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


    spec:RegisterPack( "Arms", 20190816, [[dyeSnbqisLEePaBsO8jHuiJcLYPqPAvsLe9ksrZIuv3sQKAxO6xQKgMqvhJuLLjK8mHunnsHCnPszBsLQVrkOghPqDoui16KkjnpHk3JuAFOqDqHuAHOKEOqkWffsrDsuiXkLkMPqkODIsmuuiPLkKI0tvXurbxvifXwLkj8vHuO2lK)svdwWHPSyO6XuzYeUmYML0NHIrdLoTQwnPG8AsfZMKBlLDd63knCPQLd8Cftx01Ly7cX3vPgVujoVkX6rHy(OO9t0i9qmGocljelrfVEm641y96oxVUf9UPrOtEPNqNEZPJHHqhO1i0jAbTbD6TlQ1eigqNzlahHoyZSF6QxVI5tSfCUBBxNVvuw(l0bSAED(M7k6GxEvYOar4OJWscXsuXRhJoEnwVUZ1RBrVBrxJrhRKyxa6C(wrz5VWObaRMOd2xiiichDe04qhnqgIwqBKHOXga8lq2rdKbSz2pD1RxX8j2co3TTRZ3kkl)f6awnVoFZDv2rdKHOTGPmPmOx31xgIkE9y0Yqxld61TUAuXl7i7ObYq0aSgednDvzhnqg6AziAfcsidmQLwJuCzhnqg6AziAfcsidDfVlxWfziAAzWELrP1tqXdXidDfVlxWfUSJgidDTmeTcbjKbwTmvKmCWULugYvg6bKBB4wkdrlJA0qUSJgidDTmen3fYvYFHeiA0idmQaY9ZVqz4hzqqkkjbx2rdKHUwgIwHGeYq0KHKbgLKAdhDu)KdIb0zEigf5tdGHsediw0dXa6qqdxrceROJd8jbEdDauZE4idXPvgefGL)cLHUsziEE0LHyYGGWl1k3TQDMY4NMny5I9gIoMl)fIoackqjILOqmGoe0WvKaXk64aFsG3qhGHHKH4KHUhVmetgWl1kxqMqDX7mvJl2BOmetgWl1kVrTfCXVvVQ4EHxaiRnCXEdrhZL)crNrNIsn9QptcGselrhXa6qqdxrceROJd8jbEdD0vgWl1kxqMqDX7mvJx6LHyYaBYGBxLyVHC3Q2zkJFA2GLdOM9WrgItgIsgyYugytgstrWKFBaCaz6qaobnCfjKHyYGBxLyVH8BdGdithcWbuZE4idXjdrjdSldSJoMl)fIoalIHHaOeXIgHyaDiOHRibIv0Xb(KaVHo6kd0me0r8g1wWf)w9QI7fEbGS2WBMgAbYatMYaBYaEPw5nQTGl(T6vf3l8cazTHx6LbMmLb3UkXEd5nQTGl(T6vf3l8cazTHdOM9WrgySmOx8Ya7OJ5YFHOJBv7mLXpnBWIselDdXa6qqdxrceROJd8jbEdD0vgOziOJ4nQTGl(T6vf3l8cazTH3mn0cKbMmLb2Kb8sTYBuBbx8B1RkUx4faYAdV0ldmzkdUDvI9gYBuBbx8B1RkUx4faYAdhqn7HJmWyzqV4Lb2rhZL)crNBdGdithcGselDhXa6yU8xi6iitOU4DMQHoe0WvKaXkkrSOHrmGoe0WvKaXk64aFsG3qh8sTYNIqqqVGSelhqMlrhZL)crhQlKRKekrSOXigqhcA4ksGyfDCGpjWBOJBxLyVH82cst5Ne86qCa1ShoYqmzGnzqxzinfbtUGmH6I3zQgNGgUIeYatMYaEPw5cYeQlENPACXEdLb2LHyYaBYaBYGGWl1k3TQDMY4NMny5LEziMmORmymcb(K4jnPFR(2JbBYjOHRiHmWUmWKPmGxQvEst63QV9yWM8sVmWUmetgWl1kVrTfCXVvVQ4EHxaiRnCXEdrhZL)crhCLjOjxqdLiwy0igqhcA4ksGyfDCGpjWBOZ0tkLpnagkh(n2hOUFOqgySmef6yU8xi64uKfHqjIf9IhXa6qqdxrceROJd8jbEdDaggsgItgIE8YqmzaVuR8g1wWf)w9QI7fEbGS2Wl9Yqmzqq4LAL7w1otz8tZgS8sp6yU8xi6Sriq)EtauIyrp9qmGoMl)fIoTfKMYpj41HqhcA4ksGyfLiw0lkedOdbnCfjqSIooWNe4n0jnfbtELarwGFRECltfXjOHRiHmetgytgWl1kVrTfCXVvVQ4EHxaiRn8sVmWKPmGxQvUGmH6I3zQgV0ldSJoMl)fIo3yFG6(HcuIyrVOJyaDmx(leD2ieOFVja6qqdxrceROeXIEAeIb0HGgUIeiwrhh4tc8g6KMIGjVsGilWVvpULPI4e0WvKaDmx(leDUX(a19dfOeXIEDdXa6qqdxrceROJd8jbEdD0vgstrWKxjqKf43Qh3YurCcA4ksGoMl)fIoJYAOeXIEDhXa6yU8xi6e5D5cU4bLbl6qqdxrceROeXIEAyedOJ5YFHOZ36jO4Hy8rExUGlOdbnCfjqSIsuIocQAfvIyaXIEigqhZL)crhhwdGHqhcA4ksGyfLiwIcXa6yU8xi60xAnsHoe0WvKaXkkrSeDedOJ5YFHOt)M)crhcA4ksGyfLiw0iedOdbnCfjqSIooWNe4n0rq4LAL7w1otz8tZgS8sp6yU8xi6GR2v4RfWfuIyPBigqhcA4ksGyfDCGpjWBOJGWl1k3TQDMY4NMny5LE0XC5Vq0bNadb05HyqjILUJyaDiOHRibIv0Xb(KaVHoccVuRC3Q2zkJFA2GLl2BOmetgC7Qe7nK3wqAk)KGxhIdOM9WrgySmOhVBYqmzayyiziozOBXJoMl)fIogWzqYNlaqWeLiw0WigqhcA4ksGyfDCGpjWBOJGWl1k3TQDMY4NMny5I9gIoMl)fIoQhd2C8AOIatJGjkrSOXigqhcA4ksGyfDCGpjWBOJGWl1k3TQDMY4NMny5LE0XC5Vq0P(acxTRaLiwy0igqhcA4ksGyfDCGpjWBOJGWl1k3TQDMY4NMny5LE0XC5Vq0XGoAsGP8otPqjIf9IhXa6qqdxrceROd0Ae6aSw)dX4TwV6ZIG8yEmwKvLEcI5He6yU8xi6aSw)dX4TwV6ZIG8yEmwKvLEcI5HekrSONEigqhcA4ksGyfDmx(leDSbBedsJhymYc8Ufyk0Xb(KaVHo6kdccVuRCGXilW7wGP8ccVuR8sVmWKPmWMmKgadL88BKpxFVl9rpEziozOBYqmzqq4LAL7wOO4Ypc5FOoEbHxQvEPxgyxgyYugytg0vgeeEPw5UfkkU8Jq(hQJxq4LALx6LHyYaEPw5nQTGl(T6vf3l8cazTHx6LbMmLb2KHEafXJXj46XDRANPm(PzdwziMmORmqZqqhXBuBbx8B1RkUx4faYAdVzAOfidSldSJoqRrOJnyJyqA8aJrwG3TatHsel6ffIb0HGgUIeiwrhh4tc8g642vj2Bi3TQDMY4NMny5aQzpCKH4KbnwgyYugytgstrWKFBaCaz6qaobnCfjKHyYGBxLyVH8BdGdithcWbuZE4idXjdASmWo6yU8xi6yrS0aOeXIErhXa6qqdxrceROJd8jbEdDC7Qe7nK7w1otz8tZgSCa1ShoYqCYGgldmzkdSjdPPiyYVnaoGmDiaNGgUIeYqmzWTRsS3q(TbWbKPdb4aQzpCKH4KbnwgyhDmx(leDkd5)KAdkrSONgHyaDiOHRibIv0Xb(KaVHotpPu(0ayOC43yFG6(HczGXYGEYqmzGnzWTRsS3qoUYe0KlOXbuZE4idmwg0lEzGjtzWTRsS3qUBv7mLXpnBWYbuZE4idmwg0yzGjtzWyec8jXtAs)w9Thd2KtqdxrczGD0XC5Vq0zUjQ)Hy8tcEDObLiw0RBigqhcA4ksGyfDCGpjWBOdEPw5jnPFR(2JbBYl9YatMYaBYGGWl1k3TQDMY4NMny5LEziMmORmymcb(K4jnPFR(2JbBYjOHRiHmWo6yU8xi6GR2v43QpXsEcsTlOeXIEDhXa6qqdxrceROJd8jbEdD0vgeeEPw5UvTZug)0SblV0ldXKbDLb8sTYtAs)w9Thd2Kx6rhZL)crN(c4RxEigpUYMeLiw0tdJyaDiOHRibIv0Xb(KaVHo6kdccVuRC3Q2zkJFA2GLx6LHyYGUYaEPw5jnPFR(2JbBYl9OJ5YFHOd477vK)H(P3CekrSONgJyaDiOHRibIv0Xb(KaVHo6kdccVuRC3Q2zkJFA2GLx6LHyYGUYaEPw5jnPFR(2JbBYl9OJ5YFHOZ9cuIi0d9aAwObDekrSOhJgXa6qqdxrceROJd8jbEdD0vgeeEPw5UvTZug)0SblV0ldXKbDLb8sTYtAs)w9Thd2Kx6rhZL)crN66kdj8gJqGpjpoznuIyjQ4rmGoe0WvKaXk64aFsG3qhDLbbHxQvUBv7mLXpnBWYl9YqmzqxzaVuR8KM0VvF7XGn5LEziMmi2K7wOJGjWss4RkRrE8caYbuZE4idALH4rhZL)crh3cDembwscFvzncLiwIspedOdbnCfjqSIooWNe4n0bVuRCa50rrZ4RlWr8sp6yU8xi6KyjFbIVfOWxxGJqjILOIcXa6qqdxrceROJd8jbEdDC7Qe7nK7w1otz8tZgSCa1ShoYqCYGEXJoMl)fIoykgq8g0VvVXieytSOeXsurhXa6qqdxrceROJd8jbEdD0vgstrWKFBaCaz6qaobnCfjKHyYGBxLyVHC3Q2zkJFA2GLdOM9WrgItgIUmWKPm42vj2Bi)2a4aY0HaCa1ShoYqCYq0rhZL)crNg1wWf)w9QI7fEbGS2GselrPrigqhcA4ksGyfDCGpjWBOdWEHNIqWKBcXWPU8toOJ5YFHOdOa9Ml)f6v)KOJ6N0dTgHoynhkrSev3qmGoe0WvKaXk64aFsG3qNPNukFAamuo8BSpqD)qHmWyzqJqhZL)crhqb6nx(l0R(jrh1pPhAncDQFeYNgadLOeXsuDhXa6qqdxrceROJd8jbEdDytgstrWK3SzmhG4e0WvKqgIjdPbWqjhlzQelV3LYqCYq07MmWUmWKPmKgadLCSKPsS8ExkdXjdrfp6yU8xi6akqV5YFHE1pj6O(j9qRrOd1fYvscLiwIsdJyaDiOHRibIv0XC5Vq0buGEZL)c9QFs0r9t6HwJqN5HyuKpnagkrjkrNEa52gULigqSOhIb0XC5Vq0b3Yur(b7ws0HGgUIeiwrjILOqmGoe0WvKaXk6aTgHogJmynGn(6ct)w997nbqhZL)crhJrgSgWgFDHPFR((9MaOeXs0rmGoMl)fIonQTGl(T6vf3l8cazTbDiOHRibIvuIyrJqmGoMl)fIoykgq8g0VvVXieytSOdbnCfjqSIselDdXa6yU8xi60V5Vq0HGgUIeiwrjkrhQlKRKeIbel6HyaDiOHRibIv0Xb(KaVHoaddjdXjdDpEziMmGxQvUGmH6I3zQgxS3qziMmGxQvEJAl4IFREvX9cVaqwB4I9gIoMl)fIoJofLA6vFMeaLiwIcXa6qqdxrceROJd8jbEdD0vgWl1kxqMqDX7mvJx6LHyYaBYGBxLyVHC3Q2zkJFA2GLdOM9WrgItgIsgyYugytgstrWKFBaCaz6qaobnCfjKHyYGBxLyVH8BdGdithcWbuZE4idXjdrjdSldSJoMl)fIoalIHHaOeXs0rmGoe0WvKaXk64aFsG3qhDLbAgc6iEJAl4IFREvX9cVaqwB4ntdTazGjtzGnzaVuR8g1wWf)w9QI7fEbGS2Wl9YatMYGBxLyVH8g1wWf)w9QI7fEbGS2WbuZE4idmwg0lEzGD0XC5Vq0XTQDMY4NMnyrjIfncXa6qqdxrceROJd8jbEdD0vgOziOJ4nQTGl(T6vf3l8cazTH3mn0cKbMmLb2Kb8sTYBuBbx8B1RkUx4faYAdV0ldmzkdUDvI9gYBuBbx8B1RkUx4faYAdhqn7HJmWyzqV4Lb2rhZL)crNBdGdithcGselDdXa6yU8xi6iitOU4DMQHoe0WvKaXkkrS0DedOdbnCfjqSIooWNe4n0rxzaVuR8g1wWf)w9QI7fEbGS2Wl9YqmzaVuR8KM0VvF7XGn5LEziMmammKmeNme94LHyYGUYaEPw5cYeQlENPA8sp6yU8xi6GRmbn5cAOeXIggXa6qqdxrceROJd8jbEdDMEsP8PbWq5WVX(a19dfYaJLHOqhZL)crhNISiekrSOXigqhcA4ksGyfDCGpjWBOdEPw5oqzW(qmEBgROsEPxgIjd4LAL3O2cU43QxvCVWlaK1gUyVHOJ5YFHOZOSgkrSWOrmGoe0WvKaXk64aFsG3qh8sTY3ieOFVjaFsZPJmOvgIsgIjdPPiyYfaYeqRGbBYjOHRib6yU8xi60wqAk)KGxhcLiw0lEedOdbnCfjqSIooWNe4n0bVuR8g1wWf)w9QI7fEbGS2Wl9YatMYaEPw5cYeQlENPA8sp6yU8xi6qDHCLKqjIf90dXa6yU8xi6Sriq)Eta0HGgUIeiwrjIf9IcXa6yU8xi6qDHCLKqhcA4ksGyfLOeDWAoediw0dXa6qqdxrceROJd8jbEdDauZE4idXPvgefGL)cLHUsziEE0LHyYaBYGUYaWEHNIqWKBcXWl9YatMYaEPw5Znr9peJFsWRdn8sVmWo6yU8xi6aiOaLiwIcXa6qqdxrceROJd8jbEdDaggsgItg6E8YqmzGnzWTRsS3qUGmH6I3zQghqn7HJmWyzi6YatMYGUYqAkcMCbzc1fVZunobnCfjKb2rhZL)crNrNIsn9QptcGselrhXa6qqdxrceROJd8jbEdDytgC7Qe7nKJRmbn5cACa1ShoYaJLHUldmzkdPPiyYbweddb4e0WvKqgIjdUDvI9gYbweddb4aQzpCKbgldDxgyxgIjdSjdUDvI9gYDRANPm(PzdwoGA2dhziozikzGjtzGnzinfbt(TbWbKPdb4e0WvKqgIjdUDvI9gYVnaoGmDiahqn7HJmeNmeLmWUmWo6yU8xi6iitOU4DMQHselAeIb0HGgUIeiwrhh4tc8g6WMmaSx4Piem5Mqm8sVmWKPmaSx4Piem5Mqm8hkdmwgsdGHsE(nYNRx8KmWUmetgytgC7Qe7nK7w1otz8tZgSCa1ShoYqCYquYatMYaBYqAkcM8BdGdithcWjOHRiHmetgC7Qe7nKFBaCaz6qaoGA2dhziozikzGDzGD0XC5Vq0byrmmeaLiw6gIb0HGgUIeiwrhh4tc8g6aSx4Piem5Mqm8sVmWKPmaSx4Piem5Mqm8hkdmwg0O4LbMmLb2KbG9cpfHGj3eIH)qzGXYquXldXKH0uem5gedb8ndAyOgbtobnCfjKb2rhZL)crh3Q2zkJFA2GfLiw6oIb0HGgUIeiwrhh4tc8g6aSx4Piem5Mqm8sVmWKPmaSx4Piem5Mqm8hkdmwg0O4LbMmLb2KbG9cpfHGj3eIH)qzGXYquXldXKH0uem5gedb8ndAyOgbtobnCfjKb2rhZL)crNBdGdithcGselAyedOdbnCfjqSIooWNe4n0Hnzqq4LAL7w1otz8tZgS8sVmetga2l8uecMCtig(dLbgldPbWqjp)g5Z1lEsgyxgyYuga2l8uecMCtigEPxgIjdSjdSjdccVuRC3Q2zkJFA2GLdOM9WrgySmOr8UjdXKbDLbJriWNepPj9B13EmytobnCfjKb2LbMmLb8sTYtAs)w9Thd2Kx6Lb2rhZL)crhCLjOjxqdLiw0yedOdbnCfjqSIooWNe4n0rxzayVWtriyYnHy4LEzGjtzGnzayVWtriyYnHy4LEziMmymcb(K4d9t7D(BlcXjOHRiHmWo6yU8xi6Sriq)EtauIyHrJyaDiOHRibIv0Xb(KaVHotpPu(0ayOC43yFG6(HczGXYquOJ5YFHOJtrwecLiw0lEedOdbnCfjqSIooWNe4n0rxzayVWtriyYnHy4LEzGjtzGnzqxzinfbtUtrweItqdxrcziMmi2KliQ3FVfOy4aQzpCKH4KHOKb2LbMmLb8sTYNIqqqVGSelhqMlrhZL)crhQlKRKekrSONEigqhcA4ksGyfDCGpjWBOJUYaWEHNIqWKBcXWl9YatMYaBYGUYqAkcMCNISieNGgUIeYqmzqSjxquV)ElqXWbuZE4idXjdrjdSJoMl)fIoTfKMYpj41HqjIf9IcXa6qqdxrceROJd8jbEdDa2l8uecMCtigEPhDmx(leDUX(a19dfOeXIErhXa6yU8xi6Sriq)Eta0HGgUIeiwrjIf90iedOdbnCfjqSIooWNe4n0jnfbtELarwGFRECltfXjOHRib6yU8xi6CJ9bQ7hkqjIf96gIb0HGgUIeiwrhh4tc8g6ORmKMIGjVsGilWVvpULPI4e0WvKqgIjd6kda7fEkcbtUjedV0JoMl)fIoJYAOeXIEDhXa6yU8xi6e5D5cU4bLbl6qqdxrceROeXIEAyedOJ5YFHOZ36jO4Hy8rExUGlOdbnCfjqSIsuIo1pc5tdGHsediw0dXa6qqdxrceROJd8jbEdDaggsgItg6E8YqmzGnzqxzinfbtUGmH6I3zQgNGgUIeYatMYaEPw5cYeQlENPACXEdLb2rhZL)crNrNIsn9QptcGselrHyaDiOHRibIv0Xb(KaVHoSjd6kdPPiyYVnaoGmDiaNGgUIeYatMYGBxLyVH8BdGdithcWbuZE4idXjdrjdSJoMl)fIoalIHHaOeXs0rmGoe0WvKaXk64aFsG3qhbHxQvUBv7mLXpnBWYf7neDmx(leDCRANPm(PzdwuIyrJqmGoe0WvKaXk64aFsG3qhbHxQvUBv7mLXpnBWYf7neDmx(leDUnaoGmDiakrS0nedOdbnCfjqSIooWNe4n0bVuR85MO(hIXpj41HgUyVHYqmzGnzqxzinfbtUGmH6I3zQgNGgUIeYatMYaEPw5cYeQlENPACXEdLb2LHyYaBYaBYGGWl1k3TQDMY4NMny5aQzpCKbgldAeVBYqmzqxzWyec8jXtAs)w9Thd2KtqdxrczGDzGjtzaVuR8KM0VvF7XGn5LEzGD0XC5Vq0bxzcAYf0qjILUJyaDmx(leDeKjux8ot1qhcA4ksGyfLiw0WigqhZL)crhNISie6qqdxrceROeXIgJyaDiOHRibIv0Xb(KaVHoSjd6kdPPiyYDkYIqCcA4ksidXKbXMCbr9(7Tafdhqn7HJmeNmeLmWUmWKPmWMmGxQv(uecc6fKLy5aYCPmWKPmGxQv(KlK8yjdKCazUugyxgIjdSjd4LALp3e1)qm(jbVo0Wl9YatMYGBxLyVH85MO(hIXpj41HgoGA2dhzGXYGgldSJoMl)fIouxixjjuIyHrJyaDiOHRibIv0Xb(KaVHoSjd6kdPPiyYDkYIqCcA4ksidXKbXMCbr9(7Tafdhqn7HJmeNmeLmWUmWKPmGxQv(Ctu)dX4Ne86qdV0ldXKb8sTY3ieOFVjaFsZPJmOvgIsgIjdPPiyYfaYeqRGbBYjOHRib6yU8xi60wqAk)KGxhcLiw0lEedOdbnCfjqSIooWNe4n0rq4LAL7w1otz8tZgS8sVmWKPmWMmGxQvUdugSpeJ3MXkQKx6LHyYqAkcM8kbISa)w94wMkItqdxrczGD0XC5Vq05g7du3puGsel6PhIb0HGgUIeiwrhh4tc8g6GxQvUGmH6I3zQgV0ldmzkdaddjdmwg6E8OJ5YFHOZn2hOUFOaLiw0lkedOJ5YFHOZgHa97nbqhcA4ksGyfLiw0l6igqhZL)crNBSpqD)qb6qqdxrceROeXIEAeIb0XC5Vq0jY7YfCXdkdw0HGgUIeiwrjIf96gIb0XC5Vq05B9eu8qm(iVlxWf0HGgUIeiwrjkrj6eHaZVqelrfVEm641WrXOrNBdaFiMbDyuA9lijHm0DzWC5Vqzq9toCzh0z6jhIfnSEOtpyRVIqhnqgIwqBKHOXga8lq2rdKbSz2pD1RxX8j2co3TTRZ3kkl)f6awnVoFZDv2rdKHOTGPmPmOx31xgIkE9y0Yqxld61TUAuXl7i7ObYq0aSgednDvzhnqg6AziAfcsidmQLwJuCzhnqg6AziAfcsidDfVlxWfziAAzWELrP1tqXdXidDfVlxWfUSJgidDTmeTcbjKbwTmvKmCWULugYvg6bKBB4wkdrlJA0qUSJgidDTmen3fYvYFHeiA0idmQaY9ZVqz4hzqqkkjbx2rdKHUwgIwHGeYq0KHKbgLKAdx2r2rdKHO5UqUssczaNQlGKb32WTugWjmpC4Yq06CuFoYaCHDnwd0QfLmyU8x4idluDHl7ObYG5YFHdVhqUTHBP2QYgDKD0azWC5VWH3di32WTutTxR7kKD0azWC5VWH3di32WTutTxTcMgbtl)fk7ObYWbA9d2nLbG9czaVuRKqgM0YrgWP6cizWTnClLbCcZdhzWGczOhqDD)M5dXid)idIfsCzhZL)chEpGCBd3sn1Ef3Yur(b7wszhZL)chEpGCBd3sn1ETmK)tQPp0AKwJrgSgWgFDHPFR((9MaYoMl)fo8Ea52gULAQ9AJAl4IFREvX9cVaqwBKDmx(lC49aYTnCl1u7vmfdiEd63Q3yecSjwzhZL)chEpGCBd3sn1ETFZFHYoYoAGmen3fYvssiduecCrgYVrYqILKbZLlqg(rgSi2RmCfXLDmx(lC06WAamKSJ5YFHJMAV2xAnsj7yU8x4OP2R9B(lu2XC5VWrtTxXv7k81c4I(FvRGWl1k3TQDMY4NMny5LEzhZL)chn1EfNadb05Hy0)RAfeEPw5UvTZug)0SblV0l7yU8x4OP2RgWzqYNlaqWu)VQvq4LAL7w1otz8tZgSCXEdJ52vj2BiVTG0u(jbVoehqn7HdJ1J3Tyaddfx3Ix2XC5VWrtTxvpgS541qfbMgbt9)QwbHxQvUBv7mLXpnBWYf7nu2XC5VWrtTxRpGWv7k0)RAfeEPw5UvTZug)0SblV0l7yU8x4OP2Rg0rtcmL3zkL(FvRGWl1k3TQDMY4NMny5LEzhZL)chn1ETmK)tQPp0AKwG16FigV16vFweKhZJXISQ0tqmpKKDmx(lC0u71Yq(pPM(qRrATbBedsJhymYc8Ufyk9)QwDfeEPw5aJrwG3Tat5feEPw5LEMmzlnagk553iFU(Ex6JE8X1TyccVuRC3cffx(ri)d1Xli8sTYl9SZKjB6ki8sTYDluuC5hH8puhVGWl1kV0hdVuR8g1wWf)w9QI7fEbGS2Wl9mzYwpGI4X4eC94UvTZug)0SbBmDPziOJ4nQTGl(T6vf3l8cazTH3mn0cyNDzhZL)chn1E1IyPb0)RAD7Qe7nK7w1otz8tZgSCa1ShoXPXmzYwAkcM8BdGdithcWjOHRirm3UkXEd53gahqMoeGdOM9WjonMDzhZL)chn1ETmK)tQn6)vTUDvI9gYDRANPm(PzdwoGA2dN40yMmzlnfbt(TbWbKPdb4e0WvKiMBxLyVH8BdGdithcWbuZE4eNgZUSJ5YFHJMAVo3e1)qm(jbVo0O)x1o9Ks5tdGHYHFJ9bQ7hkySEXyZTRsS3qoUYe0KlOXbuZE4Wy9INjt3UkXEd5UvTZug)0Sblhqn7HdJ1yMmngHaFs8KM0VvF7XGn5e0WvKGDzhZL)chn1EfxTRWVvFIL8eKAx0)RAXl1kpPj9B13EmytEPNjt2eeEPw5UvTZug)0SblV0htxJriWNepPj9B13EmytobnCfjyx2XC5VWrtTx7lGVE5Hy84kBs9)QwDfeEPw5UvTZug)0SblV0htx8sTYtAs)w9Thd2Kx6LDmx(lC0u7vW33Ri)d9tV5i9)QwDfeEPw5UvTZug)0SblV0htx8sTYtAs)w9Thd2Kx6LDmx(lC0u717fOerOh6b0Sqd6i9)QwDfeEPw5UvTZug)0SblV0htx8sTYtAs)w9Thd2Kx6LDmx(lC0u7166kdj8gJqGpjpozn9)QwDfeEPw5UvTZug)0SblV0htx8sTYtAs)w9Thd2Kx6LDmx(lC0u7v3cDembwscFvzns)VQvxbHxQvUBv7mLXpnBWYl9X0fVuR8KM0VvF7XGn5L(yIn5Uf6iycSKe(QYAKhVaGCa1ShoAJx2XC5VWrtTxtSKVaX3cu4RlWr6)vT4LALdiNokAgFDboIx6LDmx(lC0u7vmfdiEd63Q3yecSjw9)Qw3UkXEd5UvTZug)0Sblhqn7HtC6fVSJ5YFHJMAV2O2cU43QxvCVWlaK1g9)QwDttrWKFBaCaz6qaobnCfjI52vj2Bi3TQDMY4NMny5aQzpCIl6mz62vj2Bi)2a4aY0HaCa1ShoXfDzhZL)chn1EfuGEZL)c9QFs9HwJ0I1C6)vTa7fEkcbtUjedN6Yp5i7yU8x4OP2RGc0BU8xOx9tQp0AK26hH8PbWqP(Fv70tkLpnagkh(n2hOUFOGXAKSJ5YFHJMAVckqV5YFHE1pP(qRrAPUqUss6)vTSLMIGjVzZyoaXjOHRirS0ayOKJLmvIL37Y4IE3yNjZ0ayOKJLmvIL37Y4IkEzhZL)chn1EfuGEZL)c9QFs9HwJ0opeJI8PbWqPSJSJ5YFHdN6c5kjPD0POutV6ZKa6)vTaddfx3JpgEPw5cYeQlENPACXEdJHxQvEJAl4IFREvX9cVaqwB4I9gk7yU8x4WPUqUssAQ9kWIyyiG(FvRU4LALlitOU4DMQXl9XyZTRsS3qUBv7mLXpnBWYbuZE4exumzYwAkcM8BdGdithcWjOHRirm3UkXEd53gahqMoeGdOM9WjUOyNDzhZL)cho1fYvsstTxDRANPm(Pzdw9)QwDPziOJ4nQTGl(T6vf3l8cazTH3mn0cyYKn8sTYBuBbx8B1RkUx4faYAdV0ZKPBxLyVH8g1wWf)w9QI7fEbGS2WbuZE4Wy9INDzhZL)cho1fYvsstTxVnaoGmDiG(FvRU0me0r8g1wWf)w9QI7fEbGS2WBMgAbmzYgEPw5nQTGl(T6vf3l8cazTHx6zY0TRsS3qEJAl4IFREvX9cVaqwB4aQzpCySEXZUSJ5YFHdN6c5kjPP2RcYeQlENPAYoMl)foCQlKRKKMAVIRmbn5cA6)vT6IxQvEJAl4IFREvX9cVaqwB4L(y4LALN0K(T6BpgSjV0hdyyO4IE8X0fVuRCbzc1fVZunEPx2XC5VWHtDHCLK0u7vNISiK(Fv70tkLpnagkh(n2hOUFOGXrj7yU8x4WPUqUssAQ96OSM(FvlEPw5oqzW(qmEBgROsEPpgEPw5nQTGl(T6vf3l8cazTHl2BOSJ5YFHdN6c5kjPP2RTfKMYpj41H0)RAXl1kFJqG(9Ma8jnNoAJkwAkcMCbGmb0kyWMCcA4ksi7yU8x4WPUqUssAQ9k1fYvss)VQfVuR8g1wWf)w9QI7fEbGS2Wl9mzIxQvUGmH6I3zQgV0l7yU8x4WPUqUssAQ96gHa97nbKDmx(lC4uxixjjn1EL6c5kjj7i7yU8x4WRFeYNgadLAhDkk10R(mjG(FvlWWqX194JXMUPPiyYfKjux8ot14e0WvKGjt8sTYfKjux8ot14I9gYUSJ5YFHdV(riFAamuQP2RalIHHa6)vTSPBAkcM8BdGdithcWjOHRibtMUDvI9gYVnaoGmDiahqn7HtCrXUSJ5YFHdV(riFAamuQP2RUvTZug)0SbR(FvRGWl1k3TQDMY4NMny5I9gk7yU8x4WRFeYNgadLAQ96TbWbKPdb0)RAfeEPw5UvTZug)0SblxS3qzhZL)chE9Jq(0ayOutTxXvMGMCbn9)Qw8sTYNBI6Fig)KGxhA4I9ggJnDttrWKlitOU4DMQXjOHRibtM4LALlitOU4DMQXf7nK9ySXMGWl1k3TQDMY4NMny5aQzpCySgX7wmDngHaFs8KM0VvF7XGn5e0WvKGDMmXl1kpPj9B13EmytEPNDzhZL)chE9Jq(0ayOutTxfKjux8ot1KDmx(lC41pc5tdGHsn1E1Pilcj7yU8x4WRFeYNgadLAQ9k1fYvss)VQLnDttrWK7uKfH4e0WvKiMytUGOE)9wGIHdOM9WjUOyNjt2Wl1kFkcbb9cYsSCazUKjt8sTYNCHKhlzGKdiZLShJn8sTYNBI6Fig)KGxhA4LEMmD7Qe7nKp3e1)qm(jbVo0WbuZE4WynMDzhZL)chE9Jq(0ayOutTxBlinLFsWRdP)x1YMUPPiyYDkYIqCcA4ksetSjxquV)ElqXWbuZE4exuSZKjEPw5Znr9peJFsWRdn8sFm8sTY3ieOFVjaFsZPJ2OILMIGjxaitaTcgSjNGgUIeYoMl)fo86hH8PbWqPMAVEJ9bQ7hk0)RAfeEPw5UvTZug)0SblV0ZKjB4LAL7aLb7dX4TzSIk5L(yPPiyYReiYc8B1JBzQiobnCfjyx2XC5VWHx)iKpnagk1u71BSpqD)qH(FvlEPw5cYeQlENPA8sptMaddX4UhVSJ5YFHdV(riFAamuQP2RBec0V3eq2XC5VWHx)iKpnagk1u71BSpqD)qHSJ5YFHdV(riFAamuQP2RrExUGlEqzWk7yU8x4WRFeYNgadLAQ9636jO4Hy8rExUGlYoYoMl)foCSMtlGGc9)Qwa1ShoXPvuaw(lSRmEE0JXMUa7fEkcbtUjedV0ZKjEPw5Znr9peJFsWRdn8sp7YoMl)foCSMttTxhDkk10R(mjG(FvlWWqX194JXMBxLyVHCbzc1fVZunoGA2dhghDMm1nnfbtUGmH6I3zQgNGgUIeSl7yU8x4WXAon1EvqMqDX7mvt)VQLn3UkXEd54ktqtUGghqn7HdJ7otMPPiyYbweddb4e0WvKiMBxLyVHCGfXWqaoGA2dhg3D2JXMBxLyVHC3Q2zkJFA2GLdOM9WjUOyYKT0uem53gahqMoeGtqdxrIyUDvI9gYVnaoGmDiahqn7HtCrXo7YoMl)foCSMttTxbweddb0)RAzdyVWtriyYnHy4LEMmb2l8uecMCtig(dzCAamuYZVr(C9INypgBUDvI9gYDRANPm(PzdwoGA2dN4IIjt2strWKFBaCaz6qaobnCfjI52vj2Bi)2a4aY0HaCa1ShoXff7Sl7yU8x4WXAon1E1TQDMY4NMny1)RAb2l8uecMCtigEPNjtG9cpfHGj3eIH)qgRrXZKjBa7fEkcbtUjed)HmoQ4JLMIGj3GyiGVzqdd1iyYjOHRib7YoMl)foCSMttTxVnaoGmDiG(FvlWEHNIqWKBcXWl9mzcSx4Piem5Mqm8hYynkEMmzdyVWtriyYnHy4pKXrfFS0uem5gedb8ndAyOgbtobnCfjyx2XC5VWHJ1CAQ9kUYe0KlOP)x1YMGWl1k3TQDMY4NMny5L(ya7fEkcbtUjed)Hmonagk553iFUEXtSZKjWEHNIqWKBcXWl9XyJnbHxQvUBv7mLXpnBWYbuZE4WynI3Ty6Amcb(K4jnPFR(2JbBYjOHRib7mzIxQvEst63QV9yWM8sp7YoMl)foCSMttTx3ieOFVjG(FvRUa7fEkcbtUjedV0ZKjBa7fEkcbtUjedV0hZyec8jXh6N2783weItqdxrc2LDmx(lC4ynNMAV6uKfH0)RANEsP8PbWq5WVX(a19dfmokzhZL)chowZPP2Ruxixjj9)QwDb2l8uecMCtigEPNjt20nnfbtUtrweItqdxrIyIn5cI693BbkgoGA2dN4IIDMmXl1kFkcbb9cYsSCazUu2XC5VWHJ1CAQ9ABbPP8tcEDi9)QwDb2l8uecMCtigEPNjt20nnfbtUtrweItqdxrIyIn5cI693BbkgoGA2dN4IIDzhZL)chowZPP2R3yFG6(Hc9)QwG9cpfHGj3eIHx6LDmx(lC4ynNMAVUriq)EtazhZL)chowZPP2R3yFG6(Hc9)Q20uem5vcezb(T6XTmveNGgUIeYoMl)foCSMttTxhL10)RA1nnfbtELarwGFRECltfXjOHRirmDb2l8uecMCtigEPx2XC5VWHJ1CAQ9AK3Ll4IhugSYoMl)foCSMttTx)wpbfpeJpY7YfCr2r2XC5VWHppeJI8PbWqPwabf6)vTaQzpCItROaS8xyxz88Ohtq4LAL7w1otz8tZgSCXEdLDmx(lC4ZdXOiFAamuQP2RJofLA6vFMeq)VQfyyO46E8XWl1kxqMqDX7mvJl2Bym8sTYBuBbx8B1RkUx4faYAdxS3qzhZL)ch(8qmkYNgadLAQ9kWIyyiG(FvRU4LALlitOU4DMQXl9XyZTRsS3qUBv7mLXpnBWYbuZE4exumzYwAkcM8BdGdithcWjOHRirm3UkXEd53gahqMoeGdOM9WjUOyNDzhZL)ch(8qmkYNgadLAQ9QBv7mLXpnBWQ)x1QlndbDeVrTfCXVvVQ4EHxaiRn8MPHwatMSHxQvEJAl4IFREvX9cVaqwB4LEMmD7Qe7nK3O2cU43QxvCVWlaK1goGA2dhgRx8Sl7yU8x4WNhIrr(0ayOutTxVnaoGmDiG(FvRU0me0r8g1wWf)w9QI7fEbGS2WBMgAbmzYgEPw5nQTGl(T6vf3l8cazTHx6zY0TRsS3qEJAl4IFREvX9cVaqwB4aQzpCySEXZUSJ5YFHdFEigf5tdGHsn1EvqMqDX7mvt2XC5VWHppeJI8PbWqPMAVsDHCLK0)RAXl1kFkcbb9cYsSCazUu2XC5VWHppeJI8PbWqPMAVIRmbn5cA6)vTUDvI9gYBlinLFsWRdXbuZE4eJnDttrWKlitOU4DMQXjOHRibtM4LALlitOU4DMQXf7nK9ySXMGWl1k3TQDMY4NMny5L(y6Amcb(K4jnPFR(2JbBYjOHRib7mzIxQvEst63QV9yWM8sp7XWl1kVrTfCXVvVQ4EHxaiRnCXEdLDmx(lC4ZdXOiFAamuQP2Rofzri9)Q2PNukFAamuo8BSpqD)qbJJs2XC5VWHppeJI8PbWqPMAVUriq)Eta9)QwGHHIl6XhdVuR8g1wWf)w9QI7fEbGS2Wl9XeeEPw5UvTZug)0SblV0l7yU8x4WNhIrr(0ayOutTxBlinLFsWRdj7yU8x4WNhIrr(0ayOutTxVX(a19df6)vTPPiyYReiYc8B1JBzQiobnCfjIXgEPw5nQTGl(T6vf3l8cazTHx6zYeVuRCbzc1fVZunEPNDzhZL)ch(8qmkYNgadLAQ96gHa97nbKDmx(lC4ZdXOiFAamuQP2R3yFG6(Hc9)Q20uem5vcezb(T6XTmveNGgUIeYoMl)fo85HyuKpnagk1u71rzn9)QwDttrWKxjqKf43Qh3YurCcA4ksi7yU8x4WNhIrr(0ayOutTxJ8UCbx8GYGv2XC5VWHppeJI8PbWqPMAV(TEckEigFK3Ll4ckrjcba]] )


end
