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

            toggle = "cooldowns",

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

        potion = "potion_of_bursting_blood",

        package = "Arms",
    } )


    spec:RegisterPack( "Arms", 20190707.2225, [[dyuIkbqisvEeku2KuXNeIqnksjNcLQvjer9kukZsiClvLODr4xQkgMqLJrQQLrk1ZuvktdfQUgPc2MQs13eI04ivuNJuHADQkHMNqv3JuSpuihuvjzHOOEOqe4IQkboPQskRuOmtHiODIImuvLuTuHispvvMkk4QcreBvvjOVkeHSxq)LQgSGdtzXq1JPYKr1Lr2SK(mumAO0Pvz1KkKxtQ0Sj62sz3q(TsdxQA5apxX0fDDj2Uq67QQgVquNxQ06jvK5Js2pjd1hYa8XTKGmPDC6RJJlsJlsfART2rAC6dFz3Ec(6nNUggc(qwJGVVc0g4R36kxJdza(MTaCe8HnZ(5l(5dMlXwWfUT9zUwrA5TihWQ5N5AUpWhE5K5xdbXHpULeKjTJtFDCCrACrQqBT1osJtF4Zkj2faFVRvKwElksaWQj8H94CcbXHpono4JXuHVc0gvisKba3cuXymvaBM9Zx8ZhmxITGlCB7ZCTI0YBroGvZpZ1CFuXymviwr2vfI0iubTJtFDSk8LQG2A)f1MXvXuXymvisawdHHMVOkgJPcFPk8vCoXvHVEP1iPqfJXuHVuf(koN4QWx45Yf0vfIKwgSF(ATEcXpegv4l8C5c6kuXymv4lvHVIZjUkWSLPKuHh2TKQqUQqpGCBd3sv4R(6rcfQymMk8LQWxqKjxjVfrGiXJk81bK7MBrQWnQaNKusCHkgJPcFPk8vCoXvHijdPcFTKAJa(K3KdKb4Boegj5tdGHsidqM0hYa8ridxsCiZWNdCjbod(auZo0OcXRrf4fGL3IuHizvioX3uHoQaNWl1QWTYDMY4NMnyf89hbFMlVfbFacXHjKjTHmaFeYWLehYm85axsGZGpGHHuH4vHVhNk0rfWl1QGtgx217mztW3FKk0rfWl1QOrTf01VvVS4oUNdiRnc((JGpZL3IGVr3Iuo9YltcatitFdYa8ridxsCiZWNdCjbod(0tfWl1QGtgx217mztu6vHoQGwQGBxjF)rc3k3zkJFA2GvaOMDOrfIxf0wfyXsf0sfstsOu8BaCaz6sabHmCjXvHoQGBxjF)rIFdGditxciauZo0OcXRcARcSRcSdFMlVfbFalQHHaWeYeJdza(iKHljoKz4ZbUKaNbF6Pc0meYrIg1wqx)w9YI74EoGS2iAMoAbQalwQGwQaEPwfnQTGU(T6Lf3X9CazTru6vbwSub3Us((JenQTGU(T6Lf3X9CazTraOMDOrfyKkOFCQa7WN5YBrWNBL7mLXpnBWctit6aKb4JqgUK4qMHph4scCg8PNkqZqihjAuBbD9B1llUJ75aYAJOz6OfOcSyPcAPc4LAv0O2c663QxwCh3ZbK1grPxfyXsfC7k57ps0O2c663QxwCh3ZbK1gbGA2HgvGrQG(XPcSdFMlVfbF)gahqMUeaMqM(oKb4ZC5Ti4Jtgx217mzd(iKHljoKzyczksHmaFeYWLehYm85axsGZGp8sTkMcNtipNSeRaqMlHpZL3IGpkYKRKemHmPZqgGpcz4sIdzg(CGljWzWNBxjF)rI2cst6NeC6sca1SdnQqhvqlvqpvinjHsbNmUSR3zYMGqgUK4QalwQaEPwfCY4YUENjBc((Jub2vHoQGwQGwQaNWl1QWTYDMY4NMnyfLEvOJkONky6ebUKejnPFR(2HbBkiKHljUkWUkWILkGxQvrst63QVDyWMIsVkWUk0rfWl1QOrTf01VvVS4oUNdiRnc((JGpZL3IGpCPXPjxqdMqM0XqgGpcz4sIdzg(CGljWzW30tsPpnagkhXp2di)pexfyKkOn8zU8we85KKfLGjKj9JdYa8ridxsCiZWNdCjbod(aggsfIxf(wCQqhvaVuRIg1wqx)w9YI74EoGS2ik9QqhvGt4LAv4w5otz8tZgSIsp8zU8we8Trjq)(tayczsF9HmaFMlVfbFTfKM0pj40LGpcz4sIdzgMqM0xBidWhHmCjXHmdFoWLe4m4lnjHsrLarxGFRECltjjiKHljUk0rf0sfWl1QOrTf01VvVS4oUNdiRnIsVkWILkGxQvbNmUSR3zYMO0RcSdFMlVfbF)ypG8)qCyczs)Vbza(mxElc(2OeOF)ja8ridxsCiZWeYK(moKb4JqgUK4qMHph4scCg8LMKqPOsGOlWVvpULPKeeYWLeh(mxElc((XEa5)H4WeYK(6aKb4JqgUK4qMHph4scCg8PNkKMKqPOsGOlWVvpULPKeeYWLeh(mxElc(gP1GjKj9)oKb4ZC5Ti4l65Yf01dkdw4JqgUK4qMHjKj9JuidWN5YBrW316je)qy8rpxUGUWhHmCjXHmdtycFCQAfzczaYK(qgGpZL3IGphwdGHGpcz4sIdzgMqM0gYa8zU8we81xAnscFeYWLehYmmHm9nidWN5YBrWx)M3IGpcz4sIdzgMqMyCidWhHmCjXHmdFoWLe4m4Jt4LAv4w5otz8tZgSIsp8zU8we8Hl3L7RfqxyczshGmaFeYWLehYm85axsGZGpoHxQvHBL7mLXpnBWkk9WN5YBrWhobgcO7HWatitFhYa8ridxsCiZWNdCjbod(4eEPwfUvUZug)0SbRGV)ivOJk42vY3FKOTG0K(jbNUKaqn7qJkWivqFHoOcDubGHHuH4vbDio4ZC5Ti4Zaodr(CbacLWeYuKcza(iKHljoKz4ZbUKaNbFCcVuRc3k3zkJFA2GvW3Fe8zU8we8jpmyZXRJkCmncLWeYKodza(iKHljoKz4ZbUKaNbFCcVuRc3k3zkJFA2Gvu6HpZL3IGV6biC5UCyczshdza(iKHljoKz4ZbUKaNbFCcVuRc3k3zkJFA2Gvu6HpZL3IGpd5OjbM07mPeMqM0poidWhHmCjXHmdFiRrWhWA9hcJ3A9YllCYJ5Wyrxz6jeMdrWN5YBrWhWA9hcJ3A9YllCYJ5Wyrxz6jeMdrWeYK(6dza(iKHljoKz4ZbUKaNbFUDL89hjCRCNPm(PzdwbGA2HgviEvqNvbwSubTuH0Kekf)gahqMUeqqidxsCvOJk42vY3FK43a4aY0Laca1SdnQq8QGoRcSdFMlVfbFwulnamHmPV2qgGpcz4sIdzg(CGljWzWNBxjF)rc3k3zkJFA2GvaOMDOrfIxf0zvGflvqlvinjHsXVbWbKPlbeeYWLexf6OcUDL89hj(naoGmDjGaqn7qJkeVkOZQa7WN5YBrWxzi)LuBGjKj9)gKb4JqgUK4qMHph4scCg8n9Ku6tdGHYr8J9aY)dXvbgPc6RcDubTub3Us((Je4sJttUGMaqn7qJkWivq)4ubwSub3Us((JeUvUZug)0SbRaqn7qJkWivqNvbwSubtNiWLKiPj9B13omytbHmCjXvb2HpZL3IGV5NO(dHXpj40LgyczsFghYa8ridxsCiZWNdCjbod(Wl1QiPj9B13omytrPxfyXsf0sf4eEPwfUvUZug)0SbRO0RcDub9ubtNiWLKiPj9B13omytbHmCjXvb2HpZL3IGpC5UC)w9jwYtiQ1fMqM0xhGmaFeYWLehYm85axsGZGp9uboHxQvHBL7mLXpnBWkk9QqhvqpvaVuRIKM0VvF7WGnfLE4ZC5Ti4RVaUA3dHXJlTjHjKj9)oKb4JqgUK4qMHph4scCg8PNkWj8sTkCRCNPm(PzdwrPxf6Oc6Pc4LAvK0K(T6BhgSPO0dFMlVfbFGRVxs(d5NEZrWeYK(rkKb4JqgUK4qMHph4scCg8PNkWj8sTkCRCNPm(PzdwrPxf6Oc6Pc4LAvK0K(T6BhgSPO0dFMlVfbF)lqYJshYdOzrgYrWeYK(6mKb4JqgUK4qMHph4scCg8PNkWj8sTkCRCNPm(PzdwrPxf6Oc6Pc4LAvK0K(T6BhgSPO0dFMlVfbF11vgI7nDIaxsECYAWeYK(6yidWhHmCjXHmdFoWLe4m4tpvGt4LAv4w5otz8tZgSIsVk0rf0tfWl1QiPj9B13omytrPxf6Oc8nfUf5iucSK4(Q0AKhVaqca1SdnQGgvio4ZC5Ti4ZTihHsGLe3xLwJGjKjTJdYa8ridxsCiZWNdCjbod(Wl1QaqoDL0m(6cCKO0dFMlVfbFjwYxq4BbX91f4iyczsB9HmaFeYWLehYm85axsGZGp3Us((JeUvUZug)0SbRaqn7qJkeVkOFCWN5YBrWhMIb4NH8B1B6eb2elmHmPT2qgGpcz4sIdzg(CGljWzWNBxjF)rc3k3zkJFA2GvaOMDOrfIxf(g8zU8we81O2c663QxwCh3ZbK1gyczs7Vbza(iKHljoKz4ZbUKaNbFa74EkkHsHX5JGI8n5aFMlVfbFGcYBU8wKxEtcFYBspYAe8H1CWeYK2moKb4JqgUK4qMHph4scCg8n9Ku6tdGHYr8J9aY)dXvbgPcmo8zU8we8bkiV5YBrE5nj8jVj9iRrWx9Is(0ayOeMqM0whGmaFeYWLehYm85axsGZGpTuH0KekfnBgZbibHmCjXvHoQqAamukWsMmXk6DPkeVk8nDqfyxfyXsfsdGHsbwYKjwrVlvH4vbTJd(mxElc(afK3C5TiV8Me(K3KEK1i4JIm5kjbtitA)DidWhHmCjXHmdFMlVfbFGcYBU8wKxEtcFYBspYAe8nhcJK8PbWqjmHj81di32WTeYaKj9HmaFMlVfbF4wMsYpy3scFeYWLehYmmHmPnKb4ZC5Ti4RFZBrWhHmCjXHmdtitFdYa8zU8we81O2c663QxwCh3ZbK1g4JqgUK4qMHjKjghYa8zU8we8HPya(zi)w9MorGnXcFeYWLehYmmHmPdqgGpZL3IGV66kdX9MorGljpozn4JqgUK4qMHjmHpkYKRKeKbit6dza(iKHljoKz4ZbUKaNbFaddPcXRcFpovOJkGxQvbNmUSR3zYMGV)ivOJkGxQvrJAlORFREzXDCphqwBe89hbFMlVfbFJUfPC6LxMeaMqM0gYa8ridxsCiZWNdCjbod(0tfWl1QGtgx217mztu6vHoQGwQGBxjF)rc3k3zkJFA2GvaOMDOrfIxf0wfyXsf0sfstsOu8BaCaz6sabHmCjXvHoQGBxjF)rIFdGditxciauZo0OcXRcARcSRcSdFMlVfbFalQHHaWeY03GmaFeYWLehYm85axsGZGp9ubAgc5irJAlORFREzXDCphqwBenthTavGflvqlvaVuRIg1wqx)w9YI74EoGS2ik9QalwQGBxjF)rIg1wqx)w9YI74EoGS2iauZo0Ocmsf0povGD4ZC5Ti4ZTYDMY4NMnyHjKjghYa8ridxsCiZWNdCjbod(0tfOziKJenQTGU(T6Lf3X9CazTr0mD0cubwSubTub8sTkAuBbD9B1llUJ75aYAJO0RcSyPcUDL89hjAuBbD9B1llUJ75aYAJaqn7qJkWivq)4ub2HpZL3IGVFdGditxcatit6aKb4ZC5Ti4Jtgx217mzd(iKHljoKzycz67qgGpcz4sIdzg(CGljWzWNEQaEPwfnQTGU(T6Lf3X9CazTru6vHoQaEPwfjnPFR(2HbBkk9QqhvayyiviEv4BXPcDub9ub8sTk4KXLD9ot2eLE4ZC5Ti4dxACAYf0GjKPifYa8ridxsCiZWNdCjbod(MEsk9PbWq5i(XEa5)H4QaJubTHpZL3IGpNKSOemHmPZqgGpcz4sIdzg(CGljWzWhEPwfoqzWEimEBgRitrPxf6Oc4LAv0O2c663QxwCh3ZbK1gbF)rWN5YBrW3iTgmHmPJHmaFeYWLehYm85axsGZGp8sTk2OeOF)jGysZPRkOrf0wf6OcPjjuk4aY4iRGbBkiKHljo8zU8we81wqAs)KGtxcMqM0poidWhHmCjXHmdFoWLe4m4dVuRIg1wqx)w9YI74EoGS2ik9QalwQaEPwfCY4YUENjBIsp8zU8we8rrMCLKGjKj91hYa8zU8we8Trjq)(ta4JqgUK4qMHjKj91gYa8zU8we8rrMCLKGpcz4sIdzgMWe(WAoidqM0hYa8ridxsCiZWNdCjbod(auZo0OcXRrf4fGL3IuHizvioX3uHoQGwQGEQaWoUNIsOuyC(ik9QalwQaEPwfZpr9hcJFsWPlnIsVkWo8zU8we8biehMqM0gYa8ridxsCiZWNdCjbod(aggsfIxf(ECQqhvqlvWTRKV)ibNmUSR3zYMaqn7qJkWiv4BQalwQGEQqAscLcozCzxVZKnbHmCjXvb2HpZL3IGVr3Iuo9YltcatitFdYa8ridxsCiZWNdCjbod(0sfC7k57psGlnon5cAca1SdnQaJuHVRcSyPcPjjukawuddbeeYWLexf6OcUDL89hjawuddbeaQzhAubgPcFxfyxf6OcAPcUDL89hjCRCNPm(PzdwbGA2HgviEvqBvGflvqlvinjHsXVbWbKPlbeeYWLexf6OcUDL89hj(naoGmDjGaqn7qJkeVkOTkWUkWo8zU8we8XjJl76DMSbtitmoKb4JqgUK4qMHph4scCg8PLkaSJ7POekfgNpIsVkWILkaSJ7POekfgNpIdPcmsfsdGHsrEnYNRNFKkWUk0rf0sfC7k57ps4w5otz8tZgSca1SdnQq8QG2QalwQGwQqAscLIFdGditxciiKHljUk0rfC7k57ps8BaCaz6sabGA2HgviEvqBvGDvGD4ZC5Ti4dyrnmeaMqM0bidWhHmCjXHmdFoWLe4m4dyh3trjukmoFeLEvGflvayh3trjukmoFehsfyKkW4XPcSyPcAPca74EkkHsHX5J4qQaJubTJtf6OcPjjukmegc4BgYWqncLccz4sIRcSdFMlVfbFUvUZug)0SblmHm9DidWhHmCjXHmdFoWLe4m4dyh3trjukmoFeLEvGflvayh3trjukmoFehsfyKkW4XPcSyPcAPca74EkkHsHX5J4qQaJubTJtf6OcPjjukmegc4BgYWqncLccz4sIRcSdFMlVfbF)gahqMUeaMqMIuidWhHmCjXHmdFoWLe4m4tlvGt4LAv4w5otz8tZgSIsVk0rfa2X9uucLcJZhXHubgPcPbWqPiVg5Z1ZpsfyxfyXsfa2X9uucLcJZhrPxf6OcAPcAPcCcVuRc3k3zkJFA2GvaOMDOrfyKkW4cDqf6Oc6PcMorGljrst63QVDyWMccz4sIRcSRcSyPc4LAvK0K(T6BhgSPO0RcSdFMlVfbF4sJttUGgmHmPZqgGpcz4sIdzg(CGljWzWNEQaWoUNIsOuyC(ik9QalwQGwQaWoUNIsOuyC(ik9QqhvW0jcCjjg6M258)wusqidxsCvGD4ZC5Ti4BJsG(9NaWeYKogYa8ridxsCiZWNdCjbod(MEsk9PbWq5i(XEa5)H4QaJubTHpZL3IGpNKSOemHmPFCqgGpcz4sIdzg(CGljWzWNEQaWoUNIsOuyC(ik9QalwQGwQGEQqAscLcNKSOKGqgUK4QqhvGVPGtuV)Fli(iauZo0OcXRcARcSRcSyPc4LAvmfoNqEozjwbGmxcFMlVfbFuKjxjjyczsF9HmaFeYWLehYm85axsGZGp9ubGDCpfLqPW48ru6vbwSubTub9uH0KekfojzrjbHmCjXvHoQaFtbNOE))wq8raOMDOrfIxf0wfyh(mxElc(AlinPFsWPlbtit6RnKb4JqgUK4qMHph4scCg8bSJ7POekfgNpIsp8zU8we89J9aY)dXHjKj9)gKb4ZC5Ti4BJsG(9NaWhHmCjXHmdtit6Z4qgGpcz4sIdzg(CGljWzWxAscLIkbIUa)w94wMssqidxsC4ZC5Ti47h7bK)hIdtit6RdqgGpcz4sIdzg(CGljWzWNEQqAscLIkbIUa)w94wMssqidxsCvOJkONkaSJ7POekfgNpIsp8zU8we8nsRbtit6)DidWN5YBrWx0ZLlORhugSWhHmCjXHmdtit6hPqgGpZL3IGVR1ti(HW4JEUCbDHpcz4sIdzgMWe(QxuYNgadLqgGmPpKb4JqgUK4qMHph4scCg8bmmKkeVk894uHoQGwQGEQqAscLcozCzxVZKnbHmCjXvbwSub8sTk4KXLD9ot2e89hPcSdFMlVfbFJUfPC6LxMeaMqM0gYa8ridxsCiZWNdCjbod(0sf0tfstsOu8BaCaz6sabHmCjXvbwSub3Us((Je)gahqMUeqaOMDOrfIxf0wfyh(mxElc(awuddbGjKPVbza(iKHljoKz4ZbUKaNbFCcVuRc3k3zkJFA2GvW3Fe8zU8we85w5otz8tZgSWeYeJdza(iKHljoKz4ZbUKaNbFCcVuRc3k3zkJFA2GvW3Fe8zU8we89BaCaz6sayczshGmaFeYWLehYm85axsGZGp8sTkMFI6peg)KGtxAe89hPcDubTub9uH0KekfCY4YUENjBccz4sIRcSyPc4LAvWjJl76DMSj47psfyxf6OcAPcAPcCcVuRc3k3zkJFA2GvaOMDOrfyKkW4cDqf6Oc6PcMorGljrst63QVDyWMccz4sIRcSRcSyPc4LAvK0K(T6BhgSPO0RcSdFMlVfbF4sJttUGgmHm9DidWN5YBrWhNmUSR3zYg8ridxsCiZWeYuKcza(mxElc(CsYIsWhHmCjXHmdtit6mKb4JqgUK4qMHph4scCg8PLkONkKMKqPWjjlkjiKHljUk0rf4Bk4e17)3cIpca1SdnQq8QG2Qa7QalwQGwQaEPwftHZjKNtwIvaiZLQalwQaEPwftUiYJLmqkaK5svGDvOJkOLkGxQvX8tu)HW4NeC6sJO0RcSyPcUDL89hjMFI6peg)KGtxAeaQzhAubgPc6SkWo8zU8we8rrMCLKGjKjDmKb4JqgUK4qMHph4scCg8PLkONkKMKqPWjjlkjiKHljUk0rf4Bk4e17)3cIpca1SdnQq8QG2Qa7QalwQaEPwfZpr9hcJFsWPlnIsVk0rfWl1QyJsG(9NaIjnNUQGgvqBvOJkKMKqPGdiJJScgSPGqgUK4WN5YBrWxBbPj9tcoDjyczs)4GmaFeYWLehYm85axsGZGpoHxQvHBL7mLXpnBWkk9QalwQGwQaEPwfoqzWEimEBgRitrPxf6OcPjjukQei6c8B1JBzkjbHmCjXvb2HpZL3IGVFShq(FiomHmPV(qgGpcz4sIdzg(CGljWzWhEPwfCY4YUENjBIsVkWILkammKkWiv47XbFMlVfbF)ypG8)qCyczsFTHmaFMlVfbFBuc0V)ea(iKHljoKzyczs)Vbza(mxElc((XEa5)H4WhHmCjXHmdtit6Z4qgGpZL3IGVONlxqxpOmyHpcz4sIdzgMqM0xhGmaFMlVfbFxRNq8dHXh9C5c6cFeYWLehYmmHjmHVOeyUfbzs740xN1xB9JtOT2FtF473aOdHzGVVwRFbjXvHVRcMlVfPcYBYrOIbF9GTEsc(ymv4RaTrfIezaWTavmgtfWMz)8f)8bZLyl4c32(mxRiT8wKdy18ZCn3hvmgtfIvKDvHincvq740xhRcFPkOT2FrTzCvmvmgtfIeG1qyO5lQIXyQWxQcFfNtCv4RxAnskuXymv4lvHVIZjUk8fEUCbDvHiPLb7NVwRNq8dHrf(cpxUGUcvmgtf(sv4R4CIRcmBzkjv4HDlPkKRk0di32WTuf(QVEKqHkgJPcFPk8fezYvYBreis8OcFDa5U5wKkCJkWjjLexOIXyQWxQcFfNtCvisYqQWxlP2iuXuXymv4liYKRKexfWP6civWTnClvbCcZHgHk8voh1NJkGw0xI1aTArQcMlVfnQWIKDfQymMkyU8w0i6bKBB4wQPkTrxvmgtfmxElAe9aYTnClztZN6UCvmgtfmxElAe9aYTnClztZhRGPrO0YBrQymMk8qw)GDtvayhxfWl1kXvHjTCubCQUasfCBd3svaNWCOrfmexf6b0x2VzEimQWnQaFrKqfZC5TOr0di32WTKnnFWTmLKFWULufZC5TOr0di32WTKnnF638wKkM5YBrJOhqUTHBjBA(0O2c663QxwCh3ZbK1gvmZL3IgrpGCBd3s208btXa8Zq(T6nDIaBIvfZC5TOr0di32WTKnnFQRRme3B6ebUK84K1uXuXymv4liYKRKexfOOeORkKxJuHelPcMlxGkCJkyrTtA4ssOIzU8w0OXH1ayivmZL3Ig208PV0AKufZC5TOHnnF638wKkM5YBrdBA(Gl3L7Rfq3iUQgoHxQvHBL7mLXpnBWkk9QyMlVfnSP5dobgcO7HWeXv1Wj8sTkCRCNPm(PzdwrPxfZC5TOHnnFmGZqKpxaGqzexvdNWl1QWTYDMY4NMnyf89h1XTRKV)irBbPj9tcoDjbGA2HggPVqh6ammu86qCQyMlVfnSP5J8WGnhVoQWX0iugXv1Wj8sTkCRCNPm(PzdwbF)rQyMlVfnSP5t9aeUCxEexvdNWl1QWTYDMY4NMnyfLEvmZL3Ig208XqoAsGj9otkJ4QA4eEPwfUvUZug)0SbRO0RIzU8w0WMMpLH8xsTiqwJ0aSw)HW4TwV8YcN8yomw0vMEcH5qKkM5YBrdBA(yrT0arCvnUDL89hjCRCNPm(PzdwbGA2HM41zwS0knjHsXVbWbKPlbeeYWLeVJBxjF)rIFdGditxciauZo0eVoZUkM5YBrdBA(ugYFj1MiUQg3Us((JeUvUZug)0SbRaqn7qt86mlwALMKqP43a4aY0Laccz4sI3XTRKV)iXVbWbKPlbeaQzhAIxNzxfZC5TOHnnFMFI6peg)KGtxAI4QAMEsk9PbWq5i(XEa5)H4ms)oA52vY3FKaxACAYf0eaQzhAyK(XXILBxjF)rc3k3zkJFA2GvaOMDOHr6mlwMorGljrst63QVDyWMccz4sIZUkM5YBrdBA(Gl3L73QpXsEcrTUrCvn4LAvK0K(T6BhgSPO0ZILwCcVuRc3k3zkJFA2Gvu67ONPte4ssK0K(T6BhgSPGqgUK4SRIzU8w0WMMp9fWv7EimECPnzexvJECcVuRc3k3zkJFA2Gvu67OhEPwfjnPFR(2HbBkk9QyMlVfnSP5d467LK)q(P3CuexvJECcVuRc3k3zkJFA2Gvu67OhEPwfjnPFR(2HbBkk9QyMlVfnSP5Z)cK8O0H8aAwKHCuexvJECcVuRc3k3zkJFA2Gvu67OhEPwfjnPFR(2HbBkk9QyMlVfnSP5tDDLH4EtNiWLKhNSwexvJECcVuRc3k3zkJFA2Gvu67OhEPwfjnPFR(2HbBkk9QyMlVfnSP5JBrocLaljUVkTgfXv1OhNWl1QWTYDMY4NMnyfL(o6HxQvrst63QVDyWMIsFh(Mc3ICekbwsCFvAnYJxaibGA2HgnXPIzU8w0WMMpjwYxq4BbX91f4OiUQg8sTkaKtxjnJVUahjk9QyMlVfnSP5dMIb4NH8B1B6eb2eBexvJBxjF)rc3k3zkJFA2GvaOMDOjE9JtfZC5TOHnnFAuBbD9B1llUJ75aYAtexvJBxjF)rc3k3zkJFA2GvaOMDOj(VPIzU8w0WMMpGcYBU8wKxEtgbYAKgSMlIRQbyh3trjukmoFeuKVjhvmZL3Ig208buqEZL3I8YBYiqwJ0uVOKpnagkJ4QAMEsk9PbWq5i(XEa5)H4mIXvXmxElAytZhqb5nxElYlVjJaznsdfzYvskIRQrR0KekfnBgZbibHmCjX7KgadLcSKjtSIExg)30b2zXknagkfyjtMyf9UmETJtfZC5TOHnnFafK3C5TiV8MmcK1inZHWijFAamuQIPIzU8w0iOitUssAgDls50lVmjqexvdWWqX)946GxQvbNmUSR3zYMGV)Oo4LAv0O2c663QxwCh3ZbK1gbF)rQyMlVfnckYKRKeBA(aSOggceXv1OhEPwfCY4YUENjBIsFhTC7k57ps4w5otz8tZgSca1SdnXRnlwALMKqP43a4aY0Laccz4sI3XTRKV)iXVbWbKPlbeaQzhAIxB2zxfZC5TOrqrMCLKytZh3k3zkJFA2GnIRQrpAgc5irJAlORFREzXDCphqwBenthTawS0cVuRIg1wqx)w9YI74EoGS2ik9Sy52vY3FKOrTf01VvVS4oUNdiRnca1Sdnms)4yxfZC5TOrqrMCLKytZNFdGditxceXv1OhndHCKOrTf01VvVS4oUNdiRnIMPJwalwAHxQvrJAlORFREzXDCphqwBeLEwSC7k57ps0O2c663QxwCh3ZbK1gbGA2HggPFCSRIzU8w0iOitUssSP5dNmUSR3zYMkM5YBrJGIm5kjXMMp4sJttUGwexvJE4LAv0O2c663QxwCh3ZbK1grPVdEPwfjnPFR(2HbBkk9Daggk(Vfxh9Wl1QGtgx217mztu6vXmxElAeuKjxjj208XjjlkfXv1m9Ku6tdGHYr8J9aY)dXzK2QyMlVfnckYKRKeBA(msRfXv1GxQvHdugShcJ3MXkYuu67GxQvrJAlORFREzXDCphqwBe89hPIzU8w0iOitUssSP5tBbPj9tcoDPiUQg8sTk2OeOF)jGysZPRgT7KMKqPGdiJJScgSPGqgUK4QyMlVfnckYKRKeBA(qrMCLKI4QAWl1QOrTf01VvVS4oUNdiRnIsplw4LAvWjJl76DMSjk9QyMlVfnckYKRKeBA(Srjq)(tavmZL3IgbfzYvsInnFOitUssQyQyMlVfnI6fL8PbWqPMr3Iuo9YltceXv1ammu8FpUoAPxAscLcozCzxVZKnbHmCjXzXcVuRcozCzxVZKnbF)rSRIzU8w0iQxuYNgadLSP5dWIAyiqexvJw6LMKqP43a4aY0Laccz4sIZILBxjF)rIFdGditxciauZo0eV2SRIzU8w0iQxuYNgadLSP5JBL7mLXpnBWgXv1Wj8sTkCRCNPm(PzdwbF)rQyMlVfnI6fL8PbWqjBA(8BaCaz6sGiUQgoHxQvHBL7mLXpnBWk47psfZC5TOruVOKpnagkztZhCPXPjxqlIRQbVuRI5NO(dHXpj40LgbF)rD0sV0KekfCY4YUENjBccz4sIZIfEPwfCY4YUENjBc((JyVJwAXj8sTkCRCNPm(PzdwbGA2HggX4cDOJEMorGljrst63QVDyWMccz4sIZolw4LAvK0K(T6BhgSPO0ZUkM5YBrJOErjFAamuYMMpCY4YUENjBQyMlVfnI6fL8PbWqjBA(4KKfLuXmxElAe1lk5tdGHs208HIm5kjfXv1OLEPjjukCsYIsccz4sI3HVPGtuV)Fli(iauZo0eV2SZILw4LAvmfoNqEozjwbGmxYIfEPwftUiYJLmqkaK5s27OfEPwfZpr9hcJFsWPlnIsplwUDL89hjMFI6peg)KGtxAeaQzhAyKoZUkM5YBrJOErjFAamuYMMpTfKM0pj40LI4QA0sV0KekfojzrjbHmCjX7W3uWjQ3)VfeFeaQzhAIxB2zXcVuRI5NO(dHXpj40LgrPVdEPwfBuc0V)eqmP50vJ2DstsOuWbKXrwbd2uqidxsCvmZL3Igr9Is(0ayOKnnF(XEa5)H4rCvnCcVuRc3k3zkJFA2Gvu6zXsl8sTkCGYG9qy82mwrMIsFN0KekfvceDb(T6XTmLKGqgUK4SRIzU8w0iQxuYNgadLSP5Zp2di)pepIRQbVuRcozCzxVZKnrPNflGHHy03JtfZC5TOruVOKpnagkztZNnkb63FcOIzU8w0iQxuYNgadLSP5Zp2di)pexfZC5TOruVOKpnagkztZNONlxqxpOmyvXmxElAe1lk5tdGHs2085A9eIFim(ONlxqxvmvmZL3IgbwZPbqiEexvdGA2HM41WlalVffjhN4BD0spGDCpfLqPW48ru6zXcVuRI5NO(dHXpj40LgrPNDvmZL3IgbwZXMMpJUfPC6LxMeiIRQbyyO4)ECD0YTRKV)ibNmUSR3zYMaqn7qdJ(glw6LMKqPGtgx217mztqidxsC2vXmxElAeynhBA(WjJl76DMSfXv1OLBxjF)rcCPXPjxqtaOMDOHrFNfR0KekfalQHHaccz4sI3XTRKV)ibWIAyiGaqn7qdJ(o7D0YTRKV)iHBL7mLXpnBWkauZo0eV2SyPvAscLIFdGditxciiKHljEh3Us((Je)gahqMUeqaOMDOjETzNDvmZL3IgbwZXMMpalQHHarCvnAbSJ7POekfgNpIsplwa74EkkHsHX5J4qmknagkf51iFUE(rS3rl3Us((JeUvUZug)0SbRaqn7qt8AZILwPjjuk(naoGmDjGGqgUK4DC7k57ps8BaCaz6sabGA2HM41MD2vXmxElAeynhBA(4w5otz8tZgSrCvna74EkkHsHX5JO0ZIfWoUNIsOuyC(ioeJy84yXslGDCpfLqPW48rCigPDCDstsOuyimeW3mKHHAekfeYWLeNDvmZL3IgbwZXMMp)gahqMUeiIRQbyh3trjukmoFeLEwSa2X9uucLcJZhXHyeJhhlwAbSJ7POekfgNpIdXiTJRtAscLcdHHa(MHmmuJqPGqgUK4SRIzU8w0iWAo208bxACAYf0I4QA0It4LAv4w5otz8tZgSIsFhGDCpfLqPW48rCigLgadLI8AKpxp)i2zXcyh3trjukmoFeL(oAPfNWl1QWTYDMY4NMnyfaQzhAyeJl0Ho6z6ebUKejnPFR(2HbBkiKHljo7SyHxQvrst63QVDyWMIsp7QyMlVfncSMJnnF2OeOF)jqexvJEa74EkkHsHX5JO0ZILwa74EkkHsHX5JO03X0jcCjjg6M258)wusqidxsC2vXmxElAeynhBA(4KKfLI4QAMEsk9PbWq5i(XEa5)H4msBvmZL3IgbwZXMMpuKjxjPiUQg9a2X9uucLcJZhrPNflT0lnjHsHtswusqidxs8o8nfCI69)BbXhbGA2HM41MDwSWl1QykCoH8CYsScazUufZC5TOrG1CSP5tBbPj9tcoDPiUQg9a2X9uucLcJZhrPNflT0lnjHsHtswusqidxs8o8nfCI69)BbXhbGA2HM41MDvmZL3IgbwZXMMp)ypG8)q8iUQgGDCpfLqPW48ru6vXmxElAeynhBA(Srjq)(tavmZL3IgbwZXMMp)ypG8)q8iUQM0KekfvceDb(T6XTmLKGqgUK4QyMlVfncSMJnnFgP1I4QA0lnjHsrLarxGFRECltjjiKHljEh9a2X9uucLcJZhrPxfZC5TOrG1CSP5t0ZLlORhugSQyMlVfncSMJnnFUwpH4hcJp65Yf0vftfZC5TOrmhcJK8PbWqPgaH4rCvnaQzhAIxdVaS8wuKCCIV1Ht4LAv4w5otz8tZgSc((JuXmxElAeZHWijFAamuYMMpJUfPC6LxMeiIRQbyyO4)ECDWl1QGtgx217mztW3Fuh8sTkAuBbD9B1llUJ75aYAJGV)ivmZL3IgXCimsYNgadLSP5dWIAyiqexvJE4LAvWjJl76DMSjk9D0YTRKV)iHBL7mLXpnBWkauZo0eV2SyPvAscLIFdGditxciiKHljEh3Us((Je)gahqMUeqaOMDOjETzNDvmZL3IgXCimsYNgadLSP5JBL7mLXpnBWgXv1OhndHCKOrTf01VvVS4oUNdiRnIMPJwalwAHxQvrJAlORFREzXDCphqwBeLEwSC7k57ps0O2c663QxwCh3ZbK1gbGA2HggPFCSRIzU8w0iMdHrs(0ayOKnnF(naoGmDjqexvJE0meYrIg1wqx)w9YI74EoGS2iAMoAbSyPfEPwfnQTGU(T6Lf3X9CazTru6zXYTRKV)irJAlORFREzXDCphqwBeaQzhAyK(XXUkM5YBrJyoegj5tdGHs208Htgx217mztfZC5TOrmhcJK8PbWqjBA(qrMCLKI4QAWl1QykCoH8CYsScazUufZC5TOrmhcJK8PbWqjBA(Glnon5cArCvnUDL89hjAlinPFsWPljauZo00rl9stsOuWjJl76DMSjiKHljolw4LAvWjJl76DMSj47pI9oAPfNWl1QWTYDMY4NMnyfL(o6z6ebUKejnPFR(2HbBkiKHljo7SyHxQvrst63QVDyWMIsp7DWl1QOrTf01VvVS4oUNdiRnc((JuXmxElAeZHWijFAamuYMMpojzrPiUQMPNKsFAamuoIFShq(FioJ0wfZC5TOrmhcJK8PbWqjBA(Srjq)(tGiUQgGHHI)BX1bVuRIg1wqx)w9YI74EoGS2ik9D4eEPwfUvUZug)0SbRO0RIzU8w0iMdHrs(0ayOKnnFAlinPFsWPlPIzU8w0iMdHrs(0ayOKnnF(XEa5)H4rCvnPjjukQei6c8B1JBzkjbHmCjX7OfEPwfnQTGU(T6Lf3X9CazTru6zXcVuRcozCzxVZKnrPNDvmZL3IgXCimsYNgadLSP5ZgLa97pbuXmxElAeZHWijFAamuYMMp)ypG8)q8iUQM0KekfvceDb(T6XTmLKGqgUK4QyMlVfnI5qyKKpnagkztZNrATiUQg9stsOuujq0f43Qh3Yusccz4sIRIzU8w0iMdHrs(0ayOKnnFIEUCbD9GYGvfZC5TOrmhcJK8PbWqjBA(CTEcXpegF0ZLlOl8n9KdYuKQpmHjec]] )


end
