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
            cooldown = 45,
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

    spec:RegisterPack( "Guardian", 20201012, [[dSKPfbqisuEKQK6sIiK2eu8jreuJsK6usfRser9kqvZck1Tafj2fP(LQudte1XGswMi4zQsY0er6AKOABQsGVbkkJduuDovjsRduKAEIq3tvSpqHdkIqSqsOhQkrmrrerxueHYgfrq6JQsqoPicSsrYmfreUPiI0obL(PicvdvebXsbfj5PGmvqLVcksQ9c5VumykDyIfROhJQjRWLr2mv(muz0sPtlSAvjOEnjy2I62K0Uv53adxQ64QsOLR0ZPQPl56QQTdv9DPy8QsuNNez9GIy(sL2pkJWcbhcAifHGnHKtizSsgRe0jGfwjN0KIGkL6jeuVWvqWriOtuje0l0x2rihcQxukdKbcoeKh8xoHGARQ3dt)(nUOA)tnhO(2hQ)Sub44R4Q3(qL)gbn)rUsco0ebnKIqWMqYjKmwjJvc6eWcRKtAcii5xTGfbbfQVeeuBmg0HMiOb55iOxZSVqFzhHCmBsY9hdwQxZSjX5fyslZIfwyZSjKCcjZsXs9AM9L0khoYdtZs9AMfMcZMeCCW2dwPiM9Li17Kua4uioMTFdWgvqEMnD4ywpvvC4y2WZS8wIRan6Orq5WxEeCiOSsCzfacoeSyHGdbj8kahcsfaofIZ4aRkcIozMPbsruHke0KKfbhcwSqWHGOtMzAGuebX3OOneeKYy25350tswJdSQ6Fpcs4vaoe0KK14aRkQqWMacoeeDYmtdKIii(gfTHGGsZSPz25350tA90QGzsYQ)9mB3Um787C644YEsfGZG7l7iKZaCM)6bC9VNz7WSyy20mRYy2X(JHMlvdj4jZKKLzXWSkJzh7pgAqtUHe8KzsYYSDy2oiiHxb4qq9GkahQqW(keCiiHxb4qqRGNoW3BClDWeLqq0jZmnqkIkeSjfbhcIozMPbsreeFJI2qqqkJzh7pgAUunKGNmtswMfdZQmMDS)yObn5gsWtMjjlcs4vaoeehC4bkqMQLm((yJYJkeSkhbhcIozMPbsreeFJI2qqqPz25350RGNoW3BClDWeL0)EMTBxMvzmlhGNo5knE6QwLwMTdcs4vaoe0KwpTkGkeSVaeCii6KzMgifrq8nkAdbbLMzNFNtVcE6aFVXT0btus)7z2UDzwLXSCaE6KR04PRAvAz2oiiHxb4qqXXL9KkahQqWcZqWHGOtMzAGuebX3OOneeuAMvzm7y)XqZLQHe8KzsYYSyywLXSJ9hdnOj3qcEYmjzz2omB3UmRWRapzOJudYZSW4Hztabj8kahcIu7bn0AMGBGkeSWCeCii6KzMgifrq8nkAdbbLMzljtxPNROoZKxtNmZ0Gz7WSyy20m787C6jjRXbwv9VNz7GGeEfGdbnLvbVcXHkeSVueCii6KzMgifrq8nkAdbbn)oNowW5(REjvjopZMiZMSw5iiHxb4qqXco3FrfcwSsgbhcIozMPbsreKWRaCiizi9vGNm(gzvrq8nkAdbbTKBjFRmZecIReptMswCu5rWIfQqWIfwi4qq0jZmnqkIG4Bu0gccknZo)oNgNKfEfCdUVSJqo9VNzXWSJ9hdnOj3qcEYmjzz2omlgMv4vGNm0rQb5z2eFy2xHGeEfGdbPcaNlwcviyXkbeCii6KzMgifrqcVcWHGQ2v8TMjjlcIVrrBiiOLCl5BLzMy2UDz2bO0v7k(wZKKv7lHRaZMiZ(kMTBxMnnZoaLUAxX3AMKSAFjCfy2ez2KYSyy29FKdS4iD(7CsCUVNggsDUcN00l(J(EAWSDy2UDzwHxbEYqhPgKNzHbZQCeexjEMmLS4OYJGfluHGfRxHGdbrNmZ0aPicIVrrBiiO5350XXL9KkaNb3x2riNb4m)1d46bO5ywmm787C6jTEAvWmjz1dqZXSyywHxbEYqhPgKNzHXdZMueKWRaCiiFt0tMjjlQqWIvsrWHGOtMzAGuebX3OOnee087C644YEsfGt)7zwmmRWRapzOJudYZSjYSjGGeEfGdbPk)mQqWILYrWHGOtMzAGuebX3OOneeuAMD(DoTxWl4idhOoLsUs7lHRaZcJhMflMTdZIHztZSZVZPlaOAnYnm8S0O)9mBhMfdZo)oNooUSNub40)EMfdZk8kWtg6i1G8m7dZMacs4vaoeKQ8ZOcblwVaeCii6KzMgifrq8nkAdbbn)oNooUSNub40)EMfdZk8kWtg6i1G8mBIpm7RqqcVcWHGuLdxMqfcwSGzi4qq0jZmnqkIGeEfGdbPcaNlwcbX3OOnee0sUL8TYmtmlgMv4vGNm0rQb5z2eFy2xHG4kXZKPKfhvEeSyHkeSybZrWHGOtMzAGuebX3OOneeuAMD(DoDbavRrUHHNLgTVeUcmlmEy2ey2omB3UmBAMD(DoDbavRrUHHNLg9VNzXWSZVZPlaOAnYnm8S0OxsvIZZSjYSyPvoZ2Hz72LztZSZVZP9cEbhz4a1PuYvAFjCfywy8WSVIz7GGeEfGdbPk)mQqWI1lfbhcIozMPbsreeFJI2qqqcVc8KHosnipZcdMfleKWRaCiOQDfFRzsYIkeSjKmcoeeDYmtdKIii(gfTHGGsZSZVZPXjzHxb3G7l7iKt)7zwmm7y)XqZLQHe8KzsYYSDywmmRWRapzOJudYZSj(WSVIz72LztZSZVZPXjzHxb3G7l7iKt)7zwmmRYy2X(JHMlvdj4jZKKLzXWSkJzh7pgAqtUHe8KzsYYSDywmmRWRapzOJudYZSj(WSVcbj8kahcsfaoxSeQqWMawi4qq0jZmnqkIG4Bu0gccknZUcoIztKzH5jZSDywmmRWRapzOJudYZSjYSjfbj8kahcsvoCzcviytibeCii6KzMgifrqcVcWHG6)z80gWecbX3OOnee0au6QDfFRzsYQ9LWvGzHbZMacIReptMswCu5rWIfQqWMWRqWHGeEfGdbvTR4BntsweeDYmtdKIOcbBcjfbhcs4vaoeKQ8Zii6KzMgifrfc2euocoeKWRaCiiFt0tMjjlcIozMPbsruHkeKAuboPcWHGdblwi4qq0jZmnqkIG4Bu0gcckooqnoCMHOk4iJY9mlmy2ybN7VMHOk4it1UKVfKhmlgMD(DoDSGZ9x9sQsCEMnrM9vmBsMzBfFriiHxb4qqXco3Frfc2eqWHGOtMzAGuebX3OOneeulj5QvZ)7sxXSjYSjRHzkNztYmBlj5QvRkVmcs4vaoeKBPdMe0WSeo6OvQaCOcb7RqWHGOtMzAGuebX3OOneeubWHlt6b5OZh4jpZIHzBjjxT6EEXSjYSW8KrqcVcWHGKlufdWzgKuTOcbBsrWHGOtMzAGuebX3OOneeuAMTKmDLEUI6mtEnDYmtdMTdZIHztZSZVZPNKSghyv1)EMTdZIHzBjjxT6EEXSjYSWmLZSyy244a14WzgIQGJmk3ZSWGztwNGYz2KmZ2ssUA1QYlJGeEfGdbnLvbVcXHkeSkhbhcIozMPbsreeFJI2qqqZVZP9)fFGxYM48vC8YRhGMJzXWSZVZPNYQGxH40dqZXSyy2wsYvRUNxmBIm7lizMfdZghhOghoZqufCKr5EMfgmBY6euoZMKz2wsYvRwvEzeKWRaCii)FXh4LSjoFfhV8OcviOSsCzfocoeSyHGdbj8kahcIlLXbwveeDYmtdKIOcviOb5KFUqWHGfleCiiHxb4qqEf(5Szk(weeDYmtdKIOcbBci4qqcVcWHG(EYefP6rq0jZmnqkIkeSVcbhcIozMPbsreeFJI2qqqPz20mBjz6kDljBzaot1sMMip00jZmnywmm787C6ws2YaCMQLmnrEO)9mBhMfdZMMzh7pgAUunKGNmtswMTBxMDS)yObn5gsWtMjjlZ2Hz7GGeEfGdb1dQaCOcbBsrWHGOtMzAGuebX3OOnee0y)XqZLQHe8KzsYYSyy20mBAMLda5bO50v7k(wZKKvVKQeNNzHbZMmZIHz5aqEaAoTQC4YKEjvjopZcdMnzMfdZoaLwfaoxSKEjvjopZcJhMfhFWSWZSjRvoZIHzxbhXSjYSjnzMfdZo)oNooUSNub4m4(Yoc5maN5VEaxpanhZIHzNFNtpP1tRcMjjREaAoMfdZo)oNgNKfEfCdUVSJqo9a0CmBhMTBxMnnZo)oNMlLXbwv9VNzXWS0rloLywyWSjOCMTdZ2TlZMMz3)roWIJ0aPAnaNPAjdLh0Ag7pgA6f)rFpnywmmRYy25350aPAnaNPAjdLh0Ag7pg6FpZIHztZSZVZP5szCGvv)7zwmmlD0ItjMfgmBcjZSDy2omB3UmBAMD)h5alosdKQ1aCMQLmuEqRzS)yOPx8h990GzXWSZVZPBjzldWzQwY0e5HEjvjopZMiZIvYmBhMfdZMMzNFNtZLY4aRQ(3ZSyyw6OfNsmlmy2esMz7WSD7YSPzwoapDYvAfuAd5ywmmlhaYdqZPj1EqdTMj4g6LuL48mBIpmlwmlgMv4vGNm0rQb5z2ez2ey2omBheKWRaCiO9FgHxb4m5WxiOC4lZjQecIlvdj4juHGv5i4qq0jZmnqkIG4Bu0gccAS)yObn5gsWtMjjlZIHztZSPzwoaKhGMtxTR4Bntsw9sQsCEMfgmBYmlgMLda5bO50QYHlt6LuL48mlmy2Kzwmm7k4iMnrMnHKzwmm787C644YEsfGtpanhZIHzNFNtpP1tRcMjjREaAoMTdZ2TlZMMzNFNtRcaNcXzCGvv)7zwmm7auA))CXs6LCl5BLzMy2omB3UmBAMD(DoTkaCkeNXbwv9VNzXWSZVZPBjzldWzQwY0e5H(3ZSDy2UDz20m787CAva4uioJdSQ6FpZIHztZSZVZPjEo69Kj)pz1)EMTBxMD(DonXZrVNmEqww9VNz7WSyywLXS7)ihyXrAGuTgGZuTKHYdAnJ9hdn9I)OVNgmBhMTBxMnnZU)JCGfhPbs1Aaot1sgkpO1m2Fm00l(J(EAWSyywLXSZVZPbs1Aaot1sgkpO1m2Fm0)EMTdZ2TlZMMz5a80jxPVaxBzCcXSyywoaKhGMtZbhEGcKPAjJVp2O86LuL48mBIpmlwmBhMTBxMnnZYb4PtUsRGsBihZIHz5aqEaAonP2dAO1mb3qVKQeNNzt8HzXIzXWScVc8KHosnipZMiZMaZ2Hz7GGeEfGdbT)Zi8kaNjh(cbLdFzorLqqGMCdj4juHG9fGGdbrNmZ0aPicIVrrBiiO0mBAMD)h5alosNvIlR4nUmrvC4m4YHAVN00l(J(EAWSDywmmBAMTKmDLEkz54KrCU4IsjnDYmtdMTdZIHztZSZVZPZkXLv8gxMOkoCgC5qT3t6FpZ2HzXWSPz25350zL4YkEJltufhodUCO27j9sQsCEMnXhMnbMTdZ2bbj8kahcA)Nr4vaoto8fckh(YCIkHGYkXLvaOcblmdbhcIozMPbsreeFJI2qqqPz20m7(pYbwCKoRexwXBCzIQ4WzWLd1EpPPx8h990Gz7WSyy20mBjz6kTJwjBeNlUOustNmZ0Gz7WSyy20m787C6SsCzfVXLjQIdNbxou79K(3ZSDywmmBAMD(DoDwjUSI34YevXHZGlhQ9EsVKQeNNzt8HztGz7WSDqqcVcWHG2)zeEfGZKdFHGYHVmNOsiOSsCzfoQqWcZrWHGOtMzAGuebj8kahcIl5Sr4vaoto8fckh(YCIkHGuJkWjvaouHG9LIGdbrNmZ0aPics4vaoe0(pJWRaCMC4leuo8L5evcbnjzrfQqqCPAibpHGdblwi4qqcVcWHG6xqtgbrNmZ0aPiQqWMacoeeDYmtdKIii(gfTHGGMFNt3VGMS(3JGeEfGdbTIceQqW(keCii6KzMgifrq8nkAdbbvsMUs3sYwgGZuTKPjYdnDYmtdMfdZQmMD(DoDljBzaot1sMMip0)EeKWRaCiOws2YaCMQLmnrEGkeSjfbhcIozMPbsreeFJI2qqqJ9hdnxQgsWtMjjlcs4vaoeeP2dAO1mb3aviyvocoeeDYmtdKIii(gfTHGGg7pgAUunKGNmtsweKWRaCiio4WduGmvlz89XgLhviyFbi4qq0jZmnqkIG4Bu0gccAak9g96LCl5BLzMywmmlhOobMEqCLNzHXdZMueKWRaCiOn6rfcwygcoeeDYmtdKIii(gfTHGG4a1jW0dIR8mlmEy2KIGeEfGdb5OfWdW3BMrrOcblmhbhcIozMPbsreKWRaCiizi9vGNm(gzvrq8nkAdbbTKBjFRmZecIReptMswCu5rWIfQqW(srWHGOtMzAGuebX3OOnee0au6vuG0l5wY3kZmXSyywoqDcm9G4kpZMiZMueKWRaCiOvuGqfcwSsgbhcIozMPbsreeFJI2qqqcVc8KHosnipZcdMflMfdZk8kWtMbO0v7k(wdxkM9Hztgbj8kahcQAxX3A4sHkeSyHfcoeeDYmtdKIii(gfTHGG4a1jW0dIR8mBImRYrqcVcWHG8TlnqfQqqCaipanNhbhcwSqWHGeEfGdb1dQaCii6KzMgifrfc2eqWHGeEfGdb1sYwgY7PJtii6KzMgifrfc2xHGdbj8kahcAMbGHX9xLqq0jZmnqkIkeSjfbhcs4vaoe0KwpTkehoeeDYmtdKIOcbRYrWHGeEfGdbjlxoYuGDPRqq0jZmnqkIkeSVaeCiiHxb4qq5axB5nVW)bov6keeDYmtdKIOcblmdbhcs4vaoeKlwAMbGbcIozMPbsruHGfMJGdbj8kahcsoo5RvYgUKZii6KzMgifrfc2xkcoeeDYmtdKIii(gfTHGGMFNtpjznoWQQ)9iiHxb4qqZn8vooCg3FrfcwSsgbhcIozMPbsreeFJI2qqqPz2bO0QaW5IL0vWvioCmB3UmRWRapzOJudYZSWGzXIz7WSyy2bO0v7k(wZKKvxbxH4WHGeEfGdbfhx2tQaCOcblwyHGdbj8kahcAsRNwfqq0jZmnqkIkeSyLacoeeDYmtdKIiiHxb4qqCL4zqTGl4Mzw8fcICoIxMtujeexjEgul4cUzMfFHkeSy9keCii6KzMgifrq8nkAdbbvaC4YKMda5bO58mlgMnnZwHkzkGzeeZMiZk8kaNHda5bO5y23mBcmB3UmRWRapzOJudYZSWGzXIz7GGeEfGdbjxOkgGZmiPArfcwSskcoeKWRaCiivsfSkzaot(ZJHzSKO6rq0jZmnqkIkeSyPCeCiiHxb4qqFpzIIu9ii6KzMgifrfQqq9lXbQtPqWHGfleCiiHxb4qqke3yPHX3hBuEeeDYmtdKIOcbBci4qq0jZmnqkIG4Bu0gccAS)yO5s1qcEYmjzzwmmBjz6kTJwjBeNlUOustNmZ0GzXWSZVZP5szCGvv)7rqcVcWHG6xqtgviyFfcoeeDYmtdKIii(gfTHGGugZo2Fm0CPAibpzMKSmlgMvzm7y)XqdAYnKGNmtsweKWRaCiOjjRXbwvuHGnPi4qq0jZmnqkIG4Bu0gccQKmDLULKTmaNPAjttKhA6KzMgmlgMDS)yObn5gsWtMjjlZIHzNFNtRcaNcXzCGvv)7rqcVcWHGAjzldWzQwY0e5bQqWQCeCii6KzMgifrq8nkAdbbn2Fm0GMCdj4jZKKLzXWSZVZPvbGtH4moWQQ)9iiHxb4qqnRuTOcviiqtUHe8ecoeSyHGdbrNmZ0aPicIVrrBiiOsY0v6ws2YaCMQLmnrEOPtMzAWSyywLXSZVZPBjzldWzQwY0e5H(3JGeEfGdb1sYwgGZuTKPjYduHGnbeCii6KzMgifrq8nkAdbbn2Fm0GMCdj4jZKKfbj8kahcIu7bn0AMGBGkeSVcbhcIozMPbsreeFJI2qqqJ9hdnOj3qcEYmjzrqcVcWHG4GdpqbYuTKX3hBuEuHGnPi4qq0jZmnqkIGeEfGdbjdPVc8KX3iRkcIVrrBiiOLCl5BLzMqqCL4zYuYIJkpcwSqfcwLJGdbrNmZ0aPics4vaoeKkaCUyjeeFJI2qqql5wY3kZmXSD7YSZVZPXjzHxb3G7l7iKt)7rqCL4zYuYIJkpcwSqfc2xacoeeDYmtdKIiiHxb4qq()5ILqq8nkAdbbTKBjFRmZecIReptMswCu5rWIfQqWcZqWHGOtMzAGuebX3OOneeuAMD(DonXZrVNm5)jR(3ZSD7YSZVZPjEo69KXdYYQ)9mBheKWRaCiiFjR)V4iuHGfMJGdbrNmZ0aPicIVrrBiiO0mlXZrVN0XzY)twMTBxML45O3tApilR5OxUy2omB3UmBAML45O3t64m5)jlZIHzNFNtt8C07jt(FYQj1EqdT0Gz7GGeEfGdb5lzDXsOcb7lfbhcs4vaoeuZkvlcIozMPbsruHkuHGWtRpahc2esoHKXkzSWcb1i7fhopccM6KiWubBsaSVqW0mlZcxlXSHApylM1bwMnjmhaYdqZ5tcZSl9I)yPbZ6bQeZk)cOkfnywERC4iVMLkjrCeZI1RGPz2xc4WtBrdMfkuFjmRxPRKxMztIYSfGzts8fMDe4dFaoMf0tRuGLzt)UdZMgRxUJMLILkjqThSfny2xkZk8kahZMdF51SuiiFpXrWIvYjfb1VaxKje0Rz2xOVSJqoMnj5(Jbl1Rz2K48cmPLzXclSz2esoHKzPyPEnZ(sALdh5HPzPEnZctHztcooy7bRueZ(sK6DskaCkehZ2VbyJkipZMoCmRNQkoCmB4zwElXvGgD0SuSuVMztI9Ye)x0GzNKdSeZYbQtPy2jHloVMztIW5uF5z2dCWuALv19ZmRWRaCEMfCzL0SucVcW519lXbQtPG)5TcXnwAy89XgLNL61mRWRaCED)sCG6uk4FEZLY4aRk2H7zS)yO5s1qcEYmjzXusMUs7OvYgX5IlkL00jZmnyPeEfGZR7xIduNsb)Z7(f0KXoCpJ9hdnxQgsWtMjjlMsY0vAhTs2ioxCrPKMozMPbM5350CPmoWQQ)9SucVcW519lXbQtPG)59KK14aRk2H7rzJ9hdnxQgsWtMjjlgLn2Fm0GMCdj4jZKKLLs4vaoVUFjoqDkf8pVBjzldWzQwY0e5b2H7PKmDLULKTmaNPAjttKhA6KzMgyg7pgAqtUHe8KzsYIz(DoTkaCkeNXbwv9VNLs4vaoVUFjoqDkf8pVBwPAXoCpJ9hdnOj3qcEYmjzXm)oNwfaofIZ4aRQ(3ZsXs9AMnj2lt8FrdMLWtRsmBfQeZwTeZk8cSmB4zwbVezzMjnlLWRaC(hVc)C2mfFllLWRaCE4FE)9Kjks1Zsj8kaNh(N39Gkah2H7jD6sY0v6ws2YaCMQLmnrEOPtMzAGz(DoDljBzaot1sMMip0)(oysp2Fm0CPAibpzMKSD7o2Fm0GMCdj4jZKKTthwkHxb48W)8E)Nr4vaoto8f2NOspCPAibpHD4Eg7pgAUunKGNmtswmPtZbG8a0C6QDfFRzsYQxsvIZdJKXWbG8a0CAv5WLj9sQsCEyKmMbO0QaW5IL0lPkX5HXdo(a(K1khZk4OetAYyMFNthhx2tQaCgCFzhHCgGZ8xpGRhGMdZ87C6jTEAvWmjz1dqZHz(Donojl8k4gCFzhHC6bO560TB65350CPmoWQQ)9yOJwCkbJeuENUDtV)JCGfhPbs1Aaot1sgkpO1m2Fm00l(J(EAGrzZVZPbs1Aaot1sgkpO1m2Fm0)EmPNFNtZLY4aRQ(3JHoAXPemsi5oD62n9(pYbwCKgivRb4mvlzO8GwZy)XqtV4p67PbM5350TKSLb4mvlzAI8qVKQeNprSsUdM0ZVZP5szCGvv)7XqhT4ucgjKCNUDtZb4PtUsRGsBihgoaKhGMttQ9GgAntWn0lPkX5t8blmcVc8KHosniFIj0PdlLWRaCE4FEV)Zi8kaNjh(c7tuPhqtUHe8e2H7zS)yObn5gsWtMjjlM0P5aqEaAoD1UIV1mjz1lPkX5HrYy4aqEaAoTQC4YKEjvjopmsgZk4OetizmZVZPJJl7jvao9a0CyMFNtpP1tRcMjjREaAUoD7ME(DoTkaCkeNXbwv9VhZauA))CXs6LCl5BLzM60TB65350QaWPqCghyv1)EmZVZPBjzldWzQwY0e5H(33PB30ZVZPvbGtH4moWQQ)9ysp)oNM45O3tM8)Kv)772D(DonXZrVNmEqww9VVdgLT)JCGfhPbs1Aaot1sgkpO1m2Fm00l(J(EA0PB307)ihyXrAGuTgGZuTKHYdAnJ9hdn9I)OVNgyu287CAGuTgGZuTKHYdAnJ9hd9VVt3UP5a80jxPVaxBzCcHHda5bO50CWHhOazQwY47JnkVEjvjoFIpy1PB30CaE6KR0kO0gYHHda5bO50KApOHwZeCd9sQsC(eFWcJWRapzOJudYNycD6Wsj8kaNh(N37)mcVcWzYHVW(ev6jRexwbGD4EsNE)h5alosNvIlR4nUmrvC4m4YHAVN00l(J(EA0bt6sY0v6PKLJtgX5IlkL00jZmn6Gj987C6SsCzfVXLjQIdNbxou79K(33bt65350zL4YkEJltufhodUCO27j9sQsC(eFsOthwkHxb48W)8E)Nr4vaoto8f2NOspzL4YkCSd3t607)ihyXr6SsCzfVXLjQIdNbxou79KMEXF03tJoysxsMUs7OvYgX5IlkL00jZmn6Gj987C6SsCzfVXLjQIdNbxou79K(33bt65350zL4YkEJltufhodUCO27j9sQsC(eFsOthwkHxb48W)8Ml5Sr4vaoto8f2NOspQrf4KkahlLWRaCE4FEV)Zi8kaNjh(c7tuPNjjllflLWRaCE9KK9zsYACGvf7W9OS5350tswJdSQ6FplLWRaCE9KKf(N39Gkah2H7jD65350tA90QGzsYQ)9D7o)oNooUSNub4m4(Yoc5maN5VEax)77GjTYg7pgAUunKGNmtswmkBS)yObn5gsWtMjjBNoSucVcW51tsw4FEVcE6aFVXT0btuILs4vaoVEsYc)ZBo4WduGmvlz89XgLh7W9OSX(JHMlvdj4jZKKfJYg7pgAqtUHe8KzsYYsj8kaNxpjzH)59KwpTkyMKSyhUN0ZVZPxbpDGV34w6GjkP)9D7QmoapDYvA80vTkTDyPeEfGZRNKSW)8ooUSNub4WoCpPNFNtVcE6aFVXT0btus)772vzCaE6KR04PRAvA7Wsj8kaNxpjzH)5nP2dAO1mb3a7W9KwzJ9hdnxQgsWtMjjlgLn2Fm0GMCdj4jZKKTt3UcVc8KHosnipmEsGLs4vaoVEsYc)Z7PSk4vioSd3t6sY0v65kQZm510jZmn6Gj987C6jjRXbwv9VVdlLWRaCE9KKf(N3Xco3FXoCpZVZPJfCU)QxsvIZNyYALZsj8kaNxpjzH)5TmK(kWtgFJSQyZvINjtjloQ8pyHD4EwYTKVvMzILs4vaoVEsYc)ZBva4CXsyhUN0ZVZPXjzHxb3G7l7iKt)7Xm2Fm0GMCdj4jZKKTdgHxbEYqhPgKpXNxXsj8kaNxpjzH)5D1UIV1mjzXMReptMswCu5FWc7W9SKBjFRmZu3UdqPR2v8TMjjR2xcxHeFv3UPhGsxTR4BntswTVeUcjMum7)ihyXr6835K4CFpnmK6CfoPPx8h990Ot3UcVc8KHosnipmuolLWRaCE9KKf(N3(MONWoCpZVZPJJl7jvaodUVSJqodWz(RhW1dqZHz(Do9KwpTkyMKS6bO5Wi8kWtg6i1G8W4jPSucVcW51tsw4FERk)m2H7z(DoDCCzpPcWP)9yeEf4jdDKAq(etGLs4vaoVEsYc)ZBv5NXoCpPNFNt7f8coYWbQtPKR0(s4kaJhS6Gj987C6caQwJCddpln6FFhmZVZPJJl7jvao9VhJWRapzOJudY)KalLWRaCE9KKf(N3QYHltyhUN5350XXL9KkaN(3Jr4vGNm0rQb5t85vSucVcW51tsw4FERcaNlwcBUs8mzkzXrL)blSd3ZsUL8TYmtyeEf4jdDKAq(eFEflLWRaCE9KKf(N3QYpJD4Esp)oNUaGQ1i3WWZsJ2xcxby8KqNUDtp)oNUaGQ1i3WWZsJ(3Jz(DoDbavRrUHHNLg9sQsC(eXsR8oD7ME(DoTxWl4idhOoLsUs7lHRamEEvhwkHxb486jjl8pVR2v8TMjjl2H7r4vGNm0rQb5HbwSucVcW51tsw4FERcaNlwc7W9KE(Donojl8k4gCFzhHC6FpMX(JHMlvdj4jZKKTdgHxbEYqhPgKpXNx1TB653504KSWRGBW9LDeYP)9yu2y)XqZLQHe8KzsYIrzJ9hdnOj3qcEYmjz7Gr4vGNm0rQb5t85vSucVcW51tsw4FERkhUmHD4EsVcokryEYDWi8kWtg6i1G8jMuwkHxb486jjl8pV7)z80gWecBUs8mzkzXrL)blSd3Zau6QDfFRzsYQ9LWvagjWsj8kaNxpjzH)5D1UIV1mjzzPeEfGZRNKSW)8wv(zwkHxb486jjl8pV9nrpzMKSSuSuVMzfEfGZd)ZBUKZgHxb4m5WxyFIk9OgvGtQaCSuVMzfEfGZd)Z7Mipm8wzXrSuVMzfEfGZd)ZBUKZgHxb4m5WxyFIk9WbG8a0CEwQxZScVcW5H)5TQ8ZyhUNvWr6b5cEujMqYyeEf4jdDKAq(etkl1RzwHxb48W)8wv(zSd3Zk4i9GCbpQetizmK3thN0CW5YbVmYnm(AdhPvLxyWIrzZVZP9TY2thnm8S041)EwQxZScVcW5H)5DSGZ9xSd3dh4RNK72n9k4iyWb(cJatOnksNfLOLggv5inDYmtdmcVc8KHosnipmsOdl1RzwHxb48W)8U)NXtBatiSlzXrLjCpdqPR2v8TMjjR2xcxHNbO0v7k(wZKKvRkVSXxcxbpl1RzwHxb48W)8wfaoxSe2LS4OYeUNbO0QaW5IL0l5wY3kZmHr4vGNm0rQb5tmbwQxZScVcW5H)5D1UIVf7W9KE(DoDCCzpPcWPhGMdJWRapzOJudYddS60TB65350XXL9KkaN(3Jr4vGNm0rQb5Hrs7Ws9AMv4vaop8pV9nrpHD4EMFNthhx2tQaC6bO5Wi8kWtg6i1G8WiPSuVMzfEfGZd)ZBv5WLjSd3Zau6QDfFRzsYQRGRqC4yPEnZk8kaNh(N3QaW5ILWUKfhvMW9m)oNgNKfEfCdUVSJqo9VhJWRapzOJudYNycSuVMzfEfGZd)Z7QDfFll1Rz2KqJCMzBIQLztsbGZflXSnr1YSjHaQK0xobwQxZScVcW5H)5TkaCUyjSd3JatOnks3dAO1aCMQLmQaWPx5uagyHr4vGNm0rQb5FWIL61mRWRaCE4FE7BIEILILs4vaoVwnQaNub4EIfCU)ID4EIJduJdNziQcoYOCpmIfCU)AgIQGJmv7s(wqEGz(DoDSGZ9x9sQsC(eFvsUv8fXsj8kaNxRgvGtQaCW)82T0btcAywchD0kvaoSd3tlj5QvZ)7sxLyYAyMYtYTKKRwTQ8YSucVcW51Qrf4Kkah8pVLlufdWzgKuTyhUNcGdxM0dYrNpWtEmTKKRwDpVseMNmlLWRaCETAuboPcWb)Z7PSk4vioSd3t6sY0v65kQZm510jZmn6Gj987C6jjRXbwv9VVdMwsYvRUNxjcZuoM44a14WzgIQGJmk3dJK1jO8KClj5QvRkVmlLWRaCETAuboPcWb)ZB)FXh4LSjoFfhV8yhUN5350()IpWlztC(koE51dqZHz(Do9uwf8keNEaAomTKKRwDpVs8fKmM44a14WzgIQGJmk3dJK1jO8KClj5QvRkVmlflLWRaCEnhaYdqZ5F6bvaowkHxb48AoaKhGMZd)Z7ws2YqEpDCILs4vaoVMda5bO58W)8EMbGHX9xLyPeEfGZR5aqEaAop8pVN06PvH4WXsj8kaNxZbG8a0CE4FEllxoYuGDPRyPeEfGZR5aqEaAop8pVZbU2YBEH)dCQ0vSucVcW51CaipanNh(N3UyPzgagSucVcW51CaipanNh(N3YXjFTs2WLCMLs4vaoVMda5bO58W)8EUHVYXHZ4(l2H7z(Do9KK14aRQ(3Zsj8kaNxZbG8a0CE4FEhhx2tQaCyhUN0dqPvbGZflPRGRqC462v4vGNm0rQb5HbwDWmaLUAxX3AMKS6k4kehowkHxb48AoaKhGMZd)Z7jTEAvGLs4vaoVMda5bO58W)8(7jtuKk2KZr8YCIk9WvINb1cUGBMzXxSucVcW51CaipanNh(N3YfQIb4mdsQwSd3tbWHltAoaKhGMZJjDfQKPaMrqjYbG8a0CjrtOBxHxbEYqhPgKhgy1HLs4vaoVMda5bO58W)8wLubRsgGZK)8yygljQEwkHxb48AoaKhGMZd)Z7VNmrrQEwkwkHxb48AUunKGNE6xqtMLs4vaoVMlvdj4j4FEVIce2H7z(DoD)cAY6FplLWRaCEnxQgsWtW)8ULKTmaNPAjttKhyhUNsY0v6ws2YaCMQLmnrEOPtMzAGrzZVZPBjzldWzQwY0e5H(3Zsj8kaNxZLQHe8e8pVj1EqdTMj4gyhUNX(JHMlvdj4jZKKLLs4vaoVMlvdj4j4FEZbhEGcKPAjJVp2O8yhUNX(JHMlvdj4jZKKLLs4vaoVMlvdj4j4FEVrp2H7zak9g96LCl5BLzMWWbQtGPhex5HXtszPeEfGZR5s1qcEc(N3oAb8a89Mzue2H7HduNatpiUYdJNKYsj8kaNxZLQHe8e8pVLH0xbEY4BKvfBUs8mzkzXrL)blSd3ZsUL8TYmtSucVcW51CPAibpb)Z7vuGWoCpdqPxrbsVKBjFRmZegoqDcm9G4kFIjLLs4vaoVMlvdj4j4FExTR4BnCPWoCpcVc8KHosnipmWcJWRapzgGsxTR4BnCPEsMLs4vaoVMlvdj4j4FE7BxAGD4E4a1jW0dIR8jQCwkwkHxb486SsCzf(dxkJdSQSuSucVcW51zL4YkGhva4uioJdSQSuSucVcW51GMCdj4PNws2YaCMQLmnrEGD4EkjtxPBjzldWzQwY0e5HMozMPbgLn)oNULKTmaNPAjttKh6FplLWRaCEnOj3qcEc(N3KApOHwZeCdSd3Zy)XqdAYnKGNmtswwkHxb48AqtUHe8e8pV5GdpqbYuTKX3hBuESd3Zy)XqdAYnKGNmtswwkHxb48AqtUHe8e8pVLH0xbEY4BKvfBUs8mzkzXrL)blSd3ZsUL8TYmtSucVcW51GMCdj4j4FERcaNlwcBUs8mzkzXrL)blSd3ZsUL8TYmtD7o)oNgNKfEfCdUVSJqo9VNLs4vaoVg0KBibpb)ZB))CXsyZvINjtjloQ8pyHD4EwYTKVvMzILs4vaoVg0KBibpb)ZBFjR)V4iSd3t65350eph9EYK)NS6FF3UZVZPjEo69KXdYYQ)9DyPeEfGZRbn5gsWtW)82xY6ILWoCpPjEo69Koot(FY2TlXZrVN0EqwwZrVC1PB30eph9EshNj)pzXm)oNM45O3tM8)KvtQ9GgAPrhwkHxb48AqtUHe8e8pVBwPArfQqi]] )

end