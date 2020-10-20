-- WarriorProtection.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


-- Conduits
-- [x] unnerving_focus
-- [x] show_of_force

-- Prot Endurance
-- [-] brutal_vitality


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 73 )

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand_fury = {
            swing = "mainhand",

            last = function ()
                local swing = state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = "mainhand_speed",

            stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
            value = function ()
                return ( state.talent.war_machine.enabled and 1.5 or 1 ) * 2
            end
        },
    } )

    -- Talents
    spec:RegisterTalents( {
        war_machine = 15760, -- 316733
        punish = 15759, -- 275334
        devastator = 15774, -- 236279

        double_time = 19676, -- 103827
        rumbling_earth = 22629, -- 275339
        storm_bolt = 22409, -- 107570

        best_served_cold = 22378, -- 202560
        booming_voice = 22626, -- 202743
        dragon_roar = 23260, -- 118000

        crackling_thunder = 23096, -- 203201
        bounding_stride = 22627, -- 202163
        menace = 22488, -- 275338

        never_surrender = 22384, -- 202561
        indomitable = 22631, -- 202095
        impending_victory = 22800, -- 202168

        into_the_fray = 22395, -- 202603
        unstoppable_force = 22544, -- 275336
        ravager = 22401, -- 228920

        anger_management = 23455, -- 152278
        heavy_repercussions = 22406, -- 203177
        bolster = 23099, -- 280001
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        bodyguard = 168, -- 213871
        demolition = 5374, -- 329033
        disarm = 24, -- 236077
        dragon_charge = 831, -- 206572
        morale_killer = 171, -- 199023
        oppressor = 845, -- 205800
        overwatch = 5378, -- 329035
        rebound = 833, -- 213915
        shield_bash = 173, -- 198912
        sword_and_board = 167, -- 199127
        thunderstruck = 175, -- 199045
        warpath = 178, -- 199086
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
        bounding_stride = {
            id = 202164,
            duration = 3,
            max_stack = 1,
        },
        charge = {
            id = 105771,
            duration = 1,
            max_stack = 1,
        },
        challenging_shout = {
            id = 1161,
            duration = 6,
            max_stack = 1,
        },
        deep_wounds = {
            id = 115767,
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
        hamstring = {
            id = 1715,
            duration = 15,
            max_stack = 1,
        },
        ignore_pain = {
            id = 190456,
            duration = 12,
            max_stack = 1,
        },
        intimidating_shout = {
            id = 5246,
            duration = 8,
            max_stack = 1,
        },
        into_the_fray = {
            id = 202602,
            duration = 3600,
            max_stack = 3,
        },
        last_stand = {
            id = 12975,
            duration = 15,
            max_stack = 1,
        },
        punish = {
            id = 275335,
            duration = 9,
            max_stack = 3,
        },
        rallying_cry = {
            id = 97463,
            duration = function () return 10 * ( 1 + conduit.inspiring_presence.mod * 0.01 ) end,
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
            duration = 6,
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
            duration = 4,
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


    local rageSpent = 0
    local rageSinceBanner = 0 


    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function( event )
        local _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" then
            local ability = class.abilities[ spellID ]

            if not ability then return end

            if ability.key == "conquerors_banner" then
                rageSinceBanner = 0
            end
        end
    end )

    
    local RAGE = Enum.PowerType.Rage
    local lastRage = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( unit, powerType )
        if powerType == RAGE then
            local current = UnitPower( "player", RAGE )

            if current < lastRage then
                rageSpent = ( rageSpent + lastRage - current ) % 20 -- Anger Mgmt.                
                rageSinceBanner = ( rageSinceBanner + lastRage - current ) % 30 -- Glory.
            end

            lastRage = current
        end
    end )

    spec:RegisterStateExpr( "rage_spent", function ()
        return rageSpent
    end )

    spec:RegisterStateExpr( "rage_since_banner", function ()
        return rageSinceBanner
    end )

    -- model rage expenditure reducing CDs...
    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "rage" and amt > 0 then
            if talent.anger_management.enabled then
                rage_spent = rage_spent + amt
                local secs = floor( rage_spent / 10 )
                rage_spent = rage_spent % 10

                cooldown.avatar.expires = cooldown.avatar.expires - secs
                cooldown.shield_wall.expires = cooldown.shield_wall.expires - secs
                -- cooldown.last_stand.expires = cooldown.last_stand.expires - secs
                -- cooldown.demoralizing_shout.expires = cooldown.demoralizing_shout.expires - secs
            end

            if buff.conquerors_frenzy.up then
                rage_since_banner = rage_since_banner + amt
                local stacks = floor( rage_since_banner / 20 )
                rage_since_banner = rage_since_banner % 20

                if stacks > 0 then addStack( "glory", nil, stacks ) end
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
            gcd = "off",

            spend = function () return ( level > 51 and -40 or -30 ) * ( 1 + conduit.unnerving_focus.mod * 0.01 ) end,
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

            essential = true,

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


        challenging_shout = {
            id = 1161,
            cast = 0,
            cooldown = 240,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 132091,
            
            handler = function ()
                applyDebuff( "target", "challenging_shout" )
                active_dot.challenging_shout = active_enemies
            end,
        },
        

        charge = {
            id = 100,
            cast = 0,
            cooldown = 20,
            gcd = "off",

            spend = function () return -20 * ( 1 + conduit.unnerving_focus.mod * 0.01 ) end,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132337,

            usable = function () return target.minR > 7, "requires 8 yard range or more" end,
            
            handler = function ()
                applyDebuff( "target", "charge" )
            end,
        },


        demoralizing_shout = {
            id = 1160,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = function () return ( talent.booming_voice.enabled and -40 or 0 ) * ( 1 + conduit.unnerving_focus.mod * 0.01 ) end,
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
            end,
        },


        dragon_roar = {
            id = 118000,
            cast = 0,
            cooldown = 35,
            gcd = "spell",

            spend = function () return -20 * ( 1 + conduit.unnerving_focus.mod * 0.01 ) end,
            spendType = "rage",

            startsCombat = true,
            texture = 642418,

            talent = "dragon_roar",
            range = 12,

            handler = function ()
                applyDebuff( "target", "dragon_roar" )
                active_dot.dragon_roar = max( active_dot.dragon_roar, active_enemies )
            end,
        },


        execute = {
            id = 163201,
            noOverride = 317485,
            cast = 0,
            cooldown = 6,
            gcd = "spell",
            
            spend = 20,
            spendType = "rage",
            
            startsCombat = true,
            texture = 135358,

            usable = function () return target.health_pct < 20, "requires target below 20% HP" end,
            
            handler = function ()
                if rage.current > 0 then
                    local amt = min( 20, rage.current )
                    spend( amt, "rage" )

                    amt = ( amt + 20 ) * 0.2
                    gain( amt, "rage" )

                    return
                end

                gain( 4, "rage" )
            end,
        },


        heroic_leap = {
            id = 6544,
            cast = 0,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
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

            spend = 40,
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
                if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
            end,
        },


        intervene = {
            id = 3411,
            cast = 0,
            cooldown = 30,
            gcd = "off",
            
            startsCombat = true,
            texture = 132365,
            
            handler = function ()
            end,
        },


        intimidating_shout = {
            id = function () return talent.menace.enabled and 316593 or 5246 end,
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

            copy = { 316593, 5246 }
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

                if talent.bolster.enabled then
                    applyBuff( "shield_block", buff.last_stand.duration )
                end

                if conduit.unnerving_focus.enabled then applyBuff( "unnerving_focus" ) end
            end,

            auras = {
                -- Conduit
                unnerving_focus = {
                    id = 337155,
                    duration = 15,
                    max_stack = 1
                }
            }
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
                gain( 0.2 * health.max, "health" )
                health.max = health.max * 1.2
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
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.revenge.up or buff.reprisal.up then return 0 end
                return 20
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
                if buff.revenge.up then removeBuff( "revenge" )
                else removeBuff( "reprisal" ) end
                if conduit.show_of_force.enabled then applyBuff( "show_of_force" ) end
            end,

            auras = {
                -- Conduit
                show_of_force = {
                    id = 339825,
                    duration = 12,
                    max_stack = 1
                },
                reprisal = {
                    id = 335734,
                    duration = 6,
                    max_stack = 1
                }
            }
        },


        shield_block = {
            id = 2565,
            cast = 0,
            charges = 2,
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

            nobuff = "shield_block",

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

            spend = function () return ( ( legendary.the_wall.enabled and -5 or 0 ) + ( talent.heavy_repercussions.enabled and -18 or -15 ) ) * ( 1 + conduit.unnerving_focus.mod * 0.01 ) end,
            spendType = "rage",

            startsCombat = true,
            texture = 134951,

            handler = function ()
                if talent.heavy_repercussions.enabled and buff.shield_block.up then
                    buff.shield_block.expires = buff.shield_block.expires + 1
                end

                if legendary.the_wall.enabled and cooldown.shield_wall.remains > 0 then
                    reduceCooldown( "shield_wall", 5 )
                end

                if talent.punish.enabled then applyDebuff( "target", "punish" ) end
            end,
        },


        shield_wall = {
            id = 871,
            cast = 0,
            cooldown = function () return 240 - conduit.stalwart_guardian.mod * 0.002 end,
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
            cooldown = function () return ( ( talent.rumbling_earth.enabled and active_enemies >= 3 ) and 25 or 40 ) + conduit.disturb_the_peace.mod * 0.001 end,
            gcd = "spell",

            startsCombat = true,
            texture = 236312,

            toggle = "interrupts",
            debuff = "casting",
            readyTime = state.timeToInterrupt,
            usable = function () return not target.is_boss end,

            handler = function ()
                applyDebuff( "target", "shockwave" )
                active_dot.shockwave = max( active_dot.shockwave, active_enemies )
                if not target.is_boss then interrupt() end
            end,
        },


        spell_reflection = {
            id = 23920,
            cast = 0,
            cooldown = 25,
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

            spend = function () return -5 * ( 1 + conduit.unnerving_focus.mod * 0.01 ) end,
            spendType = "rage",

            startsCombat = true,
            texture = 136105,

            handler = function ()
                applyDebuff( "target", "thunder_clap" )
                active_dot.thunder_clap = max( active_dot.thunder_clap, active_enemies )
                removeBuff( "show_of_force" )

                if legendary.thunderlord.enabled and cooldown.demoralizing_shout.remains > 0 then
                    reduceCooldown( "demoralizing_shout", min( 3, active_enemies ) * 1.5 )
                end
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
                if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
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

        potion = "potion_of_unbridled_fury",

        package = "Protection Warrior",
    } )


    spec:RegisterSetting( "free_revenge", true, {
        name = "Free |T132353:0|t Revenge",
        desc = "If checked, the Revenge ability will only be recommended when it costs 0 Rage to use.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Protection Warrior", 20200830, [[dK00QaqivLYJiHAtQQYNuvsmksGtbr1QOOcVsv0SOu6wQkv7ss)sP0WiP6yKuwgLINbrmnkv6AQQQTrckFJsfnosiDokQO1rccnpis3tvAFquoOQsyHQkEiLkyIQkr1fjbbFuvjsNKsfALKOzscQUPQse7uvyOQkPwkji9ujMQsXvvvIYxjbr7vXFvYGPYHrTyO6XGMmvDzIndLptHrRuDAvwnfv61uuMnPUnK2TOFl1WHWXvvsA5aphPPlCDkz7uKVRQY4jH48uQA9uu18jj7hXJAZMP45qMh2OUnQRUIIe1RQPgsS7))pLWEeYuqWqZydzkjJkt5RbDiW46K4uiza4AWuqW2RB2pBMcTTaqzk7rGGQqC7wJl2TWRWgDl9qT0CCDcbmwSLEOWTtb360HDmh8P45qMh2OUnQRUIIe1RQPMA2P6MZPqriW5HDIKPSFEVKd(u8cfofftCFnOdbgxNeNcjdaxdikvmX9fwgw0G4qI62sC2OUnQtusuQyIZoSZPHqjkvmX9DI7l8EI7l5IZGJRtIt3ghK4IM4s5hXvou7aX9fFTcVsuQyI77e3xUOz7jUaCPzsqjofikcuqee3xkOtJVcf5ehwdiUVWehmOsuQyI77eNc)m2djjUY(jApX9r3qZioo9eND0iBGqCFnFjX5zu2qiUld2mH4aYx16acQKbTsuQyI77eNcvqBtcXb6GJRtwtCwu2qiUgJ4u4mniUsWPVsuQyI77e3xgviofQyssdH4uWVDjjUlioytdkXPqzdb5exNA7jUdJ4UG4(15xjiUldbGjaH4(DXoXHEXzWX1zDkian2PLPOyI7RbDiW46K4uiza4AarPIjUVWYWIgehsu3wIZg1TrDIsIsftC2HDonekrPIjUVtCFH3tCFjxCgCCDsC624Gex0exk)iUYHAhiUV4Rv4vIsftCFN4(YfnBpXfGlntckXParrGcIG4(sbDA8vOiN4WAaX9fM4GbvIsftCFN4u4NXEijXv2pr7jUp6gAgXXPN4SJgzdeI7R5ljopJYgcXDzWMjehq(QwhqqLmOvIsftCFN4uOcABsioqhCCDYAIZIYgcX1yeNcNPbXvco9vIsftCFN4(YOcXPqftsAieNc(TljXDbXbBAqjofkBiiN46uBpXDye3fe3Vo)kbXDziambie3Vl2jo0lodoUoReLeLkM4uiOic0kepXHlynqioyJIZbXHlgxsRe3xaHcIGsCzNFFNbOywAIJHX1jL46uBFLOuXehdJRtAfbqGnkohVyAMAgrPIjoggxN0kcGaBuCoE(UfRBprPIjoggxN0kcGaBuCoE(ULTmqLm446KOuXexjze09oioaFEId3cdt8ehn4GsC4cwdeId2O4CqC4IXLuIJtpXHaiFhrhXLge3rjoFNsLOKHX1jTIaiWgfNJNVBX5i0YIU3wbrjdJRtAfbqGnkohpF3ArL1fcQTjJkVS5P7mGPlSoJvJTq0)earjdJRtAfbqGnkohpF3(RbAVj5YfqODYjuikzyCDsRiacSrX5457wubTb2VASL2cE(LhimkLOKHX1jTIaiWgfNJNVBr0X1jrjrPIjofckIaTcXtCIjbypXfhQqCXUqCmmAaXDuIJnXNMX1sLOKHX1j9fUZadHOKHX1j957wewOOIMOKHX1j957w6Edn7hBsS9WE9cUfgwfY04sJQfI)(wWadjQhDH3ukrjdJRt6Z3T46U9lmlG9eLmmUoPpF3IlaQam7sdIsggxN0NVBzaKtzfnaizquYW46K(8DR(m2d6YCT8gOsgeLmmUoPpF3IDabx3TNOKHX1j957woHcnaSEbzTMOKHX1j957wC2y1yRaCqZOeLmmUoPpF3IOJRtBpSxClmSkBIdguTqOsvCOYk6L)eKAZ)eLkM4SOcXzhnYgie3xZxsCrtCSP(8ehGneIdYiqCPbrjdJRt6Z3TNr2azHGV02d7fWgs1lyh8cKAx1nhbRLmQ4DJEPXYuFqPkjJRfV5a2T23)YQxqBaRpZFPXIU3wrfiS3EIsggxN0NVB)1aT3KC5ci0o5ek2EyVWU1((xwztCWGkqq5lPi91gIsggxN0NVBrf0gy)QXwAl45xEGWOuBpSxy3AF)lRSjoyqfiO8LuK(Aa9eLmmUoPpF3c7ekza4q8lmnJk2EyV4wyyv2ehmO67F5FFZ3rf2juYaWH4xyAgvw4wGSceu(skYuxLkHsLek1yxwqGf8W1YQXwyAgvQaondPiHOuXehdJRt6Z3TAMglAWP32d7vOujHsLZdLxn2sFyYIt)YlCSxrzZTbeLmmUoPpF3UlmiwcLkjuS9WE)McekvsOuJDzbbwWdxlRgBHPzuPIYMBduPsOujHs9xd0EtYLlGq7KtOurzZTbQujuQKqPY5HYRgBPpmzXPF5fo2ROS52avQekvsOurf0gy)QXwAl45xEGWO0kkBUna5eLmmUoPpF3ArL1fck12d7f2T23)YkBIdgubckFjfPVgqVkv4wyyv2ehmOAHGOKHX1j957w2ehmGOKHX1j957wkcHbRgBHZ046KOKHX1j957wyNFvlb0a6cNZuaeLmmUoPpF3Yj8Kmwmwia6EdnJOKOKHX1j957wiR1lggxNl9rdBtgvErV4m44602d79syJEPXYZOSHS(NIm1jkzyCDsF(UfyLlggxNl9rdBtgvE5wS9WEPieTEfmWqcAn2TsVawqnJazViHOKHX1j957wiR1lggxNl9rdBtgvEPbrjrjdJRtAf9IZGJRZ3ZiBGSqWxA7H9EjSrV0y5zu2qw)tjkzyCDsROxCgCCD(8DlD)eTFHRBOz2EyVk4BbRLmQ4TMgcOkjJRfVkvFd3cdRQzASObN(QfcK)NcG7mWqOlmadJRtwJm1QkQkvxcB0lnwEgLnK1)uKtuYW46KwrV4m446857wVG2awFM)sJfDVTcBpSxfemWqI6Vl2Vun1vPIHXzswskONqrMAi)pfOGlHn6LglpJYgY6FkYuVQ2)MJDH1XEfLvevQ2fwh7veWaPirDKRsLc(wWAjJkE3OxASm1huQsY4AXRsfGnKkkRiFhWgcsTR6ih5eLmmUoPv0lodoUoF(UvZ0yrdo92EyVxcB0lnwEgLnKfsOiBxyDS)hSBTV)LvopuE1ylVWXEfiO8LuK(AdrjdJRtAf9IZGJRZNVBP7NO9RFSwB7H9EjSrV0y5zu2qw)tr2UW6yxLQDH1XEfbmqQnQtusuYW46Kw5wEJDR0lGfuZiikzyCDsRClpF36f0gW6Z8xASO7Tvy7H9gSwYOI3n6Lglt9bLQKmUw8eLmmUoPvULNVBP7NO9lCDdnZ2d7f2T23)YkD)eTFr1mAfiS3()WTWWQ09t0(fUUHMv99V8pClmSkQG2a7xn2sBbp)YdegLwTqquYW46Kw5wE(ULUFI2VOAg12d7f3cdRIkOnW(vJT0wWZV8aHrPvleeLmmUoPvULNVB9a2OZfOzarjdJRtALB557wGyssdX2d7f3cdRcetsAivleQu9TOnm0s1lyssptcvLkClmS6zKnqwi4lRwiuPsb4wyyv6(jA)cx3qZQabLVKQsfSBTV)Lv6(jA)cx3qZQWDgyi0fgGHX1jRrQ6vff5eLmmUoPvULNVBTOY6cb12KrLxdqNg0fcWHY6fGneBpSxClmSkBIdgu99VuLky3AF)lRXUv6fWcQzevGGYxsr2RDjkzyCDsRClpF3cytSHaikzyCDsRClpF3s3pr7x46gAMTh2lSBTV)Lv6(jA)IQz0kqyV9)HBHHvP7NO9lCDdnR67F5FWDgyi0xBikzyCDsRClpF3s3pr7xunJsuYW46Kw5wE(Uf2PxqtBpSxaBivOfaizGSxggxN1ZiBGSqWxwHnnEIeBikzyCDsRClpF3kkIaTcHOKHX1jTYT88DRPdgnW(fWIUtuYW46Kw5wE(U9qriP)sJLPdgnWEIsggxN0k3YZ3TEXetdoeIsIsggxN0knEJDR0lGfuZiS9WEPieTEfmWqcAn2TsVawqnJ41M)cwlzuTsA0iqW4AzH1aOuLKX1I)pClmSkBIdguTqquYW46KwPXZ3T09t0(fUUHMz7H9c7w77FzLUFI2VOAgTce2B)F4wyyv6(jA)cx3qZQ((x(hCNbgc91gIsggxN0knE(ULUFI2VOAgLOKHX1jTsJNVBJDR0lGfuZiS9WEvqWAjJQvsJgbcgxllSgaLQKmUw8)HBHHvztCWGQfcKtuYW46KwPXZ3TEbTbS(m)Lgl6EBf2EyVbRLmQ4DJEPXYuFqPkjJRfprjdJRtALgpF3ArL1fcQTjJkVmD3eNcDbyZ3GfSbS22d71l4wyyvaB(gSGnG1lVGBHHvPbdn7vDIsggxN0knE(U1IkRleuBtgvEz6Ujof6cWMVblydyTTh2RxWTWWQa28nybBaRxEb3cdRsdgAgYSZ)uaSBTV)Lv2ehmOceu(sks)xLkClmSkBIdguTqGCIsggxN0knE(U1dyJoxGMbeLmmUoPvA88DBSBLEbSGAgbrjdJRtALgpF3cetsAi2EyV4wyyvGyssdPAHqLQVfTHHwQEbts6zsOQuHBHHvpJSbYcbFz1cHkvka3cdRs3pr7x46gAwfiO8LuvQGDR99VSs3pr7x46gAwfUZadHUWammUoznsvVQOiNOKHX1jTsJNVBTOY6cb12KrLxdqNg0fcWHY6fGneBpSxClmSkBIdgu99VuLky3AF)lR09t0(fvZOvGGYxsr2RDjkzyCDsR0457waBInearjdJRtALgpF3c70lOPTh2lGnKk0caKmq2ldJRZ6zKnqwi4lRWMgprIneLmmUoPvA88DROic0keIsggxN0knE(U10bJgy)cyr3jkzyCDsR04572dfHK(lnwMoy0a7jkzyCDsR0457wVyIPbhYumja6158Wg1TrD1vyQz3P8Jb5Lg0Pyhrr0Gq8e3)ehdJRtItF0GwjkNcBf7nykLd1sZX1PDaWyXu0hnOZMP4fm2shZM5HAZMPWW46CkWDgyitrsgxl(5ZeZdBMntHHX15uqyHIk6PijJRf)8zI5bsMntrsgxl(5ZuGGleWXtXl4wyyvitJlnQwiiU)iUVrCbdmKOE0fEtPtHHX15uO7n0SFSjzI5HDNntHHX15uW1D7xywa7NIKmUw8ZNjMh)pBMcdJRZPGlaQam7sJPijJRf)8zI5HcB2mfggxNtHbqoLv0aGKXuKKX1IF(mX8WoNntHHX15u0NXEqxMRL3avYyksY4AXpFMyEOOZMPWW46CkyhqW1D7NIKmUw8ZNjMhMZzZuyyCDofoHcnaSEbzTEksY4AXpFMyEOM6ZMPWW46Ck4SXQXwb4GMrNIKmUw8ZNjMhQP2SzksY4AXpFMceCHaoEk4wyyv2ehmOAHG4uPI4IdvwrV8NqCiL4S5)PWW46Cki646CI5HA2mBMIKmUw8ZNPabxiGJNcGnKQxWo4fehsjo7QoXzoiUG1sgv8UrV0yzQpOuLKX1IN4mhehSBTV)LvVG2awFM)sJfDVTIkqyV9tHHX15uoJSbYcbF5eZd1qYSzksY4AXpFMceCHaoEkWU1((xwztCWGkqq5lPehsFjoBMcdJRZP8RbAVj5YfqODYjuMyEOMDNntrsgxl(5ZuGGleWXtb2T23)YkBIdgubckFjL4q6lXza9tHHX15uqf0gy)QXwAl45xEGWO0jMhQ9)SzksY4AXpFMceCHaoEk4wyyv2ehmO67FjX9hX9nIZ3rf2juYaWH4xyAgvw4wGSceu(skXHmItDItLkItOujHsn2LfeybpCTSASfMMrLkGtZioKsCizkmmUoNcStOKbGdXVW0mQmX8qnf2SzksY4AXpFMceCHaoEkFJ4uaXjuQKqPg7YccSGhUwwn2ctZOsfLn3gqCQurCcLkjuQ)AG2BsUCbeANCcLkkBUnG4uPI4ekvsOu58q5vJT0hMS40V8ch7vu2CBaXPsfXjuQKqPIkOnW(vJT0wWZV8aHrPvu2CBaXH8PWW46Ck7cdILqPscLjMhQzNZMPijJRf)8zkqWfc44Pa7w77FzLnXbdQabLVKsCi9L4mGEItLkId3cdRYM4GbvletHHX15uSOY6cbLoX8qnfD2mfggxNtHnXbdMIKmUw8ZNjMhQzoNntHHX15uOiegSASfotJRZPijJRf)8zI5HnQpBMcdJRZPa78RAjGgqx4CMcyksY4AXpFMyEyJAZMPWW46CkCcpjJfJfcGU3qZMIKmUw8ZNjMh2yZSzksY4AXpFMceCHaoEkxcB0lnwEgLnK1)uIdzeN6tHHX15uGSwVyyCDU0hnMI(OXkzuzkOxCgCCDoX8WgKmBMIKmUw8ZNPabxiGJNcfHO1RGbgsqRXUv6fWcQzeehYEjoKmfggxNtbyLlggxNl9rJPOpASsgvMc3YeZdBS7SzksY4AXpFMcdJRZPazTEXW46CPpAmf9rJvYOYuOXetmfeab2O4CmBMhQnBMcdJRZPGZrOLfDVTIPijJRf)8zI5HnZMPijJRf)8zkjJktHnpDNbmDH1zSASfI(NaMcdJRZPWMNUZaMUW6mwn2cr)tatmpqYSzkmmUoNYVgO9MKlxaH2jNqzksY4AXpFMyEy3zZuyyCDofubTb2VASL2cE(LhimkDksY4AXpFMyE8)SzkmmUoNcIoUoNIKmUw8ZNjMykOxCgCCDoBMhQnBMIKmUw8ZNPabxiGJNYLWg9sJLNrzdz9pDkmmUoNYzKnqwi4lNyEyZSzksY4AXpFMceCHaoEkkG4(gXfSwYOI3AAiGQKmUw8eNkve33ioClmSQMPXIgC6RwiioKtC)rCkG4G7mWqOlmadJRtwtCiJ4uRQOeNkve3LWg9sJLNrzdz9pL4q(uyyCDof6(jA)cx3qZMyEGKzZuKKX1IF(mfi4cbC8uuaXfmWqI6Vl2Vun1jovQioggNjzjPGEcL4qgXPgXHCI7pItbeNciUlHn6LglpJYgY6FkXHmIt9QA)tCMdIBxyDSxrzfH4uPI42fwh7veWG4qkXHe1joKtCQurCkG4(gXfSwYOI3n6Lglt9bLQKmUw8eNkvehGnKkkRie33joaBiehsjo7QoXHCId5tHHX15u8cAdy9z(lnw092kMyEy3zZuKKX1IF(mfi4cbC8uUe2OxAS8mkBilKqjoKrC7cRJDI7pId2T23)YkNhkVASLx4yVceu(skXH0xIZMPWW46CkAMglAWPFI5X)ZMPijJRf)8zkqWfc44PCjSrV0y5zu2qw)tjoKrC7cRJDItLkIBxyDSxradIdPeNnQpfggxNtHUFI2V(XA9etmfAmBMhQnBMIKmUw8ZNPabxiGJNcfHO1RGbgsqRXUv6fWcQzee3lXzdX9hXfSwYOAL0OrGGX1YcRbqPkjJRfpX9hXHBHHvztCWGQfIPWW46CkXUv6fWcQzetmpSz2mfjzCT4NptbcUqahpfy3AF)lR09t0(fvZOvGWE7jU)ioClmSkD)eTFHRBOzvF)ljU)io4odmekX9sC2mfggxNtHUFI2VW1n0SjMhiz2mfggxNtHUFI2VOAgDksY4AXpFMyEy3zZuKKX1IF(mfi4cbC8uuaXfSwYOAL0OrGGX1YcRbqPkjJRfpX9hXHBHHvztCWGQfcId5tHHX15uIDR0lGfuZiMyE8)SzksY4AXpFMceCHaoEkbRLmQ4DJEPXYuFqPkjJRf)uyyCDofVG2awFM)sJfDVTIjMhkSzZuKKX1IF(mfi4cbC8u8cUfgwfWMVblydy9Yl4wyyvAWqZiUxIt9PKmQmfMUBItHUaS5BWc2awpfggxNtHP7M4uOlaB(gSGnG1tmpSZzZuKKX1IF(mfi4cbC8u8cUfgwfWMVblydy9Yl4wyyvAWqZioKrC2jX9hXPaId2T23)YkBIdgubckFjL4qkX9pXPsfXHBHHvztCWGQfcId5tjzuzkmD3eNcDbyZ3GfSbSEkmmUoNct3nXPqxa28nybBaRNyEOOZMPWW46CkEaB05c0myksY4AXpFMyEyoNntHHX15uIDR0lGfuZiMIKmUw8ZNjMhQP(SzksY4AXpFMceCHaoEk4wyyvGyssdPAHG4uPI4(gXfTHHwQEbts6zsOeNkvehUfgw9mYgile8LvleeNkveNcioClmSkD)eTFHRBOzvGGYxsjovQioy3AF)lR09t0(fUUHMvH7mWqOlmadJRtwtCiL4uVQOehYNcdJRZPaetsAitmputTzZuKKX1IF(mfi4cbC8uWTWWQSjoyq13)sItLkId2T23)YkD)eTFr1mAfiO8LuIdzVeNDNsYOYumaDAqxiahkRxa2qMcdJRZPya60GUqaouwVaSHmX8qnBMntHHX15uaSj2qatrsgxl(5ZeZd1qYSzksY4AXpFMceCHaoEka2qQqlaqYG4q2lXXW46SEgzdKfc(YkSPbX9K4qIntHHX15uGD6f0CI5HA2D2mfggxNtruebAfYuKKX1IF(mX8qT)NntHHX15umDWOb2Vaw09PijJRf)8zI5HAkSzZuyyCDoLdfHK(lnwMoy0a7NIKmUw8ZNjMhQzNZMPWW46CkEXetdoKPijJRf)8zIjMc3YSzEO2SzkmmUoNsSBLEbSGAgXuKKX1IF(mX8WMzZuKKX1IF(mfi4cbC8ucwlzuX7g9sJLP(Gsvsgxl(PWW46CkEbTbS(m)Lgl6EBftmpqYSzksY4AXpFMceCHaoEkWU1((xwP7NO9lQMrRaH92tC)rC4wyyv6(jA)cx3qZQ((xsC)rC4wyyvubTb2VASL2cE(LhimkTAHykmmUoNcD)eTFHRBOztmpS7SzksY4AXpFMceCHaoEk4wyyvubTb2VASL2cE(LhimkTAHykmmUoNcD)eTFr1m6eZJ)NntHHX15u8a2OZfOzWuKKX1IF(mX8qHnBMIKmUw8ZNPabxiGJNcUfgwfiMK0qQwiiovQiUVrCrByOLQxWKKEMekXPsfXHBHHvpJSbYcbFz1cbXPsfXPaId3cdRs3pr7x46gAwfiO8LuItLkId2T23)YkD)eTFHRBOzv4odme6cdWW46K1ehsjo1RkkXH8PWW46CkaXKKgYeZd7C2mfjzCT4NptbcUqahpfClmSkBIdgu99VK4uPI4GDR99VSg7wPxalOMrubckFjL4q2lXz3PKmQmfdqNg0fcWHY6fGnKPWW46CkgGonOleGdL1laBitmpu0zZuyyCDofaBIneWuKKX1IF(mX8WCoBMIKmUw8ZNPabxiGJNcSBTV)Lv6(jA)IQz0kqyV9e3FehUfgwLUFI2VW1n0SQV)Le3FehCNbgcL4EjoBMcdJRZPq3pr7x46gA2eZd1uF2mfggxNtHUFI2VOAgDksY4AXpFMyEOMAZMPijJRf)8zkqWfc44PaydPcTaajdIdzVehdJRZ6zKnqwi4lRWMge3tIdj2mfggxNtb2PxqZjMhQzZSzkmmUoNIOic0kKPijJRf)8zI5HAiz2mfggxNtX0bJgy)cyr3NIKmUw8ZNjMhQz3zZuyyCDoLdfHK(lnwMoy0a7NIKmUw8ZNjMhQ9)SzkmmUoNIxmX0GdzksY4AXpFMyIjMyIzaa]] )


end
