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


    spec:RegisterPack( "Arms", 20200124, [[dy0svbqikWJOG0MeIpjusYOqLCkurRsOKQxrHmlHIBHQqTlu(fQudti5ycPwgfvpdvbtdvqxtOuBdvO(gQqACcL4CuqvRtOKyEuuUhfzFOk6GOkKfIQQhsbvYfrfcojfuXkLkntkOsTtuvgkQq0sfkP0tbAQOkDvHssTvuHqFvOKI9c1FP0GfCyQwmOEmPMmHlJSzr(minAaoTQwnfuEnfQztYTf1UH8BfdxQA5Q8CLMUKRlLTlu9DqmEuboVuX6PGy(aA)enoAmVyqHxeMpZJY8OIkAZ5qw0rffhgBEadwD6jmyVRn2HsyqKNjmip6YlgS37OgxG5fdUt70egeqv9BSc3Cd9lanyMEYCVFUP86hK(8uX9(zn3yq42Rkdheggdk8IW8zEuMhvurBohYIoQO4WyJb9wbyomi4NBkV(bz468uHbb8cbHWWyqbTAmOHkd8OlVYqSg)UFozxdvgauv)gRWn3q)cqdMPNm37NBkV(bPppvCVFwZTSRHkdDDuZVoYG5rhJmyEuMhLSRSRHkdgUa4iO0gRi7AOYapwg4rcbjKboYwotkMSRHkd8yzGhjeKqg4i(6AUoYqS22cGBdNCpHepcQmWr811CDyYUgQmWJLbEKqqczGFVkfjdGaMwjd1id9hPNmSxYapIJ0Wnt21qLbESmWrGdiDR(brxSQvg4ips)7piz4xzqqkQibt21qLbESmWJecsidXQxsgmCkkVmmO63AX8Ib3hbvr2YpOuH5fZx0yEXGeYHvKaZpguFFr37yWJY(JwzWmtYGODE9dsgI1LHOy8GmergeeClLy6rn72w7M9fatmqqyqxx)GWGhHe4cZN5yEXGeYHvKaZpguFFr37yWZHsYGzYahhLmergGBPetqUq1XQDvMjgiiziIma3sjwMYZ1XojRQPFHvCKNxMyGGWGUU(bHbxJBk12R(QOdxy(4bmVyqc5WksG5hdQVVO7DmObYaClLycYfQowTRYSwVmerg4sg0ZOedeetpQz32A3SVayhL9hTYGzYG5YaqGYaxYq5kcvmi(bFKBmDmc5WksidrKb9mkXabXG4h8rUX0Xok7pALbZKbZLboLboXGUU(bHbppUdLoCH5JdX8IbDD9dcdQh1SBBTB2xayqc5WksG5hxy(InMxmORRFqyqi(bFKBmDyqc5WksG5hxy(4ymVyqxx)GWGcYfQowTRYyqc5WksG5hxy(4OyEXGeYHvKaZpguFFr37yq4wkX2MqqiRG8ca7ixxyqxx)GWGehq6wr4cZxSG5fdsihwrcm)yq99fDVJb1ZOedeelpx5k7w3BmXok7pALHiYaxYGbYq5kcvmb5cvhR2vzgHCyfjKbGaLb4wkXeKluDSAxLzIbcsg4ugIidCjdCjdccULsm9OMDBRDZ(cG16LHiYGbYGBi09fXkAl7KS5hkGIrihwrczGtzaiqzaULsSI2YojB(HcOyTEzGtziIma3sjwMYZ1XojRQPFHvCKNxMyGGKHiYW5qjzWmzGdJcd666hegew5cAR5Y4cZNHhZlgKqoSIey(XG67l6EhdU9Kszl)Gs1YGa4pfKhjKbEkdMJbDD9dcdQvKhNWfMVOJcZlgKqoSIey(XG67l6EhdYLmCousgmtg4HOKHiYaClLyzkpxh7KSQM(fwXrEEzTEziImii4wkX0JA2TT2n7lawRxg4ugacug4sgohkjdMjdC0OKHiYaClLyzkpxh7KSQM(fwXrEEzIbcsg4ed666hegCItx)aHoCH5l6OX8IbDD9dcdMNRCLDR7nMWGeYHvKaZpUW8fT5yEXGeYHvKaZpguFFr37yWYveQyj6IpNDswyVkfXiKdRiHmerg4sgGBPelt556yNKv10VWkoYZlR1ldabkdccULsm9OMDBRDZ(cG16LbGaLb4wkXeKluDSAxLzTEzGtmORRFqyqia(tb5rcCH5lAEaZlg011pim4eNU(bcDyqc5WksG5hxy(IMdX8IbjKdRibMFmO((IU3XGLRiuXs0fFo7KSWEvkIrihwrcziImWLma3sjwrBzNKn)qbuSwVmaeOmii4wkX0JA2TT2n7laMyGGKHiYaClLyfTLDs28dfqXedeKmergohkjd8ug44OKboXGUU(bHbHa4pfKhjWfMVOJnMxmiHCyfjW8Jb13x09og0azOCfHkwIU4ZzNKf2Rsrmc5WksGbDD9dcdUkpJlmFrZXyEXGUU(bHbJ)6AUo2RTaWGeYHvKaZpUW8fnhfZlg011pim4N7jK4rqTXFDnxhmiHCyfjW8JlCHbfuYBQcZlMVOX8IbDD9dcdQb4hucdsihwrcm)4cZN5yEXGUU(bHb7B5mPWGeYHvKaZpUW8XdyEXGeYHvKaZpguFFr37yWYpOuXaqUQaW61LmyMmyE0YqezaULsSmLNRJDswvt)cR4ipVSwVmaeOmyGmq7sinXYuEUo2jzvn9lSIJ88YYUHnhg011pimy)u)GWfMpoeZlgKqoSIey(XG67l6Ehdc3sjwMYZ1XojRQPFHvCKNx2rz)rRmyMmeBzaiqzGlzWazG2LqAILP8CDStYQA6xyfh55LLDdBoziImii4wkX0JA2TT2n7lawRxg4ed666hegewnJWMAxhCH5l2yEXGeYHvKaZpguFFr37yq4wkXYuEUo2jzvn9lSIJ88YA9YaqGYaxYGbYaTlH0elt556yNKv10VWkoYZll7g2CYqezqqWTuIPh1SBBTB2xaSwVmWjg011pimimDlDg)iO4cZhhJ5fdsihwrcm)yq99fDVJb1ZOedeelpx5k7w3BmXok7pALbEkdrZITmergGBPelt556yNKv10VWkoYZltmqqYqez4COKmyMme7OWGUU(bHb9t7iYwZDeQWfMpokMxmiHCyfjW8Jb13x09oguqWTuIPh1SBBTB2xamXabHbDD9dcdQEOaQ1Aynb0mHkCH5lwW8IbjKdRibMFmO((IU3XGWTuILP8CDStYQA6xyfh55LDu2F0kdMjdXwgacug4sgmqgODjKMyzkpxh7KSQM(fwXrEEzz3WMtgIidccULsm9OMDBRDZ(cG16LboXGUU(bHbt)rWQze4cZNHhZlgKqoSIey(XG67l6Ehdc3sjwMYZ1XojRQPFHvCKNx2rz)rRmyMmeBzaiqzGlzWazG2LqAILP8CDStYQA6xyfh55LLDdBoziImii4wkX0JA2TT2n7lawRxg4ed666heg0rAARZvwTRu4cZx0rH5fdsihwrcm)yq99fDVJbHBPelt556yNKv10VWkoYZl7OS)OvgmtgITmaeOmWLmyGmq7sinXYuEUo2jzvn9lSIJ88YYUHnNmergeeClLy6rn72w7M9faR1ldCIbDD9dcdc7qTtYw3RnEXfMVOJgZlgKqoSIey(XGUU(bHb9fqChrR9CdzoREoxHb13x09og0azqqWTuIDUHmNvpNRSccULsSwVmaeOmWLmu(bLkgaYvfawVUKbZKbZJIfTmergGBPelt556yNKv10VWkoYZlR1ldrKb9mkXabXYuEUo2jzvn9lSIJ88Yok7pALbZKHOJMJkdCkdabkdCjdLFqPIvFMS1y71LLhIsgmtgITmergeeClLy6bjA66Jt2hzSvqWTuI16LHiYGbYaTlH0elt556yNKv10VWkoYZll7g2CYaNYaqGYaxYGbYGGGBPetpirtxFCY(iJTccULsSwVmergmqgODjKMyzkpxh7KSQM(fwXrEEzz3WMtgIidccULsm9OMDBRDZ(cG16LboLbGaLH6ZKTgR4jzWmzGhIcdI8mHb9fqChrR9CdzoREoxHlmFrBoMxmiHCyfjW8Jb13x09ogupJsmqqm9OMDBRDZ(cGDu2F0kdMjdXImaeOmWLmuUIqfdIFWh5gthJqoSIeYqezqpJsmqqmi(bFKBmDSJY(JwzWmziwKboXGUU(bHb94E5hUW8fnpG5fdsihwrcm)yq99fDVJb1ZOedeetpQz32A3SVayhL9hTYGzYqSidabkdCjdLRiuXG4h8rUX0XiKdRiHmerg0ZOedeedIFWh5gth7OS)OvgmtgIfzGtmORRFqyW2s2VO8IlmFrZHyEXGeYHvKaZpguFFr37yWTNukB5huQwgea)PG8iHmWtziAziImWLmONrjgiigSYf0wZLzhL9hTYapLHOJsgacug0ZOedeetpQz32A3SVayhL9hTYapLHyrgacugCdHUViwrBzNKn)qbumc5WksidCIbDD9dcdUqiQ)rqTBDVX0IlmFrhBmVyqc5WksG5hdQVVO7DmiClLyfTLDs28dfqXA9YaqGYaxYGGGBPetpQz32A3SVayTEziImyGm4gcDFrSI2YojB(HcOyeYHvKqg4ed666hegewnJWojBbGSeIYDWfMVO5ymVyqc5WksG5hdQVVO7DmObYGGGBPetpQz32A3SVayTEziImyGma3sjwrBzNKn)qbuSwpg011pimyF7(uNhb1cR8TWfMVO5OyEXGeYHvKaZpguFFr37yqdKbbb3sjMEuZUT1UzFbWA9YqezWazaULsSI2YojB(HcOyTEmORRFqyW777vK9r2T31eUW8fDSG5fdsihwrcm)yq99fDVJbnqgeeClLy6rn72w7M9faR1ldrKbdKb4wkXkAl7KS5hkGI16XGUU(bHbHmNseNEK9ODqost4cZx0gEmVyqc5WksG5hdQVVO7DmObYGGGBPetpQz32A3SVayTEziImyGma3sjwrBzNKn)qbuSwpg011pimyA0TLew3qO7lYctEgxy(mpkmVyqc5WksG5hdQVVO7DmObYGGGBPetpQz32A3SVayTEziImyGma3sjwrBzNKn)qbuSwpg011pim4rE)JGAtkptlUW8zE0yEXGeYHvKaZpguFFr37yqdKbbb3sjMEuZUT1UzFbWA9YqezWazaULsSI2YojB(HcOyTEziImiMIPhKMq15fjSjLNjlC7qSJY(JwzWKmefg011pimOEqAcvNxKWMuEMWfMpZnhZlgKqoSIey(XG67l6Ehdc3sj2rAJv0U20CAI16XGUU(bHblaKTHGNgsytZPjCH5ZCEaZlgKqoSIey(XG67l6EhdQNrjgiiMEuZUT1UzFbWok7pALbZKHOJcd666hegeAZpX7i7KSUHq3uaWfMpZ5qmVyqc5WksG5hdQVVO7DmObYq5kcvmi(bFKBmDmc5WksidrKb9mkXabX0JA2TT2n7la2rz)rRmyMmavlKHiYaxYq9zYwJv8KmWtzi6yhLmaeOmu(bLkgaYvfawVUKbZKbZJsg4ed666hegmt556yNKv10VWkoYZlUW8zESX8IbjKdRibMFmO((IU3XGLRiuXG4h8rUX0XiKdRiHmerg0ZOedeedIFWh5gth7OS)OvgmtgGQfYqezGlzO(mzRXkEsg4PmeDSJsgacugk)Gsfda5QcaRxxYGzYG5rjdCIbDD9dcdMP8CDStYQA6xyfh55fxy(mNJX8IbjKdRibMFmO((IU3XGN)clfNqfZfILrCWV1IbDD9dcdEnK111piR63cdQ(TSiptyqaUgxy(mNJI5fdsihwrcm)yq99fDVJb3EsPSLFqPAzqa8NcYJeYapLboed666heg8AiRRRFqw1Vfgu9BzrEMWGPpozl)GsfUW8zESG5fdsihwrcm)yq99fDVJb5sgkxrOIL9DD9rmc5WksidrKHYpOuXaqUQaW61LmyMmWdXwg4ugacugk)Gsfda5QcaRxxYGzYG5rHbDD9dcdEnK111piR63cdQ(TSiptyqIdiDRiCH5ZCdpMxmiHCyfjW8JbDD9dcdEnK111piR63cdQ(TSiptyW9rqvKT8dkv4cxyW(J0tg2lmVy(IgZlg011pimiSxLISlGPvyqc5WksG5hxy(mhZlgKqoSIey(XGiptyq3qwa(5RnnOYojB)aHomORRFqyq3qwa(5RnnOYojB)aHoCH5JhW8IbDD9dcdczoLio9i7r7GCKMWGeYHvKaZpUW8XHyEXGUU(bHbZuEUo2jzvn9lSIJ88IbjKdRibMFCH5l2yEXGUU(bHbH28t8oYojRBi0nfamiHCyfjW8JlmFCmMxmORRFqyW(P(bHbjKdRibMFCHlmiXbKUveMxmFrJ5fdsihwrcm)yq99fDVJbphkjdMjdCCuYqezaULsmb5cvhR2vzMyGGKHiYaClLyzkpxh7KSQM(fwXrEEzIbccd666hegCnUPuBV6RIoCH5ZCmVyqc5WksG5hdQVVO7DmObYaClLycYfQowTRYSwVmerg4sg0ZOedeetpQz32A3SVayhL9hTYGzYG5YaqGYaxYq5kcvmi(bFKBmDmc5WksidrKb9mkXabXG4h8rUX0Xok7pALbZKbZLboLboXGUU(bHbppUdLoCH5JhW8IbjKdRibMFmO((IU3XGgid0UestSmLNRJDswvt)cR4ipVSSByZjdabkdCjdWTuILP8CDStYQA6xyfh55L16LbGaLb9mkXabXYuEUo2jzvn9lSIJ88Yok7pALbEkdrhLmWjg011pimOEuZUT1UzFbGlmFCiMxmiHCyfjW8Jb13x09og0azG2LqAILP8CDStYQA6xyfh55LLDdBozaiqzGlzaULsSmLNRJDswvt)cR4ipVSwVmaeOmONrjgiiwMYZ1XojRQPFHvCKNx2rz)rRmWtzi6OKboXGUU(bHbH4h8rUX0HlmFXgZlg011pimOGCHQJv7QmgKqoSIey(XfMpogZlgKqoSIey(XG67l6EhdAGma3sjwMYZ1XojRQPFHvCKNxwRxgIidWTuIv0w2jzZpuafR1ldrKHZHsYGzYapeLmergmqgGBPetqUq1XQDvM16XGUU(bHbHvUG2AUmUW8XrX8IbjKdRibMFmO((IU3XGBpPu2YpOuTmia(tb5rczGNYG5yqxx)GWGAf5XjCH5lwW8IbjKdRibMFmO((IU3XGWTuIPV2c4rqT(UEtvSwVmergGBPelt556yNKv10VWkoYZltmqqyqxx)GWGRYZ4cZNHhZlgKqoSIey(XG67l6Ehdc3sj2eNU(bcDSTCTXYGjzWCziImuUIqftCKlqEdkGIrihwrcmORRFqyW8CLRSBDVXeUW8fDuyEXGeYHvKaZpguFFr37yq4wkXYuEUo2jzvn9lSIJ88YA9YaqGYaClLycYfQowTRYSwVmaeOmWLma3sjwrBzNKn)qbuSwVmerg0ZOedeelt556yNKv10VWkoYZl7OS)Ovg4Pmy45qzGtmORRFqyqIdiDRiCH5l6OX8IbDD9dcdoXPRFGqhgKqoSIey(XfMVOnhZlg011pimiXbKUvegKqoSIey(XfUWGaCnMxmFrJ5fdsihwrcm)yq99fDVJbpk7pALbZmjdI251piziwxgIIXdYqezGlzWaz48xyP4eQyUqSSwVmaeOma3sj2cHO(hb1U19gtlR1ldCIbDD9dcdEesGlmFMJ5fdsihwrcm)yq99fDVJbphkjdMjdCCuYqezGlzqpJsmqqmb5cvhR2vz2rz)rRmWtzGhKbGaLbdKHYveQycYfQowTRYmc5WksidCIbDD9dcdUg3uQTx9vrhUW8XdyEXGeYHvKaZpguFFr37yqUKb9mkXabXGvUG2AUm7OS)Ovg4PmWXYaqGYq5kcvSZJ7qPJrihwrcziImONrjgii25XDO0Xok7pALbEkdCSmWPmerg4sg0ZOedeetpQz32A3SVayhL9hTYGzYG5YaqGYaxYq5kcvmi(bFKBmDmc5WksidrKb9mkXabXG4h8rUX0Xok7pALbZKbZLboLboXGUU(bHbfKluDSAxLXfMpoeZlgKqoSIey(XG67l6EhdYLmC(lSuCcvmxiwwRxgacugo)fwkoHkMlel7rYapLHYpOuXQpt2ASINKboLHiYaxYGEgLyGGy6rn72w7M9fa7OS)Ovgmtgmxgacug4sgkxrOIbXp4JCJPJrihwrcziImONrjgiige)GpYnMo2rz)rRmyMmyUmWPmWjg011pim45XDO0HlmFXgZlgKqoSIey(XG67l6EhdE(lSuCcvmxiwwRxgacugo)fwkoHkMlel7rYapLbomkzaiqzGlz48xyP4eQyUqSShjd8ugmpkziImuUIqfZrqPZMDKdLYeQyeYHvKqg4ed666hegupQz32A3SVaWfMpogZlgKqoSIey(XG67l6EhdE(lSuCcvmxiwwRxgacugo)fwkoHkMlel7rYapLbomkzaiqzGlz48xyP4eQyUqSShjd8ugmpkziImuUIqfZrqPZMDKdLYeQyeYHvKqg4ed666hegeIFWh5gthUW8XrX8IbjKdRibMFmO((IU3XGCjdccULsm9OMDBRDZ(cG16LHiYW5VWsXjuXCHyzpsg4Pmu(bLkw9zYwJv8KmWPmaeOmC(lSuCcvmxiwwRxgIidCjdCjdccULsm9OMDBRDZ(cGDu2F0kd8ug4qwSLHiYGbYGBi09fXkAl7KS5hkGIrihwrczGtzaiqzaULsSI2YojB(HcOyTEzGtmORRFqyqyLlOTMlJlmFXcMxmiHCyfjW8Jb13x09og0az48xyP4eQyUqSSwVmaeOmWLmC(lSuCcvmxiwwRxgIidUHq3xeBPFZV2cXJtmc5WksidCIbDD9dcdoXPRFGqhUW8z4X8IbjKdRibMFmO((IU3XGBpPu2YpOuTmia(tb5rczGNYG5yqxx)GWGAf5XjCH5l6OW8IbjKdRibMFmO((IU3XGgidN)clfNqfZfIL16LbGaLbUKbdKHYveQyAf5XjgHCyfjKHiYGykMGOElKPHel7OS)Ovgmtgmxg4ugacugGBPeBBcbHScYlaSJCDHbDD9dcdsCaPBfHlmFrhnMxmiHCyfjW8Jb13x09og0az48xyP4eQyUqSSwVmaeOmWLmyGmuUIqftRipoXiKdRiHmergetXee1BHmnKyzhL9hTYGzYG5YaNyqxx)GWG55kxz36EJjCH5lAZX8IbjKdRibMFmO((IU3XGN)clfNqfZfIL16XGUU(bHbHa4pfKhjWfMVO5bmVyqxx)GWGtC66hi0HbjKdRibMFCH5lAoeZlgKqoSIey(XG67l6EhdwUIqflrx85StYc7vPigHCyfjWGUU(bHbHa4pfKhjWfMVOJnMxmiHCyfjW8Jb13x09og0azOCfHkwIU4ZzNKf2Rsrmc5WksidrKbdKHZFHLItOI5cXYA9yqxx)GWGRYZ4cZx0CmMxmORRFqyW4VUMRJ9AlamiHCyfjW8JlmFrZrX8IbDD9dcd(5EcjEeuB8xxZ1bdsihwrcm)4cxyW0hNSLFqPcZlMVOX8IbjKdRibMFmO((IU3XGNdLKbZKbookziImWLmyGmuUIqftqUq1XQDvMrihwrczaiqzaULsmb5cvhR2vzMyGGKboXGUU(bHbxJBk12R(QOdxy(mhZlgKqoSIey(XG67l6EhdYLmyGmuUIqfdIFWh5gthJqoSIeYaqGYGEgLyGGyq8d(i3y6yhL9hTYGzYG5YaNyqxx)GWGNh3HshUW8XdyEXGeYHvKaZpguFFr37yqbb3sjMEuZUT1UzFbWedeeg011pimOEuZUT1UzFbGlmFCiMxmiHCyfjW8Jb13x09oguqWTuIPh1SBBTB2xamXabHbDD9dcdcXp4JCJPdxy(InMxmiHCyfjW8Jb13x09ogeULsSfcr9pcQDR7nMwMyGGKHiYaxYGbYq5kcvmb5cvhR2vzgHCyfjKbGaLb4wkXeKluDSAxLzIbcsg4ugIidCjdCjdccULsm9OMDBRDZ(cGDu2F0kd8ug4qwSLHiYGbYGBi09fXkAl7KS5hkGIrihwrczGtzaiqzaULsSI2YojB(HcOyTEzGtmORRFqyqyLlOTMlJlmFCmMxmORRFqyqb5cvhR2vzmiHCyfjW8JlmFCumVyqxx)GWGAf5XjmiHCyfjW8JlmFXcMxmiHCyfjW8Jb13x09ogKlzWazOCfHkMwrECIrihwrcziImiMIjiQ3czAiXYok7pALbZKbZLboLbGaLbUKb4wkX2MqqiRG8ca7ixxYaqGYaClLyBniYcG8Ryh56sg4ugIidCjdWTuITqiQ)rqTBDVX0YA9YaqGYGEgLyGGyleI6Feu7w3BmTSJY(JwzGNYqSidCIbDD9dcdsCaPBfHlmFgEmVyqc5WksG5hdQVVO7DmixYGbYq5kcvmTI84eJqoSIeYqezqmftquVfY0qILDu2F0kdMjdMldCkdabkdWTuITqiQ)rqTBDVX0YA9YqezaULsSjoD9de6yB5AJLbtYG5YqezOCfHkM4ixG8guafJqoSIeyqxx)GWG55kxz36EJjCH5l6OW8IbjKdRibMFmO((IU3XGccULsm9OMDBRDZ(cG16LbGaLbUKb4wkX0xBb8iOwFxVPkwRxgIidLRiuXs0fFo7KSWEvkIrihwrczGtmORRFqyqia(tb5rcCH5l6OX8IbjKdRibMFmO((IU3XGWTuIjixO6y1UkZA9YaqGYW5qjzGNYahhfg011pimiea)PG8ibUW8fT5yEXGUU(bHbN401pqOddsihwrcm)4cZx08aMxmORRFqyqia(tb5rcmiHCyfjW8JlmFrZHyEXGUU(bHbJ)6AUo2RTaWGeYHvKaZpUW8fDSX8IbDD9dcd(5EcjEeuB8xxZ1bdsihwrcm)4cx4cdgNU9heMpZJkAdFuXs0CmgeIFOhbDXGgo5(5ksidCSm466hKmO(TwMSlgS)M0RimOHkd8OlVYqSg)UFozxdvgauv)gRWn3q)cqdMPNm37NBkV(bPppvCVFwZTSRHkdDDuZVoYG5rhJmyEuMhLSRSRHkdgUa4iO0gRi7AOYapwg4rcbjKboYwotkMSRHkd8yzGhjeKqg4i(6AUoYqS22cGBdNCpHepcQmWr811CDyYUgQmWJLbEKqqczGFVkfjdGaMwjd1id9hPNmSxYapIJ0Wnt21qLbESmWrGdiDR(brxSQvg4ips)7piz4xzqqkQibt21qLbESmWJecsidXQxsgmCkkVmzxzxdvg4iWbKUvKqgGP0CKmONmSxYamb9rltg4rAn1xRmGgepgGF5utjdUU(bTYWGuDyYUgQm466h0Y6pspzyVmLu(ASSRHkdUU(bTS(J0tg2lJmXDAgHSRHkdUU(bTS(J0tg2lJmXT3GMju51pizxdvgarE)cykz48xidWTuIeYWwETYamLMJKb9KH9sgGjOpALbhjKH(J4X9tvpcQm8RmigeXKDDD9dAz9hPNmSxgzIByVkfzxatRKDDD9dAz9hPNmSxgzI72s2VOCmiptMCdzb4NV20Gk7KS9de6KDDD9dAz9hPNmSxgzIBiZPeXPhzpAhKJ0KSRRRFqlR)i9KH9YitCNP8CDStYQA6xyfh55v2111pOL1FKEYWEzKjUH28t8oYojRBi0nfazxxx)Gww)r6jd7LrM4UFQFqYUYUgQmWrGdiDRiHmqXPRJmuFMKHcajdUUMtg(vg84(RCyfXKDDD9dAnPb4hus2111pO1itC33Yzsj7666h0AKjU7N6humFYu5huQyaixvay96YmZJocClLyzkpxh7KSQM(fwXrEEzTEGanG2LqAILP8CDStYQA6xyfh55LLDdBozxxx)GwJmXnSAgHn1UoX8jtWTuILP8CDStYQA6xyfh55LDu2F0AwSbcKldODjKMyzkpxh7KSQM(fwXrEEzz3WMlIGGBPetpQz32A3SVayTEoLDDD9dAnYe3W0T0z8JGgZNmb3sjwMYZ1XojRQPFHvCKNxwRhiqUmG2LqAILP8CDStYQA6xyfh55LLDdBUiccULsm9OMDBRDZ(cG165u2111pO1itC7N2rKTM7iufZNmPNrjgiiwEUYv2TU3yIDu2F0YZOzXocClLyzkpxh7KSQM(fwXrEEzIbckY5qjZIDuYUUU(bTgzIB1dfqTwdRjGMjufZNmji4wkX0JA2TT2n7laMyGGKDDD9dAnYe3P)iy1mIy(Kj4wkXYuEUo2jzvn9lSIJ88Yok7pAnl2abYLb0UestSmLNRJDswvt)cR4ipVSSByZfrqWTuIPh1SBBTB2xaSwpNYUUU(bTgzIBhPPToxz1UsfZNmb3sjwMYZ1XojRQPFHvCKNx2rz)rRzXgiqUmG2LqAILP8CDStYQA6xyfh55LLDdBUiccULsm9OMDBRDZ(cG165u2111pO1itCd7qTtYw3RnEJ5tMGBPelt556yNKv10VWkoYZl7OS)O1Sydeixgq7sinXYuEUo2jzvn9lSIJ88YYUHnxebb3sjMEuZUT1UzFbWA9Ck7666h0AKjUBlz)IYXG8mzYxaXDeT2ZnK5S65CvmFYKbccULsSZnK5S65CLvqWTuI16bcKRYpOuXaqUQaW61LzMhfl6iWTuILP8CDStYQA6xyfh55L16JONrjgiiwMYZ1XojRQPFHvCKNx2rz)rRzrhnhLtGa5Q8dkvS6ZKTgBVUS8quMf7iccULsm9GenD9Xj7Jm2ki4wkXA9rmG2LqAILP8CDStYQA6xyfh55LLDdBoobcKldeeClLy6bjA66Jt2hzSvqWTuI16JyaTlH0elt556yNKv10VWkoYZll7g2CreeClLy6rn72w7M9faR1ZjqG1NjBnwXtMXdrj7666h0AKjU94E5xmFYKEgLyGGy6rn72w7M9fa7OS)O1SybiqUkxrOIbXp4JCJPJrihwrIi6zuIbcIbXp4JCJPJDu2F0AwSWPSRRRFqRrM4UTK9lkVX8jt6zuIbcIPh1SBBTB2xaSJY(JwZIfGa5QCfHkge)GpYnMogHCyfjIONrjgiige)GpYnMo2rz)rRzXcNYUUU(bTgzI7fcr9pcQDR7nM2y(KPTNukB5huQwgea)PG8ibpJocx6zuIbcIbRCbT1Cz2rz)rlpJokGa1ZOedeetpQz32A3SVayhL9hT8mwac0ne6(IyfTLDs28dfqXiKdRibNYUUU(bTgzIBy1mc7KSfaYsik3jMpzcULsSI2YojB(HcOyTEGa5sqWTuIPh1SBBTB2xaSwFedCdHUViwrBzNKn)qbumc5WksWPSRRRFqRrM4UVDFQZJGAHv(wX8jtgii4wkX0JA2TT2n7lawRpIbWTuIv0w2jzZpuafR1l7666h0AKjUVVVxr2hz3ExtX8jtgii4wkX0JA2TT2n7lawRpIbWTuIv0w2jzZpuafR1l7666h0AKjUHmNseNEK9ODqostX8jtgii4wkX0JA2TT2n7lawRpIbWTuIv0w2jzZpuafR1l7666h0AKjUtJUTKW6gcDFrwyYZX8jtgii4wkX0JA2TT2n7lawRpIbWTuIv0w2jzZpuafR1l7666h0AKjUpY7FeuBs5zAJ5tMmqqWTuIPh1SBBTB2xaSwFedGBPeROTStYMFOakwRx2111pO1itCRhKMq15fjSjLNPy(KjdeeClLy6rn72w7M9faR1hXa4wkXkAl7KS5hkGI16JiMIPhKMq15fjSjLNjlC7qSJY(Jwtrj7666h0AKjUlaKTHGNgsytZPPy(Kj4wkXosBSI21MMttSwVSRRRFqRrM4gAZpX7i7KSUHq3uaI5tM0ZOedeetpQz32A3SVayhL9hTMfDuYUUU(bTgzI7mLNRJDswvt)cR4ipVX8jtguUIqfdIFWh5gthJqoSIer0ZOedeetpQz32A3SVayhL9hTMbvlIWv9zYwJv8epJo2rbey5huQyaixvay96YmZJItzxxx)GwJmXDMYZ1XojRQPFHvCKN3y(KPYveQyq8d(i3y6yeYHvKiIEgLyGGyq8d(i3y6yhL9hTMbvlIWv9zYwJv8epJo2rbey5huQyaixvay96YmZJItzxxx)GwJmX91qwxx)GSQFRyqEMmbW1X8jtN)clfNqfZfILrCWV1k7666h0AKjUVgY666hKv9BfdYZKP0hNSLFqPkMpzA7jLYw(bLQLbbWFkipsWtou2111pO1itCFnK111piR63kgKNjtehq6wrX8jtCvUIqfl7766JyeYHvKis5huQyaixvay96YmEi2Ccey5huQyaixvay96YmZJs2111pO1itCFnK111piR63kgKNjt7JGQiB5huQKDLDDD9dAzehq6wrMwJBk12R(QOlMpz6COKzCCurGBPetqUq1XQDvMjgiOiWTuILP8CDStYQA6xyfh55Ljgiizxxx)GwgXbKUvKrM4(84ou6I5tMmaULsmb5cvhR2vzwRpcx6zuIbcIPh1SBBTB2xaSJY(JwZmhiqUkxrOIbXp4JCJPJrihwrIi6zuIbcIbXp4JCJPJDu2F0AM5CYPSRRRFqlJ4as3kYitCRh1SBBTB2xaX8jtgq7sinXYuEUo2jzvn9lSIJ88YYUHnhqGCb3sjwMYZ1XojRQPFHvCKNxwRhiq9mkXabXYuEUo2jzvn9lSIJ88Yok7pA5z0rXPSRRRFqlJ4as3kYitCdXp4JCJPlMpzYaAxcPjwMYZ1XojRQPFHvCKNxw2nS5acKl4wkXYuEUo2jzvn9lSIJ88YA9abQNrjgiiwMYZ1XojRQPFHvCKNx2rz)rlpJokoLDDD9dAzehq6wrgzIBb5cvhR2vzzxxx)GwgXbKUvKrM4gw5cAR5YX8jtga3sjwMYZ1XojRQPFHvCKNxwRpcClLyfTLDs28dfqXA9rohkzgpevedGBPetqUq1XQDvM16LDDD9dAzehq6wrgzIBTI84umFY02tkLT8dkvldcG)uqEKGNMl7666h0YioG0TImYe3RYZX8jtWTuIPV2c4rqT(UEtvSwFe4wkXYuEUo2jzvn9lSIJ88YedeKSRRRFqlJ4as3kYitCNNRCLDR7nMI5tMGBPeBItx)aHo2wU2ytMhPCfHkM4ixG8guafJqoSIeYUUU(bTmIdiDRiJmXnXbKUvumFYeClLyzkpxh7KSQM(fwXrEEzTEGaHBPetqUq1XQDvM16bcKl4wkXkAl7KS5hkGI16JONrjgiiwMYZ1XojRQPFHvCKNx2rz)rlpn8CiNYUUU(bTmIdiDRiJmX9eNU(bcDYUUU(bTmIdiDRiJmXnXbKUvKSRSRRRFqll9XjB5huQmTg3uQTx9vrxmFY05qjZ44OIWLbLRiuXeKluDSAxLzeYHvKaiq4wkXeKluDSAxLzIbcItzxxx)Gww6Jt2YpOuzKjUppUdLUy(KjUmOCfHkge)GpYnMogHCyfjacupJsmqqmi(bFKBmDSJY(JwZmNtzxxx)Gww6Jt2YpOuzKjU1JA2TT2n7lGy(Kjbb3sjMEuZUT1UzFbWedeKSRRRFqll9XjB5huQmYe3q8d(i3y6I5tMeeClLy6rn72w7M9fatmqqYUUU(bTS0hNSLFqPYitCdRCbT1C5y(Kj4wkXwie1)iO2TU3yAzIbckcxguUIqftqUq1XQDvMrihwrcGaHBPetqUq1XQDvMjgiioJWfxccULsm9OMDBRDZ(cGDu2F0YtoKf7ig4gcDFrSI2YojB(HcOyeYHvKGtGaHBPeROTStYMFOakwRNtzxxx)Gww6Jt2YpOuzKjUfKluDSAxLLDDD9dAzPpozl)GsLrM4wRipoj7666h0YsFCYw(bLkJmXnXbKUvumFYexguUIqftRipoXiKdRireXumbr9witdjw2rz)rRzMZjqGCb3sj22ecczfKxayh56ciq4wkX2AqKfa5xXoY1fNr4cULsSfcr9pcQDR7nMwwRhiq9mkXabXwie1)iO2TU3yAzhL9hT8mw4u2111pOLL(4KT8dkvgzI78CLRSBDVXumFYexguUIqftRipoXiKdRireXumbr9witdjw2rz)rRzMZjqGWTuITqiQ)rqTBDVX0YA9rGBPeBItx)aHo2wU2ytMhPCfHkM4ixG8guafJqoSIeYUUU(bTS0hNSLFqPYitCdbWFkipseZNmji4wkX0JA2TT2n7lawRhiqUGBPetFTfWJGA9D9MQyT(iLRiuXs0fFo7KSWEvkIrihwrcoLDDD9dAzPpozl)GsLrM4gcG)uqEKiMpzcULsmb5cvhR2vzwRhiWZHs8KJJs2111pOLL(4KT8dkvgzI7joD9de6KDDD9dAzPpozl)GsLrM4gcG)uqEKq2111pOLL(4KT8dkvgzI74VUMRJ9Alazxxx)Gww6Jt2YpOuzKjU)CpHepcQn(RR56i7k7666h0Ya4AthHeX8jthL9hTMzs0oV(bfRhfJhIWLbN)clfNqfZfIL16bceULsSfcr9pcQDR7nMwwRNtzxxx)GwgaxBKjUxJBk12R(QOlMpz6COKzCCur4spJsmqqmb5cvhR2vz2rz)rlp5bGanOCfHkMGCHQJv7QmJqoSIeCk7666h0Ya4AJmXTGCHQJv7QCmFYex6zuIbcIbRCbT1Cz2rz)rlp5yGalxrOIDEChkDmc5WkserpJsmqqSZJ7qPJDu2F0YtoMZiCPNrjgiiMEuZUT1UzFbWok7pAnZCGa5QCfHkge)GpYnMogHCyfjIONrjgiige)GpYnMo2rz)rRzMZjNYUUU(bTmaU2itCFEChkDX8jtCD(lSuCcvmxiwwRhiWZFHLItOI5cXYEepl)GsfR(mzRXkEIZiCPNrjgiiMEuZUT1UzFbWok7pAnZCGa5QCfHkge)GpYnMogHCyfjIONrjgiige)GpYnMo2rz)rRzMZjNYUUU(bTmaU2itCRh1SBBTB2xaX8jtN)clfNqfZfIL16bc88xyP4eQyUqSShXtomkGa568xyP4eQyUqSShXtZJks5kcvmhbLoB2rouktOIrihwrcoLDDD9dAzaCTrM4gIFWh5gtxmFY05VWsXjuXCHyzTEGap)fwkoHkMlel7r8KdJciqUo)fwkoHkMlel7r808OIuUIqfZrqPZMDKdLYeQyeYHvKGtzxxx)GwgaxBKjUHvUG2AUCmFYexccULsm9OMDBRDZ(cG16JC(lSuCcvmxiw2J4z5huQy1NjBnwXtCce45VWsXjuXCHyzT(iCXLGGBPetpQz32A3SVayhL9hT8KdzXoIbUHq3xeROTStYMFOakgHCyfj4eiq4wkXkAl7KS5hkGI165u2111pOLbW1gzI7joD9de6I5tMm48xyP4eQyUqSSwpqGCD(lSuCcvmxiwwRpIBi09fXw638RTq84eJqoSIeCk7666h0Ya4AJmXTwrECkMpzA7jLYw(bLQLbbWFkipsWtZLDDD9dAzaCTrM4M4as3kkMpzYGZFHLItOI5cXYA9abYLbLRiuX0kYJtmc5WksermftquVfY0qILDu2F0AM5CceiClLyBtiiKvqEbGDKRlzxxx)GwgaxBKjUZZvUYU19gtX8jtgC(lSuCcvmxiwwRhiqUmOCfHkMwrECIrihwrIiIPycI6TqMgsSSJY(JwZmNtzxxx)GwgaxBKjUHa4pfKhjI5tMo)fwkoHkMlelR1l7666h0Ya4AJmX9eNU(bcDYUUU(bTmaU2itCdbWFkipseZNmvUIqflrx85StYc7vPigHCyfjKDDD9dAzaCTrM4EvEoMpzYGYveQyj6IpNDswyVkfXiKdRiredo)fwkoHkMlelR1l7666h0Ya4AJmXD8xxZ1XETfGSRRRFqldGRnYe3FUNqIhb1g)11CDKDLDDD9dAz7JGQiB5huQmDeseZNmDu2F0AMjr786huSEumEiIGGBPetpQz32A3SVayIbcs2111pOLTpcQISLFqPYitCVg3uQTx9vrxmFY05qjZ44OIa3sjMGCHQJv7QmtmqqrGBPelt556yNKv10VWkoYZltmqqYUUU(bTS9rqvKT8dkvgzI7ZJ7qPlMpzYa4wkXeKluDSAxLzT(iCPNrjgiiMEuZUT1UzFbWok7pAnZCGa5QCfHkge)GpYnMogHCyfjIONrjgiige)GpYnMo2rz)rRzMZjNYUUU(bTS9rqvKT8dkvgzIB9OMDBRDZ(cq2111pOLTpcQISLFqPYitCdXp4JCJPt2111pOLTpcQISLFqPYitClixO6y1Ukl7666h0Y2hbvr2YpOuzKjUjoG0TII5tMGBPeBBcbHScYlaSJCDj7666h0Y2hbvr2YpOuzKjUHvUG2AUCmFYKEgLyGGy55kxz36EJj2rz)rBeUmOCfHkMGCHQJv7QmJqoSIeabc3sjMGCHQJv7QmtmqqCgHlUeeClLy6rn72w7M9faR1hXa3qO7lIv0w2jzZpuafJqoSIeCceiClLyfTLDs28dfqXA9CgbULsSmLNRJDswvt)cR4ipVmXabf5COKzCyuYUUU(bTS9rqvKT8dkvgzIBTI84umFY02tkLT8dkvldcG)uqEKGNMl7666h0Y2hbvr2YpOuzKjUN401pqOlMpzIRZHsMXdrfbULsSmLNRJDswvt)cR4ipVSwFebb3sjMEuZUT1UzFbWA9CceixNdLmJJgve4wkXYuEUo2jzvn9lSIJ88YedeeNYUUU(bTS9rqvKT8dkvgzI78CLRSBDVXKSRRRFqlBFeufzl)GsLrM4gcG)uqEKiMpzQCfHkwIU4ZzNKf2Rsrmc5WkseHl4wkXYuEUo2jzvn9lSIJ88YA9abki4wkX0JA2TT2n7lawRhiq4wkXeKluDSAxLzTEoLDDD9dAz7JGQiB5huQmYe3tC66hi0j7666h0Y2hbvr2YpOuzKjUHa4pfKhjI5tMkxrOILOl(C2jzH9QueJqoSIer4cULsSI2YojB(HcOyTEGafeClLy6rn72w7M9fatmqqrGBPeROTStYMFOakMyGGICouINCCuCk7666h0Y2hbvr2YpOuzKjUxLNJ5tMmOCfHkwIU4ZzNKf2Rsrmc5Wksi7666h0Y2hbvr2YpOuzKjUJ)6AUo2RTaKDDD9dAz7JGQiB5huQmYe3FUNqIhb1g)11CDWGBpPX8XrJgx4cJb]] )


end
