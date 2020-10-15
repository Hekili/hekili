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


    spec:RegisterPack( "Balance", 20201014.1, [[dG04sdqiQKEevQkDjLi2KQQpPQGYOivDksLvbvHxrLYSus6wqvu7IWVusmmq4yGOLjqEMQIMMQcDnqITrLk9nOkzCQkW5GQuRdQImpQe3tjSpqQdQQGQfcs6HuPIjsLQk1fPsvL0hPsvvDsQuvyLcuZKkvzNkr9tQuvjgkvQQyPuPQONkOPQKQVsLQQSxL6VKmyvomLftupgLjtkxgzZc9zOy0qPtl1RvvA2u1TPIDR43qgoOoUQcYYL8CunDGRRkBhQ8DbmELuopuvRxjsZNi7x0Bi3RVd1maTxoiiccciHaYpkccYGc6J49oeGpmTdHn2xddTdhZH2Hq182WODiSHVhzA713HC0Ry0oelaaZXtRScMgG9jlyiNv4TZZBGgnSYIGv4TdBLDO8R9a3hZwEhQzaAVCqqeeeqcbKFueeKbf0NFWo0EaSOAhg2oUZoeBRPrZwEhQrC2o09npOAEByuEUFxVwld29np3VWaizQYdYpUAEbbrqqKbNb7(MN7G1gmehpLb7(MhEoVpCnnslVqK3Q8GkzoImy338WZ55oyTbdPLhWkmeq1X8ygN45bq5XWN5jfWkmeGlYGDFZdpNN7tYbHJ0Y7ndXio3k8ZdNvTj7jEE6Bbjwnp4IWP4aR4VcdLhEg68GlcNGdSI)kmKoXo03CaFV(oeUigYr2a713ld5E9DOXanA2Hoi08Thvevo7qAmzpPTH6gSxoO967qJbA0Sdduga7oKgt2tABOUb7L)CV(o0yGgn7WaLbWUdPXK9K2gQBWE5pUxFhsJj7jTnu3HSQbu12oKdtEVcyfgcWfCGvrZ7ZZL8(4o0yGgn7qoWk(RWqBWEzOSxFhsJj7jTnu3Hi4DiNa7qJbA0SdXzvBYEAhIZ8pAhkJ488(Zl6rOkp95PpVyJblqvKJ1dpp8CEbbrE6YBL8GmiiYtxEqNx0JqvE6ZtFEXgdwGQihRhEE458cck5HNZtFEqcrE4rEaZtdq0dZQXanAe0yYEslpD5HNZtFEFmp8ipgA0EnqaxeR5KY8nMXHgGGgt2tA5PlpD5TsEq(bqKNUDioRuJ5q7qgAWH(sknIJ)W2GnyhkJmWE99YqUxFhsJj7jTnu3HSQbu12ou(fJcMP6HjEW7qJbA0SdldhnOhxflAwk(BWE5G2RVdPXK9K2gQ7qe8oKtGDOXanA2H4SQnzpTdXz(hTdDnp5xmkKnVnmsHIkZ7vaS9GHRgd8ks8GZ7ppxZt(fJczZBdJuOOY8EfaBpy4kRy2qIh8oeNvQXCODiRAWGap4nyV8N713H0yYEsBd1DiRAavTTdLFXOGdSYJknrrowp88CjpiHsE)5Ppp5xmkKnVnmsHIkZ7vaS9GHRgd8ksuKJ1dppOZ7JcOKNKuEYVyuiBEByKcfvM3Ray7bdxzfZgsuKJ1dppOZ7JcOKNU8(ZZ4GY8kyuaQYd6f55UqK3FE6ZJHqEnuGrWmvpmrrowp88Gop8kpjP80NhdH8AOaJGCGrbOsjJgnrrowp88Gop8kV)8Cnp5xmk(2JwrAkYbgfGkhAakAOctVus8GZ7ppgchn2aeFXVABYtxE62Hgd0OzhYSHrEL8lg3HYVyunMdTd5aR8OsBd2l)X967qAmzpPTH6oKvnGQ22HUMhoRAt2tcw1GbbEW59NN(80NNR5XqiVgkWiyObh6lPayjfhURgWfp48KKYZ18WzvBYEsWqdo0xsXqJwdA0KNKuEUMhdHJgBaIPXGfOIgLNU8(ZtFEmeoASbiMgdwGkAuEss5Pppgc51qbgbZu9Wef5y9WZd68WR8KKYtFEmeYRHcmcYbgfGkLmA0ef5y9WZd68WR8(ZZ18KFXO4BpAfPPihyuaQCObOOHkm9sjXdoV)8yiC0ydq8f)QTjpD5PlpD5PlpjP80NhdH8AOaJGHgCOVKcGLuC4UAax8GZ7ppgc51qbgbZu9WefzA4N3FEmeoASbiMgdwGkAuE62Hgd0OzhYbwXFfgAd2ldL967qAmzpPTH6o0yGgn7q(BIDr7qw1aQABhwuSiowt2t59NhWkmeqaAhsbqkTMYd68G0DZ7ppdwXWsSV59NN(8WzvBYEsWQgmiWdopjP80NNXbL5vWOauLNl59je59NNR5j)IrbZu9Wep480LNKuEmeYRHcmcMP6HjkY0WppD7qg(mpPawHHa89YqUb7LD3967qAmzpPTH6o0yGgn7qheAIDr7qw1aQABhwuSiowt2t59NhWkmeqaAhsbqkTMYd68G8tbuY7ppdwXWsSV59NN(8WzvBYEsWQgmiWdopjP80NNXbL5vWOauLNl59je59NNR5j)IrbZu9Wep480LNKuEmeYRHcmcMP6HjkY0WppD59NNR5j)IrX3E0kstroWOau5qdqrdvy6LsIh8oKHpZtkGvyiaFVmKBWEz8AV(oKgt2tABOUdngOrZoKdiV3kv0BfTdzvdOQTDyrXI4ynzpL3FEaRWqabODifaP0AkpOZds3np3YRihRhEE)5zWkgwI9nV)80NhoRAt2tcw1GbbEW5jjLNXbL5vWOauLNl59je5jjLhdH8AOaJGzQEyIImn8Zt3oKHpZtkGvyiaFVmKBWE5pyV(oKgt2tABOUdzvdOQTDObRyyj23DOXanA2HruXifkQgd8kAd2lJ3713H0yYEsBd1DiRAavTTd1NhX8nmNe9OSb)8KKYJy(gMtcoYBLQhfK5jjLhX8nmNe(3yLQhfK5PlV)80NNR5Xq4OXgGyAmybQOr5jjLN(8moOmVcgfGQ8Cjp8gk59NN(8WzvBYEsWQgmiWdopjP8moOmVcgfGQ8CjVpHipjP8WzvBYEs0CLHO80L3FE6ZdNvTj7jbdn4qFjLgXXFy59NNR5XqiVgkWiyObh6lPayjfhURgWfp48KKYZ18WzvBYEsWqdo0xsPrC8hwE)55AEmeYRHcmcMP6HjEW5PlpD5PlV)80NhdH8AOaJGzQEyIICSE45bDEFcrEss5zCqzEfmkav5bDE4ne59NhdH8AOaJGzQEyIhCE)5Pppgc51qbgb5aJcqLsgnAIICSE455sEgd0OrWbwf7Ie0Ae7bifODO8KKYZ18yiC0ydq8f)QTjpD5jjLxSXGfOkYX6HNNl5bje5PlV)80NNgcimndg04ifpGvoknZXWqIICSE45bDEFmpjP8Cnpgchn2aedXkKhvA5PBhAmqJMDy8v4Rqrf5FdTb7LHeI967qAmzpPTH6oKvnGQ22H6ZJy(gMtc)BSsn0AG8KKYJy(gMtcoYBLAO1a5jjLhX8nmNe2GVAO1a5jjLN8lgfYM3ggPqrL59ka2EWWvJbEfjkYX6HNh059rbuYtskp5xmkKnVnmsHIkZ7vaS9GHRSIzdjkYX6HNh059rbuYtskpJdkZRGrbOkpOZdVHiV)8yiKxdfyemt1dtuKPHFE6Y7pp95XqiVgkWiyMQhMOihRhEEqN3NqKNKuEmeYRHcmcMP6HjkY0WppD5jjLxSXGfOkYX6HNNl5bje7qJbA0Sd)2JwrAkoCxnGVb7LHeY967qAmzpPTH6oKvnGQ22H6ZZ4GY8kyuaQYd68WBiY7pp95j)IrX3E0kstroWOau5qdqrdvy6LsIhCEss55AEmeoASbi(IF12KNU8KKYJHWrJnaX0yWcurJYtskp5xmkK9iKM)XbIhCE)5j)IrHShH08poquKJ1dppxYliiYZT80N3hZdpYJHgTxdeWfXAoPmFJzCObiOXK9KwE6YtxE)5PppxZJHWrJnaX0yWcurJYtskpgc51qbgbdn4qFjfalP4WD1aU4bNNKuEXgdwGQihRhEEUKhdH8AOaJGHgCOVKcGLuC4UAaxuKJ1dpp3YZDZtskVyJblqvKJ1dpVLKhKFae55sEbbrEULN(8(yE4rEm0O9AGaUiwZjL5BmJdnabnMSN0YtxE62Hgd0OzhYipXbT5vMVXmo0a2G9Yqg0E9DinMSN02qDhYQgqvB7q95zCqzEfmkav5bDE4ne59NN(8KFXO4BpAfPPihyuaQCObOOHkm9sjXdopjP8Cnpgchn2aeFXVABYtxEss5Xq4OXgGyAmybQOr5jjLN8lgfYEesZ)4aXdoV)8KFXOq2JqA(hhikYX6HNNl59je55wE6Z7J5Hh5XqJ2Rbc4IynNuMVXmo0ae0yYEslpD5PlV)80NNR5Xq4OXgGyAmybQOr5jjLhdH8AOaJGHgCOVKcGLuC4UAax8GZtskpCw1MSNem0Gd9LuAeh)HL3FEXgdwGQihRhEEqNhKFae55wEbbrEULN(8(yE4rEm0O9AGaUiwZjL5BmJdnabnMSN0YtxEss5fBmybQICSE455sEmeYRHcmcgAWH(skawsXH7QbCrrowp88Clp3npjP8IngSavrowp88CjVpHip3YtFEFmp8ipgA0EnqaxeR5KY8nMXHgGGgt2tA5PlpD7qJbA0Sd7Hz1yGgnBWEzi)CV(oKgt2tABOUdzvdOQTDO(8WzvBYEsWqdo0xsPrC8hwE)5fBmybQICSE45bDEq(je5jjLN8lgfmt1dt8GZtxE)5Ppp5xmkKnVnmsHIkZ7vaS9GHRgd8ksWbg7RcN5FuEqN3NqKNKuEYVyuiBEByKcfvM3Ray7bdxzfZgsWbg7RcN5FuEqN3NqKNU8KKYl2yWcuf5y9WZZL8GeIDOXanA2Hm0Gd9LuaSKId3vd4BWEzi)4E9DinMSN02qDhYQgqvB7WDOXanA2HMMbdACKIhWkNnyVmKqzV(oKgt2tABOUdzvdOQTDidHJgBaIPXGfOIgL3FE6ZdNvTj7jbdn4qFjLgXXFy5jjLhdH8AOaJGzQEyIICSE455sEqcrE6Y7ppJdkZRGrbOkpOZdkqK3FEmeYRHcmcgAWH(skawsXH7QbCrrowp88CjpiHyhAmqJMDihyf)vyOnyVmKU7E9DinMSN02qDhIG3HCcSdngOrZoeNvTj7PDioZ)ODiX8nmNe9O8VXQ8WJ8(G8wjpJbA0i4aRIDrcAnI9aKc0ouEULNR5rmFdZjrpk)BSkp8ip3nVvYZyGgnIaLbWkO1i2dqkq7q55wEqickVvYJdtEVcRXb0oeNvQXCODOXHD)qviX2G9YqIx713H0yYEsBd1DiRAavTTd1NN(8IngSavrowp88CjVpMNKuE6Zt(fJIYWrd6XvXIMLIVOihRhEEUKhgMMWXwlp8ipg1(80NNXbL5vWOauL3k59je5PlV)8KFXOOmC0GECvSOzP4lEW5PlpD5jjLN(8moOmVcgfGQ8ClpCw1MSNegh29dvHelp8ip5xmkiMVH5KIJ8wjkYX6HNNB5PHaI4RWxHIkY)gsaA2xUQihRN8WJ8csaL8GopidcI8KKYZ4GY8kyuaQYZT8WzvBYEsyCy3pufsS8WJ8KFXOGy(gMtk)BSsuKJ1dpp3YtdbeXxHVcfvK)nKa0SVCvrowp5Hh5fKak5bDEqgee5PlV)8iMVH5KOhLn4N3FE6ZtFEUMhdH8AOaJGzQEyIhCEss5Xq4OXgG4l(vBtE)55AEmeYRHcmcYbgfGkLmA0ep480LNKuEmeoASbiMgdwGkAuE6Ytskp5xmkyMQhMOihRhEEqN3hK3FEUMN8lgfLHJg0JRIfnlfFXdopD7qJbA0Sd5aR4VcdTb7LH8d2RVdPXK9K2gQ7qw1aQABhQpp5xmkiMVH5KY)gRep48KKYtFEmSwHH45TiVGY7pVIyyTcdPaTdLNl5bL80LNKuEmSwHH45TiVpZtxE)5zWkgwI9DhAmqJMD4qbuoi0Sb7LHeV3RVdPXK9K2gQ7qw1aQABhQpp5xmkiMVH5KY)gRep48KKYtFEmSwHH45TiVGY7pVIyyTcdPaTdLNl5bL80LNKuEmSwHH45TiVpZtxE)5zWkgwI9DhAmqJMDiwZhvoi0Sb7LdcI967qAmzpPTH6oKvnGQ22H6Zt(fJcI5ByoP8VXkXdopjP80NhdRvyiEElYlO8(ZRigwRWqkq7q55sEqjpD5jjLhdRvyiEElY7Z80L3FEgSIHLyF3Hgd0OzhgFEVYbHMnyVCqqUxFhAmqJMDyaRQgvkuur(3q7qAmzpPTH6gSxoOG2RVdPXK9K2gQ7qw1aQABhsmFdZjrpk)BSkpjP8iMVH5KGJ8wPgAnqEss5rmFdZjHn4RgAnqEss5j)IrraRQgvkuur(3qIhCE)5rmFdZjrpk)BSkpjP80NN8lgfmt1dtuKJ1dppxYZyGgnIaLbWkO1i2dqkq7q59NN8lgfmt1dt8GZt3o0yGgn7qoWQyx0gSxoOp3RVdngOrZomqzaS7qAmzpPTH6gSxoOpUxFhsJj7jTnu3Hgd0OzhwVrzmqJgLV5GDOV5a1yo0omAEpaB92GnyhQrr75b713ld5E9DOXanA2HCK3kLmzo7qAmzpPTH6gSxoO967qAmzpPTH6oebVd5eyhAmqJMDioRAt2t7qCM)r7qom59kGvyiaxWbwfnVppOZdY8(ZtFEUMhW80aeCGvEuPjOXK9KwEss5bmpnabhqEVvkTQJabnMSN0YtxEss5XHjVxbScdb4coWQO595bDEbTdXzLAmhAh2CLHOnyV8N713H0yYEsBd1DicEhYjWo0yGgn7qCw1MSN2H4m)J2HCyY7vaRWqaUGdSk2fLh05b5oeNvQXCODyZvmpz4OnyV8h3RVdPXK9K2gQ7qw1aQABhQppxZJHWrJnaX0yWcurJYtskpxZJHqEnuGrWqdo0xsbWskoCxnGlEW5PlV)8KFXOGzQEyIh8o0yGgn7qzQ4u9ThmBWEzOSxFhsJj7jTnu3HSQbu12ou(fJcMP6HjEW7qJbA0SdHrGgnBWEz3DV(o0yGgn7WhNunGC47qAmzpPTH6gSxgV2RVdPXK9K2gQ7qw1aQABhIZQ2K9KO5kdr7qoOAgyVmK7qJbA0SdR3OmgOrJY3CWo03CGAmhAhAiAd2l)b713H0yYEsBd1DiRAavTTdR3qruHHeG2HcGQrPvK5i3Jgvc6d9AyysBhYbvZa7LHChAmqJMDy9gLXanAu(Md2H(MduJ5q7qTImh5E0OAd2lJ3713H0yYEsBd1DiRAavTTdR3qruHHeYM3ggPqrL59ka2EWWf0h61WWK2oKdQMb2ld5o0yGgn7W6nkJbA0O8nhSd9nhOgZH2HYidSb7LHeI967qAmzpPTH6oKvnGQ22HEch5Zd68Gce7qJbA0SdR3OmgOrJY3CWo03CGAmhAhYbBWEziHCV(oKgt2tABOUdngOrZoSEJYyGgnkFZb7qFZbQXCODiCrWgGHvXbBWgSd1kYCK7rJQ967LHCV(oKgt2tABOUdrW7qob2Hgd0OzhIZQ2K90oeN5F0ouFEYVyuaAhkaQgLwrMJCpAujkYX6HNh05HHPjCS1Y7ppxZJy(gMtIEu(3yvE)55AEeZ3WCsWrERudTgiV)8CnpI5ByojSbF1qRbYtskp5xmkaTdfavJsRiZrUhnQef5y9WZd68mgOrJGdSk2fjO1i2dqkq7q59NN(84WK3RawHHaCbhyvSlkpOZdY8KKYJy(gMtIEu(3yvEss5rmFdZjbh5Tsn0AG8KKYJy(gMtcBWxn0AG80LNU8KKYZ18KFXOa0ouaunkTImh5E0Os8G3H4SsnMdTd5wKuaK6XjfhM8(nyVCq713H0yYEsBd1DiRAavTTd1NNR5HZQ2K9KGBrsbqQhNuCyY7Ztskp95Ppp5xmkiMVH5KIJ8wjkYX6HNNl5HHPjCS1Y7pp5xmkiMVH5KIJ8wjEW5PlpjP80NN8lgfLHJg0JRIfnlfFrrowp88CjpmmnHJTwE4rEmQ95PppJdkZRGrbOkVvY7tiYtxE)5j)Irrz4Ob94QyrZsXx8GZtxE6YtxE)5Ppp5xmkiMVH5KIJ8wjEW5jjLhX8nmNeCK3k1qRbYtskpI5ByojSbF1qRbYtxEss5zCqzEfmkav5bDE4ne7qJbA0Sd5aR4VcdTb7L)CV(oKgt2tABOUdngOrZo0bHMyx0oKvnGQ22HfflIJ1K9uE)5bScdbeG2HuaKsRP8GopiD38(ZZ18KFXO4BpAfPPihyuaQCObOOHkm9sjXdEhYWN5jfWkmeGVxgYnyV8h3RVdPXK9K2gQ7qJbA0Sd5Vj2fTdzvdOQTDyrXI4ynzpL3FEaRWqabODifaP0AkpOZds3nV)8Cnp5xmk(2JwrAkYbgfGkhAakAOctVus8G3Hm8zEsbScdb47LHCd2ldL967qAmzpPTH6o0yGgn7qoG8ERurVv0oKvnGQ22HfflIJ1K9uE)5bScdbeG2HuaKsRP8GopiD38(ZtFEYVyuWmvpmrrowp88GopiHipjP8Cnp5xmkyMQhM4bNNU8(ZZGvmSe7BE)55AEYVyu8ThTI0uKdmkavo0au0qfMEPK4bVdz4Z8KcyfgcW3ld5gSx2D3RVdPXK9K2gQ7qw1aQABhACqzEfmkav55sE4fe59NN(8KFXOa0ouaunkTImh5E0OsuKJ1dppOZddtt4yRLhEKxq5jjLNR5j)IrbODOaOAuAfzoY9OrL4bNNUDOXanA2HLHJg0JRIfnlf)nyVmETxFhsJj7jTnu3HSQbu12o0GvmSe7BE)55AEYVyuWmvpmXdoV)80NN8lgfG2HcGQrPvK5i3JgvIICSE45bDEyyAchBT8KKYZ18KFXOa0ouaunkTImh5E0Os8GZtxE)5zWkgwI9nV)8Cnp5xmkyMQhM4bN3FE6Zl2yWcuf5y9WZZL8yiKxdfyem0Gd9LuaSKId3vd4IICSE455wE4vEss5fBmybQICSE45TK8G8dGipxYlOGYtskpgc51qbgbdn4qFjfalP4WD1aU4bNNKuEUMhdHJgBaIPXGfOIgLNUDOXanA2HmYtCqBEL5BmJdnGnyV8hSxFhsJj7jTnu3HSQbu12o0GvmSe7BE)55AEYVyuWmvpmXdoV)80NN8lgfG2HcGQrPvK5i3JgvIICSE45bDEyyAchBT8KKYZ18KFXOa0ouaunkTImh5E0Os8GZtxE)5PpVyJblqvKJ1dppxYJHqEnuGrWqdo0xsbWskoCxnGlkYX6HNNB5Hx5jjLxSXGfOkYX6HN3sYdYpaI8CjVpdkpjP8yiKxdfyem0Gd9LuaSKId3vd4IhCEss55AEmeoASbiMgdwGkAuE62Hgd0Ozh2dZQXanA2G9Y49E9DinMSN02qDhYQgqvB7qdwXWsSV7qJbA0SdJOIrkuung4v0gSxgsi2RVdPXK9K2gQ7qw1aQABhk)IrbODOaOAuAfzoY9OrLOihRhEEqNhgMMWXwlV)80Nx0JqvE6ZtFEXgdwGQihRhEE458GeI80L3k5zmqJgfdH8AOatE6Yd68IEeQYtFE6Zl2yWcuf5y9WZdpNhKqKhEopgc51qbgbZu9Wef5y9WZtxERKNXanAumeYRHcm5PlV)80NhX8nmNe9O4iVv5jjLhX8nmNeCK3k1qRbYtskp5xmkyMQhMOihRhEEqNhKqKNKuEYVyuaxTdQ0AZRSIztZuWpp3kboZ)O8GErEbHxqK3FEghuMxbJcqvEqNhuGipD5PBhAmqJMD43E0kstXH7Qb8nyVmKqUxFhsJj7jTnu3Hi4DiNa7qJbA0SdXzvBYEAhIZ8pAhk)IrbC1oOsRnVYkMnntb)8CRe4m)JYZL8c6JqK3FE6ZJHqEnuGrWmvpmrrowp88ClpiHipOZl2yWcuf5y9WZtskpgc51qbgbZu9Wef5y9WZZT8(eI8CjVyJblqvKJ1dpV)8IngSavrowp88Gopi)eI8KKYl2yWcuf5y9WZBj5bzqqKNl5bjuYtskp5xmkyMQhMOihRhEEqNhELNU8(ZJy(gMtIEu2G)oeNvQXCODidn4qFjfdnAnOrZgSxgYG2RVdPXK9K2gQ7qw1aQABhIZQ2K9KGHgCOVKIHgTg0OjV)80NNXbL5vWOauLNl5bfiY7ppCw1MSNenxzikpjP8moOmVcgfGQ8CjVpHipD59NN(8KFXOa0ouaunkTImh5E0OsuKJ1dppOZJwJypaPaTdLNKuEUMN8lgfG2HcGQrPvK5i3JgvIhCE62Hgd0OzhYqdo0xsbWskoCxnGVb7LH8Z967qAmzpPTH6oKvnGQ22HeZ3WCs0JYg8Z7ppdwXWsSV59NhoRAt2tcUfjfaPECsXHjVpV)80NNgcimndg04ifpGvoknZXWqcqZ(2dM8KKYZ18yiC0ydqmeRqEuPLNKuECyY7vaRWqaEEqNxq5PBhAmqJMDy8v4Rqrf5FdTb7LH8J713H0yYEsBd1DiRAavTTd3Hgd0OzhAAgmOXrkEaRC2G9YqcL967qAmzpPTH6oKvnGQ22HUMhdHJgBaIPXGfOIgL3FEmeYRHcmcMP6HjkY0WpV)8moOmVcgfGQ8Gop8cIDOXanA2HCGv8xHH2G9Yq6U713H0yYEsBd1DiRAavTTdziC0ydqmngSav0O8(ZdNvTj7jbdn4qFjfdnAnOrtE)5zCqzEfmkav5b9I8(eI8(ZJHqEnuGrWqdo0xsbWskoCxnGlkYX6HNNl5HHPjCS1YdpYJrTpp95zCqzEfmkav5TsEFcrE62Hgd0OzhYbwXFfgAd2ldjETxFhsJj7jTnu3HSQbu12ouFEYVyuqmFdZjL)nwjEW5jjLN(8yyTcdXZBrEbL3FEfXWAfgsbAhkpxYdk5PlpjP8yyTcdXZBrEFMNU8(ZZGvmSe77o0yGgn7WHcOCqOzd2ld5hSxFhsJj7jTnu3HSQbu12ouFEYVyuqmFdZjL)nwjEW5jjLN(8yyTcdXZBrEbL3FEfXWAfgsbAhkpxYdk5PlpjP8yyTcdXZBrEFMNU8(ZZGvmSe7BE)5Ppp5xmkaTdfavJsRiZrUhnQef5y9WZd68O1i2dqkq7q5jjLNR5j)IrbODOaOAuAfzoY9OrL4bNNUDOXanA2HynFu5GqZgSxgs8EV(oKgt2tABOUdzvdOQTDO(8KFXOGy(gMtk)BSs8GZtskp95XWAfgIN3I8ckV)8kIH1kmKc0ouEUKhuYtxEss5XWAfgIN3I8(mpD59NNbRyyj238(ZtFEYVyuaAhkaQgLwrMJCpAujkYX6HNh05rRrShGuG2HYtskpxZt(fJcq7qbq1O0kYCK7rJkXdopD7qJbA0SdJpVx5GqZgSxoii2RVdngOrZomGvvJkfkQi)BODinMSN02qDd2lheK713H0yYEsBd1DiRAavTTdjMVH5KOhL)nwLNKuEeZ3WCsWrERudTgipjP8iMVH5KWg8vdTgipjP8KFXOiGvvJkfkQi)BiXdoV)8KFXOGy(gMtk)BSs8GZtskp95j)IrbZu9Wef5y9WZZL8mgOrJiqzaScAnI9aKc0ouE)5j)IrbZu9Wep480TdngOrZoKdSk2fTb7LdkO967qJbA0Sdduga7oKgt2tABOUb7Ld6Z967qAmzpPTH6o0yGgn7W6nkJbA0O8nhSd9nhOgZH2HrZ7byR3gSb7qdr713ld5E9DinMSN02qDhYQgqvB7q5xmk4aRIM3lkkwehRj7P8(ZtFEUMx9gkIkmKWJpZkJRIEIa9GrHX3oWCsqFOxddtA5jjLhODO8wsEFek5bDEYVyuWbwfnVxuKJ1dpp3YlO80TdngOrZoKdSkAE)gSxoO967qAmzpPTH6o0yGgn7q(BIDr7qw1aQABhAWkgwI9nV)8iMVH5KOhLn4N3FEfflIJ1K9uE)5bScdbeG2HuaKsRP8Gopi)yE4584WK3RawHHa88ClVICSE47qg(mpPawHHa89YqUb7L)CV(oKgt2tABOUdngOrZo0bHMyx0oKvnGQ22HfflIJ1K9uE)5bScdbeG2HuaKsRP8Gop95b5hZZT80NhhM8EfWkmeGl4aRIDr5Hh5bPak5PlpD5TsECyY7vaRWqaEEULxrowp88(ZtFEmeYRHcmcMP6HjkY0WppjP84WK3RawHHaCbhyvSlkpxY7Z8KKYtFEeZ3WCs0JIJ8wLNKuEeZ3WCs0JsgbWMNKuEeZ3WCs0JY)gRY7ppxZdyEAaco65vOOcGLururCGGgt2tA5PlV)80NhhM8EfWkmeGl4aRIDr55sEqcrE4rE6ZdY8ClpG5Pbiab6r5GqdxqJj7jT80LNU8(ZZ4GY8kyuaQYd68Gce5HNZt(fJcoWQO59IICSE45Hh55U5PlV)8Cnp5xmk(2JwrAkYbgfGkhAakAOctVus8GZ7ppdwXWsSV7qg(mpPawHHa89YqUb7L)4E9DinMSN02qDhYQgqvB7qdwXWsSV7qJbA0SdJOIrkuung4v0gSxgk713H0yYEsBd1DiRAavTTdLFXOGzQEyIh8o0yGgn7WYWrd6XvXIMLI)gSx2D3RVdPXK9K2gQ7qw1aQABhQpp5xmk4aRIM3lEW5jjLNXbL5vWOauLh05bfiYtxE)55AEYVyuWrEoOzK4bN3FEUMN8lgfmt1dt8GZ7pp951dGkyK3aKMk2yWcuf5y9WZZL8yiKxdfyem0Gd9LuaSKId3vd4IICSE455wE4vEss51dGkyK3aKMk2yWcuf5y9WZBj5b5harEUKxqbLNKuEmeYRHcmcgAWH(skawsXH7QbCXdopjP8Cnpgchn2aetJblqfnkpD7qJbA0SdzKN4G28kZ3yghAaBWEz8AV(oKgt2tABOUdzvdOQTDySXGfOkYX6HNNl5bjuYtskp95j)IrbC1oOsRnVYkMnntb)8CRe4m)JYZL8cckqKNKuEYVyuaxTdQ0AZRSIztZuWpp3kboZ)O8GErEbbfiYtxE)5j)Irbhyv08EXdoV)8yiKxdfyemt1dtuKJ1dppOZdkqSdngOrZoShMvJbA0Sb7L)G967qAmzpPTH6o0yGgn7qoG8ERurVv0oKvnGQ22HfflIJ1K9uE)5bAhsbqkTMYd68Gek59NhhM8EfWkmeGl4aRIDr55sEFmV)8myfdlX(M3FE6Zt(fJcMP6HjkYX6HNh05bje5jjLNR5j)IrbZu9Wep480Tdz4Z8KcyfgcW3ld5gSxgV3RVdPXK9K2gQ7qe8oKtGDOXanA2H4SQnzpTdXz(hTdLFXOaUAhuP1MxzfZMMPGFEUvcCM)r55sEbbfiYdpNNXbL5vWOauL3FE6ZJHqEnuGrWmvpmrrowp88ClpiHipOZl2yWcuf5y9WZtskpgc51qbgbZu9Wef5y9WZZT8(eI8CjVyJblqvKJ1dpV)8IngSavrowp88Gopi)eI8KKYt(fJcMP6HjkYX6HNh05Hx5PlV)8iMVH5KOhLn4NNKuEXgdwGQihRhEEljpidcI8CjpiHYoeNvQXCODidn4qFjfdnAnOrZgSxgsi2RVdPXK9K2gQ7qw1aQABhIZQ2K9KGHgCOVKIHgTg0OjV)8moOmVcgfGQ8CjpOaXo0yGgn7qgAWH(skawsXH7Qb8nyVmKqUxFhsJj7jTnu3HSQbu12oKy(gMtIEu2GFE)5zWkgwI9nV)8KFXOaUAhuP1MxzfZMMPGFEUvcCM)r55sEbbfiY7pp95PHactZGbnosXdyLJsZCmmKa0SV9GjpjP8Cnpgchn2aedXkKhvA5jjLhhM8EfWkmeGNh05fuE62Hgd0OzhgFf(kuur(3qBWEzidAV(oKgt2tABOUdngOrZo00myqJJu8aw5SdzvdOQTDOR5bA23EWK3FECyY7vaRWqaUGdSkAEFEUKhEVdz4Z8KcyfgcW3ld5gSxgYp3RVdPXK9K2gQ7qw1aQABhk)IrbAiawUcMkgbdA0iEW59NN(8KFXOGdSkAEVOOyrCSMSNYtskpJdkZRGrbOkpOZdVHipD7qJbA0Sd5aRIM3Vb7LH8J713H0yYEsBd1DiRAavTTdziC0ydqmngSav0O8(ZdNvTj7jbdn4qFjfdnAnOrtE)5XqiVgkWiyObh6lPayjfhURgWff5y9WZZL8WW0eo2A5Hh5XO2NN(8moOmVcgfGQ8wjpOarE6Y7pp5xmk4aRIM3lkkwehRj7PDOXanA2HCGvrZ73G9YqcL967qAmzpPTH6oKvnGQ22HmeoASbiMgdwGkAuE)5HZQ2K9KGHgCOVKIHgTg0OjV)8yiKxdfyem0Gd9LuaSKId3vd4IICSE455sEyyAchBT8WJ8yu7ZtFEghuMxbJcqvERK3NqKNU8(Zt(fJcoWQO59Ih8o0yGgn7qoWk(RWqBWEziD3967qAmzpPTH6oebVd5eyhAmqJMDioRAt2t7qCM)r7qJdkZRGrbOkpOZ7dGip8CE6Zt(fJcoWQO59IICSE45Hh59zERKhhM8EfwJdO80LhEop95PHaI4RWxHIkY)gsuKJ1dpp8ipOKNU8(Zt(fJcoWQO59Ih8oeNvQXCODihyv08Eva0aurZ7vOyCd2ldjETxFhsJj7jTnu3HSQbu12ou(fJc0qaSCfZtwPW18gnIhCEss55AECGvXUiHbRyyj238KKYtFEYVyuWmvpmrrowp88CjpOK3FEYVyuWmvpmXdopjP80NN8lgfLHJg0JRIfnlfFrrowp88CjpmmnHJTwE4rEmQ95PppJdkZRGrbOkVvY7tiYtxE)5j)Irrz4Ob94QyrZsXx8GZtxE6Y7ppCw1MSNeCGvrZ7vbqdqfnVxHIX8(ZJdtEVcyfgcWfCGvrZ7ZZL8(ChAmqJMDihyf)vyOnyVmKFWE9DinMSN02qDhYQgqvB7q95rmFdZjrpkBWpV)8yiKxdfyemt1dtuKJ1dppOZdkqKNKuE6ZJH1kmepVf5fuE)5vedRvyifODO8CjpOKNU8KKYJH1kmepVf59zE6Y7ppdwXWsSV7qJbA0SdhkGYbHMnyVmK49E9DinMSN02qDhYQgqvB7q95rmFdZjrpkBWpV)8yiKxdfyemt1dtuKJ1dppOZdkqKNKuE6ZJH1kmepVf5fuE)5vedRvyifODO8CjpOKNU8KKYJH1kmepVf59zE6Y7ppdwXWsSV7qJbA0SdXA(OYbHMnyVCqqSxFhsJj7jTnu3HSQbu12ouFEeZ3WCs0JYg8Z7ppgc51qbgbZu9Wef5y9WZd68Gce5jjLN(8yyTcdXZBrEbL3FEfXWAfgsbAhkpxYdk5PlpjP8yyTcdXZBrEFMNU8(ZZGvmSe77o0yGgn7W4Z7voi0Sb7LdcY967qJbA0Sddyv1OsHIkY)gAhsJj7jTnu3G9Ybf0E9DinMSN02qDhIG3HCcSdngOrZoeNvTj7PDioZ)ODihM8EfWkmeGl4aRIDr5bDEFqEULx0JqvE6ZZX4aQWxHZ8pkVvYliiYtxEULx0JqvE6Zt(fJcoWk(RWqkYbgfGkhAacoWyFZBL8(yE62H4SsnMdTd5aRIDrQEuCK3QnyVCqFUxFhsJj7jTnu3HSQbu12oKy(gMtc)BSsn0AG8KKYJy(gMtcBWxn0AG8(ZdNvTj7jrZvmpz4O8KKYJy(gMtIEuCK3Q8(ZZ18WzvBYEsWbwf7Iu9O4iVv5jjLN8lgfmt1dtuKJ1dppxYZyGgncoWQyxKGwJypaPaTdL3FEUMhoRAt2tIMRyEYWr59NN8lgfmt1dtuKJ1dppxYJwJypaPaTdL3FEYVyuWmvpmXdopjP8KFXOOmC0GECvSOzP4lEW59NhhM8EfwJdO8GopieUBEss55AE4SQnzpjAUI5jdhL3FEYVyuWmvpmrrowp88GopAnI9aKc0o0o0yGgn7WaLbWUb7Ld6J713Hgd0OzhYbwf7I2H0yYEsBd1nyVCqqzV(oKgt2tABOUdngOrZoSEJYyGgnkFZb7qFZbQXCODy08Ea26TbBWomAEpaB92RVxgY967qAmzpPTH6oKvnGQ22HUMx9gkIkmKq282WifkQmVxbW2dgUG(qVggM02Hgd0OzhYbwXFfgAd2lh0E9DinMSN02qDhAmqJMDi)nXUODiRAavTTd1qaHdcnXUirrowp88GoVICSE47qg(mpPawHHa89YqUb7L)CV(o0yGgn7qheAIDr7qAmzpPTH6gSb7qoyV(Ezi3RVdPXK9K2gQ7qJbA0SdDqOj2fTdzvdOQTDyrXI4ynzpL3FEaRWqabODifaP0AkpOZdYGY7pp95j)IrbZu9Wef5y9WZd68GsE)5Ppp5xmkkdhnOhxflAwk(IICSE45bDEqjpjP8Cnp5xmkkdhnOhxflAwk(IhCE6YtskpxZt(fJcMP6HjEW5jjLNXbL5vWOauLNl59je5PlV)80NNR5j)IrX3E0kstroWOau5qdqrdvy6LsIhCEss5zCqzEfmkav55sEFcrE6Y7ppdwXWsSV7qg(mpPawHHa89YqUb7LdAV(oKgt2tABOUdngOrZoK)Myx0oKvnGQ22HfflIJ1K9uE)5bScdbeG2HuaKsRP8GopidkV)80NN8lgfmt1dtuKJ1dppOZdk59NN(8KFXOOmC0GECvSOzP4lkYX6HNh05bL8KKYZ18KFXOOmC0GECvSOzP4lEW5PlpjP8Cnp5xmkyMQhM4bNNKuEghuMxbJcqvEUK3NqKNU8(ZtFEUMN8lgfF7rRinf5aJcqLdnafnuHPxkjEW5jjLNXbL5vWOauLNl59je5PlV)8myfdlX(Udz4Z8KcyfgcW3ld5gSx(Z967qAmzpPTH6o0yGgn7qoG8ERurVv0oKvnGQ22HfflIJ1K9uE)5bScdbeG2HuaKsRP8GopiD38(ZtFEYVyuWmvpmrrowp88GopOK3FE6Zt(fJIYWrd6XvXIMLIVOihRhEEqNhuYtskpxZt(fJIYWrd6XvXIMLIV4bNNU8KKYZ18KFXOGzQEyIhCEss5zCqzEfmkav55sEFcrE6Y7pp955AEYVyu8ThTI0uKdmkavo0au0qfMEPK4bNNKuEghuMxbJcqvEUK3NqKNU8(ZZGvmSe77oKHpZtkGvyiaFVmKBWE5pUxFhsJj7jTnu3HSQbu12o0GvmSe77o0yGgn7WiQyKcfvJbEfTb7LHYE9DinMSN02qDhYQgqvB7q5xmkyMQhM4bVdngOrZoSmC0GECvSOzP4Vb7LD3967qAmzpPTH6oKvnGQ22H6ZtFEYVyuqmFdZjfh5TsuKJ1dppOZdsiYtskp5xmkiMVH5KY)gRef5y9WZd68GeI80L3FEmeYRHcmcMP6HjkYX6HNh059je59NN(8KFXOaUAhuP1MxzfZMMPGFEUvcCM)r55sEb9riYtskpxZREdfrfgsaxTdQ0AZRSIztZuWpp3kb9HEnmmPLNU80LNKuEYVyuaxTdQ0AZRSIztZuWpp3kboZ)O8GErEbHxqKNKuEmeYRHcmcMP6HjkY0WpV)80NNXbL5vWOauLh05H3qKNKuE4SQnzpjAUYquE62Hgd0Ozh(ThTI0uC4UAaFd2lJx713H0yYEsBd1DiRAavTTd1NNXbL5vWOauLh05H3qK3FE6Zt(fJIV9OvKMICGrbOYHgGIgQW0lLep48KKYZ18yiC0ydq8f)QTjpD5jjLhdHJgBaIPXGfOIgLNKuE4SQnzpjAUYquEss5j)IrHShH08poq8GZ7pp5xmkK9iKM)XbIICSE455sEbbrEULN(80NhENhEKx9gkIkmKaUAhuP1MxzfZMMPGFEUvc6d9AyyslpD55wE6Z7J5Hh5XqJ2Rbc4IynNuMVXmo0ae0yYEslpD5PlpD59NNR5j)IrbZu9Wep48(ZtFEXgdwGQihRhEEUKhdH8AOaJGHgCOVKcGLuC4UAaxuKJ1dpp3YdVYtskVyJblqvKJ1dppxYlOGYZT80NhENhEKN(8KFXOaUAhuP1MxzfZMMPGFEUvcCM)r5bDEqcbe5PlpD5jjLxSXGfOkYX6HN3sYdYpaI8CjVGckpjP8yiKxdfyem0Gd9LuaSKId3vd4IhCEss55AEmeoASbiMgdwGkAuE62Hgd0OzhYipXbT5vMVXmo0a2G9YFWE9DinMSN02qDhYQgqvB7q95zCqzEfmkav5bDE4ne59NN(8KFXO4BpAfPPihyuaQCObOOHkm9sjXdopjP8Cnpgchn2aeFXVABYtxEss5Xq4OXgGyAmybQOr5jjLhoRAt2tIMRmeLNKuEYVyui7rin)Jdep48(Zt(fJczpcP5FCGOihRhEEUK3NqKNB5Ppp95H35Hh5vVHIOcdjGR2bvAT5vwXSPzk4NNBLG(qVggM0YtxEULN(8(yE4rEm0O9AGaUiwZjL5BmJdnabnMSN0YtxE6YtxE)55AEYVyuWmvpmXdoV)80NxSXGfOkYX6HNNl5XqiVgkWiyObh6lPayjfhURgWff5y9WZZT8WR8KKYl2yWcuf5y9WZZL8(mO8Clp95H35Hh5Ppp5xmkGR2bvAT5vwXSPzk4NNBLaN5FuEqNhKqarE6YtxEss5fBmybQICSE45TK8G8dGipxY7ZGYtskpgc51qbgbdn4qFjfalP4WD1aU4bNNKuEUMhdHJgBaIPXGfOIgLNUDOXanA2H9WSAmqJMnyVmEVxFhsJj7jTnu3Hi4DiNa7qJbA0SdXzvBYEAhIZ8pAhYq4OXgGyAmybQOr59NN(8KFXOaUAhuP1MxzfZMMPGFEUvcCM)r55sEb9riY7pp95XqiVgkWiyMQhMOihRhEEULhKqKh05fBmybQICSE45jjLhdH8AOaJGzQEyIICSE455wEFcrEUKxSXGfOkYX6HN3FEXgdwGQihRhEEqNhKFcrEss5j)IrbZu9Wef5y9WZd68WR80L3FEYVyuqmFdZjfh5TsuKJ1dppOZdsiYtskVyJblqvKJ1dpVLKhKbbrEUKhKqjpD7qCwPgZH2Hm0Gd9Lum0O1GgnBWEziHyV(oKgt2tABOUdrW7qob2Hgd0OzhIZQ2K90oeN5F0ouFEUMhdH8AOaJGzQEyIImn8ZtskpxZdNvTj7jbdn4qFjfdnAnOrtE)5Xq4OXgGyAmybQOr5PBhIZk1yo0oKB4ivevkMP6HTb7LHeY967qAmzpPTH6oKvnGQ22H4SQnzpjyObh6lPyOrRbnAY7ppJdkZRGrbOkpxY7ti2Hgd0OzhYqdo0xsbWskoCxnGVb7LHmO967qAmzpPTH6oKvnGQ22HeZ3WCs0JYg8Z7ppdwXWsSV59NN8lgfWv7GkT28kRy20mf8ZZTsGZ8pkpxYlOpcrE)5PppneqyAgmOXrkEaRCuAMJHHeGM9Thm5jjLNR5Xq4OXgGyiwH8OslpD59NhoRAt2tcUHJuruPyMQh2o0yGgn7W4RWxHIkY)gAd2ld5N713H0yYEsBd1DiRAavTTd3Hgd0OzhAAgmOXrkEaRC2G9Yq(X967qAmzpPTH6oKvnGQ22HYVyuGgcGLRGPIrWGgnIhCE)5j)Irbhyv08ErrXI4ynzpTdngOrZoKdSkAE)gSxgsOSxFhsJj7jTnu3HSQbu12ou(fJcoWkpQ0ef5y9WZZL8C38(ZtFEYVyuqmFdZjfh5Ts8GZtskp5xmkiMVH5KY)gRep480L3FEghuMxbJcqvEqNhEdXo0yGgn7qMnmYRKFX4ou(fJQXCODihyLhvABWEziD3967qAmzpPTH6oKvnGQ22HmeoASbiMgdwGkAuE)5HZQ2K9KGHgCOVKIHgTg0OjV)8yiKxdfyem0Gd9LuaSKId3vd4IICSE455sEyyAchBT8WJ8yu7ZtFEghuMxbJcqvERK3NqKNUDOXanA2HCGv8xHH2G9YqIx713H0yYEsBd1DiRAavTTdbMNgGGdiV3kLw1rGGgt2tA59NNR5bmpnabhyLhvAcAmzpPL3FEYVyuWbwfnVxuuSiowt2t59NN(8KFXOGy(gMtk)BSsuKJ1dppOZZDZ7ppI5Byoj6r5FJv59NN8lgfWv7GkT28kRy20mf8ZZTsGZ8pkpxYliOarEss5j)IrbC1oOsRnVYkMnntb)8CRe4m)JYd6f5feuGiV)8moOmVcgfGQ8Gop8gI8KKYtdbeMMbdACKIhWkhLM5yyirrowp88GoVpipjP8mgOrJW0myqJJu8aw5O0mhddj6rf9ngSG80L3FEUMhdH8AOaJGzQEyIImn83Hgd0OzhYbwfnVFd2ld5hSxFhsJj7jTnu3HSQbu12ou(fJc0qaSCfZtwPW18gnIhCEss5j)IrX3E0kstroWOau5qdqrdvy6LsIhCEss5j)IrbZu9Wep48(ZtFEYVyuugoAqpUkw0Su8ff5y9WZZL8WW0eo2A5Hh5XO2NN(8moOmVcgfGQ8wjVpHipD59NN8lgfLHJg0JRIfnlfFXdopjP8Cnp5xmkkdhnOhxflAwk(IhCE)55AEmeYRHcmIYWrd6XvXIMLIVOitd)8KKYZ18yiC0ydqGJgaw8R80LNKuEghuMxbJcqvEqNhEdrE)5rmFdZjrpkBWFhAmqJMDihyf)vyOnyVmK49E9DinMSN02qDhYQgqvB7qG5Pbi4aR8OstqJj7jT8(ZtFEYVyuWbw5rLM4bNNKuEghuMxbJcqvEqNhEdrE6Y7pp5xmk4aR8OstWbg7BEUK3N59NN(8KFXOGy(gMtkoYBL4bNNKuEYVyuqmFdZjL)nwjEW5PlV)8KFXOaUAhuP1MxzfZMMPGFEUvcCM)r55sEbHxqK3FE6ZJHqEnuGrWmvpmrrowp88GopiHipjP8CnpCw1MSNem0Gd9Lum0O1Ggn59NhdHJgBaIPXGfOIgLNUDOXanA2HCGv8xHH2G9YbbXE9DinMSN02qDhYQgqvB7q95j)IrbC1oOsRnVYkMnntb)8CRe4m)JYZL8ccVGipjP8KFXOaUAhuP1MxzfZMMPGFEUvcCM)r55sEbbfiY7ppG5Pbi4aY7TsPvDeiOXK9KwE6Y7pp5xmkiMVH5KIJ8wjkYX6HNh05Hx59NhX8nmNe9O4iVv59NNR5j)IrbAiawUcMkgbdA0iEW59NNR5bmpnabhyLhvAcAmzpPL3FEmeYRHcmcMP6HjkYX6HNh05Hx59NN(8yiKxdfyeF7rRinfhURgWff5y9WZd68WR8KKYZ18yiC0ydq8f)QTjpD7qJbA0Sd5aR4VcdTb7LdcY967qAmzpPTH6oKvnGQ22H6Zt(fJcI5ByoP8VXkXdopjP80NhdRvyiEElYlO8(ZRigwRWqkq7q55sEqjpD5jjLhdRvyiEElY7Z80L3FEgSIHLyFZ7ppCw1MSNeCdhPIOsXmvpSDOXanA2Hdfq5GqZgSxoOG2RVdPXK9K2gQ7qw1aQABhQpp5xmkiMVH5KY)gRep48(ZZ18yiC0ydq8f)QTjpjP80NN8lgfF7rRinf5aJcqLdnafnuHPxkjEW59NhdHJgBaIV4xTn5PlpjP80NhdRvyiEElYlO8(ZRigwRWqkq7q55sEqjpD5jjLhdRvyiEElY7Z8KKYt(fJcMP6HjEW5PlV)8myfdlX(M3FE4SQnzpj4gosfrLIzQEy7qJbA0SdXA(OYbHMnyVCqFUxFhsJj7jTnu3HSQbu12ouFEYVyuqmFdZjL)nwjEW59NNR5Xq4OXgG4l(vBtEss5Ppp5xmk(2JwrAkYbgfGkhAakAOctVus8GZ7ppgchn2aeFXVABYtxEss5PppgwRWq88wKxq59NxrmSwHHuG2HYZL8GsE6YtskpgwRWq88wK3N5jjLN8lgfmt1dt8GZtxE)5zWkgwI9nV)8WzvBYEsWnCKkIkfZu9W2Hgd0OzhgFEVYbHMnyVCqFCV(o0yGgn7WawvnQuOOI8VH2H0yYEsBd1nyVCqqzV(oKgt2tABOUdzvdOQTDiX8nmNe9O8VXQ8KKYJy(gMtcoYBLAO1a5jjLhX8nmNe2GVAO1a5jjLN8lgfbSQAuPqrf5FdjEW59NN8lgfeZ3WCs5FJvIhCEss5Ppp5xmkyMQhMOihRhEEUKNXanAebkdGvqRrShGuG2HY7pp5xmkyMQhM4bNNUDOXanA2HCGvXUOnyVCqU7E9DOXanA2HbkdGDhsJj7jTnu3G9YbHx713H0yYEsBd1DOXanA2H1Bugd0Or5Boyh6BoqnMdTdJM3dWwVnyd2HWfbBagwfhSxFVmK713H0yYEsBd1DOXanA2Hoi0e7I2HSQbu12oSOyrCSMSNY7ppGvyiGa0oKcGuAnLh05bzq59NN(8KFXOGzQEyIICSE45bDEqjpjP8Cnp5xmkyMQhM4bNNKuEghuMxbJcqvEUK3NqKNU8(ZZGvmSe77oKHpZtkGvyiaFVmKBWE5G2RVdPXK9K2gQ7qJbA0Sd5Vj2fTdzvdOQTDyrXI4ynzpL3FEaRWqabODifaP0AkpOZdYGY7pp95j)IrbZu9Wef5y9WZd68GsEss55AEYVyuWmvpmXdopjP8moOmVcgfGQ8CjVpHipD59NNbRyyj23DidFMNuaRWqa(Ezi3G9YFUxFhsJj7jTnu3Hgd0OzhYbK3BLk6TI2HSQbu12oSOyrCSMSNY7ppGvyiGa0oKcGuAnLh05bzq59NN(8KFXOGzQEyIICSE45bDEqjpjP8Cnp5xmkyMQhM4bNNKuEghuMxbJcqvEUK3NqKNU8(ZZGvmSe77oKHpZtkGvyiaFVmKBWE5pUxFhsJj7jTnu3HSQbu12o0GvmSe77o0yGgn7WiQyKcfvJbEfTb7LHYE9DinMSN02qDhYQgqvB7q95zCqzEfmkav5bDE4ne5jjLN8lgfYEesZ)4aXdoV)8KFXOq2JqA(hhikYX6HNNl5fK7MNU8(ZZ18KFXOGzQEyIh8o0yGgn7qg5joOnVY8nMXHgWgSx2D3RVdPXK9K2gQ7qw1aQABhQppJdkZRGrbOkpOZdVHipjP8KFXOq2JqA(hhiEW59NN8lgfYEesZ)4arrowp88CjVpD380L3FEUMN8lgfmt1dt8G3Hgd0Ozh2dZQXanA2G9Y41E9DinMSN02qDhIG3HCcSdngOrZoeNvTj7PDioZ)ODOR5XqiVgkWiyMQhMOitd)DioRuJ5q7qUHJuruPyMQh2gSx(d2RVdPXK9K2gQ7qw1aQABhsmFdZjrpkBWpV)8myfdlX(M3FE4SQnzpj4gosfrLIzQEy7qJbA0SdJVcFfkQi)BOnyVmEVxFhsJj7jTnu3HSQbu12ou(fJcoWkpQ0ef5y9WZZL8C38(ZtFEYVyuqmFdZjfh5Ts8GZtskp5xmkiMVH5KY)gRep480L3FEghuMxbJcqvEqNhEdXo0yGgn7qMnmYRKFX4ou(fJQXCODihyLhvABWEziHyV(oKgt2tABOUdzvdOQTDO(8CnpBPu1asWbfzF7bJIdSIlkB(MNKuEYVyuWmvpmrrowp88CjpAnI9aKc0ouEss55AEWfHtWbwXFfgkpD59NN(8KFXOGzQEyIhCEss5zCqzEfmkav5bDE4ne59NhX8nmNe9OSb)80TdngOrZoKdSI)km0gSxgsi3RVdPXK9K2gQ7qw1aQABhQppxZZwkvnGeCqr23EWO4aR4IYMV5jjLN8lgfmt1dtuKJ1dppxYJwJypaPaTdLNKuEUMhCr4eCGv8xHHYtxE)5bmpnabhyLhvAcAmzpPL3FE6Zt(fJcoWkpQ0ep48KKYZ4GY8kyuaQYd68WBiYtxE)5j)IrbhyLhvAcoWyFZZL8(mV)80NN8lgfeZ3WCsXrERep48KKYt(fJcI5ByoP8VXkXdopD7qJbA0Sd5aR4VcdTb7LHmO967qAmzpPTH6oKvnGQ22H6ZZ18SLsvdibhuK9ThmkoWkUOS5BEss5j)IrbZu9Wef5y9WZZL8O1i2dqkq7q5jjLNR5bxeobhyf)vyO80L3FEYVyuqmFdZjfh5TsuKJ1dppOZdVY7ppI5Byoj6rXrERY7ppxZdyEAacoWkpQ0e0yYEslV)8yiKxdfyemt1dtuKJ1dppOZdV2Hgd0OzhYbwXFfgAd2ld5N713H0yYEsBd1DiRAavTTd1NN8lgfeZ3WCs5FJvIhCEss5PppgwRWq88wKxq59NxrmSwHHuG2HYZL8GsE6YtskpgwRWq88wK3N5PlV)8myfdlX(M3FE4SQnzpj4gosfrLIzQEy7qJbA0SdhkGYbHMnyVmKFCV(oKgt2tABOUdzvdOQTDO(8KFXOGy(gMtk)BSs8GZtskp95XWAfgIN3I8ckV)8kIH1kmKc0ouEUKhuYtxEss5XWAfgIN3I8(mpjP8KFXOGzQEyIhCE6Y7ppdwXWsSV59NhoRAt2tcUHJuruPyMQh2o0yGgn7qSMpQCqOzd2ldju2RVdPXK9K2gQ7qw1aQABhQpp5xmkiMVH5KY)gRep48KKYtFEmSwHH45TiVGY7pVIyyTcdPaTdLNl5bL80LNKuEmSwHH45TiVpZtskp5xmkyMQhM4bNNU8(ZZGvmSe7BE)5HZQ2K9KGB4ivevkMP6HTdngOrZom(8ELdcnBWEziD3967qJbA0Sddyv1OsHIkY)gAhsJj7jTnu3G9YqIx713H0yYEsBd1DiRAavTTd1NNTuQAaj4GISV9GrXbwXfLnFZ7pp5xmkyMQhMOihRhEEqNhTgXEasbAhkV)8GlcNiqzaS5PlpjP80NNR5zlLQgqcoOi7BpyuCGvCrzZ38KKYt(fJcMP6HjkYX6HNNl5rRrShGuG2HYtskpxZdUiCcoWQyxuE6Y7pp95rmFdZjrpk)BSkpjP8iMVH5KGJ8wPgAnqEss5rmFdZjHn4RgAnqEss5j)IrraRQgvkuur(3qIhCE)5j)IrbX8nmNu(3yL4bNNKuE6Zt(fJcMP6HjkYX6HNNl5zmqJgrGYayf0Ae7bifODO8(Zt(fJcMP6HjEW5PlpD5jjLN(8SLsvdiHMfy6bJI)grzZ38GoVGY7pp5xmkiMVH5KIJ8wjkYX6HNh05bL8(ZZ18KFXOqZcm9GrXFJOihRhEEqNNXanAebkdGvqRrShGuG2HYt3o0yGgn7qoWQyx0gSxgYpyV(o0yGgn7WaLbWUdPXK9K2gQBWEziX7967qAmzpPTH6o0yGgn7W6nkJbA0O8nhSd9nhOgZH2HrZ7byR3gSbBWoehv8gn7LdcIGGasiG8J7Wawn9GHVdD)9H7(Cz3hl7(hpLxERJLYRDGrfiViQY7dtRiZrUhnQ(WYROp0RlslpoYHYZEaKJbiT8yyTbdXfzWUxpuEbHNYZDqdoQaKwEHTJ7Khh)byRL3sYdGYZ9EwEAnUM3Ojpemvgav5PFfD5PhY10jYGDVEO8Wl8uEUdAWrfG0YlSDCN844paBT8wYsYdGYZ9EwEoiTN)XZdbtLbqvE6xIU80d5A6ezWUxpuEFaEkp3bn4OcqA5f2oUtEC8hGTwElzj5bq55EplphK2Z)45HGPYaOkp9lrxE6HCnDImy3RhkpiHapLN7GgCubiT8cBh3jpo(dWwlVLKhaLN79S80ACnVrtEiyQmaQYt)k6YtFqRPtKb7E9q5bjK4P8Ch0GJkaPLxy74o5XXFa2A5TKLKhaLN79S8CqAp)JNhcMkdGQ80VeD5PhY10jYGDVEO8G0DXt55oObhvaslVW2XDYJJ)aS1YBj5bq55EplpTgxZB0KhcMkdGQ80VIU80d5A6ezWzWU)(WDFUS7JLD)JNYlV1Xs51oWOcKxev59Hbxed5iBGpS8k6d96I0YJJCO8Sha5yaslpgwBWqCrgS71dLhuWt55oObhvaslVW2XDYJJ)aS1YBj5bq55EplpTgxZB0KhcMkdGQ80VIU80h0A6ezWzWU)(WDFUS7JLD)JNYlV1Xs51oWOcKxev59Hzi6dlVI(qVUiT84ihkp7bqogG0YJH1gmexKb7E9q5bjEkp3bn4OcqA5f2oUtEC8hGTwElzj5bq55EplphK2Z)45HGPYaOkp9lrxE6HCnDImy3RhkVpXt55oObhvaslVW2XDYJJ)aS1YBj5bq55EplpTgxZB0KhcMkdGQ80VIU80d5A6ezWUxpuEUlEkp3bn4OcqA5f2oUtEC8hGTwElzj5bq55EplphK2Z)45HGPYaOkp9lrxE6HCnDImy3Rhkp8cpLN7GgCubiT8cBh3jpo(dWwlVLSK8aO8CVNLNds75F88qWuzauLN(LOlp9qUMorgS71dLhEJNYZDqdoQaKwEHTJ7Khh)byRL3swsEauEU3ZYZbP98pEEiyQmaQYt)s0LNEixtNid296HYdYpINYZDqdoQaKwEHTJ7Khh)byRL3sYdGYZ9EwEAnUM3Ojpemvgav5PFfD5PhY10jYGDVEO8Gek4P8Ch0GJkaPLxy74o5XXFa2A5TK8aO8CVNLNwJR5nAYdbtLbqvE6xrxE6HCnDImy3RhkpiDx8uEUdAWrfG0YlSDCN844paBT8wsEauEU3ZYtRX18gn5HGPYaOkp9ROlp9qUMorgS71dLhK4fEkp3bn4OcqA5f2oUtEC8hGTwEljpakp37z5P14AEJM8qWuzauLN(v0LNEixtNid296HYlOGWt55oObhvaslVW2XDYJJ)aS1YBj5bq55EplpTgxZB0KhcMkdGQ80VIU80h0A6ezWzWU)(WDFUS7JLD)JNYlV1Xs51oWOcKxev59HXbFy5v0h61fPLhh5q5zpaYXaKwEmS2GH4Imy3Rhkp8cpLN7GgCubiT8cBh3jpo(dWwlVLSK8aO8CVNLNds75F88qWuzauLN(LOlp9qUMorgS71dL3hGNYZDqdoQaKwEHTJ7Khh)byRL3swsEauEU3ZYZbP98pEEiyQmaQYt)s0LNEixtNid296HYdVXt55oObhvaslVW2XDYJJ)aS1YBjljpakp37z55G0E(hppemvgav5PFj6YtpKRPtKb7E9q5bP7INYZDqdoQaKwEHTJ7Khh)byRL3sYdGYZ9EwEAnUM3Ojpemvgav5PFfD5PhY10jYGDVEO8G8dWt55oObhvaslVW2XDYJJ)aS1YBj5bq55EplpTgxZB0KhcMkdGQ80VIU80d5A6ezWzWU)(WDFUS7JLD)JNYlV1Xs51oWOcKxev59HjJmWhwEf9HEDrA5XrouE2dGCmaPLhdRnyiUid296HYdsiXt55oObhvaslVW2XDYJJ)aS1YBjljpakp37z55G0E(hppemvgav5PFj6YtpKRPtKb7E9q5bP7INYZDqdoQaKwEHTJ7Khh)byRL3sYdGYZ9EwEAnUM3Ojpemvgav5PFfD5P)Z10jYGDVEO8GeVWt55oObhvaslVW2XDYJJ)aS1YBj5bq55EplpTgxZB0KhcMkdGQ80VIU80d5A6ezWzWUpCGrfG0Y7dYZyGgn55BoGlYG3HCyITxgsicAhcxOy7PDO7BEq182WO8C)UETwgS7BEUFHbqYuLhKFC18ccIGGidod29np3bRnyioEkd29np8CEF4AAKwEHiVv5bvYCezWUV5HNZZDWAdgslpGvyiGQJ5XmoXZdGYJHpZtkGvyiaxKb7(MhEop3NKdchPL3BgIrCUv4NhoRAt2t8803csSAEWfHtXbwXFfgkp8m05bxeobhyf)vyiDIm4myJbA0WfWfXqoYgyHdcnF7rfrLtgSXanA4c4Iyihzd42IvcugaBgSXanA4c4Iyihzd42IvcugaBgSXanA4c4Iyihzd42Iv4aR4VcdTAhxWHjVxbScdb4coWQO59U8XmyJbA0WfWfXqoYgWTfRGZQ2K90QJ5qlyObh6lP0io(dBvCM)rlKrC(F0JqLE9XgdwGQihRhoEoii0TeidccDqh9iuPxFSXGfOkYX6HJNdck4z9qcbEampnarpmRgd0OrqJj7jnD4z9FepyOr71abCrSMtkZ3yghAacAmzpPPt3sG8dGqxgCgS7BEUFDnI9aKwEeoQWppq7q5bWs5zmaQYR55z4S2BYEsKbBmqJg(coYBLsMmNmyJbA0WDBXk4SQnzpT6yo0IMRmeTkoZ)OfCyY7vaRWqaUGdSkAEp0q(R3vG5Pbi4aR8OstqJj7jnjjG5Pbi4aY7TsPvDeiOXK9KMojjom59kGvyiaxWbwfnVh6GYGngOrd3TfRGZQ2K90QJ5qlAUI5jdhTkoZ)OfCyY7vaRWqaUGdSk2fbnKzWgd0OH72IvKPIt13EWSAhxO3vgchn2aetJblqfnssYvgc51qbgbdn4qFjfalP4WD1aU4bR7x(fJcMP6HjEWzWgd0OH72IvGrGgnR2XfYVyuWmvpmXdod2yGgnC3wSYJtQgqo8myJbA0WDBXk1Bugd0Or5Boy1XCOfgIwLdQMbwa5QDCboRAt2tIMRmeLbBmqJgUBlwPEJYyGgnkFZbRoMdTqRiZrUhnQwLdQMbwa5QDCr9gkIkmKa0ouaunkTImh5E0OsqFOxddtAzWgd0OH72IvQ3OmgOrJY3CWQJ5qlKrgyvoOAgybKR2Xf1BOiQWqczZBdJuOOY8EfaBpy4c6d9Ayysld2yGgnC3wSs9gLXanAu(MdwDmhAbhSAhx4jCKhAOargSXanA4UTyL6nkJbA0O8nhS6yo0c4IGnadRIdYGZGngOrdxyiAbhyv08(v74c5xmk4aRIM3lkkwehRj7PF9UwVHIOcdj84ZSY4QONiqpyuy8TdmNe0h61WWKMKeODOLSKpcfOLFXOGdSkAEVOihRhUBbPld2yGgnCHHi3wSc)nXUOvz4Z8KcyfgcWxa5QDCHbRyyj23FI5Byoj6rzd()fflIJ1K90pWkmeqaAhsbqkTMGgYpIN5WK3RawHHaC3kYX6HNbBmqJgUWqKBlwXbHMyx0Qm8zEsbScdb4lGC1oUOOyrCSMSN(bwHHacq7qkasP1e06H8JUPNdtEVcyfgcWfCGvXUi8asbu0PBjCyY7vaRWqaUBf5y9W)1ZqiVgkWiyMQhMOitdFjjom59kGvyiaxWbwf7IC5tjj9eZ3WCs0JIJ8wjjrmFdZjrpkzeaRKeX8nmNe9O8VXQFxbMNgGGJEEfkQayjvevehiOXK9KMUF9CyY7vaRWqaUGdSk2f5cKqGh6H0nG5Pbiab6r5GqdxqJj7jnD6(noOmVcgfGkOHce4z5xmk4aRIM3lkYX6HJhURUFxLFXO4BpAfPPihyuaQCObOOHkm9sjXd(3GvmSe7BgSXanA4cdrUTyLiQyKcfvJbEfTAhxyWkgwI9nd2yGgnCHHi3wSsz4Ob94QyrZsXF1oUq(fJcMP6HjEWzWgd0OHlme52IvyKN4G28kZ3yghAaR2Xf6LFXOGdSkAEV4bljzCqzEfmkavqdfi097Q8lgfCKNdAgjEW)Uk)IrbZu9Wep4F99aOcg5naPPIngSavrowpCxyiKxdfyem0Gd9LuaSKId3vd4IICSE4UHxss9aOcg5naPPIngSavrowp8LSei)aiCjOGKKyiKxdfyem0Gd9LuaSKId3vd4IhSKKRmeoASbiMgdwGkAKUmyJbA0WfgICBXk9WSAmqJMv74c9YVyuWbwfnVx8GLKmoOmVcgfGkOHce6(Dv(fJcoYZbnJep4FxLFXOGzQEyIh8V(EaubJ8gG0uXgdwGQihRhUlmeYRHcmcgAWH(skawsXH7QbCrrowpC3WljPEaubJ8gG0uXgdwGQihRh(swcKFaeU8zqssmeYRHcmcgAWH(skawsXH7QbCXdwsYvgchn2aetJblqfnsNXanA4cdrUTyLV9OvKMId3vd4R2XfXgdwGQihRhUlqcfjj9YVyuaxTdQ0AZRSIztZuWpp3kboZ)ixcckqijj)IrbC1oOsRnVYkMnntb)8CRe4m)JGErqqbcD)YVyuWbwfnVx8G)ziKxdfyemt1dtuKJ1dhAOargSXanA4cdrUTyfoG8ERurVv0Qm8zEsbScdb4lGC1oUOOyrCSMSN(bTdPaiLwtqdju(5WK3RawHHaCbhyvSlYLp(BWkgwI99xV8lgfmt1dtuKJ1dhAiHqsYv5xmkyMQhM4bRld2yGgnCHHi3wScoRAt2tRoMdTGHgCOVKIHgTg0OzvCM)rlKFXOaUAhuP1MxzfZMMPGFEUvcCM)rUeeuGapBCqzEfmkav)6ziKxdfyemt1dtuKJ1d3niHa6yJblqvKJ1dxsIHqEnuGrWmvpmrrowpC3(ecxIngSavrowp8)yJblqvKJ1dhAi)ecjj5xmkyMQhMOihRho04LUFI5Byoj6rzd(ssXgdwGQihRh(swcKbbHlqcLmyJbA0WfgICBXkm0Gd9LuaSKId3vd4R2Xf4SQnzpjyObh6lPyOrRbnA(noOmVcgfGkxGcezWgd0OHlme52IvIVcFfkQi)BOv74cI5Byoj6rzd()gSIHLyF)LFXOaUAhuP1MxzfZMMPGFEUvcCM)rUeeuG4xVgcimndg04ifpGvoknZXWqcqZ(2dgjjxziC0ydqmeRqEuPjjXHjVxbScdb4qhKUmyJbA0WfgICBXkMMbdACKIhWkNvz4Z8KcyfgcWxa5QDCHRGM9Thm)CyY7vaRWqaUGdSkAEVl4DgSXanA4cdrUTyfoWQO59R2XfYVyuGgcGLRGPIrWGgnIh8VE5xmk4aRIM3lkkwehRj7jjjJdkZRGrbOcA8gcDzWgd0OHlme52Iv4aRIM3VAhxWq4OXgGyAmybQOr)4SQnzpjyObh6lPyOrRbnA(ziKxdfyem0Gd9LuaSKId3vd4IICSE4UGHPjCS1Wdg1E9ghuMxbJcq1sGce6(LFXOGdSkAEVOOyrCSMSNYGngOrdxyiYTfRWbwXFfgA1oUGHWrJnaX0yWcurJ(XzvBYEsWqdo0xsXqJwdA08ZqiVgkWiyObh6lPayjfhURgWff5y9WDbdtt4yRHhmQ96noOmVcgfGQL8je6(LFXOGdSkAEV4bNbBmqJgUWqKBlwbNvTj7PvhZHwWbwfnVxfanav08EfkgxfN5F0cJdkZRGrbOc6pac8SE5xmk4aRIM3lkYX6HJhFUeom59kSghq6WZ61qar8v4Rqrf5FdjkYX6HJhqr3V8lgfCGvrZ7fp4myJbA0WfgICBXkCGv8xHHwTJlKFXOanealxX8KvkCnVrJ4blj5khyvSlsyWkgwI9vssV8lgfmt1dtuKJ1d3fO8l)IrbZu9Wepyjj9YVyuugoAqpUkw0Su8ff5y9WDbdtt4yRHhmQ96noOmVcgfGQL8je6(LFXOOmC0GECvSOzP4lEW609JZQ2K9KGdSkAEVkaAaQO59kum(ZHjVxbScdb4coWQO59U8zgSXanA4cdrUTyLHcOCqOz1oUqpX8nmNe9OSb)Fgc51qbgbZu9Wef5y9WHgkqijPNH1kmeFrq)fXWAfgsbAhYfOOtsIH1kmeFXN6(nyfdlX(MbBmqJgUWqKBlwbR5JkheAwTJl0tmFdZjrpkBW)NHqEnuGrWmvpmrrowpCOHcess6zyTcdXxe0FrmSwHHuG2HCbk6KKyyTcdXx8PUFdwXWsSVzWgd0OHlme52IvIpVx5GqZQDCHEI5Byoj6rzd()meYRHcmcMP6HjkYX6HdnuGqsspdRvyi(IG(lIH1kmKc0oKlqrNKedRvyi(Ip19BWkgwI9nd2yGgnCHHi3wSsaRQgvkuur(3qzWgd0OHlme52IvWzvBYEA1XCOfCGvXUivpkoYB1Q4m)JwWHjVxbScdb4coWQyxe0FGBrpcv6DmoGk8v4m)JwsqqOZTOhHk9YVyuWbwXFfgsroWOau5qdqWbg77s(OUmyJbA0WfgICBXkbkdGD1oUGy(gMtc)BSsn0AajjI5ByojSbF1qRb(XzvBYEs0CfZtgossIy(gMtIEuCK3QFxXzvBYEsWbwf7Iu9O4iVvssYVyuWmvpmrrowpCxmgOrJGdSk2fjO1i2dqkq7q)UIZQ2K9KO5kMNmC0V8lgfmt1dtuKJ1d3fAnI9aKc0o0V8lgfmt1dt8GLKKFXOOmC0GECvSOzP4lEW)CyY7vynoGGgcH7kj5koRAt2tIMRyEYWr)YVyuWmvpmrrowpCOP1i2dqkq7qzWgd0OHlme52Iv4aRIDrzWgd0OHlme52IvQ3OmgOrJY3CWQJ5qlIM3dWwVm4myJbA0WfYidSOmC0GECvSOzP4VAhxi)IrbZu9Wep4myJbA0WfYid42IvWzvBYEA1XCOfSQbdc8GxfN5F0cxLFXOq282WifkQmVxbW2dgUAmWRiXd(3v5xmkKnVnmsHIkZ7vaS9GHRSIzdjEWzWgd0OHlKrgWTfRWSHrEL8lgxDmhAbhyLhvAR2XfYVyuWbw5rLMOihRhUlqcLF9YVyuiBEByKcfvM3Ray7bdxng4vKOihRho0Fuafjj5xmkKnVnmsHIkZ7vaS9GHRSIzdjkYX6Hd9hfqr3VXbL5vWOaub9c3fIF9meYRHcmcMP6HjkYX6HdnEjjPNHqEnuGrqoWOauPKrJMOihRho041VRYVyu8ThTI0uKdmkavo0au0qfMEPK4b)Zq4OXgG4l(vBJoDzWgd0OHlKrgWTfRWbwXFfgA1oUWvCw1MSNeSQbdc8G)1R3vgc51qbgbdn4qFjfalP4WD1aU4blj5koRAt2tcgAWH(skgA0AqJgjjxziC0ydqmngSav0iD)6ziC0ydqmngSav0ijj9meYRHcmcMP6HjkYX6HdnEjjPNHqEnuGrqoWOauPKrJMOihRho041VRYVyu8ThTI0uKdmkavo0au0qfMEPK4b)Zq4OXgG4l(vBJoD60jjPNHqEnuGrWqdo0xsbWskoCxnGlEW)meYRHcmcMP6HjkY0W)NHWrJnaX0yWcurJ0LbBmqJgUqgza3wSc)nXUOvz4Z8KcyfgcWxa5QDCrrXI4ynzp9dScdbeG2HuaKsRjOH0D)nyfdlX((RhNvTj7jbRAWGapyjj9ghuMxbJcqLlFcXVRYVyuWmvpmXdwNKedH8AOaJGzQEyIImn81LbBmqJgUqgza3wSIdcnXUOvz4Z8KcyfgcWxa5QDCrrXI4ynzp9dScdbeG2HuaKsRjOH8tbu(nyfdlX((RhNvTj7jbRAWGapyjj9ghuMxbJcqLlFcXVRYVyuWmvpmXdwNKedH8AOaJGzQEyIImn8197Q8lgfF7rRinf5aJcqLdnafnuHPxkjEWzWgd0OHlKrgWTfRWbK3BLk6TIwLHpZtkGvyiaFbKR2XffflIJ1K90pWkmeqaAhsbqkTMGgs31TICSE4)gSIHLyF)1JZQ2K9KGvnyqGhSKKXbL5vWOau5YNqijXqiVgkWiyMQhMOitdFDzWgd0OHlKrgWTfRerfJuOOAmWROv74cdwXWsSVzWgd0OHlKrgWTfReFf(kuur(3qR2Xf6jMVH5KOhLn4ljrmFdZjbh5Ts1JcsjjI5Byoj8VXkvpki19R3vgchn2aetJblqfnsssVXbL5vWOau5cEdLF94SQnzpjyvdge4bljzCqzEfmkavU8jess4SQnzpjAUYqKUF94SQnzpjyObh6lP0io(d73vgc51qbgbdn4qFjfalP4WD1aU4blj5koRAt2tcgAWH(sknIJ)W(DLHqEnuGrWmvpmXdwNoD)6ziKxdfyemt1dtuKJ1dh6pHqsY4GY8kyuaQGgVH4NHqEnuGrWmvpmXd(xpdH8AOaJGCGrbOsjJgnrrowpCxmgOrJGdSk2fjO1i2dqkq7qssUYq4OXgG4l(vBJojPyJblqvKJ1d3fiHq3VEneqyAgmOXrkEaRCuAMJHHef5y9WH(JssUYq4OXgGyiwH8OstxgSXanA4czKbCBXkF7rRinfhURgWxTJl0tmFdZjH)nwPgAnGKeX8nmNeCK3k1qRbKKiMVH5KWg8vdTgqss(fJczZBdJuOOY8EfaBpy4QXaVIef5y9WH(JcOijj)IrHS5THrkuuzEVcGThmCLvmBirrowpCO)OakssghuMxbJcqf04ne)meYRHcmcMP6HjkY0Wx3VEgc51qbgbZu9Wef5y9WH(tiKKyiKxdfyemt1dtuKPHVojPyJblqvKJ1d3fiHid2yGgnCHmYaUTyfg5joOnVY8nMXHgWQDCHEJdkZRGrbOcA8gIF9YVyu8ThTI0uKdmkavo0au0qfMEPK4blj5kdHJgBaIV4xTn6KKyiC0ydqmngSav0ijj5xmkK9iKM)XbIh8V8lgfYEesZ)4arrowpCxccc30)r8GHgTxdeWfXAoPmFJzCObiOXK9KMoD)6DLHWrJnaX0yWcurJKKyiKxdfyem0Gd9LuaSKId3vd4IhSKuSXGfOkYX6H7cdH8AOaJGHgCOVKcGLuC4UAaxuKJ1d3n3vsk2yWcuf5y9WxYsG8dGWLGGWn9FepyOr71abCrSMtkZ3yghAacAmzpPPtxgSXanA4czKbCBXk9WSAmqJMv74c9ghuMxbJcqf04ne)6LFXO4BpAfPPihyuaQCObOOHkm9sjXdwsYvgchn2aeFXVAB0jjXq4OXgGyAmybQOrssYVyui7rin)Jdep4F5xmkK9iKM)XbIICSE4U8jeUP)J4bdnAVgiGlI1Csz(gZ4qdqqJj7jnD6(17kdHJgBaIPXGfOIgjjXqiVgkWiyObh6lPayjfhURgWfpyjjCw1MSNem0Gd9LuAeh)H9hBmybQICSE4qd5haHBbbHB6)iEWqJ2Rbc4IynNuMVXmo0ae0yYEstNKuSXGfOkYX6H7cdH8AOaJGHgCOVKcGLuC4UAaxuKJ1d3n3vsk2yWcuf5y9WD5tiCt)hXdgA0EnqaxeR5KY8nMXHgGGgt2tA60LbBmqJgUqgza3wScdn4qFjfalP4WD1a(QDCHECw1MSNem0Gd9LuAeh)H9hBmybQICSE4qd5Nqijj)IrbZu9WepyD)6LFXOq282WifkQmVxbW2dgUAmWRibhySVkCM)rq)jessYVyuiBEByKcfvM3Ray7bdxzfZgsWbg7RcN5Fe0FcHojPyJblqvKJ1d3fiHid2yGgnCHmYaUTyftZGbnosXdyLZQDCrgSXanA4czKbCBXkCGv8xHHwTJlyiC0ydqmngSav0OF94SQnzpjyObh6lP0io(dtsIHqEnuGrWmvpmrrowpCxGecD)ghuMxbJcqf0qbIFgc51qbgbdn4qFjfalP4WD1aUOihRhUlqcrgSXanA4czKbCBXk4SQnzpT6yo0cJd7(HQqITkoZ)OfeZ3WCs0JY)gRWJpyjgd0OrWbwf7Ie0Ae7bifODi3CLy(gMtIEu(3yfE4UlXyGgnIaLbWkO1i2dqkq7qUbHiOLWHjVxH14akd2yGgnCHmYaUTyfoWk(RWqR2Xf61hBmybQICSE4U8rjj9YVyuugoAqpUkw0Su8ff5y9WDbdtt4yRHhmQ96noOmVcgfGQL8je6(LFXOOmC0GECvSOzP4lEW60jjP34GY8kyuaQCdNvTj7jHXHD)qviXWd5xmkiMVH5KIJ8wjkYX6H7MgciIVcFfkQi)BibOzF5QICSEWJGeqbAidccjjJdkZRGrbOYnCw1MSNegh29dvHedpKFXOGy(gMtk)BSsuKJ1d3nneqeFf(kuur(3qcqZ(Yvf5y9GhbjGc0qgee6(jMVH5KOhLn4)RxVRmeYRHcmcMP6HjEWssmeoASbi(IF1287kdH8AOaJGCGrbOsjJgnXdwNKedHJgBaIPXGfOIgPtss(fJcMP6HjkYX6Hd9h87Q8lgfLHJg0JRIfnlfFXdwxgSXanA4czKbCBXkdfq5GqZQDCHE5xmkiMVH5KY)gRepyjj9mSwHH4lc6VigwRWqkq7qUafDssmSwHH4l(u3VbRyyj23myJbA0WfYid42IvWA(OYbHMv74c9YVyuqmFdZjL)nwjEWss6zyTcdXxe0FrmSwHHuG2HCbk6KKyyTcdXx8PUFdwXWsSVzWgd0OHlKrgWTfReFEVYbHMv74c9YVyuqmFdZjL)nwjEWss6zyTcdXxe0FrmSwHHuG2HCbk6KKyyTcdXx8PUFdwXWsSVzWgd0OHlKrgWTfReWQQrLcfvK)nugSXanA4czKbCBXkCGvXUOv74cI5Byoj6r5FJvsseZ3WCsWrERudTgqsIy(gMtcBWxn0Aajj5xmkcyv1OsHIkY)gs8G)jMVH5KOhL)nwjjPx(fJcMP6HjkYX6H7IXanAebkdGvqRrShGuG2H(LFXOGzQEyIhSUmyJbA0WfYid42IvcugaBgSXanA4czKbCBXk1Bugd0Or5Boy1XCOfrZ7byRxgCgSXanA4cTImh5E0OAboRAt2tRoMdTGBrsbqQhNuCyY7xfN5F0c9YVyuaAhkaQgLwrMJCpAujkYX6HdngMMWXw73vI5Byoj6r5FJv)UsmFdZjbh5Tsn0AGFxjMVH5KWg8vdTgqss(fJcq7qbq1O0kYCK7rJkrrowpCOngOrJGdSk2fjO1i2dqkq7q)65WK3RawHHaCbhyvSlcAiLKiMVH5KOhL)nwjjrmFdZjbh5Tsn0AajjI5ByojSbF1qRb0PtsYv5xmkaTdfavJsRiZrUhnQep4myJbA0WfAfzoY9OrLBlwHdSI)km0QDCHExXzvBYEsWTiPai1Jtkom59ss61l)IrbX8nmNuCK3krrowpCxWW0eo2A)YVyuqmFdZjfh5Ts8G1jjPx(fJIYWrd6XvXIMLIVOihRhUlyyAchBn8GrTxVXbL5vWOauTKpHq3V8lgfLHJg0JRIfnlfFXdwNoD)6LFXOGy(gMtkoYBL4bljrmFdZjbh5Tsn0AajjI5ByojSbF1qRb0jjzCqzEfmkavqJ3qKbBmqJgUqRiZrUhnQCBXkoi0e7IwLHpZtkGvyiaFbKR2XffflIJ1K90pWkmeqaAhsbqkTMGgs393v5xmk(2JwrAkYbgfGkhAakAOctVus8GZGngOrdxOvK5i3JgvUTyf(BIDrRYWN5jfWkmeGVaYv74IIIfXXAYE6hyfgciaTdPaiLwtqdP7(7Q8lgfF7rRinf5aJcqLdnafnuHPxkjEWzWgd0OHl0kYCK7rJk3wSchqEVvQO3kAvg(mpPawHHa8fqUAhxuuSiowt2t)aRWqabODifaP0AcAiD3F9YVyuWmvpmrrowpCOHecjjxLFXOGzQEyIhSUFdwXWsSV)Uk)IrX3E0kstroWOau5qdqrdvy6LsIhCgSXanA4cTImh5E0OYTfRugoAqpUkw0Su8xTJlmoOmVcgfGkxWli(1l)IrbODOaOAuAfzoY9OrLOihRho0yyAchBn8iijjxLFXOa0ouaunkTImh5E0Os8G1LbBmqJgUqRiZrUhnQCBXkmYtCqBEL5BmJdnGv74cdwXWsSV)Uk)IrbZu9Wep4F9YVyuaAhkaQgLwrMJCpAujkYX6HdngMMWXwtsYv5xmkaTdfavJsRiZrUhnQepyD)gSIHLyF)Dv(fJcMP6HjEW)6JngSavrowpCxyiKxdfyem0Gd9LuaSKId3vd4IICSE4UHxssXgdwGQihRh(swcKFaeUeuqssmeYRHcmcgAWH(skawsXH7QbCXdwsYvgchn2aetJblqfnsxgSXanA4cTImh5E0OYTfR0dZQXanAwTJlmyfdlX((7Q8lgfmt1dt8G)1l)IrbODOaOAuAfzoY9OrLOihRho0yyAchBnjjxLFXOa0ouaunkTImh5E0Os8G19Rp2yWcuf5y9WDHHqEnuGrWqdo0xsbWskoCxnGlkYX6H7gEjjfBmybQICSE4lzjq(bq4YNbjjXqiVgkWiyObh6lPayjfhURgWfpyjjxziC0ydqmngSav0iDzWgd0OHl0kYCK7rJk3wSsevmsHIQXaVIwTJlmyfdlX(MbBmqJgUqRiZrUhnQCBXkF7rRinfhURgWxTJlKFXOa0ouaunkTImh5E0OsuKJ1dhAmmnHJT2V(OhHk96JngSavrowpC8mKqOBjmeYRHcm6Go6rOsV(yJblqvKJ1dhpdje4zgc51qbgbZu9Wef5y9W1Tegc51qbgD)6jMVH5KOhfh5TssIy(gMtcoYBLAO1assYVyuWmvpmrrowpCOHecjj5xmkGR2bvAT5vwXSPzk4NNBLaN5Fe0lccVG434GY8kyuaQGgkqOtxgSXanA4cTImh5E0OYTfRGZQ2K90QJ5qlyObh6lPyOrRbnAwfN5F0c5xmkGR2bvAT5vwXSPzk4NNBLaN5FKlb9ri(1ZqiVgkWiyMQhMOihRhUBqcb0XgdwGQihRhUKedH8AOaJGzQEyIICSE4U9jeUeBmybQICSE4)XgdwGQihRho0q(jessXgdwGQihRh(swcKbbHlqcfjj5xmkyMQhMOihRho04LUFI5Byoj6rzd(zWgd0OHl0kYCK7rJk3wScdn4qFjfalP4WD1a(QDCboRAt2tcgAWH(skgA0AqJMF9ghuMxbJcqLlqbIFCw1MSNenxzissY4GY8kyuaQC5ti09Rx(fJcq7qbq1O0kYCK7rJkrrowpCOP1i2dqkq7qssUk)IrbODOaOAuAfzoY9OrL4bRld2yGgnCHwrMJCpAu52IvIVcFfkQi)BOv74cI5Byoj6rzd()gSIHLyF)XzvBYEsWTiPai1Jtkom59)61qaHPzWGghP4bSYrPzoggsaA23EWij5kdHJgBaIHyfYJknjjom59kGvyiah6G0LbBmqJgUqRiZrUhnQCBXkMMbdACKIhWkNv74ImyJbA0WfAfzoY9OrLBlwHdSI)km0QDCHRmeoASbiMgdwGkA0pdH8AOaJGzQEyIImn8)noOmVcgfGkOXliYGngOrdxOvK5i3JgvUTyfoWk(RWqR2XfmeoASbiMgdwGkA0poRAt2tcgAWH(skgA0AqJMFJdkZRGrbOc6fFcXpdH8AOaJGHgCOVKcGLuC4UAaxuKJ1d3fmmnHJTgEWO2R34GY8kyuaQwYNqOld2yGgnCHwrMJCpAu52IvgkGYbHMv74c9YVyuqmFdZjL)nwjEWss6zyTcdXxe0FrmSwHHuG2HCbk6KKyyTcdXx8PUFdwXWsSVzWgd0OHl0kYCK7rJk3wScwZhvoi0SAhxOx(fJcI5ByoP8VXkXdwsspdRvyi(IG(lIH1kmKc0oKlqrNKedRvyi(Ip19BWkgwI99xV8lgfG2HcGQrPvK5i3JgvIICSE4qtRrShGuG2HKKCv(fJcq7qbq1O0kYCK7rJkXdwxgSXanA4cTImh5E0OYTfReFEVYbHMv74c9YVyuqmFdZjL)nwjEWss6zyTcdXxe0FrmSwHHuG2HCbk6KKyyTcdXx8PUFdwXWsSV)6LFXOa0ouaunkTImh5E0OsuKJ1dhAAnI9aKc0oKKKRYVyuaAhkaQgLwrMJCpAujEW6YGngOrdxOvK5i3JgvUTyLawvnQuOOI8VHYGngOrdxOvK5i3JgvUTyfoWQyx0QDCbX8nmNe9O8VXkjjI5Byoj4iVvQHwdijrmFdZjHn4RgAnGKK8lgfbSQAuPqrf5FdjEW)YVyuqmFdZjL)nwjEWss6LFXOGzQEyIICSE4UymqJgrGYayf0Ae7bifODOF5xmkyMQhM4bRld2yGgnCHwrMJCpAu52IvcugaBgSXanA4cTImh5E0OYTfRuVrzmqJgLV5GvhZHwenVhGTEzWzWgd0OHlIM3dWwVfCGv8xHHwTJlCTEdfrfgsiBEByKcfvM3Ray7bdxqFOxddtAzWgd0OHlIM3dWwp3wSc)nXUOvz4Z8KcyfgcWxa5QDCHgciCqOj2fjkYX6HdDrowp8myJbA0WfrZ7byRNBlwXbHMyxugCgSXanA4c4IGnadRIdw4GqtSlAvg(mpPawHHa8fqUAhxuuSiowt2t)aRWqabODifaP0AcAid6xV8lgfmt1dtuKJ1dhAOij5Q8lgfmt1dt8GLKmoOmVcgfGkx(ecD)gSIHLyFZGngOrdxaxeSbyyvCGBlwH)Myx0Qm8zEsbScdb4lGC1oUOOyrCSMSN(bwHHacq7qkasP1e0qg0VE5xmkyMQhMOihRho0qrsYv5xmkyMQhM4bljzCqzEfmkavU8je6(nyfdlX(MbBmqJgUaUiydWWQ4a3wSchqEVvQO3kAvg(mpPawHHa8fqUAhxuuSiowt2t)aRWqabODifaP0AcAid6xV8lgfmt1dtuKJ1dhAOij5Q8lgfmt1dt8GLKmoOmVcgfGkx(ecD)gSIHLyFZGngOrdxaxeSbyyvCGBlwjIkgPqr1yGxrR2XfgSIHLyFZGngOrdxaxeSbyyvCGBlwHrEIdAZRmFJzCObSAhxO34GY8kyuaQGgVHqss(fJczpcP5FCG4b)l)IrHShH08poquKJ1d3LGCxD)Uk)IrbZu9Wep4myJbA0WfWfbBagwfh42Iv6Hz1yGgnR2Xf6noOmVcgfGkOXBiKKKFXOq2JqA(hhiEW)YVyui7rin)Jdef5y9WD5t3v3VRYVyuWmvpmXdod2yGgnCbCrWgGHvXbUTyfCw1MSNwDmhAb3WrQiQumt1dBvCM)rlCLHqEnuGrWmvpmrrMg(zWgd0OHlGlc2amSkoWTfReFf(kuur(3qR2XfeZ3WCs0JYg8)nyfdlX((JZQ2K9KGB4ivevkMP6HLbBmqJgUaUiydWWQ4a3wScZgg5vYVyC1XCOfCGvEuPTAhxi)IrbhyLhvAIICSE4U4U)6LFXOGy(gMtkoYBL4bljj)IrbX8nmNu(3yL4bR734GY8kyuaQGgVHid2yGgnCbCrWgGHvXbUTyfoWk(RWqR2Xf6D1wkvnGeCqr23EWO4aR4IYMVssYVyuWmvpmrrowpCxO1i2dqkq7qssUcxeobhyf)vyiD)6LFXOGzQEyIhSKKXbL5vWOaubnEdXpX8nmNe9OSbFDzWgd0OHlGlc2amSkoWTfRWbwXFfgA1oUqVR2sPQbKGdkY(2dgfhyfxu28vss(fJcMP6HjkYX6H7cTgXEasbAhssYv4IWj4aR4VcdP7hyEAacoWkpQ0e0yYEs7xV8lgfCGvEuPjEWssghuMxbJcqf04ne6(LFXOGdSYJknbhySVU85VE5xmkiMVH5KIJ8wjEWssYVyuqmFdZjL)nwjEW6YGngOrdxaxeSbyyvCGBlwHdSI)km0QDCHExTLsvdibhuK9ThmkoWkUOS5RKK8lgfmt1dtuKJ1d3fAnI9aKc0oKKKRWfHtWbwXFfgs3V8lgfeZ3WCsXrERef5y9WHgV(jMVH5KOhfh5T63vG5Pbi4aR8OstqJj7jTFgc51qbgbZu9Wef5y9WHgVYGngOrdxaxeSbyyvCGBlwzOakheAwTJl0l)IrbX8nmNu(3yL4bljPNH1kmeFrq)fXWAfgsbAhYfOOtsIH1kmeFXN6(nyfdlX((JZQ2K9KGB4ivevkMP6HLbBmqJgUaUiydWWQ4a3wScwZhvoi0SAhxOx(fJcI5ByoP8VXkXdwsspdRvyi(IG(lIH1kmKc0oKlqrNKedRvyi(IpLKKFXOGzQEyIhSUFdwXWsSV)4SQnzpj4gosfrLIzQEyzWgd0OHlGlc2amSkoWTfReFEVYbHMv74c9YVyuqmFdZjL)nwjEWss6zyTcdXxe0FrmSwHHuG2HCbk6KKyyTcdXx8PKK8lgfmt1dt8G19BWkgwI99hNvTj7jb3WrQiQumt1dld2yGgnCbCrWgGHvXbUTyLawvnQuOOI8VHYGngOrdxaxeSbyyvCGBlwHdSk2fTAhxO3wkvnGeCqr23EWO4aR4IYMV)YVyuWmvpmrrowpCOP1i2dqkq7q)WfHteOmawDss6D1wkvnGeCqr23EWO4aR4IYMVssYVyuWmvpmrrowpCxO1i2dqkq7qssUcxeobhyvSls3VEI5Byoj6r5FJvsseZ3WCsWrERudTgqsIy(gMtcBWxn0Aajj5xmkcyv1OsHIkY)gs8G)LFXOGy(gMtk)BSs8GLK0l)IrbZu9Wef5y9WDXyGgnIaLbWkO1i2dqkq7q)YVyuWmvpmXdwNojj92sPQbKqZcm9GrXFJOS5l0b9l)IrbX8nmNuCK3krrowpCOHYVRYVyuOzbMEWO4VruKJ1dhAJbA0icugaRGwJypaPaTdPld2yGgnCbCrWgGHvXbUTyLaLbWMbBmqJgUaUiydWWQ4a3wSs9gLXanAu(MdwDmhAr08Ea26LbNbBmqJgUGdw4GqtSlAvg(mpPawHHa8fqUAhxuuSiowt2t)aRWqabODifaP0AcAid6xV8lgfmt1dtuKJ1dhAO8Rx(fJIYWrd6XvXIMLIVOihRho0qrsYv5xmkkdhnOhxflAwk(IhSojjxLFXOGzQEyIhSKKXbL5vWOau5YNqO7xVRYVyu8ThTI0uKdmkavo0au0qfMEPK4bljzCqzEfmkavU8je6(nyfdlX(MbBmqJgUGdCBXk83e7IwLHpZtkGvyiaFbKR2XffflIJ1K90pWkmeqaAhsbqkTMGgYG(1l)IrbZu9Wef5y9WHgk)6LFXOOmC0GECvSOzP4lkYX6HdnuKKCv(fJIYWrd6XvXIMLIV4bRtsYv5xmkyMQhM4bljzCqzEfmkavU8je6(17Q8lgfF7rRinf5aJcqLdnafnuHPxkjEWssghuMxbJcqLlFcHUFdwXWsSVzWgd0OHl4a3wSchqEVvQO3kAvg(mpPawHHa8fqUAhxuuSiowt2t)aRWqabODifaP0AcAiD3F9YVyuWmvpmrrowpCOHYVE5xmkkdhnOhxflAwk(IICSE4qdfjjxLFXOOmC0GECvSOzP4lEW6KKCv(fJcMP6HjEWssghuMxbJcqLlFcHUF9Uk)IrX3E0kstroWOau5qdqrdvy6LsIhSKKXbL5vWOau5YNqO73GvmSe7BgSXanA4coWTfRerfJuOOAmWROv74cdwXWsSVzWgd0OHl4a3wSsz4Ob94QyrZsXF1oUq(fJcMP6HjEWzWgd0OHl4a3wSY3E0kstXH7Qb8v74c96LFXOGy(gMtkoYBLOihRho0qcHKK8lgfeZ3WCs5FJvIICSE4qdje6(ziKxdfyemt1dtuKJ1dh6pH4xV8lgfWv7GkT28kRy20mf8ZZTsGZ8pYLG(iessUwVHIOcdjGR2bvAT5vwXSPzk4NNBLG(qVggM00Ptss(fJc4QDqLwBELvmBAMc(55wjWz(hb9IGWliKKyiKxdfyemt1dtuKPH)VEJdkZRGrbOcA8gcjjCw1MSNenxzisxgSXanA4coWTfRWipXbT5vMVXmo0awTJl0BCqzEfmkavqJ3q8Rx(fJIV9OvKMICGrbOYHgGIgQW0lLepyjjxziC0ydq8f)QTrNKedHJgBaIPXGfOIgjjHZQ2K9KO5kdrssYVyui7rin)Jdep4F5xmkK9iKM)XbIICSE4UeeeUPxpEJh1BOiQWqc4QDqLwBELvmBAMc(55wjOp0RHHjnDUP)J4bdnAVgiGlI1Csz(gZ4qdqqJj7jnD6097Q8lgfmt1dt8G)1hBmybQICSE4UWqiVgkWiyObh6lPayjfhURgWff5y9WDdVKKIngSavrowpCxcki30J34HE5xmkGR2bvAT5vwXSPzk4NNBLaN5Fe0qcbe60jjfBmybQICSE4lzjq(bq4sqbjjXqiVgkWiyObh6lPayjfhURgWfpyjjxziC0ydqmngSav0iDzWgd0OHl4a3wSspmRgd0Oz1oUqVXbL5vWOaubnEdXVE5xmk(2JwrAkYbgfGkhAakAOctVus8GLKCLHWrJnaXx8R2gDssmeoASbiMgdwGkAKKeoRAt2tIMRmejjj)IrHShH08poq8G)LFXOq2JqA(hhikYX6H7YNq4ME94nEuVHIOcdjGR2bvAT5vwXSPzk4NNBLG(qVggM005M(pIhm0O9AGaUiwZjL5BmJdnabnMSN00Pt3VRYVyuWmvpmXd(xFSXGfOkYX6H7cdH8AOaJGHgCOVKcGLuC4UAaxuKJ1d3n8ssk2yWcuf5y9WD5ZGCtpEJh6LFXOaUAhuP1MxzfZMMPGFEUvcCM)rqdjeqOtNKuSXGfOkYX6HVKLa5haHlFgKKedH8AOaJGHgCOVKcGLuC4UAax8GLKCLHWrJnaX0yWcurJ0LbBmqJgUGdCBXk4SQnzpT6yo0cgAWH(skgA0AqJMvXz(hTGHWrJnaX0yWcurJ(1l)IrbC1oOsRnVYkMnntb)8CRe4m)JCjOpcXVEgc51qbgbZu9Wef5y9WDdsiGo2yWcuf5y9WLKyiKxdfyemt1dtuKJ1d3TpHWLyJblqvKJ1d)p2yWcuf5y9WHgYpHqss(fJcMP6HjkYX6HdnEP7x(fJcI5ByoP4iVvIICSE4qdjessXgdwGQihRh(swcKbbHlqcfDzWgd0OHl4a3wScoRAt2tRoMdTGB4ivevkMP6HTkoZ)Of6DLHqEnuGrWmvpmrrMg(ssUIZQ2K9KGHgCOVKIHgTg0O5NHWrJnaX0yWcurJ0LbBmqJgUGdCBXkm0Gd9LuaSKId3vd4R2Xf4SQnzpjyObh6lPyOrRbnA(noOmVcgfGkx(eImyJbA0WfCGBlwj(k8vOOI8VHwTJliMVH5KOhLn4)BWkgwI99x(fJc4QDqLwBELvmBAMc(55wjWz(h5sqFeIF9AiGW0myqJJu8aw5O0mhddjan7BpyKKCLHWrJnaXqSc5rLMUFCw1MSNeCdhPIOsXmvpSmyJbA0WfCGBlwX0myqJJu8aw5SAhxKbBmqJgUGdCBXkCGvrZ7xTJlKFXOanealxbtfJGbnAep4F5xmk4aRIM3lkkwehRj7PmyJbA0WfCGBlwHzdJ8k5xmU6yo0coWkpQ0wTJlKFXOGdSYJknrrowpCxC3F9YVyuqmFdZjfh5Ts8GLKKFXOGy(gMtk)BSs8G19BCqzEfmkavqJ3qKbBmqJgUGdCBXkCGv8xHHwTJlyiC0ydqmngSav0OFCw1MSNem0Gd9Lum0O1Ggn)meYRHcmcgAWH(skawsXH7QbCrrowpCxWW0eo2A4bJAVEJdkZRGrbOAjFcHUmyJbA0WfCGBlwHdSkAE)QDCbW80aeCa59wP0Qoce0yYEs73vG5Pbi4aR8OstqJj7jTF5xmk4aRIM3lkkwehRj7PF9YVyuqmFdZjL)nwjkYX6HdT7(tmFdZjrpk)BS6x(fJc4QDqLwBELvmBAMc(55wjWz(h5sqqbcjj5xmkGR2bvAT5vwXSPzk4NNBLaN5Fe0lcckq8BCqzEfmkavqJ3qijPHactZGbnosXdyLJsZCmmKOihRho0FGKKXanAeMMbdACKIhWkhLM5yyirpQOVXGfO73vgc51qbgbZu9WefzA4NbBmqJgUGdCBXkCGv8xHHwTJlKFXOanealxX8KvkCnVrJ4bljj)IrX3E0kstroWOau5qdqrdvy6LsIhSKK8lgfmt1dt8G)1l)Irrz4Ob94QyrZsXxuKJ1d3fmmnHJTgEWO2R34GY8kyuaQwYNqO7x(fJIYWrd6XvXIMLIV4blj5Q8lgfLHJg0JRIfnlfFXd(3vgc51qbgrz4Ob94QyrZsXxuKPHVKKRmeoASbiWrdal(LojjJdkZRGrbOcA8gIFI5Byoj6rzd(zWgd0OHl4a3wSchyf)vyOv74cG5Pbi4aR8OstqJj7jTF9YVyuWbw5rLM4bljzCqzEfmkavqJ3qO7x(fJcoWkpQ0eCGX(6YN)6LFXOGy(gMtkoYBL4bljj)IrbX8nmNu(3yL4bR7x(fJc4QDqLwBELvmBAMc(55wjWz(h5sq4fe)6ziKxdfyemt1dtuKJ1dhAiHqsYvCw1MSNem0Gd9Lum0O1Ggn)meoASbiMgdwGkAKUmyJbA0WfCGBlwHdSI)km0QDCHE5xmkGR2bvAT5vwXSPzk4NNBLaN5FKlbHxqijj)IrbC1oOsRnVYkMnntb)8CRe4m)JCjiOaXpW80aeCa59wP0Qoce0yYEst3V8lgfeZ3WCsXrERef5y9WHgV(jMVH5KOhfh5T63v5xmkqdbWYvWuXiyqJgXd(3vG5Pbi4aR8OstqJj7jTFgc51qbgbZu9Wef5y9WHgV(1ZqiVgkWi(2JwrAkoCxnGlkYX6HdnEjj5kdHJgBaIV4xTn6YGngOrdxWbUTyLHcOCqOz1oUqV8lgfeZ3WCs5FJvIhSKKEgwRWq8fb9xedRvyifODixGIojjgwRWq8fFQ73GvmSe77poRAt2tcUHJuruPyMQhwgSXanA4coWTfRG18rLdcnR2Xf6LFXOGy(gMtk)BSs8G)DLHWrJnaXx8R2gjj9YVyu8ThTI0uKdmkavo0au0qfMEPK4b)Zq4OXgG4l(vBJojj9mSwHH4lc6VigwRWqkq7qUafDssmSwHH4l(uss(fJcMP6HjEW6(nyfdlX((JZQ2K9KGB4ivevkMP6HLbBmqJgUGdCBXkXN3RCqOz1oUqV8lgfeZ3WCs5FJvIh8VRmeoASbi(IF12ijPx(fJIV9OvKMICGrbOYHgGIgQW0lLep4Fgchn2aeFXVAB0jjPNH1kmeFrq)fXWAfgsbAhYfOOtsIH1kmeFXNssYVyuWmvpmXdw3VbRyyj23FCw1MSNeCdhPIOsXmvpSmyJbA0WfCGBlwjGvvJkfkQi)BOmyJbA0WfCGBlwHdSk2fTAhxqmFdZjrpk)BSssIy(gMtcoYBLAO1asseZ3WCsyd(QHwdijj)IrraRQgvkuur(3qIh8V8lgfeZ3WCs5FJvIhSKKE5xmkyMQhMOihRhUlgd0OreOmawbTgXEasbAh6x(fJcMP6HjEW6YGngOrdxWbUTyLaLbWMbBmqJgUGdCBXk1Bugd0Or5Boy1XCOfrZ7byR3gSb7na]] )


end