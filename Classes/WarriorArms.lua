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

            interval = 'mainhand_speed',

            stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * arms_rage_mult * state.swings.mainhand_speed
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
            duration = 5,
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
        }
    } )


    local rageSpent = 0

    spec:RegisterStateExpr( "rage_spent", function ()
        return rageSpent
    end )

    local rageSinceBanner = 0

    spec:RegisterStateExpr( "rage_since_banner", function ()
        return rageSinceBanner
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

            if buff.conquerors_frenzy.up then
                rage_since_banner = rage_since_banner + amt
                local stacks = floor( rage_since_banner / 20 )
                rage_since_banner = rage_since_banner % 20

                if stacks > 0 then
                    addStack( "glory", nil, stacks )
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
            elseif spellName == class.abilities.conquerors_banner.name then
                rageSinceBanner = 0
            end
        end
    end )


    local RAGE = Enum.PowerType.Rage
    local lastRage = -1

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( unit, powerType )
        if powerType == RAGE then
            local current = UnitPower( "player", RAGE )

            if current < lastRage then
                rageSpent = ( rageSpent + lastRage - current ) % 20 -- Anger Mgmt.                
                rageSinceBanner = ( rageSinceBanner + lastRage - current ) % 20 -- Glory.
            end

            lastRage = current
        end
    end )


    local cs_actual

    spec:RegisterHook( "reset_precast", function ()
        rage_spent = nil
        rage_since_banner = nil

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
            gcd = "spell",

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
                return 30 - ( buff.battlelord.up and 12 or 0 )
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

            notalent = "cleave",

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
                applyBuff( "conquerors_frenzy" )
                if conduit.veterans_repute.enabled then
                    applyBuff( "veterans_repute" )
                    addStack( "glory", nil, 5 )
                end
                rage_since_banner = 0
            end,

            auras = {
                conquerors_frenzy = {
                    id = 325862,
                    duration = 20,
                    max_stack = 1
                },
                glory = {
                    id = 325787,
                    duration = 30,
                    max_stack = 30
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
            cooldown = 6,
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

            copy = { 317485, 330325, 317349 }
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

        potion = "potion_of_unbridled_fury",

        package = "Arms",
    } )


    spec:RegisterPack( "Arms", 20201024, [[dKu5AbqivkpIqkBcH(KksrgfcCke0QuPQ6vQiMLkHBrir7c0VKkmmvuhJawgH4zQuzAes11iqTnvK03iKW4urIZrijRJqsP5rqUNOQ9jvQdQsvzHsf9qcjfxufPsNufPQvsqntvKs5MQif1oLk5NQiLyOesQwQksbpLkMQOsxvfPqBvfPIVQIuQ2lv9xIgmshwyXi6XumzsDzOntPplvnAr50OA1Ik8AvIMnj3wKDJYVvA4QWXvrkPLd8CftxY1LY2jq(oHA8QuLZRsA9IkA(uP9RQ9c4Z17OJc9DjYzrolWzreD4zrLiNIOlQ8o11d07CeMlJE07WIe6DUpqA8ohXv1gAFUENzBad6DYQ6ye12rh98kRrcnBQJHNAQO4lZacB1XWtMo8oKnUQo9mpP3rhf67sKZICwGZIi6WZIkrofbeW7eTkBbEhhEQPIIVmrnGWwENmUwJmpP3rJJX7iAp9(aP5PN2daGVGxyr7PNwm1sIGNkIOFXtf5SiNFHFHfTNkQjly94iQ9fw0EQO8P3NwJ6NkQ3sjubFHfTNkkF69P1O(PNoCtTGRp90qBY640NoqMMZ6F6Pd3ul4k8fw0EQO8P3NwJ6N2zuLcFQt22QNw7tpaOztKr907tu)0g8fw0EQO8PNU3dnTIVmeCAAEQOoan8HVSNYNNQrfwOg(clApvu(07tRr9tpno4tp9fMg4lSO9ur5tVpT(PiRaxFQDbpTtvOXPwq6PI7yFAU4upDTp90mVpREkb2f8ufkiuXz9x80t)t7B4mec9ok(uJpxVZWz9kuwbOhlFU(UeWNR3bzbPc1(o9ogaVqap8oamfC28uHY)uDdefFzp9(F6z4DENWu8L5Dait7lFxI4Z17eMIVmVJgdT6Q0eQK3bzbPc1(o9LVR7856DqwqQqTVtVJbWleWdVdi6XNk0tp1ZpL4tjBwluJHwDvAcvcQxXSNs8PKnRfMW0cUkxRu1mCTudWinq9kM9ux3NcIE8Pc9uro7DctXxM3zUSPuZHIxfc8LVlr3NR3bzbPc1(o9ogaVqap8oe8uZUk9kMbnRANPnYjftgeGPGZMNk0tf5PUUpLGNwHczfuCaibyCjcGilivO(PeFQzxLEfZGIdajaJlraeGPGZMNk0tf5Pe(uc9oHP4lZ7acbf9iWx(UeSpxVdYcsfQ9D6DmaEHaE4D0Bb1iEifVnMEGamfC28uHY)uDdefFzp9(F6z4DpL4tj4PZbQuYka9ynqXzCGsmNPFA(NkWtDDF6TNwHczf0OWqqiezbPc1pLqVtyk(Y8oPfuHsofGFj6lFxNQpxVdYcsfQ9D6DmaEHaE4DMduPKva6XAGIZ4aLyot)0UFQipL4t1Bb1iEifVnMEGamfC28uHY)uDdefFzp9(F6z4DENWu8L5Dmkmee6lFxIcFUEhKfKku7707ya8cb8W7C7P4miZGqZY0iBqTuXTODbgeISGuH6Ns8P3EAfkKvWumtyaiezbPc1pL4tj4Pva6Xcw8ekRvEykPiNFA3pvGZp119PwEFwjbyk4S5PD)ubF(Pe(ux3NIZGmdcnltJSb1sf3I2fyqiYcsfQFkXNE7PvOqwbtXmHbGqKfKku)uIpLGNwbOhlyXtOSw5HPKIC(PD)ubo)ux3NA59zLeGPGZMN29tpLZpLWN66(0kuiRGPyMWaqiYcsfQFkXNsWtRa0JfS4juwR8WuY7e8t7(PcC(PUUp1Y7ZkjatbNnpT7Nk4ZpLqVtyk(Y8oMvTZ0g5KIjZx(UofFUEhKfKku7707ya8cb8W7C7P4miZGqZY0iBqTuXTODbgeISGuH6Ns8P3EAfkKvWumtyaiezbPc1pL4tj4Pva6Xcw8ekRvEykPiNFA3pvGZp119PwEFwjbyk4S5PD)ubF(Pe(ux3NIZGmdcnltJSb1sf3I2fyqiYcsfQFkXNE7PvOqwbtXmHbGqKfKku)uIpLGNwbOhlyXtOSw5HPKIC(PD)ubo)ux3NA59zLeGPGZMN29tpLZpLWN66(0kuiRGPyMWaqiYcsfQFkXNsWtRa0JfS4juwR8WuY7e8t7(PcC(PUUp1Y7ZkjatbNnpT7Nk4ZpLqVtyk(Y8oIdajaJlrGV8DjQ856DqwqQqTVtVJbWleWdVdzZAHttRrMuJrLbbyykVtyk(Y8o49qtRqF57sGZ(C9oilivO23P3Xa4fc4H3XSRsVIzW0cQqjNcWVeHamfC28uIpLGNQrYM1cnRANPnYjftguVIzpL4tjBwlSWPKRvM49zfSD8ux3NQrYM1cnRANPnYjftgSD8uIp92tJCIaEHWcNsUwzI3NvqKfKku)ucFkXNsWtV90kuiRGAm0QRstOsqKfKku)ux3Ns2SwOgdT6Q0eQeuVIzpLWNs8PKnRfMW0cUkxRu1mCTudWinq9kM9uIpfe94tf6PI(zVtyk(Y8oKQqJtTGKV8DjGa(C9oilivO23P3Xa4fc4H3zoqLswbOhRbkoJduI5m9tZ)ubEQR7tV90kuiRGgfgccHilivO27eMIVmVtAbvOKtb4xI(Y3LaI4Z17GSGuHAFNEhdGxiGhEN5avkzfGESgO4moqjMZ0pT7NkI3jmfFzEhJcdbH(Y3La35Z17GSGuHAFNEhdGxiGhEhcEkbpLGNs2Swyctl4QCTsvZW1snaJ0aBhpLWN66(ucEQgjBwl0SQDM2iNumzW2Xtj8PUUpLGNs2SwOgdT6Q0eQeSD8ucFkHpL4tRqHScArGGwGCTsYOkfcrwqQq9tj8PUUpLGNsWtjBwlmHPfCvUwPQz4APgGrAGTJN66(uq0JpT7NEkIQNs4tj(uns2SwOzv7mTroPyYGTJNs8PKnRfw4uY1kt8(ScQxXSNs8P3EAfkKvqlce0cKRvsgvPqiYcsfQFkHENWu8L5DeNXbkXCM2x(Ueq0956DqwqQqTVtVJbWleWdVZTNwHczf0IabTa5ALKrvkeISGuH6Ns8Pe8uYM1ctyAbxLRvQAgUwQbyKgy74PUUpvJKnRfAw1otBKtkMmy74Pe6DctXxM3zurYx(UeqW(C9oHP4lZ7SccbhRye4DqwqQqTVtF57sGt1NR3bzbPc1(o9ogaVqap8ovOqwbTiqqlqUwjzuLcHilivO(PeFkbpLSzTWcNsUwzI3NvW2XtDDFQgjBwl0SQDM2iNumzq9kM9uIpLSzTWcNsUwzI3Nvq9kM9uIpfe94t7(PN65NsO3jmfFzEhXzCGsmNP9LVlbef(C9oilivO23P3Xa4fc4H352tRqHScArGGwGCTsYOkfcrwqQqT3jmfFzENrfjF57sGtXNR3jmfFzEhbXn1cUkbTjZ7GSGuHAFN(Y3LaIkFUENWu8L5D4PdKP5SEPG4MAbx9oilivO23PV8L3bVhAAf6Z13La(C9oilivO23P3Xa4fc4H3bGPGZMNku(NQBGO4l7P3)tpdVZ7eMIVmVdazAF57seFUENWu8L5D0yOvxLMqL8oilivO23PV8DDNpxVdYcsfQ9D6DmaEHaE4Darp(uHEQGf5PeFkzZAHjmTGRY1kvndxl1amsduVIzp119PGOhFQqpvKZENWu8L5DMlBk1CO4vHaF57s0956DqwqQqTVtVJbWleWdVJzxLEfZGMvTZ0g5KIjdcWuWzZtf6PI8ux3NsWtRqHSckoaKamUebqKfKku)uIp1SRsVIzqXbGeGXLiacWuWzZtf6PI8uc9oHP4lZ7acbf9iWx(UeSpxVdYcsfQ9D6DmaEHaE4DU9uCgKzqyctl4QCTsvZW1snaJ0atrowWtDDFkbpLSzTWeMwWv5ALQMHRLAagPb2oEQR7tn7Q0RygmHPfCvUwPQz4APgGrAGamfC280UFQaNFkHENWu8L5DmRANPnYjftMV8DDQ(C9oilivO23P3Xa4fc4H352tXzqMbHjmTGRY1kvndxl1amsdmf5ybp119Pe8uYM1ctyAbxLRvQAgUwQbyKgy74PUUp1SRsVIzWeMwWv5ALQMHRLAagPbcWuWzZt7(PcC(Pe6DctXxM3rCaibyCjc8LVlrHpxVdYcsfQ9D6DmaEHaE4D0Bb1iEifVnMEGamfC28uHY)uDdefFzp9(F6z4DpL4tj4PZbQuYka9ynqXzCGsmNPFA(NkWtDDF6TNohOsjRa0J1afNXbkXCM(PD)ubEkXNE7PvOqwbnkmeecrwqQq9tj07eMIVmVtAbvOKtb4xI(Y31P4Z17GSGuHAFNEhdGxiGhEhcE6CGkLScqpwduCghOeZz6N29tf5PeFQElOgXdP4TX0deGPGZMNku(NQBGO4l7P3)tpdV7Pe(ux3NsWtNduPKva6XAGIZ4aLyot)0UF6DpLqVtyk(Y8ogfgcc9LVlrLpxVdYcsfQ9D6DmaEHaE4DU9uYM1ctyAbxLRvQAgUwQbyKgy74PeFkzZAHfoLCTYeVpRGTJNs8PGOhFQqp9UZpL4tV9uYM1c1yOvxLMqLGTdVtyk(Y8oKQqJtTGKV8DjWzFUEhKfKku7707ya8cb8W7q2Swyctl4QCTsvZW1snaJ0aBhp119PKnRfQXqRUknHkbBhp119PAKSzTqZQ2zAJCsXKbBhp119PKnRfw4uY1kt8(Sc2o8oHP4lZ7G3dnTc9LVlbeWNR3bzbPc1(o9ogaVqap8o3EkzZAHjmTGRY1kvndxl1amsdSD8uIp92tJCIaEHWcNsUwzI3NvqKfKku)uIpfe94tf6P3D(PeF6TNs2SwOgdT6Q0eQeSD4DctXxM3HufACQfK8LVlbeXNR3bzbPc1(o9ogaVqap8oKnRfAaTjJZ6LXmrtvW2Xtj(uYM1ctyAbxLRvQAgUwQbyKgOEfZ8oHP4lZ7mQi5lFxcCNpxVdYcsfQ9D6DmaEHaE4Dayk4S5PcL)P6gik(YE69)0ZW7EkXNwbOhlyXtOSwPMJpT7Nkk8oHP4lZ7aqM2x(Ueq0956DctXxM3zfecowXiW7GSGuHAFN(Y3Lac2NR3jmfFzEhZY0yI5DqwqQqTVtF57sGt1NR3jmfFzEh8EOPvO3bzbPc1(o9LVlbef(C9oHP4lZ7iiUPwWvjOnzEhKfKku770x(Ue4u856DctXxM3HNoqMMZ6LcIBQfC17GSGuHAFN(YxEhnAJMQ8567saFUENWu8L5DmzbOh9oilivO23PV8DjIpxVtyk(Y8ohTucvEhKfKku770x(UUZNR3bzbPc1(o9ogaVqap8oe80ka9ybZWqvzWdt9uHEQic8ux3NwHczfmfZegacrwqQq9tj(0ka9ybZWqvzWdt9uHE6DN6tj8PeFkbpLSzTWeMwWv5ALQMHRLAagPb2oEQR7tjBwlSVfanpyY1kJCIGTYGTJNs4tDDF6TNIZGmdctyAbxLRvQAgUwQbyKgykYXcEkXNE7P4miZGqZY0iBqTuXTODbgeMICSGNs8Pe80ka9ybZWqvzWdt9uHEQic8ux3NwHczfmfZegacrwqQq9tj(0ka9ybZWqvzWdt9uHE6DN6tj8PeFQgjBwl0SQDM2iNumzW2XtDDFQL3NvsaMcoBEQqpveb7DctXxM35yl(Y8LVlr3NR3bzbPc1(o9ogaVqap8oKnRfMW0cUkxRu1mCTudWinW2Xtj(uYM1clCk5ALjEFwbBhp119PKnRf23cGMhm5ALrorWwzW2Xtj(uns2SwOzv7mTroPyYGTJN66(uYM1cheRmoRxcIEe2oEQR7tj4P3EkodYmimHPfCvUwPQz4APgGrAGPihl4PeF6TNIZGmdcnltJSb1sf3I2fyqykYXcEkXNE7P4miZGqs1UA5ALvgkrgMUctrowWtj(uns2SwOzv7mTroPyYGTJNsO3jmfFzEhs1UAPTbU6lFxc2NR3bzbPc1(o9ogaVqap8oKnRfMW0cUkxRu1mCTudWinW2Xtj(uYM1clCk5ALjEFwbBhp119PKnRf23cGMhm5ALrorWwzW2Xtj(uns2SwOzv7mTroPyYGTJN66(uYM1cheRmoRxcIEe2oEQR7tj4P3EkodYmimHPfCvUwPQz4APgGrAGPihl4PeF6TNIZGmdcnltJSb1sf3I2fyqykYXcEkXNE7P4miZGqs1UA5ALvgkrgMUctrowWtj(uns2SwOzv7mTroPyYGTJNsO3jmfFzEhsemi4soR3x(UovFUEhKfKku7707ya8cb8W7q2Swyctl4QCTsvZW1snaJ0a1Ry2tj(uq0JpvONk4ZpL4tj4PMDv6vmdMwqfk5ua(LieGPGZMN29t7n6N66(ucEAfGESGzyOQm4HPEQqpvKZp119PvOqwbtXmHbGqKfKku)uIpTcqpwWmmuvg8WupvONENGFkHpLqVtyk(Y8obWemuwlaGSYx(Uef(C9oilivO23P3Xa4fc4H3rJKnRfAw1otBKtkMmOEfZ8oHP4lZ7O49z1iZrt3Nqw5lFxNIpxVdYcsfQ9D6DmaEHaE4DiBwlmHPfCvUwPQz4APgGrAGTJNs8PKnRfw4uY1kt8(Sc2oEQR7tjBwlSVfanpyY1kJCIGTYGTJNs8PAKSzTqZQ2zAJCsXKbBhp119PKnRfoiwzCwVee9iSD8ux3NsWtV9uCgKzqyctl4QCTsvZW1snaJ0atrowWtj(0BpfNbzgeAwMgzdQLkUfTlWGWuKJf8uIp92tXzqMbHKQD1Y1kRmuImmDfMICSGNs8PAKSzTqZQ2zAJCsXKbBhpLqVtyk(Y8owoajv7Q9LVlrLpxVdYcsfQ9D6DmaEHaE4DiBwlmHPfCvUwPQz4APgGrAGTJNs8PKnRfw4uY1kt8(Sc2oEQR7tjBwlSVfanpyY1kJCIGTYGTJNs8PAKSzTqZQ2zAJCsXKbBhp119PKnRfoiwzCwVee9iSD8ux3NsWtV9uCgKzqyctl4QCTsvZW1snaJ0atrowWtj(0BpfNbzgeAwMgzdQLkUfTlWGWuKJf8uIp92tXzqMbHKQD1Y1kRmuImmDfMICSGNs8PAKSzTqZQ2zAJCsXKbBhpLqVtyk(Y8obZGtbcL0ekLV8DjWzFUEhKfKku7707ya8cb8W7OrYM1cnRANPnYjftguVIzpL4tjBwlmHPfCvUwPQz4APgGrAG6vm7PeFQzxLEfZGPfuHsofGFjcbyk4SX7eMIVmVdz0lxRSaCZLJV8DjGa(C9oilivO23P3jmfFzENyYeuWWrcICUaPzbHY7ya8cb8W7C7PAKSzTqqKZfinliusns2Swy74PUUpLGNsWtRa0JfmddvLbpm1tf6PICgkWtDDFAfkKvWumtyaiezbPc1pL4tRa0JfmddvLbpm1tf6P3jyOapLWNs8Pe8uYM1ctyAbxLRvQAgUwQbyKgy74PeFkbp1SRsVIzWeMwWv5ALQMHRLAagPbcWuWzZtf6PcC(uFQR7tn7Q0RygmHPfCvUwPQz4APgGrAGamfC28uHEQacikEkXNA59zLeGPGZMNk0tf58tj(0BpTcfYkykMjmaeISGuH6Ns4tDDFkzZAH9TaO5btUwzKteSvgSD8uIpvJKnRfAw1otBKtkMmy74Pe(ucFQR7tXzqMbHMLPr2GAPIBr7cmimf5ybpL4tRa0JfmddvLbpm1tf6PIC(PUUpLGNwbOhlyggQkdEyQNk0tV7muGNs8PAKSzTqZY0ntXfek5SlLAKSzTW2Xtj(0BpfNbzgeMW0cUkxRu1mCTudWinWuKJf8uIp92tXzqMbHMLPr2GAPIBr7cmimf5ybpLWN66(ucE6TNQrYM1cnlt3mfxqOKZUuQrYM1cBhpL4tV9uCgKzqyctl4QCTsvZW1snaJ0atrowWtj(0BpfNbzgeAwMgzdQLkUfTlWGWuKJf8uIpvJKnRfAw1otBKtkMmy74Pe6Dyrc9oXKjOGHJee5CbsZccLV8DjGi(C9oilivO23P3jmfFzENiNtwaIrAxwjxR8yfJaVJbWleWdVtXtOSwPMJpvONkko)uIpLGNA2vPxXmOzv7mTroPyYGamfC28uHEQaI8ux3NsWtRqHSckoaKamUebqKfKku)uIp1SRsVIzqXbGeGXLiacWuWzZtf6PciYtj8Pe(ux3NE7PAKSzTqZQ2zAJCsXKbBhpL4tV9uYM1clCk5ALjEFwbBhpL4tV9uYM1ctyAbxLRvQAgUwQbyKgy74PeFAXtOSwPMJpT7NkGGp7Dyrc9oroNSaeJ0USsUw5Xkgb(Y3La35Z17GSGuHAFNEhdGxiGhENBpfNbzgeMW0cUkxRu1mCTudWinWuKJf8ux3NsWtjBwlmHPfCvUwPQz4APgGrAGTJN66(uZUk9kMbtyAbxLRvQAgUwQbyKgiatbNnpT7Nk6c(Pe6DctXxM3jeuubWx(Ueq0956DqwqQqTVtVJbWleWdVJzxLEfZGMvTZ0g5KIjdcWuWzZtf6PNYtDDFkbpTcfYkO4aqcW4searwqQq9tj(uZUk9kMbfhasagxIaiatbNnpvONEkpLqVtyk(Y8oTbL8ctJV8DjGG956DqwqQqTVtVJbWleWdVZCGkLScqpwduCghOeZz6N29tf4PeFkbp1SRsVIzqsvOXPwqccWuWzZt7(PcC(PUUp1SRsVIzqZQ2zAJCsXKbbyk4S5PD)0t5PUUpnYjc4fclCk5ALjEFwbrwqQq9tj07eMIVmVZigXdoRxofGFjo(Y3LaNQpxVdYcsfQ9D6DmaEHaE4Di4PKnRfw4uY1kt8(Sc2oEQR7tj4PAKSzTqZQ2zAJCsXKbBhpL4tV90iNiGxiSWPKRvM49zfezbPc1pLWNs4tj(ucEQL3NvsaMcoBEA3pvuD(PUUpLGNwbOhlyggQkdEyQNk0tf58tDDFAfkKvWumtyaiezbPc1pL4tRa0JfmddvLbpm1tf6P3j4Ns4tj07eMIVmVdPAxTCTYkdLidtx9LVlbef(C9oilivO23P3Xa4fc4H352t1izZAHMvTZ0g5KIjd2oEkXNE7PKnRfw4uY1kt8(Sc2o8oHP4lZ7C0aC7voRxsQIP8LVlbofFUEhKfKku7707ya8cb8W7C7PAKSzTqZQ2zAJCsXKbBhpL4tV9uYM1clCk5ALjEFwbBhENWu8L5Da8Jdfk5m5Ceg0x(Uequ5Z17GSGuHAFNEhdGxiGhENBpvJKnRfAw1otBKtkMmy74PeF6TNs2SwyHtjxRmX7Zky7W7eMIVmVJ4fO0cc5mjaNLfmd6lFxIC2NR3bzbPc1(o9ogaVqap8o3EQgjBwl0SQDM2iNumzW2Xtj(0BpLSzTWcNsUwzI3NvW2H3jmfFzEh7AAdQLroraVqjjgjF57seb856DqwqQqTVtVJbWleWdVZTNQrYM1cnRANPnYjftgSD8uIp92tjBwlSWPKRvM49zfSD4DctXxM3bGXbN1lTQiHJV8DjIi(C9oilivO23P3Xa4fc4H352t1izZAHMvTZ0g5KIjd2oEkXNE7PKnRfw4uY1kt8(Sc2oEkXNQ3cAwMbzfikulTQiHsYgGbbyk4S5P5F6zVtyk(Y8oMLzqwbIc1sRksOV8DjYD(C9oilivO23P3Xa4fc4H3HSzTqaAUuHZiTlWGW2H3jmfFzENkdLng52yAPDbg0x(Uer0956DqwqQqTVtVJbWleWdVZTNwHczfuCaibyCjcGilivO(PeFQzxLEfZGMvTZ0g5KIjdcWuWzZtf6Pc(PeFkbp1Y7ZkjatbNnpT7NkIaNFQR7tj4Pva6XcMHHQYGhM6Pc9uro)ux3NwHczfmfZegacrwqQq9tj(0ka9ybZWqvzWdt9uHE6Dc(Pe(ux3NA59zLeGPGZMNk0tVtGNsO3jmfFzEN(wa08GjxRmYjc2kZx(UerW(C9oilivO23P3Xa4fc4H3PcfYkO4aqcW4searwqQq9tj(uZUk9kMbfhasagxIaiatbNnpvONk4Ns8Pe8ulVpRKamfC280UFQicC(PUUpLGNwbOhlyggQkdEyQNk0tf58tDDFAfkKvWumtyaiezbPc1pL4tRa0JfmddvLbpm1tf6P3j4Ns4tDDFQL3NvsaMcoBEQqp9obEkHENWu8L5D6BbqZdMCTYiNiyRmF57sKt1NR3bzbPc1(o9ogaVqap8o3EAfkKvqXbGeGXLiaISGuH6Ns8PMDv6vmdAw1otBKtkMmiatbNnpvONkWtj(ucEQL3NvsaMcoBEA3pvabF(PUUpLGNwbOhlyggQkdEyQNk0tf58tDDFAfkKvWumtyaiezbPc1pL4tRa0JfmddvLbpm1tf6P3j4Ns4tj07eMIVmVtctl4QCTsvZW1snaJ04lFxIik856DqwqQqTVtVJbWleWdVtfkKvqXbGeGXLiaISGuH6Ns8PMDv6vmdkoaKamUebqaMcoBEQqpvGNs8Pe8ulVpRKamfC280UFQac(8tDDFkbpTcqpwWmmuvg8WupvONkY5N66(0kuiRGPyMWaqiYcsfQFkXNwbOhlyggQkdEyQNk0tVtWpLWNsO3jmfFzENeMwWv5ALQMHRLAagPXx(Ue5u856DctXxM3zoWaixRKmMIVmVdYcsfQ9D6lFxIiQ856DctXxM3XSStRneSGrsgmgc8oilivO23PV8DD3zFUENWu8L5DcMHJSsg2cbt2AU07GSGuHAFN(Y31Dc4Z17GSGuHAFNEhdGxiGhEhYM1cNMwJmPgJkd2oEQR7tbrp(0UZ)ur)8tDDFAfGESGfpHYALAo(uHEAVr7DctXxM3XSmnMy(Y31DI4Z17GSGuHAFNEhdGxiGhEhcEAfkKvWumtyaiezbPc1pL4tRa0JfmddvLbpm1tf6P3j4Ns4tDDFAfGESGzyOQm4HPEQqpvKZENWu8L5DanMmmfFzsfFkVJIpLKfj07G3dnTc9LVR7UZNR3bzbPc1(o9oHP4lZ7aAmzyk(YKk(uEhfFkjlsO3z4SEfkRa0JLV8L35aGMnrgLpxFxc4Z17eMIVmVdzuLcLt22kVdYcsfQ9D6lFxI4Z17GSGuHAFNEhwKqVtKZjlaXiTlRKRvESIrG3jmfFzENiNtwaIrAxwjxR8yfJaF576oFUEhKfKku7707ya8cb8W7uHczf0IabTa5ALKrvkeISGuH6N66(0BpTcfYkOfbcAbY1kjJQuiezbPc1pL4tlEcL1k1C8PD)ube8zVtyk(Y8ojmTGRY1kvndxl1amsJV8Dj6(C9oilivO23P3Xa4fc4H3PcfYkOfbcAbY1kjJQuiezbPc1p119PvOqwbtXmHbGqKfKku)uIpT4juwRuZXN29tfrGZp119PvOqwbbitdrwqQq9tj(ucEAXtOSwPMJpT7NkIaNFQR7tlEcL1k1C8Pc9ubeDb)uc9oHP4lZ703cGMhm5ALrorWwz(Yx(Y7iiem8L57sKZICwGZIC27ioamoRF8oN(0Xcku)ur)PHP4l7Pk(ud8f27CawlxHEhr7P3hinp90Eaa8f8clAp90IPwse8ure9lEQiNf58l8lSO9urnzbRhhrTVWI2tfLp9(0Au)ur9wkHk4lSO9ur5tVpTg1p90HBQfC9PNgAtwhN(0bY0Cw)tpD4MAbxHVWI2tfLp9(0Au)0oJQu4tDY2w90AF6banBImQNEFI6N2GVWI2tfLp909EOPv8LHGttZtf1bOHp8L9u(8unQWc1Wxyr7PIYNEFAnQF6PXbF6PVW0aFHfTNkkF69P1pfzf46tTl4PDQcno1cspvCh7tZfN6PR9PNM59z1tjWUGNQqbHkoR)INE6FAFdNHq4l8lSO90t37HMwH6NsI2fGp1SjYOEkj2Zzd8P3NXGh18u2YeLzbizBQNgMIVS5PltDf(clApnmfFzd8aGMnrgvERkMlFHfTNgMIVSbEaqZMiJ6K8Dy3v)clApnmfFzd8aGMnrg1j57iA9jKvrXx2lSO9uhwCmzB9uqW1pLSzTO(Ptf18us0Ua8PMnrg1tjXEoBEAW0p9aGIYJTkoR)P85P6LHWx4Wu8LnWdaA2ezuNKVdYOkfkNSTvVWHP4lBGha0SjYOojFhTbL8ctxWIeMpY5KfGyK2LvY1kpwXi4fomfFzd8aGMnrg1j57iHPfCvUwPQz4APgGrAUGBZxHczf0IabTa5ALKrvkeISGuHAx3BvOqwbTiqqlqUwjzuLcHilivOMyXtOSwPMJDlGGp)chMIVSbEaqZMiJ6K8D03cGMhm5ALrorWwzxWT5RqHScArGGwGCTsYOkfcrwqQqTRBfkKvWumtyaiezbPc1elEcL1k1CSBre4SRBfkKvqaY0qKfKkutKGINqzTsnh7webo76w8ekRvQ5Oqci6cMWx4xyr7PNU3dnTc1pffecU(0INWNwz4tdtTGNYNNgck4QGuHWx4Wu8Ln5nzbOhFHdtXx2Cs(ooAPeQEHdtXx2Cs(oo2IVSl428eubOhlyggQkdEykHerax3kuiRGPyMWaqiYcsfQjwbOhlyggQkdEykHU7ujKibKnRfMW0cUkxRu1mCTudWinW2HRlzZAH9TaO5btUwzKteSvgSDqOR7nCgKzqyctl4QCTsvZW1snaJ0atrowaXB4miZGqZY0iBqTuXTODbgeMICSaIeubOhlyggQkdEykHerax3kuiRGPyMWaqiYcsfQjwbOhlyggQkdEykHU7ujKOgjBwl0SQDM2iNumzW2HRRL3NvsaMcoBeseb)chMIVS5K8DqQ2vlTnW1l428KnRfMW0cUkxRu1mCTudWinW2brYM1clCk5ALjEFwbBhUUKnRf23cGMhm5ALrorWwzW2brns2SwOzv7mTroPyYGTdxxYM1cheRmoRxcIEe2oCDj4godYmimHPfCvUwPQz4APgGrAGPihlG4nCgKzqOzzAKnOwQ4w0UadctrowaXB4miZGqs1UA5ALvgkrgMUctrowarns2SwOzv7mTroPyYGTdcFHdtXx2Cs(oirWGGl5S(l428KnRfMW0cUkxRu1mCTudWinW2brYM1clCk5ALjEFwbBhUUKnRf23cGMhm5ALrorWwzW2brns2SwOzv7mTroPyYGTdxxYM1cheRmoRxcIEe2oCDj4godYmimHPfCvUwPQz4APgGrAGPihlG4nCgKzqOzzAKnOwQ4w0UadctrowaXB4miZGqs1UA5ALvgkrgMUctrowarns2SwOzv7mTroPyYGTdcFHdtXx2Cs(ocGjyOSwaaz1fCBEYM1ctyAbxLRvQAgUwQbyKgOEfZicIEuibFMibMDv6vmdMwqfk5ua(LieGPGZMU7nAxxcQa0JfmddvLbpmLqIC21TcfYkykMjmaeISGuHAIva6XcMHHQYGhMsO7emHe(chMIVS5K8DO49z1iZrt3NqwDb3MxJKnRfAw1otBKtkMmOEfZEHdtXx2Cs(oSCasQ2vFb3MNSzTWeMwWv5ALQMHRLAagPb2ois2SwyHtjxRmX7Zky7W1LSzTW(wa08GjxRmYjc2kd2oiQrYM1cnRANPnYjftgSD46s2Sw4GyLXz9sq0JW2HRlb3WzqMbHjmTGRY1kvndxl1amsdmf5ybeVHZGmdcnltJSb1sf3I2fyqykYXciEdNbzgesQ2vlxRSYqjYW0vykYXciQrYM1cnRANPnYjftgSDq4lCyk(YMtY3rWm4uGqjnHsDb3MNSzTWeMwWv5ALQMHRLAagPb2ois2SwyHtjxRmX7Zky7W1LSzTW(wa08GjxRmYjc2kd2oiQrYM1cnRANPnYjftgSD46s2Sw4GyLXz9sq0JW2HRlb3WzqMbHjmTGRY1kvndxl1amsdmf5ybeVHZGmdcnltJSb1sf3I2fyqykYXciEdNbzgesQ2vlxRSYqjYW0vykYXciQrYM1cnRANPnYjftgSDq4lCyk(YMtY3bz0lxRSaCZLZfCBEns2SwOzv7mTroPyYG6vmJizZAHjmTGRY1kvndxl1amsduVIzen7Q0RygmTGkuYPa8lriatbNnVWHP4lBojFhTbL8ctxWIeMpMmbfmCKGiNlqAwqOUGBZFtJKnRfcICUaPzbHsQrYM1cBhUUeqqfGESGzyOQm4HPesKZqbCDRqHScMIzcdaHilivOMyfGESGzyOQm4HPe6obdfGqIeq2Swyctl4QCTsvZW1snaJ0aBhejWSRsVIzWeMwWv5ALQMHRLAagPbcWuWzJqcC(uDDn7Q0RygmHPfCvUwPQz4APgGrAGamfC2iKacikiA59zLeGPGZgHe5mXBvOqwbtXmHbGqKfKkutORlzZAH9TaO5btUwzKteSvgSDquJKnRfAw1otBKtkMmy7GqcDDXzqMbHMLPr2GAPIBr7cmimf5ybeRa0JfmddvLbpmLqIC21LGka9ybZWqvzWdtj0DNHcquJKnRfAwMUzkUGqjNDPuJKnRf2oiEdNbzgeMW0cUkxRu1mCTudWinWuKJfq8godYmi0SmnYgulvClAxGbHPihlGqxxcUPrYM1cnlt3mfxqOKZUuQrYM1cBheVHZGmdctyAbxLRvQAgUwQbyKgykYXciEdNbzgeAwMgzdQLkUfTlWGWuKJfquJKnRfAw1otBKtkMmy7GWx4Wu8LnNKVJ2GsEHPlyrcZh5CYcqms7Yk5ALhRyeCb3MV4juwRuZrHefNjsGzxLEfZGMvTZ0g5KIjdcWuWzJqciIRlbvOqwbfhasagxIaiYcsfQjA2vPxXmO4aqcW4seabyk4SribeHqcDDVPrYM1cnRANPnYjftgSDq8gzZAHfoLCTYeVpRGTdI3iBwlmHPfCvUwPQz4APgGrAGTdIfpHYALAo2Tac(8lCyk(YMtY3riOOcWfCB(B4miZGWeMwWv5ALQMHRLAagPbMICSaxxciBwlmHPfCvUwPQz4APgGrAGTdxxZUk9kMbtyAbxLRvQAgUwQbyKgiatbNnDl6cMWx4Wu8LnNKVJ2GsEHP5cUnVzxLEfZGMvTZ0g5KIjdcWuWzJqNIRlbvOqwbfhasagxIaiYcsfQjA2vPxXmO4aqcW4seabyk4SrOtHWx4Wu8LnNKVJrmIhCwVCka)sCUGBZphOsjRa0J1afNXbkXCMUBbisGzxLEfZGKQqJtTGeeGPGZMUf4SRRzxLEfZGMvTZ0g5KIjdcWuWzt3NIRBKteWlew4uY1kt8(ScISGuHAcFHdtXx2Cs(oiv7QLRvwzOezy66fCBEciBwlSWPKRvM49zfSD46sGgjBwl0SQDM2iNumzW2bXBroraVqyHtjxRmX7ZkiYcsfQjKqIey59zLeGPGZMUfvNDDjOcqpwWmmuvg8WucjYzx3kuiRGPyMWaqiYcsfQjwbOhlyggQkdEykHUtWes4lCyk(YMtY3XrdWTx5SEjPkM6cUn)nns2SwOzv7mTroPyYGTdI3iBwlSWPKRvM49zfSD8chMIVS5K8Da4hhkuYzY5im4fCB(BAKSzTqZQ2zAJCsXKbBheVr2SwyHtjxRmX7Zky74fomfFzZj57q8cuAbHCMeGZYcMbVGBZFtJKnRfAw1otBKtkMmy7G4nYM1clCk5ALjEFwbBhVWHP4lBojFh210gulJCIaEHssmsxWT5VPrYM1cnRANPnYjftgSDq8gzZAHfoLCTYeVpRGTJx4Wu8LnNKVdaghCwV0QIeoxWT5VPrYM1cnRANPnYjftgSDq8gzZAHfoLCTYeVpRGTJx4Wu8LnNKVdZYmiRarHAPvfj8cUn)nns2SwOzv7mTroPyYGTdI3iBwlSWPKRvM49zfSDquVf0SmdYkquOwAvrcLKnadcWuWzt(ZVWHP4lBojFhvgkBmYTX0s7cm4fCBEYM1cbO5sfoJ0UadcBhVWHP4lBojFh9TaO5btUwzKteSv2fCB(BvOqwbfhasagxIaiYcsfQjA2vPxXmOzv7mTroPyYGamfC2iKGjsGL3NvsaMcoB6webo76sqfGESGzyOQm4HPesKZUUvOqwbtXmHbGqKfKkutScqpwWmmuvg8WucDNGj011Y7ZkjatbNncDNae(chMIVS5K8D03cGMhm5ALrorWwzxWT5RqHSckoaKamUebqKfKkut0SRsVIzqXbGeGXLiacWuWzJqcMibwEFwjbyk4SPBre4SRlbva6XcMHHQYGhMsiro76wHczfmfZegacrwqQqnXka9ybZWqvzWdtj0DcMqxxlVpRKamfC2i0Dcq4lCyk(YMtY3rctl4QCTsvZW1snaJ0Cb3M)wfkKvqXbGeGXLiaISGuHAIMDv6vmdAw1otBKtkMmiatbNncjarcS8(SscWuWzt3ci4ZUUeubOhlyggQkdEykHe5SRBfkKvWumtyaiezbPc1eRa0JfmddvLbpmLq3jycj8fomfFzZj57iHPfCvUwPQz4APgGrAUGBZxHczfuCaibyCjcGilivOMOzxLEfZGIdajaJlraeGPGZgHeGibwEFwjbyk4SPBbe8zxxcQa0JfmddvLbpmLqIC21TcfYkykMjmaeISGuHAIva6XcMHHQYGhMsO7emHe(chMIVS5K8DmhyaKRvsgtXx2lCyk(YMtY3HzzNwBiybJKmyme8chMIVS5K8DemdhzLmSfcMS1C5lCyk(YMtY3HzzAmXUGBZt2Sw400AKj1yuzW2HRli6XUZl6NDDRa0JfS4juwRuZrH6n6x4Wu8LnNKVdqJjdtXxMuXN6cwKW849qtRWl428euHczfmfZegacrwqQqnXka9ybZWqvzWdtj0DcMqx3ka9ybZWqvzWdtjKiNFHdtXx2Cs(oanMmmfFzsfFQlyrcZpCwVcLva6X6f(fomfFzdeVhAAfMhGm9fCBEaMcoBekVUbIIVS7)m8Ux4Wu8Lnq8EOPv4j57qJHwDvAcv6fomfFzdeVhAAfEs(oMlBk1CO4vHGl428GOhfsWIqKSzTWeMwWv5ALQMHRLAagPbQxXmxxq0JcjY5x4Wu8Lnq8EOPv4j57aeck6rWfxWT5n7Q0Ryg0SQDM2iNumzqaMcoBesexxcQqHSckoaKamUebqKfKkut0SRsVIzqXbGeGXLiacWuWzJqIq4lCyk(YgiEp00k8K8Dyw1otBKtkMSl4283WzqMbHjmTGRY1kvndxl1amsdmf5ybUUeq2Swyctl4QCTsvZW1snaJ0aBhUUMDv6vmdMW0cUkxRu1mCTudWinqaMcoB6wGZe(chMIVSbI3dnTcpjFhIdajaJlrWfCB(B4miZGWeMwWv5ALQMHRLAagPbMICSaxxciBwlmHPfCvUwPQz4APgGrAGTdxxZUk9kMbtyAbxLRvQAgUwQbyKgiatbNnDlWzcFHdtXx2aX7HMwHNKVJ0cQqjNcWVeVGBZR3cQr8qkEBm9abyk4SrO86gik(YU)ZW7isWCGkLScqpwduCghOeZz68c46EBoqLswbOhRbkoJduI5mD3cq8wfkKvqJcdbHqKfKkut4lCyk(YgiEp00k8K8Dyuyii8cUnpbZbQuYka9ynqXzCGsmNP7weI6TGAepKI3gtpqaMcoBekVUbIIVS7)m8ocDDjyoqLswbOhRbkoJduI5mD33r4lCyk(YgiEp00k8K8DqQcno1csxWT5Vr2Swyctl4QCTsvZW1snaJ0aBhejBwlSWPKRvM49zfSDqee9Oq3DM4nYM1c1yOvxLMqLGTJx4Wu8Lnq8EOPv4j57aVhAAfEb3MNSzTWeMwWv5ALQMHRLAagPb2oCDjBwluJHwDvAcvc2oCD1izZAHMvTZ0g5KIjd2oCDjBwlSWPKRvM49zfSD8chMIVSbI3dnTcpjFhKQqJtTG0fCB(BKnRfMW0cUkxRu1mCTudWinW2bXBroraVqyHtjxRmX7ZkiYcsfQjcIEuO7ot8gzZAHAm0QRstOsW2XlCyk(YgiEp00k8K8DmQiDb3MNSzTqdOnzCwVmMjAQc2ois2Swyctl4QCTsvZW1snaJ0a1Ry2lCyk(YgiEp00k8K8DaqM(cUnpatbNncLx3arXx29FgEhXka9yblEcL1k1CSBrXlCyk(YgiEp00k8K8DSccbhRye8chMIVSbI3dnTcpjFhMLPXe7fomfFzdeVhAAfEs(oW7HMwHVWHP4lBG49qtRWtY3HG4MAbxLG2K9chMIVSbI3dnTcpjFh80bY0CwVuqCtTGRVWVWHP4lBGdN1RqzfGESYdqM(cUnpatbNncLx3arXx29FgE3lCyk(Yg4Wz9kuwbOhRtY3HgdT6Q0eQ0lCyk(Yg4Wz9kuwbOhRtY3XCztPMdfVkeCb3Mhe9OqN6zIKnRfQXqRUknHkb1RygrYM1ctyAbxLRvQAgUwQbyKgOEfZCDbrpkKiNFHdtXx2ahoRxHYka9yDs(oaHGIEeCb3MNaZUk9kMbnRANPnYjftgeGPGZgHeX1LGkuiRGIdajaJlraezbPc1en7Q0RyguCaibyCjcGamfC2iKies4lCyk(Yg4Wz9kuwbOhRtY3rAbvOKtb4xIxWT51Bb1iEifVnMEGamfC2iuEDdefFz3)z4DejyoqLswbOhRbkoJduI5mDEbCDVvHczf0OWqqiezbPc1e(chMIVSboCwVcLva6X6K8Dyuyii8cUn)CGkLScqpwduCghOeZz6UfHOElOgXdP4TX0deGPGZgHYRBGO4l7(pdV7fomfFzdC4SEfkRa0J1j57WSQDM2iNumzxWT5VHZGmdcnltJSb1sf3I2fyqiYcsfQjERcfYkykMjmaeISGuHAIeubOhlyXtOSw5HPKICUBbo76A59zLeGPGZMUf8zcDDXzqMbHMLPr2GAPIBr7cmiezbPc1eVvHczfmfZegacrwqQqnrcQa0JfS4juwR8Wusro3TaNDDT8(SscWuWzt3NYzcDDRqHScMIzcdaHilivOMibva6Xcw8ekRvEyk5DcUBbo76A59zLeGPGZMUf8zcFHdtXx2ahoRxHYka9yDs(oehasagxIGl4283WzqMbHMLPr2GAPIBr7cmiezbPc1eVvHczfmfZegacrwqQqnrcQa0JfS4juwR8Wusro3TaNDDT8(SscWuWzt3c(mHUU4miZGqZY0iBqTuXTODbgeISGuHAI3QqHScMIzcdaHilivOMibva6Xcw8ekRvEykPiN7wGZUUwEFwjbyk4SP7t5mHUUvOqwbtXmHbGqKfKkutKGka9yblEcL1kpmL8ob3TaNDDT8(SscWuWzt3c(mHVWHP4lBGdN1RqzfGESojFh49qtRWl428KnRfonTgzsngvgeGHPEHdtXx2ahoRxHYka9yDs(oivHgNAbPl428MDv6vmdMwqfk5ua(LieGPGZgIeOrYM1cnRANPnYjftguVIzejBwlSWPKRvM49zfSD46QrYM1cnRANPnYjftgSDq8wKteWlew4uY1kt8(ScISGuHAcjsWTkuiRGAm0QRstOsqKfKku76s2SwOgdT6Q0eQeuVIzesKSzTWeMwWv5ALQMHRLAagPbQxXmIGOhfs0p)chMIVSboCwVcLva6X6K8DKwqfk5ua(L4fCB(5avkzfGESgO4moqjMZ05fW19wfkKvqJcdbHqKfKku)chMIVSboCwVcLva6X6K8Dyuyii8cUn)CGkLScqpwduCghOeZz6Uf5fomfFzdC4SEfkRa0J1j57qCghOeZz6l428eqabKnRfMW0cUkxRu1mCTudWinW2bHUUeOrYM1cnRANPnYjftgSDqORlbKnRfQXqRUknHkbBhesiXkuiRGweiOfixRKmQsHqKfKkutORlbeq2Swyctl4QCTsvZW1snaJ0aBhUUGOh7(uevesuJKnRfAw1otBKtkMmy7GizZAHfoLCTYeVpRG6vmJ4TkuiRGweiOfixRKmQsHqKfKkut4lCyk(Yg4Wz9kuwbOhRtY3XOI0fCB(BvOqwbTiqqlqUwjzuLcHilivOMibKnRfMW0cUkxRu1mCTudWinW2HRRgjBwl0SQDM2iNumzW2bHVWHP4lBGdN1RqzfGESojFhRGqWXkgbVWHP4lBGdN1RqzfGESojFhIZ4aLyotFb3MVcfYkOfbcAbY1kjJQuiezbPc1ejGSzTWcNsUwzI3NvW2HRRgjBwl0SQDM2iNumzq9kMrKSzTWcNsUwzI3Nvq9kMree9y3N6zcFHdtXx2ahoRxHYka9yDs(ogvKUGBZFRcfYkOfbcAbY1kjJQuiezbPc1VWHP4lBGdN1RqzfGESojFhcIBQfCvcAt2lCyk(Yg4Wz9kuwbOhRtY3bpDGmnN1lfe3ul4Q3zoqJVlrHa(YxEpa]] )


end
