-- PaladinRetribution.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


local PTR = ns.PTR


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
            duration = function () return azerite.lights_decree.enabled and 25 or 20 end,
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
            tick_time = 6,
            shared = "player", -- check for anyone's buff on the player.
        },

        greater_blessing_of_wisdom = {
            id = 203539,
            duration = 3600,
            max_stack = 1,
            tick_time = 10,
            shared = "player", -- check for anyone's buff on the player.
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

        selfless_healer = {
            id = 114250,
            duration = 15,
            max_stack = 4,
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

        zeal = {
            id = 217020,
            duration = 12,
            max_stack = 3
        },


        -- Azerite Powers
        empyreal_ward = {
            id = 287731,
            duration = 60,
            max_stack = 1,
        },

        empyrean_power = {
            id = 286393,
            duration = 15,
            max_stack = 1
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
                applyBuff( 'avenging_wrath' )
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
                if buff.empyrean_power.up then return 0 end
                return 3 - ( buff.fires_of_justice.up and 1 or 0 ) - ( buff.hidden_retribution_t21_4p.up and 1 or 0 )
            end,
            spendType = "holy_power",
            
            startsCombat = true,
            texture = 236250,
            
            handler = function ()
                if buff.empyrean_power.up then removeBuff( 'empyrean_power' )
                elseif buff.divine_purpose.up then removeBuff( 'divine_purpose' )
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
            
            startsCombat = false,
            texture = 135993,
            
            usable = function () return active_dot.greater_blessing_of_kings == 0 end,
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
            
            startsCombat = false,
            texture = 135912,
            
            usable = function () return active_dot.greater_blessing_of_wisdom == 0 end,
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
                if azerite.empyreal_ward.enabled then applyBuff( "empyreal_ward" ) end
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
            
            debuff = "casting",
            readyTime = state.timeToInterrupt,

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

    
    spec:RegisterPack( "Retribution", 20190201.1040, [[dKuAibqiIkEKss1MKk(KOuzuev5uev1QuQKxPuXSikDlKuv7IWVqknmPsogrXYqsEMOuMgrLUgskBtuQY3effJtuu5CIsvToLQMNsQUNszFifhujPKfkvQhQKuCrLkL2isQu(isQunsKuLtIKkzLirZuPsXofLmurrPLQuP6PiAQIcxvuu1xrsf7LI)kyWu1HjTyeEmktMsxgAZs5Zcz0kXPvz1kP8AKWSf52ez3s(TQgUqDCrrwoWZbnDfxNkBhP67IQXRKKZRKy9kjLA(sv7hvBKXKHH0QdAYIQUKj73fvDjJGkQKBxulZziNvIrdzSYOqJqdzPsOHC3XbCeU5(YqgRRKE1AYWqcFhGHgYLzIH7PL2OBwCec2lrl8KCjDUVyaTn0cpjgTePNGwIMs9TiDAJbF7siK2moeqLm0MbvYeYSAsTxf2DCahHBUVeWtIzijCxAOUkdHH0QdAYIQUKj73fvDjJGkQKBxul7ziHXiZKvMPld5YzTyzimKweYmKRo3V74aoc3CFX9zwnP2R4uU6C)YmXW90sB0nlocb7LOfEsUKo3xmG2gAHNeJwI0tqlrtP(wKoTXGVDjesBMfG7UEwiTz2DpKz1KAVkS74aoc3CFjGNeJt5QZ9u3qcGtbRW9Yil3tvxYK95EQp3tvx7ZMmCk5uU6C)QzrRieUNt5QZ9uFUpZhB1bTC)aUIcCGcdzm4BxcnKRo3V74aoc3CFX9zwnP2R4uU6C)YmXW90sB0nlocb7LOfEsUKo3xmG2gAHNeJwI0tqlrtP(wKoTXGVDjesBMfG7UEwiTz2DpKz1KAVkS74aoc3CFjGNeJt5QZ9u3qcGtbRW9Yil3tvxYK95EQp3tvx7ZMmCk5uU6C)QzrRieUNt5QZ9uFUpZhB1bTC)aUIcCGcoLCkxDUF3UkK5g0Y9ey7bi3ZEjcD4Ecm6kOG7xTymmEGCF9f1FrbsnxI7v2CFb5(VsRi4uQS5(ckIbi7Li0zRLuifCkv2CFbfXaK9se6SZgTT)TCkv2CFbfXaK9se6SZgTQlscRrN7loLRo3twAmC5hUhONL7jCTgA5E4OdK7jW2dqUN9se6W9ey0vqUxll3hdqQF8pZvrC)b5E7xOGtPYM7lOigGSxIqND2OfwAmC5NaC0bYPuzZ9fuedq2lrOZoB0g)Z9fNsLn3xqrmazVeHo7SrRcyAHH5baSgzV2MCgnH1iYvkWW3ckCbHcSuIeA5uYPC15(D7QqMBql3J0rWkC)Csi3pli3RS5bC)b5ELUEjLiHcoLkBUVGBQB(GoJYOGtPYM7l4oB0cqchfiNsLn3xWD2OLPPuqzZ9viDWr2sLWTpgleWPuzZ9fCNnAzAkfu2CFfshCKTujCJ9FY(5fKtPYM7l4oB0Y0ukOS5(kKo4iBPs4wewiqNha5uYPuzZ9fuW(pz)8cU5Gy4gus2sLWnGkfFvuqLIt34Syi6Iu6FAcyfDfk712KhHR1ekDSIUkkKd0zr4I77jCTMGbCq1IcxS85uQS5(cky)NSFEb3zJwhed3GsYwQeUfb(kcgIbNKMcancL9ABYHW1AcLowrxffYb6SiCXDKdHR1emGdQwu4I5uQS5(cky)NSFEb3zJwhed3GsYwQeUb0vBRROagiUOaaTbc3mFXPuzZ9fuW(pz)8cUZgToigUbLKTujCBnegw(8ecK9ABeUwtO0Xk6QOqoqNfHlUVNW1AcgWbvlkCXDiCTMGbCq1Ic4Omk2KPloLkBUVGc2)j7NxWD2O1bXWnOKSLkHB0pnf(wqRtsh0gis)BL9ABYJW1AcLowrxffYb6SiCX99eUwtWaoOArHlUdHR1emGdQwuaqj9k46YK5KFFV8y)NSFEju6yfDvuihOZIaGs6vqAYwx99S)t2pVemGdQwuaqj9kinzRl5ZPuzZ9fuW(pz)8cUZgToigUbLKTujCZ(Vem0CGvK9ABeUwtO0Xk6QOqoqNfHlUVNW1AcgWbvlkCXDiCTMGbCq1IcakPxbxxMmhNsLn3xqb7)K9Zl4oB06Gy4gus2sLWTinHmnLqamqGkfYETncxRju6yfDvuihOZIWf33t4Anbd4GQffU4oeUwtWaoOArbaL0RGRld14uQS5(cky)NSFEb3zJwhed3GsYwQeUrSs0xyGaXGMK0szYETncxRju6yfDvuihOZIWf33t4Anbd4GQffUyoLkBUVGc2)j7NxWD2O1bXWnOKSLkHBsiaPywuyOPvKSxBtEYbONnG0XAeQ1cf4Qo4a77b6zdiDSgHATqXv0id1KFFpmgtPWOGiCGc7r)kmaNhirZgvCkv2CFbfS)t2pVG7SrRdIHBqjzlvc3ItUYIacubwyOLuifYETncxRju6yfDvuihOZIWf33t4Anbd4GQffU4oeUwtWaoOArbCugf0Sjtx99S)t2pVekDSIUkkKd0zraqj9kinYLA99YHW1AcgWbvlkCXDy)NSFEjyahuTOaGs6vqAKl14uQS5(cky)NSFEb3zJwhed3GsYwQeUrGaicOabWWAU1CYETncxRju6yfDvuihOZIWf33t4Anbd4GQffU4oeUwtWaoOArbCugf0Sjtx99S)t2pVekDSIUkkKd0zraqj9kinYLA99YHW1AcgWbvlkCXDy)NSFEjyahuTOaGs6vqAKl14uQS5(cky)NSFEb3zJwhed3GsYwQeUHLnHqyyUInoag(wObu2CFPPq8NJazV2gHR1ekDSIUkkKd0zr4I77jCTMGbCq1IcxChcxRjyahuTOaokJcA2KPR(E2)j7NxcLowrxffYb6SiaOKEfKg5sT(E2)j7NxcgWbvlkaOKEfKg5snoLkBUVGc2)j7NxWD2O1bXWnOKSLkHBXOcsb7rhbWa7LIviu2RTr4AnHshRORIc5aDweU4(EcxRjyahuTOWf3HW1AcgWbvlkGJYOGMnz6ItPYM7lOG9FY(5fCNnADqmCdkjBPs4w7aWjiPdcdW4vIskek712iCTMqPJv0vrHCGolcxCFpHR1emGdQwu4I7q4Anbd4GQffausVcU(MmuJtPYM7lOG9FY(5fCNnADqmCdkjBPs4w(Ybs5xfbdXjNKgHYETncxRju6yfDvuihOZIWf33t4Anbd4GQffU4oeUwtWaoOArbaL0RGRVrvxCkv2CFbfS)t2pVG7SrRdIHBqjzlvc3SauTHOKApDEamqO2iu2RTr4AnHshRORIc5aDweU4(EcxRjyahuTOWf3HW1AcgWbvlkaOKEfC9nQ6ItPYM7lOG9FY(5fCNnADqmCdkjBPs4MfGQnOW4dO1adsOvtP7lzV2gHR1ekDSIUkkKd0zr4I77jCTMGbCq1IcxChcxRjyahuTOaGs6vW13OQloLkBUVGc2)j7NxWD2O1bXWnOKSLkHBuu)e(wql2H1eAoWkYETncxRju6yfDvuihOZIWf33t4Anbd4GQffU4oeUwtWaoOArbCugf0Sjtx99S)t2pVekDSIUkkKd0zraqj9kinzRR(E5q4Anbd4GQffU4oS)t2pVemGdQwuaqj9kinzRloLkBUVGc2)j7NxWD2O1bXWnOeu2RTr4AnHshRORIc5aDweU4(EcxRjyahuTOWf3HW1AcgWbvlkGJYOytMU4uQS5(cky)NSFEb3zJ24FUVK9ABeUwtqK(3MCWraqLn99eUwtO0Xk6QOqoqNfHlUVNW1AcgWbvlkCXDiCTMGbCq1IcakPxbxNkQXPuzZ9fuW(pz)8cUZgTPlAzGH1C2ijSgzV2gmgtPWOGiCGI0fTmWWAoBKewdnBu13lp5a0Zgq6ync1AHcCvhCG99a9SbKowJqTwO4kAYmut(Ckv2CFbfS)t2pVG7SrB7air6FRSxBJW1AcLowrxffYb6SiCX99eUwtWaoOArHlUdHR1emGdQwuahLrXMmDXPuzZ9fuW(pz)8cUZgTWLdt2W3c0Xkc1IHCkv2CFbfS)t2pVG7SrRshRORIc5aDwK9ABeUwtCvMCh8M7lHlUVxoJMWAexLj3bV5(sGLsKqlNsLn3xqb7)K9Zl4oB0YaoOArzV22YNwje)5iGMn5YPKtPYM7lOOD1bxqaCJUcoLiHYwQeUzHbMchLiHYsxtoCdgJPuyuqeoqH9OFfgGZdKOzJQoYz0ewJaCrld(oyGocShBeyPej023dJXukmkichOWE0VcdW5bs0SLToJMWAeGlAzW3bd0rG9yJalLiHwoLkBUVGI2vhCbbWD2O9Qm5o4n3xYETncxRjUktUdEZ9LW(5vFpHR1exLj3bV5(saqj9k46uRZYNwje)5iGMTS13pAcRrGRczU5(kaXAWIHcSuIeA7W(pz)8sGRczU5(kaXAWIHcakPxbxxMU6q4AnXvzYDWBUVeausVcUUmuRVN9FY(5LqPJv0vrHCGolcakPxbxxgQ1HW1AIRYK7G3CFjaOKEfCDQ6QZYNwje)5iGMTSXPuzZ9fu0U6GliaUZgT4QqMBUVcqSgSyOSxBdgJPuyuqeoqH9OFfgGZdKwFJQoYtoJMWAemGdQwuGLsKqBFp7)K9Zlbd4GQffausVcsteZUlQKpNsLn3xqr7QdUGa4oB0Ap6xHb48ajzV2gDfCkrcfwyGPWrjsyhcxRjSh9RWqSde)quaqLnCkv2CFbfTRo4ccG7SrR9OFfgGZdKK9AB0vWPejuyHbMchLiHDKNCgnH1iyahuTOalLiH2(E2)j7NxcgWbvlkaOKEfKMiMDxuj)(EcxRjqP4vaOwH4phbcxChls4AnXAoBKewJW(5vhcxRjSh9RWqSde)quy)8ItPYM7lOOD1bxqaCNnAhukoPayGocShBK9ABeUwtyp6xHHyhi(HOaGkB4uQS5(ckAxDWfea3zJ2bLItkagOJa7XgzV2M8KZOjSgbd4GQffyPej023Z(pz)8sWaoOArbaL0RG0eXS7kBYVJ8KZOjSgbUkK5M7RaeRblgkWsjsOTVNW1AcgWbvlkCXDiCTMGbCq1Ic4OmkwxMU67z)NSFEjWvHm3CFfGynyXqbaL0RG0eXS7Ik5ZPKtPYM7lOicleOZdGB0vWPeju2sLWnQ3tDKLUMC4M8KZOjSgXIkjHGW3c5aDweyPej023pkichXcQPzreZgA2OQRoYJW1AcLowrxffYb6SiSFE13t4Anbd4GQff2pVKV85uQS5(ckIWcb68a4oB0Y0ukOS5(kKo4iBPs4w7QdUGaOSxBB5tReI)CeqZg14uQS5(ckIWcb68a4oB0MRuGHVfu4ccL9ABYtoa9SbKowJqTwOax1bhyFpqpBaPJ1iuRfkUIgzOwFpmgtPWOGiCGICLcm8TGcxqinBuj)oYB5tReI)CeS(wx99lFALq8NJGnz6W(pz)8sqKulg(wynhCogkaOKEfKMiMv(Ckv2CFbfryHaDEaCNnAjsQfdFlSMdohdL9ABlFALq8NJG13OQVxElFALq8NJGTS1rES)t2pVelQKeccFlKd0zraqj9kinrm7UOQVNUcoLiHcQ3tDKV85uQS5(ckIWcb68a4oB0UMZgjH1i712w(0kH4phbRVrvFV8w(0kH4phbRVj3oYJ9FY(5LGiPwm8TWAo4Cmuaqj9kinrm7UOQVNUcoLiHcQ3tDKV85uQS5(ckIWcb68a4oB0UOssii8TqoqNfzV22YNwje)5iy9n5YPuzZ9fueHfc05bWD2OL9fezaDUVK9ABlFALq8NJG13OQVF5tReI)CeS(w26W(pz)8sqKulg(wynhCogkaOKEfKMiMDxu13V8PvcXFoc2KBh2)j7NxcIKAXW3cR5GZXqbaL0RG0eXS7IQoS)t2pVeR5SrsyncakPxbPjIz3fvCkv2CFbfryHaDEaCNnAzAkfu2CFfshCKTujCRD1bxqau2RTnAcRrSOssii8TqoqNfbwkrcTDK3OGiCelOMMfrmBwFJQU67jCTMqPJv0vrHCGolcxCFpHR1emGdQwu4ILpNsLn3xqrewiqNha3zJwgWbvlccWbCuGYETn2)j7NxcgWbvlccWbCuGc2IcIqyObu2CFPjA2KrKzOwh5T8PvcXFocwFJQ((LpTsi(ZrW6BzRd7)K9ZlbrsTy4BH1CW5yOaGs6vqAIy2DrvF)YNwje)5iytUDy)NSFEjisQfdFlSMdohdfausVcsteZUlQ6W(pz)8sSMZgjH1iaOKEfKMiMDxu1H9FY(5LG9fezaDUVeausVcsteZUlQKpNsLn3xqrewiqNha3zJwMMsbLn3xH0bhzlvc3AxDWfea5uQS5(ckIWcb68a4oB0YaoOArqaoGJcu2RTT8PvcXFocwFtUCkv2CFbfryHaDEaCNnAvatlmmpaG1i712w(0kH4phbRVjxoLCkv2CFbfFmwiydIzYHfdL9ABJMWAe5kfy4BbfUGqbwkrcTDgnH1iyahuTOalLiH2oJMWAe4QqMBUVcqSgSyOalLiH2oYz0ewJyrLKqq4BHCGolcSuIeALTujClxPadFmwiiSBjdRgY9WLdt2W3c0Xkc1IH7jsQfdFlSMdohd3VMZgjH1SNbCq1I7hukoPayGocShB2NRuGHVfu4cc3pOuCsbWaDeyp2SNbCq1IGaCahf4ECviZn3xbiwdwmKtPYM7lO4JXcb7SrleZKdlgk712gnH1iYvkWW3ckCbHcSuIeA7mAcRrWaoOArbwkrcTDKZOjSgbUkK5M7RaeRblgkWsjsOTJCgnH1iwujjee(wihOZIalLiHwzlvc3YvkWWhJfccRgY9WLdt2W3c0Xkc1IH7jsQfdFlSMdohd3VMZgjH1SNbCq1I7hukoPayGocShB2NRuGHVfu4cc3pOuCsbWaDeyp2SNbCq1IGaCahf4(bLItkagOJa7XgoLkBUVGIpgleSZgTqmtoSyOSxBB0ewJixPadFlOWfekWsjsOTZOjSgbd4GQffyPej02z0ewJaxfYCZ9vaI1GfdfyPej02z0ewJyrLKqq4BHCGolcSuIeALTujClxPadFmwiiSBjduVN6ShUCyYg(wGowrOwmCprsTy4BH1CW5y4(1C2ijSM9mGdQwC)GsXjfad0rG9yZ(CLcm8TGcxq4(bLItkagOJa7XM9lQKeccFlKd0zzpUkK5M7RaeRblgYPuzZ9fu8XyHGD2OfIzYHfdL9ABJMWAe5kfy4BbfUGqbwkrcTDgnH1iyahuTOalLiH2oYz0ewJaxfYCZ9vaI1GfdfyPej02z0ewJyrLKqq4BHCGolcSuIeALTujClxPadFmwiiq9EQZE4YHjB4Bb6yfHAXW9ej1IHVfwZbNJH7xZzJKWA2ZaoOAX9dkfNuamqhb2Jn7ZvkWW3ckCbH7hukoPayGocShB2VOssii8TqoqNL9dkfNuamqhb2JnCkv2CFbfFmwiyNnAHyMCyXqzV22OjSgrUsbg(wqHliuGLsKqBNrtynIRYK7G3CFjWsjsOv2sLWTCLcm8XyHGa1vLP9WLdt2W3c0Xkc1IH7jsQfdFlSMdohd3VMZgjH1S)Qm5o4n3x7v6yfDvuihOZY(CLcm8TGcxqOHKocG3xMSOQlzYCYqv26sqLmDjxdzUcQRIGgsQZQ1UNf1vwu33Z9CFgli3FsXpy4(2d4(S7JXcbzh3dWm5oaA5E4lHCV6Mxsh0Y9SfTIqOGt5U5kK7Lzp3N5lOlo(bdA5ELn3xCF2bXm5WIHzNGt5U5kK7PAp3N5lOlo(bdA5ELn3xCF2bXm5WIHzNGt5U5kK7Z2EUpZxqxC8dg0Y9kBUV4(SdIzYHfdZobNYDZvi3l39CFMVGU44hmOL7v2CFX9zheZKdlgMDcoL7MRqUNA75(mFbDXXpyql3RS5(I7ZoiMjhwmm7eCk5usDwT29SOUYI6(EUN7Zyb5(tk(bd33Ea3NDwSPU0KDCpaZK7aOL7HVeY9QBEjDql3Zw0kcHcoL7MRqUxM9CFMVGU44hmOL7v2CFX9zN6MpOZOmkYobNsoLuxsXpyql3N94ELn3xCF6GduWP0qQUz5bgsYtA1yithCGMmmKFmwiWKHjlzmzyiXsjsO10THuzZ9LHeIzYHfdnKLkHgYCLcm8XyHGWULmSAi3dxomzdFlqhRiulgUNiPwm8TWAo4CmC)AoBKewZEgWbvlUFqP4KcGb6iWESzFUsbg(wqHliC)GsXjfad0rG9yZEgWbvlccWbCuG7XvHm3CFfGynyXqdjdCdco1qoAcRrKRuGHVfu4ccfyPej0Y9D4(rtyncgWbvlkWsjsOL77W9JMWAe4QqMBUVcqSgSyOalLiHwUVd3lhUF0ewJyrLKqq4BHCGolcSuIeAnJjlQmzyiXsjsO10THuzZ9LHeIzYHfdnKLkHgYCLcm8XyHGWQHCpC5WKn8TaDSIqTy4EIKAXW3cR5GZXW9R5Srsyn7zahuT4(bLItkagOJa7XM95kfy4BbfUGW9dkfNuamqhb2Jn7zahuTiiahWrbUFqP4KcGb6iWESXqYa3GGtnKJMWAe5kfy4BbfUGqbwkrcTCFhUF0ewJGbCq1IcSuIeA5(oCVC4(rtyncCviZn3xbiwdwmuGLsKql33H7Ld3pAcRrSOssii8TqoqNfbwkrcTMXKv2mzyiXsjsO10THuzZ9LHeIzYHfdnKLkHgYCLcm8XyHGWULmq9EQZE4YHjB4Bb6yfHAXW9ej1IHVfwZbNJH7xZzJKWA2ZaoOAX9dkfNuamqhb2Jn7ZvkWW3ckCbH7hukoPayGocShB2VOssii8TqoqNL94QqMBUVcqSgSyOHKbUbbNAihnH1iYvkWW3ckCbHcSuIeA5(oC)OjSgbd4GQffyPej0Y9D4(rtyncCviZn3xbiwdwmuGLsKql33H7hnH1iwujjee(wihOZIalLiHwZyYsUMmmKyPej0A62qQS5(YqcXm5WIHgYsLqdzUsbg(ySqqG69uN9WLdt2W3c0Xkc1IH7jsQfdFlSMdohd3VMZgjH1SNbCq1I7hukoPayGocShB2NRuGHVfu4cc3pOuCsbWaDeyp2SFrLKqq4BHCGol7hukoPayGocShBmKmWni4ud5OjSgrUsbg(wqHliuGLsKql33H7hnH1iyahuTOalLiHwUVd3lhUF0ewJaxfYCZ9vaI1GfdfyPej0Y9D4(rtynIfvscbHVfYb6SiWsjsO1mMSOMjddjwkrcTMUnKkBUVmKqmtoSyOHSuj0qMRuGHpgleeOUQmThUCyYg(wGowrOwmCprsTy4BH1CW5y4(1C2ijSM9xLj3bV5(AVshRORIc5aDw2NRuGHVfu4ccnKmWni4ud5OjSgrUsbg(wqHliuGLsKql33H7hnH1iUktUdEZ9LalLiHwZygdPfBQlnMmmzjJjddPYM7ldP6MpOZOmkmKyPej0A62mMSOYKHHuzZ9LHeGeokqdjwkrcTMUnJjRSzYWqILsKqRPBdPYM7ldjttPGYM7Rq6GJHmDWjuQeAi)ySqGzmzjxtggsSuIeAnDBiv2CFzizAkfu2CFfshCmKPdoHsLqdj7)K9ZlOzmzrntggsSuIeAnDBiv2CFzizAkfu2CFfshCmKPdoHsLqdzewiqNhanJzmKXaK9se6yYWKLmMmmKyPej0A62mMSOYKHHelLiHwt3MXKv2mzyiXsjsO10TzmzjxtggsSuIeAnDBgtwuZKHHuzZ9LHm(N7ldjwkrcTMUnJjRSNjddjwkrcTMUnKmWni4udPC4(rtynICLcm8TGcxqOalLiHwdPYM7ldPcyAHH5baSgZygdj7)K9ZlOjdtwYyYWqILsKqRPBdPYM7ldjqLIVkkOsXPBCwmeDrk9pnbSIUcnKmWni4udP84EcxRju6yfDvuihOZIWfZ999CpHR1emGdQwu4I5E5BilvcnKavk(QOGkfNUXzXq0fP0)0eWk6k0mMSOYKHHelLiHwt3gsLn3xgYiWxrWqm4K0uaOrOHKbUbbNAiLd3t4AnHshRORIc5aDweUyUVd3lhUNW1AcgWbvlkCXgYsLqdze4RiyigCsAka0i0mMSYMjddjwkrcTMUnKLkHgsGUABDffWaXffaOnq4M5ldPYM7ldjqxTTUIcyG4Ica0giCZ8LzmzjxtggsSuIeAnDBiv2CFzixdHHLppHadjdCdco1qs4AnHshRORIc5aDweUyUVVN7jCTMGbCq1Icxm33H7jCTMGbCq1Ic4Omk4(nUxMUmKLkHgY1qyy5ZtiWmMSOMjddjwkrcTMUnKkBUVmK0pnf(wqRtsh0gis)BnKmWni4udP84EcxRju6yfDvuihOZIWfZ999CpHR1emGdQwu4I5(oCpHR1emGdQwuaqj9ki3Vo3ltMJ7Lp333Z9YJ7z)NSFEju6yfDvuihOZIaGs6vqUNgUpBDX999Cp7)K9Zlbd4GQffausVcY90W9zRlUx(gYsLqdj9ttHVf06K0bTbI0)wZyYk7zYWqILsKqRPBdPYM7ldP9FjyO5aRyizGBqWPgscxRju6yfDvuihOZIWfZ999CpHR1emGdQwu4I5(oCpHR1emGdQwuaqj9ki3Vo3ltMZqwQeAiT)lbdnhyfZyYkZyYWqILsKqRPBdPYM7ldzKMqMMsiagiqLcdjdCdco1qs4AnHshRORIc5aDweUyUVVN7jCTMGbCq1Icxm33H7jCTMGbCq1IcakPxb5(15EzOMHSuj0qgPjKPPecGbcuPWmMSYCMmmKyPej0A62qQS5(YqsSs0xyGaXGMK0szgsg4geCQHKW1AcLowrxffYb6SiCXCFFp3t4Anbd4GQffUydzPsOHKyLOVWabIbnjPLYmJjRSVjddjwkrcTMUnKkBUVmKsiaPywuyOPvKHKbUbbNAiLh3lhUhONnG0XAeQ1cf4Qo4a5((EUhONnG0XAeQ1cfxX90W9YqnUx(CFFp3dJXukmkichOWE0VcdW5bsCpnBCpvgYsLqdPecqkMffgAAfzgtwY0LjddjwkrcTMUnKkBUVmKXjxzrabQalm0skKcdjdCdco1qs4AnHshRORIc5aDweUyUVVN7jCTMGbCq1Icxm33H7jCTMGbCq1Ic4Omk4EA24Ez6I7775E2)j7NxcLowrxffYb6SiaOKEfK7PH7Ll14((EUxoCpHR1emGdQwu4I5(oCp7)K9Zlbd4GQffausVcY90W9YLAgYsLqdzCYvweqGkWcdTKcPWmMSKrgtggsSuIeAnDBiv2CFzijqaebuGayyn3AodjdCdco1qs4AnHshRORIc5aDweUyUVVN7jCTMGbCq1Icxm33H7jCTMGbCq1Ic4Omk4EA24Ez6I7775E2)j7NxcLowrxffYb6SiaOKEfK7PH7Ll14((EUxoCpHR1emGdQwu4I5(oCp7)K9Zlbd4GQffausVcY90W9YLAgYsLqdjbcGiGceadR5wZzgtwYqLjddjwkrcTMUnKkBUVmKyztiegMRyJdGHVfAaLn3xAke)5iWqYa3GGtnKeUwtO0Xk6QOqoqNfHlM7775EcxRjyahuTOWfZ9D4EcxRjyahuTOaokJcUNMnUxMU4((EUN9FY(5LqPJv0vrHCGolcakPxb5EA4E5snUVVN7z)NSFEjyahuTOaGs6vqUNgUxUuZqwQeAiXYMqimmxXghadFl0akBUV0ui(ZrGzmzjt2mzyiXsjsO10THuzZ9LHmgvqkyp6iagyVuScHgsg4geCQHKW1AcLowrxffYb6SiCXCFFp3t4Anbd4GQffUyUVd3t4Anbd4GQffWrzuW90SX9Y0LHSuj0qgJkifShDeadSxkwHqZyYsg5AYWqILsKqRPBdPYM7ldz7aWjiPdcdW4vIskeAizGBqWPgscxRju6yfDvuihOZIWfZ999CpHR1emGdQwu4I5(oCpHR1emGdQwuaqj9ki3V(g3ld1mKLkHgY2bGtqshegGXReLui0mMSKHAMmmKyPej0A62qQS5(YqMVCGu(vrWqCYjPrOHKbUbbNAijCTMqPJv0vrHCGolcxm333Z9eUwtWaoOArHlM77W9eUwtWaoOArbaL0RGC)6BCpvDzilvcnK5lhiLFvemeNCsAeAgtwYK9mzyiXsjsO10THuzZ9LH0cq1gIsQ905bWaHAJqdjdCdco1qs4AnHshRORIc5aDweUyUVVN7jCTMGbCq1Icxm33H7jCTMGbCq1IcakPxb5(134EQ6YqwQeAiTauTHOKApDEamqO2i0mMSKjZyYWqILsKqRPBdPYM7ldPfGQnOW4dO1adsOvtP7ldjdCdco1qs4AnHshRORIc5aDweUyUVVN7jCTMGbCq1Icxm33H7jCTMGbCq1IcakPxb5(134EQ6YqwQeAiTauTbfgFaTgyqcTAkDFzgtwYK5mzyiXsjsO10THuzZ9LHKI6NW3cAXoSMqZbwXqYa3GGtnKeUwtO0Xk6QOqoqNfHlM7775EcxRjyahuTOWfZ9D4EcxRjyahuTOaokJcUNMnUxMU4((EUN9FY(5LqPJv0vrHCGolcakPxb5EA4(S1f333Z9YH7jCTMGbCq1Icxm33H7z)NSFEjyahuTOaGs6vqUNgUpBDzilvcnKuu)e(wql2H1eAoWkMXKLmzFtggsSuIeAnDBizGBqWPgscxRju6yfDvuihOZIWfZ999CpHR1emGdQwu4I5(oCpHR1emGdQwuahLrb3VX9Y0LHuzZ9LH0bXWnOe0mMSOQltggsSuIeAnDBizGBqWPgscxRjis)Bto4iaOYgUVVN7jCTMqPJv0vrHCGolcxm333Z9eUwtWaoOArHlM77W9eUwtWaoOArbaL0RGC)6CpvuZqQS5(Yqg)Z9LzmzrLmMmmKyPej0A62qYa3GGtnKWymLcJcIWbksx0YadR5SrsynCpnBCpvCFFp3lpUxoCpqpBaPJ1iuRfkWvDWbY999CpqpBaPJ1iuRfkUI7PH7ZmuJ7LVHuzZ9LHmDrldmSMZgjH1ygtwurLjddjwkrcTMUnKmWni4udjHR1ekDSIUkkKd0zr4I5((EUNW1AcgWbvlkCXCFhUNW1AcgWbvlkGJYOG734Ez6YqQS5(Yq2oasK(3AgtwuLntggsLn3xgs4YHjB4Bb6yfHAXqdjwkrcTMUnJjlQKRjddjwkrcTMUnKmWni4udjHR1exLj3bV5(s4I5((EUxoC)OjSgXvzYDWBUVeyPej0Aiv2CFziv6yfDvuihOZIzmzrf1mzyiXsjsO10THKbUbbNAix(0kH4phbCpnBCVCnKkBUVmKmGdQw0mMXq2U6GliaAYWKLmMmmKyPej0A62qsxto0qcJXukmkichOWE0VcdW5bsCpnBCpvCFhUxoC)OjSgb4Iwg8DWaDeyp2iWsjsOL7775EymMsHrbr4af2J(vyaopqI7PzJ7Zg33H7hnH1iax0YGVdgOJa7XgbwkrcTgsLn3xgs6k4uIeAiPRGqPsOH0cdmfokrcnJjlQmzyiXsjsO10THKbUbbNAijCTM4Qm5o4n3xc7NxCFFp3t4AnXvzYDWBUVeausVcY9RZ9uJ77W9lFALq8NJaUNMnUpBCFFp3pAcRrGRczU5(kaXAWIHcSuIeA5(oCp7)K9ZlbUkK5M7RaeRblgkaOKEfK7xN7LPlUVd3t4AnXvzYDWBUVeausVcY9RZ9YqnUVVN7z)NSFEju6yfDvuihOZIaGs6vqUFDUxgQX9D4EcxRjUktUdEZ9LaGs6vqUFDUNQU4(oC)YNwje)5iG7PzJ7ZMHuzZ9LH8Qm5o4n3xMXKv2mzyiXsjsO10THKbUbbNAiHXykfgfeHduyp6xHb48ajUF9nUNkUVd3lpUxoC)OjSgbd4GQffyPej0Y999Cp7)K9Zlbd4GQffausVcY90W9rml3VlUNkUx(gsLn3xgsCviZn3xbiwdwm0mMSKRjddjwkrcTMUnKmWni4udjDfCkrcfwyGPWrjsi33H7jCTMWE0VcdXoq8drbav2yiv2CFziTh9RWaCEGKzmzrntggsSuIeAnDBizGBqWPgs6k4uIekSWatHJsKqUVd3lpUxoC)OjSgbd4GQffyPej0Y999Cp7)K9Zlbd4GQffausVcY90W9rml3VlUNkUx(CFFp3t4AnbkfVca1ke)5iq4I5(oCVfjCTMynNnscRry)8I77W9eUwtyp6xHHyhi(HOW(5LHuzZ9LH0E0VcdW5bsMXKv2ZKHHelLiHwt3gsg4geCQHKW1Ac7r)kme7aXpefauzJHuzZ9LHCqP4KcGb6iWESXmMSYmMmmKyPej0A62qYa3GGtnKYJ7Ld3pAcRrWaoOArbwkrcTCFFp3Z(pz)8sWaoOArbaL0RGCpnCFeZY97I7Zg3lFUVd3lpUxoC)OjSgbUkK5M7RaeRblgkWsjsOL7775EcxRjyahuTOWfZ9D4EcxRjyahuTOaokJcUFDUxMU4((EUN9FY(5LaxfYCZ9vaI1GfdfausVcY90W9rml3VlUNkUx(gsLn3xgYbLItkagOJa7XgZygdzewiqNhanzyYsgtggsSuIeAnDBiPRjhAiLh3lhUF0ewJyrLKqq4BHCGolcSuIeA5((EUFuqeoIfutZIiMnCpnBCpvDX9D4E5X9eUwtO0Xk6QOqoqNfH9ZlUVVN7jCTMGbCq1Ic7NxCV85E5Biv2CFziPRGtjsOHKUccLkHgsQ3tDmJjlQmzyiXsjsO10THKbUbbNAix(0kH4phbCpnBCp1mKkBUVmKmnLckBUVcPdogY0bNqPsOHSD1bxqa0mMSYMjddjwkrcTMUnKmWni4udP84E5W9a9SbKowJqTwOax1bhi333Z9a9SbKowJqTwO4kUNgUxgQX999CpmgtPWOGiCGICLcm8TGcxqi3tZg3tf3lFUVd3lpUF5tReI)CeW9RVX9DX999C)YNwje)5iG734Ez4(oCp7)K9ZlbrsTy4BH1CW5yOaGs6vqUNgUpIz5E5Biv2CFziZvkWW3ckCbHMXKLCnzyiXsjsO10THKbUbbNAix(0kH4phbC)6BCpvCFFp3lpUF5tReI)CeW9BCF24(oCV84E2)j7NxIfvscbHVfYb6SiaOKEfK7PH7JywUFxCpvCFFp3txbNsKqb17PoCV85E5Biv2CFzijsQfdFlSMdohdnJjlQzYWqILsKqRPBdjdCdco1qU8PvcXFoc4(134EQ4((EUxEC)YNwje)5iG7xFJ7Ll33H7Lh3Z(pz)8sqKulg(wynhCogkaOKEfK7PH7JywUFxCpvCFFp3txbNsKqb17PoCV85E5Biv2CFzixZzJKWAmJjRSNjddjwkrcTMUnKmWni4ud5YNwje)5iG7xFJ7LRHuzZ9LHCrLKqq4BHCGolMXKvMXKHHelLiHwt3gsg4geCQHC5tReI)CeW9RVX9uX999C)YNwje)5iG7xFJ7Zg33H7z)NSFEjisQfdFlSMdohdfausVcY90W9rml3VlUNkUVVN7x(0kH4phbC)g3lxUVd3Z(pz)8sqKulg(wynhCogkaOKEfK7PH7JywUFxCpvCFhUN9FY(5LynNnscRraqj9ki3td3hXSC)U4EQmKkBUVmKSVGidOZ9LzmzL5mzyiXsjsO10THKbUbbNAihnH1iwujjee(wihOZIalLiHwUVd3lpUFuqeoIfutZIiMnC)6BCpvDX999CpHR1ekDSIUkkKd0zr4I5((EUNW1AcgWbvlkCXCV8nKkBUVmKmnLckBUVcPdogY0bNqPsOHSD1bxqa0mMSY(MmmKyPej0A62qYa3GGtnKS)t2pVemGdQweeGd4OafSffeHWqdOS5(stCpnBCVmImd14(oCV84(LpTsi(Zra3V(g3tf333Z9lFALq8NJaUF9nUpBCFhUN9FY(5LGiPwm8TWAo4Cmuaqj9ki3td3hXSC)U4EQ4((EUF5tReI)CeW9BCVC5(oCp7)K9ZlbrsTy4BH1CW5yOaGs6vqUNgUpIz5(DX9uX9D4E2)j7NxI1C2ijSgbaL0RGCpnCFeZY97I7PI77W9S)t2pVeSVGidOZ9LaGs6vqUNgUpIz5(DX9uX9Y3qQS5(YqYaoOArqaoGJc0mMSKPltggsSuIeAnDBiv2CFzizAkfu2CFfshCmKPdoHsLqdz7QdUGaOzmzjJmMmmKyPej0A62qYa3GGtnKlFALq8NJaUF9nUxUgsLn3xgsgWbvlccWbCuGMXKLmuzYWqILsKqRPBdjdCdco1qU8PvcXFoc4(134E5Aiv2CFzivatlmmpaG1ygZygZygJb]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        potion = "battle_potion_of_strength",
        
        package = "Retribution",
    } )
end
