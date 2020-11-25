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
        return eclipse.wrath_counter
    end )

    spec:RegisterStateExpr( "solar_eclipse", function ()
        return eclipse.starfire_counter
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

    spec:RegisterPack( "Guardian", 20201124, [[dOeIobqijrpsrkxsrcPnbL(KIeQgfL4uusRsrQQxrqMfb1TuKQ0UO4xqrdJq4yeQwMc0ZGcMMKqxtsW2uKuFtrIACeIQZPijwhHO08iuUNIAFqHoOIeKfsi9qfjPjQiH4IksOSrfjq9rfjsNKquSsfXmvKG6Mkse7KanufjqwQIeGNcYujGVQib0EH8xsnyQCyulgWJjzYs5YiBwIpduJgiNwy1ksv8Af0SLQBdv7wPFRQHlPooHiTCvEovnDrxhuBxH(oLA8eI48kG1RivMVK0(jAK4ibqqnojKGdkIbfH4IpyfndIHbXqfXackhOMqq1SAidMqqlJtiOPuy(AbViOAEG(ZnKaii)dFkcbbkZAVilMycosqWag1JJPpWH7Cg)QoUKy6dCfMiia4ONImlcab14KqcoOigueIl(Gv0miggediigob9hcckWNQiiqrRrlcab1iVcbnnPBkfMVwWR0nf5GJMCY0Kob)rchGoPBWkkS0nOigueYjYjtt6MQG4fm5fzLtMM0n9kDImR6V6)4KKUPkNyoL8)omwPR(I)ImiV0zjksNNYmwWsx4LofisnKAwniOE4tpsaeuFafF8JeajO4ibqqSkJFrq4)VdJvx(dhbrld0PgsuuIseeaXhsaKGIJeabrld0PgsueK6IKUGrqvkDaWLIbG4tx(d3axJGyvg)IGai(0L)WrjsWbrcGGyvg)IGoEK2h2RlhTt3aiiAzGo1qIIsKGyajacIwgOtnKOii1fjDbJGQu6AhC0mkoTjEK0aeFshwPRsPRDWrZ82DBIhjnaXhcIvz8lcs974pK0jis7RJlspkrcwrKaiiAzGo1qIIGuxK0fmcYI0baxkMJhP9H96Yr70nGbUw6Qwv6Qu6u)iT8MMrAtqdCsNveeRY4xeeaDE6gIsKGvajacIwgOtnKOii1fjDbJGSiDaWLI54rAFyVUC0oDdyGRLUQvLUkLo1pslVPzK2e0aN0zfbXQm(fbfRIVLZ4xuIeCQrcGGOLb6udjkcsDrsxWiilsxLsx7GJMrXPnXJKgG4t6WkDvkDTdoAM3UBt8iPbi(KoRsx1QshRYyK00s4b5LomolDdIGyvg)IGi863MonWVnuIeCkJeabrld0PgsueK6IKUGrqwKUK70MgGJXb6K3qld0PM0zv6WkDwKoa4sXaq8Pl)HBGRLoRiiwLXViia(g6hglkrckYrcGGOLb6udjkcsDrsxWiilsxLsx7td346mgjT3MpCDJXzWKjd1WyblDyLUkLowLXVgUX1zmsAVnF46gJZGjtS6spadkLoSsNfPRsPR9PHBCDgJK2BZhUgeXDtgQHXcw6Qwv6AFA4gxNXiP928HRbrC3CeohRx6WO0HbPZQ0vTQ01(0WnUoJrs7T5dx3yCgmz8jRgkDIjDyq6WkDTpnCJRZyK0EB(W1ngNbtMJW5y9sNysxfKoSsx7td346mgjT3MpCDJXzWKjd1WyblDwrqSkJFrqCJRZyK0EB(WrjsWPcsaeeTmqNAirrqQls6cgbzr6aGlfdyUZQmuAWW81cEnW1shwPRDWrZ82DBIhjnaXN0zv6WkDSkJrstlHhKx6eBw6WacIvz8lcc))TehHsKGIlcKaiiAzGo1qIIGyvg)IGsqh7bPbi(qqQls6cgbDu5ipigOtsx1Qsx7ttc6ypinaXNXNSAO0jM0HbPRAvPZI01(0KGo2dsdq8z8jRgkDIjDvu6WkDh8sL)atMoCPWXwG9utt4ahRidjsHJ6AQjDwLUQvLowLXiPPLWdYlDyCw6QicsnGQt6KpWu6rckokrckU4ibqq0YaDQHefbPUiPlyeeaCPyIvX3Yz8RgmmFTGx9x0WN)vM2BVshwPdaUuma05PBOgG4Z0E7v6WkDSkJrstlHhKx6W4S0vreeRY4xeK3oQjnaXhkrck(Gibqq0YaDQHefbPUiPlyeeaCPyIvX3Yz8RbUw6WkDSkJrstlHhKx6et6gebXQm(fbHZWDuIeuCmGeabrld0PgsueK6IKUGrqwKoa4sX45rgmPvpoaN8MgFYQHshgNLoXLoRshwPZI0baxkM8)eKM3Mw1zBdCT0zv6WkDaWLIjwfFlNXVg4APdR0XQmgjnTeEqEPBw6gebXQm(fbHZWDuIeu8kIeabrld0PgsueK6IKUGrqaWLIjwfFlNXVg4APdR0XQmgjnTeEqEPtSzPddiiwLXViiCEb3juIeu8kGeabrld0PgsueeRY4xee()BjocbPUiPlye0rLJ8GyGojDyLowLXiPPLWdYlDInlDyabPgq1jDYhyk9ibfhLibfFQrcGGOLb6udjkcsDrsxWiilsNfPZI0baxkM8)eKM3Mw1zBJpz1qPdJZs3GsNvPRAvPZI0baxkM8)eKM3Mw1zBdCT0Hv6aGlft(FcsZBtR6ST5iCowV0jM0jUPcsNvPRAvPZI0baxkgppYGjT6Xb4K304twnu6W4S0HbPZQ0zv6WkDSkJrstlHhKx6et6WG0zfbXQm(fbHZWDuIeu8PmsaeeTmqNAirrqQls6cgbXQmgjnTeEqEPdJsN4iiwLXViOe0XEqAaIpuIeuCrosaeeTmqNAirrqQls6cgbzr6aGlfdyUZQmuAWW81cEnW1shwPRDWrZO40M4rsdq8jDwLoSshRYyK00s4b5LoXMLomiDvRkDwKoa4sXaM7SkdLgmmFTGxdCT0Hv6Qu6AhC0mkoTjEK0aeFshwPRsPRDWrZ82DBIhjnaXN0zv6WkDSkJrstlHhKx6eBw6WacIvz8lcc))TehHsKGIpvqcGGOLb6udjkcsDrsxWiilsNfP7yWK0jM0nveH0zv6WkDSkJrstlHhKx6et6WG0zv6Qwv6SiDwKUJbtsNysNiVcsNvPdR0XQmgjnTeEqEPtmPddshwPl5oTPX)WD9x0jisx(J8PHwgOtnPZkcIvz8lccNxWDcLibhueibqq0YaDQHefbXQm(fbvd3hPlMocbPUiPlyeu7ttc6ypinaXNXNSAO0HrPBqeKAavN0jFGP0JeuCuIeCqXrcGGyvg)IGsqh7bPbi(qq0YaDQHefLibhCqKaiiAzGo1qIIGuxK0fmcIvzmsAAj8G8sNyshgqqSkJFrq4mChLibhedibqqSkJFrqE7OM0aeFiiAzGo1qIIsKGdwrKaiiAzGo1qIIGuxK0fmc6yWKPrLqfP0jM0vrriDyLoa4sXe3Vf4ZCeohRx6et6eHPciiwLXViO4(TaFOeLii8idWCg)IeajO4ibqq0YaDQHefbPUiPlyeuSQhpwW6gJZGjDf8shgLU4(TaF6gJZGjDc6ipOV3KoSshaCPyI73c8zocNJ1lDIjDyq6M(shi2NecIvz8lckUFlWhkrcoisaeeTmqNAirrqQls6cgbL8omwWshwPdeX9eKPwLsNys3uxbeeRY4xe0rlzZDuIeedibqq0YaDQHefbPUiPlyeuY7WyblDyLoqe3tqMAvkDIjDtDfqqSkJFrqLJ2PlOM(iW0shNXVOejyfrcGGOLb6udjkcsDrsxWiO8bdUtMgvO1hJKx6WkDGiUNGm1Qu6et6e5IabXQm(fbXBGZ6VOBeNGqjsWkGeabrld0PgsueK6IKUGrqwKUK70MgGJXb6K3qld0PM0zv6WkDwKoa4sXaq8Pl)HBGRLoRshwPdeX9eKPwLsNys3uUcshwPlw1JhlyDJXzWKUcEPdJsNimdwbPB6lDGiUNGm4SibbXQm(fbbW3q)WyrjsWPgjacIwgOtnKOii1fjDbJGaGlfJh(gJrURJ1NXQsVP92R0Hv6aGlfdaFd9dJ10E7v6WkDGiUNGm1Qu6et6MAriDyLUyvpESG1ngNbt6k4LomkDIWmyfKUPV0bI4EcYGZIeeeRY4xeKh(gJrURJ1NXQspkrjcQ(i1JdWjsaKGIJeabrld0PgsueK6IKUGrqaWLIrXPU8hUbUw6WkDTdoAgfN2epsAaIpeeRY4xeu992DuIeCqKaiiAzGo1qIIGuxK0fmcQsPdaUumaeF6YF4g4APdR0zr6Qu6AhC0mkoTjEK0aeFsx1QshaCPyuCQl)HBAV9kDwLoSsNfPRsPRDWrZ82DBIhjnaXN0vTQ0baxkg8)3HXQl)HBAV9kDwrqSkJFrqaeF6YF4OejigqcGGOLb6udjkcsDrsxWiOK70MgqeFP(l6eePTJEZqld0PM0Hv6SiDTdoAgfN2epsAaIpPdR0baxkgfN6YF4g4APRAvPRDWrZ82DBIhjnaXN0Hv6aGlfd()7Wy1L)WnW1sx1QshaCPyW)FhgRU8hUbUw6WkDj3PnnaCNxfP5sj2ihWqld0PM0zfbXQm(fbbI4l1FrNGiTD0BOejyfrcGGOLb6udjkcsDrsxWiia4sXG))omwD5pCdCT0Hv6AhC0mVD3M4rsdq8HGyvg)IGSpobHsuIG6dO4JvibqckosaeeRY4xeKItD5pCeeTmqNAirrjkrqnQWW9ejasqXrcGGyvg)IG8dH7Dna7bHGOLb6udjkkrcoisaeeTmqNAirrqQls6cgbvP0baxkM67T7g4AeeRY4xeeSN0rs4EuIeedibqq0YaDQHefbPUiPlyeKfPZI0zr6sUtBAar8L6VOtqK2o6ndTmqNAshwPdaUumGi(s9x0jisBh9MbUw6SkDyLolsx7GJMrXPnXJKgG4t6Qwv6AhC0mVD3M4rsdq8jDwLoSsxLshaCPyQV3UBGRLoRsx1QsNfPZI0baxkga680nudq8zGRLUQvLoa4sXeRIVLZ4xnyy(AbV6VOHp)RmW1sNvPdR0zr6Qu6AhC0mkoTjEK0aeFshwPRsPRDWrZ82DBIhjnaXN0zv6SkDwrqSkJFrq1Fg)IsKGvejacIwgOtnKOii1fjDbJGAhC0mkoTjEK0aeFshwPdaUumko1L)WnW1iiwLXViOdE1SkJF19WNiOE4t9Y4ecsXPnXJekrcwbKaiiAzGo1qIIGuxK0fmcQDWrZ82DBIhjnaXN0Hv6aGlfd()7Wy1L)WnW1iiwLXViOdE1SkJF19WNiOE4t9Y4ec6T72epsOej4uJeabrld0PgsueK6IKUGrqwKols3bVu5pWKPpGIp2RlDIYybRb3d8ApzirkCuxtnPZQ0Hv6SiDj3PnnaCNxfP5sj2ihWqld0PM0zv6WkDwKoa4sX0hqXh71LorzSG1G7bETNmW1sNvPdR0zr6aGlftFafFSxx6eLXcwdUh41EYCeohRx6eBw6gu6SkDwrqSkJFrqh8Qzvg)Q7Hprq9WN6LXjeuFafF8JsKGtzKaiiAzGo1qIIGuxK0fmcYI0zr6o4Lk)bMm9bu8XEDPtuglyn4EGx7jdjsHJ6AQjDwLoSsNfPl5oTPPqh31CPeBKdyOLb6ut6SkDyLolshaCPy6dO4J96sNOmwWAW9aV2tg4APZQ0Hv6SiDaWLIPpGIp2RlDIYybRb3d8ApzocNJ1lDInlDdkDwLoRiiwLXViOdE1SkJF19WNiOE4t9Y4ecQpGIpwHsKGICKaiiAzGo1qIIGuxK0fmcYI0zr6sUtBAa4oVksZLsSroGHwgOtnPZQ0Hv6SiDvkDTdoAgfN2epsAaIpPZQ0Hv6SiDvkDTdoAM3UBt8iPbi(KoRshwPZI0P(rA5nnBaguQlmjDyLo1)92BVg1VJ)qsNGiTVoUi9MJW5y9sNyZsN4sNvPZkcIvz8lc6GxnRY4xDp8jcQh(uVmoHGE1VJ)qcLibNkibqq0YaDQHefbPUiPlyeKfPZI0LCN20uOJ7AUuInYbm0YaDQjDwLoSsNfPRsPRDWrZO40M4rsdq8jDwLoSsNfPRsPRDWrZ82DBIhjnaXN0zv6WkDwKo1pslVPzdWGsDHjPdR0P(V3E71O(D8hs6eeP91XfP3CeohRx6eBw6ex6SkDwrqSkJFrqh8Qzvg)Q7Hprq9WN6LXjeKs974pKqjsqXfbsaeeTmqNAirrqSkJFrqkU31SkJF19WNiOE4t9Y4eccpYamNXVOejO4IJeabrld0PgsueeRY4xe0bVAwLXV6E4teup8PEzCcbbq8HsuIGuCAt8iHeajO4ibqqSkJFrq13B3rq0YaDQHefLibhejacIwgOtnKOii1fjDbJGQu6aGlfJItD5pCdCncIvz8lcsXPU8hokrcIbKaiiAzGo1qIIGuxK0fmccaUum13B3nW1iiwLXViOJhsOejyfrcGGOLb6udjkcsDrsxWiOK70MgqeFP(l6eePTJEZqld0PM0Hv6Qu6aGlfdiIVu)fDcI02rVzGRrqSkJFrqGi(s9x0jisBh9gkrcwbKaiiAzGo1qIIGuxK0fmcQDWrZO40M4rsdq8HGyvg)IGi863MonWVnuIeCQrcGGOLb6udjkcsDrsxWiO2bhnJItBIhjnaXhcIvz8lcs974pK0jis7RJlspkrcoLrcGGOLb6udjkcsDrsxWiO2NMlQnhvoYdIb6K0Hv6upoWRR)ytV0HXzPRIiiwLXViOlQrjsqrosaeeTmqNAirrqQls6cgbPECGxx)XMEPdJZsxfrqSkJFrqf6Ev8WEnqKekrcovqcGGOLb6udjkcsDrsxWiilsxLsx7td346mgjT3MpCDJXzWKjd1WyblDyLUkLowLXVgUX1zmsAVnF46gJZGjtS6spadkLoSsNfPRsPR9PHBCDgJK2BZhUgeXDtgQHXcw6Qwv6AFA4gxNXiP928HRbrC3CeohRx6WO0HbPZQ0vTQ01(0WnUoJrs7T5dx3yCgmz8jRgkDIjDyq6WkDTpnCJRZyK0EB(W1ngNbtMJW5y9sNysxfKoSsx7td346mgjT3MpCDJXzWKjd1WyblDwrqSkJFrqCJRZyK0EB(WrjsqXfbsaeeTmqNAirrqQls6cgb1(0C8qYCu5ipigOtshwPt94aVU(Jn9sNysxfrqSkJFrqhpKqjsqXfhjacIwgOtnKOii1fjDbJGupoWRR)ytV0jM0vbeeRY4xeKh0rnuIseK6)E7TxpsaKGIJeabXQm(fbv)z8lcIwgOtnKOOej4GibqqSkJFrqGi(sn590QieeTmqNAirrjsqmGeabXQm(fbb0)VPlW3aiiAzGo1qIIsKGvejacIvz8lccGopDdJfmcIwgOtnKOOejyfqcGGyvg)IG4tXlPZ)oAteeTmqNAirrjsWPgjacIvz8lcQhGbLE90dCdmoTjcIwgOtnKOOej4ugjacIvz8lcQehb0)VHGOLb6udjkkrckYrcGGyvg)IG4vr(84UwX9ocIwgOtnKOOej4ubjacIwgOtnKOii1fjDbJGaGlfdaXNU8hUbUgbXQm(fbbCHp7XcwxGpuIeuCrGeabrld0PgsueK6IKUGrqwKU2Ng8)3sCKjd1WyblDvRkDSkJrstlHhKx6WO0jU0zv6WkDTpnjOJ9G0aeFMmudJfmcIvz8lckwfFlNXVOejO4IJeabXQm(fbbqNNUHiiAzGo1qIIsKGIpisaeeTmqNAirrqSkJFrqQbu9pVFdLgOZ(ebrLcPs9Y4ecsnGQ)59BO0aD2NOejO4yajacIwgOtnKOii1fjDbJGYhm4ozu)3BV96LoSsNfPldCsNVUfK0jM0XQm(vR(V3E7v6Wu6gu6Qwv6yvgJKMwcpiV0HrPtCPZkcIvz8lcI3aN1Fr3iobHsKGIxrKaiiwLXViiCc)Vb0Fr3Hvrt3oIX9iiAzGo1qIIsKGIxbKaiiwLXViiypPJKW9iiAzGo1qIIsuIGE1VJ)qcjasqXrcGGyvg)IGW)FhgRU8hocIwgOtnKOOej4GibqqSkJFrqQFh)HKobrAFDCr6rq0YaDQHefLOebPu)o(djKaibfhjacIvz8lcsXPU8hocIwgOtnKOOej4GibqqSkJFrqQFh)HKobrAFDCr6rq0YaDQHefLOeb92DBIhjKaibfhjacIwgOtnKOii1fjDbJGQu6aGlfd()7Wy1L)WnW1iiwLXVii8)3HXQl)HJsKGdIeabrld0PgsueK6IKUGrqj3PnnGi(s9x0jisBh9MHwgOtnPdR0vP0baxkgqeFP(l6eePTJEZaxJGyvg)IGar8L6VOtqK2o6nuIeedibqq0YaDQHefbPUiPlyeu7GJM5T72epsAaIpeeRY4xeeHx)20Pb(THsKGvejacIwgOtnKOii1fjDbJGAhC0mVD3M4rsdq8HGyvg)IGu)o(djDcI0(64I0JsKGvajacIwgOtnKOii1fjDbJGSiDvkDTpnCJRZyK0EB(W1ngNbtMmudJfS0Hv6Qu6yvg)A4gxNXiP928HRBmodMmXQl9amOu6WkDwKUkLU2NgUX1zmsAVnF4Aqe3nzOgglyPRAvPR9PHBCDgJK2BZhUgeXDZr4CSEPdJshgKoRsx1Qsx7td346mgjT3MpCDJXzWKXNSAO0jM0HbPdR01(0WnUoJrs7T5dx3yCgmzocNJ1lDIjDvq6WkDTpnCJRZyK0EB(W1ngNbtMmudJfS0zfbXQm(fbXnUoJrs7T5dhLibNAKaiiAzGo1qIIGyvg)IGW)FlXrii1fjDbJGoQCKhed0jPRAvPdaUumG5oRYqPbdZxl41axJGudO6Ko5dmLEKGIJsKGtzKaiiAzGo1qIIGyvg)IG8WBjocbPUiPlye0rLJ8GyGoHGudO6Ko5dmLEKGIJsKGICKaiiAzGo1qIIGuxK0fmcYI0baxkgs1JApP7WlFg4APRAvPdaUumKQh1Es7)oFg4APZkcIvz8lcYN85HpWekrcovqcGGOLb6udjkcsDrsxWiilshP6rTNmXQ7WlFsx1QshP6rTNm(VZNEjrskDwLUQvLolshP6rTNmXQ7WlFshwPdaUum(Kpp8bM0eE9BthoTPUdV8zGRLoRiiwLXViiFYxjocLibfxeibqqSkJFrq2hNGqq0YaDQHefLOeLiOr68XVibhuedkcXfFqmGGS5BJfShbnf4uOPaeuKrWPurwPt6eaejDbE9FP0v(t6MIR(V3E71pfx6osKchh1Ko)JtshdNpoNut6uG4fm5nYjtHJLKoXXGiR0nv)DKUKAshuGpvLo)aBYIePBkQ0LV0nfgMLUwmg(4xP7RPJZ)KolyAv6SiUiXQrororKbV(VKAsN4IlDSkJFLUE4tVrobb5RjfsqXfrfrq13xIoHGMM0nLcZxl4v6MICWrtozAsNG)iHdqN0nyffw6guedkc5e5KPjDtvq8cM8ISYjtt6MELorMv9x9FCss3uLtmNs(FhgR0vFXFrgKx6SefPZtzglyPl8sNcePgsnRg5e5KPjDtXejKcoPM0bqL)iPt94aCkDae4y9gPBkKsr1Px62FNEbXhEbUlDSkJF9s3V9bmYjSkJF9M6JupoaNcnJz992DHJYmaCPyuCQl)HBGRX2o4OzuCAt8iPbi(Ktyvg)6n1hPECaofAgtaIpD5pCHJYCLaWLIbG4tx(d3axJ1sLTdoAgfN2epsAaIVQvbGlfJItD5pCt7TxRyTuz7GJM5T72epsAaIVQvbGlfd()7Wy1L)WnT3ETkNWQm(1BQps94aCk0mMGi(s9x0jisBh9MWrzo5oTPbeXxQ)IobrA7O3m0YaDQH1s7GJMrXPnXJKgG4dlaCPyuCQl)HBGRRwTDWrZ82DBIhjnaXhwa4sXG))omwD5pCdCD1QaWLIb))DyS6YF4g4ASj3PnnaCNxfP5sj2ihWqld0PMv5ewLXVEt9rQhhGtHMX0(4eKWrzgaUum4)VdJvx(d3axJTDWrZ82DBIhjnaXNCICY0KUPyIesbNut6Or6gq6YaNKUeejDSk)t6cV0XJC0zGozKtyvg)6N9dH7Dna7bjNWQm(1l0mMWEshjH7fokZvcaxkM67T7g4A5ewLXVEHMXS(Z4xHJYSflwsUtBAar8L6VOtqK2o6ndTmqNAybGlfdiIVu)fDcI02rVzGRTI1s7GJMrXPnXJKgG4RA12bhnZB3TjEK0aeFwXwjaCPyQV3UBGRTwTQflaWLIbGopDd1aeFg46QvbGlftSk(woJF1GH5Rf8Q)Ig(8VYaxBfRLkBhC0mkoTjEK0aeFyRSDWrZ82DBIhjnaXNvRwLtMM0XQm(1l0mMh8Qzvg)Q7HpfEzCAwXPnXJKWrzUDWrZO40M4rsdq8H1If1)92BVMe0XEqAaIpZr4CSEmkcSQ)7T3En48cUtMJW5y9yueyBFAW)FlXrMJW5y9yCgSQjKimva7XGjXQOiWcaxkMyv8TCg)QbdZxl4v)fn85FLP92lwa4sXaqNNUHAaIpt7TxSaWLIbm3zvgknyy(AbVM2BVwRw1caCPyuCQl)HBGRXslDGhaJdwbRvRA5GxQ8hyY8Ccs)fDcI0uVrNUDWrZqIu4OUMAyReaUumpNG0FrNGin1B0PBhC0mW1yTaaxkgfN6YF4g4AS0sh4bW4GIWQ1QvTCWlv(dmzEobP)IobrAQ3Ot3o4OzirkCuxtnSaWLIbeXxQ)IobrA7O3mhHZX6ftCryfRfa4sXO4ux(d3axJLw6apaghuewRw1I6hPL30mCGl4fR6)E7TxdHx)20Pb(TzocNJ1l2S4yzvgJKMwcpiVydA1QCcRY4xVqZyEWRMvz8RUh(u4LXPzfN2epschL52bhnJItBIhjnaXhwa4sXO4ux(d3axlNmnPJvz8RxOzmp4vZQm(v3dFk8Y408B3TjEKeokZTdoAM3UBt8iPbi(WAXI6)E7Txtc6ypinaXN5iCowpgfbw1)92BVgCEb3jZr4CSEmkcShdMeBqrGfaUumXQ4B5m(10E7flaCPyaOZt3qnaXNP92R1QvTaaxkg8)3HXQl)HBGRX2(04H3sCK5OYrEqmqNSwTQfa4sXG))omwD5pCdCnwa4sXaI4l1FrNGiTD0Bg4ARvRAbaUum4)VdJvx(d3axJ1caCPyivpQ9KUdV8zGRRwfaUumKQh1Es7)oFg4ARyR8GxQ8hyY8Ccs)fDcI0uVrNUDWrZqIu4OUMAwRw1YbVu5pWK55eK(l6eePPEJoD7GJMHePWrDn1WwjaCPyEobP)IobrAQ3Ot3o4OzGRTwTQf1pslVPzdWGsDHjSQ)7T3EnQFh)HKobrAFDCr6nhHZX6fBwCRvRAr9J0YBAgoWf8Iv9FV92RHWRFB60a)2mhHZX6fBwCSSkJrstlHhKxSbTAvoHvz8RxOzmp4vZQm(v3dFk8Y408B3TjEKeokZTdoAM3UBt8iPbi(Wcaxkg8)3HXQl)HBGRLtyvg)6fAgZdE1SkJF19WNcVmon3hqXh)chLzlwo4Lk)bMm9bu8XEDPtuglyn4EGx7jdjsHJ6AQzfRLK70MgaUZRI0CPeBKdyOLb6uZkwlaWLIPpGIp2RlDIYybRb3d8ApzGRTI1caCPy6dO4J96sNOmwWAW9aV2tMJW5y9InpOvRYjSkJF9cnJ5bVAwLXV6E4tHxgNM7dO4JvchLzlwo4Lk)bMm9bu8XEDPtuglyn4EGx7jdjsHJ6AQzfRLK70MMcDCxZLsSroGHwgOtnRyTaaxkM(ak(yVU0jkJfSgCpWR9KbU2kwlaWLIPpGIp2RlDIYybRb3d8ApzocNJ1l28GwTkNWQm(1l0mMh8Qzvg)Q7HpfEzCA(v)o(djHJYSflj3PnnaCNxfP5sj2ihWqld0PMvSwQSDWrZO40M4rsdq8zfRLkBhC0mVD3M4rsdq8zfRf1pslVPzdWGsDHjSQ)7T3EnQFh)HKobrAFDCr6nhHZX6fBwCRwLtyvg)6fAgZdE1SkJF19WNcVmonRu)o(djHJYSflj3Pnnf64UMlLyJCadTmqNAwXAPY2bhnJItBIhjnaXNvSwQSDWrZ82DBIhjnaXNvSwu)iT8MMnadk1fMWQ(V3E71O(D8hs6eeP91XfP3CeohRxSzXTAvoHvz8RxOzmvCVRzvg)Q7HpfEzCAgpYamNXVYjSkJF9cnJ5bVAwLXV6E4tHxgNMbi(KtKtyvg)6naeFZaeF6YF4chL5kbGlfdaXNU8hUbUwoHvz8R3aq8j0mMhps7d71LJ2PBa5ewLXVEdaXNqZyQ(D8hs6eeP91XfPx4Omxz7GJMrXPnXJKgG4dBLTdoAM3UBt8iPbi(Ktyvg)6naeFcnJjaDE6gQbi(eokZwaGlfZXJ0(WED5OD6gWaxxTALQFKwEtZiTjOboRYjSkJF9gaIpHMXmwfFlNXVchLzlaWLI54rAFyVUC0oDdyGRRwTs1pslVPzK2e0aNv5ewLXVEdaXNqZys41VnDAGFBchLzlv2o4OzuCAt8iPbi(Wwz7GJM5T72epsAaIpRvRYQmgjnTeEqEmopOCcRY4xVbG4tOzmb4BOFySchLzlj3PnnahJd0jVHwgOtnRyTaaxkgaIpD5pCdCTv5ewLXVEdaXNqZyYnUoJrs7T5dxyHJYSLkBFA4gxNXiP928HRBmodMmzOgglySvYQm(1WnUoJrs7T5dx3yCgmzIvx6byqjwlv2(0WnUoJrs7T5dxdI4Ujd1WybxTA7td346mgjT3MpCniI7MJW5y9yedwRwT9PHBCDgJK2BZhUUX4myY4twnummGT9PHBCDgJK2BZhUUX4myYCeohRxSkGT9PHBCDgJK2BZhUUX4myYKHAySGTkNWQm(1Bai(eAgt8)3sCKWrz2caCPyaZDwLHsdgMVwWRbUgB7GJM5T72epsAaIpRyzvgJKMwcpiVyZyqoHvz8R3aq8j0mMjOJ9G0aeFcRgq1jDYhyk9ZIlCuMpQCKhed0PQvBFAsqh7bPbi(m(KvdfddvRAP9PjbDShKgG4Z4twnuSkI9GxQ8hyY0Hlfo2cSNAAch4yfzirkCuxtnRvRYQmgjnTeEqEmoxr5ewLXVEdaXNqZy6TJAs4OmdaxkMyv8TCg)QbdZxl4v)fn85FLP92lwa4sXaqNNUHAaIpt7TxSSkJrstlHhKhJZvuoHvz8R3aq8j0mM4mCx4OmdaxkMyv8TCg)AGRXYQmgjnTeEqEXguoHvz8R3aq8j0mM4mCx4OmBbaUumEEKbtA1JdWjVPXNSAigNf3kwlaWLIj)pbP5TPvD22axBflaCPyIvX3Yz8RbUglRYyK00s4b5NhuoHvz8R3aq8j0mM48cUtchLza4sXeRIVLZ4xdCnwwLXiPPLWdYl2mgKtyvg)6naeFcnJj()Bjosy1aQoPt(atPFwCHJY8rLJ8GyGoHLvzmsAAj8G8InJb5ewLXVEdaXNqZyIZWDHJYSflwaGlft(FcsZBtR6STXNSAigNh0A1QwaGlft(FcsZBtR6STbUglaCPyY)tqAEBAvNTnhHZX6ftCtfSwTQfa4sX45rgmPvpoaN8MgFYQHyCgdwTILvzmsAAj8G8IHbRYjSkJF9gaIpHMXmbDShKgG4t4OmZQmgjnTeEqEmkUCcRY4xVbG4tOzmX)FlXrchLzlaWLIbm3zvgknyy(AbVg4ASTdoAgfN2epsAaIpRyzvgJKMwcpiVyZyOAvlaWLIbm3zvgknyy(AbVg4ASv2o4OzuCAt8iPbi(Wwz7GJM5T72epsAaIpRyzvgJKMwcpiVyZyqoHvz8R3aq8j0mM48cUtchLzlwogmj2urewXYQmgjnTeEqEXWG1QvTy5yWKyI8kyflRYyK00s4b5fddytUtBA8pCx)fDcI0L)iFAOLb6uZQCcRY4xVbG4tOzmRH7J0fthjSAavN0jFGP0plUWrzU9PjbDShKgG4Z4twneJdkNWQm(1Bai(eAgZe0XEqAaIp5ewLXVEdaXNqZyIZWDHJYmRYyK00s4b5fddYjSkJF9gaIpHMX0Bh1KgG4toHvz8R3aq8j0mMX9Bb(eokZhdMmnQeQifRIIalaCPyI73c8zocNJ1lMimvqorozAshRY4xVqZyQ4ExZQm(v3dFk8Y40mEKbyoJFLtMM0XQm(1l0mM2rVPvG4dmjNmnPJvz8RxOzmvCVRzvg)Q7HpfEzCAw9FV92RxozAshRY4xVqZyIZWDHJY8XGjtJkHksXgueyzvgJKMwcpiVyvuozAshRY4xVqZyIZWDHJY8XGjtJkHksXgueyjVNwfzu)w6Hk1820(8IczW5PN)WwjaCPy8G4RMwQPvD22BGRLtMM0XQm(1l0mMX9Bb(eokZQ3NZIOAvlhdMWO69jwE6OlsY05bOJAACEjdTmqNAyzvgJKMwcpipgh0QCY0KowLXVEHMXSgUpsxmDKWjFGPuhL52NMe0XEqAaIpJpz1W52NMe0XEqAaIpdols0(Kvd9Yjtt6yvg)6fAgt8)3sCKWjFGPuhL52Ng8)3sCK5OYrEqmqNWYQmgjnTeEqEXguozAshRY4xVqZyMGo2ds4OmBbaUumXQ4B5m(10E7flRYyK00s4b5XO4wRw1caCPyIvX3Yz8RbUglRYyK00s4b5XyfTkNmnPJvz8RxOzm92rnjCuMbGlftSk(woJFnT3EXYQmgjnTeEqEmwr5KPjDSkJF9cnJjoVG7KWrzU9PjbDShKgG4ZKHAySGLtMM0XQm(1l0mM4)VL4iHt(atPokZaWLIbm3zvgknyy(AbVg4ASSkJrstlHhKxSbLtMM0XQm(1l0mMjOJ9GKtMM0nfC07sNDKGKUPK)3sCK0zhjiPBkOpNsejdkNmnPJvz8RxOzmX)FlXrchLzE6OlsYu)20P)IobrA8)xZX7qmkowwLXiPPLWdYplUCY0KowLXVEHMX0Bh1KCICcRY4xVbpYamNXVZX9Bb(eokZXQE8ybRBmodM0vWJX4(TaF6gJZGjDc6ipOV3WcaxkM4(TaFMJW5y9IHHPpi2NKCcRY4xVbpYamNXVcnJ5rlzZDHJYCY7WybJfeX9eKPwLIn1vqoHvz8R3GhzaMZ4xHMXSC0oDb10hbMw64m(v4OmN8omwWybrCpbzQvPytDfKtyvg)6n4rgG5m(vOzm5nWz9x0nItqchL58bdUtMgvO1hJKhliI7jitTkftKlc5ewLXVEdEKbyoJFfAgta(g6hgRWrz2sYDAtdWX4aDYBOLb6uZkwlaWLIbG4tx(d3axBfliI7jitTkfBkxbSXQE8ybRBmodM0vWJrrygSctFqe3tqgCwKiNWQm(1BWJmaZz8RqZy6HVXyK76y9zSQ0lCuMbGlfJh(gJrURJ1NXQsVP92lwa4sXaW3q)WynT3EXcI4EcYuRsXMArGnw1JhlyDJXzWKUcEmkcZGvy6dI4EcYGZIe5e5ewLXVEJ6)E7Tx)C9NXVYjSkJF9g1)92BVEHMXeeXxQjVNwfjNWQm(1Bu)3BV96fAgtG()nDb(gqoHvz8R3O(V3E71l0mMa05PBySGLtyvg)6nQ)7T3E9cnJjFkEjD(3rBkNWQm(1Bu)3BV96fAgZEagu61tpWnW40MYjSkJF9g1)92BVEHMXSehb0)VjNWQm(1Bu)3BV96fAgtEvKppURvCVlNWQm(1Bu)3BV96fAgtGl8zpwW6c8jCuMbGlfdaXNU8hUbUwoHvz8R3O(V3E71l0mMXQ4B5m(v4OmBP9Pb))TehzYqnmwWvRYQmgjnTeEqEmkUvSTpnjOJ9G0aeFMmudJfSCcRY4xVr9FV92RxOzmbOZt3q5ewLXVEJ6)E7TxVqZyc7jDKeUWuPqQuVmonRgq1)8(nuAGo7t5ewLXVEJ6)E7TxVqZyYBGZ6VOBeNGeokZ5dgCNmQ)7T3E9yTKboPZx3csm1)92BVtrhSAvwLXiPPLWdYJrXTkNWQm(1Bu)3BV96fAgtCc)Vb0Fr3Hvrt3oIX9YjSkJF9g1)92BVEHMXe2t6ijCVCICcRY4xVrXPnXJ0C992D5ewLXVEJItBIhjHMXuXPU8hUWrzUsa4sXO4ux(d3axlNWQm(1BuCAt8ij0mMhpKeokZaWLIP(E7UbUwoHvz8R3O40M4rsOzmbr8L6VOtqK2o6nHJYCYDAtdiIVu)fDcI02rVzOLb6udBLaWLIbeXxQ)IobrA7O3mW1YjSkJF9gfN2epscnJjHx)20Pb(TjCuMBhC0mkoTjEK0aeFYjSkJF9gfN2epscnJP63XFiPtqK2xhxKEHJYC7GJMrXPnXJKgG4toHvz8R3O40M4rsOzmVOw4Om3(0CrT5OYrEqmqNWQECGxx)XMEmoxr5ewLXVEJItBIhjHMXSq3RIh2RbIKeokZQhh411FSPhJZvuoHvz8R3O40M4rsOzm5gxNXiP928HlCuMTuz7td346mgjT3MpCDJXzWKjd1WybJTswLXVgUX1zmsAVnF46gJZGjtS6spadkXAPY2NgUX1zmsAVnF4Aqe3nzOggl4QvBFA4gxNXiP928HRbrC3CeohRhJyWA1QTpnCJRZyK0EB(W1ngNbtgFYQHIHbSTpnCJRZyK0EB(W1ngNbtMJW5y9IvbSTpnCJRZyK0EB(W1ngNbtMmudJfSv5ewLXVEJItBIhjHMX84HKWrzU9P54HK5OYrEqmqNWQECGxx)XMEXQOCcRY4xVrXPnXJKqZy6bDut4OmRECGxx)XMEXQGCICcRY4xVrP(D8hsZko1L)WLtyvg)6nk1VJ)qsOzmv)o(djDcI0(64I0lNiNWQm(1B6dO4JvZko1L)WLtKtyvg)6n9bu8X)m()7Wy1L)WLtKtyvg)6nV63XFinJ))omwD5pC5ewLXVEZR(D8hscnJP63XFiPtqK2xhxKE5e5ewLXVEZB3TjEKMX)FhgRU8hUWrzUsa4sXG))omwD5pCdCTCcRY4xV5T72epscnJjiIVu)fDcI02rVjCuMtUtBAar8L6VOtqK2o6ndTmqNAyReaUumGi(s9x0jisBh9MbUwoHvz8R382DBIhjHMXKWRFB60a)2eokZTdoAM3UBt8iPbi(Ktyvg)6nVD3M4rsOzmv)o(djDcI0(64I0lCuMBhC0mVD3M4rsdq8jNWQm(1BE7UnXJKqZyYnUoJrs7T5dx4OmBPY2NgUX1zmsAVnF46gJZGjtgQHXcgBLSkJFnCJRZyK0EB(W1ngNbtMy1LEaguI1sLTpnCJRZyK0EB(W1GiUBYqnmwWvR2(0WnUoJrs7T5dxdI4U5iCowpgXG1QvBFA4gxNXiP928HRBmodMm(KvdfddyBFA4gxNXiP928HRBmodMmhHZX6fRcyBFA4gxNXiP928HRBmodMmzOgglyRYjSkJF9M3UBt8ij0mM4)VL4iHvdO6Ko5dmL(zXfokZhvoYdIb6u1QaWLIbm3zvgknyy(AbVg4A5ewLXVEZB3TjEKeAgtp8wIJewnGQt6KpWu6Nfx4OmFu5ipigOtYjSkJF9M3UBt8ij0mM(Kpp8bMeokZwaGlfdP6rTN0D4LpdCD1QaWLIHu9O2tA)35ZaxBvoHvz8R382DBIhjHMX0N8vIJeokZwivpQ9KjwDhE5RAvs1JApz8FNp9sIK0A1QwivpQ9KjwDhE5dlaCPy8jFE4dmPj863MoCAtDhE5ZaxBvoHvz8R382DBIhjHMX0(4eekrjcb]] )

end