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


    spec:RegisterPack( "Protection Warrior", 20190811, [[dCKlKaqiiKEeeQnjq6tOcPgfrWPicTkieELIQzreDlfPAxk1VeWWeOogeSmvv5zePmnfjUMQkTnie9nfj14isLZrKW6qfQMhrs3tvzFcehKivTqfLhsKiturs0fvKe(irIQtIkuwjentuH4MkssTtfXqvKILQij5PuAQcYxrfs2RO)QkdwHddwmuEmktwOltAZq6ZOQrRKoTKvtKO8Avv1SP42q1UL63QmCLy5iEoHPt11jQTJk9DurJxrkDEvvSEubZxqTFKoridL2i4Ao5VGrqkcw6qaHnc)(hICkslT(plAAxa2)aVM2gW10onKZvMxxthCuaHuhjTlWpMdIzO0kozctt7Q7lcoEGa8LVkJTzhEarHlBaVUMraupGOWzbslMCzCowNyPncUMt(lyeKIGLoeqyJWVblf)oL0kwuwozQLwAxRyu7elTrvWslIPJPHCUY86A6GJciK6iuKiMowDFrWXdeGV8vzSn7WdikCzd411mcG6befoJIeX0H0lZllC6qAssh)fmcsbDmD6aHG54tjyksksethsPvO5vbfjIPJPthsFmsht1Lx8GxxthMJVy0HF0rRCsh2cxkrhs)0Wr2uKiMoMoDmvQg4h6Wjv)V6c6qc60Y0fNoKYjxZZrlKiDGEe6q65coq2uKiMoMoDWrk(vxB6WUwQjshZmh7F6a6iDWX47JO0X0avthrah4v6OAh(xPdjaDKoIfkQs02lWv6yz9hrXataCGVy0reWbEvIBksethtNoMQu8JRshKZbVUgm0HSa4v64qPdociC6W6qh3PDHCOLrtlIPJPHCUY86A6GJciK6iuKiMowDFrWXdeGV8vzSn7WdikCzd411mcG6befoJIeX0H0lZllC6qAssh)fmcsbDmD6aHG54tjyksksethsPvO5vbfjIPJPthsFmsht1Lx8GxxthMJVy0HF0rRCsh2cxkrhs)0Wr2uKiMoMoDmvQg4h6Wjv)V6c6qc60Y0fNoKYjxZZrlKiDGEe6q65coq2uKiMoMoDWrk(vxB6WUwQjshZmh7F6a6iDWX47JO0X0avthrah4v6OAh(xPdjaDKoIfkQs02lWv6yz9hrXataCGVy0reWbEvIBksethtNoMQu8JRshKZbVUgm0HSa4v64qPdociC6W6qh3uKuKiMoMkMwLj7AKoWu0JO0b7WXaNoWu(QfB6q6zmDXf0rF90xbcoQSHoaMxxlOJRn)SPirmDamVUwSxik7WXa)d1aI)PirmDamVUwSxik7WXaF(xa07IuKiMoaMxxl2leLD4yGp)laiZJRTdEDnfjIPdBdlI1ZPdcur6atgfvJ0HWbxqhyk6ru6GD4yGthykF1c6a6iDSq0PVCUxnpDuc6iETUPibMxxl2leLD4yGp)lag4UrFI1t2PibMxxl2leLD4yGp)lGSqFLR4s2aU(bCqSceq8qV2Fh6B54ujuKaZRRf7fIYoCmWN)faxXpYpVd9zKzv8fjkGlOibMxxl2leLD4yGp)laVmqIf0Vd9bCqjNVsrcmVUwSxik7WXaF(xGLZRRPiPirmDmvmTkt21iDOCvYp0Hx4kD4RkDam)i0rjOdGlugaZOBksG511IVQDLW0fNIeyEDTy(xGfzCC1qrcmVUwm)lGy9y)ZjWvLSq)IkMmk6MbcVA(T8sqruhi8QVlXd7ecksG511I5FbKf6RCfxizH(XUZepo7nWfCGSjkouTqQF8Sy4WyYOOBGl4azlVqrcmVUwm)laM5U4dvM8dfjW86AX8VaykrOK)RMNIeyEDTy(xaGWGwF(riA7uKaZRRfZ)cyk(vx8KYKJ84A7uKaZRRfZ)cGwefZCxKIeyEDTy(xaOzQWjG5XaJHIeyEDTy(xGLZRRLSq)WKrr3axWbYwEjCyVW1NFVyPs9VFPirmDilu6GJX3hrPJPbQMo8JoaUxfPdcWR0bdwwQMNIeyEDTy(xGIVpI(wGQLSq)iaVUJkAXkxQ)978)cgr4GrBFJDhE18pUxX0T2aMrJic2DM4XzVJk(ratXHQ5FI1t23efI)qrcmVUwm)laNhXe5Qv)iQ4AOzQKf6h7ot84S3axWbYMO4q1cP(9hfjW86AX8VaKAzXOVQFIfGPuKaZRRfZ)cGR4h5N3H(mYSk(IefWfuKaZRRfZ)cWUMPTtaxJpudGRswOFyYOOBGl4azhpoBksethaZRRfZ)cyaH)eo0rjl0p2DM4XzVHUWH3H(Ik4RBIIdvlK63FuKaZRRfZ)caCbhiuKaZRRfZ)cWaJ5bmVU(zkHlzd46hE5fp411swOFvZo8Q5Frah413VIGemfjW86AX8Vae5(bmVU(zkHlzd46hCQKf6NyrnMNdeE1fBFvUJk5XmWsq(KgfjW86AX8VamWyEaZRRFMs4s2aU(jCksksG511InE5fp411FfFFe9TavlzH(vn7WRM)fbCGxF)kOibMxxl24Lx8Gxxp)lGyTut8Hzo2)swOFsarDWOTVXoJWvYwBaZOXWHrumzu0Tbe(t4qh3YlsmOsGTceEv8qjaZRRbtqqylDHdxn7WRM)fbCGxF)kKifjW86AXgV8Ih8665FbIk(ratXHQ5FI1t2LSq)KGdeE13Cw(A1ieC4WaZlU6tBfVurqqqIbvcsOA2Hxn)lc4aV((veKG3i8lIyvbJVUXHPnC4vfm(6EH5svAblXWHLaI6GrBFJDhE18pUxX0T2aMrJHdtaEDJdt70jaVk1PeSeLifjW86AXgV8Ih8665FbmGWFch6OKf63QcgFDVWCPkTGPibMxxl24Lx8Gxxp)lGyTut8XjymswOFvZo8Q5Frah413VIGSQGXxdhEvbJVUxyUu)lyksksG511InC6NVk3rL8ygyHIeyEDTydNo)laUIFKFEh6ZiZQ4lsuaxizH(HjJIUbUGdKD84SPibMxxl2WPZ)cev8JaMIdvZ)eRNSlzH(5GrBFJDhE18pUxX0T2aMrJuKaZRRfB405FbGUWH3H(Ik4RswOFyYOOBdi8NWHoULxOibMxxl2WPZ)ceja)1pYbeksG511InC68VaeLR28QKf6hMmk6MOC1Mx3YlHdJO(XZB0Dur1wuCvr4WyYOO7IVpI(wGQ3YluKaZRRfB405FbKf6RCfxYgW1pEY18I3cPWbZJa8QKf6hMmk6g4coq2XJZoCy2DM4XzV9v5oQKhZalBIIdvlcY3uOibMxxl2WPZ)cqaUaVsOibMxxl2WPZ)ciwl1eFyMJ9VKf6h7ot84S3I1snXNWa4BIcXFckMmk6wSwQj(Wmh7)D84SPibMxxl2WPZ)ciwl1eFcdGtrcmVUwSHtN)fGBX8J8ZJilwPibMxxl2WPZ)cu4lAhRM)XTy(r(HIeyEDTydNo)lqu5cchCLIKIeyEDTyl8pFvUJk5XmWIKf6NyrnMNdeE1fBFvUJk5XmWY3Fb1bJ2(wUf(TSayg9HEeMU1gWmAmOyYOOBGl4azlVqrcmVUwSf(8VaI1snXhM5y)lzH(XUZepo7TyTut8jma(MOq8NGIjJIUfRLAIpmZX(FhpoBksG511ITWN)fqSwQj(egaxYc9dtgfDlwl1eFyMJ9)wEHIeyEDTyl85Fb8v5oQKhZalswOFsWbJ2(wUf(TSayg9HEeMU1gWmAmOyYOOBGl4azlVirksG511ITWN)fiQ4hbmfhQM)jwpzxYc9ZbJ2(g7o8Q5FCVIPBTbmJgPibMxxl2cF(xaOlC4DOVOc(QKf6hMmk62ac)jCOJB5fksG511ITWN)fqSwQj(egaNIeyEDTyl85FbKf6RCfxYgW1pqSYfAv8iahoYJDeWizH(fvmzu0nb4WrESJaMxuXKrr3chy))fmfjW86AXw4Z)cil0x5kUKnGRFGyLl0Q4raoCKh7iGrYc9lQyYOOBcWHJ8yhbmVOIjJIUfoW(pitDqLa7ot84S3axWbYMO4q1cP(B4WyYOOBGl4azlVirksG511ITWN)fisa(RFKdiuKaZRRfBHp)lGVk3rL8ygyHIeyEDTyl85FbikxT5vjl0pmzu0nr5QnVULxchgr9JN3O7OIQTO4QIWHXKrr3fFFe9TavVLxOibMxxl2cF(xazH(kxXLSbC9JNCnV4TqkCW8iaVkzH(HjJIUbUGdKD84SdhMDNjEC2BXAPM4tya8nrXHQfb5BkuKaZRRfBHp)lab4c8kHIeyEDTyl85Fb4wm)i)8iYIvksG511ITWN)fOWx0own)JBX8J8dfjW86AXw4Z)cevUGWbxtlxLiQRZj)fmcsrWsxWslTCcKUAErA5y4lhX1iD8lDamVUMomLWfBkY0AkHlYqPnQOGSXZq5eeYqPfyEDDAR2vctx80QnGz0yol9CYFzO0cmVUoTlY44QjTAdygnMZspNiTmuA1gWmAmNLwgPCLuqAJkMmk6MbcVA(T8cDeu6arPdhi8QVlXd7eI0cmVUoTI1J9pNaxn9CYuYqPvBaZOXCwAzKYvsbPLDNjEC2BGl4aztuCOAbDi1p6GNfPJWHPdmzu0nWfCGSLxslW8660kl0x5kUi9CYVzO0cmVUoTyM7IpuzYpPvBaZOXCw65eezgkTaZRRtlMsek5)Q5tR2aMrJ5S0ZjtDgkTaZRRtlqyqRp)ieT90QnGz0yol9CI0LHslW8660Ak(vx8KYKJ84A7PvBaZOXCw65ePidLwG511PfTikM5UyA1gWmAmNLEobHGZqPfyEDDAHMPcNaMhdmM0QnGz0yol9CcciKHsR2aMrJ5S0YiLRKcslMmk6g4coq2Yl0r4W0Hx46ZVxSu6qQ0XF)MwG511PD58660Zji8xgkTAdygnMZslJuUskiTeGx3rfTyLthsLo(7x6yoD8xW0bIGoCWOTVXUdVA(h3Ry6wBaZOr6arqhS7mXJZEhv8JaMIdvZ)eRNSVjke)jTaZRRtBX3hrFlq1PNtqqAzO0QnGz0yolTms5kPG0YUZepo7nWfCGSjkouTGoK6hD8xAbMxxNwopIjYvR(ruX1qZ00ZjimLmuAbMxxNwsTSy0x1pXcW00QnGz0yol9Ccc)MHslW8660IR4h5N3H(mYSk(IefWfPvBaZOXCw65eeqKzO0QnGz0yolTms5kPG0IjJIUbUGdKD84StlW8660YUMPTtaxJpudGRPNtqyQZqPfyEDDAbUGdK0QnGz0yol9CccsxgkTAdygnMZslJuUskiTvZo8Q5Frah413Vc6ii0rWPfyEDDAzGX8aMxx)mLWtRPe(RbCnT4Lx8GxxNEobbPidLwTbmJgZzPLrkxjfKwXIAmphi8Ql2(QChvYJzGf6iiF0H0slW8660sK7hW866NPeEAnLWFnGRPfon9CYFbNHsR2aMrJ5S0cmVUoTmWyEaZRRFMs4P1uc)1aUMwHNE6PDHOSdhd8muobHmuAbMxxNwmWDJ(eRNSNwTbmJgZzPNt(ldLwTbmJgZzPTbCnTaheRabep0R93H(woovsAbMxxNwGdIvGaIh61(7qFlhNkj9CI0YqPfyEDDAXv8J8Z7qFgzwfFrIc4I0QnGz0yol9CYuYqPfyEDDA5LbsSG(DOpGdk5810QnGz0yol9CYVzO0cmVUoTlNxxNwTbmJgZzPNEAXlV4bVUodLtqidLwTbmJgZzPLrkxjfK2QzhE18ViGd867xrAbMxxN2IVpI(wGQtpN8xgkTAdygnMZslJuUskiTsGoqu6WbJ2(g7mcxjBTbmJgPJWHPdeLoWKrr3gq4pHdDClVqhsKockDib6GTceEv8qjaZRRbdDee6aHT0rhHdthvZo8Q5Frah413Vc6qIPfyEDDAfRLAIpmZX(p9CI0YqPvBaZOXCwAzKYvsbPvc0HdeE13Cw(A1iemDeomDamV4QpTv8sf0rqOdeOdjshbLoKaDib6OA2Hxn)lc4aV((vqhbHocEJWV0bIGowvW4RBCyAPJWHPJvfm(6EH50HuPdPfmDir6iCy6qc0bIshoy023y3Hxn)J7vmDRnGz0iDeomDqaEDJdtlDmD6Ga8kDiv6ykbthsKoKyAbMxxN2OIFeWuCOA(Ny9K90ZjtjdLwTbmJgZzPLrkxjfK2vfm(6EH50HuPdPfCAbMxxNwdi8NWHoMEo53muA1gWmAmNLwgPCLuqARMD4vZ)IaoWRVFf0rqOJvfm(kDeomDSQGXx3lmNoKkD8xWPfyEDDAfRLAIpobJj90tRWZq5eeYqPvBaZOXCwAzKYvsbPvSOgZZbcV6ITVk3rL8ygyHo(OJ)OJGshoy023YTWVLfaZOp0JW0T2aMrJ0rqPdmzu0nWfCGSLxslW86606RYDujpMbwspN8xgkTAdygnMZslJuUskiTS7mXJZElwl1eFcdGVjke)HockDGjJIUfRLAIpmZX(Fhpo70cmVUoTI1snXhM5y)NEorAzO0QnGz0yolTms5kPG0IjJIUfRLAIpmZX(FlVKwG511PvSwQj(egap9CYuYqPvBaZOXCwAzKYvsbPvc0HdgT9TCl8BzbWm6d9imDRnGz0iDeu6atgfDdCbhiB5f6qIPfyEDDA9v5oQKhZalPNt(ndLwTbmJgZzPLrkxjfKwhmA7BS7WRM)X9kMU1gWmAmTaZRRtBuXpcykoun)tSEYE65eezgkTAdygnMZslJuUskiTyYOOBdi8NWHoULxslW8660cDHdVd9fvWxtpNm1zO0cmVUoTI1snXNWa4PvBaZOXCw65ePldLwTbmJgZzPfyEDDAbXkxOvXJaC4ip2ratAzKYvsbPnQyYOOBcWHJ8yhbmVOIjJIUfoW(No(OJGtBd4AAbXkxOvXJaC4ip2rat65ePidLwTbmJgZzPfyEDDAbXkxOvXJaC4ip2ratAzKYvsbPnQyYOOBcWHJ8yhbmVOIjJIUfoW(NoccDm10rqPdjqhS7mXJZEdCbhiBIIdvlOdPsh)shHdthyYOOBGl4azlVqhsmTnGRPfeRCHwfpcWHJ8yhbmPNtqi4muAbMxxN2ib4V(roGKwTbmJgZzPNtqaHmuAbMxxNwFvUJk5XmWsA1gWmAmNLEobH)YqPvBaZOXCwAzKYvsbPftgfDtuUAZRB5f6iCy6arPd)45n6oQOAlkUQGochMoWKrr3fFFe9TavVLxslW8660suUAZRPNtqqAzO0QnGz0yolTaZRRtlp5AEXBHu4G5raEnTms5kPG0IjJIUbUGdKD84SPJWHPd2DM4XzVfRLAIpHbW3efhQwqhb5JoMsABaxtlp5AEXBHu4G5raEn9CcctjdLwG511PLaCbELKwTbmJgZzPNtq43muAbMxxNwUfZpYppISynTAdygnMZspNGaImdLwG511PTWx0own)JBX8J8tA1gWmAmNLEobHPodLwG511PnQCbHdUMwTbmJgZzPNEAHtZq5eeYqPfyEDDA9v5oQKhZalPvBaZOXCw65K)YqPvBaZOXCwAzKYvsbPftgfDdCbhi74XzNwG511PfxXpYpVd9zKzv8fjkGlspNiTmuA1gWmAmNLwgPCLuqADWOTVXUdVA(h3Ry6wBaZOX0cmVUoTrf)iGP4q18pX6j7PNtMsgkTAdygnMZslJuUskiTyYOOBdi8NWHoULxslW8660cDHdVd9fvWxtpN8BgkTaZRRtBKa8x)ihqsR2aMrJ5S0ZjiYmuA1gWmAmNLwgPCLuqAXKrr3eLR286wEHochMoqu6WpEEJUJkQ2IIRkOJWHPdmzu0DX3hrFlq1B5L0cmVUoTeLR28A65KPodLwTbmJgZzPfyEDDA5jxZlElKchmpcWRPLrkxjfKwmzu0nWfCGSJhNnDeomDWUZepo7TVk3rL8ygyztuCOAbDeKp6ykPTbCnT8KR5fVfsHdMhb410ZjsxgkTaZRRtlb4c8kjTAdygnMZspNifzO0QnGz0yolTms5kPG0YUZepo7TyTut8jma(MOq8h6iO0bMmk6wSwQj(Wmh7)D84StlW8660kwl1eFyMJ9F65eecodLwG511PvSwQj(egapTAdygnMZspNGaczO0cmVUoTClMFKFEezXAA1gWmAmNLEobH)YqPfyEDDAl8fTJvZ)4wm)i)KwTbmJgZzPNtqqAzO0cmVUoTrLliCW10QnGz0yol90tpTGSVEK0AlCzd411sjcG6PNEM]] )


end
