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

    spec:RegisterPack( "Guardian", 20201207, [[du0BnbqiPsEKuvztGYOerNsewfOIQxrenlIu3sQqYUi1VicdduPJruzzsf9mPcMMuv11ikSnqf6BGkY4KkeNJOOADGkknpIQUhG2NuvoOuHsTqIspuQq1eLkuCrPcLSrIIO6JefrojrryLsvUPuHu7KizOefr5PGmvqv7fQ)sXGP0HrTyGEmjtwkxgzZI6ZkvJgGtt1Qbvu8ArYSvYTH0Uv8BvgUK64efLLRQNlX0fUoeBxP8Djz8efPZlvQ1dQG5lsTFcJLddpgQXbHLQt42jCLRt4cN0Yb3oL5Yqomu0DnHHQzvkENWqdJsyizsi83CEWq1C3RJBy4XqLd5vegcqe1f4SsiXUhaqa1QdvIIJIS4WVr9CoKO4OkjWqGi(kKjgmigQXbHLQt42jCLRt4cN0Yb3oL59xgyigjaCpgcYr74yiaERrdged1OIcd1pHvMec)nNhHTJ5r8MOx)e2ogsrOG0lSWjPf2oHBNWv0t0RFcBhhap7uboROx)e2okHvMyu3xFphKW2X5qIo67Mu(iS1VFVhove2KEwylue(SlSEryvaivkQLql61pHTJsyLjg1913ZbjSxD43iSXjSfaEoe2K3lSZfjewqkFpjSD8B2UuKgdT8suWWJHwDR4Npm8yPKddpgIvHFdgc9UjLpM89OyiAyWf1WYIdCGHaj(XWJLsom8yiAyWf1WYIHuVh07mgQlHfejN1Ge)M89OAKAmeRc)gmeiXVjFpkoWs1jgEmeRc)gm0ZB0Cift(Pbo0ngIggCrnSS4alvhWWJHOHbxudllgs9EqVZyOUe22J4nTIJkI3idiXVWcty7syBpI30x1QI4nYas8JHyv43GHu3SDPitaGmLA)9OGdSu9hdpgIggCrnSSyi17b9oJHskSGi5S(5nAoKIj)0ah6wJulSPtlSDjSQBJgEc9gnbGUFHnbgIvHFdgcK(c9PWbwkzGHhdrddUOgwwmK69GENXqjfwqKCw)8gnhsXKFAGdDRrQf20Pf2Uew1TrdpHEJMaq3VWMadXQWVbd5JI)Hd)gCGLcoIHhdrddUOgwwmK69GENXqjf2Ue22fAUX1HVrMsf)OMgJY7KoCvkF2fwycBxclRc)gn346W3itPIFutJr5Ds7JjV8DaHWctytkSDjSTl0CJRdFJmLk(rnaiEPdxLYNDHnDAHTDHMBCD4BKPuXpQbaXl9tOSpfHTpHTdcBcHnDAHTDHMBCD4BKPuXpQPXO8oPlbRsjSYlSDqyHjSTl0CJRdFJmLk(rnngL3j9tOSpfHvEHvgclmHTDHMBCD4BKPuXpQPXO8oPdxLYNDHnbgIvHFdgIBCD4BKPuXpkoWsbNWWJHOHbxudllgs9EqVZyONYpvaWGlsytNwyBxOdapxayaj(1LGvPew5f2oiSPtlSjf22f6aWZfagqIFDjyvkHvEHT)clmH9rgkF)oPxi5m7tgPqndHc(SI0KmdXRRPMWMqytNwyzv4BKHgc1PIW2hqHT)yiwf(nyOaWZfagqIFCGLQJGHhdrddUOgwwmK69GENXqjf2KclisoR35fRcxz2r4V58OrQf2eclmHLvHVrgAiuNkcR8cBNcBcHnDAHnPWMuybrYz9oVyv4kZoc)nNhnsTWMqyHjSDjSTl0O3nz)jD4Qu(SlSWewwf(gzOHqDQiS9jSYjSWe2G)Dk0HJsM4mnNe2(ew56uytGHyv43GHqVBY(t4alLmhdpgIggCrnSSyi17b9oJHskSTl0O3nz)j9tOSpfHvEGcBhewycBsHfejN178IvHRm7i83CE0i1cBcHfMWYQW3idneQtfHTpHvgclmHn4FNcD4OKjotZjHTpHvUof2eyiwf(nyi07MS)eoWsjhCXWJHOHbxudllgs9EqVZyOKc7t5NkayWfjSWewwf(gzOHqDQiSYlSDkSWe2G)Dk0HJsM4mnNe2(ew56uytiSPtlSjf2Ue22fA07MS)KoCvkF2fwyclRcFJm0qOove2(ew5ewycBW)of6WrjtCMMtcBFcRCDkSjWqSk8BWqO3nz)jCGLso5WWJHOHbxudllgs9EqVZyiqKCw7JI)Hd)gZoc)nNhZLniF5u62vnclmHfejN1G0xOpLbK4x3UQryHjSSk8nYqdH6ury7dOW2FmeRc)gmuPYRjdiXpoWsjxNy4Xq0WGlQHLfdPEpO3zmeisoR9rX)WHFJgPwyHjSSk8nYqdH6uryLxy7edXQWVbdHYilCGLsUoGHhdrddUOgwwmK69GENXqjfwqKCwx4nENmQdfKdEcDjyvkHTpGcRCcBcHfMWMuybrYzDCxaWWtZOwCLgPwytiSWewqKCw7JI)Hd)gnsTWctyzv4BKHgc1PIWcuy7edXQWVbdHYilCGLsU(JHhdrddUOgwwmK69GENXqGi5S2hf)dh(nAKAHfMWYQW3idneQtfHvEGcBhWqSk8BWqO8SViCGLsozGHhdrddUOgwwmK69GENXqjf2KcBsHfejN1XDbadpnJAXv6sWQucBFaf2of2ecB60cBsHfejN1XDbadpnJAXvAKAHfMWcIKZ64UaGHNMrT4k9tOSpfHvEHvoTme2ecB60cBsHfejN1fEJ3jJ6qb5GNqxcwLsy7dOW2bHnHWMqyHjSSk8nYqdH6uryLxy7GWMadXQWVbdHYilCGLso4igEmenm4IAyzXqQ3d6DgdXQW3idneQtfHTpHvomeRc)gmua45cadiXpoWsjhCcdpgIggCrnSSyi17b9oJHskSjf2N3jHvEHvMdxHnHWctyzv4BKHgc1PIWkVW2bHnHWMoTWMuytkSpVtcR8cBhrgcBcHfMWYQW3idneQtfHvEHTdclmHn4fnHUCilZLnbaYKVNkHMggCrnHnbgIvHFdgcLN9fHdSuY1rWWJHOHbxudllgIvHFdgQgzTrVdhimK69GENXqTl0bGNlamGe)6sWQucBFcBNyiv3Qfzc(3POGLsoCGLsozogEmeRc)gmua45cadiXpgIggCrnSS4alvNWfdpgIggCrnSSyi17b9oJHyv4BKHgc1PIWkVW2bmeRc)gmekJSWbwQoLddpgIvHFdgQu51KbK4hdrddUOgwwCGLQZoXWJHOHbxudllgs9EqVZyON3jDJYUYdHvEHT)WvyHjSGi5S2)BYiV(ju2NIWkVWcxTmWqSk8BWq(Ftg5XboWqOE47C43GHhlLCy4Xq0WGlQHLfdPEpO3zmKpQd1NDtJr5DYiJIW2NW6)nzK30yuENmbGNkaUvtyHjSGi5S2)BYiV(ju2NIWkVW2bHfoxybWLGWqSk8BWq(Ftg5XbwQoXWJHOHbxudllgs9EqVZyOGNu(SlSWewaeVca6AviSYlSWrzGHyv43GHEAOkEHdSuDadpgIggCrnSSyi17b9oJHcEs5ZUWctybq8kaORvHWkVWchLbgIvHFdgk)0ahCQzEANg65WVbhyP6pgEmenm4IAyzXqQ3d6Dgdf3((I0nkttX3OIWctybq8kaORvHWkVW2rGlgIvHFdgIhhLnx20ioaGdSuYadpgIggCrnSSyi17b9oJHskSDjSThXBAfhveVrgqIFHfMW2LW2EeVPVQvfXBKbK4xytiSPtlSSk8nYqdH6ury7dOW2jgIvHFdgIqRVk6nG30Wbwk4igEmenm4IAyzXqQ3d6DgdbIKZAqIFt(EunsTWctydEs5ZUWctybq8kaORvHWkVWcNKHWcty9rDO(SBAmkVtgzue2(ew4QLtyHZfwaeVcaAuwMIHyv43GHa5pvjLp4alfCcdpgIggCrnSSyi17b9oJHarYzDb538nEz8Pe(OIIUDvJWctybrYzni)PkP8r3UQryHjSaiEfa01QqyLxyHJWvyHjS(OouF2nngL3jJmkcBFclC1DkdHfoxybq8kaOrzzkgIvHFdgQG8B(gVm(ucFurbh4adv)K6qb5adpwk5WWJHyv43GHs5t7PMPu7Vhfmenm4IAyzXbwQoXWJHOHbxudllgs9EqVZyiqKCwR4WKVhvJulSWe22J4nTIJkI3idiXpgIvHFdgQ(VQfoWs1bm8yiAyWf1WYIHuVh07mgQlHfejN180TjFpQgPwyHjSjf2Ue22J4nTIJkI3idiXVWMoTWcIKZAfhM89O62vncBcHfMWMuy7syBpI30x1QI4nYas8lSPtlSGi5Sg9UjLpM89O62vncBcmeRc)gmeiXVjFpkoWs1Fm8yiAyWf1WYIHuVh07mgk4fnHgaXFyUSjaqMkF100WGlQjSWe2KcB7r8MwXrfXBKbK4xyHjSGi5SwXHjFpQgPwytNwyBpI30x1QI4nYas8lSWewqKCwJE3KYht(EunsTWMoTWcIKZA07Mu(yY3JQrQfwycBWlAcniV4rrgoN9XJU10WGlQjSjWqSk8BWqai(dZLnbaYu5RgoWsjdm8yiAyWf1WYIHuVh07mgcejN1O3nP8XKVhvJulSWe22J4n9vTQiEJmGe)yiwf(nyOQNda4ahyOv3k(zfgESuYHHhdXQWVbdP4WKVhfdrddUOgwwCGdmuJYmYkWWJLsom8yiwf(nyOskK1YaYfayiAyWf1WYIdSuDIHhdrddUOgwwmK69GENXqDjSGi5SU(VQLgPgdXQWVbdHuiJheAbhyP6agEmenm4IAyzXqQ3d6DgdLuytkSjf2Gx0eAae)H5YMaazQ8vttddUOMWctybrYznaI)WCztaGmv(QPrQf2eclmHnPW2EeVPvCur8gzaj(f20Pf22J4n9vTQiEJmGe)cBcHfMW2LWcIKZ66)QwAKAHnHWMoTWMuytkSGi5SgK(c9PmGe)AKAHnDAHfejN1(O4F4WVXSJWFZ5XCzdYxoLgPwytiSWe2KcBxcB7r8MwXrfXBKbK4xyHjSDjSThXB6RAvr8gzaj(f2ecBcHnbgIvHFdgQ(c)gCGLQ)y4Xq0WGlQHLfdPEpO3zmu7r8MwXrfXBKbK4xyHjSGi5SwXHjFpQgPgdXQWVbd9iJHvHFJz5LadT8syggLWqkoQiEJWbwkzGHhdrddUOgwwmK69GENXqThXB6RAvr8gzaj(fwyclisoRrVBs5JjFpQgPgdXQWVbd9iJHvHFJz5LadT8syggLWqx1QI4nchyPGJy4Xq0WGlQHLfdPEpO3zmusHnPW(idLVFN0RUv8ZftEru4ZUzF5O1fstYmeVUMAcBcHfMWMuydErtOb5fpkYW5SpE0TMggCrnHnHWctytkSGi5SE1TIFUyYlIcF2n7lhTUqAKAHnHWctytkSGi5SE1TIFUyYlIcF2n7lhTUq6NqzFkcR8af2of2ecBcmeRc)gm0Jmgwf(nMLxcm0YlHzyucdT6wXpF4alfCcdpgIggCrnSSyi17b9oJHskSjf2hzO897KE1TIFUyYlIcF2n7lhTUqAsMH411utytiSWe2KcBWlAcDMEEz4C2hp6wtddUOMWMqyHjSjfwqKCwV6wXpxm5frHp7M9LJwxinsTWMqyHjSjfwqKCwV6wXpxm5frHp7M9LJwxi9tOSpfHvEGcBNcBcHnbgIvHFdg6rgdRc)gZYlbgA5LWmmkHHwDR4Nv4alvhbdpgIggCrnSSyi17b9oJHkue(Sx0faEom57nQB2UuKWctytkSjf2Gx0eAqEXJImCo7JhDRPHbxutytiSWe2KcBxcB7r8MwXrfXBKbK4xytiSWe2KcBxcB7r8M(QwveVrgqIFHnHWctytkSQBJgEc947actMjHfMWQUB1UQrRUz7srMaazk1(7rr)ek7tryLhOWkNWMqytGHyv43GHEKXWQWVXS8sGHwEjmdJsyOtDZ2LIWbwkzogEmenm4IAyzXqQ3d6DgdvOi8zVOla8CyY3Bu3SDPiHfMWMuytkSbVOj0z65LHZzF8OBnnm4IAcBcHfMWMuy7syBpI30koQiEJmGe)cBcHfMWMuy7syBpI30x1QI4nYas8lSjewycBsHvDB0WtOhFhqyYmjSWew1DR2vnA1nBxkYeaitP2Fpk6NqzFkcR8afw5e2ecBcmeRc)gm0Jmgwf(nMLxcm0YlHzyucdPu3SDPiCGLso4IHhdrddUOgwwmeRc)gmKIxldRc)gZYlbgA5LWmmkHHq9W35WVbhyPKtom8yiAyWf1WYIHyv43GHEKXWQWVXS8sGHwEjmdJsyiqIFCGdmKIJkI3im8yPKddpgIvHFdgQ(VQfgIggCrnSS4alvNy4Xq0WGlQHLfdPEpO3zmuxclisoRvCyY3JQrQXqSk8BWqkom57rXbwQoGHhdrddUOgwwmK69GENXqGi5SU(VQLgPgdXQWVbd9CkchyP6pgEmenm4IAyzXqQ3d6Dgdf8IMqdG4pmx2eaitLVAAAyWf1ewycBxclisoRbq8hMlBcaKPYxnnsngIvHFdgcaXFyUSjaqMkF1WbwkzGHhdrddUOgwwmK69GENXqThXBAfhveVrgqIFmeRc)gmeHwFv0BaVPHdSuWrm8yiAyWf1WYIHuVh07mgQ9iEtR4OI4nYas8JHyv43GHu3SDPitaGmLA)9OGdSuWjm8yiAyWf1WYIHuVh07mgQDH(9A9t5NkayWfjSWew1HcEM6ZNOiS9buy7pgIvHFdg69ACGLQJGHhdrddUOgwwmK69GENXqQdf8m1Nprry7dOW2FmeRc)gmuM(t5hsXa6bHdSuYCm8yiAyWf1WYIHuVh07mgkPW2LW2UqZnUo8nYuQ4h10yuEN0HRs5ZUWcty7syzv43O5gxh(gzkv8JAAmkVtAFm5LVdiewycBsHTlHTDHMBCD4BKPuXpQbaXlD4Qu(SlSPtlSTl0CJRdFJmLk(rnaiEPFcL9PiS9jSDqytiSPtlSTl0CJRdFJmLk(rnngL3jDjyvkHvEHTdclmHTDHMBCD4BKPuXpQPXO8oPFcL9PiSYlSYqyHjSTl0CJRdFJmLk(rnngL3jD4Qu(SlSjWqSk8BWqCJRdFJmLk(rXbwk5GlgEmenm4IAyzXqQ3d6Dgd1Uq)Cks)u(PcagCrclmHvDOGNP(8jkcR8cB)XqSk8BWqpNIWbwk5KddpgIggCrnSSyi17b9oJHuhk4zQpFIIWkVWkdmeRc)gmubWtnCGdmK6Uv7QMcgESuYHHhdXQWVbdvFHFdgIggCrnSS4alvNy4XqSk8BWqGR7AMmY3ngIggCrnSS4alvhWWJHyv43GHaPVqFkF2Xq0WGlQHLfhyP6pgEmeRc)gme)kEitC)ttGHOHbxudlloWsjdm8yiwf(nyOLVdikg4miTDuAcmenm4IAyzXbwk4igEmeRc)gmu2FcCDxddrddUOgwwCGLcoHHhdXQWVbdXJIkXZlJIxlmenm4IAyzXbwQocgEmenm4IAyzXqQ3d6DgdbIKZAqIFt(EunsngIvHFdgc89sS8z3KrECGLsMJHhdrddUOgwwmK69GENXqjf22fA07MS)KoCvkF2f20Pfwwf(gzOHqDQiS9jSYjSjewycB7cDa45cadiXVoCvkF2XqSk8BWq(O4F4WVbhyPKdUy4XqSk8BWqG0xOpfgIggCrnSS4alLCYHHhdrddUOgwwmeRc)gmKQB16I)gxzaxCjWquotQWmmkHHuDRwx834kd4IlboWsjxNy4XqSk8BWqifY4bHwWq0WGlQHLfh4adDQB2UuegESuYHHhdXQWVbdHE3KYht(Eumenm4IAyzXbwQoXWJHyv43GHu3SDPitaGmLA)9OGHOHbxudlloWbgsPUz7sry4XsjhgEmeRc)gmKIdt(Eumenm4IAyzXbwQoXWJHyv43GHu3SDPitaGmLA)9OGHOHbxudlloWbg6QwveVry4XsjhgEmenm4IAyzXqQ3d6Dgd1LWcIKZA07Mu(yY3JQrQXqSk8BWqO3nP8XKVhfhyP6edpgIggCrnSSyi17b9oJHcErtObq8hMlBcaKPYxnnnm4IAclmHTlHfejN1ai(dZLnbaYu5RMgPgdXQWVbdbG4pmx2eaitLVA4alvhWWJHOHbxudllgs9EqVZyO2J4n9vTQiEJmGe)yiwf(nyicT(QO3aEtdhyP6pgEmenm4IAyzXqQ3d6Dgd1EeVPVQvfXBKbK4hdXQWVbdPUz7srMaazk1(7rbhyPKbgEmenm4IAyzXqQ3d6DgdLuy7syBxO5gxh(gzkv8JAAmkVt6WvP8zxyHjSDjSSk8B0CJRdFJmLk(rnngL3jTpM8Y3beclmHnPW2LW2UqZnUo8nYuQ4h1aG4LoCvkF2f20Pf22fAUX1HVrMsf)OgaeV0pHY(ue2(e2oiSje20Pf22fAUX1HVrMsf)OMgJY7KUeSkLWkVW2bHfMW2UqZnUo8nYuQ4h10yuEN0pHY(uew5fwziSWe22fAUX1HVrMsf)OMgJY7KoCvkF2f2eyiwf(nyiUX1HVrMsf)O4alfCedpgIggCrnSSyiwf(nyi07MS)egs9EqVZyONYpvaWGlsytNwybrYz9oVyv4kZoc)nNhnsngs1TArMG)DkkyPKdhyPGty4Xq0WGlQHLfdXQWVbdvqMS)egs9EqVZyONYpvaWGlcdP6wTitW)offSuYHdSuDem8yiAyWf1WYIHuVh07mgkPWcIKZAsT86czwid)AKAHnDAHfejN1KA51fYuUf)AKAHnbgIvHFdgQe8xq(DchyPK5y4Xq0WGlQHLfdPEpO3zmusHLulVUqAFmlKHFHnDAHLulVUq6YT43mKmne2ecB60cBsHLulVUqAFmlKHFHfMWcIKZ6sWFb53jdHwFv0Jstywid)AKAHnbgIvHFdgQe8N9NWbwk5GlgEmeRc)gmu1Zbamenm4IAyzXboWbgAJ(IFdwQoHBNWvUoHRmWqv8p(SxWqYeO13hutyLtoHLvHFJWU8su0IEyOsnPWsjhC7pgQ(VSVimu)ewzsi83CEe2oMhXBIE9ty7yifHcsVWcNKwy7eUDcxrprV(jSDCa8Stf4SIE9ty7OewzIrDF99CqcBhNdj6OVBs5JWw)(9E4uryt6zHTqr4ZUW6fHvbGuPOwcTOx)e2okHvMyu3xFphKWE1HFJWgNWwa45qytEVWoxKqybP89KW2XVz7srArprV(jSDSKPKcjOMWcs57jHvDOGCiSG0UpfTW2XwPO6OiSZnDua4hnJSewwf(nfH9Mv3Arpwf(nfD9tQdfKdjbkrkFAp1mLA)9Oi6XQWVPORFsDOGCijqjQ)RAjTNbcIKZAfhM89OAKAyThXBAfhveVrgqIFrpwf(nfD9tQdfKdjbkbiXVjFpQ0EgyxGi5SMNUn57r1i1Ws2v7r8MwXrfXBKbK4pDAqKCwR4WKVhv3UQjbSKD1EeVPVQvfXBKbK4pDAqKCwJE3KYht(EuD7QMeIESk8Bk66Nuhkihscucae)H5YMaazQ8vtApdm4fnHgaXFyUSjaqMkF100WGlQblz7r8MwXrfXBKbK4hgisoRvCyY3JQrQtNU9iEtFvRkI3idiXpmqKCwJE3KYht(EunsD60Gi5Sg9UjLpM89OAKAybVOj0G8Ihfz4C2hp6wtddUOwcrpwf(nfD9tQdfKdjbkr1ZbaP9mqqKCwJE3KYht(EunsnS2J4n9vTQiEJmGe)IEIE9ty7yjtjfsqnHL2OVBHnCusydaKWYQ4EH1lclVX(IbxKw0JvHFtbyjfYAza5carpwf(nfjbkbsHmEqOfP9mWUarYzD9FvlnsTOhRc)MIKaLO(c)gP9mWKjtg8IMqdG4pmx2eaitLVAAAyWf1GbIKZAae)H5YMaazQ8vtJuNawY2J4nTIJkI3idiXF60ThXB6RAvr8gzaj(taRlqKCwx)x1sJuNiD6KjbrYzni9f6tzaj(1i1PtdIKZAFu8pC43y2r4V58yUSb5lNsJuNawYUApI30koQiEJmGe)W6Q9iEtFvRkI3idiXFIeje96NWYQWVPijqjEKXWQWVXS8si9WOeqfhveVrs7zGThXBAfhveVrgqIFyjtQUB1UQrhaEUaWas8RFcL9P0hCHPUB1UQrJYZ(I0pHY(u6dUWAxOrVBY(t6NqzFk9bCx1KeUAza75Ds((dxyGi5S2hf)dh(nMDe(BopMlBq(YP0TRAGbIKZAq6l0NYas8RBx1adejN178IvHRm7i83CE0TRAsKoDsqKCwR4WKVhvJudJg637UVoLrI0Pt(idLVFN0hhamx2eaidTA0BApI30KmdXRRPgSUarYz9XbaZLnbaYqRg9M2J4nnsnSKGi5SwXHjFpQgPggn0V3DFDc3ejsNo5Jmu((DsFCaWCztaGm0QrVP9iEttYmeVUMAWarYznaI)WCztaGmv(QPFcL9PiVCWnbSKGi5SwXHjFpQgPggn0V3DFDc3ePtNuDB0WtOt1978atD3QDvJMqRVk6nG300pHY(uKhOCWyv4BKHgc1PI8DMiHOhRc)MIKaL4rgdRc)gZYlH0dJsavCur8gjTNb2EeVPvCur8gzaj(HbIKZAfhM89OAKArV(jSSk8BkscuIhzmSk8BmlVespmkb8QwveVrs7zGThXB6RAvr8gzaj(HLmP6Uv7QgDa45cadiXV(ju2NsFWfM6Uv7Qgnkp7ls)ek7tPp4c75Ds(oHlmqKCw7JI)Hd)gD7QgyGi5SgK(c9PmGe)62vnjsNojisoRrVBs5JjFpQgPgw7cDbzY(t6NYpvaWGlkr60jbrYzn6DtkFm57r1i1WarYznaI)WCztaGmv(QPrQtKoDsqKCwJE3KYht(EunsnSKGi5SMulVUqMfYWVgPoDAqKCwtQLxxit5w8RrQtaRRhzO897K(4aG5YMaazOvJEt7r8MMKziEDn1sKoDYhzO897K(4aG5YMaazOvJEt7r8MMKziEDn1G1fisoRpoayUSjaqgA1O30EeVPrQtKoDs1TrdpHE8DaHjZem1DR2vnA1nBxkYeaitP2Fpk6NqzFkYduUePtNuDB0WtOt1978atD3QDvJMqRVk6nG300pHY(uKhOCWyv4BKHgc1PI8DMiHOhRc)MIKaL4rgdRc)gZYlH0dJsaVQvfXBK0Egy7r8M(QwveVrgqIFyGi5Sg9UjLpM89OAKArpwf(nfjbkXJmgwf(nMLxcPhgLaU6wXpFs7zGjt(idLVFN0RUv8ZftEru4ZUzF5O1fstYmeVUMAjGLm4fnHgKx8OidNZ(4r3AAyWf1saljisoRxDR4NlM8IOWNDZ(YrRlKgPobSKGi5SE1TIFUyYlIcF2n7lhTUq6NqzFkYdSZeje9yv43uKeOepYyyv43ywEjKEyuc4QBf)SsApdmzYhzO897KE1TIFUyYlIcF2n7lhTUqAsMH411ulbSKbVOj0z65LHZzF8OBnnm4IAjGLeejN1RUv8ZftEru4ZUzF5O1fsJuNawsqKCwV6wXpxm5frHp7M9LJwxi9tOSpf5b2zIeIESk8BkscuIhzmSk8BmlVespmkb8u3SDPiP9mWcfHp7fDbGNdt(EJ6MTlfblzYGx0eAqEXJImCo7JhDRPHbxulbSKD1EeVPvCur8gzaj(talzxThXB6RAvr8gzaj(talP62OHNqp(oGWKzcM6Uv7QgT6MTlfzcaKPu7Vhf9tOSpf5bkxIeIESk8BkscuIhzmSk8BmlVespmkbuPUz7srs7zGfkcF2l6caphM89g1nBxkcwYKbVOj0z65LHZzF8OBnnm4IAjGLSR2J4nTIJkI3idiXFcyj7Q9iEtFvRkI3idiXFcyjv3gn8e6X3beMmtWu3TAx1Ov3SDPitaGmLA)9OOFcL9Pipq5sKq0JvHFtrsGsO41YWQWVXS8si9WOequp8Do8Be9yv43uKeOepYyyv43ywEjKEyuciiXVONOhRc)MIgK4hiiXVjFpQ0EgyxGi5SgK43KVhvJul6XQWVPObj(LeOepVrZHum5Ng4q3IESk8BkAqIFjbkH6MTlfzcaKPu7VhfP9mWUApI30koQiEJmGe)W6Q9iEtFvRkI3idiXVOhRc)MIgK4xsGsasFH(ugqIFP9mWKGi5S(5nAoKIj)0ah6wJuNoDxQBJgEc9gnbGU)eIESk8BkAqIFjbkHpk(ho8BK2ZatcIKZ6N3O5qkM8tdCOBnsD60DPUnA4j0B0ea6(ti6XQWVPObj(LeOeCJRdFJmLk(rL2Zat2v7cn346W3itPIFutJr5DshUkLp7W6IvHFJMBCD4BKPuXpQPXO8oP9XKx(oGawYUAxO5gxh(gzkv8JAaq8shUkLp7Pt3UqZnUo8nYuQ4h1aG4L(ju2NsFDir60Tl0CJRdFJmLk(rnngL3jDjyvk57aS2fAUX1HVrMsf)OMgJY7K(ju2NI8Yaw7cn346W3itPIFutJr5DshUkLp7je9yv43u0Ge)scuIaWZfagqIFPd(3PW4zGpLFQaGbxu60Tl0bGNlamGe)6sWQuY3H0Pt2UqhaEUaWas8RlbRsjF)H9idLVFN0lKCM9jJuOMHqbFwrAsMH411ulr60Sk8nYqdH6uPpG9x0JvHFtrds8ljqjqVBY(ts7zGjtcIKZ6DEXQWvMDe(BopAK6eWyv4BKHgc1PI8DMiD6KjbrYz9oVyv4kZoc)nNhnsDcyD1UqJE3K9N0HRs5Zomwf(gzOHqDQ0NCWc(3PqhokzIZ0CQp56mHOhRc)MIgK4xsGsGE3K9NK2Zat2UqJE3K9N0pHY(uKhyhGLeejN178IvHRm7i83CE0i1jGXQW3idneQtL(KbSG)Dk0HJsM4mnN6tUoti6XQWVPObj(LeOeO3nz)jP9mWKpLFQaGbxemwf(gzOHqDQiFNWc(3PqhokzIZ0CQp56mr60j7QDHg9Uj7pPdxLYNDySk8nYqdH6uPp5Gf8VtHoCuYeNP5uFY1zcrpwf(nfniXVKaLOu51K0EgiisoR9rX)WHFJzhH)MZJ5YgKVCkD7QgyGi5SgK(c9PmGe)62vnWyv4BKHgc1PsFa7VOhRc)MIgK4xsGsGYilP9mqqKCw7JI)Hd)gnsnmwf(gzOHqDQiFNIESk8BkAqIFjbkbkJSK2ZatcIKZ6cVX7KrDOGCWtOlbRs1hq5saljisoRJ7cagEAg1IR0i1jGbIKZAFu8pC43OrQHXQW3idneQtfGDk6XQWVPObj(LeOeO8SViP9mqqKCw7JI)Hd)gnsnmwf(gzOHqDQipWoi6XQWVPObj(LeOeOmYsApdmzYKGi5SoUlay4PzulUsxcwLQpGDMiD6KGi5SoUlay4PzulUsJuddejN1XDbadpnJAXv6NqzFkYlNwgjsNojisoRl8gVtg1HcYbpHUeSkvFa7qIeWyv4BKHgc1PI8DiHOhRc)MIgK4xsGseaEUaWas8lTNbYQW3idneQtL(Kt0JvHFtrds8ljqjq5zFrs7zGjt(8ojVmhUjGXQW3idneQtf57qI0PtM85Ds(oImsaJvHVrgAiuNkY3bybVOj0LdzzUSjaqM89uj00WGlQLq0JvHFtrds8ljqjQrwB07WbsAv3Qfzc(3POauoP9mW2f6aWZfagqIFDjyvQ(6u0JvHFtrds8ljqjcapxayaj(f9yv43u0Ge)scucugzjTNbYQW3idneQtf57GOhRc)MIgK4xsGsuQ8AYas8l6XQWVPObj(LeOe(Ftg5L2ZaFEN0nk7kpKV)WfgisoR9)MmYRFcL9PipC1Yq0t0RFclRc)MIKaLqXRLHvHFJz5Lq6HrjGOE47C43i61pHLvHFtrsGsu5RMrbG)Ds0RFclRc)MIKaLqXRLHvHFJz5Lq6HrjGQ7wTRAkIE9tyzv43uKeOeOmYsApd85Ds3OSR8q(oHlmwf(gzOHqDQiF)f96NWYQWVPijqjqzKL0Eg4Z7KUrzx5H8DcxyuPqJI0QBYlxfgEAMs8EM0OmCM7H1fisoRla4VMgQzulUQOrQf96NWYQWVPijqj8)MmYlTNbQUsaeUPtN85DQp1vcymCGEpi9I7MEQzq5H00WGlQbJvHVrgAiuNk91zcrV(jSSk8BkscuIAK1g9oCGKo4FNcJNb2UqhaEUaWas8RlbRsbSDHoa8CbGbK4xJYYutjyvQIOx)ewwf(nfjbkb6Dt2Fs6G)DkmEgy7cn6Dt2Fs)u(PcagCrWyv4BKHgc1PI8Dk61pHLvHFtrsGseaEUaqApdmjisoR9rX)WHFJUDvdmwf(gzOHqDQ0NCjsNojisoR9rX)WHFJgPggRcFJm0qOov6R)je96NWYQWVPijqjkvEnjTNbcIKZAFu8pC43OBx1aJvHVrgAiuNk91FrV(jSSk8BkscucuE2xK0Egy7cDa45cadiXVoCvkF2f96NWYQWVPijqjqVBY(tsh8VtHXZabrYz9oVyv4kZoc)nNhnsnmwf(gzOHqDQiFNIE9tyzv43uKeOebGNlae96NWktUVwcBLhae2o67MS)KWw5baHvMSl6OLPDk61pHLvHFtrsGsGE3K9NK2Zaz4a9Eq66RIEZLnbaYGE3OFEs1NCWyv4BKHgc1Pcq5e96NWYQWVPijqjkvEnj6j6XQWVPOr9W35WVbO)3KrEP9mqFuhQp7MgJY7KrgL(8)MmYBAmkVtMaWtfa3QbdejN1(Ftg51pHY(uKVdW5a4sqIESk8BkAup8Do8BKeOepnufVK2ZadEs5ZomaeVca6AvipCugIESk8BkAup8Do8BKeOe5Ng4GtnZt70qph(ns7zGbpP8zhgaIxbaDTkKhokdrpwf(nfnQh(oh(nscucECu2CztJ4aG0EgyC77ls3OmnfFJkWaq8kaORvH8De4k6XQWVPOr9W35WVrsGsqO1xf9gWBAs7zGj7Q9iEtR4OI4nYas8dRR2J4n9vTQiEJmGe)jsNMvHVrgAiuNk9bStrpwf(nfnQh(oh(nscucq(tvs5J0EgiisoRbj(n57r1i1WcEs5ZomaeVca6AvipCsgW8rDO(SBAmkVtgzu6dUA5GZbq8kaOrzzQOhRc)MIg1dFNd)gjbkrb538nEz8Pe(OII0EgiisoRli)MVXlJpLWhvu0TRAGbIKZAq(tvs5JUDvdmaeVca6AvipCeUW8rDO(SBAmkVtgzu6dU6oLbCoaIxbankltf9e9yv43u0Q7wTRAkaRVWVr0JvHFtrRUB1UQPijqjax31mzKVBrpwf(nfT6Uv7QMIKaLaK(c9P8zx0JvHFtrRUB1UQPijqj4xXdzI7FAcrpwf(nfT6Uv7QMIKaLy57aIIbodsBhLMq0JvHFtrRUB1UQPijqjY(tGR7AIESk8BkA1DR2vnfjbkbpkQepVmkETe9yv43u0Q7wTRAkscucW3lXYNDtg5L2ZabrYzniXVjFpQgPw0JvHFtrRUB1UQPijqj8rX)WHFJ0EgyY2fA07MS)KoCvkF2tNMvHVrgAiuNk9jxcyTl0bGNlamGe)6WvP8zx0JvHFtrRUB1UQPijqjaPVqFkrpwf(nfT6Uv7QMIKaLaPqgpiuPPCMuHzyucOQB16I)gxzaxCje9yv43u0Q7wTRAkscucKcz8GqlIEIESk8BkAfhveVraR)RAj6XQWVPOvCur8gjjqjuCyY3JkTNb2fisoRvCyY3JQrQf9yv43u0koQiEJKeOepNIK2ZabrYzD9FvlnsTOhRc)MIwXrfXBKKaLaaXFyUSjaqMkF1K2ZadErtObq8hMlBcaKPYxnnnm4IAW6cejN1ai(dZLnbaYu5RMgPw0JvHFtrR4OI4nssGsqO1xf9gWBAs7zGThXBAfhveVrgqIFrpwf(nfTIJkI3ijbkH6MTlfzcaKPu7VhfP9mW2J4nTIJkI3idiXVOhRc)MIwXrfXBKKaL49AP9mW2f63R1pLFQaGbxem1HcEM6ZNO0hW(l6XQWVPOvCur8gjjqjY0Fk)qkgqpiP9mq1HcEM6ZNO0hW(l6XQWVPOvCur8gjjqj4gxh(gzkv8JkTNbMSR2fAUX1HVrMsf)OMgJY7KoCvkF2H1fRc)gn346W3itPIFutJr5Ds7JjV8DabSKD1UqZnUo8nYuQ4h1aG4LoCvkF2tNUDHMBCD4BKPuXpQbaXl9tOSpL(6qI0PBxO5gxh(gzkv8JAAmkVt6sWQuY3byTl0CJRdFJmLk(rnngL3j9tOSpf5LbS2fAUX1HVrMsf)OMgJY7KoCvkF2ti6XQWVPOvCur8gjjqjEofjTNb2Uq)Cks)u(PcagCrWuhk4zQpFII89x0JvHFtrR4OI4nssGsua8utApduDOGNP(8jkYldrprpwf(nfTsDZ2LIaQ4WKVhv0JvHFtrRu3SDPijbkH6MTlfzcaKPu7Vhfrprpwf(nf9QBf)ScOIdt(Eurprpwf(nf9QBf)8be9UjLpM89OIEIESk8Bk6tDZ2LIaIE3KYht(Eurpwf(nf9PUz7srscuc1nBxkYeaitP2FpkIEIESk8Bk6RAvr8gbe9UjLpM89Os7zGDbIKZA07Mu(yY3JQrQf9yv43u0x1QI4nssGsaG4pmx2eaitLVAs7zGbVOj0ai(dZLnbaYu5RMMggCrnyDbIKZAae)H5YMaazQ8vtJul6XQWVPOVQvfXBKKaLGqRVk6nG30K2ZaBpI30x1QI4nYas8l6XQWVPOVQvfXBKKaLqDZ2LImbaYuQ93JI0Egy7r8M(QwveVrgqIFrpwf(nf9vTQiEJKeOeCJRdFJmLk(rL2Zat2v7cn346W3itPIFutJr5DshUkLp7W6IvHFJMBCD4BKPuXpQPXO8oP9XKx(oGawYUAxO5gxh(gzkv8JAaq8shUkLp7Pt3UqZnUo8nYuQ4h1aG4L(ju2NsFDir60Tl0CJRdFJmLk(rnngL3jDjyvk57aS2fAUX1HVrMsf)OMgJY7K(ju2NI8Yaw7cn346W3itPIFutJr5DshUkLp7je9yv43u0x1QI4nssGsGE3K9NKw1TArMG)DkkaLtApd8P8tfam4IsNgejN178IvHRm7i83CE0i1IESk8Bk6RAvr8gjjqjkit2FsAv3Qfzc(3POauoP9mWNYpvaWGls0JvHFtrFvRkI3ijbkrj4VG87K0EgysqKCwtQLxxiZcz4xJuNonisoRj1YRlKPCl(1i1je9yv43u0x1QI4nssGsuc(Z(ts7zGjj1YRlK2hZcz4pDAsT86cPl3IFZqY0ir60jj1YRlK2hZcz4hgisoRlb)fKFNmeA9vrpknHzHm8RrQti6XQWVPOVQvfXBKKaLO65aaoWbgd]] )

end