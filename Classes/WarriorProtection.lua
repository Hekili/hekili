-- WarriorProtection.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local FindUnitBuffByID = ns.FindUnitBuffByID

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

        conquerors_banner = {
            aura = "conquerors_banner",

            last = function ()
                local app = state.buff.conquerors_banner.applied
                local t = state.query_time

                return app + ( floor( ( t - app ) / ( 1 * state.haste ) ) * ( 1 * state.haste ) )
            end,

            interval = 1,

            value = 4,
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
        rebound = 833, -- 213915
        shield_bash = 173, -- 198912
        sword_and_board = 167, -- 199127
        thunderstruck = 175, -- 199045
        warbringer = 5432, -- 356353
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


    local gloryRage = 0

spec:RegisterStateExpr( "glory_rage", function ()
        return gloryRage
    end )

    local RAGE = Enum.PowerType.Rage
    local lastRage = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "RAGE" and state.legendary.glory.enabled and FindUnitBuffByID( "player", 324143 ) then
            local current = UnitPower( "player", RAGE )

            if current < lastRage then
                gloryRage = ( gloryRage + lastRage - current ) % 20 -- Glory.
            end

            lastRage = current
        end
    end )

    spec:RegisterStateExpr( "glory_rage", function ()
        return gloryRage
    end )

    -- model rage expenditure reducing CDs...
    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "rage" and amt > 0 then
            if talent.anger_management.enabled then
                rage_spent = rage_spent + amt
                local secs = floor( rage_spent / 10 )
                rage_spent = rage_spent % 10

                cooldown.avatar.expires = cooldown.avatar.expires - secs
                reduceCooldown( "shield_wall", secs )
                -- cooldown.last_stand.expires = cooldown.last_stand.expires - secs
                -- cooldown.demoralizing_shout.expires = cooldown.demoralizing_shout.expires - secs
            end

            if legendary.glory.enabled and buff.conquerors_banner.up then
                glory_rage = glory_rage + amt
                local reduction = floor( glory_rage / 10 ) * 0.5
                glory_rage = glory_rage % 10
    
                buff.conquerors_banner.expires = buff.conquerors_banner.expires + reduction
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
                if legendary.reprisal.enabled then
                    applyBuff( "shield_block", 4 )
                    applyBuff( "revenge" )
                    gain( 20, "rage" )
                end
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
                if legendary.reprisal.enabled then
                    applyBuff( "shield_block", 4 )
                    applyBuff( "revenge" )
                    gain( 20, "rage" )
                end
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
                if buff.revenge.up then return 0 end
                return 20
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 132353,

            usable = function ()
                if action.revenge.cost == 0 then return true end
                if toggle.defensives and buff.ignore_pain.down and incoming_damage_5s > 0.1 * health.max then return false, "don't spend on revenge if ignore_pain is down and there is incoming damage" end
                if settings.free_revenge and action.revenge.cost ~= 0 then return false, "free_revenge is checked and revenge is not free" end

                return true
            end,

            handler = function ()
                if buff.revenge.up then removeBuff( "revenge" ) end
                if conduit.show_of_force.enabled then applyBuff( "show_of_force" ) end
            end,

            auras = {
                -- Conduit
                show_of_force = {
                    id = 339825,
                    duration = 12,
                    max_stack = 1
                },
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
            charges = function () if legendary.unbreakable_will.enabled then return 2 end end,
            cooldown = function () return 240 - conduit.stalwart_guardian.mod * 0.002 end,
            recharge = function () return 240 - conduit.stalwart_guardian.mod * 0.002 end,
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
            debuff = function () return settings.shockwave_interrupt and "casting" or nil end,
            readyTime = function () return settings.shockwave_interrupt and timeToInterrupt() or nil end,

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
        width = "full"
    } )

    spec:RegisterSetting( "shockwave_interrupt", true, {
        name = "Use Shockwave as Interrupt",
        desc = "If checked, Shockwave will only be recommended with a target that is casting.",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "heroic_charge", false, {
        name = "Use Heroic Charge Combo",
        desc = "If checked, the default priority will check |cFFFFD100settings.heroic_charge|r to determine whether to use Heroic Leap + Charge together.\n\n" ..
            "This is generally a DPS increase but the erratic movement can be disruptive to smooth gameplay.",
        type = "toggle",
        width = "full",
    } )


    spec:RegisterPack( "Protection Warrior", 20210627, [[d0KNCaqiuvQfrrQEeOInPq8juvzuOk5uOk1Qqvb9kLkZsPWTOiSlG(LOQHrsCmfLLHQ4zGQAAOQKRPqABOQkFJKunoLQY5OiLwhOsmpkIUhOSpLQCqqvAHIkpurftevf4IOQO2iQk0hrvvvJevvLtQOsTsqAMuKCtuvvzNuu)KIumuqvSuqL6PImvsQVIQImwfvYEf(lQmyOomXIjXJrzYk5YiBwbFgWOPWPLA1GkPETIQMnPUTOSBj)wvdhehNKuwoKNtPPt11vKTRq9DLIgVsv15jjz9GkjZxP0(v5ywOoslXPWmpQWZmv4pE2hOk7B0rNP6rYvfeksqe28cafPsYOibpO3jM3FDy(KGq9JIeerv6xwH6iz)jeJIKH7qSWL85bA3ysbK9z5TD2Kw8(lgsg882oJLpsktT2N7kuI0sCkmZJk8mtf(JN9bQY(gD0zWpswielmR6Wpsg9ArvOePfzzrcEqVtmV)6W8jbH6hDqHov0H5r134W8OcpZoOh05yifazpOM4WW7ADy(V2BaX7VoS(bA2H9)WfT5HtD2Com8cpMc8GAIdBQgWWP6WjJM0RdNt)S5pSuRdp3a1JOddpsxhEjzcaD4UCzE6Wis1MAeLrLBbpOM4WWnL9JPdJEx8(lrF4jRaqh(hoSPeRF4Kl1c8GAIdd3KfcX8dB68rerhgUPXubqM(HTK7DbCyPwhgrz)y6WVBqOdJiRJAM3FzbpOM4W8rrRpSIWM)W(FyBxaAYeUGai)Wqq9JAxvhUhoSBqhgEnn85dlmV)6W626h2qShUE3OlGd7)HxpyKGG(HwtrcoW5WWd6DI59xhMpjiu)OdkCGZHHov0H5r134W8OcpZoOhu4aNdphdPai7bfoW5WM4WW7ADy(V2BaX7VoS(bA2H9)WfT5HtD2Com8cpMc8Gch4CytCyt1agovhoz0KED4C6Nn)HLAD45gOEeDy4r66WljtaOd3LlZthgrQ2uJOmQCl4bfoW5WM4WWnL9JPdJEx8(lrF4jRaqh(hoSPeRF4Kl1c8Gch4CytCy4MSqiMFytNpIi6WWnnMkaY0pSLCVlGdl16Wik7hth(DdcDyezDuZ8(ll4bfoW5WM4W8rrRpSIWM)W(FyBxaAYeUGai)Wqq9JAxvhUhoSBqhgEnn85dlmV)6W626h2qShUE3OlGd7)Hxp4b9GkmV)YccbrSptr8DWYRiURjoRXp5huH59xwqiiI9zkIVdwEiV3FDqpOWbohMpVFIn506W0ycPQd7DgDy3GoSW8hD42EyzS0ArrtGhuH59xwymdbbqhu4Cy(aAqM0(HHx4Xu8ZEytN)rOVzhEogccGm9d32dlhM)rOVzh2uKa5WdVw)BsRdROQdphdbbqh2)dV(dB)m6WljtaOdl16WauriXPdd3cabEqfM3Fz3blVbH(MXPjbYg9aml5Exawqdc9nJJziiaAe0urdpcGareeuBf9iS)1RFZcKziiacerzsxwtcWwhuH59x2DWYZmeeaTrpaZsU3fGf0GqFZ4ygccGgbnv0WJaiqebb1wrpceengCgObH(MXPjbYbvyE)LDhS8qMYYi9bvyE)LDhS8wJNn)MYyAJEa2IuMggazI17caCcYi8TliaYbBlNYBThuH59x2DWYpzjU2Pm7g9am2)61VzbkJfxqGikt6YAsyaS12TktddGYyXfe4eKdQW8(l7oy5v0)V4gMqQ6GkmV)YUdwEfczj08DbCqfM3Fz3blVGysrC(Jqu5huH59x2DWYRBad3YbxpTaYOYpOcZ7VS7GLFOrKI()1bvyE)LDhS8sXiRJenht06dQW8(l7oy5veaUFGZrnBE7bvyE)LDhS8qEV)AJEaMY0WaOmwCbbobz72HgWW5quM0L1K8m6bvyE)LDhS8mrR5eM3FXPBRVrjzeSS2BaX7V2OhG1f7Z6cGBjzcaXnQDpvoOcZ7VS7GLN9LQnrOhz5uKQi0g9am0urdpcGab0psvhuH59x2DWYlJfxqhuH59x2DWYlfRPY5KbNqwJNn)bvyE)LDhS8wiKG4(bofX69xhuH59x2DWYZ(s1Mi0JSCksve6GkmV)YUdwERrt6fNI(zZVrpatzAya0A0KEXPOF28GRFZ6GkmV)YUdwEMO1CcZ7V40T13OKmcM80g9amlesR5CbbqUf0nMQfH4yAbYEWG)bvyE)LDhS8mrR5eM3FXPBRVrjzemaQiuZoOhuH59xwWS2BaX7VG1a1JioisxB0dWqcaT3OQmIY0WaydupI4GiDbU(nRdQW8(llyw7nG49x7GL3A0KEXPOF28B0dW4fF7IMkhu51wNqGujkAATDlFRmnmaQfRZzDPwGtq49i8IziiaYYnGeM3Fj69MbUVTB7I9zDbWTKmbG4g1Y7dQW8(llyw7nG49x7GLFrzps0nCvxaCwJFY3q3fXXwW4Vn6by8Yfea5GB2UrxZuz7wH59yIJkkRj7EZ49i8IxDX(SUa4wsMaqCJA3tfWzJYhAqI2naZK9VDRbjA3aecZnj8vH3B3Yl(2fnvoOY)zDbWn(BgbsLOOP12TibGaZK9BcKaqMKVuH38(GkmV)YcM1EdiE)1oy51I15SUuRn6byDX(SUa4wsMaqCW3UNbjA3ye2)61VzbkvNjC)a3Ie3aerzsxwtcJNdQW8(llyw7nG49x7GL3A0KEXTPO1B0dW6I9zDbWTKmbG4g1UNbjA3y7wds0UbieMBsEu5GEqfM3FzbLNGHKXcaHoOcZ7VSGYt7GLFHeGV4qVGoOcZ7VSGYt7GL3nMQfH4yAbYbvyE)LfuEAhS8iAmva0bvyE)LfuEAhS8wJM0loRwYoOhuH59xwqaQiuZGHKXcaHoOcZ7VSGaurOMTdw(fsa(Id9c6GkmV)YccqfHA2oy5TgnPxCwTKTrpatzAya0A0KEXPOF28GtqoOcZ7VSGaurOMTdwE3yQweIJPfiB0dW4LfcP1CUGai3c6gt1IqCmTazVzB3Y(xV(nlqRrt6fNvlzGikt6YY7rCrtLdovw)Haru0e3WJyeivIIMwJOmnmakJfxqGtqoOcZ7VSGaurOMTdwERrt6fNvlzhuH59xwqaQiuZ2blp7RfLvhuH59xwqaQiuZ2blpTFIn50bvyE)LfeGkc1SDWYJOXubqB0dWqcaT3(uzexqaKdAqI2naHW894rLTBvMggar0yQaiWjihuH59xwqaQiuZ2blVBmvlcXX0cKdQW8(lliaveQz7GLhrJPcGoOcZ7VSGaurOMTdw(XnZFKQ4qtwJdQW8(lliaveQz7GLVZGq1QlaUXnZFKQoOcZ7VSGaurOMTdw(fnwSU4uKgtiB)vyMhv4zMk81m4hPnfu1fGns8j4fUnp3M5)Hlh(WQnOd3zqEKF4HhDy(TObzs787Wis1MAeToS9ZOdlt(NjoTomZqkaYcEqnvx0H5bUC4581yc506W8dnv0WJaiW5IFh2)dZp0urdpcGaNlqQefnT43H51S9ZBWdQP6Iom8HlhEoFnMqoTom)qtfn8iacCU43H9)W8dnv0WJaiW5cKkrrtl(DyEnB)8g8GAQUOdpJ)GlhEoFnMqoTom)qtfn8iacCU43H9)W8dnv0WJaiW5cKkrrtl(DyXpmF20yQdZRz7N3Gh0d6CNb5roTo8OhwyE)1H1T1TGh0iPBRBd1rcGkc1SqDyEwOoscZ7VIesglaeksujkAAf5cpmZtOoscZ7VI0cjaFXHEbfjQefnTICHhMHFOosujkAAf5Ied1oHAjsktddGwJM0lof9ZMhCcsKeM3FfjRrt6fNvlzHhM5RqDKOsu00kYfjgQDc1sK41HTqiTMZfea5wq3yQweIJPfihEVdp7WB3Ey2)61VzbAnAsV4SAjderzsx2dZ7dpYHDrtLdovw)Haru0e3WJyeivIIMwhEKdRmnmakJfxqGtqIKW8(Ri5gt1IqCmTaj8W8OH6ijmV)kswJM0loRwYIevIIMwrUWdZ8xOoscZ7VIe7RfLvrIkrrtRix4HzvpuhjH59xrI2pXMCksujkAAf5cpmVVqDKOsu00kYfjgQDc1sKqcaD49o8(u5WJCyxqaKdAqI2naHW8dV3H5rLdVD7HvMggar0yQaiWjirsyE)vKq0yQaOWdZM2qDKeM3Ffj3yQweIJPfirIkrrtRix4H5zQeQJKW8(RiHOXubqrIkrrtRix4H5zZc1rsyE)vKg3m)rQIdnznIevIIMwrUWdZZ4juhjH59xrQZGq1QlaUXnZFKQIevIIMwrUWdZZGFOoscZ7VI0IglwxCksujkAAf5cp8iTObzs7H6W8SqDKeM3FfjMHGaOirLOOPvKl8WmpH6irLOOPvKlscZ7VIKbH(MXPjbsKwKLHAiE)vK4dObzs7hgEHhtXp7H5Fe6B2HNJHGaOd32dlhM)rOVzh2uKa5WdVw)BsRdROQdphdbbqh2)dV(dB)m6WljtaOdl16WauriXPdd3cabgjgQDc1sKSK7Dbybni03moMHGaOdpYHrtfn8iacerqqTv0GujkAAD4rom7F963SazgccGaruM0L9WM8WaSv4Hz4hQJevIIMwrUiXqTtOwIKLCVlalObH(MXXmeeaD4romAQOHhbqGiccQTIgKkrrtRdpYHHGOXGZani03monjqIKW8(RiXmeeafEyMVc1rsyE)vKGmLLr6irLOOPvKl8W8OH6irLOOPvKlsmu7eQLiTiLPHbqMy9UaaNGC4romFFyxqaKd2woL3AJKW8(RiznE28BkJPWdZ8xOosujkAAf5Ied1oHAjsS)1RFZcuglUGaruM0L9WMe2HbyRdVD7HvMggaLXIliWjirsyE)vKMSex7uMn8WSQhQJKW8(RiPO)FXnmHuvKOsu00kYfEyEFH6ijmV)kskeYsO57cisujkAAf5cpmBAd1rsyE)vKeetkIZFeIkpsujkAAf5cpmptLqDKeM3FfjDdy4wo46PfqgvEKOsu00kYfEyE2SqDKeM3FfPHgrk6)xrIkrrtRix4H5z8eQJKW8(RijfJSos0CmrRJevIIMwrUWdZZGFOoscZ7VIKIaW9dCoQzZBJevIIMwrUWdZZ4RqDKOsu00kYfjgQDc1sKuMggaLXIliWjihE72dp0agohIYKUSh2KhMNrJKW8(Rib59(RWdZZgnuhjQefnTICrIHANqTePUyFwxaCljtaiUrThEVdRsKeM3FfjMO1CcZ7V40T1JKUToxjzuKYAVbeV)k8W8m(luhjQefnTICrIHANqTej0urdpcGab0psvGujkAAfjH59xrI9LQnrOhz5uKQiu4H5zQEOoscZ7VIKmwCbfjQefnTICHhMNTVqDKeM3FfjPynvoNm4eYA8S5JevIIMwrUWdZZmTH6ijmV)kswiKG4(bofX69xrIkrrtRix4HzEujuhjH59xrI9LQnrOhz5uKQiuKOsu00kYfEyMNzH6irLOOPvKlsmu7eQLiPmnmaAnAsV4u0pBEW1VzfjH59xrYA0KEXPOF28HhM5HNqDKOsu00kYfjgQDc1sKSqiTMZfea5wq3yQweIJPfihEpyhg(rsyE)vKyIwZjmV)It3wps626CLKrrsEk8WmpWpuhjQefnTICrsyE)vKyIwZjmV)It3wps626CLKrrcGkc1SWdpsqqe7ZuepuhMNfQJKW8(RiPiURjoRXp5rIkrrtRix4HzEc1rsyE)vKG8E)vKOsu00kYfE4rkR9gq8(RqDyEwOosujkAAf5Ied1oHAjsibGo8EhEuvo8ihwzAyaSbQhrCqKUax)MvKeM3FfPgOEeXbr6k8WmpH6irLOOPvKlsmu7eQLiXRdZ3h2fnvoOYRToHaPsu006WB3Ey((WktddGAX6CwxQf4eKdZ7dpYH51HzgccGSCdiH59xI(W7D4zG77WB3E4UyFwxaCljtaiUrThM3rsyE)vKSgnPxCk6NnF4Hz4hQJevIIMwrUijmV)kslk7rIUHR6cGZA8tEKyO2julrIxh2fea5GB2UrxZu5WB3EyH59yIJkkRj7H37WZomVp8ihMxhMxhUl2N1fa3sYeaIBu7H37WQaoB0dZhEyds0UbyMS)dVD7Hnir7gGqy(Hn5HHVkhM3hE72dZRdZ3h2fnvoOY)zDbWn(BgbsLOOP1H3U9WibGaZK9FytCyKaqh2KhMVu5W8(W8os6Uio2ks8x4Hz(kuhjQefnTICrIHANqTePUyFwxaCljtaio4Bp8Eh2GeTBC4rom7F963SaLQZeUFGBrIBaIOmPl7HnjSdZtKeM3FfjTyDoRl1k8W8OH6irLOOPvKlsmu7eQLi1f7Z6cGBjzcaXnQ9W7Dyds0UXH3U9WgKODdqim)WM8W8OsKeM3FfjRrt6f3MIwhE4rsEkuhMNfQJKW8(RiHKXcaHIevIIMwrUWdZ8eQJKW8(RiTqcWxCOxqrIkrrtRix4Hz4hQJKW8(Ri5gt1IqCmTajsujkAAf5cpmZxH6ijmV)ksiAmvauKOsu00kYfEyE0qDKeM3FfjRrt6fNvlzrIkrrtRix4HhEKKj34rrk1ztAX7VMdsg8Wdpca]] )


end
