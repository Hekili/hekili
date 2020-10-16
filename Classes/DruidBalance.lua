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


    spec:RegisterPack( "Balance", 20201016, [[dGutDdqikLEeLcvxsfsBceFsvvPmkQKtrPAvuk4vcWSurClviYUi8lvvmmOWXGIwMa5zQqnnvvvxtvL2MaQ(gLImovvfNJsrTokfY8qsDpvW(qIoiLcflej4HcOmrvikXfvHOK(OkevDsvvLQvkqntviStvK(PkeLAOQquSukfk9ubnvvv5RQquzVQ0FjAWkDyslMkEmIjJuxg1Mf6ZG0OHsNwYRvrnBQ62uYUL63qgoOoUQQswUINtX0bUUQSDvLVtLA8iHopsY6fqMpuTFrFX8(3nKwb890GWiimWedmdCbMyECqyyt3qavW8newjNvO8nSvl(gsb1RnHVHWkvEKsF)7gAqVHW3qSaaSXg9Zpqla2NJGGS(XuwpVckutgnc(XuwKFUHoVYd(37RZnKwb890GWiimWedmd8BO(ayrZnmSScSBi2IMM7RZnKMnKBOnEUuq9At4CpYY8k6myB8CpYMaqo8KlMb(j5gegbHrgCgSnEUbgwTHYgBugSnEUhPCTXqtZ05gI86Klfy1sKbBJN7rk3adR2qz6Cb6aLbYkMlrnSjxakxcveplb6aLbgrgSnEUhPCTXYwOpMo3x3mHngDOk3pDk1XZMCDvcwCsUWd)jnaDmVbkN7rIYCHh(tya6yEdu2U4g6ldWC)7gspSA5unnp3)UNI59VBi3QJNPVu4gIGVHggCdvcOq9n8tNsD88n8t9p(g6kxNxmkaLf7gnTKEy1YPAAEedBPvBYLYCHsOfwkfZnGCXqGzUqY1vUmXxWgwuT0bbWMloEUmXxWgwuT0G86KloEUmXxWgw4FToYMPiix75IJNRZlgfGYIDJMwspSA5unnpIHT0Qn5szUkbuOwya6eRHfmfzYdWsqzX5gqUyiWmxi56kxM4lydlQw6FTo5IJNlt8fSHfgKxhzZueKloEUmXxWgwOnvYMPiix75ApxC8CTnxNxmkaLf7gnTKEy1YPAAEep4B4NoYwT4BOrJSeGKpdlnWS3Fb3td6(3nKB1XZ0xkCdjtb4P0BORCTn3pDk1XZcJgzjajFgwAGzVpxC8CDLRZlgfJ(Xn6zKXH7arLyylTAtUuNlucTWsPyU2qUeU856kx1ag1lHrU5j3FY9ymY1EUqY15fJIr)4g9mY4WDGOs8GZ1EU2Zfhpx1ag1lHrU5jxkZ1MX4gQeqH6BObOJ5nq5l4E6X3)UHCRoEM(sHBizkapLEdTnxAeqO0kmO(yPXTowsA1sHYcqroxn0CHKRT5QeqHAHsRWG6JLg36yjPvlfklQwg9fuSGCHKRRCTnxAeqO0kmO(yPXTowsSS6fGICUAO5IJNlnciuAfguFS04whljww9IHT0Qn5szU)MR9CXXZLgbekTcdQpwACRJLKwTuOSWauY5CPo3JZfsU0iGqPvyq9XsJBDSK0QLcLfdBPvBYL6Cpoxi5sJacLwHb1hlnU1XssRwkuwakY5QHEdvcOq9nuPvyq9XsJBDSUG7P))(3nKB1XZ0xkCdvcOq9n0cH6yn8nKmfGNsVHUY15fJcIkRMig2sR2KlL5(BUqY1vUoVyum6h3ONrghUdevIHT0Qn5szU)MloEU2MRZlgfJ(Xn6zKXH7arL4bNR9CXXZ12CDEXOGOYQjIhCU445QgWOEjmYnp5sDUhJrU2ZfsUUY12CDEXO4C10dtlzlyKBES4gi5MhOvGyXdoxC8CvdyuVeg5MNCPo3JXix75cjxfwsWYKZ3qGoqzGSI3WHJdBWQoEoxi5c0bkdeGYILaKKU4CPmxmd6cUN(79VBi3QJNPVu4gQeqH6BO51XA4BizkapLEdDLRZlgfevwnrmSLwTjxkZ93CHKRRCDEXOy0pUrpJmoChiQedBPvBYLYC)nxC8CTnxNxmkg9JB0ZiJd3bIkXdox75IJNRT568IrbrLvtep4CXXZvnGr9syKBEYL6CpgJCTNlKCDLRT568IrX5QPhMwYwWi38yXnqYnpqRaXIhCU445QgWOEjmYnp5sDUhJrU2ZfsUkSKGLjNVHaDGYazfVHdhh2GvD8CUqYfOdugiaLflbijDX5szUyg0fCpnWV)Dd5wD8m9Lc3qLakuFdna271rg96W3qYuaEk9g6kxNxmkiQSAIyylTAtUuM7V5cjxx568IrXOFCJEgzC4oqujg2sR2KlL5(BU445ABUoVyum6h3ONrghUdevIhCU2ZfhpxBZ15fJcIkRMiEW5IJNRAaJ6LWi38Kl15Emg5Apxi56kxBZ15fJIZvtpmTKTGrU5XIBGKBEGwbIfp4CXXZvnGr9syKBEYL6CpgJCTNlKCvyjbltoFdb6aLbYkEdhooSbR645CHKlqhOmqaklwcqs6IZLYCXmWVG7P209VBi3QJNPVu4gsMcWtP3qfwsWYKZ3qLakuFdJOHWsuu2k4n8fCp9FU)Dd5wD8m9Lc3qYuaEk9g68IrbrLvtep4BOsafQVHJ(Xn6zKXH7ar1fCp1MV)Dd5wD8m9Lc3qYuaEk9g6kxx568Irbt8fSHLgKxhXWwA1MCPmxmXixC8CDEXOGj(c2Ws)R1rmSLwTjxkZftmY1EUqYLGqEAK7wquz1eXWwA1MCPm3JXix75IJNlbH80i3TGOYQjIHvAQUHkbuO(gEUA6HPLg4AkG5cUNIjg3)UHCRoEM(sHBizkapLEdDLRZlgfNRMEyAjBbJCZJf3aj38aTcelEW5IJNRT5sqFCRnqCMQP0ox75IJNlb9XT2arxqXcKrLZfhp3pDk1XZIYiveNloEUoVyu44riA)Zaep4CHKRZlgfoEeI2)maXWwA1MCPo3GWi3aY1vU)pxBixcQPFfqapmPmSu9f02IBGGB1XZ05Apxi5ABUoVyuquz1eXdoxi56k3Qb8aJ8kGPLXckwGCylTAtUuNlbH80i3TGG6p0zwcWYsdCnfWig2sR2KBa5At5IJNB1aEGrEfW0YybflqoSLwTjxQZnOGYfhp3Qb8aJ8kGPLXckwGCylTAtUhnxm)hmYL6CdkOCXXZLGqEAK7wqq9h6mlbyzPbUMcyep4CXXZ12CjOpU1gi6ckwGmQCU2VHkbuO(gsypBaL6LQVG2wCdUG7PyI59VBi3QJNPVu4gsMcWtP3qx568IrX5QPhMwYwWi38yXnqYnpqRaXIhCU445ABUe0h3AdeNPAkTZ1EU445sqFCRnq0fuSazu5CXXZ9tNsD8SOmsfX5IJNRZlgfoEeI2)maXdoxi568IrHJhHO9pdqmSLwTjxQZ9ymYnGCDL7)Z1gYLGA6xbeWdtkdlvFbTT4gi4wD8mDU2ZfsU2MRZlgfevwnr8GZfsUUYTAapWiVcyAzSGIfih2sR2Kl15sqipnYDliO(dDMLaSS0axtbmIHT0Qn5gqU2uU445wnGhyKxbmTmwqXcKdBPvBYL6CpoOCXXZTAapWiVcyAzSGIfih2sR2K7rZfZ)bJCPo3JdkxC8CjiKNg5Ufeu)HoZsawwAGRPagXdoxC8CTnxc6JBTbIUGIfiJkNR9BOsafQVHvt0PvqH6l4EkMbD)7gYT64z6lfUHi4BOHb3qLakuFd)0PuhpFd)u)JVHe0h3AdeDbflqgvoxi56kxNxmkGNYcn0L6L6q0Uis4N3OJ4t9poxQZnO)JrUqY1vUeeYtJC3cIkRMig2sR2KBa5Ijg5szUvd4bg5vatlJfuSa5WwA1MCXXZLGqEAK7wquz1eXWwA1MCdi3JXixQZTAapWiVcyAzSGIfih2sR2KlKCRgWdmYRaMwglOybYHT0Qn5szUyEmg5IJNRZlgfevwnrmSLwTjxkZ1MY1EUqY15fJcM4lydlniVoIHT0Qn5szUyIrU445wnGhyKxbmTmwqXcKdBPvBY9O5IzqyKl15I5V5A)g(PJSvl(gsq9h6mljOMUafQVG7PyE89VBi3QJNPVu4gIGVHggCdvcOq9n8tNsD88n8t9p(g6kxBZLGqEAK7wquz1eXWknv5IJNRT5(PtPoEwqq9h6mljOMUafQZfsUe0h3AdeDbflqgvox73WpDKTAX3qJ(XYiAKevwn5cUNI5)V)Dd5wD8m9Lc3qYuaEk9g(PtPoEwqq9h6mljOMUafQZfsUQbmQxcJCZtUuN7)X4gQeqH6Bib1FOZSeGLLg4AkG5cUNI5V3)UHCRoEM(sHBizkapLEdzIVGnSOAP2uLlKCvyjbltoNlKCDLlnciuAfguFS04whljTAPqzbOiNRgAU445ABUe0h3AdentgKhn05Apxi5(PtPoEwy0pwgrJKOYQj3qLakuFdJVHkjkkz)R5l4EkMb(9VBi3QJNPVu4gsMcWtP3qc6JBTbIUGIfiJkNlKC)0PuhpliO(dDMLeutxGc15cjx1ag1lHrU5jxkpK7)Xixi5sqipnYDliO(dDMLaSS0axtbmIHT0Qn5sDUqj0clLI5Ad5s4YNRRCvdyuVeg5MNC)j3JXix73qLakuFdnaDmVbkFb3tX0MU)Dd5wD8m9Lc3qYuaEk9g6kxNxmkyIVGnS0)ADep4CXXZ1vUeS6aLn5Ei3GYfsUdtWQduwckloxQZ93CTNloEUeS6aLn5Ei3JZ1EUqYvHLeSm5CUqY9tNsD8SWOFSmIgjrLvtUHkbuO(g2SBPfc1xW9um)N7F3qUvhptFPWnKmfGNsVHUY15fJcM4lydl9VwhXdoxi5ABUe0h3AdeNPAkTZfhpxx568IrX5QPhMwYwWi38yXnqYnpqRaXIhCUqYLG(4wBG4mvtPDU2Zfhpxx5sWQdu2K7HCdkxi5ombRoqzjOS4CPo3FZ1EU445sWQdu2K7HCpoxC8CDEXOGOYQjIhCU2ZfsUkSKGLjNZfsUF6uQJNfg9JLr0ijQSAYnujGc13qSQpkTqO(cUNIPnF)7gYT64z6lfUHKPa8u6n0vUoVyuWeFbByP)16iEW5cjxBZLG(4wBG4mvtPDU4456kxNxmkoxn9W0s2cg5MhlUbsU5bAfiw8GZfsUe0h3AdeNPAkTZ1EU4456kxcwDGYMCpKBq5cj3Hjy1bklbLfNl15(BU2ZfhpxcwDGYMCpK7X5IJNRZlgfevwnr8GZ1EUqYvHLeSm5CUqY9tNsD8SWOFSmIgjrLvtUHkbuO(ggFEV0cH6l4EAqyC)7gQeqH6BOBDMcnsuuY(xZ3qUvhptFPWfCpnimV)Dd5wD8m9Lc3qYuaEk9gYeFbByr1s)R1jxC8CzIVGnSWG86iBMIGCXXZLj(c2WcTPs2mfb5IJNRZlgfU1zk0irrj7FnlEW5cjxNxmkyIVGnS0)ADep4CXXZ1vUoVyuquz1eXWwA1MCPoxLakulCpkaRGPitEawckloxi568IrbrLvtep4CTFdvcOq9n0a0jwdFb3tdkO7F3qLakuFdDpka7nKB1XZ0xkCb3td647F3qUvhptFPWnujGc13W51sLakul9LbCd9LbiB1IVHr17byN3fCb3q4HHvabR0aU)DpfZ7F3qUvhptFPWnujGc13qleQJ1W3qYuaEk9goCCydw1XZ5cjxGoqzGauwSeGK0fNlL5Izq5cjxx568IrbrLvtedBPvBYLYC)nxC8CTnxNxmkiQSAI4bNloEUQbmQxcJCZtUuN7XyKR9CHKRcljyzY5BiHkINLaDGYaZ9umVG7PbD)7gYT64z6lfUHkbuO(gAEDSg(gsMcWtP3WHJdBWQoEoxi5c0bkdeGYILaKKU4CPmxmdkxi56kxNxmkiQSAIyylTAtUuM7V5IJNRT568IrbrLvtep4CXXZvnGr9syKBEYL6CpgJCTNlKCvyjbltoFdjur8SeOdugyUNI5fCp947F3qUvhptFPWnujGc13qdG9EDKrVo8nKmfGNsVHdhh2GvD8CUqYfOdugiaLflbijDX5szUyguUqY1vUoVyuquz1eXWwA1MCPm3FZfhpxBZ15fJcIkRMiEW5IJNRAaJ6LWi38Kl15Emg5Apxi5QWscwMC(gsOI4zjqhOmWCpfZl4E6)V)Dd5wD8m9Lc3qYuaEk9gQWscwMC(gQeqH6ByenewIIYwbVHVG7P)E)7gYT64z6lfUHKPa8u6n0vUQbmQxcJCZtUuMRnJrU44568IrHJhHO9pdq8GZfsUoVyu44riA)ZaedBPvBYL6CdkWZ1EUqY12CDEXOGOYQjIh8nujGc13qc7zdOuVu9f02IBWfCpnWV)Dd5wD8m9Lc3qYuaEk9g6kx1ag1lHrU5jxkZ1MXixC8CDEXOWXJq0(NbiEW5cjxNxmkC8ieT)zaIHT0Qn5sDUhh45Apxi5ABUoVyuquz1eXd(gQeqH6By1eDAfuO(cUNAt3)UHCRoEM(sHBic(gAyWnujGc13WpDk1XZ3Wp1)4BOT5sqipnYDliQSAIyyLMQB4NoYwT4BOr)yzensIkRMCb3t)N7F3qUvhptFPWnKmfGNsVHmXxWgwuTuBQYfsUkSKGLjNZfsUF6uQJNfg9JLr0ijQSAYnujGc13W4BOsIIs2)A(cUNAZ3)UHoVyu2QfFdnaD8OH(gQeqH6BirBc7LoVy8gsMcWtP3qNxmkmaD8OHwmSLwTjxQZnWZfsUUY15fJcM4lydlniVoIhCU44568Irbt8fSHL(xRJ4bNR9CHKRAaJ6LWi38KlL5AZyCd5wD8m9LcxW9umX4(3nKB1XZ0xkCdjtb4P0BORCTnxnq8uawyadRNRgQ0a0XigTpNloEUoVyuquz1eXWwA1MCPoxMIm5byjOS4CXXZ12CHh(tya6yEduox75cjxx568IrbrLvtep4CXXZvnGr9syKBEYLYCTzmYfsUmXxWgwuTuBQY1(nujGc13qdqhZBGYxW9umX8(3nKB1XZ0xkCdjtb4P0BORCTnxnq8uawyadRNRgQ0a0XigTpNloEUoVyuquz1eXWwA1MCPoxMIm5byjOS4CXXZ12C)0PuhplGh(tAa6yEduox75cjxG65gimaD8OHwWT64z6CHKRRCDEXOWa0XJgAXdoxC8CvdyuVeg5MNCPmxBgJCTNlKCDEXOWa0XJgAHbOKZ5sDUhNlKCDLRZlgfmXxWgwAqEDep4CXXZ15fJcM4lydl9VwhXdox75cjxcc5PrUBbrLvtedBPvBYLYCTPBOsafQVHgGoM3aLVG7Pyg09VBi3QJNPVu4gsMcWtP3qx5ABUAG4PaSWagwpxnuPbOJrmAFoxC8CDEXOGOYQjIHT0Qn5sDUmfzYdWsqzX5IJNRT5cp8NWa0X8gOCU2ZfsUoVyuWeFbByPb51rmSLwTjxkZ1MYfsUmXxWgwuT0G86KlKCTnxG65gimaD8OHwWT64z6CHKlbH80i3TGOYQjIHT0Qn5szU20nujGc13qdqhZBGYxW9ump((3nKB1XZ0xkCdjtb4P0BORCDEXOGj(c2Ws)R1r8GZfhpxx5sWQdu2K7HCdkxi5ombRoqzjOS4CPo3FZ1EU445sWQdu2K7HCpox75cjxfwsWYKZ5cj3pDk1XZcJ(XYiAKevwn5gQeqH6ByZULwiuFb3tX8)3)UHCRoEM(sHBizkapLEdDLRZlgfmXxWgw6FToIhCU4456kxcwDGYMCpKBq5cj3Hjy1bklbLfNl15(BU2ZfhpxcwDGYMCpK7X5IJNRZlgfevwnr8GZ1EUqYvHLeSm5CUqY9tNsD8SWOFSmIgjrLvtUHkbuO(gIv9rPfc1xW9um)9(3nKB1XZ0xkCdjtb4P0BORCDEXOGj(c2Ws)R1r8GZfhpxx5sWQdu2K7HCdkxi5ombRoqzjOS4CPo3FZ1EU445sWQdu2K7HCpoxC8CDEXOGOYQjIhCU2ZfsUkSKGLjNZfsUF6uQJNfg9JLr0ijQSAYnujGc13W4Z7LwiuFb3tXmWV)DdvcOq9n0TotHgjkkz)R5Bi3QJNPVu4cUNIPnD)7gYT64z6lfUHKPa8u6n0vUAG4PaSWagwpxnuPbOJrmAFoxi568IrbrLvtedBPvBYLYCzkYKhGLGYIZfsUWd)jCpkaBU2Zfhpxx5ABUAG4PaSWagwpxnuPbOJrmAFoxC8CDEXOGOYQjIHT0Qn5sDUmfzYdWsqzX5IJNRT5cp8NWa0jwdNR9CHKRRCzIVGnSOAP)16KloEUmXxWgwyqEDKntrqU445YeFbByH2ujBMIGCXXZ15fJc36mfAKOOK9VMfp4CHKRZlgfmXxWgw6FToIhCU4456kxNxmkiQSAIyylTAtUuNRsafQfUhfGvWuKjpalbLfNlKCDEXOGOYQjIhCU2Z1EU4456kxnq8uawqRU7QHknVwmAFoxkZnOCHKRZlgfmXxWgwAqEDedBPvBYLYC)nxi5ABUoVyuqRU7QHknVwmSLwTjxkZvjGc1c3JcWkykYKhGLGYIZ1(nujGc13qdqNyn8fCpfZ)5(3nujGc13q3JcWEd5wD8m9LcxW9umT57F3qUvhptFPWnujGc13W51sLakul9LbCd9LbiB1IVHr17byN3fCb3qAoQpp4(39umV)DdvcOq9n0G86iDy16gYT64z6lfUG7PbD)7gYT64z6lfUHi4BOHb3qLakuFd)0PuhpFd)u)JVHgy27LaDGYaJWa0jQEFUuMlM5cjxx5ABUa1Znqya64rdTGB1XZ05IJNlq9Cdega796iPNkceCRoEMox75IJNRbM9EjqhOmWimaDIQ3NlL5g0n8thzRw8nSmsfXxW90JV)Dd5wD8m9Lc3qe8n0WGBOsafQVHF6uQJNVHFQ)X3qdm79sGoqzGrya6eRHZLYCX8g(PJSvl(gwgjXZ6hFb3t))9VBi3QJNPVu4gsMcWtP3qx5ABUe0h3AdeDbflqgvoxC8CTnxcc5PrUBbb1FOZSeGLLg4AkGr8GZ1EUqY15fJcIkRMiEW3qLakuFdD4XWZ5QHEb3t)9(3nKB1XZ0xkCdjtb4P0BOZlgfevwnr8GVHkbuO(gcJafQVG7Pb(9VBOsafQVHpdllaBzUHCRoEM(sHl4EQnD)7gYT64z6lfUHKPa8u6n8tNsD8SOmsfX3qdykc4EkM3qLakuFdNxlvcOqT0xgWn0xgGSvl(gQi(cUN(p3)UHCRoEM(sHBizkapLEdNxZr0aLfGYIDJMwspSA5unnpc(F9kyyM(gAatra3tX8gQeqH6B48APsafQL(YaUH(YaKTAX3q6HvlNQP55cUNAZ3)UHCRoEM(sHBizkapLEdNxZr0aLfoQxBclrrP69sa2QHAe8)6vWWm9n0aMIaUNI5nujGc13W51sLakul9LbCd9LbiB1IVHoifCb3tXeJ7F3qUvhptFPWnKmfGNsVHE(J95szU)IXnujGc13W51sLakul9LbCd9LbiB1IVHgWfCpftmV)Dd5wD8m9Lc3qLakuFdNxlvcOqT0xgWn0xgGSvl(gcpmSciyLgWfCb3qhKcU)DpfZ7F3qUvhptFPWnKmfGNsVHoVyuquz1eXd(gQeqH6B4OFCJEgzC4oquDb3td6(3nKB1XZ0xkCdrW3qddUHkbuO(g(PtPoE(g(P(hFdTnxNxmkCuV2ewIIs17LaSvd1iBf8gw8GZfsU2MRZlgfoQxBclrrP69sa2QHAK6q0Mfp4B4NoYwT4BizkqJap4l4E6X3)UHoVyu2QfFdnaD8OH(gQeqH6BirBc7LoVy8gsMcWtP3qNxmkmaD8OHwmSLwTjxQZfZFZfsUUY15fJch1RnHLOOu9EjaB1qnYwbVHfdBPvBYLYC)V43CXXZ15fJch1RnHLOOu9EjaB1qnsDiAZIHT0Qn5szU)x8BU2ZfsUQbmQxcJCZtUuEi3ahJCHKRRCjiKNg5UfevwnrmSLwTjxkZ1MYfhpxx5sqipnYDlylyKBEKoOMwmSLwTjxkZ1MYfsU2MRZlgfNRMEyAjBbJCZJf3aj38aTcelEW5cjxc6JBTbIZunL25Apx73qUvhptFPWfCp9)3)UHCRoEM(sHBizkapLEdTn3pDk1XZcYuGgbEW5cjxx56kxBZLGqEAK7wqq9h6mlbyzPbUMcyep4CXXZ12C)0PuhpliO(dDMLeutxGc15IJNRT5sqFCRnq0fuSazu5CTNlKCDLlb9XT2arxqXcKrLZfhpxx5sqipnYDliQSAIyylTAtUuMRnLloEUUYLGqEAK7wWwWi38iDqnTyylTAtUuMRnLlKCTnxNxmkoxn9W0s2cg5MhlUbsU5bAfiw8GZfsUe0h3AdeNPAkTZ1EU2Z1EU2Zfhpxx5sqipnYDliO(dDMLaSS0axtbmIhCUqYLGqEAK7wquz1eXWknv5cjxc6JBTbIUGIfiJkNR9BOsafQVHgGoM3aLVG7P)E)7gYT64z6lfUHkbuO(gQ0kmO(yPXTow3qYuaEk9gABU0iGqPvyq9XsJBDSK0QLcLfGICUAO5cjxBZvjGc1cLwHb1hlnU1XssRwkuwuTm6lOyb5cjxx5ABU0iGqPvyq9XsJBDSKyz1laf5C1qZfhpxAeqO0kmO(yPXTowsSS6fdBPvBYLYC)nx75IJNlnciuAfguFS04whljTAPqzHbOKZ5sDUhNlKCPraHsRWG6JLg36yjPvlfklg2sR2Kl15ECUqYLgbekTcdQpwACRJLKwTuOSauKZvd9gsOI4zjqhOmWCpfZl4EAGF)7gYT64z6lfUHkbuO(gAEDSg(gsMcWtP3WHJdBWQoEoxi5c0bkdeGYILaKKU4CPmxmd8CHKRcljyzY5CHKRRC)0PuhplitbAe4bNloEUUYvnGr9syKBEYL6CpgJCHKRT568IrbrLvtep4CTNloEUeeYtJC3cIkRMigwPPkx73qcveplb6aLbM7PyEb3tTP7F3qUvhptFPWnujGc13qleQJ1W3qYuaEk9goCCydw1XZ5cjxGoqzGauwSeGK0fNlL5I5XIFZfsUkSKGLjNZfsUUY9tNsD8SGmfOrGhCU4456kx1ag1lHrU5jxQZ9ymYfsU2MRZlgfevwnr8GZ1EU445sqipnYDliQSAIyyLMQCTNlKCTnxNxmkoxn9W0s2cg5MhlUbsU5bAfiw8GVHeQiEwc0bkdm3tX8cUN(p3)UHCRoEM(sHBOsafQVHga796iJED4BizkapLEdhooSbR645CHKlqhOmqaklwcqs6IZLYCXmWZnGCh2sR2KlKCvyjbltoNlKCDL7NoL64zbzkqJap4CXXZvnGr9syKBEYL6CpgJCXXZLGqEAK7wquz1eXWknv5A)gsOI4zjqhOmWCpfZl4EQnF)7gYT64z6lfUHKPa8u6nuHLeSm58nujGc13WiAiSefLTcEdFb3tXeJ7F3qUvhptFPWnKmfGNsVHUYLj(c2WIQLAtvU445YeFbByHb51rwTeZCXXZLj(c2Wc)R1rwTeZCTNlKCDLRT5sqFCRnq0fuSazu5CXXZ1vUQbmQxcJCZtUuNRn)BUqY1vUF6uQJNfKPanc8GZfhpx1ag1lHrU5jxQZ9ymYfhp3pDk1XZIYiveNR9CHKRRC)0PuhpliO(dDML0SHQMKlKCTnxcc5PrUBbb1FOZSeGLLg4AkGr8GZfhpxBZ9tNsD8SGG6p0zwsZgQAsUqY12CjiKNg5Ufevwnr8GZ1EU2Z1EUqY1vUeeYtJC3cIkRMig2sR2KlL5Emg5IJNRAaJ6LWi38KlL5AZyKlKCjiKNg5Ufevwnr8GZfsUUYLGqEAK7wWwWi38iDqnTyylTAtUuNRsafQfgGoXAybtrM8aSeuwCU445ABUe0h3AdeNPAkTZ1EU445glOybYHT0Qn5sDUyIrU2ZfsUUYLgbekTcdQpwACRJLKwTuOSyylTAtUuM7)ZfhpxBZLG(4wBGOzYG8OHox73qLakuFdJVHkjkkz)R5l4EkMyE)7gYT64z6lfUHKPa8u6n0vUmXxWgw4FToYMPiixC8CzIVGnSWG86iBMIGCXXZLj(c2WcTPs2mfb5IJNRZlgfoQxBclrrP69sa2QHAKTcEdlg2sR2KlL5(FXV5IJNRZlgfoQxBclrrP69sa2QHAK6q0MfdBPvBYLYC)V43CXXZvnGr9syKBEYLYCTzmYfsUeeYtJC3cIkRMigwPPkx75cjxx5sqipnYDliQSAIyylTAtUuM7XyKloEUeeYtJC3cIkRMigwPPkx75IJNBSGIfih2sR2Kl15Ijg3qLakuFdpxn9W0sdCnfWCb3tXmO7F3qUvhptFPWnKmfGNsVHUYvnGr9syKBEYLYCTzmYfsUUY15fJIZvtpmTKTGrU5XIBGKBEGwbIfp4CXXZ12CjOpU1giot1uANR9CXXZLG(4wBGOlOybYOY5IJNRZlgfoEeI2)maXdoxi568IrHJhHO9pdqmSLwTjxQZnimYnGCDL7)Z1gYLGA6xbeWdtkdlvFbTT4gi4wD8mDU2Z1EUqY1vU2Mlb9XT2arxqXcKrLZfhpxcc5PrUBbb1FOZSeGLLg4AkGr8GZfhp3ybflqoSLwTjxQZLGqEAK7wqq9h6mlbyzPbUMcyedBPvBYnGCd8CXXZnwqXcKdBPvBY9O5I5)GrUuNBqyKBa56k3)NRnKlb10VciGhMugwQ(cABXnqWT64z6CTNR9BOsafQVHe2ZgqPEP6lOTf3Gl4EkMhF)7gYT64z6lfUHKPa8u6n0vUQbmQxcJCZtUuMRnJrUqY1vUoVyuCUA6HPLSfmYnpwCdKCZd0kqS4bNloEU2Mlb9XT2aXzQMs7CTNloEUe0h3AdeDbflqgvoxC8CDEXOWXJq0(NbiEW5cjxNxmkC8ieT)zaIHT0Qn5sDUhJrUbKRRC)FU2qUeut)kGaEyszyP6lOTf3ab3QJNPZ1EU2ZfsUUY12CjOpU1gi6ckwGmQCU445sqipnYDliO(dDMLaSS0axtbmIhCU445(PtPoEwqq9h6mlPzdvnjxi5glOybYHT0Qn5szUy(pyKBa5geg5gqUUY9)5Ad5sqn9Rac4HjLHLQVG2wCdeCRoEMox75IJNBSGIfih2sR2Kl15sqipnYDliO(dDMLaSS0axtbmIHT0Qn5gqUbEU445glOybYHT0Qn5sDUhJrUbKRRC)FU2qUeut)kGaEyszyP6lOTf3ab3QJNPZ1EU2VHkbuO(gwnrNwbfQVG7Py()7F3qUvhptFPWnKmfGNsVHUY9tNsD8SGG6p0zwsZgQAsUqYnwqXcKdBPvBYLYCX8ymYfhpxNxmkiQSAI4bNR9CHKRRCDEXOWr9AtyjkkvVxcWwnuJSvWByHbOKZYp1)4CPm3JXixC8CDEXOWr9AtyjkkvVxcWwnuJuhI2SWauYz5N6FCUuM7XyKR9CXXZnwqXcKdBPvBYL6CXeJBOsafQVHeu)HoZsawwAGRPaMl4EkM)E)7gYT64z6lfUHKPa8u6nKG(4wBGOlOybYOY5cjxx5(PtPoEwqq9h6mlPzdvnjxC8CjiKNg5UfevwnrmSLwTjxQZftmY1EUqYvnGr9syKBEYLYC)fJCHKlbH80i3TGG6p0zwcWYsdCnfWig2sR2Kl15Ijg3qLakuFdnaDmVbkFb3tXmWV)Dd5wD8m9Lc3qe8n0WGBOsafQVHF6uQJNVHFQ)X3qM4lydlQw6FTo5Ad5(p5(tUkbuOwya6eRHfmfzYdWsqzX5gqU2Mlt8fSHfvl9VwNCTHCd8C)jxLakulCpkaRGPitEawcklo3aYfdrq5(tUgy27LyvdGVHF6iB1IVHQb(idpHm5cUNIPnD)7gYT64z6lfUHKPa8u6n0vUUYnwqXcKdBPvBYL6C)FU4456kxNxmkg9JB0ZiJd3bIkXWwA1MCPoxOeAHLsXCTHCjC5Z1vUQbmQxcJCZtU)K7XyKR9CHKRZlgfJ(Xn6zKXH7arL4bNR9CTNloEUUYvnGr9syKBEYnGC)0Puhplud8rgEczsU2qUoVyuWeFbByPb51rmSLwTj3aYLgbeX3qLefLS)1SauKZg5WwA15Ad5gK43CPmxmdcJCXXZvnGr9syKBEYnGC)0Puhplud8rgEczsU2qUoVyuWeFbByP)16ig2sR2KBa5sJaI4BOsIIs2)AwakYzJCylT6CTHCds8BUuMlMbHrU2ZfsUmXxWgwuTuBQYfsUUY1vU2MlbH80i3TGOYQjIhCU445sqFCRnqCMQP0oxi5ABUeeYtJC3c2cg5MhPdQPfp4CTNloEUe0h3AdeDbflqgvox75IJNRZlgfevwnrmSLwTjxkZ9FYfsU2MRZlgfJ(Xn6zKXH7arL4bNR9BOsafQVHgGoM3aLVG7Py(p3)UHCRoEM(sHBizkapLEdDLRZlgfmXxWgw6FToIhCU4456kxcwDGYMCpKBq5cj3Hjy1bklbLfNl15(BU2ZfhpxcwDGYMCpK7X5Apxi5QWscwMC(gQeqH6ByZULwiuFb3tX0MV)Dd5wD8m9Lc3qYuaEk9g6kxNxmkyIVGnS0)ADep4CXXZ1vUeS6aLn5Ei3GYfsUdtWQduwckloxQZ93CTNloEUeS6aLn5Ei3JZ1EUqYvHLeSm58nujGc13qSQpkTqO(cUNgeg3)UHCRoEM(sHBizkapLEdDLRZlgfmXxWgw6FToIhCU4456kxcwDGYMCpKBq5cj3Hjy1bklbLfNl15(BU2ZfhpxcwDGYMCpK7X5Apxi5QWscwMC(gQeqH6By859sleQVG7PbH59VBOsafQVHU1zk0irrj7FnFd5wD8m9LcxW90Gc6(3nKB1XZ0xkCdjtb4P0Bit8fSHfvl9VwNCXXZLj(c2WcdYRJSzkcYfhpxM4lydl0MkzZueKloEUoVyu4wNPqJefLS)1S4bNlKCzIVGnSOAP)16KloEUUY15fJcIkRMig2sR2Kl15QeqHAH7rbyfmfzYdWsqzX5cjxNxmkiQSAI4bNR9BOsafQVHgGoXA4l4EAqhF)7gQeqH6BO7rbyVHCRoEM(sHl4EAq))(3nKB1XZ0xkCdvcOq9nCETujGc1sFza3qFzaYwT4Byu9Ea25DbxWnur89V7PyE)7gYT64z6lfUHKPa8u6n05fJcdqNO69IHJdBWQoEoxi56kxBZDEnhrduw4PIOJAKrpZGQHkH6llydl4)1RGHz6CXXZfuwCUhn3))BUuMRZlgfgGor17fdBPvBYnGCdkx73qLakuFdnaDIQ3Fb3td6(3nKB1XZ0xkCdvcOq9n086yn8nKmfGNsVHkSKGLjNZfsUmXxWgwuTuBQYfsUdhh2GvD8CUqYfOdugiaLflbijDX5szUy()Cps5AGzVxc0bkdm5gqUdBPvBUHeQiEwc0bkdm3tX8cUNE89VBi3QJNPVu4gQeqH6BOsRWG6JLg36yDdjtb4P0BOT5ckY5QHMlKCTnxLakuluAfguFS04whljTAPqzr1YOVGIfKloEU0iGqPvyq9XsJBDSK0QLcLfgGsoNl15ECUqYLgbekTcdQpwACRJLKwTuOSyylTAtUuN7X3qcveplb6aLbM7PyEb3t))9VBi3QJNPVu4gQeqH6BOfc1XA4BizkapLEdhooSbR645CHKlqhOmqaklwcqs6IZLYCDLlM)p3aY1vUgy27LaDGYaJWa0jwdNRnKlMIFZ1EU2Z9NCnWS3lb6aLbMCdi3HT0Qn5cjxx5sqipnYDliQSAIyyLMQCXXZ1aZEVeOdugyegGoXA4CPo3JZfhpxx5YeFbByr1sdYRtU445YeFbByr1sheaBU445YeFbByr1s)R1jxi5ABUa1ZnqyqpVefLaSSmIg2aeCRoEMox75cjxx5AGzVxc0bkdmcdqNynCUuNlMyKRnKRRCXm3aYfOEUbcG7QLwiuBeCRoEMox75Apxi5QgWOEjmYnp5szU)IrUhPCDEXOWa0jQEVyylTAtU2qUbEU2ZfsU2MRZlgfNRMEyAjBbJCZJf3aj38aTcelEW5cjxfwsWYKZ3qcveplb6aLbM7PyEb3t)9(3nKB1XZ0xkCdjtb4P0BOcljyzY5BOsafQVHr0qyjkkBf8g(cUNg43)UHCRoEM(sHBizkapLEdDEXOGOYQjIh8nujGc13Wr)4g9mY4WDGO6cUNAt3)UHCRoEM(sHBizkapLEdDLRZlgfgGor17fp4CXXZvnGr9syKBEYLYC)fJCTNlKCTnxNxmkmiVbuew8GZfsU2MRZlgfevwnr8GZfsUUYTAapWiVcyAzSGIfih2sR2Kl15sqipnYDliO(dDMLaSS0axtbmIHT0Qn5gqU2uU445wnGhyKxbmTmwqXcKdBPvBY9O5I5)GrUuNBqbLloEUeeYtJC3ccQ)qNzjallnW1uaJ4bNloEU2Mlb9XT2arxqXcKrLZ1(nujGc13qc7zdOuVu9f02IBWfCp9FU)Dd5wD8m9Lc3qYuaEk9gglOybYHT0Qn5sDUy(BU4456kxNxmkGNYcn0L6L6q0Uis4N3OJ4t9poxQZnOFXixC8CDEXOaEkl0qxQxQdr7IiHFEJoIp1)4CP8qUb9lg5Apxi568IrHbOtu9EXdoxi5sqipnYDliQSAIyylTAtUuM7VyCdvcOq9nSAIoTckuFb3tT57F3qUvhptFPWnujGc13qdG9EDKrVo8nKmfGNsVHdhh2GvD8CUqYfuwSeGK0fNlL5I5V5cjxdm79sGoqzGrya6eRHZL6C)FUqYvHLeSm5CUqY1vUoVyuquz1eXWwA1MCPmxmXixC8CTnxNxmkiQSAI4bNR9BiHkINLaDGYaZ9umVG7PyIX9VBi3QJNPVu4gIGVHggCdvcOq9n8tNsD88n8t9p(g68Irb8uwOHUuVuhI2frc)8gDeFQ)X5sDUb9lg5EKYvnGr9syKBEYfsUUYLGqEAK7wquz1eXWwA1MCdixmXixkZnwqXcKdBPvBYfhpxcc5PrUBbrLvtedBPvBYnGCpgJCPo3ybflqoSLwTjxi5glOybYHT0Qn5szUyEmg5IJNRZlgfevwnrmSLwTjxkZ1MY1EUqYLj(c2WIQLAtvU445glOybYHT0Qn5E0CXmimYL6CX83B4NoYwT4Bib1FOZSKGA6cuO(cUNIjM3)UHCRoEM(sHBizkapLEd)0PuhpliO(dDMLeutxGc15cjx1ag1lHrU5jxQZ9xmUHkbuO(gsq9h6mlbyzPbUMcyUG7Pyg09VBi3QJNPVu4gsMcWtP3qM4lydlQwQnv5cjxfwsWYKZ5cjxNxmkGNYcn0L6L6q0Uis4N3OJ4t9poxQZnOFXixi56kxAeqO0kmO(yPXTowsA1sHYcqroxn0CXXZ12CjOpU1giAMmipAOZfhpxdm79sGoqzGjxkZnOCTFdvcOq9nm(gQKOOK9VMVG7PyE89VBi3QJNPVu4gsMcWtP3qNxmkqndWAKW8qyyqHAXdoxi56kxNxmkmaDIQ3lgooSbR645CXXZvnGr9syKBEYLYCTzmY1(nujGc13qdqNO69xW9um))9VBi3QJNPVu4gsMcWtP3qc6JBTbIUGIfiJkNlKC)0PuhpliO(dDMLeutxGc15cjxcc5PrUBbb1FOZSeGLLg4AkGrmSLwTjxQZfkHwyPumxBixcx(CDLRAaJ6LWi38K7p5(lg5Apxi568IrHbOtu9EXWXHnyvhpFdvcOq9n0a0jQE)fCpfZFV)Dd5wD8m9Lc3qYuaEk9gsqFCRnq0fuSazu5CHK7NoL64zbb1FOZSKGA6cuOoxi5sqipnYDliO(dDMLaSS0axtbmIHT0Qn5sDUqj0clLI5Ad5s4YNRRCvdyuVeg5MNC)j3JXix75cjxNxmkmaDIQ3lEW3qLakuFdnaDmVbkFb3tXmWV)Dd5wD8m9Lc3qe8n0WGBOsafQVHF6uQJNVHFQ)X3q1ag1lHrU5jxkZ9FWi3JuUUY15fJcdqNO69IHT0Qn5Ad5ECU)KRbM9Ejw1a4CTN7rkxx5sJaI4BOsIIs2)AwmSLwTjxBi3FZ1EUqY15fJcdqNO69Ih8n8thzRw8n0a0jQEV0nQbYO69sumEb3tX0MU)Dd5wD8m9Lc3qYuaEk9g68IrbQzawJK4zDKFLPqT4bNloEU2MRbOtSgwOWscwMCoxC8CDLRZlgfevwnrmSLwTjxQZ93CHKRZlgfevwnr8GZfhpxx568IrXOFCJEgzC4oqujg2sR2Kl15cLqlSukMRnKlHlFUUYvnGr9syKBEY9NCpgJCTNlKCDEXOy0pUrpJmoChiQep4CTNR9CHK7NoL64zHbOtu9EPBudKr17LOymxi5AGzVxc0bkdmcdqNO695sDUhFdvcOq9n0a0X8gO8fCpfZ)5(3nKB1XZ0xkCdjtb4P0BORCzIVGnSOAP2uLlKCjiKNg5UfevwnrmSLwTjxkZ9xmYfhpxx5sWQdu2K7HCdkxi5ombRoqzjOS4CPo3FZ1EU445sWQdu2K7HCpox75cjxfwsWYKZ3qLakuFdB2T0cH6l4EkM289VBi3QJNPVu4gsMcWtP3qx5YeFbByr1sTPkxi5sqipnYDliQSAIyylTAtUuM7VyKloEUUYLGvhOSj3d5guUqYDycwDGYsqzX5sDU)MR9CXXZLGvhOSj3d5ECU2ZfsUkSKGLjNVHkbuO(gIv9rPfc1xW90GW4(3nKB1XZ0xkCdjtb4P0BORCzIVGnSOAP2uLlKCjiKNg5UfevwnrmSLwTjxkZ9xmYfhpxx5sWQdu2K7HCdkxi5ombRoqzjOS4CPo3FZ1EU445sWQdu2K7HCpox75cjxfwsWYKZ3qLakuFdJpVxAHq9fCpnimV)DdvcOq9n0TotHgjkkz)R5Bi3QJNPVu4cUNguq3)UHCRoEM(sHBic(gAyWnujGc13WpDk1XZ3Wp1)4BObM9EjqhOmWimaDI1W5szU)tUbKB0JqtUUY1snaEOs(P(hN7p5geg5Ap3aYn6rOjxx568IrHbOJ5nqzjBbJCZJf3aHbOKZ5(tU)px73WpDKTAX3qdqNynSSAPb515cUNg0X3)UHCRoEM(sHBizkapLEdzIVGnSW)ADKntrqU445YeFbByH2ujBMIGCHK7NoL64zrzKepRFCU445YeFbByr1sdYRtUqY12C)0PuhplmaDI1WYQLgKxNCXXZ15fJcIkRMig2sR2Kl15QeqHAHbOtSgwWuKjpalbLfNlKCTn3pDk1XZIYijEw)4CHKRZlgfevwnrmSLwTjxQZLPitEawckloxi568IrbrLvtep4CXXZ15fJIr)4g9mY4WDGOs8GZfsUgy27LyvdGZLYCXqe45IJNRT5(PtPoEwugjXZ6hNlKCDEXOGOYQjIHT0Qn5szUmfzYdWsqzX3qLakuFdDpka7fCpnO)F)7gQeqH6BObOtSg(gYT64z6lfUG7Pb979VBi3QJNPVu4gQeqH6B48APsafQL(YaUH(YaKTAX3WO69aSZ7cUGByu9Ea25D)7EkM3)UHCRoEM(sHBizkapLEdTn351CenqzHJ61MWsuuQEVeGTAOgb)VEfmmtFdvcOq9n0a0X8gO8fCpnO7F3qUvhptFPWnujGc13qZRJ1W3qYuaEk9gsJacleQJ1WIHT0Qn5szUdBPvBUHeQiEwc0bkdm3tX8cUNE89VBOsafQVHwiuhRHVHCRoEM(sHl4cUHgW9V7PyE)7gYT64z6lfUHkbuO(gQ0kmO(yPXTow3qYuaEk9gABU0iGqPvyq9XsJBDSK0QLcLfGICUAO5cjxBZvjGc1cLwHb1hlnU1XssRwkuwuTm6lOyb5cjxx5ABU0iGqPvyq9XsJBDSKyz1laf5C1qZfhpxAeqO0kmO(yPXTowsSS6fdBPvBYLYC)nx75IJNlnciuAfguFS04whljTAPqzHbOKZ5sDUhNlKCPraHsRWG6JLg36yjPvlfklg2sR2Kl15ECUqYLgbekTcdQpwACRJLKwTuOSauKZvd9gsOI4zjqhOmWCpfZl4EAq3)UHCRoEM(sHBOsafQVHwiuhRHVHKPa8u6n0vUoVyuquz1eXWwA1MCPm3FZfsUUY15fJIr)4g9mY4WDGOsmSLwTjxkZ93CXXZ12CDEXOy0pUrpJmoChiQep4CTNloEU2MRZlgfevwnr8GZfhpx1ag1lHrU5jxQZ9ymY1EUqY1vU2MRZlgfNRMEyAjBbJCZJf3aj38aTcelEW5IJNRAaJ6LWi38Kl15Emg5Apxi5QWscwMC(gsOI4zjqhOmWCpfZl4E6X3)UHCRoEM(sHBOsafQVHMxhRHVHKPa8u6nC44WgSQJNZfsUaDGYabOSyjajPloxkZfZGYfsUUY15fJcIkRMig2sR2KlL5(BUqY1vUoVyum6h3ONrghUdevIHT0Qn5szU)MloEU2MRZlgfJ(Xn6zKXH7arL4bNR9CXXZ12CDEXOGOYQjIhCU445QgWOEjmYnp5sDUhJrU2ZfsUUY12CDEXO4C10dtlzlyKBES4gi5MhOvGyXdoxC8CvdyuVeg5MNCPo3JXix75cjxfwsWYKZ3qcveplb6aLbM7PyEb3t))9VBi3QJNPVu4gQeqH6BObWEVoYOxh(gsMcWtP3WHJdBWQoEoxi5c0bkdeGYILaKKU4CPmxmd8CHKRRCDEXOGOYQjIHT0Qn5szU)MlKCDLRZlgfJ(Xn6zKXH7arLyylTAtUuM7V5IJNRT568IrXOFCJEgzC4oqujEW5ApxC8CTnxNxmkiQSAI4bNloEUQbmQxcJCZtUuN7XyKR9CHKRRCTnxNxmkoxn9W0s2cg5MhlUbsU5bAfiw8GZfhpx1ag1lHrU5jxQZ9ymY1EUqYvHLeSm58nKqfXZsGoqzG5EkMxW90FV)Dd5wD8m9Lc3qYuaEk9gQWscwMC(gQeqH6ByenewIIYwbVHVG7Pb(9VBi3QJNPVu4gsMcWtP3qNxmkiQSAI4bFdvcOq9nC0pUrpJmoChiQUG7P209VBi3QJNPVu4gsMcWtP3qx56kxNxmkyIVGnS0G86ig2sR2KlL5Ijg5IJNRZlgfmXxWgw6FToIHT0Qn5szUyIrU2ZfsUeeYtJC3cIkRMig2sR2KlL5Emg5cjxx568Irb8uwOHUuVuhI2frc)8gDeFQ)X5sDUb9FmYfhpxBZDEnhrduwapLfAOl1l1HODrKWpVrhb)VEfmmtNR9CTNloEUoVyuapLfAOl1l1HODrKWpVrhXN6FCUuEi3GSjmYfhpxcc5PrUBbrLvtedR0uLlKCDLRAaJ6LWi38KlL5AZyKloEUF6uQJNfLrQiox73qLakuFdpxn9W0sdCnfWCb3t)N7F3qUvhptFPWnKmfGNsVHUYvnGr9syKBEYLYCTzmYfsUUY15fJIZvtpmTKTGrU5XIBGKBEGwbIfp4CXXZ12CjOpU1giot1uANR9CXXZLG(4wBGOlOybYOY5IJN7NoL64zrzKkIZfhpxNxmkC8ieT)zaIhCUqY15fJchpcr7FgGyylTAtUuNBqyKBa56kxx5AZ5Ad5oVMJObklGNYcn0L6L6q0Uis4N3OJG)xVcgMPZ1EUbKRRC)FU2qUeut)kGaEyszyP6lOTf3ab3QJNPZ1EU2Z1EUqY12CDEXOGOYQjIhCUqY1vUXckwGCylTAtUuNlbH80i3TGG6p0zwcWYsdCnfWig2sR2KBa5At5IJNBSGIfih2sR2Kl15guq5gqUUY1MZ1gY1vUoVyuapLfAOl1l1HODrKWpVrhXN6FCUuMlMyGrU2Z1EU445glOybYHT0Qn5E0CX8FWixQZnOGYfhpxcc5PrUBbb1FOZSeGLLg4AkGr8GZfhpxBZLG(4wBGOlOybYOY5A)gQeqH6BiH9SbuQxQ(cABXn4cUNAZ3)UHCRoEM(sHBizkapLEdDLRAaJ6LWi38KlL5AZyKlKCDLRZlgfNRMEyAjBbJCZJf3aj38aTcelEW5IJNRT5sqFCRnqCMQP0ox75IJNlb9XT2arxqXcKrLZfhp3pDk1XZIYiveNloEUoVyu44riA)Zaep4CHKRZlgfoEeI2)maXWwA1MCPo3JXi3aY1vUUY1MZ1gYDEnhrduwapLfAOl1l1HODrKWpVrhb)VEfmmtNR9Cdixx5()CTHCjOM(vab8WKYWs1xqBlUbcUvhptNR9CTNR9CHKRT568IrbrLvtep4CHKRRCJfuSa5WwA1MCPoxcc5PrUBbb1FOZSeGLLg4AkGrmSLwTj3aY1MYfhp3ybflqoSLwTjxQZ94GYnGCDLRnNRnKRRCDEXOaEkl0qxQxQdr7IiHFEJoIp1)4CPmxmXaJCTNR9CXXZnwqXcKdBPvBY9O5I5)GrUuN7XbLloEUeeYtJC3ccQ)qNzjallnW1uaJ4bNloEU2Mlb9XT2arxqXcKrLZ1(nujGc13WQj60kOq9fCpftmU)Dd5wD8m9Lc3qe8n0WGBOsafQVHF6uQJNVHFQ)X3qc6JBTbIUGIfiJkNlKCDLRZlgfWtzHg6s9sDiAxej8ZB0r8P(hNl15g0)Xixi56kxcc5PrUBbrLvtedBPvBYnGCXeJCPm3ybflqoSLwTjxC8CjiKNg5UfevwnrmSLwTj3aY9ymYL6CJfuSa5WwA1MCHKBSGIfih2sR2KlL5I5XyKloEUoVyuquz1eXWwA1MCPmxBkx75cjxNxmkyIVGnS0G86ig2sR2KlL5Ijg5IJNBSGIfih2sR2K7rZfZGWixQZfZFZ1(n8thzRw8nKG6p0zwsqnDbkuFb3tXeZ7F3qUvhptFPWnebFdnm4gQeqH6B4NoL645B4N6F8n0vU2MlbH80i3TGOYQjIHvAQYfhpxBZ9tNsD8SGG6p0zwsqnDbkuNlKCjOpU1gi6ckwGmQCU2VHF6iB1IVHg9JLr0ijQSAYfCpfZGU)Dd5wD8m9Lc3qYuaEk9g(PtPoEwqq9h6mljOMUafQZfsUQbmQxcJCZtUuN7XyCdvcOq9nKG6p0zwcWYsdCnfWCb3tX847F3qUvhptFPWnKmfGNsVHmXxWgwuTuBQYfsUkSKGLjNZfsUoVyuapLfAOl1l1HODrKWpVrhXN6FCUuNBq)hJCHKRRCPraHsRWG6JLg36yjPvlfklaf5C1qZfhpxBZLG(4wBGOzYG8OHox75cj3pDk1XZcJ(XYiAKevwn5gQeqH6By8nujrrj7FnFb3tX8)3)UHCRoEM(sHBizkapLEdDEXOa1maRrcZdHHbfQfp4CHKRZlgfgGor17fdhh2GvD88nujGc13qdqNO69xW9um)9(3n05fJYwT4BObOJhn03qLakuFdjAtyV05fJ3qYuaEk9g68IrHbOJhn0IHT0Qn5sDU)MlKCDLRZlgfmXxWgwAqEDedBPvBYLYC)nxC8CDEXOGj(c2Ws)R1rmSLwTjxkZ93CTNlKCvdyuVeg5MNCPmxBgJBi3QJNPVu4cUNIzGF)7gYT64z6lfUHKPa8u6nKG(4wBGOlOybYOY5cj3pDk1XZccQ)qNzjb10fOqDUqYLGqEAK7wqq9h6mlbyzPbUMcyedBPvBYL6CHsOfwkfZ1gYLWLpxx5QgWOEjmYnp5(tUhJrU2VHkbuO(gAa6yEdu(cUNIPnD)7gYT64z6lfUHKPa8u6neOEUbcdG9EDK0tfbcUvhptNlKCTnxG65gimaD8OHwWT64z6CHKRZlgfgGor17fdhh2GvD8CUqY1vUoVyuWeFbByP)16ig2sR2KlL5g45cjxM4lydlQw6FTo5cjxNxmkGNYcn0L6L6q0Uis4N3OJ4t9poxQZnOFXixC8CDEXOaEkl0qxQxQdr7IiHFEJoIp1)4CP8qUb9lg5cjx1ag1lHrU5jxkZ1MXixC8CPraHsRWG6JLg36yjPvlfklg2sR2KlL5(p5IJNRsafQfkTcdQpwACRJLKwTuOSOAz0xqXcY1EUqY12CjiKNg5UfevwnrmSst1nujGc13qdqNO69xW9um)N7F3qUvhptFPWnKmfGNsVHoVyuGAgG1ijEwh5xzkulEW5IJNRZlgfNRMEyAjBbJCZJf3aj38aTcelEW5IJNRZlgfevwnr8GZfsUUY15fJIr)4g9mY4WDGOsmSLwTjxQZfkHwyPumxBixcx(CDLRAaJ6LWi38K7p5Emg5Apxi568IrXOFCJEgzC4oqujEW5IJNRT568IrXOFCJEgzC4oqujEW5cjxBZLGqEAK7wm6h3ONrghUdevIHvAQYfhpxBZLG(4wBG4JBawQMCTNloEUQbmQxcJCZtUuMRnJrUqYLj(c2WIQLAt1nujGc13qdqhZBGYxW9umT57F3qUvhptFPWnKmfGNsVHa1Znqya64rdTGB1XZ05cjxx568IrHbOJhn0IhCU445QgWOEjmYnp5szU2mg5Apxi568IrHbOJhn0cdqjNZL6Cpoxi56kxNxmkyIVGnS0G86iEW5IJNRZlgfmXxWgw6FToIhCU2ZfsUoVyuapLfAOl1l1HODrKWpVrhXN6FCUuNBq2eg5cjxx5sqipnYDliQSAIyylTAtUuMlMyKloEU2M7NoL64zbb1FOZSKGA6cuOoxi5sqFCRnq0fuSazu5CTFdvcOq9n0a0X8gO8fCpnimU)Dd5wD8m9Lc3qYuaEk9g6kxNxmkGNYcn0L6L6q0Uis4N3OJ4t9poxQZniBcJCXXZ15fJc4PSqdDPEPoeTlIe(5n6i(u)JZL6Cd6xmYfsUa1ZnqyaS3RJKEQiqWT64z6CTNlKCDEXOGj(c2WsdYRJyylTAtUuMRnLlKCzIVGnSOAPb51jxi5ABUoVyuGAgG1iH5HWWGc1IhCUqY12CbQNBGWa0XJgAb3QJNPZfsUeeYtJC3cIkRMig2sR2KlL5At5cjxx5sqipnYDloxn9W0sdCnfWig2sR2KlL5At5IJNRT5sqFCRnqCMQP0ox73qLakuFdnaDmVbkFb3tdcZ7F3qUvhptFPWnKmfGNsVHUY15fJcM4lydl9VwhXdoxC8CDLlbRoqztUhYnOCHK7WeS6aLLGYIZL6C)nx75IJNlbRoqztUhY94CTNlKCvyjbltoNlKC)0Puhplm6hlJOrsuz1KBOsafQVHn7wAHq9fCpnOGU)Dd5wD8m9Lc3qYuaEk9g6kxNxmkyIVGnS0)ADep4CHKRT5sqFCRnqCMQP0oxC8CDLRZlgfNRMEyAjBbJCZJf3aj38aTcelEW5cjxc6JBTbIZunL25ApxC8CDLlbRoqztUhYnOCHK7WeS6aLLGYIZL6C)nx75IJNlbRoqztUhY94CXXZ15fJcIkRMiEW5Apxi5QWscwMCoxi5(PtPoEwy0pwgrJKOYQj3qLakuFdXQ(O0cH6l4EAqhF)7gYT64z6lfUHKPa8u6n0vUoVyuWeFbByP)16iEW5cjxBZLG(4wBG4mvtPDU4456kxNxmkoxn9W0s2cg5MhlUbsU5bAfiw8GZfsUe0h3AdeNPAkTZ1EU4456kxcwDGYMCpKBq5cj3Hjy1bklbLfNl15(BU2ZfhpxcwDGYMCpK7X5IJNRZlgfevwnr8GZ1EUqYvHLeSm5CUqY9tNsD8SWOFSmIgjrLvtUHkbuO(ggFEV0cH6l4EAq))(3nujGc13q36mfAKOOK9VMVHCRoEM(sHl4EAq)E)7gYT64z6lfUHKPa8u6nKj(c2WIQL(xRtU445YeFbByHb51r2mfb5IJNlt8fSHfAtLSzkcYfhpxNxmkCRZuOrIIs2)Aw8GZfsUoVyuWeFbByP)16iEW5IJNRRCDEXOGOYQjIHT0Qn5sDUkbuOw4EuawbtrM8aSeuwCUqY15fJcIkRMiEW5A)gQeqH6BObOtSg(cUNguGF)7gQeqH6BO7rbyVHCRoEM(sHl4EAq209VBi3QJNPVu4gQeqH6B48APsafQL(YaUH(YaKTAX3WO69aSZ7cUGBi8WeKLJcU)DpfZ7F3qLakuFdTqO(C1YiASUHCRoEM(sHl4EAq3)UHkbuO(g6Eua2Bi3QJNPVu4cUNE89VBOsafQVHUhfG9gYT64z6lfUG7P))(3nKB1XZ0xkCdjtb4P0BObM9EjqhOmWimaDIQ3Nl15()BOsafQVHgGoM3aLVG7P)E)7gYT64z6lfUHi4BOHb3qLakuFd)0PuhpFd)u)JVHoiJjxi5g9i0KRRCDLBSGIfih2sR2K7rk3GWix75(tUygeg5ApxkZn6rOjxx56k3ybflqoSLwTj3JuUb9BUhPCDLlMyKRnKlq9Cdevt0PvqHAb3QJNPZ1EUhPCDL7)Z1gYLGA6xbeWdtkdlvFbTT4gi4wD8mDU2Z1EU)KlM)dg5A)g(PJSvl(gsq9h6mlPzdvn5cUGl4g(XJPq990GWiimWedmd8BOBD6QHAUHh5SXyJ90)9tpYBJYn3)WY5wwWObKBen5(VrpSA5unnp)B5o8)6vdtNRbzX5QpaYsbmDUeSAdLnIm4JOAo3GSr5gyO(JhatNByzfy5AOQbkfZ9O5cq5Eepnx66RmfQZfbZJcqtUU(XEUUWKI2fzWhr1CUyIHnk3ad1F8ay6CdlRalxdvnqPyUh9O5cq5Eepnxle9Z)m5IG5rbOjxxh1EUUWKI2fzWhr1CUyIPnk3ad1F8ay6CdlRalxdvnqPyUh9O5cq5Eepnxle9Z)m5IG5rbOjxxh1EUUWKI2fzWhr1CUygKnk3ad1F8ay6CdlRalxdvnqPyUh9O5cq5Eepnxle9Z)m5IG5rbOjxxh1EUUWKI2fzWhr1CUyg42OCdmu)XdGPZnSScSCnu1aLI5E0CbOCpINMlD9vMc15IG5rbOjxx)ypxxysr7Im4m4JC2ySXE6)(Ph5Tr5M7Fy5Clly0aYnIMC)3GhMGSCuW)wUd)VE1W05AqwCU6dGSuatNlbR2qzJid(iQMZ9xBuUbgQ)4bW05gwwbwUgQAGsXCpAUauUhXtZLU(ktH6CrW8Oa0KRRFSNRRGOODrgCg8roBm2yp9F)0J82OCZ9pSCULfmAa5grtU)BkI)3YD4)1RgMoxdYIZvFaKLcy6Cjy1gkBezWhr1CUyAJYnWq9hpaMo3WYkWY1qvdukM7rpAUauUhXtZ1cr)8ptUiyEuaAY11rTNRlmPODrg8runN7)Tr5gyO(JhatNByzfy5AOQbkfZ9O5cq5Eepnx66RmfQZfbZJcqtUU(XEUUWKI2fzWhr1CU2Knk3ad1F8ay6CdlRalxdvnqPyUh9O5cq5Eepnxle9Z)m5IG5rbOjxxh1EUUWKI2fzWhr1CU)Jnk3ad1F8ay6CdlRalxdvnqPyUh9O5cq5Eepnxle9Z)m5IG5rbOjxxh1EUUWKI2fzWhr1CUyIHnk3ad1F8ay6CdlRalxdvnqPyUh9O5cq5Eepnxle9Z)m5IG5rbOjxxh1EUUWKI2fzWhr1CUy(FBuUbgQ)4bW05gwwbwUgQAGsXCpAUauUhXtZLU(ktH6CrW8Oa0KRRFSNRlmPODrg8runNlM)AJYnWq9hpaMo3WYkWY1qvdukM7rZfGY9iEAU01xzkuNlcMhfGMCD9J9CDHjfTlYGpIQ5CXmWTr5gyO(JhatNByzfy5AOQbkfZ9O5cq5Eepnx66RmfQZfbZJcqtUU(XEUUWKI2fzWhr1CUyAt2OCdmu)XdGPZnSScSCnu1aLI5E0CbOCpINMlD9vMc15IG5rbOjxx)ypxxysr7Im4JOAo3GcYgLBGH6pEamDUHLvGLRHQgOum3JMlaL7r80CPRVYuOoxempkan566h756kikAxKbNbFKZgJn2t)3p9iVnk3C)dlNBzbJgqUr0K7)Mb8VL7W)RxnmDUgKfNR(ailfW05sWQnu2iYGpIQ5C)hBuUbgQ)4bW05gwwbwUgQAGsXCp6rZfGY9iEAUwi6N)zYfbZJcqtUUoQ9CDHjfTlYGpIQ5CTzBuUbgQ)4bW05gwwbwUgQAGsXCp6rZfGY9iEAUwi6N)zYfbZJcqtUUoQ9CDHjfTlYGpIQ5CXedBuUbgQ)4bW05gwwbwUgQAGsXCp6rZfGY9iEAUwi6N)zYfbZJcqtUUoQ9CDHjfTlYGpIQ5CXmWTr5gyO(JhatNByzfy5AOQbkfZ9O5cq5Eepnx66RmfQZfbZJcqtUU(XEUUWKI2fzWhr1CUy(p2OCdmu)XdGPZnSScSCnu1aLI5E0CbOCpINMlD9vMc15IG5rbOjxx)ypxxysr7Im4m4JC2ySXE6)(Ph5Tr5M7Fy5Clly0aYnIMC)3Cqk4Fl3H)xVAy6Cnilox9bqwkGPZLGvBOSrKbFevZ5Izq2OCdmu)XdGPZnSScSCnu1aLI5E0JMlaL7r80CTq0p)ZKlcMhfGMCDDu756ctkAxKbFevZ5IzGBJYnWq9hpaMo3WYkWY1qvdukM7rZfGY9iEAU01xzkuNlcMhfGMCD9J9CDDmfTlYGpIQ5CX0MSr5gyO(JhatNByzfy5AOQbkfZ9O5cq5Eepnx66RmfQZfbZJcqtUU(XEUUWKI2fzWzW)7wWObW05(p5QeqH6C9LbyezW3q4bflpFdTXZLcQxBcN7rwMxrNbBJN7r2eaYHNCXmWpj3GWiimYGZGTXZnWWQnu2yJYGTXZ9iLRngAAMo3qKxNCPaRwImyB8Cps5gyy1gktNlqhOmqwXCjQHn5cq5sOI4zjqhOmWiYGTXZ9iLRnw2c9X05(6MjSXOdv5(PtPoE2KRRsWItYfE4pPbOJ5nq5CpsuMl8WFcdqhZBGY2fzWzWkbuO2iGhMGSCuWbleQpxTmIgRmyLakuBeWdtqwokiGd)4Eua2myLakuBeWdtqwokiGd)4Eua2myLakuBeWdtqwokiGd)ya6yEdu(KkEWaZEVeOdugyegGor17P()zWkbuO2iGhMGSCuqah(5tNsD88jTAXhiO(dDML0SHQMCYN6F8bhKXaj6rOXLRybflqoSLwT5ifeg2pkMbHHDkJEeAC5kwqXcKdBPvBosb97rYfMyyda1ZnqunrNwbfQfCRoEM2(rY1)TbcQPFfqapmPmSu9f02IBGGB1XZ02TFum)hmSNbNbBJN7rwPitEaMox(JhQYfuwCUaSCUkbGMCltU6NwE1XZImyLakuBoyqEDKoSALbReqHAtah(5tNsD88jTAXhkJur8jFQ)XhmWS3lb6aLbgHbOtu9EkXeIlBbQNBGWa0XJgAb3QJNPXXbQNBGWayVxhj9urGGB1XZ02XXnWS3lb6aLbgHbOtu9EkdkdwjGc1Mao8ZNoL645tA1IpugjXZ6hFYN6F8bdm79sGoqzGrya6eRHPeZmyLakuBc4Wpo8y45C1qpPIhCzlb9XT2arxqXcKrLXXTLGqEAK7wqq9h6mlbyzPbUMcyepy7qCEXOGOYQjIhCgSsafQnbC4hyeOq9jv8GZlgfevwnr8GZGvcOqTjGd)8mSSaSLjdwjGc1Mao8Z8APsafQL(YaoPvl(GI4tmGPiGdyEsfp8PtPoEwugPI4myLakuBc4WpZRLkbuOw6ld4KwT4d0dRwovtZZjgWueWbmpPIhMxZr0aLfGYIDJMwspSA5unnpc(F9kyyModwjGc1Mao8Z8APsafQL(YaoPvl(GdsbNyatrahW8KkEyEnhrduw4OETjSefLQ3lbyRgQrW)RxbdZ0zWkbuO2eWHFMxlvcOqT0xgWjTAXhmGtQ4bp)XEk)fJmyLakuBc4WpZRLkbuOw6ld4KwT4dWddRacwPbKbNbReqHAJqr8bdqNO69NuXdoVyuya6evVxmCCydw1XZqCz78AoIgOSWtfrh1iJEMbvdvc1xwWgwW)RxbdZ044GYIp6r))Vu68IrHbOtu9EXWwA1MacYEgSsafQncfXbC4hZRJ1WNqOI4zjqhOmWCaZtQ4bfwsWYKZqyIVGnSOAP2ubz44WgSQJNHa0bkdeGYILaKKUykX8)hjdm79sGoqzGjGHT0QnzWkbuO2iuehWHFuAfguFS04whRtiur8SeOdugyoG5jv8GTGICUAOqSvjGc1cLwHb1hlnU1XssRwkuwuTm6lOyb440iGqPvyq9XsJBDSK0QLcLfgGsot9XqOraHsRWG6JLg36yjPvlfklg2sR2q9XzWkbuO2iuehWHFSqOowdFcHkINLaDGYaZbmpPIhgooSbR64ziaDGYabOSyjajPlMsxy()aCzGzVxc0bkdmcdqNynSnGP4x72pQbM9EjqhOmWeWWwA1giUiiKNg5UfevwnrmSstfoUbM9EjqhOmWimaDI1WuFmoUlM4lydlQwAqEDWXzIVGnSOAPdcGfhNj(c2WIQL(xRdeBbQNBGWGEEjkkbyzzenSbi4wD8mTDiUmWS3lb6aLbgHbOtSgMAmXWgCHzaa1ZnqaCxT0cHAJGB1XZ02TdrnGr9syKBEO8xmosoVyuya6evVxmSLwTXgcC7qS15fJIZvtpmTKTGrU5XIBGKBEGwbIfpyikSKGLjNZGvcOqTrOioGd)erdHLOOSvWB4tQ4bfwsWYKZzWkbuO2iuehWHFg9JB0ZiJd3bIQtQ4bNxmkiQSAI4bNbReqHAJqrCah(HWE2ak1lvFbTT4gCsfp4Y5fJcdqNO69IhmoUAaJ6LWi38q5VyyhIToVyuyqEdOiS4bdXwNxmkiQSAI4bdXv1aEGrEfW0YybflqoSLwTHAcc5PrUBbb1FOZSeGLLg4AkGrmSLwTjaBchVAapWiVcyAzSGIfih2sR2C0JI5)Gb1bfeoobH80i3TGG6p0zwcWYsdCnfWiEW442sqFCRnq0fuSazuz7zWkbuO2iuehWHFQMOtRGc1NuXdUCEXOWa0jQEV4bJJRgWOEjmYnpu(lg2HyRZlgfgK3akclEWqS15fJcIkRMiEWqCvnGhyKxbmTmwqXcKdBPvBOMGqEAK7wqq9h6mlbyzPbUMcyedBPvBcWMWXRgWdmYRaMwglOybYHT0Qnh9Oy(pyq9XbHJtqipnYDliO(dDMLaSS0axtbmIhmoUTe0h3AdeDbflqgv2UsafQncfXbC4NZvtpmT0axtbmNuXdXckwGCylTAd1y(loUlNxmkGNYcn0L6L6q0Uis4N3OJ4t9pM6G(fdCCNxmkGNYcn0L6L6q0Uis4N3OJ4t9pMYdb9lg2H48IrHbOtu9EXdgcbH80i3TGOYQjIHT0Qnu(lgzWkbuO2iuehWHFma271rg96WNqOI4zjqhOmWCaZtQ4HHJdBWQoEgcOSyjajPlMsm)fIbM9EjqhOmWimaDI1Wu)FikSKGLjNH4Y5fJcIkRMig2sR2qjMyGJBRZlgfevwnr8GTNbReqHAJqrCah(5tNsD88jTAXhiO(dDMLeutxGc1N8P(hFW5fJc4PSqdDPEPoeTlIe(5n6i(u)JPoOFX4iPgWOEjmYnpqCrqipnYDliQSAIyylTAtayIbLXckwGCylTAdoobH80i3TGOYQjIHT0QnbCmguhlOybYHT0QnqIfuSa5WwA1gkX8ymWXDEXOGOYQjIHT0QnuAt2HWeFbByr1sTPchpwqXcKdBPvBo6rXmimOgZFZGvcOqTrOioGd)qq9h6mlbyzPbUMcyoPIh(0PuhpliO(dDMLeutxGc1qudyuVeg5MhQ)fJmyLakuBekId4WpX3qLefLS)18jv8at8fSHfvl1MkikSKGLjNH48Irb8uwOHUuVuhI2frc)8gDeFQ)Xuh0VyaXfnciuAfguFS04whljTAPqzbOiNRgkoUTe0h3AdentgKhn044gy27LaDGYadLbzpdwjGc1gHI4ao8JbOtu9(tQ4bNxmkqndWAKW8qyyqHAXdgIlNxmkmaDIQ3lgooSbR64zCC1ag1lHrU5HsBgd7zWkbuO2iuehWHFmaDIQ3FsfpqqFCRnq0fuSazuziF6uQJNfeu)HoZscQPlqHAieeYtJC3ccQ)qNzjallnW1uaJyylTAd1qj0clLI2aHlVl1ag1lHrU55O)IHDioVyuya6evVxmCCydw1XZzWkbuO2iuehWHFmaDmVbkFsfpqqFCRnq0fuSazuziF6uQJNfeu)HoZscQPlqHAieeYtJC3ccQ)qNzjallnW1uaJyylTAd1qj0clLI2aHlVl1ag1lHrU55OhJHDioVyuya6evVx8GZGvcOqTrOioGd)8PtPoE(KwT4dgGor17LUrnqgvVxIIXt(u)JpOgWOEjmYnpu(pyCKC58IrHbOtu9EXWwA1gB44JAGzVxIvna2(rYfnciIVHkjkkz)RzXWwA1gB4x7qCEXOWa0jQEV4bNbReqHAJqrCah(Xa0X8gO8jv8GZlgfOMbynsIN1r(vMc1IhmoUTgGoXAyHcljyzYzCCxoVyuquz1eXWwA1gQ)fIZlgfevwnr8GXXD58IrXOFCJEgzC4oqujg2sR2qnucTWsPOnq4Y7snGr9syKBEo6XyyhIZlgfJ(Xn6zKXH7arL4bB3oKpDk1XZcdqNO69s3OgiJQ3lrXiedm79sGoqzGrya6evVN6JZGvcOqTrOioGd)0SBPfc1NuXdUyIVGnSOAP2ubHGqEAK7wquz1eXWwA1gk)fdCCxeS6aLnhccYWeS6aLLGYIP(x744eS6aLnho2oefwsWYKZzWkbuO2iuehWHFWQ(O0cH6tQ4bxmXxWgwuTuBQGqqipnYDliQSAIyylTAdL)IboUlcwDGYMdbbzycwDGYsqzXu)RDCCcwDGYMdhBhIcljyzY5myLakuBekId4WpXN3lTqO(KkEWft8fSHfvl1MkieeYtJC3cIkRMig2sR2q5VyGJ7IGvhOS5qqqgMGvhOSeuwm1)AhhNGvhOS5WX2HOWscwMCodwjGc1gHI4ao8JBDMcnsuuY(xZzWkbuO2iuehWHF(0PuhpFsRw8bdqNynSSAPb515Kp1)4dgy27LaDGYaJWa0jwdt5)eq0JqJll1a4Hk5N6F8rdcd7be9i04Y5fJcdqhZBGYs2cg5MhlUbcdqjNp6)TNbReqHAJqrCah(X9OaSNuXdmXxWgw4FToYMPiahNj(c2WcTPs2mfbq(0PuhplkJK4z9JXXzIVGnSOAPb51bITF6uQJNfgGoXAyz1sdYRdoUZlgfevwnrmSLwTHALakulmaDI1WcMIm5byjOSyi2(PtPoEwugjXZ6hdX5fJcIkRMig2sR2qntrM8aSeuwmeNxmkiQSAI4bJJ78IrXOFCJEgzC4oqujEWqmWS3lXQgatjgIahh32pDk1XZIYijEw)yioVyuquz1eXWwA1gkzkYKhGLGYIZGvcOqTrOioGd)ya6eRHZGvcOqTrOioGd)mVwQeqHAPVmGtA1IpevVhGDEzWzWkbuO2iCqk4WOFCJEgzC4oquDsfp48IrbrLvtep4myLakuBeoifeWHF(0PuhpFsRw8bYuGgbEWN8P(hFWwNxmkCuV2ewIIs17LaSvd1iBf8gw8GHyRZlgfoQxBclrrP69sa2QHAK6q0Mfp4myLakuBeoifeWHFiAtyV05fJN0QfFWa0XJg6tQ4bNxmkmaD8OHwmSLwTHAm)fIlNxmkCuV2ewIIs17LaSvd1iBf8gwmSLwTHY)l(fh35fJch1RnHLOOu9EjaB1qnsDiAZIHT0Qnu(FXV2HOgWOEjmYnpuEiWXaIlcc5PrUBbrLvtedBPvBO0MWXDrqipnYDlylyKBEKoOMwmSLwTHsBcIToVyuCUA6HPLSfmYnpwCdKCZd0kqS4bdHG(4wBG4mvtPTD7zWkbuO2iCqkiGd)ya6yEdu(KkEW2pDk1XZcYuGgbEWqC5Ywcc5PrUBbb1FOZSeGLLg4AkGr8GXXT9tNsD8SGG6p0zwsqnDbkuJJBlb9XT2arxqXcKrLTdXfb9XT2arxqXcKrLXXDrqipnYDliQSAIyylTAdL2eoUlcc5PrUBbBbJCZJ0b10IHT0QnuAtqS15fJIZvtpmTKTGrU5XIBGKBEGwbIfpyie0h3AdeNPAkTTB3UDCCxeeYtJC3ccQ)qNzjallnW1uaJ4bdHGqEAK7wquz1eXWknvqiOpU1gi6ckwGmQS9myLakuBeoifeWHFuAfguFS04whRtiur8SeOdugyoG5jv8GT0iGqPvyq9XsJBDSK0QLcLfGICUAOqSvjGc1cLwHb1hlnU1XssRwkuwuTm6lOybqCzlnciuAfguFS04whljww9cqroxnuCCAeqO0kmO(yPXTowsSS6fdBPvBO8x7440iGqPvyq9XsJBDSK0QLcLfgGsot9XqOraHsRWG6JLg36yjPvlfklg2sR2q9XqOraHsRWG6JLg36yjPvlfklaf5C1qZGvcOqTr4Guqah(X86yn8jeQiEwc0bkdmhW8KkEy44WgSQJNHa0bkdeGYILaKKUykXmWHOWscwMCgIRpDk1XZcYuGgbEW44UudyuVeg5MhQpgdi268IrbrLvtepy744eeYtJC3cIkRMigwPPYEgSsafQnchKcc4WpwiuhRHpHqfXZsGoqzG5aMNuXddhh2GvD8meGoqzGauwSeGK0ftjMhl(fIcljyzYziU(0PuhplitbAe4bJJ7snGr9syKBEO(ymGyRZlgfevwnr8GTJJtqipnYDliQSAIyyLMk7qS15fJIZvtpmTKTGrU5XIBGKBEGwbIfp4myLakuBeoifeWHFma271rg96WNqOI4zjqhOmWCaZtQ4HHJdBWQoEgcqhOmqaklwcqs6IPeZapGHT0QnquyjbltodX1NoL64zbzkqJapyCC1ag1lHrU5H6JXahNGqEAK7wquz1eXWknv2ZGvcOqTr4Guqah(jIgclrrzRG3WNuXdkSKGLjNZGvcOqTr4Guqah(j(gQKOOK9VMpPIhCXeFbByr1sTPchNj(c2WcdYRJSAjM44mXxWgw4FToYQLyAhIlBjOpU1gi6ckwGmQmoUl1ag1lHrU5HAB(xiU(0PuhplitbAe4bJJRgWOEjmYnpuFmg44F6uQJNfLrQi2oexF6uQJNfeu)HoZsA2qvtGylbH80i3TGG6p0zwcWYsdCnfWiEW442(PtPoEwqq9h6mlPzdvnbITeeYtJC3cIkRMiEW2TBhIlcc5PrUBbrLvtedBPvBO8ymWXvdyuVeg5MhkTzmGqqipnYDliQSAI4bdXfbH80i3TGTGrU5r6GAAXWwA1gQvcOqTWa0jwdlykYKhGLGYIXXTLG(4wBG4mvtPTDC8ybflqoSLwTHAmXWoex0iGqPvyq9XsJBDSK0QLcLfdBPvBO8)442sqFCRnq0mzqE0qBpdwjGc1gHdsbbC4NZvtpmT0axtbmNuXdUyIVGnSW)ADKntraoot8fSHfgKxhzZueGJZeFbByH2ujBMIaCCNxmkCuV2ewIIs17LaSvd1iBf8gwmSLwTHY)l(fh35fJch1RnHLOOu9EjaB1qnsDiAZIHT0Qnu(FXV44QbmQxcJCZdL2mgqiiKNg5UfevwnrmSstLDiUiiKNg5UfevwnrmSLwTHYJXahNGqEAK7wquz1eXWknv2XXJfuSa5WwA1gQXeJmyLakuBeoifeWHFiSNnGs9s1xqBlUbNuXdUudyuVeg5MhkTzmG4Y5fJIZvtpmTKTGrU5XIBGKBEGwbIfpyCCBjOpU1giot1uABhhNG(4wBGOlOybYOY44oVyu44riA)ZaepyioVyu44riA)ZaedBPvBOoimcW1)TbcQPFfqapmPmSu9f02IBGGB1XZ02TdXLTe0h3AdeDbflqgvghNGqEAK7wqq9h6mlbyzPbUMcyepyC8ybflqoSLwTHAcc5PrUBbb1FOZSeGLLg4AkGrmSLwTjGahhpwqXcKdBPvBo6rX8FWG6GWiax)3giOM(vab8WKYWs1xqBlUbcUvhptB3EgSsafQnchKcc4Wpvt0PvqH6tQ4bxQbmQxcJCZdL2mgqC58IrX5QPhMwYwWi38yXnqYnpqRaXIhmoUTe0h3AdeNPAkTTJJtqFCRnq0fuSazuzCCNxmkC8ieT)zaIhmeNxmkC8ieT)zaIHT0QnuFmgb46)2ab10VciGhMugwQ(cABXnqWT64zA72H4Ywc6JBTbIUGIfiJkJJtqipnYDliO(dDMLaSS0axtbmIhmo(NoL64zbb1FOZSKMnu1eiXckwGCylTAdLy(pyeqqyeGR)Bdeut)kGaEyszyP6lOTf3ab3QJNPTJJhlOybYHT0QnutqipnYDliO(dDMLaSS0axtbmIHT0Qnbe444XckwGCylTAd1hJraU(Vnqqn9Rac4HjLHLQVG2wCdeCRoEM2U9myLakuBeoifeWHFiO(dDMLaSS0axtbmNuXdU(0PuhpliO(dDML0SHQMajwqXcKdBPvBOeZJXah35fJcIkRMiEW2H4Y5fJch1RnHLOOu9EjaB1qnYwbVHfgGsol)u)JP8ymWXDEXOWr9AtyjkkvVxcWwnuJuhI2SWauYz5N6FmLhJHDC8ybflqoSLwTHAmXidwjGc1gHdsbbC4hdqhZBGYNuXde0h3AdeDbflqgvgIRpDk1XZccQ)qNzjnBOQj44eeYtJC3cIkRMig2sR2qnMyyhIAaJ6LWi38q5VyaHGqEAK7wqq9h6mlbyzPbUMcyedBPvBOgtmYGvcOqTr4Guqah(5tNsD88jTAXhud8rgEczYjFQ)XhyIVGnSOAP)16yd)ZrvcOqTWa0jwdlykYKhGLGYIdWwM4lydlQw6FTo2qGFuLakulCpkaRGPitEawckloamebDudm79sSQbWzWkbuO2iCqkiGd)ya6yEdu(KkEWLRybflqoSLwTH6)JJ7Y5fJIr)4g9mY4WDGOsmSLwTHAOeAHLsrBGWL3LAaJ6LWi38C0JXWoeNxmkg9JB0ZiJd3bIkXd2UDCCxQbmQxcJCZtaF6uQJNfQb(idpHmXgCEXOGj(c2WsdYRJyylTAta0iGi(gQKOOK9VMfGIC2ih2sR2gcs8lLygeg44QbmQxcJCZtaF6uQJNfQb(idpHmXgCEXOGj(c2Ws)R1rmSLwTjaAeqeFdvsuuY(xZcqroBKdBPvBdbj(Lsmdcd7qyIVGnSOAP2ubXLlBjiKNg5Ufevwnr8GXXjOpU1giot1uAdXwcc5PrUBbBbJCZJ0b10IhSDCCc6JBTbIUGIfiJkBhh35fJcIkRMig2sR2q5)aXwNxmkg9JB0ZiJd3bIkXd2EgSsafQnchKcc4Wpn7wAHq9jv8GlNxmkyIVGnS0)ADepyCCxeS6aLnhccYWeS6aLLGYIP(x744eS6aLnho2oefwsWYKZzWkbuO2iCqkiGd)Gv9rPfc1NuXdUCEXOGj(c2Ws)R1r8GXXDrWQdu2CiiidtWQduwcklM6FTJJtWQdu2C4y7quyjbltoNbReqHAJWbPGao8t859sleQpPIhC58Irbt8fSHL(xRJ4bJJ7IGvhOS5qqqgMGvhOSeuwm1)AhhNGvhOS5WX2HOWscwMCodwjGc1gHdsbbC4h36mfAKOOK9VMZGvcOqTr4Guqah(Xa0jwdFsfpWeFbByr1s)R1bhNj(c2WcdYRJSzkcWXzIVGnSqBQKntraoUZlgfU1zk0irrj7FnlEWqyIVGnSOAP)16GJ7Y5fJcIkRMig2sR2qTsafQfUhfGvWuKjpalbLfdX5fJcIkRMiEW2ZGvcOqTr4Guqah(X9OaSzWkbuO2iCqkiGd)mVwQeqHAPVmGtA1IpevVhGDEzWzWkbuO2iOhwTCQMMNdF6uQJNpPvl(GrJSeGKpdlnWS3FYN6F8bxoVyuakl2nAAj9WQLt108ig2sR2qjucTWsPyayiWeIlM4lydlQw6GayXXzIVGnSOAPb51bhNj(c2Wc)R1r2mfb2XXDEXOauwSB00s6HvlNQP5rmSLwTHsLakulmaDI1WcMIm5byjOS4aWqGjexmXxWgwuT0)ADWXzIVGnSWG86iBMIaCCM4lydl0MkzZuey3ooUToVyuakl2nAAj9WQLt108iEWzWkbuO2iOhwTCQMMNao8JbOJ5nq5tQ4bx2(PtPoEwy0ilbi5ZWsdm7944UCEXOy0pUrpJmoChiQedBPvBOgkHwyPu0giC5DPgWOEjmYnph9ymSdX5fJIr)4g9mY4WDGOs8GTBhhxnGr9syKBEO0MXidwjGc1gb9WQLt108eWHFuAfguFS04whRta6aLbYkEWwAeqO0kmO(yPXTowsA1sHYcqroxnui2QeqHAHsRWG6JLg36yjPvlfklQwg9fuSaiUSLgbekTcdQpwACRJLelREbOiNRgkoonciuAfguFS04whljww9IHT0Qnu(RDCCAeqO0kmO(yPXTowsA1sHYcdqjNP(yi0iGqPvyq9XsJBDSK0QLcLfdBPvBO(yi0iGqPvyq9XsJBDSK0QLcLfGICUAOzWkbuO2iOhwTCQMMNao8Jfc1XA4ta6aLbYkEy44WgSQJNHa0bkdeGYILaKKUykXmOtQ4bxoVyuquz1eXWwA1gk)fIlNxmkg9JB0ZiJd3bIkXWwA1gk)fh3wNxmkg9JB0ZiJd3bIkXd2ooUToVyuquz1eXdghxnGr9syKBEO(ymSdXLToVyuCUA6HPLSfmYnpwCdKCZd0kqS4bJJRgWOEjmYnpuFmg2HOWscwMCodwjGc1gb9WQLt108eWHFmVowdFcqhOmqwXddhh2GvD8meGoqzGauwSeGK0ftjMbDsfp4Y5fJcIkRMig2sR2q5VqC58IrXOFCJEgzC4oqujg2sR2q5V44268IrXOFCJEgzC4oqujEW2XXT15fJcIkRMiEW44QbmQxcJCZd1hJHDiUS15fJIZvtpmTKTGrU5XIBGKBEGwbIfpyCC1ag1lHrU5H6JXWoefwsWYKZzWkbuO2iOhwTCQMMNao8JbWEVoYOxh(eGoqzGSIhgooSbR64ziaDGYabOSyjajPlMsmd8tQ4bxoVyuquz1eXWwA1gk)fIlNxmkg9JB0ZiJd3bIkXWwA1gk)fh3wNxmkg9JB0ZiJd3bIkXd2ooUToVyuquz1eXdghxnGr9syKBEO(ymSdXLToVyuCUA6HPLSfmYnpwCdKCZd0kqS4bJJRgWOEjmYnpuFmg2HOWscwMCodwjGc1gb9WQLt108eWHFIOHWsuu2k4n8jv8GcljyzY5myLakuBe0dRwovtZtah(z0pUrpJmoChiQoPIhCEXOGOYQjIhCgSsafQnc6HvlNQP5jGd)CUA6HPLg4AkG5KkEWLlNxmkyIVGnS0G86ig2sR2qjMyGJ78Irbt8fSHL(xRJyylTAdLyIHDieeYtJC3cIkRMig2sR2q5XyyhhNGqEAK7wquz1eXWknvzWkbuO2iOhwTCQMMNao8dH9SbuQxQ(cABXn4KkEWLZlgfNRMEyAjBbJCZJf3aj38aTcelEW442sqFCRnqCMQP02ooob9XT2arxqXcKrLXX)0PuhplkJurmoUZlgfoEeI2)maXdgIZlgfoEeI2)maXWwA1gQdcJaC9FBGGA6xbeWdtkdlvFbTT4gi4wD8mTDi268IrbrLvtepyiUQgWdmYRaMwglOybYHT0QnutqipnYDliO(dDMLaSS0axtbmIHT0Qnbyt44vd4bg5vatlJfuSa5WwA1gQdkiC8Qb8aJ8kGPLXckwGCylTAZrpkM)dguhuq44eeYtJC3ccQ)qNzjallnW1uaJ4bJJBlb9XT2arxqXcKrLTNbReqHAJGEy1YPAAEc4Wpvt0PvqH6tQ4bxoVyuCUA6HPLSfmYnpwCdKCZd0kqS4bJJBlb9XT2aXzQMsB744e0h3AdeDbflqgvgh)tNsD8SOmsfX44oVyu44riA)ZaepyioVyu44riA)ZaedBPvBO(ymcW1)TbcQPFfqapmPmSu9f02IBGGB1XZ02HyRZlgfevwnr8GH4QAapWiVcyAzSGIfih2sR2qnbH80i3TGG6p0zwcWYsdCnfWig2sR2eGnHJxnGhyKxbmTmwqXcKdBPvBO(4GWXRgWdmYRaMwglOybYHT0Qnh9Oy(pyq9XbHJtqipnYDliO(dDMLaSS0axtbmIhmoUTe0h3AdeDbflqgv2EgSsafQnc6HvlNQP5jGd)8PtPoE(KwT4deu)HoZscQPlqH6t(u)JpqqFCRnq0fuSazuziUCEXOaEkl0qxQxQdr7IiHFEJoIp1)yQd6)yaXfbH80i3TGOYQjIHT0QnbGjguwnGhyKxbmTmwqXcKdBPvBWXjiKNg5UfevwnrmSLwTjGJXG6Qb8aJ8kGPLXckwGCylTAdKQb8aJ8kGPLXckwGCylTAdLyEmg44oVyuquz1eXWwA1gkTj7qCEXOGj(c2WsdYRJyylTAdLyIboE1aEGrEfW0YybflqoSLwT5OhfZGWGAm)1EgSsafQnc6HvlNQP5jGd)8PtPoE(KwT4dg9JLr0ijQSAYjFQ)XhCzlbH80i3TGOYQjIHvAQWXT9tNsD8SGG6p0zwsqnDbkudHG(4wBGOlOybYOY2ZGvcOqTrqpSA5unnpbC4hcQ)qNzjallnW1uaZjv8WNoL64zbb1FOZSKGA6cuOgIAaJ6LWi38q9)XidwjGc1gb9WQLt108eWHFIVHkjkkz)R5tQ4bM4lydlQwQnvquyjbltodXfnciuAfguFS04whljTAPqzbOiNRgkoUTe0h3AdentgKhn02H8PtPoEwy0pwgrJKOYQjzWkbuO2iOhwTCQMMNao8JbOJ5nq5tQ4bc6JBTbIUGIfiJkd5tNsD8SGG6p0zwsqnDbkudrnGr9syKBEO8W)XacbH80i3TGG6p0zwcWYsdCnfWig2sR2qnucTWsPOnq4Y7snGr9syKBEo6XyypdwjGc1gb9WQLt108eWHFA2T0cH6tQ4bxoVyuWeFbByP)16iEW44Uiy1bkBoeeKHjy1bklbLft9V2XXjy1bkBoCSDikSKGLjNH8PtPoEwy0pwgrJKOYQjzWkbuO2iOhwTCQMMNao8dw1hLwiuFsfp4Y5fJcM4lydl9VwhXdgITe0h3AdeNPAkTXXD58IrX5QPhMwYwWi38yXnqYnpqRaXIhmec6JBTbIZunL22XXDrWQdu2CiiidtWQduwcklM6FTJJtWQdu2C4yCCNxmkiQSAI4bBhIcljyzYziF6uQJNfg9JLr0ijQSAsgSsafQnc6HvlNQP5jGd)eFEV0cH6tQ4bxoVyuWeFbByP)16iEWqSLG(4wBG4mvtPnoUlNxmkoxn9W0s2cg5MhlUbsU5bAfiw8GHqqFCRnqCMQP02ooUlcwDGYMdbbzycwDGYsqzXu)RDCCcwDGYMdhJJ78IrbrLvtepy7quyjbltod5tNsD8SWOFSmIgjrLvtYGvcOqTrqpSA5unnpbC4h36mfAKOOK9VMZGvcOqTrqpSA5unnpbC4hdqNyn8jv8at8fSHfvl9VwhCCM4lydlmiVoYMPiahNj(c2WcTPs2mfb44oVyu4wNPqJefLS)1S4bdX5fJcM4lydl9VwhXdgh3LZlgfevwnrmSLwTHALakulCpkaRGPitEawcklgIZlgfevwnr8GTNbReqHAJGEy1YPAAEc4WpUhfGndwjGc1gb9WQLt108eWHFMxlvcOqT0xgWjTAXhIQ3dWoVm4myLakuBer17byN3bdqhZBGYNuXd2oVMJObklCuV2ewIIs17LaSvd1i4)1RGHz6myLakuBer17byNxah(X86yn8jeQiEwc0bkdmhW8KkEGgbewiuhRHfdBPvBOCylTAtgSsafQnIO69aSZlGd)yHqDSgododwjGc1gb8WWkGGvAahSqOowdFcHkINLaDGYaZbmpPIhgooSbR64ziaDGYabOSyjajPlMsmdcIlNxmkiQSAIyylTAdL)IJBRZlgfevwnr8GXXvdyuVeg5MhQpgd7quyjbltoNbReqHAJaEyyfqWknGao8J51XA4tiur8SeOdugyoG5jv8WWXHnyvhpdbOdugiaLflbijDXuIzqqC58IrbrLvtedBPvBO8xCCBDEXOGOYQjIhmoUAaJ6LWi38q9XyyhIcljyzY5myLakuBeWddRacwPbeWHFma271rg96WNqOI4zjqhOmWCaZtQ4HHJdBWQoEgcqhOmqaklwcqs6IPeZGG4Y5fJcIkRMig2sR2q5V44268IrbrLvtepyCC1ag1lHrU5H6JXWoefwsWYKZzWkbuO2iGhgwbeSsdiGd)erdHLOOSvWB4tQ4bfwsWYKZzWkbuO2iGhgwbeSsdiGd)qypBaL6LQVG2wCdoPIhCPgWOEjmYnpuAZyGJ78IrHJhHO9pdq8GH48IrHJhHO9pdqmSLwTH6GcC7qS15fJcIkRMiEWzWkbuO2iGhgwbeSsdiGd)unrNwbfQpPIhCPgWOEjmYnpuAZyGJ78IrHJhHO9pdq8GH48IrHJhHO9pdqmSLwTH6JdC7qS15fJcIkRMiEWzWkbuO2iGhgwbeSsdiGd)8PtPoE(KwT4dg9JLr0ijQSAYjFQ)XhSLGqEAK7wquz1eXWknvzWkbuO2iGhgwbeSsdiGd)eFdvsuuY(xZNuXdmXxWgwuTuBQGOWscwMCgYNoL64zHr)yzensIkRMKbReqHAJaEyyfqWknGao8drBc7LoVy8KwT4dgGoE0qFsfp48IrHbOJhn0IHT0Qnuh4qC58Irbt8fSHLgKxhXdgh35fJcM4lydl9VwhXd2oe1ag1lHrU5HsBgJmyLakuBeWddRacwPbeWHFmaDmVbkFsfp4Ywnq8uawyadRNRgQ0a0XigTpJJ78IrbrLvtedBPvBOMPitEawcklgh3w4H)egGoM3aLTdXLZlgfevwnr8GXXvdyuVeg5MhkTzmGWeFbByr1sTPYEgSsafQnc4HHvabR0ac4WpgGoM3aLpPIhCzRgiEkalmGH1ZvdvAa6yeJ2NXXDEXOGOYQjIHT0QnuZuKjpalbLfJJB7NoL64zb8WFsdqhZBGY2Haup3aHbOJhn0cUvhptdXLZlgfgGoE0qlEW44QbmQxcJCZdL2mg2H48IrHbOJhn0cdqjNP(yiUCEXOGj(c2WsdYRJ4bJJ78Irbt8fSHL(xRJ4bBhcbH80i3TGOYQjIHT0QnuAtzWkbuO2iGhgwbeSsdiGd)ya6yEdu(KkEWLTAG4PaSWagwpxnuPbOJrmAFgh35fJcIkRMig2sR2qntrM8aSeuwmoUTWd)jmaDmVbkBhIZlgfmXxWgwAqEDedBPvBO0MGWeFbByr1sdYRdeBbQNBGWa0XJgAb3QJNPHqqipnYDliQSAIyylTAdL2ugSsafQnc4HHvabR0ac4Wpn7wAHq9jv8GlNxmkyIVGnS0)ADepyCCxeS6aLnhccYWeS6aLLGYIP(x744eS6aLnho2oefwsWYKZq(0Puhplm6hlJOrsuz1KmyLakuBeWddRacwPbeWHFWQ(O0cH6tQ4bxoVyuWeFbByP)16iEW44Uiy1bkBoeeKHjy1bklbLft9V2XXjy1bkBoCmoUZlgfevwnr8GTdrHLeSm5mKpDk1XZcJ(XYiAKevwnjdwjGc1gb8WWkGGvAabC4N4Z7LwiuFsfp4Y5fJcM4lydl9VwhXdgh3fbRoqzZHGGmmbRoqzjOSyQ)1ooobRoqzZHJXXDEXOGOYQjIhSDikSKGLjNH8PtPoEwy0pwgrJKOYQjzWkbuO2iGhgwbeSsdiGd)4wNPqJefLS)1CgSsafQnc4HHvabR0ac4WpgGoXA4tQ4bxAG4PaSWagwpxnuPbOJrmAFgIZlgfevwnrmSLwTHsMIm5byjOSyiWd)jCpkaRDCCx2QbINcWcdyy9C1qLgGogXO9zCCNxmkiQSAIyylTAd1mfzYdWsqzX442cp8NWa0jwdBhIlM4lydlQw6FTo44mXxWgwyqEDKntraoot8fSHfAtLSzkcWXDEXOWTotHgjkkz)RzXdgIZlgfmXxWgw6FToIhmoUlNxmkiQSAIyylTAd1kbuOw4EuawbtrM8aSeuwmeNxmkiQSAI4bB3ooUlnq8uawqRU7QHknVwmAFMYGG48Irbt8fSHLgKxhXWwA1gk)fIToVyuqRU7QHknVwmSLwTHsLakulCpkaRGPitEawckl2EgSsafQnc4HHvabR0ac4WpUhfGndwjGc1gb8WWkGGvAabC4N51sLakul9LbCsRw8HO69aSZldodwjGc1gHbCqPvyq9XsJBDSoHqfXZsGoqzG5aMNuXd2sJacLwHb1hlnU1XssRwkuwakY5QHcXwLakuluAfguFS04whljTAPqzr1YOVGIfaXLT0iGqPvyq9XsJBDSKyz1laf5C1qXXPraHsRWG6JLg36yjXYQxmSLwTHYFTJJtJacLwHb1hlnU1XssRwkuwyak5m1hdHgbekTcdQpwACRJLKwTuOSyylTAd1hdHgbekTcdQpwACRJLKwTuOSauKZvdndwjGc1gHbeWHFSqOowdFcHkINLaDGYaZbmpPIhgooSbR64ziaDGYabOSyjajPlMsmd6KkEWLZlgfevwnrmSLwTHYFH4Y5fJIr)4g9mY4WDGOsmSLwTHYFXXT15fJIr)4g9mY4WDGOs8GTJJBRZlgfevwnr8GXXvdyuVeg5MhQpgd7qCzRZlgfNRMEyAjBbJCZJf3aj38aTcelEW44QbmQxcJCZd1hJHDikSKGLjNZGvcOqTryabC4hZRJ1WNqOI4zjqhOmWCaZtQ4HHJdBWQoEgcqhOmqaklwcqs6IPeZGG4Y5fJcIkRMig2sR2q5VqC58IrXOFCJEgzC4oqujg2sR2q5V44268IrXOFCJEgzC4oqujEW2XXT15fJcIkRMiEW44QbmQxcJCZd1hJHDiUS15fJIZvtpmTKTGrU5XIBGKBEGwbIfpyCC1ag1lHrU5H6JXWoefwsWYKZzWkbuO2imGao8JbWEVoYOxh(ecveplb6aLbMdyEsfpmCCydw1XZqa6aLbcqzXsassxmLyg4qC58IrbrLvtedBPvBO8xiUCEXOy0pUrpJmoChiQedBPvBO8xCCBDEXOy0pUrpJmoChiQepy744268IrbrLvtepyCC1ag1lHrU5H6JXWoex268IrX5QPhMwYwWi38yXnqYnpqRaXIhmoUAaJ6LWi38q9XyyhIcljyzY5myLakuBegqah(jIgclrrzRG3WNuXdkSKGLjNZGvcOqTryabC4Nr)4g9mY4WDGO6KkEW5fJcIkRMiEWzWkbuO2imGao8Z5QPhMwAGRPaMtQ4bxUCEXOGj(c2WsdYRJyylTAdLyIboUZlgfmXxWgw6FToIHT0QnuIjg2HqqipnYDliQSAIyylTAdLhJbexoVyuapLfAOl1l1HODrKWpVrhXN6Fm1b9FmWXTDEnhrduwapLfAOl1l1HODrKWpVrhb)VEfmmtB3ooUZlgfWtzHg6s9sDiAxej8ZB0r8P(ht5HGSjmWXjiKNg5UfevwnrmSstfexQbmQxcJCZdL2mg44F6uQJNfLrQi2EgSsafQncdiGd)qypBaL6LQVG2wCdoPIhCPgWOEjmYnpuAZyaXLZlgfNRMEyAjBbJCZJf3aj38aTcelEW442sqFCRnqCMQP02ooob9XT2arxqXcKrLXX)0PuhplkJurmoUZlgfoEeI2)maXdgIZlgfoEeI2)maXWwA1gQdcJaC5YMTH51Cenqzb8uwOHUuVuhI2frc)8gDe8)6vWWmT9aC9FBGGA6xbeWdtkdlvFbTT4gi4wD8mTD72HyRZlgfevwnr8GH4kwqXcKdBPvBOMGqEAK7wqq9h6mlbyzPbUMcyedBPvBcWMWXJfuSa5WwA1gQdkOaCzZ2GlNxmkGNYcn0L6L6q0Uis4N3OJ4t9pMsmXad72XXJfuSa5WwA1MJEum)hmOoOGWXjiKNg5Ufeu)HoZsawwAGRPagXdgh3wc6JBTbIUGIfiJkBpdwjGc1gHbeWHFQMOtRGc1NuXdUudyuVeg5MhkTzmG4Y5fJIZvtpmTKTGrU5XIBGKBEGwbIfpyCCBjOpU1giot1uABhhNG(4wBGOlOybYOY44F6uQJNfLrQigh35fJchpcr7FgG4bdX5fJchpcr7FgGyylTAd1hJraUCzZ2W8AoIgOSaEkl0qxQxQdr7IiHFEJoc(F9kyyM2EaU(Vnqqn9Rac4HjLHLQVG2wCdeCRoEM2UD7qS15fJcIkRMiEWqCflOybYHT0QnutqipnYDliO(dDMLaSS0axtbmIHT0Qnbyt44XckwGCylTAd1hhuaUSzBWLZlgfWtzHg6s9sDiAxej8ZB0r8P(htjMyGHD744XckwGCylTAZrpkM)dguFCq44eeYtJC3ccQ)qNzjallnW1uaJ4bJJBlb9XT2arxqXcKrLTNbReqHAJWac4WpF6uQJNpPvl(ab1FOZSKGA6cuO(Kp1)4de0h3AdeDbflqgvgIlNxmkGNYcn0L6L6q0Uis4N3OJ4t9pM6G(pgqCrqipnYDliQSAIyylTAtayIbLXckwGCylTAdoobH80i3TGOYQjIHT0QnbCmguhlOybYHT0QnqIfuSa5WwA1gkX8ymWXDEXOGOYQjIHT0QnuAt2H48Irbt8fSHLgKxhXWwA1gkXedC8ybflqoSLwT5OhfZGWGAm)1EgSsafQncdiGd)8PtPoE(KwT4dg9JLr0ijQSAYjFQ)XhCzlbH80i3TGOYQjIHvAQWXT9tNsD8SGG6p0zwsqnDbkudHG(4wBGOlOybYOY2ZGvcOqTryabC4hcQ)qNzjallnW1uaZjv8WNoL64zbb1FOZSKGA6cuOgIAaJ6LWi38q9XyKbReqHAJWac4WpX3qLefLS)18jv8at8fSHfvl1MkikSKGLjNH48Irb8uwOHUuVuhI2frc)8gDeFQ)Xuh0)XaIlAeqO0kmO(yPXTowsA1sHYcqroxnuCCBjOpU1giAMmipAOTd5tNsD8SWOFSmIgjrLvtYGvcOqTryabC4hdqNO69NuXdoVyuGAgG1iH5HWWGc1IhmeNxmkmaDIQ3lgooSbR645myLakuBegqah(HOnH9sNxmEsRw8bdqhpAOpPIhCEXOWa0XJgAXWwA1gQ)fIlNxmkyIVGnS0G86ig2sR2q5V44oVyuWeFbByP)16ig2sR2q5V2HOgWOEjmYnpuAZyKbReqHAJWac4WpgGoM3aLpPIhiOpU1gi6ckwGmQmKpDk1XZccQ)qNzjb10fOqnecc5PrUBbb1FOZSeGLLg4AkGrmSLwTHAOeAHLsrBGWL3LAaJ6LWi38C0JXWEgSsafQncdiGd)ya6evV)KkEaOEUbcdG9EDK0tfbcUvhptdXwG65gimaD8OHwWT64zAioVyuya6evVxmCCydw1XZqC58Irbt8fSHL(xRJyylTAdLboeM4lydlQw6FToqCEXOaEkl0qxQxQdr7IiHFEJoIp1)yQd6xmWXDEXOaEkl0qxQxQdr7IiHFEJoIp1)ykpe0VyarnGr9syKBEO0MXahNgbekTcdQpwACRJLKwTuOSyylTAdL)doUsafQfkTcdQpwACRJLKwTuOSOAz0xqXcSdXwcc5PrUBbrLvtedR0uLbReqHAJWac4WpgGoM3aLpPIhCEXOa1maRrs8SoYVYuOw8GXXDEXO4C10dtlzlyKBES4gi5MhOvGyXdgh35fJcIkRMiEWqC58IrXOFCJEgzC4oqujg2sR2qnucTWsPOnq4Y7snGr9syKBEo6XyyhIZlgfJ(Xn6zKXH7arL4bJJBRZlgfJ(Xn6zKXH7arL4bdXwcc5PrUBXOFCJEgzC4oqujgwPPch3wc6JBTbIpUbyPASJJRgWOEjmYnpuAZyaHj(c2WIQLAtvgSsafQncdiGd)ya6yEdu(KkEaOEUbcdqhpAOfCRoEMgIlNxmkmaD8OHw8GXXvdyuVeg5MhkTzmSdX5fJcdqhpAOfgGsot9XqC58Irbt8fSHLgKxhXdgh35fJcM4lydl9VwhXd2oeNxmkGNYcn0L6L6q0Uis4N3OJ4t9pM6GSjmG4IGqEAK7wquz1eXWwA1gkXedCCB)0PuhpliO(dDMLeutxGc1qiOpU1gi6ckwGmQS9myLakuBegqah(Xa0X8gO8jv8GlNxmkGNYcn0L6L6q0Uis4N3OJ4t9pM6GSjmWXDEXOaEkl0qxQxQdr7IiHFEJoIp1)yQd6xmGaup3aHbWEVos6PIab3QJNPTdX5fJcM4lydlniVoIHT0QnuAtqyIVGnSOAPb51bIToVyuGAgG1iH5HWWGc1IhmeBbQNBGWa0XJgAb3QJNPHqqipnYDliQSAIyylTAdL2eexeeYtJC3IZvtpmT0axtbmIHT0QnuAt442sqFCRnqCMQP02EgSsafQncdiGd)0SBPfc1NuXdUCEXOGj(c2Ws)R1r8GXXDrWQdu2CiiidtWQduwcklM6FTJJtWQdu2C4y7quyjbltod5tNsD8SWOFSmIgjrLvtYGvcOqTryabC4hSQpkTqO(KkEWLZlgfmXxWgw6FToIhmeBjOpU1giot1uAJJ7Y5fJIZvtpmTKTGrU5XIBGKBEGwbIfpyie0h3AdeNPAkTTJJ7IGvhOS5qqqgMGvhOSeuwm1)AhhNGvhOS5WX44oVyuquz1eXd2oefwsWYKZq(0Puhplm6hlJOrsuz1KmyLakuBegqah(j(8EPfc1NuXdUCEXOGj(c2Ws)R1r8GHylb9XT2aXzQMsBCCxoVyuCUA6HPLSfmYnpwCdKCZd0kqS4bdHG(4wBG4mvtPTDCCxeS6aLnhccYWeS6aLLGYIP(x744eS6aLnhogh35fJcIkRMiEW2HOWscwMCgYNoL64zHr)yzensIkRMKbReqHAJWac4WpU1zk0irrj7FnNbReqHAJWac4WpgGoXA4tQ4bM4lydlQw6FTo44mXxWgwyqEDKntraoot8fSHfAtLSzkcWXDEXOWTotHgjkkz)RzXdgIZlgfmXxWgw6FToIhmoUlNxmkiQSAIyylTAd1kbuOw4EuawbtrM8aSeuwmeNxmkiQSAI4bBpdwjGc1gHbeWHFCpkaBgSsafQncdiGd)mVwQeqHAPVmGtA1IpevVhGDE3qdmtUNIjgbDbxW9ca]] )


end