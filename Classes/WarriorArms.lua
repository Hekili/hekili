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


    spec:RegisterPack( "Arms", 20201210, [[dGKJUaqijr6raqBcvPpjjcnkKqDkKqwLOG6vskZcvv3suGDjXVevnma6ysslts4zIcnnKO6AiPABaGVHeLXjjQZHeuRdjL08qvCpfAFiroiskwOOYdLebtejq5IiPeNuuqwjszMibQ2PO0qrsPwksq0tfzQusxfjqSvKG0xrcc7v4VanyfDyIfJspgXKj1LH2mL6Zky0a60kTAKaPxJQYSP42OYUL63QA4ivhhjGLd65QmDQUok2UKQVtjgpa68IIwVKiA(ij7NKJQH1iPfhJSvayfawTIQawaKYOoLLrkpsEM0Xirxi8jdyKAHdJe1a5UirxY08IoSgP7zGemsaDN(rTMp)W6azylKNl)TCmgX3VjqX2ZFlhjFKyzwJNH6GnsAXXiBfawbGvROkGfaPmQtzvqHJKW4aFyKslhJr897kbOy7rc4Q1yhSrsJhjsaOAsnqUtnPqiq4(qfnaunPGHeKJfHQzva5xnRaWkaurtrdavZkbGspGh1QIgaQMzGAsnAnQvtQndhhAkkAaOAMbQj1O1OwnPqxI)WmvtkKmhW8zio6yR3EqnPqxI)WmlkAaOAMbQj1O1OwnZjUBq1mb8zC10F1KoejphR4Qj1qTPGxu0aq1mdutQfaIegF)gHvINAsTHizV9B1Cp1uJg0rDrrdavZmqnPgTg1QjfKdvZmKJCxrrdavZmqnTAbf(utSDyMQP9dvZCgrJN)qUsKm75xyns32dge0f4a6H1iB1WAKWwynOoYfjcCDeUsKOy10Eha6GqKt2(utkPMvRmGQjvuPMuSA6cCa9cqumoWcDIRM8OMvaOAsfvQPlgS9cNCNqGybBH1GA1Kx10f4a6fGOyCGf6exn5rnZi1vtksnPOijeF)osKVPami8HhiR0ncdpYwrynsylSguh5IebUocxjsK)n63sxiV5VJ5apo5awGiNS9PM8OMvwn5vnhi6ce5KTp1CunbmscX3VJKuxCbgEKnJH1iHTWAqDKlse46iCLibroz7tn5zun1mqX3VvZmSAcyjJrsi((DKGyRdpYs5H1iHTWAqDKlse46iCLiD0rJb0f4a6xXcWfASSTwnPKAwvn5vn1Vx0ish0YZ06Raroz7tn5rnhi6ijeF)osedk1XWJSupSgjH473rYIazHOWhcJe2cRb1rUWJSaqynscX3VJe5n)Dmh4XjhWiHTWAqDKl8ilLfwJe2cRb1rUirGRJWvIelJTDrQlUalqKt2(utEuZQvwn5vnRu1u)Ebk1LbewGiNS9fjH473rck1LbegEKTYH1ijeF)osstwSDqX2r4b8j8fjSfwdQJCHhzPWH1ijeF)oshDuGGVniRC((DKWwynOoYfEKTkGH1iHTWAqDKlse46iCLirakWb8uZr1SIijeF)osFDes)TGWWJSvRgwJe2cRb1rUirGRJWvIelJTDrJI2KjirmCf9BPvtEvtkwn1ilJTDH8M)oMd84KdyHHUAYRAcLbun5rnZiGQjvuPMqzavtEutkdq1KIIKq897iXAenE(d5cpYwTIWAKWwynOoYfjcCDeUsKyzSTlFDes)TGWY5cHp1KsJQzfQjVQjlJTDrJI2KjirmCf9BPvtQOsnPy1u)ErJiDqlptRVce5KTp1KNr1CGOvtEvtY)g9BPlK383XCGhNCalqKt2(utkPMdeTAsrrsi((DK4EOlgWZHlFy4r2QzmSgjH473rsJI2KjirmCrcBH1G6ix4r2QuEynsylSguh5IebUocxjsqzavtEutaaq1Kx1KLX2UOrrBYeKigUI(T0rsi((DKo(ymMJUzDhHHhzRs9WAKeIVFhPVocP)wqyKWwynOoYfEKTkaewJe2cRb1rUirGRJWvIelJTD5y0ASb1O4alquiEKeIVFhjY3AKRdpYwLYcRrcBH1G6ixKiW1r4krILX2UCmAn2GAuCGfikepscX3VJecqKW4y4r2QvoSgjH473rI7HUyaphU8HrcBH1G6ix4r2Qu4WAKWwynOoYfjcCDeUsKCXGTxSry9hc(2GSI7gSGTWAqTAYRAcLbunPKAcaagjH473rYcWfASSTo8iBfagwJKq897iDgHlsylSguh5cpYwr1WAKeIVFhP6lXFyMGqMdyKWwynOoYfEKTIkcRrsi((DKwo6yR3EaS(s8hMzKWwynOoYfE4rsJ2cJXdRr2QH1ijeF)oseGcCaJe2cRb1rUWJSvewJKq897irNHJdnrcBH1G6ix4r2mgwJKq897ir)997iHTWAqDKl8ilLhwJe2cRb1rUirGRJWvIKgzzSTlK383XCGhNCalm0JKq897iXA(xdAZaZm8il1dRrcBH1G6ixKiW1r4krsJSm22fYB(7yoWJtoGfiYjBFQjLutaiscX3VJelcpeY32dHhzbGWAKWwynOoYfjcCDeUsKi)B0VLUW9qxmGNdx(Wce5KTp1KsQz1c1vtEvtOmGQjpQj1bmscX3VJKajsJG(dHy7HhzPSWAKWwynOoYfjcCDeUsK0ilJTDH8M)oMd84Kdyr)wA1Kx1K8Vr)w6c3dDXaEoC5dlqKt2(IKq897iz2bG(bsbLrpWHThEKTYH1iHTWAqDKlse46iCLiPrwgB7c5n)Dmh4XjhWcd9ijeF)os2lezn)RdpYsHdRrcBH1G6ixKiW1r4krsJSm22fYB(7yoWJtoGfg6rsi((DKKMGNdfdirmMWJSvbmSgjSfwdQJCrIaxhHRejnYYyBxiV5VJ5apo5aw0VLwn5vnj)B0VLUW9qxmGNdx(Wce5KTVijeF)osSYa4Bd6WLW3fEKTA1WAKWwynOoYfPw4WiT9rGmUWAqqkaJ0odhOgRVemscX3VJ02hbY4cRbbPams7mCGAS(sWWJSvRiSgjSfwdQJCrQfomsAikA7fIG1X7qtKeIVFhjnefT9crW64DOj8iB1mgwJKq897iXCi46i3fjSfwdQJCHhzRs5H1iHTWAqDKlse46iCLiD0rJb0f4a6xXcWfASSTwnPKAwvn5vnj)B0VLUWAenE(d5kqKt2(utkPMvRiscX3VJ0zbr6BpaEoC5dVWJSvPEynsylSguh5IebUocxjsqz1GyDS9IO1xbb4E(fjH473rcY0GcX3Vbn75rYSNd2chgjGcj8iBvaiSgjSfwdQJCrIaxhHRejkwnDXGTx4K7ecelylSguRM8QMUahqVaefJdSqN4QjpQzgPUAsrQjvuPMUahqVaefJdSqN4QjpQzfaQMurLAsXQPlWb0larX4al0jUAsj1SYaQM8QMKVo2s7L6y7aZeQMuuKeIVFhjitdkeF)g0SNhjZEoylCyKqaIeghdpYwLYcRrcBH1G6ixKeIVFhjitdkeF)g0SNhjZEoylCyKUThmiOlWb0dp8irhIKNJv8WAKTAynscX3VJeR4UbbpGpJhjSfwdQJCHhzRiSgjSfwdQJCrQfomssL8akq5aT)2bFBq6VfegjH473rsQKhqbkhO93o4Bds)TGWWJSzmSgjSfwdQJCrIaxhHRejxmy7fBew)HGVniR4UblylSguRMurLAwPQPlgS9IncR)qW3gKvC3GfSfwdQvtEvtF5qq)b1lQMusnRsDaJKq897iXHCpmtW3g0WqwnOgIc3fEKLYdRrcBH1G6ixKiW1r4krYfd2EXgH1Fi4BdYkUBWc2cRb1QjvuPMUyW2lCYDcbIfSfwdQvtEvtF5qq)b1lQMusnROkGQjvuPMUyW2lqS1fSfwdQvtEvtkwn9Ldb9huVOAsj1SIQaQMurLA6lhc6pOEr1Kh1SkLtD1KIIKq897inWiq9kn4Bdkvse(oWWdpsiarcJJH1iB1WAKeIVFhjnkAtMGeXWfjSfwdQJCHhzRiSgjSfwdQJCrIaxhHRejiYjBFQjpJQPMbk((TAMHvtalzmscX3VJeeBD4r2mgwJe2cRb1rUirGRJWvIeugq1Kh1eaaun5vnPy1Ssvtxmy7fnkAtMGeXWvWwynOwnPIk1KLX2UOrrBYeKigUI(T0QjffjH473r64JXyo6M1DegEKLYdRrcBH1G6ixKiW1r4krI8Vr)w6c5n)Dmh4XjhWce5KTp1Kh1SYQjVQ5arxGiNS9PMJQjGrsi((DKK6IlWWJSupSgjSfwdQJCrIaxhHRejwgB7IuxCbwGiNS9PM8OMvRSAYRAwPQP(9cuQldiSaroz7lscX3VJeuQldim8ilaewJKq897ir(McWGWhEGSs3imsylSguh5cpYszH1iHTWAqDKlse46iCLiD0rJb0f4a6xXcWfASSTwnPKAwvn5vn1Vx0ish0YZ06Raroz7tn5rnhi6ijeF)osedk1XWJSvoSgjH473rYIazHOWhcJe2cRb1rUWJSu4WAKeIVFhjYB(7yoWJtoGrcBH1G6ix4r2QagwJe2cRb1rUirGRJWvIKgzzSTlK383XCGhNCalm0vtQOsnzzSTlhJwJnOgfhybIcXvtQOsnHYaQMusnbaQhjH473rI8Tg56WJSvRgwJe2cRb1rUirGRJWvIebOahWtnhvZkIKq897i91ri93ccdpYwTIWAKeIVFhjPjl2oOy7i8a(e(Ie2cRb1rUWJSvZyynscX3VJ0rhfi4BdYkNVFhjSfwdQJCHhzRs5H1iHTWAqDKlse46iCLiXYyBx0OOnzcsedxr)wA1Kx1ekdOAYJAsDaJKq897iXAenE(d5cpYwL6H1iHTWAqDKlse46iCLiPFVOrKoOLNP1xbICY2NAYZOAoq0rsi((DK4EOlgWZHlFy4r2QaqynsylSguh5IebUocxjsqzavtEutkhWijeF)oshFmgZr3SUJWWJSvPSWAKeIVFhPVocP)wqyKWwynOoYfEKTALdRrsi((DKiFRrUosylSguh5cpYwLchwJKq897iHaejmogjSfwdQJCHhzRaWWAKeIVFhP6lXFyMGqMdyKWwynOoYfEKTIQH1ijeF)oslhDS1BpawFj(dZmsylSguh5cp8ibuiH1iB1WAKWwynOoYfjcCDeUsKGYaQM8OMaaGQjVQjlJTDrJI2KjirmCf9BPJKq897iD8XymhDZ6ocdpYwrynscX3VJe5BkadcF4bYkDJWiHTWAqDKl8iBgdRrcBH1G6ixKiW1r4krI8Vr)w6c5n)Dmh4XjhWce5KTp1Kh1SAKeIVFhjPU4cm8ilLhwJe2cRb1rUirGRJWvIK(9Igr6GwEMwFfiYjBFQjpJQ5arhjH473rIyqPogEKL6H1ijeF)osweilef(qyKWwynOoYfEKfacRrsi((DKKMSy7GITJWd4t4lsylSguh5cpYszH1ijeF)oshDuGGVniRC((DKWwynOoYfEKTYH1ijeF)osSgrJN)qUiHTWAqDKl8ilfoSgjH473rck1LbegjSfwdQJCHhzRcyynscX3VJe5n)Dmh4XjhWiHTWAqDKl8iB1QH1iHTWAqDKlse46iCLibroz7tn5zun1mqX3VvZmSAcyjJQjVQjlJTD5SGi9ThaphU8HxHHEKeIVFhji26WJSvRiSgjH473rIyqPogjSfwdQJCHhzRMXWAKWwynOoYfjcCDeUsKyzSTlNfePV9a45WLp8km0vtQOsn1Vx0ish0YZ06Raroz7tn5rnhiA1Kx1Ssvtxmy7fIbL6ybBH1G6ijeF)osCp0fd45WLpm8iBvkpSgjSfwdQJCrIaxhHRejxmy7fnefDlmda9c2cRb1rsi((DK(6iK(BbHHhzRs9WAKeIVFhjY3AKRJe2cRb1rUWJSvbGWAKWwynOoYfjcCDeUsKyzSTlNfePV9a45WLp8km0JKq897iHaejmogEKTkLfwJKq897i91ri93ccJe2cRb1rUWJSvRCynscX3VJKfGl0yzBDKWwynOoYfEKTkfoSgjH473rQ(s8hMjiK5agjSfwdQJCHhzRaWWAKeIVFhPLJo26ThaRVe)HzgjSfwdQJCHhE4rQocV97iBfawbGvRaWkhjlcS3E4IugIJ(dDuRMuxnfIVFRMM98ROOfPJosISuw1irh(2RbJeaQMudK7utkeceUpurdavtkyib5yrOAwfq(vZkaScav0u0aq1SsaO0d4rTQObGQzgOMuJwJA1KAZWXHMIIgaQMzGAsnAnQvtk0L4pmt1KcjZbmFgIJo26Thutk0L4pmZIIgaQMzGAsnAnQvZCI7guntaFgxn9xnPdrYZXkUAsnuBk4ffnaunZa1KAbGiHX3VryL4PMuBis2B)wn3tn1ObDuxu0aq1mdutQrRrTAsb5q1md5i3vu0aq1mdutRwqHp1eBhMPAA)q1mNr045pKROOPObGQj1carcJJA1KfTFiQMKNJvC1Kfh2(kQj1qiiD)uZ(7maOa5SzmQPq897tn)2Kzrrti((9vOdrYZXkETX8SI7ge8a(mUIMq897RqhIKNJv8AJ5zoeCDKJ)w4WrPsEafOCG2F7GVni93ccv0eIVFFf6qK8CSIxBmphY9WmbFBqddz1GAikCh)R9OlgS9IncR)qW3gKvC3GfSfwdQPIQk1fd2EXgH1Fi4BdYkUBWc2cRb186lhc6pOErkvL6aQOjeF)(k0Hi55yfV2y(bgbQxPbFBqPsIW3bY)Ap6IbBVyJW6pe8Tbzf3nybBH1GAQOYfd2EHtUtiqSGTWAqnV(YHG(dQxKsvufqQOYfd2EbITUGTWAqnVuSVCiO)G6fPufvbKkQ8Ldb9huVipvPCQtrkAkAaOAsTaqKW4OwnX6imt10xounDGOAke)HQ5EQPuxwJWAWIIMq897BKauGdOIMq897R2yE6mCCOrrti((9vBmp933Vv0eIVFF1gZZA(xdAZaZK)1EuJSm22fYB(7yoWJtoGfg6kAcX3VVAJ5zr4Hq(2EG)1EuJSm22fYB(7yoWJtoGfiYjBFucau0eIVFF1gZlqI0iO)qi2o)R9i5FJ(T0fUh6Ib8C4YhwGiNS9rPQfQZlugqEOoGkAcX3VVAJ5n7aq)aPGYOh4W25FTh1ilJTDH8M)oMd84Kdyr)wAEj)B0VLUW9qxmGNdx(Wce5KTpfnH473xTX82lezn)R5FTh1ilJTDH8M)oMd84KdyHHUIMq897R2yEPj45qXaseJH)1EuJSm22fYB(7yoWJtoGfg6kAcX3VVAJ5zLbW3g0HlHVJ)1EuJSm22fYB(7yoWJtoGf9BP5L8Vr)w6c3dDXaEoC5dlqKt2(u0eIVFF1gZZCi46ih)TWHJBFeiJlSgeKcWiTZWbQX6lbv0eIVFF1gZZCi46ih)TWHJAikA7fIG1X7qJIMq897R2yEMdbxh5ofnH473xTX8NfePV9a45WLp84FThp6OXa6cCa9Ryb4cnw2wtPQ8s(3OFlDH1iA88hYvGiNS9rPQvOOjeF)(QnMhY0GcX3Vbn7583chocui8V2Jqz1GyDS9IO1xbb4E(POjeF)(QnMhY0GcX3Vbn7583choIaejmoY)ApsXUyW2lCYDcbIfSfwdQ51f4a6fGOyCGf6eNNmsDkIkQCboGEbikghyHoX5PcaPIkk2f4a6fGOyCGf6eNsvgqEjFDSL2l1X2bMjKIu0eIVFF1gZdzAqH473GM9C(BHdhVThmiOlWb0v0u0eIVFFfeGiHXXrnkAtMGeXWPOjeF)(kiarcJJ1gZdXwZ)Apcroz7JNrndu897mmGLmQOjeF)(kiarcJJ1gZF8XymhDZ6oc5FThHYaYdaaiVuCL6IbBVOrrBYeKigUc2cRb1urflJTDrJI2KjirmCf9BPPifnH473xbbisyCS2yEPU4cK)1EK8Vr)w6c5n)Dmh4XjhWce5KTpEQmVdeDbICY23iGkAcX3VVccqKW4yTX8qPUmGq(x7rwgB7IuxCbwGiNS9Xt1kZBLQFVaL6YaclqKt2(u0eIVFFfeGiHXXAJ5jFtbyq4dpqwPBeQOjeF)(kiarcJJ1gZtmOuh5FThp6OXa6cCa9Ryb4cnw2wtPQ8QFVOrKoOLNP1xbICY2hpdeTIMq897RGaejmowBmVfbYcrHpeQOjeF)(kiarcJJ1gZtEZFhZbECYburti((9vqaIeghRnMN8Tg5A(x7rnYYyBxiV5VJ5apo5awyOtfvSm22LJrRXguJIdSarH4urfugqkbauxrti((9vqaIeghRnM)RJq6VfeY)ApsakWb8gRqrti((9vqaIeghRnMxAYITdk2ocpGpHpfnH473xbbisyCS2y(JokqW3gKvoF)wrti((9vqaIeghRnMN1iA88hYX)ApYYyBx0OOnzcsedxr)wAEHYaYd1burti((9vqaIeghRnMN7HUyaphU8H8V2J63lAePdA5zA9vGiNS9XZ4arROjeF)(kiarcJJ1gZF8XymhDZ6oc5FThHYaYdLdOIMq897RGaejmowBm)xhH0Fliurti((9vqaIeghRnMN8Tg5AfnH473xbbisyCS2yEeGiHXrfnH473xbbisyCS2y(6lXFyMGqMdOIMq897RGaejmowBm)YrhB92dG1xI)Wmv0u0eIVFFfGcz84JXyo6M1DeY)ApcLbKhaaqEzzSTlAu0MmbjIHROFlTIMq897Raui1gZt(McWGWhEGSs3iurti((9vakKAJ5L6Ilq(x7rY)g9BPlK383XCGhNCalqKt2(4PQIMq897Raui1gZtmOuh5FTh1Vx0ish0YZ06Raroz7JNXbIwrti((9vakKAJ5Tiqwik8HqfnH473xbOqQnMxAYITdk2ocpGpHpfnH473xbOqQnM)OJce8TbzLZ3Vv0eIVFFfGcP2yEwJOXZFiNIMq897Raui1gZdL6Yacv0eIVFFfGcP2yEYB(7yoWJtoGkAcX3VVcqHuBmpeBn)R9ie5KTpEg1mqX3VZWawYiVSm22LZcI03Ea8C4YhEfg6kAcX3VVcqHuBmpXGsDurti((9vakKAJ55EOlgWZHlFi)R9ilJTD5SGi9ThaphU8HxHHovuPFVOrKoOLNP1xbICY2hpdenVvQlgS9cXGsDSGTWAqTIMq897Raui1gZ)1ri93cc5FThDXGTx0qu0TWma0lylSguROjeF)(kafsTX8KV1ixROjeF)(kafsTX8iarcJJ8V2JSm22LZcI03Ea8C4YhEfg6kAcX3VVcqHuBm)xhH0Fliurti((9vakKAJ5TaCHglBRv0eIVFFfGcP2y(6lXFyMGqMdOIMq897Raui1gZVC0XwV9ay9L4pmtfnfnH473x52EWGGUahqFK8nfGbHp8azLUri)R9ifBVdaDqiYjBFuQALbKkQOyxGdOxaIIXbwOtCEQaqQOYfd2EHtUtiqSGTWAqnVUahqVaefJdSqN48KrQtruKIMq897RCBpyqqxGdOxBmVuxCbY)Aps(3OFlDH8M)oMd84KdybICY2hpvM3bIUaroz7BeqfnH473x52EWGGUahqV2yEi2A(x7riYjBF8mQzGIVFNHbSKrfnH473x52EWGGUahqV2yEIbL6i)R94rhngqxGdOFflaxOXY2AkvLx97fnI0bT8mT(kqKt2(4zGOv0eIVFFLB7bdc6cCa9AJ5Tiqwik8HqfnH473x52EWGGUahqV2yEYB(7yoWJtoGkAcX3VVYT9GbbDboGETX8qPUmGq(x7rwgB7IuxCbwGiNS9Xt1kZBLQFVaL6YaclqKt2(u0eIVFFLB7bdc6cCa9AJ5LMSy7GITJWd4t4trti((9vUThmiOlWb0RnM)OJce8TbzLZ3Vv0eIVFFLB7bdc6cCa9AJ5)6iK(BbH8V2JeGcCaVXku0eIVFFLB7bdc6cCa9AJ5znIgp)HC8V2JSm22fnkAtMGeXWv0VLMxkwJSm22fYB(7yoWJtoGfg68cLbKNmcivubLbKhkdqksrti((9vUThmiOlWb0RnMN7HUyaphU8H8V2JSm22LVocP)wqy5CHWhLgRGxwgB7IgfTjtqIy4k63stfvuS(9Igr6GwEMwFfiYjBF8moq08s(3OFlDH8M)oMd84KdybICY2hLgiAksrti((9vUThmiOlWb0RnMxJI2KjirmCkAcX3VVYT9GbbDboGETX8hFmgZr3SUJq(x7rOmG8aaaYllJTDrJI2KjirmCf9BPv0eIVFFLB7bdc6cCa9AJ5)6iK(BbHkAcX3VVYT9GbbDboGETX8KV1ixZ)ApYYyBxogTgBqnkoWcefIROjeF)(k32dge0f4a61gZJaejmoY)ApYYyBxogTgBqnkoWcefIROjeF)(k32dge0f4a61gZZ9qxmGNdx(qfnH473x52EWGGUahqV2yElaxOXY2A(x7rxmy7fBew)HGVniR4UblylSguZlugqkbaaQOjeF)(k32dge0f4a61gZFgHtrti((9vUThmiOlWb0RnMV(s8hMjiK5aQOjeF)(k32dge0f4a61gZVC0XwV9ay9L4pmZWdpca]] )


end
