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


    spec:RegisterPack( "Arms", 20200210, [[dCuzfbqikjpcufBsu8jqvrnkkrNIsyvusLYRiunlrvDljPYUq5xGkdJsLJjk1YeL8mjPmnkPQRjQITrjL(MKu14avvNJsQyDGQsMhLQUhLY(evPdkjrlKq8qqvrUOKeyJusL4KssOvkjMjOQuTtc0qbvfwkOQuEkitLaUkLuPARssqFLsQK2lK)sXGf5Wclwv9ysMmrxgzZu5ZQsJwvCAGvtjfVMqz2K62u1UH63kgUKA5Q8CLMUuxxITti9Dqz8ss68IkRhuLMpbTFunkBKaiiz0esWSSll7SlRSQgZo4ppwNQzTiOoxnHGQdLyXlHGWHNqqv55xeuDKtpHejacANYPie0t31l8fCW9c6NYNPgpClWx0rdgS6cxd3c8k4qq)cq3vrm6JGKrtibZYUSSZUSYQAm7G)8yDQw2iOO0pZHGGa(IoAWGHpDHRrqpaPKWOpcssRcbbp8uvE(LNSUg3bMJxbE4PNURx4l4G7f0pLptnE4wGVOJgmy1fUgUf4vWXRap8K1f6FL4YXtzBx(8uw2LLD8k8kWdpbF6jWV0cFXRap8u1XtvPussEc(O49KMXRap8u1XtvPussEQkeO65YXtW3k7dCvrFnHLa8lpvfcu9C5y8kWdpvD8uvkLKKNej6wt8e0ZuAEQhEQ(i14)rZtvj8b8DgVc8WtvhpvfuvsvAWGPd(8YtWhhPalyW8ey5jjPPMKmEf4HNQoEQkLssYtw3xINQIn5xgcsd2ErcGGwa(vtMoUxQrcGemBKaiichFnjrIGGuhOPdeiOJ8baV8K924jz5IgmyEY6gpzhRA8ugEss)IZXuJE2TSM1h7dtoWWiOq1GbJGoclrnsWSqcGGiC81KejccsDGMoqGGU4L4j75jR1oEkdp9lohtsHuNZOcTNjhyyEkdp9lohZt(5YzgNrxuaPrEu4xMCGHrqHQbdgbTIv06Twd6MouJeSAibqqeo(AsIebbPoqthiqqwXt)IZXKui15mQq7zLAEkdpzjpPMrlhyyMA0ZUL1S(yFyh5daE5j75PS4jHc5jl5Po0eUzWI7FuigDmchFnj5Pm8KAgTCGHzWI7FuigDSJ8baV8K98uw8Kf8KfiOq1GbJGUq04LouJe06rcGGcvdgmcsn6z3YAwFSpiichFnjrIGAKG5bjackunyWiiyX9pkeJoeeHJVMKirqnsqRfjackunyWiijfsDoJk0EeeHJVMKirqnsWQhjacIWXxtsKiii1bA6abc6xCo2wKscBKu0pSJcvJGcvdgmcIQkPknHAKGWpsaeeHJVMKirqqQd00bceKAgTCGHz(56qB2(aIrSJ8baV8ugEYsEYkEQdnHBMKcPoNrfApJWXxtsEsOqE6xCoMKcPoNrfAptoWW8Kf8ugEYsEYsEss)IZXuJE2TSM1h7dRuZtz4jR4PaEPd0eRPTnJZ4bVpnJWXxtsEYcEsOqE6xCowtBBgNXdEFAwPMNSGNYWt)IZX8KFUCMXz0ffqAKhf(LjhyyEkdpDXlXt2ZtwVDiOq1GbJG(6qsBpNh1ibToibqqeo(AsIebbPoqthiqqBnP1MoUxQxgShWPHbWsEkV8uwiOq1GbJGuAkeLqnsWSTdjacIWXxtsKiii1bA6abcYsE6IxINSNNQMD8ugE6xCoMN8ZLZmoJUOasJ8OWVSsnpLHNK0V4Cm1ONDlRz9X(Wk18Kf8KqH8KL80fVepzppv92Xtz4PFX5yEYpxoZ4m6IcinYJc)YKdmmpzbckunyWiOru6Qhy0HAKGzNnsaeuOAWGrq(56qB2(aIriichFnjrIGAKGzNfsaeeHJVMKirqqQd00bceuhAc3mhDIoNzCMF0TMyeo(AsYtz4jl5PFX5yEYpxoZ4m6IcinYJc)Yk18KqH8KK(fNJPg9SBznRp2hwPMNekKN(fNJjPqQZzuH2Zk18KfiOq1GbJGG9aonmawIAKGzxnKaiOq1GbJGgrPREGrhcIWXxtsKiOgjy2wpsaeeHJVMKirqqQd00bceuhAc3mhDIoNzCMF0TMyeo(AsYtz4jl5PFX5ynTTzCgp49PzLAEsOqEss)IZXuJE2TSM1h7dtoWW8ugE6xCowtBBgNXdEFAMCGH5Pm80fVepLxEYATJNSabfQgmyeeShWPHbWsuJem78Geabr44RjjseeK6anDGabzfp1HMWnZrNOZzgN5hDRjgHJVMKiOq1GbJGwD4rnsWSTwKaiOq1GbJGefO65YzUY(GGiC81KejcQrcMD1JeabfQgmyeeWxtyja)AefO65YHGiC81KejcQrncssUOOBKaibZgjackunyWii1tCVecIWXxtsKiOgjywibqqHQbdgbvx8EsJGiC81KejcQrcwnKaiichFnjrIGGuhOPdeiOoUxQzpuO7hwTQ5j75PSYMNYWt)IZX8KFUCMXz0ffqAKhf(LvQ5jHc5jR4jAxcRiMN8ZLZmoJUOasJ8OWVmFynZHGcvdgmcQEAWGrnsqRhjacIWXxtsKiii1bA6abc6xCoMN8ZLZmoJUOasJ8OWVSJ8baV8K98uE4jHc5jl5jR4jAxcRiMN8ZLZmoJUOasJ8OWVmFynZXtz4jj9lohtn6z3YAwFSpSsnpzbckunyWiOVEgPXvUCOgjyEqcGGiC81KejccsDGMoqGG(fNJ5j)C5mJZOlkG0ipk8lRuZtcfYtwYtwXt0Uewrmp5NlNzCgDrbKg5rHFz(WAMJNYWts6xCoMA0ZUL1S(yFyLAEYceuOAWGrqF6w6edGFrnsqRfjacIWXxtsKiii1bA6abcsnJwoWWm)CDOnBFaXi2r(aGxEkV8u2S8Wtz4PFX5yEYpxoZ4m6IcinYJc)YKdmmpLHNU4L4j75P8yhckunyWiO4ubMm9ChHBuJeS6rcGGiC81KejccsDGMoqGGK0V4Cm1ONDlRz9X(WKdmmpLHN(fNJ5j)C5mJZOlkG0ipk8ltoWW8ugEsnJwoWWm)CDOnBFaXi2r(aGxeuOAWGrqAW7tVgRPiF9eUrnsq4hjacIWXxtsKiii1bA6abc6xCoMN8ZLZmoJUOasJ8OWVSJ8baV8K98uE4jHc5jl5jR4jAxcRiMN8ZLZmoJUOasJ8OWVmFynZXtz4jj9lohtn6z3YAwFSpSsnpzbckunyWiih4OVEgjQrcADqcGGiC81KejccsDGMoqGG(fNJ5j)C5mJZOlkG0ipk8l7iFaWlpzppLhEsOqEYsEYkEI2LWkI5j)C5mJZOlkG0ipk8lZhwZC8ugEss)IZXuJE2TSM1h7dRuZtwGGcvdgmckWkA7l0gvO1Ogjy22Heabr44RjjseeK6anDGabjPFX5yQrp7wwZ6J9HjhyyEkdp9lohZt(5YzgNrxuaPrEu4xMCGH5Pm8KAgTCGHz(56qB2(aIrSJ8baViOq1GbJG(XRzCM(akXwuJem7SrcGGiC81KejcckunyWiOyFenW0AUaENZOMl0ii1bA6abcYkEss)IZXUaENZOMl0gj9lohRuZtcfYtwYtDCVuZEOq3pSAvZt2ZtzzhlBEkdp9lohZt(5YzgNrxuaPrEu4xwPMNYWtQz0YbgM5j)C5mJZOlkG0ipk8l7iFaWlpzppLD2vppzbpjuipzjp1X9snRbEY0JPw1MQzhpzppLhEkdpjPFX5yQbllQgikzayXms6xCowPMNYWtwXt0Uewrmp5NlNzCgDrbKg5rHFz(WAMJNSGNekKNSKNSINK0V4Cm1GLfvdeLmaSygj9lohRuZtz4jR4jAxcRiMN8ZLZmoJUOasJ8OWVmFynZXtz4jj9lohtn6z3YAwFSpSsnpzbpjuip1apz6Xibepzppvn7qq4WtiOyFenW0AUaENZOMl0Ogjy2zHeabr44RjjseeK6anDGabPMrlhyyMA0ZUL1S(yFyh5daE5j75j4NNekKNSKN6qt4MblU)rHy0XiC81KKNYWtQz0YbgMblU)rHy0XoYha8Yt2ZtWppzbckunyWiOq0OJd1ibZUAibqqeo(AsIebbPoqthiqqQz0YbgMPg9SBznRp2h2r(aGxEYEEc(5jHc5jl5Po0eUzWI7FuigDmchFnj5Pm8KAgTCGHzWI7FuigDSJ8baV8K98e8ZtwGGcvdgmcQSKb0KFrnsWSTEKaiichFnjrIGGuhOPdeiOTM0Ath3l1ld2d40WayjpLxEkBEkdpzjpPMrlhyy2xhsA758SJ8baV8uE5PSTJNekKNuZOLdmmtn6z3YAwFSpSJ8baV8uE5j4NNekKNc4LoqtSM22moJh8(0mchFnj5jlqqHQbdgbTWiQgGFnBFaXOf1ibZopibqqeo(AsIebbPoqthiqq)IZXAABZ4mEW7tZk18KqH8KL8KK(fNJPg9SBznRp2hwPMNYWtwXtb8shOjwtBBgNXdEFAgHJVMK8KfiOq1GbJG(6zKMXz6hYqyYNd1ibZ2ArcGGiC81KejccsDGMoqGGSINK0V4Cm1ONDlRz9X(Wk18ugEYkE6xCowtBBgNXdEFAwPgbfQgmyeuD5aUCa8R5RJTrnsWSREKaiichFnjrIGGuhOPdeiiR4jj9lohtn6z3YAwFSpSsnpLHNSIN(fNJ102MXz8G3NMvQrqHQbdgbDG6AnzayZwhkc1ibZg(rcGGiC81KejccsDGMoqGGSINK0V4Cm1ONDlRz9X(Wk18ugEYkE6xCowtBBgNXdEFAwPgbfQgmyeeS50srja2C0o4aRiuJemBRdsaeeHJVMKirqqQd00bceKv8KK(fNJPg9SBznRp2hwPMNYWtwXt)IZXAABZ4mEW7tZk1iOq1GbJGCJQSK0eWlDGMmFk8Ogjyw2Heabr44RjjseeK6anDGabzfpjPFX5yQrp7wwZ6J9HvQ5Pm8Kv80V4CSM22moJh8(0SsnckunyWiOJIAa(140HNwuJemRSrcGGiC81KejccsDGMoqGGSINK0V4Cm1ONDlRz9X(Wk18ugEYkE6xCowtBBgNXdEFAwPMNYWtYPzQbRiCFrtsJthEY8lhMDKpa4LNSXt2HGcvdgmcsnyfH7lAsAC6WtOgjywzHeabr44RjjseeK6anDGab9loh7iLyAAxJBofXk1iOq1GbJG6hYuW)PGLg3Ckc1ibZQAibqqeo(AsIebbPoqthiqqQz0YbgMPg9SBznRp2h2r(aGxEYEEkB7qqHQbdgb9wItccSzCMaEPB6huJemlRhjacIWXxtsKiii1bA6abcYkEQdnHBgS4(hfIrhJWXxtsEkdpPMrlhyyMA0ZUL1S(yFyh5daE5j75PxLKNYWtwYtnWtMEmsaXt5LNYop2XtcfYtDCVuZEOq3pSAvZt2ZtzzhpzbckunyWiip5NlNzCgDrbKg5rHFrnsWSYdsaeeHJVMKirqqQd00bceuhAc3myX9pkeJogHJVMK8ugEsnJwoWWmyX9pkeJo2r(aGxEYEE6vj5Pm8KL8ud8KPhJeq8uE5PSZJD8KqH8uh3l1Shk09dRw18K98uw2XtwGGcvdgmcYt(5YzgNrxuaPrEu4xuJemlRfjacIWXxtsKiii1bA6abcARjT20X9s9YG9aonmawYt5LNSEeuOAWGrqxbBcvdgSrd2gbPbBBWHNqqoGOKPJ7LAuJemRQhjacIWXxtsKiii1bA6abcYsEQdnHBMp2nuhXiC81KKNYWtDCVuZEOq3pSAvZt2Ztvlp8Kf8KqH8uh3l1Shk09dRw18K98uw2HGcvdgmc6kytOAWGnAW2iinyBdo8ecIQkPknHAKGzb)ibqqeo(AsIebbfQgmye0vWMq1GbB0GTrqAW2gC4je0cWVAY0X9snQrncQ(i14)rJeajy2ibqqHQbdgb9JU1KzFMsJGiC81KejcQrcMfsaeeHJVMKirqq4WtiOaE3N4I14gCBgNPEGrhckunyWiOaE3N4I14gCBgNPEGrhQrcwnKaiOq1GbJGGnNwkkbWMJ2bhyfHGiC81KejcQrcA9ibqqHQbdgb5j)C5mJZOlkG0ipk8lcIWXxtsKiOgjyEqcGGcvdgmc6TeNeeyZ4mb8s30piichFnjrIGAKGwlsaeuOAWGrq1tdgmcIWXxtsKiOg1iiQQKQ0esaKGzJeabr44RjjseeK6anDGabDXlXt2ZtwRD8ugE6xCoMKcPoNrfAptoWW8ugE6xCoMN8ZLZmoJUOasJ8OWVm5adJGcvdgmcAfRO1BTg0nDOgjywibqqeo(AsIebbPoqthiqqwXt)IZXKui15mQq7zLAEkdpzjpPMrlhyyMA0ZUL1S(yFyh5daE5j75PS4jHc5jl5Po0eUzWI7FuigDmchFnj5Pm8KAgTCGHzWI7FuigDSJ8baV8K98uw8Kf8KfiOq1GbJGUq04LouJeSAibqqeo(AsIebbPoqthiqqwXt0Uewrmp5NlNzCgDrbKg5rHFz(WAMJNekKNSKN(fNJ5j)C5mJZOlkG0ipk8lRuZtcfYtQz0YbgM5j)C5mJZOlkG0ipk8l7iFaWlpLxEkB74jlqqHQbdgbPg9SBznRp2huJe06rcGGiC81KejccsDGMoqGGSINODjSIyEYpxoZ4m6IcinYJc)Y8H1mhpjuipzjp9lohZt(5YzgNrxuaPrEu4xwPMNekKNuZOLdmmZt(5YzgNrxuaPrEu4x2r(aGxEkV8u22XtwGGcvdgmccwC)JcXOd1ibZdsaeuOAWGrqskK6CgvO9iichFnjrIGAKGwlsaeeHJVMKirqqQd00bceKv80V4Cmp5NlNzCgDrbKg5rHFzLAEkdp9lohRPTnJZ4bVpnRuZtz4PlEjEYEEQA2Xtz4jR4PFX5yskK6CgvO9SsnckunyWiOVoK02Z5rnsWQhjacIWXxtsKiii1bA6abcARjT20X9s9YG9aonmawYt5LNYcbfQgmyeKstHOeQrcc)ibqqeo(AsIebbPoqthiqq)IZXuxzFa4xtSBu0nRuZtz4PFX5yEYpxoZ4m6IcinYJc)YKdmmckunyWiOvhEuJe06Geabr44RjjseeK6anDGab9lohBeLU6bgDSTdLy8KnEklEkdp1HMWntEuiXr59Pzeo(AsIGcvdgmcYpxhAZ2hqmc1ibZ2oKaiichFnjrIGGuhOPdeiOFX5yEYpxoZ4m6IcinYJc)Yk18KqH80V4CmjfsDoJk0EwPMNekKNSKN(fNJ102MXz8G3NMvQ5Pm8KAgTCGHzEYpxoZ4m6IcinYJc)YoYha8Yt5LNSowppzbckunyWiiQQKQ0eQrcMD2ibqqHQbdgbnIsx9aJoeeHJVMKirqnsWSZcjackunyWiiQQKQ0ecIWXxtsKiOg1iihquY0X9snsaKGzJeabr44RjjseeK6anDGabDXlXt2ZtwRD8ugEYsEYkEQdnHBMKcPoNrfApJWXxtsEsOqE6xCoMKcPoNrfAptoWW8KfiOq1GbJGwXkA9wRbDthQrcMfsaeeHJVMKirqqQd00bceKL8Kv8uhAc3myX9pkeJogHJVMK8KqH8KAgTCGHzWI7FuigDSJ8baV8K98uw8KfiOq1GbJGUq04LouJeSAibqqeo(AsIebbPoqthiqqs6xCoMA0ZUL1S(yFyYbggbfQgmyeKA0ZUL1S(yFqnsqRhjacIWXxtsKiii1bA6abcss)IZXuJE2TSM1h7dtoWWiOq1GbJGGf3)Oqm6qnsW8Geabr44RjjseeK6anDGab9lohBHruna)A2(aIrltoWW8ugEYsEYkEQdnHBMKcPoNrfApJWXxtsEsOqE6xCoMKcPoNrfAptoWW8Kf8ugEYsEYsEss)IZXuJE2TSM1h7d7iFaWlpLxEY6z5HNYWtwXtb8shOjwtBBgNXdEFAgHJVMK8Kf8KqH80V4CSM22moJh8(0SsnpzbckunyWiOVoK02Z5rnsqRfjackunyWiijfsDoJk0EeeHJVMKirqnsWQhjackunyWiiLMcrjeeHJVMKirqnsq4hjacIWXxtsKiii1bA6abcYsEYkEQdnHBMstHOeJWXxtsEkdpjNMjjQ2aBky5YoYha8Yt2ZtzXtwWtcfYtwYt)IZX2IusyJKI(HDuOAEsOqE6xCo22dMmpuCn7Oq18Kf8ugEYsE6xCo2cJOAa(1S9beJwwPMNekKNuZOLdmmBHruna)A2(aIrl7iFaWlpLxEc(5jlqqHQbdgbrvLuLMqnsqRdsaeeHJVMKirqqQd00bceKL8Kv8uhAc3mLMcrjgHJVMK8ugEsontsuTb2uWYLDKpa4LNSNNYINSGNekKN(fNJTWiQgGFnBFaXOLvQ5Pm80V4CSru6Qhy0X2ouIXt24PS4Pm8uhAc3m5rHehL3NMr44RjjckunyWii)CDOnBFaXiuJemB7qcGGiC81KejccsDGMoqGGK0V4Cm1ONDlRz9X(Wk18KqH8KL80V4Cm1v2ha(1e7gfDZk18ugEQdnHBMJorNZmoZp6wtmchFnj5jlqqHQbdgbb7bCAyaSe1ibZoBKaiichFnjrIGGuhOPdeiOFX5yskK6CgvO9SsnpjuipDXlXt5LNSw7qqHQbdgbb7bCAyaSe1ibZolKaiOq1GbJGgrPREGrhcIWXxtsKiOgjy2vdjackunyWiiypGtddGLiichFnjrIGAKGzB9ibqqHQbdgbjkq1ZLZCL9bbr44RjjseuJem78GeabfQgmyeeWxtyja)AefO65YHGiC81KejcQrnQrqIs3cgmsWSSll7Sll7YdccwCya(DrqvrF9Cnj5P8WtHQbdMN0GTxgVccQ(ghqtii4HNQYZV8K114oWC8kWdp90D9cFbhCVG(P8zQXd3c8fD0GbRUW1WTaVcoEf4HNSUq)RexoEkB7YNNYYUSSJxHxbE4j4tpb(Lw4lEf4HNQoEQkLssYtWhfVN0mEf4HNQoEQkLssYtvHavpxoEc(wzFGRk6RjSeGF5PQqGQNlhJxbE4PQJNQsPKK8Kir3AINGEMsZt9Wt1hPg)pAEQkHpGVZ4vGhEQ64PQGQsQsdgmDWNxEc(4ifybdMNalpjjn1KKXRap8u1XtvPussEY6(s8uvSj)Y4v4vGhEQkOQKQ0KKN(KBoINuJ)hnp9PxaEz8uvQuuDV8eEWv3tCExrZtHQbdE5PbRZX4vGhEkunyWlR(i14)rBZPJvmEf4HNcvdg8YQpsn(F0IBdo3msEf4HNcvdg8YQpsn(F0IBdUO86jChnyW8kWdpbHJ69zAE6cGKN(fNJK802rV80NCZr8KA8)O5Pp9cWlpfyjpvFu1vpDdWV8ey5j5GjgVsOAWGxw9rQX)JwCBW9JU1KzFMsZReQgm4LvFKA8)Of3gCLLmGM85JdpzlG39jUynUb3MXzQhy0XReQgm4LvFKA8)Of3gCWMtlfLayZr7GdSI4vcvdg8YQpsn(F0IBdop5NlNzCgDrbKg5rHF5vcvdg8YQpsn(F0IBdU3sCsqGnJZeWlDt)WReQgm4LvFKA8)Of3gC1tdgmVcVc8WtvbvLuLMK8ejkD54Pg4jEQFiEku9C8ey5Pq0aOJVMy8kHQbdETPEI7L4vcvdg8kUn4QlEpP5vcvdg8kUn4QNgm48boBDCVuZEOq3pSAvBFwzN5xCoMN8ZLZmoJUOasJ8OWVSsTqHwr7syfX8KFUCMXz0ffqAKhf(L5dRzoELq1GbVIBdUVEgPXvUC5dC2(fNJ5j)C5mJZOlkG0ipk8l7iFaWR95rOqlTI2LWkI5j)C5mJZOlkG0ipk8lZhwZCzK0V4Cm1ONDlRz9X(Wk1wWReQgm4vCBW9PBPtma(nFGZ2V4Cmp5NlNzCgDrbKg5rHFzLAHcT0kAxcRiMN8ZLZmoJUOasJ8OWVmFynZLrs)IZXuJE2TSM1h7dRuBbVsOAWGxXTbxCQatMEUJWD(aNn1mA5adZ8Z1H2S9beJyh5daEZB2S8K5xCoMN8ZLZmoJUOasJ8OWVm5adN5IxY(8yhVsOAWGxXTbNg8(0RXAkYxpH78boBs6xCoMA0ZUL1S(yFyYbgoZV4Cmp5NlNzCgDrbKg5rHFzYbgoJAgTCGHz(56qB2(aIrSJ8baV8kHQbdEf3gCoWrF9mY8boB)IZX8KFUCMXz0ffqAKhf(LDKpa41(8iuOLwr7syfX8KFUCMXz0ffqAKhf(L5dRzUms6xCoMA0ZUL1S(yFyLAl4vcvdg8kUn4cSI2(cTrfAD(aNTFX5yEYpxoZ4m6IcinYJc)YoYha8AFEek0sRODjSIyEYpxoZ4m6IcinYJc)Y8H1mxgj9lohtn6z3YAwFSpSsTf8kHQbdEf3gC)41motFaLyB(aNnj9lohtn6z3YAwFSpm5adN5xCoMN8ZLZmoJUOasJ8OWVm5adNrnJwoWWm)CDOnBFaXi2r(aGxELq1GbVIBdUYsgqt(8XHNSf7JObMwZfW7Cg1CHoFGZMvs6xCo2fW7Cg1CH2iPFX5yLAHcTSJ7LA2df6(HvRA7ZYow2z(fNJ5j)C5mJZOlkG0ipk8lRuNrnJwoWWmp5NlNzCgDrbKg5rHFzh5daETp7SRElek0YoUxQznWtMEm1Q2un7SppzK0V4Cm1GLfvdeLmaSygj9lohRuNXkAxcRiMN8ZLZmoJUOasJ8OWVmFynZzHqHwALK(fNJPgSSOAGOKbGfZiPFX5yL6mwr7syfX8KFUCMXz0ffqAKhf(L5dRzUms6xCoMA0ZUL1S(yFyLAlekSbEY0Jrci7RMD8kHQbdEf3gCHOrhx(aNn1mA5adZuJE2TSM1h7d7iFaWR9WVqHw2HMWndwC)JcXOJr44Rjzg1mA5adZGf3)Oqm6yh5daETh(TGxjunyWR42GRSKb0KFZh4SPMrlhyyMA0ZUL1S(yFyh5daETh(fk0Yo0eUzWI7FuigDmchFnjZOMrlhyygS4(hfIrh7iFaWR9WVf8kHQbdEf3gClmIQb4xZ2hqmAZh4ST1KwB64EPEzWEaNggalZB2zSunJwoWWSVoK02Z5zh5daEZB22juOAgTCGHzQrp7wwZ6J9HDKpa4nVWVqHb8shOjwtBBgNXdEFAgHJVMKwWReQgm4vCBW91ZinJZ0pKHWKpx(aNTFX5ynTTzCgp49PzLAHcTus)IZXuJE2TSM1h7dRuNXQaEPd0eRPTnJZ4bVpnJWXxtsl4vcvdg8kUn4QlhWLdGFnFDSD(aNnRK0V4Cm1ONDlRz9X(Wk1zS6xCowtBBgNXdEFAwPMxjunyWR42G7a11AYaWMTouu(aNnRK0V4Cm1ONDlRz9X(Wk1zS6xCowtBBgNXdEFAwPMxjunyWR42Gd2CAPOeaBoAhCGvu(aNnRK0V4Cm1ONDlRz9X(Wk1zS6xCowtBBgNXdEFAwPMxjunyWR42GZnQYsstaV0bAY8PWNpWzZkj9lohtn6z3YAwFSpSsDgR(fNJ102MXz8G3NMvQ5vcvdg8kUn4okQb4xJthEAZh4SzLK(fNJPg9SBznRp2hwPoJv)IZXAABZ4mEW7tZk18kHQbdEf3gCQbRiCFrtsJthEkFGZMvs6xCoMA0ZUL1S(yFyL6mw9lohRPTnJZ4bVpnRuNrontnyfH7lAsAC6WtMF5WSJ8baV2SJxjunyWR42GRFitb)NcwACZPO8boB)IZXosjMM214MtrSsnVsOAWGxXTb3BjojiWMXzc4LUPFYh4SPMrlhyyMA0ZUL1S(yFyh5daETpB74vcvdg8kUn48KFUCMXz0ffqAKhf(nFGZMvDOjCZGf3)Oqm6yeo(AsMrnJwoWWm1ONDlRz9X(WoYha8A)RsMXYg4jtpgjGYB25XoHc74EPM9qHUFy1Q2(SSZcELq1GbVIBdop5NlNzCgDrbKg5rHFZh4S1HMWndwC)JcXOJr44Rjzg1mA5adZGf3)Oqm6yh5daET)vjZyzd8KPhJeq5n78yNqHDCVuZEOq3pSAvBFw2zbVsOAWGxXTb3vWMq1GbB0GTZhhEYMdikz64EPoFGZ2wtATPJ7L6Lb7bCAyaSmVwpVsOAWGxXTb3vWMq1GbB0GTZhhEYgvvsvAkFGZMLDOjCZ8XUH6igHJVMKz64EPM9qHUFy1Q2(QLhlekSJ7LA2df6(HvRA7ZYoELq1GbVIBdURGnHQbd2ObBNpo8KTfGF1KPJ7LAEfELq1GbVmQQKQ0KTvSIwV1Aq30LpWz7IxYER1Um)IZXKui15mQq7zYbgoZV4Cmp5NlNzCgDrbKg5rHFzYbgMxjunyWlJQkPknjUn4Uq04LU8boBw9lohtsHuNZOcTNvQZyPAgTCGHzQrp7wwZ6J9HDKpa41(Sek0Yo0eUzWI7FuigDmchFnjZOMrlhyygS4(hfIrh7iFaWR9zzHf8kHQbdEzuvjvPjXTbNA0ZUL1S(yFYh4SzfTlHveZt(5YzgNrxuaPrEu4xMpSM5ek0YFX5yEYpxoZ4m6IcinYJc)Yk1cfQMrlhyyMN8ZLZmoJUOasJ8OWVSJ8baV5nB7SGxjunyWlJQkPknjUn4Gf3)Oqm6Yh4SzfTlHveZt(5YzgNrxuaPrEu4xMpSM5ek0YFX5yEYpxoZ4m6IcinYJc)Yk1cfQMrlhyyMN8ZLZmoJUOasJ8OWVSJ8baV5nB7SGxjunyWlJQkPknjUn4Kui15mQq75vcvdg8YOQsQstIBdUVoK02Z5Zh4Sz1V4Cmp5NlNzCgDrbKg5rHFzL6m)IZXAABZ4mEW7tZk1zU4LSVA2LXQFX5yskK6CgvO9SsnVsOAWGxgvvsvAsCBWP0uikLpWzBRjT20X9s9YG9aonmawM3S4vcvdg8YOQsQstIBdUvh(8boB)IZXuxzFa4xtSBu0nRuN5xCoMN8ZLZmoJUOasJ8OWVm5adZReQgm4LrvLuLMe3gC(56qB2(aIr5dC2(fNJnIsx9aJo22HsmBzLPdnHBM8OqIJY7tZiC81KKxjunyWlJQkPknjUn4OQsQst5dC2(fNJ5j)C5mJZOlkG0ipk8lRulu4V4CmjfsDoJk0EwPwOql)fNJ102MXz8G3NMvQZOMrlhyyMN8ZLZmoJUOasJ8OWVSJ8baV516y9wWReQgm4LrvLuLMe3gCJO0vpWOJxjunyWlJQkPknjUn4OQsQst8k8kHQbdEzoGOKPJ7LABRyfTER1GUPlFGZ2fVK9wRDzS0Qo0eUzskK6CgvO9mchFnjfk8xCoMKcPoNrfAptoWWwWReQgm4L5aIsMoUxQf3gCxiA8sx(aNnlTQdnHBgS4(hfIrhJWXxtsHcvZOLdmmdwC)JcXOJDKpa41(SSGxjunyWlZbeLmDCVulUn4uJE2TSM1h7t(aNnj9lohtn6z3YAwFSpm5adZReQgm4L5aIsMoUxQf3gCWI7FuigD5dC2K0V4Cm1ONDlRz9X(WKdmmVsOAWGxMdikz64EPwCBW91HK2EoF(aNTFX5ylmIQb4xZ2hqmAzYbgoJLw1HMWntsHuNZOcTNr44RjPqH)IZXKui15mQq7zYbg2ImwAPK(fNJPg9SBznRp2h2r(aG38A9S8KXQaEPd0eRPTnJZ4bVpnJWXxtslek8xCowtBBgNXdEFAwP2cELq1GbVmhquY0X9sT42GtsHuNZOcTNxjunyWlZbeLmDCVulUn4uAkeL4vcvdg8YCarjth3l1IBdoQQKQ0u(aNnlTQdnHBMstHOeJWXxtYmYPzsIQnWMcwUSJ8baV2NLfcfA5V4CSTiLe2iPOFyhfQwOWFX5yBpyY8qX1SJcvBrgl)fNJTWiQgGFnBFaXOLvQfkunJwoWWSfgr1a8Rz7digTSJ8baV5f(TGxjunyWlZbeLmDCVulUn48Z1H2S9beJYh4SzPvDOjCZuAkeLyeo(AsMrontsuTb2uWYLDKpa41(SSqOWFX5ylmIQb4xZ2hqmAzL6m)IZXgrPREGrhB7qjMTSY0HMWntEuiXr59Pzeo(AsYReQgm4L5aIsMoUxQf3gCWEaNggalZh4SjPFX5yQrp7wwZ6J9HvQfk0YFX5yQRSpa8Rj2nk6MvQZ0HMWnZrNOZzgN5hDRjgHJVMKwWReQgm4L5aIsMoUxQf3gCWEaNggalZh4S9lohtsHuNZOcTNvQfk8IxkVwRD8kHQbdEzoGOKPJ7LAXTb3ikD1dm64vcvdg8YCarjth3l1IBdoypGtddGL8kHQbdEzoGOKPJ7LAXTbNOavpxoZv2hELq1GbVmhquY0X9sT42Gd4RjSeGFnIcu9C54v4vcvdg8Ywa(vtMoUxQTDewMpWz7iFaWR92KLlAWGTUzhRAzK0V4Cm1ONDlRz9X(WKdmmVsOAWGx2cWVAY0X9sT42GBfRO1BTg0nD5dC2U4LS3ATlZV4CmjfsDoJk0EMCGHZ8lohZt(5YzgNrxuaPrEu4xMCGH5vcvdg8Ywa(vtMoUxQf3gCxiA8sx(aNnR(fNJjPqQZzuH2Zk1zSunJwoWWm1ONDlRz9X(WoYha8AFwcfAzhAc3myX9pkeJogHJVMKzuZOLdmmdwC)JcXOJDKpa41(SSWcELq1GbVSfGF1KPJ7LAXTbNA0ZUL1S(yF4vcvdg8Ywa(vtMoUxQf3gCWI7FuigD8kHQbdEzla)Qjth3l1IBdojfsDoJk0EELq1GbVSfGF1KPJ7LAXTbhvvsvAkFGZ2V4CSTiLe2iPOFyhfQMxjunyWlBb4xnz64EPwCBW91HK2EoF(aNn1mA5adZ8Z1H2S9beJyh5daEZyPvDOjCZKui15mQq7zeo(Asku4V4CmjfsDoJk0EMCGHTiJLwkPFX5yQrp7wwZ6J9HvQZyvaV0bAI102MXz8G3NMr44RjPfcf(lohRPTnJZ4bVpnRuBrMFX5yEYpxoZ4m6IcinYJc)YKdmCMlEj7TE74vcvdg8Ywa(vtMoUxQf3gCknfIs5dC22AsRnDCVuVmypGtddGL5nlELq1GbVSfGF1KPJ7LAXTb3ikD1dm6Yh4Sz5fVK9vZUm)IZX8KFUCMXz0ffqAKhf(LvQZiPFX5yQrp7wwZ6J9HvQTqOqlV4LSV6TlZV4Cmp5NlNzCgDrbKg5rHFzYbg2cELq1GbVSfGF1KPJ7LAXTbNFUo0MTpGyeVsOAWGx2cWVAY0X9sT42Gd2d40Wayz(aNTo0eUzo6eDoZ4m)OBnXiC81KmJL)IZX8KFUCMXz0ffqAKhf(LvQfkus)IZXuJE2TSM1h7dRulu4V4CmjfsDoJk0EwP2cELq1GbVSfGF1KPJ7LAXTb3ikD1dm64vcvdg8Ywa(vtMoUxQf3gCWEaNggalZh4S1HMWnZrNOZzgN5hDRjgHJVMKzS8xCowtBBgNXdEFAwPwOqj9lohtn6z3YAwFSpm5adN5xCowtBBgNXdEFAMCGHZCXlLxR1ol4vcvdg8Ywa(vtMoUxQf3gCRo85dC2SQdnHBMJorNZmoZp6wtmchFnj5vcvdg8Ywa(vtMoUxQf3gCIcu9C5mxzF4vcvdg8Ywa(vtMoUxQf3gCaFnHLa8RruGQNlhcARjfsWQpBuJAec]] )


end
