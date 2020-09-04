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


    spec:RegisterPack( "Protection Paladin", 20200904.2, [[dierRaqibQhHcvBcegLaCkb0QuQKxrcMLa5wkfQ2fr)cszycQJHcwMsv9mLcMMsfxdK02qH4BkfY4eeX5ee16qHcnpbP7HI2NGWbfejles1drHIUOGi1jrHcwPsPDcsnuuO0svku6PQYubr7f4VcnyjomLfdXJPYKPQlJSzj9zuA0G60sTALQ8AqIztQBRKDl63QmCs64kfkwouphvtxX1vvBNe67KOXRuPoVsrRhfsZhs2pHbmaGe882qaO3p8(HdhYH3rYWomWWgaVztvc8unhumwc8sBrGhJfFd5M(srHXAAZ3j4PABQpZdGe843h7iWdEgvoJr0qJTh4pI0Dl0496RTPV0HT6GgVxo0apKFRhgdjab882qaO3p8(HdhYH3rYWomWW(HeWZ(d8HbVxVymbp427PeGaEEI7apgxuyS4Bi30xkkmwtB(ofBzCr5rQdTqiSOStqIY(H3pSyRylJlkmMWwYsCXwgxu24IsiL3tErzJLq(qHKGNU5dhaj4T6PzTPVeajaAgaqcEuAiAYdqh8C4EiCBGhYVwLC4M0(4vJdmfXnl8q3Nl9NYuuGqucquGp9Mr1tjHLEQ2UEefMIsyrbfkrb5xRsFRyNuu9Jvpoj)QIsGGN5M(sWJd3K2hVACGPiUzHh6(CWaGEFaKGhLgIM8a0bphUhc3g4H8RvjIXN(Y4vJS6dVP8Rkkqiki)AvIy8PVmE1iR(WBkX0Y6KlkHkkSoVOSlrzFWZCtFj4P8W(4vJS6dVjyaqVbaKGhLgIM8a0bphUhc3g4fGOatMEGLQUrucvu2jSOei4zUPVe8uEyF8Qrw9H3emaO3baj4rPHOjpaDWZH7HWTbEbikD6UvNSrVTmwkYq4WHdV4IsOIcmz6bwUSDlk7suyqUpufLaffiefyY0dSu1nIsOIcuHQOaHOmMMYrIBw4HUppQIVHCZHLuAiAYdEMB6lbpLh2hVAKvF4nbdaAOcGe8O0q0KhGo45W9q42aVaeLoD3Qt2O3wglfzydHdhEXfLqffyY0dSCz7wu2LOWGKreLaffiefyY0dSu1nIsOIcuHk4zUPVe8uEyF8Qrw9H3emaOzeaKGhLgIM8a0bphUhc3g4fGO0P7wDYg92YyPiJeoC4fxucvuGjtpWYLTBrzxIsy5gjkbkkqikWKPhyPQBeLqffgbQIceIYyAkhjUzHh6(8Ok(gYnhwsPHOjp4zUPVe8uEyF8Qrw9H3emaO3iaKGhLgIM8a0bphUhc3g4fGO0P7wDYg92YyPyihoC4fxucvuGjtpWYLTBrzxIcdY9fLaffiefyY0dSu1nIsOIcuHk4zUPVe8uEyF8Qrw9H3emaOdjaibpknen5bOdEoCpeUnWlyrzmnLJKtytfUxsknen5ffieLoD3Qt2O3wglf3hQHdV4IsiefyY0dSCz7wu2LOewUJOaHOeSOeGOG8RvPH9uorpvP0ty5xvuqHsuq(1QK9ByFBz8QrlDnLtekDYYLFvrbfkrb5xRsFRyNuKd3K2l)QIckuIcYVwLQ30xk)QIsGGN5M(sWJ9ByFBz8QrlDnLtekDYYbda6qgaj4rPHOjpaDWZH7HWTbEblkJPPCKCcBQW9ssPHOjVOaHOmMMYrw700r(yPxsPHOjVOaHO0P7wDYg92YyP4(qnC4fxucHOatMEGLlB3IYUeLWYDefieLGfLaefKFTknSNYj6PkLEcl)QIckuIcYVwLSFd7BlJxnAPRPCIqPtwU8RkkOqjki)Av6Bf7KIC4M0E5xvuqHsuq(1Qu9M(s5xvuce8m30xcE(wXoPihUjThmaOzimasWJsdrtEa6GNd3dHBd8cwugtt5i5e2uH7LKsdrtErbcrPt3T6Kn6TLXsX9HA4WlUOecrbMm9alx2UfLDjkHL7ikqikblkbiki)AvAypLt0tvk9ew(vffuOefKFTkz)g23wgVA0sxt5eHsNSC5xvuqHsuq(1Q03k2jf5WnP9YVQOGcLOG8RvP6n9LYVQOei4zUPVe8mSNYj6PkLEcdga0mWaasWJsdrtEa6GNd3dHBd8cwugtt5i5e2uH7LKsdrtErbcrbMm9alvDJOeQOWaubpZn9LGN22mEze2sphmGb8C3P9NYKdGeandaibpknen5bOdEoCpeUnWd5xRstrkz7KnQeBdS8RcEMB6lbVAJje9DEWaGEFaKGhLgIM8a0bpZn9LGNXOCydB8y9YjE1O6PKWGNd3dHBd8C3P9NYuYjSPc3ljMwwNCrjuMIcdHffuOeLGfLX0uosoHnv4EjP0q0Kh8sBrGNXOCydB8y9YjE1O6PKWGba9gaqcEuAiAYdqh8m30xcEghwrljEeBm6HJUdBAWZH7HWTbEbikEc5xRsSXOho6oSPJEc5xRs(yoOikHqu2irbcrb5xRstrkz7KnQeBdS8RkkbkkOqjkEc5xRsSXOho6oSPJEc5xRs(yoOikmfLWGxAlc8moSIws8i2y0dhDh20Gba9oaibpZn9LGhNWMkCVapknen5bOdga0qfaj4zUPVe8momLrytRpLGhLgIM8a0bdaAgbaj4rPHOjpaDWZH7HWTbEi)AvYjSPc3l5xvuqHsuC3P9NYuYjSPc3ljMwwNCrjurzFrbfkrjyrzmnLJKtytfUxsknen5bpZn9LGNPiLSDYgvITbgmaO3iaKGhLgIM8a0bphUhc3g4H8RvPPiLSDYgvITbw(vbpZn9LGN6n9LGbaDibaj4zUPVe8q0eN3jB8Qr(FTim4rPHOjpaDWaGoKbqcEMB6lbpenX5DYgVA0(ZFLGhLgIM8a0bdaAgcdGe8m30xcEiAIZ7KnE1OYohcdEuAiAYdqhmaOzGbaKGN5M(sWdrtCENSXRg5Q4ozbpknen5bOdga0mSpasWZCtFj4POLBm)MdtyEe2wlcdEuAiAYdqhmaOzydaibpknen5bOdEoCpeUnWd(0BgvpLew6PA76rucHOSbWZCtFj45Bf7KIZP1Gband7aGe8O0q0KhGo45W9q42ap3DA)PmLMIuYsyEKd3K2lX0Y6KdEMB6lbV1TOCIxnYQp8MGbandqfaj4rPHOjpaDWZH7HWTbEi)AvYjSPc3l5xvuqHsucwugtt5i5e2uH7LKsdrtEWZCtFj495uShAXbdaAgyeaKGhLgIM8a0bpZn9LGhl(swEuf3lthXglbEoCpeUnWlarjarXDN2Fkt5EFp7IYrw)ADetoydZsXPxKOecrzhrbfkrjarjyrzmnLJ0H)CZtyECVVNDr5iP0q0KxuGquuXKIrwNxYGCVVNDr5ikbkkbkkqikU70(tzknfPKLW8ihUjTxIPL1jxucHOSJOaHOG8RvjNWMkCVKyAzDYfLqik7ikbkkOqjkbiki)AvYjSPc3ljMwwNCrjurzhrjqWlTfbES4lz5rvCVmDeBSeyaqZWgbGe8O0q0KhGo4zUPVe8weMGYaB8y1swWZH7HWTbEblki)AvAksjBNSrLyBGLFvrbcrjarb5xRsoHnv4Ej)QIckuIsWIYyAkhjNWMkCVKuAiAYlkbcEPTiWBryckdSXJvlzbdaAgcjaibpknen5bOdEPTiWdBmQ)NqHhrA2iM8rK)mxcEMB6lbpSXO(FcfEePzJyYhr(ZCjyad45PQ91dasa0maGe8m30xcEyc5dfc8O0q0KhGoyaqVpasWJsdrtEa6GN5M(sWZzAD0CtFzu38b80nFIPTiWZDN2FktoyaqVbaKGhLgIM8a0bpZn9LGNZ06O5M(YOU5d4PB(etBrG3QNM1M(sWaGEhaKGhLgIM8a0bphUhc3g4H8RvPUReI(oVKpMdkIsOIYgapZn9LGNYdR9ksDgXe)slDeyaqdvaKGhLgIM8a0bphUhc3g4bF6nJQNscl9uTD9ikmfLWIceIsaIsaIcYVwLMIuY2jBuj2gy5xvuGqucwugtt5i5e2uH7LKsdrtErjqrbfkrb5xRsoHnv4Ej)QIsGGN5M(sWJd3K2hVACGPiUzHh6(CWaGMraqcEuAiAYdqh8C4EiCBGxaIcYVwLMIuY2jBuj2gy5xvuGquq(1Q0uKs2ozJkX2alX0Y6KlkHkk7ikqikblkJPPCKCcBQW9ssPHOjVOeOOGcLOeGOG8RvjNWMkCVKyAzDYfLqfLDefiefKFTk5e2uH7L8RkkbcEMB6lbpoCtAF8QXbMI4MfEO7Zbda6ncaj4rPHOjpaDWZH7HWTbEWNEZO6PKWspvBxpIsieLWGN5M(sWd2wlchVAuj2gyWaGoKaGe8O0q0KhGo45W9q42apKFTk5e2uH7L8Rkkqiki)AvYjSPc3ljMwwNCrjurzdGN5M(sWt3SWdpU33ZUOCada6qgaj4rPHOjpaDWZH7HWTbEblkUl5KdBtFP8RcEMB6lbp3LCYHTPVemaOzimasWJsdrtEa6GNd3dHBd8cquC3P9NYuU33ZUOCKyAzDYfLqffwNxuGquC3P9NYuU33ZUOCKoydZs8yfBUPV00Isiefgefief3DA)PmJyYCJOeOOGcLOeSOmMMYr6WFU5jmpU33ZUOCKuAiAYdEMB6lbV9(E2fLdyaqZadaibpknen5bOdEoCpeUnWZDN2FkZiMm3aEMB6lbptrkzjmpYHBs7bdaAg2haj4rPHOjpaDWZH7HWTbEU70(tzgXK5grbfkrjyrzmnLJ0H)CZtyECVVNDr5iP0q0Kh8m30xcE799SlkhWaGMHnaGe8O0q0KhGo45W9q42aVaeLGfLX0uosoHnv4EjP0q0KxuqHsuq(1QKtytfUxYVQOeOOaHOeSO4Vr6U0r5GTH8XQ2wue5JtjMwwNCrjeIsyrbfkrH4CkDKCGPOd)DnIMIxnw12IKylHIOeQOSbWZCtFj45U0r5GTH8XQ2weyaqZWoaibpknen5bOdEoCpeUnWlyrzmnLJKtytfUxsknen5ffuOefKFTk5e2uH7L8RcEMB6lbpDZcp84EFp7IYbmaOzaQaibpZn9LGNL9YIxn6jBGbpknen5bOdga0mWiaibpknen5bOdEMB6lbpenX5KpcBRfHbp(GBOqCWBdGbandBeasWZCtFj4bBRfHJxnoWue3SWdDFo4rPHOjpaDWaGMHqcasWZCtFj45UKtoSn9LGhLgIM8a0bdaAgczaKGhLgIM8a0bphUhc3g4fSOeGOqCoLosoWu0H)UgrtXRgRABrYLT3HffuOefIZP0rsLhw7vK6mIj(Lw6i5Y27WIckuIcX5u6iPL9YIxnQ7kfT0h9KnWYLT3HffuOefIZP0rYfTo8MXRg1Fx7JEmzlUCz7DyrjqWZCtFj4btgEIeNtPJadyapvm5UfInaibqZaasWJsdrtEa6Gba9(aibpknen5bOdga0Baaj4rPHOjpaDWaGEhaKGhLgIM8a0bdaAOcGe8m30xcEQ30xcEuAiAYdqhmaOzeaKGN5M(sWt3SWdpU33ZUOCapknen5bOdgWagWtrcZ7lbqVF49dhoKdVJKbWtPHZoz5GhJHL6HhYlk7ikMB6lffDZhUuSf84QKdanJWiGNk(QTMapgxuyS4Bi30xkkmwtB(ofBzCr5rQdTqiSOStqIY(H3pSyRylJlkmMWwYsCXwgxu24IsiL3tErzJLq(qHKITITmUOesVBY9hYlkiu9WKO4UfInIccX2jxkkHuohPoCrjVCJdB4v9RffZn9LCr5s9MsXwZn9LCPkMC3cXgMvTXHIyR5M(sUuftUBHyJcmrRENxS1CtFjxQIj3TqSrbMOzF2fLJn9LITmUO8stLdFJOGT2lki)AL8IcFSHlkiu9WKO4UfInIccX2jxuS0lkQyAJREZ0jRO0CrXFjjfBn30xYLQyYDleBuGjA80u5W3e5JnCXwZn9LCPkMC3cXgfyIM6n9LITMB6l5svm5UfInkWenDZcp84EFp7IYrSvSLXfLq6DtU)qErHuKWBkktVirzGjrXCZHfLMlkMIwRnenjfBn30xYzIjKpuiXwZn9LCfyIMZ06O5M(YOU5tqPTiMU70(tzYfBn30xYvGjAotRJMB6lJ6MpbL2IyU6PzTPVuS1CtFjxbMOP8WAVIuNrmXV0shfuxzI8RvPUReI(oVKpMdkHUbXwZn9LCfyIghUjTpE14atrCZcp095b1vMWNEZO6PKWspvBxpmddrabG8RvPPiLSDYgvITbw(vHi4X0uosoHnv4EjP0q0KpquOq(1QKtytfUxYVAGITMB6l5kWenoCtAF8QXbMI4MfEO7ZdQRmda5xRstrkz7KnQeBdS8RcbYVwLMIuY2jBuj2gyjMwwN8q3bIGhtt5i5e2uH7LKsdrt(arHkaKFTk5e2uH7LetlRtEO7abYVwLCcBQW9s(vduS1CtFjxbMObBRfHJxnQeBdCqDLj8P3mQEkjS0t121ticl2AUPVKRat00nl8WJ799SlkNG6ktKFTk5e2uH7L8RcbYVwLCcBQW9sIPL1jp0ni2AUPVKRat0CxYjh2M(YG6kZGDxYjh2M(s5xvS1CtFjxbMOT33ZUOCcQRmdWDN2Fkt5EFp7IYrIPL1jpuwNhc3DA)PmL799SlkhPd2WSepwXMB6lnDiyac3DA)PmJyYCtGOqf8yAkhPd)5MNW84EFp7IYrsPHOjVyR5M(sUcmrZuKswcZJC4M0(G6kt3DA)PmJyYCJyR5M(sUcmrBVVNDr5euxz6Ut7pLzetMBqHk4X0uosh(ZnpH5X9(E2fLJKsdrtEXwZn9LCfyIM7shLd2gYhRABrb1vMbe8yAkhjNWMkCVKuAiAYJcfYVwLCcBQW9s(vdeIG93iDx6OCW2q(yvBlkI8XPetlRtEicJcfX5u6i5atrh(7AenfVASQTfjXwcLq3GyR5M(sUcmrt3SWdpU33ZUOCcQRmdEmnLJKtytfUxsknen5rHc5xRsoHnv4Ej)QITMB6l5kWenl7LfVA0t2al2AUPVKRat0q0eNt(iSTweoi(GBOqCMBqS1CtFjxbMObBRfHJxnoWue3SWdDFUyR5M(sUcmrZDjNCyB6lfBn30xYvGjAWKHNiX5u6OG6kZGdG4CkDKCGPOd)DnIMIxnw12IKlBVdJcfX5u6iPYdR9ksDgXe)slDKCz7DyuOioNshjTSxw8QrDxPOL(ONSbwUS9omkueNtPJKlAD4nJxnQ)U2h9yYwC5Y27Wbk2k2AUPVKlD3P9NYKZS2ycrFNpOUYe5xRstrkz7KnQeBdS8Rk2AUPVKlD3P9NYKRat0(Ck2dTckTfX0yuoSHnESE5eVAu9us4G6kt3DA)PmLCcBQW9sIPL1jpuMmegfQGhtt5i5e2uH7LKsdrtEXwZn9LCP7oT)uMCfyI2NtXEOvqPTiMghwrljEeBm6HJUdB6G6kZa8eYVwLyJrpC0Dyth9eYVwL8XCqjeBeei)AvAksjBNSrLyBGLF1arHYti)AvIng9Wr3HnD0ti)AvYhZbfMHfBn30xYLU70(tzYvGjACcBQW9sS1CtFjx6Ut7pLjxbMOzCykJWMwFkfBn30xYLU70(tzYvGjAMIuY2jBuj2g4G6ktKFTk5e2uH7L8RIcL7oT)uMsoHnv4EjX0Y6Kh6(Oqf8yAkhjNWMkCVKuAiAYl2AUPVKlD3P9NYKRat0uVPVmOUYe5xRstrkz7KnQeBdS8Rk2AUPVKlD3P9NYKRat0q0eN3jB8Qr(FTiSyR5M(sU0DN2FktUcmrdrtCENSXRgT)8xPyR5M(sU0DN2FktUcmrdrtCENSXRgv25qyXwZn9LCP7oT)uMCfyIgIM48ozJxnYvXDYk2AUPVKlD3P9NYKRat0u0YnMFZHjmpcBRfHfBn30xYLU70(tzYvGjA(wXoP4CADqDLj8P3mQEkjS0t121ti2GyR5M(sU0DN2FktUcmrBDlkN4vJS6dVzqDLP7oT)uMstrkzjmpYHBs7LyAzDYfBn30xYLU70(tzYvGjAFof7Hw8G6ktKFTk5e2uH7L8RIcvWJPPCKCcBQW9ssPHOjVyR5M(sU0DN2FktUcmr7ZPyp0kO0wetw8LS8OkUxMoInwkOUYmGaC3P9NYuU33ZUOCK1VwhXKd2WSuC6ffIDqHkGGhtt5iD4p38eMh377zxuosknen5HqftkgzDEjdY9(E2fLtGbcH7oT)uMstrkzjmpYHBs7LyAzDYdXoqG8RvjNWMkCVKyAzDYdXobIcvai)AvYjSPc3ljMwwN8q3jqXwZn9LCP7oT)uMCfyI2NtXEOvqPTiMlctqzGnESAjBqDLzWi)AvAksjBNSrLyBGLFvica5xRsoHnv4Ej)QOqf8yAkhjNWMkCVKuAiAYhOyR5M(sU0DN2FktUcmr7ZPyp0kO0wetSXO(FcfEePzJyYhr(ZCPyRyR5M(sUC1tZAtFjtoCtAF8QXbMI4MfEO7ZdQRmr(1QKd3K2hVACGPiUzHh6(CP)uMqea8P3mQEkjS0t121dZWOqH8RvPVvStkQ(XQhNKF1afBn30xYLREAwB6lvGjAkpSpE1iR(WBguxzI8RvjIXN(Y4vJS6dVP8RcbYVwLigF6lJxnYQp8MsmTSo5HY687AFXwZn9LC5QNM1M(sfyIMYd7JxnYQp8Mb1vMbatMEGLQUj0DchOyR5M(sUC1tZAtFPcmrt5H9XRgz1hEZG6kZa60DRozJEBzSuKHWHdhEXdfMm9alx2U3fdY9HAGqatMEGLQUjuOcvigtt5iXnl8q3NhvX3qU5Wsknen5fBn30xYLREAwB6lvGjAkpSpE1iR(WBguxzgqNUB1jB0BlJLImSHWHdV4HctMEGLlB37IbjJeieWKPhyPQBcfQqvS1CtFjxU6PzTPVubMOP8W(4vJS6dVzqDLzaD6UvNSrVTmwkYiHdhEXdfMm9alx2U3vy5gfieWKPhyPQBcLrGkeJPPCK4MfEO7ZJQ4Bi3CyjLgIM8ITMB6l5YvpnRn9LkWenLh2hVAKvF4ndQRmdOt3T6Kn6TLXsXqoC4WlEOWKPhy5Y29UyqUFGqatMEGLQUjuOcvXwgxum30xYLREAwB6lvGjAC4M0(4vJdmfXnl8q3NhuxzI8RvjhUjTpE14atrCZcp095s)PmHia4tVzu9us4qSpkui)Av6Bf7KIQFS6Xj5xnqXwZn9LC5QNM1M(sfyIg73W(2Y4vJw6AkNiu6KLhuxzg8yAkhjNWMkCVKuAiAYdrNUB1jB0BlJLI7d1WHx8qatMEGLlB37kSChicoaKFTknSNYj6PkLEcl)QOqH8Rvj73W(2Y4vJw6AkNiu6KLl)QOqH8RvPVvStkYHBs7LFvuOq(1Qu9M(s5xnqXwZn9LC5QNM1M(sfyIMVvStkYHBs7dQRmdEmnLJKtytfUxsknen5HymnLJS2PPJ8XsVKsdrtEi60DRozJEBzSuCFOgo8IhcyY0dSCz7ExHL7arWbG8RvPH9uorpvP0ty5xffkKFTkz)g23wgVA0sxt5eHsNSC5xffkKFTk9TIDsroCtAV8RIcfYVwLQ30xk)Qbk2AUPVKlx90S20xQat0mSNYj6PkLEchuxzg8yAkhjNWMkCVKuAiAYdrNUB1jB0BlJLI7d1WHx8qatMEGLlB37kSChicoaKFTknSNYj6PkLEcl)QOqH8Rvj73W(2Y4vJw6AkNiu6KLl)QOqH8RvPVvStkYHBs7LFvuOq(1Qu9M(s5xnqXwZn9LC5QNM1M(sfyIM22mEze2sppOUYm4X0uosoHnv4EjP0q0KhcyY0dSu1nHYaubdyaaa]] )


end
