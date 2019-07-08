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

        potion = "potion_of_bursting_blood",

        package = "Fury",
    } )


    spec:RegisterPack( "Fury", 20190707.2215, [[dKKEGaqiQGhbkAtIqJcuPtbQ4vGsZIkLBHsPDrv)IkAyIGJHs1YOs6zuPQPruKRruvBdLI8nqbJJOkDoIswhOqMhrH7HkTpQeDqukSqPIhckuMirPYfrPOAJujuJeLIYjPsiRevmtIsv3euOANsLgkrP0sjkfpvktvKCvIIsBLOO4Revr7vYFrXGjCyklgKhtYKf1Lr2Ss(mrgnk50QSAIQWRfPMnPUnQA3k(nudxQ64efvlh45QA6cxxP2oOQVtfA8uj48evwpvQmFr0(HCXELQAzlOQRRjWUSsagsag8U6k7SPeK3QfY1tvR3uPnjQAJXtvZfVbYvTEton2YvQQ94nqrvJve9pmYPtPlyTH8kmVZ)43Alo8Oa2kC(hVYz1G2NoCrtbvTSfu111eyxwjadjadExzx(YRmbdvZ2blmOATJhgdjCIeSbqX64JdG)QX6YzAkOQLPxvnyIeU4nqoKqEAaWHbioWejyfr)dJC6u6cwBiVcZ78p(T2IdpkGTcN)XRqCGjsWzRLdjGb3qcxtGDzHeSfjCLDyK8LpIdIdmrcymw2irpmcXbMibBrc2iNPmsiB388K2J4atKGTiHS7EdstzKGhdpXttGeorc2mcGpfsi7jRhjuMwJeWDWbsmeLPmsSWaK4g2kz8esOWtqUqahpIdmrc2IeW4y4Pms0rBz6dmGhjSjJeYoGjHhKq2Gnasyqy4jKOJgJZbRd8bseyK447by4jKybiz(MgLCibEHeasH55PjBXHNhjG7F8psaWBjwA5qcsMVnnC8ioWejylsWg5mLrIoweAcjASW7ajcms0difMhYcKGnKTYEpIdmrc2IeSrotzKqM5ubgihsiB2plKWGWWtiXFJKMyByajkqc5jRdOD8MShXbMibBrc2iNPmsiZ(es4IcI)9vtFF8vQQ93iPjMWasuuPQUSxPQMPIdpv7psIGaKLMavJgdst5QtfvxxRuvJgdst5Qt1uGliWzvdUib0ET8asLwt)p0)(DpsKmjsaTxlppXJbYXGxm6T6Ymzaz8VF3JeWbjsMejGlseMMMWVa4G1nsmqe4jqAc4PXG0ugjsMejcttt4vgymjYtJbPPmsKisaxKaAVwEAaMe5beVDZJeYajKuzKizsKayses4sKqwjGeWbjsMejcttt45T)nfG80yqAkJejIeWfjG2RLNgGjrEaXB38iHmqcjvgjsMejaMeHeUejKvcibCqc4untfhEQgW47njQIQR7RuvZuXHNQrUaP2bvnAminLRovuDLPkv1OXG0uU6unf4ccCw16be8msQSNDpW47njQAMko8uniTLPpWa(kQUYVsvnAminLRovtbUGaNvnO9A5PbysKF3xntfhEQwgys4HbGnqfvx2uLQA0yqAkxDQMcCbboRAq71YtdWKiFg74GejtIeM7iWfKxH1zMpisZWchmqAmo7b2KgjCjsWE1mvC4PAqAmohSoWhvuDHHkv1OXG0uU6unf4ccCw1uSmGe9ibxKW1QzQ4Wt1aM0nsmqASJvuDL3kv1mvC4PAqAmohSoWhvJgdst5QtfvxzvPQgngKMYvNQPaxqGZQwyAAcVYaJjrEAminLrIKjrc4IeHPPj882)McqEAminLrIercGjriHmqc5nbKaoirYKibCrIW00e(fahSUrIbIapbstapngKMYirIibWKiKqgiHSsajGt1mvC4PAat6gjgin2XkQUSNqLQA0yqAkxDQMcCbboRAHPPj8Rn4W7N512ZYtJbPPC1mvC4PARn4W7N512ZQIQl7SxPQMPIdpvd(tfyGCmG9ZQA0yqAkxDQO6YURvQQzQ4Wt1o(EAY3iXa)PcmqUQrJbPPC1PIQl7UVsvntfhEQMJSoG2XBYvJgdst5QtfvuTmTSToQuvx2RuvZuXHNQPyzajQA0yqAkxDQO66ALQAMko8uT(nppPRgngKMYvNkQUUVsvnAminLRovtbUGaNvn4Iea7Yme80eEEm8epnHpFFyJIqcxIeUkFKirKayxMHGNMWZJHN4Pj83GeUejKj5JeWbjsMejCaja2Lzi4Pj88y4jEAcp5c3hF1mvC4PASia(umAY6RO6ktvQQzQ4Wt16XXHNQrJbPPC1PIQR8RuvJgdst5Qt1uGliWzvlmnnHFTbhE)mV2EwEAminLrIerc4Ieq71YV2GdVFMxBpl)hMknsidKW9irYKib0ET8Rn4W7N512ZYdiE7MhjKbs4EKizsKaUiHcJ1zSJJhqQ0A6)H(3diE7MhjKbs4EKirKaAVw(1gC49Z8A7z5beVDZJeYajKfsahKaovZuXHNQT2GdVFMxBpRkQUSPkv1OXG0uU6unf4ccCw1uySoJDC8asLwt)p0)EaXB38iHmqc3xntfhEQgW47njQIQlmuPQgngKMYvNQPaxqGZQg0ET8asLwt)p0)(DF1mvC4PAqAmoZGxmblIHgIxUkQUYBLQA0yqAkxDQMcCbboRAoGeq71YdivAn9)q)739irIiHdib0ET8)rseeGS0eWV7RMPIdpvRFdULC3iXaPTpQO6kRkv1OXG0uU6unf4ccCw1CajG2RLhqQ0A6)H(3V7rIerchqcO9A5)JKiiazPjGF3xntfhEQg4671eZnmFVPOkQUSNqLQA0yqAkxDQMcCbboRAoGeq71YdivAn9)q)739irIiHdib0ET8)rseeGS0eWV7RMPIdpvZrmqNHNUHbqpESrrvuDzN9kv1OXG0uU6unf4ccCw1CajG2RLhqQ0A6)H(3V7rIerchqcO9A5)JKiiazPjGF3xntfhEQ2cR2pLzm3rGligiY4RO6YURvQQrJbPPC1PAkWfe4SQ5asaTxlpGuP10)d9VF3JejIeoGeq71Y)hjrqaYsta)UhjsejY4WRWJIMaybLzwAJNyG2GXdiE7Mhj4IejuntfhEQMcpkAcGfuMzPnEQIQl7UVsvnAminLRovtbUGaNvnO9A5bKkTM(NzHbkYV7RMPIdpvlyrm7bcVNmZcduufvx2LPkv1OXG0uU6unf4ccCw1CajG2RLhqQ0A6)H(3V7RMPIdpvtABG8zddEXyUJa4Gvfvx2LFLQA0yqAkxDQMcCbboRAoGeq71YdivAn9)q)739vZuXHNQXt8yGCm4fJERUmtgqg)xr1LD2uLQA0yqAkxDQMcCbboRAoGe0)0OiVcpzAEkZOVfTWaf55n5bgGejtIekmwNXooEPTbYNnm4fJ5ocGdwEaXB38iHlrcxtajsMejG2RLxABG8zddEXyUJa4GLF3xntfhEQgGuP10)d9Ffvx2HHkv1OXG0uU6unf4ccCw1(EsRzcdirX7DK1b0oEtgjCjsWosKis4asaTxlppzbJstg8eWV7RMPIdpvZrwhq74n5kQUSlVvQQrJbPPC1PAJXtvdy893iXy896l2zIr6Km4X6GHgPBOQzQ4Wt1agF)nsmgFV(IDMyKojdESoyOr6gQIQl7YQsvntfhEQ2(jMli(VA0yqAkxDQO66AcvQQzQ4Wt1G0yCMzTbYvnAminLRovuDDL9kv1mvC4PAqe4jq6BKQgngKMYvNkQUU6ALQA0yqAkxDQMcCbboRAq71YdivAn9)q)7ZyhNQzQ4Wt10NeR4zKh7SepnrfvxxDFLQAMko8uT1biingNRgngKMYvNkQUUktvQQzQ4Wt1SrrFamnJY06QrJbPPC1PIQRRYVsvnAminLRovZuXHNQb2dJPIdpm67JQPVpygJNQ2FJKMycdirrfvunEm8epnrLQ6YELQAMko8unweaFkgnz9vJgdst5QtfvuTEaPW8qwuPQUSxPQgngKMYvNkQUUwPQgngKMYvNkQUUVsvnAminLRovuDLPkv1mvC4PAqweAI5zH3r1OXG0uU6ur1v(vQQzQ4Wt16XXHNQrJbPPC1PIQlBQsvntfhEQgpXJbYXGxm6T6Ymzaz8F1OXG0uU6ur1fgQuvZuXHNQjTnq(SHbVym3raCWQA0yqAkxDQO6kVvQQzQ4Wt1wy1(PmJ5ocCbXargF1OXG0uU6ur1vwvQQrJbPPC1PAkWfe4SQ5aseMMMWV2GdVFMxBplpngKMYvZuXHNQbivAn9)q)xrfvun4jWF4P66AcSlReCLDyWNqcSl)Q5ObMBK(Q5I47XGGYiHmHeMko8Ge67J3J4uTVNuvxyW1Q1dWRttvdMiHlEdKdjKNgaCyaIdmrcwr0)WiNoLUG1gYRW8o)JFRT4WJcyRW5F8kehyIeC2A5qcyWnKW1eyxwibBrcxzhgjF5J4G4atKagJLns0dJqCGjsWwKGnYzkJeY2nppP9ioWejylsi7U3G0ugj4XWt80eiHtKGnJa4tHeYEY6rcLP1ibChCGedrzkJelmajUHTsgpHek8eKleWXJ4atKGTibmogEkJeD0wM(ad4rcBYiHSdys4bjKnydGegegEcj6OX4CW6aFGebgjo(EagEcjwasMVPrjhsGxibGuyEEAYwC45rc4(h)Jea8wILwoKGK5BtdhpIdmrc2IeSrotzKOJfHMqIgl8oqIaJe9asH5HSajydzRS3J4atKGTibBKZugjKzovGbYHeYM9Zcjmim8es83iPj2ggqIcKqEY6aAhVj7rCGjsWwKGnYzkJeYSpHeUOG4FpIdIdmrc2CxGu7GYibeTWacjuyEilqcis6M3JeSHsr9XJedEylldWV2AKWuXHNhjWJwopIJPIdpVVhqkmpKfCxA7tJ4yQ4WZ77bKcZdzbSCDUW4mIJPIdpVVhqkmpKfWY1PTL4PjS4WdIdmrI2y9plCGea7Yib0ETOms8HfpsarlmGqcfMhYcKaIKU5rcBYirpGyBpoIBKqI7rImEipIJPIdpVVhqkmpKfWY1jKfHMyEw4DG4yQ4WZ77bKcZdzbSCD2JJdpioMko88(EaPW8qwalxN8epgihdEXO3QlZKbKX)ioMko88(EaPW8qwalxNsBdKpByWlgZDeahSqCmvC4599asH5HSawUoxy1(PmJ5ocCbXargpIJPIdpVVhqkmpKfWY1jGuP10)d9VB3IRdHPPj8Rn4W7N512ZYtJbPPmIdIdmrc2CxGu7GYibbpbKdjIJNqIGfHeMkWaK4EKWG3oTbPjpIJPIdppxfldirioMko88WY1z)MNN0ioWejsX6EK4EKGh)HwoKiWirpGGNMajuySoJDCEKybW8ibeDJesyk1LPjmTwoKy)ugjYBWnsibpgEINMWJ4atKWuXHNhwUob7HXuXHhg99HBJXtC5XWt80eUDlU8y4jEAcF((Wgf5s5J4yQ4WZdlxNSia(umAY6D7wCHlWUmdbpnHNhdpXtt4Z3h2Oix6Q8teyxMHGNMWZJHN4Pj834szs(Wjzsha2Lzi4Pj88y4jEAcp5c3hpIJPIdppSCD2JJdpioMko88WY15Ado8(zET9SC7wCdttt4xBWH3pZRTNLNgdst5eHl0ET8Rn4W7N512ZY)HPsld3Nmj0ET8Rn4W7N512ZYdiE7MxgUpzs4QWyDg744bKkTM(FO)9aI3U5LH7teAVw(1gC49Z8A7z5beVDZldzbh4G4yQ4WZdlxNaJV3Ki3UfxfgRZyhhpGuP10)d9Vhq82nVmCpIJPIdppSCDcPX4mdEXeSigAiE5C7wCH2RLhqQ0A6)H(3V7rCmvC45HLRZ(n4wYDJedK2(WTBX1bO9A5bKkTM(FO)97(eDaAVw()ijccqwAc439ioMko88WY1j4671eZnmFVPi3UfxhG2RLhqQ0A6)H(3V7t0bO9A5)JKiiazPjGF3J4yQ4WZdlxNoIb6m80nma6XJnkYTBX1bO9A5bKkTM(FO)97(eDaAVw()ijccqwAc439ioMko88WY15cR2pLzm3rGligiY4D7wCDaAVwEaPsRP)h6F)UprhG2RL)psIGaKLMa(DpIJPIdppSCDQWJIMaybLzwAJNC7wCDaAVwEaPsRP)h6F)UprhG2RL)psIGaKLMa(DFIzC4v4rrtaSGYmlTXtmqBW4beVDZZnbehtfhEEy56myrm7bcVNmZcduKB3Il0ET8asLwt)ZSWaf539ioMko88WY1P02a5Zgg8IXChbWbl3UfxhG2RLhqQ0A6)H(3V7rCmvC45HLRtEIhdKJbVy0B1LzYaY4F3UfxhG2RLhqQ0A6)H(3V7rCmvC45HLRtaPsRP)h6F3UfxhO)PrrEfEY08uMrFlAHbkYZBYdmizsfgRZyhhV02a5Zgg8IXChbWblpG4TBEx6AcjtcTxlV02a5Zgg8IXChbWbl)UhXXuXHNhwUoDK1b0oEt2TBX97jTMjmGefV3rwhq74nzxYEIoaTxlppzbJstg8eWV7rCmvC45HLRZ9tmxq8UngpXfy893iXy896l2zIr6Km4X6GHgPBiehtfhEEy56C)eZfe)J4yQ4WZdlxNqAmoZS2a5qCmvC45HLRtic8ei9nsioMko88WY1P(KyfpJ8yNL4PjC7wCH2RLhqQ0A6)H(3NXooioMko88WY156aeKgJZioMko88WY1Pnk6dGPzuMwJ4yQ4WZdlxNG9WyQ4WdJ((WTX4jU)nsAIjmGefioioMko88EEm8epnbxweaFkgnz9ioioMko88()gjnXegqIcU)rseeGS0eaXXuXHN3)3iPjMWasualxNaJV3Ki3Ufx4cTxlpGuP10)d9VF3Nmj0ET88epgihdEXO3QlZKbKX)(DpCsMeUHPPj8laoyDJedebEcKMaEAminLtMmmnnHxzGXKipngKMYjcxO9A5PbysKhq82nVmKu5KjbMe5szLaCsMmmnnHN3(3uaYtJbPPCIWfAVwEAaMe5beVDZldjvozsGjrUuwjah4G4yQ4WZ7)BK0etyajkGLRtYfi1oiehtfhEE)FJKMycdirbSCDcPTm9bgW72T42di4zKuzp7EGX3BseIJPIdpV)VrstmHbKOawUoZatcpmaSbC7wCH2RLNgGjr(DpIJPIdpV)VrstmHbKOawUoH0yCoyDGpC7wCH2RLNgGjr(m2XjzsZDe4cYRW6mZhePzyHdgingN9aBs7s2rCmvC459)nsAIjmGefWY1jWKUrIbsJD0TBXvXYas0Z1vehtfhEE)FJKMycdirbSCDcPX4CW6aFG4yQ4WZ7)BK0etyajkGLRtGjDJedKg7OB3IByAAcVYaJjrEAminLtMeUHPPj882)McqEAminLteysKmK3eGtYKWnmnnHFbWbRBKyGiWtG0eWtJbPPCIatIKHSsaoioMko88()gjnXegqIcy56CTbhE)mV2EwUDlUHPPj8Rn4W7N512ZYtJbPPmIJPIdpV)VrstmHbKOawUoH)ubgihdy)SqCmvC459)nsAIjmGefWY15X3tt(gjg4pvGbYH4yQ4WZ7)BK0etyajkGLRthzDaTJ3KROIQa]] )
end
