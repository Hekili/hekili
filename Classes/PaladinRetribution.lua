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

    
    spec:RegisterPack( "Retribution", 20180930.1733, [[dGurgbqiIkEKiuAtsjFseQgLsLofIOvjvrVsPIzjcULufQDr4xeLgMukhJOyzOKEMiKPruLRHizBisfFtQcghIqDoePuRtPQ5jLQ7Pu2hIYbrKsSqPk9qePsxerq(iIusJerQ6KicQvIsmtebStrudvekwkIqEkkMQiYvreOVIif7Lk)LQgmPomLfJWJr1Kj5YGnRKplsJwQCAvwTuvEnIQzl42ez3s(TQgUOCCIQA5qEoutxX1fA7OuFxunEIkDEPQA9sviZxk2ps7KXLKJrzd4sM12KHe3gPDIAtitpKOejphZ0Fg4yYmo5wk4yktcCmKiyqhrCUVCmzw)H3uUKCm4pI4GJPBMm8EzLn9MUiHG)sYIpPyWM7loYwJS4tIllr4jKLyz9yfWw2m0VUaGLnPdqSkJSjXQm(eJfm1vEsemOJio3xc8jXDmeXlmKWLJWXOSbCjZABYqIBJ0orTjKPhseRjsghdod4UK7H2CmDNsbLJWXOam3XKyPAsemOJio3xuDIXcM6kkljwQUBMm8EzLn9MUiHG)sYIpPyWM7loYwJS4tIllr4jKLyz9yfWw2m0VUaGLnXGasKDkSSjgsKpXybtDLNebd6iIZ9LaFsCkljwQMbYgqIaquDIAlbQM12KHet19yQwMEyFIAZXKH(1fahtILQjrWGoI4CFr1jglyQROSKyP6UzYW7Lv20B6Iec(ljl(KIbBUV4iBnYIpjUSeHNqwIL1JvaBzZq)6caw2edcir2PWYMyir(eJfm1vEsemOJio3xc8jXPSKyPAgiBajcar1jQTeOAwBtgsmv3JPAz6H9jQnkluwsSunjKCbECafvtaRhbun)LiSHQjG0RWcQM0cNdzdMQRV6XDgsAfduTXN7lmv)vOFbLfJp3xyrgc4VeHnBRGHjNYIXN7lSidb8xIWMD2KD9VIYIXN7lSidb8xIWMD2K1IPsqn2CFrzjXs1mLLH7(HQr2POAI4AbkQgp2GPAcy9iGQ5VeHnunbKEfMQTsr1ziOhN9ZCvkvFyQw9fiOSy85(clYqa)LiSzNnzXLLH7(XJhBWuwm(CFHfziG)se2SZMSz)CFrzHYsILQjHKlWJdOOAGnG6NQNtcO6PdOAJppIQpmvBSTlyebqqzX4Z9fEZIZ7Tzmo5uwm(CFH3ztweqejhOSy85(cVZMSCle8gFUV8HdpjuMeS9zqbiklgFUVW7Sjl3cbVXN7lF4WtcLjbB8)dQpVWuwm(CFH3ztwUfcEJp3x(WHNektc2sHcq28imLfklgFUVWc()b1Nx4Tig83asjuMeSHSEKkwKJ9exQhbkprCMVOSy85(cl4)huFEH3zt2ig83asjuMeS1hG9DFEaqjCRnI4Ajm2qLEvQphztNiM10qexlbhfXMceXSweX1sWrrSPabEmo5BY0gLfJp3xyb))G6Zl8oBYgXG)gqkHYKGn2Nf8)YB1jzdO8eH)vjCRTDjIRLWydv6vP(CKnDIywtdrCTeCueBkqeZArexlbhfXMceiqYUc3UmKys20Sl))G6ZlHXgQ0Rs95iB6eiqYUctwIARPH)Fq95LGJIytbceizxHjlrTrsklgFUVWc()b1Nx4D2KnIb)nGucLjbBQ)LW(ve1Fc3AJiUwcJnuPxL6Zr20jIznneX1sWrrSParmRfrCTeCueBkqGaj7kC7YqIPSy85(cl4)huFEH3zt2ig83asjuMeSLAbGBHaGWEcWipHBTrexlHXgQ0Rs95iB6eXSMgI4Aj4Oi2uGiM1IiUwcokInfiqGKDfUDzifLfJp3xyb))G6Zl8oBYgXG)gqkHYKGnI(t)c8ea4TGKvgpHBTrexlHXgQ0Rs95iB6eXSMgI4Aj4Oi2uGiMrzX4Z9fwW)pO(8cVZMSrm4VbKsOmjytcqa5tNH9lRst4wB7khKDkpWgQrykfwaY9WdUPbzNYdSHAeMsHfxrMmKIKnn4mie8JHsHbluh7RapEEKezBSszX4Z9fwW)pO(8cVZMSrm4VbKsOmjyllelfGiadPW(vWWKNWT2iIRLWydv6vP(CKnDIywtdrCTeCueBkqeZArexlbhfXMce4X4Kt2MmT10W)pO(8sySHk9QuFoYMobcKSRWKjps10ihI4Aj4Oi2uGiM1I)Fq95LGJIytbceizxHjtEKIYIXN7lSG)Fq95fENnzJyWFdiLqzsWgbGWaICaH99f7lMWT2iIRLWydv6vP(CKnDIywtdrCTeCueBkqeZArexlbhfXMce4X4Kt2MmT10W)pO(8sySHk9QuFoYMobcKSRWKjps10ihI4Aj4Oi2uGiM1I)Fq95LGJIytbceizxHjtEKIYIXN7lSG)Fq95fENnzJyWFdiLqzsWguQaGX(5k(erG)x(fY4Z9Lf8zFoGs4wBeX1sySHk9QuFoYMormRPHiUwcokInfiIzTiIRLGJIytbc8yCYjBtM2AA4)huFEjm2qLEvQphztNabs2vyYKhPAA4)huFEj4Oi2uGabs2vyYKhPOSy85(cl4)huFEH3zt2ig83asjuMeSLbgk4vhBaH98xkZW4eU1grCTegBOsVk1NJSPteZAAiIRLGJIytbIywlI4Aj4Oi2uGapgNCY2KPnklgFUVWc()b1Nx4D2KnIb)nGucLjbBRdHhVKna2JZ6pnyyCc3AJiUwcJnuPxL6Zr20jIznneX1sWrrSParmRfrCTeCueBkqGaj7kC7BYqkklgFUVWc()b1Nx4D2KnIb)nGucLjbB5DhkKFvk2NfIswkKWT2iIRLWydv6vP(CKnDIywtdrCTeCueBkqeZArexlbhfXMceiqYUc3(gRTrzX4Z9fwW)pO(8cVZMSrm4VbKsOmjytHat5tdM6S5rypHPsHeU1grCTegBOsVk1NJSPteZAAiIRLGJIytbIywlI4Aj4Oi2uGabs2v423yTnklgFUVWc()b1Nx4D2KnIb)nGucLjbBkeykVHZoKvd2lbkleUVs4wBeX1sySHk9QuFoYMormRPHiUwcokInfiIzTiIRLGJIytbceizxHBFJ12OSy85(cl4)huFEH3zt2ig83as4eU12UeX1sySHk9QuFoYMormRPHiUwcokInfiIzgFUVWc()b1Nx4D2Kn7N7ReU12UeX1sqe(xfI4rGaJpnneX1sySHk9QuFoYMormRPHiUwcokInfiIzTiIRLGJIytbceizxHBNvs10mgkfgXCsGFEV6G23KxBKKYIXN7lSG)Fq95fENnzdxA3G99fvPsqnjCRnCgec(XqPWGfHlTBW((IQujOgY2yTPzx5GSt5b2qnctPWcqUhEWnni7uEGnuJWukS4kY6bsrsklgFUVWc()b1Nx4D2KDDiGi8VkHBTrexlHXgQ0Rs95iB6eXSMgI4Aj4Oi2uGiM1IiUwcokInfiWJXjFtM2OSy85(cl4)huFEH3ztwC3bbL)xE2qLcwXbklgFUVWc()b1Nx4D2K1ydv6vP(CKnDjCRnI4AjUs(XdFZ9LiM10iNXcqnIRKF8W3CFjGYicGIYIXN7lSG)Fq95fENnz5Oi2uqc3AR7d97Z(Car2M8OSqzX4Z9fwSU6WDacVX2qNreGektc2uyp3WJreGeyBHiSHZGqWpgkfgSqDSVc845rsKTLOMg5mwaQrGU0Ub(i2ZgqQJpcOmIaOAnwaQrOo2xb((IQujOgbugrauTWzqi4hdLcdwOo2xbE88ijY2yTPX6ra6gqOo2xbE0L2ncOmIaOAz9iaDdiuh7Rap6s7gbYkYjBJ1wJHsHr0bwy6ez8P9nwBRfrCTeQJ9vGhDPDJq95fLfJp3xyX6Qd3bi8oBYEL8Jh(M7ReU1grCTexj)4HV5(sO(8QPHiUwIRKF8W3CFjqGKDfUDs1Q7d97Z(Car2wIAAgla1ia5c84CF5XqnqXbbugrauT4)huFEja5c84CF5XqnqXbbcKSRWTltBTiIRL4k5hp8n3xceizxHBxgs10W)pO(8sySHk9QuFoYMobcKSRWTldPArexlXvYpE4BUVeiqYUc3oRT1Q7d97Z(Car2wIOSy85(clwxD4oaH3ztwqUapo3xEmuduCiHBTHZGqWpgkfgSqDSVc845rsTVLOw7kNXcqncokInfiGYicGQPH)Fq95LGJIytbceizxHjlLR6jRKKYIXN7lSyD1H7aeENnzvh7RapEEKuc3AJTHoJiacf2Zn8yebOfrCTeQJ9vGplIYEmiqGXhklgFUVWI1vhUdq4D2KvDSVc845rsjCRn2g6mIaiuyp3WJreGw7kNXcqncokInfiGYicGQPH)Fq95LGJIytbceizxHjlLR6jRKKYIXN7lSyD1H7aeENnzhqklyiSNnGuhFs4wBeX1sOo2xb(Sik7XGabgFATRCgla1ia5c84CF5XqnqXbbugraunn8)dQpVeGCbECUV8yOgO4Gabs2vyYs5ksszX4Z9fwSU6WDacVZMSdiLfme2ZgqQJpjCRTDLZybOgbhfXMceqzebq10W)pO(8sWrrSPabcKSRWKLYv9Kvs2Ax5mwaQraYf4X5(YJHAGIdcOmIaOAAiIRLGJIytbIywlI4Aj4Oi2uGapgN82LPTMg()b1NxcqUapo3xEmuduCqGaj7kmzPCvpzLKuwOSy85(clsHcq28i8gBdDgrasOmjyJ0)KMeyBHiSTRCgla1i6mjja5)LphztNakJiaQMMXqPWi6almDIm(q2gRT1AxI4Ajm2qLEvQphztNq95vtdrCTeCueBkqO(8IKKKYIXN7lSifkazZJW7Sjl3cbVXN7lF4WtcLjbBRRoChGWjCRTUp0Vp7ZbezBKIYIXN7lSifkazZJW7SjBUro4)L3WDaoHBTTRCq2P8aBOgHPuybi3dp4MgKDkpWgQrykfwCfzYqks2A3Up0Vp7Zbu7BT1009H(9zFoG2KPf))G6ZlbrWuG)x((I454Gabs2vyYs5ksszX4Z9fwKcfGS5r4D2KLiykW)lFFr8CCiHBT19H(9zFoGAFJ1MMD7(q)(SphqBjQ1U8)dQpVeDMKeG8)YNJSPtGaj7kmzPCvpzTPHTHoJiacs)tAijjPSy85(clsHcq28i8oBY2xuLkb1KWT26(q)(SphqTVXAtZUDFOFF2NdO23KxRD5)huFEjicMc8)Y3xephheiqYUctwkx1twBAyBOZicGG0)KgsssklgFUVWIuOaKnpcVZMSDMKeG8)YNJSPlHBT19H(9zFoGAFtEuwm(CFHfPqbiBEeENnz5FHboYM7ReU1w3h63N95aQ9nwBA6(q)(SphqTVLOw8)dQpVeebtb(F57lINJdceizxHjlLR6jRnnDFOFF2NdOn51I)Fq95LGiykW)lFFr8CCqGaj7kmzPCvpzTf))G6ZlrFrvQeuJabs2vyYs5QEYkLfJp3xyrkuaYMhH3ztwUfcEJp3x(WHNektc2wxD4oaHt4wBJfGAeDMKeG8)YNJSPtaLreavRDhdLcJOdSW0jY4t7BS2wtdrCTegBOsVk1NJSPteZAAiIRLGJIytbIygjBTlrCTeQJ9vGplIYEmiIznneX1sWrrSPabEmo5TltBKKYIXN7lSifkazZJW7SjlhfXMcqE8GoYHeU1g))G6ZlbhfXMcqE8GoYbbVZqPa2VqgFUVSazBYi6bs1A3Up0Vp7Zbu7BS2009H(9zFoGAFlrT4)huFEjicMc8)Y3xephheiqYUctwkx1twBA6(q)(SphqBYRf))G6ZlbrWuG)x((I454Gabs2vyYs5QEYAl()b1NxI(IQujOgbcKSRWKLYv9K1w8)dQpVe8VWahzZ9Labs2vyYs5QEYkjPSy85(clsHcq28i8oBYYTqWB85(Yho8KqzsW26Qd3bimLfJp3xyrkuaYMhH3ztwokInfG84bDKdjCRTUp0Vp7Zbu7BYJYIXN7lSifkazZJW7SjRH4wb(5riOMeU12UkGiUwcqUapo3xEmuduCqeZAA2DSauJOZKKaK)x(CKnDcOmIaOAT7yOuyeDGfMorgFiBJ12AAiIRLWydv6vP(CKnDc1NxnneX1sWrrSPaH6ZlssYMg5mwaQraYf4X5(YJHAGIdcOmIaOAAKZybOgrNjjbi)V85iB6eqzebqrYwDFOFF2NdO23KhLfklgFUVWIpdkaTHb5hHIdjCRTXcqnICJCW)lVH7aSakJiaQwJfGAeCueBkqaLreavRXcqncqUapo3xEmuduCqaLreavl5mwaQr0zssaY)lFoYMobugraujuMeSLBKd(pdka5jHy8KUm7XDheu(F5zdvkyfh2temf4)LVViEooSVVOkvcQzphfXMc2pGuwWqypBaPo(Sp3ih8)YB4oaVFaPSGHWE2asD8zphfXMcqE8GoYH9GCbECUV8yOgO4aLfJp3xyXNbfG2ztwmi)iuCiHBTnwaQrKBKd(F5nChGfqzebq1ASauJGJIytbcOmIaOAjNXcqncqUapo3xEmuduCqaLreavl5mwaQr0zssaY)lFoYMobugraujuMeSLBKd(pdka5jDz2J7oiO8)YZgQuWkoSNiykW)lFFr8CCyFFrvQeuZEokInfSFaPSGHWE2asD8zFUro4)L3WDaE)aszbdH9SbK64ZEokInfG84bDKd7hqklyiSNnGuhFOSy85(cl(mOa0oBYIb5hHIdjCRTXcqnICJCW)lVH7aSakJiaQwJfGAeCueBkqaLreavRXcqncqUapo3xEmuduCqaLreavRXcqnIotscq(F5Zr20jGYicGkHYKGTCJCW)zqbipjeJN0)KM94Udck)V8SHkfSId7jcMc8)Y3xephh23xuLkb1SNJIytb7hqklyiSNnGuhF2NBKd(F5nChG3pGuwWqypBaPo(SVZKKaK)x(CKnD7b5c84CF5XqnqXbklgFUVWIpdkaTZMSyq(rO4qc3ABSauJi3ih8)YB4oalGYicGQ1ybOgbhfXMceqzebq1soJfGAeGCbECUV8yOgO4GakJiaQwJfGAeDMKeG8)YNJSPtaLreavcLjbB5g5G)ZGcqEs)tA2J7oiO8)YZgQuWkoSNiykW)lFFr8CCyFFrvQeuZEokInfSFaPSGHWE2asD8zFUro4)L3WDaE)aszbdH9SbK64Z(otscq(F5Zr20TFaPSGHWE2asD8HYIXN7lS4ZGcq7SjlgKFekoKWT2gla1iYnYb)V8gUdWcOmIaOAnwaQrCL8Jh(M7lbugraujuMeSLBKd(pdka5jHl5Vh3Dqq5)LNnuPGvCyprWuG)x((I454W((IQujOM9xj)4HV5(AVXgQ0Rs95iB62NBKd(F5nChGDmSbe((YLmRTjdjUTEqMEq0MmjIuoMCdvxLIDmKgslKOKjHtM06EQMQtQdO6tk7rdvVEevN4FguakXPAei)4HafvJFjGQT48s2akQM3zvkGfuwibUcOAz2t1KGfoML9ObuuTXN7lQoXXG8JqXHexqzHe4kGQzDpvtcw4yw2Jgqr1gFUVO6ehdYpcfhsCbLfsGRaQor7PAsWchZYE0akQ24Z9fvN4yq(rO4qIlOSqcCfq1YBpvtcw4yw2Jgqr1gFUVO6ehdYpcfhsCbLfsGRaQMu7PAsWchZYE0akQ24Z9fvN4yq(rO4qIlOSqzH0qAHeLmjCYKw3t1uDsDavFszpAO61JO6exbllgMeNQrG8Jhcuun(LaQ2IZlzdOOAENvPawqzHe4kGQLzpvtcw4yw2Jgqr1gFUVO6e3IZ7Tzmo5jUGYcLfsyPShnGIQjDOAJp3xuD4WdwqzXXyXP7rogMtI01Xeo8GDj5y(mOaKljxYY4sYXaLreaLRxhJXN7lhdgKFeko4yktcCm5g5G)ZGcqEsigpPlZEC3bbL)xE2qLcwXH9ebtb(F57lINJd77lQsLGA2ZrrSPG9diLfme2ZgqQJp7ZnYb)V8gUdW7hqklyiSNnGuhF2ZrrSPaKhpOJCypixGhN7lpgQbko4y4OBa0zoMXcqnICJCW)lVH7aSakJiakQUfvpwaQrWrrSPabugrauuDlQESauJaKlWJZ9Lhd1afheqzebqr1TOA5q1JfGAeDMKeG8)YNJSPtaLreaLBCjZQljhdugrauUEDmgFUVCmyq(rO4GJPmjWXKBKd(pdka5jDz2J7oiO8)YZgQuWkoSNiykW)lFFr8CCyFFrvQeuZEokInfSFaPSGHWE2asD8zFUro4)L3WDaE)aszbdH9SbK64ZEokInfG84bDKd7hqklyiSNnGuhFCmC0na6mhZybOgrUro4)L3WDawaLreafv3IQhla1i4Oi2uGakJiakQUfvlhQESauJaKlWJZ9Lhd1afheqzebqr1TOA5q1JfGAeDMKeG8)YNJSPtaLreaLBCjNixsogOmIaOC96ym(CF5yWG8JqXbhtzsGJj3ih8FguaYtcX4j9pPzpU7GGY)lpBOsbR4WEIGPa)V89fXZXH99fvPsqn75Oi2uW(bKYcgc7zdi1XN95g5G)xEd3b49diLfme2ZgqQJp77mjja5)Lphzt3EqUapo3xEmuduCWXWr3aOZCmJfGAe5g5G)xEd3bybugrauuDlQESauJGJIytbcOmIaOO6wu9ybOgbixGhN7lpgQbkoiGYicGIQBr1JfGAeDMKeG8)YNJSPtaLreaLBCjlpxsogOmIaOC96ym(CF5yWG8JqXbhtzsGJj3ih8FguaYt6FsZEC3bbL)xE2qLcwXH9ebtb(F57lINJd77lQsLGA2ZrrSPG9diLfme2ZgqQJp7ZnYb)V8gUdW7hqklyiSNnGuhF23zssaY)lFoYMU9diLfme2ZgqQJpogo6gaDMJzSauJi3ih8)YB4oalGYicGIQBr1JfGAeCueBkqaLreafv3IQLdvpwaQraYf4X5(YJHAGIdcOmIaOO6wu9ybOgrNjjbi)V85iB6eqzebq5gxYKYLKJbkJiakxVogJp3xogmi)iuCWXuMe4yYnYb)NbfG8KWL83J7oiO8)YZgQuWkoSNiykW)lFFr8CCyFFrvQeuZ(RKF8W3CFT3ydv6vP(CKnD7ZnYb)V8gUdWogo6gaDMJzSauJi3ih8)YB4oalGYicGIQBr1JfGAexj)4HV5(saLreaLBCJJrbllggxsUKLXLKJX4Z9LJXIZ7Tzmo5ogOmIaOC96gxYS6sYXy85(YXGaIi5GJbkJiakxVUXLCICj5yGYicGY1RJX4Z9LJHBHG34Z9LpC4XXeo84ltcCmFguaYnUKLNljhdugrauUEDmgFUVCmCle8gFUV8HdpoMWHhFzsGJH)Fq95f2nUKjLljhdugrauUEDmgFUVCmCle8gFUV8HdpoMWHhFzsGJjfkazZJWUXnoMmeWFjcBCj5swgxsogOmIaOC96gxYS6sYXaLreaLRx34sorUKCmqzebq561nUKLNljhdugrauUEDJlzs5sYXy85(YXK9Z9LJbkJiakxVUXnog()b1NxyxsUKLXLKJbkJiakxVoMYKahdY6rQyro2tCPEeO8eXz(YXy85(YXGSEKkwKJ9exQhbkprCMVCJlzwDj5yGYicGY1RJX4Z9LJPpa77(8aGCmC0na6mhdrCTegBOsVk1NJSPteZO6MgQMiUwcokInfiIzuDlQMiUwcokInfiWJXjNQ3OAzAZXuMe4y6dW(Uppai34sorUKCmqzebq561Xy85(YXW(SG)xERojBaLNi8VYXWr3aOZCm7s1eX1sySHk9QuFoYMormJQBAOAI4Aj4Oi2uGiMr1TOAI4Aj4Oi2uGabs2vyQUDQwgsmvtsQUPHQ3LQ5)huFEjm2qLEvQphztNabs2vyQMmQorTr1nnun))G6ZlbhfXMceiqYUct1Kr1jQnQMKoMYKahd7Zc(F5T6KSbuEIW)k34swEUKCmqzebq561Xy85(YXO(xc7xru)ogo6gaDMJHiUwcJnuPxL6Zr20jIzuDtdvtexlbhfXMceXmQUfvtexlbhfXMceiqYUct1Tt1YqIDmLjbog1)sy)kI63nUKjLljhdugrauUEDmgFUVCmPwa4wiaiSNamYDmC0na6mhdrCTegBOsVk1NJSPteZO6MgQMiUwcokInfiIzuDlQMiUwcokInfiqGKDfMQBNQLHuoMYKahtQfaUfcac7jaJC34sM0XLKJbkJiakxVogJp3xogI(t)c8ea4TGKvg3XWr3aOZCmeX1sySHk9QuFoYMormJQBAOAI4Aj4Oi2uGiM5yktcCme9N(f4jaWBbjRmUBCj3dUKCmqzebq561Xy85(YXibiG8PZW(LvPogo6gaDMJzxQwounYoLhyd1imLcla5E4bt1nnunYoLhyd1imLclUIQjJQLHuunjP6MgQgNbHGFmukmyH6yFf4XZJKOAY2OAwDmLjbogjabKpDg2VSk1nUKjXUKCmqzebq561Xy85(YXKfILcqeGHuy)kyyYDmC0na6mhdrCTegBOsVk1NJSPteZO6MgQMiUwcokInfiIzuDlQMiUwcokInfiWJXjNQjBJQLPnQUPHQ5)huFEjm2qLEvQphztNabs2vyQMmQwEKIQBAOA5q1eX1sWrrSParmJQBr18)dQpVeCueBkqGaj7kmvtgvlps5yktcCmzHyPaebyif2VcgMC34sM02LKJbkJiakxVogJp3xogcaHbe5ac77l2x0XWr3aOZCmeX1sySHk9QuFoYMormJQBAOAI4Aj4Oi2uGiMr1TOAI4Aj4Oi2uGapgNCQMSnQwM2O6MgQM)Fq95LWydv6vP(CKnDceizxHPAYOA5rkQUPHQLdvtexlbhfXMceXmQUfvZ)pO(8sWrrSPabcKSRWunzuT8iLJPmjWXqaimGihqyFFX(IUXLSmT5sYXaLreaLRxhJXN7lhduQaGX(5k(erG)x(fY4Z9Lf8zFoGCmC0na6mhdrCTegBOsVk1NJSPteZO6MgQMiUwcokInfiIzuDlQMiUwcokInfiWJXjNQjBJQLPnQUPHQ5)huFEjm2qLEvQphztNabs2vyQMmQwEKIQBAOA()b1NxcokInfiqGKDfMQjJQLhPCmLjbogOubaJ9Zv8jIa)V8lKXN7ll4Z(Ca5gxYYiJljhdugrauUEDmgFUVCmzGHcE1Xgqyp)LYmm2XWr3aOZCmeX1sySHk9QuFoYMormJQBAOAI4Aj4Oi2uGiMr1TOAI4Aj4Oi2uGapgNCQMSnQwM2CmLjboMmWqbV6ydiSN)szgg7gxYYWQljhdugrauUEDmgFUVCmRdHhVKna2JZ6pnyySJHJUbqN5yiIRLWydv6vP(CKnDIygv30q1eX1sWrrSParmJQBr1eX1sWrrSPabcKSRWuD7BuTmKYXuMe4ywhcpEjBaShN1FAWWy34swMe5sYXaLreaLRxhJXN7lhtE3Hc5xLI9zHOKLcogo6gaDMJHiUwcJnuPxL6Zr20jIzuDtdvtexlbhfXMceXmQUfvtexlbhfXMceiqYUct1TVr1S2MJPmjWXK3DOq(vPyFwikzPGBCjlJ8Cj5yGYicGY1RJX4Z9LJrHat5tdM6S5rypHPsbhdhDdGoZXqexlHXgQ0Rs95iB6eXmQUPHQjIRLGJIytbIygv3IQjIRLGJIytbceizxHP623OAwBZXuMe4yuiWu(0GPoBEe2tyQuWnUKLHuUKCmqzebq561Xy85(YXOqGP8go7qwnyVeOSq4(YXWr3aOZCmeX1sySHk9QuFoYMormJQBAOAI4Aj4Oi2uGiMr1TOAI4Aj4Oi2uGabs2vyQU9nQM12CmLjbogfcmL3WzhYQb7LaLfc3xUXLSmKoUKCmqzebq561XWr3aOZCm7s1eX1sqe(xfI4rGaJpuDtdvtexlHXgQ0Rs95iB6eXmQUPHQjIRLGJIytbIygv3IQjIRLGJIytbceizxHP62PAwjfv30q1JHsHrmNe4N3RoGQBFJQLxBunjDmgFUVCmrm4VbKWUXLSm9GljhdugrauUEDmC0na6mhdodcb)yOuyWIWL2nyFFrvQeudvt2gvZkv30q17s1YHQr2P8aBOgHPuybi3dpyQUPHQr2P8aBOgHPuyXvunzuDpqkQMKogJp3xoMWL2nyFFrvQeuJBCjldj2LKJbkJiakxVogo6gaDMJHiUwcJnuPxL6Zr20jIzuDtdvtexlbhfXMceXmQUfvtexlbhfXMce4X4Kt1BuTmT5ym(CF5ywhcic)RCJlzziTDj5ym(CF5yWDheu(F5zdvkyfhCmqzebq561nUKzTnxsogOmIaOC96y4OBa0zogI4AjUs(XdFZ9LiMr1nnuTCO6XcqnIRKF8W3CFjGYicGYXy85(YXySHk9QuFoYMo34sMvzCj5yGYicGY1RJHJUbqN5y6(q)(SphqunzBuT8CmgFUVCmCueBkWnUXXSU6WDac7sYLSmUKCmqzebq561XW2crWXGZGqWpgkfgSqDSVc845rsunzBuDIO6MgQwou9ybOgb6s7g4JypBaPo(iGYicGIQBr1JfGAeQJ9vGVVOkvcQraLreafv3IQXzqi4hdLcdwOo2xbE88ijQMSnQMvQUPHQTEeGUbeQJ9vGhDPDJakJiakQUfvB9iaDdiuh7Rap6s7gbYkYPAY2OAwP6wu9yOuyeDGfMorgFO623OAwBJQBr1eX1sOo2xbE0L2nc1NxogJp3xog2g6mIa4yyBiFzsGJrH9CdpgraCJlzwDj5yGYicGY1RJHJUbqN5yiIRL4k5hp8n3xc1NxuDtdvtexlXvYpE4BUVeiqYUct1Tt1KIQBr1DFOFF2NdiQMSnQoruDtdvpwaQraYf4X5(YJHAGIdcOmIaOO6wun))G6ZlbixGhN7lpgQbkoiqGKDfMQBNQLPnQUfvtexlXvYpE4BUVeiqYUct1Tt1YqkQUPHQ5)huFEjm2qLEvQphztNabs2vyQUDQwgsr1TOAI4AjUs(XdFZ9Labs2vyQUDQM12O6wuD3h63N95aIQjBJQtKJX4Z9LJ5k5hp8n3xUXLCICj5yGYicGY1RJHJUbqN5yWzqi4hdLcdwOo2xbE88ijQU9nQoruDlQExQwou9ybOgbhfXMceqzebqr1nnun))G6ZlbhfXMceiqYUct1Kr1PCfv3tQMvQMKogJp3xogqUapo3xEmuduCWnUKLNljhdugrauUEDmC0na6mhdBdDgraekSNB4Xicav3IQjIRLqDSVc8zru2Jbbcm(4ym(CF5yuh7RapEEKKBCjtkxsogOmIaOC96y4OBa0zog2g6mIaiuyp3WJreaQUfvVlvlhQESauJGJIytbcOmIaOO6MgQM)Fq95LGJIytbceizxHPAYO6uUIQ7jvZkvtshJXN7lhJ6yFf4XZJKCJlzshxsogOmIaOC96y4OBa0zogI4Ajuh7RaFweL9yqGaJpuDlQExQwou9ybOgbixGhN7lpgQbkoiGYicGIQBAOA()b1NxcqUapo3xEmuduCqGaj7kmvtgvNYvunjDmgFUVCmdiLfme2ZgqQJpUXLCp4sYXaLreaLRxhdhDdGoZXSlvlhQESauJGJIytbcOmIaOO6MgQM)Fq95LGJIytbceizxHPAYO6uUIQ7jvZkvtsQUfvVlvlhQESauJaKlWJZ9Lhd1afheqzebqr1nnunrCTeCueBkqeZO6wunrCTeCueBkqGhJtov3ovltBuDtdvZ)pO(8saYf4X5(YJHAGIdceizxHPAYO6uUIQ7jvZkvtshJXN7lhZaszbdH9SbK64JBCJJjfkazZJWUKCjlJljhdugrauUEDmSTqeCm7s1YHQhla1i6mjja5)LphztNakJiakQUPHQhdLcJOdSW0jY4dvt2gvZABuDlQExQMiUwcJnuPxL6Zr20juFEr1nnunrCTeCueBkqO(8IQjjvtshJXN7lhdBdDgraCmSnKVmjWXq6FsJBCjZQljhdugrauUEDmC0na6mht3h63N95aIQjBJQjLJX4Z9LJHBHG34Z9LpC4XXeo84ltcCmRRoChGWUXLCICj5yGYicGY1RJHJUbqN5y2LQLdvJSt5b2qnctPWcqUhEWuDtdvJSt5b2qnctPWIROAYOAzifvtsQUfvVlv39H(9zFoGO623O62O6MgQU7d97Z(Car1BuTmuDlQM)Fq95LGiykW)lFFr8CCqGaj7kmvtgvNYvunjDmgFUVCm5g5G)xEd3by34swEUKCmqzebq561XWr3aOZCmDFOFF2NdiQU9nQMvQUPHQ3LQ7(q)(Sphqu9gvNiQUfvVlvZ)pO(8s0zssaY)lFoYMobcKSRWunzuDkxr19KQzLQBAOA2g6mIaii9pPHQjjvtshJXN7lhdrWuG)x((I454GBCjtkxsogOmIaOC96y4OBa0zoMUp0Vp7Zbev3(gvZkv30q17s1DFOFF2NdiQU9nQwEuDlQExQM)Fq95LGiykW)lFFr8CCqGaj7kmvtgvNYvuDpPAwP6MgQMTHoJiacs)tAOAss1K0Xy85(YX0xuLkb14gxYKoUKCmqzebq561XWr3aOZCmDFOFF2NdiQU9nQwEogJp3xoMotscq(F5Zr205gxY9GljhdugrauUEDmC0na6mht3h63N95aIQBFJQzLQBAO6Up0Vp7Zbev3(gvNiQUfvZ)pO(8sqemf4)LVViEooiqGKDfMQjJQt5kQUNunRuDtdv39H(9zFoGO6nQwEuDlQM)Fq95LGiykW)lFFr8CCqGaj7kmvtgvNYvuDpPAwP6wun))G6ZlrFrvQeuJabs2vyQMmQoLRO6Es1S6ym(CF5y4FHboYM7l34sMe7sYXaLreaLRxhdhDdGoZXmwaQr0zssaY)lFoYMobugrauuDlQExQEmukmIoWctNiJpuD7BunRTr1nnunrCTegBOsVk1NJSPteZO6MgQMiUwcokInfiIzunjP6wu9UunrCTeQJ9vGplIYEmiIzuDtdvtexlbhfXMce4X4Kt1Tt1Y0gvtshJXN7lhd3cbVXN7lF4WJJjC4XxMe4ywxD4oaHDJlzsBxsogOmIaOC96y4OBa0zog()b1NxcokInfG84bDKdcENHsbSFHm(CFzbQMSnQwgrpqkQUfvVlv39H(9zFoGO623OAwP6MgQU7d97Z(Car1TVr1jIQBr18)dQpVeebtb(F57lINJdceizxHPAYO6uUIQ7jvZkv30q1DFOFF2NdiQEJQLhv3IQ5)huFEjicMc8)Y3xephheiqYUct1Kr1PCfv3tQMvQUfvZ)pO(8s0xuLkb1iqGKDfMQjJQt5kQUNunRuDlQM)Fq95LG)fg4iBUVeiqYUct1Kr1PCfv3tQMvQMKogJp3xogokInfG84bDKdUXLSmT5sYXaLreaLRxhJXN7lhd3cbVXN7lF4WJJjC4XxMe4ywxD4oaHDJlzzKXLKJbkJiakxVogo6gaDMJP7d97Z(Car1TVr1YZXy85(YXWrrSPaKhpOJCWnUKLHvxsogOmIaOC96y4OBa0zoMDPAfqexlbixGhN7lpgQbkoiIzuDtdvVlvpwaQr0zssaY)lFoYMobugrauuDlQExQEmukmIoWctNiJpunzBunRTr1nnunrCTegBOsVk1NJSPtO(8IQBAOAI4Aj4Oi2uGq95fvtsQMKuDtdvlhQESauJaKlWJZ9Lhd1afheqzebqr1nnuTCO6XcqnIotscq(F5Zr20jGYicGIQjjv3IQ7(q)(SphquD7BuT8CmgFUVCmgIBf4NhHGACJBCJBCJZb]] )


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
