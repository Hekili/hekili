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
        --[[ rake = {
            id = 155722,
            duration = 15,
            max_stack = 1,
        }, ]]
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
        --[[ thrash_cat = {
            id = 106830,
            duration = function () return mod_circle_dot( 15 ) end,
            tick_time = function () return mod_circle_dot( 3 ) * haste end,
            max_stack = 1,
        }, ]]
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
            elseif k == "no_cds" then return not toggle.cooldowns
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

                if talent.balance_affinity.enabled then
                    shift( "moonkin_form" )
                elseif talent.feral_affinity.enabled then
                    shift( "cat_form" )
                elseif talent.restoration_affinity.enabled then
                    unshift()
                end
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
            cooldown = function () return ( buff.berserk.up and ( level > 57 and 1.5 or 3 ) or 6 ) * haste end,
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
                if time > 0 and ( not boss or not buff.shadowmeld.up ) then return false, "cannot stealth in combat"
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
            cooldown = function () return ( buff.berserk.up and ( level > 57 and 1.5 or 3 ) or 6 ) * haste end,
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

        potion = "spectral_agility",

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

    spec:RegisterSetting( "mangle_more", false, {
        name = "Use |T132135:0|t Mangle More in Multi-Target",
        desc = "If checked, the default priority will recommend |T132135:0|t Mangle more often in |cFFFFD100multi-target|r scenarios.  This will generate roughly 15% more Rage and allow for more mitigation (or |T132136:0|t Maul) than otherwise, " ..
            "funnel slightly more damage into your primary target, but will |T134296:0|t Swipe less often, dealing less damage/threat to your secondary targets.",
        type = "toggle",
        width = "full",
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

    spec:RegisterPack( "Guardian", 20210307.1, [[dye(AbqiPs9iKK0Ma4tasXOKGtrv1QOkGEfvPMff0TOki2fP(ffYWqsCmQIwMujptQitdjPUgvH2gGu9nQc04KkkDoQcQ1rvqY8KkCpKyFaIdcibTqQsEivbyIasGlcir(iGuQtIKeReqntaj0nbKs2jfQNcQPIK6Rasu7LWFP0Gj6WOwmqpMKjlPldTzQ8zLQrlvDAHvtvqQxlHMTsUnsTBf)wvdxIoUur1Yv55sz6IUoiBxP8DkA8as68uG1lvumFQk7hXcpfulGRCIcJ7IkD5jv6ev8G6U6YZoBN8Wc40GsuaxYQI8okGhMgfWaTH4Rg8iGlzdwpxfulGBp0PqbCFMLnpugz0EK9qGA1tBulOHwCg)Oo2Lg1cALrcyqOyLuLrakGRCIcJ7IkD5jv6ev8G6U6YZoBxEuaZqz)Fcy4G2dqa3h1kocqbCfBkbmqBi(Qbpejqbhuujad0Ipvpr6bnKi7IkDrfcWeG9a65zhBEOia7HqKuLr9x5FCIePhaNgb06)Pymez5f)fzGnISq4iYgMzm7ez0isvpQkIv)AcWEiejvzu)v(hNir(Lz8drMpr26dxsKf(JiNp9tKGO7pKi9a(z7lIAb8kAztqTaEzGIp(fulm2tb1cywLXpcy6)NIXyD)rlGXHbxyv4LifPage5tqTWypfulGXHbxyv4LawDrIxWc4UjsqiNtdI8zD)rRHkfWSkJFeWGiFw3F0IuyCxcQfWSkJFeWhVHZd1SUdNoJbcyCyWfwfEjsHXDsqTaghgCHvHxcy1fjEblG7MiRhuu1konrEdTGiFejaISBISEqrv)MltK3qliYNaMvz8Jaw9Z2xeTzpABLXfztKcJPAb1cyCyWfwfEjGvxK4fSaUarcc5C6J3W5HAw3HtNXanujr6Zhr2nrQ(nC4j1B4K9gCePFbmRY4hbmiEn8kksHXEuqTaghgCHvHxcy1fjEblGlqKGqoN(4nCEOM1D40zmqdvsK(8rKDtKQFdhEs9gozVbhr6xaZQm(rahJIVHZ4hrkmgOlOwaJddUWQWlbS6IeVGfWfisqiNtdIxdVIwqKpnujr6Zhrcc5C6yu8nCg)y3H4Rg8yFNf6AVsdvsK(fWSkJFeWG41WRym7IuyShuqTaghgCHvHxcy1fjEblGlqKDtK1p1CLlZydTnt(OTvMM3rDgQIXStKaiYUjswLXpAUYLzSH2MjF02ktZ7OogRBf79jrcGilqKDtK1p1CLlZydTnt(OT9iV0zOkgZor6Zhrw)uZvUmJn02m5J22J8sFinhtJibcr2jI0pr6Zhrw)uZvUmJn02m5J2wzAEh1TKvfjYoiYorKaiY6NAUYLzSH2MjF02ktZ7O(qAoMgr2br6rIearw)uZvUmJn02m5J2wzAEh1zOkgZor6xaZQm(raZvUmJn02m5JwKcJ7ScQfW4WGlSk8saRUiXlyb8HUdB9m4cjsF(iY6N6S)4wVfe5t3swvKi7Gi7er6ZhrwGiRFQZ(JB9wqKpDlzvrISdIKQjsae5bnO7VDuVGCooghudRwKg8yfQXohkklXkr6Ni95JizvgBOfhKoWgrcekejvlGzvg)iGZ(JB9wqKprkm2dlOwaJddUWQWlbS6IeVGfWfiYcejiKZP35fRYqz3H4Rg8OHkjs)ejaIKvzSHwCq6aBezhezxePFI0NpISarwGibHCo9oVyvgk7oeF1Ghnujr6NibqKDtK1p10)pU4qDgQIXStKaiswLXgAXbPdSrKaHi9KibqKjF7yQZGgT5BRbsKaHi9SlI0VaMvz8JaM()XfhksHXEsfb1cyCyWfwfEjGvxK4fSaUarw)ut))4Id1hsZX0iYoOqKDIibqKfisqiNtVZlwLHYUdXxn4rdvsK(jsaejRYydT4G0b2isGqKEKibqKjF7yQZGgT5BRbsKaHi9SlI0VaMvz8JaM()XfhksHXE6PGAbmom4cRcVeWQls8cwaF8oQROlursKaHi9KkejaISHzgZEttZZ(cT0)HcywLXpcyAE2xOifg7zxcQfW4WGlSk8saRUiXlybCbI8q3HTEgCHejaIKvzSHwCq6aBezhezxejaIm5BhtDg0OnFBnqIeiePNDrK(jsF(iYcez3ez9tn9)JlouNHQym7ejaIKvzSHwCq6aBejqispjsaezY3oM6mOrB(2AGejqisp7Ii9lGzvg)iGP)FCXHIuySNDsqTaghgCHvHxcy1fjEblGbHCoDmk(goJFS7q8vdESVZcDTxPRV5qKaisqiNtdIxdVIwqKpD9nhIearYQm2qloiDGnIeiuisQwaZQm(ra3mJs0cI8jsHXEs1cQfW4WGlSk8saRUiXlybmiKZPJrX3Wz8JgQKibqKSkJn0IdshyJi7Gi7saZQm(ratZqlrkm2tpkOwaJddUWQWlbS6IeVGfWfisqiNt34nEhTQNgKtEsDlzvrIeiuispjs)ejaISarcc5C68)S3Yt1QwSPgQKi9tKaisqiNthJIVHZ4hnujrcGizvgBOfhKoWgrsHi7saZQm(ratZqlrkm2tGUGAbmom4cRcVeWQls8cwadc5C6yu8nCg)OHkjsaejRYydT4G0b2iYoOqKDsaZQm(ratZZ(cfPWyp9GcQfW4WGlSk8saRUiXlybCbISarwGibHCoD(F2B5PAvl2u3swvKibcfISlI0pr6ZhrwGibHCoD(F2B5PAvl2udvsKaisqiNtN)N9wEQw1In1hsZX0iYoisp1EKi9tK(8rKfisqiNt34nEhTQNgKtEsDlzvrIeiuiYorK(js)ejaIKvzSHwCq6aBezhezNis)cywLXpcyAgAjsHXE2zfulGXHbxyv4LawDrIxWcywLXgAXbPdSrKaHi9uaZQm(raN9h36TGiFIuySNEyb1cyCyWfwfEjGvxK4fSaUarwGipEhjYoispmvis)ejaIKvzSHwCq6aBezhezNis)ePpFezbISarE8osKDqKDwpsK(jsaejRYydT4G0b2iYoiYorKaiYKx4K62dTSVZM9O19h2snom4cRePFbmRY4hbmnp7luKcJ7IkcQfW4WGlSk8saZQm(raxcT2Wl6mOawDrIxWc46N6S)4wVfe5t3swvKibcr2LawzGAH2KVDmBcJ9uKcJ7Ytb1cywLXpc4S)4wVfe5taJddUWQWlrkmURUeulGXHbxyv4LawDrIxWcywLXgAXbPdSrKDqKDsaZQm(ratZqlrkmURojOwaZQm(ra3mJs0cI8jGXHbxyv4Lifg3fvlOwaJddUWQWlbS6IeVGfWhVJ6k6cvKezhejvtfIearcc5C64(XbD6dP5yAezhejv0EuaZQm(rah3poOtKIuathzSZz8JGAHXEkOwaJddUWQWlbS6IeVGfWXOE6y2TvMM3rRhBejqiY4(XbD2ktZ7On7pS1)RkrcGibHCoDC)4Go9H0CmnISdIStePhir2ZTefWSkJFeWX9Jd6ePW4UeulGXHbxyv4LawDrIxWc4KNIXStKaiYEKxzVUuLezhejq3JcywLXpc4dh0KxIuyCNeulGXHbxyv4LawDrIxWc4KNIXStKaiYEKxzVUuLezhejq3JcywLXpcy3HtNjWQ9WDCWJZ4hrkmMQfulGXHbxyv4LawDrIxWc4cez3ez9GIQwXPjYBOfe5JibqKDtK1dkQ63CzI8gAbr(is)ePpFejRYydT4G0b2isGqHi7saZQm(raJ0LVjEwWFQIuyShfulGXHbxyv4LawDrIxWc4KNIXStKaiYEKxzVUuLezhePh0JejaImg1thZUTY08oA9yJibcrsfTNePhir2J8k710mqvaZQm(radYxXwXyePWyGUGAbmom4cRcVeWQls8cwadc5C6g0TfB8YgtlJrLnD9nhIearcc5CAq(k2kgJU(MdrcGi7rEL96svsKDqKaDQqKaiYyupDm72ktZ7O1JnIeiejv0D5rI0dKi7rEL9AAgOkGzvg)iGBq3wSXlBmTmgv2ePifWkonrEdfulm2tb1cywLXpc4Y7nxcyCyWfwfEjsHXDjOwaJddUWQWlbS6IeVGfWDtKGqoNwXP19hTgQuaZQm(raR406(JwKcJ7KGAbmom4cRcVeWQls8cwadc5C6Y7nxAOsbmRY4hb8XfrrkmMQfulGXHbxyv4LawDrIxWc4Kx4K6EKV0(oB2JwZyv14WGlSsKaiYUjsqiNt3J8L23zZE0AgRQgQuaZQm(ra3J8L23zZE0AgRQifg7rb1cyCyWfwfEjGvxK4fSaUEqrvR40e5n0cI8jGzvg)iGr6Y3epl4pvrkmgOlOwaJddUWQWlbS6IeVGfW1p1hxe1h6oS1ZGlKibqKQNg8TLFmzJi7GiPAbmRY4hb8Xfrrkm2dkOwaJddUWQWlbS6IeVGfW1p1xuQp0DyRNbxircGivpn4Bl)yYgrcekejvlGzvg)iGVOuKcJ7ScQfW4WGlSk8saRUiXlybC9GIQwXPjYBOfe5taZQm(raR(z7lI2ShTTY4ISjsHXEyb1cyCyWfwfEjGvxK4fSaw90GVT8JjBejqOqKuTaMvz8Ja2H3RIhQzbJefW0mq1IdE7gim2trkm2tQiOwaJddUWQWlbS6IeVGfWfiYUjY6NAUYLzSH2MjF02ktZ7OodvXy2jsaez3ejRY4hnx5Ym2qBZKpABLP5DuhJ1TI9(KibqKfiYUjY6NAUYLzSH2MjF02EKx6mufJzNi95JiRFQ5kxMXgABM8rB7rEPpKMJPrKaHi7er6Ni95JiRFQ5kxMXgABM8rBRmnVJ6wYQIezhezNisaez9tnx5Ym2qBZKpABLP5DuFinhtJi7Gi9ircGiRFQ5kxMXgABM8rBRmnVJ6mufJzNi9lGzvg)iG5kxMXgABM8rlsHXE6PGAbmom4cRcVeWQls8cwaREAW3w(XKnTc6oCsISdI0JcywLXpc4w)Hvrksb8YafFSsqTWypfulGzvg)iGvCAD)rlGXHbxyv4LifPaUIogALcQfg7PGAbmom4cRcVeWvSPUOmJFeWaLaQOckXkrIB4zarMbnsKzpsKSk)JiJgrYBCSyWfQfWSkJFeWTIqRLfKB9IuyCxcQfW4WGlSk8saRUiXlybC3ejiKZPlV3CPHkfWSkJFeWqn0gjs3ePW4ojOwaJddUWQWlbS6IeVGfWfiYcezbIm5foPUh5lTVZM9O1mwvnom4cRejaIeeY509iFP9D2ShTMXQQHkjs)ejaISarwpOOQvCAI8gAbr(isF(iY6bfv9BUmrEdTGiFePFIear2nrcc5C6Y7nxAOsI0pr6ZhrwGilqKGqoNgeVgEfTGiFAOsI0NpIeeY50XO4B4m(XUdXxn4X(ol01ELgQKi9tKaiYcez3ez9GIQwXPjYBOfe5JibqKDtK1dkQ63CzI8gAbr(is)ePFI0VaMvz8JaU8Z4hrkmMQfulGXHbxyv4LaUIn1fLz8JaMvz8ttxrhdTsVPy0bnwwLXp2v0sdhMgPO40e5n0WWrPEqrvR40e5n0cI8bOqb1)R6Bo6S)4wVfe5tFinhtdiubG6)v9nhnnp7luFinhtdiubq9tn9)JlouFinhtdiu2vvVPI2JaoEh7GQPcaqiNthJIVHZ4h7oeF1Gh77Sqx7v66BoaaHConiEn8kAbr(013Caac5C6DEXQmu2Di(Qbp66Bo(95RaiKZPvCAD)rRHkbGdE7gaKU8OFF(ku)uFCruFO7WwpdUqa1p1xuQp0DyRNbxOFF(kCqd6(Bh1pN923zZE0IRkE26bfvn25qrzjwb0niKZPFo7TVZM9Ofxv8S1dkQAOsafaHCoTItR7pAnujaCWB3aG0fv8daeY509iFP9D2ShTMXQQpKMJP1bfpPIFF(kO(nC4j1fn4cEaO(FvFZrJ0LVjEwWFQ6dP5yADqXtaSkJn0IdshyRJU87ZxbqiNt3J8L23zZE0AgRQgQeao4TBaq8WuXVFbmRY4hb8bnwwLXp2v0sbS6IeVGfW1dkQAfNMiVHwqKpIearcc5CAfNw3F0AOsb8kAPDyAuaR40e5nuKcJ9OGAbmom4cRcVeWvSPUOmJFeWSkJFA6k6yOv6nfJoOXYQm(XUIwA4W0iL3CzI8gAy4OupOOQFZLjYBOfe5dqHcQ)x13C0z)XTEliYN(qAoMgqOca1)R6BoAAE2xO(qAoMgqOcGJ3Xo6IkaaHCoDmk(goJF013Caac5CAq8A4v0cI8PRV543NVcGqoNM()Pymw3F0AOsa1p1nOXfhQp0DyRNbxOFF(kac5CA6)NIXyD)rRHkbac5C6EKV0(oB2JwZyv1qL(95RaiKZPP)FkgJ19hTgQeqbqiNtJQvu2q7cA4tdv6ZhiKZPr1kkBOT9l(0qL(b09bnO7VDu)C2BFNn7rlUQ4zRhuu1yNdfLLy1VpFfoObD)TJ6NZE77SzpAXvfpB9GIQg7COOSeRa6geY50pN923zZE0IRkE26bfvnuPFF(kO(nC4j1tS3NwhJau)VQV5Ov)S9frB2J2wzCr20hsZX06GIN(95RG63WHNux0Gl4bG6)v9nhnsx(M4zb)PQpKMJP1bfpbWQm2qloiDGTo6YVFbmRY4hb8bnwwLXp2v0sbS6IeVGfW1dkQ63CzI8gAbr(isaejiKZPP)FkgJ19hTgQuaVIwAhMgfWV5Ye5nuKcJb6cQfW4WGlSk8saxXM6IYm(ratvCePjsK98gsKafnqXhtKlChNkFgqKyNdfLLyLi5PsKG8IhfsKSZftKgqKCJizIm5fojrAIezZmsvprgt(ej9)tXyis3F0ePzpo4gEez2Je5YafFmrcc5Cez0isojY)isqC9MezxezdvcywLXpc4dASSkJFSROLcy1fjEblGlqKfiYdAq3F7OEzGIpUzDleZy2T7RGUSHASZHIYsSsK(jsaezbIm5foPgKx8Oql7CXePbACyWfwjs)ejaISarcc5C6Lbk(4M1TqmJz3UVc6YgQHkjs)ejaISarcc5C6Lbk(4M1TqmJz3UVc6YgQpKMJPrKDqHi7Ii9tK(fWROL2HPrb8YafF8lsHXEqb1cyCyWfwfEjGRytDrzg)iGPkoI0ejYEEdjsGIgO4JjYfUJtLpdisSZHIYsSsK8ujshE8IizNlMinGi5grYezYlCsI0ejYMzKQEImM8jshE8IiD)rtKM94GB4rKzpsKldu8XejiKZrKrJi5Ki)JibX1BsKDrKnujGzvg)iGpOXYQm(XUIwkGvxK4fSaUarwGipObD)TJ6Lbk(4M1TqmJz3UVc6YgQXohkklXkr6NibqKfiYKx4KAhE8YYoxmrAGghgCHvI0prcGilqKGqoNEzGIpUzDleZy2T7RGUSHAOsI0prcGilqKGqoNEzGIpUzDleZy2T7RGUSH6dP5yAezhuiYUis)ePFb8kAPDyAuaVmqXhRePW4oRGAbmom4cRcVeWvSPUOmJFeWufhrAIanhsKmroXEF6yKi5PsKMirw)bOjjstEsImFIuXPjYBOrV5Ye5n0qEQePjsK98gsKG8IhfAKdpErKSZftKgqKjVWjXQHejq5ECWn8is1pBFrKivvImAejujrAIezZmsvprgt(ej7CXePbeP7pAImFIuXTKiJ0qIShpKiP)Fkgdr6(JwlGzvg)iGpOXYQm(XUIwkGvxK4fSaUHzgZEt36dxAD)zv)S9frIearwGilqKjVWj1G8IhfAzNlMinqJddUWkr6NibqKfiYUjY6bfvTIttK3qliYhr6NibqKfiYUjY6bfv9BUmrEdTGiFePFIearwGiv)go8K6j27tRJrIearQ(FvFZrR(z7lI2ShTTY4ISPpKMJPrKDqHi9Ki9tK(fWROL2HPrb8R(z7lIIuyShwqTaghgCHvHxc4k2uxuMXpcyQIJinrGMdjsMiNyVpDmsK8ujstKiR)a0KePjpjrMprQ40e5n0O3CzI8gAipvI0ejYEEdjsqEXJcnYHhVis25IjsdiYKx4Ky1qIeOCpo4gEeP6NTVisKQkrgnIeQKinrISzgPQNiJjFIKDUyI0aI09hnrMprQ4wsKrAir2JhsKkoD)rtKU)O1cywLXpc4dASSkJFSROLcy1fjEblGByMXS30T(WLw3Fw1pBFrKibqKfiYcezYlCsTdpEzzNlMinqJddUWkr6NibqKfiYUjY6bfvTIttK3qliYhr6NibqKfiYUjY6bfv9BUmrEdTGiFePFIearwGiv)go8K6j27tRJrIearQ(FvFZrR(z7lI2ShTTY4ISPpKMJPrKDqHi9Ki9tK(fWROL2HPrbSs9Z2xefPWypPIGAbmom4cRcVeWSkJFeWkETSSkJFSROLc4v0s7W0OaMoYyNZ4hrkm2tpfulGXHbxyv4LaMvz8Ja(GglRY4h7kAPaEfT0omnkGbr(ePifWLhQEAqofulm2tb1cyCyWfwfEjGRytDrzg)iGbkburfuIvIeeD)HeP6Pb5KibX9yAAIeOqLclZgro)4H0ZhTdArKSkJFAe5pld0cywLXpc4IXupSABLXfztKcJ7sqTaghgCHvHxcy1fjEblGbHCoTItR7pAnujrcGiRhuu1konrEdTGiFcywLXpc4Y7nxIuyCNeulGXHbxyv4LawDrIxWc4UjsqiNtZJbw3F0AOsIearwGi7MiRhuu1konrEdTGiFePpFejiKZPvCAD)rRRV5qK(jsaezbISBISEqrv)MltK3qliYhr6Zhrcc5CA6)NIXyD)rRRV5qK(fWSkJFeWGiFw3F0IuymvlOwaJddUWQWlbS6IeVGfWjVWj19iFP9D2ShTMXQQXHbxyLibqKfiY6bfvTIttK3qliYhrcGibHCoTItR7pAnujr6ZhrwpOOQFZLjYBOfe5JibqKGqoNM()Pymw3F0AOsI0NpIeeY500)pfJX6(JwdvsKaiYKx4KAqEXJcTSZftKgOXHbxyLi9lGzvg)iG7r(s77SzpAnJvvKcJ9OGAbmom4cRcVeWQls8cwadc5CA6)NIXyD)rRHkjsaez9GIQ(nxMiVHwqKpIear2nrQ(nC4j1tS3NwhJcywLXpcyZJZErkmgOlOwaJddUWQWlbS6IeVGfWGqoNM()Pymw3F0AOsIearwpOOQFZLjYBOfe5JibqKQFdhEs9e79P1XOaMvz8JaUL85IdfPifWQ)x13CAcQfg7PGAbmRY4hbC5NXpcyCyWfwfEjsHXDjOwaZQm(radU(VADqNbcyCyWfwfEjsHXDsqTaMvz8JageVgEfJzxaJddUWQWlrkmMQfulGzvg)iG5tXdAZ)oCsbmom4cRcVePWypkOwaZQm(raVI9(Sz9qdv3PXjfW4WGlSk8sKcJb6cQfWSkJFeWU4qW1)vbmom4cRcVePWypOGAbmRY4hbmpkSLhVSkETeW4WGlSk8sKcJ7ScQfW4WGlSk8saRUiXlybmiKZPbr(SU)O1qLcywLXpcyWlA5kMDRd6ePWypSGAbmom4cRcVeWQls8cwaxGiRFQP)FCXH6mufJzNi95JizvgBOfhKoWgrceI0tI0prcGiRFQZ(JB9wqKpDgQIXSlGzvg)iGJrX3Wz8Jifg7jveulGzvg)iGbXRHxrbmom4cRcVePWyp9uqTaghgCHvHxcywLXpcyLbQ1N3pHYcU4wkGrNdvPDyAuaRmqT(8(juwWf3srkm2ZUeulGzvg)iGHAOnsKUjGXHbxyv4LifPa(v)S9frb1cJ9uqTaMvz8JaM()Pymw3F0cyCyWfwfEjsHXDjOwaZQm(raR(z7lI2ShTTY4ISjGXHbxyv4LifPawP(z7lIcQfg7PGAbmRY4hbSItR7pAbmom4cRcVePW4UeulGzvg)iGv)S9frB2J2wzCr2eW4WGlSk8sKIua)MltK3qb1cJ9uqTaghgCHvHxcy1fjEblG7MibHCon9)tXySU)O1qLcywLXpcy6)NIXyD)rlsHXDjOwaJddUWQWlbS6IeVGfWjVWj19iFP9D2ShTMXQQXHbxyLibqKDtKGqoNUh5lTVZM9O1mwvnuPaMvz8JaUh5lTVZM9O1mwvrkmUtcQfWSkJFeWTKVg0TJcyCyWfwfEjsHXuTGAbmom4cRcVeWQls8cwa3EOfymvTlUwAB5ffrnom4cRcywLXpcy1pBFr0M9OTvgxKnrkm2JcQfW4WGlSk8saRUiXlybC9GIQ(nxMiVHwqKpbmRY4hbmsx(M4zb)PksHXaDb1cyCyWfwfEjGvxK4fSaUar2nrw)uZvUmJn02m5J2wzAEh1zOkgZorcGi7Mizvg)O5kxMXgABM8rBRmnVJ6ySUvS3NejaISar2nrw)uZvUmJn02m5J22J8sNHQym7ePpFez9tnx5Ym2qBZKpABpYl9H0CmnIeiezNis)ePpFez9tnx5Ym2qBZKpABLP5Du3swvKi7Gi7ercGiRFQ5kxMXgABM8rBRmnVJ6dP5yAezhePhjsaez9tnx5Ym2qBZKpABLP5DuNHQym7ePFbmRY4hbmx5Ym2qBZKpArkm2dkOwaJddUWQWlbmRY4hbCdACXHcy1fjEblGp0DyRNbxOawzGAH2KVDmBcJ9uKcJ7ScQfW4WGlSk8saZQm(rat))4IdfWQls8cwaFO7WwpdUqI0NpIeeY5078IvzOS7q8vdE0qLcyLbQfAt(2XSjm2trkm2dlOwaJddUWQWlbS6IeVGfWQFdhEs9e79P1XircGir1kkBOMhdSdcutbmRY4hbCl5ZfhksHXEsfb1cyCyWfwfEjGvxK4fSaUBIu9B4WtQNyVpTogjsaejQwrzd18yGDqGAkGzvg)iGnpo7fPWyp9uqTaghgCHvHxcy1fjEblGlqKGqoNgvROSH2f0WNgQKi95JibHConQwrzdTTFXNgQKi9lGzvg)iGv)S9frB2J2wzCr2ePWyp7sqTaghgCHvHxcy1fjEblGlqKOAfLnuhJDbn8rK(8rKOAfLnu3(fF2bbQjr6Ni95JilqKOAfLnuhJDbn8rKaisqiNt3s(Aq3oAr6Y3epACs7cA4tdvsK(fWSkJFeWTKpxCOifg7zNeulGzvg)iGnpo7fW4WGlSk8sKIuKc4n8AXpcJ7IkD5jv6ev8Gcyt(My2BcyQcD5Fjwjsp9Kizvg)qKROLnnbybCRevcJ9KkuTaU8ExSqbmvLibAdXxn4Hibk4GIkbyQkrc0Ipvpr6bnKi7IkDrfcWeGPQePhqpp7yZdfbyQkr6HqKuLr9x5FCIePhaNgb06)Pymez5f)fzGnISq4iYgMzm7ez0isvpQkIv)AcWuvI0dHiPkJ6VY)4ejYVmJFiY8jYwF4sISWFe58PFIeeD)HePhWpBFrutaMamvLibkburfuIvIeeD)HeP6Pb5KibX9yAAIeOqLclZgro)4H0ZhTdArKSkJFAe5pld0eGzvg)00LhQEAqo9MIrfJPEy12kJlYgbywLXpnD5HQNgKtVPyu59MlddhfqiNtR406(JwdvcOEqrvR40e5n0cI8raMvz8ttxEO6Pb50BkgbI8zD)rBy4O0niKZP5XaR7pAnujGcDxpOOQvCAI8gAbr(85deY50koTU)O113C8dOq31dkQ63CzI8gAbr(85deY500)pfJX6(JwxFZXpbywLXpnD5HQNgKtVPyupYxAFNn7rRzSQggokjVWj19iFP9D2ShTMXQQXHbxyfqH6bfvTIttK3qliYhaqiNtR406(Jwdv6Zx9GIQ(nxMiVHwqKpaGqoNM()Pymw3F0AOsF(aHCon9)tXySU)O1qLasEHtQb5fpk0YoxmrAGghgCHv)eGzvg)00LhQEAqo9MIrMhN9ggokGqoNM()Pymw3F0AOsa1dkQ63CzI8gAbr(a0T63WHNupXEFADmsaMvz8ttxEO6Pb50Bkg1s(CXHggokGqoNM()Pymw3F0AOsa1dkQ63CzI8gAbr(aO(nC4j1tS3NwhJeGjatvjsGsavubLyLiXn8mGiZGgjYShjswL)rKrJi5nowm4c1eGzvg)0O0kcTwwqU1taMvz8tZBkgb1qBKiDZWWrPBqiNtxEV5sdvsaMvz8tZBkgv(z8JHHJsHcfsEHtQ7r(s77SzpAnJvvJddUWkaqiNt3J8L23zZE0AgRQgQ0pGc1dkQAfNMiVHwqKpF(Qhuu1V5Ye5n0cI85hq3GqoNU8EZLgQ0VpFfkac5CAq8A4v0cI8PHk95deY50XO4B4m(XUdXxn4X(ol01ELgQ0pGcDxpOOQvCAI8gAbr(a0D9GIQ(nxMiVHwqKp)(9taMQsKSkJFAEtXOdASSkJFSROLgomnsrXPjYBOHHJs9GIQwXPjYBOfe5dqHcQ)x13C0z)XTEliYN(qAoMgqOca1)R6BoAAE2xO(qAoMgqOcG6NA6)hxCO(qAoMgqOSRQEtfThbC8o2bvtfaGqoNogfFdNXp2Di(Qbp23zHU2R013Caac5CAq8A4v0cI8PRV5aaeY5078IvzOS7q8vdE013C87ZxbqiNtR406(Jwdvcah82naiD5r)(8v4Gg093oQFo7TVZM9Ofxv8S1dkQASZHIYsScOBqiNt)C2BFNn7rlUQ4zRhuu1qLakac5CAfNw3F0AOsa4G3UbaPlQ43VpFfoObD)TJ6NZE77SzpAXvfpB9GIQg7COOSeRaaHCoDpYxAFNn7rRzSQ6dP5yAD4jv8dOaiKZPvCAD)rRHkbGdE7gaKUOIFF(kO(nC4j1fn4cEaO(FvFZrJ0LVjEwWFQ6dP5yADqXtaSkJn0IdshyRJU87NamvLizvg)08MIrh0yzvg)yxrlnCyAKIIttK3qddhL6bfvTIttK3qliYhGcfu)VQV5OZ(JB9wqKp9H0CmnGqfaQ)x13C008SVq9H0CmnGqfa1p10)pU4q9H0CmnGqzxv9MkApc44DSdQMkaaHCoDmk(goJFS7q8vdESVZcDTxPRV5aaeY50G41WROfe5txFZbaiKZP35fRYqz3H4Rg8ORV543NVcGqoNwXP19hTgQeao4TBaq6YJ(95Rq9t9Xfr9HUdB9m4cbu)uFrP(q3HTEgCH(95RWbnO7VDu)C2BFNn7rlUQ4zRhuu1yNdfLLyfq3GqoN(5S3(oB2JwCvXZwpOOQHkbuaeY50koTU)O1qLaWbVDdasxuXpaqiNt3J8L23zZE0AgRQ(qAoMwhu8Kk(95RG63WHNux0Gl4bG6)v9nhnsx(M4zb)PQpKMJP1bfpbWQm2qloiDGTo6YVpFfaHCoDpYxAFNn7rRzSQAOsa4G3UbaXdtf)(jaZQm(P5nfJoOXYQm(XUIwA4W0iffNMiVHggok1dkQAfNMiVHwqKpaGqoNwXP19hTgQKamvLizvg)08MIrh0yzvg)yxrlnCyAKYBUmrEdnmCuQhuu1V5Ye5n0cI8bOqb1)R6Bo6S)4wVfe5tFinhtdiubG6)v9nhnnp7luFinhtdiubWX7yhDrfaGqoNogfFdNXp66BoaaHConiEn8kAbr(013C87ZxbqiNtt))umgR7pAnujG6N6g04Id1h6oS1ZGl0VpFfaHCon9)tXySU)O1qLaaHCoDpYxAFNn7rRzSQAOs)(8vaeY500)pfJX6(JwdvcOaiKZPr1kkBODbn8PHk95deY50OAfLn02(fFAOs)a6(Gg093oQFo7TVZM9Ofxv8S1dkQASZHIYsS63NVch0GU)2r9ZzV9D2ShT4QINTEqrvJDouuwIvaDdc5C6NZE77SzpAXvfpB9GIQgQ0VpFfu)go8K6j27tRJraQ)x13C0QF2(IOn7rBRmUiB6dP5yADqXt)(8vq9B4WtQlAWf8aq9)Q(MJgPlFt8SG)u1hsZX06GINayvgBOfhKoWwhD53pbywLXpnVPy0bnwwLXp2v0sdhMgP8MltK3qddhL6bfv9BUmrEdTGiFaaHCon9)tXySU)O1qLeGPQejvXrKMir2ZBircu0afFmrUWDCQ8zarIDouuwIvIKNkrcYlEuirYoxmrAarYnIKjYKx4KePjsKnZiv9ezm5tK0)pfJHiD)rtKM94GB4rKzpsKldu8XejiKZrKrJi5Ki)JibX1BsKDrKnuraMvz8tZBkgDqJLvz8JDfT0WHPrkldu8XVHHJsHch0GU)2r9YafFCZ6wiMXSB3xbDzd1yNdfLLy1pGcjVWj1G8IhfAzNlMinqJddUWQFafaHCo9YafFCZ6wiMXSB3xbDzd1qL(buaeY50ldu8XnRBHygZUDFf0LnuFinhtRdkD53pbyQkrsvCePjsK98gsKafnqXhtKlChNkFgqKyNdfLLyLi5PsKo84frYoxmrAarYnIKjYKx4KePjsKnZiv9ezm5tKo84fr6(JMin7Xb3WJiZEKixgO4JjsqiNJiJgrYjr(hrcIR3Ki7IiBOIamRY4NM3um6GglRY4h7kAPHdtJuwgO4JvggokfkCqd6(Bh1ldu8XnRBHygZUDFf0LnuJDouuwIv)akK8cNu7WJxw25Ijsd04WGlS6hqbqiNtVmqXh3SUfIzm729vqx2qnuPFafaHCo9YafFCZ6wiMXSB3xbDzd1hsZX06Gsx(9taMQsKufhrAIanhsKmroXEF6yKi5PsKMirw)bOjjstEsImFIuXPjYBOrV5Ye5n0qEQePjsK98gsKG8IhfAKdpErKSZftKgqKjVWjXQHejq5ECWn8is1pBFrKivvImAejujrAIezZmsvprgt(ej7CXePbeP7pAImFIuXTKiJ0qIShpKiP)Fkgdr6(JwtaMvz8tZBkgDqJLvz8JDfT0WHPrkV6NTViAy4O0WmJzVPB9HlTU)SQF2(IiGcfsEHtQb5fpk0YoxmrAGghgCHv)ak0D9GIQwXPjYBOfe5ZpGcDxpOOQFZLjYBOfe5ZpGcQFdhEs9e79P1Xia1)R6BoA1pBFr0M9OTvgxKn9H0CmToO4PF)eGPQejvXrKMiqZHejtKtS3NogjsEQePjsK1FaAsI0KNKiZNivCAI8gA0BUmrEdnKNkrAIezpVHejiV4rHg5WJxej7CXePbezYlCsSAircuUhhCdpIu9Z2xejsvLiJgrcvsKMir2mJu1tKXKprYoxmrAar6(JMiZNivCljYinKi7XdjsfNU)Ojs3F0AcWSkJFAEtXOdASSkJFSROLgomnsrP(z7lIggoknmZy2B6wF4sR7pR6NTVicOqHKx4KAhE8YYoxmrAGghgCHv)ak0D9GIQwXPjYBOfe5ZpGcDxpOOQFZLjYBOfe5ZpGcQFdhEs9e79P1Xia1)R6BoA1pBFr0M9OTvgxKn9H0CmToO4PF)eGzvg)08MIrkETSSkJFSROLgomnsHoYyNZ4hcWSkJFAEtXOdASSkJFSROLgomnsbe5JambywLXpnniYhfqKpR7pAddhLUbHConiYN19hTgQKamRY4NMge5ZBkgD8gopuZ6oC6mgqaMvz8ttdI85nfJu)S9frB2J2wzCr2mmCu6UEqrvR40e5n0cI8bO76bfv9BUmrEdTGiFeGzvg)00GiFEtXiq8A4v0cI8zy4OuaeY50hVHZd1SUdNoJbAOsF(6w9B4WtQ3Wj7n48taMvz8ttdI85nfJIrX3Wz8JHHJsbqiNtF8gopuZ6oC6mgOHk95RB1VHdpPEdNS3GZpbywLXpnniYN3umceVgEfJz3WWrPaiKZPbXRHxrliYNgQ0NpqiNthJIVHZ4h7oeF1Gh77Sqx7vAOs)eGzvg)00GiFEtXiUYLzSH2MjF0ggokf6U(PMRCzgBOTzYhTTY08oQZqvmMDaDZQm(rZvUmJn02m5J2wzAEh1XyDRyVpbuO76NAUYLzSH2MjF02EKx6mufJz3NV6NAUYLzSH2MjF02EKx6dP5yAaPt(95R(PMRCzgBOTzYhTTY08oQBjRk2rNau)uZvUmJn02m5J2wzAEh1hsZX06WJaQFQ5kxMXgABM8rBRmnVJ6mufJz3pbywLXpnniYN3umk7pU1Bbr(mm5BhtB4OCO7WwpdUqF(QFQZ(JB9wqKpDlzvXo6KpFfQFQZ(JB9wqKpDlzvXoOAah0GU)2r9cY54yCqnSArAWJvOg7COOSeR(95JvzSHwCq6aBaHcvtaMvz8ttdI85nfJO)FCXHggokfkac5C6DEXQmu2Di(QbpAOs)ayvgBOfhKoWwhD53NVcfaHCo9oVyvgk7oeF1GhnuPFaDx)ut))4Id1zOkgZoawLXgAXbPdSbepbK8TJPodA0MVTgiq8Sl)eGzvg)00GiFEtXi6)hxCOHHJsH6NA6)hxCO(qAoMwhu6eGcGqoNENxSkdLDhIVAWJgQ0pawLXgAXbPdSbepci5BhtDg0OnFBnqG4zx(jaZQm(PPbr(8MIr08SVqddhLJ3rDfDHksG4jva0WmJzVPP5zFHw6)qcWSkJFAAqKpVPye9)Jlo0WWrPWHUdB9m4cbWQm2qloiDGTo6cqY3oM6mOrB(2AGaXZU87ZxHURFQP)FCXH6mufJzhaRYydT4G0b2aINas(2XuNbnAZ3wdeiE2LFcWSkJFAAqKpVPyuZmkrddhfqiNthJIVHZ4h7oeF1Gh77Sqx7v66BoaaHConiEn8kAbr(013CaWQm2qloiDGnGqHQjaZQm(PPbr(8MIr0m0YWWrbeY50XO4B4m(rdvcGvzSHwCq6aBD0fbywLXpnniYN3umIMHwggokfaHCoDJ34D0QEAqo5j1TKvfbcfp9dOaiKZPZ)ZElpvRAXMAOs)aaHCoDmk(goJF0qLayvgBOfhKoWgLUiaZQm(PPbr(8MIr08SVqddhfqiNthJIVHZ4hnujawLXgAXbPdS1bLoraMvz8ttdI85nfJOzOLHHJsHcfaHCoD(F2B5PAvl2u3swveiu6YVpFfaHCoD(F2B5PAvl2udvcaeY505)zVLNQvTyt9H0CmTo8u7r)(8vaeY50nEJ3rR6Pb5KNu3swveiu6KF)ayvgBOfhKoWwhDYpbywLXpnniYN3umk7pU1Bbr(mmCuyvgBOfhKoWgq8KamRY4NMge5ZBkgrZZ(cnmCuku44DSdpmv8dGvzSHwCq6aBD0j)(8vOWX7yhDwp6haRYydT4G0b26OtasEHtQBp0Y(oB2Jw3Fyl14WGlS6NamRY4NMge5ZBkgvcT2Wl6mOHkdul0M8TJzJINggok1p1z)XTEliYNULSQiq6IamRY4NMge5ZBkgL9h36TGiFeGzvg)00GiFEtXiAgAzy4OWQm2qloiDGTo6ebywLXpnniYN3umQzgLOfe5JamRY4NMge5ZBkgf3poOZWWr54DuxrxOISdQMkaaHCoDC)4Go9H0CmToOI2JeGjaZQm(PPPJm25m(HsC)4GoddhLyupDm72ktZ7O1JnGe3poOZwzAEhTz)HT(Fvbac5C64(XbD6dP5yAD0jpWEULibywLXpnnDKXoNXpEtXOdh0KxggokjpfJzhqpYRSxxQYoa6EKamRY4NMMoYyNZ4hVPyK7WPZey1E4oo4Xz8JHHJsYtXy2b0J8k71LQSdGUhjaZQm(PPPJm25m(XBkgH0LVjEwWFQggokf6UEqrvR40e5n0cI8bO76bfv9BUmrEdTGiF(95JvzSHwCq6aBaHsxeGzvg)000rg7Cg)4nfJa5RyRymggokjpfJzhqpYRSxxQYo8GEeqmQNoMDBLP5D06XgqOI2tpWEKxzVMMbQeGzvg)000rg7Cg)4nfJAq3wSXlBmTmgv2mmCuaHCoDd62InEzJPLXOYMU(MdaqiNtdYxXwXy013Ca0J8k71LQSdGovaeJ6PJz3wzAEhTESbeQO7YJEG9iVYEnndujataMvz8ttR(FvFZPrP8Z4hcWSkJFAA1)R6BonVPye46)Q1bDgqaMvz8ttR(FvFZP5nfJaXRHxXy2jaZQm(PPv)VQV508MIr8P4bT5FhojbywLXpnT6)v9nNM3umAf79zZ6HgQUtJtsaMvz8ttR(FvFZP5nfJCXHGR)ReGzvg)00Q)x13CAEtXiEuylpEzv8AraMvz8ttR(FvFZP5nfJaVOLRy2ToOZWWrbeY50GiFw3F0AOscWSkJFAA1)R6BonVPyumk(goJFmmCuku)ut))4Id1zOkgZUpFSkJn0IdshydiE6hq9tD2FCR3cI8PZqvmMDcWSkJFAA1)R6BonVPyeiEn8ksaMvz8ttR(FvFZP5nfJGAOnsK2q05qvAhMgPOmqT(8(juwWf3scWSkJFAA1)R6BonVPyeudTrI0ncWeGzvg)00konrEdPuEV5IamRY4NMwXPjYBO3umsXP19hTHHJs3GqoNwXP19hTgQKamRY4NMwXPjYBO3um64IOHHJciKZPlV3CPHkjaZQm(PPvCAI8g6nfJ6r(s77SzpAnJv1WWrj5foPUh5lTVZM9O1mwvnom4cRa6geY509iFP9D2ShTMXQQHkjaZQm(PPvCAI8g6nfJq6Y3epl4pvddhL6bfvTIttK3qliYhbywLXpnTIttK3qVPy0XfrddhL6N6JlI6dDh26zWfcq90GVT8JjBDq1eGzvg)00konrEd9MIrxuAy4Ou)uFrP(q3HTEgCHaupn4Bl)yYgqOq1eGzvg)00konrEd9MIrQF2(IOn7rBRmUiBggok1dkQAfNMiVHwqKpcWSkJFAAfNMiVHEtXihEVkEOMfms0qAgOAXbVDdO4PHHJI6PbFB5ht2acfQMamRY4NMwXPjYBO3umIRCzgBOTzYhTHHJsHURFQ5kxMXgABM8rBRmnVJ6mufJzhq3SkJF0CLlZydTnt(OTvMM3rDmw3k27taf6U(PMRCzgBOTzYhTTh5LodvXy295R(PMRCzgBOTzYhTTh5L(qAoMgq6KFF(QFQ5kxMXgABM8rBRmnVJ6wYQID0ja1p1CLlZydTnt(OTvMM3r9H0CmTo8iG6NAUYLzSH2MjF02ktZ7OodvXy29taMvz8ttR40e5n0Bkg16pSAy4OOEAW3w(XKnTc6oCYo8ibycWSkJFAAL6NTVisrXP19hnbywLXpnTs9Z2xe9MIrQF2(IOn7rBRmUiBeGjaZQm(PPxgO4JvuuCAD)rtaMamRY4NMEzGIp(Pq))umgR7pAcWeGzvg)00V6NTVisH()Pymw3F0eGzvg)00V6NTVi6nfJu)S9frB2J2wzCr2iataMvz8tt)MltK3qk0)pfJX6(J2WWrPBqiNtt))umgR7pAnujbywLXpn9BUmrEd9MIr9iFP9D2ShTMXQAy4OK8cNu3J8L23zZE0AgRQghgCHvaDdc5C6EKV0(oB2JwZyv1qLeGzvg)00V5Ye5n0Bkg1s(Aq3osaMvz8tt)MltK3qVPyK6NTViAZE02kJlYMHHJs7HwGXu1U4APTLxue14WGlSsaMvz8tt)MltK3qVPyesx(M4zb)PAy4OupOOQFZLjYBOfe5JamRY4NM(nxMiVHEtXiUYLzSH2MjF0ggokf6U(PMRCzgBOTzYhTTY08oQZqvmMDaDZQm(rZvUmJn02m5J2wzAEh1XyDRyVpbuO76NAUYLzSH2MjF02EKx6mufJz3NV6NAUYLzSH2MjF02EKx6dP5yAaPt(95R(PMRCzgBOTzYhTTY08oQBjRk2rNau)uZvUmJn02m5J2wzAEh1hsZX06WJaQFQ5kxMXgABM8rBRmnVJ6mufJz3pbywLXpn9BUmrEd9MIrnOXfhAOYa1cTjF7y2O4PHHJYHUdB9m4cjaZQm(PPFZLjYBO3umI()XfhAOYa1cTjF7y2O4PHHJYHUdB9m4c95deY5078IvzOS7q8vdE0qLeGzvg)00V5Ye5n0Bkg1s(CXHggokQFdhEs9e79P1XiauTIYgQ5Xa7Ga1KamRY4NM(nxMiVHEtXiZJZEddhLUv)go8K6j27tRJraOAfLnuZJb2bbQjbywLXpn9BUmrEd9MIrQF2(IOn7rBRmUiBggokfaHConQwrzdTlOHpnuPpFGqoNgvROSH22V4tdv6NamRY4NM(nxMiVHEtXOwYNlo0WWrPaQwrzd1XyxqdF(8HQvu2qD7x8zheOM(95RaQwrzd1XyxqdFaaHCoDl5RbD7OfPlFt8OXjTlOHpnuPFcWSkJFA63CzI8g6nfJmpo7fPifca]] )

end