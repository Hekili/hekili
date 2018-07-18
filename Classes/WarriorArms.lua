-- WarriorArms.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 71 )

    local base_rage_gen, arms_rage_mult = 1.75, 4.286

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand = {
            last = function ()
                local swing = state.combat == 0 and state.now or state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = 'mainhand_speed',

            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * arms_rage_mult * state.swings.mainhand_speed
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
            
            usable = function () return buff.battle_shout.remains < 10 end,
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
            charges = function () return talent.double_time.enabled and 2 or 1 end,
            cooldown = function () return talent.double_time.enabled and 17 or 20 end,
            recharge = function () return talent.double_time.enabled and 17 or 20 end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132337,
            
            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd ) end,
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
            id = 163201,
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
            charges = function () return ( level < 116 and equipped.timeless_strategem ) and 3 or 1 end,
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
            charges = function () return talent.dreadnaught.enabled and 2 or 1 end,
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
            gcd = "spell",
            
            startsCombat = true,
            texture = 132938,
            
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
            cooldown = function () return 21 * haste end,
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
                return 20
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132340,
            
            recheck = function () return rage.time_to_40 end,
            handler = function ()
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 4, "rage" ) end
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
            
            handler = function ()
                removeBuff( "victorious" )
            end,
        },
        

        warbreaker = {
            id = 262161,
            cast = 0,
            cooldown = 45,
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
        damageExpiration = 8,
    
        package = "Arms",
    } )

    spec:RegisterPack( "Arms", 20180715.0805, [[duub2aqiHKhHIQ0MOsnkPuNskzvcrYROsAwcHBjePSlI(fvKHPK0XOcTmHuptkW0Kc11KczBOOY3qrX4Kc6COOQ6DcrQmpLe3JqTpQOoikkXcPs8quuvMikkvUikkjTruus8ruuQAKOOu6KOOkwjkyNublffLupfKPIcTxu9xPAWKCyklMGhtvtMuxgAZG6ZkXOf0PrSAuukETu0Sr62O0Uv1VvmCH64crSCvEUOPl56k12vs9DbgVquNhfz9crQA(eY(bM7iNroK2kK7q0R6ydxLzCSrYvB4QnkAMHdvmfJCOyZ30wqo0BSihIz5ytouSXeDmnNrouo7ZJCiMLZhsylYnjhsytOfZZZf4qARqUdrVQJnCvMXXgjxLzCCvhDKdz7kCooeZY5djSf5MKdPX0ZHymKKafjbkdOInFtBbbQbgOmFrMhOOKSsGcEoGIzl2KqjsadagymKKavGLav8nRjAuducmbumlNpKWwKBsGYEnqrsGYaQG5AgPr(iT4BwomtjGbadmgIa18uMakFO9lycuvOvafZdq1Mzl2KqjTaQqBncuSMgbk7qGQgGkExafuZnLMXusv4bugCHhqX8n0jZDcuqSwgcuKhOIpYCKIPiaQCaksbuc4JWKkbk4BybQkebkMpiGsJcByyjGbadmRmhqvHiqXSCSjqLXONyusKERiZhbqX8aubekfOeqGkyUMKFbOMhOiSX3SM8lafZABbbk2rJuYVauW3WcubOfppqLbKFjLafqX88avfIaflAFryXiakMMnqXAmbuJ3BjzEJszcOsebkiQXcuXtmqTJbQGq8bQdnFi5xCk2YK8lavdwfOywBlyKoGQcjjqfAXX4Navqi(aLbubOfppqLbKFbOcSeOWihJ(c1aLacphcuvicu4VqEeOynncuh6hww81wrMpJaOe2fqfyjqPrQXeQbk45aQCyrG6qlNxYHOKSsoJCOK8luSx2TGfNrUdoYzKdHVjqrn3foK)ifEeJdDiRr(eOwrmqP3NvK5bQifqTQSbaLBGsJcByyPFOtM7SNSwgk1tWZHmFrMNdD4R5f3HO5mYHW3eOOM7chYFKcpIXHoBbbQvakMzvGYnq1gO8Zq1tWl1OPPm19gLvEiRr(eOCgOAaqjseqffqvgf)sQrttzQ7nkReFtGIAGQfhY8fzEou2CtPzmLufE8I7qd4mYHW3eOOM7chYFKcpIXH8Zq1tWlfOMgZAow5HSg5tGYzGI5ak3avBGQnq5NHQNGx6h6K5o7jRLHYdznYNa1kav0aLiravBGQmk(LmWoHdTM4jX3eOOgOCdu(zO6j4Lb2jCO1ep5HSg5tGAfGkAGQfq1cOejcOAduyKSjXXOwgGKLWQpW9ke7ODviq5gO8Zq1tWldXBi(ofTy5HSg5tGAfGkAGQfq1Idz(ImphsJMMYu3BuwEXDOXCg5q4BcuuZDHd5psHhX4qcByyPFOtM7SNSwgk1tWZHmFrMNd5h6K5o7jRLH8I7qJ4mYHW3eOOM7chYFKcpIXHe2WWs)qNm3zpzTmuQNGNdz(ImphkWoHdTM4XlUdmhNroe(Maf1Cx4q(Ju4rmoegjBsCmQLbizjS6dCVcXoAxfcuUbknkSHHL(HozUZEYAzOupbpq5gOAduTbk)mu9e8s)qNm3zpzTmuEiRr(eOCgOAiq5gOIcOIpCDFXRLok9dDYCN9K1YqGQfqjseq1gOkJIFjdSt4qRjEs8nbkQbk3aLFgQEcEzGDchAnXtEiRr(eOCgOAiq5gOIcOIpCDFXRLokdSt4qRjEavlGQfhY8fzEouiEdX3POfZlUdmdNroe(Maf1Cx4q(Ju4rmoKWggwMBTg)UgTkuEO5lGsKiGsyddlZAEShI2vYdnFXHmFrMNdHrg97c5f3HgYzKdHVjqrn3foK)ifEeJdjSHHLzaIXKFPN1rAIPupbpq5gO0OWggw6h6K5o7jRLHYdznYNaLZavJLncOCduTbQ4dx3x8APJs25kJ2Z6inrGsKiGkJrkTx2TGvkdcjhnG8AGYzGYrGQfq5gOAdurbucByyPgnnLPU3OSYDmqjseqffqvgf)sQrttzQ7nkReFtGIAGQfhY8fzEoKa10ywZXYlUdm)Cg5q4BcuuZDHd5psHhX4qAuyddl9dDYCN9K1Yq5ogOCduTbk)mu9e8snAAktDVrzLhYAKpbkNbkMdOejcOIcOkJIFj1OPPm19gLvIVjqrnq1Idz(Imph6S12cE8I7GJRYzKdHVjqrn3foK)ifEeJdLXiL2l7wWkLbHKJgqEnq5mqfnhY8fzEoKNI2AKxChC0roJCiZxK55qSZvgTN1rAICi8nbkQ5UWlUdognNroK5lY8COznEXtaECi8nbkQ5UWlUdo2aoJCi8nbkQ5UWH8hPWJyCOYO4xsy8wpxFG7cwvuuIVjqrnq5gOAduNTGaLZIbQgTkqjseqPrHnmS0p0jZD2twldL7yGQfhY8fzEouqi5ObKxZlUdo2yoJCi8nbkQ5UWH8hPWJyCOOaQYO4xsy8wpxFG7cwvuuIVjqrnq5gOAduNTGaLZIbQgVkqjseqPrHnmS0p0jZD2twldL7yGQfhY8fzEousnwEXloKgHTnT4mYDWroJCiZxK55q2UMUvL5BYHW3eOOM7cV4oenNroK5lY8CiFODlihcFtGIAUl8I7qd4mYHW3eOOM7ch6nwKdDKFPpWD)qPwCs(Lo8U2hMCiZxK55qh5x6dC3puQfNKFPdVR9HjhYFKcpIXHIcOe2WWYczJlRiZl3X8I7qJ5mYHW3eOOM7chYFKcpIXH0OWggw6h6K5o7jRLHs9e8CiZxK55quYsyLDMnB9cl(fV4o0ioJCiZxK55q7e7Kcztoe(Maf1Cx4f3bMJZihcFtGIAUlCi)rk8ighsJcByyPFOtM7SNSwgk3XCiZxK55qc0z0D49XeV4oWmCg5q4BcuuZDHd5psHhX4qAuyddl9dDYCN9K1Yq5oMdz(ImphsaVeVMKFHxChAiNroe(Maf1Cx4q(Ju4rmoKgf2WWs)qNm3zpzTmuQNGhOCdu(zO6j4LSZvgTN1rAIYdznYNaLZafZEMpMDaLBG6SfeOwbOA0QaLBGkkGsyddl1OPPm19gLvUJ5qMViZZHSZBp2R5o8lEXDG5NZihcFtGIAUlCi)rk8ighkJrkTx2TGvkdcjhnG8AGYzGYroK5lY8COmaXyYV0Z6inXKxChCCvoJCi8nbkQ5UWHmFrMNdD7VB(ImFNsYId5psHhX4qzmsP9YUfSszqi5ObKxduodunMdrjz1FJf5qWK1yVSBblEXDWrh5mYHW3eOOM7chY8fzEo0T)U5lY8DkjloK)ifEeJd1gOkJIFjzTmn)Hs8nbkQbk3avz3cwYq0OvOm2xa1kavdAeq1cOejcOk7wWsgIgTcLX(cOwbOIEvoeLKv)nwKdHrg97c5f3bhJMZihcFtGIAUlCiZxK55q3(7MViZ3PKS4qusw93yrous(fk2l7wWIx8IdfFOFyfSIZi3bh5mYHW3eOOM7chQykg5q(z)ffZSBhlbtEXDiAoJCi8nbkQ5UWHkMIroe1wtYWEUpJ1UomAzXlUdnGZihcFtGIAUlCOIPyKdPrycf18I7qJ5mYHmFrMNdjyvrXEgo7IdHVjqrn3fEXDOrCg5q4BcuuZDHxChyooJCi8nbkQ5UWHINImphAO6EGDCiZxK55qXtrMNx8IdHrg97c5mYDWroJCi8nbkQ5UWH8hPWJyCOdznYNa1kIbk9(SImpqfPaQvLnaOCduAuyddl9dDYCN9K1YqPEcEoK5lY8COdFnV4oenNroe(Maf1Cx4q(Ju4rmo0zliqTcqXmRcuUbQ2avBGYpdvpbVuJMMYu3Buw5HSg5tGYzGQbaLBGkkGsyddl1OPPm19gLvUJbQwaLiravuavzu8lPgnnLPU3OSs8nbkQbQwCiZxK55qzZnLMXusv4XlUdnGZihcFtGIAUlCi)rk8ighYpdvpbVuGAAmR5yLhYAKpbkNbkMdOCduTbQ2aLFgQEcEPFOtM7SNSwgkpK1iFcuRaurduIebuTbQYO4xYa7eo0AINeFtGIAGYnq5NHQNGxgyNWHwt8KhYAKpbQvaQObQwavlGsKiGQnqHrYMehJAzaswcR(a3RqSJ2vHaLBGYpdvpbVmeVH47u0ILhYAKpbQvaQObQwavloK5lY8CinAAktDVrz5f3HgZzKdHVjqrn3foK)ifEeJdjSHHL(HozUZEYAzOupbphY8fzEoKFOtM7SNSwgYlUdnIZihcFtGIAUlCi)rk8ighsyddl9dDYCN9K1YqPEcEoK5lY8COa7eo0AIhV4oWCCg5q4BcuuZDHd5psHhX4qyKSjXXOwgGKLWQpW9ke7ODviq5gO0OWggw6h6K5o7jRLHs9e8aLBGQnq1gO8Zq1tWl9dDYCN9K1Yq5HSg5tGYzGQHaLBGkkGk(W19fVw6O0p0jZD2twldbQwaLiravBGQmk(LmWoHdTM4jX3eOOgOCdu(zO6j4Lb2jCO1ep5HSg5tGYzGQHaLBGkkGk(W19fVw6OmWoHdTM4buTaQwCiZxK55qH4neFNIwmV4oWmCg5q4BcuuZDHd5psHhX4qAuyddl9dDYCN9K1Yq5HSg5tGYzGQXYgbuUbQZwqGAfGIzwfOCduTbQOakHnmSuJMMYu3Buw5ogOejcOIcOkJIFj1OPPm19gLvIVjqrnq1Idz(ImphsGAAmR5y5f3HgYzKdHVjqrn3foK)ifEeJdPrHnmS0p0jZD2twldL7yGYnq1gO8Zq1tWl1OPPm19gLvEiRr(eOCgOyoGsKiGkkGQmk(LuJMMYu3Buwj(Maf1avloK5lY8COZwBl4XlUdm)Cg5q4BcuuZDHd5psHhX4qzmsP9YUfSszqi5ObKxduodurZHmFrMNd5POTg5f3bhxLZihcFtGIAUlCi)rk8ighsyddlN14fpb4jZY8nbkXav0aLBGQnqvgf)sQp00VTxclj(Maf1aLirafgjBsCmQL25dT1ZN9q0wZup0Enq1Idz(ImphIDUYO9SostKxChC0roJCiZxK55qZA8INa84q4BcuuZDHxChCmAoJCi8nbkQ5UWH8hPWJyCOZwqGYzXavJxfOejcO0OWggw6h6K5o7jRLHYDmqjseqjSHHL5wRXVRrRcLhA(cOejcOe2WWYSMh7HODL8qZxCiZxK55qyKr)UqEXloemzn2l7wWIZi3bh5mYHW3eOOM7chYFKcpIXHoK1iFcuRigO07ZkY8avKcOwv2aGYnqjSHHLzaIXKFPN1rAIPChZHmFrMNdD4R5f3HO5mYHW3eOOM7chYFKcpIXHoBbbQvakMzvGYnq1gO8Zq1tWl1OPPm19gLvEiRr(eOCgOAaqjseqffqvgf)sQrttzQ7nkReFtGIAGQfhY8fzEou2CtPzmLufE8I7qd4mYHW3eOOM7chYFKcpIXH8Zq1tWlfOMgZAow5HSg5tGYzGI5ak3avBGQnq5NHQNGx6h6K5o7jRLHYdznYNa1kav0aLiravBGQmk(LmWoHdTM4jX3eOOgOCdu(zO6j4Lb2jCO1ep5HSg5tGAfGkAGQfq1cOejcOAduyKSjXXOwgGKLWQpW9ke7ODviq5gO8Zq1tWldXBi(ofTy5HSg5tGAfGkAGQfq1Idz(ImphsJMMYu3BuwEXDOXCg5q4BcuuZDHd5psHhX4qcByyPFOtM7SNSwgk1tWZHmFrMNd5h6K5o7jRLH8I7qJ4mYHW3eOOM7chYFKcpIXHe2WWs)qNm3zpzTmuQNGNdz(ImphkWoHdTM4XlUdmhNroe(Maf1Cx4q(Ju4rmoegjBsCmQLbizjS6dCVcXoAxfcuUbknkSHHL(HozUZEYAzOupbpq5gOAduTbk)mu9e8s)qNm3zpzTmuEiRr(eOCgOAiq5gOIcOIpCDFXRLok9dDYCN9K1YqGQfqjseq1gOkJIFjdSt4qRjEs8nbkQbk3aLFgQEcEzGDchAnXtEiRr(eOCgOAiq5gOIcOIpCDFXRLokdSt4qRjEavlGQfhY8fzEouiEdX3POfZlUdmdNroe(Maf1Cx4q(Ju4rmoKWggwMbigt(LEwhPjMs9e8aLBGsJcByyPFOtM7SNSwgkpK1iFcuodunw2iGYnq1gOIpCDFXRLokzNRmApRJ0ebkrIaQmgP0Ez3cwPmiKC0aYRbkNbkhbQwaLBGQnqffqjSHHLA00uM6EJYk3XaLiravuavzu8lPgnnLPU3OSs8nbkQbQwCiZxK55qcutJznhlV4o0qoJCi8nbkQ5UWH8hPWJyCinkSHHL(HozUZEYAzOChduUbQ2aLFgQEcEPgnnLPU3OSYdznYNaLZafZbuIeburbuLrXVKA00uM6EJYkX3eOOgOAXHmFrMNdD2ABbpEXDG5NZihY8fzEoKNI2AKdHVjqrn3fEXDWXv5mYHW3eOOM7chYFKcpIXHAdurbuLrXVKEkARrj(Maf1aLBGspLuJyCpy2VoLhYAKpbQvaQObQwaLiravBGsyddlZTwJFxJwfkp08fqjseqjSHHLznp2dr7k5HMVaQwaLBGQnqjSHHLzaIXKFPN1rAIPChduIebu(zO6j4LzaIXKFPN1rAIP8qwJ8jq5mq1qGQfhY8fzEoegz0VlKxChC0roJCi8nbkQ5UWH8hPWJyCO2avuavzu8lPNI2AuIVjqrnq5gO0tj1ig3dM9Rt5HSg5tGAfGkAGQfqjseqjSHHLzaIXKFPN1rAIPChduUbkHnmSCwJx8eGNmlZ3eOedurduUbQ2avzu8lP(qt)2EjSK4BcuuduIebuyKSjXXOwANp0wpF2drBnt9q71avloK5lY8Ci25kJ2Z6inrEXDWXO5mYHW3eOOM7chYFKcpIXH0OWggw6h6K5o7jRLHYDmhY8fzEouqi5ObKxZlUdo2aoJCiZxK55qZA8INa84q4BcuuZDHxChCSXCg5qMViZZHccjhnG8Aoe(Maf1Cx4fV4fhAnEjzEUdrVQJnCvMXXglDC1g3iouGDp5xsoehk(gycf5qMViZNY4d9dRGvIHPw2mIIPyuSF2FrXm72XsWeWG5lY8Pm(q)WkyLRIDcEgDeftXOyQTMKH9CFgRDDy0YcWG5lY8Pm(q)WkyLRIDY2lS4xwrMpIIPyuSgHjuudyW8fz(ugFOFyfSYvXojyvrXEgo7cWaZlqb9wCgofqDgrducByyuduzzvcuci8Ciq5hwbRakbCH8jqzVgOIpmslEQI8lafjbk98OeWG5lY8Pm(q)WkyLRIDkFlodNQNLvjGbZxK5tz8H(HvWkxf7u8uK5J4nwu8q19a7amauagyEbkMvJm63fQbkCnEmbufHfbQkebkZxZbuKeOS1gHAcuucyW8fz(uSTRPBvz(MagmFrMpDvSt(q7wqadmVafJHKeOijqXozrzcOQbOIpCn(fq5NHQNGpbk4BybkbK8laL59en(LrPmbu7e1aLEFKFbOyN1il(LeWaZR5lY8PRIDkEkY8r8glkEO6EGDrqGflSHHLh6BsXmFmt5ogWG5lY8PRIDANyNuiBeVXIIpYV0h4UFOuloj)shEx7dZiiWIJsyddllKnUSImVChdyaOamy(ImF6QyNOKLWk7mB26fw8RiiWI1OWggw6h6K5o7jRLHs9e8agmFrMpDvSt7e7KcztadMViZNUk2jb6m6o8(ykccSynkSHHL(HozUZEYAzOChdyW8fz(0vXojGxIxtYVebbwSgf2WWs)qNm3zpzTmuUJbmy(ImF6QyNSZBp2R5o8RiiWI1OWggw6h6K5o7jRLHs9e8U9Zq1tWlzNRmApRJ0eLhYAKpDMzpZhZo3NTGR0OvDhLWggwQrttzQ7nkRChdyW8fz(0vXoLbigt(LEwhPjMrqGfNXiL2l7wWkLbHKJgqETZocyW8fz(0vXoD7VB(ImFNsYkI3yrXWK1yVSBbRiiWIZyKs7LDlyLYGqYrdiV25gdyW8fz(0vXoD7VB(ImFNsYkI3yrXyKr)UWiiWIBxgf)sYAzA(dL4Bcuu7USBblziA0kug7RvAqJAjsuz3cwYq0OvOm2xRe9QagmFrMpDvSt3(7MViZ3PKSI4nwuCs(fk2l7wWcWaqbyW8fz(uctwJ9YUfSCvSth(6iiWIpK1iFUIy9(SImFKAvzdClSHHLzaIXKFPN1rAIPChdyW8fz(uctwJ9YUfSCvStzZnLMXusv4fbbw8zl4kmZQUB7NHQNGxQrttzQ7nkR8qwJ8PZnqKOOkJIFj1OPPm19gLvIVjqrDladMViZNsyYASx2TGLRIDsJMMYu3Bu2iiWI9Zq1tWlfOMgZAow5HSg5tNzo3TB7NHQNGx6h6K5o7jRLHYdznYNReTirTlJIFjdSt4qRjEs8nbkQD7NHQNGxgyNWHwt8KhYAKpxj6wTejQngjBsCmQLbizjS6dCVcXoAxf62pdvpbVmeVH47u0ILhYAKpxj6wTamy(ImFkHjRXEz3cwUk2j)qNm3zpzTmmccSyHnmS0p0jZD2twldL6j4bmy(ImFkHjRXEz3cwUk2Pa7eo0AIxeeyXcByyPFOtM7SNSwgk1tWdyW8fz(uctwJ9YUfSCvStH4neFNIwCeeyXyKSjXXOwgGKLWQpW9ke7ODvOBnkSHHL(HozUZEYAzOupbV72T9Zq1tWl9dDYCN9K1Yq5HSg5tNBO7OIpCDFXRLok9dDYCN9K1YWwIe1Umk(LmWoHdTM4jX3eOO2TFgQEcEzGDchAnXtEiRr(05g6oQ4dx3x8APJYa7eo0AIxRwagmFrMpLWK1yVSBblxf7Ka10ywZXgbbwSWggwMbigt(LEwhPjMs9e8U1OWggw6h6K5o7jRLHYdznYNo3yzJC3o(W19fVw6OKDUYO9SostuKOmgP0Ez3cwPmiKC0aYRD2XwUBhLWggwQrttzQ7nkRChlsuuLrXVKA00uM6EJYkX3eOOUfGbZxK5tjmzn2l7wWYvXoD2ABbViiWI1OWggw6h6K5o7jRLHYDS72(zO6j4LA00uM6EJYkpK1iF6mZjsuuLrXVKA00uM6EJYkX3eOOUfGbZxK5tjmzn2l7wWYvXo5POTgbmy(ImFkHjRXEz3cwUk2jmYOFxyeeyXTJQmk(L0trBnkX3eOO2TEkPgX4EWSFDkpK1iFUs0TejQTWggwMBTg)UgTkuEO5lrIe2WWYSMh7HODL8qZxTC3wyddlZaeJj)spRJ0et5owKi)mu9e8YmaXyYV0Z6inXuEiRr(05g2cWG5lY8PeMSg7LDly5QyNyNRmApRJ0eJGalUDuLrXVKEkARrj(Maf1U1tj1ig3dM9Rt5HSg5ZvIULircByyzgGym5x6zDKMyk3XUf2WWYznEXtaEYSmFtXr7UDzu8lP(qt)2EjSK4BcuulsegjBsCmQL25dT1ZN9q0wZup0EDladMViZNsyYASx2TGLRIDkiKC0aYRJGalwJcByyPFOtM7SNSwgk3XagmFrMpLWK1yVSBblxf70SgV4japadMViZNsyYASx2TGLRIDkiKC0aYRbmauagmFrMpLyKr)Uqxf70HVoccS4dznYNRiwVpRiZhPwv2a3Auyddl9dDYCN9K1YqPEcEadMViZNsmYOFxORIDkBUP0mMsQcViiWIpBbxHzw1D72(zO6j4LA00uM6EJYkpK1iF6CdChLWggwQrttzQ7nkRCh3sKOOkJIFj1OPPm19gLvIVjqrDladMViZNsmYOFxORIDsJMMYu3Bu2iiWI9Zq1tWlfOMgZAow5HSg5tNzo3TB7NHQNGx6h6K5o7jRLHYdznYNReTirTlJIFjdSt4qRjEs8nbkQD7NHQNGxgyNWHwt8KhYAKpxj6wTejQngjBsCmQLbizjS6dCVcXoAxf62pdvpbVmeVH47u0ILhYAKpxj6wTamy(ImFkXiJ(DHUk2j)qNm3zpzTmmccSyHnmS0p0jZD2twldL6j4bmy(ImFkXiJ(DHUk2Pa7eo0AIxeeyXcByyPFOtM7SNSwgk1tWdyW8fz(uIrg97cDvStH4neFNIwCeeyXyKSjXXOwgGKLWQpW9ke7ODvOBnkSHHL(HozUZEYAzOupbV72T9Zq1tWl9dDYCN9K1Yq5HSg5tNBO7OIpCDFXRLok9dDYCN9K1YWwIe1Umk(LmWoHdTM4jX3eOO2TFgQEcEzGDchAnXtEiRr(05g6oQ4dx3x8APJYa7eo0AIxRwagmFrMpLyKr)Uqxf7Ka10ywZXgbbwSgf2WWs)qNm3zpzTmuEiRr(05glBK7ZwWvyMvD3okHnmSuJMMYu3Buw5owKOOkJIFj1OPPm19gLvIVjqrDladMViZNsmYOFxORID6S12cErqGfRrHnmS0p0jZD2twldL7y3T9Zq1tWl1OPPm19gLvEiRr(0zMtKOOkJIFj1OPPm19gLvIVjqrDladMViZNsmYOFxORIDYtrBngbbwCgJuAVSBbRugesoAa51ohnGbZxK5tjgz0Vl0vXoXoxz0EwhPjgbbwSWggwoRXlEcWtML5BkoA3TlJIFj1hA632lHLeFtGIArIWiztIJrT0oFOTE(ShI2AM6H2RBbyW8fz(uIrg97cDvStZA8INa8amy(ImFkXiJ(DHUk2jmYOFxyeeyXNTGolUXRksKgf2WWs)qNm3zpzTmuUJfjsyddlZTwJFxJwfkp08LircByyzwZJ9q0UsEO5ladafGbZxK5tzs(fk2l7wWYvXoD4RJGal(qwJ85kI17ZkY8rQvLnWTgf2WWs)qNm3zpzTmuQNGhWG5lY8Pmj)cf7LDly5QyNYMBknJPKQWlccS4ZwWvyMvD32pdvpbVuJMMYu3Buw5HSg5tNBGirrvgf)sQrttzQ7nkReFtGI6wagmFrMpLj5xOyVSBblxf7KgnnLPU3OSrqGf7NHQNGxkqnnM1CSYdznYNoZCUB32pdvpbV0p0jZD2twldLhYAKpxjArIAxgf)sgyNWHwt8K4Bcuu72pdvpbVmWoHdTM4jpK1iFUs0TAjsuBms2K4yuldqYsy1h4EfID0Uk0TFgQEcEziEdX3POflpK1iFUs0TAbyW8fz(uMKFHI9YUfSCvSt(HozUZEYAzyeeyXcByyPFOtM7SNSwgk1tWdyW8fz(uMKFHI9YUfSCvStb2jCO1eViiWIf2WWs)qNm3zpzTmuQNGhWG5lY8Pmj)cf7LDly5QyNcXBi(ofT4iiWIXiztIJrTmajlHvFG7vi2r7Qq3Auyddl9dDYCN9K1YqPEcE3TB7NHQNGx6h6K5o7jRLHYdznYNo3q3rfF46(IxlDu6h6K5o7jRLHTejQDzu8lzGDchAnXtIVjqrTB)mu9e8Ya7eo0AIN8qwJ8PZn0DuXhUUV41shLb2jCO1eVwTamy(ImFktYVqXEz3cwUk2jmYOFxyeeyXcByyzU1A87A0Qq5HMVejsyddlZAEShI2vYdnFbyW8fz(uMKFHI9YUfSCvStcutJznhBeeyXcByyzgGym5x6zDKMyk1tW7wJcByyPFOtM7SNSwgkpK1iF6CJLnYD74dx3x8APJs25kJ2Z6inrrIYyKs7LDlyLYGqYrdiV2zhB5UDucByyPgnnLPU3OSYDSirrvgf)sQrttzQ7nkReFtGI6wagmFrMpLj5xOyVSBblxf70zRTf8IGalwJcByyPFOtM7SNSwgk3XUB7NHQNGxQrttzQ7nkR8qwJ8PZmNirrvgf)sQrttzQ7nkReFtGI6wagmFrMpLj5xOyVSBblxf7KNI2AmccS4mgP0Ez3cwPmiKC0aYRDoAadMViZNYK8luSx2TGLRIDIDUYO9SosteWG5lY8Pmj)cf7LDly5QyNM14fpb4byW8fz(uMKFHI9YUfSCvStbHKJgqEDeeyXLrXVKW4TEU(a3fSQOOeFtGIA3TpBbDwCJwvKinkSHHL(HozUZEYAzOCh3cWG5lY8Pmj)cf7LDly5QyNsQXgbbwCuLrXVKW4TEU(a3fSQOOeFtGIA3TpBbDwCJxvKinkSHHL(HozUZEYAzOCh3IdLXON7aZ4iV4fNd]] )
end
