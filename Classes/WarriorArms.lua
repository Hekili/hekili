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
                local swing = state.swings.mainhand
                local t = state.query_time

                return swing + floor( ( t - swing ) / state.mainhand_speed ) * state.mainhand_speed
            end,

            interval = "mainhand_speed",

            stop = function () return state.swings.mainhand == 0 end,
            value = function ()
                return ( state.talent.war_machine.enabled and 1.1 or 1 ) * base_rage_gen * arms_rage_mult * state.mainhand_speed / state.haste
            end,
        },

        conquerors_banner = {
            aura = "conquerors_banner",

            last = function ()
                local app = state.buff.conquerors_banner.applied
                local t = state.query_time

                return app + floor( t - app )
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
            onCancel = function()
                setCooldown( "global_cooldown", 0 )
            end,
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
            duration = function () return set_bonus.tier28_2pc > 0 and 13 or 10 end,
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

    spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
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
            local current = UnitPower( "player", RAGE, false )

            if current < lastRage then
                rageSpent = ( rageSpent + lastRage - current ) % 20 -- Anger Mgmt.

                if state.legendary.glory.enabled and GetPlayerAuraBySpellID( 324143 ) then
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


    spec:RegisterStateExpr( "cycle_for_execute", function ()
        if not settings.cycle or buff.execute_ineligible.down or buff.sudden_death.up then return false end
        return Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, max( settings.cycle_min, offset + delay ) ) > 0
    end )


    spec:RegisterStateExpr( "cycle_for_condemn", function ()
        if not settings.cycle or not covenant.venthyr or buff.condemn_ineligible.down or buff.sudden_death.up then return false end
        return Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, max( settings.cycle_min, offset + delay ) ) > 0 or Hekili:GetNumTargetsAboveHealthPct( 80, false, max( settings.cycle_min, offset + delay ) ) > 0
    end )


    -- Tier 28
    spec:RegisterGear( 'tier28', 188942, 188941, 188940, 188938, 188937 )
    spec:RegisterSetBonuses( "tier28_2pc", 364553, "tier28_4pc", 363913 )
    -- 2-Set - Pile On - Colossus Smash / Warbreaker lasts 3 sec longer and increases your damage dealt to affected enemies by an additional 5%.
    -- 4-Set - Pile On - Tactician has a 50% increased chance to proc against enemies with Colossus Smash and causes your next Overpower to grant 2% Strength, up to 20% for 15 sec.
    spec:RegisterAuras( {
        pile_on_ready = {
            id = 363917,
            duration = 15,
            max_stack = 1,
        },
        pile_on_str = {
            id = 366769,
            duration = 15,
            max_stack = 4,
            copy = "pile_on"
        }
    })


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
                setCooldown( "global_cooldown", 6 * haste )

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

            spend = 0,
            spendType = "rage",

            startsCombat = true,
            texture = 135358,

            usable = function ()
                if buff.sudden_death.up or buff.stone_heart.up then return true end
                if cycle_for_execute then return true end
                return target.health_pct < ( talent.massacre.enabled and 35 or 20 ), "requires < " .. ( talent.massacre.enabled and 35 or 20 ) .. "% health"
            end,

            cycle = "execute_ineligible",

            timeToReady = function()
                -- Instead of using regular resource requirements, we'll use timeToReady to support the spend system.
                if rage.current >= 20 then return 0 end
                return rage.time_to_20
            end,

            handler = function ()
                if not buff.sudden_death.up and not buff.stone_heart.up then
                    local cost = min( rage.current, 40 )
                    spend( cost, "rage", nil, true )
                    gain( 0.2 * cost, "rage" )
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
                },
                -- Target Swapping
                execute_ineligible = {
                    duration = 3600,
                    max_stack = 1,
                    generate = function( t, auraType )
                        if buff.sudden_death.down and buff.stone_heart.down and target.health_pct > ( talent.massacre.enabled and 35 or 20 ) then
                            t.count = 1
                            t.expires = query_time + 3600
                            t.applied = query_time
                            t.duration = 3600
                            t.caster = "player"
                            return
                        end
                        t.count = 0
                        t.expires = 0
                        t.applied = 0
                        t.caster = "nobody"
                    end
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

                if buff.pile_on_ready.up then
                    addStack( "pile_on_str", nil, 1 )
                    removeBuff( "pile_on_ready" )
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
                if cycle_for_condemn then return true end
                return target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or target.health_pct > 80, "requires > 80% or < " .. ( talent.massacre.enabled and 35 or 20 ) .. "% health"
            end,

            cycle = "condemn_ineligible",

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
                },
                -- Target Swapping
                condemn_ineligible = {
                    duration = 3600,
                    max_stack = 1,
                    generate = function( t, auraType )
                        if buff.sudden_death.up or not covenant.venthyr or ( target.health_pct > ( talent.massacre.enabled and 35 or 20 ) and target.health_pct < 80 ) then
                            t.count = 1
                            t.expires = query_time + 3600
                            t.applied = query_time
                            t.duration = 3600
                            t.caster = "player"
                            return
                        end
                        t.count = 0
                        t.expires = 0
                        t.applied = 0
                        t.caster = "nobody"
                    end
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


    spec:RegisterPack( "Arms", 20220530, [[dGKo2aqikPQhrjv2eQKpHkYOujLtPsQwfQOIxPs1SqL6wkQuSlH(LIYWOqDmkYYOqEMIkMMOsUMkjBJscFtuPACusY5uujRJsk9ofvknpkvUNISpfvDqkPWcvjEOOs5IOIk9rkPOojQOWkPOMjQOQBIkkQDsPSukPipvKPkQ6QOII8vfvQglLeTxj)fWGv4WKwms9yuMSGldTzG(mQA0iXPv1QPKuVgvy2eDBrz3s9BedhjDCurPLR0ZbnDQUUk2UkLVtbJxuX5Pu18Pe7NWLPkFLcQJLnJm2iJm(Q5yC0uUU6kJTQk52tfRevLXHYJvQ1mSswJndwjQQ9sIgQ8vcsoldRef3PcT2zZ4FNYHoYizZGF2rQ(tA2QG(m4NXMvj6ZlDoJUORuqDSSzKXgzKXxnhJJMY1vxzSvuj94uiBLsF2rQ(t6CBvqVsu(qa7IUsbeYQK1yZGIXCx39jRWmNz1EXyogZTyyKXgzKWSWCUrrBEeATcZZnIbNjQb1rXaKSIXCfnAUvm0qqmCD5rxmGguQu)MxmajRyW5MdYoool3iDaZ6yLKp0Hv(kb)MxIaUU8Ox5lBMQ8vcBLwIH6sLy774(ALwmt)gkg2njg8SqLuM)KUsl2HYlBgv5Re2kTed1LkX23X91kb(8uCGfZ0VHIX8IHPCzCLuM)KUsmsZzp4swiaT2nULx2MtLVskZFsxj9M66wjSvAjgQlLx2YvLVskZFsxPvVP84wjSvAjgQlLx2UQYxjL5pPRKbDPxu5a3kHTslXqDP8YMvu5RKY8N0vIrKei8abGzkKsLWwPLyOUuEzl3R8vsz(t6kPn7X2buqhxifcJJkHTslXqDP8YMvv5RKY8N0vcsf1fGacqRq)jDLWwPLyOUuEzBUQ8vcBLwIH6sLy774(ALyu0LhHIXKyyuLuM)KUsKB4sLya3YlBMmUYxjSvAjgQlvITVJ7RvApncswEmID4SFZdqljgIyR0smigwSig7PrqYYJrA1DjkjBiITslXGyyXIyqFabJKB4sLya3i0vghIX8tIHrvsz(t6kLrwxLaqFFoWYlBMmv5Re2kTed1LkX23X91krFabJWtiGnqavNsCrL5vsz(t6kXiDaZ6YlBMmQYxjSvAjgQlvITVJ7RvI(acgHNqaBGaQoL4IkZRKY8N0vcZbzhhlVSzAov(kHTslXqDPsS9DCFTsRYJXac(S3fJ5fJCDLyWLyqFabJbuds7byQmlgig6kPm)jDLGCCKsiv57oULx2mLRkFLWwPLyOUuj2(oUVwj6diymGAqApatLzXaXqlgCjgRYJIHDIXCmUskZFsxjAPgqOt2SYlBMUQYxjL5pPRua1G0EaMkZQe2kTed1LYlBMSIkFLuM)KUsKB4sLya3kHTslXqDP8YMPCVYxjL5pPRugzDvca995aRe2kTed1LYlBMSQkFLWwPLyOUuj2(oUVwPfZ0VHIHDIr4SQ)Kwm4CedJJZPskZFsxPf7q5LntZvLVsyR0smuxQeBFh3xReKkkLaUU8OdJgO8R0W3bXyEXWuLuM)KUsmjQ3WYlBgzCLVsyR0smuxQeBFh3xRKRsS9iiU3ilabeGwDxIrSvAjgedlwedivukbCD5rhgnq5xPHVdIX8IrUedlwedivukbCD5rhgnq5xPHVdIX8IHrIbxIb9bemcnGi1V5bG((CGWyGyORKY8N0vYaLFLg(ouEzZitv(kHTslXqDPsS9DCFTswVy4QeBpcI7nYcqabOv3LyeBLwIbXGlX4AIXQ8OymVyCLXIHflIraPpGGrgrsGWdeaMPqkXdvXWIfXW6fJ90iiz5Xi2HZ(npaTKyiITslXGyC9kPm)jDLGsnR8YRuab1J0R8Lntv(kPm)jDLyu0LhRe2kTed1LYlBgv5RKY8N0vI6jldLvcBLwIH6s5LT5u5Re2kTed1LkX23X91kXZcXfZ0VHIXKyySyWLyeq6diyKrKei8abGzkKsCXm9BOymVyyvIHflIbnbcfdUedWNNIdSyM(numStmm6QkPm)jDLOs8N0Lx2YvLVsyR0smuxQeBFh3xRuaPpGGrgrsGWdeaMPqkXd1kPm)jDLOLesaa8S2xEz7QkFLWwPLyOUuj2(oUVwPasFabJmIKaHhiamtHuIlMPFdfJ5fdROskZFsxjACH4YX38Lx2SIkFLWwPLyOUuj2(oUVwjgHidedDmJSUkbG((CGXfZ0VHIX8IHP4vIbxIXQ8OyyNyCLXvsz(t6kPltBeWj7ITxEzl3R8vcBLwIH6sLy774(ALci9bemYisceEGaWmfsjgigAXGlXGriYaXqhZiRRsaOVphyCXm9ByLuM)KUsYNNIdbS6tGpdBV8YMvv5Re2kTed1LkX23X91kfq6diyKrKei8abGzkKs8qTskZFsxjWFrAjHekVSnxv(kHTslXqDPsS9DCFTsbK(acgzejbcpqayMcPepuRKY8N0vsBgc9vLamvklVSzY4kFLWwPLyOUuj2(oUVwPasFabJmIKaHhiamtHuIbIHwm4smyeImqm0XmY6Qea67Zbgxmt)gwjL5pPReTYdqab89zCalVSzYuLVsyR0smuxQuRzyLGmDHaeqaWvDCBvca99bXkPm)jDLGmDHaeqaWvDCBvca99bXYlBMmQYxjSvAjgQlvQ1mSs86nucqabCkia4Vqhqx63XTskZFsxjE9gkbiGaofea8xOdOl974wEzZ0CQ8vsz(t6kDGiW7ygSsyR0smuxkVSzkxv(kHTslXqDPsS9DCFTsqQOuc46YJomAGYVsdFheJ5fdtIbxIX1edgHidedDKwQbe6KnlUyM(numMxmmDLyyXIy4QeBpU6nLh3i2kTedIX1RKY8N0vcAarQFZda995aHLx2mDvLVsyR0smuxQeBFh3xRKRsS9yMcHkBXi2kTedIbxIHRlp6rkOkDkrQmxmStmMZvIHflIHRlp6rkOkDkrQmxmStmmYyXWIfXGrUHT2E8g2of7xXGlXW1Lh9ifuLoLivMlgZlgwLXIHflIbZEMebajlaMdYookgwSigm7zseaKSamshWSUsqFFMx2mvjL5pPRetLsaL5pPbKp0RK8HoqRzyLWCq2XXYlBMSIkFLWwPLyOUuj2(oUVwPv)aaEdBpQHamEOkgwSigqQOuc46YJomAGYVsdFheJ5fdtvc67Z8YMPkPm)jDLyQucOm)jnG8HELKp0bAndRefLvEzZuUx5Re2kTed1LkPm)jDLyQucOm)jnG8HELKp0bAndRe8BEjc46YJE5LntwvLVsyR0smuxQeBFh3xReKCK0FhIupq)iraCpu9N0rSvAjgedlwedi5iP)oeVrKQ)seasK3W2JyR0smigCjgwVyqFabJ3is1FjcajYBy7auozAt(q8qTsF74UhQoWdwji5iP)oeVrKQ)seasK3W2R03oU7HQd8zzy4vhRKPkPm)jDLaLiKcBvqVsF74UhQoaVKqRYkzQ8YMP5QYxjL5pPR0TN5K1EG9aPujSvAjgQlLx2mY4kFLuM)KUsFgvSdFZdC7zozTVsyR0smuxkV8krDrgjJw9kFzZuLVskZFsxjA1DjcaPqoELWwPLyOUuEzZOkFLuM)KUsGsesHTkOxjSvAjgQlLxELWCq2XXkFzZuLVskZFsxPaQbP9amvMvjSvAjgQlLx2mQYxjL5pPReJ0C2dUKfcqRDJBLWwPLyOUuEzBov(kHTslXqDPsS9DCFTsqQOuc46YJomAGYVsdFheJjXWKyWLyWZcXfZ0VHIXKyySyWLyCnXyvEumMxmY9RedlweJv5rXyEX4kJfdUed6diyCrghsecBecJhQIX1RKY8N0vIPndLa0hqWkrFabbAndReTudi0jBw5LTCv5Re2kTed1LkX23X91kXZcXfZ0VHIXKyySyyXIy46YJE0)meWjaHhfd7edJmUskZFsxj9M66wEz7QkFLWwPLyOUujL5pPReJ0bmRReBFh3xRe9bemQqkydy1hEECB94XdvXGlXG(acgvifSbS6dppUTE84Iz63qXWoXGNfedUedgPdN3JkKc2aw9HNh3wpEC1MdXyEXWuLy2ZKiGRlp6WYMPYlBwrLVsyR0smuxQKY8N0vcZbzhhReBFh3xRe9bemQqkydy1hEECB94XdvXGlXG(acgvifSbS6dppUTE84Iz63qXWoXGNfedUedgPdN3JkKc2aw9HNh3wpEC1MdXyEXWuLy2ZKiGRlp6WYMPYlB5ELVskZFsxPvVP84wjSvAjgQlLx2SQkFLWwPLyOUuj2(oUVwPfZ0VHIHDtIbpligCjgxtmSEXWvj2E0GU0lQCGBeBLwIbXGlXGriYaXqhzejbcpqayMcPexmt)gkg2jg5smSyrmCvIThnOl9Ikh4gXwPLyqm4smyeImqm0rd6sVOYbUXfZ0VHIHDIrUeJRlgCjgUU8Oh9pdbCcq4rXyEXWKrvsz(t6kTyhkVSnxv(kPm)jDLmOl9Ikh4wjSvAjgQlLx2mzCLVskZFsxjgrsGWdeaMPqkvcBLwIH6s5LntMQ8vsz(t6kPn7X2buqhxifcJJkHTslXqDP8YMjJQ8vsz(t6kbPI6cqabOvO)KUsyR0smuxkVSzAov(kHTslXqDPskZFsxjgPdywxj2(oUVwP90iiz5Xi85B0biGaozZW2XaahFZdJyR0smigCjgxtmwLhJbe8zVlg2jggDLyyXIyeq6diyKrKei8abGzkKs8qvm4smwLhfJ5fJCzSyyXIyqFabJWtiGnqavNsCrL5IHflIb9bemgqniThGPYS4HQyC9kXSNjraxxE0HLntLx2mLRkFLWwPLyOUuj2(oUVwjgfD5rOymjggvjL5pPRe5gUujgWT8YMPRQ8vcBLwIH6sLy774(ALGurPeW1LhDy0aLFLg(oigZlgMedUeJaXJbePcyGC6amUyM(numStm4zHkPm)jDLysuVHLx2mzfv(kHTslXqDPsS9DCFTsbIhdisfWa50byCXm9BOyy3KyWZcIHflIXEAeKS8ye7Wz)MhGwsmeXwPLyqmSyrmOpGGrYnCPsmGBe6kJdXysmmsm4smci9bemI5qvsEh3i0vghIXKyyKyyXIyqFabJ0Q7sus2q8qTskZFsxPmY6Qea67ZbwEzZuUx5Re2kTed1LkPm)jDLyKoGzDLy774(ALwLhJbe8zVlg2jggDLyyXIyqFabJbuds7byQmlEOwjM9mjc46YJoSSzQ8YMjRQYxjSvAjgQlvITVJ7RvAvEumStmY1vvsz(t6kb54iLqQY3DClVSzAUQ8vcBLwIH6sLy774(ALOpGGXaQbP9amvMfdedTyWLyCnXyvEumStmmYyXWIfXW6fJ90iiz5Xi8BWJeaEwEmITslXGyWLySkpkg2jgxzSyC9kPm)jDLOLAaHozZkVSzKXv(kPm)jDLi3WLkXaUvcBLwIH6s5LnJmv5Re2kTed1LkPm)jDLyKoGzDLy2ZKiGRlp6WYMPYlBgzuLVsyR0smuxQKY8N0vcZbzhhReZEMebCD5rhw2mvE5vIIYQ8Lntv(kHTslXqDPsS9DCFTsRYJIHDIHvySyWLyqFabJbuds7byQmlgig6kPm)jDLGCCKsiv57oULx2mQYxjL5pPReJ0C2dUKfcqRDJBLWwPLyOUuEzBov(kHTslXqDPsS9DCFTsmcrgig6iJijq4bcaZuiL4Iz63qXWoXWuLuM)KUs6n11T8YwUQ8vsz(t6kzqx6fvoWTsyR0smuxkVSDvLVskZFsxjgrsGWdeaMPqkvcBLwIH6s5LnROYxjSvAjgQlvITVJ7Rvkq8yarQagiNoaJlMPFdfd7MedEwOskZFsxjMe1By5LTCVYxjL5pPRK2ShBhqbDCHuimoQe2kTed1LYlBwvLVskZFsxjivuxaciaTc9N0vcBLwIH6s5LT5QYxjL5pPReTudi0jBwLWwPLyOUuEzZKXv(kPm)jDLw9MYJBLWwPLyOUuEzZKPkFLWwPLyOUuj2(oUVwPfZ0VHIHDtIr4SQ)Kwm4CedJJZrm4smOpGGrObeP(npa03NdegpuRKY8N0vAXouEzZKrv(kPm)jDLysuVHvcBLwIH6s5LntZPYxjSvAjgQlvITVJ7RvI(acgHgqK638aqFFoqy8qvmSyrmcepgqKkGbYPdW4Iz63qXWoXGNfedUedRxmCvIThzsuVHrSvAjgQKY8N0vkJSUkbG((CGLx2mLRkFLWwPLyOUuj2(oUVwjxLy7XWIAO1dpfpITslXqLuM)KUsKB4sLya3YlBMUQYxjSvAjgQlvsz(t6kXiDaZ6kX23X91krFabJqdis9BEaOVphimEOkgwSig0hqWi8ecydeq1PepuReZEMebCD5rhw2mvEzZKvu5Re2kTed1LkPm)jDLWCq2XXkX23X91krFabJqdis9BEaOVphimEOkgwSig0hqWi8ecydeq1PepuReZEMebCD5rhw2mvEzZuUx5RKY8N0vICdxQed4wjSvAjgQlLx2mzvv(kPm)jDLmq5xPHVdvcBLwIH6s5LxELUHl8jDzZiJnYiJNJP5Qsg0T)MhwP5U1WAYgNHnRzRvmeJ8uqX4ZOswxmajRyWj438seW1LhDojglYzp)IbXasYqXqpojtDmigmkAZJWOWmN)BummzS1kg5gPVHRJbXGt7PrqYYJrRKtIHtedoTNgbjlpgTYi2kTedCsmUMPCUEuyMZ)nkgMm2AfJCJ03W1XGyWP90iiz5XOvYjXWjIbN2tJGKLhJwzeBLwIbojgxZuoxpkmZ5)gfdJmzTIrUr6B46yqm40EAeKS8y0k5Ky4eXGt7PrqYYJrRmITslXaNeJRzkNRhfMfMN7wdRjBCg2SMTwXqmYtbfJpJkzDXaKSIbNciOEKoNeJf5SNFXGyajzOyOhNKPogedgfT5ryuyMZ)nkgMSkRvmYnsFdxhdIbNGKJK(7q0k5Ky4eXGtqYrs)DiALrSvAjg4KyCnJY56rHzH55U1WAYgNHnRzRvmeJ8uqX4ZOswxmajRyWjmhKDCKtIXIC2ZVyqmGKmum0JtYuhdIbJI28imkmZ5)gfdtZXAfJCJ03W1XGyWP90iiz5XOvYjXWjIbN2tJGKLhJwzeBLwIbojgxZuoxpkmZ5)gfdtwH1kg5gPVHRJbXGt7PrqYYJrRKtIHtedoTNgbjlpgTYi2kTedCsmUMPCUEuyMZ)nkgMMlRvmYnsFdxhdIbN2tJGKLhJwjNedNigCApncswEmALrSvAjg4KyCnt5C9OWSWmNrgvY6yqmUsmuM)KwmKp0HrH5kbPISYwUBQsuxc4lXkzDwNyyn2mOym31DFYkmBDwNyWzwTxmMJXClggzSrgjmlmBDwNyKBu0MhHwRWS1zDIXCJyWzIAqDumajRymxrJMBfdneedxxE0fdObLk1V5fdqYkgCU5GSJJZYnshWSokmlmBDwNyW5MdYoogedAeKSOyWiz0Qlg0i)3WOyynymKQdfJM0Znu0nd8ifdL5pPHIbPL2hfMvM)KggPUiJKrR(9Pz0Q7seasHCCHzL5pPHrQlYiz0QFFAgOeHuyRc6cZcZwN1jgCU5GSJJbXaVHR9IH)zOy4uqXqzozfJhkg6n9LkTeJcZkZFsdNyu0LhfMvM)KgEFAg1twgkfMvM)KgEFAgvI)KM7hCINfIlMPFdNmMRasFabJmIKaHhiamtHuIlMPFdN3QSyHMaHCb(8uCGfZ0VH2z0vcZkZFsdVpnJwsibaWZAp3p4uaPpGGrgrsGWdeaMPqkXdvHzL5pPH3NMrJlexo(MN7hCkG0hqWiJijq4bcaZuiL4Iz63W5TcHzL5pPH3NMPltBeWj7ITZ9doXiezGyOJzK1vja03NdmUyM(nCEtXR4AvE0URmwywz(tA49PzYNNIdbS6tGpdBN7hCkG0hqWiJijq4bcaZuiLyGyO5IriYaXqhZiRRsaOVphyCXm9BOWSY8N0W7tZa)fPLesG7hCkG0hqWiJijq4bcaZuiL4HQWSY8N0W7tZ0MHqFvjatLsUFWPasFabJmIKaHhiamtHuIhQcZkZFsdVpnJw5biGa((moGC)GtbK(acgzejbcpqayMcPedednxmcrgig6ygzDvca995aJlMPFdfMvM)KgEFA2bIaVJzC3Agobz6cbiGaGR642Qea67dIcZkZFsdVpn7arG3XmUBndN41BOeGac4uqaWFHoGU0VJRWSY8N0W7tZoqe4DmdkmRm)jn8(0mObeP(npa03NdeY9dobPIsjGRlp6WObk)kn8DyEtCDngHidedDKwQbe6KnlUyM(nCEtxzXIRsS94Q3uECJyR0smCDHzL5pPH3NMXuPeqz(tAa5dDUBndNWCq2XrUH((mFYe3p4KRsS9yMcHkBXi2kTedC56YJEKcQsNsKkZTBoxzXIRlp6rkOkDkrQm3oJm2Ifg5g2A7XBy7uSF5Y1Lh9ifuLoLivMpVvzSflm7zseaKSayoi74Oflm7zseaKSamshWSwywz(tA49PzmvkbuM)Kgq(qN7wZWjkkJBOVpZNmX9doT6haWBy7rneGXdvlwGurPeW1LhDy0aLFLg(omVjHzL5pPH3NMXuPeqz(tAa5dDUBndNGFZlraxxE0fMvM)KgEFAgOeHuyRc6C)GtqYrs)Dis9a9JebW9q1FsBXcKCK0FhI3is1FjcajYBy7Cz90hqW4nIu9xIaqI8g2oaLtM2Kpepu5(Bh39q1b(Smm8QJtM4(Bh39q1b4LeAvozI7VDC3dvh4bNGKJK(7q8grQ(lrairEdBxywz(tA49Pz3EMtw7b2dKIWSY8N0W7tZ(mQyh(Mh42ZCYAVWSWSY8N0WiMdYooofqniThGPYmHzL5pPHrmhKDC8(0mgP5ShCjleGw7gxHzL5pPHrmhKDC8(0mM2mucqFab5U1mCIwQbe6KnJ7hCcsfLsaxxE0Hrdu(vA47WKjU4zH4Iz63WjJ56ARYJZN7xzXYQ848xzmx0hqW4ImoKie2iegpuVUWSY8N0WiMdYooEFAMEtDD5(bN4zH4Iz63WjJTyX1Lh9O)ziGtacpANrglmRm)jnmI5GSJJ3NMXiDaZAUz2ZKiGRlp6WjtC)Gt0hqWOcPGnGvF45XT1Jhpu5I(acgvifSbS6dppUTE84Iz63q74zbUyKoCEpQqkydy1hEECB94XvBoM3KWSY8N0WiMdYooEFAgMdYooYnZEMebCD5rhozI7hCI(acgvifSbS6dppUTE84Hkx0hqWOcPGnGvF45XT1Jhxmt)gAhplWfJ0HZ7rfsbBaR(WZJBRhpUAZX8MeMvM)KggXCq2XX7tZw9MYJRWSY8N0WiMdYooEFA2IDG7hCAXm9BODt8SaxxZ6DvIThnOl9Ikh4gXwPLyGlgHidedDKrKei8abGzkKsCXm9BOD5YIfxLy7rd6sVOYbUrSvAjg4IriYaXqhnOl9Ikh4gxmt)gAxUUoxUU8Oh9pdbCcq4X5nzKWSY8N0WiMdYooEFAMbDPxu5axHzL5pPHrmhKDC8(0mgrsGWdeaMPqkcZkZFsdJyoi7449PzAZESDaf0XfsHW4qywz(tAyeZbzhhVpndsf1fGacqRq)jTWSY8N0WiMdYooEFAgJ0bmR5MzptIaUU8OdNmX9doTNgbjlpgHpFJoabeWjBg2oga44BEixxBvEmgqWN9UDgDLflbK(acgzejbcpqayMcPepu5AvEC(CzSfl0hqWi8ecydeq1PexuzUfl0hqWya1G0EaMkZIhQxxywz(tAyeZbzhhVpnJCdxQed4Y9doXOOlpcNmsywz(tAyeZbzhhVpnJjr9gY9dobPIsjGRlp6WObk)kn8DyEtCfiEmGivadKthGXfZ0VH2XZccZkZFsdJyoi7449PzzK1vja03NdK7hCkq8yarQagiNoaJlMPFdTBINfSyzpncswEmID4SFZdqljgSyH(acgj3WLkXaUrORmoMmIRasFabJyouLK3XncDLXXKrwSqFabJ0Q7sus2q8qvywz(tAyeZbzhhVpnJr6aM1CZSNjraxxE0HtM4(bNwLhJbe8zVBNrxzXc9bemgqniThGPYS4HQWSY8N0WiMdYooEFAgKJJucPkF3XL7hCAvE0UCDLWSY8N0WiMdYooEFAgTudi0jBg3p4e9bemgqniThGPYSyGyO56ARYJ2zKXwSy97PrqYYJr43Ghja8S8ixRYJ2DLXxxywz(tAyeZbzhhVpnJCdxQed4kmRm)jnmI5GSJJ3NMXiDaZAUz2ZKiGRlp6WjtcZkZFsdJyoi7449Pzyoi74i3m7zseW1LhD4KjHzHzL5pPHrkkBcYXrkHuLV74Y9doTkpANvymx0hqWya1G0EaMkZIbIHwywz(tAyKIYUpnJrAo7bxYcbO1UXvywz(tAyKIYUpntVPUUC)Gtmcrgig6iJijq4bcaZuiL4Iz63q7mjmRm)jnmsrz3NMzqx6fvoWvywz(tAyKIYUpnJrKei8abGzkKIWSY8N0WifLDFAgtI6nK7hCkq8yarQagiNoaJlMPFdTBINfeMvM)KggPOS7tZ0M9y7akOJlKcHXHWSY8N0WifLDFAgKkQlabeGwH(tAHzL5pPHrkk7(0mAPgqOt2mHzL5pPHrkk7(0SvVP84kmRm)jnmsrz3NMTyh4(bNwmt)gA3u4SQ)KMZX44C4I(acgHgqK638aqFFoqy8qvywz(tAyKIYUpnJjr9gkmRm)jnmsrz3NMLrwxLaqFFoqUFWj6diyeAarQFZda995aHXdvlwcepgqKkGbYPdW4Iz63q74zbUSExLy7rMe1ByeBLwIbHzL5pPHrkk7(0mYnCPsmGl3p4KRsS9yyrn06HNIhXwPLyqywz(tAyKIYUpnJr6aM1CZSNjraxxE0HtM4(bNOpGGrObeP(npa03NdegpuTyH(acgHNqaBGaQoL4HQWSY8N0WifLDFAgMdYooYnZEMebCD5rhozI7hCI(acgHgqK638aqFFoqy8q1If6diyeEcbSbcO6uIhQcZkZFsdJuu29PzKB4sLyaxHzL5pPHrkk7(0mdu(vA47GWSWSY8N0Wi8BEjc46YJ(0IDG7hCAXm9BODt8SGWSY8N0Wi8BEjc46YJ(9PzmsZzp4swiaT2nUC)GtGppfhyXm9B48MYLXcZkZFsdJWV5LiGRlp63NMP3uxxHzL5pPHr438seW1Lh97tZw9MYJRWSY8N0Wi8BEjc46YJ(9Pzg0LErLdCfMvM)KggHFZlraxxE0VpnJrKei8abGzkKIWSY8N0Wi8BEjc46YJ(9PzAZESDaf0XfsHW4qywz(tAye(nVebCD5r)(0mivuxaciaTc9N0cZkZFsdJWV5LiGRlp63NMrUHlvIbC5(bNyu0LhHtgjmRm)jnmc)MxIaUU8OFFAwgzDvca995a5(bN2tJGKLhJyho738a0sIblw2tJGKLhJ0Q7sus2Gfl0hqWi5gUujgWncDLXX8tgjmRm)jnmc)MxIaUU8OFFAgJ0bmR5(bNOpGGr4jeWgiGQtjUOYCHzL5pPHr438seW1Lh97tZWCq2XrUFWj6diyeEcbSbcO6uIlQmxywz(tAye(nVebCD5r)(0mihhPesv(UJl3p40Q8ymGGp795Z1vCrFabJbuds7byQmlgigAHzL5pPHr438seW1Lh97tZOLAaHozZ4(bNOpGGXaQbP9amvMfdednxRYJ2nhJfMvM)KggHFZlraxxE0VpnlGAqApatLzcZkZFsdJWV5LiGRlp63NMrUHlvIbCfMvM)KggHFZlraxxE0VpnlJSUkbG((CGcZkZFsdJWV5LiGRlp63NMTyh4(bNwmt)gAx4SQ)KMZX44CeMvM)KggHFZlraxxE0VpnJjr9gY9dobPIsjGRlp6WObk)kn8DyEtcZkZFsdJWV5LiGRlp63NMzGYVsdFh4(bNCvIThbX9gzbiGa0Q7smITslXGflqQOuc46YJomAGYVsdFhMpxwSaPIsjGRlp6WObk)kn8DyEJ4I(acgHgqK638aqFFoqymqm0cZkZFsdJWV5LiGRlp63NMbLAg3p4K17QeBpcI7nYcqabOv3LyeBLwIbUU2Q848xzSflbK(acgzejbcpqayMcPepuTyX63tJGKLhJyho738a0sIHRxE5vb]] )


end
