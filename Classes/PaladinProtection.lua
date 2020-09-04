-- PaladinProtection.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'PALADIN' then
    local spec = Hekili:NewSpecialization( 66 )

    spec:RegisterResource( Enum.PowerType.HolyPower )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        holy_shield = 22428, -- 152261
        redoubt = 22558, -- 280373
        blessed_hammer = 23469, -- 204019

        first_avenger = 22431, -- 203776
        crusaders_judgment = 22604, -- 204023
        moment_of_glory = 23468, -- 327193

        fist_of_justice = 22179, -- 234299
        repentance = 22180, -- 20066
        blinding_light = 21811, -- 115750

        unbreakable_spirit = 22433, -- 114154
        cavalier = 22434, -- 230332
        blessing_of_spellwarding = 22435, -- 204018

        divine_purpose = 17597, -- 223817
        holy_avenger = 17599, -- 105809
        seraphim = 17601, -- 152262

        hand_of_the_protector = 17601, -- 213652
        consecrated_ground = 22438, -- 204054
        judgment_of_light = 22189, -- 183778

        sanctified_wrath = 23457, -- 171648
        righteous_protector = 21202, -- 204074
        final_stand = 22645, -- 204077
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        cleansing_light = 3472, -- 236186
        guarded_by_the_light = 97, -- 216855
        guardian_of_the_forgotten_queen = 94, -- 228049
        hallowed_ground = 90, -- 216868
        inquisition = 844, -- 207028
        judgments_of_the_pure = 93, -- 216860
        luminescence = 3474, -- 199428
        sacred_duty = 92, -- 216853
        shield_of_virtue = 861, -- 215652
        steed_of_glory = 91, -- 199542
        unbound_freedom = 3475, -- 305394
        warrior_of_light = 860, -- 210341
    } )

    -- Auras
    spec:RegisterAuras( {
        ardent_defender = {
            id = 31850,
            duration = 8,
            max_stack = 1,
        },
        avengers_shield = {
            id = 31935,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        avenging_wrath = {
            id = 31884,
            duration = function () return ( talent.sanctified_wrath.enabled and 1.25 or 1 ) * ( azerite.lights_decree.enabled and 25 or 20 ) end,
            max_stack = 1,
        },
        bastion_of_glory = {
            id = 182104,
            duration = 15,
            max_stack = 5,
        },
        blessed_hammer = {
            id = 204301,
            duration = 10,
            max_stack = 1,
        },
        blessing_of_freedom = {
            id = 1044,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        blessing_of_protection = {
            id = 1022,
            duration = 10,
            max_stack = 1,
            type = "Magic",
        },
        blessing_of_sacrifice = {
            id = 6940,
            duration = 12,
            max_stack = 1,
            type = "Magic",
        },
        blessing_of_spellwarding = {
            id = 204018,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        blinding_light = {
            id = 105421,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        concentration_aura = {
            id = 317920,
            duration = 3600,
            max_stack = 1,
        },
        consecration = {
            id = 188370,
            duration = 12,
            max_stack = 1,
            generate = function( c, type )
                if type == "buff" and FindUnitBuffByID( "player", 188370 ) then
                    local dropped, expires
                    
                    for i = 1, 5 do
                        local up, name, start, duration = GetTotemInfo( i )

                        if up and name == class.abilities.consecration.name then
                            dropped = start
                            expires = dropped + duration
                            break
                        end
                    end

                    if dropped and expires > query_time then
                        c.expires = expires
                        c.applied = dropped
                    c.count = 1
                    c.caster = "player"
                    return
                end
                end

                c.count = 0
                c.expires = 0
                c.applied = 0
                c.caster = "unknown"
            end
        },
        consecration_dot = {
            id = 204242,
            duration = 12,
            max_stack = 1,
        },
        devotion_aura = {
            id = 465,
            duration = 3600,
            max_stack = 1,
        },
        divine_purpose = {
            id = 223819,
            duration = 12,
            max_stack = 1,
        },
        divine_shield = {
            id = 642,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        divine_steed = {
            id = 221886,
            duration = 3,
            max_stack = 1,
        },
        final_stand = {
            id = 204079,
            duration = 8,
            max_stack = 1,
        },
        first_avenger = {
            id = 327225,
            duration = 8,
            max_stack = 1,
        },
        forbearance = {
            id = 25771,
            duration = 30,
            max_stack = 1,
        },
        grand_crusader = {
            id = 85043,
        },
        guardian_of_ancient_kings = {
            id = 86659,
            duration = 8,
            max_stack = 1,
        },
        hammer_of_justice = {
            id = 853,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        hand_of_reckoning = {
            id = 62124,
            duration = 3,
            max_stack = 1,
        },
        holy_avenger = {
            id = 105809,
            duration = 20,
            max_stack = 1,
        },
        judgment = {
            id = 197277,
            duration = 15,
            max_stack = 1,
        },
        judgment_of_light = {
            id = 196941,
            duration = 30,
            max_stack = 25,
        },
        moment_of_glory = {
            id = 327193,
            duration = 15,
            max_stack = 3,
        },
        redoubt = {
            id = 280375,
            duration = 10,
            max_stack = 3,
        },
        repentance = {
            id = 20066,
            duration = 6,
            max_stack = 1,
        },
        retribution_aura = {
            id = 183435,
            duration = 3600,
            max_stack = 1,
        },
        seraphim = {
            id = 152262,
            duration = 16,
            max_stack = 1,
        },
        shield_of_the_righteous = {
            id = 132403,
            duration = 4.5,
            max_stack = 1,
        },
        turn_evil = {
            id = 10326,
            duration = 40,
            max_stack = 1
        },


        -- Azerite Powers
        empyreal_ward = {
            id = 287731,
            duration = 60,
            max_stack = 1,
        },

    } )


    -- Gear Sets
    spec:RegisterGear( 'tier19', 138350, 138353, 138356, 138359, 138362, 138369 )
    spec:RegisterGear( 'tier20', 147160, 147162, 147158, 147157, 147159, 147161 )
        spec:RegisterAura( 'sacred_judgment', {
            id = 246973,
            duration = 8,
            max_stack = 1,
        } )        

    spec:RegisterGear( 'tier21', 152151, 152153, 152149, 152148, 152150, 152152 )
    spec:RegisterGear( 'class', 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )

    spec:RegisterGear( "breastplate_of_the_golden_valkyr", 137017 )
    spec:RegisterGear( "heathcliffs_immortality", 137047 )
    spec:RegisterGear( 'justice_gaze', 137065 )
    spec:RegisterGear( "saruans_resolve", 144275 )
    spec:RegisterGear( "tyelca_ferren_marcuss_stature", 137070 )
    spec:RegisterGear( "tyrs_hand_of_faith", 137059 )
    spec:RegisterGear( "uthers_guard", 137105 )

    spec:RegisterGear( "soul_of_the_highlord", 151644 )
    spec:RegisterGear( "pillars_of_inmost_light", 151812 )    


    spec:RegisterStateExpr( "last_consecration", function () return action.consecration.lastCast end )
    spec:RegisterStateExpr( "last_blessed_hammer", function () return action.blessed_hammer.lastCast end )
    spec:RegisterStateExpr( "last_shield", function () return action.shield_of_the_righteous.lastCast end )

    spec:RegisterStateExpr( "consecration", function () return buff.consecration end )

    spec:RegisterHook( "reset_precast", function ()
        last_consecration = nil
        last_blessed_hammer = nil
        last_shield = nil
    end )


    -- Abilities
    spec:RegisterAbilities( {
        ardent_defender = {
            id = 31850,
            cast = 0,
            cooldown = function ()
                return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 120 end,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 135870,

            handler = function ()
                applyBuff( "ardent_defender" )
            end,
        },


        avengers_shield = {
            id = 31935,
            cast = 0,
            cooldown = function () return buff.moment_of_glory.up and 0 or 15 end,
            gcd = "spell",

            interrupt = true,

            startsCombat = true,
            texture = 135874,

            handler = function ()
                applyDebuff( "target", "avengers_shield" )
                interrupt()

                removeStack( "moment_of_glory", nil, 1 )

                if talent.first_avenger.enabled then
                    applyBuff( "first_avenger" )
                end

                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            end,
        },


        avenging_wrath = {
            id = 31884,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135875,

            handler = function ()
                applyBuff( "avenging_wrath" )
            end,
        },


        blessed_hammer = {
            id = 204019,
            cast = 0,
            charges = 3,
            cooldown = 6,
            recharge = 6,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 535595,

            talent = "blessed_hammer",

            handler = function ()
                applyDebuff( "target", "blessed_hammer" )
                last_blessed_hammer = query_time

                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            end,
        },


        blessing_of_freedom = {
            id = 1044,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            spend = 0.07,
            spendType = "mana",

            startsCombat = false,
            texture = 135968,

            handler = function ()
                applyBuff( "blessing_of_freedom" )
            end,
        },


        blessing_of_protection = {
            id = 1022,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 135964,

            notalent = "blessing_of_spellwarding",
            nodebuff = "forbearance",

            handler = function ()
                applyBuff( "blessing_of_protection" )
                applyDebuff( "player", "forbearance" )
            end,
        },


        blessing_of_sacrifice = {
            id = 6940,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            spend = 0.07,
            spendType = "mana",

            defensives = true,

            startsCombat = false,
            texture = 135966,

            handler = function ()
                applyBuff( "blessing_of_sacrifice" )
            end,
        },


        blessing_of_spellwarding = {
            id = 204018,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            defensives = true,

            startsCombat = false,
            texture = 135880,

            talent = "blessing_of_spellwarding",
            nodebuff = "forbearance",

            handler = function ()
                applyBuff( "blessing_of_spellwarding" )
                applyDebuff( "player", "forbearance" )
            end,
        },


        blinding_light = {
            id = 115750,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "interrupts",

            spend = 0.06,
            spendType = "mana",

            interrupt = true,

            startsCombat = true,
            texture = 571553,

            talent = "blinding_light",

            usable = function () return target.casting end,
            readyTime = function () return debuff.casting.up and ( debuff.casting.remains - 0.5 ) or 3600 end,
            handler = function ()
                interrupt()
                applyDebuff( "target", "blinding_light" )
                active_dot.blinding_light = max( active_enemies, active_dot.blinding_light )
            end,
        },


        cleanse_toxins = {
            id = 213644,
            cast = 0,
            charges = 1,
            cooldown = 8,
            recharge = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 135953,

            usable = function ()
                return buff.dispellable_poison.up or buff.dispellable_disease.up, "requires poison or disease"
            end,

            handler = function ()
                removeBuff( "dispellable_poison" )
                removeBuff( "dispellable_disease" )
            end,
        },


        consecration = {
            id = 26573,
            cast = 0,
            cooldown = 9,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 135926,

            handler = function ()
                applyBuff( "consecration" )
                applyDebuff( "target", "consecration_dot" )
                last_consecration = query_time
            end,
        },


        crusader_aura = {
            id = 32223,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135890,
            
            handler = function ()
                removeBuff( "concentration_aura" )
                removeBuff( "devotion_aura" )
                removeBuff( "retribution_aura" )
                applyBuff( "crusader_aura" )
            end,
        },
        

        devotion_aura = {
            id = 465,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135893,
            
            handler = function ()
                removeBuff( "concentration_aura" )
                removeBuff( "crusader_aura" )
                removeBuff( "retribution_aura" )
                applyBuff( "devotion_aura" )
            end,
        },


        divine_shield = {
            id = 642,
            cast = 0,
            cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 300 end,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 524354,

            nodebuff = "forbearance",

            handler = function ()
                applyBuff( "divine_shield" )
                applyDebuff( "player", "forbearance" )

                if talent.final_stand.enabled then
                    applyDebuff( "target", "final_stand" )
                    active_dot.final_stand = min( active_dot.final_stand, active_enemies )
                end
            end,
        },


        divine_steed = {
            id = 190784,
            cast = 0,
            charges = function () return talent.cavalier.enabled and 2 or nil end,
            cooldown = 45,
            recharge = function () return talent.cavalier.enabled and 45 or nil end,
            gcd = "spell",

            startsCombat = false,
            texture = 1360759,

            handler = function ()
                applyBuff( "divine_steed" )
            end,
        },


        flash_of_light = {
            id = 19750,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.22,
            spendType = "mana",

            startsCombat = false,
            texture = 135907,

            handler = function ()
                gain( 1.67 * 1.68 * ( 1 + stat.versatility_atk_mod ) * stat.spell_power, "health" )
            end,
        },


        guardian_of_ancient_kings = {
            id = 86659,
            cast = 0,
            cooldown = 300,
            gcd = "off",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 135919,

            handler = function ()
                applyBuff( "guardian_of_ancient_kings" )
            end,
        },


        hammer_of_justice = {
            id = 853,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 135963,

            handler = function ()
                applyDebuff( "target", "hammer_of_justice" )
            end,
        },


        hammer_of_the_righteous = {
            id = 53595,
            cast = 0,
            charges = 2,
            cooldown = 6,
            recharge = 6,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 236253,

            notalent = "blessed_hammer",

            handler = function ()
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            end,
        },


        

        hammer_of_wrath = {
            id = 24275,
            cast = 0,
            cooldown = 7.5,
            gcd = "spell",
            
            startsCombat = true,
            texture = 613533,
            
            usable = function () return target.health_pct < 20 or ( level > 57 and buff.avenging_wrath.up ) or buff.hammer_of_wrath_hallow.up, "requires low health, avenging_wrath, or ashen_hallow" end,
            handler = function ()
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            end,
        },


        hand_of_reckoning = {
            id = 62124,
            cast = 0,
            charges = 1,
            cooldown = 8,
            recharge = 8,
            gcd = "off",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135984,

            handler = function ()
                applyDebuff( "target", "hand_of_reckoning" )
            end,
        },


        holy_avenger = {
            id = 105809,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 571555,

            talent = "holy_avenger",
            
            handler = function ()
                applyBuff( "holy_avenger" )
            end,
        },


        judgment = {
            id = 275779,
            cast = 0,
            charges = function ()
                local c = 1
                if talent.crusaders_judgment.enabled then c = c + 1 end
                if buff.grand_crusader.up then c = c + 1 end
                return c > 1 and c or nil
            end,
            cooldown = 6,
            recharge = 6,
            hasteCD = true,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135959,

            handler = function ()
                applyDebuff( "target", "judgment" )
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )

                if talent.judgment_of_light.enabled then applyDebuff( "target", "judgment_of_light", nil, 25 ) end

                if talent.fist_of_justice.enabled then
                    cooldown.hammer_of_justice.expires = max( 0, cooldown.hammer_of_justice.expires - 6 ) 
                end
            end,
        },


        lay_on_hands = {
            id = 633,
            cast = 0,
            cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 600 end,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 135928,

            nodebuff = "forbearance",

            handler = function ()
                gain( health.max, "health" )
                applyDebuff( "player", "forbearance" )
                if azerite.empyreal_ward.enabled then applyBuff( "empyrael_ward" ) end
            end,
        },


        moment_of_glory = {
            id = 327193,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 589117,

            talent = "moment_of_glory",
            
            handler = function ()
                setCooldown( "avengers_shield", 0 )
                applyBuff( "moment_of_glory", nil, 3 )
            end,
        },


        rebuke = {
            id = 96231,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            startsCombat = true,
            texture = 523893,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        --[[ redemption = {
            id = 7328,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 135955,

            handler = function ()
            end,
        }, ]]


        repentance = {
            id = 20066,
            cast = 1.7,
            cooldown = 15,
            gcd = "spell",

            interrupt = true,

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 135942,

            handler = function ()
                applyDebuff( "target", "repentance" )
            end,
        },
        

        retribution_aura = {
            id = 183435,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = false,
            texture = 135889,
            
            handler = function ()
                removeBuff( "concentration_aura" )
                removeBuff( "crusader_aura" )
                removeBuff( "devotion_aura" )
                applyBuff( "retribution_aura" )
            end,
        },

        seraphim = {
            id = 152262,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3
            end,
            spendType = "holy_power",

            startsCombat = false,
            texture = 1030103,

            talent = "seraphim",

            handler = function ()
                removeBuff( "divine_purpose" )                
                local used = min( 2, cooldown.shield_of_the_righteous.charges )
                applyBuff( "seraphim", used * 8 )
            end,
        },


        shield_of_the_righteous = {
            id = 53600,
            cast = 0,
            cooldown = 1,
            icd = 1,
            gcd = "off",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3
            end,
            spendType = "holy_power",

            defensives = true,

            startsCombat = true,
            texture = 236265,

            handler = function ()
                if talent.redoubt.enabled then addStack( "redoubt", nil, 3 ) end

                removeBuff( "divine_purpose" )                

                addStack( "bastion_of_glory", nil, 1 )

                applyBuff( "shield_of_the_righteous", buff.shield_of_the_righteous.remains + 4.5 )

                if talent.righteous_protector.enabled then
                    cooldown.light_of_the_protector.expires = max( 0, cooldown.light_of_the_protector.expires - 3 )
                    cooldown.hand_of_the_protector.expires = max( 0, cooldown.hand_of_the_protector.expires - 3 )
                    cooldown.avenging_wrath.expires = max( 0, cooldown.avenging_wrath.expires - 3 )
                end

                last_shield = query_time
            end,
        },


        turn_evil = {
            id = 10326,
            cast = 1.5,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            startsCombat = true,
            texture = 571559,
            
            handler = function ()
                applyDebuff( "turn_evil" )
            end,
        },


        word_of_glory = {
            id = 85673,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3
            end,
            spendType = "holy_power",
            
            startsCombat = false,
            texture = 133192,
            
            handler = function ()
                removeBuff( "bastion_of_glory" )
                removeBuff( "divine_purpose" )                

                gain( 2.9 * stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )

                if buff.vanquishers_hammer.up then
                    applyBuff( "shield_of_the_righteous" )
                    removeBuff( "vanquishers_hammer" )
                end 
            end,
        },


        -- Paladin - Kyrian    - 304971 - divine_toll          (Divine Toll)
        divine_toll = {
            id = 304971,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 3565448,

            toggle = "essences",

            handler = function ()
                if spec.protection then
                    -- Cast Avenger's Shield x5.
                    -- This is lazy and may be wrong/bad.
                    for i = 1, active_enemies do
                        class.abilities.avengers_shield.handler()
                    end
                elseif spec.retribution then
                    -- Cast Judgment x5.
                    for i = 1, active_enemies do
                        class.abilities.judgment.handler()
                    end
                elseif spec.holy then
                    -- Cast Holy Shock x5.
                    for i = 1, active_enemies do
                        class.abilities.holy_shock.handler()
                    end
                end
            end
        },

        -- Paladin - Necrolord - 328204 - vanquishers_hammer   (Vanquisher's Hammer)
        vanquishers_hammer = {
            id = 328204,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 1
            end,
            spendType = "holy_power",

            startsCombat = true,
            texture = 3578228,

            toggle = "essences",

            handler = function ()
                removeBuff( "divine_purpose" )                
                applyBuff( "vanquishers_hammer" )
            end,

            auras = {
                vanquishers_hammer = {
                    id = 328204,
                    duration = 15,
                    max_stack = 1
                }
            }
        },

        -- Paladin - Night Fae - 328620 - blessing_of_summer   (Blessing of Summer)
        blessing_of_summer = {
            id = 328620,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = false,
            texture = 3636845,

            toggle = "essences",
            buff = "blessing_of_summer_active",

            handler = function ()
                applyBuff( "blessing_of_summer" ) -- We'll just apply to self because we don't care.
                
                removeBuff( "blessing_of_summer_active" )
                applyBuff( "blessing_of_autumn_active" )
                setCooldown( "blessing_of_autumn", 45 )
            end,

            auras = {
                blessing_of_summer = {
                    id = 328620,
                    duration = 30,
                    max_stack = 1,
                },

                blessing_of_summer_active = {
                    duration = 3600,
                    max_stack = 1,
                    generate = function( t )
                        if IsActiveSpell( 328620 ) then
                            t.name = class.auras.blessing_of_summer.name .. " Active"
                            t.count = 1
                            t.applied = now
                            t.expires = now + 3600
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.applied = 0
                        t.expires = 0
                        t.caster = "nobody"
                    end,
                },
            }
        },

        blessing_of_autumn = {
            id = 328622,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = false,
            texture = 3636843,

            toggle = "essences",
            buff = "blessing_of_autumn_active",

            handler = function ()
                applyBuff( "blessing_of_autumn" )

                removeBuff( "blessing_of_autumn_active" )
                applyBuff( "blessing_of_winter_active" )
                setCooldown( "blessing_of_winter", 45 )
            end,

            auras = {
                blessing_of_autumn = {
                    id = 328622,
                    duration = 30,
                    max_stack = 1,                    
                },
                blessing_of_autumn_active = {
                    duration = 3600,
                    max_stack = 1,
                    generate = function( t )
                        if IsActiveSpell( 328622 ) then
                            t.name = class.auras.blessing_of_autumn.name .. " Active"
                            t.count = 1
                            t.applied = now
                            t.expires = now + 3600
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.applied = 0
                        t.expires = 0
                        t.caster = "nobody"
                    end,
                }
            }
        },

        blessing_of_winter = {
            id = 328281,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = false,
            texture = 3636846,

            toggle = "essences",
            buff = "blessing_of_winter_active",

            handler = function ()
                applyBuff( "blessing_of_winter" )

                removeBuff( "blessing_of_winter_active" )
                applyBuff( "blessing_of_spring_active" )
                setCooldown( "blessing_of_spring", 45 )
            end,

            auras = {
                blessing_of_winter = {
                    id = 328281,
                    duration = 30,
                    max_stack = 1,                    
                },
                blessing_of_winter_debuff = {
                    id = 328506,
                    duration = 6,
                    max_stack = 10
                },
                blessing_of_winter_active = {
                    duration = 3600,
                    max_stack = 1,
                    generate = function( t )
                        if IsActiveSpell( 328281 ) then
                            t.name = class.auras.blessing_of_winter.name .. " Active"
                            t.count = 1
                            t.applied = now
                            t.expires = now + 3600
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.applied = 0
                        t.expires = 0
                        t.caster = "nobody"
                    end,
                }
            }
        },

        blessing_of_spring = {
            id = 328282,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = false,
            texture = 3636844,

            toggle = "essences",
            buff = "blessing_of_spring_active",

            handler = function ()
                applyBuff( "blessing_of_spring" )

                removeBuff( "blessing_of_spring_active" )
                applyBuff( "blessing_of_summer_active" )
                setCooldown( "blessing_of_summer", 45 )
            end,

            auras = {
                blessing_of_spring = {
                    id = 328281,
                    duration = 30,
                    max_stack = 1,
                    friendly = true,
                },
                blessing_of_spring_active = {
                    duration = 3600,
                    max_stack = 1,
                    generate = function( t )
                        if IsActiveSpell( 328282 ) then
                            t.name = class.auras.blessing_of_winter.name .. " Active"
                            t.count = 1
                            t.applied = now
                            t.expires = now + 3600
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.applied = 0
                        t.expires = 0
                        t.caster = "nobody"
                    end,
                }
            }
        },

        -- Paladin - Venthyr   - 316958 - ashen_hallow         (Ashen Hallow)
        ashen_hallow = {
            id = 316958,
            cast = function () return 1.5 * haste end,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 3565722,

            toggle = "essences",

            auras = {
                hammer_of_wrath_hallow = {
                    duration = 30,
                    max_stack = 1,
                    generate = function( t )
                        if IsUsableSpell( 24275 ) and not ( target.health_pct < 20 or ( level > 57 and ( buff.avenging_wrath.up or buff.crusade.up ) ) and not buff.final_verdict.up ) then
                            t.name = class.abilities.hammer_of_wrath.name .. " " .. class.abilities.ashen_hallow.name
                            t.count = 1
                            t.applied = action.ashen_hallow.lastCast
                            t.expires = action.ashen_hallow.lastCast + 30
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.applied = 0
                        t.expires = 0
                        t.caster = "nobody"
                    end,
                },        
            }
        },


    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_unbridled_fury",

        package = "Protection Paladin",
    } )


    spec:RegisterPack( "Protection Paladin", 20200904.1, [[diKrSaqiHKhjePnbsgLqQtjuzvQOYRqOMfjQBbjH2fr)cKAycLJrISmveptfKPPIY1urABqs6Bcr14eIsNtfuwNkOsZtOQ7bP2hKuhescwic5HcrHlQcQYjvbvSsvODcjgkKeTuvqv9uvzQGO9c8xQAWICyklgIhtLjl4YO2SO(mIgTQ60sTAqWRbHMnPUTkTBj)wPHtshxikA5q9CKMUIRdQTle(ojmEvu15vbwVqeZhb7NWaLaqcEbByakNe7KyXoSyNjv6SyXonYbV5avg8unhensg8k7YGhQeVd7MElrcvAAl0f4PAhOxlaGe8Olm2XG3Fgv6Hl0qt2Zhgr62l00(cRTP3YHT8anTVoObpe4wphofab8c2Wauoj2jXIDyXotQ0zXID6PGNbp)fdEV(gzaE)oe4cGaEbM6aVivKqL4Dy30BjsOstBHUehJur6pJk9WfAOj75dJiD7fAAFH120B5WwEGM2xh0IJrQiHkOIBTiPumLfPtIDsmXrXXivKIm(wrYuXXivKqffjuHqGdI0HpJadrwcE6MouaKG3TNM0MElaKauucaj4XLHO5aGiWZH7HXTbEiW5SK(Bwh8B2pF2JBY)WlmvgwfLibLi9x9bE1vbJLbo3UEej0IumWZCtVf4r)nRd(n7Np7Xn5F4fMcgakNaGe84Yq0Caqe45W9W42ape4CwIy0P3YVzpPEXhiHvfjOeje4CwIy0P3YVzpPEXhiX816IksXlsKUGiDor6eWZCtVf4PyXb)M9K6fFayaOCiaKGhxgIMdaIaphUhg3g4fTi9ztpFPQBeP4fPZIjsXbEMB6Tapflo43SNuV4dadaLZaqcECziAoaic8C4EyCBGx0IuxU92fPpyxJK9kflwSyxQifVi9ztpF51oViDorsj5jNksXjsqjsF20ZxQ6grkEr60tfjOePX0CnsCt(hEHPEv8oSBwSKldrZbWZCtVf4PyXb)M9K6fFayaOCkasWJldrZbarGNd3dJBd8IwK6YT3Ui9b7AKSxPdflwSlvKIxK(SPNV8ANxKoNiPKevfP4ejOePpB65lvDJifViD6PGN5MElWtXId(n7j1l(aWaqbvbqcECziAoaic8C4EyCBGx0IuxU92fPpyxJK9OASyXUurkEr6ZME(YRDEr6CIumzKlsXjsqjsF20ZxQ6grkErcvpvKGsKgtZ1iXn5F4fM6vX7WUzXsUmenhapZn9wGNIfh8B2tQx8bGbGsKdGe84Yq0Caqe45W9W42aVOfPUC7TlsFWUgj7pSyXIDPIu8I0Nn98Lx78I05ejLKNisXjsqjsF20ZxQ6grkEr60tbpZn9wGNIfh8B2tQx8bGbGsKfaj4XLHO5aGiWZH7HXTbEiW5SK(Bwh8B2pF2JBY)WlmvgwfLibLi9x9bE1vbJfjulsNaEMB6Tap6VzDWVz)8zpUj)dVWuWaq5WaqcECziAoaic8C4EyCBGxuI0yAUgjLXM6VVsUmenhejOePUC7TlsFWUgj7p50yXUurc1I0Nn98Lx78I05ePyYZejOePOePOfje4CwA4axJpWzUcmwcRkseiisiW5SKe2WH2k)M9w5AUgpe7IKkHvfjceeje4Cwg6i6I90FZ6GewvKiqqKqGZzP6o9wsyvrkoWZCtVf4rcB4qBLFZERCnxJhIDrsbdafLIbGe84Yq0Caqe45W9W42aVOePX0CnskJn1FFLCziAoisqjsJP5AK5UmTNowfKCziAoisqjsD52BxK(GDns2FYPXIDPIeQfPpB65lV25fPZjsXKNjsqjsrjsrlsiW5S0WbUgFGZCfySewvKiqqKqGZzjjSHdTv(n7TY1CnEi2fjvcRkseiisiW5Sm0r0f7P)M1bjSQirGGiHaNZs1D6TKWQIuCGN5MElWl0r0f7P)M1bWaqrjLaqcECziAoaic8C4EyCBGxuI0yAUgjLXM6VVsUmenhejOePUC7TlsFWUgj7p50yXUurc1I0Nn98Lx78I05ePyYZejOePOePOfje4CwA4axJpWzUcmwcRkseiisiW5SKe2WH2k)M9w5AUgpe7IKkHvfjceeje4Cwg6i6I90FZ6GewvKiqqKqGZzP6o9wsyvrkoWZCtVf4z4axJpWzUcmgmauu6eaKGhxgIMdaIaphUhg3g4fLinMMRrszSP(7RKldrZbrckr6ZME(sv3isXlskDk4zUP3c802b(T8FRcuWagWZTRoSkkkasakkbGe84Yq0Caqe45W9W42ape4CwArWfzxKEfyB(syvWZCtVf4LBmJO3nagakNaGe84Yq0Caqe4zUP3c8SiH(nSr95Tg)M9QRcgdEoCpmUnWZTRoSkkjLXM6VVsmFTUOIu8OfjLIjseiisrjsJP5AKugBQ)(k5Yq0Ca8k7YGNfj0VHnQpV143SxDvWyWaq5qaibpUmenhaebEMB6TapJ(JWkM6XwKSyVBXMg8C4EyCBGx0IuGrGZzj2IKf7Dl20(aJaNZs6yoiksOwKICrckrcboNLweCr2fPxb2MVewvKItKiqqKcmcColXwKSyVBXM2hye4CwshZbrrcTifd8k7YGNr)ryft9ylswS3TytdgakNbGe84Yq0Caqe45W9W42ap3U6WQOK0FZ6GFZ(5ZECt(hEHPs33WKm1NXMB6TmTiHA0I0jGN5MElWJYyt93xWaq5uaKGN5MElWZOFU8FtRxfGhxgIMdaIadafufaj4XLHO5aGiWZH7HXTbEiW5SKYyt93xjSQirGGi52vhwfLKYyt93xjMVwxurkEr6erIabrkkrAmnxJKYyt93xjxgIMdGN5MElWZIGlYUi9kW28bdaLihaj4XLHO5aGiWZH7HXTbEiW5S0IGlYUi9kW28LWQGN5MElWtDNElWaqjYcGe8m30BbEiAMs7I0Vzpf(Ezm4XLHO5aGiWaq5WaqcEMB6TapentPDr63S3Gh4BbECziAoaicmauukgasWZCtVf4HOzkTls)M9k6Aym4XLHO5aGiWaqrjLaqcEMB6TapentPDr63SNQI7Ie84Yq0CaqeyaOO0jaibpUmenhaebEoCpmUnW7V6d8QRcgldCUD9isOwKIbEMB6TaViSkYeUPFgt9F7EzmyaOO0HaqcECziAoaic8C4EyCBG3F1h4vxfmwg4C76rKqTiDiWZCtVf4f6i6I9ZQ1GbGIsNbGe84Yq0Caqe45W9W42ap3U6WQOKweCrYyQN(BwhKy(ADrbpZn9wG3DVCn(n7j1l(aWaqrPtbqcECziAoaic8C4EyCBGhcColPm2u)9vcRkseiisrjsJP5AKugBQ)(k5Yq0Ca8m30BbEWu23dFPGbGIsOkasWJldrZbarGN5MElWJeVfj1RI7RP9yJKbphUhg3g4fTifTi52vhwfLecWbYlxJmdR1Em7(gMK9tFzrc1I0zIebcIu0IuuI0yAUgPddtTaJPEiahiVCnsUmenhejOejvmhHN0fKkjHaCG8Y1isXjsXjsqjsUD1HvrjTi4IKXup93SoiX816IksOwKotKGsKqGZzjLXM6VVsmFTUOIeQfPZeP4ejceePOfje4CwszSP(7ReZxRlQifViDMifh4v2Lbps8wKuVkUVM2JnsgmauukYbqcECziAoaic8m30BbExgZqC(g1NTIe8C4EyCBGxuIecColTi4ISlsVcSnFjSQibLifTiHaNZskJn1FFLWQIebcIuuI0yAUgjLXM6VVsUmenheP4aVYUm4DzmdX5BuF2ksWaqrPilasWJldrZbarGxzxg8WwKeGlis9inPhZbpc8mBbEMB6TapSfjb4cIupst6XCWJapZwGbmGxGZgSEaqcqrjaKGN5MElWdZiWqKbpUmenhaebgakNaGe84Yq0Caqe4zUP3c8CMw7n30B51nDapDthFzxg8C7QdRIIcgakhcaj4XLHO5aGiWZCtVf45mT2BUP3YRB6aE6Mo(YUm4D7PjTP3cmauodaj4XLHO5aGiWZH7HXTbEiW5Su3zgrVBqshZbrrkEr6qGN5MElWtXI1Hi4U8yMULvogmauofaj4XLHO5aGiWZH7HXTbE)vFGxDvWyzGZTRhrcTiftKGsKIwKIwKqGZzPfbxKDr6vGT5lHvfjOePOePX0CnskJn1FFLCziAoisXjseiisiW5SKYyt93xjSQifh4zUP3c8O)M1b)M9ZN94M8p8ctbdafufaj4XLHO5aGiWZH7HXTbErlsiW5S0IGlYUi9kW28LWQIeuIecColTi4ISlsVcSnFjMVwxurkEr6mrckrkkrAmnxJKYyt93xjxgIMdIuCIebcIu0IecColPm2u)9vI5R1fvKIxKotKGsKqGZzjLXM6VVsyvrkoWZCtVf4r)nRd(n7Np7Xn5F4fMcgakroasWJldrZbarGNd3dJBd8(R(aV6QGXYaNBxpIeQfPyGN5MElW7B3lJ9B2RaBZhmauISaibpUmenhaebEoCpmUnWdboNLugBQ)(kHvfjOeje4CwszSP(7ReZxRlQifViDiWZCtVf4PBY)q9qaoqE5AadaLddaj4XLHO5aGiWZH7HXTbErjsUTOSdBtVLewf8m30BbEUTOSdBtVfyaOOumaKGhxgIMdaIaphUhg3g4fTi52vhwfLecWbYlxJeZxRlQifVir6cIeuIKBxDyvusiahiVCns33WKm1NXMB6TmTiHArsjrckrYTRoSkkpMn3isXjseiisrjsJP5AKomm1cmM6HaCG8Y1i5Yq0Ca8m30BbEqaoqE5AadafLucaj4XLHO5aGiWZH7HXTbEUD1Hvr5XS5gWZCtVf4zrWfjJPE6VzDamauu6eaKGhxgIMdaIaphUhg3g452vhwfLhZMBejceePOePX0CnshgMAbgt9qaoqE5AKCziAoaEMB6TapiahiVCnGbGIshcaj4XLHO5aGiWZH7HXTbErlsrjsJP5AKugBQ)(k5Yq0CqKiqqKqGZzjLXM6VVsyvrkorckrkkrkSJ0TLJRbBdh8zTDzpcmUKy(ADrfjulsXejceejMs5YXY5ZEhg21iA2VzFwBxwITcIIu8I0HapZn9wGNBlhxd2go4ZA7YGbGIsNbGe84Yq0Caqe45W9W42aVOePX0CnskJn1FFLCziAoiseiisiW5SKYyt93xjSk4zUP3c80n5FOEiahiVCnGbGIsNcGe8m30BbEw1xZVzFGT5dECziAoaicmauucvbqcECziAoaic8m30BbEiAMs5G)B3lJbp6GBiYuW7qGbGIsroasWZCtVf49T7LX(n7Np7Xn5F4fMcECziAoaicmauukYcGe8m30BbEUTOSdBtVf4XLHO5aGiWaqrPddaj4XLHO5aGiWZH7HXTbErjsrlsmLYLJLZN9omSRr0SFZ(S2US8AqyXIebcIetPC5yPIfRdrWD5XmDlRCS8AqyXIebcIetPC5yPv918B2R7m7Tk4dSnF51GWIfjceejMs5YXYlFx8b(n71WUo4dy2Uu51GWIfP4apZn9wG3Nn84zkLlhdgWaEQy2TxeBaqcqrjaKGhxgIMdaIadaLtaqcECziAoaicmauoeasWJldrZbarGbGYzaibpUmenhaebgakNcGe8m30BbEQ70BbECziAoaicmauqvaKGN5MElWt3K)H6HaCG8Y1aECziAoaicmGbmGxemM2Bbq5KyNel2Hf7mWtHHRUiPG3HZvDXdhePZejZn9wIKUPdvkocEQ4n3Ag8IurcvI3HDtVLiHknTf6sCmsfPhRo8fHXI0zklsNe7KyIJIJrQifz8TIKPIJrQiHkksOcHahePdFgbgISuCuCmsfPdVZZo4HdIecNxmlsU9IyJiHWKDrLIeQGZXQdvKQTqf)g(MH1IK5MElQiTL(aP4O5MElQufZU9Iyd6S2OquC0CtVfvQIz3ErSHy0qN3nioAUP3IkvXSBVi2qmAOnyYlxJn9wIJrQi9ktL(3rKWwheje4CMdIeDSHksiCEXSi52lInIect2fvKSkisQygvuDNPlsrQPIuylwkoAUP3IkvXSBVi2qmAOPLPs)74PJnuXrZn9wuPkMD7fXgIrdT6o9wIJMB6TOsvm72lIneJgADt(hQhcWbYlxJ4O4yKkshENNDWdhejocgFGin9LfP5ZIK5MflsnvKSiSwBiAwkoAUP3IIgZiWqKfhn30Brjgn0otR9MB6T86Mokx2Lr72vhwffvC0CtVfLy0q7mT2BUP3YRB6OCzxg9TNM0MElXrZn9wuIrdTIfRdrWD5XmDlRCSYDgncCol1DMr07gK0XCqm(djoAUP3IsmAOP)M1b)M9ZN94M8p8ctvUZO)R(aV6QGXYaNBxpOJbv0rJaNZslcUi7I0RaBZxcRcvuJP5AKugBQ)(k5Yq0CioceqGZzjLXM6VVsy14ehn30Brjgn00FZ6GFZ(5ZECt(hEHPk3z0rJaNZslcUi7I0RaBZxcRcfcColTi4ISlsVcSnFjMVwx04pdQOgtZ1iPm2u)9vYLHO5qCeiencColPm2u)9vI5R1fn(ZGcboNLugBQ)(kHvJtC0CtVfLy0q)T7LX(n7vGT5RCNr)x9bE1vbJLbo3UEqDmXrZn9wuIrdTUj)d1db4a5LRr5oJgboNLugBQ)(kHvHcboNLugBQ)(kX816Ig)Hehn30Brjgn0UTOSdBtVLYDgDuUTOSdBtVLewvC0CtVfLy0qdb4a5LRr5oJoA3U6WQOKqaoqE5AKy(ADrJN0fGYTRoSkkjeGdKxUgP7BysM6ZyZn9wMg1kbLBxDyvuEmBUjoceIAmnxJ0HHPwGXupeGdKxUgjxgIMdIJMB6TOeJgAlcUizm1t)nRdk3z0UD1Hvr5XS5gXrZn9wuIrdneGdKxUgL7mA3U6WQO8y2CdbcrnMMRr6WWulWyQhcWbYlxJKldrZbXrZn9wuIrdTBlhxd2go4ZA7Yk3z0rh1yAUgjLXM6VVsUmenhiqaboNLugBQ)(kHvJdQOc7iDB54AW2WbFwBx2JaJljMVwxuuhJabMs5YXY5ZEhg21iA2VzFwBxwITcIXFiXrZn9wuIrdTUj)d1db4a5LRr5oJoQX0CnskJn1FFLCziAoqGacColPm2u)9vcRkoAUP3IsmAOTQVMFZ(aBZxC0CtVfLy0qJOzkLd(VDVmwz6GBiYu0hsC0CtVfLy0q)T7LX(n7Np7Xn5F4fMkoAUP3IsmAODBrzh2MElXrZn9wuIrd9Nn84zkLlhRCNrhv0mLYLJLZN9omSRr0SFZ(S2US8AqyXeiWukxowQyX6qeCxEmt3YkhlVgewmbcmLYLJLw1xZVzVUZS3QGpW28LxdclMabMs5YXYlFx8b(n71WUo4dy2Uu51GWIJtCuC0CtVfv62vhwfffDUXmIE3GYDgncColTi4ISlsVcSnFjSQ4O5MElQ0TRoSkkkXOHgMY(E4RYLDz0wKq)g2O(8wJFZE1vbJvUZOD7QdRIsszSP(7ReZxRlA8OvkgbcrnMMRrszSP(7RKldrZbXrZn9wuPBxDyvuuIrdnmL99WxLl7YOn6pcRyQhBrYI9UfBAL7m6OdmcColXwKSyVBXM2hye4CwshZbruh5qHaNZslcUi7I0RaBZxcRghbcbgboNLylswS3Tyt7dmcColPJ5Gi6yIJMB6TOs3U6WQOOeJgAkJn1FFvUZOD7QdRIss)nRd(n7Np7Xn5F4fMkDFdtYuFgBUP3Y0Og9jIJMB6TOs3U6WQOOeJgAJ(5Y)nTEvioAUP3IkD7QdRIIsmAOTi4ISlsVcSnFL7mAe4CwszSP(7RewLab3U6WQOKugBQ)(kX816Ig)jeie1yAUgjLXM6VVsUmenhehn30BrLUD1Hvrrjgn0Q70BPCNrJaNZslcUi7I0RaBZxcRkoAUP3IkD7QdRIIsmAOr0mL2fPFZEk89YyXrZn9wuPBxDyvuuIrdnIMP0Ui9B2BWd8Tehn30BrLUD1Hvrrjgn0iAMs7I0VzVIUggloAUP3IkD7QdRIIsmAOr0mL2fPFZEQkUlsXrZn9wuPBxDyvuuIrdDewfzc30pJP(VDVmw5oJ(V6d8QRcgldCUD9G6yIJMB6TOs3U6WQOOeJg6qhrxSFwTw5oJ(V6d8QRcgldCUD9G6djoAUP3IkD7QdRIIsmAOV7LRXVzpPEXhOCNr72vhwfL0IGlsgt90FZ6GeZxRlQ4O5MElQ0TRoSkkkXOHgMY(E4lv5oJgboNLugBQ)(kHvjqiQX0CnskJn1FFLCziAoioAUP3IkD7QdRIIsmAOHPSVh(QCzxgnjElsQxf3xt7XgjRCNrhD0UD1HvrjHaCG8Y1iZWAThZUVHjz)0xg1NrGq0rnMMRr6WWulWyQhcWbYlxJKldrZbOuXCeEsxqQKecWbYlxtCXbLBxDyvuslcUizm1t)nRdsmFTUOO(mOqGZzjLXM6VVsmFTUOO(S4iqiAe4CwszSP(7ReZxRlA8NfN4O5MElQ0TRoSkkkXOHgMY(E4RYLDz0xgZqC(g1NTIu5oJoke4CwArWfzxKEfyB(syvOIgboNLugBQ)(kHvjqiQX0CnskJn1FFLCziAoeN4O5MElQ0TRoSkkkXOHgMY(E4RYLDz0ylscWfePEKM0J5GhbEMTehfhn30BrL3EAsB6Tqt)nRd(n7Np7Xn5F4fMQCNrJaNZs6VzDWVz)8zpUj)dVWuzyvuq9x9bE1vbJLbo3UEqhtC0CtVfvE7PjTP3Iy0qRyXb)M9K6fFGYDgncColrm60B53SNuV4dKWQqHaNZseJo9w(n7j1l(ajMVwx04jDHZDI4O5MElQ82ttAtVfXOHwXId(n7j1l(aL7m6O)SPNVu1nXFwS4ehn30BrL3EAsB6Tign0kwCWVzpPEXhOCNrhDxU92fPpyxJK9kflwSyxA8F20ZxETZFoLKNCACq9ztpFPQBI)0tHAmnxJe3K)HxyQxfVd7Mfl5Yq0CqC0CtVfvE7PjTP3Iy0qRyXb)M9K6fFGYDgD0D52BxK(GDns2R0HIfl2Lg)Nn98Lx78NtjjQghuF20ZxQ6M4p9uXrZn9wu5TNM0MElIrdTIfh8B2tQx8bk3z0r3LBVDr6d21izpQglwSln(pB65lV25pxmzKhhuF20ZxQ6M4r1tHAmnxJe3K)HxyQxfVd7Mfl5Yq0CqC0CtVfvE7PjTP3Iy0qRyXb)M9K6fFGYDgD0D52BxK(GDns2FyXIf7sJ)ZME(YRD(ZPK8K4G6ZME(sv3e)PNkoAUP3IkV90K20BrmAOP)M1b)M9ZN94M8p8ctvUZOrGZzj93So43SF(Sh3K)HxyQmSkkO(R(aV6QGXO(eXrZn9wu5TNM0MElIrdnjSHdTv(n7TY1CnEi2fjv5oJoQX0CnskJn1FFLCziAoavxU92fPpyxJK9NCASyxkQ)SPNV8AN)CXKNbvurJaNZsdh4A8boZvGXsyvceqGZzjjSHdTv(n7TY1CnEi2fjvcRsGacColdDeDXE6VzDqcRsGacColv3P3scRgN4O5MElQ82ttAtVfXOHo0r0f7P)M1bL7m6OgtZ1iPm2u)9vYLHO5auJP5AK5UmTNowfKCziAoavxU92fPpyxJK9NCASyxkQ)SPNV8AN)CXKNbvurJaNZsdh4A8boZvGXsyvceqGZzjjSHdTv(n7TY1CnEi2fjvcRsGacColdDeDXE6VzDqcRsGacColv3P3scRgN4O5MElQ82ttAtVfXOH2WbUgFGZCfySYDgDuJP5AKugBQ)(k5Yq0CaQUC7TlsFWUgj7p50yXUuu)ztpF51o)5IjpdQOIgboNLgoW14dCMRaJLWQeiGaNZssydhAR8B2BLR5A8qSlsQewLabe4Cwg6i6I90FZ6GewLabe4CwQUtVLewnoXrZn9wu5TNM0MElIrdT2oWVL)BvGQCNrh1yAUgjLXM6VVsUmenhG6ZME(sv3eVsNcEuv2bqbvrvWagaaa]] )


end
