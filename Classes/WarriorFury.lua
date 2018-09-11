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


    spec:RegisterPack( "Fury", 20180830.2053, [[dOe9zaqiqQ8irKnjc(eHIAuurofvuVcf1SOsCluK2fv9luQHrO6yePwMiXZaPmnqOUgrsBJqH(gHszCejohiK1bsvZtK09iK9jc1bbbwii6HIqYejuIlsOaBueIpkcPmscf0jjuQwjkzMGG6MekPDcsgkvsTuueEQkMQi1vfHu9vQK0Eb(ROmyuDyklwkpMutwQUmYMvPptWOrHtdz1ujXRPsnBsUnrTBf)gQHlQooiilxvpxY0fUoO2or03jcJhfrNxe16juK5tf2VsdKgKgC6wqaOsrCPLI4sbAI7trCPMIuLk4ejNtGtUPDBce4mMmbojc8Nm4KBjRWwhKgCkm8RjWHre5f0ZMTakya38ASm7cjdRSaHh9B3GDHK1SBkCJD7AmTtsYo)XxKIk2U(jMWq9ITRzImx1(hH)Seb(t2xizn40GrQqSpGg40TGaqLI4slfXLc0e3NI4snfPcXGJbhmWp4CqYjQLZE5qWRzGKd0JlWPtLgCsA5jc8N8YDv7Fe(xwjTCgrKxqpB2cOGbCZRXYSlKmSYceE0VDd2fswZUPWn2TRX0ojj78hFrkQy76Nycd1l2UMjYCv7Fe(Zse4pzFHK1lRKwoealaxXYHM4US8uexAPSCMUCPa9qt8L7AX6YAzL0YtumSrGkOFzL0Yz6YHGEN6l31WYYKYVSsA5mD5Ifuznf1xUmwssMMy5SxUyi9yKE5qyYYxU2uQL70GJLpe1P(YV4F5OHPcMmTCnEcIjdN9lRKwotxUyflj1xoKkRtvGF5LBtF5IL3eWZYzcS9l3AyjPLdPcJ7bd0xXYd8YrY5pwsA53NGqW0OtE547YFsJLLPPBbcp1YDQqY1YlfsGrOsE5mqcmO3z)YkPLZ0Ldb9o1xoKwekA5hgy4y5bE55pPXYnlwoe4AiShCuOkkqAWPqJGIYc7fOaKgaL0G0GdnwtrDaKGJ(rb9idCAW3R)jTBfv1qv5HZxUdhlxJXQowIX)K2TIQAOQ8pjBOPwEIxEkIdoMoq4bCkejqTNm30dcauPasdo0ynf1bqco6hf0JmWPbFV(N0UvuvdvLhoF5oCSCNwEykAc)9Xbd0iK1OVO3n9EASMI6l3HJLhMIMWRTFmbYtJ1uuF5jSCNwEd(E908Ma5Fs2qtT8uxUGUVChow(Bc0Yt8YHiXxUZl3HJLhMIMWlBvz6N80ynf1xEcl3PL3GVxpnVjq(NKn0ulp1LlO7l3HJL)MaT8eVCis8L78YDgCmDGWd48MCUjqGaaf0aPbhASMI6aibh9Jc6rg40GVxpnVjqE4CWX0bcpGdXKKgoiqaGcIbPbhASMI6aibh9Jc6rg40GVxpnVjq(owIbCmDGWd40uyCpyG(kabakPcsdo0ynf1bqco6hf0JmWrZWEbQwUOLNc4y6aHhW5nb0iK1uyjabakXiin4qJ1uuhaj4OFuqpYaN8NKmtq39s7Fto3eOLNWYDA5DQbFV(crcu7jZn9E48L7WXYHULhMIMWxisGApzUP3tJ1uuF5odoMoq4bCAkRtvGFzqaGsSbsdo0ynf1bqco6hf0JmWPbFVEAEtG8W5lpHL70Y7ud(E9fIeO2tMB69W5l3HJLdDlpmfnHVqKa1EYCtVNgRPO(YDgCmDGWd40Ftapzp2EqaGskG0GJPdeEaNMcJ7bd0xb4qJ1uuhajiaqbrG0GdnwtrDaKGJ(rb9idCctrt412pMa5PXAkQVChowUtlpmfnHx2QY0p5PXAkQV8ew(Bc0YtD5sr8L78YD4y5oT8Wu0e(7JdgOriRrFrVB690ynf1xEcl)nbA5PUCis8L7m4y6aHhW5nb0iK1uyjabakPfhKgCOXAkQdGeC0pkOhzGtykAc)f(ry4kRuwXWtJ1uuhCmDGWd4CHFegUYkLvmabakPLgKgCmDGWd4ibd0RKanDWHgRPOoasqacWPtxdwfG0aOKgKgCmDGWd4yWboZIW0UbhASMI6aibbaQuaPbhthi8ao5WYYKcCOXAkQdGeeaOGgin4y6aHhWrZWEbcCOXAkQdGeeaOGyqAWX0bcpGtooq4bCOXAkQdGeeaOKkin4qJ1uuhaj4OFuqpYaNWu0e(l8JWWvwPSIHNgRPO(Yty5oT8g896VWpcdxzLYkg(kmT7LN6YH2YD4y5n471FHFegUYkLvm8pjBOPwEQlhAl3HJL70Y1ySQJLy8pPDROQgQk)tYgAQLN6YH2Yty5n471FHFegUYkLvm8pjBOPwEQlhIwUZl3zWX0bcpGZf(ry4kRuwXaeaOeJG0GdnwtrDaKGJ(rb9idCiiemkpN6E3MysmzkJjZUWUcI6wLDH)KxEcl3PL3GVx)f2vqu3QSl8NSVJLywUdhl)jzdn1YtD5PSCNbhthi8aonfg3dgOVcqaGsSbsdo0ynf1bqco6hf0JmWrJXQowIX)K2TIQAOQ8pjBOPwEQlhAGJPdeEaN3KZnbceaOKcin4y6aHhW5jTBfv1qvbo0ynf1bqccauqein4qJ1uuhaj4OFuqpYaNkNuQSWEbkkVemqVsc00xEIxU0lpHLdDlVbFVEzYImTImjP3dNdoMoq4bCKGb6vsGMoiaqjT4G0GdnwtrDaKGJ(rb9idCAW3R)jTBfv1qv5HZbhthi8aonfg3ZUWFYGaaL0sdsdo0ynf1bqco6hf0JmWPbFV(N0UvuvdvLhohCmDGWd40OVO3nAeabakPtbKgCOXAkQdGeC0pkOhzGZBc0YtD5qS4lpHLdDlVbFV(N0UvuvdvLhohCmDGWd4yV2gklW)ttacausdnqAWHgRPOoasWr)OGEKbon471)K2TIQAOQ8DSed4y6aHhWrHeyevMRa3fKPjabakPHyqAWHgRPOoasWr)OGEKbon471)K2TIQAOQ8W5GJPdeEaNl6PMcJ7GaaL0sfKgCOXAkQdGeC0pkOhzGtd(E9pPDROQgQkpCo4y6aHhWXgnvXBQmTPuGaaL0IrqAWHgRPOoasWX0bcpGZdpzMoq4jtHQaCuOkYgtMaNcnckklSxGcqacWrgljjttasdGsAqAWX0bcpGdd6XiDMISCWHgRPOoasqacWj)jnwUzbinakPbPbhASMI6aibbaQuaPbhASMI6aibbakObsdo0ynf1bqccauqmin4qJ1uuhajiaqjvqAWX0bcpGtZIqrzfdmCao0ynf1bqccauIrqAWX0bcpGtooq4bCOXAkQdGeeGaeGJK0xi8aGkfXLwkIlfPHMxAPk1uahjSFqJqboUkeWeqj2Hkrd6x(YtZGwosoh)XYV4F5I5oDnyviMx(tqiy0t9LxyzA5gCGLTG6lxZWgbQ8llimAOLln0V8e9PGZZXFq9LB6aHNLlMn4aNzryA3Iz)YAzj2LZXFq9LdXl30bcplxHQO8llWj)XxKIaNKwEIa)jVCx1(hH)LvslNre5f0ZMTakya38ASm7cjdRSaHh9B3GDHK1SBkCJD7AmTtsYo)XxKIk2U(jMWq9ITRzImx1(hH)Seb(t2xiz9YkPLdbWcWvSCOjUllpfXLwklNPlxkqp0eF5UwSUSwwjT8efdBeOc6xwjTCMUCiO3P(YDnSSmP8lRKwotxUybvwtr9LlJLKKPjwo7LlgspgPxoeMS8LRnLA5on4y5drDQV8l(xoAyQGjtlxJNGyYWz)YkPLZ0LlwXss9LdPY6uf4xE520xUy5nb8SCMaB)YTgwsA5qQW4EWa9vS8aVCKC(JLKw(9jiemn6Kxo(U8N0yzzA6wGWtTCNkKCT8sHeyeQKxodKad6D2VSsA5mD5qqVt9LdPfHIw(HbgowEGxE(tASCZILdbUgc7xwlRKwUyatsA4G6lVrx8tlxJLBwS8gjGMYVCiqRP8Ow(GhMYWE5lSA5Moq4PwoEuj7xwMoq4P85pPXYnleDvw5Ezz6aHNYN)Kgl3SGzrSVyCFzz6aHNYN)Kgl3SGzrSnybzAclq4zzL0YpJLxmWXYFd1xEd(EP(YRWIA5n6IFA5ASCZIL3ib0ul3M(YZFIP54iqJWYr1Y74H8llthi8u(8N0y5MfmlIDnwEXahzvyrTSmDGWt5ZFsJLBwWSi2nlcfLvmWWXYY0bcpLp)jnwUzbZIyNJdeEwwlRKwUyatsA4G6lNKK(KxEGKPLhmOLB6a)lhvl3K0qkRPi)YY0bcpLidoWzweM29YY0bcpfZIyNdlltQLLPdeEkMfXwZWEbAzL0YtZavlhvlxgxHk5Lh4LN)KK0elxJXQowIPw(9XYlVrOry5MwJ60eMsL8YHlQV8o8JgHLlJLKKPj8lRKwUPdeEkMfX(HNmthi8KPqv4YyYKizSKKmnHlORizSKKmnHVJQWgnLyPUSsA5Moq4PyweBg0Jr6mfz5UGUIC6nupJKKMWlJLKKPj8Duf2OPeNIut4nupJKKMWlJLKKPj8OjXqSuD2HdO7nupJKKMWlJLKKPj8etIQOwwMoq4Pywe7CCGWZYY0bcpfZIyFHFegUYkLvmCbDffMIMWFHFegUYkLvm80ynf1tWPg896VWpcdxzLYkg(kmT7uHMdhn471FHFegUYkLvm8pjBOPsfAoC4KgJvDSeJ)jTBfv1qv5Fs2qtLk0sObFV(l8JWWvwPSIH)jzdnvQqKZoVSmDGWtXSi2nfg3dgOVcxqxreecgLNtDVBtmjMmLXKzxyxbrDRYUWFYj4ud(E9xyxbrDRYUWFY(owIXHJNKn0uPMIZllthi8umlI9BY5Ma5c6ksJXQowIX)K2TIQAOQ8pjBOPsfAllthi8umlI9tA3kQQHQAzz6aHNIzrSLGb6vsGMUlOROkNuQSWEbkkVemqVsc00tS0jaDn471ltwKPvKjj9E48LLPdeEkMfXUPW4E2f(t2f0vud(E9pPDROQgQkpC(YY0bcpfZIy3OVO3nAeCbDf1GVx)tA3kQQHQYdNVSmDGWtXSi22RTHYc8)0eUGUIEtGsfIfpbORbFV(N0UvuvdvLhoFzz6aHNIzrSvibgrL5kWDbzAcxqxrn471)K2TIQAOQ8DSeZYY0bcpfZIyFrp1uyC3f0vud(E9pPDROQgQkpC(YY0bcpfZIyBJMQ4nvM2ukxqxrn471)K2TIQAOQ8W5llthi8umlI9dpzMoq4jtHQWLXKjrfAeuuwyVaflRLLPdeEkVmwssMMqed6XiDMIS8L1YY0bcpLVqJGIYc7fOquHibQ9K5MExqxrn471)K2TIQAOQ8W5oCOXyvhlX4Fs7wrvnuv(NKn0ujofXxwMoq4P8fAeuuwyVafmlI9BY5Ma5c6kQbFV(N0UvuvdvLho3HdNctrt4VpoyGgHSg9f9UP3tJ1uu3HJWu0eET9JjqEASMI6j4ud(E908Ma5Fs2qtLQGU7WXBcuIHiXD2HJWu0eEzRkt)KNgRPOEco1GVxpnVjq(NKn0uPkO7oC8MaLyisCNDEzz6aHNYxOrqrzH9cuWSi2etsA4GCbDf1GVxpnVjqE48LLPdeEkFHgbfLf2lqbZIy3uyCpyG(kCbDf1GVxpnVjq(owIzzz6aHNYxOrqrzH9cuWSi2VjGgHSMclHlORind7fOsukllthi8u(cnckklSxGcMfXUPSovb(LDbDfL)KKzc6UxA)BY5MaLGtDQbFV(crcu7jZn9E4ChoGUWu0e(crcu7jZn9EASMI6oVSmDGWt5l0iOOSWEbkywe7(Bc4j7X27c6kQbFVEAEtG8W5j4uNAW3RVqKa1EYCtVho3HdOlmfnHVqKa1EYCtVNgRPOUZllthi8u(cnckklSxGcMfXUPW4EWa9vSSmDGWt5l0iOOSWEbkywe73eqJqwtHLWf0vuykAcV2(XeipnwtrDhoCkmfnHx2QY0p5PXAkQNWBcuQsrCND4WPWu0e(7JdgOriRrFrVB690ynf1t4nbkvisCNxwMoq4P8fAeuuwyVafmlI9f(ry4kRuwXWf0vuykAc)f(ry4kRuwXWtJ1uuFzz6aHNYxOrqrzH9cuWSi2sWa9kjqthCQCsdGsSLciabaa]] )
end
