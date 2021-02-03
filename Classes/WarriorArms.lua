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

        potion = "spectral_strength",

        package = "Arms",
    } )


    spec:RegisterPack( "Arms", 20210202, [[dCeHRaqikj8ijKnrj6tusunkqbNcePvHkrELu0SqQ6wOsyxs6xsWWqL6ycLLjf6zsOmnqrDnkbBtcvFJssghLqNduOwhLeL5Hu5EsP9HkPdckYcfQEiOq6IGcXgbrqNevIALiLzcIi2PqAOusKLcIi9ubtviUkic1wbruFfeHSxr)ffdwQomXIrPhJyYuCzOntP(SenAq60kTAqe41GsZMKBJQ2TIFdmCq1XPKulxvpxLPt11rY2bHVJkgpiQZlfmFkP2pPoJLrYGrCmJ2i3ngJ7g5UXAmlcZWCmlMbVb4ygGleyLsmdJWJzaME(ldWLguaXKrYWbOEcMbOUd)SYkuOCDOuSvcGVWT8ukXxWqEX2lClpPqgyPwLZLNKndgXXmAJC3ymUBK7gRXSimxSywidcLdf8ziS8ukXxWaJ(ITNbORXGtYMbdEKmuur6om98NUdjs(FbVMwrfP7qcr2Ns(g09gPx3BK7gJPPPPvur6omkuzkXZkttROI0DUq3HjJbn6UvIINhvvnTIks35cDhMmg0O7qYlXbFd6oKuQdAbUmpCCm7uQ7qYlXbFdvnTIks35cDhMmg0O7Xf3vOUhGcOCD3b6o8hjaEwX1DyYkbjPQPvur6oxO7Wiqgju(cg8TYpD3k9izVfm6(E6UbvOJMQMwrfP7CHUdtgdA0DiXhQ7Czh5VQMwrfP7CHUhHdkWQ744Fd6Un4194kXGNdE(Agu75xgjd3oLkKXLVe9msgnwgjd4iSk0KXZa5xh)vYamO72BjuN5rEzNt35QUhZICR7wBTUdd6UlFj6vOOOCOv4ex3Pt3BKBD3AR1Dxu44vE5oH8yfhHvHgD3sD3LVe9kuuuo0kCIR70P7fZc6oKQ7qAgeIVGjdeWy1u4d(JHvMb)0ZOnMrYaocRcnz8mq(1XFLmqaaLbWzQeGcCh1XC8YbT(iVSZP70P7wu3Tu3ljM6J8YoNU3Q7CNbH4lyYGaH4YNEgTyzKmGJWQqtgpdKFD8xjdpYl7C6oDT6UH6fFbJUZL0DURfldcXxWKHhht6zuyoJKbCewfAY4zG8RJ)kz4GJkfJlFj6xLd09vC2XO7Cv3JP7wQ7gGxnicNHdGAmx9rEzNt3Pt3ljMmieFbtgikuGatpJAHmsgeIVGjdCKN9rbw8ZaocRcnz80ZOfpJKbH4lyYabOa3rDmhVCqZaocRcnz80ZOwvgjd4iSk0KXZa5xh)vYalLTDvGqC5RpYl7C6oD6EmlQ7wQ7wHUBaE9fiKs8RpYl7Czqi(cMm8cesj(PNrTygjdcXxWKbzilooJy74FqbeyZaocRcnz80ZOW4msgeIVGjdhCuEgGndRC(cMmGJWQqtgp9mAmUZizahHvHMmEgi)64VsgiqLVepDVv3BmdcXxWKbae4dhWb)0ZOXILrYaocRcnz8mq(1XFLmWszBxnOyunWqefF1a4m6UL6omO7gKLY2UsakWDuhZXlh0kfCD3sD)Lsu3Pt3lg36U1wR7VuI6oD6UvXTUdPzqi(cMmWQedEo45tpJgRXmsgWryvOjJNbYVo(RKbwkB7kac8Hd4GF9CHaRUZ1wDVrD3sDNLY2UAqXOAGHik(QbWz0DRTw3HbD3a8Qbr4mCauJ5QpYl7C6oDT6EjXO7wQ7eaqzaCMkbOa3rDmhVCqRpYl7C6ox19sIr3H0mieFbtg4bVlkMZ)fwm9mASILrYGq8fmzWGIr1adru8zahHvHMmE6z0yWCgjd4iSk0KXZa5xh)vYWlLOUtNUxCU1Dl1DwkB7QbfJQbgIO4RgaNjdcXxWKHdwkL6GRw3Xp9mAmlKrYGq8fmzaab(WbCWpd4iSk0KXtpJgR4zKmGJWQqtgpdKFD8xjdSu221JYyWHXGIdT(Oq8mieFbtgiGXG8t6z0ywvgjd4iSk0KXZa5xh)vYalLTD9OmgCymO4qRpkepdcXxWKbeYiHYX0ZOXSygjdcXxWKbEW7II58FHfZaocRcnz80ZOXGXzKmGJWQqtgpdKFD8xjdUOWXR24db4za2mSI7kSIJWQqtgeIVGjdCGUVIZoM0ZOnYDgjd4iSk0KXZa5xh)vYGvO7UOWXR24db4za2mSI7kSIJWQqtgeIVGjdNs4tp9myqBHs5zKmASmsgeIVGjdeOYxIzahHvHMmE6z0gZizqi(cMmaNINhvzahHvHMmE6z0ILrYGq8fmzaoWxWKbCewfAY4PNrH5msgWryvOjJNbYVo(RKbdYszBxjaf4oQJ54LdALcEgeIVGjdSkaWWyt9nKEg1czKmGJWQqtgpdKFD8xjdgKLY2UsakWDuhZXlh06J8YoNUZvDV4zqi(cMmWI)HpS7uMEgT4zKmGJWQqtgpdKFD8xjdeaqzaCMkp4DrXC(VWI1h5LDoDNR6ESQf0Dl19xkrDNoD3cCNbH4lyYG8ezqgh8poE6zuRkJKbCewfAY4zG8RJ)kzWGSu22vcqbUJ6yoE5GwnaoJUBPUtaaLbWzQ8G3ffZ5)clwFKx25YGq8fmzqTLq9JbsaLPKhhp9mQfZizahHvHMmEgi)64VsgmilLTDLauG7OoMJxoOvk4zqi(cMmyVpYQaat6zuyCgjd4iSk0KXZa5xh)vYGbzPSTReGcCh1XC8YbTsbpdcXxWKbzi45VOyiIsLEgng3zKmGJWQqtgpdKFD8xjdgKLY2UsakWDuhZXlh0QbWz0Dl1DcaOmaotLh8UOyo)xyX6J8YoxgeIVGjdSsjdWMX)La7LEgnwSmsgWryvOjJNHr4XmSZrEkxyviJvtjJtXZyqiwcMbH4lyYWoh5PCHvHmwnLmofpJbHyjy6z0ynMrYaocRcnz8mmcpMbZJIXEFKbc8ouLbH4lyYG5rXyVpYabEhQspJgRyzKmieFbtgOoKzDK)YaocRcnz80ZOXG5msgWryvOjJNbYVo(RKHdoQumU8LOFvoq3xXzhJUZvDpMUBPUdd6obaugaNPYQedEo45RpYl7C6ox19ywq3T2AD3ffoE9fiKs8R4iSk0O7qAgeIVGjdhheHVtjZ5)clEPNrJzHmsgWryvOjJNbYVo(RKbyq3DrHJx5L7eYJvCewfA0Dl1Dx(s0Rqrr5qRWjUUtNUxmlO7qQUBT16UlFj6vOOOCOv4ex3Pt3BKBD3AR1Dyq3D5lrVcffLdTcN46ox1DlYTUBPUtaqGJmEfcCCOn86oKMHZ)L4z0yzqi(cMmqeLIri(cgg1EEgu75mJWJzaHmsOCm9mASINrYaocRcnz8mq(1XFLmCWrLIXLVe9RYb6(ko7y0DUQ7XYW5)s8mASmieFbtgiIsXieFbdJAppdQ9CMr4XmaviPNrJzvzKmGJWQqtgpdcXxWKbIOumcXxWWO2ZZGApNzeEmd3oLkKXLVe90ZOXSygjdcXxWKbiwId(gyEQdAgWryvOjJNEgngmoJKbH4lyYWYdhhZoLmqSeh8nKbCewfAY4PNEgG)ibWZkEgjJglJKbH4lyYaR4UczoOakpd4iSk0KXtpJ2ygjd4iSk0KXZa5xh)vYGvO7p1G2GVeR3woOZaSzCWZJJJggy3P8QOvtTWHJMmieFbtgEKaRcVBW7sp9mGqgjuoMrYOXYizqi(cMmyqXOAGHik(mGJWQqtgp9mAJzKmGJWQqtgpdKFD8xjdpYl7C6oDT6UH6fFbJUZL0DURfldcXxWKHhht6z0ILrYaocRcnz8mq(1XFLm8sjQ70P7fNBD3sDhg0DRq3DrHJxnOyunWqefFfhHvHgD3AR1DwkB7QbfJQbgIO4RgaNr3H0mieFbtgoyPuQdUADh)0ZOWCgjd4iSk0KXZa5xh)vYabaugaNPsakWDuhZXlh06J8YoNUtNUBrD3sDVKyQpYl7C6ERUZDgeIVGjdceIlF6zulKrYaocRcnz8mq(1XFLmWszBxfiex(6J8YoNUtNUhZI6UL6UvO7gGxFbcPe)6J8YoxgeIVGjdVaHuIF6z0INrYGq8fmzGagRMcFWFmSYm4NbCewfAY4PNrTQmsgWryvOjJNbYVo(RKHdoQumU8LOFvoq3xXzhJUZvDpMUBPUBaE1GiCgoaQXC1h5LDoDNoDVKyYGq8fmzGOqbcm9mQfZizqi(cMmWrE2hfyXpd4iSk0KXtpJcJZizqi(cMmqakWDuhZXlh0mGJWQqtgp9mAmUZizahHvHMmEgi)64VsgmilLTDLauG7OoMJxoOvk46U1wR7Su221JYyWHXGIdT(OqCD3AR19xkrDNR6EXTqgeIVGjdeWyq(j9mASyzKmGJWQqtgpdKFD8xjdeOYxINU3Q7nMbH4lyYaac8Hd4GF6z0ynMrYGq8fmzqgYIJZi2o(huab2mGJWQqtgp9mASILrYGq8fmz4GJYZaSzyLZxWKbCewfAY4PNrJbZzKmGJWQqtgpdKFD8xjdSu22vdkgvdmerXxnaoJUBPU)sjQ70P7wG7mieFbtgyvIbph88PNrJzHmsgWryvOjJNbYVo(RKbdWRgeHZWbqnMR(iVSZP701Q7LetgeIVGjd8G3ffZ5)clMEgnwXZizahHvHMmEgi)64VsgEPe1D60DyM7mieFbtgoyPuQdUADh)0ZOXSQmsgeIVGjdaiWhoGd(zahHvHMmE6z0ywmJKbH4lyYabmgKFYaocRcnz80ZOXGXzKmieFbtgqiJekhZaocRcnz80tpdqfsgjJglJKbCewfAY4zG8RJ)kz4Lsu3Pt3lo36UL6olLTD1GIr1adru8vdGZKbH4lyYWblLsDWvR74NEgTXmsgeIVGjdeWy1u4d(JHvMb)mGJWQqtgp9mAXYizahHvHMmEgi)64VsgiaGYa4mvcqbUJ6yoE5GwFKx250D609yzqi(cMmiqiU8PNrH5msgWryvOjJNbYVo(RKbdWRgeHZWbqnMR(iVSZP701Q7LetgeIVGjdefkqGPNrTqgjdcXxWKboYZ(Oal(zahHvHMmE6z0INrYGq8fmzqgYIJZi2o(huab2mGJWQqtgp9mQvLrYGq8fmz4GJYZaSzyLZxWKbCewfAY4PNrTygjdcXxWKbwLyWZbpFgWryvOjJNEgfgNrYGq8fmz4fiKs8ZaocRcnz80ZOX4oJKbH4lyYabOa3rDmhVCqZaocRcnz80ZOXILrYaocRcnz8mq(1XFLm8iVSZP701Q7gQx8fm6oxs35UwmD3sDNLY2UECqe(oLmN)lS4vPGNbH4lyYWJJj9mASgZizqi(cMmquOabMbCewfAY4PNrJvSmsgWryvOjJNbYVo(RKbwkB76Xbr47uYC(VWIxLcUUBT16Ub4vdIWz4aOgZvFKx250D609sIr3Tu3TcD3ffoELOqbcSIJWQqtgeIVGjd8G3ffZ5)clMEgngmNrYaocRcnz8mq(1XFLm4IchVAEumJqvc1R4iSk0KbH4lyYaac8Hd4GF6z0ywiJKbH4lyYabmgKFYaocRcnz80ZOXkEgjd4iSk0KXZa5xh)vYalLTD94Gi8Dkzo)xyXRsbpdcXxWKbeYiHYX0ZOXSQmsgeIVGjdaiWhoGd(zahHvHMmE6z0ywmJKbH4lyYahO7R4SJjd4iSk0KXtp90Zae4FlyYOnYDJChRXgTyg4i)St5LbUmpCW7Or3TGUleFbJUR2ZVQMwgG)a7vHzOOI0Dy65pDhsK8)cEnTIks3HeISpL8nO7nsVU3i3ngttttROI0DyuOYuINvMMwrfP7CHUdtgdA0DRefppQQAAfvKUZf6omzmOr3HKxId(g0DiPuh0cCzE44y2Pu3HKxId(gQAAfvKUZf6omzmOr3JlURqDpafq56Ud0D4psa8SIR7WKvcssvtROI0DUq3HrGmsO8fm4BLF6Uv6rYEly0990DdQqhnvnTIks35cDhMmg0O7qIpu35YoYFvnTIks35cDpchuGv3XX)g0DBWR7XvIbph88vnnnTIks3HrGmsOC0O7SOn4rDNa4zfx3zXYDUQUdtecc3pDFadxavEEBkLUleFbZP7Gr1qvtti(cMRc)rcGNv8MTfyf3viZbfq5AAcXxWCv4psa8SI3STWJeyv4DdEh9RDRv8udAd(sSEB5GodWMXbppooAyGDNYRIwn1choA0000kQiDhgbYiHYrJUJqGFd6UV8OU7qrDxio41990DbczvcRcRAAcXxWCTeOYxIAAcXxWCnBlaNINhvAAcXxWCnBlah4ly00eIVG5A2wGvbaggBQVb6x7wdYszBxjaf4oQJ54LdALcUMMq8fmxZ2cS4F4d7oL0V2TgKLY2UsakWDuhZXlh06J8YohxlUMMq8fmxZ2cYtKbzCW)440V2TeaqzaCMkp4DrXC(VWI1h5LDoUgRAblFPePZcCRPjeFbZ1STGAlH6hdKaktjpoo9RDRbzPSTReGcCh1XC8YbTAaCgljaGYa4mvEW7II58FHfRpYl7CAAcXxWCnBlyVpYQaad9RDRbzPSTReGcCh1XC8YbTsbxtti(cMRzBbzi45VOyiIsr)A3AqwkB7kbOa3rDmhVCqRuW10eIVG5A2wGvkza2m(Veyp6x7wdYszBxjaf4oQJ54LdA1a4mwsaaLbWzQ8G3ffZ5)clwFKx2500eIVG5A2wG6qM1rE6hHhB35ipLlSkKXQPKXP4zmielb10eIVG5A2wG6qM1rE6hHhBnpkg79rgiW7qLMMq8fmxZ2cuhYSoYFAAcXxWCnBlCCqe(oLmN)lS4r)A3EWrLIXLVe9RYb6(ko7y4AmlHbcaOmaotLvjg8CWZxFKx254AmlyT1UOWXRVaHuIFfhHvHgivtti(cMRzBbIOumcXxWWO2ZPFeESfHmsOCK(Z)L4TXOFTBHbxu44vE5oH8yfhHvHglD5lrVcffLdTcN40vmlaPwBTlFj6vOOOCOv4eNUg52ARHbx(s0Rqrr5qRWjoxTi3wsaqGJmEfcCCOn8qQMMq8fmxZ2cerPyeIVGHrTNt)i8yluHq)5)s82y0V2ThCuPyC5lr)QCGUVIZogUgttti(cMRzBbIOumcXxWWO2ZPFeES92PuHmU8LORPjeFbZ1STaelXbFdmp1bvtti(cMRzBHLhooMDkzGyjo4Bqtttti(cMRIqgjuo2AqXOAGHikEnnH4lyUkczKq5yZ2cpog6x72h5LDo6AnuV4ly4sCxlMMMq8fmxfHmsOCSzBHdwkL6GRw3XN(1U9LsKUIZTLWGv4IchVAqXOAGHik(kocRcnwBnlLTD1GIr1adru8vdGZaPAAcXxWCveYiHYXMTfeiexE6x7wcaOmaotLauG7OoMJxoO1h5LDo6SOLLet9rEzNRLBnnH4lyUkczKq5yZ2cVaHuIp9RDllLTDvGqC5RpYl7C0fZIwAfgGxFbcPe)6J8YoNMMq8fmxfHmsOCSzBbcySAk8b)XWkZGVMMq8fmxfHmsOCSzBbIcfiq6x72doQumU8LOFvoq3xXzhdxJzPb4vdIWz4aOgZvFKx25ORKy00eIVG5QiKrcLJnBlWrE2hfyXxtti(cMRIqgjuo2STabOa3rDmhVCq10eIVG5QiKrcLJnBlqaJb5h6x7wdYszBxjaf4oQJ54LdALcU1wZszBxpkJbhgdko06JcXT26xkrUwClOPjeFbZvriJekhB2waab(WbCWN(1ULav(s8AButti(cMRIqgjuo2STGmKfhNrSD8pOacSAAcXxWCveYiHYXMTfo4O8maBgw58fmAAcXxWCveYiHYXMTfyvIbph880V2TSu22vdkgvdmerXxnaoJLVuI0zbU10eIVG5QiKrcLJnBlWdExumN)lSi9RDRb4vdIWz4aOgZvFKx25ORTKy00eIVG5QiKrcLJnBlCWsPuhC16o(0V2TVuI0bZCRPjeFbZvriJekhB2waab(WbCWxtti(cMRIqgjuo2STabmgKF00eIVG5QiKrcLJnBlGqgjuoQPPPjeFbZvHkK2dwkL6GRw3XN(1U9LsKUIZTLSu22vdkgvdmerXxnaoJMMq8fmxfQqA2wGagRMcFWFmSYm4RPjeFbZvHkKMTfeiexE6x7wcaOmaotLauG7OoMJxoO1h5LDo6IPPjeFbZvHkKMTfikuGaPFTBnaVAqeodha1yU6J8YohDTLeJMMq8fmxfQqA2wGJ8SpkWIVMMq8fmxfQqA2wqgYIJZi2o(huabwnnH4lyUkuH0STWbhLNbyZWkNVGrtti(cMRcvinBlWQedEo4510eIVG5QqfsZ2cVaHuIVMMq8fmxfQqA2wGauG7OoMJxoOAAcXxWCvOcPzBHhhd9RD7J8YohDTgQx8fmCjURfZswkB76Xbr47uYC(VWIxLcUMMq8fmxfQqA2wGOqbcutti(cMRcvinBlWdExumN)lSi9RDllLTD94Gi8Dkzo)xyXRsb3ARnaVAqeodha1yU6J8YohDLeJLwHlkC8krHceyfhHvHgnnH4lyUkuH0STaac8Hd4Gp9RDRlkC8Q5rXmcvjuVIJWQqJMMq8fmxfQqA2wGagdYpAAcXxWCvOcPzBbeYiHYr6x7wwkB76Xbr47uYC(VWIxLcUMMq8fmxfQqA2waab(WbCWxtti(cMRcvinBlWb6(ko7y0000eIVG5Q3oLkKXLVe9wcySAk8b)XWkZGp9RDlmyVLqDMh5LDoUgZICBT1WGlFj6vOOOCOv4eNUg52ARDrHJx5L7eYJvCewfAS0LVe9kuuuo0kCItxXSaKcPAAcXxWC1BNsfY4YxIEZ2cceIlp9RDlbaugaNPsakWDuhZXlh06J8YohDw0YsIP(iVSZ1YTMMq8fmx92PuHmU8LO3STWJJH(1U9rEzNJUwd1l(cgUe31IPPjeFbZvVDkviJlFj6nBlquOabs)A3EWrLIXLVe9RYb6(ko7y4AmlnaVAqeodha1yU6J8YohDLeJMMq8fmx92PuHmU8LO3STah5zFuGfFnnH4lyU6TtPczC5lrVzBbcqbUJ6yoE5GQPjeFbZvVDkviJlFj6nBl8cesj(0V2TSu22vbcXLV(iVSZrxmlAPvyaE9fiKs8RpYl7CAAcXxWC1BNsfY4YxIEZ2cYqwCCgX2X)GciWQPjeFbZvVDkviJlFj6nBlCWr5za2mSY5ly00eIVG5Q3oLkKXLVe9MTfaqGpCah8PFTBjqLVeV2g10eIVG5Q3oLkKXLVe9MTfyvIbph880V2TSu22vdkgvdmerXxnaoJLWGbzPSTReGcCh1XC8YbTsb3Yxkr6kg3wB9lLiDwf3qQMMq8fmx92PuHmU8LO3STap4DrXC(VWI0V2TSu22vae4dhWb)65cbwU22OLSu22vdkgvdmerXxnaoJ1wddgGxnicNHdGAmx9rEzNJU2sIXscaOmaotLauG7OoMJxoO1h5LDoUwsmqQMMq8fmx92PuHmU8LO3STGbfJQbgIO410eIVG5Q3oLkKXLVe9MTfoyPuQdUADhF6x72xkr6ko3wYszBxnOyunWqefF1a4mAAcXxWC1BNsfY4YxIEZ2caiWhoGd(AAcXxWC1BNsfY4YxIEZ2ceWyq(H(1ULLY2UEugdomguCO1hfIRPjeFbZvVDkviJlFj6nBlGqgjuos)A3YszBxpkJbhgdko06JcX10eIVG5Q3oLkKXLVe9MTf4bVlkMZ)fwutti(cMRE7uQqgx(s0B2wGd09vC2Xq)A36IchVAJpeGNbyZWkURWkocRcnAAcXxWC1BNsfY4YxIEZ2cNs4PFTBTcxu44vB8Ha8maBgwXDfwXryvOjdhCKKrTQyPNEMa]] )


end
