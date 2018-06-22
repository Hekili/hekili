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
            duration = 20,
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

        greater_blessing_of_kings = {
            id = 203538,
            duration = 3600,
            max_stack = 1,
        },

        greater_blessing_of_wisdom = {
            id = 203539,
            duration = 3600,
            max_stack = 1,
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
                applyBuff( 'avenging_wrath', 20 )
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
            cooldown = function () return ( talent.fires_of_justice.enabled and 5 or 6 ) * haste end,
            recharge = function () return ( talent.fires_of_justice.enabled and 5 or 6 ) * haste end,
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
            charges = function () return talent.cavalier.enabled and 2 or 1 end,
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
                if level < 115 then
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
            
            startsCombat = true,
            texture = 135993,
            
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
            
            startsCombat = true,
            texture = 135912,
            
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
            end,
        },
        

        rebuke = {
            id = 96231,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

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

    spec:RegisterPack( "Retribution", 20180622.175200, [[deeXHaqiGOhrrGAtcQrbKofqzvsQ8kjvnljf7Iu)sqmmvsoMKslJI6zqQAAueDnGW2ujL(gfHgNkPW5OiG1rrqmpGQ7Pc7tLyHcOlsrqzKqQ0jPiOALuKEjfbPDkadLIazPQKIEkGPcP8vivSxu(RedgQdt1IjQhtyYu6YiBMiFwfnAH60kTAbPxdj1Sj52sYUf9BfdxL64QKQLd65OA6sDDi2Ua9DHmEijNhsmFkSFvnRwgAmaR3elaZxv714QR1SzDTMiimBYAzank3ed42fO2pjgq6ved4AsnCLr6DsgWTJIACldngaFqGcIbe39n3esiHC78MK3ulMQqGEuiRja6r91uycycLbiJSQ2eEYcKby9Myby(QAVgxDTMnRR1ebHzZMKbWVjblat8kgGL4cgaAXl)Xl)XDm9ylj5iQ(XUO3jF8TlqTFspwAGp(AsnCLr6DYhBcYvUDtUMbCdhPvrmatWp2egQibst2htbjikpU3k6XDm9yx0d8Xl)XEqFvUSI0VPUO3j5hospfVBxG63ux07K86pcbsYiOMEtDrVtYR)ieHRufx07Kf1Y7AsVIoMBkjynR0rVve4Mdhpkuk3tebbh9VPUO3j51FeIWvQIl6DYIA5DnPxrhIzu2jk5VPUO3j51FeIWvQIl6DYIA5DnPxrhNusqVhi)n9n1f9ojxlMrzNOKFCp9oznR0bOYissAz1mwfcV1qYfTHHmIKK2ds55MNLiO3XAKBddzejjTaIWDlPrUdlJijPfqeUBjnKQ8n5GBgeggTdpPw3Bfv6Pyxc8dtEfyVPUO3j5AXmk7eL86pcrTNXnVekI9SIYUMv6GFtkvPD4j1CTApJBEjue7zfL9LdZggGcsOV2cfKYw7wlxtOA5n3Wa6RTqbPS1U1Y1BEXebbyVPUO3j5AXmk7eL86pcHhVKYwgPsqkpjpf0BQl6DsUwmJYorjV(Jq8GuEU5zjc6DCnR0HmIKKEZRJS8T3j1i3ggGSDfLTEZRJS8T3j1u6YkY(M6IENKRfZOStuYR)iebeH7wQMv6iEuOuUNicE5WKVPVPUO3j5APnxEmb5hbD46YkQM0ROdlViCE7YkQMGUcHo43KsvAhEsnxB3GBsfEpWQlhO3WODfLT2Ub3KkHIypROS1u6YkYgMFtkvPD4j1CTDdUjv49aRUCy(n1f9ojxlT5YJjiV(Jq286ilF7DYAwPdzejj9Mxhz5BVtQTtuAyiJijP386ilF7DsnKQ8n5GdIWXJcLY9erWlhMnmeZOStuQjurcKENSWPSPuqAiv5BYbV2RclJijP386ilF7DsnKQ8n5GxliEtDrVtY1sBU8ycYR)iecvKaP3jlCkBkfunR0b)MuQs7WtQ5A7gCtQW7bwb(b6ddkiBxrzRfqeUBjnLUSISggIzu2jk1cic3TKgsv(M8lNcBDMb7n1f9ojxlT5YJjiV(JqSBWnPcVhyvnR0rqhUUSI0wEr482LvuyzejjTDdUjvUrG3dN0qYf9BQl6DsUwAZLhtqE9hHy3GBsfEpWQAwPJGoCDzfPT8IW5TlROWGcY2vu2AbeH7wstPlRiRHHygLDIsTaIWDlPHuLVj)YPWwNzWEtDrVtY1sBU8ycYR)iKMQUvoKxcsq7k6AwPdzejjTDdUjvUrG3dN0qYfDyqbz7kkBnHksG07KfoLnLcstPlRiRHHygLDIsnHksG07KfoLnLcsdPkFt(LtHfS3ux07KCT0MlpMG86pcPPQBLd5LGe0UIUMv6auq2UIYwlGiC3sAkDzfznmeZOStuQfqeUBjnKQ8n5xof26mdwyqbz7kkBnHksG07KfoLnLcstPlRiRHHmIKKwar4UL0i3HLrKK0cic3TKM3Ua1Gx7vggIzu2jk1eQibsVtw4u2ukinKQ8n5xof26md2B6BQl6DsU(Ksc69a5hbD46YkQM0ROd0DqNAc6ke6auq2UIYwh7vveSmsLiO3XAkDzfznmAhEsToMCvhRVf9LdZxfguzejjThKYZnplrqVJ12jknmKrKK0cic3TK2orjyG9M6IENKRpPKGEpqE9hHiCLQ4IENSOwExt6v0H0MlpMG8AwPJ4rHs5EIi4Ldq8M6IENKRpPKGEpqE9hHe5OMkJuX5XeVMv6auqc91wOGu2A3A5AcvlV5ggqFTfkiLT2TwUEZlMVcSWGgpkuk3tebb)4kdJ4rHs5EIi4rTHfZOStuQLvULkJujueEVcsdPkFt(LtHfS3ux07KC9jLe07bYR)iezLBPYivcfH3RGQzLoIhfkL7jIGGFy2Wa04rHs5EIi4b6ddQygLDIsDSxvrWYivIGEhRHuLVj)YPWwNzdJGoCDzfPr3bDadS3ux07KC9jLe07bYR)iKqrSNvu21SshXJcLY9erqWpmByepkuk3tebb)a9HfZOStuQLvULkJujueEVcsdPkFt(LtHToZggGgpkuk3tebpmzyqfZOStuQLvULkJujueEVcsdPkFt(LtHToZggbD46YksJUd6agyVPUO3j56tkjO3dKx)riXEvfblJujc6D8BQl6DsU(Ksc69a51FeIysojGEVtwZkDepkuk3tebb)WSHr8OqPCpree8d0hwmJYorPww5wQmsLqr49kinKQ8n5xof26mByaA8OqPCpre8WKHfZOStuQLvULkJujueEVcsdPkFt(LtHToZHfZOStuQdfXEwrzRHuLVj)YPWwN5WbD46YksJUd6a2BQl6DsU(Ksc69a51FeIWvQIl6DYIA5DnPxrhsBU8ycYRzLoAxrzRJ9QkcwgPse07ynLUSISHbTD4j16yYvDS(w0GFy(kddzejjThKYZnplrqVJ1i3ggYissAbeH7wsJCdwyqLrKK02n4Mu5gbEpCsJCByiJijPfqeUBjnVDbQbV2Ra7n1f9ojxFsjb9EG86pcrar4ULGfEdxut1SshIzu2jk1cic3TeSWB4IAslID4jXlsqx07KU6YrTAteeHbnEuOuUNicc(HzdJ4rHs5EIii4hOpSygLDIsTSYTuzKkHIW7vqAiv5BYVCkS1z2WiEuOuUNicEyYWIzu2jk1Yk3sLrQekcVxbPHuLVj)YPWwN5WIzu2jk1HIypROS1qQY3KF5uyRZCyXmk7eLAXKCsa9ENudPkFt(LtHToZHd6W1LvKgDh0bS3ux07KC9jLe07bYR)ieHRufx07Kf1Y7AsVIoK2C5XeK)M6IENKRpPKGEpqE9hHiGiC3sWcVHlQP3ux07KC9jLe07bYR)iehk8Kk9aHu21SshGAjzejjnHksG07KfoLnLcsJCByaA7kkBDSxvrWYivIGEhRP0LvKnmOTdpPwhtUQJ13I(YH5RmmKrKK0Eqkp38Seb9owBNO0WqgrsslGiC3sA7eLGbMHbiBxrzRjurcKENSWPSPuqAkDzfznmaz7kkBDSxvrWYivIGEhRP0LvKfSWXJcLY9erqWpm5B6BQl6DsUEUPKGhHe5OMkJuX5Xe)n1f9ojxp3usW6pcrw5wQmsLqr49kOAwPJ4rHs5EIii4G4n1f9ojxp3usW6pcjue7zfLDnR0r8OqPCpreeCqWacsq(ojlaZxv714QR18v6AVwqacgqKdZnp5magGA5nNHgdyUPKGm0ybuldngGl6DsgqKJAQmsfNhtCgaLUSISSaznlaZm0yau6YkYYcKbiGBtW1zaXJcLY9erWhd(JbbdWf9ojdqw5wQmsLqr49kiwZca9m0yau6YkYYcKbiGBtW1zaXJcLY9erWhd(JbbdWf9ojdiue7zfLnRzndWssoIQzOXcOwgAmax07KmahPNI3TlqndGsxwrwwGSMfGzgAmax07KmaijJGAIbqPlRillqwZca9m0yau6YkYYcKbiGBtW1za9wrpg8hB(XHFC8OqPCpre8XG)y0ZaCrVtYaeUsvCrVtwulVzaQL3L0RigWCtjbznlatYqJbqPlRillqgGl6DsgGWvQIl6DYIA5ndqT8UKEfXaeZOStuYznlaqWqJbqPlRillqgGl6DsgGWvQIl6DYIA5ndqT8UKEfXaoPKGEpqoRznd4gsIPs2BgASMbiMrzNOKZqJfqTm0yau6YkYYcKbiGBtW1zaG(yzejjTSAgRcH3Ai5I(Xggpwgrss7bP8CZZse07ynY9JnmESmIKKwar4UL0i3po8JLrKK0cic3TKgsv(M8hd(JndIhBy842HNuR7TIk9uSl9yWpESjV6XGXaCrVtYaUNENK1SamZqJbqPlRillqgGaUnbxNbWVjLQ0o8KAUwTNXnVekI9SIY(XxoES5hBy8yqFmiFm0xBHcszRDRLRjuT8M)ydJhd91wOGu2A3A56nF8LhBIG4XGXaCrVtYau7zCZlHIypROSznla0ZqJb4IENKbWJxszlJujiLNKNcIbqPlRillqwZcWKm0yau6YkYYcKbiGBtW1zaYiss6nVoYY3ENuJC)ydJhdYh3UIYwV51rw(27KAkDzfzzaUO3jzaEqkp38Seb9oM1SaabdngaLUSISSazac42eCDgq8OqPCpre8XxoESjzaUO3jzacic3TeRzndqAZLhtqodnwa1YqJbqPlRillqgqqxHqma(nPuL2HNuZ12n4MuH3dS6XxoEm6FSHXJBxrzRTBWnPsOi2ZkkBnLUSISpo8J53KsvAhEsnxB3GBsfEpWQhF54XMzaUO3jzabD46YkIbe0HL0RigGLxeoVDzfXAwaMzOXaO0LvKLfidqa3MGRZaKrKK0BEDKLV9oP2or5JnmESmIKKEZRJS8T3j1qQY3K)yWFmiEC4hhpkuk3tebF8LJhB(XggpwmJYorPMqfjq6DYcNYMsbPHuLVj)XG)4AV6XHFSmIKKEZRJS8T3j1qQY3K)yWFCTGGb4IENKbS51rw(27KSMfa6zOXaO0LvKLfidqa3MGRZa43KsvAhEsnxB3GBsfEpWQhd(XJr)Jd)yqFmiFC7kkBTaIWDlPP0LvK9XggpwmJYorPwar4UL0qQY3K)4lp(uyFCDp28JbJb4IENKbqOIei9ozHtztPGynlatYqJbqPlRillqgGaUnbxNbe0HRlRiTLxeoVDzf94WpwgrssB3GBsLBe49WjnKCrZaCrVtYaSBWnPcVhyfRzbacgAmakDzfzzbYaeWTj46mGGoCDzfPT8IW5TlROhh(XG(yq(42vu2AbeH7wstPlRi7JnmESygLDIsTaIWDlPHuLVj)XxE8PW(46ES5hdgdWf9ojdWUb3Kk8EGvSMfW1YqJbqPlRillqgGaUnbxNbiJijPTBWnPYnc8E4KgsUOFC4hd6Jb5JBxrzRjurcKENSWPSPuqAkDzfzFSHXJfZOStuQjurcKENSWPSPuqAiv5BYF8LhFkSpgmgGl6Dsgqtv3khYlbjODfnRzbyIm0yau6YkYYcKbiGBtW1zaG(yq(42vu2AbeH7wstPlRi7JnmESygLDIsTaIWDlPHuLVj)XxE8PW(46ES5hd2Jd)yqFmiFC7kkBnHksG07KfoLnLcstPlRi7JnmESmIKKwar4UL0i3po8JLrKK0cic3TKM3Ua1pg8hx7vp2W4XIzu2jk1eQibsVtw4u2ukinKQ8n5p(YJpf2hx3Jn)yWyaUO3jzanvDRCiVeKG2v0SM1mGtkjO3dKZqJfqTm0yau6YkYYcKbe0vieda0hdYh3UIYwh7vveSmsLiO3XAkDzfzFSHXJBhEsToMCvhRVf9JVC8yZx94Wpg0hlJijP9GuEU5zjc6DS2or5JnmESmIKKwar4UL02jkFmypgmgGl6DsgqqhUUSIyabDyj9kIbGUd6WAwaMzOXaO0LvKLfidqa3MGRZaIhfkL7jIGp(YXJbbdWf9ojdq4kvXf9ozrT8MbOwExsVIyasBU8ycYznla0ZqJbqPlRillqgGaUnbxNba6Jb5JH(AluqkBTBTCnHQL38hBy8yOV2cfKYw7wlxV5JV8yZx9yWEC4hd6JJhfkL7jIGpg8JhF1JnmEC8OqPCpre8XhpU2hh(XIzu2jk1Yk3sLrQekcVxbPHuLVj)XxE8PW(yWyaUO3jzaroQPYivCEmXznlatYqJbqPlRillqgGaUnbxNbepkuk3tebFm4hp28JnmEmOpoEuOuUNic(4JhJ(hh(XG(yXmk7eL6yVQIGLrQeb9owdPkFt(JV84tH9X19yZp2W4XbD46YksJUd68yWEmymax07KmazLBPYivcfH3RGynlaqWqJbqPlRillqgGaUnbxNbepkuk3tebFm4hp28JnmEC8OqPCpre8XGF8y0)4WpwmJYorPww5wQmsLqr49kinKQ8n5p(YJpf2hx3Jn)ydJhd6JJhfkL7jIGp(4XM8XHFmOpwmJYorPww5wQmsLqr49kinKQ8n5p(YJpf2hx3Jn)ydJhh0HRlRin6oOZJb7XGXaCrVtYacfXEwrzZAwaxldngGl6DsgqSxvrWYivIGEhZaO0LvKLfiRzbyIm0yau6YkYYcKbiGBtW1zaXJcLY9erWhd(XJn)ydJhhpkuk3tebFm4hpg9po8JfZOStuQLvULkJujueEVcsdPkFt(JV84tH9X19yZp2W4XG(44rHs5EIi4JpESjFC4hlMrzNOulRClvgPsOi8EfKgsv(M8hF5XNc7JR7XMFC4hlMrzNOuhkI9SIYwdPkFt(JV84tH9X19yZpo8Jd6W1LvKgDh05XGXaCrVtYaetYjb07DswZc4AWqJbqPlRillqgGaUnbxNb0UIYwh7vveSmsLiO3XAkDzfzFC4hd6JBhEsToMCvhRVf9Jb)4XMV6Xggpwgrss7bP8CZZse07ynY9JnmESmIKKwar4UL0i3pgShh(XG(yzejjTDdUjvUrG3dN0i3p2W4XYissAbeH7wsZBxG6hd(JR9QhdgdWf9ojdq4kvXf9ozrT8MbOwExsVIyasBU8ycYznlatagAmakDzfzzbYaeWTj46maXmk7eLAbeH7wcw4nCrnPfXo8K4fjOl6Dsx94lhpUwTjcIhh(XG(44rHs5EIi4Jb)4XMFSHXJJhfkL7jIGpg8JhJ(hh(XIzu2jk1Yk3sLrQekcVxbPHuLVj)XxE8PW(46ES5hBy844rHs5EIi4JpESjFC4hlMrzNOulRClvgPsOi8EfKgsv(M8hF5XNc7JR7XMFC4hlMrzNOuhkI9SIYwdPkFt(JV84tH9X19yZpo8JfZOStuQftYjb07DsnKQ8n5p(YJpf2hx3Jn)4WpoOdxxwrA0DqNhdgdWf9ojdqar4ULGfEdxutSMfqTxXqJbqPlRillqgGl6DsgGWvQIl6DYIA5ndqT8UKEfXaK2C5XeKZAwa1wldngGl6DsgGaIWDlbl8gUOMyau6YkYYcK1SaQ1mdngaLUSISSazac42eCDgaOp2sYissAcvKaP3jlCkBkfKg5(Xggpg0h3UIYwh7vveSmsLiO3XAkDzfzFC4hd6JBhEsToMCvhRVf9JVC8yZx9ydJhlJijP9GuEU5zjc6DS2or5JnmESmIKKwar4UL02jkFmypgShBy8yq(42vu2AcvKaP3jlCkBkfKMsxwr2hBy8yq(42vu26yVQIGLrQeb9owtPlRi7Jb7XHFC8OqPCpre8XGF8ytYaCrVtYaCOWtQ0deszZAwZAgGJ0XdKbamkUlGoRznJb]] )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        package = "Retribution",
    } )
end
