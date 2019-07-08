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
        ursols_vortex = 22916, -- 102793
        wild_charge = 18571, -- 102401

        balance_affinity = 22163, -- 197488
        feral_affinity = 22156, -- 202155
        restoration_affinity = 22159, -- 197492

        mighty_bash = 21778, -- 5211
        mass_entanglement = 18576, -- 102359
        typhoon = 18577, -- 132469

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
        relentless = 3465, -- 196029
        gladiators_medallion = 3464, -- 208683
        adaptation = 3463, -- 214027

        malornes_swiftness = 1237, -- 236147
        alpha_challenge = 842, -- 207017
        master_shapeshifter = 49, -- 236144
        toughness = 50, -- 201259
        den_mother = 51, -- 236180
        demoralizing_roar = 52, -- 201664
        roaring_speed = 3054, -- 236148
        protector_of_the_pack = 197, -- 202043
        overrun = 196, -- 202246
        entangling_claws = 195, -- 202226
        charging_bash = 194, -- 228431
        sharpened_claws = 193, -- 202110
        raging_frenzy = 192, -- 236153
        clan_defender = 191, -- 213951
    } )


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
        dash = {
            id = 1850,
            duration = 10,
            max_stack = 1,
        },
        earth_warden = {
            id = 203975,
            duration = 0, -- persistent / removed by taking auto attacks
            max_stack = 3,
        },
        --[[ enrage_effect = {
            I am not sure if this could / would be done here or its even viable for recommending soothe, but could be good as it's instant, doesn't take you out of bear form, but there are a million enrage buffs
        } ]]
        entangling_roots = {
            id = 339,
            duration = 30,
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
            max_stack =1,
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
        lunar_empowerment = {
            id = 164547,
            duration = 45,
            max_stack = 3,
        },
        mass_entanglement = {
            id = 102359,
            duration = 30,
            max_stack = 1,
            type = "Magic",
        },
        mighty_bash = {
            id = 5211,
            duration = 5,
            max_stack = 1,
        },
        moonfire = {
            id = 164812,
            duration = 16,
            max_stack = 1,
            type = "Magic",
        },
        moonkin_form = {
            id = 197625,
            duration = 3600,
            max_stack = 1,
        },
        natural_defenses = {
            id = 211160,
            duration = 15,
            max_stack = 2,
        },
        prowl = {
            id = 5215,
            duration = 3600,
            max_stack = 1,
        },
        pulverize = {
            id = 158792,
            duration = 20,
            max_stack = 1,
        },
        regrowth = {
            id = 8936,
            duration = 12,
            max_stack = 1,
        },
        rejuvenation = {
            id = 774,
            duration = 15,
            max_stack = 1,
        },
        stampeding_roar = {
            id = 77761,
            duration = 8,
            max_stack = 1,
        },
        solar_empowerment = {
            id = 164545,
            duration = 45,
            max_stack = 3,
        },
        sunfire = {
            id = 164815,
            duration = 12,
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
            duration = 16,
            max_stack = function () return ( ( level < 116 and equipped.elizes_everlasting_encasement ) and 5 or 3 ) end,
        },
        thrash_cat = {
            id = 106830,
            duration = 15,
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
    } )


    -- Function to remove any form currently active.
    spec:RegisterStateFunction( "unshift", function()
        removeBuff( "cat_form" )
        removeBuff( "bear_form" )
        removeBuff( "travel_form" )
        removeBuff( "moonkin_form" )
    end )


    -- Function to apply form that is passed into it via string.
    spec:RegisterStateFunction( "shift", function( form )
        unshift()
        applyBuff( form )
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
            cooldown = 60,
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

                if ( level < 116 and equipped.oakhearts_puny_quods ) then
                    gain( 45, "rage" )
                    applyBuff( "oakhearts_puny_quods" )
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

            spend = 0.18,
            spendType = "mana",

            startsCombat = false,
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
                if args.max_energy == 1 then gain( 25, "energy" ) end
                spend( min( 5, combo_points.current ), "combo_points" )
                if target.health_pct < 25 and debuff.rip.up then
                    debuff.rip.expires = query_time + min( debuff.rip.remains + debuff.rip.duration, debuff.rip.duration * 1.3 )
                end
            end,
        },


        frenzied_regeneration = {
            id = 22842,
            cast = 0,
            charges = 2,
            cooldown = 36,
            recharge = 36,
            gcd = "spell",

            spend = function () return 10 - ( 5 * buff.natural_defenses.stack ) end,
            spendType = "rage",

            startsCombat = false,
            texture = 132091,

            toggle = "defensives",
            defensive = true,

            form = "bear_form",

            readyTime = function () return buff.frenzied_regeneration.remains end,

            handler = function ()
                applyBuff( "frenzied_regeneration" )
                gain( health.max * 0.08, "health" )

                if level < 116 and equipped.skysecs_hold then applyBuff( "skysecs_hold" ) end
                removeStack( "natural_defenses" )
            end,
        },


        growl = {
            id = 6795,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            nopvptalent = "alpha_challenge",

            startsCombat = true,
            texture = 132270,

            handler = function ()
                applyDebuff( "target", "growl" )
            end,
        },


        hibernate = {
            id = 2637,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.15,
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
            cooldown = 180,
            gcd = "off",

            startsCombat = false,
            texture = 571586,

            toggle = "cooldowns",

            handler = function ()
                applyBuff( "incarnation" )
            end,

            copy = { "incarnation_guardian_of_ursoc", "Incarnation" }
        },


        intimidating_roar = {
            id = 236748,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 132117,

            handler = function ()
                applyDebuff( "target", "intimidating_roar" )
            end,
        },


        ironfur = {
            id = 192081,
            cast = 0,
            cooldown = 0.5,
            gcd = "spell",

            spend = function () return 45 - ( 5 * buff.natural_defenses.stack ) end,
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
                removeStack( "natural_defenses" )
            end,
        },


        lunar_beam = {
            id = 204066,
            cast = 0,
            cooldown = 75,
            gcd = "spell",

            startsCombat = true,
            texture = 136057,

            talent = "lunar_beam",

            handler = function ()
                -- may need to construct fake aura...
            end,
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


        mangle = {
            id = 33917,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = function () return -10 + ( buff.gore.up and -4 or 0 ) end,
            spendType = "rage",

            startsCombat = true,
            texture = 132135,

            form = "bear_form",

            handler = function ()
                if talent.guardian_of_elune.enabled then applyBuff( "guardian_of_elune" ) end

                if set_bonus.tier21_2pc == 1 and buff.gore.up then
                    cooldown.barkskin.expires = cooldown.barkskin.expires - 1
                end

                if set_bonus.tier19_4pc == 1 then
                    addStack( "natural_defenses", 15, 1 )
                end

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
            cooldown = 50,
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
                if ( level < 116 and equipped.lady_and_the_child ) then
                    active_dot.moonfire = min( active_enemies, active_dot.moonfire + 1 )
                end

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

            handler = function ()
                applyDebuff( "target", "overrun" )
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
            cooldown = 0,
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


        solar_wrath = {
            id = 197629,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.02,
            spendType = "mana",

            startsCombat = true,
            texture = 535045,

            talent = "balance_affinity",
            form = "moonkin_form",

            handler = function ()
                removeStack( "solar_empowerment" )
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


        starsurge = {
            id = 197626,
            cast = 2,
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
            charges = function () return ( ( level < 116 and equipped.dual_determination ) and 3 or 2 ) end,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( ( level < 116 and equipped.dual_determination ) and 0.85 or 1 ) * 240 end,
            recharge = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * ( ( level < 116 and equipped.dual_determination ) and 0.85 or 1 ) * 240 end,
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


            handler = function ()
                unshift()
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

            copy = "swipe"
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
            cooldown = 6,
            gcd = "spell",

            spend = -5,
            spendType = "rage",

            startsCombat = true,
            texture = 451161,

            form = "bear_form",

            handler = function ()
                applyDebuff( "target", "thrash_bear", 15, debuff.thrash_bear.count + 1 )
                active_dot.thrash_bear = active_enemies
            end,

            copy = "thrash"
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

            talent = "typhoon",

            handler = function ()
                if target.distance < 15 then
                    applyDebuff( "target", "typhoon" )
                end
            end,
        },


        --[[ wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 1518639,

            handler = function ()
            end,
        }, ]]


        ursols_vortex = {
            id = 102793,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            talent = "ursols_vortex",

            startsCombat = true,
            texture = 571588,

            handler = function ()
                applyDebuff( "target", "ursols_vortex" )
            end,
        },


        wild_charge = {
            id = 102401,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 538771,

            talent = "wild_charge",

            handler = function ()
                if buff.bear_form.up then target.distance = 5; applyDebuff( "target", "immobilized" )
                elseif buff.cat_form.up then target.distance = 5; applyDebuff( "target", "dazed" ) end
            end,
        },


        wild_growth = {
            id = 48438,
            cast = 1.5,
            cooldown = 10,
            gcd = "spell",

            spend = 0.3,
            spendType = "mana",

            startsCombat = false,
            texture = 236153,

            handler = function ()
                applyBuff( "wild_growth" )
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

        potion = "steelskin_potion",

        package = "Guardian",
    } )

    spec:RegisterSetting( "maul_rage", 20, {
        name = "Excess Rage for |T132136:0|t Maul",
        desc = "If set above zero, the addon will not recommend |T132136:0|t Maul only if you have at least this much excess Rage.",
        icon = 132136,
        iconCoords = { 0.1, 0.9, 0.1, 0.9 },
        type = "range",
        min = 0,
        max = 60,
        step = 0.1,
        width = 1.5
    } )    

    spec:RegisterPack( "Guardian", 20190707.2145, [[du0uwaqivQcpscSjvvnkvvYPuvHvjj4vQuMfQu3ssODPOFHiddKCmvILjj9mjOMMkvUMKkBdvs(MQkACOIW5qfP1HkO5jPQ7PQSpjrhevsTqvspevenrvQkxevGSrubQpkbXjvPkALG4MQuL2PKYqLG0srfWtfAQsO9k6VimybhMyXaEmutwfxMYMb1NvLgTeDAsRwLQQxdsnBfUnq7wQFR0WrulhPNJY0P66OQTRk8DvrJhvOZJkQ1RQsnFuj2pKZlzXmEe3YAvH6cNc1pH6NZQxUJRQw4m6CMSLrYcgA51YylGwgleEHEuPZizHZJvozXmYwEk2YyP7KzCijsVQxYdmXlijMcYpex3gtfyNetbXKaglajayPIh7bjY0fwhgJuHsnoGOhgPcLdqCFuE9qui8c9OspzkioJa86WVNDcKXJ4wwRkux4uO(ju)Cw9YDCv1lzu49YLMXOcYjZyPEowNaz8ymCglafkeEHEuPrH7JYRheKcqHs3jZ4qsKEvVKhyIxqsmfKFiUUnMkWojMcIjbmwasaWsfp2dsKPlSomgPcLACarpmsfkhG4(O86HOq4f6rLEYuqmcsbOae(bNrHFYnkufQlCkkuruO6fo8oOqqqqkaf4KLs)AmoebPauOIOaxFo2bfUx11xX1TrbbqhQRgBIGuakuruGRph7GcrO5hdu4QWkNzCOmNLfZiE3XzF2SSyw7swmJc21TZi511TZO1cWWo510ZAvZIzuWUUDgbg7EiG5PCoJwlad7KxtpRv4SygfSRBNraJYmk0A)MrRfGHDYRPN1UllMrb762zuOyPncFPuR9mATamStEn9SwDzXmkyx3oJd9T0ze3p)5f0ApJwlad7KxtpRXvzXmkyx3oJWk1ag7EYO1cWWo510ZA)mlMrb762zuASXCQmiWYyKrRfGHDYRPN14ezXmATamStEnJyQ6gvLmcWddpbmHsaVuWjp5mkyx3oJacfAg0ANEwJtZIz0AbyyN8AgXu1nQkzeGhgEcycLaEPGtEYzuWUUDgh8Tqjambm9S2fOYIz0AbyyN8AgXu1nQkzeGhgEcycLaEPGtEYzuWUUDgbOkZhA)saZttpRD5swmJwlad7KxZiMQUrvjJ)cfoRpb3THvQnDfdT2VOax4ckiyxFyewBGQXqHkrHlOWpqH)OWz9PxsfwjbGj0PRyO1(nJc21TZO2yH2IRBNEw7s1SygfSRBNrEMrOUbYYO1cWWo510tpJGQRVIRBNfZAxYIz0AbyyN8AgXu1nQkzuB8cQ9lXraLxJOogkujka1SADOqfqHstgE5eu4ik8hfa4HHNkDByE6KAGI2muOEu4fFqHkGcvZOGDD7mQ0TH5PPN1QMfZO1cWWo51mIPQBuvYyPjdVCI5PuRDuOEuaQjxHcvafknz4LtqHJzuWUUDgHPw)B1oeu71AJkUUD6zTcNfZO1cWWo51mIPQBuvYyPjdVCsg7Oq9OqDqHc)rbTXlO2VehbuEnI6yOqLOauZQ1Hcvafknz4LtqHJzuWUUDgbek0mO1o9S2DzXmATamStEnJyQ6gvLmcWddpz80h6dzqOnZ1g7S5zF2OWFuO0KHxojJDuOEuOW1Hc)rbTXlO2VehbuEnI6yOqLOauZQ1Hcvafknz4LtqHJzuWUUDgz80h6dzqOnZ1g7S0tpJhdw4hEwmRDjlMrb762zKbn)yqaiSYmATamStEn9Sw1SygTwag2jVMrb762zelJbHGDDBIHY8mouMt0cOLrq11xX1TtpRv4SygTwag2jVMrb762zelJbHGDDBIHY8mouMt0cOLr8UJZ(SzPN1UllMrRfGHDYRzetv3OQKrQ8AZJbRy1rH6rHQqHc)rbb76dJWAdungkupkCxgfSRBNrqHFKEwRUSygTwag2jVMrmvDJQsgPYRnpgSIvhfQhfQcfk8hfmgZASnXBdpuSti9HG5uf2MGY9Vuu4pkCpqbaEy4jRuOKT2oe4H8Kn5jNrb762zeu4hPN14QSygTwag2jVMrmvDJQsgXlZrHpuakuGlCbf(fkqLxdfQefWlZrH)OG8BJQUnhcNnQDiaL2Mwlad7Gc)rbb76dJWAdungkujkuff(rgfSRBNrLUnmpn9S2pZIz0AbyyN8AgXu1nQkz8S(0lPcRKaWe6K5cgAu4dfoRp9sQWkjamHobfosWCbdnlJc21TZiz(XdJQ)2spRXjYIz0AbyyN8AgXu1nQkz8S(eC3gwP2KAWuJvkaddf(Jcc21hgH1gOAmuOEuOAgfSRBNrWDByLAPN140SygTwag2jVMrmvDJQsg)fkaWddp1gl0wCD75zF2OWFuqWU(WiS2avJHcvIcxqHFGcCHlOWVqbaEy4P2yH2IRBp5jJc)rbb76dJWAdungkujkChk8Jmkyx3oJEjvyLeaMqtpRDbQSygTwag2jVMrmvDJQsgb4HHNAJfAlUU98SpBu4pkiyxFyewBGQXqHkrH7YOGDD7mYEQKncatOPN1UCjlMrRfGHDYRzetv3OQKXZ6tVKkSscatOtxXqR9BgfSRBNrqPFhw6zTlvZIz0AbyyN8AgXu1nQkzeGhgE(kdb7kM4LxOhv6jpzu4pkiyxFyewBGQXqH6rHQzuWUUDgb3THvQLEw7sHZIzuWUUDg9sQWkjamHMrRfGHDYRPN1UCxwmJwlad7KxZiMQUrvjJYVnQ62K8(0OelmHxAeG72tQ0qJcvIcxqH)OGGD9HryTbQgdf(qHlzuWUUDgb3THvQLEw7sDzXmkyx3oJSNkzJaWeAgTwag2jVME6zKm1WliG4zXS2LSygfSRBNrqdCPCMyHjg8y9qCOMaYYO1cWWo510ZAvZIzuWUUDgbmHsaVuWmATamStEn9SwHZIzuWUUDgjVUUDgTwag2jVME6PNXhgLPBN1Qc1foXfOQw4z1Q3v4m(uOT2VSmEpbjVu3oOWDOGGDDBuyOmNnrqYiJSHZAxG6UmsMUW6WYybOqHWl0JknkCFuE9GGuaku6ozghsI0R6L8at8csIPG8dX1TXub2jXuqmjeKcqbi8doJc)KBuOkux4uuOIOq1lC4DqHGGGuakWjlL(1yCicsbOqfrbU(CSdkCVQRVIRBJccGouxn2ebPauOIOaxFo2bfIqZpgOWvHvorqqqkaf4G4OH5D7Gcag8snuaVGaIJca2R2SjkW1ySr2zOqVDflfkim)afeSRBZqHThCEIGuakiyx3Mnjtn8cci(h8qyqJGuakiyx3Mnjtn8cci(TpsW7EqqkafeSRBZMKPgEbbe)2hjH)f0AxCDBeeb762SjzQHxqaXV9rc0axkNjwyIbpwpehQjGmeeb762SjzQHxqaXV9rcWekb8sbrqkafITqMvUokqf9Gca8WW2bfyU4muaWGxQHc4feqCuaWE1MHcsFqbYuRIKx31(ffugkC22MiifGcc21TztYudVGaIF7JeRfYSY1jyU4meeb762SjzQHxqaXV9rI8662iiiifGcCqC0W8UDqb7Hr5mk4kOHcEPHcc2xkkOmuqEi6qag2ebrWUUn7Jbn)yqaiSseeb762SBFKWYyqiyx3MyOmN7waTpq11xX1TrqeSRBZU9rclJbHGDDBIHYCUBb0(W7oo7ZMHGiyx3MD7JeOWp4wH)OYRnpgSIvV(Qq9xWU(WiS2avJv)Diic21Tz3(ibk8dUv4pQ8AZJbRy1RVku)ngZASnXBdpuSti9HG5uf2MGY9V0)3daEy4jRuOKT2oe4H8Kn5jJGiyx3MD7JKs3gMNYTc)HxM)bfx4YVOYRvjEz(F53gvDBoeoBu7qakTnTwag25VGD9HryTbQgRYQ)abrWUUn72hjY8Jhgv)TXTl0xZju4VZ6tVKkSscatOtMlyO)oRp9sQWkjamHobfosWCbdndbrWUUn72hjWDByLAC7c91Ccf(7S(eC3gwP2KAWuJvkad7VGD9HryTbQgR(Qiic21Tz3(i5LuHvYTc)9laEy4P2yH2IRBpp7Z(VGD9HryTbQgRYl)GlC5xa8WWtTXcTfx3EYt(VGD9HryTbQgRY7(bcIGDDB2TpsSNkzJBf(dGhgEQnwOT462ZZ(S)lyxFyewBGQXQ8oeeb762SBFKaL(DyCRWFN1NEjvyLeaMqNUIHw7xeeb762SBFKa3THvQXTl0xZju4paEy45RmeSRyIxEHEuPN8K)lyxFyewBGQXQVkcIGDDB2TpsEjvyLiifGcCW6yGcpvVefU3DByLAOWt1lrHcD97LJvrqeSRBZU9rcC3gwPg3k8N8BJQUnjVpnkXct4Lgb4U9Kkn0vE5VGD9HryTbQg77ccIGDDB2TpsSNkzdbbbrWUUnBcQU(kUU9Ns3gMNYTc)PnEb1(L4iGYRruhRsOMvRRcLMm8YjOWX)a8WWtLUnmpDsnqrBw9V4tfQIGiyx3MnbvxFfx3(2hjyQ1)wTdb1ET2OIRBZTc)vAYWlNyEk1AVEOMCvfknz4LtqHJiic21Tztq11xX1TV9rcqOqZGwBUv4VstgE5Km2RVoO(RnEb1(L4iGYRruhRsOMvRRcLMm8YjOWreeb762SjO66R4623(iX4Pp0hYGqBMRn2zCRWFa8WWtgp9H(qgeAZCTXoBE2N9)stgE5Km2RVW19xB8cQ9lXraLxJOowLqnRwxfknz4LtqHJiiiic21Tzt8UJZ(SzFKxx3gbPauqWUUnBI3DC2Nn72hPstOoHXywJneeb762SjE3XzF2SBFKag7EiG5PCgbrWUUnBI3DC2Nn72hjaJYmk0A)IGiyx3MnX7oo7ZMD7JKqXsBe(sPw7iic21Tzt8UJZ(Sz3(in03sNrC)8NxqRDeeb762SjE3XzF2SBFKGvQbm29GGiyx3MnX7oo7ZMD7JK0yJ5uzqGLXabrWUUnBI3DC2Nn72hjaHcndAT5wH)a4HHNaMqjGxk4KNmcIGDDB2eV74SpB2Tpsd(wOeaMaYTc)bWddpbmHsaVuWjpzeeb762SjE3XzF2SBFKaOkZhA)saZt5wH)a4HHNaMqjGxk4KNmcIGDDB2eV74SpB2TpsAJfAlUUn3k83VoRpb3THvQnDfdT2VCHlc21hgH1gOASkV8J)N1NEjvyLeaMqNUIHw7xeeb762SjE3XzF2SBFK4zgH6gil90Ze]] )

end