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


    -- PvP Talents
    spec:RegisterPvpTalents( { 
        relentless = 3446, -- 196029
        adaptation = 3445, -- 214027
        gladiators_medallion = 3444, -- 208683
        
        blessing_of_sanctuary = 752, -- 210256
        cleansing_light = 3055, -- 236186
        divine_punisher = 755, -- 204914
        hammer_of_reckoning = 756, -- 247675
        jurisdiction = 757, -- 204979
        law_and_order = 858, -- 204934
        lawbringer = 754, -- 246806
        luminescence = 81, -- 199428
        ultimate_retribution = 753, -- 287947
        unbound_freedom = 641, -- 305394
        vengeance_aura = 751, -- 210323
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
            max_stack = 1,
            copy = "avenging_wrath_crit"
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

        -- PvP
        reckoning = {
            id = 247677,
            max_stack = 30,
            duration = 30
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


        hammer_of_reckoning = {
            id = 247675,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            -- texture = ???,

            pvptalent = "hammer_of_reckoning",

            usable = function () return buff.reckoning.stack >= 50 end,
            handler = function ()
                removeStack( "reckoning", 50 )
                if talent.crusade.enabled then
                    applyBuff( "crusade", 12 )
                else
                    applyBuff( "avenging_wrath", 6 )
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

            usable = function () return incoming_damage_3s > 0.2 * health.max, "incoming damage over 3s is less than 20% of max health" end,
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


    spec:RegisterPack( "Retribution", 20190818, [[dCuAybqiKIEKcvSjsYOuioLKuRsq4vkQAwck3sHQyxq9lbvddP0XuuwgfPNjjzAiv6Aif2gsf13OiQgNGOoNcv16qQinpkk3tb7tsCqkIslurLhIurmrfQKCrfQKAJkuLyKuefNuHkHvkiTtfkdvHQKwQcvPEkjMQcPRQqLOVQqLAVc9xPmyehMQfJKht0Kj1LrTzj(mbJwroTkRMIWRrQA2s1TPWUf9BLgUK64uez5Q65qMoW1P02jP(UaJhPcNNIQ1liY8j0(bDCwC0OI2bCCmtPD24tBiplKXZmLg010zrfG51CuP2L07cCujDdoQmEZG)OSGBZOsTBEFDDC0OcATVKJktaqnIon8WfoWKLclxJWrNHT7GBt57fq4OZqgEuHYEDW4Imsfv0oGJJzkTZgFAd5zHmEMP0GUMgvq1SmoMjN2OY0P1CgPIkAgjJkJdKmEZG)OSGBtiz8Q3D9LWqhhizcaQr0PHhUWbMSuy5Aeo6mSDhCBkFVachDgYWHHooqIjRvWIaqYSqomiXuANn(qY4bsMzkDkDPbmuyOJdKqNm5PaJOtHHooqY4bsgxwRDaRHKY(qsiJnfddDCGKXdKmE5Odir6iq4YjptUdj0jJRqqICIL0JGKY(qIj74oC6K3ICnJJk1)wUohvghiz8Mb)rzb3MqY4vV76lHHooqYeauJOtdpCHdmzPWY1iC0zy7o42u(Ebeo6mKHddDCGetwRGfbGKzHCyqIP0oB8HKXdKmZu6u6sdyOWqhhiHozYtbgrNcdDCGKXdKmUSw7awdjL9HKqgBkgg64ajJhiz8YrhqI0rGWLtEMChsOtgxHGe5elPhbjL9Het2XD40jVf5Agddfg64ajJRPdwAbSgsO4Y(mKixdkhajuSWLimKyYkLCnabj5MJNj)nk2oK4sWTjcs2SBogg64ajUeCBIW1plxdkhmu6oIEyOJdK4sWTjcx)SCnOCW8dHx2vddDCGexcUnr46NLRbLdMFiC3kyWjWb3MWqhhirj9A00cGK3pnKqzlfwdjiGdqqcfx2NHe5Aq5aiHIfUebjEQHK6Nhp1laCPaKCiirVjJHHooqIlb3MiC9ZY1GYbZpeok9A00cAiGdqWqDj42eHRFwUguoy(HWRxWTjmuxcUnr46NLRbLdMFiC)LEYnW(pNGWUYanbENtaoWPNBBP5OjgH50P6Sggkm0XbsgxthS0cynKWQ53CibCgmKaMyiXLG9HKdbjUA)6ovNXWqDj42en8mLLEggQlb3MO5hcx69EZLGBZw)qGWs3GhK721BqIGH6sWTjA(HWLEV3Cj42S1peiS0n4bbo53b7JGHcd1LGBteg8xspdqZpeUfXTdWgHLUbp8EiPTj9Og1j0Ew3OSaWMWqDj42eHb)L0Za08dHBrC7aSryPBWdMGrTPnOZFyxzGYwkyxnNcxk0cEhmHT1IIu2sblFlY1m2wRIYwky5BrUMXiGlPFygTWqDj42eHb)L0Za08dHBrC7aSryPBWdQpV32sZZZWbSUr13vh2vggHYwkyxnNcxk0cEhmHT1IIu2sblFlY1m2wRIYwky5BrUMXpB4xImBwixTO4iYD76niXUAofUuOf8oyc)SHFjQsv0kkk3TR3GelFlY1m(zd)suLQOTAyOUeCBIWG)s6zaA(HWTiUDa2iS0n4b9UgOwX(Mh2vgOSLc2vZPWLcTG3btyBTOiLTuWY3ICnJT1QOSLcw(wKRz8Zg(LiZMfYWqDj42eHb)L0Za08dHBrC7aSryPBWdcENLEVZpQrXo9HDLbkBPGD1CkCPql4DWe2wlkszlfS8TixZyBTkkBPGLVf5Ag)SHFjYSz0agQlb3Mim4VKEgGMFiClIBhGnclDdEGYCHn5gfZnVB4Pld7kdu2sb7Q5u4sHwW7GjSTwuKYwky5BrUMX2AyOUeCBIWG)s6zaA(HWTiUDa2iS0n4bd(z6btoQv8uiSRmmcnF)0nwnNaSR1imthhcGefF)0nwnNaSR1i8LvMrJQffr1CV3a(lWaewFQVKBiW(gvgmfgQlb3Mim4VKEgGMFiClIBhGnclDdEOUBtn)uS)AuR0De9HDLbkBPGD1CkCPql4DWe2wlkszlfS8TixZyBTkkBPGLVf5AgJaUK(kdZOvuuUBxVbj2vZPWLcTG3bt4Nn8lrvOlnefPjLTuWY3ICnJT1QK721BqILVf5Ag)SHFjQcDPbmuxcUnryWFj9man)q4we3oaBew6g8af)i(PNFuZewtyd7kdu2sb7Q5u4sHwW7GjSTwuKYwky5BrUMX2Avu2sblFlY1mgbCj9vgMrROOC3UEdsSRMtHlfAbVdMWpB4xIQqxAikstkBPGLVf5AgBRvj3TR3GelFlY1m(zd)suf6sdyOUeCBIWG)s6zaA(HWTiUDa2iS0n4bo1DgHAGlLa7ZTT0kVlb3MEVvVb8h2vgOSLc2vZPWLcTG3btyBTOiLTuWY3ICnJT1QOSLcw(wKRzmc4s6RmmJwrr5UD9gKyxnNcxk0cEhmHF2WVevHU0quuUBxVbjw(wKRz8Zg(LOk0LgWqDj42eHb)L0Za08dHBrC7aSryPBWd1S)9M(uZpQjxJAhHc7kdu2sb7Q5u4sHwW7GjSTwuKYwky5BrUMX2Avu2sblFlY1mgbCj9vgMrlmuxcUnryWFj9man)q4we3oaBew6g8q5EeOz4ag1q1Ml0DekSRmqzlfSRMtHlfAbVdMW2ArrkBPGLVf5AgBRvrzlfS8TixZ4Nn8lrMnmJgWqDj42eHb)L0Za08dHBrC7aSryPBWdbt33dUua1Q7wdxGd7kdu2sb7Q5u4sHwW7GjSTwuKYwky5BrUMX2Avu2sblFlY1m(zd)sKzdMslmuxcUnryWFj9man)q4we3oaBew6g8G(zx3e6U(CW(OgLRf4WUYaLTuWUAofUuOf8oycBRffPSLcw(wKRzSTwfLTuWY3ICnJF2WVez2GP0cd1LGBteg8xspdqZpeUfXTdWgHLUbpOF21nhvFVNauZG1EVFBg2vgOSLc2vZPWLcTG3btyBTOiLTuWY3ICnJT1QOSLcw(wKRz8Zg(LiZgmLwyOUeCBIWG)s6zaA(HWTiUDa2iS0n4bHFtbuR(pdV3ExGd7kd0KYwkyxnNcxk0cEhmHT1QOjLTuWY3ICnJT1WqDj42eHb)L0Za08dHBrC7aSryPBWdOlpeG)Mq31Nd2h1OCTah2vgOSLc2vZPWLcTG3btyBTOiLTuWY3ICnJT1QOSLcw(wKRz8Zg(LiZgMrdyOUeCBIWG)s6zaA(HWTiUDa2iS0n4b0LhcWFtO76Zb7JAgS279BZWUYaLTuWUAofUuOf8oycBRffPSLcw(wKRzSTwfLTuWY3ICnJF2WVez2GP0cd1LGBteg8xspdqZpeUfXTdWgHLUbp4HeAYFh1kBcABPvVb8h2vgOjW7CcWY3ICnJ50P6SwLC3UEdsSRMtHlfAbVdMWpB4xImJgIIaVZjalFlY1mMtNQZAvYD76niXY3ICnJF2WVezgnubodUYmAffN2U5T6nG)kdvPcCgSzZOvfW7CcWbo9CBlnhnXimNovN1WqDj42eHb)L0Za08dHBrC7aSryPBWdQp0TzBlnnBCioSRmqzlfSRMtHlfAbVdMW2ArrkBPGLVf5AgBRvrzlfS8TixZyeWL0pmJwrr5UD9gKyxnNcxk0cEhmHF2WVevzOkAffL721BqILVf5Ag)SHFjQYqv0cd1LGBteg8xspdqZpeUfXTdWgHLUbp4Oj1EYO27H0(n5(EpSRmOzkBPGFpK2Vj337nntzlfSEdsrXrOSLc2vZPWLcTG3bt4Nn8lrvgmLwrrkBPGLVf5AgJaUK(Hz0QIYwky5BrUMXpB4xIQmJgvRAe5UD9gKybR)6ZZ2wAEiX)cMWpB4xIQm(0kkcodUb2M(yZQIwrrAYieNsgl3uZjI1T(v4Y(sgB4My)QHH6sWTjcd(lPNbO5hc3I42byJWs3GhOpxqBlnpLhNGwX(Mh2vgOSLc2vZPWLcTG3btyBTOiLTuWY3ICnJT1QOSLcw(wKRzmc4s6RmmJwrr5UD9gKyxnNcxk0cEhmHF2WVevPkAffPjLTuWY3ICnJT1QK721BqILVf5Ag)SHFjQsv0cd1LGBteg8xspdqZpeUfXTdWgOWUYaLTuWUAofUuOf8oycBRffPSLcw(wKRzSTwfLTuWY3ICnJraxs)WmAHHcd1LGBtewUBxVbjAOEb3MHDLHrK721BqIfS(RppBBP5He)lyc)SHFjQY4tROinzeItjJLBQ5eX6w)kCzFjJnCtSF1QgHYwkyQ(U6UfbWp7sGOiLTuWUAofUuOf8oycBRvrzlfSRMtHlfAbVdMWpB4xIQmlKffPSLcw(wKRzSTwfLTuWY3ICnJF2WVezMP0OAyOUeCBIWYD76nirZpeE)eMaOMjSAbdobHDLbun37nG)cmaH7NWea1mHvlyWjOYGPIIJqZ3pDJvZja7AncZ0XHairX3pDJvZja7AncFzftonQggQlb3MiSC3UEds08dHxUNP67Qd7kdu2sb7Q5u4sHwW7GjSTwuKYwky5BrUMX2Avu2sblFlY1mgbCj9dZOfgQlb3MiSC3UEds08dHJMoURBBPPMtb2tjh2vgOSLcgXmy6sH27cmwVbPkkBPGnyJ9nVTLw3kpDt)SBGW6niHH6sWTjcl3TR3Gen)q4sV3BUeCB26hcew6g8a4VKEgGGH6sWTjcl3TR3Gen)q4GjUztQ1M6wzFjh2vgaNbB2GPIIu2sb)SK(oJqTY(sgBRHH6sWTjcl3TR3Gen)q4u9D1TT0atCJt2W8WUYaLTuWUAofUuOf8oycBRffPSLcw(wKRzSTwfLTuWY3ICnJraxs)WmAHH6sWTjcl3TR3Gen)q4cw)1NNTT08qI)fmf2vgOjW7CcWY3ICnJ50P6Sw1iYD76niXUAofUuOf8oyc)SHFjYmAOAA7M3Q3a(RmuLQrOSLc(stYEOdCBIT1II0e4Dob4lnj7HoWTjMtNQZ6QffL721BqID1CkCPql4DWe(zd)suLb6sJQffhb4Doby5BrUMXC6uDwRsUBxVbjw(wKRz8Zg(LiZeKAvtB38w9gWFLb6kkoTDZB1Ba)vgQsf4myZMrRkG35eGdC652wAoAIryoDQoRffL721BqILVf5Ag)SHFjQYaDPr1WqDj42eHL721BqIMFi8G97A18LTNrB6PKd7kdYD76niXUAofUuOf8oyc)SHFjYmbPw102nVvVb8xzOkrr5UD9gKy5BrUMXpB4xImtqQvnTDZB1Ba)vgOROOC3UEdsSRMtHlfAbVdMWpB4xIQmqxAikk3TR3GelFlY1m(zd)suLb6sdyOUeCBIWYD76nirZpeEzLweRBEiX)b4gf7gHDLHrO57NUXQ5eGDTgHz64qaKO47NUXQ5eGDTgHVSsv0kkIQ5EVb8xGbiS(uFj3qG9nQmyA1QO5iu2sb7Q5u4sHwW7GjSTwuKYwky5BrUMX26QvnIC3UEdsmv31CBlntyrGtY4Nn8lrveK6quLk5UD9gKyty1cgCcWpB4xIQii1HOQQHH6sWTjcl3TR3Gen)q4gSX(M32sRBLNUPF2nqHDLHrOSLc2vZPWLcTG3btyBTOiLTuWY3ICnJT1QOSLcw(wKRzmc4s6hMrB1QM2U5T6nGFZgQcgQlb3MiSC3UEds08dHxB)Ry(LcnQUJaHDLHrO57NUXQ5eGDTgHz64qaKO47NUXQ5eGDTgHVSsv0kkIQ5EVb8xGbiS(uFj3qG9nQmyA1WqDj42eHL721BqIMFiClIBhGncJlfwcAPBWdsZL9f8BEYgv3rGWUYanhHYwkyxnNcxk0cEhmHT1IIu2sblFlY1m2wxTQrK721BqIP6UMBBPzclcCsg)SHFjQIGuhIQuj3TR3GeBcRwWGta(zd)sufbPoevvnmuxcUnry5UD9gKO5hc3vZPWLcTG3btHDLHrOjW7CcWxAs2dDGBtmNovN1IIu2sbFPjzp0bUnX26QvnTDZB1Ba)vgQcgQlb3MiSC3UEds08dHlFlY1CyxzyA7M3Q3a(RmqxrXPTBEREd4VYqvQaNbB2mAvb8oNaCGtp32sZrtmcZPt1znmuyOUeCBIWLlp0e)Ob1(FovNdlDdEi4sbuRE3EyQ9ULhOjBs2RUM14z05XVQz0v1i0e4Doby5BrUMXC6uDwRsUBxVbj2vZPWLcTG3bt4Nn8lrveK6quLOOC3UEdsS8TixZ4Nn8lrveK6quv1IISjzV6AwJNrNh)QMrxvJqtG35eGLVf5AgZPt1zTk5UD9gKyxnNcxk0cEhmHF2WVevrqQdbDwuuUBxVbjw(wKRz8Zg(LOkcsDiOZvdd1LGBteUC5HM4hn)q4Q9)CQohw6g8Gg1Koc4uDom1E3YdOAU3Ba)fyacRp1xYneyFJkdMQIMaVZja)NWeGxlQPMF9jbyoDQoRffr1CV3a(lWaewFQVKBiW(gvgQsfW7CcW)jmb41IAQ5xFsaMtNQZArrkBPGzJAZF2Zw9gWp2wRsZu2sbBcRwWGtawVbPkkBPG1N6l5wT9RxeJ1BqQIYwkyxnNcxk0cEhm1ClyL)bW6niHH6sWTjcxU8qt8JMFi8lnj7HoWTzyxzGYwk4lnj7HoWTjwVbPOiLTuWUAofUuOf8oycR3Gu1iu2sbFPjzp0bUnXpB4xImlKvnTDZB1Ba)vgQsue4DobyMoyPfCB2qCc4uYyoDQoRvj3TR3GeZ0blTGBZgItaNsg)SHFjYSz0QIYwk4lnj7HoWTj(zd)sKzZOHOOC3UEdsSRMtHlfAbVdMWpB4xImBgnurzlf8LMK9qh42e)SHFjYmtPv102nVvVb8xzOQQHH6sWTjcxU8qt8JMFiCMoyPfCB2qCc4uYHDLbun37nG)cmaH1N6l5gcSVHzdMQAeAc8oNaS8TixZyoDQoRvj3TR3Ge7Q5u4sHwW7Gj8Zg(LOkZOvue4Doby5BrUMXC6uDwRIYwky5BrUMX6nivj3TR3GelFlY1m(zd)suLz0kkszlfS8TixZyeWL0xzWKxnmuxcUnr4YLhAIF08dHRp1xYneyFJWUYGA)pNQZynQjDeWP6Sk1(FovNXbxkGA172vnYi0e4DobyMoyPfCB2qCc4uYyoDQoRffhbvZ9Ed4Vadqy9P(sUHa7BuzWurr5UD9gKyMoyPfCB2qCc4uY4Nn8lrveK6qyA1vlkoIC3UEdsSRMtHlfAbVdMWpB4xIQii1HOkvYD76niXUAofUuOf8oyc)SHFjYSz0kkk3TR3GelFlY1m(zd)sufbPoevPsUBxVbjw(wKRz8Zg(LiZMrROiLTuWY3ICnJT1QOSLcw(wKRzmc4s6nBgTvxnmuxcUnr4YLhAIF08dHdyJ6U)OMA(1Nee2vgu7)5uDghCPaQvVBx1i0e4DobyMoyPfCB2qCc4uYyoDQoRffL721BqIz6GLwWTzdXjGtjJF2WVevrqQdHPIIYD76niXUAofUuOf8oyc)SHFjQIGuhIQuj3TR3Ge7Q5u4sHwW7Gj8Zg(LiZMrROOC3UEdsS8TixZ4Nn8lrveK6quLk5UD9gKy5BrUMXpB4xImBgTIIu2sblFlY1m2wRIYwky5BrUMXiGlP3Sz0wnmuyOUeCBIWcCYVd2hnO2)ZP6CyPBWdMm74om1E3YdJqtG35eGNCdd(BBPf8oycZPt1zTOiWFbgGNyVdMW1sqLbtPvfnhHYwkyxnNcxk0cEhmHT1IIu2sblFlY1m2wxD1WqDj42eHf4KFhSpA(HWLEV3Cj42S1peiS0n4HYLhAIFuyxzyA7M3Q3a(RmqdrrkBPGnyJ9nVTLw3kpDt)SBGW2ArrkBPGrmdMUuO9UaJT1IIu2sbFPjzp0bUnX6nivnTDZB1Ba)vgQcgQlb3MiSaN87G9rZpeEGtp32sZrtmkSRmmcnF)0nwnNaSR1imthhcGefF)0nwnNaSR1i8LvMrdrrun37nG)cmaHdC652wAoAIrvgmTAvJmTDZB1Ba)MnqRO402nVvVb8pmtLC3UEdsmv31CBlntyrGtY4Nn8lrveK6QvnIC3UEdsSRMtHlfAbVdMWpB4xIQmJwrrG35eGLVf5AgZPt1zTk5UD9gKy5BrUMXpB4xIQmJ2QHH6sWTjclWj)oyF08dHt1Dn32sZewe4KCyxzyA7M3Q3a(nBWurXrM2U5T6nG)HQunIC3UEds8KByWFBlTG3bt4Nn8lrveK6qyQOOA)pNQZytMDCxD1WqDj42eHf4KFhSpA(HWnHvlyWjiSRmmTDZB1Ba)MnyQO4itB38w9gWVzd0v1iYD76niXuDxZTT0mHfbojJF2WVevrqQdHPIIQ9)CQoJnz2XD1vdd1LGBtewGt(DW(O5hcFYnm4VTLwW7GPWUYW02nVvVb8B2aDHH6sWTjclWj)oyF08dHl3eXY3b3MHDLHPTBEREd43SbtffN2U5T6nGFZgQsLC3UEdsmv31CBlntyrGtY4Nn8lrveK6qyQO402nVvVb8pqxvYD76niXuDxZTT0mHfbojJF2WVevrqQdHPQK721BqInHvlyWja)SHFjQIGuhctHH6sWTjclWj)oyF08dHl9EV5sWTzRFiqyPBWdLlp0e)OWUYaW7CcWtUHb)TT0cEhmH50P6SwfWFbgGNyVdMW1sGzdMsROiLTuWUAofUuOf8oycBRffPSLcw(wKRzSTggQlb3MiSaN87G9rZpeU8TixZFdb(JEoSRmi3TR3GelFlY183qG)ONXYj)fyuR8UeCB69kdZWMCAOAKPTBEREd43SbtffN2U5T6nGFZgQsLC3UEdsmv31CBlntyrGtY4Nn8lrveK6qyQO402nVvVb8pqxvYD76niXuDxZTT0mHfbojJF2WVevrqQdHPQK721BqInHvlyWja)SHFjQIGuhctvj3TR3Gel3eXY3b3M4Nn8lrveK6qyA1WqDj42eHf4KFhSpA(HWLEV3Cj42S1peiS0n4HYLhAIFemuxcUnrybo53b7JMFiC5MsobVdyDR0DdggQlb3MiSaN87G9rZpeU8TixZFdb(JEoSRmmTDZB1Ba)MnqxyOUeCBIWcCYVd2hn)q4(l9KBG9FobHDLHPTBEREd43Sb6gvuZp62moMP0oB8PnKNrBujW)8sbuuzCHr9(awdj0ziXLGBtiPFiacddnQ0peafhnQO5IB7G4OXXMfhnQ4sWTzu5zkl9CuHtNQZ64CrqCmtJJgv40P6SooxuXLGBZOI079Mlb3MT(HarL(HaT0n4OIC3UEdsueehRQ4OrfoDQoRJZfvCj42mQi9EV5sWTzRFiquPFiqlDdoQiWj)oyFueebrL6NLRbLdIJghBwC0OIlb3MrL6fCBgv40P6SooxeehZ04OrfoDQoRJZfvK)b4)8OcnHeG35eGdC652wAoAIryoDQoRJkUeCBgv8x6j3a7)CcIGiiQi3TR3Gefhno2S4OrfoDQoRJZfvK)b4)8OYiqIC3UEdsSG1F95zBlnpK4Fbt4Nn8lrqsfiz8PfsefHeAcjmcXPKXYn1CIyDRFfUSVKXgUj2hsQgsubjJaju2sbt13v3Tia(zxcGerriHYwkyxnNcxk0cEhmHT1qIkiHYwkyxnNcxk0cEhmHF2WVebjvGKzHmKikcju2sblFlY1m2wdjQGekBPGLVf5Ag)SHFjcsmdsmLgqs1rfxcUnJk1l42mcIJzAC0OcNovN1X5IkY)a8FEubvZ9Ed4Vadq4(jmbqnty1cgCcGKkdqIPqIOiKmcKqti59t3y1CcWUwJWmDCiacsefHK3pDJvZja7AncFjKubsm50asQoQ4sWTzuPFctauZewTGbNGiiowvXrJkC6uDwhNlQi)dW)5rfkBPGD1CkCPql4DWe2wdjIIqcLTuWY3ICnJT1qIkiHYwky5BrUMXiGlPhsgGKz0gvCj42mQuUNP67QJG4y0noAuHtNQZ64Crf5Fa(ppQqzlfmIzW0LcT3fySEdsirfKqzlfSbBSV5TT06w5PB6NDdewVbzuXLGBZOcA64UUTLMAofypLCeehJgXrJkC6uDwhNlQ4sWTzur69EZLGBZw)qGOs)qGw6gCub8xspdqrqCm6CC0OcNovN1X5IkY)a8FEubCgmKy2aKykKikcju2sb)SK(oJqTY(sgBRJkUeCBgvatCZMuRn1TY(socIJzYJJgv40P6Sooxur(hG)ZJku2sb7Q5u4sHwW7GjSTgsefHekBPGLVf5AgBRHevqcLTuWY3ICnJraxspKmajZOnQ4sWTzuHQVRUTLgyIBCYgMhbXXc54OrfoDQoRJZfvK)b4)8OcnHeG35eGLVf5AgZPt1znKOcsgbsK721BqID1CkCPql4DWe(zd)seKygKqdirfKmTDZB1Ba)qsLbiPkirfKmcKqzlf8LMK9qh42eBRHerriHMqcW7CcWxAs2dDGBtmNovN1qs1qIOiKi3TR3Ge7Q5u4sHwW7Gj8Zg(LiiPYaKqxAajvdjIIqYiqcW7CcWY3ICnJ50P6SgsubjYD76niXY3ICnJF2WVebjMbjcsnKOcsM2U5T6nGFiPYaKqxiruesM2U5T6nGFiPYaKufKOcsaNbdjMbjZOfsubjaVZjah40ZTT0C0eJWC6uDwdjIIqIC3UEdsS8TixZ4Nn8lrqsLbiHU0asQoQ4sWTzurW6V(8STLMhs8VGPiio24hhnQWPt1zDCUOI8pa)NhvK721BqID1CkCPql4DWe(zd)seKygKii1qIkizA7M3Q3a(HKkdqsvqIOiKi3TR3GelFlY1m(zd)seKygKii1qIkizA7M3Q3a(HKkdqcDHerrirUBxVbj2vZPWLcTG3bt4Nn8lrqsLbiHU0asefHe5UD9gKy5BrUMXpB4xIGKkdqcDPruXLGBZOsW(DTA(Y2ZOn9uYrqCSz0ghnQWPt1zDCUOI8pa)NhvgbsOjK8(PBSAobyxRryMooeabjIIqY7NUXQ5eGDTgHVesQajvrlKikcjOAU3Ba)fyacRp1xYneyFdiPYaKykKunKOcsOjKmcKqzlfSRMtHlfAbVdMW2AiruesOSLcw(wKRzSTgsQgsubjJajYD76niXuDxZTT0mHfbojJF2WVebjvGebPgscbKufKOcsK721BqInHvlyWja)SHFjcsQajcsnKeciPkiP6OIlb3MrLYkTiw38qI)dWnk2nIG4yZMfhnQWPt1zDCUOI8pa)NhvgbsOSLc2vZPWLcTG3btyBnKikcju2sblFlY1m2wdjQGekBPGLVf5AgJaUKEizasMrlKunKOcsM2U5T6nGFiXSbiPQOIlb3Mrfd2yFZBBP1TYt30p7gOiio2mtJJgv40P6Sooxur(hG)ZJkJaj0esE)0nwnNaSR1imthhcGGerri59t3y1CcWUwJWxcjvGKQOfsefHeun37nG)cmaH1N6l5gcSVbKuzasmfsQoQ4sWTzuP2(xX8lfAuDhbIG4yZQkoAuHtNQZ64CrfxcUnJksZL9f8BEYgv3rGOI8pa)NhvOjKmcKqzlfSRMtHlfAbVdMW2AiruesOSLcw(wKRzSTgsQgsubjJajYD76niXuDxZTT0mHfbojJF2WVebjvGebPgscbKufKOcsK721BqInHvlyWja)SHFjcsQajcsnKeciPkiP6OcxkSe0s3GJksZL9f8BEYgv3rGiio2m6ghnQWPt1zDCUOI8pa)NhvgbsOjKa8oNa8LMK9qh42eZPt1znKikcju2sbFPjzp0bUnX2AiPAirfKmTDZB1Ba)qsLbiPQOIlb3MrfxnNcxk0cEhmfbXXMrJ4OrfoDQoRJZfvK)b4)8OY02nVvVb8djvgGe6cjIIqY02nVvVb8djvgGKQGevqc4myiXmizgTqIkib4Dob4aNEUTLMJMyeMtNQZ6OIlb3Mrf5BrUMJGiiQa(lPNbO4OXXMfhnQWPt1zDCUOs6gCu59qsBt6rnQtO9SUrzbGnJkUeCBgvEpK02KEuJ6eApRBuwayZiioMPXrJkC6uDwhNlQ4sWTzuXemQnTbD(JkY)a8FEuHYwkyxnNcxk0cEhmHT1qIOiKqzlfS8TixZyBnKOcsOSLcw(wKRzmc4s6HKbizgTrL0n4OIjyuBAd68hbXXQkoAuHtNQZ64CrfxcUnJkQpV32sZZZWbSUr13vhvK)b4)8OYiqcLTuWUAofUuOf8oycBRHerriHYwky5BrUMX2AirfKqzlfS8TixZ4Nn8lrqIzqYSqgsQgsefHKrGe5UD9gKyxnNcxk0cEhmHF2WVebjvGKQOfsefHe5UD9gKy5BrUMXpB4xIGKkqsv0cjvhvs3GJkQpV32sZZZWbSUr13vhbXXOBC0OcNovN1X5IkUeCBgv07AGAf7BEur(hG)ZJku2sb7Q5u4sHwW7GjSTgsefHekBPGLVf5AgBRHevqcLTuWY3ICnJF2WVebjMbjZc5Os6gCurVRbQvSV5rqCmAehnQWPt1zDCUOIlb3MrfbVZsV35h1OyN(OI8pa)NhvOSLc2vZPWLcTG3btyBnKikcju2sblFlY1m2wdjQGekBPGLVf5Ag)SHFjcsmdsMrJOs6gCurW7S07D(rnk2PpcIJrNJJgv40P6SooxuXLGBZOcL5cBYnkMBE3WtxgvK)b4)8OcLTuWUAofUuOf8oycBRHerriHYwky5BrUMX26Os6gCuHYCHn5gfZnVB4PlJG4yM84OrfoDQoRJZfvCj42mQyWptpyYrTINcrf5Fa(ppQmcKqti59t3y1CcWUwJWmDCiacsefHK3pDJvZja7AncFjKubsMrdiPAiruesq1CV3a(lWaewFQVKBiW(gqsLbiX0Os6gCuXGFMEWKJAfpfIG4yHCC0OcNovN1X5IkUeCBgvQ72uZpf7Vg1kDhrFur(hG)ZJku2sb7Q5u4sHwW7GjSTgsefHekBPGLVf5AgBRHevqcLTuWY3ICnJraxspKuzasMrlKikcjYD76niXUAofUuOf8oyc)SHFjcsQaj0LgqIOiKqtiHYwky5BrUMX2AirfKi3TR3GelFlY1m(zd)seKubsOlnIkPBWrL6Un18tX(RrTs3r0hbXXg)4OrfoDQoRJZfvCj42mQqXpIF65h1mH1e2OI8pa)NhvOSLc2vZPWLcTG3btyBnKikcju2sblFlY1m2wdjQGekBPGLVf5AgJaUKEiPYaKmJwiruesK721BqID1CkCPql4DWe(zd)seKubsOlnGerriHMqcLTuWY3ICnJT1qIkirUBxVbjw(wKRz8Zg(LiiPcKqxAevs3GJku8J4NE(rntynHncIJnJ24OrfoDQoRJZfvCj42mQWPUZiudCPeyFUTLw5Dj4207T6nG)OI8pa)NhvOSLc2vZPWLcTG3btyBnKikcju2sblFlY1m2wdjQGekBPGLVf5AgJaUKEiPYaKmJwiruesK721BqID1CkCPql4DWe(zd)seKubsOlnGerrirUBxVbjw(wKRz8Zg(LiiPcKqxAevs3GJkCQ7mc1axkb2NBBPvExcUn9EREd4pcIJnBwC0OcNovN1X5IkUeCBgvQz)7n9PMFutUg1ocfvK)b4)8OcLTuWUAofUuOf8oycBRHerriHYwky5BrUMX2AirfKqzlfS8TixZyeWL0djvgGKz0gvs3GJk1S)9M(uZpQjxJAhHIG4yZmnoAuHtNQZ64CrfxcUnJkL7rGMHdyudvBUq3rOOI8pa)NhvOSLc2vZPWLcTG3btyBnKikcju2sblFlY1m2wdjQGekBPGLVf5Ag)SHFjcsmBasMrJOs6gCuPCpc0mCaJAOAZf6ocfbXXMvvC0OcNovN1X5IkUeCBgvcMUVhCPaQv3TgUahvK)b4)8OcLTuWUAofUuOf8oycBRHerriHYwky5BrUMX2AirfKqzlfS8TixZ4Nn8lrqIzdqIP0gvs3GJkbt33dUua1Q7wdxGJG4yZOBC0OcNovN1X5IkUeCBgv0p76Mq31Nd2h1OCTahvK)b4)8OcLTuWUAofUuOf8oycBRHerriHYwky5BrUMX2AirfKqzlfS8TixZ4Nn8lrqIzdqIP0gvs3GJk6NDDtO76Zb7JAuUwGJG4yZOrC0OcNovN1X5IkUeCBgv0p76MJQV3taQzWAV3VnJkY)a8FEuHYwkyxnNcxk0cEhmHT1qIOiKqzlfS8TixZyBnKOcsOSLcw(wKRz8Zg(LiiXSbiXuAJkPBWrf9ZUU5O679eGAgS279BZiio2m6CC0OcNovN1X5IkUeCBgve(nfqT6)m8E7DboQi)dW)5rfAcju2sb7Q5u4sHwW7GjSTgsubj0esOSLcw(wKRzSToQKUbhve(nfqT6)m8E7DbocIJnZKhhnQWPt1zDCUOIlb3Mrf0LhcWFtO76Zb7JAuUwGJkY)a8FEuHYwkyxnNcxk0cEhmHT1qIOiKqzlfS8TixZyBnKOcsOSLcw(wKRz8Zg(LiiXSbizgnIkPBWrf0LhcWFtO76Zb7JAuUwGJG4yZc54OrfoDQoRJZfvCj42mQGU8qa(BcDxFoyFuZG1EVFBgvK)b4)8OcLTuWUAofUuOf8oycBRHerriHYwky5BrUMX2AirfKqzlfS8TixZ4Nn8lrqIzdqIP0gvs3GJkOlpeG)Mq31Nd2h1myT373MrqCSzJFC0OcNovN1X5IkUeCBgv8qcn5VJALnbTT0Q3a(JkY)a8FEuHMqcW7CcWY3ICnJ50P6SgsubjYD76niXUAofUuOf8oyc)SHFjcsmdsObKikcjaVZjalFlY1mMtNQZAirfKi3TR3GelFlY1m(zd)seKygKqdirfKaodgsQajZOfsefHKPTBEREd4hsQmajvbjQGeWzWqIzqYmAHevqcW7CcWbo9CBlnhnXimNovN1rL0n4OIhsOj)DuRSjOTLw9gWFeehZuAJJgv40P6SooxuXLGBZOI6dDB22stZghIJkY)a8FEuHYwkyxnNcxk0cEhmHT1qIOiKqzlfS8TixZyBnKOcsOSLcw(wKRzmc4s6HKbizgTqIOiKi3TR3Ge7Q5u4sHwW7Gj8Zg(LiiPYaKufTqIOiKi3TR3GelFlY1m(zd)seKuzasQI2Os6gCur9HUnBBPPzJdXrqCmtNfhnQWPt1zDCUOIlb3MrfhnP2tg1EpK2Vj337rf5Fa(ppQOzkBPGFpK2Vj337nntzlfSEdsiruesgbsOSLc2vZPWLcTG3bt4Nn8lrqsLbiXuAHerriHYwky5BrUMXiGlPhsgGKz0cjQGekBPGLVf5Ag)SHFjcsQajZObKunKOcsgbsK721BqIfS(RppBBP5He)lyc)SHFjcsQajJpTqIOiKaodUb2M(yiXmiPkAHerriHMqcJqCkzSCtnNiw36xHl7lzSHBI9HKQJkPBWrfhnP2tg1EpK2Vj337rqCmtnnoAuHtNQZ64CrfxcUnJk0NlOTLMNYJtqRyFZJkY)a8FEuHYwkyxnNcxk0cEhmHT1qIOiKqzlfS8TixZyBnKOcsOSLcw(wKRzmc4s6HKkdqYmAHerrirUBxVbj2vZPWLcTG3bt4Nn8lrqsfiPkAHerriHMqcLTuWY3ICnJT1qIkirUBxVbjw(wKRz8Zg(LiiPcKufTrL0n4Oc95cABP5P84e0k238iioMPvfhnQWPt1zDCUOI8pa)NhvOSLc2vZPWLcTG3btyBnKikcju2sblFlY1m2wdjQGekBPGLVf5AgJaUKEizasMrBuXLGBZOIfXTdWgOiicIkLlp0e)O4OXXMfhnQWPt1zDCUOYwhvqmiQ4sWTzurT)Nt15OIAVB5OcnHe2KSxDnRXEiHM83rTYMG2wA1Ba)qIkizeiHMqcW7CcWY3ICnJ50P6SgsubjYD76niXUAofUuOf8oyc)SHFjcsQajcsnKeciPkiruesK721BqILVf5Ag)SHFjcsQajcsnKeciPkiPAiruesytYE11Sg7HeAYFh1kBcABPvVb8djQGKrGeAcjaVZjalFlY1mMtNQZAirfKi3TR3Ge7Q5u4sHwW7Gj8Zg(LiiPcKii1qsiGe6mKikcjYD76niXY3ICnJF2WVebjvGebPgscbKqNHKQJkQ9VLUbhvcUua1Q3ThbXXmnoAuHtNQZ64CrLToQGyquXLGBZOIA)pNQZrf1E3Yrfun37nG)cmaH1N6l5gcSVbKuzasmfsubj0esaENta(pHjaVwutn)6tcWC6uDwdjIIqcQM79gWFbgGW6t9LCdb23asQmajvbjQGeG35eG)tycWRf1uZV(KamNovN1qIOiKqzlfmBuB(ZE2Q3a(X2AirfKOzkBPGnHvlyWjaR3Gesubju2sbRp1xYTA7xVigR3Gesubju2sb7Q5u4sHwW7GPMBbR8pawVbzurT)T0n4OIg1Koc4uDocIJvvC0OcNovN1X5IkY)a8FEuHYwk4lnj7HoWTjwVbjKikcju2sb7Q5u4sHwW7GjSEdsirfKmcKqzlf8LMK9qh42e)SHFjcsmdsczirfKmTDZB1Ba)qsLbiPkiruesaENtaMPdwAb3MneNaoLmMtNQZAirfKi3TR3GeZ0blTGBZgItaNsg)SHFjcsmdsMrlKOcsOSLc(stYEOdCBIF2WVebjMbjZObKikcjYD76niXUAofUuOf8oyc)SHFjcsmdsMrdirfKqzlf8LMK9qh42e)SHFjcsmdsmLwirfKmTDZB1Ba)qsLbiPkiP6OIlb3MrLlnj7HoWTzeehJUXrJkC6uDwhNlQi)dW)5rfun37nG)cmaH1N6l5gcSVbKy2aKykKOcsgbsOjKa8oNaS8TixZyoDQoRHevqIC3UEdsSRMtHlfAbVdMWpB4xIGKkqYmAHerrib4Doby5BrUMXC6uDwdjQGekBPGLVf5AgR3GesubjYD76niXY3ICnJF2WVebjvGKz0cjIIqcLTuWY3ICnJraxspKuzasm5qs1rfxcUnJkmDWsl42SH4eWPKJG4y0ioAuHtNQZ64Crf5Fa(ppQO2)ZP6mwJAshbCQodjQGe1(FovNXbxkGA172HevqYiqYiqcnHeG35eGz6GLwWTzdXjGtjJ50P6SgsefHKrGeun37nG)cmaH1N6l5gcSVbKuzasmfsefHe5UD9gKyMoyPfCB2qCc4uY4Nn8lrqsfirqQHKqajMcjvdjvdjIIqYiqIC3UEdsSRMtHlfAbVdMWpB4xIGKkqIGudjHasQcsubjYD76niXUAofUuOf8oyc)SHFjcsmdsMrlKikcjYD76niXY3ICnJF2WVebjvGebPgscbKufKOcsK721BqILVf5Ag)SHFjcsmdsMrlKikcju2sblFlY1m2wdjQGekBPGLVf5AgJaUKEiXmizgTqs1qs1rfxcUnJk6t9LCdb23icIJrNJJgv40P6Sooxur(hG)ZJkQ9)CQoJdUua1Q3TdjQGKrGeAcjaVZjaZ0blTGBZgItaNsgZPt1znKikcjYD76niXmDWsl42SH4eWPKXpB4xIGKkqIGudjHasmfsefHe5UD9gKyxnNcxk0cEhmHF2WVebjvGebPgscbKufKOcsK721BqID1CkCPql4DWe(zd)seKygKmJwiruesK721BqILVf5Ag)SHFjcsQajcsnKeciPkirfKi3TR3GelFlY1m(zd)seKygKmJwiruesOSLcw(wKRzSTgsubju2sblFlY1mgbCj9qIzqYmAHKQJkUeCBgvaSrD3Futn)6tcIGiiQiWj)oyFuC04yZIJgv40P6SooxuzRJkigevCj42mQO2)ZP6CurT3TCuzeiHMqcW7CcWtUHb)TT0cEhmH50P6SgsefHeG)cmapXEhmHRLaiPYaKykTqIkiHMqYiqcLTuWUAofUuOf8oycBRHerriHYwky5BrUMX2AiPAiP6OIA)BPBWrftMDChbXXmnoAuHtNQZ64Crf5Fa(ppQmTDZB1Ba)qsLbiHgqIOiKqzlfSbBSV5TT06w5PB6NDde2wdjIIqcLTuWiMbtxk0ExGX2AiruesOSLc(stYEOdCBI1BqcjQGKPTBEREd4hsQmajvfvCj42mQi9EV5sWTzRFiquPFiqlDdoQuU8qt8JIG4yvfhnQWPt1zDCUOI8pa)NhvgbsOjK8(PBSAobyxRryMooeabjIIqY7NUXQ5eGDTgHVesQajZObKikcjOAU3Ba)fyach40ZTT0C0eJGKkdqIPqs1qIkizeizA7M3Q3a(HeZgGeAHerrizA7M3Q3a(HKbizgKOcsK721BqIP6UMBBPzclcCsg)SHFjcsQajcsnKunKOcsgbsK721BqID1CkCPql4DWe(zd)seKubsMrlKikcjaVZjalFlY1mMtNQZAirfKi3TR3GelFlY1m(zd)seKubsMrlKuDuXLGBZOsGtp32sZrtmkcIJr34OrfoDQoRJZfvK)b4)8OY02nVvVb8djMnajMcjIIqYiqY02nVvVb8djdqsvqIkizeirUBxVbjEYnm4VTLwW7Gj8Zg(LiiPcKii1qsiGetHerrirT)Nt1zSjZoUHKQHKQJkUeCBgvO6UMBBPzclcCsocIJrJ4OrfoDQoRJZfvK)b4)8OY02nVvVb8djMnajMcjIIqYiqY02nVvVb8djMnaj0fsubjJajYD76niXuDxZTT0mHfbojJF2WVebjvGebPgscbKykKikcjQ9)CQoJnz2XnKunKuDuXLGBZOIjSAbdobrqCm6CC0OcNovN1X5IkY)a8FEuzA7M3Q3a(HeZgGe6gvCj42mQm5gg832sl4DWueehZKhhnQWPt1zDCUOI8pa)NhvM2U5T6nGFiXSbiXuiruesM2U5T6nGFiXSbiPkirfKi3TR3Get1Dn32sZewe4Km(zd)seKubseKAijeqIPqIOiKmTDZB1Ba)qYaKqxirfKi3TR3Get1Dn32sZewe4Km(zd)seKubseKAijeqIPqIkirUBxVbj2ewTGbNa8Zg(LiiPcKii1qsiGetJkUeCBgvKBIy57GBZiiowihhnQWPt1zDCUOI8pa)NhvaENtaEYnm4VTLwW7GjmNovN1qIkib4VadWtS3bt4AjasmBasmLwiruesOSLc2vZPWLcTG3btyBnKikcju2sblFlY1m2whvCj42mQi9EV5sWTzRFiquPFiqlDdoQuU8qt8JIG4yJFC0OcNovN1X5IkY)a8FEurUBxVbjw(wKR5VHa)rpJLt(lWOw5Dj4207qsLbizg2KtdirfKmcKmTDZB1Ba)qIzdqIPqIOiKmTDZB1Ba)qIzdqsvqIkirUBxVbjMQ7AUTLMjSiWjz8Zg(LiiPcKii1qsiGetHerrizA7M3Q3a(HKbiHUqIkirUBxVbjMQ7AUTLMjSiWjz8Zg(LiiPcKii1qsiGetHevqIC3UEdsSjSAbdob4Nn8lrqsfirqQHKqajMcjQGe5UD9gKy5Miw(o42e)SHFjcsQajcsnKeciXuiP6OIlb3Mrf5BrUM)gc8h9CeehBgTXrJkC6uDwhNlQ4sWTzur69EZLGBZw)qGOs)qGw6gCuPC5HM4hfbXXMnloAuXLGBZOICtjNG3bSUv6Ubhv40P6SooxeehBMPXrJkC6uDwhNlQi)dW)5rLPTBEREd4hsmBasOBuXLGBZOI8TixZFdb(JEocIJnRQ4OrfoDQoRJZfvK)b4)8OY02nVvVb8djMnaj0nQ4sWTzuXFPNCdS)ZjicIGiiQ4wW0(rfLZGojcIGye]] )


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
