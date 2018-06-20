-- PaladinRetribution.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'PALADIN' then
    local spec = Hekili:NewSpecialization( 70 )

    spec:RegisterResource( Enum.PowerType.HolyPower )
    spec:RegisterResource( Enum.PowerType.Mana )
    
    -- Talents
    spec:RegisterTalents( {
        zeal = 22590, -- 269569
        righteous_verdict = 22557, -- 267610
        execution_sentence = 22175, -- 267798

        fires_of_justice = 22319, -- 203316
        blade_of_wrath = 22592, -- 231832
        hammer_of_wrath = 22593, -- 24275

        fist_of_justice = 22896, -- 234299
        repentance = 22180, -- 20066
        blinding_light = 21811, -- 115750

        divine_judgment = 22375, -- 271580
        consecration = 22182, -- 205228
        wake_of_ashes = 22183, -- 255937

        cavalier = 22595, -- 230332
        unbreakable_spirit = 22185, -- 114154
        eye_for_an_eye = 22186, -- 205191

        selfless_healer = 23167, -- 85804
        justicars_vengeance = 22483, -- 215661
        word_of_glory = 23086, -- 210191

        divine_purpose = 22591, -- 223817
        crusade = 22215, -- 231895
        inquisition = 22634, -- 84963
    } )

    -- Auras
    spec:RegisterAuras( {
        avenging_wrath = {
            id = 31884,
            duration = 20,
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
            type = "Magic",
            max_stack = 1,
        },

        crusade = {
            id = 231895,
            duration = 25,
            type = "Magic",
            max_stack = 10,
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

        execution_sentence = {
            id = 267799,
            duration = 12,
            max_stack = 1,
        },

        greater_blessing_of_kings = {
            id = 203538,
            duration = 3600,
            max_stack = 1,
        },

        greater_blessing_of_wisdom = {
            id = 203539,
            duration = 3600,
            max_stack = 1,
        },

        hammer_of_justice = {
            id = 853,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },

        hand_of_hindrance = {
            id = 183218,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },

        hand_of_reckoning = {
            id = 62124,
            duration = 3,
            max_stack = 1,
        },

        inquisition = {
            id = 84963,
            duration = 45,
            max_stack = 1,
        },

        judgment = {
            id = 197277,
            duration = 15,
            max_stack = 1,
        },

        shield_of_vengeance = {
            id = 184662,
            duration = 15,
            max_stack = 1,
        },

        wake_of_ashes = {
            id = 255937,
            duration = 5,
            max_stack = 1,
        },
    } )

    spec:RegisterGear( 'tier19', 138350, 138353, 138356, 138359, 138362, 138369 )
    spec:RegisterGear( 'tier20', 147160, 147162, 147158, 147157, 147159, 147161 )
        spec:RegisterAura( 'sacred_judgment', {
            id = 246973,
            duration = 8
        } )

    spec:RegisterGear( 'tier21', 152151, 152153, 152149, 152148, 152150, 152152 )
        spec:RegisterAura( 'hidden_retribution_t21_4p', {
            id = 253806, 
            duration = 15 
        } )

    spec:RegisterGear( 'class', 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )
    spec:RegisterGear( 'truthguard', 128866 )
    spec:RegisterGear( 'whisper_of_the_nathrezim', 137020 )
        spec:RegisterAura( 'whisper_of_the_nathrezim', {
            id = 207633,
            duration = 3600
        } )

    spec:RegisterGear( 'justice_gaze', 137065 )
    spec:RegisterGear( 'ashes_to_dust', 51745 )
        spec:RegisterAura( 'ashes_to_dust', {
            id = 236106, 
            duration = 6
        } )

    spec:RegisterGear( 'aegisjalmur_the_armguards_of_awe', 140846 )
    spec:RegisterGear( 'chain_of_thrayn', 137086 )
        spec:RegisterAura( 'chain_of_thrayn', {
            id = 236328,
            duration = 3600
        } )

    spec:RegisterGear( 'liadrins_fury_unleashed', 137048 )
        spec:RegisterAura( 'liadrins_fury_unleashed', {
            id = 208410,
            duration = 3600,
        } )

    spec:RegisterGear( "soul_of_the_highlord", 151644 )
    spec:RegisterGear( "pillars_of_inmost_light", 151812 )
    spec:RegisterGear( "scarlet_inquisitors_expurgation", 151813 )
        spec:RegisterAura( "scarlet_inquisitors_expurgation", {
            id = 248289, 
            duration = 3600,
            max_stack = 3
        } )



    -- Abilities
    spec:RegisterAbilities( {
        avenging_wrath = {
            id = 31884,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = 'cooldowns',
            notalent = 'crusade',
            
            startsCombat = true,
            texture = 135875,
            
            usable = function () return not buff.avenging_wrath.up end,
            handler = function ()
                applyBuff( 'avenging_wrath', 20 )
                if level < 115 then
                    if equipped.liadrins_fury_unleashed then gain( 1, 'holy_power' ) end
                end
            end,
        },
        

        blade_of_justice = {
            id = 184575,
            cast = 0,
            cooldown = function () return 10.5 * haste end,
            gcd = "spell",

            spend = -2,
            spendType = 'holy_power',

            notalent = 'divine_hammer',
            bind = 'divine_hammer',
            
            startsCombat = true,
            texture = 1360757,
                        
            handler = function ()
                removeBuff( 'sacred_judgment' )
                if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, 1 ) end
            end,
        },
        

        blessing_of_freedom = {
            id = 1044,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135968,
            
            handler = function ()
                applyBuff( 'blessing_of_freedom' )
            end,
        },
        

        blessing_of_protection = {
            id = 1022,
            cast = 0,
            charges = 1,
            cooldown = 300,
            recharge = 300,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135964,
            
            handler = function ()
                applyBuff( 'blessing_of_protection' )
                applyDebuff( 'player', 'forbearance' )
            end,
        },
        

        blinding_light = {
            id = 115750,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            spend = 0.08,
            spendType = "mana",

            talent = 'blinding_light',
            
            startsCombat = true,
            texture = 571553,
            
            handler = function ()
                applyDebuff( 'target', 'blinding_light', 6 )
                active_dot.blinding_light = active_enemies
            end,
        },
        

        cleanse_toxins = {
            id = 213644,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            spend = 0.06,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135953,
            
            handler = function ()
            end,
        },
        

        consecration = {
            id = 205228,
            cast = 0,
            cooldown = 20,
            gcd = "spell",
            
            talent = 'consecration',
            
            startsCombat = true,
            texture = 135926,

            handler = function ()
            end,
        },
        

        crusade = {
            id = 231895,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            talent = 'crusade',
            toggle = 'cooldowns',
            
            startsCombat = false,
            texture = 236262,
            
            usable = function () return not buff.crusade.up end,
            handler = function ()
                applyBuff( 'crusade' )
            end,
        },
        

        crusader_strike = {
            id = 35395,
            cast = 0,
            charges = 2,
            cooldown = function () return ( talent.fires_of_justice.enabled and 5 or 6 ) * haste end,
            recharge = function () return ( talent.fires_of_justice.enabled and 5 or 6 ) * haste end,
            gcd = "spell",

            spend = -1,
            spendType = 'holy_power',
            
            startsCombat = true,
            texture = 135891,
            
            handler = function ()
            end,
        },
        

        divine_shield = {
            id = 642,
            cast = 0,
            cooldown = function () return 300 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 524354,
            
            usable = function () return not debuff.forbearance.up end,
            handler = function ()
                applyBuff( 'divine_shield' )
                applyDebuff( 'player', 'forbearance' )
            end,
        },
        

        divine_steed = {
            id = 190784,
            cast = 0,
            charges = function () return talent.cavalier.enabled and 2 or 1 end,
            cooldown = 60,
            recharge = 60,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1360759,
            
            handler = function ()
                applyBuff( 'divine_steed' )
            end,
        },
        

        divine_storm = {
            id = 53385,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 )
            end,
            spendType = "holy_power",
            
            startsCombat = true,
            texture = 236250,
            
            handler = function ()
                if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
                else
                    removeBuff( 'fires_of_justice' )
                    removeBuff( 'hidden_retribution_t21_4p' )
                end
                if level < 115 then
                    if equipped.whisper_of_the_nathrezim then applyBuff( 'whisper_of_the_nathrezim', 4 ) end
                    if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, active_enemies ) end
                end
            end,
        },
        

        execution_sentence = {
            id = 267798,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 )
            end,
            spendType = "holy_power",
            
            talent = 'execution_sentence', 

            startsCombat = true,
            texture = 613954,
            
            handler = function ()
                if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
                else
                    removeBuff( 'fires_of_justice' )
                    removeBuff( 'hidden_retribution_t21_4p' )
                end
                applyDebuff( 'target', 'execution_sentence', 12 )
            end,
        },

        eye_for_an_eye = {
            id = 205191,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            talent = 'eye_for_an_eye',

            startsCombat = false,
            texture = 135986,
            
            handler = function ()
                applyBuff( 'eye_for_an_eye' )
            end,
        },
        

        flash_of_light = {
            id = 19750,
            cast = function () return ( 1.5 - ( buff.selfless_healer.stack * 0.5 ) ) * haste end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.2,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135907,
            
            handler = function ()
                removeBuff( 'selfless_healer' )
            end,
        },
        

        -- TODO:  Detect GBoK on allies.
        greater_blessing_of_kings = {
            id = 203538,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135993,
            
            handler = function ()
                applyBuff( 'greater_blessing_of_kings' )
            end,
        },
        

        -- TODO:  Detect GBoW on allies.
        greater_blessing_of_wisdom = {
            id = 203539,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135912,
            
            handler = function ()
                applyBuff( 'greater_blessing_of_wisdom' )
            end,
        },
        

        hammer_of_justice = {
            id = 853,
            cast = 0,
            cooldown = function ()
                if equipped.justice_gaze and target.health.percent > 75 then
                    return 15
                end
                return 60
            end,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135963,
            
            handler = function ()
                applyDebuff( 'target', 'hammer_of_justice' )
                if equipped.justice_gaze and target.health.percent > 75 then
                    gain( 1, 'holy_power' )
                end
            end,
        },
        

        hammer_of_wrath = {
            id = 24275,
            cast = 0,
            cooldown = function () return 7.5 * haste end,
            gcd = "spell",

            spend = -1,
            spendType = 'holy_power',
            
            startsCombat = true,
            texture = 613533,
            
            usable = function () return target.health_pct < 20 or buff.avenging_wrath.up or buff.crusade.up end,
            handler = function ()                
            end,
        },
        

        hand_of_hindrance = {
            id = 183218,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            startsCombat = true,
            texture = 1360760,
            
            handler = function ()
                applyDebuff( 'target', 'hand_of_hindrance' )
            end,
        },
        

        hand_of_reckoning = {
            id = 62124,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135984,
            
            handler = function ()
                applyDebuff( 'target', 'hand_of_reckoning' )
            end,
        },
        

        inquisition = {
            id = 84963,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 0,
            spendType = "holy_power",

            talent = 'inquisition',
            
            startsCombat = true,
            texture = 461858,
            
            usable = function () return buff.fires_of_justice.up or holy_power.current > 0 end,
            handler = function ()
                if buff.fires_of_justice.up then
                    local hopo = min( 2, holy_power.current )
                    spend( hopo, 'holy_power' )                    
                    applyBuff( 'inquisition', 15 * ( hopo + 1 ) )
                    return
                end
                local hopo = min( 3, holy_power.current )
                spend( hopo, 'holy_power' )                    
                applyBuff( 'inquisition', 15 * hopo )
            end,
        },
        

        judgment = {
            id = 20271,
            cast = 0,
            charges = 1,
            cooldown = function () return 12 * haste end,
            gcd = "spell",
            
            spend = -1,
            spendType = "holy_power",
            
            startsCombat = true,
            texture = 135959,
            
            handler = function ()
                applyDebuff( 'target', 'judgment' )
                if talent.zeal.enabled then applyBuff( 'zeal', 20, 3 ) end
                if set_bonus.tier20_2pc > 0 then applyBuff( 'sacred_judgment' ) end
                if set_bonus.tier21_4pc > 0 then applyBuff( 'hidden_retribution_t21_4p', 15 ) end
                if talent.sacred_judgment.enabled then applyBuff( 'sacred_judgment' ) end                
            end,
        },
        

        justicars_vengeance = {
            id = 215661,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 5 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 )
            end,
            spendType = "holy_power",
            
            startsCombat = true,
            texture = 135957,
            
            handler = function ()
                if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
                else
                    removeBuff( 'fires_of_justice' )
                    removeBuff( 'hidden_retribution_t21_4p' )
                end
                if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, 1 ) end
            end,
        },
        

        lay_on_hands = {
            id = 633,
            cast = 0,
            cooldown = function () return 600 * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) end,
            gcd = "off",
            
            startsCombat = false,
            texture = 135928,
            
            handler = function ()
                gain( health.max, "health" )
                applyDebuff( 'player', 'forbearance', 30 )                
            end,
        },
        

        rebuke = {
            id = 96231,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            toggle = 'interrupts',
            
            startsCombat = true,
            texture = 523893,
            
            usable = function () return debuff.casting.up end,
            handler = function ()
                interrupt()
            end,
        },
        

        redemption = {
            id = 7328,
            cast = function () return 10 * haste end,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135955,
            
            handler = function ()
            end,
        },
        

        repentance = {
            id = 20066,
            cast = function () return 1.7 * haste end,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            startsCombat = false,
            texture = 135942,
            
            handler = function ()
                interrupt()
                applyDebuff( 'target', 'repentance', 60 )
            end,
        },
        

        shield_of_vengeance = {
            id = 184662,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236264,
            
            usable = function () return incoming_damage_3s > 0.2 * health.max end,
            handler = function ()
                applyBuff( 'shield_of_vengeance' )
            end,
        },
        

        templars_verdict = {
            id = 85256,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 )
            end,
            spendType = "holy_power",
            
            startsCombat = true,
            texture = 461860,
            
            handler = function ()
                if buff.divine_purpose.up then removeBuff( 'divine_purpose' )                
                else
                    removeBuff( 'fires_of_justice' )
                    removeBuff( 'hidden_retribution_t21_4p' )
                end
                if talent.righteous_verdict.enabled then applyBuff( 'righteous_verdict' ) end
                if level < 115 and equipped.whisper_of_the_nathrezim then applyBuff( 'whisper_of_the_nathrezim', 4 ) end
                if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, 1 ) end
            end,
        },
        

        wake_of_ashes = {
            id = 255937,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = -5,
            spendType = 'holy_power',

            startsCombat = true,
            texture = 1112939,
            
            handler = function ()
                if target.is_undead or target.is_demon then applyDebuff( 'target', 'wake_of_ashes' ) end
                if level < 115 and equipped.ashes_to_dust then
                    applyDebuff( 'target', 'ashes_to_dust' )
                    active_dot.ashes_to_dust = active_enemies
                end
                if talent.divine_judgment.enabled then addStack( 'divine_judgment', 15, 1 ) end
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
        

        word_of_glory = {
            id = 210191,
            cast = 0,
            charges = 2,
            cooldown = 60,
            recharge = 60,
            gcd = "spell",
            
            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 )
            end,
            spendType = "holy_power",
            
            startsCombat = true,
            texture = 133192,
            
            handler = function ()
                if buff.divine_purpose.up then removeBuff( 'divine_purpose' )
                else
                    removeBuff( 'fires_of_justice' )
                    removeBuff( 'hidden_retribution_t21_4p' )
                end
                gain( 1.33 * stat.spell_power * 8, 'health' )
            end,
        },
    } )

    spec:RegisterPack( "Retribution", 20180619.222400, [[dieiIaqiKGhHujYMeOrHKCkKuRsQsVsLWSKQ4wuav7Iu)sq1Wuj6yQKSmk0ZqQY0OaDnKQABua5BQKIXPsk15qQKwNkPeZdj6EQW(KQAHcOlIujQrIuPojfqPvsb9skGIDkadvLuslfPs4PaMksPVsbyVO8xPmyehMQftupMWKP0LH2mr(SkA0sLtR0QfuEnsOztYTfQDl63kgUk1Xvjvlh0Zr10LCDG2UG8DHmEKkopsX8PO9RQzxXOLby9czby8YRU2xAGUIUQnA0ObnAGyafn3id42fu0prgq6XidGUal4kdw7KmGBNg14wgTma(acfidORQB(1s4HF78cL3ulM4Wx6k9OiDHGUAGHbidUQYaBYKzawVqgGXlV6ABGFPbYa)k66tmA8AXOrga)gfSaUMlzawKlya02T8NS8NuD4tSOKdQQN4IAN8j3UGI(j(ePb(e6cSGRmyTt(KRvx52n5AgWnCKwfYaOl9e6Y0bfGfAFcgcH08KAJXNuD4tCrnWNS8N4H8v5Yku)g6IANKF4G108QCbfFdDrTtYV4iCikdsr8n0f1oj)IJWfUs1CrTt2ulV6j9y8yUXeH9Ssh1gJuAmy3OOPDpriKs69g6IANKFXr4cxPAUO2jBQLx9KEmEiMrzNOK)g6IANKFXr4cxPAUO2jBQLx9KEmECIjc9AG83W3qxu7KCTygLDIs(X9u7K9SshujdkjPLvZyvG8sdrxuMMYGssApeMNBE2IGE1PbVnnLbLK0cii3TOg8oOmOKKwab5Uf1qm23KtPr6BAwo8elDTXyRMMDrkpm4Lu)g6IANKRfZOStuYV4iC1E2v8wyG2ZymREwPd(nQuTYHNyX1Q9SR4TWaTNXyw9pmAAsffG(AByimlTBTCnsNLxCttOV2ggcZs7wlxVz)RH(u)g6IANKRfZOStuYV4iCE3IkBBKAHW8e9uGVHUO2j5AXmk7eL8loc3dH55MNTiOxD9SshYGss6nVo4Y3ANudEBAsHYvyw6nVo4Y3ANuJPlRq7BOlQDsUwmJYorj)IJWfqqUBXEwPJUrrt7EIqy)dd(g(g6IANKRL2C5DiKFeYHRlRWEspgpS8MW5LlRWEc5kq8GFJkvRC4jwCTDdTj241aJ7FqptZYvywA7gAtSfgO9mgZsJPlRqBq(nQuTYHNyX12n0MyJxdmU)HX3qxu7KCT0MlVdH8locFZRdU8T2j7zLoKbLK0BEDWLV1oP2orPPPmOKKEZRdU8T2j1qm23Ktj9d2nkAA3tec7Fy00umJYorPgPdkaRDYghZctbQHySVjNYRUmOmOKKEZRdU8T2j1qm23Kt5v0)n0f1ojxlT5Y7qi)IJWr6GcWANSXXSWuG9Ssh8BuPALdpXIRTBOnXgVgymLh0livuOCfMLwab5Uf1y6Yk0AAkMrzNOulGGC3IAig7BY7FkS9AK63qxu7KCT0MlVdH8loc3UH2eB8AGX9SshHC46YkuB5nHZlxwHbLbLK02n0My7geEpCudrxuVHUO2j5APnxEhc5xCeUDdTj241aJ7zLoc5W1LvO2YBcNxUScdsffkxHzPfqqUBrnMUScTMMIzu2jk1cii3TOgIX(M8(NcBVgP(n0f1ojxlT5Y7qi)IJWlm(w5qElecTRO6zLoKbLK02n0My7geEpCudrxubPIcLRWS0iDqbyTt24ywykqnMUScTMMIzu2jk1iDqbyTt24ywykqneJ9n59pfwQFdDrTtY1sBU8oeYV4i8cJVvoK3cHq7kQEwPdQOq5kmlTacYDlQX0LvO10umJYorPwab5Uf1qm23K3)uy71i1bPIcLRWS0iDqbyTt24ywykqnMUScTMMYGssAbeK7wudEhugusslGGC3IAE5cks5vxAAkMrzNOuJ0bfG1ozJJzHPa1qm23K3)uy71i1VHVHUO2j56tmrOxdKFeYHRlRWEspgpO7Xa6jKRaXdQOq5kmlDNhhJW2i1IGE1PX0LvO10SC4jw6o0vvN(wu9pmEzqQKbLK0Eimp38Sfb9QtBNO00ugusslGGC3IA7eLut9BOlQDsU(ete61a5xCeUWvQMlQDYMA5vpPhJhsBU8oeY7zLo6gfnT7jcH9pO)BOlQDsU(ete61a5xCeEKtrSnsnN3H8EwPdQOa0xBddHzPDRLRr6S8IBAc912WqywA3A56n7B8sQdsv3OOPDpriKYJlnn7gfnT7jcHhxfumJYorPww5wSnsTWa51kqneJ9n59pfwQdsLygLDIsTacYDlQHySVjVVXlnnPq5kmlTacYDlQX0LvOL63qxu7KC9jMi0RbYV4iCzLBX2i1cdKxRa7zLo6gfnT7jcHuEy00KQUrrt7EIq4b9csLygLDIsDNhhJW2i1IGE1PHySVjV)PW2RrtZqoCDzfQP7XaOM63qxu7KC9jMi0RbYV4i8WaTNXyw9SshDJIM29eHqkpmAA2nkAA3tecP8GEbfZOStuQLvUfBJulmqETcudXyFtE)tHTxJMMu1nkAA3tecpmyqXmk7eLAzLBX2i1cdKxRa1qm23K3)uy71yWqoCDzfQP7XaO(n0f1ojxFIjc9AG8locVZJJryBKArqV6EdDrTtY1NyIqVgi)IJWftYrb0RDYEwPJUrrt7EIqiLhgnn7gfnT7jcHuEqVGIzu2jk1Yk3ITrQfgiVwbQHySVjV)PW2RrttQ6gfnT7jcHhgmOygLDIsTSYTyBKAHbYRvGAig7BY7FkS9AmOygLDIsDyG2ZymlneJ9n59pf2EngmKdxxwHA6EmaQFdDrTtY1NyIqVgi)IJWfUs1CrTt2ulV6j9y8qAZL3HqEpR0r5kmlDNhhJW2i1IGE1PX0LvOnivLdpXs3HUQ603IIYdJxAAkdkjP9qyEU5zlc6vNg820ugusslGGC3IAWBQdsLmOKK2UH2eB3GW7HJAWBttzqjjTacYDlQ5LlOiLxDj1VHUO2j56tmrOxdKFXr4cii3TiSXl4srSNv6qmJYorPwab5UfHnEbxkIArNdprEtc6IAN0v9pUsFn0pivDJIM29eHqkpmAA2nkAA3tecP8GEbfZOStuQLvUfBJulmqETcudXyFtE)tHTxJMMDJIM29eHWddgumJYorPww5wSnsTWa51kqneJ9n59pf2EngumJYorPomq7zmMLgIX(M8(NcBVgdkMrzNOulMKJcOx7KAig7BY7FkS9AmyihUUSc109yau)g6IANKRpXeHEnq(fhHlCLQ5IANSPwE1t6X4H0MlVdH83qxu7KC9jMi0RbYV4iCbeK7we24fCPi(g6IANKRpXeHEnq(fhH7qHNyRgieZQNv6GklkdkjPr6GcWANSXXSWuGAWBttQkxHzP784ye2gPwe0RonMUScTbPQC4jw6o0vvN(wu9pmEPPPmOKK2dH55MNTiOxDA7eLMMYGssAbeK7wuBNOKAQnnPq5kmlnshuaw7KnoMfMcuJPlRqRPjfkxHzP784ye2gPwe0RonMUScTuhSBu00UNies5HbFdFdDrTtY1ZnMi8i8iNIyBKAoVd5VHUO2j565gteEXr4Yk3ITrQfgiVwb2ZkD0nkAA3tecPK(VHUO2j565gteEXr4HbApJXS6zLo6gfnT7jcHusFgqKdZnp5magGdwDdKbaqruH1azaQLxCgTmG5gteYOLfWvmAzaUO2jzarofX2i1CEhYzay6Yk0YcKvSamYOLbGPlRqllqgGaUfcxNb0nkAA3tecFcLpH(maxu7KmazLBX2i1cdKxRazfla6XOLbGPlRqllqgGaUfcxNb0nkAA3tecFcLpH(maxu7KmGWaTNXywSIvmalk5GQIrllGRy0YaCrTtYaCWAAEvUGImamDzfAzbYkwagz0YaCrTtYaGOmifrgaMUScTSazfla6XOLbGPlRqllqgGaUfcxNbuBm(ekFIXNe8jDJIM29eHWNq5tOhdWf1ojdq4kvZf1oztT8IbOwE1spgzaZnMiKvSamiJwgaMUScTSazaUO2jzacxPAUO2jBQLxma1YRw6XidqmJYorjNvSaOpJwgaMUScTSazaUO2jzacxPAUO2jBQLxma1YRw6Xid4ete61a5SIvmGBikMyzVy0YkgGygLDIsoJwwaxXOLbGPlRqllqgGaUfcxNbq1tKbLK0YQzSkqEPHOlQNyA(ezqjjThcZZnpBrqV60G3pX08jYGssAbeK7wudE)KGprgusslGGC3IAig7BYFcLpXi9FIP5tkhEILU2ySvtZU4tO84jg8YNqndWf1ojd4EQDswXcWiJwgaMUScTSazac4wiCDga)gvQw5WtS4A1E2v8wyG2ZymRN0)4jgFIP5tO6ju4jqFTnmeML2TwUgPZYl(tmnFc0xBddHzPDRLR38j9FY1q)NqndWf1ojdqTNDfVfgO9mgZIvSaOhJwgGlQDsgaVBrLTnsTqyEIEkqgaMUScTSazfladYOLbGPlRqllqgGaUfcxNbidkjP386GlFRDsn49tmnFcfEs5kml9MxhC5BTtQX0LvOLb4IANKb4HW8CZZwe0RowXcG(mAzay6Yk0YcKbiGBHW1zaDJIM29eHWN0)4jgKb4IANKbiGGC3ISIvmaPnxEhc5mAzbCfJwgaMUScTSazaHCfiYa43Os1khEIfxB3qBInEnW4N0)4j07jMMpPCfML2UH2eBHbApJXS0y6Yk0(KGpHFJkvRC4jwCTDdTj241aJFs)JNyKb4IANKbeYHRlRqgqih2spgzawEt48YLviRybyKrldatxwHwwGmabCleUodqgussV51bx(w7KA7eLpX08jYGss6nVo4Y3ANudXyFt(tO8j0)jbFs3OOPDpri8j9pEIXNyA(eXmk7eLAKoOaS2jBCmlmfOgIX(M8Nq5tU6YNe8jYGss6nVo4Y3ANudXyFt(tO8jxrFgGlQDsgWMxhC5BTtYkwa0JrldatxwHwwGmabCleUodGFJkvRC4jwCTDdTj241aJFcLhpHEpj4tO6ju4jLRWS0cii3TOgtxwH2NyA(eXmk7eLAbeK7wudXyFt(t6)KtH9j9(eJpHAgGlQDsgashuaw7KnoMfMcKvSamiJwgaMUScTSazac4wiCDgqihUUSc1wEt48YLv4tc(ezqjjTDdTj2UbH3dh1q0ffdWf1ojdWUH2eB8AGXSIfa9z0YaW0LvOLfidqa3cHRZac5W1LvO2YBcNxUScFsWNq1tOWtkxHzPfqqUBrnMUScTpX08jIzu2jk1cii3TOgIX(M8N0)jNc7t69jgFc1maxu7Kma7gAtSXRbgZkwagigTmamDzfAzbYaeWTq46mazqjjTDdTj2UbH3dh1q0f1tc(eQEcfEs5kmlnshuaw7KnoMfMcuJPlRq7tmnFIygLDIsnshuaw7KnoMfMcudXyFt(t6)KtH9juZaCrTtYakm(w5qElecTROyflGRHrldatxwHwwGmabCleUodGQNqHNuUcZslGGC3IAmDzfAFIP5teZOStuQfqqUBrneJ9n5pP)tof2N07tm(eQFsWNq1tOWtkxHzPr6GcWANSXXSWuGAmDzfAFIP5tKbLK0cii3TOg8(jbFImOKKwab5Uf18Yfu8ju(KRU8jMMprmJYorPgPdkaRDYghZctbQHySVj)j9FYPW(KEFIXNqndWf1ojdOW4BLd5Tqi0UIIvSIbCIjc9AGCgTSaUIrldatxwHwwGmGqUcezau9ek8KYvyw6opogHTrQfb9QtJPlRq7tmnFs5WtS0DORQo9TOEs)JNy8YNe8ju9ezqjjThcZZnpBrqV602jkFIP5tKbLK0cii3TO2or5tO(juZaCrTtYac5W1LvidiKdBPhJma6EmawXcWiJwgaMUScTSazac4wiCDgq3OOPDpri8j9pEc9zaUO2jzacxPAUO2jBQLxma1YRw6XidqAZL3HqoRybqpgTmamDzfAzbYaeWTq46maQEcfEc0xBddHzPDRLRr6S8I)etZNa912WqywA3A56nFs)Ny8YNq9tc(eQEs3OOPDpri8juE8KlFIP5t6gfnT7jcHp54jx9KGprmJYorPww5wSnsTWa51kqneJ9n5pP)tof2Nq9tc(eQEIygLDIsTacYDlQHySVj)j9FIXlFIP5tOWtkxHzPfqqUBrnMUScTpHAgGlQDsgqKtrSnsnN3HCwXcWGmAzay6Yk0YcKbiGBHW1zaDJIM29eHWNq5Xtm(etZNq1t6gfnT7jcHp54j07jbFcvprmJYorPUZJJryBKArqV60qm23K)K(p5uyFsVpX4tmnFsihUUSc109yapH6NqndWf1ojdqw5wSnsTWa51kqwXcG(mAzay6Yk0YcKbiGBHW1zaDJIM29eHWNq5Xtm(etZN0nkAA3tecFcLhpHEpj4teZOStuQLvUfBJulmqETcudXyFt(t6)KtH9j9(eJpX08ju9KUrrt7EIq4toEIbFsWNiMrzNOulRCl2gPwyG8AfOgIX(M8N0)jNc7t69jgFsWNeYHRlRqnDpgWtOMb4IANKbegO9mgZIvSamqmAzaUO2jzaDECmcBJulc6vhdatxwHwwGSIfW1WOLbGPlRqllqgGaUfcxNb0nkAA3tecFcLhpX4tmnFs3OOPDpri8juE8e69KGprmJYorPww5wSnsTWa51kqneJ9n5pP)tof2N07tm(etZNq1t6gfnT7jcHp54jg8jbFIygLDIsTSYTyBKAHbYRvGAig7BYFs)NCkSpP3Ny8jbFIygLDIsDyG2ZymlneJ9n5pP)tof2N07tm(KGpjKdxxwHA6EmGNqndWf1ojdqmjhfqV2jzflGRnJwgaMUScTSazac4wiCDgq5kmlDNhhJW2i1IGE1PX0LvO9jbFcvpPC4jw6o0vvN(wupHYJNy8YNyA(ezqjjThcZZnpBrqV60G3pX08jYGssAbeK7wudE)eQFsWNq1tKbLK02n0My7geEpCudE)etZNidkjPfqqUBrnVCbfFcLp5QlFc1maxu7KmaHRunxu7Kn1YlgGA5vl9yKbiT5Y7qiNvSaORmAzay6Yk0YcKbiGBHW1zaIzu2jk1cii3TiSXl4srul6C4jYBsqxu7KU6j9pEYv6RH(pj4tO6jDJIM29eHWNq5Xtm(etZN0nkAA3tecFcLhpHEpj4teZOStuQLvUfBJulmqETcudXyFt(t6)KtH9j9(eJpX08jDJIM29eHWNC8ed(KGprmJYorPww5wSnsTWa51kqneJ9n5pP)tof2N07tm(KGprmJYorPomq7zmMLgIX(M8N0)jNc7t69jgFsWNiMrzNOulMKJcOx7KAig7BYFs)NCkSpP3Ny8jbFsihUUSc109yapHAgGlQDsgGacYDlcB8cUuezflGRUKrldatxwHwwGmaxu7KmaHRunxu7Kn1YlgGA5vl9yKbiT5Y7qiNvSaU6kgTmaxu7KmabeK7we24fCPiYaW0LvOLfiRybCLrgTmamDzfAzbYaeWTq46maQEIfLbLK0iDqbyTt24ywykqn49tmnFcvpPCfMLUZJJryBKArqV60y6Yk0(KGpHQNuo8elDh6QQtFlQN0)4jgV8jMMprguss7HW8CZZwe0RoTDIYNyA(ezqjjTacYDlQTtu(eQFc1pX08ju4jLRWS0iDqbyTt24ywykqnMUScTpX08ju4jLRWS0DECmcBJulc6vNgtxwH2Nq9tc(KUrrt7EIq4tO84jgKb4IANKb4qHNyRgieZIvSIvSIvmg]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        package = "Retribution",
    } )
end