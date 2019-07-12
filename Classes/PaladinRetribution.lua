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


    spec:RegisterPack( "Retribution", 20190712.0045, [[duuSjbqiKOEesi2ef1OuOCkfsRsOOxPOywue3cjKAxq(LqLHHKCmfvlJI0ZuOAAibxtrPTHeQ(MKuACirY5KKQwNKuP5ju6EkyFsIdIes0cviEisKIlIePQrIekojsKsRKiStjjdfjKWsrcj9uenvHQUksKkFfjuAVu6Vs1GjCyQwmcpMKjtQlJAZs5Zi1OvKtR0Qfk8AKuZwIBtHDl63QA4sQJljflh45GMUkxxW2jsFxiJhjIZteTEjPI5tu7hQTZTXBj1(X2QmLQ5vpvv7CtrurffMLQ5wYtYA2sw7kQDA2sMUbBjPOYhyjc3(PLS2LS8U2gVLe(bGITKt3vdRUXfh9EtbcK6nIdUgHIF7NkG3U4GRHkoljrylhL20syj1(X2QmLQ5vpvvlvvpAof3scRzLTQQLkl50Q1CAjSKAgQSKueSGIkFGLiC7NybffEX1BILGIGft3vdRUXfh9EtbcK6nIdUgHIF7NkG3U4GRHkoSeueSqIqrsSyUPMGfMs18QhlOOXcQOQ6sHzXsGLGIGfuAM8KMHvxSeueSGIglO0vR9J1yr7bybLczkYswd(2wyljfblOOYhyjc3(jwqrHxC9MyjOiyX0D1WQBCXrV3uGaPEJ4GRrO43(Pc4Tlo4AOIdlbfblKiuKelMBQjyHPunV6XckASGkQQUuywSeyjOiybLMjpPzy1flbfblOOXckD1A)ynw0EawqPqMIWsGLGIGfu6PewfowJfeC7bmwOEdc)WccMEticlOOuP46dIf5Nu0toWOfkyHRU9tiw8zrsewcxD7NqunGvVbHFdTIdPglHRU9tiQgWQ3GWVzgIR9VglHRU9tiQgWQ3GWVzgIZd0gCE(TFILGIGfKPxdN(dla(QXcIqRXASaE(bXccU9agluVbHFybbtVjel8uJf1aMIU(VBtASyHyH(tgHLWv3(jevdy1Bq43mdXbtVgo9xhE(bXs4QB)eIQbS6ni8BMH4Q)B)elHRU9tiQgWQ3GWVzgIZbkp5(9aaNNjBBGYNx48qro1C)BDhoXqeNorH1yjWsqrWck9ucRchRXcwkdKelU1GXIBIXcxDpalwiw4s9T4efgHLWv3(jCaWebQzSeU62pHZmeNYlLURU9ZEzHNjPBWdQ)l6pkHyjC1TFcNzioLxkDxD7N9Ycpts3GhO5Kb(9aiwcSeU62pHOdSj18bhcqUVhBys6g8aWnQ3KU7g1L9cAUtV0U0VCDoP3KnzBdJreAnKlLt6nP7ra)MqHAzzIqRHuGa01mkupkwcxD7Nq0b2KA(GZmexaY99ydts3GhObFsd71G1WlDGtZMSTbkteAnKlLt6nP7ra)MqHAZuMi0AifiaDnJc1yjC1TFcrhytQ5doZqCbi33JnmjDdEa4vhDiPg2jw6oG1DIWDFILWv3(jeDGnPMp4mdXfGCFp2WK0n4HyWW(0hvyGjBBGi0AixkN0Bs3Ja(nHc1YYeHwdPabORzuO2mrO1qkqa6Agbpxr9WCQWs4QB)eIoWMuZhCMH4cqUVhBys6g8G01l9V19Cn8J1DIY)At22WyeHwd5s5KEt6EeWVjuOwwMi0AifiaDnJc1MjcTgsbcqxZiaB4BcJDoLAuz5Xu)x0FuICPCsVjDpc43ecWg(MWkJtLSS6)I(JsKceGUMra2W3ewzCQgflHRU9ti6aBsnFWzgIla5(ESHjPBWd6)nG9waiPjBBGi0AixkN0Bs3Ja(nHc1YYeHwdPabORzuO2mrO1qkqa6AgbydFtySZPuyjC1TFcrhytQ5doZqCbi33JnmjDdEG2lSYlfga7eStTjBBGi0AixkN0Bs3Ja(nHc1YYeHwdPabORzuO2mrO1qkqa6AgbydFtySZNflHRU9ti6aBsnFWzgIla5(ESHjPBWdess)j3jyU7fdpDLjBBGi0AixkN0Bs3Ja(nHc1YYeHwdPabORzuOglHRU9ti6aBsnFWzgIla5(ESHjPBWdgmGP(MCyV5jTjBBymkd8v3zPCEixRHiMsw4bLLb(Q7SuopKR1q0MvMp7OYYWAUu6NdO5dI0R0n5o8EGrLbtXs4QB)eIoWMuZhCMH4cqUVhBys6g8qDjKAgqWoqd7TIdP2KTnqeAnKlLt6nP7ra)MqHAzzIqRHuGa01mkuBMi0AifiaDnJGNROUYWCQKLv)x0FuICPCsVjDpc43ecWg(MWkuywzzkteAnKceGUMrHAZQ)l6pkrkqa6AgbydFtyfkmlwcxD7Nq0b2KA(GZmexaY99ydts3GhiyaKbuZaypgHyemzBdeHwd5s5KEt6EeWVjuOwwMi0AifiaDnJc1MjcTgsbcqxZi45kQRmmNkzz1)f9hLixkN0Bs3Ja(nHaSHVjScfMvwMYeHwdPabORzuO2S6)I(JsKceGUMra2W3ewHcZILWv3(jeDGnPMp4mdXfGCFp2WK0n4bo1fgc73MQla4(36nGRU9tV0R)igyY2gicTgYLYj9M09iGFtOqTSmrO1qkqa6AgfQnteAnKceGUMrWZvuxzyovYYQ)l6pkrUuoP3KUhb8BcbydFtyfkmRSS6)I(JsKceGUMra2W3ewHcZILWv3(jeDGnPMp4mdXfGCFp2WK0n4HA2bLUELYayx9g1oeAY2gicTgYLYj9M09iGFtOqTSmrO1qkqa6AgfQnteAnKceGUMrWZvuxzyovyjC1TFcrhytQ5doZqCbi33JnmjDdEOTa41n8JHDyTK0fhcnzBdeHwd5s5KEt6EeWVjuOwwMi0AifiaDnJc1MjcTgsbcqxZiaB4BcJDy(SyjC1TFcrhytQ5doZqCbi33JnmjDdEiAAbLOnPH96sWWPzt22arO1qUuoP3KUhb8BcfQLLjcTgsbcqxZOqTzIqRHuGa01mcWg(MWyhmLkSeU62pHOdSj18bNziUaK77XgMKUbpObSR70fxV(9ayNW10SjBBGi0AixkN0Bs3Ja(nHc1YYeHwdPabORzuO2mrO1qkqa6AgbydFtySdMsfwcxD7Nq0b2KA(GZmexaY99ydts3Gh0a21DhwVappy3G1EPSFAY2gicTgYLYj9M09iGFtOqTSmrO1qkqa6AgfQnteAnKceGUMra2W3eg7GPuHLWv3(jeDGnPMp4mdXfGCFp2WK0n4bQZ)6FR7PA586Taqst22arO1qUuoP3KUhb8BcfQLLjcTgsbcqxZOqTzIqRHuGa01mcEUI6kdZPsww9Fr)rjYLYj9M09iGFtiaB4BcRmovYYuMi0AifiaDnJc1Mv)x0FuIuGa01mcWg(MWkJtfwcxD7Nq0b2KA(GZmexaY99ydOjBBGi0AixkN0Bs3Ja(nHc1YYeHwdPabORzuO2mrO1qkqa6Agbpxr9WCQWsGLWv3(jeP(VO)OeoO8sP7QB)Sxw4zs6g8Wb2KA(GyjC1TFcrQ)l6pkHZmex9F7NMSTbIqRHik)Rlb4HaSRozzIqRHCPCsVjDpc43ekullteAnKceGUMrHAZeHwdPabORzeGn8nHXA6SyjC1TFcrQ)l6pkHZmexzPNoypgbnTbNNjBBawZLs)CanFquzPNoypgbnTbNxLbtLLhJYaF1DwkNhY1AiIPKfEqzzGV6olLZd5AneTzLQD2rXs4QB)eIu)x0FucNziU2cyIY)At22arO1qUuoP3KUhb8BcfQLLjcTgsbcqxZOqTzIqRHuGa01mcEUI6H5uHLWv3(jeP(VO)OeoZqCWPLl6(36s5KM9uXMSTbIqRHGmFtBs3bonJ0FuAMi0Aid24bs2)wVeuRURbSBar6pkXs4QB)eIu)x0FucNziUaK77XgMKUbpaCJ6nP7UrDzVGM70lTl9lxNt6nzt22WyeHwd5s5KEt6EeWVjuOwwMi0AifiaDnJc1JILWv3(jeP(VO)OeoZqC3e3djXhsDV9afBY2gU1GJDWuzzIqRHaSI6cdH92dumkuJLWv3(jeP(VO)OeoZqCeL)19V1VjUZjBiPjBBGi0AixkN0Bs3Ja(nHc1YYeHwdPabORzuO2mrO1qkqa6Agbpxr9WCQWs4QB)eIu)x0FucNzio6Gd0RN9V19Qdd(BYKTnq5ZlCEifiaDnJ40jkS28yQ)l6pkrUuoP3KUhb8BcbydFtySZAE6ls2R)iguzyCZJreAn0MvtyH7TFIc1YYu(8cNhAZQjSW92prC6efwpQSS6)I(JsKlLt6nP7ra)Mqa2W3ewzGcZoQS8yNx48qkqa6AgXPtuyTz1)f9hLifiaDnJaSHVjmwAL280xKSx)rmOYafKLN(IK96pIbvgg38TgCSZPY85fopuKtn3)w3HtmeXPtuyTSS6)I(JsKceGUMra2W3ewzGcZokwcxD7NqK6)I(Js4mdXf9GIwkVzhWWp9uXMSTb1)f9hLixkN0Bs3Ja(nHaSHVjmwAL280xKSx)rmOYW4YYQ)l6pkrkqa6AgbydFtyS0kT5PVizV(JyqLbkilR(VO)Oe5s5KEt6EeWVjeGn8nHvgOWSYYQ)l6pkrkqa6AgbydFtyLbkmlwcxD7NqK6)I(Js4mdX1EvaY6UxDyWECNGDdt22Wyug4RUZs58qUwdrmLSWdkld8v3zPCEixRHOnRmovYYWAUu6NdO5dI0R0n5o8EGrLbth18yeHwd5s5KEt6EeWVjK(JszzIqRHuGa01ms)r5OMht9Fr)rjIO4AU)TEmcWBvmcWg(MWk0kDmh3S6)I(JsumcAAdopeGn8nHvOv6yo(OyjC1TFcrQ)l6pkHZmeNbB8aj7FRxcQv31a2nGMSTHXicTgYLYj9M09iGFtOqTSmrO1qkqa6AgfQnteAnKceGUMrWZvupmNQrnp9fj71FedIDyCSeU62pHi1)f9hLWzgIRoa2MKBs3jko8mzBdJrzGV6olLZd5AneXuYcpOSmWxDNLY5HCTgI2SY4ujldR5sPFoGMpisVs3K7W7bgvgmDuSeU62pHi1)f9hLWzgIZLYj9M09iGFtMSTHXO85fop0MvtyH7TFI40jkSwwMi0AOnRMWc3B)efQh180xKSx)rmOYW4yjC1TFcrQ)l6pkHZmeNceGUMnzBdtFrYE9hXGkduqwE6ls2R)iguzyCZ3AWXoNkZNx48qro1C)BDhoXqeNorH1yjWs4QB)eIABUWjgahK6G1jkSjPBWdrBsd71)xmrQxc8aL5QjS11SgnNIx9JpNcMhJYNx48qkqa6AgXPtuyTz1)f9hLixkN0Bs3Ja(nHaSHVjScTshZXLLv)x0FuIuGa01mcWg(MWk0kDmhFuzzUAcBDnRrZP4v)4ZPG5XO85fopKceGUMrC6efwBw9Fr)rjYLYj9M09iGFtiaB4BcRqR0XKIllR(VO)OePabORzeGn8nHvOv6ysXhflHRU9tiQT5cNyaCMH4K6G1jkSjPBWdAyx5WZjkSjs9sGhG1CP0phqZhePxPBYD49aJkdMAMYNx48qGLE64pa7szGEvhItNOWAzzynxk9Zb08br6v6MChEpWOYW4MpVW5Hal90XFa2LYa9QoeNorH1yjC1TFcrTnx4edGZme3MvtyH7TFAY2gicTgYLYj9M09iGFti9hLMhJi0AOnRMWc3B)eP)OuwMi0AOnRMWc3B)ebydFtySukZtFrYE9hXGkdJllFEHZdXucRc3(zhY5XPIrC6efwBw9Fr)rjIPewfU9ZoKZJtfJaSHVjm25uzMi0AOnRMWc3B)ebydFtySZNvww9Fr)rjYLYj9M09iGFtiaB4BcJD(SMjcTgAZQjSW92pra2W3egRPuzE6ls2R)iguzy8rXs4QB)eIABUWjgaNzioMsyv42p7qopovSjBBawZLs)CanFqKELUj3H3dmIDWuZJr5ZlCEifiaDnJ40jkS2S6)I(JsKlLt6nP7ra)Mqa2W3ewzovYYNx48qkqa6AgXPtuyTzIqRHuGa01ms)rPz1)f9hLifiaDnJaSHVjSYCQKLjcTgsbcqxZi45kQRmuTJILWv3(je12CHtmaoZqC6v6MChEpWWKTni1bRtuyKg2vo8CIcBwQdwNOWOOnPH96)lMhJYNx48qmLWQWTF2HCECQyeNorH1YYWAUu6NdO5dI0R0n5o8EGrSdMAw9Fr)rjIPewfU9ZoKZJtfJaSHVjScTshttLLv)x0FuICPCsVjDpc43ecWg(MWk0kDmh3S6)I(JsKlLt6nP7ra)Mqa2W3eg7CQKLjcTgsbcqxZOqTzIqRHuGa01mcEUI6yNt1OyjC1TFcrTnx4edGZme3Xg1fha7szGEvNjBBqQdwNOWOOnPH96)lMhJYNx48qmLWQWTF2HCECQyeNorH1YYQ)l6pkrmLWQWTF2HCECQyeGn8nHvOv6yAQSS6)I(JsKlLt6nP7ra)Mqa2W3ewHwPJ54Mv)x0FuICPCsVjDpc43ecWg(MWyNtLSmrO1qkqa6AgfQnteAnKceGUMrWZvuh7CQgflbwcxD7NqenNmWVhahK6G1jkSjPBWdumpfRjs9sGhgJYNx48qtUHbd6FRhb8BcXPtuyTS85aA(qtSxUjuT6QmykvMhJi0AixkN0Bs3Ja(nH0FuklteAnKceGUMr6pkhDuSeU62pHiAozGFpaoZqCkVu6U62p7LfEMKUbp02CHtmaAY2gM(IK96pIbvgMvwMi0Aid24bs2)wVeuRURbSBarHAzzIqRHGmFtBs3bonJc1YYeHwdTz1ew4E7Ni9hLMN(IK96pIbvgghlHRU9tiIMtg43dGZmexKtn3)w3Htm0KTnmgLb(Q7SuopKR1qetjl8GYYaF1DwkNhY1AiAZkZNvwgwZLs)CanFquKtn3)w3HtmSYGPJAESPVizV(JyqSdujlp9fj71FedgMBw9Fr)rjIO4AU)TEmcWBvmcWg(MWk0k9OMht9Fr)rjYLYj9M09iGFtiaB4BcRmNkz5ZlCEifiaDnJ40jkS2S6)I(JsKceGUMra2W3ewzovJILWv3(jerZjd87bWzgIJO4AU)TEmcWBvSjBBy6ls2R)ige7GPYYJn9fj71Fedgg38yQ)l6pkrtUHbd6FRhb8BcbydFtyfALoMMkll1bRtuyefZtXo6OyjC1TFcr0CYa)EaCMH4IrqtBW5zY2gM(IK96pIbXoyQS8ytFrYE9hXGyhOG5Xu)x0FuIikUM7FRhJa8wfJaSHVjScTshttLLL6G1jkmII5PyhDuSeU62pHiAozGFpaoZqCtUHbd6FRhb8BYKTnm9fj71FedIDGcyjC1TFcr0CYa)EaCMH4uFczfWV9tt22W0xKSx)rmi2btLLN(IK96pIbXomUz1)f9hLiIIR5(36XiaVvXiaB4BcRqR0X0uz5PVizV(JyWafmR(VO)OeruCn3)wpgb4TkgbydFtyfALoMMAw9Fr)rjkgbnTbNhcWg(MWk0kDmnflHRU9tiIMtg43dGZmeNYlLURU9ZEzHNjPBWdTnx4edGMSTHZlCEOj3WGb9V1Ja(nH40jkS285aA(qtSxUjuT6IDWuQKLjcTgYLYj9M09iGFtOqTSmrO1qkqa6AgfQXs4QB)eIO5Kb(9a4mdXPabORzqhEGLA2KTnO(VO)OePabORzqhEGLAgPMCand7nGRU9tVuzyoQAN18ytFrYE9hXGyhmvwE6ls2R)ige7W4Mv)x0FuIikUM7FRhJa8wfJaSHVjScTshttLLN(IK96pIbduWS6)I(JserX1C)B9yeG3QyeGn8nHvOv6yAQz1)f9hLOye00gCEiaB4BcRqR0X0uZQ)l6pkrQpHSc43(jcWg(MWk0kDmnDuSeU62pHiAozGFpaoZqCkVu6U62p7LfEMKUbp02CHtmaILWv3(jerZjd87bWzgIt9PIZd4hR7TIBWyjC1TFcr0CYa)EaCMH4uGa01mOdpWsnBY2gM(IK96pIbXoqbSeU62pHiAozGFpaoZqCoq5j3Vha48mzBdtFrYE9hXGyhOGLukdG7N2QmLQ5vpvvlvvpAof3sg5GCtAOLKsRr9dowJfuCSWv3(jwuw4bryjSKE4MEGLKCnO0yjll8G24TKAU5HYzJ3w1CB8wsxD7NwsateOMTKC6efwBhXE2Qm1gVLKtNOWA7iwsxD7NwsLxkDxD7N9YcplzzHxpDd2sQ(VO)OeApBvJBJ3sYPtuyTDelPRU9tlPYlLURU9ZEzHNLSSWRNUbBjP5Kb(9aO9SNLSgWQ3GWpB82QMBJ3sYPtuyTDe7zRYuB8wsoDIcRTJypBvJBJ3sYPtuyTDe7zRIc24TKC6efwBhXE2QM1gVL0v3(PLS(V9tljNorH12rSNTkkUnElPRU9tlPbB8aj7FRxcQv31a2nGwsoDIcRTJypBvvRnEljNorH12rSKkWEmyDljLXIZlCEOiNAU)TUdNyiItNOWAlPRU9tlPduEY97baop7zplP6)I(JsOnEBvZTXBj50jkS2oIL0v3(PLu5Ls3v3(zVSWZsww41t3GTKhytQ5dApBvMAJ3sYPtuyTDelPcShdw3sseAner5FDjapeGD1HfYYybrO1qUuoP3KUhb8BcfQXczzSGi0AifiaDnJc1yHzSGi0AifiaDnJaSHVjelIflmDwlPRU9tlz9F7N2Zw1424TKC6efwBhXsQa7XG1TKWAUu6NdO5dIkl90b7XiOPn48WIkdyHPyHSmwmgwqzSa4RUZs58qUwdrmLSWdIfYYybWxDNLY5HCTgI2elQGfv7SyXOwsxD7NwYYspDWEmcAAdop7zRIc24TKC6efwBhXsQa7XG1TKeHwd5s5KEt6EeWVjuOglKLXcIqRHuGa01mkuJfMXcIqRHuGa01mcEUIASyalMtLL0v3(PLSTaMO8V2E2QM1gVLKtNOWA7iwsfypgSULKi0AiiZ30M0DGtZi9hLyHzSGi0Aid24bs2)wVeuRURbSBar6pkTKU62pTKWPLl6(36s5KM9uX2Zwff3gVLKtNOWA7iwsfypgSUL8wdglIDalmflKLXcIqRHaSI6cdH92dumkuBjD1TFAjVjUhsIpK6E7bk2E2QQwB8wsoDIcRTJyjvG9yW6wsIqRHCPCsVjDpc43ekuJfYYybrO1qkqa6AgfQXcZybrO1qkqa6AgbpxrnwmGfZPYs6QB)0ssu(x3)w)M4oNSHK2ZwfLYgVLKtNOWA7iwsfypgSULKYyX5fopKceGUMrC6efwJfMXIXWc1)f9hLixkN0Bs3Ja(nHaSHVjelIflOvASWmwm9fj71FedWIkdyX4yHSmwO(VO)Oe5s5KEt6EeWVjeGn8nHyrLbSGcZIfJIfYYyXyyX5fopKceGUMrC6efwJfMXc1)f9hLifiaDnJaSHVjelIflOvASWmwm9fj71FedWIkdybfWczzSq9Fr)rjsbcqxZiaB4BcXIkdybfMflg1s6QB)0sshCGE9S)TUxDyWFt2Zwv1BJ3sYPtuyTDelPcShdw3sQ(VO)Oe5s5KEt6EeWVjeGn8nHyrSybTsJfMXIPVizV(JyawuzalghlKLXc1)f9hLifiaDnJaSHVjelIflOvASWmwm9fj71FedWIkdybfWczzSq9Fr)rjYLYj9M09iGFtiaB4BcXIkdybfMflKLXc1)f9hLifiaDnJaSHVjelQmGfuywlPRU9tlz0dkAP8MDad)0tfBpBvZPYgVLKtNOWA7iwsfypgSULCmSGYybWxDNLY5HCTgIykzHhelKLXcGV6olLZd5AneTjwublgNkSqwglG1CP0phqZhePxPBYD49adSOYawykwmkwyglgdlicTgYLYj9M09iGFti9hLyHSmwqeAnKceGUMr6pkXIrXcZyXyyH6)I(JserX1C)B9yeG3QyeGn8nHyrfSGwPXIyIfJJfMXc1)f9hLOye00gCEiaB4BcXIkybTsJfXelghlg1s6QB)0s2EvaY6UxDyWECNGDd7zRA(CB8wsoDIcRTJyjvG9yW6wYXWcIqRHCPCsVjDpc43ekuJfYYybrO1qkqa6AgfQXcZybrO1qkqa6AgbpxrnwmGfZPclgflmJftFrYE9hXaSi2bSyClPRU9tlPbB8aj7FRxcQv31a2nG2Zw1CtTXBj50jkS2oILub2JbRBjhdlOmwa8v3zPCEixRHiMsw4bXczzSa4RUZs58qUwdrBIfvWIXPclKLXcynxk9Zb08br6v6MChEpWalQmGfMIfJAjD1TFAjRdGTj5M0DIIdp7zRA(424TKC6efwBhXsQa7XG1TKeHwdTz1ew4E7NOqnwilJfugloVW5H2SAclCV9teNorH1wsxD7NwsxkN0Bs3Ja(nzpBvZPGnEljNorH12rSKkWEmyDl50xKSx)rmalQmGfuWs6QB)0sQabORz7zpl5b2KA(G24Tvn3gVLKtNOWA7iwsfypgSULCmSGi0AixkN0Bs3Ja(nHc1yHSmwqeAnKceGUMrHASyulz6gSLe4g1Bs3DJ6YEbn3PxAx6xUoN0BYwsxD7NwsGBuVjD3nQl7f0CNEPDPF56CsVjBpBvMAJ3sYPtuyTDelPcShdw3sszSGi0AixkN0Bs3Ja(nHc1yHzSGYybrO1qkqa6AgfQTKPBWwsAWN0WEnyn8sh40SL0v3(PLKg8jnSxdwdV0bonBpBvJBJ3sYPtuyTDelz6gSLe4vhDiPg2jw6oG1DIWDFAjD1TFAjbE1rhsQHDILUdyDNiC3N2ZwffSXBj50jkS2oILub2JbRBjjcTgYLYj9M09iGFtOqnwilJfeHwdPabORzuOglmJfeHwdPabORze8Cf1yXawmNklz6gSLmgmSp9rfgyjD1TFAjJbd7tFuHb2Zw1S24TKC6efwBhXsQa7XG1TKJHfeHwd5s5KEt6EeWVjuOglKLXcIqRHuGa01mkuJfMXcIqRHuGa01mcWg(MqSiwSyoLclgflKLXIXWc1)f9hLixkN0Bs3Ja(nHaSHVjelQGfJtfwilJfQ)l6pkrkqa6AgbydFtiwublgNkSyulz6gSLu66L(36EUg(X6or5FTL0v3(PLu66L(36EUg(X6or5FT9SvrXTXBj50jkS2oILub2JbRBjjcTgYLYj9M09iGFtOqnwilJfeHwdPabORzuOglmJfeHwdPabORzeGn8nHyrSyXCkLLmDd2sQ)3a2BbGKwsxD7Nws9)gWElaK0E2QQwB8wsoDIcRTJyjvG9yW6wsIqRHCPCsVjDpc43ekuJfYYybrO1qkqa6AgfQXcZybrO1qkqa6AgbydFtiwelwmFwlz6gSLK2lSYlfga7eStTL0v3(PLK2lSYlfga7eStT9SvrPSXBj50jkS2oILub2JbRBjjcTgYLYj9M09iGFtOqnwilJfeHwdPabORzuO2sMUbBjjKK(tUtWC3lgE6klPRU9tljHK0FYDcM7EXWtxzpBvvVnEljNorH12rSKkWEmyDl5yybLXcGV6olLZd5AneXuYcpiwilJfaF1DwkNhY1AiAtSOcwmFwSyuSqwglG1CP0phqZhePxPBYD49adSOYawyQLmDd2sAWaM6BYH9MN0wsxD7NwsdgWuFtoS38K2E2QMtLnEljNorH12rSKkWEmyDljrO1qUuoP3KUhb8BcfQXczzSGi0AifiaDnJc1yHzSGi0AifiaDnJGNROglQmGfZPclKLXc1)f9hLixkN0Bs3Ja(nHaSHVjelQGfuywSqwglOmwqeAnKceGUMrHASWmwO(VO)OePabORzeGn8nHyrfSGcZAjt3GTK1LqQzab7anS3koKAlPRU9tlzDjKAgqWoqd7TIdP2E2QMp3gVLKtNOWA7iwsfypgSULKi0AixkN0Bs3Ja(nHc1yHSmwqeAnKceGUMrHASWmwqeAnKceGUMrWZvuJfvgWI5uHfYYyH6)I(JsKlLt6nP7ra)Mqa2W3eIfvWckmlwilJfuglicTgsbcqxZOqnwyglu)x0FuIuGa01mcWg(MqSOcwqHzTKPBWwscgaza1ma2JrigblPRU9tljbdGmGAga7XieJG9Svn3uB8wsoDIcRTJyjvG9yW6wsIqRHCPCsVjDpc43ekuJfYYybrO1qkqa6AgfQXcZybrO1qkqa6AgbpxrnwuzalMtfwilJfQ)l6pkrUuoP3KUhb8BcbydFtiwublOWSyHSmwO(VO)OePabORzeGn8nHyrfSGcZAjt3GTKCQlme2VnvxaW9V1BaxD7NEPx)rmWs6QB)0sYPUWqy)2uDba3)wVbC1TF6LE9hXa7zRA(424TKC6efwBhXsQa7XG1TKeHwd5s5KEt6EeWVjuOglKLXcIqRHuGa01mkuJfMXcIqRHuGa01mcEUIASOYawmNklz6gSLSMDqPRxPma2vVrTdHwsxD7NwYA2bLUELYayx9g1oeApBvZPGnEljNorH12rSKkWEmyDljrO1qUuoP3KUhb8BcfQXczzSGi0AifiaDnJc1yHzSGi0AifiaDnJaSHVjelIDalMpRLmDd2s2wa86g(XWoSws6IdHwsxD7NwY2cGx3Wpg2H1ssxCi0E2QMpRnEljNorH12rSKkWEmyDljrO1qUuoP3KUhb8BcfQXczzSGi0AifiaDnJc1yHzSGi0AifiaDnJaSHVjelIDalmLklz6gSLmAAbLOnPH96sWWPzlPRU9tlz00ckrBsd71LGHtZ2Zw1CkUnEljNorH12rSKkWEmyDljrO1qUuoP3KUhb8BcfQXczzSGi0AifiaDnJc1yHzSGi0AifiaDnJaSHVjelIDalmLklz6gSLudyx3PlUE97bWoHRPzlPRU9tlPgWUUtxC963dGDcxtZ2Zw18Q1gVLKtNOWA7iwsfypgSULKi0AixkN0Bs3Ja(nHc1yHSmwqeAnKceGUMrHASWmwqeAnKceGUMra2W3eIfXoGfMsLLmDd2sQbSR7oSEbEEWUbR9sz)0s6QB)0sQbSR7oSEbEEWUbR9sz)0E2QMtPSXBj50jkS2oILub2JbRBjjcTgYLYj9M09iGFtOqnwilJfeHwdPabORzuOglmJfeHwdPabORze8Cf1yrLbSyovyHSmwO(VO)Oe5s5KEt6EeWVjeGn8nHyrfSyCQWczzSGYybrO1qkqa6AgfQXcZyH6)I(JsKceGUMra2W3eIfvWIXPYsMUbBjPo)R)TUNQLZR3cajTKU62pTKuN)1)w3t1Y51BbGK2Zw18Q3gVLKtNOWA7iwsfypgSULKi0AixkN0Bs3Ja(nHc1yHSmwqeAnKceGUMrHASWmwqeAnKceGUMrWZvuJfdyXCQSKU62pTKbi33JnG2ZEwsAozGFpaAJ3w1CB8wsoDIcRTJyj)AljKplPRU9tlPuhSorHTKs9sGTKJHfugloVW5HMCddg0)wpc43eItNOWASqwglohqZhAI9YnHQvhwuzalmLkSWmwmgwqeAnKlLt6nP7ra)Mq6pkXczzSGi0AifiaDnJ0FuIfJIfJAjL6GE6gSLKI5PyTNTktTXBj50jkS2oILub2JbRBjN(IK96pIbyrLbSywSqwglicTgYGnEGK9V1lb1Q7Aa7gquOglKLXcIqRHGmFtBs3bonJc1wsxD7NwsLxkDxD7N9YcplzzHxpDd2s22CHtmaApBvJBJ3sYPtuyTDelPcShdw3sogwqzSa4RUZs58qUwdrmLSWdIfYYybWxDNLY5HCTgI2elQGfZNflKLXcynxk9Zb08brro1C)BDhoXqSOYawykwmkwyglgdlM(IK96pIbyrSdybvyHSmwm9fj71FedWIbSyowyglu)x0FuIikUM7FRhJa8wfJaSHVjelQGf0knwmkwyglgdlu)x0FuICPCsVjDpc43ecWg(MqSOcwmNkSqwgloVW5HuGa01mItNOWASWmwO(VO)OePabORzeGn8nHyrfSyovyXOwsxD7NwYiNAU)TUdNyO9SvrbB8wsoDIcRTJyjvG9yW6wYPVizV(Jyawe7awykwilJfJHftFrYE9hXaSyalghlmJfJHfQ)l6pkrtUHbd6FRhb8BcbydFtiwublOvASiMyHPyHSmwi1bRtuyefZtXIfJIfJAjD1TFAjjkUM7FRhJa8wfBpBvZAJ3sYPtuyTDelPcShdw3so9fj71FedWIyhWctXczzSymSy6ls2R)igGfXoGfualmJfJHfQ)l6pkrefxZ9V1JraERIra2W3eIfvWcALglIjwykwilJfsDW6efgrX8uSyXOyXOwsxD7NwYye00gCE2Zwff3gVLKtNOWA7iwsfypgSULC6ls2R)igGfXoGfuWs6QB)0so5ggmO)TEeWVj7zRQATXBj50jkS2oILub2JbRBjN(IK96pIbyrSdyHPyHSmwm9fj71FedWIyhWIXXcZyH6)I(JserX1C)B9yeG3QyeGn8nHyrfSGwPXIyIfMIfYYyX0xKSx)rmalgWckGfMXc1)f9hLiIIR5(36XiaVvXiaB4BcXIkybTsJfXelmflmJfQ)l6pkrXiOPn48qa2W3eIfvWcALglIjwyQL0v3(PLu9jKva)2pTNTkkLnEljNorH12rSKkWEmyDl55fop0KByWG(36ra)MqC6efwJfMXIXWIZb08HMyVCtOA1HfXoGfMsfwilJfeHwd5s5KEt6EeWVjuOglKLXcIqRHuGa01mkuJfJAjD1TFAjvEP0D1TF2ll8SKLfE90nylzBZfoXaO9Svv924TKC6efwBhXsQa7XG1TKQ)l6pkrkqa6Ag0HhyPMrQjhqZWEd4QB)0lyrLbSyoQANflmJfJHftFrYE9hXaSi2bSWuSqwglM(IK96pIbyrSdyX4yHzSq9Fr)rjIO4AU)TEmcWBvmcWg(MqSOcwqR0yrmXctXczzSy6ls2R)igGfdybfWcZyH6)I(JserX1C)B9yeG3QyeGn8nHyrfSGwPXIyIfMIfMXc1)f9hLOye00gCEiaB4BcXIkybTsJfXelmflmJfQ)l6pkrQpHSc43(jcWg(MqSOcwqR0yrmXctXIrTKU62pTKkqa6Ag0HhyPMTNTQ5uzJ3sYPtuyTDelPRU9tlPYlLURU9ZEzHNLSSWRNUbBjBBUWjgaTNTQ5ZTXBjD1TFAjvFQ48a(X6ER4gSLKtNOWA7i2Zw1CtTXBj50jkS2oILub2JbRBjN(IK96pIbyrSdybfSKU62pTKkqa6Ag0HhyPMTNTQ5JBJ3sYPtuyTDelPcShdw3so9fj71FedWIyhWckyjD1TFAjDGYtUFpaW5zp7zjBBUWjgaTXBRAUnEljNorH12rSKFTLeYNL0v3(PLuQdwNOWwsPEjWwsynxk9Zb08br6v6MChEpWalQmGfMIfMXckJfNx48qGLE64pa7szGEvhItNOWASqwglG1CP0phqZhePxPBYD49adSOYawmowygloVW5Hal90XFa2LYa9QoeNorH1wsPoONUbBj1WUYHNtuy7zRYuB8wsoDIcRTJyjvG9yW6wsIqRH2SAclCV9tK(JsSqwglicTgAZQjSW92pra2W3eIfXIfZIfMXIPVizV(JyawuzalghlKLXIZlCEiMsyv42p7qopovmItNOWASWmwO(VO)OeXucRc3(zhY5XPIra2W3eIfXIfZPclmJfeHwdTz1ew4E7NiaB4BcXIyXI5ZIfYYyH6)I(JsKlLt6nP7ra)Mqa2W3eIfXIfZNflmJfeHwdTz1ew4E7NiaB4BcXIyXctPclmJftFrYE9hXaSOYawmUL0v3(PLCZQjSW92pTNTQXTXBj50jkS2oILub2JbRBjH1CP0phqZhePxPBYD49adSi2bSWuSWmwmgwqzS48cNhsbcqxZioDIcRXcZyH6)I(JsKlLt6nP7ra)Mqa2W3eIfvWI5uHfYYyX5fopKceGUMrC6efwJfMXcIqRHuGa01ms)rjwyglu)x0FuIuGa01mcWg(MqSOcwmNkSqwglicTgsbcqxZi45kQXIkdyr1IfJAjD1TFAjzkHvHB)Sd584uX2ZwffSXBj50jkS2oILub2JbRBjL6G1jkmsd7khEorHXcZyXyybLXIZlCEifiaDnJ40jkSglKLXc1)f9hLifiaDnJaSHVjelQGf0knwetSWuSyuSqwglicTgInQLeWE2R)igGc1yHzSqZeHwdfJGM2GZdP)OelmJfeHwdPxPBY96aO(Hms)rPL0v3(PLuVs3K7W7bg2Zw1S24TKC6efwBhXsQa7XG1TKJHfugloVW5HuGa01mItNOWASWmwO(VO)Oe5s5KEt6EeWVjeGn8nHyrfSGwPXIyIfJJfYYyH6)I(JsKceGUMra2W3eIfvWcALglIjwmowmkwyglgdlOmwCEHZdXucRc3(zhY5XPIrC6efwJfYYyH6)I(JsetjSkC7NDiNhNkgbydFtiwublOvASiMyHPyHSmwO(VO)Oe5s5KEt6EeWVjeGn8nHyrfSGwPXIyIfJJfMXc1)f9hLixkN0Bs3Ja(nHaSHVjelIflMtfwilJfeHwdPabORzuOglmJfeHwdPabORze8Cf1yrSyXCQWIrTKU62pTKhBuxCaSlLb6vD2ZE2ZE2ZAb]] )


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
