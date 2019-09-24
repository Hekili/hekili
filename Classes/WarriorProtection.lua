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

            readyTime = function ()
                if buff.ignore_pain.up and buff.ignore_pain.v1 > 0.3 * stat.attack_power * 3.5 * ( 1 + stat.versatility_atk_mod / 100 ) then
                    return buff.ignore_pain.remains - gcd.max
                end
                return 0
            end,

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
                if action.revenge.cost == 0 then return true end
                if toggle.defensives and buff.ignore_pain.down then return false, "don't spend on revenge if ignore_pain is down" end
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

            debuff = function () return not target.is_boss and "casting" or nil end,

            handler = function ()
                applyDebuff( "target", "shockwave" )
                active_dot.shockwave = max( active_dot.shockwave, active_enemies )
                if not target.is_boss then interrupt() end
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
                removeBuff( "victorious" )
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
        name = "Free |T132353:0|t Revenge",
        desc = "If checked, the Revenge ability will only be recommended when it costs 0 Rage to use.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Protection Warrior", 20190925, [[dKunMaqiaWJaqBIssFsvIYOauofGQvbiQxPk1SOeDlaODjQFrPmmkPogQWYOu1ZOemnvL4AQsABusW3uvsnoaHZHkQwhQOK5biDpvv7JsOdQQKSqvfpKsImrvjqxuvc4JQsqDskj0krLMjGi3uvcYovIgQQezPOIINk0uvcxLsIYxvLOAVs9xLAWcomYIH4XOmzrUmPnd0NPWOvsNwYQrfL61uQmBIUnK2TIFRYWvfhNsIQLd1ZjmDQUofTDuLVdqJxvcDEvLA9OImFuv7h0nh9IoMix7L2BnhCU1CU9FjZbq8QfSG9D0)(r74dXSJm0ooeQ2XxcFUY86gy4LtyCD4o(qFlpk1l6O4mXmTJRU)i4SSzZO8vtKm7qTjkutj51nmmb62efkZwhrmlPBfNgPJjY1EP9wZbNBnNB)xYCaeVAbl0rXJY6LFTf64ALs60iDmPcwhbim8s4ZvMx3adVCcJRdd5cqyy19hbNLnBgLVAIKzhQnrHAkjVUHHjq3MOqzqUaegI6JROikggS)vlHb7TMdohYfYfGWGvALgdva5cqyaaHHVkLGHxOYldYRBGb5zumyWpyyuaHHyHALGHV6Laszixacdaim8cQs6ByWX1yN6cyay6lY0hhgEHX3y8Yeahgapmm8v8iNWzixacdaimaKkJvxhyiUwQmbdFKhZoyGMemyfnMdRWWlr1adjcLmuyOgNStHbSALBwyfvhxKHCbimaGWaNrrpEkmGpN86gscdMcYqHHdegasKWHHOttkd5cqyaaHbRmHcdCgLNogkmamax1bgkhgyNWfWaNHmuGdd3i)ggkqyOCyaWBEzomuJRyqfRWaGLVcdOLxgKx3K74d(alP2racdVe(CL51nWWlNW46WqUaegwD)rWzzZMr5RMiz2HAtuOMsYRByyc0TjkugKlaHHO(4kkIIHb7F1syWER5GZHCHCbimyLwPXqfqUaegaqy4Rsjy4fQ8YG86gyqEgfdg8dggfqyiwOwjy4REjGugYfGWaacdVGQK(ggCCn2PUagaM(Im9XHHxy8ngVmbWHbWdddFfpYjCgYfGWaacdaPYy11bgIRLktWWh5XSdgOjbdwrJ5Wkm8sunWqIqjdfgQXj7uyaRw5Mfwr1XfzixacdaimWzu0JNcd4ZjVUHKWGPGmuy4aHbGejCyi60KYqUaegaqyWktOWaNr5PJHcdadWvDGHYHb2jCbmWzidf4WWnYVHHcegkhga8MxMdd14kguXkmay5RWaA5Lb51nzixixacdVaVOYmDnbdik4HvyGDOiKddiQrnImm8vmM(4cyyUbaxjmkOPegiMx3iGHBKFNHCbimqmVUrKFWk7qri)husc7GCbimqmVUrKFWk7qri)9VnW7sqUaegiMx3iYpyLDOiK)(3gzAGQJtEDdKlaHH4qpI1ZHbmvjyaXeeutWGWjxadik4HvyGDOiKddiQrncyGMem8Gva85CVgdyOeWq6gnd5smVUrKFWk7qri)9VneYDPUfRNPd5smVUrKFWk7qri)9VntHUlxrTCiu9N4KyLWKydEJVpW9ZbOIHCjMx3iYpyLDOiK)(3gQIE4V3h4wAYQ0oHvcva5smVUrKFWk7qri)9VndtcNkA2h4M4KIpFfYLyEDJi)Gv2HIq(7FBpNx3a5c5cqy4f4fvMPRjyq5P4VHbVqvyWxvyGy(HHHsadepQKeIuZqUeZRBe)14kMPpoKlX86gX7FBpMOOQeYLyEDJ49VnX6XSdqINAzb(NuetqWmJeEngzZhRcaoHnupxInYjeqUeZRBeV)Tzk0D5kQWYc8NDNmDaozIh5eoJvuQgbq)nyj(8rmbbZepYjC28bYLyEDJ49Vne5DPnOj(BixI51nI3)2quSqX2vJbKlX86gX7FBeMrJU9dJ1XHCjMx3iE)BtwgRUyZzBMmq1XHCjMx3iE)BdSWkI8UeKlX86gX7FB0WuHJj5MrsjKlX86gX7FBpNx3yzb(JyccMjEKt4S5dF(EHQB)2PsbQ9Vc5cqyWuOWGv0yoScdVevdm4hmq8UkbdyYqHbg98uJbKlX86gX7FBLXCyD)q1yzb(JjdnNuWIvoqT)132Bnq2jPoEg5o0Am28UIPzDiePMaYS7KPdWjNu0dtYIt1ySfRNPNXkL(gYLyEDJ49VnapSmXtRzJvXn0WullWF2DY0b4KjEKt4mwrPAea93EixI51nI3)2W1ZJu31SfpetHCjMx3iE)Bdvrp837dClnzvANWkHkGCjMx3iE)BJDdthhtUM2GscvTSa)rmbbZepYjCoDaowfasNNz3W0XXKRPnOKq1nIjEYyfLQryrR5ZxfcDyA2x1ndBYkePUpWnOKq1mMg7aQfGCbimqmVUr8(3MKe(w40KSSa)z3jthGtMMcL2h4oPKVMXkkvJaO)2d5smVUr8(3gXJCcd5smVUr8(3gJKYnX86MTSeULdHQ)OLxgKx3yzb(xd7qRXyNiuYq3VkSO1qUeZRBeV)THnNnX86MTSeULdHQ)0PwwG)Ihvk3oHnuxK9vZjP4ntspw83cqUeZRBeV)TXiPCtmVUzllHB5qO6VWHCHCjMx3iYOLxgKx38xgZH19dvJLf4FnSdTgJDIqjdD)QaYLyEDJiJwEzqEDZ7FBI1sLPnI8y2zzb(dmaWjPoEg5KcxXzDiePM4ZhaqmbbZss4BHttkB(aCRcm2kHnuXgetmVUHKwKJmqWNFnSdTgJDIqjdD)Qa4qUeZRBez0YldYRBE)BlPOhMKfNQXylwpt3Yc8hyoHnupdy5R1WH185tmV4PBDu0sfwKdGBvGbSAyhAng7eHsg6(vHfToZXRa5vLK(AgLEr(8xvs6R5hMdulynW5ZhyaGtsD8mYDO1yS5DftZ6qisnXNpMm0mk9IaiMmuG(fRboWHCjMx3iYOLxgKx38(3MKe(w40KSSa)xvs6R5hMdulynKlX86grgT8YG86M3)2eRLktBajP0Yc8Vg2HwJXorOKHUFvyXvLK(kF(Rkj918dZbQ9wd5c5smVUrKPt)9vZjP4ntspqUeZRBez603)2qv0d)9(a3stwL2jSsOcllWFetqWmXJCcNthGdKlX86grMo99VTKIEyswCQgJTy9mDllWFNK64zK7qRXyZ7kMM1HqKAcYLyEDJitN((3gnfkTpWDsjF1Yc8hXeemljHVfonPS5dKlX86grMo99VTeMmUzJpcd5smVUrKPtF)BdR80XqTSa)rmbbZyLNogA28HpFaWpddPMtkOoIINk4ZhXeemxgZH19dvt28HpFGHyccMfRLktBe5XSlJvuQgbF(S7KPdWjlwlvM2iYJzxMTsydvSbXeZRBijqTodeahYLyEDJitN((3MPq3LROwoeQ(BGVXqSFWfkj3yYqTSa)rmbbZepYjCoDao85ZUtMoaNSVAojfVzs6jJvuQgHf))cKlX86grMo99VnmXJmumKlX86grMo99VnXAPY0grEm7SSa)z3jthGtwSwQmTfscnJvk9TvrmbbZI1sLPnI8y2LthGdKlX86grMo99VnXAPY0wijuixI51nImD67FB8kMF4V3ytXkKlX86grMo99VTc9rNungBEfZp83qUeZRBez603)2skps4KRqUqUeZRBezH)7RMtsXBMKESSa)fpQuUDcBOUi7RMtsXBMKE(T3Qoj1XZMJWVNhcrQBWdZ0SoeIutwfXeemt8iNWzZhixacdeZRBezH)(3MyTuzAJipMDwwG)S7KPdWjlwlvM2cjHMXkL(2QiMGGzXAPY0grEm7YPdWbYLyEDJil83)2eRLktBHKqTSa)rmbbZI1sLPnI8y2LnFGCjMx3iYc)9VnF1CskEZK0JLf4pWCsQJNnhHFppeIu3GhMPzDiePMSkIjiyM4roHZMpahYLyEDJil83)2sk6HjzXPAm2I1Z0TSa)DsQJNrUdTgJnVRyAwhcrQjixI51nISWF)BJMcL2h4oPKVAzb(JyccMLKW3cNMu28bYLyEDJil83)2eRLktBHKqHCjMx3iYc)9VntHUlxrTCiu9NeR8OrfBmXPdVzhMKwwG)jfXeemJjoD4n7WKCNuetqWSWjMD)wd5smVUrKf(7FBMcDxUIA5qO6pjw5rJk2yIthEZomjTSa)tkIjiygtC6WB2Hj5oPiMGGzHtm7S4xBvGXUtMoaNmXJCcNXkkvJaOVYNpIjiyM4roHZMpahYLyEDJil83)2syY4Mn(imKlX86grw4V)T5RMtsXBMKEGCjMx3iYc)9VnSYthd1Yc8hXeemJvE6yOzZh(8ba)mmKAoPG6ikEQGpFetqWCzmhw3punzZh(8bgIjiywSwQmTrKhZUmwrPAe85ZUtMoaNSyTuzAJipMDz2kHnuXgetmVUHKa16mqaCixI51nISWF)BZuO7Yvulhcv)nW3yi2p4cLKBmzOwwG)iMGGzIh5eoNoah(8z3jthGtwSwQmTfscnJvuQgHf))cKlX86grw4V)THjEKHIHCjMx3iYc)9VnEfZp83BSPyfYLyEDJil83)2k0hDs1yS5vm)WFd5smVUrKf(7FBjLhjCY1oYtXI6MEP9wZbNBnqWbhz7TqhbKWtngIoAfrFoSRjy4vyGyEDdmilHlYqUDuwcx0l6ysbjtP3l6LC0l6iX86MowJRyM(4DuhcrQP(t79s77fDKyEDthFmrrvzh1HqKAQ)0EV0c9IoQdHi1u)PJmC5kUOoMuetqWmJeEngzZhyWQWaaadoHnupxInYjeDKyEDthfRhZoajEA79YV0l6OoeIut9NoYWLR4I6i7oz6aCYepYjCgROuncyaO)WGblbd85ddiMGGzIh5eoB(0rI51nD0uO7Yvur79Yx7fDKyEDthrK3L2GM4V7OoeIut9N27LwHErhjMx30refluSD1y0rDiePM6pT3l)6ErhjMx30rcZOr3(HX64DuhcrQP(t79sGOx0rI51nDuwgRUyZzBMmq1X7OoeIut9N27LCEVOJeZRB6iyHve5DPoQdHi1u)P9Ejhw3l6iX86MosdtfoMKBgjLDuhcrQP(t79so4Ox0rDiePM6pDKHlxXf1retqWmXJCcNnFGb(8HbVq1TF7uPWaqHb7FTJeZRB64Z51nT3l5W(Erh1HqKAQ)0rgUCfxuhXKHMtkyXkhgakmy)RWWByWERHbGmm4KuhpJChAngBExX0SoeIutWaqggy3jthGtoPOhMKfNQXylwptpJvk9DhjMx30XYyoSUFOAAVxYHf6fDuhcrQP(thz4YvCrDKDNmDaozIh5eoJvuQgbma0FyW(osmVUPJaEyzINwZgRIBOHPT3l54l9IosmVUPJ465rQ7A2IhIPDuhcrQP(t79soETx0rI51nDevrp837dClnzvANWkHk6OoeIut9N27LCyf6fDuhcrQP(thz4YvCrDeXeemt8iNW50b4adwfgaayiDEMDdthhtUM2Gscv3iM4jJvuQgbmyryWAyGpFyqfcDyA2x1ndBYkePUpWnOKq1mMg7GbGcdwOJeZRB6i7gMooMCnTbLeQ2EVKJVUx0rI51nDK4roH7OoeIut9N27LCae9IoQdHi1u)PJmC5kUOowd7qRXyNiuYq3VkGblcdw3rI51nDKrs5MyEDZwwcVJYs47Hq1oIwEzqEDt79so48Erh1HqKAQ)0rgUCfxuhfpQuUDcBOUi7RMtsXBMKEGbl(ddwOJeZRB6i2C2eZRB2Ys4DuwcFpeQ2r6027L2BDVOJ6qisn1F6iX86MoYiPCtmVUzllH3rzj89qOAhfE7T3XhSYoueY7f9so6fDKyEDthri3L6wSEMEh1HqKAQ)0EV0(Erh1HqKAQ)0XHq1osCsSsysSbVX3h4(5auXDKyEDthjojwjmj2G347dC)CaQ427LwOx0rI51nDevrp837dClnzvANWkHk6OoeIut9N27LFPx0rI51nD0WKWPIM9bUjoP4Zx7OoeIut9N27LV2l6iX86Mo(CEDth1HqKAQ)0E7DeT8YG86MErVKJErh1HqKAQ)0rgUCfxuhRHDO1yStekzO7xfDKyEDthlJ5W6(HQP9EP99IoQdHi1u)PJmC5kUOocmyaaGbNK64zKtkCfN1HqKAcg4ZhgaayaXeemljHVfonPS5dmaCyWQWaWGb2kHnuXgetmVUHKWGfHboYabmWNpmud7qRXyNiuYq3VkGbG3rI51nDuSwQmTrKhZU27LwOx0rDiePM6pDKHlxXf1rGbdoHnupdy5R1WH1WaF(WaX8INU1rrlvadweg4agaomyvyayWaWGHAyhAng7eHsg6(vbmyryW6mhVcdazyyvjPVMrPxeg4Zhgwvs6R5hMddafgSG1WaWHb(8HbGbdaam4KuhpJChAngBExX0SoeIutWaF(WaMm0mk9IWaacdyYqHbGcdFXAya4WaW7iX86MoMu0dtYIt1ySfRNP3EV8l9IoQdHi1u)PJmC5kUOoUQK0xZpmhgakmybR7iX86MokjHVfonP27LV2l6OoeIut9NoYWLR4I6ynSdTgJDIqjdD)QagSimSQK0xHb(8HHvLK(A(H5WaqHb7TUJeZRB6OyTuzAdijLT3EhfEVOxYrVOJ6qisn1F6idxUIlQJIhvk3oHnuxK9vZjP4ntspWWpmypmyvyWjPoE2Ce(98qisDdEyMM1HqKAcgSkmGyccMjEKt4S5thjMx30rF1CskEZK0t79s77fDuhcrQP(thz4YvCrDeXeemlwlvM2iYJzx28PJeZRB6OyTuzAlKeA79sl0l6OoeIut9NoYWLR4I6iWGbNK64zZr43ZdHi1n4HzAwhcrQjyWQWaIjiyM4roHZMpWaW7iX86Mo6RMtsXBMKEAVx(LErh1HqKAQ)0rgUCfxuhDsQJNrUdTgJnVRyAwhcrQPosmVUPJjf9WKS4ungBX6z6T3lFTx0rDiePM6pDKHlxXf1retqWSKe(w40KYMpDKyEDthPPqP9bUtk5RT3lTc9IosmVUPJI1sLPTqsODuhcrQP(t79YVUx0rDiePM6pDKyEDthjXkpAuXgtC6WB2Hjzhz4YvCrDmPiMGGzmXPdVzhMK7KIyccMfoXSdg(HbR74qOAhjXkpAuXgtC6WB2Hjz79sGOx0rDiePM6pDKyEDthjXkpAuXgtC6WB2Hjzhz4YvCrDmPiMGGzmXPdVzhMK7KIyccMfoXSdgSim81WGvHbGbdS7KPdWjt8iNWzSIs1iGbGcdVcd85ddiMGGzIh5eoB(adaVJdHQDKeR8OrfBmXPdVzhMKT3l58ErhjMx30XeMmUzJpc3rDiePM6pT3l5W6ErhjMx30rF1CskEZK0th1HqKAQ)0EVKdo6fDuhcrQP(thz4YvCrDeXeemJvE6yOzZhyGpFyaaGb)mmKAoPG6ikEQag4ZhgqmbbZLXCyD)q1KnFGb(8HbGbdiMGGzXAPY0grEm7YyfLQrad85ddS7KPdWjlwlvM2iYJzxMTsydvSbXeZRBijmauyW6mqadaVJeZRB6iw5PJH2EVKd77fDuhcrQP(thjMx30rd8ngI9dUqj5gtgAhz4YvCrDeXeemt8iNW50b4ad85ddS7KPdWjlwlvM2cjHMXkkvJagS4pm8LooeQ2rd8ngI9dUqj5gtgA79soSqVOJeZRB6iM4rgkUJ6qisn1FAVxYXx6fDKyEDth5vm)WFVXMI1oQdHi1u)P9EjhV2l6iX86MowOp6KQXyZRy(H)UJ6qisn1FAVxYHvOx0rI51nDmP8iHtU2rDiePM6pT3EhPt7f9so6fDKyEDth9vZjP4ntspDuhcrQP(t79s77fDuhcrQP(thz4YvCrDeXeemt8iNW50b40rI51nDevrp837dClnzvANWkHkAVxAHErh1HqKAQ)0rgUCfxuhDsQJNrUdTgJnVRyAwhcrQPosmVUPJjf9WKS4ungBX6z6T3l)sVOJ6qisn1F6idxUIlQJiMGGzjj8TWPjLnF6iX86MostHs7dCNuYxBVx(AVOJeZRB6yctg3SXhH7OoeIut9N27LwHErh1HqKAQ)0rgUCfxuhrmbbZyLNogA28bg4ZhgaayWpddPMtkOoIINkGb(8HbetqWCzmhw3punzZhyGpFyayWaIjiywSwQmTrKhZUmwrPAeWaF(Wa7oz6aCYI1sLPnI8y2LzRe2qfBqmX86gscdafgSodeWaW7iX86MoIvE6yOT3l)6Erh1HqKAQ)0rI51nD0aFJHy)GlusUXKH2rgUCfxuhrmbbZepYjCoDaoWaF(Wa7oz6aCY(Q5Ku8MjPNmwrPAeWGf)HHV0XHq1oAGVXqSFWfkj3yYqBVxce9IosmVUPJyIhzO4oQdHi1u)P9EjN3l6OoeIut9NoYWLR4I6i7oz6aCYI1sLPTqsOzSsPVHbRcdiMGGzXAPY0grEm7YPdWPJeZRB6OyTuzAJipMDT3l5W6ErhjMx30rXAPY0wij0oQdHi1u)P9EjhC0l6iX86MoYRy(H)EJnfRDuhcrQP(t79soSVx0rI51nDSqF0jvJXMxX8d)Dh1HqKAQ)0EVKdl0l6iX86MoMuEKWjx7OoeIut9N2BV9osM(6H7ySqnLKx3yLWeO3E7Dd]] )


end
