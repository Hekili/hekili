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


    spec:RegisterPack( "Arms", 20201228, [[dGKrRaqijP4rIIAtuqFsskPrbIYPKsvRsue9kPKzHs5wGkAxs8lrvddPYXKeltsYZOannrr6AOu12KKQVbQKXHsLZbIQwNKuI5bQ6EsQ9rbCqqfwOOYdbvkMOuQexeev6KIIWkrkZukvs7uuAOGkvlvkvQEkLMkf6QssPSvquXxLsLYEf(lsgSuDyIfJkpgXKf5YqBMI(SumAq60QSAjPu9AKQMnj3gvTBf)gy4GYXLsflxvpxPPt11rX2bHVJsgpiY5Lsz9GkLMVOW(j1rLWyytIJr2QORk6QuvvSRuXG0bxSNDH1BdggwycHEPbd7i8yyHJNFdlmPnfqsHXWUaMNGHfQ7W2QL85BohkdxHa4ZVhpJs8dmKxm987XtYhwoMt5zIj4cBsCmYwfDvrxLQQIDLkgKo4YGvfwHXHc(WApEgL4hyGBEX0dl0lLWj4cBcxsyZSUdhp)Q7TBY)h410YSU3UGeKNdFDVk2XMUxfDvrNMMMwM1D4gOY0GB1IMwM1D4u3HJuct6oCNHNhvfnTmR7WPUdhPeM0DiNJ4GVnDVDNzHMptWddN0nn6oKZrCW3wrtlZ6oCQ7WrkHjDpN4Uc1DluaJR7oq3H9ibWZjUUdhW921IMwM1D4u3HCHesy8dm4xTU6oC)rYThy09B19eQqhtfnTmR7WPUdhPeM09QTf19mHJ8BrtlZ6oCQ7gzHc96oo(3MUBcEDpNss46GNVew1T(ggd7EtJcPC5BqpmgzRegdlocNctrUWs(ZX)KWcz6U51a1PEKxUz1DdO7vyhD6EgzO7qMU7Y3GEbkkkhAbgX1D419QOt3ZidD3ffoEHx2vipwWr4uys3nu3D5BqVaffLdTaJ46o86UbzVU3EDV9Hvi(bMWsat7WGp4xkozg8dpYwvymS4iCkmf5cl5ph)tclbaujaRPqakWUml1Yll0YJ8YnRUdVUZoD3qDVHKkpYl3S6ETUtxyfIFGjSceIlF4rwdggdlocNctrUWs(ZX)KW(iVCZQ7WxR7jMx8dm6EMu3PRyWWke)atyFCsHhzZ0WyyXr4uykYfwYFo(Ne2fgQuuU8nOVfwqVxX6MKUBaDVIUBOUNaEjHimkwaMjTLh5LBwDhEDVHKcRq8dmHLOqbcm8il7dJHvi(bMWYsEUhf6XpS4iCkmf5cpYw9WyyfIFGjSeGcSlZsT8YcnS4iCkmf5cpYcxHXWIJWPWuKlSK)C8pjSCmMMfbcXLV8iVCZQ7WR7vyNUBOUxn6Ec4LxGqAWV8iVCZgwH4hyc7lqin4hEKLDHXWke)atyLHC44uIPJ)cfqOpS4iCkmf5cpYc5dJHvi(bMWUWq5PaMuCY6hyclocNctrUWJSvOlmgwCeofMICHL8NJ)jHLav(gC19ADVQWke)atybqGpmal8dpYwPsymS4iCkmf5cl5ph)tclhJPzjHss1gfru8LeG1O7gQ7qMUNqogtZcbOa7YSulVSqlmW0Dd19xAqDhED3G0P7zKHU)sdQ7WR7WfD6E7dRq8dmHLtjjCDWZhEKTsvHXWIJWPWuKlSK)C8pjSCmMMfae4ddWc)Y6cHED3a16Ev6UH6ohJPzjHss1gfru8LeG1O7zKHUdz6Ec4LeIWOybyM0wEKxUz1D4R19gss3nu3jaGkbynfcqb2LzPwEzHwEKxUz1DdO7nKKU3(Wke)aty5bVlkQ1)JEm8iBfdggdRq8dmHnHss1gfru8HfhHtHPix4r2kzAymS4iCkmf5cl5ph)tc7lnOUdVUxD60Dd1DogtZscLKQnkIO4ljaRjScXpWe2LEgLAHPo3Xp8iBf2hgdRq8dmHfab(WaSWpS4iCkmf5cpYwP6HXWIJWPWuKlSK)C8pjSCmMMLLjLWHkHIdT8Oq8Wke)atyjGjH8t4r2kWvymS4iCkmf5cl5ph)tclhJPzzzsjCOsO4qlpkepScXpWewesiHXXWJSvyxymScXpWewEW7IIA9)OhdlocNctrUWJSvG8HXWIJWPWuKlSK)C8pjSUOWXlM4db4PaMuCI7kSGJWPWuyfIFGjSSGEVI1nPWJSvrxymS4iCkmf5cl5ph)tcB1O7UOWXlM4db4PaMuCI7kSGJWPWuyfIFGjSRs4dp8WMqtHr5HXiBLWyyfIFGjSeOY3GHfhHtHPix4r2QcJHvi(bMWcJHNhvHfhHtHPix4rwdggdRq8dmHfgWpWewCeofMICHhzZ0WyyXr4uykYfwYFo(Ne2eYXyAwiafyxMLA5LfAHbwyfIFGjSCkairzY8TfEKL9HXWIJWPWuKlSK)C8pjSjKJX0SqakWUml1Yll0YJ8YnRUBaDV6Hvi(bMWYH)Ip930eEKT6HXWIJWPWuKlSK)C8pjSeaqLaSMcp4DrrT(F0JLh5LBwD3a6ELc71Dd19xAqDhEDN90fwH4hycR8ezqkh8poE4rw4kmgwCeofMICHL8NJ)jHnHCmMMfcqb2LzPwEzHwsawJUBOUtaavcWAk8G3ff16)rpwEKxUzdRq8dmHvDnq9LQANj1WJJhEKLDHXWIJWPWuKlSK)C8pjSjKJX0SqakWUml1Yll0cdSWke)atynVh5uaqk8ilKpmgwCeofMICHL8NJ)jHnHCmMMfcqb2LzPwEzHwyGfwH4hycRmeC9xuuerPcpYwHUWyyXr4uykYfwYFo(Ne2eYXyAwiafyxMLA5LfAjbyn6UH6obaujaRPWdExuuR)h9y5rE5MnScXpWewoPHcys5)rOFdpYwPsymS4iCkmf5c7i8yyVzjpJlCkKQDyKXz4PsiehbdRq8dmH9ML8mUWPqQ2HrgNHNkHqCem8iBLQcJHfhHtHPixyhHhdB6rjzEpsbbUlQcRq8dmHn9OKmVhPGa3fvHhzRyWWyyfIFGjSmlsDoYVHfhHtHPix4r2kzAymS4iCkmf5cl5ph)tc7cdvkkx(g03clO3RyDts3nGUxr3nu3HmDNaaQeG1u4uscxh88Lh5LBwD3a6Ef2R7zKHU7IchV8cesd(fCeofM092hwH4hyc7Ycry30qT(F0JB4r2kSpmgwCeofMICHL8NJ)jHfY0Dxu44fEzxH8ybhHtHjD3qD3LVb9cuuuo0cmIR7WR7gK96E719mYq3D5BqVaffLdTaJ46o86Ev0P7zKHUdz6UlFd6fOOOCOfyex3nGUZo60Dd1DcacCKXlqGJdTTx3BFyx)pIhzRewH4hyclrukkH4hyOu36HvDRtncpgwesiHXXWJSvQEymS4iCkmf5cl5ph)tc7cdvkkx(g03clO3RyDts3nGUxjSR)hXJSvcRq8dmHLikfLq8dmuQB9WQU1PgHhdluHeEKTcCfgdlocNctrUWke)atyjIsrje)adL6wpSQBDQr4XWU30Oqkx(g0dpYwHDHXWke)atyH4io4BJ6zwOHfhHtHPix4r2kq(WyyfIFGjShpmCs30qbXrCW3wyXr4uykYfE4Hf2JeapN4HXiBLWyyfIFGjSCI7kKAHcy8WIJWPWuKl8iBvHXWIJWPWuKlSJWJHvGBxOYllLjyCkGjfmal8dRq8dmHvGBxOYllLjyCkGjfmal8dp8WIqcjmoggJSvcJHvi(bMWMqjPAJIik(WIJWPWuKl8iBvHXWIJWPWuKlSK)C8pjSpYl3S6o816EI5f)aJUNj1D6kgmScXpWe2hNu4rwdggdlocNctrUWs(ZX)KW(sdQ7WR7vNoD3qDhY09Qr3DrHJxsOKuTrrefFbhHtHjDpJm0DogtZscLKQnkIO4ljaRr3BFyfIFGjSl9mk1ctDUJF4r2mnmgwCeofMICHL8NJ)jHLaaQeG1uiafyxMLA5LfA5rE5Mv3Hx3zNUBOU3qsLh5LBwDVw3PlScXpWewbcXLp8il7dJHfhHtHPixyj)54Fsy5ymnlceIlF5rE5Mv3Hx3RWoD3qDVA09eWlVaH0GF5rE5MnScXpWe2xGqAWp8iB1dJHvi(bMWsat7WGp4xkozg8dlocNctrUWJSWvymS4iCkmf5cl5ph)tc7cdvkkx(g03clO3RyDts3nGUxr3nu3taVKqegflaZK2YJ8YnRUdVU3qsHvi(bMWsuOabgEKLDHXWke)atyzjp3Jc94hwCeofMICHhzH8HXWke)atyjafyxMLA5LfAyXr4uykYfEKTcDHXWIJWPWuKlSK)C8pjSjKJX0SqakWUml1Yll0cdmDpJm0DogtZYYKs4qLqXHwEuiUUNrg6(lnOUBaDV6SpScXpWewcysi)eEKTsLWyyXr4uykYfwYFo(Newcu5BWv3R19QcRq8dmHfab(WaSWp8iBLQcJHvi(bMWkd5WXPeth)fkGqFyXr4uykYfEKTIbdJHvi(bMWUWq5PaMuCY6hyclocNctrUWJSvY0WyyXr4uykYfwYFo(NewogtZscLKQnkIO4ljaRr3nu3FPb1D41D2txyfIFGjSCkjHRdE(WJSvyFymS4iCkmf5cl5ph)tcBc4LeIWOybyM0wEKxUz1D4R19gskScXpWewEW7IIA9)OhdpYwP6HXWIJWPWuKlSK)C8pjSV0G6o86EMsxyfIFGjSl9mk1ctDUJF4r2kWvymScXpWewae4ddWc)WIJWPWuKl8iBf2fgdRq8dmHLaMeYpHfhHtHPix4r2kq(WyyfIFGjSiKqcJJHfhHtHPix4HhwOcjmgzRegdlocNctrUWs(ZX)KW(sdQ7WR7vNoD3qDNJX0SKqjPAJIik(scWAcRq8dmHDPNrPwyQZD8dpYwvymScXpWewcyAhg8b)sXjZGFyXr4uykYfEK1GHXWIJWPWuKlSK)C8pjSeaqLaSMcbOa7YSulVSqlpYl3S6o86ELWke)atyfiex(WJSzAymS4iCkmf5cl5ph)tcBc4LeIWOybyM0wEKxUz1D4R19gskScXpWewIcfiWWJSSpmgwH4hycll55EuOh)WIJWPWuKl8iB1dJHvi(bMWkd5WXPeth)fkGqFyXr4uykYfEKfUcJHvi(bMWUWq5PaMuCY6hyclocNctrUWJSSlmgwH4hyclNss46GNpS4iCkmf5cpYc5dJHvi(bMW(cesd(HfhHtHPix4r2k0fgdRq8dmHLauGDzwQLxwOHfhHtHPix4r2kvcJHfhHtHPixyj)54FsyFKxUz1D4R19eZl(bgDptQ70vmOUBOUZXyAwwwic7MgQ1)JEClmWcRq8dmH9XjfEKTsvHXWke)atyjkuGadlocNctrUWJSvmyymS4iCkmf5cl5ph)tclhJPzzzHiSBAOw)p6XTWat3ZidDpb8scryuSamtAlpYl3S6o86EdjP7gQ7vJU7IchVquOabwWr4uykScXpWewEW7IIA9)OhdpYwjtdJHfhHtHPixyj)54FsyDrHJxspkPryAG6fCeofMcRq8dmHfab(WaSWp8iBf2hgdRq8dmHLaMeYpHfhHtHPix4r2kvpmgwCeofMICHL8NJ)jHLJX0SSSqe2nnuR)h94wyGfwH4hyclcjKW4y4r2kWvymScXpWewae4ddWc)WIJWPWuKl8iBf2fgdRq8dmHLf07vSUjfwCeofMICHhE4Hfc83dmr2QORk6Quvv0fwwYp30SHntWdd8oM0D2R7cXpWO7QB9TOPfwypW8uyyZSUdhp)Q7TBY)h410YSU3UGeKNdFDVk2XMUxfDvrNMMMwM1D4gOY0GB1IMwM1D4u3HJuct6oCNHNhvfnTmR7WPUdhPeM0DiNJ4GVnDVDNzHMptWddN0nn6oKZrCW3wrtlZ6oCQ7WrkHjDpN4Uc1DluaJR7oq3H9ibWZjUUdhW921IMwM1D4u3HCHesy8dm4xTU6oC)rYThy09B19eQqhtfnTmR7WPUdhPeM09QTf19mHJ8BrtlZ6oCQ7gzHc96oo(3MUBcEDpNss46GNVOPPPLzDhYfsiHXXKUZHMGh1DcGNtCDNdBUzl6oCqiimF19bmWju55nzu6Uq8dmRUdgvBfnnH4hy2cShjaEoXBvNNtCxHuluaJRPje)aZwG9ibWZjER68mlsDoYZ2i8yTa3UqLxwktW4uatkyaw4RPPPLzDhYfsiHXXKUJqGFB6UF8OU7qrDxio419B1Dbc5ucNclAAcXpWS1eOY3GAAcXpWSTQZdJHNhvAAcXpWSTQZdd4hy00eIFGzBvNNtbajktMVn2oZ6eYXyAwiafyxMLA5LfAHbMMMq8dmBR68C4V4t)nnSDM1jKJX0SqakWUml1Yll0YJ8YnRbQUMMq8dmBR68YtKbPCW)44SDM1eaqLaSMcp4DrrT(F0JLh5LBwduPWEdFPbHN90PPje)aZ2QoV6AG6lv1otQHhhNTZSoHCmMMfcqb2LzPwEzHwsawJHeaqLaSMcp4DrrT(F0JLh5LBwnnH4hy2w15nVh5uaqITZSoHCmMMfcqb2LzPwEzHwyGPPje)aZ2QoVmeC9xuuerPy7mRtihJPzHauGDzwQLxwOfgyAAcXpWSTQZZjnuatk)pc9lBNzDc5ymnleGcSlZsT8YcTKaSgdjaGkbynfEW7IIA9)OhlpYl3SAAcXpWSTQZZSi15ipBJWJ13SKNXfofs1omY4m8ujeIJGAAcXpWSTQZZSi15ipBJWJ1PhLK59ife4UOstti(bMTvDEMfPoh5xnnH4hy2w15xwic7MgQ1)JECz7mRxyOsr5Y3G(wyb9EfRBsgOIHqgbaujaRPWPKeUo45lpYl3SgOc7Zidxu44LxGqAWVGJWPWu710eIFGzBvNNikfLq8dmuQBD2gHhRriHeghzB9)iEDf2oZAiZffoEHx2vipwWr4uyYqx(g0lqrr5qlWio8gK9TpJmC5BqVaffLdTaJ4WxfDzKbK5Y3GEbkkkhAbgXna7OZqcacCKXlqGJdTTV9AAcXpWSTQZteLIsi(bgk1ToBJWJ1qfcBR)hXRRW2zwVWqLIYLVb9TWc69kw3KmqfnnH4hy2w15jIsrje)adL6wNTr4X69Mgfs5Y3GUMMq8dmBR68qCeh8Tr9mlunnH4hy2w15pEy4KUPHcIJ4GVnnnnnH4hy2ccjKW4yDcLKQnkIO410eIFGzliKqcJJTQZ)4Ky7mRFKxUzHVoX8IFGjtsxXGAAcXpWSfesiHXXw15x6zuQfM6ChF2oZ6xAq4RoDgczvJlkC8scLKQnkIO4l4iCkmLrgCmMMLekjvBuerXxsawt710eIFGzliKqcJJTQZlqiU8SDM1eaqLaSMcbOa7YSulVSqlpYl3SWZodBiPYJ8YnBnDAAcXpWSfesiHXXw15FbcPbF2oZAogtZIaH4YxEKxUzHVc7mSAsaV8cesd(Lh5LBwnnH4hy2ccjKW4yR68eW0om4d(LItMbFnnH4hy2ccjKW4yR68efkqGSDM1lmuPOC5BqFlSGEVI1njduXWeWljeHrXcWmPT8iVCZcFdjPPje)aZwqiHeghBvNNL8Cpk0JVMMq8dmBbHesyCSvDEcqb2LzPwEzHQPje)aZwqiHeghBvNNaMeYpSDM1jKJX0SqakWUml1Yll0cdSmYGJX0SSmPeoujuCOLhfINrgV0GgO6Sxtti(bMTGqcjmo2Qopac8HbyHpBNznbQ8n4wxLMMq8dmBbHesyCSvDEzihooLy64Vqbe610eIFGzliKqcJJTQZVWq5PaMuCY6hy00eIFGzliKqcJJTQZZPKeUo45z7mR5ymnljusQ2OiIIVKaSgdFPbHN90PPje)aZwqiHeghBvNNh8UOOw)p6r2oZ6eWljeHrXcWmPT8iVCZcFDdjPPje)aZwqiHeghBvNFPNrPwyQZD8z7mRFPbHptPttti(bMTGqcjmo2Qopac8HbyHVMMq8dmBbHesyCSvDEcysi)OPje)aZwqiHeghBvNhHesyCutttti(bMTavi1l9mk1ctDUJpBNz9lni8vNod5ymnljusQ2OiIIVKaSgnnH4hy2cuH0QopbmTdd(GFP4KzWxtti(bMTaviTQZlqiU8SDM1eaqLaSMcbOa7YSulVSqlpYl3SWxrtti(bMTaviTQZtuOabY2zwNaEjHimkwaMjTLh5LBw4RBijnnH4hy2cuH0Qopl55EuOhFnnH4hy2cuH0QoVmKdhNsmD8xOac9AAcXpWSfOcPvD(fgkpfWKItw)aJMMq8dmBbQqAvNNtjjCDWZRPje)aZwGkKw15FbcPbFnnH4hy2cuH0QopbOa7YSulVSq10eIFGzlqfsR68poj2oZ6h5LBw4RtmV4hyYK0vmOHCmMMLLfIWUPHA9)Oh3cdmnnH4hy2cuH0QoprHceOMMq8dmBbQqAvNNh8UOOw)p6r2oZAogtZYYcry30qT(F0JBHbwgzKaEjHimkwaMjTLh5LBw4BijdRgxu44fIcfiWcocNctAAcXpWSfOcPvDEae4ddWcF2oZAxu44L0JsAeMgOEbhHtHjnnH4hy2cuH0QopbmjKF00eIFGzlqfsR68iKqcJJSDM1CmMMLLfIWUPHA9)Oh3cdmnnH4hy2cuH0Qopac8HbyHVMMq8dmBbQqAvNNf07vSUjPPPPje)aZw2BAuiLlFd61eW0om4d(LItMbF2oZAiZ8AG6upYl3SgOc7OlJmGmx(g0lqrr5qlWio8vrxgz4IchVWl7kKhl4iCkmzOlFd6fOOOCOfyehEdY(23EnnH4hy2YEtJcPC5BqVvDEbcXLNTZSMaaQeG1uiafyxMLA5LfA5rE5MfE2zydjvEKxUzRPttti(bMTS30Oqkx(g0BvN)XjX2zw)iVCZcFDI5f)atMKUIb10eIFGzl7nnkKYLVb9w15jkuGaz7mRxyOsr5Y3G(wyb9EfRBsgOIHjGxsicJIfGzsB5rE5Mf(gsstti(bMTS30Oqkx(g0BvNNL8Cpk0JVMMq8dmBzVPrHuU8nO3QopbOa7YSulVSq10eIFGzl7nnkKYLVb9w15FbcPbF2oZAogtZIaH4YxEKxUzHVc7mSAsaV8cesd(Lh5LBwnnH4hy2YEtJcPC5BqVvDEzihooLy64Vqbe610eIFGzl7nnkKYLVb9w15xyO8uatkoz9dmAAcXpWSL9Mgfs5Y3GER68aiWhgGf(SDM1eOY3GBDvAAcXpWSL9Mgfs5Y3GER68CkjHRdEE2oZAogtZscLKQnkIO4ljaRXqilHCmMMfcqb2LzPwEzHwyGz4lni8gKUmY4LgeE4IU2RPje)aZw2BAuiLlFd6TQZZdExuuR)h9iBNznhJPzbab(WaSWVSUqO3a1vzihJPzjHss1gfru8LeG1Krgqwc4LeIWOybyM0wEKxUzHVUHKmKaaQeG1uiafyxMLA5LfA5rE5M1anKu710eIFGzl7nnkKYLVb9w15tOKuTrrefVMMq8dmBzVPrHuU8nO3Qo)spJsTWuN74Z2zw)sdcF1PZqogtZscLKQnkIO4ljaRrtti(bMTS30Oqkx(g0BvNhab(WaSWxtti(bMTS30Oqkx(g0BvNNaMeYpSDM1CmMMLLjLWHkHIdT8OqCnnH4hy2YEtJcPC5BqVvDEesiHXr2oZAogtZYYKs4qLqXHwEuiUMMq8dmBzVPrHuU8nO3Qopp4DrrT(F0JAAcXpWSL9Mgfs5Y3GER68SGEVI1nj2oZAxu44ft8Ha8uatkoXDfwWr4uystti(bMTS30Oqkx(g0BvNFvcpBNzD14IchVyIpeGNcysXjURWcocNctHDHHKilCvj8WJa]] )


end
