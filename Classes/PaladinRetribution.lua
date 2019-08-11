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

            nobuff = 'avenging_wrath',

            handler = function ()
                applyBuff( 'avenging_wrath' )
                applyBuff( "avenging_wrath_crit" )
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

            nobuff = 'crusade',

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

                if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end

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
                if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
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


    spec:RegisterPack( "Retribution", 20190810, [[dCeCybqissEeLk1MqQgLuuNsHyvuQ4vkQAwukDlfQIDb1VKImmKshtrzzuIEgLQMgjPUgsHTrjiFdPOACkuX5uOQwhsrP5rj5EsP9jfoiLGQfQOYdrkkMOcvsUOcvsTrfQsmskbLtQqLWkPuStfkdvHQKwQcvPEkHMQcPRQqLOVQqLAVc9xjnyehMQfJKht0Kj1LrTzj(mbJwroTkRMsOxtsmBP62uy3I(TsdxbhNsGLRQNdz6axxW2jP(ofnEKICEkPwpLkz(Ky)GooloAuu7aooML0oB8PDCMrl2s7NPAlhNOiW6boko4svCbokMUbhfhVzWFubWTzuCWTUVUooAueTHxYrXjayarZ2utchykqHLRrtOZi0DWTP89cOj0ziBkksfUoyCrgPIIAhWXXSK2zJpTJZmAXwA)mvBP9rr0alJJrZPnkoDAnNrQOOMrYOODdjJ3m4pQa42esgV6DxFj0g7gsMaGbenBtnjCGPafwUgnHoJq3b3MY3lGMqNHSjOn2nKyHheciaKmJwBHelPD24djJhiXs7PzNrdOnqBSBiHMzYtbgrZcTXUHKXdKmUCq7awdjL9HKXbBjgAJDdjJhiz8YrtqI0rGMKtEMChsOzgxHGe5elvbbjL9Hel8XDt0mFa5Aghfh(TCDokA3qY4nd(JkaUnHKXRE31xcTXUHKjayarZ2utchykqHLRrtOZi0DWTP89cOj0ziBcAJDdjw4bHacajZO1wiXsANn(qY4bsS0EA2z0aAd0g7gsOzM8uGr0SqBSBiz8ajJlh0oG1qszFizCWwIH2y3qY4bsgVC0eKiDeOj5KNj3HeAMXviiroXsvqqszFiXcFC3enZhqUMXqBG2y3qY4AAILbaRHekUSpdjY1GYbqcflCjcdjw4sjpaqqsU54zYFJsOdjUeCBIGKn7wJH2y3qIlb3Mi8WZY1GYbTLUJubAJDdjUeCBIWdplxdkhmFBtLD1qBSBiXLGBteE4z5Aq5G5BBYdcgCcCWTj0g7gsetFanTai59tdjuHsH1qcc4aeKqXL9zirUguoasOyHlrqINAiz45XZWcaxkajhcs0BYyOn2nK4sWTjcp8SCnOCW8TnHsFanTGkc4ae0gxcUnr4HNLRbLdMVTPHfCBcTXLGBteE4z5Aq5G5BBYFPNCfS)ZjW2R0QkG35eGnDv46wQoAIryoDQoRH2aTXUHKX10eldawdjSA(TgsaNbdjGjgsCjyFi5qqIR2VUt1zm0gxcUnrTptfuHH24sWTjA(2MKEVxDj42S2peW20n4w5UD9AMiOnUeCBIMVTjP37vxcUnR9dbSnDdUvGt(DW(iOnqBCj42eHb)LQWa08TnfqC9aSHTPBWTVBx6qQcQsDc1N1vQaaSj0gxcUnryWFPkmanFBtbexpaByB6gCRfzuDAn78B7vAPcLc2vZPWLcvZ3bt4WGIcvOuWYpGCnJdd0PcLcw(bKRzmc4svANrl0gxcUnryWFPkmanFBtbexpaByB6gCR6Z71Tu98mCaRRu9D12EL2MPcLc2vZPWLcvZ3bt4WGIcvOuWYpGCnJdd0PcLcw(bKRz8Zg(LiRMnoJOO0SC3UEntSRMtHlfQMVdMWpB4xIAypTkkYD761mXYpGCnJF2WVe1WEAhbAJlb3Mim4VufgGMVTPaIRhGnSnDdUvVRbQwcV12ELwQqPGD1CkCPq18DWeomOOqfkfS8dixZ4WaDQqPGLFa5Ag)SHFjYQzJd0gxcUnryWFPkmanFBtbexpaByB6gCRG3zP378JQuSRITxPLkukyxnNcxkunFhmHddkkuHsbl)aY1momqNkuky5hqUMXpB4xISAgnG24sWTjcd(lvHbO5BBkG46bydBt3GBPSwytUsXC17gE6sBVslvOuWUAofUuOA(oychguuOcLcw(bKRzCyaAJlb3Mim4VufgGMVTPaIRhGnSnDdU1GFwfWKJQfpfS9kTnRQ3pDLvZja7AncZ00HaifL3pDLvZja7AncFzJz0yeff0a37vG)cmaH1N6l5kcSVrJwlH24sWTjcd(lvHbO5BBkG46bydBt3GBh6HuZpf7VgvlDhPITxPLkukyxnNcxkunFhmHddkkuHsbl)aY1momqNkuky5hqUMXiGlvPr7mAvuK721RzID1CkCPq18DWe(zd)sudvtdffvrfkfS8dixZ4WaD5UD9AMy5hqUMXpB4xIAOAAaTXLGBteg8xQcdqZ32uaX1dWg2MUb3sXpIFv4hvTyWIbBVslvOuWUAofUuOA(oychguuOcLcw(bKRzCyGovOuWYpGCnJraxQsJ2z0QOi3TRxZe7Q5u4sHQ57Gj8Zg(LOgQMgkkQIkuky5hqUMXHb6YD761mXYpGCnJF2WVe1q10aAJlb3Mim4VufgGMVTPaIRhGnSnDdULtDNrOk4sji8CDl1Y7sWTP3RdRj)2ELwQqPGD1CkCPq18DWeomOOqfkfS8dixZ4WaDQqPGLFa5AgJaUuLgTZOvrrUBxVMj2vZPWLcvZ3bt4Nn8lrnunnuuK721RzILFa5Ag)SHFjQHQPb0gxcUnryWFPkmanFBtbexpaByB6gC7a7FVQp18JQY1yWriBVslvOuWUAofUuOA(oychguuOcLcw(bKRzCyGovOuWYpGCnJraxQsJ2z0cTXLGBteg8xQcdqZ32uaX1dWg2MUb3wUhbQgoGrv0G1cDhHS9kTuHsb7Q5u4sHQ57GjCyqrHkuky5hqUMXHb6uHsbl)aY1m(zd)sKvTZOb0gxcUnryWFPkmanFBtbexpaByB6gCR509DZlfq1HEWWfyBVslvOuWUAofUuOA(oychguuOcLcw(bKRzCyGovOuWYpGCnJF2WVezvRL0cTXLGBteg8xQcdqZ32uaX1dWg2MUb3QF21vHURphSpQs5Ab22R0sfkfSRMtHlfQMVdMWHbffQqPGLFa5AghgOtfkfS8dixZ4Nn8lrw1AjTqBCj42eHb)LQWa08TnfqC9aSHTPBWT6NDD1rd37javnyT373M2ELwQqPGD1CkCPq18DWeomOOqfkfS8dixZ4WaDQqPGLFa5Ag)SHFjYQwlPfAJlb3Mim4VufgGMVTPaIRhGnSnDdUv43uavh(ZW713fyBVsRQOcLc2vZPWLcvZ3bt4WaDvrfkfS8dixZ4Wa0gxcUnryWFPkmanFBtbexpaByB6gCl6Ydb4Vk0D95G9rvkxlW2ELwQqPGD1CkCPq18DWeomOOqfkfS8dixZ4WaDQqPGLFa5Ag)SHFjYQ2z0aAJlb3Mim4VufgGMVTPaIRhGnSnDdUfD5Ha8xf6U(CW(OQbR9E)202R0sfkfSRMtHlfQMVdMWHbffQqPGLFa5AghgOtfkfS8dixZ4Nn8lrw1AjTqBCj42eHb)LQWa08TnfqC9aSHTPBWTUDHM83r1YMG6wQdRj)2ELwvb8oNaS8dixZyoDQoRPl3TRxZe7Q5u4sHQ57Gj8Zg(LiROHIcW7CcWYpGCnJ50P6SMUC3UEntS8dixZ4Nn8lrwrd6GZGBmJwfLPTBDDyn5VrR90bNbB1mAPd8oNaSPRcx3s1rtmcZPt1zn0gxcUnryWFPkmanFBtbexpaByB6gCR6dDBw3svZghIT9kTuHsb7Q5u4sHQ57GjCyqrHkuky5hqUMXHb6uHsbl)aY1mgbCPkTZOvrrUBxVMj2vZPWLcvZ3bt4Nn8lrnATNwff5UD9AMy5hqUMXpB4xIA0ApTqBCj42eHb)LQWa08TnfqC9aSHTPBWToAsTNmQ(UDTFvUV3T9kTAMkuk43TR9RY99EvZuHsbRxZurPzQqPGD1CkCPq18DWe(zd)suJwlPvrHkuky5hqUMXiGlvPDgT0PcLcw(bKRz8Zg(LOgZOXi0BwUBxVMjwi4V(8SULQBx8VGj8Zg(LOgJpTkkGZGRGTQp2k7PvrrvmcXPKXYn1CIyDTFfUSVKXgUf3FeOnUeCBIWG)svyaA(2MciUEa2W20n4wvYfu3s1t5XjOwcV12ELwQqPGD1CkCPq18DWeomOOqfkfS8dixZ4WaDQqPGLFa5AgJaUuLgTZOvrrUBxVMj2vZPWLcvZ3bt4Nn8lrnSNwffvrfkfS8dixZ4WaD5UD9AMy5hqUMXpB4xIAypTqBCj42eHb)LQWa08TnfqC9aSbY2R0sfkfSRMtHlfQMVdMWHbffQqPGLFa5AghgOtfkfS8dixZyeWLQ0oJwOnqBCj42eHL721RzIAhwWTPTxPTz5UD9AMyHG)6ZZ6wQUDX)cMWpB4xIAm(0QOOkgH4uYy5MAorSU2Vcx2xYyd3I7pc9MPcLcMQVRUhqa8ZUeOOqfkfSRMtHlfQMVdMWHb6uHsb7Q5u4sHQ57Gj8Zg(LOgZghffQqPGLFa5AghgOtfkfS8dixZ4Nn8lrwzjngbAJlb3MiSC3UEnt08Tn1pHjaQAXGwWGtGTxPfnW9Ef4Vadq4(jmbqvlg0cgCcA0APIsZQ69txz1CcWUwJWmnDiasr59txz1CcWUwJWx2GMtJrG24sWTjcl3TRxZenFBtL7zQ(UABVslvOuWUAofUuOA(oychguuOcLcw(bKRzCyGovOuWYpGCnJraxQs7mAH24sWTjcl3TRxZenFBtOPJ766wQQ5uG9uY2ELwQqPGrmdMUuO(UaJ1RzsNkukyd2yFRRBP2dYtx1p7giSEntOnUeCBIWYD761mrZ32K079Qlb3M1(Ha2MUb3c(lvHbiOnUeCBIWYD761mrZ32eyIRHKAdPUw2xY2ELwWzWw1APIcvOuWplvPZiuTSVKXHbOnUeCBIWYD761mrZ32evFxDDlvWex5KnS22R0sfkfSRMtHlfQMVdMWHbffQqPGLFa5AghgOtfkfS8dixZyeWLQ0oJwOnUeCBIWYD761mrZ32KqWF95zDlv3U4Fbt2ELwvb8oNaS8dixZyoDQoRP3SC3UEntSRMtHlfQMVdMWpB4xISIg0N2U11H1K)gT2tVzQqPGV0cch6a3M4WGIIQaENta(sliCOdCBI50P6SEeff5UD9AMyxnNcxkunFhmHF2WVe1Ov10yefLMbENtaw(bKRzmNovN10L721RzILFa5Ag)SHFjYkbPM(02TUoSM83Ov1kktB366WAYFJw7Pdod2Qz0sh4DobytxfUULQJMyeMtNQZAff5UD9AMy5hqUMXpB4xIA0QAAmc0gxcUnry5UD9AMO5BBYC)UwnFz9z0MEkzBVsRC3UEntSRMtHlfQMVdMWpB4xISsqQPpTDRRdRj)nATxrrUBxVMjw(bKRz8Zg(LiReKA6tB366WAYFJwvROi3TRxZe7Q5u4sHQ57Gj8Zg(LOgTQMgkkYD761mXYpGCnJF2WVe1Ov10aAJlb3MiSC3UEnt08TnvwzaX6QBx8FaUsXUHTxPTzv9(PRSAobyxRryMMoeaPO8(PRSAobyxRr4lBypTkkObU3Ra)fyacRp1xYveyFJgTwoc9MPcLc2vZPWLcvZ3bty9AM0PcLcw(bKRzSEnZrO3SC3UEntmv31CDlvlgqGtY4Nn8lrneKA7ypD5UD9AMylg0cgCcWpB4xIAii12X(rG24sWTjcl3TRxZenFBtgSX(wx3sThKNUQF2nq2EL2MPcLc2vZPWLcvZ3bt4WGIcvOuWYpGCnJdd0PcLcw(bKRzmc4svANr7i0N2U11H1KFRAThAJlb3MiSC3UEnt08Tnne(Ry9LcvQUJa2EL2Mv17NUYQ5eGDTgHzA6qaKIY7NUYQ5eGDTgHVSH90QOGg4EVc8xGbiS(uFjxrG9nA0A5iqBCj42eHL721RzIMVTPaIRhGnSLlfwcQPBWTsRL9f8BEYkv3raBVsBZuHsb7Q5u4sHQ57GjSEnt6uHsbl)aY1mwVM5i0BwUBxVMjMQ7AUULQfdiWjz8Zg(LOgcsTDSNUC3UEntSfdAbdob4Nn8lrneKA7y)iqBCj42eHL721RzIMVTjxnNcxkunFhmz7vABwvaVZjaFPfeo0bUnXC6uDwROqfkf8Lwq4qh42ehggH(02TUoSM83O1EOnUeCBIWYD761mrZ32K8dixZ2EL2PTBDDyn5VrRQvuM2U11H1K)gT2thCgSvZOLoW7CcWMUkCDlvhnXimNovN1qBG24sWTjcxU8qt8JAv7)5uD220n4wZlfq1HD72Q27bUvvSfeUHbwJNzHgF7NPA6nRkG35eGLFa5AgZPt1znD5UD9AMyxnNcxkunFhmHF2WVe1qqQTJ9kkYD761mXYpGCnJF2WVe1qqQTJ9JOOWwq4ggynEMfA8TFMQP3SQaENtaw(bKRzmNovN10L721RzID1CkCPq18DWe(zd)sudbP2owiff5UD9AMy5hqUMXpB4xIAii12Xcnc0gxcUnr4YLhAIF08TnP2)ZP6STPBWTAuv6iGt1zBv79a3Ig4EVc8xGbiS(uFjxrG9nA0AjDvb8oNa8FctaEdOQA(1NeG50P6SwrbnW9Ef4Vadqy9P(sUIa7B0O1E6aVZja)NWeG3aQQMF9jbyoDQoRvuOcLcMngS(zpRdRj)4WaDntfkfSfdAbdoby9AM0PcLcwFQVKRdHFyrmwVMjDQqPGD1CkCPq18DWu1dGv(haRxZeAJlb3MiC5YdnXpA(2MU0cch6a3M2ELwQqPGV0cch6a3My9AMkkuHsb7Q5u4sHQ57GjSEnt6ntfkf8Lwq4qh42e)SHFjYQXH(02TUoSM83O1EffG35eGzAILbWTzfXjGtjJ50P6SMUC3UEntmttSmaUnRiobCkz8Zg(LiRMrlDQqPGV0cch6a3M4Nn8lrwnJgkkYD761mXUAofUuOA(oyc)SHFjYQz0GovOuWxAbHdDGBt8Zg(LiRSKw6tB366WAYFJw7hbAJlb3MiC5YdnXpA(2MyAILbWTzfXjGtjB7vArdCVxb(lWaewFQVKRiW(gw1Aj9MvfW7CcWYpGCnJ50P6SMUC3UEntSRMtHlfQMVdMWpB4xIAmJwffG35eGLFa5AgZPt1znDQqPGLFa5AgRxZKUC3UEntS8dixZ4Nn8lrnMrRIcvOuWYpGCnJraxQsJwA(iqBCj42eHlxEOj(rZ32K(uFjxrG9nS9kTQ9)CQoJ1OQ0raNQZ0v7)5uDgBEPaQoSBNEZnRkG35eGzAILbWTzfXjGtjJ50P6SwrPz0a37vG)cmaH1N6l5kcSVrJwlvuK721RzIzAILbWTzfXjGtjJF2WVe1qqQTJLJmIIsZYD761mXUAofUuOA(oyc)SHFjQHGuBh7Pl3TRxZe7Q5u4sHQ57Gj8Zg(LiRMrRIIC3UEntS8dixZ4Nn8lrneKA7ypD5UD9AMy5hqUMXpB4xISAgTkkuHsbl)aY1momqNkuky5hqUMXiGlvXQz0oYiqBCj42eHlxEOj(rZ32eGng6(JQQ5xFsGTxPvT)Nt1zS5LcO6WUD6nRkG35eGzAILbWTzfXjGtjJ50P6SwrrUBxVMjMPjwga3MveNaoLm(zd)sudbP2owQOi3TRxZe7Q5u4sHQ57Gj8Zg(LOgcsTDSNUC3UEntSRMtHlfQMVdMWpB4xISAgTkkYD761mXYpGCnJF2WVe1qqQTJ90L721RzILFa5Ag)SHFjYQz0QOqfkfS8dixZ4WaDQqPGLFa5AgJaUufRMr7iqBG24sWTjclWj)oyFuRA)pNQZ2MUb3AHTJBBv79a32SQaENtaEYnm4VULQ57GjmNovN1kka)fyaEI9oycpibnATKw6ntfkfSRMtHlfQMVdMW61mPtfkfS8dixZy9AMJmc0gxcUnrybo53b7JMVTjP37vxcUnR9dbSnDdUTC5HM4hz7vAN2U11H1K)gT0qrHkukyd2yFRRBP2dYtx1p7giCyqrHkukyeZGPlfQVlW4WGIcvOuWxAbHdDGBtSEnt6tB366WAYFJw7H24sWTjclWj)oyF08Tnz6QW1TuD0eJS9kTnRQ3pDLvZja7AncZ00HaifL3pDLvZja7AncFzJz0qrbnW9Ef4VadqytxfUULQJMyuJwlhHEZtB366WAYVvT0QOmTDRRdRj)TZOl3TRxZet1Dnx3s1Ibe4Km(zd)sudbPEe6nl3TRxZe7Q5u4sHQ57Gj8Zg(LOgZOvrb4Doby5hqUMXC6uDwtxUBxVMjw(bKRz8Zg(LOgZODeOnUeCBIWcCYVd2hnFBtuDxZ1TuTyabojB7vAN2U11H1KFRATurP5PTBDDyn5V1E6nl3TRxZep5gg8x3s18DWe(zd)sudbP2owQOO2)ZP6m2cBh3Jmc0gxcUnrybo53b7JMVTjlg0cgCcS9kTtB366WAYVvTwQO0802TUoSM8BvRQP3SC3UEntmv31CDlvlgqGtY4Nn8lrneKA7yPIIA)pNQZylSDCpYiqBCj42eHf4KFhSpA(2MMCdd(RBPA(oyY2R0oTDRRdRj)w1QAOnUeCBIWcCYVd2hnFBtYnrS8DWTPTxPDA7wxhwt(TQ1sfLPTBDDyn53Qw7Pl3TRxZet1Dnx3s1Ibe4Km(zd)sudbP2owQOmTDRRdRj)TQMUC3UEntmv31CDlvlgqGtY4Nn8lrneKA7yjD5UD9AMylg0cgCcWpB4xIAii12XsOnUeCBIWcCYVd2hnFBtsV3RUeCBw7hcyB6gCB5YdnXpY2R0c8oNa8KByWFDlvZ3btyoDQoRPd8xGb4j27Gj8GeyvRL0QOqfkfSRMtHlfQMVdMWHbffQqPGLFa5AghgG24sWTjclWj)oyF08Tnj)aY18xrG)uHT9kTYD761mXYpGCn)ve4pvySCYFbgvlVlb3MEVr7mmnNg0BEA7wxhwt(TQ1sfLPTBDDyn53Qw7Pl3TRxZet1Dnx3s1Ibe4Km(zd)sudbP2owQOmTDRRdRj)TQMUC3UEntmv31CDlvlgqGtY4Nn8lrneKA7yjD5UD9AMylg0cgCcWpB4xIAii12Xs6YD761mXYnrS8DWTj(zd)sudbP2owoc0gxcUnrybo53b7JMVTjP37vxcUnR9dbSnDdUTC5HM4hbTXLGBtewGt(DW(O5BBsUPKtW7awxlD3GH24sWTjclWj)oyF08Tnj)aY18xrG)uHT9kTtB366WAYVvTQgAJlb3MiSaN87G9rZ32K)sp5ky)NtGTxPDA7wxhwt(TQv1rr18JUnJJzjTZgFAP52plkA6FEPakkoUWyyFaRHeleK4sWTjK0peaHH2ef7hcGIJgf1CXdDqC04yZIJgfDj42mk(mvqfokYPt1zDCUiioMLXrJIC6uDwhNlk6sWTzuu69E1LGBZA)qGOy)qGA6gCuuUBxVMjkcIJzFC0OiNovN1X5IIUeCBgfLEVxDj42S2peik2peOMUbhff4KFhSpkcIGO4WZY1GYbXrJJnloAu0LGBZO4WcUnJIC6uDwhNlcIJzzC0OiNovN1X5IIY)a8FEuuvqcW7CcWMUkCDlvhnXimNovN1rrxcUnJI(l9KRG9FobrqeefL721RzIIJghBwC0OiNovN1X5IIY)a8FEuSzirUBxVMjwi4V(8SULQBx8VGj8Zg(LiiPbKm(0cjkkqIQGegH4uYy5MAorSU2Vcx2xYyd3I7djJaj0HKMHeQqPGP67Q7bea)SlbqIIcKqfkfSRMtHlfQMVdMWHbiHoKqfkfSRMtHlfQMVdMWpB4xIGKgqYSXbsuuGeQqPGLFa5AghgGe6qcvOuWYpGCnJF2WVebjwbjwsdizKOOlb3MrXHfCBgbXXSmoAuKtNQZ64Crr5Fa(ppkIg4EVc8xGbiC)eMaOQfdAbdobqsJwiXsirrbsAgsufK8(PRSAobyxRryMMoeabjkkqY7NUYQ5eGDTgHVesAaj0CAajJefDj42mk2pHjaQAXGwWGtqeehZ(4OrroDQoRJZffL)b4)8OivOuWUAofUuOA(oychgGeffiHkuky5hqUMXHbiHoKqfkfS8dixZyeWLQajTqYmAJIUeCBgfl3Zu9D1rqCmvhhnkYPt1zDCUOO8pa)NhfPcLcgXmy6sH67cmwVMjKqhsOcLc2Gn2366wQ9G80v9ZUbcRxZmk6sWTzuenDCxx3svnNcSNsocIJrJ4OrroDQoRJZffDj42mkk9EV6sWTzTFiquSFiqnDdokc(lvHbOiioMfkoAuKtNQZ64Crr5Fa(ppkcodgsSQfsSesuuGeQqPGFwQsNrOAzFjJddrrxcUnJIGjUgsQnK6AzFjhbXXO5XrJIC6uDwhNlkk)dW)5rrQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddqcDiHkuky5hqUMXiGlvbsAHKz0gfDj42mks13vx3sfmXvozdRJG4yJtC0OiNovN1X5IIY)a8FEuuvqcW7CcWYpGCnJ50P6SgsOdjndjYD761mXUAofUuOA(oyc)SHFjcsScsObKqhsM2U11H1KFiPrlKypKqhsAgsOcLc(sliCOdCBIddqIIcKOkib4Dob4lTGWHoWTjMtNQZAizeirrbsK721RzID1CkCPq18DWe(zd)seK0OfsunnGKrGeffiPzib4Doby5hqUMXC6uDwdj0He5UD9AMy5hqUMXpB4xIGeRGebPgsOdjtB366WAYpK0OfsunKOOajtB366WAYpK0OfsShsOdjGZGHeRGKz0cj0HeG35eGnDv46wQoAIryoDQoRHeffirUBxVMjw(bKRz8Zg(LiiPrlKOAAajJefDj42mkke8xFEw3s1Tl(xWueehB8JJgf50P6Sooxuu(hG)ZJIYD761mXUAofUuOA(oyc)SHFjcsScseKAiHoKmTDRRdRj)qsJwiXEirrbsK721RzILFa5Ag)SHFjcsScseKAiHoKmTDRRdRj)qsJwir1qIIcKi3TRxZe7Q5u4sHQ57Gj8Zg(LiiPrlKOAAajkkqIC3UEntS8dixZ4Nn8lrqsJwir10ik6sWTzu0C)UwnFz9z0MEk5iio2mAJJgf50P6Sooxuu(hG)ZJIndjQcsE)0vwnNaSR1imtthcGGeffi59txz1CcWUwJWxcjnGe7PfsuuGe0a37vG)cmaH1N6l5kcSVbK0OfsSesgbsOdjndjuHsb7Q5u4sHQ57GjSEntiHoKqfkfS8dixZy9AMqYiqcDiPzirUBxVMjMQ7AUULQfdiWjz8Zg(LiiPbKii1qIDGe7He6qIC3UEntSfdAbdob4Nn8lrqsdirqQHe7aj2djJefDj42mkwwzaX6QBx8FaUsXUreehB2S4OrroDQoRJZffL)b4)8OyZqcvOuWUAofUuOA(oychgGeffiHkuky5hqUMXHbiHoKqfkfS8dixZyeWLQajTqYmAHKrGe6qY02TUoSM8djw1cj2hfDj42mkAWg7BDDl1EqE6Q(z3afbXXMzzC0OiNovN1X5IIY)a8FEuSzirvqY7NUYQ5eGDTgHzA6qaeKOOajVF6kRMta21Ae(siPbKypTqIIcKGg4EVc8xGbiS(uFjxrG9nGKgTqILqYirrxcUnJIdH)kwFPqLQ7iqeehBM9XrJIC6uDwhNlk6sWTzuuATSVGFZtwP6ocefL)b4)8OyZqcvOuWUAofUuOA(oycRxZesOdjuHsbl)aY1mwVMjKmcKqhsAgsK721RzIP6UMRBPAXacCsg)SHFjcsAajcsnKyhiXEiHoKi3TRxZeBXGwWGta(zd)seK0aseKAiXoqI9qYirrUuyjOMUbhfLwl7l438KvQUJarqCSzQooAuKtNQZ64Crr5Fa(ppk2mKOkib4Dob4lTGWHoWTjMtNQZAirrbsOcLc(sliCOdCBIddqYiqcDizA7wxhwt(HKgTqI9rrxcUnJIUAofUuOA(oykcIJnJgXrJIC6uDwhNlkk)dW)5rXPTBDDyn5hsA0cjQgsuuGKPTBDDyn5hsA0cj2dj0HeWzWqIvqYmAHe6qcW7CcWMUkCDlvhnXimNovN1rrxcUnJIYpGCnhbrque8xQcdqXrJJnloAuKtNQZ64CrX0n4O472LoKQGQuNq9zDLkaaBgfDj42mk(UDPdPkOk1juFwxPcaWMrqCmlJJgf50P6Sooxu0LGBZOOfzuDAn78hfL)b4)8OivOuWUAofUuOA(oychgGeffiHkuky5hqUMXHbiHoKqfkfS8dixZyeWLQajTqYmAJIPBWrrlYO60A25pcIJzFC0OiNovN1X5IIUeCBgfvFEVULQNNHdyDLQVRokk)dW)5rXMHeQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddqcDiHkuky5hqUMXpB4xIGeRGKzJdKmcKOOajndjYD761mXUAofUuOA(oyc)SHFjcsAaj2tlKOOajYD761mXYpGCnJF2WVebjnGe7PfsgjkMUbhfvFEVULQNNHdyDLQVRocIJP64OrroDQoRJZffDj42mkQ31avlH36OO8pa)NhfPcLc2vZPWLcvZ3bt4WaKOOajuHsbl)aY1momaj0HeQqPGLFa5Ag)SHFjcsScsMnorX0n4OOExduTeERJG4y0ioAuKtNQZ64CrrxcUnJIcENLEVZpQsXUkrr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1m(zd)seKyfKmJgrX0n4OOG3zP378JQuSRseehZcfhnkYPt1zDCUOOlb3MrrkRf2KRumx9UHNUmkk)dW)5rrQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddrX0n4OiL1cBYvkMRE3WtxgbXXO5XrJIC6uDwhNlk6sWTzu0GFwfWKJQfpfIIY)a8FEuSzirvqY7NUYQ5eGDTgHzA6qaeKOOajVF6kRMta21Ae(siPbKmJgqYiqIIcKGg4EVc8xGbiS(uFjxrG9nGKgTqILrX0n4OOb)SkGjhvlEkebXXgN4OrroDQoRJZffDj42mko0dPMFk2FnQw6osLOO8pa)NhfPcLc2vZPWLcvZ3bt4WaKOOajuHsbl)aY1momaj0HeQqPGLFa5AgJaUufiPrlKmJwirrbsK721RzID1CkCPq18DWe(zd)seK0asunnGeffirvqcvOuWYpGCnJddqcDirUBxVMjw(bKRz8Zg(LiiPbKOAAeft3GJId9qQ5NI9xJQLUJujcIJn(XrJIC6uDwhNlk6sWTzuKIFe)QWpQAXGfdrr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqsJwizgTqIIcKi3TRxZe7Q5u4sHQ57Gj8Zg(LiiPbKOAAajkkqIQGeQqPGLFa5AghgGe6qIC3UEntS8dixZ4Nn8lrqsdir10ikMUbhfP4hXVk8JQwmyXqeehBgTXrJIC6uDwhNlk6sWTzuKtDNrOk4sji8CDl1Y7sWTP3RdRj)rr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqsJwizgTqIIcKi3TRxZe7Q5u4sHQ57Gj8Zg(LiiPbKOAAajkkqIC3UEntS8dixZ4Nn8lrqsdir10ikMUbhf5u3zeQcUuccpx3sT8UeCB696WAYFeehB2S4OrroDQoRJZffDj42mkoW(3R6tn)OQCngCekkk)dW)5rrQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddqcDiHkuky5hqUMXiGlvbsA0cjZOnkMUbhfhy)7v9PMFuvUgdocfbXXMzzC0OiNovN1X5IIUeCBgfl3JavdhWOkAWAHUJqrr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1m(zd)seKyvlKmJgrX0n4Oy5EeOA4agvrdwl0DekcIJnZ(4OrroDQoRJZffDj42mkAoDF38sbuDOhmCbokk)dW)5rrQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddqcDiHkuky5hqUMXpB4xIGeRAHelPnkMUbhfnNUVBEPaQo0dgUahbXXMP64OrroDQoRJZffDj42mkQF21vHURphSpQs5Abokk)dW)5rrQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddqcDiHkuky5hqUMXpB4xIGeRAHelPnkMUbhf1p76Qq31Nd2hvPCTahbXXMrJ4OrroDQoRJZffDj42mkQF21vhnCVNau1G1EVFBgfL)b4)8OivOuWUAofUuOA(oychgGeffiHkuky5hqUMXHbiHoKqfkfS8dixZ4Nn8lrqIvTqIL0gft3GJI6NDD1rd37javnyT373MrqCSzwO4OrroDQoRJZffDj42mkk8BkGQd)z4967cCuu(hG)ZJIQcsOcLc2vZPWLcvZ3bt4WaKqhsufKqfkfS8dixZ4WqumDdokk8BkGQd)z4967cCeehBgnpoAuKtNQZ64CrrxcUnJIOlpeG)Qq31Nd2hvPCTahfL)b4)8OivOuWUAofUuOA(oychgGeffiHkuky5hqUMXHbiHoKqfkfS8dixZ4Nn8lrqIvTqYmAeft3GJIOlpeG)Qq31Nd2hvPCTahbXXMnoXrJIC6uDwhNlk6sWTzueD5Ha8xf6U(CW(OQbR9E)2mkk)dW)5rrQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddqcDiHkuky5hqUMXpB4xIGeRAHelPnkMUbhfrxEia)vHURphSpQAWAV3VnJG4yZg)4OrroDQoRJZffDj42mk62fAYFhvlBcQBPoSM8hfL)b4)8OOQGeG35eGLFa5AgZPt1znKqhsK721RzID1CkCPq18DWe(zd)seKyfKqdirrbsaENtaw(bKRzmNovN1qcDirUBxVMjw(bKRz8Zg(LiiXkiHgqcDibCgmK0asMrlKOOajtB366WAYpK0OfsShsOdjGZGHeRGKz0cj0HeG35eGnDv46wQoAIryoDQoRJIPBWrr3Uqt(7OAztqDl1H1K)iioML0ghnkYPt1zDCUOOlb3Mrr1h62SULQMnoehfL)b4)8OivOuWUAofUuOA(oychgGeffiHkuky5hqUMXHbiHoKqfkfS8dixZyeWLQajTqYmAHeffirUBxVMj2vZPWLcvZ3bt4Nn8lrqsJwiXEAHeffirUBxVMjw(bKRz8Zg(LiiPrlKypTrX0n4OO6dDBw3svZghIJG4ywoloAuKtNQZ64CrrxcUnJIoAsTNmQ(UDTFvUV3JIY)a8FEuuZuHsb)UDTFvUV3RAMkuky9AMqIIcK0mKqfkfSRMtHlfQMVdMWpB4xIGKgTqIL0cjkkqcvOuWYpGCnJraxQcK0cjZOfsOdjuHsbl)aY1m(zd)seK0asMrdizeiHoK0mKi3TRxZele8xFEw3s1Tl(xWe(zd)seK0asgFAHeffibCgCfSv9XqIvqI90cjkkqIQGegH4uYy5MAorSU2Vcx2xYyd3I7djJeft3GJIoAsTNmQ(UDTFvUV3JG4ywAzC0OiNovN1X5IIUeCBgfvjxqDlvpLhNGAj8whfL)b4)8OivOuWUAofUuOA(oychgGeffiHkuky5hqUMXHbiHoKqfkfS8dixZyeWLQajnAHKz0cjkkqIC3UEntSRMtHlfQMVdMWpB4xIGKgqI90cjkkqIQGeQqPGLFa5AghgGe6qIC3UEntS8dixZ4Nn8lrqsdiXEAJIPBWrrvYfu3s1t5XjOwcV1rqCmlTpoAuKtNQZ64Crr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqslKmJ2OOlb3MrXaIRhGnqrqeeflxEOj(rXrJJnloAuKtNQZ64CrXDikIyqu0LGBZOOA)pNQZrr1EpWrrvbjSfeUHbwJD7cn5VJQLnb1Tuhwt(He6qsZqIQGeG35eGLFa5AgZPt1znKqhsK721RzID1CkCPq18DWe(zd)seK0aseKAiXoqI9qIIcKi3TRxZel)aY1m(zd)seK0aseKAiXoqI9qYiqIIcKWwq4ggyn2Tl0K)oQw2eu3sDyn5hsOdjndjQcsaENtaw(bKRzmNovN1qcDirUBxVMj2vZPWLcvZ3bt4Nn8lrqsdirqQHe7ajwiirrbsK721RzILFa5Ag)SHFjcsAajcsnKyhiXcbjJefv7FnDdokAEPaQoSBpcIJzzC0OiNovN1X5II7queXGOOlb3Mrr1(FovNJIQ9EGJIObU3Ra)fyacRp1xYveyFdiPrlKyjKqhsufKa8oNa8FctaEdOQA(1NeG50P6SgsuuGe0a37vG)cmaH1N6l5kcSVbK0OfsShsOdjaVZja)NWeG3aQQMF9jbyoDQoRHeffiHkuky2yW6N9SoSM8JddqcDirZuHsbBXGwWGtawVMjKqhsOcLcwFQVKRdHFyrmwVMjKqhsOcLc2vZPWLcvZ3btvpaw5FaSEnZOOA)RPBWrrnQkDeWP6CeehZ(4OrroDQoRJZffL)b4)8OivOuWxAbHdDGBtSEntirrbsOcLc2vZPWLcvZ3bty9AMqcDiPziHkuk4lTGWHoWTj(zd)seKyfKmoqcDizA7wxhwt(HKgTqI9qIIcKa8oNamttSmaUnRiobCkzmNovN1qcDirUBxVMjMPjwga3MveNaoLm(zd)seKyfKmJwiHoKqfkf8Lwq4qh42e)SHFjcsScsMrdirrbsK721RzID1CkCPq18DWe(zd)seKyfKmJgqcDiHkuk4lTGWHoWTj(zd)seKyfKyjTqcDizA7wxhwt(HKgTqI9qYirrxcUnJIxAbHdDGBZiioMQJJgf50P6Sooxuu(hG)ZJIObU3Ra)fyacRp1xYveyFdiXQwiXsiHoK0mKOkib4Doby5hqUMXC6uDwdj0He5UD9AMyxnNcxkunFhmHF2WVebjnGKz0cjkkqcW7CcWYpGCnJ50P6SgsOdjuHsbl)aY1mwVMjKqhsK721RzILFa5Ag)SHFjcsAajZOfsuuGeQqPGLFa5AgJaUufiPrlKqZHKrIIUeCBgfzAILbWTzfXjGtjhbXXOrC0OiNovN1X5IIY)a8FEuuT)Nt1zSgvLoc4uDgsOdjQ9)CQoJnVuavh2Tdj0HKMHKMHevbjaVZjaZ0eldGBZkItaNsgZPt1znKOOajndjObU3Ra)fyacRp1xYveyFdiPrlKyjKOOajYD761mXmnXYa42SI4eWPKXpB4xIGKgqIGudj2bsSesgbsgbsuuGKMHe5UD9AMyxnNcxkunFhmHF2WVebjnGebPgsSdKypKqhsK721RzID1CkCPq18DWe(zd)seKyfKmJwirrbsK721RzILFa5Ag)SHFjcsAajcsnKyhiXEiHoKi3TRxZel)aY1m(zd)seKyfKmJwirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqIvqYmAHKrGKrIIUeCBgf1N6l5kcSVreehZcfhnkYPt1zDCUOO8pa)Nhfv7)5uDgBEPaQoSBhsOdjndjQcsaENtaMPjwga3MveNaoLmMtNQZAirrbsK721RzIzAILbWTzfXjGtjJF2WVebjnGebPgsSdKyjKOOajYD761mXUAofUuOA(oyc)SHFjcsAajcsnKyhiXEiHoKi3TRxZe7Q5u4sHQ57Gj8Zg(LiiXkizgTqIIcKi3TRxZel)aY1m(zd)seK0aseKAiXoqI9qcDirUBxVMjw(bKRz8Zg(LiiXkizgTqIIcKqfkfS8dixZ4WaKqhsOcLcw(bKRzmc4svGeRGKz0cjJefDj42mkcyJHU)OQA(1NeebrquuGt(DW(O4OXXMfhnkYPt1zDCUO4oefrmik6sWTzuuT)Nt15OOAVh4OyZqIQGeG35eGNCdd(RBPA(oycZPt1znKOOaja)fyaEI9oycpibqsJwiXsAHe6qsZqcvOuWUAofUuOA(oycRxZesOdjuHsbl)aY1mwVMjKmcKmsuuT)10n4OOf2oUJG4ywghnkYPt1zDCUOO8pa)NhfN2U11H1KFiPrlKqdirrbsOcLc2Gn2366wQ9G80v9ZUbchgGeffiHkukyeZGPlfQVlW4WaKOOajuHsbFPfeo0bUnX61mHe6qY02TUoSM8djnAHe7JIUeCBgfLEVxDj42S2peik2peOMUbhflxEOj(rrqCm7JJgf50P6Sooxuu(hG)ZJIndjQcsE)0vwnNaSR1imtthcGGeffi59txz1CcWUwJWxcjnGKz0asuuGe0a37vG)cmaHnDv46wQoAIrqsJwiXsizeiHoK0mKmTDRRdRj)qIvTqcTqIIcKmTDRRdRj)qslKmdsOdjYD761mXuDxZ1TuTyabojJF2WVebjnGebPgsgbsOdjndjYD761mXUAofUuOA(oyc)SHFjcsAajZOfsuuGeG35eGLFa5AgZPt1znKqhsK721RzILFa5Ag)SHFjcsAajZOfsgjk6sWTzu00vHRBP6OjgfbXXuDC0OiNovN1X5IIY)a8FEuCA7wxhwt(HeRAHelHeffiPzizA7wxhwt(HKwiXEiHoK0mKi3TRxZep5gg8x3s18DWe(zd)seK0aseKAiXoqILqIIcKO2)ZP6m2cBh3qYiqYirrxcUnJIuDxZ1TuTyabojhbXXOrC0OiNovN1X5IIY)a8FEuCA7wxhwt(HeRAHelHeffiPzizA7wxhwt(HeRAHevdj0HKMHe5UD9AMyQUR56wQwmGaNKXpB4xIGKgqIGudj2bsSesuuGe1(FovNXwy74gsgbsgjk6sWTzu0IbTGbNGiioMfkoAuKtNQZ64Crr5Fa(ppkoTDRRdRj)qIvTqIQJIUeCBgfNCdd(RBPA(oykcIJrZJJgf50P6Sooxuu(hG)ZJItB366WAYpKyvlKyjKOOajtB366WAYpKyvlKypKqhsK721RzIP6UMRBPAXacCsg)SHFjcsAajcsnKyhiXsirrbsM2U11H1KFiPfsunKqhsK721RzIP6UMRBPAXacCsg)SHFjcsAajcsnKyhiXsiHoKi3TRxZeBXGwWGta(zd)seK0aseKAiXoqILrrxcUnJIYnrS8DWTzeehBCIJgf50P6Sooxuu(hG)ZJIaVZjap5gg8x3s18DWeMtNQZAiHoKa8xGb4j27Gj8Geajw1cjwslKOOajuHsb7Q5u4sHQ57GjCyasuuGeQqPGLFa5AghgIIUeCBgfLEVxDj42S2peik2peOMUbhflxEOj(rrqCSXpoAuKtNQZ64Crr5Fa(ppkk3TRxZel)aY18xrG)uHXYj)fyuT8UeCB6DiPrlKmdtZPbKqhsAgsM2U11H1KFiXQwiXsirrbsM2U11H1KFiXQwiXEiHoKi3TRxZet1Dnx3s1Ibe4Km(zd)seK0aseKAiXoqILqIIcKmTDRRdRj)qslKOAiHoKi3TRxZet1Dnx3s1Ibe4Km(zd)seK0aseKAiXoqILqcDirUBxVMj2IbTGbNa8Zg(LiiPbKii1qIDGelHe6qIC3UEntSCtelFhCBIF2WVebjnGebPgsSdKyjKmsu0LGBZOO8dixZFfb(tfocIJnJ24OrroDQoRJZffDj42mkk9EV6sWTzTFiquSFiqnDdokwU8qt8JIG4yZMfhnk6sWTzuuUPKtW7awxlD3GJIC6uDwhNlcIJnZY4OrroDQoRJZffL)b4)8O402TUoSM8djw1cjQok6sWTzuu(bKR5VIa)PchbXXMzFC0OiNovN1X5IIY)a8FEuCA7wxhwt(HeRAHevhfDj42mk6V0tUc2)5eebrqeef9ayA)OO4zqZebrqmc]] )


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
