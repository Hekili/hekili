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

        blade_of_wrath = {
            id = 281178,
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

        divine_right = {
            id = 278523,
            duration = 10,
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

        fires_of_justice = {
            id = 209785,
            duration = 15,
            max_stack = 1,
            copy = "the_fires_of_justice" -- backward compatibility
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

        righteous_verdict = {
            id = 267611,
            duration = 6,
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
                removeBuff( "blade_of_wrath" )
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
            cooldown = function () return 6 * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste end,
            recharge = function () return 6 * ( talent.fires_of_justice.enabled and 0.85 or 1 ) * haste end,
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
            charges = function () return talent.cavalier.enabled and 2 or nil end,
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

                if level < 116 then
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
            gcd = "off",

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

    
    spec:RegisterPack( "Retribution", 20180717.0135, [[dCK8WaqiefpsuQSjfYNqGIgLOsNsuvRIurVcrPzPOCleif7sOFrQ0WquDmsvldrEMOOPPq11qO2MOGVjk04ivW5iviRtr18evCpbTpkWbrGu1crq9qei5IiqLpIaPYirG4KiqHvIqMjcKs7ebmueO0sjvOEkPmvrjFvuQAVI8xunykDyQwmk9yctMOlRAZO4Zky0u0PvA1IQ8AkOztYTfy3s9BqdhqhxuklhYZHA6sUoqBNc9Dfz8iiNxHY6rGQMpa7hPt6tzL0KE9ebirUEDG8mQpJrY1NzgipdjTAmGpPb0fg6dpP1EWtA64xOLfSwyN0a6JPGUmLvsddbrIN0mRciEUU6oSLjiBuad0fVbGkVwylqotPlEde6YQGS6YY4e0iVrDbIGmR6yDZApIKEDZIKEobRRC52CD8l0YcwlSJ4nqK0ybxvrWOtSjnPxprasKRxhipJ6ZyKC9zsI04jnmWlseiJKN0KhlsAzzUyQDXuBzEQvEghuvuRlQf2ulqxyOpCQLbIOwD8l0YcwlSPwcwx5YTXrkruIYY8OtTo6ulW3YThOwqGsVoMAzGiQvh)cTSG1cBQLG1vUC7zullyrTBrTtRsrTONnWfDQfddo16s5wlSDf1kGYThOw2ZarNAlZtTemXpBGVfNGj1YCVarNAxm1Ubavp4DDj1wMErTL5PwD8lQLGEcwcAPwq8XrQLAjy0uBzEQn4ExBWNrT4NnW3IJP2PvPOw2tT7qdrxgtAarqMv9KMlQf24qhSGCVkxyiLixulSXKnux0zbn8uICrTWgt2qDfUsXDrTWMRwCnR9Ghcb((ikrUOwyJjBOUcxP4UOwyZvlUM1EWdfqOscNAmLixulSXKnuxHRuCxulS5QfxZAp4HdVpYlictjIsKlQf24Oacvs4uJdbcRf2ZwMWCzbzyISkiuQaXveDxuaaWcYWeDJVh2EGpH8YmcceaawqgMOabID5JGahXcYWefiqSlFe9aFBCoKigaGYrdVI1gCEb5Y95eoo55tjYf1cBCuaHkjCQXKnux1oywyEEGYHG31SLjed8kfVC0WlCuTdMfMNhOCi4DzqijaaYLmiFL8B8DfDPehpHwCHbaa5RKFJVROlL442gKrIZNsKlQf24Oacvs4uJjBOUyZ9kjhYWn(E4EloLixulSXrbeQKWPgt2qDDJVh2EGpH8YC2YeYcYWe3oBGlERf2rqGaaqMYvVR42zdCXBTWo(2zvxsjYf1cBCuaHkjCQXKnuxbce7YpBzcnHQX4aHthzq44uIOe5IAHnoYS9InpchA0rRZQ(S2dEOeZfoUCw1Nz0vGped8kfVC0WlCuUg3(CCbrbgeMjaaLRExr5AC7ZZduoe8UIVDw1LJWaVsXlhn8chLRXTphxquGbHKaaWj4pARhLRXTphTdMv8TZQUCu5OHxrZ7QYmcuu5esI8rSGmmr5AC7Zr7GzfLWPMsKlQf24iZ2l28imzd1D7SbU4TwypBzczbzyIBNnWfV1c7Oeo1aaWcYWe3oBGlERf2r0d8TX5q8itOAmoq40rgeMjaaLRExXtOlaRf2C876T4X3oR6YrciujHtD8e6cWAHnh)UElEe9aFBCo6jFelidtC7SbU4TwyhrpW3gNJEIPe5IAHnoYS9Inpct2qDpHUaSwyZXVR3IpBzcXaVsXlhn8chLRXTphxquqoHzokxYuU6DffiqSlF8TZQUeaabeQKWPokqGyx(i6b(2ydgesDskFkrUOwyJJmBVyZJWKnux5AC7ZXfefmBzcn6O1zvpkXCHJlNv9rSGmmr5AC7ZbcIacXpIUlkkrUOwyJJmBVyZJWKnux5AC7ZXfefmBzcn6O1zvpkXCHJlNv9r5sMYvVROabID5JVDw1LaaiGqLeo1rbce7YhrpW3gBWGqQts5tjYf1cBCKz7fBEeMSH6wpaOYryUXJKROMTmHSGmmr5AC7ZbcIacXpIUlQr5sMYvVR4j0fG1cBo(D9w84BNvDjaaciujHtD8e6cWAHnh)UElEe9aFBSbdcz(uICrTWghz2EXMhHjBOU1daQCeMB8i5kQzltyUKPC17kkqGyx(4BNvDjaaciujHtDuGaXU8r0d8TXgmiK6Ku(JYLmLRExXtOlaRf2C876T4X3oR6saaybzyIcei2LpccCelidtuGaXU8rC5cdZrp5aaiGqLeo1XtOlaRf2C876T4r0d8TXgmiK6Ku(uIOe5IAHnoo8(iVGiCOrhToR6ZAp4Heey2pZORaFyUKPC17kA6bbhXHm8jKxMX3oR6saakhn8kAExvMrGIYGqsKpkxwqgMOB89W2d8jKxMrjCQbaGfKHjkqGyx(Oeo15NpLixulSXXH3h5feHjBOUcxP4UOwyZvlUM1EWdz2EXMhHNTmHMq1yCGWPJmiKykrUOwyJJdVpYlict2qDNCdphYWDS5XZwMWCjdYxj)gFxrxkXXtOfxyaaq(k5347k6sjoUTbKip)r5AcvJXbcNokNqYbaWeQgJdeoDuO(rciujHtDKv5YZHm88aX1kEe9aFBSbdcz(uICrTWghhEFKxqeMSH6YQC55qgEEG4AfF2YeAcvJXbcNokNqsaaKRjunghiC6OWmhLRacvs4uhn9GGJ4qg(eYlZi6b(2ydgesDscaaJoADw1Jeey2NF(uICrTWghhEFKxqeMSH6MhOCi4DnBzcnHQX4aHthLtijaaY1eQgJdeoDuoHJpkxbeQKWPoYQC55qgEEG4AfpIEGVn2GbHuNKaaWOJwNv9ibbM95NpLixulSXXH3h5feHjBOUMEqWrCidFc5L5SLj0eQgJdeoDuoHJtjYf1cBCC49rEbryYgQRa24lqETWE2YeAcvJXbcNokNqsaaycvJXbcNokNWmhjGqLeo1rwLlphYWZdexR4r0d8TXgmiK6KeaaMq1yCGWPJchFKacvs4uhzvU8CidppqCTIhrpW3gBWGqQtsJeqOscN6yEGYHG3ve9aFBSbdcPojrjYf1cBCC49rEbryYgQRWvkUlQf2C1IRzTh8qMTxS5r4zlty5Q3v00dcoIdz4tiVmJVDw1LJYTC0WRO5DvzgbkQCcjroaaSGmmr347HTh4tiVmJGabaGfKHjkqGyx(iiW8hLllidtuUg3(CGGiGq8JGabaGfKHjkqGyx(iUCHH5ON88Pe5IAHnoo8(iVGimzd1vGaXU8ioUqRHF2YekGqLeo1rbce7YJ44cTg(OW0rdhZzqUOwy7kdc1hZiXJY1eQgJdeoDuoHKaaWeQgJdeoDuoHzosaHkjCQJSkxEoKHNhiUwXJOh4BJnyqi1jjaamHQX4aHthfo(ibeQKWPoYQC55qgEEG4AfpIEGVn2GbHuNKgjGqLeo1X8aLdbVRi6b(2ydgesDsAKacvs4uhfWgFbYRf2r0d8TXgmiK6Ku(uICrTWghhEFKxqeMSH6kCLI7IAHnxT4Aw7bpKz7fBEeMsKlQf244W7J8cIWKnuxbce7YJ44cTg(zltOjunghiC6OCchNsKlQf244W7J8cIWKnuxhj8(8cIqVRzltyUYZcYWepHUaSwyZXVR3IhbbcaqULRExrtpi4ioKHpH8Ym(2zvxok3YrdVIM3vLzeOOmiKe5aaWcYWeDJVh2EGpH8YmkHtnaaSGmmrbce7YhLWPo)8baGmLRExXtOlaRf2C876T4X3oR6saait5Q3v00dcoIdz4tiVmJVDw1L5pYeQgJdeoDuoHJtjIsKlQf24ie47JcXpBGVfF2YewU6DfNCdphYWDS5XX3oR6YrLRExrbce7YhF7SQlhvU6DfpHUaSwyZXVR3IhF7SQlhrMYvVROPheCehYWNqEzgF7SQlN1EWdNCdphc89rCconobL2CS5ELKdz4gFpCVfFoRYLNdz45bIRv855bkhcExZfiqSl)86bavocZnEKCf18j3WZHmChBE886bavocZnEKCf1Cbce7YJ44cTg(5NqxawlS5431BXPe5IAHnocb((iYgQl(zd8T4ZwMWYvVR4KB45qgUJnpo(2zvxoQC17kkqGyx(4BNvD5iYuU6DfpHUaSwyZXVR3IhF7SQlhrMYvVROPheCehYWNqEzgF7SQlN1EWdNCdphc89rCckT5yZ9kjhYWn(E4El(CwLlphYWZdexR4ZZduoe8UMlqGyx(51daQCeMB8i5kQ5tUHNdz4o28451daQCeMB8i5kQ5cei2LhXXfAn8ZRhau5im34rYvuuICrTWghHaFFezd1f)Sb(w8zlty5Q3vCYn8Cid3XMhhF7SQlhvU6DffiqSlF8TZQUCu5Q3v8e6cWAHnh)UElE8TZQUCu5Q3v00dcoIdz4tiVmJVDw1LZAp4HtUHNdb((iobNgNGaZ(5yZ9kjhYWn(E4El(CwLlphYWZdexR4ZZduoe8UMlqGyx(51daQCeMB8i5kQ5tUHNdz4o28451daQCeMB8i5kQ5MEqWrCidFc5L58tOlaRf2C876T4uICrTWghHaFFezd1f)Sb(w8zlty5Q3vCYn8Cid3XMhhF7SQlhvU6DffiqSlF8TZQUCezkx9UINqxawlS5431BXJVDw1LJkx9UIMEqWrCidFc5Lz8TZQUCw7bpCYn8CiW3hXjiWSFo2CVsYHmCJVhU3IpNv5YZHm88aX1k(88aLdbVR5cei2LFE9aGkhH5gpsUIA(KB45qgUJnpEE9aGkhH5gpsUIAUPheCehYWNqEzoVEaqLJWCJhjxrrjIsK5DzOAhmlm3O3dGosYnVky2kd1tmj9eRFglSbX8vgMzg0tsx9etojkr9fggkm9T5qgEzEoyh4gE0SvgQNysK0HmNXcBqmFLHzMb9K0vpXKtA2BHP3fFLHeRd6iYPeHnHGk5r4q1oywyUrVhaDKKJnHGk5ravED8SvgQNys6joZzSWgeZxzyMzqpjD1tm5KOeX6cddNmxmWJ4qgEzEE7Lj6e8BWSvgQpZmsojYNXcBqmFLHzMHmjF2BHP3fFLHepEMJtjsyECfQ2bZcZn69aOJKCw0DCbu51NTYq9ets)46WmwydI5RmmZmONKU6jMCsuIMqlUWHg9awKloMdz4QL5yUJXGiVfF2kd1tmjYjL5mwydI5RmmZmONKU6jMCsuIm9wIdv7GzH5g9Ea0rs(Gd2L6fE2kd1tmj9et(mwydI5RmmZmONKU6jMCsuIM8fxHdiylz8Y8i(WIKQpBLH6jMe5KinJf2Gy(kdZmd6jPREIjNeLi1hWHcioaIfGk12dC1haQ864zRmupXKixFgMXcBqmFLHzMb9K0vpXKtIseZFfYcI6Th4cOX3CSZ6fSXZwzOEIjrUEYNXcBqmFLHzMb9K0vpXKtIseZ2dhPpedQu7LC8DfhYWlZZb6DzEypBLH6jwVokJKMXcBqmFLHzMb9K0vpXKtA2BHP3fFLHepojDeLiMThoIuigcQ4qgEzEU5oyQGi5SvgQNy9zy8XNXcBqmFLHzMHmjF2Wd4RmupX6jwhgF2BHP3fFLHepojDeLOcTTHV0hI)bU9ahlGGOHpT9WSvgQNy96Omm(mwydI5RmmZmONKU6jMCsuIk02g(IuOh4DzcQWCJlEH9SvgQN4X1NrsZyHniMVYWXjPptkrb(2CtVLHo2KfT9WrZwzOEsKRJYOomJf2Gy(kdZyMzC2Wd4RmupXeRdeRxx9etI8m1bD1tmX6aX6NHUAf8vgMzg0tAUEI1ts3mZGEsZ1tm5K0nZmON0C9eRNeLikrzh1sq3De1Qbge4OXOeLDu7WDeFvgvHKgNuuFMuIYoQD4oIJl07HYmmdzCCkrzh1oChXXLhSThQN04Jtjk7O2H7iUaTfh512dHzMXmqjk7O2H7iUPJRZrET9q4461bkrzh1oChXdCCD0yCKxBpeoUoKrkrzh1oChXnEe2RvT1yCKxBpeskJzsjk7O2H7iUJcGOqDiJJtjk7Ow8lolSbXH1Eej9CsafH6PeLDul(fNf2G4WApIKE(4afH6tAgpcVWorasKRxhipdKif1NrIjL0MCuV9aoPL0ulUWPSsAqGVpkLvIa6tzL0E7SQlteoP5IAHDsd)Sb(w8Kw7bpPn5gEoe47J4eCACckT5yZ9kjhYWn(E4El(CwLlphYWZdexR4ZZduoe8UMlqGyx(51daQCeMB8i5kQ5tUHNdz4o28451daQCeMB8i5kQ5cei2LhXXfAn8ZpHUaSwyZXVR3IN0eOToA9Kw5Q3vCYn8Cid3XMhhF7SQlP2ruB5Q3vuGaXU8X3oR6sQDe1wU6DfpHUaSwyZXVR3IhF7SQlP2rulzO2YvVROPheCehYWNqEzgF7SQltvIaKszL0E7SQlteoP5IAHDsd)Sb(w8Kw7bpPn5gEoe47J4euAZXM7vsoKHB89W9w85SkxEoKHNhiUwXNNhOCi4DnxGaXU8ZRhau5im34rYvuZNCdphYWDS5XZRhau5im34rYvuZfiqSlpIJl0A4NxpaOYryUXJKROsAc0whTEsRC17ko5gEoKH7yZJJVDw1Lu7iQTC17kkqGyx(4BNvDj1oIAjd1wU6DfpHUaSwyZXVR3IhF7SQlP2rulzO2YvVROPheCehYWNqEzgF7SQltvIazMYkP92zvxMiCsZf1c7Kg(zd8T4jT2dEsBYn8CiW3hXj404eey2phBUxj5qgUX3d3BXNZQC55qgEEG4AfFEEGYHG31Cbce7YpVEaqLJWCJhjxrnFYn8Cid3XMhpVEaqLJWCJhjxrn30dcoIdz4tiVmNFcDbyTWMJFxVfpPjqBD06jTYvVR4KB45qgUJnpo(2zvxsTJO2YvVROabID5JVDw1Lu7iQTC17kEcDbyTWMJFxVfp(2zvxsTJO2YvVROPheCehYWNqEzgF7SQltvIaJNYkP92zvxMiCsZf1c7Kg(zd8T4jT2dEsBYn8CiW3hXjiWSFo2CVsYHmCJVhU3IpNv5YZHm88aX1k(88aLdbVR5cei2LFE9aGkhH5gpsUIA(KB45qgUJnpEE9aGkhH5gpsUIAUPheCehYWNqEzoVEaqLJWCJhjxrL0eOToA9Kw5Q3vCYn8Cid3XMhhF7SQlP2ruB5Q3vuGaXU8X3oR6sQDe1sgQTC17kEcDbyTWMJFxVfp(2zvxsTJO2YvVROPheCehYWNqEzgF7SQltvQsAYZ4GQkLvIa6tzL0CrTWoP5GfK7v5cdtAVDw1LjcNQebiLYkP5IAHDsdDwqdFs7TZQUmr4uLiqMPSsAVDw1LjcN0CrTWoPjCLI7IAHnxT4kPPwCXBp4jniW3hLQebgpLvs7TZQUmr4KMlQf2jnHRuCxulS5Qfxjn1IlE7bpPjGqLeo14uLiaXPSsAVDw1LjcN0CrTWoPjCLI7IAHnxT4kPPwCXBp4jTH3h5feHtvQsAarxady9kLvQsAciujHtnoLvIa6tzL0E7SQlteoPjqBD06jTCPwwqgMiRccLkqCfr3ff1caa1YcYWeDJVh2EGpH8YmccKAbaGAzbzyIcei2LpccKAhrTSGmmrbce7YhrpW3gtT5qTKiMAbaGAlhn8kwBW5fKl3tT5esTJto1MFsZf1c7KgqyTWovjcqkLvs7TZQUmr4KMaT1rRN0WaVsXlhn8chv7GzH55bkhcExuRbHuljQfaaQnxQLmulYxj)gFxrxkXXtOfxyQfaaQf5RKFJVROlL442uRbuBgjMAZpP5IAHDstTdMfMNhOCi4DLQebYmLvsZf1c7Kg2CVsYHmCJVhU3IN0E7SQlteovjcmEkRK2BNvDzIWjnbARJwpPXcYWe3oBGlERf2rqGulaaulzO2YvVR42zdCXBTWo(2zvxM0CrTWoP5gFpS9aFc5LzQseG4uwjT3oR6YeHtAc0whTEsZeQgJdeoDe1Aqi1oEsZf1c7KMabID5tvQsAmBVyZJWPSseqFkRK2BNvDzIWjnJUc8jnmWRu8YrdVWr5AC7ZXfefqTgesTzsTaaqTLRExr5AC7ZZduoe8UIVDw1Lu7iQfd8kfVC0WlCuUg3(CCbrbuRbHuljQfaaQ1j4pARhLRXTphTdMv8TZQUKAhrTLJgEfnVRkZiqrrT5esTKiNAhrTSGmmr5AC7Zr7GzfLWPoP5IAHDsZOJwNv9KMrhXBp4jnjMlCC5SQNQebiLYkP92zvxMiCstG26O1tASGmmXTZg4I3AHDucNAQfaaQLfKHjUD2ax8wlSJOh4BJP2COwIP2ruRjunghiC6iQ1GqQntQfaaQTC17kEcDbyTWMJFxVfp(2zvxsTJOwbeQKWPoEcDbyTWMJFxVfpIEGVnMAZHA1to1oIAzbzyIBNnWfV1c7i6b(2yQnhQvpXjnxulStABNnWfV1c7uLiqMPSsAVDw1LjcN0eOToA9Kgg4vkE5OHx4OCnU954cIcO2CcP2mP2ruBUulzO2YvVROabID5JVDw1LulaauRacvs4uhfiqSlFe9aFBm1Aa1oiKuRoPwsuB(jnxulStANqxawlS5431BXtvIaJNYkP92zvxMiCstG26O1tAgD06SQhLyUWXLZQo1oIAzbzyIY142NdeebeIFeDxujnxulStAY142NJlikivjcqCkRK2BNvDzIWjnbARJwpPz0rRZQEuI5chxoR6u7iQnxQLmuB5Q3vuGaXU8X3oR6sQfaaQvaHkjCQJcei2LpIEGVnMAnGAhesQvNuljQn)KMlQf2jn5AC7ZXfefKQebYqkRK2BNvDzIWjnbARJwpPXcYWeLRXTphiicie)i6UOO2ruBUulzO2YvVR4j0fG1cBo(D9w84BNvDj1caa1kGqLeo1XtOlaRf2C876T4r0d8TXuRbu7GqsT5N0CrTWoPvpaOYryUXJKROsvIazmLvs7TZQUmr4KMaT1rRN0YLAjd1wU6DffiqSlF8TZQUKAbaGAfqOscN6OabID5JOh4BJPwdO2bHKA1j1sIAZNAhrT5sTKHAlx9UINqxawlS5431BXJVDw1LulaaullidtuGaXU8rqGu7iQLfKHjkqGyx(iUCHHuBouREYPwaaOwbeQKWPoEcDbyTWMJFxVfpIEGVnMAnGAhesQvNuljQn)KMlQf2jT6bavocZnEKCfvQsvsB49rEbr4uwjcOpLvs7TZQUmr4KMrxb(KwUulzO2YvVROPheCehYWNqEzgF7SQlPwaaO2YrdVIM3vLzeOOOwdcPwsKtTJO2CPwwqgMOB89W2d8jKxMrjCQPwaaOwwqgMOabID5Js4utT5tT5N0CrTWoPz0rRZQEsZOJ4Th8KgbbM9PkrasPSsAVDw1LjcN0eOToA9KMjunghiC6iQ1GqQL4KMlQf2jnHRuCxulS5Qfxjn1IlE7bpPXS9InpcNQebYmLvs7TZQUmr4KMaT1rRN0YLAjd1I8vYVX3v0LsC8eAXfMAbaGAr(k5347k6sjoUn1Aa1sICQnFQDe1Ml1AcvJXbcNoIAZjKAjNAbaGAnHQX4aHthrTHuREQDe1kGqLeo1rwLlphYWZdexR4r0d8TXuRbu7GqsT5N0CrTWoPn5gEoKH7yZJtvIaJNYkP92zvxMiCstG26O1tAMq1yCGWPJO2CcPwsulaauBUuRjunghiC6iQnKAZKAhrT5sTciujHtD00dcoIdz4tiVmJOh4BJPwdO2bHKA1j1sIAbaGAn6O1zvpsqGzp1Mp1MFsZf1c7KgRYLNdz45bIRv8uLiaXPSsAVDw1LjcN0eOToA9KMjunghiC6iQnNqQLe1caa1Ml1AcvJXbcNoIAZjKAhNAhrT5sTciujHtDKv5YZHm88aX1kEe9aFBm1Aa1oiKuRoPwsulaauRrhToR6rccm7P28P28tAUOwyN0Yduoe8UsvIaziLvs7TZQUmr4KMaT1rRN0mHQX4aHthrT5esTJN0CrTWoPz6bbhXHm8jKxMPkrGmMYkP92zvxMiCstG26O1tAMq1yCGWPJO2CcPwsulaauRjunghiC6iQnNqQntQDe1kGqLeo1rwLlphYWZdexR4r0d8TXuRbu7GqsT6KAjrTaaqTMq1yCGWPJO2qQDCQDe1kGqLeo1rwLlphYWZdexR4r0d8TXuRbu7GqsT6KAjrTJOwbeQKWPoMhOCi4DfrpW3gtTgqTdcj1QtQLusZf1c7KMa24lqETWovjcOdPSsAVDw1LjcN0eOToA9Kw5Q3v00dcoIdz4tiVmJVDw1Lu7iQnxQTC0WRO5DvzgbkkQnNqQLe5ulaaullidt0n(Ey7b(eYlZiiqQfaaQLfKHjkqGyx(iiqQnFQDe1Ml1YcYWeLRXTphiicie)iiqQfaaQLfKHjkqGyx(iUCHHuBouREYP28tAUOwyN0eUsXDrTWMRwCL0ulU4Th8KgZ2l28iCQseqhLYkP92zvxMiCstG26O1tAciujHtDuGaXU8ioUqRHpkmD0WXCgKlQf2UIAniKA1hZiXu7iQnxQ1eQgJdeoDe1Mti1sIAbaGAnHQX4aHthrT5esTzsTJOwbeQKWPoYQC55qgEEG4AfpIEGVnMAnGAhesQvNuljQfaaQ1eQgJdeoDe1gsTJtTJOwbeQKWPoYQC55qgEEG4AfpIEGVnMAnGAhesQvNuljQDe1kGqLeo1X8aLdbVRi6b(2yQ1aQDqiPwDsTKO2ruRacvs4uhfWgFbYRf2r0d8TXuRbu7GqsT6KAjrT5N0CrTWoPjqGyxEehxO1WNQeb0tEkRK2BNvDzIWjnxulStAcxP4UOwyZvlUsAQfx82dEsJz7fBEeovjcOxFkRK2BNvDzIWjnbARJwpPzcvJXbcNoIAZjKAhpP5IAHDstGaXU8ioUqRHpvjcONukRK2BNvDzIWjnbARJwpPLl1kplidt8e6cWAHnh)UElEeei1caa1Ml1wU6Dfn9GGJ4qg(eYlZ4BNvDj1oIAZLAlhn8kAExvMrGIIAniKAjro1caa1YcYWeDJVh2EGpH8YmkHtn1caa1YcYWefiqSlFucNAQnFQnFQfaaQLmuB5Q3v8e6cWAHnh)UElE8TZQUKAbaGAjd1wU6Dfn9GGJ4qg(eYlZ4BNvDj1Mp1oIAnHQX4aHthrT5esTJN0CrTWoP5iH3Nxqe6DLQuLQKMdwMqustBdiOsvQsj]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        potion = "potion_of_bursting_blood",
        
        package = "Retribution",
    } )
end
