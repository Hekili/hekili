-- WarriorArms.lua
-- June 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State

local FindUnitBuffByID = ns.FindUnitBuffByID

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
                
                if state.legendary.glory.enabled and FindUnitBuffByID( "player", 324143 ) then
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
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
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
                    elseif state.spec.fury and buff.recklessness.up then buff.recklessness.expires = buff.recklessness.expires + 1.5 end
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


    spec:RegisterPack( "Arms", 20210719, [[dOKTXaqivu4revztiuFcf0Oef1PKk0QqbKxPImlQGBruWUe5xsLggrPJrfTmIkptQOMMubxtQQ2grr9nIQY4efPZjkI1jveZJk09uH9jvL)ruOQdQIsluQYdvrrxKOq5JsfPmsIcvojkqTscmtIczNIQgQurYsrbupvktvu6QsfPAROa4ROa0yjQQ2RK)sKbtvhM0IrPhJQjtPld2mI(mHgncoTQwnrrEncz2uCBQ0Uv8BOgobDCuGSCLEoKPlCDvA7OqFhfnErHZRIQ5lQSFKUCwzRMvdOYlNSY5uw5ZzMKC25(7SS9xT4CHq1eQCIurOAJ6cv7SRlQAc1Zny1wzRgcFxouncrie1jD7k(bHlBIJD7IE3RrJhp8vjJUO3L3TAS33em4PyRMvdOYlNSY5uw5ZzMKC25(7SSYvn9geWB1AV71OXJNZCvYOAeERfMITAwaXR2zxxe1ZaQ7(4LkqW1Co17mtCG6Ltw5CsfqfCMe0reqDcvGmq9N1Abl13PUUUGjrfidu)zTwWs9mappW75upd8frOld2vim2FePEgGNh498evGmq9N1Abl13tJWauFJa(guFGPEHlWXUSAq9NTtjJsubYa1lJLbWVXJhyziI67ulWF0JhQ)ruVfmqa2evGmq9N1Abl13PJaQNbhGlkrfiduFwMGse1dtSNt9K4L67zulGc86MQM5rbQYwn0pIgqk0veIkBL3zLTAWOSgWw9QgF)a2xR2cU6piQ3XdQxKBRMYJhpvBHXwrLxUkB1GrznGT6vn((bSVwnYxKqiTGR(dI67J6D2bzRMYJhpvJJhg0fw8IKy1zGTIkFNRSvt5XJNQPmQHUvdgL1a2Qxfv(ouzRMYJhpvBvgvryRgmkRbSvVkQ89xzRMYJhpvJPUSlOebB1GrznGT6vrLxMRSvt5XJNQXXgmcDrsixfrOAWOSgWw9QOYlFv2QP84Xt10H)WeskzalIaMtu1GrznGT6vrLptRSvt5XJNQHec6kHjLyvu84PAWOSgWw9QOYNjv2QbJYAaB1RA89dyFTACc6kciQ)G6LRAkpE8unmJWkeZe2kQ8oLTYwnyuwdyREvJVFa7RvBVdqIxribJ9U)ikXAWmtWOSgWs95Yr97Das8kcjwncdyWRnbJYAal1Nlh1ZEjjtygHviMjSjuOCIO((oOE5QMYJhpvZfVHAKqX(ebvu5D6SYwnyuwdyREvJVFa7RvJ9ssMqxRfgjlObH0ckpQMYJhpvJJhl4ovu5DkxLTAWOSgWw9QgF)a2xRg7LKmHUwlmswqdcPfuEunLhpEQgKbWVburL3zNRSvdgL1a2Qx147hW(A1wveswG85Fq99r9DOFQNyQN9ssMSGAnNlXvJBYIzovt5XJNQHi6AmiHMpcyROY7Sdv2QbJYAaB1RA89dyFTASxsYKfuR5CjUACtwmZH6jM6xveOEhP(olB1uE84PASg1cOaVUvu5D2FLTAkpE8unlOwZ5sC14wnyuwdyREvu5DkZv2QP84Xt1WmcRqmtyRgmkRbSvVkQ8oLVkB1uE84PAU4nuJek2NiOAWOSgWw9QOY7mtRSvdgL1a2Qx147hW(A1wWv)br9os927QXJhQNbI6Ln15QP84Xt1wySvu5DMjv2QbJYAaB1RA89dyFTAiHGXif6kcbkXKWVgM)yP((OENvt5XJNQXnGYiurLxozRSvdgL1a2Qx147hW(A1c1atKiHLr8kHjLy1imqcgL1awQpxoQhjemgPqxriqjMe(1W8hl13h13bQpxoQhjemgPqxriqjMe(1W8hl13h1lh1tm1ZEjjtiMai8hrjuSprakzXmNQP84Xt1ys4xdZFSvu5LZzLTAWOSgWw9QgF)a2xR2zq9HAGjsKWYiELWKsSAegibJYAal1tm1NzQFvrG67J67xwQpxoQ3cSxsYehBWi0fjHCveH0vi1Nlh1Fgu)EhGeVIqcg7D)ruI1GzMGrznGL67y1uE84PAiJ6wrfvZcK61ev2kVZkB1uE84PACc6kcvdgL1a2QxfvE5QSvt5XJNQj866cMQbJYAaB1RIkFNRSvdgL1a2Qx147hW(A1e520cU6piQ)G6LL6jM6Ta7LKmXXgmcDrsixfriTGR(dI67J6ZuQpxoQNfJqupXup5lsiKwWv)br9os9Y1F1uE84PAcXXJNkQ8DOYwnyuwdyREvJVFa7RvZcSxsYehBWi0fjHCveH0vy1uE84PASgm2krE3ZROY3FLTAWOSgWw9QgF)a2xRMfyVKKjo2GrOlsc5QicPfC1FquFFuVmxnLhpEQglSiyj6hXkQ8YCLTAWOSgWw9QgF)a2xRghJnwmZj5I3qnsOyFIG0cU6piQVpQ3zQFQNyQFvrG6DK67x2QP84Xt10LRdif4DHjQOYlFv2QbJYAaB1RA89dyFTAwG9ssM4ydgHUijKRIiKSyMd1tm1ZXyJfZCsU4nuJek2NiiTGR(dQAkpE8unZlsiqsY01k6cturLptRSvdgL1a2Qx147hW(A1Sa7LKmXXgmcDrsixfriDfwnLhpEQg5VaRbJTvu5ZKkB1GrznGT6vn((bSVwnlWEjjtCSbJqxKeYvresxHvt5XJNQPdhqXQgjUAmvu5DkBLTAWOSgWw9QgF)a2xRMfyVKKjo2GrOlsc5QicjlM5q9et9Cm2yXmNKlEd1iHI9jcsl4Q)GQMYJhpvJvfLWKsX(CIqvu5D6SYwnLhpEQ2fbsFaUOQbJYAaB1RIkVt5QSvdgL1a2Qx147hW(A1qcbJrk0vecuIjHFnm)Xs99r9oPEIP(mt9Cm2yXmNeRrTakWRBAbx9he13h17SFQpxoQpudmrAvgvrytWOSgWs9DSAkpE8unetae(JOek2NiavrL3zNRSvdgL1a2Qx147hW(A1Ym1hQbMi5QiKYxibJYAal1tm1h6kcrIaOMGqsipOEhP(o3p13rQpxoQp0veIebqnbHKqEq9os9Yjl1Nlh1NzQp0veIebqnbHKqEq99r9zQSupXuphZim6ejgHjiC(s9DSAOyFEu5DwnLhpEQgxngjLhpEKmpkQM5rH0OUq1Gma(nGkQ8o7qLTAWOSgWw9QMYJhpvJRgJKYJhpsMhfvZ8OqAuxOAOFenGuORievu5D2FLTAkpE8ungFEG3ZL2lIq1GrznGT6vrL3PmxzRMYJhpv7DfcJ9hrjgFEG3ZRgmkRbSvVkQOAcxGJDz1OYw5DwzRMYJhpvJvJWasic4BunyuwdyREvur1Gma(nGkBL3zLTAkpE8unlOwZ5sC14wnyuwdyREvu5LRYwnLhpEQghpmOlS4fjXQZaB1GrznGT6vrLVZv2QbJYAaB1RA89dyFTAiHGXif6kcbkXKWVgM)yP(dQ3j1tm1lYTPfC1Fqu)b1ll1tm1NzQFvrG67J6LV(P(C5O(vfbQVpQVFzPEIPE2ljzAborgaHgaHsxHuFhRMYJhpvJRdhmsSxsYQXEjjLg1fQgRrTakWRBfv(ouzRgmkRbSvVQX3pG91QjYTPfC1Fqu)b1ll1Nlh1h6kcrkExqkWs2hOEhPE5KTAkpE8unLrn0TIkF)v2QbJYAaB1RA89dyFTASxsYKIiaJKmDffHD0BKUcPEIPE2ljzsreGrsMUIIWo6nsl4Q)GOEhPErUL6jM654XE)iPicWijtxrryh9gPvhIO((OENvt5XJNQXXJfCNkQ8YCLTAWOSgWw9QgF)a2xRg7LKmPicWijtxrryh9gPRqQNyQN9ssMuebyKKPROiSJEJ0cU6piQ3rQxKBPEIPEoES3pskIamsY0vue2rVrA1HiQVpQ3z1uE84PAqga)gqfvE5RYwnLhpEQ2QmQIWwnyuwdyREvu5Z0kB1GrznGT6vn((bSVwTfC1FquVJhuVi3s9et9zM6pdQpudmrIPUSlOebBcgL1awQNyQNJXglM5K4ydgHUijKRIiKwWv)br9os9DG6ZLJ6d1atKyQl7ckrWMGrznGL6jM65ySXIzojM6YUGseSPfC1FquVJuFhO(os9et9HUIqKI3fKcSK9bQVpQ3PCvt5XJNQTWyROYNjv2QP84Xt1yQl7ckrWwnyuwdyREvu5DkBLTAkpE8uno2GrOlsc5QicvdgL1a2QxfvENoRSvt5XJNQPd)HjKuYawebmNOQbJYAaB1RIkVt5QSvt5XJNQHec6kHjLyvu84PAWOSgWw9QOY7SZv2QbJYAaB1RA89dyFTA7Das8kcj0loqiHjLc86ctawjI(reLGrznGL6jM6Zm1VQiKSa5Z)G6DK6LRFQpxoQ3cSxsYehBWi0fjHCveH0vi1tm1VQiq99r9DqwQpxoQN9ssMqxRfgjlObH0ckpO(C5OE2ljzYcQ1CUexnUPRqQVJvt5XJNQXXJfCNkQ8o7qLTAWOSgWw9QgF)a2xRgNGUIaI6pOE5QMYJhpvdZiScXmHTIkVZ(RSvdgL1a2Qx147hW(A1qcbJrk0vecuIjHFnm)Xs99r9oPEIPEloswaekXeFhlkTGR(dI6DK6f52QP84Xt14gqzeQOY7uMRSvdgL1a2Qx147hW(A1S4izbqOet8DSO0cU6piQ3XdQxKBP(C5O(9oajEfHem27(JOeRbZmbJYAal1Nlh1ZEjjtygHviMjSjuOCIO(dQxoQNyQ3cSxsYeKHqd(dytOq5er9huVCuFUCup7LKmXQryadETPRWQP84Xt1CXBOgjuSprqfvENYxLTAWOSgWw9QgF)a2xR2QIqYcKp)dQ3rQxU(P(C5OE2ljzYcQ1CUexnUPRWQP84Xt144XcUtfvENzALTAWOSgWw9QgF)a2xR2QIa17i13H(RMYJhpvdr01yqcnFeWwrL3zMuzRgmkRbSvVQX3pG91QXEjjtwqTMZL4QXnzXmhQNyQpZu)QIa17i1lNSuFUCu)zq97Das8kcj0pKxJe6UIqcgL1awQNyQFvrG6DK67xwQVJvt5XJNQXAulGc86wrLxozRSvt5XJNQHzewHyMWwnyuwdyREvu5LZzLTAkpE8unoESG7unyuwdyREvu5LtUkB1uE84PAqga)gq1GrznGT6vrfvJGYRSvENv2QbJYAaB1RA89dyFTARkcuVJuVmll1tm1ZEjjtwqTMZL4QXnzXmNQP84Xt1qeDngKqZhbSvu5LRYwnLhpEQghpmOlS4fjXQZaB1GrznGT6vrLVZv2QbJYAaB1RA89dyFTACm2yXmNehBWi0fjHCveH0cU6piQ3rQ3z1uE84PAkJAOBfv(ouzRMYJhpvJPUSlOebB1GrznGT6vrLV)kB1uE84PACSbJqxKeYvreQgmkRbSvVkQ8YCLTAWOSgWw9QgF)a2xRMfhjlacLyIVJfLwWv)br9oEq9ICB1uE84PACdOmcvu5LVkB1uE84PA6WFycjLmGfraZjQAWOSgWw9QOYNPv2QP84Xt1qcbDLWKsSkkE8unyuwdyREvu5ZKkB1uE84PASg1cOaVUvdgL1a2QxfvENYwzRMYJhpvBvgvryRgmkRbSvVkQ8oDwzRgmkRbSvVQX3pG91QTGR(dI6D8G6T3vJhpupde1lBQZupXup7LKmHycGWFeLqX(ebO0vy1uE84PAlm2kQ8oLRYwnLhpEQg3akJq1GrznGT6vrL3zNRSvdgL1a2Qx147hW(A1yVKKjetae(JOek2NiaLUcP(C5OEloswaekXeFhlkTGR(dI6DK6f5wQNyQ)mO(qnWejUbugHemkRbSvt5XJNQ5I3qnsOyFIGkQ8o7qLTAWOSgWw9QgF)a2xRwOgyIKDb1o6vKqKGrznGTAkpE8unmJWkeZe2kQ8o7VYwnLhpEQghpwWDQgmkRbSvVkQ8oL5kB1GrznGT6vn((bSVwn2ljzcXeaH)ikHI9jcqPRWQP84Xt1Gma(nGkQ8oLVkB1uE84PAygHviMjSvdgL1a2QxfvENzALTAkpE8unMe(1W8hB1GrznGT6vrfvungHf94PYlNSY5uw5twNvJPUZpIOQXaEwg48m48DADc1t9zjau)7keVb1tIxQNHOFenGuORiemK6xGbD)fSupc7cuVEdSRgGL65e0reqjQaz0pa17u2oH6pt8WiSbyPEgU3biXRiKKFgs9bM6z4EhGeVIqs(tWOSgWYqQpZoZOJjQaz0pa17u2oH6pt8WiSbyPEgU3biXRiKKFgs9bM6z4EhGeVIqs(tWOSgWYqQpZoZOJjQaz0pa1lNZoH6pt8WiSbyPEgU3biXRiKKFgs9bM6z4EhGeVIqs(tWOSgWYqQpZoZOJjQaQagWZYaNNbNVtRtOEQplbG6FxH4nOEs8s9meYa43ayi1Vad6(lyPEe2fOE9gyxnal1ZjOJiGsubYOFaQ3zN7eQ)mXdJWgGL6z4EhGeVIqs(zi1hyQNH7Das8kcj5pbJYAaldP(m7mJoMOcKr)auVtzUtO(ZepmcBawQNH7Das8kcj5NHuFGPEgU3biXRiKK)emkRbSmK6ZSZm6yIkqg9dq9oZKoH6pt8WiSbyPEgU3biXRiKKFgs9bM6z4EhGeVIqs(tWOSgWYqQpZoZOJjQaQagSRq8gGL67N6vE84H6npkqjQGQjCXKVbQM8Kh1F21fr9mG6UpEPcKN8OEbxZ5uVZmXbQxozLZjvavG8Kh1FMe0reqDcvG8Kh1ldu)zTwWs9DQRRlysubYtEuVmq9N1Abl1Za88aVNt9mWxeHUmyxHWy)rK6zaEEG3ZtubYtEuVmq9N1Abl13tJWauFJa(guFGPEHlWXUSAq9NTtjJsubYtEuVmq9Yyza8B84bwgIO(o1c8h94H6Fe1BbdeGnrfip5r9Ya1FwRfSuFNocOEgCaUOevG8Kh1lduFwMGse1dtSNt9K4L67zulGc86MOcOcKN8OEzSma(nal1ZcK4fOEo2LvdQNfe)bLO(ZY5GWar9dEKbc66sEnuVYJhpiQhpMZtubkpE8GscxGJDz140rxwncdiHiGVbvavG8Kh1lJLbWVbyPEGrypN6J3fO(Gaq9kpWl1)iQxzuFJYAGevGYJhpOdobDfbQaLhpEqNo6k866cgQaLhpEqNo6kehpEC4jpe520cU6pOdzj2cSxsYehBWi0fjHCveH0cU6pO(Y0C5yXieXKViHqAbx9hKJY1pvGYJhpOthDznySvI8UN7WtEyb2ljzIJnye6IKqUkIq6kKkq5XJh0PJUSWIGLOFeD4jpSa7LKmXXgmcDrsixfriTGR(dQpzMkq5XJh0PJU6Y1bKc8UWeo8KhCm2yXmNKlEd1iHI9jcsl4Q)G6ZzQFIxveCSFzPcuE84bD6OR5fjeijz6AfDHjC4jpSa7LKmXXgmcDrsixfrizXmhI5ySXIzojx8gQrcf7teKwWv)brfO84Xd60rxYFbwdgBD4jpSa7LKmXXgmcDrsixfriDfsfO84Xd60rxD4akw1iXvJXHN8WcSxsYehBWi0fjHCveH0vivGYJhpOthDzvrjmPuSpNiKdp5HfyVKKjo2GrOlsc5QicjlM5qmhJnwmZj5I3qnsOyFIG0cU6piQaLhpEqNo6ErG0hGlIkq5XJh0PJUiMai8hrjuSpraYHN8ajemgPqxriqjMe(1W8hBFojoZCm2yXmNeRrTakWRBAbx9huFo7pxUqnWePvzufHnbJYAaBhPcuE84bD6OlxngjLhpEKmpkCyux4aYa43aCaf7ZJdNo8KhzoudmrYvriLVqcgL1awIdDfHirautqijKho25(7yUCHUIqKiaQjiKeYdhLt2C5YCORiejcGAccjH8OVmvwI5ygHrNiXimbHZ3osfip5r9Y4aE8CQ)Swl1FMgqzeOElgqdddQpwDqgnaQ)hzquDbhOEwGRxeq9eWmPElM6phFPE7tsclmXRbq9Q1IOEgrjQhDrH(dyPE3RjEzi0vecz8ubYtEuVYJhpOthD5QXiP84XJK5rHdJ6cheuUdOyFEC40HN8ajemgPqxriqjMe(1W8hBFoPcuE84bD6OlxngjLhpEKmpkCyux4a9JObKcDfHGkq5XJh0PJUm(8aVNlTxebQaLhpEqNo6(UcHX(JOeJppW75ububkpE8Gsqga)gWHfuR5CjUACPcuE84bLGma(nGthD54HbDHfVijwDgyPcuE84bLGma(nGthD56WbJe7LK0HrDHdwJAbuGxxhEYdKqWyKcDfHaLys4xdZFShojwKBtl4Q)GoKL4mVQi0N81FUCRkc91VSeZEjjtlWjYai0aiu6kSJubkpE8Gsqga)gWPJUkJAORdp5Hi3MwWv)bDiBUCHUIqKI3fKcSK9bhLtwQaLhpEqjidGFd40rxoESG74WtEWEjjtkIamsY0vue2rVr6kKy2ljzsreGrsMUIIWo6nsl4Q)GCuKBjMJh79JKIiaJKmDffHD0BKwDiQpNubkpE8Gsqga)gWPJUqga)gGdp5b7LKmPicWijtxrryh9gPRqIzVKKjfragjz6kkc7O3iTGR(dYrrULyoES3pskIamsY0vue2rVrA1HO(CsfO84Xdkbza8BaNo6UkJQiSubkpE8Gsqga)gWPJUlmwhEYJfC1FqoEiYTeN5ZiudmrIPUSlOebBcgL1awI5ySXIzojo2GrOlsc5QicPfC1Fqo2HC5c1atKyQl7ckrWMGrznGLyogBSyMtIPUSlOebBAbx9hKJDOJeh6kcrkExqkWs2h6ZPCubkpE8Gsqga)gWPJUm1LDbLiyPcuE84bLGma(nGthD5ydgHUijKRIiqfO84Xdkbza8BaNo6Qd)HjKuYawebmNiQaLhpEqjidGFd40rxKqqxjmPeRIIhpubkpE8Gsqga)gWPJUC8yb3XHN8yVdqIxriHEXbcjmPuGxxycWkr0pIiIZ8QIqYcKp)dhLR)C5Sa7LKmXXgmcDrsixfriDfs8QIqFDq2C5yVKKj01AHrYcAqiTGYJC5yVKKjlOwZ5sC14MUc7ivGYJhpOeKbWVbC6OlMryfIzcRdp5bNGUIa6qoQaLhpEqjidGFd40rxUbugbhEYdKqWyKcDfHaLys4xdZFS95KyloswaekXeFhlkTGR(dYrrULkq5XJhucYa43aoD01fVHAKqX(ebo8KhwCKSaiuIj(owuAbx9hKJhICBUC7Das8kcjyS39hrjwdMzUCSxsYeMryfIzcBcfkNOd5i2cSxsYeKHqd(dytOq5eDixUCSxsYeRgHbm41MUcPcuE84bLGma(nGthD54XcUJdp5XQIqYcKp)dhLR)C5yVKKjlOwZ5sC14MUcPcuE84bLGma(nGthDreDngKqZhbSo8KhRkco2H(PcuE84bLGma(nGthDznQfqbEDD4jpyVKKjlOwZ5sC14MSyMdXzEvrWr5KnxUZyVdqIxriH(H8AKq3veiEvrWX(LTJubkpE8Gsqga)gWPJUygHviMjSubkpE8Gsqga)gWPJUC8yb3Hkq5XJhucYa43aoD0fYa43aOcOcuE84bLiO8derxJbj08raRdp5XQIGJYSSeZEjjtwqTMZL4QXnzXmhQaLhpEqjck)0rxoEyqxyXlsIvNbwQaLhpEqjck)0rxLrn01HN8GJXglM5K4ydgHUijKRIiKwWv)b5OtQaLhpEqjck)0rxM6YUGseSubkpE8Gseu(PJUCSbJqxKeYvreOcuE84bLiO8thD5gqzeC4jpS4izbqOet8DSO0cU6pihpe5wQaLhpEqjck)0rxD4pmHKsgWIiG5erfO84Xdkrq5No6Iec6kHjLyvu84Hkq5XJhuIGYpD0L1Owaf41Lkq5XJhuIGYpD0DvgvryPcuE84bLiO8thDxySo8Khl4Q)GC8WExnE8WajBQZeZEjjtiMai8hrjuSprakDfsfO84Xdkrq5No6YnGYiqfO84Xdkrq5No66I3qnsOyFIahEYd2ljzcXeaH)ikHI9jcqPRWC5S4izbqOet8DSO0cU6pihf5wIpJqnWejUbugHemkRbSubkpE8Gseu(PJUygHviMjSo8KhHAGjs2fu7OxrcrcgL1awQaLhpEqjck)0rxoESG7qfO84Xdkrq5No6cza8Bao8KhSxsYeIjac)rucf7teGsxHubkpE8Gseu(PJUygHviMjSubkpE8Gseu(PJUmj8RH5pwQaQaLhpEqj0pIgqk0veIJfgRdp5XcU6pihpe5wQaLhpEqj0pIgqk0veIthD54HbDHfVijwDgyD4jpiFrcH0cU6pO(C2bzPcuE84bLq)iAaPqxrioD0vzudDPcuE84bLq)iAaPqxrioD0DvgvryPcuE84bLq)iAaPqxrioD0LPUSlOeblvGYJhpOe6hrdif6kcXPJUCSbJqxKeYvreOcuE84bLq)iAaPqxrioD0vh(dtiPKbSicyorubkpE8GsOFenGuORieNo6Iec6kHjLyvu84Hkq5XJhuc9JObKcDfH40rxmJWkeZewhEYdobDfb0HCubkpE8GsOFenGuORieNo66I3qnsOyFIahEYJ9oajEfHem27(JOeRbZmxU9oajEfHeRgHbm41Mlh7LKmHzewHyMWMqHYjQVd5OcuE84bLq)iAaPqxrioD0LJhl4oo8KhSxsYe6ATWizbniKwq5bvGYJhpOe6hrdif6kcXPJUqga)gGdp5b7LKmHUwlmswqdcPfuEqfO84XdkH(r0asHUIqC6OlIORXGeA(iG1HN8yvrizbYN)rFDOFIzVKKjlOwZ5sC14MSyMdvGYJhpOe6hrdif6kcXPJUSg1cOaVUo8KhSxsYKfuR5CjUACtwmZH4vfbh7SSubkpE8GsOFenGuORieNo6Ab1AoxIRgxQaLhpEqj0pIgqk0veIthDXmcRqmtyPcuE84bLq)iAaPqxrioD01fVHAKqX(ebubkpE8GsOFenGuORieNo6UWyD4jpwWv)b5O9UA84Hbs2uNPcuE84bLq)iAaPqxrioD0LBaLrWHN8ajemgPqxriqjMe(1W8hBFoPcuE84bLq)iAaPqxrioD0LjHFnm)X6WtEeQbMirclJ4vctkXQryGemkRbS5YHecgJuORieOetc)Ay(JTVoKlhsiymsHUIqGsmj8RH5p2(KJy2ljzcXeaH)ikHI9jcqjlM5qfO84XdkH(r0asHUIqC6OlYOUo8KhNrOgyIejSmIxjmPeRgHbsWOSgWsCMxve6RFzZLZcSxsYehBWi0fjHCveH0vyUCNXEhGeVIqcg7D)ruI1Gz2XQHec8kV85SIkQca]] )


end
