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
            duration = 15,
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
            gcd = "spell",

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
            cooldown = function () return 180 - conduit.stalwart_guardian.mod * 0.001 end,
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
            gcd = "spell",
            
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


    spec:RegisterPack( "Arms", 20200830.1, [[dCupNbqiOQEKksztqLpPsLGrPsCkvsRsLkPELkIzPIQBrvHSli)IQsddQYXiOwgvjpJG00urIRPsvBtfj9nvKQXrq4CuvOwhvfiZJaDpPs7tfLdQsLAHsfEivfOUivfGtsvbzLeWmvPsIDsvLHsvb1svPsspLqtLQuxvLkH2kvfqFvLkrTxQ8xIgmQoSWIHYJPyYKCzWMj1NvHrlsNgLvtvrVMQQMnLUTO2nIFR0WLQoUkvISCv9CftxY1LY2Lk67ufJNGOZRsz9QuX8fX(rANWoVDIQOaNFEHNx4HNqiu8qcl894Dkc7eRB9GtSpm(hhGtKezWjE3FECI9Xn7gkN3oXzBVbCIPv1p(G813dwL2WqMn77WYnBuSLy(qx(oSSXxNiwJzlFiIdZjQIcC(5fEEHhEcHqXdjSW3J3P4eJwLUVtuKLB2OylXh8h6YjMYukG4WCIkymoXtJYV7ppu(D54F2(ubonk)UBhTPOCHI35uUx45fEubOcCAuUp40GCaJpiQaNgL7JO87wPafL7d3YzWIOcCAuUpIYVBLcuuUpqMP2)gLFxTnP(6dL7bIIroOCFGmtT)nevGtJY9ru(DRuGIY7iQYcuUy62kkVwkV)bZMXIIYVBF47kiQaNgL7JOCFacjyAfBjWFxyOCF4hmSHTekNnuUcSqbkevGtJY9ru(DRuGIYVloaL7dvqEqorlBQX5TtCyKdliR4pGY5TZpHDE7ebsGzbLRdNO5zf8SWj(Xbq5cs53FQuookhRP1ifek7nPjSzKA9qOCCuowtRrziV)n5QL2MHPKQhI8GuRhItmmfBjoXX)M1o9wwvW7kNFE582jcKaZckxhorZZk4zHteFkhRP1ifek7nPjSzuRNYXr5xOCZUw16HGmRDNPnYjhtk6HCWidLliL7fLNKq5xO8kSaPqEIh7HWF4rajWSGIYXr5MDTQ1db5jEShc)Hh9qoyKHYfKY9IYVs5xDIHPylXj(rNXb8UY5NqDE7ebsGzbLRdNO5zf8SWjIpLdZaedGmlrbKbusltd69nacibMfuuookhFkVclqkuoMjmpGasGzbfLJJYVq5v8hqHkwgK1k7nL0l8O8ZOCHXJYtsOCn7iTKpKdgzO8ZO87XJYVs5jjuomdqmaYSefqgqjTmnO33aiGeywqr54OC8P8kSaPq5yMW8acibMfuuook)cLxXFafQyzqwRS3usVWJYpJYfgpkpjHY1SJ0s(qoyKHYpJYfc8O8RuEscLxHfifkhZeMhqajWSGIYXr5xO8k(dOqfldYAL9Msk07P8ZOCHXJYtsOCn7iTKpKdgzO8ZO87XJYV6edtXwIt0S2DM2iNCmPUY53P482jcKaZckxhorZZk4zHteFkhMbigazwIcidOKwMg07BaeqcmlOOCCuo(uEfwGuOCmtyEabKaZckkhhLFHYR4pGcvSmiRv2BkPx4r5Nr5cJhLNKq5A2rAjFihmYq5Nr53JhLFLYtsOCygGyaKzjkGmGsAzAqVVbqajWSGIYXr54t5vybsHYXmH5beqcmlOOCCu(fkVI)akuXYGSwzVPKEHhLFgLlmEuEscLRzhPL8HCWidLFgLle4r5xP8KekVclqkuoMjmpGasGzbfLJJYVq5v8hqHkwgK1k7nLuO3t5Nr5cJhLNKq5A2rAjFihmYq5Nr53JhLF1jgMITeNON4XEi8hEx587EN3oXWuSL4evqOS3KMWMDIajWSGY1HRC(DQoVDIajWSGY1Ht08ScEw4eXAAnAAkfqKkiQu0dHPCIHPylXjAwIcYex5870DE7ebsGzbLRdNO5zf8SWjI10A00ukGivquPOhct5edtXwIteesW0kWvo)ecN3orGeywq56WjAEwbplCIMDTQ1dbL3VcRCQN5pGEihmYq54OCfG10AKzT7mTro5ysrQ1dHYXr5xOC8P8kSaPqkiu2BstyZiGeywqr5jjuowtRrkiu2BstyZi16Hq5xPCCu(fk)cLRaSMwJmRDNPnYjhtkQ1t54OC8P84oWZkavWuYvlZSJ0cbKaZckk)kLNKq5ynTgvWuYvlZSJ0c16P8RuookhRP1OmK3)MC1sBZWus1drEqQ1dHYXr5FCauUGu(PGNtmmfBjormBOGP2p7kNF(yN3orGeywq56WjAEwbplCItpyTYk(dOgKNu2B9Wikk)mk3lNyyk2sCIgleDcUY5NW4582jcKaZckxhorZZk4zHt8cLJpLxHfif6bIcbKaZckkhhLR2cPaOx6zBe1GEihmYq54O8poakxqk)0XJYXr5ynTgLH8(3KRwABgMsQEiYdsTEiuookxbynTgzw7otBKtoMuKA9qO8RuEscLFHYRWcKc9arHasGzbfLJJYvBHua0l9SnIAqpKdgzOCCuUAl0def6HCWidLFgLFyuuook)JdGYfKYpD8OCCuowtRrziV)n5QL2MHPKQhI8GuRhcLJJYvawtRrM1UZ0g5KJjfPwpek)QtmmfBjoXTt47xpW7kNFclSZBNyyk2sCI59RWkN6z(dorGeywq56Wvo)e2lN3orGeywq56WjAEwbplCIpKdgzOCb7s5Q2hfBju(DnLJhsOoXWuSL4eFGOCLZpHfQZBNiqcmlOCD4enpRGNfoXlu(fk)cLJ10AugY7FtUAPTzykP6HipOwpLFLYtsO8luUcWAAnYS2DM2iNCmPOwpLFLYtsO8luowtRrkiu2BstyZOwpLFLYVs54O8kSaPqA47CF5QLyrvwabKaZckk)kLNKq5xO8luowtRrziV)n5QL2MHPKQhI8GA9uEscL)Xbq5Nr5cHpMYVs54OCfG10AKzT7mTro5ysrTEkhhLJ10AubtjxTmZoslKA9qOCCuo(uEfwGuin8DUVC1sSOklGasGzbfLF1jgMITeNONu2B9Wikx58t4tX5TteibMfuUoCIMNvWZcNi(uEfwGuin8DUVC1sSOklGasGzbfLJJYVq5ynTgLH8(3KRwABgMsQEiYdQ1t5jjuUcWAAnYS2DM2iNCmPOwpLF1jgMITeN4yJSRC(j89oVDIHPylXjUDcF)6bENiqcmlOCD4kNFcFQoVDIajWSGY1Ht08ScEw4eRWcKcPHVZ9LRwIfvzbeqcmlOOCCu(fkhRP1OcMsUAzMDKwOwpLNKq5kaRP1iZA3zAJCYXKIuRhcLJJYXAAnQGPKRwMzhPfsTEiuook)JdGYpJYpv8O8RoXWuSL4e9KYERhgr5kNFcF6oVDIajWSGY1Ht08ScEw4eXNYRWcKcPHVZ9LRwIfvzbeqcmlOCIHPylXjo2i7kNFcleoVDIHPylXj2jZu7Ft(Tj1jcKaZckxhUY5NW(yN3oXWuSL4ez5EGOyKdzNmtT)nNiqcmlOCD4kx5evGoA2Y5TZpHDE7edtXwIt0Kg)b4ebsGzbLRdx58ZlN3oXWuSL4e7B5myDIajWSGY1HRC(juN3orGeywq56WjAEwbplCIxO8k(dOqPqyRuuVPOCbPCVeMYtsO8kSaPq5yMW8acibMfuuookVI)akuke2kf1BkkxqkxONkLFLYXr5xOCSMwJYqE)BYvlTndtjvpe5b16P8KekhRP1OJw8kwqKRwg3b(TsrTEk)kLNKq54t5WmaXaOmK3)MC1sBZWus1drEq5WN7t54OC8PCygGyaKzjkGmGsAzAqVVbq5WN7t54O8luEf)buOuiSvkQ3uuUGuUxct5jjuEfwGuOCmtyEabKaZckkhhLxXFafkfcBLI6nfLliLl0tLYVs54OCfG10AKzT7mTro5ysrTEkpjHY1SJ0s(qoyKHYfKY96ENyyk2sCI9BXwIRC(DkoVDIajWSGY1Ht08ScEw4eXAAnkd59VjxT02mmLu9qKhuRNYXr5ynTgvWuYvlZSJ0c16P8KekhRP1OJw8kwqKRwg3b(TsrTEkhhLRaSMwJmRDNPnYjhtkQ1t5jjuowtRrdavkJCi)4aqTEkpjHYVq54t5WmaXaOmK3)MC1sBZWus1drEq5WN7t54OC8PCygGyaKzjkGmGsAzAqVVbq5WN7t54OC8PCygGyaeMDxLC1YkfKabY3q5WN7t54OCfG10AKzT7mTro5ysrTEk)QtmmfBjorm7UkPU93CLZV7DE7ebsGzbLRdNO5zf8SWjI10AugY7FtUAPTzykP6HipOwpLJJYXAAnQGPKRwMzhPfQ1t5jjuowtRrhT4vSGixTmUd8BLIA9uookxbynTgzw7otBKtoMuuRNYtsOCSMwJgaQug5q(XbGA9uEscLFHYXNYHzaIbqziV)n5QL2MHPKQhI8GYHp3NYXr54t5WmaXaiZsuazaL0Y0GEFdGYHp3NYXr54t5WmaXaim7Uk5QLvkibcKVHYHp3NYXr5kaRP1iZA3zAJCYXKIA9u(vNyyk2sCIyWpW7pJC4kNFNQZBNiqcmlOCD4enpRGNforSMwJYqE)BYvlTndtjvpe5bPwpekhhL)Xbq5cs53JhLJJYVq5MDTQ1dbL3VcRCQN5pGEihmYq5Nr5hgfLNKq5xO8k(dOqPqyRuuVPOCbPCVWJYtsO8kSaPq5yMW8acibMfuuookVI)akuke2kf1BkkxqkxO3t5xP8RoXWuSL4eJ3eeqw7)aPCLZVt35TteibMfuUoCIMNvWZcNOcWAAnYS2DM2iNCmPi16H4edtXwIt0YosRr6ZM6idKYvo)ecN3orGeywq56WjAEwbplCIynTgLH8(3KRwABgMsQEiYdQ1t54OCSMwJkyk5QLz2rAHA9uEscLJ10A0rlEfliYvlJ7a)wPOwpLJJYvawtRrM1UZ0g5KJjf16P8KekhRP1ObGkLroKFCaOwpLNKq5xOC8PCygGyaugY7FtUAPTzykP6HipOC4Z9PCCuo(uomdqmaYSefqgqjTmnO33aOC4Z9PCCuo(uomdqmacZURsUAzLcsGa5BOC4Z9PCCuUcWAAnYS2DM2iNCmPOwpLF1jgMITeNOM9aMDxLRC(5JDE7ebsGzbLRdNO5zf8SWjI10AugY7FtUAPTzykP6HipOwpLJJYXAAnQGPKRwMzhPfQ1t5jjuowtRrhT4vSGixTmUd8BLIA9uookxbynTgzw7otBKtoMuuRNYtsOCSMwJgaQug5q(XbGA9uEscLFHYXNYHzaIbqziV)n5QL2MHPKQhI8GYHp3NYXr54t5WmaXaiZsuazaL0Y0GEFdGYHp3NYXr54t5WmaXaim7Uk5QLvkibcKVHYHp3NYXr5kaRP1iZA3zAJCYXKIA9u(vNyyk2sCIbXat9HvAcR1vo)egpN3orGeywq56WjAEwbplCIkaRP1iZA3zAJCYXKIuRhcLJJYXAAnkd59VjxT02mmLu9qKhKA9qOCCuUzxRA9qq59RWkN6z(dOhYbJmoXWuSL4eXId5QL1Zm(pUY5NWc782jcKaZckxhoXWuSL4eJjTZGaJ8J7SV0SFyDIMNvWZcNi(uUcWAAn6J7SV0SFyLkaRP1OwpLNKq5xO8luEf)buOuiSvkQ3uuUGuUx4HeMYtsO8kSaPq5yMW8acibMfuuookVI)akuke2kf1BkkxqkxO3JeMYVs54O8luowtRrziV)n5QL2MHPKQhI8GA9uook)cLB21QwpeugY7FtUAPTzykP6HipOhYbJmuUGuUW4DQuEscLB21QwpeugY7FtUAPTzykP6HipOhYbJmuUGuUWcF6uookxZosl5d5Grgkxqk3l8OCCuo(uEfwGuOCmtyEabKaZckk)kLNKq5ynTgD0IxXcIC1Y4oWVvkQ1t54OCfG10AKzT7mTro5ysrTEk)kLFLYtsOCygGyaKzjkGmGsAzAqVVbq5WN7t54O8k(dOqPqyRuuVPOCbPCVWJYtsO8luEf)buOuiSvkQ3uuUGuUqXdjmLJJYvawtRrMLOAMI1jize)LkaRP1OwpLJJYXNYHzaIbqziV)n5QL2MHPKQhI8GYHp3NYXr54t5WmaXaiZsuazaL0Y0GEFdGYHp3NYVs5jju(fkhFkxbynTgzwIQzkwNGKr8xQaSMwJA9uookhFkhMbigaLH8(3KRwABgMsQEiYdkh(CFkhhLJpLdZaedGmlrbKbusltd69nakh(CFkhhLRaSMwJmRDNPnYjhtkQ1t5xDIKidoXys7miWi)4o7ln7hwx58tyVCE7ebsGzbLRdNyyk2sCIXDM04JrQxsjxTSF9aVt08ScEw4elwgK1kvmGYfKYpD8OCCu(fk3SRvTEiiZA3zAJCYXKIEihmYq5cs5c7fLNKq5xO8kSaPqEIh7HWF4rajWSGIYXr5MDTQ1db5jEShc)Hh9qoyKHYfKYf2lk)kLFLYtsOC8PCfG10AKzT7mTro5ysrTEkhhLJpLJ10AubtjxTmZosluRNYXr54t5ynTgLH8(3KRwABgMsQEiYdQ1t54O8ILbzTsfdO8ZOCHVhpNijYGtmUZKgFms9sk5QL9Rh4DLZpHfQZBNiqcmlOCD4enpRGNforZUw16HGmRDNPnYjhtk6HCWidLliLleuEscLFHYRWcKc5jEShc)HhbKaZckkhhLB21QwpeKN4XEi8hE0d5GrgkxqkxiO8RoXWuSL4eJoJkEx58t4tX5TteibMfuUoCIMNvWZcNOzxRA9qqM1UZ0g5KJjf9qoyKHYfKYfckpjHYVq5vybsH8ep2dH)WJasGzbfLJJYn7AvRhcYt8ype(dp6HCWidLliLleu(vNyyk2sCITbKScYJRC(j89oVDIajWSGY1Ht08ScEw4eNEWALv8hqnipPS36Hruu(zuUWuook)cLB21QwpeeMnuWu7NrpKdgzO8ZOCHXJYtsOCZUw16HGmRDNPnYjhtk6HCWidLFgLleuEscLh3bEwbOcMsUAzMDKwiGeywqr5xDIHPylXjoEaONroKt9m)HXvo)e(uDE7ebsGzbLRdNO5zf8SWjEHYXAAnQGPKRwMzhPfQ1t5jju(fkxbynTgzw7otBKtoMuuRNYXr54t5XDGNvaQGPKRwMzhPfcibMfuu(vk)kLJJYVq5A2rAjFihmYq5Nr5(y8O8Kek)cLxXFafkfcBLI6nfLliL7fEuEscLxHfifkhZeMhqajWSGIYXr5v8hqHsHWwPOEtr5cs5c9Ek)kLF1jgMITeNiMDxLC1YkfKabY3CLZpHpDN3orGeywq56WjAEwbplCI4t5kaRP1iZA3zAJCYXKIA9uookhFkhRP1OcMsUAzMDKwOwVtmmfBjoX(2Z03yKdjMnMYvo)ewiCE7ebsGzbLRdNO5zf8SWjIpLRaSMwJmRDNPnYjhtkQ1t54OC8PCSMwJkyk5QLz2rAHA9oXWuSL4eFwFVfKmIC6dd4kNFc7JDE7ebsGzbLRdNO5zf8SWjIpLRaSMwJmRDNPnYjhtkQ1t54OC8PCSMwJkyk5QLz2rAHA9oXWuSL4e9SVv1jWiYhMLeed4kNFEHNZBNiqcmlOCD4enpRGNfor8PCfG10AKzT7mTro5ysrTEkhhLJpLJ10AubtjxTmZosluR3jgMITeNOEnTbuY4oWZkqIbr2vo)8syN3orGeywq56WjAEwbplCI4t5kaRP1iZA3zAJCYXKIA9uookhFkhRP1OcMsUAzMDKwOwVtmmfBjoXhIEg5qQTrggx58ZlVCE7ebsGzbLRdNO5zf8SWjIpLRaSMwJmRDNPnYjhtkQ1t54OC8PCSMwJkyk5QLz2rAHA9uookxTfYSedqQpkqj12idsS2tqpKdgzO8UuoEoXWuSL4enlXaK6JcusTnYGRC(5LqDE7ebsGzbLRdNO5zf8SWjI10A0dg)TWms9(ga16DIHPylXjwPGSrW2grj17Bax58ZRtX5TteibMfuUoCIMNvWZcNi(uEfwGuipXJ9q4p8iGeywqr54OCZUw16HGmRDNPnYjhtk6HCWidLliLFpLJJYVq5A2rAjFihmYq5Nr5EjmEuEscLFHYR4pGcLcHTsr9MIYfKY9cpkpjHYRWcKcLJzcZdiGeywqr54O8k(dOqPqyRuuVPOCbPCHEpLFLYtsOCn7iTKpKdgzOCbPCHkmLF1jgMITeN4rlEfliYvlJ7a)wPUY5Nx3782jcKaZckxhorZZk4zHtSclqkKN4XEi8hEeqcmlOOCCuUzxRA9qqEIh7HWF4rpKdgzOCbP87PCCu(fkxZosl5d5Grgk)mk3lHXJYtsO8luEf)buOuiSvkQ3uuUGuUx4r5jjuEfwGuOCmtyEabKaZckkhhLxXFafkfcBLI6nfLliLl07P8RuEscLRzhPL8HCWidLliLluHP8RoXWuSL4epAXRybrUAzCh43k1vo)86uDE7ebsGzbLRdNO5zf8SWjIpLxHfifYt8ype(dpcibMfuuook3SRvTEiiZA3zAJCYXKIEihmYq5cs5ct54O8luUMDKwYhYbJmu(zuUW3JhLNKq5xO8k(dOqPqyRuuVPOCbPCVWJYtsO8kSaPq5yMW8acibMfuuookVI)akuke2kf1BkkxqkxO3t5xP8RoXWuSL4eZqE)BYvlTndtjvpe5Xvo)860DE7ebsGzbLRdNO5zf8SWjwHfifYt8ype(dpcibMfuuook3SRvTEiipXJ9q4p8OhYbJmuUGuUWuook)cLRzhPL8HCWidLFgLl894r5jju(fkVI)akuke2kf1Bkkxqk3l8O8KekVclqkuoMjmpGasGzbfLJJYR4pGcLcHTsr9MIYfKYf69u(vk)QtmmfBjoXmK3)MC1sBZWus1drECLZpVecN3oXWuSL4eNEiE5QLyXuSL4ebsGzbLRdx58ZlFSZBNyyk2sCIMLCxQb)(Jelie4DIajWSGY1HRC(ju8CE7edtXwItmiggqkzOl4N014VteibMfuUoCLZpHkSZBNiqcmlOCD4enpRGNfoXPhSwzf)budYtk7TEyefLFgLFkoXWuSL4e)grgMITePLnLt0YMssIm4e1Sobzf)buUY5Nq9Y5TteibMfuUoCIMNvWZcNiwtRrttPaIubrLIA9uEscL)Xbq5N1LYpf8O8KekVI)akuXYGSwPIbuUGu(Hr5edtXwIt0SefKjUY5NqfQZBNiqcmlOCD4enpRGNfoXluEfwGuOCmtyEabKaZckkhhLxXFafkfcBLI6nfLliLl07P8RuEscLxXFafkfcBLI6nfLliL7fEoXWuSL4e)grgMITePLnLt0YMssIm4ebHemTcCLZpHEkoVDIajWSGY1HtmmfBjoXVrKHPylrAzt5eTSPKKidoXHroSGSI)akx5kNy)dMnJfLZBNFc782jgMITeNiwuLfKt62kNiqcmlOCD4kNFE582jcKaZckxhorsKbNyCNjn(yK6LuYvl7xpW7edtXwItmUZKgFms9sk5QL9Rh4DLZpH682jcKaZckxhorZZk4zHtSclqkKg(o3xUAjwuLfqajWSGIYtsOC8P8kSaPqA47CF5QLyrvwabKaZckkhhLxSmiRvQyaLFgLl8945edtXwItmd59VjxT02mmLu9qKhx587uCE7ebsGzbLRdNO5zf8SWjwHfifsdFN7lxTelQYciGeywqr5jjuEfwGuOCmtyEabKaZckkhhLxSmiRvQyaLFgL7LW4r5jjuEfwGuOhikeqcmlOOCCu(fkVyzqwRuXak)mk3lHXJYtsO8ILbzTsfdOCbPCHpL7P8RoXWuSL4epAXRybrUAzCh43k1vo)U35TteibMfuUoCIMNvWZcNimdqmaYSefqgqjTmnO33aOC4Z9DI9BXwItSFl2sKRw2iyptzbLu3(BoXWuSL4e73ITex587uDE7ebsGzbLRdNO5zf8SWjcZaedGYqE)BYvlTndtjvpe5bLdFUVtSFl2sCI9BXwIC1s9AAdOKpmRTtWjgMITeNy)wSL4kNFNUZBNyyk2sCI9BXwIteibMfuUoCLRCIGqcMwboVD(jSZBNiqcmlOCD4enpRGNfoXpoakxqk)EVOCCuowtRrkiu2BstyZi16Hq54OCSMwJYqE)BYvlTndtjvpe5bPwpeNyyk2sCIJ)nRD6TSQG3vo)8Y5TteibMfuUoCIMNvWZcNi(uowtRrkiu2BstyZOwpLJJYVq5MDTQ1dbzw7otBKtoMu0d5Grgkxqk3lkpjHYVq5vybsH8ep2dH)WJasGzbfLJJYn7AvRhcYt8ype(dp6HCWidLliL7fLFLYV6edtXwIt8JoJd4DLZpH682jcKaZckxhorZZk4zHteFkhMbigaLH8(3KRwABgMsQEiYdkh(CFkpjHYVq5ynTgLH8(3KRwABgMsQEiYdQ1t5jjuUzxRA9qqziV)n5QL2MHPKQhI8GEihmYq5Nr5cJhLF1jgMITeNOzT7mTro5ysDLZVtX5TteibMfuUoCIMNvWZcNi(uomdqmakd59VjxT02mmLu9qKhuo85(uEscLFHYXAAnkd59VjxT02mmLu9qKhuRNYtsOCZUw16HGYqE)BYvlTndtjvpe5b9qoyKHYpJYfgpk)QtmmfBjorpXJ9q4p8UY539oVDIHPylXjQGqzVjnHn7ebsGzbLRdx587uDE7ebsGzbLRdNO5zf8SWjIpLJ10AugY7FtUAPTzykP6HipOwpLJJYXAAnQGPKRwMzhPfQ1t54O8poakxqkxO4r54OC8PCSMwJuqOS3KMWMrTENyyk2sCIy2qbtTF2vo)oDN3orGeywq56WjAEwbplCItpyTYk(dOgKNu2B9Wikk)mk3lNyyk2sCIgleDcUY5Nq482jcKaZckxhorZZk4zHteRP1iZ3Mug5qgZenBHA9uookhRP1OmK3)MC1sBZWus1drEqQ1dXjgMITeN4yJSRC(5JDE7ebsGzbLRdNO5zf8SWj(qoyKHYfSlLRAFuSLq531uoEiHs54O8k(dOqfldYALkgq5Nr5NUtmmfBjoXhikx58ty8CE7ebsGzbLRdNO5zf8SWjI10A02j89Rh4rtfg)P8UuUxuookVclqkK6HqrI2rAHasGzbLtmmfBjoX8(vyLt9m)bx58tyHDE7ebsGzbLRdNO5zf8SWjI10AugY7FtUAPTzykP6HipOwpLNKq5ynTgPGqzVjnHnJA9uEscLRaSMwJmRDNPnYjhtkQ1t5jjuowtRrfmLC1Ym7iTqTENyyk2sCIGqcMwbUY5NWE582jgMITeN42j89Rh4DIajWSGY1HRC(jSqDE7edtXwIt0SefKjorGeywq56Wvo)e(uCE7edtXwIteesW0kWjcKaZckxhUYvornRtqwXFaLZBNFc782jcKaZckxhorZZk4zHt8JdGYfKYpv8OCCu(fkhFkVclqkKccL9M0e2mcibMfuuEscLJ10AKccL9M0e2msTEiu(vNyyk2sCIJ)nRD6TSQG3vo)8Y5TteibMfuUoCIMNvWZcN4fkhFkVclqkKN4XEi8hEeqcmlOO8Kek3SRvTEiipXJ9q4p8OhYbJmuUGuUxu(vNyyk2sCIF0zCaVRC(juN3orGeywq56WjAEwbplCIkaRP1iZA3zAJCYXKIuRhItmmfBjorZA3zAJCYXK6kNFNIZBNiqcmlOCD4enpRGNforfG10AKzT7mTro5ysrQ1dXjgMITeNON4XEi8hEx587EN3orGeywq56WjAEwbplCIynTgnEaONroKt9m)HbPwpekhhLFHYXNYRWcKcPGqzVjnHnJasGzbfLNKq5ynTgPGqzVjnHnJuRhcLFLYXr5xO8luUcWAAnYS2DM2iNCmPOhYbJmu(zu(PGUNYXr54t5XDGNvaQGPKRwMzhPfcibMfuu(vkpjHYXAAnQGPKRwMzhPfQ1t5xDIHPylXjIzdfm1(zx587uDE7edtXwItubHYEtAcB2jcKaZckxhUY53P782jgMITeNOXcrNGteibMfuUoCLZpHW5TteibMfuUoCIMNvWZcN4fkhFkVclqkKXcrNacibMfuuookxTfsbqV0Z2iQb9qoyKHYfKY9IYVs5jju(fkhRP1OPPuarQGOsrpeMIYtsOCSMwJMAjGmfIVqpeMIYVs54O8luowtRrJha6zKd5upZFyqTEkpjHYn7AvRhcA8aqpJCiN6z(dd6HCWidLFgLleu(vNyyk2sCIMLOGmXvo)8XoVDIajWSGY1Ht08ScEw4eVq54t5vybsHmwi6eqajWSGIYXr5QTqka6LE2grnOhYbJmuUGuUxu(vkpjHYVq5ynTgnnLcisfevk6HWuuEscLJ10A0ulbKPq8f6HWuu(vkhhLFHYXAAnA8aqpJCiN6z(ddQ1t5jjuUzxRA9qqJha6zKd5upZFyqpKdgzO8ZOCHGYV6edtXwIteesW0kWvo)egpN3orGeywq56WjAEwbplCIxOC8P8kSaPqgleDciGeywqr54OC1wifa9spBJOg0d5Grgkxqk3lk)kLNKq5ynTgnEaONroKt9m)Hb16PCCuowtRrBNW3VEGhnvy8NY7s5Er54O8kSaPqQhcfjAhPfcibMfuoXWuSL4eZ7xHvo1Z8hCLZpHf25TteibMfuUoCIMNvWZcNOcWAAnYS2DM2iNCmPOwpLNKq5xOCSMwJmFBszKdzmt0SfQ1t54O8kSaPqA47CF5QLyrvwabKaZckk)QtmmfBjorpPS36HruUY5NWE582jcKaZckxhorZZk4zHteRP1ifek7nPjSzuRNYtsO8poak)mk)uXZjgMITeNONu2B9Wikx58tyH682jgMITeN42j89Rh4DIajWSGY1HRC(j8P482jgMITeNONu2B9WikNiqcmlOCD4kNFcFVZBNyyk2sCIDYm1(3KFBsDIajWSGY1HRC(j8P682jgMITeNil3defJCi7KzQ9V5ebsGzbLRdx5kx5e7e(HTeNFEHNx4HNqiu8CIEINWihJt0hk3VFbkk)EkpmfBjuULn1GOc4e7)vZSGt80O87(ZdLFxo(NTpvGtJYV72rBkkxO4DoL7fEEHhvaQaNgL7donihW4dIkWPr5(ik)Uvkqr5(WTCgSiQaNgL7JO87wPafL7dKzQ9Vr53vBtQV(q5EGOyKdk3hiZu7Fdrf40OCFeLF3kfOO8oIQSaLlMUTIYRLY7FWSzSOO872h(UcIkWPr5(ik3hGqcMwXwc83fgk3h(bdBylHYzdLRaluGcrf40OCFeLF3kfOO87Idq5(qfKhevaQaNgL7dqibtRafLJb69bk3SzSOOCm4GrgeLF3gd0xdLtwIpkn(SUzP8WuSLmu(sS3qubonkpmfBjdQ)bZMXIQR2gJ)ubonkpmfBjdQ)bZMXI6KU(Q3vrf40O8WuSLmO(hmBglQt66B0oYaPIITeQaNgLlsI(jDlk)dMIYXAAnOO8PIAOCmqVpq5MnJffLJbhmYq5brr59p4J63QyKdkNnuUAjaIkqyk2sgu)dMnJf1jD9flQYcYjDBfvGWuSLmO(hmBglQt66BBajRG85KidDJ7mPXhJuVKsUAz)6bEQaHPylzq9py2mwuN013mK3)MC1sBZWus1drEoNP7wHfifsdFN7lxTelQYciGeywqLKGFfwGuin8DUVC1sSOklGasGzbfUILbzTsfdot47XJkqyk2sgu)dMnJf1jD99OfVIfe5QLXDGFR0Zz6UvybsH0W35(YvlXIQSacibMfujjvybsHYXmH5beqcmlOWvSmiRvQyWzEjmEjjvybsHEGOqajWSGc3LILbzTsfdoZlHXljPyzqwRuXabf(uU)kvGWuSLmO(hmBglQt66B)wSLCojYq3(TylrUAzJG9mLfusD7VDot3fMbigazwIcidOKwMg07Bauo85(ubctXwYG6FWSzSOoPRV9BXwY5KidD73ITe5QL610gqjFywBNW5mDxygGyaugY7FtUAPTzykP6HipOC4Z9PceMITKb1)GzZyrDsxF73ITeQaubonk3hGqcMwbkkh6e(BuEXYaLxPaLhMAFkNnuE0zWSbMfqubctXwY01Kg)bqfimfBjZjD9TVLZGLkqyk2sMt66B)wSLCot39sf)buOuiSvkQ3uc6LWjjvybsHYXmH5beqcmlOWvXFafkfcBLI6nLGc9uVI7cwtRrziV)n5QL2MHPKQhI8GA9jjynTgD0IxXcIC1Y4oWVvkQ1FnjbFygGyaugY7FtUAPTzykP6HipOC4Z9XHpmdqmaYSefqgqjTmnO33aOC4Z9XDPI)akuke2kf1Bkb9s4KKkSaPq5yMW8acibMfu4Q4pGcLcHTsr9MsqHEQxXPaSMwJmRDNPnYjhtkQ1NKOzhPL8HCWiJGEDpvGWuSLmN01xm7UkPU93oNP7I10AugY7FtUAPTzykP6HipOwpoSMwJkyk5QLz2rAHA9jjynTgD0IxXcIC1Y4oWVvkQ1JtbynTgzw7otBKtoMuuRpjbRP1ObGkLroKFCaOwFsYf8HzaIbqziV)n5QL2MHPKQhI8GYHp3hh(WmaXaiZsuazaL0Y0GEFdGYHp3hh(WmaXaim7Uk5QLvkibcKVHYHp3hNcWAAnYS2DM2iNCmPOw)vQaHPylzoPRVyWpW7pJCCot3fRP1OmK3)MC1sBZWus1drEqTECynTgvWuYvlZSJ0c16tsWAAn6OfVIfe5QLXDGFRuuRhNcWAAnYS2DM2iNCmPOwFscwtRrdavkJCi)4aqT(KKl4dZaedGYqE)BYvlTndtjvpe5bLdFUpo8HzaIbqMLOaYakPLPb9(gaLdFUpo8HzaIbqy2DvYvlRuqceiFdLdFUpofG10AKzT7mTro5ysrT(RubctXwYCsxFJ3eeqw7)aPoNP7I10AugY7FtUAPTzykP6Hipi16HG7JdqW7Xd3fZUw16HGY7xHvo1Z8hqpKdgzo7WOssUuXFafkfcBLI6nLGEHxssfwGuOCmtyEabKaZckCv8hqHsHWwPOEtjOqV)6vQaHPylzoPRVw2rAnsF2uhzGuNZ0DvawtRrM1UZ0g5KJjfPwpeQaHPylzoPRVA2dy2DvNZ0DXAAnkd59VjxT02mmLu9qKhuRhhwtRrfmLC1Ym7iTqT(KeSMwJoAXRybrUAzCh43kf16XPaSMwJmRDNPnYjhtkQ1NKG10A0aqLYihYpoauRpj5c(WmaXaOmK3)MC1sBZWus1drEq5WN7JdFygGyaKzjkGmGsAzAqVVbq5WN7JdFygGyaeMDxLC1YkfKabY3q5WN7JtbynTgzw7otBKtoMuuR)kvGWuSLmN013GyGP(WknH1Eot3fRP1OmK3)MC1sBZWus1drEqTECynTgvWuYvlZSJ0c16tsWAAn6OfVIfe5QLXDGFRuuRhNcWAAnYS2DM2iNCmPOwFscwtRrdavkJCi)4aqT(KKl4dZaedGYqE)BYvlTndtjvpe5bLdFUpo8HzaIbqMLOaYakPLPb9(gaLdFUpo8HzaIbqy2DvYvlRuqceiFdLdFUpofG10AKzT7mTro5ysrT(RubctXwYCsxFXId5QL1Zm(pNZ0DvawtRrM1UZ0g5KJjfPwpeCynTgLH8(3KRwABgMsQEiYdsTEi4m7AvRhckVFfw5upZFa9qoyKHkqyk2sMt66BBajRG85KidDJjTZGaJ8J7SV0SFypNP7IVcWAAn6J7SV0SFyLkaRP1OwFsYLlv8hqHsHWwPOEtjOx4HeojPclqkuoMjmpGasGzbfUk(dOqPqyRuuVPeuO3Je(kUlynTgLH8(3KRwABgMsQEiYdQ1J7IzxRA9qqziV)n5QL2MHPKQhI8GEihmYiOW4DQjjMDTQ1dbLH8(3KRwABgMsQEiYd6HCWiJGcl8PJtZosl5d5Grgb9cpC4xHfifkhZeMhqajWSG6AscwtRrhT4vSGixTmUd8BLIA94uawtRrM1UZ0g5KJjf16VEnjbMbigazwIcidOKwMg07Bauo85(4Q4pGcLcHTsr9MsqVWlj5sf)buOuiSvkQ3ucku8qcJtbynTgzwIQzkwNGKr8xQaSMwJA94WhMbigaLH8(3KRwABgMsQEiYdkh(CFC4dZaedGmlrbKbusltd69nakh(C)RjjxWxbynTgzwIQzkwNGKr8xQaSMwJA94WhMbigaLH8(3KRwABgMsQEiYdkh(CFC4dZaedGmlrbKbusltd69nakh(CFCkaRP1iZA3zAJCYXKIA9xPceMITK5KU(2gqYkiFojYq34otA8Xi1lPKRw2VEG)CMUBXYGSwPIbcE64H7IzxRA9qqM1UZ0g5KJjf9qoyKrqH9kj5sfwGuipXJ9q4p8iGeywqHZSRvTEiipXJ9q4p8OhYbJmckSxxVMKGVcWAAnYS2DM2iNCmPOwpo8XAAnQGPKRwMzhPfQ1JdFSMwJYqE)BYvlTndtjvpe5b16XvSmiRvQyWzcFpEubctXwYCsxFJoJk(Zz6UMDTQ1dbzw7otBKtoMu0d5GrgbfIKKlvybsH8ep2dH)WJasGzbfoZUw16HG8ep2dH)WJEihmYiOqCLkqyk2sMt66BBajRG8Cot31SRvTEiiZA3zAJCYXKIEihmYiOqKKCPclqkKN4XEi8hEeqcmlOWz21QwpeKN4XEi8hE0d5GrgbfIRubctXwYCsxFhpa0ZihYPEM)WCot3D6bRvwXFa1G8KYERhgrDMW4Uy21QwpeeMnuWu7NrpKdgzoty8ssm7AvRhcYS2DM2iNCmPOhYbJmNjejjXDGNvaQGPKRwMzhPfcibMfuxPceMITK5KU(Iz3vjxTSsbjqG8TZz6UxWAAnQGPKRwMzhPfQ1NKCrbynTgzw7otBKtoMuuRhh(XDGNvaQGPKRwMzhPfcibMfuxVI7IMDKwYhYbJmN5JXlj5sf)buOuiSvkQ3uc6fEjjvybsHYXmH5beqcmlOWvXFafkfcBLI6nLGc9(RxPceMITK5KU(23EM(gJCiXSXuNZ0DXxbynTgzw7otBKtoMuuRhh(ynTgvWuYvlZSJ0c16PceMITK5KU((S(Elize50hg4CMUl(kaRP1iZA3zAJCYXKIA94WhRP1OcMsUAzMDKwOwpvGWuSLmN01xp7BvDcmI8HzjbXaNZ0DXxbynTgzw7otBKtoMuuRhh(ynTgvWuYvlZSJ0c16PceMITK5KU(QxtBaLmUd8ScKyqKpNP7IVcWAAnYS2DM2iNCmPOwpo8XAAnQGPKRwMzhPfQ1tfimfBjZjD99HONroKABKH5CMUl(kaRP1iZA3zAJCYXKIA94WhRP1OcMsUAzMDKwOwpvGWuSLmN01xZsmaP(OaLuBJmCot3fFfG10AKzT7mTro5ysrTEC4J10AubtjxTmZosluRhNAlKzjgGuFuGsQTrgKyTNGEihmY0fpQaHPylzoPRVvkiBeSTrus9(g4CMUlwtRrpy83cZi17BauRNkqyk2sMt667rlEfliYvlJ7a)wPNZ0DXVclqkKN4XEi8hEeqcmlOWz21QwpeKzT7mTro5ysrpKdgze8ECx0SJ0s(qoyK5mVegVKKlv8hqHsHWwPOEtjOx4LKuHfifkhZeMhqajWSGcxf)buOuiSvkQ3uck07VMKOzhPL8HCWiJGcv4RubctXwYCsxFpAXRybrUAzCh43k9CMUBfwGuipXJ9q4p8iGeywqHZSRvTEiipXJ9q4p8OhYbJmcEpUlA2rAjFihmYCMxcJxsYLk(dOqPqyRuuVPe0l8ssQWcKcLJzcZdiGeywqHRI)akuke2kf1Bkbf69xts0SJ0s(qoyKrqHk8vQaHPylzoPRVziV)n5QL2MHPKQhI8Cot3f)kSaPqEIh7HWF4rajWSGcNzxRA9qqM1UZ0g5KJjf9qoyKrqHXDrZosl5d5GrMZe(E8ssUuXFafkfcBLI6nLGEHxssfwGuOCmtyEabKaZckCv8hqHsHWwPOEtjOqV)6vQaHPylzoPRVziV)n5QL2MHPKQhI8Cot3TclqkKN4XEi8hEeqcmlOWz21QwpeKN4XEi8hE0d5Grgbfg3fn7iTKpKdgzot47Xlj5sf)buOuiSvkQ3uc6fEjjvybsHYXmH5beqcmlOWvXFafkfcBLI6nLGc9(RxPceMITK5KU(o9q8YvlXIPylHkqyk2sMt66Rzj3LAWV)iXccbEQaHPylzoPRVbXWasjdDb)KUg)PceMITK5KU((nImmfBjslBQZjrg6QzDcYk(dOoNP7o9G1kR4pGAqEszV1dJOo7uOceMITK5KU(AwIcYKZz6UynTgnnLcisfevkQ1NK8XbCw3tbVKKk(dOqfldYALkgi4HrrfimfBjZjD99Bezyk2sKw2uNtIm0fesW0k4CMU7LkSaPq5yMW8acibMfu4Q4pGcLcHTsr9MsqHE)1KKk(dOqPqyRuuVPe0l8OceMITK5KU((nImmfBjslBQZjrg6omYHfKv8hqrfGkqyk2sgeiKGPvq3X)M1o9wwvWFot39JdqW79chwtRrkiu2BstyZi16HGdRP1OmK3)MC1sBZWus1drEqQ1dHkqyk2sgeiKGPvWjD99JoJd4pNP7IpwtRrkiu2BstyZOwpUlMDTQ1dbzw7otBKtoMu0d5Grgb9kj5sfwGuipXJ9q4p8iGeywqHZSRvTEiipXJ9q4p8OhYbJmc611RubctXwYGaHemTcoPRVM1UZ0g5KJj9CMUl(WmaXaOmK3)MC1sBZWus1drEq5WN7NKCbRP1OmK3)MC1sBZWus1drEqT(KeZUw16HGYqE)BYvlTndtjvpe5b9qoyK5mHX7kvGWuSLmiqibtRGt66RN4XEi8h(Zz6U4dZaedGYqE)BYvlTndtjvpe5bLdFUFsYfSMwJYqE)BYvlTndtjvpe5b16tsm7AvRhckd59VjxT02mmLu9qKh0d5GrMZegVRubctXwYGaHemTcoPRVkiu2BstyZubctXwYGaHemTcoPRVy2qbtTF(CMUl(ynTgLH8(3KRwABgMsQEiYdQ1JdRP1OcMsUAzMDKwOwpUpoabfkE4WhRP1ifek7nPjSzuRNkqyk2sgeiKGPvWjD91yHOt4CMU70dwRSI)aQb5jL9wpmI6mVOceMITKbbcjyAfCsxFhBKpNP7I10AK5BtkJCiJzIMTqTECynTgLH8(3KRwABgMsQEiYdsTEiubctXwYGaHemTcoPRVpquNZ0DFihmYiyxv7JITK7A8qcfxf)buOILbzTsfdo70PceMITKbbcjyAfCsxFZ7xHvo1Z8hoNP7I10A02j89Rh4rtfg)76fUkSaPqQhcfjAhPfcibMfuubctXwYGaHemTcoPRVGqcMwbNZ0DXAAnkd59VjxT02mmLu9qKhuRpjbRP1ifek7nPjSzuRpjrbynTgzw7otBKtoMuuRpjbRP1OcMsUAzMDKwOwpvGWuSLmiqibtRGt6672j89Rh4PceMITKbbcjyAfCsxFnlrbzcvGWuSLmiqibtRGt66liKGPvavaQaHPylzqAwNGSI)aQUJ)nRD6TSQG)CMU7hhGGNkE4UGFfwGuifek7nPjSzeqcmlOssWAAnsbHYEtAcBgPwpKRubctXwYG0Sobzf)buN013p6moG)CMU7f8RWcKc5jEShc)HhbKaZcQKeZUw16HG8ep2dH)WJEihmYiOxxPceMITKbPzDcYk(dOoPRVM1UZ0g5KJj9CMURcWAAnYS2DM2iNCmPi16HqfimfBjdsZ6eKv8hqDsxF9ep2dH)WFot3vbynTgzw7otBKtoMuKA9qOceMITKbPzDcYk(dOoPRVy2qbtTF(CMUlwtRrJha6zKd5upZFyqQ1db3f8RWcKcPGqzVjnHnJasGzbvscwtRrkiu2BstyZi16HCf3LlkaRP1iZA3zAJCYXKIEihmYC2PGUhh(XDGNvaQGPKRwMzhPfcibMfuxtsWAAnQGPKRwMzhPfQ1FLkqyk2sgKM1jiR4pG6KU(QGqzVjnHntfimfBjdsZ6eKv8hqDsxFnwi6eOceMITKbPzDcYk(dOoPRVMLOGm5CMU7f8RWcKczSq0jGasGzbfo1wifa9spBJOg0d5Grgb96AsYfSMwJMMsbePcIkf9qyQKeSMwJMAjGmfIVqpeM6kUlynTgnEaONroKt9m)Hb16tsm7AvRhcA8aqpJCiN6z(dd6HCWiZzcXvQaHPylzqAwNGSI)aQt66liKGPvW5mD3l4xHfifYyHOtabKaZckCQTqka6LE2grnOhYbJmc611KKlynTgnnLcisfevk6HWujjynTgn1sazkeFHEim1vCxWAAnA8aqpJCiN6z(ddQ1NKy21Qwpe04bGEg5qo1Z8hg0d5GrMZeIRubctXwYG0Sobzf)buN0138(vyLt9m)HZz6UxWVclqkKXcrNacibMfu4uBHua0l9SnIAqpKdgze0RRjjynTgnEaONroKt9m)Hb16XH10A02j89Rh4rtfg)76fUkSaPqQhcfjAhPfcibMfuubctXwYG0Sobzf)buN01xpPS36HruNZ0DvawtRrM1UZ0g5KJjf16tsUG10AK5BtkJCiJzIMTqTECvybsH0W35(YvlXIQSacibMfuxPceMITKbPzDcYk(dOoPRVEszV1dJOoNP7I10AKccL9M0e2mQ1NK8XbC2PIhvGWuSLminRtqwXFa1jD9D7e((1d8ubctXwYG0Sobzf)buN01xpPS36HruubctXwYG0Sobzf)buN013ozMA)BYVnPubctXwYG0Sobzf)buN01xwUhikg5q2jZu7FJkavGWuSLmOHroSGSI)aQUJ)nRD6TSQG)CMU7hhGG3FQ4WAAnsbHYEtAcBgPwpeCynTgLH8(3KRwABgMsQEiYdsTEiubctXwYGgg5WcYk(dOoPRVF0zCa)5mDx8XAAnsbHYEtAcBg16XDXSRvTEiiZA3zAJCYXKIEihmYiOxjjxQWcKc5jEShc)HhbKaZckCMDTQ1db5jEShc)Hh9qoyKrqVUELkqyk2sg0WihwqwXFa1jD91S2DM2iNCmPNZ0DXhMbigazwIcidOKwMg07BaeqcmlOWHFfwGuOCmtyEabKaZckCxQ4pGcvSmiRv2BkPx4DMW4LKOzhPL8HCWiZz3J31KeygGyaKzjkGmGsAzAqVVbqajWSGch(vybsHYXmH5beqcmlOWDPI)akuXYGSwzVPKEH3zcJxsIMDKwYhYbJmNje4DnjPclqkuoMjmpGasGzbfUlv8hqHkwgK1k7nLuO3FMW4LKOzhPL8HCWiZz3J3vQaHPylzqdJCybzf)buN01xpXJ9q4p8NZ0DXhMbigazwIcidOKwMg07BaeqcmlOWHFfwGuOCmtyEabKaZckCxQ4pGcvSmiRv2BkPx4DMW4LKOzhPL8HCWiZz3J31KeygGyaKzjkGmGsAzAqVVbqajWSGch(vybsHYXmH5beqcmlOWDPI)akuXYGSwzVPKEH3zcJxsIMDKwYhYbJmNje4DnjPclqkuoMjmpGasGzbfUlv8hqHkwgK1k7nLuO3FMW4LKOzhPL8HCWiZz3J3vQaHPylzqdJCybzf)buN01xfek7nPjSzQaHPylzqdJCybzf)buN01xZsuqMCot3fRP1OPPuarQGOsrpeMIkqyk2sg0WihwqwXFa1jD9fesW0k4CMUlwtRrttPaIubrLIEimfvGWuSLmOHroSGSI)aQt66lMnuWu7NpNP7A21QwpeuE)kSYPEM)a6HCWidofG10AKzT7mTro5ysrQ1db3f8RWcKcPGqzVjnHnJasGzbvscwtRrkiu2BstyZi16HCf3LlkaRP1iZA3zAJCYXKIA94WpUd8ScqfmLC1Ym7iTqajWSG6AscwtRrfmLC1Ym7iTqT(R4WAAnkd59VjxT02mmLu9qKhKA9qW9Xbi4PGhvGWuSLmOHroSGSI)aQt66RXcrNW5mD3PhSwzf)budYtk7TEye1zErfimfBjdAyKdliR4pG6KU(UDcF)6b(Zz6UxWVclqk0defcibMfu4uBHua0l9SnIAqpKdgzW9Xbi4PJhoSMwJYqE)BYvlTndtjvpe5bPwpeCkaRP1iZA3zAJCYXKIuRhY1KKlvybsHEGOqajWSGcNAlKcGEPNTrud6HCWido1wOhik0d5GrMZomkCFCacE64HdRP1OmK3)MC1sBZWus1drEqQ1dbNcWAAnYS2DM2iNCmPi16HCLkqyk2sg0WihwqwXFa1jD9nVFfw5upZFGkqyk2sg0WihwqwXFa1jD99bI6CMU7d5Grgb7QAFuSLCxJhsOubctXwYGgg5WcYk(dOoPRVEszV1dJOoNP7E5YfSMwJYqE)BYvlTndtjvpe5b16VMKCrbynTgzw7otBKtoMuuR)AsYfSMwJuqOS3KMWMrT(RxXvHfifsdFN7lxTelQYciGeywqDnj5YfSMwJYqE)BYvlTndtjvpe5b16ts(4aoti8XxXPaSMwJmRDNPnYjhtkQ1JdRP1OcMsUAzMDKwi16HGd)kSaPqA47CF5QLyrvwabKaZcQRubctXwYGgg5WcYk(dOoPRVJnYNZ0DXVclqkKg(o3xUAjwuLfqajWSGc3fSMwJYqE)BYvlTndtjvpe5b16tsuawtRrM1UZ0g5KJjf16VsfimfBjdAyKdliR4pG6KU(UDcF)6bEQaHPylzqdJCybzf)buN01xpPS36HruNZ0DRWcKcPHVZ9LRwIfvzbeqcmlOWDbRP1OcMsUAzMDKwOwFsIcWAAnYS2DM2iNCmPi16HGdRP1OcMsUAzMDKwi16HG7Jd4StfVRubctXwYGgg5WcYk(dOoPRVJnYNZ0DXVclqkKg(o3xUAjwuLfqajWSGIkqyk2sg0WihwqwXFa1jD9TtMP2)M8BtkvGWuSLmOHroSGSI)aQt66ll3defJCi7KzQ9V5eNEW4870f2vUY5a]] )


end
