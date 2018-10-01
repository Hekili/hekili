-- WarriorArms.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 71 )

    local base_rage_gen, arms_rage_mult = 1.75, 4.000

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand = {
            last = function ()
                local swing = state.combat == 0 and state.now or state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = 'mainhand_speed',

            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * arms_rage_mult * state.swings.mainhand_speed / state.haste
            end,
        }
    } )
    
    -- Talents
    spec:RegisterTalents( {
        war_machine = 22624, -- 262231
        sudden_death = 22360, -- 29725
        skullsplitter = 22371, -- 260643

        double_time = 19676, -- 103827
        impending_victory = 22372, -- 202168
        storm_bolt = 22789, -- 107570

        massacre = 22380, -- 281001
        fervor_of_battle = 22489, -- 202316
        rend = 19138, -- 772

        second_wind = 15757, -- 29838
        bounding_stride = 22627, -- 202163
        defensive_stance = 22628, -- 197690

        collateral_damage = 22392, -- 268243
        warbreaker = 22391, -- 262161
        cleave = 22362, -- 845

        in_for_the_kill = 22394, -- 248621
        avatar = 22397, -- 107574
        deadly_calm = 22399, -- 262228

        anger_management = 21204, -- 152278
        dreadnaught = 22407, -- 262150
        ravager = 21667, -- 152277
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3589, -- 208683
        relentless = 3588, -- 196029
        adaptation = 3587, -- 214027

        duel = 34, -- 236273
        disarm = 3534, -- 236077
        sharpen_blade = 33, -- 198817
        war_banner = 32, -- 236320
        spell_reflection = 3521, -- 216890
        death_sentence = 3522, -- 198500
        master_and_commander = 28, -- 235941
        shadow_of_the_colossus = 29, -- 198807
        storm_of_destruction = 31, -- 236308
    } )

    -- Auras
    spec:RegisterAuras( {
        avatar = {
            id = 107574,
            duration = 20,
            max_stack = 1,
        },
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
            id = 227847,
            duration = 6,
            max_stack = 1,
        },
        bounding_stride = {
            id = 202164,
            duration = 3,
            max_stack = 1,
        },
        colossus_smash = {
            id = 208086,
            duration = 10,
            max_stack = 1,
        },
        deadly_calm = {
            id = 262228,
            duration = 6,
            max_stack = 1,
        },
        deep_wounds = {
            id = 262115,
            duration = 6,
            max_stack = 1,
        },
        defensive_stance = {
            id = 197690,
            duration = 3600,
            max_stack = 1,
        },
        die_by_the_sword = {
            id = 118038,
            duration = 8,
            max_stack = 1,
        },
        hamstring = {
            id = 1715,
            duration = 15,
            max_stack = 1,
        },
        in_for_the_kill = {
            id = 248622,
            duration = 10,
            max_stack = 1,
        },
        intimidating_shout = {
            id = 5246,
            duration = 8,
            max_stack = 1,
        },
        mortal_wounds = {
            id = 115804,
            duration = 10,
            max_stack = 1,
        },
        overpower = {
            id = 7384,
            duration = 15,
            max_stack = 2,
        },
        rallying_cry = {
            id = 97463,
            duration = 10,
            max_stack = 1,
        },
        --[[ ravager = {
            id = 152277,
        }, ]]
        rend = {
            id = 772,
            duration = 12,
            max_stack = 1,
        },
        --[[ seasoned_soldier = {
            id = 279423,
        }, ]]
        sign_of_the_emissary = {
            id = 225788,
            duration = 3600,
            max_stack = 1,
        },
        stone_heart = {
            id = 225947,
            duration = 10,
        },
        sudden_death = {
            id = 52437,
            duration = 10,
            max_stack = 1,
        },
        sweeping_strikes = {
            id = 260708,
            duration = 12,
            max_stack = 1,
        },
        --[[ tactician = {
            id = 184783,
        }, ]]
        taunt = {
            id = 355,
            duration = 3,
            max_stack = 1,
        },
        victorious = {
            id = 32216,
            duration = 20,
            max_stack = 1,
        },

        -- Azerite Powers
        crushing_assault = {
            id = 278826,
            duration = 10,
            max_stack = 1
        },

        test_of_might = {
            id = 275540,
            duration = 12,
            max_stack = 1
        }
    } )


    local rageSpent = 0

    spec:RegisterHook( "spend", function( amt, resource )
        if talent.anger_management.enabled and resource == "rage" then
            rageSpent = rageSpent + amt
            local reduction = floor( rageSpent / 20 )
            rageSpent = rageSpent % 20

            if reduction > 0 then
                cooldown.colossus_smash.expires = cooldown.colossus_smash.expires - reduction
                cooldown.bladestorm.expires = cooldown.bladestorm.expires - reduction
                cooldown.warbreaker.expires = cooldown.warbreaker.expires - reduction
            end
        end
    end )

    spec:RegisterHook( "reset_precast", function ()
        rageSpent = 0
        if buff.bladestorm.up then setCooldown( "global_cooldown", max( cooldown.global_cooldown.remains, buff.bladestorm.remains ) ) end
    end )


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
        spec:RegisterAura( "war_veteran", {
            id = 253382,
            duration = 8
         } ) -- arms 2pc.
        spec:RegisterAura( "weighted_blade", { 
            id = 253383,  
            duration = 1,
            max_stack = 3
        } ) -- arms 4pc.

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
        avatar = {
            id = 107574,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            spend = -20,
            spendType = "rage",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 613534,

            talent = "avatar",
            
            handler = function ()
                applyBuff( "avatar" )
            end,
        },
        

        battle_shout = {
            id = 6673,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132333,

            nobuff = "battle_shout",
            essential = true,
            
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

            startsCombat = true,
            texture = 136009,
            
            handler = function ()
                applyBuff( "berserker_rage" )
                if level < 116 and equipped.ceannar_charger then gain( 8, "rage" ) end
            end,
        },
        

        bladestorm = {
            id = 227847,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 236303,

            notalent = "ravager",
            
            handler = function ()
                applyBuff( "bladestorm" )
                if level < 116 and equipped.the_great_storms_eye then addStack( "tornados_eye", 6, 1 ) end
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
                setDistance( 5 )
            end,
        },
        

        cleave = {
            id = 845,
            cast = 0,
            cooldown = 9,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 20
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132338,

            talent = "cleave",
            
            handler = function ()
                if active_enemies >= 3 then applyDebuff( "target", "deep_wounds" ) end
                if talent.collateral_damage.enabled then gain( 4, "rage" ) end
            end,
        },
        

        colossus_smash = {
            id = 167105,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 464973,

            notalent = "warbreaker",
            
            handler = function ()
                applyDebuff( "target", "colossus_smash" )

                if level < 116 then
                    if set_bonus.tier21_2pc == 1 then applyBuff( "war_veteran" ) end
                    if set_bonus.tier20_2pc == 1 then
                        if talent.ravager.enabled then setCooldown( "ravager", max( 0, cooldown.ravager.remains - 2 ) )
                        else setCooldown( "bladestorm", max( 0, cooldown.bladestorm.remains - 3 ) ) end
                    end
                end

                if talent.in_for_the_kill.enabled then
                    applyBuff( "in_for_the_kill" )
                    stat.haste = state.haste + ( target.health.pct < 20 and 0.2 or 0.1 )
                end
            end,
        },
        

        deadly_calm = {
            id = 262228,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 298660,
            
            handler = function ()
                applyBuff( "deadly_calm" )
            end,
        },
        

        defensive_stance = {
            id = 212520,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132349,

            talent = "defensive_stance",
            toggle = "defensives",
            
            handler = function ()
                if buff.defensive_stance.up then removeBuff( "defensive_stance" )
                else applyBuff( "defensive_stance" ) end
            end,
        },
        

        die_by_the_sword = {
            id = 118038,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 132336,

            toggle = "defensives",
            
            handler = function ()
                applyBuff( "die_by_the_sword" )
            end,
        },
        

        execute = {
            id = function () return talent.massacre.enabled and 281001 or 163201 end,
            known = 163201,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.sudden_death.up then return 0 end
                if buff.stone_heart.up then return 0 end
                if buff.deadly_calm.up then return 0 end
                return 20
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 135358,

            recheck = function () return rage.time_to_40 end,
            usable = function () return buff.sudden_death.up or buff.stone_heart.up or target.health.pct < ( talent.massacre.enabled and 35 or 20 ) end,
            handler = function ()
                if not buff.sudden_death.up and not buff.stone_heart.up then
                    local overflow = min( rage.current, 20 )
                    spend( overflow, "rage" )
                    gain( 0.3 * ( 20 + overflow ), "rage" )
                end
                if buff.stone_heart.up then removeBuff( "stone_heart" )
                else removeBuff( "sudden_death" ) end

                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 4, "rage" ) end
            end,

            copy = { 163201, 281001, 281000 }
        },
        

        hamstring = {
            id = 1715,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 10
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132316,
            
            handler = function ()
                applyDebuff( "target", "hamstring" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 2, "rage" ) end
            end,
        },
        

        heroic_leap = {
            id = 6544,
            cast = 0,
            charges = function () return ( level < 116 and equipped.timeless_strategem ) and 3 or nil end,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            recharge = function () return talent.bounding_stride.enabled and 30 or 45 end,
            gcd = "spell",
            
            startsCombat = false,
            texture = 236171,

            usable = function () return ( equipped.weight_of_the_earth or target.distance > 10 ) and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd.execute * 2 ) end,
            handler = function ()
                setDistance( 5 )
                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
                if level < 116 and equipped.weight_of_the_earth then
                    applyDebuff( "target", "colossus_smash" )
                    active_dot.colossus_smash = max( 1, active_enemies )
                end
            end,
        },
        

        heroic_throw = {
            id = 57755,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132453,
            
            usable = function () return target.distance > 10 end,
            handler = function ()
            end,
        },
        

        impending_victory = {
            id = 202168,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 10
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 589768,

            talent = "impending_victory",
            
            handler = function ()
                removeBuff( "victorious" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 2, "rage" ) end
            end,
        },
        

        intimidating_shout = {
            id = 5246,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132154,
            
            handler = function ()
                applyBuff( "intimidating_shout" )
            end,
        },
        

        mortal_strike = {
            id = 12294,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 30 - ( ( level < 116 and equipped.archavons_heavy_hand ) and 8 or 0 )
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132355,
            
            handler = function ()
                applyDebuff( "target", "mortal_wounds" )
                applyDebuff( "target", "deep_wounds" )
                removeBuff( "overpower" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 6, "rage" ) end
                if level < 116 and set_bonus.tier21_4pc == 1 then addStack( "weighted_blade", 12, 1 ) end
            end,
        },
        

        overpower = {
            id = 7384,
            cast = 0,
            charges = function () return talent.dreadnaught.enabled and 2 or nil end,
            cooldown = 12,
            recharge = 12,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132223,
            
            handler = function ()
                if talent.dreadnaught.enabled then
                    addStack( "overpower", 15, 1 )
                else
                    applyBuff( "overpower" )
                end
            end,
        },
        

        pummel = {
            id = 6552,
            cast = 0,
            cooldown = 15,
            gcd = "off",
            
            startsCombat = true,
            texture = 132938,

            toggle = "interrupts",
            
            usable = function () return target.casting end,
            handler = function ()
                interrupt()
            end,
        },
        

        rallying_cry = {
            id = 97462,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            startsCombat = false,
            texture = 132351,

            toggle = "defensives",
            
            handler = function ()
                applyBuff( "rallying_cry" )
            end,
        },
        

        ravager = {
            id = 152277,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = -7,
            spendType = "rage",
            
            startsCombat = true,
            texture = 970854,

            talents = "ravager",
            toggle = "cooldowns",
            
            handler = function ()
                if ( level < 116 and equipped.the_great_storms_eye ) then addStack( "tornados_eye", 6, 1 ) end
                -- need to plan out rage gen.
            end,
        },
        

        rend = {
            id = 772,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 30
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132155,

            talent = "rend",
            
            handler = function ()
                applyDebuff( "target", "rend" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 6, "rage" ) end
            end,
        },
        

        skullsplitter = {
            id = 260643,
            cast = 0,
            cooldown = 21,
            hasteCD = true,
            gcd = "spell",

            spend = -20,
            spendType = "rage",
            
            startsCombat = true,
            texture = 2065621,

            talent = "skullsplitter",
            
            handler = function ()
            end,
        },
        

        slam = {
            id = 1464,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                if buff.crushing_assault.up then return 0 end
                return 20
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132340,
            
            recheck = function () return rage.time_to_30, rage.time_to_40 end,
            handler = function ()
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 4, "rage" ) end
                removeBuff( "crushing_assault" )
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
        

        sweeping_strikes = {
            id = 260708,
            cast = 0,
            cooldown = 30,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132306,
            
            handler = function ()
                applyBuff( "sweeping_strikes" )
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
        

        warbreaker = {
            id = 262161,
            cast = 0,
            cooldown = 45,
            velocity = 25,
            gcd = "spell",
            
            startsCombat = true,
            texture = 2065633,

            talent = "warbreaker",
            
            handler = function ()                
                if talent.in_for_the_kill.enabled then
                    if buff.in_for_the_kill.down then
                        stat.haste = stat.haste + ( target.health.pct < 0.2 and 0.2 or 0.1 )
                    end
                    applyBuff( "in_for_the_kill" )
                end

                if level < 116 then
                    if set_bonus.tier21_2pc == 1 then applyBuff( "war_veteran" ) end
                    if set_bonus.tier20_2pc == 1 then
                        if talent.ravager.enabled then setCooldown( "ravager", max( 0, cooldown.ravager.remains - 2 ) )
                        else setCooldown( "bladestorm", max( 0, cooldown.bladestorm.remains - 3 ) ) end
                    end
                end

                applyDebuff( "target", "colossus_smash" )
            end,
        },
        

        whirlwind = {
            id = 1680,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 30
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132369,

            recheck = function () return rage.time_to_50 end,
            handler = function ()
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 6, "rage" ) end
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageDots = false,
        damageExpiration = 8,

        potion = "potion_of_bursting_blood",

        package = "Arms",
    } )

    
    spec:RegisterPack( "Arms", 20180930.2339, [[dqK3(aqirQEKiGnjjgfq1PakRsei9kukZse6wIi1Uq1VefdtKYXerTmsfpdLQMMOuDnGuTnrP8nuQW4qPsNdLkADIiQ5jk5EOK9bKCqrKSquKhcKcUOiq0jfbkRuKmtGuODcedfiLwQiI8ujMQK0wfbQ(kqkAVk(RQmyQ6WuwmGhtLjt4YiBgsFwsnAvLtR0QfbcVgf1Sj62KYUv53qnCvvlh0ZLA6cxhITtQ67IQXlc68KkTEreMpkSFsEsEQofHf0aIoPLm7Mg7K9PX1H9SNDYE2pLq3FAk)MJzRMMYzA0uskOwpLFtxj2et1P0yeOJMYxe)DsotM6n(qa4oSwME1qKwS4Zbn0itVAUmasmqgaulPfK(m)qm6kPodOfsjjBfDgqBs6bAAq4IHVKcQ18E1CtbazLrc2natrybnGOtAjZUPXozFACDyp7zh6K9PyiXhgoLYQHiTyXhObOHgt5Bfc6gGPiO2nLeq5tkOwR8GMgeUyOkvcO8Fr83j5mzQ34dbG7WAz6vdrAXIph0qJm9Q5YaiXazaqTKwq6Z8dXORK6mGwiLKSv0zaTjPhOPbHlg(skOwZ7vZPsLakFH(dsdGGkp7tlrLxN0sMDv(Kw51H9jzDstLsLkbuEqdF2vtDswLkbu(Kw5tkHGekpOfrtJKCvQeq5tALpPecsO8j4RlWqDv(Kes)Ljbt7NoXE1kFc(6cmuxUkvcO8jTYNucbjuEMSiKKYx(WiHYhyL)hsoSgGfkFsbAbnYNIC7ONQtP3RwsVWG1umvhqsEQof6majjgMMIdUbbxBkqsZ2Rv(SyP8ceOfl(u(euLpno7v(kkVGaqqr5oSe3ns)AnR)4cC(nfZfl(McKoXedi6mvNcDgGKedttXb3GGRnfOvtkFwkF2st5RO8GR8PR8HjPl4cYesDFotQXPZaKKq5zWq5bqqr5cYesDFotQXf48t5bBkMlw8nLMzePS)LBeeCIbe2pvNcDgGKedttXb3GGRnL0vEaeuuUGmHu3NZKACKFLVIYdUY7WyPaNFChwI7gPFTM1FCiPz71kFwkVokpdgkp4kFys6cEUbbGKXmb50zassO8vuEhglf48JNBqaizmtqoK0S9ALplLxhLhmLhSPyUyX3uGMERMGtmGK9P6uOZaKKyyAko4geCTPiiaeuuUdlXDJ0VwZ6pUaNFtXCXIVP4WsC3i9R1S(BIbeqFQof6majjgMMIdUbbxBkccabfL7WsC3i9R1S(JlW53umxS4Bk5geasgZeCIbKSnvNI5IfFtrqMqQ7ZzsTPqNbijXW0ediSJP6uOZaKKyyAko4geCTPaGGIYBeHGUNGS4JdjZftXCXIVPqjKCibnXac7ovNcDgGKedttXb3GGRnfhglf48JRHHHjFDaxMjoK0S9ALVIYdUYNUYhMKUGliti195mPgNodqscLNbdLhabfLliti195mPgxGZpLhmLVIYdUYdUYliaeuuUdlXDJ0VwZ6poYVYxr5tx5TKGGBq8G64HrFAB9xWPZaKKq5bt5zWq5bqqr5b1XdJ(026VGJ8R8GnfZfl(McG0euhyO2ediSZP6uOZaKKyyAko4geCTP0)Ku(cdwtrZZ)wOmFpHYdkLxNPyUyX3uCsY0ttmGKCAt1PqNbijXW0uCWni4AtXsccUbXBABT19Yn9ehAhZkplLN9tXCXIVPG1tWFCobNyaj5KNQtXCXIVPOHHHjFDaxMPPqNbijXW0edijRZuDk0zassmmnfhCdcU2uctsxWrjOEm8HrFawesItNbijHYxr5bx5bqqr5cYesDFotQXr(vEgmuEOvtkpOyP8zlnLhSPyUyX3uY)wOmFpXedijZ(P6umxS4Bky9e8hNtWPqNbijXW0edijN9P6uOZaKKyyAko4geCTPeMKUGJsq9y4dJ(aSiKeNodqscLVIYdUYNUYBjbb3G4b1XdJ(026VGtNbijHYZGHYliaeuuUdlXDJ0VwZ6poYVYd2umxS4Bk5FluMVNyIbKKb9P6uOZaKKyyAko4geCTPKUYhMKUGJsq9y4dJ(aSiKeNodqscLVIYdUYNUYBjbb3G4b1XdJ(026VGtNbijHYZGHYliaeuuUdlXDJ0VwZ6poYVYZGHYdGGIYfKjK6(CMuJJ8R8myO8qRMuEqXs5ZwAkpytXCXIVP0stBIbKKZ2uDkMlw8nf9RlWqDFqK(Bk0zassmmnXasYSJP6umxS4BkR2pDI9QF6xxGH6of6majjgMMyIPiiudrgt1bKKNQtXCXIVP4(mynnf6majjgMMyarNP6umxS4Bk)iAAKCk0zassmmnXac7NQtXCXIVP8JJfFtHodqsIHPjgqY(uDk0zassmmnfhCdcU2ueeackk3HL4Ur6xRz9hh5FkMlw8nfajglEOiqDNyab0NQtHodqsIHPP4GBqW1MIGaqqr5oSe3ns)AnR)4i)tXCXIVPaqWMGmVx9edizBQof6majjgMMIdUbbxBkccabfL7WsC3i9R1S(JlW5NYxr5DySuGZpUgggM81bCzM4qsZ2RvEqP8jZbDLVIYdTAs5Zs5b90MI5IfFtXGo7OxGHq6Ijgqyht1PqNbijXW0uCWni4AtrqaiOOChwI7gPFTM1FCbo)MI5IfFtrU1Fr)sqGiQ1OlMyaHDNQtHodqsIHPP4GBqW1MIGaqqr5oSe3ns)AnR)4i)tXCXIVPGUqcqIXIjgqyNt1PqNbijXW0uCWni4AtrqaiOOChwI7gPFTM1FCK)PyUyX3uSZrDan5Zzs5edijN2uDkMlw8nfKMEBqA9uOZaKKyyAIbKKtEQof6majjgMMIdUbbxBkomwkW5h3HL4Ur6xRz9hhsA2ETYNLYZUkpdgkp4kFys6cEUbbGKXmb50zassO8vuEhglf48JNBqaizmtqoK0S9ALplLNDvEWMI5IfFtX0BHbNyajzDMQtHodqsIHPP4GBqW1Ms)ts5lmynfnp)BHY89ekpOu(Kv(kkp4kVdJLcC(XbKMG6ad14qsZ2RvEqP8jNMYZGHY7WyPaNFChwI7gPFTM1FCiPz71kpOuE2v5zWq5TKGGBq8G64HrFAB9xWPZaKKq5bBkMlw8nLoNO)9QFDaxMPEIbKKz)uDk0zassmmnfhCdcU2uG2kEKE6cUjenNs42rpfZfl(Mce5EMlw89KBhtrUD8otJMYN5Myaj5SpvNcDgGKedttXb3GGRnL(NKYxyWAkAE(3cL57juEqP8zFkMlw8nfiY9mxS47j3oMIC74DMgnf0vp9cdwtXedijd6t1PqNbijXW0uCWni4AtbCLpmjDbxZ62CqItNbijHYxr5ddwtb)Jmz8X)DHYNLYZEqx5bt5zWq5ddwtb)Jmz8X)DHYNLYRtAtXCXIVParUN5IfFp52XuKBhVZ0OPqjKCibnXasYzBQof6majjgMMI5IfFtbICpZfl(EYTJPi3oENPrtP3RwsVWG1umXet5hsoSgGft1bKKNQtHodqsIHPjgq0zQof6majjgMMyaH9t1PqNbijXW0edizFQof6majjgMMyab0NQtXCXIVPayriPx)HrIPqNbijXW0edizBQofZfl(MYpow8nf6majjgMMyIPqjKCibnvhqsEQof6majjgMMIdUbbxBkqRMu(Su(SLMYxr5bx5tx5dtsxWfKjK6(CMuJtNbijHYZGHYdGGIYfKjK6(CMuJlW5NYd2umxS4BknZisz)l3ii4edi6mvNcDgGKedttXb3GGRnL0vEaeuuUGmHu3NZKACKFLVIYdUY7WyPaNFChwI7gPFTM1FCiPz71kFwkVokpdgkp4kFys6cEUbbGKXmb50zassO8vuEhglf48JNBqaizmtqoK0S9ALplLxhLhmLhSPyUyX3uGMERMGtmGW(P6uOZaKKyyAko4geCTPiiaeuuUdlXDJ0VwZ6pUaNFtXCXIVP4WsC3i9R1S(BIbKSpvNcDgGKedttXb3GGRnfbbGGIYDyjUBK(1Aw)Xf48BkMlw8nLCdcajJzcoXacOpvNI5IfFtrqMqQ7ZzsTPqNbijXW0edizBQof6majjgMMIdUbbxBkqRMu(SuE2NMYxr5tx5bqqr5cYesDFotQXr(NI5IfFtbqAcQdmuBIbe2XuDk0zassmmnfhCdcU2u6FskFHbRPO55FluMVNq5bLYRZumxS4Bkojz6Pjgqy3P6uOZaKKyyAko4geCTPaGGIYDqK(BV6N1THidoY)umxS4BkT00MyaHDovNcDgGKedttXb3GGRnfaeuuowpb)X5eK3H5yw5zP86O8vu(WK0fCbKmXzi1FbNodqscLNbdLhabfLtjKCiXIpc2VFi52EXhVdZXSYZs51zkMlw8nfnmmm5Rd4YmnXasYPnvNcDgGKedttXb3GGRnfaeuuUGmHu3NZKACK)PyUyX3uOesoKGMyaj5KNQtXCXIVPG1tWFCobNcDgGKedttmGKSot1PyUyX3uOesoKGMcDgGKedttmXu(m3uDaj5P6uOZaKKyyAko4geCTPajnBVw5ZILYlqGwS4t5tqv(04Sx5RO8GR8PR8qBfpspDb3eIMJ8R8myO8aiOO8oNO)9QFDaxMPMJ8R8GnfZfl(McKoXedi6mvNcDgGKedttXb3GGRnfOvtkFwkF2st5RO8GR8omwkW5hxqMqQ7ZzsnoK0S9ALhukp7vEgmu(0v(WK0fCbzcPUpNj140zassO8GnfZfl(MsZmIu2)YnccoXac7NQtHodqsIHPP4GBqW1Mc4kVdJLcC(XbKMG6ad14qsZ2RvEqP8zt5zWq5dtsxWHMERMGC6majju(kkVdJLcC(XHMERMGCiPz71kpOu(SP8GP8vuEWvEhglf48J7WsC3i9R1S(JdjnBVw5Zs51r5zWq5bx5dtsxWZniaKmMjiNodqscLVIY7WyPaNF8CdcajJzcYHKMTxR8zP86O8GP8GnfZfl(MIGmHu3NZKAtmGK9P6uOZaKKyyAko4geCTPaUYdTv8i90fCtiAoYVYZGHYdTv8i90fCtiA(EkpOu(WG1uWJvJEb(jws5bt5RO8GR8omwkW5h3HL4Ur6xRz9hhsA2ETYNLYRJYZGHYdUYhMKUGNBqaizmtqoDgGKekFfL3HXsbo)45geasgZeKdjnBVw5Zs51r5bt5bBkMlw8nfOP3Qj4ediG(uDk0zassmmnfhCdcU2uG2kEKE6cUjenh5x5zWq5H2kEKE6cUjenFpLhukF2tt5zWq5bx5H2kEKE6cUjenFpLhukVoPP8vu(WK0fC7Qj4tZoRM0Ol40zassO8GnfZfl(MIdlXDJ0VwZ6VjgqY2uDk0zassmmnfhCdcU2uG2kEKE6cUjenh5x5zWq5H2kEKE6cUjenFpLhukF2tt5zWq5bx5H2kEKE6cUjenFpLhukVoPP8vu(WK0fC7Qj4tZoRM0Ol40zassO8GnfZfl(MsUbbGKXmbNyaHDmvNcDgGKedttXb3GGRnfaeuuENt0)E1VoGlZuZf48t5RO8GR8GR8ccabfL7WsC3i9R1S(JJ8R8vuEOTIhPNUGBcrZ3t5bLYhgSMcESA0lWpXskpykpdgkp0wXJ0txWnHO5i)kFfLhCLhCLxqaiOOChwI7gPFTM1FCiPz71kpOu(SZbDLVIYNUYBjbb3G4b1XdJ(026VGtNbijHYdMYZGHYdGGIYdQJhg9PT1Fbh5x5bt5bBkMlw8nfaPjOoWqTjgqy3P6uOZaKKyyAko4geCTPKUYdTv8i90fCtiAoYVYZGHYdUYdTv8i90fCtiAoYVYxr5TKGGBq8M2wBDVCtpXPZaKKq5bBkMlw8nfSEc(JZj4ediSZP6uOZaKKyyAko4geCTP0)Ku(cdwtrZZ)wOmFpHYdkLxNPyUyX3uCsY0ttmGKCAt1PqNbijXW0uCWni4AtjDLhAR4r6Pl4Mq0CKFLNbdLhCLpDLpmjDb3jjtpXPZaKKq5RO8cCWfe9)YXiNO5qsZ2Rv(SuEDuEWuEgmuEaeuuEJie09eKfFCizUykMlw8nfkHKdjOjgqso5P6uOZaKKyyAko4geCTPKUYdTv8i90fCtiAoYVYZGHYdUYNUYhMKUG7KKPN40zassO8vuEbo4cI(F5yKt0CiPz71kFwkVokpytXCXIVPOHHHjFDaxMPjgqswNP6uOZaKKyyAko4geCTPaTv8i90fCtiAoY)umxS4Bk5FluMVNyIbKKz)uDkMlw8nfSEc(JZj4uOZaKKyyAIbKKZ(uDk0zassmmnfhCdcU2uctsxWrjOEm8HrFawesItNbijXumxS4Bk5FluMVNyIbKKb9P6uOZaKKyyAko4geCTPKUYhMKUGJsq9y4dJ(aSiKeNodqscLVIYNUYdTv8i90fCtiAoY)umxS4BkT00Myaj5SnvNI5IfFtr)6cmu3heP)McDgGKedttmGKm7yQofZfl(MYQ9tNyV6N(1fyOUtHodqsIHPjMykORE6fgSMIP6asYt1PqNbijXW0uCWni4AtbA1KYNLYNT0u(kkp4kF6kFys6cUGmHu3NZKAC6majjuEgmuEaeuuUGmHu3NZKACbo)uEWMI5IfFtPzgrk7F5gbbNyarNP6uOZaKKyyAko4geCTPaUYNUYhMKUGNBqaizmtqoDgGKekpdgkVdJLcC(XZniaKmMjihsA2ETYNLYRJYd2umxS4BkqtVvtWjgqy)uDk0zassmmnfhCdcU2ueeackk3HL4Ur6xRz9hxGZVPyUyX3uCyjUBK(1Aw)nXas2NQtHodqsIHPP4GBqW1MIGaqqr5oSe3ns)AnR)4cC(nfZfl(MsUbbGKXmbNyab0NQtHodqsIHPP4GBqW1McackkVZj6FV6xhWLzQ5cC(P8vuEWv(0v(WK0fCbzcPUpNj140zassO8myO8aiOOCbzcPUpNj14cC(P8GP8vuEWvEWvEbbGGIYDyjUBK(1Aw)XHKMTxR8Gs5Zoh0v(kkF6kVLeeCdIhuhpm6tBR)coDgGKekpykpdgkpackkpOoEy0N2w)fCKFLhSPyUyX3uaKMG6ad1MyajBt1PyUyX3ueKjK6(CMuBk0zassmmnXac7yQofZfl(MItsMEAk0zassmmnXac7ovNcDgGKedttXb3GGRnfWv(0v(WK0fCNKm9eNodqscLVIYlWbxq0)lhJCIMdjnBVw5Zs51r5bt5zWq5bx5bqqr5nIqq3tqw8XHK5cLNbdLhabfL3b(O3hzWGdjZfkpykFfLhCLhabfL35e9Vx9Rd4Ym1CKFLNbdL3HXsbo)4Dor)7v)6aUmtnhsA2ETYdkLNDvEWMI5IfFtHsi5qcAIbe25uDk0zassmmnfhCdcU2uax5tx5dtsxWDsY0tC6majju(kkVahCbr)VCmYjAoK0S9ALplLxhLhmLNbdLhabfL35e9Vx9Rd4Ym1CKFLVIYdGGIYX6j4poNG8omhZkplLxhLVIYdUYhMKUGlGKjodP(l40zassO8myO8aiOOCkHKdjw8rW(9dj32l(4DyoMvEwkVokpytXCXIVPOHHHjFDaxMPjgqsoTP6uOZaKKyyAko4geCTPiiaeuuUdlXDJ0VwZ6poYVYZGHYdUYdGGIYDqK(BV6N1THidoYVYxr5dtsxWrjOEm8HrFawesItNbijHYd2umxS4Bk5FluMVNyIbKKtEQof6majjgMMIdUbbxBkaiOOCbzcPUpNj14i)kpdgkp0QjLhukF2sBkMlw8nL8VfkZ3tmXasY6mvNI5IfFtbRNG)4Ccof6majjgMMyajz2pvNI5IfFtj)BHY89etHodqsIHPjgqso7t1PyUyX3u0VUad19br6VPqNbijXW0edijd6t1PyUyX3uwTF6e7v)0VUad1Dk0zassmmnXetmf9eSx8nGOtAjZUPXozFACDyVojpLCdE7v3tjbt7hddsO8zt5nxS4t5LBhnxLAk9p5gqyhjpLFigDL0usaLpPGATYdAAq4IHQujGY)fXFNKZKPEJpeaUdRLPxnePfl(CqdnY0RMldGedKba1sAbPpZpeJUsQZaAHusYwrNb0MKEGMgeUy4lPGAnVxnNkvcO8f6pinacQ8SpTevEDslz2v5tALxh2NK1jnvkvQeq5bn8zxn1jzvQeq5tALpPecsO8GwennsYvPsaLpPv(KsiiHYNGVUad1v5tsi9xMemTF6e7vR8j4RlWqD5QujGYN0kFsjeKq5zYIqskF5dJekFGv(Fi5WAawO8jfOf0ixLsLkbu(eKjKCibjuEacfdjL3H1aSq5bO69AUYNuoh9hTYF4lP)mOgkIu5nxS4RvE8j1LRszUyXxZ)HKdRbybluP1mRszUyXxZ)HKdRbybBSYGIXcvkZfl(A(pKCynalyJvgdPwJUWIfFQujGYxo7V)WHYdTvO8aiOOKq57WIw5biumKuEhwdWcLhGQ3RvE7ek)pKs6FCe7vR8BR8c8rCvkZfl(A(pKCynalyJvM(S)(dhVoSOvPmxS4R5)qYH1aSGnwzaSiK0R)WiHkL5IfFn)hsoSgGfSXkZpow8PsPsLakFcYesoKGekpPNG6Q8XQrkF8rkV5cmu53w5n92knajXvPmxS4Rz5(mynPszUyXxZgRm)iAAKuLYCXIVMnwz(XXIpvkZfl(A2yLbqIXIhkcu3exuwccabfL7WsC3i9R1S(JJ8RszUyXxZgRmaeSjiZ7vN4IYsqaiOOChwI7gPFTM1FCKFvkZfl(A2yLXGo7OxGHq6IexuwccabfL7WsC3i9R1S(JlW5xfhglf48JRHHHjFDaxMjoK0S9AqLmh0RaTAklqpnvkZfl(A2yLrU1Fr)sqGiQ1OlsCrzjiaeuuUdlXDJ0VwZ6pUaNFQuMlw81SXkd6cjajglsCrzjiaeuuUdlXDJ0VwZ6poYVkL5IfFnBSYyNJ6aAYNZKYexuwccabfL7WsC3i9R1S(JJ8RszUyXxZgRmin92G0AvkZfl(A2yLX0BHbtCrz5WyPaNFChwI7gPFTM1FCiPz71zXUmyaEys6cEUbbGKXmb50zassuXHXsbo)45geasgZeKdjnBVol2fmvkZfl(A2yLPZj6FV6xhWLzQtCrz1)Ku(cdwtrZZ)wOmFpbOsUc4omwkW5hhqAcQdmuJdjnBVgujNgdgomwkW5h3HL4Ur6xRz9hhsA2EnOyxgmSKGGBq8G64HrFAB9xWPZaKKamvkZfl(A2yLbICpZfl(EYTJeptJy9zUexuwqBfpspDb3eIMtjC7OvPmxS4RzJvgiY9mxS47j3os8mnIf6QNEHbRPiXfLv)ts5lmynfnp)BHY89eGk7QuMlw81SXkde5EMlw89KBhjEMgXIsi5qckXfLf4HjPl4Aw3MdsC6majjQegSMc(hzY4J)7ISypOdgdgHbRPG)rMm(4)UilDstLYCXIVMnwzGi3ZCXIVNC7iXZ0iw9E1s6fgSMcvkvkZfl(AoLqYHeeRMzePS)LBeemXfLf0QPSYwAvap9WK0fCbzcPUpNj140zassWGbackkxqMqQ7ZzsnUaNFGPszUyXxZPesoKGyJvgOP3QjyIlkR0bqqr5cYesDFotQXr(RaUdJLcC(XDyjUBK(1Aw)XHKMTxNLomyaEys6cEUbbGKXmb50zassuXHXsbo)45geasgZeKdjnBVolDadmvkZfl(AoLqYHeeBSY4WsC3i9R1S(lXfLLGaqqr5oSe3ns)AnR)4cC(PszUyXxZPesoKGyJvMCdcajJzcM4IYsqaiOOChwI7gPFTM1FCbo)uPmxS4R5ucjhsqSXkJGmHu3NZKAQuMlw81CkHKdji2yLbqAcQdmulXfLf0QPSyFAvshabfLliti195mPgh5xLYCXIVMtjKCibXgRmojz6Pexuw9pjLVWG1u088VfkZ3takDuPmxS4R5ucjhsqSXktlnTexuwaiOOCheP)2R(zDBiYGJ8RszUyXxZPesoKGyJvgnmmm5Rd4YmL4IYcabfLJ1tWFCob5DyoMzPtLWK0fCbKmXzi1FbNodqscgmaqqr5ucjhsS4JG97hsUTx8X7WCmZshvkZfl(AoLqYHeeBSYqjKCibL4IYcabfLliti195mPgh5xLYCXIVMtjKCibXgRmy9e8hNtqvkZfl(AoLqYHeeBSYqjKCibPsPszUyXxZrx90lmynfSAMrKY(xUrqWexuwqRMYkBPvb80dtsxWfKjK6(CMuJtNbijbdgaiOOCbzcPUpNj14cC(bMkL5IfFnhD1tVWG1uWgRmqtVvtWexuwGNEys6cEUbbGKXmb50zassWGHdJLcC(XZniaKmMjihsA2EDw6aMkL5IfFnhD1tVWG1uWgRmoSe3ns)AnR)sCrzjiaeuuUdlXDJ0VwZ6pUaNFQuMlw81C0vp9cdwtbBSYKBqaizmtWexuwccabfL7WsC3i9R1S(JlW5NkL5IfFnhD1tVWG1uWgRmastqDGHAjUOSaqqr5Dor)7v)6aUmtnxGZVkGNEys6cUGmHu3NZKAC6majjyWaabfLliti195mPgxGZpWQao4ccabfL7WsC3i9R1S(JdjnBVguzNd6vs3sccUbXdQJhg9PT1FbNodqscWyWaabfLhuhpm6tBR)coYpyQuMlw81C0vp9cdwtbBSYiiti195mPMkL5IfFnhD1tVWG1uWgRmojz6jvkZfl(Ao6QNEHbRPGnwzOesoKGsCrzbE6HjPl4ojz6joDgGKeve4Gli6)LJrorZHKMTxNLoGXGb4aiOO8griO7jil(4qYCbdgaiOO8oWh9(idgCizUaSkGdGGIY7CI(3R(1bCzMAoYpdgomwkW5hVZj6FV6xhWLzQ5qsZ2Rbf7cMkL5IfFnhD1tVWG1uWgRmAyyyYxhWLzkXfLf4PhMKUG7KKPN40zassurGdUGO)xog5enhsA2EDw6agdgaiOO8oNO)9QFDaxMPMJ8xbabfLJ1tWFCob5DyoMzPtfWdtsxWfqYeNHu)fC6majjyWaabfLtjKCiXIpc2VFi52EXhVdZXmlDatLYCXIVMJU6PxyWAkyJvM8VfkZ3tK4IYsqaiOOChwI7gPFTM1FCKFgmahabfL7Gi93E1pRBdrgCK)kHjPl4Oeupg(WOpalcjXPZaKKamvkZfl(Ao6QNEHbRPGnwzY)wOmFprIlklaeuuUGmHu3NZKACKFgmGwnbQSLMkL5IfFnhD1tVWG1uWgRmy9e8hNtqvkZfl(Ao6QNEHbRPGnwzY)wOmFpHkL5IfFnhD1tVWG1uWgRm6xxGH6(Gi9NkL5IfFnhD1tVWG1uWgRmR2pDI9QF6xxGH6QsPszUyXxZ)mhliDIexuwqsZ2RZILabAXIVe004SVc4PdTv8i90fCtiAoYpdgaiOO8oNO)9QFDaxMPMJ8dMkL5IfFn)ZCSXktZmIu2)YnccM4IYcA1uwzlTkG7WyPaNFCbzcPUpNj14qsZ2Rbf7zWi9WK0fCbzcPUpNj140zassaMkL5IfFn)ZCSXkJGmHu3NZKAjUOSa3HXsbo)4astqDGHACiPz71GkBmyeMKUGdn9wnb50zassuXHXsbo)4qtVvtqoK0S9AqLnWQaUdJLcC(XDyjUBK(1Aw)XHKMTxNLomyaEys6cEUbbGKXmb50zassuXHXsbo)45geasgZeKdjnBVolDadmvkZfl(A(N5yJvgOP3QjyIlklWH2kEKE6cUjenh5NbdOTIhPNUGBcrZ3duHbRPGhRg9c8tSeyva3HXsbo)4oSe3ns)AnR)4qsZ2RZshgmapmjDbp3GaqYyMGC6majjQ4WyPaNF8CdcajJzcYHKMTxNLoGbMkL5IfFn)ZCSXkJdlXDJ0VwZ6VexuwqBfpspDb3eIMJ8ZGb0wXJ0txWnHO57bQSNgdgGdTv8i90fCtiA(EGsN0QeMKUGBxnbFA2z1KgDbNodqscWuPmxS4R5FMJnwzYniaKmMjyIlklOTIhPNUGBcrZr(zWaAR4r6Pl4Mq089av2tJbdWH2kEKE6cUjenFpqPtAvctsxWTRMGpn7SAsJUGtNbijbyQuMlw818pZXgRmastqDGHAjUOSaqqr5Dor)7v)6aUmtnxGZVkGdUGaqqr5oSe3ns)AnR)4i)vG2kEKE6cUjenFpqfgSMcESA0lWpXsGXGb0wXJ0txWnHO5i)vahCbbGGIYDyjUBK(1Aw)XHKMTxdQSZb9kPBjbb3G4b1XdJ(026VGtNbijbymyaGGIYdQJhg9PT1Fbh5hmWuPmxS4R5FMJnwzW6j4poNGjUOSshAR4r6Pl4Mq0CKFgmahAR4r6Pl4Mq0CK)kwsqWniEtBRTUxUPN40zassaMkL5IfFn)ZCSXkJtsMEkXfLv)ts5lmynfnp)BHY89eGshvkZfl(A(N5yJvgkHKdjOexuwPdTv8i90fCtiAoYpdgGNEys6cUtsMEItNbijrfbo4cI(F5yKt0CiPz71zPdymyaGGIYBeHGUNGS4JdjZfQuMlw818pZXgRmAyyyYxhWLzkXfLv6qBfpspDb3eIMJ8ZGb4PhMKUG7KKPN40zassurGdUGO)xog5enhsA2EDw6aMkL5IfFn)ZCSXkt(3cL57jsCrzbTv8i90fCtiAoYVkL5IfFn)ZCSXkdwpb)X5euLYCXIVM)zo2yLj)BHY89ejUOSctsxWrjOEm8HrFawesItNbijHkL5IfFn)ZCSXktlnTexuwPhMKUGJsq9y4dJ(aSiKeNodqsIkPdTv8i90fCtiAoYVkL5IfFn)ZCSXkJ(1fyOUpis)PszUyXxZ)mhBSYSA)0j2R(PFDbgQRkLkL5IfFnV3RwsVWG1uWcsNiXfLfK0S96SyjqGwS4lbnno7RiiaeuuUdlXDJ0VwZ6pUaNFQuMlw818EVAj9cdwtbBSY0mJiL9VCJGGjUOSGwnLv2sRc4PhMKUGliti195mPgNodqscgmaqqr5cYesDFotQXf48dmvkZfl(AEVxTKEHbRPGnwzGMERMGjUOSshabfLliti195mPgh5Vc4omwkW5h3HL4Ur6xRz9hhsA2EDw6WGb4HjPl45geasgZeKtNbijrfhglf48JNBqaizmtqoK0S96S0bmWuPmxS4R59E1s6fgSMc2yLXHL4Ur6xRz9xIlklbbGGIYDyjUBK(1Aw)Xf48tLYCXIVM37vlPxyWAkyJvMCdcajJzcM4IYsqaiOOChwI7gPFTM1FCbo)uPmxS4R59E1s6fgSMc2yLrqMqQ7ZzsnvkZfl(AEVxTKEHbRPGnwzOesoKGsCrzbGGIYBeHGUNGS4JdjZfQuMlw818EVAj9cdwtbBSYainb1bgQL4IYYHXsbo)4AyyyYxhWLzIdjnBVUc4PhMKUGliti195mPgNodqscgmaqqr5cYesDFotQXf48dSkGdUGaqqr5oSe3ns)AnR)4i)vs3sccUbXdQJhg9PT1FbNodqscWyWaabfLhuhpm6tBR)coYpyQuMlw818EVAj9cdwtbBSY4KKPNsCrz1)Ku(cdwtrZZ)wOmFpbO0rLYCXIVM37vlPxyWAkyJvgSEc(JZjyIlkllji4geVPT1w3l30tCODmZI9QuMlw818EVAj9cdwtbBSYOHHHjFDaxMjvkZfl(AEVxTKEHbRPGnwzY)wOmFprIlkRWK0fCucQhdFy0hGfHK40zassubCaeuuUGmHu3NZKACKFgmGwnbkwzlnWuPmxS4R59E1s6fgSMc2yLbRNG)4CcQszUyXxZ79QL0lmynfSXkt(3cL57jsCrzfMKUGJsq9y4dJ(aSiKeNodqsIkGNULeeCdIhuhpm6tBR)coDgGKemyiiaeuuUdlXDJ0VwZ6poYpyQuMlw818EVAj9cdwtbBSY0stlXfLv6HjPl4Oeupg(WOpalcjXPZaKKOc4PBjbb3G4b1XdJ(026VGtNbijbdgccabfL7WsC3i9R1S(JJ8ZGbackkxqMqQ7ZzsnoYpdgqRMafRSLgyQuMlw818EVAj9cdwtbBSYOFDbgQ7dI0FQuMlw818EVAj9cdwtbBSYSA)0j2R(PFDbgQ7etmd]] )


end
