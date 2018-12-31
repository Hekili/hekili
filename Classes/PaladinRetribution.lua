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

    
    spec:RegisterPack( "Retribution", 20181230.2104, [[dKeSgbqiHGhPKsTjPOpjfOrHuvNIOkRsPsELsfZIOYTKcODr4xiLgMqYXqQSmKINjeAAiv5AisTnLkv9nejzCkPOZPKsQ1Pu18us6EkL9HO6GkPKSqPqpujLyIkPq6Ikvk(OskeJersDsLkLwjIYmvQuzNcPgQuawkIe9uKmvHORQKc(kIe2lP(lvnyQCyklgHhJQjtYLH2Su9zr1OvItRYQvs1RreZwKBtKDl53QA4c1XjQQLd65atxX1fSDIY3fLXlf05vsSELuOMVuA)OSMoDKAkLnOoAAIIU1KoAIyucAOlk6f1AQPMvIrnvSXjXYrnvzsOMIuId8icZ9LMk2wj9MshPMc8bih1ulZed2tlT53Seie8xIwWjfs2CFXHwFOfCsCAjspbTeDRbQqz0gd)(LqaTrEiKg6OnsAOZ3aSKPUYtkXbEeH5(saojUMIiCPz3wAcnLYguhnnrr3Ashnrmkbn0ff9IIuPPaXixhnPkkn1YPuyPj0ukeW1uRnZrkXbEeH5(I5AawYuxXiBTzULzIb7PL28Bwcec(lrl4KcjBUV4qRp0cojoTePNGwIU1avOmAJHF)siG2gaejL2Pa02aiL(gGLm1vEsjoWJim3xcWjXzKT2m3AuKJseiK5IyuYXC0efDRjZ1azoAIApPPhJmgzRnZTwwSkhb7zKT2mxdK5wdXkBqfZnWRibhGqtfd)(Lqn1AZCKsCGhryUVyUgGLm1vmYwBMBzMyWEAPn)MLaHG)s0coPqYM7lo06dTGtItlr6jOLOBnqfkJ2y43VecOTbarsPDkaTnasPVbyjtDLNuId8icZ9LaCsCgzRnZTgf5OebczUigLCmhnrr3AYCnqMJMO2tA6XiJr2AZCRLfRYrWEgzRnZ1azU1qSYguXCd8ksWbiyKXiBTzUDtdrEyqfZrG9hImh)LiSH5iW8RacMBTIZX4bWC1xnWfdk1djMZ4Z9fG5(kTIGrMXN7lGigI8xIWMTEYaKWiZ4Z9fqedr(lryZoB02)xXiZ4Z9fqedr(lryZoB0AHCjSgBUVyKT2mhvzXGLFyoODkMJi07OI5aJnaMJa7pezo(lrydZrG5xbyoRumxmeBGX)mxLZChG5uFHcgzgFUVaIyiYFjcB2zJwqzXGLF8GXgaJmJp3xarme5VeHn7SrB8p3xmYm(CFbeXqK)se2SZgTgKBf6NhcXAK76BrySewJiZib9F3BGfeiWYisOIrgJS1M52nne5HbvmhkdHRWCZjHm3SGmNXNhYChG5mz2LmIekyKz85(cSzH592mgNegzgFUVa7SrlejcKGmYm(CFb2zJwULsEJp3x(0bg5ktc3(ySqiJmJp3xGD2OLBPK34Z9LpDGrUYKWn()j1NvagzgFUVa7Srl3sjVXN7lF6aJCLjHB5yHqBEiGrgJmJp3xab))K6ZkWoB0gaO)gusUYKWnOTgRcfjapXL7HOYteM5lgzgFUVac()j1NvGD2Onaq)nOKCLjHBRJa)YNLqOCxFJi07ctgw5xL7ZG2SicXTTeHExWHbGPqriUjrO3fCyaykuagJtYgDrXiZ4Z9fqW)pP(ScSZgTba6VbLKRmjCt2zj)39wDs2Gkpr6FLCxFJ(eHExyYWk)QCFg0MfriUTLi07comamfkcXnjc9UGddatHcikzxbwLU1uETT0N)Fs9zLWKHv(v5(mOnlcikzxbipIr12Y)pP(SsWHbGPqbeLSRaKhXOKhJmJp3xab))K6ZkWoB0gaO)gusUYKWn1)saFpaxrURVre6DHjdR8RY9zqBweH42wIqVl4WaWuOie3Ki07comamfkGOKDfyv6wtgzgFUVac()j1NvGD2Onaq)nOKCLjHB5wc5wkHqGNansK76BeHExyYWk)QCFg0MfriUTLi07comamfkcXnjc9UGddatHcikzxbwLosZiZ4Z9fqW)pP(ScSZgTba6VbLKRmjCJyL8VqpbIEljzLXL76BeHExyYWk)QCFg0MfriUTLi07comamfkcXmYm(CFbe8)tQpRa7SrBaG(Bqj5ktc3KqisYSyaF3QC5U(g9Ja0oLhLH1imLciWgEGb02cTt5rzynctPaIRiNoslV2wqmMs(XG54aeQt2vOhmpuI8nAyKz85(ci4)NuFwb2zJ2aa93GsYvMeUfNcLcHeObvaFpzasK76BeHExyYWk)QCFg0MfriUTLi07comamfkcXnjc9UGddatHcWyCsiFJUOAB5)NuFwjmzyLFvUpdAZIaIs2vaYPhPBBJarO3fCyaykueIBY)pP(SsWHbGPqbeLSRaKtpsZiZ4Z9fqW)pP(ScSZgTba6VbLKRmjCJaHaesccb(1dRhK76BeHExyYWk)QCFg0MfriUTLi07comamfkcXnjc9UGddatHcWyCsiFJUOAB5)NuFwjmzyLFvUpdAZIaIs2vaYPhPBBJarO3fCyaykueIBY)pP(SsWHbGPqbeLSRaKtpsZiZ4Z9fqW)pP(ScSZgTba6VbLKRmjCdlvcba)CfFcq0)DFhA85(Ys(4pdHYD9nIqVlmzyLFvUpdAZIie32se6DbhgaMcfH4MeHExWHbGPqbymojKVrxuTT8)tQpReMmSYVk3NbTzrarj7ka50J0TT8)tQpReCyaykuarj7ka50J0mYm(CFbe8)tQpRa7SrBaG(Bqj5ktc3IrdM8QtgcbE(lfBaGCxFJi07ctgw5xL7ZG2SicXTTeHExWHbGPqriUjrO3fCyaykuagJtc5B0ffJmJp3xab))K6ZkWoB0gaO)gusUYKWT(bbJxYge4bXRKNmaqURVre6DHjdR8RY9zqBweH42wIqVl4WaWuOie3Ki07comamfkGOKDfy1n6inJmJp3xab))K6ZkWoB0gaO)gusUYKWTSLdMYUkh4JtbjlhL76BeHExyYWk)QCFg0MfriUTLi07comamfkcXnjc9UGddatHcikzxbwDJMOyKz85(ci4)NuFwb2zJ2aa93GsYvMeUPGOP85jtD28qGNWu5OCxFJi07ctgw5xL7ZG2SicXTTeHExWHbGPqriUjrO3fCyaykuarj7kWQB0efJmJp3xab))K6ZkWoB0gaO)gusUYKWnfenL3aXh0Qb4LqLLs3xYD9nIqVlmzyLFvUpdAZIie32se6DbhgaMcfH4MeHExWHbGPqbeLSRaRUrtumYm(CFbe8)tQpRa7SrBaG(Bqj5ktc3iP(X)DVv8dRX3dWvK76BeHExyYWk)QCFg0MfriUTLi07comamfkcXnjc9UGddatHcWyCsiFJUOAB5)NuFwjmzyLFvUpdAZIaIs2vaYJyuTTrGi07comamfkcXn5)NuFwj4WaWuOaIs2vaYJyumYm(CFbe8)tQpRa7SrBaG(BqjGCxFJi07ctgw5xL7ZG2SicXTTeHExWHbGPqriUjrO3fCyaykuagJtYgDrXiZ4Z9fqW)pP(ScSZgTX)CFj313OprO3feP)vPayeq04tBlrO3fMmSYVk3NbTzreIBBjc9UGddatHIqCtIqVl4WaWuOaIs2vGvPH0TTJbZXrmNe6N3RoC1n6fL8yKz85(ci4)NuFwb2zJ20LVma)6bvUewJCxFdeJPKFmyooar6YxgGF9GkxcRH8nAABPFeG2P8OmSgHPuab2WdmG2wODkpkdRrykfqCf5KkslpgzgFUVac()j1NvGD2OTFqKi9VsURVre6DHjdR8RY9zqBweH42wIqVl4WaWuOie3Ki07comamfkaJXjzJUOyKz85(ci4)NuFwb2zJwWYHjL)7EzyLJwXrgzgFUVac()j1NvGD2O1KHv(v5(mOnlYD9nIqVlUs(HdCZ9Lie32gHXsynIRKF4a3CFjWYisOIrMXN7lGG)Fs9zfyNnA5WaWuOCxFB5tR4J)mes(g9yKXiZ4Z9fq0V6alieSjZGNrKq5ktc3uap3aJrKq5KzPaUbIXuYpgmhhGqDYUc9G5HsKVrtZimwcRraV8Lb)aWldHQJpcSmIeQABbXyk5hdMJdqOozxHEW8qjY3IyZXsync4LVm4haEziuD8rGLrKqfJmJp3xar)QdSGqWoB0EL8dh4M7l5U(grO3fxj)WbU5(sO(SQTLi07IRKF4a3CFjGOKDfyvs3C5tR4J)mes(weBBhlH1iWgI8WCF5bynyXrbwgrcvn5)NuFwjWgI8WCF5bynyXrbeLSRaRsxunjc9U4k5hoWn3xcikzxbwLos32Y)pP(SsyYWk)QCFg0MfbeLSRaRshPBse6DXvYpCGBUVequYUcSknr1C5tR4J)mes(wezKz85(ci6xDGfec2zJwSHipm3xEawdwCuURVbIXuYpgmhhGqDYUc9G5HsRUrtt6hHXsyncomamfkWYisOQTL)Fs9zLGddatHcikzxbipNR2fnYJrMXN7lGOF1bwqiyNnAvNSRqpyEOKCxFtMbpJiHcfWZnWyejSjrO3fQt2vOpoaJFakGOXhgzgFUVaI(vhybHGD2OvDYUc9G5HsYD9nzg8mIekuap3aJrKWM0pcJLWAeCyaykuGLrKqvBl))K6ZkbhgaMcfquYUcqEoxTlAKxBlrO3fOu8kq0kF8NHqriUPcjc9Uy9GkxcRrO(SQjrO3fQt2vOpoaJFakuFwXiZ4Z9fq0V6alieSZgTdkfNmiWldHQJpYD9nIqVluNSRqFCag)auarJpmYm(CFbe9RoWccb7Sr7GsXjdc8YqO64JCxFJ(rySewJGddatHcSmIeQAB5)NuFwj4WaWuOaIs2vaYZ5QDfr51K(rySewJaBiYdZ9LhG1Gfhfyzeju12se6DbhgaMcfH4MeHExWHbGPqbymojRsxuTT8)tQpReydrEyUV8aSgS4OaIs2vaYZ5QDrJ8yKXiZ4Z9fqKJfcT5HGnzg8mIekxzs4gP(jfYjZsbCJ(rySewJyXKKqO)7(mOnlcSmIeQABhdMJJybT0SiI5d5B0evt6te6DHjdR8RY9zqBweQpRABjc9UGddatHc1NvYtEmYm(CFbe5yHqBEiyNnA5wk5n(CF5thyKRmjCRF1bwqiqURVT8Pv8XFgcjFJ0mYm(CFbe5yHqBEiyNnAZmsq)39gybbYD9n6hbODkpkdRrykfqGn8adOTfANYJYWAeMsbexroDKUTfeJPKFmyooarMrc6)U3aliG8nAKxt6V8Pv8XFgcxDlQ22LpTIp(Zq4gDn5)NuFwjisMc9F3VEamhhfquYUcqEoxjpgzgFUVaICSqOnpeSZgTejtH(V7xpaMJJYD9TLpTIp(Zq4QB002s)LpTIp(Zq4weBsF()j1NvIftscH(V7ZG2SiGOKDfG8CUAx002kZGNrKqbP(jfYtEmYm(CFbe5yHqBEiyNnAxpOYLWAK76BlFAfF8NHWv3OPTL(lFAfF8NHWv3Oxt6Z)pP(SsqKmf6)UF9ayookGOKDfG8CUAx002kZGNrKqbP(jfYtEmYm(CFbe5yHqBEiyNnAxmjje6)UpdAZICxFB5tR4J)meU6g9yKz85(ciYXcH28qWoB0Y)cGCOn3xYD9TLpTIp(Zq4QB002U8Pv8XFgcxDlIn5)NuFwjisMc9F3VEamhhfquYUcqEoxTlAABx(0k(4pdHB0Rj))K6ZkbrYuO)7(1dG54OaIs2vaYZ5QDrtt()j1NvI1dQCjSgbeLSRaKNZv7IggzgFUVaICSqOnpeSZgTClL8gFUV8PdmYvMeU1V6aliei313glH1iwmjje6)UpdAZIalJiHQM0FmyooIf0sZIiMpRUrtuTTeHExyYWk)QCFg0MfriUTLi07comamfkcXYJrMXN7lGihleAZdb7SrlhgaMcHEWapsq5U(g))K6ZkbhgaMcHEWapsqbFXG5iW3HgFUVSe5B0jivKUj9x(0k(4pdHRUrtB7YNwXh)ziC1Ti2K)Fs9zLGizk0)D)6bWCCuarj7ka55C1UOPTD5tR4J)meUrVM8)tQpReejtH(V7xpaMJJcikzxbipNR2fnn5)NuFwjwpOYLWAequYUcqEoxTlAAY)pP(SsW)cGCOn3xcikzxbipNR2fnYJrMXN7lGihleAZdb7Srl3sjVXN7lF6aJCLjHB9RoWccbmYm(CFbe5yHqBEiyNnA5WaWui0dg4rck313w(0k(4pdHRUrpgzgFUVaICSqOnpeSZgTgKBf6NhcXAK76BlFAfF8NHWv3OhJmgzgFUVaIpgleUbq5hWIJYD9TXsynImJe0)DVbwqGalJiHQMJLWAeCyaykuGLrKqvZXsyncSHipm3xEawdwCuGLrKqvZimwcRrSyssi0)DFg0MfbwgrcvYvMeULzKG(pgle63nu(1c1EWYHjL)7EzyLJwXX9ejtH(V7xpaMJJ7xpOYLWA2ZHbGPW9dkfNmiWldHQJp7Zmsq)39gybb7hukozqGxgcvhF2ZHbGPqOhmWJeCp2qKhM7lpaRbloYiZ4Z9fq8XyHWD2OfGYpGfhL76BJLWAezgjO)7EdSGabwgrcvnhlH1i4WaWuOalJiHQMrySewJaBiYdZ9LhG1Gfhfyzeju1mcJLWAelMKec9F3NbTzrGLrKqLCLjHBzgjO)JXcH(1c1EWYHjL)7EzyLJwXX9ejtH(V7xpaMJJ7xpOYLWA2ZHbGPW9dkfNmiWldHQJp7Zmsq)39gybb7hukozqGxgcvhF2ZHbGPqOhmWJeC)GsXjdc8YqO64dJmJp3xaXhJfc3zJwak)awCuURVnwcRrKzKG(V7nWcceyzeju1CSewJGddatHcSmIeQAowcRrGne5H5(YdWAWIJcSmIeQAowcRrSyssi0)DFg0MfbwgrcvYvMeULzKG(pgle63nuEs9tk2dwomP8F3ldRC0koUNizk0)D)6bWCCC)6bvUewZEomamfUFqP4KbbEziuD8zFMrc6)U3aliy)GsXjdc8YqO64Z(ftscH(V7ZG2SShBiYdZ9LhG1GfhzKz85(ci(ySq4oB0cq5hWIJYD9TXsynImJe0)DVbwqGalJiHQMJLWAeCyaykuGLrKqvZimwcRrGne5H5(YdWAWIJcSmIeQAowcRrSyssi0)DFg0MfbwgrcvYvMeULzKG(pgle6j1pPypy5WKY)DVmSYrR44EIKPq)39RhaZXX9Rhu5syn75WaWu4(bLItge4LHq1XN9zgjO)7EdSGG9dkfNmiWldHQJp7xmjje6)UpdAZY(bLItge4LHq1XhgzgFUVaIpgleUZgTau(bS4OCxFBSewJiZib9F3BGfeiWYisOQ5yjSgXvYpCGBUVeyzejujxzs4wMrc6)ySqOF3wYFpy5WKY)DVmSYrR44EIKPq)39RhaZXX9Rhu5syn7Vs(HdCZ91Etgw5xL7ZG2SSpZib9F3BGfeOPKHqW9LoAAIIU1KoAOlkrurr3AQPYmyDvoqtrkwRiLrVBJEnYEMJ5ICbzUtk(HdZ1FiZ1GFmwiSbzoik)WbrfZbEjK5SW8s2GkMJVyvocemY2DxHmhD7zU1qbcXXpCqfZz85(I5Aqak)awCSbfmY2DxHmhn7zU1qbcXXpCqfZz85(I5Aqak)awCSbfmY2DxHmxe3ZCRHceIJF4GkMZ4Z9fZ1Gau(bS4ydkyKT7Uczo6TN5wdfieh)WbvmNXN7lMRbbO8dyXXguWiB3DfYCKEpZTgkqio(HdQyoJp3xmxdcq5hWIJnOGrgJmsXAfPm6DB0Rr2ZCmxKliZDsXpCyU(dzUguHDlKMgK5GO8dhevmh4LqMZcZlzdQyo(Iv5iqWiB3DfYC0TN5wdfieh)WbvmNXN7lMRbTW8EBgJtsdkyKXiB3kf)Wbvm3UN5m(CFXCPdmabJmnv6adqhPM6JXcH6i1rtNosnfwgrcv6g1ugFUV0uau(bS4OMQmjutLzKG(pgle63nu(1c1EWYHjL)7EzyLJwXX9ejtH(V7xpaMJJ7xpOYLWA2ZHbGPW9dkfNmiWldHQJp7Zmsq)39gybb7hukozqGxgcvhF2ZHbGPqOhmWJeCp2qKhM7lpaRbloQP4WBq4zAQXsynImJe0)DVbwqGalJiHkMRjZnwcRrWHbGPqbwgrcvmxtMBSewJaBiYdZ9LhG1GfhfyzejuXCnzUiWCJLWAelMKec9F3NbTzrGLrKqLE0rtJosnfwgrcv6g1ugFUV0uau(bS4OMQmjutLzKG(pgle6xlu7blhMu(V7LHvoAfh3tKmf6)UF9ayooUF9GkxcRzphgaMc3pOuCYGaVmeQo(SpZib9F3BGfeSFqP4KbbEziuD8zphgaMcHEWapsW9dkfNmiWldHQJpAko8geEMMASewJiZib9F3BGfeiWYisOI5AYCJLWAeCyaykuGLrKqfZ1K5IaZnwcRrGne5H5(YdWAWIJcSmIeQyUMmxeyUXsynIftscH(V7ZG2SiWYisOsp6OJOosnfwgrcv6g1ugFUV0uau(bS4OMQmjutLzKG(pgle63nuEs9tk2dwomP8F3ldRC0koUNizk0)D)6bWCCC)6bvUewZEomamfUFqP4KbbEziuD8zFMrc6)U3aliy)GsXjdc8YqO64Z(ftscH(V7ZG2SShBiYdZ9LhG1Gfh1uC4ni8mn1yjSgrMrc6)U3aliqGLrKqfZ1K5glH1i4WaWuOalJiHkMRjZnwcRrGne5H5(YdWAWIJcSmIeQyUMm3yjSgXIjjHq)39zqBweyzejuPhD00thPMclJiHkDJAkJp3xAkak)awCutvMeQPYmsq)hJfc9K6NuShSCys5)Uxgw5OvCCprYuO)7(1dG544(1dQCjSM9CyaykC)GsXjdc8YqO64Z(mJe0)DVbwqW(bLItge4LHq1XN9lMKec9F3NbTzz)GsXjdc8YqO64JMIdVbHNPPglH1iYmsq)39gybbcSmIeQyUMm3yjSgbhgaMcfyzejuXCnzUiWCJLWAeydrEyUV8aSgS4OalJiHkMRjZnwcRrSyssi0)DFg0Mfbwgrcv6rhnP1rQPWYisOs3OMY4Z9LMcGYpGfh1uLjHAQmJe0)XyHq)UTK)EWYHjL)7EzyLJwXX9ejtH(V7xpaMJJ7xpOYLWA2FL8dh4M7R9MmSYVk3NbTzzFMrc6)U3aliqtXH3GWZ0uJLWAezgjO)7EdSGabwgrcvmxtMBSewJ4k5hoWn3xcSmIeQ0JE0ukSBH0OJuhnD6i1ugFUV0uwyEVnJXjrtHLrKqLUr9OJMgDKAkJp3xAkiseib1uyzejuPBup6OJOosnfwgrcv6g1ugFUV0uClL8gFUV8PdmAQ0bgFzsOM6JXcH6rhn90rQPWYisOs3OMY4Z9LMIBPK34Z9LpDGrtLoW4ltc1u8)tQpRa6rhnP1rQPWYisOs3OMY4Z9LMIBPK34Z9LpDGrtLoW4ltc1u5yHqBEiqp6rtfdr(lryJosD00PJutHLrKqLUr9OJMgDKAkSmIeQ0nQhD0ruhPMclJiHkDJ6rhn90rQPWYisOs3OE0rtADKAkJp3xAQ4FUV0uyzejuPBup6O396i1uyzejuPButXH3GWZ0urG5glH1iYmsq)39gybbcSmIeQ0ugFUV0ugKBf6NhcXA0JE0u8)tQpRa6i1rtNosnfwgrcv6g1uLjHAkOTgRcfjapXL7HOYteM5lnLXN7lnf0wJvHIeGN4Y9qu5jcZ8LE0rtJosnfwgrcv6g1ugFUV0uRJa)YNLqOMIdVbHNPPic9UWKHv(v5(mOnlIqmZ12YCeHExWHbGPqriM5AYCeHExWHbGPqbymojm3gZrxuAQYKqn16iWV8zjeQhD0ruhPMclJiHkDJAkJp3xAkzNL8F3B1jzdQ8eP)vAko8geEMMI(mhrO3fMmSYVk3NbTzreIzU2wMJi07comamfkcXmxtMJi07comamfkGOKDfG5wL5OBnzo5XCTTmh9zo()j1Nvctgw5xL7ZG2SiGOKDfG5iN5IyumxBlZX)pP(SsWHbGPqbeLSRamh5mxeJI5KNMQmjutj7SK)7ERojBqLNi9Vsp6OPNosnfwgrcv6g1ugFUV0uQ)La(EaUIMIdVbHNPPic9UWKHv(v5(mOnlIqmZ12YCeHExWHbGPqriM5AYCeHExWHbGPqbeLSRam3QmhDRPMQmjutP(xc47b4k6rhnP1rQPWYisOs3OMY4Z9LMk3si3sjec8eOrIMIdVbHNPPic9UWKHv(v5(mOnlIqmZ12YCeHExWHbGPqriM5AYCeHExWHbGPqbeLSRam3QmhDKwtvMeQPYTeYTucHapbAKOhD07EDKAkSmIeQ0nQPm(CFPPiwj)l0tGO3sswzCnfhEdcpttre6DHjdR8RY9zqBweHyMRTL5ic9UGddatHIqSMQmjutrSs(xONarVLKSY46rhnPshPMclJiHkDJAkJp3xAkjeIKmlgW3TkxtXH3GWZ0u0N5IaZbTt5rzynctPacSHhyamxBlZbTt5rzynctPaIRyoYzo6inZjpMRTL5aXyk5hdMJdqOozxHEW8qjMJ8nMJgnvzsOMscHijZIb8DRY1Jo61uhPMclJiHkDJAkJp3xAQ4uOuiKanOc47jdqIMIdVbHNPPic9UWKHv(v5(mOnlIqmZ12YCeHExWHbGPqriM5AYCeHExWHbGPqbymojmh5BmhDrXCTTmh))K6ZkHjdR8RY9zqBwequYUcWCKZC0J0mxBlZfbMJi07comamfkcXmxtMJ)Fs9zLGddatHcikzxbyoYzo6rAnvzsOMkofkfcjqdQa(EYaKOhD0R16i1uyzejuPButz85(strGqacjbHa)6H1dAko8geEMMIi07ctgw5xL7ZG2SicXmxBlZre6DbhgaMcfHyMRjZre6DbhgaMcfGX4KWCKVXC0ffZ12YC8)tQpReMmSYVk3NbTzrarj7kaZroZrpsZCTTmxeyoIqVl4WaWuOieZCnzo()j1NvcomamfkGOKDfG5iN5OhP1uLjHAkcecqijie4xpSEqp6OPlkDKAkSmIeQ0nQPm(CFPPWsLqaWpxXNae9F33HgFUVSKp(ZqOMIdVbHNPPic9UWKHv(v5(mOnlIqmZ12YCeHExWHbGPqriM5AYCeHExWHbGPqbymojmh5BmhDrXCTTmh))K6ZkHjdR8RY9zqBwequYUcWCKZC0J0mxBlZX)pP(SsWHbGPqbeLSRamh5mh9iTMQmjutHLkHaGFUIpbi6)UVdn(CFzjF8NHq9OJMo60rQPWYisOs3OMY4Z9LMkgnyYRozie45VuSbaAko8geEMMIi07ctgw5xL7ZG2SicXmxBlZre6DbhgaMcfHyMRjZre6DbhgaMcfGX4KWCKVXC0fLMQmjutfJgm5vNmec88xk2aa9OJMoA0rQPWYisOs3OMY4Z9LMQFqW4LSbbEq8k5jda0uC4ni8mnfrO3fMmSYVk3NbTzreIzU2wMJi07comamfkcXmxtMJi07comamfkGOKDfG5wDJ5OJ0AQYKqnv)GGXlzdc8G4vYtgaOhD00frDKAkSmIeQ0nQPm(CFPPYwoyk7QCGpofKSCutXH3GWZ0ueHExyYWk)QCFg0MfriM5ABzoIqVl4WaWuOieZCnzoIqVl4WaWuOaIs2vaMB1nMJMO0uLjHAQSLdMYUkh4Jtbjlh1JoA6ONosnfwgrcv6g1ugFUV0ukiAkFEYuNnpe4jmvoQP4WBq4zAkIqVlmzyLFvUpdAZIieZCTTmhrO3fCyaykueIzUMmhrO3fCyaykuarj7kaZT6gZrtuAQYKqnLcIMYNNm1zZdbEctLJ6rhnDKwhPMclJiHkDJAkJp3xAkfenL3aXh0Qb4LqLLs3xAko8geEMMIi07ctgw5xL7ZG2SicXmxBlZre6DbhgaMcfHyMRjZre6DbhgaMcfquYUcWCRUXC0eLMQmjutPGOP8gi(GwnaVeQSu6(sp6OPB3RJutHLrKqLUrnLXN7lnfj1p(V7TIFyn(EaUIMIdVbHNPPic9UWKHv(v5(mOnlIqmZ12YCeHExWHbGPqriM5AYCeHExWHbGPqbymojmh5BmhDrXCTTmh))K6ZkHjdR8RY9zqBwequYUcWCKZCrmkMRTL5IaZre6DbhgaMcfHyMRjZX)pP(SsWHbGPqbeLSRamh5mxeJstvMeQPiP(X)DVv8dRX3dWv0JoA6iv6i1uyzejuPButXH3GWZ0ueHExyYWk)QCFg0MfriM5ABzoIqVl4WaWuOieZCnzoIqVl4WaWuOamgNeMBJ5OlknLXN7lnvaG(BqjGE0rt3AQJutHLrKqLUrnfhEdcpttrFMJi07cI0)QuamciA8H5ABzoIqVlmzyLFvUpdAZIieZCTTmhrO3fCyaykueIzUMmhrO3fCyaykuarj7kaZTkZrdPzU2wMBmyooI5Kq)8E1Hm3QBmh9II5KNMY4Z9LMk(N7l9OJMU1ADKAkSmIeQ0nQP4WBq4zAkqmMs(XG54aePlFza(1dQCjSgMJ8nMJgMRTL5OpZfbMdANYJYWAeMsbeydpWayU2wMdANYJYWAeMsbexXCKZCKksZCYttz85(stLU8Lb4xpOYLWA0JoAAIshPMclJiHkDJAko8geEMMIi07ctgw5xL7ZG2SicXmxBlZre6DbhgaMcfHyMRjZre6DbhgaMcfGX4KWCBmhDrPPm(CFPP6hejs)R0JoAAOthPMY4Z9LMcSCys5)Uxgw5OvCutHLrKqLUr9OJMgA0rQPWYisOs3OMIdVbHNPPic9U4k5hoWn3xIqmZ12YCrG5glH1iUs(HdCZ9LalJiHknLXN7lnLjdR8RY9zqBw0JoAAIOosnfwgrcv6g1uC4ni8mn1YNwXh)ziK5iFJ5ONMY4Z9LMIddatH6rpAQ(vhybHaDK6OPthPMclJiHkDJAkzwkGAkqmMs(XG54aeQt2vOhmpuI5iFJ5OH5AYCrG5glH1iGx(YGFa4LHq1XhbwgrcvmxBlZbIXuYpgmhhGqDYUc9G5Hsmh5BmxezUMm3yjSgb8Yxg8daVmeQo(iWYisOstz85(stjZGNrKqnLmd6ltc1ukGNBGXisOE0rtJosnfwgrcv6g1uC4ni8mnfrO3fxj)WbU5(sO(SI5ABzoIqVlUs(HdCZ9LaIs2vaMBvMJ0mxtMB5tR4J)meYCKVXCrK5ABzUXsyncSHipm3xEawdwCuGLrKqfZ1K54)NuFwjWgI8WCF5bynyXrbeLSRam3QmhDrXCnzoIqVlUs(HdCZ9LaIs2vaMBvMJosZCTTmh))K6ZkHjdR8RY9zqBwequYUcWCRYC0rAMRjZre6DXvYpCGBUVequYUcWCRYC0efZ1K5w(0k(4pdHmh5Bmxe1ugFUV0uxj)WbU5(sp6OJOosnfwgrcv6g1uC4ni8mnfigtj)yWCCac1j7k0dMhkXCRUXC0WCnzo6ZCrG5glH1i4WaWuOalJiHkMRTL54)NuFwj4WaWuOaIs2vaMJCMlNRyUDXC0WCYttz85(stHne5H5(YdWAWIJ6rhn90rQPWYisOs3OMIdVbHNPPKzWZisOqb8CdmgrczUMmhrO3fQt2vOpoaJFakGOXhnLXN7lnL6KDf6bZdL0JoAsRJutHLrKqLUrnfhEdcpttjZGNrKqHc45gymIeYCnzo6ZCrG5glH1i4WaWuOalJiHkMRTL54)NuFwj4WaWuOaIs2vaMJCMlNRyUDXC0WCYJ5ABzoIqVlqP4vGOv(4pdHIqmZ1K5uirO3fRhu5sync1NvmxtMJi07c1j7k0hhGXpafQpR0ugFUV0uQt2vOhmpusp6O396i1uyzejuPButXH3GWZ0ueHExOozxH(4am(bOaIgF0ugFUV0udkfNmiWldHQJp6rhnPshPMclJiHkDJAko8geEMMI(mxeyUXsyncomamfkWYisOI5ABzo()j1NvcomamfkGOKDfG5iN5Y5kMBxmxezo5XCnzo6ZCrG5glH1iWgI8WCF5bynyXrbwgrcvmxBlZre6DbhgaMcfHyMRjZre6DbhgaMcfGX4KWCRYC0ffZ12YC8)tQpReydrEyUV8aSgS4OaIs2vaMJCMlNRyUDXC0WCYttz85(stnOuCYGaVmeQo(Oh9OPYXcH28qGosD00PJutHLrKqLUrnLmlfqnf9zUiWCJLWAelMKec9F3NbTzrGLrKqfZ12YCJbZXrSGwAweX8H5iFJ5OjkMRjZrFMJi07ctgw5xL7ZG2SiuFwXCTTmhrO3fCyaykuO(SI5KhZjpnLXN7lnLmdEgrc1uYmOVmjutrQFsHE0rtJosnfwgrcv6g1uC4ni8mn1YNwXh)ziK5iFJ5iTMY4Z9LMIBPK34Z9LpDGrtLoW4ltc1u9RoWccb6rhDe1rQPWYisOs3OMIdVbHNPPOpZfbMdANYJYWAeMsbeydpWayU2wMdANYJYWAeMsbexXCKZC0rAMRTL5aXyk5hdMJdqKzKG(V7nWccyoY3yoAyo5XCnzo6ZClFAfF8NHqMB1nMlkMRTL5w(0k(4pdHm3gZrhZ1K54)NuFwjisMc9F3VEamhhfquYUcWCKZC5CfZjpnLXN7lnvMrc6)U3aliqp6OPNosnfwgrcv6g1uC4ni8mn1YNwXh)ziK5wDJ5OH5ABzo6ZClFAfF8NHqMBJ5IiZ1K5OpZX)pP(SsSyssi0)DFg0MfbeLSRamh5mxoxXC7I5OH5ABzozg8mIeki1pPG5KhZjpnLXN7lnfrYuO)7(1dG54OE0rtADKAkSmIeQ0nQP4WBq4zAQLpTIp(ZqiZT6gZrdZ12YC0N5w(0k(4pdHm3QBmh9yUMmh9zo()j1NvcIKPq)39RhaZXrbeLSRamh5mxoxXC7I5OH5ABzozg8mIeki1pPG5KhZjpnLXN7ln16bvUewJE0rV71rQPWYisOs3OMIdVbHNPPw(0k(4pdHm3QBmh90ugFUV0ulMKec9F3NbTzrp6Ojv6i1uyzejuPButXH3GWZ0ulFAfF8NHqMB1nMJgMRTL5w(0k(4pdHm3QBmxezUMmh))K6ZkbrYuO)7(1dG54OaIs2vaMJCMlNRyUDXC0WCTTm3YNwXh)ziK52yo6XCnzo()j1NvcIKPq)39RhaZXrbeLSRamh5mxoxXC7I5OH5AYC8)tQpReRhu5syncikzxbyoYzUCUI52fZrJMY4Z9LMI)fa5qBUV0Jo61uhPMclJiHkDJAko8geEMMASewJyXKKqO)7(mOnlcSmIeQyUMmh9zUXG54iwqlnlIy(WCRUXC0efZ12YCeHExyYWk)QCFg0MfriM5ABzoIqVl4WaWuOieZCYttz85(stXTuYB85(YNoWOPshy8LjHAQ(vhybHa9OJETwhPMclJiHkDJAko8geEMMI)Fs9zLGddatHqpyGhjOGVyWCe47qJp3xwI5iFJ5OtqQinZ1K5OpZT8Pv8XFgczUv3yoAyU2wMB5tR4J)meYCRUXCrK5AYC8)tQpReejtH(V7xpaMJJcikzxbyoYzUCUI52fZrdZ12YClFAfF8NHqMBJ5OhZ1K54)NuFwjisMc9F3VEamhhfquYUcWCKZC5CfZTlMJgMRjZX)pP(SsSEqLlH1iGOKDfG5iN5Y5kMBxmhnmxtMJ)Fs9zLG)fa5qBUVequYUcWCKZC5CfZTlMJgMtEAkJp3xAkomamfc9GbEKG6rhnDrPJutHLrKqLUrnLXN7lnf3sjVXN7lF6aJMkDGXxMeQP6xDGfec0JoA6OthPMclJiHkDJAko8geEMMA5tR4J)meYCRUXC0ttz85(stXHbGPqOhmWJeup6OPJgDKAkSmIeQ0nQP4WBq4zAQLpTIp(ZqiZT6gZrpnLXN7lnLb5wH(5HqSg9Oh9OPSWS8qnf1jTw0JE0Aa]] )


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
