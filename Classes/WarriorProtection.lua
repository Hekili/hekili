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
            range = 12,

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

            readyTime = function () return max( talent.bolster.enabled and buff.last_stand.remains or 0, buff.shield_block.remains ) end,
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

            toggle = "interrupts",
            debuff = "casting",
            readyTime = state.timeToInterrupt,
            usable = function () return not target.is_boss end,

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

        potion = "potion_of_unbridled_fury",

        package = "Protection Warrior",
    } )


    spec:RegisterSetting( "free_revenge", true, {
        name = "Free |T132353:0|t Revenge",
        desc = "If checked, the Revenge ability will only be recommended when it costs 0 Rage to use.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Protection Warrior", 20200614, [[dKuMOaqivr6rav2KQO(KKsLrbu6uafRIer9kvvMffv3svvAxI8lQudJkPJrIAzuKEMKsMgvIUMQQABQQcFJebJJejNtsPQ1rIqnpGQUNQY(OiCqvvrluvQhsIunrjLsUOKsrFusPWjPsiRKKmtsKYnPsOANQcdvveTuse5PsmvjvxvsPuFLeHSxv(ROgmLomQfdPhJyYu1Lj2meFMcJwsoTIvtLGxtrz2K62a2Tu)wPHdKJtLqz5q9CKMUW1PITts9DvjJxveoVKI1tr08jH9d6t5R(v8Ci3dtD1uxD9pu2LjLn1uLYLkFLOgqYvaXeZyd5kndix5jXBiKy2gAvIymEw8vaX1Ox2F1VcDDWe5kvraIQe72TXevoOjYc4MoaoAoMTjygjCthaI7RG6m6Wf1h6v8Ci3dtD1uxD9pu2LjLn1uLYLxHcsi3dLqTUs149sFOxXluYvah0(K4nesmBdTkrmgplgQcCqBveGOkXUDBmrLdAISaUPdGJMJzBcMrc30bGavboOvLtlqRYU0CO1uxn1vOkOkWbTk9kUnekuf4G2)cT)P3dTU4tmgCmBdT61yiqBSqBlVG2YaO0H2)8jvAjOkWbT)fARTenxd0g4Pntck0cw5jicOaARnWBBu7OGbArwm0(NQ5GXjOkWbT)fAvAJrvin0wQgr7H236Lyg0YThADrg9IfO9j5PHwpdWgc0oDWMjqlwCXCgSaiDqtqvGdA)l0QKeGvTaT4n4y2M1qRdLneODrGwLgtdOTeC7tqvGdA)l0wBtfOvjjQL2qGwW(QsAODcOLS0GcTkj2qad0UTUgODqG2jG2xBx7cOD6qWicwG2xtubTatmgCmBNUci8ImA5kGdAFs8gcjMTHwLigJNfdvboOTkcquLy3UnMOYbnrwa30bWrZXSnbZiHB6aqGQah0QYPfOvzxAo0AQRM6kufuf4GwLEf3gcfQcCq7FH2)07Hwx8jgdoMTHw9AmeOnwOTLxqBzau6q7F(KkTeuf4G2)cT1wIMRbAd80MjbfAbR8eebuaT1g4TnQDuWaTilgA)t1CW4euf4G2)cTkTXOkKgAlvJO9q7B9smdA52dTUiJEXc0(K80qRNbydbANoyZeOflUyodwaKoOjOkWbT)fAvscWQwGw8gCmBZAO1HYgc0UiqRsJPb0wcU9jOkWbT)fARTPc0QKe1sBiqlyFvjn0ob0swAqHwLeBiGbA3wxd0oiq7eq7RTRDb0oDiyeblq7RjQGwGjgdoMTtqvqvGdARnFcH4eIhArfKflqlzbq5aArfJPPjO9pjebuqH2E7)wXyaehn0YKy2McTBRRjbvboOLjXSnnbclKfaLJpentndQcCqltIzBAcewilakh)(CJSRhQcCqltIzBAcewilakh)(CZogashCmBdvboOT0miA1gqlMhp0I6GGiEOLgCqHwubzXc0swauoGwuXyAk0YThAbHL)cAJyAdODOqRFBjbvXKy2MMaHfYcGYXVp3OCeAjtRwNaQIjXSnnbclKfaLJFFUDOsEcbW8MbKp2K0kgZ0mY2rErYG2xcgQIjXSnnbclKfaLJFFUFTyTxTmDgl0T5MiqvmjMTPjqyHSaOC87ZnGaS4AYlsw7qgF2JfgGcvXKy2MMaHfYcGYXVp3G2y2gQcQcCqBT5tieNq8qROwW1aTXaiqBujqltIfdTdfAz18OzuTKGQysmBt)MoemrafqvmjMTP)(CdYbaq0qvmjMTP)(CtRwIzVy1I5dYNxqDqqseMgtBKCa98tdgBirAOz0LsHQysmBt)95gvVRpJ4GRbQIjXSn93NBubtfSztBavXKy2M(7ZnJjCl5yXyPdOkMeZ20FFU1JrvqZUGJ3aq6aQIjXSn93NBKblO6D9qvmjMTP)(CZnrObM1zcR1qvmjMTP)(CJYg5fjh4HygfQIjXSn93NBqBmBB(G8H6GGKy1CW4KdifkIbqYXM9JaEt)hQcCqRdvGwxKrVybAFsEAOnwOLvVJhAXSHaTegeOPnGQysmBt)95Em6flzq80MpiFy2qsEbzitaEt))NPUQKdwlDKq3fyAJS6DissAgvlELmzxTFF1jVaSywpMCAJmTADIewyFnqvmjMTP)(C)AXAVAz6mwOBZnrmFq(i7Q97RoXQ5GXjSaWttb)NPqvmjMTP)(CdialUM8IK1oKXN9yHbOMpiFKD1(9vNy1CW4ewa4PPG)ZG4HQysmBt)95MSnr6aZH4ZiAgqmFq(qDqqsSAoyCYVV6NFQFJezBI0bMdXNr0mGKrDWDcla80ut4QcfcLknrsrLKjyhYGQL8IKr0mGKWCBg4Rfuf4GwMeZ20FFU1mnY0GBV5dYNqPstKe3daNxKSEqKm3(Sx4OkbWUWIHQysmBt)95UsyCKfkvAIy(G89uWkuQ0ejfvsMGDidQwYlsgrZascGDHfRqHqPstK0RfR9QLPZyHUn3ejbWUWIvOqOuPjsI7bGZlswpisMBF2lCuLayxyXkuiuQ0ejbialUM8IK1oKXN9yHbOja2fwmyGQysmBt)952Hk5jeaQ5dYhzxTFF1jwnhmoHfaEAk4)miEfkqDqqsSAoyCYbeuftIzB6Vp3SAoymuftIzB6Vp3ewRZmjMTZ6HgM3mG8bmXyWXST5dY30KfyAJSNbydj)p1eUcvXKy2M(7Zn2PZmjMTZ6HgM3mG8XRy(G8rbjADoySHe0uu50EbNjAgKj(QfuftIzB6Vp3ewRZmjMTZ6HgM3mG8rdOkOkMeZ20eWeJbhZ2FJrVyjdIN28b5BAYcmTr2ZaSHK)NcvXKy2MMaMym4y2(3NBA1iAFgvVeZmFq(a7tdwlDKqxnneCsAgvlEfkEkQdcssZ0itdU9jhqG5zWsQySHqZiyMeZ2S2ekNukfkMMSatBK9maBi5)PGbQIjXSnnbmXyWXS9Vp3EbyXSEm50gzA16eMpiFGnySHePxtunTYUQqbtIrTKLwagHAcLbZZGfSttwGPnYEgGnK8)ut4As5)vYvcRJQea)ekuujSoQsGib4RLRGrHcW(0G1shj0DbM2iREhIKKMr1IxHcmBija(j(lMneW7sxbdyGQysmBttatmgCmB)7ZTMPrMgC7nFq(MMSatBK9maBi5ArnrLW6O6zYUA)(QtCpaCErYEHJQewa4PPG)ZuOkMeZ20eWeJbhZ2)(CtRgr7ZVyT28b5BAYcmTr2ZaSHK)NAIkH1rLcfvcRJQeisaEtDfQcQIjXSnnXR8fvoTxWzIMbbvXKy2MM4v(952lalM1JjN2itRwNW8b5lyT0rcDxGPnYQ3HijPzuT4HQysmBtt8k)(CtRgr7ZO6LyM5dYhzxTFF1jA1iAFMQzGewyFnpJ6GGKOvJO9zu9sml53x9ZOoiijabyX1KxKS2Hm(Shlman5acQIjXSnnXR87ZnTAeTpt1mG5dYhQdcscqawCn5fjRDiJp7XcdqtoGGQysmBtt8k)(C7XSX2z8YyOkMeZ20eVYVp3yrT0gI5dYhQdcsclQL2qsoGuO4PXAyOLKxqKMoQfQcfOoiiPXOxSKbXtNCaPqbyrDqqs0Qr0(mQEjMLWcapnvHcYUA)(Qt0Qr0(mQEjMLivm2qOzemtIzBwdExtkfyGQysmBtt8k)(C7qL8ecG5ndiFg4TnOzq4bG1zmBiMpiFOoiijwnhmo53xTcfKD1(9vNIkN2l4mrZGsybGNMAIpxcvXKy2MM4v(95gZQzdbdvXKy2MM4v(95MwnI2Nr1lXmZhKpYUA)(Qt0Qr0(mvZajSW(AEg1bbjrRgr7ZO6LywYVV6Njvm2qOFMcvXKy2MM4v(95MwnI2NPAgaQIjXSnnXR87ZT6HelUMm2HwbvXKy2MM4v(95EaajTFAJS6HelUgOkMeZ20eVYVp3ErntdoeOkOkMeZ20en(IkN2l4mrZGmFq(OGeTohm2qcAkQCAVGZend6Z0NdwlDKCAASGaXOAjJSyIKKMr1I)zuheKeRMdgNCabvXKy2MMOXVp30Qr0(mQEjMz(G8r2v73xDIwnI2NPAgiHf2xZZOoiijA1iAFgvVeZs(9v)mPIXgc9ZuOkMeZ20en(95MwnI2NPAgaQIjXSnnrJFFUJkN2l4mrZGmFq(aBWAPJKttJfeigvlzKftKK0mQw8pJ6GGKy1CW4KdiWavXKy2MMOXVp3EbyXSEm50gzA16eMpiFbRLosO7cmTrw9oejjnJQfpuftIzBAIg)(C7qL8ecG5ndiFmTsn3cnJztU4mzXS28b5ZlOoiijmBYfNjlM1zVG6GGKObtm7ZvOkMeZ20en(952Hk5jeaZBgq(yALAUfAgZMCXzYIzT5dYNxqDqqsy2KlotwmRZEb1bbjrdMyMjucpdwYUA)(QtSAoyCcla80uW)VcfOoiijwnhmo5acmqvmjMTPjA87ZThZgBNXlJHQysmBtt043N7OYP9cot0miOkMeZ20en(95glQL2qmFq(qDqqsyrT0gsYbKcfpnwddTK8cI00rTqvOa1bbjng9ILmiE6KdifkalQdcsIwnI2Nr1lXSewa4PPkuq2v73xDIwnI2Nr1lXSePIXgcnJGzsmBZAW7AsPaduftIzBAIg)(C7qL8ecG5ndiFg4TnOzq4bG1zmBiMpiFOoiijwnhmo53xTcfKD1(9vNOvJO9zQMbsybGNMAIpxcvXKy2MMOXVp3ywnBiyOkMeZ20en(95w9qIfxtg7qRGQysmBtt043N7baK0(PnYQhsS4AGQysmBtt043NBVOMPbhYvuly6S99Wuxn1vxv20)4kVyCpTb9kUiaqloep0(p0YKy2gA1dnOjOQRWor1IVszaC0CmBR0XmsCf9qd6v)kEbHD0Xv)EO8v)kmjMTVY0HGjcO4ksZOAXFVV4Ey6v)kmjMTVcihaarFfPzuT4V3xCpQ1v)ksZOAXFVVcbpHGh(kEb1bbjryAmTrYbe0(m0(uOnySHePHMrxk9kmjMTVcTAjM9IvlxCpC5v)kmjMTVcQExFgXbxZvKMr1I)EFX94)R(vysmBFfubtfSztBCfPzuT4V3xCp(JR(vysmBFfgt4wYXIXshxrAgvl(79f3dLWv)kmjMTVIEmQcA2fC8gashxrAgvl(79f3dL6QFfMeZ2xbzWcQEx)vKMr1I)EFX9O2F1VctIz7RWnrObM1zcR1xrAgvl(79f3dLD9QFfMeZ2xbLnYlsoWdXm6vKMr1I)EFX9qzLV6xrAgvl(79vi4je8Wxb1bbjXQ5GXjhqqRcfqBmaso2SFeOf8qRP)FfMeZ2xb0gZ2xCpu20R(vKMr1I)EFfcEcbp8vWSHK8cYqMaAbp0A6)q7pO1uxHwLm0gSw6iHUlW0gz17qKK0mQw8qRsgAj7Q97Ro5fGfZ6XKtBKPvRtKWc7R5kmjMTVYy0lwYG4PV4EOCTU6xrAgvl(79vi4je8WxHSR2VV6eRMdgNWcapnfAb)h0A6vysmBFLxlw7vltNXcDBUjYf3dLD5v)ksZOAXFVVcbpHGh(kKD1(9vNy1CW4ewa4PPql4)GwdI)kmjMTVcGaS4AYlsw7qgF2JfgGEX9q5)V6xrAgvl(79vi4je8Wxb1bbjXQ5GXj)(QH2NH2NcT(nsKTjshyoeFgrZasg1b3jSaWttHwtaTUcTkuaTcLknrsrLKjyhYGQL8IKr0mGKWCBg0cEOTwxHjXS9viBtKoWCi(mIMbKlUhk)hx9RinJQf)9(ke8ecE4R8uOfSqRqPstKuujzc2HmOAjVizendija2fwm0Qqb0kuQ0ej9AXAVAz6mwOBZnrsaSlSyOvHcOvOuPjsI7bGZlswpisMBF2lCuLayxyXqRcfqRqPstKeGaS4AYlsw7qgF2JfgGMayxyXqlyUctIz7RujmoYcLknrU4EOSs4QFfPzuT4V3xHGNqWdFfYUA)(QtSAoyCcla80uOf8FqRbXdTkuaTOoiijwnhmo5a6kmjMTVIdvYtia0lUhkRux9RWKy2(kSAoy8vKMr1I)EFX9q5A)v)ksZOAXFVVcbpHGh(kttwGPnYEgGnK8)uO1eqRRxHjXS9viSwNzsmBN1dnUIEOrUza5katmgCmBFX9WuxV6xrAgvl(79vi4je8WxHcs06CWydjOPOYP9cot0miO1eFqBTUctIz7RGD6mtIz7SEOXv0dnYndixHx5I7HPkF1VI0mQw837RWKy2(kewRZmjMTZ6Hgxrp0i3mGCfACXfxbewilakhx97HYx9RWKy2(kOCeAjtRwN4ksZOAXFVV4Ey6v)ksZOAXFVVsZaYvytsRymtZiBh5fjdAFj4RWKy2(kSjPvmMPzKTJ8IKbTVe8f3JAD1VctIz7R8AXAVAz6mwOBZnrUI0mQw837lUhU8QFfMeZ2xbqawCn5fjRDiJp7XcdqVI0mQw837lUh)F1VctIz7RaAJz7RinJQf)9(IlUcWeJbhZ2x97HYx9RinJQf)9(ke8ecE4RmnzbM2i7za2qY)tVctIz7Rmg9ILmiE6lUhME1VI0mQw837RqWti4HVcyH2NcTbRLosORMgcojnJQfp0Qqb0(uOf1bbjPzAKPb3(KdiOfmq7ZqlyHwsfJneAgbZKy2M1qRjGwLtkf0Qqb0onzbM2i7za2qY)tHwWCfMeZ2xHwnI2Nr1lXSlUh16QFfPzuT4V3xHGNqWdFfWcTbJnKi9AIQPv2vOvHcOLjXOwYslaJqHwtaTkdTGbAFgAbl0cwODAYcmTr2ZaSHK)NcTMaADnP8)qRsgARewhvja(jGwfkG2kH1rvcejGwWdT1YvOfmqRcfqlyH2NcTbRLosO7cmTrw9oejjnJQfp0Qqb0IzdjbWpb0(xOfZgc0cEO1LUcTGbAbZvysmBFfVaSywpMCAJmTADIlUhU8QFfPzuT4V3xHGNqWdFLPjlW0gzpdWgsUwuO1eqBLW6OcAFgAj7Q97RoX9aW5fj7foQsybGNMcTG)dAn9kmjMTVIMPrMgC7V4E8)v)ksZOAXFVVcbpHGh(kttwGPnYEgGnK8)uO1eqBLW6OcAvOaARewhvjqKaAbp0AQRxHjXS9vOvJO95xSwFXfxHgx97HYx9RinJQf)9(ke8ecE4RqbjADoySHe0uu50EbNjAge0(bTMcTpdTbRLosonnwqGyuTKrwmrssZOAXdTpdTOoiijwnhmo5a6kmjMTVsu50EbNjAg0f3dtV6xrAgvl(79vi4je8WxHSR2VV6eTAeTpt1mqclSVgO9zOf1bbjrRgr7ZO6LywYVVAO9zOLuXydHcTFqRPxHjXS9vOvJO9zu9sm7I7rTU6xHjXS9vOvJO9zQMbUI0mQw837lUhU8QFfPzuT4V3xHGNqWdFfWcTbRLosonnwqGyuTKrwmrssZOAXdTpdTOoiijwnhmo5acAbZvysmBFLOYP9cot0mOlUh)F1VI0mQw837RqWti4HVsWAPJe6UatBKvVdrssZOAXFfMeZ2xXlalM1JjN2itRwN4I7XFC1VI0mQw837RWKy2(kmTsn3cnJztU4mzXS(ke8ecE4R4fuheKeMn5IZKfZ6SxqDqqs0GjMbTFqRRxPza5kmTsn3cnJztU4mzXS(I7Hs4QFfPzuT4V3xHjXS9vyALAUfAgZMCXzYIz9vi4je8WxXlOoiijmBYfNjlM1zVG6GGKObtmdAnb0QeG2NHwWcTKD1(9vNy1CW4ewa4PPql4H2)HwfkGwuheKeRMdgNCabTG5kndixHPvQ5wOzmBYfNjlM1xCpuQR(vysmBFfpMn2oJxgFfPzuT4V3xCpQ9x9RWKy2(krLt7fCMOzqxrAgvl(79f3dLD9QFfPzuT4V3xHGNqWdFfuheKewulTHKCabTkuaTpfAJ1WqljVGinDuluOvHcOf1bbjng9ILmiE6KdiOvHcOfSqlQdcsIwnI2Nr1lXSewa4PPqRcfqlzxTFF1jA1iAFgvVeZsKkgBi0mcMjXSnRHwWdTUMukOfmxHjXS9vWIAPnKlUhkR8v)ksZOAXFVVctIz7RyG32GMbHhawNXSHCfcEcbp8vqDqqsSAoyCYVVAOvHcOLSR2VV6eTAeTpt1mqcla80uO1eFqRlVsZaYvmWBBqZGWdaRZy2qU4EOSPx9RWKy2(kywnBi4RinJQf)9(I7HY16QFfMeZ2xr9qIfxtg7qRUI0mQw837lUhk7YR(vysmBFLbaK0(PnYQhsS4AUI0mQw837lUhk))v)kmjMTVIxuZ0Gd5ksZOAXFVV4IRWRC1VhkF1VctIz7RevoTxWzIMbDfPzuT4V3xCpm9QFfPzuT4V3xHGNqWdFLG1shj0DbM2iREhIKKMr1I)kmjMTVIxawmRhtoTrMwToXf3JAD1VI0mQw837RqWti4HVczxTFF1jA1iAFMQzGewyFnq7ZqlQdcsIwnI2Nr1lXSKFF1q7ZqlQdcscqawCn5fjRDiJp7XcdqtoGUctIz7RqRgr7ZO6Ly2f3dxE1VI0mQw837RqWti4HVcQdcscqawCn5fjRDiJp7XcdqtoGUctIz7RqRgr7ZundCX94)R(vysmBFfpMn2oJxgFfPzuT4V3xCp(JR(vKMr1I)EFfcEcbp8vqDqqsyrT0gsYbe0Qqb0(uOnwddTK8cI00rTqHwfkGwuheK0y0lwYG4PtoGGwfkGwWcTOoiijA1iAFgvVeZsybGNMcTkuaTKD1(9vNOvJO9zu9smlrQySHqZiyMeZ2SgAbp06AsPGwWCfMeZ2xblQL2qU4EOeU6xrAgvl(79vysmBFfd82g0mi8aW6mMnKRqWti4HVcQdcsIvZbJt(9vdTkuaTKD1(9vNIkN2l4mrZGsybGNMcTM4dAD5vAgqUIbEBdAgeEayDgZgYf3dL6QFfMeZ2xbZQzdbFfPzuT4V3xCpQ9x9RinJQf)9(ke8ecE4Rq2v73xDIwnI2NPAgiHf2xd0(m0I6GGKOvJO9zu9sml53xn0(m0sQySHqH2pO10RWKy2(k0Qr0(mQEjMDX9qzxV6xHjXS9vOvJO9zQMbUI0mQw837lUhkR8v)kmjMTVI6HelUMm2HwDfPzuT4V3xCpu20R(vysmBFLbaK0(PnYQhsS4AUI0mQw837lUhkxRR(vysmBFfVOMPbhYvKMr1I)EFXfxCXf3b]] )


end
