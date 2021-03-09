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


    spec:RegisterPack( "Arms", 20210208, [[dCKZQaqijP4rss2Ki0NebQgfOGtbI0Qeb0RKsMfkPBbkQDjXVKeddL4yIkltkvpte00erQRjIyBss13erY4qs5CssP1bkunpqP7jf7djvheuKfkQ6HIaLlcku2iiI0jfbyLGQzcke2PO0qfbYsbru9uknvrXvbfI2kOq6RGik7v4VOyWs1HjwmQ8yetMIldTzr6ZsQrdsNwPvdIiEnsYSj52OQDR43adhjooiclxvpxLPt11rQTdcFhLA8GOoVukZxe1(j1rUitynIJr22zP9CS0oluRKRAti1s62dR3gfmSuecvsng2r4XWctp)fwksBkGyImH9a0pbdlu3PCW4vQuVouAUcbWx5wEAL4lyiVK6vULNujSC0RYtatWfwJ4yKTDwAphlTZc1k5Q2esTewTHvODOGpS2LNwj(cMeSxs9WcDngCcUWAWJe2QQs3HPN)0DizY)l41WRQkDhskY90Y3MUtnw192zP9CA4A4vvLUNGbvMA8GX1WRQkDhM1DyYyqJUNGO55rvrdVQQ0Dyw3HjJbn6om6sCW3MUdjN(GwjbWtbhZo16om6sCW3wrdVQQ0Dyw3HjJbn6EEXDfQ7wOaAx3DGUt5rcGNtCDhMsqWikA4vvLUdZ6omgKrcTVGb)e8t3tqps2BbJUVNUBqf6OPOHxvv6omR7WKXGgDhg5H6EcWr(ROHxvv6omR7zyJcv6oo(3MUNcEDpVsm45GNVew1E(fzc7TtTczC5RrpYezZfzclocNcnr(Ws(1XFLWcd6E6wd1zEKx250DQR75Ogl6EYjR7WGU7YxJEbkkkhAHcX1Dy192zr3tozD3ffoEHxUtipwWr4uOr3tu3D5RrVaffLdTqH46oS6EctIUdP6oKgwH4lyclbmqcA8b)XWjZGF4r22JmHfhHtHMiFyj)64VsyjaGYaypfcqbUJ(yoE5GwEKx250Dy1DQP7jQ71et5rEzNt3B0DwcRq8fmHvGqC5dpYMWityXr4uOjYhwYVo(Re2h5LDoDh2gD3q)IVGr3tG6olLegwH4lyc7JJj8iBshzclocNcnr(Ws(1XFLWEuqLIXLVg9RWg6(k27y0DQR7509e1DdWlgePWWgqpMR8iVSZP7WQ71etyfIVGjSefkqGHhztsKjScXxWew2YZ9Oqf(HfhHtHMiF4r2QhzcRq8fmHLauG7OpMJxoOHfhHtHMiF4r2KkYewCeofAI8HL8RJ)kHLJonTiqiU8Lh5LDoDhwDph109e19Qr3naV8cesn(Lh5LDUWkeFbtyFbcPg)WJSulYewH4lycRmKfhNrsD8pOacvHfhHtHMiF4r2QnYewH4lyc7rbLNbKYWjNVGjS4iCk0e5dpYMJLityXr4uOjYhwYVo(Rewcu5RXt3B092dRq8fmHfab(uaSXp8iBUCrMWIJWPqtKpSKFD8xjSC0PPfdkgvBmerXxma2JUNOUdd6Ub5OttleGcCh9XC8YbTqtr3tu3FPg1Dy19eYIUNCY6(l1OUdRUNuSO7qAyfIVGjSCkXGNdE(WJS5ApYewCeofAI8HL8RJ)kHLJonTaGaFka24xoxiuP7uVr3Bx3tu35OttlgumQ2yiIIVyaShDp5K1Dyq3naVyqKcdBa9yUYJ8YoNUdBJUxtm6EI6obauga7PqakWD0hZXlh0YJ8YoNUtDDVMy0DinScXxWewEW7II58FPcdpYMlHrMWkeFbtynOyuTXqefFyXr4uOjYhEKnxshzclocNcnr(Ws(1XFLW(snQ7WQ7vNfDprDNJonTyqXOAJHik(IbWEcRq8fmH9OIwPokQ1D8dpYMljrMWkeFbtybqGpfaB8dlocNcnr(WJS5QEKjS4iCk0e5dl5xh)vclhDAA5OngCymO4qlpkepScXxWewcymi)eEKnxsfzclocNcnr(Ws(1XFLWYrNMwoAJbhgdko0YJcXdRq8fmHfHmsODm8iBoQfzcRq8fmHLh8UOyo)xQWWIJWPqtKp8iBUQnYewCeofAI8HL8RJ)kH1ffoEjfFiapdiLHtCxHfCeofAcRq8fmHLn09vS3XeEKTDwImHfhHtHMiFyj)64VsyRgD3ffoEjfFiapdiLHtCxHfCeofAcRq8fmH9ucF4HhwdMk0kpYezZfzcRq8fmHLav(AmS4iCk0e5dpY2EKjScXxWewk088OkS4iCk0e5dpYMWityfIVGjSua(cMWIJWPqtKp8iBshzclocNcnr(Ws(1XFLWAqo600cbOa3rFmhVCql0ucRq8fmHLtbagMu6VTWJSjjYewCeofAI8HL8RJ)kH1GC0PPfcqbUJ(yoE5GwEKx250DQR7vpScXxWewo8p8PAN6WJSvpYewCeofAI8HL8RJ)kHLaakdG9u4bVlkMZ)LkS8iVSZP7ux3ZvsIUNOU)snQ7WQ7jHLWkeFbtyLNidY4G)XXdpYMurMWIJWPqtKpSKFD8xjSgKJonTqakWD0hZXlh0IbWE09e1DcaOma2tHh8UOyo)xQWYJ8YoxyfIVGjSQTgQFmqsOn1844HhzPwKjS4iCk0e5dl5xh)vcRb5OttleGcCh9XC8YbTqtjScXxWe209rofaycpYwTrMWIJWPqtKpSKFD8xjSgKJonTqakWD0hZXlh0cnLWkeFbtyLHGN)IIHikv4r2CSezclocNcnr(Ws(1XFLWAqo600cbOa3rFmhVCqlga7r3tu3jaGYaypfEW7II58FPclpYl7CHvi(cMWYj1mGug)xcvx4r2C5ImHfhHtHMiFyhHhd7oh5PDHtHmqcAzCAEgdcXsWWkeFbty35ipTlCkKbsqlJtZZyqiwcgEKnx7rMWIJWPqtKpSJWJH18Oys3hzGaVdvHvi(cMWAEumP7JmqG3HQWJS5syKjScXxWew6dzwh5VWIJWPqtKp8iBUKoYewCeofAI8HL8RJ)kH9OGkfJlFn6xHn09vS3XO7ux3ZP7jQ7WGUtaaLbWEkCkXGNdE(YJ8YoNUtDDpxs09Ktw3DrHJxEbcPg)cocNcn6oKgwH4lyc7Xgrk7uZC(VuHx4r2CjjYewCeofAI8HL8RJ)kHfg0Dxu44fE5oH8ybhHtHgDprD3LVg9cuuuo0cfIR7WQ7jmj6oKQ7jNSU7YxJEbkkkhAHcX1Dy192zr3tozDhg0Dx(A0lqrr5qluiUUtDDNASO7jQ7eae4iJxGahhABVUdPH98FjEKnxyfIVGjSerPyeIVGHrTNhw1EoZi8yyriJeAhdpYMR6rMWIJWPqtKpSKFD8xjShfuPyC5Rr)kSHUVI9ogDN66EUWE(VepYMlScXxWewIOumcXxWWO2ZdRApNzeEmSqfs4r2CjvKjS4iCk0e5dRq8fmHLikfJq8fmmQ98WQ2ZzgHhd7TtTczC5Rrp8iBoQfzcRq8fmHfIL4GVnMN(GgwCeofAI8HhzZvTrMWkeFbtyxEk4y2PMbIL4GVTWIJWPqtKp8WdlLhjaEoXJmr2CrMWkeFbty5e3viZbfq7HfhHtHMiF4HhweYiH2XitKnxKjScXxWewdkgvBmerXhwCeofAI8HhzBpYewCeofAI8HL8RJ)kH9rEzNt3HTr3n0V4ly09eOUZsjHHvi(cMW(4ycpYMWityXr4uOjYhwYVo(Re2xQrDhwDV6SO7jQ7WGUxn6UlkC8IbfJQngIO4l4iCk0O7jNSUZrNMwmOyuTXqefFXayp6oKgwH4lyc7rfTsDuuR74hEKnPJmHfhHtHMiFyj)64VsyjaGYaypfcqbUJ(yoE5GwEKx250Dy1DQP7jQ71et5rEzNt3B0DwcRq8fmHvGqC5dpYMKityXr4uOjYhwYVo(Rewo600IaH4YxEKx250Dy19Cut3tu3RgD3a8Ylqi14xEKx25cRq8fmH9fiKA8dpYw9ityfIVGjSeWajOXh8hdNmd(HfhHtHMiF4r2KkYewCeofAI8HL8RJ)kH9OGkfJlFn6xHn09vS3XO7ux3ZP7jQ7gGxmisHHnGEmx5rEzNt3Hv3RjMWkeFbtyjkuGadpYsTityfIVGjSSLN7rHk8dlocNcnr(WJSvBKjScXxWewcqbUJ(yoE5GgwCeofAI8HhzZXsKjS4iCk0e5dl5xh)vcRb5OttleGcCh9XC8YbTqtr3tozDNJonTC0gdomguCOLhfIR7jNSU)snQ7ux3REscRq8fmHLagdYpHhzZLlYewCeofAI8HL8RJ)kHLav(A809gDV9WkeFbtybqGpfaB8dpYMR9ityfIVGjSYqwCCgj1X)GciufwCeofAI8HhzZLWityfIVGjShfuEgqkdNC(cMWIJWPqtKp8iBUKoYewCeofAI8HL8RJ)kHLJonTyqXOAJHik(IbWE09e19xQrDhwDpjSewH4lyclNsm45GNp8iBUKezclocNcnr(Ws(1XFLWAaEXGifg2a6XCLh5LDoDh2gDVMycRq8fmHLh8UOyo)xQWWJS5QEKjS4iCk0e5dl5xh)vc7l1OUdRUN0SewH4lyc7rfTsDuuR74hEKnxsfzcRq8fmHfab(uaSXpS4iCk0e5dpYMJArMWkeFbtyjGXG8tyXr4uOjYhEKnx1gzcRq8fmHfHmsODmS4iCk0e5dp8WcvirMiBUityXr4uOjYhwYVo(Re2xQrDhwDV6SO7jQ7C0PPfdkgvBmerXxma2tyfIVGjShv0k1rrTUJF4r22JmHvi(cMWsadKGgFWFmCYm4hwCeofAI8HhztyKjS4iCk0e5dl5xh)vclbauga7PqakWD0hZXlh0YJ8YoNUdRUNlScXxWewbcXLp8iBshzclocNcnr(Ws(1XFLWAaEXGifg2a6XCLh5LDoDh2gDVMycRq8fmHLOqbcm8iBsImHvi(cMWYwEUhfQWpS4iCk0e5dpYw9ityfIVGjSYqwCCgj1X)GciufwCeofAI8HhztQityfIVGjShfuEgqkdNC(cMWIJWPqtKp8il1ImHvi(cMWYPedEo45dlocNcnr(WJSvBKjScXxWe2xGqQXpS4iCk0e5dpYMJLityfIVGjSeGcCh9XC8YbnS4iCk0e5dpYMlxKjS4iCk0e5dl5xh)vc7J8YoNUdBJUBOFXxWO7jqDNLsc19e1Do600YXgrk7uZC(VuHxHMsyfIVGjSpoMWJS5ApYewH4lyclrHceyyXr4uOjYhEKnxcJmHfhHtHMiFyj)64Vsy5OttlhBePStnZ5)sfEfAk6EYjR7gGxmisHHnGEmx5rEzNt3Hv3RjgDprDVA0Dxu44fIcfiWcocNcnHvi(cMWYdExumN)lvy4r2CjDKjS4iCk0e5dl5xh)vcRlkC8I5rXmcDnuVGJWPqtyfIVGjSaiWNcGn(HhzZLKityfIVGjSeWyq(jS4iCk0e5dpYMR6rMWIJWPqtKpSKFD8xjSC0PPLJnIu2PM58FPcVcnLWkeFbtyriJeAhdpYMlPImHvi(cMWcGaFka24hwCeofAI8HhzZrTityfIVGjSSHUVI9oMWIJWPqtKp8WdpSqG)TGjY2olTNJL2zP9WYw(zN6lSjaEkG3rJUNeDxi(cgDxTNFfn8WEuqsKnPYfwkpiDvyyRQkDhME(t3HKj)VGxdVQQ0DiPi3tlFB6o1yv3BNL2ZPHRHxvv6EcguzQXdgxdVQQ0Dyw3HjJbn6EcIMNhvfn8QQs3HzDhMmg0O7WOlXbFB6oKC6dALeapfCm7uR7WOlXbFBfn8QQs3HzDhMmg0O75f3vOUBHcODD3b6oLhjaEoX1DykbbJOOHxvv6omR7Wyqgj0(cg8tWpDpb9izVfm6(E6UbvOJMIgEvvP7WSUdtgdA0DyKhQ7jah5VIgEvvP7WSUNHnkuP744FB6Ek4198kXGNdE(IgUgEvvP7Wyqgj0oA0Domf8OUta8CIR7Cy9oxr3HjcbP4NUpGbMHkpFkTs3fIVG50DWOAROHleFbZvO8ibWZjERMkCI7kK5GcODnCn8QQs3HXGmsOD0O7ie43MU7lpQ7ouu3fIdEDFpDxGqwLWPWIgUq8fmxdbQ81OgUq8fmxRMkuO55rLgUq8fmxRMkua(cgnCH4lyUwnv4uaGHjL(BJ1nTXGC0PPfcqbUJ(yoE5GwOPOHleFbZ1QPch(h(uTtnRBAJb5OttleGcCh9XC8YbT8iVSZr9QRHleFbZ1QPI8ezqgh8pooRBAdbauga7PWdExumN)lvy5rEzNJ65kjjXxQrytclA4cXxWCTAQO2AO(XajH2uZJJZ6M2yqo600cbOa3rFmhVCqlga7jrcaOma2tHh8UOyo)xQWYJ8YoNgUq8fmxRMkP7JCkaWW6M2yqo600cbOa3rFmhVCql0u0WfIVG5A1urgcE(lkgIOuSUPngKJonTqakWD0hZXlh0cnfnCH4lyUwnv4KAgqkJ)lHQJ1nTXGC0PPfcqbUJ(yoE5Gwma2tIeaqzaSNcp4DrXC(VuHLh5LDonCH4lyUwnvOpKzDKN1r4XMDoYt7cNczGe0Y408mgeILGA4cXxWCTAQqFiZ6ipRJWJnMhft6(ide4DOsdxi(cMRvtf6dzwh5pnCH4lyUwnvo2iszNAMZ)Lk8yDtBokOsX4YxJ(vydDFf7DmupxIWabauga7PWPedEo45lpYl7Cupxssozxu44LxGqQXVGJWPqdKQHleFbZ1QPcrukgH4lyyu75Socp2Gqgj0oY65)s8MCSUPnWGlkC8cVCNqESGJWPqtIU81OxGIIYHwOqCytysG0Kt2LVg9cuuuo0cfIdB7SKCYWGlFn6fOOOCOfkeN6uJLejaiWrgVaboo02Eivdxi(cMRvtfIOumcXxWWO2ZzDeESbQqy98FjEtow30MJcQumU81OFf2q3xXEhd1ZPHleFbZ1QPcrukgH4lyyu75Socp2C7uRqgx(A01WfIVG5A1ubIL4GVnMN(GQHleFbZ1QPYYtbhZo1mqSeh8TPHRHleFbZvqiJeAhBmOyuTXqefVgUq8fmxbHmsODSvtLhhdRBAZJ8YohSng6x8fmjqwkjudxi(cMRGqgj0o2QPYrfTsDuuR74Z6M28sncB1zjryOACrHJxmOyuTXqefFbhHtHMKtMJonTyqXOAJHik(IbWEGunCH4lyUcczKq7yRMkceIlpRBAdbauga7PqakWD0hZXlh0YJ8YohSulXAIP8iVSZ1WIgUq8fmxbHmsODSvtLxGqQXN1nTHJonTiqiU8Lh5LDoyZrTeRgdWlVaHuJF5rEzNtdxi(cMRGqgj0o2QPcbmqcA8b)XWjZGVgUq8fmxbHmsODSvtfIcfiqw30MJcQumU81OFf2q3xXEhd1ZLOb4fdIuyydOhZvEKx25GTMy0WfIVG5kiKrcTJTAQWwEUhfQWxdxi(cMRGqgj0o2QPcbOa3rFmhVCq1WfIVG5kiKrcTJTAQqaJb5hw30gdYrNMwiaf4o6J54LdAHMsYjZrNMwoAJbhgdko0YJcXto5xQrQx9KOHleFbZvqiJeAhB1ubab(uaSXN1nTHav(A8AAxdxi(cMRGqgj0o2QPImKfhNrsD8pOacvA4cXxWCfeYiH2XwnvokO8mGugo58fmA4cXxWCfeYiH2Xwnv4uIbph88SUPnC0PPfdkgvBmerXxma2tIVuJWMew0WfIVG5kiKrcTJTAQWdExumN)lviRBAJb4fdIuyydOhZvEKx25GTPMy0WfIVG5kiKrcTJTAQCurRuhf16o(SUPnVuJWM0SOHleFbZvqiJeAhB1ubab(uaSXxdxi(cMRGqgj0o2QPcbmgKF0WfIVG5kiKrcTJTAQGqgj0oQHRHleFbZvGkKMJkAL6OOw3XN1nT5LAe2QZsIC0PPfdkgvBmerXxma2JgUq8fmxbQqA1uHagibn(G)y4KzWxdxi(cMRaviTAQiqiU8SUPneaqzaSNcbOa3rFmhVCqlpYl7CWMtdxi(cMRaviTAQquOabY6M2yaEXGifg2a6XCLh5LDoyBQjgnCH4lyUcuH0QPcB55EuOcFnCH4lyUcuH0QPImKfhNrsD8pOacvA4cXxWCfOcPvtLJckpdiLHtoFbJgUq8fmxbQqA1uHtjg8CWZRHleFbZvGkKwnvEbcPgFnCH4lyUcuH0QPcbOa3rFmhVCq1WfIVG5kqfsRMkpogw30Mh5LDoyBm0V4lysGSusyIC0PPLJnIu2PM58FPcVcnfnCH4lyUcuH0QPcrHceOgUq8fmxbQqA1uHh8UOyo)xQqw30go600YXgrk7uZC(VuHxHMsYjBaEXGifg2a6XCLh5LDoyRjMeRgxu44fIcfiWcocNcnA4cXxWCfOcPvtfae4tbWgFw30gxu44fZJIze6AOEbhHtHgnCH4lyUcuH0QPcbmgKF0WfIVG5kqfsRMkiKrcTJSUPnC0PPLJnIu2PM58FPcVcnfnCH4lyUcuH0QPcac8PayJVgUq8fmxbQqA1uHn09vS3XOHRHleFbZvUDQviJlFn6neWajOXh8hdNmd(SUPnWq6wd1zEKx25OEoQXsYjddU81OxGIIYHwOqCyBNLKt2ffoEHxUtipwWr4uOjrx(A0lqrr5qluioSjmjqkKQHleFbZvUDQviJlFn6TAQiqiU8SUPneaqzaSNcbOa3rFmhVCqlpYl7CWsTeRjMYJ8YoxdlA4cXxWCLBNAfY4YxJERMkpogw30Mh5LDoyBm0V4lysGSusOgUq8fmx52PwHmU81O3QPcrHceiRBAZrbvkgx(A0VcBO7RyVJH65s0a8IbrkmSb0J5kpYl7CWwtmA4cXxWCLBNAfY4YxJERMkSLN7rHk81WfIVG5k3o1kKXLVg9wnviaf4o6J54LdQgUq8fmx52PwHmU81O3QPYlqi14Z6M2WrNMweiex(YJ8YohS5OwIvJb4LxGqQXV8iVSZPHleFbZvUDQviJlFn6TAQidzXXzKuh)dkGqLgUq8fmx52PwHmU81O3QPYrbLNbKYWjNVGrdxi(cMRC7uRqgx(A0B1ubab(uaSXN1nTHav(A8AAxdxi(cMRC7uRqgx(A0B1uHtjg8CWZZ6M2WrNMwmOyuTXqefFXaypjcdgKJonTqakWD0hZXlh0cnLeFPgHnHSKCYVuJWMuSaPA4cXxWCLBNAfY4YxJERMk8G3ffZ5)sfY6M2WrNMwaqGpfaB8lNleQOEt7jYrNMwmOyuTXqefFXaypjNmmyaEXGifg2a6XCLh5LDoyBQjMejaGYaypfcqbUJ(yoE5GwEKx25OEnXaPA4cXxWCLBNAfY4YxJERMkgumQ2yiIIxdxi(cMRC7uRqgx(A0B1u5OIwPokQ1D8zDtBEPgHT6SKihDAAXGIr1gdru8fdG9OHleFbZvUDQviJlFn6TAQaGaFka24RHleFbZvUDQviJlFn6TAQqaJb5hw30go600YrBm4WyqXHwEuiUgUq8fmx52PwHmU81O3QPcczKq7iRBAdhDAA5OngCymO4qlpkexdxi(cMRC7uRqgx(A0B1uHh8UOyo)xQqnCH4lyUYTtTczC5RrVvtf2q3xXEhdRBAJlkC8sk(qaEgqkdN4Ucl4iCk0OHleFbZvUDQviJlFn6TAQCkHN1nTPACrHJxsXhcWZasz4e3vybhHtHMWdpca]] )


end
