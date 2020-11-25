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


    spec:RegisterPack( "Arms", 20201124, [[dGKm1aqivL6rQkXMqf(eKsHrbjPtbjLvjrP8kvfZIc1TKOODj0VKedds1XKKwgQONjrvtdsjxdvsBdsIVPQKACqs15uvswNeLO5rHCpP0(qL4GsuyHsKhkrf5IqkvoPeLQvsbZuIkQDkH(PeLqdvIsAPsucEkvnvj4QqkLARqkv9viLs2RO)kvdwvomPfdvpgLjl4YiBgkFwsnAP40aRgsPOxJk1SPYTrv7wXVvA4QQoUevy5GEUktN46qSDiX3POgpKIZtrA9suP5trSFkDwnlK(GkuwKt05e9Qv5eTICYjNFfNvtVy6pL(FLXTwtPFuEk9LbK)s)VAQB1qwi93Iazu6Be5)klRuPgini4r2Yx5a8iova7WGkMu5a8SkPhhb4KY(K4PpOcLf5eDorVAvorRiNCY5xv9RsVIinlm9EapItfWoLtqftsFdieOjXtFGow6)I9vgq(Z(qBPqiyHwdFX(klYKfNG2hNOUX2hNOZj6wdwdFX(kNA0PMUYsRHVyFLP9vgHafSVYkcpp5IwdFX(kt7RmcbkyFO9aMSqtTVYcixtLYo)pnbWuBFO9aMSqtJwdFX(kt7RmcbkyFLurCK95BweX(K1((HeB5XvX(kJYA5C0A4l2xzAFODOHyicyhcI24SVYkKyGdSJ9bo7lqosOq0A4l2xzAFLriqb7dT9r2xzxi(lAn8f7RmTVcMjLB7JgbAQ9HTq7RKtd0jlKpMEh4KllK(dm1oQlkSMKSqwSAwi90O4okKLspdcecc00JQ2NOWAsIcGN6Y2daY(4I9vf1r3(mXe7dvTprH1KeBi1jnXFMyFgzFCIU9zIj2NOoAKiVENYGuKgf3rb7Jd7tuynjXgsDst8Nj2Nr2x55Q9HA2hQLELjGDspBNYbcbx41X1ziykzroZcPNgf3rHSu6zqGqqGME2UUWAEIS1T3HC9JxVMiK4vWC2Nr2x10RmbSt6vuurHPKflFwi90O4okKLspdcecc00djEfmN9zuR9fqGQa2X(kB2h6XYNELjGDspKMqkzr0klKEAuChfYsPNbbcbbA6VFY56IcRj5IMBaqNzWeSpUyFvTpoSVWkXar)DZlYeUiK4vWC2Nr2xnlKELjGDspZrkkukzrUMfsVYeWoP3ScXHKYnbtpnkUJczPuYIOswi9kta7KE2627qU(XRxt6PrXDuilLsw8RZcPxzcyN0RddqJ0vmHGxZY4o90O4okKLsjlI6zH0RmbSt6VFsH9fRJRNa2j90O4okKLsjl(vzH0tJI7Oqwk9miqiiqtFGWrWWIS1T3HC9JxVMiYV9XH99T9XwuOrhjIcnsJPW0RmbSt6XDAGozH8PKfRIEwi90O4okKLspdcecc00hiCemSiBD7Dix)41RjI8BFCyFFBFSffA0rIOqJ0ykm9kta7KEOIIwtWuYIvRMfspnkUJczP0ZGaHGan9SgfwtN91AFCMELjGDs)Icb)xZemLSyvoZcPNgf3rHSu6zqGqqGMECemS4Icb)xZemEIY42(4sR9XP9XH9HJGHfdKgCM2zQJpgwZJ9zIj2xyLyGO)U5fzcxes8kyo7ZOw7RMfsVYeWoPNFHI66NabCtPKfRw(Sq6vMa2j9bsdot7m1XNEAuChfYsPKfRIwzH0tJI7Oqwk9miqiiqtpuRj7Zi7dvq3(4W(WrWWIbsdot7m1XhdR5j9kta7K(JBeN7(DariykzXQCnlKELjGDs)Icb)xZem90O4okKLsjlwfvYcPxzcyN0Z2jq8t6PrXDuilLswS6xNfspnkUJczP0ZGaHGan94iyyXdjeOPhivAIqszs6vMa2j9eAigIqPKfRI6zH0RmbSt65xOOU(jqa3u6PrXDuilLswS6xLfspnkUJczP0ZGaHGan9bchbdlYw3EhY1pE9AIi)2hh2hBrHgDKik0inMctVYeWoPh3Pb6KfYNswKt0ZcPNgf3rHSu6zqGqqGMErD0irmcIYc7lwhxfXrrAuChfSpoSpOwt2hxSpub90RmbSt6n3aGoZGjKswKZQzH0tJI7Oqwk9miqiiqtpuRj7Jl2hxrp9kta7K(ZP8PKf5KZSq6vMa2j9OayYcnTdrUM0tJI7OqwkLSiNLplKELjGDspG)NMayQ7OayYcnn90O4okKLsjL0himfXjzHSy1Sq6vMa2j9SgfwtPNgf3rHSukzroZcPxzcyN0)JWZtU0tJI7OqwkLSy5ZcPxzcyN0)VcyN0tJI7OqwkLSiALfspnkUJczP0ZGaHGan9bchbdlYw3EhY1pE9AIi)PxzcyN0J72n0XqGMMswKRzH0tJI7Oqwk9miqiiqtFGWrWWIS1T3HC9JxVMiK4vWC2hxSpuj9kta7KECcEeKBWuNswevYcPNgf3rHSu6zqGqqGME2UUWAEI8luux)eiGBkcjEfmN9Xf7RAKR2hh2huRj7Zi7JRONELjGDsVcz6qDzHqAKuYIFDwi90O4okKLspdcecc00hiCemSiBD7Dix)41RjgwZJ9XH9X21fwZtKFHI66NabCtriXRG5sVYeWoP3bQBKRJ2ejuZtJKswe1ZcPNgf3rHSu6zqGqqGM(aHJGHfzRBVd56hVEnrK)0RmbSt6Xaqc3TBiLS4xLfspnkUJczP0ZGaHGan9bchbdlYw3EhY1pE9AIi)PxzcyN0RdJobQUotDUuYIvrplKEAuChfYsPNbbcbbA6deocgwKTU9oKRF861edR5X(4W(y76cR5jYVqrD9tGaUPiK4vWCPxzcyN0JR19fRlqaJ7lLSy1QzH0RmbSt6roQdeI)spnkUJczPuYIv5mlKEAuChfYsPNbbcbbA6VFY56IcRj5IMBaqNzWeSpUyFvTpoSp2UUWAEI4onqNSq(iK4vWC2hxSVQCMELjGDs)zMOFWu3pbc4MUuYIvlFwi90O4okKLspdcecc00JJGHff6K(I15b1nse53(mXe7dvTVaHJGHfzRBVd56hVEnrKF7Jd77B7tlxccekk0j9fRZdQBKinkUJc2hQLELjGDspUB3qFX6sd1PH4nnLSyv0klKEAuChfYsPNbbcbbA6)2(ceocgwKTU9oKRF861er(TpoSVVTpCemSOqN0xSopOUrIi)PxzcyN0)JabyMcM6oUtpjLSyvUMfspnkUJczP0ZGaHGan9FBFbchbdlYw3EhY1pE9AIi)2hh2332hocgwuOt6lwNhu3irK)0RmbSt6HG)Fh1bt)(vgLswSkQKfspnkUJczP0ZGaHGan9FBFbchbdlYw3EhY1pE9AIi)2hh2332hocgwuOt6lwNhu3irK)0RmbSt6nVqxafcmDiD7OdJsjlw9RZcPNgf3rHSu6zqGqqGM(VTVaHJGHfzRBVd56hVEnrKF7Jd77B7dhbdlk0j9fRZdQBKiYF6vMa2j9yld5OqxlxcceQJtkFkzXQOEwi90O4okKLspdcecc00)T9fiCemSiBD7Dix)41RjI8BFCyFFBF4iyyrHoPVyDEqDJer(tVYeWoPhs6pyQ7yoLNUuYIv)QSq6PrXDuilLEgeieeOP)B7lq4iyyr2627qU(XRxte53(4W((2(WrWWIcDsFX68G6gjI8BFCyFHvISDy0iqvOqhZP8uhhboriXRG5SVw7d90RmbSt6z7WOrGQqHoMt5PuYICIEwi90O4okKLspdcecc00JJGHfHeJBhDxhBHmkI8NELjGDsV0qDKbFrMqhBHmkLSiNvZcPNgf3rHSu6zqGqqGME2UUWAEIS1T3HC9JxVMiK4vWC2Nr2xv0tVYeWoPVgrHbGo9fRRLlbxPjLSiNCMfspnkUJczP0ZGaHGan9FBFI6OrIMvioKuUjyKgf3rb7Jd7JTRlSMNiBD7Dix)41RjcjEfmN9zK9vZc2hh2hQAFIcRjjkaEQlBpai7Jl2xvUIU9zIj2NOWAsInK6KM4ptSpJSpor3(qT0RmbSt65j(fAAFX6oegi0dqs5VuYICw(Sq6PrXDuilLEgeieeOPxuhns0ScXHKYnbJ0O4okyFCyFSDDH18enRqCiPCtWiK4vWC2Nr2xnlyFCyFOQ9jkSMKOa4PUS9aGSpUyFv5k62NjMyFIcRjj2qQtAI)mX(mY(4eD7d1sVYeWoPNN4xOP9fR7qyGqpajL)sjlYjALfspnkUJczP0ZGaHGan9qfe6ek0irneUiHgWjx6vMa2j9qKPRmbSt3boj9oWj9r5P03OSuYICY1Sq6PrXDuilLEgeieeOPhvTprD0irE9oLbPinkUJc2hh2NOWAsInK6KM4ptSpJSVYZv7d1SptmX(efwtsSHuN0e)zI9zK9Xj62NjMyFOQ9jkSMKydPoPj(Ze7Jl2hQJU9XH9XwuOrhjIcnsJPq7d1sVYeWoPhImDLjGD6oWjP3boPpkpLEcnedrOuYICIkzH0tJI7Oqwk9kta7KEiY0vMa2P7aNKEh4K(O8u6pWu7OUOWAssjL0)dj2YJRswilwnlKELjGDspUkIJ6xZIiPNgf3rHSukzroZcPNgf3rHSu6hLNsVwUxJc1RJTJ0xS()AMGPxzcyN0RL71Oq96y7i9fR)VMjykzXYNfspnkUJczP0ZGaHGan9I6OrIyeeLf2xSoUkIJI0O4okyFMyI99T9jQJgjIrquwyFX64QioksJI7OG9XH9jaEQlBpai7Jl2xvUIE6vMa2j98e)cnTVyDhcde6biP8xkzr0klKEAuChfYsPNbbcbbA6f1rJeXiiklSVyDCvehfPrXDuW(mXe7tuhnsKxVtzqksJI7OG9XH9jaEQlBpai7Jl2hNvr3(mXe7tuhnsestisJI7OG9XH9HQ2Na4PUS9aGSpUyFCwfD7ZetSpbWtDz7bazFgzFvrlUAFOw6vMa2j91ikma0PVyDTCj4knPKs6j0qmeHYczXQzH0RmbSt6dKgCM2zQJp90O4okKLsjlYzwi90O4okKLspdcecc00djEfmN9zuR9fqGQa2X(kB2h6XYNELjGDspKMqkzXYNfspnkUJczP0ZGaHGan9qTMSpJSpubD7Jd7dvTVVTprD0iXaPbNPDM64J0O4okyFMyI9HJGHfdKgCM2zQJpgwZJ9HAPxzcyN0FCJ4C3VdicbtjlIwzH0tJI7Oqwk9miqiiqtpBxxynpr2627qU(XRxtes8kyo7Zi7RA6vMa2j9kkQOWuYICnlKELjGDspBNYbcbx41X1ziy6PrXDuilLswevYcPNgf3rHSu6zqGqqGM(7NCUUOWAsUO5ga0zgmb7Jl2xv7Jd7lSsmq0F38ImHlcjEfmN9zK9vZcPxzcyN0ZCKIcLsw8RZcPxzcyN0BwH4qs5MGPNgf3rHSukzruplKELjGDspBD7Dix)41Rj90O4okKLsjl(vzH0tJI7Oqwk9miqiiqtpRrH10zFT2hNPxzcyN0VOqW)1mbtjlwf9Sq6vMa2j96Wa0iDfti41SmUtpnkUJczPuYIvRMfsVYeWoP)(jf2xSoUEcyN0tJI7OqwkLSyvoZcPNgf3rHSu6zqGqqGM(WkXar)DZlYeUiK4vWC2Nr2xnlKELjGDsp)cf11pbc4MsjlwT8zH0tJI7Oqwk9miqiiqtpuRj7Zi7dTqp9kta7K(JBeN7(DariykzXQOvwi9kta7K(ffc(VMjy6PrXDuilLswSkxZcPxzcyN0Z2jq8t6PrXDuilLswSkQKfsVYeWoPNqdXqek90O4okKLsjlw9RZcPNgf3rHSu6zqGqqGMEOwt2Nr2hQJE6vMa2j94onqNSq(uYIvr9Sq6PrXDuilLEgeieeOPhQ1K9zK9H6ONELjGDspurrRjykzXQFvwi9kta7KEuamzHM2Hixt6PrXDuilLswKt0ZcPxzcyN0d4)PjaM6okaMSqttpnkUJczPusj9nkllKfRMfspnkUJczP0ZGaHGan9qTMSpJSpubD7Jd7dhbdlgin4mTZuhFmSMN0RmbSt6pUrCU73beHGPKf5mlKELjGDspBNYbcbx41X1ziy6PrXDuilLswS8zH0tJI7Oqwk9miqiiqtpBxxynpr2627qU(XRxtes8kyo7Zi7RA6vMa2j9kkQOWuYIOvwi90O4okKLspdcecc00hwjgi6VBErMWfHeVcMZ(mQ1(QzH0RmbSt6zosrHsjlY1Sq6vMa2j9MvioKuUjy6PrXDuilLswevYcPxzcyN0RddqJ0vmHGxZY4o90O4okKLsjl(1zH0RmbSt6VFsH9fRJRNa2j90O4okKLsjlI6zH0RmbSt6XDAGozH8PNgf3rHSukzXVklKELjGDspurrRjy6PrXDuilLswSk6zH0RmbSt6zRBVd56hVEnPNgf3rHSukzXQvZcPNgf3rHSu6zqGqqGMEiXRG5SpJATVacufWo2xzZ(qpwE7Jd7dhbdlEMj6hm19tGaUPlI8NELjGDspKMqkzXQCMfsVYeWoPN5iffk90O4okKLsjlwT8zH0tJI7Oqwk9miqiiqtpocgw8mt0pyQ7NabCtxe53(mXe7lSsmq0F38ImHlcjEfmN9zK9vZc2hh2332NOoAKiZrkkuKgf3rH0RmbSt65xOOU(jqa3ukzXQOvwi90O4okKLspdcecc00lQJgjgGKggfPUrI0O4okKELjGDs)Icb)xZemLSyvUMfsVYeWoPNTtG4N0tJI7OqwkLSyvujlKEAuChfYsPNbbcbbA6XrWWINzI(btD)eiGB6Ii)PxzcyN0tOHyicLswS6xNfsVYeWoPFrHG)RzcMEAuChfYsPKfRI6zH0RmbSt6n3aGoZGjKEAuChfYsPKskPhfcEGDYICIoNOxfDor90BwHdyQV0x25)xOqb7JR2NYeWo2NdCYfTgs)9tSS4xxn9)Wfd4O0)f7RmG8N9H2sHqWcTg(I9vCrH4XjO9XjAzS9Xj6CIU1G1WxSVYPgDQPRS0A4l2xzAFLriqb7RSIWZtUO1WxSVY0(kJqGc2hApGjl0u7RSaY1uPSZ)ttam12hApGjl00O1WxSVY0(kJqGc2xjvehzF(MfrSpzTVFiXwECvSVYOSwohTg(I9vM2hAhAigIa2HGOno7RScjg4a7yFGZ(cKJekeTg(I9vM2xzecuW(qBFK9v2fI)IwdFX(kt7RGzs52(OrGMAFyl0(k50aDYc5JwdwdFX(q7qdXqekyF4e2cj7JT84QyF4unyUO9vgmg9lN9n7uMnkKhdXzFkta7C23ootJwdkta7CXFiXwECv(0wbxfXr9RzreRbLjGDU4pKylpUkFARGCuhieVXJYtTA5EnkuVo2osFX6)RzcAnOmbSZf)HeB5Xv5tBfEIFHM2xSUdHbc9aKu(ZyawROoAKigbrzH9fRJRI4OinkUJcMyY3I6OrIyeeLf2xSoUkIJI0O4okWHa4PUS9aG4svUIU1GYeWox8hsSLhxLpTvQruyaOtFX6A5sWvAmgG1kQJgjIrquwyFX64QioksJI7OGjMiQJgjYR3PmifPrXDuGdbWtDz7baXfoRIUjMiQJgjcPjePrXDuGduva8ux2EaqCHZQOBIjcGN6Y2daYOQOfxrnRbRHVyFODOHyicfSpcfcAQ9jaEY(KgY(uMSq7dC2NIIcCkUJIwdkta7CTSgfwtwdkta7CFAR8JWZtoRbLjGDUpTv(xbSJ1GYeWo3N2k4UDdDmeOPgdWAdeocgwKTU9oKRF861er(TguMa25(0wbNGhb5gm1gdWAdeocgwKTU9oKRF861eHeVcMJlOI1GYeWo3N2kkKPd1LfcPrmgG1Y21fwZtKFHI66NabCtriXRG54s1ix5aQ1KrCfDRbLjGDUpTvCG6g56Onrc180igdWAdeocgwKTU9oKRF861edR5Hd2UUWAEI8luux)eiGBkcjEfmN1GYeWo3N2kyaiH72nymaRnq4iyyr2627qU(XRxte53AqzcyN7tBfDy0jq11zQZzmaRnq4iyyr2627qU(XRxte53AqzcyN7tBfCTUVyDbcyCFgdWAdeocgwKTU9oKRF861edR5Hd2UUWAEI8luux)eiGBkcjEfmN1GYeWo3N2kih1bcXFwdkta7CFARCMj6hm19tGaUPZyaw79toxxuynjx0Cda6mdMaxQYbBxxynprCNgOtwiFes8kyoUuLtRbLjGDUpTvWD7g6lwxAOoneVPgdWAXrWWIcDsFX68G6gjI8BIjOAGWrWWIS1T3HC9JxVMiYphFRLlbbcff6K(I15b1nsKgf3rbuZAqzcyN7tBLFeiaZuWu3XD6jgdWA)oq4iyyr2627qU(XRxte5NJVXrWWIcDsFX68G6gjI8BnOmbSZ9PTce8)7Ooy63VYiJbyTFhiCemSiBD7Dix)41RjI8ZX34iyyrHoPVyDEqDJer(TguMa25(0wX8cDbuiW0H0TJomYyaw73bchbdlYw3EhY1pE9AIi)C8nocgwuOt6lwNhu3irKFRbLjGDUpTvWwgYrHUwUeeiuhNuEJbyTFhiCemSiBD7Dix)41RjI8ZX34iyyrHoPVyDEqDJer(TguMa25(0wbs6pyQ7yoLNoJbyTFhiCemSiBD7Dix)41RjI8ZX34iyyrHoPVyDEqDJer(TguMa25(0wHTdJgbQcf6yoLNmgG1(DGWrWWIS1T3HC9JxVMiYphFJJGHff6K(I15b1nse5NJWkr2omAeOkuOJ5uEQJJaNiK4vWCTOBnOmbSZ9PTI0qDKbFrMqhBHmYyawlocgwesmUD0DDSfYOiYV1GYeWo3N2k1ikma0PVyDTCj4kngdWAz76cR5jYw3EhY1pE9AIqIxbZzuv0TguMa25(0wHN4xOP9fR7qyGqpajL)mgG1(TOoAKOzfIdjLBcgPrXDuGd2UUWAEIS1T3HC9JxVMiK4vWCgvZcCGQIcRjjkaEQlBpaiUuLROBIjIcRjj2qQtAI)mXiorh1SguMa25(0wHN4xOP9fR7qyGqpajL)mgG1kQJgjAwH4qs5MGrAuChf4GTRlSMNOzfIdjLBcgHeVcMZOAwGduvuynjrbWtDz7baXLQCfDtmruynjXgsDst8NjgXj6OM1GYeWo3N2kqKPRmbSt3boX4r5P2gLzmaRfQGqNqHgjQHWfj0ao5SguMa25(0wbImDLjGD6oWjgpkp1sOHyiczmaRfvf1rJe517ugKI0O4okWHOWAsInK6KM4ptmQ8Cf1mXerH1KeBi1jnXFMyeNOBIjOQOWAsInK6KM4pt4cQJohSffA0rIOqJ0yke1SguMa25(0wbImDLjGD6oWjgpkp1EGP2rDrH1KynynOmbSZfj0qmeHAdKgCM2zQJ3AqzcyNlsOHyic9PTcKMGXaSwiXRG5mQnGavbStzd9y5TguMa25IeAigIqFARCCJ4C3VdicbngG1c1AYiubDoq1Vf1rJedKgCM2zQJpsJI7OGjMGJGHfdKgCM2zQJpgwZdQznOmbSZfj0qmeH(0wrrrffAmaRLTRlSMNiBD7Dix)41RjcjEfmNrvTguMa25IeAigIqFARW2PCGqWfEDCDgcAnOmbSZfj0qmeH(0wH5iffYyaw79toxxuynjx0Cda6mdMaxQYryLyGO)U5fzcxes8kyoJQzbRbLjGDUiHgIHi0N2kMvioKuUjO1GYeWoxKqdXqe6tBf2627qU(XRxJ1GYeWoxKqdXqe6tBLffc(VMjOXaSwwJcRPRLtRbLjGDUiHgIHi0N2k6Wa0iDfti41SmUTguMa25IeAigIqFARC)Kc7lwhxpbSJ1GYeWoxKqdXqe6tBf(fkQRFceWnzmaRnSsmq0F38ImHlcjEfmNr1SG1GYeWoxKqdXqe6tBLJBeN7(DariOXaSwOwtgHwOBnOmbSZfj0qmeH(0wzrHG)RzcAnOmbSZfj0qmeH(0wHTtG4hRbLjGDUiHgIHi0N2keAigIqwdkta7CrcnedrOpTvWDAGozH8gdWAHAnzeQJU1GYeWoxKqdXqe6tBfOIIwtqJbyTqTMmc1r3AqzcyNlsOHyic9PTckaMSqt7qKRXAqzcyNlsOHyic9PTcG)NMayQ7OayYcn1AWAqzcyNl2OS2JBeN7(DariOXaSwOwtgHkOZbocgwmqAWzANPo(yynpwdkta7CXgL9PTcBNYbcbx41X1ziO1GYeWoxSrzFAROOOIcngG1Y21fwZtKTU9oKRF861eHeVcMZOQwdkta7CXgL9PTcZrkkKXaS2WkXar)DZlYeUiK4vWCg1wZcwdkta7CXgL9PTIzfIdjLBcAnOmbSZfBu2N2k6Wa0iDfti41SmUTguMa25Ink7tBL7NuyFX646jGDSguMa25Ink7tBfCNgOtwiV1GYeWoxSrzFARavu0AcAnOmbSZfBu2N2kS1T3HC9JxVgRbLjGDUyJY(0wbstWyawlK4vWCg1gqGQa2PSHES8CGJGHfpZe9dM6(jqa30fr(TguMa25Ink7tBfMJuuiRbLjGDUyJY(0wHFHI66NabCtgdWAXrWWINzI(btD)eiGB6Ii)MysyLyGO)U5fzcxes8kyoJQzbo(wuhnsK5iffksJI7OG1GYeWoxSrzFARSOqW)1mbngG1kQJgjgGKggfPUrI0O4okynOmbSZfBu2N2kSDce)ynOmbSZfBu2N2keAigIqgdWAXrWWINzI(btD)eiGB6Ii)wdkta7CXgL9PTYIcb)xZe0AqzcyNl2OSpTvm3aGoZGjynynOmbSZfpWu7OUOWAsAz7uoqi4cVoUodbngG1IQIcRjjkaEQlBpaiUuf1r3etqvrH1KeBi1jnXFMyeNOBIjI6OrI86DkdsrAuChf4quynjXgsDst8NjgvEUIAOM1GYeWox8atTJ6IcRj5tBfffvuOXaSw2UUWAEIS1T3HC9JxVMiK4vWCgv1AqzcyNlEGP2rDrH1K8PTcKMGXaSwiXRG5mQnGavbStzd9y5TguMa25IhyQDuxuynjFARWCKIczmaR9(jNRlkSMKlAUbaDMbtGlv5iSsmq0F38ImHlcjEfmNr1SG1GYeWox8atTJ6IcRj5tBfZkehsk3e0AqzcyNlEGP2rDrH1K8PTcBD7Dix)41RXAqzcyNlEGP2rDrH1K8PTIomansxXecEnlJBRbLjGDU4bMAh1ffwtYN2k3pPW(I1X1ta7ynOmbSZfpWu7OUOWAs(0wb3Pb6KfYBmaRnq4iyyr2627qU(XRxte5NJVzlk0OJerHgPXuO1GYeWox8atTJ6IcRj5tBfOIIwtqJbyTbchbdlYw3EhY1pE9AIi)C8nBrHgDKik0inMcTguMa25IhyQDuxuynjFARSOqW)1mbngG1YAuynDTCAnOmbSZfpWu7OUOWAs(0wHFHI66NabCtgdWAXrWWIlke8FntW4jkJBU0Yjh4iyyXaPbNPDM64JH18yIjHvIbI(7MxKjCriXRG5mQTMfSguMa25IhyQDuxuynjFARein4mTZuhV1GYeWox8atTJ6IcRj5tBLJBeN7(DariOXaSwOwtgHkOZbocgwmqAWzANPo(yynpwdkta7CXdm1oQlkSMKpTvwui4)AMGwdkta7CXdm1oQlkSMKpTvy7ei(XAqzcyNlEGP2rDrH1K8PTcHgIHiKXaSwCemS4Hec00dKknriPmXAqzcyNlEGP2rDrH1K8PTc)cf11pbc4MSguMa25IhyQDuxuynjFARG70aDYc5ngG1giCemSiBD7Dix)41RjI8ZbBrHgDKik0inMcTguMa25IhyQDuxuynjFARyUbaDMbtWyawROoAKigbrzH9fRJRI4OinkUJcCa1AIlOc6wdkta7CXdm1oQlkSMKpTvoNYBmaRfQ1ex4k6wdkta7CXdm1oQlkSMKpTvqbWKfAAhICnwdkta7CXdm1oQlkSMKpTva8)0eatDhfatwOPPKsMa]] )


end
