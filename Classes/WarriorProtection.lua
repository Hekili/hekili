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
            duration = function () return legendary.misshapen_mirror.enabled and 8 or 5 end,
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

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "RAGE" then
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
            charges = function () return legendary.leaper.enabled and 3 or nil end,
            recharge = function () return legendary.leaper.enabled and ( talent.bounding_stride.enabled and 30 or 45 ) or nil end,
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

        potion = "potion_of_phantom_fire",

        package = "Protection Warrior",
    } )


    spec:RegisterSetting( "free_revenge", true, {
        name = "Only |T132353:0|t Revenge if Free",
        desc = "If checked, the Revenge ability will only be recommended when it costs 0 Rage to use.",
        type = "toggle",
        width = 1.5
    } )


    spec:RegisterPack( "Protection Warrior", 20201205, [[dG0nCaqiiQArqu0JeOSjvfgLqItjK0QueQxjfnlfr3svfTlv5xsHHbroMQsltvvptGyAQQW1esTniu8nbQmobQ6CquyDQkk18eiDpvyFqiheIsTqHYdvvunriuQlQQOKncHkDsikzLamtfHCtiuXofIHQiWsve0tj1ufWxvvuSxQ(RknyfomYIb6XGMSuDzuBwf9zinAP0PfTAiuYRvKmBc3wq7wYVvA4a64qOQLt0Zjz6uUUIA7cvFxrQXRQiNxvLwpevMpeSFO2)6bCDNm2J8hP)i99psr)(()pIX12VazxdKGtrOSRlkKD9eixJHwUfE8ziPmxPRbs)kwQ7bCTANLq21TMbu9z3ObAATZGp4g2qLHZcYYTGs60AOYqydxdoNcdzvoOR7KXEK)i9hPV)rk633))Jo6ODTcid9ibxqCDB27C5GUUZkORdgEmbY1yOLBHhFgskZvIbem8aXMHCiilXJONep(J0FKWaWacgE85TuHYkmGGHh)epq29oEG4KwIswUfEiw0eIh2IhfpnEOZWphpq2tWe9WacgE8t8yIs0wJl8q3MSOJhXelCk8GQoEGSqRvY4XeqzHhDkKqz8ilJMIXdjJ4NtjhYLPEyabdp(jEmHC4gNXd5AKLBrc8ywrOmESN4Xerkdp0gv9hgqWWJFIhtiRaYqdpqMiUsMXJjKJZfkJmXdfBwwO4bvD8qYHBCgpwRLL4HKvMmHwUL65AGY9mfSRdgEmbY1yOLBHhFgskZvIbem8aXMHCiilXJONep(J0FKWaWacgE85TuHYkmGGHh)epq29oEG4KwIswUfEiw0eIh2IhfpnEOZWphpq2tWe9WacgE8t8yIs0wJl8q3MSOJhXelCk8GQoEGSqRvY4XeqzHhDkKqz8ilJMIXdjJ4NtjhYLPEyabdp(jEmHC4gNXd5AKLBrc8ywrOmESN4Xerkdp0gv9hgqWWJFIhtiRaYqdpqMiUsMXJjKJZfkJmXdfBwwO4bvD8qYHBCgpwRLL4HKvMmHwUL6HbGbqql3s9akz4gcswZJgGKzc(QA3zddGGwUL6buYWneKSMhnaUwUfgagqWWJpRpXWzJ74bhNL)IhwgY4H1Y4bbTvIhPcpO4ukiqb)WaiOLBPoGTKeLXaiOLBPAE0a4CyilWaiOLBPAE0q1UWPMMIZtMNhDgC(88bjLLf6Bg4hiVrsu2EP6cUkfgabTClvZJgZk(MghQMmppG7k6701JItgjFsoKYsf0duyhbeaNppFuCYi5BgigabTClvZJgGID73Zz5Vyae0YTunpAaYsflNklumacA5wQMhnijKk(ARuYLHbqql3s18OHirBn1fXAUJgYLHbqql3s18OXzkzqXUDmacA5wQMhnOcYktsIlKecmacA5wQMhnaj07EEnzcNsHbqql3s18ObW1YTMmppaNppFuCYi5BgiciCMOT2vYHuwQG(pAmacA5wQMhns0AL8fiL1K55HKq5xNptyAb9hinXgj4YEG7gMf6n(Mq(Xfbk4(ed3v03PRxNdxjjsKll0RQDNTNKP(Vyae0YTunpAajH4sql36ksLnzrH8ryAjkz5wtMNhzb3WSqVDkKq5B0keHegabTClvZJgubtUSlDASu1UWPWaiOLBPAE0qbKj5DpVGKYYTWaiOLBPAE0aUfIFMLRuDbPQyjgabTClvZJguCYijgabTClvZJgY56sql36ksLnzrH8bT8K55HcilexJKOSPEw7C1z5fkiGi6iiyae0YTunpAajH4sql36ksLnzrH8HYWaWaiOLBPEHPLOKLBDKO1k5lqkRjZZJSGBywO3ofsO8nA1hGZNNVeTwjFbsz9670fgabTCl1lmTeLSCRMhnuTjl6xqXcNAY88ikiVrcUSh4kuglFCrGcUJacip4855tqk7QmQ6VzGr9JOaBjjkRUNscA5wKarFFbpciKfCdZc92PqcLVrRIkgabTCl1lmTeLSCRMhn6C4kjrICzHEvT7SnzEEefJKOS9MoT2S(IeciqqlJZxU4WKvi6Bu)ikrjl4gMf6TtHekFJwHiKEFJEIBzsyTVq6tiGqltcR9beAbniifveqikiVrcUSh4UHzHEJVjKFCrGcUJacscLFH0N(PKq5G(dKIAuXaiOLBPEHPLOKLB18OHGu2vzu1NmppYcUHzHE7uiHY3GOqultcR9d4UI(oD9OkdP7EE7mzTpjhszPc6XFmacA5wQxyAjkz5wnpAOAtw0VttcXK55rwWnml0BNcju(gTcrTmjSweqOLjH1(acTG(hjmamacA5wQhT8HKItOSedGGwUL6rl38OrxsOBDLljXaiOLBPE0YnpAyTZvNLxOGaIbqql3s9OLBE0OZHRKejYLf6v1UZ2K55HrcUSh4UHzHEJVjKFCrGcUJbqql3s9OLBE0qYX5cLXaiOLBPE0YnpAOAtw0VGIfo1K55bCxrFNUEQ2Kf9RsqHpjt9F)aC(88PAtw0VGIfo1RVtxFaBjjkRo(Jbqql3s9OLBE0q1MSOFvckedGGwUL6rl38ObCRohwtMNhscLFWzPKldrhe0YTEjATs(cKY6bxL1mi)XaiOLBPE0YnpAWFIHZgJbqql3s9OLBE0iEcTv(7voRAXaiOLBPE0YnpAKHa5QNf6nEcTv(lgabTCl1JwU5rJohNugzmgagabTCl1tzhskoHYsmacA5wQNYAE0Olj0TUYLKyae0YTupL18OH1oxDwEHcc4K55HcilexJKOSPEw7C1z5fkiGh))Wibx2BUu2ceibk475kH8JlcuW9paNppFuCYi5BgigabTCl1tznpAOAtw0VGIfo1K55bCxrFNUEQ2Kf9RsqHpjt9F)aC(88PAtw0VGIfo1RVtxFyziFT9gsF6cBjjkRckkSJbqql3s9uwZJgQ2Kf9RsqHtMNhGZNNpvBYI(fuSWPEZaXaiOLBPEkR5rdRDU6S8cfeWjZZJOyKGl7nxkBbcKaf89CLq(Xfbk4(hGZNNpkozK8ndmQyae0YTupL18OrNdxjjsKll0RQDNTjZZdJeCzpWDdZc9gFti)4IafChdGGwUL6PSMhnuTjl6xLGcXaiOLBPEkR5rd(tmC2ymacA5wQNYAE0qYX5cLNmppKekJOJGdjmacA5wQNYAE0WANRolVqbbedGGwUL6PSMhnKCCUqzmacA5wQNYAE0iEcTv(7voRAXaiOLBPEkR5rJmeix9SqVXtOTYFXaiOLBPEkR5rJohNugzSRJZsvULh5ps)rcPGpii56PjzLfQY1iRqGR04oEenEqql3cpePYupmaxtZw7kDTodNfKLB95s60CTivMYd46oFsZcZd4r(6bCnbTClxdBjjk7AUiqb39yU5r(7bCnbTClxdComKfUMlcuWDpMBEKG4bCnxeOG7EmxdLPXYKCDNbNppFqszzH(MbIhFGhipEyKeLTxQUGRs5AcA5wUw1UWPMMIZU5r(HhW1CrGcU7XCnuMgltY1WDf9D66rXjJKpjhszPWJGEGhOWoEGac4b4855JItgjFZaDnbTClxpR4BACOYnps0Eaxtql3Y1GID73Zz5VUMlcuWDpMBEeeJhW1e0YTCnilvSCQSqDnxeOG7Em38ibNhW1e0YTCnjHuXxBLsUmxZfbk4UhZnpsW7bCnbTClxls0wtDrSM7OHCzUMlcuWDpMBEeKHhW1e0YTC9zkzqXUDxZfbk4UhZnpYxK8aUMGwULRPcYktsIlKecxZfbk4UhZnpY3VEaxtql3Y1Ge6DpVMmHtPCnxeOG7Em38iF)7bCnxeOG7EmxdLPXYKCn4855JItgjFZaXdeqapot0w7k5qklfEeu84F0UMGwULRbUwULBEKVbXd4AUiqb39yUgktJLj5AjHYVoFMW0WJGIh)aj8yIXdJeCzpWDdZc9gFti)4IafChpMy8aUROVtxVohUssKixwOxv7oBpjt9FDnbTClxNO1k5lqkl38iF)HhW1CrGcU7XCnuMgltY1zb3WSqVDkKq5B0k8ar4bsUMGwULRHKqCjOLBDfPYCTiv2TOq21HPLOKLB5Mh5B0Eaxtql3Y1ubtUSlDASu1UWPCnxeOG7Em38iFrmEaxtql3Y1kGmjV75fKuwULR5IafC3J5Mh5BW5bCnbTClxd3cXpZYvQUGuvS01CrGcU7XCZJ8n49aUMGwULRP4KrsxZfbk4UhZnpYxKHhW1CrGcU7XCnuMgltY1kGSqCnsIYM6zTZvNLxOGaIhi6apcIRjOLB5A5CDjOLBDfPYCTiv2TOq210YU5r(JKhW1CrGcU7XCnbTClxdjH4sql36ksL5ArQSBrHSRvMBU5AGsgUHGK5b8iF9aUMGwULRbjZe8v1UZMR5IafC3J5Mh5VhW1e0YTCnW1YTCnxeOG7Em3CZ1HPLOKLB5b8iF9aUMlcuWDpMRHY0yzsUol4gMf6TtHekFJwHhFGhGZNNVeTwjFbsz9670LRjOLB56eTwjFbsz5Mh5VhW1CrGcU7XCnuMgltY1rbpqE8Wibx2dCfkJLpUiqb3XdeqapqE8aC(88jiLDvgv93mq8iQ4Xh4ruWdyljrz19usql3Ie4bIWJVVGhpqab8il4gMf6TtHekFJwHhr11e0YTCTQnzr)ckw4uU5rcIhW1CrGcU7XCnuMgltY1rbpmsIY2B60AZ6ls4bciGhe0Y48LlomzfEGi84lEev84d8ik4ruWJSGBywO3ofsO8nAfEGi8aP33OXJjgpAzsyTVq6t4bciGhTmjS2hqOHhbfpccs4ruXdeqapIcEG84HrcUSh4UHzHEJVjKFCrGcUJhiGaEiju(fsFcp(jEijugpckE8dKWJOIhr11e0YTCDNdxjjsKll0RQDNn38i)Wd4AUiqb39yUgktJLj56SGBywO3ofsO8nik8ar4rltcRfp(apG7k6701JQmKU75TZK1(KCiLLcpc6bE831e0YTCTGu2vzu1DZJeThW1CrGcU7XCnuMgltY1zb3WSqVDkKq5B0k8ar4rltcRfpqab8OLjH1(acn8iO4XFKCnbTClxRAtw0VttcHBU5AL5b8iF9aUMGwULRLuCcLLUMlcuWDpMBEK)Eaxtql3Y1DjHU1vUK01CrGcU7XCZJeepGR5IafC3J5AOmnwMKRvazH4AKeLn1ZANRolVqbbepoWJ)4Xh4HrcUS3CPSfiqcuW3Zvc5hxeOG74Xh4b4855JItgjFZaDnbTClxBTZvNLxOGa6Mh5hEaxZfbk4UhZ1qzASmjxd3v03PRNQnzr)Qeu4tYu)x84d8aC(88PAtw0VGIfo1RVtx4Xh4HLH812Bi9PlSLKOScpckEGc7UMGwULRvTjl6xqXcNYnps0EaxZfbk4UhZ1qzASmjxdoFE(uTjl6xqXcN6nd01e0YTCTQnzr)QeuOBEeeJhW1CrGcU7XCnuMgltY1rbpmsWL9MlLTabsGc(EUsi)4IafChp(apaNppFuCYi5BgiEevxtql3Y1w7C1z5fkiGU5rcopGR5IafC3J5AOmnwMKRnsWL9a3nml0B8nH8JlcuWDxtql3Y1DoCLKirUSqVQ2D2CZJe8Eaxtql3Y1Q2Kf9RsqHUMlcuWDpMBEeKHhW1e0YTCn)jgoBSR5IafC3J5Mh5lsEaxZfbk4UhZ1qzASmjxljugpq0bEeCi5AcA5wUwYX5cLDZJ89RhW1e0YTCT1oxDwEHccOR5IafC3J5Mh57FpGRjOLB5AjhNlu21CrGcU7XCZJ8niEaxtql3Y1XtOTYFVYzvRR5IafC3J5Mh57p8aUMGwULRZqGC1Zc9gpH2k)11CrGcU7XCZJ8nApGRjOLB56ohNugzSR5IafC3J5MBUMw2d4r(6bCnbTClxlP4eklDnxeOG7Em38i)9aUMGwULR7scDRRCjPR5IafC3J5MhjiEaxtql3Y1w7C1z5fkiGUMlcuWDpMBEKF4bCnxeOG7EmxdLPXYKCTrcUSh4UHzHEJVjKFCrGcU7AcA5wUUZHRKejYLf6v1UZMBEKO9aUMGwULRLCCUqzxZfbk4UhZnpcIXd4AUiqb39yUgktJLj5A4UI(oD9uTjl6xLGcFsM6)IhFGhGZNNpvBYI(fuSWPE9D6cp(apGTKeLv4XbE831e0YTCTQnzr)ckw4uU5rcopGRjOLB5AvBYI(vjOqxZfbk4UhZnpsW7bCnxeOG7EmxdLPXYKCTKq5hCwk5YWdeDGhe0YTEjATs(cKY6bxLHhnXJG831e0YTCnCRohwU5rqgEaxtql3Y18Ny4SXUMlcuWDpMBEKVi5bCnbTClxhpH2k)9kNvTUMlcuWDpMBEKVF9aUMGwULRZqGC1Zc9gpH2k)11CrGcU7XCZJ89VhW1e0YTCDNJtkJm21CrGcU7XCZn3CZn3ba]] )


end
