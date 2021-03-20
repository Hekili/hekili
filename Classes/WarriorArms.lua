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


    spec:RegisterHook( "TimeToReady", function( wait, action )
        local id = class.abilities[ action ].id
        if buff.bladestorm.up and ( id < -99 or id > 0 ) then
            wait = max( wait, buff.bladestorm.remains )
        end
        return wait
    end )


    local cs_actual

    spec:RegisterHook( "reset_precast", function ()
        rage_spent = nil

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

            usable = function () return target.distance > 10 and ( query_time - action.charge.lastCast > gcd.execute ) end,
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
                },
                -- Legendary
                exploiter = {
                    id = 335452,
                    duration = 30,
                    max_stack = 2,
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
            gcd = "off",

            startsCombat = false,
            texture = 236171,

            usable = function () return query_time - action.heroic_leap.lastCast > gcd.execute * 2 end,
            handler = function ()
                setDistance( 15 )
                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
            end,
            
            copy = 52174
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

            rangeSpell = function () return class.abilities.execute and class.abilities.execute.id end,

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


    spec:RegisterPack( "Arms", 20210314, [[dKeATaqivk0JeuztesFsQsgLkvDkcHvPsO6vsvnlcLBriQDjPFjrnmKshtcwMkONrOY0uPKRPs02KQuFJqvnovcohHiwNkfzEck3tQSpvQCqvk1cLipKqv6IQuGpQsi6KQuuRevmtbvLBQsiStj0qjuflvLq5Pcnvb5QcQQARQesFvLcASeI0Ef9xu1GLYHjTycEmIjtPldTzk8zbgTk60QA1cQQ8AKIzt0TPODR43Ggos1XfuLLd8CLMovxhjBxL03rLgVufNxfy(Qq7hLZczOmAvhZIhs7HfOvCfUv9qAVuC36Wm6hqhZiDLqJgGzCutmJ3gyUzKUEGeQ2mugxifGGz80D67nvUCW7Nucvc0S8(Mus1F4qaQHxEFts5mkq9s)MNuiJw1XS4H0EybAfxHBvpK2lfN4Uqgvk)ecYy8nPKQ)Wr8cudpJNV1ItkKrlUKmEBG5YA3qfaEiGX5IqbKtwRWTeJ1oK2dlW4W4iEp1ja3BIXrKzTBBTOL1epuMMOSY4iYS2TTw0YAx0N4qWbS2fJAplFZM0XX(taRDrFIdbhuzCezw72wlAzTsQ7sK1INqkN1CiRrhGeOPG6S2TfpHVkJJiZA3GEqcL)Wbb9AznXdaj)(WH1(L1SOeD0wzCezw72wlAzTW)fzTB2rZTY4iYSwiUOsdRHJdoG1mGawRKuT46qGznJYF9ndLX9NajY7kia9muwSqgkJ4Ocs0MLYib8ocEnJ3ZAgFWPZdqt9NL1UJ1kCbAzTJhzT7znxbbOxprv6Nv6eN1cJ1oKww74rwZvjoE1u3vjaSIJkirlRjkR5kia96jQs)SsN4SwySM4UK1ebRjImQe)HtgjWj8OqaeS8c6mii9S4HzOmIJkirBwkJeW7i41mcqt9NL1cRJ1Sua1F4WAxCwJ2Q4YOs8hozeGJn9SO4YqzehvqI2SugjG3rWRzKaHslK7ujqjCxQLFn19Scqt9NL1cJ1UaRjkRfqSvaAQ)SSwhRrBgvI)WjJ6v1vq6zXBLHYioQGeTzPmsaVJGxZ4shLsExbbOVvUNpqY9hlRDhRvG1eL1SqVArKopxi1y3kan1FwwlmwlGyZOs8hozKir9kMEw8YmugvI)WjJa9QgGGmIJkirBwk9SyVZqzuj(dNmYvbcauPbbzehvqI2Su6zrXpdLrL4pCYibkH7sT8RPUNzehvqI2Su6zXlKHYOs8hozuhYJJZRgoc2tiHMmIJkirBwk9SOijdLrL4pCY4shvap0Gxqx)HtgXrfKOnlLEwSaTzOmIJkirBwkJeW7i41msovqaUSwhRDygvI)WjJWRiGoKlcsplwOqgkJ4Ocs0MLYib8ocEnJaQbnGGaSIJLc8taVGeYTIJkirlRD8iRjqzyuHxraDixeuxxj0WA31XAhYAhpYA3ZAwOxTisNNlKASBfGM6plRfwhRfqSSMOSgbcLwi3PsGs4Uul)AQ7zfGM6plRDhRfqSSMiYOs8hoz0ecCvYVo4Pbtplw4WmugXrfKOnlLrc4De8AgfOmmQwuTYd4jQ0SAHChwtuw7EwZIcuggvcuc3LA5xtDpRu0znrznGgGSwySM4OL1oEK1aAaYAHXAxslRjImQe)HtgfKQfxhcmtplwqCzOmQe)HtgTOALhWtuPzgXrfKOnlLEwSWTYqzehvqI2SugjG3rWRzeObiRfgR1BAznrznbkdJQfvR8aEIknRwi3jJkXF4KXLgkPCPlF3rq6zXcxMHYOs8hozeEfb0HCrqgXrfKOnlLEwSqVZqzehvqI2SugjG3rWRzuGYWOUuwlo8wu9ZkavINrL4pCYibow0Csplwq8ZqzehvqI2SugjG3rWRzuGYWOUuwlo8wu9ZkavINrL4pCYi2dsOCm9SyHlKHYOs8hoz0ecCvYVo4PbZioQGeTzP0ZIfejzOmIJkirBwkJeW7i41m6QehVAGGRqap0GxqDxIvCubjAZOs8hozK75dKC)XMEw8qAZqzehvqI2SugjG3rWRz8gznxL44vdeCfc4Hg8cQ7sSIJkirlRjkRDpRb0aK1UJ1UKww74rwdqnObeeG19dg05Hg8oeyIJJwEA(jyR4Ocs0YAIiJkXF4KXvQMPNEgTOHsj9muwSqgkJkXF4KrYPccWmIJkirBwk9S4HzOmQe)HtgPtzAIYmIJkirBwk9SO4Yqzuj(dNmsh6pCYioQGeTzP0ZI3kdLrCubjAZszKaEhbVMrlkqzyujqjCxQLFn19SsrpJkXF4KrbjeA5nOahKEw8YmugXrfKOnlLrc4De8AgTOaLHrLaLWDPw(1u3Zkan1Fww7owR3zuj(dNmkGGfb08tq6zXENHYioQGeTzPmsaVJGxZibcLwi3PAcbUk5xh80GvaAQ)SS2DSwH6LSMOSgqdqwlmw7sAZOs8hozubeDqEhca44PNff)mugXrfKOnlLrc4De8AgTOaLHrLaLWDPw(1u3ZQfYDynrzncekTqUt1ecCvYVo4PbRa0u)zZOs8hozu(bN(Yh(rzdmXXtplEHmugXrfKOnlLrc4De8AgTOaLHrLaLWDPw(1u3Zkf9mQe)HtgnEakiHqB6zrrsgkJ4Ocs0MLYib8ocEnJwuGYWOsGs4Uul)AQ7zLIEgvI)WjJ6qW1bQKNOsz6zXc0MHYioQGeTzPmsaVJGxZOffOmmQeOeUl1YVM6EwTqUdRjkRrGqPfYDQMqGRs(1bpnyfGM6pBgvI)WjJcAap0G3bpHMn9SyHczOmIJkirBwkJJAIz8NLaOCvqI8HhLooLjVfV(emJkXF4KXFwcGYvbjYhEu64uM8w86tW0ZIfomdLrCubjAZszCutmJwaQwJhG8xXDrzgvI)WjJwaQwJhG8xXDrz6zXcIldLrL4pCYi1I8VJMBgXrfKOnlLEwSWTYqzehvqI2SugjG3rWRzCPJsjVRGa03k3Zhi5(JL1UJ1kWAIYA3ZAeiuAHCNQGuT46qGzfGM6plRDhRv4sw74rwZvjoEfOx1aeuXrfKOL1ergvI)WjJlxeP)ta)6GNgCtplw4YmugXrfKOnlLrc4De8AgVN1CvIJxn1DvcaR4Ocs0YAIYAUccqVEIQ0pR0joRfgRjUlznrWAhpYAUccqVEIQ0pR0joRfgRDiTS2XJS29SMRGa0RNOk9ZkDIZA3XAxGwwtuwJaVIJoE9ko(5bawtezCDWt8SyHmQe)HtgjQuYRe)HdV8xpJYFD(rnXmI9GekhtplwO3zOmIJkirBwkJeW7i41mU0rPK3vqa6BL75dKC)XYA3XAfY46GN4zXczuj(dNmsuPKxj(dhE5VEgL)68JAIz8ujPNfli(zOmIJkirBwkJkXF4KrIkL8kXF4Wl)1ZO8xNFutmJ7pbsK3vqa6PNflCHmugvI)WjJxFIdbhWdO2ZmIJkirBwk9SybrsgkJkXF4KX3Koo2Fc4V(ehcoiJ4Ocs0MLsp9mshGeOPG6zOSyHmugvI)WjJcQ7sKFpHuEgXrfKOnlLE6ze7bjuoMHYIfYqzuj(dNmAr1kpGNOsZmIJkirBwk9S4HzOmIJkirBwkJeW7i41mU0rPK3vqa6BL75dKC)XYADSwbwtuwlGyRa0u)zzTowJwwtuw7EwdObiRDhRj(xYAhpYAanazT7yTlPL1eL1eOmmQaKqJe3DWDRu0znrKrL4pCYirhck5fOmmYOaLHb)OMygfKQfxhcmtplkUmugXrfKOnlLrc4De8AgjqO0c5ovcuc3LA5xtDpRa0u)zzTWyTlWAIYAbeBfGM6plR1XA0MrL4pCYOEvDfKEw8wzOmIJkirBwkJeW7i41mc0aK1cJ16nTSMOS29S2nYAUkXXRwuTYd4jQ0SIJkirlRD8iRjqzyuTOALhWtuPz1c5oSMiYOs8hozCPHskx6Y3DeKEw8YmugvI)WjJa9QgGGmIJkirBwk9SyVZqzuj(dNmsGt4rHaiy5f0zqqgXrfKOnlLEwu8ZqzehvqI2SugjG3rWRzCPJsjVRGa03k3Zhi5(JL1UJ1kWAIYAwOxTisNNlKASBfGM6plRfgRfqSzuj(dNmsKOEftplEHmugvI)WjJCvGaavAqqgXrfKOnlLEwuKKHYOs8hozKaLWDPw(1u3ZmIJkirBwk9SybAZqzehvqI2SugjG3rWRz0Icuggvcuc3LA5xtDpRu0zTJhznbkdJ6szT4WBr1pRaujoRD8iRb0aK1UJ169Lzuj(dNmsGJfnN0ZIfkKHYioQGeTzPmsaVJGxZi5ubb4YADS2Hzuj(dNmcVIa6qUii9SyHdZqzuj(dNmQd5XX5vdhb7jKqtgXrfKOnlLEwSG4Yqzuj(dNmU0rfWdn4f01F4KrCubjAZsPNflCRmugXrfKOnlLrc4De8AgbudAabbyfhlf4NaEbjKBfhvqIww74rwZc9Qfr68CHuJDRa0u)zzTW6yTaIL1oEK1UN1UN1SOaLHrf7HUe(ocQRReAyTow7qw74rwtGYWOkOUlrjeyRu0znrWAIYA3iRrGxXrhVEfh)8aaRjImQe)HtgnHaxL8RdEAW0ZIfUmdLrCubjAZszKaEhbVMrbkdJQfvR8aEIknRwi3H1eL1aAaYAHXAxsBgvI)WjJcs1IRdbMPNfl07mugXrfKOnlLrc4De8AgbAaYAHXA3I2mQe)HtgxAOKYLU8DhbPNfli(zOmQe)HtgHxraDixeKrCubjAZsPNflCHmugvI)WjJe4yrZjJ4Ocs0MLsplwqKKHYOs8hoze7bjuoMrCubjAZsPNEgpvsgklwidLrCubjAZszKaEhbVMrGgGSwySwVPL1eL1eOmmQwuTYd4jQ0SAHCNmQe)HtgxAOKYLU8DhbPNfpmdLrL4pCYiboHhfcGGLxqNbbzehvqI2Su6zrXLHYioQGeTzPmsaVJGxZibcLwi3PsGs4Uul)AQ7zfGM6plRfgRviJkXF4Kr9Q6ki9S4TYqzuj(dNmYvbcauPbbzehvqI2Su6zXlZqzuj(dNmsGs4Uul)AQ7zgXrfKOnlLEwS3zOmIJkirBwkJeW7i41mAHE1IiDEUqQXUvaAQ)SSwyDSwaXMrL4pCYirI6vm9SO4NHYOs8hozuhYJJZRgoc2tiHMmIJkirBwk9S4fYqzuj(dNmU0rfWdn4f01F4KrCubjAZsPNffjzOmQe)HtgfKQfxhcmZioQGeTzP0ZIfOndLrL4pCYiqVQbiiJ4Ocs0MLsplwOqgkJ4Ocs0MLYib8ocEnJa0u)zzTW6ynlfq9hoS2fN1OTkowtuwtGYWOUCrK(pb8RdEAWTsrpJkXF4Krao20ZIfomdLrL4pCYirI6vmJ4Ocs0MLsplwqCzOmIJkirBwkJeW7i41mkqzyuxUis)Na(1bpn4wPOZAhpYAwOxTisNNlKASBfGM6plRfgRfqSSMOS2nYAUkXXRejQxXkoQGeTzuj(dNmAcbUk5xh80GPNflCRmugXrfKOnlLrc4De8AgDvIJxTauTJsfC6vCubjAZOs8hozeEfb0HCrq6zXcxMHYOs8hozKahlAozehvqI2Su6zXc9odLrCubjAZszKaEhbVMrbkdJ6Yfr6)eWVo4Pb3kf9mQe)HtgXEqcLJPNfli(zOmQe)HtgHxraDixeKrCubjAZsPNflCHmugvI)WjJCpFGK7p2mIJkirBwk90tpJxrW(WjlEiThwGwXvG2mYvbZpbBgVH3(Iv8MlErEtSgRf6ezT3Koe4SMbeWA9A)jqI8UccqVxSgadpQhGwwBHMiRPuo0uD0YAKtDcWTY4e((bzTcfUjwt8cNRiWrlR1la1GgqqawfP9I1CiR1la1GgqqawfPvCubjA7fRDFHEerLXj89dYAhs7nXAIx4CfboAzTEbOg0accWQiTxSMdzTEbOg0accWQiTIJkirBVyT7l0JiQmomo3WBFXkEZfViVjwJ1cDIS2BshcCwZacyTEH9Gekh7fRbWWJ6bOL1wOjYAkLdnvhTSg5uNaCRmoHVFqwRWTUjwt8cNRiWrlR1la1GgqqawfP9I1CiR1la1GgqqawfPvCubjA7fRDFHEerLXHX5MnPdboAzTlznL4pCyn5V(wzCYiDa04Lygdx4yTBdmxw7gQaWdbmoHlCS2fHciNSwHBjgRDiThwGXHXjCHJ1eVN6eG7nX4eUWXAImRDBRfTSM4HY0eLvgNWfowtKzTBBTOL1UOpXHGdyTlg1Ew(MnPJJ9Naw7I(ehcoOY4eUWXAImRDBRfTSwj1DjYAXtiLZAoK1Odqc0uqDw72INWxLXjCHJ1ezw7g0dsO8hoiOxlRjEai53hoS2VSMfLOJ2kJt4chRjYS2TTw0YAH)lYA3SJMBLXjCHJ1ezwlexuPH1WXbhWAgqaRvsQwCDiWSY4W4eUWXA3GEqcLJwwtanGaK1iqtb1znbm4NTYA3Mqq6(YAdCe5tfyAqjznL4pCwwdoYdQmokXF4Sv6aKanfuVFxzb1DjYVNqkNXHXjCHJ1Ub9GekhTSgEfbhWA(BISMFISMsCiG1(L10R6lvbjwzCuI)Wz7iNkiazCuI)Wz73vMoLPjkzCuI)Wz73vMo0F4W4Oe)HZ2VRSGecT8guGde7n6SOaLHrLaLWDPw(1u3ZkfDghL4pC2(DLfqWIaA(jqS3OZIcuggvcuc3LA5xtDpRa0u)zVR3mokXF4S97kRaIoiVdbaCCXEJocekTqUt1ecCvYVo4PbRa0u)zVRq9srbAag2L0Y4Oe)HZ2VRS8do9Lp8JYgyIJl2B0zrbkdJkbkH7sT8RPUNvlK7ikbcLwi3PAcbUk5xh80GvaAQ)SmokXF4S97kB8auqcHwXEJolkqzyujqjCxQLFn19SsrNXrj(dNTFxzDi46avYtuPuS3OZIcuggvcuc3LA5xtDpRu0zCuI)Wz73vwqd4Hg8o4j0SI9gDwuGYWOsGs4Uul)AQ7z1c5oIsGqPfYDQMqGRs(1bpnyfGM6plJJs8hoB)UYulY)oAk2OMy3plbq5QGe5dpkDCktElE9jiJJs8hoB)UYulY)oAk2OMyNfGQ14bi)vCxuY4Oe)HZ2VRm1I8VJMlJJs8hoB)UYlxeP)ta)6GNgCf7n6w6OuY7kia9TY98bsU)yVRGO3tGqPfYDQcs1IRdbMvaAQ)S3v4YJhDvIJxb6vnabvCubjAfbJJs8hoB)UYevk5vI)WHx(Rl2OMyh2dsOCuS1bpX7ki2B0DVRsC8QPURsayfhvqIwrDfeGE9evPFwPt8We3LI44rxbbOxprv6Nv6epSdP94X7DfeGE9evPFwPt87UaTIsGxXrhVEfh)8aGiyCuI)Wz73vMOsjVs8ho8YFDXg1e7ovIyRdEI3vqS3OBPJsjVRGa03k3Zhi5(J9UcmokXF4S97ktuPKxj(dhE5VUyJAID7pbsK3vqa6mokXF4S97kF9joeCapGApzCuI)Wz73v(nPJJ9Na(RpXHGdyCyCuI)WzRypiHYXolQw5b8evAY4Oe)HZwXEqcLJ97kt0HGsEbkddXg1e7eKQfxhcmf7n6w6OuY7kia9TY98bsU)y7kiAaXwbOP(Z2rRO3d0a8oX)YJhbAaE3L0kQaLHrfGeAK4UdUBLIUiyCuI)WzRypiHYX(DL1RQRaXEJocekTqUtLaLWDPw(1u3Zkan1F2WUGObeBfGM6pBhTmokXF4SvShKq5y)UYlnus5sx(UJaXEJoGgGH1BAf9(B0vjoE1IQvEaprLMvCubjApEuGYWOAr1kpGNOsZQfYDebJJs8hoBf7bjuo2VRmqVQbiGXrj(dNTI9Gekh73vMaNWJcbqWYlOZGaghL4pC2k2dsOCSFxzIe1ROyVr3shLsExbbOVvUNpqY9h7Dfe1c9Qfr68CHuJDRa0u)zdlGyzCuI)WzRypiHYX(DL5QabaQ0GaghL4pC2k2dsOCSFxzcuc3LA5xtDpzCuI)WzRypiHYX(DLjWXIMJyVrNffOmmQeOeUl1YVM6EwPOF8OaLHrDPSwC4TO6NvaQe)4rGgG317lzCuI)WzRypiHYX(DLHxraDixei2B0rovqaUDhY4Oe)HZwXEqcLJ97kRd5XX5vdhb7jKqdJJs8hoBf7bjuo2VR8shvap0Gxqx)HdJJs8hoBf7bjuo2VRSje4QKFDWtdk2B0bOg0accWkowkWpb8csi3JhTqVArKopxi1y3kan1F2W6ci2JhV)ElkqzyuXEOlHVJG66kHMUdpEuGYWOkOUlrjeyRu0fHO3ibEfhD86vC8ZdaIGXrj(dNTI9Gekh73vwqQwCDiWuS3OtGYWOAr1kpGNOsZQfYDefObyyxslJJs8hoBf7bjuo2VR8sdLuU0LV7iqS3OdObyy3IwghL4pC2k2dsOCSFxz4veqhYfbmokXF4SvShKq5y)UYe4yrZHXrj(dNTI9Gekh73vg7bjuoY4W4Oe)HZwpvs3sdLuU0LV7iqS3OdObyy9MwrfOmmQwuTYd4jQ0SAHChghL4pC26Ps63vMaNWJcbqWYlOZGaghL4pC26Ps63vwVQUce7n6iqO0c5ovcuc3LA5xtDpRa0u)zdRaJJs8hoB9uj97kZvbcauPbbmokXF4S1tL0VRmbkH7sT8RPUNmokXF4S1tL0VRmrI6vuS3OZc9Qfr68CHuJDRa0u)zdRlGyzCuI)WzRNkPFxzDipooVA4iypHeAyCuI)WzRNkPFx5LoQaEObVGU(dhghL4pC26Ps63vwqQwCDiWKXrj(dNTEQK(DLb6vnabmokXF4S1tL0VRmahRyVrhan1F2W6Sua1F4CXPTkorfOmmQlxeP)ta)6GNgCRu0zCuI)WzRNkPFxzIe1RiJJs8hoB9uj97kBcbUk5xh80GI9gDcugg1LlI0)jGFDWtdUvk6hpAHE1IiDEUqQXUvaAQ)SHfqSIEJUkXXRejQxXkoQGeTmokXF4S1tL0VRm8kcOd5IaXEJoxL44vlav7OubNEfhvqIwghL4pC26Ps63vMahlAomokXF4S1tL0VRm2dsOCuS3OtGYWOUCrK(pb8RdEAWTsrNXrj(dNTEQK(DLHxraDixeW4Oe)HZwpvs)UYCpFGK7pwghghL4pC26(tGe5DfeGEhboHhfcGGLxqNbbI9gD3B8bNopan1F27kCbApE8ExbbOxprv6Nv6epSdP94rxL44vtDxLaWkoQGeTI6kia96jQs)SsN4HjUlfHiyCuI)WzR7pbsK3vqa6DaCSI9gDa0u)zdRZsbu)HZfN2Q4yCuI)WzR7pbsK3vqa697kRxvxbI9gDeiuAHCNkbkH7sT8RPUNvaAQ)SHDbrdi2kan1F2oAzCuI)WzR7pbsK3vqa697ktKOEff7n6w6OuY7kia9TY98bsU)yVRGOwOxTisNNlKASBfGM6pBybelJJs8hoBD)jqI8UccqVFxzGEvdqaJJs8hoBD)jqI8UccqVFxzUkqaGkniGXrj(dNTU)eirExbbO3VRmbkH7sT8RPUNmokXF4S19NajY7kia9(DL1H8448QHJG9esOHXrj(dNTU)eirExbbO3VR8shvap0Gxqx)HdJJs8hoBD)jqI8UccqVFxz4veqhYfbI9gDKtfeGB3HmokXF4S19NajY7kia9(DLnHaxL8RdEAqXEJoa1GgqqawXXsb(jGxqc5E8OaLHrfEfb0HCrqDDLqZDDhE849wOxTisNNlKASBfGM6pByDbeROeiuAHCNkbkH7sT8RPUNvaAQ)S3fqSIGXrj(dNTU)eirExbbO3VRSGuT46qGPyVrNaLHr1IQvEaprLMvlK7i69wuGYWOsGs4Uul)AQ7zLIUOanadtC0E8iqdWWUKwrW4Oe)HZw3FcKiVRGa073v2IQvEaprLMmokXF4S19NajY7kia9(DLxAOKYLU8DhbI9gDanadR30kQaLHr1IQvEaprLMvlK7W4Oe)HZw3FcKiVRGa073vgEfb0HCraJJs8hoBD)jqI8UccqVFxzcCSO5i2B0jqzyuxkRfhElQ(zfGkXzCuI)WzR7pbsK3vqa697kJ9Gekhf7n6eOmmQlL1IdVfv)ScqL4mokXF4S19NajY7kia9(DLnHaxL8RdEAqghL4pC26(tGe5DfeGE)UYCpFGK7pwXEJoxL44vdeCfc4Hg8cQ7sSIJkirlJJs8hoBD)jqI8UccqVFx5vQMI9gD3ORsC8QbcUcb8qdEb1DjwXrfKOv07bAaE3L0E8iGAqdiiaR7hmOZdn4DiWehhT808tWkImU0rswu8lKE6zc]] )


end
