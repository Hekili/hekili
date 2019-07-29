-- WarriorArms.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 71 )

    local base_rage_gen, arms_rage_mult = 1.75, 4.000

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand = {
            last = function ()
                local swing = state.combat == 0 and state.now or state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = 'mainhand_speed',

            stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * arms_rage_mult * state.swings.mainhand_speed / state.haste
            end,
        }
    } )

    -- Talents
    spec:RegisterTalents( {
        war_machine = 22624, -- 262231
        sudden_death = 22360, -- 29725
        skullsplitter = 22371, -- 260643

        double_time = 19676, -- 103827
        impending_victory = 22372, -- 202168
        storm_bolt = 22789, -- 107570

        massacre = 22380, -- 281001
        fervor_of_battle = 22489, -- 202316
        rend = 19138, -- 772

        second_wind = 15757, -- 29838
        bounding_stride = 22627, -- 202163
        defensive_stance = 22628, -- 197690

        collateral_damage = 22392, -- 268243
        warbreaker = 22391, -- 262161
        cleave = 22362, -- 845

        in_for_the_kill = 22394, -- 248621
        avatar = 22397, -- 107574
        deadly_calm = 22399, -- 262228

        anger_management = 21204, -- 152278
        dreadnaught = 22407, -- 262150
        ravager = 21667, -- 152277
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3589, -- 208683
        relentless = 3588, -- 196029
        adaptation = 3587, -- 214027

        duel = 34, -- 236273
        disarm = 3534, -- 236077
        sharpen_blade = 33, -- 198817
        war_banner = 32, -- 236320
        spell_reflection = 3521, -- 216890
        death_sentence = 3522, -- 198500
        master_and_commander = 28, -- 235941
        shadow_of_the_colossus = 29, -- 198807
        storm_of_destruction = 31, -- 236308
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
        bladestorm = {
            id = 227847,
            duration = 6,
            max_stack = 1,
        },
        bounding_stride = {
            id = 202164,
            duration = 3,
            max_stack = 1,
        },
        colossus_smash = {
            id = 208086,
            duration = 10,
            max_stack = 1,
        },
        deadly_calm = {
            id = 262228,
            duration = 6,
            max_stack = 1,
        },
        deep_wounds = {
            id = 262115,
            duration = 6,
            max_stack = 1,
        },
        defensive_stance = {
            id = 197690,
            duration = 3600,
            max_stack = 1,
        },
        die_by_the_sword = {
            id = 118038,
            duration = 8,
            max_stack = 1,
        },
        hamstring = {
            id = 1715,
            duration = 15,
            max_stack = 1,
        },
        in_for_the_kill = {
            id = 248622,
            duration = 10,
            max_stack = 1,
        },
        intimidating_shout = {
            id = 5246,
            duration = 8,
            max_stack = 1,
        },
        mortal_wounds = {
            id = 115804,
            duration = 10,
            max_stack = 1,
        },
        overpower = {
            id = 7384,
            duration = 15,
            max_stack = 2,
        },
        rallying_cry = {
            id = 97463,
            duration = 10,
            max_stack = 1,
        },
        --[[ ravager = {
            id = 152277,
        }, ]]
        rend = {
            id = 772,
            duration = 12,
            tick_time = 3,
            max_stack = 1,
        },
        --[[ seasoned_soldier = {
            id = 279423,
        }, ]]
        sign_of_the_emissary = {
            id = 225788,
            duration = 3600,
            max_stack = 1,
        },
        stone_heart = {
            id = 225947,
            duration = 10,
        },
        sudden_death = {
            id = 52437,
            duration = 10,
            max_stack = 1,
        },
        sweeping_strikes = {
            id = 260708,
            duration = 12,
            max_stack = 1,
        },
        --[[ tactician = {
            id = 184783,
        }, ]]
        taunt = {
            id = 355,
            duration = 3,
            max_stack = 1,
        },
        victorious = {
            id = 32216,
            duration = 20,
            max_stack = 1,
        },

        -- Azerite Powers
        crushing_assault = {
            id = 278826,
            duration = 10,
            max_stack = 1
        },        

        gathering_storm = {
            id = 273415,
            duration = 6,
            max_stack = 5,
        },

        intimidating_presence = {
            id = 288644,
            duration = 12,
            max_stack = 1,
        },

        striking_the_anvil = {
            id = 288455,
            duration = 15,
            max_stack = 1,
        },

        test_of_might = {
            id = 275540,
            duration = 12,
            max_stack = 1
        }
    } )


    local rageSpent = 0

    spec:RegisterHook( "spend", function( amt, resource )
        if talent.anger_management.enabled and resource == "rage" then
            rageSpent = rageSpent + amt
            local reduction = floor( rageSpent / 20 )
            rageSpent = rageSpent % 20

            if reduction > 0 then
                cooldown.colossus_smash.expires = cooldown.colossus_smash.expires - reduction
                cooldown.bladestorm.expires = cooldown.bladestorm.expires - reduction
                cooldown.warbreaker.expires = cooldown.warbreaker.expires - reduction
            end
        end
    end )


    local last_cs_target = nil

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" and spellName == class.abilities.colossus_smash.name then
            last_cs_target = destGUID
        end
    end )


    spec:RegisterHook( "reset_precast", function ()
        rageSpent = 0
        if buff.bladestorm.up then
            setCooldown( "global_cooldown", max( cooldown.global_cooldown.remains, buff.bladestorm.remains ) )
            if buff.gathering_storm.up then applyBuff( "gathering_storm", buff.bladestorm.remains + 6, 4 ) end
        end

        if prev_gcd[1].colossus_smash and time - action.colossus_smash.lastCast < 1 and last_cs_target == target.unit and debuff.colossus_smash.down then
            -- Apply Colossus Smash early because its application is delayed for some reason.
            applyDebuff( "target", "colossus_smash", 10 )
        end
    end )


    spec:RegisterGear( 'tier20', 147187, 147188, 147189, 147190, 147191, 147192 )
        spec:RegisterAura( "raging_thirst", {
            id = 242300, 
            duration = 8
         } ) -- fury 2pc.
        spec:RegisterAura( "bloody_rage", {
            id = 242952,
            duration = 10,
            max_stack = 10
         } ) -- fury 4pc.

    spec:RegisterGear( 'tier21', 152178, 152179, 152180, 152181, 152182, 152183 )
        spec:RegisterAura( "war_veteran", {
            id = 253382,
            duration = 8
         } ) -- arms 2pc.
        spec:RegisterAura( "weighted_blade", { 
            id = 253383,  
            duration = 1,
            max_stack = 3
        } ) -- arms 4pc.

    spec:RegisterGear( "ceannar_charger", 137088 )
    spec:RegisterGear( "timeless_stratagem", 143728 )
    spec:RegisterGear( "kazzalax_fujiedas_fury", 137053 )
        spec:RegisterAura( "fujiedas_fury", {
            id = 207776,
            duration = 10,
            max_stack = 4 
        } )
    spec:RegisterGear( "mannoroths_bloodletting_manacles", 137107 ) -- NYI.
    spec:RegisterGear( "najentuss_vertebrae", 137087 )
    spec:RegisterGear( "valarjar_berserkers", 151824 )
    spec:RegisterGear( "ayalas_stone_heart", 137052 )
        spec:RegisterAura( "stone_heart", { id = 225947,
            duration = 10
        } )
    spec:RegisterGear( "the_great_storms_eye", 151823 )
        spec:RegisterAura( "tornados_eye", {
            id = 248142, 
            duration = 6, 
            max_stack = 6
        } )
    spec:RegisterGear( "archavons_heavy_hand", 137060 )
    spec:RegisterGear( "weight_of_the_earth", 137077 ) -- NYI.


    spec:RegisterGear( "soul_of_the_battlelord", 151650 )



    -- Abilities
    spec:RegisterAbilities( {
        avatar = {
            id = 107574,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            spend = -20,
            spendType = "rage",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 613534,

            talent = "avatar",

            handler = function ()
                applyBuff( "avatar" )
            end,
        },


        battle_shout = {
            id = 6673,
            cast = 0,
            cooldown = 15,
            gcd = "spell",

            startsCombat = false,
            texture = 132333,

            nobuff = "battle_shout",
            essential = true,

            handler = function ()
                applyBuff( "battle_shout" )
            end,
        },


        berserker_rage = {
            id = 18499,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 136009,

            handler = function ()
                applyBuff( "berserker_rage" )
                if level < 116 and equipped.ceannar_charger then gain( 8, "rage" ) end
            end,
        },


        bladestorm = {
            id = 227847,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.85 or 1 ) * 90 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 236303,

            notalent = "ravager",

            handler = function ()
                applyBuff( "bladestorm" )
                setCooldown( "global_cooldown", 4 * haste )
                if level < 116 and equipped.the_great_storms_eye then addStack( "tornados_eye", 6, 1 ) end

                if azerite.gathering_storm.enabled then
                    applyBuff( "gathering_storm", 6 + ( 4 * haste ), 4 )
                end
            end,
        },


        charge = {
            id = 100,
            cast = 0,
            charges = function () return talent.double_time.enabled and 2 or nil end,
            cooldown = function () return talent.double_time.enabled and 17 or 20 end,
            recharge = function () return talent.double_time.enabled and 17 or 20 end,
            gcd = "spell",

            startsCombat = true,
            texture = 132337,

            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd.execute ) end,
            handler = function ()
                setDistance( 5 )
            end,
        },


        cleave = {
            id = 845,
            cast = 0,
            cooldown = 9,
            gcd = "spell",

            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 20
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 132338,

            talent = "cleave",

            handler = function ()
                if active_enemies >= 3 then applyDebuff( "target", "deep_wounds" ) end
                if talent.collateral_damage.enabled then gain( 4, "rage" ) end
            end,
        },


        colossus_smash = {
            id = 167105,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = true,
            texture = 464973,

            notalent = "warbreaker",

            handler = function ()
                applyDebuff( "target", "colossus_smash" )

                if level < 116 then
                    if set_bonus.tier21_2pc == 1 then applyBuff( "war_veteran" ) end
                    if set_bonus.tier20_2pc == 1 then
                        if talent.ravager.enabled then setCooldown( "ravager", max( 0, cooldown.ravager.remains - 2 ) )
                        else setCooldown( "bladestorm", max( 0, cooldown.bladestorm.remains - 3 ) ) end
                    end
                end

                if talent.in_for_the_kill.enabled then
                    applyBuff( "in_for_the_kill" )
                    stat.haste = state.haste + ( target.health.pct < 20 and 0.2 or 0.1 )
                end
            end,
        },


        deadly_calm = {
            id = 262228,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 298660,

            handler = function ()
                applyBuff( "deadly_calm" )
            end,
        },


        defensive_stance = {
            id = 212520,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = false,
            texture = 132349,

            talent = "defensive_stance",
            toggle = "defensives",

            handler = function ()
                if buff.defensive_stance.up then removeBuff( "defensive_stance" )
                else applyBuff( "defensive_stance" ) end
            end,
        },


        die_by_the_sword = {
            id = 118038,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            startsCombat = false,
            texture = 132336,

            toggle = "defensives",

            handler = function ()
                applyBuff( "die_by_the_sword" )
            end,
        },


        execute = {
            id = function () return talent.massacre.enabled and 281001 or 163201 end,
            known = 163201,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.sudden_death.up then return 0 end
                if buff.stone_heart.up then return 0 end
                if buff.deadly_calm.up then return 0 end
                return 20
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 135358,

            recheck = function () return rage.time_to_40 end,
            usable = function () return buff.sudden_death.up or buff.stone_heart.up or target.health.pct < ( talent.massacre.enabled and 35 or 20 ) end,
            handler = function ()
                if not buff.sudden_death.up and not buff.stone_heart.up then
                    local overflow = min( rage.current, 20 )
                    spend( overflow, "rage" )
                    gain( 0.2 * ( 20 + overflow ), "rage" )
                end
                if buff.stone_heart.up then removeBuff( "stone_heart" )
                else removeBuff( "sudden_death" ) end

                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 4, "rage" ) end
            end,

            copy = { 163201, 281001, 281000 }
        },


        hamstring = {
            id = 1715,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 10
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 132316,

            handler = function ()
                applyDebuff( "target", "hamstring" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 2, "rage" ) end
            end,
        },


        heroic_leap = {
            id = 6544,
            cast = 0,
            charges = function () return ( level < 116 and equipped.timeless_strategem ) and 3 or nil end,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            recharge = function () return talent.bounding_stride.enabled and 30 or 45 end,
            gcd = "spell",

            startsCombat = false,
            texture = 236171,

            usable = function () return ( equipped.weight_of_the_earth or target.distance > 10 ) and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd.execute * 2 ) end,
            handler = function ()
                setDistance( 5 )
                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
                if level < 116 and equipped.weight_of_the_earth then
                    applyDebuff( "target", "colossus_smash" )
                    active_dot.colossus_smash = max( 1, active_enemies )
                end
            end,
        },


        heroic_throw = {
            id = 57755,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            startsCombat = true,
            texture = 132453,

            usable = function () return target.distance > 10 end,
            handler = function ()
            end,
        },


        impending_victory = {
            id = 202168,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 10
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 589768,

            talent = "impending_victory",

            handler = function ()
                removeBuff( "victorious" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 2, "rage" ) end
            end,
        },


        intimidating_shout = {
            id = 5246,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            startsCombat = true,
            texture = 132154,

            handler = function ()
                applyBuff( "intimidating_shout" )
                if azerite.intimidating_presence.enabled then applyDebuff( "target", "intimidating_presence" ) end
            end,
        },


        mortal_strike = {
            id = 12294,
            cast = 0,
            cooldown = 6,
            gcd = "spell",

            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 30 - ( ( level < 116 and equipped.archavons_heavy_hand ) and 8 or 0 )
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 132355,

            handler = function ()
                applyDebuff( "target", "mortal_wounds" )
                applyDebuff( "target", "deep_wounds" )
                removeBuff( "overpower" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 6, "rage" ) end
                if level < 116 and set_bonus.tier21_4pc == 1 then addStack( "weighted_blade", 12, 1 ) end
            end,
        },


        overpower = {
            id = 7384,
            cast = 0,
            charges = function () return talent.dreadnaught.enabled and 2 or nil end,
            cooldown = 12,
            recharge = 12,
            gcd = "spell",

            startsCombat = true,
            texture = 132223,

            handler = function ()
                if talent.dreadnaught.enabled then
                    addStack( "overpower", 15, 1 )
                else
                    applyBuff( "overpower" )
                end

                if buff.striking_the_anvil.up then
                    removeBuff( "striking_the_anvil" )
                    gainChargeTime( "mortal_strike", 1.5 )
                end
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

            startsCombat = false,
            texture = 132351,

            toggle = "defensives",

            handler = function ()
                applyBuff( "rallying_cry" )
            end,
        },


        ravager = {
            id = 152277,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 60 end,
            gcd = "spell",

            spend = -7,
            spendType = "rage",

            startsCombat = true,
            texture = 970854,

            talents = "ravager",
            toggle = "cooldowns",

            handler = function ()
                if ( level < 116 and equipped.the_great_storms_eye ) then addStack( "tornados_eye", 6, 1 ) end
                -- need to plan out rage gen.
            end,
        },


        rend = {
            id = 772,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 30
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 132155,

            talent = "rend",

            handler = function ()
                applyDebuff( "target", "rend" )
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 6, "rage" ) end
            end,
        },


        skullsplitter = {
            id = 260643,
            cast = 0,
            cooldown = 21,
            hasteCD = true,
            gcd = "spell",

            spend = -20,
            spendType = "rage",

            startsCombat = true,
            texture = 2065621,

            talent = "skullsplitter",

            handler = function ()
            end,
        },


        slam = {
            id = 1464,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.deadly_calm.up then return 0 end
                if buff.crushing_assault.up then return 0 end
                return 20
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 132340,

            recheck = function () return rage.time_to_30, rage.time_to_40 end,
            handler = function ()
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 4, "rage" ) end
                removeBuff( "crushing_assault" )
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


        sweeping_strikes = {
            id = 260708,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            startsCombat = true,
            texture = 132306,

            handler = function ()
                applyBuff( "sweeping_strikes" )
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


        victory_rush = {
            id = 34428,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 132342,

            notalent = "impending_victory",

            buff = "victorious",

            handler = function ()
                removeBuff( "victorious" )
            end,
        },


        warbreaker = {
            id = 262161,
            cast = 0,
            cooldown = 45,
            velocity = 25,
            gcd = "spell",

            startsCombat = true,
            texture = 2065633,

            talent = "warbreaker",

            handler = function ()                
                if talent.in_for_the_kill.enabled then
                    if buff.in_for_the_kill.down then
                        stat.haste = stat.haste + ( target.health.pct < 0.2 and 0.2 or 0.1 )
                    end
                    applyBuff( "in_for_the_kill" )
                end

                if level < 116 then
                    if set_bonus.tier21_2pc == 1 then applyBuff( "war_veteran" ) end
                    if set_bonus.tier20_2pc == 1 then
                        if talent.ravager.enabled then setCooldown( "ravager", max( 0, cooldown.ravager.remains - 2 ) )
                        else setCooldown( "bladestorm", max( 0, cooldown.bladestorm.remains - 3 ) ) end
                    end
                end

                applyDebuff( "target", "colossus_smash" )
            end,
        },


        whirlwind = {
            id = 1680,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.deadly_calm.up then return 0 end
                return 30
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 132369,

            recheck = function () return rage.time_to_50 end,
            handler = function ()
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 6, "rage" ) end
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageDots = false,
        damageExpiration = 8,

        potion = "potion_of_unbridled_fury",

        package = "Arms",
    } )


    spec:RegisterPack( "Arms", 20190729, [[dyKlnbqisfpcfQ2Kq1NKkGmkukNcLQvjvq8ksHzrQQBPQq2fQ(LQsdti6yKQSmHWZuvKPrkkxJuK2gPi(MQcACKIQZPQaRtQGAEsfDpsP9Hc5GQkuleL0dLkaUOubQtIcfTsHYmLkaTtuIHIcfwQubspvvMkk4QsfqTvPcsFvQaXEH8xQAWcomLfdvpMktMWLr2SeFgknAvvNwLvJcLEnPsZMKBlLDd63knCPQLd8Cftx01L02fsFhkgVuHoVuP1RQOMpkA)enspedONWscXserQ3he5hgXhWJms90C90d9YU9e61BoDnSe6bTgHEFmOnOxV1vTMaXa6nBf4i07pZ(Pd)9l2l)R4C32(oxRQS8wOdyL87Cn3x0dVEQKXeIWrpHLeILiIuVpiYpmIpGhzK6P5rQh6z18FbO37AvLL3c7aaSsIE)Nqqqeo6jOXHEmUm8XG2idDqma4wGmgJld)z2pD4VFXE5FfN72235AvLL3cDaRKFNR5(kJX4YqSQQRmeXhOVmerK69bYWhjdrgzhwpnvgtgJXLHoa)gelnDyzmgxg(iz4Jfcsidmg1wJuCzmgxg(iz4JfcsidDONlxqxzOdAD()Yy26jO4GyLHo0ZLlOlxgJXLHpsg(yHGeYaRwMksgE)BnLHCLHEa52gULYWhZy0bKlJX4YWhjdDWDKC18wib6anYaJbGC3ClugUrgeKIssWLXyCz4JKHpwiiHm0bEizGXmP2Wrp1n5Gya9MdIvr(0ayPeXaIf9qmGEe0WvKaXk65axsGZqpa1SdoYqNALbrfy5TqzOdrgIK)jziUmii8APWDRANPo(PzZpxSyGON5YBHOhGGcuIyjcedOhbnCfjqSIEoWLe4m0dyyjzOtzqtIugIld41sHlitO66DMQXflgOmexgWRLcVrTf01VfVQ6oHxaiRnCXIbIEMlVfIEJUvLA6vxMeaLiw(eIb0JGgUIeiwrph4scCg6PJmGxlfUGmHQR3zQgV2ldXLb2Kb3UkXIbYDRANPo(PzZphqn7GJm0PmeHmWKPmWMmKMIGjhJbWbKPlb4e0WvKqgIldUDvIfdKJXa4aY0LaCa1SdoYqNYqeYa7Ya7ON5YBHOhWIAyjakrSOzigqpcA4ksGyf9CGljWzONoYandbDeVrTf01VfVQ6oHxaiRn8MXyxGmWKPmWMmGxlfEJAlORFlEv1DcVaqwB41EzGjtzWTRsSyG8g1wqx)w8QQ7eEbGS2WbuZo4idmsg0lszGD0ZC5Tq0ZTQDM64NMn)OeXIMIya9iOHRibIv0ZbUKaNHE6id0me0r8g1wqx)w8QQ7eEbGS2WBgJDbYatMYaBYaETu4nQTGU(T4vv3j8cazTHx7LbMmLb3UkXIbYBuBbD9BXRQUt4faYAdhqn7GJmWizqViLb2rpZL3crpmgahqMUeaLiw0eedON5YBHONGmHQR3zQg6rqdxrceROeXYhIya9iOHRibIv0ZbUKaNHE41sHpvHGGEbz5phqMlrpZL3crpQJKRMekrSO5igqpcA4ksGyf9CGljWzONBxLyXa5TfKMYpj40L4aQzhCKH4YaBYGoYqAkcMCbzcvxVZunobnCfjKbMmLb8APWfKjuD9ot14IfdugyxgIldSjdSjdccVwkC3Q2zQJFA28ZR9YqCzqhzW(mbUK4jnPFl(2H9p5e0WvKqgyxgyYugWRLcpPj9BX3oS)jV2ldSldXLb8APWBuBbD9BXRQUt4faYAdxSyGON5YBHOhUYe0KlOHselFaIb0JGgUIeiwrph4scCg6n9Ks5tdGLYHJ5)akmhuidmsgIa9mxEle9CkYIsOeXIErIya9iOHRibIv0ZbUKaNHEadljdDkdFksziUmGxlfEJAlORFlEv1DcVaqwB41EziUmii8APWDRANPo(PzZpV2JEMlVfIEBuc0VyiakrSONEigqpZL3crV2cst5NeC6sOhbnCfjqSIsel6fbIb0JGgUIeiwrph4scCg6LMIGjVqGOlWVfpULPI4e0WvKqgIldSjd41sH3O2c663IxvDNWlaK1gETxgyYugWRLcxqMq117mvJx7Lb2rpZL3crpm)hqH5GcuIyrVpHya9mxEle92OeOFXqa0JGgUIeiwrjIf90medOhbnCfjqSIEoWLe4m0lnfbtEHarxGFlECltfXjOHRib6zU8wi6H5)akmhuGsel6PPigqpcA4ksGyf9CGljWzONoYqAkcM8cbIUa)w84wMkItqdxrc0ZC5Tq0BuwdLiw0ttqmGEMlVfIErpxUGUEqD(rpcA4ksGyfLiw07drmGEMlVfIExRNGIdI1h9C5c6IEe0WvKaXkkrj6jOIvvjIbel6Hya9mxEle9C)galHEe0WvKaXkkrSebIb0ZC5Tq0RV2AKc9iOHRibIvuIy5tigqpZL3crV(nVfIEe0WvKaXkkrSOzigqpcA4ksGyf9CGljWzONGWRLc3TQDM64NMn)8Ap6zU8wi6HR2v4lvqxuIyrtrmGEe0WvKaXk65axsGZqpbHxlfUBv7m1XpnB(51E0ZC5Tq0dNadb09GyrjIfnbXa6rqdxrceRONdCjbod9eeETu4UvTZuh)0S5NlwmqziUm42vjwmqEBbPP8tcoDjoGA2bhzGrYGECnvgIldadljdDkdAAKON5YBHONbCgK85caemrjILpeXa6rqdxrceRONdCjbod9eeETu4UvTZuh)0S5Nlwmq0ZC5Tq0tDy)ZXZyRcSncMOeXIMJya9iOHRibIv0ZbUKaNHEccVwkC3Q2zQJFA28ZR9ON5YBHOx5aeUAxbkrS8bigqpcA4ksGyf9CGljWzONGWRLc3TQDM64NMn)8Ap6zU8wi6zqhnjWuENPuOeXIErIya9iOHRibIv0dAnc9awR)Gy9wRxDzvqEShwl6QspbXEqc9mxEle9awR)Gy9wRxDzvqEShwl6QspbXEqcLiw0tpedOhbnCfjqSIEMlVfIE28h1G04b2NxG3TatHEoWLe4m0thzqq41sHdSpVaVBbMYli8APWR9YatMYaBYqAaSuY)jtL)8ExkdDkdFksUEYqCzqq41sH7wOO6Ylk5pOUEbHxlfETxgyxgyYugytg0rgeeETu4UfkQU8Is(dQRxq41sHx7LH4YaETu4nQTGU(T4vv3j8cazTHx7LbMmLb2KHEaf1J1j46XDRANPo(PzZVmexg0rgOziOJ4nQTGU(T4vv3j8cazTH3mg7cKb2Lb2rpO1i0ZM)OgKgpW(8c8UfykuIyrViqmGEe0WvKaXk65axsGZqp3UkXIbYDRANPo(PzZphqn7GJm0PmO5YatMYaBYqAkcMCmgahqMUeGtqdxrcziUm42vjwmqogdGditxcWbuZo4idDkdAUmWo6zU8wi6zrT0aOeXIEFcXa6rqdxrceRONdCjbod9C7Qelgi3TQDM64NMn)Ca1SdoYqNYGMldmzkdSjdPPiyYXyaCaz6saobnCfjKH4YGBxLyXa5ymaoGmDjahqn7GJm0PmO5Ya7ON5YBHOxDi)LuBqjIf90medOhbnCfjqSIEoWLe4m0B6jLYNgalLdhZ)buyoOqgyKmONmexgytgC7QelgihxzcAYf04aQzhCKbgjd6fPmWKPm42vjwmqUBv7m1XpnB(5aQzhCKbgjdAUmWKPmyFMaxs8KM0VfF7W(NCcA4ksidSJEMlVfIEdgI6piw)KGtxAqjIf90uedOhbnCfjqSIEoWLe4m0dVwk8KM0VfF7W(N8AVmWKPmWMmii8APWDRANPo(PzZpV2ldXLbDKb7Ze4sIN0K(T4Bh2)KtqdxrczGD0ZC5Tq0dxTRWVfF(tEcsTUOeXIEAcIb0JGgUIeiwrph4scCg6PJmii8APWDRANPo(PzZpV2ldXLbDKb8APWtAs)w8Td7FYR9ON5YBHOxFfCLUheRhxztIsel69HigqpcA4ksGyf9CGljWzONoYGGWRLc3TQDM64NMn)8AVmexg0rgWRLcpPj9BX3oS)jV2JEMlVfIEGRVxr(d6NEZrOeXIEAoIb0JGgUIeiwrph4scCg6PJmii8APWDRANPo(PzZpV2ldXLbDKb8APWtAs)w8Td7FYR9ON5YBHOhMfOerPd6b0Sqd6iuIyrVpaXa6rqdxrceRONdCjbod90rgeeETu4UvTZuh)0S5Nx7LH4YGoYaETu4jnPFl(2H9p51E0ZC5Tq0RSU6qcV9zcCj5XjRHselrejIb0JGgUIeiwrph4scCg6PJmii8APWDRANPo(PzZpV2ldXLbDKb8APWtAs)w8Td7FYR9YqCzqSj3TqhbtGLKWxuwJ84vaKdOMDWrg0kdrIEMlVfIEUf6iycSKe(IYAekrSeHEigqpcA4ksGyf9CGljWzOhETu4aYPRIMXxwGJ41E0ZC5Tq0l)jFfIVvOWxwGJqjILiIaXa6rqdxrceRONdCjbod9C7Qelgi3TQDM64NMn)Ca1SdoYqNYGErIEMlVfIEyRgqCg0VfV9zcS5pkrSeXNqmGEe0WvKaXk65axsGZqp3UkXIbYDRANPo(PzZphqn7GJm0Pm8j0ZC5Tq0RrTf01VfVQ6oHxaiRnOeXseAgIb0JGgUIeiwrph4scCg6bSt4POem5MqmCQJ3Kd6zU8wi6bQqV5YBHE1nj6PUj9qRrO3V5qjILi0uedOhbnCfjqSIEoWLe4m0B6jLYNgalLdhZ)buyoOqgyKmOzON5YBHOhOc9MlVf6v3KON6M0dTgHELlk5tdGLsuIyjcnbXa6rqdxrceRONdCjbod9ytgstrWK3SzmhG4e0WvKqgIldPbWsj)Nmv(Z7DPm0Pm8jnvgyxgyYugsdGLs(pzQ8N37szOtziIirpZL3crpqf6nxEl0RUjrp1nPhAnc9OosUAsOeXseFiIb0JGgUIeiwrpZL3crpqf6nxEl0RUjrp1nPhAnc9MdIvr(0ayPeLOe96bKBB4wIyaXIEigqpZL3crpCltf5N)TMOhbnCfjqSIselrGya9iOHRibIv0dAnc9Spp)gWgFzHPFl((fdbqpZL3crp7ZZVbSXxwy63IVFXqauIy5tigqpZL3crVg1wqx)w8QQ7eEbGS2GEe0WvKaXkkrSOzigqpZL3crpSvdiod63I3(mb28h9iOHRibIvuIyrtrmGEMlVfIE9BEle9iOHRibIvuIs0J6i5QjHyaXIEigqpcA4ksGyf9CGljWzOhWWsYqNYGMePmexgWRLcxqMq117mvJlwmqziUmGxlfEJAlORFlEv1DcVaqwB4Ifde9mxEle9gDRk10RUmjakrSebIb0JGgUIeiwrph4scCg6PJmGxlfUGmHQR3zQgV2ldXLb2Kb3UkXIbYDRANPo(PzZphqn7GJm0PmeHmWKPmWMmKMIGjhJbWbKPlb4e0WvKqgIldUDvIfdKJXa4aY0LaCa1SdoYqNYqeYa7Ya7ON5YBHOhWIAyjakrS8jedOhbnCfjqSIEoWLe4m0thzGMHGoI3O2c663IxvDNWlaK1gEZySlqgyYugytgWRLcVrTf01VfVQ6oHxaiRn8AVmWKPm42vjwmqEJAlORFlEv1DcVaqwB4aQzhCKbgjd6fPmWo6zU8wi65w1otD8tZMFuIyrZqmGEe0WvKaXk65axsGZqpDKbAgc6iEJAlORFlEv1DcVaqwB4nJXUazGjtzGnzaVwk8g1wqx)w8QQ7eEbGS2WR9YatMYGBxLyXa5nQTGU(T4vv3j8cazTHdOMDWrgyKmOxKYa7ON5YBHOhgdGditxcGselAkIb0ZC5Tq0tqMq117mvd9iOHRibIvuIyrtqmGEe0WvKaXk65axsGZqpDKb8APWBuBbD9BXRQUt4faYAdV2ldXLb8APWtAs)w8Td7FYR9YqCzayyjzOtz4trkdXLbDKb8APWfKjuD9ot141E0ZC5Tq0dxzcAYf0qjILpeXa6rqdxrceRONdCjbod9MEsP8PbWs5WX8FafMdkKbgjdrGEMlVfIEofzrjuIyrZrmGEe0WvKaXk65axsGZqp8APWDG68FqSEBgRQsETxgIld41sH3O2c663IxvDNWlaK1gUyXarpZL3crVrznuIy5dqmGEe0WvKaXk65axsGZqp8APW3OeOFXqa(KMtxzqRmeHmexgstrWKlaKjGwf7FYjOHRib6zU8wi61wqAk)KGtxcLiw0lsedOhbnCfjqSIEoWLe4m0dVwk8g1wqx)w8QQ7eEbGS2WR9YatMYaETu4cYeQUENPA8Ap6zU8wi6rDKC1KqjIf90dXa6zU8wi6Trjq)IHaOhbnCfjqSIsel6fbIb0ZC5Tq0J6i5QjHEe0WvKaXkkrj69Boediw0dXa6rqdxrceRONdCjbod9auZo4idDQvgevGL3cLHoezis(NKH4YaBYGoYaWoHNIsWKBcXWR9YatMYaETu4dgI6piw)KGtxA41EzGD0ZC5Tq0dqqbkrSebIb0JGgUIeiwrph4scCg6bmSKm0PmOjrkdXLb2Kb3UkXIbYfKjuD9ot14aQzhCKbgjdFsgyYug0rgstrWKlitO66DMQXjOHRiHmWo6zU8wi6n6wvQPxDzsauIy5tigqpcA4ksGyf9CGljWzOhBYGBxLyXa54ktqtUGghqn7GJmWizqtKbMmLH0uem5alQHLaCcA4ksidXLb3UkXIbYbwudlb4aQzhCKbgjdAImWUmexgytgC7Qelgi3TQDM64NMn)Ca1SdoYqNYqeYatMYaBYqAkcMCmgahqMUeGtqdxrcziUm42vjwmqogdGditxcWbuZo4idDkdridSldSJEMlVfIEcYeQUENPAOeXIMHya9iOHRibIv0ZbUKaNHESjda7eEkkbtUjedV2ldmzkda7eEkkbtUjed)GYaJKH0ayPKNxJ856fhjdSldXLb2Kb3UkXIbYDRANPo(PzZphqn7GJm0PmeHmWKPmWMmKMIGjhJbWbKPlb4e0WvKqgIldUDvIfdKJXa4aY0LaCa1SdoYqNYqeYa7Ya7ON5YBHOhWIAyjakrSOPigqpcA4ksGyf9CGljWzOhWoHNIsWKBcXWR9YatMYaWoHNIsWKBcXWpOmWizqZIugyYugytga2j8uucMCtig(bLbgjdrePmexgstrWKBqSeW3mOHLAem5e0WvKqgyh9mxEle9CRANPo(PzZpkrSOjigqpcA4ksGyf9CGljWzOhWoHNIsWKBcXWR9YatMYaWoHNIsWKBcXWpOmWizqZIugyYugytga2j8uucMCtig(bLbgjdrePmexgstrWKBqSeW3mOHLAem5e0WvKqgyh9mxEle9WyaCaz6sauIy5drmGEe0WvKaXk65axsGZqp2KbbHxlfUBv7m1XpnB(51EziUmaSt4POem5Mqm8dkdmsgsdGLsEEnYNRxCKmWUmWKPmaSt4POem5Mqm8AVmexgytgytgeeETu4UvTZuh)0S5NdOMDWrgyKmOzCnvgIld6id2NjWLepPj9BX3oS)jNGgUIeYa7YatMYaETu4jnPFl(2H9p51EzGD0ZC5Tq0dxzcAYf0qjIfnhXa6rqdxrceRONdCjbod90rga2j8uucMCtigETxgyYugytga2j8uucMCtigETxgIld2NjWLeFOBANZJXIsCcA4ksidSJEMlVfIEBuc0VyiakrS8bigqpcA4ksGyf9CGljWzO30tkLpnawkhoM)dOWCqHmWizic0ZC5Tq0ZPilkHsel6fjIb0JGgUIeiwrph4scCg6PJmaSt4POem5Mqm8AVmWKPmWMmOJmKMIGj3PilkXjOHRiHmexgeBYfe17XSvOy4aQzhCKHoLHiKb2LbMmLb8APWNQqqqVGS8NdiZLON5YBHOh1rYvtcLiw0tpedOhbnCfjqSIEoWLe4m0thzayNWtrjyYnHy41EzGjtzGnzqhzinfbtUtrwuItqdxrcziUmi2KliQ3JzRqXWbuZo4idDkdridSJEMlVfIETfKMYpj40LqjIf9IaXa6rqdxrceRONdCjbod9a2j8uucMCtigETh9mxEle9W8FafMdkqjIf9(eIb0ZC5Tq0BJsG(fdbqpcA4ksGyfLiw0tZqmGEe0WvKaXk65axsGZqV0uem5fceDb(T4XTmveNGgUIeON5YBHOhM)dOWCqbkrSONMIya9iOHRibIv0ZbUKaNHE6idPPiyYlei6c8BXJBzQiobnCfjKH4YGoYaWoHNIsWKBcXWR9ON5YBHO3OSgkrSONMGya9mxEle9IEUCbD9G68JEe0WvKaXkkrSO3hIya9mxEle9UwpbfheRp65Yf0f9iOHRibIvuIs0RCrjFAaSuIyaXIEigqpcA4ksGyf9CGljWzOhWWsYqNYGMePmexgytg0rgstrWKlitO66DMQXjOHRiHmWKPmGxlfUGmHQR3zQgxSyGYa7ON5YBHO3OBvPME1LjbqjILiqmGEe0WvKaXk65axsGZqp2KbDKH0uem5ymaoGmDjaNGgUIeYatMYGBxLyXa5ymaoGmDjahqn7GJm0PmeHmWo6zU8wi6bSOgwcGselFcXa6rqdxrceRONdCjbod9eeETu4UvTZuh)0S5Nlwmq0ZC5Tq0ZTQDM64NMn)OeXIMHya9iOHRibIv0ZbUKaNHEccVwkC3Q2zQJFA28Zflgi6zU8wi6HXa4aY0LaOeXIMIya9iOHRibIv0ZbUKaNHE41sHpyiQ)Gy9tcoDPHlwmqziUmWMmOJmKMIGjxqMq117mvJtqdxrczGjtzaVwkCbzcvxVZunUyXaLb2LH4YaBYaBYGGWRLc3TQDM64NMn)Ca1SdoYaJKbnJRPYqCzqhzW(mbUK4jnPFl(2H9p5e0WvKqgyxgyYugWRLcpPj9BX3oS)jV2ldSJEMlVfIE4ktqtUGgkrSOjigqpZL3crpbzcvxVZun0JGgUIeiwrjILpeXa6zU8wi65uKfLqpcA4ksGyfLiw0CedOhbnCfjqSIEoWLe4m0JnzqhzinfbtUtrwuItqdxrcziUmi2KliQ3JzRqXWbuZo4idDkdridSldmzkdSjd41sHpvHGGEbz5phqMlLbMmLb8APWNCHK)NmqYbK5szGDziUmWMmGxlf(GHO(dI1pj40LgETxgyYugC7QelgiFWqu)bX6NeC6sdhqn7GJmWizqZLb2rpZL3crpQJKRMekrS8bigqpcA4ksGyf9CGljWzOhBYGoYqAkcMCNISOeNGgUIeYqCzqSjxquVhZwHIHdOMDWrg6ugIqgyxgyYugWRLcFWqu)bX6NeC6sdV2ldXLb8APW3OeOFXqa(KMtxzqRmeHmexgstrWKlaKjGwf7FYjOHRib6zU8wi61wqAk)KGtxcLiw0lsedOhbnCfjqSIEoWLe4m0tq41sH7w1otD8tZMFETxgyYugytgWRLc3bQZ)bX6TzSQk51EziUmKMIGjVqGOlWVfpULPI4e0WvKqgyh9mxEle9W8FafMdkqjIf90dXa6rqdxrceRONdCjbod9WRLcxqMq117mvJx7LbMmLbGHLKbgjdAsKON5YBHOhM)dOWCqbkrSOxeigqpZL3crVnkb6xmea9iOHRibIvuIyrVpHya9mxEle9W8FafMdkqpcA4ksGyfLiw0tZqmGEMlVfIErpxUGUEqD(rpcA4ksGyfLiw0ttrmGEMlVfIExRNGIdI1h9C5c6IEe0WvKaXkkrjkrVOeyUfIyjIi17dI8dJ8d5rereAk6HXaWdIDqpgZw)cssidAImyU8wOmOUjhUmg6n9KdXYhQh61d2YPi0JXLHpg0gzOdIba3cKXyCz4pZ(Pd)9l2l)R4C32(oxRQS8wOdyL87Cn3xzmgxgIvvDLHi(a9LHiIuVpqg(iziYi7W6PPYyYymUm0b43GyPPdlJX4YWhjdFSqqczGXO2AKIlJX4YWhjdFSqqczOd9C5c6kdDqRZ)xgZwpbfheRm0HEUCbD5YymUm8rYWhleKqgy1YurYW7FRPmKRm0di32WTug(ygJoGCzmgxg(izOdUJKRM3cjqhOrgymaK7MBHYWnYGGuuscUmgJldFKm8XcbjKHoWdjdmMj1gUmMmgJldDWDKC1KeYaovwajdUTHBPmGtyp4WLHp25O(CKb4c)OFd0kvLmyU8w4idlu1LlJX4YG5YBHdVhqUTHBP2IYgDLXyCzWC5TWH3di32WTudTFl7kKXyCzWC5TWH3di32WTudTFTk2gbtlVfkJX4YWdA9Z)MYaWoHmGxlfsidtA5id4uzbKm42gULYaoH9GJmyqHm0dOpQFZ8GyLHBKbXcjUmM5YBHdVhqUTHBPgA)IBzQi)8V1ugZC5TWH3di32WTudTFRd5VKA6dTgP1(88BaB8LfM(T47xmeqgZC5TWH3di32WTudTFBuBbD9BXRQUt4faYAJmM5YBHdVhqUTHBPgA)ITAaXzq)w82NjWM)YyMlVfo8Ea52gULAO9B)M3cLXKXyCzOdUJKRMKqgOOeORmKxJKH8NKbZLlqgUrgSO2PmCfXLXmxElC06(nawsgZC5TWrdTF7RTgPKXmxElC0q73(nVfkJzU8w4OH2V4QDf(sf0v)ROvq41sH7w1otD8tZMFETxgZC5TWrdTFXjWqaDpiw9VIwbHxlfUBv7m1XpnB(51EzmZL3chn0(1aods(CbacM6FfTccVwkC3Q2zQJFA28ZflgyC3UkXIbYBlinLFsWPlXbuZo4Wi94AACGHL6utJugZC5TWrdTFvh2)C8m2QaBJGP(xrRGWRLc3TQDM64NMn)CXIbkJzU8w4OH2VLdq4QDf6FfTccVwkC3Q2zQJFA28ZR9YyMlVfoAO9RbD0Kat5DMsP)v0ki8APWDRANPo(PzZpV2lJzU8w4OH2V1H8xsn9HwJ0cSw)bX6TwV6YQG8ypSw0vLEcI9GKmM5YBHJgA)whYFj10hAnsRn)rninEG95f4DlWu6FfT6ii8APWb2NxG3Tat5feETu41EMmzlnawk5)KPYFEVl78trY1lUGWRLc3Tqr1LxuYFqD9ccVwk8Ap7mzYMoccVwkC3cfvxErj)b11li8APWR9XXRLcVrTf01VfVQ6oHxaiRn8AptMS1dOOESobxpUBv7m1XpnB(JRdndbDeVrTf01VfVQ6oHxaiRn8MXyxa7SlJzU8w4OH2VwulnG(xrRBxLyXa5UvTZuh)0S5NdOMDWPtnNjt2strWKJXa4aY0LaCcA4kse3TRsSyGCmgahqMUeGdOMDWPtnNDzmZL3chn0(ToK)sQn6FfTUDvIfdK7w1otD8tZMFoGA2bNo1CMmzlnfbtogdGditxcWjOHRirC3UkXIbYXyaCaz6saoGA2bNo1C2LXmxElC0q73bdr9heRFsWPln6FfTtpPu(0ayPC4y(pGcZbfmsV4S52vjwmqoUYe0KlOXbuZo4Wi9IKjt3UkXIbYDRANPo(PzZphqn7GdJ0CMmTptGljEst63IVDy)tobnCfjyxgZC5TWrdTFXv7k8BXN)KNGuRR(xrlETu4jnPFl(2H9p51EMmztq41sH7w1otD8tZMFETpUo2NjWLepPj9BX3oS)jNGgUIeSlJzU8w4OH2V9vWv6EqSECLnP(xrRoccVwkC3Q2zQJFA28ZR9X1bVwk8KM0VfF7W(N8AVmM5YBHJgA)cU(Ef5pOF6nhP)v0QJGWRLc3TQDM64NMn)8AFCDWRLcpPj9BX3oS)jV2lJzU8w4OH2VywGseLoOhqZcnOJ0)kA1rq41sH7w1otD8tZMFETpUo41sHN0K(T4Bh2)Kx7LXmxElC0q73Y6Qdj82NjWLKhNSM(xrRoccVwkC3Q2zQJFA28ZR9X1bVwk8KM0VfF7W(N8AVmM5YBHJgA)6wOJGjWss4lkRr6FfT6ii8APWDRANPo(PzZpV2hxh8APWtAs)w8Td7FYR9XfBYDl0rWeyjj8fL1ipEfa5aQzhC0gPmM5YBHJgA)M)KVcX3ku4llWr6FfT41sHdiNUkAgFzboIx7LXmxElC0q7xSvdiod63I3(mb28x)RO1TRsSyGC3Q2zQJFA28ZbuZo40PErkJzU8w4OH2VnQTGU(T4vv3j8cazTr)RO1TRsSyGC3Q2zQJFA28ZbuZo405NKXmxElC0q7xqf6nxEl0RUj1hAns7V50)kAb2j8uucMCtigo1XBYrgZC5TWrdTFbvO3C5TqV6MuFO1iTLlk5tdGLs9VI2PNukFAaSuoCm)hqH5GcgPzYyMlVfoAO9lOc9MlVf6v3K6dTgPL6i5QjP)v0YwAkcM8MnJ5aeNGgUIeXtdGLs(pzQ8N37Yo)KMYotMPbWsj)Nmv(Z7DzNrePmM5YBHJgA)cQqV5YBHE1nP(qRrANdIvr(0ayPugtgZC5TWHtDKC1K0o6wvQPxDzsa9VIwGHL6utImoETu4cYeQUENPACXIbghVwk8g1wqx)w8QQ7eEbGS2WflgOmM5YBHdN6i5QjPH2ValQHLa6FfT6GxlfUGmHQR3zQgV2hNn3UkXIbYDRANPo(PzZphqn7GtNrWKjBPPiyYXyaCaz6saobnCfjI72vjwmqogdGditxcWbuZo40zeSZUmM5YBHdN6i5QjPH2VUvTZuh)0S5x)ROvhAgc6iEJAlORFlEv1DcVaqwB4nJXUaMmzdVwk8g1wqx)w8QQ7eEbGS2WR9mz62vjwmqEJAlORFlEv1DcVaqwB4aQzhCyKErYUmM5YBHdN6i5QjPH2VymaoGmDjG(xrRo0me0r8g1wqx)w8QQ7eEbGS2WBgJDbmzYgETu4nQTGU(T4vv3j8cazTHx7zY0TRsSyG8g1wqx)w8QQ7eEbGS2WbuZo4Wi9IKDzmZL3cho1rYvtsdTFfKjuD9ot1KXmxElC4uhjxnjn0(fxzcAYf00)kA1bVwk8g1wqx)w8QQ7eEbGS2WR9XXRLcpPj9BX3oS)jV2hhyyPo)uKX1bVwkCbzcvxVZunETxgZC5TWHtDKC1K0q7xNISOK(xr70tkLpnawkhoM)dOWCqbJIqgZC5TWHtDKC1K0q73rzn9VIw8APWDG68FqSEBgRQsETpoETu4nQTGU(T4vv3j8cazTHlwmqzmZL3cho1rYvtsdTFBlinLFsWPlP)v0Ixlf(gLa9lgcWN0C6QnI4PPiyYfaYeqRI9p5e0WvKqgZC5TWHtDKC1K0q7xQJKRMK(xrlETu4nQTGU(T4vv3j8cazTHx7zYeVwkCbzcvxVZunETxgZC5TWHtDKC1K0q73nkb6xmeqgZC5TWHtDKC1K0q7xQJKRMKmMmM5YBHdVCrjFAaSuQD0TQutV6YKa6FfTadl1PMezC20jnfbtUGmHQR3zQgNGgUIemzIxlfUGmHQR3zQgxSyGSlJzU8w4WlxuYNgalLAO9lWIAyjG(xrlB6KMIGjhJbWbKPlb4e0WvKGjt3UkXIbYXyaCaz6saoGA2bNoJGDzmZL3chE5Is(0ayPudTFDRANPo(PzZV(xrRGWRLc3TQDM64NMn)CXIbkJzU8w4WlxuYNgalLAO9lgdGditxcO)v0ki8APWDRANPo(PzZpxSyGYyMlVfo8YfL8PbWsPgA)IRmbn5cA6FfT41sHpyiQ)Gy9tcoDPHlwmW4SPtAkcMCbzcvxVZunobnCfjyYeVwkCbzcvxVZunUyXazpoBSji8APWDRANPo(PzZphqn7GdJ0mUMgxh7Ze4sIN0K(T4Bh2)Ktqdxrc2zYeVwk8KM0VfF7W(N8Ap7YyMlVfo8YfL8PbWsPgA)kitO66DMQjJzU8w4WlxuYNgalLAO9RtrwusgZC5TWHxUOKpnawk1q7xQJKRMK(xrlB6KMIGj3PilkXjOHRirCXMCbr9EmBfkgoGA2bNoJGDMmzdVwk8Pkee0lil)5aYCjtM41sHp5cj)pzGKdiZLShNn8APWhme1FqS(jbNU0WR9mz62vjwmq(GHO(dI1pj40LgoGA2bhgP5SlJzU8w4WlxuYNgalLAO9BBbPP8tcoDj9VIw20jnfbtUtrwuItqdxrI4In5cI69y2kumCa1SdoDgb7mzIxlf(GHO(dI1pj40LgETpoETu4Buc0VyiaFsZPR2iINMIGjxaitaTk2)KtqdxrczmZL3chE5Is(0ayPudTFX8FafMdk0)kAfeETu4UvTZuh)0S5Nx7zYKn8APWDG68FqSEBgRQsETpEAkcM8cbIUa)w84wMkItqdxrc2LXmxElC4Llk5tdGLsn0(fZ)buyoOq)ROfVwkCbzcvxVZunETNjtGHLyKMePmM5YBHdVCrjFAaSuQH2VBuc0VyiGmM5YBHdVCrjFAaSuQH2Vy(pGcZbfYyMlVfo8YfL8PbWsPgA)g9C5c66b15xgZC5TWHxUOKpnawk1q73R1tqXbX6JEUCbDLXKXmxElC4)MtlGGc9VIwa1SdoDQvubwElSdjs(NIZMoa7eEkkbtUjedV2ZKjETu4dgI6piw)KGtxA41E2LXmxElC4)MtdTFhDRk10RUmjG(xrlWWsDQjrgNn3UkXIbYfKjuD9ot14aQzhCy0NyYuN0uem5cYeQUENPACcA4ksWUmM5YBHd)3CAO9RGmHQR3zQM(xrlBUDvIfdKJRmbn5cACa1SdomstyYmnfbtoWIAyjaNGgUIeXD7QelgihyrnSeGdOMDWHrAc7XzZTRsSyGC3Q2zQJFA28ZbuZo40zemzYwAkcMCmgahqMUeGtqdxrI4UDvIfdKJXa4aY0LaCa1SdoDgb7SlJzU8w4W)nNgA)cSOgwcO)v0YgWoHNIsWKBcXWR9mzcSt4POem5Mqm8dYO0ayPKNxJ856fhXEC2C7Qelgi3TQDM64NMn)Ca1SdoDgbtMSLMIGjhJbWbKPlb4e0WvKiUBxLyXa5ymaoGmDjahqn7GtNrWo7YyMlVfo8FZPH2VUvTZuh)0S5x)ROfyNWtrjyYnHy41EMmb2j8uucMCtig(bzKMfjtMSbSt4POem5Mqm8dYOiImEAkcMCdILa(MbnSuJGjNGgUIeSlJzU8w4W)nNgA)IXa4aY0La6FfTa7eEkkbtUjedV2ZKjWoHNIsWKBcXWpiJ0SizYKnGDcpfLGj3eIHFqgfrKXttrWKBqSeW3mOHLAem5e0WvKGDzmZL3ch(V50q7xCLjOjxqt)ROLnbHxlfUBv7m1XpnB(51(4a7eEkkbtUjed)Gmknawk551iFUEXrSZKjWoHNIsWKBcXWR9XzJnbHxlfUBv7m1XpnB(5aQzhCyKMX1046yFMaxs8KM0VfF7W(NCcA4ksWotM41sHN0K(T4Bh2)Kx7zxgZC5TWH)Bon0(DJsG(fdb0)kA1byNWtrjyYnHy41EMmzdyNWtrjyYnHy41(42NjWLeFOBANZJXIsCcA4ksWUmM5YBHd)3CAO9Rtrwus)ROD6jLYNgalLdhZ)buyoOGrriJzU8w4W)nNgA)sDKC1K0)kA1byNWtrjyYnHy41EMmztN0uem5ofzrjobnCfjIl2KliQ3JzRqXWbuZo40zeSZKjETu4tviiOxqw(ZbK5szmZL3ch(V50q732cst5NeC6s6FfT6aSt4POem5Mqm8AptMSPtAkcMCNISOeNGgUIeXfBYfe17XSvOy4aQzhC6mc2LXmxElC4)MtdTFX8FafMdk0)kAb2j8uucMCtigETxgZC5TWH)Bon0(DJsG(fdbKXmxElC4)MtdTFX8FafMdk0)kAttrWKxiq0f43Ih3YurCcA4ksiJzU8w4W)nNgA)okRP)v0QtAkcM8cbIUa)w84wMkItqdxrI46aSt4POem5Mqm8AVmM5YBHd)3CAO9B0ZLlORhuNFzmZL3ch(V50q73R1tqXbX6JEUCbDLXKXmxElC4ZbXQiFAaSuQfqqH(xrlGA2bNo1kQalVf2Hej)tXfeETu4UvTZuh)0S5NlwmqzmZL3ch(CqSkYNgalLAO97OBvPME1Ljb0)kAbgwQtnjY441sHlitO66DMQXflgyC8APWBuBbD9BXRQUt4faYAdxSyGYyMlVfo85GyvKpnawk1q7xGf1Wsa9VIwDWRLcxqMq117mvJx7JZMBxLyXa5UvTZuh)0S5NdOMDWPZiyYKT0uem5ymaoGmDjaNGgUIeXD7QelgihJbWbKPlb4aQzhC6mc2zxgZC5TWHpheRI8PbWsPgA)6w1otD8tZMF9VIwDOziOJ4nQTGU(T4vv3j8cazTH3mg7cyYKn8APWBuBbD9BXRQUt4faYAdV2ZKPBxLyXa5nQTGU(T4vv3j8cazTHdOMDWHr6fj7YyMlVfo85GyvKpnawk1q7xmgahqMUeq)ROvhAgc6iEJAlORFlEv1DcVaqwB4nJXUaMmzdVwk8g1wqx)w8QQ7eEbGS2WR9mz62vjwmqEJAlORFlEv1DcVaqwB4aQzhCyKErYUmM5YBHdFoiwf5tdGLsn0(vqMq117mvtgZC5TWHpheRI8PbWsPgA)sDKC1K0)kAXRLcFQcbb9cYYFoGmxkJzU8w4WNdIvr(0ayPudTFXvMGMCbn9VIw3UkXIbYBlinLFsWPlXbuZo4eNnDstrWKlitO66DMQXjOHRibtM41sHlitO66DMQXflgi7XzJnbHxlfUBv7m1XpnB(51(46yFMaxs8KM0VfF7W(NCcA4ksWotM41sHN0K(T4Bh2)Kx7zpoETu4nQTGU(T4vv3j8cazTHlwmqzmZL3ch(CqSkYNgalLAO9Rtrwus)ROD6jLYNgalLdhZ)buyoOGrriJzU8w4WNdIvr(0ayPudTF3OeOFXqa9VIwGHL68trghVwk8g1wqx)w8QQ7eEbGS2WR9XfeETu4UvTZuh)0S5Nx7LXmxElC4ZbXQiFAaSuQH2VTfKMYpj40LKXmxElC4ZbXQiFAaSuQH2Vy(pGcZbf6FfTPPiyYlei6c8BXJBzQiobnCfjIZgETu4nQTGU(T4vv3j8cazTHx7zYeVwkCbzcvxVZunETNDzmZL3ch(CqSkYNgalLAO97gLa9lgciJzU8w4WNdIvr(0ayPudTFX8FafMdk0)kAttrWKxiq0f43Ih3YurCcA4ksiJzU8w4WNdIvr(0ayPudTFhL10)kA1jnfbtEHarxGFlECltfXjOHRiHmM5YBHdFoiwf5tdGLsn0(n65Yf01dQZVmM5YBHdFoiwf5tdGLsn0(9A9euCqS(ONlxqxuIseca]] )


end
