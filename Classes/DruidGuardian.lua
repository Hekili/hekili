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

    spec:RegisterPack( "Guardian", 20201123, [[dOKeqbqiPqpsPQCjPGK2eu8jPGunkkXPOKwLsvv9kIuZIi5wkvvPDrXVGsnmIIogrvltkPNbLyAkvX1ikSnLQuFtkOACsbQZPuLyDsbsZJOY9uk7dkPdkfezHeLEOsvstukiXfLcszJsbH6JsbLoPuGyLsPMPuqu3ukOyNerdvkiKLkfe4PGmvIWxLccAVq(lPgSGdJAXQYJjzYcDzKnlPpRQA0QkNMQvRuvfVwPYSLQBdv7wXVbgUsCCPaA5Q8CjMUORdQTRK(oLA8sb48sjwVsvL5lfTFcJKhjbckYjHKSvz2QmLx(wXIrEzi)EqqzllecAHv74FcbnmoHGAyH5l68GGw4w6aoIKabvaWNIqqFzUuAqXg7Fp)GFgfah7IJd350bJ64AIDXXvyJGEWEpBqg0dbf5Kqs2QmBvMYlFRyXiVmKhlyrgiigo)ahccYX3RiOppgPb9qqrQOqq7teAyH5l68icnuoypkAVprqsWkH)OteAflsjcTkZwLPOTO9(eH96hp)uPbv0EFIW(Ri0GmkWTaoojryVYj2nmaWSZhry5CW5PtfrWIxfHcLPp)IGxeb1hP2rrRgeu3lzbjbcQ3IIpgGKajP8ijqqSkDWGGWbGzNp6k4Wrq0WVofrYIsuIGEeFijqskpsceen8RtrKSii15jDoJGAueEW1Q5r8PRGd3aVGGyv6Gbb9i(0vWHJsKKTIKabXQ0bdc64vAaWfD9Oz)Abbrd)6uejlkrsIfKeiiA4xNIizrqQZt6Cgb1OiepypAuCAt8kPFeFIagrOrriEWE0aS72eVs6hXhcIvPdgeKcmRGDKo)iDzXpplOej5EqsGGOHFDkIKfbPopPZzeKfr4bxRMJxPbax01JM9Rfd8Ii0SPi0OiOaR0WtAwPj)A5ebRiiwLoyqqp6k0TdLijLbsceen8RtrKSii15jDoJGSicp4A1C8kna4IUE0SFTyGxeHMnfHgfbfyLgEsZkn5xlNiyfbXQ0bdcYhfFdNoyqjsY9gjbcIg(1PisweK68KoNrqweHgfH4b7rJItBIxj9J4teWicnkcXd2JgGD3M4vs)i(ebRIqZMIaRsFL00q4ovebSUjcTIGyv6Gbbr4laB60pWerjsYgosceen8RtrKSii15jDoJGSicj3PjnVJXFDQyOHFDkkcwfbmIGfr4bxRMhXNUcoCd8IiyfbXQ0bdc6X3UYoFqjsYgmsceen8RtrKSii15jDoJGSicnkcrqA4iVK(kPl28HRJmo)tM0v785xeWicnkcSkDWy4iVK(kPl28HRJmo)tgF01U))LIagrWIi0OiebPHJ8s6RKUyZhU(J4UjD1oF(fHMnfHiinCKxsFL0fB(W1Fe3nhHZ(uebSkcyreSkcnBkcrqA4iVK(kPl28HRJmo)tMsYQDIGCIawebmIqeKgoYlPVs6InF46iJZ)K5iC2NIiiNiidraJiebPHJ8s6RKUyZhUoY48pzsxTZNFrWkcIvPdgeeh5L0xjDXMpCuIKCVGKabrd)6uejlcsDEsNZiilIWdUwn)CNvPR0)W8fDEmWlIagriEWE0aS72eVs6hXNiyveWicSk9vstdH7ureKBteWccIvPdgeeoamv)iuIKuEzIKabrd)6uejlcsDEsNZiOJQhv(4xNeHMnfHiin53XLp9J4ZuswTteKteWIi0SPiyreIG0KFhx(0pIptjz1orqorypIagr4GhQcUFY0HRv2NkCHIAc)DSImude2xwOOiyveA2ueyv6RKMgc3PIiG1nrypiiwLoyqq53XLp9J4dbPAr1jDY3pLfKKYJsKKYlpsceen8RtrKSii15jDoJGEW1QXhfFdNoy0)W8fDE0GQg(kaLjcShraJi8GRvZJUcD70pIpteypIagrGvPVsAAiCNkIaw3eH9GGyv6GbbvS9fs)i(qjss5BfjbcIg(1PisweK68KoNrqp4A14JIVHthmg4fraJiWQ0xjnneUtfrqorOveeRshmiiCgUJsKKYJfKeiiA4xNIizrqQZt6CgbzreEW1QPWR8pPva8hN8KMsYQDIaw3eb5fbRIagrWIi8GRvtca5NMNOw1zBd8IiyveWicp4A14JIVHthmg4fraJiWQ0xjnneUtfryteAfbXQ0bdccNH7OejP87bjbcIg(1PisweK68KoNrqp4A14JIVHthmg4fraJiWQ0xjnneUtfrqUnraliiwLoyqq4883juIKuEzGKabrd)6uejlcsDEsNZiOJQhv(4xNebmIaRsFL00q4oveb52ebSGGyv6GbbHdat1pcbPAr1jDY3pLfKKYJsKKYV3ijqq0WVofrYIGuNN05mcYIiyreSicp4A1Kaq(P5jQvD22uswTteW6Mi0QiyveA2ueSicp4A1Kaq(P5jQvD22aVicyeHhCTAsai)08e1QoBBocN9PicYjcYBKHiyveA2ueSicp4A1u4v(N0ka(JtEstjz1oraRBIawebRIGvraJiWQ0xjnneUtfrqoralIGveeRshmiiCgUJsKKY3WrsGGOHFDkIKfbPopPZzeeRsFL00q4ovebSkcYJGyv6GbbLFhx(0pIpuIKu(gmsceen8RtrKSii15jDoJGSicp4A18ZDwLUs)dZx05XaVicyeH4b7rJItBIxj9J4teSkcyebwL(kPPHWDQicYTjcyreA2ueSicp4A18ZDwLUs)dZx05XaVicyeHgfH4b7rJItBIxj9J4teWicnkcXd2JgGD3M4vs)i(ebRIagrGvPVsAAiCNkIGCBIawqqSkDWGGWbGP6hHsKKYVxqsGGOHFDkIKfbPopPZzeKfrWIiC8pjcYjc7fzkcwfbmIaRsFL00q4oveb5ebSicwfHMnfblIGfr44FseKteAWYqeSkcyebwL(kPPHWDQicYjcyreWicj3PjnfaCxdQ68J0vWrL0qd)6uueSIGyv6GbbHZZFNqjsYwLjsceen8RtrKSii15jDoJGIG0KFhx(0pIptjz1oraRIqRiiwLoyqqlW9v689JqqQwuDsN89tzbjP8OejzRYJKabXQ0bdck)oU8PFeFiiA4xNIizrjsYwBfjbcIg(1PisweK68KoNrqSk9vstdH7ureKteWccIvPdgeeod3rjsYwXcsceeRshmiOITVq6hXhcIg(1PiswuIKS19GKabrd)6uejlcsDEsNZiOJ)jtKQUYtrqorypYueWicp4A14hyQWN5iC2NIiiNiitJmqqSkDWGG8dmv4dLOebH7P)ZPdgKeijLhjbcIg(1PisweK68KoNrq(Oa4(8RJmo)tAzuebSkc(bMk8PJmo)t687OYhOhfbmIWdUwn(bMk8zocN9PicYjcyre2)IWhxscbXQ0bdcYpWuHpuIKSvKeiiA4xNIizrqQZt6CgbL8SZNFraJi8rCp)mlQueKte2BzGGyv6GbbD0q2ChLijXcsceen8RtrKSii15jDoJGsE25ZViGre(iUNFMfvkcYjc7TmqqSkDWGGQhn7Ntr9r)0qhNoyqjsY9GKabrd)6uejlcsDEsNZiOe8)3jtKQ0u8vQicyeHpI75NzrLIGCIqdwMiiwLoyqq844Sgu1rIZpuIKugijqq0WVofrYIGuNN05mcYIiKCNM08og)1PIHg(1POiyveWicweHhCTAEeF6k4WnWlIGvraJi8rCp)mlQueKteA4YqeWic(Oa4(8RJmo)tAzuebSkcY00QmeH9Vi8rCp)m4CdabXQ0bdc6X3UYoFqjsY9gjbcIg(1PisweK68KoNrqp4A1uGVvFL7AFkPpQSyIa7reWicp4A184BxzNpMiWEebmIWhX98ZSOsrqoryVLPiGre8rbW95xhzC(N0YOicyveKPPvzic7Fr4J4E(zW5gacIvPdgeub(w9vUR9PK(OYckrjcA5ifa)XjscKKYJKabrd)6uejlcsDEsNZiilIq8G9OrXPnXRK(r8jcwfHMnfblIGcSsdpPz8)VuxzseWicj3Pjnv64UMRvF8Sfdn8RtrrWkcIvPdgeKItDfC4OejzRijqq0WVofrYIGuNN05mckEWE0O40M4vs)i(qqSkDWGGwoGDhLijXcsceen8RtrKSii15jDoJGSicXd2JgGD3M4vs)i(ebRIqZMIGfrqbwPHN0m()xQRmjcyeHK70KMh35rrAUw9XZwm0WVoffbRiiwLoyqq4aWSZhDfC4Oej5EqsGGOHFDkIKfbPopPZzeKfrWIi0OiepypAa2DBIxj9J4teWicnkcXd2JgfN2eVs6hXNiyveWicweHgfbfyLgEsZ4)FPUYKiyveSkcnBkcweblIqJIq8G9Oby3TjEL0pIpraJi0OiepypAuCAt8kPFeFIGvraJiyreuGvA4jnJ))L6ktIagri5onP5OscooDWO5A1hpBXqd)6uueSkcwrqSkDWGGEeF6k4WrjsszGKabrd)6uejlcsDEsNZiOK70KMpIVudQ68J02EpAOHFDkkcyeblIq8G9OrXPnXRK(r8jcyeHhCTAuCQRGd3aVicnBkcXd2JgGD3M4vs)i(ebmIWdUwn4aWSZhDfC4g4frOztr4bxRgCay25JUcoCd8IiGresUttAECNhfP5A1hpBXqd)6uueSIGyv6Gbb9r8LAqvNFK227ruIKCVrsGGOHFDkIKfbPopPZzeu8G9Oby3TjEL0pIpeeRshmii7JZpuIseuVffFScjbss5rsGGyv6GbbP4uxbhocIg(1PiswuIseuKQmCprsGKuEKeiiwLoyqqLDW9U(XLpeen8RtrKSOejzRijqq0WVofrYIGuNN05mcQrr4bxRMLdy3nWliiwLoyqqWfs7jHxqjssSGKabrd)6uejlcsDEsNZiilIGfrWIiKCNM08r8LAqvNFK227rdn8RtrraJi8GRvZhXxQbvD(rABVhnWlIGvraJiyreIhShnkoTjEL0pIprOztriEWE0aS72eVs6hXNiyveWicnkcp4A1SCa7UbEreSkcnBkcweblIWdUwnp6k0Tt)i(mWlIqZMIWdUwn(O4B40bJ(hMVOZJgu1WxbOmWlIGvraJiyreAueIhShnkoTjEL0pIpraJi0OiepypAa2DBIxj9J4teSkcwfbRiiwLoyqqlG0bdkrsUhKeiiA4xNIizrqSkDWGGo4rZQ0bJU7LebPopPZzeu8G9OrXPnXRK(r8jcyeHhCTAuCQRGd3aVGG6Ej1dJtiifN2eVsOejPmqsGGOHFDkIKfbXQ0bdc6GhnRshm6UxseK68KoNrqXd2JgGD3M4vs)i(ebmIWdUwn4aWSZhDfC4g4feu3lPEyCcbbS72eVsOej5EJKabrd)6uejlcIvPdge0bpAwLoy0DVKii15jDoJGSicweHdEOk4(jtVffFCrx7eL(8R)7o(sHmude2xwOOiyveWicweHK70KMh35rrAUw9XZwm0WVoffbRIagrWIi8GRvtVffFCrx7eL(8R)7o(sHmWlIGvraJiyreEW1QP3IIpUORDIsF(1)DhFPqMJWzFkIGCBIqRIGvrWkcQ7LupmoHG6TO4JbOejzdhjbcIg(1PisweeRshmiOdE0SkDWO7EjrqQZt6CgbzreSich8qvW9tMElk(4IU2jk95x)3D8LczOgiSVSqrrWQiGreSicj3Pjnv64UMRvF8Sfdn8RtrrWQiGreSicp4A10BrXhx01orPp)6)UJVuid8IiyveWicweHhCTA6TO4Jl6ANO0NF9F3XxkK5iC2NIii3Mi0QiyveSIG6Ej1dJtiOElk(yfkrs2GrsGGOHFDkIKfbXQ0bdc6GhnRshm6UxseK68KoNrqweblIqYDAsZJ78OinxR(4zlgA4xNIIGvraJiyreAueIhShnkoTjEL0pIprWQiGreSicnkcXd2JgGD3M4vs)i(ebRIagrWIiOaR0WtAg))l1vMebmIGca6rG9yuGzfSJ05hPll(5zXCeo7treKBteKxeSkcwrqDVK6HXjeeqbMvWocLij3lijqq0WVofrYIGyv6GbbDWJMvPdgD3ljcsDEsNZiilIGfri5onPPsh31CT6JNTyOHFDkkcwfbmIGfrOrriEWE0O40M4vs)i(ebRIagrWIi0OiepypAa2DBIxj9J4teSkcyeblIGcSsdpPz8)VuxzseWickaOhb2JrbMvWosNFKUS4NNfZr4SpfrqUnrqErWQiyfb19sQhgNqqkfywb7iuIKuEzIKabrd)6uejlcIvPdgeKI7DnRshm6Uxseu3lPEyCcbH7P)ZPdguIKuE5rsGGOHFDkIKfbXQ0bdc6GhnRshm6Uxseu3lPEyCcb9i(qjkrqkoTjELqsGKuEKeiiwLoyqqlhWUJGOHFDkIKfLijBfjbcIg(1PisweK68KoNrqnkcp4A1O4uxbhUbEbbXQ0bdcsXPUcoCuIKelijqq0WVofrYIGuNN05mc6bxRMLdy3nWliiwLoyqqhVJqjsY9GKabrd)6uejlcsDEsNZiOK70KMpIVudQ68J02EpAOHFDkkcyeHgfHhCTA(i(snOQZpsB79ObEbbXQ0bdc6J4l1GQo)iTT3JOejPmqsGGOHFDkIKfbPopPZzeu8G9OrXPnXRK(r8HGyv6Gbbr4laB60pWerjsY9gjbcIg(1PisweK68KoNrqXd2JgfN2eVs6hXhcIvPdgeKcmRGDKo)iDzXpplOejzdhjbcIg(1PisweK68KoNrqrqAoFXCu9OYh)6KiGreua8hqVa8jlIaw3eH9GGyv6GbbD(ckrs2GrsGGOHFDkIKfbPopPZzeKcG)a6fGpzreW6MiSheeRshmiOkDaLdGl6NNekrsUxqsGGOHFDkIKfbPopPZzeKfrOrricsdh5L0xjDXMpCDKX5FYKUANp)IagrOrrGvPdgdh5L0xjDXMpCDKX5FY4JU29)VueWicweHgfHiinCKxsFL0fB(W1Fe3nPR25ZVi0SPiebPHJ8s6RKUyZhU(J4U5iC2NIiGvralIGvrOztricsdh5L0xjDXMpCDKX5FYuswTteKteWIiGreIG0WrEj9vsxS5dxhzC(NmhHZ(ueb5ebzicyeHiinCKxsFL0fB(W1rgN)jt6QD(8lcwrqSkDWGG4iVK(kPl28HJsKKYltKeiiA4xNIizrqQZt6CgbfbP54DK5O6rLp(1jraJiOa4pGEb4tweb5eH9GGyv6GbbD8ocLijLxEKeiiA4xNIizrqQZt6CgbPa4pGEb4tweb5ebzGGyv6Gbbv(okIsuIGuaqpcSNcscKKYJKabXQ0bdcAbKoyqq0WVofrYIsKKTIKabXQ0bdc6J4l1uPqJIqq0WVofrYIsKKybjbcIvPdge0RdarDf(Abbrd)6uejlkrsUhKeiiwLoyqqp6k0TZNFeen8RtrKSOejPmqsGGyv6GbbXNIhsNG7Ojrq0WVofrYIsKK7nsceeRshmiOU))Lf9(dC8hNMebrd)6uejlkrs2WrsGGyv6Gbbv9JEDaiIGOHFDkIKfLijBWijqqSkDWGG4rrL84UwX9ocIg(1PiswuIKCVGKabrd)6uejlcsDEsNZiOhCTAEeF6k4WnWliiwLoyqqVZlz3NFDf(qjss5Ljsceen8RtrKSii15jDoJGSicrqAWbGP6hzsxTZNFrOztrGvPVsAAiCNkIawfb5fbRIagricst(DC5t)i(mPR25ZpcIvPdgeKpk(goDWGsKKYlpsceeRshmiOhDf62HGOHFDkIKfLijLVvKeiiA4xNIizrqSkDWGGuTO6G8aJR0VoxseevRKk1dJtiivlQoipW4k9RZLeLijLhlijqq0WVofrYIGuNN05mckb))DYOaGEeypfraJiyreshN0jqhDseKteyv6GrRaGEeypIa2IqRIqZMIaRsFL00q4ovebSkcYlcwrqSkDWGG4XXznOQJeNFOejP87bjbcIvPdgeeoHdUw0GQUdR8OoEeJxqq0WVofrYIsKKYldKeiiwLoyqqWfs7jHxqq0WVofrYIsuIGakWSc2rijqskpsceeRshmiiCay25JUcoCeen8RtrKSOeLiiLcmRGDescKKYJKabXQ0bdcsXPUcoCeen8RtrKSOeLiiGD3M4vcjbss5rsGGOHFDkIKfbPopPZzeuJIWdUwn4aWSZhDfC4g4feeRshmiiCay25JUcoCuIKSvKeiiA4xNIizrqQZt6CgbLCNM08r8LAqvNFK227rdn8RtrraJi0Oi8GRvZhXxQbvD(rABVhnWliiwLoyqqFeFPgu15hPT9EeLijXcsceen8RtrKSii15jDoJGIhShna7UnXRK(r8HGyv6Gbbr4laB60pWerjsY9GKabrd)6uejlcsDEsNZiO4b7rdWUBt8kPFeFiiwLoyqqkWSc2r68J0Lf)8SGsKKYajbcIg(1PisweK68KoNrqweHgfHiinCKxsFL0fB(W1rgN)jt6QD(8lcyeHgfbwLoymCKxsFL0fB(W1rgN)jJp6A3))sraJiyreAueIG0WrEj9vsxS5dx)rC3KUANp)IqZMIqeKgoYlPVs6InF46pI7MJWzFkIawfbSicwfHMnfHiinCKxsFL0fB(W1rgN)jtjz1orqoralIagricsdh5L0xjDXMpCDKX5FYCeo7treKteKHiGreIG0WrEj9vsxS5dxhzC(NmPR25ZViyfbXQ0bdcIJ8s6RKUyZhokrsU3ijqq0WVofrYIGuNN05mc6O6rLp(1jrOztr4bxRMFUZQ0v6Fy(Iopg4feeRshmiiCayQ(riivlQoPt((PSGKuEuIKSHJKabrd)6uejlcsDEsNZiOJQhv(4xNqqSkDWGGkWt1pcbPAr1jDY3pLfKKYJsKKnyKeiiA4xNIizrqQZt6CgbzreEW1QHuDFPq6o8WNbEreA2ueEW1QHuDFPq6cOZNbEreSIGyv6Gbbvs(kW3pHsKK7fKeiiA4xNIizrqQZt6Cgbzreiv3xkKXhDhE4teA2ueiv3xkKPa68PhQbKIGvrOztrWIiqQUVuiJp6o8WNiGreEW1QPK8vGVFst4laB6WPj1D4Hpd8IiyfbXQ0bdcQK8v9Jqjss5LjsceeRshmii7JZpeen8RtrKSOeLOebTsxXbdsYwLzRYuE5LFpiiB(gF(liOgcBi1qGKnis2W2GkcIGeFKi44lGlfHk4eHg6kaOhb2tPHUiCude2pkkcfaojcmCcW5KIIG6JNFQyeTBi7djcYJLguryVcMv6skkcqo(EvekTmj3aeHgQIqceHgYWSie9vV4Greal0Xj4eblyBveSiFdWQr0w0UbbFbCjffb5Lxeyv6Gre6EjlgrBeuzHuijLxM7bbTCGQ3je0(eHgwy(IopIqdLd2JI27teKeSs4p6eHwXIuIqRYSvzkAlAVpryV(XZpvAqfT3NiS)kcniJcClGJtse2RCIDddam78rewohCE6ureS4vrOqz6ZVi4frq9rQDu0Qr0w0EFIqdTgaPGtkkcpQcoseua8hNIWJ(9PyeHgskfTKfryaZ(7hF4v4UiWQ0btreatVfJOnRshmfZYrka(JZnfN6k4WLYRBwIhShnkoTjEL0pIpRnBArbwPHN0m()xQRmHj5onPPsh31CT6JNTyOHFDkAv0MvPdMIz5ifa)XP0ByVCa7UuEDlEWE0O40M4vs)i(eTzv6GPywosbWFCk9g24aWSZhDfC4s51nlXd2JgGD3M4vs)i(S2SPffyLgEsZ4)FPUYeMK70KMh35rrAUw9XZwm0WVofTkAZQ0btXSCKcG)4u6nSFeF6k4WLYRBwS0y8G9Oby3TjEL0pIpmngpypAuCAt8kPFeFwXyPrfyLgEsZ4)FPUYKvRnBAXsJXd2JgGD3M4vs)i(W0y8G9OrXPnXRK(r8zfJffyLgEsZ4)FPUYeMK70KMJkj440bJMRvF8Sfdn8RtrRwfTzv6GPywosbWFCk9g2FeFPgu15hPT9EukVULCNM08r8LAqvNFK227rdn8RtrmwIhShnkoTjEL0pIpmp4A1O4uxbhUbEPzZ4b7rdWUBt8kPFeFyEW1QbhaMD(ORGd3aV0S5dUwn4aWSZhDfC4g4fmj3PjnpUZJI0CT6JNTyOHFDkAv0MvPdMIz5ifa)XP0ByBFC(jLx3IhShna7UnXRK(r8jAlAVprOHwdGuWjffbALUweH0Xjri)irGvj4ebVic8k7D(1jJOnRshmLTYo4Ex)4YNOnRshmfP3WgUqApj8IuEDRXhCTAwoGD3aViAZQ0btr6nSxaPdgP86MflwsUttA(i(snOQZpsB79OHg(1PiMhCTA(i(snOQZpsB79ObEXkglXd2JgfN2eVs6hXxZMXd2JgGD3M4vs)i(SIPXhCTAwoGD3aVyTztlwEW1Q5rxHUD6hXNbEPzZhCTA8rX3WPdg9pmFrNhnOQHVcqzGxSIXsJXd2JgfN2eVs6hXhMgJhShna7UnXRK(r8z1Qvr79jcSkDWuKEd7dE0SkDWO7EjLAyCAtXPnXRKuEDlEWE0O40M4vs)i(WyXIca6rG9yYVJlF6hXN5iC2NcwLjgfa0Ja7XGZZFNmhHZ(uWQmXebPbhaMQFK5iC2Ncw3(vrPLPrgyo(NKBpYeZdUwn(O4B40bJ(hMVOZJgu1WxbOmrG9G5bxRMhDf62PFeFMiWEW8GRvZp3zv6k9pmFrNhteypwB20YdUwnko1vWHBGxWqdD)TG1wLH1MnTCWdvb3pzaC(PbvD(rAQhPthpypAOgiSVSqrmn(GRvdGZpnOQZpst9iD64b7rd8cglp4A1O4uxbhUbEbdn093cwBvMwT2SPLdEOk4(jdGZpnOQZpst9iD64b7rd1aH9LfkI5bxRMpIVudQ68J02EpAocN9PiN8Y0kglp4A1O4uxbhUbEbdn093cwBvMwB20IcSsdpPzxlNZdgfa0Ja7Xq4laB60pWenhHZ(uKBtEmSk9vstdH7urUwTAv0MvPdMI0ByFWJMvPdgD3lPudJtBkoTjELKYRBXd2JgfN2eVs6hXhMhCTAuCQRGd3aViAVprGvPdMI0ByFWJMvPdgD3lPudJtBa7UnXRKuEDlEWE0aS72eVs6hXhglwuaqpcSht(DC5t)i(mhHZ(uWQmXOaGEeypgCE(7K5iC2NcwLjMJ)j5AvMyEW1QXhfFdNoymrG9G5bxRMhDf62PFeFMiWES2SPLhCTAWbGzNp6k4WnWlyIG0uGNQFK5O6rLp(1jRnBA5bxRgCay25JUcoCd8cMhCTA(i(snOQZpsB79ObEXAZMwEW1QbhaMD(ORGd3aVGXYdUwnKQ7lfs3Hh(mWlnB(GRvdP6(sH0fqNpd8IvmnEWdvb3pzaC(PbvD(rAQhPthpypAOgiSVSqrRnBA5GhQcUFYa48tdQ68J0upsNoEWE0qnqyFzHIyA8bxRgaNFAqvNFKM6r60Xd2Jg4fRnBArbwPHN0m()xQRmHrba9iWEmkWSc2r68J0Lf)8SyocN9Pi3M8wB20IcSsdpPzxlNZdgfa0Ja7Xq4laB60pWenhHZ(uKBtEmSk9vstdH7urUwTAv0MvPdMI0ByFWJMvPdgD3lPudJtBa7UnXRKuEDlEWE0aS72eVs6hXhMhCTAWbGzNp6k4WnWlI2SkDWuKEd7dE0SkDWO7EjLAyCAR3IIpgiLx3Sy5GhQcUFY0BrXhx01orPp)6)UJVuid1aH9LfkAfJLK70KMh35rrAUw9XZwm0WVofTIXYdUwn9wu8XfDTtu6ZV(V74lfYaVyfJLhCTA6TO4Jl6ANO0NF9F3XxkK5iC2NICBTA1QOnRshmfP3W(GhnRshm6UxsPggN26TO4Jvs51nlwo4HQG7Nm9wu8XfDTtu6ZV(V74lfYqnqyFzHIwXyj5onPPsh31CT6JNTyOHFDkAfJLhCTA6TO4Jl6ANO0NF9F3XxkKbEXkglp4A10BrXhx01orPp)6)UJVuiZr4Spf52A1QvrBwLoyksVH9bpAwLoy0DVKsnmoTbuGzfSJKYRBwSKCNM084opksZ1QpE2IHg(1POvmwAmEWE0O40M4vs)i(SIXsJXd2JgGD3M4vs)i(SIXIcSsdpPz8)VuxzcJca6rG9yuGzfSJ05hPll(5zXCeo7trUn5TAv0MvPdMI0ByFWJMvPdgD3lPudJtBkfywb7iP86Mflj3Pjnv64UMRvF8Sfdn8RtrRyS0y8G9OrXPnXRK(r8zfJLgJhShna7UnXRK(r8zfJffyLgEsZ4)FPUYegfa0Ja7XOaZkyhPZpsxw8ZZI5iC2NICBYB1QOnRshmfP3WwX9UMvPdgD3lPudJtB4E6)C6Gr0MvPdMI0ByFWJMvPdgD3lPudJtBpIprBrBwLoykMhX32J4txbhUuEDRXhCTAEeF6k4WnWlI2SkDWumpIpP3W(4vAaWfD9Oz)Ar0MvPdMI5r8j9g2kWSc2r68J0Lf)8SiLx3AmEWE0O40M4vs)i(W0y8G9Oby3TjEL0pIprBwLoykMhXN0By)ORq3o9J4tkVUz5bxRMJxPbax01JM9Rfd8sZMnQaR0WtAwPj)A5SkAZQ0btX8i(KEdBFu8nC6GrkVUz5bxRMJxPbax01JM9Rfd8sZMnQaR0WtAwPj)A5SkAZQ0btX8i(KEdBcFbytN(bMOuEDZsJXd2JgfN2eVs6hXhMgJhShna7UnXRK(r8zTztwL(kPPHWDQG1TwfTzv6GPyEeFsVH9JVDLD(iLx3SKCNM08og)1PIHg(1POvmwEW1Q5r8PRGd3aVyv0MvPdMI5r8j9g2CKxsFL0fB(WLskVUzPXiinCKxsFL0fB(W1rgN)jt6QD(8JPrwLoymCKxsFL0fB(W1rgN)jJp6A3))smwAmcsdh5L0xjDXMpC9hXDt6QD(83SzeKgoYlPVs6InF46pI7MJWzFkyflwB2mcsdh5L0xjDXMpCDKX5FYuswTtoSGjcsdh5L0xjDXMpCDKX5FYCeo7trozGjcsdh5L0xjDXMpCDKX5FYKUANp)wfTzv6GPyEeFsVHnoamv)iP86MLhCTA(5oRsxP)H5l68yGxWepypAa2DBIxj9J4ZkgwL(kPPHWDQi3gweTzv6GPyEeFsVHD(DC5t)i(Ks1IQt6KVFklBYlLx3oQEu5JFDQzZiin53XLp9J4ZuswTtoS0SPLiin53XLp9J4ZuswTtU9G5GhQcUFY0HRv2NkCHIAc)DSImude2xwOO1Mnzv6RKMgc3Pcw32JOnRshmfZJ4t6nSl2(cjLx3EW1QXhfFdNoy0)W8fDE0GQg(kaLjcShmp4A18ORq3o9J4Zeb2dgwL(kPPHWDQG1T9iAZQ0btX8i(KEdBCgUlLx3EW1QXhfFdNoymWlyyv6RKMgc3PICTkAZQ0btX8i(KEdBCgUlLx3S8GRvtHx5FsRa4po5jnLKv7W6M8wXy5bxRMeaYpnprTQZ2g4fRyEW1QXhfFdNoymWlyyv6RKMgc3PYwRI2SkDWumpIpP3WgNN)ojLx3EW1QXhfFdNoymWlyyv6RKMgc3PICByr0MvPdMI5r8j9g24aWu9JKs1IQt6KVFklBYlLx3oQEu5JFDcdRsFL00q4ovKBdlI2SkDWumpIpP3WgNH7s51nlwS8GRvtca5NMNOw1zBtjz1oSU1Q1MnT8GRvtca5NMNOw1zBd8cMhCTAsai)08e1QoBBocN9PiN8gzyTztlp4A1u4v(N0ka(JtEstjz1oSUHfRwXWQ0xjnneUtf5WIvrBwLoykMhXN0ByNFhx(0pIpP86gRsFL00q4ovWQ8I2SkDWumpIpP3WghaMQFKuEDZYdUwn)CNvPR0)W8fDEmWlyIhShnkoTjEL0pIpRyyv6RKMgc3PICByPztlp4A18ZDwLUs)dZx05XaVGPX4b7rJItBIxj9J4dtJXd2JgGD3M4vs)i(SIHvPVsAAiCNkYTHfrBwLoykMhXN0ByJZZFNKYRBwSC8pj3ErMwXWQ0xjnneUtf5WI1MnTy54FsUgSmSIHvPVsAAiCNkYHfmj3PjnfaCxdQ68J0vWrL0qd)6u0QOnRshmfZJ4t6nSxG7R057hjLQfvN0jF)uw2KxkVUfbPj)oU8PFeFMsYQDyTvrBwLoykMhXN0ByNFhx(0pIprBwLoykMhXN0ByJZWDP86gRsFL00q4ovKdlI2SkDWumpIpP3WUy7lK(r8jAZQ0btX8i(KEdB)atf(KYRBh)tMivDLNYThzI5bxRg)atf(mhHZ(uKtMgziAlAVprGvPdMI0ByR4ExZQ0bJU7LuQHXPnCp9FoDWiAVprGvPdMI0ByB79Ow9X3pjAVprGvPdMI0ByR4ExZQ0bJU7LuQHXPnfa0Ja7PiAVprGvPdMI0ByJZWDP862X)Kjsvx5PCTktmSk9vstdH7urU9iAVprGvPdMI0ByJZWDP862X)Kjsvx5PCTktmuPqJImkWu7Uk18e1L88kzW59hWHPXhCTAkF8Tqdf1QoBxmWlI27teyv6GPi9g2(bMk8jLx3uGsUjZMnTC8pHvfOKy49JopjtNBHokQX5Hm0WVofXWQ0xjnneUtfS2Qvr79jcSkDWuKEd7f4(kD((rsL89tP2RBrqAYVJlF6hXNPKSA3weKM874YN(r8zW5gGUKSAxr0EFIaRshmfP3WghaMQFKujF)uQ96weKgCayQ(rMJQhv(4xNWWQ0xjnneUtf5Av0EFIaRshmfP3Wo)oU8jLx3S8GRvJpk(goDWyIa7bdRsFL00q4ovWQ8wB20YdUwn(O4B40bJbEbdRsFL00q4ovW6ESkAVprGvPdMI0ByxS9fskVU9GRvJpk(goDWyIa7bdRsFL00q4ovW6EeT3NiWQ0btr6nSX55Vts51Tiin53XLp9J4ZKUANp)I27teyv6GPi9g24aWu9JKk57NsTx3EW1Q5N7SkDL(hMVOZJbEbdRsFL00q4ovKRvr79jcSkDWuKEd7874YNO9(eHgI9ExeS98teAyaGP6hjc2E(jcnebYgMgqRI27teyv6GPi9g24aWu9JKYRB8(rNNKzbytNgu15hPXbGXC8SdRYJHvPVsAAiCNkBYlAVprGvPdMI0ByxS9fs0w0MvPdMIb3t)NthmB(bMk8jLx38rbW95xhzC(N0YOGv)atf(0rgN)jD(Du5d0JyEW1QXpWuHpZr4Spf5WY()JljjAZQ0btXG7P)ZPdgP3W(OHS5UuEDl5zNp)y(iUNFMfvk3EldrBwLoykgCp9FoDWi9g21JM9ZPO(OFAOJthms51TKND(8J5J4E(zwuPC7TmeTzv6GPyW90)50bJ0ByZJJZAqvhjo)KYRBj4)VtMivPP4RubZhX98ZSOs5AWYu0MvPdMIb3t)NthmsVH9JVDLD(iLx3SKCNM08og)1PIHg(1POvmwEW1Q5r8PRGd3aVyfZhX98ZSOs5A4YaJpkaUp)6iJZ)KwgfSkttRYy))rCp)m4Cdq0MvPdMIb3t)NthmsVHDb(w9vUR9PK(OYIuED7bxRMc8T6RCx7tj9rLfteypyEW1Q5X3UYoFmrG9G5J4E(zwuPC7TmX4JcG7ZVoY48pPLrbRY00Qm2)Fe3Zpdo3aeTfTzv6GPyuaqpcSNY2ciDWiAZQ0btXOaGEeypfP3W(J4l1uPqJIeTzv6GPyuaqpcSNI0By)6aquxHVweTzv6GPyuaqpcSNI0By)ORq3oF(fTzv6GPyuaqpcSNI0ByZNIhsNG7OjfTzv6GPyuaqpcSNI0By39)VSO3FGJ)40KI2SkDWumkaOhb2tr6nSR(rVoaefTzv6GPyuaqpcSNI0ByZJIk5XDTI7DrBwLoykgfa0Ja7Pi9g2VZlz3NFDf(KYRBp4A18i(0vWHBGxeTzv6GPyuaqpcSNI0By7JIVHthms51nlrqAWbGP6hzsxTZN)Mnzv6RKMgc3PcwL3kMiin53XLp9J4ZKUANp)I2SkDWumkaOhb2tr6nSF0vOBNOnRshmfJca6rG9uKEdB4cP9KWLIQvsL6HXPnvlQoipW4k9RZLu0MvPdMIrba9iWEksVHnpooRbvDK48tkVULG))ozuaqpcSNcglPJt6eOJojNca6rG90qT1Mnzv6RKMgc3PcwL3QOnRshmfJca6rG9uKEdBCchCTObvDhw5rD8igViAZQ0btXOaGEeypfP3WgUqApj8IOTOnRshmfJItBIxPTLdy3fTzv6GPyuCAt8kj9g2ko1vWHlLx3A8bxRgfN6k4WnWlI2SkDWumkoTjELKEd7J3rs51ThCTAwoGD3aViAZQ0btXO40M4vs6nS)i(snOQZpsB79OuEDl5onP5J4l1GQo)iTT3JgA4xNIyA8bxRMpIVudQ68J02EpAGxeTzv6GPyuCAt8kj9g2e(cWMo9dmrP86w8G9OrXPnXRK(r8jAZQ0btXO40M4vs6nSvGzfSJ05hPll(5zrkVUfpypAuCAt8kPFeFI2SkDWumkoTjELKEd7ZxKYRBrqAoFXCu9OYh)6egfa)b0laFYcw32JOnRshmfJItBIxjP3WUshq5a4I(5jjLx3ua8hqVa8jlyDBpI2SkDWumkoTjELKEdBoYlPVs6InF4s51nlngbPHJ8s6RKUyZhUoY48pzsxTZNFmnYQ0bJHJ8s6RKUyZhUoY48pz8rx7()xIXsJrqA4iVK(kPl28HR)iUBsxTZN)MnJG0WrEj9vsxS5dx)rC3Ceo7tbRyXAZMrqA4iVK(kPl28HRJmo)tMsYQDYHfmrqA4iVK(kPl28HRJmo)tMJWzFkYjdmrqA4iVK(kPl28HRJmo)tM0v7853QOnRshmfJItBIxjP3W(4DKuEDlcsZX7iZr1JkF8Rtyua8hqVa8jlYThrBwLoykgfN2eVssVHD57OOuEDtbWFa9cWNSiNmeTfTzv6GPyukWSc2rBko1vWHlAlAZQ0btX0BrXhR2uCQRGdx0w0MvPdMIP3IIpgSHdaZoF0vWHlAlAZQ0btXauGzfSJ2WbGzNp6k4WfTfTzv6GPya2DBIxPnCay25JUcoCP86wJp4A1GdaZoF0vWHBGxeTzv6GPya2DBIxjP3W(J4l1GQo)iTT3Js51TK70KMpIVudQ68J02EpAOHFDkIPXhCTA(i(snOQZpsB79ObEr0MvPdMIby3TjELKEdBcFbytN(bMOuEDlEWE0aS72eVs6hXNOnRshmfdWUBt8kj9g2kWSc2r68J0Lf)8SiLx3IhShna7UnXRK(r8jAZQ0btXaS72eVssVHnh5L0xjDXMpCP86MLgJG0WrEj9vsxS5dxhzC(NmPR25ZpMgzv6GXWrEj9vsxS5dxhzC(Nm(ORD))lXyPXiinCKxsFL0fB(W1Fe3nPR25ZFZMrqA4iVK(kPl28HR)iUBocN9PGvSyTzZiinCKxsFL0fB(W1rgN)jtjz1o5WcMiinCKxsFL0fB(W1rgN)jZr4Spf5KbMiinCKxsFL0fB(W1rgN)jt6QD(8Bv0MvPdMIby3TjELKEdBCayQ(rsPAr1jDY3pLLn5LYRBhvpQ8XVo1S5dUwn)CNvPR0)W8fDEmWlI2SkDWuma7UnXRK0ByxGNQFKuQwuDsN89tzztEP862r1JkF8RtI2SkDWuma7UnXRK0Byxs(kW3pjLx3S8GRvdP6(sH0D4Hpd8sZMp4A1qQUVuiDb05ZaVyv0MvPdMIby3TjELKEd7sYx1pskVUzHuDFPqgF0D4HVMnjv3xkKPa68PhQbKwB20cP6(sHm(O7WdFyEW1QPK8vGVFst4laB6WPj1D4Hpd8IvrBwLoykgGD3M4vs6nSTpo)qjkria]] )

end