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


    spec:RegisterPack( "Fury", 20190803, [[dKe4IaqicYJqHAtubJcfPtHI4vOOMfvk3IGYUe8lHYWOs1XqLAzcvEgHktdvIUgkeBdvc(gkKmocQ6CeQADcvP5rLK7rG9rLuhuOQwOIYdrLqMOqv4IujiBuOkAKujGtsLiTsczMujQUjvc0ovunuQeQLsLqEQOMQI4QujO2kQeQVsLOSxL(RkgmjhMYIvPht0KPQldTzr(mQA0OItdA1eu51ksZMu3gL2Tu)gy4c54ujILRQNJy6sUUcBhf8DQqJhfsDEcL1JkP5tfTFKE5ENSzVv4opo35w8Ul8UlUa3UZLCbgr43CjweU5ito14Xn3glU5454fBZrMyAG53jBMagVe3mNQIiXBSy8WIZ4gKa2yei7qBfe0Y3svmcKvgBZ3buxU0EVB2BfUZJZDUfV7cV7IlWT7CjxGryKnBJId43CgYYfrvXOQ4)soq2c(aYM5a9ES37M9irUzgtvXZXlgv5YS)HGNkIXufNQIiXBSy8WIZ4gKa2yei7qBfe0Y3svmcKvsfXyQk(d(bPOkX5gvfN7ClEQsyuf3UhVIt8ururmMQ4I4ynpsIxQigtvcJQIV3JEQYfpyzrDGkIXuLWOQ4bKyxn6Pkwadil2fvfJQCbWhaLuLlhTiQsAAnvX0guuvJOh9uvc8ufSfgVXIuLe0fYOlMeOIymvjmQYfeWa6PQzAZJKc8SuL1EQkE8gpOPkxeWEQYUagqQAMga8fh4tkQQaufKn6bmGuv6rxYaBPyufirvpkbSSy7TccAcvXucKLqvpyWZrlgvHUKHPzsGkIXuLWOQ479ONQMzvPrQkZbmkQQauv0Jsa71kQk(UyxEGkIXuLWOQ479ONQ4IHYc8IrvUObHdvzxadivrGnVgfwzppwuLlJd81ocBFGkIXuLWOQ479ONQCHjiv5slKLe2SgskYozZeyZRXtzppw7KDo37KnBYcc6ntGipEF0MI)MX2UA0VZ2ANh3ozZyBxn63zBw(WcFOTzMsv3rkfEuovJesJesyervoDsv3rkfyrwWl2bKo6He6p(hnwsyervmHQC6KQykvvMg7kKEqXb28Nl(e8NIFaB7Qrpv50jvvMg7kiTVnEmGTD1ONQCGQykvDhPua734XWJSgSjuLROkEPNQC6KQEJhPkxtvI3DQIjuLtNuvzASRaRriM8Xa22vJEQYbQIPu1DKsbSFJhdpYAWMqvUIQ4LEQYPtQ6nEKQCnvjE3PkMqvmzZMSGGEZVXgz84w7CXTt2SjliO3mYOr5OWnJTD1OFNT1oNl3jBgB7Qr)oBZYhw4dTnlevDhPu4QbaVEqQWiIQCGQUJukKgpemihI2iCcpYAWMqvUIQe3Mnzbb9MtJhcgKdrBeoBTZzKDYMX2UA0VZ2S8Hf(qBZrpYWHx6dChEJnY4XnBYcc6nF1Mhjf4z3ANZf2jBgB7Qr)oBZYhw4dTnFhPua734XWiAZMSGGEZ(34b95b2V1oNrTt2m22vJ(D2MLpSWhAB(osPa2VXJbpWXMQC6KQmUIpSWGeO9hsHO(WbuNRga8H36PuLRPkU3SjliO38vda(Id8j1w7CHFNSzSTRg97SnlFyHp02SKJ98iHQeqvXTztwqqV534Hn)5QboU1ox87KnBYcc6nF1aGV4aFsTzSTRg97ST25C7(ozZyBxn63zBw(WcFOT5Y0yxbP9TXJbSTRg9uLtNuftPQY0yxbwJqm5JbSTRg9uLdu1B8iv5kQs4DNQycv50jvXuQQmn2vi9GIdS5px8j4pf)a22vJEQYbQ6nEKQCfvjE3PkMSztwqqV534Hn)5QboU1oNBU3jBgB7Qr)oBZYhw4dTnxMg7kKgpemihI2iCcyBxn63SjliO3CA8qWGCiAJWzRDo3XTt2SjliO3mdqzbEXo)GWzZyBxn63zBTZ5wC7KnBYcc6ndzJW2dB(ddqzbEX2m22vJ(D2w7CU5YDYMnzbb9MDKd81ocB)MX2UA0VZ2ARnZcyazXU2j7CU3jB2Kfe0BMd(aO8OrlAZyBxn63zBT1M9yYg6ANSZ5ENSztwqqVzjh75XnJTD1OFNT1opUDYMnzbb9MJgSSOEZyBxn63zBTZf3ozZyBxn63zBw(WcFOTzMsvVb9hKbSRalGbKf7k4HKYAjsvUMQIJrOkhOQ3G(dYa2vGfWaYIDfGnv5AQIlzeQIjB2Kfe0BMd(aO8OrlARDoxUt2SjliO3CeOGGEZyBxn63zBTZzKDYMX2UA0VZ2S8Hf(qBZsaq7bo2HhLt1iH0iHeEK1GnHQCfvjUnBYcc6n)gBKXJBTZ5c7KnJTD1OFNTz5dl8H2MVJuk8OCQgjKgjKWiAZMSGGEZxna4pG0P4GhSrwX2ANZO2jBgB7Qr)oBZYhw4dTnlevDhPu4r5unsinsiHrev5avjevDhPuGarE8(Onf)WiAZMSGGEZrJhMed28NR2i1w7CHFNSzSTRg97SnlFyHp02Squ1DKsHhLt1iH0iHegruLduLqu1DKsbce5X7J2u8dJOnBYcc6n)WOinEG9HezsCRDU43jBgB7Qr)oBZYhw4dTnlevDhPu4r5unsinsiHrev5avjevDhPuGarE8(Onf)WiAZMSGGEZocETNbe2NhjG2AjU1oNB33jBgB7Qr)oBZYhw4dTnlevDhPu4r5unsinsiHrev5avjevDhPuGarE8(Onf)WiAZMSGGEZjGCqq)X4k(Wcpx0y3ANZn37KnJTD1OFNTz5dl8H2MfIQUJuk8OCQgjKgjKWiIQCGQeIQUJukqGipEF0MIFyervoqvEqfKGwID9wH(tsBS45o(o8iRbBcvjGQCFZMSGGEZsqlXUERq)jPnwCRDo3XTt2m22vJ(D2MLpSWhAB(osPWJYPAKqojWlXWiAZMSGGEZfh8m6ly0(tc8sCRDo3IBNSzSTRg97SnlFyHp02Squ1DKsHhLt1iH0iHegrB2Kfe0BMFyVhA9bKogxXhuC2ANZnxUt2m22vJ(D2MLpSWhABwiQ6osPWJYPAKqAKqcJOnBYcc6nZISGxSdiD0dj0F8pASKT25CZi7KnJTD1OFNTz5dl8H2MfIQqcbBjgKG2Jnb9hnmHjWlXaRjCGNQCGQeIQqcbBjgUAaWFaPtXbpyJSIfynHd8uLtNuLea0EGJDGFyVhA9bKogxXhuCcpYAWMqvUMQIZDQYPtQ6osPa)WEp06diDmUIpO4egruLtNuLea0EGJD4Qba)bKofh8GnYkw4rwd2eQYvufV0VztwqqV5hLt1iH0iHS1oNBUWozZyBxn63zBw(WcFOTzseQ1NYEESibh5aFTJW2tvUMQ4MQCGQeIQUJukWIwDKA0ya)WiAZMSGGEZoYb(AhHTFRDo3mQDYMX2UA0VZ2SjliO3Sr4WG1i58gxb)rcEtVz5dl8H2MfIQ84DKsH34k4psWB6JhVJukmIOkNoPkMsvL98yf4GMU4eIKfv5kQsCUh4MQCGQ84DKsbjO9dzbzapWE6XJ3rkfgruftOkNoPkMsvcrvE8osPGe0(HSGmGhyp94X7iLcJiQYbQ6osPalYcEXoG0rpKq)X)OXscJiQYPtQk6rgo8sFiUa)WEp06diDmUIpO4qvoDsvrpYWHx6dXfEuovJesJecv5avXuQsiQcjeSLyGfzbVyhq6OhsO)4F0yjbwt4apv5avjevHec2smibThBc6pAyctGxIbwt4apvXeQIjBUnwCZgHddwJKZBCf8hj4n9w7CUf(DYMX2UA0VZ2CBS4MFJnc28hJnsdRHhp8qEJbGUoyZdBCZMSGGEZVXgbB(JXgPH1WJhEiVXaqxhS5HnU1oNBXVt2SjliO38GGhyHSKnJTD1OFNT1opo33jB2Kfe0B(Qba)jnEX2m22vJ(D2w7844ENSztwqqV5l(e8NcB(nJTD1OFNT1opU42jBgB7Qr)oBZYhw4dTnFhPu4r5unsinsibpWXEZMSGGEZAipNICeUHNNf7ARDECIBNSztwqqV5e8XRga8BgB7Qr)oBRDECC5ozZMSGGEZwlrs9M(inTEZyBxn63zBTZJJr2jBgB7Qr)oBZMSGGEZ)OpMSGG(OHKAZAiPoTXIBMaBEnEk75XART2C0Jsa71QDYoN7DYMX2UA0VZ2ANh3ozZyBxn63zBTZf3ozZyBxn63zBTZ5YDYMnzbb9MVwvA8q4ag1MX2UA0VZ2ANZi7KnJTD1OFNT52yXnBCLWXEJCsGUoG0jc4i(B2Kfe0B24kHJ9g5KaDDaPteWr83ANZf2jB2Kfe0BMfzbVyhq6OhsO)4F0yjBgB7Qr)oBRDoJANSztwqqVz(H9EO1hq6yCfFqXzZyBxn63zBTZf(DYMnzbb9MFuovJesJeYMX2UA0VZ2ANl(DYMnzbb9MJafe0BgB7Qr)oBRT2AZmGpbc6DECUZT4DNrfN43SJ23WMNSzxkBe4l0tvCjvzYccAQsdjfjqfT5OhKGACZmMQINJxmQYLz)dbpveJPkovfrI3yX4HfNXnibSXiq2H2kiOLVLQyeiRKkIXuv8h8dsrvIZnQko35w8uLWOkUDpEfN4PIOIymvXfXXAEKeVurmMQegvfFVh9uLlEWYI6aveJPkHrvXdiXUA0tvSagqwSlQkgv5cGpakPkxoAruL00AQIPnOOQgrp6PQe4PkylmEJfPkjOlKrxmjqfXyQsyuLliGb0tvZ0Mhjf4zPkR9uv84nEqtvUiG9uLDbmGu1mna4loWNuuvbOkiB0dyaPQ0JUKb2sXOkqIQEucyzX2Bfe0eQIPeilHQEWGNJwmQcDjdtZKaveJPkHrvX37rpvnZQsJuvMdyuuvbOQOhLa2Rvuv8DXU8aveJPkHrvX37rpvXfdLf4fJQCrdchQYUagqQIaBEnkSYEESOkxgh4RDe2(aveJPkHrvX37rpv5ctqQYLwiljqfrfXyQYfIrJYrHEQ6IjWJuLeWETIQUipSjbQk(sjgveQQbTW4ypBAOPktwqqtOkqRflqfzYccAsi6rjG9ALGK2itPImzbbnje9OeWETIzbXsaGNkYKfe0Kq0Jsa71kMfeZg8SyxwbbnveJPQCBreoGIQEd6PQ7iLqpvrkRiu1ftGhPkjG9AfvDrEytOkR9uv0JclcufS5PkiHQ8GgdurMSGGMeIEucyVwXSGyxRknEiCaJIkYKfe0Kq0Jsa71kMfeBqWdSqw3AJffyCLWXEJCsGUoG0jc4i(urMSGGMeIEucyVwXSGySil4f7ash9qc9h)JglHkYKfe0Kq0Jsa71kMfeJFyVhA9bKogxXhuCOImzbbnje9OeWETIzbXEuovJesJecvKjliOjHOhLa2RvmliweOGGMkIkIXuLleJgLJc9ufYa(IrvfKfPQIdsvMSapvbjuLXGb12vJbQitwqqtei5yppsfzYccAcZcIfnyzrnveJPQjCGeQcsOkwaP0IrvfGQIEKbSlQscaApWXMqvPhWsvxe28uLjLqp2LP1Irvdc6Pk)4HnpvXcyazXUcurmMQmzbbnHzbX(rFmzbb9rdjLBTXIcybmGSyxUbtcybmGSyxbpKuwlrxZiurMSGGMWSGyCWhaLhnArUbtcy6Bq)bza7kWcyazXUcEiPSwIUoogXH3G(dYa2vGfWaYIDfGTR5sgHjurMSGGMWSGyrGccAQitwqqtywqS3yJmE0nysGea0EGJD4r5unsinsiHhznytCL4OImzbbnHzbXUAaWFaPtXbpyJSI5gmj4osPWJYPAKqAKqcJiQitwqqtywqSOXdtIbB(ZvBKYnysGq3rkfEuovJesJesye5Gq3rkfiqKhVpAtXpmIOImzbbnHzbXEyuKgpW(qImj6gmjqO7iLcpkNQrcPrcjmICqO7iLceiYJ3hTP4hgrurMSGGMWSGyocETNbe2NhjG2Aj6gmjqO7iLcpkNQrcPrcjmICqO7iLceiYJ3hTP4hgrurMSGGMWSGyjGCqq)X4k(Wcpx0yDdMei0DKsHhLt1iH0iHegroi0DKsbce5X7J2u8dJiQitwqqtywqmjOLyxVvO)K0gl6gmjqO7iLcpkNQrcPrcjmICqO7iLceiYJ3hTP4hgro4bvqcAj21Bf6pjTXIN747WJSgSjcCNkYKfe0eMfeR4GNrFbJ2FsGxIUbtcUJuk8OCQgjKtc8smmIOImzbbnHzbX4h27HwFaPJXv8bfh3GjbcDhPu4r5unsinsiHrevKjliOjmliglYcEXoG0rpKq)X)OXsCdMei0DKsHhLt1iH0iHegrurMSGGMWSGypkNQrcPrcXnysGqiHGTedsq7XMG(JgMWe4LyG1eoW7GqiHGTedxna4pG0P4GhSrwXcSMWbENoLaG2dCSd8d79qRpG0X4k(GIt4rwd2exhN7oDEhPuGFyVhA9bKogxXhuCcJiNoLaG2dCSdxna4pG0P4GhSrwXcpYAWM4kEPNkYKfe0eMfeZroWx7iS9UbtcirOwFk75XIeCKd81ocBVR52bHUJukWIwDKA0ya)WiIkYKfe0eMfeBqWdSqw3AJffyeomynsoVXvWFKG30UbtceYJ3rkfEJRG)ibVPpE8osPWiYPtMw2ZJvGdA6ItiswUsCUh42bpEhPuqcA)qwqgWdSNE84DKsHretC6KPc5X7iLcsq7hYcYaEG90JhVJukmIC4osPalYcEXoG0rpKq)X)OXscJiNoJEKHdV0hIlWpS3dT(ashJR4dkooDg9idhEPpex4r5unsinsioWuHqcbBjgyrwWl2bKo6He6p(hnwsG1eoW7GqiHGTedsq7XMG(JgMWe4LyG1eoWZeMqfzYccAcZcIni4bwiRBTXIcEJnc28hJnsdRHhp8qEJbGUoyZdBKkYKfe0eMfeBqWdSqwcvKjliOjmli2vda(tA8IrfzYccAcZcIDXNG)uyZtfzYccAcZcIPH8CkYr4gEEwSl3Gjb3rkfEuovJesJesWdCSPImzbbnHzbXsWhVAaWtfzYccAcZcIzTej1B6J00AQitwqqtywqSF0htwqqF0qs5wBSOacS514PSNhlQiQitwqqtcSagqwSlbCWhaLhnArururMSGGMeiWMxJNYEESeqGipEF0MIpvKjliOjbcS514PSNhlMfe7n2iJhDdMeW07iLcpkNQrcPrcjmIC68osPalYcEXoG0rpKq)X)OXscJiM40jtltJDfspO4aB(ZfFc(tXpGTD1O3PZY0yxbP9TXJbSTRg9oW07iLcy)gpgEK1GnXv8sVtNVXJUw8UZeNoltJDfyncXKpgW2UA07atVJukG9B8y4rwd2exXl9oD(gp6AX7otycvKjliOjbcS514PSNhlMfedz0OCuivKjliOjbcS514PSNhlMfelnEiyqoeTr44gmjqO7iLcxna41dsfgroChPuinEiyqoeTr4eEK1GnXvIJkYKfe0Kab28A8u2ZJfZcID1Mhjf4zDdMee9idhEPpWD4n2iJhPImzbbnjqGnVgpL98yXSGy(34b95b27gmj4osPa2VXJHrevKjliOjbcS514PSNhlMfe7QbaFXb(KYnysWDKsbSFJhdEGJTtNgxXhwyqc0(dPquF4aQZvda(WB9uxZnvKjliOjbcS514PSNhlMfe7nEyZFUAGJUbtcKCSNhjcIJkYKfe0Kab28A8u2ZJfZcID1aGV4aFsrfzYccAsGaBEnEk75XIzbXEJh28NRg4OBWKGY0yxbP9TXJbSTRg9oDY0Y0yxbwJqm5JbSTRg9o8gp6kH3DM40jtltJDfspO4aB(ZfFc(tXpGTD1O3H34rxjE3zcvKjliOjbcS514PSNhlMfelnEiyqoeTr44gmjOmn2vinEiyqoeTr4eW2UA0tfzYccAsGaBEnEk75XIzbXyaklWl25heourMSGGMeiWMxJNYEESywqmiBe2EyZFyaklWlgvKjliOjbcS514PSNhlMfeZroWx7iS9BMeHYDoJkUT2Axa]] )
end
