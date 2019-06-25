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

        avenging_wrath_crit = ns.PTR and {
            id = 294027,
            duration = 20,
            max_stack = 1
        } or nil,

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


    spec:RegisterPack( "Retribution", 20190624.1049, [[dGu7hbqikv8ifvPnjQ6tcvPmkfvoLIsRIsLELcPzrk6wcvv2fIFrPyyuQ6yiHLHK6zkkMMcvxtHY2eQs(MIQQXrkOohPGSoHQO5ju6EkyFIkhuOkKfQq8qfvLCrHQq9rfvLYivuvCsfvrTsKKzQOQuTtHkdvOkvlvOk4PqzQcfxvrvKVkuv1Ej5VszWOCyQwmu9yunzkUmXMf5Zi1OvKtR0Qjf61irZwQUnLSBj)wvdxuoUqvz5aph00v56c2oP03fY4jf48ukTEfvH5tQ2pKvuOIrHz8tuXrT9uOHSpEr9yekSFMzOGAf2zBMOWYCoLoTOWk3suyXdYbw8WTFPWYCB7VBuXOWGFaWff20DzW4Pn2qV3uaNWFlBGRvO73(fh4PZg4AXTbV)42GN84Nr0Atg4tBxG2eZkaQPWMyOMIw8U3DZwT4b5alE42ViW1IRWWdB)MNlfUcZ4NOIJA7PqdzF8I6XjuqH9JtX4kmyMWvXn)2RWMwJrkfUcZiqUcBErS4b5alE42VqS4DV7MTqunVi20DzW4Pn2qV3uaNWFlBGRvO73(fh4PZg4AXTbr18IyufkbXOECnrmQTNcneIf)qmkSpEoUgcrfIQ5fXMVM8IwGXtevZlIf)qS5PmJFIbXspaX0WeQjkSmWN2UOWMxelEqoWIhU9lelE37UzlevZlInDxgmEAJn07nfWj83Yg4Af6(TFXbE6SbUwCBqunVigvHsqmQhxteJA7PqdHyXpeJc7JNJRHquHOAErS5RjVOfy8er18IyXpeBEkZ4NyqS0dqmnmHAcIkevZlIfpwdeE4edIHlPhiig)TW9dXWf6TGeelEeNlzheXQVIFtoWkf6iMZV9liI9v3wcIkNF7xqsgq4VfUFdPUdPerLZV9lijdi83c3VrhSj9VbrLZV9lijdi83c3VrhSXd0wsD(TFHOAErmSYZGt)HyaFnigEiLedIbp)GigUKEGGy83c3pedxO3cIyEzqSmGe)Y(72IgXwiIz(siiQC(TFbjzaH)w4(n6GnWYZGt)1GNFqevo)2VGKmGWFlC)gDWMS)2Vqu58B)csYac)TW9B0bBCa3lPDpai1P5MgSZ5DPosKtP0(uZHtcKiLJ3fdIkevZlIfpwdeE4edIjAfGTi2TwcIDtcI587bi2crmxRVDhVleevo)2VGdE4(MFNZPerLZV9l4Od2ae8aLcIkNF7xWrhSH79EZ53(vRVWtZYTKb()DZhvqevo)2VGJoyd379MZV9RwFHNMLBjd0sja)EaerfIkNF7xqYb2Is5GdbO02tS0SClza4wzBr3CRS(EbJ0OxAx73VMu0BjAUPH5WdPeX1kf9w0TiGFtKqMUoEiLiCqa6gHeYMfrLZV9li5aBrPCWrhSjaL2EILMLBjd0GVOHTmWA59gWPfn30GDWdPeX1kf9w0TiGFtKqwE7GhsjcheGUriHmevo)2VGKdSfLYbhDWMauA7jwAwULma85HjuucB4lDdiMgE4UVqu58B)csoWwukhC0bBcqPTNyPz5wYGgfyB6J6cqZnnGhsjIRvk6TOBra)MiHmDD8qkr4Ga0ncjKLhpKseoiaDJqGNZPCGc7ru58B)csoWwukhC0bBcqPTNyPz5wYG217Tp18AT8tmn8()gn30WC4HuI4ALIEl6weWVjsitxhpKseoiaDJqcz5XdPeHdcq3ieGy5BbJLcn8S66ZX)VB(OI4ALIEl6weWVjcqS8TG5MXEDD()DZhveoiaDJqaILVfm3m2plIkNF7xqYb2Is5GJoytakT9elnl3sgm)BbBPaWwn30aEiLiUwPO3IUfb8BIeY01XdPeHdcq3iKqwE8qkr4Ga0ncbiw(wWyPqdJOY53(fKCGTOuo4Od2eGsBpXsZYTKbAVlCV3faSHloLAUPb8qkrCTsrVfDlc43ejKPRJhsjcheGUriHS84HuIWbbOBecqS8TGXsXyiQC(TFbjhylkLdo6GnbO02tS0SClza3w6VKgUinVB5LZ1Ctd4HuI4ALIEl6weWVjsitxhpKseoiaDJqcziQC(TFbjhylkLdo6GnbO02tS0SClzWsacL3KdBjVO1CtdZzhGVMMOvQJ4gdKiAWcpOUoWxtt0k1rCJbs2khfJnRUomt6925aA5GeZQDlPbVhyLBGAevo)2VGKdSfLYbhDWMauA7jwAwULmK1dLra4IdmWwQ7qk1Ctd4HuI4ALIEl6weWVjsitxhpKseoiaDJqcz5XdPeHdcq3ie45CkZnqH9668)7MpQiUwPO3IUfb8BIaelFlyUXhtx3o4HuIWbbOBesilp))U5JkcheGUriaXY3cMB8Xqu58B)csoWwukhC0bBcqPTNyPz5wYaUaGcGsbaBAmOXGMBAapKsexRu0Br3Ia(nrcz664HuIWbbOBesilpEiLiCqa6gHapNtzUbkSxxN)F38rfX1kf9w0TiGFteGy5BbZn(y662bpKseoiaDJqcz55)3nFur4Ga0ncbiw(wWCJpgIkNF7xqYb2Is5GJoytakT9elnl3sgKY0fiSDBXVaqAFQLao)2V8El7JeGMBAapKsexRu0Br3Ia(nrcz664HuIWbbOBesilpEiLiCqa6gHapNtzUbkSxxN)F38rfX1kf9w0TiGFteGy5BbZn(y668)7MpQiCqa6gHaelFlyUXhdrLZV9li5aBrPCWrhSjaL2EILMLBjdzId6nZQvaWg)TYCiuZnnGhsjIRvk6TOBra)MiHmDD8qkr4Ga0ncjKLhpKseoiaDJqGNZPm3af2JOY53(fKCGTOuo4Od2eGsBpXsZYTKH0cGxZYpb2Gz2s3DiuZnnGhsjIRvk6TOBra)MiHmDD8qkr4Ga0ncjKLhpKseoiaDJqaILVfm2bkgdrLZV9li5aBrPCWrhSjaL2EILMLBjdrtlOhTfnSL1dwoTO5MgWdPeX1kf9w0TiGFtKqMUoEiLiCqa6gHeYYJhsjcheGUriaXY3cg7a12JOY53(fKCGTOuo4Od2eGsBpXsZYTKbdqCtJU7M1VhaB4UHw0Ctd4HuI4ALIEl6weWVjsitxhpKseoiaDJqcz5XdPeHdcq3ieGy5BbJDGA7ru58B)csoWwukhC0bBcqPTNyPz5wYGbiUP5WSf41bBwIX799ln30aEiLiUwPO3IUfb8BIeY01XdPeHdcq3iKqwE8qkr4Ga0ncbiw(wWyhO2Eevo)2VGKdSfLYbhDWMauA7jwAwULmqz9x7tnV4Ruxlfa2Q5MgWdPeX1kf9w0TiGFtKqMUoEiLiCqa6gHeYYJhsjcheGUriWZ5uMBGc7115)3nFurCTsrVfDlc43ebiw(wWCZyVUUDWdPeHdcq3iKqwE()DZhveoiaDJqaILVfm3m2JOY53(fKCGTOuo4Od2eGsBpXcQ5MgWdPeX1kf9w0TiGFtKqMUoEiLiCqa6gHeYYJhsjcheGUriWZ5uoqH9iQqu58B)cs4)3nFubhDWMS)2V0Ctd4HuIG3)30dWJaeNF664HuI4ALIEl6weWVjsitxhpKseoiaDJqcz5XdPeHdcq3ieGy5BbJL6Xqu58B)cs4)3nFubhDWM(spDWMgdgAlPon30amt6925aA5GK(spDWMgdgAlPUCduRRpNDa(AAIwPoIBmqIObl8G66aFnnrRuhXngizRCZ)yZIOY53(fKW)VB(Oco6GnPfi49)nAUPb8qkrCTsrVfDlc43ejKPRJhsjcheGUriHS84HuIWbbOBec8CoLduypIkNF7xqc))U5Jk4Od2aNwPBAFQPvkAXlUO5MgWdPebkYnTfDd40cX8rfIkNF7xqc))U5Jk4Od2Ctslu4FOmT0d4IMBA4wlj2bQ11XdPebiCk7ce2spGlKqgIkNF7xqc))U5Jk4Od2G3)30(u7MKMuILTAUPb8qkrCTsrVfDlc43ejKPRJhsjcheGUriHS84HuIWbbOBec8CoLduypIkNF7xqc))U5Jk4Od2qhCGz9Q9PMppeWFtAUPb()DZhvexRu0Br3Ia(nraILVfmwAUj)03TTL9rci3Wm668)7MpQiCqa6gHaelFlyS0Ct(PVBBl7JeqUHX115)3nFurCTsrVfDlc43ebiw(wWCdJpMUo))U5JkcheGUriaXY3cMBy8Xqu58B)cs4)3nFubhDWMOh0nALTAab(LxCrZnnW)VB(OI4ALIEl6weWVjcqS8TGXsZn5N(UTTSpsa5gMrxN)F38rfHdcq3ieGy5BbJLMBYp9DBBzFKaYnmUUo))U5JkIRvk6TOBra)MiaXY3cMBy8X015)3nFur4Ga0ncbiw(wWCdJpgIkNF7xqc))U5Jk4Od2KEEakMMppeWEsdxCln30WC2b4RPjAL6iUXajIgSWdQRd810eTsDe3yGKTYnJ966WmP3BNdOLdsmR2TKg8EGvUbQNn)C4HuI4ALIEl6weWVjI5JkDD8qkr4Ga0ncX8r1S5NJ)F38rfbV7gP9PMgdWB5cbiw(wWC0CJDNjp))U5JkIgdgAlPocqS8TG5O5g7oZSiQC(TFbj8)7MpQGJoyJLy9aBBFQ1d810maXTGAUPH5WdPeX1kf9w0TiGFtKqMUoEiLiCqa6gHeYYJhsjcheGUriWZ5uoqH9ZMF6722Y(ibe7WmiQC(TFbj8)7MpQGJoytwaSjB3IUH3D4P5MgMZoaFnnrRuhXngir0GfEqDDGVMMOvQJ4gdKSvUzSxxhMj9E7CaTCqIz1UL0G3dSYnq9SiQC(TFbj8)7MpQGJoyJRvk6TOBra)M0CtdZzNZ7sDKTIVWc3B)IiLJ3fJUoEiLiBfFHfU3(fjKnB(PVBBl7JeqUHzqu58B)cs4)3nFubhDWgoiaDJO5MgM(UTTSpsa5gghrLZV9liH)F38rfC0bBcqPTNyPz5wYqpaOuaW2wW1SFa2O30P5MgWdPeX1kf9w0TiGFtKqMUoEiLiCqa6gHeYqu58B)cs4)3nFubhDWgU37nNF7xT(cpnl3sgoWwukherfIkNF7xqsARfoja4GwhSoEx0SClzWaBChEoEx0uR3dYamt6925aA5GeZQDlPbVhyLBG68258UuhbS0tN8bytRaml)is54DXORdZKEVDoGwoiXSA3sAW7bw5gMj)5DPocyPNo5dWMwbyw(rKYX7IbrLZV9lijT1cNeaC0bB2k(clCV9ln30aEiLiBfFHfU3(fX8rLUoEiLiBfFHfU3(fbiw(wWyhl)03TTL9rci3Wm66N3L6iIgi8WTF1GsDsXfIuoExm55)3nFurenq4HB)QbL6KIleGy5BbJLc7ZJhsjYwXxyH7TFraILVfmwkgtxN)F38rfX1kf9w0TiGFteGy5BbJLIXYJhsjYwXxyH7TFraILVfmwQTp)03TTL9rci3WmiQC(TFbjPTw4KaGJoyJObcpC7xnOuNuCrZnnaZKEVDoGwoiXSA3sAW7bwXoqD(5SZ5DPocheGUris54DXORJhsjcheGUriMpQYZ)VB(OIWbbOBecqS8TG5OWEDD8qkr4Ga0ncbEoNYCdZ)S5Td))U5JkIRvk6TOBra)MiaXY3cglf2JOY53(fKK2AHtcao6GnMv7wsdEpWsZnnO1bRJ3fIb24o8C8UKFo7CExQJWbbOBeIuoExm668)7MpQiCqa6gHaelFlyoAUXUupRUoEiLiIvMTaXRw2hjasilVrWdPerJbdTLuhX8rvE8qkrmR2TKwwaK9qHy(OcrLZV9lijT1cNeaC0bBoXkR7aytRaml)0CtdZzNZ7sDeoiaDJqKYX7Ijp))U5JkIRvk6TOBra)MiaXY3cMJMBS7m668)7MpQiCqa6gHaelFlyoAUXUZmB(5SZ5DPoIObcpC7xnOuNuCHiLJ3fJUo))U5JkIObcpC7xnOuNuCHaelFlyoAUXUuRRZ)VB(OI4ALIEl6weWVjcqS8TG5O5g7otE()DZhvexRu0Br3Ia(nraILVfmwkSxxhpKseoiaDJqcz5XdPeHdcq3ie45CkJLc7NfrfIkNF7xqcTucWVhah06G1X7IMLBjdZNp(RPwVhKH5SZ5DPoYKBzjG2NAra)Mis54DXORFoGwoYK49BIKXVCduBF(5WdPeX1kf9w0TiGFteZhv664HuIWbbOBeI5JQzNfrLZV9liHwkb43dGJoyd379MZV9RwFHNMLBjdPTw4KaGAUPHPVBBl7JeqUHX01XdPeXsSEGTTp16b(AAgG4wqsitxhpKseOi30w0nGtlKqgIkNF7xqcTucWVhahDWMiNsP9PMdNeOMBAyo7a810eTsDe3yGerdw4b11b(AAIwPoIBmqYw5OymDDyM07TZb0YbjroLs7tnhojWCdupB(5M(UTTSpsaXoyVU(03TTL9rcyGI88)7MpQi4D3iTp10yaElxiaXY3cMJMBMn)C8)7MpQiUwPO3IUfb8BIaelFlyoAUXUJPRZ)VB(OIWbbOBecqS8TG5O5g7o2SiQC(TFbj0sja)EaC0bBW7UrAFQPXa8wUO5MgM(UTTSpsaXoqTU(CtF32w2hjGHzYph))U5JkYKBzjG2NAra)MiaXY3cMJMBSl166ADW64DHmF(4)SZIOY53(fKqlLa87bWrhSrJbdTLuNMBAy6722Y(ibe7a166Zn9DBBzFKaIDy88ZX)VB(OIG3DJ0(utJb4TCHaelFlyoAUXUuRRR1bRJ3fY85J)ZolIkNF7xqcTucWVhahDWMj3YsaTp1Ia(nP5MgM(UTTSpsaXomoIkNF7xqcTucWVhahDWg(xqHd8B)sZnnm9DBBzFKaIDGAD9PVBBl7JeqSdZKN)F38rfbV7gP9PMgdWB5cbiw(wWC0CJDPwxF6722Y(ibmmEE()DZhve8UBK2NAAmaVLleGy5BbZrZn2L688)7MpQiAmyOTK6iaXY3cMJMBSl1iQC(TFbj0sja)EaC0bB4EV3C(TF16l80SClziT1cNeauZnnCExQJm5wwcO9PweWVjIuoExm5phqlhzs8(nrY4xSduBVUoEiLiUwPO3IUfb8BIeY01XdPeHdcq3iKqgIkNF7xqcTucWVhahDWgoiaDJaAWdSukAUPb()DZhveoiaDJaAWdSuke(KdOfylbC(TF59CduqM)XYp303TTL9rci2bQ11N(UTTSpsaXomtE()DZhve8UBK2NAAmaVLleGy5BbZrZn2LAD9PVBBl7JeWW455)3nFurW7UrAFQPXa8wUqaILVfmhn3yxQZZ)VB(OIOXGH2sQJaelFlyoAUXUuNN)F38rfH)fu4a)2ViaXY3cMJMBSl1ZIOY53(fKqlLa87bWrhSH79EZ53(vRVWtZYTKH0wlCsaqevo)2VGeAPeGFpao6Gn8V4sDa)etl1DlbrLZV9liHwkb43dGJoydheGUran4bwkfn30W03TTL9rci2HXru58B)csOLsa(9a4Od24aUxs7EaqQtZnnm9DBBzFKaIDyCfMwba3VuXrT9uOHSNA7PGqH9JRWICqTfnuHf)Jhfpe38CCZ3INigIfZKGyRv2doel9aelEZijp0V4nediXxybIbXGVLGyE4El)edIXN8IwGeevZ33sqmkINi28ubdzzp4edI58B)cXI38W9n)oNtz8gbrfIQ5zRShCIbXIxiMZV9leRVWdsquPW6l8GQyuygj5H(PIrfhfQyuyo)2VuyE4(MFNZPuHjLJ3fJAe1PIJAvmkmNF7xkmGGhOuuys54DXOgrDQ4MrfJctkhVlg1ikmNF7xkmU37nNF7xT(cpfwFHxRClrHX)VB(OcQovCJRIrHjLJ3fJAefMZV9lfg379MZV9RwFHNcRVWRvULOWOLsa(9aO6uNcldi83c3pvmQ4OqfJctkhVlg1iQtfh1Qyuys54DXOgrDQ4MrfJctkhVlg1iQtf34Qyuys54DXOgrDQ4gtfJcZ53(Lcl7V9lfMuoExmQruNkU4LkgfMuoExmQruyCWEcyDfMDqSZ7sDKiNsP9PMdNeirkhVlgfMZV9lfMd4EjT7baPo1Pofg))U5JkOkgvCuOIrHjLJ3fJAefghSNawxHHhsjcE)FtpapcqC(Hy66igEiLiUwPO3IUfb8BIeYqmDDedpKseoiaDJqcziwEedpKseoiaDJqaILVfeXIfXOEmfMZV9lfw2F7xQtfh1Qyuys54DXOgrHXb7jG1vyWmP3BNdOLds6l90bBAmyOTK6qSCdig1iMUoInhIzhed4RPjAL6iUXajIgSWdIy66igWxtt0k1rCJbs2cXYHyZ)yi2SkmNF7xkS(spDWMgdgAlPo1PIBgvmkmPC8UyuJOW4G9eW6km8qkrCTsrVfDlc43ejKHy66igEiLiCqa6gHeYqS8igEiLiCqa6gHapNtjInGyuyVcZ53(LclTabV)VrDQ4gxfJctkhVlg1ikmoypbSUcdpKseOi30w0nGtleZhvkmNF7xkm40kDt7tnTsrlEXf1PIBmvmkmPC8UyuJOW4G9eW6kSBTeel2beJAetxhXWdPebiCk7ce2spGlKqMcZ53(Lc7MKwOW)qzAPhWf1PIlEPIrHjLJ3fJAefghSNawxHHhsjIRvk6TOBra)MiHmetxhXWdPeHdcq3iKqgILhXWdPeHdcq3ie45CkrSbeJc7vyo)2Vuy49)nTp1UjPjLyzR6uXn)Qyuys54DXOgrHXb7jG1vy8)7MpQiUwPO3IUfb8BIaelFliIflIrZniwEeB6722Y(ibGy5gqSzqmDDeJ)F38rfHdcq3ieGy5BbrSyrmAUbXYJytF32w2hjael3aInoIPRJy8)7MpQiUwPO3IUfb8BIaelFliILBaXgFmetxhX4)3nFur4Ga0ncbiw(wqel3aIn(ykmNF7xkm6GdmRxTp185Ha(BsDQ40WQyuys54DXOgrHXb7jG1vy8)7MpQiUwPO3IUfb8BIaelFliIflIrZniwEeB6722Y(ibGy5gqSzqmDDeJ)F38rfHdcq3ieGy5BbrSyrmAUbXYJytF32w2hjael3aInoIPRJy8)7MpQiUwPO3IUfb8BIaelFliILBaXgFmetxhX4)3nFur4Ga0ncbiw(wqel3aIn(ykmNF7xkSOh0nALTAab(LxCrDQ40qQyuys54DXOgrHXb7jG1vyZHy2bXa(AAIwPoIBmqIObl8GiMUoIb810eTsDe3yGKTqSCi2m2Jy66igmt6925aA5GeZQDlPbVhyHy5gqmQrSzrS8i2CigEiLiUwPO3IUfb8BIy(OcX01rm8qkr4Ga0ncX8rfInlILhXMdX4)3nFurW7UrAFQPXa8wUqaILVfeXYHy0CdIzxeBgelpIX)VB(OIOXGH2sQJaelFliILdXO5geZUi2mi2SkmNF7xkS0ZdqX085Ha2tA4IBPovCuyVkgfMuoExmQruyCWEcyDf2CigEiLiUwPO3IUfb8BIeYqmDDedpKseoiaDJqcziwEedpKseoiaDJqGNZPeXgqmkShXMfXYJytF32w2hjael2beBgfMZV9lfMLy9aBBFQ1d810maXTGQtfhfuOIrHjLJ3fJAefghSNawxHnhIzhed4RPjAL6iUXajIgSWdIy66igWxtt0k1rCJbs2cXYHyZypIPRJyWmP3BNdOLdsmR2TKg8EGfILBaXOgXMvH58B)sHLfaBY2TOB4DhEQtfhfuRIrHjLJ3fJAefghSNawxHnhIzhe78UuhzR4lSW92Vis54DXGy66igEiLiBfFHfU3(fjKHyZIy5rSPVBBl7JeaILBaXMrH58B)sH5ALIEl6weWVj1PIJIzuXOWKYX7IrnIcJd2taRRWM(UTTSpsaiwUbeBCfMZV9lfgheGUruNkokgxfJctkhVlg1ikmNF7xkSEaqPaGTTGRz)aSrVPtHXb7jG1vy4HuI4ALIEl6weWVjsidX01rm8qkr4Ga0ncjKPWk3suy9aGsbaBBbxZ(byJEtN6uXrXyQyuys54DXOgrH58B)sHX9EV58B)Q1x4PW6l8ALBjkSdSfLYbvN6uyhylkLdQIrfhfQyuys54DXOgrH58B)sHbCRSTOBUvwFVGrA0lTR97xtk6TefghSNawxHnhIHhsjIRvk6TOBra)MiHmetxhXWdPeHdcq3iKqgInRcRClrHbCRSTOBUvwFVGrA0lTR97xtk6Te1PIJAvmkmPC8UyuJOWC(TFPWObFrdBzG1Y7nGtlkmoypbSUcZoigEiLiUwPO3IUfb8BIeYqS8iMDqm8qkr4Ga0ncjKPWk3suy0GVOHTmWA59gWPf1PIBgvmkmPC8UyuJOWk3suyaFEycfLWg(s3aIPHhU7lfMZV9lfgWNhMqrjSHV0nGyA4H7(sDQ4gxfJctkhVlg1ikmNF7xkmnkW20h1fGcJd2taRRWWdPeX1kf9w0TiGFtKqgIPRJy4HuIWbbOBesidXYJy4HuIWbbOBec8CoLi2aIrH9kSYTefMgfyB6J6cqDQ4gtfJctkhVlg1ikmNF7xkmTR3BFQ51A5NyA49)nkmoypbSUcBoedpKsexRu0Br3Ia(nrcziMUoIHhsjcheGUriHmelpIHhsjcheGUriaXY3cIyXIyuOHrSzrmDDeBoeJ)F38rfX1kf9w0TiGFteGy5BbrSCi2m2Jy66ig))U5JkcheGUriaXY3cIy5qSzShXMvHvULOW0UEV9PMxRLFIPH3)3OovCXlvmkmPC8UyuJOWC(TFPWm)BbBPaWwfghSNawxHHhsjIRvk6TOBra)MiHmetxhXWdPeHdcq3iKqgILhXWdPeHdcq3ieGy5BbrSyrmk0WkSYTefM5Flylfa2QovCZVkgfMuoExmQruyo)2Vuy0Ex4EVlaydxCkvyCWEcyDfgEiLiUwPO3IUfb8BIeYqmDDedpKseoiaDJqcziwEedpKseoiaDJqaILVfeXIfXOymfw5wIcJ27c37DbaB4ItP6uXPHvXOWKYX7IrnIcZ53(Lcd3w6VKgUinVB5LZvyCWEcyDfgEiLiUwPO3IUfb8BIeYqmDDedpKseoiaDJqczkSYTefgUT0FjnCrAE3YlNRovCAivmkmPC8UyuJOWC(TFPWSeGq5n5WwYlAfghSNawxHnhIzhed4RPjAL6iUXajIgSWdIy66igWxtt0k1rCJbs2cXYHyumgInlIPRJyWmP3BNdOLdsmR2TKg8EGfILBaXOwHvULOWSeGq5n5WwYlA1PIJc7vXOWKYX7IrnIcZ53(LclRhkJaWfhyGTu3HuQW4G9eW6km8qkrCTsrVfDlc43ejKHy66igEiLiCqa6gHeYqS8igEiLiCqa6gHapNtjILBaXOWEetxhX4)3nFurCTsrVfDlc43ebiw(wqelhIn(yiMUoIzhedpKseoiaDJqcziwEeJ)F38rfHdcq3ieGy5BbrSCi24JPWk3suyz9qzeaU4adSL6oKs1PIJckuXOWKYX7IrnIcZ53(LcdxaqbqPaGnng0yqHXb7jG1vy4HuI4ALIEl6weWVjsidX01rm8qkr4Ga0ncjKHy5rm8qkr4Ga0ncbEoNsel3aIrH9iMUoIX)VB(OI4ALIEl6weWVjcqS8TGiwoeB8XqmDDeZoigEiLiCqa6gHeYqS8ig))U5JkcheGUriaXY3cIy5qSXhtHvULOWWfauaukaytJbnguNkokOwfJctkhVlg1ikmNF7xkmPmDbcB3w8laK2NAjGZV9lV3Y(ibOW4G9eW6km8qkrCTsrVfDlc43ejKHy66igEiLiCqa6gHeYqS8igEiLiCqa6gHapNtjILBaXOWEetxhX4)3nFurCTsrVfDlc43ebiw(wqelhIn(yiMUoIX)VB(OIWbbOBecqS8TGiwoeB8XuyLBjkmPmDbcB3w8laK2NAjGZV9lV3Y(ibOovCumJkgfMuoExmQruyo)2VuyzId6nZQvaWg)TYCiuHXb7jG1vy4HuI4ALIEl6weWVjsidX01rm8qkr4Ga0ncjKHy5rm8qkr4Ga0ncbEoNsel3aIrH9kSYTefwM4GEZSAfaSXFRmhcvNkokgxfJctkhVlg1ikmNF7xkS0cGxZYpb2Gz2s3DiuHXb7jG1vy4HuI4ALIEl6weWVjsidX01rm8qkr4Ga0ncjKHy5rm8qkr4Ga0ncbiw(wqel2beJIXuyLBjkS0cGxZYpb2Gz2s3DiuDQ4OymvmkmPC8UyuJOWC(TFPWIMwqpAlAylRhSCArHXb7jG1vy4HuI4ALIEl6weWVjsidX01rm8qkr4Ga0ncjKHy5rm8qkr4Ga0ncbiw(wqel2beJA7vyLBjkSOPf0J2Ig2Y6blNwuNkokIxQyuys54DXOgrH58B)sHzaIBA0D3S(9ayd3n0IcJd2taRRWWdPeX1kf9w0TiGFtKqgIPRJy4HuIWbbOBesidXYJy4HuIWbbOBecqS8TGiwSdig12RWk3suygG4MgD3nRFpa2WDdTOovCum)Qyuys54DXOgrH58B)sHzaIBAomBbEDWMLy8EF)sHXb7jG1vy4HuI4ALIEl6weWVjsidX01rm8qkr4Ga0ncjKHy5rm8qkr4Ga0ncbiw(wqel2beJA7vyLBjkmdqCtZHzlWRd2SeJ377xQtfhfAyvmkmPC8UyuJOWC(TFPWOS(R9PMx8vQRLcaBvyCWEcyDfgEiLiUwPO3IUfb8BIeYqmDDedpKseoiaDJqcziwEedpKseoiaDJqGNZPeXYnGyuypIPRJy8)7MpQiUwPO3IUfb8BIaelFliILdXMXEetxhXSdIHhsjcheGUriHmelpIX)VB(OIWbbOBecqS8TGiwoeBg7vyLBjkmkR)AFQ5fFL6APaWw1PIJcnKkgfMuoExmQruyCWEcyDfgEiLiUwPO3IUfb8BIeYqmDDedpKseoiaDJqcziwEedpKseoiaDJqGNZPeXgqmkSxH58B)sHfGsBpXcQo1PWsBTWjbavXOIJcvmkmPC8UyuJOW(mfguofMZV9lfMwhSoExuyA9EquyWmP3BNdOLdsmR2TKg8EGfILBaXOgXYJy2bXoVl1ral90jFa20kaZYpIuoExmiMUoIbZKEVDoGwoiXSA3sAW7bwiwUbeBgelpIDExQJaw6Pt(aSPvaMLFePC8UyuyADqRClrHzGnUdphVlQtfh1Qyuys54DXOgrHXb7jG1vy4HuISv8fw4E7xeZhviMUoIHhsjYwXxyH7TFraILVfeXIfXgdXYJytF32w2hjael3aIndIPRJyN3L6iIgi8WTF1GsDsXfIuoExmiwEeJ)F38rfr0aHhU9RguQtkUqaILVfeXIfXOWEelpIHhsjYwXxyH7TFraILVfeXIfXOymetxhX4)3nFurCTsrVfDlc43ebiw(wqelweJIXqS8igEiLiBfFHfU3(fbiw(wqelweJA7rS8i203TTL9rcaXYnGyZOWC(TFPW2k(clCV9l1PIBgvmkmPC8UyuJOW4G9eW6kmyM07TZb0YbjMv7wsdEpWcXIDaXOgXYJyZHy2bXoVl1r4Ga0ncrkhVlgetxhXWdPeHdcq3ieZhviwEeJ)F38rfHdcq3ieGy5BbrSCigf2Jy66igEiLiCqa6gHapNtjILBaXMFeBwelpIzheJ)F38rfX1kf9w0TiGFteGy5BbrSyrmkSxH58B)sHjAGWd3(vdk1jfxuNkUXvXOWKYX7IrnIcJd2taRRW06G1X7cXaBChEoExqS8i2CiMDqSZ7sDeoiaDJqKYX7IbX01rm()DZhveoiaDJqaILVfeXYHy0CdIzxeJAeBwetxhXWdPerSYSfiE1Y(ibqcziwEeZi4HuIOXGH2sQJy(OcXYJy4HuIywTBjTSai7HcX8rLcZ53(LcZSA3sAW7bwQtf3yQyuys54DXOgrHXb7jG1vyZHy2bXoVl1r4Ga0ncrkhVlgelpIX)VB(OI4ALIEl6weWVjcqS8TGiwoeJMBqm7IyZGy66ig))U5JkcheGUriaXY3cIy5qmAUbXSlIndInlILhXMdXSdIDExQJiAGWd3(vdk1jfxis54DXGy66ig))U5JkIObcpC7xnOuNuCHaelFliILdXO5geZUig1iMUoIX)VB(OI4ALIEl6weWVjcqS8TGiwoeJMBqm7IyZGy5rm()DZhvexRu0Br3Ia(nraILVfeXIfXOWEetxhXWdPeHdcq3iKqgILhXWdPeHdcq3ie45CkrSyrmkShXMvH58B)sHDIvw3bWMwbyw(Po1PWOLsa(9aOkgvCuOIrHjLJ3fJAef2NPWGYPWC(TFPW06G1X7IctR3dIcBoeZoi25DPoYKBzjG2NAra)Mis54DXGy66i25aA5itI3Vjsg)qSCdig12Jy5rS5qm8qkrCTsrVfDlc43eX8rfIPRJy4HuIWbbOBeI5JkeBweBwfMwh0k3suyZNp(RovCuRIrHjLJ3fJAefghSNawxHn9DBBzFKaqSCdi2yiMUoIHhsjILy9aBBFQ1d810maXTGKqgIPRJy4HuIaf5M2IUbCAHeYuyo)2VuyCV3Bo)2VA9fEkS(cVw5wIclT1cNeauDQ4MrfJctkhVlg1ikmoypbSUcBoeZoigWxtt0k1rCJbsenyHheX01rmGVMMOvQJ4gdKSfILdXOymetxhXGzsV3ohqlhKe5ukTp1C4KarSCdig1i2SiwEeBoeB6722Y(ibGyXoGy2Jy66i203TTL9rcaXgqmkqS8ig))U5JkcE3ns7tnngG3YfcqS8TGiwoeJMBqSzrS8i2Cig))U5JkIRvk6TOBra)MiaXY3cIy5qmAUbXSlIngIPRJy8)7MpQiCqa6gHaelFliILdXO5geZUi2yi2SkmNF7xkSiNsP9PMdNeO6uXnUkgfMuoExmQruyCWEcyDf203TTL9rcaXIDaXOgX01rS5qSPVBBl7JeaInGyZGy5rS5qm()DZhvKj3YsaTp1Ia(nraILVfeXYHy0CdIzxeJAetxhX06G1X7cz(8XFeBweBwfMZV9lfgE3ns7tnngG3Yf1PIBmvmkmPC8UyuJOW4G9eW6kSPVBBl7JeaIf7aIrnIPRJyZHytF32w2hjael2beBCelpInhIX)VB(OIG3DJ0(utJb4TCHaelFliILdXO5geZUig1iMUoIP1bRJ3fY85J)i2Si2SkmNF7xkmngm0wsDQtfx8sfJctkhVlg1ikmoypbSUcB6722Y(ibGyXoGyJRWC(TFPWMCllb0(ulc43K6uXn)Qyuys54DXOgrHXb7jG1vytF32w2hjael2beJAetxhXM(UTTSpsaiwSdi2miwEeJ)F38rfbV7gP9PMgdWB5cbiw(wqelhIrZniMDrmQrmDDeB6722Y(ibGydi24iwEeJ)F38rfbV7gP9PMgdWB5cbiw(wqelhIrZniMDrmQrS8ig))U5JkIgdgAlPocqS8TGiwoeJMBqm7IyuRWC(TFPW4FbfoWV9l1PItdRIrHjLJ3fJAefghSNawxHDExQJm5wwcO9PweWVjIuoExmiwEe7CaTCKjX73ejJFiwSdig12Jy66igEiLiUwPO3IUfb8BIeYqmDDedpKseoiaDJqczkmNF7xkmU37nNF7xT(cpfwFHxRClrHL2AHtcaQovCAivmkmPC8UyuJOW4G9eW6km()DZhveoiaDJaAWdSuke(KdOfylbC(TF5Del3aIrbz(hdXYJyZHytF32w2hjael2beJAetxhXM(UTTSpsaiwSdi2miwEeJ)F38rfbV7gP9PMgdWB5cbiw(wqelhIrZniMDrmQrmDDeB6722Y(ibGydi24iwEeJ)F38rfbV7gP9PMgdWB5cbiw(wqelhIrZniMDrmQrS8ig))U5JkIgdgAlPocqS8TGiwoeJMBqm7IyuJy5rm()DZhve(xqHd8B)IaelFliILdXO5geZUig1i2SkmNF7xkmoiaDJaAWdSukQtfhf2RIrHjLJ3fJAefMZV9lfg379MZV9RwFHNcRVWRvULOWsBTWjbavNkokOqfJcZ53(LcJ)fxQd4NyAPUBjkmPC8UyuJOovCuqTkgfMuoExmQruyCWEcyDf203TTL9rcaXIDaXgxH58B)sHXbbOBeqdEGLsrDQ4OygvmkmPC8UyuJOW4G9eW6kSPVBBl7JeaIf7aInUcZ53(LcZbCVK29aGuN6uN6uyE4MEGcdBTMVuN6uka]] )


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
