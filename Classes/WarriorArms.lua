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


    spec:RegisterPack( "Arms", 20201210.1, [[dOKuVaqijPQhjLOnHQ4tirXOKsQtjLsRcvvXRKunlkj3cjvTlj(LKyyiHJjKwMKKNjjLPHePRHQkBtkHVHQQACsP4CiryDsjjZdvP7Pc7djLdIevluO6HirKjkLKYfrIO(isuQojsQyLiLzkjvyNcLHIQQ0srsL8ubtviUQusQ2ksuYxrsLASirPSxr)vLgSuDyIfJspgXKj1LH2mL6ZsXOvrNwPvljv0Rrvz2uCBuz3k(TQgos1XLsILd65atNQRJITlP8DkX4Ls15PKA9ssLMpsY(j5mAgjdAXXmwvuuffrRkkfLOuckO0O8FgCRPJzGUq4tAWmmchMbkhYbYaDXAZl6msgapdKGz40D6GwvLknRFYWwipxfWYXyeF)HafBVcy5ivYalZACQZKSzqloMXQIIQOiAvrPOeLsqbLgndcJF(WmewogJ47pusqX2ZW5Q14KSzqJasgAPQt5qoGQtDlq4(qfTwQ6TAib5yrOQhLcRu9QOOkku0u0APQtjDktdcAvkATu1PEvNY1AuR68xgoo0uu0APQt9QoLR1Ow1PSwI)qRvDQlgWzfQdhDC070O6uwlXFO1ffTwQ6uVQt5AnQv94I7gu1dNpJR6(R60Hi55yfx1PC(B1rrrRLQo1R6uYTJegF)bHugGQZFHizb7pQ(cuDnAqh1ffTwQ6uVQt5AnQv9wDaQ6uhh5affTwQ6uVQhXck8P644qRvD7hQ6XnIgb(d5kzWSahKrYayNgdEDb2GEgjJfnJKbCewdQZ4zGaxhHRKHwR62BZPFHiNSdq1PMQhTnuO6urLQ3Av3fyd6Ltum(zHoXvDEv9QOq1PIkv3fdoEHtaaHaXcocRb1QopQUlWg0lNOy8ZcDIR68Q6vJFQEBv92MbH47pzG8tRWGWhcUSYmim9mwvzKmGJWAqDgpde46iCLmq(3OFltH8MhayaxaNaolqKt2bO68Q6Tr15r1Bi6ce5KDaQ(HQtrgeIV)KbPM4cm9mw1YizahH1G6mEgiW1r4kzaICYoavN3dvxZafF)r15pQofLQLbH47pzaIJo9mgLMrYaocRb1z8mqGRJWvYaGoAmxxGnOdkwoxOXYoAvNAQEuvNhvx)ErJi9RLNz0Gce5KDaQoVQEdrNbH47pzGyqPgMEgJFzKmieF)jdweilef(qygWrynOoJNEgRfzKmieF)jdK38aad4c4eWzgWrynOoJNEgJ)ZizahH1G6mEgiW1r4kzGLX2Ui1exGfiYj7auDEv9OTr15r1REvx)Ebk1KgewGiNSdidcX3FYauQjnim9mwBYizqi((tgKHS44xX2ri48j8LbCewdQZ4PNXOezKmieF)jda6OaVV9Lva((tgWrynOoJNEglkfzKmGJWAqDgpde46iCLmqofydcu9dvVQmieF)jdFnes)TGW0ZyrJMrYaocRb1z8mqGRJWvYalJTDrJI2y9LigUI(TmQopQERvDnYYyBxiV5bagWfWjGZcdDvNhvhknOQZRQxnkuDQOs1HsdQ68Q68pfQEBZGq89NmWAenc8hYLEglAvzKmGJWAqDgpde46iCLmWYyBx(AiK(BbHfGle(uDQDO6vP68O6Sm22fnkAJ1xIy4k63YO6urLQ3Avx)ErJi9RLNz0Gce5KDaQoVhQEdrR68O6K)n63YuiV5bagWfWjGZce5KDaQo1u9gIw1BBgeIV)KbUh6I5cC4YhMEglA1Yizqi((tg0OOnwFjIHld4iSguNXtpJfLsZizahH1G6mEgiW1r4kzaknOQZRQ3ckuDEuDwgB7IgfTX6lrmCf9BzYGq89Nma4JXya0nR7im9mwu(LrYGq89Nm81qi93ccZaocRb1z80ZyrBrgjd4iSguNXZabUocxjdSm22faJwJZvJIFwGOq8mieF)jdKF0i3KEglk)NrYaocRb1z8mqGRJWvYalJTDbWO14C1O4NfikepdcX3FYa2osyCm9mw02KrYGq89NmW9qxmxGdx(WmGJWAqDgp9mwukrgjd4iSguNXZabUocxjdUyWXl2iS2dVV9LvC3GfCewdQvDEuDO0GQo1u9wqrgeIV)KblNl0yzhD6zSQOiJKbH47pzayeUmGJWAqDgp9mwvrZizqi((tgQTe)HwFHmGZmGJWAqDgp9mwvvLrYGq89NmSC0XrVtZT2s8hADgWrynOoJNE6zqJ2cJXZizSOzKmieF)jdKtb2GzahH1G6mE6zSQYizqi((tgOZWXHMmGJWAqDgp9mw1Yizqi((tgO)((tgWrynOoJNEgJsZizahH1G6mEgiW1r4kzqJSm22fYBEaGbCbCc4SWqpdcX3FYaR5F91MbAD6zm(LrYaocRb1z8mqGRJWvYGgzzSTlK38aad4c4eWzbICYoavNAQElYGq89NmWIqac5BNM0ZyTiJKbCewdQZ4zGaxhHRKbY)g9BzkCp0fZf4WLpSarozhGQtnvpAHFQopQouAqvNxvNFuKbH47pzqGezWR)qioE6zm(pJKbCewdQZ4zGaxhHRKbnYYyBxiV5bagWfWjGZI(TmQopQo5FJ(TmfUh6I5cC4YhwGiNSdidcX3FYGzBoDWT6Kr3WHJNEgRnzKmGJWAqDgpde46iCLmOrwgB7c5npaWaUaobCwyONbH47pzWEHiR5FD6zmkrgjd4iSguNXZabUocxjdAKLX2UqEZdamGlGtaNfg6zqi((tgKHGahkMlrmM0ZyrPiJKbCewdQZ4zGaxhHRKbnYYyBxiV5bagWfWjGZI(TmQopQo5FJ(TmfUh6I5cC4YhwGiNSdidcX3FYaR0CF7RdxcFG0ZyrJMrYaocRb1z8mmchMHDaeiJlSg82kmY4mCxnwBjygeIV)KHDaeiJlSg82kmY4mCxnwBjy6zSOvLrYaocRb1z8mmchMbnefT9cXBneaqtgeIV)KbnefT9cXBneaqt6zSOvlJKbH47pzGbG31roqgWrynOoJNEglkLMrYaocRb1z8mqGRJWvYaGoAmxxGnOdkwoxOXYoAvNAQEuvNhvV1QUlgC8cuQjniSGJWAqTQtfvQo5FJ(TmfwJOrG)qUce5KDaQo1u9OvP6TndcX3FYaWcI03P5cC4YhcspJfLFzKmGJWAqDgpde46iCLmaLvFXA44frRbfS9f4GmieF)jdqM5keF)5AwGNbZc87iCygofs6zSOTiJKbCewdQZ4zGaxhHRKHwR6UyWXlCcaieiwWrynOw15r1Db2GE5efJFwOtCvNxvVA8t1BRQtfvQUlWg0lNOy8ZcDIR68Q6vrHQtfvQERvDxGnOxorX4Nf6ex1PMQ3gkuDEuDYxdhz8snC8tRHQEBZGq89NmazMRq89NRzbEgmlWVJWHzaBhjmoMEglk)NrYaocRb1z8mieF)jdqM5keF)5AwGNbZc87iCyga70yWRlWg0tp9mqhIKNJv8msglAgjdcX3FYaR4UbVGZNXZaocRb1z80ZyvLrYaocRb1z8mmchMbP6cofOaU2)433(s)TGWmieF)jds1fCkqbCT)XVV9L(BbHPNXQwgjd4iSguNXZabUocxjdUyWXl2iS2dVV9LvC3GfCewdQvDQOs1REv3fdoEXgH1E49TVSI7gSGJWAqTQZJQ7lhE9)Qxu1PMQhLFuKbH47pzGd5EO133(AyiR(QHOWbspJrPzKmGJWAqDgpde46iCLm4IbhVyJWAp8(2xwXDdwWrynOw1PIkv3fdoEHtaaHaXcocRb1QopQUVC41)RErvNAQEvrPq1PIkv3fdoEbIJUGJWAqTQZJQ3Av3xo86)vVOQtnvVQOuO6urLQ7lhE9)Qxu15v1JsP8t1BBgeIV)KHggbQxzUV9vQUi89Z0tpdy7iHXXmsglAgjdcX3FYGgfTX6lrmCzahH1G6mE6zSQYizahH1G6mEgiW1r4kzaICYoavN3dvxZafF)r15pQofLQLbH47pzaIJo9mw1YizahH1G6mEgiW1r4kzaknOQZRQ3ckuDEu9wR6vVQ7IbhVOrrBS(sedxbhH1GAvNkQuDwgB7IgfTX6lrmCf9Bzu92MbH47pzaWhJXaOBw3ry6zmknJKbCewdQZ4zGaxhHRKbY)g9BzkK38aad4c4eWzbICYoavNxvVnQopQEdrxGiNSdq1puDkYGq89Nmi1exGPNX4xgjd4iSguNXZabUocxjdSm22fPM4cSarozhGQZRQhTnQopQE1R663lqPM0GWce5KDazqi((tgGsnPbHPNXArgjdcX3FYa5NwHbHpeCzLzqygWrynOoJNEgJ)ZizahH1G6mEgiW1r4kzaqhnMRlWg0bflNl0yzhTQtnvpQQZJQRFVOrK(1YZmAqbICYoavNxvVHOZGq89NmqmOudtpJ1MmsgeIV)KblcKfIcFimd4iSguNXtpJrjYizqi((tgiV5bagWfWjGZmGJWAqDgp9mwukYizahH1G6mEgiW1r4kzqJSm22fYBEaGbCbCc4SWqx1PIkvNLX2Uay0ACUAu8ZcefIR6urLQdLgu1PMQ3c(LbH47pzG8Jg5M0ZyrJMrYaocRb1z8mqGRJWvYa5uGniq1pu9QYGq89Nm81qi93cctpJfTQmsgeIV)Kbzilo(vSDecoFcFzahH1G6mE6zSOvlJKbH47pzaqhf49TVScW3FYaocRb1z80ZyrP0msgWrynOoJNbcCDeUsgyzSTlAu0gRVeXWv0VLr15r1HsdQ68Q68JImieF)jdSgrJa)HCPNXIYVmsgWrynOoJNbcCDeUsg0Vx0is)A5zgnOarozhGQZ7HQ3q0zqi((tg4EOlMlWHlFy6zSOTiJKbCewdQZ4zGaxhHRKbO0GQoVQoLsrgeIV)KbaFmgdGUzDhHPNXIY)zKmieF)jdFnes)TGWmGJWAqDgp9mw02KrYGq89Nmq(rJCtgWrynOoJNEglkLiJKbH47pzaBhjmoMbCewdQZ4PNXQIImsgeIV)KHAlXFO1xid4md4iSguNXtpJvv0msgeIV)KHLJoo6DAU1wI)qRZaocRb1z80tpdNcjJKXIMrYaocRb1z8mqGRJWvYauAqvNxvVfuO68O6Sm22fnkAJ1xIy4k63YKbH47pzaWhJXaOBw3ry6zSQYizqi((tgi)0kmi8HGlRmdcZaocRb1z80ZyvlJKbCewdQZ4zGaxhHRKbY)g9BzkK38aad4c4eWzbICYoavNxvpAgeIV)KbPM4cm9mgLMrYaocRb1z8mqGRJWvYG(9Igr6xlpZObfiYj7auDEpu9gIodcX3FYaXGsnm9mg)Yizqi((tgSiqwik8HWmGJWAqDgp9mwlYizqi((tgKHS44xX2ri48j8LbCewdQZ4PNX4)msgeIV)KbaDuG33(YkaF)jd4iSguNXtpJ1MmsgeIV)KbwJOrG)qUmGJWAqDgp9mgLiJKbH47pzak1KgeMbCewdQZ4PNXIsrgjdcX3FYa5npaWaUaobCMbCewdQZ4PNXIgnJKbCewdQZ4zGaxhHRKbiYj7auDEpuDndu89hvN)O6uuQMQZJQZYyBxawqK(onxGdx(qqHHEgeIV)Kbio60ZyrRkJKbH47pzGyqPgMbCewdQZ4PNXIwTmsgWrynOoJNbcCDeUsgyzSTlalisFNMlWHlFiOWqx1PIkvx)ErJi9RLNz0Gce5KDaQoVQEdrR68O6vVQ7IbhVqmOudl4iSguNbH47pzG7HUyUahU8HPNXIsPzKmGJWAqDgpde46iCLm4IbhVOHOOhHP50l4iSguNbH47pz4RHq6VfeMEglk)Yizqi((tgi)OrUjd4iSguNXtpJfTfzKmGJWAqDgpde46iCLmWYyBxawqK(onxGdx(qqHHEgeIV)KbSDKW4y6zSO8FgjdcX3FYWxdH0Flimd4iSguNXtpJfTnzKmieF)jdwoxOXYo6mGJWAqDgp9mwukrgjdcX3FYqTL4p06lKbCMbCewdQZ4PNXQIImsgeIV)KHLJoo6DAU1wI)qRZaocRb1z80tp9mudHG9NmwvuuffrRkkfzWIaNDAazG6MYPUIrDIrzVvP6QEKtu1xo6p0vD7hQ6ugnAlmgNYO6qSvywiQvDWZHQUW4pN4Ow1jNY0GGIIw1XoOQhLsBvQoL0p1qOJAvNY4IbhVqzJYO6(R6ugxm44fkBfCewdQPmQERJ2EBlkAkAuho6p0rTQZpvxi((JQBwGdkkAzGo8TxdMHwQ6uoKdO6u3ceUpurRLQERgsqoweQ6rPWkvVkkQIcfnfTwQ6usNY0GGwLIwlvDQx1PCTg1Qo)LHJdnffTwQ6uVQt5AnQvDkRL4p0AvN6IbCwH6Wrhh9onQoL1s8hADrrRLQo1R6uUwJAvpU4Ubv9W5Z4QU)QoDisEowXvDkN)wDuu0APQt9QoLC7iHX3FqiLbO68xiswW(JQVavxJg0rDrrRLQo1R6uUwJAvVvhGQo1XroqrrRLQo1R6rSGcFQooo0Av3(HQECJOrG)qUIIMIwlvDk52rcJJAvNfTFiQ6KNJvCvNfB2buuDkNqq6oq1NFO(tbYzZyuDH47pav)hJ1ffnH47pGcDisEowXRFuHvC3GxW5Z4kAcX3Faf6qK8CSIx)OcdaVRJCwnchEivxWPafW1(h)(2x6VfeQOjeF)buOdrYZXkE9JkCi3dT((2xddz1xnefoGvR9HlgC8IncR9W7BFzf3nybhH1GAQOQ6DXGJxSryThEF7lR4Ubl4iSguZJVC41)RErQfLFuOOjeF)buOdrYZXkE9JknmcuVYCF7RuDr47NwT2hUyWXl2iS2dVV9LvC3GfCewdQPIkxm44fobaecel4iSguZJVC41)RErQvvukOIkxm44fio6cocRb180AF5WR)x9IuRQOuqfv(YHx)V6f5nkLYV2QOPO1svNsUDKW4Ow1XAi0Av3xou19tu1fI)qvFbQUutwJWAWIIMq89hWb5uGnOIMq89hq9Jk0z44qJIMq89hq9Jk0FF)rrti((dO(rfwZ)6Rnd0ARw7dnYYyBxiV5bagWfWjGZcdDfnH47pG6hvyriaH8TtJvR9HgzzSTlK38aad4c4eWzbICYoaQ1cfnH47pG6hveirg86peIJB1AFq(3OFltH7HUyUahU8HfiYj7aOw0c)4bkniV8JcfnH47pG6hvmBZPdUvNm6goCCRw7dnYYyBxiV5bagWfWjGZI(Tm8q(3OFltH7HUyUahU8HfiYj7au0eIV)aQFuXEHiR5FTvR9HgzzSTlK38aad4c4eWzHHUIMq89hq9JkYqqGdfZLigJvR9HgzzSTlK38aad4c4eWzHHUIMq89hq9JkSsZ9TVoCj8bSATp0ilJTDH8MhayaxaNaol63YWd5FJ(TmfUh6I5cC4YhwGiNSdqrti((dO(rfgaExh5SAeo8yhabY4cRbVTcJmod3vJ1wcQOjeF)bu)OcdaVRJCwnchEOHOOTxiERHaaAu0eIV)aQFuHbG31roGIMq89hq9JkalisFNMlWHlFiWQ1(aqhnMRlWg0bflNl0yzhn1IYtRDXGJxGsnPbHurf5FJ(TmfwJOrG)qUce5KDaulAvTvrti((dO(rfiZCfIV)CnlWTAeo84uiwT2hqz1xSgoEr0AqbBFboqrti((dO(rfiZCfIV)CnlWTAeo8aBhjmoA1AF0Axm44fobaecel4iSguZJlWg0lNOy8ZcDIZB14xBPIkxGnOxorX4Nf6eN3QOGkQATlWg0lNOy8ZcDItT2qbpKVgoY4LA44NwdBRIMq89hq9JkqM5keF)5AwGB1iC4byNgdEDb2GUIMIMq89hqbBhjmoEOrrBS(sedNIMq89hqbBhjmow)OcehTvR9be5KDa8EOzGIV)WFOOunfnH47pGc2osyCS(rfaFmgdGUzDhHwT2hqPb5TfuWtRRExm44fnkAJ1xIy4k4iSgutfvSm22fnkAJ1xIy4k63Y0wfnH47pGc2osyCS(rfPM4c0Q1(G8Vr)wMc5npaWaUaobCwGiNSdG32WtdrxGiNSd4GcfnH47pGc2osyCS(rfOutAqOvR9blJTDrQjUalqKt2bWB02Wt1RFVaLAsdclqKt2bOOjeF)buW2rcJJ1pQq(Pvyq4dbxwzgeQOjeF)buW2rcJJ1pQqmOudTATpa0rJ56cSbDqXY5cnw2rtTO8OFVOrK(1YZmAqbICYoaEBiAfnH47pGc2osyCS(rflcKfIcFiurti((dOGTJeghRFuH8MhayaxaNaov0eIV)aky7iHXX6hvi)OrUXQ1(qJSm22fYBEaGbCbCc4SWqNkQyzSTlagTgNRgf)SarH4urfuAqQ1c(POjeF)buW2rcJJ1pQ81qi93ccTATpiNcSbbhvPOjeF)buW2rcJJ1pQidzXXVITJqW5t4trti((dOGTJeghRFubqhf49TVScW3Fu0eIV)aky7iHXX6hvynIgb(d5SATpyzSTlAu0gRVeXWv0VLHhO0G8Ypku0eIV)aky7iHXX6hv4EOlMlWHlFOvR9H(9Igr6xlpZObfiYj7a49OHOv0eIV)aky7iHXX6hva8Xyma6M1DeA1AFaLgKxkLcfnH47pGc2osyCS(rLVgcP)wqOIMq89hqbBhjmow)Oc5hnYnkAcX3FafSDKW4y9Jky7iHXrfnH47pGc2osyCS(rLAlXFO1xid4urti((dOGTJeghRFuz5OJJENMBTL4p0AfnfnH47pGYPqoa8Xyma6M1DeA1AFaLgK3wqbpSm22fnkAJ1xIy4k63YOOjeF)buofs9JkKFAfge(qWLvMbHkAcX3FaLtHu)OIutCbA1AFq(3OFltH8MhayaxaNaolqKt2bWBufnH47pGYPqQFuHyqPgA1AFOFVOrK(1YZmAqbICYoaEpAiAfnH47pGYPqQFuXIazHOWhcv0eIV)akNcP(rfzilo(vSDecoFcFkAcX3FaLtHu)OcGokW7BFzfGV)OOjeF)buofs9JkSgrJa)HCkAcX3FaLtHu)OcuQjniurti((dOCkK6hviV5bagWfWjGtfnH47pGYPqQFubIJ2Q1(aICYoaEp0mqX3F4puuQgpSm22fGfePVtZf4WLpeuyOROjeF)buofs9Jkedk1qfnH47pGYPqQFuH7HUyUahU8HwT2hSm22fGfePVtZf4WLpeuyOtfv63lAePFT8mJguGiNSdG3gIMNQ3fdoEHyqPgwWrynOwrti((dOCkK6hv(AiK(BbHwT2hUyWXlAik6ryAo9cocRb1kAcX3FaLtHu)Oc5hnYnkAcX3FaLtHu)Oc2osyC0Q1(GLX2UaSGi9DAUahU8HGcdDfnH47pGYPqQFu5RHq6VfeQOjeF)buofs9JkwoxOXYoAfnH47pGYPqQFuP2s8hA9fYaov0eIV)akNcP(rLLJoo6DAU1wI)qRv0u0eIV)akGDAm41fyd6hKFAfge(qWLvMbHwT2hT2EBo9le5KDaulABOGkQATlWg0lNOy8ZcDIZBvuqfvUyWXlCcaieiwWrynOMhxGnOxorX4Nf6eN3QXV22wfnH47pGcyNgdEDb2GE9JksnXfOvR9b5FJ(TmfYBEaGbCbCc4SarozhaVTHNgIUarozhWbfkAcX3FafWong86cSb96hvG4OTATpGiNSdG3dndu89h(dfLQPOjeF)bua70yWRlWg0RFuHyqPgA1AFaOJgZ1fyd6GILZfASSJMAr5r)ErJi9RLNz0Gce5KDa82q0kAcX3FafWong86cSb96hvSiqwik8HqfnH47pGcyNgdEDb2GE9JkK38aad4c4eWPIMq89hqbStJbVUaBqV(rfOutAqOvR9blJTDrQjUalqKt2bWB02Wt1RFVaLAsdclqKt2bOOjeF)bua70yWRlWg0RFurgYIJFfBhHGZNWNIMq89hqbStJbVUaBqV(rfaDuG33(YkaF)rrti((dOa2PXGxxGnOx)OYxdH0Fli0Q1(GCkWgeCuLIMq89hqbStJbVUaBqV(rfwJOrG)qoRw7dwgB7IgfTX6lrmCf9Bz4P1AKLX2UqEZdamGlGtaNfg68aLgK3QrbvubLgKx(NI2QOjeF)bua70yWRlWg0RFuH7HUyUahU8HwT2hSm22LVgcP)wqyb4cHpQDufpSm22fnkAJ1xIy4k63YqfvTw)ErJi9RLNz0Gce5KDa8E0q08q(3OFltH8MhayaxaNaolqKt2bqTgIUTkAcX3FafWong86cSb96hv0OOnwFjIHtrti((dOa2PXGxxGnOx)OcGpgJbq3SUJqRw7dO0G82ck4HLX2UOrrBS(sedxr)wgfnH47pGcyNgdEDb2GE9JkFnes)TGqfnH47pGcyNgdEDb2GE9JkKF0i3y1AFWYyBxamAnoxnk(zbIcXv0eIV)akGDAm41fyd61pQGTJeghTATpyzSTlagTgNRgf)SarH4kAcX3FafWong86cSb96hv4EOlMlWHlFOIMq89hqbStJbVUaBqV(rflNl0yzhTvR9HlgC8IncR9W7BFzf3nybhH1GAEGsdsTwqHIMq89hqbStJbVUaBqV(rfGr4u0eIV)akGDAm41fyd61pQuBj(dT(czaNkAcX3FafWong86cSb96hvwo64O3P5wBj(dToda6ijJX)rtp9mb]] )


end
