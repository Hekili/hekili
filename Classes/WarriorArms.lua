-- WarriorArms.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


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

        executioners_precision = not PTR and {
            id = 272870,
            duration = 30,
            max_stack = 2,
        } or nil,

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

        -- Map buff.executioners_precision to debuff.executioners_precision; use rawset to avoid changing the meta table.
        rawset( buff, "executioners_precision", debuff.executioners_precision )

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
                if azerite.executioners_precision.enabled then
                    applyDebuff( "target", "executioners_precision", nil, min( 2, debuff.executioners_precision.stack + 1 ) )
                end                
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
                removeDebuff( "target", "executioners_precision" )
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
            
            usable = function () return target.casting end,
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

    
    spec:RegisterPack( "Arms", 20181210.2230, [[dyuE(aqijOhHsL2KK4tOufzuOiNcuAvOuv5vOOMLiYTerXUq1VePgMe4yIGLrQ0Zer10uvPUMQkzBsO8nuQsJdLkoNeQY6qPkmpjK7Hs2NQkoOikTqqXdfHQAIOuv0frPQ0jrPQQvksMjkvrTtvvnujuzPIqLNkQPkjTvrOkFvcv1EL6VQYGPQdtzXG8yQmzcxgzZq6ZsQrRQCAfRgLQcVgLYSj62KYUv53qnCq1YbEUstx46qSDsvFxIgViKZtQy9Iqz(OW(j5oHUANfwq9FDlib2jbDtOaUU6M8e6COdCQZWnhBwn15Z0OoNSaTTZWnDKyt0v78IraoQZFraFzpsNUEIpeiUdRLEhnePfd(CadnsVJMlnKedLgc1sgbPpnCagDK0MU4auIZgXMU4sCVIVbadg8swG2Y3rZ1ziKrgS)xd1zHfu)x3csGDsq3ekGRRUjVGFXoD2qIpmOZ5rdrAXGVeFGHgD(Bec6AOolO11z2v5twG2Q8fFdagmqLIDv(ViGVShPtxpXhce3H1sVJgI0IbFoGHgP3rZLgsIHsdHAjJG0NgoaJosAtxCakXzJytxCjUxX3aGbdEjlqB57O5uPyxLN9j5inicO8juqskVUfKa7O8jJYRRUjVavkvk2v5t8)SRMw2dvk2v5tgLpzfcsO8fhIMgj5QuSRYNmkFYkeKq5t8gxGb6O8joK9ln7VgC6eZvR8jEJlWaD4QuSRYNmkFYkeKq5HXIqskF(dJekFGvE4aYH1GSq5t2IJ9mxLIDv(Kr5zFte5qIbFeG90Q8fhGCZo4t5Nv5fKKcsW7SC2y7QDENRwsVWa1u0v7)j0v7mDgKKenmD2bMGaJ1zaPzZTkFrSuEbcWIbFkp7NYxap5kFfLxqqiOOChwI3fzFRMTFCbU86S5IbFDgqNOJ(VUD1otNbjjrdtNDGjiWyDgy1KYxKYxScu(kkptkFHkFys6cUGmHuNNZKAC6mijjuEgmuEieuuUGmHuNNZKACbU8uEy7S5IbFDEzdrkx4Yjcc0r)p5D1otNbjjrdtNDGjiWyDUqLhcbfLliti155mPghbUYxr5zs5DySuGlpUdlX7ISVvZ2poG0S5wLViLxxLNbdLNjLpmjDbV0aqaYyJaC6mijju(kkVdJLcC5XlnaeGm2iahqA2CRYxKYRRYdRYdBNnxm4RZatVvtGo6))UR2z6mijjAy6SdmbbgRZcccbfL7Ws8Ui7B1S9JlWLxNnxm4RZoSeVlY(wnB)6O))RUANPZGKKOHPZoWeeySoliieuuUdlX7ISVvZ2pUaxED2CXGVoxAaiazSrGo6)fRR2zZfd(6SGmHuNNZKADModssIgMo6)S3UANPZGKKOHPZoWeeySodHGIYxeHGUNGS4JdiZfD2CXGVotjICib1r)ND6QDModssIgMo7atqGX6SdJLcC5X1WGWKVnadBehqA2CRYxr5zs5lu5dtsxWfKjK68CMuJtNbjjHYZGHYdHGIYfKjK68CMuJlWLNYdRYxr5zs5zs5feeckk3HL4Dr23Qz7hhbUYxr5lu5TeJatq8G24HrFAt9xWPZGKKq5Hv5zWq5Hqqr5bTXdJ(0M6VGJax5HTZMlg81ziPjOnWaTo6)fVUANPZGKKOHPZoWeeySoVWjP8fgOMILx(naz5CcL)hLx3oBUyWxNDsY0tD0)tOGUANPZGKKOHPZoWeeySoBjgbMG4lnR24ELMEIdSJnLNLYN8oBUyWxNX6jaCCjb6O)NqcD1oBUyWxN1WGWKVnadBuNPZGKKOHPJ(Fc62v7mDgKKenmD2bMGaJ15WK0fCucOhdEy0hKfHK40zqssO8vuEMuEieuuUGmHuNNZKACe4kpdgkpWQjL)hwkFXkq5HTZMlg815YVbilNt0r)pHK3v7S5IbFDgRNaWXLeOZ0zqss0W0r)pHF3v7mDgKKenmD2bMGaJ15WK0fCucOhdEy0hKfHK40zqssO8vuEMu(cvElXiWeepOnEy0N2u)fC6mijjuEgmuEbbHGIYDyjExK9TA2(XrGR8W2zZfd(6C53aKLZj6O)NWV6QDModssIgMo7atqGX6CHkFys6cokb0Jbpm6dYIqsC6mijju(kkptkFHkVLyeycIh0gpm6tBQ)coDgKKekpdgkVGGqqr5oSeVlY(wnB)4iWvEgmuEieuuUGmHuNNZKACe4kpdgkpWQjL)hwkFXkq5HTZMlg815vAAD0)tOyD1oBUyWxN1pUad05bq2VotNbjjrdth9)eyVD1oBUyWxNhn40jMR(PFCbgOtNPZGKKOHPJo6SGqnez0v7)j0v7S5IbFD29zGAQZ0zqss0W0r)x3UANnxm4RZWr00izNPZGKKOHPJ(FY7QD2CXGVodhhd(6mDgKKenmD0))DxTZ0zqss0W0zhyccmwNfeeckk3HL4Dr23Qz7hhbENnxm4RZqsmw8qra60r))xD1otNbjjrdtNDGjiWyDwqqiOOChwI3fzFRMTFCe4D2CXGVodrGLaSnxDh9)I1v7mDgKKenmD2bMGaJ1zbbHGIYDyjExK9TA2(Xf4Yt5RO8omwkWLhxddct(2amSrCaPzZTk)pkFc8FP8vuEGvtkFrk)VkOZMlg81zd4SJEbgaOl6O)ZE7QDModssIgMo7atqGX6SGGqqr5oSeVlY(wnB)4cC51zZfd(6SCQ)I9X(aruRrx0r)ND6QDModssIgMo7atqGX6SGGqqr5oSeVlY(wnB)4iW7S5IbFDgDaeKeJfD0)lED1otNbjjrdtNDGjiWyDwqqiOOChwI3fzFRMTFCe4D2CXGVoBNJ2ayYNZKYo6)juqxTZ0zqss0W0zhyccmwNDySuGlpUdlX7ISVvZ2poG0S5wLViLNDuEgmuEMu(WK0f8sdabiJncWPZGKKq5RO8omwkWLhV0aqaYyJaCaPzZTkFrkp7O8W2zZfd(6SP3cd0r)pHe6QDModssIgMo7atqGX68cNKYxyGAkwE53aKLZju(Fu(eu(kkptkVdJLcC5XHKMG2ad04asZMBv(Fu(ekq5zWq5DySuGlpUdlX7ISVvZ2poG0S5wL)hLNDuEgmuElXiWeepOnEy0N2u)fC6mijjuEy7S5IbFDEljc(C1VnadB02r)pbD7QDModssIgMo7atqGX6mWgXJ0txWnHy5uIMn2oBUyWxNbi3ZCXGVNC2OZYzJ3zAuN)mxh9)esExTZ0zqss0W0zhyccmwNx4Ku(cdutXYl)gGSCoHY)JY)7oBUyWxNbi3ZCXGVNC2OZYzJ3zAuNrh90lmqnfD0)t43D1otNbjjrdtNDGjiWyDMjLpmjDbxZ21CaItNbjjHYxr5ddutb)Jmz8XH7cLViLp5)s5Hv5zWq5ddutb)Jmz8XH7cLViLx3c6S5IbFDgGCpZfd(EYzJolNnENPrDMse5qcQJ(Fc)QR2z6mijjAy6S5IbFDgGCpZfd(EYzJolNnENPrDENRwsVWa1u0rhDgoGCynil6Q9)e6QDModssIgMo6)62v7mDgKKenmD0)tExTZ0zqss0W0r))3D1oBUyWxNHSiK0B)WirNPZGKKOHPJ()V6QD2CXGVodhhd(6mDgKKenmD0rNPeroKG6Q9)e6QDModssIgMo7atqGX6mWQjLViLVyfO8vuEMu(cv(WK0fCbzcPopNj140zqssO8myO8qiOOCbzcPopNj14cC5P8W2zZfd(68YgIuUWLteeOJ(VUD1otNbjjrdtNDGjiWyDUqLhcbfLliti155mPghbUYxr5zs5DySuGlpUdlX7ISVvZ2poG0S5wLViLxxLNbdLNjLpmjDbV0aqaYyJaC6mijju(kkVdJLcC5XlnaeGm2iahqA2CRYxKYRRYdRYdBNnxm4RZatVvtGo6)jVR2z6mijjAy6SdmbbgRZcccbfL7Ws8Ui7B1S9JlWLxNnxm4RZoSeVlY(wnB)6O))7UANPZGKKOHPZoWeeySoliieuuUdlX7ISVvZ2pUaxED2CXGVoxAaiazSrGo6))QR2zZfd(6SGmHuNNZKADModssIgMo6)fRR2z6mijjAy6SdmbbgRZaRMu(Iu(KxGYxr5lu5Hqqr5cYesDEotQXrG3zZfd(6mK0e0gyGwh9F2BxTZ0zqss0W0zhyccmwNx4Ku(cdutXYl)gGSCoHY)JYRBNnxm4RZojz6Po6)StxTZ0zqss0W0zhyccmwNHqqr5oaY(nx9Z21qKbhbENnxm4RZR006O)x86QDModssIgMo7atqGX6meckkhRNaWXLeGVH5yt5zP86Q8vu(WK0fCbGmXzi1FbNodssIoBUyWxN1WGWKVnadBuh9)ekOR2z6mijjAy6SdmbbgRZqiOOCbzcPopNj14iW7S5IbFDMse5qcQJ(Fcj0v7S5IbFDgRNaWXLeOZ0zqss0W0r)pbD7QD2CXGVotjICib1z6mijjAy6O)NqY7QD2CXGVoRFCbgOZdGSFDModssIgMo6)j87UANnxm4RZJgC6eZv)0pUad0PZ0zqss0W0rhD(ZCD1(FcD1otNbjjrdtNDGjiWyDgqA2CRYxelLxGaSyWNYZ(P8fWtUYxr5zs5lu5b2iEKE6cUjelhbUYZGHYdHGIY3sIGpx9BdWWgTCe4kpSD2CXGVodOt0r)x3UANPZGKKOHPZoWeeySodSAs5ls5lwbkFfLNjL3HXsbU84cYesDEotQXbKMn3Q8)O8jx5zWq5lu5dtsxWfKjK68CMuJtNbjjHYdBNnxm4RZlBis5cxorqGo6)jVR2z6mijjAy6SdmbbgRZmP8omwkWLhhsAcAdmqJdinBUv5)r5lMYZGHYhMKUGdm9wnb40zqssO8vuEhglf4YJdm9wnb4asZMBv(Fu(IP8WQ8vuEMuEhglf4YJ7Ws8Ui7B1S9JdinBUv5ls51v5zWq5zs5dtsxWlnaeGm2iaNodsscLVIY7WyPaxE8sdabiJncWbKMn3Q8fP86Q8WQ8W2zZfd(6SGmHuNNZKAD0))DxTZ0zqss0W0zhyccmwNzs5b2iEKE6cUjelhbUYZGHYdSr8i90fCtiw(Ck)pkFyGAk4XOrVa)edP8WQ8vuEMuEhglf4YJ7Ws8Ui7B1S9JdinBUv5ls51v5zWq5zs5dtsxWlnaeGm2iaNodsscLVIY7WyPaxE8sdabiJncWbKMn3Q8fP86Q8WQ8W2zZfd(6mW0B1eOJ()V6QDModssIgMo7atqGX6mWgXJ0txWnHy5iWvEgmuEGnIhPNUGBcXYNt5)r5)DbkpdgkptkpWgXJ0txWnHy5ZP8)O86wGYxr5dtsxWTRMapn7SAsJUGtNbjjHYdBNnxm4RZoSeVlY(wnB)6O)xSUANPZGKKOHPZoWeeySodSr8i90fCtiwocCLNbdLhyJ4r6Pl4MqS85u(Fu(FxGYZGHYZKYdSr8i90fCtiw(Ck)pkVUfO8vu(WK0fC7QjWtZoRM0Ol40zqssO8W2zZfd(6CPbGaKXgb6O)ZE7QDModssIgMo7atqGX6mtkVGGqqr5oSeVlY(wnB)4iWv(kkpWgXJ0txWnHy5ZP8)O8HbQPGhJg9c8tmKYdRYZGHYdSr8i90fCtiwocCLVIYZKYZKYliieuuUdlX7ISVvZ2poG0S5wL)hL)38FP8vu(cvElXiWeepOnEy0N2u)fC6mijjuEyvEgmuEieuuEqB8WOpTP(l4iWvEy7S5IbFDgsAcAdmqRJ(p70v7mDgKKenmD2bMGaJ15cvEGnIhPNUGBcXYrGR8myO8mP8aBepspDb3eILJax5RO8wIrGji(sZQnUxPPN40zqssO8W2zZfd(6mwpbGJljqh9)IxxTZ0zqss0W0zhyccmwNx4Ku(cdutXYl)gGSCoHY)JYRBNnxm4RZojz6Po6)juqxTZ0zqss0W0zhyccmwNlu5b2iEKE6cUjelhbUYZGHYZKYxOYhMKUG7KKPN40zqssO8vuEbo4cIG)kXiNy5asZMBv(IuEDvEyvEgmuEieuu(Iie09eKfFCazUOZMlg81zkrKdjOo6)jKqxTZ0zqss0W0zhyccmwNlu5b2iEKE6cUjelhbUYZGHYZKYxOYhMKUG7KKPN40zqssO8vuEbo4cIG)kXiNy5asZMBv(IuEDvEy7S5IbFDwddct(2amSrD0)tq3UANPZGKKOHPZoWeeySodSr8i90fCtiwoc8oBUyWxNl)gGSCorh9)esExTZMlg81zSEcahxsGotNbjjrdth9)e(DxTZ0zqss0W0zhyccmwNdtsxWrjGEm4HrFqwesItNbjjrNnxm4RZLFdqwoNOJ(Fc)QR2z6mijjAy6SdmbbgRZfQ8HjPl4Oeqpg8WOpilcjXPZGKKq5RO8fQ8aBepspDb3eILJaVZMlg815vAAD0)tOyD1oBUyWxN1pUad05bq2VotNbjjrdth9)eyVD1oBUyWxNhn40jMR(PFCbgOtNPZGKKOHPJo6m6ONEHbQPOR2)tOR2z6mijjAy6SdmbbgRZaRMu(Iu(IvGYxr5zs5lu5dtsxWfKjK68CMuJtNbjjHYZGHYdHGIYfKjK68CMuJlWLNYdBNnxm4RZlBis5cxorqGo6)62v7mDgKKenmD2bMGaJ1zMu(cv(WK0f8sdabiJncWPZGKKq5zWq5DySuGlpEPbGaKXgb4asZMBv(IuEDvEy7S5IbFDgy6TAc0r)p5D1otNbjjrdtNDGjiWyDwqqiOOChwI3fzFRMTFCbU86S5IbFD2HL4Dr23Qz7xh9)F3v7mDgKKenmD2bMGaJ1zbbHGIYDyjExK9TA2(Xf4YRZMlg815sdabiJnc0r))xD1otNbjjrdtNDGjiWyDgcbfLVLebFU63gGHnA5cC5P8vuEMu(cv(WK0fCbzcPopNj140zqssO8myO8qiOOCbzcPopNj14cC5P8WQ8vuEMuEMuEbbHGIYDyjExK9TA2(XbKMn3Q8)O8)M)lLVIYxOYBjgbMG4bTXdJ(0M6VGtNbjjHYdRYZGHYdHGIYdAJhg9Pn1FbhbUYdBNnxm4RZqstqBGbAD0)lwxTZMlg81zbzcPopNj16mDgKKenmD0)zVD1oBUyWxNDsY0tDModssIgMo6)StxTZ0zqss0W0zhyccmwNzs5lu5dtsxWDsY0tC6mijju(kkVahCbrWFLyKtSCaPzZTkFrkVUkpSkpdgkptkpeckkFrec6EcYIpoGmxO8myO8qiOO8nWh9(ideCazUq5Hv5RO8mP8qiOO8TKi4Zv)2amSrlhbUYZGHY7WyPaxE8TKi4Zv)2amSrlhqA2CRY)JYZokpSD2CXGVotjICib1r)V41v7mDgKKenmD2bMGaJ1zMu(cv(WK0fCNKm9eNodsscLVIYlWbxqe8xjg5elhqA2CRYxKYRRYdRYZGHYdHGIY3sIGpx9BdWWgTCe4kFfLhcbfLJ1ta44scW3WCSP8SuEDv(kkptkFys6cUaqM4mK6VGtNbjjHYdBNnxm4RZAyqyY3gGHnQJ(Fcf0v7mDgKKenmD2bMGaJ1zbbHGIYDyjExK9TA2(XrGR8myO8mP8qiOOChaz)MR(z7AiYGJax5RO8HjPl4Oeqpg8WOpilcjXPZGKKq5HTZMlg815YVbilNt0r)pHe6QDModssIgMo7atqGX6meckkxqMqQZZzsnocCLNbdLhy1KY)JYxSc6S5IbFDU8BaYY5eD0)tq3UANnxm4RZy9eaoUKaDModssIgMo6)jK8UANnxm4RZLFdqwoNOZ0zqss0W0r)pHF3v7S5IbFDw)4cmqNhaz)6mDgKKenmD0)t4xD1oBUyWxNhn40jMR(PFCbgOtNPZGKKOHPJo6OZ6jWo4R)RBbjWojuGUSdpb2BYlEDU0a3C1BNz)1GJbbju(IP8Mlg8P8YzJLRs1z4am6iPoZUkFYc0wLV4BaWGbQuSRY)fb8L9iD66j(qG4oSw6D0qKwm4Zbm0i9oAU0qsmuAiulzeK(0Wby0rsB6IdqjoBeB6IlX9k(gamyWlzbAlFhnNkf7Q8SpjhPbraLpHcss51TGeyhLpzuED1n5fOsPsXUkFI)ND10YEOsXUkFYO8jRqqcLV4q00ijxLIDv(Kr5twHGekFI34cmqhLpXHSFPz)1GtNyUALpXBCbgOdxLIDv(Kr5twHGekpmwess5ZFyKq5dSYdhqoSgKfkFYwCSN5QuSRYNmkp7BIihsm4JaSNwLV4aKB2bFk)SkVGKuqcUkLkf7Q8SVjICibjuEicfdiL3H1GSq5HO65wUYNSohbpwL)WxY8zanuePYBUyW3Q84tQdxLYCXGVLdhqoSgKfSqL2YMkL5IbFlhoGCynilyMvAumwOszUyW3YHdihwdYcMzL2qQ1OlSyWNkf7Q85ZGVF4q5b2iuEieuusO8ByXQ8qekgqkVdRbzHYdr1ZTkVDcLhoGsg44iMRw5Nv5f4J4QuMlg8TC4aYH1GSGzwPHSiK0B)WiHkL5IbFlhoGCynilyMvA44yWNkLkf7Q8SVjICibjuEspb0r5JrJu(4JuEZfyGYpRYB6TrAqsIRszUyW3YY9zGAsLYCXGVLzwPHJOPrsvkZfd(wMzLgoog8PszUyW3YmR0qsmw8qra6K0GYsqqiOOChwI3fzFRMTFCe4QuMlg8TmZknebwcW2C1jnOSeeeckk3HL4Dr23Qz7hhbUkL5IbFlZSsBaND0lWaaDrsdklbbHGIYDyjExK9TA2(Xf4YRIdJLcC5X1WGWKVnadBehqA2C7pjW)vfGvtf9RcuPmxm4BzMvA5u)f7J9bIOwJUiPbLLGGqqr5oSeVlY(wnB)4cC5PszUyW3YmR0OdGGKySiPbLLGGqqr5oSeVlY(wnB)4iWvPmxm4BzMvA7C0gat(CMuM0GYsqqiOOChwI3fzFRMTFCe4QuMlg8TmZkTP3cdK0GYYHXsbU84oSeVlY(wnB)4asZMBlIDyWGPWK0f8sdabiJncWPZGKKOIdJLcC5XlnaeGm2iahqA2CBrSdSQuMlg8TmZk9wse85QFBag2OnPbL1cNKYxyGAkwE53aKLZj(jHkm5WyPaxECiPjOnWanoG0S52FsOagmCySuGlpUdlX7ISVvZ2poG0S52FyhgmSeJatq8G24HrFAt9xWPZGKKawvkZfd(wMzLgGCpZfd(EYzJKotJy9zUKguwaBepspDb3eILtjA2yvPmxm4BzMvAaY9mxm47jNns6mnIf6ONEHbQPiPbL1cNKYxyGAkwE53aKLZj(53QuMlg8TmZkna5EMlg89KZgjDMgXIse5qckPbLftHjPl4A2UMdqC6mijjQegOMc(hzY4Jd3ffL8FbldgHbQPG)rMm(4WDrr6wGkL5IbFlZSsdqUN5IbFp5SrsNPrS25QL0lmqnfQuQuMlg8TCkrKdjiwlBis5cxorqGKguwaRMkQyfuHPcdtsxWfKjK68CMuJtNbjjbdgqiOOCbzcPopNj14cC5bRkL5IbFlNse5qcIzwPbMERMajnOSkecbfLliti155mPghbEfMCySuGlpUdlX7ISVvZ2poG0S52I0LbdMctsxWlnaeGm2iaNodssIkomwkWLhV0aqaYyJaCaPzZTfPlSWQszUyW3YPeroKGyMvAhwI3fzFRMTFjnOSeeeckk3HL4Dr23Qz7hxGlpvkZfd(woLiYHeeZSsxAaiazSrGKguwcccbfL7Ws8Ui7B1S9JlWLNkL5IbFlNse5qcIzwPfKjK68CMutLYCXGVLtjICibXmR0qstqBGbAjnOSawnvuYlOsHqiOOCbzcPopNj14iWvPmxm4B5uIihsqmZkTtsMEkPbL1cNKYxyGAkwE53aKLZj(rxvkZfd(woLiYHeeZSsVstlPbLfeckk3bq2V5QF2UgIm4iWvPmxm4B5uIihsqmZkTggeM8TbyyJsAqzbHGIYX6jaCCjb4Byo2yPBLWK0fCbGmXzi1FbNodsscvkZfd(woLiYHeeZSstjICibL0GYccbfLliti155mPghbUkL5IbFlNse5qcIzwPX6jaCCjbuPmxm4B5uIihsqmZknLiYHeKkL5IbFlNse5qcIzwP1pUad05bq2pvkZfd(woLiYHeeZSspAWPtmx9t)4cmqhvkvkZfd(wo6ONEHbQPG1YgIuUWLteeiPbLfWQPIkwbvyQWWK0fCbzcPopNj140zqssWGbeckkxqMqQZZzsnUaxEWQszUyW3Yrh90lmqnfmZknW0B1eiPbLftfgMKUGxAaiazSraoDgKKemy4WyPaxE8sdabiJncWbKMn3wKUWQszUyW3Yrh90lmqnfmZkTdlX7ISVvZ2VKguwcccbfL7Ws8Ui7B1S9JlWLNkL5IbFlhD0tVWa1uWmR0LgacqgBeiPbLLGGqqr5oSeVlY(wnB)4cC5PszUyW3Yrh90lmqnfmZknK0e0gyGwsdklieuu(wse85QFBag2OLlWLxfMkmmjDbxqMqQZZzsnoDgKKemyaHGIYfKjK68CMuJlWLhSvyIjbbHGIYDyjExK9TA2(XbKMn3(ZV5)QsHwIrGjiEqB8WOpTP(l40zqssaldgqiOO8G24HrFAt9xWrGdRkL5IbFlhD0tVWa1uWmR0cYesDEotQPszUyW3Yrh90lmqnfmZkTtsMEsLYCXGVLJo6PxyGAkyMvAkrKdjOKguwmvyys6cUtsMEItNbjjrfbo4cIG)kXiNy5asZMBlsxyzWGjieuu(Iie09eKfFCazUGbdieuu(g4JEFKbcoGmxaBfMGqqr5BjrWNR(TbyyJwocCgmCySuGlp(wse85QFBag2OLdinBU9h2bwvkZfd(wo6ONEHbQPGzwP1WGWKVnadBusdklMkmmjDb3jjtpXPZGKKOIahCbrWFLyKtSCaPzZTfPlSmyaHGIY3sIGpx9BdWWgTCe4vGqqr5y9eaoUKa8nmhBS0TctHjPl4cazIZqQ)coDgKKeWQszUyW3Yrh90lmqnfmZkD53aKLZjsAqzjiieuuUdlX7ISVvZ2pocCgmyccbfL7ai73C1pBxdrgCe4vctsxWrjGEm4HrFqwesItNbjjbSQuMlg8TC0rp9cdutbZSsx(naz5CIKguwqiOOCbzcPopNj14iWzWay10pfRavkZfd(wo6ONEHbQPGzwPX6jaCCjbuPmxm4B5OJE6fgOMcMzLU8BaYY5eQuMlg8TC0rp9cdutbZSsRFCbgOZdGSFQuMlg8TC0rp9cdutbZSspAWPtmx9t)4cmqhvkvkZfd(w(N5ybOtK0GYcqA2CBrSeialg8X(vap5vyQqGnIhPNUGBcXYrGZGbeckkFljc(C1VnadB0YrGdRkL5IbFl)ZCmZk9YgIuUWLteeiPbLfWQPIkwbvyYHXsbU84cYesDEotQXbKMn3(tYzWOWWK0fCbzcPopNj140zqssaRkL5IbFl)ZCmZkTGmHuNNZKAjnOSyYHXsbU84qstqBGbACaPzZT)umgmctsxWbMERMaC6mijjQ4WyPaxECGP3QjahqA2C7pfd2km5WyPaxEChwI3fzFRMTFCaPzZTfPldgmfMKUGxAaiazSraoDgKKevCySuGlpEPbGaKXgb4asZMBlsxyHvLYCXGVL)zoMzLgy6TAcK0GYIjGnIhPNUGBcXYrGZGbWgXJ0txWnHy5Z9tyGAk4XOrVa)edbBfMCySuGlpUdlX7ISVvZ2poG0S52I0LbdMctsxWlnaeGm2iaNodssIkomwkWLhV0aqaYyJaCaPzZTfPlSWQszUyW3Y)mhZSs7Ws8Ui7B1S9lPbLfWgXJ0txWnHy5iWzWayJ4r6Pl4MqS85(53fWGbtaBepspDb3eILp3p6wqLWK0fC7QjWtZoRM0Ol40zqssaRkL5IbFl)ZCmZkDPbGaKXgbsAqzbSr8i90fCtiwocCgma2iEKE6cUjelFUF(DbmyWeWgXJ0txWnHy5Z9JUfujmjDb3UAc80SZQjn6coDgKKeWQszUyW3Y)mhZSsdjnbTbgOL0GYIjbbHGIYDyjExK9TA2(XrGxbyJ4r6Pl4MqS85(jmqnf8y0OxGFIHGLbdGnIhPNUGBcXYrGxHjMeeeckk3HL4Dr23Qz7hhqA2C7p)M)RkfAjgbMG4bTXdJ(0M6VGtNbjjbSmyaHGIYdAJhg9Pn1FbhboSQuMlg8T8pZXmR0y9eaoUKajnOSkeyJ4r6Pl4MqSCe4myWeWgXJ0txWnHy5iWRyjgbMG4lnR24ELMEItNbjjbSQuMlg8T8pZXmR0ojz6PKguwlCskFHbQPy5LFdqwoN4hDvPmxm4B5FMJzwPPeroKGsAqzviWgXJ0txWnHy5iWzWGPcdtsxWDsY0tC6mijjQiWbxqe8xjg5elhqA2CBr6cldgqiOO8friO7jil(4aYCHkL5IbFl)ZCmZkTggeM8TbyyJsAqzviWgXJ0txWnHy5iWzWGPcdtsxWDsY0tC6mijjQiWbxqe8xjg5elhqA2CBr6cRkL5IbFl)ZCmZkD53aKLZjsAqzbSr8i90fCtiwocCvkZfd(w(N5yMvASEcahxsavkZfd(w(N5yMv6YVbilNtK0GYkmjDbhLa6XGhg9bzrijoDgKKeQuMlg8T8pZXmR0R00sAqzvyys6cokb0Jbpm6dYIqsC6mijjQuiWgXJ0txWnHy5iWvPmxm4B5FMJzwP1pUad05bq2pvkZfd(w(N5yMv6rdoDI5QF6hxGb6OsPszUyW3Y35QL0lmqnfSa0jsAqzbinBUTiwceGfd(y)kGN8kcccbfL7Ws8Ui7B1S9JlWLNkL5IbFlFNRwsVWa1uWmR0lBis5cxorqGKguwaRMkQyfuHPcdtsxWfKjK68CMuJtNbjjbdgqiOOCbzcPopNj14cC5bRkL5IbFlFNRwsVWa1uWmR0atVvtGKguwfcHGIYfKjK68CMuJJaVctomwkWLh3HL4Dr23Qz7hhqA2CBr6YGbtHjPl4LgacqgBeGtNbjjrfhglf4YJxAaiazSraoG0S52I0fwyvPmxm4B57C1s6fgOMcMzL2HL4Dr23Qz7xsdklbbHGIYDyjExK9TA2(Xf4YtLYCXGVLVZvlPxyGAkyMv6sdabiJncK0GYsqqiOOChwI3fzFRMTFCbU8uPmxm4B57C1s6fgOMcMzLwqMqQZZzsnvkZfd(w(oxTKEHbQPGzwPPeroKGsAqzbHGIYxeHGUNGS4JdiZfQuMlg8T8DUAj9cdutbZSsdjnbTbgOL0GYYHXsbU84AyqyY3gGHnIdinBUTctfgMKUGliti155mPgNodsscgmGqqr5cYesDEotQXf4Yd2kmXKGGqqr5oSeVlY(wnB)4iWRuOLyeycIh0gpm6tBQ)coDgKKeWYGbeckkpOnEy0N2u)fCe4WQszUyW3Y35QL0lmqnfmZkTtsMEkPbL1cNKYxyGAkwE53aKLZj(rxvkZfd(w(oxTKEHbQPGzwPX6jaCCjbsAqzzjgbMG4lnR24ELMEIdSJnwjxLYCXGVLVZvlPxyGAkyMvAnmim5BdWWgPszUyW3Y35QL0lmqnfmZkD53aKLZjsAqzfMKUGJsa9yWdJ(GSiKeNodssIkmbHGIYfKjK68CMuJJaNbdGvt)WQyfaRkL5IbFlFNRwsVWa1uWmR0y9eaoUKaQuMlg8T8DUAj9cdutbZSsx(naz5CIKguwHjPl4Oeqpg8WOpilcjXPZGKKOctfAjgbMG4bTXdJ(0M6VGtNbjjbdgcccbfL7Ws8Ui7B1S9JJahwvkZfd(w(oxTKEHbQPGzwPxPPL0GYQWWK0fCucOhdEy0hKfHK40zqssuHPcTeJatq8G24HrFAt9xWPZGKKGbdbbHGIYDyjExK9TA2(XrGZGbeckkxqMqQZZzsnocCgmawn9dRIvaSQuMlg8T8DUAj9cdutbZSsRFCbgOZdGSFQuMlg8T8DUAj9cdutbZSspAWPtmx9t)4cmqNoVWjx)N9MqhD0na]] )


end
