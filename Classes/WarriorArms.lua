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

                if conduit.ashen_juggernaut.enabled then addStack( "ashen_juggernaut", nil, 1 ) end
            end,

            copy = { 163201, 281000, 281000 },

            auras = {
                -- Conduit
                ashen_juggernaut = {
                    id = 335234,
                    duration = 8,
                    max_stack = function () return max( 6, conduit.ashen_juggernaut.mod ) end
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
                return 30
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 132355,

            handler = function ()
                applyDebuff( "target", "mortal_wounds" )
                applyDebuff( "target", "deep_wounds" )
                removeBuff( "overpower" )
                removeStack( "deadly_calm" )
            end,
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


    spec:RegisterPack( "Arms", 20201014, [[dGKJybqie0JqiyteXNisQsJsL0PuPSkIK4vsLAwQeDlec1UG6xIQAyQOogcSmIuptfPPrfkxdH02uruFJijnoQq15iskRtfrkZdH6EIk7tQOdQIiwOujpufrQUirsLojcH0kPcMjrsvzNsf(jcHOHsKuXsjsQQEkrnvrvUkrsvSvvej9vecH9sv)LWGr5WclgrpMutMIld2mL(SkmAr50OA1uH8AvcZMKBlYUr63kgUu1XvrKy5Q65knDjxxkBNiX3PIgpcrNxLQ1RIW8Ps7hYEc855Lnrb(oK(S0Nj4mbog(85tp9S0E56Ep4L7d9fXb4LPrc8YNKpTE5(4UAcJppV8oTxdE5SQ63tA5N)bVYAKy9KYF5PMkk(q1FyR8xEsNVxMSXvfruQN0lBIc8Di9zPptWzcCm85ZNknrLAE5OvzZ7LL5PMkk(qpP)HT8YzCJbOEsVSbwTxMiGyNKpTigreX)85roqeqmIi11qcpIrWPxIysFw6ZEzfFR1NNxE50dfiQ4pGYNNVdc855LbAqQaJVlVS(5f88Wl)qk40fXiohIzAFu8HIysfe7m(uVCOl(q9Ypqn(Y3H0(88YHU4d1lBGWOUl0Hk5LbAqQaJVlF574uFEEzGgKkW47YlRFEbpp8YFCaigXi2jFgXKGyKnRfBGWOUl0HkHnJtkIjbXiBwlobP5VlgRq10CJW8qKwSzCsrmxxe7JdaXigXK(Sxo0fFOE59IMsT9kEvW7lFhoMppVmqdsfy8D5L1pVGNhE5RiMEgLzCsX6rn72wXMInd)qk40fXigXKgXCDrSRiwfkGwyNXt(qCb8yGgKkWGysqm9mkZ4KIDgp5dXfWJFifC6IyeJysJy3qSBE5qx8H6L)qkXb8(Y3br955LbAqQaJVlVS(5f88WlBMcBaOx4CAuZIFifC6IyeNdXmTpk(qrmPcIDgFkIjbXUIyBpOuIk(dOwSZm(RCYPgelhIraI56IyeIyvOaAH1kiKcGbAqQadIDZlh6IpuVCA(kuITE(fGV8DCY(88YanivGX3Lxw)8cEE4L3EqPev8hqTyNz8x5KtniwNiM0iMeeZmf2aqVW50OMf)qk40fXiohIzAFu8HIysfe7m(uVCOl(q9YAfesb8LVdPQppVmqdsfy8D5L1pVGNhEzcrmyxGQbSEOgGUGrO4wWoVgWanivGbXKGyeIyvOaAHtXUH(bmqdsfyqmji2veRI)akCXtGOgrVUesFgX6eXi4mI56Iyv8hqHlEce1imCaX6eXi6ze7gI56IyWUavdy9qnaDbJqXTGDEnGbAqQadIjbXieXQqb0cNIDd9dyGgKkWGysqSRiwf)bu4INarnIEDjK(mI1jIrWzeZ1fXQ4pGcx8eiQry4aI1jI54NrSBiMRlIvHcOfof7g6hWanivGbXKGyxrSk(dOWfpbIAe96sCkrrSormcoJyUUiwf)bu4INarncdhqSormIEgXU5LdDXhQxwpQz32k2uSz(Y3HJ7ZZld0GubgFxEz9Zl45HxMqed2fOAaRhQbOlyekUfSZRbmqdsfyqmjigHiwfkGw4uSBOFad0GubgetcIDfXQ4pGcx8eiQr0RlH0NrSormcoJyUUiwf)bu4INarncdhqSormIEgXUHyUUigSlq1awpudqxWiuClyNxdyGgKkWGysqmcrSkuaTWPy3q)agObPcmiMee7kIvXFafU4jquJOxxcPpJyDIyeCgXCDrSk(dOWfpbIAegoGyDIyo(ze7gI56IyvOaAHtXUH(bmqdsfyqmji2veRI)akCXtGOgrVUeNsueRteJGZiMRlIvXFafU4jquJWWbeRteJONrSBE5qx8H6LDgp5dXfW7lFhsnFEEzGgKkW47YlRFEbpp8YKnRfVnJbOcdevg(HqxE5qx8H6LbIe0Tc8LVdco7ZZld0GubgFxEz9Zl45HxwpJYmoP408vOeB98la8dPGtxetcIzaYM1I1JA2TTInfBg2moPiMee7kIriIvHcOf2aHrDxOdvcd0GubgeZ1fXiBwl2aHrDxOdvcBgNue7gIjbXUIyxrmdq2SwSEuZUTvSPyZWTEetcIriIfNaEEb4c2smwrIFKvyGgKkWGy3qmxxeJSzT4c2smwrIFKv4wpIDdXKGyKnRfNG083fJvOAAUryEisl2moPiMee7JdaXigXCSZE5qx8H6LjvHb2A(KV8Dqab(88YanivGX3Lxw)8cEE4L3EqPev8hqTyNz8x5KtniwoeJaeZ1fXieXQqb0cRvqifad0GubgVCOl(q9YP5Rqj265xa(Y3bbs7ZZld0GubgFxEz9Zl45HxE7bLsuXFa1IDMXFLto1GyDIys7LdDXhQxwRGqkGV8DqWP(88YanivGX3Lxw)8cEE4LVIyxrSRigzZAXjin)DXyfQMMBeMhI0IB9i2neZ1fXUIygGSzTy9OMDBRytXMHB9i2neZ1fXUIyKnRfBGWOUl0HkHB9i2ne7gIjbXQqb0cBHxkZlgRGmQsbyGgKkWGy3qmxxe7kIDfXiBwlobP5VlgRq10CJW8qKwCRhXCDrSpoaeRteZXLAi2netcIzaYM1I1JA2TTInfBgU1JysqmYM1IlylXyfj(rwHnJtkIjbXieXQqb0cBHxkZlgRGmQsbyGgKkWGy38YHU4d1l7mJ)kNCQXx(oiWX855LbAqQaJVlVS(5f88WltiIvHcOf2cVuMxmwbzuLcWanivGbXKGyxrmYM1ItqA(7IXkunn3impePf36rmxxeZaKnRfRh1SBBfBk2mCRhXU5LdDXhQxEvrYx(oiGO(88YHU4d1lpsb((Xj8EzGgKkW47Yx(oi4K955LbAqQaJVlVS(5f88WlxHcOf2cVuMxmwbzuLcWanivGbXKGyxrmYM1IlylXyfj(rwHB9iMRlIzaYM1I1JA2TTInfBg2moPiMeeJSzT4c2smwrIFKvyZ4KIysqSpoaeRte7KpJy38YHU4d1l7mJ)kNCQXx(oiqQ6ZZld0GubgFxEz9Zl45HxMqeRcfqlSfEPmVyScYOkfGbAqQaJxo0fFOE5vfjF57Gah3NNxo0fFOEzPW1183fFBZ8YanivGX3LV8DqGuZNNxo0fFOEzEQhOgo9qifUUM)UxgObPcm(U8LV8Yarc6wb(88DqGppVmqdsfy8D5L1pVGNhE5hsbNUigX5qmt7JIpuetQGyNXN6LdDXhQx(bQXx(oK2NNxo0fFOEzdeg1DHoujVmqdsfy8D5lFhN6ZZld0GubgFxEz9Zl45Hx(JdaXigXiQ0iMeeJSzT4eKM)UyScvtZncZdrAXMXjfXCDrSpoaeJyet6ZE5qx8H6L3lAk12R4vbVV8D4y(88YanivGX3Lxw)8cEE4L1ZOmJtkwpQz32k2uSz4hsbNUigXiM0iMRlIDfXQqb0c7mEYhIlGhd0GubgetcIPNrzgNuSZ4jFiUaE8dPGtxeJyetAe7Mxo0fFOE5pKsCaVV8DquFEEzGgKkW47YlRFEbpp8YeIyWUavd4eKM)UyScvtZncZdrAXPWrZJyUUi2veJSzT4eKM)UyScvtZncZdrAXTEeZ1fX0ZOmJtkobP5VlgRq10CJW8qKw8dPGtxeRteJGZi2nVCOl(q9Y6rn72wXMInZx(oozFEEzGgKkW47YlRFEbpp8YeIyWUavd4eKM)UyScvtZncZdrAXPWrZJyUUi2veJSzT4eKM)UyScvtZncZdrAXTEeZ1fX0ZOmJtkobP5VlgRq10CJW8qKw8dPGtxeRteJGZi2nVCOl(q9YoJN8H4c49LVdPQppVmqdsfy8D5L1pVGNhEzZuyda9cNtJAw8dPGtxeJ4CiMP9rXhkIjvqSZ4trmji2veB7bLsuXFa1IDMXFLto1Gy5qmcqmxxeJqeB7bLsuXFa1IDMXFLto1GyDIyeGysqmcrSkuaTWAfesbWanivGbXU5LdDXhQxonFfkXwp)cWx(oCCFEEzGgKkW47YlRFEbpp8YxrSThukrf)bul2zg)vo5udI1jIjnIjbXmtHna0lConQzXpKcoDrmIZHyM2hfFOiMubXoJpfXUHyUUi2veB7bLsuXFa1IDMXFLto1GyDIyNIy38YHU4d1lRvqifWx(oKA(88YanivGX3Lxw)8cEE4LjeXiBwlobP5VlgRq10CJW8qKwCRhXKGyKnRfxWwIXks8JSc36rmji2hhaIrmID6zetcIriIr2SwSbcJ6UqhQeU17LdDXhQxMufgyR5t(Y3bbN955LbAqQaJVlVS(5f88Wlt2SwCcsZFxmwHQP5gH5HiT4wpI56IyKnRfBGWOUl0HkHB9iMRlIzaYM1I1JA2TTInfBgU1JyUUigzZAXfSLySIe)iRWTEVCOl(q9Yarc6wb(Y3bbe4ZZld0GubgFxEz9Zl45HxMSzTy932mo9qe7gnvHB9iMeeJSzT4eKM)UyScvtZncZdrAXMXj1lh6IpuV8QIKV8DqG0(88YanivGX3Lxw)8cEE4LFifC6IyeNdXmTpk(qrmPcIDgFkIjbXQ4pGcx8eiQry4aI1jIjv9YHU4d1l)a14lFheCQppVCOl(q9YJuGVFCcVxgObPcm(U8LVdcCmFEE5qx8H6L1d1ajQxgObPcm(U8LVdciQppVCOl(q9Yarc6wbEzGgKkW47Yx(oi4K955LdDXhQxwkCDn)DX32mVmqdsfy8D5lFheiv955LdDXhQxMN6bQHtpesHRR5V7LbAqQaJVlF5lVSbSrtv(88DqGppVCOl(q9Y6S4paVmqdsfy8D5lFhs7ZZlh6IpuVCFlLaLxgObPcm(U8LVJt955LbAqQaJVlVS(5f88WlFfXQ4pGcNbHQYW96cXigXKMaeZ1fXQqb0cNIDd9dyGgKkWGysqSk(dOWzqOQmCVUqmIrStpze7gIjbXUIyKnRfNG083fJvOAAUryEislU1JyUUigzZAXhT4n8GkgRiob8tLHB9i2neZ1fXieXGDbQgWjin)DXyfQMMBeMhI0ItHJMhXKGyeIyWUavdy9qnaDbJqXTGDEnGtHJMhXKGyxrSk(dOWzqOQmCVUqmIrmPjaXCDrSkuaTWPy3q)agObPcmiMeeRI)akCgeQkd3RleJye70tgXUHysqmdq2SwSEuZUTvSPyZWTEeZ1fXS8JSs8qk40fXigXKMOE5qx8H6L7NIpuF57WX855LbAqQaJVlVS(5f88Wlt2SwCcsZFxmwHQP5gH5HiT4wpIjbXiBwlUGTeJvK4hzfU1JyUUigzZAXhT4n8GkgRiob8tLHB9iMeeZaKnRfRh1SBBfBk2mCRhXCDrmYM1IxaQmo9q8XbGB9iMRlIDfXieXGDbQgWjin)DXyfQMMBeMhI0ItHJMhXKGyeIyWUavdy9qnaDbJqXTGDEnGtHJMhXKGyeIyWUavdys1mgXyfvgiakKUJtHJMhXKGygGSzTy9OMDBRytXMHB9i2nVCOl(q9YKQzmcB7V7lFhe1NNxgObPcm(U8Y6NxWZdVmzZAXjin)DXyfQMMBeMhI0IB9iMeeJSzT4c2smwrIFKv4wpI56IyKnRfF0I3WdQySI4eWpvgU1Jysqmdq2SwSEuZUTvSPyZWTEeZ1fXiBwlEbOY40dXhhaU1JyUUi2veJqed2fOAaNG083fJvOAAUryEislofoAEetcIriIb7cunG1d1a0fmcf3c251aofoAEetcIriIb7cunGjvZyeJvuzGaOq6oofoAEetcIzaYM1I1JA2TTInfBgU1Jy38YHU4d1ltc)c)fC6HV8DCY(88YanivGX3Lxw)8cEE4LjBwlobP5VlgRq10CJW8qKwSzCsrmji2hhaIrmIr0ZiMee7kIPNrzgNuCA(kuITE(fa(HuWPlI1jIDOniMRlIDfXQ4pGcNbHQYW96cXigXK(mI56IyvOaAHtXUH(bmqdsfyqmjiwf)bu4miuvgUxxigXi2PefXUHy38YHU4d1lhVoOGOM)bA5lFhsvFEEzGgKkW47YlRFEbpp8YgGSzTy9OMDBRytXMHnJtQxo0fFOEzf)iRwHJAMJeqlF57WX955LbAqQaJVlVS(5f88Wlt2SwCcsZFxmwHQP5gH5HiT4wpIjbXiBwlUGTeJvK4hzfU1JyUUigzZAXhT4n8GkgRiob8tLHB9iMeeZaKnRfRh1SBBfBk2mCRhXCDrmYM1IxaQmo9q8XbGB9iMRlIDfXieXGDbQgWjin)DXyfQMMBeMhI0ItHJMhXKGyeIyWUavdy9qnaDbJqXTGDEnGtHJMhXKGyeIyWUavdys1mgXyfvgiakKUJtHJMhXKGygGSzTy9OMDBRytXMHB9i2nVCOl(q9Yw(dKQzm(Y3HuZNNxgObPcm(U8Y6NxWZdVmzZAXjin)DXyfQMMBeMhI0IB9iMeeJSzT4c2smwrIFKv4wpI56IyKnRfF0I3WdQySI4eWpvgU1Jysqmdq2SwSEuZUTvSPyZWTEeZ1fXiBwlEbOY40dXhhaU1JyUUi2veJqed2fOAaNG083fJvOAAUryEislofoAEetcIriIb7cunG1d1a0fmcf3c251aofoAEetcIriIb7cunGjvZyeJvuzGaOq6oofoAEetcIzaYM1I1JA2TTInfBgU1Jy38YHU4d1lhunS1hkHoukF57GGZ(88YanivGX3Lxw)8cEE4LnazZAX6rn72wXMIndBgNuetcIr2SwCcsZFxmwHQP5gH5HiTyZ4KIysqm9mkZ4KItZxHsS1ZVaWpKcoD9YHU4d1ltghIXkQNRVy9LVdciWNNxgObPcm(U8YHU4d1lhBMuckSIpoX8c98HYlRFEbpp8YeIygGSzT4poX8c98HsyaYM1IB9iMRlIDfXUIyv8hqHZGqvz4EDHyeJysFgtaI56IyvOaAHtXUH(bmqdsfyqmjiwf)bu4miuvgUxxigXi2PeftaIDdXKGyxrmYM1ItqA(7IXkunn3impePf36rmji2vetpJYmoP4eKM)UyScvtZncZdrAXpKcoDrmIrmcoFYiMRlIPNrzgNuCcsZFxmwHQP5gH5HiT4hsbNUigXigbeivrmjiMLFKvIhsbNUigXiM0NrmjigHiwfkGw4uSBOFad0Gubge7gI56IyKnRfF0I3WdQySI4eWpvgU1Jysqmdq2SwSEuZUTvSPyZWTEe7gIDdXCDrmyxGQbSEOgGUGrO4wWoVgWPWrZJysqSk(dOWzqOQmCVUqmIrmPpJyUUi2veRI)akCgeQkd3RleJye70ZycqmjiMbiBwlwputtxCPaco9cHbiBwlU1JysqmcrmyxGQbCcsZFxmwHQP5gH5HiT4u4O5rmjigHigSlq1awpudqxWiuClyNxd4u4O5rSBiMRlIDfXieXmazZAX6HAA6IlfqWPximazZAXTEetcIriIb7cunGtqA(7IXkunn3impePfNchnpIjbXieXGDbQgW6HAa6cgHIBb78AaNchnpIjbXmazZAX6rn72wXMInd36rSBEzAKaVCSzsjOWk(4eZl0ZhkF57GaP955LbAqQaJVlVCOl(q9YXj2S4JvyhAjgROFCcVxw)8cEE4LlEce1imCaXigXKQNrmji2vetpJYmoPy9OMDBRytXMHFifC6IyeJyeinI56IyxrSkuaTWoJN8H4c4XanivGbXKGy6zuMXjf7mEYhIlGh)qk40fXigXiqAe7gIDdXCDrmcrmdq2SwSEuZUTvSPyZWTEetcIriIr2SwCbBjgRiXpYkCRhXKGyeIyKnRfNG083fJvOAAUryEislU1JysqSINarncdhqSormci6zVmnsGxooXMfFSc7qlXyf9Jt49LVdco1NNxgObPcm(U8Y6NxWZdVmHigSlq1aobP5VlgRq10CJW8qKwCkC08iMRlIDfXiBwlobP5VlgRq10CJW8qKwCRhXCDrm9mkZ4KItqA(7IXkunn3impePf)qk40fX6eXCmIIy38YHU4d1lhsjQ49LVdcCmFEEzGgKkW47YlRFEbpp8Y6zuMXjfRh1SBBfBk2m8dPGtxeJyeZXrmxxe7kIvHcOf2z8KpexapgObPcmiMeetpJYmoPyNXt(qCb84hsbNUigXiMJJy38YHU4d1l3wqWliT(Y3bbe1NNxgObPcm(U8Y6NxWZdV82dkLOI)aQf7mJ)kNCQbX6eXiaXKGyxrm9mkZ4KIjvHb2A(e(HuWPlI1jIrWzeZ1fX0ZOmJtkwpQz32k2uSz4hsbNUiwNiMJJyUUiwCc45fGlylXyfj(rwHbAqQadIDZlh6IpuV86eGEo9qS1ZVawF57GGt2NNxgObPcm(U8Y6NxWZdV8veJSzT4c2smwrIFKv4wpI56Iyxrmdq2SwSEuZUTvSPyZWTEetcIriIfNaEEb4c2smwrIFKvyGgKkWGy3qSBiMee7kIz5hzL4HuWPlI1jIj1oJyUUi2veRI)akCgeQkd3RleJyet6ZiMRlIvHcOfof7g6hWanivGbXKGyv8hqHZGqvz4EDHyeJyNsue7gIDZlh6IpuVmPAgJySIkdeafs39LVdcKQ(88YanivGX3Lxw)8cEE4LjeXmazZAX6rn72wXMInd36rmjigHigzZAXfSLySIe)iRWTEVCOl(q9Y9TNBVZPhcsvSLV8DqGJ7ZZld0GubgFxEz9Zl45HxMqeZaKnRfRh1SBBfBk2mCRhXKGyeIyKnRfxWwIXks8JSc369YHU4d1l)8(Efi4uX2hAWx(oiqQ5ZZld0GubgFxEz9Zl45HxMqeZaKnRfRh1SBBfBk2mCRhXKGyeIyKnRfxWwIXks8JSc369YHU4d1l7CELrkaNkEyhAq1GV8Di9zFEEzGgKkW47YlRFEbpp8YeIygGSzTy9OMDBRytXMHB9iMeeJqeJSzT4c2smwrIFKv4wVxo0fFOEz7OBlyeXjGNxGGeIKV8Dinb(88YanivGX3Lxw)8cEE4LjeXmazZAX6rn72wXMInd36rmjigHigzZAXfSLySIe)iRWTEVCOl(q9Ype9C6HWQIeS(Y3H0s7ZZld0GubgFxEz9Zl45HxMqeZaKnRfRh1SBBfBk2mCRhXKGyeIyKnRfxWwIXks8JSc36rmjiMzkSEOAGwFuGryvrceKTNIFifC6Iy5qSZE5qx8H6L1dvd06JcmcRksGV8Di9P(88YanivGX3Lxw)8cEE4LjBwl(b9fkyxHDEnGB9E5qx8H6LRmq0OKtJAe251GV8DiTJ5ZZld0GubgFxEz9Zl45HxMqeRcfqlSZ4jFiUaEmqdsfyqmjiMEgLzCsX6rn72wXMInd)qk40fXigXikIjbXUIyw(rwjEifC6IyDIystWzeZ1fXUIyv8hqHZGqvz4EDHyeJysFgXCDrSkuaTWPy3q)agObPcmiMeeRI)akCgeQkd3RleJye7uIIy3qmxxeZYpYkXdPGtxeJye7ucqSBE5qx8H6LpAXB4bvmwrCc4NkZx(oKMO(88YanivGX3Lxw)8cEE4LRqb0c7mEYhIlGhd0GubgetcIPNrzgNuSZ4jFiUaE8dPGtxeJyeJOiMee7kIz5hzL4HuWPlI1jIjnbNrmxxe7kIvXFafodcvLH71fIrmIj9zeZ1fXQqb0cNIDd9dyGgKkWGysqSk(dOWzqOQmCVUqmIrStjkIDdXCDrml)iRepKcoDrmIrStjaXU5LdDXhQx(OfVHhuXyfXjGFQmF57q6t2NNxgObPcm(U8Y6NxWZdVmHiwfkGwyNXt(qCb8yGgKkWGysqm9mkZ4KI1JA2TTInfBg(HuWPlIrmIraIjbXUIyw(rwjEifC6IyDIyeq0ZiMRlIDfXQ4pGcNbHQYW96cXigXK(mI56IyvOaAHtXUH(bmqdsfyqmjiwf)bu4miuvgUxxigXi2PefXUHy38YHU4d1lNG083fJvOAAUryEisRV8DiTu1NNxgObPcm(U8Y6NxWZdVCfkGwyNXt(qCb8yGgKkWGysqm9mkZ4KIDgp5dXfWJFifC6IyeJyeGysqSRiMLFKvIhsbNUiwNigbe9mI56IyxrSk(dOWzqOQmCVUqmIrmPpJyUUiwfkGw4uSBOFad0GubgetcIvXFafodcvLH71fIrmIDkrrSBi2nVCOl(q9Yjin)DXyfQMMBeMhI06lFhs74(88YHU4d1lV9q8IXkiJT4d1ld0GubgFx(Y3H0snFEE5qx8H6L1d9Ksd(5xbzqPW7LbAqQaJVlF5740Z(88YHU4d1lhunhOLiSf8B2OVWld0GubgFx(Y3XPe4ZZld0GubgFxEz9Zl45HxMSzT4TzmavyGOYWTEeZ1fX(4aqSoZHyo2zeZ1fXQ4pGcx8eiQry4aIrmIDOnE5qx8H6L1d1ajQV8DCQ0(88YanivGX3Lxw)8cEE4LVIyvOaAHtXUH(bmqdsfyqmjiwf)bu4miuvgUxxigXi2PefXUHyUUiwf)bu4miuvgUxxigXiM0N9YHU4d1l)nQi0fFOcfFlVSIVLGgjWldejOBf4lFhNEQppVmqdsfy8D5LdDXhQx(BurOl(qfk(wEzfFlbnsGxE50dfiQ4pGYx(Yl3)GEsKr5ZZ3bb(88YHU4d1ltgvPaXMnTYld0GubgFx(Y3H0(88YanivGX3LxMgjWlhNyZIpwHDOLySI(Xj8E5qx8H6LJtSzXhRWo0smwr)4eEF574uFEEzGgKkW47YlRFEbpp8YvOaAHTWlL5fJvqgvPamqdsfyqmxxeJqeRcfqlSfEPmVyScYOkfGbAqQadIjbXkEce1imCaX6eXiGON9YHU4d1lNG083fJvOAAUryEisRV8D4y(88YanivGX3Lxw)8cEE4LRqb0cBHxkZlgRGmQsbyGgKkWGyUUiwfkGw4uSBOFad0GubgetcIv8eiQry4aI1jIjnbNrmxxeRcfql8dudgObPcmiMee7kIv8eiQry4aI1jIjnbNrmxxeR4jquJWWbeJyeJahJOi2nVCOl(q9YhT4n8GkgRiob8tL5lF5lVSuGF5d13H0NL(mbNj4uVSZ4PC6X6LjIM6NVadI5yiwOl(qrmfFRfJCWl3)JLRaVmraXojFArmIiI)5ZJCGiGyerQRHeEeJah7set6ZsFg5aYbIaIDsplOhWEsd5araXiIrStIXagetQtlLafg5araXiIrStIXage7KkxxZFhXK6VTz5ten1dudNEGyNu56A(7yKdebeJigXojgdyqSUIQuaIjNnTcXQbX6FqpjYOqStIuhP(WihicigrmIj1LibDR4dfEPExetQZdA(YhkIXxeZakOadg5araXiIrStIXagetQNfqmIOfKwmYbKdebetQlrc6wbgeJeSZdiMEsKrHyKWbNUye7KO1qFTigDOeXzXNSnfIf6Ip0fXgQ6og5araXcDXh6I7FqpjYOYzvXEbYbIaIf6Ip0f3)GEsKr1DU8TZyqoqeqSqx8HU4(h0tImQUZLF0osaTIIpuKdebetMg9B2ui2hCdIr2SwWGyBf1IyKGDEaX0tImkeJeo40fXcQbX6FGiUFQItpqm(IyMHcyKdHU4dDX9pONezuDNlFYOkfi2SPvihcDXh6I7FqpjYO6ox(Tfe8csxsJeKloXMfFSc7qlXyf9Jt4roe6Ip0f3)GEsKr1DU8tqA(7IXkunn3impeP9sUnxfkGwyl8szEXyfKrvkad0GubgxxcRqb0cBHxkZlgRGmQsbyGgKkWiP4jquJWWHojGONroe6Ip0f3)GEsKr1DU8pAXB4bvmwrCc4Nk7sUnxfkGwyl8szEXyfKrvkad0Gubgx3kuaTWPy3q)agObPcmskEce1imCOtPj4SRBfkGw4hOgmqdsfyKCT4jquJWWHoLMGZUUfpbIAegoqmbogrVHCa5araXK6sKGUvGbXaPa)DeR4jaXQmaXcDnpIXxelKsWvbPcWihcDXh6MtNf)bGCi0fFOB35YVVLsGc5qOl(q3UZLF)u8HEj3M7Af)bu4miuvgUxxelnbUUvOaAHtXUH(bmqdsfyKuXFafodcvLH71fXNEY3KCLSzT4eKM)UyScvtZncZdrAXTExxYM1IpAXB4bvmwrCc4Nkd36V56siSlq1aobP5VlgRq10CJW8qKwCkC08sie2fOAaRhQbOlyekUfSZRbCkC08sUwXFafodcvLH71fXstGRBfkGw4uSBOFad0Gubgjv8hqHZGqvz4EDr8PN8njgGSzTy9OMDBRytXMHB9UUw(rwjEifC6sS0ef5qOl(q3UZLpPAgJW2(7xYT5iBwlobP5VlgRq10CJW8qKwCRxczZAXfSLySIe)iRWTExxYM1IpAXB4bvmwrCc4Nkd36LyaYM1I1JA2TTInfBgU176s2Sw8cqLXPhIpoaCR319kHWUavd4eKM)UyScvtZncZdrAXPWrZlHqyxGQbSEOgGUGrO4wWoVgWPWrZlHqyxGQbmPAgJySIkdeafs3XPWrZlXaKnRfRh1SBBfBk2mCR)gYHqx8HUDNlFs4x4VGtpUKBZr2SwCcsZFxmwHQP5gH5HiT4wVeYM1IlylXyfj(rwHB9UUKnRfF0I3WdQySI4eWpvgU1lXaKnRfRh1SBBfBk2mCR31LSzT4fGkJtpeFCa4wVR7vcHDbQgWjin)DXyfQMMBeMhI0ItHJMxcHWUavdy9qnaDbJqXTGDEnGtHJMxcHWUavdys1mgXyfvgiakKUJtHJMxIbiBwlwpQz32k2uSz4w)nKdHU4dD7ox(XRdkiQ5FGwxYT5iBwlobP5VlgRq10CJW8qKwSzCsL8Xbqmrpl5QEgLzCsXP5Rqj265xa4hsbNUDEOnUUxR4pGcNbHQYW96IyPp76wHcOfof7g6hWanivGrsf)bu4miuvgUxxeFkrVDd5qOl(q3UZLVIFKvRWrnZrcO1LCBodq2SwSEuZUTvSPyZWMXjf5qOl(q3UZLVL)aPAgZLCBoYM1ItqA(7IXkunn3impePf36Lq2SwCbBjgRiXpYkCR31LSzT4Jw8gEqfJveNa(PYWTEjgGSzTy9OMDBRytXMHB9UUKnRfVauzC6H4Jda36DDVsiSlq1aobP5VlgRq10CJW8qKwCkC08sie2fOAaRhQbOlyekUfSZRbCkC08sie2fOAatQMXigROYabqH0DCkC08smazZAX6rn72wXMInd36VHCi0fFOB35YpOAyRpucDOuxYT5iBwlobP5VlgRq10CJW8qKwCRxczZAXfSLySIe)iRWTExxYM1IpAXB4bvmwrCc4Nkd36LyaYM1I1JA2TTInfBgU176s2Sw8cqLXPhIpoaCR319kHWUavd4eKM)UyScvtZncZdrAXPWrZlHqyxGQbSEOgGUGrO4wWoVgWPWrZlHqyxGQbmPAgJySIkdeafs3XPWrZlXaKnRfRh1SBBfBk2mCR)gYHqx8HUDNlFY4qmwr9C9f7LCBodq2SwSEuZUTvSPyZWMXjvczZAXjin)DXyfQMMBeMhI0InJtQe9mkZ4KItZxHsS1ZVaWpKcoDroe6Ip0T7C53wqWliDjnsqUyZKsqHv8XjMxONpuxYT5i0aKnRf)XjMxONpucdq2SwCR31961k(dOWzqOQmCVUiw6ZycCDRqb0cNIDd9dyGgKkWiPI)akCgeQkd3RlIpLOycUj5kzZAXjin)DXyfQMMBeMhI0IB9sUQNrzgNuCcsZFxmwHQP5gH5HiT4hsbNUetW5t21vpJYmoP4eKM)UyScvtZncZdrAXpKcoDjMacKQsS8JSs8qk40LyPplHWkuaTWPy3q)agObPcm3CDjBwl(OfVHhuXyfXjGFQmCRxIbiBwlwpQz32k2uSz4w)TBUUWUavdy9qnaDbJqXTGDEnGtHJMxsf)bu4miuvgUxxel9zx3Rv8hqHZGqvz4EDr8PNXeiXaKnRfRhQPPlUuabNEHWaKnRf36LqiSlq1aobP5VlgRq10CJW8qKwCkC08sie2fOAaRhQbOlyekUfSZRbCkC083CDVsObiBwlwputtxCPaco9cHbiBwlU1lHqyxGQbCcsZFxmwHQP5gH5HiT4u4O5LqiSlq1awpudqxWiuClyNxd4u4O5LyaYM1I1JA2TTInfBgU1Fd5qOl(q3UZLFBbbVG0L0ib5ItSzXhRWo0smwr)4e(l52CfpbIAegoqSu9SKR6zuMXjfRh1SBBfBk2m8dPGtxIjqAx3RvOaAHDgp5dXfWJbAqQaJe9mkZ4KIDgp5dXfWJFifC6smbsF7MRlHgGSzTy9OMDBRytXMHB9siKSzT4c2smwrIFKv4wVecjBwlobP5VlgRq10CJW8qKwCRxsXtGOgHHdDsarpJCi0fFOB35YpKsuXFj3MJqyxGQbCcsZFxmwHQP5gH5HiT4u4O5DDVs2SwCcsZFxmwHQP5gH5HiT4wVRREgLzCsXjin)DXyfQMMBeMhI0IFifC62PJr0BihcDXh62DU8Bli4fK2l52C6zuMXjfRh1SBBfBk2m8dPGtxIDCx3RvOaAHDgp5dXfWJbAqQaJe9mkZ4KIDgp5dXfWJFifC6sSJFd5qOl(q3UZL)6eGEo9qS1ZVa2l52CBpOuIk(dOwSZm(RCYPMojqYv9mkZ4KIjvHb2A(e(HuWPBNeC21vpJYmoPy9OMDBRytXMHFifC62PJ76gNaEEb4c2smwrIFKvyGgKkWCd5qOl(q3UZLpPAgJySIkdeafs3VKBZDLSzT4c2smwrIFKv4wVR7vdq2SwSEuZUTvSPyZWTEjegNaEEb4c2smwrIFKvyGgKkWC7MKRw(rwjEifC62Pu7SR71k(dOWzqOQmCVUiw6ZUUvOaAHtXUH(bmqdsfyKuXFafodcvLH71fXNs0B3qoe6Ip0T7C533EU9oNEiivXwxYT5i0aKnRfRh1SBBfBk2mCRxcHKnRfxWwIXks8JSc36roe6Ip0T7C5)8(Efi4uX2hA4sUnhHgGSzTy9OMDBRytXMHB9siKSzT4c2smwrIFKv4wpYHqx8HUDNlFNZRmsb4uXd7qdQgUKBZrObiBwlwpQz32k2uSz4wVecjBwlUGTeJvK4hzfU1JCi0fFOB35Y3o62cgrCc45fiiHiDj3MJqdq2SwSEuZUTvSPyZWTEjes2SwCbBjgRiXpYkCRh5qOl(q3UZL)drpNEiSQib7LCBocnazZAX6rn72wXMInd36LqizZAXfSLySIe)iRWTEKdHU4dD7ox(6HQbA9rbgHvfj4sUnhHgGSzTy9OMDBRytXMHB9siKSzT4c2smwrIFKv4wVeZuy9q1aT(OaJWQIeiiBpf)qk40n3zKdHU4dD7ox(vgiAuYPrnc78A4sUnhzZAXpOVqb7kSZRbCRh5qOl(q3UZL)rlEdpOIXkIta)uzxYT5iScfqlSZ4jFiUaEmqdsfyKONrzgNuSEuZUTvSPyZWpKcoDjMOsUA5hzL4HuWPBNstWzx3Rv8hqHZGqvz4EDrS0NDDRqb0cNIDd9dyGgKkWiPI)akCgeQkd3RlIpLO3CDT8JSs8qk40L4tj4gYHqx8HUDNl)Jw8gEqfJveNa(PYUKBZvHcOf2z8KpexapgObPcms0ZOmJtk2z8Kpexap(HuWPlXevYvl)iRepKcoD7uAco76ETI)akCgeQkd3RlIL(SRBfkGw4uSBOFad0Gubgjv8hqHZGqvz4EDr8Pe9MRRLFKvIhsbNUeFkb3qoe6Ip0T7C5NG083fJvOAAUryEis7LCBocRqb0c7mEYhIlGhd0Gubgj6zuMXjfRh1SBBfBk2m8dPGtxIjqYvl)iRepKcoD7KaIE219Af)bu4miuvgUxxel9zx3kuaTWPy3q)agObPcmsQ4pGcNbHQYW96I4tj6TBihcDXh62DU8tqA(7IXkunn3impeP9sUnxfkGwyNXt(qCb8yGgKkWirpJYmoPyNXt(qCb84hsbNUetGKRw(rwjEifC62jbe9SR71k(dOWzqOQmCVUiw6ZUUvOaAHtXUH(bmqdsfyKuXFafodcvLH71fXNs0B3qoe6Ip0T7C5V9q8IXkiJT4df5qOl(q3UZLVEONuAWp)kidkfEKdHU4dD7ox(bvZbAjcBb)Mn6lqoe6Ip0T7C5RhQbs0l52CKnRfVnJbOcdevgU176(Xb0zoh7SRBf)bu4INarncdhi(qBqoe6Ip0T7C5)nQi0fFOcfFRlPrcYbejOBfCj3M7AfkGw4uSBOFad0Gubgjv8hqHZGqvz4EDr8Pe9MRBf)bu4miuvgUxxel9zKdHU4dD7ox(FJkcDXhQqX36sAKGClNEOarf)buihqoe6Ip0fdejOBfK7bQ5sUn3dPGtxIZzAFu8HkvoJpf5qOl(qxmqKGUvq35Y3aHrDxOdvc5qOl(qxmqKGUvq35YFVOPuBVIxf8xYT5(4aiMOslHSzT4eKM)UyScvtZncZdrAXMXj119JdGyPpJCi0fFOlgisq3kO7C5)HuId4V8sUnNEgLzCsX6rn72wXMInd)qk40LyPDDVwHcOf2z8KpexapgObPcms0ZOmJtk2z8Kpexap(HuWPlXsFd5qOl(qxmqKGUvq35YxpQz32k2uSzxYT5ie2fOAaNG083fJvOAAUryEislofoAEx3RKnRfNG083fJvOAAUryEislU176QNrzgNuCcsZFxmwHQP5gH5HiT4hsbNUDsW5BihcDXh6IbIe0Tc6ox(oJN8H4c4VKBZriSlq1aobP5VlgRq10CJW8qKwCkC08UUxjBwlobP5VlgRq10CJW8qKwCR31vpJYmoP4eKM)UyScvtZncZdrAXpKcoD7KGZ3qoe6Ip0fdejOBf0DU8tZxHsS1ZVaUKBZzMcBaOx4CAuZIFifC6sCot7JIpuPYz8PsUU9GsjQ4pGAXoZ4VYjNAYrGRlHBpOuIk(dOwSZm(RCYPMojqcHvOaAH1kiKcGbAqQaZnKdHU4dDXarc6wbDNlFTccPaxYT5UU9GsjQ4pGAXoZ4VYjNA6uAjMPWga6foNg1S4hsbNUeNZ0(O4dvQCgF6nx3RBpOuIk(dOwSZm(RCYPMop9gYHqx8HUyGibDRGUZLpPkmWwZNUKBZrizZAXjin)DXyfQMMBeMhI0IB9siBwlUGTeJvK4hzfU1l5JdG4tplHqYM1Inqyu3f6qLWTEKdHU4dDXarc6wbDNlFGibDRGl52CKnRfNG083fJvOAAUryEislU176s2SwSbcJ6UqhQeU176AaYM1I1JA2TTInfBgU176s2SwCbBjgRiXpYkCRh5qOl(qxmqKGUvq35YFvr6sUnhzZAX6VTzC6Hi2nAQc36Lq2SwCcsZFxmwHQP5gH5HiTyZ4KICi0fFOlgisq3kO7C5)a1Cj3M7HuWPlX5mTpk(qLkNXNkPI)akCXtGOgHHdDkvroe6Ip0fdejOBf0DU8hPaF)4eEKdHU4dDXarc6wbDNlF9qnqIICi0fFOlgisq3kO7C5dejOBfGCi0fFOlgisq3kO7C5lfUUM)U4BBgYHqx8HUyGibDRGUZLpp1dudNEiKcxxZFh5aYHqx8HU4LtpuGOI)aQCpqnxYT5EifC6sCot7JIpuPYz8PihcDXh6Ixo9qbIk(dO6ox(gimQ7cDOsihcDXh6Ixo9qbIk(dO6ox(7fnLA7v8QG)sUn3hhaXN8zjKnRfBGWOUl0HkHnJtQeYM1ItqA(7IXkunn3impePfBgNux3poaIL(mYHqx8HU4LtpuGOI)aQUZL)hsjoG)sUn3v9mkZ4KI1JA2TTInfBg(HuWPlXs76ETcfqlSZ4jFiUaEmqdsfyKONrzgNuSZ4jFiUaE8dPGtxIL(2nKdHU4dDXlNEOarf)buDNl)08vOeB98lGl52CMPWga6foNg1S4hsbNUeNZ0(O4dvQCgFQKRBpOuIk(dOwSZm(RCYPMCe46syfkGwyTccPayGgKkWCd5qOl(qx8YPhkquXFav35YxRGqkWLCBUThukrf)bul2zg)vo5utNslXmf2aqVW50OMf)qk40L4CM2hfFOsLZ4troe6Ip0fVC6Hcev8hq1DU81JA2TTInfB2LCBocHDbQgW6HAa6cgHIBb78Aad0GubgjewHcOfof7g6hWanivGrY1k(dOWfpbIAe96si95oj4SRBf)bu4INarncdh6KONV56c7cunG1d1a0fmcf3c251agObPcmsiScfqlCk2n0pGbAqQaJKRv8hqHlEce1i61Lq6ZDsWzx3k(dOWfpbIAego0PJF(MRBfkGw4uSBOFad0GubgjxR4pGcx8eiQr0RlXPeTtco76wXFafU4jquJWWHoj65BihcDXh6Ixo9qbIk(dO6ox(oJN8H4c4VKBZriSlq1awpudqxWiuClyNxdyGgKkWiHWkuaTWPy3q)agObPcmsUwXFafU4jquJOxxcPp3jbNDDR4pGcx8eiQry4qNe98nxxyxGQbSEOgGUGrO4wWoVgWanivGrcHvOaAHtXUH(bmqdsfyKCTI)akCXtGOgrVUesFUtco76wXFafU4jquJWWHoD8Z3CDRqb0cNIDd9dyGgKkWi5Af)bu4INarnIEDjoLODsWzx3k(dOWfpbIAego0jrpFd5qOl(qx8YPhkquXFav35Yhisq3k4sUnhzZAXBZyaQWarLHFi0fYHqx8HU4LtpuGOI)aQUZLpPkmWwZNUKBZPNrzgNuCA(kuITE(fa(HuWPRedq2SwSEuZUTvSPyZWMXjvYvcRqb0cBGWOUl0HkHbAqQaJRlzZAXgimQ7cDOsyZ4KEtY1RgGSzTy9OMDBRytXMHB9simob88cWfSLySIe)iRWanivG5MRlzZAXfSLySIe)iRWT(BsiBwlobP5VlgRq10CJW8qKwSzCsL8XbqSJDg5qOl(qx8YPhkquXFav35YpnFfkXwp)c4sUn32dkLOI)aQf7mJ)kNCQjhbUUewHcOfwRGqkagObPcmihcDXh6Ixo9qbIk(dO6ox(AfesbUKBZT9GsjQ4pGAXoZ4VYjNA6uAKdHU4dDXlNEOarf)buDNlFNz8x5KtnxYT5UE9kzZAXjin)DXyfQMMBeMhI0IB93CDVAaYM1I1JA2TTInfBgU1FZ19kzZAXgimQ7cDOs4w)TBsQqb0cBHxkZlgRGmQsbyGgKkWCZ196vYM1ItqA(7IXkunn3impePf36DD)4a60XLA3KyaYM1I1JA2TTInfBgU1lHSzT4c2smwrIFKvyZ4KkHWkuaTWw4LY8IXkiJQuagObPcm3qoe6Ip0fVC6Hcev8hq1DU8xvKUKBZryfkGwyl8szEXyfKrvkad0GubgjxjBwlobP5VlgRq10CJW8qKwCR311aKnRfRh1SBBfBk2mCR)gYHqx8HU4LtpuGOI)aQUZL)if47hNWJCi0fFOlE50dfiQ4pGQ7C57mJ)kNCQ5sUnxfkGwyl8szEXyfKrvkad0GubgjxjBwlUGTeJvK4hzfU176AaYM1I1JA2TTInfBg2moPsiBwlUGTeJvK4hzf2moPs(4a68KpFd5qOl(qx8YPhkquXFav35YFvr6sUnhHvOaAHTWlL5fJvqgvPamqdsfyqoe6Ip0fVC6Hcev8hq1DU8LcxxZFx8Tnd5qOl(qx8YPhkquXFav35YNN6bQHtpesHRR5V7L3Eq77qQsGV8L3d]] )


end
