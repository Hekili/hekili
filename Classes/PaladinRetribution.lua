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
            duration = 15,
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
            shared = "player", -- check for anyone's buff on the player.
        },

        greater_blessing_of_wisdom = {
            id = 203539,
            duration = 3600,
            max_stack = 1,
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

    
    spec:RegisterPack( "Retribution", 20181001.0915, [[dKeIhbqiIk9iPq0MKI(KuinkLkoLsvwLss9kLknlrWTKcvTlu9lIsdte1XqjwgIYZusY0iQ4Ais2MsvHVHivgNsvvNtkuSoeX8KcUNszFiQoOuOulujXdrKsDrLQs(OuOeJerQ6KisjRKOyMkvfTtrKFkfkPHkfclvPQYtrXufHUQsvP(kIuSxQ8xQAWK6WuwmcpMWKj5YGnlvFwKgTsCAvwTskVgL0Sf62ez3s(TQgUO64ev1YH8COMUIRly7OuFxknEIQCELuTEPqL5lk7hPDS4s0XOSbCjrwYSS)SKCYSWtUXWY(GmwCmZ65GJj3eSAPGJPmjWXSFWGoIWCF5yYT1JVPCj6yWFajahZYm5ysKv20BwceCXljl(KcrBUVeiRpYIpjHSeXNqwIU14vaBzZrF)Iaw2eparglYMizS4Bew0ux53pyqhryUV44ts4yicxCiTkhHJrzd4sISKzz)zj5KzHNCJjzYyXXGZbHljsxYoMLtPGYr4yuaw4yAKu9(bd6icZ9fv3iSOPUIktJKQxMjhtISYMEZsGGlEjzXNuiAZ9Laz9rw8jjKLi(eYs0TgVcylBo67xeWY2iqW(zNclBJy)8nclAQR87hmOJim3xC8jjOY0iP6gRI5jaevZscunzjZY(t1nEQo5gdjSqkhto67xeCmnsQE)GbDeH5(IQBew0uxrLPrs1lZKJjrwztVzjqWfVKS4tkeT5(sGS(il(KeYseFczj6wJxbSLnh99lcyzBeiy)StHLTrSF(gHfn1v(9dg0reM7lo(KeuzAKuDJvX8eaIQzjbQMSKzz)P6gpvNCJHewifvgQmnsQEFjpqegqr1eq)ravlEjcBOAci9kmNQBSfciFWuD9vJFXqs9qKQnXCFHP6VIRZPYyI5(cZZrG4LiSzRhnmRuzmXCFH55iq8se2S7MS9)vuzmXCFH55iq8se2S7MSwivcQXM7lQmnsQMPSC8YpunYofvte6Dqr14Xgmvta9hbuT4LiSHQjG0RWuTvkQohbn(8FMRsP6dt1QVaovgtm3xyEoceVeHn7UjlUSC8YpE8ydMkJjM7lmphbIxIWMD3Kn)N7lQmuzAKu9(sEGimGIQb2aADQEojGQNfGQnX8iQ(WuTX2UOrebovgtm3x4nlmV3MXeSsLXeZ9fE3nzrarGvGkJjM7l8UBYkSy0BI5(Yhp8KqzsW2NdfGOYyI5(cV7MSclg9MyUV8XdpjuMeSj(pQ(2ctLXeZ9fE3nzfwm6nXCF5JhEsOmjylfkazZJWuzOYyI5(cZf)hvFBH3cyWFdiLqzsWgYACQqXk2tCPEeO8eHz(IkJjM7lmx8Fu9TfE3nzdyWFdiLqzsW2Aa2V8TraLW13ic9o3ydv6vP(wKnl8qEwgrO35cuaBkGhYBse6DUafWMc44XeSUXsYuzmXCFH5I)JQVTW7UjBad(BaPektc2yFw0)DVvNKnGYte)xLW132Hi07CJnuPxL6Br2SWd5zzeHENlqbSPaEiVjrO35cuaBkGJaj7kCdSS)7LLTJ4)O6BlUXgQ0Rs9TiBw4iqYUct(Qsolt8Fu9TfxGcytbCeizxHjFvjVhvgtm3xyU4)O6Bl8UBYgWG)gqkHYKGn1)syFpGwpHRVre6DUXgQ0Rs9TiBw4H8SmIqVZfOa2uapK3Ki07CbkGnfWrGKDfUbw2FQmMyUVWCX)r13w4D3KnGb)nGucLjbBPweewmciSNamwt46BeHENBSHk9QuFlYMfEiplJi07CbkGnfWd5njc9oxGcytbCeizxHBGfsrLXeZ9fMl(pQ(2cV7MSbm4VbKsOmjyJy90VapbaElkzLjs46BeHENBSHk9QuFlYMfEiplJi07CbkGnfWd5uzmXCFH5I)JQVTW7UjBad(BaPektc2KaeW6SyyF3Q0eU(2oYfzNYdSHA4MsH5G8o8GZYq2P8aBOgUPuy(vKZcP2lldNdXOFmukmyU6yFf4XZJKiFJmQmMyUVWCX)r13w4D3KnGb)nGucLjbB5XqPaebyif23JgM1eU(grO35gBOsVk13ISzHhYZYic9oxGcytb8qEtIqVZfOa2uahpMGvY3yj5SmX)r13wCJnuPxL6Br2SWrGKDfMC5qQSm5se6DUafWMc4H8MI)JQVT4cuaBkGJaj7km5YHuuzmXCFH5I)JQVTW7UjBad(BaPektc2iaegqSciSFTWAHeU(grO35gBOsVk13ISzHhYZYic9oxGcytb8qEtIqVZfOa2uahpMGvY3yj5SmX)r13wCJnuPxL6Br2SWrGKDfMC5qQSm5se6DUafWMc4H8MI)JQVT4cuaBkGJaj7km5YHuuzmXCFH5I)JQVTW7UjBad(BaPektc2Gsfbm2pxjMac8F33rMyUVSOp)BbucxFJi07CJnuPxL6Br2SWd5zzeHENlqbSPaEiVjrO35cuaBkGJhtWk5BSKCwM4)O6BlUXgQ0Rs9TiBw4iqYUctUCivwM4)O6BlUafWMc4iqYUctUCifvgtm3xyU4)O6Bl8UBYgWG)gqkHYKGTCWqrV6ydiSx8s5ggNW13ic9o3ydv6vP(wKnl8qEwgrO35cuaBkGhYBse6DUafWMc44XeSs(gljtLXeZ9fMl(pQ(2cV7MSbm4VbKsOmjyRFi84LSbWEC(6PrdJt46BeHENBSHk9QuFlYMfEiplJi07CbkGnfWd5njc9oxGcytbCeizxHByJfsrLXeZ9fMl(pQ(2cV7MSbm4VbKsOmjyRD5qX2RsX(8yqYsHeU(grO35gBOsVk13ISzHhYZYic9oxGcytb8qEtIqVZfOa2uahbs2v4g2ilzQmMyUVWCX)r13w4D3KnGb)nGucLjbBkeykFA0uNnpc7jmvkKW13ic9o3ydv6vP(wKnl8qEwgrO35cuaBkGhYBse6DUafWMc4iqYUc3WgzjtLXeZ9fMl(pQ(2cV7MSbm4VbKsOmjytHat5nC(HSAWEjqzX49vcxFJi07CJnuPxL6Br2SWd5zzeHENlqbSPaEiVjrO35cuaBkGJaj7kCdBKLmvgtm3xyU4)O6Bl8UBYgWG)gqcNW132Hi07CJnuPxL6Br2SWd5zzeHENlqbSPaEi3eZ9fMl(pQ(2cV7MS5)CFLW132Hi07CI4)QyapCeyIjlJi07CJnuPxL6Br2SWd5zzeHENlqbSPaEiVjrO35cuaBkGJaj7kCdKrQSSXqPWWNtc8Z7vh0WMCsEpQmMyUVWCX)r13w4D3Kn)N7ReU(2oeHENte)xfd4HJatmzzeHENBSHk9QuFlYMfEiplJi07CbkGnfWd5njc9oxGcytbCeizxHBGmsLLngkfg(CsGFEV6Gg2KtY7rLXeZ9fMl(pQ(2cV7MSXlDzW(1cQujOMeU(gohIr)yOuyW84LUmy)AbvQeud5BKLLTJCr2P8aBOgUPuyoiVdp4SmKDkpWgQHBkfMFf5KosThvgtm3xyU4)O6Bl8UBY2peqe)xLW13ic9o3ydv6vP(wKnl8qEwgrO35cuaBkGhYBse6DUafWMc44XeSUXsYuzmXCFH5I)JQVTW7UjlE5GOY)DpBOsbReavgtm3xyU4)O6Bl8UBYASHk9QuFlYMLeU(grO35xj)WHV5(IhYZYK7yrOg(vYpC4BUV4qzerqrLXeZ9fMl(pQ(2cV7MScuaBkiHRVT8X195FlGiFtouzOYyI5(cZ7xD4faH3yBOZiIqcLjbBkSxy4XiIqcSTya2W5qm6hdLcdMRo2xbE88ijY3wvwMChlc1Wrx6YaFa7zdi1jgougreunhlc1Wvh7Ra)AbvQeudhkJicQM4Cig9JHsHbZvh7RapEEKe5BKLLznoaDdWvh7Rap6sxgougreunTghGUb4QJ9vGhDPldhzfRKVrwZXqPWWxalol8CX0Wgzj3Ki07C1X(kWJU0LHR(2IkJjM7lmVF1HxaeE3nzVs(HdFZ9vcxFJi078RKF4W3CFXvFBLLre6D(vYpC4BUV4iqYUc3aPAU8X195FlGiFBvzzJfHA4G8aryUV8yOgOeahkJicQMI)JQVT4G8aryUV8yOgOeahbs2v4gyj5MeHENFL8dh(M7locKSRWnWcPYYe)hvFBXn2qLEvQVfzZchbs2v4gyHunjc9o)k5ho8n3xCeizxHBGSKBU8X195FlGiFBvuzmXCFH59Ro8cGW7UjlipqeM7lpgQbkbKW13W5qm6hdLcdMRo2xbE88iPg2wvZDK7yrOgUafWMc4qzerqLLj(pQ(2IlqbSPaocKSRWKNkuRMS9OYyI5(cZ7xD4faH3Dtw1X(kWJNhjLW13yBOZiIaxH9cdpgreAse6DU6yFf4ZdO8hdCeyIHkJjM7lmVF1HxaeE3nzvh7RapEEKucxFJTHoJicCf2lm8yerO5oYDSiudxGcytbCOmIiOYYe)hvFBXfOa2uahbs2vyYtfQvt2EuzmXCFH59Ro8cGW7Uj7as5rdH9SbK6etcxFJi07C1X(kWNhq5pg4iWetZDK7yrOgoipqeM7lpgQbkbWHYiIGklt8Fu9TfhKhicZ9Lhd1aLa4iqYUctEQqThvgtm3xyE)QdVai8UBYoGuE0qypBaPoXKW132rUJfHA4cuaBkGdLrebvwM4)O6BlUafWMc4iqYUctEQqTAY2R5oYDSiudhKhicZ9Lhd1aLa4qzerqLLre6DUafWMc4H8MeHENlqbSPaoEmbRnWsYzzI)JQVT4G8aryUV8yOgOeahbs2vyYtfQvt2EuzOYyI5(cZtHcq28i8gBdDgresOmjyJ0)KMeyBXaSTJChlc1Wxmjja5)UVfzZchkJicQSSXqPWWxalol8CXq(gzj3ChIqVZn2qLEvQVfzZcx9TvwgrO35cuaBkGR(2AV9OYyI5(cZtHcq28i8UBYkSy0BI5(Yhp8KqzsWw)QdVaiCcxFB5JR7Z)war(gPOYyI5(cZtHcq28i8UBY2ASc(V7n8cGt46B7ixKDkpWgQHBkfMdY7WdoldzNYdSHA4MsH5xrolKAVM7S8X195FlGAyl5SSLpUUp)Bb0glnf)hvFBXjIMc8F3VwapNa4iqYUctEQqThvgtm3xyEkuaYMhH3DtwIOPa)39RfWZjGeU(2Yhx3N)TaQHnYYY2z5JR7Z)waTTQM7i(pQ(2IVyssaY)DFlYMfocKSRWKNkuRMSSm2g6mIiWj9pPzV9OYyI5(cZtHcq28i8UBYUwqLkb1KW13w(46(8VfqnSrww2olFCDF(3cOg2KtZDe)hvFBXjIMc8F3VwapNa4iqYUctEQqTAYYYyBOZiIaN0)KM92JkJjM7lmpfkazZJW7Uj7Ijjbi)39TiBws46BlFCDF(3cOg2Kdvgtm3xyEkuaYMhH3DtwXxyqGS5(kHRVT8X195FlGAyJSSSLpUUp)BbudBRQP4)O6Blor0uG)7(1c45eahbs2vyYtfQvtww2Yhx3N)TaAtonf)hvFBXjIMc8F3VwapNa4iqYUctEQqTAYAk(pQ(2IVwqLkb1WrGKDfM8uHA1KrLXeZ9fMNcfGS5r4D3KvyXO3eZ9LpE4jHYKGT(vhEbq4eU(2yrOg(Ijjbi)39TiBw4qzerq1CNXqPWWxalol8CX0WgzjNLre6DUXgQ0Rs9TiBw4H8SmIqVZfOa2uapKVxZDic9oxDSVc85bu(JbEiplJi07CbkGnfWXJjyTbwsEpQmMyUVW8uOaKnpcV7MScuaBka5Xd6yfs46BI)JQVT4cuaBka5Xd6yf4IfdLcyFhzI5(YIKVXcN0rQM7S8X195FlGAyJSSSLpUUp)BbudBRQP4)O6Blor0uG)7(1c45eahbs2vyYtfQvtww2Yhx3N)TaAtonf)hvFBXjIMc8F3VwapNa4iqYUctEQqTAYAk(pQ(2IVwqLkb1WrGKDfM8uHA1K1u8Fu9Tfx8fgeiBUV4iqYUctEQqTAY2JkJjM7lmpfkazZJW7UjRWIrVjM7lF8WtcLjbB9Ro8cGWuzmXCFH5PqbiBEeE3nzfOa2uaYJh0XkKW13w(46(8VfqnSjhQmMyUVW8uOaKnpcV7MSgsyf4NhHGAs46B7OaIqVZb5bIWCF5XqnqjaEiplBNXIqn8ftscq(V7Br2SWHYiIGQ5oJHsHHVawCw45IH8nYsolJi07CJnuPxL6Br2SWvFBLLre6DUafWMc4QVT2BVSm5oweQHdYdeH5(YJHAGsaCOmIiOYYK7yrOg(Ijjbi)39TiBw4qzerqTxZLpUUp)BbudBYHkdvgtm3xy(NdfG2WG8dqjGeU(2yrOgERXk4)U3WlaMdLrebvZXIqnCbkGnfWHYiIGQ5yrOgoipqeM7lpgQbkbWHYiIGQPChlc1Wxmjja5)UVfzZchkJicQektc2Anwb)NdfG87lgpPndj4LdIk)39SHkfSsaKqenf4)UFTaEobqYAbvQeudjcuaBkGKbKYJgc7zdi1jgsAnwb)39gEbWKmGuE0qypBaPoXqIafWMcqE8Gowbsa5bIWCF5XqnqjaQmMyUVW8phkaT7MSyq(bOeqcxFBSiudV1yf8F3B4faZHYiIGQ5yrOgUafWMc4qzerq1uUJfHA4G8aryUV8yOgOeahkJicQMYDSiudFXKKaK)7(wKnlCOmIiOsOmjyR1yf8FouaYtAZqcE5GOY)DpBOsbReajertb(V7xlGNtaKSwqLkb1qIafWMcizaP8OHWE2asDIHKwJvW)DVHxamjdiLhne2ZgqQtmKiqbSPaKhpOJvGKbKYJgc7zdi1jgQmMyUVW8phkaT7MSyq(bOeqcxFBSiudV1yf8F3B4faZHYiIGQ5yrOgUafWMc4qzerq1CSiudhKhicZ9Lhd1aLa4qzerq1CSiudFXKKaK)7(wKnlCOmIiOsOmjyR1yf8FouaYVVy8K(N0qcE5GOY)DpBOsbReajertb(V7xlGNtaKSwqLkb1qIafWMcizaP8OHWE2asDIHKwJvW)DVHxamjdiLhne2ZgqQtmKSyssaY)DFlYMfsa5bIWCF5XqnqjaQmMyUVW8phkaT7MSyq(bOeqcxFBSiudV1yf8F3B4faZHYiIGQ5yrOgUafWMc4qzerq1uUJfHA4G8aryUV8yOgOeahkJicQMJfHA4lMKeG8F33ISzHdLrebvcLjbBTgRG)ZHcqEs)tAibVCqu5)UNnuPGvcGeIOPa)39RfWZjaswlOsLGAirGcytbKmGuE0qypBaPoXqsRXk4)U3WlaMKbKYJgc7zdi1jgswmjja5)UVfzZcjdiLhne2ZgqQtmuzmXCFH5FouaA3nzXG8dqjGeU(2yrOgERXk4)U3WlaMdLrebvZXIqn8RKF4W3CFXHYiIGkHYKGTwJvW)5qbipPvjFsWlhev(V7zdvkyLaiHiAkW)D)Ab8CcGK1cQujOgsUs(HdFZ9fjgBOsVk13ISzHKwJvW)DVHxaSJHnGW3xUKilzw2)KBmRkzolKUvTkhtRHQRsXogstJ9(LePvsnwiHQP6exaQ(KYF0q19hr1n6NdfGAuQgbYpCiqr14xcOAlmVKnGIQflwLcyovM95vavZcju9(UWH88hnGIQnXCFr1nkgKFakb0OCQm7ZRaQMmsO69DHd55pAafvBI5(IQBumi)aucOr5uz2Nxbu9QiHQ33foKN)ObuuTjM7lQUrXG8dqjGgLtLzFEfq1YHeQEFx4qE(Jgqr1MyUVO6gfdYpaLaAuovM95vavtksO69DHd55pAafvBI5(IQBumi)aucOr5uzOYqAAS3VKiTsQXcjunvN4cq1Nu(JgQU)iQUrvq3cXPrPAei)WHafvJFjGQTW8s2akQwSyvkG5uz2NxbunlKq177chYZF0akQ2eZ9fv3OwyEVnJjyTr5uzOYqAjL)Obuu9(GQnXCFr1XdpyovghJfMLh5yyojsBht8Wd2LOJ5ZHcqUeDjXIlrhdugreuUvCmMyUVCmyq(bOeGJPmjWX0ASc(phka53xmEsBgsWlhev(V7zdvkyLaiHiAkW)D)Ab8CcGK1cQujOgseOa2uajdiLhne2ZgqQtmK0ASc(V7n8cGjzaP8OHWE2asDIHebkGnfG84bDScKaYdeH5(YJHAGsaogb6gaDMJzSiudV1yf8F3B4faZHYiIGIQBs1JfHA4cuaBkGdLrebfv3KQhlc1Wb5bIWCF5XqnqjaougreuuDtQwUu9yrOg(Ijjbi)39TiBw4qzerq5gxsK5s0XaLrebLBfhJjM7lhdgKFakb4yktcCmTgRG)ZHcqEsBgsWlhev(V7zdvkyLaiHiAkW)D)Ab8CcGK1cQujOgseOa2uajdiLhne2ZgqQtmK0ASc(V7n8cGjzaP8OHWE2asDIHebkGnfG84bDScKmGuE0qypBaPoX4yeOBa0zoMXIqn8wJvW)DVHxamhkJickQUjvpweQHlqbSPaougreuuDtQwUu9yrOgoipqeM7lpgQbkbWHYiIGIQBs1YLQhlc1Wxmjja5)UVfzZchkJick34sAvUeDmqzerq5wXXyI5(YXGb5hGsaoMYKahtRXk4)COaKFFX4j9pPHe8YbrL)7E2qLcwjasiIMc8F3VwapNaizTGkvcQHebkGnfqYas5rdH9SbK6edjTgRG)7EdVaysgqkpAiSNnGuNyizXKKaK)7(wKnlKaYdeH5(YJHAGsaogb6gaDMJzSiudV1yf8F3B4faZHYiIGIQBs1JfHA4cuaBkGdLrebfv3KQhlc1Wb5bIWCF5XqnqjaougreuuDtQESiudFXKKaK)7(wKnlCOmIiOCJlj54s0XaLrebLBfhJjM7lhdgKFakb4yktcCmTgRG)ZHcqEs)tAibVCqu5)UNnuPGvcGeIOPa)39RfWZjaswlOsLGAirGcytbKmGuE0qypBaPoXqsRXk4)U3WlaMKbKYJgc7zdi1jgswmjja5)UVfzZcjdiLhne2ZgqQtmogb6gaDMJzSiudV1yf8F3B4faZHYiIGIQBs1JfHA4cuaBkGdLrebfv3KQLlvpweQHdYdeH5(YJHAGsaCOmIiOO6Mu9yrOg(Ijjbi)39TiBw4qzerq5gxsKYLOJbkJick3kogtm3xogmi)aucWXuMe4yAnwb)NdfG8KwL8jbVCqu5)UNnuPGvcGeIOPa)39RfWZjaswlOsLGAi5k5ho8n3xKySHk9QuFlYMfsAnwb)39gEbWogb6gaDMJzSiudV1yf8F3B4faZHYiIGIQBs1JfHA4xj)WHV5(IdLrebLBCJJrbDlehxIUKyXLOJXeZ9LJXcZ7TzmbRogOmIiOCR4gxsK5s0XyI5(YXGaIaRGJbkJick3kUXL0QCj6yGYiIGYTIJXeZ9LJryXO3eZ9LpE4XXep84ltcCmFouaYnUKKJlrhdugreuUvCmMyUVCmclg9MyUV8XdpoM4HhFzsGJr8Fu9Tf2nUKiLlrhdugreuUvCmMyUVCmclg9MyUV8XdpoM4HhFzsGJjfkazZJWUXnoMCeiEjcBCj6sIfxIogOmIiOCR4gxsK5s0XaLrebLBf34sAvUeDmqzerq5wXnUKKJlrhdugreuUvCJljs5s0XyI5(YXK)Z9LJbkJick3kUXnogX)r13wyxIUKyXLOJbkJick3koMYKahdYACQqXk2tCPEeO8eHz(YXyI5(YXGSgNkuSI9exQhbkpryMVCJljYCj6yGYiIGYTIJXeZ9LJzna7x(2iGCmc0na6mhdrO35gBOsVk13ISzHhYP6SmQMi07CbkGnfWd5uDtQMi07CbkGnfWXJjyLQ3OAws2XuMe4ywdW(LVnci34sAvUeDmqzerq5wXXyI5(YXW(SO)7ERojBaLNi(VYXiq3aOZCm7q1eHENBSHk9QuFlYMfEiNQZYOAIqVZfOa2uapKt1nPAIqVZfOa2uahbs2vyQUbQML9NQ3JQZYO6DOAX)r13wCJnuPxL6Br2SWrGKDfMQjNQxvYuDwgvl(pQ(2IlqbSPaocKSRWun5u9QsMQ3ZXuMe4yyFw0)DVvNKnGYte)x5gxsYXLOJbkJick3kogtm3xog1)syFpGw3Xiq3aOZCmeHENBSHk9QuFlYMfEiNQZYOAIqVZfOa2uapKt1nPAIqVZfOa2uahbs2vyQUbQML93XuMe4yu)lH99aAD34sIuUeDmqzerq5wXXyI5(YXKArqyXiGWEcWy1Xiq3aOZCmeHENBSHk9QuFlYMfEiNQZYOAIqVZfOa2uapKt1nPAIqVZfOa2uahbs2vyQUbQMfs5yktcCmPweewmciSNamwDJlP9HlrhdugreuUvCmMyUVCmeRN(f4jaWBrjRmHJrGUbqN5yic9o3ydv6vP(wKnl8qovNLr1eHENlqbSPaEi3XuMe4yiwp9lWtaG3Iswzc34sI05s0XaLrebLBfhJjM7lhJeGawNfd77wL6yeOBa0zoMDOA5s1i7uEGnud3ukmhK3HhmvNLr1i7uEGnud3ukm)kQMCQMfsr17r1zzunohIr)yOuyWC1X(kWJNhjr1KVr1K5yktcCmsacyDwmSVBvQBCjT)UeDmqzerq5wXXyI5(YXKhdLcqeGHuyFpAywDmc0na6mhdrO35gBOsVk13ISzHhYP6SmQMi07CbkGnfWd5uDtQMi07CbkGnfWXJjyLQjFJQzjzQolJQf)hvFBXn2qLEvQVfzZchbs2vyQMCQwoKIQZYOA5s1eHENlqbSPaEiNQBs1I)JQVT4cuaBkGJaj7kmvtovlhs5yktcCm5XqPaebyif23JgMv34sQX4s0XaLrebLBfhJjM7lhdbGWaIvaH9Rfwl4yeOBa0zogIqVZn2qLEvQVfzZcpKt1zzunrO35cuaBkGhYP6MunrO35cuaBkGJhtWkvt(gvZsYuDwgvl(pQ(2IBSHk9QuFlYMfocKSRWun5uTCifvNLr1YLQjc9oxGcytb8qov3KQf)hvFBXfOa2uahbs2vyQMCQwoKYXuMe4yiaegqSciSFTWAb34sILKDj6yGYiIGYTIJXeZ9LJbkveWy)CLyciW)DFhzI5(YI(8Vfqogb6gaDMJHi07CJnuPxL6Br2SWd5uDwgvte6DUafWMc4HCQUjvte6DUafWMc44XeSs1KVr1SKmvNLr1I)JQVT4gBOsVk13ISzHJaj7kmvtovlhsr1zzuT4)O6BlUafWMc4iqYUct1Kt1YHuoMYKahduQiGX(5kXeqG)7(oYeZ9Lf95FlGCJljwyXLOJbkJick3kogtm3xoMCWqrV6ydiSx8s5gg7yeOBa0zogIqVZn2qLEvQVfzZcpKt1zzunrO35cuaBkGhYP6MunrO35cuaBkGJhtWkvt(gvZsYoMYKahtoyOOxDSbe2lEPCdJDJljwiZLOJbkJick3kogtm3xoM(HWJxYga7X5RNgnm2Xiq3aOZCmeHENBSHk9QuFlYMfEiNQZYOAIqVZfOa2uapKt1nPAIqVZfOa2uahbs2vyQUHnQMfs5yktcCm9dHhVKna2JZxpnAySBCjXYQCj6yGYiIGYTIJXeZ9LJPD5qX2RsX(8yqYsbhJaDdGoZXqe6DUXgQ0Rs9TiBw4HCQolJQjc9oxGcytb8qov3KQjc9oxGcytbCeizxHP6g2OAYs2XuMe4yAxouS9QuSppgKSuWnUKyroUeDmqzerq5wXXyI5(YXOqGP8PrtD28iSNWuPGJrGUbqN5yic9o3ydv6vP(wKnl8qovNLr1eHENlqbSPaEiNQBs1eHENlqbSPaocKSRWuDdBunzj7yktcCmkeykFA0uNnpc7jmvk4gxsSqkxIogOmIiOCR4ymXCF5yuiWuEdNFiRgSxcuwmEF5yeOBa0zogIqVZn2qLEvQVfzZcpKt1zzunrO35cuaBkGhYP6MunrO35cuaBkGJaj7kmv3WgvtwYoMYKahJcbMYB48dz1G9sGYIX7l34sIL9HlrhdugreuUvCmc0na6mhZounrO35eX)vXaE4iWedvNLr1eHENBSHk9QuFlYMfEiNQZYOAIqVZfOa2uapKt1nPAIqVZfOa2uahbs2vyQUbQMmsr1zzu9yOuy4Zjb(59QdO6g2OA5KmvVNJXeZ9LJjGb)nGe2nUKyH05s0XaLrebLBfhJaDdGoZXSdvte6Dor8FvmGhocmXq1zzunrO35gBOsVk13ISzHhYP6SmQMi07CbkGnfWd5uDtQMi07CbkGnfWrGKDfMQBGQjJuuDwgvpgkfg(CsGFEV6aQUHnQwojt175ymXCF5yY)5(YnUKyz)Dj6yGYiIGYTIJrGUbqN5yW5qm6hdLcdMhV0Lb7xlOsLGAOAY3OAYO6SmQEhQwUunYoLhyd1WnLcZb5D4bt1zzunYoLhyd1WnLcZVIQjNQjDKIQ3ZXyI5(YXeV0Lb7xlOsLGACJljwAmUeDmqzerq5wXXiq3aOZCmeHENBSHk9QuFlYMfEiNQZYOAIqVZfOa2uapKt1nPAIqVZfOa2uahpMGvQEJQzjzhJjM7lht)qar8FLBCjrwYUeDmMyUVCm4LdIk)39SHkfSsaogOmIiOCR4gxsKXIlrhdugreuUvCmc0na6mhdrO35xj)WHV5(IhYP6SmQwUu9yrOg(vYpC4BUV4qzerq5ymXCF5ym2qLEvQVfzZIBCjrgzUeDmqzerq5wXXiq3aOZCmlFCDF(3ciQM8nQwoogtm3xogbkGnf4g34y6xD4faHDj6sIfxIog2wmaogCoeJ(XqPWG5QJ9vGhppsIQjFJQxfvNLr1YLQhlc1Wrx6YaFa7zdi1jgougreuuDtQESiudxDSVc8RfuPsqnCOmIiOO6MunohIr)yOuyWC1X(kWJNhjr1KVr1Kr1zzuT14a0naxDSVc8OlDz4qzerqr1nPARXbOBaU6yFf4rx6YWrwXkvt(gvtgv3KQhdLcdFbS4SWZfdv3WgvtwYuDtQMi07C1X(kWJU0LHR(2YXaLrebLBfhJjM7lhdBdDgreCmSnKVmjWXOWEHHhJicUXLezUeDmqzerq5wXXiq3aOZCmeHENFL8dh(M7lU6BlQolJQjc9o)k5ho8n3xCeizxHP6gOAsr1nP6LpUUp)Bbevt(gvVkQolJQhlc1Wb5bIWCF5XqnqjaougreuuDtQw8Fu9TfhKhicZ9Lhd1aLa4iqYUct1nq1SKmv3KQjc9o)k5ho8n3xCeizxHP6gOAwifvNLr1I)JQVT4gBOsVk13ISzHJaj7kmv3avZcPO6MunrO35xj)WHV5(IJaj7kmv3avtwYuDtQE5JR7Z)war1KVr1RYXyI5(YXCL8dh(M7l34sAvUeDmqzerq5wXXiq3aOZCm4Cig9JHsHbZvh7RapEEKev3WgvVkQUjvVdvlxQESiudxGcytbCOmIiOO6SmQw8Fu9TfxGcytbCeizxHPAYP6uHIQxnvtgvVNJXeZ9LJbKhicZ9Lhd1aLaCJlj54s0XaLrebLBfhJaDdGoZXW2qNrebUc7fgEmIiq1nPAIqVZvh7RaFEaL)yGJatmogtm3xog1X(kWJNhj5gxsKYLOJbkJick3kogb6gaDMJHTHoJicCf2lm8yerGQBs17q1YLQhlc1WfOa2uahkJickQolJQf)hvFBXfOa2uahbs2vyQMCQovOO6vt1Kr175ymXCF5yuh7RapEEKKBCjTpCj6yGYiIGYTIJrGUbqN5yic9oxDSVc85bu(JbocmXq1nP6DOA5s1JfHA4G8aryUV8yOgOeahkJickQolJQf)hvFBXb5bIWCF5XqnqjaocKSRWun5uDQqr175ymXCF5ygqkpAiSNnGuNyCJljsNlrhdugreuUvCmc0na6mhZouTCP6XIqnCbkGnfWHYiIGIQZYOAX)r13wCbkGnfWrGKDfMQjNQtfkQE1unzu9EuDtQEhQwUu9yrOgoipqeM7lpgQbkbWHYiIGIQZYOAIqVZfOa2uapKt1nPAIqVZfOa2uahpMGvQUbQMLKP6SmQw8Fu9TfhKhicZ9Lhd1aLa4iqYUct1Kt1PcfvVAQMmQEphJjM7lhZas5rdH9SbK6eJBCJJjfkazZJWUeDjXIlrhdBlgahZouTCP6XIqn8ftscq(V7Br2SWHYiIGIQZYO6XqPWWxalol8CXq1KVr1KLmv3KQ3HQjc9o3ydv6vP(wKnlC13wuDwgvte6DUafWMc4QVTO69O69Cmqzerq5wXXyI5(YXW2qNrebhdBd5ltcCmK(N04gxsK5s0XaLrebLBfhJjM7lhJWIrVjM7lF8WJJrGUbqN5yw(46(8Vfqun5BunPCmXdp(YKaht)QdVaiSBCjTkxIogOmIiOCR4yeOBa0zoMDOA5s1i7uEGnud3ukmhK3HhmvNLr1i7uEGnud3ukm)kQMCQMfsr17r1nP6DO6LpUUp)Bbev3WgvNmvNLr1lFCDF(3ciQEJQzHQBs1I)JQVT4ertb(V7xlGNtaCeizxHPAYP6uHIQ3ZXyI5(YX0ASc(V7n8cGDJlj54s0XaLrebLBfhJaDdGoZXS8X195FlGO6g2OAYO6SmQEhQE5JR7Z)war1Bu9QO6Mu9ouT4)O6Bl(Ijjbi)39TiBw4iqYUct1Kt1PcfvVAQMmQolJQzBOZiIaN0)KgQEpQEphJjM7lhdr0uG)7(1c45eGBCjrkxIogOmIiOCR4yeOBa0zoMLpUUp)Bbev3WgvtgvNLr17q1lFCDF(3ciQUHnQwouDtQEhQw8Fu9TfNiAkW)D)Ab8CcGJaj7kmvtovNkuu9QPAYO6SmQMTHoJicCs)tAO69O69CmMyUVCmRfuPsqnUXL0(WLOJbkJick3kogb6gaDMJz5JR7Z)war1nSr1YXXyI5(YXSyssaY)DFlYMf34sI05s0XaLrebLBfhJaDdGoZXS8X195FlGO6g2OAYO6SmQE5JR7Z)war1nSr1RIQBs1I)JQVT4ertb(V7xlGNtaCeizxHPAYP6uHIQxnvtgvNLr1lFCDF(3ciQEJQLdv3KQf)hvFBXjIMc8F3VwapNa4iqYUct1Kt1PcfvVAQMmQUjvl(pQ(2IVwqLkb1WrGKDfMQjNQtfkQE1unzogtm3xogXxyqGS5(YnUK2FxIogOmIiOCR4ymXCF5yewm6nXCF5JhECmc0na6mhZyrOg(Ijjbi)39TiBw4qzerqr1nP6DO6XqPWWxalol8CXq1nSr1KLmvNLr1eHENBSHk9QuFlYMfEiNQZYOAIqVZfOa2uapKt17r1nP6DOAIqVZvh7RaFEaL)yGhYP6SmQMi07CbkGnfWXJjyLQBGQzjzQEpht8WJVmjWX0V6Wlac7gxsngxIogOmIiOCR4yeOBa0zogX)r13wCbkGnfG84bDScCXIHsbSVJmXCFzrQM8nQMfoPJuuDtQEhQE5JR7Z)war1nSr1Kr1zzu9Yhx3N)TaIQByJQxfv3KQf)hvFBXjIMc8F3VwapNa4iqYUct1Kt1PcfvVAQMmQolJQx(46(8Vfqu9gvlhQUjvl(pQ(2Itenf4)UFTaEobWrGKDfMQjNQtfkQE1unzuDtQw8Fu9TfFTGkvcQHJaj7kmvtovNkuu9QPAYO6MuT4)O6BlU4lmiq2CFXrGKDfMQjNQtfkQE1unzu9Eogtm3xogbkGnfG84bDScUXLelj7s0XaLrebLBfhJjM7lhJWIrVjM7lF8WJJjE4XxMe4y6xD4faHDJljwyXLOJbkJick3kogb6gaDMJz5JR7Z)war1nSr1YXXyI5(YXiqbSPaKhpOJvWnUKyHmxIogOmIiOCR4yeOBa0zoMDOAfqe6DoipqeM7lpgQbkbWd5uDwgvVdvpweQHVyssaY)DFlYMfougreuuDtQEhQEmukm8fWIZcpxmun5Bunzjt1zzunrO35gBOsVk13ISzHR(2IQZYOAIqVZfOa2uax9TfvVhvVhvNLr1YLQhlc1Wb5bIWCF5XqnqjaougreuuDwgvlxQESiudFXKKaK)7(wKnlCOmIiOO69O6Mu9Yhx3N)TaIQByJQLJJXeZ9LJXqcRa)8ieuJBCJBCJBCoa]] )


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
