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

        potion = "potion_of_phantom_fire",

        package = "Arms",
    } )


    spec:RegisterPack( "Arms", 20201212, [[dGeZUaqijP0JaG2eQsFssk0OaqDkakRIss6vsQMfQQUfsQAxs8ljXWqchtOAzus9mkjMgssUgskBda8nkj14KKQZbGyDiPIMhQI7jL2hsIdIKuluO8qjPGjcqLCrKuHtsjjwjszMauP2PqAOiPslfGQ0tfmvH4QauHTcqv9vaQI9k6VanyP6WelgLEmIjtQldTzk1NLIrdOtR0QbOIEnQkZMIBJk7wXVv1WrQooaslh0Zvz6uDDuSDjLVtjgpa58sswVKu08rI2pjNXZizqloMrTMcRPiU1XTUqbajUvOw1ZGxfDmd0fcFsdMHr4Wmq1qUld0LQmVOZiz4EgibZaq3PFuNvQ0Soqg2c55QClhJr89hcuS9k3YrQKbwM14wLjzZGwCmJAnfwtrCRJBDHcasCRqvwjdcJd8HziSCmgX3FQgGITNbGRwJtYMbnEKmaGQovd5ovhWJaH7dv0aqvhWfsqoweQ6XTMFv3AkSMcfnfnau1RgaktdEuNkAaOQt9QovR1Ow1PUmCCOPOObGQo1R6uTwJAvhWFj(dRs1b8YCaRyv4OJJENgvhWFj(dRQOObGQo1R6uTwJAvpM4Ubv9aWNXvD)vD6qK8CSIR6un1fWDrrdavDQx1Poaesy89hewnEQo1fIK92Fu99uDnAqh1ffnau1PEvNQ1AuR6aoou1TkoYDffnau1PEvpIfu4t1XXHvP62pu1JzenE(d5kzWSNFzKmC70yqqxGnONrYOXZizahH1G6mwgiW1r4kzaGvD7TbOdcrozNt1PIQhV6uO6usPQdWQUlWg0larX4al0jUQZJQBnfQoLuQ6UyWXlCYDcbIfCewdQvDEvDxGnOxaIIXbwOtCvNhv3kut1bmvhWYGq89Nmq(bGYGWhEGSYmim9mQ1zKmGJWAqDglde46iCLmq(3OFltH8M)oMd84KdybICYoNQZJQxDvNxvVHOlqKt25u9wvNImieF)jdsnXfy6zuRKrYaocRb1zSmqGRJWvYae5KDovNNwvxZafF)r1TQQoffRKbH47pzaIJo9mkvLrYaocRb1zSmqGRJWvYWrhngqxGnOFflaxOXYoAvNkQECvNxvx)ErJiDqlpZOVce5KDovNhvVHOZGq89NmqmOudtpJsTmsgeIV)KblcKfIcFimd4iSguNXspJcazKmieF)jdK383XCGhNCaZaocRb1zS0ZOwDgjd4iSguNXYabUocxjdSm22fPM4cSarozNt15r1JxDvNxvVAvD97fOutAqybICYoxgeIV)KbOutAqy6z0QNrYGq89NmidzXXbfBhHhWNWxgWrynOoJLEgfGKrYGq89NmC0rbc(2GSY57pzahH1G6mw6z04uKrYaocRb1zSmqGRJWvYabOaBWt1BvDRZGq89Nm81qi93cctpJgpEgjd4iSguNXYabUocxjdSm22fnkAtvGeXWv0VLr15v1byvxJSm22fYB(7yoWJtoGfg6QoVQouAqvNhv3kuO6usPQdLgu15r1TAkuDaldcX3FYaRr045pKl9mACRZizahH1G6mwgiW1r4kzGLX2U81qi93cclNle(uDQ0Q6wR68Q6Sm22fnkAtvGeXWv0VLr1PKsvhGvD97fnI0bT8mJ(kqKt25uDEAv9gIw15v1j)B0VLPqEZFhZbECYbSarozNt1PIQ3q0QoGLbH47pzG7HUyaphU8HPNrJBLmsgeIV)KbnkAtvGeXWLbCewdQZyPNrJtvzKmGJWAqDglde46iCLmaLgu15r1bakuDEvDwgB7IgfTPkqIy4k63YKbH47pz44JXyo6M1DeMEgno1Yizqi((tg(AiK(BbHzahH1G6mw6z04aqgjd4iSguNXYabUocxjdSm22LJrRXbuJIdSarH4zqi((tgi)OrUj9mACRoJKbCewdQZyzGaxhHRKbwgB7YXO14aQrXbwGOq8mieF)jdiGqcJJPNrJx9msgeIV)KbUh6Ib8C4YhMbCewdQZyPNrJdqYizahH1G6mwgiW1r4kzWfdoEXgH1Ei4BdYkUBWcocRb1QoVQouAqvNkQoaqrgeIV)KblaxOXYo60ZOwtrgjdcX3FYWzeUmGJWAqDgl9mQ1XZizqi((tgQTe)HvbczoGzahH1G6mw6zuRToJKbH47pzy5OJJENgWAlXFyvzahH1G6mw6PNbnAlmgpJKrJNrYGq89NmqakWgmd4iSguNXspJADgjdcX3FYaDgoo0KbCewdQZyPNrTsgjdcX3FYa933FYaocRb1zS0ZOuvgjd4iSguNXYabUocxjdAKLX2UqEZFhZbECYbSWqpdcX3FYaR5FnOndSQ0ZOulJKbCewdQZyzGaxhHRKbnYYyBxiV5VJ5apo5awGiNSZP6ur1bGmieF)jdSi8qiF70KEgfaYizahH1G6mwgiW1r4kzG8Vr)wMc3dDXaEoC5dlqKt25uDQO6Xlut15v1HsdQ68O6uJImieF)jdcKidc6peIJNEg1QZizahH1G6mwgiW1r4kzqJSm22fYB(7yoWJtoGf9BzuDEvDY)g9BzkCp0fd45WLpSarozNldcX3FYGzBa6hiGtgDdhoE6z0QNrYaocRb1zSmqGRJWvYGgzzSTlK383XCGhNCalm0ZGq89NmyVqK18Vo9mkajJKbCewdQZyzGaxhHRKbnYYyBxiV5VJ5apo5awyONbH47pzqgcEoumGeXyspJgNImsgWrynOoJLbcCDeUsg0ilJTDH8M)oMd84Kdyr)wgvNxvN8Vr)wMc3dDXaEoC5dlqKt25YGq89NmWknGVnOdxcFx6z04XZizahH1G6mwggHdZWohbY4cRbbbOmY4mCGAS2sWmieF)jd7CeiJlSgeeGYiJZWbQXAlbtpJg36msgWrynOoJLHr4WmOHOOTxicwdVdnzqi((tg0qu02lebRH3HM0ZOXTsgjdcX3FYaZHGRJCxgWrynOoJLEgnovLrYaocRb1zSmqGRJWvYWrhngqxGnOFflaxOXYoAvNkQECvNxvhGvDY)g9BzkSgrJN)qUce5KDovNkQECQP6usPQ7IbhVaLAsdcl4iSguR6awgeIV)KHZcI03Pb8C4YhEPNrJtTmsgWrynOoJLbcCDeUsgGYQbXA44frRVccO98ldcX3FYaKzafIV)aA2ZZGzphCeomdafs6z04aqgjd4iSguNXYabUocxjdaSQ7IbhVWj3jeiwWrynOw15v1Db2GEbikghyHoXvDEuDRqnvhWuDkPu1Db2GEbikghyHoXvDEuDRPq1PKsvhGvDxGnOxaIIXbwOtCvNkQE1Pq15v1jFnCKXl1WXbwfu1bSmieF)jdqMbui((dOzppdM9CWr4WmGacjmoMEgnUvNrYaocRb1zSmieF)jdqMbui((dOzppdM9CWr4WmC70yqqxGnONE6zGoejphR4zKmA8msgeIV)KbwXDdcEaFgpd4iSguNXspJADgjd4iSguNXYWiCygKQ5buGYbA)Jd(2G0FlimdcX3FYGunpGcuoq7FCW3gK(BbHPNrTsgjd4iSguNXYabUocxjdUyWXl2iS2dbFBqwXDdwWrynOw1PKsvVAvDxm44fBew7HGVniR4Ubl4iSguR68Q6(YHG(dQxu1PIQhNAuKbH47pzGd5EyvGVnOHHSAqnefUl9mkvLrYaocRb1zSmqGRJWvYGlgC8IncR9qW3gKvC3GfCewdQvDkPu1DXGJx4K7ecel4iSguR68Q6(YHG(dQxu1PIQBDCkuDkPu1DXGJxG4Ol4iSguR68Q6aSQ7lhc6pOErvNkQU1XPq1PKsv3xoe0Fq9IQopQECQIAQoGLbH47pzOHrG6vgW3guQMi8DGPNEgqaHeghZiz04zKmieF)jdAu0MQajIHld4iSguNXspJADgjd4iSguNXYabUocxjdqKt25uDEAvDndu89hv3QQ6uuSsgeIV)Kbio60ZOwjJKbCewdQZyzGaxhHRKbO0GQopQoaqHQZRQdWQE1Q6UyWXlAu0MQajIHRGJWAqTQtjLQolJTDrJI2ufirmCf9BzuDaldcX3FYWXhJXC0nR7im9mkvLrYaocRb1zSmqGRJWvYa5FJ(TmfYB(7yoWJtoGfiYj7CQopQE1vDEv9gIUarozNt1BvDkYGq89Nmi1exGPNrPwgjd4iSguNXYabUocxjdSm22fPM4cSarozNt15r1JxDvNxvVAvD97fOutAqybICYoxgeIV)KbOutAqy6zuaiJKbH47pzG8daLbHp8azLzqygWrynOoJLEg1QZizahH1G6mwgiW1r4kz4OJgdOlWg0VIfGl0yzhTQtfvpUQZRQRFVOrKoOLNz0xbICYoNQZJQ3q0zqi((tgiguQHPNrREgjdcX3FYGfbYcrHpeMbCewdQZyPNrbizKmieF)jdK383XCGhNCaZaocRb1zS0ZOXPiJKbCewdQZyzGaxhHRKbnYYyBxiV5VJ5apo5awyOR6usPQZYyBxogTghqnkoWcefIR6usPQdLgu1PIQdauldcX3FYa5hnYnPNrJhpJKbCewdQZyzGaxhHRKbcqb2GNQ3Q6wNbH47pz4RHq6VfeMEgnU1zKmieF)jdYqwCCqX2r4b8j8LbCewdQZyPNrJBLmsgeIV)KHJokqW3gKvoF)jd4iSguNXspJgNQYizahH1G6mwgiW1r4kzGLX2UOrrBQcKigUI(TmQoVQouAqvNhvNAuKbH47pzG1iA88hYLEgno1YizahH1G6mwgiW1r4kzq)ErJiDqlpZOVce5KDovNNwvVHOZGq89NmW9qxmGNdx(W0ZOXbGmsgWrynOoJLbcCDeUsgGsdQ68O6uffzqi((tgo(ymMJUzDhHPNrJB1zKmieF)jdFnes)TGWmGJWAqDgl9mA8QNrYGq89Nmq(rJCtgWrynOoJLEgnoajJKbH47pzabesyCmd4iSguNXspJAnfzKmieF)jd1wI)WQaHmhWmGJWAqDgl9mQ1XZizqi((tgwo64O3PbS2s8hwvgWrynOoJLE6zaOqYiz04zKmGJWAqDglde46iCLmaLgu15r1bakuDEvDwgB7IgfTPkqIy4k63YKbH47pz44JXyo6M1DeMEg16msgeIV)KbYpauge(WdKvMbHzahH1G6mw6zuRKrYaocRb1zSmqGRJWvYa5FJ(TmfYB(7yoWJtoGfiYj7CQopQE8mieF)jdsnXfy6zuQkJKbCewdQZyzGaxhHRKb97fnI0bT8mJ(kqKt25uDEAv9gIodcX3FYaXGsnm9mk1Yizqi((tgSiqwik8HWmGJWAqDgl9mkaKrYGq89NmidzXXbfBhHhWNWxgWrynOoJLEg1QZizqi((tgo6OabFBqw589NmGJWAqDgl9mA1Zizqi((tgynIgp)HCzahH1G6mw6zuasgjdcX3FYauQjnimd4iSguNXspJgNImsgeIV)KbYB(7yoWJtoGzahH1G6mw6z04XZizahH1G6mwgiW1r4kzaICYoNQZtRQRzGIV)O6wvvNIIvuDEvDwgB7Yzbr670aEoC5dVcd9mieF)jdqC0PNrJBDgjdcX3FYaXGsnmd4iSguNXspJg3kzKmGJWAqDglde46iCLmWYyBxolisFNgWZHlF4vyOR6usPQRFVOrKoOLNz0xbICYoNQZJQ3q0QoVQE1Q6UyWXledk1WcocRb1zqi((tg4EOlgWZHlFy6z04uvgjd4iSguNXYabUocxjdUyWXlAik6ryAa6fCewdQZGq89Nm81qi93cctpJgNAzKmieF)jdKF0i3KbCewdQZyPNrJdazKmGJWAqDglde46iCLmWYyBxolisFNgWZHlF4vyONbH47pzabesyCm9mACRoJKbH47pz4RHq6VfeMbCewdQZyPNrJx9msgeIV)KblaxOXYo6mGJWAqDgl9mACasgjdcX3FYqTL4pSkqiZbmd4iSguNXspJAnfzKmieF)jdlhDC070awBj(dRkd4iSguNXsp90ZqneE7pzuRPWAkIBDCkkXZGfbo70CzWQWr)HoQvDQP6cX3FuDZE(vu0YaD4BVgmdaOQt1qUt1b8iq4(qfnau1bCHeKJfHQECR5x1TMcRPqrtrdav9QbGY0Gh1PIgaQ6uVQt1AnQvDQldhhAkkAaOQt9QovR1Ow1b8xI)WQuDaVmhWkwfo64O3Pr1b8xI)WQkkAaOQt9QovR1Ow1JjUBqvpa8zCv3FvNoejphR4QovtDbCxu0aqvN6vDQdaHegF)bHvJNQtDHizV9hvFpvxJg0rDrrdavDQx1PATg1QoGJdvDRIJCxrrdavDQx1Jybf(uDCCyvQU9dv9ygrJN)qUIIMIgaQ6uhacjmoQvDw0(HOQtEowXvDwSzNRO6unHG09t1NFOEGcKZMXO6cX3Fov)htvffnH47pxHoejphR41BRWkUBqWd4Z4kAcX3FUcDisEowXR3wH5qW1ro(hHdBLQ5buGYbA)Jd(2G0Fliurti((ZvOdrYZXkE92kCi3dRc8TbnmKvdQHOWD8V2TUyWXl2iS2dbFBqwXDdwWrynOMskRwxm44fBew7HGVniR4Ubl4iSguZRVCiO)G6fPsCQrHIMq89NRqhIKNJv86TvAyeOELb8TbLQjcFhi)RDRlgC8IncR9qW3gKvC3GfCewdQPKsxm44fo5oHaXcocRb186lhc6pOErQyDCkOKsxm44fio6cocRb18cW(YHG(dQxKkwhNckP0xoe0Fq9I8eNQOgGPOPObGQo1bGqcJJAvhRHWQuDF5qv3bIQUq8hQ67P6snzncRblkAcX3FUwcqb2GkAcX3FU6TvOZWXHgfnH47px92k0FF)rrti((ZvVTcR5FnOndSk(x7wnYYyBxiV5VJ5apo5awyOROjeF)5Q3wHfHhc5BNg(x7wnYYyBxiV5VJ5apo5awGiNSZrfaqrti((ZvVTIajYGG(dH448V2TK)n63Yu4EOlgWZHlFybICYohvIxOgVqPb5HAuOOjeF)5Q3wXSna9deWjJUHdhN)1UvJSm22fYB(7yoWJtoGf9Bz4L8Vr)wMc3dDXaEoC5dlqKt25u0eIV)C1BRyVqK18VM)1UvJSm22fYB(7yoWJtoGfg6kAcX3FU6TvKHGNdfdirmg(x7wnYYyBxiV5VJ5apo5awyOROjeF)5Q3wHvAaFBqhUe(o(x7wnYYyBxiV5VJ5apo5aw0VLHxY)g9BzkCp0fd45WLpSarozNtrti((ZvVTcZHGRJC8pch2UZrGmUWAqqakJmodhOgRTeurti((ZvVTcZHGRJC8pch2QHOOTxicwdVdnkAcX3FU6TvyoeCDK7u0eIV)C1BRCwqK(onGNdx(WJ)1U9OJgdOlWg0VIfGl0yzhnvIZlat(3OFltH1iA88hYvGiNSZrL4uJskDXGJxGsnPbHfCewdQbmfnH47px92kqMbui((dOzpN)r4WwGcH)1UfkRgeRHJxeT(kiG2ZpfnH47px92kqMbui((dOzpN)r4WweqiHXr(x7wa2fdoEHtUtiqSGJWAqnVUaBqVaefJdSqN48yfQbyusPlWg0larX4al0jopwtbLucWUaBqVaefJdSqN4uP6uWl5RHJmEPgooWQGaMIMq89NREBfiZakeF)b0SNZ)iCy7TtJbbDb2GUIMIMq89NRGacjmo2QrrBQcKigofnH47pxbbesyCSEBfioA(x7wiYj7C80QzGIV)yvPOyffnH47pxbbesyCSEBLJpgJ5OBw3ri)RDluAqEaak4fGRwxm44fnkAtvGeXWvWrynOMskzzSTlAu0MQajIHROFldGPOjeF)5kiGqcJJ1BRi1exG8V2TK)n63YuiV5VJ5apo5awGiNSZXt15THOlqKt25APqrti((ZvqaHeghR3wbk1KgeY)A3YYyBxKAIlWce5KDoEIxDERw97fOutAqybICYoNIMq89NRGacjmowVTc5hakdcF4bYkZGqfnH47pxbbesyCSEBfIbLAi)RD7rhngqxGnOFflaxOXYoAQeNx97fnI0bT8mJ(kqKt254PHOv0eIV)CfeqiHXX6TvSiqwik8HqfnH47pxbbesyCSEBfYB(7yoWJtoGkAcX3FUcciKW4y92kKF0i3W)A3QrwgB7c5n)Dmh4XjhWcdDkPKLX2UCmAnoGAuCGfikeNskHsdsfaGAkAcX3FUcciKW4y92kFnes)TGq(x7wcqb2GxR1kAcX3FUcciKW4y92kYqwCCqX2r4b8j8POjeF)5kiGqcJJ1BRC0rbc(2GSY57pkAcX3FUcciKW4y92kSgrJN)qo(x7wwgB7IgfTPkqIy4k63YWluAqEOgfkAcX3FUcciKW4y92kCp0fd45WLpK)1Uv)ErJiDqlpZOVce5KDoEABiAfnH47pxbbesyCSEBLJpgJ5OBw3ri)RDluAqEOkku0eIV)CfeqiHXX6Tv(AiK(BbHkAcX3FUcciKW4y92kKF0i3OOjeF)5kiGqcJJ1BRGacjmoQOjeF)5kiGqcJJ1BRuBj(dRceYCav0eIV)CfeqiHXX6Tvwo64O3PbS2s8hwLIMIMq89NRauiThFmgZr3SUJq(x7wO0G8aauWllJTDrJI2ufirmCf9Bzu0eIV)CfGcPEBfYpauge(WdKvMbHkAcX3FUcqHuVTIutCbY)A3s(3OFltH8M)oMd84KdybICYohpXv0eIV)CfGcPEBfIbLAi)RDR(9Igr6GwEMrFfiYj7C802q0kAcX3FUcqHuVTIfbYcrHpeQOjeF)5kafs92kYqwCCqX2r4b8j8POjeF)5kafs92khDuGGVniRC((JIMq89NRaui1BRWAenE(d5u0eIV)CfGcPEBfOutAqOIMq89NRaui1BRqEZFhZbECYburti((ZvakK6TvG4O5FTBHiNSZXtRMbk((JvLIIv4LLX2UCwqK(onGNdx(WRWqxrti((ZvakK6TviguQHkAcX3FUcqHuVTc3dDXaEoC5d5FTBzzSTlNfePVtd45WLp8km0PKs97fnI0bT8mJ(kqKt254PHO5TADXGJxiguQHfCewdQv0eIV)CfGcPEBLVgcP)wqi)RDRlgC8IgIIEeMgGEbhH1GAfnH47pxbOqQ3wH8Jg5gfnH47pxbOqQ3wbbesyCK)1ULLX2UCwqK(onGNdx(WRWqxrti((ZvakK6Tv(AiK(BbHkAcX3FUcqHuVTIfGl0yzhTIMq89NRaui1BRuBj(dRceYCav0eIV)CfGcPEBLLJoo6DAaRTe)HvPOPOjeF)5k3onge0fyd6TKFaOmi8HhiRmdc5FTBby7TbOdcrozNJkXRofusja7cSb9cqumoWcDIZJ1uqjLUyWXlCYDcbIfCewdQ51fyd6fGOyCGf6eNhRqnadWu0eIV)CLBNgdc6cSb96TvKAIlq(x7wY)g9BzkK383XCGhNCalqKt254P682q0fiYj7CTuOOjeF)5k3onge0fyd61BRaXrZ)A3crozNJNwndu89hRkffROOjeF)5k3onge0fyd61BRqmOud5FTBp6OXa6cSb9Ryb4cnw2rtL48QFVOrKoOLNz0xbICYohpneTIMq89NRC70yqqxGnOxVTIfbYcrHpeQOjeF)5k3onge0fyd61BRqEZFhZbECYburti((ZvUDAmiOlWg0R3wbk1KgeY)A3YYyBxKAIlWce5KDoEIxDERw97fOutAqybICYoNIMq89NRC70yqqxGnOxVTImKfhhuSDeEaFcFkAcX3FUYTtJbbDb2GE92khDuGGVniRC((JIMq89NRC70yqqxGnOxVTYxdH0FliK)1ULauGn41ATIMq89NRC70yqqxGnOxVTcRr045pKJ)1ULLX2UOrrBQcKigUI(Tm8cWAKLX2UqEZFhZbECYbSWqNxO0G8yfkOKsO0G8y1uaykAcX3FUYTtJbbDb2GE92kCp0fd45WLpK)1ULLX2U81qi93cclNle(OsR18YYyBx0OOnvbsedxr)wgkPeG1Vx0ish0YZm6RarozNJN2gIMxY)g9BzkK383XCGhNCalqKt25OsdrdykAcX3FUYTtJbbDb2GE92kAu0MQajIHtrti((ZvUDAmiOlWg0R3w54JXyo6M1DeY)A3cLgKhaGcEzzSTlAu0MQajIHROFlJIMq89NRC70yqqxGnOxVTYxdH0Fliurti((ZvUDAmiOlWg0R3wH8Jg5g(x7wwgB7YXO14aQrXbwGOqCfnH47px52PXGGUaBqVEBfeqiHXr(x7wwgB7YXO14aQrXbwGOqCfnH47px52PXGGUaBqVEBfUh6Ib8C4YhQOjeF)5k3onge0fyd61BRyb4cnw2rZ)A36IbhVyJWApe8Tbzf3nybhH1GAEHsdsfaGcfnH47px52PXGGUaBqVEBLZiCkAcX3FUYTtJbbDb2GE92k1wI)WQaHmhqfnH47px52PXGGUaBqVEBLLJoo6DAaRTe)HvLHJosYOwD80tpt]] )


end
