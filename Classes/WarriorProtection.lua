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

            -- toggle = "defensives", -- should probably be a defensive...
            
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

            toggle = "defensives",
            
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
                setDistance( 5 )
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

            debuff = "casting",
            readyTime = state.timeToInterrupt,

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


    spec:RegisterPack( "Protection Warrior", 20190201.0042, [[dqukyaqiOIEeKuBcLyuqQofKYQqPIxbjMLsIBHsAxQYVOidJI6yQQAzQQ8mOsMMsixtjPTbjrFdLknoij15ucSoLGAEOu19GI9Hs5GkHYcvv8qLq1fHKqBuvjvNescwjuAMQkPCtvLe7ujAOkb5PkmvH0xHKK9k1FbmyuDyslgIhtyYk1Lr2SaFgOrluNwYQvvs61Qk1Sj62Oy3I(TkdNclNspxrtNQRlOTleFxj14vvIZdvy9qLA(qv7h09)oAp2Qt9YFM)VaZ)m)7z28I(Vk72dhhgupmuX3ki1JuzOESq2ZjHxxc5Ok1ARZ2ddfhYt3D0EmVqRG6rS7gZf2KjWYJdrEIJX0SycLQxxkSAGBAwmctiYdXesGY6MIyYWEbLKMMIwK93ptr)9davPwBDwGfYEoj86Y3Sye9ajSKoQq2i9yRo1l)z()cm)Z8VNzZl6)QOYEmnirVKDXvpIR9MYgPhBAk6bQH8fYEoj86sihvPwBDwiwud5XUBmxytMwVE9Re4G1iuLZN4ymT(wBYWEoj86swxRwBDwwnIqS6A(nR2ZvVUKvXDY9ToNSQiLS8IMqSOgY)6eInuT4aY)TcK)Z8)fa5Sc5MnVWMxaelelQH8fpwtqAcXIAiNviFX2Bi)RuEbQEDjKlpWsa5(b5jTgYhfZId5l2c91EqSOgYzfY3eZzvzH7kbbMXxOdSjKWGaiNv2G8nXCwvw4UsqGz8f69WWEbLK6bQH8fYEoj86sihvPwBDwiwud5XUBmxytMwVE9Re4G1iuLZN4ymT(wBYWEoj86swxRwBDwwnIqS6A(nR2ZvVUKvXDY9ToNSQiLS8IMqSOgY)6eInuT4aY)TcK)Z8)fa5Sc5MnVWMxaelelQH8fpwtqAcXIAiNviFX2Bi)RuEbQEDjKlpWsa5(b5jTgYhfZId5l2c91EqSOgYzfY3eZzvzH7kbbMXxOdSjKWGaiNv2G8nXCwvw4UsqGz8f6qSqSOgYrf)cjcDAd5iuWzjixCmiQd5ieyLZhKVycbz4tipVK1y1YeekHCv41Lti)sjoEqSQWRlNpdljoge1Xei153qSQWRlNpdljoge1rbJPG72qSQWRlNpdljoge1rbJjneKHsx96siwud5JunMXNd5wT2qosyqaTH8PR(eYrOGZsqU4yquhYriWkNqUMBi3WsSACUxjiKxtiFFj9GyvHxxoFgwsCmiQJcgtiQ7scygFHoeRk86Y5ZWsIJbrDuWyAMQXm(CGPR(eIvfED58zyjXXGOokymzCEDjelelQHCuXVqIqN2qofHS4aY9IHGCpMGCv4NfYRjKRr0sQis6bXQcVUCIXiKHHKqSQWRlNOGXuLozfKHdXQcVUCIcgtHtcOCIzLuzimwLXOsqaLXqwE4MaalqnYjDakbRKGyvHxxorbJPWjbuoXmHyvHxxorbJje5DBGGqloGyvHxxorbJjeYoj73vccXQcVUCIcgtQvOjb4N1sPdXQcVUCIcgtYcm2NaF1WnidLoeRk86YjkymfuwcrE3gIvfED5efmM0uqt3QsaHkLqSQWRlNOGXKqLsav41LaYA6RKkdHXWEoeleRk86Y5JP8cu96smZ4IKBae5j(ELkad640vjL(d5KtNSpkvejTXJhNiHbbpPoDGPR5(fAGglOlIvlinbcSQWRlvjB)FOA84RuCmvccSvgfKawDYM53p2jMuPh)y0VGgeRk86Y5JP8cu96suWyQaZZsagALRubyqcdcEZ4IKBae5j((TV1jliHbbVcmplbyOv(236Kf0Tki9meoBl4hE8OhtQ0JFgcN94YmE8vkoMkbb2kJcsaRozZ87h7etQ0JFm6xqdniwv41LZht5fO61LOGX0MyoRklCxjiWm(c9vQamO7QfK836YJR8Vz84vHxriakjMIMS9hnwqh9kfhtLGaBLrbjGvNSz(9JDIjv6Xpg9l4XhtQ0JFgcN94YmA4XJooDvsP)qUJPsqGixjOhLkIK24XBvq6XOFHvRcsSFrMrdniwv41LZht5fO61LOGXKuNoW01CVsfGjMuPh)meo7XLziwv41LZht5fO61LOGX0mUi5gyTkLRubyQuCmvccSvgfKawDYwmPspgp(ysLE8Zq4S)Nziwiwv41LZNH9CmgHmmKeIvfED58zyphfmMmoVUCLkaJxmeGFa7Iy)VvHyvHxxoFg2ZrbJjnI6QDLkad6I7K7BD(2eZzvzH7kbbMXxO)SKUXbE8I7K7BD(2eZzvzH7kbbMXxO)SeJw5KTFObXQcVUC(mSNJcgtcvkbuHxxciRPVsQmegMYlq1RlxPcWuP4yQeeyRmkibS6KnZqSQWRlNpd75OGX0MyoRklCxjiWm(c9vQamUAbj)TU84k)BgpEv4vecGsIPOjB)HyvHxxoFg2ZrbJjRgrbjleRk86Y5ZWEokymTTk4La2tTqSQWRlNpd75OGXKhhMBYciKQXkvag0DvsP)cZPFggkIKacoRGEuQisAZcsyqWtJOUAFHgSSjKWGG3MyoRklCxjiWm(c9xObAqSQWRlNpd75OGX0mUi5garEIVxPcWGU4o5(wNVzCrYnWuQmplPBCWcsyqWBgxKCdGipX3V9Tozbjmi4j1PdmDn3V9TordIvfED58zyphfmMkW8SeGHw5kvagxZVReKfKWGG3mUi5garEIVF7BDcXQcVUC(mSNJcgtZ4IKBGPuzGyvHxxoFg2ZrbJjpom3Kfqivdiwv41LZNH9CuWyYsrOeKwPcWGooDvsP)IqjiPPGEuQisAJgE8O7QKs)fHsqstb9OurK0MfKWGGNLIqji9SKkCwWjsyqWlcLGKMccOaZZsagALVqd0WJhDKWGGxekbjnfeGLIqji9cnqdpE0DvsP)IqjiPPGEuQisAZcorcdcErOeK0uqafyEwcWqR8fAWcorcdcErOeK0uqawkcLG0l0GfRcsSHbxMrdIvfED58zyphfmMkW8SeGHw5kHtc4ccaafBm)xPcWyvqIn21meRk86Y5ZWEokymTPi60vN6reYoRl7L)m)FbM)B(37N5fTGESwTzLGZEGkWyCwN2q(IGCv41LqUSM(8bX2dn0JpBpgftOu96Yf3QbEpK10ND0EWuEbQEDzhTx(VJ2dkvejT7p9qylNSL2d0HCCc5UkP0FiNC6K9rPIiPnKJhpKJtihjmi4j1PdmDn3VqdihniNfihDixeRwqAceyvHxxQsiNni))dvd54Xd5vkoMkbb2kJcsaRoHC2GCZVFqo7a5XKk94hJ(fihTEOcVUShZ4IKBae5j(U9E5VoApOurK0U)0dHTCYwApqcdcEZ4IKBae5j((TV1jKZcKJege8kW8SeGHw5BFRtiNfihDi3QG0Zq4qoBq(c(b54Xd5Od5XKk94NHWHC2d54YmKJhpKxP4yQeeyRmkibS6eYzdYn)(b5SdKhtQ0JFm6xGC0GC06Hk86YEuG5zjadTY27L4QJ2dkvejT7p9qylNSL2d0HCxTGK)wxECL)nd54Xd5QWRieaLetrtiNni)pKJgKZcKJoKJoKxP4yQeeyRmkibS6eYzdYn)(b5SdKhtQ0JFm6xGC84H8ysLE8Zq4qo7HCCzgYrdYXJhYrhYXjK7QKs)HChtLGarUsqpkvejTHC84HCRcspg9lqoRqUvbjiN9q(Imd5Ob5O1dv41L9ytmNvLfUReeygFHE79Yf1r7bLkIK29NEiSLt2s7rmPsp(ziCiN9qoUm3dv41L9qQthy6AUBVxUAhThuQisA3F6HWwozlThvkoMkbb2kJcsaRoHC2G8ysLEmKJhpKhtQ0JFgchYzpK)ZCpuHxx2JzCrYnWAvkBV9EyypVJ2l)3r7Hk86YEyeYWqYEqPIiPD)P9E5VoApOurK0U)0dHTCYwAp8IHa8dyxeKZEi)3Q9qfEDzpmoVUS9EjU6O9Gsfrs7(tpe2YjBP9aDixCNCFRZ3MyoRklCxjiWm(c9NL0noGC84HCXDY9ToFBI5SQSWDLGaZ4l0FwIrRCc5Sb5)GC06Hk86YEOruxTT3lxuhThuQisA3F6HWwozlThvkoMkbb2kJcsaRoHC2GCZ9qfEDzpeQucOcVUeqwtVhYA6aPYq9GP8cu96Y27LR2r7bLkIK29NEiSLt2s7HRwqYFRlpUY)MHC84HCv4vecGsIPOjKZgK)VhQWRl7XMyoRklCxjiWm(c927LOYoApuHxx2dRgrbjBpOurK0U)0EVKD7O9qfEDzp2wf8sa7P2EqPIiPD)P9EjQUJ2dkvejT7p9qylNSL2d0HCxLu6VWC6NHHIijGGZkOhLkIK2qolqosyqWtJOUAFHgqolq(MqcdcEBI5SQSWDLGaZ4l0FHgqoA9qfEDzp84WCtwaHunAVxUGoApOurK0U)0dHTCYwApqhYf3j3368nJlsUbMsL5zjDJdiNfihjmi4nJlsUbqKN473(wNqolqosyqWtQthy6AUF7BDc5O1dv41L9ygxKCdGipX3T3l)BUJ2dkvejT7p9qylNSL2dxZVReeYzbYrcdcEZ4IKBae5j((TV1zpuHxx2JcmplbyOv2EV8))oApuHxx2JzCrYnWuQm9Gsfrs7(t79Y))6O9qfEDzp84WCtwaHun6bLkIK29N27L)XvhThuQisA3F6HWwozlThOd54eYDvsP)IqjiPPGEuQisAd5Ob54Xd5Od5UkP0FrOeK0uqpkvejTHCwGCKWGGNLIqji9SKkCiNfihNqosyqWlcLGKMccOaZZsagALVqdihnihpEihDihjmi4fHsqstbbyPiucsVqdihnihpEihDi3vjL(lcLGKMc6rPIiPnKZcKJtihjmi4fHsqstbbuG5zjadTYxObKZcKJtihjmi4fHsqstbbyPiucsVqdiNfi3QGeKZggihxMHC06Hk86YEyPiucsT3l)VOoApOurK0U)0dHTCYwApSkib5Sb5SR5EOcVUShfyEwcWqRShHtc4ccaaf7E8V9E5)v7O9qfEDzp2ueD6Qt9Gsfrs7(t7T3JnfOHsVJ2l)3r7Hk86YEyeYWqYEqPIiPD)P9E5VoApuHxx2JkDYkidVhuQisA3FAVxIRoApOurK0U)0JuzOEyvgJkbbugdz5HBcaSa1iN0bOeSsQhQWRl7HvzmQeeqzmKLhUjaWcuJCshGsWkP27LlQJ2dv41L9iCsaLtmZEqPIiPD)P9E5QD0EOcVUShiY72abHwC0dkvejT7pT3lrLD0EOcVUShiKDs2VReShuQisA3FAVxYUD0EOcVUShQvOjb4N1sP3dkvejT7pT3lr1D0EOcVUShYcm2NaF1WnidLEpOurK0U)0EVCbD0EOcVUShbLLqK3T7bLkIK29N27L)n3r7Hk86YEOPGMUvLacvk7bLkIK29N27L))3r7bLkIK29NEOcVUShcvkbuHxxciRP3dznDGuzOEyypV927HHLehdI6D0E5)oApOurK0U)0EV8xhThuQisA3FAVxIRoApOurK0U)0EVCrD0EOcVUShiQ7scygFHEpOurK0U)0EVC1oApOurK0U)0EVev2r7Hk86YEyCEDzpOurK0U)0E7T3E7Dd]] )


end
