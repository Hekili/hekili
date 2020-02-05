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


    spec:RegisterPack( "Arms", 20200205, [[dKeq(aqikPEKuuTjPsFcfkvJIsXPOuAvOqv1RqjMfLQULuiTlc)sLYWKcogLkltkYZKkyAus4AOqSnPq8nuOY4OKOZHcLSouOW7qHszEsfDpuQ9jfQdsjPwikQhIcfDrkjP2ikuvgjkufNuQqSsPKzIcvPDIImuPcPLsjj5PQyQQuDvkjH2kLKOVsjjyVq(lfdwOdt1Ib5XKmzsDzKnl4ZQKrdQonWQLkuVgL0Sj62IA3q9BfdxQA5Q65knDjxxKTJc(oOmEPOCEPuRhfsZNsSFunYo0D0r7fHyQPgAQHgAQbgr0qdnX4Sc7qNQDpHo9UIv)IqhSNj0XQ)8Io9EB54A0D0zN0Ri0bEv9lJXTBxGcEcsOM8TfKtsVadw9EOUTGS6g6aLaYQJGrqOJ2lcXutn0udn0udmIOHgAIX1HoGoEQGpp6Ca5K0lWGzmFpuOdCGwtyee6OPvHonNhT6pV8Ovb)FW88wnNhHxv)YyC72fOGNGeQjFBb5K0lWGvVhQBliRUXB1CEKXhb9j)BZJwH98ytn0ud8w8wnNhzmH74lAzm4TAop2O8OvR1KMh7OPCMKcERMZJnkpA1AnP5rRsGQMVnpAvLw436i5EcRb4lE0QeOQ5Bl4TAop2O8OvR1KMhz2Rss84b(KkESgES)j1KH8IhT6okJxbVvZ5XgLhTQBgPsfyW0ZyF5Xo6tkWcgmpcwEutsQiTG3Q58yJYJwTwtAE0Q4s8yhPO8k4TAop2O8OvfLhginpY4XQzm5rjylgB84cY8yp9H5Zowr8iy5riQk65ryGc(KkEeu8OJ184cWxsYu(Frfp6k1KW1YJH55XCswGY)lQeOJeS1IUJolaFjjt5)fvO7iMSdDhDiSdjjnIz0r9GIEGJopLDaE5XozZJ607fyW8iJFESbrh4XU8OMGsHGqnYz30A2SVWf6bggDCvbgm68ewJketnHUJoe2HKKgXm6OEqrpWrN3ViEStESrAGh7YJqPqqOjxlBBuUml0dmmp2LhHsHGit55BBMGrMuaTr)KNxHEGHrhxvGbJolRjPC7LGQOhviM6a6o6qyhssAeZOJ6bf9ahDSMhHsHGqtUw22OCzwK65XU8On8OAgPEGHfQro7MwZM9fU4PSdWlp2jp2epAXcpAdpwUKWLaM)qp5SsVGWoKK08yxEunJupWWcy(d9KZk9INYoaV8yN8yt8OT8OTOJRkWGrN3zWVOhviMSc0D0HWoKK0iMrh1dk6bo6ynps7syfjYuE(2MjyKjfqB0p55vK9oEEE0IfE0gEekfcImLNVTzcgzsb0g9tEEfPEE0IfEunJupWWImLNVTzcgzsb0g9tEEfpLDaE5XgZJ21apAl64Qcmy0rnYz30A2SVWrfIjgbDhDiSdjjnIz0r9GIEGJowZJ0UewrImLNVTzcgzsb0g9tEEfzVJNNhTyHhTHhHsHGit55BBMGrMuaTr)KNxrQNhTyHhvZi1dmSit55BBMGrMuaTr)KNxXtzhGxESX8ODnWJ2IoUQadgDG5p0toR0Jketnc6o64Qcmy0rtUw22OCzgDiSdjjnIzuHyIXHUJoe2HKKgXm6OEqrpWrhOuii2KwtyJM8cU4jxvOJRkWGrhQzKkveQqmzLO7OdHDijPrmJoQhu0dC0rnJupWWI88LlnB9awjXtzhGxESlpAdpAnpwUKWLqtUw22OCzwqyhssAE0IfEekfccn5AzBJYLzHEGH5rB5XU8On8On8OMGsHGqnYz30A2SVWfPEESlpAnp6mk9GIefTLzcMm4cEjiSdjjnpAlpAXcpcLcbrrBzMGjdUGxIuppAlp2LhHsHGit55BBMGrMuaTr)KNxHEGHrhxvGbJoqsxtBnFgviMySq3rhc7qssJygDupOOh4OZ2tsPP8)IQvado4LWaynp2yESj0XvfyWOJssodeQqmzxdO7OdHDijPrmJoQhu0dC059lIh7Kh7qd8yxEekfcImLNVTzcgzsb0g9tEEfPEESlpQjOuiiuJC2nTMn7lCrQhDCvbgm6mmqF)aJEuHyYo7q3rhxvGbJo55lxA26bSsOdHDijPrmJket21e6o6qyhssAeZOJ6bf9ahDkxs4seONH5ntWa5vjjbHDijP5XU8On8iukeezkpFBZemYKcOn6N88ks98Ofl8iukeeAY1Y2gLlZIuppAl64Qcmy0bgCWlHbWAuHyYUoGUJoUQadgDggOVFGrp6qyhssAeZOcXKDwb6o6qyhssAeZOJ6bf9ahDkxs4seONH5ntWa5vjjbHDijPrhxvGbJoWGdEjmawJket2XiO7OdHDijPrmJoQhu0dC0XAESCjHlrGEgM3mbdKxLKee2HKKgDCvbgm6SspJket21iO7OJRkWGrhgaQA(2MpTWrhc7qssJygviMSJXHUJoUQadgDa5EcRb4lddavnFB0HWoKK0iMrfQqhnf8KSq3rmzh6o64Qcmy0rb3)lcDiSdjjnIzuHyQj0D0XvfyWOtFkNjj6qyhssAeZOcXuhq3rhxvGbJo9tbgm6qyhssAeZOcXKvGUJoe2HKKgXm6OEqrpWrhnbLcbHAKZUP1SzFHls9OJRkWGrhi5mAti9TrfIjgbDhDiSdjjnIz0r9GIEGJoAckfcc1iNDtRzZ(cxK6rhxvGbJoq0V0ZkaFHketnc6o6qyhssAeZOJ6bf9ahD0eukeeQro7MwZM9fUqpWW8yxEunJupWWI88LlnB9awjXtzhGxESX8ODcgHh7YJVFr8yN8iJ0a64Qcmy0XFLJjtn)t4cviMyCO7OdHDijPrmJoQhu0dC0rtqPqqOg5SBAnB2x4c9adJoUQadgDKGl41A64K(kt4cviMSs0D0HWoKK0iMrh1dk6bo6OjOuiiuJC2nTMn7lCrQhDCvbgm6eapbjNrJketmwO7OdHDijPrmJoQhu0dC0rtqPqqOg5SBAnB2x4Iup64Qcmy0XXkAR3LgLlLOcXKDnGUJoe2HKKgXm6G9mHoVN7b4lJN7LGkPjZf4YzyKLHWxamHoUQadgDEp3dWxgp3lbvstMlWLZWildHVaycviMSZo0D0HWoKK0iMrhxvGbJo(cNbhtR5DgDEJAExIoQhu0dC0XAEutqPqq8oJoVrnVlnAckfcIuppAXcpAdpw(FrLOazYuJPxvMo0ap2jpYi8yxEutqPqqOgSoPkadKbGz1OjOuiis98OT8Ofl8On8O18OMGsHGqnyDsvagidaZQrtqPqqK65XU8iukeezkpFBZemYKcOn6N88ks98Ofl8On8y)tmyUuAHDc1iNDtRzZ(cNh7YJwZJ0UewrImLNVTzcgzsb0g9tEEfzVJNNhTLhTfDWEMqhFHZGJP18oJoVrnVlrfIj7AcDhDiSdjjnIz0r9GIEGJoQzK6bgwOg5SBAnB2x4INYoaV8yN8OvYJwSWJ2WJLljCjG5p0toR0liSdjjnp2LhvZi1dmSaM)qp5SsV4PSdWlp2jpAL8OTOJRkWGrhNbV8hviMSRdO7OdHDijPrmJoQhu0dC0rnJupWWc1iNDtRzZ(cx8u2b4Lh7KhTsE0IfE0gESCjHlbm)HEYzLEbHDijP5XU8OAgPEGHfW8h6jNv6fpLDaE5Xo5rRKhTfDCvbgm6KwYakkVOcXKDwb6o6qyhssAeZOJ6bf9ahD2EsknL)xuTcyWbVegaR5XgZJ2XJD5rB4r1ms9adlGKUM2A(S4PSdWlp2yE0Ug4rlw4r1ms9adluJC2nTMn7lCXtzhGxESX8OvYJwSWJoJspOirrBzMGjdUGxcc7qssZJ2IoUQadgDwye1dWxMTEaR0Iket2XiO7OdHDijPrmJoQhu0dC0bkfcII2YmbtgCbVePEE0IfE0gEutqPqqOg5SBAnB2x4Iupp2LhTMhDgLEqrII2YmbtgCbVee2HKKMhTfDCvbgm6ajNrBMGPGtgct52OcXKDnc6o6qyhssAeZOJ6bf9ahDSMh1eukeeQro7MwZM9fUi1ZJD5rR5rOuiikAlZemzWf8sK6rhxvGbJo9PheAdWxgiPVfQqmzhJdDhDiSdjjnIz0r9GIEGJowZJAckfcc1iNDtRzZ(cxK65XU8O18iukeefTLzcMm4cEjs9OJRkWGrNh03ljdaB2ExrOcXKDwj6o6qyhssAeZOJ6bf9ahDSMh1eukeeQro7MwZM9fUi1ZJD5rR5rOuiikAlZemzWf8sK6rhxvGbJoWMxQzGayZt7GDSIqfIj7ySq3rhc7qssJygDupOOh4OJ18OMGsHGqnYz30A2SVWfPEESlpAnpcLcbrrBzMGjdUGxIup64Qcmy0jmQ0sAJZO0dkYarEgviMAQb0D0HWoKK0iMrh1dk6bo6ynpQjOuiiuJC2nTMn7lCrQNh7YJwZJqPqqu0wMjyYGl4Li1ZJD5r9uc1GveUEViTji9mzGspw8u2b4LhzZJnGoUQadgDudwr469I0MG0ZeQqm1KDO7OdHDijPrmJoQhu0dC0bkfcINuSkPDnH5vKi1JoUQadgDk4KjHHMewBcZRiuHyQPMq3rhc7qssJygDupOOh4OJAgPEGHfQro7MwZM9fU4PSdWlp2jpAxdOJRkWGrNRK)AGJntW4mk9tbhviMAQdO7OdHDijPrmJoQhu0dC0XAESCjHlbm)HEYzLEbHDijP5XU8OAgPEGHfQro7MwZM9fU4PSdWlp2jp2bE0IfEunJupWWcy(d9KZk9INYoaV8yN8yhqhxvGbJozkpFBZemYKcOn6N88IketnzfO7OdHDijPrmJoQhu0dC0z7jP0u(Fr1kGbh8syaSMhBmpAfOJRkWGrNpHnUQad2ibBHosWwgSNj0jayGmL)xuHketnXiO7OdHDijPrmJoQhu0dC0XgESCjHlr231vpjiSdjjnp2Lhl)VOsaNCzbx0RkEStESdmcpAlpAXcpw(FrLao5YcUOxv8yN8ytnGoUQadgD(e24QcmyJeSf6ibBzWEMqhQzKkveQqm1uJGUJoe2HKKgXm64Qcmy05tyJRkWGnsWwOJeSLb7zcDwa(ssMY)lQqfQqN(NutgYl0Det2HUJoUQadgDG8QKKzHpPcDiSdjjnIzuHyQj0D0HWoKK0iMrhSNj0Xz0fU)(AcdUmtW0pWOhDCvbgm64m6c3FFnHbxMjy6hy0JketDaDhDCvbgm6KP88TntWitkG2OFYZl6qyhssAeZOcXKvGUJoUQadgDUs(Rbo2mbJZO0pfC0HWoKK0iMrfIjgbDhDCvbgm60pfyWOdHDijPrmJkuHouZivQi0Det2HUJoe2HKKgXm6OEqrpWrN3ViEStESrAGh7YJqPqqOjxlBBuUml0dmmp2LhHsHGit55BBMGrMuaTr)KNxHEGHrhxvGbJolRjPC7LGQOhviMAcDhDiSdjjnIz0r9GIEGJowZJqPqqOjxlBBuUmls98yxE0gEunJupWWc1iNDtRzZ(cx8u2b4Lh7KhBIhTyHhTHhlxs4saZFONCwPxqyhssAESlpQMrQhyybm)HEYzLEXtzhGxEStESjE0wE0w0XvfyWOZ7m4x0JketDaDhDiSdjjnIz0r9GIEGJowZJ0UewrImLNVTzcgzsb0g9tEEfzVJNNhTyHhTHhHsHGit55BBMGrMuaTr)KNxrQNhTyHhvZi1dmSit55BBMGrMuaTr)KNxXtzhGxESX8ODnWJ2IoUQadgDuJC2nTMn7lCuHyYkq3rhc7qssJygDupOOh4OJ18iTlHvKit55BBMGrMuaTr)KNxr27455rlw4rB4rOuiiYuE(2MjyKjfqB0p55vK65rlw4r1ms9adlYuE(2MjyKjfqB0p55v8u2b4LhBmpAxd8OTOJRkWGrhy(d9KZk9OcXeJGUJoUQadgD0KRLTnkxMrhc7qssJygviMAe0D0HWoKK0iMrh1dk6bo6ynpcLcbrMYZ32mbJmPaAJ(jpVIupp2LhHsHGOOTmtWKbxWlrQNh7YJVFr8yN8yhAGh7YJwZJqPqqOjxlBBuUmls9OJRkWGrhiPRPTMpJketmo0D0HWoKK0iMrh1dk6bo6S9KuAk)VOAfWGdEjmawZJnMhBcDCvbgm6OKKZaHketwj6o6qyhssAeZOJ6bf9ahDGsHGq9PfoaFz8D9KSePEESlpcLcbrMYZ32mbJmPaAJ(jpVc9adJoUQadgDwPNrfIjgl0D0HWoKK0iMrh1dk6bo6aLcbXWa99dm6fB5kw5r28yt8yxESCjHlH(jxJ90f8sqyhssA0XvfyWOtE(YLMTEaReQqmzxdO7OdHDijPrmJoQhu0dC0bkfcImLNVTzcgzsb0g9tEEfPEE0IfEekfccn5AzBJYLzrQhDCvbgm6qnJuPIqfIj7SdDhDCvbgm6mmqF)aJE0HWoKK0iMrfIj7AcDhDCvbgm6qnJuPIqhc7qssJygvOcDcagit5)fvO7iMSdDhDiSdjjnIz0r9GIEGJoVFr8yN8yJ0ap2LhTHhTMhlxs4sOjxlBBuUmliSdjjnpAXcpcLcbHMCTSTr5YSqpWW8OTOJRkWGrNL1KuU9sqv0JketnHUJoe2HKKgXm6OEqrpWrhB4rR5XYLeUeW8h6jNv6fe2HKKMhTyHhvZi1dmSaM)qp5SsV4PSdWlp2jp2epAl64Qcmy05Dg8l6rfIPoGUJoe2HKKgXm6OEqrpWrhnbLcbHAKZUP1SzFHl0dmm64Qcmy0rnYz30A2SVWrfIjRaDhDiSdjjnIz0r9GIEGJoAckfcc1iNDtRzZ(cxOhyy0XvfyWOdm)HEYzLEuHyIrq3rhc7qssJygDupOOh4OdukeelmI6b4lZwpGvAf6bgMh7YJ2WJwZJLljCj0KRLTnkxMfe2HKKMhTyHhHsHGqtUw22OCzwOhyyE0wESlpAdpAdpQjOuiiuJC2nTMn7lCXtzhGxESX8OviyeESlpAnp6mk9GIefTLzcMm4cEjiSdjjnpAlpAXcpcLcbrrBzMGjdUGxIuppAl64Qcmy0bs6AAR5ZOcXuJGUJoUQadgD0KRLTnkxMrhc7qssJygviMyCO7OJRkWGrhLKCgi0HWoKK0iMrfIjReDhDiSdjjnIz0r9GIEGJo2WJwZJLljCjusYzGee2HKKMh7YJ6PeAI6nWMewVINYoaV8yN8yt8OT8Ofl8On8iukeeBsRjSrtEbx8KRkE0IfEekfcITgmzGt(xINCvXJ2YJD5rB4rOuiiwye1dWxMTEaR0ks98Ofl8OAgPEGHflmI6b4lZwpGvAfpLDaE5XgZJwjpAl64Qcmy0HAgPsfHketmwO7OdHDijPrmJoQhu0dC0XgE0AESCjHlHssodKGWoKK08yxEupLqtuVb2KW6v8u2b4Lh7KhBIhTLhTyHhHsHGyHrupaFz26bSsRi1ZJD5rOuiiggOVFGrVylxXkpYMhBIh7YJLljCj0p5ASNUGxcc7qssJoUQadgDYZxU0S1dyLqfIj7AaDhDiSdjjnIz0r9GIEGJoAckfcc1iNDtRzZ(cxK65rlw4rB4rOuiiuFAHdWxgFxpjlrQNh7YJLljCjc0ZW8MjyG8QKKGWoKK08OTOJRkWGrhyWbVegaRrfIj7SdDhDiSdjjnIz0r9GIEGJoqPqqOjxlBBuUmls98Ofl847xep2yESrAaDCvbgm6ado4LWaynQqmzxtO7OJRkWGrNHb67hy0Joe2HKKgXmQqmzxhq3rhxvGbJoWGdEjmawJoe2HKKgXmQqmzNvGUJoUQadgDyaOQ5BB(0chDiSdjjnIzuHyYogbDhDCvbgm6aY9ewdWxggaQA(2OdHDijPrmJkuHk0Hb6xWGrm1udn1qd21KvGoW8hdWxl60rY9ZxKMhzeE0vfyW8OeS1k4TqNTNuiMyC2Ho9)eascDAopA1FE5rRc()G55TAopcVQ(LX42Tlqbpbjut(2cYjPxGbREpu3wqwDJ3Q58iJpc6t(3MhTc75XMAOPg4T4TAopYyc3Xx0YyWB1CESr5rRwRjnp2rt5mjf8wnNhBuE0Q1AsZJwLavnFBE0QkTWV1rY9ewdWx8OvjqvZ3wWB1CESr5rRwRjnpYSxLK4Xd8jv8yn8y)tQjd5fpA1DugVcERMZJnkpAv3msLkWGPNX(YJD0NuGfmyEeS8OMKurAbVvZ5XgLhTATM08OvXL4Xosr5vWB1CESr5rRkkpmqAEKXJvZyYJsWwm24XfK5XE6dZNDSI4rWYJquv0ZJWaf8jv8iO4rhR5XfGVKKP8)IkE0vQjHRLhdZZJ5KSaL)xuj4T4TAopAv3msLksZJquyEIhvtgYlEeIUa4vWJwTsr91YJ4b3OW9phssE0vfyWlpoyzBbVvZ5rxvGbVI(NutgYl2bPVSYB1CE0vfyWRO)j1KH8If23cZO5TAop6Qcm4v0)KAYqEXc7BE6kt4YlWG5TAopEWE)cFkE8DGMhHsHaP5XT8A5rikmpXJQjd5fpcrxa8YJowZJ9p1O9tva8fpcwEupysWB5Qcm4v0)KAYqEXc7BqEvsYSWNuXB5Qcm4v0)KAYqEXc7BPLmGIY2J9mX2z0fU)(AcdUmtW0pWON3YvfyWRO)j1KH8If23YuE(2MjyKjfqB0p55L3YvfyWRO)j1KH8If23Us(Rbo2mbJZO0pfCElxvGbVI(NutgYlwyFRFkWG5T4TAopAv3msLksZJed03MhlqM4XcoXJUQMNhblp6m4aPdjjbVLRkWGx2k4(Fr8wUQadEzH9T(uotsElxvGbVSW(w)uGbZB5Qcm4Lf23GKZOnH032EqGTMGsHGqnYz30A2SVWfPEElxvGbVSW(ge9l9ScWx2dcS1eukeeQro7MwZM9fUi1ZB5Qcm4Lf238x5yYuZ)eUSheyRjOuiiuJC2nTMn7lCHEGH7QMrQhyyrE(YLMTEaRK4PSdWBJTtWiDF)I6KrAG3YvfyWllSVjbxWR10Xj9vMWL9GaBnbLcbHAKZUP1SzFHl0dmmVLRkWGxwyFlaEcsoJ2EqGTMGsHGqnYz30A2SVWfPEElxvGbVSW(MJv0wVlnkxkTheyRjOuiiuJC2nTMn7lCrQN3YvfyWllSVLwYakkBp2Ze73Z9a8LXZ9sqL0K5cC5mmYYq4laM4TCvbg8Yc7BPLmGIY2J9mX2x4m4yAnVZOZBuZ7s7bb2wRjOuiiENrN3OM3LgnbLcbrQ3IfBk)VOsuGmzQX0RkthAOtgPRMGsHGqnyDsvagidaZQrtqPqqK6T1IfBSwtqPqqOgSoPkadKbGz1OjOuiis9DHsHGit55BBMGrMuaTr)KNxrQ3IfB6FIbZLslStOg5SBAnB2x4DTM2LWksKP88TntWitkG2OFYZRi7D882AlVLRkWGxwyFZzWl)TheyRMrQhyyHAKZUP1SzFHlEk7a82PvAXInLljCjG5p0toR0liSdjjDx1ms9adlG5p0toR0lEk7a82PvAlVLRkWGxwyFlTKbuuETheyRMrQhyyHAKZUP1SzFHlEk7a82PvAXInLljCjG5p0toR0liSdjjDx1ms9adlG5p0toR0lEk7a82PvAlVLRkWGxwyFBHrupaFz26bSsR9Ga7TNKst5)fvRagCWlHbW6gBxxBuZi1dmSas6AAR5ZINYoaVn2UgSyrnJupWWc1iNDtRzZ(cx8u2b4TXwPfloJspOirrBzMGjdUGxcc7qssBlVLRkWGxwyFdsoJ2mbtbNmeMYTTheydLcbrrBzMGjdUGxIuVfl2OjOuiiuJC2nTMn7lCrQVR1oJspOirrBzMGjdUGxcc7qssBlVLRkWGxwyFRp9GqBa(Yaj9TSheyBTMGsHGqnYz30A2SVWfP(UwdLcbrrBzMGjdUGxIupVLRkWGxwyF7b99sYaWMT3vK9GaBR1eukeeQro7MwZM9fUi131AOuiikAlZemzWf8sK65TCvbg8Yc7BWMxQzGayZt7GDSISheyBTMGsHGqnYz30A2SVWfP(UwdLcbrrBzMGjdUGxIupVLRkWGxwyFlmQ0sAJZO0dkYarE2EqGT1Ackfcc1iNDtRzZ(cxK67AnukeefTLzcMm4cEjs98wUQadEzH9n1GveUEViTji9mzpiW2AnbLcbHAKZUP1SzFHls9DTgkfcII2YmbtgCbVeP(U6PeQbRiC9ErAtq6zYaLES4PSdWl7g4TCvbg8Yc7BfCYKWqtcRnH5vK9GaBOuiiEsXQK21eMxrIupVLRkWGxwyF7k5Vg4yZemoJs)uWTheyRMrQhyyHAKZUP1SzFHlEk7a82PDnWB5Qcm4Lf23YuE(2MjyKjfqB0p551EqGT1LljCjG5p0toR0liSdjjDx1ms9adluJC2nTMn7lCXtzhG3o7GflQzK6bgwaZFONCwPx8u2b4TZoWB5Qcm4Lf23(e24QcmyJeSL9yptSdagit5)fv2dcS3EsknL)xuTcyWbVegaRBSvWB5Qcm4Lf23(e24QcmyJeSL9yptSPMrQur2dcSTPCjHlr231vpjiSdjjD3Y)lQeWjxwWf9QQZoWi2AXs5)fvc4Kll4IEv1ztnWB5Qcm4Lf23(e24QcmyJeSL9yptSxa(ssMY)lQ4T4TCvbg8kOMrQurSxwts52lbvrV9Ga73VOoBKg6cLcbHMCTSTr5YSqpWWDHsHGit55BBMGrMuaTr)KNxHEGH5TCvbg8kOMrQurSW(27m4x0BpiW2AOuii0KRLTnkxMfP(U2OMrQhyyHAKZUP1SzFHlEk7a82ztwSyt5scxcy(d9KZk9cc7qss3vnJupWWcy(d9KZk9INYoaVD2KT2YB5Qcm4vqnJuPIyH9n1iNDtRzZ(c3EqGT10UewrImLNVTzcgzsb0g9tEEfzVJN3IfBGsHGit55BBMGrMuaTr)KNxrQ3If1ms9adlYuE(2MjyKjfqB0p55v8u2b4TX21GT8wUQadEfuZivQiwyFdM)qp5SsV9GaBRPDjSIezkpFBZemYKcOn6N88kYEhpVfl2aLcbrMYZ32mbJmPaAJ(jpVIuVflQzK6bgwKP88TntWitkG2OFYZR4PSdWBJTRbB5TCvbg8kOMrQurSW(MMCTSTr5YmVLRkWGxb1msLkIf23GKUM2A(S9GaBRHsHGit55BBMGrMuaTr)KNxrQVlukeefTLzcMm4cEjs9DF)I6Sdn01AOuii0KRLTnkxMfPEElxvGbVcQzKkvelSVPKKZazpiWE7jP0u(Fr1kGbh8syaSUXnXB5Qcm4vqnJuPIyH9Tv6z7bb2qPqqO(0chGVm(UEswIuFxOuiiYuE(2MjyKjfqB0p55vOhyyElxvGbVcQzKkvelSVLNVCPzRhWkzpiWgkfcIHb67hy0l2YvSYUPULljCj0p5ASNUGxcc7qssZB5Qcm4vqnJuPIyH9nQzKkvK9GaBOuiiYuE(2MjyKjfqB0p55vK6Tybkfccn5AzBJYLzrQN3YvfyWRGAgPsfXc7Bdd03pWON3YvfyWRGAgPsfXc7BuZivQiElElxvGbVIaGbYu(Frf7L1KuU9sqv0BpiW(9lQZgPHU2yD5scxcn5AzBJYLzbHDijPTybkfccn5AzBJYLzHEGHTL3YvfyWRiayGmL)xuXc7BVZGFrV9GaBBSUCjHlbm)HEYzLEbHDijPTyrnJupWWcy(d9KZk9INYoaVD2KT8wUQadEfbadKP8)IkwyFtnYz30A2SVWTheyRjOuiiuJC2nTMn7lCHEGH5TCvbg8kcagit5)fvSW(gm)HEYzLE7bb2Ackfcc1iNDtRzZ(cxOhyyElxvGbVIaGbYu(FrflSVbjDnT18z7bb2qPqqSWiQhGVmB9awPvOhy4U2yD5scxcn5AzBJYLzbHDijPTybkfccn5AzBJYLzHEGHTTRn2OjOuiiuJC2nTMn7lCXtzhG3gBfcgPR1oJspOirrBzMGjdUGxcc7qssBRflqPqqu0wMjyYGl4Li1BlVLRkWGxraWazk)VOIf230KRLTnkxM5TCvbg8kcagit5)fvSW(MssodeVLRkWGxraWazk)VOIf23OMrQur2dcSTX6YLeUekj5mqcc7qss3vpLqtuVb2KW6v8u2b4TZMS1IfBGsHGytAnHnAYl4INCvzXcukeeBnyYaN8Vep5QY2U2aLcbXcJOEa(YS1dyLwrQ3If1ms9adlwye1dWxMTEaR0kEk7a82yR0wElxvGbVIaGbYu(FrflSVLNVCPzRhWkzpiW2gRlxs4sOKKZajiSdjjDx9ucnr9gytcRxXtzhG3oBYwlwGsHGyHrupaFz26bSsRi13fkfcIHb67hy0l2YvSYUPULljCj0p5ASNUGxcc7qssZB5Qcm4veamqMY)lQyH9nyWbVegaRTheyRjOuiiuJC2nTMn7lCrQ3IfBGsHGq9PfoaFz8D9KSeP(ULljCjc0ZW8MjyG8QKKGWoKK02YB5Qcm4veamqMY)lQyH9nyWbVegaRTheydLcbHMCTSTr5YSi1BXY7xuJBKg4TCvbg8kcagit5)fvSW(2Wa99dm65TCvbg8kcagit5)fvSW(gm4GxcdG18wUQadEfbadKP8)IkwyFJbGQMVT5tlCElxvGbVIaGbYu(FrflSVbY9ewdWxggaQA(28w8wUQadEflaFjjt5)fvSFcRThey)u2b4Tt2607fyWm(Bq0HUAckfcc1iNDtRzZ(cxOhyyElxvGbVIfGVKKP8)IkwyFBznjLBVeuf92dcSF)I6SrAOlukeeAY1Y2gLlZc9ad3fkfcImLNVTzcgzsb0g9tEEf6bgM3YvfyWRyb4ljzk)VOIf23ENb)IE7bb2wdLcbHMCTSTr5YSi131g1ms9adluJC2nTMn7lCXtzhG3oBYIfBkxs4saZFONCwPxqyhss6UQzK6bgwaZFONCwPx8u2b4TZMS1wElxvGbVIfGVKKP8)IkwyFtnYz30A2SVWTheyBnTlHvKit55BBMGrMuaTr)KNxr2745TyXgOuiiYuE(2MjyKjfqB0p55vK6TyrnJupWWImLNVTzcgzsb0g9tEEfpLDaEBSDnylVLRkWGxXcWxsYu(FrflSVbZFONCwP3EqGT10UewrImLNVTzcgzsb0g9tEEfzVJN3IfBGsHGit55BBMGrMuaTr)KNxrQ3If1ms9adlYuE(2MjyKjfqB0p55v8u2b4TX21GT8wUQadEflaFjjt5)fvSW(MMCTSTr5YmVLRkWGxXcWxsYu(FrflSVrnJuPISheydLcbXM0AcB0KxWfp5QI3YvfyWRyb4ljzk)VOIf23GKUM2A(S9GaB1ms9adlYZxU0S1dyLepLDaE7AJ1LljCj0KRLTnkxMfe2HKK2IfOuii0KRLTnkxMf6bg22U2yJMGsHGqnYz30A2SVWfP(Uw7mk9GIefTLzcMm4cEjiSdjjTTwSaLcbrrBzMGjdUGxIuVTDHsHGit55BBMGrMuaTr)KNxHEGH5TCvbg8kwa(ssMY)lQyH9nLKCgi7bb2BpjLMY)lQwbm4GxcdG1nUjElxvGbVIfGVKKP8)IkwyFByG((bg92dcSF)I6Sdn0fkfcImLNVTzcgzsb0g9tEEfP(UAckfcc1iNDtRzZ(cxK65TCvbg8kwa(ssMY)lQyH9T88LlnB9awjElxvGbVIfGVKKP8)IkwyFdgCWlHbWA7bb2LljCjc0ZW8MjyG8QKKGWoKK0DTbkfcImLNVTzcgzsb0g9tEEfPElwGsHGqtUw22OCzwK6TL3YvfyWRyb4ljzk)VOIf23ggOVFGrpVLRkWGxXcWxsYu(FrflSVbdo4LWayT9Ga7YLeUeb6zyEZemqEvssqyhssAElxvGbVIfGVKKP8)IkwyFBLE2EqGT1LljCjc0ZW8MjyG8QKKGWoKK08wUQadEflaFjjt5)fvSW(gdavnFBZNw48wUQadEflaFjjt5)fvSW(gi3tynaFzyaOQ5BJkuHq]] )


end
