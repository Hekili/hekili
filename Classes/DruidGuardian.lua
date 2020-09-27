-- DruidGuardian.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'DRUID' then
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
        ursocs_fury_remembered = {
            id = 345048,
            duration = 15,
            max_stack = 1,
        },
    } )


    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
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
    spec:RegisterGear( 'class', 139726, 139728, 139723, 139730, 139725, 139729, 139727, 139724 )
    spec:RegisterGear( 'tier19', 138330, 138336, 138366, 138324, 138327, 138333 )
    spec:RegisterGear( 'tier20', 147136, 147138, 147134, 147133, 147135, 147137 ) -- Bonuses NYI
    spec:RegisterGear( 'tier21', 152127, 152129, 152125, 152124, 152126, 152128 )

    spec:RegisterGear( 'ailuro_pouncers', 137024 )
    spec:RegisterGear( 'behemoth_headdress', 151801 )
    spec:RegisterGear( 'chatoyant_signet', 137040 )        
    spec:RegisterGear( "dual_determination", 137041 )
    spec:RegisterGear( 'ekowraith_creator_of_worlds', 137015 )
    spec:RegisterGear( "elizes_everlasting_encasement", 137067 )
    spec:RegisterGear( 'fiery_red_maimers', 144354 )
    spec:RegisterGear( "lady_and_the_child", 144295 )
    spec:RegisterGear( 'luffa_wrappings', 137056 )
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

    spec:RegisterGear( 'the_wildshapers_clutch', 137094 )


    spec:RegisterGear( 'soul_of_the_archdruid', 151636 )


    spec:RegisterHook( "reset_precast", function ()
        if azerite.masterful_instincts.enabled and buff.survival_instincts.up and buff.masterful_instincts.down then
            applyBuff( "masterful_instincts", buff.survival_instincts.remains + 30 )
        end
    end )


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
            cooldown = function () return talent.survival_of_the_fittest.enabled and 40 or 60 end,
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


        dash = {
            id = 1850,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 132120,

            notalent = "tiger_dash",

            handler = function ()
                applyBuff( "dash" )
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


        ferocious_bite = {
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
        },


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
            cooldown = 300,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
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


        lunar_strike = {
            id = 197628,
            cast = function () return haste * ( buff.lunar_empowerment.up and 1.8 or 2.5) end,
            cooldown = 0,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135753,

            form = "moonkin_form",
            talent = "balance_affinity",

            handler = function ()
                removeStack( "lunar_empowerment" )
            end,
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
            end,
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
            cooldown = 30,
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


        rake = {
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
        },


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


        rip = {
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
        },


        shred = {
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
        },


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


        starfire = {
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
        },


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


        wrath = {
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
        },


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

    spec:RegisterPack( "Guardian", 20200831, [[dueXAaqiOuHhbiUeGuztQcJskHtjLOvHuHxPKAwsPClKkAxQQFjfgMQOJPISma1ZqQY0qQQRPIQTbLQ(gsLACQGCovaToKkP5jL09ayFsP6GaswOsYdvbWeHsfDraP0gbKI(OkaDsaPQvcf3ekvANsrdfqk8uIMQiAVc)vLgSOomPfdvpg0KLQlJAZi5ZQsJwKonLvJujEnuYSvQBd0UL8BfdhPSCepNW0P66kX2vH(UimEvGopukRxfuZxfL9d54uKmKD15OjWpb(5ZdrVt)Nh6eW07qH0XgnoK0uiw6lhYsb5qEaxus30kK0uSThThjdPywiqoKPUttqxB04180f8pCaBimWLT62uqIs5negiSriXxSTd0xbEi7QZrtGFc8ZNhIEN(pp0Zd8C6fsDXthsiLg4biKPwVZvGhYolGHeiO8bCrjDtlug7KSyDegGGYa1Y7IWrz6DQnug4Na)eHbHbiO8bivRxwqxryacktNOmq17ChLXUMBVQBtHYkUTn3yXhHbiOmDIYavVZDuwI1YEJYRur6hHbiOmDIYavVZDu2itrTqUDfuF5RNsyr6S7O8qZTP(HCBcxejdjCMDFsuIiz08uKmKk0TPcjTXTPcjxk(M7XQWJMahjdPcDBQqMYkXVSqWfKdjxk(M7XQWJM0lsgsf62uHKOh5AwexkcxhgBHKlfFZ9yv4rt6hjdPcDBQqIVNPFPwiylKCP4BUhRcpAEEKmKk0TPcjotemblREdjxk(M7XQWJMyFKmKk0TPcPsGAXxFieU8qYLIV5ESk8OjDhjdPcDBQqUT3uxCPll9xqU8qYLIV5ESk8O5HIKHuHUnviPmcJVNPhsUu8n3JvHhnpWizivOBtfsTGSWj6(c19oKCP4BUhRcpAE6zKmKk0TPcjdsBsWKl(u9qYLIV5ESk8O5PtrYqQq3MkKWPooyXxpLVcAgXCri5sX3CpwfE08eWrYqYLIV5ESkKqI5mX0qIVqr9XzLCPgc4FHgk)aLBbkRq3oYxUyqJfOC7O8ju(SZq5uw3E6NgtGC5OCROm2)eLBzivOBtfY9sPKloRGHhnprVizi5sX3CpwfsiXCMyAiXxOO(4SsUudb8VqlKk0TPcjoXe(2Q3l1cj8O5j6hjdjxk(M7XQqcjMZetdzlq5(4FWzkkJWF3Gyz1lkF2zOScD7iF5IbnwGYTJYNq5wIYpq5(4FpLOI0loRKVBqSS6nKk0TPcPvqLuQBtfE0805rYqQq3MkKAxP52r(ksOeWqYLIV5ESk8O5jSpsgsf62uHeNjcMGvi5sX3CpwfE08eDhjdjxk(M7XQqQq3MkKqSb3JtMYGx8Tk8qYuum0VLcYHeIn4ECYug8IVvHhE080HIKHKlfFZ9yviHeZzIPH0N33n)HZS7tIsGYpq5wGYUbYxFUDJr5wrzf62ux4m7(KOqzGougyu(SZqzf62r(YfdASaLBhLpHYTmKk0TPcPwgOEhQBNvpn8O5Pdmsgsf62uHeKbhc2Ud1DVaT(TtyfuesUu8n3JvHhnb(zKmKk0TPc5IGVMZGIqYLIV5ESk8WdjO52R62urYO5Pizi5sX3CpwfsiXCMyAiTcoGw9E7kO(Y3ZfOC7OSrMIAHC7kO(YxpLWI0z3r5hOm(cf13itrTq(eguTsGYTIY0dLPduovfohsf62uH0itrTqcpAcCKmKCP4BUhRcjKyotmnKPSU90pCHq4Yr5wr5NF6(CuMoq5uw3E6hupyivOBtfskcxh24(LWVCXe1TPcpAsVizi5sX3CpwfsiXCMyAi959DZ)otXLWoYcu(bkNY62t)0Gok3kkFONHuHUnvi1Ya17qD7S6PHhnPFKmKCP4BUhRcjKyotmnKPSU90pnOJYTIY095O8du2k4aA17TRG6lFpxGYTJYp)aFokthOCkRBp9dQhmKk0TPcjUsWsGLvHhnppsgsUu8n3JvHesmNjMgs8fkQVyHC0oQ7Rvc3kOl(9jrHYpqz8fkQpUsWsGLv)(KOq5hOCkRBp9td6OCROm2)eLFGYwbhqREVDfuF575cuUDu(5h4Zrz6aLtzD7PFq9GHuHUnviflKJ2rDFTs4wbDr4HhYotPlBpsgnpfjdPcDBQqkWAzVV4QinKCP4BUhRcpAcCKmKCP4BUhRcPcDBQqc19(Qq3M6UnHhYTj8BPGCibn3Ev3Mk8Oj9IKHuHUnvity7(fMQKxoKCP4BUhRcpAs)izi5sX3Cpwfsf62uHeQ79vHUn1DBcpKBt43sb5qcNz3NeLi8O55rYqYLIV5ESkKqI5mX0qs0x(3zkdAok3kkd8tu(bkRq3oYxUyqJfOCROm9dPcDBQqcQl7WJMyFKmKCP4BUhRcjKyotmnKe9L)DMYGMJYTIYa)eLFGYSqWfK)WPO2g0VA1VcNyu8huPldbLFGYyhOm(cf1xKQeACX9lCRje)fAHuHUnvib1LD4rt6osgsUu8n3JvHesmNjMgs4iCugak)eLp7muUfOmrFzuUDugochLFGY6HzI58FRyJjC)cQf)5sX3ChLFGYk0TJ8Llg0ybk3okdmk3YqQq3MkKgzkQfs4rZdfjdjxk(M7XQqcjMZetdzF8VNsur6fNvYx4kelugak3h)7PevKEXzL8b1dEfUcXsesf62uHK2Y(itSdZHhnpWizi5sX3CpwfsiXCMyAi7J)bNPOmc)jmfHfPk(Mr5hOScD7iF5IbnwGYTIYahsf62uHeCMIYiC4rZtpJKHKlfFZ9yviHeZzIPHSfOm(cf13kOsk1TP(9jrHYpqzf62r(YfdASaLBhLpHYTeLp7muUfOm(cf13kOsk1TP(l0q5hOScD7iF5IbnwGYTJY0hLBzivOBtfspLOI0loRKWJMNofjdjxk(M7XQqcjMZetdj(cf13kOsk1TP(9jrHYpqzf62r(YfdASaLBhLPFivOBtfsrcJgFXzLeE08eWrYqYLIV5ESkKqI5mX0q2h)7PevKEXzL8DdILvVHuHUnvib16DZHhnprVizi5sX3CpwfsiXCMyAiXxOO(V6wHUbVVlkPBA9xOHYpqzf62r(YfdASaLBfLboKk0TPcj4mfLr4WJMNOFKmKk0TPcPNsur6fNvsi5sX3CpwfE0805rYqYLIV5ESkKqI5mX0qQhMjMZFAtcMChQRNYxWzQprlSq52r5tO8duwHUDKVCXGglqzaO8PqQq3MkKGZuugHdpAEc7JKHuHUnvifjmA8fNvsi5sX3CpwfE4HKgHHdiU6rYO5PizivOBtfsCwjxQHagsUu8n3JvHhnbosgsf62uHelR6eUFf0mI5IqYLIV5ESk8Oj9IKHuHUnvibzWHGT7qD3lqRF7ewbfHKlfFZ9yv4rt6hjdPcDBQqsBCBQqYLIV5ESk8WdpKhzIWMkAc8tGF(8qaFGFGdzcLuw9kcjqpiTH4ChLPpkRq3McL3MWfFeMqsJmu2Mdjqq5d4Is6MwOm2jzX6imabLbQL3fHJY07uBOmWpb(jcdcdqq5dqQwVSGUIWaeuMorzGQ35okJDn3Ev3McLvCBBUXIpcdqqz6eLbQEN7OSeRL9gLxPI0pcdqqz6eLbQEN7OSrMIAHC7kO(YxpLWI0z3r5HMBt9ryqyackd0EqgU4ChLXzQHWOmCaXvhLX5xReFugOGqMMlq5Ak6mvjGulBuwHUnLaLNAJTpcdqqzf62uIpncdhqC1bqTvbwimabLvOBtj(0imCaXvFnGguZ0ryackRq3Ms8Pry4aIR(Aan0LxqUC1TPqyuOBtj(0imCaXvFnGg4SsUudbeHbiOSSuAI0XrzIADugFHII7OSWvxGY4m1qyugoG4QJY48RvcuwRoktJW0jTXDRErztGY9P4pcdqqzf62uIpncdhqC1xdOHOuAI0XVcxDbcJcDBkXNgHHdiU6Rb0alR6eUFf0mI5cegf62uIpncdhqC1xdObidoeSDhQ7EbA9BNWkOaHrHUnL4tJWWbex91aAqBCBkegegGGYaThKHlo3rz(itWgk7giJYEkJYk0hckBcuwpQ2wX38hHrHUnLaGaRL9(IRIuegf62uI1aAa19(Qq3M6UnH3wPGmaqZTx1TPqyuOBtjwdOrcB3VWuL8Yimk0TPeRb0aQ79vHUn1DBcVTsbzaWz29jrjqyuOBtjwdObOUSBZOaq0x(3zkdAERa)8HcD7iF5Ibnw0k9ryuOBtjwdObOUSBZOaq0x(3zkdAERa)8bleCb5pCkQTb9Rw9RWjgf)bv6YqEGDGVqr9fPkHgxC)c3AcXFHgcJcDBkXAanmYuulK2mkaWr4aEE2zTGOVC7Wr4p0dZeZ5)wXgt4(ful(ZLIV5(df62r(YfdASODGBjcJcDBkXAanOTSpYe7WCBUsEz)Aua6J)9uIksV4Ss(cxHybOp(3tjQi9IZk5dQh8kCfILaHrHUnLynGgGZuugHBZvYl7xJcqF8p4mfLr4pHPiSivX38df62r(YfdASOvGryuOBtjwdOHNsurABgfGwGVqr9TcQKsDBQFFsupuOBh5lxmOXI2p1YZoRf4luuFRGkPu3M6Vq7HcD7iF5Ibnw0o9BjcJcDBkXAanejmACBgfa8fkQVvqLuQBt97tI6HcD7iF5Ibnw0o9ryuOBtjwdObOwVBUnJcqF8VNsur6fNvY3niww9IWOq3MsSgqdWzkkJWT5k5L9RrbaFHI6)QBf6g8(UOKUP1FH2df62r(YfdASOvGryuOBtjwdOHNsurkcdqqzGM2EJYjmpfLXUZuugHr5eMNIYangh7EqGryuOBtjwdOb4mfLr42mka6HzI58N2KGj3H66P8fCM6t0cR2p9qHUDKVCXGglaCcHrHUnLynGgIegngHbHrHUnL4dAU9QUnfaJmf1cPnJcGvWb0Q3Bxb1x(EUODJmf1c52vq9LVEkHfPZU)aFHI6BKPOwiFcdQwjALE0rQkCgHrHUnL4dAU9QUn1AanOiCDyJ7xc)Yftu3MQnJcqkRBp9dxieU8wF(P7ZPJuw3E6hupicJcDBkXh0C7vDBQ1aAOLbQ3H62z1tBZOa4Z77M)DMIlHDKfpszD7PFAqV1d9eHrHUnL4dAU9QUn1AanWvcwcSSQnJcqkRBp9td6Ts3N)Wk4aA17TRG6lFpx0(ZpWNthPSU90pOEqegf62uIpO52R62uRb0qSqoAh191kHBf0fTzuaWxOO(IfYr7OUVwjCRGU43Ne1d8fkQpUsWsGLv)(KOEKY62t)0GERy)ZhwbhqREVDfuF575I2F(b(C6iL1TN(b1dIWGWOq3Ms8HZS7tIsaG242uimk0TPeF4m7(KOeRb0iLvIFzHGliJWOq3Ms8HZS7tIsSgqdIEKRzrCPiCDySHWOq3Ms8HZS7tIsSgqd89m9l1cbBimk0TPeF4m7(KOeRb0aNjcMGLvVimk0TPeF4m7(KOeRb0qjqT4RpecxocJcDBkXhoZUpjkXAan22BQlU0LL(lixocJcDBkXhoZUpjkXAanOmcJVNPJWOq3Ms8HZS7tIsSgqdTGSWj6(c19gHrHUnL4dNz3NeLynGgmiTjbtU4t1ryuOBtj(Wz29jrjwdObCQJdw81t5RGMrmxGWOq3Ms8HZS7tIsSgqJ9sPKloRGTzuaWxOO(4SsUudb8Vq7rluOBh5lxmOXI2pD2zPSU90pnMa5YBf7F2segf62uIpCMDFsuI1aAGtmHVT69sTqAZOaGVqr9XzLCPgc4FHgcJcDBkXhoZUpjkXAanScQKsDBQ2mkaTOp(hCMIYi83niww9E2zk0TJ8Llg0yr7NA5J(4FpLOI0loRKVBqSS6fHrHUnL4dNz3NeLynGgAxP52r(ksOeqegf62uIpCMDFsuI1aAGZebtWcHrHUnL4dNz3NeLynGglc(Aod2gtrXq)wkidaIn4ECYug8IVvHJWOq3Ms8HZS7tIsSgqdTmq9ou3oREABgfaFEF38hoZUpjkXJw4giF952nUv4m7(KOa6a(SZuOBh5lxmOXI2p1segf62uIpCMDFsuI1aAaYGdbB3H6UxGw)2jSckqyuOBtj(Wz29jrjwdOXIGVMZGIqkOXWO5PN0p8WJa]] )

end