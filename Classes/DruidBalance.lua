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
            duration = 16,
            max_stack = 1,
            meta = {
                empowered = function( t ) return t.up and t.empowerTime >= t.applied end,
            }
        },
        eclipse_solar = {
            id = 48517,
            duration = 16,
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
            max_stack = 1,

            generate = function ()
                local foe = buff.fury_of_elune_ap
                local applied = action.fury_of_elune.lastCast

                if applied and now - applied < 8 then
                    foe.count = 1
                    foe.expires = applied + 8
                    foe.applied = applied
                    foe.caster = "player"
                    return
                end

                foe.count = 0
                foe.expires = 0
                foe.applied = 0
                foe.caster = "nobody"
            end,
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

        oath_of_the_elder_druid_icd = {
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

        return astral_power.current - cost + ( talent.shooting_stars.enabled and 4 or 0 ) + ( talent.natures_balance.enabled and ceil( execute_time / 1.5 ) or 0 ) < astral_power.max
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
            id = 194153,
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

            copy = "solar_wrath"
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


    spec:RegisterPack( "Balance", 20200907, [[dC0o6aqifvpIqvxsHk2eH8jbu1OuqNsHSkOO6vurMfHYTuOQ2fP(fvudtHYXeiltaEgbQPjGY1iqSnfQ03iqY4iuPZPqvwhuuI3rGuAEci3JG2hbCqcv0cfuEOaQmrcvWfjqk2iuus9rOOKCscKQvQOmtOOu2Pa1sHIs1tbAQcI9sYFfAWQ6Wuwms9yitgQUmQntvFgknAf40sTAcvOxtfMnr3gj7wLFJy4uPLl55GMUORdy7qHVlOA8qrX5fKwpuK5Ri7xPvbPcrbIBjRcoGXcySXgVXeu6aeCGjUcwWkWmuxwb6AihgwwbEgfRadZK2HyfORfQKy4QquGqcqHyf4GmDHywC2zSDoaGwJiuodBkaPLn5qL5tNHnfYzfinqltb9trRaXTKvbhWybm2yJ3yckDabjybjWgpfObKdiLceSPcCkWbnooFkAfiodrkqXVFyM0oeVV4qb047mXVpi7Mmfnx7lOeB)aglGX2z7mXVFGBGDyziMLDM43F83xCIJZ47dsKwTFySrP3zIF)XF)a3a7WY47NwHLZy73hzqgUFs2hfksYX0kSCc17mXV)4Vpyt5kBFO7loXexDY7NL15(scXbGlC)H4KlWN7da59bUJrmeAvO7JHvTrl59HHEPHzgP3zIF)XFFm7mfbdgFFmBngSm09bD7QZ9rKdVZMC77j1(bowYWSn5(ItzJ9O4lf0UFOeGaVuU)addE)o3Nu7hkby)WjxGp3h2hI3xq)oUWWsE)gU)Gg7aU23TAs1zOAfOSHjufIceN9gGmvHOcoivikqdLn5uGqI0QinBukq(mAjJROvPk4auHOa5ZOLmUkmfiQ6KR2uG0aEVgzX(qAaxfOHYMCkqAUGC5OpSQufSGvHOa5ZOLmUkmf4zuSc0WeCGvgm6jxgj(OljCUuGgkBYPanmbhyLbJEYLrIp6scNlfiQ6KR2uGZ3NgW71il2hsd4UVO9XjPMIqoFxSoBKJ(WUVO9XjPgcC(UyD2ih9HDFr7pC)57NMKVudtwkTk6LwXA(mAjJV)00(4KudtwkTk6LwX6Sro6d7(JuPk4atfIcKpJwY4QWuGOQtUAtboC)57NMKVudtRKKcxZNrlz89NM2NgW71W0kjPW1aU7pAFr7pFFAaVxJSyFinG7(I2hNKAkc58DX6Sro6d7(I2hNKAiW57I1zJC0h29fT)W9NVFAs(snmzP0QOxAfR5ZOLm((tt7JtsnmzP0QOxAfRZg5OpS7psbAOSjNcelGv4TDrIpAyIlsoqLQGfevikq(mAjJRctbAOSjNcefkssYICnkslnyQarvNC1McC((0aEVgzX(qAa39fTpoj1ueY57I1zJC0h29fTpoj1qGZ3fRZg5OpS7lA)H7pF)0K8LAyYsPvrV0kwZNrlz89NM2hNKAyYsPvrV0kwNnYrFy3FKcK9EgLXZOyfikuKKKf5AuKwAWuLQGhxvikq(mAjJRctbAOSjNceoOXGRig8rOIflBKc8mkwbch0yWved(iuXILnsbIQo5Qnf489Pb8EnYI9H0aU7lA)57td49AAjHGlbGPgWvbMwHLZy7vG4Kudh0yWved(iuAyAih7lGW9fevQcwqPcrbYNrlzCvykWZOyfiLDTNHjjs8rkd)yiubAOSjNcKYU2ZWKej(iLHFmeQarvNC1McKgW71il2hsxmL1hCFb2pOX2FAAFAaVxJSyFiDXuwFW9fy)aBFr7td49ARq21OOlGeALgMgYX(cS)4U)00((g7GmwmL1hC)aTFabPsvWIRkefiFgTKXvHParvNC1McerisCs4NgzX(q6IPS(G7lW(cEmfOHYMCkqAjHGhj(yoGJ8XuHQsvWJNkefiFgTKXvHParvNC1McC((0aEVgzX(qAa39fT)W9nywMm6scNR9d0(bii7pnTpIqK4KWpnYI9H0ftz9b3xG9f8y7pAFr7Jtsne48DX6IPS(G7lW(bn2(I2hNKAkc58DX6IPS(G7lW(bn2(I2F4(Z3pnjFPgMSuAv0lTI18z0sgF)PP9XjPgMSuAv0lTI1ftz9b3xG9dAS9hPanu2KtbsXuKk0iXhLaOgpIxSrbvPk4GgtfIc0qztofOlq1(q7dBKwAWubYNrlzCvyQufCqbPcrbAOSjNcSAxxjh7lcDneRa5ZOLmUkmvQcoOauHOanu2KtbIihIVSSKXJEPrXkq(mAjJRctLQGdsWQquG8z0sgxfMcevDYvBkqAaVxxmYHKHWONuiwd4UVO9XjPMIqoFxSoBKJ(WUVO9XjPgcC(UyD2ih9HDFr7pC)57NMKVudtwkTk6LwXA(mAjJV)00(4KudtwkTk6LwX6Sro6d7(JuGgkBYPaZbCe4OjahE0tkeRsvWbfyQquGgkBYPadNusCm4(IfdjNDiwbYNrlzCvyQufCqcIkefiFgTKXvHParvNC1McC4(Z3hdRAJwYAdtriC)PP9NVpnG3RrwSpKgWD)r7lAFCsQPiKZ3fRZg5OpS7lAFCsQHaNVlwNnYrFy3x0(d3F((Pj5l1WKLsRIEPvSMpJwY47pnTpoj1WKLsRIEPvSoBKJ(WU)ifOHYMCkqpbbaz8OHjU6KJ0SrPsvWbnUQquGgkBYPaZbK6Gkq(mAjJRctLQGdsqPcrbYNrlzCvykqu1jxTPaPb8EnYI9H0aU7pnTVVXoiJftz9b3pq7hWykqdLn5uGaqo2jtbvPk4GexvikqdLn5uGHBv1Kks8rwcCScKpJwY4QWuPk4Ggpvikq(mAjJRctbIQo5Qnf489Pb8EnYI9H0aU7lA)H7td49AkMIuHgj(Oea14r8InkOgWD)PP9hU)W9reIeNe(PPyksfAK4JsauJhXl2OG6IPS(G7lW(bm2(tt7pFFgc5dXAkMIuHgj(Oea14r8InkOMYehj1(J2x0(MBenGro2F0(J2x0(d3NgW71umfPcns8rjaQXJ4fBuqnG7(tt7BUr0ag5y)r7lAFCsQHaNVlwxmL1hCFb2xC3x0(4KutriNVlwxmL1hCFb2pOa2x0(d3hNKAyYsPvrV0kwxmL1hCFb2FC3FAA)57NMKVudtwkTk6LwXA(mAjJV)ifOHYMCkW(qwDw2KtLQGdymvikq(mAjJRctbIQo5Qnf489Pb8EnYI9H0aU7lA)H7td49AkMIuHgj(Oea14r8InkOgWD)PP9hU)W9reIeNe(PPyksfAK4JsauJhXl2OG6IPS(G7lW(bm2(tt7pFFgc5dXAkMIuHgj(Oea14r8InkOMYehj1(J2x0(MBenGro2F0(J2x0(d3hNKAiW57I1ftz9b3xG9dyFr7JtsnfHC(UyD2ih9HDFr7pCFCsQHjlLwf9sRyD2ih9HD)PP9NVFAs(snmzP0QOxAfR5ZOLm((J2FKc0qztofiILmmBtgnzJ9O4lvPk4acsfIc0qztofit5scNRin5WvG8z0sgxfMkvbhqaQquGgkBYPaldd(iaWOV4dtHQa5ZOLmUkmvQcoabRcrbYNrlzCvykqu1jxTPahUpnG3RrwSpKgWD)PP9reIeNe(PrwSpKUykRp4(cSVGhB)r7lA)WllhOn3iAaJCOanu2Ktb6bQqJeFKLahRsvWbeyQquG8z0sgxfMcevDYvBkWH7td49AKf7dPbC3FAAFeHiXjHFAKf7dPlMY6dUVa7l4X2F0(I23CJObmYHc0qztofONuios8XZsGIvPk4aeevikq(mAjJRctbIQo5QnfinG3RHPvssHRlMY6dUFG2xW7lA)57hEz5aT5grdyKdfOHYMCkqKDiwgPb8EfinG3hpJIvGW0kjPWvPk4agxvikq(mAjJRctbIQo5QnfinG3RzKSDHCucCwPbC3x0(Z3NgW71ms2UqokboR0mLljCUy89NM2NgW71ms2UqocjsR0aU7lA)57td49AgjBxihHePvAMYLeoxmUc0qztofimTccuyzvQcoabLkefiFgTKXvHParvNC1McC4(Z3p8YYbAZnIgWih7pnT)W9Pb8EnmTsskCnmnKJ9d0(cE)PP9Pb8EnmTsskCDXuwFW9fq4(I7(J2x0(d333yhKXIPS(G770(bT)O9X89HUSugtRWYjCFb2hrG5(JZ(bOfK9hTVO9HUSugtRWYjCFbeUpgw1gTK1qFmTclNqfOHYMCkqyAL3KsvQcoaXvfIcKpJwY4QWuGOQtUAtboC)H7NMKVudtRKKcxZNrlz89fT)W9Pb8EnmTsskCnmnKJ9d0(cE)PP9Pb8EnmTsskCDXuwFW9fq4(cY(I2NgW71wHSRrrxaj0knmnKJ9d0(I7(J2FAA)57NMKVudtRKKcxZNrlz89fT)W9Pb8ETvi7Au0fqcTsdtd5y)aTV4U)00(0aEVgzX(qAa39hT)O9fT)W9Pb8EnJKTlKJqI0knG7(I2NgW71ms2UqokboR0aU7pAFr7td496IroKmeg9KcXreb4sU0W0qo2pq7h04T)00(0aEVUyKdjdHrpPqSgWD)r7lAFOllLX0kSCc1W0kVjL7hO9XWQ2OLSg6JPvy5eUVO9hU)89XWQ2OLS2Wuec3FAA)57td49AKf7dPbC3FAA)577wmgAyAfeOWY7pA)PP99n2bzSykRp4(bs4(mMHrajhZMI3hZ33GzzYOljCU2FC2pWgB)PP9NVF4LLd0MBenGrouGgkBYPaHPvqGclRsvWbmEQquG8z0sgxfMcevDYvBkqdLngCKpMQz4(bAFmSQnAjRH(yAfwoH7lA)H7td49AgjBxihHePv6IPS(G7lW(idMXSP49NM2NgW71ms2UqokboR0ftz9b3xG9rgmJztX7psbAOSjNceMwbbkSSkvbl4XuHOa5ZOLmUkmfiQ6KR2uG0aEVgzX(qAa39fTpnG3RrwSpKUykRp4(bAFSiCnLHz2x0(gM4QtwdZInh9HnctRG6Yoh7lAFCsQPiKZ3fRlMY6dUVa7xmL1hubAOSjNcecC(UyvQcwWbPcrbYNrlzCvykqu1jxTPaPb8EnYI9H0aU7lAFAaVxJSyFiDXuwFW9d0(yr4AkdZSVO9nmXvNSgMfBo6dBeMwb1LDouGgkBYPaPiKZ3fRsvWcoavikq(mAjJRctbAOSjNcecC(UyfiQ6KR2uGf7lgoWOL8(I23CJObmYX(I23ljKA)H7NwHLtD2uCmjr8M3FC2F4(bSpMVp0LLY4adM8(J2F0(y((qxwkJPvy5eUVac3hXTC)H77LesT)W9dy)XzFOllLX0kSCc3F0(y((bPfK9hTVt7hW(y((qxwkJPvy5eUVO9hUp0LLYyAfwoH7lW(bTVt7NMKVuNH3xKIqoOMpJwY47pnTpoj1ueY57I1zJC0h29hTVO9hU)89nmXvNSgMfBo6dBeMwb1LDo2FAA)57td49AKf7dPbC3FAA)577wmgAiW57I3F0(I2F4(0aEVgzX(q6IPS(G7lW(ftz9b3FAA)57td49AKf7dPbC3FKcefksYX0kSCcvbhKkvblybRcrbYNrlzCvykqdLn5uGueY57IvGOQtUAtbwSVy4aJwY7lAFZnIgWih7lAFVKqQ9hUFAfwo1ztXXKeXBE)Xz)H7hW(y((qxwkJdmyY7pA)r7J57dDzPmMwHLt4(ciC)XDFr7pC)57ByIRoznml2C0h2imTcQl7CS)00(Z3NgW71il2hsd4U)00(Z33Tym0ueY57I3F0(I2F4(0aEVgzX(q6IPS(G7lW(ftz9b3FAA)57td49AKf7dPbC3FKcefksYX0kSCcvbhKkvbl4atfIcKpJwY4QWuGgkBYPaHjlLwf9sRyfiQ6KR2uGf7lgoWOL8(I23CJObmYX(I23ljKA)H7NwHLtD2uCmjr8M3FC2F4(bSpMVp0LLY4adM8(J2F0(ciCFbzFr7pC)57ByIRoznml2C0h2imTcQl7CS)00(Z3NgW71il2hsd4U)00(Z33Tym0WKLsRIEPv8(JuGOqrsoMwHLtOk4GuPkybliQquGgkBYParKddIdoMd4i0TRoHkq(mAjJRctLQGf84QcrbYNrlzCvykqu1jxTPan3iAaJCOanu2KtbEC4rkc5uPkyblOuHOa5ZOLmUkmfiQ6KR2uGMBenGrouGgkBYPahysFKIqovQcwWIRkefiFgTKXvHParvNC1Mc0CJObmYHc0qztofOhqkJueYPsvWcE8uHOa5ZOLmUkmfiQ6KR2uGMBenGro2x0(d3NgW71ms2UqokboR0ftz9b3xG9rgmJztX7pnTpKiTkYiz7c59fy)X2FKc0qztofimTY3fRsvWb2yQquG8z0sgxfMcevDYvBkqZnIgWih7lA)H7td49AgjBxihHePv6IPS(G7lW(idMXSP49NM2xcCwfzKSDH8(cS)y7psbAOSjNcm8YYbQufCGfKkefOHYMCkqiW57IvG8z0sgxfMkvPc0TyeHI2sviQGdsfIcKpJwY4QWuGexfiKtfOHYMCkqmSQnAjRaXWKaScmWuGyyv8mkwbc9X0kSCcvPk4auHOa5ZOLmUkmfiXvbA44kqdLn5uGyyvB0swbIHjbyfyqkqu1jxTPanmXvNS2kKDnk6ciHwP5ZOLmUcedRINrXkqOpMwHLtOkvblyvikq(mAjJRctbsCvGgoUc0qztofigw1gTKvGyysawbgKcevDYvBkW0K8LAyALKu4A(mAjJRaXWQ4zuSce6JPvy5eQsvWbMkefiFgTKXvHPajUkqdhxbAOSjNcedRAJwYkqmmjaRadsbIQo5QnfOHjU6K1WSyZrFyJW0kOUSZX(cSFa7lAFdtC1jRTczxJIUasOvA(mAjJRaXWQ4zuSce6JPvy5eQsvWcIkefiFgTKXvHPajUkqiaTc0qztofigw1gTKvGyysawbgKcevDYvBkW57NMKVuNH3xKIqoOMpJwY4kqmSkEgfRaH(yAfwoHQuf84QcrbAOSjNcKIqoh9f9KIsbYNrlzCvyQufSGsfIc0qztofOJ(WlgpcD7QtOcKpJwY4QWuPkyXvfIcKpJwY4QWuGNrXkqdtWbwzWONCzK4JUKW5sbAOSjNc0WeCGvgm6jxgj(OljCUuPk4XtfIcKpJwY4QWuGgkBYPaDjztofiEONr1OOBXUKubgKkvbh0yQquGgkBYPadVSCGcKpJwY4QWuPk4GcsfIc0qztofimTccuyzfiFgTKXvHPsvQsfigCbBYPcoGXcySXe3agpTGvGHB11hwOcuqNYLujJVFa7BOSj3(YgMq9otb6weFlzfO43pmtAhI3xCOaA8DM43hKDtMIMR9fuITFaJfWy7SDM43pWnWoSmeZYot87p(7loXXz89bjsR2pm2O07mXV)4VFGBGDyz89tRWYzS97Jmid3pj7Jcfj5yAfwoH6DM43F83hSPCLTp09fNyIRo59ZY6CFjH4aWfU)qCYf4Z9bG8(a3XigcTk09XWQ2OL8(WqV0WmJ07mXV)4VpMDMIGbJVpMTgdwg6(GUD15(iYH3ztU99KA)ahlzy2MCFXPSXEu8LcA3pucqGxk3FGHbVFN7tQ9dLaSF4KlWN7d7dX7lOFhxyyjVFd3FqJDax77wnP6mu9oBNj(9f0GzyeqY47tZEsX7Jiu0wUpnJTpOEFXjcXUjC)JCJ)aRO8aY9nu2KdUp5KHQ3zIFFdLn5GA3IrekAlf6Lg0Xot87BOSjhu7wmIqrBPtcD2ti47mXVVHYMCqTBXicfTLoj0zdalfFPLn52z7mXVV4etC1jVpgw1gTKH7mXVVHYMCqTBXicfTLoj0zmSQnAjl2zuSqdtriummmjal0WexDYAywS5OpSryAfux25yNj(9nu2KdQDlgrOOT0jHoJHvTrlzXoJIfAykAUIHHjbyHgM4QtwBfYUgfDbKqR0LDo2z7mXVpyAL3KY9XyFW0kiqHL3pTclN7JasI3VZmu2KdQDlgrOOTuigw1gTKf7mkwi0htRWYjummmjalmW2zgkBYb1UfJiu0w6KqNXWQ2OLSyNrXcH(yAfwoHIrCfA44IHHjbyHbjw7fAyIRozTvi7Au0fqcTsZNrlz8DMHYMCqTBXicfTLoj0zmSQnAjl2zuSqOpMwHLtOyexHgoUyyysawyqI1EHPj5l1W0kjPW18z0sgFNzOSjhu7wmIqrBPtcDgdRAJwYIDgfle6JPvy5ekgXvOHJlggMeGfgKyTxOHjU6K1WSyZrFyJW0kOUSZHabiYWexDYARq21OOlGeALMpJwY47mdLn5GA3IrekAlDsOZyyvB0swSZOyHqFmTclNqXiUcHa0IHHjbyHbjw7fopnjFPodVVifHCqnFgTKX3zgkBYb1UfJiu0w6KqNPiKZrFrpPO2z7mXVp4zUWbKC)YA89Pb8EgFFyAjCFA2tkEFeHI2Y9PzS9b33o89DlE8Djz2h29B4(4KJ17mXVVHYMCqTBXicfTLoj0z4zUWbKmctlH7mdLn5GA3IrekAlDsOZo6dVy8i0TRoH7mdLn5GA3IrekAlDsOZaqo2jtj2zuSqdtWbwzWONCzK4JUKW5ANzOSjhu7wmIqrBPtcD2LKn5edp0ZOAu0TyxskmODMHYMCqTBXicfTLoj05WllhSZmu2KdQDlgrOOT0jHodtRGafwENTZe)(cAWmmciz89zm4k09ZMI3phW7BOKu73W9nmSwA0swVZmu2KdkesKwfPzJANj(9dCIdWDMHYMCqNe6mnxqUC0hwXAVqAaVxJSyFinG7oZqztoOtcDgaYXozkXoJIfAycoWkdg9KlJeF0LeoxI1EHZPb8EnYI9H0aUIWjPMIqoFxSoBKJ(WkcNKAiW57I1zJC0hwrdNNMKVudtwkTk6LwXA(mAjJpnHtsnmzP0QOxAfRZg5OpSJ2zgkBYbDsOZybScVTls8rdtCrYbI1EHdNNMKVudtRKKcxZNrlz8PjAaVxdtRKKcxd4os0CAaVxJSyFinGRiCsQPiKZ3fRZg5OpSIWjPgcC(UyD2ih9Hv0W5Pj5l1WKLsRIEPvSMpJwY4tt4KudtwkTk6LwX6Sro6d7ODMHYMCqNe6maKJDYuIXEpJY4zuSquOijjlY1OiT0GPyTx4CAaVxJSyFinGRiCsQPiKZ3fRZg5OpSIWjPgcC(UyD2ih9Hv0W5Pj5l1WKLsRIEPvSMpJwY4tt4KudtwkTk6LwX6Sro6d7ODMHYMCqNe6maKJDYuIDgfleoOXGRig8rOIflBKyTx4CAaVxJSyFinGRO50aEVMwsi4sayQbCflTclNX2leNKA4GgdUIyWhHsdtd5qaHcYoZqztoOtcDgaYXozkXoJIfszx7zysIeFKYWpgcfR9cPb8EnYI9H0ftz9bfiOXMMOb8EnYI9H0ftz9bfiWerd49ARq21OOlGeALgMgYHaJ70KVXoiJftz9bduabTZmu2Kd6KqNPLecEK4J5aoYhtfQyTxiIqK4KWpnYI9H0ftz9bfqWJTZmu2Kd6KqNPyksfAK4JsauJhXl2OGI1EHZPb8EnYI9H0aUIgAWSmz0LeoxbkabzAcrisCs4NgzX(q6IPS(Gci4XgjcNKAiW57I1ftz9bfiOXeHtsnfHC(UyDXuwFqbcAmrdNNMKVudtwkTk6LwXA(mAjJpnHtsnmzP0QOxAfRlMY6dkqqJnANzOSjh0jHo7cuTp0(WgPLgm3zgkBYbDsOZv76k5yFrORH4DMHYMCqNe6mICi(YYsgp6LgfVZmu2Kd6KqNZbCe4OjahE0tkelw7fsd496IroKmeg9KcXAaxr4KutriNVlwNnYrFyfHtsne48DX6Sro6dROHZttYxQHjlLwf9sRynFgTKXNMWjPgMSuAv0lTI1zJC0h2r7mdLn5Goj05WjLehdUVyXqYzhI3zgkBYbDsOZEccaY4rdtC1jhPzJsS2lC4CmSQnAjRnmfHWPP50aEVgzX(qAa3rIWjPMIqoFxSoBKJ(WkcNKAiW57I1zJC0hwrdNNMKVudtwkTk6LwXA(mAjJpnHtsnmzP0QOxAfRZg5OpSJ2zgkBYbDsOZ5asDWDMHYMCqNe6maKJDYuqXAVqAaVxJSyFinG70KVXoiJftz9bduaJTZmu2Kd6KqNd3QQjvK4JSe44DM433qztoOtcDUVJlmSKfR9cnmXvNSw2yWYqJq3U6uZNrlzCrdreIeNe(P7dz1zztoDXuwFWafW0eIqK4KWpnILmmBtgnzJ9O4l1ftz9bduqbmANzOSjh0jHo3hYQZYMCI1EHZPb8EnYI9H0aUIgsd49AkMIuHgj(Oea14r8InkOgWDAA4qeHiXjHFAkMIuHgj(Oea14r8InkOUykRpOabm200Cgc5dXAkMIuHgj(Oea14r8InkOMYehj1irMBenGrogns0qAaVxtXuKk0iXhLaOgpIxSrb1aUttMBenGrogjcNKAiW57I1ftz9bfqCfHtsnfHC(UyDXuwFqbckardXjPgMSuAv0lTI1ftz9bfyCNMMNMKVudtwkTk6LwXA(mAjJpANzOSjh0jHoJyjdZ2Krt2ypk(sXAVW50aEVgzX(qAaxrdPb8EnftrQqJeFucGA8iEXgfud4onnCiIqK4KWpnftrQqJeFucGA8iEXgfuxmL1huGagBAAodH8HynftrQqJeFucGA8iEXgfutzIJKAKiZnIgWihJgjAioj1qGZ3fRlMY6dkqaIWjPMIqoFxSoBKJ(WkAioj1WKLsRIEPvSoBKJ(WonnpnjFPgMSuAv0lTI18z0sgF0ODMHYMCqNe6mt5scNRin5W3zgkBYbDsOZLHbFeay0x8HPq3zgkBYbDsOZEGk0iXhzjWXI1EHdPb8EnYI9H0aUtticrItc)0il2hsxmL1huabp2irHxwoqBUr0ag5yNzOSjh0jHo7jfIJeF8SeOyXAVWH0aEVgzX(qAa3PjeHiXjHFAKf7dPlMY6dkGGhBKiZnIgWih7SDM43h0LpCUG7mdLn5Goj0zKDiwgPb8EXoJIfctRKKcxS2lKgW71W0kjPW1ftz9bdKGfnp8YYbAZnIgWih7mdLn5Goj0zyAfeOWYI1EH0aEVMrY2fYrjWzLgWv0CAaVxZiz7c5Oe4SsZuUKW5IXNMOb8EnJKTlKJqI0knGRO50aEVMrY2fYrirALMPCjHZfJVZmu2Kd6KqNHPvEtkfR9chop8YYbAZnIgWihttdPb8EnmTsskCnmnKJaj4PjAaVxdtRKKcxxmL1huaHI7ird9n2bzSykRpOtbncZHUSugtRWYjuaebMJtaAbzKiOllLX0kSCcfqigw1gTK1qFmTclNWDMHYMCqNe6mmTccuyzXAVWHdttYxQHPvssHR5ZOLmUOH0aEVgMwjjfUgMgYrGe80enG3RHPvssHRlMY6dkGqbrenG3RTczxJIUasOvAyAihbsChnnnpnjFPgMwjjfUMpJwY4Igsd49ARq21OOlGeALgMgYrGe3PjAaVxJSyFinG7OrIgsd49AgjBxihHePvAaxr0aEVMrY2fYrjWzLgWDKiAaVxxmYHKHWONuioIiaxYLgMgYrGcA8MMOb8EDXihsgcJEsHynG7irqxwkJPvy5eQHPvEtkdegw1gTK1qFmTclNqrdNJHvTrlzTHPieonnNgW71il2hsd4onn3Tym0W0kiqHLhnn5BSdYyXuwFWajKXmmci5y2umMBWSmz0LeoxJtGn2008WllhOn3iAaJCSZmu2Kd6KqNHPvqGcllw7fAOSXGJ8Xunddegw1gTK1qFmTclNqrdPb8EnJKTlKJqI0kDXuwFqbqgmJztXtt0aEVMrY2fYrjWzLUykRpOaidMXSP4r7mdLn5Goj0ziW57IfR9cPb8EnYI9H0aUIOb8EnYI9H0ftz9bdeweUMYWmImmXvNSgMfBo6dBeMwb1LDoeHtsnfHC(UyDXuwFqbkMY6dUZmu2Kd6KqNPiKZ3flw7fsd49AKf7dPbCfrd49AKf7dPlMY6dgiSiCnLHzezyIRoznml2C0h2imTcQl7CSZ2zIFFXbsiWDMHYMCqNe6me48DXIHcfj5yAfwoHcdsS2lSyFXWbgTKfzUr0ag5qKxsi1W0kSCQZMIJjjI384mmamh6YszCGbtE0imh6YszmTclNqbeI4wo0ljKAyaJd0LLYyAfwoHJW8G0cYiNcaZHUSugtRWYju0qOllLX0kSCcfiiNstYxQZW7lsrihuZNrlz8PjCsQPiKZ3fRZg5OpSJenCUHjU6K1WSyZrFyJW0kOUSZX00CAaVxJSyFinG700C3IXqdboFx8irdPb8EnYI9H0ftz9bfOykRp400CAaVxJSyFinG7ODMHYMCqNe6mfHC(UyXqHIKCmTclNqHbjw7fwSVy4aJwYIm3iAaJCiYljKAyAfwo1ztXXKeXBECggaMdDzPmoWGjpAeMdDzPmMwHLtOachxrdNByIRoznml2C0h2imTcQl7CmnnNgW71il2hsd4onn3Tym0ueY57IhjAinG3RrwSpKUykRpOaftz9bNMMtd49AKf7dPbChTZmu2Kd6KqNHjlLwf9sRyXqHIKCmTclNqHbjw7fwSVy4aJwYIm3iAaJCiYljKAyAfwo1ztXXKeXBECggaMdDzPmoWGjpAKacferdNByIRoznml2C0h2imTcQl7CmnnNgW71il2hsd4onn3Tym0WKLsRIEPv8OD2ot87JzfFCzjPG7mdLn5Goj0ze5WG4GJ5aocD7Qt4oZqztoOtcD(4WJueYjw7fAUr0ag5yNzOSjh0jHopWK(ifHCI1EHMBenGro2zgkBYbDsOZEaPmsriNyTxO5grdyKJDMHYMCqNe6mmTY3flw7fAUr0ag5q0qAaVxZiz7c5Oe4SsxmL1huaKbZy2u80eKiTkYiz7czbgB0oZqztoOtcDo8YYbI1EHMBenGroenKgW71ms2UqocjsR0ftz9bfazWmMnfpnjboRIms2UqwGXgTZ2zIFFmRnPmhua77j1(uemyk(YDMHYMCqNe6me48DXkqOlJubh0ybOsvQu]] )


end