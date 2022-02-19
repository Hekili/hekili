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


    spec:RegisterPack( "Protection Warrior", 20211207, [[d0KZCaqiuv0IOuv9iqL2KcQpHQsJcvPofQswfQQsELsLzPGClkvSlG(LIyyKuoMOYYav9mfjtJKkDnLs2gjv8nuvvJJKQ6CuQkTofPQ5rPk3du2NsPoiQcwOc8qfPmrufLUiQQInIQc9ruvLAKOQGtcQiReKMjLkDtqfv7KK8tkvfdfvrwkQc9urMkLYxrvunwfPYEf(lQmyuomXIjXJHAYk5YiBwH(mGrtjNwYQrvu8ALcZMu3wu2Tu)wvdhehNKQSCipNIPt11vuBxu13vkA8GkCEuvz9GkkZxPQ9RYrUWwKwItHk4vd(C5Gxn(he(PMAQTMkso)GqrcIG3qaOi1sgfjEc9oH967JXZfeQEuKGi8t)YkSfjZpJWuKSChIz6NmbOCRzfq8NnXuzZAXRVXiz0NyQm8KiPmxAho1HsKwItHk4vd(C5Gxn(he(PMAQTYfjdechQ4)PIKvTwuhkrArgCK4j07e2RVpgpxqO6rhuvFEktHqhl3udDm4vd(Ch0d60SKgGmhu7CmEyTogCE5fG413ht)af(y(FSM28yPkBAhJh4j7cEqTZXSBby5uFSKvr61XgOF8ght61XGta9JOJXts1hBjzcaDSQDzd6yis9MleLrTBapO25y8iL95PJHEx86BrFSzJaqh7hpMDfJFSKl9c8GANJXJKbcH9Jz)8rerhJhP8udq2)XmK7vdCmPxhdrzFE6yVBrOJHiJJkSxFBapO25y8rrRpMIG34y(Fmt1aAYoUGai)yqq1JkNFhRgpMBrhJhSp8NJjyV((y6Y4hZsmhRF3QAGJ5)XwpyKGG(XstrcUW9y8e6Dc713hJNliu9OdkCH7Xu95PmfcDSCtn0XGxn4ZDqpOWfUhBAwsdqMdkCH7XSZX4H16yW5LxaIxFFm9du4J5)XAAZJLQSPDmEGNSl4bfUW9y25y2TaSCQpwYQi96yd0pEJJj96yWjG(r0X4jP6JTKmbGow1USbDmePEZfIYO2nGhu4c3JzNJXJu2NNog6DXRVf9XMncaDSF8y2vm(XsU0lWdkCH7XSZX4rYaHW(XSF(iIOJXJuEQbi7)ygY9QboM0RJHOSppDS3Ti0XqKXrf2RVnGhu4c3JzNJXhfT(ykcEJJ5)XmvdOj74ccG8JbbvpQC(DSA8yUfDmEW(WFoMG967JPlJFmlXCS(DRQboM)hB9Gh0dQG96BdieeH)mfX3bBII4UM4mw)SFqfSxFBaHGi8NPi(oytG8E99b9Gcx4Em(dCq4zNwhJYti(DmVYOJ5w0XeS)OJvMJj5LslkAc8GkyV(2adBjia6Gc3JXZsJYS2pgpWt2LVMJz)8bc9f(ytZsqaK9FSYCm5y8bc9f(y2LeihB816FtADmf(DSPzjia6y(FS1FmZNrhBjzcaDmPxhdGAcjoDmEuaiWdQG96BZoytSi0xyonjqgQgHzi3RgWaArOVWCylbbqdJMBA8raeiIGGkJOhg)VE9B2GylbbqGiktQ2ypa86GkyV(2Sd2eSLGaOHQrygY9QbmGwe6lmh2sqa0WO5MgFeabIiiOYi6HHGO8G5aTi0xyonjqoOc2RVn7GnbYCwgPpOc2RVn7GnXy94n2uYtdvJWwKY84iiwmE1aGZqgMpDbbqoyz4uEJ5GkyV(2Sd2KzdXvoLzgQgHH)xV(nBqjV4ccerzs1g7bdaV2VxzECeuYlUGaNHCqfSxFB2bBII()f34mIFhub713MDWMOqidH2OAGdQG96BZoyteewAIZFeIA)GkyV(2Sd2eDby5goEM5fqg1(bvWE9TzhSjJfIu0)VoOc2RVn7GnrAmzCKO5WIwFqfSxFB2bBIIaW9JCoQWByoOc2RVn7GnbY713dvJWuMhhbL8IliWzi73pwawohIYKQn2d(ToOc2RVn7GnblAnNG96BoDz8HAjJGLvEbiE99qghvyhwUHQryvJ)SQb4wsMaqCBz2wTdQG96BZoytWFREZe6rgofPBcnuncdn304Jaiqa9J43bvWE9TzhSjsEXf0bvWE9TzhSjsJlQDoz0jKX6XBCqfSxFB2bBIbcjiUFKtrmE99bvWE9TzhSj4VvVzc9idNI0nHoOc2RVn7GnXyvKEXPOF8gdvJWuMhhbnwfPxCk6hVb463SpOc2RVn7GnblAnNG96BoDz8HAjJGjpnKXrf2HLBOAeMbcP1CUGai3a6wZ9IqCyTazBytDqfSxFB2bBcw0Aob713C6Y4d1sgbdGAcv4d6bvWE9TbmR8cq86Byfq)iIdIu9q1imKaqBVLAdRmpocwa9Jiois1GRFZ(GkyV(2aMvEbiE99oytmwfPxCk6hVXq1imEZNUOP2bvETXjei1IIMw73ZNkZJJGAX4Cgx6f4meEnmVXwccGmCJib713IE7CGQ)(9vJ)SQb4wsMaqCBz41bvWE9TbmR8cq867DWMSOShj6coRAaoJ1p7dPRM4WlyQZq1imE7ccGCWnl3Q6CQTFVG9kpXrnLvKz7C8AyEZ7QXFw1aCljtaiUTmBRgyUT4VSir7wGzcCSFVfjA3cec2T3uQXR975nF6IMAhu5)SQb4Y)fMaPwu00A)EKaqGzcCyhKaq2tDvJx86GkyV(2aMvEbiE99oyt0IX5mU0RHQryvJ)SQb4wsMaqCtz22IeTBnm(F963SbLUYeUFKBrIBbIOmPAJ9Gb)bvWE9TbmR8cq867DWMySksV42u06HQryvJ)SQb4wsMaqCBz22IeTBTFVfjA3cec2Th8QDqpOc2RVnGYtWqsEbGqhub713gq5PDWMSqcW3COxqhub713gq5PDWM4wZ9IqCyTa5GkyV(2akpTd2eeLNAa6GkyV(2akpTd2eJvr6fNrlzh0dQG96Bdia1eQWWqsEbGqhub713gqaQjuH3bBYcjaFZHEbDqfSxFBabOMqfEhSjgRI0loJwYgQgHPmpocASksV4u0pEdWzihub713gqaQjuH3bBIBn3lcXH1cKHQry82aH0AoxqaKBaDR5ErioSwGSDU97X)Rx)MnOXQi9IZOLmqeLjvB41WUOP2bNBJ)qGikAIB8rycKArrtRHvMhhbL8IliWzihub713gqaQjuH3bBIXQi9IZOLSdQG96Bdia1eQW7Gnb)9IY6dQG96Bdia1eQW7GnHGdcp70bvWE9TbeGAcv4DWMGO8udqdvJWqcaTT6R2WUGaih0IeTBbcb7BdVA73RmpocIO8udqGZqoOc2RVnGautOcVd2e3AUxeIdRfihub713gqaQjuH3bBcIYtnaDqfSxFBabOMqfEhSj5lS)i(XHMnwhub713gqaQjuH3bBsLbH6v1aC5lS)i(DqfSxFBabOMqfEhSjlkVyCXPiLNqM67qf8QbFo1uh45)iTPG6QbmrINZd8Ok4Kk(7P)yhZMfDSkdYJ8Jn(OJX3fnkZANVhdrQ3CHO1XmFgDmz2)mXP1XWwsdqgWdQDRMog8t)XM235jKtRJXx0CtJpcGaNo(Em)pgFrZnn(iacC6aPwu00IVhJ35GdEbEqTB10XMA6p20(opHCADm(IMBA8rae40X3J5)X4lAUPXhbqGthi1IIMw89y8ohCWlWdQDRMowo1z6p20(opHCADm(IMBA8rae40X3J5)X4lAUPXhbqGthi1IIMw89yIFm(J9XUhJ35GdEbEqpOWPmipYP1X26yc2RVpMUmUb8GgjDzCtylsautOch2cv5cBrsWE9DKqsEbGqrIArrtRyq4Hk4dBrsWE9DKwib4Bo0lOirTOOPvmi8q1uHTirTOOPvmisyu5eQKiPmpocASksV4u0pEdWzirsWE9DKmwfPxCgTKfEOsDdBrIArrtRyqKWOYjujrI3hZaH0AoxqaKBaDR5ErioSwGCSTpwUJTF)XW)Rx)MnOXQi9IZOLmqeLjvBogVo2WhZfn1o4CB8hcerrtCJpctGulkAADSHpMY84iOKxCbbodjsc2RVJKBn3lcXH1cKWdvBf2IKG967izSksV4mAjlsulkAAfdcpuPoHTijyV(os4VxuwhjQffnTIbHhQ4)WwKeSxFhjcoi8StrIArrtRyq4Hk1pSfjQffnTIbrcJkNqLejKaqhB7JP(QDSHpMliaYbTir7wGqW(X2(yWR2X2V)ykZJJGikp1ae4mKijyV(osikp1au4Hk7Bylsc2RVJKBn3lcXH1cKirTOOPvmi8qvo1cBrsWE9DKquEQbOirTOOPvmi8qvUCHTijyV(os5lS)i(XHMnwrIArrtRyq4HQCWh2IKG967ivzqOEvnax(c7pIFrIArrtRyq4HQCtf2IKG967iTO8IXfNIe1IIMwXGWdpslAuM1EyluLlSfjb713rcBjiaksulkAAfdcpubFylsulkAAfdIKG967izrOVWCAsGePfzWOcIxFhjEwAuM1(X4bEYU81Cm(aH(cFSPzjia6yL5yYX4de6l8XSljqo24R1)M06yk87ytZsqa0X8)yR)yMpJo2sYea6ysVoga1esC6y8OaqGrcJkNqLejd5E1agqlc9fMdBjia6ydFm0CtJpcGareeuzeni1IIMwhB4JH)xV(nBqSLGaiqeLjvBoM9ogaEfEOAQWwKOwu00kgejmQCcvsKmK7vdyaTi0xyoSLGaOJn8XqZnn(iacerqqLr0GulkAADSHpgeeLhmhOfH(cZPjbsKeSxFhjSLGaOWdvQBylsc2RVJeK5SmshjQffnTIbHhQ2kSfjQffnTIbrcJkNqLePfPmpocIfJxna4mKJn8X4ZJ5ccGCWYWP8gtKeSxFhjJ1J3ytjpfEOsDcBrIArrtRyqKWOYjujrc)VE9B2GsEXfeiIYKQnhZEWogaEDS97pMY84iOKxCbbodjsc2RVJ0SH4kNYmHhQ4)WwKeSxFhjf9)lUXze)Ie1IIMwXGWdvQFylsc2RVJKcHmeAJQbIe1IIMwXGWdv23WwKeSxFhjbHLM48hHO2Je1IIMwXGWdv5ulSfjb713rsxawUHJNzEbKrThjQffnTIbHhQYLlSfjb713rASqKI()vKOwu00kgeEOkh8HTijyV(ossJjJJenhw06irTOOPvmi8qvUPcBrsWE9DKueaUFKZrfEdtKOwu00kgeEOkN6g2Ie1IIMwXGiHrLtOsIKY84iOKxCbbod5y73FSXcWY5quMuT5y27yWVvKeSxFhjiVxFhEOk3wHTirTOOPvmisyu5eQKivn(ZQgGBjzcaXTL5yBFm1IKXrf2dv5IKG967iHfTMtWE9nNUmEK0LX5AjJIuw5fG413HhQYPoHTirTOOPvmisyu5eQKiHMBA8raeiG(r8dKArrtRijyV(os4VvVzc9idNI0nHcpuLJ)dBrsWE9DKK8IlOirTOOPvmi8qvo1pSfjb713rsACrTZjJoHmwpEJirTOOPvmi8qvo7Bylsc2RVJKbcjiUFKtrmE9DKOwu00kgeEOcE1cBrsWE9DKWFREZe6rgofPBcfjQffnTIbHhQGpxylsulkAAfdIegvoHkjskZJJGgRI0lof9J3aC9B2rsWE9DKmwfPxCk6hVr4Hk4HpSfjQffnTIbrcJkNqLejdesR5CbbqUb0TM7fH4WAbYX2g2XMksghvypuLlsc2RVJew0Aob713C6Y4rsxgNRLmksYtHhQGFQWwKOwu00kgejb713rclAnNG96BoDz8iPlJZ1sgfjaQjuHdp8ibbr4ptr8WwOkxylsc2RVJKI4UM4mw)ShjQffnTIbHhQGpSfjb713rcY713rIArrtRyq4HhPSYlaXRVdBHQCHTirTOOPvmisyu5eQKiHea6yBFSTu7ydFmL5XrWcOFeXbrQgC9B2rsWE9DKkG(reheP6WdvWh2Ie1IIMwXGiHrLtOsIeVpgFEmx0u7GkV24ecKArrtRJTF)X4ZJPmpocQfJZzCPxGZqogVo2WhJ3hdBjiaYWnIeSxFl6JT9XYbQ(hB)(Jvn(ZQgGBjzcaXTL5y8ksc2RVJKXQi9Itr)4ncpunvylsulkAAfdIKG967iTOShj6coRAaoJ1p7rcJkNqLejEFmxqaKdUz5wvNtTJTF)XeSx5joQPSImhB7JL7y86ydFmEFmEFSQXFw1aCljtaiUTmhB7JPgyUTog)1XSir7wGzcCCS97pMfjA3cec2pM9o2uQDmEDS97pgVpgFEmx0u7Gk)Nvnax(VWei1IIMwhB)(JHeacmtGJJzNJHea6y27yQRAhJxhJxrsxnXHxrsDcpuPUHTirTOOPvmisyu5eQKivn(ZQgGBjzcaXnL5yBFmls0U1Xg(y4)1RFZgu6kt4(rUfjUfiIYKQnhZEWog8rsWE9DK0IX5mU0RWdvBf2Ie1IIMwXGiHrLtOsIu14pRAaULKjae3wMJT9XSir7whB)(JzrI2TaHG9JzVJbVArsWE9DKmwfPxCBkAD4Hhj5PWwOkxylsc2RVJesYlaeksulkAAfdcpubFylsc2RVJ0cjaFZHEbfjQffnTIbHhQMkSfjb713rYTM7fH4WAbsKOwu00kgeEOsDdBrsWE9DKquEQbOirTOOPvmi8q1wHTijyV(osgRI0loJwYIe1IIMwXGWdp8ijZU1JIuQYM1IxFpnKm6HhEea]] )


end
