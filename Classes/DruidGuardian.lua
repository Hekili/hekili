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

    spec:RegisterPack( "Guardian", 20201208, [[dGuwsbqijfpsPeBcu(KsjHrjjDkjXQavv5vKiZIe6wKuvSlk(fOYWijCmssltsPNrsLPbQsxJKOTbQcFJKQQXbQkDosQI1bQIY8ee3dq7tPuheuvvzHKuEiOkYevkj6IKuvQnQusQ(iOkQojjvPvQumtLss5MkLKStsudfuvv1tbzQKGVssvj7fQ)sPbtQdJAXa9yIMSuDzKnl0Nby0kvNMQvdQQkVwqnBLCBcTBf)wLHlfhhuvz5Q65smDrxNGTlL(UaJxPK68csRhuvmFjv7hYyvXkGH6CsyLRvf1QcvRvfWxJQQhvQovvjgkdTHWqnSmmdGWqdlsyi45c83DEWqnCORJ7yfWqLt4LegApZMc8m4GdGN7cGg5jcxXffwC63iFoMWvCrjCyiqbFLQ3bdIH6CsyLRvf1QcvRvfWxJQQhvQovvhgIfY97XqqUi8egA37DAWGyOovKyOTG0WZf4V78G0BLVG3rB2csVvssseKEKg(QisxRkQvfOnOnBbPHN25bavGNH2SfKw9bPvVJ8(M75KqA4joHBR6UjSpiDZ737PtfKUQhr6cLPpaqAVG0YDsgM6vmOnBbPvFqA17iVV5EojK(As)gKopKUS7XePREpspxwbPbP49esdpDt7fMmyOLxYcwbm0kuj)8HvaRSQyfWqSm9BWqI3nH9XgVxedrddUOownCItmeiXpwbSYQIvadrddUOownmK89KENXq1G0GcXObK43gVx0i0GHyz63GHaj(TX7fXjw5AXkGHyz63GHEULMtOyJpnWNqXq0WGlQJvdNyLvhwbmenm4I6y1WqY3t6Dgdvds3FbVBKCgqClzbj(rAyiDniD)f8U5cwbe3swqIFmelt)gmK8M2lmzZDYwA83ZcoXkdVyfWq0WGlQJvddjFpP3zmuvKguignp3sZjuSXNg4tOgHgKUEDKUgKwET0WtAAPj3d9r6kyiwM(nyiq6l0hgNyLvjwbmenm4I6y1WqY3t6DgdvfPbfIrZZT0CcfB8Pb(eQrObPRxhPRbPLxln8KMwAY9qFKUcgILPFdgYhj)dN(n4eRm8aRagIggCrDSAyi57j9oJHQI01G09lnCNBsVLSLa(fTDwKbqM0LH9basddPRbPzz63y4o3KElzlb8lA7SidGm(yJlhWEI0Wq6QiDniD)sd35M0BjBjGFr7oXlt6YW(aaPRxhP7xA4o3KElzlb8lA3jEzEsK9PG0BJ0QdPRG01RJ09lnCNBsVLSLa(fTDwKbqMsYYWiDiiT6qAyiD)sd35M0BjBjGFrBNfzaK5jr2NcshcsRsKggs3V0WDUj9wYwc4x02zrgazsxg2haiDfmelt)gme35M0BjBjGFrCIvw9JvadrddUOownmK89KENXqpfFQSZGlcPRxhP7xAY9Nl7wqIFtjzzyKoeKwDiD96iDvKUFPj3FUSBbj(nLKLHr6qqA4fPHH0VWqX7bqMLqmY(efku3sIGpljdb)e8MgQJ0vq661rAwMElzPHeDQG0BdePHxmelt)gmuU)Cz3cs8JtSYWxScyiAyWf1XQHHKVN07mgQksxfPbfIrdaEXY0Lwac83DEmcniDfKggsZY0BjlnKOtfKoeKUwKUcsxVosxfPRI0GcXObaVyz6slab(7opgHgKUcsddPRbP7xAeVBI(tM0LH9basddPzz6TKLgs0PcsVnsRksddPt(bqPjDrYMNT7esVnsRATiDfmelt)gmK4Dt0FcNyLvpyfWq0WGlQJvddjFpP3zmuvKUFPr8Uj6pzEsK9PG0HaePvhsddPRI0GcXObaVyz6slab(7opgHgKUcsddPzz6TKLgs0PcsVnsRsKggsN8dGst6IKnpB3jKEBKw1Ar6kyiwM(nyiX7MO)eoXkRQkWkGHOHbxuhRggs(EsVZyOQi9tXNk7m4IqAyinltVLS0qIovq6qq6ArAyiDYpaknPls28SDNq6TrAvRfPRG01RJ0vr6Aq6(LgX7MO)KjDzyFaG0WqAwMElzPHeDQG0BJ0QI0Wq6KFauAsxKS5z7oH0BJ0QwlsxbdXY0VbdjE3e9NWjwzvvfRagIggCrDSAyi57j9oJHafIrJps(ho9BSae4V78yVOv4lN00VGbPHH0GcXObK(c9HTGe)M(fminmKMLP3swAirNki92arA4fdXY0Vbdvc8gYk5eNyLvTwScyiAyWf1XQHHKVN07mgcuign(i5F40VXi0G0WqAwMElzPHeDQG0HG01IHyz63GHezHfoXkRQ6WkGHOHbxuhRggs(EsVZyOQinOqmAkCldGSYteKtEstjzzyKEBGiTQiDfKggsxfPbfIrtExUB5PBLloWi0G0vqAyinOqmA8rY)WPFJrObPHH0Sm9wYsdj6ubPbI01IHyz63GHezHfoXkRk8IvadrddUOownmK89KENXqGcXOXhj)dN(ngHgKggsZY0BjlnKOtfKoeGiT6WqSm9BWqI8ayr4eRSQQeRagIggCrDSAyi57j9oJHQI0vr6QinOqmAY7YDlpDRCXbMsYYWi92ar6Ar6kiD96iDvKguign5D5ULNUvU4aJqdsddPbfIrtExUB5PBLloW8Ki7tbPdbPv1OsKUcsxVosxfPbfIrtHBzaKvEIGCYtAkjldJ0BdePvhsxbPRG0WqAwMElzPHeDQG0HG0QdPRGHyz63GHezHfoXkRk8aRagIggCrDSAyi57j9oJHyz6TKLgs0PcsVnsRkgILPFdgk3FUSBbj(Xjwzvv)yfWq0WGlQJvddjFpP3zmuvKUks)macPdbPvpQaPRG0WqAwMElzPHeDQG0HG0QdPRG01RJ0vr6Qi9ZaiKoeKg(QsKUcsddPzz6TKLgs0PcshcsRoKggsN8IM0uoHL9I2CNSX7PsAOHbxuhPRGHyz63GHe5bWIWjwzvHVyfWq0WGlQJvddXY0Vbd1iSAP3Hpegs(EsVZyO(LMC)5YUfK43uswggP3gPRfdjdvUiBYpaklyLvfNyLvv9GvadXY0VbdL7px2TGe)yiAyWf1XQHtSY1QcScyiAyWf1XQHHKVN07mgILP3swAirNkiDiiT6WqSm9BWqISWcNyLRvvScyiwM(nyOsG3qwqIFmenm4I6y1Wjw5ARfRagIggCrDSAyi57j9oJHEgaz6u0LEI0HG0WRkqAyinOqmA8)MOWBEsK9PG0HG0QWOsmelt)gmK)3efECItmKONoao9BWkGvwvScyiAyWf1XQHHKVN07mgYh5j6daBNfzaKvLfKEBK2)BIcVTZImaYM7pv2VvhPHH0GcXOX)BIcV5jr2NcshcsRoKg(dP35ssyiwM(nyi)Vjk84eRCTyfWq0WGlQJvddjFpP3zmuYtyFaG0Wq6DIx5UPrMiDiin8qLyiwM(nyONgkGx4eRS6WkGHOHbxuhRggs(EsVZyOKNW(aaPHH07eVYDtJmr6qqA4HkXqSm9BWqXNg4JtD7taOHEo9BWjwz4fRagIggCrDSAyi57j9oJHQI01G09xW7gjNbe3swqIFKggsxds3FbVBUGvaXTKfK4hPRG01RJ0Sm9wYsdj6ubP3gisxlgILPFdgIeBUa6TG30XjwzvIvadrddUOownmK89KENXqjpH9basddP3jEL7MgzI0HG0QFvI0WqAFKNOpaSDwKbqwvwq6TrAvyufPH)q6DIx5UrK3Amelt)gmei)HlH9bNyLHhyfWq0WGlQJvddjFpP3zmeOqmAkcFR3YlRpL0hzwm9lyqAyinOqmAa5pCjSpM(fminmKEN4vUBAKjshcsdpubsddP9rEI(aW2zrgazvzbP3gPvHPwvI0WFi9oXRC3iYBngILPFdgQi8TElVS(usFKzbN4edj5mG4wcRawzvXkGHyz63GHA(lyHHOHbxuhRgoXkxlwbmenm4I6y1WqY3t6DgdvdsdkeJgjN249IgHgmelt)gmKKtB8ErCIvwDyfWq0WGlQJvddjFpP3zmeOqmAA(lyzeAWqSm9BWqphMWjwz4fRagIggCrDSAyi57j9oJHsErtA2j(t7fT5ozd8v3qddUOosddPRbPbfIrZoXFAVOn3jBGV6gHgmelt)gm0oXFAVOn3jBGV64eRSkXkGHOHbxuhRggs(EsVZyO(l4DJKZaIBjliXpgILPFdgIeBUa6TG30Xjwz4bwbmenm4I6y1WqY3t6Dgd1FbVBKCgqClzbj(XqSm9BWqYBAVWKn3jBPXFpl4eRS6hRagIggCrDSAyi57j9oJH6xAEVX8u8PYodUiKggslprWZ2C(KfKEBGin8IHyz63GHEVbNyLHVyfWq0WGlQJvddjFpP3zmK8ebpBZ5twq6TbI0WlgILPFdgks)j9tOyb9KWjwz1dwbmenm4I6y1WqY3t6DgdvfPRbP7xA4o3KElzlb8lA7SidGmPld7daKggsxdsZY0VXWDUj9wYwc4x02zrgaz8XgxoG9ePHH0vr6Aq6(LgUZnP3s2sa)I2DIxM0LH9basxVos3V0WDUj9wYwc4x0Ut8Y8Ki7tbP3gPvhsxbPRxhP7xA4o3KElzlb8lA7SidGmLKLHr6qqA1H0Wq6(LgUZnP3s2sa)I2olYaiZtISpfKoeKwLinmKUFPH7Ct6TKTeWVOTZImaYKUmSpaq6kyiwM(nyiUZnP3s2sa)I4eRSQQaRagIggCrDSAyi57j9oJH6xAEomzEk(uzNbxesddPLNi4zBoFYcshcsdVyiwM(nyONdt4eRSQQIvadrddUOownmK89KENXqYte8SnNpzbPdbPvjgILPFdgQS)uhN4edTcvYplXkGvwvScyiwM(nyijN249IyiAyWf1XQHtCIH6uKfwjwbSYQIvadXY0VbdvclSwwqUSJHOHbxuhRgoXkxlwbmenm4I6y1WqY3t6DgdvdsdkeJMM)cwgHgmelt)gmKqHSEsIfCIvwDyfWq0WGlQJvddjFpP3zmuvKUksxfPtErtA2j(t7fT5ozd8v3qddUOosddPbfIrZoXFAVOn3jBGV6gHgKUcsddPRI09xW7gjNbe3swqIFKUEDKU)cE3CbRaIBjliXpsxbPHH01G0GcXOP5VGLrObPRG01RJ0vr6QinOqmAaPVqFyliXVrObPRxhPbfIrJps(ho9BSae4V78yVOv4lN0i0G0vqAyiDvKUgKU)cE3i5mG4wYcs8J0Wq6Aq6(l4DZfSciULSGe)iDfKUcsxbdXY0Vbd1CPFdoXkdVyfWq0WGlQJvddjFpP3zmu)f8UrYzaXTKfK4hPHH0GcXOrYPnEVOrObdXY0Vbd9cJLLPFJD5LedT8sAhwKWqsodiULWjwzvIvadrddUOownmK89KENXq9xW7MlyfqClzbj(rAyinOqmAeVBc7JnEVOrObdXY0Vbd9cJLLPFJD5LedT8sAhwKWqxWkG4wcNyLHhyfWq0WGlQJvddjFpP3zmuvKUks)cdfVhazwHk5Nl24IO0hawalxSPqgc(j4nnuhPRG0Wq6QiDYlAsdiV4rswog9XZqn0WGlQJ0vqAyiDvKguignRqL8ZfBCru6dalGLl2uiJqdsxbPHH0vrAqHy0ScvYpxSXfrPpaSawUytHmpjY(uq6qaI01I0vq6kyiwM(nyOxySSm9BSlVKyOLxs7WIegAfQKF(Wjwz1pwbmenm4I6y1WqY3t6DgdvfPRI0VWqX7bqMvOs(5InUik9bGfWYfBkKHGFcEtd1r6kinmKUksN8IM0ePNxwog9XZqn0WGlQJ0vqAyiDvKguignRqL8ZfBCru6dalGLl2uiJqdsxbPHH0vrAqHy0ScvYpxSXfrPpaSawUytHmpjY(uq6qaI01I0vq6kyiwM(nyOxySSm9BSlVKyOLxs7WIegAfQKFwItSYWxScyiAyWf1XQHHKVN07mgQqz6dGIPS7X0gV3kVP9ctinmKUksxfPtErtAa5fpsYYXOpEgQHggCrDKUcsddPRI01G09xW7gjNbe3swqIFKUcsddPRI01G09xW7MlyfqClzbj(r6kinmKUkslVwA4jnJdypTrMqAyiT8Uv)cgJ8M2lmzZDYwA83ZI5jr2NcshcqKwvKUcsxbdXY0Vbd9cJLLPFJD5LedT8sAhwKWqN8M2lmHtSYQhScyiAyWf1XQHHKVN07mgQqz6dGIPS7X0gV3kVP9ctinmKUksxfPtErtAI0ZllhJ(4zOgAyWf1r6kinmKUksxds3FbVBKCgqClzbj(r6kinmKUksxds3FbVBUGvaXTKfK4hPRG0Wq6QiT8APHN0moG90gzcPHH0Y7w9lymYBAVWKn3jBPXFplMNezFkiDiarAvr6kiDfmelt)gm0lmwwM(n2Lxsm0YlPDyrcdjL30EHjCIvwvvGvadrddUOownmelt)gmKKxlllt)g7YljgA5L0oSiHHe90bWPFdoXkRQQyfWq0WGlQJvddXY0Vbd9cJLLPFJD5LedT8sAhwKWqGe)4eNyOMNKNiiNyfWkRkwbmelt)gmuyF6p1TLg)9SGHOHbxuhRgoXkxlwbmenm4I6y1WqY3t6DgdbkeJgjN249IgHgKggs3FbVBKCgqClzbj(XqSm9BWqn)fSWjwz1HvadrddUOownmK89KENXq1G0GcXOHNqTX7fncninmKUksxds3FbVBKCgqClzbj(r661rAqHy0i50gVx00VGbPRG0Wq6QiDniD)f8U5cwbe3swqIFKUEDKguignI3nH9XgVx00VGbPRGHyz63GHaj(TX7fXjwz4fRagIggCrDSAyi57j9oJHsErtA2j(t7fT5ozd8v3qddUOosddPRI09xW7gjNbe3swqIFKggsdkeJgjN249IgHgKUEDKU)cE3CbRaIBjliXpsddPbfIrJ4DtyFSX7fncniD96inOqmAeVBc7JnEVOrObPHH0jVOjnG8Ihjz5y0hpd1qddUOosxbdXY0VbdTt8N2lAZDYg4RooXkRsScyiAyWf1XQHHKVN07mgcuignI3nH9XgVx0i0G0Wq6(l4DZfSciULSGe)inmKUgKwET0WtAghWEAJmHHyz63GHcEo3Xjwz4bwbmenm4I6y1WqY3t6DgdbkeJgX7MW(yJ3lAeAqAyiD)f8U5cwbe3swqIFKggslVwA4jnJdypTrMWqSm9BWqLK)O)eoXjgsE3QFbtbRawzvXkGHyz63GHAU0VbdrddUOownCIvUwScyiwM(nyiW1DDBu4dfdrddUOownCIvwDyfWqSm9BWqG0xOpSpaWq0WGlQJvdNyLHxScyiwM(nyi(L8q28(NMedrddUOownCIvwLyfWqSm9BWqlhWEwSW)e6aePjXq0WGlQJvdNyLHhyfWqSm9BWqr)jW1DDmenm4I6y1Wjwz1pwbmelt)gmepsQKpVSsETWq0WGlQJvdNyLHVyfWq0WGlQJvddjFpP3zmeOqmAaj(TX7fncnyiwM(nyiW3l5Yha2OWJtSYQhScyiAyWf1XQHHKVN07mgQks3V0iE3e9NmPld7daKUEDKMLP3swAirNki92iTQiDfKggs3V0K7px2TGe)M0LH9bagILPFdgYhj)dN(n4eRSQQaRagILPFdgcK(c9HXq0WGlQJvdNyLvvvScyiAyWf1XQHHyz63GHKHkxx(34sl4IljgIIrsM2HfjmKmu56Y)gxAbxCjXjwzvRfRagILPFdgsOqwpjXcgIggCrDSA4eNyOtEt7fMWkGvwvScyiwM(nyiX7MW(yJ3lIHOHbxuhRgoXkxlwbmelt)gmK8M2lmzZDYwA83ZcgIggCrDSA4eNyiP8M2lmHvaRSQyfWqSm9BWqsoTX7fXq0WGlQJvdNyLRfRagILPFdgsEt7fMS5ozln(7zbdrddUOownCItm0fSciULWkGvwvScyiAyWf1XQHHKVN07mgQgKguignI3nH9XgVx0i0GHyz63GHeVBc7JnEVioXkxlwbmenm4I6y1WqY3t6DgdL8IM0St8N2lAZDYg4RUHggCrDKggsxdsdkeJMDI)0ErBUt2aF1ncnyiwM(nyODI)0ErBUt2aF1Xjwz1HvadXY0Vbdvs(lcpacdrddUOownCIvgEXkGHOHbxuhRggs(EsVZyOYjSa9PBI(xsBjFpmzOHbxuhdXY0VbdjVP9ct2CNSLg)9SGtSYQeRagIggCrDSAyi57j9oJH6VG3nxWkG4wYcs8JHyz63GHiXMlGEl4nDCIvgEGvadrddUOownmK89KENXqvr6Aq6(LgUZnP3s2sa)I2olYait6YW(aaPHH01G0Sm9BmCNBsVLSLa(fTDwKbqgFSXLdyprAyiDvKUgKUFPH7Ct6TKTeWVODN4LjDzyFaG01RJ09lnCNBsVLSLa(fT7eVmpjY(uq6TrA1H0vq661r6(LgUZnP3s2sa)I2olYaitjzzyKoeKwDinmKUFPH7Ct6TKTeWVOTZImaY8Ki7tbPdbPvjsddP7xA4o3KElzlb8lA7SidGmPld7daKUcgILPFdgI7Ct6TKTeWVioXkR(XkGHOHbxuhRggILPFdgQimr)jmK89KENXqpfFQSZGlcdjdvUiBYpaklyLvfNyLHVyfWq0WGlQJvddXY0VbdjE3e9NWqY3t6Dgd9u8PYodUiKUEDKguigna4fltxAbiWF35Xi0GHKHkxKn5haLfSYQItSYQhScyiAyWf1XQHHKVN07mgsET0WtAghWEAJmH0WqAsU8Mcz4ju7qBDIHyz63GHkj)r)jCIvwvvGvadrddUOownmK89KENXq1G0YRLgEsZ4a2tBKjKggstYL3uidpHAhARtmelt)gmuWZ5ooXkRQQyfWq0WGlQJvddjFpP3zmuvKguignKC5nfYUeg(ncniD96inOqmAi5YBkKTCl(ncniDfmelt)gmK8M2lmzZDYwA83ZcoXkRATyfWq0WGlQJvddjFpP3zmuvKMKlVPqgFSlHHFKUEDKMKlVPqMYT43o0wNiDfKUEDKUkstYL3uiJp2LWWpsddPbfIrtj5Vi8ailj2Cb0lstAxcd)gHgKUcgILPFdgQK8h9NWjwzvvhwbmelt)gmuWZ5ogIggCrDSA4eN4ed1sFXVbRCTQOwvOATQq9JHc4F8bqbdPEfBUpPosRQQinlt)gKE5LSyqBWqn)f9fHH2csdpxG)UZdsVv(cEhTzli9wjjjrq6rA4RIiDTQOwvG2G2SfKgEANhaubEgAZwqA1hKw9oY7BUNtcPHN4eUTQ7MW(G0nVFVNovq6QEePluM(aaP9csl3jzyQxXG2SfKw9bPvVJ8(M75Kq6Rj9Bq68q6YUhtKU69i9CzfKgKI3tin80nTxyYG2G2SfKw99wtsHK6inifVNqA5jcYjsdsa8PyqA4)KsQjli9CJ6Zo)IrHfsZY0VPG03Sc1G2WY0VPyAEsEIGCQeq4c7t)PUT04VNf0gwM(nftZtYteKtLacxZFblf9iqqHy0i50gVx0i0aR)cE3i5mG4wYcs8J2WY0VPyAEsEIGCQeq4aj(TX7fv0JaRbuign8eQnEVOrObw1A6VG3nsodiULSGe)1RdkeJgjN249IM(fmvGvTM(l4DZfSciULSGe)1RdkeJgX7MW(yJ3lA6xWubTHLPFtX08K8eb5ujGWTt8N2lAZDYg4RUIEeyYlAsZoXFAVOn3jBGV6gAyWf1HvT)cE3i5mG4wYcs8dduignsoTX7fncn1R3FbVBUGvaXTKfK4hgOqmAeVBc7JnEVOrOPEDqHy0iE3e2hB8ErJqdSKx0KgqEXJKSCm6JNHAOHbxuVcAdlt)MIP5j5jcYPsaHl45CxrpceuignI3nH9XgVx0i0aR)cE3CbRaIBjliXpSAKxln8KMXbSN2itOnSm9BkMMNKNiiNkbeUsYF0FsrpceuignI3nH9XgVx0i0aR)cE3CbRaIBjliXpm51sdpPzCa7PnYeAdAZwqA13BnjfsQJ0ul9HI0PlsiDUtinlZ7rAVG0Cl7lgCrg0gwM(nfGLWcRLfKl7OnSm9BkkbeoHcz9Kelk6rG1akeJMM)cwgHg0gwM(nfLacxZL(nk6rGvRwn5fnPzN4pTx0M7KnWxDdnm4I6WafIrZoXFAVOn3jBGV6gHMkWQ2FbVBKCgqClzbj(RxV)cE3CbRaIBjliXFfy1akeJMM)cwgHMk1RxTkOqmAaPVqFyliXVrOPEDqHy04JK)Ht)glab(7op2lAf(YjncnvGvTM(l4DJKZaIBjliXpSA6VG3nxWkG4wYcs8xPsf0MTG0Sm9BkkbeUxySSm9BSlVKkoSibuYzaXTKIEey)f8UrYzaXTKfK4hw1QY7w9lym5(ZLDliXV5jr2NY2QaM8Uv)cgJipawK5jr2NY2Qaw)sJ4Dt0FY8Ki7tzBGaKDLuHrLWEgafc8QcyGcXOXhj)dN(nwac83DESx0k8LtA6xWaduignG0xOpSfK430VGbgOqmAaWlwMU0cqG)UZJPFbtL61RckeJgjN249IgHgy0qpGq3UwvwPE9QVWqX7bqMJZD7fT5ozPvNEB)f8UHGFcEtd1HvdOqmAoo3Tx0M7KLwD6T9xW7gHgyvbfIrJKtB8ErJqdmAOhqOBxRkQuPE9QVWqX7bqMJZD7fT5ozPvNEB)f8UHGFcEtd1HbkeJMDI)0ErBUt2aF1npjY(ucrvvubwvqHy0i50gVx0i0aJg6be621QIk1RxvET0WtAch678atE3QFbJHeBUa6TG30npjY(ucbOQWyz6TKLgs0Psi1wPcAdlt)MIsaH7fgllt)g7YlPIdlsaLCgqClPOhb2FbVBKCgqClzbj(HbkeJgjN249IgHg0MTG0Sm9BkkbeUxySSm9BSlVKkoSib8cwbe3sk6rG9xW7MlyfqClzbj(HvTQ8Uv)cgtU)Cz3cs8BEsK9PSTkGjVB1VGXiYdGfzEsK9PSTkG9makKAvbmqHy04JK)Ht)gt)cgyGcXObK(c9HTGe)M(fmvQxVkOqmAeVBc7JnEVOrObw)stryI(tMNIpv2zWfvPE9QGcXOr8UjSp249IgHgyGcXOzN4pTx0M7KnWxDJqtL61RckeJgX7MW(yJ3lAeAGvfuignKC5nfYUeg(ncn1RdkeJgsU8Mczl3IFJqtfy18cdfVhazoo3Tx0M7KLwD6T9xW7gc(j4nnuVs96vFHHI3dGmhN72lAZDYsRo92(l4Ddb)e8MgQdRgqHy0CCUBVOn3jlT60B7VG3ncnvQxVQ8APHN0moG90gzcM8Uv)cgJ8M2lmzZDYwA83ZI5jr2NsiavTs96vLxln8KMWH(opWK3T6xWyiXMlGEl4nDZtISpLqaQkmwMElzPHeDQesTvQG2WY0VPOeq4EHXYY0VXU8sQ4WIeWlyfqClPOhb2FbVBUGvaXTKfK4hgOqmAeVBc7JnEVOrObTzliT6nI0besVZTesVvluj)msVia005puKMGFcEtd1rAE6iniV4rsinhJ(4zOinxqAgPtErtI0besxc8uUJ0(KhslE3e2hKoEVishStd1spsN7esVcvYpJ0GcXis7fKMtK(EKgKwxasxlsxijAdlt)MIsaH7fgllt)g7YlPIdlsaxHk5Npf9iWQvFHHI3dGmRqL8ZfBCru6dalGLl2uidb)e8MgQxbw1Kx0KgqEXJKSCm6JNHAOHbxuVcSQGcXOzfQKFUyJlIsFaybSCXMczeAQaRkOqmAwHk5Nl24IO0hawalxSPqMNezFkHaS2kvqB2csREJiDaH07ClH0B1cvYpJ0lcanD(dfPj4NG30qDKMNoshPNxinhJ(4zOinxqAgPtErtI0besxc8uUJ0(KhshPNxiD8ErKoyNgQLEKo3jKEfQKFgPbfIrK2linNi99iniTUaKUwKUqs0gwM(nfLac3lmwwM(n2LxsfhwKaUcvYplv0JaRw9fgkEpaYScvYpxSXfrPpaSawUytHme8tWBAOEfyvtErtAI0ZllhJ(4zOgAyWf1RaRkOqmAwHk5Nl24IO0hawalxSPqgHMkWQckeJMvOs(5InUik9bGfWYfBkK5jr2NsiaRTsf0MTG0Q3ishqBfpH0mspoG9mYesZthPdiKUFZwrI0b8KiDEiTKZaIBj4UGvaXTKI80r6acP35wcPb5fpscUi98cP5y0hpdfPtErtsDfrA1x70qT0J0YBAVWesl7iTxqAHgKoGq6sGNYDK2N8qAog9XZqr649IiDEiTKljs7PIi9o9eslE3e2hKoEVObTHLPFtrjGW9cJLLPFJD5LuXHfjGN8M2lmPOhbwOm9bqXu29yAJ3BL30EHjyvRM8IM0aYlEKKLJrF8mudnm4I6vGvTM(l4DJKZaIBjliXFfyvRP)cE3CbRaIBjliXFfyvLxln8KMXbSN2itWK3T6xWyK30EHjBUt2sJ)EwmpjY(ucbOQvQG2SfKw9gr6aAR4jKMr6XbSNrMqAE6iDaH09B2ksKoGNePZdPLCgqClb3fSciULuKNoshqi9o3siniV4rsWfPNxinhJ(4zOiDYlAsQRisR(ANgQLEKwEt7fMqAzhP9csl0G0besxc8uUJ0(KhsZXOpEgkshVxePZdPLCjrApveP3PNqAjNX7fr649Ig0gwM(nfLac3lmwwM(n2LxsfhwKakL30EHjf9iWcLPpakMYUhtB8ER8M2lmbRA1Kx0KMi98YYXOpEgQHggCr9kWQwt)f8UrYzaXTKfK4VcSQ10FbVBUGvaXTKfK4VcSQYRLgEsZ4a2tBKjyY7w9lymYBAVWKn3jBPXFplMNezFkHau1kvqByz63uuciCsETSSm9BSlVKkoSibu0thaN(nOnSm9BkkbeUxySSm9BSlVKkoSibeK4hTbTHLPFtXas8deK43gVxurpcSgqHy0as8BJ3lAeAqByz63umGe)kbeUNBP5ek24td8ju0gwM(nfdiXVsaHtEt7fMS5ozln(7zrrpcSM(l4DJKZaIBjliXpSA6VG3nxWkG4wYcs8J2WY0VPyaj(vciCG0xOpSfK4xrpcSkOqmAEULMtOyJpnWNqncn1RxJ8APHN00stUh6xbTHLPFtXas8Req48rY)WPFJIEeyvqHy08ClnNqXgFAGpHAeAQxVg51sdpPPLMCp0VcAdlt)MIbK4xjGWXDUj9wYwc4xurpcSAn9lnCNBsVLSLa(fTDwKbqM0LH9baSAyz63y4o3KElzlb8lA7SidGm(yJlhWEcRAn9lnCNBsVLSLa(fT7eVmPld7dG617xA4o3KElzlb8lA3jEzEsK9PST6QuVE)sd35M0BjBjGFrBNfzaKPKSmCiQdw)sd35M0BjBjGFrBNfzaK5jr2NsiQew)sd35M0BjBjGFrBNfzaKjDzyFaubTHLPFtXas8Req4Y9Nl7wqIFft(bqP1JaFk(uzNbxu969ln5(ZLDliXVPKSmCiQRE9Q9ln5(ZLDliXVPKSmCiWlSxyO49aiZsigzFIcfQBjrWNLKHGFcEtd1RuVoltVLS0qIov2gi8I2WY0VPyaj(vciCI3nr)jf9iWQvbfIrdaEXY0Lwac83DEmcnvGXY0BjlnKOtLqQTs96vRckeJga8ILPlTae4V78yeAQaRM(LgX7MO)KjDzyFaaJLP3swAirNkBRkSKFauAsxKS5z7oTTQ1wbTHLPFtXas8Req4eVBI(tk6rGv7xAeVBI(tMNezFkHauDWQckeJga8ILPlTae4V78yeAQaJLP3swAirNkBRsyj)aO0KUizZZ2DABvRTcAdlt)MIbK4xjGWjE3e9Nu0JaR(u8PYodUiySm9wYsdj6ujKAHL8dGst6IKnpB3PTvT2k1RxTM(LgX7MO)KjDzyFaaJLP3swAirNkBRkSKFauAsxKS5z7oTTQ1wbTHLPFtXas8Req4kbEdPOhbckeJgFK8pC63ybiWF35XErRWxoPPFbdmqHy0asFH(WwqIFt)cgySm9wYsdj6uzBGWlAdlt)MIbK4xjGWjYclf9iqqHy04JK)Ht)gJqdmwMElzPHeDQesTOnSm9BkgqIFLacNilSu0JaRckeJMc3YaiR8eb5KN0uswgEBGQwbwvqHy0K3L7wE6w5IdmcnvGbkeJgFK8pC63yeAGXY0BjlnKOtfG1I2WY0VPyaj(vciCI8ayrk6rGGcXOXhj)dN(ngHgySm9wYsdj6ujeGQdTHLPFtXas8Req4ezHLIEey1QvbfIrtExUB5PBLloWuswgEBG1wPE9QGcXOjVl3T80TYfhyeAGbkeJM8UC3Yt3kxCG5jr2NsiQAuzL61RckeJMc3YaiR8eb5KN0uswgEBGQRsfySm9wYsdj6uje1vbTHLPFtXas8Req4Y9Nl7wqIFf9iqwMElzPHeDQSTQOnSm9BkgqIFLacNipawKIEey1QpdGcr9OIkWyz6TKLgs0PsiQRs96vR(make4RkRaJLP3swAirNkHOoyjVOjnLtyzVOn3jB8EQKgAyWf1RG2WY0VPyaj(vciCncRw6D4dPOmu5ISj)aOSauvf9iW(LMC)5YUfK43uswgE7ArByz63umGe)kbeUC)5YUfK4hTHLPFtXas8Req4ezHLIEeiltVLS0qIovcrDOnSm9BkgqIFLacxjWBiliXpAdlt)MIbK4xjGW5)nrHxrpc8zaKPtrx6ziWRkGbkeJg)Vjk8MNezFkHOcJkrBqB2csZY0VPOeq4K8Azzz63yxEjvCyrcOONoao9BqB2csZY0VPOeq4c8v3k35haH2SfKMLPFtrjGWj51YYY0VXU8sQ4WIeq5DR(fmf0MTG0Sm9BkkbeorwyPOhb(maY0POl9mKAvbmwMElzPHeDQec8I2SfKMLPFtrjGWjYclf9iWNbqMofDPNHuRkGrLcnsYiVjUCzA5PBl57rYiYW)UhwnGcXOPSZFdnu3kxCqXi0G2SfKMLPFtrjGW5)nrHxrpcuELeOkQxV6ZaOTLxjHXWh69Kmlou6PUvKhYqddUOomwMElzPHeDQSDTvqB2csZY0VPOeq4AewT07WhsXKFauA9iW(LMC)5YUfK43uswggy)stU)Cz3cs8Be5T2wswgUG2SfKMLPFtrjGWjE3e9Num5haLwpcSFPr8Uj6pzEk(uzNbxemwMElzPHeDQesTOnBbPzz63uuciC5(ZLDf9iWQGcXOXhj)dN(nM(fmWyz6TKLgs0PY2QwPE9QGcXOXhj)dN(ngHgySm9wYsdj6uzB4TcAZwqAwM(nfLacxjWBif9iqqHy04JK)Ht)gt)cgySm9wYsdj6uzB4fTzlinlt)MIsaHtKhalsrpcSFPj3FUSBbj(nPld7da0MTG0Sm9BkkbeoX7MO)KIj)aO06rGGcXObaVyz6slab(7opgHgySm9wYsdj6ujKArB2csZY0VPOeq4Y9Nl7OnBbP3Q7Rfsh45osVvD3e9Nq6ap3rA4)VCRARRfTzlinlt)MIsaHt8Uj6pPOhbYWh69Kmnxa92lAZDYkE3yEEcVTQWyz6TKLgs0PcqvrB2csZY0VPOeq4kbEdH2G2WY0VPye90bWPFdq)Vjk8k6rG(iprFay7SidGSQSST)3efEBNfzaKn3FQSFRomqHy04)nrH38Ki7tje1b)TZLKqByz63umIE6a40VrjGW90qb8srpcm5jSpaGTt8k3nnYme4HkrByz63umIE6a40VrjGWfFAGpo1TpbGg650Vrrpcm5jSpaGTt8k3nnYme4HkrByz63umIE6a40VrjGWrInxa9wWB6k6rGvRP)cE3i5mG4wYcs8dRM(l4DZfSciULSGe)vQxNLP3swAirNkBdSw0gwM(nfJONoao9BuciCG8hUe2hf9iWKNW(aa2oXRC30iZqu)QeMpYt0ha2olYaiRklBRcJQWF7eVYDJiV1OnSm9BkgrpDaC63Oeq4kcFR3YlRpL0hzwu0JabfIrtr4B9wEz9PK(iZIPFbdmqHy0aYF4syFm9lyGTt8k3nnYme4HkG5J8e9bGTZImaYQYY2QWuRkH)2jEL7grERrBqByz63umY7w9lykaBU0VbTHLPFtXiVB1VGPOeq4ax31TrHpu0gwM(nfJ8Uv)cMIsaHdK(c9H9baAdlt)MIrE3QFbtrjGWXVKhYM3)0KOnSm9Bkg5DR(fmfLac3YbSNfl8pHoarAs0gwM(nfJ8Uv)cMIsaHl6pbUURJ2WY0VPyK3T6xWuuciC8iPs(8Yk51cTHLPFtXiVB1VGPOeq4aFVKlFayJcVIEeiOqmAaj(TX7fncnOnSm9Bkg5DR(fmfLacNps(ho9Bu0JaR2V0iE3e9NmPld7dG61zz6TKLgs0PY2Qwbw)stU)Cz3cs8Bsxg2haOnSm9Bkg5DR(fmfLachi9f6dJ2WY0VPyK3T6xWuuciCcfY6jjQifJKmTdlsaLHkxx(34sl4IljAdlt)MIrE3QFbtrjGWjuiRNKybTbTHLPFtXi5mG4wcyZFbl0gwM(nfJKZaIBjLacNKtB8Erf9iWAafIrJKtB8ErJqdAdlt)MIrYzaXTKsaH75WKIEeiOqmAA(lyzeAqByz63umsodiULuciC7e)P9I2CNSb(QROhbM8IM0St8N2lAZDYg4RUHggCrDy1akeJMDI)0ErBUt2aF1ncnOnSm9BkgjNbe3skbeosS5cO3cEtxrpcS)cE3i5mG4wYcs8J2WY0VPyKCgqClPeq4K30EHjBUt2sJ)Ewu0Ja7VG3nsodiULSGe)OnSm9BkgjNbe3skbeU3Bu0Ja7xAEVX8u8PYodUiyYte8SnNpzzBGWlAdlt)MIrYzaXTKsaHls)j9tOyb9Ku0JaLNi4zBoFYY2aHx0gwM(nfJKZaIBjLach35M0BjBjGFrf9iWQ10V0WDUj9wYwc4x02zrgazsxg2haWQHLPFJH7Ct6TKTeWVOTZImaY4JnUCa7jSQ10V0WDUj9wYwc4x0Ut8YKUmSpaQxVFPH7Ct6TKTeWVODN4L5jr2NY2QRs969lnCNBsVLSLa(fTDwKbqMsYYWHOoy9lnCNBsVLSLa(fTDwKbqMNezFkHOsy9lnCNBsVLSLa(fTDwKbqM0LH9bqf0gwM(nfJKZaIBjLac3ZHjf9iW(LMNdtMNIpv2zWfbtEIGNT58jlHaVOnSm9BkgjNbe3skbeUY(tDf9iq5jcE2MZNSeIkrBqByz63ums5nTxycOKtB8Er0gwM(nfJuEt7fMuciCYBAVWKn3jBPXFplOnOnSm9BkMvOs(zjqjN249IOnOnSm9BkMvOs(5dO4DtyFSX7frBqByz63umN8M2lmbu8UjSp249IOnSm9BkMtEt7fMuciCYBAVWKn3jBPXFplOnOnSm9BkMlyfqClbu8UjSp249Ik6rG1akeJgX7MW(yJ3lAeAqByz63umxWkG4wsjGWTt8N2lAZDYg4RUIEeyYlAsZoXFAVOn3jBGV6gAyWf1HvdOqmA2j(t7fT5ozd8v3i0G2WY0VPyUGvaXTKsaHRK8xeEaeAdlt)MI5cwbe3skbeo5nTxyYM7KT04VNff9iWYjSa9PBI(xsBjFpmzOHbxuhTHLPFtXCbRaIBjLachj2Cb0BbVPROhb2FbVBUGvaXTKfK4hTHLPFtXCbRaIBjLach35M0BjBjGFrf9iWQ10V0WDUj9wYwc4x02zrgazsxg2haWQHLPFJH7Ct6TKTeWVOTZImaY4JnUCa7jSQ10V0WDUj9wYwc4x0Ut8YKUmSpaQxVFPH7Ct6TKTeWVODN4L5jr2NY2QRs969lnCNBsVLSLa(fTDwKbqMsYYWHOoy9lnCNBsVLSLa(fTDwKbqMNezFkHOsy9lnCNBsVLSLa(fTDwKbqM0LH9bqf0gwM(nfZfSciULuciCfHj6pPOmu5ISj)aOSauvf9iWNIpv2zWfH2WY0VPyUGvaXTKsaHt8Uj6pPOmu5ISj)aOSauvf9iWNIpv2zWfvVoOqmAaWlwMU0cqG)UZJrObTHLPFtXCbRaIBjLacxj5p6pPOhbkVwA4jnJdypTrMGrYL3uidpHAhARt0gwM(nfZfSciULuciCbpN7k6rG1iVwA4jnJdypTrMGrYL3uidpHAhARt0gwM(nfZfSciULuciCYBAVWKn3jBPXFplk6rGvbfIrdjxEtHSlHHFJqt96GcXOHKlVPq2YT43i0ubTHLPFtXCbRaIBjLacxj5p6pPOhbwLKlVPqgFSlHH)61j5YBkKPCl(TdT1zL61RsYL3uiJp2LWWpmqHy0us(lcpaYsInxa9I0K2LWWVrOPcAdlt)MI5cwbe3skbeUGNZDmuPHKyLvvfWloXjgd]] )

end