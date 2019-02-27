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


        -- override this to account for recheck.
        lights_judgment = {
            id = 255647,
            cast = 0,
            cooldown = 150,
            gcd = "spell",

            toggle = 'cooldowns',

            usable = function () return race.lightforged_draenei end,
            recheck = function () return cooldown.recklessness.remains - 3, cooldown.recklessness.remains end,   
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
            cooldown = 90,
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

        potion = "potion_of_bursting_blood",

        package = "Fury",
    } )


    spec:RegisterPack( "Fury", 20190217.0015, [[dG0azaqiGepIuQnbKAusuoLeQxbvAwkOULePDjPFHsggrLJbeltI4zOuAAOOQRrkPTjHqFdLkgNeIohkfRdLQmpfK7ru2hPehuIklubEOecMikk1frrr2ikQmsGKYjrrrTsuyMOOKBIIc2Pc1qLqAPsu1tv0uLGTIIc9vuQ0Ev6VKQbJQdtzXaEmvMmvDzKntsFgkJgOoTuRgiP61qfZMWTjYUf9BidhQ64ajXYv1ZbnDHRtITRq(okY4rPQoprvRhijnFsX(v5fKTWo9wq74sKde2ixjGWov5KdeTcIw3zipEAN4nhoggTZ0KODYCkV87eVjVaz(TWoHiL3r7eCe4HShlwyDawbO6qsSGTKIWIgLU3udwWwYXcqGaybOAL6PrSW)i1wqqwf9PYBThYQOLxNDT)B0RZCkV8vyl52jGslcM5Cb2P3cAhxICGWg5kbe2PkNCGOv5kYDAkby0VZzlveooRJxU3bULI(rWDcU9EkxGD6jOBNAFCMt5L)4SR9FJ(JH2hhCe4HShlwyDawbO6qsSGTKIWIgLU3udwWwYXcqGaybOAL6PrSW)i1wqqwf9PYBThYQOLxNDT)B0RZCkV8vyl5ogAFCMJaEf7L)4GWodF8sKde2C8spUCYXELW2JXXq7JxeaBjgbzVJH2hV0JxoVN8hVOkssKOEm0(4LECMDdnab5pUeAejrzCCwhhuJEu7ooZIm8h3zcXXllrXXtI8K)4QO)4DwkMjrh3HYGy)O46Xq7Jx6XzgqJi)Xhimpbd0lDCl9hNz)ggkpE5r2FCdanIo(abc5dW9dJJhOJ3s4F0i64QpbQOqPt(JJup(toKKeLElAucpEzWwcECOOXahc5po4gdm9fxpgAF8spE58EYF8bwec64tWiL44b644FYHKaS44LROmR6Xq7Jx6XlN3t(JZm2Ua9YF8YRabFCdanIooStmbvAypgfhNDb3VGPo91DkAya3c7e2jMG0d7XOylSJbzlStZfnk3jSjmc4jdh63jLgGG87Gn2XLSf2jLgGG87GD6(oOVTDcOOQwFYHJGGWKGWQc(JRrZXl74HjOmQQpka3jMoa9q6XH(kLgGG8hxJMJhMGYO6SpnmQsPbii)Xb9Xl74akQQvkFdJQpjzDcp(qhhZ5pUgnh)nm64A54SrUJx8X1O54HjOmQsgeAUNQuAacYFCqF8YooGIQALY3WO6tswNWJp0XXC(JRrZXFdJoUwooBK74fF8I3P5IgL78nj8ggTXoMTBHDAUOr5oj2NCkbTtknab53bBSJz(TWoP0aeKFhSt33b9TTt8pnshZ5RGuFtcVHr70CrJYDcimpbd0lTXowRBHDsPbii)oyNUVd6BBNakQQvkFdJQEet5X1O54gOk9Dqvhs41HbrcDWOqhqGq(6BjohxlhhKDAUOr5obeiKpa3pm2yhxe3c7Ksdqq(DWoDFh032oDGThJGhx2XlzNMlAuUZ3W6ethqGyAJDm7Sf2jLgGG87GD6(oOVTDcOOQwP8nmQQGFNMlAuUt)ByOu)r2VXoUi3c70CrJYDciqiFaUFyStknab53bBSJzZwyNuAacYVd2P77G(22zyckJQZ(0WOkLgGG8hxJMJx2XdtqzuLmi0CpvP0aeK)4G(4VHrhFOJxKYD8IpUgnhVSJhMGYOQ(OaCNy6a0dPhh6RuAacYFCqF83WOJp0XzJChV4DAUOr5oFdRtmDabIPn2XGi3wyNuAacYVd2P77G(22zyckJQQY3ifOouyqWvknab53P5IgL7uv5BKcuhkmi4n2XGaYwyNMlAuUZrTlqV86Vce8oP0aeKFhSXogKs2c70CrJYD2s4P03jM(O2fOx(DsPbii)oyJDmiSDlStZfnk3jtG7xWuN(DsPbii)oyJn2PNunfrSf2XGSf2P5IgL70b2EmANuAacYVd2yhxYwyNMlAuUt8kssKyNuAacYVd2yhZ2TWonx0OCN4rrJYDsPbii)oyJDmZVf2jLgGG87GD6(oOVTDgMGYOQQ8nsbQdfgeCLsdqq(Jd6Jx2XbuuvRQkFJuG6qHbbxHH5W54dDC2ECnAooGIQAvv5BKcuhkmi46tswNWJp0Xz7X1O54LDChcj8iMY6toCeeeMeewFsY6eE8HooBpoOpoGIQAvv5BKcuhkmi46tswNWJp0XzZXl(4fVtZfnk3PQY3ifOouyqWBSJ16wyNuAacYVd2P77G(22PdHeEetz9jhoccctccRpjzDcp(qhNT70CrJYD(MeEdJ2yhxe3c7Ksdqq(DWoDFh032obLJhMGYOcBcJaEYWH(kLgGG8hxJMJx2XDiKWJykRWMWiGNmCOV(KK1j84dDCqoUgnh3HqcpIPScBcJaEYWH(6tswNWJRLJR1Jx8onx0OCNp5Wrqqysq4g7y2zlStknab53b709DqFB7eINec9WEmkGvMa3VGPo9hxlhhKJd6JdkhhqrvTkrwO7eKnI(Qc(DAUOr5ozcC)cM60VXoUi3c7Ksdqq(DWottI25Bs47et3KWl6qXt6ynMncjcDkX6K2P5IgL78nj8DIPBs4fDO4jDSgZgHeHoLyDsBSJzZwyNMlAuUtfiP3bjb3jLgGG87Gn2XGi3wyNMlAuUtabc51vvE53jLgGG87Gn2XGaYwyNMlAuUta6H0JtNy7Ksdqq(DWg7yqkzlStknab53b709DqFB7eqrvT(KdhbbHjbHvpIPCNMlAuUtrJboG6G6kEmjkJn2XGW2TWonx0OCNQ9taceYVtknab53bBSJbH53c70CrJYDAPJGXBcDNje7Ksdqq(DWg7yq06wyNuAacYVd2P5IgL78vsDZfnk1fnm2POHHEAs0oHDIji9WEmk2yJDkHgrsugBHDmiBHDAUOr5obtpQD6cYWVtknab53bBSXoX)KdjbyXwyhdYwyNuAacYVd2yhxYwyNuAacYVd2yhZ2TWoP0aeKFhSXoM53c7Ksdqq(DWg7yTUf2P5IgL7epkAuUtknab53bBSJlIBHDsPbii)oyNUVd6BBNGYXdtqzuvv(gPa1HcdcUsPbii)Xb9XbLJhMGYO(KdhbbH6gGLEuwP0aeKFNMlAuUZNC4iiimjiCJn2yNJOh2OChxICGWg5krUsQGacZxYozY(Stm4ozMLWJ(G8hN5pU5IgLhx0Wawpg7eINC7y2PKDI)rQTG2P2hN5uE5po7A)3O)yO9XbhbEi7XIfwhGvaQoKelylPiSOrP7n1GfSLCSaeiawaQwPEAel8psTfeKvrFQ8w7HSkA51zx7)g96mNYlFf2sUJH2hN5iGxXE5poiSZWhVe5aHnhV0JlNCSxjS9yCm0(4fbWwIrq27yO9Xl94LZ7j)XlQIKejQhdTpEPhNz3qdqq(JlHgrsughN1Xb1Oh1UJZSid)XDMqC8YsuC8Kip5pUk6pENLIzs0XDOmi2pkUEm0(4LECMb0iYF8bcZtWa9sh3s)Xz2VHHYJxEK9h3aqJOJpqGq(aC)W44b64Te(hnIoU6tGkku6K)4i1J)KdjjrP3IgLWJxgSLGhhkAmWHq(JdUXatFX1JH2hV0JxoVN8hFGfHGo(emsjoEGoo(NCijaloE5kkZQEm0(4LE8Y59K)4mJTlqV8hV8kqWh3aqJOJd7etqLg2JrXXzxW9lyQtF9yCm0(4mtSp5ucYFCasf90XDijalooaH1jSE8Y5Ce(aE8eLLc2EjvfXXnx0OeECukKVEmmx0OewX)KdjbyHmvHbX5yyUOrjSI)jhscWcCLXsfH8hdZfnkHv8p5qsawGRmwMcMeLHfnkpgAF8zA4HGrXXFR9hhqrvL8hhgwapoaPIE64oKeGfhhGW6eECl9hh)tLIhfrNyhVHh3JsQEmmx0OewX)KdjbybUYybtdpemk0HHfWJH5IgLWk(NCijalWvgl8OOr5XWCrJsyf)toKeGf4kJ1toCeeeMeeoCRkductqzuvv(gPa1HcdcUsPbiipObLWeug1NC4iiiu3aS0JYkLgGG8hJJH2hNzI9jNsq(JtJOx(JhTeD8amDCZfO)4n842iRfgGGQhdZfnkHYCGThJogMlAucXvgl8kssK4yO9XlaUHhVHhxcbdH8hpqhh)tJOmoUdHeEetj84Qps64auNyh3CU2tzycH8hxbs(J7v(oXoUeAejrzupgAFCZfnkH4kJ1RK6MlAuQlAymCAsKmj0isIYy4wvMeAejrzu9nmS0rArRhdTpU5IgLqCLXcm9O2Plid)WTQSYER960ikJQeAejrzu9nmS0rAPeTc63AVonIYOkHgrsug1o1cZR1I1ObuER960ikJQeAejrzuj2VHb8yyUOrjexzSWJIgLhdZfnkH4kJLQY3ifOouyqWd3QYctqzuvv(gPa1HcdcUsPbiipOldqrvTQQ8nsbQdfgeCfgMdNHyRgnakQQvvLVrkqDOWGGRpjzDchITA0uMdHeEetz9jhoccctccRpjzDchITGgqrvTQQ8nsbQdfgeC9jjRt4qSP4IpgMlAucXvgR3KWBy0WTQmhcj8iMY6toCeeeMeewFsY6eoeBpgMlAucXvgRNC4iiimjiC4wvgOeMGYOcBcJaEYWH(kLgGG8A0uMdHeEetzf2egb8KHd91NKSoHdbIgnoes4rmLvytyeWtgo0xFsY6eQfTw8XWCrJsiUYyXe4(fm1PF4wvgepje6H9yuaRmbUFbtD61ciGguauuvRsKf6obzJOVQG)yyUOrjexzSuGKEhK0WPjrYEtcFNy6MeErhkEshRXSrirOtjwN0XWCrJsiUYyPaj9oij4XWCrJsiUYybiqiVUQYl)XWCrJsiUYybqpKEC6e7yyUOrjexzSeng4aQdQR4XKOmgUvLbOOQwFYHJGGWKGWQhXuEmmx0OeIRmwQ9taceYFmmx0OeIRmww6iy8Mq3zcXXWCrJsiUYy9kPU5IgL6IggdNMejd2jMG0d7XO4yCmmx0OewLqJijkdzGPh1oDbz4pghdZfnkHvyNycspShJczWMWiGNmCO)yyUOrjSc7etq6H9yuGRmwVjH3WOHBvzakQQ1NC4iiimjiSQGxJMYctqzuvFuaUtmDa6H0Jd9vknab51OjmbLr1zFAyuLsdqqEqxgGIQALY3WO6tswNWHWCEnAEdJ0cBKRynActqzuLmi0CpvP0aeKh0LbOOQwP8nmQ(KK1jCimNxJM3WiTWg5kU4JH5IgLWkStmbPh2JrbUYyrSp5uc6yyUOrjSc7etq6H9yuGRmwacZtWa9sd3QYW)0iDmNVcs9nj8ggDmmx0OewHDIji9WEmkWvglabc5dW9dJHBvzakQQvkFdJQEetPgngOk9Dqvhs41HbrcDWOqhqGq(6BjoAbKJH5IgLWkStmbPh2JrbUYy9gwNy6acetd3QYCGThJGYk5yyUOrjSc7etq6H9yuGRmw(3WqP(JSF4wvgGIQALY3WOQc(JH5IgLWkStmbPh2JrbUYybiqiFaUFyCmmx0OewHDIji9WEmkWvgR3W6ethqGyA4wvwyckJQZ(0WOkLgGG8A0uwyckJQKbHM7PkLgGG8G(nmAOIuUI1OPSWeugv1hfG7ethGEi94qFLsdqqEq)ggneBKR4JH5IgLWkStmbPh2JrbUYyPQ8nsbQdfge8WTQSWeugvvLVrkqDOWGGRuAacYFmmx0OewHDIji9WEmkWvgRrTlqV86Vce8XWCrJsyf2jMG0d7XOaxzSAj8u67etFu7c0l)XWCrJsyf2jMG0d7XOaxzSycC)cM60VXg7c]] )
end
