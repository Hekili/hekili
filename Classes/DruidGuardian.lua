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

    spec:RegisterPack( "Guardian", 20201011, [[dCej1aqiisEerPUeiKQnjHgfrXPiKwfeP6vkPMfbCljcPDjQFjrnmqWXGOwMePNbc10iqUgeX2ikHVbcX4KiQZruswhrjL5jbUNsSpcuheesXcvHEiiKmrisHlsuIYgjkr1hLieNeIuALeQBsuIStvWpHifnuqiLEQKMQsYEL6VcgSkDyulwPEmutguxgzZc9zcA0QOttz1eLu9Aq0Sf52ez3k(TQgoiDCjc1YbEojtNQRdPTtu9DimEjICEjO1lrW8je7Nu3i3R6km7uFOuiukeqgciJCgzbbXibziUREHqPUcLXqYcPUoSe11seugaB80vOCHPNH7vDv9Oam11t3HQK1kxwO5NO7m(LkRmj0e72pyah9YktcxURBul5iTtV7km7uFOuiukeqgciJCgzbbXib5UYO(5d6A1KGO66PbdttV7kmPWDv26BjckdGnE0xKgaudwlw26lstS)BcOViJSa6BPqOuiOfRflB9fI6KhHKswtlw26BjQ(I0o4ha9bSt6lef7LLL(FG0g9fkWEG5gP0xzSO(Qi3TrO(Ak9fFsyijyrZDnzkx1R6AQqmd4Vx1hqUx1vg72pDv6)bsBcXhi1vA4DIG7JT3Ex3ed6v9bK7vDLXU9txbSCAEuvicOPekSR0W7eb3hBVpuAVQR0W7eb3h7kgyobmURB0ymVjGIaqg2edYOq1xrerF3OXy2gmdg2TFccrzaSXt4JbuG6XzuODLXU9txH(U9t79biUx1vg72pDfvrbZjjvxPH3jcUp2EFqq9QUYy3(PR4FK)qsb)KckOgWCvxPH3jcUp2EFaj9QUsdVteCFSRyG5eW4UUrJXmGLtZJQcranLqHzuO6RiIOViL(IF50WJNLtJFwiORm2TF66Makcaz79bzrVQR0W7eb3h7kgyobmURB0ymdy508OQqeqtjuygfQ(kIi6lsPV4xon84z504Nfc6kJD7NUAdMbd72pT3hGi9QUYy3(PRKe0hbbc7FG7kn8orW9X27dLCVQR0W7eb3h7kgyobmURYOVoNOXZBalTtKktdVteS(kQ(wuFLrF3OXyEtmieFGugfQ(kAxzSB)01ndGubPnT3hKv9QUsdVteCFSRyG5eW4UkJ(cyHugMIg2C9Ta9fziOVIQVf1xg7MCkqdjzKsFlqFfuxzSB)0vjgn1EFazi0R6kn8orW9XUIbMtaJ76gngZg4Nikidij2gL(wG(cHms6kJD7NUAGFIOG27diJCVQR0W7eb3h7kgyobmURakci1jVtK(kIi6l87z)eWQZWMyqw5mgs9Ta9fI1xrerFHFp7NawDg2edYkNXqQVfOVcsFlQVa0HIpqiLtOXiBtevrWbsAdymLPsmQbfkb3vg72pD1pbS6mSjg0EFa5s7vDLgENi4(yxXaZjGXDvg9DJgJzBWmyy3(jd)ig9TO(UrJX8Makcazytmid)ig9TO(Yy3KtbAijJu6RG1xK1xr1xrerFLrF3OXy2gmdg2TFYOq13I67gngZBcOiaKHnXGm8Jy03I6lJDtofOHKmsPVcwFfK(kAxzSB)0v)eWQZWMyq79bKH4EvxPH3jcUp2vmWCcyCxrk91nmK2iSRm2TF6kdZqDtofuiyGu79bKfuVQR0W7eb3h7kgyobmURakci1jVtK(wuFzSBYPanKKrk9TGf9T0UYy3(PRs)prdqT3hqgj9QUsdVteCFSRyG5eW4UUrJXSqoXy3WbHOma24jJcvFlQVB0ymlKtm2nCqikdGnEYasITrPVfOViNrsxzSB)0vP)NObO27dill6vDLgENi4(yxXaZjGXDDJgJzBWmyy3(jieLbWgpHpgqbQhNHFeJ(wuF3OXyEtafbGmSjgKHFeJ(wuFzSBYPanKKrk9vW6RG6kJD7NUQqyqPWMyq79bKHi9QUsdVteCFSRyG5eW4UkJ(UrJXS)VFg4boGtmISYzmK6RGx03s1xr13I6lJDtofOHKmsPVfOVcQRm2TF6QeJMAVpGCj3R6kn8orW9XUIbMtaJ7Qm67gngZ()(zGh4aoXiYOq13I67gngZ()(zGh4aoXiYasITrPVfOViNrI(kQ(wuFzSBYPanKKrk9Ta9vqDLXU9txLy0u79bKLv9QUsdVteCFSRyG5eW4UkJ(UrJXSILZcPa(L2SZJNvoJHuFf8I(cX6RO6Br9LXUjNc0qsgP03c0xb1vg72pDvIrtT3hkfc9QUsdVteCFSRyG5eW4UcyHK(wG(wYqqFfre9fP03nAmM3eqraidBIbzuO6Br9fP03nAmMTbZGHD7NGqugaB8e(yafOECgfAxzSB)0vjEeMO27dLICVQR0W7eb3h7kgyobmURWVN9taRodBIbzLZyi1xbRVL2vg72pDfkAsobSsGAVpuAP9QUYy3(PR(jGvNHnXGUsdVteCFS9(qPqCVQRm2TF6QeJM6kn8orW9X27dLkOEvxzSB)0vfcdkf2ed6kn8orW9X2BVRsMBcz3(Px1hqUx1vA4DIG7JDfdmNag3vBWVKncdWSelKcirPVcwFnWpruqaMLyHuWpbK68tW6Br9DJgJzd8tefKbKeBJsFlqFHy9fPRVNSYPUYy3(PRg4NikO9(qP9QUsdVteCFSRyG5eW4UEsCYpZyuaGgxFlqFHqgIGe9fPRVNeN8ZSexsDLXU9txJaAkbJGdasineGD7N27dqCVQR0W7eb3h7kgyobmUR(luyIYWuKgLjNu6Br99K4KFMHID9Ta9TKHqxzSB)0vEmjo8XamX(z79bb1R6kn8orW9XUIbMtaJ7Qm6RZjA88gWs7ePY0W7ebRVIQVf1xz03nAmM3edcXhiLrHQVIQVf13tIt(zgk213c0xics03I6Rn4xYgHbywIfsbKO0xbRVqixks0xKU(EsCYpZsCj1vg72pDDZaivqAt79bK0R6kn8orW9XUIbMtaJ76gngZkuGCtoNc2OCBWUkd)ig9TO(UrJX8MbqQG0Mm8Jy03I67jXj)mdf76Bb6RSac6Br91g8lzJWamlXcPasu6RG1xiKlfj6lsxFpjo5NzjUK6kJD7NUQqbYn5CkyJYTb7Q2BVRPcXmGX9Q(aY9QUYy3(PRy2dXhi1vA4DIG7JT3ExHPiJM8EvFa5EvxzSB)0vfKOPuyZQZUsdVteCFS9(qP9QUsdVteCFSRyG5eW4Ucdqn4mMDeelNcBIb6Br9DJgJzm7H4dKYOq7QYbg27di3vg72pDfGobg72pHKP8UMmLhgwI6kMDeelNAVpaX9QUsdVteCFSRyG5eW4Ucdqn48JiHGy5uytmqFlQVB0yml9)aPnH4dKYOq7QYbg27di3vg72pDfGobg72pHKP8UMmLhgwI66JiHGy5u79bb1R6kn8orW9XUIbMtaJ7Qm6Rm6laDO4des5uHygWQqmrKBJWGWKjbvrzQeJAqHsW6RO6Br9vg915enEEZjEWuGJrBmVWmn8orW6RO6Br9vg9DJgJ5uHygWQqmrKBJWGWKjbvrzuO6RO6Br9vg9DJgJ5uHygWQqmrKBJWGWKjbvrzajX2O03cw03s1xr1xr7kJD7NUcqNaJD7NqYuExtMYddlrDnviMb83EFaj9QUsdVteCFSRyG5eW4UkJ(kJ(cqhk(aHuoviMbSkete52imimzsqvuMkXOguOeS(kQ(wuFLrFDorJNJeGtbogTX8cZ0W7ebRVIQVf1xz03nAmMtfIzaRcXerUncdctMeufLrHQVIQVf1xz03nAmMtfIzaRcXerUncdctMeufLbKeBJsFlyrFlvFfvFfTRm2TF6kaDcm2TFcjt5DnzkpmSe11uHygW427dYIEvxzSB)01nXGq8bsDLgENi4(y79bisVQR0W7eb3h7kJD7NUI5ukWy3(jKmL31KP8WWsuxLm3eYU9t79HsUx1vg72pDfHLGd4tgiK6kn8orW9X27dYQEvxPH3jcUp2vg72pDfZPuGXU9tizkVRjt5HHLOUI)pb)igv79bKHqVQR0W7eb3h7kJD7NUcqNaJD7NqYuExtMYddlrDDtmO927kMDeelN6v9bK7vDLXU9txHcEePUsdVteCFS9(qP9QUsdVteCFSRyG5eW4UUrJXmuWJiLrH2vg72pDfWqsT3hG4EvxPH3jcUp2vmWCcyCxDorJNpjg4Hpg8tkGWsWzA4DIG13I6lsPVB0ymFsmWdFm4NuaHLGZOq7kJD7NUEsmWdFm4NuaHLGBVpiOEvxPH3jcUp2vmWCcyCxHbOgCgZocILtHnXGUYy3(PRKe0hbbc7FGBVpGKEvxPH3jcUp2vmWCcyCxHbOgCgZocILtHnXGUYy3(PR4FK)qsb)KckOgWCv79bzrVQR0W7eb3h7kgyobmURWVNbg0mGIasDY7ePVf1x8lT)a03gxPVl6ls6kJD7NUcmOT3hGi9QUsdVteCFSRyG5eW4UIFP9hG(24k9DrFrsxzSB)01ibES9OQW2CQ9(qj3R6kn8orW9XUIbMtaJ7k87zadjLbueqQtENi9TO(IFP9hG(24k9Ta9fjDLXU9txbmKu79bzvVQR0W7eb3h7kgyobmURm2n5uGgsYiL(ky9fz9TO(Yy3Ktb43Z(jGvNbm767I(cHUYy3(PR(jGvNbm7T3hqgc9QUsdVteCFSRyG5eW4UIFP9hG(24k9Ta9fjDLXU9txvNacU927k()e8Jyu9Q(aY9QUYy3(PRqF3(PR0W7eb3hBVpuAVQRm2TF66jXapqkfnyQR0W7eb3hBVpaX9QUYy3(PR70)WHikOWUsdVteCFS9(GG6vDLXU9tx3eqraiTryxPH3jcUp2EFaj9QUYy3(PRmaZdf8haOX7kn8orW9X27dYIEvxzSB)01Kj80vbzDuyHs04DLgENi4(y79bisVQRm2TF6A0a0o9pCxPH3jcUp2EFOK7vDLXU9tx5btkhWPaMtPUsdVteCFS9(GSQx1vA4DIG7JDfdmNag31nAmM3edcXhiLrH2vg72pDDdmLNSryiIcAVpGme6vDLgENi4(yxXaZjGXDvg9f(9S0)t0au2nmK2iuFfre9LXUjNc0qsgP0xbRViRVIQVf1x43Z(jGvNHnXGSByiTryxzSB)0vBWmyy3(P9(aYi3R6kJD7NUUjGIaq2vA4DIG7JT3hqU0EvxPH3jcUp2vg72pDfxio9o4hdh2jw5DLIrc7HHLOUIleNEh8JHd7eR827didX9QUsdVteCFSRyG5eW4U6VqHjkJ)pb)igL(wuFLrFDtIc(hGnsFlqFzSB)eW)NGFeJ(crxFlvFfre9LXUjNc0qsgP0xbRViRVI2vg72pDLhtIdFmatSF2EFazb1R6kJD7NUkrspOWWhdjuSbhGbelP6kn8orW9X27diJKEvxzSB)0vuffmNKuDLgENi4(y7T3vOac)sB27v9bK7vDLXU9txH0gyabhuqnG5QUsdVteCFS9(qP9QUsdVteCFSRyG5eW4UUrJX8Myqi(aPm8Jy03I6Rm6lsPVWaudoJzhbXYPWMyG(kIi67gngZy2dXhiLHFeJ(kQ(wuFLrFrk9fgGAW5hrcbXYPWMyG(kIi67gngZs)pqAti(aPm8Jy0xr7kJD7NUUjgeIpqQ9(ae3R6kJD7NUkrspOWWhdjuSbhGbelP6kn8orW9X27dcQx1vg72pDf672pDLgENi4(y7T31hrcbXYPEvFa5EvxzSB)0vP)hiTjeFGuxPH3jcUp2EFO0EvxPH3jcUp2vmWCcyCxDorJNpjg4Hpg8tkGWsWzA4DIG13I6lsPVB0ymFsmWdFm4NuaHLGZOq7kJD7NUEsmWdFm4NuaHLGBVpaX9QUsdVteCFSRyG5eW4Ucdqn48JiHGy5uytmORm2TF6kjb9rqGW(h427dcQx1vA4DIG7JDfdmNag3vyaQbNFejeelNcBIbDLXU9txX)i)HKc(jfuqnG5Q27diPx1vA4DIG7JDfdmNag3vafbK6K3jQRm2TF6Q0)t0au79bzrVQR0W7eb3h7kgyobmURakci1jVtuxzSB)0vf6ena1EFaI0R6kn8orW9XUIbMtaJ7Qm67gngZeozqvuiHomiJcvFfre9DJgJzcNmOkkO(edYOq1xr7kJD7NUQCgOqbcP27dLCVQR0W7eb3h7kgyobmURYOVeozqvu2MqcDyG(kIi6lHtgufLvFIbHHkjxFfvFfre9vg9LWjdQIY2esOdd03I67gngZeozqvuiHomitsqFeeGG1xr7kJD7NUQCgena1EFqw1R6kJD7NUIaW(zxPH3jcUp2E7T3v5eqz)0hkfcLcbKHaYi3vemySrOQRiTsqFGtW6RSsFzSB)OVjt5QSwCxHc(OLOUkB9TebLbWgp6lsdaQbRflB9fPj2)nb0xKrwa9Tuiuke0I1ILT(crDYJqsjRPflB9TevFrAh8dG(a2j9fII9YYs)pqAJ(cfypWCJu6RmwuFvK72iuFnL(IpjmKeSOzTyTyzRVYYkjcJ6eS(UP4di9f)sB213nj0gvwFHObJjOUsFNFkrpzGuenPVm2TFu67pPcZAXm2TFuzOac)sB2xVugsBGbeCqb1aMR0IzSB)OYqbe(L2SVEP8Myqi(ajbS4YgngZBIbH4dKYWpIPOmifma1GZy2rqSCkSjgiIiB0ymJzpeFGug(rmIwugKcgGAW5hrcbXYPWMyGiISrJXS0)dK2eIpqkd)igr1IzSB)OYqbe(L2SVEPSej9GcdFmKqXgCagqSKslMXU9Jkdfq4xAZ(6LYqF3(rlwlw26RSSsIWOobRVKCcuO(6MePV(jPVm2FG(Ak9LLZwI3jkRfZy3(rTOGenLcBwDQfZy3(rTEPmaDcm2TFcjt5cmSeTGzhbXYjbuoWW(cYcyXfyaQbNXSJGy5uytmO4gngZy2dXhiLrHQfZy3(rTEPmaDcm2TFcjt5cmSeT8isiiwojGYbg2xqwalUadqn48JiHGy5uytmO4gngZs)pqAti(aPmkuTyg72pQ1lLbOtGXU9tizkxGHLOLuHygWVawCrgzaOdfFGqkNkeZawfIjICBegeMmjOkktLyudkucw0IY4CIgpV5epykWXOnMxyMgENiyrlkZgngZPcXmGvHyIi3gHbHjtcQIYOqfTOmB0ymNkeZawfIjICBegeMmjOkkdij2gvblLkQOAXm2TFuRxkdqNaJD7NqYuUadlrlPcXmGXcyXfzKbGou8bcPCQqmdyviMiYTryqyYKGQOmvIrnOqjyrlkJZjA8CKaCkWXOnMxyMgENiyrlkZgngZPcXmGvHyIi3gHbHjtcQIYOqfTOmB0ymNkeZawfIjICBegeMmjOkkdij2gvblLkQOAXm2TFuRxkVjgeIpqslMXU9JA9szmNsbg72pHKPCbgwIwKm3eYU9JwmJD7h16LYiSeCaFYaHKwmJD7h16LYyoLcm2TFcjt5cmSeTG)pb)igLwmJD7h16LYa0jWy3(jKmLlWWs0YMyGwSwmJD7hvEtmy9szalNMhvfIaAkHc1IzSB)OYBIbRxkd9D7hbS4YgngZBcOiaKHnXGmkurezJgJzBWmyy3(jieLbWgpHpgqbQhNrHQfZy3(rL3edwVugvrbZjjLwmJD7hvEtmy9sz8pYFiPGFsbfudyUslMXU9JkVjgSEP8MakcazytmqalUSrJXmGLtZJQcranLqHzuOIicsHF50WJNLtJFwiqlMXU9JkVjgSEPSnygmSB)iGfx2OXygWYP5rvHiGMsOWmkurebPWVCA4XZYPXpleOfZy3(rL3edwVuMKG(iiqy)dSwmJD7hvEtmy9s5ndGubPncyXfzCorJN3awANivMgENiyrlkZgngZBIbH4dKYOqfvlMXU9JkVjgSEPSeJMeWIlYayHugMIg28cqgcIwKXUjNc0qsgPkqqAXm2TFu5nXG1lLnWpruGawCzJgJzd8tefKbKeBJQaiKrIwmJD7hvEtmy9sz)eWQZWMyGaodesEWIlakci1jVtKiIa)E2pbS6mSjgKvoJHSaiwerGFp7NawDg2edYkNXqwGGkcqhk(aHuoHgJSnrufbhiPnGXuMkXOguOeSwmJD7hvEtmy9sz)eWQtbS4ImB0ymBdMbd72pz4hXuCJgJ5nbueaYWMyqg(rmfzSBYPanKKrkbJSOIiImB0ymBdMbd72pzuOf3OXyEtafbGmSjgKHFetrg7MCkqdjzKsWcsuTyg72pQ8MyW6LYmmd1n5uqHGbsc4mqi5blUGuUHH0gHAXm2TFu5nXG1lLL(FIgGeWzGqYdwCbqraPo5DIkYy3KtbAijJufSuQwmJD7hvEtmy9szP)NObibS4YgngZc5eJDdheIYayJNmk0IB0ymlKtm2nCqikdGnEYasITrvaYzKOfZy3(rL3edwVuwHWGscyXLnAmMTbZGHD7NGqugaB8e(yafOECg(rmf3OXyEtafbGmSjgKHFetrg7MCkqdjzKsWcslMXU9JkVjgSEPSeJMeWIlYSrJXS)VFg4boGtmISYzmKcEPurlYy3KtbAijJufiiTyg72pQ8MyW6LYsmAsalUiZgngZ()(zGh4aoXiYOqlUrJXS)VFg4boGtmImGKyBufGCgjIwKXUjNc0qsgPkqqAXm2TFu5nXG1lLLy0KawCrMnAmMvSCwifWV0MDE8SYzmKcEbIfTiJDtofOHKmsvGG0IzSB)OYBIbRxklXJWejGfxaSqQGsgcIicsTrJX8MakcazytmiJcTisTrJXSnygmSB)eeIYayJNWhdOa1JZOq1IzSB)OYBIbRxkdfnjNawjqc4mqi5blUa)E2pbS6mSjgKvoJHuWLQfZy3(rL3edwVu2pbS6mSjgOfZy3(rL3edwVuwIrtAXm2TFu5nXG1lLvimOuytmqlwlw26lJD7h16LYyoLcm2TFcjt5cmSeTizUjKD7hTyzRVm2TFuRxkJWsWb8jdesAXYwFzSB)OwVugZPuGXU9tizkxGHLOf8)j4hXO0ILT(Yy3(rTEPSeJMeWIlawiLHPOHnVGsHqrg7MCkqdjzKQabPflB9LXU9JA9szjgnjGfxaSqkdtrdBEbLcHIKsrdMY4FIjd7bEGdkhyrklXY6pOisTrJXS6KbqPHGd4eJqLrHQflB9LXU9JA9szd8tefiGfxWVYxGGiIidGfscg)kVixceWCkN4cjabhK4HY0W7ebxKXUjNc0qsgPeCPIQflB9LXU9JA9szOOj5eWkbsaNbcjpyXf43Z(jGvNHnXGSYzmKlWVN9taRodBIbzjUKckNXqQ0ILT(Yy3(rTEPS0)t0aKaodesEWIlWVNL(FIgGYakci1jVturg7MCkqdjzKQGs1ILT(Yy3(rTEPSFcy1PawCrMnAmMTbZGHD7Nm8JykYy3KtbAijJucgzrfrez2OXy2gmdg2TFYOqlYy3KtbAijJucwqIQflB9LXU9JA9szfcdkjGfx2OXy2gmdg2TFYWpIPiJDtofOHKmsjybPflB9LXU9JA9szjEeMibS4c87z)eWQZWMyq2nmK2iulw26lJD7h16LYs)prdqc4mqi5blUSrJXSqoXy3WbHOma24jJcTiJDtofOHKmsvqPAXYwFzSB)OwVu2pbS6ulw26RSClL0xeMFQVYs)prdq6lcZp1xiAFxwQKkvlw26lJD7h16LYs)prdqcyXfUeiG5ug6JGaHpg8tki9)Kb8aPGrUiJDtofOHKmsTGSwSS1xg72pQ1lLvimOKwSwmJD7hvwYCti72plg4NikqalUyd(LSryaMLyHuajkbBGFIOGamlXcPGFci15NGlUrJXSb(jIcYasITrvaeJ0pzLtAXm2TFuzjZnHSB)SEPCeqtjyeCaqcPHaSB)iGfxojo5NzmkaqJxaeYqeKG0pjo5NzjUK0IzSB)OYsMBcz3(z9szEmjo8XamX(PawCXFHctugMI0Om5KQ4jXj)mdf7fuYqqlMXU9JklzUjKD7N1lL3masfK2iGfxKX5enEEdyPDIuzA4DIGfTOmB0ymVjgeIpqkJcv0INeN8ZmuSxaebjfTb)s2imaZsSqkGeLGHqUuKG0pjo5NzjUK0IzSB)OYsMBcz3(z9szfkqUjNtbBuUnyxjGfx2OXywHcKBY5uWgLBd2vz4hXuCJgJ5ndGubPnz4hXu8K4KFMHI9cKfqOOn4xYgHbywIfsbKOemeYLIeK(jXj)mlXLKwSwmJD7hvg)Fc(rmQfOVB)OfZy3(rLX)NGFeJA9s5tIbEGukAWKwmJD7hvg)Fc(rmQ1lL3P)HdruqHAXm2TFuz8)j4hXOwVuEtafbG0gHAXm2TFuz8)j4hXOwVuMbyEOG)aanUwmJD7hvg)Fc(rmQ1lLtMWtxfK1rHfkrJRfZy3(rLX)NGFeJA9s5ObOD6FyTyg72pQm()e8JyuRxkZdMuoGtbmNsAXm2TFuz8)j4hXOwVuEdmLNSryiIceWIlB0ymVjgeIpqkJcvlMXU9JkJ)pb)ig16LY2GzWWU9JawCrg43Zs)prdqz3WqAJqreHXUjNc0qsgPemYIwe(9SFcy1zytmi7ggsBeQfZy3(rLX)NGFeJA9s5nbueasTyg72pQm()e8JyuRxkJQOG5KKaumsypmSeTGleNEh8JHd7eRCTyg72pQm()e8JyuRxkZJjXHpgGj2pfWIl(luyIY4)tWpIrvug3KOG)byJka)Fc(rmq0lverySBYPanKKrkbJSOAXm2TFuz8)j4hXOwVuwIKEqHHpgsOydoadiwsPfZy3(rLX)NGFeJA9szuffmNKuAXAXm2TFuzm7iiwoTaf8isAXm2TFuzm7iiwoTEPmGHKeWIlB0ymdf8iszuOAXm2TFuzm7iiwoTEP8jXap8XGFsbewcwalU4CIgpFsmWdFm4NuaHLGZ0W7ebxeP2OXy(KyGh(yWpPaclbNrHQfZy3(rLXSJGy506LYKe0hbbc7FGfWIlWaudoJzhbXYPWMyGwmJD7hvgZocILtRxkJ)r(djf8tkOGAaZvcyXfyaQbNXSJGy5uytmqlMXU9JkJzhbXYP1lLbgubS4c87zGbndOiGuN8orfXV0(dqFBC1cs0IzSB)OYy2rqSCA9s5ibES9OQW2CsalUGFP9hG(24QfKOfZy3(rLXSJGy506LYagssalUa)EgWqszafbK6K3jQi(L2Fa6BJRkajAXm2TFuzm7iiwoTEPSFcy1zaZUawCHXUjNc0qsgPemYfzSBYPa87z)eWQZaM9fiOfZy3(rLXSJGy506LYQtablGfxWV0(dqFBCvbirlwlMXU9JkNkeZagVGzpeFGKwSwmJD7hvoviMb8Vi9)aPnH4dK0I1IzSB)OYpIecILtls)pqAti(ajTyg72pQ8JiHGy506LYNed8Whd(jfqyjybS4IZjA88jXap8XGFsbewcotdVteCrKAJgJ5tIbE4Jb)KciSeCgfQwmJD7hv(rKqqSCA9szsc6JGaH9pWcyXfyaQbNFejeelNcBIbAXm2TFu5hrcbXYP1lLX)i)HKc(jfuqnG5kbS4cma1GZpIecILtHnXaTyg72pQ8JiHGy506LYs)prdqc4mqi5blUaOiGuN8orAXm2TFu5hrcbXYP1lLvOt0aKaodesEWIlakci1jVtKwmJD7hv(rKqqSCA9szLZafkqijGfxKzJgJzcNmOkkKqhgKrHkIiB0ymt4Kbvrb1NyqgfQOAXm2TFu5hrcbXYP1lLvodIgGeWIlYq4KbvrzBcj0HbIicHtgufLvFIbHHkjxurergcNmOkkBtiHomO4gngZeozqvuiHomitsqFeeGGfvlMXU9Jk)isiiwoTEPmca7NDvbLW9bKHGGAV9Ub]] )

end