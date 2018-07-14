-- WarriorFury.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 72 )

    local base_rage_gen, fury_rage_mult = 1.75, 0.80
    local offhand_mod = 0.80

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand_fury = {
            -- setting = "forecast_fury",

            last = function ()
                local swing = state.combat == 0 and state.now or state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = "mainhand_speed",

            stop = function () return state.time == 0 end,

            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * ( base_rage_gen * fury_rage_mult * state.swings.mainhand_speed )
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

            stop = function () return state.time == 0 end,
            
            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * fury_rage_mult * state.swings.mainhand_speed * offhand_mod
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
        if state.talent.recklessness.enabled and resource == "rage" then
            rageSpent = rageSpent + amt
            state.cooldown.recklessness.expires = state.cooldown.recklessness.expires - floor( rageSpent / 20 )
            rageSpent = rageSpent % 20
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        rageSpent = 0
    end )


    -- Auras
    spec:RegisterAuras( {
        battle_shout = {
            id = 6673,
            duration = 3600,
            max_stack = 1,
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


    -- Abilities
    spec:RegisterAbilities( {
        battle_shout = {
            id = 6673,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132333,
            
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
            end,
        },
        

        charge = {
            id = 100,
            cast = 0,
            charges = function () return talent.double_time.enabled and 2 or 1 end,
            cooldown = function () return talent.double_time.enabled and 17 or 20 end,
            recharge = function () return talent.double_time.enabled and 17 or 20 end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132337,
            
            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd ) end,
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
            id = 280735,
            known = 5308,
            cast = 0,
            cooldown = 6,
            hasteCD = true,
            gcd = "spell",
            
            spend = -20,
            spendType = "rage",
            
            startsCombat = true,
            texture = 135358,
            
            usable = function () return buff.sudden_death.up or buff.stone_heart.up or target.health.pct < ( talent.massacre.enabled and 35 or 20 ) end,
            handler = function ()
                if buff.stone_heart.up then removeBuff( "stone_heart" )
                else removeBuff( "sudden_death" ) end
            end,
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
            
            handler = function ()
                if buff.furious_slash.stack < 3 then stat.haste = stat.haste + 0.02 end
                addStack( "furious_slash", 15, 1 )
            end,
        },
        

        heroic_leap = {
            id = 6544,
            cast = 0,
            charges = function () return ( level < 116 and equipped.timeless_stratagem ) and 3 or 1 end,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            recharge = function () return talent.bounding_stride.enabled and 30 or 45 end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 236171,

            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd ) end,
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
            
            usable = function () return target.casting end,
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
                applyBuff( "whirlwind" )

                if talent.meat_cleaver.enabled then
                    gain( min( 11, 3 + min( 3, active_enemies ) + active_enemies ), "rage" )
                else
                    gain( min( 8, 3 + active_enemies ), "rage" )
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
    
        package = "Fury",
    } )


    spec:RegisterPack( "Fury", 20180714.1115, [[dG0SHaqievzrKkfEKkkAtuI(KuYOur1PqeEfPKzrQ4wQOu2ff)cfzyeKogPulJGQNrqzAiQ01qe12ivQ6Bus04quvNdrK1rQK5Hi5EeyFis1bjiAHucxufLkBufLQ(OkkyKQOqDskjSssXmPK0orugkPsrlvfL8uKAQQixvffYxjvkTxu9xk1Gv1HfTyK8ysMSuDzWMvPpJsJwkoTIvtq41OWSj62eA3s(nudxfooIkwoKNt10v66iSDuuFNu14rKY5PKA9KkvMVuQ9lmxB(joDpxGtMWfQ2KVqTsTjxJ2ARTvkmsMtVwFaC6JuXizboDLIaN(SNaznN(iTwIZo)eN2XeifWPfsKQze3bHDonfXixRO4uC6EUaNmHluTjFHALAtUgT1wOKejBLC6KyBWioTqIunJ4oiSZP7GR40NAgp(XJpJ)ivmswiE8n(uTdUIxo(6XFXO4pJbgJCmHMqZPgiEHu30QXRp94pqyMNo0JNY64fsKQze3bH94ZQh)4XNXRhJyC2M6SDGWSiWDtOj0yfXJarmZqp(TbIx3qeZmic1QBe)rIwpE8n(TbIxi1nTA8(uki(TbSo(ebXx4nEchUeY4Nk(TbIxHRfiTnE8n(Tz84ZEhxgoTC815N40(uSsWEtelS8tCY0MFItdvsjHo3coTcnlGMKttrCVgeOyib3lWDdXr8TBhVcJLDS(YGafdj4EbUBqGyoLhpPhVWjFoDQ2bxCAFawGcbjdaXxozcNFItdvsjHo3coTcnlGMKttrCVgeOyib3lWDdXr8TBh)5XVPeQ1Cr4TzkwBka5aIbGmqLusOhF72XVPeQ1OsuLSGbQKsc94Tm(ZJNI4EnqHswWGaXCkpEsfpRQhF72XJswiEspEssOXtI4B3o(nLqTgX09uHadujLe6XBz8NhpfX9AGcLSGbbI5uE8KkEwvp(2TJhLSq8KE8KKqJNeXtcoDQ2bxCAukEKSaF5Kjm(jonujLe6Cl40k0SaAsonfX9AGcLSGH4GtNQDWfNginqrSaF5KrU8tCAOskj05wWPvOzb0KCAkI71afkzbthRV40PAhCXPPKyCFBgKV8LtgjZpXPHkPKqNBbNwHMfqtYPvnjIf84feVW50PAhCXPrj7uS2usSE(Yjt3ZpXPt1o4IttjX4(2miF50qLusOZTGVCYSs(jonujLe6Cl40k0SaAso9bcy2Mv1nABqP4rYcXBz8NhpfX9A8bybkeKmaKH4i(2TJN8IFtjuRXhGfOqqYaqgOskj0JNeC6uTdU40uYSd(IrI8Ltg5ZpXPHkPKqNBbNwHMfqtYPPiUxduOKfmehXBz8NhpfX9A8bybkeKmaKH4i(2TJN8IFtjuRXhGfOqqYaqgOskj0JNeC6uTdU40DuYIlBeor8LtgjXpXPHkPKqNBbNwHMfqtYP3uc1AujQswWavsjHE8TBh)5XVPeQ1iMUNkeyGkPKqpElJhLSq8KkEYxOXtI4B3o(ZJFtjuR5IWBZuS2uaYbedazGkPKqpElJhLSq8KkEssOXtcoDQ2bxCAuYofRnLeRNVCY0wO8tCAOskj05wWPvOzb0KC6nLqTMlbAWeUTltVXavsjHoNov7Glo9Lanyc32LP3WxozARn)eNov7GloT(Mbj1pvNtdvsjHo3c(YxoTiMzqeQLFItM28tC6uTdU40nacpkBjKhCAOskj05wWx(YP7WnjKl)eNmT5N40PAhCXPtIfBN7MkgCAOskj05wWxozcNFItNQDWfNw1KiwGtdvsjHo3c(Yjty8tCAOskj05wWPvOzb0KC6ZJhLt3gygQ1SjIfwtF8nlfepPhVWj54TmEuoDBGzOwJiMzqeQ1mv8KE8KljhpjIVD74jV4r50TbMHAnIyMbrOwdqAJVoNov7GloDdGWJYwc5bF5KrU8tCAOskj05wWPvOzb0KCAGCiMJdOBqtXAJV2kSuMh(uS2xILabE8wgpfX9AGcLSGH4iElJN8INI4EnliES5o4YqCWPRue40OPyTXxBfwkZdFkw7lXsGaNtNQDWfNgnfRn(ARWszE4tXAFjwce48LtgjZpXPHkPKqNBbNwHMfqtYP3uc1AUeObt42Um9gdujLe6XBz8NhpfX9AUeObt42Um9gJVPIr8KkEHfF72XtrCVMlbAWeUTltVXGaXCkpEsfVWIVD74ppEfgl7y9LbbkgsW9cC3GaXCkpEsfVWI3Y4PiUxZLanyc32LP3yqGyoLhpPINKINeXtcoDQ2bxC6lbAWeUTltVHVCY098tCAOskj05wWPvOzb0KCAGCiMJdOByK6oDxktsZ(sied0t3(sGSoElJ)84PiUxZLqigONU9LazTPJ1xX3UD8iqmNYJNuXl84jbNov7GlonLeJ7BZG8LVCYSs(jonujLe6Cl40k0SaAsoTcJLDS(YGafdj4EbUBqGyoLhpPIxyC6uTdU40Ou8izb(YjJ85N40qLusOZTGtRqZcOj50kmw2X6ldcumKG7f4UbbI5uE8KkEHXPt1o4Itlh2M1TfcIoRiulF5Krs8tC6uTdU40iqXqcUxG7CAOskj05wWxozAlu(jonujLe6Cl40k0SaAsonqoeZXb0neIuOuAlIXfRmhMbpElJNI4EniqXqcUxG7gIJ4TmEkI71afkzbdXbNUsrGttisHsPTigxSYCygCoDQ2bxCAcrkukTfX4IvMdZGZxozARn)eNgQKscDUfCAfAwanjNMI4EniqXqcUxG7gIJ4TmEkI71afkzbdXbNUsrGtZyKcrcDOCBkcunfRT(XB40PAhCXPzmsHiHouUnfbQMI1w)4n8LtM2cNFItNQDWfNMWb7zbrNtdvsjHo3c(YjtBHXpXPHkPKqNBbNwHMfqtYPPiUxdcumKG7f4UH4GtNQDWfNMsIXD7lbYA(YjtBYLFItdvsjHo3coTcnlGMKttrCVgeOyib3lWDdXbNov7GlonfGCaXykw(YjtBsMFItdvsjHo3coTcnlGMKtJswiEsfVWfA8wgp5fpfX9AqGIHeCVa3nehC6uTdU40jsLfyVyecQLVCY0w3ZpXPHkPKqNBbNov7GlonIOSt1o4Ywo(YPLJV2vkcCAFkwjyVjIfw(Yxo9bcuyrQC5N4KPn)eNgQKscDUfC616dGtRWe1kb3TtK4aoF5KjC(jonujLe6Cl40R1haNEBa7gIIfzTTyYo(ci(Yjty8tCAOskj05wWPxRpaoDhUJe68Ltg5YpXPHkPKqNBbF5KrY8tCAOskj05wWPpW7Glonw2T1NioDQ2bxC6d8o4IV8LVCA9jQMI1506wH8SiZki7mOR4J)ude)iEGrB8xmk(w(uSsWEtelSTIhbKdXGGE8oweIpjwSyUqpEvtwSGBcnwDkiET1v8NAgpEOwK1XRAafdp(TbIxHXYowFf)fJIVLcJLDS(YGafdj4EbUBqGyoL3kE9nJQjEvwXtbXJaNqUXpv84EpEkOjzEWO4NB8TuySSJ1xgeOyib3lWDdceZP8wXpE8lMLvc94X3lt9Xtkj0nHMqJUviplYScYod6k(4p1aXpIhy0g)fJIVvhUjHCBfpcihIbb94DSieFsSyXCHE8QMSyb3eAS6uq8ARR4pJkN44aJwOhFQ2bxX3kjwSDUBQy0YeAS6uq8ctxXFwWHmvqp(wIyMbrOwtF8nlf0kE9Z2eFRnrSWA6JVzPGwXFU2KgjmHgRofep5QR4pl4qMkOhFlrmZGiuRPp(MLcAfV(zBIV1Miwyn9X3SuqR4pxBsJeMqJvNcIx3RR4p1mE8qTiRJx1akgE8BdeVcJLDS(k(lgfFlfgl7y9LbbkgsW9cC3GaXCkVv86Bgvt8QSINcIhboHCJFQ4X9E8uqtY8GrXp34BPWyzhRVmiqXqcUxG7geiMt5TIF84xmlRe6XJVxM6JNusOBcnwDkiEYxxXFQz84HArwhVQbum843giEfgl7y9v8xmk(wkmw2X6ldcumKG7f4UbbI5uER413mQM4vzfpfepcCc5g)uXJ794PGMK5bJIFUX3sHXYowFzqGIHeCVa3niqmNYBf)4XVywwj0JhFVm1hpPKq3eAS6uq8KKUI)uZ4Xd1ISoEvdOy4XVnq8kmw2X6R4Vyu8TuySSJ1xgeOyib3lWDdceZP8wXRVzunXRYkEkiEe4eYn(PIh37XtbnjZdgf)CJVLcJLDS(YGafdj4EbUBqGyoL3k(XJFXSSsOhp(EzQpEsjHUj0eAScXdmAHE8KB8PAhCfVC81nHgDRqEwKzfKDg0v8XFQbIFepWOn(lgfFlFkwjyVjIf2wXJaYHyqqpEhlcXNelwmxOhVQjlwWnHgRofeV26k(tnJhpulY64vnGIHh)2aXRWyzhRVI)IrX3sHXYowFzqGIHeCVa3niqmNYBfV(Mr1eVkR4PG4rGti34NkECVhpf0Kmpyu8Zn(wkmw2X6ldcumKG7f4UbbI5uER4hp(fZYkHE847LP(4jLe6MqtOr3kKNfzwbzNbDfF8NAG4hXdmAJ)IrX3Qd3KqUTIhbKdXGGE8oweIpjwSyUqpEvtwSGBcnwDkiET1v8NrLtCCGrl0Jpv7GR4BLel2o3nvmAzcnwDkiEHPR4pl4qMkOhFlrmZGiuRPp(MLcAfV(zBIV1Miwyn9X3SuqR4pxBsJeMqJvNcINK1v8NAgpEOwK1XRAafdp(TbIxHXYowFf)fJIVLcJLDS(YGafdj4EbUBqGyoL3kE9nJQjEvwXtbXJaNqUXpv84EpEkOjzEWO4NB8TuySSJ1xgeOyib3lWDdceZP8wXpE8lMLvc94X3lt9Xtkj0nHgRofeVvQR4p1mE8qTiRJx1akgE8BdeVcJLDS(k(lgfFlfgl7y9LbbkgsW9cC3GaXCkVv86Bgvt8QSINcIhboHCJFQ4X9E8uqtY8GrXp34BPWyzhRVmiqXqcUxG7geiMt5TIF84xmlRe6XJVxM6JNusOBcnwDkiEYxxXFQz84HArwhVQbum843giEfgl7y9v8xmk(wkmw2X6ldcumKG7f4UbbI5uER413mQM4vzfpfepcCc5g)uXJ794PGMK5bJIFUX3sHXYowFzqGIHeCVa3niqmNYBf)4XVywwj0JhFVm1hpPKq3eAcnwH4bgTqpEYn(uTdUIxo(6MqdN2pafNmRu4C6de(osGtNQDWLBoqGclsLRGRmDg6SwFacuyIALG72jsCap0KQDWLBoqGclsLRwcy6IXDDwRpabBdy3quSiRTft2XxafAs1o4YnhiqHfPYvlbmLeSIqT5o4sN16dqqhUJe6HMZmv7Gl3CGafwKkxTeWevUReS9gmXgAoZ4PR8WBWB8OC6XtrCVqpEFZ1JNcUyeeVclsLB8ua7uE8z1J)abNTd8UtXg)4X3XfycnPAhC5MdeOWIu5QLaM8kp8g8A7BUEOjv7Gl3CGafwKkxTeW0bEhCPtLIGaSSBRprHMqZzg)zhPbkIf6XdmdiRJFhri(TbIpvlgf)4XNmNJmPKGj0KQDWLlijwSDUBQyeAs1o4Y1satQMeXcHMZm(tnJh)4XlI9vAD8lo(deWmuB8kmw2X6lp(lclgpfmfB8PsnDO2ukToEch6X3jqtXgViMzqeQ1eAoZ4t1o4Y1satiIYov7GlB54RovkcceXmdIqT6mxbIyMbrOwtF8nlfq6KCOjv7Glxlbm1ai8OSLqEOZCfCokNUnWmuRreZmic1A6JVzPasx4KSLOC62aZqTgrmZGiuRzksNCjzs0Un5HYPBdmd1AeXmdIqTgG0gF9qZzMQDWLRLaMoW7GlDQueeGLDB9jsN5kGI4EniqXqcUxG7gIJqtQ2bxUwcyIWb7zbrDQueeGMI1gFTvyPmp8PyTVelbcCDMRaGCiMJdOBqtXAJV2kSuMh(uS2xILabULue3RbkuYcgIdljpkI71SG4XM7GldXrOj0KQDWLRLaMUeObt42Um9gDMRGnLqTMlbAWeUTltVXavsjHULNtrCVMlbAWeUTltVX4BQyqkH1UnfX9AUeObt42Um9gdceZPCsjS2TpxHXYowFzqGIHeCVa3niqmNYjLWSKI4Enxc0GjCBxMEJbbI5uoPijsqIqtQ2bxUwcyIsIX9Tzq(QZCfaKdXCCaDdJu3P7szsA2xcHyGE62xcK1wEofX9AUecXa90TVeiRnDS(QDBeiMt5Ks4Ki0KQDWLRLaMqP4rYc6mxbkmw2X6ldcumKG7f4UbbI5uoPewOjv7Glxlbmjh2M1TfcIoRiuRoZvGcJLDS(YGafdj4EbUBqGyoLtkHfAs1o4Y1satiqXqcUxG7HMuTdUCTeWeHd2ZcI6uPiiGqKcLsBrmUyL5Wm46mxba5qmhhq3qisHsPTigxSYCygClPiUxdcumKG7f4UH4WskI71afkzbdXrOjv7Glxlbmr4G9SGOovkccymsHiHouUnfbQMI1w)4n6mxba5qmhhq3WyKcrcDOCBkcunfRT(XB0zUcOiUxdcumKG7f4UH4WskI71afkzbdXrO5mt1o4Y1sateoypli66mxbue3RbbkgsW9cC3qCeAs1o4Y1sateoypli6HMuTdUCTeWeLeJ72xcK16mxbue3RbbkgsW9cC3qCeAs1o4Y1satuaYbeJPy1zUcOiUxdcumKG7f4UH4i0KQDWLRLaMsKklWEXieuRoZvakzbsjCHAj5rrCVgeOyib3lWDdXrOjv7GlxlbmHik7uTdUSLJV6uPiiWNIvc2BIyHn0eAs1o4YnIyMbrOwbnacpkBjKhHMqtQ2bxUXNIvc2BIyHvlbm5dWcuiizaiDMRakI71Gafdj4EbUBioA3wHXYowFzqGIHeCVa3niqmNYjDHt(HMuTdUCJpfReS3eXcRwcycLIhjlOZCfqrCVgeOyib3lWDdXr72NVPeQ1Cr4TzkwBka5aIbGmqLusO3U9MsOwJkrvYcgOskj0T8CkI71afkzbdceZPCsXQ6TBJswG0jjHsI2T3uc1Aet3tfcmqLusOB55ue3RbkuYcgeiMt5KIv1B3gLSaPtscLeKi0KQDWLB8PyLG9Miwy1sataPbkIf0zUcOiUxduOKfmehHMuTdUCJpfReS3eXcRwcyIsIX9Tzq(QZCfqrCVgOqjly6y9vOjv7Gl34tXkb7nrSWQLaMqj7uS2usSEDMRavtIybxGWdnPAhC5gFkwjyVjIfwTeWeLeJ7BZG8n0KQDWLB8PyLG9Miwy1satuYSd(IrI6mxbhiGzBwv3OTbLIhjly55ue3RXhGfOqqYaqgIJ2TjVnLqTgFawGcbjdazGkPKqNeHMuTdUCJpfReS3eXcRwcyQJswCzJWjsN5kGI4EnqHswWqCy55ue3RXhGfOqqYaqgIJ2TjVnLqTgFawGcbjdazGkPKqNeHMuTdUCJpfReS3eXcRwcycLStXAtjX61zUc2uc1AujQswWavsjHE72NVPeQ1iMUNkeyGkPKq3suYcKI8fkjA3(8nLqTMlcVntXAtbihqmaKbQKscDlrjlqkssOKi0KQDWLB8PyLG9Miwy1satxc0GjCBxMEJoZvWMsOwZLanyc32LP3yGkPKqp0KQDWLB8PyLG9Miwy1sat6BgKu)uD(Yxoha]] )
end
