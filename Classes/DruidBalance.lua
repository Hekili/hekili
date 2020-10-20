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


    spec:RegisterPack( "Balance", 20201020, [[dGeqMdqiQqpsGu6sQqSjq8jOqkJIk5uuPwfvaVsaMLkIBrfK2fHFPQIHPQQJHQyzcONPc10Gc11uvPTbfIVrfuJtfsDoQaToQGyEOQCpvW(qv6GcKclekYdfizIqHeXfHcjsFekKuNekKQvkqntvizNQi9tOqIAOqHewQaPONkOPcf8vOqs2Rk9xIgSshM0IPupgLjdvxgzZc9zqA0qPtl51QOMnvDBkz3k(nKHdQJlqQwUupNIPdCDvz7QkFNkA8qrDEuvTEbI5Jk7x0xEUy4gIRa6EAG)d8pp)d8VGhh83Fd83BiGFy6gcRSZku6goQfDdXK61Hr3qyLFpsXVy4gAqVMr3qSaaSXH8Zpqla2NTGHS(XuwpVck0WAnc(XuwSFUH2VYdWOpx7BiUcO7Pb(pW)88pW)cECWF)nqm(gQpawuFddlRG6gITWXP5AFdXjd7gg0MlMuVomkxmkPFfEgCqBUyuMbq2uNBG)pj3a)h4)m4m4G2CdkS6aLmoKm4G2CDO5g0ahNWZne51oxmrQLidoOnxhAUbfwDGs45c0gkbKvmxMAitUauUm(zEsc0gkbmIm4G2CDO5g0KSqFeEUVzigzmAZFUFAxQTNm56QeK4KCHB6tAaABEnukxhkV5c30NWa028AOKBXn0xgG5IHBiCtWkGHvAaxmCpLNlgUH0O2Ec)IPBOYafAUHwi0eRMUHSUaux6nSPytgSQTNYfsUaTHsabOSijajXlkxEZLNaZfsUUY1(fJcMkRHjAYsRXKlV5(BUCC56yU2VyuWuznmXdoxoUCvdOvVeg5K6C5l3J)NR7CHKRclzyj25BiJFMNKaTHsaZ9uEUG7PbEXWnKg12t4xmDdvgOqZn08My10nK1fG6sVHnfBYGvT9uUqYfOnuciaLfjbijEr5YBU8eyUqY1vU2VyuWuznmrtwAnMC5n3FZLJlxhZ1(fJcMkRHjEW5YXLRAaT6LWiNuNlF5E8)CDNlKCvyjdlXoFdz8Z8KeOnucyUNYZfCp94lgUH0O2Ec)IPBOYafAUHga59AlJETPBiRla1LEdBk2KbRA7PCHKlqBOeqaklscqs8IYL3C5jWCHKRRCTFXOGPYAyIMS0Am5YBU)MlhxUoMR9lgfmvwdt8GZLJlx1aA1lHroPox(Y94)56oxi5QWsgwID(gY4N5jjqBOeWCpLNl4EkgFXWnKg12t4xmDdzDbOU0BOclzyj25BOYafAUHruZijkkhf8A6cUN(7fd3qAuBpHFX0nK1fG6sVHUYvnGw9syKtQZL3CDW)5YXLR9lgf2Eec3)maXdoxi5A)IrHThHW9pdq0KLwJjx(YnqmsUUZfsUoMR9lgfmvwdt8GVHkduO5gYipzaL6LQVGow0aUG7PyKlgUH0O2Ec)IPBiRla1LEdDLRAaT6LWiNuNlV56G)ZLJlx7xmkS9ieU)zaIhCUqY1(fJcBpcH7FgGOjlTgtU8L7XyKCDNlKCDmx7xmkyQSgM4bFdvgOqZnSgM2Jck0Cb3tD4lgUH0O2Ec)IPBic(gAiWnuzGcn3WpTl12t3Wp1)OBOJ5YqipoY5iyQSgMOjfN)B4N2YrTOBOr)ize1sMkRHDb3tp6lgUH0O2Ec)IPBiRla1LEdjMVGnKOgPo8NlKCvyjdlXoNlKC)0UuBpjm6hjJOwYuznSBOYafAUHXxZVefLK)n0fCp1bVy4gsJA7j8lMUHSUaux6n0(fJcdqBpQXfnzP1yYLVCXi5cjxx5A)IrbX8fSHKgKxBXdoxoUCTFXOGy(c2qs)B0w8GZ1DUqYvnGw9syKtQZL3CDW)3qLbk0Cdz6WiV0(fJ3q7xmkh1IUHgG2EuJFb3t55)fd3qAuBpHFX0nK1fG6sVHUY1XC1GqDbiHb0KEUgOsdqBJO15CUCC5A)IrbtL1WenzP1yYLVCjmtShGKGYIYLJlxhZfUPpHbOT51qPCDNlKCDLR9lgfmvwdt8GZLJlx1aA1lHroPoxEZ1b)NlKCjMVGnKOgPo8NR7BOYafAUHgG2MxdLUG7P8WZfd3qAuBpHFX0nK1fG6sVHUY1XC1GqDbiHb0KEUgOsdqBJO15CUCC5A)IrbtL1WenzP1yYLVCjmtShGKGYIYLJlxhZ9t7sT9KaUPpPbOT51qPCDNlKCbQNgGWa02JACbnQTNWZfsUUY1(fJcdqBpQXfp4C54YvnGw9syKtQZL3CDW)56oxi5A)IrHbOTh14cdqzNZLVCpoxi56kx7xmkiMVGnK0G8AlEW5YXLR9lgfeZxWgs6FJ2IhCUUZfsUmeYJJCocMkRHjAYsRXKlV56W3qLbk0CdnaTnVgkDb3t5jWlgUH0O2Ec)IPBiRla1LEdDLRJ5QbH6cqcdOj9CnqLgG2grRZ5C54Y1(fJcMkRHjAYsRXKlF5syMypajbLfLlhxUoMlCtFcdqBZRHs56oxi5A)IrbX8fSHKgKxBrtwAnMC5nxhoxi5smFbBirnsdYRDUqY1XCbQNgGWa02JACbnQTNWZfsUmeYJJCocMkRHjAYsRXKlV56W3qLbk0CdnaTnVgkDb3t554lgUH0O2Ec)IPBiRla1LEdDLR9lgfeZxWgs6FJ2IhCUCC56kxgwTHsMCpKBG5cj3Myy1gkjbLfLlF5(BUUZLJlxgwTHsMCpK7X56oxi5QWsgwIDoxi5(PDP2Esy0psgrTKPYAy3qLbk0CdhYP0cHMl4Ekpy8fd3qAuBpHFX0nK1fG6sVHUY1(fJcI5lydj9VrBXdoxoUCDLldR2qjtUhYnWCHKBtmSAdLKGYIYLVC)nx35YXLldR2qjtUhY94C54Y1(fJcMkRHjEW56oxi5QWsgwIDoxi5(PDP2Esy0psgrTKPYAy3qLbk0CdXQ(O0cHMl4Ekp)EXWnKg12t4xmDdzDbOU0BORCTFXOGy(c2qs)B0w8GZLJlxx5YWQnuYK7HCdmxi52edR2qjjOSOC5l3FZ1DUCC5YWQnuYK7HCpoxoUCTFXOGPYAyIhCUUZfsUkSKHLyNZfsUFAxQTNeg9JKrulzQSg2nuzGcn3W4Z7Lwi0Cb3t5bJCXWnuzGcn3qNA3fQLOOK8VHUH0O2Ec)IPl4Ekpo8fd3qAuBpHFX0nK1fG6sVHUYvdc1fGegqt65AGknaTnIwNZ5cjx7xmkyQSgMOjlTgtU8MlHzI9aKeuwuUqYfUPpHZwbyZ1DUCC56kxhZvdc1fGegqt65AGknaTnIwNZ5YXLR9lgfmvwdt0KLwJjx(YLWmXEascklkxoUCDmx4M(egG2XQPCDNlKCDLlX8fSHe1i9Vr7C54YLy(c2qcdYRTCimdYLJlxI5lydj0HF5qygKlhxU2Vyu4u7UqTefLK)nK4bNlKCTFXOGy(c2qs)B0w8GZLJlxx5A)IrbtL1WenzP1yYLVCvgOqJWzRaSccZe7bijOSOCHKR9lgfmvwdt8GZ1DUUZLJlxx5QbH6cqcC15uduP5nIwNZ5YBUbMlKCTFXOGy(c2qsdYRTOjlTgtU8M7V5cjxhZ1(fJcC15uduP5nIMS0Am5YBUkduOr4SvawbHzI9aKeuwuUUVHkduO5gAaAhRMUG7P8C0xmCdvgOqZn0zRaS3qAuBpHFX0fCpLhh8IHBinQTNWVy6gQmqHMBy)gPYafAK(YaUH(YaKJAr3WO69aS97cUGBiEtQLDn4uFXW9uEUy4gsJA7j8lMUHi4BOHa3qLbk0Cd)0UuBpDd)u)JUHUY1(fJcqzror9iXBsTSRbNArtwAnMC5nxOmCHLI5Cdi3)cEYfsUUYLy(c2qIAK2ia2C54YLy(c2qIAKgKx7C54YLy(c2qc)B0woeMb56oxoUCTFXOauwKtups8Mul7AWPw0KLwJjxEZvzGcncdq7y1KGWmXEascklk3aY9VGNCHKRRCjMVGnKOgP)nANlhxUeZxWgsyqETLdHzqUCC5smFbBiHo8lhcZGCDNR7C54Y1XCTFXOauwKtups8Mul7AWPw8GVHFAlh1IUHgnssas(mK0atE)fCpnWlgUH0O2Ec)IPBiRla1LEdDLRJ5(PDP2Esy0ijbi5Zqsdm595YXLRRCTFXOO1pAqpJm20ee(fnzP1yYLVCHYWfwkMZ1bYLrLpxx5QgqREjmYj15(tUh)px35cjx7xmkA9Jg0ZiJnnbHFXdox356oxoUCvdOvVeg5K6C5nxh8)nuzGcn3qdqBZRHsxW90JVy4gsJA7j8lMUHSUaux6n0XCXraHIRWG6JKgNABjXvlfkjaf7CnqZfsUoMRYafAekUcdQpsACQTLexTuOKOgz0xqXcYfsUUY1XCXraHIRWG6JKgNABjXsQxak25AGMlhxU4iGqXvyq9rsJtTTKyj1lAYsRXKlV5(BUUZLJlxCeqO4kmO(iPXP2wsC1sHscdqzNZLVCpoxi5IJacfxHb1hjno12sIRwkus0KLwJjx(Y94CHKlociuCfguFK04uBljUAPqjbOyNRb6nuzGcn3qfxHb1hjno126cUNIXxmCdPrT9e(ft3qLbk0CdTqOjwnDdzDbOU0BORCTFXOGPYAyIMS0Am5YBU)MlKCDLR9lgfT(rd6zKXMMGWVOjlTgtU8M7V5YXLRJ5A)IrrRF0GEgzSPji8lEW56oxoUCDmx7xmkyQSgM4bNlhxUQb0QxcJCsDU8L7X)Z1DUqY1vUoMR9lgfNRbVjCjzbJCsTfnajnudTccjEW5YXLRAaT6LWiNuNlF5E8)CDNlKCvyjdlXoFdbAdLaYkEdBk2KbRA7PCHKlqBOeqaklscqs8IYL3C5jWl4E6VxmCdPrT9e(ft3qLbk0CdnVjwnDdzDbOU0BORCTFXOGPYAyIMS0Am5YBU)MlKCDLR9lgfT(rd6zKXMMGWVOjlTgtU8M7V5YXLRJ5A)IrrRF0GEgzSPji8lEW56oxoUCDmx7xmkyQSgM4bNlhxUQb0QxcJCsDU8L7X)Z1DUqY1vUoMR9lgfNRbVjCjzbJCsTfnajnudTccjEW5YXLRAaT6LWiNuNlF5E8)CDNlKCvyjdlXoFdbAdLaYkEdBk2KbRA7PCHKlqBOeqaklscqs8IYL3C5jWl4Ekg5IHBinQTNWVy6gQmqHMBObqEV2YOxB6gY6cqDP3qx5A)IrbtL1WenzP1yYL3C)nxi56kx7xmkA9Jg0ZiJnnbHFrtwAnMC5n3FZLJlxhZ1(fJIw)Ob9mYyttq4x8GZ1DUCC56yU2VyuWuznmXdoxoUCvdOvVeg5K6C5l3J)NR7CHKRRCDmx7xmkoxdEt4sYcg5KAlAasAOgAfes8GZLJlx1aA1lHroPox(Y94)56oxi5QWsgwID(gc0gkbKv8g2uSjdw12t5cjxG2qjGauwKeGK4fLlV5Ydg5cUN6WxmCdPrT9e(ft3qwxaQl9gQWsgwID(gQmqHMBye1msIIYrbVMUG7Ph9fd3qAuBpHFX0nK1fG6sVH2VyuWuznmXd(gQmqHMByRF0GEgzSPji8Fb3tDWlgUH0O2Ec)IPBiRla1LEdDLRRCTFXOGy(c2qsdYRTOjlTgtU8Mlp)ZLJlx7xmkiMVGnK0)gTfnzP1yYL3C55FUUZfsUmeYJJCocMkRHjAYsRXKlV5E8)CDNlhxUmeYJJCocMkRHjAsX5)gQmqHMB45AWBcxAGRUaMl4Ekp)Vy4gsJA7j8lMUHSUaux6n0vU2VyuCUg8MWLKfmYj1w0aK0qn0kiK4bNlhxUoMld9rJoaXz(7sNCDNlhxUm0hn6aetbflqgvkxoUC)0UuBpjkJuruUCC5A)IrHThHW9pdq8GZfsU2Vyuy7riC)ZaenzP1yYLVCd8FUbKRRCX4CDGCzOb)vabCtSYqs1xqhlAacAuBpHNR7CHKRJ5A)IrbtL1Wep4CHKRRCRbqnmYRacxglOybYMS0Am5YxUmeYJJCocgA(qNjjaljnWvxaJOjlTgtUbKRdNlhxU1aOgg5vaHlJfuSaztwAnMC5l3admxoUCRbqnmYRacxglOybYMS0Am5EKC55O)NlF5gyG5YXLldH84iNJGHMp0zscWssdC1fWiEW5YXLRJ5YqF0OdqmfuSazuPCDFdvgOqZnKrEYak1lvFbDSObCb3t5HNlgUH0O2Ec)IPBiRla1LEdDLR9lgfNRbVjCjzbJCsTfnajnudTccjEW5YXLRJ5YqF0OdqCM)U0jx35YXLld9rJoaXuqXcKrLYLJl3pTl12tIYiveLlhxU2Vyuy7riC)Zaep4CHKR9lgf2Eec3)martwAnMC5l3J)NBa56kxmoxhixgAWFfqa3eRmKu9f0XIgGGg12t456oxi56yU2VyuWuznmXdoxi56k3AaudJ8kGWLXckwGSjlTgtU8LldH84iNJGHMp0zscWssdC1fWiAYsRXKBa56W5YXLBnaQHrEfq4Yybflq2KLwJjx(Y94aZLJl3AaudJ8kGWLXckwGSjlTgtUhjxEo6)5YxUhhyUCC5YqipoY5iyO5dDMKaSK0axDbmIhCUCC56yUm0hn6aetbflqgvkx33qLbk0CdRHP9OGcnxW9uEc8IHBinQTNWVy6gIGVHgcCdvgOqZn8t7sT90n8t9p6gYqF0OdqmfuSazuPCHKRRCTFXOaUlluJxQxQntNIjHFEJ2Ip1)OC5l3aX4)5cjxx5YqipoY5iyQSgMOjlTgtUbKlp)ZL3CRbqnmYRacxglOybYMS0Am5YXLldH84iNJGPYAyIMS0Am5gqUh)px(YTga1WiVciCzSGIfiBYsRXKlKCRbqnmYRacxglOybYMS0Am5YBU8C8)C54Y1(fJcMkRHjAYsRXKlV56W56oxi5A)IrbX8fSHKgKxBrtwAnMC5nxE(NlhxU1aOgg5vaHlJfuSaztwAnMCpsU8e4)C5lxE(nx33WpTLJAr3qgA(qNjjdn4fOqZfCpLNJVy4gsJA7j8lMUHi4BOHa3qLbk0Cd)0UuBpDd)u)JUHUY1XCziKhh5Cemvwdt0KIZFUCC56yUFAxQTNem08HotsgAWlqHMCHKld9rJoaXuqXcKrLY19n8tB5Ow0n0OFKmIAjtL1WUG7P8GXxmCdPrT9e(ft3qwxaQl9g(PDP2EsWqZh6mjzObVafAYfsUQb0QxcJCsDU8Llg))gQmqHMBidnFOZKeGLKg4QlG5cUNYZVxmCdPrT9e(ft3qwxaQl9gsmFbBirnsD4pxi5QWsgwIDoxi56kxCeqO4kmO(iPXP2wsC1sHscqXoxd0C54Y1XCzOpA0bigI1ipQXZ1DUqY9t7sT9KWOFKmIAjtL1WUHkduO5ggFn)suus(3qxW9uEWixmCdPrT9e(ft3qwxaQl9gYqF0OdqmfuSazuPCHK7N2LA7jbdnFOZKKHg8cuOjxi5QgqREjmYj15Y7HCX4)5cjxgc5XrohbdnFOZKeGLKg4QlGr0KLwJjx(YfkdxyPyoxhixgv(CDLRAaT6LWiNuN7p5E8)CDFdvgOqZn0a028AO0fCpLhh(IHBinQTNWVy6gY6cqDP3qx5A)IrbX8fSHK(3OT4bNlhxUUYLHvBOKj3d5gyUqYTjgwTHssqzr5YxU)MR7C54YLHvBOKj3d5ECUUZfsUkSKHLyNZfsUFAxQTNeg9JKrulzQSg2nuzGcn3WHCkTqO5cUNYZrFXWnKg12t4xmDdzDbOU0BORCTFXOGy(c2qs)B0w8GZfsUoMld9rJoaXz(7sNC54Y1vU2VyuCUg8MWLKfmYj1w0aK0qn0kiK4bNlKCzOpA0bioZFx6KR7C54Y1vUmSAdLm5Ei3aZfsUnXWQnuscklkx(Y93CDNlhxUmSAdLm5Ei3JZLJlx7xmkyQSgM4bNR7CHKRclzyj25CHK7N2LA7jHr)ize1sMkRHDdvgOqZneR6JsleAUG7P84GxmCdPrT9e(ft3qwxaQl9g6kx7xmkiMVGnK0)gTfp4CHKRJ5YqF0OdqCM)U0jxoUCDLR9lgfNRbVjCjzbJCsTfnajnudTccjEW5cjxg6JgDaIZ83Lo56oxoUCDLldR2qjtUhYnWCHKBtmSAdLKGYIYLVC)nx35YXLldR2qjtUhY94C54Y1(fJcMkRHjEW56oxi5QWsgwIDoxi5(PDP2Esy0psgrTKPYAy3qLbk0CdJpVxAHqZfCpnW)xmCdvgOqZn0P2DHAjkkj)BOBinQTNWVy6cUNgipxmCdPrT9e(ft3qwxaQl9gsmFbBirns)B0oxoUCjMVGnKWG8AlhcZGC54YLy(c2qcD4xoeMb5YXLR9lgfo1Ululrrj5FdjEW5cjx7xmkiMVGnK0)gTfp4C54Y1vU2VyuWuznmrtwAnMC5lxLbk0iC2kaRGWmXEascklkxi5A)IrbtL1Wep4CDFdvgOqZn0a0ownDb3tdmWlgUHkduO5g6Sva2BinQTNWVy6cUNg4XxmCdPrT9e(ft3qLbk0Cd73ivgOqJ0xgWn0xgGCul6ggvVhGTFxWfCdXPO(8GlgUNYZfd3qLbk0CdniV2sBsTUH0O2Ec)IPl4EAGxmCdPrT9e(ft3qe8n0qGBOYafAUHFAxQTNUHFQ)r3qdm59sG2qjGryaAhvVpxEZLNCHKRRCDmxG6PbimaT9OgxqJA7j8C54YfOEAacdG8ETL4DfbcAuBpHNR7C54Y1atEVeOnucyegG2r17ZL3Cd8g(PTCul6gwgPIOl4E6XxmCdPrT9e(ft3qe8n0qGBOYafAUHFAxQTNUHFQ)r3qdm59sG2qjGryaAhRMYL3C55g(PTCul6gwgjZt6hDb3tX4lgUH0O2Ec)IPBiRla1LEdDLRJ5YqF0OdqmfuSazuPC54Y1XCziKhh5Cem08HotsawsAGRUagXdox35cjx7xmkyQSgM4bFdvgOqZn0MAd1NRb6fCp93lgUH0O2Ec)IPBiRla1LEdTFXOGPYAyIh8nuzGcn3qyeOqZfCpfJCXWnuzGcn3WNHKfGSm3qAuBpHFX0fCp1HVy4gsJA7j8lMUHSUaux6n8t7sT9KOmsfr3qdOlg4Ekp3qLbk0Cd73ivgOqJ0xgWn0xgGCul6gQi6cUNE0xmCdPrT9e(ft3qwxaQl9g2VHIOgkjaLf5e1JeVj1YUgCQfuq)vWWe(n0a6IbUNYZnuzGcn3W(nsLbk0i9LbCd9Lbih1IUH4nPw21Gt9fCp1bVy4gsJA7j8lMUHSUaux6nSFdfrnusyREDyKefLQ3lbyRbQrqb9xbdt43qdOlg4Ekp3qLbk0Cd73ivgOqJ0xgWn0xgGCul6gAJuWfCpLN)xmCdPrT9e(ft3qwxaQl9g6PpYNlV5(7)BOYafAUH9BKkduOr6ld4g6ldqoQfDdnGl4Ekp8CXWnKg12t4xmDdrW3qdbUHkduO5g(PDP2E6g(P(hDdHB6t4Sva2B4N2YrTOBiCtFsNTcWEb3t5jWlgUH0O2Ec)IPBic(gAiWnuzGcn3WpTl12t3Wp1)OBiCtFcdq7y10n8tB5Ow0neUPpPbODSA6cUNYZXxmCdPrT9e(ft3qe8n0qGBOYafAUHFAxQTNUHFQ)r3q4M(egG2MxdLUHFAlh1IUHWn9jnaTnVgkDb3t5bJVy4gsJA7j8lMUHkduO5g2VrQmqHgPVmGBOVma5Ow0neUjyfWWknGl4cUHWnXqw2k4IH7P8CXWnuzGcn3qleAoxJmIARBinQTNWVy6cUNg4fd3qLbk0CdD2ka7nKg12t4xmDb3tp(IHBOYafAUHoBfG9gsJA7j8lMUG7Py8fd3qLbk0CdnaTJvt3qAuBpHFX0fCp93lgUH0O2Ec)IPBic(gAiWnuzGcn3WpTl12t3Wp1)OBOnYyYfsUrpc156kxx5glOybYMS0Am56qZnW)56o3FYLNa)NR7C5n3OhH6CDLRRCJfuSaztwAnMCDO5g4V56qZ1vU88pxhixG6PbiQHP9OGcncAuBpHNR7CDO56kxmoxhixgAWFfqa3eRmKu9f0XIgGGg12t456ox35(tU8C0)Z19n8tB5Ow0nKHMp0zsItg(h2fCb3qfrxmCpLNlgUH0O2Ec)IPBic(gAiWnuzGcn3WpTl12t3Wp1)OBORCTFXOauwKtups8Mul7AWPw0KLwJjx(YfkdxyPyo3aY9VGNC54Y1(fJcqzror9iXBsTSRbNArtwAnMC5lxLbk0imaTJvtccZe7bijOSOCdi3)cEYfsUUYLy(c2qIAK(3ODUCC5smFbBiHb51woeMb5YXLlX8fSHe6WVCimdY1DUUZfsU2VyuaklYjQhjEtQLDn4ulEW5cj3(nue1qjbOSiNOEK4nPw21GtTGc6VcgMWVHFAlh1IUH4nPwsNL3lJQ3lrX4fCpnWlgUH0O2Ec)IPBiRla1LEdTFXOWa0oQEVOPytgSQTNYfsUUY1atEVeOnucyegG2r17ZLVCpoxoUCDm3(nue1qjbOSiNOEK4nPw21GtTGc6VcgMWZ1DUqY1vUoMB)gkIAOKWZptB1iJEIa1avc1xwWgsqb9xbdt45YXLlOSOCpsUy8V5YBU2VyuyaAhvVx0KLwJj3aYnWCDFdvgOqZn0a0oQE)fCp94lgUH0O2Ec)IPBiRla1LEd73qrudLeGYICI6rI3KAzxdo1ckO)kyycpxi5AGjVxc0gkbmcdq7O695Y7HCpoxi56kxhZ1(fJcqzror9iXBsTSRbNAXdoxi5A)IrHbODu9ErtXMmyvBpLlhxUUY9t7sT9KaVj1s6S8Ezu9EjkgZfsUUY1(fJcdq7O69IMS0Am5YxUhNlhxUgyY7LaTHsaJWa0oQEFU8MBG5cjxG6PbimaY71wI3veiOrT9eEUqY1(fJcdq7O69IMS0Am5YxU)MR7CDNR7BOYafAUHgG2r17VG7Py8fd3qAuBpHFX0nebFdne4gQmqHMB4N2LA7PB4N6F0nunGw9syKtQZL3Cp6)56qZ1vU88pxhix7xmkaLf5e1JeVj1YUgCQfgGYoNR7CDO56kx7xmkmaTJQ3lAYsRXKRdK7X5(tUgyY7LyvdGY1DUo0CDLlociIVMFjkkj)BirtwAnMCDGC)nx35cjx7xmkmaTJQ3lEW3WpTLJAr3qdq7O69sNObiJQ3lrX4fCp93lgUH0O2Ec)IPBiRla1LEd)0UuBpjWBsTKolVxgvVxIIXCHK7N2LA7jHbODu9EPt0aKr17LOy8gQmqHMBObOT51qPl4Ekg5IHBinQTNWVy6gQmqHMBO5nXQPBiRla1LEdvyjdlXoNlKCjMVGnKOgPo8FdbAdLaYkEdBk2KbRA7PCHKlqBOeqaklscqs8IYL3C5bJZ1HMRbM8EjqBOeWKBa52KLwJ5cUN6WxmCdPrT9e(ft3qwxaQl9g6yUGIDUgO5cjxhZvzGcncfxHb1hjno12sIRwkusuJm6lOyb5YXLlociuCfguFK04uBljUAPqjHbOSZ5YxUhNlKCXraHIRWG6JKgNABjXvlfkjAYsRXKlF5E8nuzGcn3qfxHb1hjno126cUNE0xmCdPrT9e(ft3qLbk0CdTqOjwnDdzDbOU0BORCziKhh5Cemvwdt0KIZFUCC5AGjVxc0gkbmcdq7y1uU8L7X5YXLRRCjMVGnKOgPb51oxoUCjMVGnKOgPncGnxoUCjMVGnKOgP)nANlKCDmxG6PbimONxIIsawsgrnzacAuBpHNlhxU2Vyua3LfQXl1l1MPtXKWpVrBXN6FuU8Ei3a)9FUUZfsUUY1atEVeOnucyegG2XQPC5lxE(NRdKRRC5j3aYfOEAacGZAKwi0ye0O2Ecpx356oxi5QgqREjmYj15YBU)(pxhAU2VyuyaAhvVx0KLwJjxhixmsUUZfsUoMR9lgfNRbVjCjzbJCsTfnajnudTccjEW5cjxfwYWsSZ3qG2qjGSI3WMInzWQ2Ekxi5c0gkbeGYIKaKeVOC5nxx5YdgNBa56kxdm59sG2qjGryaAhRMY1bYLhXV56ox35(tUgyY7LaTHsatUbKBtwAnMl4EQdEXWnKg12t4xmDdzDbOU0BOclzyj25BOYafAUHruZijkkhf8A6cUNYZ)lgUH0O2Ec)IPBiRla1LEdTFXOGPYAyIh8nuzGcn3Ww)Ob9mYyttq4)cUNYdpxmCdPrT9e(ft3qwxaQl9g6kx7xmkmaTJQ3lEW5YXLRAaT6LWiNuNlV5(7)CDNlKCDmx7xmkmiVbums8GZfsUoMR9lgfmvwdt8GZfsUUYTga1WiVciCzSGIfiBYsRXKlF5YqipoY5iyO5dDMKaSK0axDbmIMS0Am5gqUoCUCC5wdGAyKxbeUmwqXcKnzP1yY9i5YZr)px(YnWaZLJlxgc5XrohbdnFOZKeGLKg4QlGr8GZLJlxhZLH(OrhGykOybYOs56(gQmqHMBiJ8KbuQxQ(c6yrd4cUNYtGxmCdPrT9e(ft3qwxaQl9gglOybYMS0Am5YxU88BUCC56kx7xmkG7Yc14L6LAZ0Pys4N3OT4t9pkx(YnWF)NlhxU2Vyua3LfQXl1l1MPtXKWpVrBXN6FuU8Ei3a)9FUUZfsU2VyuyaAhvVx8GZfsUmeYJJCocMkRHjAYsRXKlV5(7)BOYafAUH1W0EuqHMl4EkphFXWnKg12t4xmDdvgOqZn0aiVxBz0RnDdzDbOU0BytXMmyvBpLlKCbLfjbijEr5YBU88BUqY1atEVeOnucyegG2XQPC5lxmoxi5QWsgwIDoxi56kx7xmkyQSgMOjlTgtU8Mlp)ZLJlxhZ1(fJcMkRHjEW56(gY4N5jjqBOeWCpLNl4Ekpy8fd3qAuBpHFX0nebFdne4gQmqHMB4N2LA7PB4N6F0n0(fJc4USqnEPEP2mDkMe(5nAl(u)JYLVCd83)56qZvnGw9syKtQZfsUUYLHqECKZrWuznmrtwAnMCdixE(NlV5glOybYMS0Am5YXLldH84iNJGPYAyIMS0Am5gqUh)px(YnwqXcKnzP1yYfsUXckwGSjlTgtU8Mlph)pxoUCTFXOGPYAyIMS0Am5YBUoCUUZfsUeZxWgsuJuh(ZLJl3ybflq2KLwJj3JKlpb(px(YLNFVHFAlh1IUHm08HotsgAWlqHMl4Ekp)EXWnKg12t4xmDdzDbOU0B4N2LA7jbdnFOZKKHg8cuOjxi5QgqREjmYj15YxU)()gQmqHMBidnFOZKeGLKg4QlG5cUNYdg5IHBinQTNWVy6gY6cqDP3qI5lydjQrQd)5cjxfwYWsSZ5cjx7xmkG7Yc14L6LAZ0Pys4N3OT4t9pkx(YnWF)NlKCDLlociuCfguFK04uBljUAPqjbOyNRbAUCC56yUm0hn6aedXAKh145YXLRbM8EjqBOeWKlV5gyUUVHkduO5ggFn)suus(3qxW9uEC4lgUH0O2Ec)IPBiRla1LEdTFXOaneaRrctnJGbfAep4CHKRRCTFXOWa0oQEVOPytgSQTNYLJlx1aA1lHroPoxEZ1b)NR7BOYafAUHgG2r17VG7P8C0xmCdPrT9e(ft3qwxaQl9gYqF0OdqmfuSazuPCHK7N2LA7jbdnFOZKKHg8cuOjxi5YqipoY5iyO5dDMKaSK0axDbmIMS0Am5YxUqz4clfZ56a5YOYNRRCvdOvVeg5K6C)j3F)NR7CHKR9lgfgG2r17fnfBYGvT90nuzGcn3qdq7O69xW9uECWlgUH0O2Ec)IPBiRla1LEdzOpA0biMckwGmQuUqY9t7sT9KGHMp0zsYqdEbk0KlKCziKhh5Cem08HotsawsAGRUagrtwAnMC5lxOmCHLI5CDGCzu5Z1vUQb0QxcJCsDU)K7X)Z1DUqY1(fJcdq7O69Ih8nuzGcn3qdqBZRHsxW90a)FXWnKg12t4xmDdzDbOU0BO9lgfOHaynsMN0w(vMcnIhCUCC56yUgG2XQjHclzyj25C54Y1vU2VyuWuznmrtwAnMC5l3FZfsU2VyuWuznmXdoxoUCDLR9lgfT(rd6zKXMMGWVOjlTgtU8LlugUWsXCUoqUmQ856kx1aA1lHroPo3FY94)56oxi5A)IrrRF0GEgzSPji8lEW56ox35cj3pTl12tcdq7O69sNObiJQ3lrXyUqY1atEVeOnucyegG2r17ZLVCp(gQmqHMBObOT51qPl4EAG8CXWnKg12t4xmDdzDbOU0BORCjMVGnKOgPo8NlKCziKhh5Cemvwdt0KLwJjxEZ93)5YXLRRCzy1gkzY9qUbMlKCBIHvBOKeuwuU8L7V56oxoUCzy1gkzY9qUhNR7CHKRclzyj25BOYafAUHd5uAHqZfCpnWaVy4gsJA7j8lMUHSUaux6n0vUeZxWgsuJuh(ZfsUmeYJJCocMkRHjAYsRXKlV5(7)C54Y1vUmSAdLm5Ei3aZfsUnXWQnuscklkx(Y93CDNlhxUmSAdLm5Ei3JZ1DUqYvHLmSe78nuzGcn3qSQpkTqO5cUNg4XxmCdPrT9e(ft3qwxaQl9g6kxI5lydjQrQd)5cjxgc5XrohbtL1WenzP1yYL3C)9FUCC56kxgwTHsMCpKBG5cj3Myy1gkjbLfLlF5(BUUZLJlxgwTHsMCpK7X56oxi5QWsgwID(gQmqHMBy859sleAUG7PbIXxmCdvgOqZn0P2DHAjkkj)BOBinQTNWVy6cUNg4VxmCdPrT9e(ft3qe8n0qGBOYafAUHFAxQTNUHFQ)r3qdm59sG2qjGryaAhRMYL3Cp6Cdi3OhH6CDLRLAauZV8t9pk3FYnW)56o3aYn6rOoxx5A)IrHbOT51qjjzbJCsTfnaHbOSZ5(tUyCUUVHFAlh1IUHgG2XQjznsdYR9fCpnqmYfd3qAuBpHFX0nK1fG6sVHeZxWgs4FJ2YHWmixoUCjMVGnKqh(LdHzqUqY9t7sT9KOmsMN0pkxoUCjMVGnKOgPb51oxi56yUFAxQTNegG2XQjznsdYRDUCC5A)IrbtL1WenzP1yYLVCvgOqJWa0ownjimtShGKGYIYfsUoM7N2LA7jrzKmpPFuUqY1(fJcMkRHjAYsRXKlF5syMypajbLfLlKCTFXOGPYAyIhCUCC5A)IrrRF0GEgzSPji8lEW5cjxdm59sSQbq5YBU)fyKC54Y1XC)0UuBpjkJK5j9JYfsU2VyuWuznmrtwAnMC5nxcZe7bijOSOBOYafAUHoBfG9cUNgOdFXWnuzGcn3qdq7y10nKg12t4xmDb3td8OVy4gsJA7j8lMUHkduO5g2VrQmqHgPVmGBOVma5Ow0nmQEpaB)UGl4ggvVhGTFxmCpLNlgUH0O2Ec)IPBiRla1LEdDm3(nue1qjHT61HrsuuQEVeGTgOgbf0FfmmHFdvgOqZn0a028AO0fCpnWlgUH0O2Ec)IPBOYafAUHM3eRMUHSUaux6nehbewi0eRMenzP1yYL3CBYsRXCdz8Z8KeOnucyUNYZfCp94lgUHkduO5gAHqtSA6gsJA7j8lMUGl4gAaxmCpLNlgUH0O2Ec)IPBOYafAUHkUcdQpsACQT1nK1fG6sVHoMlociuCfguFK04uBljUAPqjbOyNRbAUqY1XCvgOqJqXvyq9rsJtTTK4QLcLe1iJ(ckwqUqY1vUoMlociuCfguFK04uBljws9cqXoxd0C54YfhbekUcdQpsACQTLelPErtwAnMC5n3FZ1DUCC5IJacfxHb1hjno12sIRwkusyak7CU8L7X5cjxCeqO4kmO(iPXP2wsC1sHsIMS0Am5YxUhNlKCXraHIRWG6JKgNABjXvlfkjaf7CnqVHm(zEsc0gkbm3t55cUNg4fd3qAuBpHFX0nuzGcn3qleAIvt3qwxaQl9g6kx7xmkyQSgMOjlTgtU8M7V5cjxx5A)IrrRF0GEgzSPji8lAYsRXKlV5(BUCC56yU2Vyu06hnONrgBAcc)IhCUUZLJlxhZ1(fJcMkRHjEW5YXLRAaT6LWiNuNlF5E8)CDNlKCDLRJ5A)IrX5AWBcxswWiNuBrdqsd1qRGqIhCUCC5QgqREjmYj15YxUh)px35cjxfwYWsSZ3qg)mpjbAdLaM7P8Cb3tp(IHBinQTNWVy6gQmqHMBO5nXQPBiRla1LEdBk2KbRA7PCHKlqBOeqaklscqs8IYL3C5jWCHKRRCTFXOGPYAyIMS0Am5YBU)MlKCDLR9lgfT(rd6zKXMMGWVOjlTgtU8M7V5YXLRJ5A)IrrRF0GEgzSPji8lEW56oxoUCDmx7xmkyQSgM4bNlhxUQb0QxcJCsDU8L7X)Z1DUqY1vUoMR9lgfNRbVjCjzbJCsTfnajnudTccjEW5YXLRAaT6LWiNuNlF5E8)CDNlKCvyjdlXoFdz8Z8KeOnucyUNYZfCpfJVy4gsJA7j8lMUHkduO5gAaK3RTm61MUHSUaux6nSPytgSQTNYfsUaTHsabOSijajXlkxEZLhmsUqY1vU2VyuWuznmrtwAnMC5n3FZfsUUY1(fJIw)Ob9mYyttq4x0KLwJjxEZ93C54Y1XCTFXOO1pAqpJm20ee(fp4CDNlhxUoMR9lgfmvwdt8GZLJlx1aA1lHroPox(Y94)56oxi56kxhZ1(fJIZ1G3eUKSGroP2IgGKgQHwbHep4C54YvnGw9syKtQZLVCp(FUUZfsUkSKHLyNVHm(zEsc0gkbm3t55cUN(7fd3qAuBpHFX0nK1fG6sVHkSKHLyNVHkduO5ggrnJKOOCuWRPl4Ekg5IHBinQTNWVy6gY6cqDP3q7xmkyQSgM4bFdvgOqZnS1pAqpJm20ee(VG7Po8fd3qAuBpHFX0nK1fG6sVHUY1vU2VyuqmFbBiPb51w0KLwJjxEZLN)5YXLR9lgfeZxWgs6FJ2IMS0Am5YBU88px35cjxgc5XrohbtL1WenzP1yYL3Cp(FUqY1vU2Vyua3LfQXl1l1MPtXKWpVrBXN6FuU8LBGy8)C54Y1XC73qrudLeWDzHA8s9sTz6umj8ZB0wqb9xbdt456ox35YXLR9lgfWDzHA8s9sTz6umj8ZB0w8P(hLlVhYnqh(FUCC5YqipoY5iyQSgMOjfN)CHKRRCvdOvVeg5K6C5nxh8FUCC5(PDP2EsugPIOCDFdvgOqZn8Cn4nHlnWvxaZfCp9OVy4gsJA7j8lMUHSUaux6n0vUQb0QxcJCsDU8MRd(pxi56kx7xmkoxdEt4sYcg5KAlAasAOgAfes8GZLJlxhZLH(OrhG4m)DPtUUZLJlxg6JgDaIPGIfiJkLlhxUFAxQTNeLrQikxoUCTFXOW2Jq4(NbiEW5cjx7xmkS9ieU)zaIMS0Am5YxUb(p3aY1vUUY1bZ1bYTFdfrnusa3LfQXl1l1MPtXKWpVrBbf0FfmmHNR7Cdixx5IX56a5Yqd(Rac4MyLHKQVGow0ae0O2Ecpx356ox35cjxhZ1(fJcMkRHjEW5cjxx5glOybYMS0Am5YxUmeYJJCocgA(qNjjaljnWvxaJOjlTgtUbKRdNlhxUXckwGSjlTgtU8LBGbMBa56kxhmxhixx5A)IrbCxwOgVuVuBMoftc)8gTfFQ)r5YBU88)FUUZ1DUCC5glOybYMS0Am5EKC55O)NlF5gyG5YXLldH84iNJGHMp0zscWssdC1fWiEW5YXLRJ5YqF0OdqmfuSazuPCDFdvgOqZnKrEYak1lvFbDSObCb3tDWlgUH0O2Ec)IPBiRla1LEdDLRAaT6LWiNuNlV56G)ZfsUUY1(fJIZ1G3eUKSGroP2IgGKgQHwbHep4C54Y1XCzOpA0bioZFx6KR7C54YLH(OrhGykOybYOs5YXL7N2LA7jrzKkIYLJlx7xmkS9ieU)zaIhCUqY1(fJcBpcH7FgGOjlTgtU8L7X)ZnGCDLRRCDWCDGC73qrudLeWDzHA8s9sTz6umj8ZB0wqb9xbdt456o3aY1vUyCUoqUm0G)kGaUjwziP6lOJfnabnQTNWZ1DUUZ1DUqY1XCTFXOGPYAyIhCUqY1vUXckwGSjlTgtU8LldH84iNJGHMp0zscWssdC1fWiAYsRXKBa56W5YXLBSGIfiBYsRXKlF5ECG5gqUUY1bZ1bY1vU2Vyua3LfQXl1l1MPtXKWpVrBXN6FuU8Mlp))NR7CDNlhxUXckwGSjlTgtUhjxEo6)5YxUhhyUCC5YqipoY5iyO5dDMKaSK0axDbmIhCUCC56yUm0hn6aetbflqgvkx33qLbk0CdRHP9OGcnxW9uE(FXWnKg12t4xmDdrW3qdbUHkduO5g(PDP2E6g(P(hDdzOpA0biMckwGmQuUqY1vU2Vyua3LfQXl1l1MPtXKWpVrBXN6FuU8LBGy8)CHKRRCziKhh5Cemvwdt0KLwJj3aYLN)5YBUXckwGSjlTgtUCC5YqipoY5iyQSgMOjlTgtUbK7X)ZLVCJfuSaztwAnMCHKBSGIfiBYsRXKlV5YZX)ZLJlx7xmkyQSgMOjlTgtU8MRdNR7CHKR9lgfeZxWgsAqETfnzP1yYL3C55FUCC5glOybYMS0Am5EKC5jW)5YxU88BUUVHFAlh1IUHm08HotsgAWlqHMl4Ekp8CXWnKg12t4xmDdrW3qdbUHkduO5g(PDP2E6g(P(hDdDLRJ5YqipoY5iyQSgMOjfN)C54Y1XC)0UuBpjyO5dDMKm0GxGcn5cjxg6JgDaIPGIfiJkLR7B4N2YrTOBOr)ize1sMkRHDb3t5jWlgUH0O2Ec)IPBiRla1LEd)0UuBpjyO5dDMKm0GxGcn5cjx1aA1lHroPox(Y94)3qLbk0CdzO5dDMKaSK0axDbmxW9uEo(IHBinQTNWVy6gY6cqDP3qI5lydjQrQd)5cjxfwYWsSZ5cjx7xmkG7Yc14L6LAZ0Pys4N3OT4t9pkx(Ynqm(FUqY1vU4iGqXvyq9rsJtTTK4QLcLeGIDUgO5YXLRJ5YqF0OdqmeRrEuJNR7CHK7N2LA7jHr)ize1sMkRHDdvgOqZnm(A(LOOK8VHUG7P8GXxmCdPrT9e(ft3qwxaQl9gA)IrbAiawJeMAgbdk0iEW5cjx7xmkmaTJQ3lAk2KbRA7PBOYafAUHgG2r17VG7P887fd3qAuBpHFX0nK1fG6sVH2VyuyaA7rnUOjlTgtU8L7V5cjxx5A)IrbX8fSHKgKxBrtwAnMC5n3FZLJlx7xmkiMVGnK0)gTfnzP1yYL3C)nx35cjx1aA1lHroPoxEZ1b)FdvgOqZnKPdJ8s7xmEdTFXOCul6gAaA7rn(fCpLhmYfd3qAuBpHFX0nK1fG6sVHm0hn6aetbflqgvkxi5(PDP2EsWqZh6mjzObVafAYfsUmeYJJCocgA(qNjjaljnWvxaJOjlTgtU8LlugUWsXCUoqUmQ856kx1aA1lHroPo3FY94)56(gQmqHMBObOT51qPl4Ekpo8fd3qAuBpHFX0nK1fG6sVHa1tdqyaK3RTeVRiqqJA7j8CHKRJ5cupnaHbOTh14cAuBpHNlKCTFXOWa0oQEVOPytgSQTNYfsUUY1(fJcI5lydj9VrBrtwAnMC5nxmsUqYLy(c2qIAK(3ODUqY1(fJc4USqnEPEP2mDkMe(5nAl(u)JYLVCd83)5YXLR9lgfWDzHA8s9sTz6umj8ZB0w8P(hLlVhYnWF)NlKCvdOvVeg5K6C5nxh8FUCC5IJacfxHb1hjno12sIRwkus0KLwJjxEZ9OZLJlxLbk0iuCfguFK04uBljUAPqjrnYOVGIfKR7CHKRJ5YqipoY5iyQSgMOjfN)BOYafAUHgG2r17VG7P8C0xmCdPrT9e(ft3qwxaQl9gA)IrbAiawJK5jTLFLPqJ4bNlhxU2VyuCUg8MWLKfmYj1w0aK0qn0kiK4bNlhxU2VyuWuznmXdoxi56kx7xmkA9Jg0ZiJnnbHFrtwAnMC5lxOmCHLI5CDGCzu5Z1vUQb0QxcJCsDU)K7X)Z1DUqY1(fJIw)Ob9mYyttq4x8GZLJlxhZ1(fJIw)Ob9mYyttq4x8GZfsUoMldH84iNJO1pAqpJm20ee(fnP48NlhxUoMld9rJoaXhnaS8356oxoUCvdOvVeg5K6C5nxh8FUqYLy(c2qIAK6W)nuzGcn3qdqBZRHsxW9uECWlgUH0O2Ec)IPBiRla1LEdbQNgGWa02JACbnQTNWZfsUUY1(fJcdqBpQXfp4C54YvnGw9syKtQZL3CDW)56oxi5A)IrHbOTh14cdqzNZLVCpoxi56kx7xmkiMVGnK0G8AlEW5YXLR9lgfeZxWgs6FJ2IhCUUZfsU2Vyua3LfQXl1l1MPtXKWpVrBXN6FuU8LBGo8)CHKRRCziKhh5Cemvwdt0KLwJjxEZLN)5YXLRJ5(PDP2EsWqZh6mjzObVafAYfsUm0hn6aetbflqgvkx33qLbk0CdnaTnVgkDb3td8)fd3qAuBpHFX0nK1fG6sVHUY1(fJc4USqnEPEP2mDkMe(5nAl(u)JYLVCd0H)NlhxU2Vyua3LfQXl1l1MPtXKWpVrBXN6FuU8LBG)(pxi5cupnaHbqEV2s8UIabnQTNWZ1DUqY1(fJcI5lydjniV2IMS0Am5YBUoCUqYLy(c2qIAKgKx7CHKRJ5A)IrbAiawJeMAgbdk0iEW5cjxhZfOEAacdqBpQXf0O2Ecpxi5YqipoY5iyQSgMOjlTgtU8MRdNlKCDLldH84iNJ4Cn4nHlnWvxaJOjlTgtU8MRdNlhxUoMld9rJoaXz(7sNCDFdvgOqZn0a028AO0fCpnqEUy4gsJA7j8lMUHSUaux6n0vU2VyuqmFbBiP)nAlEW5YXLRRCzy1gkzY9qUbMlKCBIHvBOKeuwuU8L7V56oxoUCzy1gkzY9qUhNR7CHKRclzyj25CHK7N2LA7jHr)ize1sMkRHDdvgOqZnCiNsleAUG7Pbg4fd3qAuBpHFX0nK1fG6sVHUY1(fJcI5lydj9VrBXdoxi56yUm0hn6aeN5VlDYLJlxx5A)IrX5AWBcxswWiNuBrdqsd1qRGqIhCUqYLH(OrhG4m)DPtUUZLJlxx5YWQnuYK7HCdmxi52edR2qjjOSOC5l3FZ1DUCC5YWQnuYK7HCpoxoUCTFXOGPYAyIhCUUZfsUkSKHLyNZfsUFAxQTNeg9JKrulzQSg2nuzGcn3qSQpkTqO5cUNg4XxmCdPrT9e(ft3qwxaQl9g6kx7xmkiMVGnK0)gTfp4CHKRJ5YqF0OdqCM)U0jxoUCDLR9lgfNRbVjCjzbJCsTfnajnudTccjEW5cjxg6JgDaIZ83Lo56oxoUCDLldR2qjtUhYnWCHKBtmSAdLKGYIYLVC)nx35YXLldR2qjtUhY94C54Y1(fJcMkRHjEW56oxi5QWsgwIDoxi5(PDP2Esy0psgrTKPYAy3qLbk0CdJpVxAHqZfCpnqm(IHBOYafAUHo1Ululrrj5FdDdPrT9e(ftxW90a)9IHBinQTNWVy6gY6cqDP3qI5lydjQr6FJ25YXLlX8fSHegKxB5qygKlhxUeZxWgsOd)YHWmixoUCTFXOWP2DHAjkkj)BiXdoxi5A)IrbX8fSHK(3OT4bNlhxUUY1(fJcMkRHjAYsRXKlF5QmqHgHZwbyfeMj2dqsqzr5cjx7xmkyQSgM4bNR7BOYafAUHgG2XQPl4EAGyKlgUHkduO5g6Sva2BinQTNWVy6cUNgOdFXWnKg12t4xmDdvgOqZnSFJuzGcnsFza3qFzaYrTOByu9Ea2(DbxWn0gPGlgUNYZfd3qAuBpHFX0nK1fG6sVH2VyuWuznmXd(gQmqHMByRF0GEgzSPji8Fb3td8IHBinQTNWVy6gIGVHgcCdvgOqZn8t7sT90n8t9p6g6yU2VyuyREDyKefLQ3lbyRbQrok41K4bNlKCDmx7xmkSvVomsIIs17LaS1a1i1MPdjEW3WpTLJAr3qwxGbbEWxW90JVy4gsJA7j8lMUHSUaux6n0vU2VyuyREDyKefLQ3lbyRbQrok41KOjlTgtU8Mlgl(nxoUCTFXOWw96WijkkvVxcWwduJuBMoKOjlTgtU8Mlgl(nx35cjx1aA1lHroPoxEpKRd(pxi56kxgc5XrohbtL1WenzP1yYL3CD4C54Y1vUmeYJJCocYcg5KAPnAWfnzP1yYL3CD4CHKRJ5A)IrX5AWBcxswWiNuBrdqsd1qRGqIhCUqYLH(OrhG4m)DPtUUZ19nuzGcn3qMomYlTFX4n0(fJYrTOBObOTh14xW9um(IHBinQTNWVy6gY6cqDP3qhZ9t7sT9KG1fyqGhCUqY1vUUY1XCziKhh5Cem08HotsawsAGRUagXdoxoUCDm3pTl12tcgA(qNjjdn4fOqtUCC56yUm0hn6aetbflqgvkx35cjxx5YqF0OdqmfuSazuPC54Y1vUmeYJJCocMkRHjAYsRXKlV56W5YXLRRCziKhh5CeKfmYj1sB0GlAYsRXKlV56W5cjxhZ1(fJIZ1G3eUKSGroP2IgGKgQHwbHep4CHKld9rJoaXz(7sNCDNR7CDNR7C54Y1vUmeYJJCocgA(qNjjaljnWvxaJ4bNlKCziKhh5Cemvwdt0KIZFUqYLH(OrhGykOybYOs56(gQmqHMBObOT51qPl4E6VxmCdPrT9e(ft3qLbk0CdvCfguFK04uBRBiRla1LEdDmxCeqO4kmO(iPXP2wsC1sHscqXoxd0CHKRJ5QmqHgHIRWG6JKgNABjXvlfkjQrg9fuSGCHKRRCDmxCeqO4kmO(iPXP2wsSK6fGIDUgO5YXLlociuCfguFK04uBljws9IMS0Am5YBU)MR7C54YfhbekUcdQpsACQTLexTuOKWau25C5l3JZfsU4iGqXvyq9rsJtTTK4QLcLenzP1yYLVCpoxi5IJacfxHb1hjno12sIRwkusak25AGEdz8Z8KeOnucyUNYZfCpfJCXWnKg12t4xmDdvgOqZn08My10nK1fG6sVHnfBYGvT9uUqYfOnuciaLfjbijEr5YBU8GrYfsUkSKHLyNZfsUUY9t7sT9KG1fyqGhCUCC56kx1aA1lHroPox(Y94)5cjxhZ1(fJcMkRHjEW56oxoUCziKhh5Cemvwdt0KIZFUUVHm(zEsc0gkbm3t55cUN6WxmCdPrT9e(ft3qLbk0CdTqOjwnDdzDbOU0BytXMmyvBpLlKCbAdLacqzrsasIxuU8Mlphl(nxi5QWsgwIDoxi56k3pTl12tcwxGbbEW5YXLRRCvdOvVeg5K6C5l3J)NlKCDmx7xmkyQSgM4bNR7C54YLHqECKZrWuznmrtko)56oxi56yU2VyuCUg8MWLKfmYj1w0aK0qn0kiK4bFdz8Z8KeOnucyUNYZfCp9OVy4gsJA7j8lMUHkduO5gAaK3RTm61MUHSUaux6nSPytgSQTNYfsUaTHsabOSijajXlkxEZLhmsUbKBtwAnMCHKRclzyj25CHKRRC)0UuBpjyDbge4bNlhxUQb0QxcJCsDU8L7X)ZLJlxgc5XrohbtL1WenP48NR7BiJFMNKaTHsaZ9uEUG7Po4fd3qAuBpHFX0nK1fG6sVHkSKHLyNVHkduO5ggrnJKOOCuWRPl4Ekp)Vy4gsJA7j8lMUHSUaux6n0vUeZxWgsuJuh(ZLJlxI5lydjmiV2YAK8KlhxUeZxWgs4FJ2YAK8KR7CHKRRCDmxg6JgDaIPGIfiJkLlhxUUYvnGw9syKtQZLVCDWFZfsUUY9t7sT9KG1fyqGhCUCC5QgqREjmYj15YxUh)pxoUC)0UuBpjkJuruUUZfsUUY9t7sT9KGHMp0zsItg(hwUqY1XCziKhh5Cem08HotsawsAGRUagXdoxoUCDm3pTl12tcgA(qNjjoz4Fy5cjxhZLHqECKZrWuznmXdox356ox35cjxx5YqipoY5iyQSgMOjlTgtU8M7X)ZLJlx1aA1lHroPoxEZ1b)NlKCziKhh5Cemvwdt8GZfsUUYLHqECKZrqwWiNulTrdUOjlTgtU8LRYafAegG2XQjbHzI9aKeuwuUCC56yUm0hn6aeN5VlDY1DUCC5glOybYMS0Am5YxU88px35cjxx5IJacfxHb1hjno12sIRwkus0KLwJjxEZfJZLJlxhZLH(OrhGyiwJ8Ogpx33qLbk0CdJVMFjkkj)BOl4Ekp8CXWnKg12t4xmDdzDbOU0BORCjMVGnKW)gTLdHzqUCC5smFbBiHb51woeMb5YXLlX8fSHe6WVCimdYLJlx7xmkSvVomsIIs17LaS1a1ihf8As0KLwJjxEZfJf)MlhxU2VyuyREDyKefLQ3lbyRbQrQnths0KLwJjxEZfJf)MlhxUQb0QxcJCsDU8MRd(pxi5YqipoY5iyQSgMOjfN)CDNlKCDLldH84iNJGPYAyIMS0Am5YBUh)pxoUCziKhh5Cemvwdt0KIZFUUZLJl3ybflq2KLwJjx(YLN)3qLbk0CdpxdEt4sdC1fWCb3t5jWlgUH0O2Ec)IPBiRla1LEdDLRAaT6LWiNuNlV56G)ZfsUUY1(fJIZ1G3eUKSGroP2IgGKgQHwbHep4C54Y1XCzOpA0bioZFx6KR7C54YLH(OrhGykOybYOs5YXLR9lgf2Eec3)maXdoxi5A)IrHThHW9pdq0KLwJjx(YnW)5gqUUYfJZ1bYLHg8xbeWnXkdjvFbDSObiOrT9eEUUZ1DUqY1vUoMld9rJoaXuqXcKrLYLJlxgc5XrohbdnFOZKeGLKg4QlGr8GZLJl3ybflq2KLwJjx(YLHqECKZrWqZh6mjbyjPbU6cyenzP1yYnGCXi5YXLBSGIfiBYsRXK7rYLNJ(FU8LBG)ZnGCDLlgNRdKldn4VciGBIvgsQ(c6yrdqqJA7j8CDNR7BOYafAUHmYtgqPEP6lOJfnGl4EkphFXWnKg12t4xmDdzDbOU0BORCvdOvVeg5K6C5nxh8FUqY1vU2VyuCUg8MWLKfmYj1w0aK0qn0kiK4bNlhxUoMld9rJoaXz(7sNCDNlhxUm0hn6aetbflqgvkxoUCTFXOW2Jq4(NbiEW5cjx7xmkS9ieU)zaIMS0Am5YxUh)p3aY1vUyCUoqUm0G)kGaUjwziP6lOJfnabnQTNWZ1DUUZfsUUY1XCzOpA0biMckwGmQuUCC5YqipoY5iyO5dDMKaSK0axDbmIhCUCC5(PDP2EsWqZh6mjXjd)dlxi5glOybYMS0Am5YBU8C0)ZnGCd8FUbKRRCX4CDGCzOb)vabCtSYqs1xqhlAacAuBpHNR7C54YnwqXcKnzP1yYLVCziKhh5Cem08HotsawsAGRUagrtwAnMCdixmsUCC5glOybYMS0Am5YxUh)p3aY1vUyCUoqUm0G)kGaUjwziP6lOJfnabnQTNWZ1DUUVHkduO5gwdt7rbfAUG7P8GXxmCdPrT9e(ft3qwxaQl9g6k3pTl12tcgA(qNjjoz4Fy5cj3ybflq2KLwJjxEZLNJ)NlhxU2VyuWuznmXdox35cjxx5A)IrHT61HrsuuQEVeGTgOg5OGxtcdqzNLFQ)r5YBUh)pxoUCTFXOWw96WijkkvVxcWwduJuBMoKWau2z5N6FuU8M7X)Z1DUCC5glOybYMS0Am5YxU88)gQmqHMBidnFOZKeGLKg4QlG5cUNYZVxmCdPrT9e(ft3qwxaQl9gYqF0OdqmfuSazuPCHKRRC)0UuBpjyO5dDMK4KH)HLlhxUmeYJJCocMkRHjAYsRXKlF5YZ)CDNlKCvdOvVeg5K6C5n3F)NlKCziKhh5Cem08HotsawsAGRUagrtwAnMC5lxE(FdvgOqZn0a028AO0fCpLhmYfd3qAuBpHFX0nebFdne4gQmqHMB4N2LA7PB4N6F0nKy(c2qIAK(3ODUoqUhDU)KRYafAegG2XQjbHzI9aKeuwuUbKRJ5smFbBirns)B0oxhixmsU)KRYafAeoBfGvqyMypajbLfLBa5(xeyU)KRbM8Ejw1aOB4N2YrTOBOAGXOG6qIDb3t5XHVy4gsJA7j8lMUHSUaux6n0vU1aOgg5vaHlJfuSaztwAnMC5lxmoxoUCDLR9lgfT(rd6zKXMMGWVOjlTgtU8LlugUWsXCUoqUmQ856kx1aA1lHroPo3FY94)56oxi5A)IrrRF0GEgzSPji8lEW56ox35YXLRRCvdOvVeg5K6Cdi3pTl12tc1aJrb1Helxhix7xmkiMVGnK0G8AlAYsRXKBa5IJaI4R5xIIsY)gsak2zJSjlTMCDGCdu8BU8Mlpb(pxoUCvdOvVeg5K6Cdi3pTl12tc1aJrb1Helxhix7xmkiMVGnK0)gTfnzP1yYnGCXrar818lrrj5Fdjaf7Sr2KLwtUoqUbk(nxEZLNa)NR7CHKlX8fSHe1i1H)CHKRRCDLRJ5YqipoY5iyQSgM4bNlhxUm0hn6aeN5VlDYfsUoMldH84iNJGSGroPwAJgCXdox35YXLld9rJoaXuqXcKrLY1DUqY1vUoMld9rJoaXhnaS835YXLRJ5A)IrbtL1Wep4C54YvnGw9syKtQZL3CDW)56oxoUCTFXOGPYAyIMS0Am5YBUhDUqY1XCTFXOO1pAqpJm20ee(fp4BOYafAUHgG2MxdLUG7P8C0xmCdPrT9e(ft3qwxaQl9g6kx7xmkiMVGnK0)gTfp4C54Y1vUmSAdLm5Ei3aZfsUnXWQnuscklkx(Y93CDNlhxUmSAdLm5Ei3JZ1DUqYvHLmSe78nuzGcn3WHCkTqO5cUNYJdEXWnKg12t4xmDdzDbOU0BORCTFXOGy(c2qs)B0w8GZLJlxx5YWQnuYK7HCdmxi52edR2qjjOSOC5l3FZ1DUCC5YWQnuYK7HCpox35cjxfwYWsSZ3qLbk0CdXQ(O0cHMl4EAG)Vy4gsJA7j8lMUHSUaux6n0vU2VyuqmFbBiP)nAlEW5YXLRRCzy1gkzY9qUbMlKCBIHvBOKeuwuU8L7V56oxoUCzy1gkzY9qUhNR7CHKRclzyj25BOYafAUHXN3lTqO5cUNgipxmCdvgOqZn0P2DHAjkkj)BOBinQTNWVy6cUNgyGxmCdPrT9e(ft3qwxaQl9gsmFbBirns)B0oxoUCjMVGnKWG8AlhcZGC54YLy(c2qcD4xoeMb5YXLR9lgfo1Ululrrj5FdjEW5cjxI5lydjQr6FJ25YXLRRCTFXOGPYAyIMS0Am5YxUkduOr4SvawbHzI9aKeuwuUqY1(fJcMkRHjEW56(gQmqHMBObODSA6cUNg4XxmCdvgOqZn0zRaS3qAuBpHFX0fCpnqm(IHBinQTNWVy6gQmqHMBy)gPYafAK(YaUH(YaKJAr3WO69aS97cUGl4g(rTPqZ90a)h4FE(ZdgrWZn0P2tnqn3qmQcAe08um6NIrTdj3CXawk3Ycg1GCJOoxmA4nPw21GtngTCBkO)QMWZ1GSOC1hazPacpxgwDGsgrg8rvdLBGoKCdk08rnGWZnSScQCn8pafZ5EKCbOCpQNMlE9vMcn5IGPwbOoxx)4oxx8Gz3Im4JQgkxE(7qYnOqZh1acp3WYkOY1W)aumN7rosUauUh1tZ1cH)8ptUiyQvaQZ11rCNRlEWSBrg8rvdLlp84qYnOqZh1acp3WYkOY1W)aumN7rosUauUh1tZ1cH)8ptUiyQvaQZ11rCNRlEWSBrg8rvdLlpb6qYnOqZh1acp3WYkOY1W)aumN7rosUauUh1tZ1cH)8ptUiyQvaQZ11rCNRlEWSBrg8rvdLlpyehsUbfA(Ogq45gwwbvUg(hGI5CpsUauUh1tZfV(ktHMCrWuRauNRRFCNRlEWSBrgCgmgvbncAEkg9tXO2HKBUyalLBzbJAqUruNlgn4MyilBfGrl3Mc6VQj8Cnilkx9bqwkGWZLHvhOKrKbFu1q5(Rdj3GcnFudi8CdlRGkxd)dqXCUhjxak3J6P5IxFLPqtUiyQvaQZ11pUZ1vGy2TidodgJQGgbnpfJ(Pyu7qYnxmGLYTSGrni3iQZfJMIimA52uq)vnHNRbzr5QpaYsbeEUmS6aLmIm4JQgk3aDi5guO5JAaHNByzfu5A4FakMZ9ihjxak3J6P5AHWF(Njxem1ka1566iUZ1fpy2Tid(OQHYfJDi5guO5JAaHNByzfu5A4FakMZ9i5cq5Eupnx86RmfAYfbtTcqDUU(XDUU4bZUfzWhvnuUhTdj3GcnFudi8CdlRGkxd)dqXCUhjxak3J6P5IxFLPqtUiyQvaQZ11pUZ1fpy2Tid(OQHYLhECi5guO5JAaHNByzfu5A4FakMZ9ihjxak3J6P5AHWF(Njxem1ka1566iUZ1fpy2Tid(OQHYLNaDi5guO5JAaHNByzfu5A4FakMZ9ihjxak3J6P5AHWF(Njxem1ka1566iUZ1fpy2Tid(OQHYLhm2HKBqHMpQbeEUHLvqLRH)bOyo3JCKCbOCpQNMRfc)5FMCrWuRauNRRJ4oxx8Gz3Im4JQgkxEoAhsUbfA(Ogq45gwwbvUg(hGI5CpsUauUh1tZfV(ktHMCrWuRauNRRFCNRlEWSBrg8rvdLlpoOdj3GcnFudi8CdlRGkxd)dqXCUhjxak3J6P5IxFLPqtUiyQvaQZ11pUZ1fpy2Tid(OQHYnW)oKCdk08rnGWZnSScQCn8pafZ5EKCbOCpQNMlE9vMcn5IGPwbOoxx)4oxx8Gz3Im4JQgk3a)1HKBqHMpQbeEUHLvqLRH)bOyo3JKlaL7r90CXRVYuOjxem1ka1566h356kqm7wKbNbJrvqJGMNIr)umQDi5MlgWs5wwWOgKBe15IrZaWOLBtb9x1eEUgKfLR(ailfq45YWQduYiYGpQAOCpAhsUbfA(Ogq45gwwbvUg(hGI5CpYrYfGY9OEAUwi8N)zYfbtTcqDUUoI7CDXdMDlYGpQAOCDqhsUbfA(Ogq45gwwbvUg(hGI5CpYrYfGY9OEAUwi8N)zYfbtTcqDUUoI7CDXdMDlYGpQAOC55Vdj3GcnFudi8CdlRGkxd)dqXCUh5i5cq5Eupnxle(Z)m5IGPwbOoxxhXDUU4bZUfzWhvnuU8GrCi5guO5JAaHNByzfu5A4FakMZ9i5cq5Eupnx86RmfAYfbtTcqDUU(XDUU4bZUfzWhvnuU8C0oKCdk08rnGWZnSScQCn8pafZ5EKCbOCpQNMlE9vMcn5IGPwbOoxx)4oxx8Gz3Im4mymQcAe08um6NIrTdj3CXawk3Ycg1GCJOoxmA2ifGrl3Mc6VQj8Cnilkx9bqwkGWZLHvhOKrKbFu1q5YtGoKCdk08rnGWZnSScQCn8pafZ5EKJKlaL7r90CTq4p)ZKlcMAfG6CDDe356Ihm7wKbFu1q5YdgXHKBqHMpQbeEUHLvqLRH)bOyo3JKlaL7r90CXRVYuOjxem1ka1566h3566ym7wKbFu1q5YJd7qYnOqZh1acp3WYkOY1W)aumN7rYfGY9OEAU41xzk0KlcMAfG6CD9J7CDXdMDlYGZGXOBbJAaHN7rNRYafAY1xgGrKbFdHBuS80nmOnxmPEDyuUyus)k8m4G2CXOmdGSPo3a)FsUb(pW)zWzWbT5guy1bkzCizWbT56qZnObooHNBiYRDUyIulrgCqBUo0CdkS6aLWZfOnuciRyUm1qMCbOCz8Z8KeOnucyezWbT56qZnOjzH(i8CFZqmYy0M)C)0UuBpzY1vjiXj5c30N0a028AOuUouEZfUPpHbOT51qj3Im4myLbk0yeWnXqw2k4GfcnNRrgrTvgSYafAmc4MyilBfeWHFC2kaBgSYafAmc4MyilBfeWHFC2kaBgSYafAmc4MyilBfeWHFmaTJvtzWkduOXiGBIHSSvqah(5t7sT90jJArhyO5dDMK4KH)HDYN6F0bBKXaj6rO2LRybflq2KLwJXHg4F3hHNa)7M3OhHAxUIfuSaztwAnghAG)6qDXZFhaOEAaIAyApkOqJGg12t4UDOUWyhGHg8xbeWnXkdjvFbDSObiOrT9eUB3hHNJ(V7m4m4G2CXOumtShGWZL(OM)CbLfLlalLRYaOo3YKR(PLxT9KidwzGcnMdgKxBPnPwzWkduOXeWHF(0UuBpDYOw0HYiveDYN6F0bdm59sG2qjGryaAhvVNxEG4YrG6PbimaT9OgxqJA7jCooG6PbimaY71wI3veiOrT9eUBoodm59sG2qjGryaAhvVN3aZGvgOqJjGd)8PDP2E6KrTOdLrY8K(rN8P(hDWatEVeOnucyegG2XQjE5jdwzGcnMao8Jn1gQpxd0tQ4bxoYqF0OdqmfuSazujoohziKhh5Cem08HotsawsAGRUagXd2ne7xmkyQSgM4bNbRmqHgtah(bgbk0Csfpy)IrbtL1Wep4myLbk0yc4WppdjlazzYGvgOqJjGd)0VrQmqHgPVmGtg1IoOi6edOlg4apNuXdFAxQTNeLrQikdwzGcnMao8t)gPYafAK(Yaozul6aEtQLDn4uFIb0fdCGNtQ4H(nue1qjbOSiNOEK4nPw21GtTGc6VcgMWZGvgOqJjGd)0VrQmqHgPVmGtg1IoyJuWjgqxmWbEoPIh63qrudLe2QxhgjrrP69sa2AGAeuq)vWWeEgSYafAmbC4N(nsLbk0i9LbCYOw0bd4KkEWtFKN3F)NbRmqHgtah(5t7sT90jJArhGB6t6Sva2t(u)Joa30NWzRaSzWkduOXeWHF(0UuBpDYOw0b4M(KgG2XQPt(u)Joa30NWa0ownLbRmqHgtah(5t7sT90jJArhGB6tAaABEnu6Kp1)OdWn9jmaTnVgkLbRmqHgtah(PFJuzGcnsFzaNmQfDaUjyfWWknGm4myLbk0yekIo8PDP2E6KrTOd4nPwsNL3lJQ3lrX4jFQ)rhCz)IrbOSiNOEK4nPw21GtTOjlTgdFqz4clfZb8xWdhN9lgfGYICI6rI3KAzxdo1IMS0Am8PmqHgHbODSAsqyMypajbLffWFbpqCrmFbBirns)B0MJJy(c2qcdYRTCimd44iMVGnKqh(LdHzGB3qSFXOauwKtups8Mul7AWPw8GH0VHIOgkjaLf5e1JeVj1YUgCQfuq)vWWeEgSYafAmcfrbC4hdq7O69NuXd2VyuyaAhvVx0uSjdw12tqCzGjVxc0gkbmcdq7O698DmhNJ9BOiQHscqzror9iXBsTSRbNAbf0FfmmH7gIlh73qrudLeE(zARgz0teOgOsO(Yc2qckO)kyycNJduw0rocg)lV2VyuyaAhvVx0KLwJjGaDNbRmqHgJqruah(Xa0oQE)jv8q)gkIAOKauwKtups8Mul7AWPwqb9xbdt4qmWK3lbAdLagHbODu9EEpCmexoA)IrbOSiNOEK4nPw21GtT4bdX(fJcdq7O69IMInzWQ2EIJZ1N2LA7jbEtQL0z59YO69sumcXL9lgfgG2r17fnzP1y47yoodm59sG2qjGryaAhvVN3aHaupnaHbqEV2s8UIabnQTNWHy)IrHbODu9ErtwAng((1TB3zWkduOXiuefWHF(0UuBpDYOw0bdq7O69sNObiJQ3lrX4jFQ)rhudOvVeg5KAEp6)oux883bSFXOauwKtups8Mul7AWPwyak7SBhQl7xmkmaTJQ3lAYsRX4ahFedm59sSQbqUDOUWrar818lrrj5FdjAYsRX4a)6gI9lgfgG2r17fp4myLbk0yekIc4WpgG2MxdLoPIh(0UuBpjWBsTKolVxgvVxIIriFAxQTNegG2r17LordqgvVxIIXmyLbk0yekIc4WpM3eRMobOnuciR4HMInzWQ2EccqBOeqaklscqs8I4Lhm2HAGjVxc0gkbmb0KLwJ5KkEqHLmSe7meI5lydjQrQd)zWkduOXiuefWHFuCfguFK04uBRtaAdLaYkEWrqXoxduioQmqHgHIRWG6JKgNABjXvlfkjQrg9fuSaooCeqO4kmO(iPXP2wsC1sHscdqzN57yi4iGqXvyq9rsJtTTK4QLcLenzP1y474myLbk0yekIc4Wpwi0eRMobOnuciR4HMInzWQ2EccqBOeqaklscqs8I41fpyCaUmWK3lbAdLagHbODSAYb4r8RB3hXatEVeOnucycOjlTgZjv8Glgc5XrohbtL1WenP48ZXzGjVxc0gkbmcdq7y1eFhZX5Iy(c2qIAKgKxBooI5lydjQrAJay54iMVGnKOgP)nAdXrG6PbimONxIIsawsgrnzacAuBpHZXz)IrbCxwOgVuVuBMoftc)8gTfFQ)r8EiWF)7gIldm59sG2qjGryaAhRM4JN)oGlEcaOEAacGZAKwi0ye0O2Ec3TBiQb0QxcJCsnV)(3HA)IrHbODu9ErtwAnghaJ4gIJ2VyuCUg8MWLKfmYj1w0aK0qn0kiK4bdrHLmSe7CgSYafAmcfrbC4NiQzKefLJcEnDsfpOWsgwIDodwzGcngHIOao8tRF0GEgzSPji8Fsfpy)IrbtL1Wep4myLbk0yekIc4WpmYtgqPEP6lOJfnGtQ4bx2VyuyaAhvVx8G54udOvVeg5KAE)9VBioA)IrHb5nGIrIhmehTFXOGPYAyIhmex1aOgg5vaHlJfuSaztwAng(yiKhh5Cem08HotsawsAGRUagrtwAnMaCyoUAaudJ8kGWLXckwGSjlTgZrocph9F(cmqoogc5XrohbdnFOZKeGLKg4QlGr8G54CKH(OrhGykOybYOsUZGvgOqJrOikGd)udt7rbfAoPIhCz)IrHbODu9EXdMJtnGw9syKtQ593)UH4O9lgfgK3akgjEWqC0(fJcMkRHjEWqCvdGAyKxbeUmwqXcKnzP1y4JHqECKZrWqZh6mjbyjPbU6cyenzP1ycWH54QbqnmYRacxglOybYMS0Amh5i8C0)574a54yiKhh5Cem08HotsawsAGRUagXdMJZrg6JgDaIPGIfiJk5wzGcngHIOao8Z5AWBcxAGRUaMtQ4Hybflq2KLwJHpE(LJZL9lgfWDzHA8s9sTz6umj8ZB0w8P(hXxG)(NJZ(fJc4USqnEPEP2mDkMe(5nAl(u)J49qG)(3ne7xmkmaTJQ3lEWqyiKhh5Cemvwdt0KLwJH3F)NbRmqHgJqruah(XaiVxBz0RnDcJFMNKaTHsaZbEoPIhAk2KbRA7jiGYIKaKeViE55xigyY7LaTHsaJWa0ownXhgdrHLmSe7mex2VyuWuznmrtwAngE55phNJ2VyuWuznmXd2DgSYafAmcfrbC4NpTl12tNmQfDGHMp0zsYqdEbk0CYN6F0b7xmkG7Yc14L6LAZ0Pys4N3OT4t9pIVa)9VdvnGw9syKtQH4IHqECKZrWuznmrtwAnMa45pVXckwGSjlTgdhhdH84iNJGPYAyIMS0AmbC8F(IfuSaztwAngiXckwGSjlTgdV8C8Foo7xmkyQSgMOjlTgdVoSBieZxWgsuJuh(54IfuSaztwAnMJCeEc8pF88BgSYafAmcfrbC4hgA(qNjjaljnWvxaZjv8WN2LA7jbdnFOZKKHg8cuObIAaT6LWiNuZ3V)ZGvgOqJrOikGd)eFn)suus(3qNuXdeZxWgsuJuh(HOWsgwIDgI9lgfWDzHA8s9sTz6umj8ZB0w8P(hXxG)(hIlCeqO4kmO(iPXP2wsC1sHscqXoxduoohzOpA0bigI1ipQX54mWK3lbAdLagEd0DgSYafAmcfrbC4hdq7O69NuXd2VyuGgcG1iHPMrWGcnIhmex2VyuyaAhvVx0uSjdw12tCCQb0QxcJCsnVo4F3zWkduOXiuefWHFmaTJQ3FsfpWqF0OdqmfuSazujiFAxQTNem08HotsgAWlqHgimeYJJCocgA(qNjjaljnWvxaJOjlTgdFqz4clfZoaJkVl1aA1lHroP(i)(3ne7xmkmaTJQ3lAk2KbRA7PmyLbk0yekIc4WpgG2MxdLoPIhyOpA0biMckwGmQeKpTl12tcgA(qNjjdn4fOqdegc5XrohbdnFOZKeGLKg4QlGr0KLwJHpOmCHLIzhGrL3LAaT6LWiNuFKJ)7gI9lgfgG2r17fp4myLbk0yekIc4WpgG2MxdLoPIhSFXOaneaRrY8K2YVYuOr8G54C0a0ownjuyjdlXoZX5Y(fJcMkRHjAYsRXW3VqSFXOGPYAyIhmhNl7xmkA9Jg0ZiJnnbHFrtwAng(GYWfwkMDagvExQb0QxcJCs9ro(VBi2Vyu06hnONrgBAcc)IhSB3q(0UuBpjmaTJQ3lDIgGmQEVefJqmWK3lbAdLagHbODu9E(oodwzGcngHIOao8ZqoLwi0Csfp4Iy(c2qIAK6Wpegc5XrohbtL1WenzP1y493)CCUyy1gkzoeiKMyy1gkjbLfX3VU54yy1gkzoCSBikSKHLyNZGvgOqJrOikGd)Gv9rPfcnNuXdUiMVGnKOgPo8dHHqECKZrWuznmrtwAngE)9phNlgwTHsMdbcPjgwTHssqzr89RBoogwTHsMdh7gIclzyj25myLbk0yekIc4WpXN3lTqO5KkEWfX8fSHe1i1HFimeYJJCocMkRHjAYsRXW7V)54CXWQnuYCiqinXWQnuscklIVFDZXXWQnuYC4y3quyjdlXoNbRmqHgJqruah(XP2DHAjkkj)BOmyLbk0yekIc4WpFAxQTNozul6GbODSAswJ0G8AFYN6F0bdm59sG2qjGryaAhRM49Odi6rO2LLAauZV8t9p6ib(3Darpc1USFXOWa028AOKKSGroP2IgGWau25JGXUZGvgOqJrOikGd)4Sva2tQ4bI5lydj8VrB5qygWXrmFbBiHo8lhcZaiFAxQTNeLrY8K(rCCeZxWgsuJ0G8AdXXpTl12tcdq7y1KSgPb51MJZ(fJcMkRHjAYsRXWNYafAegG2XQjbHzI9aKeuweeh)0UuBpjkJK5j9JGy)IrbtL1WenzP1y4JWmXEascklcI9lgfmvwdt8G54SFXOO1pAqpJm20ee(fpyigyY7LyvdG49VaJWX54N2LA7jrzKmpPFee7xmkyQSgMOjlTgdVeMj2dqsqzrzWkduOXiuefWHFmaTJvtzWkduOXiuefWHF63ivgOqJ0xgWjJArhIQ3dW2Vm4myLbk0ye2ifCO1pAqpJm20ee(pPIhSFXOGPYAyIhCgSYafAmcBKcc4WpFAxQTNozul6aRlWGap4t(u)Jo4O9lgf2QxhgjrrP69sa2AGAKJcEnjEWqC0(fJcB1RdJKOOu9EjaBnqnsTz6qIhCgSYafAmcBKcc4WpmDyKxA)IXtg1IoyaA7rn(jv8Gl7xmkSvVomsIIs17LaS1a1ihf8As0KLwJHxmw8lhN9lgf2QxhgjrrP69sa2AGAKAZ0HenzP1y4fJf)6gIAaT6LWiNuZ7bh8pexmeYJJCocMkRHjAYsRXWRdZX5IHqECKZrqwWiNulTrdUOjlTgdVomehTFXO4Cn4nHljlyKtQTObiPHAOvqiXdgcd9rJoaXz(7sh3UZGvgOqJryJuqah(Xa028AO0jv8GJFAxQTNeSUadc8GH4YLJmeYJJCocgA(qNjjaljnWvxaJ4bZX54N2LA7jbdnFOZKKHg8cuOHJZrg6JgDaIPGIfiJk5gIlg6JgDaIPGIfiJkXX5IHqECKZrWuznmrtwAngEDyooxmeYJJCocYcg5KAPnAWfnzP1y41HH4O9lgfNRbVjCjzbJCsTfnajnudTccjEWqyOpA0bioZFx642TB3CCUyiKhh5Cem08HotsawsAGRUagXdgcdH84iNJGPYAyIMuC(HWqF0OdqmfuSazuj3zWkduOXiSrkiGd)O4kmO(iPXP2wNW4N5jjqBOeWCGNtQ4bhXraHIRWG6JKgNABjXvlfkjaf7CnqH4OYafAekUcdQpsACQTLexTuOKOgz0xqXcG4YrCeqO4kmO(iPXP2wsSK6fGIDUgOCC4iGqXvyq9rsJtTTKyj1lAYsRXW7VU54WraHIRWG6JKgNABjXvlfkjmaLDMVJHGJacfxHb1hjno12sIRwkus0KLwJHVJHGJacfxHb1hjno12sIRwkusak25AGMbRmqHgJWgPGao8J5nXQPty8Z8KeOnucyoWZjv8qtXMmyvBpbbOnuciaLfjbijEr8YdgbIclzyj2ziU(0UuBpjyDbge4bZX5snGw9syKtQ574)qC0(fJcMkRHjEWU54yiKhh5Cemvwdt0KIZV7myLbk0ye2ifeWHFSqOjwnDcJFMNKaTHsaZbEoPIhAk2KbRA7jiaTHsabOSijajXlIxEow8lefwYWsSZqC9PDP2EsW6cmiWdMJZLAaT6LWiNuZ3X)H4O9lgfmvwdt8GDZXXqipoY5iyQSgMOjfNF3qC0(fJIZ1G3eUKSGroP2IgGKgQHwbHep4myLbk0ye2ifeWHFmaY71wg9AtNW4N5jjqBOeWCGNtQ4HMInzWQ2EccqBOeqaklscqs8I4LhmsanzP1yGOWsgwIDgIRpTl12tcwxGbbEWCCQb0QxcJCsnFh)NJJHqECKZrWuznmrtko)UZGvgOqJryJuqah(jIAgjrr5OGxtNuXdkSKHLyNZGvgOqJryJuqah(j(A(LOOK8VHoPIhCrmFbBirnsD4NJJy(c2qcdYRTSgjpCCeZxWgs4FJ2YAK84gIlhzOpA0biMckwGmQehNl1aA1lHroPMph8xiU(0UuBpjyDbge4bZXPgqREjmYj18D8FoUpTl12tIYive5gIRpTl12tcgA(qNjjoz4FyqCKHqECKZrWqZh6mjbyjPbU6cyepyooh)0UuBpjyO5dDMK4KH)HbXrgc5XrohbtL1Wepy3UDdXfdH84iNJGPYAyIMS0Am8E8Foo1aA1lHroPMxh8pegc5XrohbtL1WepyiUyiKhh5CeKfmYj1sB0GlAYsRXWNYafAegG2XQjbHzI9aKeuwehNJm0hn6aeN5VlDCZXflOybYMS0Am8XZF3qCHJacfxHb1hjno12sIRwkus0KLwJHxmMJZrg6JgDaIHynYJAC3zWkduOXiSrkiGd)CUg8MWLg4QlG5KkEWfX8fSHe(3OTCimd44iMVGnKWG8AlhcZaooI5lydj0HF5qygWXz)IrHT61HrsuuQEVeGTgOg5OGxtIMS0Am8IXIF54SFXOWw96WijkkvVxcWwduJuBMoKOjlTgdVyS4xoo1aA1lHroPMxh8pegc5XrohbtL1WenP487gIlgc5XrohbtL1WenzP1y494)CCmeYJJCocMkRHjAsX53nhxSGIfiBYsRXWhp)ZGvgOqJryJuqah(HrEYak1lvFbDSObCsfp4snGw9syKtQ51b)dXL9lgfNRbVjCjzbJCsTfnajnudTccjEWCCoYqF0OdqCM)U0Xnhhd9rJoaXuqXcKrL44SFXOW2Jq4(NbiEWqSFXOW2Jq4(NbiAYsRXWxG)dWfg7am0G)kGaUjwziP6lOJfnabnQTNWD7gIlhzOpA0biMckwGmQehhdH84iNJGHMp0zscWssdC1fWiEWCCXckwGSjlTgdFmeYJJCocgA(qNjjaljnWvxaJOjlTgtayeoUybflq2KLwJ5ihHNJ(pFb(paxySdWqd(Rac4MyLHKQVGow0ae0O2Ec3T7myLbk0ye2ifeWHFQHP9OGcnNuXdUudOvVeg5KAEDW)qCz)IrX5AWBcxswWiNuBrdqsd1qRGqIhmhNJm0hn6aeN5VlDCZXXqF0OdqmfuSazujoo7xmkS9ieU)zaIhme7xmkS9ieU)zaIMS0Am8D8)aCHXoadn4VciGBIvgsQ(c6yrdqqJA7jC3UH4Yrg6JgDaIPGIfiJkXXXqipoY5iyO5dDMKaSK0axDbmIhmh3N2LA7jbdnFOZKeNm8pmiXckwGSjlTgdV8C0)diW)b4cJDagAWFfqa3eRmKu9f0XIgGGg12t4U54IfuSaztwAng(yiKhh5Cem08HotsawsAGRUagrtwAnMaWiCCXckwGSjlTgdFh)paxySdWqd(Rac4MyLHKQVGow0ae0O2Ec3T7myLbk0ye2ifeWHFyO5dDMKaSK0axDbmNuXdU(0UuBpjyO5dDMK4KH)HbjwqXcKnzP1y4LNJ)ZXz)IrbtL1Wepy3qCz)IrHT61HrsuuQEVeGTgOg5OGxtcdqzNLFQ)r8E8Foo7xmkSvVomsIIs17LaS1a1i1MPdjmaLDw(P(hX7X)DZXflOybYMS0Am8XZ)myLbk0ye2ifeWHFmaTnVgkDsfpWqF0OdqmfuSazujiU(0UuBpjyO5dDMK4KH)HXXXqipoY5iyQSgMOjlTgdF883ne1aA1lHroPM3F)dHHqECKZrWqZh6mjbyjPbU6cyenzP1y4JN)zWkduOXiSrkiGd)8PDP2E6KrTOdQbgJcQdj2jFQ)rhiMVGnKOgP)nA7ah9rugOqJWa0ownjimtShGKGYIcWrI5lydjQr6FJ2oag5ikduOr4SvawbHzI9aKeuwua)fbEedm59sSQbqzWkduOXiSrkiGd)yaABEnu6KkEWvnaQHrEfq4Yybflq2KLwJHpmMJZL9lgfT(rd6zKXMMGWVOjlTgdFqz4clfZoaJkVl1aA1lHroP(ih)3ne7xmkA9Jg0ZiJnnbHFXd2TBooxQb0QxcJCsDaFAxQTNeQbgJcQdjMdy)IrbX8fSHKgKxBrtwAnMaWrar818lrrj5Fdjaf7Sr2KLwJdeO4xE5jW)CCQb0QxcJCsDaFAxQTNeQbgJcQdjMdy)IrbX8fSHK(3OTOjlTgta4iGi(A(LOOK8VHeGID2iBYsRXbcu8lV8e4F3qiMVGnKOgPo8dXLlhziKhh5Cemvwdt8G54yOpA0bioZFx6aXrgc5XrohbzbJCsT0gn4IhSBoog6JgDaIPGIfiJk5gIlhzOpA0bi(ObGL)MJZr7xmkyQSgM4bZXPgqREjmYj186G)DZXz)IrbtL1WenzP1y49OH4O9lgfT(rd6zKXMMGWV4bNbRmqHgJWgPGao8ZqoLwi0Csfp4Y(fJcI5lydj9VrBXdMJZfdR2qjZHaH0edR2qjjOSi((1nhhdR2qjZHJDdrHLmSe7CgSYafAmcBKcc4WpyvFuAHqZjv8Gl7xmkiMVGnK0)gTfpyooxmSAdLmhcestmSAdLKGYI47x3CCmSAdLmho2nefwYWsSZzWkduOXiSrkiGd)eFEV0cHMtQ4bx2VyuqmFbBiP)nAlEWCCUyy1gkzoeiKMyy1gkjbLfX3VU54yy1gkzoCSBikSKHLyNZGvgOqJryJuqah(XP2DHAjkkj)BOmyLbk0ye2ifeWHFmaTJvtNuXdeZxWgsuJ0)gT54iMVGnKWG8AlhcZaooI5lydj0HF5qygWXz)IrHtT7c1suus(3qIhmeI5lydjQr6FJ2CCUSFXOGPYAyIMS0Am8PmqHgHZwbyfeMj2dqsqzrqSFXOGPYAyIhS7myLbk0ye2ifeWHFC2kaBgSYafAmcBKcc4Wp9BKkduOr6ld4KrTOdr17by7xgCgSYafAmc8Mul7AWP(WN2LA7Ptg1Ioy0ijbi5Zqsdm59N8P(hDWL9lgfGYICI6rI3KAzxdo1IMS0Am8cLHlSumhWFbpqCrmFbBirnsBealhhX8fSHe1iniV2CCeZxWgs4FJ2YHWmWnhN9lgfGYICI6rI3KAzxdo1IMS0Am8QmqHgHbODSAsqyMypajbLffWFbpqCrmFbBirns)B0MJJy(c2qcdYRTCimd44iMVGnKqh(LdHzGB3CCoA)IrbOSiNOEK4nPw21GtT4bNbRmqHgJaVj1YUgCQd4WpgG2MxdLoPIhC54N2LA7jHrJKeGKpdjnWK3ZX5Y(fJIw)Ob9mYyttq4x0KLwJHpOmCHLIzhGrL3LAaT6LWiNuFKJ)7gI9lgfT(rd6zKXMMGWV4b72nhNAaT6LWiNuZRd(pdwzGcngbEtQLDn4uhWHFuCfguFK04uBRtaAdLaYkEWrCeqO4kmO(iPXP2wsC1sHscqXoxduioQmqHgHIRWG6JKgNABjXvlfkjQrg9fuSaiUCehbekUcdQpsACQTLelPEbOyNRbkhhociuCfguFK04uBljws9IMS0Am8(RBooCeqO4kmO(iPXP2wsC1sHscdqzN57yi4iGqXvyq9rsJtTTK4QLcLenzP1y47yi4iGqXvyq9rsJtTTK4QLcLeGIDUgOzWkduOXiWBsTSRbN6ao8JfcnXQPtaAdLaYkEOPytgSQTNGa0gkbeGYIKaKeViE5jWtQ4bx2VyuWuznmrtwAngE)fIl7xmkA9Jg0ZiJnnbHFrtwAngE)LJZr7xmkA9Jg0ZiJnnbHFXd2nhNJ2VyuWuznmXdMJtnGw9syKtQ574)UH4Yr7xmkoxdEt4sYcg5KAlAasAOgAfes8G54udOvVeg5KA(o(VBikSKHLyNZGvgOqJrG3KAzxdo1bC4hZBIvtNa0gkbKv8qtXMmyvBpbbOnuciaLfjbijEr8YtGNuXdUSFXOGPYAyIMS0Am8(lex2Vyu06hnONrgBAcc)IMS0Am8(lhNJ2Vyu06hnONrgBAcc)IhSBoohTFXOGPYAyIhmhNAaT6LWiNuZ3X)DdXLJ2VyuCUg8MWLKfmYj1w0aK0qn0kiK4bZXPgqREjmYj18D8F3quyjdlXoNbRmqHgJaVj1YUgCQd4Wpga59AlJETPtaAdLaYkEOPytgSQTNGa0gkbeGYIKaKeViE5bJCsfp4Y(fJcMkRHjAYsRXW7VqCz)IrrRF0GEgzSPji8lAYsRXW7VCCoA)IrrRF0GEgzSPji8lEWU54C0(fJcMkRHjEWCCQb0QxcJCsnFh)3nexoA)IrX5AWBcxswWiNuBrdqsd1qRGqIhmhNAaT6LWiNuZ3X)DdrHLmSe7CgSYafAmc8Mul7AWPoGd)ernJKOOCuWRPtQ4bfwYWsSZzWkduOXiWBsTSRbN6ao8tRF0GEgzSPji8Fsfpy)IrbtL1Wep4myLbk0ye4nPw21GtDah(5Cn4nHlnWvxaZjv8Glx2VyuqmFbBiPb51w0KLwJHxE(ZXz)IrbX8fSHK(3OTOjlTgdV883negc5XrohbtL1WenzP1y494)U54yiKhh5Cemvwdt0KIZFgSYafAmc8Mul7AWPoGd)WipzaL6LQVGow0aoPIhCz)IrX5AWBcxswWiNuBrdqsd1qRGqIhmhNJm0hn6aeN5VlDCZXXqF0OdqmfuSazujoUpTl12tIYiveXXz)IrHThHW9pdq8GHy)IrHThHW9pdq0KLwJHVa)hGlm2byOb)vabCtSYqs1xqhlAacAuBpH7gIJ2VyuWuznmXdgIRAaudJ8kGWLXckwGSjlTgdFmeYJJCocgA(qNjjaljnWvxaJOjlTgtaomhxnaQHrEfq4Yybflq2KLwJHVadKJRga1WiVciCzSGIfiBYsRXCKJWZr)NVadKJJHqECKZrWqZh6mjbyjPbU6cyepyoohzOpA0biMckwGmQK7myLbk0ye4nPw21GtDah(PgM2Jck0Csfp4Y(fJIZ1G3eUKSGroP2IgGKgQHwbHepyoohzOpA0bioZFx64MJJH(OrhGykOybYOsCCFAxQTNeLrQiIJZ(fJcBpcH7FgG4bdX(fJcBpcH7FgGOjlTgdFh)paxySdWqd(Rac4MyLHKQVGow0ae0O2Ec3nehTFXOGPYAyIhmex1aOgg5vaHlJfuSaztwAng(yiKhh5Cem08HotsawsAGRUagrtwAnMaCyoUAaudJ8kGWLXckwGSjlTgdFhhihxnaQHrEfq4Yybflq2KLwJ5ihHNJ(pFhhihhdH84iNJGHMp0zscWssdC1fWiEWCCoYqF0OdqmfuSazuj3zWkduOXiWBsTSRbN6ao8ZN2LA7Ptg1IoWqZh6mjzObVafAo5t9p6ad9rJoaXuqXcKrLG4Y(fJc4USqnEPEP2mDkMe(5nAl(u)J4lqm(pexmeYJJCocMkRHjAYsRXeap)5Tga1WiVciCzSGIfiBYsRXWXXqipoY5iyQSgMOjlTgtah)NVAaudJ8kGWLXckwGSjlTgdKAaudJ8kGWLXckwGSjlTgdV8C8Foo7xmkyQSgMOjlTgdVoSBi2VyuqmFbBiPb51w0KLwJHxE(ZXvdGAyKxbeUmwqXcKnzP1yoYr4jW)8XZVUZGvgOqJrG3KAzxdo1bC4NpTl12tNmQfDWOFKmIAjtL1Wo5t9p6GlhziKhh5Cemvwdt0KIZphNJFAxQTNem08HotsgAWlqHgim0hn6aetbflqgvYDgSYafAmc8Mul7AWPoGd)WqZh6mjbyjPbU6cyoPIh(0UuBpjyO5dDMKm0GxGcnqudOvVeg5KA(W4)zWkduOXiWBsTSRbN6ao8t818lrrj5FdDsfpqmFbBirnsD4hIclzyj2ziUWraHIRWG6JKgNABjXvlfkjaf7Cnq54CKH(OrhGyiwJ8Og3nKpTl12tcJ(rYiQLmvwdldwzGcngbEtQLDn4uhWHFmaTnVgkDsfpWqF0OdqmfuSazujiFAxQTNem08HotsgAWlqHgiQb0QxcJCsnVhW4)qyiKhh5Cem08HotsawsAGRUagrtwAng(GYWfwkMDagvExQb0QxcJCs9ro(V7myLbk0ye4nPw21GtDah(ziNsleAoPIhCz)IrbX8fSHK(3OT4bZX5IHvBOK5qGqAIHvBOKeuweF)6MJJHvBOK5WXUHOWsgwIDgYN2LA7jHr)ize1sMkRHLbRmqHgJaVj1YUgCQd4WpyvFuAHqZjv8Gl7xmkiMVGnK0)gTfpyioYqF0OdqCM)U0HJZL9lgfNRbVjCjzbJCsTfnajnudTccjEWqyOpA0bioZFx64MJZfdR2qjZHaH0edR2qjjOSi((1nhhdR2qjZHJ54SFXOGPYAyIhSBikSKHLyNH8PDP2Esy0psgrTKPYAyzWkduOXiWBsTSRbN6ao8t859sleAoPIhCz)IrbX8fSHK(3OT4bdXrg6JgDaIZ83LoCCUSFXO4Cn4nHljlyKtQTObiPHAOvqiXdgcd9rJoaXz(7sh3CCUyy1gkzoeiKMyy1gkjbLfX3VU54yy1gkzoCmhN9lgfmvwdt8GDdrHLmSe7mKpTl12tcJ(rYiQLmvwdldwzGcngbEtQLDn4uhWHFCQDxOwIIsY)gkdwzGcngbEtQLDn4uhWHFmaTJvtNuXdeZxWgsuJ0)gT54iMVGnKWG8AlhcZaooI5lydj0HF5qygWXz)IrHtT7c1suus(3qIhme7xmkiMVGnK0)gTfpyoox2VyuWuznmrtwAng(ugOqJWzRaSccZe7bijOSii2VyuWuznmXd2DgSYafAmc8Mul7AWPoGd)4Sva2myLbk0ye4nPw21GtDah(PFJuzGcnsFzaNmQfDiQEpaB)YGZGvgOqJrevVhGTFhmaTnVgkDsfp4y)gkIAOKWw96WijkkvVxcWwduJGc6VcgMWZGvgOqJrevVhGTFbC4hZBIvtNW4N5jjqBOeWCGNtQ4bCeqyHqtSAs0KLwJH3MS0AmzWkduOXiIQ3dW2Vao8JfcnXQPm4myLbk0yeWnbRagwPbCWcHMy10jm(zEsc0gkbmh45KkEOPytgSQTNGa0gkbeGYIKaKeViE5jqiUSFXOGPYAyIMS0Am8(lhNJ2VyuWuznmXdMJtnGw9syKtQ574)UHOWsgwIDodwzGcngbCtWkGHvAabC4hZBIvtNW4N5jjqBOeWCGNtQ4HMInzWQ2EccqBOeqaklscqs8I4LNaH4Y(fJcMkRHjAYsRXW7VCCoA)IrbtL1Wepyoo1aA1lHroPMVJ)7gIclzyj25myLbk0yeWnbRagwPbeWHFmaY71wg9AtNW4N5jjqBOeWCGNtQ4HMInzWQ2EccqBOeqaklscqs8I4LNaH4Y(fJcMkRHjAYsRXW7VCCoA)IrbtL1Wepyoo1aA1lHroPMVJ)7gIclzyj25myLbk0yeWnbRagwPbeWHFIOMrsuuok410jv8Gclzyj25myLbk0yeWnbRagwPbeWHFyKNmGs9s1xqhlAaNuXdUudOvVeg5KAEDW)CC2Vyuy7riC)Zaepyi2Vyuy7riC)ZaenzP1y4lqmIBioA)IrbtL1Wep4myLbk0yeWnbRagwPbeWHFQHP9OGcnNuXdUudOvVeg5KAEDW)CC2Vyuy7riC)Zaepyi2Vyuy7riC)ZaenzP1y47ymIBioA)IrbtL1Wep4myLbk0yeWnbRagwPbeWHF(0UuBpDYOw0bJ(rYiQLmvwd7Kp1)OdoYqipoY5iyQSgMOjfN)myLbk0yeWnbRagwPbeWHFIVMFjkkj)BOtQ4bI5lydjQrQd)quyjdlXod5t7sT9KWOFKmIAjtL1WYGvgOqJra3eScyyLgqah(HPdJ8s7xmEYOw0bdqBpQXpPIhSFXOWa02JACrtwAng(WiqCz)IrbX8fSHKgKxBXdMJZ(fJcI5lydj9VrBXd2ne1aA1lHroPMxh8FgSYafAmc4MGvadR0ac4WpgG2MxdLoPIhC5OgeQlajmGM0Z1avAaABeToN54SFXOGPYAyIMS0Am8ryMypajbLfXX5iCtFcdqBZRHsUH4Y(fJcMkRHjEWCCQb0QxcJCsnVo4FieZxWgsuJuh(DNbRmqHgJaUjyfWWknGao8JbOT51qPtQ4bxoQbH6cqcdOj9CnqLgG2grRZzoo7xmkyQSgMOjlTgdFeMj2dqsqzrCCo(PDP2Esa30N0a028AOKBia1tdqyaA7rnUGg12t4qCz)IrHbOTh14IhmhNAaT6LWiNuZRd(3ne7xmkmaT9Ogxyak7mFhdXL9lgfeZxWgsAqETfpyoo7xmkiMVGnK0)gTfpy3qyiKhh5Cemvwdt0KLwJHxhodwzGcngbCtWkGHvAabC4hdqBZRHsNuXdUCudc1fGegqt65AGknaTnIwNZCC2VyuWuznmrtwAng(imtShGKGYI44CeUPpHbOT51qj3qSFXOGy(c2qsdYRTOjlTgdVomeI5lydjQrAqETH4iq90aegG2EuJlOrT9eoegc5XrohbtL1WenzP1y41HZGvgOqJra3eScyyLgqah(ziNsleAoPIhCz)IrbX8fSHK(3OT4bZX5IHvBOK5qGqAIHvBOKeuweF)6MJJHvBOK5WXUHOWsgwIDgYN2LA7jHr)ize1sMkRHLbRmqHgJaUjyfWWknGao8dw1hLwi0Csfp4Y(fJcI5lydj9VrBXdMJZfdR2qjZHaH0edR2qjjOSi((1nhhdR2qjZHJ54SFXOGPYAyIhSBikSKHLyNH8PDP2Esy0psgrTKPYAyzWkduOXiGBcwbmSsdiGd)eFEV0cHMtQ4bx2VyuqmFbBiP)nAlEWCCUyy1gkzoeiKMyy1gkjbLfX3VU54yy1gkzoCmhN9lgfmvwdt8GDdrHLmSe7mKpTl12tcJ(rYiQLmvwdldwzGcngbCtWkGHvAabC4hNA3fQLOOK8VHYGvgOqJra3eScyyLgqah(Xa0ownDsfp4sdc1fGegqt65AGknaTnIwNZqSFXOGPYAyIMS0Am8syMypajbLfbbUPpHZwbyDZX5YrniuxasyanPNRbQ0a02iADoZXz)IrbtL1WenzP1y4JWmXEascklIJZr4M(egG2XQj3qCrmFbBirns)B0MJJy(c2qcdYRTCimd44iMVGnKqh(LdHzahN9lgfo1Ululrrj5FdjEWqSFXOGy(c2qs)B0w8G54Cz)IrbtL1WenzP1y4tzGcncNTcWkimtShGKGYIGy)IrbtL1Wepy3U54CPbH6cqcC15uduP5nIwNZ8gie7xmkiMVGnK0G8AlAYsRXW7VqC0(fJcC15uduP5nIMS0Am8QmqHgHZwbyfeMj2dqsqzrUZGvgOqJra3eScyyLgqah(XzRaSzWkduOXiGBcwbmSsdiGd)0VrQmqHgPVmGtg1IoevVhGTFzWzWkduOXimGdkUcdQpsACQT1jm(zEsc0gkbmh45KkEWrCeqO4kmO(iPXP2wsC1sHscqXoxduioQmqHgHIRWG6JKgNABjXvlfkjQrg9fuSaiUCehbekUcdQpsACQTLelPEbOyNRbkhhociuCfguFK04uBljws9IMS0Am8(RBooCeqO4kmO(iPXP2wsC1sHscdqzN57yi4iGqXvyq9rsJtTTK4QLcLenzP1y47yi4iGqXvyq9rsJtTTK4QLcLeGIDUgOzWkduOXimGao8JfcnXQPty8Z8KeOnucyoWZjv8qtXMmyvBpbbOnuciaLfjbijEr8YtGNuXdUSFXOGPYAyIMS0Am8(lex2Vyu06hnONrgBAcc)IMS0Am8(lhNJ2Vyu06hnONrgBAcc)IhSBoohTFXOGPYAyIhmhNAaT6LWiNuZ3X)DdXLJ2VyuCUg8MWLKfmYj1w0aK0qn0kiK4bZXPgqREjmYj18D8F3quyjdlXoNbRmqHgJWac4WpM3eRMoHXpZtsG2qjG5apNuXdnfBYGvT9eeG2qjGauwKeGK4fXlpbcXL9lgfmvwdt0KLwJH3FH4Y(fJIw)Ob9mYyttq4x0KLwJH3F54C0(fJIw)Ob9mYyttq4x8GDZX5O9lgfmvwdt8G54udOvVeg5KA(o(VBiUC0(fJIZ1G3eUKSGroP2IgGKgQHwbHepyoo1aA1lHroPMVJ)7gIclzyj25myLbk0yegqah(XaiVxBz0RnDcJFMNKaTHsaZbEoPIhAk2KbRA7jiaTHsabOSijajXlIxEWiqCz)IrbtL1WenzP1y49xiUSFXOO1pAqpJm20ee(fnzP1y49xoohTFXOO1pAqpJm20ee(fpy3CCoA)IrbtL1Wepyoo1aA1lHroPMVJ)7gIlhTFXO4Cn4nHljlyKtQTObiPHAOvqiXdMJtnGw9syKtQ574)UHOWsgwIDodwzGcngHbeWHFIOMrsuuok410jv8Gclzyj25myLbk0yegqah(P1pAqpJm20ee(pPIhSFXOGPYAyIhCgSYafAmcdiGd)CUg8MWLg4QlG5KkEWLl7xmkiMVGnK0G8AlAYsRXWlp)54SFXOGy(c2qs)B0w0KLwJHxE(7gcdH84iNJGPYAyIMS0Am8E8FiUSFXOaUlluJxQxQntNIjHFEJ2Ip1)i(ceJ)ZX5y)gkIAOKaUlluJxQxQntNIjHFEJ2ckO)kyyc3TBoo7xmkG7Yc14L6LAZ0Pys4N3OT4t9pI3db6W)54yiKhh5Cemvwdt0KIZpexQb0QxcJCsnVo4FoUpTl12tIYive5odwzGcngHbeWHFyKNmGs9s1xqhlAaNuXdUudOvVeg5KAEDW)qCz)IrX5AWBcxswWiNuBrdqsd1qRGqIhmhNJm0hn6aeN5VlDCZXXqF0OdqmfuSazujoUpTl12tIYiveXXz)IrHThHW9pdq8GHy)IrHThHW9pdq0KLwJHVa)hGlxoOd0VHIOgkjG7Yc14L6LAZ0Pys4N3OTGc6VcgMWDhGlm2byOb)vabCtSYqs1xqhlAacAuBpH72TBioA)IrbtL1WepyiUIfuSaztwAng(yiKhh5Cem08HotsawsAGRUagrtwAnMaCyoUybflq2KLwJHVadmaxoOd4Y(fJc4USqnEPEP2mDkMe(5nAl(u)J4LN))D7MJlwqXcKnzP1yoYr45O)ZxGbYXXqipoY5iyO5dDMKaSK0axDbmIhmhNJm0hn6aetbflqgvYDgSYafAmcdiGd)udt7rbfAoPIhCPgqREjmYj186G)H4Y(fJIZ1G3eUKSGroP2IgGKgQHwbHepyoohzOpA0bioZFx64MJJH(OrhGykOybYOsCCFAxQTNeLrQiIJZ(fJcBpcH7FgG4bdX(fJcBpcH7FgGOjlTgdFh)paxUCqhOFdfrnusa3LfQXl1l1MPtXKWpVrBbf0FfmmH7oaxySdWqd(Rac4MyLHKQVGow0ae0O2Ec3TB3qC0(fJcMkRHjEWqCflOybYMS0Am8XqipoY5iyO5dDMKaSK0axDbmIMS0Amb4WCCXckwGSjlTgdFhhyaUCqhWL9lgfWDzHA8s9sTz6umj8ZB0w8P(hXlp))72nhxSGIfiBYsRXCKJWZr)NVJdKJJHqECKZrWqZh6mjbyjPbU6cyepyoohzOpA0biMckwGmQK7myLbk0yegqah(5t7sT90jJArhyO5dDMKm0GxGcnN8P(hDGH(OrhGykOybYOsqCz)IrbCxwOgVuVuBMoftc)8gTfFQ)r8fig)hIlgc5XrohbtL1WenzP1ycGN)8glOybYMS0AmCCmeYJJCocMkRHjAYsRXeWX)5lwqXcKnzP1yGelOybYMS0Am8YZX)54SFXOGPYAyIMS0Am86WUHy)IrbX8fSHKgKxBrtwAngE55phxSGIfiBYsRXCKJWtG)5JNFDNbRmqHgJWac4WpFAxQTNozul6Gr)ize1sMkRHDYN6F0bxoYqipoY5iyQSgMOjfNFooh)0UuBpjyO5dDMKm0GxGcnqyOpA0biMckwGmQK7myLbk0yegqah(HHMp0zscWssdC1fWCsfp8PDP2EsWqZh6mjzObVafAGOgqREjmYj18D8)myLbk0yegqah(j(A(LOOK8VHoPIhiMVGnKOgPo8drHLmSe7me7xmkG7Yc14L6LAZ0Pys4N3OT4t9pIVaX4)qCHJacfxHb1hjno12sIRwkusak25AGYX5id9rJoaXqSg5rnUBiFAxQTNeg9JKrulzQSgwgSYafAmcdiGd)yaAhvV)KkEW(fJc0qaSgjm1mcguOr8GHy)IrHbODu9ErtXMmyvBpLbRmqHgJWac4WpmDyKxA)IXtg1IoyaA7rn(jv8G9lgfgG2EuJlAYsRXW3VqCz)IrbX8fSHKgKxBrtwAngE)LJZ(fJcI5lydj9VrBrtwAngE)1ne1aA1lHroPMxh8FgSYafAmcdiGd)yaABEnu6KkEGH(OrhGykOybYOsq(0UuBpjyO5dDMKm0GxGcnqyiKhh5Cem08HotsawsAGRUagrtwAng(GYWfwkMDagvExQb0QxcJCs9ro(V7myLbk0yegqah(Xa0oQE)jv8aq90aega59AlX7kce0O2EchIJa1tdqyaA7rnUGg12t4qSFXOWa0oQEVOPytgSQTNG4Y(fJcI5lydj9VrBrtwAngEXiqiMVGnKOgP)nAdX(fJc4USqnEPEP2mDkMe(5nAl(u)J4lWF)ZXz)IrbCxwOgVuVuBMoftc)8gTfFQ)r8EiWF)drnGw9syKtQ51b)ZXHJacfxHb1hjno12sIRwkus0KLwJH3JMJtzGcncfxHb1hjno12sIRwkusuJm6lOybUH4idH84iNJGPYAyIMuC(ZGvgOqJryabC4hdqBZRHsNuXd2VyuGgcG1izEsB5xzk0iEWCC2VyuCUg8MWLKfmYj1w0aK0qn0kiK4bZXz)IrbtL1WepyiUSFXOO1pAqpJm20ee(fnzP1y4dkdxyPy2byu5DPgqREjmYj1h54)UHy)IrrRF0GEgzSPji8lEWCCoA)IrrRF0GEgzSPji8lEWqCKHqECKZr06hnONrgBAcc)IMuC(54CKH(OrhG4Jgaw(B3CCQb0QxcJCsnVo4FieZxWgsuJuh(ZGvgOqJryabC4hdqBZRHsNuXda1tdqyaA7rnUGg12t4qCz)IrHbOTh14IhmhNAaT6LWiNuZRd(3ne7xmkmaT9Ogxyak7mFhdXL9lgfeZxWgsAqETfpyoo7xmkiMVGnK0)gTfpy3qSFXOaUlluJxQxQntNIjHFEJ2Ip1)i(c0H)dXfdH84iNJGPYAyIMS0Am8YZFooh)0UuBpjyO5dDMKm0GxGcnqyOpA0biMckwGmQK7myLbk0yegqah(Xa028AO0jv8Gl7xmkG7Yc14L6LAZ0Pys4N3OT4t9pIVaD4)CC2Vyua3LfQXl1l1MPtXKWpVrBXN6FeFb(7Fia1tdqyaK3RTeVRiqqJA7jC3qSFXOGy(c2qsdYRTOjlTgdVomeI5lydjQrAqETH4O9lgfOHaynsyQzemOqJ4bdXrG6PbimaT9OgxqJA7jCimeYJJCocMkRHjAYsRXWRddXfdH84iNJ4Cn4nHlnWvxaJOjlTgdVomhNJm0hn6aeN5VlDCNbRmqHgJWac4Wpd5uAHqZjv8Gl7xmkiMVGnK0)gTfpyooxmSAdLmhcestmSAdLKGYI47x3CCmSAdLmho2nefwYWsSZq(0UuBpjm6hjJOwYuznSmyLbk0yegqah(bR6JsleAoPIhCz)IrbX8fSHK(3OT4bdXrg6JgDaIZ83LoCCUSFXO4Cn4nHljlyKtQTObiPHAOvqiXdgcd9rJoaXz(7sh3CCUyy1gkzoeiKMyy1gkjbLfX3VU54yy1gkzoCmhN9lgfmvwdt8GDdrHLmSe7mKpTl12tcJ(rYiQLmvwdldwzGcngHbeWHFIpVxAHqZjv8Gl7xmkiMVGnK0)gTfpyioYqF0OdqCM)U0HJZL9lgfNRbVjCjzbJCsTfnajnudTccjEWqyOpA0bioZFx64MJZfdR2qjZHaH0edR2qjjOSi((1nhhdR2qjZHJ54SFXOGPYAyIhSBikSKHLyNH8PDP2Esy0psgrTKPYAyzWkduOXimGao8JtT7c1suus(3qzWkduOXimGao8JbODSA6KkEGy(c2qIAK(3OnhhX8fSHegKxB5qygWXrmFbBiHo8lhcZaoo7xmkCQDxOwIIsY)gs8GHy)IrbX8fSHK(3OT4bZX5Y(fJcMkRHjAYsRXWNYafAeoBfGvqyMypajbLfbX(fJcMkRHjEWUZGvgOqJryabC4hNTcWMbRmqHgJWac4Wp9BKkduOr6ld4KrTOdr17by73n0atS7P88pWl4cUxa]] )


end