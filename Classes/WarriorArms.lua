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


    spec:RegisterPack( "Arms", 20201028, [[dGe3CbqivkpIkK2ec9jrfsnke4uiOvrfIELkIzPsQBrej7c0VKkmmvuhJiSmQGNPsLPPIKUgruBtfP8nvKyCIk4CIkuRJisP5rKCprv7tQuhKkewOurpuuHKlQIuvNKis1kjsntvKQyNsL8tvKk1qfviwQksv6Pe1ufv6QQivYwjIu8vvKkSxr(lHbJ0HfwmIEmftMuxgAZu6ZsvJwuonQwnvOETkjZMKBtv7gLFR0WvHJRIurlh45kMUKRlLTRsvFNkA8erCEvI1lQO5tL2VQojrk3KSokm1LdND4SeNDihGsKds(uK8PKKRlhys(imxf9ysMfEmj7ia(jjFexuBOt5MKNTbmysoRQJrsBhD0ZRSgj0S(ogUVPIIVmdiSvhd3B6ijt24QssNLitY6OWuxoC2HZsC2HCakXPD3P4WPKKJwLTGKSm33urXxwokqyRKCgxRrwImjRXXKKD0N6ia(5PNocaGVGxAh9PNUn1sIGN6qoC9tD4SdNFPFPD0NMJkly94iP9L2rFQK6PocTg1pnhP59Oc(s7Opvs9uhHwJ6NkPHBQfC5PNEBtwhs6(dKP5S(NkPHBQfCb(s7Opvs9uhHwJ6N2zuLcFQC22QNw7tpaOz9Kr9uhroYPh4lTJ(uj1tp9Le00k(Yqqo65P5ia0Wh(YEkFEQgvyHA4lTJ(uj1tDeAnQF6PRbFQKEH(b(s7Opvs90CDIXvpfzf4YtTl4PDQcno1c8WKSIp1KYnjpCwVcfva6XkLBQljs5MKrwqQqDQZKSbWleWJKma9bNnpvQ8pv3arXx2tDKp9m8UKCyk(YsYaKPtvQlhs5MKdtXxwswJHwDrycLpjJSGuH6uNPk11DPCtYilivOo1zs2a4fc4rsge94tL6PN25Ns8PKnRfQXqRUimHYd1Rt2tj(uYM1c9OFbxeRvOAgUwOby4hOEDYEQR7tbrp(uPEQdNtYHP4lljpx1uQ5qXRcbPk11PMYnjJSGuH6uNjzdGxiGhjzcEQzxLEDYGMvTZ0gX4JjdcqFWzZtL6Po8ux3NsWtRqHSc6maKamUcbqKfKku)uIp1SRsVozqNbGeGXviacqFWzZtL6Po8ucFkHj5Wu8LLKbX9rpcsvQljNYnjJSGuH6uNjzdGxiGhjz9wqnIhcNBJPhia9bNnpvQ8pv3arXx2tDKp9m8UNs8Pe805avkrfGESgOZmoq5KZ0pn)tL4PUUp92tRqHScAuyCpcrwqQq9tjmjhMIVSKSFbvOetb4xHPk11PLYnjJSGuH6uNjzdGxiGhj55avkrfGESgOZmoq5KZ0pT7N6Wtj(u9wqnIhcNBJPhia9bNnpvQ8pv3arXx2tDKp9m8UKCyk(YsYgfg3JPk11PKYnjJSGuH6uNjzdGxiGhj5BpfNbzgeAwMgzdQfkUfTlWGqKfKku)uIp92tRqHSc6JzcdaHilivO(PeFkbpTcqpwWI7rrTIdtjC48t7(PsC(PUUp1Y7Zkba9bNnpT7Nk5ZpLWN66(uCgKzqOzzAKnOwO4w0UadcrwqQq9tj(0BpTcfYkOpMjmaeISGuH6Ns8Pe80ka9yblUhf1komLWHZpT7NkX5N66(ulVpRea0hC280UFAoC(Pe(ux3NwHczf0hZegacrwqQq9tj(ucEAfGESGf3JIAfhMsCNKFA3pvIZp119PwEFwjaOp4S5PD)ujF(PeMKdtXxws2SQDM2igFmzPk1voKYnjJSGuH6uNjzdGxiGhj5BpfNbzgeAwMgzdQfkUfTlWGqKfKku)uIp92tRqHSc6JzcdaHilivO(PeFkbpTcqpwWI7rrTIdtjC48t7(PsC(PUUp1Y7Zkba9bNnpT7Nk5ZpLWN66(uCgKzqOzzAKnOwO4w0UadcrwqQq9tj(0BpTcfYkOpMjmaeISGuH6Ns8Pe80ka9yblUhf1komLWHZpT7NkX5N66(ulVpRea0hC280UFAoC(Pe(ux3NwHczf0hZegacrwqQq9tj(ucEAfGESGf3JIAfhMsCNKFA3pvIZp119PwEFwjaOp4S5PD)ujF(PeMKdtXxws2zaibyCfcsvQRCCk3KmYcsfQtDMKnaEHaEKKjBwlCAAnYeAmQmiadtLKdtXxwsgLe00kmvPUK4Ck3KmYcsfQtDMKnaEHaEKKdtXVhfid9CCEA3pvINs8Pe80BpTcfYkOgdT6IWekpezbPc1p119PKnRfQXqRUimHYd1Rt2tj8PeFkbpnYjc4fclCkXAfEEFwbrwqQq9tj(uns2SwOzv7mTrm(yYG61j7PeFkzZAHfoLyTcpVpRGTJN66(0BpnYjc4fclCkXAfEEFwbrwqQq9tj(uns2SwOzv7mTrm(yYGTJNsysomfFzjzsvOXPwGpvPUKqIuUjzKfKkuN6mjBa8cb8ijB2vPxNmOFbvOetb4xHqa6doBEkXNsWt1izZAHMvTZ0gX4JjdQxNSNs8PKnRfw4uI1k88(Sc2oEQR7t1izZAHMvTZ0gX4Jjd2oEkXNE7ProraVqyHtjwRWZ7ZkiYcsfQFkHpL4tj4P3EAfkKvqngA1fHjuEiYcsfQFQR7tjBwluJHwDrycLhQxNSNs4tj(uYM1c9OFbxeRvOAgUwOby4hOEDYEkXNcIE8Ps90t9CsomfFzjzsvOXPwGpvPUKWHuUjzKfKkuN6mjBa8cb8ijphOsjQa0J1aDMXbkNCM(P5FQep119P3EAfkKvqJcJ7riYcsfQtYHP4llj7xqfkXua(vyQsDjXDPCtYilivOo1zs2a4fc4rsEoqLsubOhRb6mJduo5m9t7(PoKKdtXxws2OW4EmvPUK4ut5MKrwqQqDQZKSbWleWJKmbpLGNsWtjBwl0J(fCrSwHQz4AHgGHFGTJNs4tDDFkbpvJKnRfAw1otBeJpMmy74Pe(ux3NsWtjBwluJHwDrycLh2oEkHpLWNs8PvOqwbTi4(fiwRGmQsHqKfKku)ucFQR7tj4Pe8uYM1c9OFbxeRvOAgUwOby4hy74PUUpfe94t7(P5qo(Pe(uIpvJKnRfAw1otBeJpMmy74PeFkzZAHfoLyTcpVpRG61j7PeF6TNwHczf0IG7xGyTcYOkfcrwqQq9tjmjhMIVSKSZmoq5KZ0Pk1LesoLBsgzbPc1PotYgaVqapsY3EAfkKvqlcUFbI1kiJQuiezbPc1pL4tj4PKnRf6r)cUiwRq1mCTqdWWpW2XtDDFQgjBwl0SQDM2igFmzW2XtjmjhMIVSK8OcFQsDjXPLYnjhMIVSK8EpcowNiijJSGuH6uNPk1LeNsk3KmYcsfQtDMKnaEHaEKKRqHScArW9lqSwbzuLcHilivO(PeFkbpLSzTWcNsSwHN3NvW2XtDDFQgjBwl0SQDM2igFmzq96K9uIpLSzTWcNsSwHN3Nvq96K9uIpfe94t7(PN25NsysomfFzjzNzCGYjNPtvQljYHuUjzKfKkuN6mjBa8cb8ijF7PvOqwbTi4(fiwRGmQsHqKfKkuNKdtXxwsEuHpvPUKihNYnjhMIVSK89CtTGlcqBYsYilivOo1zQsD5W5uUj5Wu8LLK5(dKP5SEX9CtTGljzKfKkuN6mvPkjJscAAfMYn1LePCtYilivOo1zs2a4fc4rsgG(GZMNkv(NQBGO4l7PoYNEgExsomfFzjzaY0Pk1LdPCtYHP4lljRXqRUimHYNKrwqQqDQZuL66UuUjzKfKkuN6mjBa8cb8ijdIE8Ps9uj7Wtj(uYM1c9OFbxeRvOAgUwOby4hOEDYEQR7tbrp(uPEQdNtYHP4lljpx1uQ5qXRcbPk11PMYnjJSGuH6uNjzdGxiGhjzZUk96KbnRANPnIXhtgeG(GZMNk1tD4PUUpLGNwHczf0zaibyCfcGilivO(PeFQzxLEDYGodajaJRqaeG(GZMNk1tD4PeMKdtXxwsge3h9iivPUKCk3KmYcsfQtDMKnaEHaEKKV9uCgKzqOh9l4IyTcvZW1cnad)a9HJxWtDDFkbpLSzTqp6xWfXAfQMHRfAag(b2oEQR7tn7Q0Rtg0J(fCrSwHQz4AHgGHFGa0hC280UFQeNFkHj5Wu8LLKnRANPnIXhtwQsDDAPCtYilivOo1zs2a4fc4rs(2tXzqMbHE0VGlI1kundxl0am8d0hoEbp119Pe8uYM1c9OFbxeRvOAgUwOby4hy74PUUp1SRsVozqp6xWfXAfQMHRfAag(bcqFWzZt7(PsC(PeMKdtXxws2zaibyCfcsvQRtjLBsgzbPc1PotYgaVqapsY6TGAepeo3gtpqa6doBEQu5FQUbIIVSN6iF6z4DpL4tj4PZbQuIka9ynqNzCGYjNPFA(NkXtDDF6TNohOsjQa0J1aDMXbkNCM(PD)ujEkXNE7PvOqwbnkmUhHilivO(PeMKdtXxws2VGkuIPa8RWuL6khs5MKrwqQqDQZKSbWleWJKmbpDoqLsubOhRb6mJduo5m9t7(Po8uIpvVfuJ4HW52y6bcqFWzZtLk)t1nqu8L9uh5tpdV7Pe(ux3NsWtNduPeva6XAGoZ4aLtot)0UF6DpLWKCyk(YsYgfg3JPk1vooLBsgzbPc1PotYgaVqapsY3EkzZAHE0VGlI1kundxl0am8dSD8uIpLSzTWcNsSwHN3NvW2Xtj(uq0JpvQNE35Ns8P3EkzZAHAm0QlctO8W2rsomfFzjzsvOXPwGpvPUK4Ck3KmYcsfQtDMKnaEHaEKKjBwl0J(fCrSwHQz4AHgGHFGTJN66(uYM1c1yOvxeMq5HTJN66(uns2SwOzv7mTrm(yYGTJN66(uYM1clCkXAfEEFwbBhj5Wu8LLKrjbnTctvQljKiLBsgzbPc1PotYgaVqapsY3EkzZAHE0VGlI1kundxl0am8dSD8uIp92tJCIaEHWcNsSwHN3NvqKfKku)uIpfe94tL6P3D(PeF6TNs2SwOgdT6IWekpSDKKdtXxwsMufACQf4tvQljCiLBsgzbPc1PotYgaVqapsYKnRfAaTjJZ6fXmrtvW2Xtj(uYM1c9OFbxeRvOAgUwOby4hOEDYsYHP4lljpQWNQuxsCxk3KmYcsfQtDMKnaEHaEKKbOp4S5PsL)P6gik(YEQJ8PNH39uIpTcqpwWI7rrTcnhFA3p9usYHP4lljdqMovPUK4ut5MKdtXxwsEVhbhRteKKrwqQqDQZuL6scjNYnjhMIVSKSzzA0ZsYilivOo1zQsDjXPLYnjhMIVSKmkjOPvysgzbPc1PotvQljoLuUj5Wu8LLKVNBQfCraAtwsgzbPc1PotvQljYHuUj5Wu8LLK5(dKP5SEX9CtTGljzKfKkuN6mvPkjRrB0uvk3uxsKYnjhMIVSKSjla9ysgzbPc1PotvQlhs5MKdtXxws(O59OkjJSGuH6uNPk11DPCtYilivOo1zs2a4fc4rsMGNwbOhlyggQkdEyQNk1tDqIN66(0kuiRG(yMWaqiYcsfQFkXNwbOhlyggQkdEyQNk1tV70EkHpL4tj4PKnRf6r)cUiwRq1mCTqdWWpW2XtDDFkzZAH9TaO5btSwrKteSvgSD8ucFQR7tV9uCgKzqOh9l4IyTcvZW1cnad)a9HJxWtj(0BpfNbzgeAwMgzdQfkUfTlWGqF44f8uIpLGNwbOhlyggQkdEyQNk1tDqIN66(0kuiRG(yMWaqiYcsfQFkXNwbOhlyggQkdEyQNk1tV70EkHpL4t1izZAHMvTZ0gX4Jjd2oEQR7tT8(SsaqFWzZtL6Poi5KCyk(YsYhBXxwQsDDQPCtYilivOo1zs2a4fc4rsMSzTqp6xWfXAfQMHRfAag(b2oEkXNs2SwyHtjwRWZ7Zky74PUUpLSzTW(wa08GjwRiYjc2kd2oEkXNQrYM1cnRANPnIXhtgSD8ux3Ns2Sw4GyLXz9cq0JW2XtDDFkbp92tXzqMbHE0VGlI1kundxl0am8d0hoEbpL4tV9uCgKzqOzzAKnOwO4w0Uadc9HJxWtj(0BpfNbzgesQ2vlwROYqbYq)fOpC8cEkXNQrYM1cnRANPnIXhtgSD8uctYHP4lljtQ2vlSnWLuL6sYPCtYilivOo1zs2a4fc4rsMSzTqp6xWfXAfQMHRfAag(b2oEkXNs2SwyHtjwRWZ7Zky74PUUpLSzTW(wa08GjwRiYjc2kd2oEkXNQrYM1cnRANPnIXhtgSD8ux3Ns2Sw4GyLXz9cq0JW2XtDDFkbp92tXzqMbHE0VGlI1kundxl0am8d0hoEbpL4tV9uCgKzqOzzAKnOwO4w0Uadc9HJxWtj(0BpfNbzgesQ2vlwROYqbYq)fOpC8cEkXNQrYM1cnRANPnIXhtgSD8uctYHP4lljtIGbbxXz9Pk11PLYnjJSGuH6uNjzdGxiGhjzYM1c9OFbxeRvOAgUwOby4hOEDYEkXNcIE8Ps9ujF(PeFkbp1SRsVozq)cQqjMcWVcHa0hC280UFAVr)ux3NsWtRa0JfmddvLbpm1tL6PoC(PUUpTcfYkOpMjmaeISGuH6Ns8Pva6XcMHHQYGhM6Ps907K8tj8PeMKdtXxwsoaMGHIAbaKvPk11PKYnjJSGuH6uNjzdGxiGhjzns2SwOzv7mTrm(yYG61jljhMIVSKSI3NvJWXnDVhzvQsDLdPCtYilivOo1zs2a4fc4rsMSzTqp6xWfXAfQMHRfAag(b2oEkXNs2SwyHtjwRWZ7Zky74PUUpLSzTW(wa08GjwRiYjc2kd2oEkXNQrYM1cnRANPnIXhtgSD8ux3Ns2Sw4GyLXz9cq0JW2XtDDFkbp92tXzqMbHE0VGlI1kundxl0am8d0hoEbpL4tV9uCgKzqOzzAKnOwO4w0Uadc9HJxWtj(0BpfNbzgesQ2vlwROYqbYq)fOpC8cEkXNQrYM1cnRANPnIXhtgSD8uctYHP4lljB5aKuTRovPUYXPCtYilivOo1zs2a4fc4rsMSzTqp6xWfXAfQMHRfAag(b2oEkXNs2SwyHtjwRWZ7Zky74PUUpLSzTW(wa08GjwRiYjc2kd2oEkXNQrYM1cnRANPnIXhtgSD8ux3Ns2Sw4GyLXz9cq0JW2XtDDFkbp92tXzqMbHE0VGlI1kundxl0am8d0hoEbpL4tV9uCgKzqOzzAKnOwO4w0Uadc9HJxWtj(0BpfNbzgesQ2vlwROYqbYq)fOpC8cEkXNQrYM1cnRANPnIXhtgSD8uctYHP4lljhmdofiuctOuPk1LeNt5MKrwqQqDQZKSbWleWJKSgjBwl0SQDM2igFmzq96K9uIpLSzTqp6xWfXAfQMHRfAag(bQxNSNs8PMDv61jd6xqfkXua(vieG(GZMKCyk(YsYKrVyTIcWnxnPk1LesKYnjJSGuH6uNjzdGxiGhj5BpvJKnRfcICUaHzbHsOrYM1cBhp119Pe8ucEAfGESGzyOQm4HPEQup1HZqjEQR7tRqHSc6JzcdaHilivO(PeFAfGESGzyOQm4HPEQup9ojdL4Pe(uIpLGNs2SwOh9l4IyTcvZW1cnad)aBhpL4tj4PMDv61jd6r)cUiwRq1mCTqdWWpqa6doBEQupvIZN2tDDFQzxLEDYGE0VGlI1kundxl0am8deG(GZMNk1tLqIt5PeFQL3Nvca6doBEQup1HZpL4tV90kuiRG(yMWaqiYcsfQFkHp119PKnRf23cGMhmXAfrorWwzW2Xtj(uns2SwOzv7mTrm(yYGTJNs4tj8PUUpfNbzgeAwMgzdQfkUfTlWGqF44f8uIpTcqpwWmmuvg8WupvQN6W5N66(ucEAfGESGzyOQm4HPEQup9UZqjEkXNQrYM1cnlt3mf)EuWzxj0izZAHTJNs8P3EkodYmi0J(fCrSwHQz4AHgGHFG(WXl4PeF6TNIZGmdcnltJSb1cf3I2fyqOpC8cEkHp119Pe80BpvJKnRfAwMUzk(9OGZUsOrYM1cBhpL4tV9uCgKzqOh9l4IyTcvZW1cnad)a9HJxWtj(0BpfNbzgeAwMgzdQfkUfTlWGqF44f8uIpvJKnRfAw1otBeJpMmy74PeMKzHhtYXKDFWWraICUaHzbHkjhMIVSKCmz3hmCeGiNlqywqOsvQljCiLBsgzbPc1PotYgaVqapsYf3JIAfAo(uPE6PC(PeFkbp1SRsVozqZQ2zAJy8XKbbOp4S5Ps9ujC4PUUpLGNwHczf0zaibyCfcGilivO(PeFQzxLEDYGodajaJRqaeG(GZMNk1tLWHNs4tj8PUUp92t1izZAHMvTZ0gX4Jjd2oEkXNE7PKnRfw4uI1k88(Sc2oEkXNE7PKnRf6r)cUiwRq1mCTqdWWpW2Xtj(0I7rrTcnhFA3pvcjFojZcpMKJCozbigHDzLyTIJ1jcsYHP4lljh5CYcqmc7YkXAfhRteKQuxsCxk3KmYcsfQtDMKnaEHaEKKV9uCgKzqOh9l4IyTcvZW1cnad)a9HJxWtDDFkbpLSzTqp6xWfXAfQMHRfAag(b2oEQR7tn7Q0Rtg0J(fCrSwHQz4AHgGHFGa0hC280UF6Pk5NsysomfFzj54(OcqQsDjXPMYnjJSGuH6uNjzdGxiGhjzZUk96KbnRANPnIXhtgeG(GZMNk1tZHN66(ucEAfkKvqNbGeGXviaISGuH6Ns8PMDv61jd6maKamUcbqa6doBEQupnhEkHj5Wu8LLKBdk4f6NuL6scjNYnjJSGuH6uNjzdGxiGhj55avkrfGESgOZmoq5KZ0pT7NkXtj(ucEQzxLEDYGKQqJtTapeG(GZMN29tL48tDDFQzxLEDYGMvTZ0gX4JjdcqFWzZt7(P5WtDDFAKteWlew4uI1k88(ScISGuH6NsysomfFzj5XjIhCwVyka)kCsvQljoTuUjzKfKkuN6mjBa8cb8ijtWtjBwlSWPeRv459zfSD8ux3NsWt1izZAHMvTZ0gX4Jjd2oEkXNE7ProraVqyHtjwRWZ7ZkiYcsfQFkHpLWNs8Pe8ulVpRea0hC280UFAo(8tDDFkbpTcqpwWmmuvg8WupvQN6W5N66(0kuiRG(yMWaqiYcsfQFkXNwbOhlyggQkdEyQNk1tVtYpLWNsysomfFzjzs1UAXAfvgkqg6VKQuxsCkPCtYilivOo1zs2a4fc4rs(2t1izZAHMvTZ0gX4Jjd2oEkXNE7PKnRfw4uI1k88(Sc2osYHP4lljF0aC7foRxqQIPsvQljYHuUjzKfKkuN6mjBa8cb8ijF7PAKSzTqZQ2zAJy8XKbBhpL4tV9uYM1clCkXAfEEFwbBhj5Wu8LLKb8Jdfk4mXCegmvPUKihNYnjJSGuH6uNjzdGxiGhj5BpvJKnRfAw1otBeJpMmy74PeF6TNs2SwyHtjwRWZ7Zky7ijhMIVSKSZfO03JCMaGZYcMbtvQlhoNYnjJSGuH6uNjzdGxiGhj5BpvJKnRfAw1otBeJpMmy74PeF6TNs2SwyHtjwRWZ7Zky7ijhMIVSKSDnTb1IiNiGxOGedFQsD5GePCtYilivOo1zs2a4fc4rs(2t1izZAHMvTZ0gX4Jjd2oEkXNE7PKnRfw4uI1k88(Sc2osYHP4lljdW4GZ6fwv4XjvPUCWHuUjzKfKkuN6mjBa8cb8ijF7PAKSzTqZQ2zAJy8XKbBhpL4tV9uYM1clCkXAfEEFwbBhpL4t1BbnlZGScefQfwv4rbzdWGa0hC2808p9CsomfFzjzZYmiRarHAHvfEmvPUC4UuUjzKfKkuN6mjBa8cb8ijt2SwianxPWze2fyqy7ijhMIVSKCLHIgJCBmTWUadMQuxoCQPCtYilivOo1zs2a4fc4rs(2tRqHSc6maKamUcbqKfKku)uIp1SRsVozqZQ2zAJy8XKbbOp4S5Ps9uj)uIpLGNA59zLaG(GZMN29tDqIZp119Pe80ka9ybZWqvzWdt9uPEQdNFQR7tRqHSc6JzcdaHilivO(PeFAfGESGzyOQm4HPEQup9oj)ucFQR7tT8(SsaqFWzZtL6P3jXtjmjhMIVSKCFlaAEWeRve5ebBLLQuxoi5uUjzKfKkuN6mjBa8cb8ijxHczf0zaibyCfcGilivO(PeFQzxLEDYGodajaJRqaeG(GZMNk1tL8tj(ucEQL3Nvca6doBEA3p1bjo)ux3NsWtRa0JfmddvLbpm1tL6PoC(PUUpTcfYkOpMjmaeISGuH6Ns8Pva6XcMHHQYGhM6Ps907K8tj8PUUp1Y7Zkba9bNnpvQNENepLWKCyk(YsY9TaO5btSwrKteSvwQsD5WPLYnjJSGuH6uNjzdGxiGhj5BpTcfYkOZaqcW4kearwqQq9tj(uZUk96KbnRANPnIXhtgeG(GZMNk1tL4PeFkbp1Y7Zkba9bNnpT7NkHKp)ux3NsWtRa0JfmddvLbpm1tL6PoC(PUUpTcfYkOpMjmaeISGuH6Ns8Pva6XcMHHQYGhM6Ps907K8tj8PeMKdtXxws2J(fCrSwHQz4AHgGHFsvQlhoLuUjzKfKkuN6mjBa8cb8ijxHczf0zaibyCfcGilivO(PeFQzxLEDYGodajaJRqaeG(GZMNk1tL4PeFkbp1Y7Zkba9bNnpT7NkHKp)ux3NsWtRa0JfmddvLbpm1tL6PoC(PUUpTcfYkOpMjmaeISGuH6Ns8Pva6XcMHHQYGhM6Ps907K8tj8PeMKdtXxws2J(fCrSwHQz4AHgGHFsvQlhYHuUj5Wu8LLKNdmaI1kiJP4lljJSGuH6uNPk1Ld54uUj5Wu8LLKnl70zdblyeKbJHGKmYcsfQtDMQux3DoLBsomfFzj5Gz4iReHTqWKTMRsYilivOo1zQsDDNePCtYilivOo1zs2a4fc4rsMSzTWPP1itOXOYGTJN66(uq0JpT78p9up)ux3NwbOhlyX9OOwHMJpvQN2B0j5Wu8LLKnltJEwQsDDNdPCtYilivOo1zs2a4fc4rsMGNwHczf0hZegacrwqQq9tj(0ka9ybZWqvzWdt9uPE6Ds(Pe(ux3NwbOhlyggQkdEyQNk1tD4CsomfFzjzqJjctXxMqXNkjR4tjyHhtYOKGMwHPk11D3LYnjJSGuH6uNj5Wu8LLKbnMimfFzcfFQKSIpLGfEmjpCwVcfva6XkvPkjFaqZ6jJkLBQljs5MKdtXxwsMmQsHIjBBvsgzbPc1PotvQlhs5MKrwqQqDQZKml8ysoY5KfGye2LvI1kowNiijhMIVSKCKZjlaXiSlReRvCSorqQsDDxk3KmYcsfQtDMKnaEHaEKKRqHScArW9lqSwbzuLcHilivO(PUUp92tRqHScArW9lqSwbzuLcHilivO(PeFAX9OOwHMJpT7NkHKpNKdtXxws2J(fCrSwHQz4AHgGHFsvQRtnLBsgzbPc1PotYgaVqapsYvOqwbTi4(fiwRGmQsHqKfKku)ux3NwHczf0hZegacrwqQq9tj(0I7rrTcnhFA3p1bjo)ux3NwHczfeGmnezbPc1pL4tj4Pf3JIAfAo(0UFQdsC(PUUpT4EuuRqZXNk1tL4uL8tjmjhMIVSKCFlaAEWeRve5ebBLLQuLQK89iy4ll1LdND4SeND4utYodaJZ6NKSKU)ybfQF6P(0Wu8L9ufFQb(sNKpaRLRWKSJ(uhbWpp90raa8f8s7Op90TPwse8uhYHRFQdND48l9lTJ(0CuzbRhhjTV0o6tLup1rO1O(P5inVhvWxAh9PsQN6i0Au)ujnCtTGlp90BBY6qs3FGmnN1)ujnCtTGlWxAh9PsQN6i0Au)0oJQu4tLZ2w90AF6banRNmQN6iYro9aFPD0NkPE6PVKGMwXxgcYrppnhbGg(Wx2t5Zt1OcludFPD0NkPEQJqRr9tpDn4tL0l0pWxAh9PsQNMRtmU6PiRaxEQDbpTtvOXPwGh(s)s7Op90xsqtRq9tjr7cWNAwpzupLe75Sb(uhHXGh18u2YKuzbWBBQNgMIVS5PltDb(s7OpnmfFzd8aGM1tgvERkMREPD0NgMIVSbEaqZ6jJ6K8Dy3v)s7OpnmfFzd8aGM1tg1j57iA9EKvrXx2lTJ(uzwCmzB9uqW1pLSzTO(Ptf18us0Ua8PM1tg1tjXEoBEAW0p9aGsQJTkoR)P85P6LHWx6Wu8LnWdaAwpzuNKVdYOkfkMSTvV0HP4lBGha0SEYOojFhTbf8c9xZcpMpY5KfGye2LvI1kowNi4LomfFzd8aGM1tg1j57WJ(fCrSwHQz4AHgGHFUMBZxHczf0IG7xGyTcYOkfcrwqQqTR7TkuiRGweC)ceRvqgvPqiYcsfQjwCpkQvO5y3si5ZV0HP4lBGha0SEYOojFh9TaO5btSwrKteSv21CB(kuiRGweC)ceRvqgvPqiYcsfQDDRqHSc6JzcdaHilivOMyX9OOwHMJD7GeNDDRqHSccqMgISGuHAIeuCpkQvO5y3oiXzx3I7rrTcnhLsItvYe(s)s7Op90xsqtRq9tX7rWLNwCp(0kdFAyQf8u(804(GRcsfcFPdtXx2K3KfGE8LomfFzZj574O59O6LomfFzZj574yl(YUMBZtqfGESGzyOQm4HPKYbjCDRqHSc6JzcdaHilivOMyfGESGzyOQm4HPK6UtJqIeq2SwOh9l4IyTcvZW1cnad)aBhUUKnRf23cGMhmXAfrorWwzW2bHUU3WzqMbHE0VGlI1kundxl0am8d0hoEbeVHZGmdcnltJSb1cf3I2fyqOpC8cisqfGESGzyOQm4HPKYbjCDRqHSc6JzcdaHilivOMyfGESGzyOQm4HPK6UtJqIAKSzTqZQ2zAJy8XKbBhUUwEFwjaOp4SrkhK8lDyk(YMtY3bPAxTW2axUMBZt2SwOh9l4IyTcvZW1cnad)aBhejBwlSWPeRv459zfSD46s2SwyFlaAEWeRve5ebBLbBhe1izZAHMvTZ0gX4Jjd2oCDjBwlCqSY4SEbi6ry7W1LGB4miZGqp6xWfXAfQMHRfAag(b6dhVaI3WzqMbHMLPr2GAHIBr7cmi0hoEbeVHZGmdcjv7QfRvuzOazO)c0hoEbe1izZAHMvTZ0gX4Jjd2oi8LomfFzZj57GebdcUIZ6VMBZt2SwOh9l4IyTcvZW1cnad)aBhejBwlSWPeRv459zfSD46s2SwyFlaAEWeRve5ebBLbBhe1izZAHMvTZ0gX4Jjd2oCDjBwlCqSY4SEbi6ry7W1LGB4miZGqp6xWfXAfQMHRfAag(b6dhVaI3WzqMbHMLPr2GAHIBr7cmi0hoEbeVHZGmdcjv7QfRvuzOazO)c0hoEbe1izZAHMvTZ0gX4Jjd2oi8LomfFzZj57iaMGHIAbaKvxZT5jBwl0J(fCrSwHQz4AHgGHFG61jJii6rPK8zIey2vPxNmOFbvOetb4xHqa6doB6U3ODDjOcqpwWmmuvg8Wus5Wzx3kuiRG(yMWaqiYcsfQjwbOhlyggQkdEykPUtYes4lDyk(YMtY3HI3NvJWXnDVhz11CBEns2SwOzv7mTrm(yYG61j7LomfFzZj57WYbiPAx91CBEYM1c9OFbxeRvOAgUwOby4hy7GizZAHfoLyTcpVpRGTdxxYM1c7BbqZdMyTIiNiyRmy7GOgjBwl0SQDM2igFmzW2HRlzZAHdIvgN1larpcBhUUeCdNbzge6r)cUiwRq1mCTqdWWpqF44fq8godYmi0SmnYguluClAxGbH(WXlG4nCgKzqiPAxTyTIkdfid9xG(WXlGOgjBwl0SQDM2igFmzW2bHV0HP4lBojFhbZGtbcLWek11CBEYM1c9OFbxeRvOAgUwOby4hy7GizZAHfoLyTcpVpRGTdxxYM1c7BbqZdMyTIiNiyRmy7GOgjBwl0SQDM2igFmzW2HRlzZAHdIvgN1larpcBhUUeCdNbzge6r)cUiwRq1mCTqdWWpqF44fq8godYmi0SmnYguluClAxGbH(WXlG4nCgKzqiPAxTyTIkdfid9xG(WXlGOgjBwl0SQDM2igFmzW2bHV0HP4lBojFhKrVyTIcWnxnxZT51izZAHMvTZ0gX4JjdQxNmIKnRf6r)cUiwRq1mCTqdWWpq96Kr0SRsVozq)cQqjMcWVcHa0hC28shMIVS5K8D0guWl0Fnl8y(yYUpy4iaroxGWSGqDn3M)MgjBwlee5CbcZccLqJKnRf2oCDjGGka9ybZWqvzWdtjLdNHs46wHczf0hZegacrwqQqnXka9ybZWqvzWdtj1DsgkbHejGSzTqp6xWfXAfQMHRfAag(b2oisGzxLEDYGE0VGlI1kundxl0am8deG(GZgPK48P56A2vPxNmOh9l4IyTcvZW1cnad)abOp4SrkjK4uiA59zLaG(GZgPC4mXBvOqwb9XmHbGqKfKkutORlzZAH9TaO5btSwrKteSvgSDquJKnRfAw1otBeJpMmy7GqcDDXzqMbHMLPr2GAHIBr7cmi0hoEbeRa0JfmddvLbpmLuoC21LGka9ybZWqvzWdtj1DNHsquJKnRfAwMUzk(9OGZUsOrYM1cBheVHZGmdc9OFbxeRvOAgUwOby4hOpC8ciEdNbzgeAwMgzdQfkUfTlWGqF44fqORlb30izZAHMLPBMIFpk4SReAKSzTW2bXB4miZGqp6xWfXAfQMHRfAag(b6dhVaI3WzqMbHMLPr2GAHIBr7cmi0hoEbe1izZAHMvTZ0gX4Jjd2oi8LomfFzZj57OnOGxO)Aw4X8roNSaeJWUSsSwXX6ebxZT5lUhf1k0CuQt5mrcm7Q0Rtg0SQDM2igFmzqa6doBKschCDjOcfYkOZaqcW4kearwqQqnrZUk96KbDgasagxHaia9bNnsjHdesOR7nns2SwOzv7mTrm(yYGTdI3iBwlSWPeRv459zfSDq8gzZAHE0VGlI1kundxl0am8dSDqS4EuuRqZXULqYNFPdtXx2Cs(oI7JkaxZT5VHZGmdc9OFbxeRvOAgUwOby4hOpC8cCDjGSzTqp6xWfXAfQMHRfAag(b2oCDn7Q0Rtg0J(fCrSwHQz4AHgGHFGa0hC209PkzcFPdtXx2Cs(oAdk4f6NR528MDv61jdAw1otBeJpMmia9bNnsLdUUeuHczf0zaibyCfcGilivOMOzxLEDYGodajaJRqaeG(GZgPYbcFPdtXx2Cs(ogNiEWz9IPa8RW5AUn)CGkLOcqpwd0zghOCYz6ULGibMDv61jdsQcno1c8qa6doB6wIZUUMDv61jdAw1otBeJpMmia9bNnDNdUUroraVqyHtjwRWZ7ZkiYcsfQj8LomfFzZj57GuTRwSwrLHcKH(lxZT5jGSzTWcNsSwHN3NvW2HRlbAKSzTqZQ2zAJy8XKbBheVf5eb8cHfoLyTcpVpRGilivOMqcjsGL3Nvca6doB6ohF21LGka9ybZWqvzWdtjLdNDDRqHSc6JzcdaHilivOMyfGESGzyOQm4HPK6ojtiHV0HP4lBojFhhna3EHZ6fKQyQR52830izZAHMvTZ0gX4Jjd2oiEJSzTWcNsSwHN3NvW2XlDyk(YMtY3bGFCOqbNjMJWGxZT5VPrYM1cnRANPnIXhtgSDq8gzZAHfoLyTcpVpRGTJx6Wu8LnNKVdNlqPVh5mbaNLfmdEn3M)MgjBwl0SQDM2igFmzW2bXBKnRfw4uI1k88(Sc2oEPdtXx2Cs(oSRPnOwe5eb8cfKy4VMBZFtJKnRfAw1otBeJpMmy7G4nYM1clCkXAfEEFwbBhV0HP4lBojFhamo4SEHvfECUMBZFtJKnRfAw1otBeJpMmy7G4nYM1clCkXAfEEFwbBhV0HP4lBojFhMLzqwbIc1cRk841CB(BAKSzTqZQ2zAJy8XKbBheVr2SwyHtjwRWZ7Zky7GOElOzzgKvGOqTWQcpkiBageG(GZM8NFPdtXx2Cs(oQmu0yKBJPf2fyWR528KnRfcqZvkCgHDbge2oEPdtXx2Cs(o6BbqZdMyTIiNiyRSR5283QqHSc6maKamUcbqKfKkut0SRsVozqZQ2zAJy8XKbbOp4SrkjtKalVpRea0hC20TdsC21LGka9ybZWqvzWdtjLdNDDRqHSc6JzcdaHilivOMyfGESGzyOQm4HPK6ojtORRL3Nvca6doBK6oji8LomfFzZj57OVfanpyI1kICIGTYUMBZxHczf0zaibyCfcGilivOMOzxLEDYGodajaJRqaeG(GZgPKmrcS8(SsaqFWzt3oiXzxxcQa0JfmddvLbpmLuoC21TcfYkOpMjmaeISGuHAIva6XcMHHQYGhMsQ7KmHUUwEFwjaOp4SrQ7KGWx6Wu8LnNKVdp6xWfXAfQMHRfAag(5AUn)TkuiRGodajaJRqaezbPc1en7Q0Rtg0SQDM2igFmzqa6doBKscIey59zLaG(GZMULqYNDDjOcqpwWmmuvg8Wus5Wzx3kuiRG(yMWaqiYcsfQjwbOhlyggQkdEykPUtYes4lDyk(YMtY3Hh9l4IyTcvZW1cnad)Cn3MVcfYkOZaqcW4kearwqQqnrZUk96KbDgasagxHaia9bNnsjbrcS8(SsaqFWzt3si5ZUUeubOhlyggQkdEykPC4SRBfkKvqFmtyaiezbPc1eRa0JfmddvLbpmLu3jzcj8LomfFzZj57yoWaiwRGmMIVSx6Wu8LnNKVdZYoD2qWcgbzWyi4LomfFzZj57iygoYkrylemzR5Qx6Wu8LnNKVdZY0ONDn3MNSzTWPP1itOXOYGTdxxq0JDN)up76wbOhlyX9OOwHMJs1B0V0HP4lBojFhGgteMIVmHIp11SWJ5rjbnTcVMBZtqfkKvqFmtyaiezbPc1eRa0JfmddvLbpmLu3jzcDDRa0JfmddvLbpmLuoC(LomfFzZj57a0yIWu8Lju8PUMfEm)Wz9kuubOhRx6x6Wu8LnqusqtRW8aKPVMBZdqFWzJu51nqu8L5ipdV7LomfFzdeLe00k8K8DOXqRUimHY)shMIVSbIscAAfEs(oMRAk1CO4vHGR528GOhLsYoqKSzTqp6xWfXAfQMHRfAag(bQxNmxxq0Js5W5x6Wu8LnqusqtRWtY3biUp6rW1xZT5n7Q0Rtg0SQDM2igFmzqa6doBKYbxxcQqHSc6maKamUcbqKfKkut0SRsVozqNbGeGXviacqFWzJuoq4lDyk(YgikjOPv4j57WSQDM2igFmzxZT5VHZGmdc9OFbxeRvOAgUwOby4hOpC8cCDjGSzTqp6xWfXAfQMHRfAag(b2oCDn7Q0Rtg0J(fCrSwHQz4AHgGHFGa0hC20TeNj8LomfFzdeLe00k8K8D4maKamUcbxZT5VHZGmdc9OFbxeRvOAgUwOby4hOpC8cCDjGSzTqp6xWfXAfQMHRfAag(b2oCDn7Q0Rtg0J(fCrSwHQz4AHgGHFGa0hC20TeNj8LomfFzdeLe00k8K8D4xqfkXua(v41CBE9wqnIhcNBJPhia9bNnsLx3arXxMJ8m8oIemhOsjQa0J1aDMXbkNCMoVeUU3MduPeva6XAGoZ4aLtot3TeeVvHczf0OW4EeISGuHAcFPdtXx2arjbnTcpjFhgfg3JxZT5jyoqLsubOhRb6mJduo5mD3oquVfuJ4HW52y6bcqFWzJu51nqu8L5ipdVJqxxcMduPeva6XAGoZ4aLtot39De(shMIVSbIscAAfEs(oivHgNAb(R5283iBwl0J(fCrSwHQz4AHgGHFGTdIKnRfw4uI1k88(Sc2oicIEuQ7ot8gzZAHAm0QlctO8W2XlDyk(YgikjOPv4j57aLe00k8AUnpzZAHE0VGlI1kundxl0am8dSD46s2SwOgdT6IWekpSD46QrYM1cnRANPnIXhtgSD46s2SwyHtjwRWZ7Zky74LomfFzdeLe00k8K8DqQcno1c8xZT5Vr2SwOh9l4IyTcvZW1cnad)aBheVf5eb8cHfoLyTcpVpRGilivOMii6rPU7mXBKnRfQXqRUimHYdBhV0HP4lBGOKGMwHNKVJrf(R528KnRfAaTjJZ6fXmrtvW2brYM1c9OFbxeRvOAgUwOby4hOEDYEPdtXx2arjbnTcpjFhaKPVMBZdqFWzJu51nqu8L5ipdVJyfGESGf3JIAfAo29P8shMIVSbIscAAfEs(o27rWX6ebV0HP4lBGOKGMwHNKVdZY0ON9shMIVSbIscAAfEs(oqjbnTcFPdtXx2arjbnTcpjFh3Zn1cUiaTj7LomfFzdeLe00k8K8DW9hitZz9I75MAbxEPFPdtXx2ahoRxHIka9yLhGm91CBEa6doBKkVUbIIVmh5z4DV0HP4lBGdN1RqrfGESojFhAm0QlctO8V0HP4lBGdN1RqrfGESojFhZvnLAou8QqW1CBEq0JsDANjs2SwOgdT6IWekpuVozejBwl0J(fCrSwHQz4AHgGHFG61jZ1fe9OuoC(LomfFzdC4SEfkQa0J1j57ae3h9i4AUnpbMDv61jdAw1otBeJpMmia9bNns5GRlbvOqwbDgasagxHaiYcsfQjA2vPxNmOZaqcW4keabOp4SrkhiKWx6Wu8LnWHZ6vOOcqpwNKVd)cQqjMcWVcVMBZR3cQr8q4CBm9abOp4SrQ86gik(YCKNH3rKG5avkrfGESgOZmoq5KZ05LW19wfkKvqJcJ7riYcsfQj8LomfFzdC4SEfkQa0J1j57WOW4E8AUn)CGkLOcqpwd0zghOCYz6UDGOElOgXdHZTX0deG(GZgPYRBGO4lZrEgE3lDyk(Yg4Wz9kuubOhRtY3Hzv7mTrm(yYUMBZFdNbzgeAwMgzdQfkUfTlWGqKfKkut8wfkKvqFmtyaiezbPc1ejOcqpwWI7rrTIdtjC4C3sC211Y7Zkba9bNnDl5Ze66IZGmdcnltJSb1cf3I2fyqiYcsfQjERcfYkOpMjmaeISGuHAIeubOhlyX9OOwXHPeoCUBjo76A59zLaG(GZMUZHZe66wHczf0hZegacrwqQqnrcQa0JfS4EuuR4WuI7KC3sC211Y7Zkba9bNnDl5Ze(shMIVSboCwVcfva6X6K8D4maKamUcbxZT5VHZGmdcnltJSb1cf3I2fyqiYcsfQjERcfYkOpMjmaeISGuHAIeubOhlyX9OOwXHPeoCUBjo76A59zLaG(GZMUL8zcDDXzqMbHMLPr2GAHIBr7cmiezbPc1eVvHczf0hZegacrwqQqnrcQa0JfS4EuuR4Wucho3TeNDDT8(SsaqFWzt35WzcDDRqHSc6JzcdaHilivOMibva6XcwCpkQvCykXDsUBjo76A59zLaG(GZMUL8zcFPdtXx2ahoRxHIka9yDs(oqjbnTcVMBZt2Sw400AKj0yuzqagM6L2rFQKU)aS3JpTtvOXPwG)PTj6XNYzp13ufxsvbOhl4lDyk(Yg4Wz9kuubOhRtY3bPk04ulWFn3Mpmf)EuGm0ZXPBjisWTkuiRGAm0QlctO8qKfKku76s2SwOgdT6IWekpuVozesKGiNiGxiSWPeRv459zfezbPc1e1izZAHMvTZ0gX4JjdQxNmIKnRfw4uI1k88(Sc2oCDVf5eb8cHfoLyTcpVpRGilivOMOgjBwl0SQDM2igFmzW2bHV0HP4lBGdN1RqrfGESojFhKQqJtTa)1CBEZUk96Kb9lOcLyka)kecqFWzdrc0izZAHMvTZ0gX4JjdQxNmIKnRfw4uI1k88(Sc2oCD1izZAHMvTZ0gX4Jjd2oiElYjc4fclCkXAfEEFwbrwqQqnHej4wfkKvqngA1fHjuEiYcsfQDDjBwluJHwDrycLhQxNmcjs2SwOh9l4IyTcvZW1cnad)a1Rtgrq0JsDQNFPdtXx2ahoRxHIka9yDs(o8lOcLyka)k8AUn)CGkLOcqpwd0zghOCYz68s46ERcfYkOrHX9iezbPc1V0HP4lBGdN1RqrfGESojFhgfg3JxZT5NduPeva6XAGoZ4aLtot3TdV0HP4lBGdN1RqrfGESojFhoZ4aLtotFn3MNaciGSzTqp6xWfXAfQMHRfAag(b2oi01Lans2SwOzv7mTrm(yYGTdcDDjGSzTqngA1fHjuEy7GqcjwHczf0IG7xGyTcYOkfcrwqQqnHUUeqazZAHE0VGlI1kundxl0am8dSD46cIES7Cihtirns2SwOzv7mTrm(yYGTdIKnRfw4uI1k88(ScQxNmI3QqHScArW9lqSwbzuLcHilivOMWx6Wu8LnWHZ6vOOcqpwNKVJrf(R5283QqHScArW9lqSwbzuLcHilivOMibKnRf6r)cUiwRq1mCTqdWWpW2HRRgjBwl0SQDM2igFmzW2bHV0HP4lBGdN1RqrfGESojFh79i4yDIGx6Wu8LnWHZ6vOOcqpwNKVdNzCGYjNPVMBZxHczf0IG7xGyTcYOkfcrwqQqnrciBwlSWPeRv459zfSD46QrYM1cnRANPnIXhtguVozejBwlSWPeRv459zfuVozebrp29PDMWx6Wu8LnWHZ6vOOcqpwNKVJrf(R5283QqHScArW9lqSwbzuLcHilivO(LomfFzdC4SEfkQa0J1j574EUPwWfbOnzV0HP4lBGdN1RqrfGESojFhC)bY0CwV4EUPwWLK8CGMuxNIePkvPe]] )


end
