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


    spec:RegisterPack( "Fury", 20181210.2225, [[dGuKzaqiavEevsBsK0OiP6uubVcP0SOcDlGKDrv)IadJkLJHOAzifpJKIPrsORrLkBdGW3aiACaPCoQeToskzEak3JG2hvQ6GauwiaEijr1ejPuxeqv1gPsOrcOQCssIYkrQMjjbDtGuXobIHcqAPKe5PsmvrQRcKk9vavzVk(RigmQomLflPhtQjlQldTze(mjgnICAvwnvcEnGmBIUnH2Tu)gLHduhNKalh0ZvA6cxhjBhr57KKgpavNxKy9aPQ5tfTFv9q(KEkzlWbeACJCqJCAi3npn0qJ7ihqoLifW4uaBAGmfCkTjItXfPGPmfWwksMLN0tzzuqnofsraEvlbcuUGev1RzIc2tKsAXXAn0icb7jQfuLSQGkHbQmsMaWqgXjXvaGcrvYU8kaqvPeGNbHhdM4IuWu87jQNsL6KHkRN6uYwGdi04g5Gg50qUBEAOHgAihqmfJkiXGtPCIQ8Nl45agut6eJdY2Pq6YzSN6uY4QNIRp3fPGP8CGNbHhd(0D95KIa8QwceOCbjQQxZefSNiL0IJ1AOrec2tulOkzvbvcduzKmbGHmItIRaafIQKD5vaGQsjapdcpgmXfPGP43tu)0D95QnQrXkcFo5U54ZPXnYbTNdQNtdnQfnU90F6U(CvojRvWvTE6U(Cq9CalNX8Zbukrru6F6U(Cq9C1(wRkX8ZfzKHIyhpxWZb(qi70pxfIg4NRnP85Q3S45nIzm)Ccg85xdkfteFUM1bc4Hd(NURphuph0HrgMFoaslJBWGIp368ZvBOPW6NRsmd(CRYidFoasglhKo4gppyp)ebdzKHpNaIQakS1P8CgXZHOMjkID2IJ17ZvFpX95R8uifYuEoPtHecDW)0D95G65awoJ5NdGfHeFEHeJkEEWEoyiQzIvlEoGbOQq)t31NdQNdy5mMFoO7IpxLfO46NI82yN0tzVwrIjHbvWyspGq(KEkMoowpL9qfScrdieofSTQeZdatmGqZKEkyBvjMhaMIgEbcpBkvkccpe1ajXDBCxpf4N705Zv)5HjXo8eqwq6ALKkcxecec9yBvjMFUtNppmj2HxBW2uqp2wvI5NN6Zv)5vkccp2qtb9qu0UEFoWEUIo)CNoFo0uWN7(N7s3EUdp3PZNhMe7WlA7AAi6X2Qsm)8uFU6pVsrq4XgAkOhII217Zb2Zv05N705ZHMc(C3)Cx62ZD45omfthhRNc0ebBk4ediQzspfSTQeZdatrdVaHNnLkfbHhBOPGEkWtX0XX6PGaoQPcCIbevCspfSTQeZdatrdVaHNnLkfbHhBOPG(mt1EkMoowpLQKXYbPdUXediUBspfSTQeZdatrdVaHNnfnjdQG7Zf(CAMIPJJ1tbAkxRKuLmvNyabqmPNc2wvI5bGPOHxGWZMcyiswIIo7j3dnrWMc(8uFU6ppJvkcc)EOcwHObec9uGFUtNph4EEysSd)EOcwHObec9yBvjMFUdtX0XX6PuLwg3GbfNyabqoPNc2wvI5bGPOHxGWZMsLIGWJn0uqpf4Py64y9uYqtH1jqMbNyab0M0tX0XX6PuLmwoiDWnMc2wvI5bGjgqC5KEkyBvjMhaMIgEbcpBkHjXo8Ad2Mc6X2Qsm)CNoFU6ppmj2Hx0210q0JTvLy(5P(COPGphyph0C75o8CNoFU6ppmj2HNaYcsxRKur4IqGqOhBRkX8Zt95qtbFoWEUlD75omfthhRNc0uUwjPkzQoXac5UnPNc2wvI5bGPOHxGWZMsysSdpbf8yuBYkTLKhBRkX8umDCSEkeuWJrTjR0wstmGqo5t6Py64y9uuL0bLQEDEkyBvjMhaMyIPKrcJsgt6beYN0tX0XX6PaMsueLtbBRkX8aWedi0mPNIPJJ1trtYGk4uW2QsmpamXaIAM0tbBRkX8aWu0Wlq4ztr9NdTlNGKHD4fzKHIyh(8TH1A85U)504UNN6ZH2LtqYWo8ImYqrSd)1p39pxfD3ZD45oD(CG75q7YjizyhErgzOi2Hhb8BJDkMoowpfsiKD6ejAGNyarfN0tX0XX6PaMfhRNc2wvI5bGjgqC3KEkyBvjMhaMIgEbcpBkHjXo8euWJrTjR0wsESTQeZpp1NR(ZRueeEck4XO2KvAlj)gMgONdSNRMN705ZRueeEck4XO2KvAljpefTR3NdSNRMN705Zv)5AgtMzQ2EiQbsI724UEikAxVphypxnpp1NxPii8euWJrTjR0wsEikAxVphyp3Lp3HN7WumDCSEkeuWJrTjR0wstmGaiM0tbBRkX8aWu0Wlq4ztbvbuhyWy2dKb6b9M0a8eckx4WSTjeuWuEEQpx9NxPii8euUWHzBtiOGP4Zmv7N705ZHOOD9(CG9CAEUdtX0XX6PuLmwoiDWnMyabqoPNc2wvI5bGPOHxGWZMIMXKzMQThIAGK4UnURhII217Zb2ZvZumDCSEkqteSPGtmGaAt6Py64y9uOwm5cuCNc2wvI5bGjgqC5KEkMoowpfiQbsI724UtbBRkX8aWediK72KEkyBvjMhaMIgEbcpBklyuktcdQGX6vL0bLQED(5U)5K)8uFoW98kfbHxeTirlrJme6PapfthhRNIQKoOu1RZtmGqo5t6PGTvLyEaykA4fi8SPuPii8qudKe3TXD9uGNIPJJ1tPkzSCcbfmLjgqiNMj9uW2Qsmpamfn8ceE2uQueeEiQbsI724UEkWtX0XX6Pur4IqGUwzIbeYvZKEkyBvjMhaMIgEbcpBkvkccpe1ajXDBCxFMPApfthhRNI8uifBIlqLveXoMyaHCvCspfSTQeZdatrdVaHNnLkfbHhIAGK4UnURNc8umDCSEkeheRsglpXac5UBspfSTQeZdatrdVaHNnLkfbHhIAGK4UnURNc8umDCSEkwRXnGMmrBs5ediKdiM0tbBRkX8aWumDCSEkqQoX0XX6e5TXuK3gjTjItzVwrIjHbvWyIjMIiJmue7yspGq(KEkMoowpfsiKD6ejAGNc2wvI5bGjMykGHOMjwTyspGq(KEkyBvjMhaMyaHMj9uW2QsmpamXaIAM0tbBRkX8aWediQ4KEkyBvjMhaMyaXDt6Py64y9uQwesmzjXOIPGTvLyEayIbeaXKEkMoowpfWS4y9uW2QsmpamXacGCspfSTQeZdatrdVaHNnfG75HjXo8euWJrTjR0wsESTQeZpp1NdCppmj2HhIAGK4Ujw16mR9yBvjMNIPJJ1tbIAGK4UnU7etmXuidH7X6beACJCqZnxQg380Ogv0Dtrvd2xRStrLjcMbdm)Cv85Moow)C5TX6F6tzbJ6beajntbmKrCsCkU(CxKcMYZbEgeEm4t31NtkcWRAjqGYfKOQEntuWEIuslowRHgriyprTGQKvfujmqLrYeagYiojUcauiQs2LxbaQkLa8mi8yWexKcMIFpr9t31NR2OgfRi85K7MJpNg3ih0EoOEon0Ow042t)P76Zv5KSwbx16P76Zb1ZbSCgZphqPefrP)P76Zb1Zv7BTQeZpxKrgkID8Cbph4dHSt)CviAGFU2KYNREZIN3iMX8ZjyWNFnOumr85AwhiGho4F6U(Cq9Cqhgzy(5aiTmUbdk(CRZpxTHMcRFUkXm4ZTkJm85aizSCq6GB88G98temKrg(CciQcOWwNYZzephIAMOi2zlowVpx99e3NVYtHuit55Kofsi0b)t31NdQNdy5mMFoawes85fsmQ45b75GHOMjwT45agGQc9pDxFoOEoGLZy(5GUl(CvwGIR)P)0D95a)aoQPcm)8ksWG4Z1mXQfpVIkxV(NdyAnco2N3SguKmOibL85MoowVpN1Yu8pDthhRxpyiQzIvlesiTfONUPJJ1Rhme1mXQf0kuabJLF6MoowVEWquZeRwqRqbgLIi2HfhRF6U(8sBGxsS45q7YpVsrqG5NVHf7ZRibdIpxZeRw88kQC9(CRZphmebfywexR88BFEM1O)PB64y96bdrntSAbTcfSTbEjXIKnSyF6MoowVEWquZeRwqRqbvlcjMSKyuXt30XX61dgIAMy1cAfkamlow)0nDCSE9GHOMjwTGwHcGOgijUBJ764rie4ctID4jOGhJAtwPTK8yBvjMtf4ctID4HOgijUBIvToZAp2wvI5N(t31Nd8d4OMkW8ZrYqykppor85bj85MoyWNF7ZnYStAvj6F6MoowVcbtjkIYNUPJJ1lTcfOjzqf8P76Ztt62NF7ZfzBit55b75GHizyhpxZyYmt1EFobKj(8kETYZnT(YyhMuMYZPwm)8mf8ALNlYidfXo8pDxFUPJJ1lTcfaP6ethhRtK3go2MikuKrgkID44riuKrgkID4Z3gwRr37UNUPJJ1lTcfqcHStNirdSJhHq1H2LtqYWo8ImYqrSdF(2WAn6EACxQq7YjizyhErgzOi2H)A3RIUZbNoboOD5eKmSdViJmue7WJa(TX(0nDCSEPvOaWS4y9t30XX6LwHciOGhJAtwPTKC8iegMe7Wtqbpg1MSsBj5X2QsmNQ6vkccpbf8yuBYkTLKFdtdeWuJtNvkccpbf8yuBYkTLKhII21lWuJtNQRzmzMPA7HOgijUBJ76HOOD9cm1KALIGWtqbpg1MSsBj5HOOD9cmx6GdpDthhRxAfkOkzSCq6GB44rievbuhyWy2dKb6b9M0a8eckx4WSTjeuWusv9kfbHNGYfomBBcbfmfFMPA70jefTRxGrJdpDthhRxAfkaAIGnf0XJqOMXKzMQThIAGK4UnURhII21lWuZt30XX6LwHcOwm5cuCF6MoowV0kuae1ajXDBC3NUPJJ1lTcfOkPdkv96SJhHWfmkLjHbvWy9Qs6GsvVo7EYtf4QueeEr0IeTenYqONc8t30XX6LwHcQsglNqqbtXXJqyLIGWdrnqsC3g31tb(PB64y9sRqbveUieORvC8iewPii8qudKe3TXD9uGF6MoowV0kuG8uifBIlqLveXoC8iewPii8qudKe3TXD9zMQ9t30XX6LwHcioiwLmw2XJqyLIGWdrnqsC3g31tb(PB64y9sRqbwRXnGMmrBsPJhHWkfbHhIAGK4UnURNc8t30XX6LwHcGuDIPJJ1jYBdhBtefUxRiXKWGky80F6MoowVErgzOi2HqsiKD6ejAGF6pDthhRx)ETIetcdQGHW9qfScrdie(0nDCSE971ksmjmOcg0kua0ebBkOJhHWkfbHhIAGK4UnURNcStNQhMe7WtazbPRvsQiCriqi0JTvLy2PZWKyhETbBtb9yBvjMtv9kfbHhBOPGEikAxVatrND6eAkO7DPBo40zysSdVOTRPHOhBRkXCQQxPii8ydnf0drr76fyk6StNqtbDVlDZbhE6MoowV(9AfjMegubdAfkabCutfOJhHWkfbHhBOPGEkWpDthhRx)ETIetcdQGbTcfuLmwoiDWnC8iewPii8ydnf0NzQ2pDthhRx)ETIetcdQGbTcfanLRvsQsMQoEec1KmOcUcP5PB64y963RvKysyqfmOvOGQ0Y4gmOOJhHqWqKSefD2tUhAIGnfmv1ZyLIGWVhQGviAaHqpfyNobUWKyh(9qfScrdie6X2Qsm7Wt30XX61VxRiXKWGkyqRqbzOPW6eiZGoEecRueeESHMc6Pa)0nDCSE971ksmjmOcg0kuqvYy5G0b34PB64y963RvKysyqfmOvOaOPCTssvYu1XJqyysSdV2GTPGESTQeZoDQEysSdVOTRPHOhBRkXCQqtbbgO5MdoDQEysSdpbKfKUwjPIWfHaHqp2wvI5uHMccmx6MdpDthhRx)ETIetcdQGbTcfqqbpg1MSsBj54rimmj2HNGcEmQnzL2sYJTvLy(PB64y963RvKysyqfmOvOavjDqPQxNNyIza]] )
end
