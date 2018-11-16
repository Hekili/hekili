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

        executioners_precision = {
            id = 272870,
            duration = 30,
            max_stack = 2,
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

        -- Map buff.executioners_precision to debuff.executioners_precision; use rawset to avoid changing the meta table.
        rawset( buff, "executioners_precision", debuff.executioners_precision )
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
                setCooldown( "global_cooldown", 4 * haste )
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
                if azerite.executioners_precision.enabled then
                    applyDebuff( "target", "executioners_precision", nil, min( 2, debuff.executioners_precision.stack + 1 ) )
                end                
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
                removeDebuff( "target", "executioners_precision" )
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

    
    spec:RegisterPack( "Arms", 20181028.1739, [[dCKz)aqirspcLs2KuXNqPuXOGiNcIAvKkfEfkvZse6wIiAxO6xIIHjk1XerTmrWZerAAsL01qPW2ej6BOuKXjvIZHsPSoreAEIsUhkzFsL6GIeSquKhIsrXfjvk1jjvkALIuZeLIs3eLsL2PQs)eLsvnurcTure8uPmvvfBLuPKVIsr1Ev6VQYGPQdtzXaEmvMmHlJSzi9zPQrRQ60kwnkLQ8AuuZMKBtk7wLFd1WHWYb9Cjtx46aTDsvFxunEsLCEsfRNuPA(OW(j6n59Z2ewq73eYo5UKC2j0fEYSPKY26Ax3wOdcABimhZwpTTZ0OTLcqTABimDuytSF2wHbHoAB)rGOsIzY0pXpia3H1YuJgOYIbFoOHgzQrZLbqHbYaGAjPG0NbbeJokQYKIqkjyJOYKIjHhBUbHdg(sbOwXRrZTnaWrf6M3cSnHf0(nHStUljNDcDHNmBkPSTKYM2Mbg)y42AJgOYIbFSzGgAST)riOBb2MGk32ylPpfGAL0ZMBq4GHY0SL0)hbIkjMjt)e)GaChwltnAGklg85GgAKPgnxgafgidaQLKcsFgeqm6OOktkcPKGnIktkMeES5geoy4lfGAfVgnNmnBj9S9DbgGGsFcDjrPpHStUlsFsk9SrsmPDr6tr2UY0Y0SL0ZM53UEQsIY0SL0NKsFkieKq6trqnnsXLPzlPpjL(uqiiH0RBnUad1r6tcG1FgDtne0jMRx61TgxGH6WLPzlPpjL(uqiiH0ZKfHIK(2pgmK(al9iGKdRbyH0NcPiBwUmnBj9jP0RBRlYbgd(iiBNs6tri5MAWN0pL0BsVGaarrtu6pCi9M0daIIY3MAQO2pBRMRxrVWG9uSF2VjVF2gDgGIeltBZbNGGJTniPzZvsFwSKEbi0IbFsVUH0NnpPsFhPxqaGOOChwHRcSELMv)Cbo)2M5IbFBdsNyJ9Bc7NTrNbOiXY02CWji4yBdA9K0NL0NYSL(ospssFQsFyk6cUGmHsNNZuAC6mafjKEgmKEaquuUGmHsNNZuACbo)KEK3M5IbFBRyguPkeQjccUX(nP7NTrNbOiXY02CWji4yBlvPhaefLlitO055mLgheH03r6rs6DySsGZpUdRWvbwVsZQFoK0S5kPplPpbPNbdPhjPpmfDbp3GaqYyMGC6mafjK(osVdJvcC(XZniaKmMjihsA2CL0NL0NG0JS0J82mxm4BBqtV1tWn2VDD)Sn6mafjwM2MdobbhBBccaefL7WkCvG1R0S6NlW532mxm4BBoScxfy9knR(3y)Yg7NTrNbOiXY02CWji4yBtqaGOOChwHRcSELMv)Cbo)2M5IbFBl3GaqYyMGBSFt5(zBMlg8TnbzcLopNP02gDgGIeltBSFzt7NTrNbOiXY02CWji4yBdaefLxGcbDpbzXphsMl2M5IbFBJ0f5adAJ9Bx2pBJodqrILPT5GtqWX2MdJvcC(X1WWWuVkGdZehsA2CL03r6rs6tv6dtrxWfKju68CMsJtNbOiH0ZGH0daIIYfKju68CMsJlW5N0JS03r6rs6rs6feaikk3Hv4QaRxPz1pheH03r6tv6nDNGtq8GQ4HrFAt)FWPZauKq6rw6zWq6barr5bvXdJ(0M()GdIq6rEBMlg8TnaLjOkWqTn2VST9Z2OZauKyzABo4eeCSTviiL6fgSNIIN)pqv(CcPVBPpHTzUyW32CkY0tBSFto79Z2OZauKyzABo4eeCSTz6obNG4fnL24E5MEIdTJzPNL0N0TzUyW32W6jicCob3y)MCY7NTzUyW320WWWuVkGdZ02OZauKyzAJ9BYjSF2gDgGIeltBZbNGGJTTWu0fCucQhdFy0hGfHI40zaksi9DKEKKEaquuUGmHsNNZuACqespdgsp06jPVBwsFkZw6rEBMlg8TT8)bQYNtSX(n5KUF2M5IbFBdRNGiW5eCB0zaksSmTX(n5UUF2gDgGIeltBZbNGGJTTWu0fCucQhdFy0hGfHI40zaksi9DKEKK(uLEt3j4eepOkEy0N20)hC6mafjKEgmKEbbaIIYDyfUkW6vAw9Zbri9iVnZfd(2w()av5Zj2y)MmBSF2gDgGIeltBZbNGGJTTuL(Wu0fCucQhdFy0hGfHI40zaksi9DKEKK(uLEt3j4eepOkEy0N20)hC6mafjKEgmKEbbaIIYDyfUkW6vAw9Zbri9myi9aGOOCbzcLopNP04GiKEgmKEO1tsF3SK(uMT0J82mxm4BBLY02y)MCk3pBZCXGVTPFCbgQZdcw)BJodqrILPn2VjZM2pBZCXGVTnAiOtmx)t)4cmuNTrNbOiXY0gBSnbHAGQy)SFtE)SnZfd(2M73G902OZauKyzAJ9Bc7NTzUyW32qaQPrQTrNbOiXY0g73KUF2M5IbFBdbog8Tn6mafjwM2y)219Z2OZauKyzABo4eeCSTjiaquuUdRWvbwVsZQFoiITzUyW32auyS4Hcc1zJ9lBSF2gDgGIeltBZbNGGJTnbbaIIYDyfUkW6vAw9ZbrSnZfd(2gablcY8C9BSFt5(zB0zaksSmTnhCcco22eeaikk3Hv4QaRxPz1pxGZpPVJ07WyLaNFCnmmm1Rc4WmXHKMnxj9Dl9jZzdPVJ0dTEs6Zs6zJS3M5IbFBZGo7OxGHq6In2VSP9Z2OZauKyzABo4eeCSTjiaquuUdRWvbwVsZQFUaNFBZCXGVTPM()OES9af9A0fBSF7Y(zB0zaksSmTnhCcco22eeaikk3Hv4QaRxPz1pheX2mxm4BBOdKauySyJ9lBB)Sn6mafjwM2MdobbhBBccaefL7WkCvG1R0S6NdIyBMlg8Tn7Cufqt9CMsTX(n5S3pBZCXGVTbw0BcsR2gDgGIeltBSFto59Z2OZauKyzABo4eeCST5WyLaNFChwHRcSELMv)CiPzZvsFwsFxKEgmKEKK(Wu0f8CdcajJzcYPZauKq67i9omwjW5hp3GaqYyMGCiPzZvsFwsFxKEK3M5IbFBZ0BHb3y)MCc7NTrNbOiXY02CWji4yBRqqk1lmypffp)FGQ85esF3sFYsFhPhjP3HXkbo)4aktqvGHACiPzZvsF3sFYzl9myi9omwjW5h3Hv4QaRxPz1phsA2CL03T03fPNbdP30DcobXdQIhg9Pn9)bNodqrcPh5TzUyW32QCIqmx)Rc4WmvBSFtoP7NTrNbOiXY02CWji4yBdAJ4r6Pl4MquCsxtf12mxm4BBqW7zUyW3tnvSn1uX7mnAB)MBJ9BYDD)Sn6mafjwM2MdobbhBBfcsPEHb7PO45)duLpNq67w6762mxm4BBqW7zUyW3tnvSn1uX7mnABOJE6fgSNIn2VjZg7NTrNbOiXY02CWji4yBdjPpmfDbxZQYCqItNbOiH03r6dd2tb)Nmv8Zr4cPplPpPSH0JS0ZGH0hgSNc(pzQ4NJWfsFwsFczVnZfd(2ge8EMlg89utfBtnv8otJ2gPlYbg0g73Kt5(zB0zaksSmTnZfd(2ge8EMlg89utfBtnv8otJ2wnxVIEHb7PyJn2gci5WAawSF2VjVF2gDgGIeltBSFty)Sn6mafjwM2y)M09Z2OZauKyzAJ9Bx3pBJodqrILPn2VSX(zBMlg8Tnalcf9QFmySn6mafjwM2y)MY9Z2mxm4BBiWXGVTrNbOiXY0gBSnsxKdmO9Z(n59Z2OZauKyzABo4eeCSTbTEs6Zs6tz2sFhPhjPpvPpmfDbxqMqPZZzknoDgGIespdgspaikkxqMqPZZzknUaNFspYBZCXGVTvmdQufc1ebb3y)MW(zB0zaksSmTnhCcco22sv6barr5cYekDEotPXbri9DKEKKEhgRe48J7WkCvG1R0S6NdjnBUs6Zs6tq6zWq6rs6dtrxWZniaKmMjiNodqrcPVJ07WyLaNF8CdcajJzcYHKMnxj9zj9ji9il9iVnZfd(2g00B9eCJ9Bs3pBJodqrILPT5GtqWX2MGaarr5oScxfy9knR(5cC(TnZfd(2MdRWvbwVsZQ)n2VDD)Sn6mafjwM2MdobbhBBccaefL7WkCvG1R0S6NlW532mxm4BB5geasgZeCJ9lBSF2M5IbFBtqMqPZZzkTTrNbOiXY0g73uUF2gDgGIeltBZbNGGJTnO1tsFwsFsZw67i9Pk9aGOOCbzcLopNP04Gi2M5IbFBdqzcQcmuBJ9lBA)Sn6mafjwM2MdobbhBBfcsPEHb7PO45)duLpNq67w6tyBMlg8TnNIm90g73USF2gDgGIeltBZbNGGJTnaquuUdcw)Z1)SQmqvWbrSnZfd(2wPmTn2VST9Z2OZauKyzABo4eeCSTbaIIYX6jicCob5vyoMLEwsFcsFhPpmfDbxajtCgy)FWPZauKq6zWq6feaikkN0f5aJbFeSEiGKBQbF8kmhZsplPpHTzUyW320WWWuVkGdZ0g73KZE)Sn6mafjwM2MdobbhBBaGOOCbzcLopNP04Gi2M5IbFBJ0f5adAJ9BYjVF2M5IbFBdRNGiW5eCB0zaksSmTX(n5e2pBZCXGVTr6ICGbTn6mafjwM2yJT9BU9Z(n59Z2OZauKyzABo4eeCSTbjnBUs6ZIL0laHwm4t61nK(S5jv67i9ij9Pk9qBepspDb3eIIdIq6zWq6barr5voriMR)vbCyMkoicPh5TzUyW32G0j2y)MW(zB0zaksSmTnhCcco22Gwpj9zj9PmBPVJ0JK07WyLaNFCbzcLopNP04qsZMRK(UL(Kk9myi9Pk9HPOl4cYekDEotPXPZauKq6rEBMlg8TTIzqLQqOMii4g73KUF2gDgGIeltBZbNGGJTnKKEhgRe48JdOmbvbgQXHKMnxj9Dl9Pu6zWq6dtrxWHMERNGC6mafjK(osVdJvcC(XHMERNGCiPzZvsF3sFkLEKL(ospssVdJvcC(XDyfUkW6vAw9ZHKMnxj9zj9ji9myi9ij9HPOl45geasgZeKtNbOiH03r6DySsGZpEUbbGKXmb5qsZMRK(SK(eKEKLEK3M5IbFBtqMqPZZzkTn2VDD)Sn6mafjwM2MdobbhBBij9qBepspDb3eIIdIq6zWq6H2iEKE6cUjefFoPVBPpmypf8y0OxGFIHKEKL(ospssVdJvcC(XDyfUkW6vAw9ZHKMnxj9zj9ji9myi9ij9HPOl45geasgZeKtNbOiH03r6DySsGZpEUbbGKXmb5qsZMRK(SK(eKEKLEK3M5IbFBdA6TEcUX(Ln2pBJodqrILPT5GtqWX2g0gXJ0txWnHO4GiKEgmKEOnIhPNUGBcrXNt67w67A2spdgspssp0gXJ0txWnHO4Zj9Dl9jKT03r6dtrxWTRNGpn7SEsJUGtNbOiH0J82mxm4BBoScxfy9knR(3y)MY9Z2OZauKyzABo4eeCSTbTr8i90fCtikoicPNbdPhAJ4r6Pl4Mqu85K(UL(UMT0ZGH0JK0dTr8i90fCtik(CsF3sFczl9DK(Wu0fC76j4tZoRN0Ol40zaksi9iVnZfd(2wUbbGKXmb3y)YM2pBJodqrILPT5GtqWX2gaikkVYjcXC9VkGdZuXf48t67i9ij9ij9ccaefL7WkCvG1R0S6NdIq67i9qBepspDb3eIIpN03T0hgSNcEmA0lWpXqspYspdgsp0gXJ0txWnHO4GiK(ospsspssVGaarr5oScxfy9knR(5qsZMRK(UL(UYzdPVJ0NQ0B6obNG4bvXdJ(0M()GtNbOiH0JS0ZGH0daIIYdQIhg9Pn9)bheH0JS0J82mxm4BBaktqvGHABSF7Y(zB0zaksSmTnhCcco22sv6H2iEKE6cUjefheH0ZGH0JK0dTr8i90fCtikoicPVJ0B6obNG4fnL24E5MEItNbOiH0J82mxm4BBy9eeboNGBSFzB7NTrNbOiXY02CWji4yBRqqk1lmypffp)FGQ85esF3sFcBZCXGVT5uKPN2y)MC27NTrNbOiXY02CWji4yBlvPhAJ4r6Pl4MquCqespdgspssFQsFyk6cUtrMEItNbOiH03r6f4GlicXlhdEIIdjnBUs6Zs6tq6rw6zWq6barr5fOqq3tqw8ZHK5ITzUyW32iDroWG2y)MCY7NTrNbOiXY02CWji4yBlvPhAJ4r6Pl4MquCqespdgspssFQsFyk6cUtrMEItNbOiH03r6f4GlicXlhdEIIdjnBUs6Zs6tq6rEBMlg8Tnnmmm1Rc4WmTX(n5e2pBJodqrILPT5GtqWX2g0gXJ0txWnHO4Gi2M5IbFBl)FGQ85eBSFtoP7NTzUyW32W6jicCob3gDgGIeltBSFtUR7NTrNbOiXY02CWji4yBlmfDbhLG6XWhg9byrOioDgGIeBZCXGVTL)pqv(CIn2VjZg7NTrNbOiXY02CWji4yBlvPpmfDbhLG6XWhg9byrOioDgGIesFhPpvPhAJ4r6Pl4MquCqeBZCXGVTvktBJ9BYPC)SnZfd(2M(XfyOopiy9Vn6mafjwM2y)MmBA)SnZfd(22OHGoXC9p9JlWqD2gDgGIeltBSX2qh90lmypf7N9BY7NTrNbOiXY02CWji4yBdA9K0NL0NYSL(ospssFQsFyk6cUGmHsNNZuAC6mafjKEgmKEaquuUGmHsNNZuACbo)KEK3M5IbFBRyguPkeQjccUX(nH9Z2OZauKyzABo4eeCSTHK0NQ0hMIUGNBqaizmtqoDgGIespdgsVdJvcC(XZniaKmMjihsA2CL0NL0NG0J82mxm4BBqtV1tWn2VjD)Sn6mafjwM2MdobbhBBccaefL7WkCvG1R0S6NlW532mxm4BBoScxfy9knR(3y)219Z2OZauKyzABo4eeCSTjiaquuUdRWvbwVsZQFUaNFBZCXGVTLBqaizmtWn2VSX(zB0zaksSmTnhCcco22aarr5voriMR)vbCyMkUaNFsFhPhjPpvPpmfDbxqMqPZZzknoDgGIespdgspaikkxqMqPZZzknUaNFspYsFhPhjPhjPxqaGOOChwHRcSELMv)CiPzZvsF3sFx5SH03r6tv6nDNGtq8GQ4HrFAt)FWPZauKq6rw6zWq6barr5bvXdJ(0M()GdIq6rEBMlg8TnaLjOkWqTn2VPC)SnZfd(2MGmHsNNZuABJodqrILPn2VSP9Z2mxm4BBofz6PTrNbOiXY0g73USF2gDgGIeltBZbNGGJTnKK(uL(Wu0fCNIm9eNodqrcPVJ0lWbxqeIxog8efhsA2CL0NL0NG0JS0ZGH0JK0daIIYlqHGUNGS4NdjZfspdgspaikkVc8rVFYGbhsMlKEKL(ospsspaikkVYjcXC9VkGdZuXbri9myi9omwjW5hVYjcXC9VkGdZuXHKMnxj9Dl9Dr6rEBMlg8TnsxKdmOn2VST9Z2OZauKyzABo4eeCSTHK0NQ0hMIUG7uKPN40zaksi9DKEbo4cIq8YXGNO4qsZMRK(SK(eKEKLEgmKEaquuELteI56FvahMPIdIq67i9aGOOCSEcIaNtqEfMJzPNL0NG03r6rs6dtrxWfqYeNb2)hC6mafjKEgmKEbbaIIYjDroWyWhbRhci5MAWhVcZXS0Zs6tq6rEBMlg8Tnnmmm1Rc4WmTX(n5S3pBJodqrILPT5GtqWX2MGaarr5oScxfy9knR(5GiKEgmKEKKEaquuUdcw)Z1)SQmqvWbri9DK(Wu0fCucQhdFy0hGfHI40zaksi9iVnZfd(2w()av5Zj2y)MCY7NTrNbOiXY02CWji4yBdaefLlitO055mLgheH0ZGH0dTEs67w6tz2BZCXGVTL)pqv(CIn2VjNW(zBMlg8TnSEcIaNtWTrNbOiXY0g73Kt6(zBMlg8TT8)bQYNtSn6mafjwM2y)MCx3pBZCXGVTPFCbgQZdcw)BJodqrILPn2VjZg7NTzUyW32gne0jMR)PFCbgQZ2OZauKyzAJn2yB6jyn4B)Mq2j3LSzBjnBEcjnPSTTLBWBU(AB6MAiWWGesFkLEZfd(KE1urXLP3wHGC7x2uYBdbeJokABSL0NcqTs6zZniCWqzA2s6)JarLeZKPFIFqaUdRLPgnqLfd(CqdnYuJMldGcdKba1ssbPpdcigDuuLjfHusWgrLjftcp2Cdchm8LcqTIxJMtMMTKE2(UadqqPpHUKO0Nq2j3fPpjLE2ijM0Ui9PiBxzAzA2s6zZ8BxpvjrzA2s6tsPpfecsi9PiOMgP4Y0SL0NKsFkieKq61TgxGH6i9jbW6pJUPgc6eZ1l96wJlWqD4Y0SL0NKsFkieKq6zYIqrsF7hdgsFGLEeqYH1aSq6tHuKnlxMMTK(Ku61T1f5aJbFeKTtj9PiKCtn4t6Ns6nPxqaGOOjk9hoKEt6barr5Y0Y0SL0RBRlYbgKq6biumKKEhwdWcPhG6NR4sFk4CeIOK(dFj5Vb1qbvsV5IbFL0JpLoCzAZfd(koci5WAawWcvzfZY0Mlg8vCeqYH1aSGDwzqXyHmT5IbFfhbKCynalyNvgdSxJUWIbFY0SL03odr9JdPhAJq6barrjH0xHfL0dqOyij9oSgGfspa1pxj92jKEeqkjrGJyUEPFkPxGpIltBUyWxXrajhwdWc2zLPodr9JJxfwuY0Mlg8vCeqYH1aSGDwzaSiu0R(XGHmT5IbFfhbKCynalyNvge4yWNmTmnBj9626ICGbjKEspb1r6JrJK(4NKEZfyO0pL0B6TrzakIltBUyWxXY9BWEsM2CXGVIDwzqaQPrkzAZfd(k2zLbbog8jtBUyWxXoRmakmw8qbH6K4GYsqaGOOChwHRcSELMv)CqeY0Mlg8vSZkdablcY8C9joOSeeaikk3Hv4QaRxPz1pheHmT5IbFf7SYyqND0lWqiDrIdklbbaIIYDyfUkW6vAw9Zf48RJdJvcC(X1WWWuVkGdZehsA2Cv3jZzJoqRNYInYwM2CXGVIDwzut)Fup2EGIEn6IehuwccaefL7WkCvG1R0S6NlW5NmT5IbFf7SYGoqcqHXIehuwccaefL7WkCvG1R0S6NdIqM2CXGVIDwzSZrvan1ZzkvIdklbbaIIYDyfUkW6vAw9ZbritBUyWxXoRmGf9MG0kzAZfd(k2zLX0BHbtCqz5WyLaNFChwHRcSELMv)CiPzZvz1fgmqkmfDbp3GaqYyMGC6mafj64WyLaNF8CdcajJzcYHKMnxLvxqwM2CXGVIDwzQCIqmx)Rc4WmvjoOSkeKs9cd2trXZ)hOkFor3j3bjhgRe48JdOmbvbgQXHKMnx1DYzZGHdJvcC(XDyfUkW6vAw9ZHKMnx1DxyWW0DcobXdQIhg9Pn9)bNodqrcKLPnxm4RyNvgi49mxm47PMks8mnI1V5sCqzbTr8i90fCtikoPRPIsM2CXGVIDwzGG3ZCXGVNAQiXZ0iwOJE6fgSNIehuwfcsPEHb7PO45)duLpNO7UktBUyWxXoRmqW7zUyW3tnvK4zAelsxKdmOehuwifMIUGRzvzoiXPZauKOtyWEk4)KPIFocxKvszdKzWimypf8FYuXphHlYkHSLPnxm4RyNvgi49mxm47PMks8mnIvnxVIEHb7PqMwM2CXGVIt6ICGbXQyguPkeQjccM4GYcA9uwPm7oiLAyk6cUGmHsNNZuAC6mafjyWaaefLlitO055mLgxGZpKLPnxm4R4KUihyqSZkd00B9emXbLvQaGOOCbzcLopNP04Gi6GKdJvcC(XDyfUkW6vAw9ZHKMnxLvcmyGuyk6cEUbbGKXmb50zaks0XHXkbo)45geasgZeKdjnBUkReqgzzAZfd(koPlYbge7SY4WkCvG1R0S6pXbLLGaarr5oScxfy9knR(5cC(jtBUyWxXjDroWGyNvMCdcajJzcM4GYsqaGOOChwHRcSELMv)Cbo)KPnxm4R4KUihyqSZkJGmHsNNZuAY0Mlg8vCsxKdmi2zLbqzcQcmulXbLf06PSsA2DsfaefLlitO055mLgheHmT5IbFfN0f5adIDwzCkY0tjoOSkeKs9cd2trXZ)hOkFor3jitBUyWxXjDroWGyNvMszAjoOSaarr5oiy9px)ZQYavbheHmT5IbFfN0f5adIDwz0WWWuVkGdZuIdklaquuowpbrGZjiVcZXmRe6eMIUGlGKjodS)p40zaksWGHGaarr5KUihym4JG1dbKCtn4JxH5yMvcY0Mlg8vCsxKdmi2zLH0f5adkXbLfaikkxqMqPZZzknoiczAZfd(koPlYbge7SYG1tqe4CcktBUyWxXjDroWGyNvgsxKdmizAzAZfd(ko6ONEHb7PGvXmOsviuteemXbLf06PSsz2Dqk1Wu0fCbzcLopNP040zaksWGbaikkxqMqPZZzknUaNFiltBUyWxXrh90lmypfSZkd00B9emXbLfsPgMIUGNBqaizmtqoDgGIemy4WyLaNF8CdcajJzcYHKMnxLvciltBUyWxXrh90lmypfSZkJdRWvbwVsZQ)ehuwccaefL7WkCvG1R0S6NlW5NmT5IbFfhD0tVWG9uWoRm5geasgZemXbLLGaarr5oScxfy9knR(5cC(jtBUyWxXrh90lmypfSZkdGYeufyOwIdklaquuELteI56FvahMPIlW5xhKsnmfDbxqMqPZZzknoDgGIemyaaIIYfKju68CMsJlW5hYDqcjbbaIIYDyfUkW6vAw9ZHKMnx1Dx5SrNunDNGtq8GQ4HrFAt)FWPZauKazgmaarr5bvXdJ(0M()GdIazzAZfd(ko6ONEHb7PGDwzeKju68CMstM2CXGVIJo6PxyWEkyNvgNIm9KmT5IbFfhD0tVWG9uWoRmKUihyqjoOSqk1Wu0fCNIm9eNodqrIocCWfeH4LJbprXHKMnxLvciZGbsaGOO8cuiO7jil(5qYCbdgaGOO8kWh9(jdgCizUa5oibaIIYRCIqmx)Rc4WmvCqemy4WyLaNF8kNieZ1)QaomtfhsA2Cv3DbzzAZfd(ko6ONEHb7PGDwz0WWWuVkGdZuIdklKsnmfDb3PitpXPZauKOJahCbriE5yWtuCiPzZvzLaYmyaaIIYRCIqmx)Rc4WmvCqeDaarr5y9eeboNG8kmhZSsOdsHPOl4cizIZa7)doDgGIemyiiaquuoPlYbgd(iy9qaj3ud(4vyoMzLaYY0Mlg8vC0rp9cd2tb7SYK)pqv(CIehuwccaefL7WkCvG1R0S6NdIGbdKaarr5oiy9px)ZQYavbherNWu0fCucQhdFy0hGfHI40zaksGSmT5IbFfhD0tVWG9uWoRm5)duLpNiXbLfaikkxqMqPZZzknoicgmGwp1DkZwM2CXGVIJo6PxyWEkyNvgSEcIaNtqzAZfd(ko6ONEHb7PGDwzY)hOkFoHmT5IbFfhD0tVWG9uWoRm6hxGH68GG1VmT5IbFfhD0tVWG9uWoRmJgc6eZ1)0pUad1rMwM2CXGVI)Bowq6ejoOSGKMnxLflbi0IbF6gzZtAhKsfAJ4r6Pl4MquCqemyaaIIYRCIqmx)Rc4WmvCqeiltBUyWxX)nh7SYumdQufc1ebbtCqzbTEkRuMDhKCySsGZpUGmHsNNZuACiPzZvDNugmsnmfDbxqMqPZZzknoDgGIeiltBUyWxX)nh7SYiitO055mLwIdklKCySsGZpoGYeufyOghsA2Cv3PKbJWu0fCOP36jiNodqrIoomwjW5hhA6TEcYHKMnx1DkrUdsomwjW5h3Hv4QaRxPz1phsA2CvwjWGbsHPOl45geasgZeKtNbOirhhgRe48JNBqaizmtqoK0S5QSsazKLPnxm4R4)MJDwzGMERNGjoOSqcAJ4r6Pl4MquCqemyaTr8i90fCtik(CDhgSNcEmA0lWpXqi3bjhgRe48J7WkCvG1R0S6NdjnBUkReyWaPWu0f8CdcajJzcYPZauKOJdJvcC(XZniaKmMjihsA2CvwjGmYY0Mlg8v8FZXoRmoScxfy9knR(tCqzbTr8i90fCtikoicgmG2iEKE6cUjefFUU7A2myGe0gXJ0txWnHO4Z1Dcz3jmfDb3UEc(0SZ6jn6coDgGIeiltBUyWxX)nh7SYKBqaizmtWehuwqBepspDb3eIIdIGbdOnIhPNUGBcrXNR7UMndgibTr8i90fCtik(CDNq2DctrxWTRNGpn7SEsJUGtNbOibYY0Mlg8v8FZXoRmaktqvGHAjoOSaarr5voriMR)vbCyMkUaNFDqcjbbaIIYDyfUkW6vAw9Zbr0bAJ4r6Pl4Mqu856omypf8y0OxGFIHqMbdOnIhPNUGBcrXbr0bjKeeaikk3Hv4QaRxPz1phsA2Cv3DLZgDs10DcobXdQIhg9Pn9)bNodqrcKzWaaefLhufpm6tB6)doicKrwM2CXGVI)Bo2zLbRNGiW5emXbLvQqBepspDb3eIIdIGbdKG2iEKE6cUjefherht3j4eeVOP0g3l30tC6mafjqwM2CXGVI)Bo2zLXPitpL4GYQqqk1lmypffp)FGQ85eDNGmT5IbFf)3CSZkdPlYbguIdkRuH2iEKE6cUjefhebdgiLAyk6cUtrMEItNbOirhbo4cIq8YXGNO4qsZMRYkbKzWaaefLxGcbDpbzXphsMlKPnxm4R4)MJDwz0WWWuVkGdZuIdkRuH2iEKE6cUjefhebdgiLAyk6cUtrMEItNbOirhbo4cIq8YXGNO4qsZMRYkbKLPnxm4R4)MJDwzY)hOkForIdklOnIhPNUGBcrXbritBUyWxX)nh7SYG1tqe4CcktBUyWxX)nh7SYK)pqv(CIehuwHPOl4Oeupg(WOpalcfXPZauKqM2CXGVI)Bo2zLPuMwIdkRudtrxWrjOEm8HrFawekItNbOirNuH2iEKE6cUjefheHmT5IbFf)3CSZkJ(XfyOopiy9ltBUyWxX)nh7SYmAiOtmx)t)4cmuhzAzAZfd(kEnxVIEHb7PGfKorIdkliPzZvzXsacTyWNUr28K2rqaGOOChwHRcSELMv)Cbo)KPnxm4R41C9k6fgSNc2zLPyguPkeQjccM4GYcA9uwPm7oiLAyk6cUGmHsNNZuAC6mafjyWaaefLlitO055mLgxGZpKLPnxm4R41C9k6fgSNc2zLbA6TEcM4GYkvaquuUGmHsNNZuACqeDqYHXkbo)4oScxfy9knR(5qsZMRYkbgmqkmfDbp3GaqYyMGC6mafj64WyLaNF8CdcajJzcYHKMnxLvciJSmT5IbFfVMRxrVWG9uWoRmoScxfy9knR(tCqzjiaquuUdRWvbwVsZQFUaNFY0Mlg8v8AUEf9cd2tb7SYKBqaizmtWehuwccaefL7WkCvG1R0S6NlW5NmT5IbFfVMRxrVWG9uWoRmcYekDEotPjtBUyWxXR56v0lmypfSZkdPlYbguIdklaquuEbke09eKf)CizUqM2CXGVIxZ1ROxyWEkyNvgaLjOkWqTehuwomwjW5hxdddt9QaomtCiPzZvDqk1Wu0fCbzcLopNP040zaksWGbaikkxqMqPZZzknUaNFi3bjKeeaikk3Hv4QaRxPz1pherNunDNGtq8GQ4HrFAt)FWPZauKazgmaarr5bvXdJ(0M()GdIazzAZfd(kEnxVIEHb7PGDwzCkY0tjoOSkeKs9cd2trXZ)hOkFor3jitBUyWxXR56v0lmypfSZkdwpbrGZjyIdklt3j4eeVOP0g3l30tCODmZkPY0Mlg8v8AUEf9cd2tb7SYOHHHPEvahMjzAZfd(kEnxVIEHb7PGDwzY)hOkForIdkRWu0fCucQhdFy0hGfHI40zaks0bjaquuUGmHsNNZuACqemyaTEQBwPmBKLPnxm4R41C9k6fgSNc2zLbRNGiW5euM2CXGVIxZ1ROxyWEkyNvM8)bQYNtK4GYkmfDbhLG6XWhg9byrOioDgGIeDqkvt3j4eepOkEy0N20)hC6mafjyWqqaGOOChwHRcSELMv)CqeiltBUyWxXR56v0lmypfSZktPmTehuwPgMIUGJsq9y4dJ(aSiueNodqrIoiLQP7eCcIhufpm6tB6)doDgGIemyiiaquuUdRWvbwVsZQFoicgmaarr5cYekDEotPXbrWGb06PUzLYSrwM2CXGVIxZ1ROxyWEkyNvg9JlWqDEqW6xM2CXGVIxZ1ROxyWEkyNvMrdbDI56F6hxGH6SXg7ca]] )


end
