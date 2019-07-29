-- WarriorFury.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 72 )

    local base_rage_gen, fury_rage_mult = 1.75, 1.00
    local offhand_mod = 0.50

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand_fury = {
            -- setting = "forecast_fury",

            last = function ()
                local swing = state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = "mainhand_speed",

            stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * ( base_rage_gen * fury_rage_mult * state.swings.mainhand_speed / state.haste )
            end
        },

        offhand_fury = {
            -- setting = 'forecast_fury',

            last = function ()
                local swing = state.swings.offhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed )
            end,

            interval = 'offhand_speed',

            stop = function () return state.time == 0 or state.swings.offhand == 0 end,
            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.mainhand_speed * offhand_mod / state.haste
            end,
        },

        bladestorm = {
            aura = "bladestorm",

            last = function ()
                local app = state.buff.bladestorm.applied
                local t = state.query_time

                return app + ( floor( ( t - app ) / ( 1 * state.haste ) ) * ( 1 * state.haste ) )
            end,

            interval = function () return 1 * state.haste end,

            value = 5,
        }
    } )

    -- Talents
    spec:RegisterTalents( {
        war_machine = 22632, -- 262231
        endless_rage = 22633, -- 202296
        fresh_meat = 22491, -- 215568

        double_time = 19676, -- 103827
        impending_victory = 22625, -- 202168
        storm_bolt = 23093, -- 107570

        inner_rage = 22379, -- 215573
        sudden_death = 22381, -- 280721
        furious_slash = 23372, -- 100130

        furious_charge = 23097, -- 202224
        bounding_stride = 22627, -- 202163
        warpaint = 22382, -- 208154

        carnage = 22383, -- 202922
        massacre = 22393, -- 206315
        frothing_berserker = 19140, -- 215571

        meat_cleaver = 22396, -- 280392
        dragon_roar = 22398, -- 118000
        bladestorm = 22400, -- 46924

        reckless_abandon = 22405, -- 202751
        anger_management = 22402, -- 152278
        siegebreaker = 16037, -- 280772
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3592, -- 208683
        relentless = 3591, -- 196029
        adaptation = 3590, -- 214027

        death_wish = 179, -- 199261
        enduring_rage = 177, -- 198877
        thirst_for_battle = 172, -- 199202
        battle_trance = 170, -- 213857
        barbarian = 166, -- 280745
        slaughterhouse = 3735, -- 280747
        spell_reflection = 1929, -- 216890
        death_sentence = 25, -- 198500
        disarm = 3533, -- 236077
        master_and_commander = 3528, -- 235941
    } )


    local rageSpent = 0

    spec:RegisterHook( "spend", function( amt, resource )
        if talent.recklessness.enabled and resource == "rage" then
            rageSpent = rageSpent + amt
            cooldown.recklessness.expires = cooldown.recklessness.expires - floor( rageSpent / 20 )
            rageSpent = rageSpent % 20
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        rageSpent = 0
        if buff.bladestorm.up then
            setCooldown( "global_cooldown", max( cooldown.global_cooldown.remains, buff.bladestorm.remains ) )
            if buff.gathering_storm.up then
                applyBuff( "gathering_storm", buff.bladestorm.remains + 6, 5 )
            end
        end

    end )


    -- Auras
    spec:RegisterAuras( {
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
        bladestorm = {
            id = 46924,
            duration = function () return 4 * haste end,
            max_stack = 1,
        },
        bounding_stride = {
            id = 202164,
            duration = 3,
            max_stack = 1,
        },
        charge = {
            id = 105771,
            duration = 1,
            max_stack = 1,
        },
        dragon_roar = {
            id = 118000,
            duration = 6,
            max_stack = 1,
        },
        enrage = {
            id = 184362,
            duration = 4,
            max_stack = 1,
        },
        enraged_regeneration = {
            id = 184364,
            duration = 8,
            max_stack = 1,
        },
        frothing_berserker = {
            id = 215572,
            duration = 6,
            max_stack = 1,
        },
        furious_charge = {
            id = 202225,
            duration = 5,
            max_stack = 1,
        },
        furious_slash = {
            id = 202539,
            duration = 15,
            max_stack = 3,
        },
        intimidating_shout = {
            id = 5246,
            duration = 8,
            max_stack = 1,
        },
        piercing_howl = {
            id = 12323,
            duration = 15,
            max_stack = 1,
        },
        rallying_cry = {
            id = 97463,
            duration = 10,
            max_stack = 1,
        },
        recklessness = {
            id = 1719,
            duration = function () return talent.reckless_abandon.enabled and 14 or 10 end,
            max_stack = 1,
        },
        siegebreaker = {
            id = 280773,
            duration = 10,
            max_stack = 1,
        },
        sign_of_the_skirmisher = {
            id = 186401,
            duration = 3600,
            max_stack = 1,
        },
        storm_bolt = {
            id = 132169,
            duration = 4,
            max_stack = 1,
        },
        sudden_death = {
            id = 280776,
            duration = 10,
            max_stack = 1,
        },
        taunt = {
            id = 355,
            duration = 3,
            max_stack = 1,
        },
        victorious = {
            id = 32216,
            duration = 20,
        },
        whirlwind = {
            id = 85739,
            duration = 20,
            max_stack = 2,
            copy = "meat_cleaver"
        },


        -- Azerite Powers
        gathering_storm = {
            id = 273415,
            duration = 6,
            max_stack = 5,
        },

        -- Cold Steel, Hot Blood
        gushing_wound = {
            id = 288091,
            duration = 6,
            max_stack = 1,
        },

        intimidating_presence = {
            id = 288644,
            duration = 12,
            max_stack = 1,
        },
    } )


    spec:RegisterGear( 'tier20', 147187, 147188, 147189, 147190, 147191, 147192 )
        spec:RegisterAura( "raging_thirst", {
            id = 242300, 
            duration = 8
         } ) -- fury 2pc.
        spec:RegisterAura( "bloody_rage", {
            id = 242952,
            duration = 10,
            max_stack = 10
         } ) -- fury 4pc.

    spec:RegisterGear( 'tier21', 152178, 152179, 152180, 152181, 152182, 152183 )
        spec:RegisterAura( "slaughter", {
            id = 253384,
            duration = 4
        } ) -- fury 2pc dot.
        spec:RegisterAura( "outrage", {
            id = 253385,
            duration = 8
         } ) -- fury 4pc.

    spec:RegisterGear( "ceannar_charger", 137088 )
    spec:RegisterGear( "timeless_stratagem", 143728 )
    spec:RegisterGear( "kazzalax_fujiedas_fury", 137053 )
        spec:RegisterAura( "fujiedas_fury", {
            id = 207776,
            duration = 10,
            max_stack = 4 
        } )
    spec:RegisterGear( "mannoroths_bloodletting_manacles", 137107 ) -- NYI.
    spec:RegisterGear( "najentuss_vertebrae", 137087 )
    spec:RegisterGear( "valarjar_berserkers", 151824 )
    spec:RegisterGear( "ayalas_stone_heart", 137052 )
        spec:RegisterAura( "stone_heart", { id = 225947,
            duration = 10
        } )
    spec:RegisterGear( "the_great_storms_eye", 151823 )
        spec:RegisterAura( "tornados_eye", {
            id = 248142, 
            duration = 6, 
            max_stack = 6
        } )
    spec:RegisterGear( "archavons_heavy_hand", 137060 )
    spec:RegisterGear( "weight_of_the_earth", 137077 ) -- NYI.

    spec:RegisterGear( "soul_of_the_battlelord", 151650 )


    local function IsActiveSpell( id )
        local slot = FindSpellBookSlotBySpellID( id )
        if not slot then return false end

        local _, _, spellID = GetSpellBookItemName( slot, "spell" )
        return id == spellID 
    end

    state.IsActiveSpell = IsActiveSpell


    -- Abilities
    spec:RegisterAbilities( {
        battle_shout = {
            id = 6673,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = false,
            texture = 132333,

            essential = true,
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

            toggle = "cooldowns",

            startsCombat = false,
            texture = 136009,

            handler = function ()
                applyBuff( "berserker_rage" )
                if level < 116 and equipped.ceannar_charger then gain( 8, "rage" ) end
            end,
        },


        bladestorm = {
            id = 46924,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 236303,

            handler = function ()
                applyBuff( "bladestorm" )
                gain( 5, "rage" )
                setCooldown( "global_cooldown", 4 * haste )

                if level < 116 and equipped.the_great_storms_eye then addStack( "tornados_eye", 6, 1 ) end

                if azerite.gathering_storm.enabled then
                    applyBuff( "gathering_storm", 6 + ( 4 * haste ), 5 )
                end
            end,
        },


        bloodthirst = {
            id = 23881,
            cast = 0,
            cooldown = 4.5,
            hasteCD = true,
            gcd = "spell",

            spend = -8,
            spendType = "rage",

            startsCombat = true,
            texture = 136012,

            handler = function ()
                gain( health.max * ( buff.enraged_regeneration.up and 0.25 or 0.05 ) * ( talent.fresh_meat.enabled and 1.2 or 1 ), "health" )
                if level < 116 and equipped.kazzalax_fujiedas_fury then addStack( "fujiedas_fury", 10, 1 ) end
                removeBuff( "bloody_rage" )
                removeStack( "whirlwind" )
                if azerite.cold_steel_hot_blood.enabled and stat.crit >= 100 then
                    applyDebuff( "target", "gushing_wound" )
                    gain( 4, "rage" )
                end
            end,
        },


        charge = {
            id = 100,
            cast = 0,
            charges = function () return talent.double_time.enabled and 2 or nil end,
            cooldown = function () return talent.double_time.enabled and 17 or 20 end,
            recharge = function () return talent.double_time.enabled and 17 or 20 end,
            gcd = "spell",

            startsCombat = true,
            texture = 132337,

            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd.execute ) end,
            handler = function ()
                applyDebuff( "target", "charge" )
                if talent.furious_charge.enabled then applyBuff( "furious_charge" ) end
                setDistance( 5 )
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
            end,
        },


        enraged_regeneration = {
            id = 184364,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 132345,

            handler = function ()
                applyBuff( "enraged_regeneration" )
            end,
        },


        execute = {
            id = function () return IsActiveSpell( 280735 ) and 280735 or 5308 end,
            known = 5308,
            cast = 0,
            cooldown = 6,
            hasteCD = true,
            gcd = "spell",

            spend = -20,
            spendType = "rage",

            startsCombat = true,
            texture = 135358,

            usable = function () return buff.sudden_death.up or buff.stone_heart.up or target.health.pct < ( IsActiveSpell( 280735 ) and 35 or 20 ) end,
            handler = function ()
                if buff.stone_heart.up then removeBuff( "stone_heart" )
                elseif buff.sudden_death.up then removeBuff( "sudden_death" ) end
                removeStack( "whirlwind" )
            end,

            copy = { 280735, 5308 }
        },


        furious_slash = {
            id = 100130,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = -4,
            spendType = "rage",

            startsCombat = true,
            texture = 132367,

            talent = "furious_slash",

            recheck = function () return buff.furious_slash.remains - 9, buff.furious_slash.remains - 3, buff.furious_slash.remains, cooldown.recklessness.remains < 3, cooldown.recklessness.remains end,
            handler = function ()
                if buff.furious_slash.stack < 3 then stat.haste = stat.haste + 0.02 end
                addStack( "furious_slash", 15, 1 )
                removeStack( "whirlwind" )
            end,
        },


        heroic_leap = {
            id = 6544,
            cast = 0,
            charges = function () return ( level < 116 and equipped.timeless_stratagem ) and 3 or nil end,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            recharge = function () return talent.bounding_stride.enabled and 30 or 45 end,
            gcd = "spell",

            startsCombat = false,
            texture = 236171,

            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd.execute ) end,
            handler = function ()
                setDistance( 5 )
                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
            end,
        },


        heroic_throw = {
            id = 57755,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = true,
            texture = 132453,

            handler = function ()
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
                removeStack( "whirlwind" )
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
                if azerite.intimidating_presence.enabled then applyDebuff( "target", "intimidating_presence" ) end
            end,
        },


        piercing_howl = {
            id = 12323,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = 10,
            spendType = "rage",

            startsCombat = true,
            texture = 136147,

            handler = function ()
                applyDebuff( "target", "piercing_howl" )
            end,
        },


        pummel = {
            id = 6552,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = true,
            texture = 132938,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        raging_blow = {
            id = 85288,
            cast = 0,
            charges = 2,
            cooldown = function () return ( talent.inner_rage.enabled and 7 or 8 ) * haste end,
            recharge = function () return ( talent.inner_rage.enabled and 7 or 8 ) * haste end,
            gcd = "spell",

            spend = -12,
            spendType = "rage",

            startsCombat = true,
            texture = 589119,

            handler = function ()
                removeBuff( "raging_thirst" )
                if level < 116 and set_bonus.tier_21_4pc == 1 then addStack( "bloody_rage", 10, 1 ) end
                removeStack( "whirlwind" )
            end,
        },


        rallying_cry = {
            id = 97462,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "defensives",

            startsCombat = false,
            texture = 132351,

            handler = function ()
                applyBuff( "rallying_cry" )
            end,
        },


        rampage = {
            id = 184367,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if talent.carnage.enabled then return 75 end
                if talent.frothing_berserker.enabled then return 95 end
                return 85
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 132352,

            recheck = function () return rage.time_to_91, buff.enrage.remains - gcd, buff.enrage.remains, cooldown.recklessness.remains - 3, cooldown.recklessness.remains end,
            handler = function ()
                if not buff.enrage.up then
                    stat.haste = stat.haste + 0.25
                end

                applyBuff( "enrage" )
                if talent.endless_rage.enabled then gain( 6, "rage" ) end

                if level < 116 and set_bonus.tier21_2pc == 1 then applyDebuff( "target", "slaughter" ) end

                if talent.frothing_berserker.enabled then
                    if buff.frothing_berserker.down then stat.haste = stat.haste + 0.05 end
                    applyBuff( "frothing_berserker" )
                end
                removeStack( "whirlwind" )
            end,
        },


        recklessness = {
            id = 1719,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 90 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 458972,

            handler = function ()
                applyBuff( "recklessness" )
                if talent.reckless_abandon.enabled then gain( 100, "rage" ) end
            end,
        },


        siegebreaker = {
            id = 280772,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = -10,
            spendType = "rage",

            startsCombat = true,
            texture = 294382,

            talent = "siegebreaker",

            handler = function ()
                applyDebuff( "target", "siegebreaker" )
                removeStack( "whirlwind" )
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
                removeStack( "whirlwind" )
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


        victory_rush = {
            id = 34428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132342,

            notalent = "impending_victory",
            buff = "victorious",

            handler = function ()
                removeBuff( "victorious" )
                removeStack( "whirlwind" )
            end,
        },


        whirlwind = {
            id = 190411,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132369,

            handler = function ()
                applyBuff( "whirlwind", 20, 2 )

                if talent.meat_cleaver.enabled then
                    gain( 3 + min( 5, active_enemies ) + min( 3, active_enemies ), "rage" )
                else
                    gain( 3 + min( 5, active_enemies ), "rage" )
                end
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

        package = "Fury",
    } )


    spec:RegisterPack( "Fury", 20190729, [[dKe5FaqiQGhPOYMOs1OiKCkuv1RaLMfvk3cLODjQFrLmmQihdvLLrO6zkImncPCnfv12qjOVHsOXPikNdvvwNIqMNIG7HQSpQO6GkQYcfrpKku1ePcPUikbAJOeWijKkojvOyLOuZKku6MesvTtfPHsfIwkvOYtvyQIWvjKQSvcPsFLkKSxj)ffdMKdtzXk1JjAYu1Lr2Ss(mbJguDAvwTIO61kkZMu3gv2Tu)gy4I0XPcHLRQNdz6cxhKTJs67ekJxrOopHy9urz(GI9d1fFvIA4TGQPI7eF8ZjwuC(LDYj(yrXzH1iejLQrQjNzcunAJJQbla0lsnsnr0aZxjQbca9sQgWJifnrUCjCbCODwc4CHooiTfhOLVTcxOJt6QgBOthoMU21WBbvtf3j(4NtSO48l7Kt8XIIlEnmOao4RX44C8yLlSAEVe(Xf3dq1a(59ux7A4jKSgZHvSaqViyLJY()apM9Cyf8isrtKlxcxahANLaoxOJdsBXbA5BRWf64Ky2ZHvSH0IGvIZp3WkXDIp(HvSeRCYPjIV5JzJzphw54HBTaHMim75WkwIvZZ7jpw5iH44iDgZEoSILyLJ(q2wtESIdWkXrDGvUWkrh6bNeRCSKLIvstRXkr1GaRAI8KhRwGhRUMLcghHvsqh0eh8pJzphwXsSs0hWk5XQKAZtOa8CyL1ESYr)MaOXkhhWESY2awjSkPga8b87rbwfaS64sFaRewTEYrarTueScSWQNKaooQ9wCGgHvIcDCiS6bqcW1IGvKJaY08pJzphwXsSAEEp5XQKweAcRgWbqbwfaSk9jjGBBbwnphPJnJzphwXsSAEEp5Xkr3tgGxeSYXbHGJv2gWkHvORf0eld7fOaRCuWVxl21(mM9CyflXQ559KhRe9qew5ycIdLRH(qbQsud01cAIjSxGIkrnLVkrnmzCGUgOJeO9t2m6Rb12wt(kzf1uXRe1GABRjFLSgY)c6pRgIcR2qRv(j5mnHqnHqzOuScgyWQn0AL5ioWlcdyXOHKNNX)KXHYqPyf)XkyGbRefwfMM6iVEqa)AbMn9i6NrFMABRjpwbdmyvyAQJS0(2eOm12wtESYDSsuy1gATYu)MaLFIZUgHvtaReKEScgyWQ3eiSY5yf)CcR4pwbdmyvyAQJmNHqM8Pm12wtESYDSsuy1gATYu)MaLFIZUgHvtaReKEScgyWQ3eiSY5yf)CcR4pwX)AyY4aDnEJl1eOkQPtQsudtghORbnXKekOAqTT1KVswrnv0Qe1GABRjFLSgY)c6pRgoGvBO1kV1aGxdHImukw5owTHwR8c6paeIbPne88tC21iSAcy1KQHjJd01yb9hacXG0gcEf105xjQb12wt(kznK)f0FwnsFIvgbPpZx(nUutGQHjJd01yRnpHcWZvrnLfwjQb12wt(kznK)f0Fwn2qRvM63eOmuAnmzCGUg(3eanZdSVIAklwjQb12wt(kznK)f0Fwn2qRvM63eOShiwJvWadwzoJ(lOSeO9mOGindCqWS1aGp)wpdRCowXxnmzCGUgBna4d43JIkQPtwLOguBBn5RK1q(xq)z1qc3EbcHv8WkXRHjJd014nHRfy2AGyvut5xLOgMmoqxJTga8b87rrnO22AYxjROMYNtvIAqTT1KVswd5Fb9NvJW0uhzP9TjqzQTTM8yfmWGvIcRcttDK5meYKpLP22AYJvUJvVjqy1eWQjZjSI)yfmWGvIcRcttDKxpiGFTaZMEe9ZOptTT1KhRChREtGWQjGv8ZjSI)1WKXb6A8MW1cmBnqSkQP8XxLOguBBn5RK1q(xq)z1imn1rEb9hacXG0gcEMABRjFnmzCGUglO)aqigK2qWROMYN4vIAyY4aDny9Kb4fH5HqWRb12wt(kzf1u(MuLOgMmoqxJJlLA)1cmSEYa8IudQTTM8vYkQP8jAvIAyY4aDned(9AXU2xdQTTM8vYkQOgCawjoQJkrnLVkrnmzCGUgWPhCsgnzP1GABRjFLSIkQHNwgKoQe1u(Qe1WKXb6AiHBVavdQTTM8vYkQPIxjQHjJd01ifIJJ01GABRjFLSIA6KQe1GABRjFLSgY)c6pRgIcRE78meRuhzoaReh1r2FOWAjHvohReF(yL7y1BNNHyL6iZbyL4OoYxJvohReT5Jv8VgMmoqxd40dojJMS0kQPIwLOgMmoqxJuqCGUguBBn5RKvutNFLOguBBn5RK1q(xq)z1qcaApqSo)KCMMqOMqO8tC21iSAcy1KQHjJd014nUutGQOMYcRe1GABRjFLSgY)c6pRgBO1k)KCMMqOMqOmuAnmzCGUgBna4zalMaoXqnXjsf1uwSsudQTTM8vYAi)lO)SA4awTHwR8tYzAcHAcHYqPyL7yLdy1gATYOJeO9t2m6ZqP1WKXb6AKc93sKRfy2AdfvutNSkrnO22AYxjRH8VG(ZQHdy1gATYpjNPjeQjekdLIvUJvoGvBO1kJosG2pzZOpdLwdtghORXFPPAI5AguQjPkQP8RsudQTTM8vYAi)lO)SA4awTHwR8tYzAcHAcHYqPyL7yLdy1gATYOJeO9t2m6ZqP1WKXb6Aig41EwPRzEcbARLuf1u(CQsudQTTM8vYAi)lO)SA4awTHwR8tYzAcHAcHYqPyL7yLdy1gATYOJeO9t2m6ZqP1WKXb6ASasie5zmNr)feZMmUkQP8XxLOguBBn5RK1q(xq)z1WbSAdTw5NKZ0ec1ecLHsXk3XkhWQn0ALrhjq7NSz0NHsXk3XkpiYsqlPoElipZsBCeZg678tC21iSIhw5unmzCGUgsqlPoElipZsBCuf1u(eVsudQTTM8vYAi)lO)SASHwR8tYzAcHywGxszO0AyY4aDnc4eduVbqTNzbEjvrnLVjvjQb12wt(kznK)f0FwnCaR2qRv(j5mnHqnHqzO0AyY4aDneGS3FwZawmMZOheWROMYNOvjQb12wt(kznK)f0FwnCaR2qRv(j5mnHqnHqzO0AyY4aDn4ioWlcdyXOHKNNX)KXHQOMY38Re1GABRjFLSgY)c6pRgoGvecrTKYsq7PgrEg9TOf4LuMZMCWJvUJvoGvecrTKYBna4zalMaoXqnXjsMZMCWJvWadwjbaThiwNfGS3FwZawmMZOheWZpXzxJWkNJvI7ewbdmy1gATYcq27pRzalgZz0dc4zOuScgyWkjaO9aX68wdaEgWIjGtmutCIKFIZUgHvtaReK(AyY4aDnEsottiutiuf1u(yHvIAqTT1KVswd5Fb9NvdukP1mH9cuGYIb)ETyx7XkNJv8HvUJvoGvBO1kZrwWi1KXk9zO0AyY4aDned(9AXU2xrnLpwSsudQTTM8vYA0ghvJ34sVwGX4s1xa5jgHtWyfOdgQfUMQHjJd014nU0RfymUu9fqEIr4emwb6GHAHRPkQP8nzvIAyY4aDnGqeZfehQguBBn5RKvut5JFvIAyY4aDn2AaWZSGErQb12wt(kzf1uXDQsudtghORXMEe9ZUwOguBBn5RKvutfNVkrnO22AYxjRH8VG(ZQXgATYpjNPjeQjek7bI11WKXb6AOpb4bIzYH8cCuhvutfx8krnmzCGUgR7PTga81GABRjFLSIAQ4tQsudtghORH1scfVPzKMwxdQTTM8vYkQPIlAvIAqTT1KVswdtghORXd1mMmoqZOpuud9HcM24OAGUwqtmH9cuurf1i9jjGBBrLOMYxLOguBBn5RKvutfVsudQTTM8vYkQPtQsudQTTM8vYkQPIwLOgMmoqxJTfHMyqWbqrnO22AYxjROMo)krnO22AYxjRrBCunmNHGBVHywGoyalMuGy0xdtghORH5meC7neZc0bdyXKceJ(kQPSWkrnmzCGUgCeh4fHbSy0qYZZ4FY4q1GABRjFLSIAklwjQHjJd01qaYE)zndyXyoJEqaVguBBn5RKvutNSkrnmzCGUgpjNPjeQjeQguBBn5RKvut5xLOgMmoqxJuqCGUguBBn5RKvurf1Gv6rhORPI7eF8ZjwKpXZIpPjnPAiM991cOA4y4sbFqESs0WktghOXk9HcugZUgPpyDAQgZHvSaqViyLJY()apM9Cyf8isrtKlxcxahANLaoxOJdsBXbA5BRWf64Ky2ZHvSH0IGvIZp3WkXDIp(HvSeRCYPjIV5JzJzphw54HBTaHMim75WkwIvZZ7jpw5iH44iDgZEoSILyLJ(q2wtESIdWkXrDGvUWkrh6bNeRCSKLIvstRXkr1GaRAI8KhRwGhRUMLcghHvsqh0eh8pJzphwXsSs0hWk5XQKAZtOa8CyL1ESYr)MaOXkhhWESY2awjSkPga8b87rbwfaS64sFaRewTEYrarTueScSWQNKaooQ9wCGgHvIcDCiS6bqcW1IGvKJaY08pJzphwXsSAEEp5XQKweAcRgWbqbwfaSk9jjGBBbwnphPJnJzphwXsSAEEp5Xkr3tgGxeSYXbHGJv2gWkHvORf0eld7fOaRCuWVxl21(mM9CyflXQ559KhRe9qew5ycIdLXSXSNdRybNyscfKhR20c8ewjbCBlWQnjCnkJvZtkP0aHvnOzjC75wqASYKXbAewbATizmBtghOr50NKaUTf8wAdndZ2KXbAuo9jjGBBbS8CTaapMTjJd0OC6tsa32cy55YGe4OoS4anM9Cy1OTueCqGvVDESAdTwKhRqHfiSAtlWtyLeWTTaR2KW1iSYApwL(eltbrCTawDiSYdAkJzBY4ankN(KeWTTawEU2weAIbbhafy2MmoqJYPpjbCBlGLNlieXCbX5wBCepZzi42BiMfOdgWIjfig9y2MmoqJYPpjbCBlGLNloId8IWawmAi55z8pzCimBtghOr50NKaUTfWYZLaK9(ZAgWIXCg9GaoMTjJd0OC6tsa32cy556j5mnHqnHqy2MmoqJYPpjbCBlGLNRuqCGgZgZEoSIfCIjjuqESIyLErWQ44iSkGtyLjdWJvhcRmwTtBBnLXSnzCGgXtc3EbcZ2KXbAeS8CLcXXrAm75WQeWpewDiSIdGcTiyvaWQ0NyL6aRKaG2deRry16bCy1MUwaRmP88uhMwlcwbHipw5H(RfWkoaReh1rgZEoSYKXbAeS8C9qnJjJd0m6dfU1ghXJdWkXrD42T4XbyL4OoY(dfwljNpFmBtghOrWYZfC6bNKrtwQB3INOE78meRuhzoaReh1r2FOWAj5CXNV7VDEgIvQJmhGvIJ6iFTZfT5ZFmBtghOrWYZvkioqJzBY4ancwEUEJl1ei3UfpjaO9aX68tYzAcHAcHYpXzxJMWKWSnzCGgblpxBna4zalMaoXqnXjIB3I3gATYpjNPjeQjekdLIzBY4ancwEUsH(BjY1cmBTHc3Ufph2qRv(j5mnHqnHqzOu3DydTwz0rc0(jBg9zOumBtghOrWYZ1FPPAI5AguQjj3Ufph2qRv(j5mnHqnHqzOu3DydTwz0rc0(jBg9zOumBtghOrWYZLyGx7zLUM5jeOTwsUDlEoSHwR8tYzAcHAcHYqPU7WgATYOJeO9t2m6ZqPy2MmoqJGLNRfqcHipJ5m6VGy2KX52T45WgATYpjNPjeQjekdL6UdBO1kJosG2pzZOpdLIzBY4ancwEUKGwsD8wqEML24i3Ufph2qRv(j5mnHqnHqzOu3DydTwz0rc0(jBg9zOu39GilbTK64TG8mlTXrmBOVZpXzxJ45eMTjJd0iy55kGtmq9ga1EMf4LKB3I3gATYpjNPjeIzbEjLHsXSnzCGgblpxcq27pRzalgZz0dc4UDlEoSHwR8tYzAcHAcHYqPy2MmoqJGLNloId8IWawmAi55z8pzCi3Ufph2qRv(j5mnHqnHqzOumBtghOrWYZ1tYzAcHAcHC7w8CGqiQLuwcAp1iYZOVfTaVKYC2KdE3DGqiQLuERbapdyXeWjgQjorYC2KdEyGrcaApqSolazV)SMbSymNrpiGNFIZUg5CXDcgy2qRvwaYE)zndyXyoJEqapdLcdmsaq7bI15Tga8mGftaNyOM4ej)eNDnAccspMTjJd0iy55sm43Rf7AVB3IhkL0AMWEbkqzXGFVwSR9oNp3DydTwzoYcgPMmwPpdLIzBY4ancwEUGqeZfeNBTXr8EJl9AbgJlvFbKNyeobJvGoyOw4AcZ2KXbAeS8CbHiMlioeMTjJd0iy55ARbapZc6fbZ2KXbAeS8CTPhr)SRfWSnzCGgblpx6taEGyMCiVah1HB3I3gATYpjNPjeQjek7bI1y2MmoqJGLNR190wdaEmBtghOrWYZL1scfVPzKMwJzBY4ancwEUEOMXKXbAg9Hc3AJJ4HUwqtmH9cuGzJzBY4ankZbyL4Oo4bNEWjz0KLIzJzBY4ankJUwqtmH9cuWdDKaTFYMrpMTjJd0Om6AbnXe2lqbS8C9gxQjqUDlEIAdTw5NKZ0ec1ecLHsHbMn0AL5ioWlcdyXOHKNNX)KXHYqP8hgyevyAQJ86bb8Rfy20JOFg9zQTTM8WatyAQJS0(2eOm12wtE3f1gATYu)MaLFIZUgnbbPhgyEtGCo)CI)WatyAQJmNHqM8Pm12wtE3f1gATYu)MaLFIZUgnbbPhgyEtGCo)CI)8hZ2KXbAugDTGMyc7fOawEUOjMKqbHzBY4ankJUwqtmH9cualpxlO)aqigK2qWD7w8CydTw5Tga8AiuKHsDFdTw5f0FaiedsBi45N4SRrtysy2MmoqJYORf0etyVafWYZ1wBEcfGNZTBXl9jwzeK(mF534snbcZ2KXbAugDTGMyc7fOawEU8VjaAMhyVB3I3gATYu)MaLHsXSnzCGgLrxlOjMWEbkGLNRTga8b87rHB3I3gATYu)MaL9aXAyGXCg9xqzjq7zqbrAg4GGzRbaF(TEMZ5dZ2KXbAugDTGMyc7fOawEUEt4AbMTgiMB3INeU9ceIN4y2MmoqJYORf0etyVafWYZ1wda(a(9OaZ2KXbAugDTGMyc7fOawEUEt4AbMTgiMB3IxyAQJS0(2eOm12wtEyGruHPPoYCgczYNYuBBn5D)nbActMt8hgyevyAQJ86bb8Rfy20JOFg9zQTTM8U)Manb(5e)XSnzCGgLrxlOjMWEbkGLNRf0FaiedsBi4UDlEHPPoYlO)aqigK2qWZuBBn5XSnzCGgLrxlOjMWEbkGLNlwpzaEryEieCmBtghOrz01cAIjSxGcy5564sP2FTadRNmaViy2MmoqJYORf0etyVafWYZLyWVxl21(AGsjznLffVIkQca]] )
end
