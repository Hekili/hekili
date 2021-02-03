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


    spec:RegisterPack( "Protection Warrior", 20210202, [[dCeiyaqiIalsvk6raPnrK0OisCkIOwfrk9kf0SuiDlLOSlO8lb1WuLCmLWYaINPkvttQixtbABsfvFtQqghriNJiOwNuHQMhrK7PuTpLihKiiluqEOur5IsfQSrvPuNujQALQIzkvq3ujQ0ojQgkrOwQubEkftLO8vPcL9s6VagSuomYIHQhdzYk6YO2Ss5ZQQrlvDArRwjQ41kGztPBlWUL8BvgoqDCvPWYj8CHMovxxjTDPsFxHy8eP48ePA9QsjZxHA)GwxOYuZKCwLdYlqw8cKxGGTqI6uN)(7QXLoywnGj0a0NvtrbSAKyX5mYZRGTogje5judys62JMQm1eVvbIvtV7GJD8Hd)tVFfhdDbHJzWQL88kKG28WXmafwn4RP1x(sXvZKCwLdYlqw8cKxGGTqI6uN)6D1ebZivEh9UA6Z5KlfxntoIudOGcBsS4Cg55vWwhJeI8eWhqbf2EBgxSscPdBGmkSbYlqwaFGpGckS1z9u95i8buqHTLbBsO5e2wUPNFYZRGn79teS5hSv8iWMjd6mytcjXDig8buqHTLbBDy(7DUGntFY2jSfYEObGnQMW2Y)RtWWMetzbBtkG(mSLLtdWWMGFJ1uWbC5rm4dOGcBld26ao46YWM4CYZRilSTgPpdB3gS1Hu0HnJt1ed(akOW2YGToGJGzKdBV5Blyg26aUlxF(nHTi7EwFyJQjSj4GRldBN3ZcytWrxKipVkIPgWIBlTSAafuytIfNZipVc26yKqKNa(akOW2BZ4IvsiDydKrHnqEbYc4d8buqHToRNQphHpGckSTmytcnNW2Yn98tEEfSzVFIGn)GTIhb2mzqNbBsijUdXGpGckSTmyRdZFVZfSz6t2oHTq2dnaSr1e2w(FDcg2KyklyBsb0NHTSCAag2e8BSMcoGlpIbFafuyBzWwhWbxxg2eNtEEfzHT1i9zy72GToKIoSzCQMyWhqbf2wgS1bCemJCy7nFBbZWwhWD56ZVjSfz3Z6dBunHnbhCDzy78EwaBco6Ie55vrm4d8HqEEvedSGrxao5d3dJtUBzGy)T6Whc55vrmWcgDb4KpCpm4ZZRGpWhqbf264KggT68e24USq6WMNbmS59mSri)eWwgHnQlLwc3YyWhc55vXDupj(m8HqEEvC4EyWRbbSf(qipVkoCpCS)qdmc1Lhn32Nm(62ggIIEwFSvWsvcCs8zhlJa4xmcFiKNxfhUhEnYaPZbXrZTD0D25nsHrDjNeycoGYkkP9pAoEm(62gg1LCsGTcg(qipVkoCpmU9UjW2Qq6Whc55vXH7HXzrKfdK1h(qipVkoCpmjquXa(jeC5Whc55vXH7HT5V3JalN15pGlh(qipVkoCp8wkyC7Dt4dH88Q4W9WuH4OlilaISw4dH88Q4W9W40h42aCrIgicFiKNxfhUhg855vJMB74RBByuxYjb2k4XJ3YFVdi4akROKazq4dH88Q4W9W5VobdaMYA0CBxqFgBYBjkDj1PxsRtwUCm87cY6d09seJXfHB5P0IUZoVrkSjhCcYMVvwFGy)T6ycMMsh(qipVkoCpmISwac55va2m6JwuaVhKE(jpVA0CBpl0fK1hysb0NbgmU0l4dH88Q4W9WuxYjb8HqEEvC4EyQqjxoaT5Si2FObGpeYZRId3dhbZKa42aWPONxbFiKNxfhUhgD1BSYItebWPQyb8HqEEvC4E4yFY2jaU9qdmAUTJVUTHf7t2obWThAaS5nsbFiKNxfhUhwSwaeYZRaSz0hTOaENoE0CBpcMTwaNeF2JyE)AnzbaYsGxA)D4dH88Q4W9WiYAbiKNxbyZOpArb8(NlwKi4d8HqEEveli98tEE1E(RtWaGPSgn32f0NxAWxsfFDBdl)1jyaWuwyZBKc(qipVkIfKE(jpVA4E4yFY2jaU9qdmAUTlfjWjlxog(zJolW4IWT8C8yjaFDBdZsrhi6unXwblzPkfupj(CeytqipVISlTatIgpol0fK1hysb0Nbgmkz4dH88Qiwq65N88QH7HNCWjiB(wz9bI93QpAUTlfNeF2Xgj9(Sw8A8yc5zxgGloi54slKSuLIuYcDbz9bMua9zGbJl9cBXGsBptwVhlGKMXJ7zY69yGrUKE)LKhpwksGtwUCm87cY6d09seJXfHB554Xc6ZybK0Smb9zj1PxswYWhc55vrSG0Zp55vd3dBPOdeDQMJMB7zHUGS(atkG(mW7XL6zY69sfDNDEJuyuLbeWTbmzY7XeCaLvus7GaFiKNxfXcsp)KNxnCpCSpz7eyeYAhn32ZcDbz9bMua9zGbJl1ZK17hpUNjR3Jbg5scKxWh4dH88QigD8UG6sFwaFiKNxfXOJhUhEkO)vaIJeWhc55vrm64H7H9(1AYcaKLadFiKNxfXOJhUhwWD56ZWhc55vrm64H7HJ9jBNarlfaFGpeYZRIyFUyrI2fux6Zc4dH88Qi2NlwKOH7HNc6FfG4ib8HqEEve7Zfls0W9WX(KTtGOLcgn32Xx32WI9jBNa42dna2ky4dH88Qi2NlwKOH7H9(1AYcaKLapAUTlLiy2AbCs8zpI59R1KfailbEPfJhJUZoVrkSyFY2jq0sbycoGYkkzP6KLlhBTI(bgmHBzGTtGymUiClpLk(62gg1LCsGTcg(qipVkI95IfjA4E4yFY2jq0sbWhc55vrSpxSird3dJUAYbf8HqEEve7Zfls0W9WS0WOvNHpeYZRIyFUyrIgUhwWD56ZJMB7c6ZlT3rVGpeYZRIyFUyrIgUh27xRjlaqwcm8HqEEve7Zfls0W9WcUlxFg(qipVkI95IfjA4E4UjYpH0beRXE4dH88Qi2NlwKOH7HZaWCnZ6d0nr(jKo8HqEEve7Zfls0W9WtUlfDYz10LfX8kvoiVa51cqEnOAgHevw)OAw(aWNW5jSniSripVc2Sz0JyWh1qRE)juJjdwTKNx1zcAZvJnJEuLPMpxSirQmv(cvMAiKNxPgb1L(SqnCr4wEQHuxLdIktneYZRuZuq)RaehjudxeULNAi1v5VRYudxeULNAi1GePZIKud(62gwSpz7ea3EObWwbRgc55vQj2NSDceTuG6Q8oPYudxeULNAi1GePZIKuJuGTiy2AbCs8zpI59R1Kfailbg2wc2waBJhdBO7SZBKcl2NSDceTuaMGdOSIWMKHnPcBoz5YXwROFGbt4wgy7eigJlc3YtytQWg(62gg1LCsGTcwneYZRuJ3VwtwaGSey1v5dQYudH88k1e7t2obIwkqnCr4wEQHuxL35Qm1qipVsnORMCqPgUiClp1qQRY7ivMAiKNxPgwAy0QZQHlc3YtnK6QCjsLPgUiClp1qQbjsNfjPgb9zyBPDyRJEPgc55vQrWD56ZQRYLWQm1qipVsnE)AnzbaYsGvdxeULNAi1v5lEPYudH88k1i4UC9z1WfHB5PgsDv(IfQm1qipVsnDtKFcPdiwJ9QHlc3YtnK6Q8fGOYudH88k1KbG5AM1hOBI8tiD1WfHB5PgsDv(I3vzQHqEELAMCxk6KZQHlc3YtnK6QRMjVrRwxLPYxOYudH88k1G6jXNvdxeULNAi1v5GOYudH88k1aEniGTQHlc3YtnK6Q83vzQHlc3YtnKAqI0zrsQzY4RBByik6z9XwbdBsf2KayZjXNDSmcGFXOAiKNxPMy)HgyeQlRUkVtQm1WfHB5Pgsnir6Sij1GUZoVrkmQl5KatWbuwryts7W2hnHTXJHn81TnmQl5KaBfSAiKNxPM1idKohevxLpOktneYZRudU9UjW2Qq6QHlc3YtnK6Q8oxLPgc55vQbNfrwmqwF1WfHB5PgsDvEhPYudH88k1qcevmGFcbxUA4IWT8udPUkxIuzQHqEELAS5V3JalN15pGlxnCr4wEQHuxLlHvzQHqEELA2sbJBVBQgUiClp1qQRYx8sLPgc55vQHkehDbzbqK1QgUiClp1qQRYxSqLPgc55vQbN(a3gGls0ar1WfHB5PgsDv(cquzQHlc3YtnKAqI0zrsQbFDBdJ6sojWwbdBJhdBB5V3beCaLve2KeSbYGQHqEELAaFEEL6Q8fVRYudxeULNAi1GePZIKuJG(m2K3su6WMKGTo9c2KwyZjlxog(Dbz9b6EjIX4IWT8e2KwydDNDEJuyto4eKnFRS(aX(B1XemnLUAiKNxPM8xNGbatzPUkFrNuzQHlc3YtnKAqI0zrsQjl0fK1hysb0NbgmcBlbBVudH88k1GiRfGqEEfGnJUASz0bkkGvtq65N88k1v5lguLPgc55vQH6sojudxeULNAi1v5l6CvMAiKNxPgQqjxoaT5Si2FObudxeULNAi1v5l6ivMAiKNxPMiyMea3gaof98k1WfHB5PgsDv(cjsLPgc55vQbD1BSYItebWPQyHA4IWT8udPUkFHewLPgUiClp1qQbjsNfjPg81TnSyFY2jaU9qdGnVrk1qipVsnX(KTtaC7HgqDvoiVuzQHlc3YtnKAqI0zrsQjcMTwaNeF2JyE)AnzbaYsGHTL2HT3vdH88k1iwlac55va2m6QXMrhOOawn0XQRYbzHktnCr4wEQHudH88k1GiRfGqEEfGnJUASz0bkkGvZNlwKi1vxnGfm6cWjxLPYxOYudH88k1GtUBzGy)T6QHlc3YtnK6QCquzQHqEELAaFEELA4IWT8udPU6Qji98tEELktLVqLPgUiClp1qQbjsNfjPgb9zyBjyBWxWMuHn81TnS8xNGbatzHnVrk1qipVsn5VobdaMYsDvoiQm1WfHB5Pgsnir6Sij1ifytcGnNSC5y4Nn6SaJlc3YtyB8yytcGn81TnmlfDGOt1eBfmSjzytQWMuGnupj(CeytqipVISW2sW2cmjc2gpg2YcDbz9bMua9zGbJWMKvdH88k1e7t2obWThAa1v5VRYudxeULNAi1GePZIKuJuGnNeF2Xgj9(Sw8c2gpg2iKNDzaU4GKJW2sW2cytYWMuHnPaBsb2YcDbz9bMua9zGbJW2sW2lSfdcBslS1ZK17XciPb2gpg26zY69yGroSjjy79xWMKHTXJHnPaBsaS5KLlhd)UGS(aDVeXyCr4wEcBJhdBc6ZybK0aBld2e0NHnjbBD6fSjzytYQHqEELAMCWjiB(wz9bI93QRUkVtQm1WfHB5Pgsnir6Sij1Kf6cY6dmPa6ZaVhHTLGTEMSEpSjvydDNDEJuyuLbeWTbmzY7XeCaLve2K0oSbIAiKNxPglfDGOt1uDv(GQm1WfHB5Pgsnir6Sij1Kf6cY6dmPa6ZadgHTLGTEMSEpSnEmS1ZK17XaJCytsWgiVudH88k1e7t2obgHSw1vxn0XQmv(cvMAiKNxPgb1L(SqnCr4wEQHuxLdIktneYZRuZuq)RaehjudxeULNAi1v5VRYudH88k149R1KfailbwnCr4wEQHuxL3jvMAiKNxPgb3LRpRgUiClp1qQRYhuLPgc55vQj2NSDceTuGA4IWT8udPU6QRU6Qc]] )


end
