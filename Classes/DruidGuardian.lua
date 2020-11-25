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

    spec:RegisterPack( "Guardian", 20201124.1, [[dOupobqiPqpsrkxskOOnbfFskOuJIs5uuQwfHi6veKzrqDlcrODrXVGsggbQJrOAzkOEgHW0uK4Asb2MIu13KcIXPiPoNIKyDeIQMhHY9uu7Ja5GsbPSqcPhQijnrPGcxukOKnkfKuFukOQtsiQSsfXmLcs1nLcQStcyOsbjzPsbj8uqMkuQVkfKO9c5VKAWcomQfd0JjAYsCzKnlPpdOrdWPPA1eIGxRaZwQUnuTBL(TkdxkDCcrz5Q65cnDrxhuBxH(oLmEcr68kiRxrQmFPO9tYiXryJGkCsibgwWdlyXfF4gye8up8upLHrq5qTecQLLdyGecAzCcb1WdZFX5fb1Yd1pUGWgbfp4xsiiaz2gf5XclGEcag0ipCSIooCNt)w5Z1eROJlXcbbc79uKBrGiOcNesGHf8WcwCXhUbgbp1dp1trCeedNaUhbb54tveeaVuOfbIGkuuIGMMk0WdZFX5vfAy8WErnzAQGa3iHdsVkm8uewfgwWdly1e1KPPctva8cKII8QjttfejQcICR8(275KuHPkNy1WD3oWxvO99790POkyZRQqKY0xGQGhvbjasoGk2niOUhZicBeuFij)8HWgjG4iSrqSm9Brq43Td8vxVhhbrld2PcsuuIseeiXpcBKaIJWgbrld2PcsueK89KENrqnQcGW1QbK4xxVh3a3IGyz63IGaj(117XrjsGHryJGyz63IGEEK2doQRpTt3qiiAzWovqIIsKaIaHncIwgStfKOii57j9oJGAufkpSxmsoTiEK0Ge)QagvOrvO8WEXCwDlIhjniXpcILPFlcsE74nG0jashB93Zikrcmfe2iiAzWovqIIGKVN07mcYMkacxRMNhP9GJ66t70nKbUvfA2ufAufK3iT8MMrAtad9QGDeelt)weei9r6hGsKanaHncIwgStfKOii57j9oJGSPcGW1Q55rAp4OU(0oDdzGBvHMnvHgvb5nslVPzK2eWqVkyhbXY0Vfb5RK)Lt)wuIey6ryJGOLb7ubjkcs(EsVZiiBQqJQq5sdx420hjD0IFCDHXzGKjD5aFbQcyuHgvbwM(TgUWTPps6Of)46cJZajJV6A3bcivbmQGnvOrvOCPHlCB6JKoAXpUgaXDt6Yb(cufA2ufkxA4c3M(iPJw8JRbqC38eo7BufeKkicvWUk0SPkuU0WfUn9rshT4hxxyCgizIjlhOcIPcIqfWOcLlnCHBtFK0rl(X1fgNbsMNWzFJQGyQqdubmQq5sdx420hjD0IFCDHXzGKjD5aFbQc2rqSm9BrqCHBtFK0rl(XrjsGgccBeeTmyNkirrqY3t6DgbztfaHRvdqUZY0LAGW8xCEnWTQagvO8WEXCwDlIhjniXVkyxfWOcSm9rstlH7uufeBwfebcILPFlcc)UT6pHsKatncBeeTmyNkirrqSm9BrqjGNJa0Ge)ii57j9oJGEQ(uead2jvOztvOCPjb8CeGgK43etwoqfetfeHk0SPkytfkxAsaphbObj(nXKLdubXuHPOcyuHhEP69ajthUwzFRWrQOjCWNLKHezWEBlvub7QqZMQaltFK00s4ofvbbnRctbbjhs2jDYpqkJibehLibMkiSrq0YGDQGefbjFpP3zeeiCTA8vY)YPFRgim)fNx9v1WF8KMYzTQagvaeUwnG0hPFGgK43uoRvfWOcSm9rstlH7uufe0Skmfeelt)weu0YBjniXpkrciUGryJGOLb7ubjkcs(EsVZiiq4A14RK)Lt)wdCRkGrfyz6JKMwc3POkiMkmmcILPFlccNH7OejG4IJWgbrld2PcsueK89KENrq2ubq4A1e5rgiPLhoiN8MMyYYbQGGMvbXvb7QagvWMkacxRM8UeGM3Iw2zldCRkyxfWOcGW1QXxj)lN(Tg4wvaJkWY0hjnTeUtrvywfggbXY0VfbHZWDuIeq8HryJGOLb7ubjkcs(EsVZiiq4A14RK)Lt)wdCRkGrfyz6JKMwc3POki2Skiceelt)weeoVa7ekrciUiqyJGOLb7ubjkcILPFlcc)UT6pHGKVN07mc6P6tramyNubmQaltFK00s4ofvbXMvbrGGKdj7Ko5hiLrKaIJsKaIpfe2iiAzWovqIIGKVN07mcYMkytfSPcGW1QjVlbO5TOLD2Yetwoqfe0SkmSkyxfA2ufSPcGW1QjVlbO5TOLD2Ya3Qcyubq4A1K3La08w0YoBzEcN9nQcIPcIBAGkyxfA2ufSPcGW1QjYJmqslpCqo5nnXKLdubbnRcIqfSRc2vbmQaltFK00s4ofvbXubrOc2rqSm9Brq4mChLibeVbiSrq0YGDQGefbjFpP3zeeltFK00s4ofvbbPcIJGyz63IGsaphbObj(rjsaXNEe2iiAzWovqIIGKVN07mcYMkacxRgGCNLPl1aH5V48AGBvbmQq5H9IrYPfXJKgK4xfSRcyubwM(iPPLWDkQcInRcIqfA2ufSPcGW1Qbi3zz6snqy(loVg4wvaJk0OkuEyVyKCAr8iPbj(vbmQqJQq5H9I5S6wepsAqIFvWUkGrfyz6JKMwc3POki2Skiceelt)wee(DB1FcLibeVHGWgbrld2PcsueK89KENrq2ubBQWZajvqmvyQiyvWUkGrfyz6JKMwc3POkiMkicvWUk0SPkytfSPcpdKubXuHPUbQGDvaJkWY0hjnTeUtrvqmvqeQagvi5oTPjEWD9v1jasxVNIPHwgStfvWocILPFlccNxGDcLibeFQryJGOLb7ubjkcILPFlcQfUpsVpDecs(EsVZiOYLMeWZraAqIFtmz5avqqQWWii5qYoPt(bszejG4OejG4tfe2iiwM(TiOeWZraAqIFeeTmyNkirrjsGHfmcBeeTmyNkirrqY3t6DgbXY0hjnTeUtrvqmvqeiiwM(TiiCgUJsKadlocBeelt)weu0YBjniXpcIwgStfKOOejWWdJWgbrld2PcsueK89KENrqpdKmfQ6spvbXuHPiyvaJkacxRg)VTc)MNWzFJQGyQGGnnabXY0Vfb5)Tv4hLOebH7PdKt)we2ibehHncIwgStfKOii57j9oJG8vE4(cuxyCgiPBqufeKk4)Tv4xxyCgiPtapfbC9IkGrfaHRvJ)3wHFZt4SVrvqmvqeQGiPkaGJjHGyz63IG8)2k8JsKadJWgbrld2PcsueK89KENrqjVd8fOkGrfaqCpbyALPkiMkm9nabXY0Vfb90swChLibebcBeeTmyNkirrqY3t6DgbL8oWxGQagvaaX9eGPvMQGyQW03aeelt)weu9PD6CQOFciT0ZPFlkrcmfe2iiAzWovqIIGKVN07mckpGa7KPqvAJ(ifvbmQaaI7jatRmvbXuHPwWiiwM(TiiEDCwFvDH4eakrc0ae2iiAzWovqIIGKVN07mcYMk0OkuEyVyKCAr8iPbj(vbmQqJQq5H9I5S6wepsAqIFvWUk0SPkWY0hjnTeUtrvqqZQWWiiwM(TiicV9SOxdEBbLibMEe2iiAzWovqIIGKVN07mcYMkKCN20a(moyNIgAzWovub7QagvWMkacxRgqIFD9ECdCRkyxfWOcjVd8fOkGrfaqCpbyALPkiMk0qAGkGrf8vE4(cuxyCgiPBqufeKkiyJ4QGiPkaG4EcWGZIueelt)weei)dId8fLibAiiSrq0YGDQGefbjFpP3zeeiCTAIW)OpYDTVX0xzgnLZAvbmQaiCTAa5FqCGVMYzTQagvaaX9eGPvMQGyQW0lyvaJk4R8W9fOUW4mqs3GOkiivqWMHBGkisQcaiUNam4SifbXY0VfbfH)rFK7AFJPVYmIsuIGKCAr8iHWgjG4iSrqSm9BrqT)z1rq0YGDQGefLibggHncIwgStfKOii57j9oJGAufaHRvJKtD9ECdClcILPFlcsYPUEpokrcice2iiAzWovqIIGKVN07mcceUwnT)z1nWTiiwM(TiONhqOejWuqyJGOLb7ubjkcs(EsVZiOK70Mgae)P(Q6eaPT8EXqld2PIkGrfAufaHRvdaI)uFvDcG0wEVyGBrqSm9Brqai(t9v1jasB59ckrc0ae2iiAzWovqIIGKVN07mcQ8WEXi50I4rsds8JGyz63IGi82ZIEn4TfuIey6ryJGOLb7ubjkcs(EsVZiOYd7fJKtlIhjniXpcILPFlcsE74nG0jashB93Zikrc0qqyJGOLb7ubjkcs(EsVZiOYLM3BnpvFkcGb7KkGrfKho4PBpFZOkiOzvykiiwM(TiO3BrjsGPgHncIwgStfKOii57j9oJGKho4PBpFZOkiOzvykiiwM(TiOk9N0p4Og0tcLibMkiSrq0YGDQGefbjFpP3zeKnvOrvOCPHlCB6JKoAXpUUW4mqYKUCGVavbmQqJQalt)wdx420hjD0IFCDHXzGKXxDT7abKQagvWMk0OkuU0WfUn9rshT4hxdG4UjD5aFbQcnBQcLlnCHBtFK0rl(X1aiUBEcN9nQccsfeHkyxfA2ufkxA4c3M(iPJw8JRlmodKmXKLdubXubrOcyuHYLgUWTPps6Of)46cJZajZt4SVrvqmvObQagvOCPHlCB6JKoAXpUUW4mqYKUCGVavb7iiwM(TiiUWTPps6Of)4OejG4cgHncIwgStfKOii57j9oJGkxAEEazEQ(uead2jvaJkipCWt3E(MrvqmvykiiwM(TiONhqOejG4IJWgbrld2PcsueK89KENrqYdh80TNVzufetfAacILPFlckc4PckrjcQpKKFwIWgjG4iSrqSm9Brqso117Xrq0YGDQGefLOebvOkd3te2ibehHncILPFlckoaU31GCeacIwgStfKOOejWWiSrq0YGDQGefbjFpP3zeuJQaiCTAA)ZQBGBrqSm9BrqWrs7jHhrjsarGWgbrld2PcsueK89KENrq2ubBQGnvi5oTPbaXFQVQobqAlVxm0YGDQOcyubq4A1aG4p1xvNaiTL3lg4wvWUkGrfSPcLh2lgjNwepsAqIFvOztvO8WEXCwDlIhjniXVkyxfWOcnQcGW1QP9pRUbUvfSRcnBQc2ubBQaiCTAaPps)aniXVbUvfA2ufaHRvJVs(xo9B1aH5V48QVQg(JN0a3Qc2vbmQGnvOrvO8WEXi50I4rsds8RcyuHgvHYd7fZz1TiEK0Ge)QGDvWUkyhbXY0Vfb1EPFlkrcmfe2iiAzWovqIIGKVN07mcQ8WEXi50I4rsds8Rcyubq4A1i5uxVh3a3IGyz63IGE4vZY0Vv39yIG6Em1lJtiijNwepsOejqdqyJGOLb7ubjkcs(EsVZiOYd7fZz1TiEK0Ge)QagvaeUwn43Td8vxVh3a3IGyz63IGE4vZY0Vv39yIG6Em1lJtiOZQBr8iHsKatpcBeeTmyNkirrqY3t6DgbztfSPcp8s17bsM(qs(5OU2jk9fOgy3XBJKHezWEBlvub7QagvWMkKCN20aYDELKMRvF9CidTmyNkQGDvaJkytfaHRvtFij)Cux7eL(cudS74TrYa3Qc2vbmQGnvaeUwn9HK8ZrDTtu6lqnWUJ3gjZt4SVrvqSzvyyvWUkyhbXY0Vfb9WRMLPFRU7Xeb19yQxgNqq9HK8Zhkrc0qqyJGOLb7ubjkcs(EsVZiiBQGnv4HxQEpqY0hsYph11orPVa1a7oEBKmKid2BBPIkyxfWOc2uHK70MMk9CxZ1QVEoKHwgStfvWUkGrfSPcGW1QPpKKFoQRDIsFbQb2D82izGBvb7QagvWMkacxRM(qs(5OU2jk9fOgy3XBJK5jC23Oki2SkmSkyxfSJGyz63IGE4vZY0Vv39yIG6Em1lJtiO(qs(zjkrcm1iSrq0YGDQGefbjFpP3zeKnvWMkKCN20aYDELKMRvF9CidTmyNkQGDvaJkytfAufkpSxmsoTiEK0Ge)QGDvaJkytfAufkpSxmNv3I4rsds8Rc2vbmQGnvqEJ0YBAwhiGuxzsfWOcY76LZAnYBhVbKobq6yR)EgnpHZ(gvbXMvbXvb7QGDeelt)we0dVAwM(T6Uhteu3JPEzCcbDYBhVbekrcmvqyJGOLb7ubjkcs(EsVZiiBQGnvi5oTPPsp31CT6RNdzOLb7urfSRcyubBQqJQq5H9IrYPfXJKgK4xfSRcyubBQqJQq5H9I5S6wepsAqIFvWUkGrfSPcYBKwEtZ6abK6ktQagvqExVCwRrE74nG0jashB93ZO5jC23Oki2SkiUkyxfSJGyz63IGE4vZY0Vv39yIG6Em1lJtiiP82XBaHsKaIlye2iiAzWovqIIGyz63IGKCVRzz63Q7EmrqDpM6LXjeeUNoqo9BrjsaXfhHncIwgStfKOiiwM(TiOhE1Sm9B1DpMiOUht9Y4eccK4hLOeb1(K8Wb5eHnsaXryJGyz63IGg4B5PIo26VNreeTmyNkirrjsGHryJGOLb7ubjkcs(EsVZiiq4A1i5uxVh3a3QcyuHYd7fJKtlIhjniXpcILPFlcQ9pRokrcice2iiAzWovqIIGKVN07mcQrvaeUwnGe)6694g4wvaJkytfAufkpSxmsoTiEK0Ge)QqZMQaiCTAKCQR3JBkN1Qc2vbmQGnvOrvO8WEXCwDlIhjniXVk0SPkacxRg872b(QR3JBkN1Qc2rqSm9BrqGe)6694OejWuqyJGOLb7ubjkcs(EsVZiOK70Mgae)P(Q6eaPT8EXqld2PIkGrfSPcLh2lgjNwepsAqIFvaJkacxRgjN6694g4wvOztvO8WEXCwDlIhjniXVkGrfaHRvd(D7aF117XnWTQqZMQaiCTAWVBh4RUEpUbUvfWOcj3PnnGCNxjP5A1xphYqld2PIkyhbXY0VfbbG4p1xvNaiTL3lOejqdqyJGOLb7ubjkcs(EsVZiiq4A1GF3oWxD9ECdCRkGrfkpSxmNv3I4rsds8JGyz63IGSEobGsuIGK31lN1gryJeqCe2iiwM(TiO2l9Brq0YGDQGefLibggHncILPFlccaXFQPyKwjHGOLb7ubjkkrcice2iiwM(TiiW(DfDf(hcbrld2PcsuuIeykiSrqSm9BrqG0hPFGVarq0YGDQGefLibAacBeelt)wee)sEjDE)tBIGOLb7ubjkkrcm9iSrqSm9BrqDhiGmQfjaxaItBIGOLb7ubjkkrc0qqyJGyz63IGQ(tG97kiiAzWovqIIsKatncBeelt)weeVskMp31sU3rq0YGDQGefLibMkiSrq0YGDQGefbjFpP3zeeiCTAaj(117XnWTiiwM(TiiW3Jz3xG6k8JsKaIlye2iiAzWovqIIGKVN07mcYMkuU0GF3w9NmPlh4lqvOztvGLPpsAAjCNIQGGubXvb7QagvOCPjb8CeGgK43KUCGVarqSm9Brq(k5F50VfLibexCe2iiwM(Tiiq6J0pabrld2PcsuuIeq8HryJGOLb7ubjkcILPFlcsoKSF5FRl1GDoMiiQwjzQxgNqqYHK9l)BDPgSZXeLibexeiSrq0YGDQGefbjFpP3zeuEab2jJ8UE5S2OkGrfSPcPJt680fNubXubwM(TA5D9YzTQawQWWQqZMQaltFK00s4ofvbbPcIRc2rqSm9Brq864S(Q6cXjauIeq8PGWgbXY0VfbHt43pK(Q6oS0l6YtmEebrld2PcsuuIeq8gGWgbXY0VfbbhjTNeEebrld2PcsuuIse0jVD8gqiSrciocBeelt)wee(D7aF117Xrq0YGDQGefLibggHncILPFlcsE74nG0jashB93ZicIwgStfKOOeLiiP82XBaHWgjG4iSrqSm9Brqso117Xrq0YGDQGefLibggHncILPFlcsE74nG0jashB93ZicIwgStfKOOeLiOZQBr8iHWgjG4iSrq0YGDQGefbjFpP3zeuJQaiCTAWVBh4RUEpUbUfbXY0VfbHF3oWxD9ECuIeyye2iiAzWovqIIGKVN07mck5oTPbaXFQVQobqAlVxm0YGDQOcyuHgvbq4A1aG4p1xvNaiTL3lg4weelt)weeaI)uFvDcG0wEVGsKaIaHncIwgStfKOii57j9oJGkpSxmNv3I4rsds8JGyz63IGi82ZIEn4TfuIeykiSrq0YGDQGefbjFpP3zeu5H9I5S6wepsAqIFeelt)weK82XBaPtaKo26VNruIeObiSrq0YGDQGefbjFpP3zeKnvOrvOCPHlCB6JKoAXpUUW4mqYKUCGVavbmQqJQalt)wdx420hjD0IFCDHXzGKXxDT7abKQagvWMk0OkuU0WfUn9rshT4hxdG4UjD5aFbQcnBQcLlnCHBtFK0rl(X1aiUBEcN9nQccsfeHkyxfA2ufkxA4c3M(iPJw8JRlmodKmXKLdubXubrOcyuHYLgUWTPps6Of)46cJZajZt4SVrvqmvObQagvOCPHlCB6JKoAXpUUW4mqYKUCGVavb7iiwM(TiiUWTPps6Of)4OejW0JWgbrld2Pcsueelt)wee(DB1FcbjFpP3ze0t1NIayWoPcnBQcGW1Qbi3zz6snqy(loVg4weKCizN0j)aPmIeqCuIeOHGWgbrld2Pcsueelt)weueER(tii57j9oJGEQ(uead2jeKCizN0j)aPmIeqCuIeyQryJGOLb7ubjkcs(EsVZiiBQaiCTAiz3BJKUdV8BGBvHMnvbq4A1qYU3gjD868BGBvb7iiwM(TiOyYFe(bsOejWubHncIwgStfKOii57j9oJGSPcKS7TrY4RUdV8RcnBQcKS7TrYeVo)6LePPkyxfA2ufSPcKS7TrY4RUdV8Rcyubq4A1et(JWpqst4TNf940M6o8YVbUvfSJGyz63IGIj)v)juIeqCbJWgbXY0Vfbz9Ccabrld2PcsuuIsuIGgPp63IeyybpSGfx8HNccYI)1xGreudLn0AOqarobA4f5vbvaBaKk44T3NQq9EvOHT8UE5S2ydBv4jrgS)urfIhoPcmCE4CsfvqcGxGu0OM0q3xsfexeI8QWu92r6tQOcqo(uvfIdTjlsvHgMQqEQqdDywfk(Oh9BvHRLEoVxfSHLDvWM4Iu7g1e1ero827tQOcIlUkWY0Vvf6EmJg1eeu7FvVtiOPPcn8W8xCEvHggpSxutMMkiWns4G0RcdpfHvHHf8WcwnrnzAQWufaVaPOiVAY0ubrIQGi3kVV9EojvyQYjwnC3Td8vfAF)EpDkQc28QkePm9fOk4rvqcGKdOIDJAIAY0uHgwIuscNurfaP69KkipCqovbqcOVrJk0qtkP2mQc7TIebWpEfURcSm9BJQWT9HmQjSm9BJM2NKhoiNcnJ1aFlpv0Xw)9mQMWY0VnAAFsE4GCk0mwT)z1f2RZGW1QrYPUEpUbUft5H9IrYPfXJKgK4xnHLPFB00(K8Wb5uOzSaj(117Xf2RZnccxRgqIFD9ECdClgBnwEyVyKCAr8iPbj(B2eeUwnso117XnLZATJXwJLh2lMZQBr8iPbj(B2eeUwn43Td8vxVh3uoR1UAclt)2OP9j5HdYPqZybG4p1xvNaiTL3lc715K70Mgae)P(Q6eaPT8EXqld2PcgBLh2lgjNwepsAqIFmGW1QrYPUEpUbUTzZYd7fZz1TiEK0Ge)yaHRvd(D7aF117XnWTnBccxRg872b(QR3JBGBXKCN20aYDELKMRvF9CidTmyNk2vtyz63gnTpjpCqofAglRNtac71zq4A1GF3oWxD9ECdClMYd7fZz1TiEK0Ge)QjQjttfAyjsjjCsfvGgPFiviDCsfsaKkWY8EvWJQapYENb7KrnHLPFBCooaU31GCeGAclt)2OqZybhjTNeEuyVo3iiCTAA)ZQBGBvtyz63gfAgR2l9Bf2RZ2Szl5oTPbaXFQVQobqAlVxm0YGDQGbeUwnai(t9v1jasB59IbU1ogBLh2lgjNwepsAqI)MnlpSxmNv3I4rsds8BhtJGW1QP9pRUbU1EZM2SbcxRgq6J0pqds8BGBB2eeUwn(k5F50VvdeM)IZR(QA4pEsdCRDm2AS8WEXi50I4rsds8JPXYd7fZz1TiEK0Ge)2TBxnzAQalt)2OqZy9WRMLPFRU7Xu4LXPzjNwepsc715Yd7fJKtlIhjniXpgB2K31lN1AsaphbObj(npHZ(gfKGXiVRxoR1GZlWozEcN9nkibJPCPb)UT6pzEcN9nkOzGYIqc20ampdKeBkcgdiCTA8vY)YPFRgim)fNx9v1WF8KMYzTyaHRvdi9r6hObj(nLZAXacxRgGCNLPl1aH5V48AkN1AVztBGW1QrYPUEpUbUfdT0dCibnCdS3SPThEP69ajZXja9v1jast9c96Yd7fdjYG92wQGPrq4A1CCcqFvDcG0uVqVU8WEXa3IXgiCTAKCQR3JBGBXql9ahsqdly72B202dVu9EGK54eG(Q6eaPPEHED5H9IHezWEBlvWacxRgae)P(Q6eaPT8EX8eo7BumXfSDm2aHRvJKtD9ECdClgAPh4qcAybBVztBYBKwEtZGHENxmY76LZAneE7zrVg82I5jC23OyZIJHLPpsAAjCNIInSD7QjSm9BJcnJ1dVAwM(T6UhtHxgNMLCAr8ijSxNlpSxmsoTiEK0Ge)yaHRvJKtD9ECdCRAY0ubwM(TrHMX6Hxnlt)wD3JPWlJtZNv3I4rsyVoxEyVyoRUfXJKgK4hJnBY76LZAnjGNJa0Ge)MNWzFJcsWyK31lN1AW5fyNmpHZ(gfKGX8mqsSHfmgq4A14RK)Lt)wt5SwmGW1QbK(i9d0Ge)MYzT2B20giCTAWVBh4RUEpUbUft5steER(tMNQpfbWGDYEZM2aHRvd(D7aF117XnWTyaHRvdaI)uFvDcG0wEVyGBT3SPnq4A1GF3oWxD9ECdClgBGW1QHKDVns6o8YVbUTztq4A1qYU3gjD868BGBTJPXhEP69ajZXja9v1jast9c96Yd7fdjYG92wQyVztBp8s17bsMJta6RQtaKM6f61Lh2lgsKb7TTubtJGW1Q54eG(Q6eaPPEHED5H9IbU1EZM2K3iT8MM1bci1vMWiVRxoR1iVD8gq6eaPJT(7z08eo7BuSzXT3SPn5nslVPzWqVZlg5D9YzTgcV9SOxdEBX8eo7BuSzXXWY0hjnTeUtrXg2UD1ewM(TrHMX6Hxnlt)wD3JPWlJtZNv3I4rsyVoxEyVyoRUfXJKgK4hdiCTAWVBh4RUEpUbUvnHLPFBuOzSE4vZY0Vv39yk8Y40CFij)8jSxNTz7HxQEpqY0hsYph11orPVa1a7oEBKmKid2BBPIDm2sUtBAa5oVssZ1QVEoKHwgStf7ySbcxRM(qs(5OU2jk9fOgy3XBJKbU1ogBGW1QPpKKFoQRDIsFbQb2D82izEcN9nk28W2TRMWY0Vnk0mwp8Qzz63Q7EmfEzCAUpKKFwkSxNTz7HxQEpqY0hsYph11orPVa1a7oEBKmKid2BBPIDm2sUtBAQ0ZDnxR(65qgAzWovSJXgiCTA6dj5NJ6ANO0xGAGDhVnsg4w7ySbcxRM(qs(5OU2jk9fOgy3XBJK5jC23OyZdB3UAclt)2OqZy9WRMLPFRU7Xu4LXP5tE74nGe2RZ2SLCN20aYDELKMRvF9CidTmyNk2XyRXYd7fJKtlIhjniXVDm2AS8WEXCwDlIhjniXVDm2K3iT8MM1bci1vMWiVRxoR1iVD8gq6eaPJT(7z08eo7BuSzXTBxnHLPFBuOzSE4vZY0Vv39yk8Y40SuE74nGe2RZ2SLCN20uPN7AUw91ZHm0YGDQyhJTglpSxmsoTiEK0Ge)2XyRXYd7fZz1TiEK0Ge)2XytEJ0YBAwhiGuxzcJ8UE5SwJ82XBaPtaKo26VNrZt4SVrXMf3UD1ewM(TrHMXsY9UMLPFRU7Xu4LXPzCpDGC63QMWY0Vnk0mwp8Qzz63Q7EmfEzCAgK4xnrnHLPFB0as8pds8RR3JlSxNBeeUwnGe)6694g4w1ewM(TrdiXVqZy98iThCuxFANUHutyz63gnGe)cnJL82XBaPtaKo26VNrH96CJLh2lgjNwepsAqIFmnwEyVyoRUfXJKgK4xnHLPFB0as8l0mwG0hPFGgK4xyVoBdeUwnpps7bh11N2PBidCBZMnkVrA5nnJ0Mag6TRMWY0VnAaj(fAglFL8VC63kSxNTbcxRMNhP9GJ66t70nKbUTzZgL3iT8MMrAtad92vtyz63gnGe)cnJfx420hjD0IFCHf2RZ2ASCPHlCB6JKoAXpUUW4mqYKUCGVaX0ilt)wdx420hjD0IFCDHXzGKXxDT7abKyS1y5sdx420hjD0IFCnaI7M0Ld8fyZMLlnCHBtFK0rl(X1aiUBEcN9nkiryVzZYLgUWTPps6Of)46cJZajtmz5aXebMYLgUWTPps6Of)46cJZajZt4SVrXAaMYLgUWTPps6Of)46cJZajt6Yb(c0UAclt)2ObK4xOzSWVBR(tc71zBGW1Qbi3zz6snqy(loVg4wmLh2lMZQBr8iPbj(TJHLPpsAAjCNIInlc1ewM(TrdiXVqZyLaEocqds8lSCizN0j)aPmolUWED(P6tramyNA2SCPjb8CeGgK43etwoqmr0SPTYLMeWZraAqIFtmz5aXMcMhEP69ajthUwzFRWrQOjCWNLKHezWEBlvS3SjltFK00s4off08uutyz63gnGe)cnJv0YBjH96miCTA8vY)YPFRgim)fNx9v1WF8KMYzTyaHRvdi9r6hObj(nLZAXWY0hjnTeUtrbnpf1ewM(TrdiXVqZyHZWDH96miCTA8vY)YPFRbUfdltFK00s4offBy1ewM(TrdiXVqZyHZWDH96Snq4A1e5rgiPLhoiN8MMyYYbcAwC7ySbcxRM8UeGM3Iw2zldCRDmGW1QXxj)lN(Tg4wmSm9rstlH7uCEy1ewM(TrdiXVqZyHZlWojSxNbHRvJVs(xo9BnWTyyz6JKMwc3POyZIqnHLPFB0as8l0mw43Tv)jHLdj7Ko5hiLXzXf2RZpvFkcGb7egwM(iPPLWDkk2Siutyz63gnGe)cnJfod3f2RZ2SzdeUwn5DjanVfTSZwMyYYbcAEy7nBAdeUwn5DjanVfTSZwg4wmGW1QjVlbO5TOLD2Y8eo7BumXnnWEZM2aHRvtKhzGKwE4GCYBAIjlhiOzry3ogwM(iPPLWDkkMiSRMWY0VnAaj(fAgReWZraAqIFH96mltFK00s4offK4QjSm9BJgqIFHMXc)UT6pjSxNTbcxRgGCNLPl1aH5V48AGBXuEyVyKCAr8iPbj(TJHLPpsAAjCNIInlIMnTbcxRgGCNLPl1aH5V48AGBX0y5H9IrYPfXJKgK4htJLh2lMZQBr8iPbj(TJHLPpsAAjCNIInlc1ewM(TrdiXVqZyHZlWojSxNTz7zGKytfbBhdltFK00s4offte2B20MTNbsIn1nWogwM(iPPLWDkkMiWKCN20ep4U(Q6eaPR3tX0qld2PID1ewM(TrdiXVqZy1c3hP3Nosy5qYoPt(bszCwCH96C5stc45ianiXVjMSCGGgwnHLPFB0as8l0mwjGNJa0Ge)QjSm9BJgqIFHMXcNH7c71zwM(iPPLWDkkMiutyz63gnGe)cnJv0YBjniXVAclt)2ObK4xOzS8)2k8lSxNFgizku1LEk2uemgq4A14)Tv438eo7BumbBAGAIAY0ubwM(TrHMXsY9UMLPFRU7Xu4LXPzCpDGC63QMmnvGLPFBuOzSS8ErlbWpqsnzAQalt)2OqZyj5ExZY0Vv39yk8Y40S8UE5S2OAY0ubwM(TrHMXcNH7c715NbsMcvDPNInSGXWY0hjnTeUtrXMIAY0ubwM(TrHMXcNH7c715NbsMcvDPNInSGXqXiTsYiVT2DzQ5TOJ57vYGZIeUhtJGW1QjcG)wAPIw2zRObUvnzAQalt)2OqZy5)Tv4xyVolVyol4MnT9mqsqYlMy4PJEpjtNhIEQOX5Lm0YGDQGHLPpsAAjCNIcAy7Qjttfyz63gfAgRw4(i9(0rcN8dKsTxNlxAsaphbObj(nXKLdMlxAsaphbObj(n4SivhtwoiQMmnvGLPFBuOzSWVBR(tcN8dKsTxNlxAWVBR(tMNQpfbWGDcdltFK00s4offBy1KPPcSm9BJcnJvc45iaH96Snq4A14RK)Lt)wt5SwmSm9rstlH7uuqIBVztBGW1QXxj)lN(Tg4wmSm9rstlH7uuqtXUAY0ubwM(TrHMXkA5TKWEDgeUwn(k5F50V1uoRfdltFK00s4off0uutMMkWY0Vnk0mw48cStc715YLMeWZraAqIFt6Yb(cunzAQalt)2OqZyHF3w9Neo5hiLAVodcxRgGCNLPl1aH5V48AGBXWY0hjnTeUtrXgwnzAQalt)2OqZyLaEocqnzAQqd1EVRcwEcqfA4UBR(tQGLNauHgQUSHtKoSAY0ubwM(TrHMXc)UT6pjSxN5PJEpjt7zrV(Q6eaPXVBnpVdeK4yyz6JKMwc3P4S4Qjttfyz63gfAgROL3sQjQjSm9BJgCpDGC63o7)Tv4xyVo7R8W9fOUW4mqs3GOG8)2k8RlmodK0jGNIaUEbdiCTA8)2k8BEcN9nkMiejbWXKutyz63gn4E6a50VvOzSEAjlUlSxNtEh4lqmaiUNamTYuSPVbQjSm9BJgCpDGC63k0mw1N2PZPI(jG0spN(Tc715K3b(cedaI7jatRmfB6BGAclt)2Ob3thiN(TcnJfVooRVQUqCcqyVoNhqGDYuOkTrFKIyaqCpbyALPytTGvtyz63gn4E6a50VvOzSi82ZIEn4TfH96STglpSxmsoTiEK0Ge)yAS8WEXCwDlIhjniXV9Mnzz6JKMwc3POGMhwnHLPFB0G7PdKt)wHMXcK)bXb(kSxNTLCN20a(moyNIgAzWovSJXgiCTAaj(117XnWT2XK8oWxGyaqCpbyALPynKgGXx5H7lqDHXzGKUbrbjyJ4IKaiUNam4SivnHLPFB0G7PdKt)wHMXkc)J(i31(gtFLzuyVodcxRMi8p6JCx7Bm9vMrt5SwmGW1QbK)bXb(AkN1IbaX9eGPvMIn9cgJVYd3xG6cJZajDdIcsWMHBGijaI7jadolsvtutyz63gnY76LZAJZTx63QMWY0VnAK31lN1gfAglae)PMIrALKAclt)2OrExVCwBuOzSa73v0v4Fi1ewM(TrJ8UE5S2OqZybsFK(b(cunHLPFB0iVRxoRnk0mw8l5L059pTPAclt)2OrExVCwBuOzS6oqazulsaUaeN2unHLPFB0iVRxoRnk0mwv)jW(Df1ewM(TrJ8UE5S2OqZyXRKI5ZDTK7D1ewM(TrJ8UE5S2OqZyb(Em7(cuxHFH96miCTAaj(117XnWTQjSm9BJg5D9YzTrHMXYxj)lN(Tc71zBLln43Tv)jt6Yb(cSztwM(iPPLWDkkiXTJPCPjb8CeGgK43KUCGVavtyz63gnY76LZAJcnJfi9r6hOMWY0VnAK31lN1gfAgl4iP9KWfMQvsM6LXPz5qY(L)TUud25yQMWY0VnAK31lN1gfAglEDCwFvDH4eGWEDopGa7KrExVCwBeJT0XjDE6ItIjVRxoRTH5WnBYY0hjnTeUtrbjUD1ewM(TrJ8UE5S2OqZyHt43pK(Q6oS0l6YtmEunHLPFB0iVRxoRnk0mwWrs7jHhvtutyz63gnsoTiEKMB)ZQRMWY0VnAKCAr8ij0mwso117Xf2RZnccxRgjN6694g4w1ewM(TrJKtlIhjHMX65bKWEDgeUwnT)z1nWTQjSm9BJgjNwepscnJfaI)uFvDcG0wEViSxNtUtBAaq8N6RQtaK2Y7fdTmyNkyAeeUwnai(t9v1jasB59IbUvnHLPFB0i50I4rsOzSi82ZIEn4TfH96C5H9IrYPfXJKgK4xnHLPFB0i50I4rsOzSK3oEdiDcG0Xw)9mkSxNlpSxmsoTiEK0Ge)QjSm9BJgjNwepscnJ17Tc715YLM3BnpvFkcGb7eg5HdE62Z3mkO5POMWY0VnAKCAr8ij0mwv6pPFWrnONKWEDwE4GNU98nJcAEkQjSm9BJgjNwepscnJfx420hjD0IFCH96STglxA4c3M(iPJw8JRlmodKmPlh4lqmnYY0V1WfUn9rshT4hxxyCgiz8vx7oqajgBnwU0WfUn9rshT4hxdG4UjD5aFb2Sz5sdx420hjD0IFCnaI7MNWzFJcse2B2SCPHlCB6JKoAXpUUW4mqYetwoqmrGPCPHlCB6JKoAXpUUW4mqY8eo7BuSgGPCPHlCB6JKoAXpUUW4mqYKUCGVaTRMWY0VnAKCAr8ij0mwppGe2RZLlnppGmpvFkcGb7eg5HdE62Z3mk2uutyz63gnsoTiEKeAgRiGNkc71z5HdE62Z3mkwdututyz63gns5TJ3aAwYPUEpUAclt)2OrkVD8gqcnJL82XBaPtaKo26VNr1e1ewM(TrtFij)SCwYPUEpUAIAclt)2OPpKKF(MXVBh4RUEpUAIAclt)2O5K3oEdOz872b(QR3JRMWY0VnAo5TJ3asOzSK3oEdiDcG0Xw)9mQMOMWY0VnAoRUfXJ0m(D7aF117Xf2RZnccxRg872b(QR3JBGBvtyz63gnNv3I4rsOzSaq8N6RQtaK2Y7fH96CYDAtdaI)uFvDcG0wEVyOLb7ubtJGW1QbaXFQVQobqAlVxmWTQjSm9BJMZQBr8ij0mweE7zrVg82IWEDU8WEXCwDlIhjniXVAclt)2O5S6wepscnJL82XBaPtaKo26VNrH96C5H9I5S6wepsAqIF1ewM(TrZz1TiEKeAglUWTPps6Of)4c71zBnwU0WfUn9rshT4hxxyCgizsxoWxGyAKLPFRHlCB6JKoAXpUUW4mqY4RU2DGasm2ASCPHlCB6JKoAXpUgaXDt6Yb(cSzZYLgUWTPps6Of)4Aae3npHZ(gfKiS3Sz5sdx420hjD0IFCDHXzGKjMSCGyIat5sdx420hjD0IFCDHXzGK5jC23Oynat5sdx420hjD0IFCDHXzGKjD5aFbAxnHLPFB0CwDlIhjHMXc)UT6pjSCizN0j)aPmolUWED(P6tramyNA2eeUwna5oltxQbcZFX51a3QMWY0VnAoRUfXJKqZyfH3Q)KWYHKDsN8dKY4S4c715NQpfbWGDsnHLPFB0CwDlIhjHMXkM8hHFGKWED2giCTAiz3BJKUdV8BGBB2eeUwnKS7TrshVo)g4w7QjSm9BJMZQBr8ij0mwXK)Q)KWED2gj7EBKm(Q7Wl)nBsYU3gjt868RxsKM2B20gj7EBKm(Q7Wl)yaHRvtm5pc)ajnH3Ew0JtBQ7Wl)g4w7QjSm9BJMZQBr8ij0mwwpNaqqXwsIeqCbpfuIseca]] )

end