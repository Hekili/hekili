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


        any_form = {
            alias = { "bear_form", "cat_form", "moonkin_form" },
            duration = 3600,
            aliasMode = "first",
            aliasType = "buff",            
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
        width = "full"
    } )

    spec:RegisterSetting( "ironfur_damage_threshold", 5, {
        name = "Required Damage % for |T1378702:0|t Ironfur",
        desc = "If set above zero, the addon will not recommend |T1378702:0|t Ironfur unless your incoming damage for the past 5 seconds is greater than this percentage of your maximum health.",
        type = "range",
        min = 0,
        max = 100,
        step = 0.1,
        width = "full"
    } )

    spec:RegisterSetting( "shift_for_convoke", false, {
        name = "|T3636839:0|t Powershift for Convoke the Spirits",
        desc = "If checked and you are a Night Fae, the addon will recommend swapping to your Feral/Balance Affinity specialization before using |T3636839:0|t Convoke the Spirits.  " ..
            "This is a DPS gain unless you die horribly.",
        type = "toggle",
        width = "full"
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

    spec:RegisterPack( "Guardian", 20201205, [[dOK7obqibPhPiLljvQqBck(KuPsAucQtjjwfrrYRisMfrQBjic7IIFbLmmIqhJOQLPi5zefMMuPCnbHTPiv(MGinoIIY5eevRtqenpIk3dG9reCqPsfzHeLEOGOmrPsv6IsLkQnkvQG(OuPkoPuPQwPIyMsLkXnLkvQDsenuPsfyPefPQNcYuHs9vIIuzVq(lPgmLomQfd0JjzYs5YiBwIpdOrROonvRMOiLxlvmBfUnuTBL(TkdxsDCIIQLRQNl00fDDqTDPQVlW4jkIZlvY6vKQMVK0(jmsEe2iOgNesYPK4usu(PKyimYlXUfY7Mmqqzx1ecQMvDyGecAzCcb19aZFZ5fbvZDnoUHWgbfp4xriO5mRJHKyHfqpNHbnQdhROJdp40Vv9CjXk64kSqqGW(i7(lceb14KqsoLeNsIYpLedHrEj2nzw3qqmCoFpccYXdziOzV1OfbIGAuuHGMMW29aZFZ5vy7EFyVjMmnHT7Lueoi9cBiKwyNsItjrXeXKPjSHSzEbsXqsXKPjSHecB3Fv3xFpNKWgY4eRU772o(kS1VFVNoff2WEryJuM(cuy9OWQMjvhQvXiMmnHnKqy7(R6(675Ke2Ro9Bf28e24SxsHn89c7EzfHfKk3tcBi72(RdzqqdpMre2iOrxk(5dHnss5ryJGyv63IGWVB74RUCpocIwgCqnKSOeLiiqIFe2ijLhHncIwgCqnKSii17j9oJGcvybHlfdiXVUCpUbUgbXQ0Vfbbs8Rl3JJsKKtHWgbXQ0Vfb9CpThCuxEAN(Uqq0YGdQHKfLijLbcBeeTm4GAizrqQ3t6DgbfQW2EyVzuCgqCpPbj(fwmcBOcB7H9M5cgbe3tAqIFeeRs)weK62(RdPZzshR93Zikrs2ne2iiAzWb1qYIGuVN07mckSWccxkMN7P9GJ6Yt703LbUwyRwvydvyvxpT8MMEAZ5UEHTccIvPFlccK(i9DqjsYqGWgbrldoOgsweK69KENrqHfwq4sX8CpThCuxEAN(UmW1cB1QcBOcR66PL300tBo31lSvqqSk9Brq(Q4F50VfLijNoe2iiAzWb1qYIGuVN07mckSWgQW2U0WnUo9Eshd4hx3yCgizsx1XxGclgHnuHLvPFRHBCD69KogWpUUX4mqY4RUmCGZPWIrydlSHkSTlnCJRtVN0Xa(X1ZepmPR64lqHTAvHTDPHBCD69KogWpUEM4H5jC23OWkbHvgcBfHTAvHTDPHBCD69KogWpUUX4mqYetw1ryLtyLHWIryBxA4gxNEpPJb8JRBmodKmpHZ(gfw5e2qiSye22LgUX1P3t6ya)46gJZajt6Qo(cuyRGGyv63IG4gxNEpPJb8JJsKKHue2iiAzWb1qYIGuVN07mckSWccxkgG8GvPR0aH5V58AGRfwmcB7H9M5cgbe3tAqIFHTIWIryzv69KMwc3POWkhaHvgiiwL(Tii872I)ekrskZqyJGOLbhudjlcIvPFlckNFooRbj(rqQ3t6Dgb9u5P4mdoiHTAvHTDPjNFooRbj(nXKvDew5ewziSvRkSHf22LMC(54SgK43etw1ryLty7MWIryF4Lk3dKmd4sH9TahPMMWbFwrgsMd711utyRiSvRkSSk9EstlH7uuyLaaHTBiivxQbPt(bszejP8OejzihHncIwgCqnKSii17j9oJGaHlfJVk(xo9B1aH5V58QVIg(JNY0UGvyXiSGWLIbK(i9D0Ge)M2fSclgHLvP3tAAjCNIcReaiSDdbXQ0Vfbfd8Asds8JsKKYlre2iiAzWb1qYIGuVN07mcceUum(Q4F50V1axlSyewwLEpPPLWDkkSYjStHGyv63IGWz4bkrskV8iSrq0YGdQHKfbPEpP3zeuyHfeUumrUNbsA1HdYjVPjMSQJWkbacR8cBfHfJWgwybHlftExoR5TPvdoWaxlSvewmcliCPy8vX)YPFRbUwyXiSSk9EstlH7uuybiStHGyv63IGWz4bkrsk)uiSrq0YGdQHKfbPEpP3zeeiCPy8vX)YPFRbUwyXiSSk9EstlH7uuyLdGWkdeeRs)weeoVahekrskVmqyJGOLbhudjlcIvPFlcc)UT4pHGuVN07mc6PYtXzgCqclgHLvP3tAAjCNIcRCaewzGGuDPgKo5hiLrKKYJsKKY3ne2iiAzWb1qYIGuVN07mckSWgwydlSGWLIjVlN1820QbhyIjR6iSsaGWoLWwryRwvydlSGWLIjVlN1820QbhyGRfwmcliCPyY7YznVnTAWbMNWzFJcRCcR8MqiSve2Qvf2WcliCPyICpdK0QdhKtEttmzvhHvcaewziSve2kclgHLvP3tAAjCNIcRCcRme2kiiwL(TiiCgEGsKKYhce2iiAzWb1qYIGuVN07mcIvP3tAAjCNIcReew5rqSk9Brq58ZXzniXpkrsk)0HWgbrldoOgsweK69KENrqHfwq4sXaKhSkDLgim)nNxdCTWIryBpS3mkodiUN0Ge)cBfHfJWYQ07jnTeUtrHvoacRme2Qvf2WcliCPyaYdwLUsdeM)MZRbUwyXiSHkSTh2BgfNbe3tAqIFHfJWgQW2EyVzUGraX9KgK4xyRiSyewwLEpPPLWDkkSYbqyLbcIvPFlcc)UT4pHsKKYhsryJGOLbhudjlcs9EsVZiOWcByH9zGKWkNWgYLOWwryXiSSk9EstlH7uuyLtyLHWwryRwvydlSHf2NbscRCcRmlecBfHfJWYQ07jnTeUtrHvoHvgclgHn5bTPjEWd9v05mPl3tX0qldoOMWwbbXQ0VfbHZlWbHsKKYlZqyJGOLbhudjlcIvPFlcQgE0tVp9ecs9EsVZiO2LMC(54SgK43etw1ryLGWofcs1LAq6KFGugrskpkrskFihHncIvPFlckNFooRbj(rq0YGdQHKfLijNsIiSrq0YGdQHKfbPEpP3zeeRsVN00s4offw5ewzGGyv63IGWz4bkrsoL8iSrqSk9BrqXaVM0Ge)iiAzWb1qYIsKKtnfcBeeTm4GAizrqQ3t6Dgb9mqY0OIR8uyLty7MefwmcliCPy8)2c8BEcN9nkSYjSs0eceeRs)weK)3wGFuIseeUNoqo9BryJKuEe2iiAzWb1qYIGuVN07mcYx1H7lqDJXzGKoerHvccR)3wGFDJXzGKoNFkoFJMWIrybHlfJ)3wGFZt4SVrHvoHvgcRmLWoZXKqqSk9Brq(FBb(rjsYPqyJGOLbhudjlcs9EsVZiOK3o(cuyXiSZepYztTkfw5e2PleiiwL(TiONwkGhOejPmqyJGOLbhudjlcs9EsVZiOK3o(cuyXiSZepYztTkfw5e2PleiiwL(TiOYt707ut)eqAPNt)wuIKSBiSrq0YGdQHKfbPEpP3zeuEaboitJk0g9EkkSye2zIh5SPwLcRCcRmtIiiwL(TiiEDCwFfDJ4CgLijdbcBeeTm4GAizrqQ3t6DgbfwydvyBpS3mkodiUN0Ge)clgHnuHT9WEZCbJaI7jniXVWwryRwvyzv69KMwc3POWkbac7uiiwL(TiicV(cOxdEBdLijNoe2iiAzWb1qYIGuVN07mcceUumGe)6Y94g4AHfJWM82XxGclgHDM4roBQvPWkNWgsdHWIry9vD4(cu3yCgiPdruyLGWkrJ8cRmLWot8iNn4SmbbXQ0VfbbYFNyhFrjsYqkcBeeTm4GAizrqQ3t6DgbbcxkMi83798q7Bm9vLrt7cwHfJWccxkgq(7e74RPDbRWIryNjEKZMAvkSYjStNefwmcRVQd3xG6gJZajDiIcReewjAMkecRmLWot8iNn4SmbbXQ0VfbfH)EVNhAFJPVQmIsuIGQFsD4GCIWgjP8iSrqSk9BrqD8T9uthR93ZicIwgCqnKSOej5uiSrq0YGdQHKfbPEpP3zeeiCPyuCQl3JBGRfwmcB7H9MrXzaX9KgK4hbXQ0Vfbv)xWaLijLbcBeeTm4GAizrqQ3t6DgbfQWccxkgE7sxUh3axlSye2WcBOcB7H9MrXzaX9KgK4xyRwvybHlfJItD5ECt7cwHTIWIrydlSHkSTh2BMlyeqCpPbj(f2Qvfwq4sXGF32XxD5ECt7cwHTccIvPFlccK4xxUhhLij7gcBeeTm4GAizrqQ3t6DgbL8G20mt8N6ROZzsh4JMHwgCqnHfJWgwyBpS3mkodiUN0Ge)clgHfeUumko1L7XnW1cB1QcB7H9M5cgbe3tAqIFHfJWccxkg872o(Ql3JBGRf2Qvfwq4sXGF32XxD5ECdCTWIrytEqBAa5bVksZLIVE2LHwgCqnHTccIvPFlcAM4p1xrNZKoWhnuIKmeiSrq0YGdQHKfbPEpP3zeeiCPyWVB74RUCpUbUwyXiSTh2BMlyeqCpPbj(rqSk9BrqbpNZOeLiOrxk(zfcBKKYJWgbXQ0VfbP4uxUhhbrldoOgswuIseuJkm8iryJKuEe2iiwL(TiOyh4XqdYXzeeTm4GAizrjsYPqyJGOLbhudjlcs9EsVZiOqfwq4sXu)xWWaxJGyv63IGGJK2tcpIsKKYaHncIwgCqnKSii17j9oJGclSHf2WcBYdAtZmXFQVIoNjDGpAgAzWb1ewmcliCPyMj(t9v05mPd8rZaxlSvewmcByHT9WEZO4mG4Esds8lSvRkSTh2BMlyeqCpPbj(f2kclgHnuHfeUum1)fmmW1cBfHTAvHnSWgwybHlfdi9r67Obj(nW1cB1QcliCPy8vX)YPFRgim)nNx9v0WF8ug4AHTIWIrydlSHkSTh2BgfNbe3tAqIFHfJWgQW2EyVzUGraX9KgK4xyRiSve2kiiwL(TiO6l9BrjsYUHWgbrldoOgsweK69KENrqTh2BgfNbe3tAqIFHfJWccxkgfN6Y94g4AeeRs)we0dVAwL(T6Hhte0WJPEzCcbP4mG4EcLijdbcBeeTm4GAizrqQ3t6Dgb1EyVzUGraX9KgK4xyXiSGWLIb)UTJV6Y94g4AeeRs)we0dVAwL(T6Hhte0WJPEzCcbDbJaI7juIKC6qyJGOLbhudjlcs9EsVZiOWcByH9HxQCpqYm6sXph1LbrPVa1ahoEDKmKmh2RRPMWwryXiSHf2Kh0MgqEWRI0CP4RNDzOLbhutyRiSye2WcliCPygDP4NJ6YGO0xGAGdhVosg4AHTIWIrydlSGWLIz0LIFoQldIsFbQboC86izEcN9nkSYbqyNsyRiSvqqSk9Brqp8Qzv63QhEmrqdpM6LXje0Olf)8HsKKHue2iiAzWb1qYIGuVN07mckSWgwyF4Lk3dKmJUu8ZrDzqu6lqnWHJxhjdjZH96AQjSvewmcByHn5bTPPqpp0CP4RNDzOLbhutyRiSye2WcliCPygDP4NJ6YGO0xGAGdhVosg4AHTIWIrydlSGWLIz0LIFoQldIsFbQboC86izEcN9nkSYbqyNsyRiSvqqSk9Brqp8Qzv63QhEmrqdpM6LXje0Olf)ScLijLziSrq0YGdQHKfbPEpP3zeuKY0xGrtC2lPUCVwDB)1HewmcByHnSWM8G20aYdEvKMlfF9SldTm4GAcBfHfJWgwydvyBpS3mkodiUN0Ge)cBfHfJWgwydvyBpS3mxWiG4Esds8lSvewmcByHvD90YBAwh4CQlmjSyew1DJ2fSg1T9xhsNZKow7VNrZt4SVrHvoacR8cBfHTccIvPFlc6HxnRs)w9WJjcA4XuVmoHGo1T9xhcLijd5iSrq0YGdQHKfbPEpP3zeuKY0xGrtC2lPUCVwDB)1HewmcByHnSWM8G20uONhAUu81ZUm0YGdQjSvewmcByHnuHT9WEZO4mG4Esds8lSvewmcByHnuHT9WEZCbJaI7jniXVWwryXiSHfw11tlVPzDGZPUWKWIryv3nAxWAu32FDiDot6yT)EgnpHZ(gfw5aiSYlSve2kiiwL(TiOhE1Sk9B1dpMiOHht9Y4ecsPUT)6qOejP8seHncIwgCqnKSiiwL(TiifpgAwL(T6Hhte0WJPEzCcbH7PdKt)wuIKuE5ryJGOLbhudjlcIvPFlc6HxnRs)w9WJjcA4XuVmoHGaj(rjkrqkodiUNqyJKuEe2iiwL(TiO6)cgiiAzWb1qYIsKKtHWgbrldoOgsweK69KENrqHkSGWLIrXPUCpUbUgbXQ0VfbP4uxUhhLijLbcBeeTm4GAizrqQ3t6DgbbcxkM6)cgg4AeeRs)we0ZDiuIKSBiSrq0YGdQHKfbPEpP3zeuYdAtZmXFQVIoNjDGpAgAzWb1ewmcBOcliCPyMj(t9v05mPd8rZaxJGyv63IGMj(t9v05mPd8rdLijdbcBeeTm4GAizrqQ3t6Dgb1EyVzuCgqCpPbj(rqSk9BrqeE9fqVg82gkrsoDiSrq0YGdQHKfbPEpP3zeu7H9MrXzaX9KgK4hbXQ0VfbPUT)6q6CM0XA)9mIsKKHue2iiAzWb1qYIGuVN07mcQDP59AZtLNIZm4GewmcR6WbpD95Bgfwjaqy7gcIvPFlc69AuIKuMHWgbrldoOgsweK69KENrqQdh801NVzuyLaaHTBiiwL(TiOc9NYp4Og0tcLijd5iSrq0YGdQHKfbPEpP3zeuyHnuHTDPHBCD69KogWpUUX4mqYKUQJVafwmcBOclRs)wd34607jDmGFCDJXzGKXxDz4aNtHfJWgwydvyBxA4gxNEpPJb8JRNjEysx1XxGcB1QcB7sd34607jDmGFC9mXdZt4SVrHvccRme2kcB1QcB7sd34607jDmGFCDJXzGKjMSQJWkNWkdHfJW2U0WnUo9Eshd4hx3yCgizEcN9nkSYjSHqyXiSTlnCJRtVN0Xa(X1ngNbsM0vD8fOWwbbXQ0VfbXnUo9Eshd4hhLijLxIiSrq0YGdQHKfbPEpP3zeu7sZZDiZtLNIZm4GewmcR6WbpD95Bgfw5e2UHGyv63IGEUdHsKKYlpcBeeTm4GAizrqQ3t6DgbPoCWtxF(MrHvoHneiiwL(TiO48tnuIseK6Ur7c2icBKKYJWgbXQ0VfbvFPFlcIwgCqnKSOej5uiSrqSk9BrqZe)PMIrAvecIwgCqnKSOejPmqyJGyv63IGah310f4VleeTm4GAizrjsYUHWgbXQ0VfbbsFK(o(cebrldoOgswuIKmeiSrqSk9Brq8R4L059pTjcIwgCqnKSOej50HWgbXQ0VfbnCGZzultdUbeN2ebrldoOgswuIKmKIWgbXQ0Vfbv8Nah31qq0YGdQHKfLijLziSrqSk9Brq8QOy(8qR4XabrldoOgswuIKmKJWgbrldoOgsweK69KENrqGWLIbK4xxUh3axJGyv63IGaFpMdFbQlWpkrskVeryJGOLbhudjlcs9EsVZiOWcB7sd(DBXFYKUQJVaf2QvfwwLEpPPLWDkkSsqyLxyRiSye22LMC(54SgK43KUQJVarqSk9Brq(Q4F50VfLijLxEe2iiwL(Tiiq6J03bbrldoOgswuIKu(PqyJGOLbhudjlcIvPFlcs1LAC5FRR0GdoMiiQuivQxgNqqQUuJl)BDLgCWXeLijLxgiSrq0YGdQHKfbPEpP3zeuEaboiJ6Ur7c2OWIrydlSPJt680nNew5ewwL(TA1DJ2fSclwc7ucB1QclRsVN00s4offwjiSYlSvqqSk9Brq864S(k6gX5mkrskF3qyJGyv63IGWj877sFf9aw5nD7jgpIGOLbhudjlkrskFiqyJGyv63IGGJK2tcpIGOLbhudjlkrjc6u32FDie2ijLhHncIvPFlcc)UTJV6Y94iiAzWb1qYIsKKtHWgbXQ0VfbPUT)6q6CM0XA)9mIGOLbhudjlkrjcsPUT)6qiSrskpcBeeRs)weKItD5ECeeTm4GAizrjsYPqyJGyv63IGu32FDiDot6yT)Egrq0YGdQHKfLOebDbJaI7je2ijLhHncIwgCqnKSii17j9oJGcvybHlfd(DBhF1L7XnW1iiwL(Tii872o(Ql3JJsKKtHWgbrldoOgsweK69KENrqjpOnnZe)P(k6CM0b(OzOLbhutyXiSHkSGWLIzM4p1xrNZKoWhndCncIvPFlcAM4p1xrNZKoWhnuIKugiSrq0YGdQHKfbPEpP3zeu7H9M5cgbe3tAqIFeeRs)weeHxFb0RbVTHsKKDdHncIwgCqnKSii17j9oJGApS3mxWiG4Esds8JGyv63IGu32FDiDot6yT)EgrjsYqGWgbrldoOgsweK69KENrqHf2qf22LgUX1P3t6ya)46gJZajt6Qo(cuyXiSHkSSk9BnCJRtVN0Xa(X1ngNbsgF1LHdCofwmcByHnuHTDPHBCD69KogWpUEM4HjDvhFbkSvRkSTlnCJRtVN0Xa(X1ZepmpHZ(gfwjiSYqyRiSvRkSTlnCJRtVN0Xa(X1ngNbsMyYQocRCcRmewmcB7sd34607jDmGFCDJXzGK5jC23OWkNWgcHfJW2U0WnUo9Eshd4hx3yCgizsx1XxGcBfeeRs)wee34607jDmGFCuIKC6qyJGOLbhudjlcIvPFlcc)UT4pHGuVN07mc6PYtXzgCqcB1QcliCPyaYdwLUsdeM)MZRbUgbP6sniDYpqkJijLhLijdPiSrq0YGdQHKfbXQ0VfbfH3I)ecs9EsVZiONkpfNzWbHGuDPgKo5hiLrKKYJsKKYme2iiAzWb1qYIGuVN07mckSWccxkgsn86iPhWl)g4AHTAvHfeUumKA41rshVb)g4AHTccIvPFlckM8hHFGekrsgYryJGOLbhudjlcs9EsVZiOWclPgEDKm(QhWl)cB1QclPgEDKmXBWVEjzskSve2Qvf2WclPgEDKm(QhWl)clgHfeUumXK)i8dK0eE9fqpoTPEaV8BGRf2kiiwL(TiOyYFXFcLijLxIiSrqSk9BrqbpNZiiAzWb1qYIsuIseup9r)wKKtjXPKO8Yp10HGc4F9fyebjtx3jz6LS7lz3tiPWkSyptcRJxFFkSL7f2URQ7gTlyJDxf2NK5W(tnHnE4KWYW5HZj1ew1mVaPOrmP7IVKWkVmcjf2q2T90NutyHC8qMWg7AtwMiSDhf28e2UlWSW28Ep63kSxn9CEVWggRkcBy5LjvmIjIjDF867tQjSYlVWYQ0VvyhEmJgXeeuSMuijLxIDdbv)xXhecAAcB3dm)nNxHT79H9MyY0e2Uxsr4G0lSHqAHDkjoLeftetMMWgYM5fifdjftMMWgsiSD)vDF99CscBiJtS6UVB74RWw)(9E6uuyd7fHnsz6lqH1JcRAMuDOwfJyY0e2qcHT7VQ7RVNtsyV60VvyZtyJZEjf2W3lS7LvewqQCpjSHSB7VoKrmrmzAcB3zzcPGtQjSGu5EsyvhoiNclib03Ory7oPuuDgf292qIz(XlWdHLvPFBuyVD0LrmHvPFB0u)K6Wb5ukay1X32tnDS2FpJIjSk9BJM6NuhoiNsbaR6)cgs7faGWLIrXPUCpUbUgt7H9MrXzaX9KgK4xmHvPFB0u)K6Wb5ukaybs8Rl3JlTxaekiCPy4TlD5ECdCnMWH2EyVzuCgqCpPbj(RwfeUumko1L7XnTlyRGjCOTh2BMlyeqCpPbj(RwfeUum43TD8vxUh30UGTIycRs)2OP(j1HdYPuaWAM4p1xrNZKoWhnP9cGKh0MMzI)uFfDot6aF0m0YGdQHjC7H9MrXzaX9KgK4hdiCPyuCQl3JBGRRwT9WEZCbJaI7jniXpgq4sXGF32XxD5ECdCD1QGWLIb)UTJV6Y94g4AmjpOnnG8GxfP5sXxp7YqldoOwfXewL(Trt9tQdhKtPaGvWZ5S0EbaiCPyWVB74RUCpUbUgt7H9M5cgbe3tAqIFXeXKPjSDNLjKcoPMWs903LWMoojS5mjSSkVxy9OWY9SpyWbzetyv63gbe7apgAqoolMWQ0VnkfaSGJK2tcpkTxaekiCPyQ)lyyGRftyv63gLcaw1x63kTxaeoC4Kh0MMzI)uFfDot6aF0m0YGdQHbeUumZe)P(k6CM0b(OzGRRGjC7H9MrXzaX9KgK4VA12d7nZfmciUN0Ge)vWekiCPyQ)lyyGRRuTA4WGWLIbK(i9D0Ge)g46QvbHlfJVk(xo9B1aH5V58QVIg(JNYaxxbt4qBpS3mkodiUN0Ge)ycT9WEZCbJaI7jniXFLkvetMMWYQ0VnkfaSE4vZQ0Vvp8yk9Y4eafNbe3ts7faTh2BgfNbe3tAqIFmHdRUB0UG1KZphN1Ge)MNWzFJsqIyu3nAxWAW5f4GmpHZ(gLGeX0U0GF3w8NmpHZ(gLaaGQMus0ecmpdKKRBsediCPy8vX)YPFRgim)nNx9v0WF8uM2fSyaHlfdi9r67Obj(nTlyXacxkgG8GvPR0aH5V58AAxWwPA1WGWLIrXPUCpUbUgdT0dSljmviQuTA4hEPY9ajZX5S(k6CM00OrVU9WEZqYCyVUMAycfeUumhNZ6ROZzstJg962d7ndCnMWGWLIrXPUCpUbUgdT0dSljmLeRuPA1Wp8sL7bsMJZz9v05mPPrJED7H9MHK5WEDn1WacxkMzI)uFfDot6aF0mpHZ(gLtEjwbtyq4sXO4uxUh3axJHw6b2LeMsIvQwnS66PL300PR35fJ6Ur7cwdHxFb0RbVTzEcN9nkha5XWQ07jnTeUtr5MQsfXewL(TrPaG1dVAwL(T6HhtPxgNaO4mG4EsAVaO9WEZO4mG4Esds8JbeUumko1L7XnW1Ijttyzv63gLcawp8Qzv63QhEmLEzCcWfmciUNK2laApS3mxWiG4Esds8JjCy1DJ2fSMC(54SgK438eo7BucseJ6Ur7cwdoVahK5jC23OeKiMNbsYnLeXacxkgFv8VC63AAxWIbeUumG0hPVJgK430UGTs1QHbHlfd(DBhF1L7XnW1yAxAIWBXFY8u5P4mdoOkvRggeUum43TD8vxUh3axJbeUumZe)P(k6CM0b(OzGRRuTAyq4sXGF32XxD5ECdCnMWGWLIHudVos6b8YVbUUAvq4sXqQHxhjD8g8BGRRGj0hEPY9ajZX5S(k6CM00OrVU9WEZqYCyVUMAvQwn8dVu5EGK54CwFfDotAA0Ox3EyVzizoSxxtnmHccxkMJZz9v05mPPrJED7H9MbUUs1QHvxpT8MM1boN6ctyu3nAxWAu32FDiDot6yT)EgnpHZ(gLdG8vQwnS66PL300PR35fJ6Ur7cwdHxFb0RbVTzEcN9nkha5XWQ07jnTeUtr5MQsfXewL(TrPaG1dVAwL(T6HhtPxgNaCbJaI7jP9cG2d7nZfmciUN0Ge)yaHlfd(DBhF1L7XnW1IjSk9BJsbaRhE1Sk9B1dpMsVmoby0LIF(K2lach(HxQCpqYm6sXph1LbrPVa1ahoEDKmKmh2RRPwfmHtEqBAa5bVksZLIVE2LHwgCqTkycdcxkMrxk(5OUmik9fOg4WXRJKbUUcMWGWLIz0LIFoQldIsFbQboC86izEcN9nkhGPQurmHvPFBukay9WRMvPFRE4Xu6LXjaJUu8ZkP9cGWHF4Lk3dKmJUu8ZrDzqu6lqnWHJxhjdjZH96AQvbt4Kh0MMc98qZLIVE2LHwgCqTkycdcxkMrxk(5OUmik9fOg4WXRJKbUUcMWGWLIz0LIFoQldIsFbQboC86izEcN9nkhGPQurmHvPFBukay9WRMvPFRE4Xu6LXjaN62(RdjTxaePm9fy0eN9sQl3Rv32FDimHdN8G20aYdEvKMlfF9SldTm4GAvWeo02d7nJIZaI7jniXFfmHdT9WEZCbJaI7jniXFfmHvxpT8MM1boN6ctyu3nAxWAu32FDiDot6yT)EgnpHZ(gLdG8vQiMWQ0VnkfaSE4vZQ0Vvp8yk9Y4eaL62(RdjTxaePm9fy0eN9sQl3Rv32FDimHdN8G20uONhAUu81ZUm0YGdQvbt4qBpS3mkodiUN0Ge)vWeo02d7nZfmciUN0Ge)vWewD90YBAwh4CQlmHrD3ODbRrDB)1H05mPJ1(7z08eo7BuoaYxPIycRs)2OuaWsXJHMvPFRE4Xu6LXja4E6a50VvmHvPFBukay9WRMvPFRE4Xu6LXjaGe)IjIjSk9BJgqIFaGe)6Y94s7faHccxkgqIFD5ECdCTycRs)2ObK4xkay9CpThCuxEAN(Uetyv63gnGe)sbal1T9xhsNZKow7VNrP9cGqBpS3mkodiUN0Ge)ycT9WEZCbJaI7jniXVycRs)2ObK4xkaybsFK(oAqIFP9cGWGWLI55EAp4OU80o9DzGRRwnu11tlVPPN2CURVIycRs)2ObK4xkay5RI)Lt)wP9cGWGWLI55EAp4OU80o9DzGRRwnu11tlVPPN2CURVIycRs)2ObK4xkayXnUo9Eshd4hxAP9cGWH2U0WnUo9Eshd4hx3yCgizsx1XxGycLvPFRHBCD69KogWpUUX4mqY4RUmCGZjMWH2U0WnUo9Eshd4hxpt8WKUQJVaRwTDPHBCD69KogWpUEM4H5jC23OeKrLQvBxA4gxNEpPJb8JRBmodKmXKvDKtgyAxA4gxNEpPJb8JRBmodKmpHZ(gLleyAxA4gxNEpPJb8JRBmodKmPR64lWkIjSk9BJgqIFPaGf(DBXFsAVaimiCPyaYdwLUsdeM)MZRbUgt7H9M5cgbe3tAqI)kyyv69KMwc3POCaKHycRs)2ObK4xkayLZphN1Ge)sR6sniDYpqkJaKxAVa4PYtXzgCqvR2U0KZphN1Ge)MyYQoYjJQvd3U0KZphN1Ge)MyYQoY1nmp8sL7bsMbCPW(wGJutt4GpRidjZH96AQvPAvwLEpPPLWDkkbaDtmHvPFB0as8lfaSIbEnjTxaacxkgFv8VC63QbcZFZ5vFfn8hpLPDblgq4sXasFK(oAqIFt7cwmSk9EstlH7uuca6MycRs)2ObK4xkayHZWdP9caq4sX4RI)Lt)wdCngwLEpPPLWDkk3uIjSk9BJgqIFPaGfodpK2lacdcxkMi3ZajT6Wb5K30etw1rcaKVcMWGWLIjVlN1820QbhyGRRGbeUum(Q4F50V1axJHvP3tAAjCNIaMsmHvPFB0as8lfaSW5f4GK2laaHlfJVk(xo9BnW1yyv69KMwc3POCaKHycRs)2ObK4xkayHF3w8NKw1LAq6KFGugbiV0EbWtLNIZm4GWWQ07jnTeUtr5aidXewL(TrdiXVuaWcNHhs7faHdhgeUum5D5SM3Mwn4atmzvhjayQkvRggeUum5D5SM3Mwn4adCngq4sXK3LZAEBA1GdmpHZ(gLtEtiQuTAyq4sXe5EgiPvhoiN8MMyYQosaGmQubdRsVN00s4ofLtgvetyv63gnGe)sbaRC(54SgK4xAVaGvP3tAAjCNIsqEXewL(TrdiXVuaWc)UT4pjTxaegeUuma5bRsxPbcZFZ51axJP9WEZO4mG4Esds8xbdRsVN00s4ofLdGmQwnmiCPyaYdwLUsdeM)MZRbUgtOTh2BgfNbe3tAqIFmH2EyVzUGraX9KgK4VcgwLEpPPLWDkkhaziMWQ0VnAaj(Lcaw48cCqs7faHd)mqsUqUeRGHvP3tAAjCNIYjJkvRgo8Zaj5KzHOcgwLEpPPLWDkkNmWK8G20ep4H(k6CM0L7PyAOLbhuRIycRs)2ObK4xkayvdp6P3NEsAvxQbPt(bszeG8s7faTln58ZXzniXVjMSQJeMsmHvPFB0as8lfaSY5NJZAqIFXewL(TrdiXVuaWcNHhs7faSk9EstlH7uuoziMWQ0VnAaj(LcawXaVM0Ge)IjSk9BJgqIFPaGL)3wGFP9cGNbsMgvCLNY1njIbeUum(FBb(npHZ(gLtIMqiMiMmnHLvPFBukayP4XqZQ0Vvp8yk9Y4eaCpDGC63kMmnHLvPFBukayf4JMwnZpqsmzAclRs)2OuaWsXJHMvPFRE4Xu6LXjaQ7gTlyJIjttyzv63gLcaw4m8qAVa4zGKPrfx5PCtjrmSk9EstlH7uuUUjMmnHLvPFBukayHZWdP9cGNbsMgvCLNYnLeXqXiTkYOUTmCvQ5TPJ57fYGZY0UhtOGWLIjoZFnTutRgCq0axlMmnHLvPFBukay5)Tf4xAVaqDXeGeRwn8ZajjOUyIHNE69KmdUl6PMgNxYqldoOggwLEpPPLWDkkHPQiMmnHLvPFBukayvdp6P3NEs6KFGuQ9cG2LMC(54SgK43etw1bq7sto)CCwds8BWzzIoMSQtumzAclRs)2OuaWc)UT4pjDYpqk1Ebq7sd(DBXFY8u5P4mdoimSk9EstlH7uuUPetMMWYQ0VnkfaSY5NJZs7faHbHlfJVk(xo9BnTlyXWQ07jnTeUtrjiFLQvddcxkgFv8VC63AGRXWQ07jnTeUtrj0TkIjttyzv63gLcawXaVMK2laaHlfJVk(xo9BnTlyXWQ07jnTeUtrj0nXKPjSSk9BJsbalCEboiP9cG2LMC(54SgK43KUQJVaftMMWYQ0VnkfaSWVBl(tsN8dKsTxaacxkgG8GvPR0aH5V58AGRXWQ07jnTeUtr5MsmzAclRs)2OuaWkNFoolMmnHT7qFme2apNf2U772I)KWg45SW2DWLD3YKPetMMWYQ0VnkfaSWVBl(ts7fa80tVNKP(cOxFfDotA87wZZBhjipgwLEpPPLWDkcqEXKPjSSk9BJsbaRyGxtIjIjSk9BJgCpDGC63cW)BlWV0EbGVQd3xG6gJZajDiIsW)BlWVUX4mqsNZpfNVrddiCPy8)2c8BEcN9nkNmKPM5ysIjSk9BJgCpDGC63kfaSEAPaEiTxaK82XxGyMjEKZMAvk30fcXewL(TrdUNoqo9BLcawLN2P3PM(jG0spN(Ts7fajVD8fiMzIh5SPwLYnDHqmHvPFB0G7PdKt)wPaGfVooRVIUrColTxaKhqGdY0OcTrVNIyMjEKZMAvkNmtIIjSk9BJgCpDGC63kfaSi86lGEn4TnP9cGWH2EyVzuCgqCpPbj(XeA7H9M5cgbe3tAqI)kvRYQ07jnTeUtrjaykXewL(TrdUNoqo9BLcawG83j2XxP9caq4sXas8Rl3JBGRXK82XxGyMjEKZMAvkxiney8vD4(cu3yCgiPdrucs0iVm1mXJC2GZYeXewL(TrdUNoqo9BLcawr4V375H23y6RkJs7faGWLIjc)9Epp0(gtFvz00UGfdiCPya5VtSJVM2fSyMjEKZMAvk30jrm(QoCFbQBmodK0HikbjAMkeYuZepYzdoltetetyv63gnQ7gTlyJaQV0VvmHvPFB0OUB0UGnkfaSMj(tnfJ0QiXewL(TrJ6Ur7c2OuaWcCCxtxG)Uetyv63gnQ7gTlyJsbalq6J03XxGIjSk9BJg1DJ2fSrPaGf)kEjDE)tBkMWQ0VnAu3nAxWgLcawdh4Cg1Y0GBaXPnftyv63gnQ7gTlyJsbaRI)e44UMycRs)2OrD3ODbBukayXRII5ZdTIhdXewL(TrJ6Ur7c2OuaWc89yo8fOUa)s7faGWLIbK4xxUh3axlMWQ0VnAu3nAxWgLcaw(Q4F50VvAVaiC7sd(DBXFYKUQJVaRwLvP3tAAjCNIsq(kyAxAY5NJZAqIFt6Qo(cumHvPFB0OUB0UGnkfaSaPpsFhXewL(TrJ6Ur7c2OuaWcosApjCPPsHuPEzCcGQl14Y)wxPbhCmftyv63gnQ7gTlyJsbalEDCwFfDJ4CwAVaipGahKrD3ODbBet40XjDE6MtYPUB0UGT74uvRYQ07jnTeUtrjiFfXewL(TrJ6Ur7c2OuaWcNWVVl9v0dyL30TNy8OycRs)2OrD3ODbBukaybhjTNeEumrmHvPFB0O4mG4Ecq9FbdXewL(TrJIZaI7jPaGLItD5ECP9cGqbHlfJItD5ECdCTycRs)2OrXzaX9KuaW65oK0EbaiCPyQ)lyyGRftyv63gnkodiUNKcawZe)P(k6CM0b(OjTxaK8G20mt8N6ROZzsh4JMHwgCqnmHccxkMzI)uFfDot6aF0mW1IjSk9BJgfNbe3tsbalcV(cOxdEBtAVaO9WEZO4mG4Esds8lMWQ0VnAuCgqCpjfaSu32FDiDot6yT)EgL2laApS3mkodiUN0Ge)IjSk9BJgfNbe3tsbaR3RL2laAxAEV28u5P4mdoimQdh801NVzuca6MycRs)2OrXzaX9KuaWQq)P8doQb9KK2lauho4PRpFZOea0nXewL(TrJIZaI7jPaGf34607jDmGFCP9cGWH2U0WnUo9Eshd4hx3yCgizsx1XxGycLvPFRHBCD69KogWpUUX4mqY4RUmCGZjMWH2U0WnUo9Eshd4hxpt8WKUQJVaRwTDPHBCD69KogWpUEM4H5jC23OeKrLQvBxA4gxNEpPJb8JRBmodKmXKvDKtgyAxA4gxNEpPJb8JRBmodKmpHZ(gLleyAxA4gxNEpPJb8JRBmodKmPR64lWkIjSk9BJgfNbe3tsbaRN7qs7faTlnp3HmpvEkoZGdcJ6WbpD95BgLRBIjSk9BJgfNbe3tsbaR48tnP9ca1HdE66Z3mkxietetyv63gnk1T9xhcGItD5ECXewL(TrJsDB)1HKcawQB7VoKoNjDS2FpJIjIjSk9BJMrxk(zfafN6Y94IjIjSk9BJMrxk(5da(DBhF1L7Xftetyv63gnN62(Rdba)UTJV6Y94IjSk9BJMtDB)1HKcawQB7VoKoNjDS2FpJIjIjSk9BJMlyeqCpba)UTJV6Y94s7faHccxkg872o(Ql3JBGRftyv63gnxWiG4Eskaynt8N6ROZzsh4JM0EbqYdAtZmXFQVIoNjDGpAgAzWb1WekiCPyMj(t9v05mPd8rZaxlMWQ0VnAUGraX9KuaWIWRVa61G32K2laApS3mxWiG4Esds8lMWQ0VnAUGraX9KuaWsDB)1H05mPJ1(7zuAVaO9WEZCbJaI7jniXVycRs)2O5cgbe3tsbalUX1P3t6ya)4s7faHdTDPHBCD69KogWpUUX4mqYKUQJVaXekRs)wd34607jDmGFCDJXzGKXxDz4aNtmHdTDPHBCD69KogWpUEM4HjDvhFbwTA7sd34607jDmGFC9mXdZt4SVrjiJkvR2U0WnUo9Eshd4hx3yCgizIjR6iNmW0U0WnUo9Eshd4hx3yCgizEcN9nkxiW0U0WnUo9Eshd4hx3yCgizsx1XxGvetyv63gnxWiG4EskayHF3w8NKw1LAq6KFGugbiV0EbWtLNIZm4GQwfeUuma5bRsxPbcZFZ51axlMWQ0VnAUGraX9KuaWkcVf)jPvDPgKo5hiLraYlTxa8u5P4mdoiXewL(TrZfmciUNKcawXK)i8dKK2lacdcxkgsn86iPhWl)g46QvbHlfdPgEDK0XBWVbUUIycRs)2O5cgbe3tsbaRyYFXFsAVaimPgEDKm(QhWl)vRsQHxhjt8g8RxsMKvQwnmPgEDKm(QhWl)yaHlftm5pc)ajnHxFb0JtBQhWl)g46kIjSk9BJMlyeqCpjfaScEoNrjkria]] )

end