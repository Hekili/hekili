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

        eclipse.reset() -- from Balance.
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
                return talent.feral_affinity.enabled and settings.catweave_bear
            elseif k == "owlweave_bear" then
                return talent.balance_affinity.enabled and settings.owlweave_bear
            elseif k == "primal_wrath" then return debuff.rip
            elseif k == "lunar_inspiration" then return debuff.moonfire_cat
            elseif debuff[ k ] ~= nil then return debuff[ k ]
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
        desc = function()
            local affinity
            
            if state.talent.feral_affinity.enabled then
                affinity = "|cFF00FF00" .. ( GetSpellInfo( 202155 ) ) .. "|r"
            else
                affinity = "|cFFFF0000" .. ( GetSpellInfo( 202155 ) ) .. "|r"
            end

            return "If checked, the addon will use the experimental |cFFFFD100catweave|r priority included in the default priority pack.\n\nRequires " .. affinity .. "."
        end,
        type = "toggle",
        width = "full",
    } )

    spec:RegisterSetting( "owlweave_bear", false, {
        name = "|T136036:0|t Attempt Owlweaving (Experimental)",
        desc = function()
            local affinity
            
            if state.talent.balance_affinity.enabled then
                affinity = "|cFF00FF00" .. ( GetSpellInfo( 197488 ) ) .. "|r"
            else
                affinity = "|cFFFF0000" .. ( GetSpellInfo( 197488 ) ) .. "|r"
            end

            return "If checked, the addon will use the experimental |cFFFFD100owlweave|r priority included in the default priority pack.\n\nRequires " .. affinity .. "."
        end,
        type = "toggle",
        width = "full"
    } )    

    spec:RegisterPack( "Guardian", 20201113, [[dOKihbqisepcuIljfqztqLpjfi1OKIoLuLvbkf9kqvZck6wGsH2fP(LQudtvIJrcwMi4zsbnnPqDnsK2gOK6BsHW4aLQoNuawhOuP5jcDpvX(uL0bLcOAHKqpukenrPajxukq0gLci8rPavNeuQyLIOzkfiCtPaLDckgQuarlvkGupvvnvqLVkfqYEH8xkgmLomXIv0Jr1Kv4YiBMkFgknAP0PfwnOuWRHcZwu3MK2Ts)gy4sLJlfslxLNtvtxY1bz7qvFxKgpOu68KOwpOKmFPQ2pkJuabh6pKIqWKWlj8IckOqd1jKGcnGgQu0VuUJq)oHJHGLq)vuj0VbhsUril63jkNbYabh67bqhNq)2Q68WUVFJnQwOPMduF7dvOSuby5N4Q3(qL)g9NqrUGDw0e9hsriys4LeErbfuOH6esqHgRa6lqvl4q)FO2ir)2ymOfnr)b55OpSWSn4qYnczz2guhumyjHfMfgaEsDshZQqdXKzt4LeEHLKLewy2gzRSyjpSlljSWSWgzwyNLdUoWjfXSnsPE3GbalgXYSDxaUOcYZSndhZ6PQIflZgEML3sCmOrpn6NdF5rWH(zL5YjaeCiyuabh6l8kal6RcalgXACGtf9PvMzAGuevOc9NKCi4qWOaco0NwzMPbsr0NFrrxiOVsy2jKZPNKCgh4u1qDOVWRaSO)KKZ4aNkQqWKaco0NwzMPbsr0NFrrxiOFtMTjZoHCo9KopDyyMKCAOoMTFFMDc5C6y5YTsfG1GfsUriRb4mqNhW1qDmBpMfhZ2KzvcZooOyO5sLscEYmj5ywCmRsy2XbfdninNscEYmj5y2EmBp0x4vaw0VdubyrfcMgIGd9fEfGf9pbpTaiVXD0cRug9PvMzAGueviyAmco0NwzMPbsr0NFrrxiOVsy2XbfdnxQusWtMjjhZIJzvcZooOyObP5usWtMjjh6l8kal6ZblEagKPAjJVlUO8OcbJsrWH(0kZmnqkI(8lk6cb9BYStiNtFcEAbqEJ7OfwPSgQJz73NzvcZYb4Pv2sJN2Qv5Jz7H(cVcWI(t680HbQqWaRrWH(0kZmnqkI(8lk6cb9BYStiNtFcEAbqEJ7OfwPSgQJz73NzvcZYb4Pv2sJN2Qv5Jz7H(cVcWI(XYLBLkalQqW0iqWH(0kZmnqkI(8lk6cb9BYSkHzhhum0CPsjbpzMKCmloMvjm74GIHgKMtjbpzMKCmBpMTFFMv4vGNm0sQb5z2xFy2eqFHxbyrFsTdKsNzc2bQqWa7rWH(0kZmnqkI(8lk6cb9BYSLKPT0ZtuNzYRPvMzAWS9ywCmBtMDc5C6jjNXbovnuhZ2d9fEfGf9NYHHhJyrfcMgaco0NwzMPbsr0NFrrxiO)eY50Xbwh0PpsvI1ZSjYSVOvk6l8kal6hhyDqhQqWOWli4qFALzMgifrF(ffDHG(h5oY3kZmH(cVcWI(Yq6Qapz8PYPI(CL5zYuYHLkpcgfqfcgfuabh6tRmZ0aPi6ZVOOle0VjZoHConwjl8k4gSqYncz1qDmloMDCqXqdsZPKGNmtsoMThZIJzfEf4jdTKAqEMnXhMTHOVWRaSOVkaSU4iuHGrHeqWH(0kZmnqkI(8lk6cb9pYDKVvMzIz73NzhGsxTN4BntsoTVeogmBImBdz2(9z2Mm7au6Q9eFRzsYP9LWXGztKzBmZIJzpOLCGdlPZqoNeRdYtddPopHtAQrHIUoAWS9y2(9zwHxbEYqlPgKNzFLzvk6l8kal6xTN4Bntso0NRmptMsoSu5rWOaQqWOqdrWH(0kZmnqkI(8lk6cb9NqoNowUCRubynyHKBeYAaod05bC9aKUmloMDc5C6jDE6WWmj50dq6YS4ywHxbEYqlPgKNzF9HzBm6l8kal67tJoYmj5qfcgfAmco0NwzMPbsr0NFrrxiO)eY50XYLBLkaRgQJzXXScVc8KHwsnipZMiZMa6l8kal6RkqzuHGrbLIGd9PvMzAGue95xu0fc63KzNqoN2l4fSKHduNsjBP9LWXGzF9HzvGz7XS4y2Mm7eY50fauTgzhgEws1qDmBpMfhZoHCoDSC5wPcWQH6ywCmRWRapzOLudYZSpmBcOVWRaSOVQaLrfcgfG1i4qFALzMgifrF(ffDHG(tiNthlxUvQaSAOoMfhZk8kWtgAj1G8mBIpmBdrFHxbyrFvzXMjuHGrHgbco0NwzMPbsr0NFrrxiO)rUJ8TYmtmloMv4vGNm0sQb5z2eFy2gI(cVcWI(QaW6IJqFUY8mzk5WsLhbJcOcbJcWEeCOpTYmtdKIOp)IIUqq)Mm7eY50fauTgzhgEws1(s4yWSV(WSjWS9y2(9z2Mm7eY50fauTgzhgEws1qDmloMDc5C6caQwJSddplP6JuLy9mBImRcALYS9y2(9z2Mm7eY50EbVGLmCG6ukzlTVeogm7RpmBdz2EOVWRaSOVQaLrfcgfAai4qFALzMgifrF(ffDHG(cVc8KHwsnipZ(kZQa6l8kal6xTN4BntsouHGjHxqWH(0kZmnqkI(8lk6cb9BYStiNtJvYcVcUblKCJqwnuhZIJzhhum0CPsjbpzMKCmBpMfhZk8kWtgAj1G8mBIpmBdz2(9z2Mm7eY50yLSWRGBWcj3iKvd1XS4ywLWSJdkgAUuPKGNmtsoMfhZQeMDCqXqdsZPKGNmtsoMThZIJzfEf4jdTKAqEMnXhMTHOVWRaSOVkaSU4iuHGjbfqWH(0kZmnqkI(8lk6cb9BYSNGLy2ezwy)lmBpMfhZk8kWtgAj1G8mBImBJrFHxbyrFvzXMjuHGjHeqWH(0kZmnqkI(8lk6cb9hGsxTN4BntsoTVeogm7RmBcOVWRaSOFhugpDbSIqFUY8mzk5WsLhbJcOcbtcnebh6l8kal6xTN4Bntso0NwzMPbsruHGjHgJGd9fEfGf9vfOm6tRmZ0aPiQqWKGsrWH(cVcWI((0OJmtso0NwzMPbsruHk0xnQaRubyrWHGrbeCOpTYmtdKIOp)IIUqq)y5a1yXAgIQGLmk1ZSVYSXbwh0zgIQGLmv7r(wqEWS4y2jKZPJdSoOtFKQeRNztKzBiZcBYSTIVi0x4vaw0poW6GouHGjbeCOpTYmtdKIOp)IIUqq)swmIflZIJzBjjxT6oEXSjYSWALI(cVcWI(hTuQKrfcMgIGd9PvMzAGue95xu0fc6xYIrSyzwCmBlj5Qv3XlMnrMfwRu0x4vaw03D0cRcAyoclT0jvawuHGPXi4qFALzMgifrF(ffDHG(fal2mPhKJwFGN8mloMTLKC1Q74fZMiZc7Fb9fEfGf9LnufdWzgKuTOcbJsrWH(0kZmnqkI(8lk6cb9BYSLKPT0ZtuNzYRPvMzAWS9ywCmBtMDc5C6jjNXbovnuhZ2JzXXSTKKRwDhVy2ez2gHszwCmBSCGASyndrvWsgL6z2xz2x0jOuMf2KzBjjxTAvb2I(cVcWI(t5WWJrSOcbdSgbh6tRmZ0aPi6ZVOOle0Fc5CAp0HpWlztS(kwE51dq6YS4y2jKZPNYHHhJy1dq6YS4y2wsYvRUJxmBImlS(fMfhZglhOglwZqufSKrPEM9vM9fDckLzHnz2wsYvRwvGTOVWRaSOVh6Wh4LSjwFflV8OcvOFwzUCchbhcgfqWH(cVcWI(CPmoWPI(0kZmnqkIkuH(dYjq5cbhcgfqWH(cVcWI(EmGYzZu8TOpTYmtdKIOcbtci4qFHxbyrFipzIIu9OpTYmtdKIOcbtdrWH(0kZmnqkI(8lk6cb9BYSnz2sY0w6wsUYaCMQLmPrEOPvMzAWS4y2jKZPBj5kdWzQwYKg5HgQJz7XS4y2Mm74GIHMlvkj4jZKKJz73Nzhhum0G0Ckj4jZKKJz7XS9qFHxbyr)oqfGfviyAmco0NwzMPbsr0x4vaw0)GwJWRaSMC4l0NFrrxiO)4GIHMlvkj4jZKKJzXXSnz2MmlhaYdq6QR2t8TMjjN(ivjwpZ(kZ(cZIJz5aqEasxTQSyZK(ivjwpZ(kZ(cZIJzhGsRcaRlosFKQeRNzF9HzXYhml8m7lALYS4y2tWsmBImBJFHzXXStiNthlxUvQaSgSqYncznaNb68aUEasxMfhZoHCo9KopDyyMKC6biDzwCm7eY50yLSWRGBWcj3iKvpaPlZ2Jz73NzBYStiNtZLY4aNQgQJzXXS0shwLz2xz2eukZ2Jz73NzBYSh0soWHL0aPAnaNPAjdLh0zghum0uJcfDD0GzXXSkHzNqoNgivRb4mvlzO8GoZ4GIHgQJzXXSnz2jKZP5szCGtvd1XS4ywAPdRYm7RmBcVWS9y2EmB)(mBtM9GwYboSKgivRb4mvlzO8GoZ4GIHMAuOORJgmloMDc5C6wsUYaCMQLmPrEOpsvI1ZSjYSk8cZ2JzXXSnz2jKZP5szCGtvd1XS4ywAPdRYm7RmBcVWS9y2(9z2MmlhGNwzlngkFHSmloMLda5biD1KAhiLoZeSd9rQsSEMnXhMvbMfhZk8kWtgAj1G8mBImBcmBpMTh6NdFzwrLqFUuPKGNqfcgLIGd9PvMzAGue9fEfGf9pO1i8kaRjh(c95xu0fc6poOyObP5usWtMjjhZIJzBYSnzwoaKhG0vxTN4Bntso9rQsSEM9vM9fMfhZYbG8aKUAvzXMj9rQsSEM9vM9fMfhZEcwIztKzt4fMfhZoHCoDSC5wPcWQhG0LzXXStiNtpPZthgMjjNEasxMThZ2VpZ2KzNqoNwfawmI14aNQgQJzXXSdqP9qRlosFK7iFRmZeZ2Jz73NzBYStiNtRcalgXACGtvd1XS4y2jKZPBj5kdWzQwYKg5HgQJz7XS97ZSnz2jKZPvbGfJynoWPQH6ywCmBtMDc5CAINJopzYqRCAOoMTFFMDc5CAINJopz8GSCAOoMThZIJzvcZEql5ahwsdKQ1aCMQLmuEqNzCqXqtnku01rdMThZ2VpZ2KzpOLCGdlPbs1Aaot1sgkpOZmoOyOPgfk66ObZIJzvcZoHConqQwdWzQwYq5bDMXbfdnuhZ2Jz73NzBYSCaEALT0BGTTmoHywCmlhaYdq6Q5GfpadYuTKX3fxuE9rQsSEMnXhMvbMThZ2VpZ2Kz5a80kBPXq5lKLzXXSCaipaPRMu7aP0zMGDOpsvI1ZSj(WSkWS4ywHxbEYqlPgKNztKztGz7XS9q)C4lZkQe6dsZPKGNqfcgynco0NwzMPbsr0x4vaw0)GwJWRaSMC4l0NFrrxiOFtMTjZEql5ahwsNvMlN4nUmrvSynyZHANN0uJcfDD0Gz7XS4y2MmBjzAl9uYYYjJ4CXgLYAALzMgmBpMfhZ2KzNqoNoRmxoXBCzIQyXAWMd1opPH6y2EmloMTjZoHCoDwzUCI34YevXI1GnhQDEsFKQeRNzt8HztGz7XS9q)C4lZkQe6NvMlNaqfcMgbco0NwzMPbsr0x4vaw0)GwJWRaSMC4l0NFrrxiOFtMTjZEql5ahwsNvMlN4nUmrvSynyZHANN0uJcfDD0Gz7XS4y2MmBjzAlTJojBeNl2OuwtRmZ0Gz7XS4y2Mm7eY50zL5YjEJltuflwd2CO25jnuhZ2JzXXSnz2jKZPZkZLt8gxMOkwSgS5qTZt6JuLy9mBIpmBcmBpMTh6NdFzwrLq)SYC5eoQqWa7rWH(0kZmnqkI(cVcWI(CjNncVcWAYHVq)C4lZkQe6RgvGvQaSOcbtdabh6tRmZ0aPi6l8kal6FqRr4vawto8f6NdFzwrLq)jjhQqf6ZLkLe8ecoemkGGd9fEfGf97oqAg9PvMzAGueviysabh6tRmZ0aPi6ZVOOle0xjm7eY50CPmoWPQH6qFHxbyrFUugh4urfcMgIGd9PvMzAGue95xu0fc6pHCoD3bsZAOo0x4vaw0)emiuHGPXi4qFALzMgifrF(ffDHG(LKPT0TKCLb4mvlzsJ8qtRmZ0GzXXSkHzNqoNULKRmaNPAjtAKhAOo0x4vaw0VLKRmaNPAjtAKhOcbJsrWH(0kZmnqkI(8lk6cb9hhum0CPsjbpzMKCOVWRaSOpP2bsPZmb7aviyG1i4qFALzMgifrF(ffDHG(JdkgAUuPKGNmtso0x4vaw0Ndw8amit1sgFxCr5rfcMgbco0NwzMPbsr0NFrrxiO)au6l60h5oY3kZmXS4ywoqDcmDGylpZ(6dZ2y0x4vaw0)IouHGb2JGd9PvMzAGue95xu0fc6ZbQtGPdeB5z2xFy2gJ(cVcWI(o6a8aa5nZOiuHGPbGGd9PvMzAGue95xu0fc6FK7iFRmZe6l8kal6ldPRc8KXNkNk6ZvMNjtjhwQ8iyuaviyu4feCOpTYmtdKIOp)IIUqq)bO0NGbPpYDKVvMzIzXXSCG6ey6aXwEMnrMTXOVWRaSO)jyqOcbJckGGd9PvMzAGue95xu0fc6l8kWtgAj1G8m7RmRcmloMv4vGNmdqPR2t8TgUum7dZ(c6l8kal6xTN4BnCPqfcgfsabh6tRmZ0aPi6ZVOOle0NduNathi2YZSjYSkf9fEfGf99ThnqfQqFoaKhG01JGdbJci4qFHxbyr)oqfGf9PvMzAGueviysabh6l8kal63sYvgY7PLtOpTYmtdKIOcbtdrWH(cVcWI(ZmammoOtz0NwzMPbsruHGPXi4qFHxbyr)jDE6WiwSOpTYmtdKIOcbJsrWH(cVcWI(YXLLmf4oAl0NwzMPbsruHGbwJGd9fEfGf9Zb22YBGnanWQsBH(0kZmnqkIkemnceCOVWRaSOVloAMbGb6tRmZ0aPiQqWa7rWH(cVcWI(YYjFDs2WLCg9PvMzAGueviyAai4qFALzMgifrF(ffDHG(tiNtpj5moWPQH6qFHxbyr)5f(khlwJd6qfcgfEbbh6tRmZ0aPi6ZVOOle0VjZoaLwfawxCKUcogXILz73NzfEf4jdTKAqEM9vMvbMThZIJzhGsxTN4BntsoDfCmIfl6l8kal6hlxUvQaSOcbJckGGd9fEfGf9N05Pdd0NwzMPbsruHGrHeqWH(0kZmnqkI(cVcWI(CL5zqDGn4Mzw8f6tohXlZkQe6ZvMNb1b2GBMzXxOcbJcnebh6tRmZ0aPi6ZVOOle0VayXMjnhaYdq66zwCmBtMTcvYuaZiiMnrMv4vawdhaYdq6YSVz2ey2(9zwHxbEYqlPgKNzFLzvGz7H(cVcWI(YgQIb4mdsQwuHGrHgJGd9fEfGf9vjvWPSb4mziEmmJJevp6tRmZ0aPiQqWOGsrWH(cVcWI(qEYefP6rFALzMgifrfQq)UJ4a1Pui4qWOaco0x4vaw0hJyhhnm(U4IYJ(0kZmnqkIkemjGGd9PvMzAGue95xu0fc6poOyO5sLscEYmj5ywCmBjzAlTJojBeNl2OuwtRmZ0GzXXStiNtZLY4aNQgQd9fEfGf97oqAgviyAico0NwzMPbsr0NFrrxiOVsy2XbfdnxQusWtMjjhZIJzvcZooOyObP5usWtMjjh6l8kal6pj5moWPIkemngbh6tRmZ0aPi6ZVOOle0VKmTLULKRmaNPAjtAKhAALzMgmloMDCqXqdsZPKGNmtsoMfhZoHCoTkaSyeRXbovnuh6l8kal63sYvgGZuTKjnYduHGrPi4qFALzMgifrF(ffDHG(JdkgAqAoLe8KzsYXS4y2jKZPvbGfJynoWPQH6qFHxbyr)0tQwuHk0hKMtjbpHGdbJci4qFALzMgifrF(ffDHG(kHzNqoNwfawmI14aNQgQd9fEfGf9vbGfJynoWPIkemjGGd9PvMzAGue95xu0fc6xsM2s3sYvgGZuTKjnYdnTYmtdMfhZQeMDc5C6wsUYaCMQLmPrEOH6qFHxbyr)wsUYaCMQLmPrEGkemnebh6tRmZ0aPi6ZVOOle0FCqXqdsZPKGNmtso0x4vaw0Nu7aP0zMGDGkemngbh6tRmZ0aPi6ZVOOle0FCqXqdsZPKGNmtso0x4vaw0Ndw8amit1sgFxCr5rfcgLIGd9PvMzAGue95xu0fc6FK7iFRmZe6l8kal6ldPRc8KXNkNk6ZvMNjtjhwQ8iyuaviyG1i4qFALzMgifrF(ffDHG(h5oY3kZmXS97ZStiNtJvYcVcUblKCJqwnuh6l8kal6RcaRloc95kZZKPKdlvEemkGkemnceCOpTYmtdKIOp)IIUqq)JCh5BLzMqFHxbyrFp06IJqFUY8mzk5WsLhbJcOcbdShbh6tRmZ0aPi6ZVOOle0VjZoHConXZrNNmzOvonuhZ2VpZoHConXZrNNmEqwonuhZ2d9fEfGf99LCEOdlHkemnaeCOpTYmtdKIOp)IIUqq)MmlXZrNN0XAYqRCmB)(mlXZrNN0EqwoZsW2Iz7XS97ZSnzwINJopPJ1KHw5ywCm7eY50(sop0HLmKAhiLovAltgALtd1XS9qFHxbyrFFjNlocviyu4feCOVWRaSOF6jvl6tRmZ0aPiQqfQqF805dWIGjHxs4ffEjHga6Nk3glwp63avd8gOHb2bMgCyxMLzHRLy2qTdCfZ6ahZ2GMda5biD9nOz2JAuO4ObZ6bQeZkqfqvkAWS8wzXsEnlzdIyjMvHgc7YSnsWINUIgm7puBKmRx5TeylZ2aJzlaZ2Gasy2rGp8byzwqhDsboMT57EmBtfGT90SKSKWoQDGRObZ2aywHxbyz2C4lVMLe97oGlYe6dlmBdoKCJqwMTb1bfdwsyHzHbGNuN0XSk0qmz2eEjHxyjzjHfMTr2klwYd7YsclmlSrMf2z5GRdCsrmBJuQ3nyaWIrSmB3fGlQG8mBZWXSEQQyXYSHNz5TehdA0tZsYsclmBdsylXHkAWStYboIz5a1Pum7KWgRxZSnW5CQR8m7cwyJTYP6GYmRWRaSEMfSzL1SKcVcW61DhXbQtPG)5ngXooAy8DXfLNLewywHxby96UJ4a1PuW)8MlLXbovmd3Z4GIHMlvkj4jZKKdxjzAlTJojBeNl2OuwtRmZ0GLu4vawVU7ioqDkf8pV7oqAgZW9moOyO5sLscEYmj5WvsM2s7OtYgX5InkL10kZmnWnHConxkJdCQAOowsHxby96UJ4a1PuW)8EsYzCGtfZW9OKXbfdnxQusWtMjjhoLmoOyObP5usWtMjjhlPWRaSED3rCG6uk4FE3sYvgGZuTKjnYdmd3tjzAlDljxzaot1sM0ip00kZmnWnoOyObP5usWtMjjhUjKZPvbGfJynoWPQH6yjfEfG1R7oIduNsb)Z70tQwmd3Z4GIHgKMtjbpzMKC4MqoNwfawmI14aNQgQJLKLewy2gKWwIdv0Gzj80PmZwHkXSvlXScVahZgEMvWlrwMzsZsk8kaR)XJbuoBMIVLLu4vawp8pVH8Kjks1Zsk8kaRh(N3DGkalMH7PzZsY0w6wsUYaCMQLmPrEOPvMzAGBc5C6wsUYaCMQLmPrEOH66HR54GIHMlvkj4jZKKRF)XbfdninNscEYmj561JLu4vawp8pVpO1i8kaRjh(cZvuPhUuPKGNWmCpJdkgAUuPKGNmtsoCnBYbG8aKU6Q9eFRzsYPpsvI1)6l44aqEasxTQSyZK(ivjw)RVGBakTkaSU4i9rQsS(xFWYhW)IwP4oblLyJFb3eY50XYLBLkaRblKCJqwdWzGopGRhG0f3eY50t680HHzsYPhG0f3eY50yLSWRGBWcj3iKvpaPBV(9BoHConxkJdCQAOoC0shwLFnbL2RF)Mh0soWHL0aPAnaNPAjdLh0zghum0uJcfDD0aNsMqoNgivRb4mvlzO8GoZ4GIHgQdxZjKZP5szCGtvd1HJw6WQ8Rj8sVE9738GwYboSKgivRb4mvlzO8GoZ4GIHMAuOORJg4MqoNULKRmaNPAjtAKh6JuLy9jQWl9W1Cc5CAUugh4u1qD4OLoSk)AcV0RF)MCaEALT0yO8fYIJda5biD1KAhiLoZeSd9rQsS(eFuaNWRapzOLudYNyc96Xsk8kaRh(N3h0AeEfG1KdFH5kQ0dinNscEcZW9moOyObP5usWtMjjhUMn5aqEasxD1EIV1mj50hPkX6F9fCCaipaPRwvwSzsFKQeR)1xWDcwkXeEb3eY50XYLBLkaREasxCtiNtpPZthgMjjNEas3E973Cc5CAvayXiwJdCQAOoCdqP9qRlosFK7iFRmZuV(9BoHCoTkaSyeRXbovnuhUjKZPBj5kdWzQwYKg5HgQRx)(nNqoNwfawmI14aNQgQdxZjKZPjEo68KjdTYPH663Fc5CAINJopz8GSCAOUE4uYbTKdCyjnqQwdWzQwYq5bDMXbfdn1Oqrxhn61VFZdAjh4WsAGuTgGZuTKHYd6mJdkgAQrHIUoAGtjtiNtdKQ1aCMQLmuEqNzCqXqd11RF)MCaEALT0BGTTmoHWXbG8aKUAoyXdWGmvlz8DXfLxFKQeRpXhf61VFtoapTYwAmu(czXXbG8aKUAsTdKsNzc2H(ivjwFIpkGt4vGNm0sQb5tmHE9yjfEfG1d)Z7dAncVcWAYHVWCfv6jRmxobGz4EA28GwYboSKoRmxoXBCzIQyXAWMd1opPPgfk66OrpCnljtBPNswwozeNl2OuwtRmZ0OhUMtiNtNvMlN4nUmrvSynyZHANN0qD9W1Cc5C6SYC5eVXLjQIfRbBou78K(ivjwFIpj0RhlPWRaSE4FEFqRr4vawto8fMROspzL5YjCmd3tZMh0soWHL0zL5YjEJltuflwd2CO25jn1Oqrxhn6HRzjzAlTJojBeNl2OuwtRmZ0OhUMtiNtNvMlN4nUmrvSynyZHANN0qD9W1Cc5C6SYC5eVXLjQIfRbBou78K(ivjwFIpj0RhlPWRaSE4FEZLC2i8kaRjh(cZvuPh1OcSsfGLLu4vawp8pVpO1i8kaRjh(cZvuPNjjhljlPWRaSE9KK7zsYzCGtfZW9OKjKZPNKCgh4u1qDSKcVcW61tso4FE3bQaSygUNMnNqoNEsNNommtsonux)(tiNthlxUvQaSgSqYncznaNb68aUgQRhUMkzCqXqZLkLe8KzsYHtjJdkgAqAoLe8KzsY1RhlPWRaSE9KKd(N3NGNwaK34oAHvkZsk8kaRxpj5G)5nhS4byqMQLm(U4IYJz4EuY4GIHMlvkj4jZKKdNsghum0G0Ckj4jZKKJLu4vawVEsYb)Z7jDE6WWmj5WmCpnNqoN(e80cG8g3rlSsznux)(kHdWtRSLgpTvRYxpwsHxby96jjh8pVJLl3kvawmd3tZjKZPpbpTaiVXD0cRuwd11VVs4a80kBPXtB1Q81JLu4vawVEsYb)ZBsTdKsNzc2bMH7PPsghum0CPsjbpzMKC4uY4GIHgKMtjbpzMKC963x4vGNm0sQb5F9jbwsHxby96jjh8pVNYHHhJyXmCpnljtBPNNOoZKxtRmZ0OhUMtiNtpj5moWPQH66Xsk8kaRxpj5G)5DCG1bDygUNjKZPJdSoOtFKQeRpXx0kLLu4vawVEsYb)ZBziDvGNm(u5uXKRmptMsoSu5FuaZW9CK7iFRmZelPWRaSE9KKd(N3QaW6IJWmCpnNqoNgRKfEfCdwi5gHSAOoCJdkgAqAoLe8KzsY1dNWRapzOLudYN4tdzjfEfG1RNKCW)8UApX3AMKCyYvMNjtjhwQ8pkGz4EoYDKVvMzQF)bO0v7j(wZKKt7lHJrInSF)MdqPR2t8TMjjN2xchJeBmUdAjh4Ws6mKZjX6G80WqQZt4KMAuOORJg963x4vGNm0sQb5FvPSKcVcW61tso4FE7tJocZW9mHCoDSC5wPcWAWcj3iK1aCgOZd46biDXnHCo9KopDyyMKC6biDXj8kWtgAj1G8V(0ywsHxby96jjh8pVvfOmMH7zc5C6y5YTsfGvd1Ht4vGNm0sQb5tmbwsHxby96jjh8pVvfOmMH7P5eY50EbVGLmCG6ukzlTVeogV(OqpCnNqoNUaGQ1i7WWZsQgQRhUjKZPJLl3kvawnuhoHxbEYqlPgK)jbwsHxby96jjh8pVvLfBMWmCptiNthlxUvQaSAOoCcVc8KHwsniFIpnKLu4vawVEsYb)ZBvayDXryYvMNjtjhwQ8pkGz4EoYDKVvMzcNWRapzOLudYN4tdzjfEfG1RNKCW)8wvGYygUNMtiNtxaq1AKDy4zjv7lHJXRpj0RF)MtiNtxaq1AKDy4zjvd1HBc5C6caQwJSddplP6JuLy9jQGwP963V5eY50EbVGLmCG6ukzlTVeogV(0WESKcVcW61tso4FExTN4Bntsomd3JWRapzOLudY)QcSKcVcW61tso4FERcaRlocZW90Cc5CASsw4vWnyHKBeYQH6WnoOyO5sLscEYmj56Ht4vGNm0sQb5t8PH973Cc5CASsw4vWnyHKBeYQH6WPKXbfdnxQusWtMjjhoLmoOyObP5usWtMjjxpCcVc8KHwsniFIpnKLu4vawVEsYb)ZBvzXMjmd3tZtWsjc7FPhoHxbEYqlPgKpXgZsk8kaRxpj5G)5DhugpDbSIWKRmptMsoSu5FuaZW9maLUApX3AMKCAFjCmEnbwsHxby96jjh8pVR2t8TMjjhlPWRaSE9KKd(N3QcuMLu4vawVEsYb)ZBFA0rMjjhljljSWScVcW6H)5nxYzJWRaSMC4lmxrLEuJkWkvawwsyHzfEfG1d)Z70ipm8w5WsSKWcZk8kaRh(N3CjNncVcWAYHVWCfv6Hda5biD9SKWcZk8kaRh(N3QcugZW9CcwspixWJkXeEbNWRapzOLudYNyJzjHfMv4vawp8pVvfOmMH75eSKEqUGhvIj8coY7PLtAoyD5GxgzhgFDHJ0QcSbWHtjtiNt7BLRJwAy4zj1RH6yjHfMv4vawp8pVJdSoOdZW9Wb(65L(9BEcw6voWx4eyfDrr6SOmD0WOklPPvMzAGt4vGNm0sQb5FnHESKWcZk8kaRh(N3Dqz80fWkcZsoSuzc3Zau6Q9eFRzsYP9LWX4zakD1EIV1mj50QcS14lHJHNLewywHxby9W)8wfawxCeMLCyPYeUNbO0QaW6IJ0h5oY3kZmHt4vGNm0sQb5tmbwsyHzfEfG1d)Z7Q9eFlMH7P5eY50XYLBLkaREasxCcVc8KHwsni)Rk0RF)MtiNthlxUvQaSAOoCcVc8KHwsni)RnUhljSWScVcW6H)5Tpn6imd3ZeY50XYLBLkaREasxCcVc8KHwsni)RnMLewywHxby9W)8wvwSzcZW9maLUApX3AMKC6k4yelwwsyHzfEfG1d)ZBvayDXrywYHLkt4EMqoNgRKfEfCdwi5gHSAOoCcVc8KHwsniFIjWsclmRWRaSE4FExTN4BzjHfMTbIiNz20OAz2gmayDXrmBAuTmBdKGQbd2MaljSWScVcW6H)5TkaSU4imd3JaROlks3bsPZaCMQLmQaWQpzX4vfWj8kWtgAj1G8pkWsclmRWRaSE4FE7tJoILKLu4vawVwnQaRubyFIdSoOdZW9elhOglwZqufSKrP(xJdSoOZmevblzQ2J8TG8a3eY50Xbwh0PpsvI1NydHnBfFrSKcVcW61QrfyLkal8pVpAPujJz4EkzXiwS4AjjxT6oELiSwPSKcVcW61QrfyLkal8pVDhTWQGgMJWslDsfGfZW9uYIrSyX1ssUA1D8kryTszjfEfG1RvJkWkvaw4FElBOkgGZmiPAXmCpfal2mPhKJwFGN84AjjxT6oELiS)fwsHxby9A1OcSsfGf(N3t5WWJrSygUNMLKPT0ZtuNzYRPvMzA0dxZjKZPNKCgh4u1qD9W1ssUA1D8kXgHsXflhOglwZqufSKrP(xFrNGsHnBjjxTAvb2Ysk8kaRxRgvGvQaSW)82dD4d8s2eRVILxEmd3ZeY50EOdFGxYMy9vS8YRhG0f3eY50t5WWJrS6biDX1ssUA1D8kry9l4ILduJfRziQcwYOu)RVOtqPWMTKKRwTQaBzjzjfEfG1R5aqEasx)thOcWYsk8kaRxZbG8aKUE4FE3sYvgY7PLtSKcVcW61CaipaPRh(N3ZmammoOtzwsHxby9AoaKhG01d)Z7jDE6WiwSSKcVcW61CaipaPRh(N3YXLLmf4oAlwsHxby9AoaKhG01d)Z7CGTT8gydqdSQ0wSKcVcW61CaipaPRh(N3U4OzgagSKcVcW61CaipaPRh(N3YYjFDs2WLCMLu4vawVMda5biD9W)8EEHVYXI14Gomd3ZeY50tsoJdCQAOowsHxby9AoaKhG01d)Z7y5YTsfGfZW90CakTkaSU4iDfCmIfB)(cVc8KHwsni)Rk0d3au6Q9eFRzsYPRGJrSyzjfEfG1R5aqEasxp8pVN05PddwsHxby9AoaKhG01d)ZBipzIIuXKCoIxMvuPhUY8mOoWgCZml(ILu4vawVMda5biD9W)8w2qvmaNzqs1Iz4EkawSzsZbG8aKUECnRqLmfWmckroaKhG0Tbwc97l8kWtgAj1G8VQqpwsHxby9AoaKhG01d)ZBvsfCkBaotgIhdZ4ir1Zsk8kaRxZbG8aKUE4FEd5jtuKQNLKLu4vawVMlvkj4PNUdKMzjfEfG1R5sLscEc(N3CPmoWPIz4EuYeY50CPmoWPQH6yjfEfG1R5sLscEc(N3NGbHz4EMqoNU7aPznuhlPWRaSEnxQusWtW)8ULKRmaNPAjtAKhygUNsY0w6wsUYaCMQLmPrEOPvMzAGtjtiNt3sYvgGZuTKjnYdnuhlPWRaSEnxQusWtW)8Mu7aP0zMGDGz4Eghum0CPsjbpzMKCSKcVcW61CPsjbpb)ZBoyXdWGmvlz8DXfLhZW9moOyO5sLscEYmj5yjfEfG1R5sLscEc(N3x0Hz4EgGsFrN(i3r(wzMjCCG6ey6aXw(xFAmlPWRaSEnxQusWtW)82rhGhaiVzgfHz4E4a1jW0bIT8V(0ywsHxby9AUuPKGNG)5TmKUkWtgFQCQyYvMNjtjhwQ8pkGz4EoYDKVvMzILu4vawVMlvkj4j4FEFcgeMH7zak9jyq6JCh5BLzMWXbQtGPdeB5tSXSKcVcW61CPsjbpb)Z7Q9eFRHlfMH7r4vGNm0sQb5FvbCcVc8KzakD1EIV1WL65fwsHxby9AUuPKGNG)5TV9ObMH7HduNathi2YNOszjzjfEfG1RZkZLt4pCPmoWPYsYsk8kaRxNvMlNaEubGfJynoWPYsYsk8kaRxdsZPKGNEubGfJynoWPIz4EuYeY50QaWIrSgh4u1qDSKcVcW61G0Ckj4j4FE3sYvgGZuTKjnYdmd3tjzAlDljxzaot1sM0ip00kZmnWPKjKZPBj5kdWzQwYKg5HgQJLu4vawVgKMtjbpb)ZBsTdKsNzc2bMH7zCqXqdsZPKGNmtsowsHxby9AqAoLe8e8pV5GfpadYuTKX3fxuEmd3Z4GIHgKMtjbpzMKCSKcVcW61G0Ckj4j4FEldPRc8KXNkNkMCL5zYuYHLk)JcygUNJCh5BLzMyjfEfG1RbP5usWtW)8wfawxCeMCL5zYuYHLk)JcygUNJCh5BLzM63Fc5CASsw4vWnyHKBeYQH6yjfEfG1RbP5usWtW)82dTU4im5kZZKPKdlv(hfWmCph5oY3kZmXsk8kaRxdsZPKGNG)5TVKZdDyjmd3tZjKZPjEo68KjdTYPH663Fc5CAINJopz8GSCAOUESKcVcW61G0Ckj4j4FE7l5CXrygUNMephDEshRjdTY1VpXZrNN0EqwoZsW2Qx)(njEo68KowtgALd3eY50(sop0HLmKAhiLovAltgALtd11JLu4vawVgKMtjbpb)Z70tQw033rCemk8sJrfQqia]] )

end