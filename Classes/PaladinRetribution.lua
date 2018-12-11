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
            duration = function () return azerite.lights_decree.enabled and 25 or 20 end,
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
        divine_right = not PTR and {
            id = 278523,
            duration = 15,
            max_stack = 1,
        } or nil,

        empyreal_ward = PTR and {
            id = 287731,
            duration = 60,
            max_stack = 1,
        },

        empyrean_power = PTR and {
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
            cooldown = 120,
            gcd = "spell",

            toggle = 'cooldowns',
            notalent = 'crusade',
            
            startsCombat = true,
            texture = 135875,
            
            usable = function () return not buff.avenging_wrath.up end,
            handler = function ()
                applyBuff( 'avenging_wrath' )
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
                if buff.empyrean_power.up then return 0 end
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
            
            handler = function ()
                gain( health.max, "health" )
                applyDebuff( 'player', 'forbearance', 30 )
                if PTR and azerite.empyreal_ward.enabled then applyBuff( "empyrael_ward" ) end
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

    
    spec:RegisterPack( "Retribution", 20181210.0018, [[dGKvYaqiQiEevKSjPsFcfkJcb1PqHSkQq9kqWSeQ6wkO0Ue8luWWuqogvWYqGNPGQPjvKRjuPTrfP8nPIQXHGuNtQOqRtOmpfO7Pq7ti5GsfLwOc4HOqLjkvuWfPIu9rPIIgPckojcIwjiAMOqv7KkQHIGWsfQWtr0urrDveK8vHkAVe(lvnyIomLfJspgvtMKlRAZG6ZG0OLItdSAHuVgfz2K62uPDl63knCP0XbHwouphY0LCDfTDH47svJNkKZlvy(i0(rAHdcMfKkRUWzcgYbcTde4GdHHgYbc9qonbz1r7fKTgNjd6fKP5EbzC8cdyNfytbzR1HEnLGzbjANy(fKnv1IIXadqbvZKnWxxgqa3P2kWMCSbxmGaUCgy1lldSW2WQEegAXlmqFedmdoMahyGzcCWtimTPaPpoEHbSZcSzabC5cs2jqxeYuWkivwDHZemKdeAhiWbhcdnKdDEC7CbjQ9CHZD(qcYgGs9uWkivhXfKofvghVWa2zb2KkjeM2uGKcPtrLnv1IIXadqbvZKnWxxgqa3P2kWMCSbxmGaUCgy1lldSW2WQEegAXlmqFedec8JddOqmqiIdpHW0McK(44fgWolWMbeWLtH0POYodNFx2JPshCiEQKGHCGqtLdlvo0qXgIakKuiDkQKX1yj0JIrH0POYHLk7Sk1vujHcDQKqw3ffeKT4fgOVG0POY44fgWolWMujHW0McKuiDkQSPQwumgyakOAMSb(6Yac4o1wb2KJn4IbeWLZaREzzGf2gw1JWqlEHb6JyGqGFCyafIbcrC4jeM2uG0hhVWa2zb2mGaUCkKofv2z487YEmv6GdXtLemKdeAQCyPYHgk2qeqHKcPtrLmUglHEumkKofvoSuzNvPUIkjuOtLeY6UOafskKofv60D05Z6kQK9Wl(ujFDzTIkzpuqIcuzNLZFBHOYCZHTXWUWtnvA8cSjIk3u3rGcPXlWMOql(81L1QryTHyIcPXlWMOql(81L1kimYa8UkkKgVaBIcT4ZxxwRGWid2eQ7ZYkWMuiDkQKmTwuZwuj2akQKDcdFfvIkRquj7Hx8Ps(6YAfvYEOGerLwQOYw8h22TkqcLkbiQuT5duinEb2efAXNVUSwbHrgqP1IA2YJkRquinEb2efAXNVUSwbHrgA3cSjfsJxGnrHw85RlRvqyKbdZT8(AX4Nv8a4rNuM(zf6nMUFH9gQ5OWtJvFffskKofv60D05Z6kQ8roUdQSaUNkRMtLgVwmvcquPfXaAJv)afsJxGnrJ2SwVvLXzIcPXlWMiimYa(StMofsJxGnrqyKbUP1EJxGn9AaQIpn3pUTppMcPXlWMiimYa30AVXlWMEnavXNM7h57QvBFIOqA8cSjccJmWnT2B8cSPxdqv8P5(rOpp2QfJOqsH04fytuGVRwT9jACIUhu3n(0C)y0h5B2E9XXdGhzNWWblYtOGeQVhBvty2sKi7egoWXtKPEy22LDcdh44jYupGkJZ0OddrH04fytuGVRwT9jccJmmr3dQ7IIhapYoHHdwKNqbjuFp2QMWSLir2jmCGJNit9WSTl7egoWXtKPEavgNPrhgIcPXlWMOaFxTA7teegzODlWMXdGhjm7egoWQ3vPNOkGVXlIezNWWblYtOGeQVhBvty2sKi7egoWXtKPEy22LDcdh44jYupGVRbs0GeexIeldd9vOaU3xRxb(GJDAigrH04fytuGVRwT9jccJmObqBkKp6PcQ7ZkEa8iQ9ATVmm0xOGgaTPq(ONkOUpROgjGirc7eSbu(h5zfmLcfUJaOcrKi2ak)J8ScMsHcGmQopUmIcPXlWMOaFxTA7teegzagGpRExv8a4r2jmCWI8ekiH67Xw1eMTejYoHHdC8ezQhMTDzNWWboEIm1dOY4mn6WquinEb2ef47QvBFIGWidOgW1k)c7J8e6TKFkKgVaBIc8D1QTprqyKblYtOGeQVhBvt8a4r2jmCaKqCcqGcSzy2sKOtkt)ScGeItacuGndpnw9vuinEb2ef47QvBFIGWidC8ezQhpaESz1D4B3(JJAStuiPqA8cSjkadsaQ5y0yeddmw9Jpn3pQqEUHkJv)4Jy65hrTxR9LHH(cfuGiG8EuTy3OgjGcPXlWMOamibOMJrqyKbqcXjabkWMXdGhzNWWbqcXjabkWMb12NejYoHHdGeItacuGnd47AGenyC72S6o8TB)XrnoCIelt)Sc3rNplWME0Z6j)HNgR(QU8D1QTpd3rNplWME0Z6j)b8DnqIg0HH6YoHHdGeItacuGnd47AGenOdXLir(UA12NblYtOGeQVhBvtaFxdKObDiUDzNWWbqcXjabkWMb8DnqIgKGH62S6o8TB)XrnoCkKgVaBIcWGeGAogbHrgUJoFwGn9ON1t(JhapIAVw7ldd9fkOara59OAXUdosqxc7KY0pRahprM6HNgR(kIe57QvBFg44jYupGVRbsuuq5khtaJOqA8cSjkadsaQ5yeegzqbIaY7r1IDJhapgXWaJv)Gc55gQmw97YoHHdkqeqEF7e3UOhW34ffsJxGnrbyqcqnhJGWidkqeqEpQwSB8a4XiggyS6huip3qLXQFxc7KY0pRahprM6HNgR(kIe57QvBFg44jYupGVRbsuuq5khtaJisKDcdhUBBh4BPVD7pomB7Qo7egoe9ub19zfuBF2LDcdhuGiG8(2jUDrpO2(KcPXlWMOamibOMJrqyKH6UTAdJ8rowb4v8a4r2jmCqbIaY7BN42f9a(gVOqA8cSjkadsaQ5yeegzOUBR2WiFKJvaEfpaEKWoPm9ZkWXtKPE4PXQVIir(UA12NboEIm1d47AGeffuUYXdNrDjStkt)Sc3rNplWME0Z6j)HNgR(kIezNWWboEIm1dZ2USty4ahprM6buzCMg0HHisKVRwT9z4o68zb20JEwp5pGVRbsuuq5khtaJOqsH04fytua6ZJTAXOXiggyS6hFAUFCy24m(iME(rc7KY0pRqJ56ESFH99yRAcpnw9vejwgg6RqZnD1eA5vuJemuxcZoHHdwKNqbjuFp2QMGA7tIezNWWboEIm1dQTpzeJOqA8cSjka95XwTyeegzGBAT34fytVgGQ4tZ9JWGeGAogfpaESz1D4B3(JJAmUuinEb2efG(8yRwmccJm0BmD)c7nuZrXdGhjStWgq5FKNvWuku4ocGkerIydO8pYZkykfkaYOCiUejIAVw7ldd9fk0BmD)c7nuZrrnsaJ6s4Mv3HVD7pEWXHisSz1D4B3(JhDOlFxTA7ZaR2u3VW(ONOcWFaFxdKOOGYvmIcPXlWMOa0NhB1IrqyKbwTPUFH9rprfG)4bWJnRUdF72F8GJeqKiHBwDh(2T)4XH3LW8D1QTpdnMR7X(f23JTQjGVRbsuuq5khtarIrmmWy1pmmBCYigrH04fytua6ZJTAXiimYq0tfu3Nv8a4XMv3HVD7pEWrcisKWnRUdF72F8GJDQlH57QvBFgy1M6(f2h9eva(d47AGeffuUYXeqKyeddmw9ddZgNmIruinEb2efG(8yRwmccJm0yUUh7xyFp2QM4bWJnRUdF72F8GJDIcPXlWMOa0NhB1IrqyKb(MOZXwb2mEa8yZQ7W3U9hp4ibej2S6o8TB)Xdoo8U8D1QTpdSAtD)c7JEIka)b8DnqIIckx5ycisSz1D4B3(Jh7ux(UA12NbwTPUFH9rprfG)a(UgirrbLRCmbD57QvBFgIEQG6(Sc47AGeffuUYXeqH04fytua6ZJTAXiimYa30AVXlWMEnavXNM7hHbja1CmkEa8yz6NvOXCDp2VW(ESvnHNgR(QUeUmm0xHMB6Qj0YRbhjyiIezNWWblYtOGeQVhBvty2sKi7egoWXtKPEy2YikKgVaBIcqFESvlgbHrg44jYuh7rfgW0JhapY3vR2(mWXtKPo2JkmGPh4ngg6rEySXlWMMoQrhcDEC7s4Mv3HVD7pEWrcisSz1D4B3(JhCC4D57QvBFgy1M6(f2h9eva(d47AGeffuUYXeqKyZQ7W3U9hp2PU8D1QTpdSAtD)c7JEIka)b8DnqIIckx5yc6Y3vR2(me9ub19zfW31ajkkOCLJjOlFxTA7ZaFt05yRaBgW31ajkkOCLJjGruinEb2efG(8yRwmccJmWnT2B8cSPxdqv8P5(ryqcqnhJOqA8cSjka95XwTyeegzGJNitDShvyatpEa8yZQ7W3U9hp4yNOqA8cSjka95XwTyeegzWWClVVwm(zfpaESz1D4B3(JhCStuiPqA8cSjkSTppEeDioFYF8a4XY0pRqVX09lS3qnhfEAS6R6wM(zf44jYup80y1x1Tm9ZkChD(SaB6rpRN8hEAS6R66KY0pRqJ56ESFH99yRAcpnw9vXNM7h7nMUFBFES3Pt6zCKXqnGRv(f2h5j0Bj)Xy1M6(f2h9eva(Jf9ub19zfJJNit9y1DB1gg5JCScWRy9gt3VWEd1CuS6UTAdJ8rowb4vmoEIm1XEuHbm9y3rNplWME0Z6j)uinEb2ef22NhdHrgqhIZN8hpaESm9Zk0BmD)c7nuZrHNgR(QULPFwboEIm1dpnw9vDDsz6Nv4o68zb20JEwp5p80y1x11jLPFwHgZ19y)c77Xw1eEAS6RIpn3p2BmD)2(8ypJJmgQbCTYVW(ipHEl5pgR2u3VW(ONOcWFSONkOUpRyC8ezQhRUBR2WiFKJvaEfR3y6(f2BOMJIv3TvByKpYXkaVIXXtKPo2JkmGPhRUBR2WiFKJvaErH04fytuyBFEmegzaDioFYF8a4XY0pRqVX09lS3qnhfEAS6R6wM(zf44jYup80y1x1Tm9ZkChD(SaB6rpRN8hEAS6R6wM(zfAmx3J9lSVhBvt4PXQVk(0C)yVX09B7ZJ9oDs)WSXzmud4ALFH9rEc9wYFmwTPUFH9rprfG)yrpvqDFwX44jYupwD3wTHr(ihRa8kwVX09lS3qnhfRUBR2WiFKJvaEfRXCDp2VW(ESvnXUJoFwGn9ON1t(PqA8cSjkSTppgcJmGoeNp5pEa8yz6NvO3y6(f2BOMJcpnw9vDlt)ScC8ezQhEAS6R66KY0pRWD05ZcSPh9SEYF4PXQVQBz6NvOXCDp2VW(ESvnHNgR(Q4tZ9J9gt3VTpp2pmBCgd1aUw5xyFKNqVL8hJvBQ7xyF0tub4pw0tfu3NvmoEIm1Jv3TvByKpYXkaVI1BmD)c7nuZrXQ72QnmYh5yfGxXAmx3J9lSVhBvtS6UTAdJ8rowb4ffsJxGnrHT95XqyKb0H48j)XdGhlt)Sc9gt3VWEd1Cu4PXQVQBz6NvaKqCcqGcSz4PXQVk(0C)yVX09B7ZJ9eYeIXqnGRv(f2h5j0Bj)Xy1M6(f2h9eva(Jf9ub19zfdKqCcqGcSzmlYtOGeQVhBvtSEJP7xyVHAosqg5yeytHZemKdeAhiWHHcdnKdoii7nCcsOibzC2zJdNjKo3zgJkPsMBovcCBxCrLWlMkzST95XmgvIpeNa8vujADpvAZADT6kQK3yj0Jcuiz8G8uPdXOscvIMTTlUUIknEb2Kkzm0H48j)mwGcjJhKNkjigvsOs0STDX1vuPXlWMujJHoeNp5NXcuiz8G8u5WJrLeQenBBxCDfvA8cSjvYyOdX5t(zSafsgpipv2PyujHkrZ22fxxrLgVaBsLmg6qC(KFglqHKXdYtLXngvsOs0STDX1vuPXlWMujJHoeNp5NXcuiPqgND24WzcPZDMXOsQK5MtLa32fxuj8IPsgtDyBQlgJkXhIta(kQeTUNkTzTUwDfvYBSe6rbkKmEqEQ0HyujHkrZ22fxxrLgVaBsLmMnR1BvzCMySafskKes32fxxrLonQ04fytQudqfkqHuqAZQzXcssGlJtqQbOcjywqUTppwWSWzhemliFAS6RediinEb2uqIoeNp5xqMM7fK9gt3VTpp270j9moYyOgW1k)c7J8e6TK)ySAtD)c7JEIka)XIEQG6(SIXXtKPES6UTAdJ8rowb4vSEJP7xyVHAokwD3wTHr(ihRa8kghprM6ypQWaMES7OZNfytp6z9KFbjhdQJbMGSm9Zk0BmD)c7nuZrHNgR(kQSlvwM(zf44jYup80y1xrLDPYY0pRWD05ZcSPh9SEYF4PXQVIk7sLoHklt)ScnMR7X(f23JTQj80y1xjkHZeiywq(0y1xjgqqA8cSPGeDioFYVGmn3li7nMUFBFESNXrgd1aUw5xyFKNqVL8hJvBQ7xyF0tub4pw0tfu3NvmoEIm1Jv3TvByKpYXkaVI1BmD)c7nuZrXQ72QnmYh5yfGxX44jYuh7rfgW0Jv3TvByKpYXkaVeKCmOogycYY0pRqVX09lS3qnhfEAS6ROYUuzz6NvGJNit9WtJvFfv2LkDcvwM(zfUJoFwGn9ON1t(dpnw9vuzxQ0juzz6NvOXCDp2VW(ESvnHNgR(krjCE4cMfKpnw9vIbeKgVaBkirhIZN8litZ9cYEJP732Nh7D6K(HzJZyOgW1k)c7J8e6TK)ySAtD)c7JEIka)XIEQG6(SIXXtKPES6UTAdJ8rowb4vSEJP7xyVHAokwD3wTHr(ihRa8kwJ56ESFH99yRAIDhD(SaB6rpRN8li5yqDmWeKLPFwHEJP7xyVHAok80y1xrLDPYY0pRahprM6HNgR(kQSlvwM(zfUJoFwGn9ON1t(dpnw9vuzxQSm9Zk0yUUh7xyFp2QMWtJvFLOeo3jbZcYNgR(kXacsJxGnfKOdX5t(fKP5EbzVX09B7ZJ9dZgNXqnGRv(f2h5j0Bj)Xy1M6(f2h9eva(Jf9ub19zfJJNit9y1DB1gg5JCScWRy9gt3VWEd1CuS6UTAdJ8rowb4vSgZ19y)c77Xw1eRUBR2WiFKJvaEji5yqDmWeKLPFwHEJP7xyVHAok80y1xrLDPYY0pRahprM6HNgR(kQSlv6eQSm9ZkChD(SaB6rpRN8hEAS6ROYUuzz6NvOXCDp2VW(ESvnHNgR(krjCoUcMfKpnw9vIbeKgVaBkirhIZN8litZ9cYEJP732Nh7jKjeJHAaxR8lSpYtO3s(JXQn19lSp6jQa8hl6PcQ7ZkgiH4eGafyZywKNqbjuFp2QMy9gt3VWEd1CKGKJb1XatqwM(zf6nMUFH9gQ5OWtJvFfv2Lklt)ScGeItacuGndpnw9vIsucs1HTPUemlC2bbZcsJxGnfK2SwVvLXzsq(0y1xjgqucNjqWSG04fytbj(StMUG8PXQVsmGOeopCbZcYNgR(kXacsJxGnfKCtR9gVaB61auji1au5tZ9cYT95XIs4CNemliFAS6RediinEb2uqYnT2B8cSPxdqLGudqLpn3li57QvBFIeLW54kywq(0y1xjgqqA8cSPGKBAT34fytVgGkbPgGkFAUxqc95XwTyKOeLGSfF(6YALGzHZoiywq(0y1xjgqucNjqWSG8PXQVsmGOeopCbZcYNgR(kXaIs4CNemliFAS6RedikHZXvWSG04fytbz7wGnfKpnw9vIbeLWzNMGzb5tJvFLyabjhdQJbMG0juzz6NvO3y6(f2BOMJcpnw9vcsJxGnfKgMB591IXplrjkbjFxTA7tKGzHZoiywq(0y1xjgqqA8cSPGm6J8nBV(ybjhdQJbMGKDcdhSipHcsO(ESvnHzlvsKivYoHHdC8ezQhMTuzxQKDcdh44jYupGkJZevosLomKGmn3liJ(iFZ2RpwucNjqWSG8PXQVsmGGKJb1XatqYoHHdwKNqbjuFp2QMWSLkjsKkzNWWboEIm1dZwQSlvYoHHdC8ezQhqLXzIkhPshgsqA8cSPGCIUhu3fjkHZdxWSG8PXQVsmGGKJb1XatqsyQKDcdhy17Q0tufW34fvsKivYoHHdwKNqbjuFp2QMWSLkjsKkzNWWboEIm1dZwQSlvYoHHdC8ezQhW31ajIkhKkjiUujrIuzzyOVcfW9(A9kWPYbhPYonevYibPXlWMcY2TaBkkHZDsWSG8PXQVsmGGKJb1XatqIAVw7ldd9fkObqBkKp6PcQ7ZIkJAKkjGkjsKkjmv6eQeBaL)rEwbtPqH7iaQqujrIuj2ak)J8ScMsHcGKkJIk784sLmsqA8cSPGudG2uiF0tfu3NLOeohxbZcYNgR(kXacsoguhdmbj7egoyrEcfKq99yRAcZwQKirQKDcdh44jYupmBPYUuj7egoWXtKPEavgNjQCKkDyibPXlWMcsya(S6DvIs4SttWSG04fytbjQbCTYVW(ipHEl5xq(0y1xjgqucN7CbZcYNgR(kXacsoguhdmbj7egoasiobiqb2mmBPsIePsNqLLPFwbqcXjabkWMHNgR(kbPXlWMcslYtOGeQVhBvJOeotOfmliFAS6Redii5yqDmWeKnRUdF72Fmvg1iv2jbPXlWMcsoEIm1fLOeKWGeGAogjyw4SdcMfKpnw9vIbeKrm98csu71AFzyOVqbficiVhvl2LkJAKkjqqA8cSPGmIHbgR(cYig2NM7fKkKNBOYy1xucNjqWSG8PXQVsmGGKJb1XatqYoHHdGeItacuGndQTpPsIePs2jmCaKqCcqGcSzaFxdKiQCqQmUuzxQSz1D4B3(JPYOgPYHtLejsLLPFwH7OZNfytp6z9K)WtJvFfv2Lk57QvBFgUJoFwGn9ON1t(d47AGerLdsLomev2LkzNWWbqcXjabkWMb8DnqIOYbPshIlvsKivY3vR2(myrEcfKq99yRAc47AGerLdsLoexQSlvYoHHdGeItacuGnd47AGerLdsLemev2LkBwDh(2T)yQmQrQC4csJxGnfKGeItacuGnfLW5Hlywq(0y1xjgqqYXG6yGjirTxR9LHH(cfuGiG8EuTyxQCWrQKaQSlvsyQ0juzz6NvGJNit9WtJvFfvsKivY3vR2(mWXtKPEaFxdKiQmkQekxrLoMkjGkzKG04fytb5D05ZcSPh9SEYVOeo3jbZcYNgR(kXacsoguhdmbzeddmw9dkKNBOYy1Nk7sLSty4GcebK33oXTl6b8nEjinEb2uqQara59OAXUIs4CCfmliFAS6Redii5yqDmWeKrmmWy1pOqEUHkJvFQSlvsyQ0juzz6NvGJNit9WtJvFfvsKivY3vR2(mWXtKPEaFxdKiQmkQekxrLoMkjGkzevsKivYoHHd3TTd8T03U9hhMTuzxQuD2jmCi6PcQ7ZkO2(Kk7sLSty4GcebK33oXTl6b12NcsJxGnfKkqeqEpQwSROeo70emliFAS6Redii5yqDmWeKSty4GcebK33oXTl6b8nEjinEb2uqw3TvByKpYXkaVeLW5oxWSG8PXQVsmGGKJb1XatqsyQ0juzz6NvGJNit9WtJvFfvsKivY3vR2(mWXtKPEaFxdKiQmkQekxrLoMkhovYiQSlvsyQ0juzz6Nv4o68zb20JEwp5p80y1xrLejsLSty4ahprM6Hzlv2LkzNWWboEIm1dOY4mrLdsLomevsKivY3vR2(mChD(SaB6rpRN8hW31ajIkJIkHYvuPJPscOsgjinEb2uqw3TvByKpYXkaVeLOeKqFESvlgjyw4SdcMfKpnw9vIbeKrm98csctLoHklt)ScnMR7X(f23JTQj80y1xrLejsLLHH(k0CtxnHwErLrnsLemev2LkjmvYoHHdwKNqbjuFp2QMGA7tQKirQKDcdh44jYupO2(KkzevYibPXlWMcYiggyS6liJyyFAUxqomBCkkHZeiywq(0y1xjgqqYXG6yGjiBwDh(2T)yQmQrQmUcsJxGnfKCtR9gVaB61auji1au5tZ9csyqcqnhJeLW5Hlywq(0y1xjgqqYXG6yGjijmv6eQeBaL)rEwbtPqH7iaQqujrIuj2ak)J8ScMsHcGKkJIkDiUujrIujQ9ATVmm0xOqVX09lS3qnhrLrnsLeqLmIk7sLeMkBwDh(2T)yQCWrQCiQKirQSz1D4B3(JPYrQ0bQSlvY3vR2(mWQn19lSp6jQa8hW31ajIkJIkHYvujJeKgVaBki7nMUFH9gQ5irjCUtcMfKpnw9vIbeKCmOogycYMv3HVD7pMkhCKkjGkjsKkjmv2S6o8TB)Xu5ivoCQSlvsyQKVRwT9zOXCDp2VW(ESvnb8DnqIOYOOsOCfv6yQKaQKirQmIHbgR(HHzJtQKrujJeKgVaBkiz1M6(f2h9eva(fLW54kywq(0y1xjgqqYXG6yGjiBwDh(2T)yQCWrQKaQKirQKWuzZQ7W3U9htLdosLDIk7sLeMk57QvBFgy1M6(f2h9eva(d47AGerLrrLq5kQ0XujbujrIuzeddmw9ddZgNujJOsgjinEb2uqg9ub19zjkHZonbZcYNgR(kXacsoguhdmbzZQ7W3U9htLdosLDsqA8cSPGSXCDp2VW(ESvnIs4CNlywq(0y1xjgqqYXG6yGjiBwDh(2T)yQCWrQKaQKirQSz1D4B3(JPYbhPYHtLDPs(UA12NbwTPUFH9rprfG)a(UgiruzuujuUIkDmvsavsKiv2S6o8TB)Xu5iv2jQSlvY3vR2(mWQn19lSp6jQa8hW31ajIkJIkHYvuPJPscOYUujFxTA7Zq0tfu3NvaFxdKiQmkQekxrLoMkjqqA8cSPGKVj6CSvGnfLWzcTGzb5tJvFLyabjhdQJbMGSm9Zk0yUUh7xyFp2QMWtJvFfv2Lkjmvwgg6RqZnD1eA5fvo4ivsWqujrIuj7egoyrEcfKq99yRAcZwQKirQKDcdh44jYupmBPsgjinEb2uqYnT2B8cSPxdqLGudqLpn3liHbja1CmsucN7mkywq(0y1xjgqqYXG6yGji57QvBFg44jYuh7rfgW0d8gdd9ipm24fytttLrnsLoe684sLDPsctLnRUdF72Fmvo4ivsavsKiv2S6o8TB)Xu5GJu5WPYUujFxTA7ZaR2u3VW(ONOcWFaFxdKiQmkQekxrLoMkjGkjsKkBwDh(2T)yQCKk7ev2Lk57QvBFgy1M6(f2h9eva(d47AGerLrrLq5kQ0XujbuzxQKVRwT9zi6PcQ7ZkGVRbsevgfvcLROshtLeqLDPs(UA12Nb(MOZXwb2mGVRbsevgfvcLROshtLeqLmsqA8cSPGKJNitDShvyatxucNDyibZcYNgR(kXacsJxGnfKCtR9gVaB61auji1au5tZ9csyqcqnhJeLWzhCqWSG8PXQVsmGGKJb1Xatq2S6o8TB)Xu5GJuzNeKgVaBki54jYuh7rfgW0fLWzhiqWSG8PXQVsmGGKJb1Xatq2S6o8TB)Xu5GJuzNeKgVaBkinm3Y7RfJFwIsuIsuIsia]] )


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
