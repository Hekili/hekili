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
            cooldown = 90,
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
            cooldown = 60,
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


    spec:RegisterPack( "Arms", 20181210.2231, [[dCKX)aqirrpsvLAtsIpHsvfJcbDkeLvjIc9kevZse5wIa2fQ(Li1WeL6yIqlJuXZer10qPIRHsL2MOeFdLQY4uvjNtusSouQsMNOW9qj7tvfhueOfIapeLQGjIsvkxuefCsrjPvksMjkvvANQQAOIsQLkIIEQetvs6QOuLQTIsvvFfLQO9Q4VQYGPQdtzXG8yQmzcxgAZO4ZsQrRQCALwnkvHEnkLzt0TjLDRYVrA4i0YbEUutx46GA7KQ(UOA8IGopPsRxeLMpISFsEsCQofHf48xNSt8xjQtIzZ1rNKRJojFkHUeXPq0CSz14uotdNscc06Pq00vsnXuDknfg4WP8fbXM9kD66n(GH4oQw6E1GLwS0ZbmMiDVAU0qskuAiglbeO(0ebuMvID6SgGjtBfD6Soz(ypnayPGxcc0AEVAUPabVYiREd0uewGZFDYoXFLOojMnxhDsUo6K4um44JcMsz1GLwS0J9aWyIP8TcbEd0uey7MYVv(eeO1kp7PbalfOs9BL)lcIn7v601B8bdXDuT09QblTyPNdymr6E1CPHKuO0qmwciq9PjcOmRe70znatM2k60zDY8XEAaWsbVeeO18E1CQu)w5zVHoudcbkFIzNKYRt2j(lLpbuED0j5zRsPs9BLN9WND1yZEPs9BLpbu(euiqHYN1WAAOKRs9BLpbu(euiqHYZ(VUGc0v5tMW9x6SQgr8e7vR8S)RlOaD5Qu)w5taLpbfcuO8eyrirLV8rHdLpOkpra6OAqwO8jywZ(LRs9BLpbu(KHeIo4yPhcy)0kFwdq32l9u(TvEbkXafCvQFR8jGYNGcbkuE27nQ8z1a1A(uKBh9uDk9E1s8fgOgJP68pXP6uWZGKOyiykoWgiyTPaqnBVw5ZGLYlGbwS0t5tgv(S5jx5RO8cecMHH7OsA3W9R1S(JlO53umxS0Bka8etm)1zQof8mijkgcMIdSbcwBkaRgv(mu(SKTYxr5ju5Zu5dtIxWfOjK6(CMuJJNbjrHYtIKYdbZWWfOjK6(CMuJlO5NYt2umxS0BknBWsztuUrGGjM)jFQof8mijkgcMIdSbcwBkzQ8qWmmCbAcPUpNj14Wev(kkpHkVJsLcA(XDujTB4(1Aw)XbOMTxR8zO86O8KiP8eQ8HjXl45gacGgBiGJNbjrHYxr5DuQuqZpEUbGaOXgc4auZ2Rv(muEDuEYuEYMI5ILEtby6TAemX8NDMQtbpdsIIHGP4aBGG1MIaHGzy4oQK2nC)AnR)4cA(nfZfl9MIJkPDd3VwZ6VjM)S7uDk4zqsumemfhydeS2ueiemdd3rL0UH7xRz9hxqZVPyUyP3uYnaean2qWeZ)SmvNI5ILEtrGMqQ7ZzsTPGNbjrXqWeZF23uDk4zqsumemfhydeS2uGGzy4nSqG3tGw8XbO5IPyUyP3uWeIo4aNy()RP6uWZGKOyiykoWgiyTP4OuPGMFCnkim5RdWYgYbOMTxR8vuEcv(mv(WK4fCbAcPUpNj144zqsuO8KiP8qWmmCbAcPUpNj14cA(P8KP8vuEcvEcvEbcbZWWDujTB4(1Aw)XHjQ8vu(mvElzrWgipWoEuMN2w)fC8mijkuEYuEsKuEiyggEGD8OmpTT(l4WevEYMI5ILEtbsAcSdkqBI5FwzQof8mijkgcMIdSbcwBknrukFHbQXO55FlqMVNq5)r51zkMlw6nfNen94eZ)eZEQof8mijkgcMIdSbcwBkwYIGnqEJBRTUxUPh5a7yt5zP8jFkMlw6nfQEeqKMJGjM)jM4uDkMlw6nfnkim5RdWYgof8mijkgcMy(NOot1PGNbjrXqWuCGnqWAtjmjEbNbb6PGhL5bzriroEgKefkFfLNqLhcMHHlqti195mPghMOYtIKYdSAu5)HLYNLSvEYMI5ILEtj)BbY89etm)tm5t1PyUyP3uO6rarAocMcEgKefdbtm)tKDMQtbpdsIIHGP4aBGG1Msys8codc0tbpkZdYIqIC8mijku(kkpHkFMkVLSiydKhyhpkZtBR)coEgKefkpjskVaHGzy4oQK2nC)AnR)4WevEYMI5ILEtj)BbY89etm)tKDNQtbpdsIIHGP4aBGG1MsMkFys8codc0tbpkZdYIqIC8mijku(kkpHkFMkVLSiydKhyhpkZtBR)coEgKefkpjskVaHGzy4oQK2nC)AnR)4WevEsKuEiyggUanHu3NZKACyIkpjskpWQrL)hwkFwYw5jBkMlw6nLwAAtm)tmlt1PyUyP3u0VUGc09bG7VPGNbjrXqWeZ)ezFt1PyUyP3uwnI4j2R(PFDbfO7uWZGKOyiyIjMIazmyzmvN)jovNI5ILEtX9zGACk4zqsumemX8xNP6umxS0BkeH10q5uWZGKOyiyI5FYNQtXCXsVPqKgl9McEgKefdbtm)zNP6uWZGKOyiykoWgiyTPiqiyggUJkPDd3VwZ6pomXPyUyP3uGKuQ4Xad0DI5p7ovNcEgKefdbtXb2abRnfbcbZWWDujTB4(1Aw)XHjofZfl9McecAeW2E1tm)ZYuDk4zqsumemfhydeS2ueiemdd3rL0UH7xRz9hxqZpLVIY7OuPGMFCnkim5RdWYgYbOMTxR8)O8jYzxLVIYdSAu5Zq5z3SNI5ILEtXao7Wxqba8IjM)SVP6uWZGKOyiykoWgiyTPiqiyggUJkPDd3VwZ6pUGMFtXCXsVPi36VOFShHf1A4ftm))1uDk4zqsumemfhydeS2ueiemdd3rL0UH7xRz9hhM4umxS0BkmlaHKuQyI5FwzQof8mijkgcMIdSbcwBkcecMHH7OsA3W9R1S(JdtCkMlw6nf7Cyhat(CMuoX8pXSNQtbpdsIIHGP4aBGG1MIJsLcA(XDujTB4(1Aw)XbOMTxR8zO8)s5jrs5ju5dtIxWZnaean2qahpdsIcLVIY7OuPGMF8CdabqJneWbOMTxR8zO8)s5jBkMlw6nftVfgyI5FIjovNcEgKefdbtXb2abRnfhLkf08J7OsA3W9R1S(JdqnBVw5Zq5)LYtIKYtOYhMeVGNBaiaASHaoEgKefkFfL3rPsbn)45gacGgBiGdqnBVw5Zq5)LYt2umxS0BkWn(2a16jM)jQZuDk4zqsumemfhydeS2uAIOu(cduJrZZ)wGmFpHY)JYNOYxr5ju5DuQuqZpoK0eyhuGghGA2ETY)JYNy2kpjskVJsLcA(XDujTB4(1Aw)XbOMTxR8)O8)s5jrs5TKfbBG8a74rzEAB9xWXZGKOq5jBkMlw6nLohrI7v)6aSSH9eZ)et(uDk4zqsumemfhydeS2ua2kEOE8cUjenht42rpfZfl9Mca(EMlw69KBhtrUD8otdNYN5My(Ni7mvNcEgKefdbtXb2abRnLMikLVWa1y088VfiZ3tO8)O8SZumxS0Bka47zUyP3tUDmf52X7mnCkmRE8fgOgJjM)jYUt1PGNbjrXqWuCGnqWAtHqLpmjEbxZ62CaKJNbjrHYxr5dduJb)dnz8Xj6cLpdLp5SRYtMYtIKYhgOgd(hAY4Jt0fkFgkVozpfZfl9Mca(EMlw69KBhtrUD8otdNcMq0bh4eZ)eZYuDk4zqsumemfZfl9Mca(EMlw69KBhtrUD8otdNsVxTeFHbQXyIjMcra6OAqwmvN)jovNcEgKefdbtm)1zQof8mijkgcMy(N8P6uWZGKOyiyI5p7mvNI5ILEtbYIqIV(JchtbpdsIIHGjM)S7uDkMlw6nfI0yP3uWZGKOyiyIjMcMq0bh4uD(N4uDk4zqsumemfhydeS2uawnQ8zO8zjBLVIYtOYNPYhMeVGlqti195mPghpdsIcLNejLhcMHHlqti195mPgxqZpLNSPyUyP3uA2GLYMOCJabtm)1zQof8mijkgcMIdSbcwBkzQ8qWmmCbAcPUpNj14Wev(kkpHkVJsLcA(XDujTB4(1Aw)XbOMTxR8zO86O8KiP8eQ8HjXl45gacGgBiGJNbjrHYxr5DuQuqZpEUbGaOXgc4auZ2Rv(muEDuEYuEYMI5ILEtby6TAemX8p5t1PGNbjrXqWuCGnqWAtrGqWmmChvs7gUFTM1FCbn)MI5ILEtXrL0UH7xRz93eZF2zQof8mijkgcMIdSbcwBkcecMHH7OsA3W9R1S(JlO53umxS0Bk5gacGgBiyI5p7ovNI5ILEtrGMqQ7ZzsTPGNbjrXqWeZ)SmvNcEgKefdbtXb2abRnfGvJkFgkFYZw5RO8zQ8qWmmCbAcPUpNj14WeNI5ILEtbsAcSdkqBI5p7BQof8mijkgcMIdSbcwBknrukFHbQXO55FlqMVNq5)r51zkMlw6nfNen94eZ)FnvNcEgKefdbtXb2abRnfiyggUda3F7v)SUnyzWHjofZfl9MslnTjM)zLP6uWZGKOyiykoWgiyTPabZWWP6rarAoc4Dyo2uEwkVokFfLpmjEbxaqtCgC9xWXZGKOykMlw6nfnkim5RdWYgoX8pXSNQtbpdsIIHGP4aBGG1McemddxGMqQ7ZzsnomXPyUyP3uWeIo4aNy(NyIt1PyUyP3uO6rarAocMcEgKefdbtm)tuNP6umxS0BkycrhCGtbpdsIIHGjM)jM8P6umxS0Bk6xxqb6(aW93uWZGKOyiyI5FISZuDkMlw6nLvJiEI9QF6xxqb6of8mijkgcMyIP8zUP68pXP6uWZGKOyiykoWgiyTPaqnBVw5ZGLYlGbwS0t5tgv(S5jx5RO8eQ8zQ8aBfpupEb3eIMdtu5jrs5HGzy4DoIe3R(1byzdBomrLNSPyUyP3ua4jMy(RZuDk4zqsumemfhydeS2uawnQ8zO8zjBLVIYtOY7OuPGMFCbAcPUpNj14auZ2Rv(Fu(KR8KiP8zQ8HjXl4c0esDFotQXXZGKOq5jBkMlw6nLMnyPSjk3iqWeZ)KpvNcEgKefdbtXb2abRnfcvEhLkf08Jdjnb2bfOXbOMTxR8)O8zr5jrs5dtIxWbMERgbC8mijku(kkVJsLcA(XbMERgbCaQz71k)pkFwuEYu(kkpHkVJsLcA(XDujTB4(1Aw)XbOMTxR8zO86O8KiP8eQ8HjXl45gacGgBiGJNbjrHYxr5DuQuqZpEUbGaOXgc4auZ2Rv(muEDuEYuEYMI5ILEtrGMqQ7ZzsTjM)SZuDk4zqsumemfhydeS2uiu5b2kEOE8cUjenhMOYtIKYdSv8q94fCtiA(Ek)pkFyGAm4XQHVG(elQ8KP8vuEcvEhLkf08J7OsA3W9R1S(JdqnBVw5Zq51r5jrs5ju5dtIxWZnaean2qahpdsIcLVIY7OuPGMF8CdabqJneWbOMTxR8zO86O8KP8KnfZfl9McW0B1iyI5p7ovNcEgKefdbtXb2abRnfGTIhQhVGBcrZHjQ8KiP8aBfpupEb3eIMVNY)JYZozR8KiP8eQ8aBfpupEb3eIMVNY)JYRt2kFfLpmjEb3UAe80SZQrn8coEgKefkpztXCXsVP4OsA3W9R1S(BI5FwMQtbpdsIIHGP4aBGG1McWwXd1JxWnHO5WevEsKuEGTIhQhVGBcrZ3t5)r5zNSvEsKuEcvEGTIhQhVGBcrZ3t5)r51jBLVIYhMeVGBxncEA2z1OgEbhpdsIcLNSPyUyP3uYnaean2qWeZF23uDk4zqsumemfhydeS2uiu5fiemdd3rL0UH7xRz9hhMOYxr5b2kEOE8cUjenFpL)hLpmqng8y1WxqFIfvEYuEsKuEGTIhQhVGBcrZHjQ8vuEcvEcvEbcbZWWDujTB4(1Aw)XbOMTxR8)O8SdNDv(kkFMkVLSiydKhyhpkZtBR)coEgKefkpzkpjskpemddpWoEuMN2w)fCyIkpztXCXsVPajnb2bfOnX8)xt1PGNbjrXqWuCGnqWAtjtLhyR4H6Xl4Mq0CyIkpjskpHkpWwXd1JxWnHO5Wev(kkVLSiydK342AR7LB6roEgKefkpztXCXsVPq1JaI0CemX8pRmvNcEgKefdbtXb2abRnLMikLVWa1y088VfiZ3tO8)O86mfZfl9MItIMECI5FIzpvNcEgKefdbtXb2abRnLmvEGTIhQhVGBcrZHjQ8KiP8eQ8zQ8HjXl4ojA6roEgKefkFfLxqdUarIVCk8jAoa1S9ALpdLxhLNmLNejLhcMHH3WcbEpbAXhhGMlMI5ILEtbti6GdCI5FIjovNcEgKefdbtXb2abRnLmvEGTIhQhVGBcrZHjQ8KiP8eQ8zQ8HjXl4ojA6roEgKefkFfLxqdUarIVCk8jAoa1S9ALpdLxhLNSPyUyP3u0OGWKVoalB4eZ)e1zQof8mijkgcMIdSbcwBkaBfpupEb3eIMdtCkMlw6nL8VfiZ3tmX8pXKpvNI5ILEtHQhbeP5iyk4zqsumemX8pr2zQof8mijkgcMIdSbcwBkHjXl4miqpf8OmpilcjYXZGKOykMlw6nL8VfiZ3tmX8pr2DQof8mijkgcMIdSbcwBkzQ8HjXl4miqpf8OmpilcjYXZGKOq5RO8zQ8aBfpupEb3eIMdtCkMlw6nLwAAtm)tmlt1PyUyP3u0VUGc09bG7VPGNbjrXqWeZ)ezFt1PyUyP3uwnI4j2R(PFDbfO7uWZGKOyiyIjMcZQhFHbQXyQo)tCQof8mijkgcMIdSbcwBkaRgv(mu(SKTYxr5ju5Zu5dtIxWfOjK6(CMuJJNbjrHYtIKYdbZWWfOjK6(CMuJlO5NYt2umxS0BknBWsztuUrGGjM)6mvNcEgKefdbtXb2abRnfcv(mv(WK4f8CdabqJneWXZGKOq5jrs5DuQuqZpEUbGaOXgc4auZ2Rv(muEDuEYMI5ILEtby6TAemX8p5t1PGNbjrXqWuCGnqWAtrGqWmmChvs7gUFTM1FCbn)MI5ILEtXrL0UH7xRz93eZF2zQof8mijkgcMIdSbcwBkcecMHH7OsA3W9R1S(JlO53umxS0Bk5gacGgBiyI5p7ovNcEgKefdbtXb2abRnfiyggENJiX9QFDaw2WMlO5NYxr5ju5Zu5dtIxWfOjK6(CMuJJNbjrHYtIKYdbZWWfOjK6(CMuJlO5NYtMYxr5ju5ju5fiemdd3rL0UH7xRz9hhGA2ETY)JYZoC2v5RO8zQ8wYIGnqEGD8OmpTT(l44zqsuO8KP8KiP8qWmm8a74rzEAB9xWHjQ8KnfZfl9McK0eyhuG2eZ)SmvNI5ILEtrGMqQ7ZzsTPGNbjrXqWeZF23uDkMlw6nfNen94uWZGKOyiyI5)VMQtbpdsIIHGP4aBGG1McHkFMkFys8cUtIMEKJNbjrHYxr5f0GlqK4lNcFIMdqnBVw5Zq51r5jt5jrs5ju5HGzy4nSqG3tGw8XbO5cLNejLhcMHH3b9W3hAGGdqZfkpzkFfLNqLhcMHH35isCV6xhGLnS5WevEsKuEhLkf08J35isCV6xhGLnS5auZ2Rv(Fu(FP8KnfZfl9McMq0bh4eZ)SYuDk4zqsumemfhydeS2uiu5Zu5dtIxWDs00JC8mijku(kkVGgCbIeF5u4t0CaQz71kFgkVokpzkpjskpemddVZrK4E1VoalByZHjQ8vuEiyggovpcisZraVdZXMYZs51r5RO8eQ8HjXl4caAIZGR)coEgKefkpztXCXsVPOrbHjFDaw2WjM)jM9uDk4zqsumemfhydeS2ueiemdd3rL0UH7xRz9hhMOYtIKYtOYdbZWWDa4(BV6N1TbldomrLVIYhMeVGZGa9uWJY8GSiKihpdsIcLNSPyUyP3uY)wGmFpXeZ)etCQof8mijkgcMIdSbcwBkqWmmCbAcPUpNj14WevEsKuEGvJk)pkFwYEkMlw6nL8VfiZ3tmX8prDMQtXCXsVPq1JaI0Cemf8mijkgcMy(NyYNQtXCXsVPK)Taz(EIPGNbjrXqWeZ)ezNP6umxS0Bk6xxqb6(aW93uWZGKOyiyI5FIS7uDkMlw6nLvJiEI9QF6xxqb6of8mijkgcMyIjMIEe0l9M)6KDI)kXS15x8ezFjpRmLCdC7v3tjRQrKccuO8zr5nxS0t5LBhnxLAkebuMvIt53kFcc0ALN90aGLcuP(TY)fbXM9kD66n(GH4oQw6E1GLwS0ZbmMiDVAU0qskuAiglbeO(0ebuMvID6SgGjtBfD6Soz(ypnayPGxcc0AEVAovQFR8S3qhQbHaLpXSts51j7e)LYNakVo6K8SvPuP(TYZE4ZUASzVuP(TYNakFckeOq5ZAynnuYvP(TYNakFckeOq5z)xxqb6Q8jt4(lDwvJiEI9QvE2)1fuGUCvQFR8jGYNGcbkuEcSiKOYx(OWHYhuLNiaDunilu(emRz)YvP(TYNakFYqcrhCS0dbSFALpRbOB7LEk)2kVaLyGcUk1Vv(eq5tqHafkp79gv(SAGAnxLsL63kFYqcrhCGcLhczOau5DuniluEiSEVMR8jOZHeJw5p6LaFgqJbwQ8Mlw61kp9K6YvPmxS0R5ebOJQbzblgP1SPszUyPxZjcqhvdYcYzLMHsfQuMlw61CIa0r1GSGCwPn4An8clw6Ps9BLVCgX(JgkpWwHYdbZWGcLVdlALhczOau5DuniluEiSEVw5TtO8ebycqKgXE1k)2kVGEixLYCXsVMteGoQgKfKZknKfHeF9hfouPmxS0R5ebOJQbzb5SstKgl9uPuP(TYNmKq0bhOq5r9iqxLpwnu5Jpu5nxqbk)2kVP3wPbjrUkL5ILEnl3NbQrvkZfl9AYzLMiSMgkvPmxS0RjNvAI0yPNkL5ILEn5SsdjPuXJbgOBsldlbcbZWWDujTB4(1Aw)XHjQszUyPxtoR0qiOraB7vN0YWsGqWmmChvs7gUFTM1FCyIQuMlw61KZkTbC2HVGca4fjTmSeiemdd3rL0UH7xRz9hxqZVkokvkO5hxJcct(6aSSHCaQz71)KiNDRaSAmd2nBvkZfl9AYzLwU1Fr)ypclQ1WlsAzyjqiyggUJkPDd3VwZ6pUGMFQuMlw61KZknZcqijLksAzyjqiyggUJkPDd3VwZ6pomrvkZfl9AYzL2oh2bWKpNjLjTmSeiemdd3rL0UH7xRz9hhMOkL5ILEn5SsB6TWajTmSCuQuqZpUJkPDd3VwZ6poa1S96m(fjsegMeVGNBaiaASHaoEgKefvCuQuqZpEUbGaOXgc4auZ2RZ4xKPszUyPxtoR0Wn(2a16KwgwokvkO5h3rL0UH7xRz9hhGA2EDg)IejcdtIxWZnaean2qahpdsIIkokvkO5hp3aqa0ydbCaQz71z8lYuPmxS0RjNv6ohrI7v)6aSSHDsldRMikLVWa1y088VfiZ3t8tIvi0rPsbn)4qstGDqbACaQz71)Ky2Ki5OuPGMFChvs7gUFTM1FCaQz71)8lsKSKfbBG8a74rzEAB9xWXZGKOGmvkZfl9AYzLgaFpZfl9EYTJKotdz9zUKwgwaBfpupEb3eIMJjC7OvPmxS0RjNvAa89mxS07j3os6mnKfZQhFHbQXiPLHvteLYxyGAmAE(3cK57j(HDuPmxS0RjNvAa89mxS07j3os6mnKfMq0bhysldlcdtIxW1SUnha54zqsuujmqng8p0KXhNOlYi5SlzKifgOgd(hAY4Jt0fzOt2QuMlw61KZkna(EMlw69KBhjDMgYQ3RwIVWa1yOsPszUyPxZXeIo4az1SblLnr5gbcsAzybSAmJSKDfcZmmjEbxGMqQ7ZzsnoEgKefKibbZWWfOjK6(CMuJlO5hzQuMlw61CmHOdoqYzLgy6TAeK0YWktiyggUanHu3NZKACyIvi0rPsbn)4oQK2nC)AnR)4auZ2RZqhsKimmjEbp3aqa0ydbC8mijkQ4OuPGMF8CdabqJneWbOMTxNHoKrMkL5ILEnhti6GdKCwPDujTB4(1Aw)L0YWsGqWmmChvs7gUFTM1FCbn)uPmxS0R5ycrhCGKZkDUbGaOXgcsAzyjqiyggUJkPDd3VwZ6pUGMFQuMlw61CmHOdoqYzLwGMqQ7ZzsnvkZfl9AoMq0bhi5Ssdjnb2bfOL0YWcy1ygjp7kzcbZWWfOjK6(CMuJdtuLYCXsVMJjeDWbsoR0ojA6XKwgwnrukFHbQXO55FlqMVN4hDuPmxS0R5ycrhCGKZkDlnTKwgwqWmmChaU)2R(zDBWYGdtuLYCXsVMJjeDWbsoR0AuqyYxhGLnmPLHfemddNQhbeP5iG3H5yJLovctIxWfa0eNbx)fC8mijkuPmxS0R5ycrhCGKZknMq0bhysldliyggUanHu3NZKACyIQuMlw61CmHOdoqYzLMQhbeP5iqLYCXsVMJjeDWbsoR0ycrhCGQuMlw61CmHOdoqYzLw)6ckq3haU)uPmxS0R5ycrhCGKZk9QrepXE1p9RlOaDvPuPmxS0R5mRE8fgOgdwnBWsztuUrGGKwgwaRgZilzxHWmdtIxWfOjK6(CMuJJNbjrbjsqWmmCbAcPUpNj14cA(rMkL5ILEnNz1JVWa1yqoR0atVvJGKwgweMzys8cEUbGaOXgc44zqsuqIKJsLcA(XZnaean2qahGA2EDg6qMkL5ILEnNz1JVWa1yqoR0oQK2nC)AnR)sAzyjqiyggUJkPDd3VwZ6pUGMFQuMlw61CMvp(cduJb5SsNBaiaASHGKwgwcecMHH7OsA3W9R1S(JlO5NkL5ILEnNz1JVWa1yqoR0qstGDqbAjTmSGGzy4DoIe3R(1byzdBUGMFvimZWK4fCbAcPUpNj144zqsuqIeemddxGMqQ7ZzsnUGMFKvHqcfiemdd3rL0UH7xRz9hhGA2E9pSdNDRKPLSiydKhyhpkZtBR)coEgKefKrIeemddpWoEuMN2w)fCyIKPszUyPxZzw94lmqngKZkTanHu3NZKAQuMlw61CMvp(cduJb5Ss7KOPhvPmxS0R5mRE8fgOgdYzLgti6GdmPLHfHzgMeVG7KOPh54zqsuurqdUarIVCk8jAoa1S96m0HmsKiecMHH3WcbEpbAXhhGMlirccMHH3b9W3hAGGdqZfKvHqiyggENJiX9QFDaw2WMdtKejhLkf08J35isCV6xhGLnS5auZ2R)5xKPszUyPxZzw94lmqngKZkTgfeM81byzdtAzyryMHjXl4ojA6roEgKefve0GlqK4lNcFIMdqnBVodDiJejiyggENJiX9QFDaw2WMdtScemddNQhbeP5iG3H5yJLovimmjEbxaqtCgC9xWXZGKOGmvkZfl9AoZQhFHbQXGCwPZ)wGmFprsldlbcbZWWDujTB4(1Aw)XHjsIeHqWmmChaU)2R(zDBWYGdtSsys8codc0tbpkZdYIqIC8mijkitLYCXsVMZS6XxyGAmiNv68VfiZ3tK0YWccMHHlqti195mPghMijsaRg)jlzRszUyPxZzw94lmqngKZknvpcisZrGkL5ILEnNz1JVWa1yqoR05FlqMVNqLYCXsVMZS6XxyGAmiNvA9RlOaDFa4(tLYCXsVMZS6XxyGAmiNv6vJiEI9QF6xxqb6QsPszUyPxZ)mhlaEIKwgwauZ2RZGLagyXsVKXS5jVcHzcSv8q94fCtiAomrsKGGzy4DoIe3R(1byzdBomrYuPmxS0R5FMJCwPB2GLYMOCJabjTmSawnMrwYUcHokvkO5hxGMqQ7Zzsnoa1S96FsojszgMeVGlqti195mPghpdsIcYuPmxS0R5FMJCwPfOjK6(CMulPLHfHokvkO5hhsAcSdkqJdqnBV(NSqIuys8coW0B1iGJNbjrrfhLkf08Jdm9wnc4auZ2R)jlKvHqhLkf08J7OsA3W9R1S(JdqnBVodDirIWWK4f8CdabqJneWXZGKOOIJsLcA(XZnaean2qahGA2EDg6qgzQuMlw618pZroR0atVvJGKwgwecSv8q94fCtiAomrsKa2kEOE8cUjenFVFcduJbpwn8f0NyrYQqOJsLcA(XDujTB4(1Aw)XbOMTxNHoKiryys8cEUbGaOXgc44zqsuuXrPsbn)45gacGgBiGdqnBVodDiJmvkZfl9A(N5iNvAhvs7gUFTM1FjTmSa2kEOE8cUjenhMijsaBfpupEb3eIMV3pSt2KiriWwXd1JxWnHO579JozxjmjEb3UAe80SZQrn8coEgKefKPszUyPxZ)mh5SsNBaiaASHGKwgwaBfpupEb3eIMdtKejGTIhQhVGBcrZ37h2jBsKieyR4H6Xl4Mq089(rNSReMeVGBxncEA2z1OgEbhpdsIcYuPmxS0R5FMJCwPHKMa7Gc0sAzyrOaHGzy4oQK2nC)AnR)4WeRaSv8q94fCtiA(E)egOgdESA4lOpXIKrIeWwXd1JxWnHO5WeRqiHcecMHH7OsA3W9R1S(JdqnBV(h2HZUvY0sweSbYdSJhL5PT1FbhpdsIcYirccMHHhyhpkZtBR)comrYuPmxS0R5FMJCwPP6rarAocsAzyLjWwXd1JxWnHO5WejrIqGTIhQhVGBcrZHjwXsweSbYBCBT19Yn9ihpdsIcYuPmxS0R5FMJCwPDs00JjTmSAIOu(cduJrZZ)wGmFpXp6OszUyPxZ)mh5SsJjeDWbM0YWktGTIhQhVGBcrZHjsIeHzgMeVG7KOPh54zqsuurqdUarIVCk8jAoa1S96m0HmsKGGzy4nSqG3tGw8XbO5cvkZfl9A(N5iNvAnkim5RdWYgM0YWktGTIhQhVGBcrZHjsIeHzgMeVG7KOPh54zqsuurqdUarIVCk8jAoa1S96m0HmvkZfl9A(N5iNv68VfiZ3tK0YWcyR4H6Xl4Mq0CyIQuMlw618pZroR0u9iGinhbQuMlw618pZroR05FlqMVNiPLHvys8codc0tbpkZdYIqIC8mijkuPmxS0R5FMJCwPBPPL0YWkZWK4fCgeONcEuMhKfHe54zqsuujtGTIhQhVGBcrZHjQszUyPxZ)mh5SsRFDbfO7da3FQuMlw618pZroR0Rgr8e7v)0VUGc0vLsLYCXsVM37vlXxyGAmybWtK0YWcGA2EDgSeWalw6LmMnp5veiemdd3rL0UH7xRz9hxqZpvkZfl9AEVxTeFHbQXGCwPB2GLYMOCJabjTmSawnMrwYUcHzgMeVGlqti195mPghpdsIcsKGGzy4c0esDFotQXf08JmvkZfl9AEVxTeFHbQXGCwPbMERgbjTmSYecMHHlqti195mPghMyfcDuQuqZpUJkPDd3VwZ6poa1S96m0HejcdtIxWZnaean2qahpdsIIkokvkO5hp3aqa0ydbCaQz71zOdzKPszUyPxZ79QL4lmqngKZkTJkPDd3VwZ6VKwgwcecMHH7OsA3W9R1S(JlO5NkL5ILEnV3RwIVWa1yqoR05gacGgBiiPLHLaHGzy4oQK2nC)AnR)4cA(PszUyPxZ79QL4lmqngKZkTanHu3NZKAQuMlw618EVAj(cduJb5SsJjeDWbM0YWccMHH3WcbEpbAXhhGMluPmxS0R59E1s8fgOgdYzLgsAcSdkqlPLHLJsLcA(X1OGWKVoalBihGA2EDfcZmmjEbxGMqQ7ZzsnoEgKefKibbZWWfOjK6(CMuJlO5hzviKqbcbZWWDujTB4(1Aw)XHjwjtlzrWgipWoEuMN2w)fC8mijkiJejiyggEGD8OmpTT(l4WejtLYCXsVM37vlXxyGAmiNvANen9ysldRMikLVWa1y088VfiZ3t8JoQuMlw618EVAj(cduJb5Sst1JaI0CeK0YWYsweSbYBCBT19Yn9ihyhBSsUkL5ILEnV3RwIVWa1yqoR0AuqyYxhGLnuLYCXsVM37vlXxyGAmiNv68VfiZ3tK0YWkmjEbNbb6PGhL5bzriroEgKefviecMHHlqti195mPghMijsaRg)HvwYMmvkZfl9AEVxTeFHbQXGCwPP6rarAocuPmxS0R59E1s8fgOgdYzLo)BbY89ejTmSctIxWzqGEk4rzEqwesKJNbjrrfcZ0sweSbYdSJhL5PT1FbhpdsIcsKeiemdd3rL0UH7xRz9hhMizQuMlw618EVAj(cduJb5Ss3stlPLHvMHjXl4miqpf8OmpilcjYXZGKOOcHzAjlc2a5b2XJY8026VGJNbjrbjscecMHH7OsA3W9R1S(JdtKejiyggUanHu3NZKACyIKibSA8hwzjBYuPmxS0R59E1s8fgOgdYzLw)6ckq3haU)uPmxS0R59E1s8fgOgdYzLE1iINyV6N(1fuGUtPjIU5p7lXjMyga]] )


end
