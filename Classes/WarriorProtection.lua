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

            readyTime = function ()
                if buff.ignore_pain.up and buff.ignore_pain.v1 > 0.3 * stat.attack_power * 3.5 * ( 1 + stat.versatility_atk_mod / 100 ) then
                    return buff.ignore_pain.remains - gcd.max
                end
                return 0
            end,

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
            cooldown = function () return talent.bolster.enabled and 120 or 180 end,
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
                if action.revenge.cost == 0 then return true end
                if toggle.defensives and buff.ignore_pain.down then return false, "don't spend on revenge if ignore_pain is down" end
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

            debuff = function () return not target.is_boss and "casting" or nil end,

            handler = function ()
                applyDebuff( "target", "shockwave" )
                active_dot.shockwave = max( active_dot.shockwave, active_enemies )
                if not target.is_boss then interrupt() end
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
                removeBuff( "victorious" )
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

        potion = "superior_battle_potion_of_strength",

        package = "Protection Warrior",
    } )


    spec:RegisterSetting( "free_revenge", true, {
        name = "Free |T132353:0|t Revenge",
        desc = "If checked, the Revenge ability will only be recommended when it costs 0 Rage to use.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Protection Warrior", 20190811.2300, [[dKuLLaqiaLEKQsTjkv5tuQknkavNcrXQau4vQKMffYTKkv7sf)IszyuOogawMujpJsstdGQRbq2gIQY3OuvnoakNJsIwhLeAEikDpvv7JskhKsQSqvfpKscMiLuvDrkPQ8rkvfDsevvRerMjIQ4MuQkStvIHkvkTuaf9uHMQuXvPKQ4RiQs2RO)QkdwWHHwmcpgLjlLltAZa9zu1OLQoTKvJOk1RPuz2eDBuz3k(TsdxL64usvA5i9CctNQRtrBNc(oGmEPsX5vvY6ruz(uI9d6eGStgBOR5LUmgaR0yadaaoDzva6ca7pJ(x3AgVrMDiVMXb50m2T01vMx7adKxiLwlnJ34xYfBzNmkwtktZyV73cROnB8L3BsCylNnrXzkrV2Hrrq3MO4y2YiHzjDY)KezSHUMx6YyaSsJbmaa40LvbOlaaugf3klVy)wnJ9vRPtsKXMkyz8ByOBPRRmV2bgiVqkTwkK03WqV73cROnB8L3BsCylNnrXzkrV2Hrrq3MO4yqsFddwNjVPWHbam2iyOlJbWkHHUddDzvROXgdjbj9nmyf6XHxfqsFddDhgSUwdgSpkV4rV2bgKlFXGbFHHrbcgIfNvagSUUL8CGK(gg6omy9Rs8lyWP1yN6cya4A3W0BhgSpP7WBFfKbgaxkmyDgqhPhiPVHHUddKNIV31bgI9LkBWWh5YSdgWPbdKF(zPkm0TynWqd5qEfgQXr7uyGQwVMfv50XfhiPVHHUddatLBnOWaDD0RDqjmykqEfgwqyG8GchgIooTdK03Wq3HbRhHcdat1Go8kmaCG61bgkhgyRWfWaWe5vYad7i)cgkqyOCyaODSVomuJRuqLQWaqL3ddCLx8Ox7CY4nDblPMXVHHULUUY8AhyG8cP0APqsFdd9UFlSI2SXxEVjXHTC2efNPe9AhgfbDBIIJbj9nmyDM8MchgaWyJGHUmgaReg6om0LvTIgBmKeK03WGvOhhEvaj9nm0DyW6AnyW(O8Ih9AhyqU8fdg8fggfiyiwCwbyW66wYZbs6ByO7WG1VkXVGbNwJDQlGbGRDdtVDyW(KUdV9vqgyaCPWG1zaDKEGK(gg6omqEk(Exhyi2xQSbdFKlZoyaNgmq(5NLQWq3I1adnKd5vyOghTtHbQA9AwuLthxCGK(gg6omamvU1Gcd01rV2bLWGPa5vyybHbYdkCyi640oqsFddDhgSEekmamvd6WRWaWbQxhyOCyGTcxadatKxjdmSJ8lyOaHHYHbG2X(6WqnUsbvQcdavEpmWvEXJETZbscs6ByW6RBuMPRnyGqbxQcdSLJaDyGq5RrCGbRJX0BxadZoDVhPCGMsyazETJag2r(1bs6ByazETJ4Ctv2YrG(pOef2bj9nmGmV2rCUPkB5iq)6VnWDBqsFddiZRDeNBQYwoc0V(Bdn550XrV2bs6Byio4TOFDyGIvdgimbb1gmiC0fWaHcUufgylhb6WaHYxJagWPbd3uT73R71WddLagA7OhijK51oIZnvzlhb6x)TrGUl1NOFnDijK51oIZnvzlhb6x)Tzk0x5kNrdYP)i5e9iffpWD83c(UxGukKeY8AhX5MQSLJa9R)24uUL(1BbFstw1EnQICcijK51oIZnvzlhb6x)TXBI0wHZBbFi5u669qsiZRDeNBQYwoc0V(B7E9AhijiPVHbRVUrzMU2Gb1Gs)cg8ItHbVxHbK5lfgkbmGgWsIes9ajHmV2r8xJRuME7qsiZRDex)TDBYXPsijK51oIR)2e9lZoGqdQrf4Ftjmbbpmu41WFmVThW6iLx9tjEeRqajHmV2rC93MPqFLRCcJkWF2UY2c0CqdOJ0dv5WAeK9NN1SyHWee8GgqhPhZBijK51oIR)2iK72EGM0VGKqMx7iU(BJqPcLAxn8qsiZRDex)THugo6ZxkvhhsczETJ46VnzX37Ih5TzJNthhsczETJ46VnWIQeYDBqsiZRDex)THdtfofLpgkLqsiZRDex)TDVETJrf4pHji4bnGospM3wS4fN(891kLSDbiiPVHbtHcdKF(zPkm0TynWGVWaAyRgmqrEfgy49Dn8qsiZRDex)Tv8Zs13nwJrf4pf51ttblw5KTlaDTlJbgok1Xpe7Yvd)ZWwm9Odsi1gWGTRSTanNMYTuuwKRg(NOFn9dvX2xqsiZRDex)Tb0sLndAnpQk2bhMAub(Z2v2wGMdAaDKEOkhwJGS)DbjHmV2rC93gTUVL6RMN4gzkKeY8AhX1FBCk3s)6TGpPjRAVgvrobKeY8AhX1FBSDy64u012duICQrf4pHji4bnGospTfObs6ByazETJ46Vnjk8NWXPzub(Z2v2wGMdofh(wWxtrV)qvoSgbz)7csczETJ46Vn0a6ifsczETJ46VngkLpK51opzjCJgKt)5kV4rV2XOc8Vg2Yvd)RHCiV(aKWAgdjHmV2rC93g1CEiZRDEYs4gniN(JRAub(lUvP85iLxDXX7nNMsFmjEBTFRcjHmV2rC93gdLYhY8ANNSeUrdYP)chscsczETJ4WvEXJETZFXplvF3yngvG)1WwUA4FnKd51hGeqsiZRDehUYlE0RDU(Bt0xQS9iKlZoJkWFGdSok1XpeRu4k9Odsi1MflalHji4rIc)jCCAhZBYypGZ6rkVkEGuK51oO0AaCamlwQHTC1W)AihYRpajidKeY8AhXHR8Ih9ANR)2Ak3srzrUA4FI(10nQa)bUJuE1pavEFnaySfliZld6thLRuH1aGm2d4aVg2Yvd)RHCiV(aKWAgFaaqaJEfLE)Hd7glw6vu69NBMtwRAmzSyb4aRJsD8dXUC1W)mSftp6GesTzXcf51dh2nDNI8kzbCJjdzGKqMx7ioCLx8Ox7C93Mef(t440mQa)7vu69NBMtwRAmKeY8AhXHR8Ih9ANR)2e9LkBpGqP0Oc8Vg2Yvd)RHCiV(aKWA9kk9Elw6vu69NBMt2UmgscsczETJ4GR(79MttPpMeVHKqMx7io4Qx)TXPCl9R3c(KMSQ9Auf5egvG)eMGGh0a6i90wGgijK51oIdU61FBnLBPOSixn8pr)A6gvG)ok1Xpe7Yvd)ZWwm9Odsi1gKeY8AhXbx96VnCko8TGVMIEVrf4pHji4rIc)jCCAhZBijK51oIdU61FBnkYVZJUifsczETJ4GRE93gvnOdVAub(tyccEOQbD41J5TflaRV88s90uqDeLbvyXcHji4P4NLQVBSMJ5TflaNWee8i6lv2EeYLz3HQCynclwy7kBlqZr0xQS9iKlZUdRhP8Q4bsrMx7GsYA8bWidKeY8AhXbx96VntH(kx5mAqo9NNUdV4Dtlou(OiVAub(tyccEqdOJ0tBbASyHTRSTanhV3CAk9XK49HQCyncR9d4qsiZRDehC1R)2OObKxPqsiZRDehC1R)2e9LkBpc5YSZOc8NTRSTanhrFPY2tirUdvX2x2JWee8i6lv2EeYLz3PTanqsiZRDehC1R)2e9LkBpHe5GKqMx7io4Qx)TzOy(s)6rnf9qsiZRDehC1R)2kUBDA1W)mumFPFbjHmV2rCWvV(BRPgqHJUcjbjHmV2rCe(V3BonL(ys82Oc8xCRs5ZrkV6IJ3BonL(ys8(Vl75Ouh)yocFVVrcP(axktp6GesTzpctqWdAaDKEmVHK(ggqMx7ioc)6VnrFPY2JqUm7mQa)z7kBlqZr0xQS9esK7qvS9L9imbbpI(sLThHCz2DAlqdKeY8AhXr4x)Tj6lv2EcjYzub(tyccEe9LkBpc5YS7yEdjHmV2rCe(1FBEV50u6JjXBJkWFG7Ouh)yocFVVrcP(axktp6GesTzpctqWdAaDKEmVjdKeY8AhXr4x)T1uULIYIC1W)e9RPBub(7Ouh)qSlxn8pdBX0JoiHuBqsiZRDehHF93gofh(wWxtrV3Oc8NWee8irH)eooTJ5nKeY8AhXr4x)Tj6lv2EcjYbjHmV2rCe(1FBMc9vUYz0GC6pk6nGJkEuKCl9XwkknQa)BkHji4HIKBPp2sr5RPeMGGhHJm7(ngsczETJ4i8R)2mf6RCLZOb50Fu0Bahv8Oi5w6JTuuAub(3uctqWdfj3sFSLIYxtjmbbpchz2zn73EaNTRSTanh0a6i9qvoSgbzbKfleMGGh0a6i9yEtgijK51oIJWV(BRrr(DE0fPqsiZRDehHF93M3BonL(ys8gsczETJ4i8R)2OQbD4vJkWFctqWdvnOdVEmVTyby9LNxQNMcQJOmOclwimbbpf)Su9DJ1CmVTyb4eMGGhrFPY2JqUm7ouLdRryXcBxzBbAoI(sLThHCz2Dy9iLxfpqkY8AhuswJpagzGKqMx7ioc)6VntH(kx5mAqo9NNUdV4Dtlou(OiVAub(tyccEqdOJ0tBbASyHTRSTanhrFPY2tirUdv5WAew7hWHKqMx7ioc)6VnkAa5vkKeY8AhXr4x)TzOy(s)6rnf9qsiZRDehHF93wXDRtRg(NHI5l9lijK51oIJWV(BRPgqHJUMrdkvu7Kx6YyaSsJbmaaiJaH0PgErgj)C3l11gmaiyazETdmilHloqszuwcxKDYytbrtPNDYlaKDYiY8ANmwJRuME7zuhKqQT8t65LUYozezETtgVn54uzg1bjKAl)KEEXQzNmQdsi1w(jJmA5kTWm2uctqWddfEn8hZByWEWaWcdos5v)uIhXkezezETtgf9lZoGqdA65fap7KrDqcP2YpzKrlxPfMr2UY2c0CqdOJ0dv5WAeWaz)HbEwdgSybgimbbpOb0r6X8oJiZRDYOPqFLRCI0Zlak7KrK51ozKqUB7bAs)kJ6GesTLFspVq(YozezETtgjuQqP2vdFg1bjKAl)KEEX(ZozezETtgrkdh95lLQJNrDqcP2YpPNxaSStgrMx7KrzX37Ih5TzJNthpJ6GesTLFspVyLzNmImV2jJGfvjK72YOoiHuB5N0ZlayC2jJiZRDYiomv4uu(yOuMrDqcP2YpPNxaaGStg1bjKAl)KrgTCLwygjmbbpOb0r6X8ggSybg8ItF((ALcdKfg6cqzezETtgVxV2j98caDLDYOoiHuB5NmYOLR0cZif51ttblw5WazHHUaemCfg6Yyyayadok1Xpe7Yvd)ZWwm9Odsi1gmamGb2UY2c0CAk3srzrUA4FI(10pufBFLrK51ozS4NLQVBSM0Zlay1Stg1bjKAl)KrgTCLwygz7kBlqZbnGospuLdRradK9hg6kJiZRDYiqlv2mO18OQyhCyA65faa8StgrMx7KrADFl1xnpXnY0mQdsi1w(j98caak7KrK51ozKt5w6xVf8jnzv71OkYjYOoiHuB5N0Zlaq(YozuhKqQT8tgz0YvAHzKWee8GgqhPN2c0KrK51ozKTdthNIU2EGsKttpVaG9NDYiY8ANmIgqhPzuhKqQT8t65faaSStg1bjKAl)KrgTCLwygRHTC1W)AihYRpajGbRbdgNrK51ozKHs5dzETZtwcpJYs4Vb50mYvEXJETt65faSYStg1bjKAl)KrgTCLwygf3Qu(CKYRU449MttPpMeVHbR9ddwnJiZRDYi1CEiZRDEYs4zuwc)niNMrC10ZlDzC2jJ6GesTLFYiY8ANmYqP8HmV25jlHNrzj83GCAgfE6PNXBQYwoc0Zo5faYozezETtgjq3L6t0VMEg1bjKAl)KEEPRStg1bjKAl)KXb50mIKt0Juu8a3XFl47EbsPzezETtgrYj6rkkEG74Vf8DVaP00Zlwn7KrK51ozKt5w6xVf8jnzv71OkYjYOoiHuB5N0ZlaE2jJiZRDYiVjsBfoVf8HKtPR3NrDqcP2YpPNxau2jJiZRDY4961ozuhKqQT8t6PNrUYlE0RDYo5faYozuhKqQT8tgz0YvAHzSg2Yvd)RHCiV(aKiJiZRDYyXplvF3ynPNx6k7KrDqcP2YpzKrlxPfMrGddalm4Ouh)qSsHR0JoiHuBWGflWaWcdeMGGhjk8NWXPDmVHbYad2dgaomW6rkVkEGuK51oOegSgmaWbWGblwGHAylxn8VgYH86dqcyGmzezETtgf9LkBpc5YSl98IvZozuhKqQT8tgz0YvAHze4WGJuE1pavEFnaymmyXcmGmVmOpDuUsfWG1GbaGbYad2dgaomaCyOg2Yvd)RHCiV(aKagSgmy8baabdadyOxrP3F4WUbgSybg6vu69NBMddKfgSQXWazGblwGbGddalm4Ouh)qSlxn8pdBX0JoiHuBWGflWaf51dh2nWq3HbkYRWazHba3yyGmWazYiY8ANm2uULIYIC1W)e9RPNEEbWZozuhKqQT8tgz0YvAHzSxrP3FUzomqwyWQgNrK51ozuIc)jCCAPNxau2jJ6GesTLFYiJwUslmJ1WwUA4FnKd51hGeWG1GHEfLEpmyXcm0RO07p3mhgilm0LXzezETtgf9LkBpGqPm90ZOWZo5faYozuhKqQT8tgz0YvAHzuCRs5ZrkV6IJ3BonL(ys8gg(HHUGb7bdok1XpMJW37BKqQpWLY0JoiHuBWG9GbctqWdAaDKEmVZiY8ANm69MttPpMeVtpV0v2jJ6GesTLFYiJwUslmJeMGGhrFPY2JqUm7oM3zezETtgf9LkBpHe5spVy1Stg1bjKAl)KrgTCLwygbom4Ouh)yocFVVrcP(axktp6GesTbd2dgimbbpOb0r6X8ggitgrMx7KrV3CAk9XK4D65fap7KrDqcP2YpzKrlxPfMrhL64hID5QH)zylME0bjKAlJiZRDYyt5wkklYvd)t0VME65faLDYOoiHuB5NmYOLR0cZiHji4rIc)jCCAhZ7mImV2jJ4uC4BbFnf9(0ZlKVStgrMx7KrrFPY2tirUmQdsi1w(j98I9NDYOoiHuB5NmImV2jJOO3aoQ4rrYT0hBPOmJmA5kTWm2uctqWdfj3sFSLIYxtjmbbpchz2bd)WGXzCqonJOO3aoQ4rrYT0hBPOm98cGLDYOoiHuB5NmImV2jJOO3aoQ4rrYT0hBPOmJmA5kTWm2uctqWdfj3sFSLIYxtjmbbpchz2bdwdgSFyWEWaWHb2UY2c0CqdOJ0dv5WAeWazHbabdwSadeMGGh0a6i9yEddKjJdYPzef9gWrfpksUL(ylfLPNxSYStgrMx7KXgf535rxKMrDqcP2YpPNxaW4StgrMx7KrV3CAk9XK4Dg1bjKAl)KEEbaaYozuhKqQT8tgz0YvAHzKWee8qvd6WRhZByWIfyayHbF55L6PPG6ikdQagSybgimbbpf)Su9DJ1CmVHblwGbGddeMGGhrFPY2JqUm7ouLdRradwSadSDLTfO5i6lv2EeYLz3H1JuEv8aPiZRDqjmqwyW4dGbdKjJiZRDYivnOdVMEEbGUYozuhKqQT8tgrMx7KrE6o8I3nT4q5JI8Agz0YvAHzKWee8GgqhPN2c0adwSadSDLTfO5i6lv2EcjYDOkhwJagS2pma4zCqonJ80D4fVBAXHYhf510Zlay1StgrMx7KrkAa5vAg1bjKAl)KEEbaap7KrK51oz0qX8L(1JAk6ZOoiHuB5N0ZlaaOStgrMx7KXI7wNwn8pdfZx6xzuhKqQT8t65faiFzNmImV2jJn1akC01mQdsi1w(j90ZiUA2jVaq2jJiZRDYO3BonL(ys8oJ6GesTLFspV0v2jJ6GesTLFYiJwUslmJeMGGh0a6i90wGMmImV2jJCk3s)6TGpPjRAVgvror65fRMDYOoiHuB5NmYOLR0cZOJsD8dXUC1W)mSftp6GesTLrK51ozSPClfLf5QH)j6xtp98cGNDYOoiHuB5NmYOLR0cZiHji4rIc)jCCAhZ7mImV2jJ4uC4BbFnf9(0Zlak7KrK51ozSrr(DE0fPzuhKqQT8t65fYx2jJ6GesTLFYiJwUslmJeMGGhQAqhE9yEddwSadalm4lpVupnfuhrzqfWGflWaHji4P4NLQVBSMJ5nmyXcmaCyGWee8i6lv2EeYLz3HQCyncyWIfyGTRSTanhrFPY2JqUm7oSEKYRIhifzETdkHbYcdgFamyGmzezETtgPQbD410Zl2F2jJ6GesTLFYiY8ANmYt3Hx8UPfhkFuKxZiJwUslmJeMGGh0a6i90wGgyWIfyGTRSTanhV3CAk9XK49HQCyncyWA)WaGNXb50mYt3Hx8UPfhkFuKxtpVayzNmImV2jJu0aYR0mQdsi1w(j98IvMDYOoiHuB5NmYOLR0cZiBxzBbAoI(sLTNqIChQITVGb7bdeMGGhrFPY2JqUm7oTfOjJiZRDYOOVuz7rixMDPNxaW4StgrMx7KrrFPY2tirUmQdsi1w(j98caaKDYiY8ANmAOy(s)6rnf9zuhKqQT8t65fa6k7KrK51ozS4U1Pvd)ZqX8L(vg1bjKAl)KEEbaRMDYiY8ANm2udOWrxZOoiHuB5N0tp9mIME)sZyS4mLOx7yfOiONE6zc]] )


end
