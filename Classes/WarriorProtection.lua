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


    spec:RegisterPack( "Protection Warrior", 20190401.1452, [[dCegEaqivb6riO2KcXNqvP0OuLYPuLQvHa1RuLmlbQBPkKDjYVeWWaOJbGLjiEgQkMMaX1uiTnuvPVPkughciNdbyDiqAEcKUhG2NG0brvjlur1drGyIOQu1frvPYhvfQ6KiGALOkZuvaUPQaYovOgkQQ4Pcnvb1vvfq9vvHk7vYFvvdMIddTyGEmHjlQltAZe5ZiA0e1PLA1OQu8AeQzJ0TrLDR0Vvz4ky5O8CknDQUUISDvrFhHmEvbDEeK1JQQMVIY(bDbqfUIz01ACiacabayqaeGeabz0qaGFROtObTIdOGyKuR4ICAf5h25QW7BHMhhYy9XQ4asi6H5kCfT3etOvu29blbnqaY2LNatIJlGT5MOO33kyOKhW2CIaveCQPobElWkMrxRXHaiaeaGbbqasaeKrdbWrRODqf14hJpvuUZzDlWkMvROIegA4h25QW7BHMhhYy9XG8im0i7(GLGgiaz7YtGjXXfW2Ctu07BfmuYdyBobKhHHg(AG1uObGGHMqaeacaAEe0aibqqbKFH8G8im0qqKXLuTqEegAEe0Wx5m08a1EtIEFl0qpYwan(bnRse0eBocc0Wx8Zdib5ryO5rqdFVsrcbnoRxIv3cnVPpuOdo084z3sY3AFhAKog0WxprhzjipcdnpcAEanPSRl0eLBLMHM50tqm0GBgAiWK7XuOHFWEHMmYHKk00RJeRqZB4MHMCljPmD9gDfAgKjKTfinahs2cOjJCiP(EQIdStQPAfjm0WpSZvH33cnpoKX6Jb5ryOr29blbnqaY2LNatIJlGT5MOO33kyOKhW2Ccipcdn81aRPqdabdnHaiaea08iObqcGGci)c5b5ryOHGiJlPAH8im08iOHVYzO5bQ9Me9(wOHEKTaA8dAwLiOj2CeeOHV4NhqcYJWqZJGg(ELIecACwVeRUfAEtFOqhCO5XZULKV1(o0iDmOHVEIoYsqEegAEe08aAszxxOjk3kndnZPNGyOb3m0qGj3JPqd)G9cnzKdjvOPxhjwHM3Wndn5wssz66n6k0mitiBlqAaoKSfqtg5qs99eKhKhHHg(UhQIjxZqdOkDmfAehhi6qdOs2Rnbn8LqOdUfA2BFKmY4KMOqdk8(wl0ClLqjipu49T20atfhhi6aLOOLyipu49T20atfhhi6Vagq6UmKhk8(wBAGPIJde9xadGtKC66O33c5ryOjU4Gv(COHHDgAaNKK0m0yD0TqdOkDmfAehhi6qdOs2RfAWndndm9rdN79scnTfAY3Qjipu49T20atfhhi6VagaeDNQFR8n5qEOW7BTPbMkooq0FbmGDXbR85FRJUfYdfEFRnnWuXXbI(lGbgoVVfYdYJWqdF3dvXKRzOrFQmcbnEZPqJlRqdk8JbnTfAWNytrqQMG8qH33Ab2RRmHo4qEOW7BTVagyyIJtPqEOW7BTVagyYQ)2voBWTeqWjjPe(eDKLMgMntChnFeTj8j6ilXuoSxBOHaiKhk8(w7lGbMS6VDLl4f5uGKSBjT)bwZH0pdj1GBjGGtssj8j6ilLpIwipu49T2xadasVl)LMyecYdfEFR9fWaGkZQmI7LeYdfEFR9fWaitGR(9JX01H8qH33AFbmaTjLD7NVzktYPRd5HcVV1(cyaPMPG07YqEOW7BTVagaxHADgs)cKsH8qH33AFbmWW59Tb3sabNKKs4t0rwAAy2mhzKQN8Mt)(9ZTg0qgfYJWqZdSvHgcm5EmfA4hSxOXpObFEDgAyiPcncCyOxYeKhk8(w7lGbAY9y6Fa7n4wcidj1uwLAr7bnKrFfcGeSJuD9e4DC9s(FETqt6IGuntWI7O5JOnLvUJH0M)9s(TY3KNykMjeKhk8(w7lGbWNOJmipu49T2xadiqk9JcVV9tBRh8ICkqU2Bs07BdULa2R446L8NroKu)JAdfqipu49T2xadWM2pk8(2pTTEWlYPaXtdULaAhuk97iJuDBYLN2SY(ckoekq(a5HcVV1(cyabsPFu49TFAB9GxKtbADipipu49T2ex7nj69TaTYTsZFq6jio4wc4BpOJuD9e4rTUYs6IGunpB2dcojjLOO1)wh3CAA49rEtiJms1(LyOW7BrAOaKiqZM1R446L8pitiBlq6FuBOaMaGGLvK6Yjo8HVd5HcVV1M4AVjrVV9fWan5Em9pG9gClbeCsskzLBLM)G0tqCkFeTJaojjLAY9y6Fa7nLpI2rEJHKAAq4HsaHmB2BYksD50GWdkFaC2SEfhxVKFoKSf)rTHcycacwwrQlN4Wh((7qEOW7BTjU2Bs07BFbmqw5ogsB(3l53kFtEWTeW3CKrQEIO2L7faaNndfE)u)6QCTAdfG3h5T36vCC9s(ZihsQ)rTHcycGrjyzfPUCIdF4SzYksD50GWdkFa89zZE7bDKQRNaVJRxY)ZRfAsxeKQ5zZyiPM4Wh(igsQbnia((7qEOW7BTjU2Bs07BFbmafT(364MdULakRi1LtdcpO8bqipu49T2ex7nj69TVagWk3kn)jcP0GBjG9koUEj)zKdj1)O2qLvK6YZMjRi1LtdcpOHaiKhKhk8(wBY6VagWLN2SY(ckoeClb0oOu63rgP62KlpTzL9fuCayiJ4ivxpnTw)ggqqQ(LoMqt6IGunpc4KKucFIoYstdqEOW7BTjR)cyaRCR08hKEcIdULakUJMpI2KvUvA(BPixIPyMqJaojjLSYTsZFq6jioLpI2rq(RS21eidf6x6y)MBafEIHlXHI8xzTRPSIs62l5xWqRCIHlXJaojjLWNOJS00aKhk8(wBY6VagWk3kn)TuKl4wciYFL1UMazOq)sh73CdOWtmCjouK)kRDnLvus3Ej)cgALtmCjEeWjjPe(eDKLMggbCsskzLBLM)G0tqCAAaYdfEFRnz9xad4YtBwzFbfhcULa(MJuD900A9ByabP6x6ycnPlcs18iGtssj8j6ilnn8oKhk8(wBY6VagiRChdPn)7L8BLVjp4wcOJuD9e4DC9s(FETqt6IGund5HcVV1MS(lGbSYTsZFq6jio4wcO4oA(iAtw5wP5VLICjMIzcnc4KKuYk3kn)bPNG4u(iAH8qH33Atw)fWaw5wP5VLICqEOW7BTjR)cyGmdjV9ZoKb5HcVV1MS(lGbC5PnRSVGIdqEOW7BTjR)cyaM(uxsfYdfEFRnz9xadmz1F7kxWlYPajz3sA)dSMdPFgsQb3sabNKKs4t0rwkFeTZMjUJMpI2KvUvA(BPixIPCyV2qbgeipu49T2K1FbmadFIKkdYdfEFRnz9xadK1NO1rxH8G8qH33At4PVagWLN2SY(ckoa5HcVV1MWtFbmqw5ogsB(3l53kFtEWTeqhP66jW746L8)8AHM0fbPAgYdfEFRnHN(cyGmdjV9ZoKb5HcVV1MWtFbmatFQlPc5HcVV1MWtFbmWKv)TRCbViNcKKDlP9pWAoK(ziPgClbeCsskHprhzP8r0oBM4oA(iAtU80Mv2xqXHet5WETHcmiqEOW7BTj80xadWWNiPYG8qH33At4PVagWk3kn)bPNG4GBjGI7O5JOnzLBLM)wkYLykMj0iGtssjRCR08hKEcIt5JOfYdfEFRnHN(cyaRCR083srUk(uz2(2ACiacabaiFa4XsHaiFESkseY2EjTvKaZnCmxZqZOqdk8(wOH2w3MG8QiTTUTcxXSkHtuVcxJbOcxru49TvSxxzcDWROUiivZ18YRXHuHRik8(2komXXP0kQlcs1CnV8AmFQWvuxeKQ5AEffS2vwJveCsskHprhzPPbOz2mOrChnFeTj8j6ilXuoSxl0ek0ecGvefEFBfNS6VDLZwEnoiv4kQlcs1CnVIOW7BRij7ws7FG1Ci9ZqsTIcw7kRXkcojjLWNOJSu(iAR4ICAfjz3sA)dSMdPFgsQLxJhTcxru49TveKEx(lnXiuf1fbPAUMxEnMFRWvefEFBfbvMvze3lzf1fbPAUMxEn(XQWvefEFBfrMax97hJPRxrDrqQMR5LxJjqv4kIcVVTI0Mu2TF(MPmjNUEf1fbPAUMxEnMaQWvefEFBfLAMcsVlxrDrqQMR5LxJbaWkCfrH33wrCfQ1zi9lqkTI6IGunxZlVgdaav4kQlcs1CnVIcw7kRXkcojjLWNOJS00a0mBg04iJu9K3C63VFUvOjOqtiJwru49TvC48(2YRXaesfUI6IGunxZROG1UYASImKutzvQfTdnbfAczuO5f0ecGqdbdnos11tG3X1l5)51cnPlcs1m0qWqJ4oA(iAtzL7yiT5FVKFR8n5jMIzcvru49TvSj3JP)bS3YRXaWNkCfrH33wr8j6iRI6IGunxZlVgdqqQWvuxeKQ5AEffS2vwJvSxXX1l5pJCiP(h1cnHcnawru49TvuGu6hfEF7N2wVI026)f50kY1EtIEFB51yagTcxrDrqQMR5vuWAxznwr7GsPFhzKQBtU80Mv2xqXbOjuGqdFQik8(2kYM2pk8(2pTTEfPT1)lYPvepT8Ama8BfUI6IGunxZRik8(2kkqk9JcVV9tBRxrAB9)ICAfTE5LxXbMkooq0RW1yaQWvuxeKQ5AE514qQWvuxeKQ5AE51y(uHROUiivZ18YRXbPcxru49TveeDNQFR8n5vuxeKQ5AE514rRWvuxeKQ5AE51y(Tcxru49TvC48(2kQlcs1CnV8YRix7nj69Tv4Amav4kQlcs1CnVIcw7kRXk(g08GqJJuD9e4rTUYs6IGundnZMbnpi0aojjLOO1)wh3CAAaAEhAgbAEdAeYiJuTFjgk8(wKcnHcnaKiqqZSzqtVIJRxY)GmHSTaP)rTqtOqdGjaGgcgAKvK6Yjo8HqZ7vefEFBfTYTsZFq6jiU8ACiv4kQlcs1CnVIcw7kRXkcojjLSYTsZFq6jioLpIwOzeObCssk1K7X0)a2BkFeTqZiqZBqddj10GWHMqHgcieOz2mO5nOrwrQlNgeo0euOHpacnZMbn9koUEj)Cizl(JAHMqHgataanem0iRi1LtC4dHM3HM3Rik8(2k2K7X0)a2B51y(uHROUiivZ18kkyTRSgR4BqJJms1te1UCVaai0mBg0GcVFQFDvUwTqtOqdaqZ7qZiqZBqZBqtVIJRxYFg5qs9pQfAcfAambWOqdbdnYksD5eh(qOz2mOrwrQlNgeo0euOHpacnVdnZMbnVbnpi04ivxpbEhxVK)Nxl0KUiivZqZSzqddj1eh(qO5rqddjvOjOqtqaeAEhAEVIOW7BRyw5ogsB(3l53kFtE514GuHROUiivZ18kkyTRSgROSIuxoniCOjOqdFaSIOW7BRifT(364MlVgpAfUI6IGunxZROG1UYASI9koUEj)zKdj1)OwOjuOrwrQldnZMbnYksD50GWHMGcnHayfrH33wrRCR08NiKslV8kA9kCngGkCf1fbPAUMxrbRDL1yfTdkL(DKrQUn5YtBwzFbfhGgGqtiqZiqJJuD900A9ByabP6x6ycnPlcs1m0mc0aojjLWNOJS00qfrH33wrxEAZk7lO4q514qQWvuxeKQ5AEffS2vwJvuChnFeTjRCR083srUetXmHGMrGgWjjPKvUvA(dspbXP8r0cnJani)vw7AcKHc9lDSFZnGcpXWLyOjuOb5VYAxtzfL0TxYVGHw5edxIHMrGgWjjPe(eDKLMgQik8(2kALBLM)G0tqC51y(uHROUiivZ18kkyTRSgRiYFL1UMazOq)sh73CdOWtmCjgAcfAq(RS21uwrjD7L8lyOvoXWLyOzeObCsskHprhzPPbOzeObCsskzLBLM)G0tqCAAOIOW7BROvUvA(BPix514GuHROUiivZ18kkyTRSgR4BqJJuD900A9ByabP6x6ycnPlcs1m0mc0aojjLWNOJS00a08EfrH33wrxEAZk7lO4q514rRWvuxeKQ5AEffS2vwJv0rQUEc8oUEj)pVwOjDrqQMRik8(2kMvUJH0M)9s(TY3KxEnMFRWvuxeKQ5AEffS2vwJvuChnFeTjRCR083srUetXmHGMrGgWjjPKvUvA(dspbXP8r0wru49Tv0k3kn)bPNG4YRXpwfUIOW7BROvUvA(BPixf1fbPAUMxEnMavHRik8(2kMzi5TF2HSkQlcs1CnV8AmbuHRik8(2k6YtBwzFbfhQOUiivZ18YRXaayfUIOW7BRitFQlPwrDrqQMR5LxJbaGkCf1fbPAUMxru49TvKKDlP9pWAoK(ziPwrbRDL1yfbNKKs4t0rwkFeTqZSzqJ4oA(iAtw5wP5VLICjMYH9AHMqbcnbPIlYPvKKDlP9pWAoK(ziPwEngGqQWvefEFBfz4tKuzvuxeKQ5AE51ya4tfUIOW7BRywFIwhDTI6IGunxZlV8kINwHRXauHRik8(2k6YtBwzFbfhQOUiivZ18YRXHuHROUiivZ18kkyTRSgROJuD9e4DC9s(FETqt6IGunxru49TvmRChdPn)7L8BLVjV8AmFQWvefEFBfZmK82p7qwf1fbPAUMxEnoiv4kIcVVTIm9PUKAf1fbPAUMxEnE0kCf1fbPAUMxru49TvKKDlP9pWAoK(ziPwrbRDL1yfbNKKs4t0rwkFeTqZSzqJ4oA(iAtU80Mv2xqXHet5WETqtOaHMGuXf50ksYUL0(hynhs)mKulVgZVv4kIcVVTIm8jsQSkQlcs1CnV8A8JvHROUiivZ18kkyTRSgRO4oA(iAtw5wP5VLICjMIzcbnJanGtssjRCR08hKEcIt5JOTIOW7BROvUvA(dspbXLxJjqv4kIcVVTIw5wP5VLICvuxeKQ5AE5LxEfXjx(yvm2Ctu07BjimuYlV8Qa]] )


end
