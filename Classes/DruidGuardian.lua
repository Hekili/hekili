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

    spec:RegisterPack( "Guardian", 20201126, [[dOupobqijOhPiLlPGcAtqXNuqHAuukNIs1QuKQ6veKzrqDlfPkTlk(fuYWiqDmcLLPi5zecttbvxtcyBsG6BsGyCeI05uqjRJqu18iuDpf1(iqoOeiLfsi9qfuQjQGcCrfuiBucKuFubf1jjevwPIyMsGuDtfuKDsadvcKKLkbs4PGmvOuFvcKO9c5VKAWcomQfd0JjAYs6YiBwkFgqJgGtt1QvKQ41kWSLQBdv7wPFRYWLOJtiklxvpxOPl66GA7k03PKXtiIZRGSEfPY8Lq7NKrIHWgbv5KqcmLGNsWIj2ufSrWI0HlMyfabLdvsiOswoGbsiOLXje0Wmm)vNxeujpu)4kcBeu8GFjHGaKzzuKhlSa6jayqJ8WXk64WDo9BLp3sSIoUeleeiS3trUfbIGQCsibMsWtjyXeBQc2iyr6WftWfeeedNaUhbb54dBeeaVwPfbIGQuuIGMMkmmdZF15vfgg8WEvnzAQGa3iHdsVkmvblSkmLGNsWQjQjttfg2a4fiff5vtMMkm9QcICR8(Y75KuHHnNynmD3oWxvO89790POkyZBQqKY0xGQGhvbjasoGQ2niOUhZicBeuFij)8HWgjGyiSrqSm9Brq43Td8v3Uhhbrld2PksuuIseeiXpcBKaIHWgbrld2PksueK89KENrqfQcGWTMbK4x3Uh3axIGyz63IGaj(1T7XrjsGPqyJGyz63IGEEK2doQBpTt3qiiAzWovrIIsKaIaHncIwgStvKOii57j9oJGkufQpSxnsoTiEK0Ge)QagvOqvO(WE1CwDlIhjniXpcILPFlcsE74nG0jashl93ZikrcmCe2iiAzWovrIIGKVN07mcYMkac3AMNhP9GJ62t70nKbUufkwufkufK3iT8MMrAtad9QGDeelt)weei9r6hGsKafaHncIwgStvKOii57j9oJGSPcGWTM55rAp4OU90oDdzGlvHIfvHcvb5nslVPzK2eWqVkyhbXY0Vfb5RK)Lt)wuIeOGryJGOLb7ufjkcs(EsVZiiBQqHQq9sdx5Y0hjD0IFCDLXzGKjD5aFbQcyuHcvbwM(TgUYLPps6Of)46kJZajJV6w3bcivbmQGnvOqvOEPHRCz6JKoAXpUgaXDt6Yb(cufkwufQxA4kxM(iPJw8JRbqC38eo7BufeKkicvWUkuSOkuV0WvUm9rshT4hxxzCgizIjlhOcIRcIqfWOc1lnCLltFK0rl(X1vgNbsMNWzFJQG4QqbubmQq9sdx5Y0hjD0IFCDLXzGKjD5aFbQc2rqSm9BrqCLltFK0rl(XrjsGcccBeeTmyNQirrqY3t6DgbztfaHBndqUZY0LAGW8xDEnWLQagvO(WE1CwDlIhjniXVkyxfWOcSm9rstlH7uufeFwfebcILPFlcc)UT5pHsKaIue2iiAzWovrIIGyz63IGsaphbObj(rqY3t6Dgb9u7PiagStQqXIQq9stc45ianiXVjMSCGkiUkicvOyrvWMkuV0KaEocqds8BIjlhOcIRcdxfWOcp8sT7bsMoCRX(2GJuvt4GpljdjYG9YsQQc2vHIfvbwM(iPPLWDkQccAwfgocsoKSt6KFGugrcigkrcmSqyJGOLb7ufjkcs(EsVZiiq4wZ4RK)Lt)wnqy(RoV6RPH)4jn1ZAvbmQaiCRzaPps)aniXVPEwRkGrfyz6JKMwc3POkiOzvy4iiwM(TiOOLxsAqIFuIeqmbJWgbrld2PksueK89KENrqGWTMXxj)lN(Tg4svaJkWY0hjnTeUtrvqCvykeelt)weeod3rjsaXedHncIwgStvKOii57j9oJGSPcGWTMjYJmqslpCqo5nnXKLdubbnRcIPc2vbmQGnvaeU1m5DjanVvTSZwg4svWUkGrfaHBnJVs(xo9BnWLQagvGLPpsAAjCNIQWSkmfcILPFlccNH7OejGytHWgbrld2PksueK89KENrqGWTMXxj)lN(Tg4svaJkWY0hjnTeUtrvq8zvqeiiwM(TiiCEb2juIeqmrGWgbrld2Pksueelt)wee(DBZFcbjFpP3ze0tTNIayWoPcyubwM(iPPLWDkQcIpRcIabjhs2jDYpqkJibedLibeB4iSrq0YGDQIefbjFpP3zeKnvWMkytfaHBntExcqZBvl7SLjMSCGkiOzvykvWUkuSOkytfaHBntExcqZBvl7SLbUufWOcGWTMjVlbO5TQLD2Y8eo7BufexfeZuavWUkuSOkytfaHBntKhzGKwE4GCYBAIjlhOccAwfeHkyxfSRcyubwM(iPPLWDkQcIRcIqfSJGyz63IGWz4okrciwbqyJGOLb7ufjkcs(EsVZiiwM(iPPLWDkQccsfedbXY0VfbLaEocqds8JsKaIvWiSrq0YGDQIefbjFpP3zeKnvaeU1ma5oltxQbcZF151axQcyuH6d7vJKtlIhjniXVkyxfWOcSm9rstlH7uufeFwfeHkuSOkytfaHBndqUZY0LAGW8xDEnWLQagvOqvO(WE1i50I4rsds8RcyuHcvH6d7vZz1TiEK0Ge)QGDvaJkWY0hjnTeUtrvq8zvqeiiwM(Tii872M)ekrciwbbHncIwgStvKOii57j9oJGSPc2uHNbsQG4QWWsWQGDvaJkWY0hjnTeUtrvqCvqeQGDvOyrvWMkytfEgiPcIRcI0cOc2vbmQaltFK00s4ofvbXvbrOcyuHK70MM4b31xtNaiD7EkMgAzWovvb7iiwM(TiiCEb2juIeqmrkcBeeTmyNQirrqSm9BrqLW9r69PJqqY3t6DgbvV0KaEocqds8BIjlhOccsfMcbjhs2jDYpqkJibedLibeByHWgbXY0VfbLaEocqds8JGOLb7ufjkkrcmLGryJGOLb7ufjkcs(EsVZiiwM(iPPLWDkQcIRcIabXY0VfbHZWDuIeykXqyJGyz63IGIwEjPbj(rq0YGDQIefLibMAke2iiAzWovrIIGKVN07mc6zGKPsnx6PkiUkmCbRcyubq4wZ4)Tn438eo7BufexfeSPaiiwM(Tii)VTb)OeLiiCpDGC63IWgjGyiSrq0YGDQIefbjFpP3zeKVYd3xG6kJZajDbIQGGub)VTb)6kJZajDc4PiGRxvbmQaiCRz8)2g8BEcN9nQcIRcIqfM(QaaoMecILPFlcY)BBWpkrcmfcBeeTmyNQirrqY3t6DgbL8oWxGQagvaaX9eGPuMQG4Qqbxaeelt)we0tlzXDuIeqeiSrq0YGDQIefbjFpP3zeuY7aFbQcyubae3taMszQcIRcfCbqqSm9BrqTN2PZPQ(jG0spN(TOejWWryJGOLb7ufjkcs(EsVZiO8acStMk1On6JuufWOcaiUNamLYufexfePcgbXY0VfbXRJZ6RPReNaqjsGcGWgbrld2PksueK89KENrq2uHcvH6d7vJKtlIhjniXVkGrfkufQpSxnNv3I4rsds8Rc2vHIfvbwM(iPPLWDkQccAwfMcbXY0Vfbr4LNf9AWBROejqbJWgbrld2PksueK89KENrq2uHK70MgWNXb7u0qld2PQkyxfWOc2ubq4wZas8RB3JBGlvb7Qagvi5DGVavbmQaaI7jatPmvbXvHcsbubmQGVYd3xG6kJZajDbIQGGubbBetfM(QaaI7jadolsqqSm9BrqG8pioWxuIeOGGWgbrld2PksueK89KENrqGWTMjc)J(i31(gtFLz0upRvfWOcGWTMbK)bXb(AQN1Qcyubae3taMszQcIRcfSGvbmQGVYd3xG6kJZajDbIQGGubbBMQaQW0xfaqCpbyWzrccILPFlckc)J(i31(gtFLzeLOebv(K8Wb5eHnsaXqyJGyz63IGg4B9PQow6VNreeTmyNQirrjsGPqyJGOLb7ufjkcs(EsVZiiq4wZi5u3Uh3axQcyuH6d7vJKtlIhjniXpcILPFlcQ8pRokrcice2iiAzWovrIIGKVN07mcQqvaeU1m8oKUDpUbUufWOc2uHcvH6d7vJKtlIhjniXVkuSOkac3AgjN6294M6zTQGDvaJkytfkufQpSxnNv3I4rsds8RcflQcGWTMb)UDGV6294M6zTQGDeelt)weeiXVUDpokrcmCe2iiAzWovrIIGKVN07mck5oTPbaXFQVMobqAlVxn0YGDQQcyubBQq9H9QrYPfXJKgK4xfWOcGWTMrYPUDpUbUufkwufQpSxnNv3I4rsds8Rcyubq4wZGF3oWxD7ECdCPkuSOkac3Ag872b(QB3JBGlvbmQqYDAtdi35vsAU181ZHm0YGDQQc2rqSm9Brqai(t910jasB59kkrcuae2iiAzWovrIIGKVN07mcceU1m43Td8v3Uh3axQcyuH6d7vZz1TiEK0Ge)iiwM(TiiRNtaOeLiO(qs(zjcBKaIHWgbXY0Vfbj5u3Uhhbrld2PksuuIseuLAmCpryJeqme2iiwM(TiO4a4ExdYraiiAzWovrIIsKatHWgbrld2PksueK89KENrqfQcGWTMP8pRUbUebXY0VfbbhjTNeEeLibebcBeeTmyNQirrqY3t6DgbztfSPc2uHK70Mgae)P(A6eaPT8E1qld2PQkGrfaHBndaI)uFnDcG0wEVAGlvb7QagvWMkuFyVAKCAr8iPbj(vHIfvH6d7vZz1TiEK0Ge)QGDvaJkuOkac3AMY)S6g4svWUkuSOkytfSPcGWTMbK(i9d0Ge)g4svOyrvaeU1m(k5F50VvdeM)QZR(AA4pEsdCPkyxfWOc2uHcvH6d7vJKtlIhjniXVkGrfkufQpSxnNv3I4rsds8Rc2vb7QGDeelt)weu5L(TOejWWryJGOLb7ufjkcs(EsVZiO6d7vJKtlIhjniXVkGrfaHBnJKtD7ECdCjcILPFlc6Hxnlt)wD3JjcQ7XuVmoHGKCAr8iHsKafaHncIwgStvKOii57j9oJGQpSxnNv3I4rsds8Rcyubq4wZGF3oWxD7ECdCjcILPFlc6Hxnlt)wD3JjcQ7XuVmoHGoRUfXJekrcuWiSrq0YGDQIefbjFpP3zeKnvWMk8Wl1Uhiz6dj5NJ6wNO0xGAGDhVmsgsKb7LLuvfSRcyubBQqYDAtdi35vsAU181ZHm0YGDQQc2vbmQGnvaeU1m9HK8ZrDRtu6lqnWUJxgjdCPkyxfWOc2ubq4wZ0hsYph1TorPVa1a7oEzKmpHZ(gvbXNvHPub7QGDeelt)we0dVAwM(T6Uhteu3JPEzCcb1hsYpFOejqbbHncIwgStvKOii57j9oJGSPc2uHhEP29ajtFij)Cu36eL(cudS74LrYqImyVSKQQGDvaJkytfsUtBAA0ZDn3A(65qgAzWovvb7QagvWMkac3AM(qs(5OU1jk9fOgy3XlJKbUufSRcyubBQaiCRz6dj5NJ6wNO0xGAGDhVmsMNWzFJQG4ZQWuQGDvWocILPFlc6Hxnlt)wD3JjcQ7XuVmoHG6dj5NLOejGifHncIwgStvKOii57j9oJGSPc2uHK70MgqUZRK0CR5RNdzOLb7uvfSRcyubBQqHQq9H9QrYPfXJKgK4xfSRcyubBQqHQq9H9Q5S6wepsAqIFvWUkGrfSPcYBKwEtZ6abK6gtQagvqExVEwRrE74nG0jashl93ZO5jC23Oki(SkiMkyxfSJGyz63IGE4vZY0Vv39yIG6Em1lJtiOtE74nGqjsGHfcBeeTmyNQirrqY3t6DgbztfSPcj3Pnnn65UMBnF9CidTmyNQQGDvaJkytfkufQpSxnsoTiEK0Ge)QGDvaJkytfkufQpSxnNv3I4rsds8Rc2vbmQGnvqEJ0YBAwhiGu3ysfWOcY761ZAnYBhVbKobq6yP)EgnpHZ(gvbXNvbXub7QGDeelt)we0dVAwM(T6Uhteu3JPEzCcbjL3oEdiuIeqmbJWgbrld2Pksueelt)weKK7Dnlt)wD3JjcQ7XuVmoHGW90bYPFlkrciMyiSrq0YGDQIefbXY0Vfb9WRMLPFRU7Xeb19yQxgNqqGe)OeLiijNwepsiSrcigcBeelt)weu5FwDeeTmyNQirrjsGPqyJGOLb7ufjkcs(EsVZiOcvbq4wZi5u3Uh3axIGyz63IGKCQB3JJsKaIaHncIwgStvKOii57j9oJGaHBnt5FwDdCjcILPFlc65bekrcmCe2iiAzWovrIIGKVN07mck5oTPbaXFQVMobqAlVxn0YGDQQcyuHcvbq4wZaG4p1xtNaiTL3Rg4seelt)weeaI)uFnDcG0wEVIsKafaHncIwgStvKOii57j9oJGQpSxnsoTiEK0Ge)iiwM(TiicV8SOxdEBfLibkye2iiAzWovrIIGKVN07mcQ(WE1i50I4rsds8JGyz63IGK3oEdiDcG0Xs)9mIsKafee2iiAzWovrIIGKVN07mcQEP59sZtTNIayWoPcyub5HdE6YZ3mQccAwfgocILPFlc69suIeqKIWgbrld2PksueK89KENrqYdh80LNVzufe0SkmCeelt)weuJ(t6hCud6jHsKadle2iiAzWovrIIGKVN07mcYMkuOkuV0WvUm9rshT4hxxzCgizsxoWxGQagvOqvGLPFRHRCz6JKoAXpUUY4mqY4RU1DGasvaJkytfkufQxA4kxM(iPJw8JRbqC3KUCGVavHIfvH6LgUYLPps6Of)4Aae3npHZ(gvbbPcIqfSRcflQc1lnCLltFK0rl(X1vgNbsMyYYbQG4QGiubmQq9sdx5Y0hjD0IFCDLXzGK5jC23OkiUkuavaJkuV0WvUm9rshT4hxxzCgizsxoWxGQGDeelt)weex5Y0hjD0IFCuIeqmbJWgbrld2PksueK89KENrq1lnppGmp1EkcGb7KkGrfKho4PlpFZOkiUkmCeelt)we0ZdiuIeqmXqyJGOLb7ufjkcs(EsVZii5HdE6YZ3mQcIRcfabXY0Vfbfb8ufLOebjVRxpRnIWgjGyiSrqSm9BrqLx63IGOLb7ufjkkrcmfcBeelt)weeaI)utXiTscbrld2PksuuIeqeiSrqSm9BrqG97Q6g8pecIwgStvKOOejWWryJGyz63IGaPps)aFbIGOLb7ufjkkrcuae2iiwM(Tii(L8s68(N2ebrld2PksuuIeOGryJGyz63IG6oqazup9axbItBIGOLb7ufjkkrcuqqyJGyz63IGA(tG97QiiAzWovrIIsKaIue2iiwM(TiiELumFURLCVJGOLb7ufjkkrcmSqyJGOLb7ufjkcs(EsVZiiq4wZas8RB3JBGlrqSm9BrqGVhZUVa1n4hLibetWiSrq0YGDQIefbjFpP3zeKnvOEPb)UT5pzsxoWxGQqXIQaltFK00s4ofvbbPcIPc2vbmQq9stc45ianiXVjD5aFbIGyz63IG8vY)YPFlkrciMyiSrqSm9BrqG0hPFacIwgStvKOOejGytHWgbrld2Pksueelt)weKCiz)Y)wxQb7CmrquRrYuVmoHGKdj7x(36snyNJjkrciMiqyJGOLb7ufjkcs(EsVZiO8acStg5D96zTrvaJkytfshN05PRoPcIRcSm9B1Y761ZAvbSuHPuHIfvbwM(iPPLWDkQccsfetfSJGyz63IG41Xz910vItaOejGydhHncILPFlccNWVFi910DyPx11Ny8icIwgStvKOOejGyfaHncILPFlccosApj8icIwgStvKOOeLiOtE74nGqyJeqme2iiwM(Tii872b(QB3JJGOLb7ufjkkrcmfcBeelt)weK82XBaPtaKow6VNreeTmyNQirrjkrqs5TJ3acHnsaXqyJGyz63IGKCQB3JJGOLb7ufjkkrcmfcBeelt)weK82XBaPtaKow6VNreeTmyNQirrjkrqNv3I4rcHnsaXqyJGOLb7ufjkcs(EsVZiOcvbq4wZGF3oWxD7ECdCjcILPFlcc)UDGV6294OejWuiSrq0YGDQIefbjFpP3zeuYDAtdaI)uFnDcG0wEVAOLb7uvfWOcfQcGWTMbaXFQVMobqAlVxnWLiiwM(Tiiae)P(A6eaPT8EfLibebcBeeTmyNQirrqY3t6DgbvFyVAoRUfXJKgK4hbXY0Vfbr4LNf9AWBROejWWryJGOLb7ufjkcs(EsVZiO6d7vZz1TiEK0Ge)iiwM(Tii5TJ3asNaiDS0FpJOejqbqyJGOLb7ufjkcs(EsVZiiBQqHQq9sdx5Y0hjD0IFCDLXzGKjD5aFbQcyuHcvbwM(TgUYLPps6Of)46kJZajJV6w3bcivbmQGnvOqvOEPHRCz6JKoAXpUgaXDt6Yb(cufkwufQxA4kxM(iPJw8JRbqC38eo7BufeKkicvWUkuSOkuV0WvUm9rshT4hxxzCgizIjlhOcIRcIqfWOc1lnCLltFK0rl(X1vgNbsMNWzFJQG4QqbubmQq9sdx5Y0hjD0IFCDLXzGKjD5aFbQc2rqSm9BrqCLltFK0rl(XrjsGcgHncIwgStvKOiiwM(Tii872M)ecs(EsVZiONApfbWGDsfkwufaHBndqUZY0LAGW8xDEnWLii5qYoPt(bszejGyOejqbbHncIwgStvKOiiwM(TiOi828NqqY3t6Dgb9u7PiagStii5qYoPt(bszejGyOejGifHncIwgStvKOii57j9oJGSPcGWTMHKDVms6o8YVbUufkwufaHBndj7EzK0XRZVbUufSJGyz63IGIj)r4hiHsKadle2iiAzWovrIIGKVN07mcYMkqYUxgjJV6o8YVkuSOkqYUxgjt868RxsKKQGDvOyrvWMkqYUxgjJV6o8YVkGrfaHBntm5pc)ajnHxEw0JtBQ7Wl)g4svWocILPFlckM838NqjsaXemcBeelt)weK1ZjaeeTmyNQirrjkrjcAK(OFlsGPe8ucwmXMA4gXqqw8V(cmIGkOSGwbfciYjWWSiVkOcydGubhV8(ufA3RcdJL31RN1ghgRcpjYG9NQQq8WjvGHZdNtQQcsa8cKIg1Kc6(sQGyIqKxfg23osFsvvaYXh2QqCOnzrIkmmufYtfkOdZQq1h9OFRkCL0Z59QGnSSRc2etKy3OMOMiYHxEFsvvqmXubwM(TQq3Jz0OMGGILKejGycE4iOY)AENqqttfgMH5V68QcddEyVQMmnvqGBKWbPxfMQGfwfMsWtjy1e1KPPcdBa8cKII8QjttfMEvbrUvEF59CsQWWMtSgMUBh4Rku((9E6uufS5nvisz6lqvWJQGeajhqv7g1e1KPPcdJejKeoPQkasT7jvqE4GCQcGeqFJgvOGMusLzuf2BNEbWpEdURcSm9BJQWT9HmQjSm9BJMYNKhoiNcnJ1aFRpv1Xs)9mQMWY0VnAkFsE4GCk0mwL)z1f2BZGWTMrYPUDpUbUet9H9QrYPfXJKgK4xnHLPFB0u(K8Wb5uOzSaj(1T7Xf2BZfcc3AgEhs3Uh3axIXwH1h2RgjNwepsAqI)IfbHBnJKtD7ECt9Sw7ySvy9H9Q5S6wepsAqI)IfbHBnd(D7aF1T7Xn1ZATRMWY0VnAkFsE4GCk0mwai(t910jasB59QWEBo5oTPbaXFQVMobqAlVxn0YGDQIXw9H9QrYPfXJKgK4hdiCRzKCQB3JBGllwS(WE1CwDlIhjniXpgq4wZGF3oWxD7ECdCzXIGWTMb)UDGV6294g4smj3PnnGCNxjP5wZxphYqld2PQD1ewM(Trt5tYdhKtHMXY65eGWEBgeU1m43Td8v3Uh3axIP(WE1CwDlIhjniXVAIAY0uHHrIescNuvfOr6hsfshNuHeaPcSmVxf8OkWJS3zWozutyz63gNJdG7DnihbOMWY0Vnk0mwWrs7jHhf2BZfcc3AMY)S6g4s1ewM(TrHMXQ8s)wH92SnB2sUtBAaq8N6RPtaK2Y7vdTmyNQyaHBndaI)uFnDcG0wEVAGlTJXw9H9QrYPfXJKgK4VyX6d7vZz1TiEK0Ge)2XuiiCRzk)ZQBGlTxSOnBGWTMbK(i9d0Ge)g4YIfbHBnJVs(xo9B1aH5V68QVMg(JN0axAhJTcRpSxnsoTiEK0Ge)ykS(WE1CwDlIhjniXVD72vtMMkWY0Vnk0mwp8Qzz63Q7EmfEzCAwYPfXJKWEBU(WE1i50I4rsds8JXMn5D96zTMeWZraAqIFZt4SVrbjymY761ZAn48cStMNWzFJcsWyQxAWVBB(tMNWzFJcAgOSkKGnfaZZajXhUGXac3AgFL8VC63QbcZF15vFnn8hpPPEwlgq4wZasFK(bAqIFt9SwmGWTMbi3zz6snqy(RoVM6zT2lw0giCRzKCQB3JBGlXql9ahsqtva7flA7HxQDpqYCCcqFnDcG0uVsVU(WE1qImyVSKQykeeU1mhNa0xtNain1R0RRpSxnWLySbc3AgjN6294g4sm0spWHe0uc2U9IfT9Wl1UhizoobOVMobqAQxPxxFyVAirgSxwsvmGWTMbaXFQVMobqAlVxnpHZ(gfxmbBhJnq4wZi5u3Uh3axIHw6boKGMsW2lw0M8gPL30myO35fJ8UE9SwdHxEw0RbVTAEcN9nk(Syyyz6JKMwc3PO4tz3UAclt)2OqZy9WRMLPFRU7Xu4LXPzjNwepsc7T56d7vJKtlIhjniXpgq4wZi5u3Uh3axQMmnvGLPFBuOzSE4vZY0Vv39yk8Y408z1TiEKe2BZ1h2RMZQBr8iPbj(XyZM8UE9Swtc45ianiXV5jC23OGemg5D96zTgCEb2jZt4SVrbjympdKeFkbJbeU1m(k5F50V1upRfdiCRzaPps)aniXVPEwR9IfTbc3Ag872b(QB3JBGlXuV0eH3M)K5P2tramyNSxSOnq4wZGF3oWxD7ECdCjgq4wZaG4p1xtNaiTL3Rg4s7flAdeU1m43Td8v3Uh3axIXgiCRziz3lJKUdV8BGllweeU1mKS7LrshVo)g4s7yk8HxQDpqYCCcqFnDcG0uVsVU(WE1qImyVSKQ2lw02dVu7EGK54eG(A6eaPPELED9H9QHezWEzjvXuiiCRzoobOVMobqAQxPxxFyVAGlTxSOn5nslVPzDGasDJjmY761ZAnYBhVbKobq6yP)EgnpHZ(gfFwm7flAtEJ0YBAgm078IrExVEwRHWlpl61G3wnpHZ(gfFwmmSm9rstlH7uu8PSBxnHLPFBuOzSE4vZY0Vv39yk8Y408z1TiEKe2BZ1h2RMZQBr8iPbj(Xac3Ag872b(QB3JBGlvtyz63gfAgRhE1Sm9B1DpMcVmon3hsYpFc7TzB2E4LA3dKm9HK8ZrDRtu6lqnWUJxgjdjYG9YsQAhJTK70MgqUZRK0CR5RNdzOLb7u1ogBGWTMPpKKFoQBDIsFbQb2D8YizGlTJXgiCRz6dj5NJ6wNO0xGAGDhVmsMNWzFJIppLD7QjSm9BJcnJ1dVAwM(T6UhtHxgNM7dj5NLc7TzB2E4LA3dKm9HK8ZrDRtu6lqnWUJxgjdjYG9YsQAhJTK70MMg9CxZTMVEoKHwgStv7ySbc3AM(qs(5OU1jk9fOgy3XlJKbU0ogBGWTMPpKKFoQBDIsFbQb2D8YizEcN9nk(8u2TRMWY0Vnk0mwp8Qzz63Q7EmfEzCA(K3oEdiH92SnBj3PnnGCNxjP5wZxphYqld2PQDm2kS(WE1i50I4rsds8BhJTcRpSxnNv3I4rsds8BhJn5nslVPzDGasDJjmY761ZAnYBhVbKobq6yP)EgnpHZ(gfFwm72vtyz63gfAgRhE1Sm9B1DpMcVmonlL3oEdiH92SnBj3Pnnn65UMBnF9CidTmyNQ2XyRW6d7vJKtlIhjniXVDm2kS(WE1CwDlIhjniXVDm2K3iT8MM1bci1nMWiVRxpR1iVD8gq6eaPJL(7z08eo7Bu8zXSBxnHLPFBuOzSKCVRzz63Q7EmfEzCAg3thiN(TQjSm9BJcnJ1dVAwM(T6UhtHxgNMbj(vtutyz63gnGe)ZGe)6294c7T5cbHBndiXVUDpUbUunHLPFB0as8l0mwpps7bh1TN2PBi1ewM(TrdiXVqZyjVD8gq6eaPJL(7zuyVnxy9H9QrYPfXJKgK4htH1h2RMZQBr8iPbj(vtyz63gnGe)cnJfi9r6hObj(f2BZ2aHBnZZJ0EWrD7PD6gYaxwSyHYBKwEtZiTjGHE7QjSm9BJgqIFHMXYxj)lN(Tc7TzBGWTM55rAp4OU90oDdzGllwSq5nslVPzK2eWqVD1ewM(TrdiXVqZyXvUm9rshT4hxyH92STcRxA4kxM(iPJw8JRRmodKmPlh4lqmfYY0V1WvUm9rshT4hxxzCgiz8v36oqajgBfwV0WvUm9rshT4hxdG4UjD5aFbwSy9sdx5Y0hjD0IFCnaI7MNWzFJcse2lwSEPHRCz6JKoAXpUUY4mqYetwoqCrGPEPHRCz6JKoAXpUUY4mqY8eo7Bu8cGPEPHRCz6JKoAXpUUY4mqYKUCGVaTRMWY0VnAaj(fAgl872M)KWEB2giCRzaYDwMUudeM)QZRbUet9H9Q5S6wepsAqIF7yyz6JKMwc3PO4ZIqnHLPFB0as8l0mwjGNJa0Ge)clhs2jDYpqkJZIjS3MFQ9uead2PIfRxAsaphbObj(nXKLdexeflAREPjb8CeGgK43etwoq8HJ5HxQDpqY0HBn23gCKQAch8zjzirgSxwsv7flYY0hjnTeUtrbnpC1ewM(TrdiXVqZyfT8ssyVndc3AgFL8VC63QbcZF15vFnn8hpPPEwlgq4wZasFK(bAqIFt9SwmSm9rstlH7uuqZdxnHLPFB0as8l0mw4mCxyVndc3AgFL8VC63AGlXWY0hjnTeUtrXNsnHLPFB0as8l0mw4mCxyVnBdeU1mrEKbsA5HdYjVPjMSCGGMfZogBGWTMjVlbO5TQLD2YaxAhdiCRz8vY)YPFRbUedltFK00s4ofNNsnHLPFB0as8l0mw48cStc7Tzq4wZ4RK)Lt)wdCjgwM(iPPLWDkk(Siutyz63gnGe)cnJf(DBZFsy5qYoPt(bszCwmH928tTNIayWoHHLPpsAAjCNIIplc1ewM(TrdiXVqZyHZWDH92SnB2aHBntExcqZBvl7SLjMSCGGMNYEXI2aHBntExcqZBvl7SLbUediCRzY7saAERAzNTmpHZ(gfxmtbSxSOnq4wZe5rgiPLhoiN8MMyYYbcAwe2TJHLPpsAAjCNIIlc7QjSm9BJgqIFHMXkb8CeGgK4xyVnZY0hjnTeUtrbjMAclt)2ObK4xOzSWVBB(tc7TzBGWTMbi3zz6snqy(RoVg4sm1h2RgjNwepsAqIF7yyz6JKMwc3PO4ZIOyrBGWTMbi3zz6snqy(RoVg4smfwFyVAKCAr8iPbj(Xuy9H9Q5S6wepsAqIF7yyz6JKMwc3PO4ZIqnHLPFB0as8l0mw48cStc7TzB2Egij(WsW2XWY0hjnTeUtrXfH9IfTz7zGK4I0cyhdltFK00s4offxeysUtBAIhCxFnDcG0T7PyAOLb7u1UAclt)2ObK4xOzSkH7J07thjSCizN0j)aPmolMWEBUEPjb8CeGgK43etwoqqtPMWY0VnAaj(fAgReWZraAqIF1ewM(TrdiXVqZyHZWDH92mltFK00s4offxeQjSm9BJgqIFHMXkA5LKgK4xnHLPFB0as8l0mw(FBd(f2BZpdKmvQ5spfF4cgdiCRz8)2g8BEcN9nkUGnfqnrnzAQalt)2OqZyj5ExZY0Vv39yk8Y40mUNoqo9BvtMMkWY0Vnk0mwwEVQLa4hiPMmnvGLPFBuOzSKCVRzz63Q7EmfEzCAwExVEwBunzAQalt)2OqZyHZWDH928ZajtLAU0tXNsWyyz6JKMwc3PO4dxnzAQalt)2OqZyHZWDH928ZajtLAU0tXNsWyOyKwjzK326Um18w1X89gzW5PN7XuiiCRzIa4VKwQQLD2kAGlvtMMkWY0Vnk0mw(FBd(f2BZYlMZcUyrBpdKeK8IjgE6O3tY05HONQACEjdTmyNQyyz6JKMwc3POGMYUAY0ubwM(TrHMXQeUpsVpDKWj)aPu7T56LMeWZraAqIFtmz5G56LMeWZraAqIFdols0XKLdIQjttfyz63gfAgl872M)KWj)aPu7T56Lg872M)K5P2tramyNWWY0hjnTeUtrXNsnzAQalt)2OqZyLaEocqyVnBdeU1m(k5F50V1upRfdltFK00s4offKy2lw0giCRz8vY)YPFRbUedltFK00s4off0WTRMmnvGLPFBuOzSIwEjjS3MbHBnJVs(xo9Bn1ZAXWY0hjnTeUtrbnC1KPPcSm9BJcnJfoVa7KWEBUEPjb8CeGgK43KUCGVavtMMkWY0Vnk0mw43Tn)jHt(bsP2BZGWTMbi3zz6snqy(RoVg4smSm9rstlH7uu8PutMMkWY0Vnk0mwjGNJautMMkuqT37QGLNauHHP72M)Kky5javOGQlhMejtPMmnvGLPFBuOzSWVBB(tc7TzE6O3tYuEw0RVMobqA87wZZ7abjggwM(iPPLWDkolMAY0ubwM(TrHMXkA5LKAIAclt)2Ob3thiN(TZ(FBd(f2BZ(kpCFbQRmodK0fiki)VTb)6kJZajDc4PiGRxXac3Ag)VTb)MNWzFJIlIPpaoMKAclt)2Ob3thiN(TcnJ1tlzXDH92CY7aFbIbaX9eGPuMIxWfqnHLPFB0G7PdKt)wHMXQ90oDov1pbKw650VvyVnN8oWxGyaqCpbykLP4fCbutyz63gn4E6a50VvOzS41Xz910vItac7T58acStMk1On6JuedaI7jatPmfxKky1ewM(TrdUNoqo9BfAglcV8SOxdEBvyVnBRW6d7vJKtlIhjniXpMcRpSxnNv3I4rsds8BVyrwM(iPPLWDkkO5Putyz63gn4E6a50VvOzSa5FqCGVc7TzBj3PnnGpJd2POHwgStv7ySbc3AgqIFD7ECdCPDmjVd8figae3taMszkEbPay8vE4(cuxzCgiPlquqc2i20haX9eGbNfjQjSm9BJgCpDGC63k0mwr4F0h5U23y6RmJc7Tzq4wZeH)rFK7AFJPVYmAQN1IbeU1mG8pioWxt9SwmaiUNamLYu8cwWy8vE4(cuxzCgiPlquqc2mvbM(aiUNam4SirnrnHLPFB0iVRxpRnoxEPFRAclt)2OrExVEwBuOzSaq8NAkgPvsQjSm9BJg5D96zTrHMXcSFxv3G)Hutyz63gnY761ZAJcnJfi9r6h4lq1ewM(TrJ8UE9S2OqZyXVKxsN3)0MQjSm9BJg5D96zTrHMXQ7abKr90dCfioTPAclt)2OrExVEwBuOzSA(tG97QQjSm9BJg5D96zTrHMXIxjfZN7Aj37QjSm9BJg5D96zTrHMXc89y29fOUb)c7Tzq4wZas8RB3JBGlvtyz63gnY761ZAJcnJLVs(xo9Bf2BZ2QxAWVBB(tM0Ld8fyXISm9rstlH7uuqIzht9stc45ianiXVjD5aFbQMWY0VnAK31RN1gfAglq6J0pqnHLPFB0iVRxpRnk0mwWrs7jHlm1AKm1lJtZYHK9l)BDPgSZXunHLPFB0iVRxpRnk0mw864S(A6kXjaH92CEab2jJ8UE9S2igBPJt680vNexExVEw7WWPkwKLPpsAAjCNIcsm7QjSm9BJg5D96zTrHMXcNWVFi910DyPx11Ny8OAclt)2OrExVEwBuOzSGJK2tcpQMOMWY0VnAKCAr8inx(NvxnHLPFB0i50I4rsOzSKCQB3JlS3MleeU1mso1T7XnWLQjSm9BJgjNwepscnJ1ZdiH92miCRzk)ZQBGlvtyz63gnsoTiEKeAglae)P(A6eaPT8EvyVnNCN20aG4p1xtNaiTL3RgAzWovXuiiCRzaq8N6RPtaK2Y7vdCPAclt)2OrYPfXJKqZyr4LNf9AWBRc7T56d7vJKtlIhjniXVAclt)2OrYPfXJKqZyjVD8gq6eaPJL(7zuyVnxFyVAKCAr8iPbj(vtyz63gnsoTiEKeAgR3lf2BZ1lnVxAEQ9uead2jmYdh80LNVzuqZdxnHLPFB0i50I4rsOzSA0Fs)GJAqpjH92S8WbpD55Bgf08Wvtyz63gnsoTiEKeAglUYLPps6Of)4c7TzBfwV0WvUm9rshT4hxxzCgizsxoWxGykKLPFRHRCz6JKoAXpUUY4mqY4RU1DGasm2kSEPHRCz6JKoAXpUgaXDt6Yb(cSyX6LgUYLPps6Of)4Aae3npHZ(gfKiSxSy9sdx5Y0hjD0IFCDLXzGKjMSCG4Iat9sdx5Y0hjD0IFCDLXzGK5jC23O4fat9sdx5Y0hjD0IFCDLXzGKjD5aFbAxnHLPFB0i50I4rsOzSEEajS3MRxAEEazEQ9uead2jmYdh80LNVzu8HRMWY0VnAKCAr8ij0mwrapvf2BZYdh80LNVzu8cOMOMWY0VnAKYBhVb0SKtD7EC1ewM(TrJuE74nGeAgl5TJ3asNaiDS0FpJQjQjSm9BJM(qs(z5SKtD7EC1e1ewM(TrtFij)8nJF3oWxD7EC1e1ewM(TrZjVD8gqZ43Td8v3UhxnHLPFB0CYBhVbKqZyjVD8gq6eaPJL(7zunrnHLPFB0CwDlIhPz872b(QB3JlS3MleeU1m43Td8v3Uh3axQMWY0VnAoRUfXJKqZybG4p1xtNaiTL3Rc7T5K70Mgae)P(A6eaPT8E1qld2PkMcbHBndaI)uFnDcG0wEVAGlvtyz63gnNv3I4rsOzSi8YZIEn4TvH92C9H9Q5S6wepsAqIF1ewM(TrZz1TiEKeAgl5TJ3asNaiDS0FpJc7T56d7vZz1TiEK0Ge)QjSm9BJMZQBr8ij0mwCLltFK0rl(Xf2BZ2kSEPHRCz6JKoAXpUUY4mqYKUCGVaXuilt)wdx5Y0hjD0IFCDLXzGKXxDR7abKySvy9sdx5Y0hjD0IFCnaI7M0Ld8fyXI1lnCLltFK0rl(X1aiUBEcN9nkiryVyX6LgUYLPps6Of)46kJZajtmz5aXfbM6LgUYLPps6Of)46kJZajZt4SVrXlaM6LgUYLPps6Of)46kJZajt6Yb(c0UAclt)2O5S6wepscnJf(DBZFsy5qYoPt(bszCwmH928tTNIayWovSiiCRzaYDwMUudeM)QZRbUunHLPFB0CwDlIhjHMXkcVn)jHLdj7Ko5hiLXzXe2BZp1EkcGb7KAclt)2O5S6wepscnJvm5pc)ajH92Snq4wZqYUxgjDhE53axwSiiCRziz3lJKoED(nWL2vtyz63gnNv3I4rsOzSIj)n)jH92Sns29Yiz8v3Hx(lwKKDVmsM415xVKijTxSOns29Yiz8v3Hx(Xac3AMyYFe(bsAcV8SOhN2u3Hx(nWL2vtyz63gnNv3I4rsOzSSEobGsuIqa]] )

end