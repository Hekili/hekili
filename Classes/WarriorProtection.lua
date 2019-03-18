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
            shared = "player", -- check for anyone's buff on the player.
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


        -- Azerite Powers
        bastion_of_might = {
            id = 287379,
            duration = 20,
            max_stack = 1,
        },

        intimidating_presence = {
            id = 288644,
            duration = 12,
            max_stack = 1,
        },


    } )


    -- model rage expenditure reducing CDs...
    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "rage" then
            if talent.anger_management.enabled and amt >= 10 then
                local secs = floor( amt / 10 )

                cooldown.avatar.expires = cooldown.avatar.expires - secs
                cooldown.last_stand.expires = cooldown.last_stand.expires - secs
                cooldown.shield_wall.expires = cooldown.shield_wall.expires - secs
                cooldown.demoralizing_shout.expires = cooldown.demoralizing_shout.expires - secs
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

            spend = -20,
            spendType = "rage",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 613534,

            handler = function ()
                applyBuff( "avatar" )
                if azerite.bastion_of_might.enabled then
                    applyBuff( "bastion_of_might" )
                    applyBuff( "ignore_pain" )
                end
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

            -- toggle = "defensives", -- should probably be a defensive...

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
            charges = function () return ( level < 116 and equipped.timeless_stratagem ) and 3 or nil end,
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
            gcd = "off",

            spend = function () return ( buff.vengeance_ignore_pain.up and 0.67 or 1 ) * 40 end,
            spendType = "rage",

            startsCombat = false,
            texture = 1377132,

            toggle = "defensives",

            ready = function () return action.ignore_pain.lastCast + 1 - query_time end,
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
                setDistance( 5 )
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
                if azerite.intimidating_presence.enabled then applyDebuff( "target", "intimidating_presence" ) end
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

            debuff = "casting",
            readyTime = state.timeToInterrupt,

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
            cooldown = 16,
            recharge = 16,
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
            charges = function () return ( level < 116 and equipped.ararats_bloodmirror ) and 2 or nil end,
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

            spend = function () return ( buff.kakushans_stormscale_gauntlets.up and 1.2 or 1 ) * -5 end,
            spendType = "rage",

            startsCombat = true,
            texture = 136105,

            handler = function ()
                applyDebuff( "target", "thunder_clap" )
                active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )

                if level < 116 and equipped.thundergods_vigor then
                    setCooldown( "demoralizing_shout", cooldown.demoralizing_shout.remains - ( 3 * active_enemies ) )
                end

                removeBuff( "kakushans_stormscale_gauntlets" )
            end,
        },


        victory_rush = {
            id = 34428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132342,

            buff = "victorious",

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

        potion = "potion_of_bursting_blood",

        package = "Protection Warrior",
    } )


    spec:RegisterPack( "Protection Warrior", 20190317.2037, [[dCewBaqiff5riQSjIOpHicJcaDkayvicELQWSOQQBPkL2Le)Iinma6yaYYauptbzAiQY1uuABQsrFtvQmoer6CQsvRdriZJQkUhc2NcQdIOQwOIQhQkfMiIi6IicLpQOO6KkkkReHMjvvc3KQk1ovGHIiQNk0uPQCvQQe9vQQK2RO)QQgSGddTyGEmktwsxMYMPkFMqJMOoTuRgrO61ikZgPBtWUv63QmCfz5O65uz6KUUcTDvrFNimEffopIK1Ji18vLSFqNaL(YyfvlhamGa9EahcO3vagWHE3qaLrLutwgNqgzOOLXffSmsY8tnM23cd(vKZ7JNXjKu0dRPVm6UroZYOSQtosKuPITkpcwyNGuxlmsrTVLXrpvQRfysZi4yt1z2MGzSIQLdagqGEpGdb07kad4qVdO3Nr3KXYbVBOmk31QTjygRMJLrYbdKm)uJP9TWGFf58(4qIKdgKvDYrIKkvSv5rWc7eK6AHrkQ9Tmo6PsDTadsKCWGFJCMmma078hgagqGEpm8wyayajrdnlmqY(nKiKi5GH3qgxrZbjsoy4TWa5xRWGF3AlIAFlmqpXMbd6bdRjbmeBH3agiFs2VOajsoy4TWajPrrsbdkVxYm1bda0MbZMuyyMZVvKKWbayW74Wa5)evKxY4e)8AQLrYbdKm)uJP9TWGFf58(4qIKdgKvDYrIKkvSv5rWc7eK6AHrkQ9Tmo6PsDTadsKCWGFJCMmma078hgagqGEpm8wyayajrdnlmqY(nKiKi5GH3qgxrZbjsoy4TWa5xRWGF3AlIAFlmqpXMbd6bdRjbmeBH3agiFs2VOajsoy4TWajPrrsbdkVxYm1bda0MbZMuyyMZVvKKWbayW74Wa5)evKxGeHejhmqIndJnQwfganVJBWa7earfganXEDfyG8zmBsDWWE7BLrUG3ifgqM236GHBPKQajImTV1vM4g7earLGhfDKbjImTV1vM4g7ear9bbPE3vHerM236ktCJDcGO(GGuCuuWwf1(wirYbdXfNCYNcdCSRWa4ONNvHbNIQdganVJBWa7earfganXEDWaUvyyIBVD6uTxryODWq9wRajImTV1vM4g7ear9bbPGOQu77KVrfsezAFRRmXn2jaI6dcsDlo5Kp97uuDqIit7BDLjUXobquFqq60P9TqIqIKdgiXMHXgvRcd2tJtkyqBbdguzdgqMECyODWa(eBkcsTcKiY0(whHEvJZSjfsezAFR7bbPtJccgfsezAFR7bbPJo73Qj48V9iao65vWNOI8Y40RxS7O1tITGprf5fUjG96ggyaHerM236Eqq6OZ(TAc(VOGrqKFRO7pXBbK(5OO5F7raC0ZRGprf5L6jXcjImTV19GGuq6D1V3iNuqIit7BDpiif04oJtwVIqIit7BDpiif5mCTVECUTkKiY0(w3dcsPTOS6(K4JvrbBvirKP9TUheK61CdKExfsezAFR7bbP4YmNYr6NHukKiY0(w3dcsNoTV1)2Ja4ONxbFIkYlJtVEPix00I2c2xVFTn)a8SqIKdg8lDgmmZe3JBWajJ9cd6bd4ZRRWahfnyGHtt9kwGerM236EqqAlUh3(tyV(3Ee4OOvQMxZA1pap7dGbKeuKARwaVtOxX)ZRzwXweKAvsGDhTEsSLQjCCK2KUxXVt(g1c3WkPGerM236Eqqk(evKdjImTV19GGugsPFKP9TFA7u)xuWii0AlIAFR)ThHEzNqVI)kkGI2Fw3WacjImTV19GGu(4(rM23(PTt9FrbJaEM)Thb3KrPFf5IM6kQ84wn(NrXPHjmeKiY0(w3dcsziL(rM23(PTt9FrbJGtHeHerM236kcT2IO23sWj3gT(bPhJm)BpcaCMuKARwapQtnEXweKA1xVMjWrpVcfD63P4wlJtaqsaYKrUO5(ECKP9TiDyGkK0xV6LDc9k(ROakA)zDddybysq2qQkxeWzaairKP9TUIqRTiQ9TpiiTf3JB)jSx)BpcGJEEfNCB06hKEmYk1tIvsWrpVslUh3(tyVL6jXkja5OOvMy6WVh4xVaOSHuvUmXu)meGVE1l7e6v8xrbu0(Z6ggWcWKGSHuvUiGZaaaasezAFRRi0AlIAF7dcsRMWXrAt6Ef)o5Bu9V9iaqf5IMwKOv5EbcWxVqM2pTVTMqBUHbcascqa2l7e6v8xrbu0(Z6ggWcWKGSHuvUiGZ41lzdPQCzIP(ziabWRxaCMuKARwaVtOxX)ZRzwXweKA1xV4OOveWz8wokA(H8aeaaasezAFRRi0AlIAF7dcsPOt)of3Q)ThbzdPQCzIP(ziaHerM236kcT2IO23(GGuNCB06xcKs9V9i0l7e6v8xrbu0(Z6gw2qQk)6LSHuvUmXu)amGqIqIit7BDfN(GGuvECRg)ZO4K)Thb3KrPFf5IM6kQ84wn(NrXjcalPIuB1Y460BAcbP2374mRylcsTQKGJEEf8jQiVmobjImTV1vC6dcsDYTrRFq6XiZ)2Ja7oA9Kylo52O1VJIcfUHvsjj4ONxXj3gT(bPhJSs9KyLejTXB1kGCKzFVJ)BHjKPfoUKnmsAJ3QvQg6zBVIFghDYfoUKjj4ONxbFIkYlJtqIit7BDfN(GGuNCB063rrb)BpciPnERwbKJm77D8FlmHmTWXLSHrsB8wTs1qpB7v8Z4OtUWXLmjbh98k4turEzCssWrpVItUnA9dspgzLXjirKP9TUItFqqQkpUvJ)zuCY)2JaavKARwgxNEttii1(EhNzfBrqQvLeC0ZRGprf5LXjaajImTV1vC6dcsRMWXrAt6Ef)o5Bu9V9iOi1wTaENqVI)NxZSITii1QqIit7BDfN(GGuNCB06hKEmY8V9iWUJwpj2ItUnA97OOqHByLusco65vCYTrRFq6XiRupjwirKP9TUItFqqQtUnA97OOaKiY0(wxXPpiiTYrXB)8d5qIit7BDfN(GGuvECRg)ZO4eKiY0(wxXPpiiLBpTv0GerM236ko9bbPC8jkACirKP9TUItFqqA1EIofvdsesezAFRRGN9GGuvECRg)ZO4eKiY0(wxbp7bbPvt44iTjDVIFN8nQ(3EeuKARwaVtOxX)ZRzwXweKAvirKP9TUcE2dcsRCu82p)qoKiY0(wxbp7bbPC7PTIgKiY0(wxbp7bbPC8jkACirKP9TUcE2dcsDYTrRFq6XiZ)2Ja7oA9Kylo52O1VJIcfUHvsjj4ONxXj3gT(bPhJSs9KyHerM236k4zpii1j3gT(DuuiJpnURVnhamGa9Eahcialac0qaLrjq(2ROlJZmHPJRwfgMfgqM23cd02PUcKygPTtDPVmwnpCKQPVCaqPVmImTVnJ9QgNztAgTfbPwnNNAoa40xgrM23MXPrbbJMrBrqQvZ5PMdgk9LrBrqQvZ5zKXB14nMrWrpVc(evKxgNGHxVGb2D06jXwWNOI8c3eWEDWWWWaWaMrKP9TzC0z)wnbxQ5aYl9LrBrqQvZ5zezAFBgf53k6(t8waPFokAzKXB14nMrWrpVc(evKxQNeBgxuWYOi)wr3FI3ci9Zrrl1CWSPVmImTVnJG07QFVroPYOTii1Q58uZbVz6lJit7BZiOXDgNSEfZOTii1Q58uZbVl9LrKP9Tze5mCTVECUTAgTfbPwnNNAoGKM(YiY0(2msBrz19jXhRIc2Qz0weKA1CEQ5G3N(YiY0(2m61CdKExnJ2IGuRMZtnhaeGPVmImTVnJ4YmNYr6NHuAgTfbPwnNNAoaiGsFz0weKA1CEgz8wnEJzeC0ZRGprf5LXjy41lyqrUOPfTfSVE)ABWGFGbGNnJit7BZ40P9TPMdac40xgTfbPwnNNrgVvJ3yg5OOvQMxZAfg8dma8SWWdyayaHbsaguKARwaVtOxX)ZRzwXweKAvyGeGb2D06jXwQMWXrAt6Ef)o5BulCdRKkJit7BZylUh3(tyVPMdaAO0xgrM23Mr8jQipJ2IGuRMZtnhae5L(YOTii1Q58mY4TA8gZyVStOxXFffqr7pRdggggamJit7BZidP0pY0(2pTDAgPTt)lkyzuO1we1(2uZbanB6lJ2IGuRMZZiJ3QXBmJUjJs)kYfn1vu5XTA8pJItWWWeGHHYiY0(2mYh3pY0(2pTDAgPTt)lkyzepl1CaqVz6lJ2IGuRMZZiY0(2mYqk9JmTV9tBNMrA70)IcwgDAQPMXjUXobqutF5aGsFz0weKA1CEQ5aGtFz0weKA1CEQ5GHsFz0weKA1CEQ5aYl9LrKP9TzeevLAFN8nQz0weKA1CEQ5GztFz0weKA1CEQ5G3m9LrKP9TzC60(2mAlcsTAop1uZOqRTiQ9TPVCaqPVmAlcsTAopJmERgVXmcqyyMGbfP2QfWJ6uJxSfbPwfgE9cgMjyaC0ZRqrN(DkU1Y4emaayqsyaGWatg5IM77XrM23IuyyyyaOcjfgE9cg6LDc9k(ROakA)zDWWWWaGfGHbsagKnKQYfbCgWaaYiY0(2m6KBJw)G0JrwQ5aGtFz0weKA1CEgz8wnEJzeC0ZR4KBJw)G0JrwPEsSWGKWa4ONxPf3JB)jS3s9KyHbjHbacdCu0ktmfggggEpWWWRxWaaHbzdPQCzIPWGFGHHaegE9cg6LDc9k(ROakA)zDWWWWaGfGHbsagKnKQYfbCgWaaGbaKrKP9TzSf3JB)jS3uZbdL(YOTii1Q58mY4TA8gZiaHbf5IMwKOv5Ebcqy41lyazA)0(2AcT5GHHHbGGbaadscdaegaim0l7e6v8xrbu0(Z6GHHHbaladdKamiBivLlc4mGHxVGbzdPQCzIPWGFGHHaegaam86fmaqyyMGbfP2QfW7e6v8)8AMvSfbPwfgE9cg4OOveWzadVfg4OObd(bgipaHbaadaiJit7BZy1eoosBs3R43jFJAQ5aYl9LrBrqQvZ5zKXB14nMrzdPQCzIPWGFGHHamJit7BZifD63P4wtnhmB6lJ2IGuRMZZiJ3QXBmJ9YoHEf)vuafT)Soyyyyq2qQkddVEbdYgsv5YetHb)adadygrM23MrNCB06xcKstn1m600xoaO0xgTfbPwnNNrgVvJ3ygDtgL(vKlAQROYJB14FgfNGbcWaWWGKWGIuB1Y460BAcbP2374mRylcsTkmijmao65vWNOI8Y4ugrM23MrvECRg)ZO4uQ5aGtFz0weKA1CEgz8wnEJzKDhTEsSfNCB063rrHc3WkPGbjHbWrpVItUnA9dspgzL6jXcdscdiPnERwbKJm77D8FlmHmTWXLmyyyyajTXB1kvd9STxXpJJo5chxYGbjHbWrpVc(evKxgNYiY0(2m6KBJw)G0JrwQ5GHsFz0weKA1CEgz8wnEJzejTXB1kGCKzFVJ)BHjKPfoUKbddddiPnERwPAONT9k(zC0jx44sgmijmao65vWNOI8Y4emijmao65vCYTrRFq6XiRmoLrKP9Tz0j3gT(Duui1Ca5L(YOTii1Q58mY4TA8gZiaHbfP2QLX1P30ecsTV3XzwXweKAvyqsyaC0ZRGprf5LXjyaazezAFBgv5XTA8pJItPMdMn9LrBrqQvZ5zKXB14nMrfP2QfW7e6v8)8AMvSfbPwnJit7BZy1eoosBs3R43jFJAQ5G3m9LrBrqQvZ5zKXB14nMr2D06jXwCYTrRFhffkCdRKcgKegah98ko52O1pi9yKvQNeBgrM23MrNCB06hKEmYsnh8U0xgrM23MrNCB063rrHmAlcsTAop1Cajn9LrKP9TzSYrXB)8d5z0weKA1CEQ5G3N(YiY0(2mQYJB14FgfNYOTii1Q58uZbaby6lJit7BZi3EAROLrBrqQvZ5PMdacO0xgrM23Mro(efnEgTfbPwnNNAoaiGtFzezAFBgR2t0POAz0weKA1CEQPMr8S0xoaO0xgrM23MrvECRg)ZO4ugTfbPwnNNAoa40xgTfbPwnNNrgVvJ3ygvKARwaVtOxX)ZRzwXweKA1mImTVnJvt44iTjDVIFN8nQPMdgk9LrKP9TzSYrXB)8d5z0weKA1CEQ5aYl9LrKP9TzKBpTv0YOTii1Q58uZbZM(YiY0(2mYXNOOXZOTii1Q58uZbVz6lJ2IGuRMZZiJ3QXBmJS7O1tIT4KBJw)okku4gwjfmijmao65vCYTrRFq6XiRupj2mImTVnJo52O1pi9yKLAo4DPVmImTVnJo52O1VJIcz0weKA1CEQPMAgXrv(4zm2cJuu7BFdo6PPMAMa]] )


end
