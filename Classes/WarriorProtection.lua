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


    spec:RegisterPack( "Protection Warrior", 20190310.0131, [[dquCAaqifH8iuvAtOQAuaPofuWQuLKxPOAwkIUfQISlf(ffzykkhdiwgu0ZasMguixtvOTPkH(gQIY4GcLZPiyDQskZdvf3dO2NQGdQiulur6HQsWfrvu5KIG0kHsZuvsLBcfQ2PiAOIG6Pu1uPOUkQIQ(Qii2RWFvvdwkhgzXaEmktwuxMyZI0NrLrtHtlz1QsQ61OknBq3gQ2Ts)wLHlvwoLEovMoPRlvTDvP(Ui04vLOZlcSEufMVQO9d5aKWC4ZKkrsmNbYeMbkqMnMbcOazgMHxtqNe(oIXlXjHFjCj8jS9uHP1TOwcHS26SHVJsa8OCyo8UR3YKWBOAN71mzIRuJEGb7Wn5k8EiP1TmlLQMCfoZu4b6lOMq3ai8zsLijMZazcZafiZgZabuZECcH31jSijpduH3OYzzdGWNfhl88f1sy7PctRBrTeczT1zry5lQzOAN71mzIRuJEGb7Wn5k8EiP1TmlLQMCfodHLVOggNSmdudKztIAyodKjGA8eQndKxdZjGWIWYxu7fmOLtCiS8f14juBIZzudJxAXrADlQbpUIHA6HARKiQ5l8xa1M4e(1ncFN9slOeE(IAjS9uHP1TOwcHS26SiS8f1muTZ9AMmXvQrpWGD4MCfEpK06wMLsvtUcNHWYxudJtwMbQbYSjrnmNbYeqnEc1MbYRH5eqyry5lQ9cg0Yjoew(IA8eQnX5mQHXlT4iTUf1GhxXqn9qTvse18f(lGAtCc)6giSiS8f145EPW6vjJAas6zfuJD4aKIAacxTUbQnXmM0PouBVLNmilEApe1iMw36qTBHjyGWsmTU1n6Sc7WbifCkKC8IWsmTU1n6Sc7WbiDoytP3LryjMw36gDwHD4aKohSjQNdxwL06wew(IA(L6CgNIAwQYOgqFAQKrnNsQd1aK0ZkOg7Wbif1aeUADOgTzuRZk8u3PATCOw5qT8TYaHLyADRB0zf2Hdq6CWMaivHY3zC9kclX06w3OZkSdhG05Gn5wQZzC63PK6qyjMw36gDwHD4aKohSPUtRBryry5lQXZ9sH1Rsg1K3InbOMw4cQPgcQrm9SOw5qn6nvqcakdewIP1ToW1QILjDkclX06w3CWM66XXficlX06w3CWM6DYVubFYLWfWwcVRwUpH3blTplFUIJEFq9llxTcclX06w3CWM6DYVub3HWsmTU1nhSja4D5FAVnbiSetRBDZbBcqSoXYBTCiSetRBDZbBISmALVEwRSkclX06w3CWMGfNH6(V((mhUSkclX06w3CWMslRaaVlJWsmTU1nhSjAzItTe8ZiieHLyADRBoytDNw3ozLcgOpnDqVjLSJ(UNpvYYj6qlC5R3pxcFW8rew(IA88ob1sOC7zfulHPArn9qn69vzuZsCcQXOUUA5giSetRBDZbBQ42Zk)oQ2jRuWwItgzjTyLYhmFCoMZELsqz1bWD41Y9FFftgYsaqj)k2DW8L4oYc(zjyXJA5(oJRxhwHYjaHLyADRBoyt0BsjlclX06w3CWMyee(jMw3(HLtNCjCbmEPfhP1TtwPGRLD41Y9ZeoXj)hDpmdHLyADRBoyt2(9tmTU9dlNo5s4cy6KjRuWUobc)kz5e1nuJ(nl2pdsDpaguiSetRBDZbBIrq4NyAD7hwoDYLWfWofHfHLyADRBGxAXrADlyNrjW8haEmENSsbd6jsjOS6a4GovSdzjaOKF(CIa6tthqYPFNsBE03Hb(bnZGSCI7NAjMw3sWhazGXE(Sw2Hxl3pt4eN8F09WSbMVYqiOAmWPxIbewIP1TUbEPfhP1TZbBQ42Zk)oQ2jRuWa9PPdNrjW8haEmEh5lXLFG(00rXTNv(DuTJ8L4YpOTeNm6y6dtaZNpbTHqq1y0Xu(aQzpFwl7WRL7NjCIt(p6Ey2aZxzieung40lXagqyjMw36g4LwCKw3ohSPSGFwcw8OwUVZ461jRuWGwjlNOJel1OwqM98jX06T8LvWlX9aiyGFqd6AzhETC)mHtCY)r3dZgy(kdHGQXaNE5ZNgcbvJrht5dOMHHNpb9ePeuwDaChETC)3xXKHSeauYpFAjozGtVKNSeNWhmAggWaclX06w3aV0IJ0625GnbjN(DkT5jRuWgcbvJrht5dOMHWsmTU1nWlT4iTUDoytoJsG5FIeeozLcUw2Hxl3pt4eN8F09GHqq145tdHGQXOJP8bZziSiSetRBDdNohSj1OFZI9ZGu3KvkyxNaHFLSCI6gQr)Mf7NbPoWyYVsqz1r)60RRJaGYp9SmzilbaLm)a9PPd6nPKD03HWsmTU1nC6CWMCgLaZFa4X4DYkfm7oy(sChoJsG5Vds4dRq5eWpqFA6Wzucm)bGhJ3r(sC5N4HylvgawIj)0Z(l8oIPdlT8(aXdXwQmYcLkBTCFMLCgdlT8YpqFA6GEtkzh9DiSetRBDdNohSjNrjW83bj8jRuWepeBPYaWsm5NE2FH3rmDyPL3hiEi2sLrwOuzRL7ZSKZyyPLx(b6tth0Bsj7OVJFG(00HZOey(dapgVJ(oewIP1TUHtNd2KA0VzX(zqQBYkfmOvckRo6xNEDDeau(PNLjdzjaOK5hOpnDqVjLSJ(omGWsmTU1nC6CWMYc(zjyXJA5(oJRxNSsbReuwDaChETC)3xXKHSeauYiSetRBDdNohSjNrjW8haEmENSsbZUdMVe3HZOey(7Ge(Wkuob8d0NMoCgLaZFa4X4DKVexewIP1TUHtNd2KZOey(7GeoclX06w3WPZbBkBjUB)2JSiSetRBDdNohSj1OFZI9ZGuhclX06w3WPZbBYkVLLtqyjMw36goDoytw6nXjwewIP1TUHtNd2uwEtoLubHfHLyADRBqNmhSj1OFZI9ZGuhclX06w3Gozoytzb)SeS4rTCFNX1RtwPGvckRoaUdVwU)7RyYqwcakzewIP1TUbDYCWMYwI72V9ilclX06w3Gozoytw5TSCcclX06w3Gozoytw6nXjwewIP1TUbDYCWMCgLaZFa4X4DYkfm7oy(sChoJsG5Vds4dRq5eWpqFA6Wzucm)bGhJ3r(sCryjMw36g0jZbBYzucm)Dqcp8VfRRUnsI5mqMWmmNbYy2mmcZWNiz3A5CHpHI3DwvYO2JOgX06wudwo1nqydpSCQlmh(SKs9qnmhjbjmhEIP1THVwvSmPtdVSeauYX0qJKygMdpX062W31JJlWWllbaLCmn0ijOcZHxwcak5yA4xcxcVLW7QL7t4DWs7ZYNR4O3hu)YYvReEIP1TH3s4D1Y9j8oyP9z5ZvC07dQFz5QvcnsIrH5WtmTUn89o5xQG7cVSeauYX0qJKpgMdpX062WdaVl)t7Tji8Ysaqjhtdns(IH5WtmTUn8aI1jwERLl8YsaqjhtdnsYZcZHNyADB4jlJw5RN1kRgEzjaOKJPHgjXyH5WtmTUn8WIZqD)xFFMdxwn8YsaqjhtdnsoHWC4jMw3g(0YkaW7YHxwcak5yAOrsqMfMdpX062WtltCQLGFgbHHxwcak5yAOrsqajmhEzjaOKJPHNzlvSffEG(00b9MuYo67qTNprnLSCIo0cx(69ZLGA8b1W8XWtmTUn8DNw3gAKeemdZHxwcak5yA4z2sfBrH3sCYilPfRuuJpOgMpIAZrnmNHAVc1uckRoaUdVwU)7RyYqwcakzu7vOg7oy(sChzb)SeS4rTCFNX1RdRq5eeEIP1THV42Zk)oQ2qJKGaQWC4jMw3gE6nPKn8YsaqjhtdnsccgfMdVSeauYX0WZSLk2IcFTSdVwUFMWjo5)Od1Ea1MfEIP1THNrq4NyAD7hwon8WYP)LWLWJxAXrADBOrsqEmmhEzjaOKJPHNzlvSffExNaHFLSCI6gQr)Mf7NbPou7bWOgOcpX062WB73pX062pSCA4HLt)lHlHNoj0ijiVyyo8YsaqjhtdpX062WZii8tmTU9dlNgEy50)s4s4DAOHg(oRWoCasdZrsqcZHxwcak5yAOrsmdZHxwcak5yAOrsqfMdVSeauYX0qJKyuyo8etRBdpaPku(oJRxdVSeauYX0qJKpgMdVSeauYX0qJKVyyo8etRBdF3P1THxwcak5yAOHgE8slosRBdZrsqcZHxwcak5yA4z2sfBrHh0O2eHAkbLvhah0PIDilbaLmQ98jQnrOgqFA6aso97uAZJ(ouddOg)OgOrnMbz5e3p1smTULGO2dOgidmgQ98jQvl7WRL7NjCIt(p6qThqTzdmrTxHAgcbvJbo9suddHNyADB4DgLaZFa4X4n0ijMH5WllbaLCmn8mBPITOWd0NMoCgLaZFa4X4DKVexuJFudOpnDuC7zLFhv7iFjUOg)OgOrnlXjJoMIApGAtatu75tud0OMHqq1y0XuuJpOgOMHApFIA1Yo8A5(zcN4K)Jou7buB2atu7vOMHqq1yGtVe1WaQHHWtmTUn8f3Ew53r1gAKeuH5WllbaLCmn8mBPITOWdAutjlNOJel1OwqMHApFIAetR3YxwbVehQ9aQbcQHbuJFud0OgOrTAzhETC)mHtCY)rhQ9aQnBGjQ9kuZqiOAmWPxIApFIAgcbvJrhtrn(GAGAgQHbu75tud0O2eHAkbLvha3Hxl3)9vmzilbaLmQ98jQzjozGtVe14juZsCcQXhudJMHAya1Wq4jMw3g(SGFwcw8OwUVZ461qJKyuyo8YsaqjhtdpZwQylk8gcbvJrhtrn(GAGAw4jMw3gEi50VtPnhAK8XWC4LLaGsoMgEMTuXwu4RLD41Y9ZeoXj)hDO2dOMHqq1a1E(e1mecQgJoMIA8b1WCw4jMw3gENrjW8prccdn0W70WCKeKWC4LLaGsoMgEMTuXwu4DDce(vYYjQBOg9BwSFgK6qnWOgMOg)OMsqz1r)60RRJaGYp9SmzilbaLmQXpQb0NMoO3Ks2rFx4jMw3gE1OFZI9ZGuxOrsmdZHxwcak5yA4z2sfBrHNDhmFjUdNrjW83bj8HvOCcqn(rnG(00HZOey(dapgVJ8L4IA8JAepeBPYaWsm5NE2FH3rmDyPLxu7buJ4HylvgzHsLTwUpZsoJHLwErn(rnG(00b9MuYo67cpX062W7mkbM)aWJXBOrsqfMdVSeauYX0WZSLk2IcpXdXwQmaSet(PN9x4DethwA5f1Ea1iEi2sLrwOuzRL7ZSKZyyPLxuJFudOpnDqVjLSJ(ouJFudOpnD4mkbM)aWJX7OVl8etRBdVZOey(7GeEOrsmkmhEzjaOKJPHNzlvSffEqJAkbLvh9RtVUocak)0ZYKHSeauYOg)OgqFA6GEtkzh9DOggcpX062WRg9BwSFgK6cns(yyo8YsaqjhtdpZwQylk8kbLvha3Hxl3)9vmzilbaLC4jMw3g(SGFwcw8OwUVZ461qJKVyyo8YsaqjhtdpZwQylk8S7G5lXD4mkbM)oiHpScLtaQXpQb0NMoCgLaZFa4X4DKVe3WtmTUn8oJsG5pa8y8gAKKNfMdpX062W7mkbM)oiHhEzjaOKJPHgjXyH5WtmTUn8zlXD73EKn8YsaqjhtdnsoHWC4jMw3gE1OFZI9ZGux4LLaGsoMgAKeKzH5WtmTUn8w5TSCs4LLaGsoMgAKeeqcZHNyADB4T0BItSHxwcak5yAOrsqWmmhEIP1THplVjNsQeEzjaOKJPHgA4PtcZrsqcZHNyADB4vJ(nl2pdsDHxwcak5yAOrsmdZHxwcak5yA4z2sfBrHxjOS6a4o8A5(VVIjdzjaOKdpX062WNf8ZsWIh1Y9DgxVgAKeuH5WtmTUn8zlXD73EKn8YsaqjhtdnsIrH5WtmTUn8w5TSCs4LLaGsoMgAK8XWC4jMw3gEl9M4eB4LLaGsoMgAK8fdZHxwcak5yA4z2sfBrHNDhmFjUdNrjW83bj8HvOCcqn(rnG(00HZOey(dapgVJ8L4gEIP1TH3zucm)bGhJ3qJK8SWC4jMw3gENrjW83bj8WllbaLCmn0qdn8uVAC2W7l8EiP1TVGLs1qdnca]] )


end
