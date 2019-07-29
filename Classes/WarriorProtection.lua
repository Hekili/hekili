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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 90 end,
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
            cooldown = 1,
            gcd = "off",

            spend = function () return ( buff.vengeance_ignore_pain.up and 0.67 or 1 ) * 40 end,
            spendType = "rage",

            startsCombat = false,
            texture = 1377132,

            toggle = "defensives",

            -- ready = function () return max( buff.ignore_pain.remains, action.ignore_pain.lastCast + 1 - query_time ) end,
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
            cooldown = function () return talent.bolster.enabled and 120 or 180 end,
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

            usable = function ()
                if settings.free_revenge and action.revenge.cost ~= 0 then return false, "free_revenge is checked and revenge is not free" end
                return true
            end,

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

            readyTime = function () return buff.shield_block.remains end,
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

        potion = "superior_battle_potion_of_strength",

        package = "Protection Warrior",
    } )


    spec:RegisterSetting( "free_revenge", true, {
        name = "Use Free |T132353:0|t Revenge Only",
        desc = "If checked, the Revenge ability will only be recommended when it costs 0 Rage to use.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Protection Warrior", 20190729, [[dCKmIaqivLkpcGSjuk(ekLIrbiofaAvOK0RuvmluQULKQSlL8lQKHHsCma1YOs5zsQQPPQuUMKkBdLu(gkPACQkvDoQu16qjH5bK6EQQ2ha1bPsLwOQKhIsjMikLsxeLsYhrPu5KOKOvcuZeqk3eLsv7uszOuPILIsj1tPQPkj(kGuzVI(RsnybhgAXi6XOAYsCzsBgfFMkgTqDAPwnGu1RvvYSjCBe2TIFRYWvflhPNt00PCDHSDjPVdeJhqY5bG1dKmFvP2pOtGZkPVGMM1CJfGDplSUBUFXclaZA1LEdapA6Fq(xOJM(bj007o0ZuU13adaDiL2hn9piaehwYkPxEruUM(yZEKScxUCAloICXpcxYMisGwFdNImMlztWDLEYOwySYjjtFbnnR5gla7EwyD3C)IfwaM1(gRLE5JYZASE9tFCxk6KKPVOsE6bem4o0ZuU13adaDiL2hfcgqWqSzpswHlxoTfhrU4hHlztejqRVHtrgZLSj4qWacgahjaam4M7zhgCJfGDpmupyGfwyfaxhememGGb2smooQecgqWq9Gb3TuGb2(2Ah06BGbX50CyWoyyuqGbFtWwGb31DaAliyabd1dgyBvbcayWO98LAsyaikqX1hdgy7O34W2ibimWCuyWDRIgsxqWacgQhma0ANythyWh3QOadVeh)lyaNcmWkDMJQWG7G9adfKaDuyOhd)sHbGGtbgkndJs1XA0uy4jgaYMJcxeOtZHHcsGokaxqWacgQhmWwRexvfgONHwFdkGHij6OWWXadanuAWG3WPSs)d9yAHMEabdUd9mLB9nWaqhsP9rHGbemeB2JKv4YLtBXrKl(r4s2erc06B4uKXCjBcoemGGbWrcaadU5E2Hb3yby3dd1dgyHfwbW1bbdbdiyGTeJJJkHGbemupyWDlfyGTVT2bT(gyqConhgSdggfeyW3eSfyWDDhG2ccgqWq9Gb2wvGaagmApFPMegaIcuC9XGb2o6noSnsacdmhfgC3QOH0femGGH6bdaT2j20bg8XTkkWWlXX)cgWPadSsN5Okm4oypWqbjqhfg6XWVuyai4uGHsZWOuDSgnfgEIbGS5OWfb60CyOGeOJcWfemGGH6bdS1kXvvHb6zO13GcyisIokmCmWaqdLgm4nCkliyiyabdSvaLYJmTadKkZrvyGFeKObdKQtpYfm4UCU(ysyyUPEXiLGjsadi36BKWWncaSGGbemGCRVrUEOk)iir7NrGYVGGbemGCRVrUEOk)iir7ZVlM7kqWacgqU13ixpuLFeKO953fg5qOJHwFdemGGb)GpY4ZGbk2fyGmIHrlWG0qtcdKkZrvyGFeKObdKQtpsyaNcm8q169CM1Jdm0syOCJUGGrU13ixpuLFeKO953fjAMq3Y4lYGGrU13ixpuLFeKO953vKu3TPeSpiH(JGsgJuuUzUX2hZ(5arPqWi36BKRhQYpcs0(87Iqjoka2hZweX7YUqvKqcbJCRVrUEOk)iir7ZVlNiKwAC2hZgbLsplgcg5wFJC9qv(rqI2NFxpN13abdbdiyGTcOuEKPfyqRQuaadwtOWGfRWaYTJcdTegWQylqsHUGGrU13i)7XukxFmiyKB9nYp)UEIiiubemYT(g5NFxrsD3MsizVz(53jkhiZcRIgsxuLa7rc6FhE59BYigMfwfnKUIEGGrU13i)87IuCxzZerbaemYT(g5NFxKkvQ0V6Xbcg5wFJ8ZVlKYXr32rP6yqWi36BKF(DjANytUb6Jkoe6yqWi36BKF(DX0uLuCxbcg5wFJ8ZVlC4Q0OOyZrHacg5wFJ8ZVRNZ6ByVz(jJyywyv0q6k659BRj0TD7sRG2T6GGbemejvyGv6mhvHb3b7bgSdgWQxxGbk6OWahFE6Xbcg5wFJ8ZVR2zoQUFWEyVz(POJUkktZBd0Uv3h3yHvnuOJTiVJOhND1R56shKuOfwLFNOCGmRIsCuu0GQhNTm(ISfvXcaGGrU13i)87cKJkkv1E2uvEdoCL9M5NFNOCGmlSkAiDrvcShjO)Ddcg5wFJ8ZVlA)8i0DpB5dYviyKB9nYp)UiuIJcG9XSfr8USlufjKqWi36BKF(DXVHRJrrtlBgbsOS3m)KrmmlSkAiDvoqgiyabdi36BKF(DjqPTLgof2BMF(DIYbYSWPjW9XSlkAXlQsG9ib9VBqWi36BKF(DHvrdPqWi36BKF(DXrHyJCRVzlAPX(Ge6prBTdA9nS3m)9WpIEC2fKaD0DDsaZcemYT(g5NFx0OzJCRVzlAPX(Ge6pEk7nZV8rfITHuh1KlloAkkDZf4dG)RpemYT(g5NFxCui2i36B2IwASpiH(lniyiyKB9nYfrBTdA9n)Y4wfLnP44FXEZ8dKVZqHo2I8estPlDqsHwE)(7iJyywcuABPHtzf9aq2aeEmsDu5MHICRVbfag413)(Dp8JOhN9tmaKnhf76KaMLfWSASIclErGafaHGrU13ixeT1oO13853v7mhv3pypS3m)aHmIHzjJBvu2KIJ)1QCGmVF3d)i6XztGonFxNeWSSaMvJvuyXlceOaiBiJyywTZCuD)G9SkhidBacfD01d3aS7D797yffw86HBGM1ybGqWi36BKlI2Ah06B(87QOehffnO6XzlJViJ9M5higsDuBbsBX9amlVFJCRRQBDuIwLagyaYgGaKE4hrpo7csGo6UojGzzbCDSASIclErGa173XkkS41d3aD9zbGVFdKVZqHo2I8oIEC2vVMRlDqsHwE)MIo6IabQ6rrhf0FJfacqiyKB9nYfrBTdA9nF(DjqPTLgof2BM)yffw86HBGU(SabJCRVrUiARDqRV5ZVlzCRIYgeuiyVz(7HFe94Slib6O76KaowrHf)(DSIclE9Wnq7glqWqWi36BKl80FloAkkDZf4demYT(g5cp9ZVlcL4OayFmBreVl7cvrcj7nZpzedZcRIgsxLdKbcg5wFJCHN(53vrjokkAq1JZwgFrg7nZVHcDSf5De94SREnxx6GKcTabJCRVrUWt)87cNMa3hZUOOfZEZ8tgXWSeO02sdNYk6bcg5wFJCHN(53vHIo3SPhsHGrU13ix4PF(Dr1Q64OqWi36BKl80p)UIK6UnLG9bj0Fh6noY9dTjqXMIok7nZpzedZcRIgsxLdK59B(DIYbYSS4OPO0nxGplQsG9ib8)3GGrU13ix4PF(DrXQOJsHGrU13ix4PF(DjJBvu2KIJ)f7nZp)or5azwY4wfLTuGelQIfaWgYigMLmUvrztko(xRYbYabJCRVrUWt)87sg3QOSLcKacgcg5wFJCjTFloAkkDZf4d7nZV8rfITHuh1KlloAkkDZf4ZVBSXqHo2kAK298GKcDZCuUU0bjfAHnKrmmlSkAiDf9abJCRVrUK2NFxY4wfLnP44FXEZ8ZVtuoqMLmUvrzlfiXIQybaSHmIHzjJBvu2KIJ)1QCGmqWi36BKlP953LmUvrzlfib7nZpzedZsg3QOSjfh)Rv0demYT(g5sAF(DzXrtrPBUaFyVz(bIHcDSv0iT75bjf6M5OCDPdsk0cBiJyywyv0q6k6bGqWi36BKlP953vrjokkAq1JZwgFrg7nZVHcDSf5De94SREnxx6GKcTabJCRVrUK2NFx40e4(y2ffTy2BMFYigMLaL2wA4uwrpqWi36BKlP953LmUvrzlfibemYT(g5sAF(Dfj1DBkb7dsO)OmUkoQCtrqD0n)OOGDdPoQTBM)IsgXWSOiOo6MFuuSlkzedZsAi)RFwGGrU13ixs7ZVRiPUBtjyFqc9hLXvXrLBkcQJU5hffS3m)fLmIHzrrqD0n)OOyxuYigML0q(xaM1zdq43jkhiZcRIgsxuLa7rc66E)MmIHzHvrdPROhacbJCRVrUK2NFxfk6CZMEifcg5wFJCjTp)US4OPO0nxGpqWi36BKlP953fvRQJJcbJCRVrUK2NFxrsD3MsW(Ge6Vd9gh5(H2eOytrhL9M5NmIHzHvrdPRYbY8(n)or5azwY4wfLTuGelQsG9ib8)3GGrU13ixs7ZVlkwfDukemYT(g5sAF(Dv0QO0qttFvLk7BYAUXcWUNfw3n3waZAULEqq60JJm9SsINJAAbgQdgqU13adIwAYfeC6Xil(OP33erc06ByluKXsVOLMmRK(IYGrclRK1aoRKEKB9nPVhtPC9XsVoiPql5R0YAULvspYT(M0)erqOI0Rdsk0s(kTSw9ZkPxhKuOL8v6502uAJPNFNOCGmlSkAiDrvcShjma6FyWHxGH3VHbYigMfwfnKUIEspYT(M0hj1DBkHmTS23YkPh5wFt6jf3v2mruaKEDqsHwYxPL1QlRKEKB9nPNuPsL(vpoPxhKuOL8vAznwlRKEKB9nPhPCC0TDuQow61bjfAjFLwwJ1ZkPh5wFt6fTtSj3a9rfhcDS0Rdsk0s(kTS23NvspYT(M0Z0uLuCxj96GKcTKVslR5(Ss6rU13KEC4Q0OOyZrHi96GKcTKVslRbmlzL0Rdsk0s(k9CABkTX0tgXWSWQOH0v0dm8(nmynHUTBxAfganm4wDPh5wFt6FoRVjTSgWaNvsVoiPql5R0ZPTP0gtpfD0vrzAEBWaOHb3Qdg(adUXcmWQWGHcDSf5De94SREnxx6GKcTadSkmWVtuoqMvrjokkAq1JZwgFr2IQybaPh5wFt6BN5O6(b7jTSgWULvsVoiPql5R0ZPTP0gtp)or5azwyv0q6IQeypsya0)WGBPh5wFt6b5OIsvTNnvL3GdxtlRbC9ZkPh5wFt6P9ZJq39SLpixtVoiPql5R0YAa)TSs6rU13KEcL4OayFmBreVl7cvrcz61bjfAjFLwwd46YkPxhKuOL8v6502uAJPNmIHzHvrdPRYbYKEKB9nPNFdxhJIMw2mcKqtlRbmRLvspYT(M0JvrdPPxhKuOL8vAznGz9Ss61bjfAjFLEoTnL2y67HFe94Slib6O76KWaGHbwspYT(M0ZrHyJCRVzlAPLErlT9GeA6jARDqRVjTSgWFFwj96GKcTKVspN2MsBm9Yhvi2gsDutUS4OPO0nxGpWaG)HH6NEKB9nPNgnBKB9nBrlT0lAPThKqtpEAAznGDFwj96GKcTKVspYT(M0ZrHyJCRVzlAPLErlT9GeA6LwAPL(hQYpcs0YkznGZkPh5wFt6jrZe6wgFrw61bjfAjFLwwZTSs61bjfAjFL(bj00JGsgJuuUzUX2hZ(5arPPh5wFt6rqjJrkk3m3y7Jz)CGO00YA1pRKEKB9nPNqjoka2hZweX7YUqvKqMEDqsHwYxPL1(wwj9i36BsVteslno7JzJGsPNfNEDqsHwYxPL1QlRKEKB9nP)5S(M0Rdsk0s(kT0sprBTdA9nzLSgWzL0Rdsk0s(k9CABkTX0dey47Gbdf6ylYtinLU0bjfAbgE)gg(oyGmIHzjqPTLgoLv0dmaqyGnWaqGbEmsDu5MHICRVbfWaGHbGxFpm8(nm0d)i6Xz)edazZrXUojmayyGLfWWaRcdXkkS4fbcuWaatpYT(M0lJBvu2KIJ)vAzn3YkPxhKuOL8v6502uAJPhiWazedZsg3QOSjfh)Rv5azGH3VHHE4hrpoBc0P576KWaGHbwwaddSkmeROWIxeiqbdaegydmqgXWSAN5O6(b7zvoqgyGnWaqGbk6ORhUbdaggCVBWW73WqSIclE9Wnya0WaRXcmaW0JCRVj9TZCuD)G9KwwR(zL0Rdsk0s(k9CABkTX0deyWqQJAlqAlUhGzbgE)ggqU1v1TokrRsyaWWaWWaaHb2adabgacm0d)i6Xzxqc0r31jHbaddSSaUoyGvHHyffw8Iabky49ByiwrHfVE4gmaAyO(SadaegE)ggacm8DWGHcDSf5De94SREnxx6GKcTadVFddu0rxeiqbd1dgOOJcdGgg(glWaaHbaMEKB9nPVOehffnO6XzlJVilTS23YkPxhKuOL8v6502uAJPpwrHfVE4gmaAyO(SKEKB9nPxGsBlnCkPL1QlRKEDqsHwYxPNtBtPnM(E4hrpo7csGo6UojmayyiwrHfddVFddXkkS41d3GbqddUXs6rU13KEzCRIYgeuislT0lTSswd4Ss61bjfAjFLEoTnL2y6LpQqSnK6OMCzXrtrPBUaFGHFyWnyGnWGHcDSv0iT75bjf6M5OCDPdsk0cmWgyGmIHzHvrdPRON0JCRVj9wC0uu6MlWN0YAULvsVoiPql5R0ZPTP0gtp)or5azwY4wfLTuGelQIfaadSbgiJyywY4wfLnP44FTkhit6rU13KEzCRIYMuC8VslRv)Ss61bjfAjFLEoTnL2y6jJyywY4wfLnP44FTIEspYT(M0lJBvu2sbsKww7BzL0Rdsk0s(k9CABkTX0deyWqHo2kAK298GKcDZCuUU0bjfAbgydmqgXWSWQOH0v0dmaW0JCRVj9wC0uu6MlWN0YA1LvsVoiPql5R0ZPTP0gtVHcDSf5De94SREnxx6GKcTKEKB9nPVOehffnO6XzlJVilTSgRLvsVoiPql5R0ZPTP0gtpzedZsGsBlnCkRON0JCRVj940e4(y2ffT40YASEwj9i36BsVmUvrzlfir61bjfAjFLww77ZkPxhKuOL8v6rU13KEugxfhvUPiOo6MFuuKEoTnL2y6lkzedZIIG6OB(rrXUOKrmmlPH8VGHFyGL0piHMEugxfhvUPiOo6MFuuKwwZ9zL0Rdsk0s(k9i36BspkJRIJk3ueuhDZpkkspN2MsBm9fLmIHzrrqD0n)OOyxuYigML0q(xWaGHbwhgydmaeyGFNOCGmlSkAiDrvcShjmaAyOoy49ByGmIHzHvrdPROhyaGPFqcn9OmUkoQCtrqD0n)OOiTSgWSKvspYT(M0xOOZnB6H00Rdsk0s(kTSgWaNvspYT(M0BXrtrPBUaFsVoiPql5R0YAa7wwj9i36BspvRQJJMEDqsHwYxPL1aU(zL0Rdsk0s(k9i36BsVd9gh5(H2eOytrhn9CABkTX0tgXWSWQOH0v5azGH3VHb(DIYbYSKXTkkBPajwuLa7rcda(hg(w6hKqtVd9gh5(H2eOytrhnTSgWFlRKEKB9nPNIvrhLMEDqsHwYxPL1aUUSs6rU13K(IwfLgAA61bjfAjFLwAPhpnRK1aoRKEKB9nP3IJMIs3Cb(KEDqsHwYxPL1ClRKEDqsHwYxPNtBtPnMEYigMfwfnKUkhit6rU13KEcL4OayFmBreVl7cvrczAzT6NvsVoiPql5R0ZPTP0gtVHcDSf5De94SREnxx6GKcTKEKB9nPVOehffnO6XzlJVilTS23YkPxhKuOL8v6502uAJPNmIHzjqPTLgoLv0t6rU13KECAcCFm7IIwCAzT6YkPh5wFt6lu05Mn9qA61bjfAjFLwwJ1YkPh5wFt6PAvDC00Rdsk0s(kTSgRNvsVoiPql5R0JCRVj9o0BCK7hAtGInfD00ZPTP0gtpzedZcRIgsxLdKbgE)gg43jkhiZYIJMIs3Cb(SOkb2Jega8pm8T0piHMEh6noY9dTjqXMIoAAzTVpRKEKB9nPNIvrhLMEDqsHwYxPL1CFwj96GKcTKVspN2MsBm987eLdKzjJBvu2sbsSOkwaamWgyGmIHzjJBvu2KIJ)1QCGmPh5wFt6LXTkkBsXX)kTSgWSKvspYT(M0lJBvu2sbsKEDqsHwYxPLwAPLwMa]] )


end
