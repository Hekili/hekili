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

        potion = "potion_of_bursting_blood",

        package = "Protection Warrior",
    } )


    spec:RegisterPack( "Protection Warrior", 20190417.2212, [[dCuEDaqifQ0JqcTjbXNqLinka4uaOvHe4vQsMLG0TufLDj0VisddvQJPOAzijpJiyAeHUMQiBtvu13qLKXbq4COsyDaKAEerDpaTpfkhejOfQk8qasMiQevxevIYhvfv6KaeTsuXmvOc3uHkYovugkQK6PIAQcQRQqf1xvfvSxP(RQAWuCyOfd0JrzYICzsBwGpJuJMOoTKvJkr8AKOzJ42OQDR0Vvz4ky5eEoLMovxxr2UQuFhj14vOQZdqTEIiZxHSFq3Z7WDoHU2ZOI75Cb3sCoxfPIQ5ur18o7aEq78aYOeP1oViV2zUwCUY86wO55GcrDIopGaMCyQd3z7njyANLDFWcOLkLUC5jWi74LAl(jc61Tmbg4sTfptANbNkIdi3gSZj01EgvCpNl4wIZ5QivunNQ5pFNTdkRNXvsOZYvkPBd25KAzDMIqdxloxzEDl08CqHOobKdfHgz3hSaAPsPlxEcmYoEP2IFIGEDltGbUuBXZGCOi0qHdIIanZ5QqHgQ4EoxanpdAOIka985qoqoueAauY4sRwihkcnpdAOWucAgNkVOrVUfAihDXGg)GMvPgAYfpGcAOqUECeHCOi08mOHlxjiGHgxulLQBHgaOJNPdo08Cf3sZLAbi0eCcOHcFJokIqoueAEg0mokAzxxOjlxkjbnpihJsOb3e0aiP3tOqdxJ1cnjKhPvOPwhPuHgaGBcAsvqGk01l0vOzqgW2IHeP8iDXGMeYJ0kaJDEqCbfr7mfHgUwCUY86wO55GcrDcihkcnYUpyb0sLsxU8eyKD8sTf)eb96wMadCP2INb5qrOHchefbAMZvHcnuX9CUaAEg0qfva65ZHCGCOi0aOKXLwTqoueAEg0qHPe0movErJEDl0qo6Ibn(bnRsn0KlEaf0qHC94ic5qrO5zqdxUsqadnUOwkv3cnaqhpthCO55kULMl1cqOj4eqdf(gDueHCOi08mOzCu0YUUqtwUuscAEqogLqdUjObqsVNqHgUgRfAsipsRqtTosPcnaa3e0KQGavORxORqZGmGTfdjs5r6IbnjKhPvagHCGCOi0WLnELn5AcAa1GtOqd74brhAav6ATrOHczmDWTqZE7ZKrbFWebAqMx3AHMBjaoc5GmVU1ghek74brhyabTuc5GmVU1ghek74br)fqPb3LGCqMx3AJdcLD8GO)cOuCIMxxh96wihkcn5fhSYNdncSsqd4uqGMGgRJUfAa1GtOqd74brhAav6ATqdUjOzqOpB4CVwAOPSqt6wnc5GmVU1ghek74br)fqPGO7e9BLVjhYbzEDRnoiu2XdI(lGsTloyLp)BD0TqoiZRBTXbHYoEq0Fbu6W51TqoqoueA4YgVYMCnbn6BvayOXlEfACzfAqMFcOPSqd(glccs0iKdY86wlWADvW0bhYbzEDR9fqPdt88kbYbzEDR9fqPtw9xUYBdTcaYUJKoQ3i(gDuefkpwRvYaPzPrJaNccI4B0rrCAaYbzEDR9fqPGK7s)GjbGHCqMx3AFbukOkSQGYAPHCqMx3AFbukky4QF)ecDDihK51T2xaLskAz3(5sMs0866qoiZRBTVaknOeki5UeKdY86w7lGsXLPwxGKpdjeihK51T2xaLoCEDBOvaqWPGGi(gDueNggnYrbT6rV41VF)uPsMQNGCOi0moBvObqsVNqHgUgRfA8dAW3xLGgbsRqddhgQLoc5GmVU1(cO0IEpH(hWAdTcakqAnM0GIvUKP6PxuXnf4irxpcEhFT0)3xX0OUiirtua7os6OEJjL)eiPKuT0FR8n5rHIjad5GmVU1(cOu8n6OaYbzEDR9fqPmKq(iZRB)KY6HUiVcKV8Ig962qRaG1Yo(AP)jKhP1)t2X4gYbzEDR9fqPIP9JmVU9tkRh6I8kq80qRaG2bLq(okOv3gD5PnPIpJGdJbucqoiZRBTVakLHeYhzED7Nuwp0f5vGwhYbYbzEDRnYxErJEDlqRCPK0hKCmkdTcacGX1rIUEe8iwxfrDrqIMgnACbNccIe06FRJBkonaWqaatgf0Q9hiqMx3IKXMhbeJgvl74RL(pidyBXqY)j7yChNtbYksC5ipoEac5GmVU1g5lVOrVU9fqPf9Ec9pG1gAfaeCkiiALlLK(GKJrzmDuVHaofeel69e6FaRnMoQ3qaGaP14aZhJlOA0iaiRiXLJdmxYsG7rJQLD81s)5r6I9FYog3X5uGSIexoYJJhGaeYbzEDRnYxErJED7lGstk)jqsjPAP)w5BYdTcacahf0QhPUC5ANZ9OriZR36xxLVu7yZbyiaaa1Yo(AP)jKhP1)t2X4oo)jkqwrIlh5XXpAKSIexooWCjlbUb4OrayCDKORhbVJVw6)7RyAuxeKOPrJeiTg5XX)mbsRswICdqac5GmVU1g5lVOrVU9fqPe06FRJBk0kaOSIexooWCjlbUHCqMx3AJ8Lx0Ox3(cOuRCPK0NAKqcTcawl74RL(NqEKw)pzhtwrIlpAKSIexooWCjtf3qoqoiZRBTrR)cOuxEAtQ4Zi4qOvaq7GsiFhf0QBJU80MuXNrWbGufIJeD940A9Byabj6p4emnQlcs0uiGtbbr8n6Oiona5GmVU1gT(lGsTYLssFqYXOm0kai7os6OEJw5sjPVLG8rHIjahc4uqq0kxkj9bjhJYy6OEdbLKkkxJGcKP)Gt8l(bK5rbUuogkjvuUgtkgOBT0FMaTYrbUugc4uqqeFJokItdqoiZRBTrR)cOuRCPK03sq(qRaGOKur5AeuGm9hCIFXpGmpkWLYXqjPIY1ysXaDRL(ZeOvokWLYqaNccI4B0rrCAieWPGGOvUus6dsogLXPbihK51T2O1FbuQlpTjv8zeCi0kaiaCKORhNwRFddiir)bNGPrDrqIMcbCkiiIVrhfXPbac5GmVU1gT(lGstk)jqsjPAP)w5BYdTca6irxpcEhFT0)3xX0OUiirtqoiZRBTrR)cOuRCPK0hKCmkdTcaYUJKoQ3OvUus6BjiFuOycWHaofeeTYLssFqYXOmMoQxihK51T2O1FbuQvUus6BjipKdY86wB06Vaknjq6B)IdfqoiZRBTrR)cOuxEAtQ4Zi4aKdY86wB06VakvOV1LwHCqMx3AJw)fqPtw9xUYh6I8kqAXT02)GO4rYxG0AOvaqWPGGi(gDueth17OrS7iPJ6nALlLK(wcYhfkpwRDmGseYbzEDRnA9xaLkW3iTkGCqMx3AJw)fqPj9nAD0vihihK51T2iE6lGsD5PnPIpJGdqoiZRBTr80xaLMu(tGKss1s)TY3KhAfa0rIUEe8o(AP)VVIPrDrqIMGCqMx3AJ4PVaknjq6B)IdfqoiZRBTr80xaLk036sRqoiZRBTr80xaLoz1F5kFOlYRaPf3sB)dIIhjFbsRHwbabNccI4B0rrmDuVJgXUJKoQ3OlpTjv8zeCikuESw7yaLiKdY86wBep9fqPc8nsRcihK51T2iE6lGsTYLssFqYXOm0kai7os6OEJw5sjPVLG8rHIjahc4uqq0kxkj9bjhJYy6OEHCqMx3AJ4PVak1kxkj9TeKVZVvHTUTNrf3Z5cULi3ZJZL4tu1zQrXwlTTZas(Ht4AcAEcAqMx3cnKY62iKtNXjx(eDox8te0RBbucmW7mPSUTd35KgGteVd3ZM3H7mY862oxRRcMo4DwxeKOP(r79mQ6WDgzEDBNhM45vsN1fbjAQF0EptcD4oRlcs0u)OZmr5QOWoZUJKoQ3i(gDuefkpwRfAKmqOHMLGMrJGgWPGGi(gDueNg6mY862opz1F5kVT9EMe7WDgzEDBNbj3L(btca3zDrqIM6hT3ZEQd3zK51TDgufwvqzT0DwxeKOP(r79SNVd3zK51TDgfmC1VFcHUEN1fbjAQF0EpJR6WDgzEDBNjfTSB)CjtjAED9oRlcs0u)O9EgGOd3zK51TDoOeki5UuN1fbjAQF0EpJl6WDgzEDBNXLPwxGKpdjKoRlcs0u)O9E2CU7WDwxeKOP(rNzIYvrHDgCkiiIVrhfXPbOz0iOXrbT6rV41VF)uPqJKHgQEQZiZRB78W51TT3ZMpVd3zDrqIM6hDMjkxff2zbsRXKguSYHgjdnu9e08cAOIBOHcGghj66rW74RL()(kMg1fbjAcAOaOHDhjDuVXKYFcKusQw6Vv(M8OqXeG7mY862ox07j0)awB79S5u1H7mY862oJVrhfDwxeKOP(r79S5sOd3zDrqIM6hDMjkxff25AzhFT0)eYJ06)jl0mg0WDNrMx32zgsiFK51TFsz9otkR)xKx7mF5fn61TT3ZMlXoCN1fbjAQF0zMOCvuyNTdkH8DuqRUn6YtBsfFgbhGMXacnsOZiZRB7SyA)iZRB)KY6DMuw)ViV2z8027zZFQd3zDrqIM6hDgzEDBNziH8rMx3(jL17mPS(FrETZwV9278Gqzhpi6D4E28oCN1fbjAQF0EpJQoCN1fbjAQF0EptcD4oRlcs0u)O9EMe7WDgzEDBNbr3j63kFtEN1fbjAQF0Ep7PoCN1fbjAQF0Ep757WDgzEDBNhoVUTZ6IGen1pAV9oZxErJEDBhUNnVd3zDrqIM6hDMjkxff2zaanJl04irxpcEeRRIOUiirtqZOrqZ4cnGtbbrcA9V1XnfNgGgacnHanaaAyYOGwT)abY86wKanJbnZJacOz0iOPw2Xxl9FqgW2IHK)twOzmOH74COHcGgzfjUCKhhp0aWoJmVUTZw5sjPpi5yu2EpJQoCN1fbjAQF0zMOCvuyNbNccIw5sjPpi5yugth1l0ec0aofeel69e6FaRnMoQxOjeObaqJaP14aZHMXGgUGkOz0iObaqJSIexooWCOrYqJe4gAgncAQLD81s)5r6I9FYcnJbnChNdnua0iRiXLJ844HgacnaSZiZRB7CrVNq)dyTT3ZKqhUZ6IGen1p6mtuUkkSZaaACuqREK6YLRDo3qZOrqdY86T(1v5l1cnJbnZHgacnHanaaAaa0ul74RL(NqEKw)pzHMXGgUJZFcAOaOrwrIlh5XXdnJgbnYksC54aZHgjdnsGBObGqZOrqdaGMXfACKORhbVJVw6)7RyAuxeKOjOz0iOrG0AKhhp08mOrG0k0izOrICdnaeAayNrMx325KYFcKusQw6Vv(M827zsSd3zDrqIM6hDMjkxff2zzfjUCCG5qJKHgjWDNrMx32zcA9V1Xn1Ep7PoCN1fbjAQF0zMOCvuyNRLD81s)tipsR)NSqZyqJSIexgAgncAKvK4YXbMdnsgAOI7oJmVUTZw5sjPp1iH0E7D26D4E28oCN1fbjAQF0zMOCvuyNTdkH8DuqRUn6YtBsfFgbhGgGqdvqtiqJJeD940A9Byabj6p4emnQlcs0e0ec0aofeeX3OJI40qNrMx32zxEAtQ4Zi4q79mQ6WDwxeKOP(rNzIYvrHDMDhjDuVrRCPK03sq(OqXeGHMqGgWPGGOvUus6dsogLX0r9cnHanOKur5AeuGm9hCIFXpGmpkWLsOzmObLKkkxJjfd0Tw6ptGw5OaxkHMqGgWPGGi(gDueNg6mY862oBLlLK(GKJrz79mj0H7SUiirt9JoZeLRIc7mkjvuUgbfit)bN4x8diZJcCPeAgdAqjPIY1ysXaDRL(ZeOvokWLsOjeObCkiiIVrhfXPbOjeObCkiiALlLK(GKJrzCAOZiZRB7SvUus6BjiF79mj2H7SUiirt9JoZeLRIc7maGghj66XP163Wacs0FWjyAuxeKOjOjeObCkiiIVrhfXPbObGDgzEDBND5PnPIpJGdT3ZEQd3zDrqIM6hDMjkxff2zhj66rW74RL()(kMg1fbjAQZiZRB7Cs5pbskjvl93kFtE79SNVd3zDrqIM6hDMjkxff2z2DK0r9gTYLssFlb5JcftagAcbAaNccIw5sjPpi5yugth1BNrMx32zRCPK0hKCmkBVNXvD4oJmVUTZw5sjPVLG8DwxeKOP(r79marhUZiZRB7CsG03(fhk6SUiirt9J27zCrhUZiZRB7SlpTjv8zeCOZ6IGen1pAVNnN7oCNrMx32zH(wxATZ6IGen1pAVNnFEhUZ6IGen1p6mY862otlUL2(hefps(cKw7mtuUkkSZGtbbr8n6OiMoQxOz0iOHDhjDuVrRCPK03sq(Oq5XATqZyaHgj25f51otlUL2(hefps(cKwBVNnNQoCNrMx32zb(gPvrN1fbjAQF0EpBUe6WDgzEDBNt6B06ORDwxeKOP(r7T3z80oCpBEhUZiZRB7SlpTjv8zeCOZ6IGen1pAVNrvhUZ6IGen1p6mtuUkkSZos01JG3Xxl9)9vmnQlcs0uNrMx325KYFcKusQw6Vv(M827zsOd3zK51TDojq6B)IdfDwxeKOP(r79mj2H7mY862ol036sRDwxeKOP(r79SN6WDwxeKOP(rNrMx32zAXT02)GO4rYxG0ANzIYvrHDgCkiiIVrhfX0r9cnJgbnS7iPJ6n6YtBsfFgbhIcLhR1cnJbeAKyNxKx7mT4wA7Fqu8i5lqAT9E2Z3H7mY862olW3iTk6SUiirt9J27zCvhUZ6IGen1p6mtuUkkSZS7iPJ6nALlLK(wcYhfkMam0ec0aofeeTYLssFqYXOmMoQ3oJmVUTZw5sjPpi5yu2Epdq0H7mY862oBLlLK(wcY3zDrqIM6hT3E7T3E3a]] )


end
