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


    spec:RegisterPack( "Retribution", 20190721.2330, [[duK)tbqicPEKIkSjbmkbLtjOAvuq9kfvnlbXTief7cQFPqmmkWXuuwgfYZernncjxJqyBeI4BIizCeIQZjIuRtrf18eKUNc2NiCqcrIwOcvpurfHlQOIuJKqK6KkQiALcu7uHYqjejSucrspLetvH0vvurYxjeL2Rq)vkdgXHPAXi5XenzsDzuBwuFgPgTICAvwnfKxtHA2s1TjPDl53knCr64IiSCv9Cith46uA7eQVtrJxrLoVaz9IiA(eSFqhNfhnQODahhZidML0gKugndBuYjNuIkPIkGGs5OsQln2P5Os5QCurKkd(JYcUTIkPEq911XrJkO1(soQmbaPO58iJqFGjlfwUQJGovB3b3wY3ZGrqNQCKOcL96G5KvKkQODahhZidML0gKugndBuYjlkrnlQGszzCSKYGOY0P1CfPIkAgjJkZbKisLb)rzb3wqIifE31xbdEoGKjaifnNhze6dmzPWYvDe0PA7o42s(Egmc6uLJadEoGKGT9GGeJMfcKyKbZsAirKbsML0ZzJskyWWGNdizoXKx0mAoddEoGergizovQ2bSgsY7djICSr4Os6V5RZrL5asePYG)OSGBlirKcV76RGbphqYeaKIMZJmc9bMSuy5Qoc6uTDhCBjFpdgbDQYrGbphqsW2EqqIrZcbsmYGzjnKiYajZs65SrjfmyyWZbKmNyYlAgnNHbphqIidKmNkv7awdj59Hero2immyyWZbKmNEUS0cynKqX59zirUQuoasOy6RqyirKsPKtbiiP2sKzYF1STdjUeCBHGKT6bHHbphqIlb3wiC6ZYvLYbd5UJmgg8CajUeCBHWPplxvkhm)Wi5D1WGNdiXLGBleo9z5Qs5G5hgXT0QCbCWTfm45asukpfnTai59tdju2CM1qcc4aeKqX59zirUQuoasOy6RqqIxAij9zrM0faUIgsoeKO3IXWGNdiXLGBleo9z5Qs5G5hgbvEkAAbneWbiyWUeCBHWPplxvkhm)WiPl42cgSlb3wiC6ZYvLYbZpmI)sV4gy)NlqixEq0aVZfaB6gZTn3C0eJWC5uDwddgg8CajZPNllTawdjSy(dcsaNkdjGjgsCjyFi5qqIl2VUt1zmmyxcUTqdptznMHb7sWTfA(HrKEV3Cj42Q1peiKYv5b5UD9AwiyWUeCBHMFyeP37nxcUTA9dbcPCvEGMl(DW(iyWWGDj42cHb)vgZa0GfXTdWQHuUkp8UA6v0nxnTFaRMB0hTlE7Ggx0xXHC5HWOS5m2fZf9v0nZ3btyBQGaLnNXY3ICnJTPHdd2LGBleg8xzmdqZpmIfXTdWQHuUkpq)BrJAP)P69270CixEq0u2Cg7I5I(k6M57GjSnnGOPS5mw(wKRzSnfgSlb3wim4VYygGMFyelIBhGvdPCvE49KuBlJrnQJU9SUrzbGTGb7sWTfcd(RmMbO5hgXI42by1qkxLhmeJAtRzN)qU8aLnNXUyUOVIUz(oycBtfeOS5mw(wKRzSnnaLnNXY3ICnJraxA8WmdGb7sWTfcd(RmMbO5hgXI42by1qkxLheFEVT5MxNQdyDJQVRoKlpegLnNXUyUOVIUz(oycBtfeOS5mw(wKRzSnnaLnNXY3ICnJFw1Vcf6mrE4ccHj3TRxZc7I5I(k6M57Gj8ZQ(vOejBGGGC3UEnlS8TixZ4Nv9Rqjs2GWHb7sWTfcd(RmMbO5hgXI42by1qkxLh07QIAz7huixEGYMZyxmx0xr3mFhmHTPccu2CglFlY1m2MgGYMZy5BrUMXpR6xHcDMihgSlb3wim4VYygGMFyelIBhGvdPCvEG27S07D(rnk2noKlpqzZzSlMl6ROBMVdMW2ubbkBoJLVf5AgBtdqzZzS8TixZ4Nv9RqHoteWGDj42cHb)vgZa08dJyrC7aSAiLRYdubrVf3OyU5DvVCzixEGYMZyxmx0xr3mFhmHTPccu2CglFlY1m2Mcd2LGBleg8xzmdqZpmIfXTdWQHuUkpOYpBmyYrTSx0HC5HWe97NUXI5cGDTgH55Eiasq49t3yXCbWUwJWxLyMicxqaLY9Ed4pndqy9j(kUHa7RMyWiyWUeCBHWG)kJzaA(HrSiUDawnKYv5H0UT08tX(RrTC3rghYLhOS5m2fZf9v0nZ3btyBQGaLnNXY3ICnJTPbOS5mw(wKRzmc4sJtmmZabb5UD9Awyxmx0xr3mFhmHFw1VcLquIqqq0u2CglFlY1m2MgqUBxVMfw(wKRz8ZQ(vOeIseWGDj42cHb)vgZa08dJyrC7aSAiLRYdu8J43y(rndznKnKlpqzZzSlMl6ROBMVdMW2ubbkBoJLVf5AgBtdqzZzS8TixZyeWLgNyyMbccYD761SWUyUOVIUz(oyc)SQFfkHOeHGGOPS5mw(wKRzSnnGC3UEnlS8TixZ4Nv9RqjeLiGb7sWTfcd(RmMbO5hgXI42by1qkxLh4s3zeQbUscSp32Cl)UeCB59w6AYFixEGYMZyxmx0xr3mFhmHTPccu2CglFlY1m2MgGYMZy5BrUMXiGlnoXWmdeeK721RzHDXCrFfDZ8DWe(zv)kucrjcbb5UD9Awy5BrUMXpR6xHsikrad2LGBleg8xzmdqZpmIfXTdWQHuUkpKY(3B6tm)OMCvtDekKlpqzZzSlMl6ROBMVdMW2ubbkBoJLVf5AgBtdqzZzS8TixZyeWLgNyyMbWGDj42cHb)vgZa08dJyrC7aSAiLRYd57rGMQdyudLgeD3rOqU8aLnNXUyUOVIUz(oycBtfeOS5mw(wKRzSnnaLnNXY3ICnJFw1Vcf6Wmrad2LGBleg8xzmdqZpmIfXTdWQHuUkpyoDF38kAulTBvDAoKlpqzZzSlMl6ROBMVdMW2ubbkBoJLVf5AgBtdqzZzS8TixZ4Nv9RqHoyKbWGDj42cHb)vgZa08dJyrC7aSAiLRYd6NDDJU76Zb7JAuUMMd5Ydu2Cg7I5I(k6M57GjSnvqGYMZy5BrUMX20au2CglFlY1m(zv)kuOdgzamyxcUTqyWFLXman)Wiwe3oaRgs5Q8G(zx3Cu69Ebqnvw79(TvixEGYMZyxmx0xr3mFhmHTPccu2CglFlY1m2MgGYMZy5BrUMXpR6xHcDWidGb7sWTfcd(RmMbO5hgXI42by1qkxLhmUwqBZnVKhxGw2(bfYLhOS5m2fZf9v0nZ3btyBQGaLnNXY3ICnJTPbOS5mw(wKRzmc4sJtmmZabb5UD9Awyxmx0xr3mFhmHFw1VcLizdeeenLnNXY3ICnJTPbK721RzHLVf5Ag)SQFfkrYgad2LGBleg8xzmdqZpmIfXTdWQOqU8aLnNXUyUOVIUz(oycBtfeOS5mw(wKRzSnnaLnNXY3ICnJraxA8WmdGbdd2LGBlewUBxVMfAiDb3wHC5HWK721RzHPT(RpVABU5jj)lyc)SQFfkrsBGGGOzeIljJLBP5cX6w)YCEFjJvDdTF4bcJYMZyQ(U6UfbWp7sGGaLnNXUyUOVIUz(oycBtfeOS5mw(wKRzSnnaLnNXY3ICnJFw1VcfQrIiCyWUeCBHWYD761SqZpms)ONaOMHSAAvUaHC5buk37nG)0maH7h9ea1mKvtRYfiXGrccHj63pDJfZfa7AncZZ9qaKGW7NUXI5cGDTgHVkrsjIWHb7sWTfcl3TRxZcn)Wi57zQ(U6qU8aLnNXUyUOVIUz(oycBtfeOS5mw(wKRzSnnaLnNXY3ICnJraxA8WmdGb7sWTfcl3TRxZcn)WiOPJ762MBI5IM9sYHC5bkBoJrmdMUIU9onJ1RzfGYMZyvwD)GABU1TYt30p7QiSEnlyWUeCBHWYD761SqZpmIfXTdWQHuUkp4OjXEXO27j5(n5(EpKlpOzkBoJFpj3Vj337nntzZzSEnlbHWOS5m2fZf9v0nZ3bt4Nv9RqjgmYabbkBoJLVf5AgJaU04HzgeGYMZy5BrUMXpR6xHsmteHhim5UD9AwyAR)6ZR2MBEsY)cMWpR6xHsK0giiaovUb2M(4qt2abbrZiexsgl3sZfI1T(L58(sgR6gA)WHb7sWTfcl3TRxZcn)Wiwe3oaRgs5Q8W7QPxr3C10(bSAUrF0U4TdACrFfhYLhcJYMZyxmx0xr3mFhmHTPccu2CglFlY1m2MgomyxcUTqy5UD9AwO5hgXI42byvuixEGYMZyxmx0xr3mFhmHTPccu2CglFlY1m2Mcd2LGBlewUBxVMfA(HratCZwuRT0T8(soKlpaovo0bJeeOS5m(zPXDgHA59Lm2Mcd2LGBlewUBxVMfA(HrO67QBBUbM4gxSAqHC5bkBoJDXCrFfDZ8DWe2MkiqzZzS8TixZyBAakBoJLVf5AgJaU04Hzgad2LGBlewUBxVMfA(HrOT(RpVABU5jj)lykKlpiAG35cGLVf5AgZLt1zDGWK721RzHDXCrFfDZ8DWe(zv)kuOIiW02dQLUM8Nyi5aHrzZz8vjH9qh42cBtfeenW7CbWxLe2dDGBlmxovN1Hlii3TRxZc7I5I(k6M57Gj8ZQ(vOedIseHliegW7CbWY3ICnJ5YP6SoGC3UEnlS8TixZ4Nv9RqHsl1bM2EqT01K)edIsqyA7b1sxt(tmKCaWPYHoZGaaVZfaB6gZTn3C0eJWC5uDwlii3TRxZclFlY1m(zv)kuIbrjIWHb7sWTfcl3TRxZcn)WiM731I5RApJ2YljhYLhK721RzHDXCrFfDZ8DWe(zv)kuO0sDGPThulDn5pXqYccYD761SWY3ICnJFw1VcfkTuhyA7b1sxt(tmikbb5UD9Awyxmx0xr3mFhmHFw1VcLyquIqqqUBxVMfw(wKRz8ZQ(vOedIseWGDj42cHL721RzHMFyK8kTiw38KK)dWnk2vd5YdHj63pDJfZfa7AncZZ9qaKGW7NUXI5cGDTgHVkrYgiiGs5EVb8NMbiS(eFf3qG9vtmyu4bcJYMZyxmx0xr3mFhmH1RzjiqzZzS8TixZy9AwHhim5UD9AwyQUR52MBgYIaNKXpR6xHsql1go5aYD761SWgYQPv5cGFw1VcLGwQnCYHdd2LGBlewUBxVMfA(Hruz19dQT5w3kpDt)SRIc5YdHrzZzSlMl6ROBMVdMW2ubbkBoJLVf5AgBtdqzZzS8TixZyeWLgpmZGWdmT9GAPRj)HoKmmyxcUTqy5UD9AwO5hgj1(xoOROBuDhbc5YdHj63pDJfZfa7AncZZ9qaKGW7NUXI5cGDTgHVkrYgiiGs5EVb8NMbiS(eFf3qG9vtmyu4WGDj42cHL721RzHMFyelIBhGvdHZzwcALRYdYGK9f8BDYgv3rGqU8qyu2Cg7I5I(k6M57GjSEnlbbkBoJLVf5AgRxZk8aHj3TRxZct1Dn32CZqwe4Km(zv)kucAP2WjhqUBxVMf2qwnTkxa8ZQ(vOe0sTHtoCyWUeCBHWYD761SqZpmIlMl6ROBMVdMc5YdHjAG35cGVkjSh6a3wyUCQoRfeOS5m(QKWEOdCBHTPHhyA7b1sxt(tmKmmyxcUTqy5UD9AwO5hgr(wKR5qU8W02dQLUM8NyqucctBpOw6AYFIHKdaovo0zgea4DUayt3yUT5MJMyeMlNQZAyWWGDj42cHZxDOj(rdI9)CQohs5Q8G5v0Ow6U9qe7DlpiAojSxAkRXZejjDYZevGWenW7CbWY3ICnJ5YP6SoGC3UEnlSlMl6ROBMVdMWpR6xHsql1gozbb5UD9Awy5BrUMXpR6xHsql1go5Wfe4KWEPPSgptKK0jptubct0aVZfalFlY1mMlNQZ6aYD761SWUyUOVIUz(oyc)SQFfkbTuByrIGGC3UEnlS8TixZ4Nv9RqjOLAdlschgSlb3wiC(QdnXpA(Hre7)5uDoKYv5bnQjDeWP6CiI9ULhqPCV3a(tZaewFIVIBiW(QjgmkGObENla(p6jaVwutm)6tcWC5uDwliGs5EVb8NMbiS(eFf3qG9vtmKCaG35cG)JEcWRf1eZV(KamxovN1ccu2CgZQPb9SxT01KFSnnGMPS5m2qwnTkxaSEnRau2CgRpXxXTu7NUigRxZkaLnNXUyUOVIUz(oyQ5wWk)dG1Rzbd2LGBleoF1HM4hn)WixLe2dDGBRqU8aLnNXUyUOVIUz(oycRxZkqyu2CgFvsyp0bUTW61SeeOS5m(QKWEOdCBHFw1VcfQipW02dQLUM8NyizbbG35cG55Ysl42QH4cWLKXC5uDwhqUBxVMfMNllTGBRgIlaxsg)SQFfk0zgeGYMZ4Rsc7HoWTf(zv)kuOZeHGGC3UEnlSlMl6ROBMVdMWpR6xHcDMicqzZz8vjH9qh42c)SQFfkuJmiW02dQLUM8Nyi5WHb7sWTfcNV6qt8JMFyeEUS0cUTAiUaCj5qU8akL79gWFAgGW6t8vCdb2xn0bJceMObENlaw(wKRzmxovN1bK721RzHDXCrFfDZ8DWe(zv)kuIzgiia8oxaS8TixZyUCQoRdqzZzS8TixZy9AwbK721RzHLVf5Ag)SQFfkXmdeeOS5mw(wKRzmc4sJtmKuHdd2LGBleoF1HM4hn)Wi6t8vCdb2xnKlpi2)ZP6mwJAshbCQohqS)Nt1zS5v0Ow6U9aHfMObENlaMNllTGBRgIlaxsgZLt1zTGqyOuU3Ba)PzacRpXxXneyF1edgjii3TRxZcZZLLwWTvdXfGljJFw1VcLGwQnSrHhUGqyYD761SWUyUOVIUz(oyc)SQFfkbTuB4Kdi3TRxZc7I5I(k6M57Gj8ZQ(vOqNzGGGC3UEnlS8TixZ4Nv9RqjOLAdNCa5UD9Awy5BrUMXpR6xHcDMbccu2CglFlY1m2MgGYMZy5BrUMXiGlno0zgeE4WGDj42cHZxDOj(rZpmcGvt7(JAI5xFsqixEqS)Nt1zS5v0Ow6U9aHjAG35cG55Ysl42QH4cWLKXC5uDwlii3TRxZcZZLLwWTvdXfGljJFw1VcLGwQnSrccYD761SWUyUOVIUz(oyc)SQFfkbTuB4Kdi3TRxZc7I5I(k6M57Gj8ZQ(vOqNzGGGC3UEnlS8TixZ4Nv9RqjOLAdNCa5UD9Awy5BrUMXpR6xHcDMbccu2CglFlY1m2MgGYMZy5BrUMXiGlno0zgeomyyWUeCBHW0CXVd2hni2)ZP6CiLRYdI0RiBiI9ULhct0aVZfap5QQ832CZ8DWeMlNQZAbbG)0mapXEhmHtLGedgzqGWOS5m2fZf9v0nZ3bty9Awccu2CglFlY1mwVMv4Hdd2LGBleMMl(DW(O5hgr69EZLGBRw)qGqkxLhYxDOj(rHC5HPThulDn5pXGieeOS5mwLv3pO2MBDR80n9ZUkcBtfeOS5mgXmy6k6270m2MkiqzZz8vjH9qh42cRxZkW02dQLUM8NyizyWUeCBHW0CXVd2hn)WiMUXCBZnhnXOqU8qyI(9t3yXCbWUwJW8Cpeaji8(PBSyUayxRr4RsmteccOuU3Ba)PzacB6gZTn3C0eJsmyu4bcBA7b1sxt(dDWabHPThulDn5Fywa5UD9AwyQUR52MBgYIaNKXpR6xHsql1Hhim5UD9Awyxmx0xr3mFhmHFw1VcLyMbccaVZfalFlY1mMlNQZ6aYD761SWY3ICnJFw1VcLyMbHdd2LGBleMMl(DW(O5hgHQ7AUT5MHSiWj5qU8W02dQLUM8h6GrccHnT9GAPRj)djhim5UD9Aw4jxvL)2MBMVdMWpR6xHsql1g2ibbX(FovNXI0RiB4Hdd2LGBleMMl(DW(O5hgXqwnTkxGqU8W02dQLUM8h6GrccHnT9GAPRj)HoiQaHj3TRxZct1Dn32CZqwe4Km(zv)kucAP2Wgjii2)ZP6mwKEfzdpCyWUeCBHW0CXVd2hn)WitUQk)Tn3mFhmfYLhM2EqT01K)qhefmyxcUTqyAU43b7JMFye5wiw(o42kKlpmT9GAPRj)HoyKGW02dQLUM8h6qYbK721RzHP6UMBBUzilcCsg)SQFfkbTuByJeeM2EqT01K)brfqUBxVMfMQ7AUT5MHSiWjz8ZQ(vOe0sTHnkGC3UEnlSHSAAvUa4Nv9RqjOLAdBemyxcUTqyAU43b7JMFyeP37nxcUTA9dbcPCvEiF1HM4hfYLhaENlaEYvv5VT5M57GjmxovN1ba(tZa8e7DWeovccDWideeOS5m2fZf9v0nZ3btyBQGaLnNXY3ICnJTPWGDj42cHP5IFhSpA(HrKVf5A(BiWFgZHC5b5UD9Awy5BrUM)gc8NXmwo5pnJA53LGBlVNyygoPerGWM2EqT01K)qhmsqyA7b1sxt(dDi5aYD761SWuDxZTn3mKfbojJFw1VcLGwQnSrcctBpOw6AY)GOci3TRxZct1Dn32CZqwe4Km(zv)kucAP2WgfqUBxVMf2qwnTkxa8ZQ(vOe0sTHnkGC3UEnlSClelFhCBHFw1VcLGwQnSrHdd2LGBleMMl(DW(O5hgr69EZLGBRw)qGqkxLhYxDOj(rWGDj42cHP5IFhSpA(HrKBj5c8oG1TC3vzyWUeCBHW0CXVd2hn)WiY3ICn)ne4pJ5qU8W02dQLUM8h6GOGb7sWTfctZf)oyF08dJ4V0lUb2)5ceYLhM2EqT01K)qhevurm)OBR4ygzWSK2GKAMryJso5OIP)1v0OOYCs109bSgsejqIlb3wqs)qaeggCuXTGP9JkkN6CIOs)qauC0OIMZUTdIJghBwC0OIlb3wrLNPSgZrfUCQoRJJhbXXmkoAuHlNQZ644rfxcUTIksV3BUeCB16hcev6hc0kxLJkYD761SqrqCSKJJgv4YP6SooEuXLGBROI079Mlb3wT(HarL(HaTYv5Ocnx87G9rrqeevsFwUQuoioACSzXrJkUeCBfvsxWTvuHlNQZ644rqCmJIJgv4YP6SooEur(hG)ZJkIgsaENla20nMBBU5OjgH5YP6SoQ4sWTvuXFPxCdS)ZficIGOIC3UEnluC04yZIJgv4YP6SooEur(hG)ZJkHbjYD761SW0w)1NxTn38KK)fmHFw1VcbjjGKK2airqasenKWiexsgl3sZfI1T(L58(sgR6gAFijCijaKegKqzZzmvFxD3Ia4NDjaseeGekBoJDXCrFfDZ8DWe2McjccqcLnNXY3ICnJTPqsaiHYMZy5BrUMXpR6xHGKqHeJebKeEuXLGBROs6cUTIG4ygfhnQWLt1zDC8OI8pa)NhvqPCV3a(tZaeUF0tauZqwnTkxaijXaKyeKiiajHbjIgsE)0nwmxaSR1imp3dbqqIGaK8(PBSyUayxRr4RGKeqssjcij8OIlb3wrL(rpbqndz10QCbIG4yjhhnQWLt1zDC8OI8pa)NhvOS5m2fZf9v0nZ3btyBkKiiaju2CglFlY1m2McjbGekBoJLVf5AgJaU0yizasMzquXLGBROs(EMQVRocIJjQ4OrfUCQoRJJhvK)b4)8OcLnNXiMbtxr3ENMX61SGKaqcLnNXQS6(b12CRBLNUPF2vry9AwrfxcUTIkOPJ762MBI5IM9sYrqCmrehnQWLt1zDC8OIlb3wrfhnj2lg1Epj3Vj337rf5Fa(ppQOzkBoJFpj3Vj337nntzZzSEnlirqascdsOS5m2fZf9v0nZ3bt4Nv9RqqsIbiXidGebbiHYMZy5BrUMXiGlngsgGKzgajbGekBoJLVf5Ag)SQFfcssajZebKeoKeascdsK721RzHPT(RpVABU5jj)lyc)SQFfcssajjTbqIGaKaovUb2M(yijuijzdGebbir0qcJqCjzSClnxiw36xMZ7lzSQBO9HKWJkLRYrfhnj2lg1Epj3Vj337rqCmrsC0OcxovN1XXJkUeCBfvExn9k6MRM2pGvZn6J2fVDqJl6R4OI8pa)NhvcdsOS5m2fZf9v0nZ3btyBkKiiaju2CglFlY1m2McjHhvkxLJkVRMEfDZvt7hWQ5g9r7I3oOXf9vCeehlPIJgv4YP6SooEur(hG)ZJku2Cg7I5I(k6M57GjSnfseeGekBoJLVf5AgBtJkUeCBfvSiUDawffbXXe5XrJkC5uDwhhpQi)dW)5rfWPYqsOdqIrqIGaKqzZz8ZsJ7mc1Y7lzSnnQ4sWTvubmXnBrT2s3Y7l5iiowshhnQWLt1zDC8OI8pa)NhvOS5m2fZf9v0nZ3btyBkKiiaju2CglFlY1m2McjbGekBoJLVf5AgJaU0yizasMzquXLGBROcvFxDBZnWe34IvdkcIJnZG4OrfUCQoRJJhvK)b4)8OIOHeG35cGLVf5AgZLt1znKeascdsK721RzHDXCrFfDZ8DWe(zv)keKekKicijaKmT9GAPRj)qsIbijzijaKegKqzZz8vjH9qh42cBtHebbir0qcW7CbWxLe2dDGBlmxovN1qs4qIGaKi3TRxZc7I5I(k6M57Gj8ZQ(viijXaKikrajHdjccqsyqcW7CbWY3ICnJ5YP6SgscajYD761SWY3ICnJFw1VcbjHcj0snKeasM2EqT01KFijXaKikirqasM2EqT01KFijXaKKmKeasaNkdjHcjZmascajaVZfaB6gZTn3C0eJWC5uDwdjccqIC3UEnlS8TixZ4Nv9RqqsIbiruIascpQ4sWTvuH26V(8QT5MNK8VGPiio2SzXrJkC5uDwhhpQi)dW)5rf5UD9Awyxmx0xr3mFhmHFw1VcbjHcj0snKeasM2EqT01KFijXaKKmKiiajYD761SWY3ICnJFw1VcbjHcj0snKeasM2EqT01KFijXaKikirqasK721RzHDXCrFfDZ8DWe(zv)keKKyaseLiGebbirUBxVMfw(wKRz8ZQ(viijXaKikrevCj42kQyUFxlMVQ9mAlVKCeehBMrXrJkC5uDwhhpQi)dW)5rLWGerdjVF6glMla21AeMN7HaiirqasE)0nwmxaSR1i8vqscijzdGebbibLY9Ed4pndqy9j(kUHa7RcjjgGeJGKWHKaqsyqcLnNXUyUOVIUz(oycRxZcseeGekBoJLVf5AgRxZcschscajHbjYD761SWuDxZTn3mKfbojJFw1VcbjjGeAPgsmmKKmKeasK721RzHnKvtRYfa)SQFfcssaj0snKyyijzij8OIlb3wrL8kTiw38KK)dWnk2vJG4yZsooAuHlNQZ644rf5Fa(ppQegKqzZzSlMl6ROBMVdMW2uirqasOS5mw(wKRzSnfscaju2CglFlY1mgbCPXqYaKmZaijCijaKmT9GAPRj)qsOdqsYrfxcUTIkQS6(b12CRBLNUPF2vrrqCSzIkoAuHlNQZ644rf5Fa(ppQegKiAi59t3yXCbWUwJW8CpeabjccqY7NUXI5cGDTgHVcssajjBaKiiajOuU3Ba)PzacRpXxXneyFvijXaKyeKeEuXLGBROsQ9VCqxr3O6ocebXXMjI4OrfUCQoRJJhvCj42kQKUsJza6ssw3KRAQf4GBRMMfFsoQi)dW)5rLWGekBoJDXCrFfDZ8DWewVMfKiiaju2CglFlY1mwVMfKeoKeascdsK721RzHP6UMBBUzilcCsg)SQFfcssaj0snKyyijzijaKi3TRxZcBiRMwLla(zv)keKKasOLAiXWqsYqs4rfoNzjOvUkhvKbj7l436KnQUJarqCSzIK4OrfUCQoRJJhvK)b4)8OsyqIOHeG35cGVkjSh6a3wyUCQoRHebbiHYMZ4Rsc7HoWTf2McjHdjbGKPThulDn5hssmajjhvCj42kQ4I5I(k6M57GPiio2SKkoAuHlNQZ644rf5Fa(ppQmT9GAPRj)qsIbiruqIGaKmT9GAPRj)qsIbijzijaKaovgscfsMzaKeasaENla20nMBBU5OjgH5YP6SoQ4sWTvur(wKR5iicIkG)kJzakoACSzXrJkC5uDwhhpQ4sWTvu5D10ROBUAA)awn3OpAx82bnUOVIJkY)a8FEujmiHYMZyxmx0xr3mFhmHTPqIGaKqzZzS8TixZyBkKeEuPCvoQ8UA6v0nxnTFaRMB0hTlE7Ggx0xXrqCmJIJgv4YP6SooEuXLGBROc9VfnQL(NQ3BVtZrf5Fa(ppQiAiHYMZyxmx0xr3mFhmHTPqsair0qcLnNXY3ICnJTPrLYv5Oc9VfnQL(NQ3BVtZrqCSKJJgv4YP6SooEuPCvoQ8EsQTLXOg1r3Ew3OSaWwrfxcUTIkVNKABzmQrD0TN1nklaSveehtuXrJkC5uDwhhpQ4sWTvuXqmQnTMD(JkY)a8FEuHYMZyxmx0xr3mFhmHTPqIGaKqzZzS8TixZyBkKeasOS5mw(wKRzmc4sJHKbizMbrLYv5OIHyuBAn78hbXXerC0OcxovN1XXJkUeCBfveFEVT5MxNQdyDJQVRoQi)dW)5rLWGekBoJDXCrFfDZ8DWe2McjccqcLnNXY3ICnJTPqsaiHYMZy5BrUMXpR6xHGKqHKzICijCirqascdsK721RzHDXCrFfDZ8DWe(zv)keKKass2airqasK721RzHLVf5Ag)SQFfcssajjBaKeEuPCvoQi(8EBZnVovhW6gvFxDeehtKehnQWLt1zDC8OIlb3wrf9UQOw2(bfvK)b4)8OcLnNXUyUOVIUz(oycBtHebbiHYMZy5BrUMX2uijaKqzZzS8TixZ4Nv9RqqsOqYmrEuPCvoQO3vf1Y2pOiiowsfhnQWLt1zDC8OIlb3wrfAVZsV35h1Oy34OI8pa)NhvOS5m2fZf9v0nZ3btyBkKiiaju2CglFlY1m2McjbGekBoJLVf5Ag)SQFfcscfsMjIOs5QCuH27S07D(rnk2nocIJjYJJgv4YP6SooEuXLGBROcvq0BXnkMBEx1lxgvK)b4)8OcLnNXUyUOVIUz(oycBtHebbiHYMZy5BrUMX20Os5QCuHki6T4gfZnVR6LlJG4yjDC0OcxovN1XXJkUeCBfvu5Nngm5Ow2l6OI8pa)NhvcdsenK8(PBSyUayxRryEUhcGGebbi59t3yXCbWUwJWxbjjGKzIaschseeGeuk37nG)0maH1N4R4gcSVkKKyasmkQuUkhvu5Nngm5Ow2l6iio2mdIJgv4YP6SooEuXLGBROsA3wA(Py)1OwU7iJJkY)a8FEuHYMZyxmx0xr3mFhmHTPqIGaKqzZzS8TixZyBkKeasOS5mw(wKRzmc4sJHKedqYmdGebbirUBxVMf2fZf9v0nZ3bt4Nv9RqqsciruIaseeGerdju2CglFlY1m2McjbGe5UD9Awy5BrUMXpR6xHGKeqIOeruPCvoQK2TLMFk2FnQL7oY4iio2SzXrJkC5uDwhhpQ4sWTvuHIFe)gZpQziRHSrf5Fa(ppQqzZzSlMl6ROBMVdMW2uirqasOS5mw(wKRzSnfscaju2CglFlY1mgbCPXqsIbizMbqIGaKi3TRxZc7I5I(k6M57Gj8ZQ(viijbKikrajccqIOHekBoJLVf5AgBtHKaqIC3UEnlS8TixZ4Nv9RqqsciruIiQuUkhvO4hXVX8JAgYAiBeehBMrXrJkC5uDwhhpQ4sWTvuHlDNrOg4kjW(CBZT87sWTL3BPRj)rf5Fa(ppQqzZzSlMl6ROBMVdMW2uirqasOS5mw(wKRzSnfscaju2CglFlY1mgbCPXqsIbizMbqIGaKi3TRxZc7I5I(k6M57Gj8ZQ(viijbKikrajccqIC3UEnlS8TixZ4Nv9RqqsciruIiQuUkhv4s3zeQbUscSp32Cl)UeCB59w6AYFeehBwYXrJkC5uDwhhpQ4sWTvujL9V30Ny(rn5QM6iuur(hG)ZJku2Cg7I5I(k6M57GjSnfseeGekBoJLVf5AgBtHKaqcLnNXY3ICnJraxAmKKyasMzquPCvoQKY(3B6tm)OMCvtDekcIJntuXrJkC5uDwhhpQ4sWTvujFpc0uDaJAO0GO7ocfvK)b4)8OcLnNXUyUOVIUz(oycBtHebbiHYMZy5BrUMX2uijaKqzZzS8TixZ4Nv9RqqsOdqYmrevkxLJk57rGMQdyudLgeD3rOiio2mrehnQWLt1zDC8OIlb3wrfZP77MxrJAPDRQtZrf5Fa(ppQqzZzSlMl6ROBMVdMW2uirqasOS5mw(wKRzSnfscaju2CglFlY1m(zv)keKe6aKyKbrLYv5OI509DZROrT0Uv1P5iio2mrsC0OcxovN1XXJkUeCBfv0p76gD31Nd2h1OCnnhvK)b4)8OcLnNXUyUOVIUz(oycBtHebbiHYMZy5BrUMX2uijaKqzZzS8TixZ4Nv9RqqsOdqIrgevkxLJk6NDDJU76Zb7JAuUMMJG4yZsQ4OrfUCQoRJJhvCj42kQOF21nhLEVxautL1EVFBfvK)b4)8OcLnNXUyUOVIUz(oycBtHebbiHYMZy5BrUMX2uijaKqzZzS8TixZ4Nv9RqqsOdqIrgevkxLJk6NDDZrP37fa1uzT373wrqCSzI84OrfUCQoRJJhvCj42kQyCTG2MBEjpUaTS9dkQi)dW)5rfkBoJDXCrFfDZ8DWe2McjccqcLnNXY3ICnJTPqsaiHYMZy5BrUMXiGlngssmajZmaseeGe5UD9Awyxmx0xr3mFhmHFw1VcbjjGKKnaseeGerdju2CglFlY1m2McjbGe5UD9Awy5BrUMXpR6xHGKeqsYgevkxLJkgxlOT5MxYJlqlB)GIG4yZs64OrfUCQoRJJhvK)b4)8OcLnNXUyUOVIUz(oycBtHebbiHYMZy5BrUMX2uijaKqzZzS8TixZyeWLgdjdqYmdIkUeCBfvSiUDawffbrquHMl(DW(O4OXXMfhnQWLt1zDC8OYMgvqmiQ4sWTvurS)Nt15OIyVB5OsyqIOHeG35cGNCvv(BBUz(oycZLt1znKiiaja)PzaEI9oycNkbqsIbiXidGKaqsyqcLnNXUyUOVIUz(oycRxZcseeGekBoJLVf5AgRxZcschscpQi2)w5QCurKEfzJG4ygfhnQWLt1zDC8OI8pa)NhvM2EqT01KFijXaKicirqasOS5mwLv3pO2MBDR80n9ZUkcBtHebbiHYMZyeZGPROBVtZyBkKiiaju2CgFvsyp0bUTW61SGKaqY02dQLUM8djjgGKKJkUeCBfvKEV3Cj42Q1peiQ0peOvUkhvYxDOj(rrqCSKJJgv4YP6SooEur(hG)ZJkHbjIgsE)0nwmxaSR1imp3dbqqIGaK8(PBSyUayxRr4RGKeqYmrajccqckL79gWFAgGWMUXCBZnhnXiijXaKyeKeoKeascdsM2EqT01KFij0biXairqasM2EqT01KFizasMbjbGe5UD9AwyQUR52MBgYIaNKXpR6xHGKeqcTudjHdjbGKWGe5UD9Awyxmx0xr3mFhmHFw1VcbjjGKzgajccqcW7CbWY3ICnJ5YP6SgscajYD761SWY3ICnJFw1VcbjjGKzgajHhvCj42kQy6gZTn3C0eJIG4yIkoAuHlNQZ644rf5Fa(ppQmT9GAPRj)qsOdqIrqIGaKegKmT9GAPRj)qYaKKmKeascdsK721RzHNCvv(BBUz(oyc)SQFfcssaj0snKyyiXiirqase7)5uDglsVISqs4qs4rfxcUTIkuDxZTn3mKfbojhbXXerC0OcxovN1XXJkY)a8FEuzA7b1sxt(HKqhGeJGebbijmizA7b1sxt(HKqhGerbjbGKWGe5UD9AwyQUR52MBgYIaNKXpR6xHGKeqcTudjggsmcseeGeX(FovNXI0RilKeoKeEuXLGBROIHSAAvUarqCmrsC0OcxovN1XXJkY)a8FEuzA7b1sxt(HKqhGerfvCj42kQm5QQ832CZ8DWueehlPIJgv4YP6SooEur(hG)ZJktBpOw6AYpKe6aKyeKiiajtBpOw6AYpKe6aKKmKeasK721RzHP6UMBBUzilcCsg)SQFfcssaj0snKyyiXiirqasM2EqT01KFizasefKeasK721RzHP6UMBBUzilcCsg)SQFfcssaj0snKyyiXiijaKi3TRxZcBiRMwLla(zv)keKKasOLAiXWqIrrfxcUTIkYTqS8DWTveehtKhhnQWLt1zDC8OI8pa)NhvaENlaEYvv5VT5M57GjmxovN1qsaib4pndWtS3bt4ujascDasmYairqasOS5m2fZf9v0nZ3btyBkKiiaju2CglFlY1m2MgvCj42kQi9EV5sWTvRFiquPFiqRCvoQKV6qt8JIG4yjDC0OcxovN1XXJkY)a8FEurUBxVMfw(wKR5VHa)zmJLt(tZOw(Dj42Y7qsIbizgoPebKeascdsM2EqT01KFij0biXiirqasM2EqT01KFij0bijzijaKi3TRxZct1Dn32CZqwe4Km(zv)keKKasOLAiXWqIrqIGaKmT9GAPRj)qYaKikijaKi3TRxZct1Dn32CZqwe4Km(zv)keKKasOLAiXWqIrqsairUBxVMf2qwnTkxa8ZQ(viijbKql1qIHHeJGKaqIC3UEnlSClelFhCBHFw1VcbjjGeAPgsmmKyeKeEuXLGBROI8TixZFdb(ZyocIJnZG4OrfUCQoRJJhvCj42kQi9EV5sWTvRFiquPFiqRCvoQKV6qt8JIG4yZMfhnQ4sWTvurULKlW7aw3YDxLJkC5uDwhhpcIJnZO4OrfUCQoRJJhvK)b4)8OY02dQLUM8djHoajIkQ4sWTvur(wKR5VHa)zmhbXXMLCC0OcxovN1XXJkY)a8FEuzA7b1sxt(HKqhGerfvCj42kQ4V0lUb2)5cebrqujF1HM4hfhno2S4OrfUCQoRJJhv20OcIbrfxcUTIkI9)CQohve7DlhvenKWjH9stzn2ts0K)oQL3c02ClDn5hscajHbjIgsaENlaw(wKRzmxovN1qsairUBxVMf2fZf9v0nZ3bt4Nv9RqqsciHwQHeddjjdjccqIC3UEnlS8TixZ4Nv9RqqsciHwQHeddjjdjHdjccqcNe2lnL1ypjrt(7OwElqBZT01KFijaKegKiAib4DUay5BrUMXC5uDwdjbGe5UD9Awyxmx0xr3mFhmHFw1VcbjjGeAPgsmmKisGebbirUBxVMfw(wKRz8ZQ(viijbKql1qIHHercKeEurS)TYv5OI5v0Ow6U9iioMrXrJkC5uDwhhpQSPrfedIkUeCBfve7)5uDoQi27woQGs5EVb8NMbiS(eFf3qG9vHKedqIrqsair0qcW7CbW)rpb41IAI5xFsaMlNQZAirqasqPCV3a(tZaewFIVIBiW(QqsIbijzijaKa8oxa8F0taETOMy(1NeG5YP6SgseeGekBoJz10GE2Rw6AYp2McjbGentzZzSHSAAvUay9AwqsaiHYMZy9j(kULA)0fXy9AwqsaiHYMZyxmx0xr3mFhm1ClyL)bW61SIkI9VvUkhv0OM0raNQZrqCSKJJgv4YP6SooEur(hG)ZJku2Cg7I5I(k6M57GjSEnlijaKegKqzZz8vjH9qh42cRxZcseeGekBoJVkjSh6a3w4Nv9RqqsOqIihscajtBpOw6AYpKKyassgseeGeG35cG55Ysl42QH4cWLKXC5uDwdjbGe5UD9AwyEUS0cUTAiUaCjz8ZQ(viijuizMbqsaiHYMZ4Rsc7HoWTf(zv)keKekKmteqIGaKi3TRxZc7I5I(k6M57Gj8ZQ(viijuizMiGKaqcLnNXxLe2dDGBl8ZQ(viijuiXidGKaqY02dQLUM8djjgGKKHKWJkUeCBfvUkjSh6a3wrqCmrfhnQWLt1zDC8OI8pa)NhvqPCV3a(tZaewFIVIBiW(QqsOdqIrqsaijmir0qcW7CbWY3ICnJ5YP6SgscajYD761SWUyUOVIUz(oyc)SQFfcssajZmaseeGeG35cGLVf5AgZLt1znKeasOS5mw(wKRzSEnlijaKi3TRxZclFlY1m(zv)keKKasMzaKiiaju2CglFlY1mgbCPXqsIbijPGKWJkUeCBfv45Ysl42QH4cWLKJG4yIioAuHlNQZ644rf5Fa(ppQi2)ZP6mwJAshbCQodjbGeX(FovNXMxrJAP72HKaqsyqsyqIOHeG35cG55Ysl42QH4cWLKXC5uDwdjccqsyqckL79gWFAgGW6t8vCdb2xfssmajgbjccqIC3UEnlmpxwAb3wnexaUKm(zv)keKKasOLAiXWqIrqs4qs4qIGaKegKi3TRxZc7I5I(k6M57Gj8ZQ(viijbKql1qIHHKKHKaqIC3UEnlSlMl6ROBMVdMWpR6xHGKqHKzgajccqIC3UEnlS8TixZ4Nv9RqqsciHwQHeddjjdjbGe5UD9Awy5BrUMXpR6xHGKqHKzgajccqcLnNXY3ICnJTPqsaiHYMZy5BrUMXiGlngscfsMzaKeoKeEuXLGBROI(eFf3qG9vJG4yIK4OrfUCQoRJJhvK)b4)8OIy)pNQZyZROrT0D7qsaijmir0qcW7CbW8CzPfCB1qCb4sYyUCQoRHebbirUBxVMfMNllTGBRgIlaxsg)SQFfcssaj0snKyyiXiirqasK721RzHDXCrFfDZ8DWe(zv)keKKasOLAiXWqsYqsairUBxVMf2fZf9v0nZ3bt4Nv9RqqsOqYmdGebbirUBxVMfw(wKRz8ZQ(viijbKql1qIHHKKHKaqIC3UEnlS8TixZ4Nv9RqqsOqYmdGebbiHYMZy5BrUMX2uijaKqzZzS8TixZyeWLgdjHcjZmascpQ4sWTvubWQPD)rnX8RpjicIGiicIGyea]] )


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
