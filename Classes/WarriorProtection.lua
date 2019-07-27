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


    spec:RegisterPack( "Protection Warrior", 20190722.1620, [[dCudIaqiaIEea1MqvYNqvk1OaeNcqzvOkQxPQywOQ6wIkAxk5xujdJkLJbGLHQYZevyAuPQRjQ02qvKVbOQXbq4CiKSouLI5HQW9uvTpaPdsLkTqLspeHunruLkDruLk(iGk1jriLvIGzcOIBIQuv7uu1qPsflfvPkpLQMQq5RaQK9k5VQYGfCyOfJOhJ0Kf5YK2mQ8zQy0IYPLA1OkL8AvLmBc3gODR43QmCLQLJYZjA6uUUq2Uq13rOgpaPZRQuRhHy(kf7h0favSYNqtR885gaeLBapF8TaGNaaq4E3xE77DT87i9l0rl)GGA5Dh2zk16BGbGlKX6Jv(D8BXHPkw5LxeJQLpZSDjVXLlN2YIix0d0LSbJeO13qziN5s2GuxLNmQfgrBkYYNqtR885gaeLBapF8TaGNaa4ZnhLxUR0kpWNJYN1PKofz5tQKwEaddUd7mLA9nWaWfYy9XGeammKz2UK34YLtBzrKl6b6s2Grc06BOmKZCjBqkKaGHbcrIVHb(4JFyGp3aGOGHCcdaWt8gaYfsasaWWarpdhhvcjayyiNWG7MsWaVFBTdA9nWG4CAkmyhmmkXWGVbj6WG76oaNfKaGHHCcd8UQa)ggmwpFPMegaIcOuD3GbGB2no82sGbdChdgC34OHSfKaGHHCcdaN2jZ0bg8zTksWWwXr)cgWjbdenN5ykm4oypWqcbrhfg6XWVuyai4KGHuZXPmDSgnfg2Z(w2uu4ceDAkmKqq0rb2csaWWqoHbEpf8IRWa7m06Bqbmejrhfgooya4Gsdg8goPv53zhxl0YdyyWDyNPuRVbgaUqgRpgKaGHHmZ2L8gxUCAllICrpqxYgmsGwFdLHCMlzdsHeammqis8nmWhF8dd85gaefmKtyaaEI3aqUqcqcaggi6z44Osibadd5egC3ucg49BRDqRVbgeNttHb7GHrjgg8nirhgCx3b4SGeammKtyG3vf43WGX65l1KWaquaLQ7gmaCZUXH3wcmyG7yWG7ghnKTGeammKtya40ozMoWGpRvrcg2ko6xWaojyGO5mhtHb3b7bgsii6OWqpg(LcdabNemKAooLPJ1OPWWE23YMIcxGOttHHecIokWwqcaggYjmW7PGxCfgyNHwFdkGHij6OWWXbdahuAWG3WjTGeGeammW7aOknY0emqQChtHb6bsIgmqQo9ixWG7sP6UjHH5MCMHmqUibmGuRVrcd3i(EbjayyaPwFJCTZu6bsI2pNaLFbjayyaPwFJCTZu6bsI2NFxC3LGeammGuRVrU2zk9ajr7ZVlmYbuhdT(gibadd(b3LzNbdmStWazehNMGbPHMegivUJPWa9ajrdgivNEKWaojyyNP5C)mRhhyOLWq6gDbjGuRVrU2zk9ajr7ZVls0mH(KzxKbjGuRVrU2zk9ajr7ZVR9Z6BGeqQ13ix7mLEGKO953fOcESVFh3ter70lXueucjGuRVrU2zk9ajr7ZVlNiKLACEh3djIYoldsaPwFJCTZu6bsI2NFxChnsQPhseL1M(iveesasaWWaVdGQ0ittWGgxzFddwdQWGLPWasTJbdTegW4ylqsHUGeqQ13i)7Xugv3nibKA9nYp)U2JabvbKasT(g5NFxrs91Mck5V5(P3jshXZcJJgYwmfe7rYJFhAAZgYioUfghnKTI2HeqQ13i)87IuCx6XfX(gsaPwFJ8ZVlsLjv2x94ajGuRVr(53fYO4Op7ymDmibKA9nYp)UeTtMjF8wrjhqDmibKA9nYp)U4AMskUlbjGuRVr(53fouvAmu8OOqajGuRVr(531(z9n83C)KrCClmoAiBfTVzJHmh1wwdQp7EPw5bF5cjayyisQWarZzoMcdUd2dmyhmGXVobdm0rHbkUV3JdKasT(g5NFxTZCm9TJ9WFZ9ZqhDLuUM2gp4l3p85gpBOqhBrEhypoV4xt1LoiPqt8m9or6iEwjf8yOOjspopz2fzlMIPVHeqQ13i)87I4JjsX1EEmvEdouL)M7NENiDeplmoAiBXuqShjp(5dsaPwFJ8ZVlwVVl0xpp5osvibKA9nYp)UavWJ9974EIiANEjMIGsibKA9nYp)UO3q1XyOPPhNabv(BUFYioUfghnKTshXdKaGHbKA9nYp)UeO0EsdNe)n3p9or6iEw40G474EjfTSftbXEK84NpibKA9nYp)UW4OHmibKA9nYp)UOOq8qQ138eT04Fqq9hST2bT(g(BU)EOhypoVecIo6lxjqDdsaPwFJ8ZVlw08qQ138eT04Fqq9hpL)M7xURcXZqMJAYLLfnjL9OcChO)5asaPwFJ8ZVlkkepKA9nprln(heu)LgKaKasT(g5cST2bT(MFzwRI0JuC0V4V5(bcG0qHo2I8estzlDqsHM2SbqsgXXTeO0EsdN0kAhy8ci0mK5OYhhdPwFdkakalaXMn9qpWECE7zFlBkkE5kbQBla45mffw2cebuGbjGuRVrUaBRDqRV5ZVR2zoM(2XE4V5(bczeh3sM1Qi9ifh9Rv6iE2SPh6b2JZdeDA6lxjqDBbapNPOWYwGiGcmErgXXTAN5y6Bh7zLoIhEbeg6ORDQbuIIVnBYuuyzRDQXdEYnGbjGuRVrUaBRDqRV5ZVRKcEmu0ePhNNm7Im(BUFGyiZrTfXTL1daUTzdsToU(0rbBvcuaagVacq6HEG948sii6OVCLa1Tfa5YZzkkSSficOB2KPOWYw7uJh5WnGTzdqaKgk0XwK3b2JZl(1uDPdsk00Mnm0rxGiGMtg6O8W9UbmGbjGuRVrUaBRDqRV5ZVlbkTN0WjXFZ9NPOWYw7uJh5WnibKA9nYfyBTdA9nF(DjZAvKEeJcb)n3Fp0dShNxcbrh9LReOzkkSSnBYuuyzRDQXd(CdsasaPwFJCHN(BzrtszpQa3HeqQ13ix4PF(DbQGh773X9er0o9smfbL83C)KrCClmoAiBLoIhibKA9nYfE6NFxjf8yOOjspopz2fz83C)gk0XwK3b2JZl(1uDPdsk0eKasT(g5cp9ZVlCAq8DCVKIwg)n3pzeh3sGs7jnCsRODibKA9nYfE6NFxjg6CZJDidsaPwFJCHN(53ftJRJJcjGuRVrUWt)87ksQV2uq(heu)Dy34iF7Sgefpg6O83C)KrCClmoAiBLoINnBO3jshXZYYIMKYEubUVyki2JeO)UhsaPwFJCHN(53fdJJokdsaPwFJCHN(53LmRvr6rko6x83C)07ePJ4zjZAvKEsbcUykM(MxKrCClzwRI0JuC0VwPJ4bsaPwFJCHN(53LmRvr6jfiiKaKasT(g5sA)ww0Ku2JkWD(BUF5UkepdzoQjxww0Ku2JkW9F(4LHcDSv0iTBFhjf6J7yuDPdsk0eViJ44wyC0q2kAhsaPwFJCjTp)UKzTkspsXr)I)M7NENiDeplzwRI0tkqWftX038ImIJBjZAvKEKIJ(1kDepqci16BKlP953LmRvr6jfii)n3pzeh3sM1Qi9ifh9Rv0oKasT(g5sAF(DzzrtszpQa35V5(bIHcDSv0iTBFhjf6J7yuDPdsk0eViJ44wyC0q2kAhyqci16BKlP953vsbpgkAI0JZtMDrg)n3VHcDSf5DG948IFnvx6GKcnbjGuRVrUK2NFx40G474EjfTm(BUFYioULaL2tA4Kwr7qci16BKlP953LmRvr6jfiiKasT(g5sAF(Dfj1xBki)dcQ)OmlooQ8XqICSh9yOGFdzoQ9AU)KsgXXTyiro2JEmu8skzeh3sAi9RF3GeqQ13ixs7ZVRiP(Atb5Fqq9hLzXXrLpgsKJ9Ohdf83C)jLmIJBXqICSh9yO4LuYioUL0q6xaf45fqO3jshXZcJJgYwmfe7rYJC3SHmIJBHXrdzRODGbjGuRVrUK2NFxjg6CZJDidsaPwFJCjTp)USSOjPShvG7qci16BKlP953ftJRJJcjGuRVrUK2NFxrs91McY)GG6Vd7gh5BN1GO4XqhL)M7NmIJBHXrdzR0r8Szd9or6iEwYSwfPNuGGlMcI9ib6V7HeqQ13ixs7ZVlgghDugKasT(g5sAF(DL04O0qtlFCLj7BQ885gaeLBapF8vEIr20JJS8enW9JzAcgYfgqQ13adIwAYfKq5Xil7yL33Grc06Bi6mKZkVOLMSIv(KYHrcRIv5bOIvEKA9nLVhtzuD3kVoiPqt12YQ88vXkpsT(MYVhbcQIYRdsk0uTTSkFoQyLxhKuOPAB5PS2uwJLNENiDeplmoAiBXuqShjmWJFyWHMGHnBGbYioUfghnKTI2lpsT(MYhj1xBkOSSkV7RyLhPwFt5jf3LECrSVlVoiPqt12YQ85wXkpsT(MYtQmPY(QhNYRdsk0uTTSkppvXkpsT(MYJmko6ZogthR86GKcnvBlRYd8vSYJuRVP8I2jZKpEROKdOow51bjfAQ2wwLhquXkpsT(MYZ1mLuCxQ86GKcnvBlRYtuvSYJuRVP84qvPXqXJIcr51bjfAQ2wwLha3QyLxhKuOPAB5PS2uwJLNmIJBHXrdzRODyyZgyWqMJAlRb1NDVuRWapGb(YT8i16Bk)(z9nLv5baGkw51bjfAQ2wEkRnL1y5zOJUskxtBdg4bmWxUWWhyGp3GbEggmuOJTiVdShNx8RP6shKuOjyGNHb6DI0r8Ssk4XqrtKECEYSlYwmftFxEKA9nLVDMJPVDSNYQ8aWxfR86GKcnvBlpL1MYAS807ePJ4zHXrdzlMcI9iHbE8dd8vEKA9nLN4JjsX1EEmvEdouTSkpa5OIvEKA9nLN177c91ZtUJuT86GKcnvBlRYdG7RyLhPwFt5bvWJ9974EIiANEjMIGYYRdsk0uTTSkpa5wXkVoiPqt12YtzTPSglpzeh3cJJgYwPJ4P8i16Bkp9gQogdnn94eiOwwLhaEQIvEKA9nLhJJgYkVoiPqt12YQ8aa8vSYRdsk0uTT8uwBkRXY3d9a7X5Lqq0rF5kHbGcdUvEKA9nLNIcXdPwFZt0sR8IwAVbb1Yd2w7GwFtzvEaaevSYRdsk0uTT8uwBkRXYl3vH4ziZrn5YYIMKYEubUdda9hgYr5rQ13uEw08qQ138eT0kVOL2BqqT84PLv5bGOQyLxhKuOPAB5rQ13uEkkepKA9nprlTYlAP9geulV0kRSYVZu6bsIwfRYdqfR8i16BkpjAMqFYSlYkVoiPqt12YQ88vXkpsT(MYVFwFt51bjfAQ2wwLphvSYJuRVP8Gk4X((DCpreTtVetrqz51bjfAQ2wwL39vSYJuRVP8oril148oUhseLDww51bjfAQ2wwLp3kw5rQ13uEUJgj10djIYAtFKkcwEDqsHMQTLvw5bBRDqRVPIv5bOIvEDqsHMQTLNYAtznwEGadasyWqHo2I8estzlDqsHMGHnBGbajmqgXXTeO0EsdN0kAhgagmWlyaiWandzoQ8XXqQ13GcyaOWaalabmSzdm0d9a7X5TN9TSPO4LRegakm42cayGNHHmffw2cebuyayLhPwFt5LzTkspsXr)QSkpFvSYRdsk0uTT8uwBkRXYdeyGmIJBjZAvKEKIJ(1kDepWWMnWqp0dShNhi600xUsyaOWGBlaGbEggYuuyzlqeqHbGbd8cgiJ44wTZCm9TJ9SshXdmWlyaiWadD01o1GbGcdefFWWMnWqMIclBTtnyGhWap5gmaSYJuRVP8TZCm9TJ9uwLphvSYRdsk0uTT8uwBkRXYdeyWqMJAlIBlRhaCdg2SbgqQ1X1NokyRsyaOWaaWaWGbEbdabgacm0d9a7X5Lqq0rF5kHbGcdUTaixyGNHHmffw2cebuyyZgyitrHLT2PgmWdyihUbdadg2SbgacmaiHbdf6ylY7a7X5f)AQU0bjfAcg2SbgyOJUarafgYjmWqhfg4bm4E3GbGbdaR8i16BkFsbpgkAI0JZtMDrwzvE3xXkVoiPqt12YtzTPSglFMIclBTtnyGhWqoCR8i16BkVaL2tA4KkRYNBfR86GKcnvBlpL1MYAS89qpWECEjeeD0xUsyaOWqMIcldg2SbgYuuyzRDQbd8ag4ZTYJuRVP8YSwfPhXOquwzLxAvSkpavSYRdsk0uTT8uwBkRXYl3vH4ziZrn5YYIMKYEubUdd)WaFWaVGbdf6yROrA3(osk0h3XO6shKuOjyGxWazeh3cJJgYwr7LhPwFt5TSOjPShvG7Lv55RIvEDqsHMQTLNYAtznwE6DI0r8SKzTkspPabxmftFdd8cgiJ44wYSwfPhP4OFTshXt5rQ13uEzwRI0JuC0VkRYNJkw51bjfAQ2wEkRnL1y5jJ44wYSwfPhP4OFTI2lpsT(MYlZAvKEsbcwwL39vSYRdsk0uTT8uwBkRXYdeyWqHo2kAK2TVJKc9XDmQU0bjfAcg4fmqgXXTW4OHSv0omaSYJuRVP8ww0Ku2JkW9YQ85wXkVoiPqt12YtzTPSglVHcDSf5DG948IFnvx6GKcnvEKA9nLpPGhdfnr6X5jZUiRSkppvXkVoiPqt12YtzTPSglpzeh3sGs7jnCsRO9YJuRVP840G474EjfTSYQ8aFfR8i16BkVmRvr6jfiy51bjfAQ2wwLhquXkVoiPqt12YJuRVP8OmlooQ8XqICSh9yOO8uwBkRXYNuYioUfdjYXE0JHIxsjJ44wsdPFbd)WGBLFqqT8OmlooQ8XqICSh9yOOSkprvXkVoiPqt12YJuRVP8OmlooQ8XqICSh9yOO8uwBkRXYNuYioUfdjYXE0JHIxsjJ44wsdPFbdafgaEyGxWaqGb6DI0r8SW4OHSftbXEKWapGHCHHnBGbYioUfghnKTI2HbGv(bb1YJYS44OYhdjYXE0JHIYQ8a4wfR8i16BkFIHo38yhYkVoiPqt12YQ8aaqfR8i16BkVLfnjL9OcCV86GKcnvBlRYdaFvSYJuRVP8mnUooA51bjfAQ2wwLhGCuXkVoiPqt12YJuRVP8oSBCKVDwdIIhdD0YtzTPSglpzeh3cJJgYwPJ4bg2SbgO3jshXZsM1Qi9KceCXuqShjma0FyW9LFqqT8oSBCKVDwdIIhdD0YQ8a4(kw5rQ13uEgghDuw51bjfAQ2wwLhGCRyLhPwFt5tACuAOPLxhKuOPABzLvE80kwLhGkw5rQ13uEllAsk7rf4E51bjfAQ2wwLNVkw51bjfAQ2wEkRnL1y5jJ44wyC0q2kDepLhPwFt5bvWJ9974EIiANEjMIGYYQ85OIvEDqsHMQTLNYAtznwEdf6ylY7a7X5f)AQU0bjfAQ8i16BkFsbpgkAI0JZtMDrwzvE3xXkVoiPqt12YtzTPSglpzeh3sGs7jnCsRO9YJuRVP840G474EjfTSYQ85wXkpsT(MYNyOZnp2HSYRdsk0uTTSkppvXkpsT(MYZ0464OLxhKuOPABzvEGVIvEDqsHMQTLhPwFt5Dy34iF7Sgefpg6OLNYAtznwEYioUfghnKTshXdmSzdmqVtKoINLLfnjL9OcCFXuqShjma0FyW9LFqqT8oSBCKVDwdIIhdD0YQ8aIkw5rQ13uEgghDuw51bjfAQ2wwLNOQyLxhKuOPAB5PS2uwJLNENiDeplzwRI0tkqWftX03WaVGbYioULmRvr6rko6xR0r8uEKA9nLxM1Qi9ifh9RYQ8a4wfR8i16BkVmRvr6jfiy51bjfAQ2wwzLvwzvb]] )


end
