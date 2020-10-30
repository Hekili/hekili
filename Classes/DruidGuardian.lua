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

    spec:RegisterPack( "Guardian", 20201029, [[dWuqgbqiripsvIUejIkBck9jsePgLi1PKkwLQuPEfOQzbv6wKiu7IIFbkgMiQJrcTmrWZuLW0uLKRrI02uLk(MiuACQsvDoseSoseY8erUNQyFQs5GKikwij4HQsknrvjf5IKikTrsej(OQKcNKerSsrYmfHcUPiu0obL(PiuOHQkPOwQQuj9uv1ubvUkjIQ(kjIK2lK)sPbtQdtSyf9yunzfUmYMPYNHIrlLoTWQvLkXRHkMTOUnjTBL(nWWLQoUiuTCvEovnDjxhKTdv9DPy8QsvopjQ1RkPA(sL2pkJuebh6pKIqWMqYjKSIj)IKnjNCckbfvcOFPCpH(9chhbdH(ROsO)RbKCJqw0VxuodKbco03dGooH(Tv17vIGbgmr1cnnCGkm(qfklvaw(jUcgFOYHb9NqrUusw0e9hsriyti5eswXKFrYMKtoH3)fkI(cu1co0)hQVw0VngdArt0FqEo6)sM(1asUrilt)A6GIbl1lz6eJ8cmPJPtqjGltNqYjKmlfl1lz6xBRSyiVsel1lzALyMwjz5GRhCsrm9RvkysmbGfNyz6(laxub5z60HJP9uvXIHPdptZBjoo0OJHL6LmTsmtRK3tm97kTuJKnOFo8Lhbh6NvMlNaqWHGvreCOVWRaSOVkaS4eR1bov0NwzMPbsbuHk0FsYHGdbRIi4qFALzMgifqF(ffDHG(jIPNqoNzsYzDGt1a1J(cVcWI(tsoRdCQOcbBci4qFALzMgifqF(ffDHG(Pz60m9eY5mt680HJDsYzG6z6UDz6jKZzILl3kvawlgi5gHSwGZcDEa3a1Z0DyASmDAMorm94GIHHlvdj4j7KKJPXY0jIPhhummGMCdj4j7KKJP7W0DqFHxbyr)EqfGfviyFbco0x4vaw0)e80cG8w3r7RRm6tRmZ0aPaQqW(keCOpTYmtdKcOp)IIUqq)eX0JdkggUunKGNStsoMgltNiMECqXWaAYnKGNStso0x4vaw0Ndw8aCiB1swFFCr5rfcwLIGd9PvMzAGua95xu0fc6NMPNqoN5e80cG8w3r7RRSbQNP72LPtetZb4Pv2YGN2Qv5JP7G(cVcWI(t680HdQqW(oi4qFALzMgifqF(ffDHG(Pz6jKZzobpTaiV1D0(6kBG6z6UDz6eX0CaEALTm4PTAv(y6oOVWRaSOFSC5wPcWIkeSjweCOpTYmtdKcOp)IIUqq)0mDIy6XbfddxQgsWt2jjhtJLPtetpoOyyan5gsWt2jjht3HP72LPfEf4jlTKAqEM(ThMob0x4vaw0Nu7bn0zNGDGkeSVpco0NwzMPbsb0NFrrxiOFAMUKmTLzEI6mtEdTYmtdMUdtJLPtZ0tiNZmj5SoWPAG6z6oOVWRaSO)uoC84elQqWQeqWH(0kZmnqkG(8lk6cb9NqoNjoW6GoZrQsSEMojMozJsrFHxbyr)4aRd6qfcwftgbh6tRmZ0aPa6ZVOOle0)i3r(wzMj0x4vaw0xgsFf4jRVrov0NRmpt2somu5rWQiQqWQOIi4qFALzMgifqF(ffDHG(Pz6jKZzWizHxb3IbsUriRbQNPXY0JdkggqtUHe8KDsYX0DyASmTWRapzPLudYZ0j9W0Va9fEfGf9vbG1fhHkeSkMaco0NwzMPbsb0NFrrxiO)rUJ8TYmtmD3Um9auMQ9eFRDsYz8LWXHPtIPFbt3TltNMPhGYuTN4BTtsoJVeoomDsm9RyASm9bTKdCyitgY5KyDqEAyj15jCYqjou03tdMUdt3Tltl8kWtwAj1G8m9BmTsrFHxbyr)Q9eFRDsYH(CL5zYwYHHkpcwfrfcwfFbco0NwzMPbsb0NFrrxiO)eY5mXYLBLkaRfdKCJqwlWzHopGBgGMLPXY0tiNZmPZtho2jjNzaAwMgltl8kWtwAj1G8m9Bpm9RqFHxbyrFFt0t2jjhQqWQ4RqWH(0kZmnqkG(8lk6cb9NqoNjwUCRubynq9mnwMw4vGNS0sQb5z6Ky6eqFHxbyrFvbkJkeSkQueCOpTYmtdKcOp)IIUqq)0m9eY5mEbVGHSCG6ukzlJVeoom9BpmTImDhMgltNMPNqoNPaGQ1k7WYZsJbQNP7W0yz6jKZzILl3kvawduptJLPfEf4jlTKAqEM(HPta9fEfGf9vfOmQqWQ47GGd9PvMzAGua95xu0fc6pHCotSC5wPcWAG6zASmTWRapzPLudYZ0j9W0Va9fEfGf9vLftMqfcwftSi4qFALzMgifqF(ffDHG(h5oY3kZmX0yzAHxbEYslPgKNPt6HPFb6l8kal6RcaRloc95kZZKTKddvEeSkIkeSk((i4qFALzMgifqF(ffDHG(Pz6jKZzkaOATYoS8S0y8LWXHPF7HPtGP7W0D7Y0Pz6jKZzkaOATYoS8S0yG6zASm9eY5mfauTwzhwEwAmhPkX6z6KyAfnkLP7W0D7Y0Pz6jKZz8cEbdz5a1PuYwgFjCCy63Ey6xW0DqFHxbyrFvbkJkeSkQeqWH(0kZmnqkG(8lk6cb9fEf4jlTKAqEM(nMwr0x4vaw0VApX3ANKCOcbBcjJGd9PvMzAGua95xu0fc6NMPNqoNbJKfEfClgi5gHSgOEMgltpoOyy4s1qcEYoj5y6omnwMw4vGNS0sQb5z6KEy6xW0D7Y0Pz6jKZzWizHxb3IbsUriRbQNPXY0jIPhhummCPAibpzNKCmnwMorm94GIHb0KBibpzNKCmDhMgltl8kWtwAj1G8mDspm9lqFHxbyrFvayDXrOcbBckIGd9PvMzAGua95xu0fc6NMPpbdX0jX0VFYmDhMgltl8kWtwAj1G8mDsm9RqFHxbyrFvzXKjuHGnHeqWH(0kZmnqkG(8lk6cb9hGYuTN4BTtsoJVeoom9BmDcOVWRaSOFpugpDXRtOpxzEMSLCyOYJGvruHGnHxGGd9fEfGf9R2t8T2jjh6tRmZ0aPaQqWMWRqWH(cVcWI(Qcug9PvMzAGuaviytqPi4qFHxbyrFFt0t2jjh6tRmZ0aPaQqf6RgvGrQaSi4qWQico0NwzMPbsb0NFrrxiOFSCGASySdrvWqwL6z63y64aRd6SdrvWq2Q9iFlipyASm9eY5mXbwh0zosvI1Z0jX0VGPF3mDR4lc9fEfGf9JdSoOdviytabh6tRmZ0aPa6ZVOOle0VKfNyXW0yz6wsYvRPNxmDsm97Ou0x4vaw0)OLAKmQqW(ceCOpTYmtdKcOp)IIUqq)swCIfdtJLPBjjxTMEEX0jX0VJsrFHxbyrF3r7Rh0WEegAPtQaSOcb7RqWH(0kZmnqkG(8lk6cb9lagmzYmihT(ap5zASmDlj5Q10ZlMojM(9tg9fEfGf9LnuflWzhKuTOcbRsrWH(0kZmnqkG(8lk6cb9tZ0LKPTmZtuNzYBOvMzAW0DyASmDAMEc5CMjjN1bovdupt3HPXY0TKKRwtpVy6Ky6eRszASmDSCGASySdrvWqwL6z63y6KnjOuM(DZ0TKKRwJQ8EOVWRaSO)uoC84elQqW(oi4qFALzMgifqF(ffDHG(tiNZ4Ho8bEjBJ1xXYlVzaAwMgltpHCoZuoC84eRzaAwMglt3ssUAn98IPtIPFNKzASmDSCGASySdrvWqwL6z63y6KnjOuM(DZ0TKKRwJQ8EOVWRaSOVh6Wh4LSnwFflV8OcvOFwzUCchbhcwfrWH(cVcWI(CPSoWPI(0kZmnqkGkuH(dYjq5cbhcwfrWH(cVcWI(ECGYz7u8TOpTYmtdKcOcbBci4qFHxbyrFipzJIu9OpTYmtdKcOcb7lqWH(0kZmnqkG(8lk6cb9tZ0Pz6sY0wMwsUYcC2QLSnrEyOvMzAW0yz6jKZzAj5klWzRwY2e5HbQNP7W0yz60m94GIHHlvdj4j7KKJP72LPhhummGMCdj4j7KKJP7W0DqFHxbyr)EqfGfviyFfco0NwzMPbsb0x4vaw0)GwRWRaS2C4l0NFrrxiO)4GIHHlvdj4j7KKJPXY0Pz60mnhaYdqZAQ2t8T2jjN5ivjwpt)gtNmtJLP5aqEaAwJQSyYK5ivjwpt)gtNmtJLPhGYOcaRloYCKQeRNPF7HPXWhmn8mDYgLY0yz6tWqmDsm9RsMPXY0tiNZelxUvQaSwmqYnczTaNf68aUzaAwMgltpHCoZKopD4yNKCMbOzzASm9eY5myKSWRGBXaj3iK1manlt3HP72LPtZ0tiNZWLY6aNQbQNPXY00shgLz63y6eukt3HP72LPtZ0h0soWHHmaPATaNTAjlLh0zhhummuIdf990GPXY0jIPNqoNbivRf4SvlzP8Go74GIHbQNPXY0Pz6jKZz4szDGt1a1Z0yzAAPdJYm9BmDcjZ0Dy6omD3UmDAM(GwYbomKbivRf4SvlzP8Go74GIHHsCOOVNgmnwMEc5CMwsUYcC2QLSnrEyosvI1Z0jX0kMmt3HPXY0Pz6jKZz4szDGt1a1Z0yzAAPdJYm9BmDcjZ0Dy6UDz60mnhGNwzldokFHSmnwMMda5bOznKApOHo7eSdZrQsSEMoPhMwrMgltl8kWtwAj1G8mDsmDcmDhMUd6NdFzxrLqFUunKGNqfcwLIGd9PvMzAGua9fEfGf9pO1k8kaRnh(c95xu0fc6poOyyan5gsWt2jjhtJLPtZ0PzAoaKhGM1uTN4BTtsoZrQsSEM(nMozMgltZbG8a0SgvzXKjZrQsSEM(nMozMgltFcgIPtIPtizMgltpHCotSC5wPcWAgGMLPXY0tiNZmPZtho2jjNzaAwMUdt3TltNMPNqoNrfawCI16aNQbQNPXY0dqz8qRloYCK7iFRmZet3HP72LPtZ0tiNZOcaloXADGt1a1Z0yz6jKZzAj5klWzRwY2e5HbQNP7W0D7Y0Pz6jKZzubGfNyToWPAG6zASmDAMEc5CgINJEpzZqRCgOEMUBxMEc5CgINJEpz9GSCgOEMUdtJLPtetFql5ahgYaKQ1cC2QLSuEqNDCqXWqjou03tdMUdt3TltNMPpOLCGddzas1AboB1swkpOZooOyyOehk67PbtJLPtetpHCodqQwlWzRwYs5bD2Xbfddupt3HP72LPtZ0CaEALTmBGPTSoHyASmnhaYdqZA4GfpahYwTK13hxuEZrQsSEMoPhMwrMUdt3TltNMP5a80kBzWr5lKLPXY0CaipanRHu7bn0zNGDyosvI1Z0j9W0kY0yzAHxbEYslPgKNPtIPtGP7W0Dq)C4l7kQe6dAYnKGNqfc23bbh6tRmZ0aPa6l8kal6FqRv4vawBo8f6ZVOOle0pntNMPpOLCGddzYkZLt8wxMOkwmwm5qT3tgkXHI(EAW0DyASmDAMUKmTLzkzz5KvCUyJszdTYmtdMUdtJLPtZ0tiNZKvMlN4TUmrvSySyYHAVNmq9mDhMgltNMPNqoNjRmxoXBDzIQyXyXKd1EpzosvI1Z0j9W0jW0Dy6oOFo8LDfvc9ZkZLtaOcbBIfbh6tRmZ0aPa6l8kal6FqRv4vawBo8f6ZVOOle0pntNMPpOLCGddzYkZLt8wxMOkwmwm5qT3tgkXHI(EAW0DyASmDAMUKmTLXrNKTIZfBukBOvMzAW0DyASmDAMEc5CMSYC5eV1LjQIfJftou79KbQNP7W0yz60m9eY5mzL5YjERltuflglMCO27jZrQsSEMoPhMobMUdt3b9ZHVSROsOFwzUCchviyFFeCOpTYmtdKcOVWRaSOpxYzRWRaS2C4l0ph(YUIkH(QrfyKkalQqWQeqWH(0kZmnqkG(cVcWI(h0AfEfG1MdFH(5Wx2vuj0FsYHkuH(CPAibpHGdbRIi4qFHxbyr)(d0KrFALzMgifqfc2eqWH(0kZmnqkG(8lk6cb9NqoNP)anzdup6l8kal6FcoeQqW(ceCOpTYmtdKcOp)IIUqq)sY0wMwsUYcC2QLSnrEyOvMzAW0yz6eX0tiNZ0sYvwGZwTKTjYddup6l8kal63sYvwGZwTKTjYduHG9vi4qFALzMgifqF(ffDHG(JdkggUunKGNStso0x4vaw0Nu7bn0zNGDGkeSkfbh6tRmZ0aPa6ZVOOle0FCqXWWLQHe8KDsYH(cVcWI(CWIhGdzRwY67JlkpQqW(oi4qFALzMgifqF(ffDHG(dqzUO3CK7iFRmZetJLP5a1jW2dIT8m9Bpm9RqFHxbyr)l6rfc2elco0NwzMPbsb0NFrrxiOphOob2EqSLNPF7HPFf6l8kal67OdWdaK3oJIqfc23hbh6tRmZ0aPa6ZVOOle0)i3r(wzMj0x4vaw0xgsFf4jRVrov0NRmpt2somu5rWQiQqWQeqWH(0kZmnqkG(8lk6cb9hGYCcoK5i3r(wzMjMgltZbQtGTheB5z6Ky6xH(cVcWI(NGdHkeSkMmco0NwzMPbsb0NFrrxiOVWRapzPLudYZ0VX0kY0yzAHxbEYoaLPApX3A5sX0pmDYOVWRaSOF1EIV1YLcviyvureCOpTYmtdKcOp)IIUqqFoqDcS9GylptNetRu0x4vaw033E0avOc95aqEaAwpcoeSkIGd9fEfGf97bvaw0NwzMPbsbuHGnbeCOVWRaSOFljxzjVNwoH(0kZmnqkGkeSVabh6l8kal6pZaWW6GoLrFALzMgifqfc2xHGd9fEfGf9N05PdNyXG(0kZmnqkGkeSkfbh6l8kal6lhxwYwG7OTqFALzMgifqfc23bbh6l8kal6NdmTL3(UanWOsBH(0kZmnqkGkeSjweCOVWRaSOVloAMbGb6tRmZ0aPaQqW((i4qFHxbyrFz5KVojB5soJ(0kZmnqkGkeSkbeCOpTYmtdKcOp)IIUqq)jKZzMKCwh4unq9OVWRaSO)8cFLJfJ1bDOcbRIjJGd9PvMzAGua95xu0fc6NMPhGYOcaRloYubhNyXW0D7Y0cVc8KLwsnipt)gtRit3HPXY0dqzQ2t8T2jjNPcooXIb9fEfGf9JLl3kvawuHGvrfrWH(cVcWI(t680Hd6tRmZ0aPaQqWQyci4qFALzMgifqFHxbyrFUY8mOoWgC7ml(c9jNJ4LDfvc95kZZG6aBWTZS4luHGvXxGGd9PvMzAGua95xu0fc6xamyYKHda5bOz9mnwMontxHkzlGDeetNetl8kaRLda5bOzzAyy6ey6UDzAHxbEYslPgKNPFJPvKP7G(cVcWI(YgQIf4SdsQwuHGvXxHGd9fEfGf9vjvWPSf4SziEmSJJevp6tRmZ0aPaQqWQOsrWH(cVcWI(qEYgfP6rFALzMgifqfQq)(J4a1Pui4qWQico0x4vaw0hNyhhnS((4IYJ(0kZmnqkGkeSjGGd9PvMzAGua95xu0fc6poOyy4s1qcEYoj5yASmDjzAlJJojBfNl2Ou2qRmZ0GPXY0tiNZWLY6aNQbQh9fEfGf97pqtgviyFbco0NwzMPbsb0NFrrxiOFIy6XbfddxQgsWt2jjhtJLPtetpoOyyan5gsWt2jjh6l8kal6pj5SoWPIkeSVcbh6tRmZ0aPa6ZVOOle0VKmTLPLKRSaNTAjBtKhgALzMgmnwMECqXWaAYnKGNStsoMgltpHCoJkaS4eR1bovdup6l8kal63sYvwGZwTKTjYduHGvPi4qFALzMgifqF(ffDHG(JdkggqtUHe8KDsYX0yz6jKZzubGfNyToWPAG6rFHxbyr)MtQwuHk0h0KBibpHGdbRIi4qFALzMgifqF(ffDHG(LKPTmTKCLf4SvlzBI8WqRmZ0GPXY0jIPNqoNPLKRSaNTAjBtKhgOE0x4vaw0VLKRSaNTAjBtKhOcbBci4qFALzMgifqF(ffDHG(JdkggqtUHe8KDsYH(cVcWI(KApOHo7eSduHG9fi4qFALzMgifqF(ffDHG(JdkggqtUHe8KDsYH(cVcWI(CWIhGdzRwY67JlkpQqW(keCOpTYmtdKcOp)IIUqq)JCh5BLzMqFHxbyrFzi9vGNS(g5urFUY8mzl5WqLhbRIOcbRsrWH(0kZmnqkG(8lk6cb9pYDKVvMzIP72LPNqoNbJKfEfClgi5gHSgOE0x4vaw0xfawxCe6ZvMNjBjhgQ8iyveviyFheCOpTYmtdKcOp)IIUqq)JCh5BLzMqFHxbyrFp06IJqFUY8mzl5WqLhbRIOcbBIfbh6tRmZ0aPa6ZVOOle0pntpHCodXZrVNSzOvodupt3TltpHCodXZrVNSEqwodupt3b9fEfGf99LCEOddHkeSVpco0NwzMPbsb0NFrrxiOFAMM45O3tMyTzOvoMUBxMM45O3tgpilNDP3Ry6omD3UmDAMM45O3tMyTzOvoMgltpHCodXZrVNSzOvodP2dAOJgmDh0x4vaw03xY5IJqfcwLaco0x4vaw0V5KQf9PvMzAGuavOcvOpE68byrWMqYjKSIjRycOFJCBSy8OVsQkzExHvjb2xdLiMMPHRLy6qThCft7ahtRKMda5bOz9kPz6JsCO4Obt7bQetlqfqvkAW08wzXqEdlvIHyjMwXxOeX0VwWINUIgm9puFTmTx5TK3JPvYX0fGPtmajm9iWh(aSmnONoPahtNgMomDAfFVogwkwkLe1EWv0GPvcmTWRaSmDo8L3WsH((EIJGvXKFf63FaxKj0)Lm9RbKCJqwM(10bfdwQxY0jg5fyshtNGsaxMoHKtizwkwQxY0V2wzXqELiwQxY0kXmTsYYbxp4KIy6xRuWKycaloXY09xaUOcYZ0Pdht7PQIfdthEMM3sCCOrhdl1lzALyMwjVNy63vAPgjByPyPEjtRK99iourdMEsoWrmnhOoLIPNeMy9gMwjdNt9LNPxWQe3kNQdkZ0cVcW6zAWMv2Wsj8kaR30FehOoLc(hyWj2XrdRVpUO8SuVKPfEfG1B6pIduNsb)dmCPSoWPIB4EghummCPAibpzNKCyljtBzC0jzR4CXgLYgALzMgSucVcW6n9hXbQtPG)bM(d0KXnCpJdkggUunKGNStsoSLKPTmo6KSvCUyJszdTYmtdStiNZWLY6aNQbQNLs4vawVP)ioqDkf8pWmj5SoWPIB4Es04GIHHlvdj4j7KKdBIghummGMCdj4j7KKJLs4vawVP)ioqDkf8pW0sYvwGZwTKTjYdCd3tjzAltljxzboB1s2Mipm0kZmnWooOyyan5gsWt2jjh2jKZzubGfNyToWPAG6zPeEfG1B6pIduNsb)dmnNuT4gUNXbfddOj3qcEYoj5WoHCoJkaS4eR1bovduplfl1lzALSVhXHkAW0eE6uMPRqLy6QLyAHxGJPdptl4LilZmzyPeEfG1)4XbkNTtX3Ysj8kaRh(hyG8Knks1Zsj8kaRh(hy6bvawCd3t60LKPTmTKCLf4SvlzBI8WqRmZ0a7eY5mTKCLf4SvlzBI8Wa13bB6XbfddxQgsWt2jjx3UJdkggqtUHe8KDsY1PdlLWRaSE4FG5GwRWRaS2C4lCxrLE4s1qcEc3W9moOyy4s1qcEYoj5WMonhaYdqZAQ2t8T2jjN5ivjw)BjJLda5bOznQYIjtMJuLy9VLm2bOmQaW6IJmhPkX6F7bdFaFYgLI9emusVkzStiNZelxUvQaSwmqYnczTaNf68aUzaAwStiNZmPZtho2jjNzaAwStiNZGrYcVcUfdKCJqwZa0SD62n9eY5mCPSoWPAG6XslDyu(TeuANUDtFql5ahgYaKQ1cC2QLSuEqNDCqXWqjou03tdSjAc5CgGuTwGZwTKLYd6SJdkggOESPNqoNHlL1bovdupwAPdJYVLqYD60TB6dAjh4WqgGuTwGZwTKLYd6SJdkggkXHI(EAGDc5CMwsUYcC2QLSnrEyosvI1NKIj3bB6jKZz4szDGt1a1JLw6WO8BjKCNUDtZb4Pv2YGJYxilwoaKhGM1qQ9Gg6StWomhPkX6t6rrScVc8KLwsniFsj0PdlLWRaSE4FG5GwRWRaS2C4lCxrLEan5gsWt4gUNXbfddOj3qcEYoj5WMonhaYdqZAQ2t8T2jjN5ivjw)BjJLda5bOznQYIjtMJuLy9VLm2tWqjLqYyNqoNjwUCRubyndqZIDc5CMjDE6WXoj5mdqZ2PB30tiNZOcaloXADGt1a1JDakJhADXrMJCh5BLzM60TB6jKZzubGfNyToWPAG6XoHCotljxzboB1s2Mipmq9D62n9eY5mQaWItSwh4unq9ytpHCodXZrVNSzOvoduF3UtiNZq8C07jRhKLZa13bBIoOLCGddzas1AboB1swkpOZooOyyOehk67PrNUDtFql5ahgYaKQ1cC2QLSuEqNDCqXWqjou03tdSjAc5CgGuTwGZwTKLYd6SJdkggO(oD7MMdWtRSLzdmTL1jewoaKhGM1WblEaoKTAjRVpUO8MJuLy9j9OyNUDtZb4Pv2YGJYxilwoaKhGM1qQ9Gg6StWomhPkX6t6rrScVc8KLwsniFsj0PdlLWRaSE4FG5GwRWRaS2C4lCxrLEYkZLta4gUN0PpOLCGddzYkZLt8wxMOkwmwm5qT3tgkXHI(EA0bB6sY0wMPKLLtwX5InkLn0kZmn6Gn9eY5mzL5YjERltuflglMCO27jduFhSPNqoNjRmxoXBDzIQyXyXKd1EpzosvI1N0tcD6Wsj8kaRh(hyoO1k8kaRnh(c3vuPNSYC5eoUH7jD6dAjh4WqMSYC5eV1LjQIfJftou79KHsCOOVNgDWMUKmTLXrNKTIZfBukBOvMzA0bB6jKZzYkZLt8wxMOkwmwm5qT3tgO(oytpHCotwzUCI36YevXIXIjhQ9EYCKQeRpPNe60HLs4vawp8pWWLC2k8kaRnh(c3vuPh1OcmsfGLLs4vawp8pWCqRv4vawBo8fUROsptsowkwkHxby9Mjj3ZKKZ6aNkUH7jrtiNZmj5SoWPAG6zPeEfG1BMKCW)atpOcWIB4EsNEc5CMjDE6WXoj5mq9D7oHCotSC5wPcWAXaj3iK1cCwOZd4gO(oytNOXbfddxQgsWt2jjh2enoOyyan5gsWt2jjxNoSucVcW6ntso4FG5e80cG8w3r7RRmlLWRaSEZKKd(hy4GfpahYwTK13hxuECd3tIghummCPAibpzNKCyt04GIHb0KBibpzNKCSucVcW6ntso4FGzsNNoCStsoCd3t6jKZzobpTaiV1D0(6kBG672nrCaEALTm4PTAv(6Wsj8kaR3mj5G)bMy5YTsfGf3W9KEc5CMtWtlaYBDhTVUYgO(UDtehGNwzldEARwLVoSucVcW6ntso4FGHu7bn0zNGDGB4EsNOXbfddxQgsWt2jjh2enoOyyan5gsWt2jjxNUDfEf4jlTKAq(3EsGLs4vawVzsYb)dmt5WXJtS4gUN0LKPTmZtuNzYBOvMzA0bB6jKZzMKCwh4unq9DyPeEfG1BMKCW)atCG1bD4gUNjKZzIdSoOZCKQeRpPKnkLLs4vawVzsYb)dmYq6Rapz9nYPIlxzEMSLCyOY)OiUH75i3r(wzMjwkHxby9Mjjh8pWOcaRloc3W9KEc5Cgmsw4vWTyGKBeYAG6XooOyyan5gsWt2jjxhScVc8KLwsniFspVGLs4vawVzsYb)dmv7j(w7KKdxUY8mzl5WqL)rrCd3ZrUJ8TYmtD7oaLPApX3ANKCgFjCCs6fD7MEakt1EIV1oj5m(s44K0RWEql5ahgYKHCojwhKNgwsDEcNmuIdf990Ot3UcVc8KLwsni)BkLLs4vawVzsYb)dm(MONWnCptiNZelxUvQaSwmqYnczTaNf68aUzaAwStiNZmPZtho2jjNzaAwScVc8KLwsni)BpVILs4vawVzsYb)dmQcug3W9mHCotSC5wPcWAG6Xk8kWtwAj1G8jLalLWRaSEZKKd(hyufOmUH7j9eY5mEbVGHSCG6ukzlJVeooV9OyhSPNqoNPaGQ1k7WYZsJbQVd2jKZzILl3kvawdupwHxbEYslPgK)jbwkHxby9Mjjh8pWOklMmHB4EMqoNjwUCRubynq9yfEf4jlTKAq(KEEblLWRaSEZKKd(hyubG1fhHlxzEMSLCyOY)OiUH75i3r(wzMjScVc8KLwsniFspVGLs4vawVzsYb)dmQcug3W9KEc5CMcaQwRSdlplngFjCCE7jHoD7MEc5CMcaQwRSdlplngOEStiNZuaq1ALDy5zPXCKQeRpjfnkTt3UPNqoNXl4fmKLduNsjBz8LWX5TNx0HLs4vawVzsYb)dmv7j(w7KKd3W9i8kWtwAj1G8VPilLWRaSEZKKd(hyubG1fhHB4EspHCodgjl8k4wmqYncznq9yhhummCPAibpzNKCDWk8kWtwAj1G8j98IUDtpHCodgjl8k4wmqYncznq9yt04GIHHlvdj4j7KKdBIghummGMCdj4j7KKRdwHxbEYslPgKpPNxWsj8kaR3mj5G)bgvzXKjCd3t6tWqj9(j3bRWRapzPLudYN0RyPeEfG1BMKCW)atpugpDXRt4YvMNjBjhgQ8pkIB4EgGYuTN4BTtsoJVeooVLalLWRaSEZKKd(hyQ2t8T2jjhlLWRaSEZKKd(hyufOmlLWRaSEZKKd(hy8nrpzNKCSuSuVKPfEfG1d)dmCjNTcVcWAZHVWDfv6rnQaJubyzPEjtl8kaRh(hyAI8WYBLddXs9sMw4vawp8pWWLC2k8kaRnh(c3vuPhoaKhGM1Zs9sMw4vawp8pWOkqzCd3ZjyiZGCbpQKsizScVc8KLwsniFsVIL6LmTWRaSE4FGrvGY4gUNtWqMb5cEujLqYyjVNwoz4G1LdEzLDy91foYOkVlGdBIMqoNX3kxpT0WYZsJ3a1Zs9sMw4vawp8pWehyDqhUH7Hd81tYD7M(em0BCGVWkVoDrrMSOmD0WQklzOvMzAGv4vGNS0sQb5FlHoSuVKPfEfG1d)dm9qz80fVoHBjhgQSH7zakt1EIV1oj5m(s448maLPApX3ANKCgv59S(s444zPEjtl8kaRh(hyubG1fhHBjhgQSH7zakJkaSU4iZrUJ8TYmtyfEf4jlTKAq(KsGL6LmTWRaSE4FGPApX3IB4EspHCotSC5wPcWAgGMfRWRapzPLudY)MID62n9eY5mXYLBLkaRbQhRWRapzPLudY)2R6Ws9sMw4vawp8pW4BIEc3W9mHCotSC5wPcWAgGMfRWRapzPLudY)2RyPEjtl8kaRh(hyuLftMWnCpdqzQ2t8T2jjNPcooXIHL6LmTWRaSE4FGrfawxCeULCyOYgUNjKZzWizHxb3IbsUriRbQhRWRapzPLudYNucSuVKPfEfG1d)dmv7j(wwQxY0kPe5mt3evltNycaRloIPBIQLPFndQeZ3lbwQxY0cVcW6H)bgvayDXr4gUh51PlkY0dAOZcC2QLSQaWAozX5nfXk8kWtwAj1G8pkYs9sMw4vawp8pW4BIEILILs4vawVrnQaJubyFIdSoOd3W9elhOglg7qufmKvP(3IdSoOZoevbdzR2J8TG8a7eY5mXbwh0zosvI1N0lE3TIViwkHxby9g1OcmsfGf(hyoAPgjJB4EkzXjwmyBjjxTMEEL07OuwkHxby9g1OcmsfGf(hyChTVEqd7ryOLoPcWIB4EkzXjwmyBjjxTMEEL07OuwkHxby9g1OcmsfGf(hyKnuflWzhKuT4gUNcGbtMmdYrRpWtESTKKRwtpVs69tMLs4vawVrnQaJubyH)bMPC44XjwCd3t6sY0wM5jQZm5n0kZmn6Gn9eY5mtsoRdCQgO(oyBjjxTMEELuIvPyJLduJfJDiQcgYQu)BjBsqPV7wsYvRrvEpwkHxby9g1OcmsfGf(hy8qh(aVKTX6Ry5Lh3W9mHCoJh6Wh4LSnwFflV8MbOzXoHCoZuoC84eRzaAwSTKKRwtpVs6DsgBSCGASySdrvWqwL6Flztck9D3ssUAnQY7XsXsj8kaR3WbG8a0S(NEqfGLLs4vawVHda5bOz9W)atljxzjVNwoXsj8kaR3WbG8a0SE4FGzMbGH1bDkZsj8kaR3WbG8a0SE4FGzsNNoCIfdlLWRaSEdhaYdqZ6H)bg54Ys2cChTflLWRaSEdhaYdqZ6H)bMCGPT823fObgvAlwkHxby9goaKhGM1d)dmU4OzgagSucVcW6nCaipanRh(hyKLt(6KSLl5mlLWRaSEdhaYdqZ6H)bM5f(khlgRd6WnCptiNZmj5SoWPAG6zPeEfG1B4aqEaAwp8pWelxUvQaS4gUN0dqzubG1fhzQGJtSy62v4vGNS0sQb5FtXoyhGYuTN4BTtsotfCCIfdlLWRaSEdhaYdqZ6H)bMjDE6WHLs4vawVHda5bOz9W)adKNSrrQ4sohXl7kQ0dxzEguhydUDMfFXsj8kaR3WbG8a0SE4FGr2qvSaNDqs1IB4EkagmzYWbG8a0SESPRqLSfWockjoaKhGMvjxcD7k8kWtwAj1G8VPyhwkHxby9goaKhGM1d)dmQKk4u2cC2mepg2XrIQNLs4vawVHda5bOz9W)adKNSrrQEwkwkHxby9gUunKGNE6pqtMLs4vawVHlvdj4j4FG5eCiCd3ZeY5m9hOjBG6zPeEfG1B4s1qcEc(hyAj5klWzRwY2e5bUH7PKmTLPLKRSaNTAjBtKhgALzMgyt0eY5mTKCLf4SvlzBI8Wa1Zsj8kaR3WLQHe8e8pWqQ9Gg6StWoWnCpJdkggUunKGNStsowkHxby9gUunKGNG)bgoyXdWHSvlz99XfLh3W9moOyy4s1qcEYoj5yPeEfG1B4s1qcEc(hyUOh3W9maL5IEZrUJ8TYmty5a1jW2dIT8V98kwkHxby9gUunKGNG)bghDaEaG82zueUH7HduNaBpi2Y)2ZRyPeEfG1B4s1qcEc(hyKH0xbEY6BKtfxUY8mzl5WqL)rrCd3ZrUJ8TYmtSucVcW6nCPAibpb)dmNGdHB4EgGYCcoK5i3r(wzMjSCG6ey7bXw(KEflLWRaSEdxQgsWtW)at1EIV1YLc3W9i8kWtwAj1G8VPiwHxbEYoaLPApX3A5s9KmlLWRaSEdxQgsWtW)aJV9ObUH7HduNaBpi2YNKszPyPeEfG1BYkZLt4pCPSoWPYsXsj8kaR3KvMlNaEubGfNyToWPYsXsj8kaR3aAYnKGNEAj5klWzRwY2e5bUH7PKmTLPLKRSaNTAjBtKhgALzMgyt0eY5mTKCLf4SvlzBI8Wa1Zsj8kaR3aAYnKGNG)bgsTh0qNDc2bUH7zCqXWaAYnKGNStsowkHxby9gqtUHe8e8pWWblEaoKTAjRVpUO84gUNXbfddOj3qcEYoj5yPeEfG1Ban5gsWtW)aJmK(kWtwFJCQ4YvMNjBjhgQ8pkIB4EoYDKVvMzILs4vawVb0KBibpb)dmQaW6IJWLRmpt2somu5Fue3W9CK7iFRmZu3UtiNZGrYcVcUfdKCJqwduplLWRaSEdOj3qcEc(hy8qRlocxUY8mzl5WqL)rrCd3ZrUJ8TYmtSucVcW6nGMCdj4j4FGXxY5HomeUH7j9eY5meph9EYMHw5mq9D7oHCodXZrVNSEqwoduFhwkHxby9gqtUHe8e8pW4l5CXr4gUN0eph9EYeRndTY1TlXZrVNmEqwo7sVx1PB30eph9EYeRndTYHDc5CgINJEpzZqRCgsTh0qhn6Wsj8kaR3aAYnKGNG)bMMtQwuHkec]] )

end