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
        },

        conquerors_banner = {
            aura = "conquerors_banner",

            last = function ()
                local app = state.buff.conquerors_banner.applied
                local t = state.query_time

                return app + ( floor( ( t - app ) / ( 1 * state.haste ) ) * ( 1 * state.haste ) )
            end,

            interval = 1,

            value = 4,
        },        
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
        shadow_of_the_colossus = 29, -- 198807
        sharpen_blade = 33, -- 198817
        storm_of_destruction = 31, -- 236308
        war_banner = 32, -- 236320
        warbringer = 5376, -- 356353
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
    local gloryRage = 0

    spec:RegisterStateExpr( "rage_spent", function ()
        return rageSpent
    end )

    spec:RegisterStateExpr( "glory_rage", function ()
        return gloryRage
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

            if legendary.glory.enabled and buff.conquerors_banner.up then
                glory_rage = glory_rage + amt
                local reduction = floor( glory_rage / 20 ) * 0.5
                glory_rage = glory_rage % 20

                buff.conquerors_banner.expires = buff.conquerors_banner.expires + reduction
            end
        end
    end )

    local last_cs_target = nil

    spec:RegisterEvent( "COMBAT_LOG_EVENT_UNFILTERED", function()
        local _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName = CombatLogGetCurrentEventInfo()

        if sourceGUID == state.GUID and subtype == "SPELL_CAST_SUCCESS" then
            if ( spellName == class.abilities.colossus_smash.name or spellName == class.abilities.warbreaker.name ) then
                last_cs_target = destGUID
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
                
                if state.legendary.glory.enabled and  FindUnitBuffByID( "player", 324143 ) then
                    gloryRage = ( gloryRage + lastRage - current ) % 20 -- Glory.
                end
            end

            lastRage = current
        end
    end )


    spec:RegisterHook( "TimeToReady", function( wait, action )
        local id = class.abilities[ action ].id
        if buff.bladestorm.up and ( id < -99 or id > 0 ) then
            wait = max( wait, buff.bladestorm.remains )
        end
        return wait
    end )


    local cs_actual

    spec:RegisterHook( "reset_precast", function ()
        rage_spent = nil

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

            usable = function () return target.distance > 10 and ( query_time - action.charge.lastCast > gcd.execute ) end,
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
                },
                -- Legendary
                exploiter = {
                    id = 335452,
                    duration = 30,
                    max_stack = 2,
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
            gcd = "off",

            startsCombat = false,
            texture = 236171,

            usable = function () return query_time - action.heroic_leap.lastCast > gcd.execute * 2 end,
            handler = function ()
                setDistance( 15 )
                if talent.bounding_stride.enabled then applyBuff( "bounding_stride" ) end
            end,
            
            copy = 52174
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
                return buff.battlelord.up and 15 or 30
            end,
            spendType = "rage",

            startsCombat = true,
            texture = 132355,

            handler = function ()
                applyDebuff( "target", "mortal_wounds" )
                applyDebuff( "target", "deep_wounds" )
                removeBuff( "overpower" )
                removeBuff( "exploiter" )
                removeBuff( "sharpen_blade" )

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
                },
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


        sharpen_blade = {
            id = 198817,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            startsCombat = false,
            pvptalent = "sharpen_blade",

            handler = function ()
                applyBuff( "sharpen_blade" )
            end,

            auras = {
                sharpen_blade = {
                    id = 198817,
                    duration = 3600,
                    max_stack = 1,
                }
            }
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
                if legendary.elysian_might.enabled then applyBuff( "elysian_might" ) end
            end,

            auras = {
                spear_of_bastion = {
                    id = 307871,
                    duration = function () return legendary.elysian_might.enabled and 8 or 4 end,
                    max_stack = 1
                },
                elysian_might = {
                    id = 311193,
                    duration = 8,
                    max_stack = 1,
                },
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
                applyBuff( "conquerors_banner" )
                if conduit.veterans_repute.enabled then
                    applyBuff( "veterans_repute" )
                    addStack( "glory", nil, 5 )
                end
            end,

            auras = {
                conquerors_banner = {
                    id = 324143,
                    duration = 20,
                    max_stack = 1
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

            rangeSpell = function () return class.abilities.execute and class.abilities.execute.id end,

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

                if legendary.sinful_surge.enabled then
                    if state.spec.protection and buff.last_stand.up then buff.last_stand.expires = buff.last_stand.expires + 3
                    elseif state.spec.arms and debuff.colossus_smash.up then debuff.colossus_smash.expires = debuff.colossus_smash.expires + 1.5
                    elseif state.spec.fury and buff.recklessness.up then buff.recklessness.expires = buff.recklessness.expires + 2 end
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


    --[[ spec:RegisterSetting( "heroic_charge", false, {
        name = "Use Heroic Charge Combo",
        desc = "If checked, the default priority will check |cFFFFD100settings.heroic_charge|r to determine whether to use Heroic Leap + Charge together.\n\n" ..
            "This is generally a DPS increase but the erratic movement can be disruptive to smooth gameplay.",
        type = "toggle",
        width = "full",
    } ) ]]


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


    spec:RegisterPack( "Arms", 20210701, [[dG0NXaqiPQIhjvOnHq9juIgLuuoLubRsfvPxPImlQi3IOuTlQ6xsvggrXXOclJOYZurLPjfvxtQkBJOK(gvuACurX5KQkToQOQ5ru19uH9jv0brj0cLk9qPQkxufvvFuQQkojkbTscAMOeyNsjdLOeTuvuvEQOMQu4QsvvPTQIQ4Rsvv1yPIk7vYFjYGf5WKwmkEmQMmLUm0Mr0Nj0OrWPv1QjkLxJqMnf3MkTBf)g0WjWXjkHLR0ZbMUW1vPTJs67OuJxkY5vrz(sP2psxoQgv2QbwTKtg5CiJZkJdVmoJm9BF9v54mbyLfOCIurSYJ6IvMfxxqLfONzGQTAuza8UCSYeIqaW571t8dcxgph62d8UxJgpC4Rsg9aVlVxLzUVjyHtXuzRgy1sozKZHmoRmo8Y4mY0V95OY6nia3kNF3RrJho93QKrLj8wloftLTiGxzwCDb0u)x39HlvOWR5mAYHt0KCYiNdQqQW(JGoIiW5PcLDAIfTw0stYYRRlA8uHYonXIwlAPPZZZd4EgnD(Uac9yHUcWX(JinDEEEa3Z8uHYonXIwlAPPUAegKMYeG3GMcinjyro0LrdAIfLLSapvOSttN)Mq(nE4Gllb0KSCr(dE4qtpGMSObd06PcLDAIfTw0st9VaKMyHb6c8uHYon1GnQert4e7z0ejCPPUg1IGaUU(kBEqaQgvg8JObLcDfXOAuTCunQmokJbTv3kZ3pW91kVOR(dGMK)GMe52kR84HtLxCSvuTKRAuzCugdARUvMVFG7RvM8fjesl6Q)aOPoPjhnxMkR84HtL5WrwCXfUajgDgCROADUQrLvE8WPYkRAOBLXrzmOT6wr1Q5vJkR84HtLxLvve3kJJYyqB1TIQvFvJkR84HtLzRlZIkr4wzCugdARUvuTK1QrLvE8WPYCObcaxGeWvbeQmokJbTv3kQwoB1OYkpE4uzD4poHKsg4cia5evzCugdARUvuTCMQrLvE8WPYabOUsqsjgfepCQmokJbTv3kQw9B1OY4Omg0wDRmF)a3xRmNGUIiGMoOj5QSYJhovgYkUcGSXTIQLdzQgvghLXG2QBL57h4(AL37GKWve94yV7pIsmgiBpokJbT0u7200EhKeUIONrJWGg4A94Omg0stTBttmxsspKvCfazJRhekNiAQZdAsUkR84HtLDHBOgjqSpryfvlhoQgvghLXG2QBL57h4(ALzUKKEW1AXrYIAqWVOYJkR84HtL5WXIUtfvlhYvnQmokJbTv3kZ3pW91kZCjj9GR1IJKf1GGFrLhvw5XdNkJnH8BGvuTCCUQrLXrzmOT6wz((bUVw5vfrVfjF(h0uN0uZ7JMiMMyUKKElQwZzsC146Tq2tLvE8WPYaIUgdqG5Ja3kQwoAE1OY4Omg0wDRmF)a3xRmZLK0Br1AotIRgxVfYEOjIPPvfrAsEA6CYuzLhpCQmJrTiiGRBfvlh9vnQSYJhov2IQ1CMexnUvghLXG2QBfvlhYA1OYkpE4uziR4kaYg3kJJYyqB1TIQLdNTAuzLhpCQSlCd1ibI9jcRmokJbTv3kQwoCMQrLXrzmOT6wz((bUVw5fD1Fa0K80K9UA8WHMoV0Km(ZvzLhpCQ8IJTIQLJ(TAuzCugdARUvMVFG7RvgiangPqxrmaE2e(1W(hln1jn5OYkpE4uzUbvwXkQwYjt1OY4Omg0wDRmF)a3xRCOgCcpjUScxjiPeJgHb94Omg0stTBttabOXif6kIbWZMWVg2)yPPoPPMttTBttabOXif6kIbWZMWVg2)yPPoPj5OjIPjMljPhWgrb)ikbI9jcbElK9uzLhpCQmBc)Ay)JTIQLCoQgvghLXG2QBL57h4(AL7hAkudoHNexwHReKuIrJWGECugdAPjIPPMrtRkI0uN0uFYqtTBttwK5ss65qdeaUajGRci4VcOP2TPP(HM27GKWve94yV7pIsmgiBpokJbT0uhQSYJhovgyu3kQOYwKuVMOAuTCunQSYJhovMtqxrSY4Omg0wDROAjx1OYkpE4uzbxxx0uzCugdARUvuTox1OY4Omg0wDRmF)a3xRSi36x0v)bqth0Km0eX0KfzUKKEo0abGlqc4Qac(fD1Fa0uN0KZqtTBttmqaGMiMMiFrcH0IU6paAsEAsU(QSYJhovwamE4ur1Q5vJkJJYyqB1TY89dCFTYwK5ss65qdeaUajGRci4VcQSYJhovMXaHwjY7EwfvR(QgvghLXG2QBL57h4(ALTiZLK0ZHgiaCbsaxfqWVOR(dGM6KMK1kR84HtLzWfGlr)iwr1swRgvghLXG2QBL57h4(AL5qOXczpEx4gQrce7te6x0v)bqtDsto89rtettRkI0K80uFYuzLhpCQSUCDqPaUlorfvlNTAuzCugdARUvMVFG7Rv2ImxssphAGaWfibCvabVfYEOjIPjoeASq2J3fUHAKaX(eH(fD1Favw5XdNkBErcbqs2UwrxCIkQwot1OY4Omg0wDRmF)a3xRSfzUKKEo0abGlqc4Qac(RGkR84HtLj)fzmqOTIQv)wnQmokJbTv3kZ3pW91kBrMljPNdnqa4cKaUkGG)kOYkpE4uzD4iiw1iXvJPIQLdzQgvghLXG2QBL57h4(ALTiZLK0ZHgiaCbsaxfqWBHShAIyAIdHglK94DHBOgjqSprOFrx9hqLvE8WPYmQOeKuk2NteOIQLdhvJkR84HtLVau6d0fuzCugdARUvuTCix1OY4Omg0wDRmF)a3xRmqaAmsHUIya8Sj8RH9pwAQtAYbnrmn1mAIdHglK94zmQfbbCD9l6Q)aOPoPjh9rtTBttHAWj8RYQkIRhhLXGwAQdvw5XdNkdyJOGFeLaX(eHGkQwoox1OY4Omg0wDRmF)a3xRCZOPqn4eExfau(IECugdAPjIPPqxrm8eq1ee8c4bnjpnDU(OPoqtTBttHUIy4jGQji4fWdAsEAsozOP2TPPMrtHUIy4jGQji4fWdAQtAYzKHMiMM4qwXrNWZkobHZwAQdvge7ZJQLJkR84HtL5QXiP84HJK5brLnpiKg1fRm2eYVbwr1YrZRgvghLXG2QBL57h4(ALbcqJrk0vedGNnHFnS)XstDstoQmi2Nhvlhvw5XdNkZvJrs5XdhjZdIkBEqinQlwzckVIQLJ(QgvghLXG2QBLvE8WPYC1yKuE8WrY8GOYMhesJ6Ivg8JObLcDfXOIQLdzTAuzLhpCQmRppG7zs7fqOY4Omg0wDROA5WzRgvw5XdNk)UcWX(JOeRppG7zvghLXG2QBfvuzblYHUmAunQwoQgvw5XdNkZOryqjab4nQmokJbTv3kQOYyti)gy1OA5OAuzLhpCQSfvR5mjUACRmokJbTv3kQwYvnQSYJhovMdhzXfx4cKy0zWTY4Omg0wDROADUQrLXrzmOT6wz((bUVwzGa0yKcDfXa4zt4xd7FS00bn5GMiMMe5w)IU6paA6GMKHMiMMAgnTQistDstoBF0u7200QIin1jn1Nm0eX0eZLK0ViNidcadca(RaAQdvw5XdNkZ1HJgjMljzLzUKKsJ6IvMXOweeW1TIQvZRgvghLXG2QBL57h4(ALf5w)IU6paA6GMKHMA3MMcDfXWhVlkfqj7J0K80KCYuzLhpCQSYQg6wr1QVQrLXrzmOT6wz((bUVwzMljPxbeWrs2UII4o6n8xb0eX0eZLK0Rac4ijBxrrCh9g(fD1Fa0K80Ki3stettC4yVF4vabCKKTROiUJEd)Qdr0uN0KJkR84HtL5WXIUtfvlzTAuzCugdARUvMVFG7RvM5ss6vabCKKTROiUJEd)vanrmnXCjj9kGaosY2vue3rVHFrx9hanjpnjYT0eX0eho27hEfqahjz7kkI7O3WV6qen1jn5OYkpE4uzSjKFdSIQLZwnQSYJhovEvwvrCRmokJbTv3kQwot1OY4Omg0wDRmF)a3xR8IU6paAs(dAsKBPjIPPMrt9dnfQbNWZwxMfvIW1JJYyqlnrmnXHqJfYE8CObcaxGeWvbe8l6Q)aOj5PPMttTBttHAWj8S1LzrLiC94Omg0stettCi0yHShpBDzwujcx)IU6paAsEAQ50uhOjIPPqxrm8X7IsbuY(in1jn5qUkR84HtLxCSvuT63QrLvE8WPYS1LzrLiCRmokJbTv3kQwoKPAuzLhpCQmhAGaWfibCvaHkJJYyqB1TIQLdhvJkR84HtL1H)4eskzGlGaKtuLXrzmOT6wr1YHCvJkR84HtLbcqDLGKsmkiE4uzCugdARUvuTCCUQrLXrzmOT6wz((bUVw59oijCfrp4fhmKGKsbCDXjqRer)ic84Omg0stettnJMwve9wK85FqtYttY1hn1UnnzrMljPNdnqa4cKaUkGG)kGMiMMwvePPoPPMldn1UnnXCjj9GR1IJKf1GGFrLh0u720eZLK0Br1AotIRgx)van1HkR84HtL5WXIUtfvlhnVAuzCugdARUvMVFG7RvMtqxreqth0KCvw5XdNkdzfxbq24wr1YrFvJkJJYyqB1TY89dCFTYabOXif6kIbWZMWVg2)yPPoPjh0eX0KfgElIcKydVJf4x0v)bqtYttICBLvE8WPYCdQSIvuTCiRvJkJJYyqB1TY89dCFTYwy4TikqIn8owGFrx9hanj)bnjYT0u7200EhKeUIOhh7D)ruIXaz7XrzmOLMA3MMyUKKEiR4kaYgxpiuor00bnjhnrmnzrMljPhBsGb(bUEqOCIOPdAsoAQDBAI5ss6z0imObUw)vqLvE8WPYUWnuJei2NiSIQLdNTAuzCugdARUvMVFG7RvEvr0BrYN)bnjpnjxF0u720eZLK0Br1AotIRgx)vqLvE8WPYC4yr3PIQLdNPAuzCugdARUvMVFG7RvEvrKMKNMAEFvw5XdNkdi6AmabMpcCROA5OFRgvghLXG2QBL57h4(ALzUKKElQwZzsC146Tq2dnrmn1mAAvrKMKNMKtgAQDBAQFOP9oijCfrp4hYRrcCxr0JJYyqlnrmnTQistYtt9jdn1HkR84HtLzmQfbbCDROAjNmvJkR84HtLHSIRaiBCRmokJbTv3kQwY5OAuzLhpCQmhow0DQmokJbTv3kQwYjx1OYkpE4uzSjKFdSY4Omg0wDROIktq5vJQLJQrLXrzmOT6wz((bUVw5vfrAsEAswLHMiMMyUKKElQwZzsC146Tq2tLvE8WPYaIUgdqG5Ja3kQwYvnQSYJhovMdhzXfx4cKy0zWTY4Omg0wDROADUQrLXrzmOT6wz((bUVwzoeASq2JNdnqa4cKaUkGGFrx9hanjpn5OYkpE4uzLvn0TIQvZRgvw5XdNkZwxMfvIWTY4Omg0wDROA1x1OYkpE4uzo0abGlqc4QacvghLXG2QBfvlzTAuzCugdARUvMVFG7Rv2cdVfrbsSH3Xc8l6Q)aOj5pOjrUTYkpE4uzUbvwXkQwoB1OYkpE4uzD4poHKsg4cia5evzCugdARUvuTCMQrLvE8WPYabOUsqsjgfepCQmokJbTv3kQw9B1OYkpE4uzgJArqax3kJJYyqB1TIQLdzQgvw5XdNkVkRQiUvghLXG2QBfvlhoQgvghLXG2QBL57h4(ALx0v)bqtYFqt27QXdhA68stY4phnrmnXCjj9a2ik4hrjqSpriWFfuzLhpCQ8IJTIQLd5Qgvw5XdNkZnOYkwzCugdARUvuTCCUQrLXrzmOT6wz((bUVwzMljPhWgrb)ikbI9jcb(RaAQDBAYcdVfrbsSH3Xc8l6Q)aOj5PjrULMiMM6hAkudoHNBqLv0JJYyqBLvE8WPYUWnuJei2NiSIQLJMxnQmokJbTv3kZ3pW91khQbNWBxuTJEfjeECugdARSYJhovgYkUcGSXTIQLJ(Qgvw5XdNkZHJfDNkJJYyqB1TIQLdzTAuzCugdARUvMVFG7RvM5ss6bSruWpIsGyFIqG)kOYkpE4uzSjKFdSIQLdNTAuzLhpCQmKvCfazJBLXrzmOT6wr1YHZunQSYJhovMnHFnS)XwzCugdARUvurfvMvCbpCQwYjJCoKrwLRFRmBDNFebvU)ZINVwSWw9popnrtniG007kaUbnrcxAILGFenOuORigSKMwuwC)fT0ea6I0KEdORgOLM4e0rebEQqwWpin5qgNNM6p4WkUbAPjwU3bjHRi6DowstbKMy5EhKeUIO3584Omg0YsAQzoAQdEQqwWpin5qgNNM6p4WkUbAPjwU3bjHRi6DowstbKMy5EhKeUIO3584Omg0YsAQzoAQdEQqwWpinjNdNNM6p4WkUbAPjwU3bjHRi6DowstbKMy5EhKeUIO3584Omg0YsAQzoAQdEQqQW(plE(AXcB1)480en1GastVRa4g0ejCPjwInH8BGSKMwuwC)fT0ea6I0KEdORgOLM4e0rebEQqwWpin54Copn1FWHvCd0stSCVdscxr07CSKMcinXY9oijCfrVZ5XrzmOLL0uZC0uh8uHSGFqAYHS680u)bhwXnqlnXY9oijCfrVZXsAkG0el37GKWve9oNhhLXGwwstnZrtDWtfYc(bPjh9RZtt9hCyf3aT0el37GKWve9ohlPPastSCVdscxr07CECugdAzjn1mhn1bpvivil0vaCd0st9rtkpE4qtMheapvyLbcqE1YzDuzblK8nyL7yhPjwCDb0u)x39Hlvyh7inj8AoJMC4enjNmY5GkKkSJDKM6pc6iIaNNkSJDKMKDAIfTw0stYYRRlA8uHDSJ0KSttSO1IwA6888aUNrtNVlGqpwORaCS)istNNNhW9mpvyh7inj70elATOLM6QryqAktaEdAkG0KGf5qxgnOjwuwYc8uHDSJ0KSttN)Mq(nE4Gllb0KSCr(dE4qtpGMSObd06Pc7yhPjzNMyrRfT0u)laPjwyGUapvyh7inj70ud2OsenHtSNrtKWLM6Aulcc466PcPc7yhPPZFti)gOLMyqs4I0eh6YObnXGI)a80elY5OGaqtdCKDc66sEn0KYJhoaAcoMZ8uHkpE4a8cwKdDz040rpgncdkbiaVbvivyh7inD(Bc53aT0eYkUNrtX7I0uqaPjLhWLMEanPSQVrzmONku5XdhWbNGUIivOYJhoGth9eCDDrdvOYJhoGth9eaJhoo9KhICRFrx9hWHmeBrMljPNdnqa4cKaUkGGFrx9hqNot72mqaGyYxKqiTOR(dqE56Jku5XdhWPJEmgi0krE3ZC6jpSiZLK0ZHgiaCbsaxfqWFfqfQ84Hd40rpgCb4s0pIo9KhwK5ss65qdeaUajGRci4x0v)b0PSsfQ84Hd40rpD56GsbCxCcNEYdoeASq2J3fUHAKaX(eH(fD1FaD6W3hXRkIY3NmuHkpE4aoD0Z8IecGKSDTIU4eo9KhwK5ss65qdeaUajGRci4Tq2dXCi0yHShVlCd1ibI9jc9l6Q)aOcvE8WbC6Oh5ViJbcTo9KhwK5ss65qdeaUajGRci4VcOcvE8WbC6ONoCeeRAK4QX40tEyrMljPNdnqa4cKaUkGG)kGku5XdhWPJEmQOeKuk2NteWPN8WImxssphAGaWfibCvabVfYEiMdHglK94DHBOgjqSprOFrx9havOYJhoGth9Uau6d0fqfQ84Hd40rpaBef8JOei2Nie40tEaeGgJuORigapBc)Ay)JTthe3moeASq2JNXOweeW11VOR(dOth91UDOgCc)QSQI46XrzmOTduHkpE4aoD0JRgJKYJhosMheonQlEGnH8BGobI95XHdNEYJMfQbNW7QaGYx0JJYyqlXHUIy4jGQji4fWd5pxFDOD7qxrm8eq1ee8c4H8Yjt72nl0vedpbunbbVaE0PZidXCiR4Ot4zfNGWzBhOcvE8WbC6OhxngjLhpCKmpiCAux8GGYDce7ZJdho9KhabOXif6kIbWZMWVg2)y70bvOYJhoGth94QXiP84HJK5bHtJ6IhGFenOuORiguHkpE4aoD0J1NhW9mP9ciqfQ84Hd40rV3vao2FeLy95bCpJkKku5XdhGhBc53apSOAnNjXvJlvOYJhoap2eYVbE6OhhoYIlUWfiXOZGlvOYJhoap2eYVbE6OhxhoAKyUKKonQlEWyulcc4660tEaeGgJuORigapBc)Ay)J9WbXICRFrx9hWHme3SvfXoD2(A3EvrSZ(KHyMljPFrorgeagea8xbDGku5XdhGhBc53apD0tzvdDD6jpe5w)IU6pGdzA3o0vedF8UOuaLSpkVCYqfQ84HdWJnH8BGNo6XHJfDhNEYdMljPxbeWrs2UII4o6n8xbeZCjj9kGaosY2vue3rVHFrx9hG8IClXC4yVF4vabCKKTROiUJEd)QdrD6Gku5XdhGhBc53apD0dBc53aD6jpyUKKEfqahjz7kkI7O3WFfqmZLK0Rac4ijBxrrCh9g(fD1FaYlYTeZHJ9(HxbeWrs2UII4o6n8Roe1PdQqLhpCaESjKFd80rVvzvfXLku5XdhGhBc53apD0BXX60tESOR(dq(drUL4M1pHAWj8S1LzrLiC94Omg0smhcnwi7XZHgiaCbsaxfqWVOR(dq(M3UDOgCcpBDzwujcxpokJbTeZHqJfYE8S1LzrLiC9l6Q)aKV5DG4qxrm8X7IsbuY(yNoKJku5XdhGhBc53apD0JTUmlQeHlvOYJhoap2eYVbE6OhhAGaWfibCvabQqLhpCaESjKFd80rpD4poHKsg4cia5erfQ84HdWJnH8BGNo6beG6kbjLyuq8WHku5XdhGhBc53apD0Jdhl6oo9Kh7Dqs4kIEWloyibjLc46ItGwjI(reqCZwve9wK85FiVC91UTfzUKKEo0abGlqc4Qac(RaIxve7S5Y0UnZLK0dUwloswudc(fvE0UnZLK0Br1AotIRgx)vqhOcvE8Wb4XMq(nWth9GSIRaiBCD6jp4e0vebhYrfQ84HdWJnH8BGNo6XnOYk60tEaeGgJuORigapBc)Ay)JTtheBHH3IOaj2W7yb(fD1FaYlYTuHkpE4a8yti)g4PJEUWnuJei2Ni0PN8WcdVfrbsSH3Xc8l6Q)aK)qKBB3EVdscxr0JJ9U)ikXyGSB3M5ss6HSIRaiBC9Gq5eDihXwK5ss6XMeyGFGRhekNOd5A3M5ss6z0imObUw)vavOYJhoap2eYVbE6Ohhow0DC6jpwve9wK85FiVC91UnZLK0Br1AotIRgx)vavOYJhoap2eYVbE6OhGORXaey(iW1PN8yvru(M3hvOYJhoap2eYVbE6OhJrTiiGRRtp5bZLK0Br1AotIRgxVfYEiUzRkIYlNmTB3p7Dqs4kIEWpKxJe4UIiXRkIY3NmDGku5XdhGhBc53apD0dYkUcGSXLku5XdhGhBc53apD0Jdhl6ouHkpE4a8yti)g4PJEyti)givivOYJhoapbLFai6AmabMpcCD6jpwveLxwLHyMljP3IQ1CMexnUElK9qfQ84HdWtq5No6XHJS4IlCbsm6m4sfQ84HdWtq5No6PSQHUo9KhCi0yHShphAGaWfibCvab)IU6pa5DqfQ84HdWtq5No6XwxMfvIWLku5XdhGNGYpD0Jdnqa4cKaUkGavOYJhoapbLF6Oh3GkROtp5HfgElIcKydVJf4x0v)bi)Hi3sfQ84HdWtq5No6Pd)XjKuYaxabiNiQqLhpCaEck)0rpGauxjiPeJcIhouHkpE4a8eu(PJEmg1IGaUUuHkpE4a8eu(PJERYQkIlvOYJhoapbLF6O3IJ1PN8yrx9hG8h27QXdNZRm(ZrmZLK0dyJOGFeLaX(eHa)vavOYJhoapbLF6Oh3GkRivOYJhoapbLF6ONlCd1ibI9jcD6jpyUKKEaBef8JOei2Nie4VcA32cdVfrbsSH3Xc8l6Q)aKxKBjUFc1Gt45guzf94Omg0sfQ84HdWtq5No6bzfxbq2460tEeQbNWBxuTJEfjeECugdAPcvE8Wb4jO8th94WXIUdvOYJhoapbLF6Oh2eYVb60tEWCjj9a2ik4hrjqSpriWFfqfQ84HdWtq5No6bzfxbq24sfQ84HdWtq5No6XMWVg2)yPcPcvE8Wb4b)iAqPqxrmowCSo9Khl6Q)aK)qKBPcvE8Wb4b)iAqPqxrmoD0JdhzXfx4cKy0zW1PN8G8fjesl6Q)a60rZLHku5XdhGh8JObLcDfX40rpLvn0Lku5XdhGh8JObLcDfX40rVvzvfXLku5XdhGh8JObLcDfX40rp26YSOseUuHkpE4a8GFenOuORigNo6XHgiaCbsaxfqGku5XdhGh8JObLcDfX40rpD4poHKsg4cia5erfQ84HdWd(r0GsHUIyC6OhqaQReKuIrbXdhQqLhpCaEWpIguk0veJth9GSIRaiBCD6jp4e0vebhYrfQ84HdWd(r0GsHUIyC6ONlCd1ibI9jcD6jp27GKWve94yV7pIsmgi72T37GKWve9mAeg0axB72mxsspKvCfazJRhekNOopKJku5XdhGh8JObLcDfX40rpoCSO740tEWCjj9GR1IJKf1GGFrLhuHkpE4a8GFenOuORigNo6HnH8BGo9Khmxssp4AT4izrni4xu5bvOYJhoap4hrdkf6kIXPJEaIUgdqG5JaxNEYJvfrVfjF(hD28(iM5ss6TOAnNjXvJR3czpuHkpE4a8GFenOuORigNo6Xyulcc4660tEWCjj9wuTMZK4QX1BHShIxveL)CYqfQ84HdWd(r0GsHUIyC6ONfvR5mjUACPcvE8Wb4b)iAqPqxrmoD0dYkUcGSXLku5XdhGh8JObLcDfX40rpx4gQrce7tesfQ84HdWd(r0GsHUIyC6O3IJ1PN8yrx9hG827QXdNZRm(ZrfQ84HdWd(r0GsHUIyC6Oh3GkROtp5bqaAmsHUIya8Sj8RH9p2oDqfQ84HdWd(r0GsHUIyC6OhBc)Ay)J1PN8iudoHNexwHReKuIrJWGECugdAB3giangPqxrmaE2e(1W(hBNnVDBGa0yKcDfXa4zt4xd7FSDkhXmxsspGnIc(ruce7tec8wi7Hku5XdhGh8JObLcDfX40rpGrDD6jp6Nqn4eEsCzfUsqsjgncd6XrzmOL4MTQi2zFY0UTfzUKKEo0abGlqc4Qac(RG2T7N9oijCfrpo27(JOeJbYUdvurv]] )


end
