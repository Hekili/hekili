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


    spec:RegisterPack( "Guardian", 20181006.1745, [[duKouaWijvTjKOrHkKtHkHvjKYRuunlHQUfQK2LQ8laggqCmfXYasptvrMMqLRHkABcP6BOcmoHKohQezDQkQ5PQW9uvTpjvoOqIwOKYdrcQjkKWfvKqBeji9rubDsujQvcOBQir7uO8tfjyOibwkQq9ubtvi2lv)fPgSehMyXk1JrmzLCzsBgsFgOgTKCAkRgjiEnQuZwHBdXUL63QmCK0YH65OmDrxhvTDfLVRQ04rcDEfPSEfjnFfPA)G2N4r8Wss1JbkitI6eqaj6VjCqCrLZ48qonQQhOkeUfWQhAbr9ahYl4LjThOktBCYYJ4b2XJjQhQYKk7Zaaa2Yk(9JCiaygc)qs7AcwqtamdHaypUnGnQW1Lodav8HAdLbGcWkhl2IbGc4y6OaZBlAoKxWlt6hZqiEyZBJKl3(2dljvpgOGmjQtabKO)MWbXfvqN4bHpRoShcgcf2dv2APTV9WszepupSWH8cEzsdlrbM3wqG1dlvzsL9zaaaBzf)(roeamdHFiPDnblOjaMHqaSh3gWgv46sNbGk(qTHYaqbyLJfBXaqbCmDuG5TfnhYl4Lj9JzieiW6HLPajVTIHLOhpSakitIkSWvyzch8544ececSEyHcxjnyL9ziW6HfUclr5APlyzkT0alPDnSiBByPPShey9WcxHLOCT0fSe4MFmGLAcR65HHXsMhXdK7gR7BZ8iESjEepiK0U2duV0U2dAl7HU8AE6Xa1J4bHK21EypUBrJYJNMh0w2dD5180J9jpIhesAx7HTIzkMBRb7bTL9qxEnp9yX5r8Gqs7ApiyI0kDEyS2Ph0w2dD5180JXPhXdcjTR9WWaxLmAke(fyeTtpOTSh6YR5Phl6EepiK0U2dOgw3J7wEqBzp0LxZtpgh4r8Gqs7Apinrzjwg0ezm8G2YEOlVMNESO6r8G2YEOlVMhiylvSjEyZJI(2QGPrpmYJNQhesAx7HbFly6TkiE6X4sEepOTSh6YR5bc2sfBIh28OOVTkyA0dJ84P6bHK21EyJnwoSgmnkp2tp2eq8iEqiPDTh4zkTLkcZdAl7HU8AE6PhqS0alPDThXJnXJ4bTL9qxEnpqWwQyt8G1KdXAW0lbraR0CYGL6GfqEGYjSenyPsLrw9qekcluclBEu0NHVgLh)WkIyndw(awatwWs0Gfq9Gqs7Apy4Rr5XE6Xa1J4bTL9qxEnpqWwQyt8qLkJS6r4XyTty5dybKx0HLOblvQmYQhIqrpiK0U2dOyTNQPlAScwBflPDTNESp5r8G2YEOlVMhiylvSjEOsLrw9Ossy5dyHtqGfkHfRjhI1GPxcIawP5Kbl1blG8aLtyjAWsLkJS6Hiu0dcjTR9WwWCZ42Ap9yX5r8G2YEOlVMhiylvSjEyZJI(y84z2mzqBnlTMKS36(2WcLWsLkJS6rLKWYhWYN4ewOewSMCiwdMEjicyLMtgSuhSaYduoHLOblvQmYQhIqrpiK0U2dmE8mBMmOTMLwtsMNE6HLIk8J0J4XM4r8Gqs7ApW4MFmO3cRYdAl7HU8AE6Xa1J4bTL9qxEnpiK0U2dezmOfsAxtpmw6HHXs6wqupqUBSUVnZtp2N8iEqBzp0LxZdeSLk2epGfW6BPOgXsy5dyzciWcLWIqsBMsRTIykdw(awIZdcjTR9aIWp80JfNhXdAl7HU8AEGGTuXM4bYXsy5hwabwM(0HfocwWcyfwQdwihlHfkHfzQk2s9nKPPyDrJiT(0w2dDbluclcjTzkT2kIPmyPoybuyHl8Gqs7Apy4Rr5XE6X40J4bTL9qxEnpqWwQyt8W6YxwHfwf9wf8JLcHBy5hwwx(YkSWQO3QGFicfPzPq4M5bHK21EGk)yMITPQE6XIUhXdAl7HU8AEGGTuXM4H1LpK7AudRpSIIvwLShkSqjSiK0MP0ARiMYGLpGfq9Gqs7ApGCxJAy1tpgh4r8Gqs7ApynrWTK21EqBzp0LxZtpwu9iEqBzp0LxZdeSLk2epWrWYMhf9znrWTK21V19THfkHfHK2mLwBfXugSuhSmbw4cyz6thw4iyzZJI(SMi4ws76hpvyHsyriPntP1wrmLbl1blXblCHhesAx7HSclSk6Tkyp9yCjpIh0w2dD518abBPInXdBEu0N1eb3sAx)w33gwOewesAZuATvetzWsDWsCEqiPDThyFnQk9wfSNESjG4r8G2YEOlVMhiylvSjEyD5lRWcRIERc(LgHBRb7bHK21EarAWd1tp2KjEepOTSh6YR5bc2sfBIh28OOpWYqiPrObZl4Lj9JNkSqjSiK0MP0ARiMYGLpGfq9Gqs7ApGCxJAy1tp2eq9iEqiPDThYkSWQO3QG9G2YEOlVMNESjFYJ4bHK21Ear4hEqBzp0LxZtp2K48iEqBzp0LxZdeSLk2epitvXwQpQ3xftFO0zLsJCx)WsZnSuhSmbwOewesAZuATvetzWYpSmXdcjTR9aYDnQHvp9yt40J4bHK21EG91OQ0BvWEqBzp0LxZtp9avSsoKTKEep2epIh0w2dD5180JbQhXdAl7HU8AE6X(KhXdAl7HU8AE6XIZJ4bHK21EyRcMg9WiEqBzp0LxZtpgNEepOTSh6YR5Phl6EepiK0U2duV0U2dAl7HU8AE6PNEyMIz21EmqbzsubHl9jqEtanUO6HVcUTgmZdCzeQho1fSehSiK0UgwgglzpiqpqfFO2q9q9WchYl4LjnSefyEBbbwpSuLjv2NbaaSLv87h5qaWme(HK21eSGMaygcbWECBaBuHRlDgaQ4d1gkdafGvowSfdafWX0rbM3w0CiVGxM0pMHqGaRhwMcK82kgwIE8WcOGmjQWcxHLjCWNJJtiqiW6HfkCL0Gv2NHaRhw4kSeLRLUGLP0sdSK21WISTHLMYEqG1dlCfwIY1sxWsGB(XawQjSQheiey9WYuKIkHp1fSSv0dRWc5q2sclBfS1ShSeLeIsnzWsFnxRemck)awesAxZGLRht7bbkK0UM9OIvYHSL8hDimUHafsAxZEuXk5q2so)ha6DliqHK21ShvSsoKTKZ)bi8Gr0oL0UgcuiPDn7rfRKdzl58FaBvW0OhgbcSEyj0cvw1LWcwSfSS5rr1fSWsjzWYwrpSclKdzljSSvWwZGfPxWcvSYvQxMwdgwmgSSUwFqGcjTRzpQyLCiBjN)dG1cvw1L0SusgeOqs7A2JkwjhYwY5)aOEPDneiey9WYuKIkHp1fSOZu80GL0quyjRuyri5HHfJblYmXgYEOpiqHK21SFg38Jb9wyvqGcjTRzZ)bqKXGwiPDn9Wyz8TGO)K7gR7BZGafsAxZM)dar4hXBO)ybS(wkQrS8JjGqPqsBMsRTIyk7J4GafsAxZM)dWWxJYJJ3q)jhl)bz6tNJWcyToYXskLPQyl13qMMI1fnI06tBzp0fLcjTzkT2kIPS6aLlGafsAxZM)dGk)yMITPQXBO)RlFzfwyv0BvWpwkeU)xx(YkSWQO3QGFicfPzPq4MbbkK0UMn)haYDnQH14n0)1LpK7AudRpSIIvwLShkLcjTzkT2kIPSpafcuiPDnB(paRjcUL0UgcuiPDnB(pGSclSk6Tk44n0FoAZJI(SMi4ws7636(2ukK0MP0ARiMYQBcxm9PZrBEu0N1eb3sAx)4PsPqsBMsRTIykRU44ciqHK21S5)ayFnQk9wfC8g6)Mhf9znrWTK21V19TPuiPntP1wrmLvxCqGcjTRzZ)bGin4HgVH(VU8LvyHvrVvb)sJWT1GHafsAxZM)da5Ug1WA8g6)Mhf9bwgcjncnyEbVmPF8uPuiPntP1wrmL9bOqGcjTRzZ)bKvyHvrVvbdbkK0UMn)haIWpGaRhwOqTXaw(AzfSmL31OgwHLVwwbluWLtjfbfcuiPDnB(paK7AudRXBO)YuvSL6J69vX0hkDwP0i31pS0Cx3ekfsAZuATvetz)tGafsAxZM)dG91OQ0BvWqGqGcjTRzpelnWsAx)B4Rr5XXBO)wtoeRbtVeebSsZjRoqEGYz0QuzKvpeHIuU5rrFg(AuE8dRiI1SpatwrduiqHK21ShILgyjTRN)dafR9unDrJvWARyjTRJ3q)RuzKvpcpgRD(biVOhTkvgz1drOieOqs7A2dXsdSK21Z)bSfm3mUToEd9VsLrw9OsYp4eekTMCiwdMEjicyLMtwDG8aLZOvPYiREicfHafsAxZEiwAGL0UE(pagpEMntg0wZsRjjlEd9FZJI(y84z2mzqBnlTMKS36(2uwPYiREuj5hFItkTMCiwdMEjicyLMtwDG8aLZOvPYiREicfHaHafsAxZEK7gR7BZ(PEPDneOqs7A2JC3yDFB28Fa7XDlAuE80GafsAxZEK7gR7BZM)dyRyMI52AWqGcjTRzpYDJ19TzZ)biyI0kDEyS2jeOqs7A2JC3yDFB28FaddCvYOPq4xGr0oHafsAxZEK7gR7BZM)da1W6EC3ccuiPDn7rUBSUVnB(paPjklXYGMiJbey9WIqs7A2JC3yDFB28FaBbZnJBRJ3q)38OOVTkyA0dJ84PcbkK0UM9i3nw33Mn)hWGVfm9wfK4n0)npk6BRcMg9WipEQqGcjTRzpYDJ19TzZ)bSXglhwdMgLhhVH(V5rrFBvW0Ohg5XtfcuiPDn7rUBSUVnB(paEMsBPIW8aJQs8ytajop90Da]] )
    
end