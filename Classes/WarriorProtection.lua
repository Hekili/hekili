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


    spec:RegisterPack( "Protection Warrior", 20190722, [[dyKaIaqivvjpcu0MqL0NOsrmka0PaiRcvIELQkZcvQBba2Ls(fvYWavDmazzGspJkLMMQQ4AuPABsQKVbO04uvL6CakwhQempav3tvzFauhusLAHQcpKkfmrQuOUivkkFKkfPtIkHwjQyMsQi3Kkfv7uszOsQWtPQPkj(QKkQ9k6Vk1GL4WqlgKhJ0KfCzsBgv9zQy0c1PLA1uPqETKQMnHBd0Uv8BvgUQ0Yr55enDkxxiBxs67GkJha68QQQ1dkmFvr7hXjqzL0hqtZAWcpqad8alSWUGhE3H1T)j92)VA6FrA9OJM(bb10xhSZuQ13qk1zKX6JL(x8FXHHSs6LxeJQPp2SxjxWLlN2IJGw0d0LSbJeO13qziV5s2GuxPhkQfgxCsO0hqtZAWcpqad8alSWUGhE3HfwytV8vPznG1TPpUdbDsO0hujn9WKuQd2zk16BiL6mYy9XiCGjPeB2RKl4YLtBXrql6b6s2Grc06BOmK3CjBqkHdmjforI)jfybIBsbw4bcyifaGuGfiUG7Ut4q4atsXneJJJkjCGjPaaKsDhcKIBEBTdA9nKI4CAkPyhPmkCKIVbDdKsDxh1PfHdmjfaGuCJvb(pPySEQxnjPaqfaP6RrkUPSBCCtKaIu4pgPu3vrdzlchyskaaPuNANythsXh3QiqkpehTEsbNaPWfDMJPKsDG9qkbeeDusPhdRxjfaItGucnpVY0XA0us5n(FztrHlq0PPKsabrhfqR0)Yo(wOPhMKsDWotPwFdPuNrgRpgHdmjLyZELCbxUCAlocArpqxYgmsGwFdLH8MlzdsjCGjPWjs8pPalqCtkWcpqadPaaKcSaXfC3DchchyskUHyCCujHdmjfaGuQ7qGuCZBRDqRVHueNttjf7iLrHJu8nOBGuQ76OoTiCGjPaaKIBSkW)jfJ1t9QjjfaQaivFnsXnLDJJBIeqKc)XiL6UkAiBr4atsbaiL6u7eB6qk(4wfbs5H4O1tk4eifUOZCmLuQdShsjGGOJsk9yy9kPaqCcKsO55vMowJMskVX)lBkkCbIonLucii6OaAr4q4atsXndavAKPbsbs5pMsk0decnsbsD6rUiL6Ms1xtskZnaqmYa5JeKcsT(gjPCJ4)fHdmjfKA9nY1ltPhieAF8cuwpHdmjfKA9nY1ltPhieA)(CXFxGWbMKcsT(g56LP0decTFFUWihqDm06BiCGjP4h8vgFgPWWoqkqr88AGuKgAssbs5pMsk0decnsbsD6rsk4eiLxMcaVNz94qkTKuc3OlchKA9nY1ltPhieA)(CbHMj0Tm(ImchKA9nY1ltPhieA)(C9EwFdHdsT(g56LP0decTFFUavWJ9)(43IiAh2bMIGschKA9nY1ltPhieA)(C5eHSqJZ(43imu2zXeoi16BKRxMspqi0(95I)OrsnSryOS20nKIGeoeoWKuCZaqLgzAGu0Qk7FsXAqLuSyLuqQDmsPLKcwfBbcj0fHdsT(g5xpMYO6Rr4GuRVr(7Z1BeiOkiCqQ13i)95ksQ72uqj3n)h9or4GBwyv0q2IPGypsG)5qdpFcfXZVWQOHSv0lHdsT(g5VpxqI7cB(i2)eoi16BK)(CbPmPYQVhhchKA9nYFFUqgfhDBhJPJr4GuRVr(7ZLODIn52nkk4aQJr4GuRVr(7ZfFZuiXDbchKA9nYFFUWHQsJHInffcchKA9nYFFUEpRVH7M)dkINFHvrdzRO3NpnK5O2YAqDB3o0kWH1DchyskrsLu4IoZXusPoWEif7ifS61bsHHokPqX33ECiCqQ13i)95QDMJP7xShUB(pg6ORGY302aoSU)dw45sdf6ylO7a7Xzx9AQU0bHeAGlP3jchCZkOGhdfnm6XzlJViBXum8pHdsT(g5VpxWDmrOQ2ZMPYBWHQC38F07eHdUzHvrdzlMcI9ib(hSeoi16BK)(CX63xHU7zlFrQs4GuRVr(7ZfOcES)3h)wer7WoWueus4GuRVr(7Zf9gQogdnnS5fiOYDZ)bfXZVWQOHSv4GBiCqQ13i)95sGsBlnCcC38F07eHdUzHtdI7JFhu0Ixmfe7rc8pyjCqQ13i)95cRIgYiCqQ13i)95IIcXgPwFZw0sJ7bb1pW2Ah06B4U5)6HEG94Sdii6OB3LagEchKA9nYFFUyrZgPwFZw0sJ7bb1p8uUB(p5RkeBdzoQjxwC0eu2MkWxa)5wchKA9nYFFUOOqSrQ13SfT04Eqq9tAeoeoi16BKlW2Ah06B(KXTkcBiXrRN7M)dG)LHcDSf0jKMYw6Gqcn885FbfXZVeO02sdNWk6fqCfG0yK5OYnpdPwFdkamqR)(5ZEOhypo734)LnffB3Lag(fqCzSIclEbIaiGiCqQ13ixGT1oO1387Zv7mht3VypC38FaekINFjJBve2qIJw)kCWnpF2d9a7XzdIonD7UeWWVaIlJvuyXlqeabexHI45xTZCmD)I9SchCdxbidD01l1amWa7ZNXkkS41l1aEDbpGiCqQ13ixGT1oO1387ZvqbpgkAy0JZwgFrg3n)hanK5O2cU2I7bi4F(ePwxv36OGTkbmqaIRaeG9qpWEC2beeD0T7sad)ci35Yyffw8cebWNpJvuyXRxQbC3cpGE(eG)LHcDSf0DG94SREnvx6Gqcn88jdD0ficGaadDuG)h4beGiCqQ13ixGT1oO1387ZLaL2wA4e4U5)IvuyXRxQbC3cpHdsT(g5cST2bT(MFFUKXTkcB4qHG7M)Rh6b2JZoGGOJUDxc4yffw8ZNXkkS41l1aoSWt4q4GuRVrUWt)S4OjOSnvGVeoi16BKl80FFUavWJ9)(43IiAh2bMIGsUB(pOiE(fwfnKTchCdHdsT(g5cp93NRGcEmu0WOhNTm(ImUB(pdf6ylO7a7Xzx9AQU0bHeAGWbPwFJCHN(7ZfoniUp(DqrlM7M)dkINFjqPTLgoHv0lHdsT(g5cp93NRadDUzZoKr4GuRVrUWt)95IPv1XrjCqQ13ix4P)(Cfj1DBki3dcQFoSBCK7xwdIIndDuUB(pOiE(fwfnKTchCZZN07eHdUzzXrtqzBQaFxmfe7rc4V)q4GuRVrUWt)95IHvrhLr4GuRVrUWt)95sg3QiSHehTEUB(p6DIWb3SKXTkcBPabxmfd)ZvOiE(LmUvrydjoA9RWb3q4GuRVrUWt)95sg3QiSLceKWHWbPwFJCjTploAckBtf4l3n)N8vfITHmh1KlloAckBtf47hSC1qHo2kAK29(IqcDZFmQU0bHeAGRqr88lSkAiBf9s4GuRVrUK2VpxY4wfHnK4O1ZDZ)rVteo4MLmUvrylfi4IPy4FUcfXZVKXTkcBiXrRFfo4gchKA9nYL0(95sg3QiSLceK7M)dkINFjJBve2qIJw)k6LWbPwFJCjTFFUS4OjOSnvGVC38Fa0qHo2kAK29(IqcDZFmQU0bHeAGRqr88lSkAiBf9cichKA9nYL0(95kOGhdfnm6XzlJViJ7M)ZqHo2c6oWEC2vVMQlDqiHgiCqQ13ixs73NlCAqCF87GIwm3n)huep)sGsBlnCcROxchKA9nYL0(95sg3QiSLceKWbPwFJCjTFFUIK6UnfK7bb1pugxfhvUzimo2MEmuWTHmh12n)xqHI45xmeghBtpgk2bfkINFjnKw)h8eoi16BKlP97ZvKu3TPGCpiO(HY4Q4OYndHXX20JHcUB(VGcfXZVyimo2MEmuSdkuep)sAiTEadSCfG07eHdUzHvrdzlMcI9ibU7pFcfXZVWQOHSv0lGiCqQ13ixs73NRadDUzZoKr4GuRVrUK2VpxwC0eu2MkWxchKA9nYL0(95IPv1XrjCqQ13ixs73NRiPUBtb5Eqq9ZHDJJC)YAquSzOJYDZ)bfXZVWQOHSv4GBE(KENiCWnlzCRIWwkqWftbXEKa(7peoi16BKlP97ZfdRIokJWbPwFJCjTFFUcAvuAOPPVQYK9nznyHhiGbEGfEGDblSUTUspCiB6XrMEUi47XmnqkUtki16Bifrln5IWj9yKfFS07BWibA9nUbgYBPx0stMvsFq5XiHLvYAaLvspsT(M03JPmQ(APxhesOH8rAznyZkPhPwFt6FJabvr61bHeAiFKwwZTzL0Rdcj0q(i9uwBkRX0tVteo4MfwfnKTyki2JKua(hP4qdKYZNKcuep)cRIgYwrVPhPwFt6JK6UnfuMww7pzL0JuRVj9qI7cB(i2)PxhesOH8rAzn3ZkPhPwFt6HuMuz13Jt61bHeAiFKwwRUYkPhPwFt6rgfhDBhJPJLEDqiHgYhPL1a2Ss6rQ13KEr7eBYTBuuWbuhl96GqcnKpslR93zL0JuRVj98ntHe3fsVoiKqd5J0YAatwj9i16BspouvAmuSPOqKEDqiHgYhPL1ac(Ss61bHeAiFKEkRnL1y6HI45xyv0q2k6LuE(KumK5O2YAqDB3o0kPaCsbw3tpsT(M0)EwFtAznGakRKEDqiHgYhPNYAtznMEg6ORGY302ifGtkW6oP8JuGfEsHljfdf6ylO7a7Xzx9AQU0bHeAGu4ssHENiCWnRGcEmu0WOhNTm(ISftXW)PhPwFt6BN5y6(f7jTSgqWMvsVoiKqd5J0tzTPSgtp9or4GBwyv0q2IPGypssb4FKcSPhPwFt6H7yIqvTNntL3GdvtlRbKBZkPhPwFt6z97Rq39SLVivtVoiKqd5J0YAa9NSs6rQ13KEqf8y)Vp(TiI2HDGPiOm96GqcnKpslRbK7zL0Rdcj0q(i9uwBkRX0dfXZVWQOHSv4GBspsT(M0tVHQJXqtdBEbcQPL1aQUYkPxhesOH8r6PS2uwJPNENiCWnlCAqCF87GIw8IPGypssb4FKcSPhPwFt6fO02sdNqAznGa2Ss6rQ13KESkAil96GqcnKpslRb0FNvsVoiKqd5J0tzTPSgtFp0dShNDabrhD7UKuamPaF6rQ13KEkkeBKA9nBrlT0lAPTheutpyBTdA9nPL1acyYkPxhesOH8r6PS2uwJPx(QcX2qMJAYLfhnbLTPc8Lua8hP420JuRVj9SOzJuRVzlAPLErlT9GGA6XttlRbl8zL0Rdcj0q(i9i16BspffInsT(MTOLw6fT02dcQPxAPLw6Fzk9aHqlRK1akRKEKA9nPhcntOBz8fzPxhesOH8rAznyZkPhPwFt6FpRVj96GqcnKpslR52Ss6rQ13KEqf8y)Vp(TiI2HDGPiOm96GqcnKpslR9NSs6rQ13KENiKfAC2h)gHHYolo96GqcnKpslR5Ewj9i16Bsp)rJKAyJWqzTPBifbtVoiKqd5J0sl9GT1oO13KvYAaLvsVoiKqd5J0tzTPSgtpajL)IumuOJTGoH0u2shesObs55ts5VifOiE(LaL2wA4ewrVKcGifUskaKuOXiZrLBEgsT(guqkaMuaA93KYZNKsp0dShN9B8)YMIIT7ssbWKc8lGifUKuIvuyXlqeajfaLEKA9nPxg3QiSHehT(0YAWMvsVoiKqd5J0tzTPSgtpajfOiE(LmUvrydjoA9RWb3qkpFsk9qpWEC2GOtt3UljfatkWVaIu4ssjwrHfVaraKuaePWvsbkINF1oZX09l2ZkCWnKcxjfaskm0rxVuJuamPamWskpFskXkkS41l1ifGtk1f8KcGspsT(M03oZX09l2tAzn3MvsVoiKqd5J0tzTPSgtpajfdzoQTGRT4EacEs55tsbPwxv36OGTkjfatkarkaIu4kPaqsbGKsp0dShNDabrhD7UKuamPa)ci3jfUKuIvuyXlqeajLNpjLyffw86LAKcWjf3cpPais55tsbGKYFrkgk0Xwq3b2JZU61uDPdcj0aP88jPWqhDbIaiPaaKcdDusb4KYFGNuaePaO0JuRVj9bf8yOOHrpoBz8fzPL1(twj96GqcnKpspL1MYAm9XkkS41l1ifGtkUf(0JuRVj9cuABPHtiTSM7zL0Rdcj0q(i9uwBkRX03d9a7Xzhqq0r3UljfatkXkkSys55tsjwrHfVEPgPaCsbw4tpsT(M0lJBve2WHcrAPLEPLvYAaLvsVoiKqd5J0tzTPSgtV8vfITHmh1KlloAckBtf4lP8rkWskCLumuOJTIgPDVViKq38hJQlDqiHgifUskqr88lSkAiBf9MEKA9nP3IJMGY2ub(Mwwd2Ss61bHeAiFKEkRnL1y6P3jchCZsg3QiSLceCXum8pPWvsbkINFjJBve2qIJw)kCWnPhPwFt6LXTkcBiXrRpTSMBZkPxhesOH8r6PS2uwJPhkINFjJBve2qIJw)k6n9i16BsVmUvrylfiyAzT)KvsVoiKqd5J0tzTPSgtpajfdf6yROrA37lcj0n)XO6shesObsHRKcuep)cRIgYwrVKcGspsT(M0BXrtqzBQaFtlR5Ewj96GqcnKpspL1MYAm9gk0Xwq3b2JZU61uDPdcj0q6rQ13K(GcEmu0WOhNTm(IS0YA1vwj96GqcnKpspL1MYAm9qr88lbkTT0WjSIEtpsT(M0JtdI7JFhu0ItlRbSzL0JuRVj9Y4wfHTuGGPxhesOH8rAzT)oRKEDqiHgYhPhPwFt6rzCvCu5MHW4yB6Xqr6PS2uwJPpOqr88lgcJJTPhdf7GcfXZVKgsRNu(if4t)GGA6rzCvCu5MHW4yB6XqrAznGjRKEDqiHgYhPhPwFt6rzCvCu5MHW4yB6Xqr6PS2uwJPpOqr88lgcJJTPhdf7GcfXZVKgsRNuamPaSKcxjfask07eHdUzHvrdzlMcI9ijfGtkUtkpFskqr88lSkAiBf9skak9dcQPhLXvXrLBgcJJTPhdfPL1ac(Ss6rQ13K(adDUzZoKLEDqiHgYhPL1acOSs6rQ13KEloAckBtf4B61bHeAiFKwwdiyZkPhPwFt6zAvDC00Rdcj0q(iTSgqUnRKEDqiHgYhPhPwFt6Dy34i3VSgefBg6OPNYAtznMEOiE(fwfnKTchCdP88jPqVteo4MLmUvrylfi4IPGypssbWFKYFs)GGA6Dy34i3VSgefBg6OPL1a6pzL0JuRVj9mSk6OS0Rdcj0q(iTSgqUNvspsT(M0h0QO0qttVoiKqd5J0sl94PzLSgqzL0JuRVj9wC0eu2MkW30Rdcj0q(iTSgSzL0Rdcj0q(i9uwBkRX0dfXZVWQOHSv4GBspsT(M0dQGh7)9XVfr0oSdmfbLPL1CBwj96GqcnKpspL1MYAm9gk0Xwq3b2JZU61uDPdcj0q6rQ13K(GcEmu0WOhNTm(IS0YA)jRKEDqiHgYhPNYAtznMEOiE(LaL2wA4ewrVPhPwFt6XPbX9XVdkAXPL1CpRKEKA9nPpWqNB2SdzPxhesOH8rAzT6kRKEKA9nPNPv1XrtVoiKqd5J0YAaBwj96GqcnKpspsT(M07WUXrUFznik2m0rtpL1MYAm9qr88lSkAiBfo4gs55tsHENiCWnlloAckBtf47IPGypssbWFKYFs)GGA6Dy34i3VSgefBg6OPL1(7Ss6rQ13KEgwfDuw61bHeAiFKwwdyYkPxhesOH8r6PS2uwJPNENiCWnlzCRIWwkqWftXW)KcxjfOiE(LmUvrydjoA9RWb3KEKA9nPxg3QiSHehT(0YAabFwj9i16BsVmUvrylfiy61bHeAiFKwAPLwAzc]] )


end
