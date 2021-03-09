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
                if toggle.defensives and buff.ignore_pain.down then return false, "don't spend on revenge if ignore_pain is down" end
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


    spec:RegisterPack( "Protection Warrior", 20210208, [[dCeiyaqiOeTivjPhbLAtqLAuqvCkOQSkPc5vkWSuO6wkOAxa9lb1WuL6ykKLbv8mvjMMsuUMsKTPGcFtQqnoLO6Cqj16uqrnpOkDpLQ9Pq5GQsQwOG8qfu6IkOiBekjojucTsvXmLkOBQkjStIQHcvslvQapLIPsu(kusAVK(lGblLdJSyI8yitwrxg1MvkFwvnAPQtlA1QsIETurZMs3wGDl53QmCO44qjy5eEUqtNQRRK2UuPVRGmEOsCEOQA9QskZxjSFqRJuzQzsoRYX5noJEJZ7LdocRFbRFzzQXXpgwnyiuN0NvtrbSAWvX5mYZRGnSkje5judgc)2JMQm1eVvbIvtV7yIdZHd)tVFvceDbHJzWQL88kKG28WXmafwnsRP1XILkPMj5SkhN34m6noVxo4iS(fS(LrQjIHrQ8o(f10NZjxQKAMCePgSXg2WvX5mYZRGnSkje5jGpyJnSHvyjXkjWpST8XHnCEJZi4d8bBSHTHTNQphHpyJnSnCy71Nty7vKE(jpVc2S3prWMFWwXdbBMmyyHTxhx7qq4d2ydBdh26W837CbBM(KTtylK9qDcBunHnS4VobdB4kLfSnPa6ZWwwo1jdBcglSMcoGlpccFWgByB4WwhWbxxg2eNtEEfzHT1i9zy72GToKIoSzCQMGWhSXg2goS1bCedJCy7vXkcMHToG7Y1NFvylYUN1h2OAcBco46YW259Sa2eC0fjYZRIGQbJ42slRgSXg2WvX5mYZRGnSkje5jGpyJnSHvyjXkjWpST8XHnCEJZi4d8bBSHTHTNQphHpyJnSnCy71Nty7vKE(jpVc2S3prWMFWwXdbBMmyyHTxhx7qq4d2ydBdh26W837CbBM(KTtylK9qDcBunHnS4VobdB4kLfSnPa6ZWwwo1jdBcglSMcoGlpccFWgByB4WwhWbxxg2eNtEEfzHT1i9zy72GToKIoSzCQMGWhSXg2goS1bCedJCy7vXkcMHToG7Y1NFvylYUN1h2OAcBco46YW259Sa2eC0fjYZRIGWh4dH88QiigbJUajYhShwIC3YaX(B1HpeYZRIGyem6cKiFWEymNNxbFGpyJnSnmHlmA15jSXDzb(HnpdyyZ7zyJq(jGTmcBuxkTKKLbHpeYZRI7OEs8z4dH88Q4G9Wywdcyl8HqEEvCWE4y)H6CiQlpEUTpzP1Tnqef9S(GRyWnw6K4ZoygbKUye(qipVkoyp8AKbsNdIJNB7O7SZBOcK6sojafCaLveV7F0CXcP1TnqQl5KaCfd8HqEEvCWEyj7DtGTvb(HpeYZRId2dlXIil6mRp8HqEEvCWEysGOIb8ti4YHpeYZRId2dBZFVhbELRZFaxo8HqEEvCWE4TuWs27MWhc55vXb7HPcXrxqwaezTWhc55vXb7HLOpWTb4Ie1ze(qipVkoypmMZZRgp32Lw32aPUKtcWvmlwSL)EhqWbuwr8IZsWhc55vXb7HZFDcgadL1452UG(m4K3su64DzV7iNSC5Gs3fK1hO7LigKlsYYZocDNDEdvGto4eKnFTS(aX(B1bfmnXp8HqEEvCWEyezTaeYZRaSz0hVOaEpi98tEE1452EwOliRpWKcOpdSuCS3Whc55vXb7HPUKtc4dH88Q4G9WuHsUCaAZzrS)qDcFiKNxfhShoIHjbWTbirrpVc(qipVkoypm6kSWkloreqIQIfWhc55vXb7HJ9jBNas2d15452U062gySpz7eqYEOobN3qf8HqEEvCWEyXAbqipVcWMrF8Ic4D64XZT9ig2AbCs8zpc69R1KfailHzS9xGpeYZRId2dJiRfGqEEfGnJ(4ffW7FUyrIGpWhc55vrWG0Zp55v75VobdGHYA8CBxqFESLEJBP1TnW8xNGbWqzboVHk4dH88Qiyq65N88Qb7HJ9jBNas2d15452oEWsNSC5GsNn6SaKlsYYZflWsP1TnqlfDGOt1eCfd(WnEq9K4ZrGnbH88kYo2iWLVyrwOliRpWKcOpdSueFWhc55vrWG0Zp55vd2dp5Gtq281Y6de7VvF8CBhpoj(Sdou69zn69IfeYZUmaxCqYXXgHpCJh8Kf6cY6dmPa6Zalfh7n4OL6OEMSEpyaHllw0ZK17bXGC8(YB8TybEWsNSC5Gs3fK1hO7LigKlsYYZfle0NbdiCz4c6Z4DzVXh(GpeYZRIGbPNFYZRgSh2srhi6unhp32ZcDbz9bMua9zGxIJ1ZK17Xn6o78gQaPkdiGBdyYK3dk4akRiE3Xb(qipVkcgKE(jpVAWE4yFY2jWqK1oEUTNf6cY6dmPa6ZalfhRNjR3VyrptwVhedYXloVHpWhc55vrq64Db1L(Sa(qipVkcshpyp8uq)RaehjGpeYZRIG0Xd2d79R1KfailHb(qipVkcshpypSG7Y1NHpeYZRIG0Xd2dh7t2obIwka(aFiKNxfb)CXIeTlOU0NfWhc55vrWpxSird2dpf0)kaXrc4dH88Qi4NlwKOb7HJ9jBNarlfmEUTlTUTbg7t2obKShQtWvmWhc55vrWpxSird2d79R1KfailHz8CBhprmS1c4K4ZEe07xRjlaqwcZyJwSaDNDEdvGX(KTtGOLcafCaLveF42jlxo4Af9ddgsYYaBNaXGCrswEIBP1TnqQl5KaCfd8HqEEve8Zfls0G9WX(KTtGOLcGpeYZRIGFUyrIgShgD1Kdk4dH88Qi4NlwKOb7HzCHrRodFiKNxfb)CXIenypSG7Y1Nhp32f0NhBVJFdFiKNxfb)CXIenypS3VwtwaGSeg4dH88Qi4NlwKOb7HfCxU(m8HqEEve8Zfls0G9WDtKFc8diwJ9Whc55vrWpxSird2dNby4AM1hOBI8tGF4dH88Qi4NlwKOb7HNCxk6KZQPllI5vQCCEJZO348gh1mejQS(r1GfdWCcNNW2sWgH88kyZMrpccFuJnJEuLPMpxSirQmv(ivMAiKNxPgb1L(SqnCrswEQHuxLJJktneYZRuZuq)RaehjudxKKLNAi1v5VOYudxKKLNAi1GePZIKuJ062gySpz7eqYEOobxXOgc55vQj2NSDceTuG6Q8LPYudxKKLNAi1GePZIKudEGTig2AbCs8zpc69R1KfailHb2gd2gbBlwaBO7SZBOcm2NSDceTuaOGdOSIWg(GnCdBoz5YbxROFyWqswgy7eigKlsYYtyd3WM062gi1LCsaUIrneYZRuJ3VwtwaGSeg1v5lPYudH88k1e7t2obIwkqnCrswEQHuxLpmuzQHqEELAqxn5GsnCrswEQHuxL3XQm1qipVsnmUWOvNvdxKKLNAi1v5lxLPgUijlp1qQbjsNfjPgb9zyBSDyRJFRgc55vQrWD56ZQRYXAvMAiKNxPgVFTMSaazjmQHlsYYtnK6Q8rVvzQHqEELAeCxU(SA4IKS8udPUkF0ivMAiKNxPMUjYpb(beRXE1Wfjz5PgsDv(iCuzQHqEELAYamCnZ6d0nr(jWVA4IKS8udPUkF0lQm1qipVsntUlfDYz1Wfjz5PgsD1vZK3OvRRYu5JuzQHqEELAq9K4ZQHlsYYtnK6QCCuzQHqEELAWSgeWw1Wfjz5PgsDv(lQm1Wfjz5Pgsnir6Sij1mzP1Tnqef9S(GRyGnCdByjS5K4ZoygbKUyuneYZRutS)qDoe1LvxLVmvMA4IKS8udPgKiDwKKAq3zN3qfi1LCsak4akRiSH3Dy7JMW2IfWM062gi1LCsaUIrneYZRuZAKbsNdIQRYxsLPgc55vQrYE3eyBvGF1Wfjz5PgsDv(WqLPgc55vQrIfrw0zwF1Wfjz5PgsDvEhRYudH88k1qcevmGFcbxUA4IKS8udPUkF5Qm1qipVsn2837rGx568hWLRgUijlp1qQRYXAvMAiKNxPMTuWs27MQHlsYYtnK6Q8rVvzQHqEELAOcXrxqwaezTQHlsYYtnK6Q8rJuzQHqEELAKOpWTb4Ie1zunCrswEQHuxLpchvMA4IKS8udPgKiDwKKAKw32aPUKtcWvmW2IfW2w(7DabhqzfHn8cB4SKAiKNxPgmNNxPUkF0lQm1Wfjz5Pgsnir6Sij1iOpdo5TeLoSHxyBzVHToc2CYYLdkDxqwFGUxIyqUijlpHToc2q3zN3qf4KdobzZxlRpqS)wDqbtt8Rgc55vQj)1jyamuwQRYhTmvMA4IKS8udPgKiDwKKAYcDbz9bMua9zGLIW2yW2B1qipVsniYAbiKNxbyZORgBgDGIcy1eKE(jpVsDv(OLuzQHqEELAOUKtc1Wfjz5PgsDv(OHHktneYZRudvOKlhG2Cwe7puNQHlsYYtnK6Q8rDSktneYZRutedtcGBdqIIEELA4IKS8udPUkF0YvzQHqEELAqxHfwzXjIasuvSqnCrswEQHuxLpcRvzQHlsYYtnKAqI0zrsQrADBdm2NSDcizpuNGZBOsneYZRutSpz7eqYEOovxLJZBvMA4IKS8udPgKiDwKKAIyyRfWjXN9iO3VwtwaGSegyBSDy7f1qipVsnI1cGqEEfGnJUASz0bkkGvdDS6QCCgPYudxKKLNAi1qipVsniYAbiKNxbyZORgBgDGIcy185IfjsD1vdgbJUajYvzQ8rQm1qipVsnsK7wgi2FRUA4IKS8udPUkhhvMAiKNxPgmNNxPgUijlp1qQRUAcsp)KNxPYu5JuzQHlsYYtnKAqI0zrsQrqFg2gd2w6nSHBytADBdm)1jyamuwGZBOsneYZRut(RtWayOSuxLJJktnCrswEQHudsKolssn4b2WsyZjlxoO0zJola5IKS8e2wSa2WsytADBd0srhi6unbxXaB4d2WnSHhyd1tIphb2eeYZRilSngSncC5W2IfWwwOliRpWKcOpdSue2WNAiKNxPMyFY2jGK9qDQUk)fvMA4IKS8udPgKiDwKKAWdS5K4Zo4qP3N1O3W2IfWgH8SldWfhKCe2gd2gbB4d2WnSHhydpWwwOliRpWKcOpdSue2gd2EdoAjyRJGTEMSEpyaHlW2IfWwptwVhedYHn8cBV8g2WhSTybSHhydlHnNSC5Gs3fK1hO7LigKlsYYtyBXcytqFgmGWfyB4WMG(mSHxyBzVHn8bB4tneYZRuZKdobzZxlRpqS)wD1v5ltLPgUijlp1qQbjsNfjPMSqxqwFGjfqFg4LiSngS1ZK17HnCdBO7SZBOcKQmGaUnGjtEpOGdOSIWgE3HnCudH88k1yPOdeDQMQRYxsLPgUijlp1qQbjsNfjPMSqxqwFGjfqFgyPiSngS1ZK17HTflGTEMSEpigKdB4f2W5TAiKNxPMyFY2jWqK1QU6QHowLPYhPYudH88k1iOU0NfQHlsYYtnK6QCCuzQHqEELAMc6FfG4iHA4IKS8udPUk)fvMAiKNxPgVFTMSaazjmQHlsYYtnK6Q8LPYudH88k1i4UC9z1Wfjz5PgsDv(sQm1qipVsnX(KTtGOLcudxKKLNAi1vxD1qRE)juJjdwTKNxnScAZvxDvb]] )


end
