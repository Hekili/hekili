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


    spec:RegisterPack( "Guardian", 20181023.2242, [[dueTuaWifrBcjmkIqDkIGwfvIELIYSOs6werTlv1VayyaPJPiTmIYZiImnjPUgrQTHevFtsImovr5CujO1PkQMNIQUNQ0(ueoOKewOK4HujWePsOlQksAJQIu9rIqoPQiXkb0njcStQu)usIAOssAPir5Pu1ujQ2RWFrQblXHrTyL6XqnzLCzkBgsFgOgTK60KwTQiLxtKmBfUne7wQFRYWrslhXZjmDrxNk2UQW3bIXJe58QIy9kQ08vuX(bDmnKh(fNw4wgOtF2uqLjPVmzvltw1HpFcvl8uzSumyl8nJyHxICyYs5o8u5NmoEfYdV4Ciyl81zsv8CaaaRzTZ(JpeacfXzWPEnMWOjaHIGbSh3gWgLL8YEaGk5q1HjauvIrzSUeaQkLr7IehDrlromzPC)fkco8BhDKpLo2HFXPfULb60Nnfuzs6ltw1YKjPWZoz9rcVxrCbHVwxlRJD4xMah(jHfjYHjlLByXfjo6ccCsyPotQINdaaynRD2F8HaqOiodo1RXegnbiuemG942a2OSKx2daujhQombGQsmkJ1LaqvPmAxK4OlAjYHjlL7VqrWqGtclvzCEBJalYKKRWImqN(myrYWYuqFE1YGLQkbqGqGtclUGAUbBINdbojSizyPkwlBblsGMkyo1RHfERdnvt8HaNewKmSufRLTGfVuoJbSuHf1)Wpurkc5HhF3yDG0IqE4EAip8mo1Rdp1l1RdV18EyROsKHBzH8WZ4uVo87XDlAuhYtcV18EyROsKHBjfYdpJt96WVnIWisPn4WBnVh2kQez4U6qE4zCQxhEMG52OZJqSodV18EyROsKHBPd5HNXPED4hk46uq)0CwGrSodV18EyROsKHBkpKhEgN61Hhvj2EC3k8wZ7HTIkrgURsH8WZ4uVo8CJnrs4bnMhJWBnVh2kQez4(zH8WBnVh2kQeEmrtJOC43oOO)TXeA0JG8DOgEgN61HF40mHEBmsKHBxyip8wZ7HTIkHht00ikh(Tdk6FBmHg9iiFhQHNXPED43evKdTbtJ6qImCpf0qE4zCQxhEhHrRPHicV18EyROsKrgEenvWCQxhYd3td5H3AEpSvuj8yIMgr5WRn(q0gm9IryWgT0cyzcyb0VmPHfxcl1gpY6pctjyHcyz7GI(vY1OoKpXqyTfWY8Wcy8cwCjSil8mo1RdVsUg1Hez4wwip8wZ7HTIkHht00ikh(AJhz9h7qiwNWY8WcOFkhwCjSuB8iR)imLcpJt96WJsSEUQTOjgyRncN61rgULuip8wZ7HTIkHht00ikh(AJhz9NkoHL5HfPbfwOaw0gFiAdMEXimyJwAbSmbSa6xM0WIlHLAJhz9hHPu4zCQxh(ntKsiL2rgURoKhER59WwrLWJjAAeLd)2bf9lCip0h8GwBrQnof)1bsdlual1gpY6pvCclZdlssAyHcyrB8HOny6fJWGnAPfWYeWcOFzsdlUewQnEK1FeMsHNXPED4foKh6dEqRTi1gNIiJm8ldLDgzipCpnKhEgN61HxiLZyqVzrD4TM3dBfvImCllKhER59WwrLWZ4uVo8yEmOzCQxtpurg(Hks6MrSWJOPcMt96id3skKhER59WwrLWZ4uVo8yEmOzCQxtpurg(Hks6MrSWJVBSoqArKH7Qd5H3AEpSvuj8yIMgr5WtyW2FzOkwtyzEyzkOWcfWcJt9HrBTHOMawMhwQo8mo1Rdpc7mImClDip8wZ7HTIkHht00ikhE8jsy5fwafwMZCGfjgwimydwMawWNiHfkGfEUgrt7p4NyeBrJWT9TM3dBblualmo1hgT1gIAcyzcyrgSiHHNXPED4vY1OoKid3uEip8wZ7HTIkHht00ikh(1L)SMWIA6TXKVizSuWYlSSU8N1ewutVnM8rykrlsglLi8mo1RdpvNXdJOZ1ImCxLc5H3AEpSvuj8yIMgr5WVU8JCxJQe7tmuIjQ59WGfkGfgN6dJ2AdrnbSmpSil8mo1RdpYDnQsSid3plKhEgN61HxBmtAo1RdV18EyROsKHBxyip8wZ7HTIkHht00ikhEjgw2oOOFTXmP5uV(VoqAyHcyHXP(WOT2qutaltaltHfjewMZCGfjgw2oOOFTXmP5uV(7qfwOawyCQpmARne1eWYeWs1WIegEgN61HpRjSOMEBmjYW9uqd5H3AEpSvuj8yIMgr5WVDqr)AJzsZPE9FDG0WcfWcJt9HrBTHOMawMawQo8mo1RdVaeLQrVnMez4E60qE4TM3dBfvcpMOPruo8Rl)znHf10BJj)uXsPn4WZ4uVo8iCdEyrgUNklKhER59WwrLWJjAAeLd)2bf9dMhmovmnyhMSuU)ouHfkGfgN6dJ2AdrnbSmpSil8mo1RdpYDnQsSid3tLuip8mo1RdFwtyrn92ys4TM3dBfvImCpT6qE4zCQxhEe2zeER59WwrLid3tLoKhER59WwrLWJjAAeLdppxJOP9PEGye6dLoRnAK76pHBPGLjGLPWcfWcJt9HrBTHOMawEHLPHNXPED4rURrvIfz4EkLhYdpJt96WlarPA0BJjH3AEpSvujYidpvIHpKnNH8W90qE4TM3dBfvImCllKhER59WwrLid3skKhER59WwrLid3vhYdpJt96WVnMqJEeKWBnVh2kQez4w6qE4TM3dBfvImCt5H8WZ4uVo8uVuVo8wZ7HTIkrgzKH)Hre61HBzGo9ztbvMSVSPYKo8GWKwBWIW)uqOEK0wWs1WcJt9AyzOIu8HadVGQHd3tbT6WtLCO6Wc)KWIe5WKLYnS4IehDbbojSuNjvXZbaaSM1o7p(qaiueNbN61ycJMaekcgWECBaBuwYl7baQKdvhMaqvjgLX6saOQugTlsC0fTe5WKLY9xOiyiWjHLQmoVTrGfzsYvyrgOtFgSizyzkOpVAzWsvLaiqiWjHfxqn3GnXZHaNewKmSufRLTGfjqtfmN61WcV1HMQj(qGtclsgwQI1YwWIxkNXawQWI6peie4KWYtLsg2jTfSSn0JyWc(q2CclBdS2IpSufySrnfWsFTKRzccQZawyCQxlGLRhp5dbY4uVw8Psm8HS58fDWcPGazCQxl(ujg(q2Co7fa6DliqgN61IpvIHpKnNZEbWoGrSo5uVgcKXPET4tLy4dzZ5SxaBJj0OhbbcCsyX3mvr9LWcH1fSSDqrTfSisofWY2qpIbl4dzZjSSnWAlGfUxWcvIjzQxMAdgwubSSU2(qGmo1RfFQedFiBoN9cq0mvr9L0IKtbeiJt9AXNkXWhYMZzVaOEPEneie4KWYtLsg2jTfSypmYtGLurmyjRnyHX5rGfval8dwh8EyFiqgN61IxHuoJb9Mf1qGmo1RfZEbG5XGMXPEn9qfPRnJyViAQG5uVgcKXPETy2lampg0mo1RPhQiDTze7fF3yDG0ciqgN61IzVaqyNHRk6lHbB)LHQynNFkOuW4uFy0wBiQjMVAiqgN61IzVauY1Ooexv0x8jYxqNZCKycd2MaFIKcEUgrt7p4NyeBrJWT9TM3dBrbJt9HrBTHOMyczsieiJt9AXSxauDgpmIoxZvf9DD5pRjSOMEBm5lsgl176YFwtyrn92yYhHPeTizSuciqgN61IzVaqURrvI5QI(UU8JCxJQe7tmuIjQ59WOGXP(WOT2qutmVmiqgN61IzVa0gZKMt9AiqgN61IzVaYAclQP3gtCvrFL4Tdk6xBmtAo1R)RdKMcgN6dJ2AdrnXetLW5mhjE7GI(1gZKMt96VdvkyCQpmARne1etuTecbY4uVwm7fGaeLQrVnM4QI(UDqr)AJzsZPE9FDG0uW4uFy0wBiQjMOAiqgN61IzVaq4g8WCvrFxx(ZAclQP3gt(PILsBWqGmo1RfZEbGCxJQeZvf9D7GI(bZdgNkMgSdtwk3FhQuW4uFy0wBiQjMxgeiJt9AXSxaznHf10BJjqGmo1RfZEbGWodiWjHLNUogWciAwdlsWDnQsmybenRHLQEPeqjzqGmo1RfZEbGCxJQeZvf9LNRr00(upqmc9HsN1gnYD9NWTutmLcgN6dJ2AdrnX7uiqgN61IzVaeGOun6TXeiqiqgN61IpIMkyo1RFvY1Ooexv0xTXhI2GPxmcd2OLwmbOFzs7YAJhz9hHPefBhu0VsUg1H8jgcRTyEW4LlLbbY4uVw8r0ubZPE9SxaOeRNRAlAIb2AJWPETRk6BTXJS(JDieRZ5b9t5US24rw)rykbbY4uVw8r0ubZPE9SxaBMiLqkTDvrFRnEK1FQ4CEPbLcTXhI2GPxmcd2OLwmbOFzs7YAJhz9hHPeeiJt9AXhrtfmN61ZEbiCip0h8GwBrQnofUQOVBhu0VWH8qFWdATfP24u8xhinf1gpY6pvCoVKKMcTXhI2GPxmcd2OLwmbOFzs7YAJhz9hHPeeieiJt9AXhF3yDG0IxQxQxdbY4uVw8X3nwhiTy2lG94UfnQd5jqGmo1RfF8DJ1bslM9cyBeHrKsBWqGmo1RfF8DJ1bslM9cGjyUn68ieRtiqgN61Ip(UX6aPfZEbmuW1PG(P5SaJyDcbY4uVw8X3nwhiTy2lauLy7XDliqgN61Ip(UX6aPfZEbWn2ejHh0yEmGaNewyCQxl(47gRdKwm7fWMjsjKsBxv03Tdk6FBmHg9iiFhQqGmo1RfF8DJ1bslM9cy40mHEBmIRk672bf9VnMqJEeKVdviqgN61Ip(UX6aPfZEbSjQihAdMg1H4QI(UDqr)BJj0Ohb57qfcKXPET4JVBSoqAXSxaocJwtdrezKraa]] )
    
end