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
            end,
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

        -- May want to revisit this and split out swipe_cat from swipe_bear.
        swipe_bear = {
            known = 213764,
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
        },


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


    spec:RegisterPack( "Balance", 20201012, [[dGKF3cqib0JubqxIkrBccFsfOYOiQofrzvQi1ReGzPIQBbrODr4xQGgMQIJPQ0YeiptvLMgerxdIY2ub03GOY4ubY5OsO1brW8Os6EQq7dQQdQcu1cHi9qiQAIQaeCrvac9rvakNufaSsbQzsLGDQI4NQaenuvaOLQcq1tf0uvvXxvbiTxv6VKAWkomLftfpgXKrYLrTzH(mKmAi1PL8AvvnBQ62ez3s9BqdhkhxfOSCLEojth46QY2HkFNk14vr58qvwVksMpsTFrF)E)5gsza(EsqFc6Z3pFdse03ph0xx8gcWdJVHyg5VHIVHTjX3qKAERj8neZWZdnQ7p3qf8Te(gIgaWuiHdpevbq)CeeO0HQs65nqbBYArWHQsIC4n05vEWbG(6CdPmaFpjOpb957NVbjc67Nd67bDdThanCVHHLeYFdrxuuCFDUHuSICdpaZbPM3AcNZbe2xrLbFaMZbKea0H3C(g055e0NG(KbNbFaMdYJ2AuScjKbFaMdsmNdEkkMkNqO32CqkBsIm4dWCqI5G8OTgftLdWwumqxXCiMIv5aG5qWJ4znWwumqjUH(sbu3FUHyltGsog4(Z9KV3FUHgbuW(gkbH9)Q1r4kDd52C8m1fPxW9KGU)CdncOG9n09Aa03qUnhptDr6fCp537p3qJakyFdDVga9nKBZXZuxKEb3tqY7p3qUnhptDr6nKSfG3YUHkm271aBrXaLqbSnAEFoUMdsEdncOG9nubSv9wu8fCpbz3FUHCBoEM6I0Bie7gQyWn0iGc23qC2wMJNVH4m)JVHoqLkhe5e9q4MJ8CKNtSqHgOxwYQwLdsmNG(KJSComNVb9jhz5GForpeU5iph55eluOb6LLSQv5GeZjiKLdsmh5589toNohG55giQMyBBGc2cUnhptLJSCqI5iphKmNtNdb2uVciWwMukwB(cvlXnqWT54zQCKLJSComNVh0NCKDdXzRUnj(gsGno4FwtXk8AYfCb3qkoApp4(Z9KV3FUHgbuW(gQGEB1oSjDd52C8m1fPxW9KGU)Cd52C8m1fP3qi2nuXGBOrafSVH4STmhpFdXz(hFdvyS3Rb2IIbkHcyB08(CWpNV3qC2QBtIVHLsBq(cUN879NBi3MJNPUi9gs2cWBz3q55eyoeioUTgi6cfAGoACo005eyoei0tbD3ccSXb)ZAaAwRWQTakXdlhz5GihNxmkiMUAI4HDdncOG9n0HxfV)Rg1fCpbjV)Cd52C8m1fP3qYwaEl7g68IrbX0vtepSBOrafSVHyqqb7l4EcYU)CdncOG9n8PyDbyj1nKBZXZuxKEb3toW7p3qUnhptDr6nKSfG3YUH4STmhplkL2G8nub2IaUN89gAeqb7B4(ATrafS1(sbUH(sb0TjX3qdYxW9eK7(ZnKBZXZuxKEdjBb4TSB4(AocxuSausSB42AQLnjNQP4vWhSxHHXu3qfylc4EY3BOrafSVH7R1gbuWw7lf4g6lfq3MeFdPw2KCQMI3l4EYbD)5gYT54zQlsVHKTa8w2nCFnhHlkw4yERjSgg1M3RbORgLsWhSxHHXu3qfylc4EY3BOrafSVH7R1gbuWw7lf4g6lfq3MeFdDGg4cUN4I3FUHCBoEM6I0BOrafSVH7R1gbuWw7lf4g6lfq3MeFdvGl4cUHoqdC)5EY37p3qUnhptDr6nKSfG3YUHoVyuqmD1eXd7gAeqb7B4A44g(u64Y9PW7cUNe09NBi3MJNPUi9gcXUHkgCdncOG9neNTL545BioZ)4ByG548IrHJ5TMWAyuBEVgGUAukDBG3YIhwoiYjWCCEXOWX8wtynmQnVxdqxnkL2wI1S4HDdXzRUnj(gs2c0qWd7cUN879NBi3MJNPUi9gs2cWBz3qNxmkuaB9WLsSSKvTkhxZ5lYYbroYZX5fJchZBnH1WO28EnaD1Ou62aVLfllzvRYb)CqsbYYHMohNxmkCmV1ewdJAZ71a0vJsPTLynlwwYQwLd(5GKcKLJSCqKJPaR51yq38Md(hZ5a)KdICKNdbc9uq3TGy6QjILLSQv5GFoixo005iphce6PGUBblHbDZR2b2uILLSQv5GFoixoiYjWCCEXO4F1ultPzjmOBEL4gO5Mxu1PyXdlhe5qG442AG4pEBzDoYYr2n0iGc23qI1e2RDEX4n05fJ62K4BOcyRhUuxW9eK8(ZnKBZXZuxKEdjBb4TSByG5GZ2YC8SGSfOHGhwoiYrEoYZjWCiqONc6UfeyJd(N1a0SwHvBbuIhwo005eyo4STmhpliWgh8pRjWMQafSZHMoNaZHaXXT1arxOqd0rJZrwoiYrEoeioUTgi6cfAGoACo005iphce6PGUBbX0vtellzvRYb)CqUCOPZrEoei0tbD3cwcd6MxTdSPellzvRYb)CqUCqKtG548IrX)QPwMsZsyq38kXnqZnVOQtXIhwoiYHaXXT1aXF82Y6CKLJSCKLJSCOPZrEoei0tbD3ccSXb)ZAaAwRWQTakXdlhe5qGqpf0DliMUAIyzJcVCqKdbIJBRbIUqHgOJgNJSBOrafSVHkGTQ3IIVG7ji7(ZnKBZXZuxKEdncOG9nu96yT8nKSfG3YUHlhxwH2C8CoiYbylkgiaLeRbqnvX5GFoFpWCqKJHPjOzY)CqKJ8CWzBzoEwq2c0qWdlhA6CKNJPaR51yq38MJR587NCqKtG548IrbX0vtepSCKLdnDoei0tbD3cIPRMiw2OWlhz3qcEepRb2IIbQ7jFVG7jh49NBi3MJNPUi9gAeqb7BOee2XA5BizlaVLDdxoUScT545CqKdWwumqakjwdGAQIZb)C((Raz5GihdttqZK)5Gih55GZ2YC8SGSfOHGhwo005iphtbwZRXGU5nhxZ53p5GiNaZX5fJcIPRMiEy5ilhA6CiqONc6UfetxnrSSrHxoYYbrobMJZlgf)RMAzknlHbDZRe3an38IQoflEy3qcEepRb2IIbQ7jFVG7ji39NBi3MJNPUi9gAeqb7BOcWEVT6O3w(gs2cWBz3WLJlRqBoEohe5aSffdeGsI1aOMQ4CWpNVhyobKZYsw1QCqKJHPjOzY)CqKJ8CWzBzoEwq2c0qWdlhA6CmfynVgd6M3CCnNF)KdnDoei0tbD3cIPRMiw2OWlhz3qcEepRb2IIbQ7jFVG7jh09NBi3MJNPUi9gs2cWBz3qdttqZK)3qJakyFdJWLWAyu3g4T8fCpXfV)Cd52C8m1fP3qYwaEl7gkphM4lmflQwBnE5qtNdt8fMIfkO3wD16V5qtNdt8fMIf(xBRUA93CKLdICKNtG5qG442AGOluOb6OX5qtNJ8CmfynVgd6M3CCnhxez5Gih55GZ2YC8SGSfOHGhwo005ykWAEng0nV54Ao)(jhA6CWzBzoEwukTb5CKLdICKNdoBlZXZccSXb)ZAkwHxtYbrobMdbc9uq3TGaBCW)SgGM1kSAlGs8WYHMoNaZbNTL54zbb24G)znfRWRj5GiNaZHaHEkO7wqmD1eXdlhz5ilhz5Gih55qGqpf0DliMUAIyzjRAvo4NZVFYHMohtbwZRXGU5nh8ZXf)KdICiqONc6Ufetxnr8WYbroYZHaHEkO7wWsyq38QDGnLyzjRAvoUMJrafSfkGTXAzbFgtEawdkjohA6Ccmhceh3wde)XBlRZrwo005eluOb6LLSQv54AoF)KJSCqKJ8COGaHrzyGchRvUTvstzsgkwSSKvTkh8ZbjZHMoNaZHaXXT1arZKf6HlvoYUHgbuW(ggFlEAyuZ(xZxW9KVFU)Cd52C8m1fP3qYwaEl7gkphM4lmfl8V2wDZNbYHMohM4lmfluqVT6MpdKdnDomXxykwynE6MpdKdnDooVyu4yERjSgg1M3RbORgLs3g4TSyzjRAvo4Ndskqwo00548IrHJ5TMWAyuBEVgGUAukTTeRzXYsw1QCWphKuGSCOPZXuG18AmOBEZb)CCXp5Gihce6PGUBbX0vtelBu4LJSCqKJ8CiqONc6UfetxnrSSKvTkh8Z53p5qtNdbc9uq3TGy6QjILnk8Yrwo005eluOb6LLSQv54AoF)CdncOG9n8F1ultPvy1wa1fCp5737p3qUnhptDr6nKSfG3YUHYZXuG18AmOBEZb)CCXp5Gih5548IrX)QPwMsZsyq38kXnqZnVOQtXIhwo005eyoeioUTgi(J3wwNJSCOPZHaXXT1arxOqd0rJZHMohNxmkC8qiL)PaIhwoiYX5fJchpes5FkGyzjRAvoUMtqFYjGCKNdsMZPZHaBQxbeyltkfRnFHQL4gi42C8mvoYYrwoiYrEobMdbIJBRbIUqHgOJgNdnDoei0tbD3ccSXb)ZAaAwRWQTakXdlhA6CIfk0a9Ysw1QCCnhce6PGUBbb24G)znanRvy1waLyzjRAvobKZbMdnDoXcfAGEzjRAvoUmNVh0NCCnNG(Kta5iphKmNtNdb2uVciWwMukwB(cvlXnqWT54zQCKLJSBOrafSVHe2ZkqzET5luTe3Gl4EY3GU)Cd52C8m1fP3qYwaEl7gkphtbwZRXGU5nh8ZXf)KdICKNJZlgf)RMAzknlHbDZRe3an38IQoflEy5qtNtG5qG442AG4pEBzDoYYHMohceh3wdeDHcnqhnohA6CCEXOWXdHu(NciEy5GihNxmkC8qiL)PaILLSQv54Ao)(jNaYrEoizoNohcSPEfqGTmPuS28fQwIBGGBZXZu5ilhz5Gih55eyoeioUTgi6cfAGoACo005qGqpf0DliWgh8pRbOzTcR2cOepSCOPZbNTL54zbb24G)znfRWRj5GiNyHcnqVSKvTkh8Z57b9jNaYjOp5eqoYZbjZ505qGn1RacSLjLI1MVq1sCdeCBoEMkhz5qtNtSqHgOxwYQwLJR5qGqpf0DliWgh8pRbOzTcR2cOellzvRYjGCoWCOPZjwOqd0llzvRYX1C(9tobKJ8CqYCoDoeyt9kGaBzsPyT5luTe3ab3MJNPYrwoYUHgbuW(gwnX22afSVG7jF)9(ZnKBZXZuxKEdjBb4TSBO8CWzBzoEwqGno4FwtXk8AsoiYjwOqd0llzvRYb)C((7NCOPZX5fJcIPRMiEy5ilhe5iphNxmkCmV1ewdJAZ71a0vJsPBd8wwOag5VgN5FCo4NZVFYHMohNxmkCmV1ewdJAZ71a0vJsPTLynluaJ8xJZ8poh8Z53p5ilhA6CIfk0a9Ysw1QCCnNVFUHgbuW(gsGno4FwdqZAfwTfqDb3t(IK3FUHCBoEM6I0BizlaVLDdVHgbuW(gAuggOWXALBBLUG7jFr29NBi3MJNPUi9gs2cWBz3qceh3wdeDHcnqhnohe5iphC2wMJNfeyJd(N1uScVMKdnDoei0tbD3cIPRMiwwYQwLJR589toYYbroMcSMxJbDZBo4NdY(KdICiqONc6UfeyJd(N1a0SwHvBbuILLSQv54AoF)CdncOG9nubSv9wu8fCp57bE)5gYT54zQlsVHqSBOIb3qJakyFdXzBzoE(gIZ8p(gYeFHPyr1A)RTnNtNZbLZH5yeqbBHcyBSwwWNXKhG1GsIZjGCcmhM4lmflQw7FTT5C6CoWComhJakylCVgaTGpJjpaRbLeNta58reuohMJcJ9EnAtb4BioB1TjX3qtHDaK3qMCb3t(IC3FUHCBoEM6I0BizlaVLDdLNJ8CIfk0a9Ysw1QCCnhKmhA6CKNJZlgfRHJB4tPJl3NcpXYsw1QCCnhuekHKDwoNohcx(CKNJPaR51yq38MZH587NCKLdICCEXOynCCdFkDC5(u4jEy5ilhz5qtNJ8CmfynVgd6M3CcihC2wMJNfMc7aiVHmjNtNJZlgfmXxykwRGEBfllzvRYjGCOGar8T4PHrn7Fnlaf5VsVSKvDoNoNGeilh8Z5BqFYHMohtbwZRXGU5nNaYbNTL54zHPWoaYBitY50548Irbt8fMI1(xBRyzjRAvobKdfeiIVfpnmQz)RzbOi)v6LLSQZ505eKaz5GFoFd6toYYbromXxykwuT2A8YbroYZrEobMdbc9uq3TGy6QjIhwo005qG442AG4pEBzDoiYjWCiqONc6UfSeg0nVAhytjEy5ilhA6CiqCCBnq0fk0aD04CKLdnDooVyuqmD1eXYsw1QCWpNdkhe5eyooVyuSgoUHpLoUCFk8epSCKDdncOG9nubSv9wu8fCp57bD)5gYT54zQlsVHKTa8w2nuEooVyuWeFHPyT)12kEy5qtNJ8CiOTffRY5yobLdICwMG2wuSgusCoUMdYYrwo005qqBlkwLZXC(nhz5GihdttqZK)3qJakyFdB2Twcc7l4EYxx8(ZnKBZXZuxKEdjBb4TSBO8CCEXOGj(ctXA)RTv8WYHMoh55qqBlkwLZXCckhe5SmbTTOynOK4CCnhKLJSCOPZHG2wuSkNJ58BoYYbrogMMGMj)VHgbuW(gI28rTee2xW9KG(C)5gYT54zQlsVHKTa8w2nuEooVyuWeFHPyT)12kEy5qtNJ8CiOTffRY5yobLdICwMG2wuSgusCoUMdYYrwo005qqBlkwLZXC(nhz5GihdttqZK)3qJakyFdJpVxlbH9fCpjOV3FUHgbuW(g622TGRgg1S)18nKBZXZuxKEb3tckO7p3qUnhptDr6nKSfG3YUHmXxykwuT2)ABZHMohM4lmfluqVT6MpdKdnDomXxykwynE6MpdKdnDooVyu422TGRgg1S)1S4HLdICyIVWuSOAT)12MdnDoYZX5fJcIPRMiwwYQwLJR5yeqbBH71aOf8zm5bynOK4CqKJZlgfetxnr8WYr2n0iGc23qfW2yT8fCpjOFV)CdncOG9n09Aa03qUnhptDr6fCpjiK8(ZnKBZXZuxKEdncOG9nCFT2iGc2AFPa3qFPa62K4By08Ea69DbxWn0G89N7jFV)Cd52C8m1fP3qYwaEl7g68IrHcyB08EXYXLvOnhpNdICKNtG5SVMJWffl84rS1u6ONzq1O0O8LeMIf8b7vyymvo005akjohxMdsISCWphNxmkuaBJM3lwwYQwLta5euoYUHgbuW(gQa2gnV)cUNe09NBi3MJNPUi9gAeqb7BO61XA5BizlaVLDdnmnbnt(NdICyIVWuSOAT14LdICwoUScT545CqKdWwumqakjwdGAQIZb)C(IK5GeZrHXEVgylkgOYjGCwwYQwDdj4r8SgylkgOUN89cUN879NBi3MJNPUi9gAeqb7BOee2XA5BizlaVLDdxoUScT545CqKdWwumqakjwdGAQIZb)CKNZxKmNaYrEokm271aBrXaLqbSnwlNZPZ5Raz5ilhz5Cyokm271aBrXavobKZYsw1QCqKJ8CiqONc6UfetxnrSSrHxo005OWyVxdSffducfW2yTCoUMZV5qtNJ8CyIVWuSOATc6TnhA6CyIVWuSOATdeGohA6CyIVWuSOAT)12MdICcmhG55giuWNxdJAaAwhHlRacUnhptLJSCqKJ8CuyS3Rb2IIbkHcyBSwohxZ57NCoDoYZ5BobKdW8Cdea3vRLGWwj42C8mvoYYrwoiYXuG18AmOBEZb)Cq2NCqI548IrHcyB08EXYsw1QCoDohyoYYbrobMJZlgf)RMAzknlHbDZRe3an38IQoflEy5GihdttqZK)3qcEepRb2IIbQ7jFVG7ji59NBi3MJNPUi9gs2cWBz3qdttqZK)3qJakyFdJWLWAyu3g4T8fCpbz3FUHCBoEM6I0BizlaVLDdDEXOGy6QjIh2n0iGc23W1WXn8P0XL7tH3fCp5aV)Cd52C8m1fP3qYwaEl7gAyAcAM8phe5eyooVyuqmD1eXdlhe5ipNyHcnqVSKvTkhxZHaHEkO7wqGno4FwdqZAfwTfqjwwYQwLta5GC5qtNtSqHgOxwYQwLJlZ57b9jhxZjOGYHMohce6PGUBbb24G)znanRvy1waL4HLdnDobMdbIJBRbIUqHgOJgNJSBOrafSVHe2ZkqzET5luTe3Gl4EcYD)5gYT54zQlsVHKTa8w2n0W0e0m5FoiYjWCCEXOGy6QjIhwoiYrEoXcfAGEzjRAvoUMdbc9uq3TGaBCW)SgGM1kSAlGsSSKvTkNaYb5YHMoNyHcnqVSKvTkhxMZ3d6toUMZVbLdnDoei0tbD3ccSXb)ZAaAwRWQTakXdlhA6Ccmhceh3wdeDHcnqhnohz3qJakyFdRMyBBGc2xW9Kd6(ZnKBZXZuxKEdjBb4TSBySqHgOxwYQwLJR58fz5qtNJ8CCEXOaBlj4svMxBlX6IOXEELTcCM)X54AobHSp5qtNJZlgfyBjbxQY8ABjwxen2ZRSvGZ8poh8pMtqi7toYYbrooVyuOa2gnVx8WYbroei0tbD3cIPRMiwwYQwLd(5GSp3qJakyFd)xn1YuAfwTfqDb3tCX7p3qUnhptDr6n0iGc23qfG9EB1rVT8nKSfG3YUHlhxwH2C8CoiYbusSga1ufNd(58fz5Gihfg79AGTOyGsOa2gRLZX1CqYCqKJHPjOzY)CqKJ8CCEXOGy6QjILLSQv5GFoF)KdnDobMJZlgfetxnr8WYr2nKGhXZAGTOyG6EY3l4EY3p3FUHCBoEM6I0Bie7gQyWn0iGc23qC2wMJNVH4m)JVHoVyuGTLeCPkZRTLyDr0ypVYwboZ)4CCnNGq2NCqI5ykWAEng0nV5Gih55qGqpf0DliMUAIyzjRAvobKZ3p5GFoXcfAGEzjRAvo005qGqpf0DliMUAIyzjRAvobKZVFYX1CIfk0a9Ysw1QCqKtSqHgOxwYQwLd(5893p5qtNJZlgfetxnrSSKvTkh8Zb5YrwoiYHj(ctXIQ1wJxo005eluOb6LLSQv54YC(g0NCCnNVi7gIZwDBs8nKaBCW)SMaBQcuW(cUN8979NBi3MJNPUi9gs2cWBz3qC2wMJNfeyJd(N1eytvGc25GihtbwZRXGU5nhxZbzFUHgbuW(gsGno4FwdqZAfwTfqDb3t(g09NBi3MJNPUi9gs2cWBz3qM4lmflQwBnE5GihdttqZK)5GihNxmkW2scUuL512sSUiASNxzRaN5FCoUMtqi7toiYrEouqGWOmmqHJ1k32kPPmjdflaf5F1OYHMoNaZHaXXT1arZKf6Hlvo005OWyVxdSffdu5GFobLJSBOrafSVHX3INgg1S)18fCp57V3FUHCBoEM6I0BOrafSVHgLHbkCSw52wPBizlaVLDddmhqr(xnQCqKJcJ9EnWwumqjuaBJM3NJR54I3qcEepRb2IIbQ7jFVG7jFrY7p3qUnhptDr6nKSfG3YUHoVyuaBgGwPX4LWyGc2IhwoiYrEooVyuOa2gnVxSCCzfAZXZ5qtNJPaR51yq38Md(54IFYr2n0iGc23qfW2O59xW9KVi7(ZnKBZXZuxKEdjBb4TSBibIJBRbIUqHgOJgNdICWzBzoEwqGno4FwtGnvbkyNdICiqONc6UfeyJd(N1a0SwHvBbuILLSQv54AoOiucj7SCoDoeU85iphtbwZRXGU5nNdZbzFYrwoiYX5fJcfW2O59ILJlRqBoE(gAeqb7BOcyB08(l4EY3d8(ZnKBZXZuxKEdjBb4TSBibIJBRbIUqHgOJgNdICWzBzoEwqGno4FwtGnvbkyNdICiqONc6UfeyJd(N1a0SwHvBbuILLSQv54AoOiucj7SCoDoeU85iphtbwZRXGU5nNdZ53p5ilhe548IrHcyB08EXd7gAeqb7BOcyR6TO4l4EYxK7(ZnKBZXZuxKEdHy3qfdUHgbuW(gIZ2YC88neN5F8n0uG18AmOBEZb)CoOp5GeZrEooVyuOa2gnVxSSKvTkNtNZV5Cyokm271OnfGZrwoiXCKNdfeiIVfpnmQz)RzXYsw1QCoDoilhz5GihNxmkuaBJM3lEy3qC2QBtIVHkGTrZ71UHnqhnVxdJXl4EY3d6(ZnKBZXZuxKEdjBb4TSBOZlgfWMbOvAINTvJRufSfpSCOPZjWCuaBJ1YcdttqZK)5qtNJ8CCEXOGy6QjILLSQv54Aoilhe548IrbX0vtepSCOPZrEooVyuSgoUHpLoUCFk8ellzvRYX1CqrOes2z5C6CiC5ZrEoMcSMxJbDZBohMZVFYrwoiYX5fJI1WXn8P0XL7tHN4HLJSCKLdICWzBzoEwOa2gnVx7g2aD08EnmgZbrokm271aBrXaLqbSnAEFoUMZV3qJakyFdvaBvVffFb3t(6I3FUHCBoEM6I0BizlaVLDdLNdt8fMIfvRTgVCqKdbc9uq3TGy6QjILLSQv5GFoi7to005iphcABrXQCoMtq5GiNLjOTffRbLeNJR5GSCKLdnDoe02IIv5CmNFZrwoiYXW0e0m5)n0iGc23WMDRLGW(cUNe0N7p3qUnhptDr6nKSfG3YUHYZHj(ctXIQ1wJxoiYHaHEkO7wqmD1eXYsw1QCWphK9jhA6CKNdbTTOyvohZjOCqKZYe02II1GsIZX1CqwoYYHMohcABrXQCoMZV5ilhe5yyAcAM8)gAeqb7BiAZh1sqyFb3tc679NBi3MJNPUi9gs2cWBz3q55WeFHPyr1ARXlhe5qGqpf0DliMUAIyzjRAvo4NdY(KdnDoYZHG2wuSkNJ5euoiYzzcABrXAqjX54Aoilhz5qtNdbTTOyvohZ53CKLdICmmnbnt(FdncOG9nm(8ETee2xW9KGc6(Zn0iGc23q32UfC1WOM9VMVHCBoEM6I0l4Esq)E)5gYT54zQlsVHqSBOIb3qJakyFdXzBzoE(gIZ8p(gQWyVxdSffducfW2yTCo4NZbLta5e9q4MJ8CKmfGx804m)JZ5WCc6toYYjGCIEiCZrEooVyuOa2QElkwZsyq38kXnqOag5FohMdsMJSBioB1TjX3qfW2yTSUATc6T9cUNeesE)5gYT54zQlsVHKTa8w2nKj(ctXc)RTv38zGCOPZHj(ctXcRXt38zGCOPZHj(ctXIQ1kO32CqKtG5GZ2YC8SqbSnwlRRwRGEBZHMohNxmkiMUAIyzjRAvoUMJrafSfkGTXAzbFgtEawdkjohe548IrbX0vtellzvRYX1C4ZyYdWAqjX5GihNxmkiMUAI4HLdnDooVyuSgoUHpLoUCFk8epSCqKJcJ9EnAtb4CWpNpId8gAeqb7BO71aOVG7jbHS7p3qJakyFdvaBJ1Y3qUnhptDr6fCpjOd8(ZnKBZXZuxKEdncOG9nCFT2iGc2AFPa3qFPa62K4By08Ea69DbxWnmAEpa9(U)Cp579NBi3MJNPUi9gs2cWBz3WaZzFnhHlkw4yERjSgg1M3RbORgLsWhSxHHXu3qJakyFdvaBvVffFb3tc6(ZnKBZXZuxKEdncOG9nu96yT8nKSfG3YUHuqGqcc7yTSyzjRAvo4NZYsw1QBibpIN1aBrXa19KVxW9KFV)CdncOG9nucc7yT8nKBZXZuxKEbxWnubU)Cp579NBi3MJNPUi9gAeqb7BOee2XA5BizlaVLDdxoUScT545CqKdWwumqakjwdGAQIZb)C(guoiYrEooVyuqmD1eXYsw1QCWphKLdICKNJZlgfRHJB4tPJl3NcpXYsw1QCWphKLdnDobMJZlgfRHJB4tPJl3NcpXdlhz5qtNtG548IrbX0vtepSCOPZXuG18AmOBEZX1C(9toYYbroYZjWCCEXO4F1ultPzjmOBEL4gO5Mxu1PyXdlhA6CmfynVgd6M3CCnNF)KJSCqKJHPjOzY)BibpIN1aBrXa19KVxW9KGU)Cd52C8m1fP3qJakyFdvVowlFdjBb4TSB4YXLvOnhpNdICa2IIbcqjXAautvCo4NZ3GYbroYZX5fJcIPRMiwwYQwLd(5GSCqKJ8CCEXOynCCdFkDC5(u4jwwYQwLd(5GSCOPZjWCCEXOynCCdFkDC5(u4jEy5ilhA6CcmhNxmkiMUAI4HLdnDoMcSMxJbDZBoUMZVFYrwoiYrEobMJZlgf)RMAzknlHbDZRe3an38IQoflEy5qtNJPaR51yq38MJR587NCKLdICmmnbnt(Fdj4r8SgylkgOUN89cUN879NBi3MJNPUi9gAeqb7BOcWEVT6O3w(gs2cWBz3WLJlRqBoEohe5aSffdeGsI1aOMQ4CWpNVhyoiYrEooVyuqmD1eXYsw1QCWphKLdICKNJZlgfRHJB4tPJl3NcpXYsw1QCWphKLdnDobMJZlgfRHJB4tPJl3NcpXdlhz5qtNtG548IrbX0vtepSCOPZXuG18AmOBEZX1C(9toYYbroYZjWCCEXO4F1ultPzjmOBEL4gO5Mxu1PyXdlhA6CmfynVgd6M3CCnNF)KJSCqKJHPjOzY)BibpIN1aBrXa19KVxW9eK8(ZnKBZXZuxKEdjBb4TSBOHPjOzY)BOrafSVHr4synmQBd8w(cUNGS7p3qUnhptDr6nKSfG3YUHoVyuqmD1eXd7gAeqb7B4A44g(u64Y9PW7cUNCG3FUHCBoEM6I0BizlaVLDdLNJ8CCEXOGj(ctXAf0BRyzjRAvo4NZ3p5qtNJZlgfmXxykw7FTTILLSQv5GFoF)KJSCqKdbc9uq3TGy6QjILLSQv5GFo)(jhe5iphNxmkW2scUuL512sSUiASNxzRaN5FCoUMtqi5NCOPZjWC2xZr4IIfyBjbxQY8ABjwxen2ZRSvWhSxHHXu5ilhz5qtNJZlgfyBjbxQY8ABjwxen2ZRSvGZ8poh8pMtqi3NCOPZHaHEkO7wqmD1eXYgfE5Gih55ykWAEng0nV5GFoU4NCOPZbNTL54zrP0gKZr2n0iGc23W)vtTmLwHvBbuxW9eK7(ZnKBZXZuxKEdjBb4TSBO8CmfynVgd6M3CWphx8toiYrEooVyu8VAQLP0Seg0nVsCd0CZlQ6uS4HLdnDobMdbIJBRbI)4TL15ilhA6CiqCCBnq0fk0aD04COPZbNTL54zrP0gKZHMohNxmkC8qiL)PaIhwoiYX5fJchpes5FkGyzjRAvoUMtqFYjGCKNJ8CCXCoDo7R5iCrXcSTKGlvzETTeRlIg75v2k4d2RWWyQCKLta5iphKmNtNdb2uVciWwMukwB(cvlXnqWT54zQCKLJSCKLdICcmhNxmkiMUAI4HLdICKNtSqHgOxwYQwLJR5qGqpf0DliWgh8pRbOzTcR2cOellzvRYjGCqUCOPZjwOqd0llzvRYX1CckOCcih554I5C6CKNJZlgfyBjbxQY8ABjwxen2ZRSvGZ8poh8Z57Np5ilhz5qtNtSqHgOxwYQwLJlZ57b9jhxZjOGYHMohce6PGUBbb24G)znanRvy1waL4HLdnDobMdbIJBRbIUqHgOJgNJSBOrafSVHe2ZkqzET5luTe3Gl4EYbD)5gYT54zQlsVHKTa8w2nuEoMcSMxJbDZBo4NJl(jhe5iphNxmk(xn1YuAwcd6MxjUbAU5fvDkw8WYHMoNaZHaXXT1aXF82Y6CKLdnDoeioUTgi6cfAGoACo005GZ2YC8SOuAdY5qtNJZlgfoEiKY)uaXdlhe548IrHJhcP8pfqSSKvTkhxZ53p5eqoYZrEoUyoNoN91CeUOyb2wsWLQmV2wI1frJ98kBf8b7vyymvoYYjGCKNdsMZPZHaBQxbeyltkfRnFHQL4gi42C8mvoYYrwoYYbrobMJZlgfetxnr8WYbroYZjwOqd0llzvRYX1CiqONc6UfeyJd(N1a0SwHvBbuILLSQv5eqoixo005eluOb6LLSQv54Ao)guobKJ8CCXCoDoYZX5fJcSTKGlvzETTeRlIg75v2kWz(hNd(589ZNCKLJSCOPZjwOqd0llzvRYXL589G(KJR58Bq5qtNdbc9uq3TGaBCW)SgGM1kSAlGs8WYHMoNaZHaXXT1arxOqd0rJZr2n0iGc23WQj22gOG9fCpXfV)Cd52C8m1fP3qi2nuXGBOrafSVH4STmhpFdXz(hFdjqCCBnq0fk0aD04CqKJ8CCEXOaBlj4svMxBlX6IOXEELTcCM)X54AobHKFYbroYZHaHEkO7wqmD1eXYsw1QCciNVFYb)CIfk0a9Ysw1QCOPZHaHEkO7wqmD1eXYsw1QCciNF)KJR5eluOb6LLSQv5GiNyHcnqVSKvTkh8Z57VFYHMohNxmkiMUAIyzjRAvo4NdYLJSCqKJZlgfmXxykwRGEBfllzvRYb)C((jhA6CIfk0a9Ysw1QCCzoFd6toUMZxKLJSBioB1TjX3qcSXb)ZAcSPkqb7l4EY3p3FUHCBoEM6I0Bie7gQyWn0iGc23qC2wMJNVH4m)JVHYZjWCiqONc6UfetxnrSSrHxo005eyo4STmhpliWgh8pRjWMQafSZbroeioUTgi6cfAGoACoYUH4Sv3MeFdvgowhHRMy6QjxW9KVFV)Cd52C8m1fP3qYwaEl7gIZ2YC8SGaBCW)SMaBQcuWohe5ykWAEng0nV54Ao)(5gAeqb7Bib24G)znanRvy1wa1fCp5Bq3FUHCBoEM6I0BizlaVLDdzIVWuSOAT14LdICmmnbnt(NdICCEXOaBlj4svMxBlX6IOXEELTcCM)X54AobHKFYbroYZHccegLHbkCSw52wjnLjzOybOi)Rgvo005eyoeioUTgiAMSqpCPYrwoiYbNTL54zHYWX6iC1etxn5gAeqb7By8T4PHrn7FnFb3t((79NBi3MJNPUi9gs2cWBz3WBOrafSVHgLHbkCSw52wPl4EYxK8(ZnKBZXZuxKEdjBb4TSBOZlgfWMbOvAmEjmgOGT4HLdICCEXOqbSnAEVy54Yk0MJNVHgbuW(gQa2gnV)cUN8fz3FUHCBoEM6I0BizlaVLDdDEXOqbS1dxkXYsw1QCCnNdmhe5iphNxmkyIVWuSwb92kEy5qtNJZlgfmXxykw7FTTIhwoYYbroMcSMxJbDZBo4NJl(5gAeqb7BiXAc71oVy8g68IrDBs8nubS1dxQl4EY3d8(ZnKBZXZuxKEdjBb4TSBibIJBRbIUqHgOJgNdICWzBzoEwqGno4FwtGnvbkyNdICiqONc6UfeyJd(N1a0SwHvBbuILLSQv54AoOiucj7SCoDoeU85iphtbwZRXGU5nNdZ53p5i7gAeqb7BOcyR6TO4l4EYxK7(ZnKBZXZuxKEdjBb4TSBiW8Cdeka792QP2kceCBoEMkhe5eyoaZZnqOa26HlLGBZXZu5GihNxmkuaBJM3lwoUScT545CqKJ8CCEXOGj(ctXA)RTvSSKvTkh8Z5aZbromXxykwuT2)ABZbrooVyuGTLeCPkZRTLyDr0ypVYwboZ)4CCnNGq2NCOPZX5fJcSTKGlvzETTeRlIg75v2kWz(hNd(hZjiK9jhe5ykWAEng0nV5GFoU4NCOPZHccegLHbkCSw52wjnLjzOyXYsw1QCWpNdkhA6CmcOGTWOmmqHJ1k32kPPmjdflQwh9fk0GCKLdICcmhce6PGUBbX0vtelBu4DdncOG9nubSnAE)fCp57bD)5gYT54zQlsVHKTa8w2n05fJcyZa0knXZ2QXvQc2Ihwo00548IrX)QPwMsZsyq38kXnqZnVOQtXIhwo00548IrbX0vtepSCqKJ8CCEXOynCCdFkDC5(u4jwwYQwLJR5GIqjKSZY505q4YNJ8CmfynVgd6M3ComNF)KJSCqKJZlgfRHJB4tPJl3NcpXdlhA6CcmhNxmkwdh3WNshxUpfEIhwoiYjWCiqONc6UfRHJB4tPJl3NcpXYgfE5qtNtG5qG442AGah3a04T5ilhA6CmfynVgd6M3CWphx8toiYHj(ctXIQ1wJ3n0iGc23qfWw1BrXxW9KVU49NBi3MJNPUi9gs2cWBz3qG55giuaB9WLsWT54zQCqKJ8CCEXOqbS1dxkXdlhA6CmfynVgd6M3CWphx8toYYbrooVyuOa26HlLqbmY)CCnNFZbroYZX5fJcM4lmfRvqVTIhwo00548Irbt8fMI1(xBR4HLJSCqKJZlgfyBjbxQY8ABjwxen2ZRSvGZ8pohxZjiK7toiYrEoei0tbD3cIPRMiwwYQwLd(589to005eyo4STmhpliWgh8pRjWMQafSZbroeioUTgi6cfAGoACoYUHgbuW(gQa2QElk(cUNe0N7p3qUnhptDr6nKSfG3YUHYZX5fJcSTKGlvzETTeRlIg75v2kWz(hNJR5eeY9jhA6CCEXOaBlj4svMxBlX6IOXEELTcCM)X54AobHSp5GihG55giua27TvtTvei42C8mvoYYbrooVyuWeFHPyTc6TvSSKvTkh8Zb5YbromXxykwuTwb92MdICcmhNxmkGndqR0y8symqbBXdlhe5eyoaZZnqOa26HlLGBZXZu5Gihce6PGUBbX0vtellzvRYb)CqUCqKJ8CiqONc6Uf)RMAzkTcR2cOellzvRYb)CqUCOPZjWCiqCCBnq8hVTSohz3qJakyFdvaBvVffFb3tc679NBi3MJNPUi9gs2cWBz3q5548Irbt8fMI1(xBR4HLdnDoYZHG2wuSkNJ5euoiYzzcABrXAqjX54Aoilhz5qtNdbTTOyvohZ53CKLdICmmnbnt(NdICWzBzoEwOmCSocxnX0vtUHgbuW(g2SBTee2xW9KGc6(ZnKBZXZuxKEdjBb4TSBO8CCEXOGj(ctXA)RTv8WYbrobMdbIJBRbI)4TL15qtNJ8CCEXO4F1ultPzjmOBEL4gO5Mxu1PyXdlhe5qG442AG4pEBzDoYYHMoh55qqBlkwLZXCckhe5SmbTTOynOK4CCnhKLJSCOPZHG2wuSkNJ58Bo00548IrbX0vtepSCKLdICmmnbnt(NdICWzBzoEwOmCSocxnX0vtUHgbuW(gI28rTee2xW9KG(9(ZnKBZXZuxKEdjBb4TSBO8CCEXOGj(ctXA)RTv8WYbrobMdbIJBRbI)4TL15qtNJ8CCEXO4F1ultPzjmOBEL4gO5Mxu1PyXdlhe5qG442AG4pEBzDoYYHMoh55qqBlkwLZXCckhe5SmbTTOynOK4CCnhKLJSCOPZHG2wuSkNJ58Bo00548IrbX0vtepSCKLdICmmnbnt(NdICWzBzoEwOmCSocxnX0vtUHgbuW(ggFEVwcc7l4Esqi59NBOrafSVHUTDl4QHrn7FnFd52C8m1fPxW9KGq29NBi3MJNPUi9gs2cWBz3qM4lmflQw7FTT5qtNdt8fMIfkO3wDZNbYHMohM4lmflSgpDZNbYHMohNxmkCB7wWvdJA2)Aw8WYbrooVyuWeFHPyT)12kEy5qtNJ8CCEXOGy6QjILLSQv54AogbuWw4EnaAbFgtEawdkjohe548IrbX0vtepSCKDdncOG9nubSnwlFb3tc6aV)CdncOG9n09Aa03qUnhptDr6fCpjiK7(ZnKBZXZuxKEdncOG9nCFT2iGc2AFPa3qFPa62K4By08Ea69DbxWnKAztYPAkEV)Cp579NBi3MJNPUi9gcXUHkgCdncOG9neNTL545BioZ)4BO8CCEXOausSB42AQLnjNQP4vSSKvTkh8ZbfHsizNLdICcmhM4lmflQw7FTT5GiNaZHj(ctXcf0BRU5Za5GiNaZHj(ctXcRXt38zGCOPZX5fJcqjXUHBRPw2KCQMIxXYsw1QCWphJakyluaBJ1Yc(mM8aSgusCoiYrEokm271aBrXaLqbSnwlNd(58nhA6CyIVWuSOAT)12MdnDomXxykwOGEB1nFgihA6CyIVWuSWA80nFgihz5ilhA6CcmhNxmkaLe7gUTMAztYPAkEfpSBioB1TjX3qLfznaQFkwRWyV)cUNe09NBi3MJNPUi9gs2cWBz3q55eyo4STmhpluwK1aO(PyTcJ9(COPZrEoYZX5fJcM4lmfRvqVTILLSQv54AoOiucj7SCqKJZlgfmXxykwRGEBfpSCKLdnDoYZX5fJI1WXn8P0XL7tHNyzjRAvoUMdkcLqYolNtNdHlFoYZXuG18AmOBEZ5WC(9toYYbrooVyuSgoUHpLoUCFk8epSCKLJSCKLdICKNJZlgfmXxykwRGEBfpSCOPZHj(ctXcf0BRU5Za5qtNdt8fMIfwJNU5Za5ilhA6CmfynVgd6M3CWphx8Zn0iGc23qfWw1BrXxW9KFV)Cd52C8m1fP3qJakyFdLGWowlFdjBb4TSB4YXLvOnhpNdICa2IIbcqjXAautvCo4NZ3dmhe5eyooVyu8VAQLP0Seg0nVsCd0CZlQ6uS4HDdj4r8SgylkgOUN89cUNGK3FUHCBoEM6I0BOrafSVHQxhRLVHKTa8w2nC54Yk0MJNZbroaBrXabOKynaQPkoh8Z57bMdICcmhNxmk(xn1YuAwcd6MxjUbAU5fvDkw8WUHe8iEwdSffdu3t(Eb3tq29NBi3MJNPUi9gAeqb7BOcWEVT6O3w(gs2cWBz3WLJlRqBoEohe5aSffdeGsI1aOMQ4CWpNVhyoiYrEooVyuqmD1eXYsw1QCWpNVFYHMoNaZX5fJcIPRMiEy5ilhe5yyAcAM8phe5eyooVyu8VAQLP0Seg0nVsCd0CZlQ6uS4HDdj4r8SgylkgOUN89cUNCG3FUHCBoEM6I0BizlaVLDdnfynVgd6M3CCnhK7toiYrEooVyuakj2nCBn1YMKt1u8kwwYQwLd(5GIqjKSZY505euo005eyooVyuakj2nCBn1YMKt1u8kEy5i7gAeqb7B4A44g(u64Y9PW7cUNGC3FUHCBoEM6I0BizlaVLDdnmnbnt(NdICcmhNxmkiMUAI4HLdICKNJZlgfGsIDd3wtTSj5unfVILLSQv5GFoOiucj7SCOPZjWCCEXOausSB42AQLnjNQP4v8WYrwoiYXW0e0m5FoiYjWCCEXOGy6QjIhwoiYrEoXcfAGEzjRAvoUMdbc9uq3TGaBCW)SgGM1kSAlGsSSKvTkNaYb5YHMoNyHcnqVSKvTkhxMZ3d6toUMtqbLdnDoei0tbD3ccSXb)ZAaAwRWQTakXdlhA6Ccmhceh3wdeDHcnqhnohz3qJakyFdjSNvGY8AZxOAjUbxW9Kd6(ZnKBZXZuxKEdjBb4TSBOHPjOzY)CqKtG548IrbX0vtepSCqKJ8CCEXOausSB42AQLnjNQP4vSSKvTkh8ZbfHsizNLdnDobMJZlgfGsIDd3wtTSj5unfVIhwoYYbroYZjwOqd0llzvRYX1CiqONc6UfeyJd(N1a0SwHvBbuILLSQv5eqoixo005eluOb6LLSQv54YC(EqFYX1C(nOCOPZHaHEkO7wqGno4FwdqZAfwTfqjEy5qtNtG5qG442AGOluOb6OX5i7gAeqb7By1eBBduW(cUN4I3FUHCBoEM6I0BizlaVLDdnmnbnt(FdncOG9nmcxcRHrDBG3YxW9KVFU)Cd52C8m1fP3qYwaEl7g68IrbOKy3WT1ulBsovtXRyzjRAvo4NdkcLqYolhe5ipNOhc3CKNJ8CIfk0a9Ysw1QCqI589toYY5WCmcOGTMaHEkO7ohz5GForpeU5iph55eluOb6LLSQv5GeZ57NCqI5qGqpf0DliMUAIyzjRAvoYY5WCmcOGTMaHEkO7ohz5Gih55WeFHPyr1Af0BBo005WeFHPyHc6Tv38zGCOPZX5fJcIPRMiwwYQwLd(589to00548Irb2wsWLQmV2wI1frJ98kBf4m)JZb)J5eeY9jhe5ykWAEng0nV5GFoi7toYYr2n0iGc23W)vtTmLwHvBbuxW9KVFV)Cd52C8m1fP3qi2nuXGBOrafSVH4STmhpFdXz(hFdDEXOaBlj4svMxBlX6IOXEELTcCM)X54AobHKFYbroYZHaHEkO7wqmD1eXYsw1QCciNVFYb)CIfk0a9Ysw1QCOPZHaHEkO7wqmD1eXYsw1QCciNF)KJR5eluOb6LLSQv5GiNyHcnqVSKvTkh8Z57VFYHMoNyHcnqVSKvTkhxMZ3G(KJR58fz5qtNJZlgfetxnrSSKvTkh8Zb5YrwoiYHj(ctXIQ1wJ3neNT62K4Bib24G)znb2ufOG9fCp5Bq3FUHCBoEM6I0BizlaVLDdXzBzoEwqGno4FwtGnvbkyNdICKNJPaR51yq38MJR5GSp5GihC2wMJNfLsBqohA6CmfynVgd6M3CCnNF)KJSCqKJ8CCEXOausSB42AQLnjNQP4vSSKvTkh8ZHpJjpaRbLeNdnDobMJZlgfGsIDd3wtTSj5unfVIhwoYUHgbuW(gsGno4FwdqZAfwTfqDb3t((79NBi3MJNPUi9gs2cWBz3qM4lmflQwBnE5GihdttqZK)5GihC2wMJNfklYAau)uSwHXEFoiYrEouqGWOmmqHJ1k32kPPmjdflaf5F1OYHMoNaZHaXXT1arZKf6Hlvo005OWyVxdSffdu5GFobLJSBOrafSVHX3INgg1S)18fCp5lsE)5gYT54zQlsVHKTa8w2n8gAeqb7BOrzyGchRvUTv6cUN8fz3FUHCBoEM6I0BizlaVLDddmhceh3wdeDHcnqhnohe5qGqpf0DliMUAIyzJcVCqKJPaR51yq38Md(5GCFUHgbuW(gQa2QElk(cUN89aV)Cd52C8m1fP3qYwaEl7gsG442AGOluOb6OX5GihC2wMJNfeyJd(N1eytvGc25GihtbwZRXGU5nh8pMZVFYbroei0tbD3ccSXb)ZAaAwRWQTakXYsw1QCCnhuekHKDwoNohcx(CKNJPaR51yq38MZH587NCKDdncOG9nubSv9wu8fCp5lYD)5gYT54zQlsVHKTa8w2nuEooVyuWeFHPyT)12kEy5qtNJ8CiOTffRY5yobLdICwMG2wuSgusCoUMdYYrwo005qqBlkwLZXC(nhz5GihdttqZK)3qJakyFdB2Twcc7l4EY3d6(ZnKBZXZuxKEdjBb4TSBO8CCEXOGj(ctXA)RTv8WYHMoh55qqBlkwLZXCckhe5SmbTTOynOK4CCnhKLJSCOPZHG2wuSkNJ58BoYYbrogMMGMj)ZbroYZX5fJcqjXUHBRPw2KCQMIxXYsw1QCWph(mM8aSgusCo005eyooVyuakj2nCBn1YMKt1u8kEy5i7gAeqb7BiAZh1sqyFb3t(6I3FUHCBoEM6I0BizlaVLDdLNJZlgfmXxykw7FTTIhwo005iphcABrXQCoMtq5GiNLjOTffRbLeNJR5GSCKLdnDoe02IIv5CmNFZrwoiYXW0e0m5FoiYrEooVyuakj2nCBn1YMKt1u8kwwYQwLd(5WNXKhG1GsIZHMoNaZX5fJcqjXUHBRPw2KCQMIxXdlhz3qJakyFdJpVxlbH9fCpjOp3FUHgbuW(g622TGRgg1S)18nKBZXZuxKEb3tc679NBi3MJNPUi9gs2cWBz3qM4lmflQw7FTT5qtNdt8fMIfkO3wDZNbYHMohM4lmflSgpDZNbYHMohNxmkCB7wWvdJA2)Aw8WYbrooVyuWeFHPyT)12kEy5qtNJ8CCEXOGy6QjILLSQv54AogbuWw4EnaAbFgtEawdkjohe548IrbX0vtepSCKDdncOG9nubSnwlFb3tckO7p3qJakyFdDVga9nKBZXZuxKEb3tc637p3qUnhptDr6n0iGc23W91AJakyR9LcCd9LcOBtIVHrZ7bO33fCbxWnehVQc23tc6tqF(4IFqUBOBB7QrPUHhqp4pGFYbGtoGHeYjNFqZ5usyWfKteU5CWrTSj5unfVhC5S8b7vltLJckX5ypauYamvoe0wJIvImyxOAoNGqc5G8WghVaMkNWsc5ZrHxdSZYXL5aG54cplhQcxPkyNdeJxda3CKFOSCK)9mzImyxOAohKdjKdYdBC8cyQCcljKphfEnWolhx6YCaWCCHNLJeK65FQCGy8Aa4MJCxklh5FptMid2fQMZ5Gqc5G8WghVaMkNWsc5ZrHxdSZYXLUmhamhx4z5ibPE(NkhigVgaU5i3LYYr(3ZKjYGDHQ5C((bjKdYdBC8cyQCcljKphfEnWolhxMdaMJl8SCOkCLQGDoqmEnaCZr(HYYrEqNjtKb7cvZ589lsihKh244fWu5ewsiFok8AGDwoU0L5aG54cplhji1Z)u5aX41aWnh5UuwoY)EMmrgSlunNZ3dejKdYdBC8cyQCcljKphfEnWolhxMdaMJl8SCOkCLQGDoqmEnaCZr(HYYr(3ZKjYGZGpGEWFa)KdaNCadjKto)GMZPKWGliNiCZ5GdBzcuYXahC5S8b7vltLJckX5ypauYamvoe0wJIvImyxOAohKHeYb5HnoEbmvoHLeYNJcVgyNLJlZbaZXfEwoufUsvWohigVgaU5i)qz5ipOZKjYGZGpGEWFa)KdaNCadjKto)GMZPKWGliNiCZ5GZG8bxolFWE1Yu5OGsCo2daLmatLdbT1OyLid2fQMZ5lsihKh244fWu5ewsiFok8AGDwoU0L5aG54cplhji1Z)u5aX41aWnh5UuwoY)EMmrgSlunNZViHCqEyJJxatLtyjH85OWRb2z54YCaWCCHNLdvHRufSZbIXRbGBoYpuwoY)EMmrgSlunNZbIeYb5HnoEbmvoHLeYNJcVgyNLJlDzoayoUWZYrcs98pvoqmEnaCZrUlLLJ8VNjtKb7cvZ5GCiHCqEyJJxatLtyjH85OWRb2z54sxMdaMJl8SCKGup)tLdeJxda3CK7sz5i)7zYezWUq1CoF)GeYb5HnoEbmvoHLeYNJcVgyNLJlDzoayoUWZYrcs98pvoqmEnaCZrUlLLJ8VNjtKb7cvZ58fziHCqEyJJxatLtyjH85OWRb2z54YCaWCCHNLdvHRufSZbIXRbGBoYpuwoY)EMmrgSlunNZ3dejKdYdBC8cyQCcljKphfEnWolhxMdaMJl8SCOkCLQGDoqmEnaCZr(HYYr(3ZKjYGDHQ5C(ICiHCqEyJJxatLtyjH85OWRb2z54YCaWCCHNLdvHRufSZbIXRbGBoYpuwoY)EMmrgSlunNZ3dcjKdYdBC8cyQCcljKphfEnWolhxMdaMJl8SCOkCLQGDoqmEnaCZr(HYYr(3ZKjYGDHQ5Cc6xKqoipSXXlGPYjSKq(Cu41a7SCCzoayoUWZYHQWvQc25aX41aWnh5hklh5bDMmrg8pO5CIqVh6UAu5yV1u54MxoNNIPYP6CaO5CmcOGDo(sbYX5bYXnVConeKte(AQCQohaAohJIc25qzaZXumsidohKyokGTQ3II1Seg0nVsCdYGZGpGEWFa)KdaNCadjKto)GMZPKWGliNiCZ5Gtbo4Yz5d2RwMkhfuIZXEaOKbyQCiOTgfRezWUq1CoihsihKh244fWu5ewsiFok8AGDwoU0L5aG54cplhji1Z)u5aX41aWnh5UuwoY)EMmrgSlunNZbHeYb5HnoEbmvoHLeYNJcVgyNLJlDzoayoUWZYrcs98pvoqmEnaCZrUlLLJ8VNjtKb7cvZ54IiHCqEyJJxatLtyjH85OWRb2z54sxMdaMJl8SCKGup)tLdeJxda3CK7sz5i)7zYezWUq1CoFpqKqoipSXXlGPYjSKq(Cu41a7SCCzoayoUWZYHQWvQc25aX41aWnh5hklh5FptMid2fQMZ57bHeYb5HnoEbmvoHLeYNJcVgyNLJlZbaZXfEwoufUsvWohigVgaU5i)qz5i)7zYezWzWhqp4pGFYbGtoGHeYjNFqZ5usyWfKteU5CW5anWbxolFWE1Yu5OGsCo2daLmatLdbT1OyLid2fQMZ57xKqoipSXXlGPYjSKq(Cu41a7SCCPlZbaZXfEwosqQN)PYbIXRbGBoYDPSCK)9mzImyxOAoNVhisihKh244fWu5ewsiFok8AGDwoUmhamhx4z5qv4kvb7CGy8Aa4MJ8dLLJ8FptMid2fQMZ5lYHeYb5HnoEbmvoHLeYNJcVgyNLJlZbaZXfEwoufUsvWohigVgaU5i)qz5i)7zYezWzWhaKWGlGPYb5YXiGc254lfqjYGVHkmMCp57NGUHylmwE(gEaMdsnV1eoNdiSVIkd(amNdijaOdV58nOZZjOpb9jdod(amhKhT1Oyfsid(amhKyoh8uumvoHqVT5Gu2KezWhG5GeZb5rBnkMkhGTOyGUI5qmfRYbaZHGhXZAGTOyGsKbNbBeqbBLaBzcuYXahLGW(F16iCLYGncOGTsGTmbk5yGaoEO71aOZGncOGTsGTmbk5yGaoEO71aOZGncOGTsGTmbk5yGaoEOcyR6TO4ZR4rfg79AGTOyGsOa2gnV3vKmd2iGc2kb2YeOKJbc44H4STmhpFEBs8rcSXb)ZAkwHxtohN5F8rhOsHi6HWvU8yHcnqVSKvTcjg0hzU8BqFKHF0dHRC5XcfAGEzjRAfsmiKHeL)9ZPbMNBGOAITTbkyl42C8mLmKOCK80eyt9kGaBzsPyT5luTe3ab3MJNPKjZLFpOpYYGZGpaZ5aINXKhGPYHXXlE5akjohaAohJaGBoLkhdNvEZXZImyJakyRoQGEB1oSjLbBeqbBvahpeNTL545ZBtIpwkTb5ZXz(hFuHXEVgylkgOekGTrZ7X)BgSrafSvbC8qhEv8(VAuNxXJYdKaXXT1arxOqd0rJPPdKaHEkO7wqGno4FwdqZAfwTfqjEyYq48IrbX0vtepSmyJakyRc44Hyqqb7ZR4rNxmkiMUAI4HLbBeqbBvahp8PyDbyjvgSrafSvbC8W91AJakyR9LcCEBs8rdYNRaBrah)EEfpIZ2YC8SOuAdYzWgbuWwfWXd3xRncOGT2xkW5TjXhPw2KCQMI3ZvGTiGJFpVIh3xZr4IIfGsIDd3wtTSj5unfVc(G9kmmMkd2iGc2QaoE4(ATrafS1(sboVnj(Od0aNRaBrah)EEfpUVMJWfflCmV1ewdJAZ71a0vJsj4d2RWWyQmyJakyRc44H7R1gbuWw7lf482K4JkqgCgSrafSvcdYhvaBJM3FEfp68IrHcyB08EXYXLvOnhpJqEG7R5iCrXcpEeBnLo6zgunknkFjHPybFWEfggtrtdkj2LUejrg(oVyuOa2gnVxSSKvTkGGKLbBeqbBLWGCahpu96yT85e8iEwdSffduh)EEfpAyAcAM8hbt8fMIfvRTgpelhxwH2C8mcGTOyGausSga1ufJ)xKejQWyVxdSffdubSSKvTkd2iGc2kHb5aoEOee2XA5Zj4r8SgylkgOo(98kEC54Yk0MJNraSffdeGsI1aOMQy8L)fjdqUcJ9EnWwumqjuaBJ1YN(RazYK5sfg79AGTOyGkGLLSQviKtGqpf0DliMUAIyzJcpAAfg79AGTOyGsOa2gRLD9xAA5mXxykwuTwb92stZeFHPyr1Ahiannnt8fMIfvR9V2webcmp3aHc(8AyudqZ6iCzfqWT54zkziKRWyVxdSffducfW2yTSRF)CA5FdayEUbcG7Q1sqyReCBoEMsMmeMcSMxJbDZl(i7ds05fJcfW2O59ILLSQvN(aLHiqNxmk(xn1YuAwcd6MxjUbAU5fvDkw8WqyyAcAM8pd2iGc2kHb5aoEyeUewdJ62aVLpVIhnmnbnt(NbBeqbBLWGCahpCnCCdFkDC5(u4DEfp68IrbX0vtepSmyJakyRegKd44He2ZkqzET5luTe3GZR4rdttqZK)ic05fJcIPRMiEyiKhluOb6LLSQvUsGqpf0DliWgh8pRbOzTcR2cOellzvRca5OPJfk0a9Ysw1kx6YVh0hxdkiAAce6PGUBbb24G)znanRvy1waL4HrthibIJBRbIUqHgOJglld2iGc2kHb5aoEy1eBBduW(8kE0W0e0m5pIaDEXOGy6QjIhgc5XcfAGEzjRALRei0tbD3ccSXb)ZAaAwRWQTakXYsw1QaqoA6yHcnqVSKvTYLU87b9X1FdIMMaHEkO7wqGno4FwdqZAfwTfqjEy00bsG442AGOluOb6OXYYGncOGTsyqoGJh(VAQLP0kSAlG68kEmwOqd0llzvRC9lYOPL78Irb2wsWLQmV2wI1frJ98kBf4m)JDniK9HM25fJcSTKGlvzETTeRlIg75v2kWz(hJ)XGq2hziCEXOqbSnAEV4HHGaHEkO7wqmD1eXYsw1k8r2NmyJakyRegKd44Hka792QJEB5Zj4r8SgylkgOo(98kEC54Yk0MJNrakjwdGAQIX)lYqOWyVxdSffducfW2yTSRijcdttqZK)iK78IrbX0vtellzvRW)7hA6aDEXOGy6QjIhMSmyJakyRegKd44H4STmhpFEBs8rcSXb)ZAcSPkqb7ZXz(hF05fJcSTKGlvzETTeRlIg75v2kWz(h7Aqi7ds0uG18AmOBEriNaHEkO7wqmD1eXYsw1Qa((b)yHcnqVSKvTIMMaHEkO7wqmD1eXYsw1Qa(9JRXcfAGEzjRAfIyHcnqVSKvTc)V)(HM25fJcIPRMiwwYQwHpYjdbt8fMIfvRTgpA6yHcnqVSKvTYLU8BqFC9lYYGncOGTsyqoGJhsGno4FwdqZAfwTfqDEfpIZ2YC8SGaBCW)SMaBQcuWgHPaR51yq386kY(KbBeqbBLWGCahpm(w80WOM9VMpVIhzIVWuSOAT14HWW0e0m5pcNxmkW2scUuL512sSUiASNxzRaN5FSRbHSpiKtbbcJYWafowRCBRKMYKmuSauK)vJIMoqceh3wdentwOhUu00km271aBrXaf(bjld2iGc2kHb5aoEOrzyGchRvUTv6CcEepRb2IIbQJFpVIhdeuK)vJcHcJ9EnWwumqjuaBJM37QlMbBeqbBLWGCahpubSnAE)5v8OZlgfWMbOvAmEjmgOGT4HHqUZlgfkGTrZ7flhxwH2C8mnTPaR51yq38IVl(rwgSrafSvcdYbC8qfW2O59NxXJeioUTgi6cfAGoAmcC2wMJNfeyJd(N1eytvGc2iiqONc6UfeyJd(N1a0SwHvBbuILLSQvUIIqjKSZonHlVCtbwZRXGU51Li7JmeoVyuOa2gnVxSCCzfAZXZzWgbuWwjmihWXdvaBvVffFEfpsG442AGOluOb6OXiWzBzoEwqGno4FwtGnvbkyJGaHEkO7wqGno4FwdqZAfwTfqjwwYQw5kkcLqYo70eU8YnfynVgd6Mxx(7hziCEXOqbSnAEV4HLbBeqbBLWGCahpeNTL545ZBtIpQa2gnVx7g2aD08EnmgphN5F8rtbwZRXGU5f)d6dsuUZlgfkGTrZ7fllzvRo9VUuHXEVgTPaSmKOCkiqeFlEAyuZ(xZILLSQvNgzYq48IrHcyB08EXdld2iGc2kHb5aoEOcyR6TO4ZR4rNxmkGndqR0epBRgxPkylEy00bQa2gRLfgMMGMj)PPL78IrbX0vtellzvRCfziCEXOGy6QjIhgnTCNxmkwdh3WNshxUpfEILLSQvUIIqjKSZonHlVCtbwZRXGU51L)(rgcNxmkwdh3WNshxUpfEIhMmziWzBzoEwOa2gnVx7g2aD08EnmgrOWyVxdSffducfW2O59U(BgSrafSvcdYbC8WMDRLGW(8kEuot8fMIfvRTgpeei0tbD3cIPRMiwwYQwHpY(qtlNG2wuS6yqiwMG2wuSgusSRitgnnbTTOy1XFLHWW0e0m5FgSrafSvcdYbC8q0MpQLGW(8kEuot8fMIfvRTgpeei0tbD3cIPRMiwwYQwHpY(qtlNG2wuS6yqiwMG2wuSgusSRitgnnbTTOy1XFLHWW0e0m5FgSrafSvcdYbC8W4Z71sqyFEfpkNj(ctXIQ1wJhcce6PGUBbX0vtellzvRWhzFOPLtqBlkwDmieltqBlkwdkj2vKjJMMG2wuS64VYqyyAcAM8pd2iGc2kHb5aoEOBB3cUAyuZ(xZzWgbuWwjmihWXdXzBzoE(82K4JkGTXAzD1Af0B754m)JpQWyVxdSffducfW2yTm(huarpeUYLmfGx804m)JDzqFKfq0dHRCNxmkuaBvVffRzjmOBEL4giuaJ83LiPSmyJakyRegKd44HUxdG(8kEKj(ctXc)RTv38zaAAM4lmflSgpDZNbOPzIVWuSOATc6TfrG4STmhpluaBJ1Y6Q1kO3wAANxmkiMUAIyzjRALRgbuWwOa2gRLf8zm5bynOKyeoVyuqmD1eXYsw1kx5ZyYdWAqjXiCEXOGy6QjIhgnTZlgfRHJB4tPJl3NcpXddHcJ9EnAtby8)ioWmyJakyRegKd44HkGTXA5myJakyRegKd44H7R1gbuWw7lf482K4JrZ7bO3xgCgSrafSvchOboUgoUHpLoUCFk8oVIhDEXOGy6QjIhwgSrafSvchObc44H4STmhpFEBs8rYwGgcEyNJZ8p(yGoVyu4yERjSgg1M3RbORgLs3g4TS4HHiqNxmkCmV1ewdJAZ71a0vJsPTLynlEyzWgbuWwjCGgiGJhsSMWETZlgpVnj(OcyRhUuNxXJoVyuOa26HlLyzjRALRFrgc5oVyu4yERjSgg1M3RbORgLs3g4TSyzjRAf(iPaz00oVyu4yERjSgg1M3RbORgLsBlXAwSSKvTcFKuGmzimfynVgd6Mx8pEGFqiNaHEkO7wqmD1eXYsw1k8roAA5ei0tbD3cwcd6MxTdSPellzvRWh5qeOZlgf)RMAzknlHbDZRe3an38IQoflEyiiqCCBnq8hVTSwMSmyJakyReoqdeWXdvaBvVffFEfpgioBlZXZcYwGgcEyiKlpqce6PGUBbb24G)znanRvy1waL4HrthioBlZXZccSXb)ZAcSPkqbBA6ajqCCBnq0fk0aD0yziKtG442AGOluOb6OX00YjqONc6UfetxnrSSKvTcFKJMwobc9uq3TGLWGU5v7aBkXYsw1k8roeb68IrX)QPwMsZsyq38kXnqZnVOQtXIhgcceh3wde)XBlRLjtMmAA5ei0tbD3ccSXb)ZAaAwRWQTakXddbbc9uq3TGy6QjILnk8qqG442AGOluOb6OXYYGncOGTs4anqahpu96yT85e8iEwdSffduh)EEfpUCCzfAZXZia2IIbcqjXAautvm(FpqegMMGMj)rihNTL54zbzlqdbpmAA5McSMxJbDZRR)(brGoVyuqmD1eXdtgnnbc9uq3TGy6QjILnk8KLbBeqbBLWbAGaoEOee2XA5Zj4r8SgylkgOo(98kEC54Yk0MJNraSffdeGsI1aOMQy8)(Razimmnbnt(JqooBlZXZcYwGgcEy00YnfynVgd6Mxx)9dIaDEXOGy6QjIhMmAAce6PGUBbX0vtelBu4jdrGoVyu8VAQLP0Seg0nVsCd0CZlQ6uS4HLbBeqbBLWbAGaoEOcWEVT6O3w(CcEepRb2IIbQJFpVIhxoUScT54zeaBrXabOKynaQPkg)VhyallzvRqyyAcAM8hHCC2wMJNfKTane8WOPnfynVgd6Mxx)9dnnbc9uq3TGy6QjILnk8KLbBeqbBLWbAGaoEyeUewdJ62aVLpVIhnmnbnt(NbBeqbBLWbAGaoEy8T4PHrn7FnFEfpkNj(ctXIQ1wJhnnt8fMIfkO3wD16V00mXxykw4FTT6Q1FLHqEGeioUTgi6cfAGoAmnTCtbwZRXGU51vxeziKJZ2YC8SGSfOHGhgnTPaR51yq3866VFOPXzBzoEwukTbzziKJZ2YC8SGaBCW)SMIv41eebsGqpf0DliWgh8pRbOzTcR2cOepmA6aXzBzoEwqGno4FwtXk8AcIajqONc6Ufetxnr8WKjtgc5ei0tbD3cIPRMiwwYQwH)VFOPnfynVgd6Mx8DXpiiqONc6Ufetxnr8WqiNaHEkO7wWsyq38QDGnLyzjRALRgbuWwOa2gRLf8zm5bynOKyA6ajqCCBnq8hVTSwgnDSqHgOxwYQw563pYqiNccegLHbkCSw52wjnLjzOyXYsw1k8rsA6ajqCCBnq0mzHE4sjld2iGc2kHd0abC8W)vtTmLwHvBbuNxXJYzIVWuSW)AB1nFgGMMj(ctXcf0BRU5Za00mXxykwynE6Mpdqt78IrHJ5TMWAyuBEVgGUAukDBG3YILLSQv4JKcKrt78IrHJ5TMWAyuBEVgGUAukTTeRzXYsw1k8rsbYOPnfynVgd6Mx8DXpiiqONc6UfetxnrSSrHNmeYjqONc6UfetxnrSSKvTc)F)qttGqpf0DliMUAIyzJcpz00XcfAGEzjRALRF)KbBeqbBLWbAGaoEiH9ScuMxB(cvlXn48kEuUPaR51yq38IVl(bHCNxmk(xn1YuAwcd6MxjUbAU5fvDkw8WOPdKaXXT1aXF82YAz00eioUTgi6cfAGoAmnTZlgfoEiKY)uaXddHZlgfoEiKY)uaXYsw1kxd6taYrYttGn1RacSLjLI1MVq1sCdeCBoEMsMmeYdKaXXT1arxOqd0rJPPjqONc6UfeyJd(N1a0SwHvBbuIhgnDSqHgOxwYQw5kbc9uq3TGaBCW)SgGM1kSAlGsSSKvTkGdKMowOqd0llzvRCPl)EqFCnOpbihjpnb2uVciWwMukwB(cvlXnqWT54zkzYYGncOGTs4anqahpSAITTbkyFEfpk3uG18AmOBEX3f)GqUZlgf)RMAzknlHbDZRe3an38IQoflEy00bsG442AG4pEBzTmAAceh3wdeDHcnqhnMM25fJchpes5FkG4HHW5fJchpes5FkGyzjRALR)(ja5i5PjWM6vab2YKsXAZxOAjUbcUnhptjtgc5bsG442AGOluOb6OX00ei0tbD3ccSXb)ZAaAwRWQTakXdJMgNTL54zbb24G)znfRWRjiIfk0a9Ysw1k8)EqFciOpbihjpnb2uVciWwMukwB(cvlXnqWT54zkz00XcfAGEzjRALRei0tbD3ccSXb)ZAaAwRWQTakXYsw1QaoqA6yHcnqVSKvTY1F)eGCK80eyt9kGaBzsPyT5luTe3ab3MJNPKjld2iGc2kHd0abC8qcSXb)ZAaAwRWQTaQZR4r54STmhpliWgh8pRPyfEnbrSqHgOxwYQwH)3F)qt78IrbX0vtepmziK78IrHJ5TMWAyuBEVgGUAukDBG3YcfWi)14m)JX)3p00oVyu4yERjSgg1M3RbORgLsBlXAwOag5VgN5Fm()(rgnDSqHgOxwYQw563pzWgbuWwjCGgiGJhAuggOWXALBBLoVIhZGncOGTs4anqahpubSv9wu85v8ibIJBRbIUqHgOJgJqooBlZXZccSXb)ZAkwHxtOPjqONc6UfetxnrSSKvTY1VFKHWuG18AmOBEXhzFqqGqpf0DliWgh8pRbOzTcR2cOellzvRC97NmyJakyReoqdeWXdXzBzoE(82K4JMc7aiVHm5CCM)XhzIVWuSOAT)12E6dYLgbuWwOa2gRLf8zm5bynOK4acKj(ctXIQ1(xB7PpqxAeqbBH71aOf8zm5bynOK4a(icYLkm271OnfGZGncOGTs4anqahpubSv9wu85v8OC5XcfAGEzjRALRijnTCNxmkwdh3WNshxUpfEILLSQvUIIqjKSZonHlVCtbwZRXGU51L)(rgcNxmkwdh3WNshxUpfEIhMmz00YnfynVgd6M3aWzBzoEwykSdG8gYKt78Irbt8fMI1kO3wXYsw1QaOGar8T4PHrn7Fnlaf5VsVSKv9PdsGm8)g0hAAtbwZRXGU5naC2wMJNfMc7aiVHm50oVyuWeFHPyT)12kwwYQwfafeiIVfpnmQz)RzbOi)v6LLSQpDqcKH)3G(idbt8fMIfvRTgpeYLhibc9uq3TGy6QjIhgnnbIJBRbI)4TL1icKaHEkO7wWsyq38QDGnL4HjJMMaXXT1arxOqd0rJLrt78IrbX0vtellzvRW)GqeOZlgfRHJB4tPJl3NcpXdtwgSrafSvchObc44Hn7wlbH95v8OCNxmkyIVWuS2)ABfpmAA5e02IIvhdcXYe02II1GsIDfzYOPjOTffRo(RmegMMGMj)ZGncOGTs4anqahpeT5JAjiSpVIhL78Irbt8fMI1(xBR4HrtlNG2wuS6yqiwMG2wuSgusSRitgnnbTTOy1XFLHWW0e0m5FgSrafSvchObc44HXN3RLGW(8kEuUZlgfmXxykw7FTTIhgnTCcABrXQJbHyzcABrXAqjXUImz00e02IIvh)vgcdttqZK)zWgbuWwjCGgiGJh622TGRgg1S)1CgSrafSvchObc44HkGTXA5ZR4rM4lmflQw7FTT00mXxykwOGEB1nFgGMMj(ctXcRXt38zaAANxmkCB7wWvdJA2)Aw8WqWeFHPyr1A)RTLMwUZlgfetxnrSSKvTYvJakylCVgaTGpJjpaRbLeJW5fJcIPRMiEyYYGncOGTs4anqahp09Aa0zWgbuWwjCGgiGJhUVwBeqbBTVuGZBtIpgnVhGEFzWzWgbuWwjOw2KCQMI3J4STmhpFEBs8rLfznaQFkwRWyV)CCM)XhL78IrbOKy3WT1ulBsovtXRyzjRAf(Oiucj7mebYeFHPyr1A)RTfrGmXxykwOGEB1nFgarGmXxykwynE6Mpdqt78IrbOKy3WT1ulBsovtXRyzjRAf(gbuWwOa2gRLf8zm5bynOKyeYvyS3Rb2IIbkHcyBSwg)V00mXxykwuT2)ABPPzIVWuSqb92QB(mannt8fMIfwJNU5ZaYKrthOZlgfGsIDd3wtTSj5unfVIhwgSrafSvcQLnjNQP4nGJhQa2QElk(8kEuEG4STmhpluwK1aO(PyTcJ9EAA5YDEXOGj(ctXAf0BRyzjRALROiucj7meoVyuWeFHPyTc6Tv8WKrtl35fJI1WXn8P0XL7tHNyzjRALROiucj7Stt4Yl3uG18AmOBED5VFKHW5fJI1WXn8P0XL7tHN4HjtMmeYDEXOGj(ctXAf0BR4HrtZeFHPyHc6Tv38zaAAM4lmflSgpDZNbKrtBkWAEng0nV47IFYGncOGTsqTSj5unfVbC8qjiSJ1YNtWJ4znWwumqD875v84YXLvOnhpJaylkgiaLeRbqnvX4)9areOZlgf)RMAzknlHbDZRe3an38IQoflEyzWgbuWwjOw2KCQMI3aoEO61XA5Zj4r8SgylkgOo(98kEC54Yk0MJNraSffdeGsI1aOMQy8)EGic05fJI)vtTmLMLWGU5vIBGMBErvNIfpSmyJakyReulBsovtXBahpubyV3wD0BlFobpIN1aBrXa1XVNxXJlhxwH2C8mcGTOyGausSga1ufJ)3deHCNxmkiMUAIyzjRAf(F)qthOZlgfetxnr8WKHWW0e0m5pIaDEXO4F1ultPzjmOBEL4gO5Mxu1PyXdld2iGc2kb1YMKt1u8gWXdxdh3WNshxUpfENxXJMcSMxJbDZRRi3heYDEXOausSB42AQLnjNQP4vSSKvTcFuekHKD2PdIMoqNxmkaLe7gUTMAztYPAkEfpmzzWgbuWwjOw2KCQMI3aoEiH9ScuMxB(cvlXn48kE0W0e0m5pIaDEXOGy6QjIhgc5oVyuakj2nCBn1YMKt1u8kwwYQwHpkcLqYoJMoqNxmkaLe7gUTMAztYPAkEfpmzimmnbnt(JiqNxmkiMUAI4HHqESqHgOxwYQw5kbc9uq3TGaBCW)SgGM1kSAlGsSSKvTkaKJMowOqd0llzvRCPl)EqFCnOGOPjqONc6UfeyJd(N1a0SwHvBbuIhgnDGeioUTgi6cfAGoASSmyJakyReulBsovtXBahpSAITTbkyFEfpAyAcAM8hrGoVyuqmD1eXddHCNxmkaLe7gUTMAztYPAkEfllzvRWhfHsizNrthOZlgfGsIDd3wtTSj5unfVIhMmeYJfk0a9Ysw1kxjqONc6UfeyJd(N1a0SwHvBbuILLSQvbGC00XcfAGEzjRALlD53d6JR)gennbc9uq3TGaBCW)SgGM1kSAlGs8WOPdKaXXT1arxOqd0rJLLbBeqbBLGAztYPAkEd44Hr4synmQBd8w(8kE0W0e0m5FgSrafSvcQLnjNQP4nGJh(VAQLP0kSAlG68kE05fJcqjXUHBRPw2KCQMIxXYsw1k8rrOes2ziKh9q4kxESqHgOxwYQwHe)(rMljqONc6ULHF0dHRC5XcfAGEzjRAfs87hKibc9uq3TGy6QjILLSQvYCjbc9uq3TmeYzIVWuSOATc6TLMMj(ctXcf0BRU5Za00oVyuqmD1eXYsw1k8)(HM25fJcSTKGlvzETTeRlIg75v2kWz(hJ)XGqUpimfynVgd6Mx8r2hzYYGncOGTsqTSj5unfVbC8qC2wMJNpVnj(ib24G)znb2ufOG954m)Jp68Irb2wsWLQmV2wI1frJ98kBf4m)JDniK8dc5ei0tbD3cIPRMiwwYQwfW3p4hluOb6LLSQv00ei0tbD3cIPRMiwwYQwfWVFCnwOqd0llzvRqeluOb6LLSQv4)93p00XcfAGEzjRALlD53G(46xKrt78IrbX0vtellzvRWh5KHGj(ctXIQ1wJxgSrafSvcQLnjNQP4nGJhsGno4FwdqZAfwTfqDEfpIZ2YC8SGaBCW)SMaBQcuWgHCtbwZRXGU51vK9bboBlZXZIsPnittBkWAEng0nVU(7hziK78IrbOKy3WT1ulBsovtXRyzjRAf(8zm5bynOKyA6aDEXOausSB42AQLnjNQP4v8WKLbBeqbBLGAztYPAkEd44HX3INgg1S)185v8it8fMIfvRTgpegMMGMj)rGZ2YC8SqzrwdG6NI1km27riNccegLHbkCSw52wjnLjzOybOi)RgfnDGeioUTgiAMSqpCPOPvyS3Rb2IIbk8dswgSrafSvcQLnjNQP4nGJhAuggOWXALBBLoVIhZGncOGTsqTSj5unfVbC8qfWw1BrXNxXJbsG442AGOluOb6OXiiqONc6UfetxnrSSrHhctbwZRXGU5fFK7tgSrafSvcQLnjNQP4nGJhQa2QElk(8kEKaXXT1arxOqd0rJrGZ2YC8SGaBCW)SMaBQcuWgHPaR51yq38I)XF)GGaHEkO7wqGno4FwdqZAfwTfqjwwYQw5kkcLqYo70eU8YnfynVgd6Mxx(7hzzWgbuWwjOw2KCQMI3aoEyZU1sqyFEfpk35fJcM4lmfR9V2wXdJMwobTTOy1XGqSmbTTOynOKyxrMmAAcABrXQJ)kdHHPjOzY)myJakyReulBsovtXBahpeT5JAjiSpVIhL78Irbt8fMI1(xBR4HrtlNG2wuS6yqiwMG2wuSgusSRitgnnbTTOy1XFLHWW0e0m5pc5oVyuakj2nCBn1YMKt1u8kwwYQwHpFgtEawdkjMMoqNxmkaLe7gUTMAztYPAkEfpmzzWgbuWwjOw2KCQMI3aoEy859AjiSpVIhL78Irbt8fMI1(xBR4HrtlNG2wuS6yqiwMG2wuSgusSRitgnnbTTOy1XFLHWW0e0m5pc5oVyuakj2nCBn1YMKt1u8kwwYQwHpFgtEawdkjMMoqNxmkaLe7gUTMAztYPAkEfpmzzWgbuWwjOw2KCQMI3aoEOBB3cUAyuZ(xZzWgbuWwjOw2KCQMI3aoEOcyBSw(8kEKj(ctXIQ1(xBlnnt8fMIfkO3wDZNbOPzIVWuSWA80nFgGM25fJc32UfC1WOM9VMfpmeoVyuWeFHPyT)12kEy00YDEXOGy6QjILLSQvUAeqbBH71aOf8zm5bynOKyeoVyuqmD1eXdtwgSrafSvcQLnjNQP4nGJh6Ena6myJakyReulBsovtXBahpCFT2iGc2AFPaN3MeFmAEpa9(YGZGncOGTsenVhGEFhvaBvVffFEfpg4(AocxuSWX8wtynmQnVxdqxnkLGpyVcdJPYGncOGTsenVhGEFbC8q1RJ1YNtWJ4znWwumqD875v8ifeiKGWowllwwYQwH)Ysw1QmyJakyRerZ7bO3xahpucc7yTCgCgSrafSvcf4Oee2XA5Zj4r8SgylkgOo(98kEC54Yk0MJNraSffdeGsI1aOMQy8)gec5oVyuqmD1eXYsw1k8rgc5oVyuSgoUHpLoUCFk8ellzvRWhz00b68IrXA44g(u64Y9PWt8WKrthOZlgfetxnr8WOPnfynVgd6Mxx)9JmeYd05fJI)vtTmLMLWGU5vIBGMBErvNIfpmAAtbwZRXGU511F)idHHPjOzY)myJakyRekqahpu96yT85e8iEwdSffduh)EEfpUCCzfAZXZia2IIbcqjXAautvm(FdcHCNxmkiMUAIyzjRAf(idHCNxmkwdh3WNshxUpfEILLSQv4JmA6aDEXOynCCdFkDC5(u4jEyYOPd05fJcIPRMiEy00McSMxJbDZRR)(rgc5b68IrX)QPwMsZsyq38kXnqZnVOQtXIhgnTPaR51yq3866VFKHWW0e0m5FgSrafSvcfiGJhQaS3BRo6TLpNGhXZAGTOyG643ZR4XLJlRqBoEgbWwumqakjwdGAQIX)7bIqUZlgfetxnrSSKvTcFKHqUZlgfRHJB4tPJl3NcpXYsw1k8rgnDGoVyuSgoUHpLoUCFk8epmz00b68IrbX0vtepmAAtbwZRXGU511F)idH8aDEXO4F1ultPzjmOBEL4gO5Mxu1PyXdJM2uG18AmOBED93pYqyyAcAM8pd2iGc2kHceWXdJWLWAyu3g4T85v8OHPjOzY)myJakyRekqahpCnCCdFkDC5(u4DEfp68IrbX0vtepSmyJakyRekqahp8F1ultPvy1wa15v8OC5oVyuWeFHPyTc6TvSSKvTc)VFOPDEXOGj(ctXA)RTvSSKvTc)VFKHGaHEkO7wqmD1eXYsw1k8)9dc5oVyuGTLeCPkZRTLyDr0ypVYwboZ)yxdcj)qth4(AocxuSaBlj4svMxBlX6IOXEELTc(G9kmmMsMmAANxmkW2scUuL512sSUiASNxzRaN5Fm(hdc5(qttGqpf0DliMUAIyzJcpeYnfynVgd6Mx8DXp004STmhplkL2GSSmyJakyRekqahpKWEwbkZRnFHQL4gCEfpk3uG18AmOBEX3f)GqUZlgf)RMAzknlHbDZRe3an38IQoflEy00bsG442AG4pEBzTmAAceh3wdeDHcnqhnMMgNTL54zrP0gKPPDEXOWXdHu(NciEyiCEXOWXdHu(NciwwYQw5AqFcqUCx807R5iCrXcSTKGlvzETTeRlIg75v2k4d2RWWykzbihjpnb2uVciWwMukwB(cvlXnqWT54zkzYKHiqNxmkiMUAI4HHqESqHgOxwYQw5kbc9uq3TGaBCW)SgGM1kSAlGsSSKvTkaKJMowOqd0llzvRCnOGcqUlEA5oVyuGTLeCPkZRTLyDr0ypVYwboZ)y8)(5Jmz00XcfAGEzjRALlD53d6JRbfennbc9uq3TGaBCW)SgGM1kSAlGs8WOPdKaXXT1arxOqd0rJLLbBeqbBLqbc44HvtSTnqb7ZR4r5McSMxJbDZl(U4heYDEXO4F1ultPzjmOBEL4gO5Mxu1PyXdJMoqceh3wde)XBlRLrttG442AGOluOb6OX004STmhplkL2GmnTZlgfoEiKY)uaXddHZlgfoEiKY)uaXYsw1kx)9taYL7INEFnhHlkwGTLeCPkZRTLyDr0ypVYwbFWEfggtjla5i5PjWM6vab2YKsXAZxOAjUbcUnhptjtMmeb68IrbX0vtepmeYJfk0a9Ysw1kxjqONc6UfeyJd(N1a0SwHvBbuILLSQvbGC00XcfAGEzjRALR)guaYDXtl35fJcSTKGlvzETTeRlIg75v2kWz(hJ)3pFKjJMowOqd0llzvRCPl)EqFC93GOPjqONc6UfeyJd(N1a0SwHvBbuIhgnDGeioUTgi6cfAGoASSmyJakyRekqahpeNTL545ZBtIpsGno4FwtGnvbkyFooZ)4JeioUTgi6cfAGoAmc5oVyuGTLeCPkZRTLyDr0ypVYwboZ)yxdcj)Gqobc9uq3TGy6QjILLSQvb89d(XcfAGEzjRAfnnbc9uq3TGy6QjILLSQvb87hxJfk0a9Ysw1keXcfAGEzjRAf(F)9dnTZlgfetxnrSSKvTcFKtgcNxmkyIVWuSwb92kwwYQwH)3p00XcfAGEzjRALlD53G(46xKjld2iGc2kHceWXdXzBzoE(82K4JkdhRJWvtmD1KZXz(hFuEGei0tbD3cIPRMiw2OWJMoqC2wMJNfeyJd(N1eytvGc2iiqCCBnq0fk0aD0yzzWgbuWwjuGaoEib24G)znanRvy1wa15v8ioBlZXZccSXb)ZAcSPkqbBeMcSMxJbDZRR)(jd2iGc2kHceWXdJVfpnmQz)R5ZR4rM4lmflQwBnEimmnbnt(JW5fJcSTKGlvzETTeRlIg75v2kWz(h7Aqi5heYPGaHrzyGchRvUTvstzsgkwakY)QrrthibIJBRbIMjl0dxkziWzBzoEwOmCSocxnX0vtYGncOGTsOabC8qJYWafowRCBR05v8ygSrafSvcfiGJhQa2gnV)8kE05fJcyZa0kngVegduWw8Wq48IrHcyB08EXYXLvOnhpNbBeqbBLqbc44HeRjSx78IXZBtIpQa26Hl15v8OZlgfkGTE4sjwwYQw56bIqUZlgfmXxykwRGEBfpmAANxmkyIVWuS2)ABfpmzimfynVgd6Mx8DXpzWgbuWwjuGaoEOcyR6TO4ZR4rceh3wdeDHcnqhngboBlZXZccSXb)ZAcSPkqbBeei0tbD3ccSXb)ZAaAwRWQTakXYsw1kxrrOes2zNMWLxUPaR51yq386YF)ild2iGc2kHceWXdvaBJM3FEfpcmp3aHcWEVTAQTIab3MJNPqeiW8CdekGTE4sj42C8mfcNxmkuaBJM3lwoUScT54zeYDEXOGj(ctXA)RTvSSKvTc)debt8fMIfvR9V2weoVyuGTLeCPkZRTLyDr0ypVYwboZ)yxdczFOPDEXOaBlj4svMxBlX6IOXEELTcCM)X4FmiK9bHPaR51yq38IVl(HMMccegLHbkCSw52wjnLjzOyXYsw1k8piAAJakylmkddu4yTYTTsAktYqXIQ1rFHcnqgIajqONc6UfetxnrSSrHxgSrafSvcfiGJhQa2QElk(8kE05fJcyZa0knXZ2QXvQc2IhgnTZlgf)RMAzknlHbDZRe3an38IQoflEy00oVyuqmD1eXddHCNxmkwdh3WNshxUpfEILLSQvUIIqjKSZonHlVCtbwZRXGU51L)(rgcNxmkwdh3WNshxUpfEIhgnDGoVyuSgoUHpLoUCFk8epmebsGqpf0Dlwdh3WNshxUpfEILnk8OPdKaXXT1aboUbOXBLrtBkWAEng0nV47IFqWeFHPyr1ARXld2iGc2kHceWXdvaBvVffFEfpcmp3aHcyRhUucUnhptHqUZlgfkGTE4sjEy00McSMxJbDZl(U4hziCEXOqbS1dxkHcyK)U(lc5oVyuWeFHPyTc6Tv8WOPDEXOGj(ctXA)RTv8WKHW5fJcSTKGlvzETTeRlIg75v2kWz(h7Aqi3heYjqONc6UfetxnrSSKvTc)VFOPdeNTL54zbb24G)znb2ufOGncceh3wdeDHcnqhnwwgSrafSvcfiGJhQa2QElk(8kEuUZlgfyBjbxQY8ABjwxen2ZRSvGZ8p21GqUp00oVyuGTLeCPkZRTLyDr0ypVYwboZ)yxdczFqamp3aHcWEVTAQTIab3MJNPKHW5fJcM4lmfRvqVTILLSQv4JCiyIVWuSOATc6TfrGoVyuaBgGwPX4LWyGc2IhgIabMNBGqbS1dxkb3MJNPqqGqpf0DliMUAIyzjRAf(ihc5ei0tbD3I)vtTmLwHvBbuILLSQv4JC00bsG442AG4pEBzTSmyJakyRekqahpSz3AjiSpVIhL78Irbt8fMI1(xBR4HrtlNG2wuS6yqiwMG2wuSgusSRitgnnbTTOy1XFLHWW0e0m5pcC2wMJNfkdhRJWvtmD1KmyJakyRekqahpeT5JAjiSpVIhL78Irbt8fMI1(xBR4HHiqceh3wde)XBlRPPL78IrX)QPwMsZsyq38kXnqZnVOQtXIhgcceh3wde)XBlRLrtlNG2wuS6yqiwMG2wuSgusSRitgnnbTTOy1XFPPDEXOGy6QjIhMmegMMGMj)rGZ2YC8Sqz4yDeUAIPRMKbBeqbBLqbc44HXN3RLGW(8kEuUZlgfmXxykw7FTTIhgIajqCCBnq8hVTSMMwUZlgf)RMAzknlHbDZRe3an38IQoflEyiiqCCBnq8hVTSwgnTCcABrXQJbHyzcABrXAqjXUImz00e02IIvh)LM25fJcIPRMiEyYqyyAcAM8hboBlZXZcLHJ1r4QjMUAsgSrafSvcfiGJh622TGRgg1S)1CgSrafSvcfiGJhQa2gRLpVIhzIVWuSOAT)12stZeFHPyHc6Tv38zaAAM4lmflSgpDZNbOPDEXOWTTBbxnmQz)RzXddHZlgfmXxykw7FTTIhgnTCNxmkiMUAIyzjRALRgbuWw4EnaAbFgtEawdkjgHZlgfetxnr8WKLbBeqbBLqbc44HUxdGod2iGc2kHceWXd3xRncOGT2xkW5TjXhJM3dqVVl4cUxa]] )


end