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

    spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
        if powerType == "RAGE" then
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

        potion = "potion_of_phantom_fire",

        package = "Arms",
    } )


    spec:RegisterPack( "Arms", 20201208, [[dKufVaqijI8ijsTjufFsieJcjWPufvRsiKELe1Sqv1TecSlj9ljyyirhtcTmHKNjezAOO4AOOABsK8nHqnoHOoNebRtvuyEOkDpP0(qcDqKGwOq1drrPmrvrPCrvrrFuvuQojkkzLiPzkri2PqzOcb1srrP6PcMkv0vfcITQkk5RcbP9k6VQQblvhMyXO0JrmzsDzOntL(SumAvPtR0QLiKEnQkZMQUnQSBf)wLHJchxIOwoONdmDkxhP2UQW3PcJxvKZlKA9seQ5JISFsolMoZGwmmJffLrrzXOOmY1ILaZlgPsidw0mWmWqi8jnyggHdZafc5azGHeT)eD6mdGJgsWm8AgdWZOqHM1EPzRKJRay5O9IT3qGIRvaSCKczGLE9gZAs2mOfdZyrrzuuwmkkJCTyjW8IrQeYGqBVhmdHLJ2l2EdZguCTm8UAnojBg0iGKHsR6uiKdO6rOceUhurT0Q(ZgsqoweQ6rMFvpkkJIsfvf1sR6mBVY0GGNHIAPv9iq1PqTg1QEeMMJd9vf1sR6rGQtHAnQv9N1sSdgTQZStdElWS4yGJENgv)zTe7GrxvulTQhbQofQ1Ow1JlM5rvp8E0MQBNQZaIKJJvmvNcJWLivf1sR6rGQ)mFcj02EdcJiavpcdrYc2Bu9fO6A0JgQRkQLw1JavNc1AuR6riau1zwgYbQkQLw1Jav3Pdu4t1XXGrR6Uhu1J7fncSdYvZGFbgiDMbWonE8BcSbT0zgRy6md4iSEuNXZabUgcxjduGQ7UnV2hICYoavNIQEXitPQZetQofO6MaBqR(II3ERmiMQZRQhfLQotmP6M4XXQCcaieiwXry9Ow15r1nb2Gw9ffV9wzqmvNxvpsmx1FUQ)8mieBVjdKBkzAeEqWNvMbHPLXIkDMbCewpQZ4zGaxdHRKbYDE95yQKZFaan4d4eWBfICYoavNxvpYQopQEdrxHiNSdq1BvDkZGqS9MmipetGPLXIu6md4iSEuNXZabUgcxjdqKt2bO682Q6AAOy7nQEev1PSgPmieBVjdqC0PLXyM0zgWry9OoJNbcCneUsgamqV)BcSbnq1X7c9o2rR6uu1lQ68O66ZQAez8DC0JguHiNSdq15v1Bi6mieBVjdepkpW0YympDMbHy7nzWHazHOWhcZaocRh1z80YyLkDMbHy7nzGC(daObFaNaEZaocRh1z80YyrC6md4iSEuNXZabUgcxjdS0UUv5HycScrozhGQZRQxmYQopQEjP66ZQq5H0GWke5KDazqi2EtgGYdPbHPLXIC6mdcX2BYGmKfh7lUgcbVhHVmGJW6rDgpTmwjKoZGqS9MmayGc8FUFwby7nzahH1J6mEAzSIuMoZaocRh1z8mqGRHWvYa5vGniq1Bv9OYGqS9MmCpqiJZbctlJvSy6md4iSEuNXZabUgcxjdS0UUvnkAF0FI45Q6ZXO68O6uGQRrwAx3k58haqd(aob8wPzO68O6qPbvDEv9irPQZetQouAqvNxvpIPu1FEgeIT3KbwVOrGDqU0YyfJkDMbCewpQZ4zGaxdHRKbwAx369aHmohiScmHWNQtXwvpkvNhvNL21TQrr7J(tepxvFogvNjMuDkq11Nv1iY474OhnOcrozhGQZBRQ3q0QopQo5oV(CmvY5paGg8bCc4TcrozhGQtrvVHOv9NNbHy7nzG7GM4)adU8HPLXkgP0zgeIT3KbnkAF0FI45YaocRh1z80YyfzM0zgWry9OoJNbcCneUsgGsdQ68Q6LIsvNhvNL21TQrr7J(tepxvFoMmieBVjda(O9Ead)AgctlJvK5PZmieBVjd3deY4CGWmGJW6rDgpTmwXsLoZaocRh1z8mqGRHWvYalTRBfqR1481OyVvikeldcX2BYa5gnYnPLXkgXPZmGJW6rDgpde4AiCLmWs76wb0AnoFnk2BfIcXYGqS9MmGpHeAdtlJvmYPZmieBVjdCh0e)hyWLpmd4iSEuNXtlJvSesNzahH1J6mEgiW1q4kzWepow1fHpo4)C)SIzESIJW6rTQZJQdLgu1POQxkkZGqS9Mm44DHEh7OtlJffLPZmieBVjdaVWLbCewpQZ4PLXIQy6mdcX2BYWJLyhm6pKg8MbCewpQZ4PLXIkQ0zgeIT3KHLJbo6DA(pwIDWOZaocRh1z80sldA0vO9w6mJvmDMbHy7nzG8kWgmd4iSEuNXtlJfv6mdcX2BYGqB3xmti8LbCewpQZ4PLXIu6mdcX2BYaJZ2BYaocRh1z80Yymt6md4iSEuNXZabUgcxjdAKL21Tso)ba0GpGtaVvAgzqi2Etgy93P)U0WOtlJX80zgWry9OoJNbcCneUsg0ilTRBLC(daObFaNaERqKt2bO6uu1lvgeIT3KbwecqiF70KwgRuPZmGJW6rDgpde4AiCLmqUZRphtL7GM4)adU8HviYj7auDkQ6fRmx15r1HsdQ68Q6mNYmieBVjdcKid(TdcXXslJfXPZmGJW6rDgpde4AiCLmOrwAx3k58haqd(aob8w1NJr15r1j351NJPYDqt8FGbx(Wke5KDazqi2Etg8BZRb(LO06goCS0YyroDMbCewpQZ4zGaxdHRKbnYs76wjN)aaAWhWjG3knJmieBVjdUlez93PtlJvcPZmGJW6rDgpde4AiCLmOrwAx3k58haqd(aob8wPzKbHy7nzqgccmO4)eX7tlJvKY0zgWry9OoJNbcCneUsg0ilTRBLC(daObFaNaER6ZXO68O6K786ZXu5oOj(pWGlFyfICYoGmieBVjdSsZ)C)gCj8bslJvSy6md4iSEuNXZWiCyg2bqG0MW6XFjtlJrZ914JLGzqi2Etg2bqG0MW6XFjtlJrZ914JLGPLXkgv6md4iSEuNXZWiCyg0qu0Ule)pqaa9zqi2Etg0qu0Ule)pqaa9PLXkgP0zgeIT3KbAa(xd5azahH1J6mEAzSImt6md4iSEuNXZabUgcxjdagO3)nb2GgO64DHEh7OvDkQ6fvDEuDYDE95yQSErJa7GCviYj7auDkQ6fJkdcX2BYaWbIm2P5dm4YhcslJvK5PZmGJW6rDgpde4AiCLmaLv)Xh4yvrRbv8PfyGmieBVjdq65leBV57xGLb)cS)iCygEfsAzSILkDMbCewpQZ4zGaxdHRKbkq1nXJJv5eaqiqSIJW6rTQZJQBcSbT6lkE7TYGyQoVQEKyUQ)CvNjMuDtGnOvFrXBVvget15v1JIsvNjMuDkq1nb2Gw9ffV9wzqmvNIQEKPu15r1j3dCKXQpWXEJgQ6ppdcX2BYaKE(cX2B((fyzWVa7pchMb8jKqByAzSIrC6md4iSEuNXZGqS9MmaPNVqS9MVFbwg8lW(JWHzaStJh)MaBqlT0YadisoowXsNzSIPZmieBVjdSIzE8dEpAld4iSEuNXtlJfv6md4iSEuNXZWiCygKsm4vGc47EJ9p3pJZbcZGqS9MmiLyWRafW39g7FUFgNdeMwglsPZmGJW6rDgpde4AiCLmyIhhR6IWhh8FUFwXmpwXry9Ow1zIjvVKuDt84yvxe(4G)Z9ZkM5XkocRh1QopQUTC43UVErvNIQErMtzgeIT3KboK7Gr)p3VNMS6VgIchiTmgZKoZaocRh1z8mqGRHWvYGjECSQlcFCW)5(zfZ8yfhH1JAvNjMuDt84yvobaeceR4iSEuR68O62YHF7(6fvDkQ6rvKsvNjMuDt84yvio6kocRh1QopQofO62YHF7(6fvDkQ6rvKsvNjMuDB5WVDF9IQoVQErMH5Q(ZZGqS9Mm0qlq9kZ)C)sjgHN9MwAzaFcj0gMoZyftNzqi2Etg0OO9r)jINld4iSEuNXtlJfv6md4iSEuNXZabUgcxjdqKt2bO682Q6AAOy7nQEev1PSgPmieBVjdqC0PLXIu6md4iSEuNXZabUgcxjdqPbvDEv9srPQZJQtbQEjP6M4XXQAu0(O)eXZvXry9Ow1zIjvNL21TQrr7J(tepxvFogv)5zqi2Etga8r79ag(1meMwgJzsNzahH1J6mEgiW1q4kzGCNxFoMk58haqd(aob8wHiNSdq15v1JSQZJQ3q0viYj7au9wvNYmieBVjdYdXeyAzmMNoZaocRh1z8mqGRHWvYalTRBvEiMaRqKt2bO68Q6fJSQZJQxsQU(SkuEiniScrozhqgeIT3KbO8qAqyAzSsLoZGqS9MmqUPKPr4bbFwzgeMbCewpQZ4PLXI40zgWry9OoJNbcCneUsgamqV)BcSbnq1X7c9o2rR6uu1lQ68O66ZQAez8DC0JguHiNSdq15v1Bi6mieBVjdepkpW0YyroDMbHy7nzWHazHOWhcZaocRh1z80YyLq6mdcX2BYa58haqd(aob8MbCewpQZ4PLXksz6md4iSEuNXZabUgcxjdAKL21Tso)ba0GpGtaVvAgQotmP6S0UUvaTwJZxJI9wHOqmvNjMuDO0GQofv9sX8mieBVjdKB0i3KwgRyX0zgWry9OoJNbcCneUsgiVcSbbQERQhvgeIT3KH7bczCoqyAzSIrLoZGqS9MmidzXX(IRHqW7r4ld4iSEuNXtlJvmsPZmieBVjdagOa)N7Nva2EtgWry9OoJNwgRiZKoZaocRh1z8mqGRHWvYalTRBvJI2h9NiEUQ(CmQopQouAqvNxvN5uMbHy7nzG1lAeyhKlTmwrMNoZaocRh1z8mqGRHWvYG(SQgrgFhh9ObviYj7auDEBv9gIodcX2BYa3bnX)bgC5dtlJvSuPZmGJW6rDgpde4AiCLmaLgu15v1zgkZGqS9Mma4J27bm8RzimTmwXioDMbHy7nz4EGqgNdeMbCewpQZ4PLXkg50zgeIT3KbYnAKBYaocRh1z80YyflH0zgeIT3Kb8jKqBygWry9OoJNwglkktNzqi2EtgESe7Gr)H0G3mGJW6rDgpTmwuftNzqi2Etgwog4O3P5)yj2bJod4iSEuNXtlTm8kK0zgRy6md4iSEuNXZabUgcxjdqPbvDEv9srPQZJQZs76w1OO9r)jINRQphtgeIT3KbaF0EpGHFndHPLXIkDMbHy7nzGCtjtJWdc(SYmimd4iSEuNXtlJfP0zgWry9OoJNbcCneUsgi351NJPso)ba0GpGtaVviYj7auDEv9Izqi2EtgKhIjW0Yymt6md4iSEuNXZabUgcxjd6ZQAez8DC0JguHiNSdq15Tv1Bi6mieBVjdepkpW0YympDMbHy7nzWHazHOWhcZaocRh1z80YyLkDMbHy7nzqgYIJ9fxdHG3JWxgWry9OoJNwglItNzqi2Etgamqb(p3pRaS9MmGJW6rDgpTmwKtNzqi2Etgy9Igb2b5YaocRh1z80YyLq6mdcX2BYauEinimd4iSEuNXtlJvKY0zgeIT3KbY5paGg8bCc4nd4iSEuNXtlJvSy6md4iSEuNXZabUgcxjdqKt2bO682Q6AAOy7nQEev1PSgjvNhvNL21TcCGiJDA(adU8HGknJmieBVjdqC0PLXkgv6mdcX2BYaXJYdmd4iSEuNXtlJvmsPZmGJW6rDgpde4AiCLmWs76wboqKXonFGbx(qqLMHQZetQU(SQgrgFhh9ObviYj7auDEv9gIw15r1ljv3epowL4r5bwXry9OodcX2BYa3bnX)bgC5dtlJvKzsNzahH1J6mEgiW1q4kzWepowvdrrpcDZRvXry9OodcX2BYW9aHmohimTmwrMNoZGqS9MmqUrJCtgWry9OoJNwgRyPsNzahH1J6mEgiW1q4kzGL21TcCGiJDA(adU8HGknJmieBVjd4tiH2W0YyfJ40zgeIT3KH7bczCoqygWry9OoJNwgRyKtNzqi2EtgC8UqVJD0zahH1J6mEAzSILq6mdcX2BYWJLyhm6pKg8MbCewpQZ4PLXIIY0zgeIT3KHLJbo6DA(pwIDWOZaocRh1z80slTm8aHG9MmwuugfLflgfZKbhcC2PbKHiukKzpgZk2Z(Zq1vDNVOQVCmoOP6Uhu1JiA0vO9wer1HyjtVquR6GJdvDH2ooXqTQtELPbbvf1sKDqvpQNHQhHmaAgmoOHAvxi2EJQhreA7(IzcHVisvrvrLzXX4GgQvDMR6cX2BuD)cmqvrndmGN76XmuAvNcHCavpcvGW9GkQLw1F2qcYXIqvpY8R6rrzuuQOQOwAvNz7vMge8muulTQhbQofQ1Ow1JW0CCOVQOwAvpcuDkuRrTQ)SwIDWOvDMDAWBbMfhdC070O6pRLyhm6QIAPv9iq1PqTg1QECXmpQ6H3J2uD7uDgqKCCSIP6uyeUePQOwAvpcu9N5tiH22BqyebO6ryiswWEJQVavxJE0qDvrT0QEeO6uOwJAvpcbGQoZYqoqvrT0QEeO6oDGcFQoogmAv39GQECVOrGDqUQIQIAPv9N5tiH2qTQZIUhevDYXXkMQZIn7aQQofsiiddO6ZnrWRa5CP9QUqS9gGQFJp6QIQqS9gqLbejhhRyLBlWkM5Xp49OnfvHy7nGkdisoowXk3wGgG)1qo(hHdBLsm4vGc47EJ9p3pJZbcvufIT3aQmGi54yfRCBboK7Gr)p3VNMS6VgIchG)1T1epow1fHpo4)C)SIzESIJW6rntmvsM4XXQUi8Xb)N7NvmZJvCewpQ5Xwo8B3xViflYCkvufIT3aQmGi54yfRCBHgAbQxz(N7xkXi8Sx(x3wt84yvxe(4G)Z9ZkM5XkocRh1mXKjECSkNaacbIvCewpQ5Xwo8B3xVifJQiLmXKjECSkehDfhH1JAEOaB5WVDF9IumQIuYet2YHF7(6f5TiZW8NROQOwAv)z(esOnuR64degTQBlhQ62lQ6cXoOQVavxEiRxy9yvrvi2EdOL8kWgurvi2EdOCBbH2UVyMq4trvi2EdOCBbgNT3OOkeBVbuUTaR)o93Lggn)RBRgzPDDRKZFaan4d4eWBLMHIQqS9gq52cSieGq(2PH)1TvJS0UUvY5paGg8bCc4TcrozhaflLIQqS9gq52ccKid(TdcXX4FDBj351NJPYDqt8FGbx(Wke5KDauSyL58aLgKxMtPIQqS9gq52c(T51a)suADdhog)RBRgzPDDRKZFaan4d4eWBvFogEi351NJPYDqt8FGbx(Wke5KDakQcX2BaLBl4UqK1FNM)1TvJS0UUvY5paGg8bCc4TsZqrvi2EdOCBbziiWGI)teVN)1TvJS0UUvY5paGg8bCc4TsZqrvi2EdOCBbwP5FUFdUe(a8VUTAKL21Tso)ba0GpGtaVv95y4HCNxFoMk3bnX)bgC5dRqKt2bOOkeBVbuUTana)RHC8pch2UdGaPnH1J)sMwgJM7RXhlbvufIT3ak3wGgG)1qo(hHdB1qu0Ule)pqaa9kQcX2BaLBlqdW)Aihqrvi2EdOCBbGdezStZhyWLpeW)62cyGE)3eydAGQJ3f6DSJMIf5HCNxFoMkRx0iWoixfICYoakwmkfvHy7nGYTfG0Zxi2EZ3VaJ)r4W2xHW)62cLv)Xh4yvrRbv8PfyafvHy7nGYTfG0Zxi2EZ3VaJ)r4Ww8jKqBi)RBlfyIhhRYjaGqGyfhH1JAEmb2Gw9ffV9wzqmEJeZFotmzcSbT6lkE7TYGy8gfLmXefycSbT6lkE7TYGyumYuYd5EGJmw9bo2B0WNROkeBVbuUTaKE(cX2B((fy8pch2c2PXJFtGnOPOQOkeBVbuXNqcTHTAu0(O)eXZPOkeBVbuXNqcTHLBlaXrZ)62crozhaVTAAOy7nrukRrsrvi2EdOIpHeAdl3waWhT3dy4xZqi)RBluAqElfL8qbLKjECSQgfTp6pr8CvCewpQzIjwAx3QgfTp6pr8Cv95yEUIQqS9gqfFcj0gwUTG8qmbY)62sUZRphtLC(daObFaNaERqKt2bWBK5PHORqKt2b0sPIQqS9gqfFcj0gwUTauEiniK)1TLL21TkpetGviYj7a4TyK5PK0NvHYdPbHviYj7auufIT3aQ4tiH2WYTfi3uY0i8GGpRmdcvufIT3aQ4tiH2WYTfiEuEG8VUTagO3)nb2GgO64DHEh7OPyrE0Nv1iY474OhnOcrozhaVneTIQqS9gqfFcj0gwUTGdbYcrHpeQOkeBVbuXNqcTHLBlqo)ba0GpGtaVkQcX2Bav8jKqBy52cKB0i3W)62QrwAx3k58haqd(aob8wPzWetS0UUvaTwJZxJI9wHOqmMyckniflfZvufIT3aQ4tiH2WYTfUhiKX5aH8VUTKxb2GG2OuufIT3aQ4tiH2WYTfKHS4yFX1qi49i8POkeBVbuXNqcTHLBlayGc8FUFwby7nkQcX2Bav8jKqBy52cSErJa7GC8VUTS0UUvnkAF0FI45Q6ZXWduAqEzoLkQcX2Bav8jKqBy52cCh0e)hyWLpK)1TvFwvJiJVJJE0Gke5KDa822q0kQcX2Bav8jKqBy52ca(O9Ead)Agc5FDBHsdYlZqPIQqS9gqfFcj0gwUTW9aHmohiurvi2EdOIpHeAdl3wGCJg5gfvHy7nGk(esOnSCBb8jKqBOIQqS9gqfFcj0gwUTWJLyhm6pKg8QOkeBVbuXNqcTHLBlSCmWrVtZ)XsSdgTIQIQqS9gq9viTa(O9Ead)Agc5FDBHsdYBPOKhwAx3QgfTp6pr8Cv95yuufIT3aQVcPCBbYnLmncpi4ZkZGqfvHy7nG6Rqk3wqEiMa5FDBj351NJPso)ba0GpGtaVviYj7a4TOIQqS9gq9viLBlq8O8a5FDB1Nv1iY474OhnOcrozhaVTneTIQqS9gq9viLBl4qGSqu4dHkQcX2Ba1xHuUTGmKfh7lUgcbVhHpfvHy7nG6Rqk3waWaf4)C)ScW2BuufIT3aQVcPCBbwVOrGDqofvHy7nG6Rqk3wakpKgeQOkeBVbuFfs52cKZFaan4d4eWRIQqS9gq9viLBlaXrZ)62crozhaVTAAOy7nrukRrIhwAx3kWbIm2P5dm4YhcQ0muufIT3aQVcPCBbIhLhOIQqS9gq9viLBlWDqt8FGbx(q(x3wwAx3kWbIm2P5dm4YhcQ0myIj9zvnIm(oo6rdQqKt2bWBdrZtjzIhhRs8O8aR4iSEuROkeBVbuFfs52c3deY4CGq(x3wt84yvnef9i0nVwfhH1JAfvHy7nG6Rqk3wGCJg5gfvHy7nG6Rqk3waFcj0gY)62Ys76wboqKXonFGbx(qqLMHIQqS9gq9viLBlCpqiJZbcvufIT3aQVcPCBbhVl07yhTIQqS9gq9viLBl8yj2bJ(dPbVkQcX2Ba1xHuUTWYXah9on)hlXoy0kQkQcX2BavWonE8BcSbTwYnLmncpi4ZkZGq(x3wkWDBETpe5KDauSyKPKjMOatGnOvFrXBVvgeJ3OOKjMmXJJv5eaqiqSIJW6rnpMaBqR(II3ERmigVrI5p)5kQcX2BavWonE8BcSbTYTfKhIjq(x3wYDE95yQKZFaan4d4eWBfICYoaEJmpneDfICYoGwkvufIT3aQGDA843eydALBlaXrZ)62crozhaVTAAOy7nrukRrsrvi2EdOc2PXJFtGnOvUTaXJYdK)1TfWa9(VjWg0avhVl07yhnflYJ(SQgrgFhh9ObviYj7a4THOvufIT3aQGDA843eydALBl4qGSqu4dHkQcX2BavWonE8BcSbTYTfiN)aaAWhWjGxfvHy7nGkyNgp(nb2Gw52cq5H0Gq(x3wwAx3Q8qmbwHiNSdG3IrMNssFwfkpKgewHiNSdqrvi2EdOc2PXJFtGnOvUTGmKfh7lUgcbVhHpfvHy7nGkyNgp(nb2Gw52cagOa)N7Nva2EJIQqS9gqfStJh)MaBqRCBH7bczCoqi)RBl5vGniOnkfvHy7nGkyNgp(nb2Gw52cSErJa7GC8VUTS0UUvnkAF0FI45Q6ZXWdfOrwAx3k58haqd(aob8wPzWduAqEJeLmXeuAqEJykFUIQqS9gqfStJh)MaBqRCBbUdAI)dm4YhY)62Ys76wVhiKX5aHvGje(OyBu8Ws76w1OO9r)jINRQphdtmrb6ZQAez8DC0JguHiNSdG32gIMhYDE95yQKZFaan4d4eWBfICYoak2q0pxrvi2EdOc2PXJFtGnOvUTGgfTp6pr8CkQcX2BavWonE8BcSbTYTfa8r79ag(1meY)62cLgK3srjpS0UUvnkAF0FI45Q6ZXOOkeBVbub704XVjWg0k3w4EGqgNdeQOkeBVbub704XVjWg0k3wGCJg5g(x3wwAx3kGwRX5RrXERquiMIQqS9gqfStJh)MaBqRCBb8jKqBi)RBllTRBfqR1481OyVviketrvi2EdOc2PXJFtGnOvUTa3bnX)bgC5dvufIT3aQGDA843eydALBl44DHEh7O5FDBnXJJvDr4Jd(p3pRyMhR4iSEuZduAqkwkkvufIT3aQGDA843eydALBla8cNIQqS9gqfStJh)MaBqRCBHhlXoy0Fin4vrvi2EdOc2PXJFtGnOvUTWYXah9on)hlXoy0zaWajzSiUyAPLja]] )


end
