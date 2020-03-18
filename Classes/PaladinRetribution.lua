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


    spec:RegisterPack( "Retribution", 20200317, [[dGKJybqiKIEKGsTjsYOuioLKuRsa6vkknlbPBjau7cQFjjzyiLoMIQLjqEMGQPjO4Aif2MaGVPqLgNcv5CcGSobq18eq3tb7tsCqbqXcvu8qfQQMOcvqxuHkKnQqvHrkaKtkakTsbXnvOc1ovOmufQkAPkuv6PKyQkKUQcvGVQqfTxH(RugmIdt1IrYJjAYK6YO2SeFMGrRiNwPvJuPxJu1SLQBtHDl63QmCj1XrQOLRQNdz6axNsBNK67u04rQW5fOwVGsMpH2pOJZJJgv0oGJJfeTbrlTHpFCXbnpCAqJXnQacUMJk1UKExGJkPBWrLXxg8lLfSxgvQ9G7NRJJgvqN9LCuzcaQrb4vvLWcMSuy5zufAnSDhSxkFVaQcTgYQIku2TdcWMrQOI2bCCSGOniAPn85JloO5HtdAeaIkOAwghBCPnQmTAnNrQOIMrYOsydjJVm4xklyVesgF6DxVjmKWgsMaGAuaEvvjSGjlfwEgvHwdB3b7LY3lGQqRHSkyiHnKmo2F5eKmFCdfscI2GOfgcmKWgsg)tEkWOaCyiHnKeadjJdQ1oG1qs5Eiz8WHJHHe2qsamKm(yPdir6iqvYjptUdjJ)XHiiroXs6rqs5EijaZ4SQX)BrUMXrL6)kBNJkHnKm(YGFPSG9siz8P3D9MWqcBizcaQrb4vvLWcMSuy5zufAnSDhSxkFVaQcTgYQGHe2qY4y)LtqY8XnuijiAdIwyiWqcBiz8p5PaJcWHHe2qsamKmoOw7awdjL7HKXdhoggsydjbWqY4JLoGePJavjN8m5oKm(hhIGe5elPhbjL7HKamJZQg)Vf5AgddbgsydjJJOdwAbSgsO4Y9mKipdkhajuSWMimKeGrk5AacsYldGN83Oy7qIlb7Lii5YEWyyiHnK4sWEjcx)S8mOCWqP7i6HHe2qIlb7LiC9ZYZGYbZouv5onmKWgsCjyVeHRFwEguoy2HQCRGbNahSxcdjSHeL0RrthasEF1qcLTuynKGaoabjuC5EgsKNbLdGekwyteK4PgsQFoaU(aGnfGKfbj6lzmmKWgsCjyVeHRFwEguoy2HQqPxJMoqdbCacgIlb7LiC9ZYZGYbZouv9b2lHH4sWEjcx)S8mOCWSdv5V0tUbU)5ee6wgOjW7CcWMo9C7knhnXimNovN1WqGHe2qY4i6GLwaRHewn)bdjG1GHeWedjUeCpKSiiXv7B3P6mggIlb7LOHNPS0ZWqCjyVen7qvsV3BUeSx26lceA6g8G8UU(mtemexc2lrZouL079Mlb7LT(IaHMUbpiWj)o4EemeyiUeSxIWGFt6zaA2HQSiUTa2i00n4H3dlTnPh1OwH2Z6gLfaUegIlb7Lim43KEgGMDOklIBlGncnDdEGUmQnDMD(dDldu2sb7Q5uytHM57GjSTwuKYwky5BrUMX2Avu2sblFlY1mgbCj9dZPfgIlb7Lim43KEgGMDOklIBlGncnDdEq9692vAEUgoG1nQ(D6q3YWiu2sb7Q5uytHM57GjSTwuKYwky5BrUMX2Avu2sblFlY1m(zdFtuGZhVQffhrExxFMj2vZPWMcnZ3bt4Nn8nrvcNwrr5DD9zMy5BrUMXpB4BIQeoTvddXLG9seg8BspdqZouLfXTfWgHMUbpOVZa1k2p4q3YaLTuWUAof2uOz(oycBRffPSLcw(wKRzSTwfLTuWY3ICnJF2W3ef48XdgIlb7Lim43KEgGMDOklIBlGncnDdEqW7S07D(rnk2Pp0TmqzlfSRMtHnfAMVdMW2ArrkBPGLVf5AgBRvrzlfS8TixZ4Nn8nrboNgWqCjyVeHb)M0Za0SdvzrCBbSrOPBWdublCj3OyU5DdpDzOBzGYwkyxnNcBk0mFhmHT1IIu2sblFlY1m2wddXLG9seg8BspdqZouLfXTfWgHMUbpyWptpyYrTINcHULHrO57RUXQ5eGDTgHz6yraKO47RUXQ5eGDTgH3SYCAuTOiQM79gWFbgGW6v9MCdbU3OYqqWqCjyVeHb)M0Za0SdvzrCBbSrOPBWd1DBQ5NI9xJALUJOp0TmqzlfSRMtHnfAMVdMW2ArrkBPGLVf5AgBRvrzlfS8TixZyeWL0xzyoTIIY766ZmXUAof2uOz(oyc)SHVjQsyOHOinPSLcw(wKRzSTwL8UU(mtS8TixZ4Nn8nrvcdnGH4sWEjcd(nPNbOzhQYI42cyJqt3GhO4hXp98JA01sxBOBzGYwkyxnNcBk0mFhmHT1IIu2sblFlY1m2wRIYwky5BrUMXiGlPVYWCAffL311NzID1CkSPqZ8DWe(zdFtuLWqdrrAszlfS8TixZyBTk5DD9zMy5BrUMXpB4BIQegAadXLG9seg8BspdqZouLfXTfWgHMUbpWPUZiudSPeyFUDLw5DjyV07T6ZK)q3YaLTuWUAof2uOz(oycBRffPSLcw(wKRzSTwfLTuWY3ICnJraxsFLH50kkkVRRpZe7Q5uytHM57Gj8Zg(MOkHHgIIY766ZmXY3ICnJF2W3evjm0agIlb7Lim43KEgGMDOklIBlGncnDdEOM9V30RA(rn5zu7iuOBzGYwkyxnNcBk0mFhmHT1IIu2sblFlY1m2wRIYwky5BrUMXiGlPVYWCAHH4sWEjcd(nPNbOzhQYI42cyJqt3Ghk7JandhWOgQoyHUJqHULbkBPGD1CkSPqZ8DWe2wlkszlfS8TixZyBTkkBPGLVf5Ag)SHVjkWH50agIlb7Lim43KEgGMDOklIBlGncnDdEWCA)U5McOwD3A4cCOBzGYwkyxnNcBk0mFhmHT1IIu2sblFlY1m2wRIYwky5BrUMXpB4BIcCiiAHH4sWEjcd(nPNbOzhQYI42cyJqt3Gh0p76Mq31RdUh1OCTah6wgOSLc2vZPWMcnZ3btyBTOiLTuWY3ICnJT1QOSLcw(wKRz8Zg(MOahcIwyiUeSxIWGFt6zaA2HQSiUTa2i00n4b9ZUU5O699eGAgS2799Yq3YaLTuWUAof2uOz(oycBRffPSLcw(wKRzSTwfLTuWY3ICnJF2W3ef4qq0cdXLG9seg8BspdqZouLfXTfWgHMUbpi8xkGA1)A4927cCOBzGMu2sb7Q5uytHM57GjSTwfnPSLcw(wKRzSTggIlb7Lim43KEgGMDOklIBlGncnDdEaT5Ia83e6UEDW9OgLRf4q3YaLTuWUAof2uOz(oycBRffPSLcw(wKRzSTwfLTuWY3ICnJF2W3ef4WCAadXLG9seg8BspdqZouLfXTfWgHMUbpG2Cra(BcDxVo4EuZG1EVVxg6wgOSLc2vZPWMcnZ3btyBTOiLTuWY3ICnJT1QOSLcw(wKRz8Zg(MOahcIwyiUeSxIWGFt6zaA2HQSiUTa2i00n4bpSqt(7Ow5sq7kT6ZK)q3YanbENtaw(wKRzmNovN1QK311NzID1CkSPqZ8DWe(zdFtuG0que4Doby5BrUMXC6uDwRsExxFMjw(wKRz8Zg(MOaPHkWAWvMtRO401dUvFM8xziCvG1GdCoTQaENta20PNBxP5OjgH50P6SggIlb7Lim43KEgGMDOklIBlGncnDdEq9I2lBxPPzJfXHULbkBPGD1CkSPqZ8DWe2wlkszlfS8TixZyBTkkBPGLVf5AgJaUK(H50kkkVRRpZe7Q5uytHM57Gj8Zg(MOkdHtROO8UU(mtS8TixZ4Nn8nrvgcNwyiUeSxIWGFt6zaA2HQSiUTa2i00n4bhnP2tg1EpSUVjV37HULbntzlf87H19n59EVPzkBPG1NzkkocLTuWUAof2uOz(oyc)SHVjQYqq0kkszlfS8TixZyeWL0pmNwvu2sblFlY1m(zdFtuL50OAvJiVRRpZely9xVE2UsZdl(pWe(zdFtuLaeTIIG1GBGRPxoWWPvuKMmcXPKXYl1CIyDRVfUCVKXgoDVVAyiUeSxIWGFt6zaA2HQSiUTa2i00n4b6Zd0UsZt5YjOvSFWHULbkBPGD1CkSPqZ8DWe2wlkszlfS8TixZyBTkkBPGLVf5AgJaUK(kdZPvuuExxFMj2vZPWMcnZ3bt4Nn8nrvcNwrrAszlfS8TixZyBTk5DD9zMy5BrUMXpB4BIQeoTWqCjyVeHb)M0Za0SdvzrCBbSbk0TmqzlfSRMtHnfAMVdMW2ArrkBPGLVf5AgBRvrzlfS8TixZyeWL0pmNwyiWqCjyVeHL311NzIgQpWEzOBzye5DD9zMybR)61Z2vAEyX)bMWpB4BIQeGOvuKMmcXPKXYl1CIyDRVfUCVKXgoDVVAvJqzlfmv)oD3Ia4NDjquKYwkyxnNcBk0mFhmHT1QOSLc2vZPWMcnZ3bt4Nn8nrvMpEIIu2sblFlY1m2wRIYwky5BrUMXpB4BIcmiAunmexc2lry5DD9zMOzhQQVctauJUwTGbNGq3YaQM79gWFbgGW9vycGA01Qfm4euziirXrO57RUXQ5eGDTgHz6yraKO47RUXQ5eGDTgH3SY4sJQHH4sWEjclVRRpZen7qvL9zQ(D6q3YaLTuWUAof2uOz(oycBRffPSLcw(wKRzSTwfLTuWY3ICnJraxs)WCAHH4sWEjclVRRpZen7qvOPL762vAQ5uG9uYHULbkBPGrmdM2uO9UaJ1NzQIYwkyd24(GBxP1TYv30p7giS(mtyiUeSxIWY766ZmrZouL079Mlb7LT(IaHMUbpa(nPNbiyiUeSxIWY766ZmrZoufyIB2K6SPUvUxYHULbWAWboeKOiLTuWplPVZiuRCVKX2AyiUeSxIWY766ZmrZoufv)oD7knWe34Knco0TmqzlfSRMtHnfAMVdMW2ArrkBPGLVf5AgBRvrzlfS8TixZyeWL0pmNwyiUeSxIWY766ZmrZouLG1F96z7knpS4)atHULbAc8oNaS8TixZyoDQoRvnI8UU(mtSRMtHnfAMVdMWpB4BIcKgQMUEWT6ZK)kdHRAekBPG3KoTlAb7LyBTOinbENtaEt60UOfSxI50P6SUArr5DD9zMyxnNcBk0mFhmHF2W3evzim0OArXraENtaw(wKRzmNovN1QK311NzILVf5Ag)SHVjkqbPw101dUvFM8xzimIItxp4w9zYFLHWvbwdoW50Qc4DobytNEUDLMJMyeMtNQZArr5DD9zMy5BrUMXpB4BIQmegAunmexc2lry5DD9zMOzhQY8(UwnVz7z0LEk5q3YG8UU(mtSRMtHnfAMVdMWpB4BIcuqQvnD9GB1Nj)vgcxuuExxFMjw(wKRz8Zg(MOafKAvtxp4w9zYFLHWikkVRRpZe7Q5uytHM57Gj8Zg(MOkdHHgIIY766ZmXY3ICnJF2W3evzim0agIlb7LiS8UU(mt0SdvvoPfX6Mhw8VaUrXUrOBzyeA((QBSAobyxRryMoweajk((QBSAobyxRr4nReoTIIOAU3Ba)fyacRx1BYne4EJkdbvTkAocLTuWUAof2uOz(oycBRffPSLcw(wKRzSTUAvJiVRRpZet1Dn3UsJUweyLm(zdFtufbPoGHRsExxFMjMUwTGbNa8Zg(MOkcsDadVAyiUeSxIWY766ZmrZouLbBCFWTR06w5QB6NDduOBzyekBPGD1CkSPqZ8DWe2wlkszlfS8TixZyBTkkBPGLVf5AgJaUK(H50wTQPRhCR(m5pWHWHH4sWEjclVRRpZen7qv12FlbVPqJQ7iqOBzyeA((QBSAobyxRryMoweajk((QBSAobyxRr4nReoTIIOAU3Ba)fyacRx1BYne4EJkdbvnmexc2lry5DD9zMOzhQYI42cyJq5sHLGw6g8Gmyz)a)LRSr1Dei0TmqZrOSLc2vZPWMcnZ3btyBTOiLTuWY3ICnJT1vRAe5DD9zMyQUR52vA01IaRKXpB4BIQii1bmCvY766ZmX01Qfm4eGF2W3evrqQdy4vddXLG9sewExxFMjA2HQC1CkSPqZ8DWuOBzyeAc8oNa8M0PDrlyVeZPt1zTOiLTuWBsN2fTG9sSTUAvtxp4w9zYFLHWHH4sWEjclVRRpZen7qvY3ICnh6wgMUEWT6ZK)kdHruC66b3Qpt(RmeUkWAWboNwvaVZjaB60ZTR0C0eJWC6uDwddbgIlb7LiCzZfnXpAqT)Rt15qt3Ghm3ua1QVRhQAVB5bAY0PDRRznEEaiaf(8WOAeAc8oNaS8TixZyoDQoRvjVRRpZe7Q5uytHM57Gj8Zg(MOkcsDadxuuExxFMjw(wKRz8Zg(MOkcsDadVArrMoTBDnRXZdabOWNhgvJqtG35eGLVf5AgZPt1zTk5DD9zMyxnNcBk0mFhmHF2W3evrqQdyaquuExxFMjw(wKRz8Zg(MOkcsDadavddXLG9seUS5IM4hn7qvQ9FDQohA6g8Gg1Koc4uDou1E3YdOAU3Ba)fyacRx1BYne4EJkdbPIMaVZja)RWeGplQPMF9kbyoDQoRffr1CV3a(lWaewVQ3KBiW9gvgcxfW7CcW)kmb4ZIAQ5xVsaMtNQZArrkBPGzJ6GF2Zw9zYp2wRsZu2sbtxRwWGtawFMPkkBPG1R6n5wT9RpeJ1NzQIYwkyxnNcBk0mFhm1Cl4K)cW6ZmHH4sWEjcx2Crt8JMDOQnPt7IwWEzOBzGYwk4nPt7IwWEjwFMPOiLTuWUAof2uOz(oycRpZu1iu2sbVjDAx0c2lXpB4BIcC8unD9GB1Nj)vgcxue4DobyMoyPfSx2qCc4uYyoDQoRvjVRRpZeZ0blTG9YgItaNsg)SHVjkW50QIYwk4nPt7IwWEj(zdFtuGZPHOO8UU(mtSRMtHnfAMVdMWpB4BIcConurzlf8M0PDrlyVe)SHVjkWGOv101dUvFM8xzi8QHH4sWEjcx2Crt8JMDOkMoyPfSx2qCc4uYHULbun37nG)cmaH1R6n5gcCVrGdbPAeAc8oNaS8TixZyoDQoRvjVRRpZe7Q5uytHM57Gj8Zg(MOkZPvue4Doby5BrUMXC6uDwRIYwky5BrUMX6ZmvjVRRpZelFlY1m(zdFtuL50kkszlfS8TixZyeWL0xzyCRggIlb7LiCzZfnXpA2HQ0R6n5gcCVrOBzqT)Rt1zSg1Koc4uDwLA)xNQZyZnfqT676QgzeAc8oNamthS0c2lBiobCkzmNovN1IIJGQ5EVb8xGbiSEvVj3qG7nQmeKOO8UU(mtmthS0c2lBiobCkz8Zg(MOkcsDadQ6QffhrExxFMj2vZPWMcnZ3bt4Nn8nrveK6agUk5DD9zMyxnNcBk0mFhmHF2W3ef4CAffL311NzILVf5Ag)SHVjQIGuhWWvjVRRpZelFlY1m(zdFtuGZPvuKYwky5BrUMX2Avu2sblFlY1mgbCj9boN2QRggIlb7LiCzZfnXpA2HQaSrD3Futn)6vccDldQ9FDQoJn3ua1QVRRAeAc8oNamthS0c2lBiobCkzmNovN1IIY766ZmXmDWslyVSH4eWPKXpB4BIQii1bmirr5DD9zMyxnNcBk0mFhmHF2W3evrqQdy4QK311NzID1CkSPqZ8DWe(zdFtuGZPvuuExxFMjw(wKRz8Zg(MOkcsDadxL8UU(mtS8TixZ4Nn8nrboNwrrkBPGLVf5AgBRvrzlfS8TixZyeWL0h4CARggcmexc2lrybo53b3Jgu7)6uDo00n4HaOBCgQAVB5HrOjW7CcWtUHb)TR0mFhmH50P6Swue4VadWtS3bt4AjOYqq0QIMJqzlfSRMtHnfAMVdMW2ArrkBPGLVf5AgBRRUAyiUeSxIWcCYVdUhn7qvsV3BUeSx26lceA6g8qzZfnXpk0TmmD9GB1Nj)vgOHOiLTuWgSX9b3UsRBLRUPF2nqyBTOiLTuWiMbtBk0ExGX2ArrG35eG3KoTlAb7LyoDQoRvrzlf8M0PDrlyVeRpZu101dUvFM8xziCyiUeSxIWcCYVdUhn7qvMo9C7knhnXOq3YWi089v3y1CcWUwJWmDSiasu89v3y1CcWUwJWBwzonefr1CV3a(lWae20PNBxP5OjgvziOQvnY01dUvFM8h4aTIItxp4w9zY)WCvY766ZmXuDxZTR0ORfbwjJF2W3evrqQRw1iY766ZmXUAof2uOz(oyc)SHVjQYCAffbENtaw(wKRzmNovN1QK311NzILVf5Ag)SHVjQYCARggIlb7LiSaN87G7rZoufv31C7kn6ArGvYHULHPRhCR(m5pWHGefhz66b3Qpt(hcx1iY766ZmXtUHb)TR0mFhmHF2W3evrqQdyqIIQ9FDQoJdGUXz1vddXLG9sewGt(DW9OzhQIUwTGbNGq3YW01dUvFM8h4qqIIJmD9GB1Nj)boegvJiVRRpZet1Dn3UsJUweyLm(zdFtufbPoGbjkQ2)1P6moa6gNvxnmexc2lrybo53b3JMDOQj3WG)2vAMVdMcDldtxp4w9zYFGdHbgIlb7LiSaN87G7rZouL8selFhSxg6wgMUEWT6ZK)ahcsuC66b3Qpt(dCiCvY766ZmXuDxZTR0ORfbwjJF2W3evrqQdyqIItxp4w9zY)qyujVRRpZet1Dn3UsJUweyLm(zdFtufbPoGbPsExxFMjMUwTGbNa8Zg(MOkcsDadcgIlb7LiSaN87G7rZouL079Mlb7LT(IaHMUbpu2Crt8JcDldaVZjap5gg83UsZ8DWeMtNQZAva)fyaEI9oycxlbboeeTIIu2sb7Q5uytHM57GjSTwuKYwky5BrUMX2AyiUeSxIWcCYVdUhn7qvY3ICn)ne4x65q3YG8UU(mtS8TixZFdb(LEglN8xGrTY7sWEP3RmmhpU0q1itxp4w9zYFGdbjkoD9GB1Nj)boeUk5DD9zMyQUR52vA01IaRKXpB4BIQii1bmirXPRhCR(m5FimQK311NzIP6UMBxPrxlcSsg)SHVjQIGuhWGujVRRpZetxRwWGta(zdFtufbPoGbPsExxFMjwEjILVd2lXpB4BIQii1bmOQHH4sWEjclWj)o4E0Sdvj9EV5sWEzRViqOPBWdLnx0e)iyiUeSxIWcCYVdUhn7qvYlLCcEhW6wP7gmmexc2lrybo53b3JMDOk5BrUM)gc8l9COBzy66b3Qpt(dCimWqCjyVeHf4KFhCpA2HQ8x6j3a3)CccDldtxp4w9zYFGdHjQOMF0EzCSGODEaI2XB(4fvm9p3uafvcWAuFpG1qsaasCjyVes6lcGWWqIk9fbqXrJkAU42oioACS5XrJkUeSxgvEMYsphv40P6SooteehlO4OrfoDQoRJZevCjyVmQi9EV5sWEzRViquPViqlDdoQiVRRpZefbXXcpoAuHtNQZ64mrfxc2lJksV3BUeSx26lcev6lc0s3GJkcCYVdUhfbrquP(z5zq5G4OXXMhhnQ4sWEzuP(a7LrfoDQoRJZebXXckoAuHtNQZ64mrf5Va(xpQqtib4DobytNEUDLMJMyeMtNQZ6OIlb7Lrf)LEYnW9pNGiicIkY766ZmrXrJJnpoAuHtNQZ64mrf5Va(xpQmcKiVRRpZely9xVE2UsZdl(pWe(zdFteKubscq0cjIIqcnHegH4uYy5LAorSU13cxUxYydNU3djvdjQGKrGekBPGP63P7wea)SlbqIOiKqzlfSRMtHnfAMVdMW2AirfKqzlfSRMtHnfAMVdMWpB4BIGKkqY8XdsefHekBPGLVf5AgBRHevqcLTuWY3ICnJF2W3ebjbcjbrdiP6OIlb7LrL6dSxgbXXckoAuHtNQZ64mrf5Va(xpQGQ5EVb8xGbiCFfMaOgDTAbdobqsLbijiiruesgbsOjK8(QBSAobyxRryMoweabjIIqY7RUXQ5eGDTgH3esQajJlnGKQJkUeSxgv6RWea1ORvlyWjicIJfEC0OcNovN1XzIkYFb8VEuHYwkyxnNcBk0mFhmHT1qIOiKqzlfS8TixZyBnKOcsOSLcw(wKRzmc4s6HKbizoTrfxc2lJkL9zQ(D6iiowyIJgv40P6Sootur(lG)1Jku2sbJygmTPq7DbgRpZesubju2sbBWg3hC7kTUvU6M(z3aH1NzgvCjyVmQGMwURBxPPMtb2tjhbXXOrC0OcNovN1XzIkUeSxgvKEV3CjyVS1xeiQ0xeOLUbhva)M0ZaueehlaehnQWPt1zDCMOI8xa)RhvaRbdjboajbbjIIqcLTuWplPVZiuRCVKX26OIlb7LrfWe3Sj1ztDRCVKJG4yJBC0OcNovN1XzIkYFb8VEuHYwkyxnNcBk0mFhmHT1qIOiKqzlfS8TixZyBnKOcsOSLcw(wKRzmc4s6HKbizoTrfxc2lJku970TR0atCJt2i4iio24fhnQWPt1zDCMOI8xa)RhvOjKa8oNaS8TixZyoDQoRHevqYiqI8UU(mtSRMtHnfAMVdMWpB4BIGKaHeAajQGKPRhCR(m5hsQmajHdjQGKrGekBPG3KoTlAb7LyBnKikcj0esaENtaEt60UOfSxI50P6SgsQgsefHe5DD9zMyxnNcBk0mFhmHF2W3ebjvgGKWqdiPAiruesgbsaENtaw(wKRzmNovN1qIkirExxFMjw(wKRz8Zg(MiijqirqQHevqY01dUvFM8djvgGKWajIIqY01dUvFM8djvgGKWHevqcynyijqizoTqIkib4DobytNEUDLMJMyeMtNQZAiruesK311NzILVf5Ag)SHVjcsQmajHHgqs1rfxc2lJkcw)1RNTR08WI)dmfbXXcqXrJkC6uDwhNjQi)fW)6rf5DD9zMyxnNcBk0mFhmHF2W3ebjbcjcsnKOcsMUEWT6ZKFiPYaKeoKikcjY766ZmXY3ICnJF2W3ebjbcjcsnKOcsMUEWT6ZKFiPYaKegiruesK311NzID1CkSPqZ8DWe(zdFteKuzascdnGerrirExxFMjw(wKRz8Zg(MiiPYaKegAevCjyVmQyEFxRM3S9m6spLCeehBoTXrJkC6uDwhNjQi)fW)6rLrGeAcjVV6gRMta21AeMPJfbqqIOiK8(QBSAobyxRr4nHKkqs40cjIIqcQM79gWFbgGW6v9MCdbU3asQmajbbjvdjQGeAcjJaju2sb7Q5uytHM57GjSTgsefHekBPGLVf5AgBRHKQHevqYiqI8UU(mtmv31C7kn6ArGvY4Nn8nrqsfirqQHKacjHdjQGe5DD9zMy6A1cgCcWpB4BIGKkqIGudjbeschsQoQ4sWEzuPCslI1npS4FbCJIDJiio285XrJkC6uDwhNjQi)fW)6rLrGekBPGD1CkSPqZ8DWe2wdjIIqcLTuWY3ICnJT1qIkiHYwky5BrUMXiGlPhsgGK50cjvdjQGKPRhCR(m5hscCascpQ4sWEzuXGnUp42vADRC1n9ZUbkcIJnpO4OrfoDQoRJZevK)c4F9OYiqcnHK3xDJvZja7AncZ0XIaiiruesEF1nwnNaSR1i8MqsfijCAHerribvZ9Ed4Vadqy9QEtUHa3BajvgGKGGKQJkUeSxgvQT)wcEtHgv3rGiio28WJJgv40P6SootuXLG9YOImyz)a)LRSr1DeiQi)fW)6rfAcjJaju2sb7Q5uytHM57GjSTgsefHekBPGLVf5AgBRHKQHevqYiqI8UU(mtmv31C7kn6ArGvY4Nn8nrqsfirqQHKacjHdjQGe5DD9zMy6A1cgCcWpB4BIGKkqIGudjbeschsQoQWLclbT0n4OImyz)a)LRSr1DeicIJnpmXrJkC6uDwhNjQi)fW)6rLrGeAcjaVZjaVjDAx0c2lXC6uDwdjIIqcLTuWBsN2fTG9sSTgsQgsubjtxp4w9zYpKuzascpQ4sWEzuXvZPWMcnZ3btrqCS50ioAuHtNQZ64mrf5Va(xpQmD9GB1Nj)qsLbijmqIOiKmD9GB1Nj)qsLbijCirfKawdgscesMtlKOcsaENta20PNBxP5OjgH50P6SoQ4sWEzur(wKR5iicIkGFt6zakoACS5XrJkC6uDwhNjQKUbhvEpS02KEuJAfApRBuwa4YOIlb7LrL3dlTnPh1OwH2Z6gLfaUmcIJfuC0OcNovN1XzIkUeSxgvOlJAtNzN)OI8xa)RhvOSLc2vZPWMcnZ3btyBnKikcju2sblFlY1m2wdjQGekBPGLVf5AgJaUKEizasMtBujDdoQqxg1MoZo)rqCSWJJgv40P6SootuXLG9YOI617TR08CnCaRBu970rf5Va(xpQmcKqzlfSRMtHnfAMVdMW2AiruesOSLcw(wKRzSTgsubju2sblFlY1m(zdFteKeiKmF8GKQHerrizeirExxFMj2vZPWMcnZ3bt4Nn8nrqsfijCAHerrirExxFMjw(wKRz8Zg(MiiPcKeoTqs1rL0n4OI617TR08CnCaRBu970rqCSWehnQWPt1zDCMOIlb7Lrf9DgOwX(bhvK)c4F9OcLTuWUAof2uOz(oycBRHerriHYwky5BrUMX2AirfKqzlfS8TixZ4Nn8nrqsGqY8XlQKUbhv03zGAf7hCeehJgXrJkC6uDwhNjQ4sWEzurW7S07D(rnk2PpQi)fW)6rfkBPGD1CkSPqZ8DWe2wdjIIqcLTuWY3ICnJT1qIkiHYwky5BrUMXpB4BIGKaHK50iQKUbhve8ol9ENFuJID6JG4ybG4OrfoDQoRJZevCjyVmQqfSWLCJI5M3n80Lrf5Va(xpQqzlfSRMtHnfAMVdMW2AiruesOSLcw(wKRzSToQKUbhvOcw4sUrXCZ7gE6Yiio24ghnQWPt1zDCMOIlb7Lrfd(z6btoQv8uiQi)fW)6rLrGeAcjVV6gRMta21AeMPJfbqqIOiK8(QBSAobyxRr4nHKkqYCAajvdjIIqcQM79gWFbgGW6v9MCdbU3asQmajbfvs3GJkg8Z0dMCuR4PqeehB8IJgv40P6SootuXLG9YOsD3MA(Py)1OwP7i6JkYFb8VEuHYwkyxnNcBk0mFhmHT1qIOiKqzlfS8TixZyBnKOcsOSLcw(wKRzmc4s6HKkdqYCAHerrirExxFMj2vZPWMcnZ3bt4Nn8nrqsfijm0asefHeAcju2sblFlY1m2wdjQGe5DD9zMy5BrUMXpB4BIGKkqsyOrujDdoQu3TPMFk2FnQv6oI(iiowakoAuHtNQZ64mrfxc2lJku8J4NE(rn6APRnQi)fW)6rfkBPGD1CkSPqZ8DWe2wdjIIqcLTuWY3ICnJT1qIkiHYwky5BrUMXiGlPhsQmajZPfsefHe5DD9zMyxnNcBk0mFhmHF2W3ebjvGKWqdiruesOjKqzlfS8TixZyBnKOcsK311NzILVf5Ag)SHVjcsQajHHgrL0n4Ocf)i(PNFuJUw6AJG4yZPnoAuHtNQZ64mrfxc2lJkCQ7mc1aBkb2NBxPvExc2l9ER(m5pQi)fW)6rfkBPGD1CkSPqZ8DWe2wdjIIqcLTuWY3ICnJT1qIkiHYwky5BrUMXiGlPhsQmajZPfsefHe5DD9zMyxnNcBk0mFhmHF2W3ebjvGKWqdiruesK311NzILVf5Ag)SHVjcsQajHHgrL0n4OcN6oJqnWMsG952vAL3LG9sV3Qpt(JG4yZNhhnQWPt1zDCMOIlb7LrLA2)EtVQ5h1KNrTJqrf5Va(xpQqzlfSRMtHnfAMVdMW2AiruesOSLcw(wKRzSTgsubju2sblFlY1mgbCj9qsLbizoTrL0n4Osn7FVPx18JAYZO2rOiio28GIJgv40P6SootuXLG9YOszFeOz4ag1q1bl0DekQi)fW)6rfkBPGD1CkSPqZ8DWe2wdjIIqcLTuWY3ICnJT1qIkiHYwky5BrUMXpB4BIGKahGK50iQKUbhvk7JandhWOgQoyHUJqrqCS5HhhnQWPt1zDCMOIlb7LrfZP97MBkGA1DRHlWrf5Va(xpQqzlfSRMtHnfAMVdMW2AiruesOSLcw(wKRzSTgsubju2sblFlY1m(zdFteKe4aKeeTrL0n4OI50(DZnfqT6U1Wf4iio28WehnQWPt1zDCMOIlb7Lrf9ZUUj0D96G7rnkxlWrf5Va(xpQqzlfSRMtHnfAMVdMW2AiruesOSLcw(wKRzSTgsubju2sblFlY1m(zdFteKe4aKeeTrL0n4OI(zx3e6UEDW9OgLRf4iio2CAehnQWPt1zDCMOIlb7Lrf9ZUU5O699eGAgS2799YOI8xa)RhvOSLc2vZPWMcnZ3btyBnKikcju2sblFlY1m2wdjQGekBPGLVf5Ag)SHVjcscCascI2Os6gCur)SRBoQEFpbOMbR9EFVmcIJnpaehnQWPt1zDCMOIlb7LrfH)sbuR(xdV3ExGJkYFb8VEuHMqcLTuWUAof2uOz(oycBRHevqcnHekBPGLVf5AgBRJkPBWrfH)sbuR(xdV3ExGJG4yZh34OrfoDQoRJZevCjyVmQG2Cra(BcDxVo4EuJY1cCur(lG)1Jku2sb7Q5uytHM57GjSTgsefHekBPGLVf5AgBRHevqcLTuWY3ICnJF2W3ebjboajZPrujDdoQG2Cra(BcDxVo4EuJY1cCeehB(4fhnQWPt1zDCMOIlb7Lrf0MlcWFtO761b3JAgS2799YOI8xa)RhvOSLc2vZPWMcnZ3btyBnKikcju2sblFlY1m2wdjQGekBPGLVf5Ag)SHVjcscCascI2Os6gCubT5Ia83e6UEDW9OMbR9EFVmcIJnpafhnQWPt1zDCMOIlb7LrfpSqt(7Ow5sq7kT6ZK)OI8xa)RhvOjKa8oNaS8TixZyoDQoRHevqI8UU(mtSRMtHnfAMVdMWpB4BIGKaHeAajIIqcW7CcWY3ICnJ50P6SgsubjY766ZmXY3ICnJF2W3ebjbcj0asubjG1GHKkqYCAHerriz66b3Qpt(HKkdqs4qIkibSgmKeiKmNwirfKa8oNaSPtp3UsZrtmcZPt1zDujDdoQ4HfAYFh1kxcAxPvFM8hbXXcI24OrfoDQoRJZevCjyVmQOEr7LTR00SXI4OI8xa)RhvOSLc2vZPWMcnZ3btyBnKikcju2sblFlY1m2wdjQGekBPGLVf5AgJaUKEizasMtlKikcjY766ZmXUAof2uOz(oyc)SHVjcsQmajHtlKikcjY766ZmXY3ICnJF2W3ebjvgGKWPnQKUbhvuVO9Y2vAA2yrCeehlO5XrJkC6uDwhNjQ4sWEzuXrtQ9KrT3dR7BY79Eur(lG)1JkAMYwk43dR7BY79EtZu2sbRpZesefHKrGekBPGD1CkSPqZ8DWe(zdFteKuzascIwiruesOSLcw(wKRzmc4s6HKbizoTqIkiHYwky5BrUMXpB4BIGKkqYCAajvdjQGKrGe5DD9zMybR)61Z2vAEyX)bMWpB4BIGKkqsaIwiruesaRb3axtVmKeiKeoTqIOiKqtiHrioLmwEPMteRB9TWL7Lm2WP79qs1rL0n4OIJMu7jJAVhw33K379iiowqbfhnQWPt1zDCMOIlb7Lrf6Zd0UsZt5YjOvSFWrf5Va(xpQqzlfSRMtHnfAMVdMW2AiruesOSLcw(wKRzSTgsubju2sblFlY1mgbCj9qsLbizoTqIOiKiVRRpZe7Q5uytHM57Gj8Zg(MiiPcKeoTqIOiKqtiHYwky5BrUMX2AirfKiVRRpZelFlY1m(zdFteKubscN2Os6gCuH(8aTR08uUCcAf7hCeehlOWJJgv40P6Sootur(lG)1Jku2sb7Q5uytHM57GjSTgsefHekBPGLVf5AgBRHevqcLTuWY3ICnJraxspKmajZPnQ4sWEzuXI42cydueebrLYMlAIFuC04yZJJgv40P6Sootu5QJkigevCjyVmQO2)1P6CurT3TCuHMqctN2TUM1ypSqt(7Ow5sq7kT6ZKFirfKmcKqtib4Doby5BrUMXC6uDwdjQGe5DD9zMyxnNcBk0mFhmHF2W3ebjvGebPgsciKeoKikcjY766ZmXY3ICnJF2W3ebjvGebPgsciKeoKunKikcjmDA36AwJ9Wcn5VJALlbTR0Qpt(HevqYiqcnHeG35eGLVf5AgZPt1znKOcsK311NzID1CkSPqZ8DWe(zdFteKubseKAijGqsaasefHe5DD9zMy5BrUMXpB4BIGKkqIGudjbescaqs1rf1(3s3GJkMBkGA131JG4ybfhnQWPt1zDCMOYvhvqmiQ4sWEzurT)Rt15OIAVB5OcQM79gWFbgGW6v9MCdbU3asQmajbbjQGeAcjaVZja)RWeGplQPMF9kbyoDQoRHerribvZ9Ed4Vadqy9QEtUHa3BajvgGKWHevqcW7CcW)kmb4ZIAQ5xVsaMtNQZAiruesOSLcMnQd(zpB1Nj)yBnKOcs0mLTuW01Qfm4eG1NzcjQGekBPG1R6n5wT9RpeJ1NzcjQGekBPGD1CkSPqZ8DWuZTGt(laRpZmQO2)w6gCurJAshbCQohbXXcpoAuHtNQZ64mrf5Va(xpQqzlf8M0PDrlyVeRpZesefHekBPGD1CkSPqZ8DWewFMjKOcsgbsOSLcEt60UOfSxIF2W3ebjbcjJhKOcsMUEWT6ZKFiPYaKeoKikcjaVZjaZ0blTG9YgItaNsgZPt1znKOcsK311NzIz6GLwWEzdXjGtjJF2W3ebjbcjZPfsubju2sbVjDAx0c2lXpB4BIGKaHK50asefHe5DD9zMyxnNcBk0mFhmHF2W3ebjbcjZPbKOcsOSLcEt60UOfSxIF2W3ebjbcjbrlKOcsMUEWT6ZKFiPYaKeoKuDuXLG9YOYM0PDrlyVmcIJfM4OrfoDQoRJZevK)c4F9OcQM79gWFbgGW6v9MCdbU3ascCasccsubjJaj0esaENtaw(wKRzmNovN1qIkirExxFMj2vZPWMcnZ3bt4Nn8nrqsfizoTqIOiKa8oNaS8TixZyoDQoRHevqcLTuWY3ICnJ1NzcjQGe5DD9zMy5BrUMXpB4BIGKkqYCAHerriHYwky5BrUMXiGlPhsQmajJlKuDuXLG9YOcthS0c2lBiobCk5iiognIJgv40P6Sootur(lG)1JkQ9FDQoJ1OM0raNQZqIkirT)Rt1zS5McOw9DDirfKmcKmcKqtib4DobyMoyPfSx2qCc4uYyoDQoRHerrizeibvZ9Ed4Vadqy9QEtUHa3BajvgGKGGerrirExxFMjMPdwAb7LneNaoLm(zdFteKubseKAijGqsqqs1qs1qIOiKmcKiVRRpZe7Q5uytHM57Gj8Zg(MiiPcKii1qsaHKWHevqI8UU(mtSRMtHnfAMVdMWpB4BIGKaHK50cjIIqI8UU(mtS8TixZ4Nn8nrqsfirqQHKacjHdjQGe5DD9zMy5BrUMXpB4BIGKaHK50cjIIqcLTuWY3ICnJT1qIkiHYwky5BrUMXiGlPhscesMtlKunKuDuXLG9YOIEvVj3qG7nIG4ybG4OrfoDQoRJZevK)c4F9OIA)xNQZyZnfqT676qIkizeiHMqcW7CcWmDWslyVSH4eWPKXC6uDwdjIIqI8UU(mtmthS0c2lBiobCkz8Zg(MiiPcKii1qsaHKGGerrirExxFMj2vZPWMcnZ3bt4Nn8nrqsfirqQHKacjHdjQGe5DD9zMyxnNcBk0mFhmHF2W3ebjbcjZPfsefHe5DD9zMy5BrUMXpB4BIGKkqIGudjbeschsubjY766ZmXY3ICnJF2W3ebjbcjZPfsefHekBPGLVf5AgBRHevqcLTuWY3ICnJraxspKeiKmNwiP6OIlb7LrfaBu39h1uZVELGiicIkcCYVdUhfhno284OrfoDQoRJZevU6OcIbrfxc2lJkQ9FDQohvu7DlhvgbsOjKa8oNa8KByWF7knZ3btyoDQoRHerrib4VadWtS3bt4AjasQmajbrlKOcsOjKmcKqzlfSRMtHnfAMVdMW2AiruesOSLcw(wKRzSTgsQgsQoQO2)w6gCuja6gNrqCSGIJgv40P6Sootur(lG)1Jktxp4w9zYpKuzasObKikcju2sbBWg3hC7kTUvU6M(z3aHT1qIOiKqzlfmIzW0McT3fySTgsefHeG35eG3KoTlAb7LyoDQoRHevqcLTuWBsN2fTG9sS(mtirfKmD9GB1Nj)qsLbij8OIlb7LrfP37nxc2lB9fbIk9fbAPBWrLYMlAIFueehl84OrfoDQoRJZevK)c4F9OYiqcnHK3xDJvZja7AncZ0XIaiiruesEF1nwnNaSR1i8MqsfizonGerribvZ9Ed4VadqytNEUDLMJMyeKuzasccsQgsubjJajtxp4w9zYpKe4aKqlKikcjtxp4w9zYpKmajZHevqI8UU(mtmv31C7kn6ArGvY4Nn8nrqsfirqQHKQHevqYiqI8UU(mtSRMtHnfAMVdMWpB4BIGKkqYCAHerrib4Doby5BrUMXC6uDwdjQGe5DD9zMy5BrUMXpB4BIGKkqYCAHKQJkUeSxgvmD652vAoAIrrqCSWehnQWPt1zDCMOI8xa)RhvMUEWT6ZKFijWbijiiruesgbsMUEWT6ZKFizaschsubjJajY766ZmXtUHb)TR0mFhmHF2W3ebjvGebPgsciKeeKikcjQ9FDQoJdGUXjKunKuDuXLG9YOcv31C7kn6ArGvYrqCmAehnQWPt1zDCMOI8xa)RhvMUEWT6ZKFijWbijiiruesgbsMUEWT6ZKFijWbijmqIkizeirExxFMjMQ7AUDLgDTiWkz8Zg(MiiPcKii1qsaHKGGerrirT)Rt1zCa0noHKQHKQJkUeSxgvORvlyWjicIJfaIJgv40P6Sootur(lG)1Jktxp4w9zYpKe4aKeMOIlb7LrLj3WG)2vAMVdMIG4yJBC0OcNovN1XzIkYFb8VEuz66b3Qpt(HKahGKGGerriz66b3Qpt(HKahGKWHevqI8UU(mtmv31C7kn6ArGvY4Nn8nrqsfirqQHKacjbbjIIqY01dUvFM8djdqsyGevqI8UU(mtmv31C7kn6ArGvY4Nn8nrqsfirqQHKacjbbjQGe5DD9zMy6A1cgCcWpB4BIGKkqIGudjbesckQ4sWEzurEjILVd2lJG4yJxC0OcNovN1XzIkYFb8VEub4Dob4j3WG)2vAMVdMWC6uDwdjQGeG)cmapXEhmHRLaijWbijiAHerriHYwkyxnNcBk0mFhmHT1qIOiKqzlfS8TixZyBDuXLG9YOI079Mlb7LT(IarL(IaT0n4OszZfnXpkcIJfGIJgv40P6Sootur(lG)1JkY766ZmXY3ICn)ne4x6zSCYFbg1kVlb7LEhsQmajZXJlnGevqYiqY01dUvFM8djboajbbjIIqY01dUvFM8djboajHdjQGe5DD9zMyQUR52vA01IaRKXpB4BIGKkqIGudjbesccsefHKPRhCR(m5hsgGKWajQGe5DD9zMyQUR52vA01IaRKXpB4BIGKkqIGudjbesccsubjY766ZmX01Qfm4eGF2W3ebjvGebPgsciKeeKOcsK311NzILxIy57G9s8Zg(MiiPcKii1qsaHKGGKQJkUeSxgvKVf5A(BiWV0ZrqCS50ghnQWPt1zDCMOIlb7LrfP37nxc2lB9fbIk9fbAPBWrLYMlAIFueehB(84Orfxc2lJkYlLCcEhW6wP7gCuHtNQZ64mrqCS5bfhnQWPt1zDCMOI8xa)RhvMUEWT6ZKFijWbijmrfxc2lJkY3ICn)ne4x65iio28WJJgv40P6Sootur(lG)1Jktxp4w9zYpKe4aKeMOIlb7Lrf)LEYnW9pNGiicIGOIBbt3hvuwJXFeebXi]] )


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
