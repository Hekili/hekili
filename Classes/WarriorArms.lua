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

        if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" and ( spellName == class.abilities.colossus_smash.name or spellName == class.abilities.warbreaker.name ) then
            last_cs_target = destGUID
        end
    end )


    local cs_actual

    spec:RegisterHook( "reset_precast", function ()
        rageSpent = 0
        if buff.bladestorm.up then
            setCooldown( "global_cooldown", max( cooldown.global_cooldown.remains, buff.bladestorm.remains ) )
            if buff.gathering_storm.up then applyBuff( "gathering_storm", buff.bladestorm.remains + 6, 4 ) end
        end

        if not cs_actual then cs_actual = cooldown.colossus_smash end

        if talent.warbreaker.enabled and cs_actual then
            cooldown.colossus_smash = cooldown.warbreaker
        else
            cooldown.colossus_smash = cs_actual
        end


        if prev_gcd[1].colossus_smash and time - action.colossus_smash.lastCast < 1 and last_cs_target == target.unit and debuff.colossus_smash.down then
            -- Apply Colossus Smash early because its application is delayed for some reason.
            applyDebuff( "target", "colossus_smash", 10 )
        elseif prev_gcd[1].warbreaker and time - action.warbreaker.lastCast < 1 and last_cs_target == target.unit and debuff.colossus_smash.down then
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
            range = 8,

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

            handler = function ()
                if talent.collateral_damage.enabled and active_enemies > 1 then gain( 6, "rage" ) end
                if talent.fervor_of_battle.enabled and buff.crushing_assault.up then removeBuff( "crushing_assault" ) end
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


    spec:RegisterPack( "Arms", 20200614, [[dyKzJbqiOkpsQi2eu5tQujYOujDkvkRsLkfVsfPzPIQBrfrTli)IkQHbv1XiclJi1ZOsyAsfLRPsvBJks9nPIQXrfjNtQi16uPsyEej3tQ0(ur5GurKfQI4Hsfj5IQuj1jLksSsIOzQsLe7KkvdvLkvlvLkj9uIAQujDvPIKARQuP0xvPsu7LQ(lHbJQdlSyO8yknzsUmyZK6ZQWOfLtJYQPs0RLkmBkUTi7gPFR0WLQwUQEUIPl56sz7uP8DQW4PIW5vjwVkvmFr1(rSxcVREzvuG3DPXxA8X3PLOZqsiT0UqAVCDPh8Y9HTJ4a8Y0ibEzN0NgVCFCXSHY7QxE22BbVCwv9ZDHZoFWQSggYUjNhwQzIITu7h6Y5HLSo7LXAmt1Pq9yEzvuG3DPXxA8X3PLOZqsiT0UqI79YrRY23llZsntuSL2P6dD5LZykfq9yEzfmwVCNq4oPpne(D54F2(ej7ecpRQ(5UWzNpyvwddz3KZdl1mrXwQ9dD58WswNjs2jeUKnkq4s0zNt4sJV04tKKizNq4DQYc6bm3fej7ec3jt4ojLcue(DVLsGbrKStiCNmH7Kukqr43TmBT)fc)UABYCUtj1dufJEq43TmBT)ferYoHWDYeUtsPafHFsuLbiC5STveETeE)d2nHffH7KU73vqej7ec3jt431obyBfBPWFxAi87(dw2WwkHZgcxbgOafIizNq4ozc3jPuGIW7upaH3PuqAqEzdBQX7QxEy0ddiQ4pGY7Q3Dj8U6LbAGzaL)eVS9zf8SWl)Xbq4sr4370eoochRP1ifekZfHnmjKADqjCCeowtRrjiT)fXQfMMLPeQhI0GuRdQxoSfBPE5PJMXm9gwvW7lV7s7D1ld0aZak)jEz7Zk4zHxgpchRP1ifekZfHnmjuRNWXr4xjC7Ug16GISRzNPnIjftg6HuWOdHlfHlnHNNt4xj8kmaTqoIh7HOd4ranWmGIWXr42DnQ1bf5iEShIoGh9qky0HWLIWLMWVr438YHTyl1l)HBXb8(Y7Ul8U6LbAGzaL)eVS9zf8SWlJhHdZaulGSlvb0bucdtd69TacObMbueoochpcVcdqlukMjSpGaAGzafHJJWVs4v8hqHkwce1k6TLqA8j8ZiCjWNWZZjCn7iRepKcgDi8Zi87XNWVr455eomdqTaYUufqhqjmmnO33ciGgygqr44iC8i8kmaTqPyMW(acObMbueooc)kHxXFafQyjquRO3wcPXNWpJWLaFcppNW1SJSs8qky0HWpJWDk8j8BeEEoHxHbOfkfZe2hqanWmGIWXr4xj8k(dOqflbIAf92s4I7j8ZiCjWNWZZjCn7iRepKcgDi8Zi87XNWV5LdBXwQx2UMDM2iMumz(Y7EN5D1ld0aZak)jEz7Zk4zHxgpchMbOwazxQcOdOegMg07BbeqdmdOiCCeoEeEfgGwOumtyFab0aZakchhHFLWR4pGcvSeiQv0BlH04t4Nr4sGpHNNt4A2rwjEifm6q4Nr43JpHFJWZZjCygGAbKDPkGoGsyyAqVVfqanWmGIWXr44r4vyaAHsXmH9beqdmdOiCCe(vcVI)akuXsGOwrVTesJpHFgHlb(eEEoHRzhzL4HuWOdHFgH7u4t43i88CcVcdqlukMjSpGaAGzafHJJWVs4v8hqHkwce1k6TLWf3t4Nr4sGpHNNt4A2rwjEifm6q4Nr43JpHFZlh2ITuVSJ4XEi6aEF5D)EVRE5WwSL6LvqOmxe2WK8YanWmGYFIV8U70Ex9YanWmGYFIx2(ScEw4LXAAnAAkfqfkiQm0dHT8YHTyl1ldobyBf4lV7DU3vVmqdmdO8N4LTpRGNfEz7Ug16GIs7xHrm1Z6aqpKcgDiCCeUcWAAnYUMDM2iMumzi16Gs44i8ReoEeEfgGwifekZfHnmjeqdmdOi88CchRP1ifekZfHnmjKADqj8Beooc)kHFLWvawtRr21SZ0gXKIjd16jCCeoEeECh4zfGkykXQfj2rwHaAGzafHFJWZZjCSMwJkykXQfj2rwHA9e(nchhHJ10Aucs7FrSAHPzzkH6Hini16Gs44i8poacxkcVZW3lh2ITuVmMjuWu7N8L3DNY7QxgObMbu(t8Y2NvWZcV80dgJOI)aQb5iJ9ghmQIWpJWL2lh2ITuVS1aHBGV8U3P9U6LbAGzaL)eVS9zf8SWlFLWXJWRWa0c9avHaAGzafHJJWvBHua0lCSnQAqpKcgDiCCe(hhaHlfH354t44iCSMwJsqA)lIvlmnltjupePbPwhuchhHRaSMwJSRzNPnIjftgsToOe(ncppNWVs4vyaAHEGQqanWmGIWXr4QTqka6fo2gvnOhsbJoeoocxTf6bQc9qky0HWpJWpSkchhH)Xbq4sr4Do(eoochRP1OeK2)Iy1ctZYuc1drAqQ1bLWXr4kaRP1i7A2zAJysXKHuRdkHFZlh2ITuV86g89Rd49L3DjW37QxoSfBPE50(vyet9SoaVmqdmdO8N4lV7siH3vVmqdmdO8N4LTpRGNfE5hsbJoeUuDjCv7JITuc)UHWXh5cVCyl2s9Ypqv(Y7Ues7D1ld0aZak)jEz7Zk4zHx(kHFLWVs4ynTgLG0(xeRwyAwMsOEisdQ1t43i88Cc)kHRaSMwJSRzNPnIjftgQ1t43i88Cc)kHJ10AKccL5IWgMeQ1t43i8BeoocVcdqlKgE32xSAbwuLbqanWmGIWVr455e(vc)kHJ10Aucs7FrSAHPzzkH6HinOwpHNNt4FCae(zeUt1Pj8BeoocxbynTgzxZotBetkMmuRNWXr4ynTgvWuIvlsSJScPwhuchhHJhHxHbOfsdVB7lwTalQYaiGgygqr438YHTyl1l7iJ9ghmQYxE3LWfEx9YanWmGYFIx2(ScEw4LXJWRWa0cPH3T9fRwGfvzaeqdmdOiCCe(vchRP1OeK2)Iy1ctZYuc1drAqTEcppNWvawtRr21SZ0gXKIjd16j8BE5WwSL6LhtK8L3Dj6mVRE5WwSL6Lx3GVFDaVxgObMbu(t8L3DjU37QxgObMbu(t8Y2NvWZcVCfgGwin8UTVy1cSOkdGaAGzafHJJWVs4ynTgvWuIvlsSJSc16j88CcxbynTgzxZotBetkMmKADqjCCeowtRrfmLy1Ie7iRqQ1bLWXr4FCae(zeUtJpHFZlh2ITuVSJm2BCWOkF5DxcN27QxgObMbu(t8Y2NvWZcVmEeEfgGwin8UTVy1cSOkdGaAGzaLxoSfBPE5XejF5DxIo37QxoSfBPEz3y2A)lIVnzEzGgygq5pXxE3LWP8U6LdBXwQxML6bQIrpeUXS1(x8YanWmGYFIV8Lxwb6OzkVRE3LW7QxoSfBPEzBw8hGxgObMbu(t8L3DP9U6LdBXwQxUVLsGXld0aZak)j(Y7Ul8U6LbAGzaL)eVS9zf8SWlFLWR4pGcLbHPYq92IWLIWLwccppNWRWa0cLIzc7diGgygqr44i8k(dOqzqyQmuVTiCPiCx40e(nchhHFLWXAAnkbP9ViwTW0SmLq9qKguRNWZZjCSMwJoAXRybvSArCh43kd16j8BeEEoHJhHdZaulGsqA)lIvlmnltjupePbLcxUpHJJWXJWHzaQfq2LQa6akHHPb9(waLcxUpHJJWVs4v8hqHYGWuzOEBr4sr4slbHNNt4vyaAHsXmH9beqdmdOiCCeEf)buOmimvgQ3weUueUlCAc)gHJJWvawtRr21SZ0gXKIjd16j88CcxZoYkXdPGrhcxkcx679YHTyl1l3VfBP(Y7EN5D1ld0aZak)jEz7Zk4zHxgRP1OeK2)Iy1ctZYuc1drAqTEchhHJ10AubtjwTiXoYkuRNWZZjCSMwJoAXRybvSArCh43kd16jCCeUcWAAnYUMDM2iMumzOwpHNNt4ynTgnauzm6H4Jda16j88Cc)kHJhHdZaulGsqA)lIvlmnltjupePbLcxUpHJJWXJWHzaQfq2LQa6akHHPb9(waLcxUpHJJWXJWHzaQfqyMDvIvlQmqauiDbLcxUpHJJWvawtRr21SZ0gXKIjd16j8BE5WwSL6LXm7Qe62FXxE3V37QxgObMbu(t8Y2NvWZcVmwtRrjiT)fXQfMMLPeQhI0GA9eoochRP1OcMsSArIDKvOwpHNNt4ynTgD0IxXcQy1I4oWVvgQ1t44iCfG10AKDn7mTrmPyYqTEcppNWXAAnAaOYy0dXhhaQ1t455e(vchpchMbOwaLG0(xeRwyAwMsOEisdkfUCFchhHJhHdZaulGSlvb0bucdtd69TakfUCFchhHJhHdZaulGWm7QeRwuzGaOq6ckfUCFchhHRaSMwJSRzNPnIjftgQ1t438YHTyl1lJb)aFhm6HV8U70Ex9YanWmGYFIx2(ScEw4LXAAnkbP9ViwTW0SmLq9qKgKADqjCCe(hhaHlfHFp(eooc)kHB31OwhuuA)kmIPEwha6HuWOdHFgHFyveEEoHFLWR4pGcLbHPYq92IWLIWLgFcppNWRWa0cLIzc7diGgygqr44i8k(dOqzqyQmuVTiCPiCxCpHFJWV5LdBXwQxoEBqbrT)d0YxE37CVREzGgygq5pXlBFwbpl8YkaRP1i7A2zAJysXKHuRdQxoSfBPEzd7iRgHlBQJeqlF5D3P8U6LbAGzaL)eVS9zf8SWlJ10Aucs7FrSAHPzzkH6HinOwpHJJWXAAnQGPeRwKyhzfQ1t455eowtRrhT4vSGkwTiUd8BLHA9eoocxbynTgzxZotBetkMmuRNWZZjCSMwJgaQmg9q8XbGA9eEEoHFLWXJWHzaQfqjiT)fXQfMMLPeQhI0GsHl3NWXr44r4Wma1ci7svaDaLWW0GEFlGsHl3NWXr44r4Wma1cimZUkXQfvgiakKUGsHl3NWXr4kaRP1i7A2zAJysXKHA9e(nVCyl2s9YA2dyMDv(Y7EN27QxgObMbu(t8Y2NvWZcVmwtRrjiT)fXQfMMLPeQhI0GA9eoochRP1OcMsSArIDKvOwpHNNt4ynTgD0IxXcQy1I4oWVvgQ1t44iCfG10AKDn7mTrmPyYqTEcppNWXAAnAaOYy0dXhhaQ1t455e(vchpchMbOwaLG0(xeRwyAwMsOEisdkfUCFchhHJhHdZaulGSlvb0bucdtd69TakfUCFchhHJhHdZaulGWm7QeRwuzGaOq6ckfUCFchhHRaSMwJSRzNPnIjftgQ1t438YHTyl1lhulm1hgHnmgF5Dxc89U6LbAGzaL)eVS9zf8SWlRaSMwJSRzNPnIjftgsToOeoochRP1OeK2)Iy1ctZYuc1drAqQ1bLWXr42DnQ1bfL2VcJyQN1bGEifm64LdBXwQxgloeRwupZ2X4lV7siH3vVmqdmdO8N4LdBXwQxoMm3ckmIpUZ(c7(HXlBFwbpl8Y4r4kaRP1OpUZ(c7(HrOaSMwJA9eEEoHFLWVs4v8hqHYGWuzOEBr4sr4sJpsccppNWRWa0cLIzc7diGgygqr44i8k(dOqzqyQmuVTiCPiCxCpscc)gHJJWVs4ynTgLG0(xeRwyAwMsOEisdQ1t44i8ReUDxJADqrjiT)fXQfMMLPeQhI0GEifm6q4sr4sGVtt455eUDxJADqrjiT)fXQfMMLPeQhI0GEifm6q4sr4sirNt44iCn7iRepKcgDiCPiCPXNWXr44r4vyaAHsXmH9beqdmdOi8BeEEoHJ10A0rlEflOIvlI7a)wzOwpHJJWvawtRr21SZ0gXKIjd16j8Be(ncppNWHzaQfq2LQa6akHHPb9(waLcxUpHJJWR4pGcLbHPYq92IWLIWLgFcppNWVs4v8hqHYGWuzOEBr4sr4UaFKeeoocxbynTgzxQQzlMBGGr7qOaSMwJA9eoochpchMbOwaLG0(xeRwyAwMsOEisdkfUCFchhHJhHdZaulGSlvb0bucdtd69TakfUCFc)gHNNt4xjC8iCfG10AKDPQMTyUbcgTdHcWAAnQ1t44iC8iCygGAbucs7FrSAHPzzkH6HinOu4Y9jCCeoEeomdqTaYUufqhqjmmnO33cOu4Y9jCCeUcWAAnYUMDM2iMumzOwpHFZltJe4LJjZTGcJ4J7SVWUFy8L3DjK27QxgObMbu(t8YHTyl1lh3zYIpgHEPLy1I(1b8Ez7Zk4zHxUyjquRqXacxkcVZXNWXr4xjC7Ug16GISRzNPnIjftg6HuWOdHlfHlH0eEEoHFLWRWa0c5iEShIoGhb0aZakchhHB31OwhuKJ4XEi6aE0dPGrhcxkcxcPj8Be(ncppNWXJWvawtRr21SZ0gXKIjd16jCCeoEeowtRrfmLy1Ie7iRqTEchhHJhHJ10Aucs7FrSAHPzzkH6HinOwpHJJWlwce1kumGWpJWL4E89Y0ibE54otw8Xi0lTeRw0VoG3xE3LWfEx9YanWmGYFIx2(ScEw4LT7AuRdkYUMDM2iMumzOhsbJoeUueUtr455e(vcVcdqlKJ4XEi6aEeqdmdOiCCeUDxJADqroIh7HOd4rpKcgDiCPiCNIWV5LdBXwQxoClQ49L3Dj6mVREzGgygq5pXlBFwbpl8Y2DnQ1bfzxZotBetkMm0dPGrhcxkc3Pi88Cc)kHxHbOfYr8ypeDapcObMbueooc3URrToOihXJ9q0b8OhsbJoeUueUtr438YHTyl1l3gqWkin(Y7Ue37D1ld0aZak)jEz7Zk4zHxE6bJruXFa1GCKXEJdgvr4Nr4sq44i8ReUDxJADqryMqbtTFc9qky0HWpJWLaFcppNWT7AuRdkYUMDM2iMumzOhsbJoe(zeUtr455eECh4zfGkykXQfj2rwHaAGzafHFZlh2ITuV84aGEg9qm1Z6agF5DxcN27QxgObMbu(t8Y2NvWZcV8vchRP1OcMsSArIDKvOwpHNNt4xjCfG10AKDn7mTrmPyYqTEchhHJhHh3bEwbOcMsSArIDKviGgygqr43i8Beooc)kHRzhzL4HuWOdHFgH3PXNWZZj8ReEf)buOmimvgQ3weUueU04t455eEfgGwOumtyFab0aZakchhHxXFafkdctLH6TfHlfH7I7j8Be(nVCyl2s9YyMDvIvlQmqauiDXxE3LOZ9U6LbAGzaL)eVS9zf8SWlJhHRaSMwJSRzNPnIjftgQ1t44iC8iCSMwJkykXQfj2rwHA9E5WwSL6L7BptFHrpeyMykF5DxcNY7QxgObMbu(t8Y2NvWZcVmEeUcWAAnYUMDM2iMumzOwpHJJWXJWXAAnQGPeRwKyhzfQ17LdBXwQx(z99gqWOIPpSGV8UlrN27QxgObMbu(t8Y2NvWZcVmEeUcWAAnYUMDM2iMumzOwpHJJWXJWXAAnQGPeRwKyhzfQ17LdBXwQx2X(gLBaJkEywAqTGV8Uln(Ex9YanWmGYFIx2(ScEw4LXJWvawtRr21SZ0gXKIjd16jCCeoEeowtRrfmLy1Ie7iRqTEVCyl2s9Y612gqjI7apRabgejF5DxAj8U6LbAGzaL)eVS9zf8SWlJhHRaSMwJSRzNPnIjftgQ1t44iC8iCSMwJkykXQfj2rwHA9E5WwSL6LFi6z0dH2ejy8L3DPL27QxgObMbu(t8Y2NvWZcVmEeUcWAAnYUMDM2iMumzOwpHJJWXJWXAAnQGPeRwKyhzfQ1t44iC1wi7sTaT(OaLqBIeiWApf9qky0HW7s447LdBXwQx2UulqRpkqj0Mib(Y7U0UW7QxgObMbu(t8Y2NvWZcVmwtRrpy7WaZi07BbuR3lh2ITuVCLbIgfBBuLqVVf8L3DP7mVREzGgygq5pXlBFwbpl8Y4r4vyaAHCep2drhWJaAGzafHJJWT7AuRdkYUMDM2iMumzOhsbJoeUue(9eooc)kHRzhzL4HuWOdHFgHlTe4t455e(vcVI)akugeMkd1BlcxkcxA8j88CcVcdqlukMjSpGaAGzafHJJWR4pGcLbHPYq92IWLIWDX9e(ncppNW1SJSs8qky0HWLIWDHee(nVCyl2s9YhT4vSGkwTiUd8BL5lV7sFV3vVmqdmdO8N4LTpRGNfE5kmaTqoIh7HOd4ranWmGIWXr42DnQ1bf5iEShIoGh9qky0HWLIWVNWXr4xjCn7iRepKcgDi8ZiCPLaFcppNWVs4v8hqHYGWuzOEBr4sr4sJpHNNt4vyaAHsXmH9beqdmdOiCCeEf)buOmimvgQ3weUueUlUNWVr455eUMDKvIhsbJoeUueUlKGWV5LdBXwQx(OfVIfuXQfXDGFRmF5DxAN27QxgObMbu(t8Y2NvWZcVmEeEfgGwihXJ9q0b8iGgygqr44iC7Ug16GISRzNPnIjftg6HuWOdHlfHlbHJJWVs4A2rwjEifm6q4Nr4sCp(eEEoHFLWR4pGcLbHPYq92IWLIWLgFcppNWRWa0cLIzc7diGgygqr44i8k(dOqzqyQmuVTiCPiCxCpHFJWV5LdBXwQxobP9ViwTW0SmLq9qKgF5Dx6o37QxgObMbu(t8Y2NvWZcVCfgGwihXJ9q0b8iGgygqr44iC7Ug16GICep2drhWJEifm6q4sr4sq44i8ReUMDKvIhsbJoe(zeUe3JpHNNt4xj8k(dOqzqyQmuVTiCPiCPXNWZZj8kmaTqPyMW(acObMbueoocVI)akugeMkd1Blcxkc3f3t43i8BE5WwSL6LtqA)lIvlmnltjupePXxE3L2P8U6LbAGzaL)eVS9zf8SWlp9GXiQ4pGAqoYyVXbJQi8Zi8oZlh2ITuV83OIWwSLkmSP8Yg2ucAKaVSM5giQ4pGYxE3LUt7D1ld0aZak)jEz7Zk4zHx(kHxHbOfkfZe2hqanWmGIWXr4v8hqHYGWuzOEBr4sr4U4Ec)gHNNt4v8hqHYGWuzOEBr4sr4sJVxoSfBPE5VrfHTylvyyt5LnSPe0ibEzWjaBRaF5D3f47D1ld0aZak)jE5WwSL6L)gve2ITuHHnLx2WMsqJe4Lhg9WaIk(dO8LV8Y9py3ewuEx9UlH3vVCyl2s9YyrvgqmzBR8YanWmGYFIV8UlT3vVmqdmdO8N4LPrc8YXDMS4JrOxAjwTOFDaVxoSfBPE54otw8Xi0lTeRw0VoG3xE3DH3vVmqdmdO8N4LTpRGNfE5kmaTqA4DBFXQfyrvgab0aZakcppNWXJWRWa0cPH3T9fRwGfvzaeqdmdOiCCeEXsGOwHIbe(zeUe3JVxoSfBPE5eK2)Iy1ctZYuc1drA8L39oZ7QxgObMbu(t8Y2NvWZcVCfgGwin8UTVy1cSOkdGaAGzafHNNt4vyaAHsXmH9beqdmdOiCCeEXsGOwHIbe(zeU0sGpHNNt4vyaAHEGQqanWmGIWXr4xj8ILarTcfdi8ZiCPLaFcppNWlwce1kumGWLIWLOZUNWV5LdBXwQx(OfVIfuXQfXDGFRmF5D)EVREzGgygq5pXlBFwbpl8YWma1ci7svaDaLWW0GEFlGsHl33l3VfBPE5(TylvSArJI9mLbucD7V4LdBXwQxUFl2s9L3DN27QxgObMbu(t8Y2NvWZcVmmdqTakbP9ViwTW0SmLq9qKgukC5(E5(Tyl1l3VfBPIvl0RTnGs8WSg3aVCyl2s9Y9BXwQV8U35Ex9YHTyl1l3VfBPEzGgygq5pXx(YldobyBf4D17UeEx9YanWmGYFIx2(ScEw4L)4aiCPi87LMWXr4ynTgPGqzUiSHjHuRdkHJJWXAAnkbP9ViwTW0SmLq9qKgKADq9YHTyl1lpD0mMP3WQcEF5DxAVREzGgygq5pXlBFwbpl8Y4r4ynTgPGqzUiSHjHA9eooc)kHB31OwhuKDn7mTrmPyYqpKcgDiCPiCPj88Cc)kHxHbOfYr8ypeDapcObMbueooc3URrToOihXJ9q0b8OhsbJoeUueU0e(nc)MxoSfBPE5pCloG3xE3DH3vVmqdmdO8N4LTpRGNfEz8iCygGAbucs7FrSAHPzzkH6HinOu4Y9j88Cc)kHJ10Aucs7FrSAHPzzkH6HinOwpHNNt42DnQ1bfLG0(xeRwyAwMsOEisd6HuWOdHFgHlb(e(nVCyl2s9Y21SZ0gXKIjZxE37mVREzGgygq5pXlBFwbpl8Y4r4Wma1cOeK2)Iy1ctZYuc1drAqPWL7t455e(vchRP1OeK2)Iy1ctZYuc1drAqTEcppNWT7AuRdkkbP9ViwTW0SmLq9qKg0dPGrhc)mcxc8j8BE5WwSL6LDep2drhW7lV737D1lh2ITuVSccL5IWgMKxgObMbu(t8L3DN27QxgObMbu(t8Y2NvWZcVmEeowtRrjiT)fXQfMMLPeQhI0GA9eoochRP1OcMsSArIDKvOwpHJJW)4aiCPiCxGpHJJWXJWXAAnsbHYCrydtc169YHTyl1lJzcfm1(jF5DVZ9U6LbAGzaL)eVS9zf8SWlp9GXiQ4pGAqoYyVXbJQi8ZiCP9YHTyl1lBnq4g4lV7oL3vVmqdmdO8N4LTpRGNfEzSMwJSFBYy0drmt0mfQ1t44iCSMwJsqA)lIvlmnltjupePbPwhuVCyl2s9YJjs(Y7EN27QxgObMbu(t8Y2NvWZcV8dPGrhcxQUeUQ9rXwkHF3q44JCbHJJWR4pGcvSeiQvOyaHFgH35E5WwSL6LFGQ8L3DjW37QxgObMbu(t8Y2NvWZcVmwtRrRBW3VoGhnvy7GW7s4st44i8kmaTqQhcfnAhzfcObMbuE5WwSL6Lt7xHrm1Z6a8L3DjKW7QxgObMbu(t8Y2NvWZcVmwtRrjiT)fXQfMMLPeQhI0GA9eEEoHJ10AKccL5IWgMeQ1t455eUcWAAnYUMDM2iMumzOwpHNNt4ynTgvWuIvlsSJSc169YHTyl1ldobyBf4lV7siT3vVCyl2s9YRBW3VoG3ld0aZak)j(Y7UeUW7QxoSfBPEzWjaBRaVmqdmdO8N4lF5L1m3arf)buEx9UlH3vVmqdmdO8N4LTpRGNfE5poacxkc3PXNWXr4xjC8i8kmaTqkiuMlcBysiGgygqr455eowtRrkiuMlcBysi16Gs438YHTyl1lpD0mMP3WQcEF5DxAVREzGgygq5pXlBFwbpl8YxjC8i8kmaTqoIh7HOd4ranWmGIWZZjC7Ug16GICep2drhWJEifm6q4sr4st438YHTyl1l)HBXb8(Y7Ul8U6LbAGzaL)eVS9zf8SWlRaSMwJSRzNPnIjftgsToOE5WwSL6LTRzNPnIjftMV8U3zEx9YanWmGYFIx2(ScEw4LvawtRr21SZ0gXKIjdPwhuVCyl2s9YoIh7HOd49L3979U6LbAGzaL)eVS9zf8SWlJ10A04aGEg9qm1Z6agKADqjCCe(vchpcVcdqlKccL5IWgMecObMbueEEoHJ10AKccL5IWgMesToOe(nchhHFLWVs4kaRP1i7A2zAJysXKHEifm6q4Nr4Dg6EchhHJhHh3bEwbOcMsSArIDKviGgygqr43i88CchRP1OcMsSArIDKvOwpHFZlh2ITuVmMjuWu7N8L3DN27QxoSfBPEzfekZfHnmjVmqdmdO8N4lV7DU3vVCyl2s9YwdeUbEzGgygq5pXxE3DkVREzGgygq5pXlBFwbpl8YxjC8i8kmaTqwdeUbiGgygqr44iC1wifa9chBJQg0dPGrhcxkcxAc)gHNNt4xjCSMwJMMsbuHcIkd9qylcppNWXAAnAQLcImi(c9qylc)gHJJWVs4ynTgnoaONrpet9SoGb16j88Cc3URrToOOXba9m6HyQN1bmOhsbJoe(zeUtr438YHTyl1ldobyBf4lV7DAVREzGgygq5pXlBFwbpl8YxjC8i8kmaTqwdeUbiGgygqr44iC1wifa9chBJQg0dPGrhcxkcxAc)gHNNt4ynTgnoaONrpet9SoGb16jCCeowtRrRBW3VoGhnvy7GW7s4st44i8kmaTqQhcfnAhzfcObMbuE5WwSL6Lt7xHrm1Z6a8L3DjW37QxgObMbu(t8Y2NvWZcVScWAAnYUMDM2iMumzOwpHNNt4xjCSMwJSFBYy0drmt0mfQ1t44i8kmaTqA4DBFXQfyrvgab0aZakc)MxoSfBPEzhzS34Grv(Y7Ues4D1ld0aZak)jEz7Zk4zHxgRP1ifekZfHnmjuRNWZZj8poac)mc3PX3lh2ITuVSJm2BCWOkF5DxcP9U6LdBXwQxEDd((1b8EzGgygq5pXxE3LWfEx9YHTyl1l7iJ9ghmQYld0aZak)j(Y7UeDM3vVCyl2s9YUXS1(xeFBY8YanWmGYFIV8UlX9Ex9YHTyl1lZs9avXOhc3y2A)lEzGgygq5pXx(YxEz3GFyl17U04ln(4704lHx2r8ug9y8YDkP(9lqr43t4HTylLWnSPgersVC)VAMb8YDcH7K(0q43LJ)z7tKSti8SQ6N7cND(GvznmKDtopSuZefBP2p0LZdlzDMizNq4s2OaHlrNDoHln(sJprsIKDcH3PklOhWCxqKStiCNmH7Kukqr439wkbgerYoHWDYeUtsPafHF3YS1(xi87QTjZ5oLupqvm6bHF3YS1(xqej7ec3jt4ojLcue(jrvgGWLZ2wr41s49py3ewueUt6UFxbrKStiCNmHFx7eGTvSLc)DPHWV7pyzdBPeoBiCfyGcuiIKDcH7KjCNKsbkcVt9aeENsbPbrKKizNq431obyBfOiCmqVpq42nHffHJbhm6GiCNK1c91q40L6KZIpPBgcpSfBPdHVuZferYoHWdBXw6G6FWUjSO6QnX0brYoHWdBXw6G6FWUjSOoTRZ6Dvej7ecpSfBPdQ)b7MWI60UohTJeqROylLizNq4Y0OFY2IW)GPiCSMwdkcFQOgchd07deUDtyrr4yWbJoeEqveE)do5(Tkg9GWzdHRwkGisg2IT0b1)GDtyrDAxNXIQmGyY2wrKmSfBPdQ)b7MWI60Uo3gqWkiDonsq34otw8Xi0lTeRw0VoGNizyl2shu)d2nHf1PDDobP9ViwTW0SmLq9qKMZz6UvyaAH0W72(IvlWIQmacObMbu554vHbOfsdVB7lwTalQYaiGgygqHRyjquRqXGZK4E8jsg2IT0b1)GDtyrDAxNpAXRybvSArCh43k7CMUBfgGwin8UTVy1cSOkdGaAGzavEEfgGwOumtyFab0aZakCflbIAfkgCM0sGFEEfgGwOhOkeqdmdOWDTyjquRqXGZKwc8ZZlwce1kumqkj6S7VrKmSfBPdQ)b7MWI60Uo3VfBPNtJe0TFl2sfRw0OyptzaLq3(lNZ0DHzaQfq2LQa6akHHPb9(waLcxUprYWwSLoO(hSBclQt76C)wSLEonsq3(TylvSAHETTbuIhM14gCot3fMbOwaLG0(xeRwyAwMsOEisdkfUCFIKHTylDq9py3ewuN215(TylLijrYoHWVRDcW2kqr4GBWFHWlwci8kdi8Ww7t4SHWd3cMjWmaIizyl2sNU2S4paIKHTylDoTRZ9TucmejdBXw6CAxN73IT0Zz6UxR4pGcLbHPYq92skPLipVcdqlukMjSpGaAGzafUk(dOqzqyQmuVTKYfo9nCxXAAnkbP9ViwTW0SmLq9qKguRpphRP1OJw8kwqfRwe3b(TYqT(B554bZaulGsqA)lIvlmnltjupePbLcxUpo8GzaQfq2LQa6akHHPb9(waLcxUpURv8hqHYGWuzOEBjL0sKNxHbOfkfZe2hqanWmGcxf)buOmimvgQ3ws5cN(gofG10AKDn7mTrmPyYqT(8Cn7iRepKcgDKs67jsg2IT050UoJz2vj0T)Y5mDxSMwJsqA)lIvlmnltjupePb16XH10AubtjwTiXoYkuRpphRP1OJw8kwqfRwe3b(TYqTECkaRP1i7A2zAJysXKHA955ynTgnauzm6H4Jda16ZZVIhmdqTakbP9ViwTW0SmLq9qKgukC5(4WdMbOwazxQcOdOegMg07BbukC5(4WdMbOwaHz2vjwTOYabqH0fukC5(4uawtRr21SZ0gXKIjd16VrKmSfBPZPDDgd(b(oy0JZz6UynTgLG0(xeRwyAwMsOEisdQ1JdRP1OcMsSArIDKvOwFEowtRrhT4vSGkwTiUd8BLHA94uawtRr21SZ0gXKIjd16ZZXAAnAaOYy0dXhhaQ1NNFfpygGAbucs7FrSAHPzzkH6HinOu4Y9XHhmdqTaYUufqhqjmmnO33cOu4Y9XHhmdqTacZSRsSArLbcGcPlOu4Y9XPaSMwJSRzNPnIjftgQ1FJizyl2sNt76C82GcIA)hO15mDxSMwJsqA)lIvlmnltjupePbPwhuCFCasDp(4UA31OwhuuA)kmIPEwha6HuWOZzhwvE(1k(dOqzqyQmuVTKsA8ZZRWa0cLIzc7diGgygqHRI)akugeMkd1BlPCX93UrKmSfBPZPDD2WoYQr4YM6ib06CMURcWAAnYUMDM2iMumzi16GsKmSfBPZPDDwZEaZSR6CMUlwtRrjiT)fXQfMMLPeQhI0GA94WAAnQGPeRwKyhzfQ1NNJ10A0rlEflOIvlI7a)wzOwpofG10AKDn7mTrmPyYqT(8CSMwJgaQmg9q8XbGA955xXdMbOwaLG0(xeRwyAwMsOEisdkfUCFC4bZaulGSlvb0bucdtd69TakfUCFC4bZaulGWm7QeRwuzGaOq6ckfUCFCkaRP1i7A2zAJysXKHA93isg2IT050Uohulm1hgHnmMZz6UynTgLG0(xeRwyAwMsOEisdQ1JdRP1OcMsSArIDKvOwFEowtRrhT4vSGkwTiUd8BLHA94uawtRr21SZ0gXKIjd16ZZXAAnAaOYy0dXhhaQ1NNFfpygGAbucs7FrSAHPzzkH6HinOu4Y9XHhmdqTaYUufqhqjmmnO33cOu4Y9XHhmdqTacZSRsSArLbcGcPlOu4Y9XPaSMwJSRzNPnIjftgQ1FJizyl2sNt76mwCiwTOEMTJ5CMURcWAAnYUMDM2iMumzi16GIdRP1OeK2)Iy1ctZYuc1drAqQ1bfNDxJADqrP9RWiM6zDaOhsbJoejdBXw6CAxNBdiyfKoNgjOBmzUfuyeFCN9f29dZ5mDx8uawtRrFCN9f29dJqbynTg16ZZVETI)akugeMkd1BlPKgFKe55vyaAHsXmH9beqdmdOWvXFafkdctLH6TLuU4EKe3WDfRP1OeK2)Iy1ctZYuc1drAqTECxT7AuRdkkbP9ViwTW0SmLq9qKg0dPGrhPKaFNop3URrToOOeK2)Iy1ctZYuc1drAqpKcgDKscj6CCA2rwjEifm6iL04JdVkmaTqPyMW(acObMbu3YZXAAn6OfVIfuXQfXDGFRmuRhNcWAAnYUMDM2iMumzOw)TB55Wma1ci7svaDaLWW0GEFlGsHl3hxf)buOmimvgQ3wsjn(55xR4pGcLbHPYq92skxGpscCkaRP1i7svnBXCdemAhcfG10AuRhhEWma1cOeK2)Iy1ctZYuc1drAqPWL7JdpygGAbKDPkGoGsyyAqVVfqPWL7Flp)kEkaRP1i7svnBXCdemAhcfG10AuRhhEWma1cOeK2)Iy1ctZYuc1drAqPWL7JdpygGAbKDPkGoGsyyAqVVfqPWL7JtbynTgzxZotBetkMmuR)grYWwSLoN2152acwbPZPrc6g3zYIpgHEPLy1I(1b8NZ0Dlwce1kumqQohFCxT7AuRdkYUMDM2iMumzOhsbJosjH055xRWa0c5iEShIoGhb0aZakC2DnQ1bf5iEShIoGh9qky0rkjK(2T8C8uawtRr21SZ0gXKIjd16XHhwtRrfmLy1Ie7iRqTEC4H10Aucs7FrSAHPzzkH6HinOwpUILarTcfdotI7XNizyl2sNt76C4wuXFot31URrToOi7A2zAJysXKHEifm6iLtLNFTcdqlKJ4XEi6aEeqdmdOWz31OwhuKJ4XEi6aE0dPGrhPCQBejdBXw6CAxNBdiyfKMZz6U2DnQ1bfzxZotBetkMm0dPGrhPCQ88RvyaAHCep2drhWJaAGzafo7Ug16GICep2drhWJEifm6iLtDJizyl2sNt7684aGEg9qm1Z6aMZz6UtpymIk(dOgKJm2BCWOQZKa3v7Ug16GIWmHcMA)e6HuWOZzsGFEUDxJADqr21SZ0gXKIjd9qky05mNkppUd8ScqfmLy1Ie7iRqanWmG6grYWwSLoN21zmZUkXQfvgiakKUCot39kwtRrfmLy1Ie7iRqT(88RkaRP1i7A2zAJysXKHA94WlUd8ScqfmLy1Ie7iRqanWmG62nCx1SJSs8qky05Son(55xR4pGcLbHPYq92skPXppVcdqlukMjSpGaAGzafUk(dOqzqyQmuVTKYf3F7grYWwSLoN215(2Z0xy0dbMjM6CMUlEkaRP1i7A2zAJysXKHA94WdRP1OcMsSArIDKvOwprYWwSLoN215N13BabJkM(WcNZ0DXtbynTgzxZotBetkMmuRhhEynTgvWuIvlsSJSc16jsg2IT050Uo7yFJYnGrfpmlnOw4CMUlEkaRP1i7A2zAJysXKHA94WdRP1OcMsSArIDKvOwprYWwSLoN21z9ABdOeXDGNvGadI05mDx8uawtRr21SZ0gXKIjd16XHhwtRrfmLy1Ie7iRqTEIKHTylDoTRZpe9m6HqBIemNZ0DXtbynTgzxZotBetkMmuRhhEynTgvWuIvlsSJSc16jsg2IT050UoBxQfO1hfOeAtKGZz6U4PaSMwJSRzNPnIjftgQ1JdpSMwJkykXQfj2rwHA94uBHSl1c06JcucTjsGaR9u0dPGrNU4tKmSfBPZPDDUYarJITnQsO33cNZ0DXAAn6bBhgygHEFlGA9ejdBXw6CAxNpAXRybvSArCh43k7CMUlEvyaAHCep2drhWJaAGzafo7Ug16GISRzNPnIjftg6HuWOJu3J7QMDKvIhsbJoNjTe4NNFTI)akugeMkd1BlPKg)88kmaTqPyMW(acObMbu4Q4pGcLbHPYq92skxC)T8Cn7iRepKcgDKYfsCJizyl2sNt768rlEflOIvlI7a)wzNZ0DRWa0c5iEShIoGhb0aZakC2DnQ1bf5iEShIoGh9qky0rQ7XDvZoYkXdPGrNZKwc8ZZVwXFafkdctLH6TLusJFEEfgGwOumtyFab0aZakCv8hqHYGWuzOEBjLlU)wEUMDKvIhsbJos5cjUrKmSfBPZPDDobP9ViwTW0SmLq9qKMZz6U4vHbOfYr8ypeDapcObMbu4S7AuRdkYUMDM2iMumzOhsbJosjbURA2rwjEifm6CMe3JFE(1k(dOqzqyQmuVTKsA8ZZRWa0cLIzc7diGgygqHRI)akugeMkd1BlPCX93UrKmSfBPZPDDobP9ViwTW0SmLq9qKMZz6UvyaAHCep2drhWJaAGzafo7Ug16GICep2drhWJEifm6iLe4UQzhzL4HuWOZzsCp(55xR4pGcLbHPYq92skPXppVcdqlukMjSpGaAGzafUk(dOqzqyQmuVTKYf3F7grYWwSLoN215VrfHTylvyytDonsqxnZnquXFa15mD3Phmgrf)budYrg7noyu1zDgrYWwSLoN215VrfHTylvyytDonsqxWjaBRGZz6UxRWa0cLIzc7diGgygqHRI)akugeMkd1BlPCX93YZR4pGcLbHPYq92skPXNizyl2sNt7683OIWwSLkmSPoNgjO7WOhgquXFafrsIKHTylDqGta2wbDNoAgZ0Byvb)5mD3poaPUxACynTgPGqzUiSHjHuRdkoSMwJsqA)lIvlmnltjupePbPwhuIKHTylDqGta2wbN215pCloG)CMUlEynTgPGqzUiSHjHA94UA31OwhuKDn7mTrmPyYqpKcgDKs688RvyaAHCep2drhWJaAGzafo7Ug16GICep2drhWJEifm6iL03UrKmSfBPdcCcW2k40UoBxZotBetkMSZz6U4bZaulGsqA)lIvlmnltjupePbLcxUFE(vSMwJsqA)lIvlmnltjupePb16ZZT7AuRdkkbP9ViwTW0SmLq9qKg0dPGrNZKa)BejdBXw6GaNaSTcoTRZoIh7HOd4pNP7IhmdqTakbP9ViwTW0SmLq9qKgukC5(55xXAAnkbP9ViwTW0SmLq9qKguRpp3URrToOOeK2)Iy1ctZYuc1drAqpKcgDotc8VrKmSfBPdcCcW2k40UoRGqzUiSHjrKmSfBPdcCcW2k40UoJzcfm1(PZz6U4H10Aucs7FrSAHPzzkH6HinOwpoSMwJkykXQfj2rwHA94(4aKYf4JdpSMwJuqOmxe2WKqTEIKHTylDqGta2wbN21zRbc3GZz6UtpymIk(dOgKJm2BCWOQZKMizyl2she4eGTvWPDDEmr6CMUlwtRr2Vnzm6HiMjAMc16XH10Aucs7FrSAHPzzkH6Hini16GsKmSfBPdcCcW2k40Uo)avDot39HuWOJuDvTpk2sVBWh5cCv8hqHkwce1kum4SoNizyl2she4eGTvWPDDoTFfgXupRd4CMUlwtRrRBW3VoGhnvy7OR04QWa0cPEiu0ODKviGgygqrKmSfBPdcCcW2k40UodobyBfCot3fRP1OeK2)Iy1ctZYuc1drAqT(8CSMwJuqOmxe2WKqT(8CfG10AKDn7mTrmPyYqT(8CSMwJkykXQfj2rwHA9ejdBXw6GaNaSTcoTRZRBW3VoGNizyl2she4eGTvWPDDgCcW2kGijrYWwSLoinZnquXFav3PJMXm9gwvWFot39JdqkNgFCxXRcdqlKccL5IWgMecObMbu55ynTgPGqzUiSHjHuRd6nIKHTylDqAMBGOI)aQt768hUfhWFot39kEvyaAHCep2drhWJaAGzavEUDxJADqroIh7HOd4rpKcgDKs6BejdBXw6G0m3arf)buN21z7A2zAJysXKDot3vbynTgzxZotBetkMmKADqjsg2IT0bPzUbIk(dOoTRZoIh7HOd4pNP7QaSMwJSRzNPnIjftgsToOejdBXw6G0m3arf)buN21zmtOGP2pDot3fRP1OXba9m6HyQN1bmi16GI7kEvyaAHuqOmxe2WKqanWmGkphRP1ifekZfHnmjKADqVH76vfG10AKDn7mTrmPyYqpKcgDoRZq3JdV4oWZkavWuIvlsSJScb0aZaQB55ynTgvWuIvlsSJSc16VrKmSfBPdsZCdev8hqDAxNvqOmxe2WKisg2IT0bPzUbIk(dOoTRZwdeUbejdBXw6G0m3arf)buN21zWjaBRGZz6UxXRcdqlK1aHBacObMbu4uBHua0lCSnQAqpKcgDKs6B55xXAAnAAkfqfkiQm0dHTYZXAAnAQLcImi(c9qyRB4UI10A04aGEg9qm1Z6aguRpp3URrToOOXba9m6HyQN1bmOhsbJoN5u3isg2IT0bPzUbIk(dOoTRZP9RWiM6zDaNZ0DVIxfgGwiRbc3aeqdmdOWP2cPaOx4yBu1GEifm6iL03YZXAAnACaqpJEiM6zDadQ1JdRP1O1n47xhWJMkSD0vACvyaAHupekA0oYkeqdmdOisg2IT0bPzUbIk(dOoTRZoYyVXbJQoNP7QaSMwJSRzNPnIjftgQ1NNFfRP1i73Mmg9qeZentHA94QWa0cPH3T9fRwGfvzaeqdmdOUrKmSfBPdsZCdev8hqDAxNDKXEJdgvDot3fRP1ifekZfHnmjuRpp)Jd4mNgFIKHTylDqAMBGOI)aQt7686g89Rd4jsg2IT0bPzUbIk(dOoTRZoYyVXbJQisg2IT0bPzUbIk(dOoTRZUXS1(xeFBYisg2IT0bPzUbIk(dOoTRZSupqvm6HWnMT2)crsIKHTylDqdJEyarf)buDNoAgZ0Byvb)5mD3poaPU3PXH10AKccL5IWgMesToO4WAAnkbP9ViwTW0SmLq9qKgKADqjsg2IT0bnm6Hbev8hqDAxN)WT4a(Zz6U4H10AKccL5IWgMeQ1J7QDxJADqr21SZ0gXKIjd9qky0rkPZZVwHbOfYr8ypeDapcObMbu4S7AuRdkYr8ypeDap6HuWOJusF7grYWwSLoOHrpmGOI)aQt76SDn7mTrmPyYoNP7IhmdqTaYUufqhqjmmnO33ciGgygqHdVkmaTqPyMW(acObMbu4UwXFafQyjquRO3wcPX)mjWppxZoYkXdPGrNZUh)B55Wma1ci7svaDaLWW0GEFlGaAGzafo8QWa0cLIzc7diGgygqH7Af)buOILarTIEBjKg)ZKa)8Cn7iRepKcgDoZPW)wEEfgGwOumtyFab0aZakCxR4pGcvSeiQv0BlHlU)mjWppxZoYkXdPGrNZUh)BejdBXw6Ggg9WaIk(dOoTRZoIh7HOd4pNP7IhmdqTaYUufqhqjmmnO33ciGgygqHdVkmaTqPyMW(acObMbu4UwXFafQyjquRO3wcPX)mjWppxZoYkXdPGrNZUh)B55Wma1ci7svaDaLWW0GEFlGaAGzafo8QWa0cLIzc7diGgygqH7Af)buOILarTIEBjKg)ZKa)8Cn7iRepKcgDoZPW)wEEfgGwOumtyFab0aZakCxR4pGcvSeiQv0BlHlU)mjWppxZoYkXdPGrNZUh)BejdBXw6Ggg9WaIk(dOoTRZkiuMlcBysejdBXw6Ggg9WaIk(dOoTRZGta2wbNZ0DXAAnAAkfqfkiQm0dHTisg2IT0bnm6Hbev8hqDAxNXmHcMA)05mDx7Ug16GIs7xHrm1Z6aqpKcgDWPaSMwJSRzNPnIjftgsToO4UIxfgGwifekZfHnmjeqdmdOYZXAAnsbHYCrydtcPwh0B4UEvbynTgzxZotBetkMmuRhhEXDGNvaQGPeRwKyhzfcObMbu3YZXAAnQGPeRwKyhzfQ1FdhwtRrjiT)fXQfMMLPeQhI0GuRdkUpoaP6m8jsg2IT0bnm6Hbev8hqDAxNTgiCdoNP7o9GXiQ4pGAqoYyVXbJQotAIKHTylDqdJEyarf)buN2151n47xhWFot39kEvyaAHEGQqanWmGcNAlKcGEHJTrvd6HuWOdUpoaP6C8XH10Aucs7FrSAHPzzkH6Hini16GItbynTgzxZotBetkMmKADqVLNFTcdql0dufcObMbu4uBHua0lCSnQAqpKcgDWP2c9avHEifm6C2HvH7JdqQohFCynTgLG0(xeRwyAwMsOEisdsToO4uawtRr21SZ0gXKIjdPwh0BejdBXw6Ggg9WaIk(dOoTRZP9RWiM6zDaejdBXw6Ggg9WaIk(dOoTRZpqvNZ0DFifm6ivxv7JIT07g8rUGizyl2sh0WOhgquXFa1PDD2rg7noyu15mD3RxVI10Aucs7FrSAHPzzkH6HinOw)T88RkaRP1i7A2zAJysXKHA93YZVI10AKccL5IWgMeQ1F7gUkmaTqA4DBFXQfyrvgab0aZaQB55xVI10Aucs7FrSAHPzzkH6HinOwFE(hhWzovN(gofG10AKDn7mTrmPyYqTECynTgvWuIvlsSJScPwhuC4vHbOfsdVB7lwTalQYaiGgygqDJizyl2sh0WOhgquXFa1PDDEmr6CMUlEvyaAH0W72(IvlWIQmacObMbu4UI10Aucs7FrSAHPzzkH6HinOwFEUcWAAnYUMDM2iMumzOw)nIKHTylDqdJEyarf)buN2151n47xhWtKmSfBPdAy0ddiQ4pG60Uo7iJ9ghmQ6CMUBfgGwin8UTVy1cSOkdGaAGzafURynTgvWuIvlsSJSc16ZZvawtRr21SZ0gXKIjdPwhuCynTgvWuIvlsSJScPwhuCFCaN504FJizyl2sh0WOhgquXFa1PDDEmr6CMUlEvyaAH0W72(IvlWIQmacObMbuejdBXw6Ggg9WaIk(dOoTRZUXS1(xeFBYisg2IT0bnm6Hbev8hqDAxNzPEGQy0dHBmBT)fV80dwV7DUe(YxEp]] )


end
