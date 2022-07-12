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

                return swing + floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed
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

                return app + floor( t - app )
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


    local rageSpent = 0

    spec:RegisterStateExpr( "rage_spent", function ()
        return rageSpent
    end )


    local outburstRage = 0

    spec:RegisterStateExpr( "outburst_rage", function ()
        return outburstRage
    end )


    local RAGE = Enum.PowerType.Rage
    local lastRage = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "RAGE" then
            local current = UnitPower( "player", RAGE )

            if current < lastRage then
                if state.legendary.glory.enabled and FindUnitBuffByID( "player", 324143 ) then
                    gloryRage = ( gloryRage + lastRage - current ) % 20 -- Glory.
                end

                if state.talent.anger_management.enabled then
                    rageSpent = ( rageSpent + lastRage - current ) % 10 -- Anger Management
                end

                if state.set_bonus.tier28_2pc > 0 then
                    outburstRage = ( outburstRage + lastRage - current ) % 30 -- Outburst.
                end
            end

            lastRage = current
        end
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

            if set_bonus.tier28_2pc > 0 then
                outburst_rage = outburst_rage + amt
                local stacks = floor( outburst_rage / 30 )
                outburst_rage = outburst_rage % 30

                if stacks > 0 then
                    addStack( "seeing_red", nil, stacks )
                end
            end
        end
    end )


    -- Tier 28
    spec:RegisterSetBonuses( "tier28_2pc", 364002, "tier28_4pc", 364639 )
    -- 2-Set - Outburst - Consuming 30 rage grants a stack of Seeing Red, which transforms at 8 stacks into Outburst, causing your next Shield Slam or Thunder Clap to be 200% more effective and grant Ignore Pain.
    -- 4-Set - Outburst - Avatar increases your damage dealt by an additional 10% and decreases damage taken by 10%.
    spec:RegisterAuras( {
        seeing_red = {
            id = 364006,
            duration = 30,
            max_stack = 8,
        },
        outburst = {
            id = 364010,
            duration = 30,
            max_stack = 1
        },
        outburst_buff = {
            id = 364641,
            duration = function () return class.auras.avatar.duration end,
            max_stack = 1,
        }
    })



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
                if set_bonus.tier28_4pc > 0 then
                    applyBuff( "outburst" )
                    applyBuff( "outburst_buff" )
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
            gcd = "off",

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
            gcd = "off",

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
            gcd = "off",

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
                if settings.overlap_ignore_pain then return end

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
            gcd = "off",

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

            nobuff = function()
                if not settings.stack_shield_block or not legendary.reprisal.enabled then return "shield_block" end
            end,

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

                if buff.outburst.up then
                    applyBuff( "ignore_pain" )
                    removeBuff( "outburst" )
                end
            end,
        },


        shield_wall = {
            id = 871,
            cast = 0,
            charges = function () if legendary.unbreakable_will.enabled then return 2 end end,
            cooldown = function () return 240 - conduit.stalwart_guardian.mod * 0.002 end,
            recharge = function () return 240 - conduit.stalwart_guardian.mod * 0.002 end,
            gcd = "off",

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

            toggle = "interrupts",

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
            gcd = "off",

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

                if buff.outburst.up then
                    applyBuff( "ignore_pain" )
                    removeBuff( "outburst" )
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
        name = "Only |T132353:0|t Revenge when Free",
        desc = "If checked, the |T132353:0|t Revenge ability will only be recommended when it costs 0 Rage to use.",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "shockwave_interrupt", true, {
        name = "Only |T236312:0|t Shockwave as Interrupt",
        desc = "If checked, |T236312:0|t Shockwave will only be recommended when your target is casting.",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "overlap_ignore_pain", false, {
        name = "Overlap |T1377132:0|t Ignore Pain",
        desc = "If checked, |T1377132:0|t Ignore Pain can be recommended while it is already active.  This setting may cause you to spend more Rage on mitigation.",
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "stack_shield_block", false, {
        name = "Stack |T132110:0|t Shield Block with Reprisal",
        desc = function()
            return "If checked, the addon can recommend overlapping |T132110:0|t Shield Block usage when using the Reprisal legendary.\n\n" ..
            "This setting avoids leaving Shield Block at 2 charges, which wastes cooldown recovery time.\n\n" ..
            ( state.legendary.reprisal.enabled and "|cFF00FF00" or "|cFFFF0000" ) ..
            "Requires |T236317:0|t Reprisal (legendary)|r"
        end,
        type = "toggle",
        width = "full"
    } )

    spec:RegisterSetting( "heroic_charge", false, {
        name = "Use Heroic Charge (|T236171:0|t + |T132337:0|t) Combo",
        desc = "If checked, the default priority will check |cFFFFD100settings.heroic_charge|r to determine whether to use |T236171:0|t Heroic Leap + |T132337:0|t Charge together.\n\n" ..
            "This is generally a DPS increase but the erratic movement can be disruptive to smooth gameplay.",
        type = "toggle",
        width = "full",
    } )


    spec:RegisterPack( "Protection Warrior", 20220407, [[d009KaqibblcuIEKGOnjeFsiLrji1PeKSkbHQxbQmljvULqQ2Li)cKmmqXXaPwgQspdvvMgGQUMGY2avLVbkvJtsvDoqj16eeY8qvv3dG9HQ4GaQSqa5HGszIccLlkPkTrbvvFusvuJuqv5KGQQwjrmtaf3usvKDkj9tqvfdvqflvqLEQetvs5RsQcJfus2RI)sWGH6WKwmQ8yuMSOUmYMf4ZanAI60QSAqvLEnOkZMIBlu7wQFRQHdIJlOklhYZP00P66eA7sIVJQY4bu68cjRhucZNiTFLEGEQnLS60uLxy4LxyaEyG9e0WA(v)WMIhfeAkqug8uqAkTgttjCqVtm)(EX1dfHUhnfiAuMxZtTPyFreJMIS7qSHiOGc8CzrUe7JHYEXIg1VVzinWHYEXmOMcN4zC4FpCtjRonv5fgE5fgGhgypbnSMFWxyW6PyHqSPkSZVPiF5m1d3uYKLnLWb9oX877fxpue6E0kb4GGoZIH96wmVWWlVRKvcSjRnizxjrFXaxoV46PZpq1VVxS5bp2I9FXnX3IlxmSTyGlCaM0kj6lgyoqzN6fxKpYKxmqMNbVfRDEXWFW(r0Idh96fN1yfKw81UcpAXik8epeftTBtRKOV4WLI)k0IrVR(9TAwSOvbPf)blgyuRV4IRDoTsI(IdxYcHy(IHLHFerloCPkudsWYfBj3VgCXANxmII)k0IFxMqlgrwhDm)(2MwjrFXHF1ywmNYG3I9FX2Rbnu0Dfbs(IHGUhDEul(cwSltlg4GFQ3fRm)(EXMZ6lwwTlUFx(AWf7)IZFAkqqFWzOPeYqU4Wb9oX877fxpue6E0kjKHCXahe0zwmSx3I5fgE5DLSsczixmSjRnizxjHmKlo6lg4Y5fxpD(bQ(99Inp4XwS)lUj(wC5IHTfdCHdWKwjHmKlo6lgyoqzN6fxKpYKxmqMNbVfRDEXWFW(r0Idh96fN1yfKw81UcpAXik8epeftTBtRKqgYfh9fhUu8xHwm6D1VVvZIfTkiT4pyXaJA9fxCTZPvsid5IJ(IdxYcHy(IHLHFerloCPkudsWYfBj3VgCXANxmII)k0IFxMqlgrwhDm)(2MwjHmKlo6lo8RgZI5ug8wS)l2EnOHIURiqYxme09OZJAXxWIDzAXah8t9UyL533l2CwFXYQDX97YxdUy)xC(tRKvsixC9cSet0P8I5OGhrlM9XCQVyoc8ABAXahJrqC7I7VJUSIIdenlwz(9TDXFBIkTsuMFFBtqqe7J5uhaN6UHeSYVOVsuMFFBtqqe7J5uhoaqfyiRmdPb(krz(9TnbbrSpMtD4aaf77WtKqpYkWPDtOvIY87BBccIyFmN6WbakiVFFVswjHCX1lWsmrNYlMQqOOwSFX0IDzAXkZF0Ip7I1k6zuodLwjkZVVTayYkcKwjHCXHyuGkA8fdCHdWen7IHLHpc9hBXWMSIajy5Ip7I1fh(i0FSfdmKczXbVX88r5fZf1IHnzfbsl2)fN)fB)yAXznwbPfRDEXGuti1PfhUkiLwjkZVVTWbakzc9htWqkK6UaawY9RbTjzc9htGjRiqkcsSPGhbsjebbDw1eH9Vj)81jMSIaPeII1RT8hKLxjkZVVTWbakMSIaP6UaawY9RbTjzc9htGjRiqkcsSPGhbsjebbDw1ebcIQKGojtO)ycgsHSsuMFFBHdauqeJJjZkrz(9TfoaqzLFg84tRq1DbaYeNyqqIPw)AWKiKiHGRiqYtNvG7T2vIY87BlCaGs0scNtX26UaaS)n5NVoPvuxrjefRxB5paqwwQuoXGGKwrDfLeHSsuMFFBHdauCM)ZcbIOOwjkZVVTWbakoczje8UgCLOm)(2chaOuetBsWFeIAFLOm)(2chaOmhOSBfGFfZGXu7ReL533w4aavWHioZ)5vIY87BlCaGsBgzDKAeyQXSsuMFFBHdauCkOWhi4OJbp7krz(9TfoaqPvuxrReL533w4aafK3VVR7caWjgeK0kQROKiePs5ERnsWbk7cikwV2YFEdBLOm)(2chaOyQXiOm)(wWCwVUwJjaXNFGQFFxN1rhZbaDDxaGRzF81GcznwbjHWS8aZkrz(9TfoaqX(o8ej0JScCA3eQUlaasSPGhbsjqZJIALOm)(2chaO0kQROvIY87BlCaGsB2rTlOboHSYpdEReL533w4aaLfcPiHpqGtT(99krz(9TfoaqX(o8ej0JScCA3eALOm)(2chaOSYhzYcCMNbV6UaaCIbbjR8rMSaN5zWlLF(6vIY87BlCaGYkFKjlynACDxaaoXGG0l6CIiRNeHSsuMFFBHdauiXwqz(9TG5SEDTgta0NQZ6OJ5aGUUlaGfczmcUIaj3MCzXotibMrHWda(TsuMFFBHdaum1yeuMFFlyoRxxRXeaqQj0XwjReL5332K(eaKwrbj0krz(9TnPpbhaOYif8Bb0ROvIY87BBsFcoaq5YIDMqcmJczLOm)(2M0NGdauiQc1G0krz(9TnPpbhaOSYhzYcwJgVswjkZVVTjqQj0XaG0kkiHwjkZVVTjqQj0XGdauzKc(Ta6v0krz(9TnbsnHogCaGYkFKjlynACDxaaoXGGKv(itwGZ8m4LeHivkNyqq6fDorK1tIqIGuqI)aclSvIY87BBcKAcDm4aaf77mf3ReL5332ei1e6yWbakcyjMOtReL5332ei1e6yWbakR8rMSG1OXReL5332ei1e6yWbakxwSZesGzui1DbaSqiJrWvei52Kll2zcjWmkeEGwQu2)M8ZxNSYhzYcwJgNquSETncNyqq6fDorK1t5NVELOm)(2MaPMqhdoaqHOkuds1DbaqkiXda4dMiUIajpjtQXLtqyop8cJuPCIbbjevHAqkjcjIRiqYtYKAC5eeMZFa8cteKcs8ha01pc7Ft(5Rtw5JmzbRrJtikwV2kvkNyqqcrvOgKsIqI4kcK8KmPgxobH58WlmReL5332ei1e6yWbakxwSZesGzui1Dba4edcsVOZjISEk)81ReL5332ei1e6yWbakevHAqALOm)(2MaPMqhdoaqv5y(JIsajALxjkZVVTjqQj0XGdauxmeQZxdku5y(JIALOm)(2MaPMqhdoaqLPkQ1vNwjReL5332u85hO633aoW(rKae966UaaifK4jmyIWjgeKoW(rKae96u(5RRt0scFqGailda6vIY87BBk(8du97B4aa1b2pIeGOxx3faWvei5jzsnUCccZ5baVWej0UIajpjtQXLtqyopaQpmrcb2xHAT9ufQD5OqHksOrkiXdG6hwe2)M8ZxNSYhzYcwJgNqKMJsQuKcs8aa(Gjc7Ft(5Rtzk(rQ5GfxdkyLFrpHinhvexnu7jU)JVguOYFmkrTYzOSuPifK4baSdte2)M8ZxN0kQROeI0CusLIuqIhaapmry)BYpFDktXpsnhS4AqbR8l6jeP5OI4QHApX9F81Gcv(JrjQvodLJWjgeKmQ1fSU25KiePsrkiXdGWclc7Ft(5RtAf1vucrAoQiCIbbjJADbRRDojcrQuKcs8aO(WivksbjEaewyry)BYpFDYkFKjlynACcrAoQiCIbbPx05erwpjcrQuKcs8aGFWeH9Vj)81jR8rMSG1OXjeP5OIWjgeKErNtez9KiKiCIbbjJADbRRDojcju1jAjHpiqaKLba9krz(9TnfF(bQ(9nCaGYkFKjlWzEg8Q7cae6qWvd1EI7nwNqjQvodLLkne4edcsg16cwx7CsesOIeAMSIajRqasz(9TA4b6u9Lk9A2hFnOqwJvqsimBOwjkZVVTP4Zpq1VVHdauzk(rQ5GfxdkyLFrVoZ1Kalda(Q7caeAxrGKN47C5RHggPsvMFvibQP4JS8aDOIe6qFn7JVguiRXkijeMLhysqhwiUmPgxofRaRuPYKAC5eeMZF(btOKkn0HGRgQ9e3)Xxdku5pgLOw5muwQuKcsPyfyJosbj(d8WeQqTsuMFFBtXNFGQFFdhaOmQ1fSU256UaaxZ(4RbfYAScsc8ZYJmPgxoc7Ft(5RtAFXQWhiKj1LtikwV2YFa8UsuMFFBtXNFGQFFdhaOSYhzYc8PgtDxaGRzF81GcznwbjHWS8itQXLLkvMuJlNGWC(ZlmtPcHS33tvEHHxOHMxyG9PWNI6RbTtPEaCHBv4F165q0IxCnzAXxmKh5lo4rloAzkqfnE0wmIcpXdr5fB)yAXQO)XQt5fZK1gKSPvcWCnTyEdrlg2(UcHCkV4OHeBk4rGucwfTf7)IJgsSPGhbsjyvIALZq5OT4qdnWgQ0kbyUMwm)crlg2(UcHCkV4OHeBk4rGucwfTf7)IJgsSPGhbsjyvIALZq5OT4qdnWgQ0kbyUMwm0WEiAXW23viKt5fhnKytbpcKsWQOTy)xC0qInf8iqkbRsuRCgkhTfR(IRx4hGzXHgAGnuPvYkb(hd5roLxCylwz(99InN1TPvYumN1TtTPasnHo2uBQc9uBkkZVVNcsROGeAkuRCgkpan(uL3P2uuMFFpLmsb)wa9kAkuRCgkpan(uLFtTPqTYzO8a0uyOZj0PtHtmiizLpYKf4mpdEjrilwQ0fZjgeKErNtez9KiKfhzXifKwm)bS4WcBkkZVVNIv(itwWA04XNQa)uBkkZVVNc77mf3tHALZq5bOXNQHn1MIY877PqalXeDAkuRCgkpan(uf(MAtrz(99uSYhzYcwJgpfQvodLhGgFQc7tTPqTYzO8a0uyOZj0PtXcHmgbxrGKBtUSyNjKaZOqwmplg6flv6Iz)BYpFDYkFKjlynACcrX612fhzXCIbbPx05erwpLF(6POm)(EkUSyNjKaZOqgFQw)P2uOw5muEaAkm05e60PGuqAX8ayXWhmloYIDfbsEsMuJlNGW8fZZI5fMflv6I5edcsiQc1GuseYIJSyxrGKNKj14YjimFX8hWI5fMfhzXifKwm)bSyOR)IJSy2)M8ZxNSYhzYcwJgNquSETDXsLUyoXGGeIQqniLeHS4il2vei5jzsnUCccZxmplMxyMIY877PGOkudsJpvH1tTPqTYzO8a0uyOZj0PtHtmii9IoNiY6P8ZxpfL533tXLf7mHeygfY4tvOHzQnfL533tbrvOgKMc1kNHYdqJpvHg6P2uuMFFpLkhZFuucirR8uOw5muEaA8Pk08o1MIY877PCXqOoFnOqLJ5pkQPqTYzO8a04tvO53uBkkZVVNsMQOwxDAkuRCgkpan(4tjtbQOXNAtvONAtHALZq5bOPKjldDq877PuValXeDkVyQcHIAX(ftl2LPfRm)rl(SlwRONr5muAkkZVVNctwrG04tvENAtHALZq5bOPOm)(EkYe6pMGHuitjtwg6G433tjeJcurJVyGlCaMOzxC4Jq)XwmSjRiqAXNDX6IdFe6p2IbgsHS4G3yE(O8I5IAXWMSIaPf7)IZ)ITFmT4SgRG0I1oVyqQjK60IdxfKstHHoNqNofl5(1G2KmH(JjWKveiT4ilgj2uWJaPeIGGoRAsuRCgkV4ilM9Vj)81jMSIaPeII1RTlM)lgKLhFQYVP2uOw5muEaAkm05e60Pyj3Vg0MKj0FmbMSIaPfhzXiXMcEeiLqee0zvtIALZq5fhzXqquLe0jzc9htWqkKPOm)(EkmzfbsJpvb(P2uuMFFpfiIXXKzkuRCgkpan(unSP2uOw5muEaAkm05e60PKjoXGGetT(1GjriloYIdHf7kcK80zf4ERDkkZVVNIv(zWJpTcn(uf(MAtHALZq5bOPWqNtOtNc7Ft(5RtAf1vucrX612fZFalgKLxSuPlMtmiiPvuxrjritrz(99ueTKW5uSD8PkSp1MIY877PWz(pleiIIAkuRCgkpan(uT(tTPOm)(EkCeYsi4Dn4uOw5muEaA8PkSEQnfL533trrmTjb)riQ9PqTYzO8a04tvOHzQnfL533tXCGYUva(vmdgtTpfQvodLhGgFQcn0tTPOm)(EkbhI4m)NNc1kNHYdqJpvHM3P2uuMFFpfTzK1rQrGPgZuOw5muEaA8Pk08BQnfL533tHtbf(abhDm4zNc1kNHYdqJpvHg4NAtrz(99u0kQROPqTYzO8a04tvOdBQnfQvodLhGMcdDoHoDkCIbbjTI6kkjczXsLUyU3AxCKfhCGYUaII1RTlM)lM3WMIY877Pa5977XNQqdFtTPqTYzO8a0uyOZj0Pt5A2hFnOqwJvqsim7I5zXWmfRJoMpvHEkkZVVNctngbL533cMZ6tXCwxO1yAkXNFGQFFp(ufAyFQnfQvodLhGMcdDoHoDkiXMcEeiLanpkQe1kNHYtrz(99uyFhEIe6rwboTBcn(uf66p1MIY877POvuxrtHALZq5bOXNQqdRNAtrz(99u0MDu7cAGtiR8ZG3uOw5muEaA8PkVWm1MIY877PyHqks4de4uRFFpfQvodLhGgFQYl0tTPOm)(EkSVdprc9iRaN2nHMc1kNHYdqJpv5L3P2uOw5muEaAkm05e60PWjgeKSYhzYcCMNbVu(5RNIY877PyLpYKf4mpdEJpv5LFtTPqTYzO8a0uyOZj0PtHtmii9IoNiY6jritrz(99uSYhzYcwJgp(uLxGFQnfQvodLhGMcdDoHoDkwiKXi4kcKCBYLf7mHeygfYI5bWI53uSo6y(uf6POm)(EkiXwqz(9TG5S(umN1fAnMMI(04tvEdBQnfQvodLhGMIY877PWuJrqz(9TG5S(umN1fAnMMci1e6yJp(uGGi2hZP(uBQc9uBkuRCgkpanLmzzOdIFFpL6fyjMOt5fZrbpIwm7J5uFXCe4120IbogJG42f3FhDzffhiAwSY87B7I)2evAkkZVVNcN6UHeSYVOp(uL3P2uuMFFpLadzLzinWNc1kNHYdqJpv53uBkkZVVNc77WtKqpYkWPDtOPqTYzO8a04tvGFQnfL533tbY733tHALZq5bOXhFkXNFGQFFp1MQqp1Mc1kNHYdqtrz(99uoW(rKae96PWqNtOtNcsbPfZZIddMfhzXCIbbPdSFejarVoLF(6PiAjHpiqaKLNQqp(uL3P2uOw5muEaAkkZVVNYb2pIeGOxpfg6CcD6uCfbsEsMuJlNGW8fZdGfZlmloYId9IDfbsEsMuJlNGW8fZdGfxFywCKfhclM9vOwBpvHAxok0Id1IJS4qVyKcslMhalU(HT4ilM9Vj)81jR8rMSG1OXjeP5OwSuPlgPG0I5bWIHpywCKfZ(3KF(6uMIFKAoyX1Gcw5x0tisZrT4il2vd1EI7)4RbfQ8hJsuRCgkVyPsxmsbPfZdGfd7WS4ilM9Vj)81jTI6kkHinh1ILkDXifKwmpawmWdZIJSy2)M8ZxNYu8JuZblUguWk)IEcrAoQfhzXUAO2tC)hFnOqL)yuIALZq5fhzXCIbbjJADbRRDojczXsLUyKcslMhaloSWwCKfZ(3KF(6KwrDfLqKMJAXrwmNyqqYOwxW6ANtIqwSuPlgPG0I5bWIRpmlwQ0fJuqAX8ayXHf2IJSy2)M8ZxNSYhzYcwJgNqKMJAXrwmNyqq6fDorK1tIqwSuPlgPG0I5bWI5hmloYIz)BYpFDYkFKjlynACcrAoQfhzXCIbbPx05erwpjczXrwmNyqqYOwxW6ANtIqwCOMIOLe(GabqwEQc94tv(n1Mc1kNHYdqtHHoNqNoLqV4qyXUAO2tCVX6ekrTYzO8ILkDXHWI5edcsg16cwx7CseYId1IJS4qVyMSIajRqasz(9TAwmplg6u9xSuPl(A2hFnOqwJvqsim7Id1uuMFFpfR8rMSaN5zWB8PkWp1Mc1kNHYdqtrz(99uYu8JuZblUguWk)I(uyOZj0Ptj0l2vei5j(ox(AOHzXsLUyL5xfsGAk(i7I5zXqV4qT4ilo0lo0l(A2hFnOqwJvqsim7I5zXWKGoSfhIVyzsnUCkwb2flv6ILj14YjimFX8FX8dMfhQflv6Id9IdHf7QHApX9F81Gcv(JrjQvodLxSuPlgPGukwb2fh9fJuqAX8FXapmlouloutXCnjWYtb(gFQg2uBkuRCgkpanfg6CcD6uUM9XxdkK1yfKe4NDX8SyzsnU8IJSy2)M8ZxN0(IvHpqitQlNquSETDX8hWI5DkkZVVNIrTUG11op(uf(MAtHALZq5bOPWqNtOtNY1Sp(AqHSgRGKqy2fZZILj14YlwQ0fltQXLtqy(I5)I5fMPOm)(Ekw5Jmzb(uJz8XNI(0uBQc9uBkkZVVNcsROGeAkuRCgkpan(uL3P2uuMFFpLmsb)wa9kAkuRCgkpan(uLFtTPOm)(EkUSyNjKaZOqMc1kNHYdqJpvb(P2uuMFFpfevHAqAkuRCgkpan(unSP2uuMFFpfR8rMSG1OXtHALZq5bOXhF8POIU8JMs5IfnQFFdBinWhF8za]] )


end
