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


    spec:RegisterPack( "Protection Warrior", 20210413, [[dGKWyaqiOiweuiEKkuBIKWOiH6uKqwLef9kfYSuHClsI2fO(LKyyqjhtsAzqPEguuttbX1uOABKKsFtIsghuOoNcsTossrZJe09uj7tHYbHI0cLipubjxKKuzJqb1jHcYkbYmLOWnHcWojP(jjPWqjbSujk1tj1ujrFLKu1EP8xqgSGdJSyO6XqMSIUmQnRI(mGrlPoTOvdfqVwIQzt0TLWUL63knCG64qH0Yj8CHMovxxLA7kW3vqnEsGopjjRhkqZxfSFvTv1uA6j5SPgBSWUkwdPkMHXUk2dDvmBAxvGztdMqLtaSPBQGnTciwNrEU9hu9KqKRW0GjvjxAAknDCVfi201UdoQAwPcq6134WOTOsmlULKNBJe0PxjMfOkMg)oLogQnCtpjNn1yJf2vXAivXmm2vXEORw10rWmYuxwy2015CYTHB6jhrMwbeRZip3(dQEsiYv8GWuWIu(bm(OpGnwyx9b9GgQAQb44dsLFatNZpGbKEcqEU9hKlqI(GVFO5H)GolgQpGPkqza)Gu5hkJeO25(d66KLZpusUOY)a1ZpGHa6vWFqbOS)WKkia(dz7u58hemg9ofCb3Ee(bPYpu2CXoG)GyDYZTj5hUJea)H98dLbf9pODQNWpiv(HYMJGzK)bmcgwW8hkBEa3amg5dr29Sb(a1Zpi4IDa)H1RzXheC0fjYZTJWpiv(bmmjLFaNqL)bF)qmBajRsNeaS)bWICfPRQpKNFWR5pGPQgQUpqip3(dYm6FOMIFOxVoBGp47hMlSPbl2ZuYM(4J)GciwNrEU9hu9KqKR4bD8XFatbls5hW4J(a2yHD1h0d64J)WqvtnahFqhF8hu5hW058dyaPNaKNB)b5cKOp47hAE4pOZIH6dyQcugWpOJp(dQ8dLrcu7C)bDDYY5hkjxu5FG65hWqa9k4pOau2Fysfea)HSDQC(dcgJENcUGBpc)Go(4pOYpu2CXoG)GyDYZTj5hUJea)H98dLbf9pODQNWpOJp(dQ8dLnhbZi)dyemSG5pu28aUbymYhIS7zd8bQNFqWf7a(dRxZIpi4OlsKNBhHFqhF8hu5hWWKu(bCcv(h89dXSbKSkDsaW(halYvKUQ(qE(bVM)aMQAO6(aH8C7piZO)HAk(HE96Sb(GVFyUWpOheH8C7imybJ2cCYhDvbNCxYqX692FqeYZTJWGfmAlWjF0vfWRNB)GEqhF8huDkiJUDE(bEalu1h8SG)GxZFGq(k(qg)anGsjHlz4heH8C74fQMea8dIqEUDC0vfW3ffS8brip3oo6QsSErLpmnGpkpVMm(95jmIIE2aW3GvbM4KaGD4mcHVX4dIqEUDC0vL7idLoxepkpVq7kN7WnmnGCsal4ck7OcVaqZdhWVppHPbKtc4BWpic552XrxvWL7oHoVfQ6brip3oo6QcolISO8SbEqeYZTJJUQqce1mKVcb3(dIqEUDC0vfzcu7rimW7jqb3(dIqEUDC0vLZuW4YDNpic552XrxvOgXrxqsiejLpic552XrxvWjaO9eYfjQ84dIqEUDC0vfWRNBFuEEHFFEctdiNeW3GpC4mbQDibxqzhvi2J)GiKNBhhDvjb6vWqGPSpkpVeeadp5ZeLUchcwLPtsUDy8DlYgaAWMigMBcxYZYeTRCUd3WtUyfKmXGzdafR3BhwW0uvpic552XrxvqKucrip3gsMr)OMk4RI0taYZTpkpVYgTfzdanPccGHgpogwpic552XrxvObKtIheH8C74ORkuJsUDi60zrSErL)GiKNBhhDvjcMjb0EcHtrp3(brip3oo6QcABm6nlwrecN6Mfpic552XrxvI1jlNq4Yfv(r55f(95jCSoz5ecxUOYHN7W9dIqEUDC0vfejLqeYZTHKz0pQPc(Iw(O88kcMLsiNeaShH967EYciKKap2fMFqeYZTJJUQGiPeIqEUnKmJ(rnvWxaCZIe9GEqeYZTJWfPNaKNBFLa9kyiWu2hLNxccGhBCSub(95jCc0RGHatzdp3H7heH8C7iCr6ja552JUQeRtwoHWLlQ8JYZlfJjoj52HXxz0zbm3eUKNhoGj43NNWsk6qrN6j8nyfPcfJQjbahHofeYZTj5yvHX4dhYgTfzdanPccGHgpQOheH8C7iCr6ja552JUQm5IvqYedMnauSEV9JYZlf7KaGD4HtVo7QyD4aH8CadXnxKCCSQksfkwXzJ2ISbGMubbWqJhhdl4QJxM1mj9A4csbpCOMjPxddg5keZyPOdhumM4KKBhgF3ISbGgSjIH5MWL88WbbbWWfKcQsbbWkCiyPif9GiKNBhHlspbip3E0vfjfDOOt98O88kB0wKna0KkiagcZXXQzs61QaTRCUd3WuNfe0EcnzYRHfCbLDuHxy)GiKNBhHlspbip3E0vLyDYYj0WKuEuEELnAlYgaAsfeadnECSAMKE9Hd1mj9AyWixHyJ1d6brip3octlFjObealEqeYZTJW0YJUQmfeW2qILepic552ryA5rxv867EYciKKa)GiKNBhHPLhDvrWd4gGFqeYZTJW0YJUQeRtwoHIsQ4b9GiKNBhHb4Mfj6sqdiaw8GiKNBhHb4MfjA0vLPGa2gsSK4brip3ocdWnls0ORkX6KLtOOKkokpVWVppHJ1jlNq4Yfvo8n4heH8C7ima3SirJUQ4139Kfqijb(O88sXrWSuc5KaG9iSxF3twaHKe4XQE4aAx5ChUHJ1jlNqrjval4ck7OIuHtsUD47o6lyWeUKHoxbIH5MWL8uf43NNW0aYjb8n4heH8C7ima3SirJUQeRtwoHIsQ4brip3ocdWnls0ORkOTNCr)GiKNBhHb4MfjA0vfwbz0TZpic552ryaUzrIgDvrWd4gGpkpVeeap2vzH1dIqEUDegGBwKOrxv867EYciKKa)GiKNBhHb4MfjA0vfbpGBa(brip3ocdWnls0ORkdsKVcvbjUJ1pic552ryaUzrIgDvjlaZ9mBaObjYxHQEqeYZTJWaCZIen6QYKhqrNC20dyrm32uJnwyxflSXcJn9WKOZgiAAmub4v488dJ)bc552FqMrpc)GmnD71RW06S4wsEU9qjOt30Ym6rtPPb4MfjYuAQRAknnH8CBtlObealmn3eUKNwjZn1yBknnH8CBtpfeW2qILeMMBcxYtRK5MAmBknn3eUKNwjtJePZIKmn(95jCSoz5ecxUOYHVbBAc552MowNSCcfLuH5M6Hyknn3eUKNwjtJePZIKmTI)qemlLqojaypc7139Kfqijb(dJ9HQF4WHpG2vo3HB4yDYYjuusfWcUGYo(bf9bv8bNKC7W3D0xWGjCjdDUcedZnHl55huXhWVppHPbKtc4BWMMqEUTP967EYciKKaBUPECtPPjKNBB6yDYYjuusfMMBcxYtRK5MAvRP00eYZTnnA7jx0MMBcxYtRK5M6YYuAAc552MMvqgD7SP5MWL80kzUPgJnLMMBcxYtRKPrI0zrsMwqa8hg76dLfwMMqEUTPf8aUbyZn1dTP00eYZTnTxF3twaHKeytZnHl5PvYCtDvSmLMMqEUTPf8aUbytZnHl5PvYCtD1QMsttip320dsKVcvbjUJ1MMBcxYtRK5M6QyBknnH8CBtNfG5EMna0Ge5RqvMMBcxYtRK5M6Qy2uAAc552MEYdOOtoBAUjCjpTsMBUPN8jDlDtPPUQP00eYZTnnQMeaSP5MWL80kzUPgBtPPjKNBBAW3ffS00Ct4sEALm3uJztPP5MWL80kzAKiDwKKPNm(95jmIIE2aW3G)Gk(aM8bNeaSdNri8ngnnH8CBthRxu5dtdyZn1dXuAAUjCjpTsMgjsNfjzA0UY5oCdtdiNeWcUGYo(bfE9ba08dho8b87ZtyAa5Ka(gSPjKNBB67idLoxen3upUP00eYZTnnUC3j05TqvMMBcxYtRK5MAvRP00eYZTnnolISO8Sbmn3eUKNwjZn1LLP00eYZTnnjquZq(keC7MMBcxYtRK5MAm2uAAc552MwMa1Eecd8EcuWTBAUjCjpTsMBQhAtPPjKNBB6ZuW4YDNMMBcxYtRK5M6QyzknnH8CBttnIJUGKqisknn3eUKNwjZn1vRAknnH8CBtJtaq7jKlsu5rtZnHl5PvYCtDvSnLMMBcxYtRKPrI0zrsMg)(8eMgqojGVb)Hdh(Wzcu7qcUGYo(bf(bSh30eYZTnn41ZTn3uxfZMstZnHl5PvY0ir6SijtliagEYNjk9pOWpmeS(qz(bNKC7W47wKna0Gnrmm3eUKNFOm)aAx5ChUHNCXkizIbZgakwV3oSGPPQmnH8CBtNa9kyiWu2MBQRoetPP5MWL80kzAKiDwKKPZgTfzdanPccGHgp(HX(awMMqEUTPrKucrip3gsMr30Ym6qnvWMUi9eG8CBZn1vh3uAAc552MMgqojmn3eUKNwjZn1vvTMsttip320uJsUDi60zrSErLBAUjCjpTsMBQRwwMsttip320rWmjG2tiCk652MMBcxYtRK5M6QySP00eYZTnnABm6nlwrecN6MfMMBcxYtRK5M6QdTP00Ct4sEALmnsKolsY043NNWX6KLtiC5IkhEUd3MMqEUTPJ1jlNq4YfvU5MASXYuAAUjCjpTsMgjsNfjz6iywkHCsaWEe2RV7jlGqsc8hg76dy20eYZTnnIKsic552qYm6MwMrhQPc200YMBQXUQP00Ct4sEALmnH8CBtJiPeIqEUnKmJUPLz0HAQGnna3SirMBUPbly0wGtUP0ux1uAAc552MgNCxYqX692nn3eUKNwjZn1yBknnH8CBtdE9CBtZnHl5PvYCZnDr6ja552MstDvtPP5MWL80kzAKiDwKKPfea)HX(W4y9bv8b87Zt4eOxbdbMYgEUd3MMqEUTPtGEfmeykBZn1yBknn3eUKNwjtJePZIKmTI)aM8bNKC7W4Rm6SaMBcxYZpC4WhWKpGFFEclPOdfDQNW3G)GI(Gk(GI)aQMeaCe6uqip3MKFySpufgJ)WHdFiB0wKna0KkiagA84huKPjKNBB6yDYYjeUCrLBUPgZMstZnHl5PvY0ir6SijtR4p4KaGD4HtVo7Qy9Hdh(aH8CadXnxKC8dJ9HQFqrFqfFqXFqXFiB0wKna0KkiagA84hg7dybxD8puMFOMjPxdxqk4hoC4d1mj9AyWi)dk8dygRpOOpC4Whu8hWKp4KKBhgF3ISbGgSjIH5MWL88dho8bbbWWfKc(bv(bbbWFqHFyiy9bf9bfzAc552MEYfRGKjgmBaOy9E7MBQhIP00Ct4sEALmnsKolsY0zJ2ISbGMubbWqyo(HX(qntsV(dQ4dODLZD4gM6SGG2tOjtEnSGlOSJFqHxFaBttip320sk6qrN6P5M6XnLMMBcxYtRKPrI0zrsMoB0wKna0KkiagA84hg7d1mj96pC4WhQzs61WGr(hu4hWglttip320X6KLtOHjP0CZnnTSP0ux1uAAc552MwqdiawyAUjCjpTsMBQX2uAAc552MEkiGTHeljmn3eUKNwjZn1y2uAAc552M2RV7jlGqscSP5MWL80kzUPEiMsttip320cEa3aSP5MWL80kzUPECtPPjKNBB6yDYYjuusfMMBcxYtRK5MBU5MBg]] )


end
