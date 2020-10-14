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


    spec:RegisterPack( "Balance", 20201014, [[dGecrdqiQKEevQkDjLi2ei(KQsPmksvNIuzvqv4vuPmlLKUfuf1Ui6xkrnmvvoMQQwMa5zQkzAQkvxdKyBuPsFdQsgNQsX5GQuRdQImpQe3tjSpqQdQQuQwiiPhsLkMivQQuxKkvvsFKkvv5KuPQWkfOMjvQYovs8tQuvjgkvQQyPuPQONkOPQKQVsLQQAVk1FjzWQCyklMuEmktgvDzKnl0NHIrdLoTuVwvXSPQBtf7wXVHmCqDCvLswUKNty6axxv2ou57cy8kPCEOQwVsKMpQSFrV)VxFhYBaAVsq)c63)F))U8Fq)dckqzhcWhM2HWg7JHH2HJ5q7qOAEBy0oe2W3Jm(967qb6vmAhIfaGf4PLxgtdW(0KmKZYI255nqJgwzrWYI2HT8ou71EG7JzRTd5naTxjOFb97)V)Fx(pO)bbL)7q7bWIQDyy74o7qSnppnBTDipjy7q338GQ5THr55(D9A(my338C)cdG0OkV)FF18c6xq)YGZGDFZZDWAdgsGNYGDFZdpN33oppXNxiYBvEqLmhzgS7BE458ChS2GH4ZdyfgcO6yEmtqI8aO8y4Z8KcyfgciKzWUV5HNZZ9j5GWr859MHyKqyf(5HZQ208Kip9TKKRMhCr4ucGvIxHHYdpdDEWfHtkawjEfgsNCh6BbqSxFhQHmWE99k)3RVdPX08e)gQ7qw1aQABhQ9IrjZu9WKp4DOXanA2HLHJg0tOIfnlf)nyVsq713H0yAEIFd1DicEhkiWo0yGgn7qCw1MMN2H4m)J2HUMN2lgLAM3ggPqrL59ka2EWiuJbEfjFW5bjpxZt7fJsnZBdJuOOY8EfaBpyekRy2qYh8oeNvQXCODiRAWGap4nyVYx713H0yAEIFd1DiRAavTTd1EXOuaSYJkEzrowpI8CjV)qjpi5PppTxmk1mVnmsHIkZ7vaS9GrOgd8kswKJ1JipOZ77sOKhhxEAVyuQzEByKcfvM3Ray7bJqzfZgswKJ1JipOZ77sOKNU8GKNjaL5vWOauLh0lYZD)LhK80NhdH88OaJKzQEyYICSEe5bDE4vECC5Pppgc55rbgj5aJcqLsdn8YICSEe5bDE4vEqYZ180EXO8tp8fXRihyuaQCObOOHkm9sj5dopi5Xq4OXgG8d(vBtE6Yt3o0yGgn7qMnmYR0EX4ou7fJQXCODOayLhv8BWELVVxFhsJP5j(nu3HSQbu12o018WzvBAEsYQgmiWdopi5Ppp955AEmeYZJcmsgAWH(qkawsjG7Qbc5dopoU8CnpCw1MMNKm0Gd9Hum0W3Ggn5XXLNR5Xq4OXgGCAmybQOr5Plpi5Pppgchn2aKtJblqfnkpoU80NhdH88OaJKzQEyYICSEe5bDE4vECC5Pppgc55rbgj5aJcqLsdn8YICSEe5bDE4vEqYZ180EXO8tp8fXRihyuaQCObOOHkm9sj5dopi5Xq4OXgG8d(vBtE6YtxE6YtxECC5Pppgc55rbgjdn4qFifalPeWD1aH8bNhK8yiKNhfyKmt1dtwKXJFEqYJHWrJna50yWcurJYt3o0yGgn7qbWkXRWqBWEfOSxFhsJP5j(nu3Hgd0OzhkEtSlAhYQgqvB7WIIfjWAAEkpi5bScdbKG2HuaKIVP8GoV)UBEqYZGvmSe7tEqYtFE4SQnnpjzvdge4bNhhxE6ZZeGY8kyuaQYZL8(6xEqYZ180EXOKzQEyYhCE6YJJlpgc55rbgjZu9WKfz84NNUDidFMNuaRWqaXEL)BWEf3DV(oKgtZt8BOUdngOrZo0bHMyx0oKvnGQ22HfflsG108uEqYdyfgcibTdPaifFt5bDE))scL8GKNbRyyj2N8GKN(8WzvBAEsYQgmiWdopoU80NNjaL5vWOauLNl591V8GKNR5P9IrjZu9WKp480LhhxEmeYZJcmsMP6HjlY4XppD5bjpxZt7fJYp9WxeVICGrbOYHgGIgQW0lLKp4DidFMNuaRWqaXEL)BWEf8AV(oKgtZt8BOUdngOrZouaiV3kv0BfTdzvdOQTDyrXIeynnpLhK8awHHasq7qkasX3uEqN3F3np3YRihRhrEqYZGvmSe7tEqYtFE4SQnnpjzvdge4bNhhxEMauMxbJcqvEUK3x)YJJlpgc55rbgjZu9WKfz84NNUDidFMNuaRWqaXEL)BWELVzV(oKgtZt8BOUdzvdOQTDObRyyj2NDOXanA2HruXifkQgd8kAd2RG3713H0yAEIFd1DiRAavTTd1NhX8nSGK9OSb)844YJy(gwqsbYBLQh1)844YJy(gwqs)BSs1J6FE6YdsE6ZZ18yiC0ydqongSav0O844YtFEMauMxbJcqvEUKhEdL8GKN(8WzvBAEsYQgmiWdopoU8mbOmVcgfGQ8CjVV(LhhxE4SQnnpjBHYquE6YdsE6ZdNvTP5jjdn4qFifpjWFy5bjpxZJHqEEuGrYqdo0hsbWskbCxnqiFW5XXLNR5HZQ208KKHgCOpKINe4pS8GKNR5XqippkWizMQhM8bNNU80LNU8GKN(8yiKNhfyKmt1dtwKJ1JipOZ7RF5XXLNjaL5vWOauLh05H3)YdsEmeYZJcmsMP6HjFW5bjp95XqippkWijhyuaQuAOHxwKJ1JipxYZyGgnsbWQyxKKwJypaPaTdLhhxEUMhdHJgBaYp4xTn5PlpoU8IngSavrowpI8CjV))YtxEqYtFE8iG04nyqJJuIaw5O4nhddjlYX6rKh0599844YZ18yiC0ydqoeRqEuXNNUDOXanA2HXxHVcfvK)n0gSx5)V967qAmnpXVH6oKvnGQ22H6ZJy(gwqs)BSsn0AG844YJy(gwqsbYBLAO1a5XXLhX8nSGK2GVAO1a5XXLN2lgLAM3ggPqrL59ka2EWiuJbEfjlYX6rKh059DjuYJJlpTxmk1mVnmsHIkZ7vaS9GrOSIzdjlYX6rKh059DjuYJJlptakZRGrbOkpOZdV)LhK8yiKNhfyKmt1dtwKXJFE6YdsE6ZJHqEEuGrYmvpmzrowpI8GoVV(LhhxEmeYZJcmsMP6HjlY4XppD5XXLxSXGfOkYX6rKNl59)3o0yGgn7Wp9WxeVsa3vdeBWEL))3RVdPX08e)gQ7qw1aQABhQpptakZRGrbOkpOZdV)LhK80NN2lgLF6HViEf5aJcqLdnafnuHPxkjFW5XXLNR5Xq4OXgG8d(vBtE6YJJlpgchn2aKtJblqfnkpoU80EXOuZJq8(NaiFW5bjpTxmk18ieV)jaYICSEe55sEb9lp3YtFEFpp8ipgA4FnqcxeRfKY8nMXHgGKgtZt85PlpD5bjp955AEmeoASbiNgdwGkAuECC5XqippkWizObh6dPayjLaURgiKp4844Yl2yWcuf5y9iYZL8yiKNhfyKm0Gd9HuaSKsa3vdeYICSEe55wEUBECC5fBmybQICSEe5TK8()n)YZL8c6xEULN(8(EE4rEm0W)AGeUiwliL5BmJdnajnMMN4ZtxE62Hgd0OzhYipjaT5vMVXmo0a2G9k)dAV(oKgtZt8BOUdzvdOQTDO(8mbOmVcgfGQ8Gop8(xEqYtFEAVyu(Ph(I4vKdmkavo0au0qfMEPK8bNhhxEUMhdHJgBaYp4xTn5PlpoU8yiC0ydqongSav0O844Yt7fJsnpcX7FcG8bNhK80EXOuZJq8(NailYX6rKNl591V8Clp95998WJ8yOH)1ajCrSwqkZ3yghAasAmnpXNNU80LhK80NNR5Xq4OXgGCAmybQOr5XXLhdH88OaJKHgCOpKcGLuc4UAGq(GZJJlpCw1MMNKm0Gd9Hu8Ka)HLhK8IngSavrowpI8GoV)FZV8ClVG(LNB5PpVVNhEKhdn8VgiHlI1csz(gZ4qdqsJP5j(80LhhxEXgdwGQihRhrEUKhdH88OaJKHgCOpKcGLuc4UAGqwKJ1Jip3YZDZJJlVyJblqvKJ1JipxY7RF55wE6Z775Hh5Xqd)Rbs4IyTGuMVXmo0aK0yAEIppD5PBhAmqJMDypmRgd0Ozd2R8)R967qAmnpXVH6oKvnGQ22H6ZdNvTP5jjdn4qFifpjWFy5bjVyJblqvKJ1JipOZ7)x)YJJlpTxmkzMQhM8bNNU8GKN(80EXOuZ82WifkQmVxbW2dgHAmWRiPaySpkCM)r5bDEF9lpoU80EXOuZ82WifkQmVxbW2dgHYkMnKuam2hfoZ)O8GoVV(LNU844Yl2yWcuf5y9iYZL8()BhAmqJMDidn4qFifalPeWD1aXgSx5)33RVdPX08e)gQ7qw1aQABhUdngOrZo04nyqJJuIaw5Sb7v(dL967qAmnpXVH6oKvnGQ22HmeoASbiNgdwGkAuEqYtFE4SQnnpjzObh6dP4jb(dlpoU8yiKNhfyKmt1dtwKJ1JipxY7)V80LhK8mbOmVcgfGQ8GopO8lpi5XqippkWizObh6dPayjLaURgiKf5y9iYZL8()BhAmqJMDOayL4vyOnyVYF3DV(oKgtZt8BOUdrW7qbb2Hgd0OzhIZQ2080oeN5F0oKy(gwqYEu(3yvE4rEFtElNNXanAKcGvXUijTgXEasbAhkp3YZ18iMVHfKShL)nwLhEKN7M3Y5zmqJgzGYayL0Ae7bifODO8ClVFYGYB58eWK3RWAcaTdXzLAmhAhAcy3pufsSnyVYF8AV(oKgtZt8BOUdzvdOQTDO(80NxSXGfOkYX6rKNl599844YtFEAVyuwgoAqpHkw0Su8Lf5y9iYZL8WW4Lo2A5Hh5XO2NN(8mbOmVcgfGQ8woVV(LNU8GKN2lgLLHJg0tOIfnlfF5dopD5PlpoU80NNjaL5vWOauLNB5HZQ208K0eWUFOkKy5Hh5P9IrjX8nSGucK3kzrowpI8ClpEeqgFf(kuur(3qsqZ(iuf5y9KhEKxqsOKh059pOF5XXLNjaL5vWOauLNB5HZQ208K0eWUFOkKy5Hh5P9IrjX8nSGu(3yLSihRhrEULhpciJVcFfkQi)BijOzFeQICSEYdpYlijuYd68(h0V80LhK8iMVHfKShLn4NhK80NN(8Cnpgc55rbgjZu9WKp4844YJHWrJna5h8R2M8GKNR5XqippkWijhyuaQuAOHx(GZtxECC5Xq4OXgGCAmybQOr5PlpoU80EXOKzQEyYICSEe5bDEFtEqYZ180EXOSmC0GEcvSOzP4lFW5PBhAmqJMDOayL4vyOnyVY)VzV(oKgtZt8BOUdzvdOQTDO(80EXOKy(gwqk)BSs(GZJJlp95XWAfgsK3I8ckpi5vedRvyifODO8CjpOKNU844YJH1kmKiVf59vE6YdsEgSIHLyF2Hgd0OzhouaLdcnBWEL)49E9DinMMN43qDhYQgqvB7q95P9IrjX8nSGu(3yL8bNhhxE6ZJH1kmKiVf5fuEqYRigwRWqkq7q55sEqjpD5XXLhdRvyirElY7R80LhK8myfdlX(SdngOrZoeR5JkheA2G9kb9BV(oKgtZt8BOUdzvdOQTDO(80EXOKy(gwqk)BSs(GZJJlp95XWAfgsK3I8ckpi5vedRvyifODO8CjpOKNU844YJH1kmKiVf59vE6YdsEgSIHLyF2Hgd0OzhgFEVYbHMnyVsq)3RVdngOrZomGvvJkfkQi)BODinMMN43qDd2Reuq713H0yAEIFd1DiRAavTTdjMVHfKShL)nwLhhxEeZ3WcskqERudTgipoU8iMVHfK0g8vdTgipoU80EXOmGvvJkfkQi)Bi5dopi5rmFdlizpk)BSkpoU80NN2lgLmt1dtwKJ1JipxYZyGgnYaLbWkP1i2dqkq7q5bjpTxmkzMQhM8bNNUDOXanA2HcGvXUOnyVsqFTxFhAmqJMDyGYay3H0yAEIFd1nyVsqFFV(oKgtZt8BOUdngOrZoSEJYyGgnkFla7qFlaQXCODy08Ea26TbBWoeUigYrZa713R8FV(o0yGgn7qheA(0JkIkNDinMMN43qDd2Re0E9DOXanA2HbkdGDhsJP5j(nu3G9kFTxFhAmqJMDyGYay3H0yAEIFd1nyVY33RVdPX08e)gQ7qw1aQABhkGjVxbScdbesbWQO5955sEFFhAmqJMDOayL4vyOnyVcu2RVdPX08e)gQ7qe8ouqGDOXanA2H4SQnnpTdXz(hTd1qcrEqYl6rOkp95PpVyJblqvKJ1Jip8CEb9lpD5TCE)d6xE6Yd68IEeQYtFE6Zl2yWcuf5y9iYdpNxqqjp8CE6Z7)V8WJ8aMNgGShMvJbA0iPX08eFE6YdpNN(8(EE4rEm0W)AGeUiwliL5BmJdnajnMMN4ZtxE6YB58()n)Yt3oeNvQXCODidn4qFifpjWFyBWgSd5PO98G967v(VxFhAmqJMDOa5TsPrMZoKgtZt8BOUb7vcAV(oKgtZt8BOUdrW7qbb2Hgd0OzhIZQ2080oeN5F0ouatEVcyfgciKcGvrZ7Zd68(NhK80NNR5bmpnaPayLhv8sAmnpXNhhxEaZtdqkaK3BLIV6iqsJP5j(80LhhxEcyY7vaRWqaHuaSkAEFEqNxq7qCwPgZH2HTqziAd2R81E9DinMMN43qDhIG3HccSdngOrZoeNvTP5PDioZ)ODOaM8EfWkmeqifaRIDr5bDE)3H4SsnMdTdBHI5jdhTb7v((E9DinMMN43qDhYQgqvB7q955AEmeoASbiNgdwGkAuECC55AEmeYZJcmsgAWH(qkawsjG7Qbc5dopD5bjpTxmkzMQhM8bVdngOrZouJkbvF6bZgSxbk713H0yAEIFd1DiRAavTTd1EXOKzQEyYh8o0yGgn7qyeOrZgSxXD3RVdngOrZo8jivdihXoKgtZt8BOUb7vWR967qAmnpXVH6oKvnGQ22H4SQnnpjBHYq0ouaQMb2R8FhAmqJMDy9gLXanAu(wa2H(wauJ5q7qdrBWELVzV(oKgtZt8BOUdzvdOQTDy9gkIkmKe0ouaunk(ImhTE4PssFRxddt87qbOAgyVY)DOXanA2H1Bugd0Or5Bbyh6BbqnMdTd5lYC06HNQnyVcEVxFhsJP5j(nu3HSQbu12oSEdfrfgsQzEByKcfvM3Ray7bJqsFRxddt87qbOAgyVY)DOXanA2H1Bugd0Or5Bbyh6BbqnMdTd1qgyd2R8)3E9DinMMN43qDhYQgqvB7qpHJ85bDEq53o0yGgn7W6nkJbA0O8TaSd9TaOgZH2HcWgSx5))967qAmnpXVH6o0yGgn7W6nkJbA0O8TaSd9TaOgZH2HWfbBagwLaSbBWoeUiydWWQeG967v(VxFhsJP5j(nu3Hgd0Ozh6GqtSlAhYQgqvB7q95P9IrjZu9WKf5y9iYd68GsECC55AEAVyuYmvpm5dopoU8mbOmVcgfGQ8CjVV(LNU8GKNbRyyj2NDiWkmeq1XDyrXIeynnpLhK8awHHasq7qkasX3uEqN3)G2G9kbTxFhsJP5j(nu3Hgd0OzhkEtSlAhYQgqvB7q95P9IrjZu9WKf5y9iYd68GsECC55AEAVyuYmvpm5dopoU8mbOmVcgfGQ8CjVV(LNU8GKNbRyyj2NDiWkmeq1XDyrXIeynnpLhK8awHHasq7qkasX3uEqN3)G2G9kFTxFhsJP5j(nu3Hgd0OzhkaK3BLk6TI2HSQbu12ouFEAVyuYmvpmzrowpI8GopOKhhxEUMN2lgLmt1dt(GZJJlptakZRGrbOkpxY7RF5Plpi5zWkgwI9zhcScdbuDChwuSibwtZt5bjpGvyiGe0oKcGu8nLh0593D3G9kFFV(oKgtZt8BOUdzvdOQTDObRyyj2NDOXanA2HruXifkQgd8kAd2RaL967qAmnpXVH6oKvnGQ22H6ZZeGY8kyuaQYd68W7F5XXLN2lgLAEeI3)ea5dopi5P9IrPMhH49pbqwKJ1JipxYli3npD5bjpxZt7fJsMP6HjFW7qJbA0SdzKNeG28kZ3yghAaBWEf3DV(oKgtZt8BOUdzvdOQTDO(8mbOmVcgfGQ8Gop8(xECC5P9IrPMhH49pbq(GZdsEAVyuQ5riE)taKf5y9iYZL8(YDZtxEqYZ180EXOKzQEyYh8o0yGgn7WEywngOrZgSxbV2RVdPX08e)gQ7qe8ouqGDOXanA2H4SQnnpTdXz(hTdDnpgc55rbgjZu9WKfz84VdXzLAmhAhkmCKkIkfZu9W2G9kFZE9DinMMN43qDhYQgqvB7qI5Bybj7rzd(5bjpdwXWsSp5bjpCw1MMNKcdhPIOsXmvpSDOXanA2HXxHVcfvK)n0gSxbV3RVdPX08e)gQ7qw1aQABhQ9IrPayLhv8YICSEe55sEUBEqYtFEAVyusmFdliLa5Ts(GZJJlpTxmkjMVHfKY)gRKp480LhK8mbOmVcgfGQ8Gop8(3o0yGgn7qMnmYR0EX4ou7fJQXCODOayLhv8BWEL))2RVdPX08e)gQ7qw1aQABhQppxZZwkvnGKcqr2NEWOeaReYYMp5XXLN2lgLmt1dtwKJ1JipxYJwJypaPaTdLhhxEUMhCr4KcGvIxHHYtxEqYtFEAVyuYmvpm5dopoU8mbOmVcgfGQ8Gop8(xEqYJy(gwqYEu2GFE62Hgd0OzhkawjEfgAd2R8))E9DinMMN43qDhYQgqvB7q955AE2sPQbKuakY(0dgLayLqw28jpoU80EXOKzQEyYICSEe55sE0Ae7bifODO844YZ18GlcNuaSs8kmuE6YdsEaZtdqkaw5rfVKgtZt85bjp95P9IrPayLhv8YhCECC5zcqzEfmkav5bDE49V80LhK80EXOuaSYJkEPaySp55sEFLhK80NN2lgLeZ3WcsjqERKp4844Yt7fJsI5BybP8VXk5dopD7qJbA0SdfaReVcdTb7v(h0E9DinMMN43qDhYQgqvB7q955AE2sPQbKuakY(0dgLayLqw28jpoU80EXOKzQEyYICSEe55sE0Ae7bifODO844YZ18GlcNuaSs8kmuE6YdsEAVyusmFdliLa5TswKJ1JipOZdVYdsEeZ3Wcs2JsG8wLhK8CnpG5PbifaR8OIxsJP5j(8GKhdH88OaJKzQEyYICSEe5bDE41o0yGgn7qbWkXRWqBWEL)FTxFhsJP5j(nu3HSQbu12ouFEAVyusmFdliL)nwjFW5XXLN(8yyTcdjYBrEbLhK8kIH1kmKc0ouEUKhuYtxECC5XWAfgsK3I8(kpD5bjpdwXWsSp5bjpCw1MMNKcdhPIOsXmvpSDOXanA2Hdfq5GqZgSx5)33RVdPX08e)gQ7qw1aQABhQppTxmkjMVHfKY)gRKp4844YtFEmSwHHe5TiVGYdsEfXWAfgsbAhkpxYdk5PlpoU8yyTcdjYBrEFLhhxEAVyuYmvpm5dopD5bjpdwXWsSp5bjpCw1MMNKcdhPIOsXmvpSDOXanA2HynFu5GqZgSx5pu2RVdPX08e)gQ7qw1aQABhQppTxmkjMVHfKY)gRKp4844YtFEmSwHHe5TiVGYdsEfXWAfgsbAhkpxYdk5PlpoU8yyTcdjYBrEFLhhxEAVyuYmvpm5dopD5bjpdwXWsSp5bjpCw1MMNKcdhPIOsXmvpSDOXanA2HXN3RCqOzd2R83D3RVdngOrZomGvvJkfkQi)BODinMMN43qDd2R8hV2RVdPX08e)gQ7qw1aQABhQppBPu1askafzF6bJsaSsilB(KhK80EXOKzQEyYICSEe5bDE0Ae7bifODO8GKhCr4KbkdGnpD5XXLN(8CnpBPu1askafzF6bJsaSsilB(KhhxEAVyuYmvpmzrowpI8CjpAnI9aKc0ouECC55AEWfHtkawf7IYtxEqYtFEeZ3Wcs2JY)gRYJJlpI5BybjfiVvQHwdKhhxEeZ3WcsAd(QHwdKhhxEAVyugWQQrLcfvK)nK8bNhK80EXOKy(gwqk)BSs(GZJJlp95P9IrjZu9WKf5y9iYZL8mgOrJmqzaSsAnI9aKc0ouEqYt7fJsMP6HjFW5PlpD5XXLN(8SLsvdijVfy6bJs8gzzZN8GoVGYdsEAVyusmFdliLa5TswKJ1JipOZdk5bjpxZt7fJsElW0dgL4nYICSEe5bDEgd0OrgOmawjTgXEasbAhkpD7qJbA0SdfaRIDrBWEL)FZE9DOXanA2HbkdGDhsJP5j(nu3G9k)X7967qAmnpXVH6o0yGgn7W6nkJbA0O8TaSd9TaOgZH2HrZ7byR3gSb7qdr713R8FV(oKgtZt8BOUdzvdOQTDO2lgLcGvrZ7LfflsG108uEqYtFEUMx9gkIkmK0JpZktOIEIa9GrHX3oWcssFRxddt85XXLhODO8wsEFhk5bDEAVyukawfnVxwKJ1Jip3YlO80TdngOrZouaSkAE)gSxjO967qAmnpXVH6o0yGgn7qXBIDr7qw1aQABhAWkgwI9jpi5rmFdlizpkBWppi5vuSibwtZt5bjpGvyiGe0oKcGu8nLh059)75HNZtatEVcyfgciYZT8kYX6rSdz4Z8Kcyfgci2R8Fd2R81E9DinMMN43qDhAmqJMDOdcnXUODiRAavTTdlkwKaRP5P8GKhWkmeqcAhsbqk(MYd680N3)VNNB5Pppbm59kGvyiGqkawf7IYdpY7Vek5PlpD5TCEcyY7vaRWqarEULxrowpI8GKN(8yiKNhfyKmt1dtwKXJFECC5jGjVxbScdbesbWQyxuEUK3x5XXLN(8iMVHfKShLa5TkpoU8iMVHfKShLgcGnpoU8iMVHfKShL)nwLhK8CnpG5PbifONxHIkawsfrfjasAmnpXNNU8GKN(8eWK3RawHHacPayvSlkpxY7)V8WJ80N3)8ClpG5Pbibb6r5GqJqsJP5j(80LNU8GKNjaL5vWOauLh05bLF5HNZt7fJsbWQO59YICSEe5Hh55U5Plpi55AEAVyu(Ph(I4vKdmkavo0au0qfMEPK8bNhK8myfdlX(Sdz4Z8Kcyfgci2R8Fd2R89967qAmnpXVH6oKvnGQ22HgSIHLyF2Hgd0OzhgrfJuOOAmWROnyVcu2RVdPX08e)gQ7qw1aQABhQ9IrjZu9WKp4DOXanA2HLHJg0tOIfnlf)nyVI7UxFhsJP5j(nu3HSQbu12ouFEAVyukawfnVx(GZJJlptakZRGrbOkpOZdk)YtxEqYZ180EXOuG8cqZi5dopi55AEAVyuYmvpm5dopi5PpVEaubJ8gG4vXgdwGQihRhrEUKhdH88OaJKHgCOpKcGLuc4UAGqwKJ1Jip3YdVYJJlVEaubJ8gG4vXgdwGQihRhrEljV)FZV8CjVGckpoU8yiKNhfyKm0Gd9HuaSKsa3vdeYhCECC55AEmeoASbiNgdwGkAuE62Hgd0OzhYipjaT5vMVXmo0a2G9k41E9DinMMN43qDhYQgqvB7WyJblqvKJ1JipxY7puYJJlp95P9IrjC1oOIVnVYkMnntb)8cRK4m)JYZL8cck)YJJlpTxmkHR2bv8T5vwXSPzk4NxyLeN5FuEqViVGGYV80LhK80EXOuaSkAEV8bNhK8yiKNhfyKmt1dtwKJ1JipOZdk)2Hgd0Ozh2dZQXanA2G9kFZE9DinMMN43qDhAmqJMDOaqEVvQO3kAhYQgqvB7WIIfjWAAEkpi5bAhsbqk(MYd68(dL8GKNaM8EfWkmeqifaRIDr55sEFppi5zWkgwI9jpi5PppTxmkzMQhMSihRhrEqN3)F5XXLNR5P9IrjZu9WKp480Tdz4Z8Kcyfgci2R8Fd2RG3713H0yAEIFd1DicEhkiWo0yGgn7qCw1MMN2H4m)J2HAVyucxTdQ4BZRSIztZuWpVWkjoZ)O8CjVGGYV8WZ5zcqzEfmkav5bjp95XqippkWizMQhMSihRhrEUL3)F5bDEXgdwGQihRhrECC5XqippkWizMQhMSihRhrEUL3x)YZL8IngSavrowpI8GKxSXGfOkYX6rKh059)RF5XXLN2lgLmt1dtwKJ1JipOZdVYtxEqYJy(gwqYEu2GFECC5fBmybQICSEe5TK8(h0V8CjV)qzhIZk1yo0oKHgCOpKIHg(g0Ozd2R8)3E9DinMMN43qDhYQgqvB7qCw1MMNKm0Gd9Hum0W3Ggn5bjptakZRGrbOkpxYdk)2Hgd0OzhYqdo0hsbWskbCxnqSb7v()FV(oKgtZt8BOUdzvdOQTDiX8nSGK9OSb)8GKNbRyyj2N8GKN2lgLWv7Gk(28kRy20mf8ZlSsIZ8pkpxYliO8lpi5PppEeqA8gmOXrkraRCu8MJHHKGM9Phm5XXLNR5Xq4OXgGCiwH8OIppoU8eWK3RawHHaI8GoVGYt3o0yGgn7W4RWxHIkY)gAd2R8pO967qAmnpXVH6o0yGgn7qJ3GbnosjcyLZoKvnGQ22HUMhOzF6btEqYtatEVcyfgciKcGvrZ7ZZL8W7DidFMNuaRWqaXEL)BWEL)FTxFhsJP5j(nu3HSQbu12ou7fJs0qaScfmvmcg0Or(GZdsE6Zt7fJsbWQO59YIIfjWAAEkpoU8mbOmVcgfGQ8Gop8(xE62Hgd0OzhkawfnVFd2R8)7713H0yAEIFd1DiRAavTTdziC0ydqongSav0O8GKhoRAtZtsgAWH(qkgA4BqJM8GKhdH88OaJKHgCOpKcGLuc4UAGqwKJ1JipxYddJx6yRLhEKhJAFE6ZZeGY8kyuaQYB58GYV80LhK80EXOuaSkAEVSOyrcSMMN2Hgd0OzhkawfnVFd2R8hk713H0yAEIFd1DiRAavTTdziC0ydqongSav0O8GKhoRAtZtsgAWH(qkgA4BqJM8GKhdH88OaJKHgCOpKcGLuc4UAGqwKJ1JipxYddJx6yRLhEKhJAFE6ZZeGY8kyuaQYB58(6xE6YdsEAVyukawfnVx(G3Hgd0OzhkawjEfgAd2R83D3RVdPX08e)gQ7qe8ouqGDOXanA2H4SQnnpTdXz(hTdnbOmVcgfGQ8GoVV5xE4580NN2lgLcGvrZ7Lf5y9iYdpY7R8wopbm59kSMaq5Plp8CE6ZJhbKXxHVcfvK)nKSihRhrE4rEqjpD5bjpTxmkfaRIM3lFW7qCwPgZH2HcGvrZ7vbqdqfnVxHIXnyVYF8AV(oKgtZt8BOUdzvdOQTDO2lgLOHayfkMNSsHRfnAKp4844YZ18eaRIDrsdwXWsSp5XXLN(80EXOKzQEyYICSEe55sEqjpi5P9IrjZu9WKp4844YtFEAVyuwgoAqpHkw0Su8Lf5y9iYZL8WW4Lo2A5Hh5XO2NN(8mbOmVcgfGQ8woVV(LNU8GKN2lgLLHJg0tOIfnlfF5dopD5Plpi5HZQ208KuaSkAEVkaAaQO59kumMhK8eWK3RawHHacPayv08(8CjVV2Hgd0OzhkawjEfgAd2R8)B2RVdPX08e)gQ7qw1aQABhQppI5Bybj7rzd(5bjpgc55rbgjZu9WKf5y9iYd68GYV844YtFEmSwHHe5TiVGYdsEfXWAfgsbAhkpxYdk5PlpoU8yyTcdjYBrEFLNU8GKNbRyyj2NDOXanA2Hdfq5GqZgSx5pEVxFhsJP5j(nu3HSQbu12ouFEeZ3Wcs2JYg8ZdsEmeYZJcmsMP6HjlYX6rKh05bLF5XXLN(8yyTcdjYBrEbLhK8kIH1kmKc0ouEUKhuYtxECC5XWAfgsK3I8(kpD5bjpdwXWsSp7qJbA0SdXA(OYbHMnyVsq)2RVdPX08e)gQ7qw1aQABhQppI5Bybj7rzd(5bjpgc55rbgjZu9WKf5y9iYd68GYV844YtFEmSwHHe5TiVGYdsEfXWAfgsbAhkpxYdk5PlpoU8yyTcdjYBrEFLNU8GKNbRyyj2NDOXanA2HXN3RCqOzd2Re0)967qJbA0Sddyv1OsHIkY)gAhsJP5j(nu3G9kbf0E9DinMMN43qDhIG3HccSdngOrZoeNvTP5PDioZ)ODOaM8EfWkmeqifaRIDr5bDEFtEULx0JqvE6ZZXeaQWxHZ8pkVLZlOF5Plp3Yl6rOkp95P9IrPayL4vyif5aJcqLdnaPaySp5TCEFppD7qCwPgZH2HcGvXUivpkbYB1gSxjOV2RVdngOrZouaSk2fTdPX08e)gQBWELG((E9DinMMN43qDhAmqJMDy9gLXanAu(wa2H(wauJ5q7WO59aS1Bd2GDy08Ea26TxFVY)967qAmnpXVH6oKvnGQ22HUMx9gkIkmKuZ82WifkQmVxbW2dgHK(wVggM43Hgd0OzhkawjEfgAd2Re0E9DinMMN43qDhAmqJMDO4nXUODiRAavTTd5raPdcnXUizrowpI8GoVICSEe7qg(mpPawHHaI9k)3G9kFTxFhAmqJMDOdcnXUODinMMN43qDd2GDOaSxFVY)967qAmnpXVH6o0yGgn7qheAIDr7qw1aQABhwuSibwtZt5bjpGvyiGe0oKcGu8nLh059pO8GKN(80EXOKzQEyYICSEe5bDEqjpi5PppTxmkldhnONqflAwk(YICSEe5bDEqjpoU8CnpTxmkldhnONqflAwk(YhCE6YJJlpxZt7fJsMP6HjFW5XXLNjaL5vWOauLNl591V80LhK80NNR5P9Ir5NE4lIxroWOau5qdqrdvy6LsYhCECC5zcqzEfmkav55sEF9lpD5bjpdwXWsSp7qg(mpPawHHaI9k)3G9kbTxFhsJP5j(nu3Hgd0OzhkEtSlAhYQgqvB7WIIfjWAAEkpi5bScdbKG2HuaKIVP8GoV)bLhK80NN2lgLmt1dtwKJ1JipOZdk5bjp95P9Irzz4Ob9eQyrZsXxwKJ1JipOZdk5XXLNR5P9Irzz4Ob9eQyrZsXx(GZtxECC55AEAVyuYmvpm5dopoU8mbOmVcgfGQ8CjVV(LNU8GKN(8CnpTxmk)0dFr8kYbgfGkhAakAOctVus(GZJJlptakZRGrbOkpxY7RF5Plpi5zWkgwI9zhYWN5jfWkmeqSx5)gSx5R967qAmnpXVH6o0yGgn7qbG8ERurVv0oKvnGQ22HfflsG108uEqYdyfgcibTdPaifFt5bDE)D38GKN(80EXOKzQEyYICSEe5bDEqjpi5PppTxmkldhnONqflAwk(YICSEe5bDEqjpoU8CnpTxmkldhnONqflAwk(YhCE6YJJlpxZt7fJsMP6HjFW5XXLNjaL5vWOauLNl591V80LhK80NNR5P9Ir5NE4lIxroWOau5qdqrdvy6LsYhCECC5zcqzEfmkav55sEF9lpD5bjpdwXWsSp7qg(mpPawHHaI9k)3G9kFFV(oKgtZt8BOUdzvdOQTDObRyyj2NDOXanA2HruXifkQgd8kAd2RaL967qAmnpXVH6oKvnGQ22HAVyuYmvpm5dEhAmqJMDyz4Ob9eQyrZsXFd2R4U713H0yAEIFd1DiRAavTTd1NN(80EXOKy(gwqkbYBLSihRhrEqN3)F5XXLN2lgLeZ3Wcs5FJvYICSEe5bDE))LNU8GKhdH88OaJKzQEyYICSEe5bDEF9lpi5PppTxmkHR2bv8T5vwXSPzk4NxyLeN5FuEUKxqF)xECC55AE1BOiQWqs4QDqfFBELvmBAMc(5fwjPV1RHHj(80LNU844Yt7fJs4QDqfFBELvmBAMc(5fwjXz(hLh0lYli86xECC5XqippkWizMQhMSiJh)8GKN(8mbOmVcgfGQ8Gop8(xECC5HZQ208KSfkdr5PBhAmqJMD4NE4lIxjG7QbInyVcETxFhsJP5j(nu3HSQbu12ouFEMauMxbJcqvEqNhE)lpi5PppTxmk)0dFr8kYbgfGkhAakAOctVus(GZJJlpxZJHWrJna5h8R2M80LhhxEmeoASbiNgdwGkAuECC5HZQ208KSfkdr5XXLN2lgLAEeI3)ea5dopi5P9IrPMhH49pbqwKJ1JipxYlOF55wE6ZtFE4DE4rE1BOiQWqs4QDqfFBELvmBAMc(5fwjPV1RHHj(80LNB5PpVVNhEKhdn8VgiHlI1csz(gZ4qdqsJP5j(80LNU80LhK8CnpTxmkzMQhM8bNhK80NxSXGfOkYX6rKNl5XqippkWizObh6dPayjLaURgiKf5y9iYZT8WR844Yl2yWcuf5y9iYZL8ckO8Clp95H35Hh5PppTxmkHR2bv8T5vwXSPzk4NxyLeN5FuEqN3)F)YtxE6YJJlVyJblqvKJ1JiVLK3)V5xEUKxqbLhhxEmeYZJcmsgAWH(qkawsjG7Qbc5dopoU8Cnpgchn2aKtJblqfnkpD7qJbA0SdzKNeG28kZ3yghAaBWELVzV(oKgtZt8BOUdzvdOQTDO(8mbOmVcgfGQ8Gop8(xEqYtFEAVyu(Ph(I4vKdmkavo0au0qfMEPK8bNhhxEUMhdHJgBaYp4xTn5PlpoU8yiC0ydqongSav0O844YdNvTP5jzlugIYJJlpTxmk18ieV)jaYhCEqYt7fJsnpcX7FcGSihRhrEUK3x)YZT80NN(8W78WJ8Q3qruHHKWv7Gk(28kRy20mf8ZlSssFRxddt85Plp3YtFEFpp8ipgA4FnqcxeRfKY8nMXHgGKgtZt85PlpD5Plpi55AEAVyuYmvpm5dopi5PpVyJblqvKJ1JipxYJHqEEuGrYqdo0hsbWskbCxnqilYX6rKNB5Hx5XXLxSXGfOkYX6rKNl59vq55wE6ZdVZdpYtFEAVyucxTdQ4BZRSIztZuWpVWkjoZ)O8GoV))(LNU80LhhxEXgdwGQihRhrEljV)FZV8CjVVckpoU8yiKNhfyKm0Gd9HuaSKsa3vdeYhCECC55AEmeoASbiNgdwGkAuE62Hgd0Ozh2dZQXanA2G9k49E9DinMMN43qDhIG3HccSdngOrZoeNvTP5PDioZ)ODidHJgBaYPXGfOIgLhK80NN2lgLWv7Gk(28kRy20mf8ZlSsIZ8pkpxYlOV)lpi5Pppgc55rbgjZu9WKf5y9iYZT8()lpOZl2yWcuf5y9iYJJlpgc55rbgjZu9WKf5y9iYZT8(6xEUKxSXGfOkYX6rKhK8IngSavrowpI8GoV)F9lpoU80EXOKzQEyYICSEe5bDE4vE6YdsEAVyusmFdliLa5TswKJ1JipOZ7)V844Yl2yWcuf5y9iYBj59pOF55sE)HsE62H4SsnMdTdzObh6dPyOHVbnA2G9k))TxFhsJP5j(nu3Hi4DOGa7qJbA0SdXzvBAEAhIZ8pAhQppxZJHqEEuGrYmvpmzrgp(5XXLNR5HZQ208KKHgCOpKIHg(g0Ojpi5Xq4OXgGCAmybQOr5PBhIZk1yo0ouy4ivevkMP6HTb7v()FV(oKgtZt8BOUdzvdOQTDioRAtZtsgAWH(qkgA4BqJM8GKNjaL5vWOauLNl591VDOXanA2Hm0Gd9HuaSKsa3vdeBWEL)bTxFhsJP5j(nu3HSQbu12oKy(gwqYEu2GFEqYZGvmSe7tEqYt7fJs4QDqfFBELvmBAMc(5fwjXz(hLNl5f03)LhK80NhpcinEdg04iLiGvokEZXWqsqZ(0dM844YZ18yiC0ydqoeRqEuXNNU8GKhoRAtZtsHHJuruPyMQh2o0yGgn7W4RWxHIkY)gAd2R8)R967qAmnpXVH6oKvnGQ22H7qJbA0SdnEdg04iLiGvoBWEL)FFV(oKgtZt8BOUdzvdOQTDO2lgLOHayfkyQyemOrJ8bNhK80EXOuaSkAEVSOyrcSMMN2Hgd0OzhkawfnVFd2R8hk713H0yAEIFd1DiRAavTTd1EXOuaSYJkEzrowpI8Cjp3npi5PppTxmkjMVHfKsG8wjFW5XXLN2lgLeZ3Wcs5FJvYhCE6YdsEMauMxbJcqvEqNhE)BhAmqJMDiZgg5vAVyChQ9Ir1yo0ouaSYJk(nyVYF3DV(oKgtZt8BOUdzvdOQTDidHJgBaYPXGfOIgLhK8WzvBAEsYqdo0hsXqdFdA0KhK8yiKNhfyKm0Gd9HuaSKsa3vdeYICSEe55sEyy8shBT8WJ8yu7ZtFEMauMxbJcqvElN3x)Yt3o0yGgn7qbWkXRWqBWEL)41E9DinMMN43qDhYQgqvB7qG5PbifaY7TsXxDeiPX08eFEqYZ18aMNgGuaSYJkEjnMMN4ZdsEAVyukawfnVxwuSibwtZt5bjp95P9IrjX8nSGu(3yLSihRhrEqNN7MhK8iMVHfKShL)nwLhK80EXOeUAhuX3MxzfZMMPGFEHvsCM)r55sEbbLF5XXLN2lgLWv7Gk(28kRy20mf8ZlSsIZ8pkpOxKxqq5xEqYZeGY8kyuaQYd68W7F5XXLhpcinEdg04iLiGvokEZXWqYICSEe5bDEFtECC5zmqJgPXBWGghPebSYrXBoggs2Jk6Bmyb5Plpi55AEmeYZJcmsMP6HjlY4XFhAmqJMDOayv08(nyVY)VzV(oKgtZt8BOUdzvdOQTDO2lgLOHayfkMNSsHRfnAKp4844Yt7fJYp9WxeVICGrbOYHgGIgQW0lLKp4844Yt7fJsMP6HjFW5bjp95P9Irzz4Ob9eQyrZsXxwKJ1JipxYddJx6yRLhEKhJAFE6ZZeGY8kyuaQYB58(6xE6YdsEAVyuwgoAqpHkw0Su8Lp4844YZ180EXOSmC0GEcvSOzP4lFW5bjpxZJHqEEuGrwgoAqpHkw0Su8Lfz84NhhxEUMhdHJgBasC0aWIFLNU844YZeGY8kyuaQYd68W7F5bjpI5Bybj7rzd(7qJbA0SdfaReVcdTb7v(J3713H0yAEIFd1DiRAavTTdbMNgGuaSYJkEjnMMN4ZdsE6Zt7fJsbWkpQ4Lp4844YZeGY8kyuaQYd68W7F5Plpi5P9IrPayLhv8sbWyFYZL8(kpi5PppTxmkjMVHfKsG8wjFW5XXLN2lgLeZ3Wcs5FJvYhCE6YdsEAVyucxTdQ4BZRSIztZuWpVWkjoZ)O8CjVGWRF5bjp95XqippkWizMQhMSihRhrEqN3)F5XXLNR5HZQ208KKHgCOpKIHg(g0Ojpi5Xq4OXgGCAmybQOr5PBhAmqJMDOayL4vyOnyVsq)2RVdPX08e)gQ7qw1aQABhQppTxmkHR2bv8T5vwXSPzk4NxyLeN5FuEUKxq41V844Yt7fJs4QDqfFBELvmBAMc(5fwjXz(hLNl5feu(LhK8aMNgGuaiV3kfF1rGKgtZt85Plpi5P9IrjX8nSGucK3kzrowpI8Gop8kpi5rmFdlizpkbYBvEqYZ180EXOeneaRqbtfJGbnAKp48GKNR5bmpnaPayLhv8sAmnpXNhK8yiKNhfyKmt1dtwKJ1JipOZdVYdsE6ZJHqEEuGr(Ph(I4vc4UAGqwKJ1JipOZdVYJJlpxZJHWrJna5h8R2M80TdngOrZouaSs8km0gSxjO)713H0yAEIFd1DiRAavTTd1NN2lgLeZ3Wcs5FJvYhCECC5PppgwRWqI8wKxq5bjVIyyTcdPaTdLNl5bL80LhhxEmSwHHe5TiVVYtxEqYZGvmSe7tEqYdNvTP5jPWWrQiQumt1dBhAmqJMD4qbuoi0Sb7vckO967qAmnpXVH6oKvnGQ22H6Zt7fJsI5BybP8VXk5dopi55AEmeoASbi)GF12KhhxE6Zt7fJYp9WxeVICGrbOYHgGIgQW0lLKp48GKhdHJgBaYp4xTn5PlpoU80NhdRvyirElYlO8GKxrmSwHHuG2HYZL8GsE6YJJlpgwRWqI8wK3x5XXLN2lgLmt1dt(GZtxEqYZGvmSe7tEqYdNvTP5jPWWrQiQumt1dBhAmqJMDiwZhvoi0Sb7vc6R967qAmnpXVH6oKvnGQ22H6Zt7fJsI5BybP8VXk5dopi55AEmeoASbi)GF12KhhxE6Zt7fJYp9WxeVICGrbOYHgGIgQW0lLKp48GKhdHJgBaYp4xTn5PlpoU80NhdRvyirElYlO8GKxrmSwHHuG2HYZL8GsE6YJJlpgwRWqI8wK3x5XXLN2lgLmt1dt(GZtxEqYZGvmSe7tEqYdNvTP5jPWWrQiQumt1dBhAmqJMDy859kheA2G9kb99967qJbA0Sddyv1OsHIkY)gAhsJP5j(nu3G9kbbL967qAmnpXVH6oKvnGQ22HeZ3Wcs2JY)gRYJJlpI5BybjfiVvQHwdKhhxEeZ3WcsAd(QHwdKhhxEAVyugWQQrLcfvK)nK8bNhK80EXOKy(gwqk)BSs(GZJJlp95P9IrjZu9WKf5y9iYZL8mgOrJmqzaSsAnI9aKc0ouEqYt7fJsMP6HjFW5PBhAmqJMDOayvSlAd2ReK7UxFhAmqJMDyGYay3H0yAEIFd1nyVsq41E9DinMMN43qDhAmqJMDy9gLXanAu(wa2H(wauJ5q7WO59aS1Bd2GDiFrMJwp8uTxFVY)967qAmnpXVH6oebVdfeyhAmqJMDioRAtZt7qCM)r7q95P9IrjODOaOAu8fzoA9WtLSihRhrEqNhggV0Xwlpi55AEeZ3Wcs2JY)gRYdsEUMhX8nSGKcK3k1qRbYdsEUMhX8nSGK2GVAO1a5XXLN2lgLG2HcGQrXxK5O1dpvYICSEe5bDEgd0Orkawf7IK0Ae7bifODO8GKN(8eWK3RawHHacPayvSlkpOZ7FECC5rmFdlizpk)BSkpoU8iMVHfKuG8wPgAnqECC5rmFdliPn4RgAnqE6YtxECC55AEAVyucAhkaQgfFrMJwp8ujFW7qCwPgZH2Hclskas9eKsatE)gSxjO967qAmnpXVH6oKvnGQ22H6ZZ18WzvBAEskSiPai1tqkbm595XXLN(80NN2lgLeZ3WcsjqERKf5y9iYZL8WW4Lo2A5bjpTxmkjMVHfKsG8wjFW5PlpoU80NN2lgLLHJg0tOIfnlfFzrowpI8CjpmmEPJTwE4rEmQ95PpptakZRGrbOkVLZ7RF5Plpi5P9Irzz4Ob9eQyrZsXx(GZtxE6YtxEqYtFEAVyusmFdliLa5Ts(GZJJlpI5BybjfiVvQHwdKhhxEeZ3WcsAd(QHwdKNU844YZeGY8kyuaQYd68W7F7qJbA0SdfaReVcdTb7v(AV(oKgtZt8BOUdngOrZo0bHMyx0oKvnGQ22HfflsG108uEqYdyfgcibTdPaifFt5bDE)D38GKNR5P9Ir5NE4lIxroWOau5qdqrdvy6LsYh8oKHpZtkGvyiGyVY)nyVY33RVdPX08e)gQ7qJbA0SdfVj2fTdzvdOQTDyrXIeynnpLhK8awHHasq7qkasX3uEqN3F3npi55AEAVyu(Ph(I4vKdmkavo0au0qfMEPK8bVdz4Z8Kcyfgci2R8Fd2RaL967qAmnpXVH6o0yGgn7qbG8ERurVv0oKvnGQ22HfflsG108uEqYdyfgcibTdPaifFt5bDE)D38GKN(80EXOKzQEyYICSEe5bDE))LhhxEUMN2lgLmt1dt(GZtxEqYZGvmSe7tEqYZ180EXO8tp8fXRihyuaQCObOOHkm9sj5dEhYWN5jfWkmeqSx5)gSxXD3RVdPX08e)gQ7qw1aQABhAcqzEfmkav55sE41V8GKN(80EXOe0ouaunk(ImhTE4PswKJ1JipOZddJx6yRLhEKxq5XXLNR5P9IrjODOaOAu8fzoA9WtL8bNNUDOXanA2HLHJg0tOIfnlf)nyVcETxFhsJP5j(nu3HSQbu12o0GvmSe7tEqYZ180EXOKzQEyYhCEqYtFEAVyucAhkaQgfFrMJwp8ujlYX6rKh05HHXlDS1YJJlpxZt7fJsq7qbq1O4lYC06HNk5dopD5bjpdwXWsSp5bjpxZt7fJsMP6HjFW5bjp95fBmybQICSEe55sEmeYZJcmsgAWH(qkawsjG7QbczrowpI8Clp8kpoU8IngSavrowpI8wsE))MF55sEbfuECC5XqippkWizObh6dPayjLaURgiKp4844YZ18yiC0ydqongSav0O80TdngOrZoKrEsaAZRmFJzCObSb7v(M967qAmnpXVH6oKvnGQ22HgSIHLyFYdsEUMN2lgLmt1dt(GZdsE6Zt7fJsq7qbq1O4lYC06HNkzrowpI8GopmmEPJTwECC55AEAVyucAhkaQgfFrMJwp8ujFW5Plpi5PpVyJblqvKJ1JipxYJHqEEuGrYqdo0hsbWskbCxnqilYX6rKNB5Hx5XXLxSXGfOkYX6rK3sY7)38lpxY7RGYJJlpgc55rbgjdn4qFifalPeWD1aH8bNhhxEUMhdHJgBaYPXGfOIgLNUDOXanA2H9WSAmqJMnyVcEVxFhsJP5j(nu3HSQbu12o0GvmSe7Zo0yGgn7WiQyKcfvJbEfTb7v()BV(oKgtZt8BOUdzvdOQTDO2lgLG2HcGQrXxK5O1dpvYICSEe5bDEyy8shBT8GKN(8IEeQYtFE6Zl2yWcuf5y9iYdpN3)F5PlVLZZyGgnkgc55rbM80Lh05f9iuLN(80NxSXGfOkYX6rKhEoV))YdpNhdH88OaJKzQEyYICSEe5PlVLZZyGgnkgc55rbM80LhK80NhX8nSGK9OeiVv5XXLhX8nSGKcK3k1qRbYJJlpTxmkzMQhMSihRhrEqN3)F5XXLN2lgLWv7Gk(28kRy20mf8ZlSsIZ8pkpOxKxq41V8GKNjaL5vWOauLh05bLF5PlpD7qJbA0Sd)0dFr8kbCxnqSb7v()FV(oKgtZt8BOUdrW7qbb2Hgd0OzhIZQ2080oeN5F0ou7fJs4QDqfFBELvmBAMc(5fwjXz(hLNl5f03)LhK80NhdH88OaJKzQEyYICSEe55wE))Lh05fBmybQICSEe5XXLhdH88OaJKzQEyYICSEe55wEF9lpxYl2yWcuf5y9iYdsEXgdwGQihRhrEqN3)V(LhhxEXgdwGQihRhrEljV)b9lpxY7puYJJlpTxmkzMQhMSihRhrEqNhELNU8GKhX8nSGK9OSb)DioRuJ5q7qgAWH(qkgA4BqJMnyVY)G2RVdPX08e)gQ7qw1aQABhIZQ208KKHgCOpKIHg(g0Ojpi5PpptakZRGrbOkpxYdk)YdsE4SQnnpjBHYquECC5zcqzEfmkav55sEF9lpD5bjp95P9IrjODOaOAu8fzoA9WtLSihRhrEqNhTgXEasbAhkpoU8CnpTxmkbTdfavJIViZrRhEQKp480TdngOrZoKHgCOpKcGLuc4UAGyd2R8)R967qAmnpXVH6oKvnGQ22HeZ3Wcs2JYg8ZdsEgSIHLyFYdsE4SQnnpjfwKuaK6jiLaM8(8GKN(84raPXBWGghPebSYrXBoggscA2NEWKhhxEUMhdHJgBaYHyfYJk(844YtatEVcyfgciYd68ckpD7qJbA0SdJVcFfkQi)BOnyVY)VVxFhsJP5j(nu3HSQbu12oChAmqJMDOXBWGghPebSYzd2R8hk713H0yAEIFd1DiRAavTTdDnpgchn2aKtJblqfnkpi5XqippkWizMQhMSiJh)8GKNjaL5vWOauLh05Hx)2Hgd0OzhkawjEfgAd2R83D3RVdPX08e)gQ7qw1aQABhYq4OXgGCAmybQOr5bjpCw1MMNKm0Gd9Hum0W3Ggn5bjptakZRGrbOkpOxK3x)YdsEmeYZJcmsgAWH(qkawsjG7QbczrowpI8CjpmmEPJTwE4rEmQ95PpptakZRGrbOkVLZ7RF5PBhAmqJMDOayL4vyOnyVYF8AV(oKgtZt8BOUdzvdOQTDO(80EXOKy(gwqk)BSs(GZJJlp95XWAfgsK3I8ckpi5vedRvyifODO8CjpOKNU844YJH1kmKiVf59vE6YdsEgSIHLyF2Hgd0OzhouaLdcnBWEL)FZE9DinMMN43qDhYQgqvB7q95P9IrjX8nSGu(3yL8bNhhxE6ZJH1kmKiVf5fuEqYRigwRWqkq7q55sEqjpD5XXLhdRvyirElY7R80LhK8myfdlX(KhK80NN2lgLG2HcGQrXxK5O1dpvYICSEe5bDE0Ae7bifODO844YZ180EXOe0ouaunk(ImhTE4Ps(GZt3o0yGgn7qSMpQCqOzd2R8hV3RVdPX08e)gQ7qw1aQABhQppTxmkjMVHfKY)gRKp4844YtFEmSwHHe5TiVGYdsEfXWAfgsbAhkpxYdk5PlpoU8yyTcdjYBrEFLNU8GKNbRyyj2N8GKN(80EXOe0ouaunk(ImhTE4PswKJ1JipOZJwJypaPaTdLhhxEUMN2lgLG2HcGQrXxK5O1dpvYhCE62Hgd0OzhgFEVYbHMnyVsq)2RVdngOrZomGvvJkfkQi)BODinMMN43qDd2Re0)967qAmnpXVH6oKvnGQ22HeZ3Wcs2JY)gRYJJlpI5BybjfiVvQHwdKhhxEeZ3WcsAd(QHwdKhhxEAVyugWQQrLcfvK)nK8bNhK80EXOKy(gwqk)BSs(GZJJlp95P9IrjZu9WKf5y9iYZL8mgOrJmqzaSsAnI9aKc0ouEqYt7fJsMP6HjFW5PBhAmqJMDOayvSlAd2Reuq713Hgd0OzhgOma2DinMMN43qDd2Re0x713H0yAEIFd1DOXanA2H1Bugd0Or5Bbyh6BbqnMdTdJM3dWwVnyd2GDioQenA2Re0VG(9)3)V2HbSA6bJyh6()B395kUpwX9hEkV8whlLx7aJkqEruL33gFrMJwp8u9TLxrFRxxeFEcKdLN9aihdq85XWAdgsiZGDVEO8ccpLN7GgCubi(8cBh3jpb(dWwlVLKhaLN79S84BCTOrtEiyQmaQYt)Y6Yt))10jZGDVEO8Wl8uEUdAWrfG4ZlSDCN8e4paBT8wYsYdGYZ9EwEoi(N)jYdbtLbqvE6xIU80)FnDYmy3RhkVVbpLN7GgCubi(8cBh3jpb(dWwlVLSK8aO8CVNLNdI)5FI8qWuzauLN(LOlp9)xtNmd296HY7)p8uEUdAWrfG4ZlSDCN8e4paBT8wsEauEU3ZYJVX1Ign5HGPYaOkp9lRlp9bTMozgS71dL3))4P8Ch0GJkaXNxy74o5jWFa2A5TKLKhaLN79S8Cq8p)tKhcMkdGQ80VeD5P))A6KzWUxpuE)Dx8uEUdAWrfG4ZlSDCN8e4paBT8wsEauEU3ZYJVX1Ign5HGPYaOkp9lRlp9)xtNmdod29)3U7ZvCFSI7p8uE5TowkV2bgvG8IOkVVn4Iyihnd8TLxrFRxxeFEcKdLN9aihdq85XWAdgsiZGDVEO8GcEkp3bn4Ocq85f2oUtEc8hGTwEljpakp37z5X34ArJM8qWuzauLN(L1LN(GwtNmdod29)3U7ZvCFSI7p8uE5TowkV2bgvG8IOkVVndrFB5v0361fXNNa5q5zpaYXaeFEmS2GHeYmy3RhkV)4P8Ch0GJkaXNxy74o5jWFa2A5TKLKhaLN79S8Cq8p)tKhcMkdGQ80VeD5P))A6KzWUxpuEFHNYZDqdoQaeFEHTJ7KNa)byRL3sYdGYZ9EwE8nUw0Ojpemvgav5PFzD5P))A6KzWUxpuEUlEkp3bn4Ocq85f2oUtEc8hGTwElzj5bq55Eplphe)Z)e5HGPYaOkp9lrxE6)VMozgS71dLhEHNYZDqdoQaeFEHTJ7KNa)byRL3swsEauEU3ZYZbX)8prEiyQmaQYt)s0LN()RPtMb7E9q5H34P8Ch0GJkaXNxy74o5jWFa2A5TKLKhaLN79S8Cq8p)tKhcMkdGQ80VeD5P))A6KzWUxpuE))oEkp3bn4Ocq85f2oUtEc8hGTwEljpakp37z5X34ArJM8qWuzauLN(L1LN()RPtMb7E9q59hk4P8Ch0GJkaXNxy74o5jWFa2A5TK8aO8CVNLhFJRfnAYdbtLbqvE6xwxE6)VMozgS71dL3F3fpLN7GgCubi(8cBh3jpb(dWwlVLKhaLN79S84BCTOrtEiyQmaQYt)Y6Yt))10jZGDVEO8(Jx4P8Ch0GJkaXNxy74o5jWFa2A5TK8aO8CVNLhFJRfnAYdbtLbqvE6xwxE6)VMozgS71dLxqbHNYZDqdoQaeFEHTJ7KNa)byRL3sYdGYZ9EwE8nUw0Ojpemvgav5PFzD5PpO10jZGZGD))T7(Cf3hR4(dpLxERJLYRDGrfiViQY7Bta(2YROV1RlIppbYHYZEaKJbi(8yyTbdjKzWUxpuE4fEkp3bn4Ocq85f2oUtEc8hGTwElzj5bq55Eplphe)Z)e5HGPYaOkp9lrxE6)VMozgS71dL33GNYZDqdoQaeFEHTJ7KNa)byRL3swsEauEU3ZYZbX)8prEiyQmaQYt)s0LN()RPtMb7E9q5H34P8Ch0GJkaXNxy74o5jWFa2A5TKLKhaLN79S8Cq8p)tKhcMkdGQ80VeD5P))A6KzWUxpuE)Dx8uEUdAWrfG4ZlSDCN8e4paBT8wsEauEU3ZYJVX1Ign5HGPYaOkp9lRlp9)xtNmd296HY7)3GNYZDqdoQaeFEHTJ7KNa)byRL3sYdGYZ9EwE8nUw0Ojpemvgav5PFzD5P))A6KzWzWU))2DFUI7JvC)HNYlV1Xs51oWOcKxev59TPHmW3wEf9TEDr85jqouE2dGCmaXNhdRnyiHmd296HY7)F8uEUdAWrfG4ZlSDCN8e4paBT8wYsYdGYZ9EwEoi(N)jYdbtLbqvE6xIU80)FnDYmy3RhkV)UlEkp3bn4Ocq85f2oUtEc8hGTwEljpakp37z5X34ArJM8qWuzauLN(L1LN(VwtNmd296HY7pEHNYZDqdoQaeFEHTJ7KNa)byRL3sYdGYZ9EwE8nUw0Ojpemvgav5PFzD5P))A6KzWzWUpCGrfG4Z7BYZyGgn55BbqiZG3HcyITx5)VG2HWfk2EAh6(MhunVnmkp3VRxZNb7(MN7xyaKgv59)7RMxq)c6xgCgS7BEUdwBWqc8ugS7BE458(255j(8crERYdQK5iZGDFZdpNN7G1gmeFEaRWqavhZJzcsKhaLhdFMNuaRWqaHmd29np8CEUpjheoIpV3meJecRWppCw1MMNe5PVLKC18GlcNsaSs8kmuE4zOZdUiCsbWkXRWq6KzWzWgd0OriHlIHC0mWcheA(0JkIkNmyJbA0iKWfXqoAgWTflhOma2myJbA0iKWfXqoAgWTflhOma2myJbA0iKWfXqoAgWTfllawjEfgA1oUqatEVcyfgciKcGvrZ7D57zWgd0OriHlIHC0mGBlwgNvTP5PvhZHwWqdo0hsXtc8h2Q4m)JwOHecirpcv61hBmybQICSEe45G(PBj)d6NoOJEeQ0Rp2yWcuf5y9iWZbbf8S())WdG5Pbi7Hz1yGgnsAmnpXRdpR)74bdn8VgiHlI1csz(gZ4qdqsJP5jED6wY)V5NUm4my338C)6Ae7bi(8iCuHFEG2HYdGLYZyauLxlYZWzT308Kmd2yGgnIfcK3kLgzozWgd0Or42ILXzvBAEA1XCOfTqziAvCM)rleWK3RawHHacPayv08EO)drVRaZtdqkaw5rfVKgtZt8CCaZtdqkaK3BLIV6iqsJP5jEDCCcyY7vaRWqaHuaSkAEp0bLbBmqJgHBlwgNvTP5PvhZHw0cfZtgoAvCM)rleWK3RawHHacPayvSlc6)zWgd0Or42IL1Osq1NEWSAhxO3vgchn2aKtJblqfnIJZvgc55rbgjdn4qFifalPeWD1aH8bRdI2lgLmt1dt(GZGngOrJWTfldJanAwTJl0EXOKzQEyYhCgSXanAeUTy5NGunGCezWgd0Or42ILR3OmgOrJY3cWQJ5qlmeTQaundS4)QDCboRAtZtYwOmeLbBmqJgHBlwUEJYyGgnkFlaRoMdTGViZrRhEQwvaQMbw8F1oUOEdfrfgscAhkaQgfFrMJwp8ujPV1RHHj(myJbA0iCBXY1Bugd0Or5Bby1XCOfAidSQaundS4)QDCr9gkIkmKuZ82WifkQmVxbW2dgHK(wVggM4ZGngOrJWTflxVrzmqJgLVfGvhZHwiaR2XfEch5Hgk)YGngOrJWTflxVrzmqJgLVfGvhZHwaxeSbyyvcqgCgSXanAesdrleaRIM3VAhxO9IrPayv08EzrXIeynnpbrVR1BOiQWqsp(mRmHk6jc0dgfgF7alij9TEnmmXZXbAhAjl57qbATxmkfaRIM3llYX6r4wq6YGngOrJqAiYTfllEtSlAvg(mpPawHHaIf)xTJlmyfdlX(aHy(gwqYEu2GpKIIfjWAAEccWkmeqcAhsbqk(MG()3XZcyY7vaRWqaHBf5y9iYGngOrJqAiYTfl7GqtSlAvg(mpPawHHaIf)xTJlkkwKaRP5jiaRWqajODifaP4BcA9))UB6fWK3RawHHacPayvSlcp(lHIoDlratEVcyfgciCRihRhbe9meYZJcmsMP6HjlY4XNJtatEVcyfgciKcGvXUix(IJtpX8nSGK9OeiVvCCeZ3Wcs2JsdbWYXrmFdlizpk)BScIRaZtdqkqpVcfvaSKkIksaK0yAEIxhe9cyY7vaRWqaHuaSk2f5Y)F4H()UbmpnajiqpkheAesAmnpXRthetakZRGrbOcAO8dpR9IrPayv08Ezrowpc8WD1bXvTxmk)0dFr8kYbgfGkhAakAOctVus(GHyWkgwI9jd2yGgncPHi3wSCevmsHIQXaVIwTJlmyfdlX(KbBmqJgH0qKBlwUmC0GEcvSOzP4VAhxO9IrjZu9WKp4myJbA0iKgICBXYmYtcqBEL5BmJdnGv74c9AVyukawfnVx(G54mbOmVcgfGkOHYpDqCv7fJsbYlanJKpyiUQ9IrjZu9WKpyi67bqfmYBaIxfBmybQICSEeUWqippkWizObh6dPayjLaURgiKf5y9iCdV446bqfmYBaIxfBmybQICSEelzj))MFUeuqCCmeYZJcmsgAWH(qkawsjG7Qbc5dMJZvgchn2aKtJblqfnsxgSXanAesdrUTy5EywngOrZQDCHETxmkfaRIM3lFWCCMauMxbJcqf0q5NoiUQ9IrPa5fGMrYhmex1EXOKzQEyYhme99aOcg5naXRIngSavrowpcxyiKNhfyKm0Gd9HuaSKsa3vdeYICSEeUHxCC9aOcg5naXRIngSavrowpILSK)FZpx(kioogc55rbgjdn4qFifalPeWD1aH8bZX5kdHJgBaYPXGfOIgPZyGgncPHi3wS8NE4lIxjG7QbIv74IyJblqvKJ1JWL)qHJtV2lgLWv7Gk(28kRy20mf8ZlSsIZ8pYLGGYpooTxmkHR2bv8T5vwXSPzk4NxyLeN5Fe0lcck)0br7fJsbWQO59Yhmegc55rbgjZu9WKf5y9iGgk)YGngOrJqAiYTfllaK3BLk6TIwLHpZtkGvyiGyX)v74IIIfjWAAEccODifaP4Bc6)qbIaM8EfWkmeqifaRIDrU8DigSIHLyFGOx7fJsMP6HjlYX6ra9)FCCUQ9IrjZu9WKpyDzWgd0Orine52ILXzvBAEA1XCOfm0Gd9Hum0W3GgnRIZ8pAH2lgLWv7Gk(28kRy20mf8ZlSsIZ8pYLGGYp8SjaL5vWOaubrpdH88OaJKzQEyYICSEeU9)h0XgdwGQihRhbhhdH88OaJKzQEyYICSEeU91pxIngSavrowpciXgdwGQihRhb0))6hhN2lgLmt1dtwKJ1JaA8sheI5Bybj7rzd(CCXgdwGQihRhXswY)G(5YFOKbBmqJgH0qKBlwMHgCOpKcGLuc4UAGy1oUaNvTP5jjdn4qFifdn8nOrdetakZRGrbOYfO8ld2yGgncPHi3wSC8v4Rqrf5FdTAhxqmFdlizpkBWhIbRyyj2hiAVyucxTdQ4BZRSIztZuWpVWkjoZ)ixcck)GONhbKgVbdACKseWkhfV5yyijOzF6bdhNRmeoASbihIvipQ454eWK3RawHHacOdsxgSXanAesdrUTyzJ3GbnosjcyLZQm8zEsbScdbel(VAhx4kOzF6bdebm59kGvyiGqkawfnV3f8od2yGgncPHi3wSSayv08(v74cTxmkrdbWkuWuXiyqJg5dgIETxmkfaRIM3llkwKaRP5jootakZRGrbOcA8(NUmyJbA0iKgICBXYcGvrZ7xTJlyiC0ydqongSav0ii4SQnnpjzObh6dPyOHVbnAGWqippkWizObh6dPayjLaURgiKf5y9iCbdJx6yRHhmQ96nbOmVcgfGQLaLF6GO9IrPayv08EzrXIeynnpLbBmqJgH0qKBlwwaSs8km0QDCbdHJgBaYPXGfOIgbbNvTP5jjdn4qFifdn8nOrdegc55rbgjdn4qFifalPeWD1aHSihRhHlyy8shBn8GrTxVjaL5vWOauTKV(PdI2lgLcGvrZ7Lp4myJbA0iKgICBXY4SQnnpT6yo0cbWQO59QaObOIM3RqX4Q4m)JwycqzEfmkavq)n)WZ61EXOuaSkAEVSihRhbE81seWK3RWAcaPdpRNhbKXxHVcfvK)nKSihRhbEafDq0EXOuaSkAEV8bNbBmqJgH0qKBlwwaSs8km0QDCH2lgLOHayfkMNSsHRfnAKpyooxfaRIDrsdwXWsSpCC61EXOKzQEyYICSEeUafiAVyuYmvpm5dMJtV2lgLLHJg0tOIfnlfFzrowpcxWW4Lo2A4bJAVEtakZRGrbOAjF9theTxmkldhnONqflAwk(YhSoDqWzvBAEskawfnVxfanav08EfkgHiGjVxbScdbesbWQO59U8vgSXanAesdrUTy5HcOCqOz1oUqpX8nSGK9OSbFimeYZJcmsMP6HjlYX6ranu(XXPNH1kmKyrqqkIH1kmKc0oKlqrhhhdRvyiXIV0bXGvmSe7tgSXanAesdrUTyzSMpQCqOz1oUqpX8nSGK9OSbFimeYZJcmsMP6HjlYX6ranu(XXPNH1kmKyrqqkIH1kmKc0oKlqrhhhdRvyiXIV0bXGvmSe7tgSXanAesdrUTy54Z7voi0SAhxONy(gwqYEu2Gpegc55rbgjZu9WKf5y9iGgk)440ZWAfgsSiiifXWAfgsbAhYfOOJJJH1kmKyXx6GyWkgwI9jd2yGgncPHi3wSCaRQgvkuur(3qzWgd0Orine52ILXzvBAEA1XCOfcGvXUivpkbYB1Q4m)JwiGjVxbScdbesbWQyxe0FJBrpcv6DmbGk8v4m)Jwsq)05w0JqLETxmkfaReVcdPihyuaQCObifaJ9zjFxxgSB5zmqJgH0qKBlwoqzaSR2XfeZ3Wcs6FJvQHwdWXrmFdliPn4RgAnaeCw1MMNKTqX8KHJ44iMVHfKShLa5TcIR4SQnnpjfaRIDrQEucK3kooTxmkzMQhMSihRhHlgd0Orkawf7IK0Ae7bifODiiUIZQ208KSfkMNmCeeTxmkzMQhMSihRhHl0Ae7bifODiiAVyuYmvpm5dMJt7fJYYWrd6juXIMLIV8bdratEVcRjae0)KUlhNR4SQnnpjBHI5jdhbr7fJsMP6HjlYX6ranTgXEasbAhkd2yGgncPHi3wSSayvSlkd2yGgncPHi3wSC9gLXanAu(wawDmhAr08Ea26LbNbBmqJgHudzGfLHJg0tOIfnlf)v74cTxmkzMQhM8bNbBmqJgHudza3wSmoRAtZtRoMdTGvnyqGh8Q4m)Jw4Q2lgLAM3ggPqrL59ka2EWiuJbEfjFWqCv7fJsnZBdJuOOY8EfaBpyekRy2qYhCgSXanAesnKbCBXYmByKxP9IXvhZHwiaw5rf)QDCH2lgLcGvEuXllYX6r4YFOarV2lgLAM3ggPqrL59ka2EWiuJbEfjlYX6ra93LqHJt7fJsnZBdJuOOY8EfaBpyekRy2qYICSEeq)Dju0bXeGY8kyuaQGEH7(dIEgc55rbgjZu9WKf5y9iGgV440ZqippkWijhyuaQuAOHxwKJ1JaA8cIRAVyu(Ph(I4vKdmkavo0au0qfMEPK8bdHHWrJna5h8R2gD6YGngOrJqQHmGBlwwaSs8km0QDCHR4SQnnpjzvdge4bdrVExziKNhfyKm0Gd9HuaSKsa3vdeYhmhNR4SQnnpjzObh6dPyOHVbnA44CLHWrJna50yWcurJ0brpdHJgBaYPXGfOIgXXPNHqEEuGrYmvpmzrowpcOXloo9meYZJcmsYbgfGkLgA4Lf5y9iGgVG4Q2lgLF6HViEf5aJcqLdnafnuHPxkjFWqyiC0ydq(b)QTrNoD6440ZqippkWizObh6dPayjLaURgiKpyimeYZJcmsMP6HjlY4XhcdHJgBaYPXGfOIgPld2yGgncPgYaUTyzXBIDrRYWN5jfWkmeqS4)QDCrrXIeynnpbbyfgcibTdPaifFtq)3DHyWkgwI9bIECw1MMNKSQbdc8G540BcqzEfmkavU81piUQ9IrjZu9WKpyDCCmeYZJcmsMP6HjlY4XxxgSXanAesnKbCBXYoi0e7IwLHpZtkGvyiGyX)v74IIIfjWAAEccWkmeqcAhsbqk(MG()xsOaXGvmSe7de94SQnnpjzvdge4bZXP3eGY8kyuaQC5RFqCv7fJsMP6HjFW644yiKNhfyKmt1dtwKXJVoiUQ9Ir5NE4lIxroWOau5qdqrdvy6LsYhCgSXanAesnKbCBXYca59wPIEROvz4Z8Kcyfgciw8F1oUOOyrcSMMNGaScdbKG2HuaKIVjO)7UUvKJ1JaIbRyyj2hi6XzvBAEsYQgmiWdMJZeGY8kyuaQC5RFCCmeYZJcmsMP6HjlY4XxxgSXanAesnKbCBXYruXifkQgd8kA1oUWGvmSe7tgSXanAesnKbCBXYXxHVcfvK)n0QDCHEI5Bybj7rzd(CCeZ3WcskqERu9O(ZXrmFdliP)nwP6r9xhe9UYq4OXgGCAmybQOrCC6nbOmVcgfGkxWBOarpoRAtZtsw1GbbEWCCMauMxbJcqLlF9JJdNvTP5jzlugI0brpoRAtZtsgAWH(qkEsG)WG4kdH88OaJKHgCOpKcGLuc4UAGq(G54CfNvTP5jjdn4qFifpjWFyqCLHqEEuGrYmvpm5dwNoDq0ZqippkWizMQhMSihRhb0F9JJZeGY8kyuaQGgV)bHHqEEuGrYmvpm5dgIEgc55rbgj5aJcqLsdn8YICSEeUymqJgPayvSlssRrShGuG2H44CLHWrJna5h8R2gDCCXgdwGQihRhHl))PdIEEeqA8gmOXrkraRCu8MJHHKf5y9iG(7CCUYq4OXgGCiwH8OIxxgSXanAesnKbCBXYF6HViELaURgiwTJl0tmFdliP)nwPgAnahhX8nSGKcK3k1qRb44iMVHfK0g8vdTgGJt7fJsnZBdJuOOY8EfaBpyeQXaVIKf5y9iG(7sOWXP9IrPM5THrkuuzEVcGThmcLvmBizrowpcO)UekCCMauMxbJcqf049pimeYZJcmsMP6HjlY4Xxhe9meYZJcmsMP6HjlYX6ra9x)44yiKNhfyKmt1dtwKXJVooUyJblqvKJ1JWL))YGngOrJqQHmGBlwMrEsaAZRmFJzCObSAhxO3eGY8kyuaQGgV)brV2lgLF6HViEf5aJcqLdnafnuHPxkjFWCCUYq4OXgG8d(vBJooogchn2aKtJblqfnIJt7fJsnpcX7FcG8bdr7fJsnpcX7FcGSihRhHlb9Zn9FhpyOH)1ajCrSwqkZ3yghAasAmnpXRthe9UYq4OXgGCAmybQOrCCmeYZJcmsgAWH(qkawsjG7Qbc5dMJl2yWcuf5y9iCHHqEEuGrYqdo0hsbWskbCxnqilYX6r4M7YXfBmybQICSEelzj))MFUe0p30)D8GHg(xdKWfXAbPmFJzCObiPX08eVoDzWgd0Ori1qgWTfl3dZQXanAwTJl0BcqzEfmkavqJ3)GOx7fJYp9WxeVICGrbOYHgGIgQW0lLKpyooxziC0ydq(b)QTrhhhdHJgBaYPXGfOIgXXP9IrPMhH49pbq(GHO9IrPMhH49pbqwKJ1JWLV(5M(VJhm0W)AGeUiwliL5BmJdnajnMMN41PdIExziC0ydqongSav0ioogc55rbgjdn4qFifalPeWD1aH8bZXHZQ208KKHgCOpKINe4pmiXgdwGQihRhb0))MFUf0p30)D8GHg(xdKWfXAbPmFJzCObiPX08eVooUyJblqvKJ1JWfgc55rbgjdn4qFifalPeWD1aHSihRhHBUlhxSXGfOkYX6r4Yx)Ct)3XdgA4FnqcxeRfKY8nMXHgGKgtZt860LbBmqJgHudza3wSmdn4qFifalPeWD1aXQDCHECw1MMNKm0Gd9Hu8Ka)Hbj2yWcuf5y9iG()x)440EXOKzQEyYhSoi61EXOuZ82WifkQmVxbW2dgHAmWRiPaySpkCM)rq)1pooTxmk1mVnmsHIkZ7vaS9GrOSIzdjfaJ9rHZ8pc6V(PJJl2yWcuf5y9iC5)VmyJbA0iKAid42ILnEdg04iLiGvoR2XfzWgd0Ori1qgWTfllawjEfgA1oUGHWrJna50yWcurJGOhNvTP5jjdn4qFifpjWFyCCmeYZJcmsMP6HjlYX6r4Y)F6GycqzEfmkavqdLFqyiKNhfyKm0Gd9HuaSKsa3vdeYICSEeU8)xgSXanAesnKbCBXY4SQnnpT6yo0cta7(HQqITkoZ)OfeZ3Wcs2JY)gRWJVzjgd0Orkawf7IK0Ae7bifODi3CLy(gwqYEu(3yfE4UlXyGgnYaLbWkP1i2dqkq7qU9tg0seWK3RWAcaLbBmqJgHudza3wSSayL4vyOv74c96JngSavrowpcx(ohNETxmkldhnONqflAwk(YICSEeUGHXlDS1Wdg1E9MauMxbJcq1s(6NoiAVyuwgoAqpHkw0Su8LpyD6440BcqzEfmkavUHZQ208K0eWUFOkKy4H2lgLeZ3WcsjqERKf5y9iCJhbKXxHVcfvK)nKe0Spcvrowp4rqsOa9)G(XXzcqzEfmkavUHZQ208K0eWUFOkKy4H2lgLeZ3Wcs5FJvYICSEeUXJaY4RWxHIkY)gscA2hHQihRh8iijuG(Fq)0bHy(gwqYEu2Gpe96DLHqEEuGrYmvpm5dMJJHWrJna5h8R2giUYqippkWijhyuaQuAOHx(G1XXXq4OXgGCAmybQOr6440EXOKzQEyYICSEeq)nqCv7fJYYWrd6juXIMLIV8bRld2yGgncPgYaUTy5HcOCqOz1oUqV2lgLeZ3Wcs5FJvYhmhNEgwRWqIfbbPigwRWqkq7qUafDCCmSwHHel(shedwXWsSpzWgd0Ori1qgWTflJ18rLdcnR2Xf61EXOKy(gwqk)BSs(G540ZWAfgsSiiifXWAfgsbAhYfOOJJJH1kmKyXx6GyWkgwI9jd2yGgncPgYaUTy54Z7voi0SAhxOx7fJsI5BybP8VXk5dMJtpdRvyiXIGGuedRvyifODixGIooogwRWqIfFPdIbRyyj2NmyJbA0iKAid42ILdyv1OsHIkY)gkd2yGgncPgYaUTyzbWQyx0QDCbX8nSGK9O8VXkooI5BybjfiVvQHwdWXrmFdliPn4RgAnahN2lgLbSQAuPqrf5FdjFWqiMVHfKShL)nwXXPx7fJsMP6HjlYX6r4IXanAKbkdGvsRrShGuG2HGO9IrjZu9WKpyDzWgd0Ori1qgWTflhOma2myJbA0iKAid42ILR3OmgOrJY3cWQJ5qlIM3dWwVm4myJbA0iK8fzoA9Wt1cCw1MMNwDmhAHWIKcGupbPeWK3VkoZ)Of61EXOe0ouaunk(ImhTE4PswKJ1JaAmmEPJTgexjMVHfKShL)nwbXvI5BybjfiVvQHwdaXvI5BybjTbF1qRb440EXOe0ouaunk(ImhTE4PswKJ1JaAJbA0ifaRIDrsAnI9aKc0oee9cyY7vaRWqaHuaSk2fb9FooI5Bybj7r5FJvCCeZ3WcskqERudTgGJJy(gwqsBWxn0AaD644Cv7fJsq7qbq1O4lYC06HNk5dod2yGgncjFrMJwp8u52ILfaReVcdTAhxO3vCw1MMNKclskas9eKsatEphNE9AVyusmFdliLa5TswKJ1JWfmmEPJTgeTxmkjMVHfKsG8wjFW6440R9Irzz4Ob9eQyrZsXxwKJ1JWfmmEPJTgEWO2R3eGY8kyuaQwYx)0br7fJYYWrd6juXIMLIV8bRtNoi61EXOKy(gwqkbYBL8bZXrmFdliPa5Tsn0AaooI5BybjTbF1qRb0XXzcqzEfmkavqJ3)YGngOrJqYxK5O1dpvUTyzheAIDrRYWN5jfWkmeqS4)QDCrrXIeynnpbbyfgcibTdPaifFtq)3DH4Q2lgLF6HViEf5aJcqLdnafnuHPxkjFWzWgd0Ori5lYC06HNk3wSS4nXUOvz4Z8Kcyfgciw8F1oUOOyrcSMMNGaScdbKG2HuaKIVjO)7UqCv7fJYp9WxeVICGrbOYHgGIgQW0lLKp4myJbA0iK8fzoA9WtLBlwwaiV3kv0BfTkdFMNuaRWqaXI)R2XffflsG108eeGvyiGe0oKcGu8nb9F3fIETxmkzMQhMSihRhb0))XX5Q2lgLmt1dt(G1bXGvmSe7dex1EXO8tp8fXRihyuaQCObOOHkm9sj5dod2yGgncjFrMJwp8u52ILldhnONqflAwk(R2XfMauMxbJcqLl41pi61EXOe0ouaunk(ImhTE4PswKJ1JaAmmEPJTgEeehNRAVyucAhkaQgfFrMJwp8ujFW6YGngOrJqYxK5O1dpvUTyzg5jbOnVY8nMXHgWQDCHbRyyj2hiUQ9IrjZu9WKpyi61EXOe0ouaunk(ImhTE4PswKJ1JaAmmEPJTghNRAVyucAhkaQgfFrMJwp8ujFW6GyWkgwI9bIRAVyuYmvpm5dgI(yJblqvKJ1JWfgc55rbgjdn4qFifalPeWD1aHSihRhHB4fhxSXGfOkYX6rSKL8)B(5sqbXXXqippkWizObh6dPayjLaURgiKpyooxziC0ydqongSav0iDzWgd0Ori5lYC06HNk3wSCpmRgd0Oz1oUWGvmSe7dex1EXOKzQEyYhme9AVyucAhkaQgfFrMJwp8ujlYX6ranggV0XwJJZvTxmkbTdfavJIViZrRhEQKpyDq0hBmybQICSEeUWqippkWizObh6dPayjLaURgiKf5y9iCdV44IngSavrowpILSK)FZpx(kioogc55rbgjdn4qFifalPeWD1aH8bZX5kdHJgBaYPXGfOIgPld2yGgncjFrMJwp8u52ILJOIrkuung4v0QDCHbRyyj2NmyJbA0iK8fzoA9WtLBlw(tp8fXReWD1aXQDCH2lgLG2HcGQrXxK5O1dpvYICSEeqJHXlDS1GOp6rOsV(yJblqvKJ1Jap))NULWqippkWOd6OhHk96JngSavrowpc88)F4zgc55rbgjZu9WKf5y9i0Tegc55rbgDq0tmFdlizpkbYBfhhX8nSGKcK3k1qRb440EXOKzQEyYICSEeq))hhN2lgLWv7Gk(28kRy20mf8ZlSsIZ8pc6fbHx)GycqzEfmkavqdLF60LbBmqJgHKViZrRhEQCBXY4SQnnpT6yo0cgAWH(qkgA4BqJMvXz(hTq7fJs4QDqfFBELvmBAMc(5fwjXz(h5sqF)he9meYZJcmsMP6HjlYX6r42)FqhBmybQICSEeCCmeYZJcmsMP6HjlYX6r42x)Cj2yWcuf5y9iGeBmybQICSEeq))RFCCXgdwGQihRhXswY)G(5YFOWXP9IrjZu9WKf5y9iGgV0bHy(gwqYEu2GFgSXanAes(ImhTE4PYTflZqdo0hsbWskbCxnqSAhxGZQ208KKHgCOpKIHg(g0ObIEtakZRGrbOYfO8dcoRAtZtYwOmeXXzcqzEfmkavU81pDq0R9IrjODOaOAu8fzoA9WtLSihRhb00Ae7bifODioox1EXOe0ouaunk(ImhTE4Ps(G1LbBmqJgHKViZrRhEQCBXYXxHVcfvK)n0QDCbX8nSGK9OSbFigSIHLyFGGZQ208KuyrsbqQNGucyY7HONhbKgVbdACKseWkhfV5yyijOzF6bdhNRmeoASbihIvipQ454eWK3RawHHacOdsxgSXanAes(ImhTE4PYTflB8gmOXrkraRCwTJlYGngOrJqYxK5O1dpvUTyzbWkXRWqR2XfUYq4OXgGCAmybQOrqyiKNhfyKmt1dtwKXJpetakZRGrbOcA86xgSXanAes(ImhTE4PYTfllawjEfgA1oUGHWrJna50yWcurJGGZQ208KKHgCOpKIHg(g0ObIjaL5vWOaub9IV(bHHqEEuGrYqdo0hsbWskbCxnqilYX6r4cggV0Xwdpyu71BcqzEfmkavl5RF6YGngOrJqYxK5O1dpvUTy5HcOCqOz1oUqV2lgLeZ3Wcs5FJvYhmhNEgwRWqIfbbPigwRWqkq7qUafDCCmSwHHel(shedwXWsSpzWgd0Ori5lYC06HNk3wSmwZhvoi0SAhxOx7fJsI5BybP8VXk5dMJtpdRvyiXIGGuedRvyifODixGIooogwRWqIfFPdIbRyyj2hi61EXOe0ouaunk(ImhTE4PswKJ1JaAAnI9aKc0oehNRAVyucAhkaQgfFrMJwp8ujFW6YGngOrJqYxK5O1dpvUTy54Z7voi0SAhxOx7fJsI5BybP8VXk5dMJtpdRvyiXIGGuedRvyifODixGIooogwRWqIfFPdIbRyyj2hi61EXOe0ouaunk(ImhTE4PswKJ1JaAAnI9aKc0oehNRAVyucAhkaQgfFrMJwp8ujFW6YGngOrJqYxK5O1dpvUTy5awvnQuOOI8VHYGngOrJqYxK5O1dpvUTyzbWQyx0QDCbX8nSGK9O8VXkooI5BybjfiVvQHwdWXrmFdliPn4RgAnahN2lgLbSQAuPqrf5FdjFWq0EXOKy(gwqk)BSs(G540R9IrjZu9WKf5y9iCXyGgnYaLbWkP1i2dqkq7qq0EXOKzQEyYhSUmyJbA0iK8fzoA9WtLBlwoqzaSzWgd0Ori5lYC06HNk3wSC9gLXanAu(wawDmhAr08Ea26LbNbBmqJgHmAEpaB9wiawjEfgA1oUW16nuevyiPM5THrkuuzEVcGThmcj9TEnmmXNbBmqJgHmAEpaB9CBXYI3e7IwLHpZtkGvyiGyX)v74cEeq6GqtSlswKJ1Ja6ICSEezWgd0OriJM3dWwp3wSSdcnXUOm4myJbA0iKWfbBagwLaSWbHMyx0QaRWqavhxuuSibwtZtqawHHasq7qkasX3e0)dA1oUqV2lgLmt1dtwKJ1JaAOWX5Q2lgLmt1dt(G54mbOmVcgfGkx(6NoigSIHLyFYGngOrJqcxeSbyyvcGBlww8Myx0QaRWqavhxuuSibwtZtqawHHasq7qkasX3e0)dA1oUqV2lgLmt1dtwKJ1JaAOWX5Q2lgLmt1dt(G54mbOmVcgfGkx(6NoigSIHLyFYGngOrJqcxeSbyyvcGBlwwaiV3kv0BfTkWkmeq1XffflsG108eeGvyiGe0oKcGu8nb9F3D1oUqV2lgLmt1dtwKJ1JaAOWX5Q2lgLmt1dt(G54mbOmVcgfGkx(6NoigSIHLyFYGngOrJqcxeSbyyvcGBlwoIkgPqr1yGxrR2XfgSIHLyFYGngOrJqcxeSbyyvcGBlwMrEsaAZRmFJzCObSAhxO3eGY8kyuaQGgV)XXP9IrPMhH49pbq(GHO9IrPMhH49pbqwKJ1JWLGCxDqCv7fJsMP6HjFWzWgd0OriHlc2amSkbWTfl3dZQXanAwTJl0BcqzEfmkavqJ3)440EXOuZJq8(NaiFWq0EXOuZJq8(NailYX6r4YxURoiUQ9IrjZu9WKp4myJbA0iKWfbBagwLa42ILXzvBAEA1XCOfcdhPIOsXmvpSvXz(hTWvgc55rbgjZu9WKfz84NbBmqJgHeUiydWWQea3wSC8v4Rqrf5FdTAhxqmFdlizpkBWhIbRyyj2hi4SQnnpjfgosfrLIzQEyzWgd0OriHlc2amSkbWTflZSHrEL2lgxDmhAHayLhv8R2XfAVyukaw5rfVSihRhHlUle9AVyusmFdliLa5Ts(G540EXOKy(gwqk)BSs(G1bXeGY8kyuaQGgV)LbBmqJgHeUiydWWQea3wSSayL4vyOv74c9UAlLQgqsbOi7tpyucGvczzZhooTxmkzMQhMSihRhHl0Ae7bifODiooxHlcNuaSs8kmKoi61EXOKzQEyYhmhNjaL5vWOaubnE)dcX8nSGK9OSbFDzWgd0OriHlc2amSkbWTfllawjEfgA1oUqVR2sPQbKuakY(0dgLayLqw28HJt7fJsMP6HjlYX6r4cTgXEasbAhIJZv4IWjfaReVcdPdcW80aKcGvEuXlPX08epe9AVyukaw5rfV8bZXzcqzEfmkavqJ3)0br7fJsbWkpQ4LcGX(4Yxq0R9IrjX8nSGucK3k5dMJt7fJsI5BybP8VXk5dwxgSXanAes4IGnadRsaCBXYcGvIxHHwTJl07QTuQAajfGISp9GrjawjKLnF440EXOKzQEyYICSEeUqRrShGuG2H44CfUiCsbWkXRWq6GO9IrjX8nSGucK3kzrowpcOXlieZ3Wcs2JsG8wbXvG5PbifaR8OIxsJP5jEimeYZJcmsMP6HjlYX6ranELbBmqJgHeUiydWWQea3wS8qbuoi0SAhxOx7fJsI5BybP8VXk5dMJtpdRvyiXIGGuedRvyifODixGIooogwRWqIfFPdIbRyyj2hi4SQnnpjfgosfrLIzQEyzWgd0OriHlc2amSkbWTflJ18rLdcnR2Xf61EXOKy(gwqk)BSs(G540ZWAfgsSiiifXWAfgsbAhYfOOJJJH1kmKyXxCCAVyuYmvpm5dwhedwXWsSpqWzvBAEskmCKkIkfZu9WYGngOrJqcxeSbyyvcGBlwo(8ELdcnR2Xf61EXOKy(gwqk)BSs(G540ZWAfgsSiiifXWAfgsbAhYfOOJJJH1kmKyXxCCAVyuYmvpm5dwhedwXWsSpqWzvBAEskmCKkIkfZu9WYGngOrJqcxeSbyyvcGBlwoGvvJkfkQi)BOmyJbA0iKWfbBagwLa42ILfaRIDrR2Xf6TLsvdiPauK9PhmkbWkHSS5deTxmkzMQhMSihRhb00Ae7bifODiiWfHtgOmawDCC6D1wkvnGKcqr2NEWOeaReYYMpCCAVyuYmvpmzrowpcxO1i2dqkq7qCCUcxeoPayvSlshe9eZ3Wcs2JY)gR44iMVHfKuG8wPgAnahhX8nSGK2GVAO1aCCAVyugWQQrLcfvK)nK8bdr7fJsI5BybP8VXk5dMJtV2lgLmt1dtwKJ1JWfJbA0idugaRKwJypaPaTdbr7fJsMP6HjFW60XXP3wkvnGK8wGPhmkXBKLnFGoiiAVyusmFdliLa5TswKJ1JaAOaXvTxmk5TatpyuI3ilYX6raTXanAKbkdGvsRrShGuG2H0LbBmqJgHeUiydWWQea3wSCGYayZGngOrJqcxeSbyyvcGBlwUEJYyGgnkFlaRoMdTiAEpaB9YGZGngOrJqkalCqOj2fTkdFMNuaRWqaXI)R2XffflsG108eeGvyiGe0oKcGu8nb9)GGOx7fJsMP6HjlYX6ranuGOx7fJYYWrd6juXIMLIVSihRhb0qHJZvTxmkldhnONqflAwk(YhSooox1EXOKzQEyYhmhNjaL5vWOau5Yx)0brVRAVyu(Ph(I4vKdmkavo0au0qfMEPK8bZXzcqzEfmkavU81pDqmyfdlX(KbBmqJgHuaCBXYI3e7IwLHpZtkGvyiGyX)v74IIIfjWAAEccWkmeqcAhsbqk(MG(Fqq0R9IrjZu9WKf5y9iGgkq0R9Irzz4Ob9eQyrZsXxwKJ1JaAOWX5Q2lgLLHJg0tOIfnlfF5dwhhNRAVyuYmvpm5dMJZeGY8kyuaQC5RF6GO3vTxmk)0dFr8kYbgfGkhAakAOctVus(G54mbOmVcgfGkx(6NoigSIHLyFYGngOrJqkaUTyzbG8ERurVv0Qm8zEsbScdbel(VAhxuuSibwtZtqawHHasq7qkasX3e0)Dxi61EXOKzQEyYICSEeqdfi61EXOSmC0GEcvSOzP4llYX6ranu44Cv7fJYYWrd6juXIMLIV8bRJJZvTxmkzMQhM8bZXzcqzEfmkavU81pDq07Q2lgLF6HViEf5aJcqLdnafnuHPxkjFWCCMauMxbJcqLlF9thedwXWsSpzWgd0Orifa3wSCevmsHIQXaVIwTJlmyfdlX(KbBmqJgHuaCBXYLHJg0tOIfnlf)v74cTxmkzMQhM8bNbBmqJgHuaCBXYF6HViELaURgiwTJl0Rx7fJsI5BybPeiVvYICSEeq))hhN2lgLeZ3Wcs5FJvYICSEeq))NoimeYZJcmsMP6HjlYX6ra9x)GOx7fJs4QDqfFBELvmBAMc(5fwjXz(h5sqF)hhNR1BOiQWqs4QDqfFBELvmBAMc(5fwjPV1RHHjED6440EXOeUAhuX3MxzfZMMPGFEHvsCM)rqVii86hhhdH88OaJKzQEyYImE8HO3eGY8kyuaQGgV)XXHZQ208KSfkdr6YGngOrJqkaUTyzg5jbOnVY8nMXHgWQDCHEtakZRGrbOcA8(he9AVyu(Ph(I4vKdmkavo0au0qfMEPK8bZX5kdHJgBaYp4xTn644yiC0ydqongSav0iooCw1MMNKTqziIJt7fJsnpcX7FcG8bdr7fJsnpcX7FcGSihRhHlb9Zn96XB8OEdfrfgscxTdQ4BZRSIztZuWpVWkj9TEnmmXRZn9FhpyOH)1ajCrSwqkZ3yghAasAmnpXRtNoiUQ9IrjZu9WKpyi6JngSavrowpcxyiKNhfyKm0Gd9HuaSKsa3vdeYICSEeUHxCCXgdwGQihRhHlbfKB6XB8qV2lgLWv7Gk(28kRy20mf8ZlSsIZ8pc6))(PthhxSXGfOkYX6rSKL8)B(5sqbXXXqippkWizObh6dPayjLaURgiKpyooxziC0ydqongSav0iDzWgd0Orifa3wSCpmRgd0Oz1oUqVjaL5vWOaubnE)dIETxmk)0dFr8kYbgfGkhAakAOctVus(G54CLHWrJna5h8R2gDCCmeoASbiNgdwGkAehhoRAtZtYwOmeXXP9IrPMhH49pbq(GHO9IrPMhH49pbqwKJ1JWLV(5ME94nEuVHIOcdjHR2bv8T5vwXSPzk4NxyLK(wVggM415M(VJhm0W)AGeUiwliL5BmJdnajnMMN41Pthex1EXOKzQEyYhme9XgdwGQihRhHlmeYZJcmsgAWH(qkawsjG7Qbczrowpc3WloUyJblqvKJ1JWLVcYn94nEOx7fJs4QDqfFBELvmBAMc(5fwjXz(hb9)F)0PJJl2yWcuf5y9iwYs()n)C5RG44yiKNhfyKm0Gd9HuaSKsa3vdeYhmhNRmeoASbiNgdwGkAKUmyJbA0iKcGBlwgNvTP5PvhZHwWqdo0hsXqdFdA0SkoZ)OfmeoASbiNgdwGkAee9AVyucxTdQ4BZRSIztZuWpVWkjoZ)ixc67)GONHqEEuGrYmvpmzrowpc3()d6yJblqvKJ1JGJJHqEEuGrYmvpmzrowpc3(6NlXgdwGQihRhbKyJblqvKJ1Ja6)F9JJt7fJsMP6HjlYX6ranEPdI2lgLeZ3WcsjqERKf5y9iG()poUyJblqvKJ1Jyjl5Fq)C5pu0LbBmqJgHuaCBXY4SQnnpT6yo0cHHJuruPyMQh2Q4m)JwO3vgc55rbgjZu9WKfz84ZX5koRAtZtsgAWH(qkgA4BqJgimeoASbiNgdwGkAKUmyJbA0iKcGBlwMHgCOpKcGLuc4UAGy1oUaNvTP5jjdn4qFifdn8nOrdetakZRGrbOYLV(LbBmqJgHuaCBXYXxHVcfvK)n0QDCbX8nSGK9OSbFigSIHLyFGO9IrjC1oOIVnVYkMnntb)8cRK4m)JCjOV)dIEEeqA8gmOXrkraRCu8MJHHKGM9PhmCCUYq4OXgGCiwH8OIxheCw1MMNKcdhPIOsXmvpSmyJbA0iKcGBlw24nyqJJuIaw5SAhxKbBmqJgHuaCBXYcGvrZ7xTJl0EXOeneaRqbtfJGbnAKpyiAVyukawfnVxwuSibwtZtzWgd0Orifa3wSmZgg5vAVyC1XCOfcGvEuXVAhxO9IrPayLhv8YICSEeU4Uq0R9IrjX8nSGucK3k5dMJt7fJsI5BybP8VXk5dwhetakZRGrbOcA8(xgSXanAesbWTfllawjEfgA1oUGHWrJna50yWcurJGGZQ208KKHgCOpKIHg(g0ObcdH88OaJKHgCOpKcGLuc4UAGqwKJ1JWfmmEPJTgEWO2R3eGY8kyuaQwYx)0LbBmqJgHuaCBXYcGvrZ7xTJlaMNgGuaiV3kfF1rGKgtZt8qCfyEAasbWkpQ4L0yAEIhI2lgLcGvrZ7LfflsG108ee9AVyusmFdliL)nwjlYX6raT7cHy(gwqYEu(3yfeTxmkHR2bv8T5vwXSPzk4NxyLeN5FKlbbLFCCAVyucxTdQ4BZRSIztZuWpVWkjoZ)iOxeeu(bXeGY8kyuaQGgV)XXXJasJ3GbnosjcyLJI3CmmKSihRhb0FdhNXanAKgVbdACKseWkhfV5yyizpQOVXGfOdIRmeYZJcmsMP6HjlY4Xpd2yGgncPa42ILfaReVcdTAhxO9IrjAiawHI5jRu4ArJg5dMJt7fJYp9WxeVICGrbOYHgGIgQW0lLKpyooTxmkzMQhM8bdrV2lgLLHJg0tOIfnlfFzrowpcxWW4Lo2A4bJAVEtakZRGrbOAjF9theTxmkldhnONqflAwk(YhmhNRAVyuwgoAqpHkw0Su8LpyiUYqippkWildhnONqflAwk(YImE854CLHWrJnajoAayXV0XXzcqzEfmkavqJ3)GqmFdlizpkBWpd2yGgncPa42ILfaReVcdTAhxampnaPayLhv8sAmnpXdrV2lgLcGvEuXlFWCCMauMxbJcqf049pDq0EXOuaSYJkEPaySpU8fe9AVyusmFdliLa5Ts(G540EXOKy(gwqk)BSs(G1br7fJs4QDqfFBELvmBAMc(5fwjXz(h5sq41pi6ziKNhfyKmt1dtwKJ1Ja6))44CfNvTP5jjdn4qFifdn8nOrdegchn2aKtJblqfnsxgSXanAesbWTfllawjEfgA1oUqV2lgLWv7Gk(28kRy20mf8ZlSsIZ8pYLGWRFCCAVyucxTdQ4BZRSIztZuWpVWkjoZ)ixcck)GampnaPaqEVvk(QJajnMMN41br7fJsI5BybPeiVvYICSEeqJxqiMVHfKShLa5TcIRAVyuIgcGvOGPIrWGgnYhmexbMNgGuaSYJkEjnMMN4HWqippkWizMQhMSihRhb04fe9meYZJcmYp9WxeVsa3vdeYICSEeqJxCCUYq4OXgG8d(vBJUmyJbA0iKcGBlwEOakheAwTJl0R9IrjX8nSGu(3yL8bZXPNH1kmKyrqqkIH1kmKc0oKlqrhhhdRvyiXIV0bXGvmSe7deCw1MMNKcdhPIOsXmvpSmyJbA0iKcGBlwgR5JkheAwTJl0R9IrjX8nSGu(3yL8bdXvgchn2aKFWVAB440R9Ir5NE4lIxroWOau5qdqrdvy6LsYhmegchn2aKFWVAB0XXPNH1kmKyrqqkIH1kmKc0oKlqrhhhdRvyiXIV440EXOKzQEyYhSoigSIHLyFGGZQ208Kuy4ivevkMP6HLbBmqJgHuaCBXYXN3RCqOz1oUqV2lgLeZ3Wcs5FJvYhmexziC0ydq(b)QTHJtV2lgLF6HViEf5aJcqLdnafnuHPxkjFWqyiC0ydq(b)QTrhhNEgwRWqIfbbPigwRWqkq7qUafDCCmSwHHel(IJt7fJsMP6HjFW6GyWkgwI9bcoRAtZtsHHJuruPyMQhwgSXanAesbWTflhWQQrLcfvK)nugSXanAesbWTfllawf7IwTJliMVHfKShL)nwXXrmFdliPa5Tsn0AaooI5BybjTbF1qRb440EXOmGvvJkfkQi)Bi5dgI2lgLeZ3Wcs5FJvYhmhNETxmkzMQhMSihRhHlgd0OrgOmawjTgXEasbAhcI2lgLmt1dt(G1LbBmqJgHuaCBXYbkdGnd2yGgncPa42ILR3OmgOrJY3cWQJ5qlIM3dWwVnyd2Ba]] )


end