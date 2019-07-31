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


    spec:RegisterPack( "Retribution", 20190731, [[dCKjybqissEeLk1MqQgLuPoLcXQOe6vkQAwukDlfQk7cQFjvYWqkDmfLLrj6zuQAAuQ4Aif2gjPY3uOIXHuuDofQY6qkkMhLK7jvTpPIdIuuQfQOYdvOQAIkujCrfQeTrfQKmsssvojjPQSskf7uHYqvOsQLIuuYtj0uviDvssv1xvOsTxH(RKgmIdt1IrYJjAYK6YO2SeFMGrRiNwLvtj41KeZwk3Mc7w0VvA4k44KKYYv1ZHmDGRly7KuFNIgpsropLuRNsLmFsSFqhNfhnkQDahhZsANnE0oo2pdpBCSKMpZYOiW6boko4svCbokMUbhfPzXG)OcGBZO4GBDBDDC0OiAdVKJItaWaIMPRUeoWuGclxJUqNrO5GBt57fqxOZq2vuKkCnGQVmsff1oGJJzjTZgpAhh7NHNnowQ6OXSOiAGLXXghAJItNwZzKkkQzKmkA3qcnlg8hvaCBcjJR9MRVeAJDdjtaWaIMPRUeoWuGclxJUqNrO5GBt57fqxOZq2f0g7gsSj0SgsSFMTqIL0oB8GKXhKmBCOzSKwOnqBSBiz8p5PaJOzG2y3qY4dsu9pODaRHKY(qcnhBjgAJDdjJpizC1rtqI0rGUKtEMCdsg)JlqqICILQGGKY(qcn7XDxJ)pGCnJJId)wUghfTBiHMfd(JkaUnHKX1EZ1xcTXUHKjayarZ0vxchykqHLRrxOZi0CWTP89cOl0zi7cAJDdj2eAwdj2pZwiXsANnEqY4dsMno0mwsl0gOn2nKm(N8uGr0mqBSBiz8bjQ(h0oG1qszFiHMJTedTXUHKXhKmU6Ojir6iqxYjptUbjJ)XfiiroXsvqqszFiHM94URX)hqUMXqBG2y3qY4sAILbaRHekUSpdjY1GYbqcflCjcdj0SLsEaGGKCZX3K)gLqdsCj42ebjB2SgdTXUHexcUnr4HNLRbLd6lnhPc0g7gsCj42eHhEwUguoy((Uk7QH2y3qIlb3Mi8WZY1GYbZ33Lhem4e4GBtOn2nKiM(aAAbqY7NgsOcLcRHeeWbiiHIl7ZqICnOCaKqXcxIGep1qYWZJVHfaUuasoeKO3KXqBSBiXLGBteE4z5Aq5G577cL(aAAbveWbiOnUeCBIWdplxdkhmFFxdl42eAJlb3Mi8WZY1GYbZ33L)sp5ky)NtGTxPxvaVXjaB6QW1TuD0eJWC6unwdTbAJDdjJlPjwgaSgsy18BnKaodgsatmK4sW(qYHGexTFnNQXyOnUeCBI6FMkOcdTXLGBt089Dj9wR6sWTzTDiGTPBW9YDB61mrqBCj42enFFxsV1QUeCBwBhcyB6gCVaN87G9rqBG24sWTjcd(lvHbO577kG46bydBt3G7F3U0HufuL6eQpRRubaytOnUeCBIWG)svyaA((UciUEa2W20n4ElWO60A2432R0tfkfSRMtHlfQMVdMWHbffQqPGLFa5AghgOtfkfS8dixZyeWLQ0pJwOnUeCBIWG)svyaA((UciUEa2W20n4E1N3QBP65z4awxPA7QT9k9DtfkfSRMtHlfQMVdMWHbffQqPGLFa5AghgOtfkfS8dixZ4Nn8lrwnJMpIIs3YDB61mXUAofUuOA(oyc)SHFjQJ90QOi3TPxZel)aY1m(zd)suh7PDeOnUeCBIWG)svyaA((UciUEa2W20n4E9UgOAj8wB7v6PcLc2vZPWLcvZ3bt4WGIcvOuWYpGCnJdd0PcLcw(bKRz8Zg(LiRMrZH24sWTjcd(lvHbO577kG46bydBt3G7f8gl9wJFuLIDvS9k9uHsb7Q5u4sHQ57GjCyqrHkuky5hqUMXHb6uHsbl)aY1m(zd)sKvZOb0gxcUnryWFPkmanFFxbexpaByB6gCpL1cBYvkMREZWtxA7v6PcLc2vZPWLcvZ3bt4WGIcvOuWYpGCnJddqBCj42eHb)LQWa089DfqC9aSHTPBW9g8ZQaMCuT4PGTxPVBv9(PRSAobyxRryMMoeaPO8(PRSAobyxRr4l7mJgJOOGg4wRc8xGbiS(uFjxrG9n60Bj0gxcUnryWFPkmanFFxbexpaByB6gC)qlKA(Py)1OAP5ivS9k9uHsb7Q5u4sHQ57GjCyqrHkuky5hqUMXHb6uHsbl)aY1mgbCPkD6NrRIIC3MEntSRMtHlfQMVdMWpB4xI6yhAOOOkQqPGLFa5AghgOl3TPxZel)aY1m(zd)suh7qdOnUeCBIWG)svyaA((UciUEa2W20n4Ek(r8Rc)OQfcwiy7v6PcLc2vZPWLcvZ3bt4WGIcvOuWYpGCnJdd0PcLcw(bKRzmc4sv60pJwff5Un9AMyxnNcxkunFhmHF2WVe1Xo0qrrvuHsbl)aY1momqxUBtVMjw(bKRz8Zg(LOo2HgqBCj42eHb)LQWa089DfqC9aSHTPBW9CQBmcvbxkbHNRBPwExcUn9wDyn532R0tfkfSRMtHlfQMVdMWHbffQqPGLFa5AghgOtfkfS8dixZyeWLQ0PFgTkkYDB61mXUAofUuOA(oyc)SHFjQJDOHIIC3MEntS8dixZ4Nn8lrDSdnG24sWTjcd(lvHbO577kG46bydBt3G7hy)Bv9PMFuvUgdocz7v6PcLc2vZPWLcvZ3bt4WGIcvOuWYpGCnJdd0PcLcw(bKRzmc4sv60pJwOnUeCBIWG)svyaA((UciUEa2W20n4(Y9iq1WbmQIgSwO5iKTxPNkukyxnNcxkunFhmHddkkuHsbl)aY1momqNkuky5hqUMXpB4xISQFgnG24sWTjcd(lvHbO577kG46bydBt3G7nNUVzEPaQo0cgUaB7v6PcLc2vZPWLcvZ3bt4WGIcvOuWYpGCnJdd0PcLcw(bKRz8Zg(LiR6TKwOnUeCBIWG)svyaA((UciUEa2W20n4E9ZUUk0C95G9rvkxlW2ELEQqPGD1CkCPq18DWeomOOqfkfS8dixZ4WaDQqPGLFa5Ag)SHFjYQElPfAJlb3Mim4VufgGMVVRaIRhGnSnDdUx)SRRoA4EpbOQbR9w7202R0tfkfSRMtHlfQMVdMWHbffQqPGLFa5AghgOtfkfS8dixZ4Nn8lrw1BjTqBCj42eHb)LQWa089DfqC9aSHTPBW9c)McO6WFgER(UaB7v6vfvOuWUAofUuOA(oychgORkQqPGLFa5AghgG24sWTjcd(lvHbO577kG46bydBt3G7rxEia)vHMRphSpQs5Ab22R0tfkfSRMtHlfQMVdMWHbffQqPGLFa5AghgOtfkfS8dixZ4Nn8lrw1pJgqBCj42eHb)LQWa089DfqC9aSHTPBW9OlpeG)QqZ1Nd2hvnyT3A3M2ELEQqPGD1CkCPq18DWeomOOqfkfS8dixZ4WaDQqPGLFa5Ag)SHFjYQElPfAJlb3Mim4VufgGMVVRaIRhGnSnDdU3Tl0K)oQw2eu3sDyn532R0RkG34eGLFa5AgZPt1ynD5Un9AMyxnNcxkunFhmHF2WVezfnuuaEJtaw(bKRzmNovJ10L720RzILFa5Ag)SHFjYkAqhCgCNz0QOmTnRRdRj)D6TNo4myRMrlDG34eGnDv46wQoAIryoDQgRH24sWTjcd(lvHbO577kG46bydBt3G7vFOBZ6wQA24qSTxPNkukyxnNcxkunFhmHddkkuHsbl)aY1momqNkuky5hqUMXiGlvPFgTkkYDB61mXUAofUuOA(oyc)SHFjQtV90QOi3TPxZel)aY1m(zd)suNE7PfAJlb3Mim4VufgGMVVRaIRhGnSnDdU3rtQ9Kr13TR9RY99MTxPxZuHsb)UDTFvUV3QAMkuky9AMkkDtfkfSRMtHlfQMVdMWpB4xI60BjTkkuHsbl)aY1mgbCPk9ZOLovOuWYpGCnJF2WVe1zgngHE3YDB61mXcb)1NN1TuD7I)fmHF2WVe1z8OvrbCgCfSv9XwzpTkkQIrioLmwUPMteRRTRWL9Lm2WTW(JaTXLGBteg8xQcdqZ33vaX1dWg2MUb3RsUG6wQEkpob1s4T22R0tfkfSRMtHlfQMVdMWHbffQqPGLFa5AghgOtfkfS8dixZyeWLQ0PFgTkkYDB61mXUAofUuOA(oyc)SHFjQJ90QOOkQqPGLFa5AghgOl3TPxZel)aY1m(zd)suh7PfAJlb3Mim4VufgGMVVRaIRhGnq2ELEQqPGD1CkCPq18DWeomOOqfkfS8dixZ4WaDQqPGLFa5AgJaUuL(z0cTbAJlb3MiSC3MEntu)WcUnT9k9Dl3TPxZele8xFEw3s1Tl(xWe(zd)suNXJwffvXieNsgl3uZjI112v4Y(sgB4wy)rO3nvOuWuTD1TacGF2LaffQqPGD1CkCPq18DWeomOOqfkfS8dixZ4WaDQqPGLFa5Ag)SHFjYklPXiqBCj42eHL720RzIMVVR2jmbqvle0cgCcS9k9ObU1Qa)fyac3oHjaQAHGwWGtqNElvu6wvVF6kRMta21AeMPPdbqkkVF6kRMta21Ae(YoJdngbAJlb3MiSC3MEnt089DvUNPA7QT9k9uHsb7Q5u4sHQ57GjCyqrHkuky5hqUMXHb6uHsbl)aY1mgbCPk9ZOfAJlb3MiSC3MEnt089DHMoUPRBPQMtb2tjB7v6PcLcgXmy6sH67cmwVMjDQqPGnyJ9TUULAlipDv)SBGW61mH24sWTjcl3TPxZenFFxsV1QUeCBwBhcyB6gCp4VufgGG24sWTjcl3TPxZenFFxGjUgsQnK6AzFjB7v6bNbBvVLkkuHsb)SuLgJq1Y(sghgG24sWTjcl3TPxZenFFxuTD11TubtCLt2WABVspvOuWUAofUuOA(oychguuOcLcw(bKRzCyGovOuWYpGCnJraxQs)mAH24sWTjcl3TPxZenFFxcb)1NN1TuD7I)fmz7v6vfWBCcWYpGCnJ50PASME3YDB61mXUAofUuOA(oyc)SHFjYkAqFABwxhwt(70Bp9UPcLc(svlCOdCBIddkkQc4nob4lvTWHoWTjMtNQX6ruuK720RzID1CkCPq18DWe(zd)suNE7qJruu6g4noby5hqUMXC6unwtxUBtVMjw(bKRz8Zg(LiReKA6tBZ66WAYFNE7OOmTnRRdRj)D6TNo4myRMrlDG34eGnDv46wQoAIryoDQgRvuK720RzILFa5Ag)SHFjQtVDOXiqBCj42eHL720RzIMVVlZ9BA18L1NrB6PKT9k9YDB61mXUAofUuOA(oyc)SHFjYkbPM(02SUoSM83P3Eff5Un9AMy5hqUMXpB4xISsqQPpTnRRdRj)D6TJIIC3MEntSRMtHlfQMVdMWpB4xI60BhAOOi3TPxZel)aY1m(zd)suNE7qdOnUeCBIWYDB61mrZ33vzLbeRRUDX)b4kf7g2EL(Uv17NUYQ5eGDTgHzA6qaKIY7NUYQ5eGDTgHVSJ90QOGg4wRc8xGbiS(uFjxrG9n60B5i07MkukyxnNcxkunFhmH1RzsNkuky5hqUMX61mhHE3YDB61mXunxZ1TuTqabojJF2WVe1rqQTO90L720RzITqqlyWja)SHFjQJGuBr7hbAJlb3MiSC3MEnt089DzWg7BDDl1wqE6Q(z3az7v67MkukyxnNcxkunFhmHddkkuHsbl)aY1momqNkuky5hqUMXiGlvPFgTJqFABwxhwt(TQ3EOnUeCBIWYDB61mrZ331q4VI1xkuPAocy7v67wvVF6kRMta21AeMPPdbqkkVF6kRMta21Ae(Yo2tRIcAGBTkWFbgGW6t9LCfb23OtVLJaTXLGBtewUBtVMjA((UciUEa2WwUuyjOMUb3lTw2wWV5jRunhbS9k9DtfkfSRMtHlfQMVdMW61mPtfkfS8dixZy9AMJqVB5Un9AMyQMR56wQwiGaNKXpB4xI6ii1w0E6YDB61mXwiOfm4eGF2WVe1rqQTO9JaTXLGBtewUBtVMjA((UC1CkCPq18DWKTxPVBvb8gNa8LQw4qh42eZPt1yTIcvOuWxQAHdDGBtCyye6tBZ66WAYFNE7H24sWTjcl3TPxZenFFxYpGCnB7v6N2M11H1K)o92rrzABwxhwt(70BpDWzWwnJw6aVXjaB6QW1TuD0eJWC6unwdTbAJlb3MiC5YdnXpQxT)Nt1yBt3G7nVuavh2TzRAVf4EvXQw4ggynEMQB8SFMDO3TQaEJtaw(bKRzmNovJ10L720RzID1CkCPq18DWe(zd)suhbP2I2ROi3TPxZel)aY1m(zd)suhbP2I2pIIcRAHByG14zQUXZ(z2HE3Qc4noby5hqUMXC6unwtxUBtVMj2vZPWLcvZ3bt4Nn8lrDeKAlQ6uuK720RzILFa5Ag)SHFjQJGuBrv3iqBCj42eHlxEOj(rZ33LA)pNQX2MUb3RrvPJaovJTvT3cCpAGBTkWFbgGW6t9LCfb23OtVL0vfWBCcW)jmb4nGQQ5xFsaMtNQXAff0a3AvG)cmaH1N6l5kcSVrNE7Pd8gNa8FctaEdOQA(1NeG50PASwrHkuky2yW6N9SoSM8Jdd01mvOuWwiOfm4eG1RzsNkuky9P(sUoe(HfXy9AM0PcLc2vZPWLcvZ3btvpaw5FaSEntOnUeCBIWLlp0e)O5776svlCOdCBA7v6PcLc2vZPWLcvZ3bty9AM07Mkuk4lvTWHoWTjwVMPIcvOuWxQAHdDGBt8Zg(LiRO50N2M11H1K)o92ROa8gNamttSmaUnRiobCkzmNovJ10L720RzIzAILbWTzfXjGtjJF2WVez1mAPtfkf8LQw4qh42e)SHFjYQz0qrrUBtVMj2vZPWLcvZ3bt4Nn8lrwnJg0PcLc(svlCOdCBIF2WVezLL0sFABwxhwt(70B)iqBCj42eHlxEOj(rZ33fttSmaUnRiobCkzBVspAGBTkWFbgGW6t9LCfb23WQElP3TQaEJtaw(bKRzmNovJ10L720RzID1CkCPq18DWe(zd)suNz0QOa8gNaS8dixZyoDQgRPtfkfS8dixZy9AM0L720RzILFa5Ag)SHFjQZmAvuOcLcw(bKRzmc4sv60poJaTXLGBteUC5HM4hnFFx6t9LCfb23W2R0R2)ZPAmwJQshbCQgtxT)Nt1yS5LcO6WUn6D3TQaEJtaMPjwga3MveNaoLmMtNQXAfLUrdCRvb(lWaewFQVKRiW(gD6TurrUBtVMjMPjwga3MveNaoLm(zd)suhbP2IwoYikkDl3TPxZe7Q5u4sHQ57Gj8Zg(LOocsTfTNUC3MEntSRMtHlfQMVdMWpB4xISAgTkkYDB61mXYpGCnJF2WVe1rqQTO90L720RzILFa5Ag)SHFjYQz0QOqfkfS8dixZ4WaDQqPGLFa5AgJaUufRMr7iJaTXLGBteUC5HM4hnFFxa2yO5pQQMF9jb2ELE1(FovJXMxkGQd72O3TQaEJtaMPjwga3MveNaoLmMtNQXAff5Un9AMyMMyzaCBwrCc4uY4Nn8lrDeKAlAPIIC3MEntSRMtHlfQMVdMWpB4xI6ii1w0E6YDB61mXUAofUuOA(oyc)SHFjYQz0QOi3TPxZel)aY1m(zd)suhbP2I2txUBtVMjw(bKRz8Zg(LiRMrRIcvOuWYpGCnJdd0PcLcw(bKRzmc4svSAgTJaTbAJlb3MiSaN87G9r9Q9)CQgBB6gCVQ3oUTvT3cCF3Qc4nob4j3WG)6wQMVdMWC6unwROa8xGb4j2BGj8Ge0P3sAP3nvOuWUAofUuOA(oycRxZKovOuWYpGCnJ1RzoYiqBCj42eHf4KFhSpA((UKERvDj42S2oeW20n4(YLhAIFKTxPFABwxhwt(70tdffQqPGnyJ9TUULAlipDv)SBGWHbffQqPGrmdMUuO(UaJddkkuHsbFPQfo0bUnX61mPpTnRRdRj)D6ThAJlb3MiSaN87G9rZ33LPRcx3s1rtmY2R03TQE)0vwnNaSR1imtthcGuuE)0vwnNaSR1i8LDMrdff0a3AvG)cmaHnDv46wQoAIrD6TCe6DpTnRRdRj)w1tRIY02SUoSM83pJUC3MEntmvZ1CDlvleqGtY4Nn8lrDeK6rO3TC3MEntSRMtHlfQMVdMWpB4xI6mJwffG34eGLFa5AgZPt1ynD5Un9AMy5hqUMXpB4xI6mJ2rG24sWTjclWj)oyF089Dr1Cnx3s1cbe4KSTxPFABwxhwt(TQ3sfLUN2M11H1K)E7P3TC3MEnt8KByWFDlvZ3bt4Nn8lrDeKAlAPIIA)pNQXyvVDCpYiqBCj42eHf4KFhSpA((USqqlyWjW2R0pTnRRdRj)w1BPIs3tBZ66WAYVv92HE3YDB61mXunxZ1TuTqabojJF2WVe1rqQTOLkkQ9)CQgJv92X9iJaTXLGBtewGt(DW(O577AYnm4VULQ57GjBVs)02SUoSM8BvVDG24sWTjclWj)oyF089Dj3eXY3b3M2EL(PTzDDyn53QElvuM2M11H1KFR6TNUC3MEntmvZ1CDlvleqGtY4Nn8lrDeKAlAPIY02SUoSM83Bh6YDB61mXunxZ1TuTqabojJF2WVe1rqQTOL0L720RzITqqlyWja)SHFjQJGuBrlH24sWTjclWj)oyF089Dj9wR6sWTzTDiGTPBW9Llp0e)iBVspWBCcWtUHb)1TunFhmH50PASMoWFbgGNyVbMWdsGv9wsRIcvOuWUAofUuOA(oychguuOcLcw(bKRzCyaAJlb3MiSaN87G9rZ33L8dixZFfb(tf22R0l3TPxZel)aY18xrG)uHXYj)fyuT8UeCB6To9ZWJdnO3902SUoSM8BvVLkktBZ66WAYVv92txUBtVMjMQ5AUULQfciWjz8Zg(LOocsTfTurzABwxhwt(7TdD5Un9AMyQMR56wQwiGaNKXpB4xI6ii1w0s6YDB61mXwiOfm4eGF2WVe1rqQTOL0L720RzILBIy57GBt8Zg(LOocsTfTCeOnUeCBIWcCYVd2hnFFxsV1QUeCBwBhcyB6gCF5YdnXpcAJlb3MiSaN87G9rZ33LCtjNG3bSUwAUbdTXLGBtewGt(DW(O577s(bKR5VIa)PcB7v6N2M11H1KFR6Td0gxcUnrybo53b7JMVVl)LEYvW(pNaBVs)02SUoSM8BvVDIIQ5hDBghZsANnE0oowoErrt)ZlfqrrvFgd7dynKO6GexcUnHK2Haim0MOy7qauC0OOMlEObIJghBwC0OOlb3MrXNPcQWrroDQgRJZfbXXSmoAuKtNQX64CrrxcUnJIsV1QUeCBwBhcefBhcut3GJIYDB61mrrqCm7JJgf50PASooxu0LGBZOO0BTQlb3M12HarX2Ha10n4OOaN87G9rrqeefhEwUguoioACSzXrJIUeCBgfhwWTzuKtNQX64CrqCmlJJgf50PASooxuu(hG)ZJIQcsaEJta20vHRBP6OjgH50PASok6sWTzu0FPNCfS)ZjicIGOOC3MEntuC04yZIJgf50PASooxuu(hG)ZJIDdjYDB61mXcb)1NN1TuD7I)fmHF2WVebjDGKXJwirrbsufKWieNsgl3uZjI112v4Y(sgB4wyFizeiHoK0nKqfkfmvBxDlGa4NDjasuuGeQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddqcDiHkuky5hqUMXpB4xIGeRGelPbKmsu0LGBZO4WcUnJG4ywghnkYPt1yDCUOO8pa)NhfrdCRvb(lWaeUDctau1cbTGbNaiPtpKyjKOOajDdjQcsE)0vwnNaSR1imtthcGGeffi59txz1CcWUwJWxcjDGKXHgqYirrxcUnJITtycGQwiOfm4eebXXSpoAuKtNQX64Crr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqspKmJ2OOlb3MrXY9mvBxDeehZoXrJIC6unwhNlkk)dW)5rrQqPGrmdMUuO(UaJ1Rzcj0HeQqPGnyJ9TUULAlipDv)SBGW61mJIUeCBgfrth301TuvZPa7PKJG4y0ioAuKtNQX64CrrxcUnJIsV1QUeCBwBhcefBhcut3GJIG)svyakcIJP6IJgf50PASooxuu(hG)ZJIGZGHeR6HelHeffiHkuk4NLQ0yeQw2xY4Wqu0LGBZOiyIRHKAdPUw2xYrqCSXjoAuKtNQX64Crr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqspKmJ2OOlb3MrrQ2U66wQGjUYjByDeehJMhhnkYPt1yDCUOO8pa)NhfvfKa8gNaS8dixZyoDQgRHe6qs3qIC3MEntSRMtHlfQMVdMWpB4xIGeRGeAaj0HKPTzDDyn5hs60dj2dj0HKUHeQqPGVu1ch6a3M4WaKOOajQcsaEJta(svlCOdCBI50PASgsgbsuuGe5Un9AMyxnNcxkunFhmHF2WVebjD6He7qdizeirrbs6gsaEJtaw(bKRzmNovJ1qcDirUBtVMjw(bKRz8Zg(LiiXkirqQHe6qY02SUoSM8djD6He7ajkkqY02SUoSM8djD6He7He6qc4myiXkizgTqcDib4nobytxfUULQJMyeMtNQXAirrbsK720RzILFa5Ag)SHFjcs60dj2HgqYirrxcUnJIcb)1NN1TuD7I)fmfbXXgV4OrroDQgRJZffL)b4)8OOC3MEntSRMtHlfQMVdMWpB4xIGeRGebPgsOdjtBZ66WAYpK0PhsShsuuGe5Un9AMy5hqUMXpB4xIGeRGebPgsOdjtBZ66WAYpK0PhsSdKOOajYDB61mXUAofUuOA(oyc)SHFjcs60dj2HgqIIcKi3TPxZel)aY1m(zd)seK0PhsSdnIIUeCBgfn3VPvZxwFgTPNsocIJnJ24OrroDQgRJZffL)b4)8Oy3qIQGK3pDLvZja7AncZ00HaiirrbsE)0vwnNaSR1i8LqshiXEAHeffibnWTwf4Vadqy9P(sUIa7BajD6HelHKrGe6qs3qcvOuWUAofUuOA(oycRxZesOdjuHsbl)aY1mwVMjKmcKqhs6gsK720RzIPAUMRBPAHacCsg)SHFjcs6ajcsnKyriXEiHoKi3TPxZeBHGwWGta(zd)seK0bseKAiXIqI9qYirrxcUnJILvgqSU62f)hGRuSBebXXMnloAuKtNQX64Crr5Fa(ppk2nKqfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqspKmJwizeiHoKmTnRRdRj)qIv9qI9rrxcUnJIgSX(wx3sTfKNUQF2nqrqCSzwghnkYPt1yDCUOO8pa)Nhf7gsufK8(PRSAobyxRryMMoeabjkkqY7NUYQ5eGDTgHVes6aj2tlKOOajObU1Qa)fyacRp1xYveyFdiPtpKyjKmsu0LGBZO4q4VI1xkuPAocebXXMzFC0OiNovJ1X5IIUeCBgfLwlBl438KvQMJarr5Fa(ppk2nKqfkfSRMtHlfQMVdMW61mHe6qcvOuWYpGCnJ1RzcjJaj0HKUHe5Un9AMyQMR56wQwiGaNKXpB4xIGKoqIGudjwesShsOdjYDB61mXwiOfm4eGF2WVebjDGebPgsSiKypKmsuKlfwcQPBWrrP1Y2c(npzLQ5iqeehBMDIJgf50PASooxuu(hG)ZJIDdjQcsaEJta(svlCOdCBI50PASgsuuGeQqPGVu1ch6a3M4WaKmcKqhsM2M11H1KFiPtpKyFu0LGBZOORMtHlfQMVdMIG4yZOrC0OiNovJ1X5IIY)a8FEuCABwxhwt(HKo9qIDGeffizABwxhwt(HKo9qI9qcDibCgmKyfKmJwiHoKa8gNaSPRcx3s1rtmcZPt1yDu0LGBZOO8dixZrqeefb)LQWauC04yZIJgf50PASooxumDdok(UDPdPkOk1juFwxPcaWMrrxcUnJIVBx6qQcQsDc1N1vQaaSzeehZY4OrroDQgRJZffDj42mkAbgvNwZg)rr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqspKmJ2Oy6gCu0cmQoTMn(JG4y2hhnkYPt1yDCUOOlb3Mrr1N3QBP65z4awxPA7QJIY)a8FEuSBiHkukyxnNcxkunFhmHddqIIcKqfkfS8dixZ4WaKqhsOcLcw(bKRz8Zg(LiiXkizgnhsgbsuuGKUHe5Un9AMyxnNcxkunFhmHF2WVebjDGe7PfsuuGe5Un9AMy5hqUMXpB4xIGKoqI90cjJeft3GJIQpVv3s1ZZWbSUs12vhbXXStC0OiNovJ1X5IIUeCBgf17AGQLWBDuu(hG)ZJIuHsb7Q5u4sHQ57GjCyasuuGeQqPGLFa5AghgGe6qcvOuWYpGCnJF2WVebjwbjZO5rX0n4OOExduTeERJG4y0ioAuKtNQX64CrrxcUnJIcEJLERXpQsXUkrr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1m(zd)seKyfKmJgrX0n4OOG3yP3A8JQuSRseeht1fhnkYPt1yDCUOOlb3MrrkRf2KRumx9MHNUmkk)dW)5rrQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddrX0n4OiL1cBYvkMREZWtxgbXXgN4OrroDQgRJZffDj42mkAWpRcyYr1INcrr5Fa(ppk2nKOki59txz1CcWUwJWmnDiacsuuGK3pDLvZja7AncFjK0bsMrdizeirrbsqdCRvb(lWaewFQVKRiW(gqsNEiXYOy6gCu0GFwfWKJQfpfIG4y084OrroDQgRJZffDj42mko0cPMFk2FnQwAosLOO8pa)NhfPcLc2vZPWLcvZ3bt4WaKOOajuHsbl)aY1momaj0HeQqPGLFa5AgJaUufiPtpKmJwirrbsK720RzID1CkCPq18DWe(zd)seK0bsSdnGeffirvqcvOuWYpGCnJddqcDirUBtVMjw(bKRz8Zg(LiiPdKyhAeft3GJIdTqQ5NI9xJQLMJujcIJnEXrJIC6unwhNlk6sWTzuKIFe)QWpQAHGfcrr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqsNEizgTqIIcKi3TPxZe7Q5u4sHQ57Gj8Zg(LiiPdKyhAajkkqIQGeQqPGLFa5AghgGe6qIC3MEntS8dixZ4Nn8lrqshiXo0ikMUbhfP4hXVk8JQwiyHqeehBgTXrJIC6unwhNlk6sWTzuKtDJrOk4sji8CDl1Y7sWTP3QdRj)rr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqsNEizgTqIIcKi3TPxZe7Q5u4sHQ57Gj8Zg(LiiPdKyhAajkkqIC3MEntS8dixZ4Nn8lrqshiXo0ikMUbhf5u3yeQcUuccpx3sT8UeCB6T6WAYFeehB2S4OrroDQgRJZffDj42mkoW(3Q6tn)OQCngCekkk)dW)5rrQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddqcDiHkuky5hqUMXiGlvbs60djZOnkMUbhfhy)Bv9PMFuvUgdocfbXXMzzC0OiNovJ1X5IIUeCBgfl3JavdhWOkAWAHMJqrr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1m(zd)seKyvpKmJgrX0n4Oy5EeOA4agvrdwl0CekcIJnZ(4OrroDQgRJZffDj42mkAoDFZ8sbuDOfmCbokk)dW)5rrQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddqcDiHkuky5hqUMXpB4xIGeR6HelPnkMUbhfnNUVzEPaQo0cgUahbXXMzN4OrroDQgRJZffDj42mkQF21vHMRphSpQs5Abokk)dW)5rrQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddqcDiHkuky5hqUMXpB4xIGeR6HelPnkMUbhf1p76QqZ1Nd2hvPCTahbXXMrJ4OrroDQgRJZffDj42mkQF21vhnCVNau1G1ERDBgfL)b4)8OivOuWUAofUuOA(oychgGeffiHkuky5hqUMXHbiHoKqfkfS8dixZ4Nn8lrqIv9qIL0gft3GJI6NDD1rd37javnyT3A3MrqCSzQU4OrroDQgRJZffDj42mkk8BkGQd)z4T67cCuu(hG)ZJIQcsOcLc2vZPWLcvZ3bt4WaKqhsufKqfkfS8dixZ4WqumDdokk8BkGQd)z4T67cCeehB24ehnkYPt1yDCUOOlb3Mrr0LhcWFvO56Zb7JQuUwGJIY)a8FEuKkukyxnNcxkunFhmHddqIIcKqfkfS8dixZ4WaKqhsOcLcw(bKRz8Zg(LiiXQEizgnIIPBWrr0LhcWFvO56Zb7JQuUwGJG4yZO5XrJIC6unwhNlk6sWTzueD5Ha8xfAU(CW(OQbR9w72mkk)dW)5rrQqPGD1CkCPq18DWeomajkkqcvOuWYpGCnJddqcDiHkuky5hqUMXpB4xIGeR6HelPnkMUbhfrxEia)vHMRphSpQAWAV1UnJG4yZgV4OrroDQgRJZffDj42mk62fAYFhvlBcQBPoSM8hfL)b4)8OOQGeG34eGLFa5AgZPt1ynKqhsK720RzID1CkCPq18DWe(zd)seKyfKqdirrbsaEJtaw(bKRzmNovJ1qcDirUBtVMjw(bKRz8Zg(LiiXkiHgqcDibCgmK0bsMrlKOOajtBZ66WAYpK0PhsShsOdjGZGHeRGKz0cj0HeG34eGnDv46wQoAIryoDQgRJIPBWrr3Uqt(7OAztqDl1H1K)iioML0ghnkYPt1yDCUOOlb3Mrr1h62SULQMnoehfL)b4)8OivOuWUAofUuOA(oychgGeffiHkuky5hqUMXHbiHoKqfkfS8dixZyeWLQaj9qYmAHeffirUBtVMj2vZPWLcvZ3bt4Nn8lrqsNEiXEAHeffirUBtVMjw(bKRz8Zg(LiiPtpKypTrX0n4OO6dDBw3svZghIJG4ywoloAuKtNQX64CrrxcUnJIoAsTNmQ(UDTFvUV3IIY)a8FEuuZuHsb)UDTFvUV3QAMkuky9AMqIIcK0nKqfkfSRMtHlfQMVdMWpB4xIGKo9qIL0cjkkqcvOuWYpGCnJraxQcK0djZOfsOdjuHsbl)aY1m(zd)seK0bsMrdizeiHoK0nKi3TPxZele8xFEw3s1Tl(xWe(zd)seK0bsgpAHeffibCgCfSv9XqIvqI90cjkkqIQGegH4uYy5MAorSU2Ucx2xYyd3c7djJeft3GJIoAsTNmQ(UDTFvUV3IG4ywAzC0OiNovJ1X5IIUeCBgfvjxqDlvpLhNGAj8whfL)b4)8OivOuWUAofUuOA(oychgGeffiHkuky5hqUMXHbiHoKqfkfS8dixZyeWLQajD6HKz0cjkkqIC3MEntSRMtHlfQMVdMWpB4xIGKoqI90cjkkqIQGeQqPGLFa5AghgGe6qIC3MEntS8dixZ4Nn8lrqshiXEAJIPBWrrvYfu3s1t5XjOwcV1rqCmlTpoAuKtNQX64Crr5Fa(ppksfkfSRMtHlfQMVdMWHbirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqspKmJ2OOlb3MrXaIRhGnqrqeeflxEOj(rXrJJnloAuKtNQX64CrXDikIyqu0LGBZOOA)pNQXrr1ElWrrvbjSQfUHbwJD7cn5VJQLnb1Tuhwt(He6qs3qIQGeG34eGLFa5AgZPt1ynKqhsK720RzID1CkCPq18DWe(zd)seK0bseKAiXIqI9qIIcKi3TPxZel)aY1m(zd)seK0bseKAiXIqI9qYiqIIcKWQw4ggyn2Tl0K)oQw2eu3sDyn5hsOdjDdjQcsaEJtaw(bKRzmNovJ1qcDirUBtVMj2vZPWLcvZ3bt4Nn8lrqshirqQHelcjQoirrbsK720RzILFa5Ag)SHFjcs6ajcsnKyrir1bjJefv7FnDdokAEPaQoSBlcIJzzC0OiNovJ1X5II7queXGOOlb3Mrr1(FovJJIQ9wGJIObU1Qa)fyacRp1xYveyFdiPtpKyjKqhsufKa8gNa8FctaEdOQA(1NeG50PASgsuuGe0a3AvG)cmaH1N6l5kcSVbK0PhsShsOdjaVXja)NWeG3aQQMF9jbyoDQgRHeffiHkuky2yW6N9SoSM8JddqcDirZuHsbBHGwWGtawVMjKqhsOcLcwFQVKRdHFyrmwVMjKqhsOcLc2vZPWLcvZ3btvpaw5FaSEnZOOA)RPBWrrnQkDeWPACeehZ(4OrroDQgRJZffL)b4)8OivOuWUAofUuOA(oycRxZesOdjDdjuHsbFPQfo0bUnX61mHeffiHkuk4lvTWHoWTj(zd)seKyfKqZHe6qY02SUoSM8djD6He7Heffib4nobyMMyzaCBwrCc4uYyoDQgRHe6qIC3MEntmttSmaUnRiobCkz8Zg(LiiXkizgTqcDiHkuk4lvTWHoWTj(zd)seKyfKmJgqIIcKi3TPxZe7Q5u4sHQ57Gj8Zg(LiiXkizgnGe6qcvOuWxQAHdDGBt8Zg(LiiXkiXsAHe6qY02SUoSM8djD6He7HKrIIUeCBgfVu1ch6a3MrqCm7ehnkYPt1yDCUOO8pa)NhfrdCRvb(lWaewFQVKRiW(gqIv9qILqcDiPBirvqcWBCcWYpGCnJ50PASgsOdjYDB61mXUAofUuOA(oyc)SHFjcs6ajZOfsuuGeG34eGLFa5AgZPt1ynKqhsOcLcw(bKRzSEntiHoKi3TPxZel)aY1m(zd)seK0bsMrlKOOajuHsbl)aY1mgbCPkqsNEizCGKrIIUeCBgfzAILbWTzfXjGtjhbXXOrC0OiNovJ1X5IIY)a8FEuuT)Nt1ySgvLoc4ungsOdjQ9)CQgJnVuavh2Tbj0HKUHKUHevbjaVXjaZ0eldGBZkItaNsgZPt1ynKOOajDdjObU1Qa)fyacRp1xYveyFdiPtpKyjKOOajYDB61mXmnXYa42SI4eWPKXpB4xIGKoqIGudjwesSesgbsgbsuuGKUHe5Un9AMyxnNcxkunFhmHF2WVebjDGebPgsSiKypKqhsK720RzID1CkCPq18DWe(zd)seKyfKmJwirrbsK720RzILFa5Ag)SHFjcs6ajcsnKyriXEiHoKi3TPxZel)aY1m(zd)seKyfKmJwirrbsOcLcw(bKRzCyasOdjuHsbl)aY1mgbCPkqIvqYmAHKrGKrIIUeCBgf1N6l5kcSVreeht1fhnkYPt1yDCUOO8pa)Nhfv7)5ungBEPaQoSBdsOdjDdjQcsaEJtaMPjwga3MveNaoLmMtNQXAirrbsK720RzIzAILbWTzfXjGtjJF2WVebjDGebPgsSiKyjKOOajYDB61mXUAofUuOA(oyc)SHFjcs6ajcsnKyriXEiHoKi3TPxZe7Q5u4sHQ57Gj8Zg(LiiXkizgTqIIcKi3TPxZel)aY1m(zd)seK0bseKAiXIqI9qcDirUBtVMjw(bKRz8Zg(LiiXkizgTqIIcKqfkfS8dixZ4WaKqhsOcLcw(bKRzmc4svGeRGKz0cjJefDj42mkcyJHM)OQA(1NeebrquuGt(DW(O4OXXMfhnkYPt1yDCUO4oefrmik6sWTzuuT)Nt14OOAVf4Oy3qIQGeG34eGNCdd(RBPA(oycZPt1ynKOOaja)fyaEI9gycpibqsNEiXsAHe6qs3qcvOuWUAofUuOA(oycRxZesOdjuHsbl)aY1mwVMjKmcKmsuuT)10n4OOQ3oUJG4ywghnkYPt1yDCUOO8pa)NhfN2M11H1KFiPtpKqdirrbsOcLc2Gn2366wQTG80v9ZUbchgGeffiHkukyeZGPlfQVlW4WaKOOajuHsbFPQfo0bUnX61mHe6qY02SUoSM8djD6He7JIUeCBgfLERvDj42S2oeik2oeOMUbhflxEOj(rrqCm7JJgf50PASooxuu(hG)ZJIDdjQcsE)0vwnNaSR1imtthcGGeffi59txz1CcWUwJWxcjDGKz0asuuGe0a3AvG)cmaHnDv46wQoAIrqsNEiXsizeiHoK0nKmTnRRdRj)qIv9qcTqIIcKmTnRRdRj)qspKmdsOdjYDB61mXunxZ1TuTqabojJF2WVebjDGebPgsgbsOdjDdjYDB61mXUAofUuOA(oyc)SHFjcs6ajZOfsuuGeG34eGLFa5AgZPt1ynKqhsK720RzILFa5Ag)SHFjcs6ajZOfsgjk6sWTzu00vHRBP6OjgfbXXStC0OiNovJ1X5IIY)a8FEuCABwxhwt(HeR6HelHeffiPBizABwxhwt(HKEiXEiHoK0nKi3TPxZep5gg8x3s18DWe(zd)seK0bseKAiXIqILqIIcKO2)ZPAmw1Bh3qYiqYirrxcUnJIunxZ1TuTqabojhbXXOrC0OiNovJ1X5IIY)a8FEuCABwxhwt(HeR6HelHeffiPBizABwxhwt(HeR6He7aj0HKUHe5Un9AMyQMR56wQwiGaNKXpB4xIGKoqIGudjwesSesuuGe1(FovJXQE74gsgbsgjk6sWTzu0cbTGbNGiioMQloAuKtNQX64Crr5Fa(ppkoTnRRdRj)qIv9qIDIIUeCBgfNCdd(RBPA(oykcIJnoXrJIC6unwhNlkk)dW)5rXPTzDDyn5hsSQhsSesuuGKPTzDDyn5hsSQhsShsOdjYDB61mXunxZ1TuTqabojJF2WVebjDGebPgsSiKyjKOOajtBZ66WAYpK0dj2bsOdjYDB61mXunxZ1TuTqabojJF2WVebjDGebPgsSiKyjKqhsK720RzITqqlyWja)SHFjcs6ajcsnKyriXYOOlb3Mrr5Miw(o42mcIJrZJJgf50PASooxuu(hG)ZJIaVXjap5gg8x3s18DWeMtNQXAiHoKa8xGb4j2BGj8Geajw1djwslKOOajuHsb7Q5u4sHQ57GjCyasuuGeQqPGLFa5AghgIIUeCBgfLERvDj42S2oeik2oeOMUbhflxEOj(rrqCSXloAuKtNQX64Crr5Fa(ppkk3TPxZel)aY18xrG)uHXYj)fyuT8UeCB6niPtpKmdpo0asOdjDdjtBZ66WAYpKyvpKyjKOOajtBZ66WAYpKyvpKypKqhsK720RzIPAUMRBPAHacCsg)SHFjcs6ajcsnKyriXsirrbsM2M11H1KFiPhsSdKqhsK720RzIPAUMRBPAHacCsg)SHFjcs6ajcsnKyriXsiHoKi3TPxZeBHGwWGta(zd)seK0bseKAiXIqILqcDirUBtVMjwUjILVdUnXpB4xIGKoqIGudjwesSesgjk6sWTzuu(bKR5VIa)PchbXXMrBC0OiNovJ1X5IIUeCBgfLERvDj42S2oeik2oeOMUbhflxEOj(rrqCSzZIJgfDj42mkk3uYj4DaRRLMBWrroDQgRJZfbXXMzzC0OiNovJ1X5IIY)a8FEuCABwxhwt(HeR6He7efDj42mkk)aY18xrG)uHJG4yZSpoAuKtNQX64Crr5Fa(ppkoTnRRdRj)qIv9qIDIIUeCBgf9x6jxb7)CcIGiicIIEamTFuu8mg)rqeeJ]] )


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
