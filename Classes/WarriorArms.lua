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

                return swing + ( floor( ( t - swing ) / state.mainhand_speed ) * state.mainhand_speed )
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
        if not settings.cycle then return false end
        
        local actual = rawget( args, "cycle_targets")
        args.cycle_targets = 1
    
        local result = action.execute.cycle
        args.cycle_targets = actual
        
        return result
    end )


    spec:RegisterStateExpr( "cycle_for_condemn", function ()
        if not settings.cycle or not covenant.venthyr then return false end

        local actual = rawget( args, "cycle_targets")
        args.cycle_targets = 1
        
        local result = action.condemn.cycle
        args.cycle_targets = actual

        return result
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
                if action.execute.cycle then return true end
                return target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or target.health_pct > 80, "requires > 80% or < " .. ( talent.massacre.enabled and 35 or 20 ) .. "% health"
            end,

            cycle = function ()
                if not settings.cycle or args.cycle_targets ~= 1 or buff.sudden_death.up or target.health_pct < ( talent.massacre.enabled and 35 or 20 ) then return end
                if Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, 5 ) > 0 then return "cycle" end
            end,

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
                if action.condemn.cycle then return true end
                return target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or target.health_pct > 80, "requires > 80% or < " .. ( talent.massacre.enabled and 35 or 20 ) .. "% health"
            end,

            cycle = function ()
                if not settings.cycle or args.cycle_targets ~= 1 or buff.sudden_death.up or target.health_pct < ( talent.massacre.enabled and 35 or 20 ) or target.health_pct > 80 then return end
                if ( Hekili:GetNumTargetsBelowHealthPct( talent.massacre.enabled and 35 or 20, false, 5 ) > 0 or Hekili:GetNumTargetsAboveHealthPct( 80, false, 5 ) > 0 ) then return "cycle" end
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


    spec:RegisterPack( "Arms", 20220226, [[dGKJZaqivI4rIkytqv9jIugLkrDkvkzvOsrELkPzrKClIuf7sWVKQmmkjhJOSmvQEMkLAAIk5AQuSnuPY3evKXrKkNtuPADIkL3Hkf08OuCpPY(ujCquPuluQQhkQOUOkrYgjsv6JOsbojQuOvsuntIuv7Ks1svjs1tfzQIQUQkrkFfvkQXkQq7vYFrYGLYHjTyK6XOmzHUmyZq5ZOQrdvoTQwnQu1RHQmBkUTOSBf)gXWrfhhvkz5k9CitNQRRITJk57eX4Pu68usnFkX(jCjRYxPO6qz)Uv3VB197Cx4US7wDx6QKBnhOsCugEkpuPrZGkXT3muL4OwBiASYxje5SmOs4CNdk361J)DCh6aJK1d9zhJ6pzyRI59qFgRxLOpVX5gNIUsr1HY(DRUF3Q735UWDz3T6EUQKECCKTsPp7yu)jtoVkMxjCFmctrxPiGyvIBVzirJBw39jRqU0lqVhDTw0UFJuI2DRUFxixipNXPdpGYnHCPhr7sJtuDq0WiROL7H7CdfnngfnxxEWfnKeLdNF4fnmYkAxkBb2XHE5mzIq2eeYfYVu2cSJdrrJgWiliAmsgT6IgnW)dkiACBgd44irBiJ0doDZWogrtz(tgKOrgJ1bHCL5pzqbolWiz0QFTRhT6UbOq4ihVsMh5OkFLq)WBakxxEWR8LDzv(kbJsBGy1VsS9DyFTslKP)GenB6enEwSskZFYuPfMy5L97v(kbJsBGy1VsS9DyFTsyppoNAHm9hKODHOjlxwvjL5pzQeJmCRdSKfrrRZaB5L9Bx5RKY8Nmvs5sDDRemkTbIv)Yl75QYxjL5pzQ0QCP8WwjyuAdeR(Lx2VPYxjL5pzQKeDPxqXd2kbJsBGy1V8Yo3v5RKY8NmvIrmee6GOqzkcxLGrPnqS6xEzpNQ8vsz(tMkPd7HXPumhweocdVkbJsBGy1V8YU0v5RKY8NmvcXb0LIGrrRi)jtLGrPnqS6xEzp3R8vcgL2aXQFLy77W(ALy40LhqIwNODVskZFYujcxWYHib2Yl7YSQYxjyuAdeR(vITVd7RvApdGrwEiat8S)WtrBiscWO0gikAwSiA7zamYYdbA1DdyiBmaJsBGOOzXIOrFWWceUGLdrcSbKRm8eTl6eT7vsz(tMkLrwxnuiFF8GYl7YKv5RemkTbIv)kX23H91krFWWcOtmcdveuhxybL5vsz(tMkXiteYMYl7YUx5RemkTbIv)kX23H91krFWWcOtmcdveuhxybL5vsz(tMkb2cSJdLx2LD7kFLGrPnqS6xj2(oSVwPv5HqeWE27I2fIwUUr0Wx0OpyyHiOrJ1um1KfIejtLuM)KPsi8ogdIJ5Dh2Yl7YYvLVsWO0giw9ReBFh2xRe9bdlebnASMIPMSqKizen8fTv5brZgr72wvjL5pzQeTrJaYjBw5LDz3u5RKY8NmvkcA0ynftnzvcgL2aXQF5LDzCxLVskZFYujcxWYHib2kbJsBGy1V8YUSCQYxjL5pzQugzD1qH89XdQemkTbIv)Yl7YKUkFLGrPnqS6xj2(oSVwPfY0FqIMnIw8SQ)Kr04MenRc3UskZFYuPfMy5LDz5ELVsWO0giw9ReBFh2xReIdymuUU8GJcsW9RrYprr7crtwLuM)KPsmdOCbLx2VBvLVsWO0giw9ReBFh2xRKRgy8agSCrwkcgfT6UbcWO0gikAwSiAioGXq56Ydokib3Vgj)efTleTCjAwSiAioGXq56Ydokib3Vgj)efTleT7Ig(Ig9bdlGKaaNF4Pq((4bOqKizQKY8NmvscUFns(jwEz)USkFLGrPnqS6xj2(oSVwPlr0C1aJhWGLlYsrWOOv3nqagL2arrdFr7YI2Q8GODHODJvIMflIweOpyybgXqqOdIcLPiCHdhrZIfr7seT9magz5HamXZ(dpfTHijaJsBGOODRkPm)jtLqgnR8YRueW0JXR8LDzv(kPm)jtLy40LhQemkTbIv)Yl73R8vsz(tMkX5KLbMkbJsBGy1V8Y(TR8vcgL2aXQFLy77W(AL4zXWcz6pirRt0Ss0Wx0Ia9bdlWigccDquOmfHlSqM(ds0Uq0KorZIfrJMGqIg(Ig2ZJZPwit)bjA2iA3VPskZFYujoe)jt5L9Cv5RemkTbIv)kX23H91kfb6dgwGrmee6GOqzkcx4WPskZFYujAdHePWoR1Lx2VPYxjyuAdeR(vITVd7Rvkc0hmSaJyii0brHYueUWcz6pir7crJ7QKY8NmvIgweS49dF5LDURYxjyuAdeR(vITVd7RvIriMirYeYiRRgkKVpEqyHm9hKODHOjlCJOHVOTkpiA2iA3yvLuM)KPs6Y0bOCYUW4Lx2ZPkFLGrPnqS6xj2(oSVwPiqFWWcmIHGqhefktr4crIKr0Wx0yeIjsKmHmY6QHc57Jhewit)bvjL5pzQK55X5ikU)e5ZGXlVSlDv(kbJsBGy1VsS9DyFTsrG(GHfyedbHoikuMIWfoCQKY8Nmvc7xG2qiXYl75ELVsWO0giw9ReBFh2xRueOpyybgXqqOdIcLPiCHdNkPm)jtL0HbiFvdftnMYl7YSQYxjyuAdeR(vITVd7Rvkc0hmSaJyii0brHYueUqKizen8fngHyIejtiJSUAOq((4bHfY0Fqvsz(tMkrR8uemkFFgEOYl7YKv5RemkTbIv)knAgujetxefbJcBvh2rnuiFFmOskZFYujetxefbJcBvh2rnuiFFmO8YUS7v(kPm)jtLoiG6DidvjyuAdeR(Lx2LD7kFLGrPnqS6xj2(oSVwjehWyOCD5bhfKG7xJKFII2fIMmrdFr7YIgJqmrIKjqB0iGCYMfwit)bjAxiAYUr0Syr0C1aJhwLlLh2amkTbII2TQKY8Nmvcjbao)WtH89XdqLx2LLRkFLGrPnqS6xj2(oSVwjxnW4HmfHu2cbyuAdefn8fnxxEWd4a144cCyUOzJOD7BenlwenxxEWd4a144cCyUOzJOD3krZIfrJr4cgD8axW44SEfn8fnxxEWd4a144cCyUODHOjDwjAwSiAmRzgGcJSuGTa74GOzXIOXSMzakmYsXiteYMkH89zEzxwLuM)KPsm1yOuM)KHY8iVsMh5uJMbvcSfyhhkVSl7MkFLGrPnqS6xj2(oSVwPv)ifWfmEqJru4Wr0Syr0qCaJHY1LhCuqcUFns(jkAxiAYQeY3N5LDzvsz(tMkXuJHsz(tgkZJ8kzEKtnAgujCkR8YUmURYxjyuAdeR(vsz(tMkXuJHsz(tgkZJ8kzEKtnAguj0p8gGY1Lh8Yl7YYPkFLuM)KPsC9mNSwtTheUkbJsBGy1V8YUmPRYxjL5pzQ0NXbM4p8uC9mNSwxjyuAdeR(LxEL4SaJKrRELVSlRYxjL5pzQeT6UbOq4ihVsWO0giw9lV8kb2cSJdv(YUSkFLuM)KPsrqJgRPyQjRsWO0giw9lVSFVYxjL5pzQeJmCRdSKfrrRZaBLGrPnqS6xEz)2v(kbJsBGy1VsS9DyFTsioGXq56Ydokib3Vgj)efTortMOHVOXZIHfY0FqIwNOzLOHVODzrBvEq0Uq0YPBenlweTv5br7cr7gRen8fn6dgwybgEgaHgaHchoI2TQKY8NmvIPddmu0hmSkrFWWOgndQeTrJaYjBw5L9Cv5RemkTbIv)kX23H91kXZIHfY0FqIwNOzLOzXIO56YdEW)mGYjuXhenBeT7wvjL5pzQKYL66wEz)MkFLGrPnqS6xjL5pzQeJmriBQeBFh2xRe9bdlOiCWqX9hEEyh94HdhrdFrJ(GHfueoyO4(dppSJE8Wcz6pirZgrJNffn8fngzIN3dkchmuC)HNh2rpEy1bpr7crtwLywZmaLRlp4OYUSYl7CxLVsWO0giw9RKY8NmvcSfyhhQeBFh2xRe9bdlOiCWqX9hEEyh94HdhrdFrJ(GHfueoyO4(dppSJE8Wcz6pirZgrJNffn8fngzIN3dkchmuC)HNh2rpEy1bpr7crtwLywZmaLRlp4OYUSYl75uLVskZFYuPv5s5HTsWO0giw9lVSlDv(kbJsBGy1VsS9DyFTslKP)GenB6enEwu0Wx0USODjIMRgy8GeDPxqXd2amkTbIIg(IgJqmrIKjWigccDquOmfHlSqM(ds0Sr0YLOzXIO5Qbgpirx6fu8GnaJsBGOOHVOXietKizcs0LEbfpydlKP)GenBeTCjA3s0Wx0CD5bp4Fgq5eQ4dI2fIMS7vsz(tMkTWelVSN7v(kPm)jtLKOl9ckEWwjyuAdeR(Lx2LzvLVskZFYujgXqqOdIcLPiCvcgL2aXQF5LDzYQ8vsz(tMkPd7HXPumhweocdVkbJsBGy1V8YUS7v(kPm)jtLqCaDPiyu0kYFYujyuAdeR(Lx2LD7kFLGrPnqS6xjL5pzQeJmriBQeBFh2xR0EgaJS8qa98d4uemkNSzW4qKcVF4rbyuAdefn8fTllARYdHiG9S3fnBeT73iAwSiArG(GHfyedbHoikuMIWfoCen8fTv5br7crlxwjAwSiA0hmSa6eJWqfb1XfwqzUOzXIOrFWWcrqJgRPyQjlC4iA3QsmRzgGY1LhCuzxw5LDz5QYxjyuAdeR(vITVd7RvIHtxEajADI29kPm)jtLiCblhIeylVSl7MkFLGrPnqS6xj2(oSVwjehWyOCD5bhfKG7xJKFII2fIMmrdFrls8qeaousiNjIclKP)GenBenEwSskZFYujMbuUGYl7Y4UkFLGrPnqS6xj2(oSVwPiXdra4qjHCMikSqM(ds0SPt04zrrZIfrBpdGrwEiat8S)WtrBiscWO0gikAwSiA0hmSaHly5qKaBa5kdprRt0UlA4lArG(GHfaB5yiVdBa5kdprRt0UlAwSiA0hmSaT6UbmKngoCQKY8NmvkJSUAOq((4bLx2LLtv(kbJsBGy1VskZFYujgzIq2uj2(oSVwPv5HqeWE27IMnI29Benlwen6dgwicA0ynftnzHdNkXSMzakxxEWrLDzLx2LjDv(kbJsBGy1VsS9DyFTsRYdIMnIwUUPskZFYujeEhJbXX8UdB5LDz5ELVsWO0giw9ReBFh2xRe9bdlebnASMIPMSqKizen8fTllARYdIMnI2DRenlweTlr02ZayKLhcOFWogk0z5HamkTbIIg(I2Q8GOzJODJvI2TQKY8NmvI2Ora5KnR8Y(DRQ8vsz(tMkr4cwoejWwjyuAdeR(Lx2VlRYxjyuAdeR(vsz(tMkXiteYMkXSMzakxxEWrLDzLx2VFVYxjyuAdeR(vsz(tMkb2cSJdvIznZauUU8GJk7YkV8kHtzv(YUSkFLGrPnqS6xj2(oSVwPv5brZgrJ7Ss0Wx0OpyyHiOrJ1um1KfIejtLuM)KPsi8ogdIJ5Dh2Yl73R8vsz(tMkXid36alzru06mWwjyuAdeR(Lx2VDLVsWO0giw9ReBFh2xReJqmrIKjWigccDquOmfHlSqM(ds0Sr0KvjL5pzQKYL66wEzpxv(kPm)jtLKOl9ckEWwjyuAdeR(Lx2VPYxjL5pzQeJyii0brHYueUkbJsBGy1V8Yo3v5RemkTbIv)kX23H91kfjEicahkjKZerHfY0FqIMnDIgplwjL5pzQeZakxq5L9CQYxjL5pzQKoShgNsXCyr4im8QemkTbIv)Yl7sxLVskZFYujehqxkcgfTI8NmvcgL2aXQF5L9CVYxjL5pzQeTrJaYjBwLGrPnqS6xEzxMvv(kPm)jtLwLlLh2kbJsBGy1V8YUmzv(kbJsBGy1VsS9DyFTslKP)GenB6eT4zv)jJOXnjAwfUTOHVOrFWWcijaW5hEkKVpEakC4ujL5pzQ0ctS8YUS7v(kPm)jtLygq5cQemkTbIv)Yl7YUDLVsWO0giw9ReBFh2xRe9bdlGKaaNF4Pq((4bOWHJOzXIOfjEicahkjKZerHfY0FqIMnIgplkA4lAxIO5QbgpWmGYfeGrPnqSskZFYuPmY6QHc57JhuEzxwUQ8vcgL2aXQFLy77W(ALC1aJhIlOXrp848amkTbIvsz(tMkr4cwoejWwEzx2nv(kbJsBGy1VskZFYujgzIq2uj2(oSVwj6dgwajbao)WtH89XdqHdhrZIfrJ(GHfqNyegQiOoUWHtLywZmaLRlp4OYUSYl7Y4UkFLGrPnqS6xjL5pzQeylWoouj2(oSVwj6dgwajbao)WtH89XdqHdhrZIfrJ(GHfqNyegQiOoUWHtLywZmaLRlp4OYUSYl7YYPkFLuM)KPseUGLdrcSvcgL2aXQF5LDzsxLVskZFYujj4(1i5NyLGrPnqS6xE5LxjUGf9KPSF3Q7YSkNKL7vsIUZp8OkXnZTV0TZnANBqUjAIwECGO9zCiRlAyKv0Kg6hEdq56YdU0eTf4wNFHOOHizGOPhNKPoefngoD4buqix6)diAYSk3eTCMmCbRdrrtA7zamYYdHCuAIMtenPTNbWilpeYXamkTbIst0USmBVvqix6)diAYSk3eTCMmCbRdrrtA7zamYYdHCuAIMtenPTNbWilpeYXamkTbIst0USmBVvqix6)diA3LLBIwotgUG1HOOjT9magz5HqoknrZjIM02ZayKLhc5yagL2arPjAxwMT3kiKlKZnZTV0TZnANBqUjAIwECGO9zCiRlAyKv0KgylWooinrBbU15xikAisgiA6XjzQdrrJHthEafeYL()aIMSBNBIwotgUG1HOOjT9magz5HqoknrZjIM02ZayKLhc5yagL2arPjAxwMT3kiKl9)benzCxUjA5mz4cwhIIM02ZayKLhc5O0enNiAsBpdGrwEiKJbyuAdeLMODzz2ERGqU0)hq0KL75MOLZKHlyDikAsBpdGrwEiKJst0CIOjT9magz5HqogGrPnquAI2LLz7Tcc5c5CJzCiRdrr7grtz(tgrZ8ihfeYReNLG9gOs5qoiAC7ndjACZ6UpzfYZHCq0KEb69OR1I29BKs0UB197c5c55qoiA5moD4buUjKNd5GOj9iAxACIQdIggzfTCpCNBOOPXOO56YdUOHKOC48dVOHrwr7szlWoo0lNjteYMGqUqEoKdI2LYwGDCikA0agzbrJrYOvx0Ob(FqbrJBZyahhjAdzKEWPBg2XiAkZFYGenYySoiKRm)jdkWzbgjJw9RD9Ov3nafch54c5c55qoiAxkBb2XHOObCbR1IM)zGO54artzozfThjAkx6BuAdeeYvM)Kb1XWPlpiKRm)jd6AxpoNSmWiKRm)jd6Axpoe)jJupwhplgwit)b1zf(rG(GHfyedbHoikuMIWfwit)bDH0zXcnbHWh75X5ulKP)GS5(nc5kZFYGU21J2qirkSZATupwxeOpyybgXqqOdIcLPiCHdhHCL5pzqx76rdlcw8(HxQhRlc0hmSaJyii0brHYueUWcz6pOl4oHCL5pzqx76PlthGYj7cJl1J1XietKizczK1vdfY3hpiSqM(d6czHBWFvEWMBSsixz(tg01UEMNhNJO4(tKpdgxQhRlc0hmSaJyii0brHYueUqKizWNriMirYeYiRRgkKVpEqyHm9hKqUY8NmORD9W(fOnesuQhRlc0hmSaJyii0brHYueUWHJqUY8NmORD90HbiFvdftngPESUiqFWWcmIHGqhefktr4choc5kZFYGU21Jw5Piyu((m8qs9yDrG(GHfyedbHoikuMIWfIejd(mcXejsMqgzD1qH89XdclKP)GeYvM)KbDTR3bbuVdzsnAg0Hy6IOiyuyR6WoQHc57Jbc5kZFYGU217GaQ3HmKqUY8NmORD9qsaGZp8uiFF8aKupwhIdymuUU8GJcsW9RrYpXlKH)LzeIjsKmbAJgbKt2SWcz6pOlKDJflUAGXdRYLYdBagL2aXBjKRm)jd6AxpMAmukZFYqzEKl1OzqhylWooifY3N5DYK6X6C1aJhYueszleGrPnqeFxxEWd4a144cCyUn3(glwCD5bpGduJJlWH52C3klwyeUGrhpWfmooRx8DD5bpGduJJlWH5xiDwzXcZAMbOWilfylWooyXcZAMbOWilfJmriBeYvM)KbDTRhtngkL5pzOmpYLA0mOdNYKc57Z8ozs9yDR(rkGly8GgJOWHJflioGXq56Ydokib3Vgj)eVqMqUY8NmORD9yQXqPm)jdL5rUuJMbDOF4naLRlp4c5kZFYGU21JRN5K1AQ9GWjKRm)jd6AxVpJdmXF4P46zozTwixixz(tguaSfyhh6IGgnwtXutMqUY8NmOaylWooCTRhJmCRdSKfrrRZaRqUY8NmOaylWooCTRhthgyOOpyysnAg0rB0iGCYMj1J1H4agdLRlp4OGeC)AK8tStg(8SyyHm9huNv4F5v5HlYPBSyzvE4IBScF6dgwybgEgaHgaHcho3sixz(tguaSfyhhU21t5sDDL6X64zXWcz6pOoRSyX1Lh8G)zaLtOIpyZDReYvM)KbfaBb2XHRD9yKjczJumRzgGY1LhCuNmPESo6dgwqr4GHI7p88Wo6Xdho4tFWWckchmuC)HNh2rpEyHm9hKn8Si(mYepVhueoyO4(dppSJE8WQdExitixz(tguaSfyhhU21dSfyhhKIznZauUU8GJ6Kj1J1rFWWckchmuC)HNh2rpE4WbF6dgwqr4GHI7p88Wo6XdlKP)GSHNfXNrM459GIWbdf3F45HD0JhwDW7czc5kZFYGcGTa74W1UERYLYdRqUY8NmOaylWooCTR3ctuQhRBHm9hKnD8Si(x(sC1aJhKOl9ckEWgGrPnqeFgHyIejtGrmee6GOqzkcxyHm9hKn5YIfxnW4bj6sVGIhSbyuAdeXNriMirYeKOl9ckEWgwit)bztUUf(UU8Gh8pdOCcv8HlKDxixz(tguaSfyhhU21tIU0lO4bRqUY8NmOaylWooCTRhJyii0brHYueoHCL5pzqbWwGDC4AxpDypmoLI5WIWry4jKRm)jdka2cSJdx76H4a6srWOOvK)Krixz(tguaSfyhhU21JrMiKnsXSMzakxxEWrDYK6X62ZayKLhcONFaNIGr5KndghIu49dpc)lVkpeIa2ZE3M73yXseOpyybgXqqOdIcLPiCHdh8xLhUixwzXc9bdlGoXimurqDCHfuMBXc9bdlebnASMIPMSWHZTeYvM)KbfaBb2XHRD9iCblhIeyL6X6y40LhqD3fYvM)KbfaBb2XHRD9ygq5cK6X6qCaJHY1LhCuqcUFns(jEHm8JepebGdLeYzIOWcz6piB4zrHCL5pzqbWwGDC4AxVmY6QHc57Jhi1J1fjEicahkjKZerHfY0Fq20XZIwSSNbWilpeGjE2F4POnejwSqFWWceUGLdrcSbKRm86UJFeOpyybWwogY7WgqUYWR7Ufl0hmSaT6UbmKngoCeYvM)KbfaBb2XHRD9yKjczJumRzgGY1LhCuNmPESUv5HqeWE272C)glwOpyyHiOrJ1um1KfoCeYvM)KbfaBb2XHRD9q4DmgehZ7oSs9yDRYd2KRBeYvM)KbfaBb2XHRD9OnAeqozZK6X6OpyyHiOrJ1um1KfIejd(xEvEWM7wzXYLSNbWilpeq)GDmuOZYd4VkpyZnwDlHCL5pzqbWwGDC4AxpcxWYHibwHCL5pzqbWwGDC4AxpgzIq2ifZAMbOCD5bh1jtixz(tguaSfyhhU21dSfyhhKIznZauUU8GJ6KjKlKRm)jdkGtzDi8ogdIJ5DhwPESUv5bB4oRWN(GHfIGgnwtXutwisKmc5kZFYGc4u21UEmYWToWswefTodSc5kZFYGc4u21UEkxQRRupwhJqmrIKjWigccDquOmfHlSqM(dYgzc5kZFYGc4u21UEs0LEbfpyfYvM)KbfWPSRD9yedbHoikuMIWjKRm)jdkGtzx76XmGYfi1J1fjEicahkjKZerHfY0Fq20XZIc5kZFYGc4u21UE6WEyCkfZHfHJWWtixz(tguaNYU21dXb0LIGrrRi)jJqUY8NmOaoLDTRhTrJaYjBMqUY8NmOaoLDTR3QCP8WkKRm)jdkGtzx76TWeL6X6wit)bztx8SQ)KHBYQWTXN(GHfqsaGZp8uiFF8au4Wrixz(tguaNYU21JzaLlqixz(tguaNYU21lJSUAOq((4bs9yD0hmSascaC(HNc57JhGchowSejEicahkjKZerHfY0Fq2WZI4FjUAGXdmdOCbbyuAdefYvM)KbfWPSRD9iCblhIeyL6X6C1aJhIlOXrp848amkTbIc5kZFYGc4u21UEmYeHSrkM1mdq56YdoQtMupwh9bdlGKaaNF4Pq((4bOWHJfl0hmSa6eJWqfb1XfoCeYvM)KbfWPSRD9aBb2XbPywZmaLRlp4Oozs9yD0hmSascaC(HNc57JhGchowSqFWWcOtmcdveuhx4Wrixz(tguaNYU21JWfSCisGvixz(tguaNYU21tcUFns(jkKlKRm)jdkG(H3auUU8G3TWeL6X6wit)bzthplkKRm)jdkG(H3auUU8GFTRhJmCRdSKfrrRZaRupwh2ZJZPwit)bDHSCzLqUY8NmOa6hEdq56Yd(1UEkxQRRqUY8NmOa6hEdq56Yd(1UERYLYdRqUY8NmOa6hEdq56Yd(1UEs0LEbfpyfYvM)Kbfq)WBakxxEWV21Jrmee6GOqzkcNqUY8NmOa6hEdq56Yd(1UE6WEyCkfZHfHJWWtixz(tgua9dVbOCD5b)AxpehqxkcgfTI8Nmc5kZFYGcOF4naLRlp4x76r4cwoejWk1J1XWPlpG6UlKRm)jdkG(H3auUU8GFTRxgzD1qH89XdK6X62ZayKLhcWep7p8u0gIelw2ZayKLhc0Q7gWq2Ofl0hmSaHly5qKaBa5kdVl6UlKRm)jdkG(H3auUU8GFTRhJmriBK6X6Opyyb0jgHHkcQJlSGYCHCL5pzqb0p8gGY1Lh8RD9aBb2XbPESo6dgwaDIryOIG64clOmxixz(tgua9dVbOCD5b)AxpeEhJbXX8UdRupw3Q8qicyp79lY1n4tFWWcrqJgRPyQjlejsgHCL5pzqb0p8gGY1Lh8RD9OnAeqozZK6X6OpyyHiOrJ1um1KfIejd(RYd2CBReYvM)Kbfq)WBakxxEWV21lcA0ynftnzc5kZFYGcOF4naLRlp4x76r4cwoejWkKRm)jdkG(H3auUU8GFTRxgzD1qH89XdeYvM)Kbfq)WBakxxEWV21BHjk1J1TqM(dYM4zv)jd3KvHBlKRm)jdkG(H3auUU8GFTRhZakxGupwhIdymuUU8GJcsW9RrYpXlKjKRm)jdkG(H3auUU8GFTRNeC)AK8tuQhRZvdmEadwUilfbJIwD3abyuAdeTybXbmgkxxEWrbj4(1i5N4f5YIfehWyOCD5bhfKG7xJKFIxChF6dgwajbao)WtH89XdqHirYiKRm)jdkG(H3auUU8GFTRhYOzs9yDxIRgy8agSCrwkcgfT6UbcWO0giI)LxLhU4gRSyjc0hmSaJyii0brHYueUWHJflxYEgaJS8qaM4z)HNI2qKCRkH4aSYEojR8YRca]] )


end
