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


    spec:RegisterPack( "Arms", 20201020, [[dGeizbqieYJKkWMiWNOcPQrPs5uQuTkek5vQiMLkr3IkKSlq)suvdtf1XqqlJG6ziGPjvqxdbABQiPVPIunovK4CuHO1rfsL5rqUNOY(Kk1brOuluQKhsfc6IQiL6KuHqRKkyMQiLyNsf9tvKcnuQqklvfPKEkHMQOkxvfPGTsfc8vvKISxQ6VenyuoSWIr0JjzYuCzOntPpRcJwuonQwnvOETkHztQBlYUr63knCPQJRIuulxvpxX0LCDPSDeQ(ov04rO48QKwVuHMpvA)a7j0NNx0ef67u4ZcFMWZcFgsOJKGctqc9I11E0l2hQlId0lsJe6fj2FA8I9Xv9ggFEEXzBVc9Izv1po6Yp)dEL1iHQnL)WtnDu8LQ(Ww5p8KkFVizJRlhrQN0lAIc9Dk8zHpt4zHpdj0rsqH7Wt3lgTkBFVOip10rXxQJWpSLxmJBmi1t6fn4O8IDaGrS)0ayNMI)57dCOdaStJQAjXhWe(8LaMWNf(mWbGdDaG5imlOh44Od4qhayokaJyBmObWC0APeQHah6aaZrbyeBJbnaMJaUQ2)kGDATnz57iM6rQHtpamhbCvT)viWHoaWCuagX2yqdG1vuLgbmXSTvawTaw)JQnrgfGrSD0oTabo0baMJcWoTjgu1k(sX3r)ayoApQ4dFPagFamdQXcnqGdDaG5OamITXGga70WGaMJyHPb6f18PgFEEXHtp0OSI)alFE(oj0NNxePbPgn(U8IQNx4ZdV4JPGthatOCaMP9rXxkGrSaSZqc4fdvXxQx8rQXx(of2NNxmufFPErdgg9vPk0jVisdsnA8D5lFNeWNNxePbPgn(U8IQNx4ZdV4hhiGjeGDQNbmbagzZAHgmm6RsvOtqZ6KcycamYM1ctyA)RY1k1nf3inpgPbAwNuaZ1fW(4abmHamHp7fdvXxQxCUOP1tVMxf((Y3zh6ZZlI0GuJgFxEr1Zl85Hx8gGP2vBwNuOA17mTroPyYGpMcoDamHamHbmxxa7gGvHgPf0z8KpgxGpePbPgnaMaatTR2SoPqNXt(yCb(WhtbNoaMqaMWa2Da7UxmufFPEXpiECGVV8DsqFEErKgKA047YlQEEHpp8IMTGge7Lo3g1mWhtbNoaMq5amt7JIVuaJybyNHeaWeay3aSPh1Azf)bwd0zg)1o5udGLdWieWCDbmIaSk0iTGkngehHini1ObWU7fdvXxQxmTFfA5up)c0x(opvFEErKgKA047YlQEEHpp8ItpQ1Yk(dSgOZm(RDYPgaRBatyataGz2cAqSx6CBuZaFmfC6aycLdWmTpk(sbmIfGDgsaVyOk(s9Ikngeh9LVZt3NNxePbPgn(U8IQNx4ZdViragodsviuTudsh0i1ClA3xHqKgKA0aycamIaSk0iTGPyMq9iePbPgnaMaa7gGvXFGfS4juwRSxvsHpdyDdyeEgWCDbml)iRKpMcoDaSUbmcEgWUdyUUagodsviuTudsh0i1ClA3xHqKgKA0aycamIaSk0iTGPyMq9iePbPgnaMaa7gGvXFGfS4juwRSxvsHpdyDdyeEgWCDbml)iRKpMcoDaSUbSt5mGDhWCDbSk0iTGPyMq9iePbPgnaMaa7gGvXFGfS4juwRSxvscqqaRBaJWZaMRlGz5hzL8XuWPdG1nGrWZa2DVyOk(s9IQvVZ0g5KIjZx(opfFEErKgKA047YlQEEHpp8Ieby4mivHq1sniDqJuZTODFfcrAqQrdGjaWicWQqJ0cMIzc1JqKgKA0aycaSBawf)bwWINqzTYEvjf(mG1nGr4zaZ1fWS8JSs(yk40bW6gWi4za7oG56cy4mivHq1sniDqJuZTODFfcrAqQrdGjaWicWQqJ0cMIzc1JqKgKA0aycaSBawf)bwWINqzTYEvjf(mG1nGr4zaZ1fWS8JSs(yk40bW6gWoLZa2DaZ1fWQqJ0cMIzc1JqKgKA0aycaSBawf)bwWINqzTYEvjjabbSUbmcpdyUUaMLFKvYhtbNoaw3agbpdy39IHQ4l1l6mEYhJlW3x(oDK(88Iini1OX3Lxu98cFE4fjBwlCAgdsLgmQm4JHQ8IHQ4l1lIedQAf6lFNeE2NNxePbPgn(U8IQNx4ZdVOAxTzDsHP9RqlN65xGWhtbNoaMaaZGKnRfQw9otBKtkMmOzDsbmba2naJiaRcnslObdJ(Quf6eePbPgnaMRlGr2SwObdJ(Quf6e0SoPa2DataGDdWUbygKSzTq1Q3zAJCsXKbB9aMaaJial6i(8cHfoLCTYe)iRGini1ObWUdyUUagzZAHfoLCTYe)iRGTEa7oGjaWiBwlmHP9VkxRu3uCJ08yKgOzDsbmba2hhiGjeG1HN9IHQ4l1lsQddo1(jF57Kqc955frAqQrJVlVO65f(8Wlo9OwlR4pWAGoZ4V2jNAaSCagHaMRlGreGvHgPfuPXG4iePbPgnEXqv8L6ft7xHwo1ZVa9LVtcf2NNxePbPgn(U8IQNx4ZdV40JATSI)aRb6mJ)ANCQbW6gWe2lgQIVuVOsJbXrF57Kqc4ZZlI0GuJgFxEr1Zl85Hx8gGDdWUbyKnRfMW0(xLRvQBkUrAEmsdS1dy3bmxxa7gGzqYM1cvRENPnYjftgS1dy3bmxxa7gGr2SwObdJ(Quf6eS1dy3bS7aMaaRcnslOfFIVVCTsYOkncrAqQrdGDhWCDbSBa2naJSzTWeM2)QCTsDtXnsZJrAGTEaZ1fW(4abSUbStXrcy3bmbaMbjBwluT6DM2iNumzWwpGjaWiBwlSWPKRvM4hzf0SoPaMaaJiaRcnslOfFIVVCTsYOkncrAqQrdGD3lgQIVuVOZm(RDYPgF57KWo0NNxePbPgn(U8IQNx4ZdVirawfAKwql(eFF5ALKrvAeI0GuJgataGDdWiBwlmHP9VkxRu3uCJ08yKgyRhWCDbmds2SwOA17mTroPyYGTEa7UxmufFPEXrhjF57Kqc6ZZlgQIVuV4sC87xN47frAqQrJVlF57KWt1NNxePbPgn(U8IQNx4ZdVyfAKwql(eFF5ALKrvAeI0GuJgataGDdWiBwlSWPKRvM4hzfS1dyUUaMbjBwluT6DM2iNumzqZ6KcycamYM1clCk5ALj(rwbnRtkGjaW(4abSUbSt9mGD3lgQIVuVOZm(RDYPgF57KWt3NNxePbPgn(U8IQNx4ZdVirawfAKwql(eFF5ALKrvAeI0GuJgVyOk(s9IJos(Y3jHNIppVyOk(s9IeNRQ9Vk)2K5frAqQrJVlF57KqhPppVyOk(s9I8upsnC6HK4CvT)vVisdsnA8D5lF5frIbvTc9557KqFEErKgKA047YlQEEHpp8IpMcoDamHYbyM2hfFPagXcWodjGxmufFPEXhPgF57uyFEEXqv8L6fnyy0xLQqN8Iini1OX3LV8DsaFEErKgKA047YlQEEHpp8IFCGaMqagbfgWeayKnRfMW0(xLRvQBkUrAEmsd0SoPaMRlG9XbcycbycF2lgQIVuV4CrtRNEnVk89LVZo0NNxePbPgn(U8IQNx4ZdVOAxTzDsHQvVZ0g5KIjd(yk40bWecWegWCDbSBawfAKwqNXt(yCb(qKgKA0aycam1UAZ6KcDgp5JXf4dFmfC6aycbycdy39IHQ4l1l(bXJd89LVtc6ZZlI0GuJgFxEr1Zl85HxKiadNbPkeMW0(xLRvQBkUrAEmsdmfoEFaZ1fWUbyKnRfMW0(xLRvQBkUrAEmsdS1dyUUaMAxTzDsHjmT)v5AL6MIBKMhJ0aFmfC6ayDdyeEgWU7fdvXxQxuT6DM2iNumz(Y35P6ZZlI0GuJgFxEr1Zl85HxKiadNbPkeMW0(xLRvQBkUrAEmsdmfoEFaZ1fWUbyKnRfMW0(xLRvQBkUrAEmsdS1dyUUaMAxTzDsHjmT)v5AL6MIBKMhJ0aFmfC6ayDdyeEgWU7fdvXxQx0z8KpgxGVV8DE6(88Iini1OX3Lxu98cFE4fnBbni2lDUnQzGpMcoDamHYbyM2hfFPagXcWodjaGjaWUbytpQ1Yk(dSgOZm(RDYPgalhGriG56cyebytpQ1Yk(dSgOZm(RDYPgaRBaJqataGreGvHgPfuPXG4iePbPgna2DVyOk(s9IP9RqlN65xG(Y35P4ZZlI0GuJgFxEr1Zl85Hx8gGn9OwlR4pWAGoZ4V2jNAaSUbmHbmbaMzlObXEPZTrnd8XuWPdGjuoaZ0(O4lfWiwa2zibaS7aMRlGDdWMEuRLv8hynqNz8x7Ktnaw3agbaS7EXqv8L6fvAmio6lFNosFEErKgKA047YlQEEHpp8IebyKnRfMW0(xLRvQBkUrAEmsdS1dycamYM1clCk5ALj(rwbB9aMaa7JdeWecWiWzataGreGr2SwObdJ(Quf6eS17fdvXxQxKuhgCQ9t(Y3jHN955frAqQrJVlVO65f(8Wls2Swyct7FvUwPUP4gP5XinWwpG56cyKnRfAWWOVkvHobB9aMRlGzqYM1cvRENPnYjftgS1dyUUagzZAHfoLCTYe)iRGTEVyOk(s9IiXGQwH(Y3jHe6ZZlI0GuJgFxEr1Zl85HxKSzTq13Mmo9qgZenDbB9aMaaJSzTWeM2)QCTsDtXnsZJrAGM1j1lgQIVuV4OJKV8DsOW(88Iini1OX3Lxu98cFE4fFmfC6aycLdWmTpk(sbmIfGDgsaataGvXFGfS4juwR0WraRBa709IHQ4l1l(i14lFNesaFEEXqv8L6fxIJF)6eFVisdsnA8D5lFNe2H(88IHQ4l1lQwQbtuVisdsnA8D5lFNesqFEEXqv8L6frIbvTc9Iini1OX3LV8Ds4P6ZZlgQIVuViX5QA)RYVnzErKgKA047Yx(oj80955fdvXxQxKN6rQHtpKeNRQ9V6frAqQrJVlF5lVObTrtx(88DsOppVyOk(s9IQS4pqVisdsnA8D5lFNc7ZZlgQIVuVyFlLqTxePbPgn(U8LVtc4ZZlI0GuJgFxEr1Zl85Hx8gGvXFGfmddDLb7vfGjeGjmHaMRlGvHgPfmfZeQhHini1ObWeayv8hybZWqxzWEvbycbye4ubS7aMaa7gGr2Swyct7FvUwPUP4gP5XinWwpG56cyKnRfE0I3WdQCTYOJ4VvgS1dy3bmxxaJiadNbPkeMW0(xLRvQBkUrAEmsdmfoEFataGreGHZGufcvl1G0bnsn3I29vimfoEFataGDdWQ4pWcMHHUYG9QcWecWeMqaZ1fWQqJ0cMIzc1JqKgKA0aycaSk(dSGzyORmyVQamHamcCQa2DataGzqYM1cvRENPnYjftgS1dyUUaMLFKvYhtbNoaMqaMWe0lgQIVuVy)w8L6lFNDOppVisdsnA8D5fvpVWNhErYM1ctyA)RY1k1nf3inpgPb26bmbagzZAHfoLCTYe)iRGTEaZ1fWiBwl8OfVHhu5ALrhXFRmyRhWeaygKSzTq1Q3zAJCsXKbB9aMRlGr2Sw4GyLXPhYpoqyRhWCDbSBagragodsvimHP9VkxRu3uCJ08yKgykC8(aMaaJiadNbPkeQwQbPdAKAUfT7RqykC8(aMaaJiadNbPkesQ31ixRSYqjsX0vykC8(aMaaZGKnRfQw9otBKtkMmyRhWU7fdvXxQxKuVRrAB)vF57KG(88Iini1OX3Lxu98cFE4fjBwlmHP9VkxRu3uCJ08yKgyRhWeayKnRfw4uY1kt8JSc26bmxxaJSzTWJw8gEqLRvgDe)TYGTEataGzqYM1cvRENPnYjftgS1dyUUagzZAHdIvgNEi)4aHTEaZ1fWUbyeby4mivHWeM2)QCTsDtXnsZJrAGPWX7dycamIamCgKQqOAPgKoOrQ5w0UVcHPWX7dycamIamCgKQqiPExJCTYkdLiftxHPWX7dycamds2SwOA17mTroPyYGTEa7UxmufFPErs8h8VGtp8LVZt1NNxePbPgn(U8IQNx4ZdVizZAHjmT)v5AL6MIBKMhJ0anRtkGjaW(4abmHamcEgWeay3am1UAZ6Kct7xHwo1ZVaHpMcoDaSUbSdLbWCDbSBawf)bwWmm0vgSxvaMqaMWNbmxxaRcnslykMjupcrAqQrdGjaWQ4pWcMHHUYG9QcWecWiabbS7a2DVyOk(s9IXRckkR9FKw(Y35P7ZZlI0GuJgFxEr1Zl85Hx0GKnRfQw9otBKtkMmOzDs9IHQ4l1lQ5hz1iDCZCKqA5lFNNIppVisdsnA8D5fvpVWNhErYM1ctyA)RY1k1nf3inpgPb26bmbagzZAHfoLCTYe)iRGTEaZ1fWiBwl8OfVHhu5ALrhXFRmyRhWeaygKSzTq1Q3zAJCsXKbB9aMRlGr2Sw4GyLXPhYpoqyRhWCDbSBagragodsvimHP9VkxRu3uCJ08yKgykC8(aMaaJiadNbPkeQwQbPdAKAUfT7RqykC8(aMaaJiadNbPkesQ31ixRSYqjsX0vykC8(aMaaZGKnRfQw9otBKtkMmyRhWU7fdvXxQx0YFKuVRXx(oDK(88Iini1OX3Lxu98cFE4fjBwlmHP9VkxRu3uCJ08yKgyRhWeayKnRfw4uY1kt8JSc26bmxxaJSzTWJw8gEqLRvgDe)TYGTEataGzqYM1cvRENPnYjftgS1dyUUagzZAHdIvgNEi)4aHTEaZ1fWUbyeby4mivHWeM2)QCTsDtXnsZJrAGPWX7dycamIamCgKQqOAPgKoOrQ5w0UVcHPWX7dycamIamCgKQqiPExJCTYkdLiftxHPWX7dycamds2SwOA17mTroPyYGTEa7UxmufFPEXGQWP(qlvHw7lFNeE2NNxePbPgn(U8IQNx4ZdVObjBwluT6DM2iNumzqZ6KcycamYM1ctyA)RY1k1nf3inpgPbAwNuataGP2vBwNuyA)k0YPE(fi8XuWPJxmufFPErY4qUwz9C1fJV8DsiH(88Iini1OX3LxmufFPEXyYiEqXr(rh3xQ2p0Er1Zl85HxKiaZGKnRf(rh3xQ2p0sds2SwyRhWCDbSBa2naRI)alygg6kd2Rkatiat4ZqcbmxxaRcnslykMjupcrAqQrdGjaWQ4pWcMHHUYG9QcWecWiabHecy3bmba2naJSzTWeM2)QCTsDtXnsZJrAGTEataGDdWu7QnRtkmHP9VkxRu3uCJ08yKg4JPGthatiaJWZNkG56cyQD1M1jfMW0(xLRvQBkUrAEmsd8XuWPdGjeGriHNoGjaWS8JSs(yk40bWecWe(mGjaWicWQqJ0cMIzc1JqKgKA0ay3bmxxaJSzTWJw8gEqLRvgDe)TYGTEataGzqYM1cvRENPnYjftgS1dy3bS7aMRlGHZGufcvl1G0bnsn3I29vimfoEFataGvXFGfmddDLb7vfGjeGj8zaZ1fWUbyv8hybZWqxzWEvbycbye4mKqataGzqYM1cvl10ufN4OKtVqAqYM1cB9aMaaJiadNbPkeMW0(xLRvQBkUrAEmsdmfoEFataGreGHZGufcvl1G0bnsn3I29vimfoEFa7oG56cy3amIamds2SwOAPMMQ4ehLC6fsds2SwyRhWeayeby4mivHWeM2)QCTsDtXnsZJrAGPWX7dycamIamCgKQqOAPgKoOrQ5w0UVcHPWX7dycamds2SwOA17mTroPyYGTEa7UxKgj0lgtgXdkoYp64(s1(H2x(ojuyFEErKgKA047YlgQIVuVy0Xjl(yK2LwY1k7xN47fvpVWNhEXINqzTsdhbmHaSt)mGjaWUbyQD1M1jfQw9otBKtkMm4JPGthatiaJqHbmxxa7gGvHgPf0z8KpgxGpePbPgnaMaatTR2SoPqNXt(yCb(WhtbNoaMqagHcdy3bS7aMRlGreGzqYM1cvRENPnYjftgS1dycamIamYM1clCk5ALj(rwbB9aMaaJiaJSzTWeM2)QCTsDtXnsZJrAGTEataGv8ekRvA4iG1nGribp7fPrc9IrhNS4JrAxAjxRSFDIVV8Dsib855frAqQrJVlVO65f(8WlseGHZGufctyA)RY1k1nf3inpgPbMchVpG56cy3amYM1ctyA)RY1k1nf3inpgPb26bmxxatTR2SoPWeM2)QCTsDtXnsZJrAGpMcoDaSUbSoKGa2DVyOk(s9IbXJkEF57KWo0NNxePbPgn(U8IQNx4ZdVOAxTzDsHQvVZ0g5KIjd(yk40bWecWofaZ1fWUbyvOrAbDgp5JXf4drAqQrdGjaWu7QnRtk0z8KpgxGp8XuWPdGjeGDka2DVyOk(s9ITbL8ctJV8Dsib955frAqQrJVlVO65f(8Wlo9OwlR4pWAGoZ4V2jNAaSUbmcbmba2natTR2SoPqsDyWP2pbFmfC6ayDdyeEgWCDbm1UAZ6KcvRENPnYjftg8XuWPdG1nGDkaMRlGfDeFEHWcNsUwzIFKvqKgKA0ay39IHQ4l1loorSNtpKt98lWXx(oj8u955frAqQrJVlVO65f(8WlEdWiBwlSWPKRvM4hzfS1dyUUa2naZGKnRfQw9otBKtkMmyRhWeayebyrhXNxiSWPKRvM4hzfePbPgna2Da7oGjaWUbyw(rwjFmfC6ayDdyoYZaMRlGDdWQ4pWcMHHUYG9QcWecWe(mG56cyvOrAbtXmH6risdsnAambawf)bwWmm0vgSxvaMqagbiiGDhWU7fdvXxQxKuVRrUwzLHsKIPR(Y3jHNUppVisdsnA8D5fvpVWNhErIamds2SwOA17mTroPyYGTEataGreGr2SwyHtjxRmXpYkyR3lgQIVuVyF752RC6HKuht5lFNeEk(88Iini1OX3Lxu98cFE4fjcWmizZAHQvVZ0g5KIjd26bmbagragzZAHfoLCTYe)iRGTEVyOk(s9IpVVxJsovo9Hc9LVtcDK(88Iini1OX3Lxu98cFE4fjcWmizZAHQvVZ0g5KIjd26bmbagragzZAHfoLCTYe)iRGTEVyOk(s9Io3xBioYPYhNLguf6lFNcF2NNxePbPgn(U8IQNx4ZdViraMbjBwluT6DM2iNumzWwpGjaWicWiBwlSWPKRvM4hzfS17fdvXxQx0UQ2Ggz0r85fkjXi5lFNctOppVisdsnA8D5fvpVWNhErIamds2SwOA17mTroPyYGTEataGreGr2SwyHtjxRmXpYkyR3lgQIVuV4JrpNEiT6iHJV8DkSW(88Iini1OX3Lxu98cFE4fjcWmizZAHQvVZ0g5KIjd26bmbagragzZAHfoLCTYe)iRGTEataGz2cQwQcP1hfAKwDKqjz7PWhtbNoawoa7SxmufFPEr1sviT(OqJ0QJe6lFNctaFEErKgKA047YlQEEHpp8IKnRf(O6cnoJ0UVcHTEVyOk(s9IvgkBuYTrns7(k0x(ofUd955frAqQrJVlVO65f(8WlseGvHgPf0z8KpgxGpePbPgnaMaatTR2SoPq1Q3zAJCsXKbFmfC6aycbyeeWeay3aml)iRKpMcoDaSUbmHj8mG56cy3aSk(dSGzyORmyVQamHamHpdyUUawfAKwWumtOEeI0GuJgataGvXFGfmddDLb7vfGjeGraccy3bmxxaZYpYk5JPGthatiaJaecy39IHQ4l1lE0I3WdQCTYOJ4VvMV8Dkmb955frAqQrJVlVO65f(8WlwHgPf0z8KpgxGpePbPgnaMaatTR2SoPqNXt(yCb(WhtbNoaMqagbbmba2naZYpYk5JPGthaRBatycpdyUUa2naRI)alygg6kd2Rkatiat4ZaMRlGvHgPfmfZeQhHini1ObWeayv8hybZWqxzWEvbycbyeGGa2DaZ1fWS8JSs(yk40bWecWiaHa2DVyOk(s9IhT4n8GkxRm6i(BL5lFNcFQ(88Iini1OX3Lxu98cFE4fjcWQqJ0c6mEYhJlWhI0GuJgataGP2vBwNuOA17mTroPyYGpMcoDamHamcbmba2naZYpYk5JPGthaRBaJqcEgWCDbSBawf)bwWmm0vgSxvaMqaMWNbmxxaRcnslykMjupcrAqQrdGjaWQ4pWcMHHUYG9QcWecWiabbS7a2DVyOk(s9IjmT)v5AL6MIBKMhJ04lFNcF6(88Iini1OX3Lxu98cFE4fRqJ0c6mEYhJlWhI0GuJgataGP2vBwNuOZ4jFmUaF4JPGthatiaJqataGDdWS8JSs(yk40bW6gWiKGNbmxxa7gGvXFGfmddDLb7vfGjeGj8zaZ1fWQqJ0cMIzc1JqKgKA0aycaSk(dSGzyORmyVQamHamcqqa7oGD3lgQIVuVyct7FvUwPUP4gP5Xin(Y3PWNIppVyOk(s9ItpgVCTsYyk(s9Iini1OX3LV8DkSJ0NNxmufFPEr1spn3WF)rsguk(ErKgKA047Yx(ojWzFEEXqv8L6fdQIJ0sg2c)jBvx4frAqQrJVlF57Kae6ZZlI0GuJgFxEr1Zl85HxKSzTWPzmivAWOYGTEaZ1fW(4abSUZbyD4zaZ1fWQ4pWcw8ekRvA4iGjeGDOmEXqv8L6fvl1GjQV8DsaH955frAqQrJVlVO65f(8WlEdWQqJ0cMIzc1JqKgKA0aycaSk(dSGzyORmyVQamHamcqqa7oG56cyv8hybZWqxzWEvbycbycF2lgQIVuV43OYqv8Lk18P8IA(usAKqVismOQvOV8Dsac4ZZlI0GuJgFxEXqv8L6f)gvgQIVuPMpLxuZNssJe6fho9qJYk(dS8LV8I9pQ2ezu(88DsOppVyOk(s9IKrvAuozBR8Iini1OX3LV8DkSppVisdsnA8D5fPrc9IrhNS4JrAxAjxRSFDIVxmufFPEXOJtw8XiTlTKRv2VoX3x(ojGppVisdsnA8D5fvpVWNhEXk0iTGw8j((Y1kjJQ0iePbPgnaMRlGreGvHgPf0IpX3xUwjzuLgHini1ObWeayfpHYALgocyDdyesWZEXqv8L6ftyA)RY1k1nf3inpgPXx(o7qFEErKgKA047YlQEEHpp8IvOrAbT4t89LRvsgvPrisdsnAamxxaRcnslykMjupcrAqQrdGjaWkEcL1knCeW6gWeMWZaMRlGvHgPf8rQbI0GuJgataGDdWkEcL1knCeW6gWeMWZaMRlGv8ekRvA4iGjeGryhsqa7UxmufFPEXJw8gEqLRvgDe)TY8LV8LxK44p8L67u4ZcFMWZe2HErNXt50JXl6iM63VqdG1HawOk(sbmnFQbcCWlo9OY35PtOxS)xlxJEXoaWi2FAaSttX)89bo0ba2PrvTK4dycF(sat4ZcFg4aWHoaWCeMf0dCC0bCOdamhfGrSng0ayoATuc1qGdDaG5OamITXGgaZraxv7FfWoT2MS8Det9i1WPhaMJaUQ2)ke4qhayokaJyBmObW6kQsJaMy22kaRwaR)r1MiJcWi2oANwGah6aaZrbyN2edQAfFP47OFamhThv8HVuaJpaMb1yHgiWHoaWCuagX2yqdGDAyqaZrSW0aboaCOdaStBIbvTcnagjA3hbm1MiJcWiXdoDGagXwPW(Aam6sDuzXNSnnGfQIV0bWwQ(ke4qhayHQ4lDG9pQ2ezu5S6yUa4qhayHQ4lDG9pQ2ezuNKlF7UgGdDaGfQIV0b2)OAtKrDsU8J2rcPvu8LcCOdamrA0pzBbyFWnagzZArdGnvudGrI29ratTjYOams8GthalOgaR)rhv)wfNEay8bWmlfHahcvXx6a7FuTjYOojx(KrvAuozBRaoeQIV0b2)OAtKrDsU8Bdk5fMUKgjmx0Xjl(yK2LwY1k7xN4dCiufFPdS)r1MiJ6KC5NW0(xLRvQBkUrAEmsZLCBUk0iTGw8j((Y1kjJQ0iePbPgnUUevHgPf0IpX3xUwjzuLgHini1OrqXtOSwPHJDtibpdCiufFPdS)r1MiJ6KC5F0I3WdQCTYOJ4Vv2LCBUk0iTGw8j((Y1kjJQ0iePbPgnUUvOrAbtXmH6risdsnAeu8ekRvA4y3ct4zx3k0iTGpsnqKgKA0i4wXtOSwPHJDlmHNDDlEcL1knCuic7qcEh4aWHoaWoTjgu1k0ayiXX)kGv8ecyvgcyHQ2hW4dGfep46GuJqGdHQ4lDYPYI)aboeQIV05KC533sjudCiufFPZj5YVFl(sVKBZDRI)alygg6kd2RkHeMqx3k0iTGPyMq9iePbPgncQ4pWcMHHUYG9QsicCQ3fCJSzTWeM2)QCTsDtXnsZJrAGTExxYM1cpAXB4bvUwz0r83kd26V76seodsvimHP9VkxRu3uCJ08yKgykC8(cicNbPkeQwQbPdAKAUfT7RqykC8(cUvXFGfmddDLb7vLqctORBfAKwWumtOEeI0GuJgbv8hybZWqxzWEvjebo17cmizZAHQvVZ0g5KIjd26DDT8JSs(yk40riHjiWHqv8LoNKlFs9UgPT9xVKBZr2Swyct7FvUwPUP4gP5XinWwVaYM1clCk5ALj(rwbB9UUKnRfE0I3WdQCTYOJ4VvgS1lWGKnRfQw9otBKtkMmyR31LSzTWbXkJtpKFCGWwVR7nIWzqQcHjmT)v5AL6MIBKMhJ0atHJ3xar4mivHq1sniDqJuZTODFfctHJ3xar4mivHqs9Ug5ALvgkrkMUctHJ3xGbjBwluT6DM2iNumzWw)DGdHQ4lDojx(K4p4FbNECj3MJSzTWeM2)QCTsDtXnsZJrAGTEbKnRfw4uY1kt8JSc26DDjBwl8OfVHhu5ALrhXFRmyRxGbjBwluT6DM2iNumzWwVRlzZAHdIvgNEi)4aHTEx3BeHZGufctyA)RY1k1nf3inpgPbMchVVaIWzqQcHQLAq6GgPMBr7(keMchVVaIWzqQcHK6DnY1kRmuIumDfMchVVads2SwOA17mTroPyYGT(7ahcvXx6CsU8Jxfuuw7)iTUKBZr2Swyct7FvUwPUP4gP5XinqZ6Kk4JduicEwWn1UAZ6Kct7xHwo1ZVaHpMcoD6(qzCDVvXFGfmddDLb7vLqcF21TcnslykMjupcrAqQrJGk(dSGzyORmyVQeIae8(DGdHQ4lDojx(A(rwnsh3mhjKwxYT5mizZAHQvVZ0g5KIjdAwNuGdHQ4lDojx(w(JK6DnxYT5iBwlmHP9VkxRu3uCJ08yKgyRxazZAHfoLCTYe)iRGTExxYM1cpAXB4bvUwz0r83kd26fyqYM1cvRENPnYjftgS176s2Sw4GyLXPhYpoqyR319gr4mivHWeM2)QCTsDtXnsZJrAGPWX7lGiCgKQqOAPgKoOrQ5w0UVcHPWX7lGiCgKQqiPExJCTYkdLiftxHPWX7lWGKnRfQw9otBKtkMmyR)oWHqv8LoNKl)GQWP(qlvHwFj3MJSzTWeM2)QCTsDtXnsZJrAGTEbKnRfw4uY1kt8JSc26DDjBwl8OfVHhu5ALrhXFRmyRxGbjBwluT6DM2iNumzWwVRlzZAHdIvgNEi)4aHTEx3BeHZGufctyA)RY1k1nf3inpgPbMchVVaIWzqQcHQLAq6GgPMBr7(keMchVVaIWzqQcHK6DnY1kRmuIumDfMchVVads2SwOA17mTroPyYGT(7ahcvXx6CsU8jJd5AL1ZvxmxYT5mizZAHQvVZ0g5KIjdAwNubKnRfMW0(xLRvQBkUrAEmsd0SoPcu7QnRtkmTFfA5up)ce(yk40b4qOk(sNtYLFBqjVW0L0iH5IjJ4bfh5hDCFPA)qFj3MJids2Sw4hDCFPA)qlnizZAHTEx3B3Q4pWcMHHUYG9QsiHpdj01TcnslykMjupcrAqQrJGk(dSGzyORmyVQeIaees4Db3iBwlmHP9VkxRu3uCJ08yKgyRxWn1UAZ6KctyA)RY1k1nf3inpgPb(yk40ricpFQUUQD1M1jfMW0(xLRvQBkUrAEmsd8XuWPJqes4PlWYpYk5JPGthHe(SaIQqJ0cMIzc1JqKgKA0C31LSzTWJw8gEqLRvgDe)TYGTEbgKSzTq1Q3zAJCsXKbB93V76IZGufcvl1G0bnsn3I29vimfoEFbv8hybZWqxzWEvjKWNDDVvXFGfmddDLb7vLqe4mKqbgKSzTq1snnvXjok50lKgKSzTWwVaIWzqQcHjmT)v5AL6MIBKMhJ0atHJ3xar4mivHq1sniDqJuZTODFfctHJ3)UR7nImizZAHQLAAQItCuYPxinizZAHTEbeHZGufctyA)RY1k1nf3inpgPbMchVVaIWzqQcHQLAq6GgPMBr7(keMchVVads2SwOA17mTroPyYGT(7ahcvXx6CsU8Bdk5fMUKgjmx0Xjl(yK2LwY1k7xN4Fj3MR4juwR0WrHo9ZcUP2vBwNuOA17mTroPyYGpMcoDeIqHDDVvHgPf0z8KpgxGpePbPgncu7QnRtk0z8KpgxGp8XuWPJqek897UUezqYM1cvRENPnYjftgS1lGiYM1clCk5ALj(rwbB9ciISzTWeM2)QCTsDtXnsZJrAGTEbfpHYALgo2nHe8mWHqv8LoNKl)G4rf)LCBoIWzqQcHjmT)v5AL6MIBKMhJ0atHJ3319gzZAHjmT)v5AL6MIBKMhJ0aB9UUQD1M1jfMW0(xLRvQBkUrAEmsd8XuWPt3DibVdCiufFPZj5YVnOKxyAUKBZP2vBwNuOA17mTroPyYGpMcoDe6uCDVvHgPf0z8KpgxGpePbPgncu7QnRtk0z8KpgxGp8XuWPJqNYDGdHQ4lDojx(Jte750d5up)cCUKBZn9OwlR4pWAGoZ4V2jNA6Mqb3u7QnRtkKuhgCQ9tWhtbNoDt4zxx1UAZ6KcvRENPnYjftg8XuWPt3NIRB0r85fclCk5ALj(rwbrAqQrZDGdHQ4lDojx(K6DnY1kRmuIumD9sUn3nYM1clCk5ALj(rwbB9UU3mizZAHQvVZ0g5KIjd26fqu0r85fclCk5ALj(rwbrAqQrZ97cUz5hzL8XuWPt3oYZUU3Q4pWcMHHUYG9QsiHp76wHgPfmfZeQhHini1Orqf)bwWmm0vgSxvcracE)oWHqv8LoNKl)(2ZTx50djPoM6sUnhrgKSzTq1Q3zAJCsXKbB9ciISzTWcNsUwzIFKvWwpWHqv8LoNKl)N33RrjNkN(qHxYT5iYGKnRfQw9otBKtkMmyRxarKnRfw4uY1kt8JSc26boeQIV05KC57CFTH4iNkFCwAqv4LCBoImizZAHQvVZ0g5KIjd26fqezZAHfoLCTYe)iRGTEGdHQ4lDojx(2v1g0iJoIpVqjjgPl52CezqYM1cvRENPnYjftgS1lGiYM1clCk5ALj(rwbB9ahcvXx6CsU8Fm650dPvhjCUKBZrKbjBwluT6DM2iNumzWwVaIiBwlSWPKRvM4hzfS1dCiufFPZj5YxTufsRpk0iT6iHxYT5iYGKnRfQw9otBKtkMmyRxarKnRfw4uY1kt8JSc26fy2cQwQcP1hfAKwDKqjz7PWhtbNo5odCiufFPZj5YVYqzJsUnQrA3xHxYT5iBwl8r1fACgPDFfcB9ahcvXx6CsU8pAXB4bvUwz0r83k7sUnhrvOrAbDgp5JXf4drAqQrJa1UAZ6KcvRENPnYjftg8XuWPJqeuWnl)iRKpMcoD6wycp76ERI)alygg6kd2RkHe(SRBfAKwWumtOEeI0GuJgbv8hybZWqxzWEvjebi4Dxxl)iRKpMcoDeIaeEh4qOk(sNtYL)rlEdpOY1kJoI)wzxYT5QqJ0c6mEYhJlWhI0GuJgbQD1M1jf6mEYhJlWh(yk40rick4MLFKvYhtbNoDlmHNDDVvXFGfmddDLb7vLqcF21TcnslykMjupcrAqQrJGk(dSGzyORmyVQeIae8URRLFKvYhtbNocracVdCiufFPZj5YpHP9VkxRu3uCJ08yKMl52CevHgPf0z8KpgxGpePbPgncu7QnRtkuT6DM2iNumzWhtbNocrOGBw(rwjFmfC60nHe8SR7Tk(dSGzyORmyVQes4ZUUvOrAbtXmH6risdsnAeuXFGfmddDLb7vLqeGG3VdCiufFPZj5YpHP9VkxRu3uCJ08yKMl52CvOrAbDgp5JXf4drAqQrJa1UAZ6KcDgp5JXf4dFmfC6ieHcUz5hzL8XuWPt3esWZUU3Q4pWcMHHUYG9QsiHp76wHgPfmfZeQhHini1Orqf)bwWmm0vgSxvcracE)oWHqv8LoNKl)PhJxUwjzmfFPahcvXx6CsU8vl90Cd)9hjzqP4dCiufFPZj5YpOkoslzyl8NSvDbWHqv8LoNKlF1snyIEj3MJSzTWPzmivAWOYGTEx3poWUZ1HNDDR4pWcw8ekRvA4OqhkdWHqv8LoNKl)VrLHQ4lvQ5tDjnsyoKyqvRWl52C3QqJ0cMIzc1JqKgKA0iOI)alygg6kd2RkHiabV76wXFGfmddDLb7vLqcFg4qOk(sNtYL)3OYqv8Lk18PUKgjm3WPhAuwXFGfWbGdHQ4lDGiXGQwH5EKAUKBZ9yk40rOCM2hfFPeRZqcaCiufFPdejgu1k8KC5BWWOVkvHobCiufFPdejgu1k8KC5px006PxZRc)l52CFCGcrqHfq2Swyct7FvUwPUP4gP5XinqZ6K66(XbkKWNboeQIV0bIedQAfEsU8)G4Xb(xEj3MtTR2SoPq1Q3zAJCsXKbFmfC6iKWUU3QqJ0c6mEYhJlWhI0GuJgbQD1M1jf6mEYhJlWh(yk40riHVdCiufFPdejgu1k8KC5Rw9otBKtkMSl52CeHZGufctyA)RY1k1nf3inpgPbMchVVR7nYM1ctyA)RY1k1nf3inpgPb26DDv7QnRtkmHP9VkxRu3uCJ08yKg4JPGtNUj88DGdHQ4lDGiXGQwHNKlFNXt(yCb(xYT5icNbPkeMW0(xLRvQBkUrAEmsdmfoEFx3BKnRfMW0(xLRvQBkUrAEmsdS176Q2vBwNuyct7FvUwPUP4gP5XinWhtbNoDt457ahcvXx6arIbvTcpjx(P9RqlN65xGxYT5mBbni2lDUnQzGpMcoDekNP9rXxkX6mKacUn9OwlR4pWAGoZ4V2jNAYrORlrtpQ1Yk(dSgOZm(RDYPMUjuarvOrAbvAmiocrAqQrZDGdHQ4lDGiXGQwHNKlFLgdIJxYT5Un9OwlR4pWAGoZ4V2jNA6wybMTGge7Lo3g1mWhtbNocLZ0(O4lLyDgsG7UU3MEuRLv8hynqNz8x7KtnDtG7ahcvXx6arIbvTcpjx(K6WGtTF6sUnhrKnRfMW0(xLRvQBkUrAEmsdS1lGSzTWcNsUwzIFKvWwVGpoqHiWzber2SwObdJ(Quf6eS1dCiufFPdejgu1k8KC5JedQAfEj3MJSzTWeM2)QCTsDtXnsZJrAGTExxYM1cnyy0xLQqNGTExxds2SwOA17mTroPyYGTExxYM1clCk5ALj(rwbB9ahcvXx6arIbvTcpjx(JosxYT5iBwlu9TjJtpKXmrtxWwVaYM1ctyA)RY1k1nf3inpgPbAwNuGdHQ4lDGiXGQwHNKl)hPMl52CpMcoDekNP9rXxkX6mKacQ4pWcw8ekRvA4y3NoWHqv8LoqKyqvRWtYL)sC87xN4dCiufFPdejgu1k8KC5RwQbtuGdHQ4lDGiXGQwHNKlFKyqvRqGdHQ4lDGiXGQwHNKlFIZv1(xLFBYaoeQIV0bIedQAfEsU85PEKA40djX5QA)RahaoeQIV0boC6HgLv8hyL7rQ5sUn3JPGthHYzAFu8LsSodjaWHqv8LoWHtp0OSI)aRtYLVbdJ(Quf6eWHqv8LoWHtp0OSI)aRtYL)CrtRNEnVk8VKBZ9Xbk0PEwazZAHgmm6RsvOtqZ6KkGSzTWeM2)QCTsDtXnsZJrAGM1j119JduiHpdCiufFPdC40dnkR4pW6KC5)bXJd8VKBZDtTR2SoPq1Q3zAJCsXKbFmfC6iKWUU3QqJ0c6mEYhJlWhI0GuJgbQD1M1jf6mEYhJlWh(yk40riHVFh4qOk(sh4WPhAuwXFG1j5YpTFfA5up)c8sUnNzlObXEPZTrnd8XuWPJq5mTpk(sjwNHeqWTPh1Azf)bwd0zg)1o5utocDDjQcnslOsJbXrisdsnAUdCiufFPdC40dnkR4pW6KC5R0yqC8sUn30JATSI)aRb6mJ)ANCQPBHfy2cAqSx6CBuZaFmfC6iuot7JIVuI1zibaoeQIV0boC6HgLv8hyDsU8vRENPnYjft2LCBoIWzqQcHQLAq6GgPMBr7(keI0GuJgbevHgPfmfZeQhHini1OrWTk(dSGfpHYAL9Qsk85Uj8SRRLFKvYhtbNoDtWZ3DDXzqQcHQLAq6GgPMBr7(keI0GuJgbevHgPfmfZeQhHini1OrWTk(dSGfpHYAL9Qsk85Uj8SRRLFKvYhtbNoDFkNV76wHgPfmfZeQhHini1OrWTk(dSGfpHYAL9Qssac2nHNDDT8JSs(yk40PBcE(oWHqv8LoWHtp0OSI)aRtYLVZ4jFmUa)l52CeHZGufcvl1G0bnsn3I29viePbPgnciQcnslykMjupcrAqQrJGBv8hyblEcL1k7vLu4ZDt4zxxl)iRKpMcoD6MGNV76IZGufcvl1G0bnsn3I29viePbPgnciQcnslykMjupcrAqQrJGBv8hyblEcL1k7vLu4ZDt4zxxl)iRKpMcoD6(uoF31TcnslykMjupcrAqQrJGBv8hyblEcL1k7vLKaeSBcp76A5hzL8XuWPt3e88DGdHQ4lDGdNEOrzf)bwNKlFKyqvRWl52CKnRfonJbPsdgvg8XqvahcvXx6aho9qJYk(dSojx(K6WGtTF6sUnNAxTzDsHP9RqlN65xGWhtbNocmizZAHQvVZ0g5KIjdAwNub3iQcnslObdJ(Quf6eePbPgnUUKnRfAWWOVkvHobnRt6Db3UzqYM1cvRENPnYjftgS1lGOOJ4Zlew4uY1kt8JScI0GuJM7UUKnRfw4uY1kt8JSc26VlGSzTWeM2)QCTsDtXnsZJrAGM1jvWhhOqD4zGdHQ4lDGdNEOrzf)bwNKl)0(vOLt98lWl52CtpQ1Yk(dSgOZm(RDYPMCe66sufAKwqLgdIJqKgKA0aCiufFPdC40dnkR4pW6KC5R0yqC8sUn30JATSI)aRb6mJ)ANCQPBHboeQIV0boC6HgLv8hyDsU8DMXFTto1Cj3M72TBKnRfMW0(xLRvQBkUrAEmsdS1F319MbjBwluT6DM2iNumzWw)Dx3BKnRfAWWOVkvHobB93VlOcnslOfFIVVCTsYOkncrAqQrZDx3B3iBwlmHP9VkxRu3uCJ08yKgyR319JdS7tXrExGbjBwluT6DM2iNumzWwVaYM1clCk5ALj(rwbnRtQaIQqJ0cAXN47lxRKmQsJqKgKA0Ch4qOk(sh4WPhAuwXFG1j5YF0r6sUnhrvOrAbT4t89LRvsgvPrisdsnAeCJSzTWeM2)QCTsDtXnsZJrAGTExxds2SwOA17mTroPyYGT(7ahcvXx6aho9qJYk(dSojx(lXXVFDIpWHqv8LoWHtp0OSI)aRtYLVZm(RDYPMl52CvOrAbT4t89LRvsgvPrisdsnAeCJSzTWcNsUwzIFKvWwVRRbjBwluT6DM2iNumzqZ6KkGSzTWcNsUwzIFKvqZ6Kk4JdS7t98DGdHQ4lDGdNEOrzf)bwNKl)rhPl52CevHgPf0IpX3xUwjzuLgHini1Ob4qOk(sh4WPhAuwXFG1j5YN4CvT)v53MmGdHQ4lDGdNEOrzf)bwNKlFEQhPgo9qsCUQ2)QV8L3da]] )


end
