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

    
    spec:RegisterPack( "Retribution", 20181210.0011, [[dGKkXaqiQGEeirTja8juegfOuNcuYQOc8kqsZsq1TqrKDj0VqbddGCmQqldK6zsf10eu6AcGTjavFdKiJtaIZjve16eK5jvY9a0(OICqPIiluQupeKateKGCrue1hbjOgPur6KsfHvckMPaK2jvudfKqlvqrpfrtff1vfGYxfuyVe(lvnysomLfJspgvtMuxw1Mr4ZGy0sXPvA1cOxJcnBIUnvA3I(TIHlLooa1YH65qMUKRd02fOVlvnEuKoVuH5dQ2pslCuWSGuB1fodnGCmG4i0o6yeqaYrafGaUGS6O9cYwJZOb5cY0CVGmmFHxwWANuq2ADihtlywqIgqm)cYMQArHyGbiB1aYg5JldO1fuA1ojhBefdO1LZaRCyzGLWys6hKHw8qSYJyG59yODKbMH2rpu0KMEtFy(cVSG1ozeTUCbjl4kRorkyfKARUWzObKJbehH2rhJacqack15olirTNlCgkbibzZQ1pfScs9rCbjuMQcZx4LfS2jPkOOjn9MuyGYuvtvTOqmWaKTAazJ8XLb06ckTANKJnIIb06YzGvoSmWsymj9dYqlEiw5rmafXpmTvJyakgMEOOjn9M(W8fEzbRDYiAD5uyGYufuOZVl7XuLJogovbnGCmGqvmjQcqakeGGwq2IhIvEbjuMQcZx4LfS2jPkOOjn9MuyGYuvtvTOqmWaKTAazJ8XLb06ckTANKJnIIb06YzGvoSmWsymj9dYqlEiw5rmafXpmTvJyakgMEOOjn9M(W8fEzbRDYiAD5uyGYufuOZVl7XuLJogovbnGCmGqvmjQcqakeGGMcdfgOmvXKz65G11uf7jg8Pk(4YAfvXEiBIIuvNeN)2crv5KmPgd7sakPkJx7KiQAszhrkmgV2jrXw85JlRvajKgIrkmgV2jrXw85JlRvqfideZOPWy8ANefBXNpUSwbvGmyGqCFwwTtsHbktvKP1IAMIQW2QPkwqcIRPkuzfIQypXGpvXhxwROk2dztevzPMQAXNj1ovTjeQAruLEYhPWy8ANefBXNpUSwbvGmGsRf1mLhvwHOWy8ANefBXNpUSwbvGm0o1ojfgJx7KOyl(8XL1kOcKbdZT8(AW4Nv4lbqhwM8zf7ngVFi8gQ5O4tJvEnfgkmqzQIjZ0ZbRRPQh84oOQADpvvnNQmEnyQAruLf0wPXkFKcJXRDseqdSgVvLXzKcJXRDseubYa(SGmEkmgV2jrqfidCtk9gV2j9YfvHNM7boTppMcJXRDseubYa3KsVXRDsVCrv4P5EG8zK6PpruymETtIGkqg4Mu6nETt6LlQcpn3deYZJTAWikmuymETtII8zK6Pprabr3V1Ddpn3dmWJ8ntV84WxcGSGeerl4tiBcX3JTQjc2cholibrKJbrM(rWwaybjiICmiY0pIkJZiqhbefgJx7KOiFgPE6teubYq7u7KHVeaHnlibrKvoJwcIQi(gVGdNfKGiAbFczti(ESvnrWw4WzbjiICmiY0pc2calibrKJbrM(r8DTnrDbDaGdVmmKxXADVVgVEFxadlGGffgJx7KOiFgPE6teubYGCH0uiFGGAiUpRWxcGO2lL(YWqEHIYfstH8bcQH4(SCci0WHdBhITv7FWNv00Au8mDrfcoCSTA)d(SIMwJIB6eukaWIcJXRDsuKpJup9jcQazGyXNvoJo8Lailibr0c(eYMq89yRAIGTWHZcsqe5yqKPFeSfawqcIihdIm9JOY4mc0rarHX41ojkYNrQN(ebvGmGA2l1(HWh8jKBj)uymETtII8zK6PprqfidwWNq2eIVhBvt4lbqwqcI4MagCrBTtgbBHd3HLjFwXnbm4I2ANm(0yLxtHX41ojkYNrQN(ebvGmWXGit)WxcGnJSdF70FStadlfgkmgV2jrrInxuZXiGbn8ASYhEAUhOg55gQmw5dpOjbpqu7LsFzyiVqr9gCZ7r1GDDci0uymETtIIeBUOMJrqfidBcyWfT1oz4lbqwqcI4MagCrBTtg1tFcholibrCtadUOT2jJ47ABI6kaa0mYo8Tt)XobSZWHxM8zfptphS2j9ON1t(Jpnw51aWNrQN(mEMEoyTt6rpRN8hX312e1LJacawqcI4MagCrBTtgX312e1LJbaoC(ms90Nrl4tiBcX3JTQjIVRTjQlhdaaSGeeXnbm4I2ANmIVRTjQlObeanJSdF70FSta7mfgJx7KOiXMlQ5yeubYWz65G1oPh9SEYF4lbqu7LsFzyiVqr9gCZ7r1GD7ci0aaBhwM8zf5yqKPF8PXkVgoC(ms90Nrogez6hX312e5eeU2bqdlkmgV2jrrInxuZXiOcKb9gCZ7r1GDdFjag0WRXkFuJ8CdvgR8aWcsqe1BWnVVfe3oOhX34ffgJx7KOiXMlQ5yeubYGEdU59OAWUHVeadA41yLpQrEUHkJvEaGTdlt(SICmiY0p(0yLxdhoFgPE6ZihdIm9J47ABICccx7aOHfC4SGeeX722b(w6BN(JJGTaOplibrmqqne3Nvup9jaSGeer9gCZ7BbXTd6r90NuymETtIIeBUOMJrqfid1DBLgg5dESE5v4lbqwqcIOEdU59TG42b9i(gVOWy8ANefj2CrnhJGkqgQ72knmYh8y9YRWxcGW2HLjFwrogez6hFASYRHdNpJup9zKJbrM(r8DTnrobHRDqNHfaW2HLjFwXZ0ZbRDsp6z9K)4tJvEnC4SGeerogez6hbBbGfKGiYXGit)iQmoJD5iGGdNpJup9z8m9CWAN0JEwp5pIVRTjYjiCTdGgwuyOWy8ANefH88yRgmcyqdVgR8HNM7b2PtyeEqtcEGW2HLjFwXgZ19y)q47Xw1eFASYRHdVmmKxXMBYQj2YlNacnGaa2SGeerl4tiBcX3JTQjQN(eoCwqcIihdIm9J6PpHfSOWy8ANefH88yRgmcQazGBsP341oPxUOk80CpqInxuZXOWxcGnJSdF70FStadafgJx7KOiKNhB1Grqfid9gJ3peEd1Cu4lbqy7qSTA)d(SIMwJINPlQqWHJTv7FWNv00AuCtNCmaWHJAVu6ldd5fk2BmE)q4nuZrobeAybaSBgzh(2P)4Uaci4WBgzh(2P)yGocaFgPE6ZiR003pe(abr1YFeFxBtKtq4AyrHX41ojkc55XwnyeubYaR003pe(abr1YF4lbWMr2HVD6pUlGqdhoSBgzh(2P)yGDgayZNrQN(m2yUUh7hcFp2QMi(U2MiNGW1oaA4WdA41yLp2PtyalyrHX41ojkc55XwnyeubYqGGAiUpRWxcGnJSdF70FCxaHgoCy3mYo8Tt)XDbmSaaB(ms90NrwPPVFi8bcIQL)i(U2MiNGW1oaA4WdA41yLp2PtyalyrHX41ojkc55XwnyeubYqJ56ESFi89yRAcFja2mYo8Tt)XDbmSuymETtIIqEESvdgbvGmWNeDo2QDYWxcGnJSdF70FCxaHgo8Mr2HVD6pUlGDga(ms90NrwPPVFi8bcIQL)i(U2MiNGW1oaA4WBgzh(2P)yGHfa(ms90NrwPPVFi8bcIQL)i(U2MiNGW1oaAa4Zi1tFgdeudX9zfX312e5eeU2bqtHX41ojkc55XwnyeubYa3KsVXRDsVCrv4P5EGeBUOMJrHVealt(SInMR7X(HW3JTQj(0yLxdaSldd5vS5MSAIT8QlGqdi4WzbjiIwWNq2eIVhBvteSfoCwqcIihdIm9JGTWIcJXRDsueYZJTAWiOcKbogez6J9OcVm(WxcG8zK6PpJCmiY0h7rfEz8rEJHHCKNaB8AN0Kob0Xiukaaa7Mr2HVD6pUlGqdhEZi7W3o9h3fWodaFgPE6ZiR003pe(abr1YFeFxBtKtq4AhanC4nJSdF70FmWWcaFgPE6ZiR003pe(abr1YFeFxBtKtq4Ahana8zK6PpJbcQH4(SI47ABICccx7aObGpJup9zKpj6CSv7Kr8DTnrobHRDa0WIcJXRDsueYZJTAWiOcKbUjLEJx7KE5IQWtZ9aj2CrnhJOWy8ANefH88yRgmcQazGJbrM(ypQWlJp8LayZi7W3o9h3fWWsHX41ojkc55XwnyeubYGH5wEFny8Zk8LayZi7W3o9h3fWWsHHcJXRDsuCAFEmq0bm4t(dFjawM8zf7ngVFi8gQ5O4tJvEnaLjFwrogez6hFASYRbOm5ZkEMEoyTt6rpRN8hFASYRbWHLjFwXgZ19y)q47Xw1eFASYRdpn3dS3y8(P95XEMmPhkGmeQzVu7hcFWNqUL8hIvA67hcFGGOA5puGGAiUpRqCmiY0puD3wPHr(GhRxEfQ3y8(HWBOMJcv3TvAyKp4X6LxH4yqKPp2Jk8Y4dDMEoyTt6rpRN8tHX41ojkoTppgQazaDad(K)WxcGLjFwXEJX7hcVHAok(0yLxdqzYNvKJbrM(XNgR8AaCyzYNv8m9CWAN0JEwp5p(0yLxdGdlt(SInMR7X(HW3JTQj(0yLxhEAUhyVX49t7ZJ9qbKHqn7LA)q4d(eYTK)qSstF)q4deevl)HceudX9zfIJbrM(HQ72knmYh8y9YRq9gJ3peEd1CuO6UTsdJ8bpwV8kehdIm9XEuHxgFO6UTsdJ8bpwV8IcJXRDsuCAFEmubYa6ag8j)HVealt(SI9gJ3peEd1Cu8PXkVgGYKpRihdIm9Jpnw51auM8zfptphS2j9ON1t(Jpnw51auM8zfBmx3J9dHVhBvt8PXkVo80CpWEJX7N2Nh7zYK(oDcJqOM9sTFi8bFc5wYFiwPPVFi8bcIQL)qbcQH4(ScXXGit)q1DBLgg5dESE5vOEJX7hcVHAokuD3wPHr(GhRxEfQXCDp2pe(ESvnHotphS2j9ON1t(PWy8ANefN2NhdvGmGoGbFYF4lbWYKpRyVX49dH3qnhfFASYRbOm5ZkYXGit)4tJvEnaoSm5ZkEMEoyTt6rpRN8hFASYRbOm5Zk2yUUh7hcFp2QM4tJvED4P5EG9gJ3pTpp23Ptyec1SxQ9dHp4ti3s(dXkn99dHpqquT8hkqqne3Nviogez6hQUBR0WiFWJ1lVc1BmE)q4nuZrHQ72knmYh8y9YRqnMR7X(HW3JTQjuD3wPHr(GhRxErHX41ojkoTppgQazaDad(K)WxcGLjFwXEJX7hcVHAok(0yLxdqzYNvCtadUOT2jJpnw51HNM7b2BmE)0(8yFNibCiuZEP2pe(GpHCl5peR003pe(abr1YFOab1qCFwH2eWGlARDYqwWNq2eIVhBvtOEJX7hcVHAosqg8y0oPWzObKJbehbeGCmcOozhdGGS3W5MqqcYWOtkmDUt4mu4qufvXCZPQ1TDWfvrmyQIjM2NhZeuf(agCXxtvOX9uLbwJRvxtv8glHCuKctaDZtvogIQcyjcSTDW11uLXRDsQIjqhWGp5NjIuycOBEQc6quvalrGTTdUUMQmETtsvmb6ag8j)mrKctaDZtvDoevfWseyB7GRRPkJx7KuftGoGbFYptePWeq38uvydrvbSeb22o46AQY41ojvXeOdyWN8Zerkmb0npvfGquvalrGTTdUUMQmETtsvmb6ag8j)mrKcdfMWOtkmDUt4mu4qufvXCZPQ1TDWfvrmyQIj0NWaLftqv4dyWfFnvHg3tvgynUwDnvXBSeYrrkmb0npv5yiQkGLiW22bxxtvgV2jPkMWaRXBvzCgzIifgkmDc32bxxtvbCQY41ojvjxuHIuyeKYfvibZcYP95XcMfo7OGzb5tJvETOBbjhV1XRjilt(SI9gJ3peEd1Cu8PXkVMQaGQkt(SICmiY0p(0yLxtvaqvLjFwXZ0ZbRDsp6z9K)4tJvEnvbav5qQQm5Zk2yUUh7hcFp2QM4tJvETG041oPGeDad(KFbzAUxq2BmE)0(8yptM0dfqgc1SxQ9dHp4ti3s(dXkn99dHpqquT8hkqqne3Nviogez6hQUBR0WiFWJ1lVc1BmE)q4nuZrHQ72knmYh8y9YRqCmiY0h7rfEz8HotphS2j9ON1t(fLWzOfmliFASYRfDli54ToEnbzzYNvS3y8(HWBOMJIpnw51ufauvzYNvKJbrM(XNgR8AQcaQYHuvzYNv8m9CWAN0JEwp5p(0yLxtvaqvoKQkt(SInMR7X(HW3JTQj(0yLxlinETtkirhWGp5xqMM7fK9gJ3pTpp2dfqgc1SxQ9dHp4ti3s(dXkn99dHpqquT8hkqqne3Nviogez6hQUBR0WiFWJ1lVc1BmE)q4nuZrHQ72knmYh8y9YRqCmiY0h7rfEz8HQ72knmYh8y9YlrjCUZcMfKpnw51IUfKC8whVMGSm5Zk2BmE)q4nuZrXNgR8AQcaQQm5ZkYXGit)4tJvEnvbavvM8zfptphS2j9ON1t(Jpnw51ufauvzYNvSXCDp2pe(ESvnXNgR8AbPXRDsbj6ag8j)cY0CVGS3y8(P95XEMmPVtNWieQzVu7hcFWNqUL8hIvA67hcFGGOA5puGGAiUpRqCmiY0puD3wPHr(GhRxEfQ3y8(HWBOMJcv3TvAyKp4X6LxHAmx3J9dHVhBvtOZ0ZbRDsp6z9KFrjCoScMfKpnw51IUfKC8whVMGSm5Zk2BmE)q4nuZrXNgR8AQcaQQm5ZkYXGit)4tJvEnvbav5qQQm5ZkEMEoyTt6rpRN8hFASYRPkaOQYKpRyJ56ESFi89yRAIpnw51csJx7Kcs0bm4t(fKP5EbzVX49t7ZJ9D6egHqn7LA)q4d(eYTK)qSstF)q4deevl)HceudX9zfIJbrM(HQ72knmYh8y9YRq9gJ3peEd1CuO6UTsdJ8bpwV8kuJ56ESFi89yRAcv3TvAyKp4X6LxIs4CaemliFASYRfDli54ToEnbzzYNvS3y8(HWBOMJIpnw51ufauvzYNvCtadUOT2jJpnw51csJx7Kcs0bm4t(fKP5EbzVX49t7ZJ9DIeWHqn7LA)q4d(eYTK)qSstF)q4deevl)HceudX9zfAtadUOT2jdzbFczti(ESvnH6ngVFi8gQ5irjkbP(egOSemlC2rbZcsJx7KcsdSgVvLXzuq(0yLxl6wucNHwWSG041oPGeFwqgVG8PXkVw0TOeo3zbZcYNgR8Ar3csJx7KcsUjLEJx7KE5IkbPCrLpn3liN2NhlkHZHvWSG8PXkVw0TG041oPGKBsP341oPxUOsqkxu5tZ9cs(ms90NirjCoacMfKpnw51IUfKgV2jfKCtk9gV2j9Yfvcs5IkFAUxqc55XwnyKOeLGSfF(4YALGzHZokywq(0yLxl6wucNHwWSG8PXkVw0TOeo3zbZcYNgR8Ar3Is4CyfmliFASYRfDlkHZbqWSG041oPGSDQDsb5tJvETOBrjCoGlywq(0yLxl6wqYXBD8AcshsvLjFwXEJX7hcVHAok(0yLxlinETtkinm3Y7RbJFwIsucs(ms90NibZcNDuWSG8PXkVw0TGmn3lid8iFZ0lpwqA8ANuqg4r(MPxESGKJ3641eKSGeerl4tiBcX3JTQjc2svWHtvSGeerogez6hbBPkaOkwqcIihdIm9JOY4msvaPkhbKOeodTGzb5tJvETOBbjhV1XRjiHnvXcsqezLZOLGOkIVXlQcoCQIfKGiAbFczti(ESvnrWwQcoCQIfKGiYXGit)iylvbavXcsqe5yqKPFeFxBtev1fvbDaOk4WPQYWqEfR19(A869uvxaPQWciQcwcsJx7KcY2P2jfLW5olywq(0yLxl6wqYXBD8Acsu7LsFzyiVqr5cPPq(ab1qCFwuLtaPkOPk4WPkytvoKQW2Q9p4ZkAAnkEMUOcrvWHtvyB1(h8zfnTgf3KQCIQGsbGQGLG041oPGuUqAkKpqqne3NLOeohwbZcYNgR8Ar3csoERJxtqYcsqeTGpHSjeFp2QMiylvbhovXcsqe5yqKPFeSLQaGQybjiICmiY0pIkJZivbKQCeqcsJx7KcsIfFw5mArjCoacMfKgV2jfKOM9sTFi8bFc5wYVG8PXkVw0TOeohWfmliFASYRfDli54ToEnbjlibrCtadUOT2jJGTufC4uLdPQYKpR4MagCrBTtgFASYRfKgV2jfKwWNq2eIVhBvJOeodLemliFASYRfDli54ToEnbzZi7W3o9htvobKQcRG041oPGKJbrM(IsucsInxuZXibZcNDuWSGmOjbVGe1EP0xggYluuVb38EunyxQYjGuf0cYNgR8Ar3csJx7KcYGgEnw5fKbnSpn3li1ip3qLXkVOeodTGzb5tJvETOBbjhV1XRjizbjiIBcyWfT1ozup9jvbhovXcsqe3eWGlARDYi(U2MiQQlQkaufauvZi7W3o9htvobKQ6mvbhovvM8zfptphS2j9ON1t(Jpnw51ufaufFgPE6Z4z65G1oPh9SEYFeFxBtev1fv5iGOkaOkwqcI4MagCrBTtgX312ervDrvogaQcoCQIpJup9z0c(eYMq89yRAI47ABIOQUOkhdavbavXcsqe3eWGlARDYi(U2MiQQlQcAarvaqvnJSdF70Fmv5eqQQZcsJx7KcYnbm4I2ANuucN7SGzb5tJvETOBbjhV1XRjirTxk9LHH8cf1BWnVhvd2LQ6civbnvbavbBQYHuvzYNvKJbrM(XNgR8AQcoCQIpJup9zKJbrM(r8DTnruLtufeUMQCavbnvblbPXRDsb5z65G1oPh9SEYVOeohwbZcYNgR8Ar3csoERJxtqg0WRXkFuJ8CdvgR8ufauflibruVb38(wqC7GEeFJxcsJx7Kcs9gCZ7r1GDfLW5aiywq(0yLxl6wqYXBD8AcYGgEnw5JAKNBOYyLNQaGQGnv5qQQm5ZkYXGit)4tJvEnvbhovXNrQN(mYXGit)i(U2MiQYjQccxtvoGQGMQGfvbhovXcsqeVBBh4BPVD6poc2svaqv6ZcsqedeudX9zf1tFsvaqvSGeer9gCZ7BbXTd6r90NcsJx7Kcs9gCZ7r1GDfLW5aUGzb5tJvETOBbjhV1XRjizbjiI6n4M33cIBh0J4B8sqA8ANuqw3TvAyKp4X6LxIs4musWSG8PXkVw0TGKJ3641eKWMQCivvM8zf5yqKPF8PXkVMQGdNQ4Zi1tFg5yqKPFeFxBtev5evbHRPkhqvDMQGfvbavbBQYHuvzYNv8m9CWAN0JEwp5p(0yLxtvWHtvSGeerogez6hbBPkaOkwqcIihdIm9JOY4msvDrvociQcoCQIpJup9z8m9CWAN0JEwp5pIVRTjIQCIQGW1uLdOkOPkyjinETtkiR72knmYh8y9YlrjkbjKNhB1GrcMfo7OGzbzqtcEbjSPkhsvLjFwXgZ19y)q47Xw1eFASYRPk4WPQYWqEfBUjRMylVOkNasvqdiQcaQc2uflibr0c(eYMq89yRAI6PpPk4WPkwqcIihdIm9J6PpPkyrvWsq(0yLxl6wqA8ANuqg0WRXkVGmOH9P5EbzNoHHOeodTGzb5tJvETOBbPXRDsbj3KsVXRDsVCrLGKJ3641eKnJSdF70Fmv5eqQkacs5IkFAUxqsS5IAogjkHZDwWSG8PXkVw0TGKJ3641eKWMQCivHTv7FWNv00Au8mDrfIQGdNQW2Q9p4ZkAAnkUjv5ev5yaOk4WPku7LsFzyiVqXEJX7hcVHAoIQCcivbnvblQcaQc2uvZi7W3o9htvDbKQaevbhov1mYo8Tt)XufqQYrQcaQIpJup9zKvA67hcFGGOA5pIVRTjIQCIQGW1ufSeKgV2jfK9gJ3peEd1CKOeohwbZcYNgR8Ar3csoERJxtq2mYo8Tt)XuvxaPkOPk4WPkytvnJSdF70FmvbKQ6mvbavbBQIpJup9zSXCDp2pe(ESvnr8DTnruLtufeUMQCavbnvbhovf0WRXkFStNWGQGfvblbPXRDsbjR003pe(abr1YVOeohabZcYNgR8Ar3csoERJxtq2mYo8Tt)XuvxaPkOPk4WPkytvnJSdF70Fmv1fqQkSufaufSPk(ms90NrwPPVFi8bcIQL)i(U2MiQYjQccxtvoGQGMQGdNQcA41yLp2PtyqvWIQGLG041oPGmqqne3NLOeohWfmliFASYRfDli54ToEnbzZi7W3o9htvDbKQcRG041oPGSXCDp2pe(ESvnIs4musWSG8PXkVw0TGKJ3641eKnJSdF70Fmv1fqQcAQcoCQQzKD4BN(JPQUasvDMQaGQ4Zi1tFgzLM((HWhiiQw(J47ABIOkNOkiCnv5aQcAQcoCQQzKD4BN(JPkGuvyPkaOk(ms90NrwPPVFi8bcIQL)i(U2MiQYjQccxtvoGQGMQaGQ4Zi1tFgdeudX9zfX312ervorvq4AQYbuf0csJx7Kcs(KOZXwTtkkHZbebZcYNgR8Ar3csJx7KcsUjLEJx7KE5IkbjhV1XRjilt(SInMR7X(HW3JTQj(0yLxtvaqvWMQkdd5vS5MSAIT8IQ6civbnGOk4WPkwqcIOf8jKnH47Xw1ebBPk4WPkwqcIihdIm9JGTufSeKYfv(0CVGKyZf1CmsucN7KfmliFASYRfDli54ToEnbjFgPE6ZihdIm9XEuHxgFK3yyih5jWgV2jnjv5eqQYXiukaufaufSPQMr2HVD6pMQ6civbnvbhov1mYo8Tt)XuvxaPQotvaqv8zK6PpJSstF)q4deevl)r8DTnruLtufeUMQCavbnvbhov1mYo8Tt)XufqQkSufaufFgPE6ZiR003pe(abr1YFeFxBtev5evbHRPkhqvqtvaqv8zK6PpJbcQH4(SI47ABIOkNOkiCnv5aQcAQcaQIpJup9zKpj6CSv7Kr8DTnruLtufeUMQCavbnvblbPXRDsbjhdIm9XEuHxgVOeo7iGemliFASYRfDlinETtki5Mu6nETt6LlQeKYfv(0CVGKyZf1CmsucND0rbZcYNgR8Ar3csoERJxtq2mYo8Tt)XuvxaPQWkinETtki5yqKPp2Jk8Y4fLWzhHwWSG8PXkVw0TGKJ3641eKnJSdF70Fmv1fqQkScsJx7KcsdZT8(AW4NLOeLOeKgy1mybj56cfikrjea]] )


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
