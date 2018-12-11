-- WarriorProtection.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 73 )

    spec:RegisterResource( Enum.PowerType.Rage )
    
    -- Talents
    spec:RegisterTalents( {
        into_the_fray = 15760, -- 202603
        punish = 15759, -- 275334
        impending_victory = 15774, -- 202168

        crackling_thunder = 22373, -- 203201
        bounding_stride = 22629, -- 202163
        safeguard = 22409, -- 223657

        best_served_cold = 22378, -- 202560
        unstoppable_force = 22626, -- 275336
        dragon_roar = 23260, -- 118000

        indomitable = 23096, -- 202095
        never_surrender = 23261, -- 202561
        bolster = 22488, -- 280001

        menace = 22384, -- 275338
        rumbling_earth = 22631, -- 275339
        storm_bolt = 22800, -- 107570

        booming_voice = 22395, -- 202743
        vengeance = 22544, -- 202572
        devastator = 22401, -- 236279

        anger_management = 21204, -- 152278
        heavy_repercussions = 22406, -- 203177
        ravager = 23099, -- 228920
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3595, -- 208683
        relentless = 3594, -- 196029
        adaptation = 3593, -- 214027

        oppressor = 845, -- 205800
        disarm = 24, -- 236077
        sword_and_board = 167, -- 199127
        bodyguard = 168, -- 213871
        leave_no_man_behind = 169, -- 199037
        morale_killer = 171, -- 199023
        shield_bash = 173, -- 198912
        thunderstruck = 175, -- 199045
        ready_for_battle = 3063, -- 253900
        warpath = 178, -- 199086
        dragon_charge = 831, -- 206572
        mass_spell_reflection = 833, -- 213915
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
        charge = {
            id = 105771,
            duration = 1,
            max_stack = 1,
        },
        deep_wounds = {
            id = 115768,
            duration = 19.5,
            max_stack = 1,
        },
        demoralizing_shout = {
            id = 1160,
            duration = 8,
            max_stack = 1,
        },
        devastator = {
            id = 236279,
        },
        dragon_roar = {
            id = 118000,
            duration = 6,
            max_stack = 1,
        },
        ignore_pain = {
            id = 190456,
            duration = 12,
            max_stack = 1,
        },
        intimidating_shout = {
            id = 5246,
            duration = 12,
            max_stack = 1,
        },
        into_the_fray = {
            id = 202602,
            duration = 3600,
            max_stack = 2,
        },
        kakushans_stormscale_gauntlets = {
            id = 207844,
            duration = 3600,
            max_stack = 1,
        },
        last_stand = {
            id = 12975,
            duration = 15,
            max_stack = 1,
        },
        punish = {
            id = 275335,
            duration = 9,
            max_stack = 1,
        },
        rallying_cry = {
            id = 97463,
            duration = 10,
            max_stack = 1,
        },
        ravager = {
            id = 228920,
            duration = 12,
            max_stack = 1,
        },
        revenge = {
            id = 5302,
            duration = 6,
            max_stack = 1,
        },
        shield_block = {
            id = 132404,
            duration = 7,
            max_stack = 1,
        },
        shield_wall = {
            id = 871,
            duration = 8,
            max_stack = 1,
        },
        shockwave = {
            id = 132168,
            duration = 2,
            max_stack = 1,
        },
        spell_reflection = {
            id = 23920,
            duration = 5,
            max_stack = 1,
        },
        storm_bolt = {
            id = 132169,
            duration = 2,
            max_stack = 1,
        },
        taunt = {
            id = 355,
            duration = 3,
            max_stack = 1,
        },
        thunder_clap = {
            id = 6343,
            duration = 10,
            max_stack = 1,
        },
        vanguard = {
            id = 71,
        },
        vengeance_ignore_pain = {
            id = 202574,
            duration = 15,
            max_stack = 1,
        },
        vengeance_revenge = {
            id = 202573,
            duration = 15,
            max_stack = 1,
        },


        -- Azerite Powers
        bastion_of_might = {
            id = 287379,
            duration = 20,
            max_stack = 1,
        },
        
        intimidating_presence = {
            id = 288644,
            duration = 12,
            max_stack = 1,
        },


    } )


    -- model rage expenditure reducing CDs...
    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "rage" then
            if talent.anger_management.enabled and amt >= 10 then
                local secs = floor( amt / 10 )

                cooldown.avatar.expires = cooldown.avatar.expires - secs
                cooldown.last_stand.expires = cooldown.last_stand.expires - secs
                cooldown.shield_wall.expires = cooldown.shield_wall.expires - secs
                cooldown.demoralizing_shout.expires = cooldown.demoralizing_shout.expires - secs
            end

            if level < 116 and equipped.mannoroths_bloodletting_manacles and amt >= 10 then
                local heal = 0.01 * floor( amt / 10 )
                gain( heal * health.max, "health" )
            end
        end
    end )


    spec:RegisterGear( 'tier20', 147187, 147188, 147189, 147190, 147191, 147192 )
    spec:RegisterGear( 'tier21', 152178, 152179, 152180, 152181, 152182, 152183 )

    spec:RegisterGear( "ararats_bloodmirror", 151822 )
    spec:RegisterGear( "archavons_heavy_hand", 137060 )
    spec:RegisterGear( "ayalas_stone_heart", 137052 )
        spec:RegisterAura( "stone_heart", { id = 225947,
            duration = 10
        } )
    spec:RegisterGear( "ceannar_charger", 137088 )
    spec:RegisterGear( "destiny_driver", 137018 )
    spec:RegisterGear( "kakushans_stormscale_gauntlets", 137108 )
    spec:RegisterGear( "kazzalax_fujiedas_fury", 137053 )
        spec:RegisterAura( "fujiedas_fury", {
            id = 207776,
            duration = 10,
            max_stack = 4 
        } )
    spec:RegisterGear( "mannoroths_bloodletting_manacles", 137107 )
    spec:RegisterGear( "najentuss_vertebrae", 137087 )
    spec:RegisterGear( "soul_of_the_battlelord", 151650 )
    spec:RegisterGear( "the_great_storms_eye", 151823 )
        spec:RegisterAura( "tornados_eye", {
            id = 248142, 
            duration = 6, 
            max_stack = 6
        } )
    spec:RegisterGear( "the_walls_fell", 137054 )
    spec:RegisterGear( "thundergods_vigor", 137089 )
    spec:RegisterGear( "timeless_stratagem", 143728 )
    spec:RegisterGear( "valarjar_berserkers", 151824 )
    spec:RegisterGear( "weight_of_the_earth", 137077 ) -- NYI.

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
            
            handler = function ()
                applyBuff( "avatar" )
                if azerite.bastion_of_might.enabled then
                    applyBuff( "bastion_of_might" )
                    applyBuff( "ignore_pain" )
                end
            end,
        },
        

        battle_shout = {
            id = 6673,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            essential = true, -- new flag, will prioritize using this in precombat APL even in combat.

            startsCombat = false,
            texture = 132333,
            
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
            
            defensive = true,

            startsCombat = false,
            texture = 136009,
            
            handler = function ()
                applyBuff( "berserker_rage" )
            end,
        },
        

        demoralizing_shout = {
            id = 1160,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            spend = function () return talent.booming_voice.enabled and -40 or 0 end,
            spendType = "rage",

            startsCombat = true,
            texture = 132366,
            
            handler = function ()
                applyDebuff( "target", "demoralizing_shout" )
                active_dot.demoralizing_shout = max( active_dot.demoralizing_shout, active_enemies )
            end,
        },
        

        devastate = {
            id = 20243,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135291,

            notalent = "devastator",
            
            handler = function ()
                applyDebuff( "target", "deep_wounds" )

                if level < 116 and equipped.kakushans_stormscale_gauntlets then
                    applyBuff( "kakushans_stormscale_gauntlets" )
                end
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
                active_dot.dragon_roar = max( active_dot.dragon_roar, active_enemies )
            end,
        },
        

        heroic_leap = {
            id = 6544,
            cast = 0,
            charges = function () return ( level < 116 and equipped.timeless_stratagem ) and 3 or nil end,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            recharge = function () return talent.bounding_stride.enabled and 30 or 45 end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236171,
            
            handler = function ()
                setDistance( 5 )
                setCooldown( "taunt", 0 )

                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
            end,
        },
        

        heroic_throw = {
            id = 57755,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132453,
            
            handler = function ()
            end,
        },
        

        ignore_pain = {
            id = 190456,
            cast = 0,
            cooldown = 0,
            gcd = "off",
            
            spend = function () return ( buff.vengeance_ignore_pain.up and 0.67 or 1 ) * 40 end,
            spendType = "rage",
            
            startsCombat = false,
            texture = 1377132,
            
            ready = function () return action.ignore_pain.lastCast + 1 - query_time end,
            handler = function ()
                if talent.vengeance.enabled then applyBuff( "vengeance_revenge" ) end
                removeBuff( "vengeance_ignore_pain" )

                applyBuff( "ignore_pain" )
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
            end,
        },
        

        intercept = {
            id = 198304,
            cast = 0,
            charges = 2,
            cooldown = 15,
            recharge = 15,
            gcd = "spell",

            spend = -15,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132365,
            
            usable = function () return target.distance > 10 end,
            handler = function ()
                applyDebuff( "target", "charge" )
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
                active_dot.intimidating_shout = max( active_dot.intimidating_shout, active_enemies )
                if azerite.intimidating_presence.enabled then applyDebuff( "target", "intimidating_presence" ) end
            end,
        },
        

        last_stand = {
            id = 12975,
            cast = 0,
            cooldown = function () return talent.bolster.enabled and 120 and 180 end,
            gcd = "spell",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = true,
            texture = 135871,
            
            handler = function ()
                applyBuff( "last_stand" )
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
            interrupt = true,

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
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 132351,
            
            handler = function ()
                applyBuff( "rallying_cry" )
                gain( 0.15 * health.max, "health" )
                health.max = health.max * 1.15
            end,
        },
        

        ravager = {
            id = 228920,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = false,
            texture = 970854,

            talent = "ravager",
            
            handler = function ()
                applyBuff( "ravager" )
            end,
        },
        

        revenge = {
            id = 6572,
            cast = 0,
            cooldown = 3,
            hasteCD = true,
            gcd = "spell",
            
            spend = function ()
                if buff.revenge.up then return 0 end
                return buff.vengeance_revenge.up and 20 or 30
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132353,

            handler = function ()
                if talent.vengeance.enabled then applyBuff( "vengeance_ignore_pain" ) end
                
                if buff.revenge.up then removeBuff( "revenge" )
                else removeBuff( "vengeance_revenge" ) end

                applyDebuff( "target", "deep_wounds" )
            end,
        },
        

        shield_block = {
            id = 2565,
            cast = 0,
            charges = function () return ( level < 116 and equipped.ararats_bloodmirror ) and 3 or 2 end,
            cooldown = 16,
            recharge = 16,
            hasteCD = true,
            gcd = "off",

            toggle = "defensives",
            defensive = true,
            
            spend = 30,
            spendType = "rage",
            
            startsCombat = false,
            texture = 132110,
            
            handler = function ()
                applyBuff( "shield_block" )
            end,
        },
        

        shield_slam = {
            id = 23922,
            cast = 0,
            cooldown = 9,
            hasteCD = true,
            gcd = "spell",

            spend = function () 
                return ( buff.kakushans_stormscale_gauntlets.up and 1.2 or 1 ) * ( ( level < 116 and equipped.the_walls_fell ) and -17 or -15 )
            end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 134951,
            
            handler = function ()
                if talent.heavy_repercussions.enabled and buff.shield_block.up then
                    buff.shield_block.expires = buff.shield_block.expires + 1
                end

                if talent.punish.enabled then applyDebuff( "target", "punish" ) end

                if level < 116 and equipped.the_walls_fell then
                    setCooldown( "shield_wall", cooldown.shield_wall.remains - 4 )
                end

                removeBuff( "kakushans_stormscale_gauntlets" )
            end,
        },
        

        shield_wall = {
            id = 871,
            cast = 0,
            cooldown = 240,
            gcd = "spell",
            
            toggle = "defensives",
            defensive = true,

            startsCombat = false,
            texture = 132362,
            
            handler = function ()
                applyBuff( "shield_wall" )
            end,
        },
        

        shockwave = {
            id = 46968,
            cast = 0,
            cooldown = function () return ( talent.rumbling_earth.enabled and active_enemies >= 3 ) and 25 or 40 end,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236312,
            
            handler = function ()
                applyDebuff( "target", "shockwave" )
                active_dot.shockwave = max( active_dot.shockwave, active_enemies )
            end,
        },
        

        spell_reflection = {
            id = 23920,
            cast = 0,
            charges = function () return ( level < 116 and equipped.ararats_bloodmirror ) and 2 or nil end,
            cooldown = 25,
            recharge = 25,
            gcd = "off",

            defensive = true,
            
            startsCombat = false,
            texture = 132361,
            
            handler = function ()
                applyBuff( "spell_reflection" )
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
        

        thunder_clap = {
            id = 6343,
            cast = 0,
            cooldown = function () return haste * ( ( buff.avatar.up and talent.unstoppable_force.enabled ) and 3 or 6 ) end,
            gcd = "spell",

            spend = function () return ( buff.kakushans_stormscale_gauntlets.up and 1.2 or 1 ) * -5 end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 136105,
            
            handler = function ()
                applyDebuff( "target", "thunder_clap" )
                active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )

                if level < 116 and equipped.thundergods_vigor then
                    setCooldown( "demoralizing_shout", cooldown.demoralizing_shout.remains - ( 3 * active_enemies ) )
                end

                removeBuff( "kakushans_stormscale_gauntlets" )
            end,
        },
        

        victory_rush = {
            id = 34428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132342,

            buff = "victorious",
            
            handler = function ()
                removeBuff( "victory_rush" )
                gain( 0.2 * health.max, "health" )
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

        package = "Protection Warrior",
    } )


    spec:RegisterPack( "Protection Warrior", 20181108.0016, [[di0jraqifOYJujXMGunkvQCkvQAvqkEfQWSqfDlvk7sf)sHmmfLJrkwMkXZuOmniGRPa2Mcv9niLghe05uGyDqGMNkP6EaSpfXbvjPwOIQlQajnsfOQtQskwjQ0nvGu7ubnuvsYtfAQKkBvbs8vvsP9k6VQQblPdtSybEmOjRkxgzZqYNrvJwqNMYRHqnBsUnq7wQFR0WHOLlXZrz6uDDaTDsPVtQA8qiNxHkRxbkZxrA)qDQj1LXN4uo8YmniuJMzi8mBMg0odTz0hhskJifiIfEkJTasz8QkRtq32gxVwPuSTKrKY4uR8sDzKTalqkJHUJKHGJgPxV(Jbh3nTK1SdCbhPF1pczzDc62230lLITLBi1s3CPr8TY6IBBFdUR6T6B2njWuMBelJbanLFnDgKXN4uo8YmniuJMzi8mBMMXFbTzKHKG5q0owgdT3J6miJpIbZ4vW1RQSobDBBC9ALsX2cM7vW1q3rYqWrJ0Rx)XGJ7MwYA2bUGJ0V6hHSSobDB7B6LsX2YnKAPBU0i(wzDXTTVb3v9w9n7MeykZnIH5EfCD4QLadOcUIqoX1lZ0GqC9gUQ5ccQz846vpOZiYYIYuugVcUEvL1jOBBJRxRuk2wWCVcUg6osgcoAKE96pgCC30swZoWfCK(v)iKL1jOBBFtVuk2wUHulDZLgX3kRlUT9n4UQ3QVz3KatzUrmm3RGRdxTeyavWveYjUEzMgeIR3WvnxqqnJhxV6bnMlM7vW1bverqGo9W1ac1wiCfUGbIJRbeV1SdUE1qiH0z4AV9TqPaIcOcxfOBBZW1TvJ7G5kq32MDqwi4cgioGaXDf9zHlqhZfZvGUTn7a3v9w9ndaqg9nNazyUc0TTzh4UQ3QVzCayKOvCPG5I5kq32MDan34f32gal0i17hOwiI50qbagkfEI9rveOBBlQjAoiC6uRHlO18)Nak80Fa2KzNlOjKeLhEafeH5kq32MDan34f32MdaJm(El0hPynNgkabarH6Wcns9(bQfI4ZB13OhaefQJX3BH(ifRpVvFJ(DfHNoiH(Kb5Y0P3fsIYdpqGLc1(1NDgdnHKO8WdOGOPtTgUGwZ)FcOWt)bytMDUGMqsuE4buq093J5kq32MDan34f32MdaJEe4weLnywZ)zHlqNtdfaRHlO18)Nak80Fa2KzNlOjKeLhEafeH(DfHNopcLbn)6iWSPthCUOO2pb7cAn)x7Aq6qTeOO39OFxWYytNkq30sFQjqJyt0CpMRaDBB2b0CJxCBBoamIfAK691lkfNgkawdxqR5)pbu4P)aSjHKO8WdeyPqTJ5kq32MDan34f32MdaJucZ)mx6hNgkaHKO8WdeyPqTF9zNXqtijkp8akicZfZvGUTn7WSMxraEe4weLnywZ)zHlqNtdfaxuu7NGDbTM)RDniDOwcu0d97cwgB6ub6Mw6tnbAeBIM7rhUR6T67JOvCPCkeOynBYyyUc0TTzhM18kIdaJyHgPEFMsaXCfOBBZomR5vehagzTtfiH050qbagkfEI9rveOBBlQjAoODa0TgUGwZ)FcOWt)XyaMH5kq32MDywZRioamYdb2pQ8HkbjMRaDBB2HznVI4aWOcPLAEItdfGaGOqDkKwQ5PdqKtNExaquOogFVf6JuS(aej6fHNoiH(Kb5Y9yUc0TTzhM18kIdaJEKwH5ItyUyUc0TTzhzjaSqJuVptjGCAOaiq30sFQjqJyaUGEaquOoSqJuVFGAHi(aejMRaDBB2rwIdaJ8qG9JkFOsqI5kq32MDKL4aWOxr43(xwPG5kq32MDKL4aWOcPLAEcZvGUTn7ilXbGrSqJuVptjGyUc0TTzhzjoam6rAfMloH5I5kq32MbajqqqsH5kq32MXbGrqrP(c0TT)kJ5C2ciba0CJxCBBmxb622moamckk1xGUT9xzmNZwajaWDvVvFZWCfOBBZ4aWiRDQajKoNgkaWqPWtSpQIaDBBrnrZbTdGUlfEYppJ5sdPjOfZvGUTnJdaJka7VaDB7VYyoNTasaywZRionuaeOBAPp1eOrmaAWCfOBBZ4aWOcW(lq32(RmMZzlGeazjonuaeOBAPp1eOrSjAYOwQWSTZHxMPbHZgKXMDUmMMbYOEP0wZZY41aIClo9W1XJRc0TTXvLXC2bZnJcqpClzCWti2ugN4AGWOhUUnUEnWXDBqHSMLrLXCwQlJmR5vuQlhQj1LrQLaf9Y5zewmNkMKrxuu7NGDbTM)RDniDOwcu0dxrhxVdxdwgdxNofxfOBAPp1eOrmCDcUQbxVhxrhxH7QER((iAfxkNcbkwZW1j46yzuGUTDgFe4weLnywZ)zHlqp9C4LuxgfOBBNrwOrQ3NPeWmsTeOOxop9C4yPUmsTeOOxopJWI5uXKmcdLcpX(Okc0TTffUobx1Cq7a4k64Q1Wf0A()tafE6pgdxbGRZYOaDB7mATtfiH0tphIaPUmkq32oJEiW(rLpujiZi1sGIE580ZHdK6Yi1sGIE58mclMtftYyaquOofsl180bisCD6uC9oCnaikuhJV3c9rkwFaIexrhxlcpDqcDCDcUoixW17ZOaDB7mwiTuZtPNdhFQlJc0TTZ4J0kmxCkJulbk6LZtp9m(iucqLN6YHAsDzuGUTDgrceeKuzKAjqrVCE65WlPUmsTeOOxopJc0TTZiuuQVaDB7VYyEgvgZ)Tasze0CJxCB70ZHJL6Yi1sGIE58mkq32oJqrP(c0TT)kJ5zuzm)3ciLr4UQ3QVzPNdrGuxgPwcu0lNNryXCQysgHHsHNyFufb622IcxNGRAoODaCfDC1Lcp5NNXCPHeUobxrBgfOBBNrRDQajKE65WbsDzKAjqrVCEgHfZPIjzuGUPL(utGgXWva4QMmkq32oJfG9xGUT9xzmpJkJ5)waPmYSMxrPNdhFQlJulbk6LZZiSyovmjJc0nT0NAc0igUobx1Krb622zSaS)c0TT)kJ5zuzm)3ciLrzP0tpJileCbdep1Ld1K6YOaDB7mgiUROplCb6zKAjqrVCE6PNrqZnEXTTtD5qnPUmsTeOOxopJWI5uXKmcdLcpX(Okc0TTffUobx1CqiUoDkUAnCbTM))eqHN(dWW1j46SZfCfn4Aijkp8akikJc0TTZil0i17hOwiItphEj1LrQLaf9Y5zewmNkMKXaGOqDyHgPE)a1cr85T6BCfDCnaikuhJV3c9rkwFER(gxrhxVdxlcpDqcDCDcUoixW1PtX17W1qsuE4bcSuO2X1RJRZoJHRObxdjr5Hhqbr460P4Q1Wf0A()tafE6padxNGRZoxWv0GRHKO8WdOGiC9EC9(mkq32oJgFVf6JuSo9C4yPUmsTeOOxopJWI5uXKmAnCbTM))eqHN(dWW1j46SZfCfn4Aijkp8akicxrhxVdxlcpDEekdAoUEDCfbMHRtNIRdoC1ff1(jyxqR5)AxdshQLaf9W17Xv0X17W1GLXW1PtXvb6Mw6tnbAedxNGRAW17ZOaDB7m(iWTikBWSM)ZcxGE65qei1LrQLaf9Y5zewmNkMKrRHlO18)Nak80FagUobxdjr5HhiWsHApJc0TTZil0i17RxuQ0ZHdK6Yi1sGIE58mclMtftYyijkp8abwku7461X1zNXWv0GRHKO8WdOGOmkq32oJkH5FMl9l90ZOSuQlhQj1LrQLaf9Y5zewmNkMKrb6Mw6tnbAedxbGRxWv0X1aGOqDyHgPE)a1cr8biYmkq32oJSqJuVptjGPNdVK6YOaDB7m6Ha7hv(qLGmJulbk6LZtphowQlJc0TTZ4Ri8B)lRuYi1sGIE580ZHiqQlJc0TTZyH0snpLrQLaf9Y5PNdhi1Lrb622zKfAK69zkbmJulbk6LZtpho(uxgfOBBNXhPvyU4ugPwcu0lNNE6zeUR6T6BwQlhQj1Lrb622zeiJ(MtGSmsTeOOxop9C4LuxgfOBBNrrR4sjJulbk6LZtp90tp9mb]] )


end
