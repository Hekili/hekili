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


    spec:RegisterPack( "Balance", 20201020.1, [[dG04MdqiQGhjqkDjvi2ei(euiLrrfDkQKvrfIxjaZsfXTOcL2fHFPQIHPQQJbfTmb0ZuHAAqH6AQQ02GcX3OcvJtfsDoQqADuHI5HQQ7Pc2hQkhuGuyHOk8qbsMiuirCrOqI0hHcj1jHcPALcuZufs2Pks)ekKOgkuiHLkqk6PcAQqbFfkKK9Qs)LObR0HjTyk1JrzYq1Lr2SqFgKgnu60s9AvuZMQUnLSBf)gYWb1XfivlxYZPy6axxv2UQY3PsnEufDEuLwVaX8rL9l6lMxmCdXvaDpnW)b(hZ)bIPaZapoWaVHaEHPBiSYoRqPB4Ow0nKhQxhgDdHvE9if)IHBOb9kgDdXcaWghZp)aTbyF2cgY6htB98kOrdR0i4htBX(5gA)ApaJ(CTVH4kGUNg4)a)J5)aXuGzGhJjMhFd1halQUHHTvqDdX2440CTVH4KHDddAZLhQxhgLlgLuVgpdoOnxmkZaiBQYnW)NKBG)d8FgCgCqBUbfwDGsghtgCqBUo2CdAGJt45gI8ALlpi1sKbh0MRJn3GcRoqj8CbAbLaYoMltnKjxakxgVmpjbAbLagrgCqBUo2CdAswOpcp33meJmgT4n3pTA12tMCD2csCsUWf9jnaTmVckLRJLVCHl6tyaAzEfuYL4g6BdWCXWneUiyfWWknGlgUNI5fd3qAuBpHF5XnuzGgn3qleAIDr3qw1aQA9gwuSidw12t5cjxGwqjGa0wKeGK4nLlF5IzG5cjxN5A)IrbtL9WefzP9yYLVC)nxoUCDix7xmkyQShM4bNlhxUQbuQxcJCtvU8N7X)Z1vUqYvHLmSe78nKXlZtsGwqjG5EkMxW90aVy4gsJA7j8lpUHkd0O5gAEtSl6gYQgqvR3WIIfzWQ2Ekxi5c0ckbeG2IKaKeVPC5lxmdmxi56mx7xmkyQShMOilThtU8L7V5YXLRd5A)IrbtL9Wep4C54YvnGs9syKBQYL)Cp(FUUYfsUkSKHLyNVHmEzEsc0ckbm3tX8cUNE8fd3qAuBpHF5XnuzGgn3qdG8ETKrVw0nKvnGQwVHfflYGvT9uUqYfOfuciaTfjbijEt5YxUygyUqY1zU2VyuWuzpmrrwApMC5l3FZLJlxhY1(fJcMk7HjEW5YXLRAaL6LWi3uLl)5E8)CDLlKCvyjdlXoFdz8Y8KeOfucyUNI5fCpfJVy4gsJA7j8lpUHSQbu16nuHLmSe78nuzGgn3WiQyKefLJcEfDb3t)9IHBinQTNWV84gYQgqvR3qN5QgqPEjmYnv5YxUo6)C54Y1(fJcBpcH7FgG4bNlKCTFXOW2Jq4(NbikYs7XKl)5gigjxx5cjxhY1(fJcMk7HjEW3qLbA0CdzKNmGw9s13qhlAaxW9umYfd3qAuBpHF5XnKvnGQwVHoZvnGs9syKBQYLVCD0)5YXLR9lgf2Eec3)maXdoxi5A)IrHThHW9pdquKL2Jjx(Z9ymsUUYfsUoKR9lgfmv2dt8GVHkd0O5g2dtRrbnAUG7Po(fd3qAuBpHF5XnebFdne4gQmqJMB4NwTA7PB4N6F0n0HCziKhh5Eemv2dtuKIZ7n8tl5Ow0n0OFKmIkjtL9WUG7Ph9fd3qAuBpHF5XnKvnGQwVHeZ3Wgs0JuhEZfsUkSKHLyNZfsUFA1QTNeg9JKrujzQSh2nuzGgn3W4R4vIIsY)g6cUN6OxmCdPrT9e(Lh3qw1aQA9gA)IrHbOLhv4IIS0Em5YFUyKCHKRZCTFXOGy(g2qsdYRL4bNlhxU2VyuqmFdBiP)nAjEW56kxi5QgqPEjmYnv5YxUo6)BOYanAUHmDyKxA)IXBO9lgLJAr3qdqlpQWVG7Py()IHBinQTNWV84gYQgqvR3qN56qUAqOQbKWaksp3duPbOLru6CoxoUCTFXOGPYEyIIS0Em5YFUepj2dqsqBr5YXLRd5cx0NWa0Y8kOuUUYfsUoZ1(fJcMk7HjEW5YXLRAaL6LWi3uLlF56O)ZfsUeZ3Wgs0JuhEZ11nuzGgn3qdqlZRGsxW9umX8IHBinQTNWV84gYQgqvR3qN56qUAqOQbKWaksp3duPbOLru6CoxoUCTFXOGPYEyIIS0Em5YFUepj2dqsqBr5YXLRd5(PvR2Esax0N0a0Y8kOuUUYfsUa1tdqyaA5rfUGg12t45cjxN5A)IrHbOLhv4IhCUCC5QgqPEjmYnv5YxUo6)CDLlKCTFXOWa0YJkCHbOSZ5YFUhNlKCDMR9lgfeZ3WgsAqETep4C54Y1(fJcI5Bydj9VrlXdoxx5cjxgc5XrUhbtL9WefzP9yYLVCD8BOYanAUHgGwMxbLUG7Pyg4fd3qAuBpHF5XnKvnGQwVHoZ1HC1GqvdiHbuKEUhOsdqlJO05CUCC5A)IrbtL9WefzP9yYL)CjEsShGKG2IYLJlxhYfUOpHbOL5vqPCDLlKCTFXOGy(g2qsdYRLOilThtU8LRJNlKCjMVHnKOhPb51kxi56qUa1tdqyaA5rfUGg12t45cjxgc5XrUhbtL9WefzP9yYLVCD8BOYanAUHgGwMxbLUG7PyE8fd3qAuBpHF5XnKvnGQwVHoZ1(fJcI5Bydj9VrlXdoxoUCDMldRwqjtUhYnWCHKBrmSAbLKG2IYL)C)nxx5YXLldRwqjtUhY94CDLlKCvyjdlXoNlKC)0QvBpjm6hjJOsYuzpSBOYanAUHd5wAHqZfCpftm(IHBinQTNWV84gYQgqvR3qN5A)IrbX8nSHK(3OL4bNlhxUoZLHvlOKj3d5gyUqYTigwTGssqBr5YFU)MRRC54YLHvlOKj3d5ECUCC5A)IrbtL9Wep4CDLlKCvyjdlXoNlKC)0QvBpjm6hjJOsYuzpSBOYanAUHyvFuAHqZfCpfZFVy4gsJA7j8lpUHSQbu16n0zU2VyuqmFdBiP)nAjEW5YXLRZCzy1ckzY9qUbMlKClIHvlOKe0wuU8N7V56kxoUCzy1ckzY9qUhNlhxU2VyuWuzpmXdoxx5cjxfwYWsSZ5cj3pTA12tcJ(rYiQKmv2d7gQmqJMBy859sleAUG7PyIrUy4gQmqJMBOBTQgvsuus(3q3qAuBpHF5XfCpfth)IHBinQTNWV84gYQgqvR3qN5QbHQgqcdOi9CpqLgGwgrPZ5CHKR9lgfmv2dtuKL2Jjx(YL4jXEascAlkxi5cx0NWDPaS56kxoUCDMRd5QbHQgqcdOi9CpqLgGwgrPZ5C54Y1(fJcMk7HjkYs7XKl)5s8KypajbTfLlhxUoKlCrFcdqRyxuUUYfsUoZLy(g2qIEK(3OvUCC5smFdBiHb51soepb5YXLlX8nSHe6WRCiEcYLJlx7xmkCRv1OsIIsY)gs8GZfsU2VyuqmFdBiP)nAjEW5YXLRZCTFXOGPYEyIIS0Em5YFUkd0Or4UuawbXtI9aKe0wuUqY1(fJcMk7HjEW56kxx5YXLRZC1GqvdibU6E6bQ08grPZ5C5l3aZfsU2VyuqmFdBiPb51suKL2Jjx(Y93CHKRd5A)IrbU6E6bQ08grrwApMC5lxLbA0iCxkaRG4jXEascAlkxx3qLbA0CdnaTIDrxW9ump6lgUHkd0O5g6Uua2BinQTNWV84cUNIPJEXWnKg12t4xECdvgOrZnSEJuzGgnsFBa3qFBaYrTOByu9Ea26DbxWneVi1YUhCQUy4EkMxmCdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3qN5A)IrbOTi3OAK4fPw29GtLOilThtU8LlugUWs5zUbK7FbM5cjxN5smFdBirpsBeaBUCC5smFdBirpsdYRvUCC5smFdBiH)nAjhINGCDLlhxU2VyuaAlYnQgjErQLDp4ujkYs7XKlF5QmqJgHbOvSlsq8KypajbTfLBa5(xGzUqY1zUeZ3Wgs0J0)gTYLJlxI5BydjmiVwYH4jixoUCjMVHnKqhELdXtqUUY1vUCC56qU2VyuaAlYnQgjErQLDp4ujEW3WpTKJAr3qJgjjajFgsAGjV)cUNg4fd3qAuBpHF5XnKvnGQwVHoZ1HC)0QvBpjmAKKaK8ziPbM8(C54Y1zU2Vyuu6hnONrglAccVIIS0Em5YFUqz4clLN56i5YO2NRZCvdOuVeg5MQC)j3J)NRRCHKR9lgfL(rd6zKXIMGWR4bNRRCDLlhxUQbuQxcJCtvU8LRJ()gQmqJMBObOL5vqPl4E6XxmCdPrT9e(Lh3qLbA0CdvCfg0FK04wlRBiRAavTEdDixCeqO4kmO)iPXTwwsC1sHscqZo3d0CHKRd5QmqJgHIRWG(JKg3AzjXvlfkj6rg9nuSGCHKRZCDixCeqO4kmO)iPXTwwsSK6fGMDUhO5YXLlociuCfg0FK04wlljws9IIS0Em5YxU)MRRC54YfhbekUcd6psACRLLexTuOKWau25C5p3JZfsU4iGqXvyq)rsJBTSK4QLcLefzP9yYL)Cpoxi5IJacfxHb9hjnU1YsIRwkusaA25EGEdz8Y8KeOfucyUNI5fCpfJVy4gsJA7j8lpUHkd0O5gAHqtSl6gYQgqvR3WIIfzWQ2Ekxi5c0ckbeG2IKaKeVPC5lxmdmxi56mxN5A)IrbtL9WefzP9yYLVC)nxi56mx7xmkk9Jg0ZiJfnbHxrrwApMC5l3FZLJlxhY1(fJIs)Ob9mYyrtq4v8GZ1vUCC56qU2VyuWuzpmXdoxoUCvdOuVeg5MQC5p3J)NRRCHKRZCDix7xmko3dEr4sYcg5MklAasAOcAhes8GZLJlx1ak1lHrUPkx(Z94)56kxi5QWsgwIDoxx3qgVmpjbAbLaM7PyEb3t)9IHBinQTNWV84gQmqJMBO5nXUOBiRAavTEdlkwKbRA7PCHKlqlOeqaAlscqs8MYLVCXmWCHKRZCDMR9lgfmv2dtuKL2Jjx(Y93CHKRZCTFXOO0pAqpJmw0eeEffzP9yYLVC)nxoUCDix7xmkk9Jg0ZiJfnbHxXdoxx5YXLRd5A)IrbtL9Wep4C54YvnGs9syKBQYL)Cp(FUUYfsUoZ1HCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxoUCvdOuVeg5MQC5p3J)NRRCHKRclzyj25CDDdz8Y8KeOfucyUNI5fCpfJCXWnKg12t4xECdvgOrZn0aiVxlz0RfDdzvdOQ1ByrXImyvBpLlKCbAbLacqBrsasI3uU8LlMyKCHKRZCDMR9lgfmv2dtuKL2Jjx(Y93CHKRZCTFXOO0pAqpJmw0eeEffzP9yYLVC)nxoUCDix7xmkk9Jg0ZiJfnbHxXdoxx5YXLRd5A)IrbtL9Wep4C54YvnGs9syKBQYL)Cp(FUUYfsUoZ1HCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxoUCvdOuVeg5MQC5p3J)NRRCHKRclzyj25CDDdz8Y8KeOfucyUNI5fCp1XVy4gsJA7j8lpUHSQbu16nuHLmSe78nuzGgn3WiQyKefLJcEfDb3tp6lgUH0O2Ec)YJBiRAavTEdTFXOGPYEyIh8nuzGgn3Ws)Ob9mYyrtq49cUN6OxmCdPrT9e(Lh3qw1aQA9g6mxN5A)IrbX8nSHKgKxlrrwApMC5lxm)NlhxU2VyuqmFdBiP)nAjkYs7XKlF5I5)CDLlKCziKhh5Eemv2dtuKL2Jjx(Y94)56kxoUCziKhh5Eemv2dtuKIZ7nuzGgn3WZ9GxeU0a3vdmxW9um)FXWnKg12t4xECdzvdOQ1BOZCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxoUCDixg6JgDaIZ8wTo56kxoUCzOpA0biMgkwGmQuUCC5(PvR2Es0gPIOC54Y1(fJcBpcH7FgG4bNlKCTFXOW2Jq4(NbikYs7XKl)5g4)CdixN5IX56i5Yqd(Rbc4IyTHKQVHow0ae0O2Ecpxx5cjxhY1(fJcMk7HjEW5cjxN52dGkyKxbeUm2qXcKfzP9yYL)CziKhh5Eem08HotsawsAG7QbgrrwApMCdixhpxoUC7bqfmYRacxgBOybYIS0Em5YFUbgyUCC52dGkyKxbeUm2qXcKfzP9yY9i5I5r)px(ZnWaZLJlxgc5XrUhbdnFOZKeGLKg4UAGr8GZLJlxhYLH(OrhGyAOybYOs566gQmqJMBiJ8Kb0QxQ(g6yrd4cUNIjMxmCdPrT9e(Lh3qw1aQA9g6mx7xmko3dEr4sYcg5MklAasAOcAhes8GZLJlxhYLH(OrhG4mVvRtUUYLJlxg6JgDaIPHIfiJkLlhxUFA1QTNeTrQikxoUCTFXOW2Jq4(NbiEW5cjx7xmkS9ieU)zaIIS0Em5YFUh)p3aY1zUyCUosUm0G)AGaUiwBiP6BOJfnabnQTNWZ1vUqY1HCTFXOGPYEyIhCUqY1zU9aOcg5vaHlJnuSazrwApMC5pxgc5XrUhbdnFOZKeGLKg4UAGruKL2Jj3aY1XZLJl3EaubJ8kGWLXgkwGSilThtU8N7XbMlhxU9aOcg5vaHlJnuSazrwApMCpsUyE0)ZL)CpoWC54YLHqECK7rWqZh6mjbyjPbURgyep4C54Y1HCzOpA0biMgkwGmQuUUUHkd0O5g2dtRrbnAUG7Pyg4fd3qAuBpHF5XnebFdne4gQmqJMB4NwTA7PB4N6F0nKH(OrhGyAOybYOs5cjxN5A)IrbC1wOcVvVulMontc)8gTeFQ)r5YFUbIX)ZfsUoZLHqECK7rWuzpmrrwApMCdixm)NlF52dGkyKxbeUm2qXcKfzP9yYLJlxgc5XrUhbtL9WefzP9yYnGCp(FU8NBpaQGrEfq4YydflqwKL2Jjxi52dGkyKxbeUm2qXcKfzP9yYLVCX84)5YXLR9lgfmv2dtuKL2Jjx(Y1XZ1vUqY1(fJcI5BydjniVwIIS0Em5YxUy(pxoUC7bqfmYRacxgBOybYIS0Em5EKCXmW)5YFUy(BUUUHFAjh1IUHm08HotsgAWBqJMl4EkMhFXWnKg12t4xECdrW3qdbUHkd0O5g(PvR2E6g(P(hDdDMRd5YqipoY9iyQShMOifN3C54Y1HC)0QvBpjyO5dDMKm0G3Ggn5cjxg6JgDaIPHIfiJkLRRB4NwYrTOBOr)izevsMk7HDb3tXeJVy4gsJA7j8lpUHSQbu16n8tRwT9KGHMp0zsYqdEdA0KlKCvdOuVeg5MQC5pxm()nuzGgn3qgA(qNjjaljnWD1aZfCpfZFVy4gsJA7j8lpUHSQbu16nKy(g2qIEK6WBUqYvHLmSe7CUqY1zU4iGqXvyq)rsJBTSK4QLcLeGMDUhO5YXLRd5YqF0OdqmeRqEuHNRRCHK7NwTA7jHr)izevsMk7HDdvgOrZnm(kELOOK8VHUG7PyIrUy4gsJA7j8lpUHSQbu16nKH(OrhGyAOybYOs5cj3pTA12tcgA(qNjjdn4nOrtUqYvnGs9syKBQYLVd5IX)ZfsUmeYJJCpcgA(qNjjaljnWD1aJOilThtU8NlugUWs5zUosUmQ956mx1ak1lHrUPk3FY94)566gQmqJMBObOL5vqPl4EkMo(fd3qAuBpHF5XnKvnGQwVHoZ1(fJcI5Bydj9VrlXdoxoUCDMldRwqjtUhYnWCHKBrmSAbLKG2IYL)C)nxx5YXLldRwqjtUhY94CDLlKCvyjdlXoNlKC)0QvBpjm6hjJOsYuzpSBOYanAUHd5wAHqZfCpfZJ(IHBinQTNWV84gYQgqvR3qN5A)IrbX8nSHK(3OL4bNlKCDixg6JgDaIZ8wTo5YXLRZCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxi5YqF0OdqCM3Q1jxx5YXLRZCzy1ckzY9qUbMlKClIHvlOKe0wuU8N7V56kxoUCzy1ckzY9qUhNlhxU2VyuWuzpmXdoxx5cjxfwYWsSZ5cj3pTA12tcJ(rYiQKmv2d7gQmqJMBiw1hLwi0Cb3tX0rVy4gsJA7j8lpUHSQbu16n0zU2VyuqmFdBiP)nAjEW5cjxhYLH(OrhG4mVvRtUCC56mx7xmko3dEr4sYcg5MklAasAOcAhes8GZfsUm0hn6aeN5TADY1vUCC56mxgwTGsMCpKBG5cj3Iyy1ckjbTfLl)5(BUUYLJlxgwTGsMCpK7X5YXLR9lgfmv2dt8GZ1vUqYvHLmSe7CUqY9tRwT9KWOFKmIkjtL9WUHkd0O5ggFEV0cHMl4EAG)Vy4gQmqJMBOBTQgvsuus(3q3qAuBpHF5XfCpnqmVy4gsJA7j8lpUHSQbu16nKy(g2qIEK(3OvUCC5smFdBiHb51soepb5YXLlX8nSHe6WRCiEcYLJlx7xmkCRv1OsIIsY)gs8GZfsU2VyuqmFdBiP)nAjEW5YXLRZCTFXOGPYEyIIS0Em5YFUkd0Or4UuawbXtI9aKe0wuUqY1(fJcMk7HjEW566gQmqJMBObOvSl6cUNgyGxmCdvgOrZn0DPaS3qAuBpHF5XfCpnWJVy4gsJA7j8lpUHkd0O5gwVrQmqJgPVnGBOVna5Ow0nmQEpaB9UGl4gItr95bxmCpfZlgUHkd0O5gAqETK2KADdPrT9e(LhxW90aVy4gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHgyY7LaTGsaJWa0kQEFU8LlM5cjxN56qUa1tdqyaA5rfUGg12t45YXLlq90aega59AjXRoce0O2Ecpxx5YXLRbM8EjqlOeWimaTIQ3NlF5g4n8tl5Ow0nSnsfrxW90JVy4gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHgyY7LaTGsaJWa0k2fLlF5I5n8tl5Ow0nSnsMN0p6cUNIXxmCdPrT9e(Lh3qw1aQA9g6mxhYLH(OrhGyAOybYOs5YXLRd5YqipoY9iyO5dDMKaSK0a3vdmIhCUUYfsU2VyuWuzpmXd(gQmqJMBOnvgQo3d0l4E6VxmCdPrT9e(Lh3qw1aQA9gA)IrbtL9Wep4BOYanAUHWiqJMl4Ekg5IHBOYanAUHpdjBazzUH0O2Ec)YJl4EQJFXWnKg12t4xECdzvdOQ1B4NwTA7jrBKkIUHgq1mW9umVHkd0O5gwVrQmqJgPVnGBOVna5Ow0nur0fCp9OVy4gsJA7j8lpUHSQbu16nSEdfrfusaAlYnQgjErQLDp4ujOG(RHHj8BObundCpfZBOYanAUH1BKkd0Or6Bd4g6BdqoQfDdXlsTS7bNQl4EQJEXWnKg12t4xECdzvdOQ1By9gkIkOKWw96WijkkvVxcW2duJGc6VggMWVHgq1mW9umVHkd0O5gwVrQmqJgPVnGBOVna5Ow0n0gPGl4EkM)Vy4gsJA7j8lpUHSQbu16n0tFKpx(Y93)3qLbA0CdR3ivgOrJ03gWn03gGCul6gAaxW9umX8IHBinQTNWV84gIGVHgcCdvgOrZn8tRwT90n8t9p6gcx0NWDPaS3WpTKJAr3q4I(KUlfG9cUNIzGxmCdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3q4I(egGwXUOB4NwYrTOBiCrFsdqRyx0fCpfZJVy4gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHWf9jmaTmVckDd)0soQfDdHl6tAaAzEfu6cUNIjgFXWnKg12t4xECdvgOrZnSEJuzGgnsFBa3qFBaYrTOBiCrWkGHvAaxWfCdHlIHSSvWfd3tX8IHBOYanAUHwi0CUhzevw3qAuBpHF5XfCpnWlgUHkd0O5g6Uua2BinQTNWV84cUNE8fd3qLbA0CdDxka7nKg12t4xECb3tX4lgUHkd0O5gAaAf7IUH0O2Ec)YJl4E6VxmCdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3qBKXKlKCJEeQY1zUoZn2qXcKfzP9yY1XMBG)Z1vU)KlMb(pxx5YxUrpcv56mxN5gBOybYIS0Em56yZnWFZ1XMRZCX8FUosUa1tdq0dtRrbnAe0O2Ecpxx56yZ1zUyCUosUm0G)AGaUiwBiP6BOJfnabnQTNWZ1vUUY9NCX8O)NRRB4NwYrTOBidnFOZKeNm8oSl4cUHkIUy4EkMxmCdPrT9e(Lh3qe8n0qGBOYanAUHFA1QTNUHFQ)r3qN5A)IrbOTi3OAK4fPw29GtLOilThtU8NlugUWs5zUbK7FbM5YXLR9lgfG2ICJQrIxKAz3dovIIS0Em5YFUkd0OryaAf7Ieepj2dqsqBr5gqU)fyMlKCDMlX8nSHe9i9VrRC54YLy(g2qcdYRLCiEcYLJlxI5Bydj0Hx5q8eKRRCDLlKCTFXOa0wKBuns8Iul7EWPs8GZfsU1BOiQGscqBrUr1iXlsTS7bNkbf0FnmmHFd)0soQfDdXlsTKUBVxgvVxIIXl4EAGxmCdPrT9e(Lh3qw1aQA9gA)IrHbOvu9ErrXImyvBpLlKCDMRbM8EjqlOeWimaTIQ3Nl)5ECUCC56qU1BOiQGscqBrUr1iXlsTS7bNkbf0FnmmHNRRCHKRZCDi36nuevqjHNxMwQrg9eb6bQeQVTGnKGc6VggMWZLJlxqBr5EKCX4FZLVCTFXOWa0kQEVOilThtUbKBG566gQmqJMBObOvu9(l4E6XxmCdPrT9e(Lh3qw1aQA9gwVHIOckjaTf5gvJeVi1YUhCQeuq)1WWeEUqY1atEVeOfucyegGwr17ZLVd5ECUqY1zUoKR9lgfG2ICJQrIxKAz3dovIhCUqY1(fJcdqRO69IIIfzWQ2EkxoUCDM7NwTA7jbErQL0D79YO69sumMlKCDMR9lgfgGwr17ffzP9yYL)CpoxoUCnWK3lbAbLagHbOvu9(C5l3aZfsUa1tdqyaK3RLeV6iqqJA7j8CHKR9lgfgGwr17ffzP9yYL)C)nxx56kxx3qLbA0CdnaTIQ3Fb3tX4lgUH0O2Ec)YJBic(gAiWnuzGgn3WpTA12t3Wp1)OBOAaL6LWi3uLlF5E0)Z1XMRZCX8FUosU2VyuaAlYnQgjErQLDp4ujmaLDoxx56yZ1zU2VyuyaAfvVxuKL2Jjxhj3JZ9NCnWK3lXQgaLRRCDS56mxCeqeFfVsuus(3qIIS0Em56i5(BUUYfsU2VyuyaAfvVx8GVHFAjh1IUHgGwr17LUrdqgvVxIIXl4E6VxmCdPrT9e(Lh3qw1aQA9g(PvR2EsGxKAjD3EVmQEVefJ5cj3pTA12tcdqRO69s3ObiJQ3lrX4nuzGgn3qdqlZRGsxW9umYfd3qAuBpHF5XnuzGgn3qZBIDr3qw1aQA9gwuSidw12t5cjxGwqjGa0wKeGK4nLlF5IjgNRJnxdm59sGwqjGj3aYTilThtUqYvHLmSe7CUqYLy(g2qIEK6W7nKXlZtsGwqjG5EkMxW9uh)IHBinQTNWV84gQmqJMBOIRWG(JKg3AzDdzvdOQ1BOd5cA25EGMlKCDixLbA0iuCfg0FK04wlljUAPqjrpYOVHIfKlhxU4iGqXvyq)rsJBTSK4QLcLegGYoNl)5ECUqYfhbekUcd6psACRLLexTuOKOilThtU8N7X3qgVmpjbAbLaM7PyEb3tp6lgUH0O2Ec)YJBOYanAUHwi0e7IUHSQbu16nSOyrgSQTNYfsUaTGsabOTijajXBkx(Y1zUyIX5gqUoZ1atEVeOfucyegGwXUOCDKCXu8BUUY1vU)KRbM8EjqlOeWKBa5wKL2Jjxi56mxN5YqipoY9iyQShMOifN3C54Y1atEVeOfucyegGwXUOC5p3JZLJlxN5smFdBirpsdYRvUCC5smFdBirpsBeaBUCC5smFdBirps)B0kxi56qUa1tdqyqpVefLaSKmIkYae0O2EcpxoUCTFXOaUAluH3QxQftNMjHFEJwIp1)OC57qUb(7)CDLlKCDMRbM8EjqlOeWimaTIDr5YFUy(pxhjxN5IzUbKlq90aea39iTqOXiOrT9eEUUY1vUqYvnGs9syKBQYLVC)9FUo2CTFXOWa0kQEVOilThtUosUyKCDLlKCDix7xmko3dEr4sYcg5MklAasAOcAhes8GZfsUkSKHLyNZ11nKXlZtsGwqjG5EkMxW9uh9IHBinQTNWV84gYQgqvR3qfwYWsSZ3qLbA0CdJOIrsuuok4v0fCpfZ)xmCdPrT9e(Lh3qw1aQA9gA)IrbtL9Wep4BOYanAUHL(rd6zKXIMGW7fCpftmVy4gsJA7j8lpUHSQbu16n0zU2VyuyaAfvVx8GZLJlx1ak1lHrUPkx(Y93)56kxi56qU2VyuyqEdOzK4bNlKCDix7xmkyQShM4bNlKCDMBpaQGrEfq4YydflqwKL2Jjx(ZLHqECK7rWqZh6mjbyjPbURgyefzP9yYnGCD8C54YThavWiVciCzSHIfilYs7XK7rYfZJ(FU8NBGbMlhxUmeYJJCpcgA(qNjjaljnWD1aJ4bNlhxUoKld9rJoaX0qXcKrLY11nuzGgn3qg5jdOvVu9n0XIgWfCpfZaVy4gsJA7j8lpUHSQbu16nm2qXcKfzP9yYL)CX83C54Y1zU2VyuaxTfQWB1l1IPtZKWpVrlXN6FuU8NBG)(pxoUCTFXOaUAluH3QxQftNMjHFEJwIp1)OC57qUb(7)CDLlKCTFXOWa0kQEV4bNlKCziKhh5Eemv2dtuKL2Jjx(Y93)3qLbA0Cd7HP1OGgnxW9ump(IHBinQTNWV84gQmqJMBObqEVwYOxl6gYQgqvR3WIIfzWQ2Ekxi5cAlscqs8MYLVCX83CHKRbM8EjqlOeWimaTIDr5YFUyCUqYvHLmSe7CUqY1zU2VyuWuzpmrrwApMC5lxm)NlhxUoKR9lgfmv2dt8GZ11nKXlZtsGwqjG5EkMxW9umX4lgUH0O2Ec)YJBic(gAiWnuzGgn3WpTA12t3Wp1)OBO9lgfWvBHk8w9sTy60mj8ZB0s8P(hLl)5g4V)Z1XMRAaL6LWi3uLlKCDMldH84i3JGPYEyIIS0Em5gqUy(px(Yn2qXcKfzP9yYLJlxgc5XrUhbtL9WefzP9yYnGCp(FU8NBSHIfilYs7XKlKCJnuSazrwApMC5lxmp(FUCC5A)IrbtL9WefzP9yYLVCD8CDLlKCjMVHnKOhPo8MlhxUXgkwGSilThtUhjxmd8FU8NlM)Ed)0soQfDdzO5dDMKm0G3GgnxW9um)9IHBinQTNWV84gYQgqvR3WpTA12tcgA(qNjjdn4nOrtUqYvnGs9syKBQYL)C)9)nuzGgn3qgA(qNjjaljnWD1aZfCpftmYfd3qAuBpHF5XnKvnGQwVHeZ3Wgs0JuhEZfsUkSKHLyNZfsU2VyuaxTfQWB1l1IPtZKWpVrlXN6FuU8NBG)(pxi56mxCeqO4kmO)iPXTwwsC1sHscqZo3d0C54Y1HCzOpA0bigIvipQWZLJlxdm59sGwqjGjx(YnWCDDdvgOrZnm(kELOOK8VHUG7Py64xmCdPrT9e(Lh3qw1aQA9gA)IrbAiawJeMkgbdA0iEW5cjxN5A)IrHbOvu9ErrXImyvBpLlhxUQbuQxcJCtvU8LRJ(pxx3qLbA0CdnaTIQ3Fb3tX8OVy4gsJA7j8lpUHSQbu16nKH(OrhGyAOybYOs5cj3pTA12tcgA(qNjjdn4nOrtUqYLHqECK7rWqZh6mjbyjPbURgyefzP9yYL)CHYWfwkpZ1rYLrTpxN5QgqPEjmYnv5(tU)(pxx5cjx7xmkmaTIQ3lkkwKbRA7PBOYanAUHgGwr17VG7Py6OxmCdPrT9e(Lh3qw1aQA9gYqF0OdqmnuSazuPCHK7NwTA7jbdnFOZKKHg8g0Ojxi5YqipoY9iyO5dDMKaSK0a3vdmIIS0Em5YFUqz4clLN56i5YO2NRZCvdOuVeg5MQC)j3J)NRRCHKR9lgfgGwr17fp4BOYanAUHgGwMxbLUG7Pb()IHBinQTNWV84gYQgqvR3q7xmkqdbWAKmpPL8RnnAep4C54Y1HCnaTIDrcfwYWsSZ5YXLRZCTFXOGPYEyIIS0Em5YFU)MlKCTFXOGPYEyIhCUCC56mx7xmkk9Jg0ZiJfnbHxrrwApMC5pxOmCHLYZCDKCzu7Z1zUQbuQxcJCtvU)K7X)Z1vUqY1(fJIs)Ob9mYyrtq4v8GZ1vUUYfsUFA1QTNegGwr17LUrdqgvVxIIXCHKRbM8EjqlOeWimaTIQ3Nl)5E8nuzGgn3qdqlZRGsxW90aX8IHBinQTNWV84gYQgqvR3qN5smFdBirpsD4nxi5YqipoY9iyQShMOilThtU8L7V)ZLJlxN5YWQfuYK7HCdmxi5wedRwqjjOTOC5p3FZ1vUCC5YWQfuYK7HCpoxx5cjxfwYWsSZ3qLbA0CdhYT0cHMl4EAGbEXWnKg12t4xECdzvdOQ1BOZCjMVHnKOhPo8MlKCziKhh5Eemv2dtuKL2Jjx(Y93)5YXLRZCzy1ckzY9qUbMlKClIHvlOKe0wuU8N7V56kxoUCzy1ckzY9qUhNRRCHKRclzyj25BOYanAUHyvFuAHqZfCpnWJVy4gsJA7j8lpUHSQbu16n0zUeZ3Wgs0JuhEZfsUmeYJJCpcMk7HjkYs7XKlF5(7)C54Y1zUmSAbLm5Ei3aZfsUfXWQfuscAlkx(Z93CDLlhxUmSAbLm5Ei3JZ1vUqYvHLmSe78nuzGgn3W4Z7Lwi0Cb3tdeJVy4gQmqJMBOBTQgvsuus(3q3qAuBpHF5XfCpnWFVy4gsJA7j8lpUHi4BOHa3qLbA0Cd)0QvBpDd)u)JUHgyY7LaTGsaJWa0k2fLlF5E05gqUrpcv56mxl1aOIx5N6FuU)KBG)Z1vUbKB0JqvUoZ1(fJcdqlZRGssYcg5MklAacdqzNZ9NCX4CDDd)0soQfDdnaTIDrYEKgKxRl4EAGyKlgUH0O2Ec)YJBiRAavTEdjMVHnKW)gTKdXtqUCC5smFdBiHo8khINGCHK7NwTA7jrBKmpPFuUCC5smFdBirpsdYRvUqY1HC)0QvBpjmaTIDrYEKgKxRC54Y1(fJcMk7HjkYs7XKl)5QmqJgHbOvSlsq8KypajbTfLlKCDi3pTA12tI2izEs)OCHKR9lgfmv2dtuKL2Jjx(ZL4jXEascAlkxi5A)IrbtL9Wep4C54Y1(fJIs)Ob9mYyrtq4v8GZfsUgyY7LyvdGYLVC)lWi5YXLRd5(PvR2Es0gjZt6hLlKCTFXOGPYEyIIS0Em5YxUepj2dqsqBr3qLbA0CdDxka7fCpnqh)IHBOYanAUHgGwXUOBinQTNWV84cUNg4rFXWnKg12t4xECdvgOrZnSEJuzGgnsFBa3qFBaYrTOByu9Ea26DbxWnmQEpaB9Uy4EkMxmCdPrT9e(Lh3qw1aQA9g6qU1BOiQGscB1RdJKOOu9EjaBpqnckO)Ayyc)gQmqJMBObOL5vqPl4EAGxmCdPrT9e(Lh3qLbA0CdnVj2fDdzvdOQ1BiociSqOj2fjkYs7XKlF5wKL2J5gY4L5jjqlOeWCpfZl4E6XxmCdvgOrZn0cHMyx0nKg12t4xECbxWn0aUy4EkMxmCdPrT9e(Lh3qLbA0CdvCfg0FK04wlRBiRAavTEdDixCeqO4kmO)iPXTwwsC1sHscqZo3d0CHKRd5QmqJgHIRWG(JKg3AzjXvlfkj6rg9nuSGCHKRZCDixCeqO4kmO)iPXTwwsSK6fGMDUhO5YXLlociuCfg0FK04wlljws9IIS0Em5YxU)MRRC54YfhbekUcd6psACRLLexTuOKWau25C5p3JZfsU4iGqXvyq)rsJBTSK4QLcLefzP9yYL)Cpoxi5IJacfxHb9hjnU1YsIRwkusaA25EGEdz8Y8KeOfucyUNI5fCpnWlgUH0O2Ec)YJBOYanAUHwi0e7IUHSQbu16n0zU2VyuWuzpmrrwApMC5l3FZfsUoZ1(fJIs)Ob9mYyrtq4vuKL2Jjx(Y93C54Y1HCTFXOO0pAqpJmw0eeEfp4CDLlhxUoKR9lgfmv2dt8GZLJlx1ak1lHrUPkx(Z94)56kxi56mxhY1(fJIZ9GxeUKSGrUPYIgGKgQG2bHep4C54YvnGs9syKBQYL)Cp(FUUYfsUkSKHLyNVHmEzEsc0ckbm3tX8cUNE8fd3qAuBpHF5XnuzGgn3qZBIDr3qw1aQA9gwuSidw12t5cjxGwqjGa0wKeGK4nLlF5IzG5cjxN5A)IrbtL9WefzP9yYLVC)nxi56mx7xmkk9Jg0ZiJfnbHxrrwApMC5l3FZLJlxhY1(fJIs)Ob9mYyrtq4v8GZ1vUCC56qU2VyuWuzpmXdoxoUCvdOuVeg5MQC5p3J)NRRCHKRZCDix7xmko3dEr4sYcg5MklAasAOcAhes8GZLJlx1ak1lHrUPkx(Z94)56kxi5QWsgwID(gY4L5jjqlOeWCpfZl4EkgFXWnKg12t4xECdvgOrZn0aiVxlz0RfDdzvdOQ1ByrXImyvBpLlKCbAbLacqBrsasI3uU8LlMyKCHKRZCTFXOGPYEyIIS0Em5YxU)MlKCDMR9lgfL(rd6zKXIMGWROilThtU8L7V5YXLRd5A)IrrPF0GEgzSOji8kEW56kxoUCDix7xmkyQShM4bNlhxUQbuQxcJCtvU8N7X)Z1vUqY1zUoKR9lgfN7bViCjzbJCtLfnajnubTdcjEW5YXLRAaL6LWi3uLl)5E8)CDLlKCvyjdlXoFdz8Y8KeOfucyUNI5fCp93lgUH0O2Ec)YJBiRAavTEdvyjdlXoFdvgOrZnmIkgjrr5OGxrxW9umYfd3qAuBpHF5XnKvnGQwVH2VyuWuzpmXd(gQmqJMByPF0GEgzSOji8Eb3tD8lgUH0O2Ec)YJBiRAavTEdDMRZCTFXOGy(g2qsdYRLOilThtU8LlM)ZLJlx7xmkiMVHnK0)gTefzP9yYLVCX8FUUYfsUmeYJJCpcMk7HjkYs7XKlF5E8)CHKRZCTFXOaUAluH3QxQftNMjHFEJwIp1)OC5p3aX4)5YXLRd5wVHIOckjGR2cv4T6LAX0Pzs4N3OLGc6VggMWZ1vUUYLJlx7xmkGR2cv4T6LAX0Pzs4N3OL4t9pkx(oKBGo()C54YLHqECK7rWuzpmrrkoV5cjxN5QgqPEjmYnv5YxUo6)C54Y9tRwT9KOnsfr566gQmqJMB45EWlcxAG7QbMl4E6rFXWnKg12t4xECdzvdOQ1BOZCvdOuVeg5MQC5lxh9FUqY1zU2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNlhxUoKld9rJoaXzERwNCDLlhxUm0hn6aetdflqgvkxoUC)0QvBpjAJuruUCC5A)IrHThHW9pdq8GZfsU2Vyuy7riC)ZaefzP9yYL)Cd8FUbKRZCDMRJMRJKB9gkIkOKaUAluH3QxQftNMjHFEJwckO)Ayycpxx5gqUoZfJZ1rYLHg8xdeWfXAdjvFdDSObiOrT9eEUUY1vUUYfsUoKR9lgfmv2dt8GZfsUoZn2qXcKfzP9yYL)CziKhh5Eem08HotsawsAG7QbgrrwApMCdixhpxoUCJnuSazrwApMC5p3adm3aY1zUoAUosUoZ1(fJc4QTqfEREPwmDAMe(5nAj(u)JYLVCX8))CDLRRC54Yn2qXcKfzP9yY9i5I5r)px(ZnWaZLJlxgc5XrUhbdnFOZKeGLKg4UAGr8GZLJlxhYLH(OrhGyAOybYOs566gQmqJMBiJ8Kb0QxQ(g6yrd4cUN6OxmCdPrT9e(Lh3qw1aQA9g6mx1ak1lHrUPkx(Y1r)NlKCDMR9lgfN7bViCjzbJCtLfnajnubTdcjEW5YXLRd5YqF0OdqCM3Q1jxx5YXLld9rJoaX0qXcKrLYLJl3pTA12tI2iveLlhxU2Vyuy7riC)Zaep4CHKR9lgf2Eec3)marrwApMC5p3J)NBa56mxN56O56i5wVHIOckjGR2cv4T6LAX0Pzs4N3OLGc6VggMWZ1vUbKRZCX4CDKCzOb)1abCrS2qs13qhlAacAuBpHNRRCDLRRCHKRd5A)IrbtL9Wep4CHKRZCJnuSazrwApMC5pxgc5XrUhbdnFOZKeGLKg4UAGruKL2Jj3aY1XZLJl3ydflqwKL2Jjx(Z94aZnGCDMRJMRJKRZCTFXOaUAluH3QxQftNMjHFEJwIp1)OC5lxm))pxx56kxoUCJnuSazrwApMCpsUyE0)ZL)CpoWC54YLHqECK7rWqZh6mjbyjPbURgyep4C54Y1HCzOpA0biMgkwGmQuUUUHkd0O5g2dtRrbnAUG7Py()IHBinQTNWV84gIGVHgcCdvgOrZn8tRwT90n8t9p6gYqF0OdqmnuSazuPCHKRZCTFXOaUAluH3QxQftNMjHFEJwIp1)OC5p3aX4)5cjxN5YqipoY9iyQShMOilThtUbKlM)ZLVCJnuSazrwApMC54YLHqECK7rWuzpmrrwApMCdi3J)Nl)5gBOybYIS0Em5cj3ydflqwKL2Jjx(YfZJ)NlhxU2VyuWuzpmrrwApMC5lxhpxx5cjx7xmkiMVHnK0G8AjkYs7XKlF5I5)C54Yn2qXcKfzP9yY9i5IzG)ZL)CX83CDDd)0soQfDdzO5dDMKm0G3GgnxW9umX8IHBinQTNWV84gIGVHgcCdvgOrZn8tRwT90n8t9p6g6mxhYLHqECK7rWuzpmrrkoV5YXLRd5(PvR2EsWqZh6mjzObVbnAYfsUm0hn6aetdflqgvkxx3WpTKJAr3qJ(rYiQKmv2d7cUNIzGxmCdPrT9e(Lh3qw1aQA9g(PvR2EsWqZh6mjzObVbnAYfsUQbuQxcJCtvU8N7X)VHkd0O5gYqZh6mjbyjPbURgyUG7PyE8fd3qAuBpHF5XnKvnGQwVHeZ3Wgs0JuhEZfsUkSKHLyNZfsU2VyuaxTfQWB1l1IPtZKWpVrlXN6FuU8NBGy8)CHKRZCXraHIRWG(JKg3AzjXvlfkjan7CpqZLJlxhYLH(OrhGyiwH8Ocpxx5cj3pTA12tcJ(rYiQKmv2d7gQmqJMBy8v8krrj5FdDb3tXeJVy4gsJA7j8lpUHSQbu16n0(fJc0qaSgjmvmcg0Or8GZfsU2VyuyaAfvVxuuSidw12t3qLbA0CdnaTIQ3Fb3tX83lgUH0O2Ec)YJBiRAavTEdTFXOWa0YJkCrrwApMC5p3FZfsUoZ1(fJcI5BydjniVwIIS0Em5YxU)MlhxU2VyuqmFdBiP)nAjkYs7XKlF5(BUUYfsUQbuQxcJCtvU8LRJ()gQmqJMBithg5L2Vy8gA)Ir5Ow0n0a0YJk8l4EkMyKlgUH0O2Ec)YJBiRAavTEdzOpA0biMgkwGmQuUqY9tRwT9KGHMp0zsYqdEdA0KlKCziKhh5Eem08HotsawsAG7QbgrrwApMC5pxOmCHLYZCDKCzu7Z1zUQbuQxcJCtvU)K7X)Z11nuzGgn3qdqlZRGsxW9umD8lgUH0O2Ec)YJBiRAavTEdbQNgGWaiVxljE1rGGg12t45cjxhYfOEAacdqlpQWf0O2Ecpxi5A)IrHbOvu9ErrXImyvBpLlKCDMR9lgfeZ3Wgs6FJwIIS0Em5YxUyKCHKlX8nSHe9i9VrRCHKR9lgfWvBHk8w9sTy60mj8ZB0s8P(hLl)5g4V)ZLJlx7xmkGR2cv4T6LAX0Pzs4N3OL4t9pkx(oKBG)(pxi5QgqPEjmYnv5YxUo6)C54YfhbekUcd6psACRLLexTuOKOilThtU8L7rNlhxUkd0OrO4kmO)iPXTwwsC1sHsIEKrFdflixx5cjxhYLHqECK7rWuzpmrrkoV3qLbA0CdnaTIQ3Fb3tX8OVy4gsJA7j8lpUHSQbu16n0(fJc0qaSgjZtAj)AtJgXdoxoUCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxoUCTFXOGPYEyIhCUqY1zU2Vyuu6hnONrglAccVIIS0Em5YFUqz4clLN56i5YO2NRZCvdOuVeg5MQC)j3J)NRRCHKR9lgfL(rd6zKXIMGWR4bNlhxUoKR9lgfL(rd6zKXIMGWR4bNlKCDixgc5XrUhrPF0GEgzSOji8kksX5nxoUCDixg6JgDaIpAay5TY1vUCC5QgqPEjmYnv5YxUo6)CHKlX8nSHe9i1H3BOYanAUHgGwMxbLUG7Py6OxmCdPrT9e(Lh3qw1aQA9gcupnaHbOLhv4cAuBpHNlKCDMR9lgfgGwEuHlEW5YXLRAaL6LWi3uLlF56O)Z1vUqY1(fJcdqlpQWfgGYoNl)5ECUqY1zU2VyuqmFdBiPb51s8GZLJlx7xmkiMVHnK0)gTep4CDLlKCTFXOaUAluH3QxQftNMjHFEJwIp1)OC5p3aD8)5cjxN5YqipoY9iyQShMOilThtU8LlM)ZLJlxhY9tRwT9KGHMp0zsYqdEdA0KlKCzOpA0biMgkwGmQuUUUHkd0O5gAaAzEfu6cUNg4)lgUH0O2Ec)YJBiRAavTEdDMR9lgfWvBHk8w9sTy60mj8ZB0s8P(hLl)5gOJ)pxoUCTFXOaUAluH3QxQftNMjHFEJwIp1)OC5p3a)9FUqYfOEAacdG8ETK4vhbcAuBpHNRRCHKR9lgfeZ3WgsAqETefzP9yYLVCD8CHKlX8nSHe9iniVw5cjxhY1(fJc0qaSgjmvmcg0Or8GZfsUoKlq90aegGwEuHlOrT9eEUqYLHqECK7rWuzpmrrwApMC5lxhpxi56mxgc5XrUhX5EWlcxAG7QbgrrwApMC5lxhpxoUCDixg6JgDaIZ8wTo566gQmqJMBObOL5vqPl4EAGyEXWnKg12t4xECdzvdOQ1BOZCTFXOGy(g2qs)B0s8GZLJlxN5YWQfuYK7HCdmxi5wedRwqjjOTOC5p3FZ1vUCC5YWQfuYK7HCpoxx5cjxfwYWsSZ5cj3pTA12tcJ(rYiQKmv2d7gQmqJMB4qULwi0Cb3tdmWlgUH0O2Ec)YJBiRAavTEdDMR9lgfeZ3Wgs6FJwIhCUqY1HCzOpA0bioZB16KlhxUoZ1(fJIZ9GxeUKSGrUPYIgGKgQG2bHep4CHKld9rJoaXzERwNCDLlhxUoZLHvlOKj3d5gyUqYTigwTGssqBr5YFU)MRRC54YLHvlOKj3d5ECUCC5A)IrbtL9Wep4CDLlKCvyjdlXoNlKC)0QvBpjm6hjJOsYuzpSBOYanAUHyvFuAHqZfCpnWJVy4gsJA7j8lpUHSQbu16n0zU2VyuqmFdBiP)nAjEW5cjxhYLH(OrhG4mVvRtUCC56mx7xmko3dEr4sYcg5MklAasAOcAhes8GZfsUm0hn6aeN5TADY1vUCC56mxgwTGsMCpKBG5cj3Iyy1ckjbTfLl)5(BUUYLJlxgwTGsMCpK7X5YXLR9lgfmv2dt8GZ1vUqYvHLmSe7CUqY9tRwT9KWOFKmIkjtL9WUHkd0O5ggFEV0cHMl4EAGy8fd3qLbA0CdDRv1OsIIsY)g6gsJA7j8lpUG7Pb(7fd3qAuBpHF5XnKvnGQwVHeZ3Wgs0J0)gTYLJlxI5BydjmiVwYH4jixoUCjMVHnKqhELdXtqUCC5A)IrHBTQgvsuus(3qIhCUqY1(fJcI5Bydj9VrlXdoxoUCDMR9lgfmv2dtuKL2Jjx(ZvzGgnc3LcWkiEsShGKG2IYfsU2VyuWuzpmXdoxx3qLbA0CdnaTIDrxW90aXixmCdvgOrZn0DPaS3qAuBpHF5XfCpnqh)IHBinQTNWV84gQmqJMBy9gPYanAK(2aUH(2aKJAr3WO69aS17cUGBOnsbxmCpfZlgUH0O2Ec)YJBiRAavTEdTFXOGPYEyIh8nuzGgn3Ws)Ob9mYyrtq49cUNg4fd3qAuBpHF5XnebFdne4gQmqJMB4NwTA7PB4N6F0n0HCTFXOWw96WijkkvVxcW2duJCuWRiXdoxi56qU2VyuyREDyKefLQ3lby7bQrQfths8GVHFAjh1IUHSQbdc8GVG7PhFXWnKg12t4xECdzvdOQ1BOZCTFXOWw96WijkkvVxcW2duJCuWRirrwApMC5lxmw8BUCC5A)IrHT61HrsuuQEVeGThOgPwmDirrwApMC5lxmw8BUUYfsUQbuQxcJCtvU8Dixh9FUqY1zUmeYJJCpcMk7HjkYs7XKlF5645YXLRZCziKhh5EeKfmYnvsB0GlkYs7XKlF5645cjxhY1(fJIZ9GxeUKSGrUPYIgGKgQG2bHep4CHKld9rJoaXzERwNCDLRRBOYanAUHmDyKxA)IXBO9lgLJAr3qdqlpQWVG7Py8fd3qAuBpHF5XnKvnGQwVHoK7NwTA7jbRAWGap4CHKRZCDMRd5YqipoY9iyO5dDMKaSK0a3vdmIhCUCC56qUFA1QTNem08HotsgAWBqJMC54Y1HCzOpA0biMgkwGmQuUUYfsUoZLH(OrhGyAOybYOs5YXLRZCziKhh5Eemv2dtuKL2Jjx(Y1XZLJlxN5YqipoY9iilyKBQK2ObxuKL2Jjx(Y1XZfsUoKR9lgfN7bViCjzbJCtLfnajnubTdcjEW5cjxg6JgDaIZ8wTo56kxx56kxx5YXLRZCziKhh5Eem08HotsawsAG7QbgXdoxi5YqipoY9iyQShMOifN3CHKld9rJoaX0qXcKrLY11nuzGgn3qdqlZRGsxW90FVy4gsJA7j8lpUHkd0O5gQ4kmO)iPXTww3qw1aQA9g6qU4iGqXvyq)rsJBTSK4QLcLeGMDUhO5cjxhYvzGgncfxHb9hjnU1YsIRwkus0Jm6BOyb5cjxN56qU4iGqXvyq)rsJBTSKyj1lan7CpqZLJlxCeqO4kmO)iPXTwwsSK6ffzP9yYLVC)nxx5YXLlociuCfg0FK04wlljUAPqjHbOSZ5YFUhNlKCXraHIRWG(JKg3AzjXvlfkjkYs7XKl)5ECUqYfhbekUcd6psACRLLexTuOKa0SZ9a9gY4L5jjqlOeWCpfZl4Ekg5IHBinQTNWV84gQmqJMBO5nXUOBiRAavTEdlkwKbRA7PCHKlqlOeqaAlscqs8MYLVCXeJKlKCvyjdlXoNlKCDM7NwTA7jbRAWGap4C54Y1zUQbuQxcJCtvU8N7X)ZfsUoKR9lgfmv2dt8GZ1vUCC5YqipoY9iyQShMOifN3CDDdz8Y8KeOfucyUNI5fCp1XVy4gsJA7j8lpUHkd0O5gAHqtSl6gYQgqvR3WIIfzWQ2Ekxi5c0ckbeG2IKaKeVPC5lxmpw8BUqYvHLmSe7CUqY1zUFA1QTNeSQbdc8GZLJlxN5QgqPEjmYnv5YFUh)pxi56qU2VyuWuzpmXdoxx5YXLldH84i3JGPYEyIIuCEZ1vUqY1HCTFXO4Cp4fHljlyKBQSObiPHkODqiXd(gY4L5jjqlOeWCpfZl4E6rFXWnKg12t4xECdvgOrZn0aiVxlz0RfDdzvdOQ1ByrXImyvBpLlKCbAbLacqBrsasI3uU8LlMyKCdi3IS0Em5cjxfwYWsSZ5cjxN5(PvR2EsWQgmiWdoxoUCvdOuVeg5MQC5p3J)NlhxUmeYJJCpcMk7HjksX5nxx3qgVmpjbAbLaM7PyEb3tD0lgUH0O2Ec)YJBiRAavTEdvyjdlXoFdvgOrZnmIkgjrr5OGxrxW9um)FXWnKg12t4xECdzvdOQ1BOZCjMVHnKOhPo8MlhxUeZ3WgsyqETK9iXmxoUCjMVHnKW)gTK9iXmxx5cjxN56qUm0hn6aetdflqgvkxoUCDMRAaL6LWi3uLl)56O)MlKCDM7NwTA7jbRAWGap4C54YvnGs9syKBQYL)Cp(FUCC5(PvR2Es0gPIOCDLlKCDM7NwTA7jbdnFOZKeNm8oSCHKRd5YqipoY9iyO5dDMKaSK0a3vdmIhCUCC56qUFA1QTNem08HotsCYW7WYfsUoKldH84i3JGPYEyIhCUUY1vUUYfsUoZLHqECK7rWuzpmrrwApMC5l3J)NlhxUQbuQxcJCtvU8LRJ(pxi5YqipoY9iyQShM4bNlKCDMldH84i3JGSGrUPsAJgCrrwApMC5pxLbA0imaTIDrcINe7bijOTOC54Y1HCzOpA0bioZB16KRRC54Yn2qXcKfzP9yYL)CX8FUUYfsUoZfhbekUcd6psACRLLexTuOKOilThtU8LlgNlhxUoKld9rJoaXqSc5rfEUUUHkd0O5ggFfVsuus(3qxW9umX8IHBinQTNWV84gYQgqvR3qN5smFdBiH)nAjhINGC54YLy(g2qcdYRLCiEcYLJlxI5Bydj0Hx5q8eKlhxU2VyuyREDyKefLQ3lby7bQrok4vKOilThtU8Llgl(nxoUCTFXOWw96WijkkvVxcW2duJulMoKOilThtU8Llgl(nxoUCvdOuVeg5MQC5lxh9FUqYLHqECK7rWuzpmrrkoV56kxi56mxgc5XrUhbtL9WefzP9yYLVCp(FUCC5YqipoY9iyQShMOifN3CDLlhxUXgkwGSilThtU8NlM)VHkd0O5gEUh8IWLg4UAG5cUNIzGxmCdPrT9e(Lh3qw1aQA9g6mx1ak1lHrUPkx(Y1r)NlKCDMR9lgfN7bViCjzbJCtLfnajnubTdcjEW5YXLRd5YqF0OdqCM3Q1jxx5YXLld9rJoaX0qXcKrLYLJlx7xmkS9ieU)zaIhCUqY1(fJcBpcH7FgGOilThtU8NBG)ZnGCDMlgNRJKldn4VgiGlI1gsQ(g6yrdqqJA7j8CDLRRCHKRZCDixg6JgDaIPHIfiJkLlhxUmeYJJCpcgA(qNjjaljnWD1aJ4bNlhxUXgkwGSilThtU8NldH84i3JGHMp0zscWssdCxnWikYs7XKBa5IrYLJl3ydflqwKL2Jj3JKlMh9)C5p3a)NBa56mxmoxhjxgAWFnqaxeRnKu9n0XIgGGg12t456kxx3qLbA0CdzKNmGw9s13qhlAaxW9ump(IHBinQTNWV84gYQgqvR3qN5QgqPEjmYnv5YxUo6)CHKRZCTFXO4Cp4fHljlyKBQSObiPHkODqiXdoxoUCDixg6JgDaIZ8wTo56kxoUCzOpA0biMgkwGmQuUCC5A)IrHThHW9pdq8GZfsU2Vyuy7riC)ZaefzP9yYL)Cp(FUbKRZCX4CDKCzOb)1abCrS2qs13qhlAacAuBpHNRRCDLlKCDMRd5YqF0OdqmnuSazuPC54YLHqECK7rWqZh6mjbyjPbURgyep4C54Y9tRwT9KGHMp0zsItgEhwUqYn2qXcKfzP9yYLVCX8O)NBa5g4)CdixN5IX56i5Yqd(Rbc4IyTHKQVHow0ae0O2Ecpxx5YXLBSHIfilYs7XKl)5YqipoY9iyO5dDMKaSK0a3vdmIIS0Em5gqUyKC54Yn2qXcKfzP9yYL)Cp(FUbKRZCX4CDKCzOb)1abCrS2qs13qhlAacAuBpHNRRCDDdvgOrZnShMwJcA0Cb3tXeJVy4gsJA7j8lpUHSQbu16n0zUFA1QTNem08HotsCYW7WYfsUXgkwGSilThtU8LlMh)pxoUCTFXOGPYEyIhCUUYfsUoZ1(fJcB1RdJKOOu9EjaBpqnYrbVIegGYol)u)JYLVCp(FUCC5A)IrHT61HrsuuQEVeGThOgPwmDiHbOSZYp1)OC5l3J)NRRC54Yn2qXcKfzP9yYL)CX8)nuzGgn3qgA(qNjjaljnWD1aZfCpfZFVy4gsJA7j8lpUHSQbu16nKH(OrhGyAOybYOs5cjxN5(PvR2EsWqZh6mjXjdVdlxoUCziKhh5Eemv2dtuKL2Jjx(ZfZ)56kxi5QgqPEjmYnv5YxU)(pxi5YqipoY9iyO5dDMKaSK0a3vdmIIS0Em5YFUy()gQmqJMBObOL5vqPl4EkMyKlgUH0O2Ec)YJBic(gAiWnuzGgn3WpTA12t3Wp1)OBiX8nSHe9i9VrRCDKCp6C)jxLbA0imaTIDrcINe7bijOTOCdixhYLy(g2qIEK(3OvUosUyKC)jxLbA0iCxkaRG4jXEascAlk3aY9ViWC)jxdm59sSQbq3WpTKJAr3q1aJrbvHe7cUNIPJFXWnKg12t4xECdzvdOQ1BOZC7bqfmYRacxgBOybYIS0Em5YFUyCUCC56mx7xmkk9Jg0ZiJfnbHxrrwApMC5pxOmCHLYZCDKCzu7Z1zUQbuQxcJCtvU)K7X)Z1vUqY1(fJIs)Ob9mYyrtq4v8GZ1vUUYLJlxN5QgqPEjmYnv5gqUFA1QTNeQbgJcQcjwUosU2VyuqmFdBiPb51suKL2Jj3aYfhbeXxXRefLK)nKa0SZgzrwAp56i5gO43C5lxmd8FUCC5QgqPEjmYnv5gqUFA1QTNeQbgJcQcjwUosU2VyuqmFdBiP)nAjkYs7XKBa5IJaI4R4vIIsY)gsaA2zJSilTNCDKCdu8BU8LlMb(pxx5cjxI5Bydj6rQdV5cjxN56mxhYLHqECK7rWuzpmXdoxoUCzOpA0bioZB16KlKCDixgc5XrUhbzbJCtL0gn4IhCUUYLJlxg6JgDaIPHIfiJkLRRCHKRZCDixg6JgDaIpAay5TYLJlxhY1(fJcMk7HjEW5YXLRAaL6LWi3uLlF56O)Z1vUCC5A)IrbtL9WefzP9yYLVCp6CHKRd5A)IrrPF0GEgzSOji8kEW3qLbA0CdnaTmVckDb3tX8OVy4gsJA7j8lpUHSQbu16n0zU2VyuqmFdBiP)nAjEW5YXLRZCzy1ckzY9qUbMlKClIHvlOKe0wuU8N7V56kxoUCzy1ckzY9qUhNRRCHKRclzyj25BOYanAUHd5wAHqZfCpfth9IHBinQTNWV84gYQgqvR3qN5A)IrbX8nSHK(3OL4bNlhxUoZLHvlOKj3d5gyUqYTigwTGssqBr5YFU)MRRC54YLHvlOKj3d5ECUUYfsUkSKHLyNVHkd0O5gIv9rPfcnxW90a)FXWnKg12t4xECdzvdOQ1BOZCTFXOGy(g2qs)B0s8GZLJlxN5YWQfuYK7HCdmxi5wedRwqjjOTOC5p3FZ1vUCC5YWQfuYK7HCpoxx5cjxfwYWsSZ3qLbA0CdJpVxAHqZfCpnqmVy4gQmqJMBOBTQgvsuus(3q3qAuBpHF5XfCpnWaVy4gsJA7j8lpUHSQbu16nKy(g2qIEK(3OvUCC5smFdBiHb51soepb5YXLlX8nSHe6WRCiEcYLJlx7xmkCRv1OsIIsY)gs8GZfsUeZ3Wgs0J0)gTYLJlxN5A)IrbtL9WefzP9yYL)CvgOrJWDPaScINe7bijOTOCHKR9lgfmv2dt8GZ11nuzGgn3qdqRyx0fCpnWJVy4gQmqJMBO7sbyVH0O2Ec)YJl4EAGy8fd3qAuBpHF5XnuzGgn3W6nsLbA0i9TbCd9Tbih1IUHr17byR3fCbxWn8JktJM7Pb(pW)y(pW)3q3An9a1CdXOkOrqZtXOFkg1oMCZfdyPCBlyubYnIQCXOHxKAz3dovy0YTOG(RlcpxdYIYvFaKLci8Czy1bkzezWhvpuUb6yYnOqZhvacp3W2kOY1W7auEM7rYfGY9OEAU49xBA0KlcMkfGQCD(JRCDIjpDjYGpQEOCX8VJj3GcnFubi8CdBRGkxdVdq5zUh5i5cq5Eupnxle(Z)m5IGPsbOkxNhXvUoXKNUezWhvpuUyIPJj3GcnFubi8CdBRGkxdVdq5zUh5i5cq5Eupnxle(Z)m5IGPsbOkxNhXvUoXKNUezWhvpuUygOJj3GcnFubi8CdBRGkxdVdq5zUh5i5cq5Eupnxle(Z)m5IGPsbOkxNhXvUoXKNUezWhvpuUyIrCm5guO5JkaHNByBfu5A4DakpZ9i5cq5Eupnx8(RnnAYfbtLcqvUo)XvUoXKNUezWzWyuf0iO5Py0pfJAhtU5IbSuUTfmQa5grvUy0GlIHSSvagTClkO)6IWZ1GSOC1hazPacpxgwDGsgrg8r1dL7VoMCdk08rfGWZnSTcQCn8oaLN5EKCbOCpQNMlE)1Mgn5IGPsbOkxN)4kxNbYtxIm4mymQcAe08um6NIrTJj3CXawk32cgvGCJOkxmAkIWOLBrb9xxeEUgKfLR(ailfq45YWQduYiYGpQEOCd0XKBqHMpQaeEUHTvqLRH3bO8m3JCKCbOCpQNMRfc)5FMCrWuPauLRZJ4kxNyYtxIm4JQhkxm2XKBqHMpQaeEUHTvqLRH3bO8m3JKlaL7r90CX7V20Ojxemvkav568hx56etE6sKbFu9q5E0oMCdk08rfGWZnSTcQCn8oaLN5EKCbOCpQNMlE)1Mgn5IGPsbOkxN)4kxNyYtxIm4JQhkxmX0XKBqHMpQaeEUHTvqLRH3bO8m3JCKCbOCpQNMRfc)5FMCrWuPauLRZJ4kxNyYtxIm4JQhkxmd0XKBqHMpQaeEUHTvqLRH3bO8m3JCKCbOCpQNMRfc)5FMCrWuPauLRZJ4kxNyYtxIm4JQhkxmXyhtUbfA(Ocq45g2wbvUgEhGYZCpYrYfGY9OEAUwi8N)zYfbtLcqvUopIRCDIjpDjYGpQEOCX8ODm5guO5JkaHNByBfu5A4DakpZ9i5cq5Eupnx8(RnnAYfbtLcqvUo)XvUoXKNUezWhvpuUy6OoMCdk08rfGWZnSTcQCn8oaLN5EKCbOCpQNMlE)1Mgn5IGPsbOkxN)4kxNyYtxIm4JQhk3a)7yYnOqZhvacp3W2kOY1W7auEM7rYfGY9OEAU49xBA0KlcMkfGQCD(JRCDIjpDjYGpQEOCd8xhtUbfA(Ocq45g2wbvUgEhGYZCpsUauUh1tZfV)AtJMCrWuPauLRZFCLRZa5PlrgCgmgvbncAEkg9tXO2XKBUyalLBBbJkqUruLlgndaJwUff0FDr45AqwuU6dGSuaHNldRoqjJid(O6HY9ODm5guO5JkaHNByBfu5A4DakpZ9ihjxak3J6P5AHWF(Njxemvkav568iUY1jM80Lid(O6HY1rDm5guO5JkaHNByBfu5A4DakpZ9ihjxak3J6P5AHWF(Njxemvkav568iUY1jM80Lid(O6HYfZ)oMCdk08rfGWZnSTcQCn8oaLN5EKJKlaL7r90CTq4p)ZKlcMkfGQCDEex56etE6sKbFu9q5IjgXXKBqHMpQaeEUHTvqLRH3bO8m3JKlaL7r90CX7V20Ojxemvkav568hx56etE6sKbFu9q5I5r7yYnOqZhvacp3W2kOY1W7auEM7rYfGY9OEAU49xBA0KlcMkfGQCD(JRCDIjpDjYGZGXOkOrqZtXOFkg1oMCZfdyPCBlyubYnIQCXOzJuagTClkO)6IWZ1GSOC1hazPacpxgwDGsgrg8r1dLlMb6yYnOqZhvacp3W2kOY1W7auEM7rosUauUh1tZ1cH)8ptUiyQuaQY15rCLRtm5Plrg8r1dLlMyehtUbfA(Ocq45g2wbvUgEhGYZCpsUauUh1tZfV)AtJMCrWuPauLRZFCLRZJ5Plrg8r1dLlMoUJj3GcnFubi8CdBRGkxdVdq5zUhjxak3J6P5I3FTPrtUiyQuaQY15pUY1jM80LidodgJUfmQaeEUhDUkd0OjxFBagrg8neUqX2t3WG2C5H61Hr5Irj1RXZGdAZfJYmaYMQCd8)j5g4)a)NbNbh0MBqHvhOKXXKbh0MRJn3Gg44eEUHiVw5YdsTezWbT56yZnOWQducpxGwqjGSJ5YudzYfGYLXlZtsGwqjGrKbh0MRJn3GMKf6JWZ9ndXiJrlEZ9tRwT9KjxNTGeNKlCrFsdqlZRGs56y5lx4I(egGwMxbLCjYGZGvgOrJraxedzzRGdwi0CUhzevwzWkd0OXiGlIHSSvqah(XDPaSzWkd0OXiGlIHSSvqah(XDPaSzWkd0OXiGlIHSSvqah(Xa0k2fLbRmqJgJaUigYYwbbC4NpTA12tNmQfDGHMp0zsItgEh2jFQ)rhSrgdKOhHkNoJnuSazrwApghBG)DDemd8Vl(IEeQC6m2qXcKfzP9yCSb(RJ1jM)DeG6Pbi6HP1OGgncAuBpH7YX6eJDegAWFnqaxeRnKu9n0XIgGGg12t4UCDemp6)UYGZGdAZfJs5jXEacpx6JkEZf0wuUaSuUkdGQCBtU6N2E12tImyLbA0yoyqETK2KALbRmqJgtah(5tRwT90jJArhAJur0jFQ)rhmWK3lbAbLagHbOvu9E(WeIthaQNgGWa0YJkCbnQTNW54aQNgGWaiVxljE1rGGg12t4U44mWK3lbAbLagHbOvu9E(cmdwzGgnMao8ZNwTA7Ptg1Io0gjZt6hDYN6F0bdm59sGwqjGryaAf7I4dZmyLbA0yc4Wp2uzO6CpqpPJhC6ad9rJoaX0qXcKrL44CGHqECK7rWqZh6mjbyjPbURgyepyxqSFXOGPYEyIhCgSYanAmbC4hyeOrZjD8G9lgfmv2dt8GZGvgOrJjGd)8mKSbKLjdwzGgnMao8t9gPYanAK(2aozul6GIOtmGQzGdyEshp8PvR2Es0gPIOmyLbA0yc4Wp1BKkd0Or6Bd4KrTOd4fPw29Gt1jgq1mWbmpPJhQ3qrubLeG2ICJQrIxKAz3dovckO)AyycpdwzGgnMao8t9gPYanAK(2aozul6GnsbNyavZahW8KoEOEdfrfusyREDyKefLQ3lby7bQrqb9xddt4zWkd0OXeWHFQ3ivgOrJ03gWjJArhmGt64bp9rE((9FgSYanAmbC4NpTA12tNmQfDaUOpP7sbyp5t9p6aCrFc3LcWMbRmqJgtah(5tRwT90jJArhGl6tAaAf7Io5t9p6aCrFcdqRyxugSYanAmbC4NpTA12tNmQfDaUOpPbOL5vqPt(u)Joax0NWa0Y8kOugSYanAmbC4N6nsLbA0i9TbCYOw0b4IGvadR0aYGZGvgOrJrOi6WNwTA7Ptg1IoGxKAjD3EVmQEVefJN8P(hDWP9lgfG2ICJQrIxKAz3dovIIS0Em8dLHlSuEgWFbMCC2VyuaAlYnQgjErQLDp4ujkYs7XWVYanAegGwXUibXtI9aKe0wua)fycXjX8nSHe9i9VrlooI5BydjmiVwYH4jGJJy(g2qcD4voepbUCbX(fJcqBrUr1iXlsTS7bNkXdgs9gkIkOKa0wKBuns8Iul7EWPsqb9xddt4zWkd0OXiuefWHFmaTIQ3Fshpy)IrHbOvu9ErrXImyvBpbXPbM8EjqlOeWimaTIQ3Z)XCCouVHIOckjaTf5gvJeVi1YUhCQeuq)1WWeUlioDOEdfrfus45LPLAKrprGEGkH6BlydjOG(RHHjCooqBrh5iy8V8z)IrHbOvu9ErrwApMac0vgSYanAmcfrbC4hdqRO69N0Xd1BOiQGscqBrUr1iXlsTS7bNkbf0FnmmHdXatEVeOfucyegGwr1757WXqC6G9lgfG2ICJQrIxKAz3dovIhme7xmkmaTIQ3lkkwKbRA7jooNFA1QTNe4fPws3T3lJQ3lrXieN2VyuyaAfvVxuKL2JH)J54mWK3lbAbLagHbOvu9E(cecq90aega59AjXRoce0O2EchI9lgfgGwr17ffzP9y4)xxUCLbRmqJgJqruah(5tRwT90jJArhmaTIQ3lDJgGmQEVefJN8P(hDqnGs9syKBQ47O)7yDI5FhX(fJcqBrUr1iXlsTS7bNkHbOSZUCSoTFXOWa0kQEVOilThJJC8rmWK3lXQga5YX6ehbeXxXRefLK)nKOilThJJ8Rli2VyuyaAfvVx8GZGvgOrJrOikGd)yaAzEfu6KoE4tRwT9KaVi1s6U9Ezu9EjkgH8PvR2EsyaAfvVx6gnazu9EjkgZGvgOrJrOikGd)yEtSl6egVmpjbAbLaMdyEshpuuSidw12tqaAbLacqBrsasI3eFyIXowdm59sGwqjGjGIS0EmquyjdlXodHy(g2qIEK6WBgSYanAmcfrbC4hfxHb9hjnU1Y6egVmpjbAbLaMdyEshp4aOzN7bkehugOrJqXvyq)rsJBTSK4QLcLe9iJ(gkwahhociuCfg0FK04wlljUAPqjHbOSZ8FmeCeqO4kmO)iPXTwwsC1sHsIIS0Em8FCgSYanAmcfrbC4hleAIDrNW4L5jjqlOeWCaZt64HIIfzWQ2EccqlOeqaAlscqs8M4ZjMyCaonWK3lbAbLagHbOvSlYrWu8RlxhXatEVeOfucycOilThdeNoziKhh5Eemv2dtuKIZlhNbM8EjqlOeWimaTIDr8FmhNtI5Bydj6rAqET44iMVHnKOhPncGLJJy(g2qIEK(3OfehaQNgGWGEEjkkbyjzevKbiOrT9eohN9lgfWvBHk8w9sTy60mj8ZB0s8P(hX3Ha)9VlionWK3lbAbLagHbOvSlIFm)7ioXmaG6PbiaU7rAHqJrqJA7jCxUGOgqPEjmYnv897FhR9lgfgGwr17ffzP9yCemIlioy)IrX5EWlcxswWi3uzrdqsdvq7GqIhmefwYWsSZUYGvgOrJrOikGd)erfJKOOCuWROt64bfwYWsSZzWkd0OXiuefWHFk9Jg0ZiJfnbH3t64b7xmkyQShM4bNbRmqJgJqruah(HrEYaA1lvFdDSObCshp40(fJcdqRO69IhmhNAaL6LWi3uX3V)DbXb7xmkmiVb0ms8GH4G9lgfmv2dt8GH4ShavWiVciCzSHIfilYs7XWpdH84i3JGHMp0zscWssdCxnWikYs7XeGJZX1dGkyKxbeUm2qXcKfzP9yoYrW8O)ZFGbYXXqipoY9iyO5dDMKaSK0a3vdmIhmhNdm0hn6aetdflqgvYvgSYanAmcfrbC4NEyAnkOrZjD8Gt7xmkmaTIQ3lEWCCQbuQxcJCtfF)(3fehSFXOWG8gqZiXdgId2VyuWuzpmXdgIZEaubJ8kGWLXgkwGSilThd)meYJJCpcgA(qNjjaljnWD1aJOilThtaoohxpaQGrEfq4YydflqwKL2J5ihbZJ(p)hhihhdH84i3JGHMp0zscWssdCxnWiEWCCoWqF0OdqmnuSazujxkd0OXiuefWHFo3dEr4sdCxnWCshpeBOybYIS0Em8J5VCCoTFXOaUAluH3QxQftNMjHFEJwIp1)i(d83)CC2VyuaxTfQWB1l1IPtZKWpVrlXN6FeFhc83)UGy)IrHbOvu9EXdgcdH84i3JGPYEyIIS0Em897)myLbA0yekIc4Wpga59AjJETOty8Y8KeOfucyoG5jD8qrXImyvBpbb0wKeGK4nXhM)cXatEVeOfucyegGwXUi(XyikSKHLyNH40(fJcMk7HjkYs7XWhM)54CW(fJcMk7HjEWUYGvgOrJrOikGd)8PvR2E6KrTOdm08HotsgAWBqJMt(u)Joy)IrbC1wOcVvVulMontc)8gTeFQ)r8h4V)DSQbuQxcJCtfeNmeYJJCpcMk7HjkYs7XeaM)5l2qXcKfzP9y44yiKhh5Eemv2dtuKL2JjGJ)ZFSHIfilYs7Xaj2qXcKfzP9y4dZJ)ZXz)IrbtL9WefzP9y4ZXDbHy(g2qIEK6WlhxSHIfilYs7XCKJGzG)5hZFZGvgOrJrOikGd)WqZh6mjbyjPbURgyoPJh(0QvBpjyO5dDMKm0G3GgnqudOuVeg5Mk()9FgSYanAmcfrbC4N4R4vIIsY)g6KoEGy(g2qIEK6WlefwYWsSZqSFXOaUAluH3QxQftNMjHFEJwIp1)i(d83)qCIJacfxHb9hjnU1YsIRwkusaA25EGYX5ad9rJoaXqSc5rfohNbM8EjqlOeWWxGUYGvgOrJrOikGd)yaAfvV)KoEW(fJc0qaSgjmvmcg0Or8GH40(fJcdqRO69IIIfzWQ2EIJtnGs9syKBQ4Zr)7kdwzGgngHIOao8JbOvu9(t64bg6JgDaIPHIfiJkb5tRwT9KGHMp0zsYqdEdA0aHHqECK7rWqZh6mjbyjPbURgyefzP9y4hkdxyP80ryu7DQgqPEjmYnvh53)UGy)IrHbOvu9ErrXImyvBpLbRmqJgJqruah(Xa0Y8kO0jD8ad9rJoaX0qXcKrLG8PvR2EsWqZh6mjzObVbnAGWqipoY9iyO5dDMKaSK0a3vdmIIS0Em8dLHlSuE6imQ9ovdOuVeg5MQJC8FxqSFXOWa0kQEV4bNbRmqJgJqruah(Xa0Y8kO0jD8G9lgfOHaynsMN0s(1MgnIhmhNdgGwXUiHclzyj2zooN2VyuWuzpmrrwApg()fI9lgfmv2dt8G54CA)IrrPF0GEgzSOji8kkYs7XWpugUWs5PJWO27unGs9syKBQoYX)DbX(fJIs)Ob9mYyrtq4v8GD5cYNwTA7jHbOvu9EPB0aKr17LOyeIbM8EjqlOeWimaTIQ3Z)XzWkd0OXiuefWHFgYT0cHMt64bNeZ3Wgs0JuhEHWqipoY9iyQShMOilThdF)(NJZjdRwqjZHaHuedRwqjjOTi()1fhhdRwqjZHJDbrHLmSe7CgSYanAmcfrbC4hSQpkTqO5KoEWjX8nSHe9i1HximeYJJCpcMk7HjkYs7XW3V)54CYWQfuYCiqifXWQfuscAlI)FDXXXWQfuYC4yxquyjdlXoNbRmqJgJqruah(j(8EPfcnN0XdojMVHnKOhPo8cHHqECK7rWuzpmrrwApg((9phNtgwTGsMdbcPigwTGssqBr8)RloogwTGsMdh7cIclzyj25myLbA0yekIc4WpU1QAujrrj5FdLbRmqJgJqruah(5tRwT90jJArhmaTIDrYEKgKxRt(u)JoyGjVxc0ckbmcdqRyxeFhDarpcvoTudGkELFQ)rhjW)Uci6rOYP9lgfgGwMxbLKKfmYnvw0aegGYoFem2vgSYanAmcfrbC4h3LcWEshpqmFdBiH)nAjhINaooI5Bydj0Hx5q8ea5tRwT9KOnsMN0pIJJy(g2qIEKgKxlio8PvR2EsyaAf7IK9iniVwCC2VyuWuzpmrrwApg(vgOrJWa0k2fjiEsShGKG2IG4WNwTA7jrBKmpPFee7xmkyQShMOilThd)epj2dqsqBrqSFXOGPYEyIhmhN9lgfL(rd6zKXIMGWR4bdXatEVeRAaeF)fyeooh(0QvBpjAJK5j9JGy)IrbtL9WefzP9y4J4jXEascAlkdwzGgngHIOao8JbOvSlkdwzGgngHIOao8t9gPYanAK(2aozul6qu9Ea26LbNbRmqJgJWgPGdL(rd6zKXIMGW7jD8G9lgfmv2dt8GZGvgOrJryJuqah(5tRwT90jJArhyvdge4bFYN6F0bhSFXOWw96WijkkvVxcW2duJCuWRiXdgId2VyuyREDyKefLQ3lby7bQrQfths8GZGvgOrJryJuqah(HPdJ8s7xmEYOw0bdqlpQWpPJhCA)IrHT61HrsuuQEVeGThOg5OGxrIIS0Em8HXIF54SFXOWw96WijkkvVxcW2duJulMoKOilThdFyS4xxqudOuVeg5Mk(o4O)H4KHqECK7rWuzpmrrwApg(CCooNmeYJJCpcYcg5MkPnAWffzP9y4ZXH4G9lgfN7bViCjzbJCtLfnajnubTdcjEWqyOpA0bioZB164YvgSYanAmcBKcc4WpgGwMxbLoPJhC4tRwT9KGvnyqGhmeNoDGHqECK7rWqZh6mjbyjPbURgyepyooh(0QvBpjyO5dDMKm0G3GgnCCoWqF0OdqmnuSazujxqCYqF0OdqmnuSazujooNmeYJJCpcMk7HjkYs7XWNJZX5KHqECK7rqwWi3ujTrdUOilThdFooehSFXO4Cp4fHljlyKBQSObiPHkODqiXdgcd9rJoaXzERwhxUC5IJZjdH84i3JGHMp0zscWssdCxnWiEWqyiKhh5Eemv2dtuKIZleg6JgDaIPHIfiJk5kdwzGgngHnsbbC4hfxHb9hjnU1Y6egVmpjbAbLaMdyEshp4aociuCfg0FK04wlljUAPqjbOzN7bkehugOrJqXvyq)rsJBTSK4QLcLe9iJ(gkwaeNoGJacfxHb9hjnU1YsILuVa0SZ9aLJdhbekUcd6psACRLLelPErrwApg((1fhhociuCfg0FK04wlljUAPqjHbOSZ8FmeCeqO4kmO)iPXTwwsC1sHsIIS0Em8FmeCeqO4kmO)iPXTwwsC1sHscqZo3d0myLbA0ye2ifeWHFmVj2fDcJxMNKaTGsaZbmpPJhkkwKbRA7jiaTGsabOTijajXBIpmXiquyjdlXodX5NwTA7jbRAWGapyooNQbuQxcJCtf)h)hId2VyuWuzpmXd2fhhdH84i3JGPYEyIIuCEDLbRmqJgJWgPGao8JfcnXUOty8Y8KeOfucyoG5jD8qrXImyvBpbbOfuciaTfjbijEt8H5XIFHOWsgwIDgIZpTA12tcw1GbbEWCCovdOuVeg5Mk(p(pehSFXOGPYEyIhSloogc5XrUhbtL9WefP486cId2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bNbRmqJgJWgPGao8JbqEVwYOxl6egVmpjbAbLaMdyEshpuuSidw12tqaAbLacqBrsasI3eFyIrcOilThdefwYWsSZqC(PvR2EsWQgmiWdMJtnGs9syKBQ4)4)CCmeYJJCpcMk7HjksX51vgSYanAmcBKcc4WpruXijkkhf8k6KoEqHLmSe7CgSYanAmcBKcc4WpXxXRefLK)n0jD8GtI5Bydj6rQdVCCeZ3WgsyqETK9iXKJJy(g2qc)B0s2JetxqC6ad9rJoaX0qXcKrL44CQgqPEjmYnv87O)cX5NwTA7jbRAWGapyoo1ak1lHrUPI)J)ZX9PvR2Es0gPIixqC(PvR2EsWqZh6mjXjdVddIdmeYJJCpcgA(qNjjaljnWD1aJ4bZX5WNwTA7jbdnFOZKeNm8omioWqipoY9iyQShM4b7YLlioziKhh5Eemv2dtuKL2JHVJ)ZXPgqPEjmYnv85O)HWqipoY9iyQShM4bdXjdH84i3JGSGrUPsAJgCrrwApg(vgOrJWa0k2fjiEsShGKG2I44CGH(OrhG4mVvRJloUydflqwKL2JHFm)7cItCeqO4kmO)iPXTwwsC1sHsIIS0Em8HXCCoWqF0OdqmeRqEuH7kdwzGgngHnsbbC4NZ9GxeU0a3vdmN0XdojMVHnKW)gTKdXtahhX8nSHegKxl5q8eWXrmFdBiHo8khINaoo7xmkSvVomsIIs17LaS9a1ihf8ksuKL2JHpmw8lhN9lgf2QxhgjrrP69sa2EGAKAX0HefzP9y4dJf)YXPgqPEjmYnv85O)HWqipoY9iyQShMOifNxxqCYqipoY9iyQShMOilThdFh)NJJHqECK7rWuzpmrrkoVU44InuSazrwApg(X8FgSYanAmcBKcc4WpmYtgqREP6BOJfnGt64bNQbuQxcJCtfFo6FioTFXO4Cp4fHljlyKBQSObiPHkODqiXdMJZbg6JgDaIZ8wToU44yOpA0biMgkwGmQehN9lgf2Eec3)maXdgI9lgf2Eec3)marrwApg(d8FaoXyhHHg8xdeWfXAdjvFdDSObiOrT9eUlxqC6ad9rJoaX0qXcKrL44yiKhh5Eem08HotsawsAG7QbgXdMJl2qXcKfzP9y4NHqECK7rWqZh6mjbyjPbURgyefzP9ycaJWXfBOybYIS0Emh5iyE0)5pW)b4eJDegAWFnqaxeRnKu9n0XIgGGg12t4UCLbRmqJgJWgPGao8tpmTgf0O5KoEWPAaL6LWi3uXNJ(hIt7xmko3dEr4sYcg5MklAasAOcAhes8G54CGH(OrhG4mVvRJloog6JgDaIPHIfiJkXXz)IrHThHW9pdq8GHy)IrHThHW9pdquKL2JH)J)hGtm2ryOb)1abCrS2qs13qhlAacAuBpH7YfeNoWqF0OdqmnuSazujoogc5XrUhbdnFOZKeGLKg4UAGr8G54(0QvBpjyO5dDMK4KH3Hbj2qXcKfzP9y4dZJ(Fab(paNySJWqd(Rbc4IyTHKQVHow0ae0O2Ec3fhxSHIfilYs7XWpdH84i3JGHMp0zscWssdCxnWikYs7XeagHJl2qXcKfzP9y4)4)b4eJDegAWFnqaxeRnKu9n0XIgGGg12t4UCLbRmqJgJWgPGao8ddnFOZKeGLKg4UAG5KoEW5NwTA7jbdnFOZKeNm8omiXgkwGSilThdFyE8Foo7xmkyQShM4b7cIt7xmkSvVomsIIs17LaS9a1ihf8ksyak7S8t9pIVJ)ZXz)IrHT61HrsuuQEVeGThOgPwmDiHbOSZYp1)i(o(VloUydflqwKL2JHFm)NbRmqJgJWgPGao8JbOL5vqPt64bg6JgDaIPHIfiJkbX5NwTA7jbdnFOZKeNm8omoogc5XrUhbtL9WefzP9y4hZ)UGOgqPEjmYnv897FimeYJJCpcgA(qNjjaljnWD1aJOilThd)y(pdwzGgngHnsbbC4NpTA12tNmQfDqnWyuqviXo5t9p6aX8nSHe9i9Vrlh5OpIYanAegGwXUibXtI9aKe0wuaoqmFdBirps)B0YrWihrzGgnc3LcWkiEsShGKG2Ic4ViWJyGjVxIvnakdwzGgngHnsbbC4hdqlZRGsN0Xdo7bqfmYRacxgBOybYIS0Em8JXCCoTFXOO0pAqpJmw0eeEffzP9y4hkdxyP80ryu7DQgqPEjmYnvh54)UGy)IrrPF0GEgzSOji8kEWUCXX5unGs9syKBQc4tRwT9KqnWyuqviXCe7xmkiMVHnK0G8AjkYs7XeaociIVIxjkkj)BibOzNnYIS0ECKaf)YhMb(NJtnGs9syKBQc4tRwT9KqnWyuqviXCe7xmkiMVHnK0)gTefzP9ycahbeXxXRefLK)nKa0SZgzrwAposGIF5dZa)7ccX8nSHe9i1HxioD6adH84i3JGPYEyIhmhhd9rJoaXzERwhioWqipoY9iilyKBQK2Obx8GDXXXqF0OdqmnuSazujxqC6ad9rJoaXhnaS8wCCoy)IrbtL9Wepyoo1ak1lHrUPIph9Vloo7xmkyQShMOilThdFhnehSFXOO0pAqpJmw0eeEfp4myLbA0ye2ifeWHFgYT0cHMt64bN2VyuqmFdBiP)nAjEWCCozy1ckzoeiKIyy1ckjbTfX)VU44yy1ckzoCSlikSKHLyNZGvgOrJryJuqah(bR6JsleAoPJhCA)IrbX8nSHK(3OL4bZX5KHvlOK5qGqkIHvlOKe0we))6IJJHvlOK5WXUGOWsgwIDodwzGgngHnsbbC4N4Z7Lwi0Cshp40(fJcI5Bydj9VrlXdMJZjdRwqjZHaHuedRwqjjOTi()1fhhdRwqjZHJDbrHLmSe7CgSYanAmcBKcc4WpU1QAujrrj5FdLbRmqJgJWgPGao8JbOvSl6KoEGy(g2qIEK(3OfhhX8nSHegKxl5q8eWXrmFdBiHo8khINaoo7xmkCRv1OsIIsY)gs8GHqmFdBirps)B0IJZP9lgfmv2dtuKL2JHFLbA0iCxkaRG4jXEascAlcI9lgfmv2dt8GDLbRmqJgJWgPGao8J7sbyZGvgOrJryJuqah(PEJuzGgnsFBaNmQfDiQEpaB9YGZGvgOrJrGxKAz3dovh(0QvBpDYOw0bJgjjajFgsAGjV)Kp1)OdoTFXOa0wKBuns8Iul7EWPsuKL2JHpOmCHLYZa(lWeItI5Bydj6rAJay54iMVHnKOhPb51IJJy(g2qc)B0soepbU44SFXOa0wKBuns8Iul7EWPsuKL2JHpLbA0imaTIDrcINe7bijOTOa(lWeItI5Bydj6r6FJwCCeZ3WgsyqETKdXtahhX8nSHe6WRCiEcC5IJZb7xmkaTf5gvJeVi1YUhCQep4myLbA0ye4fPw29Gtvah(Xa0Y8kO0jD8Gth(0QvBpjmAKKaK8ziPbM8EooN2Vyuu6hnONrglAccVIIS0Em8dLHlSuE6imQ9ovdOuVeg5MQJC8FxqSFXOO0pAqpJmw0eeEfpyxU44udOuVeg5Mk(C0)zWkd0OXiWlsTS7bNQao8JIRWG(JKg3AzDcJxMNKaTGsaZbmpPJhCahbekUcd6psACRLLexTuOKa0SZ9afIdkd0OrO4kmO)iPXTwwsC1sHsIEKrFdflaIthWraHIRWG(JKg3AzjXsQxaA25EGYXHJacfxHb9hjnU1YsILuVOilThdF)6IJdhbekUcd6psACRLLexTuOKWau2z(pgcociuCfg0FK04wlljUAPqjrrwApg(pgcociuCfg0FK04wlljUAPqjbOzN7bAgSYanAmc8Iul7EWPkGd)yHqtSl6egVmpjbAbLaMdyEshpuuSidw12tqaAbLacqBrsasI3eFygieNoTFXOGPYEyIIS0Em89leN2Vyuu6hnONrglAccVIIS0Em89lhNd2Vyuu6hnONrglAccVIhSloohSFXOGPYEyIhmhNAaL6LWi3uX)X)DbXPd2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bZXPgqPEjmYnv8F8FxquyjdlXo7kdwzGgngbErQLDp4ufWHFmVj2fDcJxMNKaTGsaZbmpPJhkkwKbRA7jiaTGsabOTijajXBIpmdeItN2VyuWuzpmrrwApg((fIt7xmkk9Jg0ZiJfnbHxrrwApg((LJZb7xmkk9Jg0ZiJfnbHxXd2fhNd2VyuWuzpmXdMJtnGs9syKBQ4)4)UG40b7xmko3dEr4sYcg5MklAasAOcAhes8G54udOuVeg5Mk(p(VlikSKHLyNDLbRmqJgJaVi1YUhCQc4Wpga59AjJETOty8Y8KeOfucyoG5jD8qrXImyvBpbbOfuciaTfjbijEt8HjgbItN2VyuWuzpmrrwApg((fIt7xmkk9Jg0ZiJfnbHxrrwApg((LJZb7xmkk9Jg0ZiJfnbHxXd2fhNd2VyuWuzpmXdMJtnGs9syKBQ4)4)UG40b7xmko3dEr4sYcg5MklAasAOcAhes8G54udOuVeg5Mk(p(VlikSKHLyNDLbRmqJgJaVi1YUhCQc4WpruXijkkhf8k6KoEqHLmSe7CgSYanAmc8Iul7EWPkGd)u6hnONrglAccVN0Xd2VyuWuzpmXdodwzGgngbErQLDp4ufWHFo3dEr4sdCxnWCshp40P9lgfeZ3WgsAqETefzP9y4dZ)CC2VyuqmFdBiP)nAjkYs7XWhM)DbHHqECK7rWuzpmrrwApg(o(Vloogc5XrUhbtL9WefP48MbRmqJgJaVi1YUhCQc4WpmYtgqREP6BOJfnGt64bN2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bZX5ad9rJoaXzERwhxCCm0hn6aetdflqgvIJ7tRwT9KOnsfrCC2Vyuy7riC)Zaepyi2Vyuy7riC)ZaefzP9y4pW)b4eJDegAWFnqaxeRnKu9n0XIgGGg12t4UG4G9lgfmv2dt8GH4ShavWiVciCzSHIfilYs7XWpdH84i3JGHMp0zscWssdCxnWikYs7XeGJZX1dGkyKxbeUm2qXcKfzP9y4pWa546bqfmYRacxgBOybYIS0Emh5iyE0)5pWa54yiKhh5Eem08HotsawsAG7QbgXdMJZbg6JgDaIPHIfiJk5kdwzGgngbErQLDp4ufWHF6HP1OGgnN0XdoTFXO4Cp4fHljlyKBQSObiPHkODqiXdMJZbg6JgDaIZ8wToU44yOpA0biMgkwGmQeh3NwTA7jrBKkI44SFXOW2Jq4(NbiEWqSFXOW2Jq4(NbikYs7XW)X)dWjg7im0G)AGaUiwBiP6BOJfnabnQTNWDbXb7xmkyQShM4bdXzpaQGrEfq4YydflqwKL2JHFgc5XrUhbdnFOZKeGLKg4UAGruKL2JjahNJRhavWiVciCzSHIfilYs7XW)XbYX1dGkyKxbeUm2qXcKfzP9yoYrW8O)Z)XbYXXqipoY9iyO5dDMKaSK0a3vdmIhmhNdm0hn6aetdflqgvYvgSYanAmc8Iul7EWPkGd)8PvR2E6KrTOdm08HotsgAWBqJMt(u)JoWqF0OdqmnuSazujioTFXOaUAluH3QxQftNMjHFEJwIp1)i(deJ)dXjdH84i3JGPYEyIIS0EmbG5F(6bqfmYRacxgBOybYIS0EmCCmeYJJCpcMk7HjkYs7XeWX)5VhavWiVciCzSHIfilYs7XaPhavWiVciCzSHIfilYs7XWhMh)NJZ(fJcMk7HjkYs7XWNJ7cI9lgfeZ3WgsAqETefzP9y4dZ)CC9aOcg5vaHlJnuSazrwApMJCemd8p)y(RRmyLbA0ye4fPw29Gtvah(5tRwT90jJArhm6hjJOsYuzpSt(u)Jo40bgc5XrUhbtL9WefP48YX5WNwTA7jbdnFOZKKHg8g0Obcd9rJoaX0qXcKrLCLbRmqJgJaVi1YUhCQc4Wpm08HotsawsAG7QbMt64HpTA12tcgA(qNjjdn4nOrde1ak1lHrUPIFm(FgSYanAmc8Iul7EWPkGd)eFfVsuus(3qN0XdeZ3Wgs0JuhEHOWsgwIDgItCeqO4kmO)iPXTwwsC1sHscqZo3duoohyOpA0bigIvipQWDb5tRwT9KWOFKmIkjtL9WYGvgOrJrGxKAz3dovbC4hdqlZRGsN0Xdm0hn6aetdflqgvcYNwTA7jbdnFOZKKHg8g0ObIAaL6LWi3uX3bm(pegc5XrUhbdnFOZKeGLKg4UAGruKL2JHFOmCHLYthHrT3PAaL6LWi3uDKJ)7kdwzGgngbErQLDp4ufWHFgYT0cHMt64bN2VyuqmFdBiP)nAjEWCCozy1ckzoeiKIyy1ckjbTfX)VU44yy1ckzoCSlikSKHLyNH8PvR2Esy0psgrLKPYEyzWkd0OXiWlsTS7bNQao8dw1hLwi0Cshp40(fJcI5Bydj9VrlXdgIdm0hn6aeN5TAD44CA)IrX5EWlcxswWi3uzrdqsdvq7GqIhmeg6JgDaIZ8wToU44CYWQfuYCiqifXWQfuscAlI)FDXXXWQfuYC4yoo7xmkyQShM4b7cIclzyj2ziFA1QTNeg9JKrujzQShwgSYanAmc8Iul7EWPkGd)eFEV0cHMt64bN2VyuqmFdBiP)nAjEWqCGH(OrhG4mVvRdhNt7xmko3dEr4sYcg5MklAasAOcAhes8GHWqF0OdqCM3Q1XfhNtgwTGsMdbcPigwTGssqBr8)RloogwTGsMdhZXz)IrbtL9WepyxquyjdlXod5tRwT9KWOFKmIkjtL9WYGvgOrJrGxKAz3dovbC4h3AvnQKOOK8VHYGvgOrJrGxKAz3dovbC4hdqRyx0jD8aX8nSHe9i9VrlooI5BydjmiVwYH4jGJJy(g2qcD4voepbCC2Vyu4wRQrLefLK)nK4bdX(fJcI5Bydj9VrlXdMJZP9lgfmv2dtuKL2JHFLbA0iCxkaRG4jXEascAlcI9lgfmv2dt8GDLbRmqJgJaVi1YUhCQc4WpUlfGndwzGgngbErQLDp4ufWHFQ3ivgOrJ03gWjJArhIQ3dWwVm4myLbA0yer17byR3bdqlZRGsN0XdouVHIOckjSvVomsIIs17LaS9a1iOG(RHHj8myLbA0yer17byRxah(X8Myx0jmEzEsc0ckbmhW8KoEahbewi0e7IefzP9y4RilThtgSYanAmIO69aS1lGd)yHqtSlkdodwzGgngbCrWkGHvAahSqOj2fDcJxMNKaTGsaZbmpPJhkkwKbRA7jiaTGsabOTijajXBIpmdeIt7xmkyQShMOilThdF)YX5G9lgfmv2dt8G54udOuVeg5Mk(p(VlikSKHLyNZGvgOrJraxeScyyLgqah(X8Myx0jmEzEsc0ckbmhW8KoEOOyrgSQTNGa0ckbeG2IKaKeVj(WmqioTFXOGPYEyIIS0Em89lhNd2VyuWuzpmXdMJtnGs9syKBQ4)4)UGOWsgwIDodwzGgngbCrWkGHvAabC4hdG8ETKrVw0jmEzEsc0ckbmhW8KoEOOyrgSQTNGa0ckbeG2IKaKeVj(WmqioTFXOGPYEyIIS0Em89lhNd2VyuWuzpmXdMJtnGs9syKBQ4)4)UGOWsgwIDodwzGgngbCrWkGHvAabC4NiQyKefLJcEfDshpOWsgwIDodwzGgngbCrWkGHvAabC4hg5jdOvVu9n0XIgWjD8Gt1ak1lHrUPIph9phN9lgf2Eec3)maXdgI9lgf2Eec3)marrwApg(deJ4cId2VyuWuzpmXdodwzGgngbCrWkGHvAabC4NEyAnkOrZjD8Gt1ak1lHrUPIph9phN9lgf2Eec3)maXdgI9lgf2Eec3)marrwApg(pgJ4cId2VyuWuzpmXdodwzGgngbCrWkGHvAabC4NpTA12tNmQfDWOFKmIkjtL9Wo5t9p6GdmeYJJCpcMk7HjksX5ndwzGgngbCrWkGHvAabC4N4R4vIIsY)g6KoEGy(g2qIEK6WlefwYWsSZq(0QvBpjm6hjJOsYuzpSmyLbA0yeWfbRagwPbeWHFy6WiV0(fJNmQfDWa0YJk8t64b7xmkmaT8OcxuKL2JHFmceN2VyuqmFdBiPb51s8G54SFXOGy(g2qs)B0s8GDbrnGs9syKBQ4Zr)NbRmqJgJaUiyfWWknGao8JbOL5vqPt64bNoObHQgqcdOi9CpqLgGwgrPZzoo7xmkyQShMOilThd)epj2dqsqBrCCoax0NWa0Y8kOKlioTFXOGPYEyIhmhNAaL6LWi3uXNJ(hcX8nSHe9i1HxxzWkd0OXiGlcwbmSsdiGd)yaAzEfu6KoEWPdAqOQbKWaksp3duPbOLru6CMJZ(fJcMk7HjkYs7XWpXtI9aKe0wehNdFA1QTNeWf9jnaTmVck5ccq90aegGwEuHlOrT9eoeN2VyuyaA5rfU4bZXPgqPEjmYnv85O)DbX(fJcdqlpQWfgGYoZ)XqCA)IrbX8nSHKgKxlXdMJZ(fJcI5Bydj9VrlXd2fegc5XrUhbtL9WefzP9y4ZXZGvgOrJraxeScyyLgqah(Xa0Y8kO0jD8Gth0GqvdiHbuKEUhOsdqlJO05mhN9lgfmv2dtuKL2JHFINe7bijOTioohGl6tyaAzEfuYfe7xmkiMVHnK0G8AjkYs7XWNJdHy(g2qIEKgKxlioaupnaHbOLhv4cAuBpHdHHqECK7rWuzpmrrwApg(C8myLbA0yeWfbRagwPbeWHFgYT0cHMt64bN2VyuqmFdBiP)nAjEWCCozy1ckzoeiKIyy1ckjbTfX)VU44yy1ckzoCSlikSKHLyNH8PvR2Esy0psgrLKPYEyzWkd0OXiGlcwbmSsdiGd)Gv9rPfcnN0XdoTFXOGy(g2qs)B0s8G54CYWQfuYCiqifXWQfuscAlI)FDXXXWQfuYC4yoo7xmkyQShM4b7cIclzyj2ziFA1QTNeg9JKrujzQShwgSYanAmc4IGvadR0ac4WpXN3lTqO5KoEWP9lgfeZ3Wgs6FJwIhmhNtgwTGsMdbcPigwTGssqBr8)RloogwTGsMdhZXz)IrbtL9WepyxquyjdlXod5tRwT9KWOFKmIkjtL9WYGvgOrJraxeScyyLgqah(XTwvJkjkkj)BOmyLbA0yeWfbRagwPbeWHFmaTIDrN0Xdo1GqvdiHbuKEUhOsdqlJO05me7xmkyQShMOilThdFepj2dqsqBrqGl6t4UuawxCCoDqdcvnGegqr65EGknaTmIsNZCC2VyuWuzpmrrwApg(jEsShGKG2I44CaUOpHbOvSlYfeNeZ3Wgs0J0)gT44iMVHnKWG8AjhINaooI5Bydj0Hx5q8eWXz)IrHBTQgvsuus(3qIhme7xmkiMVHnK0)gTepyooN2VyuWuzpmrrwApg(vgOrJWDPaScINe7bijOTii2VyuWuzpmXd2LlooNAqOQbKaxDp9avAEJO05mFbcX(fJcI5BydjniVwIIS0Em89lehSFXOaxDp9avAEJOilThdFkd0Or4UuawbXtI9aKe0wKRmyLbA0yeWfbRagwPbeWHFCxkaBgSYanAmc4IGvadR0ac4Wp1BKkd0Or6Bd4KrTOdr17byRxgCgSYanAmcd4GIRWG(JKg3AzDcJxMNKaTGsaZbmpPJhCahbekUcd6psACRLLexTuOKa0SZ9afIdkd0OrO4kmO)iPXTwwsC1sHsIEKrFdflaIthWraHIRWG(JKg3AzjXsQxaA25EGYXHJacfxHb9hjnU1YsILuVOilThdF)6IJdhbekUcd6psACRLLexTuOKWau2z(pgcociuCfg0FK04wlljUAPqjrrwApg(pgcociuCfg0FK04wlljUAPqjbOzN7bAgSYanAmcdiGd)yHqtSl6egVmpjbAbLaMdyEshpuuSidw12tqaAbLacqBrsasI3eFyg4jD8Gt7xmkyQShMOilThdF)cXP9lgfL(rd6zKXIMGWROilThdF)YX5G9lgfL(rd6zKXIMGWR4b7IJZb7xmkyQShM4bZXPgqPEjmYnv8F8FxqC6G9lgfN7bViCjzbJCtLfnajnubTdcjEWCCQbuQxcJCtf)h)3fefwYWsSZzWkd0OXimGao8J5nXUOty8Y8KeOfucyoG5jD8qrXImyvBpbbOfuciaTfjbijEt8HzGqCA)IrbtL9WefzP9y47xioTFXOO0pAqpJmw0eeEffzP9y47xoohSFXOO0pAqpJmw0eeEfpyxCCoy)IrbtL9Wepyoo1ak1lHrUPI)J)7cIthSFXO4Cp4fHljlyKBQSObiPHkODqiXdMJtnGs9syKBQ4)4)UGOWsgwIDodwzGgngHbeWHFmaY71sg9ArNW4L5jjqlOeWCaZt64HIIfzWQ2EccqlOeqaAlscqs8M4dtmceN2VyuWuzpmrrwApg((fIt7xmkk9Jg0ZiJfnbHxrrwApg((LJZb7xmkk9Jg0ZiJfnbHxXd2fhNd2VyuWuzpmXdMJtnGs9syKBQ4)4)UG40b7xmko3dEr4sYcg5MklAasAOcAhes8G54udOuVeg5Mk(p(VlikSKHLyNZGvgOrJryabC4NiQyKefLJcEfDshpOWsgwIDodwzGgngHbeWHFk9Jg0ZiJfnbH3t64b7xmkyQShM4bNbRmqJgJWac4WpN7bViCPbURgyoPJhC60(fJcI5BydjniVwIIS0Em8H5Foo7xmkiMVHnK0)gTefzP9y4dZ)UGWqipoY9iyQShMOilThdFh)hIt7xmkGR2cv4T6LAX0Pzs4N3OL4t9pI)aX4)CCouVHIOckjGR2cv4T6LAX0Pzs4N3OLGc6VggMWD5IJZ(fJc4QTqfEREPwmDAMe(5nAj(u)J47qGo(Foogc5XrUhbtL9WefP48cXPAaL6LWi3uXNJ(NJ7tRwT9KOnsfrUYGvgOrJryabC4hg5jdOvVu9n0XIgWjD8Gt1ak1lHrUPIph9peN2VyuCUh8IWLKfmYnvw0aK0qf0oiK4bZX5ad9rJoaXzERwhxCCm0hn6aetdflqgvIJ7tRwT9KOnsfrCC2Vyuy7riC)Zaepyi2Vyuy7riC)ZaefzP9y4pW)b40PJ6i1BOiQGsc4QTqfEREPwmDAMe(5nAjOG(RHHjCxb4eJDegAWFnqaxeRnKu9n0XIgGGg12t4UC5cId2VyuWuzpmXdgIZydflqwKL2JHFgc5XrUhbdnFOZKeGLKg4UAGruKL2JjahNJl2qXcKfzP9y4pWadWPJ6ioTFXOaUAluH3QxQftNMjHFEJwIp1)i(W8)FxU44InuSazrwApMJCemp6)8hyGCCmeYJJCpcgA(qNjjaljnWD1aJ4bZX5ad9rJoaX0qXcKrLCLbRmqJgJWac4Wp9W0AuqJMt64bNQbuQxcJCtfFo6FioTFXO4Cp4fHljlyKBQSObiPHkODqiXdMJZbg6JgDaIZ8wToU44yOpA0biMgkwGmQeh3NwTA7jrBKkI44SFXOW2Jq4(NbiEWqSFXOW2Jq4(NbikYs7XW)X)dWPth1rQ3qrubLeWvBHk8w9sTy60mj8ZB0sqb9xddt4UcWjg7im0G)AGaUiwBiP6BOJfnabnQTNWD5YfehSFXOGPYEyIhmeNXgkwGSilThd)meYJJCpcgA(qNjjaljnWD1aJOilThtaoohxSHIfilYs7XW)XbgGth1rCA)IrbC1wOcVvVulMontc)8gTeFQ)r8H5))UCXXfBOybYIS0Emh5iyE0)5)4a54yiKhh5Eem08HotsawsAG7QbgXdMJZbg6JgDaIPHIfiJk5kdwzGgngHbeWHF(0QvBpDYOw0bgA(qNjjdn4nOrZjFQ)rhyOpA0biMgkwGmQeeN2VyuaxTfQWB1l1IPtZKWpVrlXN6Fe)bIX)H4KHqECK7rWuzpmrrwApMaW8pFXgkwGSilThdhhdH84i3JGPYEyIIS0EmbC8F(JnuSazrwApgiXgkwGSilThdFyE8Foo7xmkyQShMOilThdFoUli2VyuqmFdBiPb51suKL2JHpm)ZXfBOybYIS0Emh5iyg4F(X8xxzWkd0OXimGao8ZNwTA7Ptg1Ioy0psgrLKPYEyN8P(hDWPdmeYJJCpcMk7HjksX5LJZHpTA12tcgA(qNjjdn4nOrdeg6JgDaIPHIfiJk5kdwzGgngHbeWHFyO5dDMKaSK0a3vdmN0XdFA1QTNem08HotsgAWBqJgiQbuQxcJCtf)h)pdwzGgngHbeWHFIVIxjkkj)BOt64bI5Bydj6rQdVquyjdlXodX(fJc4QTqfEREPwmDAMe(5nAj(u)J4pqm(peN4iGqXvyq)rsJBTSK4QLcLeGMDUhOCCoWqF0OdqmeRqEuH7cYNwTA7jHr)izevsMk7HLbRmqJgJWac4WpgGwr17pPJhSFXOaneaRrctfJGbnAepyi2VyuyaAfvVxuuSidw12tzWkd0OXimGao8dthg5L2Vy8KrTOdgGwEuHFshpy)IrHbOLhv4IIS0Em8)leN2VyuqmFdBiPb51suKL2JHVF54SFXOGy(g2qs)B0suKL2JHVFDbrnGs9syKBQ4Zr)NbRmqJgJWac4WpgGwMxbLoPJhyOpA0biMgkwGmQeKpTA12tcgA(qNjjdn4nOrdegc5XrUhbdnFOZKeGLKg4UAGruKL2JHFOmCHLYthHrT3PAaL6LWi3uDKJ)7kdwzGgngHbeWHFmaTIQ3FshpaupnaHbqEVws8QJabnQTNWH4aq90aegGwEuHlOrT9eoe7xmkmaTIQ3lkkwKbRA7jioTFXOGy(g2qs)B0suKL2JHpmceI5Bydj6r6FJwqSFXOaUAluH3QxQftNMjHFEJwIp1)i(d83)CC2VyuaxTfQWB1l1IPtZKWpVrlXN6FeFhc83)qudOuVeg5Mk(C0)CC4iGqXvyq)rsJBTSK4QLcLefzP9y47O54ugOrJqXvyq)rsJBTSK4QLcLe9iJ(gkwGlioWqipoY9iyQShMOifN3myLbA0yegqah(Xa0Y8kO0jD8G9lgfOHaynsMN0s(1MgnIhmhN9lgfN7bViCjzbJCtLfnajnubTdcjEWCC2VyuWuzpmXdgIt7xmkk9Jg0ZiJfnbHxrrwApg(HYWfwkpDeg1ENQbuQxcJCt1ro(Vli2Vyuu6hnONrglAccVIhmhNd2Vyuu6hnONrglAccVIhmehyiKhh5EeL(rd6zKXIMGWROifNxoohyOpA0bi(ObGL3YfhNAaL6LWi3uXNJ(hcX8nSHe9i1H3myLbA0yegqah(Xa0Y8kO0jD8aq90aegGwEuHlOrT9eoeN2VyuyaA5rfU4bZXPgqPEjmYnv85O)DbX(fJcdqlpQWfgGYoZ)XqCA)IrbX8nSHKgKxlXdMJZ(fJcI5Bydj9VrlXd2fe7xmkGR2cv4T6LAX0Pzs4N3OL4t9pI)aD8)qCYqipoY9iyQShMOilThdFy(NJZHpTA12tcgA(qNjjdn4nOrdeg6JgDaIPHIfiJk5kdwzGgngHbeWHFmaTmVckDshp40(fJc4QTqfEREPwmDAMe(5nAj(u)J4pqh)phN9lgfWvBHk8w9sTy60mj8ZB0s8P(hXFG)(hcq90aega59AjXRoce0O2Ec3fe7xmkiMVHnK0G8AjkYs7XWNJdHy(g2qIEKgKxlioy)IrbAiawJeMkgbdA0iEWqCaOEAacdqlpQWf0O2EchcdH84i3JGPYEyIIS0Em854qCYqipoY9io3dEr4sdCxnWikYs7XWNJZX5ad9rJoaXzERwhxzWkd0OXimGao8ZqULwi0Cshp40(fJcI5Bydj9VrlXdMJZjdRwqjZHaHuedRwqjjOTi()1fhhdRwqjZHJDbrHLmSe7mKpTA12tcJ(rYiQKmv2dldwzGgngHbeWHFWQ(O0cHMt64bN2VyuqmFdBiP)nAjEWqCGH(OrhG4mVvRdhNt7xmko3dEr4sYcg5MklAasAOcAhes8GHWqF0OdqCM3Q1XfhNtgwTGsMdbcPigwTGssqBr8)RloogwTGsMdhZXz)IrbtL9WepyxquyjdlXod5tRwT9KWOFKmIkjtL9WYGvgOrJryabC4N4Z7Lwi0Cshp40(fJcI5Bydj9VrlXdgIdm0hn6aeN5TAD44CA)IrX5EWlcxswWi3uzrdqsdvq7GqIhmeg6JgDaIZ8wToU44CYWQfuYCiqifXWQfuscAlI)FDXXXWQfuYC4yoo7xmkyQShM4b7cIclzyj2ziFA1QTNeg9JKrujzQShwgSYanAmcdiGd)4wRQrLefLK)nugSYanAmcdiGd)yaAf7IoPJhiMVHnKOhP)nAXXrmFdBiHb51soepbCCeZ3WgsOdVYH4jGJZ(fJc3AvnQKOOK8VHepyi2VyuqmFdBiP)nAjEWCCoTFXOGPYEyIIS0Em8RmqJgH7sbyfepj2dqsqBrqSFXOGPYEyIhSRmyLbA0yegqah(XDPaSzWkd0OXimGao8t9gPYanAK(2aozul6qu9Ea26DdnWe7EkM)d8cUG7fa]] )


end