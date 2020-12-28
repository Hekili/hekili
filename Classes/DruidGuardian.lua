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

    spec:RegisterPack( "Guardian", 20201227, [[dGKotbqirQEKuvSjq5tsvjmkjLtjjTkqLsVIezwKq3sQkv7IIFbQAyKeogjLLjs8msQAAGk6AKeTnqf8nsQW4iPsoNuvsRduPW8ejDpaTpPQ6GGkrwijPhcQeMOuvIUijvQAJKuPWhbvI6KKurRuQYmjPsLBkvLYojrnusQu0tbzQKGVssLs7fQ)sPbtQdJAXa9yIMSuUmYMf1Nby0kvNMQvdQu0RLeZwj3Mq7wXVvz4sLJdQuTCv9CjMUW1jy7kLVlIXdQqNxKY6bvsZxs1(HmwnScyOghew5uurkQqTusrDyudoOIusrDHHI06imuhlRWaim0WIegcUSa)nNhmuhN264gwbmu5eEjHH2JORa3aE4b4XUaOrEIWxCrHfh(nYNZb8fxucpgcuWxH6CWGyOghew5uurkQqTusrDyudoHtvMIkXqSqSFpgcYfHlWq7ERrdged1OIed1hKgUSa)nNhKUV8f8gQxFq6(sssIG0J0POouePtrfPOcupuV(G0Wf78aGkWnq96ds33rA15iVV7EoiKgUGd47B3nv8bP7E)EpCQG018msxOi8bas7fKwUtYkuRQb1RpiDFhPvNJ8(U75Gq6Rl8Bq64q6YUNdKU29i9CrvKgKY3tinCXnBxfYG61hKUVJ0WLAnKUVXdGfH09T7jK(6c)gdgA5LOGvadTstYpFyfWkRgwbmeld)gmK4DtfFS57fXq0WGlQHvfh4adbs8JvaRSAyfWq0WGlQHvfdjFpO3zmu6inOqoBaj(T57fncDyiwg(nyiqIFB(ErCGvofScyiwg(nyON3O5ek28tdCnnmenm4IAyvXbwz1JvadrddUOgwvmK89GENXqPJ0TxWBgjhjeVrwqIFKggsNos3EbVzUKvcXBKfK4hdXYWVbdjVz7Qq2yNSLo)9OGdSYWjwbmenm4IAyvXqY3d6DgdvdPbfYzZZB0CcfB(PbUMMrOdPRxhPthPL3gn8eMnAI90EKUkgILHFdgcK(c9vWbwzvIvadrddUOgwvmK89GENXq1qAqHC288gnNqXMFAGRPze6q661r60rA5TrdpHzJMypThPRIHyz43GH8rY)WHFdoWkdhWkGHOHbxudRkgs(EqVZyOAiD6iD7cd34UW3iBjHFrBJfzaKjCzfFaG0Wq60rAwg(ngUXDHVr2sc)I2glYaiJp28YbShinmKUgsNos3UWWnUl8nYws4x0Ut8YeUSIpaq661r62fgUXDHVr2sc)I2DIxMNezFkiD)iT6r6QiD96iD7cd34UW3iBjHFrBJfzaKPeSScsNksREKggs3UWWnUl8nYws4x02yrgazEsK9PG0PI0QePHH0TlmCJ7cFJSLe(fTnwKbqMWLv8basxfdXYWVbdXnUl8nYws4xehyLvhyfWq0WGlQHvfdjFpO3zm0t5Nk7m4Iq661r62fMy)5YUfK43ucwwbPtfPvpsxVosxdPBxyI9Nl7wqIFtjyzfKovKgorAyi9lmu(EaKzjKZSpzHc1SKi4ZsYqWDbVRJAiDvKUEDKMLHVrwAirNkiD)arA4edXYWVbdf7px2TGe)4aRS6cRagIggCrnSQyi57b9oJHQH01qAqHC2aGxSmCPfGa)nNhJqhsxfPHH0Sm8nYsdj6ubPtfPtbPRI01RJ01q6AinOqoBaWlwgU0cqG)MZJrOdPRI0Wq60r62fgX7MS)KjCzfFaG0WqAwg(gzPHeDQG09J0QH0Wq6GFauycxKSXzBoH09J0QLcsxfdXYWVbdjE3K9NWbw5(kwbmenm4IAyvXqY3d6DgdvdPBxyeVBY(tMNezFkiDQarA1J0Wq6AinOqoBaWlwgU0cqG)MZJrOdPRI0WqAwg(gzPHeDQG09J0QePHH0b)aOWeUizJZ2CcP7hPvlfKUkgILHFdgs8Uj7pHdSYQPcScyiAyWf1WQIHKVh07mg6zaKPrzx6bs3psRMkqAyiDHIWhafJipawKv8EcdXYWVbdjYdGfHdSYQPgwbmenm4IAyvXqY3d6DgdvdPFk)uzNbxesddPzz4BKLgs0PcsNksNcsddPd(bqHjCrYgNT5es3psRwkiDvKUEDKUgsNos3UWiE3K9NmHlR4daKggsZYW3ilnKOtfKUFKwnKggsh8dGct4IKnoBZjKUFKwTuq6Qyiwg(nyiX7MS)eoWkRwkyfWq0WGlQHvfdjFpO3zmeOqoB8rY)WHFJfGa)nNh7LTcF5KM2LminmKguiNnG0xOVIfK430UKbPHH0Sm8nYsdj6ubP7hisdNyiwg(nyOsI3rwqIFCGvwn1JvadrddUOgwvmK89GENXqGc5SXhj)dh(ngHoKggsZYW3ilnKOtfKovKofmeld)gmKilSWbwz1GtScyiAyWf1WQIHKVh07mgQgsdkKZMcVXaiR8eb5GNWucwwbP7hisRgsxfPHH01qAqHC2e3f7wEAw5ItmcDiDvKggsdkKZgFK8pC43ye6qAyinldFJS0qIovqAGiDkyiwg(nyirwyHdSYQPsScyiAyWf1WQIHKVh07mgcuiNn(i5F4WVXi0H0WqAwg(gzPHeDQG0PcePvpgILHFdgsKhalchyLvdoGvadrddUOgwvmK89GENXq1q6AiDnKguiNnXDXULNMvU4etjyzfKUFGiDkiDvKUEDKUgsdkKZM4Uy3YtZkxCIrOdPHH0Gc5SjUl2T80SYfNyEsK9PG0PI0QzujsxfPRxhPRH0Gc5SPWBmaYkprqo4jmLGLvq6(bI0QhPRI0vrAyinldFJS0qIovq6urA1J0vXqSm8BWqISWchyLvtDGvadrddUOgwvmK89GENXqSm8nYsdj6ubP7hPvddXYWVbdf7px2TGe)4aRSAQlScyiAyWf1WQIHKVh07mgQgsxdPFgaH0PI09vvG0vrAyinldFJS0qIovq6urA1J0vr661r6AiDnK(zaesNksRUujsxfPHH0Sm8nYsdj6ubPtfPvpsddPdErtykNWYEzBSt289ujm0WGlQH0vXqSm8BWqI8ayr4aRSA9vScyiAyWf1WQIHKVh07mgQDHj2FUSBbj(nLGLvq6(r6uWqSm8BWqDcRn6D4kHHKPjxKn4haffSYQHdSYPOcScyiwg(nyOy)5YUfK4hdrddUOgwvCGvof1WkGHOHbxudRkgs(EqVZyiwg(gzPHeDQG0PI0QhdXYWVbdjYclCGvoLuWkGHyz43GHkjEhzbj(Xq0WGlQHvfhyLtr9yfWq0WGlQHvfdjFpO3zm0ZaitJYU0dKovKgovbsddPbfYzJ)3KfEZtISpfKovKwfgvIHyz43GH8)MSWJdCGHe9WbWHFdwbSYQHvadrddUOgwvmK89GENXq(iprFayBSidGSQSG09J0(Ftw4TnwKbq2y)PY(TAinmKguiNn(Ftw4npjY(uq6urA1J0WTi9oxccdXYWVbd5)nzHhhyLtbRagIggCrnSQyi57b9oJHcEQ4daKggsVt8k2nDYaPtfPHdQedXYWVbd90qj8chyLvpwbmenm4IAyvXqY3d6Dgdf8uXhainmKEN4vSB6KbsNksdhujgILHFdgk)0axDQzFcan0ZHFdoWkdNyfWq0WGlQHvfdjFpO3zmunKoDKU9cEZi5iH4nYcs8J0Wq60r62l4nZLSsiEJSGe)iDvKUEDKMLHVrwAirNkiD)ar6uWqSm8BWqKy3LqVf8MgoWkRsScyiAyWf1WQIHKVh07mgk4PIpaqAyi9oXRy30jdKovKwDOsKggs7J8e9bGTXImaYQYcs3psRcJAinClsVt8k2nImCedXYWVbdbYFLsfFWbwz4awbmenm4IAyvXqY3d6DgdbkKZMIWV5B8Y6tj8rgft7sgKggsdkKZgq(RuQ4JPDjdsddP3jEf7MozG0PI0WbvG0WqAFKNOpaSnwKbqwvwq6(rAvysrLinClsVt8k2nImCedXYWVbdve(nFJxwFkHpYOGdCGHKCKq8gHvaRSAyfWqSm8BWqD)LSWq0WGlQHvfhyLtbRagIggCrnSQyi57b9oJHshPbfYzJKdB(ErJqhgILHFdgsYHnFVioWkREScyiAyWf1WQIHKVh07mgcuiNnD)LSmcDyiwg(nyONRq4aRmCIvadrddUOgwvmK89GENXqbVOjm7e)H9Y2yNSj(QzOHbxudPHH0PJ0Gc5SzN4pSx2g7KnXxnJqhgILHFdgAN4pSx2g7KnXxnCGvwLyfWq0WGlQHvfdjFpO3zmu7f8MrYrcXBKfK4hdXYWVbdrIDxc9wWBA4aRmCaRagIggCrnSQyi57b9oJHAVG3msosiEJSGe)yiwg(nyi5nBxfYg7KT05VhfCGvwDGvadrddUOgwvmK89GENXqTlmV3zEk)uzNbxesddPLNi4z7oFIcs3pqKgoXqSm8BWqV3HdSYQlScyiAyWf1WQIHKVh07mgsEIGNT78jkiD)arA4edXYWVbdLP)K(juSGEq4aRCFfRagIggCrnSQyi57b9oJHQH0PJ0TlmCJ7cFJSLe(fTnwKbqMWLv8basddPthPzz43y4g3f(gzlj8lABSidGm(yZlhWEG0Wq6AiD6iD7cd34UW3iBjHFr7oXlt4Yk(aaPRxhPBxy4g3f(gzlj8lA3jEzEsK9PG09J0QhPRI01RJ0TlmCJ7cFJSLe(fTnwKbqMsWYkiDQiT6rAyiD7cd34UW3iBjHFrBJfzaK5jr2NcsNksRsKggs3UWWnUl8nYws4x02yrgazcxwXhaiDvmeld)gme34UW3iBjHFrCGvwnvGvadrddUOgwvmK89GENXqTlmpxHmpLFQSZGlcPHH0Yte8SDNprbPtfPHtmeld)gm0ZviCGvwn1WkGHOHbxudRkgs(EqVZyi5jcE2UZNOG0PI0QedXYWVbdv2FQHdCGHwPj5NLyfWkRgwbmeld)gmKKdB(Ermenm4IAyvXboWqnkZcRaRawz1WkGHyz43GHkvewllix2Xq0WGlQHvfhyLtbRagIggCrnSQyi57b9oJHshPbfYzt3FjlJqhgILHFdgsOqwpiXcoWkREScyiAyWf1WQIHKVh07mgQgsxdPRH0bVOjm7e)H9Y2yNSj(QzOHbxudPHH0Gc5SzN4pSx2g7KnXxnJqhsxfPHH01q62l4nJKJeI3iliXpsxVos3EbVzUKvcXBKfK4hPRI0Wq60rAqHC209xYYi0H0vr661r6AiDnKguiNnG0xOVIfK43i0H01RJ0Gc5SXhj)dh(nwac83CESx2k8LtAe6q6QinmKUgsNos3EbVzKCKq8gzbj(rAyiD6iD7f8M5swjeVrwqIFKUksxfPRIHyz43GH6UWVbhyLHtScyiAyWf1WQIHyz43GHEHXYYWVXU8sGHKVh07mgQ9cEZi5iH4nYcs8J0WqAqHC2i5WMVx0i0HHwEjSdlsyijhjeVr4aRSkXkGHOHbxudRkgILHFdg6fglld)g7Ylbgs(EqVZyO2l4nZLSsiEJSGe)inmKguiNnI3nv8XMVx0i0HHwEjSdlsyOlzLq8gHdSYWbScyiAyWf1WQIHyz43GHEHXYYWVXU8sGHKVh07mgQgsxdPFHHY3dGmR0K8ZfBEru4dalGLl2vidb3f8UoQH0vrAyiDnKo4fnHbKx8ijlNZ(4rAgAyWf1q6QinmKUgsdkKZMvAs(5InVik8bGfWYf7kKrOdPRI0Wq6AinOqoBwPj5Nl28IOWhawalxSRqMNezFkiDQar6uq6QiDvm0YlHDyrcdTstYpF4aRS6aRagIggCrnSQyiwg(nyOxySSm8BSlVeyi57b9oJHQH01q6xyO89aiZknj)CXMxef(aWcy5IDfYqWDbVRJAiDvKggsxdPdErtyY0ZllNZ(4rAgAyWf1q6QinmKUgsdkKZMvAs(5InVik8bGfWYf7kKrOdPRI0Wq6AinOqoBwPj5Nl28IOWhawalxSRqMNezFkiDQar6uq6QiDvm0YlHDyrcdTstYplXbwz1fwbmenm4IAyvXqSm8BWqVWyzz43yxEjWqY3d6DgdvOi8bqXu29CyZ3BL3SDviKggsxdPRH0bVOjmG8Ihjz5C2hpsZqddUOgsxfPHH01q60r62l4nJKJeI3iliXpsxfPHH01q60r62l4nZLSsiEJSGe)iDvKggsxdPL3gn8eMXbSh2mtinmKwE3QDjJrEZ2vHSXozlD(7rX8Ki7tbPtfisRgsxfPRIHwEjSdlsyOtEZ2vHWbw5(kwbmenm4IAyvXqSm8BWqVWyzz43yxEjWqY3d6DgdvOi8bqXu29CyZ3BL3SDviKggsxdPRH0bVOjmz65LLZzF8indnm4IAiDvKggsxdPthPBVG3msosiEJSGe)iDvKggsxdPthPBVG3mxYkH4nYcs8J0vrAyiDnKwEB0WtyghWEyZmH0WqA5DR2Lmg5nBxfYg7KT05VhfZtISpfKovGiTAiDvKUkgA5LWoSiHHKYB2UkeoWkRMkWkGHOHbxudRkgILHFdgsYRLLLHFJD5LadT8syhwKWqIE4a4WVbhyLvtnScyiAyWf1WQIHyz43GHEHXYYWVXU8sGHwEjSdlsyiqIFCGdmu3tYteKdScyLvdRagILHFdgQIpTNA2sN)EuWq0WGlQHvfhyLtbRagIggCrnSQyi57b9oJHafYzJKdB(ErJqhsddPBVG3msosiEJSGe)yiwg(nyOU)sw4aRS6XkGHOHbxudRkgs(EqVZyO0rAqHC2WtA289IgHoKggsxdPthPBVG3msosiEJSGe)iD96inOqoBKCyZ3lAAxYG0vrAyiDnKoDKU9cEZCjReI3iliXpsxVosdkKZgX7Mk(yZ3lAAxYG0vXqSm8BWqGe)289I4aRmCIvadrddUOgwvmK89GENXqbVOjm7e)H9Y2yNSj(QzOHbxudPHH01q62l4nJKJeI3iliXpsddPbfYzJKdB(ErJqhsxVos3EbVzUKvcXBKfK4hPHH0Gc5Sr8UPIp289IgHoKUEDKguiNnI3nv8XMVx0i0H0Wq6Gx0egqEXJKSCo7JhPzOHbxudPRIHyz43GH2j(d7LTXozt8vdhyLvjwbmenm4IAyvXqY3d6DgdbkKZgX7Mk(yZ3lAe6qAyiD7f8M5swjeVrwqIFKggsNoslVnA4jmJdypSzMWqSm8BWqjph74aRmCaRagIggCrnSQyi57b9oJHafYzJ4DtfFS57fncDinmKU9cEZCjReI3iliXpsddPL3gn8eMXbSh2mtyiwg(nyOsWF2Fch4adjVB1UKPGvaRSAyfWqSm8BWqDx43GHOHbxudRkoWkNcwbmeld)gme46UMnl8PHHOHbxudRkoWkREScyiwg(nyiq6l0xXhayiAyWf1WQIdSYWjwbmeld)gme)sEiBC)ttGHOHbxudRkoWkRsScyiwg(nyOLdypkw4McnaI0eyiAyWf1WQIdSYWbScyiwg(nyOS)e46UggIggCrnSQ4aRS6aRagILHFdgIhjvINxwjVwyiAyWf1WQIdSYQlScyiAyWf1WQIHKVh07mgcuiNnGe)289IgHomeld)gme47Ly5daBw4Xbw5(kwbmenm4IAyvXqY3d6DgdvdPBxyeVBY(tMWLv8basxVosZYW3ilnKOtfKUFKwnKUksddPBxyI9Nl7wqIFt4Yk(aadXYWVbd5JK)Hd)gCGvwnvGvadXYWVbdbsFH(kyiAyWf1WQIdSYQPgwbmenm4IAyvXqSm8BWqY0KRl(BCPfCXLadr5mjd7WIegsMMCDXFJlTGlUe4aRSAPGvadXYWVbdjuiRhKybdrddUOgwvCGdm0jVz7QqyfWkRgwbmeld)gmK4DtfFS57fXq0WGlQHvfhyLtbRagILHFdgsEZ2vHSXozlD(7rbdrddUOgwvCGdmKuEZ2vHWkGvwnScyiwg(nyijh289IyiAyWf1WQIdSYPGvadXYWVbdjVz7Qq2yNSLo)9OGHOHbxudRkoWbg6swjeVryfWkRgwbmenm4IAyvXqY3d6DgdLosdkKZgX7Mk(yZ3lAe6WqSm8BWqI3nv8XMVxehyLtbRagIggCrnSQyi57b9oJHcErty2j(d7LTXozt8vZqddUOgsddPthPbfYzZoXFyVSn2jBIVAgHomeld)gm0oXFyVSn2jBIVA4aRS6XkGHyz43GHkb)fHhaHHOHbxudRkoWkdNyfWq0WGlQHvfdjFpO3zmu5ewG(0mz)lHTeVxHm0WGlQHHyz43GHK3SDviBSt2sN)EuWbwzvIvadrddUOgwvmK89GENXqTxWBMlzLq8gzbj(XqSm8BWqKy3LqVf8MgoWkdhWkGHOHbxudRkgs(EqVZyOAiD6iD7cd34UW3iBjHFrBJfzaKjCzfFaG0Wq60rAwg(ngUXDHVr2sc)I2glYaiJp28YbShinmKUgsNos3UWWnUl8nYws4x0Ut8YeUSIpaq661r62fgUXDHVr2sc)I2DIxMNezFkiD)iT6r6QiD96iD7cd34UW3iBjHFrBJfzaKPeSScsNksREKggs3UWWnUl8nYws4x02yrgazEsK9PG0PI0QePHH0TlmCJ7cFJSLe(fTnwKbqMWLv8basxfdXYWVbdXnUl8nYws4xehyLvhyfWq0WGlQHvfdjFpO3zm0t5Nk7m4IWqSm8BWqfHj7pHHKPjxKn4haffSYQHdSYQlScyiAyWf1WQIHKVh07mg6P8tLDgCriD96inOqoBaWlwgU0cqG)MZJrOddXYWVbdjE3K9NWqY0KlYg8dGIcwz1Wbw5(kwbmenm4IAyvXqY3d6DgdjVnA4jmJdypSzMqAyinjxExHm8KMDi4yGHyz43GHkb)z)jCGvwnvGvadrddUOgwvmK89GENXqPJ0YBJgEcZ4a2dBMjKggstYL3vidpPzhcogyiwg(nyOKNJDCGvwn1WkGHOHbxudRkgs(EqVZyOAinOqoBi5Y7kKDjm8Be6q661rAqHC2qYL3viB5w8Be6q6Qyiwg(nyi5nBxfYg7KT05VhfCGvwTuWkGHOHbxudRkgs(EqVZyOAinjxExHm(yxcd)iD96injxExHmLBXVDi4yG0vr661r6AinjxExHm(yxcd)inmKguiNnLG)IWdGSKy3LqVinHDjm8Be6q6Qyiwg(nyOsWF2FchyLvt9yfWqSm8BWqjph7yiAyWf1WQIdCGdm0g9f)gSYPOIuuHAPOc1fgkH)XhafmK6uS7(GAiTAQH0Sm8Bq6LxIIb1dd19x2xegQpinCzb(BopiDF5l4nuV(G09LKKebPhPtrDOisNIksrfOEOE9bPHl25bavGBG61hKUVJ0QZrEF39CqinCbhW33UBQ4ds39(9E4ubPR5zKUqr4daK2liTCNKvOwvdQxFq6(osRoh59D3ZbH0xx43G0XH0LDphiDT7r65IQiniLVNqA4IB2UkKb1RpiDFhPHl1AiDFJhalcP7B3ti91f(ngupuV(G0Q7HJKuiOgsds57jKwEIGCG0GeaFkgKgUKusDrbPNB6778lMfwinld)McsFZkndQhld)MIP7j5jcYHsaHVIpTNA2sN)Euq9yz43umDpjprqouci8D)LSu0ZabfYzJKdB(ErJqhS2l4nJKJeI3iliXpQhld)MIP7j5jcYHsaHhK43MVxurpdmDqHC2WtA289IgHoy1sV9cEZi5iH4nYcs8xVoOqoBKCyZ3lAAxYufwT0BVG3mxYkH4nYcs8xVoOqoBeVBQ4JnFVOPDjtvupwg(nft3tYteKdLac)oXFyVSn2jBIVAk6zGbVOjm7e)H9Y2yNSj(QzOHbxudwT2l4nJKJeI3iliXpmqHC2i5WMVx0i0vVE7f8M5swjeVrwqIFyGc5Sr8UPIp289IgHU61bfYzJ4DtfFS57fncDWcErtya5fpsYY5SpEKMHggCrTQOESm8BkMUNKNiihkbe(KNJDf9mqqHC2iE3uXhB(ErJqhS2l4nZLSsiEJSGe)WsxEB0WtyghWEyZmH6XYWVPy6EsEIGCOeq4lb)z)jf9mqqHC2iE3uXhB(ErJqhS2l4nZLSsiEJSGe)WK3gn8eMXbSh2mtOEOE9bPv3dhjPqqnKM2OpnKoCrcPJDcPzzCps7fKM3yFXGlYG6XYWVPaSuryTSGCzh1JLHFtrjGWluiRhKyrrpdmDqHC209xYYi0H6XYWVPOeq47UWVrrpdSwTAbVOjm7e)H9Y2yNSj(QzOHbxudgOqoB2j(d7LTXozt8vZi0vfwT2l4nJKJeI3iliXF96TxWBMlzLq8gzbj(RclDqHC209xYYi0vTE9A1afYzdi9f6Rybj(ncD1RdkKZgFK8pC43ybiWFZ5XEzRWxoPrORkSAP3EbVzKCKq8gzbj(HLE7f8M5swjeVrwqI)QvRI61hKMLHFtrjGW)cJLLHFJD5LqXHfjGsosiEJu0ZaBVG3msosiEJSGe)WQvtE3QDjJj2FUSBbj(npjY(u6xfWK3TAxYye5bWImpjY(u6xfWAxyeVBY(tMNezFk9deGSPKkmQe2ZaOuHtvaduiNn(i5F4WVXcqG)MZJ9YwHVCst7sgyGc5SbK(c9vSGe)M2LmWafYzdaEXYWLwac83CEmTlzQwVEnqHC2i5WMVx0i0bJg6bKw)POYQ1Rx7fgkFpaYCCSBVSn2jlTA0BBVG3meCxW76OgS0bfYzZXXU9Y2yNS0QrVT9cEZi0bRgOqoBKCyZ3lAe6Grd9asR)uur1Q1Rx7fgkFpaYCCSBVSn2jlTA0BBVG3meCxW76OgmqHC2St8h2lBJDYM4RM5jr2NsQQPIQWQbkKZgjh289IgHoy0qpG06pfvuTE9AYBJgEctL0ENhyY7wTlzmKy3LqVf8MM5jr2NsQavdgldFJS0qIovsnLQvr9yz43uuci8VWyzz43yxEjuCyrcOKJeI3if9mW2l4nJKJeI3iliXpmqHC2i5WMVx0i0H61hKMLHFtrjGW)cJLLHFJD5LqXHfjGxYkH4nsrpdS9cEZCjReI3iliXpSA1K3TAxYyI9Nl7wqIFZtISpL(vbm5DR2LmgrEaSiZtISpL(vbSNbqPMIkGbkKZgFK8pC43yAxYaduiNnG0xOVIfK430UKPA961afYzJ4DtfFS57fncDWAxykct2FY8u(PYodUOQ1RxduiNnI3nv8XMVx0i0bduiNn7e)H9Y2yNSj(Qze6QwVEnqHC2iE3uXhB(ErJqhSAGc5SHKlVRq2LWWVrOREDqHC2qYL3viB5w8Be6Qcl9xyO89aiZXXU9Y2yNS0QrVT9cEZqWDbVRJAvRxV2lmu(EaK54y3EzBStwA1O32EbVzi4UG31rnyPdkKZMJJD7LTXozPvJEB7f8MrORA961K3gn8eMXbSh2mtWK3TAxYyK3SDviBSt2sN)EumpjY(usfOAvRxVM82OHNWujT35bM8Uv7sgdj2Dj0BbVPzEsK9PKkq1GXYW3ilnKOtLutPAvupwg(nfLac)lmwwg(n2LxcfhwKaEjReI3if9mW2l4nZLSsiEJSGe)WafYzJ4DtfFS57fncDOE9bPvNzKoHq6DEJqA1DPj5Nr6fbGMg)PH0eCxW76OgsZtdPb5fpscP5C2hpsdP5csZiDWlAcKoHq6sIhYDK2N4qAX7Mk(G057fr6KDAOn6r6yNq6vAs(zKguiNrAVG0CG03J0G06sq6uq6cjr9yz43uuci8VWyzz43yxEjuCyrc4knj)8PONbwR2lmu(EaKzLMKFUyZlIcFaybSCXUczi4UG31rTQWQf8IMWaYlEKKLZzF8indnm4IAvHvduiNnR0K8ZfBEru4dalGLl2viJqxvy1afYzZknj)CXMxef(aWcy5IDfY8Ki7tjvGPuTkQxFqA1zgPtiKEN3iKwDxAs(zKEraOPXFAinb3f8UoQH080q6m98cP5C2hpsdP5csZiDWlAcKoHq6sIhYDK2N4q6m98cPZ3lI0j70qB0J0XoH0R0K8ZinOqoJ0EbP5aPVhPbP1LG0PG0fsI6XYWVPOeq4FHXYYWVXU8sO4WIeWvAs(zPIEgyTAVWq57bqMvAs(5InVik8bGfWYf7kKHG7cExh1QcRwWlActMEEz5C2hpsZqddUOwvy1afYzZknj)CXMxef(aWcy5IDfYi0vfwnqHC2SstYpxS5frHpaSawUyxHmpjY(usfykvRI61hKwDMr6eQV4jKMr6XbShzMqAEAiDcH0TB6lcKoHNaPJdPLCKq8gb)LSsiEJuKNgsNqi9oVriniV4rsWNPNxinNZ(4rAiDWlAcQPisRUDNgAJEKwEZ2vHqAzdP9csl0H0jesxs8qUJ0(ehsZ5SpEKgsNVxePJdPLCjqApueP3PNqAX7Mk(G057fnOESm8Bkkbe(xySSm8BSlVekoSib8K3SDvif9mWcfHpakMYUNdB(ER8MTRcbRwTGx0egqEXJKSCo7JhPzOHbxuRkSAP3EbVzKCKq8gzbj(RcRw6TxWBMlzLq8gzbj(RcRM82OHNWmoG9WMzcM8Uv7sgJ8MTRczJDYw683JI5jr2NsQavRAvuV(G0QZmsNq9fpH0mspoG9iZesZtdPtiKUDtFrG0j8eiDCiTKJeI3i4VKvcXBKI80q6ecP35ncPb5fpsc(m98cP5C2hpsdPdErtqnfrA1T70qB0J0YB2UkeslBiTxqAHoKoHq6sIhYDK2N4qAoN9XJ0q689IiDCiTKlbs7HIi9o9esl5iFVisNVx0G6XYWVPOeq4FHXYYWVXU8sO4WIeqP8MTRcPONbwOi8bqXu29CyZ3BL3SDviy1Qf8IMWKPNxwoN9XJ0m0WGlQvfwT0BVG3msosiEJSGe)vHvl92l4nZLSsiEJSGe)vHvtEB0WtyghWEyZmbtE3QDjJrEZ2vHSXozlD(7rX8Ki7tjvGQvTkQhld)MIsaHxYRLLLHFJD5LqXHfjGIE4a4WVb1JLHFtrjGW)cJLLHFJD5LqXHfjGGe)OEOESm8BkgqIFGGe)289Ik6zGPdkKZgqIFB(ErJqhQhld)MIbK4xjGW)8gnNqXMFAGRPH6XYWVPyaj(vci8YB2UkKn2jBPZFpkk6zGP3EbVzKCKq8gzbj(HLE7f8M5swjeVrwqIFupwg(nfdiXVsaHhK(c9vSGe)k6zG1afYzZZB0CcfB(PbUMMrORE90L3gn8eMnAI90(QOESm8BkgqIFLacVps(ho8Bu0ZaRbkKZMN3O5ek28tdCnnJqx96PlVnA4jmB0e7P9vr9yz43umGe)kbeEUXDHVr2sc)Ik6zG1sVDHHBCx4BKTKWVOTXImaYeUSIpaGLold)gd34UW3iBjHFrBJfzaKXhBE5a2dy1sVDHHBCx4BKTKWVODN4LjCzfFauVE7cd34UW3iBjHFr7oXlZtISpL(vF161Bxy4g3f(gzlj8lABSidGmLGLvsv9WAxy4g3f(gzlj8lABSidGmpjY(usvLWAxy4g3f(gzlj8lABSidGmHlR4dGQOESm8BkgqIFLacFS)Cz3cs8RyWpakSEg4t5Nk7m4IQxVDHj2FUSBbj(nLGLvsv91RxRDHj2FUSBbj(nLGLvsfoH9cdLVhazwc5m7twOqnljc(SKmeCxW76Ow161zz4BKLgs0Ps)aHtupwg(nfdiXVsaHx8Uj7pPONbwRgOqoBaWlwgU0cqG)MZJrORkmwg(gzPHeDQKAkvRxVwnqHC2aGxSmCPfGa)nNhJqxvyP3UWiE3K9NmHlR4daySm8nYsdj6uPF1Gf8dGct4IKnoBZP(vlLQOESm8BkgqIFLacV4Dt2FsrpdSw7cJ4Dt2FY8Ki7tjvGQhwnqHC2aGxSmCPfGa)nNhJqxvySm8nYsdj6uPFvcl4hafMWfjBC2Mt9Rwkvr9yz43umGe)kbeErEaSif9mWNbqMgLDPh9RMkGvOi8bqXiYdGfzfVNq9yz43umGe)kbeEX7MS)KIEgyTNYpv2zWfbJLHVrwAirNkPMcSGFauycxKSXzBo1VAPuTE9AP3UWiE3K9NmHlR4daySm8nYsdj6uPF1Gf8dGct4IKnoBZP(vlLQOESm8BkgqIFLacFjX7if9mqqHC24JK)Hd)glab(Bop2lBf(YjnTlzGbkKZgq6l0xXcs8BAxYaJLHVrwAirNk9deor9yz43umGe)kbeErwyPONbckKZgFK8pC43ye6GXYW3ilnKOtLutb1JLHFtXas8Req4fzHLIEgynqHC2u4ngazLNiih8eMsWYk9duTQWQbkKZM4Uy3YtZkxCIrORkmqHC24JK)Hd)gJqhmwg(gzPHeDQamfupwg(nfdiXVsaHxKhalsrpdeuiNn(i5F4WVXi0bJLHVrwAirNkPcu9OESm8BkgqIFLacVilSu0ZaRvRgOqoBI7IDlpnRCXjMsWYk9dmLQ1RxduiNnXDXULNMvU4eJqhmqHC2e3f7wEAw5ItmpjY(usvnJkRwVEnqHC2u4ngazLNiih8eMsWYk9du9vRcJLHVrwAirNkPQ(QOESm8BkgqIFLacFS)Cz3cs8RONbYYW3ilnKOtL(vd1JLHFtXas8Req4f5bWIu0ZaRv7zauQ9vvufgldFJS0qIovsv9vRxVwTNbqPQUuzvySm8nYsdj6ujv1dl4fnHPCcl7LTXozZ3tLWqddUOwvupwg(nfdiXVsaHVtyTrVdxjfLPjxKn4haffGQPONb2UWe7px2TGe)MsWYk9NcQhld)MIbK4xjGWh7px2TGe)OESm8BkgqIFLacVilSu0Zazz4BKLgs0PsQQh1JLHFtXas8Req4ljEhzbj(r9yz43umGe)kbeE)Vjl8k6zGpdGmnk7spsfovbmqHC24)nzH38Ki7tjvvyujQhQxFqAwg(nfLacVKxllld)g7YlHIdlsaf9WbWHFdQxFqAwg(nfLacFIVAw5o)aiuV(G0Sm8BkkbeEjVwwwg(n2LxcfhwKakVB1UKPG61hKMLHFtrjGWlYclf9mWNbqMgLDPhPMIkGXYW3ilnKOtLuHtuV(G0Sm8BkkbeErwyPONb(maY0OSl9i1uubmQuOrsg5n5LldlpnBjEptgrgU59WshuiNnLD(7OHAw5ItkgHouV(G0Sm8BkkbeE)Vjl8k6zGYReavr961Ega1V8kbmgUsVhKzXPrp1SI8qgAyWf1GXYW3ilnKOtL(tPkQxFqAwg(nfLacFNWAJEhUskg8dGcRNb2UWe7px2TGe)MsWYkaBxyI9Nl7wqIFJidhTLGLvkOE9bPzz43uuci8I3nz)jfd(bqH1ZaBxyeVBY(tMNYpv2zWfbJLHVrwAirNkPMcQxFqAwg(nfLacFS)CzxrpdSgOqoB8rY)WHFJPDjdmwg(gzPHeDQ0VAvRxVgOqoB8rY)WHFJrOdgldFJS0qIov6hoRI61hKMLHFtrjGWxs8osrpdeuiNn(i5F4WVX0UKbgldFJS0qIov6hor96dsZYWVPOeq4f5bWIu0ZaBxyI9Nl7wqIFt4Yk(aa1Rpinld)MIsaHx8Uj7pPyWpakSEgiOqoBaWlwgU0cqG)MZJrOdgldFJS0qIovsnfuV(G0Sm8Bkkbe(y)5YoQxFqA1n81cPt8yhP7B3nz)jKoXJDKwDZl6BWXuq96dsZYWVPOeq4fVBY(tk6zGmCLEpit3LqV9Y2yNSI3nMNNk9Rgmwg(gzPHeDQaunuV(G0Sm8Bkkbe(sI3rOEOESm8BkgrpCaC43a0)BYcVIEgOpYt0ha2glYaiRkl97)nzH32yrgazJ9Nk73QbduiNn(Ftw4npjY(usv9WT7Cjiupwg(nfJOhoao8Buci8pnucVu0ZadEQ4day7eVIDtNmsfoOsupwg(nfJOhoao8Buci85Ng4Qtn7taOHEo8Bu0ZadEQ4day7eVIDtNmsfoOsupwg(nfJOhoao8Buci8Ky3LqVf8MMIEgyT0BVG3msosiEJSGe)WsV9cEZCjReI3iliXF161zz4BKLgs0Ps)atb1JLHFtXi6HdGd)gLacpi)vkv8rrpdm4PIpaGTt8k2nDYiv1HkH5J8e9bGTXImaYQYs)QWOgC7oXRy3iYWrupwg(nfJOhoao8Buci8fHFZ34L1Ns4Jmkk6zGGc5SPi8B(gVS(ucFKrX0UKbgOqoBa5VsPIpM2LmW2jEf7MozKkCqfW8rEI(aW2yrgazvzPFvysrLWT7eVIDJidhr9q9yz43umY7wTlzka7UWVb1JLHFtXiVB1UKPOeq4bx31SzHpnupwg(nfJ8Uv7sMIsaHhK(c9v8baQhld)MIrE3QDjtrjGWZVKhYg3)0eOESm8Bkg5DR2LmfLac)YbShflCtHgarAcupwg(nfJ8Uv7sMIsaHp7pbUURH6XYWVPyK3TAxYuuci88iPs88Yk51c1JLHFtXiVB1UKPOeq4bFVelFayZcVIEgiOqoBaj(T57fncDOESm8Bkg5DR2LmfLacVps(ho8Bu0ZaR1UWiE3K9NmHlR4dG61zz4BKLgs0Ps)Qvfw7ctS)Cz3cs8BcxwXhaOESm8Bkg5DR2LmfLacpi9f6RG6XYWVPyK3TAxYuuci8cfY6bjQiLZKmSdlsaLPjxx834sl4IlbQhld)MIrE3QDjtrjGWluiRhKyb1d1JLHFtXi5iH4ncy3Fjlupwg(nfJKJeI3iLacVKdB(Erf9mW0bfYzJKdB(ErJqhQhld)MIrYrcXBKsaH)5kKIEgiOqoB6(lzze6q9yz43umsosiEJuci87e)H9Y2yNSj(QPONbg8IMWSt8h2lBJDYM4RMHggCrnyPdkKZMDI)WEzBSt2eF1mcDOESm8BkgjhjeVrkbeEsS7sO3cEttrpdS9cEZi5iH4nYcs8J6XYWVPyKCKq8gPeq4L3SDviBSt2sN)Euu0ZaBVG3msosiEJSGe)OESm8BkgjhjeVrkbe(37u0ZaBxyEVZ8u(PYodUiyYte8SDNprPFGWjQhld)MIrYrcXBKsaHpt)j9tOyb9Gu0ZaLNi4z7oFIs)aHtupwg(nfJKJeI3iLacp34UW3iBjHFrf9mWAP3UWWnUl8nYws4x02yrgazcxwXhaWsNLHFJHBCx4BKTKWVOTXImaY4JnVCa7bSAP3UWWnUl8nYws4x0Ut8YeUSIpaQxVDHHBCx4BKTKWVODN4L5jr2Ns)QVA96TlmCJ7cFJSLe(fTnwKbqMsWYkPQEyTlmCJ7cFJSLe(fTnwKbqMNezFkPQsyTlmCJ7cFJSLe(fTnwKbqMWLv8bqvupwg(nfJKJeI3iLac)Zvif9mW2fMNRqMNYpv2zWfbtEIGNT78jkPcNOESm8BkgjhjeVrkbe(Y(tnf9mq5jcE2UZNOKQkr9q9yz43ums5nBxfcOKdB(Erupwg(nfJuEZ2vHuci8YB2UkKn2jBPZFpkOEOESm8BkMvAs(zjqjh289IOEOESm8BkMvAs(5dO4DtfFS57fr9q9yz43umN8MTRcbu8UPIp289IOESm8BkMtEZ2vHuci8YB2UkKn2jBPZFpkOEOESm8BkMlzLq8gbu8UPIp289Ik6zGPdkKZgX7Mk(yZ3lAe6q9yz43umxYkH4nsjGWVt8h2lBJDYM4RMIEgyWlAcZoXFyVSn2jBIVAgAyWf1GLoOqoB2j(d7LTXozt8vZi0H6XYWVPyUKvcXBKsaHVe8xeEaeQhld)MI5swjeVrkbeE5nBxfYg7KT05Vhff9mWYjSa9PzY(xcBjEVczOHbxud1JLHFtXCjReI3iLacpj2Dj0BbVPPONb2EbVzUKvcXBKfK4h1JLHFtXCjReI3iLacp34UW3iBjHFrf9mWAP3UWWnUl8nYws4x02yrgazcxwXhaWsNLHFJHBCx4BKTKWVOTXImaY4JnVCa7bSAP3UWWnUl8nYws4x0Ut8YeUSIpaQxVDHHBCx4BKTKWVODN4L5jr2Ns)QVA96TlmCJ7cFJSLe(fTnwKbqMsWYkPQEyTlmCJ7cFJSLe(fTnwKbqMNezFkPQsyTlmCJ7cFJSLe(fTnwKbqMWLv8bqvupwg(nfZLSsiEJuci8fHj7pPOmn5ISb)aOOaunf9mWNYpv2zWfH6XYWVPyUKvcXBKsaHx8Uj7pPOmn5ISb)aOOaunf9mWNYpv2zWfvVoOqoBaWlwgU0cqG)MZJrOd1JLHFtXCjReI3iLacFj4p7pPONbkVnA4jmJdypSzMGrYL3vidpPzhcogOESm8BkMlzLq8gPeq4tEo2v0ZatxEB0WtyghWEyZmbJKlVRqgEsZoeCmq9yz43umxYkH4nsjGWlVz7Qq2yNSLo)9OOONbwduiNnKC5DfYUeg(ncD1RdkKZgsU8Uczl3IFJqxvupwg(nfZLSsiEJuci8LG)S)KIEgynsU8Ucz8XUeg(RxNKlVRqMYT43oeCmQwVEnsU8Ucz8XUeg(HbkKZMsWFr4bqwsS7sOxKMWUeg(ncDvr9yz43umxYkH4nsjGWN8CSJHkDKeRSAQaoXboWya]] )

end