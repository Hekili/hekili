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

        avenging_wrath_crit = {
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


    spec:RegisterPack( "Retribution", 20190709.1600, [[du0shbqikv8ifLytcvJsHYPuOAvuQ0RuinlkLULIsXUG6xuQAyiPogsyzukEMIkttrvxtrX2uuQ(McHghjHCofISofcAEcLUNc2Nu0bvus0cLc9qscfxKKqvJurP0jjjuALir7ukyOkkjSufLKEkIMQqXvjju5RkkP2lP(RunychMQfJWJjAYuCzuBwKpJuJwroTsRMKOxJKmBrDBsSBj)gy4sPJRqulxvph00v56c2oj13fY4jj48KKwVcbMpLSFiRPqhJM04hRBWgQPyKOEePEKWum7up7upJM8uTL1KTUKkNM1KLRWAYzv((LiClO0KTUQzGB0XOjHGWlzn50DTWrO92tV3uGalbk2dxLq2VfuY3tN9WvrAVMKiS5tfBPj0Kg)yDd2qnfJe1Ji1JeMIzN6zOyEnjSLL6ggrQ1KtRXWLMqtAyOutoliXSkF)seUfuiXScp7MTquoliX0DTWrO92tV3uGalbk2dxLq2VfuY3tN9WvrApIYzbjOmKvfjgjBrcBOMIrcjMnibfZ(iKAQruIOCwqcvmtErZWriIYzbjMniHkUwJFSbjsGhjuryBWAY2hK2mRjNfKywLVFjc3ckKywHNDZwikNfKy6Uw4i0E7P3BkqGLaf7HRsi73ck57PZE4QiThr5SGeugYQIeJKTiHnutXiHeZgKGIzFesn1ikruoliHkMjVOz4ier5SGeZgKqfxRXp2GejWJeQiSnyeLikNfKqfVkWYWXgKGGtGNrcjqHWpKGGP3cIrIzLsj3EqKOa1SzYFLuiJeU8wqbrcqLvfJO0L3ckiU9zjqHWVHu2HuHO0L3ckiU9zjqHWVrhSpbageLU8wqbXTplbke(n6G9EGwHRZVfuikNfKGS8w4e4qI3xdsqesj2GeWZpisqWjWZiHeOq4hsqW0BbrcVmir7ZZMwWDBrJelejmGIXikD5TGcIBFwcui8B0b7HL3cNaxhE(bru6YBbfe3(SeOq43Od23cUfuikD5TGcIBFwcui8B0b7vyfWRAhK65GCnDZZUcerPlVfuqC7ZsGcHFJoyV)sV4(b(NRZ2nnyNZZCD4iNkUdsDhoXqmxorMnikruoliHkEvGLHJnibRMFvrIBvyK4MyKWLh4rIfIeUAFZorMXikD5TGco8mrGkgrPlVfuWrhSx65C3L3cQEEHNTLRWdsaiBarferPlVfuWrhSx65C3L3cQEEHNTLRWd0CXVFGhIOerPlVfuq89BrfFWHaK77Xk2wUcp8Us7w0DxPnVxWWD6L2vdYxNl6TyB30WyeHuc7Q5IEl6E073eo0AzresjS8dq3W4q74ikD5TGcIVFlQ4do6G9bi33JvSTCfEG(bfnS3(RIN7VtZ2UPb7qesjSRMl6TO7rVFt4qBC7qesjS8dq3W4qlIsxElOG473Ik(GJoyFaY99yfBlxHhEFeycfvWoXs3F20jc3bkeLU8wqbX3Vfv8bhDW(aK77Xk2wUcpOsg2Narz(TDtdeHuc7Q5IEl6E073eo0AzresjS8dq3W4qBCIqkHLFa6ggdpxs1afuJO0L3cki((TOIp4Od2hGCFpwX2Yv4b1RN7Gu3RvXp20jYaGX2nnmgriLWUAUO3IUh9(nHdTwweHucl)a0nmo0gNiKsy5hGUHXpR4BbJLcv04wwJjbGSbevyxnx0Br3JE)MWpR4BbBoh1wwsaiBarfw(bOBy8Zk(wWMZr94ikD5TGcIVFlQ4do6G9bi33JvSTCfEWaakWEk8QA7MgicPe2vZf9w09O3VjCO1YIiKsy5hGUHXH24eHucl)a0nm(zfFlySuOIqu6YBbfeF)wuXhC0b7dqUVhRyB5k8aTNzPNZ8d7eStLTBAGiKsyxnx0Br3JE)MWHwllIqkHLFa6gghAJtesjS8dq3W4Nv8TGXsXmikD5TGcIVFlQ4do6G9bi33JvSTCfEGqvAqXDcM7EwXlxA7MgicPe2vZf9w09O3VjCO1YIiKsy5hGUHXHweLU8wqbX3Vfv8bhDW(aK77Xk2wUcpOWpt1n5WEYlAB30Wy25910z1CDy3yGywfw4bTSEFnDwnxh2ngiERMumZ4wwWwoN7N)08bXMv9wChEGxP5GnikD5TGcIVFlQ4do6G9bi33JvSTCfEOnhkd)eS)gypLDiv2UPbIqkHD1CrVfDp69BchATSicPew(bOByCOnoriLWYpaDdJHNlPQ5afuBzjbGSbevyxnx0Br3JE)MWpR4BbBo)mww2HiKsy5hGUHXH24saiBarfw(bOBy8Zk(wWMZpdIsxElOG473Ik(GJoyFaY99yfBlxHhi4hYpv8d7QmOYGTBAGiKsyxnx0Br3JE)MWHwllIqkHLFa6gghAJtesjS8dq3Wy45sQAoqb1wwsaiBarf2vZf9w09O3Vj8Zk(wWMZpJLLDicPew(bOByCOnUeaYgquHLFa6gg)SIVfS58ZGO0L3cki((TOIp4Od2hGCFpwX2Yv4bUmzgc73wYl8ChK6P3L3ckp3Bbr8B7MgicPe2vZf9w09O3VjCO1YIiKsy5hGUHXH24eHucl)a0nmgEUKQMduqTLLeaYgquHD1CrVfDp69Bc)SIVfS58ZyzjbGSbevy5hGUHXpR4BbBo)mikD5TGcIVFlQ4do6G9bi33JvSTCfEOL9p3nRA(HDjqP1HqB30ariLWUAUO3IUh9(nHdTwweHucl)a0nmo0gNiKsy5hGUHXWZLu1CGcQru6YBbfeF)wuXhC0b7dqUVhRyB5k8qAF41v8JHDyRQ0zhcTDtdeHuc7Q5IEl6E073eo0AzresjS8dq3W4qBCIqkHLFa6gg)SIVfm2bkMbrPlVfuq89BrfFWrhSpa5(ESITLRWdrt7NJ2Ig2BZbfNMTDtdeHuc7Q5IEl6E073eo0AzresjS8dq3W4qBCIqkHLFa6gg)SIVfm2bBOgrPlVfuq89BrfFWrhSpa5(ESITLRWdMNDtNo7M1pWd7eUHMTDtdeHuc7Q5IEl6E073eo0AzresjS8dq3W4qBCIqkHLFa6gg)SIVfm2bBOgrPlVfuq89BrfFWrhSpa5(ESITLRWdMNDt3HT771b7kSXZ5fu2UPbIqkHD1CrVfDp69BchATSicPew(bOByCOnoriLWYpaDdJFwX3cg7GnuJO0L3cki((TOIp4Od2hGCFpwX2Yv4bQkW1bPUxYLRRNcVQ2UPbIqkHD1CrVfDp69BchATSicPew(bOByCOnoriLWYpaDdJHNlPQ5afuBzjbGSbevyxnx0Br3JE)MWpR4BbBoh1ww2HiKsy5hGUHXH24saiBarfw(bOBy8Zk(wWMZrnIsxElOG473Ik(GJoyFaY99yfOTBAGiKsyxnx0Br3JE)MWHwllIqkHLFa6gghAJtesjS8dq3Wy45sQgOGAeLikD5TGcILaq2aIk4G0Z5UlVfu98cpBlxHhUFlQ4dIO0L3ckiwcazdiQGJoyFl4wqz7MgicPeMidaMCaE4ND5zzresjSRMl6TO7rVFt4qRLfriLWYpaDdJdTXjcPew(bOBy8Zk(wWyTzgeLU8wqbXsaiBarfC0b7Zl90b7QmyOv46SDtdWwoN7N)08bX5LE6GDvgm0kCDnhSXYAm78(A6SAUoSBmqmRcl8GwwVVMoRMRd7gdeVvZrCMXru6YBbfelbGSbevWrhSpTptKbaJTBAGiKsyxnx0Br3JE)MWHwllIqkHLFa6gghAJtesjS8dq3Wy45sQgOGAeLU8wqbXsaiBarfC0b7HtlNnDqQRMlA2ljB7MgicPegY8nTfD)DAgBarvCIqkHvyfWRAhK65GCnDZZUceBarfIsxElOGyjaKnGOco6G93e3dfbiuMEc8s22nnCRch7GnwweHuc)SKQmdH9e4Lmo0IO0L3ckiwcazdiQGJoyprgamDqQFtCNlwrvB30ariLWUAUO3IUh9(nHdTwweHucl)a0nmo0gNiKsy5hGUHXWZLunqb1ikD5TGcILaq2aIk4Od2th83SE1bPUpc4hCt2UPb7CEMRdl)a0nmMlNiZM4JjbGSbevyxnx0Br3JE)MWpR4BbJLwAIpbYQ2Bbr83CyolljaKnGOc7Q5IEl6E073e(zfFlyZH5NzClRXopZ1HLFa6ggZLtKztCjaKnGOcl)a0nm(zfFlyS0st8jqw1EliI)MdZBzjbGSbevy5hGUHXpR4BbBom)mJJO0L3ckiwcazdiQGJoyFe4Zg18w9NHGYljB7MgKaq2aIkSRMl6TO7rVFt4Nv8TGXslnXNazv7TGi(BomNLLeaYgquHLFa6gg)SIVfmwAPj(eiRAVfeXFZH5TSKaq2aIkSRMl6TO7rVFt4Nv8TGnhMFglljaKnGOcl)a0nm(zfFlyZH5NbrPlVfuqSeaYgqubhDW(eqgGSP7Ja(3J7eSRy7MggZoVVMoRMRd7gdeZQWcpOL17RPZQ56WUXaXB1CoQTSGTCo3p)P5dInR6T4o8aVsZbBgp(yeHuc7Q5IEl6E073e2aIkllIqkHLFa6ggBar14XhtcazdiQWez3WDqQRYa8wjJFwX3c2KwAS7CXLaq2aIkSkdgAfUo8Zk(wWM0sJDNBCeLU8wqbXsaiBarfC0b7vyfWRAhK65GCnDZZUc02nnmgriLWUAUO3IUh9(nHdTwweHucl)a0nmo0gNiKsy5hGUHXWZLunqb1JhFcKvT3cI4p2H5qu6YBbfelbGSbevWrhSVn8Bs1TO7ezhE2UPHXSZ7RPZQ56WUXaXSkSWdAz9(A6SAUoSBmq8wnNJAllylNZ9ZFA(GyZQElUdpWR0CWMXru6YBbfelbGSbevWrhS3vZf9w09O3VjB30ariLWBnYHfU3ckCO1YYoNN56WBnYHfU3ckmxorMnikD5TGcILaq2aIk4Od2l)a0nSTBAycKvT3cI4V5W8ikru6YBbfeN2AHt8dhu7)6ez22Yv4bdSlD45ez2w1EoWdWwoN7N)08bXMv9wChEGxP5GnXTZ5zUo8V0thdcWUA(nR8WC5ez2yzbB5CUF(tZheBw1BXD4bELMdZf)8mxh(x6PJbbyxn)MvEyUCImBqu6YBbfeN2AHt8dhDW(Tg5Wc3BbLTBAGiKs4Tg5Wc3Bbf2aIkllIqkH3AKdlCVfu4Nv8TGXot8jqw1EliI)MdZzzDEMRdZQald3cQoKRJljJ5YjYSjUeaYgquHzvGLHBbvhY1XLKXpR4BbJLcQJtesj8wJCyH7TGc)SIVfmwkMXYscazdiQWUAUO3IUh9(nHFwX3cglfZeNiKs4Tg5Wc3Bbf(zfFlyS2qD8jqw1EliI)MdZHO0L3ckioT1cN4ho6G9SkWYWTGQd564sY2UPbylNZ9ZFA(GyZQElUdpWRe7GnXhZoNN56WYpaDdJ5YjYSjUeaYgquHD1CrVfDp69Bc)SIVfSjfuBzDEMRdl)a0nmMlNiZM4eHucl)a0nm2aIQ4saiBarfw(bOBy8Zk(wWMuqTLfriLWYpaDdJHNlPQ5WiooIsxElOG40wlCIF4Od2Bw1BXD4bEfB30GA)xNiZydSlD45ezo(y258mxhw(bOBymxorMnwwsaiBarfw(bOBy8Zk(wWM0sJDTzCllIqkHzLwvF2REliIFCOnUHjcPewLbdTcxh2aIQ4eHucBw1BX92W3cGm2aIkeLU8wqbXPTw4e)WrhS)yL2S)WUA(nR8SDtdJzNZZCDy5hGUHXC5ez2excazdiQWUAUO3IUh9(nHFwX3c2KwAS7CwwsaiBarfw(bOBy8Zk(wWM0sJDNB84JzNZZCDywfyz4wq1HCDCjzmxorMnwwsaiBarfMvbwgUfuDixhxsg)SIVfSjT0yxBSSKaq2aIkSRMl6TO7rVFt4Nv8TGnPLg7oxCjaKnGOc7Q5IEl6E073e(zfFlySuqTLfriLWYpaDdJdTXjcPew(bOBym8CjvXsb1JJOerPlVfuqmnx87h4HdQ9FDImBB5k8WSfmRTvTNd8Wy258mxhEYvu4Vds9O3VjmxorMnwwN)08HNypFt4w51CWgQJpgriLWUAUO3IUh9(nHnGOYYIiKsy5hGUHXgqun(4ikD5TGcIP5IF)apC0b7LEo3D5TGQNx4zB5k8qARfoXp02nnmbYQ2Bbr83CygllIqkHvyfWRAhK65GCnDZZUcehATSicPegY8nTfD)DAghAru6YBbfetZf)(bE4Od2h5uXDqQ7WjgA7MggZoVVMoRMRd7gdeZQWcpOL17RPZQ56WUXaXB1KIzSSGTCo3p)P5dIJCQ4oi1D4edBoyZ4XhBcKvT3cI4p2bQTSMazv7TGi(hOiUeaYgquHjYUH7GuxLb4Tsg)SIVfSjT0mE8XKaq2aIkSRMl6TO7rVFt4Nv8TGnPGAlRZZCDy5hGUHXC5ez2excazdiQWYpaDdJFwX3c2KcQhhrPlVfuqmnx87h4HJoypr2nChK6QmaVvY2UPHjqw1EliI)yhSXYASjqw1EliI)H5IpMeaYgquHNCff(7Gup69Bc)SIVfSjT0yxBSSu7)6ezgpBbZ6XhhrPlVfuqmnx87h4HJoyVkdgAfUoB30WeiRAVfeXFSd2yzn2eiRAVfeXFSdZhFmjaKnGOctKDd3bPUkdWBLm(zfFlytAPXU2yzP2)1jYmE2cM1JpoIsxElOGyAU43pWdhDW(jxrH)oi1JE)MSDtdtGSQ9wqe)XompIsxElOGyAU43pWdhDWEjOGS89BbLTBAycKvT3cI4p2bBSSMazv7TGi(JDyU4saiBarfMi7gUdsDvgG3kz8Zk(wWM0sJDTXYAcKvT3cI4Fy(4saiBarfMi7gUdsDvgG3kz8Zk(wWM0sJDTjUeaYgquHvzWqRW1HFwX3c2KwASRnikD5TGcIP5IF)apC0b7LEo3D5TGQNx4zB5k8qARfoXp02nnCEMRdp5kk83bPE073eMlNiZM4JD(tZhEI98nHBLxSd2qTLfriLWUAUO3IUh9(nHdTwweHucl)a0nmo0ooIsxElOGyAU43pWdhDWE5hGUH)o8(Lk22nnibGSbevy5hGUH)o8(LkglN8NMH907YBbLNBoqbEeNj(ytGSQ9wqe)XoyJL1eiRAVfeXFSdZfxcazdiQWez3WDqQRYa8wjJFwX3c2KwASRnwwtGSQ9wqe)dZhxcazdiQWez3WDqQRYa8wjJFwX3c2KwASRnXLaq2aIkSkdgAfUo8Zk(wWM0sJDTjUeaYgquHLGcYY3Vfu4Nv8TGnPLg7AZ4ikD5TGcIP5IF)apC0b7LEo3D5TGQNx4zB5k8qARfoXperPlVfuqmnx87h4HJoyVeusUU3p20tzxHru6YBbfetZf)(bE4Od2l)a0n83H3VuX2UPHjqw1EliI)yhMhrPlVfuqmnx87h4HJoyV)sV4(b(NRZ2nnmbYQ2Bbr8h7W8As18dxqPBWgQPyKOE2TzEmfup)iPjJ8V2IgQjvXQ0c(JniXSJeU8wqHe5fEqmIsnPhUjWRjjxfvmAY8cpOognPHtEiF6y0nqHognPlVfuAYNjcuXAsUCImB0nQpDd2OJrtYLtKzJUrnPlVfuAsPNZDxElO65fEAY8cVE5kSMucazdiQG6t3WC6y0KC5ez2OBut6YBbLMu65C3L3cQEEHNMmVWRxUcRjP5IF)apuF6tt2(SeOq4NogDduOJrtYLtKzJUr9PBWgDmAsUCImB0nQpDdZPJrtYLtKzJUr9PByEDmAsUCImB0nQpDdZOJrt6YBbLMSfClO0KC5ez2OBuF6gMDDmAsxElO0KkSc4vTds9CqUMU5zxbQj5YjYSr3O(0nmI6y0KC5ez2OButk)94FDnPDqIZZCD4iNkUdsDhoXqmxorMnAsxElO0K(l9I7h4FUo9PpnPeaYgqub1XOBGcDmAsUCImB0nQjD5TGstk9CU7YBbvpVWttMx41lxH1K3Vfv8b1NUbB0XOj5YjYSr3OMu(7X)6AsIqkHjYaGjhGh(zxEiHLfsqesjSRMl6TO7rVFt4qlsyzHeeHucl)a0nmo0IeXrcIqkHLFa6gg)SIVfejIfjSzgnPlVfuAYwWTGsF6gMthJMKlNiZgDJAs5Vh)RRjHTCo3p)P5dIZl90b7QmyOv46qIMdiHniHLfsmgsyhK4910z1CDy3yGywfw4brcllK4910z1CDy3yG4TqIMiXiodsmUM0L3cknzEPNoyxLbdTcxN(0nmVognjxorMn6g1KYFp(xxtsesjSRMl6TO7rVFt4qlsyzHeeHucl)a0nmo0IeXrcIqkHLFa6ggdpxsfsmGeuqTM0L3cknzAFMidag9PBygDmAsUCImB0nQjL)E8VUMKiKsyiZ30w093PzSbevirCKGiKsyfwb8Q2bPEoixt38SRaXgquPjD5TGstcNwoB6Guxnx0SxswF6gMDDmAsUCImB0nQjL)E8VUM8wfgjIDajSbjSSqcIqkHFwsvMHWEc8sghA1KU8wqPjVjUhkcqOm9e4LS(0nmI6y0KC5ez2OButk)94FDnjriLWUAUO3IUh9(nHdTiHLfsqesjS8dq3W4qlsehjicPew(bOBym8CjviXasqb1AsxElO0KezaW0bP(nXDUyfv1NUbvKognjxorMn6g1KYFp(xxtAhK48mxhw(bOBymxorMnirCKymKqcazdiQWUAUO3IUh9(nHFwX3cIeXIe0sdsehjMazv7TGi(rIMdiXCiHLfsibGSbevyxnx0Br3JE)MWpR4BbrIMdiX8ZGeJJewwiXyiX5zUoS8dq3WyUCImBqI4iHeaYgquHLFa6gg)SIVfejIfjOLgKiosmbYQ2Bbr8JenhqI5rcllKqcazdiQWYpaDdJFwX3cIenhqI5Nbjgxt6YBbLMKo4Vz9QdsDFeWp4M0NUHrshJMKlNiZgDJAs5Vh)RRjLaq2aIkSRMl6TO7rVFt4Nv8TGirSibT0GeXrIjqw1EliIFKO5asmhsyzHesaiBarfw(bOBy8Zk(wqKiwKGwAqI4iXeiRAVfeXps0CajMhjSSqcjaKnGOc7Q5IEl6E073e(zfFlis0CajMFgKWYcjKaq2aIkS8dq3W4Nv8TGirZbKy(z0KU8wqPjJaF2OM3Q)meuEjz9PBGcQ1XOj5YjYSr3OMu(7X)6AYXqc7GeVVMoRMRd7gdeZQWcpisyzHeVVMoRMRd7gdeVfs0ejMJAKWYcjGTCo3p)P5dInR6T4o8aVcs0CajSbjghjIJeJHeeHuc7Q5IEl6E073e2aIkKWYcjicPew(bOBySbeviX4irCKymKqcazdiQWez3WDqQRYa8wjJFwX3cIenrcAPbjSlsmhsehjKaq2aIkSkdgAfUo8Zk(wqKOjsqlniHDrI5qIX1KU8wqPjtazaYMUpc4FpUtWUI(0nqbf6y0KC5ez2OButk)94FDn5yibriLWUAUO3IUh9(nHdTiHLfsqesjS8dq3W4qlsehjicPew(bOBym8CjviXasqb1iX4irCKycKvT3cI4hjIDajMtt6YBbLMuHvaVQDqQNdY10np7kq9PBGcB0XOj5YjYSr3OMu(7X)6AYXqc7GeVVMoRMRd7gdeZQWcpisyzHeVVMoRMRd7gdeVfs0ejMJAKWYcjGTCo3p)P5dInR6T4o8aVcs0CajSbjgxt6YBbLMSn8Bs1TO7ezhE6t3afZPJrtYLtKzJUrnP83J)11KeHucV1ihw4ElOWHwKWYcjSdsCEMRdV1ihw4ElOWC5ez2OjD5TGst6Q5IEl6E073K(0nqX86y0KC5ez2OButk)94FDn5eiRAVfeXps0CajMxt6YBbLMu(bOBy9Ppn59BrfFqDm6gOqhJMKlNiZgDJAsxElO0KVR0UfD3vAZ7fmCNEPD1G815IElwtk)94FDn5yibriLWUAUO3IUh9(nHdTiHLfsqesjS8dq3W4qlsmUMSCfwt(Us7w0DxPnVxWWD6L2vdYxNl6Ty9PBWgDmAsUCImB0nQjD5TGsts)GIg2B)vXZ93PznP83J)11K2bjicPe2vZf9w09O3VjCOfjIJe2bjicPew(bOByCOvtwUcRjPFqrd7T)Q45(70S(0nmNognjxorMn6g1KLRWAY3hbMqrfStS09NnDIWDGst6YBbLM89rGjuub7elD)ztNiChO0NUH51XOj5YjYSr3OM0L3cknPkzyFceL5xtk)94FDnjriLWUAUO3IUh9(nHdTiHLfsqesjS8dq3W4qlsehjicPew(bOBym8CjviXasqb1AYYvynPkzyFceL5xF6gMrhJMKlNiZgDJAsxElO0KQxp3bPUxRIFSPtKbaJMu(7X)6AYXqcIqkHD1CrVfDp69BchArcllKGiKsy5hGUHXHwKiosqesjS8dq3W4Nv8TGirSibfQiKyCKWYcjgdjKaq2aIkSRMl6TO7rVFt4Nv8TGirtKyoQrcllKqcazdiQWYpaDdJFwX3cIenrI5OgjgxtwUcRjvVEUdsDVwf)ytNidag9PBy21XOj5YjYSr3OM0L3cknPbauG9u4vvtk)94FDnjriLWUAUO3IUh9(nHdTiHLfsqesjS8dq3W4qlsehjicPew(bOBy8Zk(wqKiwKGcvKMSCfwtAaafypfEv1NUHruhJMKlNiZgDJAsxElO0K0EMLEoZpStWovAs5Vh)RRjjcPe2vZf9w09O3VjCOfjSSqcIqkHLFa6gghArI4ibriLWYpaDdJFwX3cIeXIeumJMSCfwts7zw65m)Wob7uPpDdQiDmAsUCImB0nQjD5TGstsOknO4obZDpR4Ll1KYFp(xxtsesjSRMl6TO7rVFt4qlsyzHeeHucl)a0nmo0QjlxH1KeQsdkUtWC3ZkE5s9PByK0XOj5YjYSr3OM0L3cknPc)mv3Kd7jVO1KYFp(xxtogsyhK4910z1CDy3yGywfw4brcllK4910z1CDy3yG4TqIMibfZGeJJewwibSLZ5(5pnFqSzvVf3Hh4vqIMdiHnAYYvynPc)mv3Kd7jVO1NUbkOwhJMKlNiZgDJAsxElO0KT5qz4NG93a7PSdPstk)94FDnjriLWUAUO3IUh9(nHdTiHLfsqesjS8dq3W4qlsehjicPew(bOBym8CjvirZbKGcQrcllKqcazdiQWUAUO3IUh9(nHFwX3cIenrI5NbjSSqc7GeeHucl)a0nmo0IeXrcjaKnGOcl)a0nm(zfFlis0ejMFgnz5kSMSnhkd)eS)gypLDiv6t3afuOJrtYLtKzJUrnPlVfuAsc(H8tf)WUkdQmOjL)E8VUMKiKsyxnx0Br3JE)MWHwKWYcjicPew(bOByCOfjIJeeHucl)a0nmgEUKkKO5asqb1iHLfsibGSbevyxnx0Br3JE)MWpR4BbrIMiX8ZGewwiHDqcIqkHLFa6gghArI4iHeaYgquHLFa6gg)SIVfejAIeZpJMSCfwtsWpKFQ4h2vzqLb9PBGcB0XOj5YjYSr3OM0L3cknjxMmdH9Bl5fEUds907YBbLN7TGi(1KYFp(xxtsesjSRMl6TO7rVFt4qlsyzHeeHucl)a0nmo0IeXrcIqkHLFa6ggdpxsfs0CajOGAKWYcjKaq2aIkSRMl6TO7rVFt4Nv8TGirtKy(zqcllKqcazdiQWYpaDdJFwX3cIenrI5NrtwUcRj5YKziSFBjVWZDqQNExElO8CVfeXV(0nqXC6y0KC5ez2OBut6YBbLMSL9p3nRA(HDjqP1HqnP83J)11KeHuc7Q5IEl6E073eo0IewwibriLWYpaDdJdTirCKGiKsy5hGUHXWZLuHenhqckOwtwUcRjBz)ZDZQMFyxcuADiuF6gOyEDmAsUCImB0nQjD5TGstM2hEDf)yyh2QkD2HqnP83J)11KeHuc7Q5IEl6E073eo0IewwibriLWYpaDdJdTirCKGiKsy5hGUHXpR4BbrIyhqckMrtwUcRjt7dVUIFmSdBvLo7qO(0nqXm6y0KC5ez2OBut6YBbLMmAA)C0w0WEBoO40SMu(7X)6AsIqkHD1CrVfDp69BchArcllKGiKsy5hGUHXHwKiosqesjS8dq3W4Nv8TGirSdiHnuRjlxH1Krt7NJ2Ig2BZbfNM1NUbkMDDmAsUCImB0nQjD5TGstAE2nD6SBw)apSt4gAwtk)94FDnjriLWUAUO3IUh9(nHdTiHLfsqesjS8dq3W4qlsehjicPew(bOBy8Zk(wqKi2bKWgQ1KLRWAsZZUPtNDZ6h4HDc3qZ6t3afJOognjxorMn6g1KU8wqPjnp7MUdB33Rd2vyJNZlO0KYFp(xxtsesjSRMl6TO7rVFt4qlsyzHeeHucl)a0nmo0IeXrcIqkHLFa6gg)SIVfejIDajSHAnz5kSM08SB6oSDFVoyxHnEoVGsF6gOqfPJrtYLtKzJUrnPlVfuAsQkW1bPUxYLRRNcVQAs5Vh)RRjjcPe2vZf9w09O3VjCOfjSSqcIqkHLFa6gghArI4ibriLWYpaDdJHNlPcjAoGeuqnsyzHesaiBarf2vZf9w09O3Vj8Zk(wqKOjsmh1iHLfsyhKGiKsy5hGUHXHwKiosibGSbevy5hGUHXpR4BbrIMiXCuRjlxH1KuvGRdsDVKlxxpfEv1NUbkgjDmAsUCImB0nQjL)E8VUMKiKsyxnx0Br3JE)MWHwKWYcjicPew(bOByCOfjIJeeHucl)a0nmgEUKkKyajOGAnPlVfuAYaK77Xkq9Ppnjnx87h4H6y0nqHognjxorMn6g1KGwnjKpnPlVfuAs1(VorM1KQ9CG1KJHe2bjopZ1HNCff(7Gup69BcZLtKzdsyzHeN)08HNypFt4w5HenhqcBOgjIJeJHeeHuc7Q5IEl6E073e2aIkKWYcjicPew(bOBySbeviX4iX4As1(3lxH1KZwWSwF6gSrhJMKlNiZgDJAs5Vh)RRjNazv7TGi(rIMdiXmiHLfsqesjScRaEv7GuphKRPBE2vG4qlsyzHeeHucdz(M2IU)onJdTAsxElO0KspN7U8wq1Zl80K5fE9YvynzARfoXpuF6gMthJMKlNiZgDJAs5Vh)RRjhdjSds8(A6SAUoSBmqmRcl8GiHLfs8(A6SAUoSBmq8wirtKGIzqcllKa2Y5C)8NMpioYPI7Gu3HtmejAoGe2GeJJeXrIXqIjqw1EliIFKi2bKGAKWYcjMazv7TGi(rIbKGcKiosibGSbevyISB4oi1vzaERKXpR4BbrIMibT0GeJJeXrIXqcjaKnGOc7Q5IEl6E073e(zfFlis0ejOGAKWYcjopZ1HLFa6ggZLtKzdsehjKaq2aIkS8dq3W4Nv8TGirtKGcQrIX1KU8wqPjJCQ4oi1D4ed1NUH51XOj5YjYSr3OMu(7X)6AYjqw1EliIFKi2bKWgKWYcjgdjMazv7TGi(rIbKyoKiosmgsibGSbev4jxrH)oi1JE)MWpR4BbrIMibT0Ge2fjSbjSSqc1(VorMXZwWSgjghjgxt6YBbLMKi7gUdsDvgG3kz9PBygDmAsUCImB0nQjL)E8VUMCcKvT3cI4hjIDajSbjSSqIXqIjqw1EliIFKi2bKyEKiosmgsibGSbevyISB4oi1vzaERKXpR4BbrIMibT0Ge2fjSbjSSqc1(VorMXZwWSgjghjgxt6YBbLMuLbdTcxN(0nm76y0KC5ez2OButk)94FDn5eiRAVfeXpse7asmVM0L3ckn5KROWFhK6rVFt6t3WiQJrtYLtKzJUrnP83J)11KtGSQ9wqe)irSdiHniHLfsmbYQ2Bbr8JeXoGeZHeXrcjaKnGOctKDd3bPUkdWBLm(zfFlis0ejOLgKWUiHniHLfsmbYQ2Bbr8JediX8irCKqcazdiQWez3WDqQRYa8wjJFwX3cIenrcAPbjSlsydsehjKaq2aIkSkdgAfUo8Zk(wqKOjsqlniHDrcB0KU8wqPjLGcYY3Vfu6t3GkshJMKlNiZgDJAs5Vh)RRjppZ1HNCff(7Gup69BcZLtKzdsehjgdjo)P5dpXE(MWTYdjIDajSHAKWYcjicPe2vZf9w09O3VjCOfjSSqcIqkHLFa6gghArIX1KU8wqPjLEo3D5TGQNx4PjZl86LRWAY0wlCIFO(0nms6y0KC5ez2OButk)94FDnPeaYgquHLFa6g(7W7xQySCYFAg2tVlVfuEgjAoGeuGhXzqI4iXyiXeiRAVfeXpse7asydsyzHetGSQ9wqe)irSdiXCirCKqcazdiQWez3WDqQRYa8wjJFwX3cIenrcAPbjSlsydsyzHetGSQ9wqe)iXasmpsehjKaq2aIkmr2nChK6QmaVvY4Nv8TGirtKGwAqc7Ie2GeXrcjaKnGOcRYGHwHRd)SIVfejAIe0sdsyxKWgKiosibGSbevyjOGS89Bbf(zfFlis0ejOLgKWUiHniX4AsxElO0KYpaDd)D49lvS(0nqb16y0KC5ez2OBut6YBbLMu65C3L3cQEEHNMmVWRxUcRjtBTWj(H6t3afuOJrt6YBbLMuckjx37hB6PSRWAsUCImB0nQpDduyJognjxorMn6g1KYFp(xxtobYQ2Bbr8JeXoGeZRjD5TGstk)a0n83H3VuX6t3afZPJrtYLtKzJUrnP83J)11KtGSQ9wqe)irSdiX8AsxElO0K(l9I7h4FUo9PpnzARfoXpuhJUbk0XOj5YjYSr3OMe0QjH8PjD5TGstQ2)1jYSMuTNdSMe2Y5C)8NMpi2SQ3I7Wd8kirZbKWgKiosyhK48mxh(x6PJbbyxn)MvEyUCImBqcllKa2Y5C)8NMpi2SQ3I7Wd8kirZbKyoKiosCEMRd)l90XGaSRMFZkpmxorMnAs1(3lxH1Kgyx6WZjYS(0nyJognjxorMn6g1KYFp(xxtsesj8wJCyH7TGcBarfsyzHeeHucV1ihw4ElOWpR4BbrIyrIzqI4iXeiRAVfeXps0CajMdjSSqIZZCDywfyz4wq1HCDCjzmxorMnirCKqcazdiQWSkWYWTGQd564sY4Nv8TGirSibfuJeXrcIqkH3AKdlCVfu4Nv8TGirSibfZGewwiHeaYgquHD1CrVfDp69Bc)SIVfejIfjOygKiosqesj8wJCyH7TGc)SIVfejIfjSHAKiosmbYQ2Bbr8JenhqI50KU8wqPj3AKdlCVfu6t3WC6y0KC5ez2OButk)94FDnjSLZ5(5pnFqSzvVf3Hh4vqIyhqcBqI4iXyiHDqIZZCDy5hGUHXC5ez2GeXrcjaKnGOc7Q5IEl6E073e(zfFlis0ejOGAKWYcjopZ1HLFa6ggZLtKzdsehjicPew(bOBySbevirCKqcazdiQWYpaDdJFwX3cIenrckOgjSSqcIqkHLFa6ggdpxsfs0CajgrKyCnPlVfuAswfyz4wq1HCDCjz9PByEDmAsUCImB0nQjL)E8VUMuT)RtKzSb2Lo8CImJeXrIXqc7GeNN56WYpaDdJ5YjYSbjSSqcjaKnGOcl)a0nm(zfFlis0ejOLgKWUiHniX4iHLfsqesjmR0Q6ZE1Bbr8JdTirCKWWeHucRYGHwHRdBarfsehjicPe2SQ3I7THVfazSbevAsxElO0KMv9wChEGxrF6gMrhJMKlNiZgDJAs5Vh)RRjhdjSdsCEMRdl)a0nmMlNiZgKiosibGSbevyxnx0Br3JE)MWpR4BbrIMibT0Ge2fjMdjSSqcjaKnGOcl)a0nm(zfFlis0ejOLgKWUiXCiX4irCKymKWoiX5zUomRcSmClO6qUoUKmMlNiZgKWYcjKaq2aIkmRcSmClO6qUoUKm(zfFlis0ejOLgKWUiHniHLfsibGSbevyxnx0Br3JE)MWpR4BbrIMibT0Ge2fjMdjIJesaiBarf2vZf9w09O3Vj8Zk(wqKiwKGcQrcllKGiKsy5hGUHXHwKiosqesjS8dq3Wy45sQqIyrckOgjgxt6YBbLM8yL2S)WUA(nR80N(0N(0Nwd]] )


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
