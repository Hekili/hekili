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

            usable = function () return ( equipped.weight_of_the_earth or target.distance > 10 ) and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd * 2 ) end,
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
            
            recheck = function () return rage.time_to_30, rage.time_to_40 end,
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

    spec:RegisterPack( "Arms", 20180721.2151, [[diKXXaqiHupcKQYMOQmkHYPeQwfivXROQQzjfClqQQ2fk)Iq1Wur6yeslti8mPqnnveUMuiBdKIVbsPXje5CQiI1PIiX8esUhvX(Ok1bbPkTqQsEOkIsxufrLrQIiPtQIOyLeIDsOmuveP6PaMki5RQiszVi9xPAWu5WuwmqpMutMKldTzq9zvy0c60eTAvev9APOzJ42eSBv9BfdxkDCqQSCLEUOPl56Q02vr9DbgVquNNQkZhe7hvtfLcffqzfsflItfnsNcTriklcrB0PrCsOaLFTifO10nTdKc8MasbGExHKc0A(rgtrHIcKZD1ifiSQ28KI4IFiRWlitpcINsHlXk5861GlXtPGwCqYakoiSb9RWZI3UdSKGP4qjXncrfhQieTFsZ2voBh6Dfswkf0uaWRKuNmpfKcOScPIfXPIgPtH2ieLfHOn60iOa2TcNLcaifozPakm1uaOcLj3jtURcrUtHW2LuCh07kKCxRPBAhi3bpl3DsfBkjsg3XDNmf3fyj3jfANTqf3bVJa3bifUeRKZFYUgC1a3fiRqU7K(vqajCNPuOI7QH7KFH7EBlUlieFU7ruHkgfGiZkPqrbs5FqWEz7bwuOOIjkfkka(gibvuVOa6vw4knkWIcM8tUlkpCN6UwjNN7GE4UtznM78XDke8cdZ0dzY8M9uWYqMAcEkGPl58uGfFfTOIfbfkka(gibvuVOa6vw4knkWAhi3ff3bTNYD(4UyCNEgIAcEMcnfXVU2icSffm5NCN3CxJ5oiq4UO5UYi4xmfAkIFDTrey4BGeuXDXPaMUKZtbYMxcjBjYQWLwuXAmfkka(gibvuVOa6vw4knkGEgIAcEgiXuywZkWwuWKFYDEZDqd35J7IXDX4o9me1e8m9qMmVzpfSmKTOGj)K7II7IG7GaH7IXDLrWVyb2cUO1exg(gibvCNpUtpdrnbplWwWfTM4YwuWKFYDrXDrWDX5U4CheiCxmUdHURSTfvSauEew9bUxHyhTTc5oFCNEgIAcEwiUJu3jO1YwuWKFYDrXDrWDX5U4uatxY5Pak0ue)6AJiqlQyNGcffaFdKGkQxua9klCLgfqHGxyyMEitM3SNcwgYutWtbmDjNNcOhYK5n7PGLH0IkwJOqrbW3ajOI6ffqVYcxPrbui4fgMPhYK5n7PGLHm1e8uatxY5Pab2cUO1exArfdAOqrbW3ajOI6ffqVYcxPrbqO7kBBrflaLhHvFG7vi2rBRqUZh3PqWlmmtpKjZB2tbldzQj45oFCxmUlg3PNHOMGNPhYK5n7PGLHSffm5NCN3CxK4oFCx0Cx7IN7hAftuMEitM3SNcwgYDX5oiq4UyCxze8lwGTGlAnXLHVbsqf35J70ZqutWZcSfCrRjUSffm5NCN3CxK4oFCx0Cx7IN7hAftuwGTGlAnXL7IZDXPaMUKZtbcXDK6obTwArfdAPqrbW3ajOI6ffqVYcxPrbaVWWS8Qu43vOvHSfnDXDqGWDGxyywwZJ9q02ITOPlkGPl58uamYO(wiTOIfjkuua8nqcQOErb0RSWvAuaWlmmldqSv(h9SwztmzQj45oFCNcbVWWm9qMmVzpfSmKTOGj)K78M7obRrCNpUlg31U45(HwXeLjmBzKEwRSjYDqGWDzlsi9Y2dSswqOCjbYxXDEZDIYDX5oFCxmUlAUd8cdZuOPi(11grGDB5oiq4UO5UYi4xmfAkIFDTrey4BGeuXDXPaMUKZtbajMcZAwbArf7KqHIcGVbsqf1lkGELfUsJcOqWlmmtpKjZB2tbldz3wUZh3fJ70ZqutWZuOPi(11grGTOGj)K78M7GgUdceUlAURmc(ftHMI4xxBebg(gibvCxCkGPl58uG1oBh4slQyIEkfkkGPl58uaHzlJ0ZALnrka(gibvuVOfvmrfLcffW0LCEkWCg32jaxka(gibvuVOfvmrJGcffaFdKGkQxua9klCLgfOmc(fdg3ZZ2h4oOvfbz4BGeuXD(4UyC3Ahi35ThURrNYDqGWDke8cdZ0dzY8M9uWYq2TL7ItbmDjNNceekxsG8v0IkMOnMcffaFdKGkQxua9klCLgfiAURmc(fdg3ZZ2h4oOvfbz4BGeuXD(4UyC3Ahi35ThU7eNYDqGWDke8cdZ0dzY8M9uWYq2TL7ItbmDjNNcKetGw0IcOqy7skkuuXeLcffW0LCEkGo02dKcGVbsqf1lArflckuuatxY5PaTxbbKqbW3ajOI6fTOI1ykuuatxY5Pa2TMUvLPBsbW3ajOI6fTOIDckuuatxY5PaTtjNNcGVbsqf1lArfRruOOa4BGeur9IcOxzHR0Oake8cdZ0dzY8M9uWYq2TLcy6sopfaKmJQdFx)OfvmOHcffaFdKGkQxua9klCLgfqHGxyyMEitM3SNcwgYUTuatxY5PaG4M42u(h0Ikg0sHIcGVbsqf1lkGELfUsJcOqWlmmtpKjZB2tbldzQj45oFCNEgIAcEMWSLr6zTYMiBrbt(j35n3jkRrCNpUBTdK7II7A0PuatxY5Pa2QTh71Sl(fTOIfjkuua8nqcQOErb0RSWvAuafcEHHz6HmzEZEkyzitnbpfW0LCEkarEewz)K)QoeWVOfvStcfkka(gibvuVOa6vw4knkGEgIAcEMEitM3SNcwgYwuWKFYDrXDrI7GaH7IXDLrWVyb2cUO1exg(gibvCNpUtpdrnbplWwWfTM4YwuWKFYDrXDrI7ItbmDjNNcyNTYwArft0tPqrbW3ajOI6ffqVYcxPrbYwKq6LThyLSGq5scKVI78M7eLcy6sopfidqSv(h9SwztmPfvmrfLcffaFdKGkQxua9klCLgfiBrcPx2EGvYccLljq(kUZBU7euatxY5Pa797MUKZ3jYSOaezw93eqkaS8m2lBpWIwuXenckuua8nqcQOErb0RSWvAuGyCxze8lMGLPPxKHVbsqf35J7kBpWIfIgPczT6I7II7ACJ4U4CheiCxz7bwSq0iviRvxCxuCxeNsbmDjNNcS3VB6soFNiZIcqKz1FtaPayKr9TqArft0gtHIcGVbsqf1lkGPl58uG9(DtxY57ezwuaImR(BcifiL)bb7LThyrlArbAxupcGwrHIkMOuOOa4BGeur9IwuXIGcffaFdKGkQx0IkwJPqrbW3ajOI6fTOIDckuua8nqcQOErlQynIcffW0LCEkaOvfb7z4Clka(gibvuVOfvmOHcffW0LCEkq7uY5Pa4BGeur9Iw0IcGrg13cPqrftukuua8nqcQOErb0RSWvAuGffm5NCxuE4o1DTsop3b9WDNYAm35J7ui4fgMPhYK5n7PGLHm1e8uatxY5Pal(kArflckuua8nqcQOErb0RSWvAuG1oqUlkUdApL78XDX4UyCNEgIAcEMcnfXVU2icSffm5NCN3CxJ5oFCx0Ch4fgMPqtr8RRnIa72YDX5oiq4UO5UYi4xmfAkIFDTrey4BGeuXDXPaMUKZtbYMxcjBjYQWLwuXAmfkka(gibvuVOa6vw4knkGEgIAcEgiXuywZkWwuWKFYDEZDqd35J7IXDX4o9me1e8m9qMmVzpfSmKTOGj)K7II7IG7GaH7IXDLrWVyb2cUO1exg(gibvCNpUtpdrnbplWwWfTM4YwuWKFYDrXDrWDX5U4CheiCxmUdHURSTfvSauEew9bUxHyhTTc5oFCNEgIAcEwiUJu3jO1YwuWKFYDrXDrWDX5U4uatxY5Pak0ue)6AJiqlQyNGcffaFdKGkQxua9klCLgfqHGxyyMEitM3SNcwgYutWtbmDjNNcOhYK5n7PGLH0IkwJOqrbW3ajOI6ffqVYcxPrbui4fgMPhYK5n7PGLHm1e8uatxY5Pab2cUO1exArfdAOqrbW3ajOI6ffqVYcxPrbqO7kBBrflaLhHvFG7vi2rBRqUZh3PqWlmmtpKjZB2tbldzQj45oFCxmUlg3PNHOMGNPhYK5n7PGLHSffm5NCN3CxK4oFCx0Cx7IN7hAftuMEitM3SNcwgYDX5oiq4UyCxze8lwGTGlAnXLHVbsqf35J70ZqutWZcSfCrRjUSffm5NCN3CxK4oFCx0Cx7IN7hAftuwGTGlAnXL7IZDXPaMUKZtbcXDK6obTwArfdAPqrbW3ajOI6ffqVYcxPrbui4fgMPhYK5n7PGLHSffm5NCN3C3jynI78XDRDGCxuCh0Ek35J7IXDrZDGxyyMcnfXVU2icSBl3bbc3fn3vgb)IPqtr8RRnIadFdKGkUlofW0LCEkaiXuywZkqlQyrIcffaFdKGkQxua9klCLgfqHGxyyMEitM3SNcwgYUTCNpUlg3PNHOMGNPqtr8RRnIaBrbt(j35n3bnCheiCx0Cxze8lMcnfXVU2icm8nqcQ4U4uatxY5PaRD2oWLwuXojuOOa4BGeur9IcOxzHR0OaGxyy2Cg32jaxwwMUj35H7IG78XDX4UYi4xm1IM6T7ryXW3ajOI7GaH7qO7kBBrfZwDODE(ShI2z)6H2R4U4uatxY5PacZwgPN1kBI0IkMONsHIcy6sopfyoJB7eGlfaFdKGkQx0IkMOIsHIcGVbsqf1lkGELfUsJcS2bYDE7H7oXPCheiCNcbVWWm9qMmVzpfSmKDB5oiq4oWlmmlVkf(DfAviBrtxCheiCh4fgML18ypeTTylA6Icy6sopfaJmQVfslArbGLNXEz7bwuOOIjkfkka(gibvuVOa6vw4knkWAhi3ff3bTNYD(4UyCNEgIAcEMcnfXVU2icSffm5NCN3CxJ5oiq4UO5UYi4xmfAkIFDTrey4BGeuXDXPaMUKZtbYMxcjBjYQWLwuXIGcffaFdKGkQxua9klCLgfqpdrnbpdKykmRzfylkyYp5oV5oOH78XDX4UyCNEgIAcEMEitM3SNcwgYwuWKFYDrXDrWDqGWDX4UYi4xSaBbx0AIldFdKGkUZh3PNHOMGNfyl4IwtCzlkyYp5UO4Ui4U4CxCUdceUlg3Hq3v22IkwakpcR(a3RqSJ2wHCNpUtpdrnbple3rQ7e0AzlkyYp5UO4Ui4U4CxCkGPl58uafAkIFDTreOfvSgtHIcGVbsqf1lkGELfUsJcOqWlmmtpKjZB2tbldzQj4PaMUKZtb0dzY8M9uWYqArf7euOOa4BGeur9IcOxzHR0Oake8cdZ0dzY8M9uWYqMAcEkGPl58uGaBbx0AIlTOI1ikuua8nqcQOErb0RSWvAuae6UY2wuXcq5ry1h4EfID02kK78XDke8cdZ0dzY8M9uWYqMAcEUZh3fJ7IXD6ziQj4z6HmzEZEkyziBrbt(j35n3fjUZh3fn31U45(HwXeLPhYK5n7PGLHCxCUdceUlg3vgb)Ifyl4IwtCz4BGeuXD(4o9me1e8SaBbx0AIlBrbt(j35n3fjUZh3fn31U45(HwXeLfyl4IwtC5U4CxCkGPl58uGqChPUtqRLwuXGgkuua8nqcQOErb0RSWvAuaWlmmldqSv(h9SwztmzQj45oFCNcbVWWm9qMmVzpfSmKTOGj)K78M7obRrCNpUlg31U45(HwXeLjmBzKEwRSjYDqGWDzlsi9Y2dSswqOCjbYxXDEZDIYDX5oFCxmUlAUd8cdZuOPi(11grGDB5oiq4UO5UYi4xmfAkIFDTrey4BGeuXDXPaMUKZtbajMcZAwbArfdAPqrbW3ajOI6ffqVYcxPrbui4fgMPhYK5n7PGLHSBl35J7IXD6ziQj4zk0ue)6AJiWwuWKFYDEZDqd3bbc3fn3vgb)IPqtr8RRnIadFdKGkUlofW0LCEkWANTdCPfvSirHIcGVbsqf1lkGELfUsJceJ7IM7kJGFX0e0oJm8nqcQ4oFCNAkMcX2EWCFvYwuWKFYDrXDrWDX5oiq4UyCh4fgMLxLc)UcTkKTOPlUdceUd8cdZYAEShI2wSfnDXDX5oFCxmUd8cdZYaeBL)rpRv2et2TL7GaH70ZqutWZYaeBL)rpRv2et2IcM8tUZBUlsCxCkGPl58uamYO(wiTOIDsOqrbW3ajOI6ffqVYcxPrbIXDrZDLrWVyAcANrg(gibvCNpUtnftHyBpyUVkzlkyYp5UO4Ui4U4CheiCh4fgMLbi2k)JEwRSjMSBl35J7aVWWS5mUTtaUSSmDtUZd3fb35J7IXDLrWVyQfn1B3JWIHVbsqf3bbc3Hq3v22IkMT6q788zpeTZ(1dTxXDXPaMUKZtbeMTmspRv2ePfvmrpLcffaFdKGkQxua9klCLgfqHGxyyMEitM3SNcwgYUTuatxY5PabHYLeiFfTOIjQOuOOaMUKZtbMZ42ob4sbW3ajOI6fTOIjAeuOOaMUKZtbccLljq(kka(gibvuVOfTOff4mUPCEQyrCQOr6uOncrzri6jAefiW2x(hjfGc0UdSKGuaOpU7KlYO(wOI7ar4zrUtpcGwXDG4H8tg3b9Q1yBLC3pp0FOTcWxc3z6soFYDZt8JXfX0LC(K1UOEeaTYdmXYMCrmDjNpzTlQhbqR83J4WZO4Iy6soFYAxupcGw5VhXT7Ha(LvY55Ia9XDaV1MHtXDRjvCh4fggvCxwwLChicplYD6ra0kUdepKFYD2R4U2fH(BNQK)b3jtUtnpY4Iy6soFYAxupcGw5VhXZ3AZWP6zzvYfX0LC(K1UOEeaTYFpIdAvrWEgo3IlIPl58jRDr9iaAL)EeVDk58Cr4Ia9XDNCrg13cvChEgx)4UskGCxfICNPRz5ozYD2ztsmqcY4Iy6soF6rhA7bYfX0LC(0FpI3EfeqcxetxY5t)9iUDRPBvz6MCrmDjNp93J4TtjNNlIPl58P)EehKmJQdFx)Aqc7rHGxyyMEitM3SNcwgYUTCrmDjNp93J4G4M42u(hniH9OqWlmmtpKjZB2tbldz3wUiMUKZN(7rCB12J9A2f)QbjShfcEHHz6HmzEZEkyzitnbVp9me1e8mHzlJ0ZALnr2IcM8tVfL1iFRDGr1Ot5Iy6soF6VhXjYJWk7N8x1Ha(vdsypke8cdZ0dzY8M9uWYqMAcEUiMUKZN(7rC7Sv22Ge2JEgIAcEMEitM3SNcwgYwuWKFgvKGajwze8lwGTGlAnXLHVbsqLp9me1e8SaBbx0AIlBrbt(zurkoxetxY5t)9iEgGyR8p6zTYMy2Ge2t2IesVS9aRKfekxsG8vElkxetxY5t)9i(E)UPl58DImRgEta9alpJ9Y2dSAqc7jBrcPx2EGvYccLljq(kVpbxetxY5t)9i(E)UPl58DImRgEta9Grg13cBqc7jwze8lMGLPPxKHVbsqLVY2dSyHOrQqwRUIQXnkoeiLThyXcrJuHSwDfveNYfX0LC(0FpIV3VB6soFNiZQH3eqpP8piyVS9alUiCrmDjNpzyKr9Tqpl(QgKWEwuWKFgLh1DTsop0ZPSg7tHGxyyMEitM3SNcwgYutWZfX0LC(KHrg13c93J4zZlHKTezv42Ge2ZAhyuq7P(IftpdrnbptHMI4xxBeb2IcM8tVBSVObVWWmfAkIFDTrey324qGeDze8lMcnfXVU2icm8nqcQIZfX0LC(KHrg13c93J4k0ue)6AJi0Ge2JEgIAcEgiXuywZkWwuWKF6n04lwm9me1e8m9qMmVzpfSmKTOGj)mQiGajwze8lwGTGlAnXLHVbsqLp9me1e8SaBbx0AIlBrbt(zurepoeiXqO7kBBrflaLhHvFG7vi2rBRqF6ziQj4zH4osDNGwlBrbt(zurepoxetxY5tggzuFl0FpIRhYK5n7PGLHniH9OqWlmmtpKjZB2tbldzQj45Iy6soFYWiJ6BH(7r8aBbx0AIBdsypke8cdZ0dzY8M9uWYqMAcEUiMUKZNmmYO(wO)Eepe3rQ7e0ABqc7bHURSTfvSauEew9bUxHyhTTc9PqWlmmtpKjZB2tbldzQj49flMEgIAcEMEitM3SNcwgYwuWKF6DK8fD7IN7hAftuMEitM3SNcwgghcKyLrWVyb2cUO1exg(gibv(0ZqutWZcSfCrRjUSffm5NEhjFr3U45(HwXeLfyl4IwtCJhNlIPl58jdJmQVf6VhXbjMcZAwHgKWEui4fgMPhYK5n7PGLHSffm5NEFcwJ8T2bgf0EQVyrdEHHzk0ue)6AJiWUTqGeDze8lMcnfXVU2icm8nqcQIZfX0LC(KHrg13c93J4RD2oWTbjShfcEHHz6HmzEZEkyzi726lMEgIAcEMcnfXVU2icSffm5NEdnqGeDze8lMcnfXVU2icm8nqcQIZfX0LC(KHrg13c93J4cZwgPN1kBIniH9aEHHzZzCBNaCzzz6MEIWxSYi4xm1IM6T7ryXW3ajOccee6UY2wuXSvhANNp7HOD2VEO9Q4CrmDjNpzyKr9Tq)9i(Cg32jaxUiMUKZNmmYO(wO)EehJmQVf2Ge2ZAhO3EoXPqGOqWlmmtpKjZB2tbldz3wiqaVWWS8Qu43vOvHSfnDbbc4fgML18ypeTTylA6IlcxetxY5tgS8m2lBpWYt28sizlrwfUniH9S2bgf0EQVy6ziQj4zk0ue)6AJiWwuWKF6DJHaj6Yi4xmfAkIFDTrey4BGeufNlIPl58jdwEg7LThy5VhXvOPi(11grObjSh9me1e8mqIPWSMvGTOGj)0BOXxSy6ziQj4z6HmzEZEkyziBrbt(zurabsSYi4xSaBbx0AIldFdKGkF6ziQj4zb2cUO1ex2IcM8ZOIiECiqIHq3v22IkwakpcR(a3RqSJ2wH(0ZqutWZcXDK6obTw2IcM8ZOIiECUiMUKZNmy5zSx2EGL)EexpKjZB2tbldBqc7rHGxyyMEitM3SNcwgYutWZfX0LC(KblpJ9Y2dS83J4b2cUO1e3gKWEui4fgMPhYK5n7PGLHm1e8CrmDjNpzWYZyVS9al)9iEiUJu3jO12Ge2dcDxzBlQybO8iS6dCVcXoABf6tHGxyyMEitM3SNcwgYutW7lwm9me1e8m9qMmVzpfSmKTOGj)07i5l62fp3p0kMOm9qMmVzpfSmmoeiXkJGFXcSfCrRjUm8nqcQ8PNHOMGNfyl4IwtCzlkyYp9os(IUDXZ9dTIjklWwWfTM4gpoxetxY5tgS8m2lBpWYFpIdsmfM1ScniH9aEHHzzaITY)ON1kBIjtnbVpfcEHHz6HmzEZEkyziBrbt(P3NG1iFXAx8C)qRyIYeMTmspRv2eHajBrcPx2EGvYccLljq(kVfnUVyrdEHHzk0ue)6AJiWUTqGeDze8lMcnfXVU2icm8nqcQIZfX0LC(KblpJ9Y2dS83J4RD2oWTbjShfcEHHz6HmzEZEkyzi726lMEgIAcEMcnfXVU2icSffm5NEdnqGeDze8lMcnfXVU2icm8nqcQIZfX0LC(KblpJ9Y2dS83J4yKr9TWgKWEIfDze8lMMG2zKHVbsqLp1umfIT9G5(QKTOGj)mQiIdbsmWlmmlVkf(DfAviBrtxqGaEHHzznp2drBl2IMUI7lg4fgMLbi2k)JEwRSjMSBlei6ziQj4zzaITY)ON1kBIjBrbt(P3rkoxetxY5tgS8m2lBpWYFpIlmBzKEwRSj2Ge2tSOlJGFX0e0oJm8nqcQ8PMIPqSThm3xLSffm5NrfrCiqaVWWSmaXw5F0ZALnXKDB9bEHHzZzCBNaCzzz6MEIWxSYi4xm1IM6T7ryXW3ajOccee6UY2wuXSvhANNp7HOD2VEO9Q4CrmDjNpzWYZyVS9al)9iEqOCjbYx1Ge2JcbVWWm9qMmVzpfSmKDB5Iy6soFYGLNXEz7bw(7r85mUTtaUCrmDjNpzWYZyVS9al)9iEqOCjbYxXfHlIPl58jlL)bb7LThy5zXx1Ge2ZIcM8ZO8OURvY5HEoL1yFke8cdZ0dzY8M9uWYqMAcEUiMUKZNSu(heSx2EGL)EepBEjKSLiRc3gKWEw7aJcAp1xm9me1e8mfAkIFDTreylkyYp9UXqGeDze8lMcnfXVU2icm8nqcQIZfX0LC(KLY)GG9Y2dS83J4k0ue)6AJi0Ge2JEgIAcEgiXuywZkWwuWKF6n04lwm9me1e8m9qMmVzpfSmKTOGj)mQiGajwze8lwGTGlAnXLHVbsqLp9me1e8SaBbx0AIlBrbt(zurepoeiXqO7kBBrflaLhHvFG7vi2rBRqF6ziQj4zH4osDNGwlBrbt(zurepoxetxY5twk)dc2lBpWYFpIRhYK5n7PGLHniH9OqWlmmtpKjZB2tbldzQj45Iy6soFYs5FqWEz7bw(7r8aBbx0AIBdsypke8cdZ0dzY8M9uWYqMAcEUiMUKZNSu(heSx2EGL)Eepe3rQ7e0ABqc7bHURSTfvSauEew9bUxHyhTTc9PqWlmmtpKjZB2tbldzQj49flMEgIAcEMEitM3SNcwgYwuWKF6DK8fD7IN7hAftuMEitM3SNcwgghcKyLrWVyb2cUO1exg(gibv(0ZqutWZcSfCrRjUSffm5NEhjFr3U45(HwXeLfyl4IwtCJhNlIPl58jlL)bb7LThy5VhXXiJ6BHniH9aEHHz5vPWVRqRczlA6cceWlmmlR5XEiABXw00fxetxY5twk)dc2lBpWYFpIdsmfM1ScniH9aEHHzzaITY)ON1kBIjtnbVpfcEHHz6HmzEZEkyziBrbt(P3NG1iFXAx8C)qRyIYeMTmspRv2eHajBrcPx2EGvYccLljq(kVfnUVyrdEHHzk0ue)6AJiWUTqGeDze8lMcnfXVU2icm8nqcQIZfX0LC(KLY)GG9Y2dS83J4RD2oWTbjShfcEHHz6HmzEZEkyzi726lMEgIAcEMcnfXVU2icSffm5NEdnqGeDze8lMcnfXVU2icm8nqcQIZfX0LC(KLY)GG9Y2dS83J4cZwgPN1kBICrmDjNpzP8piyVS9al)9i(Cg32jaxUiMUKZNSu(heSx2EGL)EepiuUKa5RAqc7Pmc(fdg3ZZ2h4oOvfbz4BGeu5l2AhO3EA0PqGOqWlmmtpKjZB2tbldz324CrmDjNpzP8piyVS9al)9iEsmHgKWEIUmc(fdg3ZZ2h4oOvfbz4BGeu5l2AhO3EoXPqGOqWlmmtpKjZB2tbldz324uGSf1uXGwrPfTOu]] )
end
