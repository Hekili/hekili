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

        -- Azerite Powers
        crushing_assault = {
            id = 278826,
            duration = 10,
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
            charges = function () return talent.double_time.enabled and 2 or 1 end,
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
            charges = function () return ( level < 116 and equipped.timeless_strategem ) and 3 or 1 end,
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
        damageExpiration = 8,
    
        package = "Arms",
    } )

    
    spec:RegisterPack( "Arms", 20180813.1538, [[dCKz0aqiHIhrvH0MOQ6tefQgLuYPeQwfrHYROQ0SeuDlLqWUi8lIQggrrhJO0YeuEMGuttjORjizBef8nQkyCuv05OQqToQkeZtO09Ok2hvPoOsiAHuL8qIcHlQes1hvcjmsLqIojrH0kvvAMkHKStIkdvjKulvjeYtvLPQQ4QkHq9vLqk7fXFLQbtLdtzXi5XKAYKCzOnJuFwjnAHCAuwnrHOxlLA2GUnr2nWVvmCP44kHA5Q8CrtxY1vQTRe9DbgVsGZliMVQQ9JQjYs(qEkRqICHjtz9Pm9PSHwiBOcTpekFm5vH0GKxJPBBRi5bmjK8wKNusEnwiWXuKpKxo7tJKxuvnPpI8YVYQOnLqpsYNmPn0k2a0NrxYNmjT8uWHsEkABrqHlLV5gAget5)WWlmzL)tyY2x0S7yZ1xKNuksMKM8O2myjJciuKNYkKixyYuwFktFkBOfYgQWKHq5JjpBxrZrEpMKmcYtHPM8(eXsUJLCxfHCNcPTnS4Uf5jLCxJPBBRi3rph3TOeBZGmb3XDYOf3fyj3XKAMRqf3rFJe39ysBOvSbiJ4m6kCUlGvrC3I6TKec5otPqf3vd3XafE3UP4UGieWDaevOsqEqwwj5d5LmWke7LDRyr(qKtwYhYdbgfeveVip9Xk8yg5DOKXaj3fRhUtTpRydG7KX4ozkcn35N7ui1MMwOh4K5o7PKLrc1eaiptxSbqEhcuKIixyKpKhcmkiQiErE6Jv4XmY7SvK7IL78bzYD(5UwCNEgOAcacfAkyiDTbLehkzmqYDEZDHM7()5Uy4UYGiOek0uWq6AdkjqGrbrf3fN8mDXga5LT3qy2azvHhPiYfAYhYdbgfeveVip9Xk8yg5PNbQMaGGcAkmR5KehkzmqYDEZDYa35N7AXDT4o9mq1eae6bozUZEkzzK4qjJbsUlwUlmU7)N7AXDLbrqjcSJ6qRnEceyuquXD(5o9mq1eaeb2rDO1gpXHsgdKCxSCxyCxCUlo39)ZDT4oCXBwtdQebiBnQ6dDVIWoAxfXD(5o9mq1eaer4nmDhIwJ4qjJbsUlwUlmUlo3fN8mDXga5PqtbdPRnOePiYTqYhYdbgfeveVip9Xk8yg5PqQnnTqpWjZD2tjlJeQjaqEMUydG80dCYCN9uYYisrKluKpKhcmkiQiErE6Jv4XmYtHuBAAHEGtM7SNswgjutaG8mDXga5fyh1HwB8ifrozG8H8qGrbrfXlYtFScpMrE4I3SMgujcq2Au1h6EfHD0UkI78ZDkKAttl0dCYCN9uYYiHAcaCNFURf31I70ZavtaqOh4K5o7PKLrIdLmgi5oV5oFYD(5Uy4UMdx2x1kHSc9aNm3zpLSmI7IZD))CxlURmickrGDuhATXtGaJcIkUZp3PNbQMaGiWoQdT24jouYyGK78M78j35N7IH7AoCzFvReYkcSJ6qRnECxCUlo5z6InaYlcVHP7q0AifroFG8H8qGrbrfXlYtFScpMrEuBAArUvke0vOvrIdnDXD))Ch1MMwK1aWEeAxjo00f5z6InaYdxaQ3fskIC(K8H8qGrbrfXlYtFScpMrEuBAArgGyddS2Z6yTXuOMaa35N7ui1MMwOh4K5o7PKLrIdLmgi5oV5Ufkcf35N7AXDnhUSVQvczfsZvgSN1XAJC3)p3Lnie2l7wXkfbrSdgWakUZBUtwUlo35N7AXDXWDuBAAHcnfmKU2GsIDd39)ZDXWDLbrqjuOPGH01gusGaJcIkUlo5z6InaYJcAkmR5KifroFm5d5HaJcIkIxKN(yfEmJ8ui1MMwOh4K5o7PKLrIDd35N7AXD6zGQjaiuOPGH01gusCOKXaj35n3jdC3)p3fd3vgebLqHMcgsxBqjbcmkiQ4U4KNPl2aiVZwAR4rkICYktYhYdbgfeveVip9Xk8yg5Lnie2l7wXkfbrSdgWakUZBUlmYZ0fBaKNgI2sKue5KvwYhYZ0fBaKN0CLb7zDS2i5HaJcIkIxKIiNSHr(qEMUydG8ML41mb4rEiWOGOI4fPiYjBOjFipeyuqur8I80hRWJzKxzqeucA8woxFO7uwvquGaJcIkUZp31I7oBf5oV9WDHsMC3)p3PqQnnTqpWjZD2tjlJe7gUlo5z6InaYliIDWagqrkICYUqYhYdbgfeveVip9Xk8yg5fd3vgebLGgVLZ1h6oLvfefiWOGOI78ZDT4UZwrUZBpC3cLj39)ZDkKAttl0dCYCN9uYYiXUH7ItEMUydG8sOjrksrEkK22WI8HiNSKpKNPl2aipDKDRi5HaJcIkIxKIixyKpKNPl2aiVMTKecjpeyuqur8Iue5cn5d5z6InaYZ210TQmDBYdbgfeveVifrUfs(qEMUydG8AMInaYdbgfeveVifrUqr(qEiWOGOI4f5PpwHhZipfsTPPf6bozUZEkzzKy3qEMUydG8OGZO607lesrKtgiFipeyuqur8I80hRWJzKNcP200c9aNm3zpLSmsSBiptxSbqEu4L41MbwjfroFG8H8qGrbrfXlYtFScpMrEkKAttl0dCYCN9uYYiHAcaCNFUtpdunbaH0CLb7zDS2O4qjJbsUZBUtwrO4o)C3zRi3fl3fkzsEMUydG8StBaSxZDiOifroFs(qEiWOGOI4f5PpwHhZipfsTPPf6bozUZEkzzKqnbaYZ0fBaKhKTgvzxg5wTkHGIue58XKpKhcmkiQiErE6Jv4XmYtHuBAAHEGtM7SNswgj2nKNPl2aipA2HuWzuKIiNSYK8H8qGrbrfXlYtFScpMrEkKAttl0dCYCN9uYYiXUH8mDXga5zanM1zWU2GqsrKtwzjFipeyuqur8I80hRWJzKNEgOAcac9aNm3zpLSmsCOKXaj3fl35tU7)N7AXDLbrqjcSJ6qRnEceyuquXD(5o9mq1eaeb2rDO1gpXHsgdKCxSCNp5U4KNPl2aipBPv2rkICYgg5d5HaJcIkIxKN(yfEmJ8Ygec7LDRyLIGi2bdyaf35n3jl5z6InaYldqSHbw7zDS2yskICYgAYhYdbgfeveViptxSbqE3g0nDXgqhYYI80hRWJzKx2GqyVSBfRueeXoyadO4oV5UfsEqwwDGjHKhnBj2l7wXIue5KDHKpKhcmkiQiErEMUydG8UnOB6InGoKLf5PpwHhZiVwCxzqeucjlttFOabgfevCNFURSBflreAWks0OlUlwUl0HI7IZD))Cxz3kwIi0GvKOrxCxSCxyYK8GSS6atcjpCbOExiPiYjBOiFipeyuqur8I8mDXga5DBq30fBaDillYdYYQdmjK8sgyfI9YUvSifPiVMd1JeLvKpe5KL8H8qGrbrfXlsrKlmYhYdbgfeveVifrUqt(qEiWOGOI4fPiYTqYhYdbgfeveVifrUqr(qEMUydG8AMInaYdbgfeveVifPipCbOExi5drozjFipeyuqur8I80hRWJzK3HsgdKCxSE4o1(SInaUtgJ7KPi0CNFUtHuBAAHEGtM7SNswgjutaG8mDXga5DiqrkICHr(qEiWOGOI4f5PpwHhZiVZwrUlwUZhKj35N7AXDT4o9mq1eaek0uWq6AdkjouYyGK78M7cn35N7IH7O200cfAkyiDTbLe7gUlo39)ZDXWDLbrqjuOPGH01gusGaJcIkUlo5z6InaYlBVHWSbYQcpsrKl0KpKhcmkiQiErE6Jv4XmYtpdunbabf0uywZjjouYyGK78M7KbUZp31I7AXD6zGQjai0dCYCN9uYYiXHsgdKCxSCxyC3)p31I7kdIGseyh1HwB8eiWOGOI78ZD6zGQjaicSJ6qRnEIdLmgi5Uy5UW4U4CxCU7)N7AXD4I3SMgujcq2Au1h6EfHD0UkI78ZD6zGQjaiIWBy6oeTgXHsgdKCxSCxyCxCUlo5z6InaYtHMcgsxBqjsrKBHKpKhcmkiQiErE6Jv4XmYtHuBAAHEGtM7SNswgjutaG8mDXga5Ph4K5o7PKLrKIixOiFipeyuqur8I80hRWJzKNcP200c9aNm3zpLSmsOMaa5z6InaYlWoQdT24rkICYa5d5HaJcIkIxKN(yfEmJ8WfVznnOseGS1OQp09kc7ODve35N7ui1MMwOh4K5o7PKLrc1ea4o)CxlURf3PNbQMaGqpWjZD2tjlJehkzmqYDEZD(K78ZDXWDnhUSVQvczf6bozUZEkzze3fN7()5UwCxzqeuIa7Oo0AJNabgfevCNFUtpdunbarGDuhATXtCOKXaj35n35tUZp3fd31C4Y(QwjKveyh1HwB84U4CxCYZ0fBaKxeEdt3HO1qkIC(a5d5HaJcIkIxKN(yfEmJ8ui1MMwOh4K5o7PKLrIdLmgi5oV5Ufkcf35N7oBf5Uy5oFqMCNFURf3fd3rTPPfk0uWq6Adkj2nC3)p3fd3vgebLqHMcgsxBqjbcmkiQ4U4KNPl2aipkOPWSMtIue58j5d5HaJcIkIxKN(yfEmJ8ui1MMwOh4K5o7PKLrIDd35N7AXD6zGQjaiuOPGH01gusCOKXaj35n3jdC3)p3fd3vgebLqHMcgsxBqjbcmkiQ4U4KNPl2aiVZwAR4rkIC(yYhYdbgfeveVip9Xk8yg5Lnie2l7wXkfbrSdgWakUZBUlmYZ0fBaKNgI2sKue5KvMKpKhcmkiQiErE6Jv4XmYJAttlML41mb4jYY0T5opCxyCNFURf3vgebLqDOPa2EnQeiWOGOI7()5oCXBwtdQe2PJSLdi7rOTmKEKbuCxCYZ0fBaKN0CLb7zDS2iPiYjRSKpKNPl2aiVzjEntaEKhcmkiQiErkICYgg5d5HaJcIkIxKN(yfEmJ8oBf5oV9WDluMC3)p3PqQnnTqpWjZD2tjlJe7gU7)N7O200ICRuiORqRIehA6I7()5oQnnTiRbG9i0UsCOPlYZ0fBaKhUauVlKuKI8OzlXEz3kwKpe5KL8H8qGrbrfXlYtFScpMrENTICxSCNpitUZp31I70ZavtaqOqtbdPRnOK4qjJbsUZBUl0C3)p3fd3vgebLqHMcgsxBqjbcmkiQ4U4KNPl2aiVS9gcZgiRk8ifrUWiFipeyuqur8I80hRWJzKNEgOAcackOPWSMtsCOKXaj35n3jdCNFURf31I70ZavtaqOh4K5o7PKLrIdLmgi5Uy5UW4U)FURf3vgebLiWoQdT24jqGrbrf35N70Zavtaqeyh1HwB8ehkzmqYDXYDHXDX5U4C3)p31I7WfVznnOseGS1OQp09kc7ODve35N70ZavtaqeH3W0DiAnIdLmgi5Uy5UW4U4CxCYZ0fBaKNcnfmKU2GsKIixOjFipeyuqur8I80hRWJzKNcP200c9aNm3zpLSmsOMaa5z6InaYtpWjZD2tjlJifrUfs(qEiWOGOI4f5PpwHhZipfsTPPf6bozUZEkzzKqnbaYZ0fBaKxGDuhATXJue5cf5d5HaJcIkIxKN(yfEmJ8WfVznnOseGS1OQp09kc7ODve35N7ui1MMwOh4K5o7PKLrc1ea4o)CxlURf3PNbQMaGqpWjZD2tjlJehkzmqYDEZD(K78ZDXWDnhUSVQvczf6bozUZEkzze3fN7()5UwCxzqeuIa7Oo0AJNabgfevCNFUtpdunbarGDuhATXtCOKXaj35n35tUZp3fd31C4Y(QwjKveyh1HwB84U4CxCYZ0fBaKxeEdt3HO1qkICYa5d5HaJcIkIxKN(yfEmJ8O200ImaXggyTN1XAJPqnbaUZp3PqQnnTqpWjZD2tjlJehkzmqYDEZDluekUZp31I7AoCzFvReYkKMRmypRJ1g5U)FUlBqiSx2TIvkcIyhmGbuCN3CNSCxCUZp31I7IH7O200cfAkyiDTbLe7gU7)N7IH7kdIGsOqtbdPRnOKabgfevCxCYZ0fBaKhf0uywZjrkIC(a5d5HaJcIkIxKN(yfEmJ8ui1MMwOh4K5o7PKLrIDd35N7AXD6zGQjaiuOPGH01gusCOKXaj35n3jdC3)p3fd3vgebLqHMcgsxBqjbcmkiQ4U4KNPl2aiVZwAR4rkIC(K8H8mDXga5PHOTejpeyuqur8Iue58XKpKhcmkiQiErE6Jv4XmYRf3fd3vgebLqdrBjkqGrbrf35N7utjui20dMnqLIdLmgi5Uy5UW4U4C3)p31I7O200ICRuiORqRIehA6I7()5oQnnTiRbG9i0UsCOPlUlo35N7AXDuBAArgGyddS2Z6yTXuSB4U)FUtpdunbargGyddS2Z6yTXuCOKXaj35n35tUlo5z6InaYdxaQ3fskICYktYhYdbgfeveVip9Xk8yg51I7IH7kdIGsOHOTefiWOGOI78ZDQPekeB6bZgOsXHsgdKCxSCxyCxCU7)N7O200ImaXggyTN1XAJPy3WD(5oQnnTywIxZeGNilt3M78WDHXD(5UwCxzqeuc1HMcy71OsGaJcIkU7)N7WfVznnOsyNoYwoGShH2Yq6rgqXDXjptxSbqEsZvgSN1XAJKIiNSYs(qEiWOGOI4f5PpwHhZipfsTPPf6bozUZEkzzKy3qEMUydG8cIyhmGbuKIiNSHr(qEMUydG8ML41mb4rEiWOGOI4fPiYjBOjFiptxSbqEbrSdgWakYdbgfeveVifPif5TeVKnaICHjtz9Pm9HWKveMSHswYlWoadSMK3I2ICrKCYOYTOWhH74Upri3XKAMR4o654ozCfsBByjJZDhU4n7qf3LJeYD2UgjRqf3PJmWkMc(3fvmaYDH2hH7wedYDtZCfQ4otxSbWDY42UMUvLPBlJl4F5FLrLAMRqf3fkUZ0fBaChKLvk4FjVMBOzqK88r5Uf9fG6DHkUJcPNd5o9irzf3rHRmqk4UfPwJnvYDGbSiezNe9gYDMUydi5UbadrW)A6InGu0COEKOSYdn0Y28VMUydifnhQhjkR81J80ZO4FnDXgqkAoupsuw5Rh5T9QeckRydG)1hL7EaRjJMI7oJP4oQnnnQ4USSk5okKEoK70JeLvChfUYaj3zaf31C4IqZufdSYDSK7udaf8VMUydifnhQhjkR81J8jWAYOP6zzvY)A6InGu0COEKOSYxpY3mfBa8V8V(OC3I(cq9Uqf3HlXleURysi3vri3z6AoUJLCNT0yqJcIc(xtxSbKE0r2TI8VMUydi91J8nBjjeY)A6InG0xpYB7A6wvMUn)RPl2asF9iFZuSbW)A6InG0xpYtbNr1P3xiHZO9OqQnnTqpWjZD2tjlJe7g(xtxSbK(6rEk8s8AZaRHZO9OqQnnTqpWjZD2tjlJe7g(xtxSbK(6rE70ga71ChcQWz0Eui1MMwOh4K5o7PKLrc1ea8RNbQMaGqAUYG9SowBuCOKXaP3YkcL)ZwXydLm5FnDXgq6Rh5HS1Ok7Yi3QvjeuHZO9OqQnnTqpWjZD2tjlJeQjaW)A6InG0xpYtZoKcoJkCgThfsTPPf6bozUZEkzzKy3W)A6InG0xpYBanM1zWU2GWWz0Eui1MMwOh4K5o7PKLrIDd)RPl2asF9iVT0k7cNr7rpdunbaHEGtM7SNswgjouYyGmwF()3QmickrGDuhATXtGaJcIk)6zGQjaicSJ6qRnEIdLmgiJ1NX5FnDXgq6Rh5ZaeByG1EwhRnMHZO9Knie2l7wXkfbrSdgWakVLL)10fBaPVEK)2GUPl2a6qwwHdmj0dnBj2l7wXkCgTNSbHWEz3kwPiiIDWagq59c5FnDXgq6Rh5VnOB6InGoKLv4atc9Gla17cdNr7PvzqeucjlttFOabgfev(l7wXseHgSIen6k2qhQ4))LDRyjIqdwrIgDfByYK)10fBaPVEK)2GUPl2a6qwwHdmj0tYaRqSx2TIf)l)RPl2asbUauVl0ZHav4mAphkzmqgRh1(SInazmzkcTFfsTPPf6bozUZEkzzKqnba(xtxSbKcCbOExOVEKpBVHWSbYQcVWz0EoBfJ1hKP)wT0ZavtaqOqtbdPRnOK4qjJbsVdT)yO200cfAkyiDTbLe7M4))XugebLqHMcgsxBqjbcmkiQIZ)A6InGuGla17c91J8k0uWq6AdkfoJ2JEgOAcackOPWSMtsCOKXaP3YG)wT0ZavtaqOh4K5o7PKLrIdLmgiJnS))wLbrqjcSJ6qRnEceyuqu5xpdunbarGDuhATXtCOKXazSHfp()FlCXBwtdQebiBnQ6dDVIWoAxf5xpdunbareEdt3HO1iouYyGm2WIhN)10fBaPaxaQ3f6Rh51dCYCN9uYYOWz0Eui1MMwOh4K5o7PKLrc1ea4FnDXgqkWfG6DH(6r(a7Oo0AJx4mApkKAttl0dCYCN9uYYiHAca8VMUydif4cq9UqF9iFeEdt3HO1eoJ2dU4nRPbvIaKTgv9HUxryhTRI8RqQnnTqpWjZD2tjlJeQja4Vvl9mq1eae6bozUZEkzzK4qjJbsV9P)yAoCzFvReYk0dCYCN9uYYO4))TkdIGseyh1HwB8eiWOGOYVEgOAcaIa7Oo0AJN4qjJbsV9P)yAoCzFvReYkcSJ6qRnEXJZ)A6InGuGla17c91J8uqtHznNu4mApkKAttl0dCYCN9uYYiXHsgdKEVqrO8F2kgRpit)TIHAttluOPGH01gusSB()JPmickHcnfmKU2GsceyuqufN)10fBaPaxaQ3f6Rh5pBPTIx4mApkKAttl0dCYCN9uYYiXUXFl9mq1eaek0uWq6AdkjouYyG0Bz4)pMYGiOek0uWq6AdkjqGrbrvC(xtxSbKcCbOExOVEKxdrBjgoJ2t2GqyVSBfRueeXoyadO8om(xtxSbKcCbOExOVEKxAUYG9SowBmCgThQnnTywIxZeGNilt32ty(BvgebLqDOPa2EnQeiWOGO6)hx8M10GkHD6iB5aYEeAldPhzavC(xtxSbKcCbOExOVEKFwIxZeGh)RPl2asbUauVl0xpYJla17cdNr75Sv0BpluM))kKAttl0dCYCN9uYYiXU5)NAttlYTsHGUcTksCOPR)FQnnTiRbG9i0UsCOPl(x(xtxSbKcA2sSx2TILNS9gcZgiRk8cNr75SvmwFqM(BPNbQMaGqHMcgsxBqjXHsgdKEh6))ykdIGsOqtbdPRnOKabgfevX5FnDXgqkOzlXEz3kw(6rEfAkyiDTbLcNr7rpdunbabf0uywZjjouYyG0BzWFRw6zGQjai0dCYCN9uYYiXHsgdKXg2)FRYGiOeb2rDO1gpbcmkiQ8RNbQMaGiWoQdT24jouYyGm2WIh))VfU4nRPbvIaKTgv9HUxryhTRI8RNbQMaGicVHP7q0AehkzmqgByXJZ)A6InGuqZwI9YUvS81J86bozUZEkzzu4mApkKAttl0dCYCN9uYYiHAca8VMUydif0SLyVSBflF9iFGDuhATXlCgThfsTPPf6bozUZEkzzKqnba(xtxSbKcA2sSx2TILVEKpcVHP7q0AcNr7bx8M10GkraYwJQ(q3RiSJ2vr(vi1MMwOh4K5o7PKLrc1ea83QLEgOAcac9aNm3zpLSmsCOKXaP3(0FmnhUSVQvczf6bozUZEkzzu8))wLbrqjcSJ6qRnEceyuqu5xpdunbarGDuhATXtCOKXaP3(0FmnhUSVQvczfb2rDO1gV4X5FnDXgqkOzlXEz3kw(6rEkOPWSMtkCgThQnnTidqSHbw7zDS2ykutaWVcP200c9aNm3zpLSmsCOKXaP3luek)TAoCzFvReYkKMRmypRJ1g))Zgec7LDRyLIGi2bdyaL3Yg3FRyO200cfAkyiDTbLe7M))ykdIGsOqtbdPRnOKabgfevX5FnDXgqkOzlXEz3kw(6r(ZwAR4foJ2JcP200c9aNm3zpLSmsSB83spdunbaHcnfmKU2GsIdLmgi9wg()JPmickHcnfmKU2GsceyuqufN)10fBaPGMTe7LDRy5Rh51q0wI8VMUydif0SLyVSBflF9ipUauVlmCgTNwXugebLqdrBjkqGrbrLF1ucfIn9GzduP4qjJbYydl()FlQnnTi3kfc6k0QiXHMU()P200ISga2Jq7kXHMUI7Vf1MMwKbi2WaR9SowBmf7M)F9mq1eaezaInmWApRJ1gtXHsgdKE7Z48VMUydif0SLyVSBflF9iV0CLb7zDS2y4mApTIPmickHgI2suGaJcIk)QPekeB6bZgOsXHsgdKXgw8)FQnnTidqSHbw7zDS2yk2n(P200IzjEntaEISmDBpH5Vvzqeuc1HMcy71OsGaJcIQ)FCXBwtdQe2PJSLdi7rOTmKEKbuX5FnDXgqkOzlXEz3kw(6r(Gi2bdyav4mApkKAttl0dCYCN9uYYiXUH)10fBaPGMTe7LDRy5Rh5NL41mb4X)A6InGuqZwI9YUvS81J8brSdgWak(x(xtxSbKIKbwHyVSBflphcuHZO9COKXazSEu7Zk2aKXKPi0(vi1MMwOh4K5o7PKLrc1ea4FnDXgqksgyfI9YUvS81J8z7neMnqwv4foJ2ZzRyS(Gm93spdunbaHcnfmKU2GsIdLmgi9o0))XugebLqHMcgsxBqjbcmkiQIZ)A6InGuKmWke7LDRy5Rh5vOPGH01gukCgTh9mq1eaeuqtHznNK4qjJbsVLb)TAPNbQMaGqpWjZD2tjlJehkzmqgBy))TkdIGseyh1HwB8eiWOGOYVEgOAcaIa7Oo0AJN4qjJbYydlE8))w4I3SMgujcq2Au1h6EfHD0UkYVEgOAcaIi8gMUdrRrCOKXazSHfpo)RPl2asrYaRqSx2TILVEKxpWjZD2tjlJcNr7rHuBAAHEGtM7SNswgjutaG)10fBaPizGvi2l7wXYxpYhyh1HwB8cNr7rHuBAAHEGtM7SNswgjutaG)10fBaPizGvi2l7wXYxpYhH3W0DiAnHZO9GlEZAAqLiazRrvFO7ve2r7Qi)kKAttl0dCYCN9uYYiHAca(B1spdunbaHEGtM7SNswgjouYyG0BF6pMMdx2x1kHSc9aNm3zpLSmk()FRYGiOeb2rDO1gpbcmkiQ8RNbQMaGiWoQdT24jouYyG0BF6pMMdx2x1kHSIa7Oo0AJx848VMUydifjdScXEz3kw(6rECbOExy4mApuBAArUvke0vOvrIdnD9)tTPPfznaShH2vIdnDX)A6InGuKmWke7LDRy5Rh5PGMcZAoPWz0EO200ImaXggyTN1XAJPqnba)kKAttl0dCYCN9uYYiXHsgdKEVqrO83Q5WL9vTsiRqAUYG9SowB8)pBqiSx2TIvkcIyhmGbuElBC)TIHAttluOPGH01gusSB()JPmickHcnfmKU2GsceyuqufN)10fBaPizGvi2l7wXYxpYF2sBfVWz0Eui1MMwOh4K5o7PKLrIDJ)w6zGQjaiuOPGH01gusCOKXaP3YW)FmLbrqjuOPGH01gusGaJcIQ48VMUydifjdScXEz3kw(6rEneTLy4mApzdcH9YUvSsrqe7GbmGY7W4FnDXgqksgyfI9YUvS81J8sZvgSN1XAJ8VMUydifjdScXEz3kw(6r(zjEntaE8VMUydifjdScXEz3kw(6r(Gi2bdyav4mApLbrqjOXB5C9HUtzvbrbcmkiQ836Sv0BpHsM))kKAttl0dCYCN9uYYiXUjo)RPl2asrYaRqSx2TILVEKpHMu4mApXugebLGgVLZ1h6oLvfefiWOGOYFRZwrV9Sqz()RqQnnTqpWjZD2tjlJe7M4Kx2GAIC(GSKIuec]] )


end
