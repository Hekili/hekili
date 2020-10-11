-- DruidGuardian.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


-- Conduits
-- [x] savage_combatant
-- [ ] unchecked_aggression

-- Guardian Endurance
-- [-] layered_mane
-- [x] wellhoned_instincts


if UnitClassBase( "player" ) == "DRUID" then
    local spec = Hekili:NewSpecialization( 104 )

    spec:RegisterResource( Enum.PowerType.Rage, {
        oakhearts_puny_quods = {
            aura = "oakhearts_puny_quods",

            last = function ()
                local app = state.buff.oakhearts_puny_quods.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 10
        },

        raging_frenzy = {
            aura = "frenzied_regeneration",
            pvptalent = "raging_frenzy",

            last = function ()
                local app = state.buff.frenzied_regeneration.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 1,
            value = 10 -- tooltip says 60, meaning this would be 20, but NOPE.
        },

        thrash_bear = {
            aura = "thrash_bear",
            talent = "blood_frenzy",
            debuff = true,

            last = function ()
                return state.debuff.thrash_bear.applied + floor( state.query_time - state.debuff.thrash_bear.applied )
            end,

            interval = function () return class.auras.thrash_bear.tick_time end,
            value = function () return 2 * state.active_dot.thrash_bear end,
        }
    } )

    spec:RegisterResource( Enum.PowerType.LunarPower )
    spec:RegisterResource( Enum.PowerType.Mana )
    spec:RegisterResource( Enum.PowerType.ComboPoints )
    spec:RegisterResource( Enum.PowerType.Energy )


    -- Talents
    spec:RegisterTalents( {
        brambles = 22419, -- 203953
        blood_frenzy = 22418, -- 203962
        bristling_fur = 22420, -- 155835

        tiger_dash = 19283, -- 252216
        renewal = 18570, -- 108238
        wild_charge = 18571, -- 102401

        balance_affinity = 22163, -- 197488
        feral_affinity = 22156, -- 202155
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        heart_of_the_wild = 18577, -- 319454

        soul_of_the_forest = 21709, -- 158477
        galactic_guardian = 21707, -- 203964
        incarnation = 22388, -- 102558

        earthwarden = 22423, -- 203974
        survival_of_the_fittest = 21713, -- 203965
        guardian_of_elune = 22390, -- 155578

        rend_and_tear = 22426, -- 204053
        lunar_beam = 22427, -- 204066
        pulverize = 22425, -- 80313
    } )


    -- PvP Talents
    spec:RegisterPvpTalents( {
        alpha_challenge = 842, -- 207017
        charging_bash = 194, -- 228431
        demoralizing_roar = 52, -- 201664
        den_mother = 51, -- 236180
        entangling_claws = 195, -- 202226
        freedom_of_the_herd = 3750, -- 213200
        malornes_swiftness = 1237, -- 236147
        master_shapeshifter = 49, -- 236144
        overrun = 196, -- 202246
        raging_frenzy = 192, -- 236153
        roar_of_the_protector = 197, -- 329042
        sharpened_claws = 193, -- 202110
        toughness = 50, -- 201259
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
            duration = 3600,
            max_stack = 1,
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
        berserk = {
            id = 50334,
            duration = 15,
            max_stack = 1,
            copy = "berserk_bear"
        },
        bristling_fur = {
            id = 155835,
            duration = 8,
            max_stack = 1,
        },
        cat_form = {
            id = 768,
            duration = 3600,
            max_stack = 1,
        },
        convoke_the_spirits = {
            id = 323764,
            duration = 4,
            max_stack = 1,
        },
        dash = {
            id = 1850,
            duration = 10,
            max_stack = 1,
        },
        earthwarden = {
            id = 203975,
            duration = 3600,
            max_stack = 3,
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
            duration = 3600,
            max_stack = 1,
        },
        frenzied_regeneration = {
            id = 22842,
            duration = 3,
            max_stack = 1,
        },
        galactic_guardian = {
            id = 213708,
            duration = 15,
            max_stack = 1,
        },
        gore = {
            id = 93622,
            duration = 10,
            max_stack = 1,
        },
        growl = {
            id = 6795,
            duration = 3,
            max_stack = 1,
        },
        guardian_of_elune = {
            id = 213680,
            duration = 15,
            max_stack = 1,
        },
        heart_of_the_wild = {
            id = 319454,
            duration = 45,
            max_stack = 1,
            copy = { 319451, 319452, 319453 }
        },
        hibernate = {
            id = 2637,
            duration = 40,
            max_stack = 1,
        },
        immobilized = {
            id = 45334,
            duration = 4,
            max_stack = 1,
        },
        incapacitating_roar = {
            id = 99,
            duration = 3,
            max_stack = 1,
        },
        incarnation = {
            id = 102558,
            duration = 30,
            max_stack = 1,
            copy = "incarnation_guardian_of_ursoc"
        },
        intimidating_roar = {
            id = 236748,
            duration = 3,
            max_stack = 1,
        },
        ironfur = {
            id = 192081,
            duration = function () return buff.guardian_of_elune.up and 9 or 7 end,
            max_stack = 5,
        },
        lightning_reflexes = {
            id = 231065,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            type = "Magic",
            max_stack = 1,
        },
        mighty_bash = {
            id = 5211,
            duration = 4,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = function () return mod_circle_dot( 16 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            type = "Magic",
            max_stack = 1,
        },
        moonkin_form = {
            id = 197625,
            duration = 3600,
            max_stack = 1,
        },
        prowl = {
            id = 5215,
            duration = 3600,
            max_stack = 1,
        },
        pulverize = {
            id = 80313,
            duration = 10,
            max_stack = 1,
        },
        rake = {
            id = 155722,
            duration = 15,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = function () return mod_circle_hot( 12 ) end,
            type = "Magic",
            max_stack = 1,
        },
        rejuvenation = {
            id = 774,
            duration = function () return mod_circle_hot( 15 ) end,
            tick_time = function () return mod_circle_hot( 3 ) * haste end,
            max_stack = 1,
        },
        soulshape = {
            id = 310143,
            duration = 3600,
            max_stack = 1,
        },
        stampeding_roar = {
            id = 77761,
            duration = 8,
            max_stack = 1,
        },
        sunfire = {
            id = 164815,
            duration = function () return mod_circle_dot( 12 ) end,
            tick_time = function () return mod_circle_dot( 2 ) * haste end,
            max_stack = 1,
            type = "Magic",
        },
        survival_instincts = {
            id = 61336,
            duration = 6,
            max_stack = 1,
        },
        thick_hide = {
            id = 16931,
        },
        thrash_bear = {
            id = 192090,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function () return mod_circle_dot( 3 ) * haste end,
            max_stack = function () return legendary.luffainfused_embrace and 4 or 3 end,
        },
        thrash_cat = {
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
        tooth_and_claw = {
            id = 135286,
            duration = 15,
            max_stack = 2
        },
        travel_form = {
            id = 783,
            duration = 3600,
            max_stack = 1,
        },
        typhoon = {
            id = 61391,
            duration = 6,
            max_stack = 1,
            type = "Magic",
        },
        ursols_vortex = {
            id = 127797,
            duration = 3600,
            max_stack = 1,
        },
        wild_charge = {
            id = 102401,
            duration = 0.5,
            max_stack = 1,
        },
        wild_growth = {
            id = 48438,
            duration = 7,
            max_stack = 1,
        },
        yseras_gift = {
            id = 145108,
        },


        -- PvP Talents
        demoralizing_roar = {
            id = 201664,
            duration = 8,
            max_stack = 1,
        },

        den_mother = {
            id = 236181,
            duration = 3600,
            max_stack = 1,
        },

        focused_assault = {
            id = 206891,
            duration = 6,
            max_stack = 1,
        },

        master_shapeshifter_feral = {
            id = 236188,
            duration = 3600,
            max_stack = 1,
        },

        overrun = {
            id = 202244,
            duration = 3,
            max_stack = 1,
        },

        protector_of_the_pack = {
            id = 201940,
            duration = 3600,
            max_stack = 1,
        },

        sharpened_claws = {
            id = 279943,
            duration = 6,
            max_stack = 1,
        },

        -- Azerite
        masterful_instincts = {
            id = 273349,
            duration = 30,
            max_stack = 1,
        },

        -- Legendary
        lycaras_fleeting_glimpse = {
            id = 340060,
            duration = 5,
            max_stack = 1
        },
        ursocs_fury_remembered = {
            id = 345048,
            duration = 15,
            max_stack = 1,
        },
    } )


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
    end )

    spec:RegisterStateExpr( "ironfur_damage_threshold", function ()
        return ( settings.ironfur_damage_threshold or 0 ) / 100 * ( health.max )
    end )


    -- Gear.
    spec:RegisterGear( "class", 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )
    spec:RegisterGear( "tier19", 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( "tier20", 147136, 147138, 147134, 147133, 147135, 147137 ) -- Bonuses NYI
    spec:RegisterGear( "tier21", 152127, 152129, 152125, 152124, 152126, 152128 )

    spec:RegisterGear( "ailuro_pouncers", 137024 )
    spec:RegisterGear( "behemoth_headdress", 151801 )
    spec:RegisterGear( "chatoyant_signet", 137040 )
    spec:RegisterGear( "dual_determination", 137041 )
    spec:RegisterGear( "ekowraith_creator_of_worlds", 137015 )
    spec:RegisterGear( "elizes_everlasting_encasement", 137067 )
    spec:RegisterGear( "fiery_red_maimers", 144354 )
    spec:RegisterGear( "lady_and_the_child", 144295 )
    spec:RegisterGear( "luffa_wrappings", 137056 )
    spec:RegisterGear( "oakhearts_puny_quods", 144432 )
        spec:RegisterAura( "oakhearts_puny_quods", {
            id = 236479,
            duration = 3,
            max_stack = 1,
        } )
    spec:RegisterGear( "skysecs_hold", 137025 )
        spec:RegisterAura( "skysecs_hold", {
            id = 208218,
            duration = 3,
            max_stack = 1,
        } )

    spec:RegisterGear( "the_wildshapers_clutch", 137094 )

    spec:RegisterGear( "soul_of_the_archdruid", 151636 )


    spec:RegisterStateExpr( "lunar_eclipse", function ()
        return 0
    end )

    spec:RegisterStateExpr( "solar_eclipse", function ()
        return 0
    end )

    spec:RegisterHook( "reset_precast", function ()
        if azerite.masterful_instincts.enabled and buff.survival_instincts.up and buff.masterful_instincts.down then
            applyBuff( "masterful_instincts", buff.survival_instincts.remains + 30 )
        end

        -- Eclipses
        solar_eclipse = buff.eclipse_lunar.up and 2 or GetSpellCount( 197628 )
        lunar_eclipse = buff.eclipse_solar.up and 2 or GetSpellCount( 5176 )
    end )


    spec:RegisterHook( "runHandler", function( ability )
        local a = class.abilities[ ability ]

        if not a or a.startsCombat then
            break_stealth()
        end

        if buff.ravenous_frenzy.up and ability ~= "ravenous_frenzy" then
            addStack( "ravenous_frenzy", nil, 1 )
        end
    end )


    spec:RegisterStateTable( "druid", setmetatable( {
    }, {
        __index = function( t, k )
            if k == "catweave_bear" then
                return settings.catweave_bear
            elseif k == "owlweave_bear" then
                return settings.owlweave_bear
            end
        end
    } ) )


    -- Abilities
    spec:RegisterAbilities( {
        alpha_challenge = {
            id = 207017,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            pvptalent = "alpha_challenge",

            startsCombat = true,
            texture = 132270,

            handler = function ()
                applyDebuff( "target", "focused_assault" )
            end,
        },


        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = function () return ( talent.survival_of_the_fittest.enabled and 40 or 60 ) * ( 1 + ( conduit.tough_as_bark.mod * 0.01 ) ) end,
            gcd = "off",

            startsCombat = false,
            texture = 136097,

            toggle = "defensives",
            defensive = true,

            usable = function ()
                if not tanking then return false, "player is not tanking right now"
                elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
                return true
            end,
            handler = function ()
                applyBuff( "barkskin" )

                if legendary.the_natural_orders_will.enabled and buff.bear_form.up then
                    applyBuff( "ironfur" )
                    applyBuff( "frenzied_regeneration" )
                end
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

            essential = true,
            noform = "bear_form",

            handler = function ()
                shift( "bear_form" )
                if conduit.ursine_vigor.enabled then applyBuff( "ursine_vigor" ) end
            end,
        },


        berserk = {
            id = 50334,
            cast = 0,
            cooldown = function () return legendary.legacy_of_the_sleeper.enabled and 150 or 180 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 236149,

            notalent = "incarnation",

            handler = function ()
                applyBuff( "berserk" )
            end,

            copy = "berserk_bear"
        },


        bristling_fur = {
            id = 155835,
            cast = 0,
            cooldown = 40,
            gcd = "spell",

            startsCombat = false,
            texture = 1033476,

            talent = "bristling_fur",

            usable = function ()
                if incoming_damage_3s < health.max * 0.1 then return false, "player has not taken 10% health in dmg in 3s" end
                return true
            end,
            handler = function ()
                applyBuff( "bristling_fur" )
            end,
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
                if pvptalent.master_shapeshifter.enabled and talent.feral_affinity.enabled then
                    applyBuff( "master_shapeshifter_feral" )
                end
            end,
        },


        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 132120,

            notalent = "tiger_dash",

            handler = function ()
                applyBuff( "dash" )
            end,
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
            gcd = "spell",

            startsCombat = false,
            texture = 132120,

            handler = function ()
                shift( "cat_form" )
                applyBuff( "dash" )
            end,
        },


        demoralizing_roar = {
            id = 201664,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            pvptalent = "demoralizing_roar",

            startsCombat = true,
            texture = 132117,

            handler = function ()
                applyDebuff( "demoralizing_roar" )
                active_dot.demoralizing_roar = active_enemies
            end,
        },


        entangling_roots = {
            id = 339,
            cast = 1.7,
            cooldown = 0,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 136100,

            handler = function ()
                applyDebuff( "target", "entangling_roots" )
            end,
        },


        --[[ ferocious_bite = {
            id = 22568,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function () return args.max_energy == 1 and 50 or 25 end,
            spendType = "energy",

            startsCombat = true,
            texture = 132127,

            form = "cat_form",

            usable = function ()
                if combo_points.current == 0 then return false, "player has no combo points" end
                return true
            end,

            handler = function ()
                spend( min( 5, combo_points.current ), "combo_points" )
            end,
        }, ]]


        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = 2,
            cooldown = function () return buff.berserk.up and ( level > 57 and 9 or 18 ) or 36 end,
            recharge = function () return buff.berserk.up and ( level > 57 and 9 or 18 ) or 36 end,
            hasteCD = true,
            gcd = "spell",

            spend = 10,
            spendType = "rage",

            startsCombat = false,
            texture = 132091,

            toggle = "defensives",
            defensive = true,

            form = "bear_form",
            nobuff = "frenzied_regeneration",

            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( health.max * 0.08, "health" )
            end,

            auras = {
                -- Conduit (ICD)
                wellhoned_instincts = {
                    id = 340556,
                    duration = function ()
                        if conduit.wellhoned_instincts.enabled then return conduit.wellhoned_instincts.mod end
                        return 90
                    end,
                    max_stack = 1
                }
            }
        },


        growl = {
            id = 6795,
            cast = 0,
            cooldown = function () return buff.berserk.up and ( level > 57 and 2 or 4 ) or 8 end,
            gcd = "spell",

            nopvptalent = "alpha_challenge",

            startsCombat = true,
            texture = 132270,

            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },


        heart_of_the_wild = {
            id = 319454,
            cast = 0,
            cooldown = function () return 300 * ( 1 - ( conduit.born_of_the_wilds.mod * 0.01 ) ) end,
            gcd = "spell",

            toggle = "cooldowns",

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

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 136090,

            handler = function ()
                applyDebuff( "target", "hibernate" )
            end,
        },


        incapacitating_roar = {
            id = 99,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 132121,

            handler = function ()
                applyDebuff( "target", "incapacitating_roar" )
            end,
        },


        incarnation = {
            id = 102558,
            cast = 0,
            cooldown = function () return legendary.legacy_of_the_sleeper.enabled and 150 or 180 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 571586,

            talent = "incarnation",

            handler = function ()
                applyBuff( "incarnation" )
            end,

            copy = { "incarnation_guardian_of_ursoc", "Incarnation" }
        },


        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "off",

            spend = function () return buff.berserk.up and 20 or 40 end,
            spendType = "rage",

            startsCombat = false,
            texture = 1378702,

            toggle = "defensives",
            defensive = true,

            form = "bear_form",

            usable = function ()
                if not tanking then return false, "player is not tanking right now"
                elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
                return true
            end,

            handler = function ()
                applyBuff( "ironfur" )
                removeBuff( "guardian_of_elune" )
            end,
        },


        lunar_beam = {
            id = 204066,
            cast = 0,
            cooldown = 75,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = true,
            texture = 136057,

            talent = "lunar_beam",

            handler = function ()
                applyBuff( "lunar_beam" )
            end,

            auras = {
                lunar_beam = {
                    duration = 8,
                    max_stack = 1,

                    generate = function( t )
                        local applied = action.lunar_beam.lastCast

                        if not t.name then t.name = class.auras.lunar_beam.name end

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
                },
            }
        },


        maim = {
            id = 22570,
            cast = 0,
            cooldown = 20,
            gcd = "spell",

            spend = 30,
            spendType = "energy",

            startsCombat = true,
            texture = 132134,

            talent = "feral_affinity",
            form = "cat_form",

            usable = function () return combo_points.current > 0, "requires combo_points" end,

            handler = function ()
                applyDebuff( "target", "maim", combo_points.current )
                spend( combo_points.current, "combo_points" )
            end,
        },


        mangle = {
            id = 33917,
            cast = 0,
            cooldown = function () return buff.berserk.up and ( level > 57 and 1.5 or 3 ) or 6 end,
            gcd = "spell",

            spend = function () return buff.gore.up and -19 or -15 end,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            form = "bear_form",

            handler = function ()
                if talent.guardian_of_elune.enabled then applyBuff( "guardian_of_elune" ) end
                removeBuff( "gore" )

                if conduit.savage_combatant.enabled then addStack( "savage_combatant", nil, 1 ) end
            end,

            auras = {
                -- Conduit
                savage_combatant = {
                    id = 340613,
                    duration = 15,
                    max_stack = 3
                }
            }
        },


        mass_entanglement = {
            id = 102359,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = false,
            texture = 538515,

            talent = "mass_entanglement",

            handler = function ()
                applyDebuff( "target", "mass_entanglement" )
            end,
        },


        maul = {
            id = 6807,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "rage",

            startsCombat = true,
            texture = 132136,

            form = "bear_form",

            usable = function ()
                if settings.maul_rage > 0 and rage.current - cost < settings.maul_rage then return false, "not enough additional rage" end
                return true
            end,

            handler = function ()
                if pvptalent.sharpened_claws.enabled or essence.conflict_and_strife.major then applyBuff( "sharpened_claws" ) end
                removeBuff( "savage_combatant" )
            end,
        },


        mighty_bash = {
            id = 5211,
            cast = 0,
            cooldown = 60,
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

            spend = 0.06,
            spendType = "mana",

            startsCombat = true,
            texture = 136096,

            handler = function ()
                applyDebuff( "target", "moonfire" )

                if buff.galactic_guardian.up then
                    gain( 8, "rage" )
                    removeBuff( "galactic_guardian" )
                end
            end,
        },


        moonkin_form = {
            id = 197625,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 136036,

            noform = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                shift( "moonkin_form" )
            end,
        },


        overrun = {
            id = 202246,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 1408833,

            pvptalent = "overrun",

            handler = function ()
                applyDebuff( "target", "overrun" )
                setDistance( 5 )
            end,
        },


        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = false,
            texture = 514640,

            usable = function ()
                if time > 0 and not boss then return false, "cannot stealth in combat"
                elseif buff.prowl.up then return false, "player is already prowling" end
                return true
            end,

            handler = function ()
                shift( "cat_form" )
                applyBuff( "prowl" )
            end,
        },


        pulverize = {
            id = 80313,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 1033490,

            talent = "pulverize",
            form = "bear_form",

            usable = function ()
                if debuff.thrash_bear.stack < 2 then return false, "target has fewer than 2 thrash stacks" end
                return true
            end,

            handler = function ()
                if debuff.thrash_bear.count > 2 then debuff.thrash_bear.count = debuff.thrash_bear.count - 2
                else removeDebuff( "target", "thrash_bear" ) end
                applyBuff( "pulverize" )
            end,
        },


        --[[ rake = {
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
                debuff.rake.pmultiplier = persistent_multiplier

                gain( 1, "combo_points" )
            end,
        }, ]]


        --[[ rebirth = {
            id = 20484,
            cast = 2,
            cooldown = 600,
            gcd = "spell",

            spend = 0,
            spendType = "rage",

            startsCombat = true,
            texture = 136080,

            handler = function ()
            end,
        }, ]]


        regrowth = {
            id = 8936,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.14,
            spendType = "mana",

            startsCombat = false,
            texture = 136085,

            talent = "restoration_affinity",
            usable = function ()
                if not ( buff.bear_form.down and buff.cat_form.down and buff.travel_form.down and buff.moonkin_form.down ) then return false, "player is in a form" end
                return true
            end,

            handler = function ()
                applyBuff( "regrowth" )
            end,
        },


        rejuvenation = {
            id = 774,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = false,
            texture = 136081,

            talent = "restoration_affinity",

            usable = function ()
                if not ( buff.bear_form.down and buff.cat_form.down and buff.travel_form.down and buff.moonkin_form.down ) then return false, "player is in a form" end
                return true
            end,
            handler = function ()
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

            startsCombat = false,
            texture = 135952,

            usable = function ()
                if buff.dispellable_poison.down and buff.dispellable_curse.down then return false, "player has no dispellable auras" end
                return true
            end,
            handler = function ()
                removeBuff( "dispellable_poison" )
                removeBuff( "dispellable_curse" )
            end,
        },


        renewal = {
            id = 108238,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "defensives",
            defensive = true,

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


        --[[ rip = {
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

            usable = function ()
                if combo_points.current == 0 then return false, "player has no combo points" end
                return true
            end,

            handler = function ()
                applyDebuff( "target", "rip" )
            end,
        }, ]]


        --[[ shred = {
            id = 5221,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 40,
            spendType = "energy",

            startsCombat = true,
            texture = 136231,

            handler = function ()
            end,
        }, ]]


        skull_bash = {
            id = 106839,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 236946,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
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

            debuff = "dispellable_enrage",

            handler = function ()
                removeDebuff( "target", "dispellable_enrage" )
            end,
        },


        stampeding_roar = {
            id = 106898,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = false,
            texture = 464343,

            handler = function ()
                applyBuff( "stampeding_roar" )
                if buff.bear_form.down and buff.cat_form.down then
                    shift( "bear_form" )
                end
            end,
        },


        --[[ starfire = {
            id = 197628,
            cast = 2.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135753,

            talent = "balance_affinity",
            form = "moonkin_form",

            handler = function ()
            end,
        }, ]]


        starsurge = {
            id = 197626,
            cast = function () return buff.heart_of_the_wild.up and 0 or 2 end,
            cooldown = 10,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135730,

            talent = "balance_affinity",
            form = "moonkin_form",

            handler = function ()
                addStack( "lunar_empowerment" )
                addStack( "solar_empowerment" )
            end,
        },


        sunfire = {
            id = 197630,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0.12,
            spendType = "mana",

            startsCombat = true,
            texture = 236216,

            talent = "balance_affinity",
            form = "moonkin_form",

            handler = function ()
                applyDebuff( "target", "sunfire" )
                active_dot.sunfire = active_enemies
            end,
        },


        survival_instincts = {
            id = 61336,
            cast = 0,
            charges = 2,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( talent.survival_of_the_fittest.enabled and ( 2/3 ) or 1 ) * 180 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( talent.survival_of_the_fittest.enabled and ( 2/3 ) or 1 ) * 180 end,
            gcd = "off",

            startsCombat = false,
            texture = 236169,

            toggle = "defensives",
            defensive = true,

            usable = function ()
                if not tanking then return false, "player is not tanking right now"
                elseif incoming_damage_3s == 0 then return false, "player has taken no damage in 3s" end
                return true
            end,

            handler = function ()
                applyBuff( "survival_instincts" )

                if azerite.masterful_instincts.enabled and buff.survival_instincts.up and buff.masterful_instincts.down then
                    applyBuff( "masterful_instincts", buff.survival_instincts.remains + 30 )
                end
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
            toggle = "defensives",
            defensive = true,

            usable = function ()
                return IsSpellUsable( 18562 ) or buff.regrowth.up or buff.wild_growth.up or buff.rejuvenation.up, "requires a HoT"
            end,

            handler = function ()
                unshift()
                if buff.regrowth.up then removeBuff( "regrowth" )
                elseif buff.wild_growth.up then removeBuff( "wild_growth" )
                elseif buff.rejuvenation.up then removeBuff( "rejuvenation" ) end
            end,
        },


        swipe_bear = {
            id = 213771,
            known = 213764,
            suffix = "(Bear)",
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 134296,

            form = "bear_form",

            handler = function ()
            end,

            copy = { "swipe", 213764 },
            bind = { "swipe_bear", "swipe_cat", "swipe" }
        },


        --[[ teleport_moonglade = {
            id = 18960,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 4,
            spendType = "mana",

            startsCombat = true,
            texture = 135758,

            handler = function ()
            end,
        }, ]]


        thrash_bear = {
            id = 77758,
            known = 106832,
            suffix = "(Bear)",
            cast = 0,
            cooldown = function () return buff.berserk.up and ( level > 57 and 1.5 or 3 ) or 6 end,
            gcd = "spell",

            spend = -5,
            spendType = "rage",

            startsCombat = true,
            texture = 451161,

            form = "bear_form",
            bind = "thrash",

            handler = function ()
                applyDebuff( "target", "thrash_bear", 15, debuff.thrash_bear.count + 1 )
                active_dot.thrash_bear = active_enemies

                if legendary.ursocs_fury_remembered.enabled then
                    applyBuff( "ursocs_fury_remembered" )
                end
            end,
        },


        tiger_dash = {
            id = 252216,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = false,
            texture = 1817485,

            talent = "tiger_dash",

            handler = function ()
                applyBuff( "tiger_dash" )
            end,
        },


        travel_form = {
            id = 783,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 132144,

            handler = function ()
                shift( "travel_form" )
            end,
        },


        typhoon = {
            id = 132469,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 236170,

            talent = "balance_affinity",

            handler = function ()
                if target.distance < 15 then
                    applyDebuff( "target", "typhoon" )
                end
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
                applyDebuff( "target", "ursols_vortex" )
            end,
        },


        wild_charge = {
            id = function ()
                if buff.bear_form.up then return 16979
                elseif buff.cat_form.up then return 49376
                elseif buff.moonkin_form.up then return 102383 end
                return 102401
            end,
            known = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            -- texture = 538771,

            talent = "wild_charge",

            usable = function () return target.exists and target.distance > 7, "target must be 8+ yards away" end,

            handler = function ()
                if buff.bear_form.up then target.distance = 5; applyDebuff( "target", "immobilized" )
                elseif buff.cat_form.up then target.distance = 5; applyDebuff( "target", "dazed" ) end
            end,

            copy = { 49376, 16979, 102401, 102383 }
        },


        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",

            spend = 0.22,
            spendType = "mana",

            startsCombat = false,
            texture = 236153,

            handler = function ()
                applyBuff( "wild_growth" )
            end,
        },


        --[[ wrath = {
            id = 5176,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.01,
            spendType = "mana",

            startsCombat = true,
            texture = 535045,

            handler = function ()
                if buff.moonkin_form.down then unshift() end
                removeStack( "solar_empowerment" )
            end,
        }, ]]
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 6,

        potion = "focused_resolve",

        package = "Guardian",
    } )

    spec:RegisterSetting( "maul_rage", 20, {
        name = "Excess Rage for |T132136:0|t Maul",
        desc = "If set above zero, the addon will recommend |T132136:0|t Maul only if you have at least this much excess Rage.",
        type = "range",
        min = 0,
        max = 60,
        step = 0.1,
        width = 1.5
    } )

    spec:RegisterSetting( "ironfur_damage_threshold", 5, {
        name = "Required Damage % for |T1378702:0|t Ironfur",
        desc = "If set above zero, the addon will not recommend |T1378702:0|t Ironfur unless your incoming damage for the past 5 seconds is greater than this percentage of your maximum health.",
        type = "range",
        min = 0,
        max = 100,
        step = 0.1,
        width = 1.5
    } )

    spec:RegisterSetting( "catweave_bear", false, {
        name = "|T132115:0|t Attempt Catweaving (Experimental)",
        desc = "If checked, the addon will use the experimental |cFFD100catweave|r priority included in the default action priority.",
        type = "toggle",
        width = "full",
    } )

    spec:RegisterSetting( "owlweave_bear", false, {
        name = "|T136036:0|t Attempt Owlweaving (Experimental)",
        desc = "If checked, the addon will use the experimental |cFFD100owlweave|r priority included in the default action priority.",
        type = "toggle",
        width = "full"
    } )    

    spec:RegisterPack( "Guardian", 20201011, [[dC0afbqisu9iOeUejkfBckgLuXPKkTkPa8kqLzbL6wqjsTls9lvPgMuOJbQAzIIEMQennPGUgusBtkG(gjkmosu05KcuRdkrY8efUNQyFQs6GKOK0cjHEijkXeLcKCrsusTrsus8rOerNukqSsrPBsIs1obf)KeLsdvkqQNcYubL2lK)sXGP0HjwSIEmQMScxgzZu5ZqLrlLoTWQHseEnjy2ICBsA3Q8BGHlvDCvjy5k9CQA6sUUQA7qvFxunEOe15jrwVQeA(sr7hLrWJGfbnKIqWKzJz2i8ncp8A4XAJW3qeuPupHG6fUccocbDIkHGWs(LDeYHG6fLsazGGfb5b)LtiO2Q69yPE)gxuT)PMduF7d1FsQaC8vC1BFOYFJGM)ivnihAIGgsriyYSXmBe(gHhEn8yTr4H)Lii5xTGfbbfQkliO2ymOdnrqdYZrqybZIL8l7iKJzBqT)yWYIfmRYwEbM0YSWdp2mBMnMzJSSSSybZQS0khoYJLILflywS0mBdYXbBpyLIywLfPERSdaNcXXS9Ba2OcYZSDchZ6PQIdhZgEML3sCfOrxnckf(YJGfbLuIlRaqWIGbEeSiiHxb4qqQaWPqCghyvrq0jZenqkIkuHGMKSiyrWapcweeDYmrdKIii(gfTHGGuoZo)oNEsYACGvv)7rqcVcWHGMKSghyvrfcMmrWIGOtMjAGuebX3OOneeuhMTdZo)oNEsRNwfmtsw9VNzB2KzNFNthhx2tQaCgCFzhHCgGZ8xpGR)9mBxMfdZ2HzvoZo2Fm0CPYjbpzMKSmlgMv5m7y)XqdYt5KGNmtswMTlZ2fbj8kahcQhub4qfcMxIGfbj8kahcAf80b(EJBP7fvcbrNmt0aPiQqW0qeSii6KzIgifrq8nkAdbbPCMDS)yO5sLtcEYmjzzwmmRYz2X(JHgKNYjbpzMKSiiHxb4qqCWHhOazQwY47JnkpQqWGveSii6KzIgifrq8nkAdbb1HzNFNtVcE6aFVXT09IkP)9mBZMmRYzwoapDYvA80vTkTmBxeKWRaCiOjTEAvaviyAGiyrq0jZenqkIG4Bu0gccQdZo)oNEf80b(EJBP7fvs)7z2MnzwLZSCaE6KR04PRAvAz2UiiHxb4qqXXL9KkahQqWOmqWIGOtMjAGuebX3OOneeuhMv5m7y)XqZLkNe8KzsYYSyywLZSJ9hdnipLtcEYmjzz2UmBZMmRWRapzOJudYZSV(WSzIGeEfGdbrQ9GCAntWnqfcgLjcweeDYmrdKIii(gfTHGG6WSLKOR0ZvuNjYRPtMjAWSDzwmmBhMD(Do9KK14aRQ(3ZSDrqcVcWHGMYQGxH4qfcMgmcweeDYmrdKIii(gfTHGGMFNthl4C)vVKQeNNzZGzBuJveKWRaCiOybN7VOcbd8nIGfbrNmt0aPics4vaoeKmK(kWtgFUSQii(gfTHGGwYTKVvMjcbXvINitjloQ8iyGhviyGhEeSii6KzIgifrq8nkAdbb1HzNFNtJtscVcUb3x2riN(3ZSyy2X(JHgKNYjbpzMKSmBxMfdZk8kWtg6i1G8mBgpm7lrqcVcWHGubGZflHkemWNjcweeDYmrdKIiiHxb4qqv7k(wZKKfbX3OOnee0sUL8TYmrmBZMm7au6QDfFRzsYQ9LWvGzZGzFjZ2SjZ2HzhGsxTR4BntswTVeUcmBgmBdzwmm7(pYbwCKo9Dojo33tddPoxHtA6f(rFpny2UmBZMmRWRapzOJudYZSVYSyfbXvINitjloQ8iyGhviyG)Liyrq0jZenqkIG4Bu0gccA(DoDCCzpPcWzW9LDeYzaoZF9aUEaYpMfdZo)oNEsRNwfmtsw9aKFmlgMv4vGNm0rQb5z2xFy2gIGeEfGdb5ZJEYmjzrfcg4BicweeDYmrdKIii(gfTHGGMFNthhx2tQaC6FpZIHzfEf4jdDKAqEMndMnteKWRaCiiv5Nqfcg4XkcweeDYmrdKIii(gfTHGG6WSZVZP9cEbhz4a1PuYvAFjCfy2xFyw4z2UmlgMTdZo)oNUaGQ1i3WWtsU(3ZSDzwmm787C644YEsfGt)7zwmmRWRapzOJudYZSpmBMiiHxb4qqQYpHkemW3arWIGOtMjAGuebX3OOnee087C644YEsfGt)7zwmmRWRapzOJudYZSz8WSVebj8kahcsvoCjcviyGxzGGfbrNmt0aPics4vaoeKkaCUyjeeFJI2qqql5wY3kZeXSyywHxbEYqhPgKNzZ4HzFjcIReprMswCu5rWapQqWaVYeblcIozMObsreeFJI2qqqDy25350fauTg5ggEsY1(s4kWSV(WSzYSDz2Mnz2om787C6caQwJCddpj56FpZIHzNFNtxaq1AKBy4jjxVKQeNNzZGzHxJvMTlZ2SjZ2HzNFNt7f8coYWbQtPKR0(s4kWSV(WSVKz7IGeEfGdbPk)eQqWaFdgblcIozMObsreeFJI2qqqcVc8KHosnipZ(kZcpcs4vaoeu1UIV1mjzrfcMmBeblcIozMObsreeFJI2qqqDy253504KKWRGBW9LDeYP)9mlgMDS)yO5sLtcEYmjzz2UmlgMv4vGNm0rQb5z2mEy2xYSnBYSDy253504KKWRGBW9LDeYP)9mlgMv5m7y)XqZLkNe8KzsYYSyywLZSJ9hdnipLtcEYmjzz2UmlgMv4vGNm0rQb5z2mEy2xIGeEfGdbPcaNlwcviyYeEeSii6KzIgifrq8nkAdbb1HzxbhXSzWSkZgz2UmlgMv4vGNm0rQb5z2my2gIGeEfGdbPkhUeHkemzMjcweeDYmrdKIiiHxb4qq9)eEAJxKqq8nkAdbbnaLUAxX3AMKSAFjCfy2xz2mrqCL4jYuYIJkpcg4rfcMmFjcweKWRaCiOQDfFRzsYIGOtMjAGueviyYSHiyrqcVcWHGuLFcbrNmt0aPiQqWKjwrWIGeEfGdb5ZJEYmjzrq0jZenqkIkuHGuJkWjvaoeSiyGhblcIozMObsreeFJI2qqqXXbQXHZmevbhzWQNzFLzJfCU)AgIQGJmv7s(wqAWSyy25350Xco3F1lPkX5z2my2xYSnaMTv8fHGeEfGdbfl4C)fviyYeblcIozMObsreeFJI2qqqTKKQwn)VlDfZMbZ2OwzGvMTbWSTKKQwTQGLrqcVcWHGClDVyqdZs4OJwPcWHkemVeblcIozMObsreeFJI2qqqfahUePhKJoFGN8mlgMTLKu1Q75fZMbZQmBebj8kahcsUqvmaNzqs1IkemneblcIozMObsreeFJI2qqqDy2ss0v65kQZe510jZeny2UmlgMTdZo)oNEsYACGvv)7z2UmlgMTLKu1Q75fZMbZQmWkZIHzJJduJdNziQcoYGvpZ(kZ2OotSYSnaMTLKu1QvfSmcs4vaoe0uwf8kehQqWGveSii6KzIgifrq8nkAdbbn)oN2)x8bEjzIZxXXlVEaYpMfdZo)oNEkRcEfItpa5hZIHzBjjvT6EEXSzWSnWgzwmmBCCGAC4mdrvWrgS6z2xz2g1zIvMTbWSTKKQwTQGLrqcVcWHG8)fFGxsM48vC8YJkuHGskXLv4iyrWapcweKWRaCiiUughyvrq0jZenqkIkuHGgKt(Pcblcg4rWIGeEfGdb5v4NsMP4Brq0jZenqkIkemzIGfbj8kahc67jtuKQhbrNmt0aPiQqW8seSii6KzIgifrq8nkAdbb1Hz7WSLKOR0TKSLb4mvlzYJ0qtNmt0GzXWSZVZPBjzldWzQwYKhPH(3ZSDzwmmBhMDS)yO5sLtcEYmjzz2Mnz2X(JHgKNYjbpzMKSmBxMTlcs4vaoeupOcWHkemneblcIozMObsreeFJI2qqqJ9hdnxQCsWtMjjlZIHz7WSDywoaKgG8txTR4Bntsw9sQsCEM9vMTrMfdZYbG0aKFAv5WLi9sQsCEM9vMTrMfdZoaLwfaoxSKEjvjopZ(6dZIJpyw4y2g1yLzXWSRGJy2my2g2iZIHzNFNthhx2tQaCgCFzhHCgGZ8xpGRhG8JzXWSZVZPN06PvbZKKvpa5hZIHzNFNtJtscVcUb3x2riNEaYpMTlZ2SjZ2HzNFNtZLY4aRQ(3ZSyyw6OfNsm7RmBMyLz7YSnBYSDy29FKdS4inqQwdWzQwYqPbTMX(JHMEHF03tdMfdZQCMD(DonqQwdWzQwYqPbTMX(JH(3ZSyy2om787CAUughyv1)EMfdZshT4uIzFLzZSrMTlZ2LzB2Kz7WS7)ihyXrAGuTgGZuTKHsdAnJ9hdn9c)OVNgmlgMD(DoDljBzaot1sM8in0lPkX5z2myw4BKz7YSyy2om787CAUughyv1)EMfdZshT4uIzFLzZSrMTlZ2SjZ2Hz5a80jxPvqPnKJzXWSCaina5NMu7b50AMGBOxsvIZZSz8WSWZSyywHxbEYqhPgKNzZGzZKz7YSDrqcVcWHG2)zeEfGZKcFHGsHVmNOsiiUu5KGNqfcgSIGfbrNmt0aPicIVrrBiiOX(JHgKNYjbpzMKSmlgMTdZ2Hz5aqAaYpD1UIV1mjz1lPkX5z2xz2gzwmmlhasdq(PvLdxI0lPkX5z2xz2gzwmm7k4iMndMnZgzwmm787C644YEsfGtpa5hZIHzNFNtpP1tRcMjjREaYpMTlZ2SjZ2HzNFNtRcaNcXzCGvv)7zwmm7auA))CXs6LCl5BLzIy2UmBZMmBhMD(DoTkaCkeNXbwv9VNzXWSZVZPBjzldWzQwYKhPH(3ZSDz2Mnz2om787CAva4uioJdSQ6FpZIHz7WSZVZPjEk69Kj9pz1)EMTztMD(DonXtrVNmEqsw9VNz7YSyywLZS7)ihyXrAGuTgGZuTKHsdAnJ9hdn9c)OVNgmBxMTztMTdZU)JCGfhPbs1Aaot1sgknO1m2Fm00l8J(EAWSyywLZSZVZPbs1Aaot1sgknO1m2Fm0)EMTlZ2SjZ2Hz5a80jxPVaxBzCcXSyywoaKgG8tZbhEGcKPAjJVp2O86LuL48mBgpml8mBxMTztMTdZYb4PtUsRGsBihZIHz5aqAaYpnP2dYP1mb3qVKQeNNzZ4HzHNzXWScVc8KHosnipZMbZMjZ2Lz7IGeEfGdbT)Zi8kaNjf(cbLcFzorLqqG8uoj4juHGPbIGfbrNmt0aPicIVrrBiiOomBhMD)h5alosNuIlR4nUervC4m4sHAVN00l8J(EAWSDzwmmBhMTKeDLEkj54KrCU4IsjnDYmrdMTlZIHz7WSZVZPtkXLv8gxIOkoCgCPqT3t6FpZ2LzXWSDy25350jL4YkEJlrufhodUuO27j9sQsCEMnJhMntMTlZ2fbj8kahcA)Nr4vaotk8fckf(YCIkHGskXLvaOcbJYablcIozMObsreeFJI2qqqDy2om7(pYbwCKoPexwXBCjIQ4WzWLc1EpPPx4h990Gz7YSyy2omBjj6kTJwjzeNlUOustNmt0Gz7YSyy2om787C6KsCzfVXLiQIdNbxku79K(3ZSDzwmmBhMD(DoDsjUSI34sevXHZGlfQ9EsVKQeNNzZ4HzZKz7YSDrqcVcWHG2)zeEfGZKcFHGsHVmNOsiOKsCzfoQqWOmrWIGOtMjAGuebj8kahcIlPKr4vaotk8fckf(YCIkHGuJkWjvaouHGPbJGfbrNmt0aPics4vaoe0(pJWRaCMu4leuk8L5evcbnjzrfQqqCPYjbpHGfbd8iyrqcVcWHG6xqEcbrNmt0aPiQqWKjcweeDYmrdKIii(gfTHGGMFNt3VG8K(3JGeEfGdbTIceQqW8seSii6KzIgifrq8nkAdbbvsIUs3sYwgGZuTKjpsdnDYmrdMfdZQCMD(DoDljBzaot1sM8in0)EeKWRaCiOws2YaCMQLm5rAGkemneblcIozMObsreeFJI2qqqJ9hdnxQCsWtMjjlcs4vaoeeP2dYP1mb3aviyWkcweeDYmrdKIii(gfTHGGg7pgAUu5KGNmtsweKWRaCiio4WduGmvlz89XgLhviyAGiyrq0jZenqkIG4Bu0gccAak9g96LCl5BLzIywmmlhOobMEqCLNzF9HzBics4vaoe0g9OcbJYablcIozMObsreeFJI2qqqCG6ey6bXvEM91hMTHiiHxb4qqoAb8a89MzueQqWOmrWIGOtMjAGuebj8kahcsgsFf4jJpxwveeFJI2qqql5wY3kZeHG4kXtKPKfhvEemWJkemnyeSii6KzIgifrq8nkAdbbnaLEffi9sUL8TYmrmlgMLduNatpiUYZSzWSnebj8kahcAffiuHGb(grWIGOtMjAGuebX3OOneeKWRapzOJudYZSVYSWZSyywHxbEYmaLUAxX3A4sXSpmBJiiHxb4qqv7k(wdxkuHGbE4rWIGOtMjAGuebX3OOneeehOobMEqCLNzZGzXkcs4vaoeKVDPbQqfcIdaPbi)8iyrWapcweKWRaCiOEqfGdbrNmt0aPiQqWKjcweKWRaCiOws2YqEpDCcbrNmt0aPiQqW8seSiiHxb4qqZeammU)QecIozMObsruHGPHiyrqcVcWHGM06PvH4WHGOtMjAGueviyWkcweKWRaCiiz5YrMcSlDfcIozMObsruHGPbIGfbj8kahckf4AlVblXFGtLUcbrNmt0aPiQqWOmqWIGeEfGdb5ILMjayGGOtMjAGueviyuMiyrqcVcWHGKJt(ALKHlPecIozMObsruHGPbJGfbrNmt0aPicIVrrBiiO5350tswJdSQ6Fpcs4vaoe0CdFLIdNX9xuHGb(grWIGOtMjAGuebX3OOneeuhMDakTkaCUyjDfCfIdhZ2SjZk8kWtg6i1G8m7Rml8mBxMfdZoaLUAxX3AMKS6k4kehoeKWRaCiO44YEsfGdviyGhEeSiiHxb4qqtA90QacIozMObsruHGb(mrWIGOtMjAGuebj8kahcIRepbQfCb3mtIVqqKZr8YCIkHG4kXtGAbxWnZK4luHGb(xIGfbrNmt0aPicIVrrBiiOcGdxI0Caina5NNzXWSDy2kujtbmJGy2mywHxb4mCaina5hZQSHzZKzB2KzfEf4jdDKAqEM9vMfEMTlcs4vaoeKCHQyaoZGKQfviyGVHiyrqcVcWHGujvWQKb4mPppgMXsIQhbrNmt0aPiQqWapwrWIGeEfGdb99Kjks1JGOtMjAGuevOcb1VehOoLcblcg4rWIGeEfGdbPqCJLggFFSr5rq0jZenqkIkemzIGfbrNmt0aPicIVrrBiiOX(JHMlvoj4jZKKLzXWSLKOR0oALKrCU4IsjnDYmrdMfdZo)oNMlLXbwv9Vhbj8kahcQFb5juHG5Liyrq0jZenqkIG4Bu0gccs5m7y)XqZLkNe8KzsYYSyywLZSJ9hdnipLtcEYmjzrqcVcWHGMKSghyvrfcMgIGfbrNmt0aPicIVrrBiiOss0v6ws2YaCMQLm5rAOPtMjAWSyy2X(JHgKNYjbpzMKSmlgMD(DoTkaCkeNXbwv9Vhbj8kahcQLKTmaNPAjtEKgOcbdwrWIGOtMjAGuebX3OOnee0y)XqdYt5KGNmtswMfdZo)oNwfaofIZ4aRQ(3JGeEfGdbLVs1IkuHGa5PCsWtiyrWapcweeDYmrdKIii(gfTHGGkjrxPBjzldWzQwYKhPHMozMObZIHzvoZo)oNULKTmaNPAjtEKg6Fpcs4vaoeuljBzaot1sM8inqfcMmrWIGOtMjAGuebX3OOnee0y)XqdYt5KGNmtsweKWRaCiisThKtRzcUbQqW8seSii6KzIgifrq8nkAdbbn2Fm0G8uoj4jZKKfbj8kahcIdo8afit1sgFFSr5rfcMgIGfbrNmt0aPics4vaoeKmK(kWtgFUSQii(gfTHGGwYTKVvMjcbXvINitjloQ8iyGhviyWkcweeDYmrdKIiiHxb4qqQaW5ILqq8nkAdbbTKBjFRmteZ2SjZo)oNgNKeEfCdUVSJqo9VhbXvINitjloQ8iyGhviyAGiyrq0jZenqkIGeEfGdb5)NlwcbX3OOnee0sUL8TYmriiUs8ezkzXrLhbd8OcbJYablcIozMObsreeFJI2qqqDy25350epf9EYK(NS6FpZ2SjZo)oNM4PO3tgpijR(3ZSDrqcVcWHG8LS()IJqfcgLjcweeDYmrdKIii(gfTHGG6WSepf9EshNj9pzz2MnzwINIEpP9GKSMJWYfZ2LzB2Kz7WSepf9EshNj9pzzwmm787CAINIEpzs)twnP2dYPLgmBxeKWRaCiiFjRlwcviyAWiyrqcVcWHGYxPArq0jZenqkIkuHkeeEA9b4qWKzJz2i8ncp8iOCzV4W5rqniQ9GTObZ2GzwHxb4y2u4lVMLfb57jocg4BSHiO(f4IeHGWcMfl5x2rihZ2GA)XGLflywLT8cmPLzHhESz2mBmZgzzzzXcMvzPvoCKhlfllwWSyPz2gKJd2EWkfXSkls9wzhaofIJz73aSrfKNz7eoM1tvfhoMn8mlVL4kqJUAwwwwSGzvwJLj(VObZojhyjMLduNsXStcxCEnZQSkNt9LNzpWHLUvwv3pXScVcW5zwWLusZYk8kaNx3VehOoLcUN3ke3yPHX3hBuEwwSGzfEfGZR7xIduNsb3ZBUughyvXoCpJ9hdnxQCsWtMjjlMss0vAhTsYioxCrPKMozMOblRWRaCED)sCG6uk4EE3VG8e2H7zS)yO5sLtcEYmjzXusIUs7OvsgX5IlkL00jZenWm)oNMlLXbwv9VNLv4vaoVUFjoqDkfCpVNKSghyvXoCpkFS)yO5sLtcEYmjzXO8X(JHgKNYjbpzMKSSScVcW519lXbQtPG75DljBzaot1sM8inWoCpLKOR0TKSLb4mvlzYJ0qtNmt0aZy)XqdYt5KGNmtswmZVZPvbGtH4moWQQ)9SScVcW519lXbQtPG75D(kvl2H7zS)yOb5PCsWtMjjlM5350QaWPqCghyv1)EwwwwSGzvwJLj(VObZs4PvjMTcvIzRwIzfEbwMn8mRGxIKmtKMLv4vao)JxHFkzMIVLLv4vaopCpV)EYefP6zzfEfGZd3Z7EqfGd7W90Ptjj6kDljBzaot1sM8in00jZenWm)oNULKTmaNPAjtEKg6FFxmDg7pgAUu5KGNmts2Mnh7pgAqEkNe8KzsY2TllRWRaCE4EEV)Zi8kaNjf(c7tuPhUu5KGNWoCpJ9hdnxQCsWtMjjlMoD4aqAaYpD1UIV1mjz1lPkX5FTrmCaina5NwvoCjsVKQeN)1gXmaLwfaoxSKEjvjo)Rp44d4AuJvmRGJYOHnIz(DoDCCzpPcWzW9LDeYzaoZF9aUEaYpmZVZPN06PvbZKKvpa5hM53504KKWRGBW9LDeYPhG8RBZMDMFNtZLY4aRQ(3JHoAXP0RzI1UnB2z)h5alosdKQ1aCMQLmuAqRzS)yOPx4h990aJYNFNtdKQ1aCMQLmuAqRzS)yO)9y6m)oNMlLXbwv9VhdD0ItPxZSXUDB2SZ(pYbwCKgivRb4mvlzO0GwZy)XqtVWp67PbM5350TKSLb4mvlzYJ0qVKQeNpd4BSlMoZVZP5szCGvv)7XqhT4u61mBSBZMD4a80jxPvqPnKddhasdq(Pj1EqoTMj4g6LuL48z8apgHxbEYqhPgKpJm72LLv4vaopCpV3)zeEfGZKcFH9jQ0dipLtcEc7W9m2Fm0G8uoj4jZKKftNoCaina5NUAxX3AMKS6LuL48V2igoaKgG8tRkhUePxsvIZ)AJywbhLrMnIz(DoDCCzpPcWPhG8dZ87C6jTEAvWmjz1dq(1TzZoZVZPvbGtH4moWQQ)9ygGs7)NlwsVKBjFRmtu3Mn7m)oNwfaofIZ4aRQ(3Jz(DoDljBzaot1sM8in0)(UnB2z(DoTkaCkeNXbwv9VhtN5350epf9EYK(NS6FFZMZVZPjEk69KXdsYQ)9DXO89FKdS4inqQwdWzQwYqPbTMX(JHMEHF03tJUnB2z)h5alosdKQ1aCMQLmuAqRzS)yOPx4h990aJYNFNtdKQ1aCMQLmuAqRzS)yO)9DB2SdhGNo5k9f4AlJtimCaina5NMdo8afit1sgFFSr51lPkX5Z4b(UnB2HdWtNCLwbL2qomCaina5NMu7b50AMGBOxsvIZNXd8yeEf4jdDKAq(mYSBxwwHxb48W98E)Nr4vaotk8f2NOspjL4YkaSd3tNo7)ihyXr6KsCzfVXLiQIdNbxku79KMEHF03tJUy6usIUspLKCCYioxCrPKMozMOrxmDMFNtNuIlR4nUervC4m4sHAVN0)(Uy6m)oNoPexwXBCjIQ4WzWLc1EpPxsvIZNXtMD7YYk8kaNhUN37)mcVcWzsHVW(ev6jPexwHJD4E60z)h5alosNuIlR4nUervC4m4sHAVN00l8J(EA0ftNss0vAhTsYioxCrPKMozMOrxmDMFNtNuIlR4nUervC4m4sHAVN0)(Uy6m)oNoPexwXBCjIQ4WzWLc1EpPxsvIZNXtMD7YYk8kaNhUN3CjLmcVcWzsHVW(ev6rnQaNub4yzfEfGZd3Z79FgHxb4mPWxyFIk9mjzzzzzfEfGZRNKSptswJdSQyhUhLp)oNEsYACGvv)7zzfEfGZRNKSW98Uhub4WoCpD6m)oNEsRNwfmtsw9VVzZ5350XXL9KkaNb3x2riNb4m)1d46FFxmDu(y)XqZLkNe8KzsYIr5J9hdnipLtcEYmjz72LLv4vaoVEsYc3Z7vWth47nULUxujwwHxb486jjlCpV5GdpqbYuTKX3hBuESd3JYh7pgAUu5KGNmtswmkFS)yOb5PCsWtMjjllRWRaCE9KKfUN3tA90QGzsYID4E6m)oNEf80b(EJBP7fvs)7B2u5CaE6KR04PRAvA7YYk8kaNxpjzH75DCCzpPcWHD4E6m)oNEf80b(EJBP7fvs)7B2u5CaE6KR04PRAvA7YYk8kaNxpjzH75nP2dYP1mb3a7W90r5J9hdnxQCsWtMjjlgLp2Fm0G8uoj4jZKKTBZMcVc8KHosni)RpzYYk8kaNxpjzH759uwf8keh2H7Ptjj6k9Cf1zI8A6KzIgDX0z(Do9KK14aRQ(33LLv4vaoVEsYc3Z7ybN7VyhUN5350Xco3F1lPkX5ZOrnwzzfEfGZRNKSW98wgsFf4jJpxwvS5kXtKPKfhv(h4XoCpl5wY3kZeXYk8kaNxpjzH75TkaCUyjSd3tN53504KKWRGBW9LDeYP)9yg7pgAqEkNe8KzsY2fJWRapzOJudYNXZlzzfEfGZRNKSW98UAxX3AMKSyZvINitjloQ8pWJD4EwYTKVvMjQzZbO0v7k(wZKKv7lHRqgVSzZodqPR2v8TMjjR2xcxHmAiM9FKdS4iD67CsCUVNggsDUcN00l8J(EA0TztHxbEYqhPgK)vSYYk8kaNxpjzH75Tpp6jSd3Z87C644YEsfGZG7l7iKZaCM)6bC9aKFyMFNtpP1tRcMjjREaYpmcVc8KHosni)RpnKLv4vaoVEsYc3ZBv5NWoCpZVZPJJl7jvao9VhJWRapzOJudYNrMSScVcW51tsw4EERk)e2H7PZ87CAVGxWrgoqDkLCL2xcxHxFGVlMoZVZPlaOAnYnm8KKR)9DXm)oNooUSNub40)EmcVc8KHosni)tMSScVcW51tsw4EERkhUeHD4EMFNthhx2tQaC6FpgHxbEYqhPgKpJNxYYk8kaNxpjzH75TkaCUyjS5kXtKPKfhv(h4XoCpl5wY3kZeHr4vGNm0rQb5Z45LSScVcW51tsw4EERk)e2H7PZ87C6caQwJCddpj5AFjCfE9jZUnB2z(DoDbavRrUHHNKC9VhZ87C6caQwJCddpj56LuL48zaVgRDB2SZ87CAVGxWrgoqDkLCL2xcxHxFEzxwwHxb486jjlCpVR2v8TMjjl2H7r4vGNm0rQb5FfEwwHxb486jjlCpVvbGZflHD4E6m)oNgNKeEfCdUVSJqo9VhZy)XqZLkNe8KzsY2fJWRapzOJudYNXZlB2SZ87CACss4vWn4(Yoc50)EmkFS)yO5sLtcEYmjzXO8X(JHgKNYjbpzMKSDXi8kWtg6i1G8z88swwHxb486jjlCpVvLdxIWoCpDwbhLHYSXUyeEf4jdDKAq(mAilRWRaCE9KKfUN39)eEAJxKWMReprMswCu5FGh7W9maLUAxX3AMKSAFjCfEntwwHxb486jjlCpVR2v8TMjjllRWRaCE9KKfUN3QYpXYk8kaNxpjzH75Tpp6jZKKLLLLflywHxb48W98MlPKr4vaotk8f2NOspQrf4KkahllwWScVcW5H75DEKggERS4iwwSGzfEfGZd3ZBUKsgHxb4mPWxyFIk9WbG0aKFEwwSGzfEfGZd3ZBv5NWoCpRGJ0dYf8OYiZgXi8kWtg6i1G8z0qwwSGzfEfGZd3ZBv5NWoCpRGJ0dYf8OYiZgXqEpDCsZbNlf8Yi3W4RnCKwvWsawmkF(DoTVv2E6OHHNKCV(3ZYIfmRWRaCE4EEhl4C)f7W9Wb(6PXMn7Sco6voWxyKxK2OiDsuIwAyuLJ00jZenWi8kWtg6i1G8VMzxwwSGzfEfGZd3Z7(FcpTXlsyxYIJkt4EgGsxTR4BntswTVeUcpdqPR2v8TMjjRwvWYgFjCf8SSybZk8kaNhUN3QaW5ILWUKfhvMW9maLwfaoxSKEj3s(wzMimcVc8KHosniFgzYYIfmRWRaCE4EExTR4BXoCpDMFNthhx2tQaC6bi)Wi8kWtg6i1G8VcF3Mn7m)oNooUSNub40)EmcVc8KHosni)RnSlllwWScVcW5H75Tpp6jSd3Z87C644YEsfGtpa5hgHxbEYqhPgK)1gYYIfmRWRaCE4EERkhUeHD4EgGsxTR4BntswDfCfIdhllwWScVcW5H75TkaCUyjSlzXrLjCpZVZPXjjHxb3G7l7iKt)7Xi8kWtg6i1G8zKjllwWScVcW5H75D1UIVLLflywLvIuIzZJQLzv2bGZflXS5r1YSnObLYowotwwSGzfEfGZd3ZBva4CXsyhUh5fPnks3dYP1aCMQLmQaWPx5u4v4Xi8kWtg6i1G8pWZYIfmRWRaCE4EE7ZJEILLLv4vaoVwnQaNub4EIfCU)ID4EIJduJdNziQcoYGv)RXco3FndrvWrMQDjFlinWm)oNowW5(REjvjoFgVSb0k(IyzfEfGZRvJkWjvao4EE7w6EXGgMLWrhTsfGd7W90ssQA18)U0vz0OwzG1gqljPQvRkyzwwHxb48A1OcCsfGdUN3YfQIb4mdsQwSd3tbWHlr6b5OZh4jpMwssvRUNxzOmBKLv4vaoVwnQaNub4G759uwf8keh2H7Ptjj6k9Cf1zI8A6KzIgDX0z(Do9KK14aRQ(33ftljPQv3ZRmugyftCCGAC4mdrvWrgS6FTrDMyTb0ssQA1QcwMLv4vaoVwnQaNub4G75T)V4d8sYeNVIJxESd3Z87CA)FXh4LKjoFfhV86bi)Wm)oNEkRcEfItpa5hMwssvRUNxz0aBetCCGAC4mdrvWrgS6FTrDMyTb0ssQA1QcwMLLLv4vaoVMdaPbi)8p9GkahlRWRaCEnhasdq(5H75DljBziVNooXYk8kaNxZbG0aKFE4EEptaWW4(RsSScVcW51Caina5NhUN3tA90QqC4yzfEfGZR5aqAaYppCpVLLlhzkWU0vSScVcW51Caina5NhUN3PaxB5nyj(dCQ0vSScVcW51Caina5NhUN3UyPzcagSScVcW51Caina5NhUN3YXjFTsYWLuILv4vaoVMdaPbi)8W98EUHVsXHZ4(l2H7z(Do9KK14aRQ(3ZYk8kaNxZbG0aKFE4EEhhx2tQaCyhUNodqPvbGZflPRGRqC4A2u4vGNm0rQb5Ff(UygGsxTR4BntswDfCfIdhlRWRaCEnhasdq(5H759KwpTkWYk8kaNxZbG0aKFE4EE)9KjksfBY5iEzorLE4kXtGAbxWnZK4lwwHxb48AoaKgG8Zd3ZB5cvXaCMbjvl2H7Pa4WLinhasdq(5X0PcvYuaZiOm4aqAaYpLnz2SPWRapzOJudY)k8DzzfEfGZR5aqAaYppCpVvjvWQKb4mPppgMXsIQNLv4vaoVMdaPbi)8W98(7jtuKQNLLLv4vaoVMlvoj4PN(fKNyzfEfGZR5sLtcEcUN3ROaHD4EMFNt3VG8K(3ZYk8kaNxZLkNe8eCpVBjzldWzQwYKhPb2H7PKeDLULKTmaNPAjtEKgA6KzIgyu(87C6ws2YaCMQLm5rAO)9SScVcW51CPYjbpb3ZBsThKtRzcUb2H7zS)yO5sLtcEYmjzzzfEfGZR5sLtcEcUN3CWHhOazQwY47Jnkp2H7zS)yO5sLtcEYmjzzzfEfGZR5sLtcEcUN3B0JD4EgGsVrVEj3s(wzMimCG6ey6bXv(xFAilRWRaCEnxQCsWtW982rlGhGV3mJIWoCpCG6ey6bXv(xFAilRWRaCEnxQCsWtW98wgsFf4jJpxwvS5kXtKPKfhv(h4XoCpl5wY3kZeXYk8kaNxZLkNe8eCpVxrbc7W9maLEffi9sUL8TYmry4a1jW0dIR8z0qwwHxb48AUu5KGNG75D1UIV1WLc7W9i8kWtg6i1G8VcpgHxbEYmaLUAxX3A4s90ilRWRaCEnxQCsWtW9823U0a7W9WbQtGPhex5ZaRSSSScVcW51jL4Yk8hUughyvzzzzfEfGZRtkXLvapQaWPqCghyvzzzzfEfGZRb5PCsWtpTKSLb4mvlzYJ0a7W9usIUs3sYwgGZuTKjpsdnDYmrdmkF(DoDljBzaot1sM8in0)EwwHxb48AqEkNe8eCpVj1EqoTMj4gyhUNX(JHgKNYjbpzMKSSScVcW51G8uoj4j4EEZbhEGcKPAjJVp2O8yhUNX(JHgKNYjbpzMKSSScVcW51G8uoj4j4EEldPVc8KXNlRk2CL4jYuYIJk)d8yhUNLCl5BLzIyzfEfGZRb5PCsWtW98wfaoxSe2CL4jYuYIJk)d8yhUNLCl5BLzIA2C(Donojj8k4gCFzhHC6FplRWRaCEnipLtcEcUN3()5ILWMReprMswCu5FGh7W9SKBjFRmtelRWRaCEnipLtcEcUN3(sw)FXryhUNoZVZPjEk69Kj9pz1)(MnNFNtt8u07jJhKKv)77YYk8kaNxdYt5KGNG75TVK1flHD4E6q8u07jDCM0)KTztINIEpP9GKSMJWYv3Mn7q8u07jDCM0)KfZ87CAINIEpzs)twnP2dYPLgDzzfEfGZRb5PCsWtW98oFLQfvOcHa]] )

end