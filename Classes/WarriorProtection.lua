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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 90 end,
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
            cooldown = 1,
            gcd = "off",

            spend = function () return ( buff.vengeance_ignore_pain.up and 0.67 or 1 ) * 40 end,
            spendType = "rage",

            startsCombat = false,
            texture = 1377132,

            toggle = "defensives",

            -- ready = function () return max( buff.ignore_pain.remains, action.ignore_pain.lastCast + 1 - query_time ) end,
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

            usable = function ()
                if settings.free_revenge and action.revenge.cost ~= 0 then return false, "free_revenge is checked and revenge is not free" end
                return true
            end,

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

            readyTime = function () return buff.shield_block.remains end,
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


    spec:RegisterSetting( "free_revenge", true, {
        name = "Use Free |T132353:0|t Revenge Only",
        desc = "If checked, the Revenge ability will only be recommended when it costs 0 Rage to use.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Protection Warrior", 20190707.2236, [[dyuhEaqibu9iaPnPa(KaigLQOofGyvaQ6vQsMLIWTuuXUe1VeOHHkCme0YqL6ziqttrLUMc02au4BkQY4au05auzDcaMNa09ayFkIoOakluv4Hak1efaPlkakFuaOojGswjcntbKCtbq1ovugQaINkYuvqFvaP2Ru)vvnykom0Ib6XinzHUmPntKpJQgnrDAjRwaiVgv0Sr52iA3k9BvgUcTCcpNstNQRlOTRk13rLmEfv15vfz9iG5RiTFq3e2d7ueDTNXnhecCCmpoMxMBUj4GecCDYFAu70is5e51oTiP2ParCUs96wOjqJcrDIonIpXom2d7K9cfuTtYUpAdabdYxUCiyMEKbTfzid96wQaL8G2IKgStGHfZbwBd2Pi6ApJBoie44yECmVm3CtWbjCWozhvApBEeStYvmQBd2POAPDcOqtGioxPEDl0eOrHOobKiqHgz3hTbGGb5lxoemtpYG2ImKHEDlvGsEqBrsHebk0qmK9e0mVjGgU5GqGdAMd0Wn3bacYbKiKiqHgGTmU8QfseOqZCGMalgHMa8YlE0RBHg2XxuOXpOzvUGMurcSHMalqcuzirGcnZbAcqvg(e04IA5uDl08SoFQo6qtaS4w(aelqGgPtanb2B0rrgseOqZCGMavXl76cnj5szrO5b7OCcn4gHgGf)EcfAceSwOjIKiVcn16iNk08mUrOjwssQqxVqxHMr5NSffzbjr(IcnrKe5vGK70O4KkM2jGcnbI4CL61TqtGgfI6eqIafAKDF0gacgKVC5qWm9idAlYqg61Tubk5bTfjfseOqdXq2tqZ8MaA4MdcboOzoqd3Chai4GqIqIafAa2Y4YRwirGcnZbAcSyeAcWlV4rVUfAyhFrHg)GMv5cAsfjWgAcSajqLHebk0mhOjavz4tqJlQLt1TqZZ68P6OdnbWIB5dqSabAKob0eyVrhfzirGcnZbAcufVSRl0KKlLfHMhSJYj0GBeAaw87juOjqWAHMisI8k0uRJCQqZZ4gHMyjjPcD9cDfAgLFYwuKfKe5lk0ersKxbsgseseOqta28vAORrObuLoHcn0JeeDObu5R1MHMaJs1r3cn7TZrgfKsHmObPEDRfAUL9ugseOqds96wBEuO0JeeDasm0YjKiqHgK61T28OqPhji6Vaeu6UiKiqHgK61T28OqPhji6Vaeed5j11rVUfseOqtAXrR85qJaRi0agkjPrOX6OBHgqv6ek0qpsq0HgqLVwl0GBeAgf6Cgp3RLhAkl0eVvZqIi1RBT5rHspsq0Fbiii6ot)w5l0HerQx3AZJcLEKGO)cqWXZRBHerQx3AZJcLEKGO)cqqsL8ep9pPplKwXFuOiPfsePEDRnpku6rcI(lab5drrSW9FsFKaQ4CzirK61T28OqPhji6Vaeu6OHwn(rcOIY1pOIKqIqIafAcWMVsdDncn6Bv8e04fPcnUScni1pb0uwObFJfdbzAgsePEDRfqTUkO6OdjIuVU1(cqWXqssLbjIuVU1(cqWqR(lxjTtusaO3XIhxBgFJokYcLeR1gqa8040PGHssz8n6OihocjIuVU1(cqqq2DXVuO4jirK61T2xaccQcRk4SwEirK61T2xacIckU63pHqxhsePEDR9fGGSIx2T)aOWipPUoKis96w7labLkHcYUlcjIuVU1(cqqCPQ1fi7trgdsePEDR9fGGJNx3orjbamuskJVrhf5WXPtDuWRE2ls973pwAa5EqirGcnHwfAaw87juOjqWAHg)Gg89vrOrG8k0qXXXA5HerQx3AFbiyXVNq)JyTtusaeiVMJQurlpGCp4lU5a4DKPRNbVJSw()7ROAwxeKPrGNEhlECT5OsEcKveOw(Vv(c9SqX4tqIi1RBTVaeeFJokGerQx3AFbiifzSps962pRS(elsQailV4rVUDIscqT0JSw(FejrE9pODsoGerQx3AFbiOiC)i1RB)SY6tSiPcapDIscGDuzSVJcE1TzxoCJQ4tz44KaiiKis96w7labPiJ9rQx3(zL1NyrsfG1HeHerQx3AZKLx8Ox3cWkxkl(bzhLZjkjaph4oY01ZGhZ6QiRlcY040PboyOKuMHw)BDCJ5WrGmWZuzuWR2VKaPEDlYMKWmWC60APhzT8)r5NSffz)bTtYrMqGxwrMlNjX5deirK61T2mz5fp61TVaeS43tO)rS2jkjapdgkjLTYLYIFq2r5mhpU2PtRLEK1Y)jr(I(h0ojhzcbEzfzUCMeNpqgamuskx87j0)iwBoECTd8Sa518i1Ne44E6uzfzUCEK6beyWbqGerQx3AZKLx8Ox3(cqWOsEcKveOw(Vv(c9jkjap7OGx9mxLlxlHCmDks96T(1vjl1ojHazGNFUw6rwl)pIKiV(h0ojhzche4LvK5YzsC(tNkRiZLZJupGeKdGmD6ZbUJmD9m4DK1Y)FFfvZ6IGmnoDQa51mjo)5iqEnGZLdGaeirK61T2mz5fp61TVaeKHw)BDCJtusaKvK5Y5rQhqcYbKis96wBMS8Ih962xacALlLf)CHm2eLeGAPhzT8)isI86Fq7KYkYC5PtLvK5Y5rQhqU5asesePEDRnJNcWLd3Ok(ugocjIuVU1MXtFbiyujpbYkcul)3kFH(eLeahz66zW7iRL))(kQM1fbzAesePEDRnJN(cqWOa5V9louajIuVU1MXtFbiOqFRlVcjIuVU1MXtFbiyOv)LRKtSiPcGxClV9pkksK9fiVorjbamuskJVrhf54X1oDk9ow84AZUC4gvXNYWXSqjXATtcyUqIi1RBTz80xackW3iVkGerQx3AZ4PVae0kxkl(bzhLZjkja07yXJRnBLlLf)wgsMfkgFAaWqjPSvUuw8dYokN54X1cjIuVU1MXtFbiOvUuw8BzijKiKis96wB26aC5WnQIpLHJtusaSJkJ9DuWRUn7YHBufFkdhbW9aoY01ZHR1VXreKPFPtq1SUiitJdagkjLX3OJIC4iKis96wB26Vae0kxkl(bzhLZjkja07yXJRnBLlLf)wgsMfkgFAaWqjPSvUuw8dYokN54X1oasavuUMbfiv)sN4xKJi1ZcC5CsKaQOCnhvus3A5)ubALZcC5CaWqjPm(gDuKdhHerQx3AZw)fGGw5szXVLHKtusaqcOIY1mOaP6x6e)ICePEwGlNtIeqfLR5OIs6wl)NkqRCwGlNdagkjLX3OJIC44aGHsszRCPS4hKDuoZHJqIi1RBTzR)cqqxoCJQ4tz44eLeGNDKPRNdxRFJJiit)sNGQzDrqMghamuskJVrhf5WrGajIuVU1MT(labJk5jqwrGA5)w5l0NOKa4itxpdEhzT8)3xr1SUiitJqIi1RBTzR)cqqRCPS4hKDuoNOKaqVJfpU2SvUuw8BzizwOy8PbadLKYw5szXpi7OCMJhxlKis96wB26Vae0kxkl(TmKesePEDRnB9xacgfi)TFXHcirK61T2S1FbiOlhUrv8PmCesePEDRnB9xack036YRqIi1RBTzR)cqWqR(lxjNyrsfaV4wE7FuuKi7lqEDIscayOKugFJokYXJRD6u6DS4X1MTYLYIFldjZcLeR1ojG5cjIuVU1MT(labf4BKxfqIi1RBTzR)cqWO(gTo6ANERcBDBpJBoie44yECmVm3CtWb7exOyRL32jGf54jCncndcni1RBHgwzDBgsStyOlFIoLkYqg61TaBbk5DIvw32d7uuLWqM3d7ze2d7es962ovRRcQo6DsxeKPX(r79mU7HDcPEDBNgdjjvwN0fbzASF0EpJG9WoPlcY0y)Otur5QOWorVJfpU2m(gDuKfkjwRfAciaOHNgHMPtHgWqjPm(gDuKdh7es962ofA1F5kPT9E2C7HDcPEDBNaz3f)sHIN6KUiitJ9J27zd2d7es962obQcRk4Sw(oPlcY0y)O9EgWOh2jK61TDcfuC1VFcHUEN0fbzASF0EpBE9WoHuVUTtSIx2T)aOWipPUEN0fbzASF0Epdy2d7es962ojvcfKDxSt6IGmn2pAVNbC9WoHuVUTt4svRlq2NImwN0fbzASF0EpJqo6HDsxeKPX(rNOIYvrHDcmuskJVrhf5WrOz6uOXrbV6zVi1VF)yPqtaHgUhSti1RB70451TT3ZiKWEyN0fbzASF0jQOCvuyNeiVMJQurlhAci0W9GqZlOHBoGgGhACKPRNbVJSw()7ROAwxeKPrOb4Hg6DS4X1MJk5jqwrGA5)w5l0ZcfJp1jK61TDQ43tO)rS227zeYDpSti1RB7e(gDu0jDrqMg7hT3ZiKG9WoPlcY0y)Otur5QOWovl9iRL)hrsKx)dAHMjHgo6es962orrg7JuVU9ZkR3jwz9)IKANilV4rVUT9EgHZTh2jDrqMg7hDIkkxff2j7OYyFhf8QBZUC4gvXNYWrOzsaqdb7es962ojc3ps962pRSENyL1)lsQDcpT9EgHd2d7KUiitJ9JoHuVUTtuKX(i1RB)SY6DIvw)ViP2jR3E7DAuO0Jee9EypJWEyNqQx32jq0DM(TYxO3jDrqMg7hT3Z4Uh2jK61TDA8862oPlcY0y)O9Egb7HDcPEDBNivYt80)K(SqAf)rHIK2oPlcY0y)O9E2C7HDcPEDBN4drrSW9FsFKaQ4C5oPlcY0y)O9E2G9WoHuVUTtshn0QXpsavuU(bvKSt6IGmn2pAV9orwEXJEDBpSNrypSt6IGmn2p6evuUkkStpdnbo04itxpdEmRRISUiitJqZ0PqtGdnGHsszgA9V1XnMdhHgGandanpdnuzuWR2VKaPEDlYGMjHgcZatOz6uOPw6rwl)Fu(jBrr2Fql0mj0WrMqOb4HgzfzUCMeNp0aKoHuVUTtw5szXpi7OC2EpJ7EyN0fbzASF0jQOCvuyNEgAadLKYw5szXpi7OCMJhxl0mDk0ul9iRL)tI8f9pOfAMeA4iti0a8qJSImxotIZhAac0ma0agkjLl(9e6FeRnhpUwOzaO5zOrG8AEK6qZKqdWXn0mDk0iRiZLZJuhAci0am4aAasNqQx32PIFpH(hXABVNrWEyN0fbzASF0jQOCvuyNEgACuWREMRYLRLqoGMPtHgK61B9RRswQfAMeAieAac0ma08m08m0ul9iRL)hrsKx)dAHMjHgoYeoi0a8qJSImxotIZhAMofAKvK5Y5rQdnbeAiihqdqGMPtHMNHMahACKPRNbVJSw()7ROAwxeKPrOz6uOrG8AMeNp0mhOrG8k0eqOzUCanabAasNqQx32POsEcKveOw(Vv(c927zZTh2jDrqMg7hDIkkxff2jzfzUCEK6qtaHgcYrNqQx32jgA9V1Xn2EpBWEyN0fbzASF0jQOCvuyNQLEK1Y)JijYR)bTqZKqJSImxgAMofAKvK5Y5rQdnbeA4MJoHuVUTtw5szXpxiJ1E7DY69WEgH9WoPlcY0y)Otur5QOWozhvg77OGxDB2Ld3Ok(ugocnaGgUHMbGghz665W1634icY0V0jOAwxeKPrOzaObmuskJVrhf5WXoHuVUTtUC4gvXNYWX27zC3d7KUiitJ9JorfLRIc7e9ow84AZw5szXVLHKzHIXNGMbGgWqjPSvUuw8dYokN54X1cndanibur5AguGu9lDIFroIuplWLtOzsObjGkkxZrfL0Tw(pvGw5SaxoHMbGgWqjPm(gDuKdh7es962ozLlLf)GSJYz79mc2d7KUiitJ9JorfLRIc7esavuUMbfiv)sN4xKJi1ZcC5eAMeAqcOIY1CurjDRL)tfOvolWLtOzaObmuskJVrhf5WrOzaObmuskBLlLf)GSJYzoCSti1RB7KvUuw8Bziz79S52d7KUiitJ9JorfLRIc70ZqJJmD9C4A9BCebz6x6eunRlcY0i0ma0agkjLX3OJIC4i0aKoHuVUTtUC4gvXNYWX27zd2d7KUiitJ9JorfLRIc7KJmD9m4DK1Y)FFfvZ6IGmn2jK61TDkQKNazfbQL)BLVqV9EgWOh2jDrqMg7hDIkkxff2j6DS4X1MTYLYIFldjZcfJpbndanGHsszRCPS4hKDuoZXJRTti1RB7KvUuw8dYokNT3ZMxpSti1RB7KvUuw8BzizN0fbzASF0Epdy2d7es962offi)TFXHIoPlcY0y)O9EgW1d7es962o5YHBufFkdh7KUiitJ9J27zeYrpSti1RB7KqFRlV2jDrqMg7hT3ZiKWEyN0fbzASF0jK61TDIxClV9pkksK9fiV2jQOCvuyNadLKY4B0rroECTqZ0Pqd9ow84AZw5szXVLHKzHsI1AHMjbanZTtlsQDIxClV9pkksK9fiV2EpJqU7HDcPEDBNe4BKxfDsxeKPX(r79mcjypSti1RB7uuFJwhDTt6IGmn2pAV9oHN2d7ze2d7es962o5YHBufFkdh7KUiitJ9J27zC3d7KUiitJ9JorfLRIc7KJmD9m4DK1Y)FFfvZ6IGmn2jK61TDkQKNazfbQL)BLVqV9Egb7HDcPEDBNIcK)2V4qrN0fbzASF0EpBU9WoHuVUTtc9TU8AN0fbzASF0EpBWEyN0fbzASF0jK61TDIxClV9pkksK9fiV2jQOCvuyNadLKY4B0rroECTqZ0Pqd9ow84AZUC4gvXNYWXSqjXATqZKaGM52Pfj1oXlUL3(hffjY(cKxBVNbm6HDcPEDBNe4BKxfDsxeKPX(r79S51d7KUiitJ9JorfLRIc7e9ow84AZw5szXVLHKzHIXNGMbGgWqjPSvUuw8dYokN54X12jK61TDYkxkl(bzhLZ27zaZEyNqQx32jRCPS43YqYoPlcY0y)O92BV927g]] )


end
