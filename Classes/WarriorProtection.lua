-- WarriorProtection.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 73 )

    spec:RegisterResource( Enum.PowerType.Rage )
    
    -- Talents
    spec:RegisterTalents( {
        into_the_fray = 15760, -- 202603
        punish = 15759, -- 275334
        impending_victory = 15774, -- 202168

        crackling_thunder = 22373, -- 203201
        bounding_stride = 22629, -- 202163
        safeguard = 22409, -- 223657

        best_served_cold = 22378, -- 202560
        unstoppable_force = 22626, -- 275336
        dragon_roar = 23260, -- 118000

        indomitable = 23096, -- 202095
        never_surrender = 23261, -- 202561
        bolster = 22488, -- 280001

        menace = 22384, -- 275338
        rumbling_earth = 22631, -- 275339
        storm_bolt = 22800, -- 107570

        booming_voice = 22395, -- 202743
        vengeance = 22544, -- 202572
        devastator = 22401, -- 236279

        anger_management = 21204, -- 152278
        heavy_repercussions = 22406, -- 203177
        ravager = 23099, -- 228920
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3595, -- 208683
        relentless = 3594, -- 196029
        adaptation = 3593, -- 214027

        oppressor = 845, -- 205800
        disarm = 24, -- 236077
        sword_and_board = 167, -- 199127
        bodyguard = 168, -- 213871
        leave_no_man_behind = 169, -- 199037
        morale_killer = 171, -- 199023
        shield_bash = 173, -- 198912
        thunderstruck = 175, -- 199045
        ready_for_battle = 3063, -- 253900
        warpath = 178, -- 199086
        dragon_charge = 831, -- 206572
        mass_spell_reflection = 833, -- 213915
    } )

    -- Auras
    spec:RegisterAuras( {
        avatar = {
            id = 107574,
            duration = 20,
            max_stack = 1,
        },
        battle_shout = {
            id = 6673,
            duration = 3600,
            max_stack = 1,
        },
        berserker_rage = {
            id = 18499,
            duration = 6,
            type = "",
            max_stack = 1,
        },
        charge = {
            id = 105771,
            duration = 1,
            max_stack = 1,
        },
        deep_wounds = {
            id = 115768,
            duration = 19.5,
            max_stack = 1,
        },
        demoralizing_shout = {
            id = 1160,
            duration = 8,
            max_stack = 1,
        },
        devastator = {
            id = 236279,
        },
        dragon_roar = {
            id = 118000,
            duration = 6,
            max_stack = 1,
        },
        ignore_pain = {
            id = 190456,
            duration = 12,
            max_stack = 1,
        },
        intimidating_shout = {
            id = 5246,
            duration = 12,
            max_stack = 1,
        },
        into_the_fray = {
            id = 202602,
            duration = 3600,
            max_stack = 2,
        },
        kakushans_stormscale_gauntlets = {
            id = 207844,
            duration = 3600,
            max_stack = 1,
        },
        last_stand = {
            id = 12975,
            duration = 15,
            max_stack = 1,
        },
        punish = {
            id = 275335,
            duration = 9,
            max_stack = 1,
        },
        rallying_cry = {
            id = 97463,
            duration = 10,
            max_stack = 1,
        },
        ravager = {
            id = 228920,
            duration = 12,
            max_stack = 1,
        },
        revenge = {
            id = 5302,
            duration = 6,
            max_stack = 1,
        },
        shield_block = {
            id = 132404,
            duration = 7,
            max_stack = 1,
        },
        shield_wall = {
            id = 871,
            duration = 8,
            max_stack = 1,
        },
        shockwave = {
            id = 132168,
            duration = 2,
            max_stack = 1,
        },
        spell_reflection = {
            id = 23920,
            duration = 5,
            max_stack = 1,
        },
        storm_bolt = {
            id = 132169,
            duration = 2,
            max_stack = 1,
        },
        taunt = {
            id = 355,
            duration = 3,
            max_stack = 1,
        },
        thunder_clap = {
            id = 6343,
            duration = 10,
            max_stack = 1,
        },
        vanguard = {
            id = 71,
        },
        vengeance_ignore_pain = {
            id = 202574,
            duration = 15,
            max_stack = 1,
        },
        vengeance_revenge = {
            id = 202573,
            duration = 15,
            max_stack = 1,
        },
    } )


    -- model rage expenditure reducing CDs...
    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "rage" then
            if talent.anger_management.enabled and amt >= 10 then
                local secs = floor( amt / 10 )

                setCooldown( "avatar", cooldown.avatar.remains - secs )
                setCooldown( "last_stand", cooldown.last_stand.remains - secs )
                setCooldown( "shield_wall", cooldown.shield_wall.remains - secs )
                setCooldown( "demoralizing_shout", cooldown.demoralizing_shout.remains - secs )
            end

            if level < 116 and equipped.mannoroths_bloodletting_manacles and amt >= 10 then
                local heal = 0.01 * floor( amt / 10 )
                gain( heal * health.max, "health" )
            end
        end
    end )


    spec:RegisterGear( 'tier20', 147187, 147188, 147189, 147190, 147191, 147192 )
    spec:RegisterGear( 'tier21', 152178, 152179, 152180, 152181, 152182, 152183 )

    spec:RegisterGear( "ararats_bloodmirror", 151822 )
    spec:RegisterGear( "archavons_heavy_hand", 137060 )
    spec:RegisterGear( "ayalas_stone_heart", 137052 )
        spec:RegisterAura( "stone_heart", { id = 225947,
            duration = 10
        } )
    spec:RegisterGear( "ceannar_charger", 137088 )
    spec:RegisterGear( "destiny_driver", 137018 )
    spec:RegisterGear( "kakushans_stormscale_gauntlets", 137108 )
    spec:RegisterGear( "kazzalax_fujiedas_fury", 137053 )
        spec:RegisterAura( "fujiedas_fury", {
            id = 207776,
            duration = 10,
            max_stack = 4 
        } )
    spec:RegisterGear( "mannoroths_bloodletting_manacles", 137107 )
    spec:RegisterGear( "najentuss_vertebrae", 137087 )
    spec:RegisterGear( "soul_of_the_battlelord", 151650 )
    spec:RegisterGear( "the_great_storms_eye", 151823 )
        spec:RegisterAura( "tornados_eye", {
            id = 248142, 
            duration = 6, 
            max_stack = 6
        } )
    spec:RegisterGear( "the_walls_fell", 137054 )
    spec:RegisterGear( "thundergods_vigor", 137089 )
    spec:RegisterGear( "timeless_stratagem", 143728 )
    spec:RegisterGear( "valarjar_berserkers", 151824 )
    spec:RegisterGear( "weight_of_the_earth", 137077 ) -- NYI.

    -- Abilities
    spec:RegisterAbilities( {
        avatar = {
            id = 107574,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 613534,
            
            handler = function ()
                applyBuff( "avatar" )
            end,
        },
        

        battle_shout = {
            id = 6673,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            essential = true, -- new flag, will prioritize using this in precombat APL even in combat.

            startsCombat = false,
            texture = 132333,
            
            nobuff = "battle_shout",

            handler = function ()
                applyBuff( "battle_shout" )
            end,
        },
        

        berserker_rage = {
            id = 18499,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            defensive = true,

            startsCombat = false,
            texture = 136009,
            
            handler = function ()
                applyBuff( "berserker_rage" )
            end,
        },
        

        demoralizing_shout = {
            id = 1160,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = function () return talent.booming_voice.enabled and -40 or 0 end,
            spendType = "rage",

            startsCombat = true,
            texture = 132366,
            
            handler = function ()
                applyDebuff( "target", "demoralizing_shout" )
                active_dot.demoralizing_shout = max( active_dot.demoralizing_shout, active_enemies )
            end,
        },
        

        devastate = {
            id = 20243,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135291,

            notalent = "devastator",
            
            handler = function ()
                applyDebuff( "target", "deep_wounds" )

                if level < 116 and equipped.kakushans_stormscale_gauntlets then
                    applyBuff( "kakushans_stormscale_gauntlets" )
                end
            end,
        },
        

        dragon_roar = {
            id = 118000,
            cast = 0,
            cooldown = 35,
            gcd = "spell",

            spend = -10,
            spendType = "rage",
            
            startsCombat = true,
            texture = 642418,
            
            talent = "dragon_roar",

            handler = function ()
                applyDebuff( "target", "dragon_roar" )
                active_dot.dragon_roar = max( active_dot.dragon_roar, active_enemies )
            end,
        },
        

        heroic_leap = {
            id = 6544,
            cast = 0,
            charges = function () return ( level < 116 and equipped.timeless_stratagem ) and 3 or 1 end,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            recharge = function () return talent.bounding_stride.enabled and 30 or 45 end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236171,
            
            handler = function ()
                setDistance( 5 )
                setCooldown( "taunt", 0 )

                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
            end,
        },
        

        heroic_throw = {
            id = 57755,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132453,
            
            handler = function ()
            end,
        },
        

        ignore_pain = {
            id = 190456,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function () return ( buff.vengeance_ignore_pain.up and 0.67 or 1 ) * 40 end,
            spendType = "rage",
            
            startsCombat = false,
            texture = 1377132,
            
            handler = function ()
                if talent.vengeance.enabled then applyBuff( "vengeance_revenge" ) end
                removeBuff( "vengeance_ignore_pain" )

                applyBuff( "ignore_pain" )
            end,
        },
        

        impending_victory = {
            id = 202168,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = 10,
            spendType = "rage",
            
            startsCombat = true,
            texture = 589768,

            talent = "impending_victory",
            
            handler = function ()
                gain( health.max * 0.2, "health" )
            end,
        },
        

        intercept = {
            id = 198304,
            cast = 0,
            charges = 2,
            cooldown = 15,
            recharge = 15,
            gcd = "spell",

            spend = -15,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132365,
            
            usable = function () return target.distance > 10 end,
            handler = function ()
                applyDebuff( "target", "charge" )
            end,
        },
        

        intimidating_shout = {
            id = 5246,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 132154,
            
            handler = function ()
                applyDebuff( "target", "intimidating_shout" )
                active_dot.intimidating_shout = max( active_dot.intimidating_shout, active_enemies )
            end,
        },
        

        last_stand = {
            id = 12975,
            cast = 0,
            cooldown = function () return talent.bolster.enabled and 120 and 180 end,
            gcd = "spell",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = true,
            texture = 135871,
            
            handler = function ()
                applyBuff( "last_stand" )
            end,
        },
        

        pummel = {
            id = 6552,
            cast = 0,
            cooldown = 15,
            gcd = "off",
            
            startsCombat = true,
            texture = 132938,

            toggle = "interrupts",
            interrupt = true,

            usable = function () return target.casting end,            
            handler = function ()
                interrupt()
            end,
        },
        

        rallying_cry = {
            id = 97462,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 132351,
            
            handler = function ()
                applyBuff( "rallying_cry" )
                gain( 0.15 * health.max, "health" )
                health.max = health.max * 1.15
            end,
        },
        

        ravager = {
            id = 228920,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 970854,

            talent = "ravager",
            
            handler = function ()
                applyBuff( "ravager" )
            end,
        },
        

        revenge = {
            id = 6572,
            cast = 0,
            cooldown = 3,
            hasteCD = true,
            gcd = "spell",
            
            spend = function ()
                if buff.revenge.up then return 0 end
                return buff.vengeance_revenge.up and 20 or 30
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132353,

            handler = function ()
                if talent.vengeance.enabled then applyBuff( "vengeance_ignore_pain" ) end
                
                if buff.revenge.up then removeBuff( "revenge" )
                else removeBuff( "vengeance_revenge" ) end

                applyDebuff( "target", "deep_wounds" )
            end,
        },
        

        shield_block = {
            id = 2565,
            cast = 0,
            charges = function () return ( level < 116 and equipped.ararats_bloodmirror ) and 3 or 2 end,
            cooldown = 18,
            recharge = 18,
            hasteCD = true,
            gcd = "off",

            toggle = "defensives",
            defensive = true,
            
            spend = 30,
            spendType = "rage",
            
            startsCombat = false,
            texture = 132110,
            
            handler = function ()
                applyBuff( "shield_block" )
            end,
        },
        

        shield_slam = {
            id = 23922,
            cast = 0,
            cooldown = 9,
            hasteCD = true,
            gcd = "spell",

            spend = function () 
                return ( buff.kakushans_stormscale_gauntlets.up and 1.2 or 1 ) * ( ( level < 116 and equipped.the_walls_fell ) and -17 or -15 )
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 134951,
            
            handler = function ()
                if talent.heavy_repercussions.enabled and buff.shield_block.up then
                    buff.shield_block.expires = buff.shield_block.expires + 1
                end

                if talent.punish.enabled then applyDebuff( "target", "punish" ) end

                if level < 116 and equipped.the_walls_fell then
                    setCooldown( "shield_wall", cooldown.shield_wall.remains - 4 )
                end

                removeBuff( "kakushans_stormscale_gauntlets" )
            end,
        },
        

        shield_wall = {
            id = 871,
            cast = 0,
            cooldown = 240,
            gcd = "spell",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 132362,
            
            handler = function ()
                applyBuff( "shield_wall" )
            end,
        },
        

        shockwave = {
            id = 46968,
            cast = 0,
            cooldown = function () return ( talent.rumbling_earth.enabled and active_enemies >= 3 ) and 25 or 40 end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236312,
            
            handler = function ()
                applyDebuff( "target", "shockwave" )
                active_dot.shockwave = max( active_dot.shockwave, active_enemies )
            end,
        },
        

        spell_reflection = {
            id = 23920,
            cast = 0,
            charges = function () return ( level < 116 and equipped.ararats_bloodmirror ) and 2 or 1 end,
            cooldown = 25,
            recharge = 25,
            gcd = "off",

            defensive = true,
            
            startsCombat = false,
            texture = 132361,
            
            handler = function ()
                applyBuff( "spell_reflection" )
            end,
        },
        

        storm_bolt = {
            id = 107570,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 613535,

            talent = "storm_bolt",
            
            handler = function ()
                applyDebuff( "target", "storm_bolt" )
            end,
        },
        

        taunt = {
            id = 355,
            cast = 0,
            cooldown = 8,
            gcd = "spell",
            
            startsCombat = true,
            texture = 136080,
            
            handler = function ()
                applyDebuff( "target", "taunt" )
            end,
        },
        

        thunder_clap = {
            id = 6343,
            cast = 0,
            cooldown = function () return haste * ( ( buff.avatar.up and talent.unstoppable_force.enabled ) and 3 or 6 ) end,
            gcd = "spell",

            spend = function () return ( buff.kakushans_stormscale_gauntlets.up and 1.2 or 1 ) * 5 end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 136105,
            
            handler = function ()
                applyDebuff( "target", "thunder_clap" )
                active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )

                if level < 116 and equipped.thundergods_vigor then
                    setCooldown( "demoralizing_shout", cooldown.demoralizing_shout.remains - ( 3 * active_enemies ) )
                end
            end,
        },
        

        victory_rush = {
            id = 34428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132342,

            buff = "victory_rush",
            
            handler = function ()
                removeBuff( "victory_rush" )
                gain( 0.2 * health.max, "health" )
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        package = "Protection Warrior",
    } )


    spec:RegisterPack( "Protection Warrior", 20180807.0009, [[d0ZloaGEkGSjku7sjBtrH9jv52iz2iMVIQxRO0VKQ6BaKNIQDks2lPDlz)uAuuqgMuXVv58uGAOuaYGvy4a50uDkkOoMuQZrbYcLk9yqlwkwUOEokRIIKLbiRJcaptKQPcutwvMUWxPauVcqDzIRRQ6WqBLcG2SQY2Ls(oaMffX0uu08OiLrsbuFgPgTigpfsNKIuDlkextKY9uKvsrnoaQ)QuRTvWk)HHOPaQtBa3bWDa0QtNoZaiaR8WGbjkhecNfPfLxiLOCdO8fcm8RSddymN9lRCqObto8PGvo7(Zqr5jraIza0VpaaaWYHgSrAjEXwWJQpaha9bLVqGHFLraaZz)YgbulXibwZAK8fy4xze4DK3bqXmc24epCHP8MFNeMEPnk)HHOPaQtBa3bWDa0QtNoZODBLZajqnfGsx5pHbvo4eNzhoZoq7aecNfPf74(Sdeg(v2bXzbZo(USDyGLzDIVuoO895er5im8RylqzbEunym1GrqKnl5(dRzRzeg(vSf8oY7aOytylmWS1S1mcd)k2IYdNgd)QjwIlK3UHCWznX)MGjyMwy7Vmcd)kK0R9cWZN7f8O8IE)qkKw2PX61zbKPSJebjrYIcnQ1mcd)k2IYdNgd)kGN6701LLni0lt8VPM)VVflXfYB3qo4SR3bqzCZ)33YPRllBqOxR3bqzSHYiTSabJEgeqZNBOebjrYc(NZsfMwNv6MkrqsKSOqJoFUxWJYl69dPqAzNgRxNfqMkrqsKSOqJAydBnJWWVITO8WPXWVc4P(SexiVnaiHyI)n5f8O8IE)qkKw2PX6LiijswW)CwQWAgHHFfBr5HtJHFfWt9jil2SaRNj(3uIGKizb)ZzPctRZkDtLiijswuOrTMTMry4xXwmVOjY0tOUmsCdKx0BwY9hM4FtbsKkwn3r5f9U15qzjf2qKNXgQ5yS5Zry4TKTucLlSETnSXW7iVdGAHTWaZRSqHEX6LU1mcd)k2I5fnraEQplXfYBZiiL1mcd)k2I5fnraEQVxHKHcOWe)BcMGzAHT)Yim8RqsV2laLMXEbpkVO3pKcPLD6SPowZim8RylMx0eb4P(rYF9K8gsqqwZim8RylMx0eb4P(zPLu0Ij(3uZ)33klTKIww)GMp3qn)FFlNUUSSbHET(bzCgPLfiy0ZGaYWwZim8RylMx0eb4P(pPfYcmeRzRzeg(vSfEcWt9zjUqEBgbPmX)Mqy4TKTucLlSjGmU5)7BXsCH82nKdo76hK1mcd)k2cpb4P(rYF9K8gsqqwZim8Ryl8eGN6)Yi9v78HzRzeg(vSfEcWt9ZslPOfRzeg(vSfEcWt9zjUqEBgbPSMry4xXw4jap1)jTqwGHynBnJWWVInbrczJWWVAtCwysHuYeLhong(vwZim8Ryap1h0pfLqSMry4xXaEQpejKncd)QnXzHjfsjtW7iVdGIznJWWVIb8uFVcjdfqHj(3embZ0cB)Lry4xHKETxaknJdmtlX65SalO0dqwZim8Ryap1p)xBeg(vBIZctkKsMyErtet8VjegElzlLq5cBQT1mcd)kgWt9Z)1gHHF1M4SWKcPKj8et8VjegElzlLq5cRxBL3sYm)knfqDAd4oaUZmxTbeqPPCaWC5fnt5MofOlhYZoMHDGWWVYoiolylRzLJ)rYLvUbwM1jUj2rdYKNDCLDy6qd2igGIxmLtCwWuWkN5fnruWAQ2kyLlf2qKN2v5WShs2rLhirQy1ChLx07wNdLLuydrE2HX2HHSJMJXSJ5ZTdegElzlLq5cZo6zhTTddBhgBhW7iVdGAHTWaZRSqHEXSJE2r6khHHFLYFc1LrIBG8IEZsU)qdnfqkyLJWWVs5SexiVnJGukxkSHipTRgAQ0vWkxkSHipTRYHzpKSJkhMGzAHT)Yim8RqID0ZoAVauA2HX2HxWJYl69dPqAzNoZoMSJokhHHFLY9kKmuafAOPMPcw5im8RuEK8xpjVHeeKYLcBiYt7QHMknfSYLcBiYt7QCy2dj7OYB()(wzPLu0Y6hKDmFUDyi7O5)7B501LLni0R1pi7Wy7iJ0YcemSJE2HbbKDyyLJWWVs5zPLu0IgAQzOGvocd)kL)KwilWquUuydrEAxn0q5p5d)jHcwt1wbRCPWgI80UkhHHFLYHiHSry4xTjoluoXzXUqkr5uE40y4xPHMcifSYry4xPCq)uucr5sHne5PD1qtLUcw5sHne5PDvocd)kLdrczJWWVAtCwOCIZIDHuIYH3rEhaftdn1mvWkxkSHipTRYHzpKSJkhMGzAHT)Yim8RqID0ZoAVauA2HX2rGzAjwpNfybf7ONDaiLJWWVs5EfsgkGcn0uPPGvUuydrEAxLdZEizhvocdVLSLsOCHzht2rBLJWWVs55)AJWWVAtCwOCIZIDHuIYzErten0uZqbRCPWgI80UkhM9qYoQCegElzlLq5cZo6zhTvocd)kLN)Rncd)QnXzHYjol2fsjkhprdnuoOSapQgmuWAQ2kyLJWWVs5nyeezZsU)q5sHne5PD1qdLt5HtJHFLcwt1wbRCPWgI80UkhM9qYoQCycMPf2(lJWWVcj2rp7O9cW2X852HxWJYl69dPqAzNgZo6zhDwazhMYoseKejlk0OkhHHFLYzjUqE7gYbNvdnfqkyLlf2qKN2v5WShs2rL38)9TyjUqE7gYbND9oak7Wy7O5)7B501LLni0R17aOSdJTddzhzKwwGGHD0ZomiGSJ5ZTddzhjcsIKf8pNLkSdtZo6Ss3omLDKiijswuOrTJ5ZTdVGhLx07hsH0YonMD0Zo6SaYomLDKiijswuOrTddBhgw5im8RuUtxxw2GqV0qtLUcw5sHne5PDvom7HKDu5EbpkVO3pKcPLDAm7ONDKiijswW)CwQq5im8RuolXfYBdasiAOPMPcw5sHne5PDvom7HKDu5jcsIKf8pNLkSdtZo6Ss3omLDKiijswuOrvocd)kLtqwSzbwpn0q54jkynvBfSYLcBiYt7QCy2dj7OYry4TKTucLlm7yYoaYom2oA()(wSexiVDd5GZU(bPCeg(vkNL4c5TzeKsdnfqkyLJWWVs5rYF9K8gsqqkxkSHipTRgAQ0vWkhHHFLYFzK(QD(WSYLcBiYt7QHMAMkyLJWWVs5zPLu0IYLcBiYt7QHMknfSYry4xPCwIlK3MrqkLlf2qKN2vdn1muWkhHHFLYFslKfyikxkSHipTRgAOC4DK3bqXuWAQ2kyLJWWVs5ylmWSYLcBiYt7QHgAOHgQc]] )


end
