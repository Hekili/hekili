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
            
            defensive = true,

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
            defensive = true,
            
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

            form = "bear_form",
            
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
            
            handler = function ()
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

            defensive = true,
            
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
            
            handler = function ()
                unshift()
            end,
        },
        

        swipe_bear = {
            id = 213771,
            known = 213764,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 134296,

            form = "bear_form",
            
            handler = function ()
            end,
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
    
        package = "Guardian",
    } )


    spec:RegisterPack( "Guardian", 20180729.2321, [[dGuAHaqivk9iPQQAteLpjIugLiKtjc1QKQIxPs1SerDluk0UOQFPImmPQYXiQSmrLEMkunnrextLITHsrFJOkgNuv6CevvRtePAEQG7Hs2NisoOuvvwOkQhsuv0ejQs0fjQk8rIQsJKOkvNuQQIvkQAMsvvANsvwkrvcpvHPksDvIQK8vIQKAVk9xfnyQCyOfJIhdAYs5YiBMqFwQmAr50cRMOkLxlQy2KCBc2TKFRQHRsookLwoWZj10PCDISDrY3vHmEvOCErW6rPG5Js1(r1RCB6D0qJ2E52p56B)KNCLFFUhxU(EJ8VdlHlAhximhSJ2rHc0oKVsiOfyTJlmb1JTn9o0Veas7yecYNCxI6Vux8vI5o2iBK7Ym7sN0pDQlSmjgp8foPdbjfAXxqakAN0Ha8eJ6zoPOU4l2yJsD6c8IHI0Nsheix5oLox5MYlbsrBkFLqqlWYRdb4oyKcL1FQLzhn0OTxU9tU(2p5jx53N7XLRV3i)7aLSShSd5DkNqf7OrA4osNfAUl0ChYDximhSJ4UxK7qOfFXDQqBAUt8bCN8oLtOcppppF6SqZDHM7yKcLXDIGxG7SmI76Vux8f3jFLqqlWI7UaVyOiUte8cC3ieKuOfFjFcqrJ7sKLraI7cn3vp3DwS)XDxGxmue3HPWqHmkI7sGSe73Hk0MEtVJgjIskBtV9KBtVdeAXx7aLSFIMHWC2bviJIA7512E5UP3bcT4RDOZrsPMmOoBhuHmkQTNxB7D8n9oqOfFTdgcbtXhiSdQqgf12ZRT9sYMEhuHmkQTN3bcT4RDarLAIql(AQcTTdvOTzHc0oecl6ql(ATT3nB6DqfYOO2EEhi0IV2bevQjcT4RPk02ouH2Mfkq7a(VQ9hv612ES5MEhuHmkQTN3beegbcChi0Iu0Kksiin3XI7KBhi0IV2bevQjcT4RPk02ouH2Mfkq7qBRT9KNn9oOczuuBpVdiimce4oqOfPOjvKqqAUlP4o52bcT4RDarLAIql(AQcTTdvOTzHc0oWNwBTDCbi4lWG2ME7j3MEhuHmkQTNxB7L7MEhuHmkQTNxB7D8n9oOczuuBpV22ljB6DqfYOO2EEhPqLeTdITsX1f18kjrrCEeaVUIQtVdeAXx7ifccKrr7ifcMfkq7WYaOoB(PiWuaRofT227Mn9oqOfFTdgcbtXhiSdQqgf12ZRT9yZn9oOczuuBpV22tE207aHw81oUEl(AhuHmkQTNxBTDa)x1(Jk9ME7j3MEhi0IV2X1BXx7GkKrrT98ABVC307aHw81oyu)3MIsGe2bviJIA7512EhFtVdeAXx7GHaAcKtuD7GkKrrT98ABVKSP3bcT4RDGaiw00EaGkBhuHmkQTNxB7DZMEhi0IV2Hk6Ym9uEtQ1jqLTdQqgf12ZRT9yZn9oqOfFTdLuHGjdHc7GkKrrT98ABp5ztVdeAXx7ikick0IV2bviJIA7512E9DtVdQqgf12Z7accJabUddvuzEgakWOiTNkKrrnUtg3LiUZqfvMxlbsfPq18fNwgnfdZiT5PczuuJ7s8oqOfFTdgeKJoNOwB7j)B6DGql(AhsAAggjO3bviJIA751wBh4tB6TNCB6DqfYOO2EEhi0IV2HW)LyaODabHrGa3bJKOOVdvi0c4StcbTalV0f3jJ7i2kfxxuZRWwctSAtlJMWSq14ozCh8Fv7pQ8wga1ztgcbEajGrP5UdCxUCxF4UoyJ7KXDmsII(ouHqlGZoje0cS8asaJsZDh4UC5U(WDDWg3jJ7se3HqlsrtQiHG0C3bUljCh7SZDeBLIRlQ5fLajmFXzHMeG4ozChcTifnPIecsZDh4UB4UeVdycqfnne0rME7j3ABVC307GkKrrT98oGGWiqG7a(VQ9hvEldG6SjdHapGeWO0C3bUlxURpCxhSXDY4U2BEldG6SjdHaV2qyoChlUR9M3YaOoBYqiWlGhBQneMJEhi0IV2XLKkfbc2aT2274B6DqfYOO2EEhqqyeiWDWijk6JcIGcT4lV0f3jJ7UL7sHGazuK3YaOoB(PiWuaRofXDY4oeArkAsfjeKM7oWDjzhi0IV2HawDkATTxs207aHw81oSmaQZMmec2bviJIA7512E3SP3bviJIA75DGql(Ahc)xIbG2beegbcChmsII(ouHqlGZoje0cS8sxCNmUJyRuCDrnVcBjmXQnTmAcZcvJ7KXDmsII(ouHqlGZoje0cS8asaJsZDh4UoyJ7KXDjI7qOfPOjvKqqAU7a3LeUJD25oITsX1f18IsGeMV4SqtcqCNmUdHwKIMurcbP5UdC3nCxI3bmbOIMgc6itV9KBTThBUP3bviJIA75DabHrGa3ba7iFJedyyC3bURVCNmUlrC3TCNHkQmFuqeuOfF5PczuuJ7KXDi0Iu0Kksiin3DG7sc3Xo7CNHkQmFuqeuOfF5PczuuJ7KXDi0Iu0Kksiin3DG7ytUlX7aHw81oeqj1ABp5ztVdQqgf12Z7accJabUJB5odvuz(ouHqlGZoje0cS8uHmkQXDY4oeArkAsfjeKM7oWD3WDSZo3zOIkZ3HkeAbC2jHGwGLNkKrrnUtg3HqlsrtQiHG0C3bUlj7aHw81oeWQtrRT967MEhuHmkQTN3bcT4RDi8FjgaAhqqyeiWDCl3zOIkZ3HkeAbC2jHGwGLNkKrrnUtg31EZl8FjgaYdiraPZqgfXDY4UeXD3YDeBLIRlQ5fLajmFXzHMeG4ozChcTifnPIecsZDh4U(YDSZo3rSvkUUOMxucKW8fNfAsaI7KXDi0Iu0Kksiin3DG7KtoUlXCh7SZDmsII(ouHqlGZoje0cS8sxCNmU7wUJyRuCDrnVcBjmXQnTmAcZcvJ7KXDi0Iu0Kksiin3DG7o(oGjav00qqhz6TNCRT9K)n9oOczuuBpVdiimce4oayh5Hsaavg3LuChcT4lFa(suc4HV24U7ChcT4lVakP8WxBCNmUlrC3TCNHkQmFuqeuOfF5PczuuJ7KXDi0Iu0Kksiin3DG7UH7yNDUZqfvMpkick0IV8uHmkQXDY4oeArkAsfjeKM7oWDSj3L4DGql(AhcOKATTNC9BtVdQqgf12Z7aHw81oe(VedaTdiimce4oUL7i2kfxxuZRWwctSAtlJMWSq14ozCx7nVW)LyaipGebKodzue3jJ7qOfPOjvKqqAU7a3D8DataQOPHGoY0Bp5wB7jNCB6DGql(Ah6JIlAYqiyhuHmkQTNxBTDOTn92tUn9oOczuuBpVdiimce4oayh5BKyadJ7oWD9Dhi0IV2HakPwB7L7MEhuHmkQTN3beegbcChmsII(OGiOql(YlDXDY4U2BEH)lXaqEajciDgYOiUJD25UB5U2BEH)lXaqElG5ev3oqOfFTdH)lXaqRT9o(MEhuHmkQTN3beegbcChW)vT)OYBzauNnzie4bKagLM7oWD5YD9H76GnUtg31EZBzauNnzie41gcZH7yXDT38wga1ztgcbEb8ytTHWC07aHw81oUKuPiqWgO12EjztVdQqgf12Z7accJabUJuiiqgf5TmaQZMFkcmfWQtrCh7SZDgQOY8aQAtSAtJqGNkKrrnUtg31EZBzauNnzie41gcZH7oWDT38wga1ztgcbEb8ytTHWC07aHw81oSmaQZMmecwB7DZMEhi0IV2HawDkAhuHmkQTNxB7XMB6DGql(Ahwga1ztgcb7GkKrrT98ABp5ztVdQqgf12Z7accJabUdgjrrFhQqOfWzNecAbwEPlUJD25UeXD3YDgQOY8DOcHwaNDsiOfy5PczuuJ7KXDT38c)xIbG8aseq6mKrrCxI3bcT4RDi8FjgaATTxF307GkKrrT98oGGWiqG7aGDKhkbauzCxsXDi0IV8b4lrjGh(AJ7UZDi0IV8cOKYdFTTdeAXx7qaLuRT9K)n9oOczuuBpVdiimce4oAV5f(Veda5bKiG0ziJI4ozCNHkQmFhQqOfWzNecAbwEQqgf14ozC3TChXwP46IAEf2syIvBAz0eMfQ2oqOfFTdH)lXaqRT9KRFB6DGql(Ah6JIlAYqiyhuHmkQTNxBTDiew0Hw81ME7j3MEhuHmkQTN3beegbcChrbFHO6Mnua7O5nAUlP4U(5Z9gURpCxgHklZlGhJ7KXDmsII(a8LOeWdibmkn3DG76GnURpCxU7aHw81ocWxIsG12E5UP3bviJIA75DabHrGa3rgHklZdLaaQmU7a31pV8Cd31hUlJqLL5fWJTdeAXx7qeqfBiO2eqDura0IVwBT12rkcOJV2E52p56B)KNCLFFUhVF3SJJqqfvNEhYR7FYl61F6jFt6Ch3LoJ4Uq46bg3j(aUlP1iruszjnUdqSvkauJ70VaXDOK9cOrnUdMHvhP98893OiUtUKo3jVQ0sxxpWOg3Hql(I7sAOK9t0meMtsZZZZZ3FeUEGrnUJn5oeAXxCNk0M2ZZVJlWlgkAh9FUt(4yeuYOg3XqIpG4o4lWGg3XqDrP9Cx)dcPltZD1xSXmeiikP4oeAXxAU7lvcEEEeAXxA)fGGVadASevOohEEeAXxA)fGGVadA3zDs8)gppcT4lT)cqWxGbT7SoHsDcuzOfFXZJql(s7Vae8fyq7oRtPqqGmkk5cfiwwga1zZpfbMcy1POKtHkjIfXwP46IAELKOiopcGxxr1P55rOfFP9xac(cmODN1jgcbtXhiWZ3)5UrHx6S34oagnUJrsuKACN2qtZDmK4diUd(cmOXDmuxuAUdRg3Dbi241BwuDCxO5U2xKNNhHw8L2Fbi4lWG2DwN0fEPZEBQn0088i0IV0(labFbg0UZ601BXx88889FUt(4yeuYOg3rPiqcCNfce3zze3Hq7bCxO5omfgkKrrEEEeAXxAwOK9t0meMdppcT4l9DwN05iPutguNXZJql(sFN1jgcbtXhiWZJql(sFN1jiQuteAXxtvOTKluGyjew0Hw8fppcT4l9DwNGOsnrOfFnvH2sUqbIf8Fv7pQ088i0IV03zDcIk1eHw81ufAl5cfiwAl5qKfcTifnPIecsZsoEEeAXx67SobrLAIql(AQcTLCHcel8PKdrwi0Iu0KksiiDsjhppppcT4lThFILW)LyaOKHjav00qqhzAwYLCiYIrsu03HkeAbC2jHGwGLx6sgXwP46IAEf2syIvBAz0eMfQMm4)Q2Fu5TmaQZMmec8asaJsFi3(0bBYyKef9DOcHwaNDsiOfy5bKagL(qU9Pd2KLieArkAsfjeK(qsyNDITsX1f18IsGeMV4SqtcqYqOfPOjvKqq6d3KyEEeAXxAp(0DwNUKuPiqWgOKdrwW)vT)OYBzauNnzie4bKagL(qU9Pd2K1EZBzauNnzie41gcZHv7nVLbqD2KHqGxap2uBimhnppcT4lThF6oRtcy1POKdrwmsII(OGiOql(YlDj72uiiqgf5TmaQZMFkcmfWQtrYqOfPOjvKqq6djHNhHw8L2JpDN1jldG6SjdHaEEeAXxAp(0DwNe(VedaLmmbOIMgc6itZsUKdrwmsII(ouHqlGZoje0cS8sxYi2kfxxuZRWwctSAtlJMWSq1KXijk67qfcTao7KqqlWYdibmk9HoytwIqOfPOjvKqq6djHD2j2kfxxuZlkbsy(IZcnjajdHwKIMurcbPpCtI55rOfFP94t3zDsaLujhISayh5BKyad7qFLLOBnurL5JcIGcT4lpviJIAYqOfPOjvKqq6djHD2nurL5JcIGcT4lpviJIAYqOfPOjvKqq6dSzI55rOfFP94t3zDsaRofLCiY6wdvuz(ouHqlGZoje0cS8uHmkQjdHwKIMurcbPpCd7SBOIkZ3HkeAbC2jHGwGLNkKrrnzi0Iu0Kksii9HKWZJql(s7XNUZ6KW)LyaOKHjav00qqhzAwYLCiY6wdvuz(ouHqlGZoje0cS8uHmkQjR9Mx4)smaKhqIasNHmkswIULyRuCDrnVOeiH5lol0KaKmeArkAsfjeK(qFzNDITsX1f18IsGeMV4SqtcqYqOfPOjvKqq6dYjxIzNDgjrrFhQqOfWzNecAbwEPlz3sSvkUUOMxHTeMy1MwgnHzHQjdHwKIMurcbPpCCEEeAXxAp(0DwNeqjvYHila2rEOeaqLLui0IV8b4lrjGh(A7ocT4lVakP8WxBYs0TgQOY8rbrqHw8LNkKrrnzi0Iu0Kksii9HByNDdvuz(OGiOql(YtfYOOMmeArkAsfjeK(aBMyEEeAXxAp(0DwNe(VedaLmmbOIMgc6itZsUKdrw3sSvkUUOMxHTeMy1MwgnHzHQjR9Mx4)smaKhqIasNHmksgcTifnPIecsF4488i0IV0E8P7SoPpkUOjdHaEEEEeAXxAVqyrhAXxScWxIsGKdrwrbFHO6Mnua7O5n6KQF(CVPpzeQSmVaEmzmsII(a8LOeWdibmk9HoyRp5YZJql(s7fcl6ql(ILiGk2qqTjG6OIaOfFLCiYkJqLL5Hsaav2H(5LNB6tgHklZlGhJNNNhHw8L2d)x1(Jk9DwNUEl(INhHw8L2d)x1(Jk9DwNyu)3MIsGe45rOfFP9W)vT)OsFN1jgcOjqor1XZJql(s7H)RA)rL(oRtiaIfnThaOY45rOfFP9W)vT)OsFN1jv0Lz6P8MuRtGkJNhHw8L2d)x1(Jk9DwNusfcMmekWZJql(s7H)RA)rL(oRtrbrqHw8fppcT4lTh(VQ9hv67SoXGGC05evYHildvuzEgakWOiTNkKrrnzjYqfvMxlbsfPq18fNwgnfdZiT5PczuulX88i0IV0E4)Q2FuPVZ6KKMMHrcAEEEEeAXxAV2yjGsQKdrwaSJ8nsmGHDOV88i0IV0ETDN1jH)lXaqjhISyKef9rbrqHw8Lx6sw7nVW)LyaipGebKodzue7SFB7nVW)LyaiVfWCIQJNhHw8L2RT7SoDjPsrGGnqjhISG)RA)rL3YaOoBYqiWdibmk9HC7thSjR9M3YaOoBYqiWRneMdR2BEldG6SjdHaVaESP2qyoAEEeAXxAV2UZ6KLbqD2KHqqYHiRuiiqgf5TmaQZMFkcmfWQtrSZUHkQmpGQ2eR20ie4Pczuutw7nVLbqD2KHqGxBimNdT38wga1ztgcbEb8ytTHWC088i0IV0ETDN1jbS6ueppcT4lTxB3zDYYaOoBYqiGNhHw8L2RT7Soj8Fjgak5qKfJKOOVdvi0c4StcbTalV0f7SNOBnurL57qfcTao7KqqlWYtfYOOMS2BEH)lXaqEajciDgYOOeZZJql(s712DwNeqjvYHila2rEOeaqLLui0IV8b4lrjGh(A7ocT4lVakP8WxB88i0IV0ETDN1jH)lXaqjhISAV5f(Veda5bKiG0ziJIKzOIkZ3HkeAbC2jHGwGLNkKrrnz3sSvkUUOMxHTeMy1MwgnHzHQXZJql(s712DwN0hfx0KHqWo0xeC7jx)sYARTla]] )
    
end