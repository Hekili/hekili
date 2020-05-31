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


    spec:RegisterPack( "Arms", 20200531, [[dGu2ybqiIKhHOKnHiFIQsvzuiKtPIAvikLELuHzjvQBHOq7c4xufnmQsDmIulJQKNrvW0KkPUgvLSnQkLVjvsgNur5CikO1rvPsZdr19KI2hvHoOur1cLcEivLkUiIc0iruaDseLkReHAMika3KQsvStQQAOikvTuQkvvpLOMkvvUkvLQ0wruk8veLI2lv(lPgmQoSWIvPhtXKjCzOntPpJGrlLonsRwQeVMQIztYTf1Ur53knCPQLRQNRy6sUUiBxk03jIXJOOZRISEPImFvy)G2jTZpNSik05VxE7L3E7lpinqAFZRUYlVCY1PE0j3hgFccOtMfz0j35FECY9Xj1gcNFo5ztVbDYTv1p(UE6jbA1MUaZM9CO5Kkk6YmFylphA24Pt(MOQISJ5UozruOZFV82lV92xEqAG0(MxDLxs7KJu1UVtwMMtQOOlZ35dB5KBPcbYCxNSahJtMSG8o)ZdKt2m(NUpKyYcYBRQF8D90tc0QnDbMn75qZjvu0Lz(WwEo0SXtiXKfK77job5Eq6UHCV82lVHedjMSGCFN2GrahFxiXKfKtgH8oxiqbKt2NYzubGetwqozeY7CHafqozdQP2)eK77pnTEs2L7rMGYia5KnOMA)taiXKfKtgH8oxiqbK3quLcHC52nvqETqE)JMnFJcY7CYEYaaqIjliNmc5Kbjt0Kk6YW333a5K9pAOdDzqoDGCbQWcfaiXKfKtgH8oxiqbK77DqiNSRW8aGetwqozeYjdSZ9DGCfDkiNoqUavyHcaKyYcYjJqUSpNAxLaY78ppqUPnyeWbYPmJkjqr3qUeA1c5fnJ6A1ckc5pQIcfqEjbdFgGtwrNAC(5KhkJGc1v8eWY5NZFPD(5KrwCvOW1Gt280cFA4KFmhu2a5K3eYfPpk6YGCYwi3BGhGCsqUaVjRfyw1otA0toMwGyLWCYHPOlZj)it4kN)E58ZjJS4QqHRbNS5Pf(0Wj)bbeYjhY9nVHCsq(nzTabgc1jTjuzGyLWGCsq(nzTGmM3)KETAvYqfAXJrEaIvcZjhMIUmN84tsPMEfTk8DLZFp48ZjJS4QqHRbNS5Pf(0WjlfKFtwlqGHqDsBcvgK6HCsqorqUzxLyLWaMvTZKg9KJPf8yoOSbYjhY9cYpoGCIG8kuiRasI)(y4d(aKfxfkGCsqUzxLyLWasI)(y4d(GhZbLnqo5qUxq(zi)StomfDzo5pAmiGVRC(31o)CYHPOlZjBw1otA0toMwNmYIRcfUgCLZFF58ZjhMIUmNSK4Vpg(GVtgzXvHcxdUY5VV58ZjhMIUmNSadH6K2eQStgzXvHcxdUY5Fx58ZjJS4QqHRbNS5Pf(0WjFtwlyscbY0cmQwWJHPCYHPOlZjJKjAsf6kN)DMZpNmYIRcfUgCYMNw4tdNSzxLyLWa59RqPN6P(GGhZbLnqojixG3K1cmRANjn6jhtlqSsyqojiNiixkiVcfYkGadH6K2eQmazXvHci)4aYVjRfiWqOoPnHkdeRegKFgYjb5eb5eb5c8MSwGzv7mPrp5yAbPEiNeKlfKhDcFAHGcNsVwDMsOTailUkua5NH8Jdi)MSwqHtPxRotj0wGupKFgYjb53K1cYyE)t61QvjdvOfpg5biwjmiNeK)bbeYjhY7AVDYHPOlZjFvHaNA)SRC(tg68ZjJS4QqHRbNS5Pf(0WjteKlfKxHczf4rMaGS4QqbKtcYfBbei2RLSjMyapMdkBGCsq(heqiNCiVR8gYjb53K1cYyE)t61QvjdvOfpg5biwjmiNeKlWBYAbMvTZKg9KJPfiwjmi)mKFCa5eb5vOqwbEKjailUkua5KGCXwabI9AjBIjgWJ5GYgiNeKl2c8itaEmhu2a5EeYjyeqoji)dciKtoK3vEd5KG8BYAbzmV)j9A1QKHk0IhJ8aeRegKtcYf4nzTaZQ2zsJEYX0ceRegKF2jhMIUmN82i(9Re8DLZFP925NtomfDzo58(vO0t9uFqNmYIRcfUgCLZFPL25NtgzXvHcxdozZtl8PHt(XCqzdKtEtixK(OOldYjBHCVbEWjhMIUmN8JmHRC(lTxo)CYilUku4AWjBEAHpnCYtpQu6kEcynajT0xjHYeqUhHCVCYHPOlZjBuy0i6kN)s7bNFozKfxfkCn4KnpTWNgozIGCIGCIG8BYAbzmV)j9A1QKHk0IhJ8as9q(zi)4aYjcYf4nzTaZQ2zsJEYX0cs9q(zi)4aYjcYVjRfiWqOoPnHkds9q(zi)mKtcYRqHScyXVX91RvFJQuiazXvHci)mKFCa5eb53K1cYyE)t61QvjdvOfpg5bK6HCsqUaVjRfyw1otA0toMwqQhYjb5sb5vOqwbS434(61QVrvkeGS4QqbKF2jhMIUmNSKw6RKqzcx58x6U25NtgzXvHcxdozZtl8PHtwkiVcfYkGf)g3xVw9nQsHaKfxfkGCsqorq(nzTGmM3)KETAvYqfAXJrEaPEi)4aYf4nzTaZQ2zsJEYX0cs9q(zNCyk6YCYJkYUY5V0(Y5NtomfDzo5gPMA)t6pnTozKfxfkCn4kN)s7Bo)CYHPOlZjtZ9itqze0nsn1(NCYilUku4AWvUYjlqBKuLZpN)s78ZjhMIUmNSPnEcOtgzXvHcxdUY5Vxo)CYHPOlZj3NYzu5KrwCvOW1GRC(7bNFozKfxfkCn4KnpTWNgozIG8kEcybAXqvTGEtb5Kd5EjnKFCa5vOqwbYXmH5raYIRcfqojiVINawGwmuvlO3uqo5qUh8ni)mKtcYjcYVjRfKX8(N0RvRsgQqlEmYdi1d5hhq(nzTacP4f0GPxRo6e(B1cs9q(zi)4aYLcYXzqMbbzmV)j9A1QKHk0IhJ8aYrx2hYjb5sb54miZGaZYeiBqHwrTODFdcYrx2hYjb5eb5v8eWc0IHQAb9McYjhY9sAi)4aYRqHScKJzcZJaKfxfkGCsqEfpbSaTyOQwqVPGCYHCp4Bq(ziNeKlWBYAbMvTZKg9KJPfK6DYHPOlZj3VfDzUY5Fx78ZjJS4QqHRbNS5Pf(0WjFtwliJ59pPxRwLmuHw8yKhqQhYjb53K1ckCk9A1zkH2cK6H8Jdi)MSwaHu8cAW0RvhDc)TAbPEiNeKlWBYAbMvTZKg9KJPfK6H8JdiNiixkihNbzgeKX8(N0RvRsgQqlEmYdihDzFiNeKlfKJZGmdcmltGSbfAf1I29niihDzFiNeKlWBYAbMvTZKg9KJPfK6H8Zo5Wu0L5KVQDfAB6p5kN)(Y5NtgzXvHcxdozZtl8PHt(MSwqgZ7FsVwTkzOcT4XipGupKtcYVjRfu4u61QZucTfi1d5hhq(nzTacP4f0GPxRo6e(B1cs9qojixG3K1cmRANjn6jhtli1d5hhq(nzTGbXQLYiO)Gacs9q(XbKteKlfKJZGmdcYyE)t61QvjdvOfpg5bKJUSpKtcYLcYXzqMbbMLjq2GcTIAr7(geKJUSpKtcYLcYXzqMbbx1Uc9A1vlQrgMpbYrx2hYjb5c8MSwGzv7mPrp5yAbPEi)StomfDzo5l(d((qzeCLZFFZ5NtgzXvHcxdozZtl8PHt(MSwqgZ7FsVwTkzOcT4XipaXkHb5KG8piGqo5qUV8gYjb5eb5MDvIvcdK3VcLEQN6dcEmhu2a5EeYjyeq(XbKteKxXtalqlgQQf0BkiNCi3lVH8JdiVcfYkqoMjmpcqwCvOaYjb5v8eWc0IHQAb9McYjhY9GVG8Zq(zNCyk6YCYXBcgQR9FKvUY5Fx58ZjJS4QqHRbNS5Pf(0WjlWBYAbMvTZKg9KJPfiwjmNCyk6YCYkkH2A0DjjiKrw5kN)DMZpNmYIRcfUgCYMNw4tdN8nzTGmM3)KETAvYqfAXJrEaPEiNeKFtwlOWP0RvNPeAlqQhYpoG8BYAbesXlObtVwD0j83QfK6HCsqUaVjRfyw1otA0toMwqQhYpoGCIGCPGCCgKzqqgZ7FsVwTkzOcT4XipGC0L9HCsqUuqoodYmiWSmbYguOvulA33GGC0L9HCsqUaVjRfyw1otA0toMwqQhYp7KdtrxMt2sF8Q2v4kN)KHo)CYilUku4AWjBEAHpnCY3K1cYyE)t61QvjdvOfpg5bK6HCsq(nzTGcNsVwDMsOTaPEi)4aYVjRfqifVGgm9A1rNWFRwqQhYjb5c8MSwGzv7mPrp5yAbPEi)4aYjcYLcYXzqMbbzmV)j9A1QKHk0IhJ8aYrx2hYjb5sb54miZGaZYeiBqHwrTODFdcYrx2hYjb5c8MSwGzv7mPrp5yAbPEi)StomfDzo5GzWP(qPnHs5kN)s7TZpNmYIRcfUgCYMNw4tdNSaVjRfyw1otA0toMwGyLWGCsq(nzTGmM3)KETAvYqfAXJrEaIvcdYjb5MDvIvcdK3VcLEQN6dcEmhu24KdtrxMt(ge0Rvxp14Z4kN)slTZpNmYIRcfUgCYHPOlZjhtBJbdh9hDAFTz)q5KnpTWNgozPGCbEtwl4JoTV2SFO0c8MSwqQhYpoGCIGCIG8kEcybAXqvTGEtb5Kd5E5nqAi)4aYRqHScKJzcZJaKfxfkGCsqEfpbSaTyOQwqVPGCYHCp4lG0q(ziNeKteKFtwliJ59pPxRwLmuHw8yKhqQhYjb5MDvIvcdKX8(N0RvRsgQqlEmYd4XCqzdKtoKlT3(gKFCa53K1ciKIxqdMET6Ot4Vvli1d5KGCbEtwlWSQDM0ONCmTGupKFgYpd5hhqorqEfpbSaTyOQwqVPGCYHCp4nqAiNeKlWBYAbMLjsMI2iQPmF0c8MSwqQhYjb5sb54miZGGmM3)KETAvYqfAXJrEa5Ol7d5KGCPGCCgKzqGzzcKnOqROw0UVbb5Ol7d5NH8JdiNiixkixG3K1cmltKmfTrutz(Of4nzTGupKtcYLcYXzqMbbzmV)j9A1QKHk0IhJ8aYrx2hYjb5sb54miZGaZYeiBqHwrTODFdcYrx2hYjb5c8MSwGzv7mPrp5yAbPEi)StMfz0jhtBJbdh9hDAFTz)q5kN)s7LZpNmYIRcfUgCYHPOlZjhDAAJpgTDzLET6(vc(ozZtl8PHtUOzuxRwqriNCiVR8gYjb5eb5MDvIvcdyw1otA0toMwWJ5GYgiNCixAVG8JdiNiiVcfYkGK4Vpg(GpazXvHciNeKB2vjwjmGK4Vpg(Gp4XCqzdKtoKlTxq(zi)mKFCa5sb5c8MSwGzv7mPrp5yAbPEiNeKlfKFtwlOWP0RvNPeAlqQhYjb5sb53K1cYyE)t61QvjdvOfpg5bK6HCsqErZOUwTGIqUhHCP9L3ozwKrNC0PPn(y02Lv61Q7xj47kN)s7bNFozKfxfkCn4KnpTWNgozZUkXkHbmRANjn6jhtl4XCqzdKtoK3zq(XbKteKxHczfqs83hdFWhGS4QqbKtcYn7QeRegqs83hdFWh8yoOSbYjhY7mi)StomfDzo5OXOI3vo)LURD(5KrwCvOW1Gt280cFA4Kn7QeRegWSQDM0ONCmTGhZbLnqo5qENb5hhqorqEfkKvajXFFm8bFaYIRcfqoji3SRsSsyajXFFm8bFWJ5GYgiNCiVZG8Zo5Wu0L5KtdQPfMhx58xAF58ZjJS4QqHRbNS5Pf(0Wjp9OsPR4jG1aK0sFLekta5EeYLgYjb5eb5MDvIvcdCvHaNA)m4XCqzdK7rixAVH8Jdi3SRsSsyaZQ2zsJEYX0cEmhu2a5EeY7mi)4aYJoHpTqqHtPxRotj0waKfxfkG8Zo5Wu0L5Khji2tze0t9uFWXvo)L23C(5KrwCvOW1Gt280cFA4KjcYVjRfu4u61QZucTfi1d5hhqorqUaVjRfyw1otA0toMwqQhYjb5sb5rNWNwiOWP0RvNPeAlaYIRcfq(zi)mKtcYjcYlAg11QfueY9iKtg6nKFCa5eb5v8eWc0IHQAb9McYjhY9YBi)4aYRqHScKJzcZJaKfxfkGCsqEfpbSaTyOQwqVPGCYHCp4li)mKF2jhMIUmN8vTRqVwD1IAKH5tUY5V0DLZpNmYIRcfUgCYMNw4tdNSuqUaVjRfyw1otA0toMwqQhYjb5sb53K1ckCk9A1zkH2cK6DYHPOlZj3NEQ9eLrqFvXuUY5V0DMZpNmYIRcfUgCYMNw4tdNSuqUaVjRfyw1otA0toMwqQhYjb5sb53K1ckCk9A1zkH2cK6DYHPOlZj)0(EfQPm90hg0vo)LMm05NtgzXvHcxdozZtl8PHtwkixG3K1cmRANjn6jhtli1d5KGCPG8BYAbfoLET6mLqBbs9o5Wu0L5KLSVs0isz6hNLfmd6kN)E5TZpNmYIRcfUgCYMNw4tdNSuqUaVjRfyw1otA0toMwqQhYjb5sb53K1ckCk9A1zkH2cK6DYHPOlZjBxtAqHo6e(0c1xmYUY5Vxs78ZjJS4QqHRbNS5Pf(0WjlfKlWBYAbMvTZKg9KJPfK6HCsqUuq(nzTGcNsVwDMsOTaPENCyk6YCYpg9ugbTvfzCCLZFV8Y5NtgzXvHcxdozZtl8PHtwkixG3K1cmRANjn6jhtli1d5KGCPG8BYAbfoLET6mLqBbs9qojixSfWSmdYQpkuOTQiJ6B6zGhZbLnqEti3BNCyk6YCYMLzqw9rHcTvfz0vo)9Ydo)CYilUku4AWjBEAHpnCY3K1cE04JcNrB33GGuVtomfDzo5Qf1j2DtmH2UVbDLZFV6ANFozKfxfkCn4KnpTWNgozPG8kuiRasI)(y4d(aKfxfkGCsqUzxLyLWaMvTZKg9KJPf8yoOSbYjhY9fKtcYjcYlAg11QfueY9iK7L0Ed5hhqorqEfpbSaTyOQwqVPGCYHCV8gYpoG8kuiRa5yMW8iazXvHciNeKxXtalqlgQQf0BkiNCi3d(cYpd5hhqErZOUwTGIqo5qUhKgYp7KdtrxMtMqkEbny61QJoH)wTUY5Vx(Y5NtgzXvHcxdozZtl8PHtUcfYkGK4Vpg(GpazXvHciNeKB2vjwjmGK4Vpg(Gp4XCqzdKtoK7liNeKteKx0mQRvlOiK7ri3lP9gYpoGCIG8kEcybAXqvTGEtb5Kd5E5nKFCa5vOqwbYXmH5raYIRcfqojiVINawGwmuvlO3uqo5qUh8fKFgYpoG8IMrDTAbfHCYHCpinKF2jhMIUmNmHu8cAW0RvhDc)TADLZFV8nNFozKfxfkCn4KnpTWNgozPG8kuiRasI)(y4d(aKfxfkGCsqUzxLyLWaMvTZKg9KJPf8yoOSbYjhYLgYjb5eb5fnJ6A1ckc5EeYL2xEd5hhqorqEfpbSaTyOQwqVPGCYHCV8gYpoG8kuiRa5yMW8iazXvHciNeKxXtalqlgQQf0BkiNCi3d(cYpd5NDYHPOlZjNX8(N0RvRsgQqlEmYJRC(7vx58ZjJS4QqHRbNS5Pf(0WjxHczfqs83hdFWhGS4QqbKtcYn7QeRegqs83hdFWh8yoOSbYjhYLgYjb5eb5fnJ6A1ckc5EeYL2xEd5hhqorqEfpbSaTyOQwqVPGCYHCV8gYpoG8kuiRa5yMW8iazXvHciNeKxXtalqlgQQf0BkiNCi3d(cYpd5NDYHPOlZjNX8(N0RvRsgQqlEmYJRC(7vN58ZjJS4QqHRbNS5Pf(0Wjp9OsPR4jG1aK0sFLekta5EeY7ANCyk6YCYFIPdtrxMwrNYjROtPzrgDYwAJOUINawUY5VxKHo)CYilUku4AWjBEAHpnCYeb5vOqwbYXmH5raYIRcfqojiVINawGwmuvlO3uqo5qUh8fKFgYpoG8kEcybAXqvTGEtb5Kd5E5TtomfDzo5pX0HPOltROt5Kv0P0SiJozKmrtQqx583dE78ZjJS4QqHRbNCyk6YCYFIPdtrxMwrNYjROtPzrgDYdLrqH6kEcy5kx5K7F0S5Buo)C(lTZpNCyk6YCY3OkfQN2nvozKfxfkCn4kN)E58ZjJS4QqHRbNmlYOto600gFmA7Yk9A19Re8DYHPOlZjhDAAJpgTDzLET6(vc(UY5VhC(5KrwCvOW1Gt280cFA4KRqHScyXVX91RvFJQuiazXvHci)4aYRqHScKJzcZJaKfxfkGCsqErZOUwTGIqUhHCP9L3q(XbKxHczf4rMaGS4QqbKtcYlAg11QfueY9iKlTxE7KdtrxMtoJ59pPxRwLmuHw8yKhx58VRD(5KrwCvOW1Gt280cFA4KRqHScyXVX91RvFJQuiazXvHci)4aYRqHScKJzcZJaKfxfkGCsqErZOUwTGIqUhHCVK2Bi)4aYRqHSc8itaqwCvOaYjb5eb5fnJ6A1ckc5EeY9sAVH8JdiVOzuxRwqriNCix6U2xq(zNCyk6YCYesXlObtVwD0j83Q1vo)9LZpNCyk6YCY9BrxMtgzXvHcxdUYvozKmrtQqNFo)L25NtgzXvHcxdozZtl8PHt(dciKtoK7lVGCsq(nzTabgc1jTjuzGyLWGCsq(nzTGmM3)KETAvYqfAXJrEaIvcZjhMIUmN84tsPMEfTk8DLZFVC(5KrwCvOW1Gt280cFA4KLcYVjRfiWqOoPnHkds9qojiNii3SRsSsyaZQ2zsJEYX0cEmhu2a5Kd5Eb5hhqorqEfkKvajXFFm8bFaYIRcfqoji3SRsSsyajXFFm8bFWJ5GYgiNCi3li)mKF2jhMIUmN8hngeW3vo)9GZpNmYIRcfUgCYMNw4tdNSuqoodYmiiJ59pPxRwLmuHw8yKhqo6Y(q(XbKteKFtwliJ59pPxRwLmuHw8yKhqQhYpoGCZUkXkHbYyE)t61QvjdvOfpg5b8yoOSbY9iKlT3q(zNCyk6YCYMvTZKg9KJP1vo)7ANFozKfxfkCn4KnpTWNgozPGCCgKzqqgZ7FsVwTkzOcT4XipGC0L9H8JdiNii)MSwqgZ7FsVwTkzOcT4XipGupKFCa5MDvIvcdKX8(N0RvRsgQqlEmYd4XCqzdK7rixAVH8Zo5Wu0L5KLe)9XWh8DLZFF58ZjhMIUmNSadH6K2eQStgzXvHcxdUY5VV58ZjJS4QqHRbNS5Pf(0WjlfKFtwliJ59pPxRwLmuHw8yKhqQhYjb53K1ckCk9A1zkH2cK6HCsq(heqiNCi3dEd5KGCPG8BYAbcmeQtAtOYGuVtomfDzo5Rke4u7NDLZ)UY5NtgzXvHcxdozZtl8PHtE6rLsxXtaRbiPL(kjuMaY9iK7LtomfDzozJcJgrx58VZC(5KrwCvOW1Gt280cFA4KVjRfy(00sze0XmrsvGupKtcYVjRfKX8(N0RvRsgQqlEmYdqSsyo5Wu0L5KhvKDLZFYqNFozKfxfkCn4KnpTWNgo5hZbLnqo5nHCr6JIUmiNSfY9g4biNeKxXtalqrZOUwTGIqUhH8UYjhMIUmN8JmHRC(lT3o)CYilUku4AWjBEAHpnCY3K1c2gXVFLGpyQW4dK3eY9cYjb5vOqwbepgcwKi0waKfxfkCYHPOlZjN3VcLEQN6d6kN)slTZpNmYIRcfUgCYMNw4tdN8nzTGmM3)KETAvYqfAXJrEaPEi)4aYVjRfiWqOoPnHkds9q(XbKlWBYAbMvTZKg9KJPfK6H8Jdi)MSwqHtPxRotj0wGuVtomfDzozKmrtQqx58xAVC(5KdtrxMtEBe)(vc(ozKfxfkCn4kN)s7bNFo5Wu0L5KrYenPcDYilUku4AWvUYjBPnI6kEcy58Z5V0o)CYilUku4AWjBEAHpnCYFqaHCYHCFZBiNeKteKlfKxHczfqGHqDsBcvgGS4QqbKFCa53K1ceyiuN0MqLbIvcdYp7KdtrxMtE8jPutVIwf(UY5Vxo)CYilUku4AWjBEAHpnCYeb5sb5vOqwbKe)9XWh8bilUkua5hhqUzxLyLWasI)(y4d(GhZbLnqo5qUxq(zNCyk6YCYF0yqaFx583do)CYilUku4AWjBEAHpnCYc8MSwGzv7mPrp5yAbIvcZjhMIUmNSzv7mPrp5yADLZ)U25NtgzXvHcxdozZtl8PHtwG3K1cmRANjn6jhtlqSsyo5Wu0L5KLe)9XWh8DLZFF58ZjJS4QqHRbNS5Pf(0WjFtwlyKGypLrqp1t9bhGyLWGCsqorqUuqEfkKvabgc1jTjuzaYIRcfq(XbKFtwlqGHqDsBcvgiwjmi)mKtcYjcYjcYf4nzTaZQ2zsJEYX0cEmhu2a5EeY7AGVGCsqUuqE0j8PfckCk9A1zkH2cGS4QqbKFgYpoG8BYAbfoLET6mLqBbs9q(zNCyk6YCYxviWP2p7kN)(MZpNCyk6YCYcmeQtAtOYozKfxfkCn4kN)DLZpNCyk6YCYgfgnIozKfxfkCn4kN)DMZpNmYIRcfUgCYMNw4tdNmrqUuqEfkKvaJcJgraYIRcfqojixSfqGyVwYMyIb8yoOSbYjhY9cYpd5hhqorq(nzTGjjeitlWOAbpgMcYpoG8BYAbtTmu3IXxGhdtb5NHCsqorq(nzTGrcI9ugb9up1hCaPEi)4aYn7QeRegyKGypLrqp1t9bhWJ5GYgi3JqENb5NDYHPOlZjJKjAsf6kN)KHo)CYilUku4AWjBEAHpnCYeb5sb5vOqwbmkmAebilUkua5KGCXwabI9AjBIjgWJ5GYgiNCi3li)mKFCa53K1cgji2tze0t9uFWbK6HCsq(nzTGTr87xj4dMkm(a5nHCVGCsqEfkKvaXJHGfjcTfazXvHcNCyk6YCY59RqPN6P(GUY5V0E78ZjJS4QqHRbNS5Pf(0WjlWBYAbMvTZKg9KJPfK6H8JdiNii)MSwG5ttlLrqhZejvbs9qojiVcfYkGf)g3xVw9nQsHaKfxfkG8Zo5Wu0L5KL0sFLekt4kN)slTZpNmYIRcfUgCYMNw4tdN8nzTabgc1jTjuzqQhYpoG8piGqUhHCFZBNCyk6YCYsAPVscLjCLZFP9Y5NtomfDzo5Tr87xj47KrwCvOW1GRC(lThC(5KdtrxMtwsl9vsOmHtgzXvHcxdUY5V0DTZpNCyk6YCYnsn1(N0FAADYilUku4AWvo)L2xo)CYHPOlZjtZ9itqze0nsn1(NCYilUku4AWvUYvo5gXFOlZ5VxE7L3E7L0E7KLepJYimozYUC)(fkGCFb5HPOldYv0PgaKyN80JgN)DL0o5(FTuf6KjliVZ)8a5KnJ)P7djMSG82Q6hFxp9KaTAtxGzZEo0CsffDzMpSLNdnB8esmzb5(EItqUhKUBi3lV9YBiXqIjli33PnyeWX3fsmzb5KriVZfcua5K9PCgvaiXKfKtgH8oxiqbKt2GAQ9pb5((ttRNKD5EKjOmcqozdQP2)easmzb5KriVZfcua5nevPqixUDtfKxlK3)OzZ3OG8oNSNmaaKyYcYjJqozqYenPIUm899nqoz)Jg6qxgKthixGkSqbasmzb5KriVZfcua5(EheYj7kmpaiXKfKtgHCYa7CFhixrNcYPdKlqfwOaajMSGCYiKl7ZP2vjG8o)ZdKBAdgbCGCkZOscu0nKlHwTqErZOUwTGIq(JQOqbKxsWWNbajgsmzb5Kbjt0Kkua5x0Upc5MnFJcYVibkBaqENBmyFnqoBzKX24Z2KcYdtrx2a5ltDcajMSG8Wu0LnG(hnB(gvtRkgFGetwqEyk6Ygq)JMnFJQJMEA3vajMSG8Wu0LnG(hnB(gvhn9mseYiRIIUmiXKfKlZI(PDli)dQaYVjRffq(urnq(fT7JqUzZ3OG8lsGYgipyciV)rYy)wfLraYPdKlwgcGehMIUSb0)OzZ3O6OPN3OkfQN2nvqIdtrx2a6F0S5BuD00Z0GAAH5UzrgBgDAAJpgTDzLET6(vc(qIdtrx2a6F0S5BuD00ZmM3)KETAvYqfAXJrE6MABwHczfWIFJ7RxR(gvPqaYIRcfhhvOqwbYXmH5raYIRcfKkAg11Qfu0Js7lVpoQqHSc8itaqwCvOGurZOUwTGIEuAV8gsCyk6Ygq)JMnFJQJMEsifVGgm9A1rNWFR2UP2MvOqwbS434(61QVrvkeGS4QqXXrfkKvGCmtyEeGS4QqbPIMrDTAbf9Oxs79XrfkKvGhzcaYIRcfKiQOzuxRwqrp6L0EFCu0mQRvlOi5s31(6mK4Wu0LnG(hnB(gvhn9SFl6YGedjMSGCYGKjAsfkGCSr8pb5fnJqE1IqEyQ9HC6a5rJbvfxfcGehMIUSPPPnEciK4Wu0LnD00Z(uoJkiXHPOlB6OPN9Brxw3uBtIQ4jGfOfdv1c6nf5Ej9XrfkKvGCmtyEeGS4QqbPkEcybAXqvTGEtrUh8TZKi6MSwqgZ7FsVwTkzOcT4XipGu)XXnzTacP4f0GPxRo6e(B1cs9NpoKcNbzgeKX8(N0RvRsgQqlEmYdihDzFssHZGmdcmltGSbfAf1I29niihDzFsevXtalqlgQQf0BkY9s6JJkuiRa5yMW8iazXvHcsv8eWc0IHQAb9MICp4BNjjWBYAbMvTZKg9KJPfK6HehMIUSPJMEEv7k020FQBQT5nzTGmM3)KETAvYqfAXJrEaPEs3K1ckCk9A1zkH2cK6poUjRfqifVGgm9A1rNWFRwqQNKaVjRfyw1otA0toMwqQ)4GiPWzqMbbzmV)j9A1QKHk0IhJ8aYrx2NKu4miZGaZYeiBqHwrTODFdcYrx2NKaVjRfyw1otA0toMwqQ)mK4Wu0LnD00Zl(d((qze6MABEtwliJ59pPxRwLmuHw8yKhqQN0nzTGcNsVwDMsOTaP(JJBYAbesXlObtVwD0j83QfK6jjWBYAbMvTZKg9KJPfK6poUjRfmiwTugb9heqqQ)4GiPWzqMbbzmV)j9A1QKHk0IhJ8aYrx2NKu4miZGaZYeiBqHwrTODFdcYrx2NKu4miZGGRAxHET6Qf1idZNa5Ol7tsG3K1cmRANjn6jhtli1FgsCyk6YMoA6z8MGH6A)hzv3uBZBYAbzmV)j9A1QKHk0IhJ8aeRegPpiGK7lVjrKzxLyLWa59RqPN6P(GGhZbLnEKGrCCqufpbSaTyOQwqVPi3lVpoQqHScKJzcZJaKfxfkivXtalqlgQQf0BkY9GVoFgsCyk6YMoA6PIsOTgDxscczKvDtTnf4nzTaZQ2zsJEYX0ceRegK4Wu0LnD00tl9XRAxr3uBZBYAbzmV)j9A1QKHk0IhJ8as9KUjRfu4u61QZucTfi1FCCtwlGqkEbny61QJoH)wTGupjbEtwlWSQDM0ONCmTGu)XbrsHZGmdcYyE)t61QvjdvOfpg5bKJUSpjPWzqMbbMLjq2GcTIAr7(geKJUSpjbEtwlWSQDM0ONCmTGu)ziXHPOlB6OPNbZGt9HsBcLQBQT5nzTGmM3)KETAvYqfAXJrEaPEs3K1ckCk9A1zkH2cK6poUjRfqifVGgm9A1rNWFRwqQNKaVjRfyw1otA0toMwqQ)4GiPWzqMbbzmV)j9A1QKHk0IhJ8aYrx2NKu4miZGaZYeiBqHwrTODFdcYrx2NKaVjRfyw1otA0toMwqQ)mK4Wu0LnD00ZBqqVwD9uJpt3uBtbEtwlWSQDM0ONCmTaXkHr6MSwqgZ7FsVwTkzOcT4XipaXkHrYSRsSsyG8(vO0t9uFqWJ5GYgiXHPOlB6OPNPb10cZDZIm2mM2gdgo6p60(AZ(HQBQTPuc8MSwWhDAFTz)qPf4nzTGu)XbrevXtalqlgQQf0BkY9YBG0hhvOqwbYXmH5raYIRcfKQ4jGfOfdv1c6nf5EWxaPptIOBYAbzmV)j9A1QKHk0IhJ8as9Km7QeRegiJ59pPxRwLmuHw8yKhWJ5GYgYL2BF744MSwaHu8cAW0RvhDc)TAbPEsc8MSwGzv7mPrp5yAbP(ZNpoiQINawGwmuvlO3uK7bVbstsG3K1cmltKmfTrutz(Of4nzTGupjPWzqMbbzmV)j9A1QKHk0IhJ8aYrx2NKu4miZGaZYeiBqHwrTODFdcYrx2)8XbrsjWBYAbMLjsMI2iQPmF0c8MSwqQNKu4miZGGmM3)KETAvYqfAXJrEa5Ol7tskCgKzqGzzcKnOqROw0UVbb5Ol7tsG3K1cmRANjn6jhtli1FgsCyk6YMoA6zAqnTWC3SiJnJonTXhJ2USsVwD)kb)UP2MfnJ6A1cksEx5njIm7QeRegWSQDM0ONCmTGhZbLnKlTxhhevHczfqs83hdFWhGS4QqbjZUkXkHbKe)9XWh8bpMdkBixAVoF(4qkbEtwlWSQDM0ONCmTGupjPUjRfu4u61QZucTfi1tsQBYAbzmV)j9A1QKHk0IhJ8as9KkAg11Qfu0Js7lVHehMIUSPJMEgngv8DtTnn7QeRegWSQDM0ONCmTGhZbLnK3zhhevHczfqs83hdFWhGS4QqbjZUkXkHbKe)9XWh8bpMdkBiVZodjomfDzthn9mnOMwyE6MABA2vjwjmGzv7mPrp5yAbpMdkBiVZooiQcfYkGK4Vpg(GpazXvHcsMDvIvcdij(7JHp4dEmhu2qENDgsCyk6YMoA65ibXEkJGEQN6doDtTnNEuP0v8eWAasAPVscLj8O0KiYSRsSsyGRke4u7NbpMdkB8O0EFCy2vjwjmGzv7mPrp5yAbpMdkB8yNDCeDcFAHGcNsVwDMsOTailUkuCgsCyk6YMoA65vTRqVwD1IAKH5tDtTnj6MSwqHtPxRotj0wGu)Xbrc8MSwGzv7mPrp5yAbPEssfDcFAHGcNsVwDMsOTailUkuC(mjIkAg11Qfu0JKHEFCqufpbSaTyOQwqVPi3lVpoQqHScKJzcZJaKfxfkivXtalqlgQQf0BkY9GVoFgsCyk6YMoA6zF6P2tugb9vft1n12ukbEtwlWSQDM0ONCmTGupjPUjRfu4u61QZucTfi1djomfDzthn98P99kutz6Ppmy3uBtPe4nzTaZQ2zsJEYX0cs9KK6MSwqHtPxRotj0wGupK4Wu0LnD00tj7RenIuM(XzzbZGDtTnLsG3K1cmRANjn6jhtli1tsQBYAbfoLET6mLqBbs9qIdtrx20rtpTRjnOqhDcFAH6lg5UP2MsjWBYAbMvTZKg9KJPfK6jj1nzTGcNsVwDMsOTaPEiXHPOlB6OPNpg9ugbTvfzC6MABkLaVjRfyw1otA0toMwqQNKu3K1ckCk9A1zkH2cK6HehMIUSPJMEAwMbz1hfk0wvKXUP2MsjWBYAbMvTZKg9KJPfK6jj1nzTGcNsVwDMsOTaPEsITaMLzqw9rHcTvfzuFtpd8yoOSPP3qIdtrx20rtpRwuNy3nXeA7(gSBQT5nzTGhn(OWz029nii1djomfDzthn9KqkEbny61QJoH)wTDtTnLQcfYkGK4Vpg(GpazXvHcsMDvIvcdyw1otA0toMwWJ5GYgY9fjIkAg11Qfu0JEjT3hhevXtalqlgQQf0BkY9Y7JJkuiRa5yMW8iazXvHcsv8eWc0IHQAb9MICp4RZhhfnJ6A1cksUhK(mK4Wu0LnD00tcP4f0GPxRo6e(B12n12ScfYkGK4Vpg(GpazXvHcsMDvIvcdij(7JHp4dEmhu2qUVirurZOUwTGIE0lP9(4GOkEcybAXqvTGEtrUxEFCuHczfihZeMhbilUkuqQINawGwmuvlO3uK7bFD(4OOzuxRwqrY9G0NHehMIUSPJMEMX8(N0RvRsgQqlEmYt3uBtPQqHScij(7JHp4dqwCvOGKzxLyLWaMvTZKg9KJPf8yoOSHCPjrurZOUwTGIEuAF59Xbrv8eWc0IHQAb9MICV8(4OcfYkqoMjmpcqwCvOGufpbSaTyOQwqVPi3d(68ziXHPOlB6OPNzmV)j9A1QKHk0IhJ80n12ScfYkGK4Vpg(GpazXvHcsMDvIvcdij(7JHp4dEmhu2qU0KiQOzuxRwqrpkTV8(4GOkEcybAXqvTGEtrUxEFCuHczfihZeMhbilUkuqQINawGwmuvlO3uK7bFD(mK4Wu0LnD00ZpX0HPOltROt1nlYytlTruxXtaRUP2MtpQu6kEcynajT0xjHYeESRHehMIUSPJME(jMomfDzAfDQUzrgBIKjAsf2n12KOkuiRa5yMW8iazXvHcsv8eWc0IHQAb9MICp4RZhhv8eWc0IHQAb9MICV8gsCyk6YMoA65Ny6Wu0LPv0P6MfzS5qzeuOUINawqIHehMIUSbGKjAsf2C8jPutVIwf(DtTn)GasUV8I0nzTabgc1jTjuzGyLWiDtwliJ59pPxRwLmuHw8yKhGyLWGehMIUSbGKjAsf2rtp)OXGa(DtTnL6MSwGadH6K2eQmi1tIiZUkXkHbmRANjn6jhtl4XCqzd5EDCqufkKvajXFFm8bFaYIRcfKm7QeRegqs83hdFWh8yoOSHCVoFgsCyk6YgasMOjvyhn90SQDM0ONCmTDtTnLcNbzgeKX8(N0RvRsgQqlEmYdihDz)JdIUjRfKX8(N0RvRsgQqlEmYdi1FCy2vjwjmqgZ7FsVwTkzOcT4XipGhZbLnEuAVpdjomfDzdajt0KkSJMEkj(7JHp43n12ukCgKzqqgZ7FsVwTkzOcT4XipGC0L9poi6MSwqgZ7FsVwTkzOcT4XipGu)XHzxLyLWazmV)j9A1QKHk0IhJ8aEmhu24rP9(mK4Wu0LnaKmrtQWoA6PadH6K2eQmK4Wu0LnaKmrtQWoA65vfcCQ9ZDtTnL6MSwqgZ7FsVwTkzOcT4XipGupPBYAbfoLET6mLqBbs9K(GasUh8MKu3K1ceyiuN0MqLbPEiXHPOlBaizIMuHD00tJcJgXUP2MtpQu6kEcynajT0xjHYeE0liXHPOlBaizIMuHD00Zrf5UP2M3K1cmFAAPmc6yMiPkqQN0nzTGmM3)KETAvYqfAXJrEaIvcdsCyk6YgasMOjvyhn98rMOBQT5J5GYgYBksFu0Lr26nWdKQ4jGfOOzuxRwqrp2vqIdtrx2aqYenPc7OPN59RqPN6P(GDtTnVjRfSnIF)kbFWuHXNMErQcfYkG4XqWIeH2cGS4QqbK4Wu0LnaKmrtQWoA6jsMOjvy3uBZBYAbzmV)j9A1QKHk0IhJ8as9hh3K1ceyiuN0MqLbP(JdbEtwlWSQDM0ONCmTGu)XXnzTGcNsVwDMsOTaPEiXHPOlBaizIMuHD00ZTr87xj4djomfDzdajt0KkSJMEIKjAsfcjgsCyk6YgGL2iQR4jGvZXNKsn9kAv43n128dci5(M3KisQkuiRacmeQtAtOYaKfxfkooUjRfiWqOoPnHkdeRe2ziXHPOlBawAJOUINawD00ZpAmiGF3uBtIKQcfYkGK4Vpg(GpazXvHIJdZUkXkHbKe)9XWh8bpMdkBi3RZqIdtrx2aS0grDfpbS6OPNMvTZKg9KJPTBQTPaVjRfyw1otA0toMwGyLWGehMIUSbyPnI6kEcy1rtpLe)9XWh87MABkWBYAbMvTZKg9KJPfiwjmiXHPOlBawAJOUINawD00ZRke4u7N7MABEtwlyKGypLrqp1t9bhGyLWirKuvOqwbeyiuN0MqLbilUkuCCCtwlqGHqDsBcvgiwjSZKiIibEtwlWSQDM0ONCmTGhZbLnESRb(IKurNWNwiOWP0RvNPeAlaYIRcfNpoUjRfu4u61QZucTfi1FgsCyk6YgGL2iQR4jGvhn9uGHqDsBcvgsCyk6YgGL2iQR4jGvhn90OWOresCyk6YgGL2iQR4jGvhn9ejt0KkSBQTjrsvHczfWOWOreGS4QqbjXwabI9AjBIjgWJ5GYgY968Xbr3K1cMKqGmTaJQf8yyQJJBYAbtTmu3IXxGhdtDMer3K1cgji2tze0t9uFWbK6pom7QeRegyKGypLrqp1t9bhWJ5GYgp2zNHehMIUSbyPnI6kEcy1rtpZ7xHsp1t9b7MABsKuvOqwbmkmAebilUkuqsSfqGyVwYMyIb8yoOSHCVoFCCtwlyKGypLrqp1t9bhqQN0nzTGTr87xj4dMkm(00lsvOqwbepgcwKi0waKfxfkGehMIUSbyPnI6kEcy1rtpL0sFLekt0n12uG3K1cmRANjn6jhtli1FCq0nzTaZNMwkJGoMjsQcK6jvHczfWIFJ7RxR(gvPqaYIRcfNHehMIUSbyPnI6kEcy1rtpL0sFLekt0n128MSwGadH6K2eQmi1FC8bb0J(M3qIdtrx2aS0grDfpbS6OPNBJ43VsWhsCyk6YgGL2iQR4jGvhn9usl9vsOmbK4Wu0LnalTruxXtaRoA6zJutT)j9NMwiXHPOlBawAJOUINawD00tAUhzckJGUrQP2)eKyiXHPOlBadLrqH6kEcy18rMOBQT5J5GYgYBksFu0Lr26nWdKe4nzTaZQ2zsJEYX0ceRegK4Wu0LnGHYiOqDfpbS6OPNJpjLA6v0QWVBQT5heqY9nVjDtwlqGHqDsBcvgiwjms3K1cYyE)t61QvjdvOfpg5biwjmiXHPOlBadLrqH6kEcy1rtp)OXGa(DtTnL6MSwGadH6K2eQmi1tIiZUkXkHbmRANjn6jhtl4XCqzd5EDCqufkKvajXFFm8bFaYIRcfKm7QeRegqs83hdFWh8yoOSHCVoFgsCyk6YgWqzeuOUINawD00tZQ2zsJEYX0cjomfDzdyOmckuxXtaRoA6PK4Vpg(GpK4Wu0LnGHYiOqDfpbS6OPNcmeQtAtOYqIdtrx2agkJGc1v8eWQJMEIKjAsf2n128MSwWKecKPfyuTGhdtbjomfDzdyOmckuxXtaRoA65vfcCQ9ZDtTnn7QeRegiVFfk9up1he8yoOSHKaVjRfyw1otA0toMwGyLWirKuvOqwbeyiuN0MqLbilUkuCCCtwlqGHqDsBcvgiwjSZKiIibEtwlWSQDM0ONCmTGupjPIoHpTqqHtPxRotj0waKfxfkoFCCtwlOWP0RvNPeAlqQ)mPBYAbzmV)j9A1QKHk0IhJ8aeRegPpiGK31EdjomfDzdyOmckuxXtaRoA652i(9Re87MABsKuvOqwbEKjailUkuqsSfqGyVwYMyIb8yoOSH0heqY7kVjDtwliJ59pPxRwLmuHw8yKhGyLWijWBYAbMvTZKg9KJPfiwjSZhhevHczf4rMaGS4QqbjXwabI9AjBIjgWJ5GYgsITapYeGhZbLnEKGrq6dci5DL3KUjRfKX8(N0RvRsgQqlEmYdqSsyKe4nzTaZQ2zsJEYX0ceRe2ziXHPOlBadLrqH6kEcy1rtpZ7xHsp1t9bHehMIUSbmugbfQR4jGvhn98rMOBQT5J5GYgYBksFu0Lr26nWdqIdtrx2agkJGc1v8eWQJMEAuy0i2n12C6rLsxXtaRbiPL(kjuMWJEbjomfDzdyOmckuxXtaRoA6PKw6RKqzIUP2Merer3K1cYyE)t61QvjdvOfpg5bK6pFCqKaVjRfyw1otA0toMwqQ)8Xbr3K1ceyiuN0MqLbP(ZNjvHczfWIFJ7RxR(gvPqaYIRcfNpoi6MSwqgZ7FsVwTkzOcT4XipGupjbEtwlWSQDM0ONCmTGupjPQqHScyXVX91RvFJQuiazXvHIZqIdtrx2agkJGc1v8eWQJMEoQi3n12uQkuiRaw8BCF9A13OkfcqwCvOGer3K1cYyE)t61QvjdvOfpg5bK6poe4nzTaZQ2zsJEYX0cs9NHehMIUSbmugbfQR4jGvhn9SrQP2)K(ttlK4Wu0LnGHYiOqDfpbS6OPN0CpYeugbDJutT)jx5kNda]] )


end
