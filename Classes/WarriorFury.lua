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
                local swing = state.combat == 0 and state.now or state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = "mainhand_speed",

            stop = function () return state.time == 0 end,

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

            stop = function () return state.time == 0 end,
            
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
        if buff.bladestorm.up then setCooldown( "global_cooldown", max( cooldown.global_cooldown.remains, buff.bladestorm.remains ) ) end
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


    spec:RegisterPack( "Fury", 20180930.2345, [[dCefyaqiIs1JebBse1OifDksHxraZIuXTGsSlQ6xqLHru5yKQSmsLEgrX0iQQRbezBeLIVruknoGOohrjRdkvnprK7rq7teYbHsPfcqpekvAIqPIlcLe2irvmsOKOtcekReQAMqjPBceQ2jqAOablfkfpvIPcGVceYEv8xrAWO6WuwSKEmvMSOUmYMH4ZeA0qXPvA1evPxduMnj3Mi7wQFJYWb0XHsklh0Zv10fUoK2oq13jqJxeQZtQQ1dLunFsP9RYJEdatjBbnGQRC6bYYjlzKZRRmYxgzK)uc9bstbO5aZePP0Menf5bfQ)uaA6RywEaykpdf6OPGjcGp2JdN4gyqREhtc3VsOklww7GgsG7xjhUQIvXvrmSKjWXbeYqwf94abiHn2MFCGa2KcImiCzWu5bfQV)xj3uQORkaX6PoLSf0aQUYPhilNSKroVUYiFzKr3PyObggCkLvc7ECChhBHomRuSq2pfmBot9uNsME3us44Ydku)JdImiCzWdFchhteaFShhoXnWGw9oMeUFLqvwSS2bnKa3VsoCvfRIRIyyjtGJdiKHSk6XbcqcBSn)4abSjfezq4YGPYdkuF)VsUdFchVqadsQsWJlJC6CCDLtpq(4y546kd2lF5o8h(eoo2fJ1I0J9h(eoowoo2MZu(4GaQKeP8h(eoowoo2zFRQO8XLyGtsuhhh3XXkjiBDhhRsgWJ7mL64A2S44nrzkFCeg84BJfrtIoUJ1bL4qd)HpHJJLJdIZaNYhhqLLPpyqPJBD(4yhOjY6JJnmdECRYaNooGkglhyw4hhpyhFLaczGthhbsynuQD6FCgYXHKJjjrD2IL1)X18xP)4VAfXek9poMvedb1WF4t44y54yBot5JdOfHIoEbddnoEWooqi5ysvloo2ccyv)uu7h)aWu(TfvuAyqrkgagq1BaykMlwwpLFjrQcjdmcofQTQIYdGtmGQ7aWuO2QkkpaofhCdcU2uQOiiEi5atr)30)EuGhxR2JR5XdtrD4rGSaZ2IPvc(eemc6P2QkkFCTApEykQdVZGTjsEQTQIYhp5JR5XROiiEQHMi5HKKT9F8KoUOlFCTApo0ePJNOJll5oUghxR2JhMI6Wlz)Boi5P2QkkF8KpUMhVIIG4PgAIKhss22)Xt64IU8X1Q94qtKoEIoUSK74ACCnMI5IL1tbAsanrAIbuzgaMc1wvr5bWP4GBqW1MsffbXtn0ejpkWPyUyz9uOeto0GMyav(datHARQO8a4uCWni4AtPIIG4PgAIKpZeSNI5IL1tPQySCGzHFmXakinamfQTQIYdGtXb3GGRnfhgdks)XfECDNI5IL1tbAIBlMwvmbNyav2mamfQTQIYdGtXb3GGRnfGqc8urx2RNhAsanr64jFCnpEMQOii(FjrQcjdmc6rbECTApUSF8Wuuh(FjrQcjdmc6P2QkkFCnMI5IL1tPQSm9bdknXaQSDaykuBvfLhaNIdUbbxBkvueep1qtK8OaNI5IL1tjdnrwNczgCIbuqEaykMlwwpLQIXYbMf(XuO2QkkpaoXaQSgaMc1wvr5bWP4GBqW1MsykQdVZGTjsEQTQIYhxR2JR5XdtrD4LS)nhK8uBvfLpEYhhAI0Xt64GSChxJJRv7X184HPOo8iqwGzBX0kbFccgb9uBvfLpEYhhAI0Xt64YsUJRXumxSSEkqtCBX0QIj4edO6j3aWuO2QkkpaofhCdcU2uctrD4rqHld9tFL9y8uBvfLNI5IL1tbbfUm0p9v2JzIbu90BaykMlwwpfbXSqLGBNNc1wvr5bWjMykzcXqvXaWaQEdatXCXY6P4WyqrAkuBvfLhaNyav3bGPyUyz9uaIkjrQPqTvvuEaCIbuzgaMc1wvr5bWP4GBqW1MIMhhABoLaN6WlXaNKOo859dRD0Xt0X1fKoEYhhABoLaN6WlXaNKOo8BF8eDC5dshxJJRv7XL9JdTnNsGtD4LyGtsuhEkX7h)umxSSEkyiiBDPkYaoXaQ8haMI5IL1tbilwwpfQTQIYdGtmGcsdatHARQO8a4uCWni4Atjmf1HhbfUm0p9v2JXtTvvu(4jFCnpEffbXJGcxg6N(k7X4)WCGD8KoUmhxR2Jxrrq8iOWLH(PVYEmEijzB)hpPJlZX1Q94AEChJPYmbBpKCGPO)B6FpKKST)JN0XL54jF8kkcIhbfUm0p9v2JXdjjB7)4jDCzDCnoUgtXCXY6PGGcxg6N(k7XmXaQSzaykuBvfLhaNIdUbbxBkewdDbcKYEWmSow3uwItrqL3LY2NIGc1)4jFCnpEffbXJGkVlLTpfbfQVpZeSpUwThhss22)Xt646ECnMI5IL1tPQySCGzHFmXaQSDaykuBvfLhaNIdUbbxBkogtLzc2Ei5atr)30)EijzB)hpPJlZumxSSEkqtcOjstmGcYdatXCXY6Pajhyk6)M(FkuBvfLhaNyavwdatHARQO8a4uCWni4At5bskvAyqrkEVGywOsWTZhprhxVJN8XL9Jxrrq8sKfPofzGtqpkWPyUyz9ueeZcvcUDEIbu9KBaykuBvfLhaNIdUbbxBkvueepKCGPO)B6FpkWPyUyz9uQkglNIGc1FIbu90BaykuBvfLhaNIdUbbxBkvueepKCGPO)B6FpkWPyUyz9uQe8jiyBloXaQE6oamfQTQIYdGtXb3GGRnLkkcIhsoWu0)n9VpZeSNI5IL1trTIyIpvErZIsuhtmGQNmdatHARQO8a4uCWni4AtPIIG4HKdmf9Ft)7rbofZflRNcYcPQIXYtmGQN8haMc1wvr5bWP4GBqW1MsffbXdjhyk6)M(3JcCkMlwwpfRD0hqtL6mLAIbu9aPbGPqTvvuEaCkMlwwpfiANAUyzDQA)ykQ9J02KOP8BlQO0WGIumXetbiKCmPQfdadO6namfQTQIYdGtmGQ7aWuO2QkkpaoXaQmdatHARQO8a4edOYFaykuBvfLhaNyafKgaMI5IL1tPArOO0hddnMc1wvr5bWjgqLndatXCXY6PaKflRNc1wvr5bWjMyIPaob)L1dO6kNEGSCYsg586kJ81DkcAWEBXFkGysazWGYhxMJBUyz9Xv7hV)WpfGqgYQOPKWXLhuO(hhezq4YGh(eooMia(ypoCIBGbT6DmjC)kHQSyzTdAibUFLC4QkwfxfXWsMahhqidzv0JdeGe2yB(XbcytkiYGWLbtLhuO((FLCh(eoEHagKuLGhxg50546kNEG8XXYX1vgSx(YD4p8jCCSlgRfPh7p8jCCSCCSnNP8Xbbujjs5p8jCCSCCSZ(wvr5JlXaNKOoooUJJvsq26oowLmGh3zk1X1SzXXBIYu(4im4X3glIMeDChRdkXHg(dFchhlhheNboLpoGkltFWGsh368XXoqtK1hhByg84wLboDCavmwoWSWpoEWo(kbeYaNoocKWAOu70)4mKJdjhtsI6SflR)JR5Vs)XF1kIju6FCmRigcQH)WNWXXYXX2CMYhhqlcfD8cggAC8GDCGqYXKQwCCSfeWQ(d)HpHJJvKyYHgu(4vcHbPJ7ysvloELe3(9hhBDocy8hVznwWyqjeu1XnxSS(poRv67p8Mlww)EGqYXKQwierzpyhEZflRFpqi5ysvleqioeglF4nxSS(9aHKJjvTqaH4murjQdlwwF4t44L2a(yyXXH2MpEffbHYh)dl(JxjegKoUJjvT44vsC7)4wNpoqiHfGSi2w847F8mRj)H3CXY63desoMu1cbeI7Bd4JHfPFyXF4nxSS(9aHKJjvTqaH4Qwekk9XWqJdV5IL1VhiKCmPQfciehqwSS(WF4t44yfjMCObLpobob1)4XkrhpWqh3CbdE89pUbUTkRQi)H3CXY6xOdJbfPdV5IL1VacXbevsIuh(eooay2)47FCj2hk9pEWooqibo1XXDmMkZeS)JJazshVsBlECZ52m1HPu6FC0NYhpJc3w84smWjjQd)HpHJBUyz9lGqCq0o1CXY6u1(HoTjrcLyGtsuh6SicLyGtsuh(8(H1okrG0H3CXY6xaH4Wqq26svKbuNfrOMqBZPe4uhEjg4Ke1HpVFyTJsKUGuYqBZPe4uhEjg4Ke1HF7ejFqsdTALDOT5ucCQdVedCsI6WtjE)4p8Mlww)ciehqwSS(WBUyz9lGqCiOWLH(PVYEm6SicdtrD4rqHld9tFL9y8uBvfLtwZkkcIhbfUm0p9v2JX)H5aljz0QTIIG4rqHld9tFL9y8qsY2(tsgTA10XyQmtW2djhyk6)M(3djjB7pjzsUIIG4rqHld9tFL9y8qsY2(tswAOXH3CXY6xaH4Qkglhyw4h6SicjSg6ceiL9GzyDSUPSeNIGkVlLTpfbfQFYAwrrq8iOY7sz7trqH67ZmbBTAHKKT9NKUAC4nxSS(fqioOjb0ejDweHogtLzc2Ei5atr)30)EijzB)jjZH3CXY6xaH4GKdmf9Ft)F4nxSS(fqiobXSqLGBN1zre(ajLknmOifVxqmluj425ePxYYEffbXlrwK6uKbob9Oap8Mlww)ciexvXy5ueuO(6SicROiiEi5atr)30)EuGhEZflRFbeIRsWNGGTTOolIWkkcIhsoWu0)n9Vhf4H3CXY6xaH4uRiM4tLx0SOe1HolIWkkcIhsoWu0)n9VpZeSp8Mlww)ciehYcPQIXY6SicROiiEi5atr)30)EuGhEZflRFbeIZAh9b0uPotP0zrewrrq8qYbMI(VP)9Oap8Mlww)cieheTtnxSSovTFOtBsKWFBrfLgguKId)HpHJBUyz97LyGtsuhcXqq26svKb8WF4nxSS(9)2IkknmOifc)LePkKmWi4H3CXY63)BlQO0WGIuiGqCqtcOjs6SicROiiEi5atr)30)EuGA1QzykQdpcKfy2wmTsWNGGrqp1wvrzTAdtrD4DgSnrYtTvvuoznROiiEQHMi5HKKT9NKOlRvl0ePejl50qR2WuuhEj7FZbjp1wvr5K1SIIG4PgAIKhss22FsIUSwTqtKsKSKtdno8Mlww)(FBrfLgguKcbeIJsm5qdsNfryffbXtn0ejpkWdV5IL1V)3wurPHbfPqaH4Qkglhyw4h6SicROiiEQHMi5Zmb7dV5IL1V)3wurPHbfPqaH4GM42IPvftqDweHomguKEH6E4nxSS(9)2IkknmOifciexvzz6dgusNfriqibEQOl71ZdnjGMiLSMzQIIG4)LePkKmWiOhfOwTYEykQd)VKivHKbgb9uBvfL14WBUyz97)TfvuAyqrkeqiUm0ezDkKzqDweHvueep1qtK8Oap8Mlww)(FBrfLgguKcbeIRQySCGzHFC4nxSS(9)2IkknmOifcieh0e3wmTQycQZIimmf1H3zW2ejp1wvrzTA1mmf1HxY(3CqYtTvvuozOjsjbYYPHwTAgMI6WJazbMTftRe8jiye0tTvvuozOjsjjl504WBUyz97)TfvuAyqrkeqioeu4Yq)0xzpgDweHHPOo8iOWLH(PVYEmEQTQIYhEZflRF)VTOIsddksHacXjiMfQeC78uEGKBav2Q7etmda]] )
end
