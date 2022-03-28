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


    spec:RegisterPack( "Arms", 20220319, [[dG0PZaqivq5rIQWMqs9jcQgfsqNcjWQiiOxPcnluPULOkj7sOFjvzyusogHSmujptfKPjQQUgsOTrqX3evPghbLohbrRtuv6DQGQmpkPUNuzFQahuuLyHsv9qrvXfjiuFufuvNKGaRKsmtcs6MQGk2jLYsvbv6PImvrLRkQsQVsqiJvufTxj)fKblLdtAXOQhJYKfCzOndQpJuJwfDAvTAcs9AKOztXTfLDR43igoQ44eKy5k9CGPt11vPTJK8DcmEkvDEkvMpHA)eDjQYvPG6yzJlR4IlRoKiHmYLvwjSIQKBhhSsCugLknwPrZWkLx2mqL4O2ziAOYvja5UmSsNUZbKV96r)(5LpYiz9aF21O(tg2QWEpWNX6vj(7BCHGP4RuqDSSXLvCXLvhsKqg5YkRewReYkPx)KSvk9zxJ6pzYNvH9kD(HaofFLciGvP8YMbKnHiD3NSslho6YoLnrcj3YgxwXfxslsl5ZPo0iiFLwYRKT8Aob1rzdMSYMqg56Wt20qq2CDPrx2acuoC(Hw2GjRSjeBpYUo2lFitaZMyLmpWbvUkb(H2GqUU0Ox5kBIQCvchL3GHQFLy774(ALwmt)biBw3jB0SqLuM)KPsloHYlBCv5QeokVbdv)kX23X91kb)0No0Iz6paz7aztu(TQskZFYujgzekxCjlaIxNb3YlBhQYvjL5pzQKsL66wjCuEdgQ(Lx2YFLRskZFYuPvPsPXTs4O8gmu9lVSrXkxLuM)KPsc0LFrLsCReokVbdv)YlBctLRskZFYujgXqaGlacKPGZkHJYBWq1V8YwEx5QKY8Nmvsh2JJdPWoUGtcJYkHJYBWq1V8YMWw5QKY8NmvcWb1fIadXRa)jtLWr5nyO6xEztiRCvchL3GHQFLy774(ALyN6sJazRt24QskZFYujcv4YHia3YlBISQYvjCuEdgQ(vITVJ7RvAVdctwAmIt4U)qdXBicI4O8gmiBIflB7DqyYsJrE1DdAiBiIJYBWGSjwSSXFHHJeQWLdraUrGRmkLTd6KnUQKY8NmvkJSUAGa((uILx2ejQYvjCuEdgQ(vITVJ7RvI)cdhb3qahOaQ(zCrL5vsz(tMkXitaZMYlBI4QYvjCuEdgQ(vITVJ7RvI)cdhb3qahOaQ(zCrL5vsz(tMkH2JSRJLx2eDOkxLWr5nyO6xj2(oUVwPvPXyaHF27Y2bYw(POSrTSXFHHJbudg7GyQjlgicMkPm)jtLauEngahZ7oULx2eL)kxLWr5nyO6xj2(oUVwj(lmCmGAWyhetnzXarWiBulBRsJYM1Y2HSQskZFYujEJgqGt2SYlBIOyLRskZFYuPaQbJDqm1KvjCuEdgQ(Lx2ejmvUkPm)jtLiuHlhIaCReokVbdv)YlBIY7kxLuM)KPszK1vdeW3NsSs4O8gmu9lVSjsyRCvchL3GHQFLy774(ALwmt)biBwlBH7Q(tgztiu2SkEOkPm)jtLwCcLx2ejKvUkHJYBWq1VsS9DCFTsaoOXa56sJoik48xJGFcY2bYMOkPm)jtLyguPclVSXLvvUkHJYBWq1VsS9DCFTsUAWXJW4sfzHiWq8Q7gmIJYBWGSjwSSb4GgdKRln6GOGZFnc(jiBhiB5x2elw2aCqJbY1LgDquW5Vgb)eKTdKnUKnQLn(lmCeiaro)qdb89PebXarWujL5pzQKGZFnc(juEzJlrvUkHJYBWq1VsS9DCFTshMS5QbhpcJlvKfIadXRUBWiokVbdYg1YgfkBRsJY2bYgfTs2elw2ci)fgoYigcaCbqGmfCgVCKnXILTdt227GWKLgJ4eU7p0q8gIGiokVbdYgfujL5pzQeWOzLxELciSEnELRSjQYvjL5pzQe7uxASs4O8gmu9lVSXvLRskZFYujo3Sm0ujCuEdgQ(Lx2ouLRs4O8gmu9ReBFh3xRenlexmt)biBDYMvYg1Ywa5VWWrgXqaGlacKPGZ4Iz6paz7aztyLnXILnEcaiBulBWp9PdTyM(dq2Sw24IIvsz(tMkXH4pzkVSL)kxLWr5nyO6xj2(oUVwPaYFHHJmIHaaxaeitbNXlNkPm)jtL4nesac(U2vEzJIvUkHJYBWq1VsS9DCFTsbK)cdhzedbaUaiqMcoJlMP)aKTdKnHPskZFYujECb4s5p0Lx2eMkxLWr5nyO6xj2(oUVwjgHycebtmJSUAGa((uIXfZ0FaY2bYMOifLnQLTvPrzZAzJIwvjL5pzQKUmDqiNSloE5LT8UYvjCuEdgQ(vITVJ7RvkG8xy4iJyiaWfabYuWzmqemYg1YgJqmbIGjMrwxnqaFFkX4Iz6pGkPm)jtLmp9PdGe6BGodhV8YMWw5QeokVbdv)kX23X91kfq(lmCKrmea4cGazk4mE5ujL5pzQe8ViVHqcLx2eYkxLWr5nyO6xj2(oUVwPaYFHHJmIHaaxaeitbNXlNkPm)jtL0HHaFvdetnMYlBISQYvjCuEdgQ(vITVJ7RvkG8xy4iJyiaWfabYuWzmqemYg1YgJqmbIGjMrwxnqaFFkX4Iz6pGkPm)jtL4vAicmKVpJsq5LnrIQCvchL3GHQFLgndReGPlaIadbVQJ7OgiGVpmwjL5pzQeGPlaIadbVQJ7OgiGVpmwEztexvUkHJYBWq1VsJMHvIwPcnqeyi)eHG)f4q6Y)oUvsz(tMkrRuHgicmKFIqW)cCiD5Fh3YlBIouLRskZFYuPlaHEhZavchL3GHQF5Lnr5VYvjCuEdgQ(vITVJ7RvcWbngixxA0brbN)Ae8tq2oq2ejBulBuOSXietGiyI8gnGaNSzXfZ0FaY2bYMikkBIflBUAWXJRsLsJBehL3GbzJcQKY8Nmvciaro)qdb89PebLx2erXkxLWr5nyO6xj2(oUVwjxn44Xmfau2IrCuEdgKnQLnxxA0JNOA8ZihMlBwlBhIIYMyXYMRln6Xtun(zKdZLnRLnUSs2elw2yeQWrhpsfo(PDRSrTS56sJE8evJFg5WCz7aztyTs2elw2y2XmiemzHq7r21rztSyzJzhZGqWKfIrMaMnvc47Z8YMOkPm)jtLyQXaPm)jdK5bELmpWHgndReApYUowEztKWu5QeokVbdv)kX23X91kT6hGqQWXJAiaIxoYMyXYgGdAmqUU0OdIco)1i4NGSDGSjQsaFFMx2evjL5pzQetngiL5pzGmpWRK5bo0OzyLovw5Lnr5DLRs4O8gmu9RKY8NmvIPgdKY8NmqMh4vY8ahA0mSsGFOniKRln6Lx2ejSvUkPm)jtLO6zozTdAVGZkHJYBWq1V8YMiHSYvjL5pzQ0NXbNWp0qu9mNS2vjCuEdgQ(LxEL4SiJKXRELRSjQYvjL5pzQeV6UbHaNKRxjCuEdgQ(LxELq7r21XkxztuLRskZFYuPaQbJDqm1KvjCuEdgQ(Lx24QYvjL5pzQeJmcLlUKfaXRZGBLWr5nyO6xEz7qvUkHJYBWq1VsS9DCFTsaoOXa56sJoik48xJGFcYwNSjs2Ow2OzH4Iz6pazRt2Ss2Ow2OqzBvAu2oq2YBkkBIflBRsJY2bYgfTs2Ow24VWWXfzuAqayqaiE5iBuqLuM)KPsmDyObI)cdxj(lmm0OzyL4nAabozZkVSL)kxLWr5nyO6xj2(oUVwjAwiUyM(dq26KnRKnXILnxxA0J(NHqobk8OSzTSXLvvsz(tMkPuPUULx2OyLRs4O8gmu9RKY8NmvIrMaMnvITVJ7RvI)cdhvWjoqc9LMg3rVE8Yr2Ow24VWWrfCIdKqFPPXD0Rhxmt)biBwlB0SGSrTSXit4(EubN4aj0xAACh96XvhkLTdKnrvIzhZGqUU0OdkBIkVSjmvUkHJYBWq1VskZFYuj0EKDDSsS9DCFTs8xy4OcoXbsOV004o61JxoYg1Yg)fgoQGtCGe6lnnUJE94Iz6pazZAzJMfKnQLngzc33Jk4ehiH(stJ7OxpU6qPSDGSjQsm7ygeY1LgDqztu5LT8UYvjL5pzQ0QuP04wjCuEdgQ(Lx2e2kxLWr5nyO6xj2(oUVwPfZ0FaYM1DYgnliBulBuOSDyYMRgC8OaD5xuPe3iokVbdYg1YgJqmbIGjYigcaCbqGmfCgxmt)biBwlB5x2elw2C1GJhfOl)IkL4gXr5nyq2Ow2yeIjqemrb6YVOsjUXfZ0FaYM1Yw(Lnkq2Ow2CDPrp6Fgc5eOWJY2bYMiUQKY8NmvAXjuEztiRCvsz(tMkjqx(fvkXTs4O8gmu9lVSjYQkxLuM)KPsmIHaaxaeitbNvchL3GHQF5LnrIQCvsz(tMkPd7XXHuyhxWjHrzLWr5nyO6xEztexvUkPm)jtLaCqDHiWq8kWFYujCuEdgQ(Lx2eDOkxLWr5nyO6xjL5pzQeJmbmBQeBFh3xR0EheMS0ye80d6qeyiNSz44yaIYFObrCuEdgKnQLnku2wLgJbe(zVlBwlBCrrztSyzlG8xy4iJyiaWfabYuWz8Yr2Ow2wLgLTdKT8BLSjwSSXFHHJGBiGduav)mUOYCztSyzJ)cdhdOgm2bXutw8Yr2OGkXSJzqixxA0bLnrLx2eL)kxLWr5nyO6xj2(oUVwj2PU0iq26KnUQKY8NmvIqfUCicWT8YMikw5QeokVbdv)kX23X91kb4GgdKRln6GOGZFnc(jiBhiBIKnQLTaXJbe5ajGCNaiUyM(dq2Sw2OzHkPm)jtLyguPclVSjsyQCvchL3GHQFLy774(ALcepgqKdKaYDcG4Iz6pazZ6ozJMfKnXILT9oimzPXioH7(dneVHiiIJYBWGSjwSSXFHHJeQWLdraUrGRmkLTozJlzJAzlG8xy4iAphd5DCJaxzukBDYgxYMyXYg)fgoYRUBqdzdXlNkPm)jtLYiRRgiGVpLy5Lnr5DLRs4O8gmu9RKY8NmvIrMaMnvITVJ7RvAvAmgq4N9USzTSXffLnXILn(lmCmGAWyhetnzXlNkXSJzqixxA0bLnrLx2ejSvUkHJYBWq1VsS9DCFTsRsJYM1Yw(PyLuM)KPsakVgdGJ5Dh3YlBIeYkxLWr5nyO6xj2(oUVwj(lmCmGAWyhetnzXarWiBulBuOSTknkBwlBCzLSjwSSDyY2EheMS0ye8d81abUlngXr5nyq2Ow2wLgLnRLnkALSrbvsz(tMkXB0acCYMvEzJlRQCvsz(tMkrOcxoeb4wjCuEdgQ(Lx24suLRs4O8gmu9RKY8NmvIrMaMnvIzhZGqUU0OdkBIkVSXfxvUkHJYBWq1VskZFYuj0EKDDSsm7ygeY1LgDqztu5LxPtLv5kBIQCvchL3GHQFLy774(ALwLgLnRLnHXkzJAzJ)cdhdOgm2bXutwmqemvsz(tMkbO8AmaoM3DClVSXvLRskZFYujgzekxCjlaIxNb3kHJYBWq1V8Y2HQCvchL3GHQFLy774(ALyeIjqemrgXqaGlacKPGZ4Iz6pazZAztuLuM)KPskvQRB5LT8x5QKY8NmvsGU8lQuIBLWr5nyO6xEzJIvUkPm)jtLyedbaUaiqMcoReokVbdv)YlBctLRs4O8gmu9ReBFh3xRuG4XaICGeqUtaexmt)biBw3jB0SqLuM)KPsmdQuHLx2Y7kxLuM)KPs6WECCif2XfCsyuwjCuEdgQ(Lx2e2kxLuM)KPsaoOUqeyiEf4pzQeokVbdv)YlBczLRskZFYujEJgqGt2SkHJYBWq1V8YMiRQCvsz(tMkTkvknUvchL3GHQF5LnrIQCvchL3GHQFLy774(ALwmt)biBw3jBH7Q(tgztiu2SkEizJAzJ)cdhbcqKZp0qaFFkrq8YPskZFYuPfNq5LnrCv5QKY8NmvIzqLkSs4O8gmu9lVSj6qvUkHJYBWq1VsS9DCFTs8xy4iqaIC(Hgc47tjcIxoYMyXYwG4XaICGeqUtaexmt)biBwlB0SGSrTSDyYMRgC8iZGkvyehL3GHkPm)jtLYiRRgiGVpLy5Lnr5VYvjCuEdgQ(vITVJ7RvYvdoEmSOgg9sF6rCuEdgQKY8NmvIqfUCicWT8YMikw5QeokVbdv)kPm)jtLyKjGztLy774(AL4VWWrGae58dneW3NseeVCKnXILn(lmCeCdbCGcO6NXlNkXSJzqixxA0bLnrLx2ejmvUkHJYBWq1VskZFYuj0EKDDSsS9DCFTs8xy4iqaIC(Hgc47tjcIxoYMyXYg)fgocUHaoqbu9Z4LtLy2XmiKRln6GYMOYlBIY7kxLuM)KPseQWLdraUvchL3GHQF5LnrcBLRskZFYujbN)Ae8tOs4O8gmu9lV8YRev4cEYu24YkU4YkU4syQKaDNFObvsikVC4AtiW2HF(kBYwUtu2(moK1LnyYkBch8dTbHCDPrx4Y2IcL7Vyq2aKmu20RtYuhdYg7uhAeeLweQ)GYMiRYxzlFidv46yq2e(EheMS0ympfUS5ezt47DqyYsJX8mIJYBWGWLnkuK9uquArO(dkBISkFLT8HmuHRJbzt47DqyYsJX8u4YMtKnHV3bHjlngZZiokVbdcx2Oqr2tbrPfH6pOSXLO8v2YhYqfUogKnHV3bHjlngZtHlBor2e(EheMS0ympJ4O8gmiCzJcfzpfeLwKweIYlhU2ecSD4NVYMSL7eLTpJdzDzdMSYMWr7r21rHlBlkuU)IbzdqYqztVojtDmiBStDOrquArO(dkBIou(kB5dzOcxhdYMW37GWKLgJ5PWLnNiBcFVdctwAmMNrCuEdgeUSrHISNcIslc1FqztKWKVYw(qgQW1XGSj89oimzPXyEkCzZjYMW37GWKLgJ5zehL3GbHlBuOi7PGO0Iq9hu2ejK5RSLpKHkCDmiBcFVdctwAmMNcx2CISj89oimzPXyEgXr5nyq4YgfkYEkikTiTieKXHSogKnkkBkZFYiBMh4GO0sL4Se43GvkpYdzlVSzaztis39jR0sEKhY2HJUStztKqYTSXLvCXL0I0sEKhYw(CQdncYxPL8ipKT8kzlVMtqDu2GjRSjKrUo8KnneKnxxA0LnGaLdNFOLnyYkBcX2JSRJ9YhYeWSjkTiTKh5HSjeBpYUogKnEeMSOSXiz8QlB8i9pGOSLxymKJdKTHm5vN6MbFnYMY8NmazJmg7IslkZFYaICwKrY4v)yxpE1DdcbojxxArAjpYdzti2EKDDmiBiv4ANS5FgkB(jkBkZjRS9aztPsFJYBWO0IY8NmGo2PU0O0IY8NmGJD94CZYqJ0IY8NmGJD94q8NmC)WD0SqCXm9hqNvuhq(lmCKrmea4cGazk4mUyM(d4aHvSyEcaqn8tF6qlMP)aSMlkkTOm)jd4yxpEdHeGGVRDC)WDbK)cdhzedbaUaiqMcoJxoslkZFYao21JhxaUu(dn3pCxa5VWWrgXqaGlacKPGZ4Iz6pGdegPfL5pzah76PltheYj7IJZ9d3XietGiyIzK1vdeW3NsmUyM(d4arrks9Q0O1u0kPfL5pzah76zE6thaj03aDgoo3pCxa5VWWrgXqaGlacKPGZyGiyOMriMarWeZiRRgiGVpLyCXm9hG0IY8NmGJD9G)f5nesG7hUlG8xy4iJyiaWfabYuWz8YrArz(tgWXUE6WqGVQbIPgd3pCxa5VWWrgXqaGlacKPGZ4LJ0IY8NmGJD94vAicmKVpJsa3pCxa5VWWrgXqaGlacKPGZyGiyOMriMarWeZiRRgiGVpLyCXm9hG0IY8NmGJD9Uae6DmJ7rZWoatxaebgcEvh3rnqaFFyuArz(tgWXUExac9oMX9OzyhTsfAGiWq(jcb)lWH0L)DCLwuM)KbCSR3fGqVJzaPfL5pzah76beGiNFOHa((uIaUF4oah0yGCDPrhefC(RrWpHdernfYietGiyI8gnGaNSzXfZ0FahiIIIf7QbhpUkvknUrCuEdgOaPfL5pzah76XuJbsz(tgiZdCUhnd7q7r21rUb((mVte3pCNRgC8yMcakBXiokVbdu76sJE8evJFg5WCRpeffl21Lg94jQg)mYH5wZLvIfZiuHJoEKkC8t7wQDDPrpEIQXpJCy(bcRvIfZSJzqiyYcH2JSRJIfZSJzqiyYcXitaZgPfL5pzah76XuJbsz(tgiZdCUhnd7ovg3aFFM3jI7hUB1paHuHJh1qaeVCelgWbngixxA0brbN)Ae8t4arslkZFYao21JPgdKY8NmqMh4CpAg2b(H2GqUU0OlTOm)jd4yxpQEMtw7G2l4uArz(tgWXUEFghCc)qdr1ZCYAN0I0IY8NmGiApYUo2fqnySdIPMmPfL5pzar0EKDD8yxpgzekxCjlaIxNbxPfL5pzar0EKDD8yxpMom0aXFHH5E0mSJ3Obe4KnJ7hUdWbngixxA0brbN)Ae8tOte10SqCXm9hqNvutHRsJhK3uuS4vPXdOOvuZFHHJlYO0GaWGaq8YHcKwuM)Kber7r21XJD9uQuxxUF4oAwiUyM(dOZkXIDDPrp6Fgc5eOWJwZLvslkZFYaIO9i764XUEmYeWSHBMDmdc56sJoOte3pCh)fgoQGtCGe6lnnUJE94Ld18xy4OcoXbsOV004o61JlMP)aSMMfOMrMW99OcoXbsOV004o61JRouEGiPfL5pzar0EKDD8yxp0EKDDKBMDmdc56sJoOte3pCh)fgoQGtCGe6lnnUJE94Ld18xy4OcoXbsOV004o61JlMP)aSMMfOMrMW99OcoXbsOV004o61JRouEGiPfL5pzar0EKDD8yxVvPsPXvArz(tgqeThzxhp21BXjW9d3TyM(dW6oAwGAk8WC1GJhfOl)IkL4gXr5nyGAgHycebtKrmea4cGazk4mUyM(dW68lwSRgC8OaD5xuPe3iokVbduZietGiyIc0LFrLsCJlMP)aSo)ua1UU0Oh9pdHCcu4XdeXL0IY8NmGiApYUoESRNaD5xuPexPfL5pzar0EKDD8yxpgXqaGlacKPGtPfL5pzar0EKDD8yxpDypooKc74cojmkLwuM)Kber7r21XJD9aCqDHiWq8kWFYiTOm)jdiI2JSRJh76XitaZgUz2XmiKRln6GorC)WD7DqyYsJrWtpOdrGHCYMHJJbik)HgqnfUkngdi8ZE3AUOOyXbK)cdhzedbaUaiqMcoJxouVknEq(TsSy(lmCeCdbCGcO6NXfvMlwm)fgogqnySdIPMS4LdfiTOm)jdiI2JSRJh76rOcxoeb4Y9d3Xo1LgbDCjTOm)jdiI2JSRJh76XmOsfY9d3b4GgdKRln6GOGZFnc(jCGiQdepgqKdKaYDcG4Iz6paRPzbPfL5pzar0EKDD8yxVmY6Qbc47tjY9d3fiEmGihibK7eaXfZ0Faw3rZcIfV3bHjlngXjC3FOH4nebIfZFHHJeQWLdraUrGRmk74I6aYFHHJO9CmK3XncCLrzhxIfZFHHJ8Q7g0q2q8YrArz(tgqeThzxhp21JrMaMnCZSJzqixxA0bDI4(H7wLgJbe(zVBnxuuSy(lmCmGAWyhetnzXlhPfL5pzar0EKDD8yxpaLxJbWX8UJl3pC3Q0O15NIslkZFYaIO9i764XUE8gnGaNSzC)WD8xy4ya1GXoiMAYIbIGHAkCvA0AUSsS4dBVdctwAmc(b(AGa3LgPEvA0AkAffiTOm)jdiI2JSRJh76rOcxoeb4kTOm)jdiI2JSRJh76XitaZgUz2XmiKRln6GorslkZFYaIO9i764XUEO9i76i3m7ygeY1LgDqNiPfPfL5pzaXtL1bO8AmaoM3DC5(H7wLgTwySIA(lmCmGAWyhetnzXarWiTOm)jdiEQSJD9yKrOCXLSaiEDgCLwuM)Kbepv2XUEkvQRl3pChJqmbIGjYigcaCbqGmfCgxmt)byTiPfL5pzaXtLDSRNaD5xuPexPfL5pzaXtLDSRhJyiaWfabYuWP0IY8NmG4PYo21JzqLkK7hUlq8yaroqci3jaIlMP)aSUJMfKwuM)Kbepv2XUE6WECCif2XfCsyukTOm)jdiEQSJD9aCqDHiWq8kWFYiTOm)jdiEQSJD94nAabozZKwuM)Kbepv2XUERsLsJR0IY8NmG4PYo21BXjW9d3TyM(dW6UWDv)jJqOvXdrn)fgoceGiNFOHa((uIG4LJ0IY8NmG4PYo21JzqLkuArz(tgq8uzh76LrwxnqaFFkrUF4o(lmCeiaro)qdb89PebXlhXIdepgqKdKaYDcG4Iz6paRPzbQpmxn44rMbvQWiokVbdslkZFYaINk7yxpcv4YHiaxUF4oxn44XWIAy0l9PhXr5nyqArz(tgq8uzh76XitaZgUz2XmiKRln6GorC)WD8xy4iqaIC(Hgc47tjcIxoIfZFHHJGBiGduav)mE5iTOm)jdiEQSJD9q7r21rUz2XmiKRln6GorC)WD8xy4iqaIC(Hgc47tjcIxoIfZFHHJGBiGduav)mE5iTOm)jdiEQSJD9iuHlhIaCLwuM)Kbepv2XUEco)1i4NG0I0IY8NmGi4hAdc56sJE3ItG7hUBXm9hG1D0SG0IY8NmGi4hAdc56sJ(XUEmYiuU4swaeVodUC)WDWp9PdTyM(d4ar53kPfL5pzarWp0geY1Lg9JD9uQuxxPfL5pzarWp0geY1Lg9JD9wLkLgxPfL5pzarWp0geY1Lg9JD9eOl)IkL4kTOm)jdic(H2GqUU0OFSRhJyiaWfabYuWP0IY8NmGi4hAdc56sJ(XUE6WECCif2XfCsyukTOm)jdic(H2GqUU0OFSRhGdQlebgIxb(tgPfL5pzarWp0geY1Lg9JD9iuHlhIaC5(H7yN6sJGoUKwuM)Kbeb)qBqixxA0p21lJSUAGa((uIC)WD7DqyYsJrCc39hAiEdrGyX7DqyYsJrE1DdAiBqSy(lmCKqfUCicWncCLr5bDCjTOm)jdic(H2GqUU0OFSRhJmbmB4(H74VWWrWneWbkGQFgxuzU0IY8NmGi4hAdc56sJ(XUEO9i76i3pCh)fgocUHaoqbu9Z4IkZLwuM)Kbeb)qBqixxA0p21dq51yaCmV74Y9d3Tkngdi8ZE)G8trQ5VWWXaQbJDqm1KfdebJ0IY8NmGi4hAdc56sJ(XUE8gnGaNSzC)WD8xy4ya1GXoiMAYIbIGH6vPrRpKvslkZFYaIGFOniKRln6h76fqnySdIPMmPfL5pzarWp0geY1Lg9JD9iuHlhIaCLwuM)Kbeb)qBqixxA0p21lJSUAGa((uIslkZFYaIGFOniKRln6h76T4e4(H7wmt)byD4UQ)Kri0Q4HKwuM)Kbeb)qBqixxA0p21JzqLkK7hUdWbngixxA0brbN)Ae8t4arslkZFYaIGFOniKRln6h76j48xJGFcC)WDUAWXJW4sfzHiWq8Q7gmIJYBWGyXaoOXa56sJoik48xJGFchKFXIbCqJbY1LgDquW5Vgb)eoGlQ5VWWrGae58dneW3NseedebJ0IY8NmGi4hAdc56sJ(XUEaJMX9d3DyUAWXJW4sfzHiWq8Q7gmIJYBWa1u4Q04bu0kXIdi)fgoYigcaCbqGmfCgVCel(W27GWKLgJ4eU7p0q8gIakOsaoiRSL3IkV8Qaa]] )


end
