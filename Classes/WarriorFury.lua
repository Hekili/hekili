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


    spec:RegisterPack( "Fury", 20190202.1142, [[dG0DzaqieOEKGytiGrjsCkrsVcHAwcs3sKYUe6xOkdteCme0YqP6zOuAAKu01qPOTrsK(gjLY4qG4CKewhjfMhcX9qvTprihuKkluQ4HKuQMicP6IiKuBeLcJeHu6KiKWkrjZKKiUjcjzNsvgQiulvKQEQuMQiARiKIVssj7vXFfyWeomLfd4XKAYI6YqBgv(mIgnqDALwncj61sLMnr3Me7wYVrA4a54iqQLRQNRY0P66Oy7sv9DssJNKOopjvRhbsMVGA)GEiCsoTS540J9eiufjWEcShjKq1KD2zFAU6GWPbY0DnsCALPGtJnyE1NgitDj1YtYPDuMxJtdS7Go1GhpY1bZae1ufE3QWinFPL(noN3TkAEaskapaolTm2NhONYTs84L4htVT5JxItFGAz)V0pGnyE1J3QONgaZkDIIAaMw2CC6XEceQIeypb2JeMa7QGTSpnJXbt)P1wf1ouWdks3RbVk((0BAG3CgRbyAz80tleOGnyE1Hc1Y(FPpKviqby3bDQbpEKRdMbiQPk8UvHrA(sl9BCoVBv08aKuaEaCwAzSppqpLBL4XlXpMEBZhVeN(a1Y(FPFaBW8QhVvrdzfcuWgiWZyV6qb7HcfSNaHQaksdkimb1GD2czbzfcuO2bBfjEQbKviqrAqr6YzmdfjMrrbLriRqGI0GcI(EgGeZqHcTpQGLdf8GcIw8PRgkujObck0MucfPuuhkkeZygk4OpuSvAKMccfAA5Ok7PgHScbksdkiQO9Xmu0rAz8C6RafwLHcI(BK0cksp1EOWaO9rOOJKsZo49phkCkuSkGEAFek4EKGMblT6qbLdkEutvuWkB(sRdks5wLdko5sc2LQdfGxsW4NAeYkeOinOiD5mMHIoM7sekAGPmou4uOa0JAQcG5qr6sSkjczfcuKguKUCgZqbrZQD6RouKEMdmuya0(iuCBrkX0C7jrhkulW7lvDRCCAY98BsoTBlsjg42tI(KC6r4KCAM2xAnTBrse4rRl(tdldqI5PZ4tp2NKtdldqI5PZ00)64V20ay44IpQ7kX7k8UidiOiCyOifOWnjwEK7Po4TidaW)WVl(rSmajMHIWHHc3Ky5rT9LrIrSmajMHccafPafamCCrSEJeJpQyBDqbrGcsDgkchgkEJeHIebfQibOivOiCyOWnjwEuXUZ0pgXYaKygkiauKcuaWWXfX6nsm(OIT1bfebki1zOiCyO4nsekseuOIeGIuHIuNMP9Lwt7nfqgjo(0JTtYPzAFP10qvg1moonSmajMNoJp9uZj50WYaKyE6mn9Vo(RnnagoUiwVrIXmv1ckchgkmck8xhJAQmhCoIYaWupaqsP54BvxOirqbHtZ0(sRPbiP0SdE)ZhF6XMtYPHLbiX80zA6FD8xBAAW2tIhuWhkyFAM2xAnT3i3ImaqsvD8PNkDsonSmajMNott)RJ)Atd0J9di15iHX3uazKiuqaOifOiJamCCXBrse4rRl(rgqqr4WqbbdfUjXYJ3IKiWJwx8JyzasmdfPont7lTMgG0Y450xz8PNABsonSmajMNott)RJ)AtdGHJlI1BKyKb00mTV0AA53iPvWtTF8Phbzsont7lTMgGKsZo49pFAyzasmpDgF6PIj50WYaKyE6mn9Vo(Rnn3Ky5rT9LrIrSmajMHIWHHIuGc3Ky5rf7ot)yeldqIzOGaqXBKiuqeOGGKauKkueomuKcu4MelpY9uh8wKba4F43f)iwgGeZqbbGI3irOGiqHksaksDAM2xAnT3i3ImaqsvD8PhHjmjNgwgGeZtNPP)1XFTP5MelpYX8lL5coPDGJyzasmpnt7lTMghZVuMl4K2bE8PhHeojNMP9LwtR)QD6REWZCGNgwgGeZtNXNEeY(KCAM2xAnTvbew5Tid6VAN(QpnSmajMNoJp9iKTtYPzAFP10uf8(sv3kpnSmajMNoJp(0YiNXi9j50JWj50mTV0AAAW2tItdldqI5PZ4tp2NKtZ0(sRPbIrrbLtdldqI5PZ4tp2ojNMP9Lwtde1xAnnSmajMNoJp9uZj50WYaKyE6mn9Vo(Rnn3Ky5roMFPmxWjTdCeldqIzOGaqrkqbadhxKJ5xkZfCs7ahp30DHcIafSfkchgkay44ICm)szUGtAh44Jk2whuqeOGTqr4WqrkqHMsLzQQv8rDxjExH3fFuX26GcIafSfkiauaWWXf5y(LYCbN0oWXhvSToOGiqHkGIuHIuNMP9LwtJJ5xkZfCs7ap(0JnNKtdldqI5PZ00)64V200uQmtvTIpQ7kX7k8U4Jk2whuqeOGTtZ0(sRP9MciJehF6PsNKtZ0(sRP9OUReVRW7MgwgGeZtNXNEQTj50WYaKyE6mn9Vo(RnTdekLbU9KOFrvbVVu1TYqrIGccHccafemuaWWXfvqZd0s06JFKb00mTV0AAQcEFPQBLhF6rqMKtdldqI5PZ0ktbN2BkG2ImWuajxNjJbKlP1Nk9aSi3cNMP9Lwt7nfqBrgykGKRZKXaYL06tLEawKBHJp9uXKCAM2xAnnMddwhvUPHLbiX80z8PhHjmjNgwgGeZtNPP)1XFTPbWWXfFu3vI3v4DrgqtZ0(sRPbiP0CahZR(4tpcjCsonSmajMNott)RJ)AtdGHJl(OUReVRW7ImGMMP9Lwtda)d)UBro(0Jq2NKtdldqI5PZ00)64V20ay44IpQ7kX7k8UyMQAnnt7lTMMCjb7xarjtMublF8PhHSDsonSmajMNott)RJ)AtdGHJl(OUReVRW7ImGMMP9LwtJBFeqsP5XNEeQMtYPHLbiX80zA6FD8xBAamCCXh1DL4DfExKb00mTV0AAwPXZFtgOnPC8PhHS5KCAyzasmpDMMP9Lwt7zQat7lTcK75ttUNhuMcoTBlsjg42tI(4JpnfAFublFso9iCsont7lTMgy8PRoqIgOPHLbiX80z8XNgOh1ufaZNKtpcNKtdldqI5PZ4tp2NKtdldqI5PZ4tp2ojNgwgGeZtNXNEQ5KCAyzasmpDgF6XMtYPzAFP10ar9LwtdldqI5PZ4tpv6KCAyzasmpDMM(xh)1MgbdfUjXYJCm)szUGtAh4iwgGeZqbbGccgkCtILhFu3vI3fyawLPveldqI5PzAFP10Eu3vI3v4DJp(4tRp(3sRPh7jqibHq2jmHi7SZoBonvTV2I8MgrHci67ygkutOW0(slOqUNFriRPDGq90tTX(0a9uUvItleOGnyE1Hc1Y(FPpKviqby3bDQbpEKRdMbiQPk8UvHrA(sl9BCoVBv08aKuaEaCwAzSppqpLBL4XlXpMEBZhVeN(a1Y(FPFaBW8QhVvrdzfcuWgiWZyV6qb7HcfSNaHQaksdkimb1GD2czbzfcuO2bBfjEQbKviqrAqr6YzmdfjMrrbLriRqGI0GcI(EgGeZqHcTpQGLdf8GcIw8PRgkujObck0MucfPuuhkkeZygk4OpuSvAKMccfAA5Ok7PgHScbksdkiQO9Xmu0rAz8C6RafwLHcI(BK0cksp1EOWaO9rOOJKsZo49phkCkuSkGEAFek4EKGMblT6qbLdkEutvuWkB(sRdks5wLdko5sc2LQdfGxsW4NAeYkeOinOiD5mMHIoM7sekAGPmou4uOa0JAQcG5qr6sSkjczfcuKguKUCgZqbrZQD6RouKEMdmuya0(iuCBrkX0C7jrhkulW7lvDRCeYcYkeOGOwLrnJJzOaa5OpcfAQcG5qbasU1fHI0P1ii)GIIwPb2EfogjuyAFP1bf0sQEeYY0(sRlc6rnvbWC(Cs76czzAFP1fb9OMQayoX85XrPzilt7lTUiOh1ufaZjMppJHubl38LwqwHafTYaDGPou82MHcagoomdfNB(bfaih9rOqtvamhkaqYToOWQmua6X0arDFlsOypOitlmczzAFP1fb9OMQayoX85DLb6at9GZn)GSmTV06IGEutvamNy(8ar9LwqwM2xADrqpQPkaMtmFEpQ7kX7k8Uqxo(eSBsS8ihZVuMl4K2boILbiXmbiy3Ky5Xh1DL4DbgGvzAfXYaKygYcYkeOGOwLrnJJzOa7JV6qHVkiu4GrOW0o9HI9GcRVTsdqIrilt7lTo(AW2tIqwM2xADeZNhigffuczfcuKe8EqXEqHc9CP6qHtHcqp2hlhk0uQmtvToOG7PkqbaUfjuyA9MXYnPuDOG5WmuKz(TiHcfAFublpczfcuyAFP1rmFEptfyAFPvGCpp0Yuq(k0(OcwEOlhFfAFublpM3ZTsJjInHScbkmTV06iMppW4txDGenqHUC8t5TnhG9XYJk0(OcwEmVNBLgte7SjbEBZbyFS8OcTpQGLh3krQjBMA4We8BBoa7JLhvO9rfS8iQY75hKLP9LwhX85bI6lTGSmTV06iMppoMFPmxWjTdCOlhF3Ky5roMFPmxWjTdCeldqIzcKcadhxKJ5xkZfCs7ahp30DjcBdhgGHJlYX8lL5coPDGJpQyBDeHTHdNIMsLzQQv8rDxjExH3fFuX26icBjaadhxKJ5xkZfCs7ahFuX26iIksnvilt7lToI5Z7nfqgjg6YXxtPYmv1k(OUReVRW7IpQyBDeHTqwM2xADeZN3J6Us8UcVdYY0(sRJy(8uf8(sv3kh6YX)aHszGBpj6xuvW7lvDRCIiKaemadhxubnpqlrRp(rgqqwM2xADeZNhZHbRJkHwMcY)nfqBrgykGKRZKXaYL06tLEawKBHqwM2xADeZNhZHbRJkhKLP9LwhX85biP0CahZREOlhFagoU4J6Us8UcVlYacYY0(sRJy(8aW)WV7wKHUC8by44IpQ7kX7k8Uidiilt7lToI5ZtUKG9lGOKjtQGLh6YXhGHJl(OUReVRW7IzQQfKLP9LwhX85XTpciP0COlhFagoU4J6Us8UcVlYacYY0(sRJy(8SsJN)MmqBszOlhFagoU4J6Us8UcVlYacYY0(sRJy(8EMkW0(sRa5EEOLPG8VTiLyGBpj6qwqwM2xADrfAFublNpy8PRoqIgiililt7lTU4TfPedC7jrN)Tijc8O1fFilt7lTU4TfPedC7jrNy(8EtbKrIHUC8by44IpQ7kX7k8UidOWHtXnjwEK7Po4TidaW)WVl(rSmajMdh2njwEuBFzKyeldqIzcKcadhxeR3iX4Jk2whri15WHFJetKksi1WHDtILhvS7m9JrSmajMjqkamCCrSEJeJpQyBDeHuNdh(nsmrQiHutfYY0(sRlEBrkXa3Es0jMppuLrnJJqwM2xADXBlsjg42tIoX85biP0SdE)ZdD54dWWXfX6nsmMPQwHdBeu4Vog1uzo4CeLbGPEaGKsZX3QUjIqilt7lTU4TfPedC7jrNy(8EJClYaajv1qxo(AW2tIhF2HSmTV06I3wKsmWTNeDI5ZdqAz8C6Re6YXh0J9di15iHX3uazKibsjJamCCXBrse4rRl(rgqHdtWUjXYJ3IKiWJwx8JyzasmNkKLP9Lwx82IuIbU9KOtmFE53iPvWtTp0LJpadhxeR3iXidiilt7lTU4TfPedC7jrNy(8aKuA2bV)5qwM2xADXBlsjg42tIoX859g5wKbasQQHUC8DtILh12xgjgXYaKyoC4uCtILhvS7m9JrSmajMjWBKiriijKA4WP4MelpY9uh8wKba4F43f)iwgGeZe4nsKiQiHuHSmTV06I3wKsmWTNeDI5ZJJ5xkZfCs7ah6YX3njwEKJ5xkZfCs7ahXYaKygYY0(sRlEBrkXa3Es0jMpV(R2PV6bpZbgYY0(sRlEBrkXa3Es0jMpVvbew5Tid6VAN(QdzzAFP1fVTiLyGBpj6eZNNQG3xQ6w5XhFg]] )
end
