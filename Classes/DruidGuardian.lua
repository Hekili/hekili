-- DruidGuardian.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


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
        intimidating_roar = 22916, -- 236748
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
        barkskin = {
            id = 22812,
            cast = 0,
            cooldown = 60,
            gcd = "off",
            
            startsCombat = false,
            texture = 136097,
            
            toggle = "defensives",
            defensive = true,

            usable = function () return tanking or incoming_damage_3s > 0 end,
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
            
            startsCombat = false,
            texture = 132276,

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
            
            usable = function () return incoming_damage_3s > health.max * 0.1 end,
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
            usable = function () return combo_points.current > 0 end,
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

            copy = "incarnation_guardian_of_ursoc"            
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
            
            usable = function () return tanking or incoming_damage_3s > 0 end,
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

            spend = function () return -8 + ( buff.gore.up and -4 or 0 ) end,
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
            
            spend = 45,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132136,

            form = "bear_form",
            
            handler = function ()                
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
        

        prowl = {
            id = 5215,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = false,
            texture = 514640,
            
            usable = function () return ( time == 0 or boss ) and not buff.prowl.up end,
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
            
            usable = function () return debuff.thrash_bear.up end,
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
            usable = function () return buff.bear_form.down and buff.cat_form.down and buff.travel_form.down and buff.moonkin_form.down end,
            
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

            usable = function () return buff.bear_form.down and buff.cat_form.down and buff.travel_form.down and buff.moonkin_form.down end,           
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
            
            usable = function () return debuff.dispellable_poison.up or debuff.dispellable_curse.up end,
            handler = function ()
                removeDebuff( "player", "dispellable_poison" )
                removeDebuff( "player", "dispellable_curse" )
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
            
            usable = function () return combo_points.current > 0 end,
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

            usable = function () return target.casting end,
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
            cooldown = 120,
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
            cooldown = function () return ( ( level < 116 and equipped.dual_determination ) and 0.85 or 1 ) * 240 end,
            recharge = function () return ( ( level < 116 and equipped.dual_determination ) and 0.85 or 1 ) * 240 end,
            gcd = "off",
            
            startsCombat = false,
            texture = 236169,

            toggle = "defensives",
            defensive = true,
            
            usable = function () return tanking or incoming_damage_3s > 0 end,
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


    spec:RegisterPack( "Guardian", 20181022.2125, [[dueRuaWifjBcbgfcLofcvTkQe9kfLzrL0TisAxQQFbWWqqhtrSmQONbuyAavUgczBaL8nvjLXbu05OsW6ak18uL4EQI9jj1bPsOfkjEirImrjjCrjjYgvLu1hrOYjLKOwjGUjrc7Kk1pjsudvsslfHINsvtLkSxH)IOblXHrTyL6XqnzLCzkBguFgiJwsDAsRwvsLxtKA2kCBq2Tu)wLHtelhPNty6IUorTDfvFxvQXdu15vKQ1RiL5Rkj7hYXKWr4xCAHBNeobmNqOtNFNtCsKtxi850LyHxcJLMbzHVzil8eNmtxk3Hxcp9XXRWr4fNmfBHVotjcWgaaqAwlV)4dcGqHKhCQxJPmCcqOqya7XTbSHzPUS5aKqpyDycavLAedRlbGQsmKvbvwxKeNmtxk3FHcHd)wwhzvUJD4xCAHBNeobmNqOtNFNtCsKZxl8SCwF0W7viPu4R11Y6yh(LjWHFkuH4Kz6s5gvQcQSUqaNcvQZuIaSbaaKM1Y7p(Gaiui5bN61ykdNaekegWECBaBywQlBoaj0dwhMaqvPgXW6saOQedzvqL1fjXjZ0LY9xOqyeWPqfPmoVTrrfNoDfvCs4eWevKkQ4cGTtIqLQkfiGiGtHksPAUbzcWgbCkurQOIlUw2cvKcnvqCQxJk8whAQM4JaofQivuXfxlBHkEPLhduPclQ)HFOIueocp(UX6E3IWr4Es4i8mo1RdVKl1RdV18EyROsKHBNHJWZ4uVo87XDlsyz60dV18EyROsKHBWiCeEgN61HFBuHrLwBqH3AEpSvujYWn4chHNXPED4zkMBJmpk16m8wZ7HTIkrgUjkCeEgN61HFOGQtb5RtEbcY6m8wZ7HTIkrgUbRWr4zCQxhEyLA7XDRWBnVh2kQez4(1chHNXPED45gBIKYdsmpgH3AEpSvujYWnygocV18EyROs4XunnQYHFldd)3gtjHpk0xws4zCQxh(HCZuYTXqrgUDHWr4TM3dBfvcpMQPrvo8Bzy4)2ykj8rH(YscpJt96WVPQihAdIewMgz4EcHHJWZ4uVo8YcJutdseER59WwrLiJm8qAQG4uVoCeUNeocV18EyROs4XunnQYHxB8bPniYfdXGmsIeOs1OcHFNeHkUevQnEK1Fig8OcbOYwgg(R0RHLPFQbXAlqLxqfq4fQ4suXz4zCQxhELEnSmnYWTZWr4TM3dBfvcpMQPrvo81gpY6pwMsTorLxqfc)GfQ4suP24rw)HyWhEgN61HhMA90uBrsnqwBuo1RJmCdgHJWBnVh2kQeEmvtJQC4RnEK1Fj4evEbviIquHaurB8bPniYfdXGmsIeOs1OcHFNeHkUevQnEK1Fig8HNXPED43mvAH0Ahz4gCHJWBnVh2kQeEmvtJQC43YWWFHmDUoNhKAlsTXP4VU3nQqaQuB8iR)sWjQ8cQageHkeGkAJpiTbrUyigKrsKavQgvi87KiuXLOsTXJS(dXGp8mo1RdVqMoxNZdsTfP24uezKHFzWS8idhH7jHJWZ4uVo8cPLhdYnlQdV18EyROsKHBNHJWBnVh2kQeEgN61HhZJbjJt9AYHkYWpurs2mKfEinvqCQxhz4gmchH3AEpSvuj8mo1RdpMhdsgN61KdvKHFOIKSzil847gR7DlImCdUWr4TM3dBfvcpMQPrvo8ugK9xgSI1evEbvMqiQqaQW4uNBKwBqQjqLxqfWfEgN61HhILhrgUjkCeER59WwrLWJPAAuLdp(ejQ8GkeIkV6vOcXIkugKHkvJk4tKOcbOcpnJQP9h80nQTiH42(wZ7HTqfcqfgN6CJ0AdsnbQunQ4evi(WZ4uVo8k9AyzAKHBWkCeEfwHd)6YFwtzrn52y6xKmw6N1L)SMYIAYTX0pedEsrYyPfHNXPED4LipMBuDAw4TM3dBfvImC)AHJWBnVh2kQeEmvtJQC4xx(HURHvQ9Pgm1e18EyOcbOcJtDUrATbPMavEbvCgEgN61Hh6UgwPwKHBWmCeEgN61HxBmtBo1RdV18EyROsKHBxiCeER59WwrLWJPAAuLdpXIkBzy4V2yM2CQx)x37gviavyCQZnsRni1eOs1OYeuH4rLx9kuHyrLTmm8xBmtBo1R)YsqfcqfgN6CJ0AdsnbQunQaouH4dpJt96WN1uwutUnMgz4EcHHJWBnVh2kQeEmvtJQC43YWWFTXmT5uV(VU3nQqaQW4uNBKwBqQjqLQrfWfEgN61Hx8wLyKBJPrgUNmjCeER59WwrLWJPAAuLd)6YFwtzrn52y6pvS0Adk8mo1Rdpe3GgwKH7jodhH3AEpSvuj8yQMgv5WVLHH)G4bJtftcsMPlL7VSeuHauHXPo3iT2GutGkVGkodpJt96WdDxdRulYW9eWiCeEgN61HpRPSOMCBmn8wZ7HTIkrgUNaUWr4zCQxhEiwEeER59WwrLid3tikCeER59WwrLWJPAAuLdppnJQP9LCVnk5btM1gj0D9NYT0Os1OYeuHauHXPo3iT2GutGkpOYKWZ4uVo8q31Wk1ImCpbSchHNXPED4fVvjg52yA4TM3dBfvImYWlHA4dAZz4iCpjCeER59WwrLid3odhH3AEpSvujYWnyeocV18EyROsKHBWfocpJt96WVnMscFuOWBnVh2kQez4MOWr4TM3dBfvImCdwHJWZ4uVo8sUuVo8wZ7HTIkrgzKHFUrf61HBNeobmNqiHG1FYRboIc)BM2Adse(QmKKJM2cvahQW4uVgvgQifFeWWlHEW6Wc)uOcXjZ0LYnQufuzDHaofQuNPebydaainRL3F8bbqOqYdo1RXugobiuimG942a2WSux2CasOhSombGQsnIH1LaqvjgYQGkRlsItMPlL7VqHWiGtHkszCEBJIkoD6kQ4KWjGjQivuXfaBNeHkvvkqaraNcvKs1CdYeGnc4uOIurfxCTSfQifAQG4uVgv4To0unXhbCkurQOIlUw2cv8slpgOsfwu)raraNcvQsG3WYPTqLTbFudvWh0MtuzBG0w8rfxeJnjPav6RLAntHGLhOcJt9AbQC9y6FeqgN61IVeQHpOnNpWdwinciJt9AXxc1Wh0MZzpaGVBHaY4uVw8Lqn8bT5C2dawgeK1jN61iGmo1RfFjudFqBoN9ayBmLe(OqiGtHk(MLiQVevOSUqLTmmSTqfrYPav2g8rnubFqBorLTbsBbQW9cvKqnPk5YuBqOIkqL112hbKXPET4lHA4dAZ5ShaIMLiQVKuKCkqazCQxl(sOg(G2Co7bGKl1RraraNcvQsG3WYPTqfBUrNoQKkKHkzTHkmopkQOcuHNZ6G3d7JaY4uVw8iKwEmi3SOgbKXPETy2dampgKmo1RjhQiDTzi7bstfeN61iGmo1RfZEaG5XGKXPEn5qfPRndzp47gR7DlqazCQxlM9aaILhUQWpugK9xgSI18LjesaJtDUrATbPM4fWHaY4uVwm7bGsVgwM6Qc)Gpr(q4REfXszqw14tKeWtZOAA)bpDJAlsiUTV18EylcyCQZnsRni1ev7K4razCQxlM9aqI8yUr1PzUQWk8Z6YFwtzrn52y6xKmw6N1L)SMYIAYTX0pedEsrYyPfiGmo1RfZEaaDxdRuZvf(zD5h6UgwP2NAWutuZ7HraJtDUrATbPM4fNiGmo1RfZEaOnMPnN61iGmo1RfZEaK1uwutUnM6Qc)qSBzy4V2yM2CQx)x37MagN6CJ0Adsnr1ti(x9kIDldd)1gZ0Mt96VSecyCQZnsRni1evdoIhbKXPETy2daXBvIrUnM6Qc)SLHH)AJzAZPE9FDVBcyCQZnsRni1evdoeqgN61IzpaG4g0WCvHFwx(ZAklQj3gt)PILwBqiGmo1RfZEaaDxdRuZvf(zldd)bXdgNkMeKmtxk3FzjeW4uNBKwBqQjEXjciJt9AXShaznLf1KBJPiGmo1RfZEaaXYdeWPqLxVogOYBnRrfP4UgwPgQ8wZAuPQxkfG3jciJt9AXShaq31Wk1CvHF4PzunTVK7TrjpyYS2iHUR)uULU6jeW4uNBKwBqQjEMGaY4uVwm7bG4TkXi3gtrarazCQxl(qAQG4uV(rPxdltDvHF0gFqAdICXqmiJKir1e(DsKlRnEK1Fig8eSLHH)k9Ayz6NAqS2IxaHxU0jciJt9AXhstfeN61ZEaatTEAQTiPgiRnkN61UQWp1gpY6pwMsToFHWpy5YAJhz9hIbpciJt9AXhstfeN61ZEaSzQ0cP12vf(P24rw)LGZxiIqc0gFqAdICXqmiJKir1e(DsKlRnEK1Fig8iGmo1RfFinvqCQxp7bGqMoxNZdsTfP24u4Qc)SLHH)cz6CDopi1wKAJtXFDVBcQnEK1Fj48fWGic0gFqAdICXqmiJKir1e(DsKlRnEK1Fig8iGiGmo1RfF8DJ19UfpsUuVgbKXPET4JVBSU3Ty2dG94UfjSmD6iGmo1RfF8DJ19UfZEaSnQWOsRnieqgN61Ip(UX6E3IzpaykMBJmpk16ebKXPET4JVBSU3Ty2dGHcQofKVo5fiiRteqgN61Ip(UX6E3IzpaGvQTh3TqazCQxl(47gR7DlM9aGBSjskpiX8yGaofQW4uVw8X3nw37wm7bWMPslKwBxv4NTmm8FBmLe(OqFzjiGmo1RfF8DJ19UfZEamKBMsUngYvf(zldd)3gtjHpk0xwcciJt9AXhF3yDVBXShaBQkYH2GiHLPUQWpBzy4)2ykj8rH(YsqazCQxl(47gR7DlM9aqwyKAAqIWlKy4W9ecbxKrgb]] )
    
end