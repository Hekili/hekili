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

    spec:RegisterPack( "Retribution", 20180620.165500, [[deKUHaqieOhrbKAtcQrHiofI0QeQ6vkjnlHs7Iu)sqAycvoMqXYeONHOQPrb6AiGTHOsFtjHgNscCoLe06OakMhc6EkX(usTqkuxKcOYiruXjPaQALuqVKcO0oPqgkfqYsPaINcyQikFLcWEr6VImyuomvlMOEmHjtPldTzI8zLYOfLtRYQfeVgHYSj52IQDl53kgUs1Xvs0Yb9CunDPUoqBxaFxiJhHQZJqMpfTFvnngkzuaR3i1OGXfZkioYnyC6yixcqUXScPanr7ify3feZ3qkq55ifWabB4jd23uuGDNi14wkzua(acfifiR7DUbMqdD35nkFLwm5Hc9OqVvi5jMbIyfAGLcidEQ2aFrnMcy9gPgfmUywbXrUbJthd5saYngdsb47OGA0kghfWICbfGSSJ)SJ)SodFMfLCqv)mx03upB3feZ3WNjnWNzGGn8Kb7BQNzGYvU9kUMcSdhPtHuad0pZahXrbyJ2NHbqirpRVC8zDg(mx0d8zh)zEa)uUSc1VHUOVP4loypjVBxqS3qx03u8vxcfIYGedFdDrFtXxDjuHRujx03uj1X7ylphxMDSqySN0sF5iHbdNnkIs7tecjK8VHUOVP4RUeQWvQKl6BQK64DSLNJlIzu2jQ4VHUOVP4RUeQWvQKl6BQK64DSLNJlByHqVhi)n8n0f9nfxlMrzNOIVSp9nvSN0cjYGssAz1mwfiV1q0fTPPmOKK2dG12vBPiO3zAWDttzqjjTacYDlQb3dldkjPfqqUBrneZ9R4egKaMMTd3Ww3xoM6jzpKWfdghPVHUOVP4AXmk7ev8vxcvDBznpfcODlhRo2tAHVJkvQD4g2CT62YAEkeq7wow96LGMMKqqOF2egaRw7wlxJe)4n30e6NnHbWQ1U1Y1xTEfjaPVHUOVP4AXmk7ev8vxcLNDOYMgPuaS2qVe4BOl6BkUwmJYorfF1Lq9ayTD1wkc6DwSN0ImOKK(QvcE8RVP0G7MMeSDfwT(QvcE8RVP0y5Yk0(g6I(MIRfZOStuXxDjubeK7wm2tAjBueL2NieUEXGVHVHUOVP4APRoEgc5lbC45Ykm2YZXflpjCE7Ykm2aUcex47OsLAhUHnxBVaxHjEpW81lK30SDfwT2EbUctHaA3YXQ1y5Yk0gMVJkvQD4g2CT9cCfM49aZxVe8n0f9nfxlD1XZqiF1LqVALGh)6BQypPfzqjj9vRe84xFtPTtuzAkdkjPVALGh)6BkneZ9R4esGWzJIO0(eHW1lbnnfZOStuPrIJcW(MkXXQXsGAiM7xXjmM4cldkjPVALGh)6BkneZ9R4egdbEdDrFtX1sxD8meYxDjuK4OaSVPsCSASeySN0cFhvQu7WnS5A7f4kmX7bMt4c5dtcbBxHvRfqqUBrnwUScTMMIzu2jQ0cii3TOgI5(v81BcB8bj9n0f9nfxlD1XZqiF1LqTxGRWeVhyESN0sahEUSc1wEs482LvyyzqjjT9cCfM2bH7dh1q0f9BOl6BkUw6QJNHq(QlHAVaxHjEpW8ypPLao8CzfQT8KW5TlRWWKqW2vy1AbeK7wuJLlRqRPPygLDIkTacYDlQHyUFfF9MWgFqsFdDrFtX1sxD8meYxDj0gZ3voKNcGq7j6ypPfzqjjT9cCfM2bH7dh1q0fDysiy7kSAnsCua23ujownwcuJLlRqRPPygLDIknsCua23ujownwcudXC)k(6nHL03qx03uCT0vhpdH8vxcTX8DLd5Pai0EIo2tAHec2UcRwlGGC3IASCzfAnnfZOStuPfqqUBrneZ9R4R3e24dsAysiy7kSAnsCua23ujownwcuJLlRqRPPmOKKwab5Uf1G7HLbLK0cii3TOM3UGyegtCMMIzu2jQ0iXrbyFtL4y1yjqneZ9R4R3e24ds6B4BOl6BkUEdle69a5lbC45Ykm2YZXfYzmGyd4kqCHec2UcRwN555imnsPiO3zASCzfAnnBhUHTodDvNP3f96LGXfMezqjjThaRTR2srqVZ02jQmnLbLK0cii3TO2orfPK(g6I(MIR3WcHEpq(QlHkCLk5I(MkPoEhB554I0vhpdH8ypPLSrruAFIq46fc8g6I(MIR3WcHEpq(QlHg5edtJuY5zip2tAHecc9ZMWay1A3A5AK4hV5MMq)SjmawT2TwU(Q1bJJ0WKKnkIs7tecjCjotZSrruAFIq4smHfZOStuPLvUftJukeqEFcudXC)k(6nHL03qx03uC9gwi07bYxDjuzLBX0iLcbK3NaJ9KwYgfrP9jcHeUe00KKSrruAFIq4c5dtIygLDIkDMNNJW0iLIGENPHyUFfF9MWgFqtZao8CzfQjNXaiL03qx03uC9gwi07bYxDj0qaTB5y1XEslzJIO0(eHqcxcAAMnkIs7tecjCH8HfZOStuPLvUftJukeqEFcudXC)k(6nHn(GMMKKnkIs7tecxmyyXmk7evAzLBX0iLcbK3Na1qm3VIVEtyJpy4ao8CzfQjNXai9n0f9nfxVHfc9EG8vxcnZZZryAKsrqVZEdDrFtX1ByHqVhiF1LqftXrb07BQypPLSrruAFIqiHlbnnZgfrP9jcHeUq(WIzu2jQ0Yk3IPrkfciVpbQHyUFfF9MWgFqttsYgfrP9jcHlgmSygLDIkTSYTyAKsHaY7tGAiM7xXxVjSXhmSygLDIkDiG2TCSAneZ9R4R3e24dgoGdpxwHAYzmasFdDrFtX1ByHqVhiF1LqfUsLCrFtLuhVJT8CCr6QJNHqESN0s7kSADMNNJW0iLIGENPXYLvOnmjTd3WwNHUQZ07IMWLGXzAkdkjP9ayTD1wkc6DMgC30ugusslGGC3IAWDsdtImOKK2EbUct7GW9HJAWDttzqjjTacYDlQ5TligHXehPVHUOVP46nSqO3dKV6sOcii3TimXB4rmm2tArmJYorLwab5UfHjEdpIHArMd3qEsc6I(MYvRxIrVIeimjzJIO0(eHqcxcAAMnkIs7tecjCH8HfZOStuPLvUftJukeqEFcudXC)k(6nHn(GMMzJIO0(eHWfdgwmJYorLww5wmnsPqa59jqneZ9R4R3e24dgwmJYorLoeq7wowTgI5(v81BcB8bdlMrzNOslMIJcO33uAiM7xXxVjSXhmCahEUSc1KZyaK(g6I(MIR3WcHEpq(QlHkCLk5I(MkPoEhB554I0vhpdH83qx03uC9gwi07bYxDjubeK7weM4n8ig(g6I(MIR3WcHEpq(QlH6qHxyQhieRo2tAHelkdkjPrIJcW(MkXXQXsGAWDttsAxHvRZ88CeMgPue07mnwUScTHjPD4g26m0vDMEx0RxcgNPPmOKK2dG12vBPiO3zA7evMMYGssAbeK7wuBNOIusnnjy7kSAnsCua23ujownwcuJLlRqRPjbBxHvRZ88CeMgPue07mnwUScTKgoBueL2Nies4IbFdFdDrFtX1ZowiCj0iNyyAKsopd5VHUOVP46zhleU6sOYk3IPrkfciVpbg7jTKnkIs7tecjKaVHUOVP46zhleU6sOHaA3YXQJ9KwYgfrP9jcHesakqaeYVPOgfmUywbXrUbJthd5sGyOaroSUAJtbOaoyNnqkaWO4Ua6ua1XBoLmkWSJfcPKrnkgkzuax03uuGiNyyAKsopd5uaSCzfAPgtBQrbPKrbWYLvOLAmfqaVgHNtbYgfrP9jcHpJWNrakGl6BkkGSYTyAKsHaY7tG0MAe5PKrbWYLvOLAmfqaVgHNtbYgfrP9jcHpJWNrakGl6BkkqiG2TCSAAtBkGfLCqvtjJAumuYOaUOVPOaoypjVBxqmkawUScTuJPn1OGuYOaUOVPOaqugKyifalxwHwQX0MAe5PKrbWYLvOLAmfqaVgHNtb6lhFgHpl4Zc)SSrruAFIq4Zi8zKNc4I(MIciCLk5I(MkPoEtbuhVtLNJuGzhlesBQrgKsgfalxwHwQXuax03uuaHRujx03uj1XBkG64DQ8CKciMrzNOItBQreGsgfalxwHwQXuax03uuaHRujx03uj1XBkG64DQ8CKcSHfc9EGCAtBkWoeftUS3uYOnfqmJYorfNsg1OyOKrbWYLvOLAmfqaVgHNtbi5zYGssAz1mwfiV1q0f9ZmnFMmOKK2dG12vBPiO3zAW9NzA(mzqjjTacYDlQb3Fw4NjdkjPfqqUBrneZ9R4pJWNfKapZ08zTd3Ww3xoM6jzp8zeU8mdg3ZiLc4I(MIcSp9nfTPgfKsgfalxwHwQXuab8AeEofGVJkvQD4g2CT62YAEkeq7wow9ZwV8SGpZ08zK8mc(mOF2egaRw7wlxJe)4n)zMMpd6NnHbWQ1U1Y1x9S1pBfjWZiLc4I(MIcOUTSMNcb0ULJvtBQrKNsgfWf9nffGNDOYMgPuaS2qVeifalxwHwQX0MAKbPKrbWYLvOLAmfqaVgHNtbKbLK0xTsWJF9nLgC)zMMpJGpRDfwT(QvcE8RVP0y5Yk0sbCrFtrb8ayTD1wkc6DgTPgrakzuaSCzfAPgtbeWRr45uGSrruAFIq4ZwV8mdsbCrFtrbeqqUBrAtBkG0vhpdHCkzuJIHsgfalxwHwQXuGaUcePa8DuPsTd3WMRTxGRWeVhy(ZwV8mY)mtZN1UcRwBVaxHPqaTB5y1ASCzfAFw4NX3rLk1oCdBU2EbUct8EG5pB9YZcsbCrFtrbc4WZLvifiGdtLNJualpjCE7YkK2uJcsjJcGLlRql1ykGaEncpNcidkjPVALGh)6BkTDIQNzA(mzqjj9vRe84xFtPHyUFf)ze(mc8SWplBueL2Nie(S1lpl4ZmnFMygLDIknsCua23ujownwcudXC)k(Zi8zXe3Zc)mzqjj9vRe84xFtPHyUFf)ze(SyiafWf9nff4QvcE8RVPOn1iYtjJcGLlRql1ykGaEncpNcW3rLk1oCdBU2EbUct8EG5pJWLNr(Nf(zK8mc(S2vy1AbeK7wuJLlRq7ZmnFMygLDIkTacYDlQHyUFf)zRF2MW(S4FwWNrkfWf9nffajoka7BQehRglbsBQrgKsgfalxwHwQXuab8AeEofiGdpxwHAlpjCE7Yk8zHFMmOKK2EbUct7GW9HJAi6IMc4I(MIcyVaxHjEpWCAtnIauYOay5Yk0snMciGxJWZPabC45YkuB5jHZBxwHpl8Zi5ze8zTRWQ1cii3TOglxwH2NzA(mXmk7evAbeK7wudXC)k(Zw)SnH9zX)SGpJukGl6BkkG9cCfM49aZPn1iYLsgfalxwHwQXuab8AeEofqgussBVaxHPDq4(WrneDr)SWpJKNrWN1UcRwJehfG9nvIJvJLa1y5Yk0(mtZNjMrzNOsJehfG9nvIJvJLa1qm3VI)S1pBtyFgPuax03uuGgZ3voKNcGq7jAAtnAfPKrbWYLvOLAmfqaVgHNtbi5ze8zTRWQ1cii3TOglxwH2NzA(mXmk7evAbeK7wudXC)k(Zw)SnH9zX)SGpJ0Nf(zK8mc(S2vy1AK4OaSVPsCSASeOglxwH2NzA(mzqjjTacYDlQb3Fw4NjdkjPfqqUBrnVDbXEgHplM4EMP5ZeZOStuPrIJcW(MkXXQXsGAiM7xXF26NTjSpl(Nf8zKsbCrFtrbAmFx5qEkacTNOPnTPaByHqVhiNsg1OyOKrbWYLvOLAmfiGRarkajpJGpRDfwToZZZryAKsrqVZ0y5Yk0(mtZN1oCdBDg6QotVl6NTE5zbJ7zHFgjptguss7bWA7QTue07mTDIQNzA(mzqjjTacYDlQTtu9msFgPuax03uuGao8Czfsbc4Wu55ifGCgdG2uJcsjJcGLlRql1ykGaEncpNcKnkIs7tecF26LNrakGl6BkkGWvQKl6BQK64nfqD8ovEosbKU64ziKtBQrKNsgfalxwHwQXuab8AeEofGKNrWNb9ZMWay1A3A5AK4hV5pZ08zq)SjmawT2TwU(QNT(zbJ7zK(SWpJKNLnkIs7tecFgHlplUNzA(SSrruAFIq4ZwEwmpl8ZeZOStuPLvUftJukeqEFcudXC)k(Zw)SnH9zKsbCrFtrbICIHPrk58mKtBQrgKsgfalxwHwQXuab8AeEofiBueL2Nie(mcxEwWNzA(msEw2OikTpri8zlpJ8pl8Zi5zIzu2jQ0zEEoctJukc6DMgI5(v8NT(zBc7ZI)zbFMP5Zc4WZLvOMCgd4zK(msPaUOVPOaYk3IPrkfciVpbsBQreGsgfalxwHwQXuab8AeEofiBueL2Nie(mcxEwWNzA(SSrruAFIq4ZiC5zK)zHFMygLDIkTSYTyAKsHaY7tGAiM7xXF26NTjSpl(Nf8zMMpJKNLnkIs7tecF2YZm4Zc)mXmk7evAzLBX0iLcbK3Na1qm3VI)S1pBtyFw8pl4Zc)Sao8CzfQjNXaEgPuax03uuGqaTB5y10MAe5sjJc4I(MIcK555imnsPiO3zuaSCzfAPgtBQrRiLmkawUScTuJPac41i8Ckq2OikTpri8zeU8SGpZ08zzJIO0(eHWNr4YZi)Zc)mXmk7evAzLBX0iLcbK3Na1qm3VI)S1pBtyFw8pl4ZmnFgjplBueL2Nie(SLNzWNf(zIzu2jQ0Yk3IPrkfciVpbQHyUFf)zRF2MW(S4FwWNf(zIzu2jQ0HaA3YXQ1qm3VI)S1pBtyFw8pl4Zc)Sao8CzfQjNXaEgPuax03uuaXuCua9(MI2uJwbuYOay5Yk0snMciGxJWZPaTRWQ1zEEoctJukc6DMglxwH2Nf(zK8S2HByRZqx1z6Dr)mcxEwW4EMP5ZKbLK0EaS2UAlfb9otdU)mtZNjdkjPfqqUBrn4(Zi9zHFgjptgussBVaxHPDq4(Wrn4(ZmnFMmOKKwab5Uf182fe7ze(SyI7zKsbCrFtrbeUsLCrFtLuhVPaQJ3PYZrkG0vhpdHCAtnAfsjJcGLlRql1ykGaEncpNciMrzNOslGGC3IWeVHhXqTiZHBipjbDrFt5QNTE5zXOxrc8SWpJKNLnkIs7tecFgHlpl4ZmnFw2OikTpri8zeU8mY)SWptmJYorLww5wmnsPqa59jqneZ9R4pB9Z2e2Nf)Zc(mtZNLnkIs7tecF2YZm4Zc)mXmk7evAzLBX0iLcbK3Na1qm3VI)S1pBtyFw8pl4Zc)mXmk7ev6qaTB5y1AiM7xXF26NTjSpl(Nf8zHFMygLDIkTykokGEFtPHyUFf)zRF2MW(S4FwWNf(zbC45YkutoJb8msPaUOVPOacii3TimXB4rmK2uJIjokzuaSCzfAPgtbCrFtrbeUsLCrFtLuhVPaQJ3PYZrkG0vhpdHCAtnkMyOKrbCrFtrbeqqUBryI3WJyifalxwHwQX0MAumbPKrbWYLvOLAmfqaVgHNtbi5zwugussJehfG9nvIJvJLa1G7pZ08zK8S2vy16mpphHPrkfb9otJLlRq7Zc)msEw7WnS1zOR6m9UOF26LNfmUNzA(mzqjjThaRTR2srqVZ02jQEMP5ZKbLK0cii3TO2or1Zi9zK(mtZNrWN1UcRwJehfG9nvIJvJLa1y5Yk0(mtZNrWN1UcRwN555imnsPiO3zASCzfAFgPpl8ZYgfrP9jcHpJWLNzqkGl6BkkGdfEHPEGqSAAtBAtBAtP]] )


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