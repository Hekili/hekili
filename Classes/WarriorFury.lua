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
        },

        battle_trance = {
            aura = "battle_trance",

            last = function ()
                local app = state.buff.battle_trance.applied
                local t = state.query_time

                return app + ( floor( ( t - app ) / state.haste ) * state.haste )
            end,

            interval = 3,

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


        -- PvP Talents
        battle_trance = {
            id = 213858,
            duration = 18,
            max_stack = 1
        }
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


    spec:RegisterPack( "Fury", 20200124, [[dKuLMaqiuPEeksBcvvJsvLofkWRqrnlsf3sOWUO0VeQggPOJHQYYiQ8muqMgQK6AcLABQQO(gkOmovvKZHIW6ifsZJuW9qf7tOOdIIOfQQ0djfctuvfYfjfQSrvvOgjPqXjfkPwjrzMQQa3KuO0ovv1qfkHLkuIEQuMQQIRsku1wjfI(QQkO9Q0FLQbtYHPAXQYJjmzrUm0Mf8zImAuLtdSAuj51KQMnf3gL2TIFJy4c54cLKLRYZbnDjxxuBhf67KknEuq15jQA9OsmFsP9J0lF7NTL8c3)YPPCAQjFYX1w(0uZyZq8TTs(iCBrUqVlHBBCwCB)48j)2IC5nepTF2gKKpbUnEvfb1OXJlbkE5NvqyJdbSzJxaYiopuXHawr8T9YatfRN9TTKx4(xonLttn5toU2YNMAgB5yyBZZfpYTTgGvJGQItvm5j4bylWrGBJhiLWzFBlHqX2ykv9JZN8u1p0VdqoQmMsv8QkcQrJhxcu8YpRGWghcyZgVaKrCEOIdbScQmMsvY8j7N8uLC8PdvjNMYPjvgvgtPkncE(iHqnkvgtPQyqvmzkHjQkwKzzrJLkJPuvmOQFea6pdMOkwcJilofvfNQ0yWJaeu1pa9iQs4gdv97qkQAqmHjQkqoQcmXqYzrQsqMcz4fdSuzmLQIbvPXsyetu1xJNqyrowQYNev9JoxImuvSK4hv5pcJiv91qiPIh4GfvveQcWgDegrQkCySkJJqEQIeOQdfewwCsEbidKQ(fcyHu1rYs8mYtvySk7ggyPYykvfdQIjtjmrvF9Qmiv14rYfvveQk6qbH95fvXKXIFGLkJPuvmOkMmLWevPrcef5KNQILzipQYFegrQccgjdgJYpjSOQFipWz0fmjlvgtPQyqvmzkHjQsJhIuvSUqwODBgaSG7NTbbJKb7LFsyTF2)8TF2Mlkaz2geGs47qxpEBdh)zW0(DR9VC7NTHJ)myA)UnXbk8a(2(LQE5qWEOqVbHWbHqBoIQ0QLQE5qWYISKt(oj0nzbi1th6SqBoIQyavPvlv9lvvUbNYgosXdms9hEq80JNfh)zWevPvlvvUbNYk8BCj0IJ)myIQ4NQ(LQE5qWIZ5sO9qwhmqQsduLKirvA1svNlHuvmPkMqtQIbuLwTuv5gCklRdHU4qlo(ZGjQIFQ6xQ6LdbloNlH2dzDWaPknqvsIevPvlvDUesvXKQycnPkgqvmyBUOaKzBNZg5s4w7FgA)SnxuaYSnKHJICHBdh)zW0(DR9pxVF2go(ZGP972ehOWd4BJBQ6Ldb7Zqijtgw2CevXpv9YHGnKpajd7qJd5zpK1bdKQ0avXqBZffGmBlKpajd7qJd5T1(p27NTHJ)myA)UnXbk8a(2IoKXUKiz5ZEoBKlHBZffGmB7z8eclYXU1()N3pBdh)zW0(DBIdu4b8T9YHGfNZLqBoABUOaKzBPZLit)i(T1(NHTF2go(ZGP972ehOWd4B7LdbloNlH2er3HQ0QLQCUGhOqRGysDyHOPZJu9NHqs2Zh9uvmPk(2Mlkaz22ZqiPIh4G1w7)FA)SnC8Nbt73TjoqHhW3MGNFsiKQ4qvYTnxuaYSTZLaJu)zi6U1(Nj2pBZffGmB7ziKuXdCWAB44pdM2VBT)5tZ9Z2WXFgmTF3M4afEaFBLBWPSc)gxcT44pdMOkTAPQFPQYn4uwwhcDXHwC8Nbtuf)u15sivPbQ6N0KQyavPvlv9lvvUbNYgosXdms9hEq80JNfh)zWevXpvDUesvAGQycnPkgSnxuaYSTZLaJu)zi6U1(Np(2pBdh)zW0(DBIdu4b8TvUbNYgYhGKHDOXH8S44pdM2Mlkaz2wiFasg2HghYBR9pFYTF2Mlkaz2gJarro57xgYBB44pdM2VBT)5JH2pBZffGmBdWgHtcmsDgbIICYVnC8Nbt73T2)8X17NT5IcqMTPlpWz0fmPTHJ)myA)U1wBlHbpBQ9Z(NV9Z2CrbiZ2e88tc3go(ZGP97w7F52pBZffGmBlkZYIMTHJ)myA)U1(NH2pBdh)zW0(DBIdu4b8T9lvDoi1rgXPSSegrwCkBcalFeivftQsUytv8tvNdsDKrCkllHrKfNYcgQkMufxhBQIbBZffGmBJhEeGOBqpAR9pxVF2go(ZGP972ehOWd4B7LdbRu2VeWNoj0DUGhP4zZruLwTu1Vuf3ufcH4iqRGmjCGyQBabmqobAzDUICuf)uv5New2cWI9I0taKQ0ahQ6N1KQyW2CrbiZ2IifGmBT)J9(zB44pdM2VBtCGcpGVnbHyseDh7Hc9gechecThY6GbsvAGQyOT5IcqMTDoBKlHBT))59Z2WXFgmTF3M4afEaFBVCiypuO3Gq4GqOnhTnxuaYSTNHqsDsOx8WooiR8BT)zy7NTHJ)myA)UnXbk8a(24MQE5qWEOqVbHWbHqBoIQ4NQ4MQE5qWcbOe(o01JNnhTnxuaYSTO8bcYdgP(Z4WAR9)pTF2go(ZGP972ehOWd4BJBQ6Ldb7Hc9gechecT5iQIFQIBQ6LdbleGs47qxpE2C02CrbiZ2oquKb7GPdJCbU1(Nj2pBdh)zW0(DBIdu4b8TXnv9YHG9qHEdcHdcH2CevXpvXnv9YHGfcqj8DORhpBoABUOaKzB6sotIrem9dHKXhbU1(Npn3pBdh)zW0(DBIdu4b8TXnv9YHG9qHEdcHdcH2CevXpvXnv9YHGfcqj8DORhpBoABUOaKzBbIidXu35cEGc7p0z3A)ZhF7NTHJ)myA)UnXbk8a(24MQE5qWEOqVbHWbHqBoIQ4NQ4MQE5qWcbOe(o01JNnhTnxuaYSTd9iWi1dgNfHBT)5tU9Z2WXFgmTF3M4afEaFBCtvVCiypuO3Gq4GqOnhrv8tvCtvVCiyHaucFh66XZMJOk(PQePScYiWPoVWupyCwS)Y3ypK1bdKQ4qvAUnxuaYSnbze4uNxyQhmolU1(NpgA)SnC8Nbt73TjoqHhW32lhc2df6nie2dKtG2C02CrbiZ2kEypppsEs9a5e4w7F(469Z2WXFgmTF3M4afEaFBCtvVCiypuO3Gq4GqOnhrv8tv)svfGf7fPNaivftQIpMi2uLwTuv5NewwEOBkE2irrvAGQKttQIbBZffGmBtk7xc4tNe6oxWJu82A)ZxS3pBdh)zW0(DBIdu4b8TXnv9YHG9qHEdcHdcH2C02CrbiZ2yrwYjFNe6MSaK6PdDw4w7F((59Z2WXFgmTF3M4afEaFBCtvieIJaTcYKWbIPUbeWa5eOL15kYrv8tvCtvieIJaTpdHK6KqV4HDCqw5TSoxroQsRwQsqiMer3XkL9lb8PtcDNl4rkE2dzDWaPQysv8rvA1svVCiyLY(La(0jHUZf8ifpBoIQ0QLQeeIjr0DSpdHK6KqV4HDCqw5ThY6GbsvAGQKePT5IcqMTDOqVbHWbHWT2)8XW2pBdh)zW0(DBIdu4b8TbJqJPx(jHf0QlpWz0fmjQkMufFuf)uf3u1lhcww0RUWGoJ4zZrBZffGmBtxEGZOlysBT)57N2pBdh)zW0(DBUOaKzBoKhJ(GW(5CHCDb5CZ2ehOWd4BRaSyVi9eaPknqvYPjvPvlvXnvLWxoeSNZfY1fKZn9e(YHGnhrvA1sv)svLFsyzlal2lspsuDgstQsduvSPk(PQe(YHGvqMuwuagXoy03t4lhc2CevXaQsRwQ6xQIBQkHVCiyfKjLffGrSdg99e(YHGnhrv8tvVCiyzrwYjFNe6MSaK6PdDwOnhrvA1svrhYyxsKSYzLY(La(0jHUZf8ifpQsRwQk6qg7sIKvo7Hc9gechecPk(PQFPkUPkecXrGwwKLCY3jHUjlaPE6qNfAzDUICuf)uf3ufcH4iqRGmjCGyQBabmqobAzDUICufdOkgSTXzXT5qEm6dc7NZfY1fKZnBT)5Jj2pBdh)zW0(DBJZIB7C2iWi1D2idOYjSlbKCgjMQJJeyWT5IcqMTDoBeyK6oBKbu5e2LasoJet1Xrcm4w7F50C)SnxuaYSTme7GczHBdh)zW0(DR9VC8TF2go(ZGP972ehOWd4B7Ldb7Hc9gechecT5OT5IcqMT9mesQhYN8BT)LtU9Z2WXFgmTF3M4afEaFBVCiypuO3Gq4GqOnhTnxuaYSThEq80dgPT2)YXq7NTHJ)myA)UnXbk8a(2E5qWEOqVbHWbHqBIO7SnxuaYSndqIxb7CvojXItT1(xoUE)SnC8Nbt73TjoqHhW32lhc2df6nieoieAZrBZffGmBlao8ziK0w7F5I9(zB44pdM2VBtCGcpGVTxoeShk0BqiCqi0MJ2Mlkaz2MpcewNB6c3y2A)l3pVF2go(ZGP972ehOWd4B7Ldb7Hc9gechecT5OT5IcqMT9CPoj0Rdi0d3A)lhdB)SnC8Nbt73T5IcqMTD5P7IcqMUbaRTzaWQpolUniyKmyV8tcRT2ABSegrwCQ9Z(NV9Z2CrbiZ24Hhbi6g0J2go(ZGP97wBTTOdfe2Nx7N9pF7NTHJ)myA)U1(xU9Z2WXFgmTF3A)Zq7NTHJ)myA)U1(NR3pBZffGmB75vzWoKhjxBdh)zW0(DR9FS3pBdh)zW0(DBJZIBZ5cKNFoShit1jHEerx82Mlkaz2MZfip)CypqMQtc9iIU4T1()N3pBZffGmBtxYzsmIGPFiKm(iWTHJ)myA)U1(NHTF2Mlkaz2glYso57Kq3KfGupDOZc3go(ZGP97w7)FA)SnxuaYSnPSFjGpDsO7CbpsXBB44pdM2VBT)zI9Z2CrbiZ2ouO3Gq4Gq42WXFgmTF3A)ZNM7NT5IcqMTfrkaz2go(ZGP97wBT12yepiGm7F50KpMqZFstgAB663agj42I1SrKRWevX1uLlkazOkdawqlv22GrOy)ZWKBBrhjam42ykv9JZN8u1p0VdqoQmMsv8QkcQrJhxcu8YpRGWghcyZgVaKrCEOIdbScQmMsvY8j7N8uLC8PdvjNMYPjvgvgtPkncE(iHqnkvgtPQyqvmzkHjQkwKzzrJLkJPuvmOQFea6pdMOkwcJilofvfNQ0yWJaeu1pa9iQs4gdv97qkQAqmHjQkqoQcmXqYzrQsqMcz4fdSuzmLQIbvPXsyetu1xJNqyrowQYNev9JoxImuvSK4hv5pcJiv91qiPIh4GfvveQcWgDegrQkCySkJJqEQIeOQdfewwCsEbidKQ(fcyHu1rYs8mYtvySk7ggyPYykvfdQIjtjmrvF9Qmiv14rYfvveQk6qbH95fvXKXIFGLkJPuvmOkMmLWevPrcef5KNQILzipQYFegrQccgjdgJYpjSOQFipWz0fmjlvgtPQyqvmzkHjQsJhIuvSUqwOLkJkJPuLghdhf5ctu1ddKdPkbH95fv9qjWaTuftkeyubPQHmXGNFSHSHQCrbidKQiJrElvMlkazG2Odfe2NxCcghQNkZffGmqB0Hcc7ZlM5epqijQmxuaYaTrhkiSpVyMtCplXIt5fGmuzmLQAJhb5rkQ6CqIQE5qatufS8csvpmqoKQee2Nxu1dLadKQ8jrvrhgJisvGrIQaqQkrg0sL5IcqgOn6qbH95fZCI)8QmyhYJKlQmxuaYaTrhkiSpVyMt8me7Gcz1zCwKJZfip)CypqMQtc9iIU4rL5IcqgOn6qbH95fZCIRl5mjgrW0pesgFeivMlkazG2Odfe2NxmZjolYso57Kq3KfGupDOZcPYCrbid0gDOGW(8IzoXLY(La(0jHUZf8ifpQmxuaYaTrhkiSpVyMt8df6nieoiesL5IcqgOn6qbH95fZCIhrkazOYOYykvPXXWrrUWevHmIN8uvbyrQQ4HuLlkYrvaiv5m6aJ)mOLkZffGmqocE(jHuzUOaKbYmN4rzww0qLXuQ6dpaKQaqQILalJ8uvrOQOdzeNIQeeIjr0DGuv4iSu1dbJev5cbiHt5gJ8uvgIjQkLpWirvSegrwCklvgtPkxuaYazMt8lpDxuaY0nayPZ4SihwcJiloLoGahwcJiloLnbGLpcmMXMkZffGmqM5eNhEeGOBqpshqGZVNdsDKrCkllHrKfNYMaWYhbgt5In)NdsDKrCkllHrKfNYcMyY1XMbuzUOaKbYmN4rKcqgDaboVCiyLY(La(0jHUZf8ifpBosR2F5gHqCeOvqMeoqm1nGagiNaTSoxro(l)KWYwawSxKEcGAGZpRjdOYCrbidKzoXpNnYLqDaboccXKi6o2df6nieoieApK1bdudmevMlkazGmZj(ZqiPoj0lEyhhKvEDaboVCiypuO3Gq4GqOnhrL5IcqgiZCIhLpqqEWi1Fghw6acC4(Ldb7Hc9gechecT5i(5(LdbleGs47qxpE2CevMlkazGmZj(bIImyhmDyKlqDaboC)YHG9qHEdcHdcH2Ce)C)YHGfcqj8DORhpBoIkZffGmqM5exxYzsmIGPFiKm(iqDaboC)YHG9qHEdcHdcH2Ce)C)YHGfcqj8DORhpBoIkZffGmqM5epqeziM6oxWduy)HoRoGahUF5qWEOqVbHWbHqBoIFUF5qWcbOe(o01JNnhrL5IcqgiZCIFOhbgPEW4SiuhqGd3VCiypuO3Gq4GqOnhXp3VCiyHaucFh66XZMJOYCrbidKzoXfKrGtDEHPEW4SOoGahUF5qWEOqVbHWbHqBoIFUF5qWcbOe(o01JNnhXFIuwbze4uNxyQhmol2F5BShY6GbYrtQmxuaYazMt8Ih2ZZJKNupqobQdiW5Ldb7Hc9gec7bYjqBoIkZffGmqM5exk7xc4tNe6oxWJu80be4W9lhc2df6nieoieAZr8)BbyXEr6jagt(yIyRvB5NewwEOBkE2irPb50KbuzUOaKbYmN4Sil5KVtcDtwas90HoluhqGd3VCiypuO3Gq4GqOnhrL5IcqgiZCIFOqVbHWbHqDaboCJqioc0kitchiM6gqadKtGwwNRih)CJqioc0(mesQtc9Ih2XbzL3Y6Cf50QvqiMer3XkL9lb8PtcDNl4rkE2dzDWaJjFA1(YHGvk7xc4tNe6oxWJu8S5iTAfeIjr0DSpdHK6KqV4HDCqw5ThY6GbQbjrIkZffGmqM5exxEGZOlys6acCGrOX0l)KWcA1Lh4m6cMum5JFUF5qWYIE1fg0zepBoIkZffGmqM5epdXoOqwDgNf54qEm6dc7NZfY1fKZn6acCkal2lspbqniNMA1YDcF5qWEoxixxqo30t4lhc2CKwT)w(jHLTaSyVi9ir1zin1qS5pHVCiyfKjLffGrSdg99e(YHGnhXaTA)L7e(YHGvqMuwuagXoy03t4lhc2Ce)VCiyzrwYjFNe6MSaK6PdDwOnhPvB0Hm2LejRCwPSFjGpDsO7CbpsXtR2OdzSljsw5Shk0BqiCqiK)F5gHqCeOLfzjN8DsOBYcqQNo0zHwwNRih)CJqioc0kitchiM6gqadKtGwwNRihdyavMlkazGmZjEgIDqHS6molY5C2iWi1D2idOYjSlbKCgjMQJJeyqQmxuaYazMt8me7GczHuzUOaKbYmN4pdHK6H8jVoGaNxoeShk0BqiCqi0MJOYCrbidKzoXF4bXtpyK0be48YHG9qHEdcHdcH2CevMlkazGmZjUbiXRGDUkNKyXP0be48YHG9qHEdcHdcH2er3HkZffGmqM5epao8ziKKoGaNxoeShk0BqiCqi0MJOYCrbidKzoX9rGW6Ctx4gJoGaNxoeShk0BqiCqi0MJOYCrbidKzoXFUuNe61be6H6acCE5qWEOqVbHWbHqBoIkZffGmqM5e)Yt3ffGmDdaw6molYbcgjd2l)KWIkJkZffGmqllHrKfNIdp8iar3GEevgvMlkazGwiyKmyV8tcloqakHVdD94rL5IcqgOfcgjd2l)KWIzoXpNnYLqDabo)(YHG9qHEdcHdcH2CKwTVCiyzrwYjFNe6MSaK6PdDwOnhXaTA)TCdoLnCKIhyK6p8G4Phplo(ZGjTAl3Gtzf(nUeAXXFgmX)VVCiyX5Cj0EiRdgOgKejTApxcJjtOjd0QTCdoLL1HqxCOfh)zWe))(YHGfNZLq7HSoyGAqsK0Q9CjmMmHMmGbuzUOaKbAHGrYG9YpjSyMtCKHJICHuzUOaKbAHGrYG9YpjSyMt8q(aKmSdnoKNoGahUF5qW(mesYKHLnhX)lhc2q(aKmSdnoKN9qwhmqnWquzUOaKbAHGrYG9YpjSyMt8NXtiSihRoGaNOdzSljsw(SNZg5sivMlkazGwiyKmyV8tclM5epDUez6hXpDaboVCiyX5Cj0MJOYCrbid0cbJKb7LFsyXmN4pdHKkEGdw6acCE5qWIZ5sOnr0D0Q15cEGcTcIj1HfIMops1FgcjzpF0ht(OYCrbid0cbJKb7LFsyXmN4NlbgP(Zq0vhqGJGNFsiKJCuzUOaKbAHGrYG9YpjSyMt8NHqsfpWblQmxuaYaTqWizWE5NewmZj(5sGrQ)meD1be4uUbNYk8BCj0IJ)mysR2Fl3GtzzDi0fhAXXFgmX)5sOg(jnzGwT)wUbNYgosXdms9hEq80JNfh)zWe)NlHAGj0KbuzUOaKbAHGrYG9YpjSyMt8q(aKmSdnoKNoGaNYn4u2q(aKmSdnoKNfh)zWevMlkazGwiyKmyV8tclM5eNrGOiN89ld5rL5IcqgOfcgjd2l)KWIzoXbSr4KaJuNrGOiN8uzUOaKbAHGrYG9YpjSyMtCD5boJUGjT1w7c]] )
end
