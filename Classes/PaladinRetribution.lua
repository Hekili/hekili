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

        avenging_wrath_autocrit = {
            id = 294027,
            duration = 20,
            max_stack = 1
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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "spell",

            toggle = 'cooldowns',
            notalent = 'crusade',

            startsCombat = true,
            texture = 135875,

            usable = function () return not buff.avenging_wrath.up end,
            handler = function ()
                applyBuff( 'avenging_wrath' )
                if PTR then applyBuff( "avenging_wrath_crit" ) end
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

            spend = 0.07,
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

            readyTime = function () return debuff.forbearance.remains end,

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

            spend = 0.06,
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

            readyTime = function () return debuff.forbearance.remains end,

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

                if PTR and buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end

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

            readyTime = function () return debuff.forbearance.remains end,

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

            spend = 0.06,
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
                if PTR and buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
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

            usable = function ()
                if settings.check_wake_range and not target.within12 then return false, "target is outside of 12 yards" end
                return true
            end,

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


    spec:RegisterPack( "Retribution", 20190729, [[dCeAubqicupIsr2ej1OerofLQwfLcVsrvZIsPBPGO2fu)se1WijoMIYYOe9mfW0iqUgb02ia13uqQXrsQCofewhbiMhLk3tH2NiCqcqQfQOYdvqstubr4IkiI2OcIKrssQYjjjvLvsj1ovqnufePwkbi5PeAQkqxLKuv9vfKyVc9xPmyehMQfJKht0Kj1LrTzr9zKA0kYPvz1KK8AkHzlv3Mc7wYVvA4I0XjjLLRQNdz6axxW2jOVtrJNa48uswpLIA(Ky)Gooloyuu7aooSLQmBiuzOTCiWZMjilfOGIIaRs5OyQlTWP5Oy5gCuuafd(JkaUTIIPUv911XbJIOn8sokobaPibKKtM(atbkSCnsgDgHUdUTKVNbjJodzYrrQW1bQ(Qivuu7aooSLQmBiuzOTCiWZMjilfOLrruklJdp0QefNoTMRivuuZizu0MGebum4pQa42csgs7DxFf0ABcsMaGuKasYjtFGPafwUgjJoJq3b3wY3ZGKrNHmzO12eKyDOBfKy5qylKyPkZgcizidjZMjGmGaHwdT2MGKH6Kx0msabATnbjdzir1FQ2bSgsY7djQoSLyO12eKmKHKHuNaajshbswo5vXDizOoKabjYjwAbcsY7djcOhkjpu)aY1mokM(B(6Cu0MGebum4pQa42csgs7DxFf0ABcsMaGuKasYjtFGPafwUgjJoJq3b3wY3ZGKrNHmzO12eKyDOBfKy5qylKyPkZgcizidjZMjGmGaHwdT2MGKH6Kx0msabATnbjdzir1FQ2bSgsY7djQoSLyO12eKmKHKHuNaajshbswo5vXDizOoKabjYjwAbcsY7djcOhkjpu)aY1mgAn0ABcsgskaSmaynKqX59zirUguoasOy6RqyiraTuYPaeKuBnKN83ih6qIlb3wiizRUvyO12eK4sWTfcN(SCnOCWyU7ilGwBtqIlb3wiC6ZY1GYbZpMCExn0ABcsCj42cHtFwUguoy(XK9aTbxahCBbT2MGeXYtrtlasE)0qcviNznKGaoabjuCEFgsKRbLdGekM(keK4LgssFEiNUaWv0qYHGe9wmgATnbjUeCBHWPplxdkhm)yYOYtrtlOHaoabT2LGBleo9z5Aq5G5htoDb3wqRDj42cHtFwUguoy(XK9x6f3a7)CbS9YJcg4DUayt3cUT5MJMyeMlNQZAO1qRTjiziPaWYaG1qclKFRGeWzWqcyIHexc2hsoeK4c9R7uDgdT2LGBl04ZublyO1UeCBHMFmzP37nxcUTA9dbSTCdEuUBxVMfcATlb3wO5htw69EZLGBRw)qaBl3GhP5IFhSpcAn0AxcUTqyWFLfmangqC7aSHTLBWJVBKEfDZns7hiO5g9r7c3oOXf9vSTxEmjQqoJDHCrFfDZ8DWeoKQOqfYzS8dixZ4qQ9qRDj42cHb)vwWa08JjhqC7aSHTLBWJ0)w0Ow6FgEV9onB7LhfmviNXUqUOVIUz(oychsvlyQqoJLFa5AghsHw7sWTfcd(RSGbO5htoG42bydBl3GhF3M1HYcuJ6OBpRBubaylO1UeCBHWG)klyaA(XKdiUDa2W2Yn4rvXO20A2532lpsfYzSlKl6ROBMVdMWHuffQqoJLFa5AghsvtfYzS8dixZyeWLwmotfO1UeCBHWG)klyaA(XKdiUDa2W2Yn4rHN3BBU51z4aw3O67QT9YJjrfYzSlKl6ROBMVdMWHuffQqoJLFa5AghsvtfYzS8dixZ4Nn8Rq2nt1zVIssYD761SWUqUOVIUz(oyc)SHFfkXaQOOi3TRxZcl)aY1m(zd)kuIbuXEO1UeCBHWG)klyaA(XKdiUDa2W2Yn4r9UgOwo8wz7LhPc5m2fYf9v0nZ3bt4qQIcviNXYpGCnJdPQPc5mw(bKRz8Zg(vi7MP6Gw7sWTfcd(RSGbO5htoG42bydBl3GhP9ol9ENFuJIDlS9YJuHCg7c5I(k6M57GjCivrHkKZy5hqUMXHu1uHCgl)aY1m(zd)kKDZei0AxcUTqyWFLfman)yYbe3oaByB5g8iLv0BXnkMBE3WlxA7LhPc5m2fYf9v0nZ3bt4qQIcviNXYpGCnJdPqRDj42cHb)vwWa08JjhqC7aSHTLBWJg8ZwaMCul7fTTxEmjb)(PBSqUayxRrywaoeaPO8(PBSqUayxRr4RsmtG2ROGs5EVb8NMbiS(eEf3qG9nsmAj0AxcUTqyWFLfman)yYbe3oaByB5g8yApuA(Py)1OwU7ilS9YJuHCg7c5I(k6M57GjCivrHkKZy5hqUMXHu1uHCgl)aY1mgbCPfjgNPIIIC3UEnlSlKl6ROBMVdMWpB4xHsiibQOiyQqoJLFa5Aghsvl3TRxZcl)aY1m(zd)kucbjqO1UeCBHWG)klyaA(XKdiUDa2W2Yn4rk(r8Bb)OMQcQky7LhPc5m2fYf9v0nZ3bt4qQIcviNXYpGCnJdPQPc5mw(bKRzmc4slsmotfff5UD9Awyxix0xr3mFhmHF2WVcLqqcurrWuHCgl)aY1moKQwUBxVMfw(bKRz8Zg(vOecsGqRDj42cHb)vwWa08JjhqC7aSHTLBWJCP7mc1axjbHNBBULFxcUT8ElDn532lpsfYzSlKl6ROBMVdMWHuffQqoJLFa5AghsvtfYzS8dixZyeWLwKyCMkkkYD761SWUqUOVIUz(oyc)SHFfkHGeOIIC3UEnlS8dixZ4Nn8RqjeKaHw7sWTfcd(RSGbO5htoG42bydBl3Ghtz)7n9jKFutUgPocz7LhPc5m2fYf9v0nZ3bt4qQIcviNXYpGCnJdPQPc5mw(bKRzmc4slsmotfO1UeCBHWG)klyaA(XKdiUDa2W2Yn4X89iqZWbmQHsTIU7iKTxEKkKZyxix0xr3mFhmHdPkkuHCgl)aY1moKQMkKZy5hqUMXpB4xHSBCMaHw7sWTfcd(RSGbO5htoG42bydBl3GhnNUVBEfnQL2dgonB7LhPc5m2fYf9v0nZ3bt4qQIcviNXYpGCnJdPQPc5mw(bKRz8Zg(vi7gTufO1UeCBHWG)klyaA(XKdiUDa2W2Yn4r9ZUUr3D95G9rnkxtZ2E5rQqoJDHCrFfDZ8DWeoKQOqfYzS8dixZ4qQAQqoJLFa5Ag)SHFfYUrlvbATlb3wim4VYcgGMFm5aIBhGnSTCdEu)SRBok9EVaOMbR9E)2Y2lpsfYzSlKl6ROBMVdMWHuffQqoJLFa5AghsvtfYzS8dixZ4Nn8Rq2nAPkqRDj42cHb)vwWa08JjhqC7aSHTLBWJwulOT5MxYJlqlhERS9YJuHCg7c5I(k6M57GjCivrHkKZy5hqUMXHu1uHCgl)aY1mgbCPfjgNPIIIC3UEnlSlKl6ROBMVdMWpB4xHsmGkkkcMkKZy5hqUMXHu1YD761SWYpGCnJF2WVcLyavGw7sWTfcd(RSGbO5htoG42bydKTxEKkKZyxix0xr3mFhmHdPkkuHCgl)aY1moKQMkKZy5hqUMXiGlTyCMkqRHw7sWTfcl3TRxZcnMUGBlBV8ysYD761SW0b)1NxTn3CBM)fmHF2WVcLyiurrrWmcXLKXYT0CHyDRFzoVVKXgUQ23E1jrfYzmvFxDpGa4NDjqrHkKZyxix0xr3mFhmHdPkkuHCgl)aY1moKQMkKZy5hqUMXpB4xHSZsbAp0AxcUTqy5UD9AwO5htUF0tautvbnTbxaBV8ikL79gWFAgGW9JEcGAQkOPn4cKy0sfLKe87NUXc5cGDTgHzb4qaKIY7NUXc5cGDTgHVkXqlq7Hw7sWTfcl3TRxZcn)yY57zQ(UABV8iviNXUqUOVIUz(oychsvuOc5mw(bKRzCivnviNXYpGCnJraxAX4mvGw7sWTfcl3TRxZcn)yYOPJ762MBc5IM9sY2E5rQqoJrmdMUIU9onJ1RzPMkKZyd2yFRABU1dYt30p7giSEnlO1UeCBHWYD761SqZpMCaXTdWg2wUbp6OjHEXO2728(n5(E32lpQzQqoJF3M3Vj337nntfYzSEnlfLKOc5m2fYf9v0nZ3bt4Nn8RqjgTufffQqoJLFa5AgJaU0IXzQOMkKZy5hqUMXpB4xHsmtG2Roj5UD9Awy6G)6ZR2MBUnZ)cMWpB4xHsmeQOOaodUb2M(y7gqfffbZiexsgl3sZfI1T(L58(sgB4QAF7Hw7sWTfcl3TRxZcn)yYbe3oaByB5g847gPxr3CJ0(bcAUrF0UWTdACrFfB7LhtIkKZyxix0xr3mFhmHdPkkuHCgl)aY1moKAp0AxcUTqy5UD9AwO5htoG42bydKTxEKkKZyxix0xr3mFhmHdPkkuHCgl)aY1moKcT2LGBlewUBxVMfA(XKbtCluuBO0T8(s22lpcod2UrlvuOc5m(zPfDgHA59LmoKcT2LGBlewUBxVMfA(XKP67QBBUbM4gxSHv2E5rQqoJDHCrFfDZ8DWeoKQOqfYzS8dixZ4qQAQqoJLFa5AgJaU0IXzQaT2LGBlewUBxVMfA(XKPd(RpVABU52m)lyY2lpkyG35cGLFa5AgZLt1zT6KK721RzHDHCrFfDZ8DWe(zd)kKDcu902TQLUM8NyCa1jrfYz8vQw4qh42chsvuemW7CbWxPAHdDGBlmxovN12ROi3TRxZc7c5I(k6M57Gj8Zg(vOeJcsG2ROKeW7CbWYpGCnJ5YP6SwTC3UEnlS8dixZ4Nn8Rq2rl1QN2UvT01K)eJcsrzA7w1sxt(tmoGAWzW2ntf1aVZfaB6wWTn3C0eJWC5uDwROi3TRxZcl)aY1m(zd)kuIrbjq7Hw7sWTfcl3TRxZcn)yYM731c5RApJ2YljB7LhL721RzHDHCrFfDZ8DWe(zd)kKD0sT6PTBvlDn5pX4akkYD761SWYpGCnJF2WVczhTuREA7w1sxt(tmkiff5UD9Awyxix0xr3mFhmHF2WVcLyuqcurrUBxVMfw(bKRz8Zg(vOeJcsGqRDj42cHL721RzHMFm58kdiw3CBM)dWnk2nS9YJjj43pDJfYfa7AncZcWHaifL3pDJfYfa7AncFvIburrbLY9Ed4pndqy9j8kUHa7BKy0s7vNeviNXUqUOVIUz(oycRxZsnviNXYpGCnJ1RzzV6KK721RzHP6UMBBUPQacCsg)SHFfkbTuBJbul3TRxZcRQGM2Gla(zd)kucAP2gdyp0AxcUTqy5UD9AwO5ht2Gn23Q2MB9G80n9ZUbY2lpMeviNXUqUOVIUz(oychsvuOc5mw(bKRzCivnviNXYpGCnJraxAX4mvSx902TQLUM8B34aqRDj42cHL721RzHMFm50WFzRUIUr1DeW2lpMKGF)0nwixaSR1imlahcGuuE)0nwixaSR1i8vjgqfffuk37nG)0maH1NWR4gcSVrIrlThATlb3wiSC3UEnl08JjhqC7aSHTCoZsqRCdEuALSVGFRt2O6ocy7LhtIkKZyxix0xr3mFhmH1RzPMkKZy5hqUMX61SSxDsYD761SWuDxZTn3uvabojJF2WVcLGwQTXaQL721RzHvvqtBWfa)SHFfkbTuBJbShATlb3wiSC3UEnl08Jj7c5I(k6M57GjBV8yscg4DUa4RuTWHoWTfMlNQZAffQqoJVs1ch6a3w4qQ9QN2UvT01K)eJdaT2LGBlewUBxVMfA(XKLFa5A22lpoTDRAPRj)jgfKIY02TQLUM8NyCa1GZGTBMkQbENla20TGBBU5OjgH5YP6SgAn0AxcUTq48vhAIF0Oq)pNQZ2wUbpAEfnQLUB3wHEpWJcMvTWLMYA8mb8qmWmbPojbd8oxaS8dixZyUCQoRvl3TRxZc7c5I(k6M57Gj8Zg(vOe0sTngqrrUBxVMfw(bKRz8Zg(vOe0sTngWEffw1cxAkRXZeWdXaZeK6KemW7CbWYpGCnJ5YP6SwTC3UEnlSlKl6ROBMVdMWpB4xHsql12qaROi3TRxZcl)aY1m(zd)kucAP2gcy7Hw7sWTfcNV6qt8JMFmzH(FovNTTCdEuJAshbCQoBRqVh4ruk37nG)0maH1NWR4gcSVrIrlvlyG35cG)JEcWBa1eYV(KamxovN1kkOuU3Ba)PzacRpHxXneyFJeJdOg4DUa4)ONa8gqnH8RpjaZLt1zTIcviNXSrQvp7vlDn5hhsvRzQqoJvvqtBWfaRxZsnviNX6t4vCln8PlIX61SutfYzSlKl6ROBMVdMAEaSY)ay9AwqRDj42cHZxDOj(rZpM8vQw4qh42Y2lpsfYzSlKl6ROBMVdMW61SuNeviNXxPAHdDGBlSEnlffQqoJVs1ch6a3w4Nn8Rq2P6upTDRAPRj)jghqrb4DUaywayzaCB1qCb4sYyUCQoRvl3TRxZcZcaldGBRgIlaxsg)SHFfYUzQOMkKZ4RuTWHoWTf(zd)kKDZeOIIC3UEnlSlKl6ROBMVdMWpB4xHSBMavtfYz8vQw4qh42c)SHFfYolvr902TQLUM8NyCa7Hw7sWTfcNV6qt8JMFmzwayzaCB1qCb4sY2E5ruk37nG)0maH1NWR4gcSVHDJwQojbd8oxaS8dixZyUCQoRvl3TRxZc7c5I(k6M57Gj8Zg(vOeZurrb4DUay5hqUMXC5uDwRMkKZy5hqUMX61Sul3TRxZcl)aY1m(zd)kuIzQOOqfYzS8dixZyeWLwKyCOThATlb3wiC(QdnXpA(XK1NWR4gcSVHTxEuO)Nt1zSg1Koc4uDwTq)pNQZyZROrT0D7Qtkjbd8oxamlaSmaUTAiUaCjzmxovN1kkjHs5EVb8NMbiS(eEf3qG9nsmAPIIC3UEnlmlaSmaUTAiUaCjz8Zg(vOe0sTnS0E7vussUBxVMf2fYf9v0nZ3bt4Nn8RqjOLABmGA5UD9Awyxix0xr3mFhmHF2WVcz3mvuuK721RzHLFa5Ag)SHFfkbTuBJbul3TRxZcl)aY1m(zd)kKDZurrHkKZy5hqUMXHu1uHCgl)aY1mgbCPf2ntf7ThATlb3wiC(QdnXpA(XKbSrA3Futi)6tcS9YJc9)CQoJnVIg1s3TRojbd8oxamlaSmaUTAiUaCjzmxovN1kkYD761SWSaWYa42QH4cWLKXpB4xHsql12Wsff5UD9Awyxix0xr3mFhmHF2WVcLGwQTXaQL721RzHDHCrFfDZ8DWe(zd)kKDZurrrUBxVMfw(bKRz8Zg(vOe0sTngqTC3UEnlS8dixZ4Nn8Rq2ntfffQqoJLFa5AghsvtfYzS8dixZyeWLwy3mvShAn0AxcUTqyAU43b7Jgf6)5uD22Yn4rvVDOyRqVh4XKemW7CbWtUHb)Tn3mFhmH5YP6Swrb4pndWtS3bt4ujiXOLQOojQqoJDHCrFfDZ8DWewVMLAQqoJLFa5AgRxZYE7Hw7sWTfctZf)oyF08Jjl9EV5sWTvRFiGTLBWJ5Ro0e)iBV8402TQLUM8NyuGkkuHCgBWg7BvBZTEqE6M(z3aHdPkkuHCgJygmDfD7DAghsvuOc5m(kvlCOdCBH1RzPEA7w1sxt(tmoa0AxcUTqyAU43b7JMFmzt3cUT5MJMyKTxEmjb)(PBSqUayxRrywaoeaPO8(PBSqUayxRr4RsmtGkkOuU3Ba)PzacB6wWTn3C0eJsmAP9QtAA7w1sxt(TBuffLPTBvlDn5FCMA5UD9AwyQUR52MBQkGaNKXpB4xHsql12Roj5UD9Awyxix0xr3mFhmHF2WVcLyMkkkaVZfal)aY1mMlNQZA1YD761SWYpGCnJF2WVcLyMk2dT2LGBleMMl(DW(O5htMQ7AUT5MQciWjzBV8402TQLUM8B3OLkkjnTDRAPRj)JdOoj5UD9Aw4j3WG)2MBMVdMWpB4xHsql12WsffH(FovNXQE7qXE7Hw7sWTfctZf)oyF08JjRQGM2GlGTxECA7w1sxt(TB0sfLKM2UvT01KF7gfK6KK721RzHP6UMBBUPQacCsg)SHFfkbTuBdlvue6)5uDgR6Tdf7ThATlb3wimnx87G9rZpM8KByWFBZnZ3bt2E5XPTBvlDn53UrbbT2LGBleMMl(DW(O5htwUfILVdUTS9YJtB3Qw6AYVDJwQOmTDRAPRj)2noGA5UD9AwyQUR52MBQkGaNKXpB4xHsql12WsfLPTBvlDn5FuqQL721RzHP6UMBBUPQacCsg)SHFfkbTuBdlvl3TRxZcRQGM2Gla(zd)kucAP2gwcT2LGBleMMl(DW(O5htw69EZLGBRw)qaBl3GhZxDOj(r2E5rG35cGNCdd(BBUz(oycZLt1zTAG)0mapXEhmHtLa7gTufffQqoJDHCrFfDZ8DWeoKQOqfYzS8dixZ4qk0AxcUTqyAU43b7JMFmz5hqUM)gc8NfSTxEuUBxVMfw(bKR5VHa)zbJLt(tZOw(Dj42Y7jgNHhAbQoPPTBvlDn53UrlvuM2UvT01KF7ghqTC3UEnlmv31CBZnvfqGtY4Nn8RqjOLAByPIY02TQLUM8pki1YD761SWuDxZTn3uvabojJF2WVcLGwQTHLQL721RzHvvqtBWfa)SHFfkbTuBdlvl3TRxZcl3cXY3b3w4Nn8RqjOLAByP9qRDj42cHP5IFhSpA(XKLEV3Cj42Q1peW2Yn4X8vhAIFe0AxcUTqyAU43b7JMFmz5wsUaVdyDl3DdgATlb3wimnx87G9rZpMS8dixZFdb(Zc22lpoTDRAPRj)2nkiO1UeCBHW0CXVd2hn)yY(l9IBG9FUa2E5XPTBvlDn53UrbfffYp62koSLQmBiuzOTCg2YbgikA6FDfnkkQ6ZiDFaRHebmK4sWTfK0peaHHwhf9ayA)OO4zmuJI9dbqXbJIAo7HoioyC4zXbJIUeCBffFMkybhf5YP6Sooxeeh2Y4GrrUCQoRJZffDj42kkk9EV5sWTvRFiquSFiqRCdokk3TRxZcfbXHhioyuKlNQZ64CrrxcUTIIsV3BUeCB16hcef7hc0k3GJI0CXVd2hfbrqum9z5Aq5G4GXHNfhmk6sWTvumDb3wrrUCQoRJZfbXHTmoyuKlNQZ64Crr5Fa(ppkkyib4DUayt3cUT5MJMyeMlNQZ6OOlb3wrr)LEXnW(pxGiicIIYD761SqXbJdployuKlNQZ64Crr5Fa(ppkMeKi3TRxZcth8xFE12CZTz(xWe(zd)keKKasgcvGeffirWqcJqCjzSClnxiw36xMZ7lzSHRQ9He7He1qssqcviNXu9D19acGF2LairrbsOc5m2fYf9v0nZ3bt4qkKOOajuHCgl)aY1moKcjQHeQqoJLFa5Ag)SHFfcsSdsSuGqI9rrxcUTIIPl42kcIdBzCWOixovN1X5IIY)a8FEueLY9Ed4pndq4(rpbqnvf00gCbGKeJqILqIIcKKeKiyi59t3yHCbWUwJWSaCiacsuuGK3pDJfYfa7AncFfKKasgAbcj2hfDj42kk2p6jaQPQGM2GlqeehEG4GrrUCQoRJZffL)b4)8OiviNXUqUOVIUz(oychsHeffiHkKZy5hqUMXHuirnKqfYzS8dixZyeWLwajJqYmvIIUeCBffZ3Zu9D1rqCybfhmkYLt1zDCUOO8pa)NhfPc5mgXmy6k6270mwVMfKOgsOc5m2Gn23Q2MB9G80n9ZUbcRxZkk6sWTvuenDCx32Ctix0SxsocIdlW4GrrUCQoRJZffDj42kk6OjHEXO2728(n5(Epkk)dW)5rrntfYz8728(n5(EVPzQqoJ1RzbjkkqssqcviNXUqUOVIUz(oyc)SHFfcssmcjwQcKOOajuHCgl)aY1mgbCPfqYiKmtfirnKqfYzS8dixZ4Nn8RqqscizMaHe7He1qssqIC3UEnlmDWF95vBZn3M5Fbt4Nn8RqqsciziubsuuGeWzWnW20hdj2bjdOcKOOajcgsyeIljJLBP5cX6w)YCEFjJnCvTpKyFuSCdok6OjHEXO2728(n5(EpcIdlGJdgf5YP6Sooxu0LGBRO47gPxr3CJ0(bcAUrF0UWTdACrFfhfL)b4)8OysqcviNXUqUOVIUz(oychsHeffiHkKZy5hqUMXHuiX(Oy5gCu8DJ0ROBUrA)abn3OpAx42bnUOVIJG4WdDCWOixovN1X5IIY)a8FEuKkKZyxix0xr3mFhmHdPqIIcKqfYzS8dixZ4qAu0LGBROyaXTdWgOiioSQloyuKlNQZ64Crr5Fa(ppkcodgsSBesSesuuGeQqoJFwArNrOwEFjJdPrrxcUTIIGjUfkQnu6wEFjhbXHhI4GrrUCQoRJZffL)b4)8OiviNXUqUOVIUz(oychsHeffiHkKZy5hqUMXHuirnKqfYzS8dixZyeWLwajJqYmvIIUeCBffP67QBBUbM4gxSHvrqC4zQehmkYLt1zDCUOO8pa)NhffmKa8oxaS8dixZyUCQoRHe1qssqIC3UEnlSlKl6ROBMVdMWpB4xHGe7GebcjQHKPTBvlDn5hssmcjdajQHKKGeQqoJVs1ch6a3w4qkKOOajcgsaENla(kvlCOdCBH5YP6SgsShsuuGe5UD9Awyxix0xr3mFhmHF2WVcbjjgHebjqiXEirrbsscsaENlaw(bKRzmxovN1qIAirUBxVMfw(bKRz8Zg(viiXoiHwQHe1qY02TQLUM8djjgHebbjkkqY02TQLUM8djjgHKbGe1qc4myiXoizMkqIAib4DUayt3cUT5MJMyeMlNQZAirrbsK721RzHLFa5Ag)SHFfcssmcjcsGqI9rrxcUTII0b)1NxTn3CBM)fmfbXHNnloyuKlNQZ64Crr5Fa(ppkk3TRxZc7c5I(k6M57Gj8Zg(viiXoiHwQHe1qY02TQLUM8djjgHKbGeffirUBxVMfw(bKRz8Zg(viiXoiHwQHe1qY02TQLUM8djjgHebbjkkqIC3UEnlSlKl6ROBMVdMWpB4xHGKeJqIGeiKOOajYD761SWYpGCnJF2WVcbjjgHebjWOOlb3wrrZ97AH8vTNrB5LKJG4WZSmoyuKlNQZ64Crr5Fa(ppkMeKiyi59t3yHCbWUwJWSaCiacsuuGK3pDJfYfa7AncFfKKasgqfirrbsqPCV3a(tZaewFcVIBiW(gqsIriXsiXEirnKKeKqfYzSlKl6ROBMVdMW61SGe1qcviNXYpGCnJ1Rzbj2djQHKKGe5UD9AwyQUR52MBQkGaNKXpB4xHGKeqcTudj2asgasudjYD761SWQkOPn4cGF2WVcbjjGeAPgsSbKmaKyFu0LGBROyELbeRBUnZ)b4gf7grqC4zdehmkYLt1zDCUOO8pa)NhftcsOc5m2fYf9v0nZ3bt4qkKOOajuHCgl)aY1moKcjQHeQqoJLFa5AgJaU0cizesMPcKypKOgsM2UvT01KFiXUrizGOOlb3wrrd2yFRABU1dYt30p7gOiio8mbfhmkYLt1zDCUOO8pa)NhftcsemK8(PBSqUayxRrywaoeabjkkqY7NUXc5cGDTgHVcssajdOcKOOajOuU3Ba)PzacRpHxXneyFdijXiKyjKyFu0LGBROyA4VSvxr3O6ocebXHNjW4GrrUCQoRJZffDj42kkMUslya6Szw3KRrAa4GBRMMfEsokk)dW)5rXKGeQqoJDHCrFfDZ8DWewVMfKOgsOc5mw(bKRzSEnliXEirnKKeKi3TRxZct1Dn32Ctvbe4Km(zd)keKKasOLAiXgqYaqIAirUBxVMfwvbnTbxa8Zg(viijbKql1qInGKbGe7JICoZsqRCdokkTs2xWV1jBuDhbIG4WZeWXbJIC5uDwhNlkk)dW)5rXKGebdjaVZfaFLQfo0bUTWC5uDwdjkkqcviNXxPAHdDGBlCifsShsudjtB3Qw6AYpKKyesgik6sWTvu0fYf9v0nZ3btrqC4zdDCWOixovN1X5IIY)a8FEuCA7w1sxt(HKeJqIGGeffizA7w1sxt(HKeJqYaqIAibCgmKyhKmtfirnKa8oxaSPBb32CZrtmcZLt1zDu0LGBROO8dixZrqeefb)vwWauCW4WZIdgf5YP6Sooxu0LGBRO47gPxr3CJ0(bcAUrF0UWTdACrFfhfL)b4)8OysqcviNXUqUOVIUz(oychsHeffiHkKZy5hqUMXHuiX(Oy5gCu8DJ0ROBUrA)abn3OpAx42bnUOVIJG4WwghmkYLt1zDCUOOlb3wrr6FlAul9pdV3ENMJIY)a8FEuuWqcviNXUqUOVIUz(oychsHe1qIGHeQqoJLFa5AghsJILBWrr6FlAul9pdV3ENMJG4WdehmkYLt1zDCUOy5gCu8DBwhklqnQJU9SUrfaGTIIUeCBffF3M1HYcuJ6OBpRBubayRiioSGIdgf5YP6Sooxu0LGBROOQyuBAn78hfL)b4)8OiviNXUqUOVIUz(oychsHeffiHkKZy5hqUMXHuirnKqfYzS8dixZyeWLwajJqYmvIILBWrrvXO20A25pcIdlW4GrrUCQoRJZffDj42kkk88EBZnVodhW6gvFxDuu(hG)ZJIjbjuHCg7c5I(k6M57GjCifsuuGeQqoJLFa5AghsHe1qcviNXYpGCnJF2WVcbj2bjZuDqI9qIIcKKeKi3TRxZc7c5I(k6M57Gj8Zg(viijbKmGkqIIcKi3TRxZcl)aY1m(zd)keKKasgqfiX(Oy5gCuu4592MBEDgoG1nQ(U6iioSaooyuKlNQZ64CrrxcUTII6DnqTC4Tkkk)dW)5rrQqoJDHCrFfDZ8DWeoKcjkkqcviNXYpGCnJdPqIAiHkKZy5hqUMXpB4xHGe7GKzQUOy5gCuuVRbQLdVvrqC4HooyuKlNQZ64CrrxcUTII0ENLEVZpQrXUfrr5Fa(ppksfYzSlKl6ROBMVdMWHuirrbsOc5mw(bKRzCifsudjuHCgl)aY1m(zd)keKyhKmtGrXYn4OiT3zP378JAuSBreehw1fhmkYLt1zDCUOOlb3wrrkRO3IBum38UHxUmkk)dW)5rrQqoJDHCrFfDZ8DWeoKcjkkqcviNXYpGCnJdPrXYn4OiLv0BXnkMBE3WlxgbXHhI4GrrUCQoRJZffDj42kkAWpBbyYrTSx0rr5Fa(ppkMeKiyi59t3yHCbWUwJWSaCiacsuuGK3pDJfYfa7AncFfKKasMjqiXEirrbsqPCV3a(tZaewFcVIBiW(gqsIriXYOy5gCu0GF2cWKJAzVOJG4WZujoyuKlNQZ64CrrxcUTIIP9qP5NI9xJA5UJSikk)dW)5rrQqoJDHCrFfDZ8DWeoKcjkkqcviNXYpGCnJdPqIAiHkKZy5hqUMXiGlTassmcjZubsuuGe5UD9Awyxix0xr3mFhmHF2WVcbjjGebjqirrbsemKqfYzS8dixZ4qkKOgsK721RzHLFa5Ag)SHFfcssajcsGrXYn4OyApuA(Py)1OwU7ilIG4WZMfhmkYLt1zDCUOOlb3wrrk(r8Bb)OMQcQkefL)b4)8OiviNXUqUOVIUz(oychsHeffiHkKZy5hqUMXHuirnKqfYzS8dixZyeWLwajjgHKzQajkkqIC3UEnlSlKl6ROBMVdMWpB4xHGKeqIGeiKOOajcgsOc5mw(bKRzCifsudjYD761SWYpGCnJF2WVcbjjGebjWOy5gCuKIFe)wWpQPQGQcrqC4zwghmkYLt1zDCUOOlb3wrrU0DgHAGRKGWZTn3YVlb3wEVLUM8hfL)b4)8OiviNXUqUOVIUz(oychsHeffiHkKZy5hqUMXHuirnKqfYzS8dixZyeWLwajjgHKzQajkkqIC3UEnlSlKl6ROBMVdMWpB4xHGKeqIGeiKOOajYD761SWYpGCnJF2WVcbjjGebjWOy5gCuKlDNrOg4kji8CBZT87sWTL3BPRj)rqC4zdehmkYLt1zDCUOOlb3wrXu2)EtFc5h1KRrQJqrr5Fa(ppksfYzSlKl6ROBMVdMWHuirrbsOc5mw(bKRzCifsudjuHCgl)aY1mgbCPfqsIrizMkrXYn4Oyk7FVPpH8JAY1i1rOiio8mbfhmkYLt1zDCUOOlb3wrX89iqZWbmQHsTIU7iuuu(hG)ZJIuHCg7c5I(k6M57GjCifsuuGeQqoJLFa5AghsHe1qcviNXYpGCnJF2WVcbj2ncjZeyuSCdokMVhbAgoGrnuQv0DhHIG4WZeyCWOixovN1X5IIUeCBffnNUVBEfnQL2dgonhfL)b4)8OiviNXUqUOVIUz(oychsHeffiHkKZy5hqUMXHuirnKqfYzS8dixZ4Nn8RqqIDJqILQefl3GJIMt33nVIg1s7bdNMJG4WZeWXbJIC5uDwhNlk6sWTvuu)SRB0DxFoyFuJY10Cuu(hG)ZJIuHCg7c5I(k6M57GjCifsuuGeQqoJLFa5AghsHe1qcviNXYpGCnJF2WVcbj2ncjwQsuSCdokQF21n6URphSpQr5AAocIdpBOJdgf5YP6Sooxu0LGBROO(zx3Cu69Ebqndw79(Tvuu(hG)ZJIuHCg7c5I(k6M57GjCifsuuGeQqoJLFa5AghsHe1qcviNXYpGCnJF2WVcbj2ncjwQsuSCdokQF21nhLEVxauZG1EVFBfbXHNP6Idgf5YP6Sooxu0LGBROOf1cABU5L84c0YH3QOO8pa)NhfPc5m2fYf9v0nZ3bt4qkKOOajuHCgl)aY1moKcjQHeQqoJLFa5AgJaU0cijXiKmtfirrbsK721RzHDHCrFfDZ8DWe(zd)keKKasgqfirrbsemKqfYzS8dixZ4qkKOgsK721RzHLFa5Ag)SHFfcssajdOsuSCdokArTG2MBEjpUaTC4TkcIdpBiIdgf5YP6Sooxuu(hG)ZJIuHCg7c5I(k6M57GjCifsuuGeQqoJLFa5AghsHe1qcviNXYpGCnJraxAbKmcjZujk6sWTvumG42bydueebrrAU43b7JIdghEwCWOixovN1X5IIBAueXGOOlb3wrrH(FovNJIc9EGJIjbjcgsaENlaEYnm4VT5M57GjmxovN1qIIcKa8NMb4j27GjCQeajjgHelvbsudjjbjuHCg7c5I(k6M57GjSEnlirnKqfYzS8dixZy9AwqI9qI9rrH(3k3GJIQE7qjcIdBzCWOixovN1X5IIY)a8FEuCA7w1sxt(HKeJqIaHeffiHkKZyd2yFRABU1dYt30p7giCifsuuGeQqoJrmdMUIU9onJdPqIIcKqfYz8vQw4qh42cRxZcsudjtB3Qw6AYpKKyesgik6sWTvuu69EZLGBRw)qGOy)qGw5gCumF1HM4hfbXHhioyuKlNQZ64Crr5Fa(ppkMeKiyi59t3yHCbWUwJWSaCiacsuuGK3pDJfYfa7AncFfKKasMjqirrbsqPCV3a(tZae20TGBBU5OjgbjjgHelHe7He1qssqY02TQLUM8dj2ncjQajkkqY02TQLUM8djJqYmirnKi3TRxZct1Dn32Ctvbe4Km(zd)keKKasOLAiXEirnKKeKi3TRxZc7c5I(k6M57Gj8Zg(viijbKmtfirrbsaENlaw(bKRzmxovN1qIAirUBxVMfw(bKRz8Zg(viijbKmtfiX(OOlb3wrrt3cUT5MJMyueehwqXbJIC5uDwhNlkk)dW)5rXPTBvlDn5hsSBesSesuuGKKGKPTBvlDn5hsgHKbGe1qssqIC3UEnl8KByWFBZnZ3bt4Nn8RqqsciHwQHeBajwcjkkqIq)pNQZyvVDOaj2dj2hfDj42kks1Dn32Ctvbe4KCeehwGXbJIC5uDwhNlkk)dW)5rXPTBvlDn5hsSBesSesuuGKKGKPTBvlDn5hsSBeseeKOgsscsK721RzHP6UMBBUPQacCsg)SHFfcssaj0snKydiXsirrbse6)5uDgR6TdfiXEiX(OOlb3wrrvf00gCbIG4Wc44GrrUCQoRJZffL)b4)8O402TQLUM8dj2ncjckk6sWTvuCYnm4VT5M57GPiio8qhhmkYLt1zDCUOO8pa)NhfN2UvT01KFiXUriXsirrbsM2UvT01KFiXUrizairnKi3TRxZct1Dn32Ctvbe4Km(zd)keKKasOLAiXgqILqIIcKmTDRAPRj)qYiKiiirnKi3TRxZct1Dn32Ctvbe4Km(zd)keKKasOLAiXgqILqIAirUBxVMfwvbnTbxa8Zg(viijbKql1qInGelJIUeCBffLBHy57GBRiioSQloyuKlNQZ64Crr5Fa(ppkc8oxa8KByWFBZnZ3btyUCQoRHe1qcWFAgGNyVdMWPsaKy3iKyPkqIIcKqfYzSlKl6ROBMVdMWHuirrbsOc5mw(bKRzCink6sWTvuu69EZLGBRw)qGOy)qGw5gCumF1HM4hfbXHhI4GrrUCQoRJZffL)b4)8OOC3UEnlS8dixZFdb(ZcglN8NMrT87sWTL3HKeJqYm8qlqirnKKeKmTDRAPRj)qIDJqILqIIcKmTDRAPRj)qIDJqYaqIAirUBxVMfMQ7AUT5MQciWjz8Zg(viijbKql1qInGelHeffizA7w1sxt(HKrirqqIAirUBxVMfMQ7AUT5MQciWjz8Zg(viijbKql1qInGelHe1qIC3UEnlSQcAAdUa4Nn8RqqsciHwQHeBajwcjQHe5UD9Awy5wiw(o42c)SHFfcssaj0snKydiXsiX(OOlb3wrr5hqUM)gc8NfCeehEMkXbJIC5uDwhNlk6sWTvuu69EZLGBRw)qGOy)qGw5gCumF1HM4hfbXHNnloyu0LGBROOCljxG3bSUL7Ubhf5YP6SooxeehEMLXbJIC5uDwhNlkk)dW)5rXPTBvlDn5hsSBeseuu0LGBROO8dixZFdb(ZcocIdpBG4GrrUCQoRJZffL)b4)8O402TQLUM8dj2ncjckk6sWTvu0FPxCdS)ZficIGOy(QdnXpkoyC4zXbJIC5uDwhNlkUPrredIIUeCBfff6)5uDokk07bokkyiHvTWLMYASBZOj)DulVfOT5w6AYpKOgsscsemKa8oxaS8dixZyUCQoRHe1qIC3UEnlSlKl6ROBMVdMWpB4xHGKeqcTudj2asgasuuGe5UD9Awy5hqUMXpB4xHGKeqcTudj2asgasShsuuGew1cxAkRXUnJM83rT8wG2MBPRj)qIAijjirWqcW7CbWYpGCnJ5YP6SgsudjYD761SWUqUOVIUz(oyc)SHFfcssaj0snKydiradjkkqIC3UEnlS8dixZ4Nn8RqqsciHwQHeBajcyiX(OOq)BLBWrrZROrT0D7rqCylJdgf5YP6SooxuCtJIigefDj42kkk0)ZP6CuuO3dCueLY9Ed4pndqy9j8kUHa7BajjgHelHe1qIGHeG35cG)JEcWBa1eYV(KamxovN1qIIcKGs5EVb8NMbiS(eEf3qG9nGKeJqYaqIAib4DUa4)ONa8gqnH8RpjaZLt1znKOOajuHCgZgPw9SxT01KFCifsudjAMkKZyvf00gCbW61SGe1qcviNX6t4vCln8PlIX61SGe1qcviNXUqUOVIUz(oyQ5bWk)dG1Rzfff6FRCdokQrnPJaovNJG4WdehmkYLt1zDCUOO8pa)NhfPc5m2fYf9v0nZ3bty9AwqIAijjiHkKZ4RuTWHoWTfwVMfKOOajuHCgFLQfo0bUTWpB4xHGe7GevhKOgsM2UvT01KFijXiKmaKOOajaVZfaZcaldGBRgIlaxsgZLt1znKOgsK721RzHzbGLbWTvdXfGljJF2WVcbj2bjZubsudjuHCgFLQfo0bUTWpB4xHGe7GKzcesuuGe5UD9Awyxix0xr3mFhmHF2WVcbj2bjZeiKOgsOc5m(kvlCOdCBHF2WVcbj2bjwQcKOgsM2UvT01KFijXiKmaKyFu0LGBRO4vQw4qh42kcIdlO4GrrUCQoRJZffL)b4)8OikL79gWFAgGW6t4vCdb23asSBesSesudjjbjcgsaENlaw(bKRzmxovN1qIAirUBxVMf2fYf9v0nZ3bt4Nn8RqqscizMkqIIcKa8oxaS8dixZyUCQoRHe1qcviNXYpGCnJ1RzbjQHe5UD9Awy5hqUMXpB4xHGKeqYmvGeffiHkKZy5hqUMXiGlTassmcjdnKyFu0LGBROilaSmaUTAiUaCj5iioSaJdgf5YP6Sooxuu(hG)ZJIc9)CQoJ1OM0raNQZqIAirO)Nt1zS5v0Ow6UDirnKKeKKeKiyib4DUaywayzaCB1qCb4sYyUCQoRHeffijjibLY9Ed4pndqy9j8kUHa7BajjgHelHeffirUBxVMfMfawga3wnexaUKm(zd)keKKasOLAiXgqILqI9qI9qIIcKKeKi3TRxZc7c5I(k6M57Gj8Zg(viijbKql1qInGKbGe1qIC3UEnlSlKl6ROBMVdMWpB4xHGe7GKzQajkkqIC3UEnlS8dixZ4Nn8RqqsciHwQHeBajdajQHe5UD9Awy5hqUMXpB4xHGe7GKzQajkkqcviNXYpGCnJdPqIAiHkKZy5hqUMXiGlTasSdsMPcKypKyFu0LGBROO(eEf3qG9nIG4Wc44GrrUCQoRJZffL)b4)8OOq)pNQZyZROrT0D7qIAijjirWqcW7CbWSaWYa42QH4cWLKXC5uDwdjkkqIC3UEnlmlaSmaUTAiUaCjz8Zg(viijbKql1qInGelHeffirUBxVMf2fYf9v0nZ3bt4Nn8RqqsciHwQHeBajdajQHe5UD9Awyxix0xr3mFhmHF2WVcbj2bjZubsuuGe5UD9Awy5hqUMXpB4xHGKeqcTudj2asgasudjYD761SWYpGCnJF2WVcbj2bjZubsuuGeQqoJLFa5AghsHe1qcviNXYpGCnJraxAbKyhKmtfiX(OOlb3wrraBK29h1eYV(KGiicIGiicIra]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 3,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_focused_resolve",

        package = "Retribution",
    } )


    spec:RegisterSetting( "check_wake_range", false, {
        name = "Check |T1112939:0|t Wake of Ashes Range",
        desc = "If checked, when your target is outside of |T1112939:0|t Wake of Ashes' range, it will not be recommended.",
        type = "toggle",
        width = 1.5
    } ) 


end
