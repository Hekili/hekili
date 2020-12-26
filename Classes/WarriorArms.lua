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


    spec:RegisterPack( "Arms", 20201220, [[dGebVaqirb9irv1Mqv6tQcIgLQOCkvHAvIc0RKunluvDluf1UK4xsIHHeoMK0Yef9mrvzAOkY1qsSnvH8nrHACQcCorHSoufsZdj19uO9HK0brvWcfvEOQGWevfvYfrvioPOawjkmtvrLANIsdfvHAPQIQ0tfzQuQUQQOcBvvuvFvvuf7v4VQQbROdtSyK6XiMmPUm0MPKpRGrRkDALwTQOIEnQkZMIBJk7wQFRYWrrhxvqTCqphy6uDDuA7skFNsz8QICErvwVQG08rI2pjhvd7rslogzZKImPOAMzsrHImIkvRMrrYZJjgjMcHpzaJulCyK4bihismL8mNOd7rcCSqcgPx3zc4rRuzy9xw6c54QawowJ471eOy5valhPsKOzxJNb6GosAXXiBMuKjfvZmtkkuKruPA1hejH1FpyKslhRr896hcOy5r6D1ASd6iPrajs5xn5bihqnFEeiCpOIr(vZNlKGC0iunRMr8RMzsrMuOyOyKF18H4v6beWJQyKF1KNvtEqRrTAYJz54qtrXi)QjpRM8GwJA185Ve)G5PMpVSG3kzaoMyR3EqnF(lXpyEffJ8RM8SAYdAnQvZCI7guntVhRRM(PMmHi54Ofxn5bE8ZDrXi)QjpRM8ipHewFVgHpKa1KhdrYc2RvZfOMA0GoQlkg5xn5z1Kh0AuRMphaunZaoYbkkg5xn5z10Unu4tnX2H5PMwhunZzenc8dYvIKzboiShjW2dg87cCa9WEKTAypsyl0guh5IebUocxjsptnT2Hx)drozBGAsv1S6dOqnPKs18zQPlWb0lVOy83ctIRMuRMzsHAsjLQPlgS9cNaacbIfSfAdQvtEvtxGdOxErX4VfMexnPwnZhvuZhRMposcX3RJe56hMfHhe8PLUry4r2md7rcBH2G6ixKiW1r4krICNrF26c5mhaWc(aob8wGiNSnqnPwnFGAYRAoq0fiYjBduZr1KIijeFVossnXfy4r28f2Je2cTb1rUirGRJWvIee5KTbQj1JQPMfk(ETAMbvtkk5lscX3RJeeBD4rwEkShjSfAdQJCrIaxhHRejat0y(UahqhuS9UqJTT1QjvvZQQjVQP(8IgrMFBhBRbfiYjBdutQvZbIoscX3RJeXGsnm8ilvc7rsi(EDKSjqAik8HWiHTqBqDKl8i7Jc7rsi(EDKiN5aawWhWjG3iHTqBqDKl8iBgh2Je2cTb1rUirGRJWvIenRLvrQjUalqKt2gOMuRMvFGAYRAMHQP(8cuQjdiSarozBqKeIVxhjOutgqy4r2he2JKq896ijnzX2)ILJqW7r4lsyl0guh5cpYMrH9ijeFVosaMOa)N1Nwa(EDKWwOnOoYfEKTkfH9iHTqBqDKlse46iCLirEf4acuZr1mZijeFVosxneY8SHWWJSvRg2Je2cTb1rUirGRJWvIenRLvrJI2K3NigUI(S1QjVQ5ZutnsZAzviN5aawWhWjG3clt1Kx1ekdOAsTAMpkutkPunHYaQMuRMzmfQ5JJKq896irBenc8dYfEKTAMH9iHTqBqDKlse46iCLirZAzvUAiK5zdHfGle(utQoQMzQM8QM0SwwfnkAtEFIy4k6ZwRMusPA(m1uFErJiZVTJT1Gce5KTbQj1JQ5arRM8QMK7m6ZwxiN5aawWhWjG3ce5KTbQjvvZbIwnFCKeIVxhjUd6I5dC4YhgEKTA(c7rsi(EDK0OOn59jIHlsyl0guh5cpYwLNc7rcBH2G6ixKiW1r4krckdOAsTA(ikutEvtAwlRIgfTjVprmCf9zRJKq896ib4J1yamnR7im8iBvQe2JKq896iD1qiZZgcJe2cTb1rUWJSvFuypsyl0guh5IebUocxjs0SwwfaRwJ9xJI)wGOq8ijeFVosKR1ixhEKTAgh2Je2cTb1rUirGRJWvIenRLvbWQ1y)1O4VfikepscX3RJe(esyDm8iB1he2JKq896iXDqxmFGdx(WiHTqBqDKl8iB1mkShjSfAdQJCrIaxhHRejxmy7flew7G)Z6tlUBWc2cTb1rsi(EDKS9UqJTT1HhzZKIWEKWwOnOoYfjcCDeUsKYq10fd2EXcH1o4)S(0I7gSGTqBqDKeIVxhjGr4cpYMz1WEKeIVxhPAlXpyEFil4nsyl0guh5cpYMzMH9ijeFVoslhtS1Bp8RTe)G5fjSfAdQJCHhEK0OLWA8WEKTAypscX3RJe5vGdyKWwOnOoYfEKnZWEKeIVxhjMSCCOjsyl0guh5cpYMVWEKeIVxhjMNVxhjSfAdQJCHhz5PWEKWwOnOoYfjcCDeUsK0inRLvHCMdaybFaNaElSmJKq896irBUt)TyH5fEKLkH9iHTqBqDKlse46iCLiPrAwlRc5mhaWc(aob8wGiNSnqnPQA(OijeFVos0ieGq(2Ei8i7Jc7rcBH2G6ixKiW1r4krICNrF26c3bDX8boC5dlqKt2gOMuvnRwOIAYRAcLbunPwnPcfrsi(EDKeirA87heIThEKnJd7rcBH2G6ixKiW1r4krsJ0SwwfYzoaGf8bCc4TOpBTAYRAsUZOpBDH7GUy(ahU8HfiYjBdIKq896iz2Hxh8Foz1dCy7HhzFqypsyl0guh5IebUocxjsAKM1YQqoZbaSGpGtaVfwMrsi(EDKSwisBUthEKnJc7rcBH2G6ixKiW1r4krsJ0SwwfYzoaGf8bCc4TWYmscX3RJK0ee4qX8jIXeEKTkfH9iHTqBqDKlse46iCLiPrAwlRc5mhaWc(aob8w0NTwn5vnj3z0NTUWDqxmFGdx(Wce5KTbrsi(EDKOLH)z9D4s4deEKTA1WEKWwOnOoYfPw4WiTnGazDH2G)hMvANL7RXAlbJKq896iTnGazDH2G)hMvANL7RXAlbdpYwnZWEKWwOnOoYfPw4WiPHOOTwi(RHaaAIKq896iPHOOTwi(RHaaAcpYwnFH9ijeFVosSa8VoYbIe2cTb1rUWJSv5PWEKWwOnOoYfjcCDeUsKamrJ57cCaDqX27cn22wRMuvnRQM8QMptnj3z0NTUqBenc8dYvGiNSnqnPQAwLkQjLuQMUyW2lqPMmGWc2cTb1Q5JJKq896ibSHiZTh(ahU8HGWJSvPsypsyl0guh5IebUocxjsqz1FSg2Er0AqbFAboiscX3RJeKT)cX3R)Mf4rYSa)3chgPxHeEKT6Jc7rcBH2G6ixKiW1r4kr6zQPlgS9cNaacbIfSfAdQvtEvtxGdOxErX4VfMexnPwnZhvuZhRMusPA6cCa9Ylkg)TWK4Qj1QzMuOMusPA(m10f4a6Lxum(BHjXvtQQMpGc1Kx1KC1WwAVudB)npOA(4ijeFVosq2(leFV(BwGhjZc8FlCyKWNqcRJHhzRMXH9iHTqBqDKlscX3RJeKT)cX3R)Mf4rYSa)3chgjW2dg87cCa9WdpsmHi54OfpShzRg2JKq896irlUBWp49y9iHTqBqDKl8iBMH9iHTqBqDKlsTWHrsEOGxbkGV11()S(mpBimscX3RJK8qbVcuaFRR9)z9zE2qy4r28f2Je2cTb1rUirGRJWvIKlgS9IfcRDW)z9Pf3nybBH2GA1KskvZmunDXGTxSqyTd(pRpT4Ublyl0guRM8QM(YHF)(6fvtQQMvPcfrsi(EDK4qUdM3)S(gwYQ)AikCGWJS8uypsyl0guh5IebUocxjsUyW2lwiS2b)N1NwC3GfSfAdQvtkPunDXGTx4eaqiqSGTqBqTAYRA6lh(97RxunPQAMzvkutkPunDXGTxGyRlyl0guRM8QMptn9Ld)(91lQMuvnZSkfQjLuQM(YHF)(6fvtQvZQ8evuZhhjH471rAGvG6v6)z9Lhkcp)n8WJe(esyDmShzRg2JKq896iPrrBY7tedxKWwOnOoYfEKnZWEKWwOnOoYfjcCDeUsKGiNSnqnPEun1SqX3RvZmOAsrjFrsi(EDKGyRdpYMVWEKWwOnOoYfjcCDeUsKGYaQMuRMpIc1Kx18zQzgQMUyW2lAu0M8(eXWvWwOnOwnPKs1KM1YQOrrBY7tedxrF2A18Xrsi(EDKa8XAmaMM1DegEKLNc7rcBH2G6ixKiW1r4krICNrF26c5mhaWc(aob8wGiNSnqnPwnFGAYRAoq0fiYjBduZr1KIijeFVossnXfy4rwQe2Je2cTb1rUirGRJWvIenRLvrQjUalqKt2gOMuRMvFGAYRAMHQP(8cuQjdiSarozBqKeIVxhjOutgqy4r2hf2JKq896irU(Hzr4bbFAPBegjSfAdQJCHhzZ4WEKWwOnOoYfjcCDeUsKamrJ57cCaDqX27cn22wRMuvnRQM8QM6ZlAez(TDSTguGiNSnqnPwnhi6ijeFVosedk1WWJSpiShjH471rYMaPHOWhcJe2cTb1rUWJSzuypscX3RJe5mhaWc(aob8gjSfAdQJCHhzRsrypsyl0guh5IebUocxjsAKM1YQqoZbaSGpGtaVfwMQjLuQM0SwwfaRwJ9xJI)wGOqC1KskvtOmGQjvvZhrLijeFVosKR1ixhEKTA1WEKWwOnOoYfjcCDeUsKiVcCabQ5OAMzKeIVxhPRgczE2qy4r2Qzg2JKq896ijnzX2)ILJqW7r4lsyl0guh5cpYwnFH9ijeFVosaMOa)N1Nwa(EDKWwOnOoYfEKTkpf2Je2cTb1rUirGRJWvIenRLvrJI2K3NigUI(S1QjVQjugq1KA1KkuejH471rI2iAe4hKl8iBvQe2Je2cTb1rUirGRJWvIK(8IgrMFBhBRbfiYjBdutQhvZbIoscX3RJe3bDX8boC5ddpYw9rH9iHTqBqDKlse46iCLibLbunPwn5jkIKq896ib4J1yamnR7im8iB1moShjH471r6QHqMNnegjSfAdQJCHhzR(GWEKeIVxhjY1AKRJe2cTb1rUWJSvZOWEKeIVxhj8jKW6yKWwOnOoYfEKntkc7rsi(EDKQTe)G59HSG3iHTqBqDKl8iBMvd7rsi(EDKwoMyR3E4xBj(bZlsyl0guh5cp8i9kKWEKTAypsyl0guh5IebUocxjsqzavtQvZhrHAYRAsZAzv0OOn59jIHROpBDKeIVxhjaFSgdGPzDhHHhzZmShjH471rIC9dZIWdc(0s3imsyl0guh5cpYMVWEKWwOnOoYfjcCDeUsKi3z0NTUqoZbaSGpGtaVfiYjBdutQvZQrsi(EDKKAIlWWJS8uypsyl0guh5IebUocxjs6ZlAez(TDSTguGiNSnqnPEunhi6ijeFVosedk1WWJSujShjH471rYMaPHOWhcJe2cTb1rUWJSpkShjH471rsAYIT)flhHG3JWxKWwOnOoYfEKnJd7rsi(EDKamrb(pRpTa896iHTqBqDKl8i7dc7rsi(EDKOnIgb(b5Ie2cTb1rUWJSzuypscX3RJeuQjdimsyl0guh5cpYwLIWEKeIVxhjYzoaGf8bCc4nsyl0guh5cpYwTAypsyl0guh5IebUocxjsqKt2gOMupQMAwO471QzgunPOKp1Kx1KM1YQaSHiZTh(ahU8HGclZijeFVosqS1HhzRMzypscX3RJeXGsnmsyl0guh5cpYwnFH9iHTqBqDKlse46iCLirZAzva2qK52dFGdx(qqHLPAsjLQP(8IgrMFBhBRbfiYjBdutQvZbIwn5vnZq10fd2EHyqPgwWwOnOoscX3RJe3bDX8boC5ddpYwLNc7rcBH2G6ixKiW1r4krYfd2Erdrr3c7WRxWwOnOoscX3RJ0vdHmpBim8iBvQe2JKq896irUwJCDKWwOnOoYfEKT6Jc7rcBH2G6ixKiW1r4krIM1YQaSHiZTh(ahU8HGclZijeFVos4tiH1XWJSvZ4WEKeIVxhPRgczE2qyKWwOnOoYfEKT6dc7rsi(EDKS9UqJTT1rcBH2G6ix4r2QzuypscX3RJuTL4hmVpKf8gjSfAdQJCHhzZKIWEKeIVxhPLJj26Th(1wIFW8Ie2cTb1rUWdp8ivdHG96iBMuKjfvZSAMrYMa7TharkdWX8GoQvtQOMcX3RvtZcCqrXismHN1AWiLF1KhGCa185rGW9Gkg5xnFUqcYrJq1SAgXVAMjfzsHIHIr(vZhIxPhqapQIr(vtEwn5bTg1QjpMLJdnffJ8RM8SAYdAnQvZN)s8dMNA(8YcERKb4yITE7b185Ve)G5vumYVAYZQjpO1OwnZjUBq1m9ESUA6NAYeIKJJwC1Kh4Xp3ffJ8RM8SAYJ8esy99Ae(qcutEmejlyVwnxGAQrd6OUOyKF1KNvtEqRrTA(Caq1md4ihOOyKF1KNvt72qHp1eBhMNAADq1mNr0iWpixrXqXi)QjpYtiH1rTAsJwhevtYXrlUAsJdBdkQjpqiithOM9188Ra5SynQPq89AGAETjVIIHq89AqHjejhhT41hRqlUBWp49yDfdH471GctisooAXRpwHfG)1ro(BHdhLhk4vGc4BDT)pRpZZgcvmeIVxdkmHi54OfV(yfoK7G59pRVHLS6VgIchG)1A0fd2EXcH1o4)S(0I7gSGTqBqnLuMHUyW2lwiS2b)N1NwC3GfSfAdQ51xo873xVivRsfkumeIVxdkmHi54OfV(yLbwbQxP)N1xEOi88x(xRrxmy7flew7G)Z6tlUBWc2cTb1usPlgS9cNaacbIfSfAdQ51xo873xVivZSkfusPlgS9ceBDbBH2GAEFMVC43VVErQMzvkOKsF5WVFF9IuxLNOYJvmumYVAYJ8esyDuRMyneMNA6lhQM(lQMcXpOAUa1uQjRrOnyrXqi(EnyK8kWbuXqi(EnO(yfMSCCOrXqi(EnO(yfMNVxRyieFVguFScT5o93IfMh)R1OgPzTSkKZCaal4d4eWBHLPIHq89Aq9Xk0ieGq(2EG)1AuJ0SwwfYzoaGf8bCc4TarozBavFKIHq89Aq9XkcKin(9dcX25FTgj3z0NTUWDqxmFGdx(Wce5KTbuTAHk8cLbKAQqHIHq89Aq9XkMD41b)Ntw9ah2o)R1OgPzTSkKZCaal4d4eWBrF2AEj3z0NTUWDqxmFGdx(Wce5KTbkgcX3Rb1hRyTqK2CNM)1AuJ0SwwfYzoaGf8bCc4TWYuXqi(EnO(yfPjiWHI5teJH)1AuJ0SwwfYzoaGf8bCc4TWYuXqi(EnO(yfAz4FwFhUe(a8VwJAKM1YQqoZbaSGpGtaVf9zR5LCNrF26c3bDX8boC5dlqKt2gOyieFVguFScla)RJC83choUnGazDH2G)hMvANL7RXAlbvmeIVxdQpwHfG)1ro(BHdh1qu0wle)1qaankgcX3Rb1hRWcW)6ihqXqi(EnO(yfGnezU9Wh4WLpeW)AncyIgZ3f4a6GIT3fASTTMQv59zK7m6ZwxOnIgb(b5kqKt2gq1QuHskDXGTxGsnzaHfSfAdQFSIHq89Aq9Xkq2(leFV(BwGZFlC44Rq4FTgHYQ)ynS9IO1Gc(0cCGIHq89Aq9Xkq2(leFV(BwGZFlC4i(esyDK)1A8zUyW2lCcaieiwWwOnOMxxGdOxErX4VfMeN68rLhtjLUahqV8IIXFlmjo1zsbLu(mxGdOxErX4VfMeNQpGcEjxnSL2l1W2FZd(yfdH471G6JvGS9xi(E93SaN)w4WrW2dg87cCaDfdfdH471Gc(esyDCuJI2K3NigofdH471Gc(esyDS(yfi2A(xRriYjBdOEuZcfFVodsrjFkgcX3Rbf8jKW6y9Xka(yngatZ6oc5FTgHYas9JOG3NLHUyW2lAu0M8(eXWvWwOnOMskPzTSkAu0M8(eXWv0NT(XkgcX3Rbf8jKW6y9XksnXfi)R1i5oJ(S1fYzoaGf8bCc4TarozBa1pG3bIUarozBWifkgcX3Rbf8jKW6y9XkqPMmGq(xRrAwlRIutCbwGiNSnG6QpG3muFEbk1KbewGiNSnqXqi(EnOGpHewhRpwHC9dZIWdc(0s3iuXqi(EnOGpHewhRpwHyqPgY)AncyIgZ3f4a6GIT3fASTTMQv5vFErJiZVTJT1Gce5KTbupq0kgcX3Rbf8jKW6y9Xk2einef(qOIHq89AqbFcjSowFSc5mhaWc(aob8QyieFVguWNqcRJ1hRqUwJCn)R1OgPzTSkKZCaal4d4eWBHLjLusZAzvaSAn2Fnk(BbIcXPKsOmGu9rurXqi(EnOGpHewhRpw5QHqMNneY)AnsEf4acgZuXqi(EnOGpHewhRpwrAYIT)flhHG3JWNIHq89AqbFcjSowFScGjkW)z9PfGVxRyieFVguWNqcRJ1hRqBenc8dYX)AnsZAzv0OOn59jIHROpBnVqzaPMkuOyieFVguWNqcRJ1hRWDqxmFGdx(q(xRr95fnIm)2o2wdkqKt2gq94arRyieFVguWNqcRJ1hRa4J1yamnR7iK)1Aekdi18efkgcX3Rbf8jKW6y9XkxneY8SHqfdH471Gc(esyDS(yfY1AKRvmeIVxdk4tiH1X6JvWNqcRJkgcX3Rbf8jKW6y9Xk1wIFW8(qwWRIHq89AqbFcjSowFSYYXeB92d)AlXpyEkgkgcX3RbLxHmc4J1yamnR7iK)1Aekdi1pIcEPzTSkAu0M8(eXWv0NTwXqi(EnO8kK6Jvix)WSi8GGpT0ncvmeIVxdkVcP(yfPM4cK)1AKCNrF26c5mhaWc(aob8wGiNSnG6QkgcX3RbLxHuFScXGsnK)1AuFErJiZVTJT1Gce5KTbupoq0kgcX3RbLxHuFSInbsdrHpeQyieFVguEfs9XkstwS9Vy5ie8Ee(umeIVxdkVcP(yfatuG)Z6tlaFVwXqi(EnO8kK6JvOnIgb(b5umeIVxdkVcP(yfOutgqOIHq89Aq5vi1hRqoZbaSGpGtaVkgcX3RbLxHuFSceBn)R1ie5KTbupQzHIVxNbPOKpEPzTSkaBiYC7HpWHlFiOWYuXqi(EnO8kK6JviguQHkgcX3RbLxHuFSc3bDX8boC5d5FTgPzTSkaBiYC7HpWHlFiOWYKsk1Nx0iY8B7yBnOarozBa1denVzOlgS9cXGsnSGTqBqTIHq89Aq5vi1hRC1qiZZgc5FTgDXGTx0qu0TWo86fSfAdQvmeIVxdkVcP(yfY1AKRvmeIVxdkVcP(yf8jKW6i)R1inRLvbydrMBp8boC5dbfwMkgcX3RbLxHuFSYvdHmpBiuXqi(EnO8kK6JvS9UqJTT1kgcX3RbLxHuFSsTL4hmVpKf8QyieFVguEfs9XklhtS1Bp8RTe)G5PyOyieFVguaBpyWVlWb0hjx)WSi8GGpT0nc5FTgFM1o86FiYjBdOA1hqbLu(mxGdOxErX4VfMeN6mPGskDXGTx4eaqiqSGTqBqnVUahqV8IIXFlmjo15Jkp(XkgcX3RbfW2dg87cCa96JvKAIlq(xRrYDg9zRlKZCaal4d4eWBbICY2aQFaVdeDbICY2GrkumeIVxdkGThm43f4a61hRaXwZ)AncrozBa1JAwO471zqkk5tXqi(EnOa2EWGFxGdOxFScXGsnK)1AeWenMVlWb0bfBVl0yBBnvRYR(8IgrMFBhBRbfiYjBdOEGOvmeIVxdkGThm43f4a61hRytG0qu4dHkgcX3RbfW2dg87cCa96JviN5aawWhWjGxfdH471Gcy7bd(DboGE9XkqPMmGq(xRrAwlRIutCbwGiNSnG6QpG3muFEbk1KbewGiNSnqXqi(EnOa2EWGFxGdOxFSI0KfB)lwocbVhHpfdH471Gcy7bd(DboGE9XkaMOa)N1Nwa(ETIHq89AqbS9Gb)UahqV(yLRgczE2qi)R1i5vGdiymtfdH471Gcy7bd(DboGE9Xk0grJa)GC8VwJ0SwwfnkAtEFIy4k6ZwZ7Z0inRLvHCMdaybFaNaElSm5fkdi15JckPekdi1zmfpwXqi(EnOa2EWGFxGdOxFSc3bDX8boC5d5FTgPzTSkxneY8SHWcWfcFuDmtEPzTSkAu0M8(eXWv0NTMskFM(8IgrMFBhBRbfiYjBdOECGO5LCNrF26c5mhaWc(aob8wGiNSnGQde9JvmeIVxdkGThm43f4a61hROrrBY7tedNIHq89AqbS9Gb)UahqV(yfaFSgdGPzDhH8VwJqzaP(ruWlnRLvrJI2K3NigUI(S1kgcX3RbfW2dg87cCa96JvUAiK5zdHkgcX3RbfW2dg87cCa96JvixRrUM)1AKM1YQay1AS)Au83cefIRyieFVguaBpyWVlWb0RpwbFcjSoY)AnsZAzvaSAn2Fnk(BbIcXvmeIVxdkGThm43f4a61hRWDqxmFGdx(qfdH471Gcy7bd(DboGE9Xk2ExOX22A(xRrxmy7flew7G)Z6tlUBWc2cTb1kgcX3RbfW2dg87cCa96JvagHJ)1AmdDXGTxSqyTd(pRpT4Ublyl0guRyieFVguaBpyWVlWb0RpwP2s8dM3hYcEvmeIVxdkGThm43f4a61hRSCmXwV9WV2s8dMxKamrsKnJRgE4ra]] )


end
