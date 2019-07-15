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


    spec:RegisterPack( "Retribution", 20190712.2330, [[duegqbqicupsrvAtcyusuoLePvjq8kfvMLG4wei0UG6xsunmIIJPOSmIsptIyAeGRraTnfvX3uGY4uGW5uGQ1PaPMNG09uO9jOoibc0cvq9qfiHlQaj1ijqKtQajALcu7ubzOeiGLsGGEkHMQc4Qkqs(kbIAVc9xPAWiomvlgjpMKjtQlJAZs6Zi1OvKtR0Qfi9AIkZwk3Mc7w0Vvz4s44eiTCGNdz6Q66uA7e03POXROQoprvRxbIMpr2pOJZIdef1(ZXHKvMzdUmd2mzXYwsjYkGblk(YxWrXcxjNtZrX0n4OOGq(blL93lJIfU8TZ1XbIIOZcuCuC6)c0GU8YP3FYsHvNr5O1W28FVub86xoAnuLhfPSB7huMrQOO2FooKSYmBWLzWMjlw2skrwbefrfSko0GjtuCA1AoJurrnJurX5fseeYpyPS)EjKiiG3C9MWGNxiz6)c0GU8YP3FYsHvNr5O1W28FVub86xoAnuLddEEHKGTn5HKzYgcKiRmZgCirqesKTKbDjYadgg88cjdkM8KMrdAyWZlKiicjdQk0(ZAiPEaizqGLfhflaxDBCuCEHebH8dwk7Vxcjcc4nxVjm45fsM(VanOlVC69NSuy1zuoAnSn)3lvaV(LJwdv5WGNxijyBtEizMSHajYkZSbhseeHezlzqxImWGNxizqXKN0mAqddEEHebrizqvH2Fwdj1dajdcSSyyWWGNxizq98zL9znKqX1dWqI6mO8hsOy6nryirqqLIlEeKKxkio5aJQTbjU63lrqYLn5XWGD1VxIWfawDgu(pwBosoyWU63lr4caRodk)NBS86DAyWU63lr4caRodk)NBSC3sBW57)Ejm45fsetVanDpKa8vdju2AL1qc69hbjuC9amKOodk)HekMEteK4PgskaSGyX9)M0qYIGe9LmggSR(9seUaWQZGY)5glhLEbA6(o69hbd2v)Ejcxay1zq5)CJLxC)Ejmyx97LiCbGvNbL)ZnwUduEY9)aao)q26OGFVX5JnD54(v7oAIryoDQgRHbddEEHKb1ZNv2N1qclKbYdj)AWqYpXqIR(dajlcsCH(2CQgJHb7QFVencykRCmmyx97LO5glx5Tw3v)EzVTOpK0n4r1Dn9zMiyWU63lrZnwUYBTUR(9YEBrFiPBWJ0CYa)pacgmmyx97Li8d2uo(rJwe33NncjDdEe4gfBs3DJI2(wn3PxAx41(oN0BYHS1XYOS1k2fYj9M0DtG)tyBHKeLTwXkGf5AgBlkfgSR(9se(bBkh)O5gl3I4((SriPBWJ0GlPr9cWA4ToWP5q26OGPS1k2fYj9M0DtG)tyBrabtzRvScyrUMX2cyWU63lr4hSPC8JMBSClI77ZgHKUbpc8bP2MYH6ulDhW6oL9)lHb7QFVeHFWMYXpAUXYTiUVpBes6g8yqzuF6mBmiKToszRvSlKt6nP7Ma)NW2cjjkBTIvalY1m2weGYwRyfWICnJrVRKBCMmWGD1VxIWpyt54hn3y5we33NncjDdEu46T(v7EUg(Z6ov7oDiBDSmkBTIDHCsVjD3e4)e2wijrzRvScyrUMX2Iau2AfRawKRzmGn8nrHoBquQKuzQ7A6ZmXUqoP3KUBc8FcdydFtu4sKrssDxtFMjwbSixZyaB4BIcxImLcd2v)Ejc)GnLJF0CJLBrCFF2iK0n4r9DgOE1cKpKToszRvSlKt6nP7Ma)NW2cjjkBTIvalY1m2weGYwRyfWICnJbSHVjk0zdcyWU63lr4hSPC8JMBSClI77ZgHKUbps7nw5TgdqDk2LlKToszRvSlKt6nP7Ma)NW2cjjkBTIvalY1m2weGYwRyfWICnJbSHVjk0zcegSR(9se(bBkh)O5gl3I4((SriPBWJuYtFj3PyU7ndpDviBDKYwRyxiN0Bs3nb(pHTfssu2AfRawKRzSTagSR(9se(bBkh)O5gl3I4((SriPBWJgmGL7NCuV6jDiBDSmbd8v3zHC(yxRryE(l6rssaF1DwiNp21AeEZWZeyPssOcU16VdO5hH1RWn5o6pGr4rzHb7QFVeHFWMYXpAUXYTiUVpBes6g8yrZMAgqXoqJ61MJKlKToszRvSlKt6nP7Ma)NW2cjjkBTIvalY1m2weGYwRyfWICnJrVRKl84mzKKu310NzIDHCsVjD3e4)egWg(MOWcqGsscMYwRyfWICnJTfbu310NzIvalY1mgWg(MOWcqGWGD1VxIWpyt54hn3y5we33NncjDdEKIbigihdq9GAdQnKToszRvSlKt6nP7Ma)NW2cjjkBTIvalY1m2weGYwRyfWICnJrVRKl84mzKKu310NzIDHCsVjD3e4)egWg(MOWcqGsscMYwRyfWICnJTfbu310NzIvalY1mgWg(MOWcqGWGD1VxIWpyt54hn3y5we33NncjDdEKtDJrO(VP6TaUF1Ef4QFV0B9IZKbHS1rkBTIDHCsVjD3e4)e2wijrzRvScyrUMX2Iau2AfRawKRzm6DLCHhNjJKK6UM(mtSlKt6nP7Ma)NWa2W3efwacussDxtFMjwbSixZyaB4BIclabcd2v)Ejc)GnLJF0CJLBrCFF2iK0n4Xc2bTUEfYauxDgfocfYwhPS1k2fYj9M0DtG)tyBHKeLTwXkGf5AgBlcqzRvScyrUMXO3vYfECMmWGD1VxIWpyt54hn3y5we33NncjDdESUa03n8NrDuH80nhHczRJu2Af7c5KEt6UjW)jSTqsIYwRyfWICnJTfbOS1kwbSixZyaB4BIcDCMaHb7QFVeHFWMYXpAUXYTiUVpBes6g8O50cAMBsJ6fnRHtZHS1rkBTIDHCsVjD3e4)e2wijrzRvScyrUMX2Iau2AfRawKRzmGn8nrHokRmWGD1VxIWpyt54hn3y5we33NncjDdEudyx3PBUE9)aOoLRP5q26iLTwXUqoP3KUBc8FcBlKKOS1kwbSixZyBrakBTIvalY1mgWg(MOqhLvgyWU63lr4hSPC8JMBSClI77ZgHKUbpQbSR7oQybE(OUbR9wBVmKToszRvSlKt6nP7Ma)NW2cjjkBTIvalY1m2weGYwRyfWICnJbSHVjk0rzLbgSR(9se(bBkh)O5gl3I4((SriPBWJYL33VA3t1Y53RwG8HS1rkBTIDHCsVjD3e4)e2wijrzRvScyrUMX2Iau2AfRawKRzm6DLCHhNjJKK6UM(mtSlKt6nP7Ma)NWa2W3efUezKKemLTwXkGf5AgBlcOURPpZeRawKRzmGn8nrHlrgyWU63lr4hSPC8JMBSClI77ZgOq26iLTwXUqoP3KUBc8FcBlKKOS1kwbSixZyBrakBTIvalY1mg9UsUXzYadggSR(9sewDxtFMjAS4(9Yq26yzQ7A6ZmX0whOxp7xT7dsgC)egWg(MOWdUmsscMriovmwDPMteR7TTY1dOySHh0duAGYOS1kMQDNUzrpgWU6LKOS1k2fYj9M0DtG)tyBHKeLTwXkGf5AgBlcqzRvScyrUMXa2W3efQScSuyWU63lry1Dn9zMO5glVT0tpQhuRM2GZpKToIk4wR)oGMFeUT0tpQhuRM2GZp8OSssLjyGV6olKZh7AncZZFrpssc4RUZc58XUwJWBgEWeyPWGD1VxIWQ7A6ZmrZnwEDbmv7oDiBDKYwRyxiN0Bs3nb(pHTfssu2AfRawKRzSTiaLTwXkGf5AgJExj34mzGb7QFVeHv310NzIMBSC00YnD)QDHCsZEQ4q26iLTwXiM)PnP7aNMX6ZmdqzRvSbBCa57xT3SQv31a2nqy9zMWGD1VxIWQ7A6ZmrZnwUfX99zJqs3GhbUrXM0D3OOTVvZD6L2fETVZj9MCiBDSmkBTIDHCsVjD3e4)e2wijrzRvScyrUMX2IsHb7QFVeHv310NzIMBSClI77ZgOq26iLTwXUqoP3KUBc8FcBlKKOS1kwbSixZyBbmyx97LiS6UM(mt0CJL)tC3MuNn196buCiBD8xdo0rzLKOS1kgWk5Amc1RhqXyBbmyx97LiS6UM(mt0CJLt1Ut3VA)N4oNSH8HS1rkBTIDHCsVjD3e4)e2wijrzRvScyrUMX2Iau2AfRawKRzm6DLCJZKbgSR(9sewDxtFMjAUXYPToqVE2VA3hKm4(Pq26OGFVX5JvalY1mMtNQX6aLPURPpZe7c5KEt6UjW)jmGn8nrHkWatxt(EXzYGWJLeOmkBTI3uqTlA)9sSTqssWV348XBkO2fT)EjMtNQX6sLKu310NzIDHCsVjD3e4)egWg(MOWJcqGLkjv27noFScyrUMXC6unwhqDxtFMjwbSixZyaB4BIcLwPdmDn57fNjdcpkajPPRjFV4mzq4Xsc8Rbh6mzc8EJZhB6YX9R2D0eJWC6unwljPURPpZeRawKRzmGn8nrHhfGalfgSR(9sewDxtFMjAUXYnpqtlK3Sdy0LEQ4q26O6UM(mtSlKt6nP7Ma)NWa2W3efkTshy6AY3lotgeESejj1Dn9zMyfWICnJbSHVjkuALoW01KVxCMmi8OaKKu310NzIDHCsVjD3e4)egWg(MOWJcqGssQ7A6ZmXkGf5AgdydFtu4rbiqyWU63lry1Dn9zMO5glVEklI1DFqYG95of7gHS1XYemWxDNfY5JDTgH55VOhjjb8v3zHC(yxRr4ndxImssOcU16VdO5hH1RWn5o6pGr4rzlnqzu2Af7c5KEt6UjW)jS(mtjjkBTIvalY1mwFMzPbktDxtFMjMQ5AUF1EqTOFvmgWg(MOW0kDqkjG6UM(mtCqTAAdoFmGn8nrHPv6GusPWGD1VxIWQ7A6ZmrZnwUbBCa57xT3SQv31a2nqHS1XYOS1k2fYj9M0DtG)tyBHKeLTwXkGf5AgBlcqzRvScyrUMXO3vYnotMsdmDn57fNjdcDSeyWU63lry1Dn9zMO5glVWc2Q8Bs3PAo6dzRJLjyGV6olKZh7AncZZFrpssc4RUZc58XUwJWBgUezKKqfCR1FhqZpcRxHBYD0FaJWJYwkmyx97LiS6UM(mt0CJL7c5KEt6UjW)Pq26yzc(9gNpEtb1UO93lXC6unwljrzRv8McQDr7VxITfLgy6AY3lotgeESeyWU63lry1Dn9zMO5glxbSixZHS1XPRjFV4mzq4rbijnDn57fNjdcpwsGFn4qNjtG3BC(ytxoUF1UJMyeMtNQXAyWWGD1VxIW1nx0edqJcDW6unoK0n4rZnPr9I7AHi0BwEuWSGA3IcwJNnpdEjZeqGYe87noFScyrUMXC6unwhqDxtFMj2fYj9M0DtG)tyaB4BIctR0bPejj1Dn9zMyfWICnJbSHVjkmTshKskvsIfu7wuWA8S5zWlzMacuMGFVX5JvalY1mMtNQX6aQ7A6ZmXUqoP3KUBc8FcdydFtuyALoiZJKK6UM(mtScyrUMXa2W3efMwPdY8ukmyx97LiCDZfnXa0CJLl0bRt14qs3Gh1OUYrVt14qe6nlpIk4wR)oGMFewVc3K7O)agHhLnGGFVX5Jbl90ZNf1fYa9QEmNovJ1ssOcU16VdO5hH1RWn5o6pGr4Xsc8EJZhdw6PNplQlKb6v9yoDQgRLKOS1kMnkKhWE2lotgGTfb0mLTwXb1QPn48X6ZmdqzRvSEfUj3lSGIdXy9zMbOS1k2fYj9M0DtG)tD3(NcSpwFMjmyx97LiCDZfnXa0CJLVPGAx0(7LHS1rkBTIDHCsVjD3e4)ewFMzGYOS1kEtb1UO93lX6ZmLKOS1kEtb1UO93lXa2W3ef6GiW01KVxCMmi8yjssV348X88zL93l7ioFovmMtNQX6aQ7A6ZmX88zL93l7ioFovmgWg(MOqNjtakBTI3uqTlA)9smGn8nrHotGssQ7A6ZmXUqoP3KUBc8FcdydFtuOZeyakBTI3uqTlA)9smGn8nrHkRmbMUM89IZKbHhlPuyWU63lr46MlAIbO5glNNpRS)EzhX5ZPIdzRJOcU16VdO5hH1RWn5o6pGrOJYgOmb)EJZhRawKRzmNovJ1bu310NzIDHCsVjD3e4)egWg(MOWZKrs69gNpwbSixZyoDQgRdqzRvScyrUMX6ZmdOURPpZeRawKRzmGn8nrHNjJKeLTwXkGf5AgJExjx4XbRuyWU63lr46MlAIbO5glxVc3K7O)agHS1rHoyDQgJ1OUYrVt14acDW6ungBUjnQxCxlqzLj43BC(yE(SY(7LDeNpNkgZPt1yTKuzOcU16VdO5hH1RWn5o6pGr4rzLKu310NzI55Zk7Vx2rC(CQymGn8nrHPv6GiBPLkjvM6UM(mtSlKt6nP7Ma)NWa2W3efMwPdsjbu310NzIDHCsVjD3e4)egWg(MOqNjJKK6UM(mtScyrUMXa2W3efMwPdsjbu310NzIvalY1mgWg(MOqNjJKeLTwXkGf5AgBlcqzRvScyrUMXO3vYf6mzkTuyWU63lr46MlAIbO5gl)zJIMdqDHmqVQpKTok0bRt1yS5M0OEXDTaLj43BC(yE(SY(7LDeNpNkgZPt1yTKK6UM(mtmpFwz)9YoIZNtfJbSHVjkmTshezLKu310NzIDHCsVjD3e4)egWg(MOW0kDqkjG6UM(mtSlKt6nP7Ma)NWa2W3ef6mzKKu310NzIvalY1mgWg(MOW0kDqkjG6UM(mtScyrUMXa2W3ef6mzKKOS1kwbSixZyBrakBTIvalY1mg9UsUqNjtPWGHb7QFVeHP5Kb(Fa0OqhSovJdjDdEuq6eKdrO3S8yzc(9gNpEYnmyq)QDtG)tyoDQgRLKEhqZpEI92pHluF4rzLjqzu2Af7c5KEt6UjW)jS(mtjjkBTIvalY1mwFMzPLcd2v)EjctZjd8)aO5glx5Tw3v)EzVTOpK0n4X6MlAIbOq26401KVxCMmi8OaLKOS1k2GnoG89R2Bw1Q7Aa7giSTqsIYwRyeZ)0M0DGtZyBHKeLTwXBkO2fT)EjwFMzGPRjFV4mzq4XsGb7QFVeHP5Kb(Fa0CJLB6YX9R2D0eJczRJLjyGV6olKZh7AncZZFrpssc4RUZc58XUwJWBgEMaLKqfCR1FhqZpcB6YX9R2D0eJcpkBPbkB6AY3lotge6Omsstxt(EXzYGXzbu310NzIPAUM7xThul6xfJbSHVjkmTsxAGYu310NzIDHCsVjD3e4)egWg(MOWZKrs69gNpwbSixZyoDQgRdOURPpZeRawKRzmGn8nrHNjtPWGD1VxIW0CYa)paAUXYPAUM7xThul6xfhYwhNUM89IZKbHokRKuztxt(EXzYGXscuM6UM(mt8KByWG(v7Ma)NWa2W3efMwPdISsscDW6ungliDcYLwkmyx97LimnNmW)dGMBS8GA10gC(HS1XPRjFV4mzqOJYkjv201KVxCMmi0rbeOm1Dn9zMyQMR5(v7b1I(vXyaB4BIctR0brwjjHoyDQgJfKob5slfgSR(9seMMtg4)bqZnw(KByWG(v7Ma)NczRJtxt(EXzYGqhfamyx97LimnNmW)dGMBSC1Liwb8FVmKTooDn57fNjdcDuwjPPRjFV4mzqOJLeqDxtFMjMQ5AUF1EqTOFvmgWg(MOW0kDqKvsA6AY3lotgmkGaQ7A6ZmXunxZ9R2dQf9RIXa2W3efMwPdISbu310NzIdQvtBW5JbSHVjkmTshezHb7QFVeHP5Kb(Fa0CJLR8wR7QFVS3w0hs6g8yDZfnXauiBD89gNpEYnmyq)QDtG)tyoDQgRd8oGMF8e7TFcxO(qhLvgjjkBTIDHCsVjD3e4)e2wijrzRvScyrUMX2cyWU63lryAozG)han3y5kGf5Ag0rpyLJdzRJQ7A6ZmXkGf5Ag0rpyLJXQjhqZOEf4QFV0BHhNHhmbgOSPRjFV4mzqOJYkjnDn57fNjdcDSKaQ7A6ZmXunxZ9R2dQf9RIXa2W3efMwPdISsstxt(EXzYGrbeqDxtFMjMQ5AUF1EqTOFvmgWg(MOW0kDqKnG6UM(mtCqTAAdoFmGn8nrHPv6GiBa1Dn9zMy1Liwb8FVedydFtuyALoiYwkmyx97LimnNmW)dGMBSCL3ADx97L92I(qs3GhRBUOjgGGb7QFVeHP5Kb(Fa0CJLRUuX5d8N19AZnyyWU63lryAozG)han3y5kGf5Ag0rpyLJdzRJtxt(EXzYGqhfamyx97LimnNmW)dGMBSChO8K7)baC(HS1XPRjFV4mzqOJcikkKbO9Y4qYkZSbxMbBMSyzKracmkA6GCtAuuCqPrXbEwdjZdK4QFVesAl6ryyWrX2IEuCGOOMRUT9XbIdnloqu0v)EzueWuw54OiNovJ1XHJFCizJdef50PASooCu0v)Ezuu5Tw3v)EzVTOpk2w03t3GJIQ7A6ZmrXpoujXbIIC6unwhhok6QFVmkQ8wR7QFVS3w0hfBl67PBWrrAozG)haf)4hflaS6mO8poqCOzXbIIC6unwhho(XHKnoquKtNQX64WXpoujXbIIC6unwhho(XHeqCGOiNovJ1XHJFCibghik6QFVmkwC)EzuKtNQX64WXpo08ehikYPt1yDC4OOcSpdwpkkyi59gNp20LJ7xT7OjgH50PASok6QFVmk6aLNC)paGZp(XpkQURPpZefhio0S4arroDQgRJdhfvG9zW6rXYGe1Dn9zMyARd0RN9R29bjdUFcdydFteKegsgCzGejjirWqcJqCQyS6snNiw3BBLRhqXydpOhaskfscajLbju2Aft1Ut3SOhdyx9qIKeKqzRvSlKt6nP7Ma)NW2cirscsOS1kwbSixZyBbKeasOS1kwbSixZyaB4BIGKqHezfiKuAu0v)EzuS4(9Y4hhs24arroDQgRJdhfvG9zW6rrub3A93b08JWTLE6r9GA10gC(qs4rirwirscskdsemKa8v3zHC(yxRryE(l6rqIKeKa8v3zHC(yxRr4nHKWqYGjqiP0OOR(9YOyBPNEupOwnTbNF8JdvsCGOiNovJ1XHJIkW(my9OiLTwXUqoP3KUBc8FcBlGejjiHYwRyfWICnJTfqsaiHYwRyfWICnJrVRKdsgHKzYefD1VxgfRlGPA3PJFCibehikYPt1yDC4OOcSpdwpkszRvmI5FAt6oWPzS(mtijaKqzRvSbBCa57xT3SQv31a2nqy9zMrrx97Lrr00YnD)QDHCsZEQ44hhsGXbIIC6unwhhok6QFVmkcCJInP7UrrBFRM70lTl8AFNt6n5OOcSpdwpkwgKqzRvSlKt6nP7Ma)NW2cirscsOS1kwbSixZyBbKuAumDdokcCJInP7UrrBFRM70lTl8AFNt6n54hhAEIdef50PASooCuub2NbRhfPS1k2fYj9M0DtG)tyBbKijbju2AfRawKRzSTik6QFVmkArCFF2af)4qdwCGOiNovJ1XHJIkW(my9O4VgmKe6iKilKijbju2AfdyLCngH61dOySTik6QFVmk(tC3MuNn196buC8JdniIdef50PASooCuub2NbRhfPS1k2fYj9M0DtG)tyBbKijbju2AfRawKRzSTascaju2AfRawKRzm6DLCqYiKmtMOOR(9YOiv7oD)Q9FI7CYgYh)4qdECGOiNovJ1XHJIkW(my9OOGHK3BC(yfWICnJ50PASgscajLbjQ7A6ZmXUqoP3KUBc8FcdydFteKekKiqijaKmDn57fNjdGKWJqsjqsaiPmiHYwR4nfu7I2FVeBlGejjirWqY7noF8McQDr7VxI50PASgskfsKKGe1Dn9zMyxiN0Bs3nb(pHbSHVjcscpcjcqGqsPqIKeKugK8EJZhRawKRzmNovJ1qsairDxtFMjwbSixZyaB4BIGKqHeALgscajtxt(EXzYaij8iKiairscsMUM89IZKbqs4riPeijaK8RbdjHcjZKbscajV348XMUCC)QDhnXimNovJ1qIKeKOURPpZeRawKRzmGn8nrqs4riracesknk6QFVmksBDGE9SF1UpizW9tXpo0mzIdef50PASooCuub2NbRhfv310NzIDHCsVjD3e4)egWg(MiijuiHwPHKaqY01KVxCMmascpcjLajssqI6UM(mtScyrUMXa2W3ebjHcj0knKeasMUM89IZKbqs4riraqIKeKOURPpZe7c5KEt6UjW)jmGn8nrqs4riracesKKGe1Dn9zMyfWICnJbSHVjcscpcjcqGrrx97LrrZd00c5n7agDPNko(XHMnloquKtNQX64WrrfyFgSEuSmirWqcWxDNfY5JDTgH55VOhbjssqcWxDNfY5JDTgH3escdjLidKijbjOcU16VdO5hH1RWn5o6pGbKeEesKfskfscajLbju2Af7c5KEt6UjW)jS(mtirscsOS1kwbSixZy9zMqsPqsaiPmirDxtFMjMQ5AUF1EqTOFvmgWg(MiijmKqR0qsqGKsGKaqI6UM(mtCqTAAdoFmGn8nrqsyiHwPHKGajLajLgfD1VxgfRNYIyD3hKmyFUtXUr8Jdnt24arroDQgRJdhfvG9zW6rXYGekBTIDHCsVjD3e4)e2wajssqcLTwXkGf5AgBlGKaqcLTwXkGf5AgJExjhKmcjZKbskfscajtxt(EXzYaij0riPKOOR(9YOObBCa57xT3SQv31a2nqXpo0SsIdef50PASooCuub2NbRhfldsemKa8v3zHC(yxRryE(l6rqIKeKa8v3zHC(yxRr4nHKWqsjYajssqcQGBT(7aA(ry9kCtUJ(dyajHhHezHKsJIU63lJIfwWwLFt6ovZrF8JdntaXbIIC6unwhhokQa7ZG1JILbjcgsEVX5J3uqTlA)9smNovJ1qIKeKqzRv8McQDr7VxITfqsPqsaiz6AY3lotgajHhHKsIIU63lJIUqoP3KUBc8Fk(XHMjW4arroDQgRJdhfvG9zW6rXPRjFV4mzaKeEeseaKijbjtxt(EXzYaij8iKucKeas(1GHKqHKzYajbGK3BC(ytxoUF1UJMyeMtNQX6OOR(9YOOcyrUMJF8JIpyt54hfhio0S4arroDQgRJdhfD1VxgfbUrXM0D3OOTVvZD6L2fETVZj9MCuub2NbRhfldsOS1k2fYj9M0DtG)tyBbKijbju2AfRawKRzSTasknkMUbhfbUrXM0D3OOTVvZD6L2fETVZj9MC8JdjBCGOiNovJ1XHJIU63lJI0GlPr9cWA4ToWP5OOcSpdwpkkyiHYwRyxiN0Bs3nb(pHTfqsairWqcLTwXkGf5AgBlIIPBWrrAWL0OEbyn8wh40C8JdvsCGOiNovJ1XHJIPBWrrGpi12uouNAP7aw3PS)Fzu0v)Ezue4dsTnLd1Pw6oG1Dk7)xg)4qcioquKtNQX64Wrrx97LrXGYO(0z2yquub2NbRhfPS1k2fYj9M0DtG)tyBbKijbju2AfRawKRzSTascaju2AfRawKRzm6DLCqYiKmtMOy6gCumOmQpDMnge)4qcmoquKtNQX64Wrrx97LrrHR36xT75A4pR7uT70rrfyFgSEuSmiHYwRyxiN0Bs3nb(pHTfqIKeKqzRvScyrUMX2cijaKqzRvScyrUMXa2W3ebjHcjZgeqsPqIKeKugKOURPpZe7c5KEt6UjW)jmGn8nrqsyiPezGejjirDxtFMjwbSixZyaB4BIGKWqsjYajLgft3GJIcxV1VA3Z1WFw3PA3PJFCO5joquKtNQX64Wrrx97Lrr9DgOE1cKpkQa7ZG1JIu2Af7c5KEt6UjW)jSTasKKGekBTIvalY1m2wajbGekBTIvalY1mgWg(Miijuiz2GikMUbhf13zG6vlq(4hhAWIdef50PASooCu0v)EzuK2BSYBngG6uSlxuub2NbRhfPS1k2fYj9M0DtG)tyBbKijbju2AfRawKRzSTascaju2AfRawKRzmGn8nrqsOqYmbgft3GJI0EJvERXauNID5IFCObrCGOiNovJ1XHJIU63lJIuYtFj3PyU7ndpDvuub2NbRhfPS1k2fYj9M0DtG)tyBbKijbju2AfRawKRzSTikMUbhfPKN(sUtXC3BgE6Q4hhAWJdef50PASooCu0v)Ezu0GbSC)KJ6vpPJIkW(my9OyzqIGHeGV6olKZh7AncZZFrpcsKKGeGV6olKZh7AncVjKegsMjqiPuirscsqfCR1FhqZpcRxHBYD0Fadij8iKiBumDdokAWawUFYr9QN0Xpo0mzIdef50PASooCu0v)EzuSOztndOyhOr9AZrYffvG9zW6rrkBTIDHCsVjD3e4)e2wajssqcLTwXkGf5AgBlGKaqcLTwXkGf5AgJExjhKeEesMjdKijbjQ7A6ZmXUqoP3KUBc8FcdydFteKegseGaHejjirWqcLTwXkGf5AgBlGKaqI6UM(mtScyrUMXa2W3ebjHHebiWOy6gCuSOztndOyhOr9AZrYf)4qZMfhikYPt1yDC4OOR(9YOifdqmqogG6b1guBuub2NbRhfPS1k2fYj9M0DtG)tyBbKijbju2AfRawKRzSTascaju2AfRawKRzm6DLCqs4rizMmqIKeKOURPpZe7c5KEt6UjW)jmGn8nrqsyiracesKKGebdju2AfRawKRzSTascajQ7A6ZmXkGf5AgdydFteKegseGaJIPBWrrkgGyGCma1dQnO24hhAMSXbIIC6unwhhok6QFVmkYPUXiu)3u9wa3VAVcC1Vx6TEXzYGOOcSpdwpkszRvSlKt6nP7Ma)NW2cirscsOS1kwbSixZyBbKeasOS1kwbSixZy07k5GKWJqYmzGejjirDxtFMj2fYj9M0DtG)tyaB4BIGKWqIaeiKijbjQ7A6ZmXkGf5AgdydFteKegseGaJIPBWrro1ngH6)MQ3c4(v7vGR(9sV1lotge)4qZkjoquKtNQX64Wrrx97LrXc2bTUEfYauxDgfocffvG9zW6rrkBTIDHCsVjD3e4)e2wajssqcLTwXkGf5AgBlGKaqcLTwXkGf5AgJExjhKeEesMjtumDdokwWoO11RqgG6QZOWrO4hhAMaIdef50PASooCu0v)EzuSUa03n8NrDuH80nhHIIkW(my9OiLTwXUqoP3KUBc8FcBlGejjiHYwRyfWICnJTfqsaiHYwRyfWICnJbSHVjcscDesMjWOy6gCuSUa03n8NrDuH80nhHIFCOzcmoquKtNQX64Wrrx97LrrZPf0m3Kg1lAwdNMJIkW(my9OiLTwXUqoP3KUBc8FcBlGejjiHYwRyfWICnJTfqsaiHYwRyfWICnJbSHVjcscDesKvMOy6gCu0CAbnZnPr9IM1WP54hhA28ehikYPt1yDC4OOR(9YOOgWUUt3C96)bqDkxtZrrfyFgSEuKYwRyxiN0Bs3nb(pHTfqIKeKqzRvScyrUMX2cijaKqzRvScyrUMXa2W3ebjHocjYktumDdokQbSR70nxV(FauNY10C8JdnBWIdef50PASooCu0v)Ezuudyx3DuXc88rDdw7T2Ezuub2NbRhfPS1k2fYj9M0DtG)tyBbKijbju2AfRawKRzSTascaju2AfRawKRzmGn8nrqsOJqISYeft3GJIAa76UJkwGNpQBWAV12lJFCOzdI4arroDQgRJdhfD1VxgfLlVVF1UNQLZVxTa5JIkW(my9OiLTwXUqoP3KUBc8FcBlGejjiHYwRyfWICnJTfqsaiHYwRyfWICnJrVRKdscpcjZKbsKKGe1Dn9zMyxiN0Bs3nb(pHbSHVjcscdjLidKijbjcgsOS1kwbSixZyBbKeasu310NzIvalY1mgWg(MiijmKuImrX0n4OOC599R29uTC(9QfiF8JdnBWJdef50PASooCuub2NbRhfPS1k2fYj9M0DtG)tyBbKijbju2AfRawKRzSTascaju2AfRawKRzm6DLCqYiKmtMOOR(9YOOfX99zdu8JFuSU5IMyakoqCOzXbIIC6unwhhokEfrre)rrx97LrrHoyDQghff6nlhffmKWcQDlkyn2hKOjh4OE9YVF1EXzYaijaKugKiyi59gNpwbSixZyoDQgRHKaqI6UM(mtSlKt6nP7Ma)NWa2W3ebjHHeALgsccKucKijbjQ7A6ZmXkGf5AgdydFteKegsOvAijiqsjqsPqIKeKWcQDlkyn2hKOjh4OE9YVF1EXzYaijaKugKiyi59gNpwbSixZyoDQgRHKaqI6UM(mtSlKt6nP7Ma)NWa2W3ebjHHeALgsccKmpqIKeKOURPpZeRawKRzmGn8nrqsyiHwPHKGajZdKuAuuOd6PBWrrZnPr9I7AXpoKSXbIIC6unwhhokEfrre)rrx97LrrHoyDQghff6nlhfrfCR1FhqZpcRxHBYD0Fadij8iKilKeasemK8EJZhdw6PNplQlKb6v9yoDQgRHejjibvWTw)Dan)iSEfUj3r)bmGKWJqsjqsai59gNpgS0tpFwuxid0R6XC6unwdjssqcLTwXSrH8a2ZEXzYaSTascajAMYwR4GA10gC(y9zMqsaiHYwRy9kCtUxybfhIX6ZmHKaqcLTwXUqoP3KUBc8FQ72)uG9X6ZmJIcDqpDdokQrDLJENQXXpoujXbIIC6unwhhokQa7ZG1JIu2Af7c5KEt6UjW)jS(mtijaKugKqzRv8McQDr7VxI1NzcjssqcLTwXBkO2fT)EjgWg(MiijuizqajbGKPRjFV4mzaKeEeskbsKKGK3BC(yE(SY(7LDeNpNkgZPt1ynKeasu310NzI55Zk7Vx2rC(CQymGn8nrqsOqYmzGKaqcLTwXBkO2fT)EjgWg(MiijuizMaHejjirDxtFMj2fYj9M0DtG)tyaB4BIGKqHKzcescaju2AfVPGAx0(7LyaB4BIGKqHezLbscajtxt(EXzYaij8iKucKuAu0v)EzuCtb1UO93lJFCibehikYPt1yDC4OOcSpdwpkIk4wR)oGMFewVc3K7O)agqsOJqISqsaiPmirWqY7noFScyrUMXC6unwdjbGe1Dn9zMyxiN0Bs3nb(pHbSHVjcscdjZKbsKKGK3BC(yfWICnJ50PASgscaju2AfRawKRzS(mtijaKOURPpZeRawKRzmGn8nrqsyizMmqIKeKqzRvScyrUMXO3vYbjHhHKbdsknk6QFVmkYZNv2FVSJ485uXXpoKaJdef50PASooCuub2NbRhff6G1PAmwJ6kh9ovJHKaqIqhSovJXMBsJ6f31GKaqszqszqIGHK3BC(yE(SY(7LDeNpNkgZPt1ynKijbjLbjOcU16VdO5hH1RWn5o6pGbKeEesKfsKKGe1Dn9zMyE(SY(7LDeNpNkgdydFteKegsOvAijiqISqsPqsPqIKeKugKOURPpZe7c5KEt6UjW)jmGn8nrqsyiHwPHKGajLajbGe1Dn9zMyxiN0Bs3nb(pHbSHVjcscfsMjdKijbjQ7A6ZmXkGf5AgdydFteKegsOvAijiqsjqsairDxtFMjwbSixZyaB4BIGKqHKzYajssqcLTwXkGf5AgBlGKaqcLTwXkGf5AgJExjhKekKmtgiPuiP0OOR(9YOOEfUj3r)bmIFCO5joquKtNQX64WrrfyFgSEuuOdwNQXyZnPr9I7AqsaiPmirWqY7noFmpFwz)9YoIZNtfJ50PASgsKKGe1Dn9zMyE(SY(7LDeNpNkgdydFteKegsOvAijiqISqIKeKOURPpZe7c5KEt6UjW)jmGn8nrqsyiHwPHKGajLajbGe1Dn9zMyxiN0Bs3nb(pHbSHVjcscfsMjdKijbjQ7A6ZmXkGf5AgdydFteKegsOvAijiqsjqsairDxtFMjwbSixZyaB4BIGKqHKzYajssqcLTwXkGf5AgBlGKaqcLTwXkGf5AgJExjhKekKmtgiP0OOR(9YO4ZgfnhG6czGEvF8JFuKMtg4)bqXbIdnloquKtNQX64WrXRikI4pk6QFVmkk0bRt14OOqVz5OyzqIGHK3BC(4j3WGb9R2nb(pH50PASgsKKGK3b08JNyV9t4c1djHhHezLbscajLbju2Af7c5KEt6UjW)jS(mtirscsOS1kwbSixZy9zMqsPqsPrrHoONUbhffKob54hhs24arroDQgRJdhfvG9zW6rXPRjFV4mzaKeEeseiKijbju2AfBWghq((v7nRA1DnGDde2wajssqcLTwXiM)PnP7aNMX2cirscsOS1kEtb1UO93lX6ZmHKaqY01KVxCMmascpcjLefD1VxgfvER1D1Vx2Bl6JITf990n4OyDZfnXau8JdvsCGOiNovJ1XHJIkW(my9OyzqIGHeGV6olKZh7AncZZFrpcsKKGeGV6olKZh7AncVjKegsMjqirscsqfCR1FhqZpcB6YX9R2D0eJGKWJqISqsPqsaiPmiz6AY3lotgajHocjYajssqY01KVxCMmasgHKzqsairDxtFMjMQ5AUF1EqTOFvmgWg(MiijmKqR0qsPqsaiPmirDxtFMj2fYj9M0DtG)tyaB4BIGKWqYmzGejji59gNpwbSixZyoDQgRHKaqI6UM(mtScyrUMXa2W3ebjHHKzYajLgfD1VxgfnD54(v7oAIrXpoKaIdef50PASooCuub2NbRhfNUM89IZKbqsOJqISqIKeKugKmDn57fNjdGKriPeijaKugKOURPpZep5ggmOF1UjW)jmGn8nrqsyiHwPHKGajYcjssqIqhSovJXcsNGmKukKuAu0v)EzuKQ5AUF1EqTOFvC8JdjW4arroDQgRJdhfvG9zW6rXPRjFV4mzaKe6iKilKijbjLbjtxt(EXzYaij0riraqsaiPmirDxtFMjMQ5AUF1EqTOFvmgWg(MiijmKqR0qsqGezHejjirOdwNQXybPtqgskfsknk6QFVmkguRM2GZp(XHMN4arroDQgRJdhfvG9zW6rXPRjFV4mzaKe6iKiGOOR(9YO4KByWG(v7Ma)NIFCObloquKtNQX64WrrfyFgSEuC6AY3lotgajHocjYcjssqY01KVxCMmascDeskbscajQ7A6ZmXunxZ9R2dQf9RIXa2W3ebjHHeALgsccKilKijbjtxt(EXzYaizeseaKeasu310NzIPAUM7xThul6xfJbSHVjcscdj0knKeeirwijaKOURPpZehuRM2GZhdydFteKegsOvAijiqISrrx97Lrr1Liwb8FVm(XHgeXbIIC6unwhhokQa7ZG1JIV348XtUHbd6xTBc8FcZPt1ynKeasEhqZpEI92pHlupKe6iKiRmqIKeKqzRvSlKt6nP7Ma)NW2cirscsOS1kwbSixZyBru0v)Ezuu5Tw3v)EzVTOpk2w03t3GJI1nx0edqXpo0GhhikYPt1yDC4OOcSpdwpkQURPpZeRawKRzqh9GvogRMCanJ6vGR(9sVbjHhHKz4btGqsaiPmiz6AY3lotgajHocjYcjssqY01KVxCMmascDeskbscajQ7A6ZmXunxZ9R2dQf9RIXa2W3ebjHHeALgsccKilKijbjtxt(EXzYaizeseaKeasu310NzIPAUM7xThul6xfJbSHVjcscdj0knKeeirwijaKOURPpZehuRM2GZhdydFteKegsOvAijiqISqsairDxtFMjwDjIva)3lXa2W3ebjHHeALgsccKilKuAu0v)EzuubSixZGo6bRCC8JdntM4arroDQgRJdhfD1VxgfvER1D1Vx2Bl6JITf990n4OyDZfnXau8JdnBwCGOOR(9YOO6sfNpWFw3Rn3GJIC6unwhho(XHMjBCGOiNovJ1XHJIkW(my9O401KVxCMmascDesequ0v)EzuubSixZGo6bRCC8JdnRK4arroDQgRJdhfvG9zW6rXPRjFV4mzaKe6iKiGOOR(9YOOduEY9)aao)4h)4hfD7pDGOO4AmOi(Xpgb]] )


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


    spec:RegisterSetting( "check_wake_range", false, {
        name = "Check |T1112939:0|t Wake of Ashes Range",
        desc = "If checked, when your target is outside of |T1112939:0|t Wake of Ashes' range, it will not be recommended.",
        type = "toggle",
        width = 1.5
    } ) 


end
