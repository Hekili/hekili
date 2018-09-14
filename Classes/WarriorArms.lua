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

    
    spec:RegisterPack( "Arms", 20180914.1121, [[dO0KbbqirLEevsztIuFIkPsJskCkrvRIkPkVIkXSOs5wsPIDHQFjLmmPuoMiQLHs1ZerAAIk6AsPQTrLKVjLk14OcPZjQqwhvOY8Os19OI2NiXbPcLfsf8qPujUivsfTrQqO(OOcLoPuQKwPu0mfvO6Mujv1orPmuQq0sPcv9uPAQaQRsfcPTsLuHVsfc2lK)cQbtQdtzXO4Xu1Kj5YiBMqFgLmAaoTQwTOcfVgqMnr3MGDR0Vvz4G0XPcHy5kEUKPlCDG2Ui8Drz8IioViP1lQG5dI9d1OKraJ6klieBS3wYoAB5OKZjp5Kz3rZPRq9ivOeQd18azSiuFnbc1DSrOqDOwQYZuiGr96ahpH6aIaA54A1I1haaz4(tOv9cGsl(B9JjgTQxW3IrEmTyeT2rrjAbDoXxsvlh5qoE7vvlhPJh2rWM5Vb2XgHIxVGh1zaFz0UUiguxzbHyJ92s2rBlhLCo5jNm7jT95e1nWaWnOE)fAxW6wyTJnEaVq8ZvOUIkpQ7AyTJncfw7iyZ83GB6AynGiGwoUwTy9baqgU)eAvVaO0I)w)yIrR6f8TyKhtlgrRDuuIwqNt8Lu1YroKJ3Ev1Yr64HDeSz(BGDSrO41l4XnDnSUtqdsGHgSo5C6gwZEBj7OyD7G1jNSJJ92WAhZ1h3e301W62fa2YIkhhUPRH1Tdw7ykfPWAhjOGaj54MUgw3oyTJPuKcRDD8(4MuXAhpybaRvx2I1XH1IVusdwNbGwSgCngjH1XH1DPjG1nIdRP1FGJXIWAhXGtQynLeO0Q(aCiSw8gSgyQcS(eXAx)NfGWnSwW(vMAEoUPRH1Tdw7ykfPWAhSiKew3bCGbwhhwdDi)jWybw7yoYCCoQl)kkeWOE9lljbh2WIceWi2sgbmQtRXijfYbu3pFqZBO(qc2Vfw7UtSwbow83I1UEyDB8KI1PXAfXakkY9N8QcSGlbRaWvx2I6Mp(Br9HwfkqSXocyuNwJrskKdOUF(GM3q9XyryT7yTRAdRtJ1nWA)Ds1LTCfzkzQWEtkWhsW(TW6uW6KI1qGG15I1HjPn4kYuYuH9MuGtRXijfwNh1nF83I6fqGszbv(rqdkqSLueWOoTgJKuihqD)8bnVH6nWA)Ds1LTCgPPOkUrGpKG9BH1PG1UcRHabRdtsBWhlHXIgoTgJKuyDAS2FNuDzlFSeglA4djy)wyDkyTRW68yDASUbw7VtQUSL7p5vfybxcwbGpKG9BH1UJ1SJ1qGG1nW6WK0g8mBygYaIgoTgJKuyDAS2FNuDzlpZgMHmGOHpKG9BH1UJ1SJ15X68OU5J)wuxrMsMkS3KcOaXworaJ60AmssHCa19Zh08gQNlwZakkYvKPKPc7nPahekwNgRBG1(7KQlB5(tEvbwWLGva4djy)wyT7yn7yneiyDdSomjTbpZgMHmGOHtRXijfwNgR93jvx2YZSHzidiA4djy)wyT7yn7yDESopQB(4Vf1hlHXIguGyR9iGrDAngjPqoG6(5dAEd1vedOOi3FYRkWcUeScaxDzlQB(4Vf19N8QcSGlbRaGceBUcbmQtRXijfYbu3pFqZBOUIyaff5(tEvbwWLGva4QlBrDZh)TOEMnmdzardkqS1UraJ60AmssHCa19Zh08gQZakkYlqLIwyfzba(qMpqDZh)TOoLeYdgekqS5OiGrDAngjPqoG6(5dAEd193jvx2YfUjmjCfZdeXhsW(TW60yDdSUbwRigqrrU)KxvGfCjyfaoiuSonwNlwB5anFq8GQa(eHfEwacoTgJKuyDESgceSMbuuKhufWNiSWZcqWbHI15rDZh)TOoJ0uuf3iGceB5ieWOoTgJKuihqD)8bnVH6fuskHdByrrXZa8Jm7xfwNcwZoQB(4Vf19sYsqOaXwYTHag1P1yKKc5aQ7NpO5nu3YbA(G4f9LW7HZSeeFSfiS2jwNuu38XFlQFjOb6LrdkqSLCYiGrDZh)TOUWnHjHRyEGiuNwJrskKdOaXwYSJag1nF83I6xcAGEz0G60AmssHCafi2soPiGrDAngjPqoG6(5dAEd1dtsBWfPjXnWNimJfHK40AmssH1PX6gyDUyTLd08bXdQc4tew4zbi40AmssH1qGG1nW6XyryDkoXAx1gwdbcwRigqrrU)KxvGfCjyfaoiuSgceSMbuuKRitjtf2BsboiuSopwNh1nF83I6za(rM9Rcfi2soNiGrDAngjPqoG6(5dAEd1ZfRdtsBWfPjXnWNimJfHK40AmssH1PX6gyDUyTLd08bXdQc4tew4zbi40AmssH1qGG1nW6XyryDkoXAx1gwdbcwRigqrrU)KxvGfCjyfaoiuSgceSMbuuKRitjtf2BsboiuSopwNh1nF83I6L0eqbITKBpcyu38XFlQN49XnPcpGfauNwJrskKdOafOUIenqzGagXwYiGrDZh)TOUhGnSiuNwJrskKdOaXg7iGrDZh)TOouqbbsI60AmssHCafi2skcyu38XFlQBGXbBryEGqDAngjPqoGceB5ebmQB(4Vf1HEXFlQtRXijfYbuGyR9iGrDAngjPqoG6(5dAEd1vedOOi3FYRkWcUeScahekQB(4Vf1zK3PGfbNurbInxHag1P1yKKc5aQ7NpO5nuxrmGIIC)jVQal4sWkaCqOOU5J)wuNHMIgG(LfkqS1UraJ60AmssHCa19Zh08gQRigqrrU)KxvGfCjyfaU6YwSonw7VtQUSLlCtys4kMhiIpKG9BH1PG1jZBpwNgRhJfH1UJ1TVnu38XFlQBJ3wcoUzOnqbInhfbmQtRXijfYbu3pFqZBOUIyaff5(tEvbwWLGva4QlBrDZh)TOU8zbik4CmGkwc0gOaXwocbmQtRXijfYbu3pFqZBOUIyaff5(tEvbwWLGva4GqrDZh)TOU4peJ8ofkqSLCBiGrDAngjPqoG6(5dAEd1vedOOi3FYRkWcUeScahekQB(4Vf1T1tvmMe2BsjkqSLCYiGrDAngjPqoG6(5dAEd193jvx2Y9N8QcSGlbRaWhsW(TWA3XAhfRHabRBG1HjPn4z2WmKbenCAngjPW60yT)oP6YwEMnmdzardFib73cRDhRDuSopQB(4Vf1TewydkqSLm7iGrDAngjPqoG6(5dAEd1lOKuch2WIIINb4hz2VkSofSozSonw3aR93jvx2YzKMIQ4gb(qc2VfwNcwNCByneiyT)oP6YwU)KxvGfCjyfa(qc2VfwNcw7OyneiyTLd08bXdQc4tew4zbi40AmssH15rDZh)TOELre0FzbxX8arfkqSLCsraJ60AmssHCa19Zh08gQp2RGPe0gCtPkoLKVIc1nF83I6d4cB(4Vfw(vG6YVc41eiuhG5rbITKZjcyuNwJrskKdOUF(GM3q9ckjLWHnSOO4za(rM9RcRtbRZjQB(4Vf1hWf28XFlS8Ra1LFfWRjqOU4NGGdByrbkqSLC7raJ60AmssHCa19Zh08gQ3aRdtsBWfSQm)qCAngjPW60yDydlk4aitga4q9bw7owN02J15XAiqW6WgwuWbqMmaWH6dS2DSM92qDZh)TO(aUWMp(BHLFfOU8RaEnbc1PKqEWGqbITKDfcyuNwJrskKdOU5J)wuFaxyZh)TWYVcux(vaVMaH61VSKeCydlkqbkqDOd5pbglqaJylzeWOoTgJKuihqbIn2raJ60AmssHCafi2skcyuNwJrskKdOaXworaJ60AmssHCafi2Apcyu38XFlQZyrij4cWbgOoTgJKuihqbInxHag1nF83I6qV4Vf1P1yKKc5akqbQtjH8GbHagXwYiGrDAngjPqoG6(5dAEd1hJfH1UJ1UQnSonw3aRBG1(7KQlB5kYuYuH9MuGpKG9BH1PG1jfRtJ15I1mGIICfzkzQWEtkWbHI15XAiqW6CX6WK0gCfzkzQWEtkWP1yKKcRZJ6Mp(Br9ciqPSGk)iObfi2yhbmQtRXijfYbu3pFqZBOU)oP6YwoJ0uuf3iWhsW(TW6uWAxH1PX6gyT)oP6YwU)KxvGfCjyfa(qc2Vfw7owZowdbcw3aRdtsBWZSHzidiA40AmssH1PXA)Ds1LT8mBygYaIg(qc2Vfw7owZowNhRZJ6Mp(BrDfzkzQWEtkGceBjfbmQtRXijfYbu3pFqZBOEUyndOOixrMsMkS3KcCqOyDASUbw7VtQUSL7p5vfybxcwbGpKG9BH1UJ1SJ1qGG1nW6WK0g8mBygYaIgoTgJKuyDAS2FNuDzlpZgMHmGOHpKG9BH1UJ1SJ15X68OU5J)wuFSeglAqbITCIag1P1yKKc5aQ7NpO5nuxrmGIIC)jVQal4sWkaC1LTOU5J)wu3FYRkWcUeScakqS1EeWOoTgJKuihqD)8bnVH6kIbuuK7p5vfybxcwbGRUSf1nF83I6z2WmKbenOaXMRqaJ60AmssHCa19Zh08gQpglcRDhRtAByDASoxSMbuuKRitjtf2Bsboiuu38XFlQZinfvXncOaXw7gbmQtRXijfYbu3pFqZBOEbLKs4Wgwuu8ma)iZ(vH1PG1SJ6Mp(BrDVKSeekqS5OiGrDAngjPqoG6(5dAEd1zaff5(bSa8llyRkdugCqOOU5J)wuVKMakqSLJqaJ60AmssHCa19Zh08gQRigqrrU)KxvGfCjyfaoiuSonwZakkYVe0a9YOHxH5bcRDI1SJ1PX6gyDysAdUAitTgilabNwJrskSgceSMbuuKtjH8GXFlnfm0H8F93YRW8aH1oXA2X68OU5J)wux4MWKWvmpqekqSLCBiGrDZh)TO(LGgOxgnOoTgJKuihqbITKtgbmQB(4Vf1PKqEWGqDAngjPqoGcuG6ampcyeBjJag1P1yKKc5aQ7NpO5nuFib73cRD3jwRahl(BXAxpSUnEsX60yDdSoxSESxbtjOn4MsvCqOyneiyndOOiVYic6VSGRyEGOIdcfRZJ6Mp(Br9HwfkqSXocyuNwJrskKdOUF(GM3q9XyryT7yTRAdRtJ1nWA)Ds1LTCfzkzQWEtkWhsW(TW6uW6KI1qGG15I1HjPn4kYuYuH9MuGtRXijfwNh1nF83I6fqGszbv(rqdkqSLueWOoTgJKuihqD)8bnVH6nWA)Ds1LTCgPPOkUrGpKG9BH1PG1UcRHabRdtsBWhlHXIgoTgJKuyDAS2FNuDzlFSeglA4djy)wyDkyTRW68yDASUbw7VtQUSL7p5vfybxcwbGpKG9BH1UJ1SJ1qGG1nW6WK0g8mBygYaIgoTgJKuyDAS2FNuDzlpZgMHmGOHpKG9BH1UJ1SJ15X68OU5J)wuxrMsMkS3KcOaXworaJ60AmssHCa19Zh08gQ3aRh7vWucAdUPufhekwdbcwp2RGPe0gCtPk(VyDkyDydlk4XlqWXbREcRZJ1PX6gyT)oP6YwU)KxvGfCjyfa(qc2Vfw7owZowdbcw3aRdtsBWZSHzidiA40AmssH1PXA)Ds1LT8mBygYaIg(qc2Vfw7owZowNhRZJ6Mp(Br9XsySObfi2ApcyuNwJrskKdOUF(GM3q9XEfmLG2GBkvXbHI1qGG1J9kykbTb3uQI)lwNcwNZ2WAiqW6gy9yVcMsqBWnLQ4)I1PG1S3gwNgRdtsBWTLfnWc2ASibAdoTgJKuyDEu38XFlQ7p5vfybxcwbafi2CfcyuNwJrskKdOUF(GM3q9XEfmLG2GBkvXbHI1qGG1J9kykbTb3uQI)lwNcwNZ2WAiqW6gy9yVcMsqBWnLQ4)I1PG1S3gwNgRdtsBWTLfnWc2ASibAdoTgJKuyDEu38XFlQNzdZqgq0GceBTBeWOoTgJKuihqD)8bnVH6nWAfXakkY9N8QcSGlbRaWbHI1PX6XEfmLG2GBkvX)fRtbRdByrbpEbcooy1tyDESgceSESxbtjOn4MsvCqOyDASUbw3aRvedOOi3FYRkWcUeScaFib73cRtbRZjV9yDASoxS2YbA(G4bvb8jcl8SaeCAngjPW68yneiyndOOipOkGpryHNfGGdcfRZJ6Mp(BrDgPPOkUrafi2CueWOoTgJKuihqD)8bnVH65I1J9kykbTb3uQIdcfRHabRBG1J9kykbTb3uQIdcfRtJ1woqZheVOVeEpCMLG40AmssH15rDZh)TO(LGgOxgnOaXwocbmQtRXijfYbu3pFqZBOEbLKs4Wgwuu8ma)iZ(vH1PG1SJ6Mp(BrDVKSeekqSLCBiGrDAngjPqoG6(5dAEd1ZfRh7vWucAdUPufhekwdbcw3aRZfRdtsBW9sYsqCAngjPW60yT6cUIiOWzh4Qk(qc2Vfw7owZowNhRHabRzaff5fOsrlSISaaFiZhOU5J)wuNsc5bdcfi2sozeWOoTgJKuihqD)8bnVH65I1J9kykbTb3uQIdcfRHabRBG15I1HjPn4EjzjioTgJKuyDASwDbxreu4SdCvfFib73cRDhRzhRZJ6Mp(BrDHBctcxX8arOaXwYSJag1P1yKKc5aQ7NpO5nuFSxbtjOn4MsvCqOOU5J)wupdWpYSFvOaXwYjfbmQB(4Vf1Ve0a9YOb1P1yKKc5akqSLCoraJ60AmssHCa19Zh08gQhMK2GlstIBGpryglcjXP1yKKc1nF83I6za(rM9Rcfi2sU9iGrDAngjPqoG6(5dAEd1ZfRdtsBWfPjXnWNimJfHK40AmssH1PX6CX6XEfmLG2GBkvXbHI6Mp(Br9sAcOaXwYUcbmQtRXijfYbu3pFqZBOEUy9yVcMsqBWnLQ4GqrDZh)TOEI3h3Kk8awaqbkqDXpbbh2WIceWi2sgbmQtRXijfYbu3pFqZBO(ySiS2DS2vTH1PX6gyT)oP6YwUImLmvyVjf4djy)wyDkyDsXAiqW6CX6WK0gCfzkzQWEtkWP1yKKcRZJ6Mp(Br9ciqPSGk)iObfi2yhbmQtRXijfYbu3pFqZBOU)oP6YwoJ0uuf3iWhsW(TW6uWAxH1PX6gyT)oP6YwU)KxvGfCjyfa(qc2Vfw7owZowdbcw3aRdtsBWZSHzidiA40AmssH1PXA)Ds1LT8mBygYaIg(qc2Vfw7owZowNhRZJ6Mp(BrDfzkzQWEtkGceBjfbmQtRXijfYbu3pFqZBOEUyndOOixrMsMkS3KcCqOyDASUbw7VtQUSL7p5vfybxcwbGpKG9BH1UJ1SJ1qGG1nW6WK0g8mBygYaIgoTgJKuyDAS2FNuDzlpZgMHmGOHpKG9BH1UJ1SJ15X68OU5J)wuFSeglAqbITCIag1P1yKKc5aQ7NpO5nuxrmGIIC)jVQal4sWkaC1LTOU5J)wu3FYRkWcUeScakqS1EeWOoTgJKuihqD)8bnVH6kIbuuK7p5vfybxcwbGRUSf1nF83I6z2WmKbenOaXMRqaJ60AmssHCa19Zh08gQZakkYRmIG(ll4kMhiQ4QlBX60yDUyndOOixrMsMkS3KcCqOyDASUbw3aRvedOOi3FYRkWcUeScaFib73cRtbRZjV9yDASoxS2YbA(G4bvb8jcl8SaeCAngjPW68yneiyndOOipOkGpryHNfGGdcfRZJ6Mp(BrDgPPOkUrafi2A3iGrDZh)TOUxswcc1P1yKKc5akqS5OiGrDAngjPqoG6(5dAEd1BG15I1HjPn4EjzjioTgJKuyDASwDbxreu4SdCvfFib73cRDhRzhRZJ1qGG1nWAgqrrEbQu0cRilaWhY8bwdbcwZakkYR4wcgaztWhY8bwNhRtJ1nWAgqrrELre0FzbxX8arfhekwdbcw7VtQUSLxzeb9xwWvmpquXhsW(TW6uWAhfRZJ6Mp(BrDkjKhmiuGylhHag1P1yKKc5aQ7NpO5nuVbwNlwhMK2G7LKLG40AmssH1PXA1fCfrqHZoWvv8HeSFlS2DSMDSopwdbcwZakkYRmIG(ll4kMhiQ4GqX60yndOOi)sqd0lJgEfMhiS2jwZowNgRBG1HjPn4QHm1AGSaeCAngjPWAiqWAgqrroLeYdg)T0uWqhY)1FlVcZdew7eRzhRZJ6Mp(BrDHBctcxX8arOaXwYTHag1P1yKKc5aQ7NpO5nuxrmGIIC)jVQal4sWkaCqOyneiyDdSMbuuK7hWcWVSGTQmqzWbHI1PX6WK0gCrAsCd8jcZyrijoTgJKuyDEu38XFlQNb4hz2VkuGyl5KraJ6Mp(Br9lbnqVmAqDAngjPqoGceBjZocyu38XFlQNb4hz2VkuNwJrskKdOafOa1tqt93IyJ92s2rBZrtABC2BR95e1ZSz)LvH6ocoMJNT2v2YX64WASgyaew)cqVjWAXBWAxxfjAGYW1fRhYreWFifwxNaH1gyCcwqkS2dWwwuXXnZX)LW6K64WAhr3cek0BcsH1Mp(BXAxxdmoylcZdKRlh3e3SDva6nbPWAxH1Mp(BXA5xrXXnr9ck5rS1Utg1HoN4lju31WAhBekS2rWM5Vb301WAaraTCCTAX6daGmC)j0QEbqPf)T(XeJw1l4BXipMwmIw7OOeTGoN4lPQLJCihV9QQLJ0Xd7iyZ83a7yJqXRxWJB6AyDNGgKadnyDY50nSM92s2rX62bRtozhh7TH1oMRpUjUPRH1TlaSLfvooCtxdRBhS2XuksH1osqbbsYXnDnSUDWAhtPifw7649XnPI1oEWcawRUSfRJdRfFPKgSodaTyn4AmscRJdR7staRBehwtR)ahJfH1oIbNuXAkjqPv9b4qyT4nynWufy9jI1U(plaHByTG9Rm18CCtxdRBhS2XuksH1oyrijSUd4adSooSg6q(tGXcS2XCK54CCtCtxdRDDMeYdgKcRziXBiS2FcmwG1meRFlow7yEpbnkSEVTDayJGiOeRnF83wy9TYu54MMp(Blo0H8NaJfofLwbeUP5J)2IdDi)jWyHloBjENc308XFBXHoK)eySWfNTmqwc0gw83IB6AyDFnOfGlW6XEfwZakkskSUclkSMHeVHWA)jWybwZqS(TWABvyn0HAhOxe)YcR)cRv3sCCtZh)Tfh6q(tGXcxC2QwdAb4c4kSOWnnF83wCOd5pbglCXzlglcjbxaoWa308XFBXHoK)eySWfNTGEXFlUjUPRH1Uotc5bdsH1ucAsfRJxGW6aaH1MpUbR)cRTe2lngjXXnnF83wo9aSHfHBA(4VTCXzlOGccKe308XFB5IZwgyCWweMhiCtZh)TLloBb9I)wCtZh)TLloBXiVtblcoP62l6urmGIIC)jVQal4sWkaCqO4MMp(BlxC2IHMIgG(LLBVOtfXakkY9N8QcSGlbRaWbHIBA(4VTCXzlB82sWXndTHBVOtfXakkY9N8QcSGlbRaWvx2M2FNuDzlx4MWKWvmpqeFib73kLK5Tp9ySi3BFB4MMp(BlxC2s(SaefCogqflbAd3ErNkIbuuK7p5vfybxcwbGRUSf308XFB5IZwI)qmY7uU9IovedOOi3FYRkWcUeScahekUP5J)2YfNTS1tvmMe2BsPBVOtfXakkY9N8QcSGlbRaWbHIBA(4VTCXzllHf242l60FNuDzl3FYRkWcUeScaFib73YDhfcKgHjPn4z2WmKbenCAngjPs7VtQUSLNzdZqgq0WhsW(TC3rZJBA(4VTCXzRkJiO)YcUI5bIk3ErNfuskHdByrrXZa8Jm7xvkjNUH)oP6YwoJ0uuf3iWhsW(Tsj52GaXFNuDzl3FYRkWcUeScaFib73kfhfcelhO5dIhufWNiSWZcqWP1yKKkpUP5J)2YfNTgWf28XFlS8RWT1eiNamVBVOZXEfmLG2GBkvXPK8vu4MMp(BlxC2AaxyZh)TWYVc3wtGCk(ji4Wgwu42l6SGssjCydlkkEgGFKz)QsjN4MMp(BlxC2AaxyZh)TWYVc3wtGCsjH8Gb52l6SrysAdUGvL5hItRXijv6WgwuWbqMmaWH6d3tA7Zdbsydlk4aitga4q9H7S3gUP5J)2YfNTgWf28XFlS8RWT1eiN1VSKeCydlkWnXnnF83wCkjKhmiNfqGszbv(rqJBVOZXyrU7Q2s3OH)oP6YwUImLmvyVjf4djy)wPK005YakkYvKPKPc7nPaheAEiqYnmjTbxrMsMkS3KcCAngjPYJBA(4VT4usipyqU4SLImLmvyVjfC7fD6VtQUSLZinfvXnc8HeSFRuCv6g(7KQlB5(tEvbwWLGva4djy)wUZoeinctsBWZSHzidiA40AmssL2FNuDzlpZgMHmGOHpKG9B5o75ZJBA(4VT4usipyqU4S1yjmw042l6mxgqrrUImLmvyVjf4Gqt3WFNuDzl3FYRkWcUeScaFib73YD2HaPrysAdEMnmdzardNwJrsQ0(7KQlB5z2WmKben8HeSFl3zpFECtZh)TfNsc5bdYfNT8N8QcSGlbRa42l6urmGIIC)jVQal4sWkaC1LT4MMp(BloLeYdgKloBLzdZqgq042l6urmGIIC)jVQal4sWkaC1LT4MMp(BloLeYdgKloBXinfvXncU9IohJf5EsBlDUmGIICfzkzQWEtkWbHIBA(4VT4usipyqU4SLxswcYTx0zbLKs4Wgwuu8ma)iZ(vLc74MMp(BloLeYdgKloBvstWTx0jdOOi3pGfGFzbBvzGYGdcf308XFBXPKqEWGCXzlHBctcxX8arU9IovedOOi3FYRkWcUeScaheAAgqrr(LGgOxgn8kmpqozpDJWK0gC1qMAnqwacoTgJKuqGWakkYPKqEW4VLMcg6q(V(B5vyEGCYEECtZh)TfNsc5bdYfNTUe0a9YOb308XFBXPKqEWGCXzlkjKhmiCtCtZh)Tfx8tqWHnSOWzbeOuwqLFe042l6CmwK7UQT0n83jvx2YvKPKPc7nPaFib73kLKcbsUHjPn4kYuYuH9MuGtRXijvECtZh)Tfx8tqWHnSOWfNTuKPKPc7nPGBVOt)Ds1LTCgPPOkUrGpKG9BLIRs3WFNuDzl3FYRkWcUeScaFib73YD2HaPrysAdEMnmdzardNwJrsQ0(7KQlB5z2WmKben8HeSFl3zpFECtZh)Tfx8tqWHnSOWfNTglHXIg3ErN5YakkYvKPKPc7nPaheA6g(7KQlB5(tEvbwWLGva4djy)wUZoeinctsBWZSHzidiA40AmssL2FNuDzlpZgMHmGOHpKG9B5o75ZJBA(4VT4IFccoSHffU4SL)KxvGfCjyfa3ErNkIbuuK7p5vfybxcwbGRUSf308XFBXf)eeCydlkCXzRmBygYaIg3ErNkIbuuK7p5vfybxcwbGRUSf308XFBXf)eeCydlkCXzlgPPOkUrWTx0jdOOiVYic6VSGRyEGOIRUSnDUmGIICfzkzQWEtkWbHMUrdfXakkY9N8QcSGlbRaWhsW(TsjN82NoxlhO5dIhufWNiSWZcqWP1yKKkpeimGII8GQa(eHfEwacoi084MMp(BlU4NGGdByrHloB5LKLGWnnF83wCXpbbh2WIcxC2Isc5bdYTx0zJCdtsBW9sYsqCAngjPsRUGRickC2bUQIpKG9B5o75HaPbdOOiVavkAHvKfa4dz(acegqrrEf3sWaiBc(qMpYNUbdOOiVYic6VSGRyEGOIdcfce)Ds1LT8kJiO)YcUI5bIk(qc2VvkoAECtZh)Tfx8tqWHnSOWfNTeUjmjCfZde52l6SrUHjPn4EjzjioTgJKuPvxWvebfo7axvXhsW(TCN98qGWakkYRmIG(ll4kMhiQ4GqtZakkYVe0a9YOHxH5bYj7PBeMK2GRgYuRbYcqWP1yKKccegqrroLeYdg)T0uWqhY)1FlVcZdKt2ZJBA(4VT4IFccoSHffU4SvgGFKz)QC7fDQigqrrU)KxvGfCjyfaoiuiqAWakkY9dyb4xwWwvgOm4GqthMK2GlstIBGpryglcjXP1yKKkpUP5J)2Il(ji4Wgwu4IZwxcAGEz0GBA(4VT4IFccoSHffU4SvgGFKz)QWnXnnF83wCaM35qRYTx05qc2VL7ovGJf)TUETXtA6g5o2RGPe0gCtPkoiuiqyaff5vgrq)LfCfZdevCqO5XnnF83wCaM3fNTkGaLYcQ8JGg3ErNJXIC3vTLUH)oP6YwUImLmvyVjf4djy)wPKuiqYnmjTbxrMsMkS3KcCAngjPYJBA(4VT4amVloBPitjtf2Bsb3ErNn83jvx2YzKMIQ4gb(qc2VvkUccKWK0g8XsySOHtRXijvA)Ds1LT8XsySOHpKG9BLIRYNUH)oP6YwU)KxvGfCjyfa(qc2VL7SdbsJWK0g8mBygYaIgoTgJKuP93jvx2YZSHzidiA4djy)wUZE(84MMp(BloaZ7IZwJLWyrJBVOZgJ9kykbTb3uQIdcfcKXEfmLG2GBkvX)nLWgwuWJxGGJdw9u(0n83jvx2Y9N8QcSGlbRaWhsW(TCNDiqAeMK2GNzdZqgq0WP1yKKkT)oP6YwEMnmdzardFib73YD2ZNh308XFBXbyExC2YFYRkWcUeScGBVOZXEfmLG2GBkvXbHcbYyVcMsqBWnLQ4)MsoBdcKgJ9kykbTb3uQI)BkS3w6WK0gCBzrdSGTglsG2GtRXijvECtZh)TfhG5DXzRmBygYaIg3ErNJ9kykbTb3uQIdcfcKXEfmLG2GBkvX)nLC2geing7vWucAdUPuf)3uyVT0HjPn42YIgybBnwKaTbNwJrsQ84MMp(BloaZ7IZwmstrvCJGBVOZgkIbuuK7p5vfybxcwbGdcn9yVcMsqBWnLQ4)Msydlk4XlqWXbREkpeiJ9kykbTb3uQIdcnDJgkIbuuK7p5vfybxcwbGpKG9BLso5TpDUwoqZhepOkGpryHNfGGtRXijvEiqyaff5bvb8jcl8SaeCqO5XnnF83wCaM3fNTUe0a9YOXTx0zUJ9kykbTb3uQIdcfcKgJ9kykbTb3uQIdcnTLd08bXl6lH3dNzjioTgJKu5XnnF83wCaM3fNT8sYsqU9IolOKuch2WIIINb4hz2VQuyh308XFBXbyExC2Isc5bdYTx0zUJ9kykbTb3uQIdcfcKg5gMK2G7LKLG40AmssLwDbxreu4SdCvfFib73YD2ZdbcdOOiVavkAHvKfa4dz(a308XFBXbyExC2s4MWKWvmpqKBVOZCh7vWucAdUPufhekeinYnmjTb3ljlbXP1yKKkT6cUIiOWzh4Qk(qc2VL7SNh308XFBXbyExC2kdWpYSFvU9Ioh7vWucAdUPufhekUP5J)2IdW8U4S1LGgOxgn4MMp(BloaZ7IZwza(rM9RYTx0zysAdUinjUb(eHzSiKeNwJrskCtZh)TfhG5DXzRsAcU9IoZnmjTbxKMe3aFIWmwesItRXijv6Ch7vWucAdUPufhekUP5J)2IdW8U4SvI3h3Kk8awaC7fDM7yVcMsqBWnLQ4GqXnXnnF83w86xwscoSHffohAvU9IohsW(TC3PcCS4V11RnEstRigqrrU)KxvGfCjyfaU6YwCtZh)TfV(LLKGdByrHloBvabkLfu5hbnU9IohJf5URAlDd)Ds1LTCfzkzQWEtkWhsW(TsjPqGKBysAdUImLmvyVjf40AmssLh308XFBXRFzjj4Wgwu4IZwkYuYuH9MuWTx0zd)Ds1LTCgPPOkUrGpKG9BLIRGajmjTbFSeglA40AmssL2FNuDzlFSeglA4djy)wP4Q8PB4VtQUSL7p5vfybxcwbGpKG9B5o7qG0imjTbpZgMHmGOHtRXijvA)Ds1LT8mBygYaIg(qc2VL7SNppUP5J)2Ix)YssWHnSOWfNTglHXIg3ErN5YakkYvKPKPc7nPaheA6g(7KQlB5(tEvbwWLGva4djy)wUZoeinctsBWZSHzidiA40AmssL2FNuDzlpZgMHmGOHpKG9B5o75ZJBA(4VT41VSKeCydlkCXzl)jVQal4sWkaU9IovedOOi3FYRkWcUeScaxDzlUP5J)2Ix)YssWHnSOWfNTYSHzidiAC7fDQigqrrU)KxvGfCjyfaU6YwCtZh)TfV(LLKGdByrHloBrjH8Gb52l6KbuuKxGkfTWkYca8HmFGBA(4VT41VSKeCydlkCXzlgPPOkUrWTx0P)oP6YwUWnHjHRyEGi(qc2Vv6gnuedOOi3FYRkWcUeScaheA6CTCGMpiEqvaFIWcplabNwJrsQ8qGWakkYdQc4tew4zbi4GqZJBA(4VT41VSKeCydlkCXzlVKSeKBVOZckjLWHnSOO4za(rM9Rkf2XnnF83w86xwscoSHffU4S1LGgOxgnU9IoTCGMpiErFj8E4mlbXhBbYzsXnnF83w86xwscoSHffU4SLWnHjHRyEGiCtZh)TfV(LLKGdByrHloBDjOb6LrdUP5J)2Ix)YssWHnSOWfNTYa8Jm7xLBVOZWK0gCrAsCd8jcZyrijoTgJKuPBKRLd08bXdQc4tew4zbi40AmssbbsJXyrP40vTbbIIyaff5(tEvbwWLGva4GqHaHbuuKRitjtf2Bsboi085XnnF83w86xwscoSHffU4Svjnb3ErN5gMK2GlstIBGpryglcjXP1yKKkDJCTCGMpiEqvaFIWcplabNwJrskiqAmglkfNUQniquedOOi3FYRkWcUeScahekeimGIICfzkzQWEtkWbHMppUP5J)2Ix)YssWHnSOWfNTs8(4MuHhWcakqbcba]] )


end
