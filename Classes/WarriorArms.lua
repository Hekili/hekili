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


    spec:RegisterPack( "Arms", 20201013, [[dG0JvbqieYJuPGnreFIiPknke4uQuTkIK4vsLmlvuULkfQDb6xIQAyQKogc1YOk8mvettQuCnIeBtQu13issJtQu6CejL1jvQuMhc6EIk7tfPdkvQyHsf9qPsLQlsKuPtQsH0kjsntIKQYoLk8tvkenuIKkwkrsv1tjQPkQYvjsQITkvQK(Qkfc7Lk)LWGr1HfwmIEmPMmfxgAZu6ZQWOfLtJYQPkYRvr1Sj52ISBK(TIHlvDCPsLy5Q65knDjxxkBxLsFNQ04vPOZRsSEQIA(uv7hyhXU8CYMOqxhEC1JReFL4tGxLAs5Qu6wNCDPhDY9H(84aDY0iHo5UZNwNCFCrnHXLNtEN2RrNCwv9B3T8Z)GvznsOEs5VSutffBO6pSv(llPZ3jt2yQ6gL6iDYMOqxhEC1JReFL4tGxLAs5A3i1CYrRYM3jlZsnvuSH2D)dB5KZygdsDKozdUAN8na4DNpTa(nI4F28aPVba)gPUgs8bCIp5ma3JREC1jRyBTU8CYlJEOqrf)bwU8CDqSlpNmsdsfACD6K1pRWNfo5htbJUaoH5aCt7JInuaxQa4xHN4KdDXgQt(rQXvUo8WLNto0fBOozdgg1fHoujNmsdsfACD6kxhN4YZjJ0GuHgxNoz9Zk8zHt(JdeWjeW7(RaUeaNSzTqdgg1fHoujOz8sbCjaozZAHjmn)fXyfQMMzeMhJ0cnJxkG77d4FCGaoHaUhxDYHUyd1jVN3uQTxXQcFx56OBC55KrAqQqJRtNS(zf(SWjtaGRNrzgVuOEuZUTvSPyZGpMcgDbCcbCpaCFFaNaaVcfslO34jFmohFisdsfAaCjaUEgLz8sHEJN8X4C8HpMcgDbCcbCpa87a(DNCOl2qDYFCBCGVRCDifxEozKgKk0460jRFwHplCYMPGge7fENg1SWhtbJUaoH5aCt7JInuaxQa4xHNa4saCca8Thvkrf)bwl0Bg7vEzudGNdWjgW99bCIa8kuiTGAfg3IqKgKk0a43DYHUyd1jNMVcLyRNDo6kxhDVlpNmsdsfACD6K1pRWNfo5Thvkrf)bwl0Bg7vEzudGFkG7bGlbWntbni2l8onQzHpMcgDbCcZb4M2hfBOaUubWVcpXjh6InuNSwHXTORCDivD55KrAqQqJRtNS(zf(SWjteGJ7Iunc1d1G0fncfZI251iePbPcnaUeaNiaVcfslyk2n0pcrAqQqdGlbWjaWR4pWcwSekQr0RlHhxb8tbCIVc4((aEf)bwWILqrncddb8tbCPCfWVd4((aoUls1iupudsx0iumlANxJqKgKk0a4saCIa8kuiTGPy3q)iePbPcnaUeaNaaVI)alyXsOOgrVUeECfWpfWj(kG77d4v8hyblwcf1immeWpfW72Ra(Da33hWRqH0cMIDd9JqKgKk0a4saCca8k(dSGflHIAe96sCIua8tbCIVc4((aEf)bwWILqrncddb8tbCPCfWV7KdDXgQtwpQz32k2uSzUY1r36YZjJ0GuHgxNoz9Zk8zHtMSzTWTzmivyWOYGpg6Yjh6InuNmEtu3k0vUoKAU8CYinivOX1Ptw)ScFw4K1ZOmJxkmnFfkXwp7Ce(yky0fWLa4gKSzTq9OMDBRytXMbnJxkGlbWjaWjcWRqH0cAWWOUi0HkbrAqQqdG77d4KnRfAWWOUi0HkbnJxkGFhWLa4ea4ea4gKSzTq9OMDBRytXMbB9aUeaNiap8m(ScHfULySIe7iRGinivObWVd4((aozZAHfULySIe7iRGTEa)oGlbWjBwlmHP5VigRq10mJW8yKwOz8sbCja(hhiGtiG3nxDYHUyd1jtQcdU18jx56G4RU8CYinivOX1Ptw)ScFw4K3EuPev8hyTqVzSx5LrnaEoaNya33hWjcWRqH0cQvyClcrAqQqJto0fBOo508vOeB9SZrx56GyID55KrAqQqJRtNS(zf(SWjV9OsjQ4pWAHEZyVYlJAa8tbCpCYHUyd1jRvyCl6kxhe7HlpNmsdsfACD6K1pRWNfozcaCcaCcaCYM1ctyA(lIXkunnZimpgPf26b87aUVpGtaGBqYM1c1JA2TTInfBgS1d43bCFFaNaaNSzTqdgg1fHoujyRhWVd43bCjaEfkKwql(3oVyScYOkfcrAqQqdGFhW99bCcaCcaCYM1ctyA(lIXkunnZimpgPf26bCFFa)JdeWpfW7wPgGFhWLa4gKSzTq9OMDBRytXMbB9aUeaNSzTWc3smwrIDKvqZ4Lc4saCIa8kuiTGw8VDEXyfKrvkeI0GuHga)Uto0fBOozVzSx5LrnUY1bXN4YZjJ0GuHgxNoz9Zk8zHtMiaVcfslOf)BNxmwbzuLcHinivObWLa4ea4KnRfMW08xeJvOAAMryEmslS1d4((aUbjBwlupQz32k2uSzWwpGF3jh6InuN8QIKRCDqC34YZjh6InuN8Cl(9Jx8DYinivOX1PRCDqSuC55KrAqQqJRtNS(zf(SWjxHcPf0I)TZlgRGmQsHqKgKk0a4saCcaCYM1clClXyfj2rwbB9aUVpGBqYM1c1JA2TTInfBg0mEPaUeaNSzTWc3smwrIDKvqZ4Lc4sa8poqa)uaV7Vc43DYHUyd1j7nJ9kVmQXvUoiU7D55KrAqQqJRtNS(zf(SWjteGxHcPf0I)TZlgRGmQsHqKgKk04KdDXgQtEvrYvUoiwQ6YZjh6InuN8TmDn)fX32mNmsdsfACD6kxhe3TU8CYHUyd1jZs9i1WOhIBz6A(lozKgKk0460vUYjJ3e1TcD556GyxEozKgKk0460jRFwHplCYpMcgDbCcZb4M2hfBOaUubWVcpXjh6InuN8JuJRCD4HlpNCOl2qDYgmmQlcDOsozKgKk0460vUooXLNtgPbPcnUoDY6Nv4ZcN8hhiGtiGlfpaCjaozZAHjmn)fXyfQMMzeMhJ0cnJxkG77d4FCGaoHaUhxDYHUyd1jVN3uQTxXQcFx56OBC55KrAqQqJRtNS(zf(SWjRNrzgVuOEuZUTvSPyZGpMcgDbCcbCpaCFFaNaaVcfslO34jFmohFisdsfAaCjaUEgLz8sHEJN8X4C8HpMcgDbCcbCpa87o5qxSH6K)424aFx56qkU8CYinivOX1Ptw)ScFw4KjcWXDrQgHjmn)fXyfQMMzeMhJ0ctHNMhW99bCcaCYM1ctyA(lIXkunnZimpgPf26bCFFaxpJYmEPWeMM)IyScvtZmcZJrAHpMcgDb8tbCIVc43DYHUyd1jRh1SBBfBk2mx56O7D55KrAqQqJRtNS(zf(SWjteGJ7IunctyA(lIXkunnZimpgPfMcpnpG77d4ea4KnRfMW08xeJvOAAMryEmslS1d4((aUEgLz8sHjmn)fXyfQMMzeMhJ0cFmfm6c4Nc4eFfWV7KdDXgQt2B8KpgNJVRCDivD55KrAqQqJRtNS(zf(SWjBMcAqSx4DAuZcFmfm6c4eMdWnTpk2qbCPcGFfEcGlbWjaW3EuPev8hyTqVzSx5LrnaEoaNya33hWjcW3EuPev8hyTqVzSx5Lrna(PaoXaUeaNiaVcfslOwHXTiePbPcna(DNCOl2qDYP5Rqj26zNJUY1r36YZjJ0GuHgxNoz9Zk8zHtMaaF7rLsuXFG1c9MXELxg1a4Nc4Ea4saCZuqdI9cVtJAw4JPGrxaNWCaUP9rXgkGlva8RWta87aUVpGtaGV9OsjQ4pWAHEZyVYlJAa8tb8ta87o5qxSH6K1kmUfDLRdPMlpNmsdsfACD6K1pRWNfozIaCYM1ctyA(lIXkunnZimpgPf26bCjaozZAHfULySIe7iRGTEaxcG)Xbc4ec4NCfWLa4eb4KnRfAWWOUi0HkbB9o5qxSH6KjvHb3A(KRCDq8vxEozKgKk0460jRFwHplCYKnRfMW08xeJvOAAMryEmslS1d4((aozZAHgmmQlcDOsWwpG77d4gKSzTq9OMDBRytXMbB9aUVpGt2SwyHBjgRiXoYkyR3jh6InuNmEtu3k0vUoiMyxEozKgKk0460jRFwHplCYKnRfQ)2MXOhIy3OPkyRhWLa4KnRfMW08xeJvOAAMryEmsl0mEPo5qxSH6KxvKCLRdI9WLNtgPbPcnUoDY6Nv4ZcN8JPGrxaNWCaUP9rXgkGlva8RWtaCjaEf)bwWILqrncddb8tbCPQto0fBOo5hPgx56G4tC55KdDXgQtEUf)(Xl(ozKgKk0460vUoiUBC55KdDXgQtwpudMOozKgKk0460vUoiwkU8CYHUyd1jJ3e1TcDYinivOX1PRCDqC37YZjh6InuN8TmDn)fX32mNmsdsfACD6kxhelvD55KdDXgQtML6rQHrpe3Y018xCYinivOX1PRCLt2G2OPkxEUoi2LNto0fBOozDw8hOtgPbPcnUoDLRdpC55KdDXgQtUVLsOYjJ0GuHgxNUY1XjU8CYinivOX1Ptw)ScFw4KjaWR4pWcMHHQYG96cWjeW9Gya33hWRqH0cMIDd9JqKgKk0a4sa8k(dSGzyOQmyVUaCcb8t6Ea)oGlbWjaWjBwlmHP5VigRq10mJW8yKwyRhW99bCYM1cpAXBybvmwr4z8Nkd26b87aUVpGteGJ7IunctyA(lIXkunnZimpgPfMcpnpGlbWjcWXDrQgH6HAq6IgHIzr78AeMcpnpGlbWjaWR4pWcMHHQYG96cWjeW9Gya33hWRqH0cMIDd9JqKgKk0a4sa8k(dSGzyOQmyVUaCcb8t6Ea)oGlbWnizZAH6rn72wXMInd26bCFFa3YoYkXJPGrxaNqa3dP4KdDXgQtUFk2qDLRJUXLNtgPbPcnUoDY6Nv4ZcNmzZAHjmn)fXyfQMMzeMhJ0cB9aUeaNSzTWc3smwrIDKvWwpG77d4KnRfE0I3WcQySIWZ4pvgS1d4saCds2SwOEuZUTvSPyZGTEa33hWjBwlCrSYy0dXhhiS1d4((aobaoraoUls1imHP5VigRq10mJW8yKwyk808aUeaNiah3fPAeQhQbPlAekMfTZRryk808aUeaNiah3fPAesQMXigROYqbsX0fyk808aUea3GKnRfQh1SBBfBk2myRhWV7KdDXgQtMunJryB)fx56qkU8CYinivOX1Ptw)ScFw4KjBwlmHP5VigRq10mJW8yKwyRhWLa4KnRfw4wIXksSJSc26bCFFaNSzTWJw8gwqfJveEg)PYGTEaxcGBqYM1c1JA2TTInfBgS1d4((aozZAHlIvgJEi(4aHTEa33hWjaWjcWXDrQgHjmn)fXyfQMMzeMhJ0ctHNMhWLa4eb44UivJq9qniDrJqXSODEnctHNMhWLa4eb44UivJqs1mgXyfvgkqkMUatHNMhWLa4gKSzTq9OMDBRytXMbB9a(DNCOl2qDYK4V4FoJE4kxhDVlpNmsdsfACD6K1pRWNfozYM1ctyA(lIXkunnZimpgPfAgVuaxcG)Xbc4ec4s5kGlbWjaW1ZOmJxkmnFfkXwp7Ce(yky0fWpfWp0ga33hWjaWR4pWcMHHQYG96cWjeW94kG77d4vOqAbtXUH(risdsfAaCjaEf)bwWmmuvgSxxaoHa(jsbWVd43DYHUyd1jhVoOOOM)rA5kxhsvxEozKgKk0460jRFwHplCYgKSzTq9OMDBRytXMbnJxQto0fBOozf7iRwHNAMJeslx56OBD55KrAqQqJRtNS(zf(SWjt2SwyctZFrmwHQPzgH5XiTWwpGlbWjBwlSWTeJvKyhzfS1d4((aozZAHhT4nSGkgRi8m(tLbB9aUea3GKnRfQh1SBBfBk2myRhW99bCYM1cxeRmg9q8XbcB9aUVpGtaGteGJ7IunctyA(lIXkunnZimpgPfMcpnpGlbWjcWXDrQgH6HAq6IgHIzr78AeMcpnpGlbWjcWXDrQgHKQzmIXkQmuGumDbMcpnpGlbWnizZAH6rn72wXMInd26b87o5qxSH6KTShjvZyCLRdPMlpNmsdsfACD6K1pRWNfozYM1ctyA(lIXkunnZimpgPf26bCjaozZAHfULySIe7iRGTEa33hWjBwl8OfVHfuXyfHNXFQmyRhWLa4gKSzTq9OMDBRytXMbB9aUVpGt2Sw4IyLXOhIpoqyRhW99bCcaCIaCCxKQryctZFrmwHQPzgH5XiTWu4P5bCjaoraoUls1iupudsx0iumlANxJWu4P5bCjaoraoUls1iKunJrmwrLHcKIPlWu4P5bCjaUbjBwlupQz32k2uSzWwpGF3jh6InuNCq14wFOe6qPCLRdIV6YZjJ0GuHgxNoz9Zk8zHt2GKnRfQh1SBBfBk2mOz8sbCjaozZAHjmn)fXyfQMMzeMhJ0cnJxkGlbW1ZOmJxkmnFfkXwp7Ce(yky01jh6InuNmzCigROEM(81vUoiMyxEozKgKk0460jh6InuNCSz3guCfF455f65dLtw)ScFw4KjcWnizZAHF455f65dLWGKnRf26bCFFaNaaNaaVI)alyggQkd2RlaNqa3JRqIbCFFaVcfslyk2n0pcrAqQqdGlbWR4pWcMHHQYG96cWjeWprkqIb87aUeaNaaNSzTWeMM)IyScvtZmcZJrAHTEaxcGtaGRNrzgVuyctZFrmwHQPzgH5XiTWhtbJUaoHaoXx7Ea33hW1ZOmJxkmHP5VigRq10mJW8yKw4JPGrxaNqaNyILQaUea3YoYkXJPGrxaNqa3JRaUeaNiaVcfslyk2n0pcrAqQqdGFhW99bCYM1cpAXBybvmwr4z8Nkd26bCjaUbjBwlupQz32k2uSzWwpGFhWVd4((aoUls1iupudsx0iumlANxJWu4P5bCjaEf)bwWmmuvgSxxaoHaUhxbCFFaNaaVI)alyggQkd2RlaNqa)KRqIbCjaUbjBwluputtxSBrbJEUWGKnRf26bCjaoraoUls1imHP5VigRq10mJW8yKwyk808aUeaNiah3fPAeQhQbPlAekMfTZRryk808a(Da33hWjaWjcWnizZAH6HAA6IDlky0ZfgKSzTWwpGlbWjcWXDrQgHjmn)fXyfQMMzeMhJ0ctHNMhWLa4eb44UivJq9qniDrJqXSODEnctHNMhWLa4gKSzTq9OMDBRytXMbB9a(DNmnsOto2SBdkUIp888c98HYvUoi2dxEozKgKk0460jh6InuNC45nl(yf2HwIXk6hV47K1pRWNfo5ILqrncddbCcbCP6vaxcGtaGRNrzgVuOEuZUTvSPyZGpMcgDbCcbCI9aW99bCca8kuiTGEJN8X4C8HinivObWLa46zuMXlf6nEYhJZXh(yky0fWjeWj2da)oGFhW99bCIaCds2SwOEuZUTvSPyZGTEaxcGteGt2SwyHBjgRiXoYkyRhWLa4eb4KnRfMW08xeJvOAAMryEmslS1d4sa8ILqrncddb8tbCILYvNmnsOto88MfFSc7qlXyf9Jx8DLRdIpXLNtgPbPcnUoDY6Nv4ZcNmraoUls1imHP5VigRq10mJW8yKwyk808aUVpGtaGt2SwyctZFrmwHQPzgH5XiTWwpG77d46zuMXlfMW08xeJvOAAMryEmsl8XuWOlGFkG3nsbWV7KdDXgQtoUnQ4DLRdI7gxEozKgKk0460jRFwHplCY6zuMXlfQh1SBBfBk2m4JPGrxaNqaVBbCFFaNaaVcfslO34jFmohFisdsfAaCjaUEgLz8sHEJN8X4C8HpMcgDbCcb8UfWV7KdDXgQtUTOGvyADLRdILIlpNmsdsfACD6K1pRWNfo5Thvkrf)bwl0Bg7vEzudGFkGtmGlbWjaW1ZOmJxkKufgCR5tWhtbJUa(PaoXxbCFFaxpJYmEPq9OMDBRytXMbFmfm6c4Nc4DlG77d4HNXNviSWTeJvKyhzfePbPcna(DNCOl2qDYRxe7z0dXwp7CCDLRdI7ExEozKgKk0460jRFwHplCYea4KnRfw4wIXksSJSc26bCFFaNaa3GKnRfQh1SBBfBk2myRhWLa4eb4HNXNviSWTeJvKyhzfePbPcna(Da)oGlbWjaWTSJSs8yky0fWpfWLAxbCFFaNaaVI)alyggQkd2RlaNqa3JRaUVpGxHcPfmf7g6hHinivObWLa4v8hybZWqvzWEDb4ec4Nifa)oGF3jh6InuNmPAgJySIkdfiftxCLRdILQU8CYinivOX1Ptw)ScFw4KjcWnizZAH6rn72wXMInd26bCjaoraozZAHfULySIe7iRGTENCOl2qDY9TNzVWOhcsvSLRCDqC36YZjJ0GuHgxNoz9Zk8zHtMia3GKnRfQh1SBBfBk2myRhWLa4eb4KnRfw4wIXksSJSc26DYHUyd1j)S(EfkyuX2hA0vUoiwQ5YZjJ0GuHgxNoz9Zk8zHtMia3GKnRfQh1SBBfBk2myRhWLa4eb4KnRfw4wIXksSJSc26DYHUyd1j7DEL5wKrfpUdnOA0vUo84QlpNmsdsfACD6K1pRWNfozIaCds2SwOEuZUTvSPyZGTEaxcGteGt2SwyHBjgRiXoYkyR3jh6InuNSD0TfnIWZ4ZkuqIrYvUo8GyxEozKgKk0460jRFwHplCYeb4gKSzTq9OMDBRytXMbB9aUeaNiaNSzTWc3smwrIDKvWwVto0fBOo5hJEg9qyvrcxx56WdpC55KrAqQqJRtNS(zf(SWjteGBqYM1c1JA2TTInfBgS1d4saCIaCYM1clClXyfj2rwbB9aUea3mfupunsRpk0iSQiHcY2tHpMcgDb8Ca(vNCOl2qDY6HQrA9rHgHvfj0vUo84exEozKgKk0460jRFwHplCYKnRf(O(CfURWoVgHTENCOl2qDYvgkAuYPrnc78A0vUo8OBC55KrAqQqJRtNS(zf(SWjteGxHcPf0B8KpgNJpePbPcnaUeaxpJYmEPq9OMDBRytXMbFmfm6c4ec4sbWLa4ea4w2rwjEmfm6c4Nc4Eq8va33hWjaWR4pWcMHHQYG96cWjeW94kG77d4vOqAbtXUH(risdsfAaCjaEf)bwWmmuvgSxxaoHa(jsbWVd4((aULDKvIhtbJUaoHa(jed43DYHUyd1jF0I3WcQySIWZ4pvMRCD4HuC55KrAqQqJRtNS(zf(SWjxHcPf0B8KpgNJpePbPcnaUeaxpJYmEPqVXt(yCo(WhtbJUaoHaUuaCjaobaULDKvIhtbJUa(PaUheFfW99bCca8k(dSGzyOQmyVUaCcbCpUc4((aEfkKwWuSBOFeI0GuHgaxcGxXFGfmddvLb71fGtiGFIua87aUVpGBzhzL4XuWOlGtiGFcXa(DNCOl2qDYhT4nSGkgRi8m(tL5kxhE09U8CYinivOX1Ptw)ScFw4KjcWRqH0c6nEYhJZXhI0GuHgaxcGRNrzgVuOEuZUTvSPyZGpMcgDbCcbCIbCjaobaULDKvIhtbJUa(PaoXs5kG77d4ea4v8hybZWqvzWEDb4ec4ECfW99b8kuiTGPy3q)iePbPcnaUeaVI)alyggQkd2RlaNqa)ePa43b87o5qxSH6KtyA(lIXkunnZimpgP1vUo8qQ6YZjJ0GuHgxNoz9Zk8zHtUcfslO34jFmohFisdsfAaCjaUEgLz8sHEJN8X4C8HpMcgDbCcbCIbCjaobaULDKvIhtbJUa(PaoXs5kG77d4ea4v8hybZWqvzWEDb4ec4ECfW99b8kuiTGPy3q)iePbPcnaUeaVI)alyggQkd2RlaNqa)ePa43b87o5qxSH6KtyA(lIXkunnZimpgP1vUo8OBD55KdDXgQtE7X4fJvqgBXgQtgPbPcnUoDLRdpKAU8CYHUyd1jRhA3Lg(ZVcYGsX3jJ0GuHgxNUY1XjxD55KdDXgQtoOAgslryl83SrFUtgPbPcnUoDLRJti2LNtgPbPcnUoDY6Nv4ZcNmzZAHBZyqQWGrLbB9aUVpG)Xbc4NMdW7MRaUVpGxXFGfSyjuuJWWqaNqa)qBCYHUyd1jRhQbtux564epC55KrAqQqJRtNS(zf(SWjtaGxHcPfmf7g6hHinivObWLa4v8hybZWqvzWEDb4ec4Nifa)oG77d4v8hybZWqvzWEDb4ec4EC1jh6InuN83OIqxSHkuSTCYk2wcAKqNmEtu3k0vUoo5exEozKgKk0460jh6InuN83OIqxSHkuSTCYk2wcAKqN8YOhkuuXFGLRCLtU)r9KiJYLNRdID55KdDXgQtMmQsHInBALtgPbPcnUoDLRdpC55KrAqQqJRtNmnsOto88MfFSc7qlXyf9Jx8DYHUyd1jhEEZIpwHDOLySI(Xl(UY1XjU8CYinivOX1Ptw)ScFw4KRqH0cAX)25fJvqgvPqisdsfAaCFFaNiaVcfslOf)BNxmwbzuLcHinivObWLa4flHIAeggc4Nc4elLRo5qxSH6KtyA(lIXkunnZimpgP1vUo6gxEozKgKk0460jRFwHplCYvOqAbT4F78IXkiJQuiePbPcnaUVpGxHcPfmf7g6hHinivObWLa4flHIAeggc4Nc4Eq8va33hWRqH0c(i1arAqQqdGlbWjaWlwcf1immeWpfW9G4RaUVpGxSekQryyiGtiGtC3ifa)Uto0fBOo5Jw8gwqfJveEg)PYCLRCLt(w8x2qDD4XvpUETBp5kKyNS34Pm6X6KVrt9ZxObW7gap0fBOaUIT1cbs7K7)XYuOt(ga8UZNwa)gr8pBEG03aGFJuxdj(aoXNCgG7XvpUcKgi9na4D3Zc6bUD3asFda(ngW7ogdAaCPoTucvqG03aGFJb8UJXGgaV7ktxZFbWL6VTz5FJM6rQHrpa8URmDn)fiq6BaWVXaE3XyqdG3zuLcbC5SPvaEnaE)J6jrgfG3DK6i1hei9na43yaxQ7nrDRydfFPExaxQZJA2YgkGZwa3GkSqdei9na43yaV7ymObWL6zra)gTW0cbsdK(gaCPU3e1TcnaojANhbC9KiJcWjXdgDHaE3rRX(AbC6qVXzXNSnfGh6In0fWhQ6cei9na4HUydDH9pQNezu5SQyphi9na4HUydDH9pQNezuDLlF7mgG03aGh6In0f2)OEsKr1vU8J2rcPvuSHcK(gaCzA0Vztb4FWmaozZArdGVvulGtI25raxpjYOaCs8GrxapOgaV)XBC)ufJEa4SfWndfHaPdDXg6c7FupjYO6kx(KrvkuSztRash6In0f2)OEsKr1vU8BlkyfMoJgjmx45nl(yf2HwIXk6hV4dKo0fBOlS)r9KiJQRC5NW08xeJvOAAMryEms7zmBUkuiTGw8VDEXyfKrvkeI0GuHgFFIQqH0cAX)25fJvqgvPqisdsfAKuSekQryy4PelLRaPdDXg6c7FupjYO6kx(hT4nSGkgRi8m(tLDgZMRcfslOf)BNxmwbzuLcHinivOX3Vcfslyk2n0pcrAqQqJKILqrncddp1dIV67xHcPf8rQbI0GuHgjeuSekQryy4PEq8vF)ILqrncddjK4Urk3bsdK(gaCPU3e1TcnaoEl(xa8ILqaVYqap018aoBb842GPcsfcbsh6In0nNol(deiDOl2q3UYLFFlLqfq6qxSHUDLl)(Pyd9mMnhbv8hybZWqvzWEDrOhe77xHcPfmf7g6hHinivOrsf)bwWmmuvgSxxeEs3FxcbKnRfMW08xeJvOAAMryEmslS177t2Sw4rlEdlOIXkcpJ)uzWw)DFFIWDrQgHjmn)fXyfQMMzeMhJ0ctHNMxcr4UivJq9qniDrJqXSODEnctHNMxcbv8hybZWqvzWEDrOhe77xHcPfmf7g6hHinivOrsf)bwWmmuvgSxxeEs3FxIbjBwlupQz32k2uSzWwVVVLDKvIhtbJUe6Huash6In0TRC5tQMXiST)YzmBoYM1ctyA(lIXkunnZimpgPf26Lq2SwyHBjgRiXoYkyR33NSzTWJw8gwqfJveEg)PYGTEjgKSzTq9OMDBRytXMbB9((KnRfUiwzm6H4Jde2699jGiCxKQryctZFrmwHQPzgH5XiTWu4P5LqeUls1iupudsx0iumlANxJWu4P5LqeUls1iKunJrmwrLHcKIPlWu4P5LyqYM1c1JA2TTInfBgS1FhiDOl2q3UYLpj(l(NZOhNXS5iBwlmHP5VigRq10mJW8yKwyRxczZAHfULySIe7iRGTEFFYM1cpAXBybvmwr4z8Nkd26LyqYM1c1JA2TTInfBgS177t2Sw4IyLXOhIpoqyR33NaIWDrQgHjmn)fXyfQMMzeMhJ0ctHNMxcr4UivJq9qniDrJqXSODEnctHNMxcr4UivJqs1mgXyfvgkqkMUatHNMxIbjBwlupQz32k2uSzWw)DG0HUydD7kx(XRdkkQ5FKwNXS5iBwlmHP5VigRq10mJW8yKwOz8sL8XbsOuUkHa9mkZ4LctZxHsS1ZohHpMcgDp9qB89jOI)alyggQkd2Rlc94QVFfkKwWuSBOFeI0GuHgjv8hybZWqvzWEDr4js5(DG0HUydD7kx(k2rwTcp1mhjKwNXS5mizZAH6rn72wXMIndAgVuG0HUydD7kx(w2JKQzmNXS5iBwlmHP5VigRq10mJW8yKwyRxczZAHfULySIe7iRGTEFFYM1cpAXBybvmwr4z8Nkd26LyqYM1c1JA2TTInfBgS177t2Sw4IyLXOhIpoqyR33NaIWDrQgHjmn)fXyfQMMzeMhJ0ctHNMxcr4UivJq9qniDrJqXSODEnctHNMxcr4UivJqs1mgXyfvgkqkMUatHNMxIbjBwlupQz32k2uSzWw)DG0HUydD7kx(bvJB9HsOdL6mMnhzZAHjmn)fXyfQMMzeMhJ0cB9siBwlSWTeJvKyhzfS177t2Sw4rlEdlOIXkcpJ)uzWwVeds2SwOEuZUTvSPyZGTEFFYM1cxeRmg9q8XbcB9((eqeUls1imHP5VigRq10mJW8yKwyk808sic3fPAeQhQbPlAekMfTZRryk808sic3fPAesQMXigROYqbsX0fyk808smizZAH6rn72wXMInd26VdKo0fBOBx5YNmoeJvuptF(EgZMZGKnRfQh1SBBfBk2mOz8sLq2SwyctZFrmwHQPzgH5XiTqZ4LkrpJYmEPW08vOeB9SZr4JPGrxG0HUydD7kx(TffSctNrJeMl2SBdkUIp888c98H6mMnhrgKSzTWp888c98HsyqYM1cB9((eqqf)bwWmmuvgSxxe6XviX((vOqAbtXUH(risdsfAKuXFGfmddvLb71fHNifiX3LqazZAHjmn)fXyfQMMzeMhJ0cB9siqpJYmEPWeMM)IyScvtZmcZJrAHpMcgDjK4RDVVVEgLz8sHjmn)fXyfQMMzeMhJ0cFmfm6siXelvLyzhzL4XuWOlHECvcrvOqAbtXUH(risdsfAU77t2Sw4rlEdlOIXkcpJ)uzWwVeds2SwOEuZUTvSPyZGT(7399XDrQgH6HAq6IgHIzr78AeMcpnVKk(dSGzyOQmyVUi0JR((euXFGfmddvLb71fHNCfsSeds2SwOEOMMUy3Icg9CHbjBwlS1lHiCxKQryctZFrmwHQPzgH5XiTWu4P5LqeUls1iupudsx0iumlANxJWu4P5V77targKSzTq9qnnDXUffm65cds2SwyRxcr4UivJWeMM)IyScvtZmcZJrAHPWtZlHiCxKQrOEOgKUOrOyw0oVgHPWtZlXGKnRfQh1SBBfBk2myR)oq6qxSHUDLl)2IcwHPZOrcZfEEZIpwHDOLySI(Xl(NXS5kwcf1immKqP6vjeONrzgVuOEuZUTvSPyZGpMcgDjKyp89jOcfslO34jFmohFisdsfAKONrzgVuO34jFmohF4JPGrxcj2J7399jYGKnRfQh1SBBfBk2myRxcrKnRfw4wIXksSJSc26LqezZAHjmn)fXyfQMMzeMhJ0cB9skwcf1imm8uILYvG0HUydD7kx(XTrf)zmBoIWDrQgHjmn)fXyfQMMzeMhJ0ctHNM33NaYM1ctyA(lIXkunnZimpgPf26991ZOmJxkmHP5VigRq10mJW8yKw4JPGr3t7gPChiDOl2q3UYLFBrbRW0EgZMtpJYmEPq9OMDBRytXMbFmfm6sy367tqfkKwqVXt(yCo(qKgKk0irpJYmEPqVXt(yCo(WhtbJUe2T3bsh6In0TRC5VErSNrpeB9SZX9mMn32JkLOI)aRf6nJ9kVmQ5uILqGEgLz8sHKQWGBnFc(yky09uIV67RNrzgVuOEuZUTvSPyZGpMcgDpTB99dpJpRqyHBjgRiXoYkisdsfAUdKo0fBOBx5YNunJrmwrLHcKIPlNXS5iGSzTWc3smwrIDKvWwVVpbgKSzTq9OMDBRytXMbB9sik8m(ScHfULySIe7iRGinivO5(DjeyzhzL4XuWO7PsTR((euXFGfmddvLb71fHEC13Vcfslyk2n0pcrAqQqJKk(dSGzyOQmyVUi8ePC)oq6qxSHUDLl)(2ZSxy0dbPk26mMnhrgKSzTq9OMDBRytXMbB9siISzTWc3smwrIDKvWwpq6qxSHUDLl)N13RqbJk2(qJNXS5iYGKnRfQh1SBBfBk2myRxcrKnRfw4wIXksSJSc26bsh6In0TRC57DEL5wKrfpUdnOA8mMnhrgKSzTq9OMDBRytXMbB9siISzTWc3smwrIDKvWwpq6qxSHUDLlF7OBlAeHNXNvOGeJ0zmBoImizZAH6rn72wXMInd26LqezZAHfULySIe7iRGTEG0HUydD7kx(pg9m6HWQIeUNXS5iYGKnRfQh1SBBfBk2myRxcrKnRfw4wIXksSJSc26bsh6In0TRC5RhQgP1hfAewvKWZy2CezqYM1c1JA2TTInfBgS1lHiYM1clClXyfj2rwbB9smtb1dvJ06JcncRksOGS9u4JPGr3Cxbsh6In0TRC5xzOOrjNg1iSZRXZy2CKnRf(O(CfURWoVgHTEG0HUydD7kx(hT4nSGkgRi8m(tLDgZMJOkuiTGEJN8X4C8HinivOrIEgLz8sH6rn72wXMInd(yky0LqPiHal7iRepMcgDp1dIV67tqf)bwWmmuvgSxxe6XvF)kuiTGPy3q)iePbPcnsQ4pWcMHHQYG96IWtKYDFFl7iRepMcgDj8eIVdKo0fBOBx5Y)OfVHfuXyfHNXFQSZy2CvOqAb9gp5JX54drAqQqJe9mkZ4Lc9gp5JX54dFmfm6sOuKqGLDKvIhtbJUN6bXx99jOI)alyggQkd2Rlc94QVFfkKwWuSBOFeI0GuHgjv8hybZWqvzWEDr4js5UVVLDKvIhtbJUeEcX3bsh6In0TRC5NW08xeJvOAAMryEms7zmBoIQqH0c6nEYhJZXhI0GuHgj6zuMXlfQh1SBBfBk2m4JPGrxcjwcbw2rwjEmfm6EkXs5QVpbv8hybZWqvzWEDrOhx99RqH0cMIDd9JqKgKk0iPI)alyggQkd2Rlcprk3VdKo0fBOBx5YpHP5VigRq10mJW8yK2Zy2CvOqAb9gp5JX54drAqQqJe9mkZ4Lc9gp5JX54dFmfm6siXsiWYoYkXJPGr3tjwkx99jOI)alyggQkd2Rlc94QVFfkKwWuSBOFeI0GuHgjv8hybZWqvzWEDr4js5(DG0HUydD7kx(BpgVyScYyl2qbsh6In0TRC5RhA3Lg(ZVcYGsXhiDOl2q3UYLFq1mKwIWw4VzJ(CG0HUydD7kx(6HAWe9mMnhzZAHBZyqQWGrLbB9((FCGNMRBU67xXFGfSyjuuJWWqcp0gG0HUydD7kx(FJkcDXgQqX26mAKWC4nrDRWZy2CeuHcPfmf7g6hHinivOrsf)bwWmmuvgSxxeEIuU77xXFGfmddvLb71fHECfiDOl2q3UYL)3OIqxSHkuSToJgjm3YOhkuuXFGfqAG0HUydDH4nrDRWCpsnNXS5Emfm6syot7JInuPYv4jaPdDXg6cXBI6wHDLlFdgg1fHoujG0HUydDH4nrDRWUYL)EEtP2EfRk8pJzZ9XbsOu8qczZAHjmn)fXyfQMMzeMhJ0cnJxQV)hhiHECfiDOl2qxiEtu3kSRC5)XTXb(NDgZMtpJYmEPq9OMDBRytXMbFmfm6sOh((euHcPf0B8KpgNJpePbPcns0ZOmJxk0B8KpgNJp8XuWOlHEChiDOl2qxiEtu3kSRC5Rh1SBBfBk2SZy2CeH7IunctyA(lIXkunnZimpgPfMcpnVVpbKnRfMW08xeJvOAAMryEmslS177RNrzgVuyctZFrmwHQPzgH5XiTWhtbJUNs817aPdDXg6cXBI6wHDLlFVXt(yCo(NXS5ic3fPAeMW08xeJvOAAMryEmslmfEAEFFciBwlmHP5VigRq10mJW8yKwyR33xpJYmEPWeMM)IyScvtZmcZJrAHpMcgDpL4R3bsh6In0fI3e1Tc7kx(P5Rqj26zNJNXS5mtbni2l8onQzHpMcgDjmNP9rXgQu5k8ejeS9OsjQ4pWAHEZyVYlJAYrSVprBpQuIk(dSwO3m2R8YOMtjwcrvOqAb1kmUfHinivO5oq6qxSHUq8MOUvyx5YxRW4w8mMnhbBpQuIk(dSwO3m2R8YOMt9qIzkObXEH3Prnl8XuWOlH5mTpk2qLkxHNC33NGThvkrf)bwl0Bg7vEzuZPNChiDOl2qxiEtu3kSRC5tQcdU18PZy2Cer2SwyctZFrmwHQPzgH5XiTWwVeYM1clClXyfj2rwbB9s(4aj8KRsiISzTqdgg1fHoujyRhiDOl2qxiEtu3kSRC5J3e1TcpJzZr2SwyctZFrmwHQPzgH5XiTWwVVpzZAHgmmQlcDOsWwVVVbjBwlupQz32k2uSzWwVVpzZAHfULySIe7iRGTEG0HUydDH4nrDRWUYL)QI0zmBoYM1c1FBZy0drSB0ufS1lHSzTWeMM)IyScvtZmcZJrAHMXlfiDOl2qxiEtu3kSRC5)i1CgZM7XuWOlH5mTpk2qLkxHNiPI)alyXsOOgHHHNkvbsh6In0fI3e1Tc7kx(ZT43pEXhiDOl2qxiEtu3kSRC5RhQbtuG0HUydDH4nrDRWUYLpEtu3keiDOl2qxiEtu3kSRC5FltxZFr8TndiDOl2qxiEtu3kSRC5Zs9i1WOhIBz6A(laPbsh6In0fUm6Hcfv8hyL7rQ5mMn3JPGrxcZzAFuSHkvUcpbiDOl2qx4YOhkuuXFGvx5Y3GHrDrOdvciDOl2qx4YOhkuuXFGvx5YFpVPuBVIvf(NXS5(4ajS7VkHSzTqdgg1fHoujOz8sLq2SwyctZFrmwHQPzgH5XiTqZ4L67)XbsOhxbsh6In0fUm6Hcfv8hy1vU8)424a)Zy2CeONrzgVuOEuZUTvSPyZGpMcgDj0dFFcQqH0c6nEYhJZXhI0GuHgj6zuMXlf6nEYhJZXh(yky0LqpUFhiDOl2qx4YOhkuuXFGvx5YpnFfkXwp7C8mMnNzkObXEH3Prnl8XuWOlH5mTpk2qLkxHNiHGThvkrf)bwl0Bg7vEzutoI99jQcfslOwHXTiePbPcn3bsh6In0fUm6Hcfv8hy1vU81kmUfpJzZT9OsjQ4pWAHEZyVYlJAo1djMPGge7fENg1SWhtbJUeMZ0(OydvQCfEcq6qxSHUWLrpuOOI)aRUYLVEuZUTvSPyZoJzZreUls1iupudsx0iumlANxJqKgKk0iHOkuiTGPy3q)iePbPcnsiOI)alyXsOOgrVUeEC9uIV67xXFGfSyjuuJWWWtLY17((4UivJq9qniDrJqXSODEncrAqQqJeIQqH0cMIDd9JqKgKk0iHGk(dSGflHIAe96s4X1tj(QVFf)bwWILqrncddpTBVE33Vcfslyk2n0pcrAqQqJecQ4pWcwSekQr0RlXjs5uIV67xXFGfSyjuuJWWWtLY17aPdDXg6cxg9qHIk(dS6kx(4nrDRWZy2CKnRfUnJbPcdgvg8XqxaPdDXg6cxg9qHIk(dS6kx(KQWGBnF6mMnNEgLz8sHP5Rqj26zNJWhtbJUsmizZAH6rn72wXMIndAgVujequfkKwqdgg1fHoujisdsfA89jBwl0GHrDrOdvcAgV07siGads2SwOEuZUTvSPyZGTEjefEgFwHWc3smwrIDKvqKgKk0C33NSzTWc3smwrIDKvWw)DjKnRfMW08xeJvOAAMryEmsl0mEPs(4ajSBUcKo0fBOlCz0dfkQ4pWQRC5NMVcLyRNDoEgZMB7rLsuXFG1c9MXELxg1KJyFFIQqH0cQvyClcrAqQqdq6qxSHUWLrpuOOI)aRUYLVwHXT4zmBUThvkrf)bwl0Bg7vEzuZPEaKo0fBOlCz0dfkQ4pWQRC57nJ9kVmQ5mMnhbeqazZAHjmn)fXyfQMMzeMhJ0cB9399jWGKnRfQh1SBBfBk2myR)UVpbKnRfAWWOUi0HkbB93VlPcfslOf)BNxmwbzuLcHinivO5UVpbeq2SwyctZFrmwHQPzgH5XiTWwVV)hh4PDRu7Ueds2SwOEuZUTvSPyZGTEjKnRfw4wIXksSJScAgVujevHcPf0I)TZlgRGmQsHqKgKk0ChiDOl2qx4YOhkuuXFGvx5YFvr6mMnhrvOqAbT4F78IXkiJQuiePbPcnsiGSzTWeMM)IyScvtZmcZJrAHTEFFds2SwOEuZUTvSPyZGT(7aPdDXg6cxg9qHIk(dS6kx(ZT43pEXhiDOl2qx4YOhkuuXFGvx5Y3Bg7vEzuZzmBUkuiTGw8VDEXyfKrvkeI0GuHgjeq2SwyHBjgRiXoYkyR333GKnRfQh1SBBfBk2mOz8sLq2SwyHBjgRiXoYkOz8sL8XbEA3F9oq6qxSHUWLrpuOOI)aRUYL)QI0zmBoIQqH0cAX)25fJvqgvPqisdsfAash6In0fUm6Hcfv8hy1vU8VLPR5Vi(2MbKo0fBOlCz0dfkQ4pWQRC5Zs9i1WOhIBz6A(lo5Th1UoKQe7kx5Ca]] )


end
