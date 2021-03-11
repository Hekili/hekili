-- WarriorArms.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


local PTR = ns.PTR


-- Conduits
--[-] crash_the_ramparts
--[-] merciless_bonegrinder
--[-] mortal_combo
--[x] ashen_juggernaut

-- Covenants
--[x] piercing_verdict
--[-] harrowing_punishment
--[x] veterans_repute
--[x] destructive_reverberations

-- Endurance
--[-] iron_maiden
--[x] indelible_victory
--[x] stalwart_guardian

-- Finesse
--[-] cacophonous_roar
--[x] disturb_the_peace
--[x] inspiring_presence
--[-] safeguard


if UnitClassBase( 'player' ) == 'WARRIOR' then
    local spec = Hekili:NewSpecialization( 71 )

    local base_rage_gen, arms_rage_mult = 1.75, 4.000

    spec:RegisterResource( Enum.PowerType.Rage, {
        mainhand = {
            swing = "mainhand",
            
            last = function ()
                local swing = state.combat == 0 and state.now or state.swings.mainhand
                local t = state.query_time

                return swing + ( floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed )
            end,

            interval = "mainhand_speed",

            stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * arms_rage_mult * state.swings.mainhand_speed / state.haste
            end,
        },

        conquerors_banner = {
            aura = "conquerors_banner",

            last = function ()
                local app = state.buff.conquerors_banner.applied
                local t = state.query_time

                return app + ( floor( ( t - app ) / ( 1 * state.haste ) ) * ( 1 * state.haste ) )
            end,

            interval = 1,

            value = 4,
        },        
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

        collateral_damage = 22392, -- 334779
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
        death_sentence = 3522, -- 198500
        demolition = 5372, -- 329033
        disarm = 3534, -- 236077
        duel = 34, -- 236273
        master_and_commander = 28, -- 235941
        overwatch = 5376, -- 329035
        shadow_of_the_colossus = 29, -- 198807
        sharpen_blade = 33, -- 198817
        storm_of_destruction = 31, -- 236308
        war_banner = 32, -- 236320
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
            duration = function () return 6 * haste end,
            max_stack = 1,
        },
        bounding_stride = {
            id = 202164,
            duration = 3,
            max_stack = 1,
        },
        challenging_shout = {
            id = 1161,
            duration = 6,
            max_stack = 1,
        },
        charge = {
            id = 105771,
            duration = 1,
            max_stack = 1,
        },
        collateral_damage = {
            id = 334783,
            duration = 30,
            max_stack = 8,
        },
        colossus_smash = {
            id = 208086,
            duration = 10,
            max_stack = 1,
        },
        deadly_calm = {
            id = 262228,
            duration = 20,
            max_stack = 4,
        },
        deep_wounds = {
            id = 262115,
            duration = 12,
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
        ignore_pain = {
            id = 190456,
            duration = 12,
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
        piercing_howl = {
            id = 12323,
            duration = 8,
            max_stack = 1,
        },
        rallying_cry = {
            id = 97463,
            duration = function () return 10 * ( 1 + conduit.inspiring_presence.mod * 0.01 ) end,
            max_stack = 1,
        },
        --[[ ravager = {
            id = 152277,
        }, ]]
        rend = {
            id = 772,
            duration = 15,
            tick_time = 3,
            max_stack = 1,
        },
        --[[ seasoned_soldier = {
            id = 279423,
        }, ]]
        stone_heart = {
            id = 225947,
            duration = 10,
        },
        sudden_death = {
            id = 52437,
            duration = 10,
            max_stack = 1,
        },
        spell_reflection = {
            id = 23920,
            duration = function () return legendary.misshapen_mirror.enabled and 8 or 5 end,
            max_stack = 1,
        },
        storm_bolt = {
            id = 132169,
            duration = 4,
            max_stack = 1,
        },
        sweeping_strikes = {
            id = 260708,
            duration = function () return level > 57 and 15 or 12 end,
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
        },
    } )


    local rageSpent = 0

    spec:RegisterStateExpr( "rage_spent", function ()
        return rageSpent
    end )

    spec:RegisterHook( "spend", function( amt, resource )
        if resource == "rage" then
            if talent.anger_management.enabled then
                rage_spent = rage_spent + amt
                local reduction = floor( rage_spent / 20 )
                rage_spent = rage_spent % 20

                if reduction > 0 then
                    cooldown.colossus_smash.expires = cooldown.colossus_smash.expires - reduction
                    cooldown.bladestorm.expires = cooldown.bladestorm.expires - reduction
                    cooldown.warbreaker.expires = cooldown.warbreaker.expires - reduction
                end
            end
        end
    end )

    local last_cs_target = nil

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" then
            if ( spellName == class.abilities.colossus_smash.name or spellName == class.abilities.warbreaker.name ) then
                last_cs_target = destGUID
            end
        end
    end )


    local RAGE = Enum.PowerType.Rage
    local lastRage = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "RAGE" then
            local current = UnitPower( "player", RAGE )

            if current < lastRage then
                rageSpent = ( rageSpent + lastRage - current ) % 20 -- Anger Mgmt.                
            end

            lastRage = current
        end
    end )


    local cs_actual

    spec:RegisterHook( "reset_precast", function ()
        rage_spent = nil

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
            gcd = "off",

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

                if azerite.gathering_storm.enabled then
                    applyBuff( "gathering_storm", 6 + ( 4 * haste ), 4 )
                end
            end,
        },


        challenging_shout = {
            id = 1161,
            cast = 0,
            cooldown = 240,
            gcd = "spell",
            
            startsCombat = true,
            texture = 132091,
            
            handler = function ()
                applyDebuff( "target", "challenging_shout" )
            end,
        },


        charge = {
            id = 100,
            cast = 0,
            charges = function () return talent.double_time.enabled and 2 or nil end,
            cooldown = function () return talent.double_time.enabled and 17 or 20 end,
            recharge = function () return talent.double_time.enabled and 17 or 20 end,
            gcd = "off",

            startsCombat = true,
            texture = 132337,

            usable = function () return target.distance > 10 and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd.execute ) end,
            handler = function ()
                setDistance( 5 )
                applyDebuff( "target", "charge" )
            end,
        },


        cleave = {
            id = 845,
            cast = 0,
            cooldown = 6,
            hasteCD = true,
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
                if buff.deadly_calm.up then removeStack( "deadly_calm" ) end
                if active_enemies >= 3 then applyDebuff( "target", "deep_wounds" ) end
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
                applyDebuff( "target", "deep_wounds" )

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
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 298660,

            handler = function ()
                applyBuff( "deadly_calm" )
            end,
        },


        defensive_stance = {
            id = 197690,
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
            cooldown = function () return ( level > 51 and 120 or 180 ) - conduit.stalwart_guardian.mod * 0.001 end,
            gcd = "spell",

            startsCombat = false,
            texture = 132336,

            toggle = "defensives",

            handler = function ()
                applyBuff( "die_by_the_sword" )
            end,
        },


        execute = {
            id = function () return talent.massacre.enabled and 281000 or 163201 end,
            known = 163201,
            noOverride = 317485,
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
                if buff.deadly_calm.up then removeStack( "deadly_calm" )
                elseif buff.stone_heart.up then removeBuff( "stone_heart" )
                else removeBuff( "sudden_death" ) end

                if legendary.exploiter.enabled then applyDebuff( "target", "exploiter", nil, min( 2, debuff.exploiter.stack + 1 ) ) end

                if conduit.ashen_juggernaut.enabled then addStack( "ashen_juggernaut", nil, 1 ) end
            end,

            copy = { 163201, 281000, 281000 },

            auras = {
                -- Conduit
                ashen_juggernaut = {
                    id = 335234,
                    duration = 8,
                    max_stack = function () return max( 8, conduit.ashen_juggernaut.mod ) end
                }
            }
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
                if buff.deadly_calm.up then removeStack( "deadly_calm" ) end
            end,
        },


        heroic_leap = {
            id = 6544,
            cast = 0,
            cooldown = function () return talent.bounding_stride.enabled and 30 or 45 end,
            charges = function () return legendary.leaper.enabled and 3 or nil end,
            recharge = function () return legendary.leaper.enabled and ( talent.bounding_stride.enabled and 30 or 45 ) or nil end,
            gcd = "spell",

            startsCombat = false,
            texture = 236171,

            usable = function () return ( equipped.weight_of_the_earth or target.distance > 10 ) and ( query_time - max( action.charge.lastCast, action.heroic_leap.lastCast ) > gcd.execute * 2 ) end,
            handler = function ()
                setDistance( 5 )
                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
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


        ignore_pain = {
            id = 190456,
            cast = 0,
            cooldown = 12,
            gcd = "spell",
            
            spend = 0,
            spendType = "rage",
            
            startsCombat = true,
            texture = 1377132,
            
            handler = function ()
                applyBuff( "ignore_pain" )
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
                if buff.deadly_calm.up then removeStack( "deadly_calm" ) end
                if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
            end,

            auras = {
                -- Conduit
                indelible_victory = {
                    id = 336642,
                    duration = 8,
                    max_stack = 1
                }
            }
        },


        intervene = {
            id = 3411,
            cast = 0,
            cooldown = 30,
            gcd = "off",
            
            startsCombat = true,
            texture = 132365,
            
            handler = function ()
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
                return buff.battlelord.up and 15 or 30
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 132355,

            handler = function ()
                applyDebuff( "target", "mortal_wounds" )
                applyDebuff( "target", "deep_wounds" )
                removeBuff( "overpower" )
                removeBuff( "exploiter" )

                if buff.deadly_calm.up then
                    removeStack( "deadly_calm" )
                else
                    removeBuff( "battlelord" )
                end
            end,

            auras = {
                battlelord = {
                    id = 346369,
                    duration = 10,
                    max_stack = 1
                }
            }
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
                addStack( "overpower", 15, 1 )

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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 45 end,
            gcd = "spell",

            spend = -7,
            spendType = "rage",

            startsCombat = true,
            texture = 970854,

            talent = "ravager",
            toggle = "cooldowns",

            handler = function ()
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
                if buff.deadly_calm.up then removeStack( "deadly_calm" ) end
            end,
        },


        shattering_throw = {
            id = 64382,
            cast = 1.5,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 311430,
            
            handler = function ()
            end,
        },
        

        shield_block = {
            id = 2565,
            cast = 0,
            cooldown = 16,
            gcd = "spell",
            
            spend = 30,
            spendType = "rage",
            
            startsCombat = true,
            texture = 132110,
            
            nobuff = "shield_block",

            handler = function ()
                applyBuff( "shield_block" )
            end,
        },
        

        shield_slam = {
            id = 23922,
            cast = 0,
            cooldown = 9,
            gcd = "spell",
            
            startsCombat = true,
            texture = 134951,
            
            handler = function ()
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
                if buff.deadly_calm.up then removeStack( "deadly_calm" ) end
                removeBuff( "crushing_assault" )
            end,
        },


        spell_reflection = {
            id = 23920,
            cast = 0,
            cooldown = 25,
            gcd = "off",
            
            startsCombat = false,
            texture = 132361,
            
            handler = function ()
                applyBuff( "spell_reflection" )
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
                setCooldown( "global_cooldown", 0.75 ) -- Might work?
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
                if conduit.indelible_victory.enabled then applyBuff( "indelible_victory" ) end
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

                applyDebuff( "target", "colossus_smash" )
                applyDebuff( "target", "deep_wounds" )
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
                if buff.deadly_calm.up then removeStack( "deadly_calm" ) end
                if talent.fervor_of_battle.enabled and buff.crushing_assault.up then removeBuff( "crushing_assault" ) end
                removeBuff( "collateral_damage" )
            end,

            auras = {
                merciless_bonegrinder = {
                    id = 346574,
                    duration = 9,
                    max_stack = 1
                }
            }
        },


        -- Warrior - Kyrian    - 307865 - spear_of_bastion      (Spear of Bastion)
        spear_of_bastion = {
            id = 307865,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = function () return -25 * ( 1 + conduit.piercing_verdict.mod * 0.01 ) end,
            spendType = "rage",

            startsCombat = true,
            texture = 3565453,

            toggle = "essences",

            velocity = 30,

            handler = function ()
                applyDebuff( "target", "spear_of_bastion" )
            end,

            auras = {
                spear_of_bastion = {
                    id = 307871,
                    duration = 4,
                    max_stack = 1
                }
            }
        },
        
        -- Warrior - Necrolord - 324143 - conquerors_banner     (Conqueror's Banner)
        conquerors_banner = {
            id = 324143,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            startsCombat = false,
            texture = 3578234,

            toggle = "essences",

            handler = function ()
                applyBuff( "conquerors_banner" )
                if conduit.veterans_repute.enabled then
                    applyBuff( "veterans_repute" )
                    addStack( "glory", nil, 5 )
                end
            end,

            auras = {
                conquerors_banner = {
                    id = 324143,
                    duration = 20,
                    max_stack = 1
                },
                -- Conduit
                veterans_repute = {
                    id = 339267,
                    duration = 30,
                    max_stack = 1
                }
            }
        },

        -- Warrior - Night Fae - 325886 - ancient_aftershock    (Ancient Aftershock)
        ancient_aftershock = {
            id = 325886,
            cast = 0,
            cooldown = function () return 90 - conduit.destructive_reverberations.mod * 0.001 end,
            gcd = "spell",

            startsCombat = true,
            texture = 3636851,

            toggle = "essences",

            handler = function ()
                applyDebuff( "target", "ancient_aftershock" )
                -- Rage gain will be reactive, can't tell what is going to get hit.
            end,

            auras = {
                ancient_aftershock = {
                    id = 325886,
                    duration = 1,
                    max_stack = 1,
                },
            }
        },

        -- Warrior - Venthyr   - 317320 - condemn               (Condemn)
        condemn = {
            id = function () return talent.massacre.enabled and 330325 or 317485 end,
            known = 317349,
            cast = 0,
            cooldown = function () return state.spec.fury and ( 4.5 * haste ) or 0 end,
            hasteCD = true,
            gcd = "spell",

            spend = function ()
                if state.spec.fury then return -20 end
                return buff.sudden_death.up and 0 or 20
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 3565727,

            -- toggle = "essences", -- no need to toggle.

            usable = function ()
                if buff.sudden_death.up then return true end
                return target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or target.health_pct > 80, "requires > 80% or < " .. ( talent.massacre.enabled and 35 or 20 ) .. "% health"
            end,

            handler = function ()
                applyDebuff( "target", "condemned" )

                if not state.spec.fury and buff.sudden_death.down then
                    local extra = min( 20, rage.current )

                    if extra > 0 then spend( extra, "rage" ) end
                    gain( 4 + floor( 0.2 * extra ), "rage" )
                end

                if legendary.exploiter.enabled then applyDebuff( "target", "exploiter", nil, min( 2, debuff.exploiter.stack + 1 ) ) end

                removeBuff( "sudden_death" )

                if conduit.ashen_juggernaut.enabled then addStack( "ashen_juggernaut", nil, 1 ) end
            end,

            auras = {
                condemned = {
                    id = 317491,
                    duration = 10,
                    max_stack = 1,
                }
            },

            copy = { 317485, 330325, 317349, 330334 }
        }


    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageDots = false,
        damageExpiration = 8,

        potion = "spectral_strength",

        package = "Arms",
    } )


    spec:RegisterPack( "Arms", 20210310, [[dKuXSaqiKQQEevO2erPpjvrJIOQofrLwfGI6vsvnlIIBHuL2LK(Le1WaQogv0YasEgrvMgrfUgGQTjvHVrurJdq05OcX6auY8OcUNuzFaPoisvSqjYdrQkDraf6JacQtcOuRePmtabUjGqANsOHIuvSuaf5Pu1uLGRcieBfqbFfqOglsvL9k6VO0GLYHjTyI8yetMsxgAZu0NPsJgGtRYQbeKxJuz2eUnf2TIFdA4OWXPcPLRQNR00fUos2oq8Du04LQ05bKMpqz)O60zwi9wnWSiOahuobxEobV60rKNJihPpakdm9mucDQlM(rnW0tpVXMEgkqfq1Mfs)cPEcMEarWybwLl7EbakPkbAuEpdkHghCiVAgL3ZGuo9suNia2tkLERgyweuGdkNGlpNGxD6iYZrKhWtVsfaGF69NbLqJdo03xnJ0d4SwCsP0BXLKE65nwEdiw))GpNgqu9ja4nNGldVbkWbLtonon6laDCXfyXPrV8g9yTOL3OpuggOOYPrV8g9yTOL3agosaFGYBatulGYaBdg4yVXL3agosaFGw50OxEJESw0YBL0ieiV5baPcElG8gJhjqdjn4n6H(aeu50OxEdySxKqfhCWVNlVrFEKC7bhE7wEZIcmqBLtJE5n6XArlVbezrEdyhOXw50OxERatuPJ3WjEGYBMWN3kjulUb8nQPxCBSzH0V34kq2qFxmYczrNzH0JJkjqBwk9K)c8pn9YN3mpxab7Jg6nlVbAEZjqcoVbgy8M85TqFxmQaqveaQmibV5aVbkW5nWaJ3cvGtun0DvYJvCujbA5nz5TqFxmQaqveaQmibV5aVjpGZBYL3KB6vsCWj9e44Ou4d)LvsNb)mYIGklKECujbAZsPN8xG)PP)rd9ML3COJ3SuVghC4nGzEd8Q8sVsIdoP)XXMrwuEzH0JJkjqBwk9K)c8pn9eiuyHmNkbkG7sTSRHUaQpAO3S8Md8gqYBYYBUeB9rd9ML364nWtVsIdoPxbrd9ZilkhzH0JJkjqBwk9K)c8pn9lduiyd9DXyRmbCVG5nwEd08MtEtwEZcJQfrgSmHuJDRpAO3S8Md8MlXMELehCsprGkiygzrGNfsVsIdoP)vqux8tpoQKaTzPmYI9ilKELehCspt9LEuPd)0JJkjqBwkJSOCMfsVsIdoPNafWDPw21qxaPhhvsG2SugzrGmlKELehCsVoKdNGvnd8xaqcDPhhvsG2SugzrhjlKELehCs)Ya1NfAYkPBCWj94Osc0MLYil6e8Sq6XrLeOnlLEYFb(NMEca9DXL364nqLELehCspee8zazIFgzrNoZcPhhvsG2Su6j)f4FA6FQbnHVlwXXs934YkjGmR4Osc0YBGbgVjrzAwHGGpdit8RBOe64nq3XBGI3admEt(8MfgvlImyzcPg7wF0qVz5nh64nxIL3KL3iqOWczovcua3LAzxdDbuF0qVz5nqZBUelVj30RK4Gt6nGFOc2n(JomJSOtqLfspoQKaTzP0t(lW)00lrzAwTOAfaLLOcJQfYC4nz5n5ZBwuIY0SsGc4Uul7AOlGkfdEtwE7vxK3CG3Kh48gyGXBV6I8Md8gWbN3KB6vsCWj9sc1IBaFJmYIoLxwi9kjo4KElQwbqzjQWi94Osc0MLYil6uoYcPhhvsG2Su6j)f4FA6F1f5nh4TEaoVjlVjrzAwTOAfaLLOcJQfYCsVsIdoPFPJsiwgIlc8Zil6e4zH0RK4Gt6HGGpdit8tpoQKaTzPmYIo7rwi94Osc0MLsp5Va)ttVeLPzDPSwCyTOgaQpQKi9kjo4KEcCSOXKrw0PCMfspoQKaTzP0t(lW)00lrzAwxkRfhwlQbG6JkjsVsIdoPh7fjubMrw0jqMfsVsIdoP3a(Hky34p6W0JJkjqBwkJSOthjlKECujbAZsPN8xG)PPpubor1eFqGpl0KvsJqGvCujbAtVsIdoPNjG7fmVXMrweuGNfspoQKaTzP0t(lW)00t)5Tqf4evt8bb(SqtwjncbwXrLeOL3KL3KpV9QlYBGM3ao48gyGXBp1GMW3fR75oyWcnzd4BGtGww6UXDR4Osc0YBYn9kjo4K(vOgzKr6TOPsjISqw0zwi9kjo4KEca9DX0JJkjqBwkJSiOYcPxjXbN0ZGYWafPhhvsG2Sugzr5LfsVsIdoPNbmo4KECujbAZszKfLJSq6XrLeOnlLEYFb(NMElkrzAwjqbCxQLDn0fqLIr6vsCWj9sci0YAs9anJSiWZcPhhvsG2Su6j)f4FA6TOeLPzLafWDPw21qxa1hn0BwEd08wpsVsIdoPxc)fF6UXnJSypYcPhhvsG2Su6j)f4FA6jqOWczovd4hQGDJ)OdRpAO3S8gO5nNvGZBYYBV6I8Md8gWbp9kjo4KE9j6GSb8FCImYIYzwi94Osc0MLsp5Va)ttVfLOmnReOaUl1YUg6cOAHmhEtwEJaHclK5unGFOc2n(JoS(OHEZMELehCsV4CbellqikRRborgzrGmlKECujbAZsPN8xG)PP3IsuMMvcua3LAzxdDbuPyKELehCsV59OKacTzKfDKSq6XrLeOnlLEYFb(NMElkrzAwjqbCxQLDn0fqLIr6vsCWj96qWnEvWsuHiJSOtWZcPhhvsG2Su6j)f4FA6TOeLPzLafWDPw21qxavlK5WBYYBeiuyHmNQb8dvWUXF0H1hn0B20RK4Gt6LuxwOjB8hHUnJSOtNzH0JJkjqBwk9JAGP)ML8uHkjqwhLsNGYG1IGCem9kjo4K(BwYtfQKazDukDckdwlcYrWmYIobvwi94Osc0MLs)Ogy6TpQwZ7rwqWDrr6vsCWj92hvR59ili4UOiJSOt5LfsVsIdoPNAr2lqJn94Osc0MLYil6uoYcPhhvsG2Su6j)f4FA6xgOqWg67IXwzc4EbZBS8gO5nN8MS8M85ncekSqMtvsOwCd4BuF0qVz5nqZBoboVbgy8wOcCI6RGOU4xXrLeOL3KB6vsCWj9ltezCJl7g)rhUzKfDc8Sq6XrLeOnlLEYFb(NME5ZBHkWjQg6Uk5XkoQKaT8MS8wOVlgvaOkcavgKG3CG3KhW5n5YBGbgVf67IrfaQIaqLbj4nh4nqboVbgy8M85TqFxmQaqveaQmibVbAEdibN3KL3iqqWrNOccobaG(8MCt)g)rISOZ0RK4Gt6jQqWQK4GdR42i9IBd2rnW0J9IeQaZil6ShzH0JJkjqBwk9K)c8pn9lduiyd9DXyRmbCVG5nwEd08MZ0VXFKil6m9kjo4KEIkeSkjo4WkUnsV42GDudm9ausgzrNYzwi94Osc0MLsVsIdoPNOcbRsIdoSIBJ0lUnyh1at)EJRazd9DXiJSOtGmlKELehCspihjGpqzFQfq6XrLeOnlLrw0PJKfsVsIdoP)myGJ9gxwqosaFGMECujbAZszKr6z8ibAiPrwil6mlKELehCsVKgHazxaqQi94Osc0MLYiJ0J9IeQaZczrNzH0RK4Gt6TOAfaLLOcJ0JJkjqBwkJSiOYcPhhvsG2Su6j)f4FA6xgOqWg67IXwzc4EbZBS8whV5K3KL3Cj26Jg6nlV1XBGZBYYBYN3E1f5nqZBYjW5nWaJ3E1f5nqZBahCEtwEtIY0S(iHobU7G7wPyWBYn9kjo4KEIoeuWkrzAMEjktt2rnW0ljulUb8nYilkVSq6XrLeOnlLEYFb(NMEcekSqMtLafWDPw21qxa1hn0BwEZbEdi5nz5nxIT(OHEZYBD8g4PxjXbN0RGOH(zKfLJSq6XrLeOnlLEYFb(NM(xDrEZbERhGZBYYBYN3O)8wOcCIQfvRaOSevyuXrLeOL3admEtIY0SAr1kaklrfgvlK5WBYn9kjo4K(LokHyziUiWpJSiWZcPxjXbN0)kiQl(PhhvsG2SugzXEKfsVsIdoPNahhLcF4VSs6m4NECujbAZszKfLZSq6XrLeOnlLEYFb(NM(LbkeSH(UySvMaUxW8glVbAEZjVjlVzHr1IidwMqQXU1hn0BwEZbEZLytVsIdoPNiqfemJSiqMfsVsIdoPNP(spQ0HF6XrLeOnlLrw0rYcPxjXbN0tGc4Uul7AOlG0JJkjqBwkJSOtWZcPhhvsG2Su6j)f4FA6TOeLPzLafWDPw21qxavkg8gyGXBsuMM1LYAXH1IAaO(OscEdmW4TxDrEd08wpaE6vsCWj9e4yrJjJSOtNzH0JJkjqBwk9K)c8pn9ea67IlV1XBGk9kjo4KEii4ZaYe)mYIobvwi9kjo4KEDihobRAg4VaGe6spoQKaTzPmYIoLxwi9kjo4K(LbQpl0Kvs34Gt6XrLeOnlLrw0PCKfspoQKaTzP0t(lW)00)udAcFxSIJL6VXLvsazwXrLeOL3admEZcJQfrgSmHuJDRpAO3S8MdD8MlXMELehCsVb8dvWUXF0HzKfDc8Sq6XrLeOnlLEYFb(NMEjktZQfvRaOSevyuTqMdVjlV9QlYBoWBah80RK4Gt6LeQf3a(gzKfD2JSq6XrLeOnlLEYFb(NM(xDrEZbEtoap9kjo4K(LokHyziUiWpJSOt5mlKELehCspee8zazIF6XrLeOnlLrw0jqMfsVsIdoPNahlAmPhhvsG2SugzrNoswi9kjo4KESxKqfy6XrLeOnlLrgPhGsYczrNzH0JJkjqBwk9K)c8pn9V6I8Md8wpaN3KL3KOmnRwuTcGYsuHr1czoPxjXbN0V0rjeldXfb(zKfbvwi9kjo4KEcCCuk8H)YkPZGF6XrLeOnlLrwuEzH0JJkjqBwk9K)c8pn9eiuyHmNkbkG7sTSRHUaQpAO3S8Md8MZ0RK4Gt6vq0q)mYIYrwi9kjo4KEM6l9Osh(PhhvsG2SugzrGNfsVsIdoPNafWDPw21qxaPhhvsG2SugzXEKfspoQKaTzP0t(lW)00BHr1IidwMqQXU1hn0BwEZHoEZLytVsIdoPNiqfemJSOCMfsVsIdoPxhYHtWQMb(laiHU0JJkjqBwkJSiqMfsVsIdoPFzG6ZcnzL0no4KECujbAZszKfDKSq6vsCWj9sc1IBaFJ0JJkjqBwkJSOtWZcPxjXbN0)kiQl(PhhvsG2SugzrNoZcPhhvsG2Su6j)f4FA6F0qVz5nh64nl1RXbhEdyM3aVkpEtwEtIY0SUmrKXnUSB8hD4wPyKELehCs)JJnJSOtqLfsVsIdoPNiqfem94Osc0MLYil6uEzH0JJkjqBwk9K)c8pn9suMM1LjImUXLDJ)Od3kfdEdmW4nlmQwezWYesn2T(OHEZYBoWBUelVjlVr)5Tqf4evIavqWkoQKaTPxjXbN0Ba)qfSB8hDygzrNYrwi94Osc0MLsp5Va)ttFOcCIQ9r1okLlGOIJkjqB6vsCWj9qqWNbKj(zKfDc8Sq6vsCWj9e4yrJj94Osc0MLYil6ShzH0JJkjqBwk9K)c8pn9suMM1LjImUXLDJ)Od3kfJ0RK4Gt6XErcvGzKfDkNzH0RK4Gt6HGGpdit8tpoQKaTzPmYIobYSq6vsCWj9mbCVG5n20JJkjqBwkJmYi9GG)EWjlckWbLtWbf4az6zQ)CJ7MEGy6byQiWUiqyGfVXBfaG82zWa(bVzcFERN7nUcKn03fJEYBp6Ou3JwEBHgiVPub0qd0YBea64IBLtdi4gK3C6eyXB0x4ac(bA5TE(udAcFxSs)6jVfqERNp1GMW3fR0VkoQKaT9K3KVZELBLtdi4gK3af4alEJ(chqWpqlV1ZNAqt47Iv6xp5TaYB98Pg0e(UyL(vXrLeOTN8M8D2RCRCACAaX0dWurGDrGWalEJ3kaa5TZGb8dEZe(8wpXErcvG9K3E0rPUhT82cnqEtPcOHgOL3ia0Xf3kNgqWniV5uoaw8g9foGGFGwERNp1GMW3fR0VEYBbK365tnOj8DXk9RIJkjqBp5n57Sx5w5040a2gmGFGwEd48MsIdo8M42yRCAPFzGKSOC6m9mEO5jW07yhZB0ZBS8gqS()bFonh7yEdiQ(ea8MtWLH3af4GYjNgNMJDmVrFbOJlUalonh7yEJE5n6XArlVrFOmmqrLtZXoM3OxEJESw0YBadhjGpq5nGjQfqzGTbdCS34YBadhjGpqRCAo2X8g9YB0J1IwERKgHa5npaivWBbK3y8ibAiPbVrp0hGGkNMJDmVrV8gWyViHko4GFpxEJ(8i52do82T8MffyG2kNMJDmVrV8g9yTOL3aISiVbSd0yRCAo2X8g9YBfyIkD8goXduEZe(8wjHAXnGVrLtJtZXoM3ag7fjubA5nj0e(iVrGgsAWBsO7nBL3OhcbzelVnWHEbOVHjLG3usCWz5n4iaALttjXbNTY4rc0qsJ(DLL0iei7casfCACAo2X8gWyViHkqlVHGGpq5T4mqElaG8Msc4ZB3YBki6jujbw50usCWz7ia03f50usCWz73vMbLHbk40usCWz73vMbmo4WPPK4GZ2VRSKacTSMupqL5m7SOeLPzLafWDPw21qxavkgCAkjo4S97klH)IpD34kZz2zrjktZkbkG7sTSRHUaQpAO3SGUhCAkjo4S97kRprhKnG)JtiZz2rGqHfYCQgWpub7g)rhwF0qVzbTZkWL9vx0bGdoNMsIdoB)UYIZfqSSaHOSUg4eYCMDwuIY0SsGc4Uul7AOlGQfYCKLaHclK5unGFOc2n(JoS(OHEZYPPK4GZ2VRS59OKacTYCMDwuIY0SsGc4Uul7AOlGkfdonLehC2(DL1HGB8QGLOcHmNzNfLOmnReOaUl1YUg6cOsXGttjXbNTFxzj1LfAYg)rOBL5m7SOeLPzLafWDPw21qxavlK5ilbcfwiZPAa)qfSB8hDy9rd9MLttjXbNTFxzQfzVanKzudS7ML8uHkjqwhLsNGYG1IGCeKttjXbNTFxzQfzVanKzudSZ(OAnVhzbb3ffCAkjo4S97ktTi7fOXYPPK4GZ2VR8Yerg34YUXF0HRmNz3Yafc2qFxm2kta3lyEJf0oLv(eiuyHmNQKqT4gW3O(OHEZcANahmWcvGtuFfe1f)koQKaTYLttjXbNTFxzIkeSkjo4WkUnKzudSd7fjubkZg)rIoNYCMDYpubor1q3vjpwXrLeOv2qFxmQaqveaQmiHdYd4YfmWc9DXOcavraOYGeoakWbdm5h67IrfaQIaqLbjanqcUSeii4OtubbNaaqF5YPPK4GZ2VRmrfcwLehCyf3gYmQb2bqjYSXFKOZPmNz3Yafc2qFxm2kta3lyEJf0o50usCWz73vMOcbRsIdoSIBdzg1a72BCfiBOVlgCAkjo4S97kdYrc4du2NAbWPPK4GZ2VR8zWah7nUSGCKa(aLtJttjXbNTI9IeQa7SOAfaLLOcdonLehC2k2lsOcSFxzIoeuWkrzAkZOgyNKqT4gW3qMZSBzGcbBOVlgBLjG7fmVX25uwxIT(OHEZ2bUSY)vxe0YjWbdSxDrqdCWLvIY0S(iHobU7G7wPyixonLehC2k2lsOcSFxzfen0xMZSJaHclK5ujqbCxQLDn0fq9rd9M1bGuwxIT(OHEZ2boNMsIdoBf7fjub2VR8shLqSmexe4lZz29Ql6qpaxw5t)dvGtuTOAfaLLOcJkoQKaTGbMeLPz1IQvauwIkmQwiZrUCAkjo4SvSxKqfy)UYVcI6IpNMsIdoBf7fjub2VRmbookf(WFzL0zWNttjXbNTI9IeQa73vMiqfeuMZSBzGcbBOVlgBLjG7fmVXcANYAHr1IidwMqQXU1hn0BwhCjwonLehC2k2lsOcSFxzM6l9Osh(CAkjo4SvSxKqfy)UYeOaUl1YUg6cGttjXbNTI9IeQa73vMahlAmYCMDwuIY0SsGc4Uul7AOlGkfdWatIY0SUuwloSwuda1hvsagyV6IGUhaNttjXbNTI9IeQa73vgcc(mGmXxMZSJaqFxC7afNMsIdoBf7fjub2VRSoKdNGvnd8xaqcDCAkjo4SvSxKqfy)UYlduFwOjRKUXbhonLehC2k2lsOcSFxzd4hQGDJ)OdL5m7EQbnHVlwXXs934YkjGmbdmlmQwezWYesn2T(OHEZ6qNlXYPPK4GZwXErcvG97kljulUb8nK5m7KOmnRwuTcGYsuHr1czoY(Ql6aWbNttjXbNTI9IeQa73vEPJsiwgIlc8L5m7E1fDqoaNttjXbNTI9IeQa73vgcc(mGmXNttjXbNTI9IeQa73vMahlAmCAkjo4SvSxKqfy)UYyViHkqononLehC2kaL0T0rjeldXfb(YCMDV6Io0dWLvIY0SAr1kaklrfgvlK5WPPK4GZwbOK(DLjWXrPWh(lRKod(CAkjo4SvakPFxzfen0xMZSJaHclK5ujqbCxQLDn0fq9rd9M1bNCAkjo4SvakPFxzM6l9Osh(CAkjo4SvakPFxzcua3LAzxdDbWPPK4GZwbOK(DLjcubbL5m7SWOArKblti1y36Jg6nRdDUelNMsIdoBfGs63vwhYHtWQMb(laiHoonLehC2kaL0VR8Ya1NfAYkPBCWHttjXbNTcqj97kljulUb8n40usCWzRaus)UYVcI6IpNMsIdoBfGs63v(XXkZz29OHEZ6qNL614GdWm4v5jReLPzDzIiJBCz34p6WTsXGttjXbNTcqj97kteOccYPPK4GZwbOK(DLnGFOc2n(JouMZStIY0SUmrKXnUSB8hD4wPyagywyuTiYGLjKASB9rd9M1bxIvw6FOcCIkrGkiyfhvsGwonLehC2kaL0VRmee8zazIVmNzxOcCIQ9r1okLlGOIJkjqlNMsIdoBfGs63vMahlAmCAkjo4SvakPFxzSxKqfOmNzNeLPzDzIiJBCz34p6WTsXGttjXbNTcqj97kdbbFgqM4ZPPK4GZwbOK(DLzc4EbZBSCACAkjo4S19gxbYg67Irhbookf(WFzL0zWxMZSt(MNlGG9rd9Mf0obsWbdm5h67IrfaQIaqLbjCauGdgyHkWjQg6Uk5XkoQKaTYg67IrfaQIaqLbjCqEaxUYLttjXbNTU34kq2qFxm6ECSYCMDpAO3So0zPEno4amdEvECAkjo4S19gxbYg67Ir)UYkiAOVmNzhbcfwiZPsGc4Uul7AOlG6Jg6nRdaPSUeB9rd9MTdConLehC26EJRazd9DXOFxzIavqqzoZULbkeSH(UySvMaUxW8glODkRfgvlImyzcPg7wF0qVzDWLy50usCWzR7nUcKn03fJ(DLFfe1fFonLehC26EJRazd9DXOFxzM6l9Osh(CAkjo4S19gxbYg67Ir)UYeOaUl1YUg6cGttjXbNTU34kq2qFxm63vwhYHtWQMb(laiHoonLehC26EJRazd9DXOFx5LbQpl0Kvs34GdNMsIdoBDVXvGSH(Uy0VRmee8zazIVmNzhbG(U42bkonLehC26EJRazd9DXOFxzd4hQGDJ)OdL5m7EQbnHVlwXXs934YkjGmbdmjktZkee8zazIFDdLqhO7afyGjFlmQwezWYesn2T(OHEZ6qNlXklbcfwiZPsGc4Uul7AOlG6Jg6nlODjw5YPPK4GZw3BCfiBOVlg97kljulUb8nK5m7KOmnRwuTcGYsuHr1czoYkFlkrzAwjqbCxQLDn0fqLIHSV6IoipWbdSxDrhao4YLttjXbNTU34kq2qFxm63v2IQvauwIkm40usCWzR7nUcKn03fJ(DLx6OeILH4IaFzoZUxDrh6b4YkrzAwTOAfaLLOcJQfYC40usCWzR7nUcKn03fJ(DLHGGpdit850usCWzR7nUcKn03fJ(DLjWXIgJmNzNeLPzDPSwCyTOgaQpQKGttjXbNTU34kq2qFxm63vg7fjubkZz2jrzAwxkRfhwlQbG6Jkj40usCWzR7nUcKn03fJ(DLnGFOc2n(JoKttjXbNTU34kq2qFxm63vMjG7fmVXkZz2fQaNOAIpiWNfAYkPriWkoQKaTCAkjo4S19gxbYg67Ir)UYRqnK5m7O)HkWjQM4dc8zHMSsAecSIJkjqRSY)vxe0ahCWa7Pg0e(UyDp3bdwOjBaFdCc0Ys3nURCZiJmb]] )


end
