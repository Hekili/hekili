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


    spec:RegisterPack( "Fury", 20190712.2333, [[dKe4GaqiQqpsj0MOIAuGQCkqPEfOYSOs1TqvLDrv)IkzyGsogHyzekpduyAurY1OsPTrfH(gQQY4afPZrfyDkbzEGQ6EOu7JkfheuuluO6HurQMive1fPccBevvfJevvvojvezLOkZKks5Mubr7ujAOubLLsfbpvHPkKUkQQQAROQQ0xPcQ2Ru)ffdMOdtzXk1JjzYcUmYMv0Njy0OKtRYQvcQxluMnPUnQSBj)gYWvshNkiTCGNRQPl66GSDuv(oHQXdkIZtiTELaZxi2pu3I0r7rWsQxkgSeXbWI)ermVyWagUfgUThPORupwnvmtG6rzCup4FGaI2JvtunYcD0E8iiGI6bRmx)fYLlHlzbT9keNR)4G0wEOsbSz66poLRESHoD6KQE3JGLuVumyjIdGf)jIyEXGbmCRy8xpmOKfc0JXX50XsxyjmduSoU8aOVhSUqGQE3Ja9QESiwY)abeflD4gaCiaM3IyjRmx)fYLlHlzbT9keNR)4G0wEOsbSz66pofM3IyjpiTOyPiI5owkgSeXbyj)WsXGXcbdyG5H5Tiw60zzLa9leM3Iyj)WsyoeOaw6WG44iThZBrSKFyPt(EBRPawYH4J4OkXsxyj)hbqNclDAKTILktRXs4vOellIcualNiawEf)emoclvOkjyscBpM3Iyj)WshseFualJRTa9jcWHLwfWsNmWeqfw6eqgalTnIpclJRrOqY6aFILjclpUvaIpclNaYHcrLsuSenXsaPqCCufS8q1JLW7pUhlbiibwArXsYHczAy7X8wel5hwcZHafWY4wMAclhSqqjwMiSCfqke32sSeMDyonpM3Iyj)WsyoeOawY)EQebeflDcqplS02i(iS8Vsqt8lnGaLyPdN1b0IFvWJ5TiwYpSeMdbkGL8)pHLoPK4EFp03NFhTh)vcAIjnGaLD0EPiD0EyQ8qvp(JeOnGSyeOhuzBnf64D2lfRJ2dQSTMcD8EOaxsGZ6b8WYn0C6bKkMM(VO)9qRyzKiy5gAo9CehcikdAYOHuxGjaiJ79qRyjSXYirWs4HLPPPk9takzDLaZMapbIrapv2wtbSmseSmnnvPxzGYeipv2wtbS0zSeEy5gAo9ubmbYdio7QhlHpwkOcyzKiyjWeiS0nyPdGfwcBSmseSmnnvPNZ(3uaYtLT1ualDglHhwUHMtpvatG8aIZU6Xs4JLcQawgjcwcmbclDdw6ayHLWglHDpmvEOQhaJB1eOo7LWOJ2dtLhQ6bbtifus9GkBRPqhVZEPt1r7bv2wtHoEpuGljWz9yfq8XiOcEr8aJB1eOEyQ8qvp2AlqFIaCD2lDBhThuzBnf649qbUKaN1Jn0C6PcycKhAThMkpu1JaWeqfdazGo7LoXoApOY2Ak0X7HcCjboRhBO50tfWeiFajEHLrIGL2ciWLKxH0bMpjsZWcLmBncf8aRIHLUblfPhMkpu1JTgHcjRd8zN9s(RJ2dQSTMcD8EOaxsGZ6HILbeOhlzJLI1dtLhQ6bWeUsGzRrI3zVeM2r7HPYdv9yRrOqY6aF2dQSTMcD8o7LoOJ2dQSTMcD8EOaxsGZ6rAAQsVYaLjqEQSTMcyzKiyj8WY00uLEo7Ftbipv2wtbS0zSeycewcFSeMclSe2yzKiyj8WY00uL(jaLSUsGztGNaXiGNkBRPaw6mwcmbclHpw6ayHLWUhMkpu1dGjCLaZwJeVZEPiWQJ2dQSTMcD8EOaxsGZ6rAAQs)ecCiON512ZYtLT1uOhMkpu1Jje4qqpZRTNvN9srePJ2dtLhQ6bFNkrarzaqpREqLT1uOJ3zVueX6O9Wu5HQECCRufUsGHVtLiGO9GkBRPqhVZEPiWOJ2dtLhQ6H4SoGw8Rc9GkBRPqhVZo7bhIpIJQSJ2lfPJ2dtLhQ6blcGofJMS1EqLT1uOJ3zN9iqtdsND0EPiD0EyQ8qvpuSmGa1dQSTMcD8o7LI1r7HPYdv9yfIJJ09GkBRPqhVZEjm6O9GkBRPqhVhkWLe4SEapSeyxGH4JQ0ZH4J4Ok9H7tRuew6gSum3ILoJLa7cmeFuLEoeFehvP)kS0nyPt5wSe29Wu5HQEWIaOtXOjBTZEPt1r7HPYdv9yfLhQ6bv2wtHoEN9s32r7bv2wtHoEpuGljWz9innvPFcboe0Z8A7z5PY2AkGLoJLWdl3qZPFcboe0Z8A7z5)0uXWs4JLWalJebl3qZPFcboe0Z8A7z5beND1JLWhlHbwgjcwcpSuHq6as8Ydivmn9Fr)7beND1JLWhlHbw6mwUHMt)ecCiON512ZYdio7QhlHpw6aSe2yjS7HPYdv9ycboe0Z8A7z1zV0j2r7bv2wtHoEpuGljWz9qHq6as8Ydivmn9Fr)7beND1JLWhlHrpmvEOQhaJB1eOo7L8xhThuzBnf649qbUKaN1Jn0C6bKkMM(VO)9qR9Wu5HQES1iuGbnzswedveNOD2lHPD0EqLT1uOJ3df4scCwpCel3qZPhqQyA6)I(3dTILoJLoILBO50)hjqBazXiGhAThMkpu1JviWnf9kbMT2(SZEPd6O9GkBRPqhVhkWLe4SE4iwUHMtpGuX00)f9VhAflDglDel3qZP)psG2aYIrap0ApmvEOQhGBDvtmxX8RMI6SxkcS6O9GkBRPqhVhkWLe4SE4iwUHMtpGuX00)f9VhAflDglDel3qZP)psG2aYIrap0ApmvEOQhIJa6aF0vma6rLvkQZEPiI0r7bv2wtHoEpuGljWz9WrSCdnNEaPIPP)l6Fp0kw6mw6iwUHMt)FKaTbKfJaEO1EyQ8qvpMif0tbgBbe4sIztgxN9sreRJ2dQSTMcD8EOaxsGZ6HJy5gAo9asftt)x0)EOvS0zS0rSCdnN()ibAdilgb8qRyPZyzaLEfQuuLalPaZuBCeZgcuEaXzx9yjBSew9Wu5HQEOqLIQeyjfyMAJJ6Sxkcm6O9GkBRPqhVhkWLe4SESHMtpGuX00)mteqrEO1EyQ8qvpsweduTrqvGzIakQZEPiovhThuzBnf649qbUKaN1dhXYn0C6bKkMM(VO)9qR9Wu5HQEiazGWzfdAYylGaOKvN9srCBhThuzBnf649qbUKaN1dhXYn0C6bKkMM(VO)9qR9Wu5HQEWrCiGOmOjJgsDbMaGmUVZEPioXoApOY2Ak0X7HcCjboRhoIL0)uPiVcvbQEkWOVjnraf55SfgbWsNXshXs6FQuKFRrOadAYKSigQior9C2cJayzKiyPcH0bK4LxaYaHZkg0KXwabqjlpG4SRES0nyPyWclJebl3qZPxaYaHZkg0KXwabqjlp0kwgjcwQqiDajE53AekWGMmjlIHkItupG4SRESe(yPGk0dtLhQ6bGuX00)f9FN9sr4VoApOY2Ak0X7HcCjboRh)kP1mPbeO89IZ6aAXVkGLUblfblDglDel3qZPNJSKrPjJpc4Hw7HPYdv9qCwhql(vHo7LIat7O9GkBRPqhVhLXr9ayCRxjWyCR6lHceJWjy8H0jdvcxr9Wu5HQEamU1ReymUv9LqbIr4em(q6KHkHROo7LI4GoApmvEOQhqpXCjX99GkBRPqhVZEPyWQJ2dtLhQ6XwJqbMjeq0EqLT1uOJ3zVumr6O9Wu5HQESjWtGyxj0dQSTMcD8o7LIjwhThuzBnf649qbUKaN1Jn0C6bKkMM(VO)9bK4vpmvEOQh6tGv(mlmuqGJQSZEPyWOJ2dtLhQ6X8a0wJqHEqLT1uOJ3zVumNQJ2dtLhQ6Hvk6tGPzuMw3dQSTMcD8o7LI52oApOY2Ak0X7HPYdv9aavmMkpuXOVp7H((KPmoQh)vcAIjnGaLD2zpwbKcXTTSJ2lfPJ2dQSTMcD8o7LI1r7bv2wtHoEN9sy0r7bv2wtHoEN9sNQJ2dtLhQ6X2Yutmpleu2dQSTMcD8o7LUTJ2dtLhQ6Xkkpu1dQSTMcD8o7LoXoApmvEOQhCehcikdAYOHuxGjaiJ77bv2wtHoEN9s(RJ2dtLhQ6HaKbcNvmOjJTacGsw9GkBRPqhVZEjmTJ2dtLhQ6XePGEkWylGaxsmBY46bv2wtHoEN9sh0r7bv2wtHoEpuGljWz9WrSmnnvPFcboe0Z8A7z5PY2Ak0dtLhQ6bGuX00)f9FND2zp4Ja)HQEPyWsehal(dw8NxmXeXT9qCduxj89WjXTIajfWsNclnvEOcl13NVhZRhRa080upwel5FGaIILoCdaoeaZBrSKvMR)c5YLWLSG2EfIZ1FCqAlpuPa2mD9hNcZBrSKhKwuSueXChlfdwI4aSKFyPyWyHGbmW8W8welD6SSsG(fcZBrSKFyjmhcualDyqCCK2J5TiwYpS0jFVT1ual5q8rCuLyPlSK)JaOtHLonYwXsLP1yj8kuILfrbkGLtealVIFcghHLkuLemjHThZBrSKFyPdjIpkGLX1wG(eb4WsRcyPtgycOclDcidGL2gXhHLX1iuizDGpXYeHLh3kaXhHLta5qHOsjkwIMyjGuiooQcwEO6Xs49h3JLaeKalTOyj5qHmnS9yElIL8dlH5qGcyzCltnHLdwiOeltewUcifIBBjwcZomNMhZBrSKFyjmhcual5FpvIaIILobONfwABeFew(xjOj(LgqGsS0HZ6aAXVk4X8wel5hwcZHafWs()NWsNusCVhZdZBrS0HaMqkOKcy5MMiaHLke32sSCtcx9ESeMvkAnFSSqf)yzaUjKglnvEO6XsuPf1J5zQ8q17xbKcXTTK9uBFmmptLhQE)kGuiUTLWX21eHcyEMkpu9(vaPqCBlHJTldsGJQ0YdvyElILJYwFwOelb2fWYn0CsbS8tlFSCtteGWsfIBBjwUjHRES0QawUci(TIY8kbS8ESmGkYJ5zQ8q17xbKcXTTeo2U2wMAI5zHGsmptLhQE)kGuiUTLWX21kkpuH5zQ8q17xbKcXTTeo2U4ioequg0KrdPUataqg3J5zQ8q17xbKcXTTeo2UeGmq4SIbnzSfqauYcZZu5HQ3VcifIBBjCSDnrkONcm2ciWLeZMmomptLhQE)kGuiUTLWX2fGuX00)f9V73KTJPPPk9tiWHGEMxBplpv2wtbmpmVfXshcycPGskGLeFequSmpocltwewAQebWY7XsJp702wtEmptLhQE2kwgqGW8mvEO6HJTRvioosJ5TiwgL19y59yjh6tTOyzIWYvaXhvjwQqiDajE9y5eG4WYnDLawAk1fOknTwuSe6PawgGaxjGLCi(ioQspM3IyPPYdvpCSDbGkgtLhQy03NUxghXMdXhXrv6(nzZH4J4Ok9H7tRuKBClMNPYdvpCSDXIaOtXOjB19BYgEa7cmeFuLEoeFehvPpCFALICJyU1zGDbgIpQsphIpIJQ0FLBCk3cBmptLhQE4y7AfLhQW8mvEO6HJTRje4qqpZRTNL73KDAAQs)ecCiON512ZYtLT1uWz4THMt)ecCiON512ZY)PPIbFyejYgAo9tiWHGEMxBplpG4SRE4dJirGNcH0bK4LhqQyA6)I(3dio7Qh(WW5n0C6NqGdb9mV2EwEaXzx9W3bWg2yEMkpu9WX2fW4wnbY9BYwHq6as8Ydivmn9Fr)7beND1dFyG5zQ8q1dhBxBncfyqtMKfXqfXjQ73K9gAo9asftt)x0)EOvmptLhQE4y7AfcCtrVsGzRTpD)MSDCdnNEaPIPP)l6Fp0QZoUHMt)FKaTbKfJaEOvmptLhQE4y7cCRRAI5kMF1uK73KTJBO50divmn9Fr)7HwD2Xn0C6)JeOnGSyeWdTI5zQ8q1dhBxIJa6aF0vma6rLvkY9BY2Xn0C6bKkMM(VO)9qRo74gAo9)rc0gqwmc4HwX8mvEO6HJTRjsb9uGXwabUKy2KX5(nz74gAo9asftt)x0)EOvNDCdnN()ibAdilgb8qRyEMkpu9WX2LcvkQsGLuGzQnoY9BY2Xn0C6bKkMM(VO)9qRo74gAo9)rc0gqwmc4HwDoGsVcvkQsGLuGzQnoIzdbkpG4SRE2WcZZu5HQho2UsweduTrqvGzIakY9BYEdnNEaPIPP)zMiGI8qRyEMkpu9WX2LaKbcNvmOjJTacGswUFt2oUHMtpGuX00)f9VhAfZZu5HQho2U4ioequg0KrdPUataqg37(nz74gAo9asftt)x0)EOvmptLhQE4y7cqQyA6)I(39BY2r6FQuKxHQavpfy03KMiGI8C2cJao7i9pvkYV1iuGbnzswedveNOEoBHrGiruiKoGeV8cqgiCwXGMm2ciakz5beND17gXGvKiBO50lazGWzfdAYylGaOKLhAnsefcPdiXl)wJqbg0KjzrmurCI6beND1dFbvaZZu5HQho2UeN1b0IFvW9BY(xjTMjnGaLVxCwhql(vb3iIZoUHMtphzjJstgFeWdTI5zQ8q1dhBxqpXCjX5EzCeBGXTELaJXTQVekqmcNGXhsNmujCfH5zQ8q1dhBxqpXCjX9yEMkpu9WX21wJqbMjequmptLhQE4y7AtGNaXUsaZZu5HQho2U0NaR8zwyOGahvP73K9gAo9asftt)x0)(as8cZZu5HQho2UMhG2AekG5zQ8q1dhBxwPOpbMMrzAnMNPYdvpCSDbGkgtLhQy03NUxghX(VsqtmPbeOeZdZZu5HQ3ZH4J4OkzZIaOtXOjBfZdZZu5HQ3)xjOjM0acuY(psG2aYIramptLhQE)FLGMysdiqjCSDbmUvtGC)MSH3gAo9asftt)x0)EO1ir2qZPNJ4qarzqtgnK6cmbazCVhAf2rIaV00uL(jaLSUsGztGNaXiGNkBRPqKiPPPk9kduMa5PY2Ak4m82qZPNkGjqEaXzx9WxqfIebycKBCaSGDKiPPPk9C2)McqEQSTMcodVn0C6PcycKhqC2vp8fuHiraMa5ghalydBmptLhQE)FLGMysdiqjCSDrWesbLeMNPYdvV)VsqtmPbeOeo2U2AlqFIaCUFt2RaIpgbvWlIhyCRMaH5zQ8q17)Re0etAabkHJTRaWeqfdaza3Vj7n0C6PcycKhAfZZu5HQ3)xjOjM0acuchBxBncfswh4t3Vj7n0C6PcycKpGeVIeXwabUK8kKoW8jrAgwOKzRrOGhyvm3icMNPYdvV)VsqtmPbeOeo2UaMWvcmBnsC3VjBfldiqpBXW8mvEO69)vcAIjnGaLWX21wJqHK1b(eZZu5HQ3)xjOjM0acuchBxat4kbMTgjU73KDAAQsVYaLjqEQSTMcrIaV00uLEo7Ftbipv2wtbNbMabFykSGDKiWlnnvPFcqjRRey2e4jqmc4PY2Ak4mWei47aybBmptLhQE)FLGMysdiqjCSDnHahc6zET9SC)MStttv6NqGdb9mV2EwEQSTMcyEMkpu9()kbnXKgqGs4y7IVtLiGOmaONfMNPYdvV)VsqtmPbeOeo2UoUvQcxjWW3PsequmptLhQE)FLGMysdiqjCSDjoRdOf)Qqp(vs1l5pX6SZUba]] )
end
