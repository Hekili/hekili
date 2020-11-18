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

    local LycarasHandler = setfenv( function ()
        if buff.travel_form.up then state:RunHandler( "stampeding_roar" )
        elseif buff.moonkin_form.up then state:RunHandler( "starfall" )
        elseif buff.bear_form.up then state:RunHandler( "barkskin" )
        elseif buff.cat_form.up then state:RunHandler( "primal_wrath" )
        else state:RunHandle( "wild_growth" ) end
    end, state )

    spec:RegisterHook( "reset_precast", function ()
        if azerite.masterful_instincts.enabled and buff.survival_instincts.up and buff.masterful_instincts.down then
            applyBuff( "masterful_instincts", buff.survival_instincts.remains + 30 )
        end

        if buff.lycaras_fleeting_glimpse.up then
            state:QueueAuraExpiration( "lycaras_fleeting_glimpse", LycarasHandler, buff.lycaras_fleeting_glimpse.expires )
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

            startsCombat = false,
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

    spec:RegisterPack( "Guardian", 20201114, [[dOuwjbqifIhPqYLiuvYMiWNiuvXOKIoLuQvPqQ6veKzrqDlfsf7Iu)ckAyeIoMuWYuq9mOGPjfY1iuzBsHQVrOknocHCocvX6iekZJq5EkY(GcDqcvvAHespukuAIeQQYfjuvQnsOQqFuku0jjeQwPcmtcvv1nLcf2juQHsOQOwkHQI8uatfk5ReQkyVq(lfdwOdJAXQQhtYKL0Lr2SeFwvA0QItt1Qviv61kuZwQUnuTBL(nOHlOJtiOLRYZP00fDDG2UI67cmEcboVcY6viL5lLSFIg1acleqLtcH9WICyr2qdn0i9WyyyruJWacihkKqaHSAm)siGLXjeqJjiFvNxeqipuhYvewiale8uec4jZqRigMy(65d4xRG4yADCWoNoCvhxsmToUcteWh07Pi(I(iGkNec7Hf5WISHgAOr6HXWWIxmGbeadMpWdba44nweWJxR0I(iGkzviGrjJnMG8vDELrXFhOxLdgLmInCMW)0jJn0iHLXHf5WIuoqoyuYyJ9H3xYkIjhmkzC0rgfXxf8cHhNKm2y5eZgdiCh7RmgEo880jRm20lYOLY03xz0TYO6HuJPABncO720IWcb0hsXhdryHWUbewiawLoCra4q4o2xtbE4iaA5FNQirrjkraFIpewiSBaHfcGw(3PksueG68KoNraJiJFWsr)j(mf4HRbdraSkD4Ia(eFMc8Wrjc7HryHayv6WfbC8mTqqRPC0oAdHaOL)DQIefLiSXacleaT8VtvKOia15jDoJagrgRhOx1kodiEMmFIpzuGmoImwpqVQHb9aINjZN4dbWQ0Hlcqb3z4yYKpKXg6NNwuIWUriSqa0Y)ovrIIauNN05mcOPm(blf9XZ0cbTMYr7OnKgmugB1sghrgvWzA5n1Z0MpdDYyBeaRshUiGpDw6gJse2IdHfcGw(3PksueG68KoNranLXpyPOpEMwiO1uoAhTH0GHYyRwY4iYOcotlVPEM28zOtgBJayv6Wfb4RIVLthUOeHDJJWcbql)7ufjkcqDEsNZiGMY4iYy9a9QwXzaXZK5t8jJcKXrKX6b6vnmOhq8mz(eFYyBzSvlzKvPptgAjCNSYigNKXHraSkD4Iai8qyaDMpCROeHT4fHfcGw(3PksueG68KoNranLXK70M6)X4)oz10Y)ovLX2YOazSPm(blf9N4ZuGhUgmugBJayv6Wfb85BSDSVOeHTicHfcGw(3PksueG68KoNranLXrKXkm1CLdtFMm2a(WnvgNFjD6QX((kJcKXrKrwLoC1CLdtFMm2a(WnvgNFjTVMs3FFszuGm2ughrgRWuZvom9zYyd4d38qCxNUASVVYyRwYyfMAUYHPptgBaF4MhI76JWzFTYigLrmiJTLXwTKXkm1CLdtFMm2a(WnvgNFjTnz1yzumzedYOazSctnx5W0NjJnGpCtLX5xsFeo7RvgftgfNmkqgRWuZvom9zYyd4d3uzC(L0PRg77Rm2gbWQ0HlcGRCy6ZKXgWhokrylEqyHaOL)DQIefbOopPZzeqtz8dwk6xUZQ0vMxq(QoVAWqzuGmwpqVQHb9aINjZN4tgBlJcKrwL(mzOLWDYkJInjJyabWQ0Hlcahc3IFekry3GiryHaOL)DQIefbOopPZzeWrLJSp8VtYyRwYyfM685y7J5t8PTjRglJIjJyqgB1sgBkJvyQZNJTpMpXN2MSASmkMm2izuGmEGlvG3lP7GLc7Bb0svdH)pwrAsec6HHuvgBlJTAjJSk9zYqlH7KvgX4Km2ieaRshUiG85y7J5t8HaudP6Kj57Lslc7gqjc7gAaHfcGw(3PksueG68KoNraFWsr7RIVLthUMxq(QoVgyXaEwOsxHbRmkqg)GLI(tNLUXMpXNUcdwzuGmYQ0NjdTeUtwzeJtYyJqaSkD4IaSbEiz(eFOeHDddJWcbql)7ufjkcqDEsNZiGpyPO9vX3YPdxnyOmkqgzv6ZKHwc3jRmkMmomcGvPdxeaod2rjc7gWacleaT8VtvKOia15jDoJaAkJFWsrB5z(Lmki(NtEtTnz1yzeJtYydYyBzuGm2ug)GLIoHW8XWB1O6CGgmugBlJcKXpyPO9vX3YPdxnyOmkqgzv6ZKHwc3jRmojJdJayv6WfbGZGDuIWUHgHWcbql)7ufjkcqDEsNZiGpyPO9vX3YPdxnyOmkqgzv6ZKHwc3jRmk2KmIbeaRshUiaCEF7ekry3G4qyHaOL)DQIefbOopPZzeWrLJSp8VtYOazKvPptgAjCNSYOytYigqaSkD4IaWHWT4hHaudP6Kj57Lslc7gqjc7gACewiaA5FNQirraQZt6Cgb0ugBkJnLXpyPOtimFm8wnQohOTjRglJyCsghwgBlJTAjJnLXpyPOtimFm8wnQohObdLrbY4hSu0jeMpgERgvNd0hHZ(ALrXKXg0ItgBlJTAjJnLXpyPOT8m)sgfe)ZjVP2MSASmIXjzedYyBzSTmkqgzv6ZKHwc3jRmkMmIbzSncGvPdxeaod2rjc7geViSqa0Y)ovrIIauNN05mcGvPptgAjCNSYigLXgqaSkD4IaYNJTpMpXhkry3GicHfcGw(3PksueG68KoNranLXpyPOF5oRsxzEb5R68QbdLrbYy9a9QwXzaXZK5t8jJTLrbYiRsFMm0s4ozLrXMKrmiJTAjJnLXpyPOF5oRsxzEb5R68QbdLrbY4iYy9a9QwXzaXZK5t8jJcKXrKX6b6vnmOhq8mz(eFYyBzuGmYQ0NjdTeUtwzuSjzediawLoCra4q4w8Jqjc7gepiSqa0Y)ovrIIauNN05mcOPm2ugp(LKrXKrXJiLX2YOazKvPptgAjCNSYOyYigKX2YyRwYytzSPmE8ljJIjJIiXjJTLrbYiRsFMm0s4ozLrXKrmiJcKXK70MAleSBGft(qMc8iBQPL)DQkJTraSkD4IaW59TtOeH9WIeHfcGw(3PksueG68KoNravyQZNJTpMpXN2MSASmIrzCyeaRshUiGqW(mD(Oria1qQozs(EP0IWUbuIWE4gqyHayv6WfbKphBFmFIpeaT8VtvKOOeH9WdJWcbql)7ufjkcqDEsNZiawL(mzOLWDYkJIjJyabWQ0HlcaNb7OeH9WyaHfcGvPdxeGnWdjZN4dbql)7ufjkkrypCJqyHaOL)DQIefbOopPZzeWXVKUsfx5PmkMm2irkJcKXpyPO9dUfWtFeo7RvgftgfPwCiawLoCra(b3c4HsuIaW90F50Hlcle2nGWcbql)7ufjkcqDEsNZiaFvqCFFnvgNFjJ4SYigLr)GBb8mvgNFjt(CK9b2RYOaz8dwkA)GBb80hHZ(ALrXKrmiJJEz8HTjHayv6Wfb4hClGhkrypmcleaT8VtvKOia15jDoJasEh77RmkqgFiUNp6qvkJIjJnU4qaSkD4IaoAPaUJse2yaHfcGw(3PksueG68KoNrajVJ99vgfiJpe3ZhDOkLrXKXgxCiawLoCraLJ2rZPQ5OxAPJthUOeHDJqyHaOL)DQIefbOopPZzeqcFF7KUsfAT(mzLrbY4dX98rhQszumzuejseaRshUiaEDC2alMkX5dkryloewiaA5FNQirraQZt6Cgb0ugtUtBQ)hJ)7Kvtl)7uvgBlJcKXMY4hSu0FIptbE4AWqzSTmkqgFiUNp6qvkJIjJIxXjJcKrFvqCFFnvgNFjJ4SYigLrrQhwCY4OxgFiUNpACweGayv6Wfb85BSDSVOeHDJJWcbql)7ufjkcqDEsNZiGpyPOTG3SpZDJV20xvA1vyWkJcKXpyPO)8n2o2xDfgSYOaz8H4E(OdvPmkMm24IugfiJ(QG4((AQmo)sgXzLrmkJIupS4KXrVm(qCpF04SiabWQ0HlcWcEZ(m3n(AtFvPfLOeb0hsXhRqyHWUbewiawLoCrakonf4HJaOL)DQIefLOebuPcd2tewiSBaHfcGvPdxeGDmyVB(S9bbql)7ufjkkrypmcleaT8VtvKOia15jDoJagrg)GLIo8GbDnyicGvPdxeaOLmEs4wuIWgdiSqa0Y)ovrIIauNN05mcOPm2ugBkJj3Pn1peFPbwm5dzc8Evtl)7uvgfiJFWsr)q8LgyXKpKjW7vnyOm2wgfiJnLX6b6vTIZaINjZN4tgB1sgRhOx1WGEaXZK5t8jJTLrbY4iY4hSu0HhmORbdLX2YyRwYytzSPm(blf9NolDJnFIpnyOm2QLm(blfTVk(woD4AEb5R68AGfd4zHknyOm2wgfiJnLXrKX6b6vTIZaINjZN4tgfiJJiJ1d0RAyqpG4zY8j(KX2YyBzSncGvPdxeqimD4Ise2ncHfcGw(3PksueaRshUiGdCnSkD4A6UnraQZt6CgbupqVQvCgq8mz(eFYOaz8dwkAfNMc8W1GHiGUBtZY4ecqXzaXZekryloewiaA5FNQirraSkD4IaoW1WQ0HRP72ebOopPZzeq9a9Qgg0diEMmFIpzuGm(blfnoeUJ91uGhUgmeb0DBAwgNqaWGEaXZekry34iSqa0Y)ovrIIayv6WfbCGRHvPdxt3TjcqDEsNZiGMYytz8axQaVxs3hsXhBnLorPVVM3UJhAjnjcb9WqQkJTLrbYytzm5oTP(ZDEvKHlfF9CinT8VtvzSTmkqgBkJFWsr3hsXhBnLorPVVM3UJhAjnyOm2wgfiJnLXpyPO7dP4JTMsNO03xZB3XdTK(iC2xRmk2KmoSm2wgBJa6UnnlJtiG(qk(yikrylEryHaOL)DQIefbWQ0Hlc4axdRshUMUBteG68KoNranLXMY4bUubEVKUpKIp2AkDIsFFnVDhp0sAsec6HHuvgBlJcKXMYyYDAtDHoUB4sXxphstl)7uvgBlJcKXMY4hSu09Hu8XwtPtu67R5T74HwsdgkJTLrbYytz8dwk6(qk(yRP0jk99182D8qlPpcN91kJInjJdlJTLX2iGUBtZY4ecOpKIpwHse2IiewiaA5FNQirraSkD4IauCVByv6W10DBIa6UnnlJtiaCp9xoD4Ise2IhewiaA5FNQirraSkD4IaoW1WQ0HRP72eb0DBAwgNqaFIpuIseGIZaINjewiSBaHfcGvPdxeq4bd6iaA5FNQirrjc7HryHaOL)DQIefbOopPZzeWiY4hSu0konf4HRbdraSkD4IauCAkWdhLiSXacleaT8VtvKOia15jDoJa(GLIo8GbDnyicGvPdxeWXJjuIWUriSqa0Y)ovrIIauNN05mci5oTP(H4lnWIjFitG3RAA5FNQYOazCez8dwk6hIV0alM8HmbEVQbdraSkD4IaEi(sdSyYhYe49kkryloewiaA5FNQirraQZt6CgbupqVQvCgq8mz(eFiawLoCraeEimGoZhUvuIWUXryHaOL)DQIefbOopPZzeq9a9QwXzaXZK5t8Hayv6WfbOG7mCmzYhYyd9ZtlkrylEryHaOL)DQIefbOopPZzeqfM6Zd1hvoY(W)ojJcKrfe)dnHqFtRmIXjzSriawLoCraNhIse2IiewiaA5FNQirraQZt6CgbOG4FOje6BALrmojJncbWQ0HlcOqhu5qqR57jHse2IhewiaA5FNQirraQZt6Cgb0ughrgRWuZvom9zYyd4d3uzC(L0PRg77Rmkqghrgzv6WvZvom9zYyd4d3uzC(L0(AkD)9jLrbYytzCezSctnx5W0NjJnGpCZdXDD6QX((kJTAjJvyQ5khM(mzSb8HBEiURpcN91kJyugXGm2wgB1sgRWuZvom9zYyd4d3uzC(L02KvJLrXKrmiJcKXkm1CLdtFMm2a(WnvgNFj9r4SVwzumzuCYOazSctnx5W0NjJnGpCtLX5xsNUASVVYyBeaRshUiaUYHPptgBaF4OeHDdIeHfcGw(3PksueG68KoNravyQpEmPpQCK9H)DsgfiJki(hAcH(MwzumzSriawLoCrahpMqjc7gAaHfcGw(3PksueG68KoNraki(hAcH(MwzumzuCiawLoCra2NJQOeLiafe2RWG1IWcHDdiSqaSkD4IacHPdxeaT8VtvKOOeH9WiSqaSkD4IaEi(sdzT0QieaT8VtvKOOeHngqyHayv6Wfb87qy1uaVHqa0Y)ovrIIse2ncHfcGvPdxeWNolDJ99fbql)7ufjkkryloewiawLoCra8P4Lmj8oAteaT8VtvKOOeHDJJWcbWQ0HlcO7VpP1m6cwFXPnra0Y)ovrIIse2IxewiawLoCraf)OFhcRiaA5FNQirrjcBrecleaRshUiaEvKnpUBuCVJaOL)DQIefLiSfpiSqa0Y)ovrIIauNN05mc4dwk6pXNPapCnyicGvPdxeW)CB2991uapuIWUbrIWcbql)7ufjkcqDEsNZiGMYyfMACiCl(r60vJ99vgB1sgzv6ZKHwc3jRmIrzSbzSTmkqgRWuNphBFmFIpD6QX((Iayv6Wfb4RIVLthUOeHDdnGWcbWQ0Hlc4tNLUXiaA5FNQirrjc7gggHfcGw(3PksueaRshUia1qQomp46kZVZ2ebqLcPsZY4ecqnKQdZdUUY87Snrjc7gWacleaT8VtvKOia15jDoJas47BN0kiSxHbRvgfiJnLX0XjtcnvNKrXKrwLoCnkiSxHbRmIPmoSm2QLmYQ0NjdTeUtwzeJYydYyBeaRshUiaEDC2alMkX5dkry3qJqyHayv6WfbGt4WBidSy6GkVAQhX4weaT8VtvKOOeHDdIdHfcGvPdxeaOLmEs4weaT8VtvKOOeLiGWJuq8pNiSqy3acleaRshUiGX(wpQASH(5Pfbql)7ufjkkrypmcleaT8VtvKOia15jDoJaQhOx1kodiEMmFIpzuGm(blfTIttbE4AWqeaRshUiGWdg0rjcBmGWcbql)7ufjkcqDEsNZiGrKXMYy9a9QwXzaXZK5t8jJcKXpyPOvCAkWdxdgkJTLrbY4iYytzSEGEvdd6beptMpXNmkqg)GLIghc3X(AkWdxdgkJTraSkD4Ia(eFMc8Wrjc7gHWcbql)7ufjkcqDEsNZiGK70M6hIV0alM8HmbEVQPL)DQkJcKXMYy9a9QwXzaXZK5t8jJcKXpyPOvCAkWdxdgkJTAjJ1d0RAyqpG4zY8j(KrbY4hSu04q4o2xtbE4AWqzSncGvPdxeWdXxAGft(qMaVxrjcBXHWcbql)7ufjkcqDEsNZiG6b6vnmOhq8mz(eFYOaz8dwkACiCh7RPapCnyicGvPdxeqWX5dkrjcag0diEMqyHWUbewiaA5FNQirraQZt6CgbmIm(blfnoeUJ91uGhUgmebWQ0Hlcahc3X(AkWdhLiShgHfcGw(3PksueG68KoNraj3Pn1peFPbwm5dzc8Evtl)7uvgfiJJiJFWsr)q8LgyXKpKjW7vnyicGvPdxeWdXxAGft(qMaVxrjcBmGWcbql)7ufjkcqDEsNZiG6b6vnmOhq8mz(eFiawLoCraeEimGoZhUvuIWUriSqa0Y)ovrIIauNN05mcOEGEvdd6beptMpXhcGvPdxeGcUZWXKjFiJn0ppTOeHT4qyHaOL)DQIefbOopPZzeqtzCezSctnx5W0NjJnGpCtLX5xsNUASVVYOazCezKvPdxnx5W0NjJnGpCtLX5xs7RP093NugfiJnLXrKXkm1CLdtFMm2a(Wnpe31PRg77Rm2QLmwHPMRCy6ZKXgWhU5H4U(iC2xRmIrzedYyBzSvlzSctnx5W0NjJnGpCtLX5xsBtwnwgftgXGmkqgRWuZvom9zYyd4d3uzC(L0hHZ(ALrXKrXjJcKXkm1CLdtFMm2a(WnvgNFjD6QX((kJTraSkD4Ia4khM(mzSb8HJse2nocleaT8VtvKOia15jDoJaoQCK9H)DsgB1sg)GLI(L7SkDL5fKVQZRgmebWQ0Hlcahc3IFecqnKQtMKVxkTiSBaLiSfViSqa0Y)ovrIIauNN05mc4OYr2h(3jeaRshUial4w8JqaQHuDYK89sPfHDdOeHTicHfcGw(3PksueG68KoNranLXpyPOjv3dTKPdU8PbdLXwTKXpyPOjv3dTKXc78PbdLX2iawLoCra2Kpl49sOeHT4bHfcGw(3PksueG68KoNranLrs19qlP910bx(KXwTKrs19qlPTWoFMLebPm2wgB1sgBkJKQ7Hws7RPdU8jJcKXpyPOTjFwW7LmeEimGoCAtthC5tdgkJTraSkD4IaSjFf)iuIWUbrIWcbWQ0Hlci448bbql)7ufjkkrjkraZ0zD4IWEyroSiBOHgWaciGV13xlcq8bXVIpHTio2nMIyYOmI1djJoEi8szSapzu8Jcc7vyWAf)iJhjcb9JQYOfItYidMqCoPQmQE49LSA5aX)(sYydyqetgBSWDMUKQYiGJ3yLr7qBYIazu8LmMqzu8pilJvF2ToCLryiDCcpzSjMTLXMnicARLdKdeXXdHxsvzu8iJSkD4kJD3MwTCacWgske2niYgHacpyX7ecyuYyJjiFvNxzu83b6v5GrjJydNj8pDYydnsyzCyroSiLdKdgLm2yF49LSIyYbJsghDKrr8vbVq4XjjJnwoXSXac3X(kJHNdppDYkJn9ImAPm99vgDRmQEi1yQ2wlhihmkzu8TiGuGjvLXpvGhjJki(Ntz8tV(A1YO4xLIctRmUWD05Hp8cyxgzv6W1kJWTpKwoGvPdxRo8ife)ZPqtyo236rvJn0ppTYbSkD4A1HhPG4FofAcZWdg0f2lt1d0RAfNbeptMpXNGpyPOvCAkWdxdgkhWQ0HRvhEKcI)5uOjm)eFMc8Wf2ltJ0SEGEvR4mG4zY8j(e8blfTIttbE4AWW2cgPz9a9Qgg0diEMmFIpbFWsrJdH7yFnf4HRbdBlhWQ0HRvhEKcI)5uOjmFi(sdSyYhYe49QWEzk5oTP(H4lnWIjFitG3RAA5FNQcAwpqVQvCgq8mz(eFc(GLIwXPPapCnyyRw1d0RAyqpG4zY8j(e8blfnoeUJ91uGhUgmSTCaRshUwD4rki(NtHMWm448ryVmvpqVQHb9aINjZN4tWhSu04q4o2xtbE4AWq5a5GrjJIVfbKcmPQmsZ0nKmMoojJ5djJSkHNm6wzKNzVZ)oPLdyv6W1ozhd27MpBFKdyv6W1k0eMGwY4jHBf2ltJ8blfD4bd6AWq5awLoCTcnHzimD4kSxMA2SzYDAt9dXxAGft(qMaVx10Y)ovf8blf9dXxAGft(qMaVx1GHTf0SEGEvR4mG4zY8j(A1QEGEvdd6beptMpXxBbJ8blfD4bd6AWW2TA1S5hSu0F6S0n28j(0GHTA9blfTVk(woD4AEb5R68AGfd4zHknyyBbnhPEGEvR4mG4zY8j(ems9a9Qgg0diEMmFIV2TBlhmkzKvPdxRqtyEGRHvPdxt3TPWlJttkodiEMe2lt1d0RAfNbeptMpXNGMnvqyVcdwD(CS9X8j(0hHZ(AXOifOGWEfgSACEF7K(iC2xlgfPGkm14q4w8J0hHZ(AX40RQkKi1ItWXVKynsKc(GLI2xfFlNoCnVG8vDEnWIb8SqLUcdwbFWsr)PZs3yZN4txHbRGpyPOF5oRsxzEb5R68QRWGTDRwn)GLIwXPPapCnyOaAP7DimoS4A3QvZdCPc8EjnKZhdSyYhYq9kDM6b6vnjcb9WqQkyKpyPOHC(yGft(qgQxPZupqVQbdf08dwkAfNMc8W1GHcOLU3HW4WISD7wTAEGlvG3lPHC(yGft(qgQxPZupqVQjriOhgsvbFWsr)q8LgyXKpKjW7v9r4SVwXAqKTf08dwkAfNMc8W1GHcOLU3HW4WISDRwnvWzA5n1Jh6CEfOGWEfgSAcpegqN5d3Q(iC2xRytniGvPptgAjCNSInC72YbSkD4AfAcZdCnSkD4A6UnfEzCAsXzaXZKWEzQEGEvR4mG4zY8j(e8blfTIttbE4AWq5GrjJSkD4AfAcZdCnSkD4A6UnfEzCAcg0diEMe2lt1d0RAyqpG4zY8j(e0SPcc7vyWQZNJTpMpXN(iC2xlgfPafe2RWGvJZ7BN0hHZ(AXOifC8lj2WIuWhSu0(Q4B50HRUcdwbFWsr)PZs3yZN4txHbB7wTA(blfnoeUJ91uGhUgmuqfMAl4w8J0hvoY(W)o1UvRMFWsrJdH7yFnf4HRbdf8blf9dXxAGft(qMaVx1GHTB1Q5hSu04q4o2xtbE4AWqbn)GLIMuDp0sMo4YNgmSvRpyPOjv3dTKXc78PbdBlyKdCPc8EjnKZhdSyYhYq9kDM6b6vnjcb9WqQ2UvRMh4sf49sAiNpgyXKpKH6v6m1d0RAsec6HHuvWiFWsrd58XalM8HmuVsNPEGEvdg2UvRMk4mT8M61FFstHjbkiSxHbRwb3z4yYKpKXg6NNw9r4SVwXMAODRwnvWzA5n1Jh6CEfOGWEfgSAcpegqN5d3Q(iC2xRytniGvPptgAjCNSInC72YbSkD4AfAcZdCnSkD4A6UnfEzCAcg0diEMe2lt1d0RAyqpG4zY8j(e8blfnoeUJ91uGhUgmuoGvPdxRqtyEGRHvPdxt3TPWlJtt9Hu8XqH9YuZMh4sf49s6(qk(yRP0jk99182D8qlPjriOhgs12cAMCN2u)5oVkYWLIVEoKMw(3PABbn)GLIUpKIp2AkDIsFFnVDhp0sAWW2cA(blfDFifFS1u6eL((AE7oEOL0hHZ(AfBA42TLdyv6W1k0eMh4Ayv6W10DBk8Y40uFifFSsyVm1S5bUubEVKUpKIp2AkDIsFFnVDhp0sAsec6HHuTTGMj3Pn1f64UHlfF9CinT8Vt12cA(blfDFifFS1u6eL((AE7oEOL0GHTf08dwk6(qk(yRP0jk99182D8qlPpcN91k20WTBlhWQ0HRvOjmvCVByv6W10DBk8Y40eUN(lNoCLdyv6W1k0eMh4Ayv6W10DBk8Y400N4toqoGvPdxR(t8n9j(mf4HlSxMg5dwk6pXNPapCnyOCaRshUw9N4tOjmpEMwiO1uoAhTHKdyv6W1Q)eFcnHPcUZWXKjFiJn0ppTc7LPrQhOx1kodiEMmFIpbJupqVQHb9aINjZN4toGvPdxR(t8j0eMF6S0n28j(e2ltn)GLI(4zAHGwt5OD0gsdg2Q1ik4mT8M6zAZNHU2YbSkD4A1FIpHMW0xfFlNoCf2ltn)GLI(4zAHGwt5OD0gsdg2Q1ik4mT8M6zAZNHU2YbSkD4A1FIpHMWKWdHb0z(WTkSxMAos9a9QwXzaXZK5t8jyK6b6vnmOhq8mz(eFTB1IvPptgAjCNSyCAy5awLoCT6pXNqty(5BSDSVc7LPMj3Pn1)JX)DYQPL)DQ2wqZpyPO)eFMc8W1GHTLdyv6W1Q)eFcnHjx5W0NjJnGpCHf2ltnhPctnx5W0NjJnGpCtLX5xsNUASVVcgHvPdxnx5W0NjJnGpCtLX5xs7RP093NuqZrQWuZvom9zYyd4d38qCxNUASVVTAvHPMRCy6ZKXgWhU5H4U(iC2xlgXq7wTQWuZvom9zYyd4d3uzC(L02KvJfddcQWuZvom9zYyd4d3uzC(L0hHZ(AftCcQWuZvom9zYyd4d3uzC(L0PRg77BB5awLoCT6pXNqtyIdHBXpsyVm18dwk6xUZQ0vMxq(QoVAWqb1d0RAyqpG4zY8j(AlGvPptgAjCNSInHb5awLoCT6pXNqtyMphBFmFIpHvdP6Kj57Ls7udc7LPJkhzF4FNA1QctD(CS9X8j(02KvJfddTA1SctD(CS9X8j(02KvJfRrcoWLkW7L0DWsH9TaAPQHW)hRinjcb9WqQ2UvlwL(mzOLWDYIXPgjhWQ0HRv)j(eActBGhsc7LPpyPO9vX3YPdxZliFvNxdSyapluPRWGvWhSu0F6S0n28j(0vyWkGvPptgAjCNSyCQrYbSkD4A1FIpHMWeNb7c7LPpyPO9vX3YPdxnyOawL(mzOLWDYk2WYbSkD4A1FIpHMWeNb7c7LPMFWsrB5z(Lmki(NtEtTnz1ymo1qBbn)GLIoHW8XWB1O6CGgmSTGpyPO9vX3YPdxnyOawL(mzOLWDYonSCaRshUw9N4tOjmX59Ttc7LPpyPO9vX3YPdxnyOawL(mzOLWDYk2egKdyv6W1Q)eFcnHjoeUf)iHvdP6Kj57Ls7udc7LPJkhzF4FNeWQ0NjdTeUtwXMWGCaRshUw9N4tOjmXzWUWEzQzZMFWsrNqy(y4TAuDoqBtwngJtd3UvRMFWsrNqy(y4TAuDoqdgk4dwk6ecZhdVvJQZb6JWzFTI1GwCTB1Q5hSu0wEMFjJcI)5K3uBtwngJtyODBbSk9zYqlH7Kvmm0woGvPdxR(t8j0eM5ZX2hZN4tyVmXQ0NjdTeUtwm2GCaRshUw9N4tOjmXHWT4hjSxMA(blf9l3zv6kZliFvNxnyOG6b6vTIZaINjZN4RTawL(mzOLWDYk2egA1Q5hSu0VCNvPRmVG8vDE1GHcgPEGEvR4mG4zY8j(ems9a9Qgg0diEMmFIV2cyv6ZKHwc3jRytyqoGvPdxR(t8j0eM48(2jH9YuZMh)sIjEezBbSk9zYqlH7Kvmm0UvRMnp(LetejU2cyv6ZKHwc3jRyyqqYDAtTfc2nWIjFitbEKn10Y)ovBlhWQ0HRv)j(eAcZqW(mD(OrcRgs1jtY3lL2Pge2ltvyQZNJTpMpXN2MSAmghwoGvPdxR(t8j0eM5ZX2hZN4toGvPdxR(t8j0eM4myxyVmXQ0NjdTeUtwXWGCaRshUw9N4tOjmTbEiz(eFYbSkD4A1FIpHMW0p4wapH9Y0XVKUsfx5PynsKc(GLI2p4wap9r4SVwXePwCYbYbJsgzv6W1k0eMkU3nSkD4A6UnfEzCAc3t)LthUYbJsgzv6W1k0eMbEVAup89sYbJsgzv6W1k0eMkU3nSkD4A6UnfEzCAsbH9kmyTYbJsgzv6W1k0eM4myxyVmD8lPRuXvEk2WIuaRsFMm0s4ozfRrYbJsgzv6W1k0eM4myxyVmD8lPRuXvEk2WIuazT0QiTcULURsdVvJnpVqACE0fEcg5dwkA7dFH0svJQZbwnyOCWOKrwLoCTcnHPFWTaEc7Ljf0MtISvRMh)syubTPaE0OZts35HOJQgCEjnT8VtvbSk9zYqlH7KfJd3woyuYiRshUwHMWmeSptNpAKWjFVuA8YufM685y7J5t8PTjRgpvHPoFo2(y(eFACweySjRgBLdgLmYQ0HRvOjmXHWT4hjCY3lLgVmvHPghc3IFK(OYr2h(3jbSk9zYqlH7KvSHLdgLmYQ0HRvOjmZNJTpc7LPMFWsr7RIVLthU6kmyfWQ0NjdTeUtwm2q7wTA(blfTVk(woD4QbdfWQ0NjdTeUtwm2O2YbJsgzv6W1k0eM2apKe2ltFWsr7RIVLthU6kmyfWQ0NjdTeUtwm2i5GrjJSkD4AfActCEF7KWEzQctD(CS9X8j(0PRg77RCWOKrwLoCTcnHjoeUf)iHt(EP04LPpyPOF5oRsxzEb5R68QbdfWQ0NjdTeUtwXgwoyuYiRshUwHMWmFo2(ihmkzu8rV3LXapFKXgdiCl(rYyGNpYO4ZWSXqemSCWOKrwLoCTcnHjoeUf)iH9YepA05jPdHb0zGft(qgCiC1hVJXydcyv6ZKHwc3j7udYbJsgzv6W1k0eM2apKKdKdyv6W1QX90F50H7KFWTaEc7LjFvqCFFnvgNFjJ4Sy0p4waptLX5xYKphzFG9QGpyPO9dUfWtFeo7Rvmmm6FyBsYbSkD4A14E6VC6WvOjmpAPaUlSxMsEh77RGhI75JouLI14ItoGvPdxRg3t)LthUcnHz5OD0CQAo6Lw640HRWEzk5DSVVcEiUNp6qvkwJlo5awLoCTACp9xoD4k0eM864SbwmvIZhH9YucFF7KUsfAT(mzf8qCpF0HQumrKiLdyv6W1QX90F50HRqty(5BSDSVc7LPMj3Pn1)JX)DYQPL)DQ2wqZpyPO)eFMc8W1GHTf8qCpF0HQumXR4e4RcI77RPY48lzeNfJIupS4g9pe3ZhnolcKdyv6W1QX90F50HRqtyAbVzFM7gFTPVQ0kSxM(GLI2cEZ(m3n(AtFvPvxHbRGpyPO)8n2o2xDfgScEiUNp6qvkwJlsb(QG4((AQmo)sgXzXOi1dlUr)dX98rJZIa5a5awLoCTAfe2RWG1ofcthUYbSkD4A1kiSxHbRvOjmFi(sdzT0Qi5awLoCTAfe2RWG1k0eM)oewnfWBi5awLoCTAfe2RWG1k0eMF6S0n23x5awLoCTAfe2RWG1k0eM8P4Lmj8oAt5awLoCTAfe2RWG1k0eMD)9jTMrxW6loTPCaRshUwTcc7vyWAfAcZIF0VdHv5awLoCTAfe2RWG1k0eM8QiBEC3O4ExoGvPdxRwbH9kmyTcnH5)CB2991uapH9Y0hSu0FIptbE4AWq5awLoCTAfe2RWG1k0eM(Q4B50HRWEzQzfMACiCl(r60vJ99TvlwL(mzOLWDYIXgAlOctD(CS9X8j(0PRg77RCaRshUwTcc7vyWAfAcZpDw6glhWQ0HRvRGWEfgSwHMWe0sgpjCHPsHuPzzCAsnKQdZdUUY87SnLdyv6W1QvqyVcdwRqtyYRJZgyXujoFe2ltj89TtAfe2RWG1kOz64KjHMQtIPGWEfgSIVgUvlwL(mzOLWDYIXgAlhWQ0HRvRGWEfgSwHMWeNWH3qgyX0bvE1upIXTYbSkD4A1kiSxHbRvOjmbTKXtc3khihWQ0HRvR4mG4zAk8GbD5awLoCTAfNbeptcnHPIttbE4c7LPr(GLIwXPPapCnyOCaRshUwTIZaINjHMW84XKWEz6dwk6Wdg01GHYbSkD4A1kodiEMeAcZhIV0alM8HmbEVkSxMsUtBQFi(sdSyYhYe49QMw(3PQGr(GLI(H4lnWIjFitG3RAWq5awLoCTAfNbeptcnHjHhcdOZ8HBvyVmvpqVQvCgq8mz(eFYbSkD4A1kodiEMeActfCNHJjt(qgBOFEAf2lt1d0RAfNbeptMpXNCaRshUwTIZaINjHMW88qH9YufM6Zd1hvoY(W)ojqbX)qti030IXPgjhWQ0HRvR4mG4zsOjml0bvoe0A(Esc7Ljfe)dnHqFtlgNAKCaRshUwTIZaINjHMWKRCy6ZKXgWhUWEzQ5ivyQ5khM(mzSb8HBQmo)s60vJ99vWiSkD4Q5khM(mzSb8HBQmo)sAFnLU)(KcAosfMAUYHPptgBaF4MhI760vJ99TvRkm1CLdtFMm2a(Wnpe31hHZ(AXigA3QvfMAUYHPptgBaF4MkJZVK2MSASyyqqfMAUYHPptgBaF4MkJZVK(iC2xRyItqfMAUYHPptgBaF4MkJZVKoD1yFFBlhWQ0HRvR4mG4zsOjmpEmjSxMQWuF8ysFu5i7d)7Kafe)dnHqFtRynsoGvPdxRwXzaXZKqtyAFoQkSxMuq8p0ec9nTIjo5a5awLoCT6(qk(y1KIttbE4YbYbSkD4A19Hu8XWjCiCh7RPapC5a5awLoCTAyqpG4zAchc3X(AkWdxyVmnYhSu04q4o2xtbE4AWq5awLoCTAyqpG4zsOjmFi(sdSyYhYe49QWEzk5oTP(H4lnWIjFitG3RAA5FNQcg5dwk6hIV0alM8HmbEVQbdLdyv6W1QHb9aINjHMWKWdHb0z(WTkSxMQhOx1WGEaXZK5t8jhWQ0HRvdd6beptcnHPcUZWXKjFiJn0ppTc7LP6b6vnmOhq8mz(eFYbSkD4A1WGEaXZKqtyYvom9zYyd4dxyVm1CKkm1CLdtFMm2a(WnvgNFjD6QX((kyewLoC1CLdtFMm2a(WnvgNFjTVMs3FFsbnhPctnx5W0NjJnGpCZdXDD6QX((2QvfMAUYHPptgBaF4MhI76JWzFTyedTB1Qctnx5W0NjJnGpCtLX5xsBtwnwmmiOctnx5W0NjJnGpCtLX5xsFeo7RvmXjOctnx5W0NjJnGpCtLX5xsNUASVVTLdyv6W1QHb9aINjHMWehc3IFKWQHuDYK89sPDQbH9Y0rLJSp8VtTA9blf9l3zv6kZliFvNxnyOCaRshUwnmOhq8mj0eMwWT4hjSAivNmjFVuANAqyVmDu5i7d)7KCaRshUwnmOhq8mj0eM2Kpl49sc7LPMFWsrtQUhAjthC5tdg2Q1hSu0KQ7HwYyHD(0GHTLdyv6W1QHb9aINjHMW0M8v8Je2ltnjv3dTK2xthC5Rvls19qlPTWoFMLebz7wTAsQUhAjTVMo4YNGpyPOTjFwW7LmeEimGoCAtthC5tdg2woGvPdxRgg0diEMeAcZGJZhuIsec]] )

end