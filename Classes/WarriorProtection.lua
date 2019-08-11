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
        name = "Free |T132353:0|t Revenge",
        desc = "If checked, the Revenge ability will only be recommended when it costs 0 Rage to use.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Protection Warrior", 20190803, [[dCKkIaqivLkpcGSjus9jHKWOaqNcawfkj9kvfZcLQBjKQDPKFjeddL4yaQLjP0ZqPyAcjUMKITPQu13esPXjKIZPQuwhkjmpGu3tv1(aOoikLAHQsEikLyIcjrxeLsYhfssojkjALa1mbKYnfssTtjvdviPwkkLupLQMQK4RasL9k6Vk1GfCyOfJOhJQjlXLjTzu8zQy0c1PLA1asvVwvjZMWTry3k(TkdxvSCKEortNY1PsBxs67aX4bKCEaX6bsMVQu7h0jWzL0xqtZ61YcWFJLOHf2SaMLOudBQj9gqE00)G8Vqhn9dsOPpQPNPCRVbga6qkTpA6FqGioSKvsV8CPCn9XM9izfrI40wSl5IFerKnHRaT(gofzSiYMGhj9KUTWyLtsM(cAAwVwwa(BSenSWMfWSeLAQ9BPx(O8SE0YM0h3LIojz6lQKNEabdrn9mLB9nWaqhsP9rHGbemeB2JKvejItBXUKl(rer2eUc06B4uKXIiBcoemGGb221XvAWaByhgQLfG)gmeDyaywyfrHfiyiyabdSLyCCujemGGHOddSDPadr1T1oO13adIZP5WGDWWOGad(MGTadSDud0wqWacgIomevQceiWGr75l1KWaavGIRpgmevrVXjQqcayG5OWaBxfnKUGGbemeDyaO1oXMoWGpUvrbgEjo(xWaofyGv6mhvHHOg7bgkib6OWqpg(LcdaeNcmuAggLQJ1OPWWtmqKnhfriqNMddfKaDuaSGGbemeDyGTwjUQkmqpdT(guadUs0rHHJbgaAO0GbVHtzL(h6X0cn9acgIA6zk36BGbGoKs7Jcbdiyi2ShjRiseN2IDjx8JiISjCfO13WPiJfr2eCiyabdSTRJR0Gb2Womulla)nyi6WaWSWkIclqWqWacgylX44Osiyabdrhgy7sbgIQBRDqRVbgeNtZHb7GHrbbg8nbBbgy7OgOTGGbemeDyiQufiqGbJ2ZxQjHbaQafxFmyiQIEJtuHeaWaZrHb2UkAiDbbdiyi6WaqRDInDGbFCRIcm8sC8VGbCkWaR0zoQcdrn2dmuqc0rHHEm8lfgaiofyO0mmkvhRrtHHNyGiBokIqGonhgkib6Oaybbdiyi6WaBTsCvvyGEgA9nOagCLOJcdhdma0qPbdEdNYccgcgqWaBfqPCxtlWaPYCufg4hbjAWaP60JCbdSnNRpMegMBIEmsjyCfWaYT(gjmCJailiyabdi36BKRhQYpcs0(zeO8liyabdi36BKRhQYpcs0(8hH5UcemGGbKB9nY1dv5hbjAF(JGUoe6yO13abdiyWp4Jm(myGIDbgiDzy0cmin0KWaPYCufg4hbjAWaP60JegWPadpun6pNz94adTegk3OliyKB9nY1dv5hbjAF(JqIMj0Tm(CniyKB9nY1dv5hbjAF(J4k1DBkb7dsO)iOKXifLBMBS9XSFoqukemYT(g56HQ8JGeTp)riuIJcK9XSfU8USlufjKqWi36BKRhQYpcs0(8hXXfPLgN9XSrqP0ZIHGrU13ixpuLFeKO95pYZz9nqWqWacgyRakL7AAbg0QkfiWG1ekmyXkmGC7OWqlHbSk2cKuOliyKB9nY)EmLY1hdcg5wFJ8ZFKhxccvabJCRVr(5pIRu3TPes2BMF(DIYbYSWQOH0fvjWEKG(3HxE)M0LHzHvrdPl3hiyKB9nYp)rif3v2mUuGabJCRVr(5pcPsLk9RECGGrU13i)8hbPCC0TDuQogemYT(g5N)iI2j2KBGE3IdHogemYT(g5N)imnvjf3vGGrU13i)8hbhUknkk2CuiGGrU13i)8h55S(g2BMFsxgMfwfnKUCFE)2AcDB3U0kORTgiyabdUsfgyLoZrvyiQXEGb7GbS61fyGIokmWXNNECGGrU13i)8hPDMJQ7hSh2BMFk6ORIY082aDT18Pwwyvdf6ylY7i6Xzx9AUU0bjfAHv53jkhiZQOehffnO6XzlJpxBrvSaeiyKB9nYp)ra5OIsvTNnvL3GdxzVz(53jkhiZcRIgsxuLa7rc6)AHGrU13i)8hH2ppcD3Zw(GCfcg5wFJ8ZFecL4OazFmBHlVl7cvrcjemYT(g5N)i8B46yu00YMrGek7nZpPldZcRIgsxLdKbcgqWaYT(g5N)icuABPHtH9M5NFNOCGmlCAcCFm7IIw8IQeypsq)xlemYT(g5N)iyv0qkemYT(g5N)iCui2i36B2IwASpiH(t0w7GwFd7nZFp8JOhNDbjqhDxJeWSabJCRVr(5pc1D2i36B2IwASpiH(JNYEZ8lFuHyBi1rn5YIDNIs3Cb(a4F2abJCRVr(5pchfInYT(MTOLg7dsO)sdcgcg5wFJCr0w7GwFZVmUvrztko(xS3m)a87muOJTipH0u6shKuOL3V)osxgMLaL2wA4uwUpaG1aKhJuhvUzOi36BqbGbEfnVF3d)i6Xz)edezZrXUgjGzzbmRgROWIxeiqbaiyKB9nYfrBTdA9nF(J0oZr19d2d7nZpajDzywY4wfLnP44FTkhiZ739WpIEC2eOtZ31ibmllGz1yffw8IabkaWAsxgMv7mhv3pypRYbYWAasrhD9Wna)TAF)owrHfVE4gO)EwaaemYT(g5IOT2bT(Mp)rkkXrrrdQEC2Y4Z1yVz(bOHuh1wG0wCpaZY73i36Q6whLOvjGbgaSgGaSh(r0JZUGeOJURrcywwaxdRgROWIxeiq9(DSIclE9WnqZgwaW73a87muOJTiVJOhND1R56shKuOL3VPOJUiqGk6u0rbDuybaaacg5wFJCr0w7GwFZN)icuABPHtH9M5pwrHfVE4gOzdlqWi36BKlI2Ah06B(8hrg3QOSbbfc2BM)E4hrpo7csGo6UgjGJvuyXVFhROWIxpCd01YcememYT(g5cp93IDNIs3Cb(abJCRVrUWt)8hHqjokq2hZw4Y7YUqvKqYEZ8t6YWSWQOH0v5azGGrU13ix4PF(JuuIJIIgu94SLXNRXEZ8BOqhBrEhrpo7QxZ1LoiPqlqWi36BKl80p)rWPjW9XSlkAXS3m)KUmmlbkTT0WPSCFGGrU13ix4PF(JuOOZnB6HuiyKB9nYfE6N)iuTQookemYT(g5cp9ZFexPUBtjyFqc93HEJJC)qBcuSPOJYEZ8t6YWSWQOH0v5azE)MFNOCGmll2DkkDZf4ZIQeypsa)hfiyKB9nYfE6N)iuSk6OuiyKB9nYfE6N)iY4wfLnP44FXEZ8ZVtuoqMLmUvrzlfiXIQybiSM0LHzjJBvu2KIJ)1QCGmqWi36BKl80p)rKXTkkBPajGGHGrU13ixs73IDNIs3Cb(WEZ8lFuHyBi1rn5YIDNIs3Cb(8xlRnuOJTChPDppiPq3mhLRlDqsHwynPldZcRIgsxUpqWi36BKlP95pImUvrztko(xS3m)87eLdKzjJBvu2sbsSOkwacRjDzywY4wfLnP44FTkhidemYT(g5sAF(JiJBvu2sbsWEZ8t6YWSKXTkkBsXX)A5(abJCRVrUK2N)iwS7uu6MlWh2BMFaAOqhB5os7EEqsHUzokxx6GKcTWAsxgMfwfnKUCFaaemYT(g5sAF(JuuIJIIgu94SLXNRXEZ8BOqhBrEhrpo7QxZ1LoiPqlqWi36BKlP95pconbUpMDrrlM9M5N0LHzjqPTLgoLL7demYT(g5sAF(JiJBvu2sbsabJCRVrUK2N)iUsD3MsW(Ge6pkJRIJk3ueuhDZpkkyVz(lkPldZIIG6OB(rrXUOKUmmlPH8V(zbcg5wFJCjTp)rCL6UnLG9bj0FugxfhvUPiOo6MFuuWEZ8xusxgMffb1r38JIIDrjDzywsd5Fb4OL1aKFNOCGmlSkAiDrvcShjOR59BsxgMfwfnKUCFaaemYT(g5sAF(JuOOZnB6HuiyKB9nYL0(8hXIDNIs3Cb(abJCRVrUK2N)iuTQookemYT(g5sAF(J4k1DBkb7dsO)o0BCK7hAtGInfDu2BMFsxgMfwfnKUkhiZ7387eLdKzjJBvu2sbsSOkb2JeW)rbcg5wFJCjTp)rOyv0rPqWi36BKlP95psrRIsdnn9vvQSVjRxlla)nwI2A)w6bbPtpoY0ZkjEoQPfyOgya5wFdmiAPjxqWPhDT4JMEFt4kqRVHTqrgl9IwAYSs6lkd6kSSswh4Ss6rU13K(EmLY1hl96GKcTKVslRxBwj9i36Bs)JlbHksVoiPql5R0Y6SjRKEDqsHwYxPNtBtPnME(DIYbYSWQOH0fvjWEKWaO)HbhEbgE)ggiDzywyv0q6Y9j9i36BsVRu3TPeY0Y6rjRKEKB9nPNuCxzZ4sbs61bjfAjFLwwVMSs6rU13KEsLkv6x94KEDqsHwYxPL1)(Ss6rU13KEKYXr32rP6yPxhKuOL8vAz9OnRKEKB9nPx0oXMCd07wCi0XsVoiPql5R0Y6rtwj9i36BspttvsXDL0Rdsk0s(kTS(3YkPh5wFt6XHRsJIInhfI0Rdsk0s(kTSoWSKvsVoiPql5R0ZPTP0gtpPldZcRIgsxUpWW73WG1e62UDPvya0WqT1KEKB9nP)5S(M0Y6adCwj96GKcTKVspN2MsBm9u0rxfLP5TbdGggQTgy4dmullWaRcdgk0XwK3r0JZU61CDPdsk0cmWQWa)or5azwfL4OOObvpoBz85AlQIfGKEKB9nPVDMJQ7hSN0Y6axBwj96GKcTKVspN2MsBm987eLdKzHvrdPlQsG9iHbq)dd1MEKB9nPhKJkkv1E2uvEdoCnTSoWSjRKEKB9nPN2ppcD3Zw(GCn96GKcTKVslRdCuYkPh5wFt6juIJcK9XSfU8USlufjKPxhKuOL8vAzDGRjRKEDqsHwYxPNtBtPnMEsxgMfwfnKUkhit6rU13KE(nCDmkAAzZiqcnTSoWFFwj9i36BspwfnKMEDqsHwYxPL1boAZkPxhKuOL8v6502uAJPVh(r0JZUGeOJURrcdaggyj9i36BsphfInYT(MTOLw6fT02dsOPNOT2bT(M0Y6ahnzL0Rdsk0s(k9CABkTX0lFuHyBi1rn5YIDNIs3Cb(ada(hgyt6rU13KEQ7SrU13SfT0sVOL2Eqcn94PPL1b(BzL0Rdsk0s(k9i36BsphfInYT(MTOLw6fT02dsOPxAPLw6FOk)iirlRK1boRKEKB9nPNentOBz85APxhKuOL8vAz9AZkPxhKuOL8v6hKqtpckzmsr5M5gBFm7NdeLMEKB9nPhbLmgPOCZCJTpM9ZbIstlRZMSs6rU13KEcL4OazFmBHlVl7cvrcz61bjfAjFLwwpkzL0JCRVj9oUiT04SpMnckLEwC61bjfAjFLwwVMSs6rU13K(NZ6BsVoiPql5R0sl9eT1oO13KvY6aNvsVoiPql5R0ZPTP0gtpaHHVdgmuOJTipH0u6shKuOfy49By47GbsxgMLaL2wA4uwUpWaaGbwddaeg4Xi1rLBgkYT(guadaggaEfnWW73Wqp8JOhN9tmqKnhf7AKWaGHbwwaddSkmeROWIxeiqbdai9i36BsVmUvrztko(xPL1RnRKEDqsHwYxPNtBtPnMEacdKUmmlzCRIYMuC8VwLdKbgE)gg6HFe94SjqNMVRrcdaggyzbmmWQWqSIclErGafmaayG1WaPldZQDMJQ7hSNv5azGbwddaegOOJUE4gmayy4B1cdVFddXkkS41d3GbqddFplWaaspYT(M03oZr19d2tAzD2KvsVoiPql5R0ZPTP0gtpaHbdPoQTaPT4EaMfy49Bya5wxv36OeTkHbaddaddaagynmaqyaGWqp8JOhNDbjqhDxJegammWYc4AGbwfgIvuyXlceOGH3VHHyffw86HBWaOHb2Wcmaay49ByaGWW3bdgk0XwK3r0JZU61CDPdsk0cm8(nmqrhDrGafmeDyGIokmaAyikSadaagaq6rU13K(IsCuu0GQhNTm(CT0Y6rjRKEDqsHwYxPNtBtPnM(yffw86HBWaOHb2Ws6rU13KEbkTT0WPKwwVMSs61bjfAjFLEoTnL2y67HFe94Slib6O7AKWaGHHyffwmm8(nmeROWIxpCdganmullPh5wFt6LXTkkBqqHiT0sV0YkzDGZkPxhKuOL8v6502uAJPx(OcX2qQJAYLf7ofLU5c8bg(HHAHbwddgk0XwUJ0UNhKuOBMJY1LoiPqlWaRHbsxgMfwfnKUCFspYT(M0BXUtrPBUaFslRxBwj96GKcTKVspN2MsBm987eLdKzjJBvu2sbsSOkwacmWAyG0LHzjJBvu2KIJ)1QCGmPh5wFt6LXTkkBsXX)kTSoBYkPxhKuOL8v6502uAJPN0LHzjJBvu2KIJ)1Y9j9i36BsVmUvrzlfirAz9OKvsVoiPql5R0ZPTP0gtpaHbdf6yl3rA3Zdsk0nZr56shKuOfyG1WaPldZcRIgsxUpWaaspYT(M0BXUtrPBUaFslRxtwj96GKcTKVspN2MsBm9gk0XwK3r0JZU61CDPdsk0s6rU13K(IsCuu0GQhNTm(CT0Y6FFwj96GKcTKVspN2MsBm9KUmmlbkTT0WPSCFspYT(M0JttG7Jzxu0ItlRhTzL0JCRVj9Y4wfLTuGePxhKuOL8vAz9OjRKEDqsHwYxPh5wFt6rzCvCu5MIG6OB(rrr6502uAJPVOKUmmlkcQJU5hff7Is6YWSKgY)cg(Hbws)GeA6rzCvCu5MIG6OB(rrrAz9VLvsVoiPql5R0JCRVj9OmUkoQCtrqD0n)OOi9CABkTX0xusxgMffb1r38JIIDrjDzywsd5FbdaggIwyG1WaaHb(DIYbYSWQOH0fvjWEKWaOHHAGH3VHbsxgMfwfnKUCFGbaK(bj00JY4Q4OYnfb1r38JII0Y6aZswj9i36BsFHIo3SPhstVoiPql5R0Y6adCwj9i36BsVf7ofLU5c8j96GKcTKVslRdCTzL0JCRVj9uTQooA61bjfAjFLwwhy2KvsVoiPql5R0JCRVj9o0BCK7hAtGInfD00ZPTP0gtpPldZcRIgsxLdKbgE)gg43jkhiZsg3QOSLcKyrvcShjma4FyikPFqcn9o0BCK7hAtGInfD00Y6ahLSs6rU13KEkwfDuA61bjfAjFLwwh4AYkPh5wFt6lAvuAOPPxhKuOL8vAPLE80Sswh4Ss6rU13KEl2DkkDZf4t61bjfAjFLwwV2Ss61bjfAjFLEoTnL2y6jDzywyv0q6QCGmPh5wFt6juIJcK9XSfU8USlufjKPL1ztwj96GKcTKVspN2MsBm9gk0XwK3r0JZU61CDPdsk0s6rU13K(IsCuu0GQhNTm(CT0Y6rjRKEDqsHwYxPNtBtPnMEsxgMLaL2wA4uwUpPh5wFt6XPjW9XSlkAXPL1RjRKEKB9nPVqrNB20dPPxhKuOL8vAz9VpRKEKB9nPNQv1XrtVoiPql5R0Y6rBwj96GKcTKVspYT(M07qVXrUFOnbk2u0rtpN2MsBm9KUmmlSkAiDvoqgy49ByGFNOCGmll2DkkDZf4ZIQeypsyaW)Wqus)GeA6DO34i3p0MafBk6OPL1JMSs6rU13KEkwfDuA61bjfAjFLww)BzL0Rdsk0s(k9CABkTX0ZVtuoqMLmUvrzlfiXIQybiWaRHbsxgMLmUvrztko(xRYbYKEKB9nPxg3QOSjfh)R0Y6aZswj9i36BsVmUvrzlfir61bjfAjFLwAPLwAzc]] )


end
