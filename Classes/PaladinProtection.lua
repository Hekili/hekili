-- PaladinProtection.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


local PTR = ns.PTR


-- Conduits
-- [-] punish_the_guilty
-- [x] vengeful_shock

-- Covenant
-- [-] ringing_clarity
-- [-] hallowed_discernment
-- [-] righteous_might
-- [x] the_long_summer

-- Endurance
-- [-] divine_call
-- [-] golden_path
-- [x] shielding_words

-- Protection Endurance
-- [x] resolute_defender
-- [x] royal_decree

-- Finesse
-- [ ] echoing_blessings -- NYI: auras not identified
-- [x] lights_barding
-- [-] pure_concentration
-- [x] wrench_evil


if UnitClassBase( "player" ) == "PALADIN" then
    local spec = Hekili:NewSpecialization( 66 )

    spec:RegisterResource( Enum.PowerType.HolyPower )
    spec:RegisterResource( Enum.PowerType.Mana )

    -- Talents
    spec:RegisterTalents( {
        holy_shield = 22428, -- 152261
        redoubt = 22558, -- 280373
        blessed_hammer = 23469, -- 204019

        first_avenger = 22431, -- 203776
        crusaders_judgment = 22604, -- 204023
        moment_of_glory = 23468, -- 327193

        fist_of_justice = 22179, -- 234299
        repentance = 22180, -- 20066
        blinding_light = 21811, -- 115750

        unbreakable_spirit = 22433, -- 114154
        cavalier = 22434, -- 230332
        blessing_of_spellwarding = 22435, -- 204018

        divine_purpose = 17597, -- 223817
        holy_avenger = 17599, -- 105809
        seraphim = 17601, -- 152262

        hand_of_the_protector = 17601, -- 213652
        consecrated_ground = 22438, -- 204054
        judgment_of_light = 22189, -- 183778

        sanctified_wrath = 23457, -- 171648
        righteous_protector = 21202, -- 204074
        final_stand = 22645, -- 204077
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( {
        cleansing_light = 3472, -- 236186
        guarded_by_the_light = 97, -- 216855
        guardian_of_the_forgotten_queen = 94, -- 228049
        hallowed_ground = 90, -- 216868
        inquisition = 844, -- 207028
        judgments_of_the_pure = 93, -- 216860
        luminescence = 3474, -- 199428
        sacred_duty = 92, -- 216853
        shield_of_virtue = 861, -- 215652
        steed_of_glory = 91, -- 199542
        unbound_freedom = 3475, -- 305394
        warrior_of_light = 860, -- 210341
    } )

    -- Auras
    spec:RegisterAuras( {
        ardent_defender = {
            id = 31850,
            duration = 8,
            max_stack = 1,
        },
        avengers_shield = {
            id = 31935,
            duration = 3,
            type = "Magic",
            max_stack = 1,
        },
        avenging_wrath = {
            id = 31884,
            duration = function () return ( talent.sanctified_wrath.enabled and 1.25 or 1 ) * ( azerite.lights_decree.enabled and 25 or 20 ) end,
            max_stack = 1,
        },
        blessed_hammer = {
            id = 204301,
            duration = 10,
            max_stack = 1,
        },
        blessing_of_freedom = {
            id = 1044,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        blessing_of_protection = {
            id = 1022,
            duration = 10,
            max_stack = 1,
            type = "Magic",
        },
        blessing_of_sacrifice = {
            id = 6940,
            duration = 12,
            max_stack = 1,
            type = "Magic",
        },
        blessing_of_spellwarding = {
            id = 204018,
            duration = 10,
            type = "Magic",
            max_stack = 1,
        },
        blinding_light = {
            id = 105421,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        concentration_aura = {
            id = 317920,
            duration = 3600,
            max_stack = 1,
        },
        consecration = {
            id = 188370,
            duration = 12,
            max_stack = 1,
            generate = function( c, type )
                if type == "buff" and FindUnitBuffByID( "player", 188370 ) then
                    local dropped, expires

                    for i = 1, 5 do
                        local up, name, start, duration = GetTotemInfo( i )

                        if up and name == class.abilities.consecration.name then
                            dropped = start
                            expires = dropped + duration
                            break
                        end
                    end

                    if dropped and expires > query_time then
                        c.expires = expires
                        c.applied = dropped
                    c.count = 1
                    c.caster = "player"
                    return
                end
                end

                c.count = 0
                c.expires = 0
                c.applied = 0
                c.caster = "unknown"
            end
        },
        consecration_dot = {
            id = 204242,
            duration = 12,
            max_stack = 1,
        },
        devotion_aura = {
            id = 465,
            duration = 3600,
            max_stack = 1,
        },
        divine_purpose = {
            id = 223819,
            duration = 12,
            max_stack = 1,
        },
        divine_shield = {
            id = 642,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        divine_steed = {
            id = 221886,
            duration = function () return 3 * ( 1 + ( conduit.lights_barding.mod * 0.01 ) ) end,
            max_stack = 1,
        },
        final_stand = {
            id = 204079,
            duration = 8,
            max_stack = 1,
        },
        first_avenger = {
            id = 327225,
            duration = 8,
            max_stack = 1,
        },
        forbearance = {
            id = 25771,
            duration = 30,
            max_stack = 1,
        },
        grand_crusader = {
            id = 85043,
        },
        guardian_of_ancient_kings = {
            id = 86659,
            duration = 8,
            max_stack = 1,
        },
        hammer_of_justice = {
            id = 853,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        hand_of_reckoning = {
            id = 62124,
            duration = 3,
            max_stack = 1,
        },
        holy_avenger = {
            id = 105809,
            duration = 20,
            max_stack = 1,
        },
        judgment = {
            id = 197277,
            duration = 15,
            max_stack = 1,
        },
        judgment_of_light = {
            id = 196941,
            duration = 30,
            max_stack = 25,
        },
        moment_of_glory = {
            id = 327193,
            duration = 15,
            max_stack = 3,
        },
        redoubt = {
            id = 280375,
            duration = 10,
            max_stack = 3,
        },
        repentance = {
            id = 20066,
            duration = 6,
            max_stack = 1,
        },
        retribution_aura = {
            id = 183435,
            duration = 3600,
            max_stack = 1,
        },
        seraphim = {
            id = 152262,
            duration = 16,
            max_stack = 1,
        },
        shield_of_the_righteous = {
            id = 132403,
            duration = 4.5,
            max_stack = 1,
        },
        shining_light = {
            id = 182104,
            duration = 15,
            max_stack = 5,
        },
        -- TODO: Check SimC implementation if they bother.
        shining_light_full = {
            id = 327510,
            duration = 15,
            max_stack = 1
        },
        turn_evil = {
            id = 10326,
            duration = 40,
            max_stack = 1
        },


        -- Azerite Powers
        empyreal_ward = {
            id = 287731,
            duration = 60,
            max_stack = 1,
        },

    } )


    -- Legendaries
    -- Vanguard's Momentum
    -- Badge of the Mad Paragon
    -- Final Verdict
    -- From Dusk till Dawn
    -- The Magistrate's Judgment


    -- Conduits
    -- Ringing Clarity
    -- Vengeful Shock
    -- Focused Light
    -- Light's Reach
    -- Templar's Vindication
    -- The Long Summer
    -- Truth's Wake
    -- Virtuous Command
    -- Righteous Might
    -- Hallowed Discernment
    -- Punish the Guilty


    -- Gear Sets
    spec:RegisterGear( "tier19", 138350, 138353, 138356, 138359, 138362, 138369 )
    spec:RegisterGear( "tier20", 147160, 147162, 147158, 147157, 147159, 147161 )
        spec:RegisterAura( "sacred_judgment", {
            id = 246973,
            duration = 8,
            max_stack = 1,
        } )

    spec:RegisterGear( "tier21", 152151, 152153, 152149, 152148, 152150, 152152 )
    spec:RegisterGear( "class", 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )

    spec:RegisterGear( "breastplate_of_the_golden_valkyr", 137017 )
    spec:RegisterGear( "heathcliffs_immortality", 137047 )
    spec:RegisterGear( "justice_gaze", 137065 )
    spec:RegisterGear( "saruans_resolve", 144275 )
    spec:RegisterGear( "tyelca_ferren_marcuss_stature", 137070 )
    spec:RegisterGear( "tyrs_hand_of_faith", 137059 )
    spec:RegisterGear( "uthers_guard", 137105 )

    spec:RegisterGear( "soul_of_the_highlord", 151644 )
    spec:RegisterGear( "pillars_of_inmost_light", 151812 )


    spec:RegisterStateExpr( "last_consecration", function () return action.consecration.lastCast end )
    spec:RegisterStateExpr( "last_blessed_hammer", function () return action.blessed_hammer.lastCast end )
    spec:RegisterStateExpr( "last_shield", function () return action.shield_of_the_righteous.lastCast end )

    spec:RegisterStateExpr( "consecration", function () return buff.consecration end )

    spec:RegisterHook( "reset_precast", function ()
        last_consecration = nil
        last_blessed_hammer = nil
        last_shield = nil
    end )


    spec:RegisterHook( "spend", function( amt, resource )
        if amt > 0 and resource == "holy_power" then
            if talent.righteous_protector.enabled then
                reduceCooldown( "avenging_wrath", amt )
                reduceCooldown( "guardian_of_ancient_kings", amt )
            end
            if talent.fist_of_justice.enabled then
                reduceCooldown( "hammer_of_justice", 2 * amt )
            end
            if legendary.uthers_devotion.enabled then
                setCooldown( "blessing_of_freedom", max( 0, cooldown.blessing_of_freedom.remains - 1 ) )
                setCooldown( "blessing_of_protection", max( 0, cooldown.blessing_of_protection.remains - 1 ) )
                setCooldown( "blessing_of_sacrifice", max( 0, cooldown.blessing_of_sacrifice.remains - 1 ) )
                setCooldown( "blessing_of_spellwarding", max( 0, cooldown.blessing_of_spellwarding.remains - 1 ) )
            end
            if legendary.relentless_inquisitor.enabled then
                addStack( "relentless_inquisitor", nil, amt )
            end
            if legendary.of_dusk_and_dawn.enabled and holy_power.current == 0 then applyBuff( "blessing_of_dusk" ) end
        end
    end )


    spec:RegisterHook( "gain", function( amt, resource, overcap )
        if legendary.of_dusk_and_dawn.enabled and amt > 0 and resource == "holy_power" and holy_power.current == 5 then
            applyBuff( "blessing_of_dawn" )
        end
    end )


    -- Abilities
    spec:RegisterAbilities( {
        ardent_defender = {
            id = 31850,
            cast = 0,
            cooldown = function ()
                return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 120 end,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 135870,

            handler = function ()
                applyBuff( "ardent_defender" )
            end,
        },


        avengers_shield = {
            id = 31935,
            cast = 0,
            cooldown = function () return buff.moment_of_glory.up and 0 or 15 end,
            gcd = "spell",

            interrupt = true,

            startsCombat = true,
            texture = 135874,

            handler = function ()
                applyDebuff( "target", "avengers_shield" )
                interrupt()

                removeStack( "moment_of_glory", nil, 1 )

                if talent.first_avenger.enabled then
                    applyBuff( "first_avenger" )
                end

                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )

                if conduit.vengeful_shock.enabled then applyDebuff( "target", "vengeful_shock" ) end

                if legendary.bulwark_of_righteous_fury.enabled then
                    addStack( "bulwark_of_righteous_fury", nil, min( 5, active_enemies ) )
                end
            end,

            auras = {
                -- Conduit
                vengeful_shock = {
                    id = 340007,
                    duration = 5,
                    max_stack = 1
                }
            }
        },


        avenging_wrath = {
            id = 31884,
            cast = 0,
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "off",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135875,

            handler = function ()
                applyBuff( "avenging_wrath" )
            end,
        },


        blessed_hammer = {
            id = 204019,
            cast = 0,
            charges = 3,
            cooldown = 6,
            recharge = 6,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 535595,

            talent = "blessed_hammer",

            handler = function ()
                applyDebuff( "target", "blessed_hammer" )
                last_blessed_hammer = query_time

                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            end,
        },


        blessing_of_freedom = {
            id = 1044,
            cast = 0,
            cooldown = 25,
            gcd = "spell",

            spend = 0.07,
            spendType = "mana",

            startsCombat = false,
            texture = 135968,

            handler = function ()
                applyBuff( "blessing_of_freedom" )
            end,
        },


        blessing_of_protection = {
            id = 1022,
            cast = 0,
            cooldown = 300,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 135964,

            notalent = "blessing_of_spellwarding",
            nodebuff = "forbearance",

            handler = function ()
                applyBuff( "blessing_of_protection" )
                applyDebuff( "player", "forbearance" )
            end,
        },


        blessing_of_sacrifice = {
            id = 6940,
            cast = 0,
            cooldown = 120,
            gcd = "off",

            spend = 0.07,
            spendType = "mana",

            defensives = true,

            startsCombat = false,
            texture = 135966,

            handler = function ()
                applyBuff( "blessing_of_sacrifice" )
            end,
        },


        blessing_of_spellwarding = {
            id = 204018,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            defensives = true,

            startsCombat = false,
            texture = 135880,

            talent = "blessing_of_spellwarding",
            nodebuff = "forbearance",

            handler = function ()
                applyBuff( "blessing_of_spellwarding" )
                applyDebuff( "player", "forbearance" )
            end,
        },


        blinding_light = {
            id = 115750,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "interrupts",

            spend = 0.06,
            spendType = "mana",

            interrupt = true,

            startsCombat = true,
            texture = 571553,

            talent = "blinding_light",

            usable = function () return target.casting end,
            readyTime = function () return debuff.casting.up and ( debuff.casting.remains - 0.5 ) or 3600 end,
            handler = function ()
                interrupt()
                applyDebuff( "target", "blinding_light" )
                active_dot.blinding_light = max( active_enemies, active_dot.blinding_light )
            end,
        },


        cleanse_toxins = {
            id = 213644,
            cast = 0,
            charges = 1,
            cooldown = 8,
            recharge = 8,
            gcd = "spell",

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 135953,

            usable = function ()
                return buff.dispellable_poison.up or buff.dispellable_disease.up, "requires poison or disease"
            end,

            handler = function ()
                removeBuff( "dispellable_poison" )
                removeBuff( "dispellable_disease" )
            end,
        },


        consecration = {
            id = 26573,
            cast = 0,
            cooldown = 9,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 135926,

            handler = function ()
                applyBuff( "consecration" )
                applyDebuff( "target", "consecration_dot" )
                last_consecration = query_time
            end,
        },


        crusader_aura = {
            id = 32223,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 135890,

            handler = function ()
                removeBuff( "concentration_aura" )
                removeBuff( "devotion_aura" )
                removeBuff( "retribution_aura" )
                applyBuff( "crusader_aura" )
            end,
        },


        devotion_aura = {
            id = 465,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = true,
            texture = 135893,

            handler = function ()
                removeBuff( "concentration_aura" )
                removeBuff( "crusader_aura" )
                removeBuff( "retribution_aura" )
                applyBuff( "devotion_aura" )
            end,
        },


        divine_shield = {
            id = 642,
            cast = 0,
            cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 300 end,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 524354,

            nodebuff = "forbearance",

            handler = function ()
                applyBuff( "divine_shield" )
                applyDebuff( "player", "forbearance" )

                if talent.final_stand.enabled then
                    applyDebuff( "target", "final_stand" )
                    active_dot.final_stand = min( active_dot.final_stand, active_enemies )
                end
            end,
        },


        divine_steed = {
            id = 190784,
            cast = 0,
            charges = function () return talent.cavalier.enabled and 2 or nil end,
            cooldown = 45,
            recharge = function () return talent.cavalier.enabled and 45 or nil end,
            gcd = "spell",

            startsCombat = false,
            texture = 1360759,

            handler = function ()
                applyBuff( "divine_steed" )
            end,
        },


        flash_of_light = {
            id = 19750,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",

            spend = 0.22,
            spendType = "mana",

            startsCombat = false,
            texture = 135907,

            handler = function ()
                gain( 1.67 * 1.68 * ( 1 + stat.versatility_atk_mod ) * stat.spell_power, "health" )
            end,
        },


        guardian_of_ancient_kings = {
            id = 86659,
            cast = 0,
            cooldown = function () return 300 - ( conduit.royal_decree.mod * 0.001 ) end,
            gcd = "off",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 135919,

            handler = function ()
                applyBuff( "guardian_of_ancient_kings" )
                if conduit.royal_decree.enabled then applyBuff( "royal_decree" ) end
            end,

            auras = {
                -- Conduit
                royal_decree = {
                    id = 340147,
                    duration = 15,
                    max_stack = 1
                }
            }
        },


        hammer_of_justice = {
            id = 853,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 135963,

            handler = function ()
                applyDebuff( "target", "hammer_of_justice" )
            end,
        },


        hammer_of_the_righteous = {
            id = 53595,
            cast = 0,
            charges = 2,
            cooldown = 6,
            recharge = 6,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 236253,

            notalent = "blessed_hammer",

            handler = function ()
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            end,
        },




        hammer_of_wrath = {
            id = 24275,
            cast = 0,
            cooldown = 7.5,
            gcd = "spell",

            startsCombat = true,
            texture = 613533,

            usable = function () return target.health_pct < 20 or ( level > 57 and buff.avenging_wrath.up ) or buff.hammer_of_wrath_hallow.up, "requires low health, avenging_wrath, or ashen_hallow" end,
            handler = function ()
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )

                if legendary.the_mad_paragon.enabled then
                    if buff.avenging_wrath.up then buff.avenging_wrath.expires = buff.avenging_wrath.expires + 1 end
                    if buff.crusade.up then buff.crusade.expires = buff.crusade.expires + 1 end
                end
            end,
        },


        hand_of_reckoning = {
            id = 62124,
            cast = 0,
            charges = 1,
            cooldown = 8,
            recharge = 8,
            gcd = "off",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135984,

            handler = function ()
                applyDebuff( "target", "hand_of_reckoning" )
            end,
        },


        holy_avenger = {
            id = 105809,
            cast = 0,
            cooldown = 180,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 571555,

            talent = "holy_avenger",

            handler = function ()
                applyBuff( "holy_avenger" )
            end,
        },


        judgment = {
            id = 275779,
            cast = 0,
            charges = function ()
                local c = 1
                if talent.crusaders_judgment.enabled then c = c + 1 end
                if buff.grand_crusader.up then c = c + 1 end
                return c > 1 and c or nil
            end,
            cooldown = 6,
            recharge = 6,
            hasteCD = true,
            gcd = "spell",

            spend = 0.03,
            spendType = "mana",

            startsCombat = true,
            texture = 135959,

            handler = function ()
                applyDebuff( "target", "judgment" )
                gain( ( buff.holy_avenger.up and 3 or 1 ) + ( buff.avenging_wrath.up and talent.sanctified_wrath.enabled and 1 or 0 ), "holy_power" )

                if talent.judgment_of_light.enabled then applyDebuff( "target", "judgment_of_light", nil, 25 ) end

                if talent.fist_of_justice.enabled then
                    cooldown.hammer_of_justice.expires = max( 0, cooldown.hammer_of_justice.expires - 6 )
                end
            end,
        },


        lay_on_hands = {
            id = 633,
            cast = 0,
            cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 600 end,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 135928,

            nodebuff = "forbearance",

            handler = function ()
                gain( health.max, "health" )
                applyDebuff( "player", "forbearance" )
                if azerite.empyreal_ward.enabled then applyBuff( "empyrael_ward" ) end
            end,
        },


        moment_of_glory = {
            id = 327193,
            cast = 0,
            cooldown = 90,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = true,
            texture = 589117,

            talent = "moment_of_glory",

            handler = function ()
                setCooldown( "avengers_shield", 0 )
                applyBuff( "moment_of_glory", nil, 3 )
            end,
        },


        rebuke = {
            id = 96231,
            cast = 0,
            cooldown = 15,
            gcd = "off",

            startsCombat = true,
            texture = 523893,

            toggle = "interrupts",

            debuff = "casting",
            readyTime = state.timeToInterrupt,

            handler = function ()
                interrupt()
            end,
        },


        --[[ redemption = {
            id = 7328,
            cast = 10,
            cooldown = 0,
            gcd = "spell",

            spend = 0.04,
            spendType = "mana",

            startsCombat = true,
            texture = 135955,

            handler = function ()
            end,
        }, ]]


        repentance = {
            id = 20066,
            cast = 1.7,
            cooldown = 15,
            gcd = "spell",

            interrupt = true,

            spend = 0.06,
            spendType = "mana",

            startsCombat = false,
            texture = 135942,

            handler = function ()
                applyDebuff( "target", "repentance" )
            end,
        },


        retribution_aura = {
            id = 183435,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            startsCombat = false,
            texture = 135889,

            handler = function ()
                removeBuff( "concentration_aura" )
                removeBuff( "crusader_aura" )
                removeBuff( "devotion_aura" )
                applyBuff( "retribution_aura" )
            end,
        },

        seraphim = {
            id = 152262,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3 - ( buff.the_magistrates_judgment.up and 1 or 0 )
            end,
            spendType = "holy_power",

            startsCombat = false,
            texture = 1030103,

            talent = "seraphim",

            handler = function ()
                removeBuff( "divine_purpose" )
                removeBuff( "the_magistrates_judgment" )
                local used = min( 2, cooldown.shield_of_the_righteous.charges )
                applyBuff( "seraphim", used * 8 )
            end,
        },


        shield_of_the_righteous = {
            id = 53600,
            cast = 0,
            cooldown = 1,
            icd = 1,
            gcd = "off",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 3 - ( buff.the_magistrates_judgment.up and 1 or 0 )
            end,
            spendType = "holy_power",

            defensives = true,

            startsCombat = true,
            texture = 236265,

            handler = function ()
                if talent.redoubt.enabled then addStack( "redoubt", nil, 3 ) end

                removeBuff( "bulwark_of_righteous_fury" )
                removeBuff( "divine_purpose" )
                removeBuff( "the_magistrates_judgment" )

                if buff.shining_light_full.up then applyBuff( "shining_light_full" )
                else
                    addStack( "shining_light", nil, 1 )
                    if buff.shining_light.stack == 5 then
                        applyBuff( "shining_light_full" )
                        removeBuff( "shining_light" )
                    end
                end

                applyBuff( "shield_of_the_righteous", buff.shield_of_the_righteous.remains + 4.5 )
                last_shield = query_time

                if conduit.resolute_defender.enabled and buff.ardent_defender.up then
                    buff.ardent_defender.expires = buff.ardent_defender.expires + ( buff.ardent_defender.duration * ( conduit.resolute_defender.mod * 0.01 ) )
                end
            end,
        },


        turn_evil = {
            id = 10326,
            cast = function () return 1.5 * ( 1 + ( conduit.wrench_evil.mod * 0.01 ) ) end,
            cooldown = 15,
            gcd = "spell",

            spend = 0.1,
            spendType = "mana",

            startsCombat = true,
            texture = 571559,

            handler = function ()
                applyDebuff( "turn_evil" )
            end,
        },


        word_of_glory = {
            id = 85673,
            cast = 0,
            cooldown = 0,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up or buff.shining_light.stack == 5 or buff.royal_decree.up then return 0 end
                return 3 - ( buff.the_magistrates_judgment.up and 1 or 0 )
            end,
            spendType = "holy_power",

            startsCombat = false,
            texture = 133192,

            handler = function ()
                if buff.royal_decree.up then removeBuff( "royal_decree" )
                elseif buff.divine_purpose.up then removeBuff( "divine_purpose" )
                else removeBuff( "shining_light_full" ) end

                removeBuff( "the_magistrates_judgment" )

                gain( 2.9 * stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )

                if buff.vanquishers_hammer.up then
                    applyBuff( "shield_of_the_righteous" )
                    removeBuff( "vanquishers_hammer" )
                end

                if conduit.shielding_words.enabled then applyBuff( "shielding_words" ) end
            end,

            auras = {
                -- Conduit
                shielding_words = {
                    id = 338788,
                    duration = 10,
                    max_stack = 1
                }
            }
        },


        -- Paladin - Kyrian    - 304971 - divine_toll          (Divine Toll)
        divine_toll = {
            id = 304971,
            cast = 0,
            cooldown = 60,
            gcd = "spell",

            startsCombat = true,
            texture = 3565448,

            toggle = "essences",

            handler = function ()
                if state.spec.protection then
                    -- Cast Avenger's Shield x5.
                    -- This is lazy and may be wrong/bad.
                    for i = 1, active_enemies do
                        class.abilities.avengers_shield.handler()
                    end
                elseif state.spec.retribution then
                    -- Cast Judgment x5.
                    for i = 1, active_enemies do
                        class.abilities.judgment.handler()
                    end
                elseif state.spec.holy then
                    -- Cast Holy Shock x5.
                    for i = 1, active_enemies do
                        class.abilities.holy_shock.handler()
                    end
                end
            end
        },

        -- Paladin - Necrolord - 328204 - vanquishers_hammer   (Vanquisher's Hammer)
        vanquishers_hammer = {
            id = 328204,
            cast = 0,
            cooldown = 30,
            gcd = "spell",

            spend = function ()
                if buff.divine_purpose.up then return 0 end
                return 1 - ( buff.the_magistrates_judgment.up and 1 or 0 )
            end,
            spendType = "holy_power",

            startsCombat = true,
            texture = 3578228,

            toggle = "essences",

            handler = function ()
                removeBuff( "divine_purpose" )
                removeBuff( "the_magistrates_judgment" )
                applyBuff( "vanquishers_hammer" )
            end,

            auras = {
                vanquishers_hammer = {
                    id = 328204,
                    duration = 15,
                    max_stack = 1
                }
            }
        },

        -- Paladin - Night Fae - 328620 - blessing_of_summer   (Blessing of Summer)
        blessing_of_summer = {
            id = 328620,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = false,
            texture = 3636845,

            toggle = "essences",
            buff = "blessing_of_summer_active",

            handler = function ()
                applyBuff( "blessing_of_summer" ) -- We'll just apply to self because we don't care.

                removeBuff( "blessing_of_summer_active" )
                applyBuff( "blessing_of_autumn_active" )
                setCooldown( "blessing_of_autumn", 45 )
            end,

            auras = {
                blessing_of_summer = {
                    id = 328620,
                    duration = function () return 30 * ( 1 - ( conduit.the_long_summer.mod * 0.01 ) ) end,
                    max_stack = 1,
                },

                blessing_of_summer_active = {
                    duration = 3600,
                    max_stack = 1,
                    generate = function( t )
                        if IsActiveSpell( 328620 ) then
                            t.name = class.auras.blessing_of_summer.name .. " Active"
                            t.count = 1
                            t.applied = now
                            t.expires = now + 3600
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.applied = 0
                        t.expires = 0
                        t.caster = "nobody"
                    end,
                },
            }
        },

        blessing_of_autumn = {
            id = 328622,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = false,
            texture = 3636843,

            toggle = "essences",
            buff = "blessing_of_autumn_active",

            handler = function ()
                applyBuff( "blessing_of_autumn" )

                removeBuff( "blessing_of_autumn_active" )
                applyBuff( "blessing_of_winter_active" )
                setCooldown( "blessing_of_winter", 45 )
            end,

            auras = {
                blessing_of_autumn = {
                    id = 328622,
                    duration = 30,
                    max_stack = 1,
                },
                blessing_of_autumn_active = {
                    duration = 3600,
                    max_stack = 1,
                    generate = function( t )
                        if IsActiveSpell( 328622 ) then
                            t.name = class.auras.blessing_of_autumn.name .. " Active"
                            t.count = 1
                            t.applied = now
                            t.expires = now + 3600
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.applied = 0
                        t.expires = 0
                        t.caster = "nobody"
                    end,
                }
            }
        },

        blessing_of_winter = {
            id = 328281,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = false,
            texture = 3636846,

            toggle = "essences",
            buff = "blessing_of_winter_active",

            handler = function ()
                applyBuff( "blessing_of_winter" )

                removeBuff( "blessing_of_winter_active" )
                applyBuff( "blessing_of_spring_active" )
                setCooldown( "blessing_of_spring", 45 )
            end,

            auras = {
                blessing_of_winter = {
                    id = 328281,
                    duration = 30,
                    max_stack = 1,
                },
                blessing_of_winter_debuff = {
                    id = 328506,
                    duration = 6,
                    max_stack = 10
                },
                blessing_of_winter_active = {
                    duration = 3600,
                    max_stack = 1,
                    generate = function( t )
                        if IsActiveSpell( 328281 ) then
                            t.name = class.auras.blessing_of_winter.name .. " Active"
                            t.count = 1
                            t.applied = now
                            t.expires = now + 3600
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.applied = 0
                        t.expires = 0
                        t.caster = "nobody"
                    end,
                }
            }
        },

        blessing_of_spring = {
            id = 328282,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            spend = 0.05,
            spendType = "mana",

            startsCombat = false,
            texture = 3636844,

            toggle = "essences",
            buff = "blessing_of_spring_active",

            handler = function ()
                applyBuff( "blessing_of_spring" )

                removeBuff( "blessing_of_spring_active" )
                applyBuff( "blessing_of_summer_active" )
                setCooldown( "blessing_of_summer", 45 )
            end,

            auras = {
                blessing_of_spring = {
                    id = 328281,
                    duration = 30,
                    max_stack = 1,
                    friendly = true,
                },
                blessing_of_spring_active = {
                    duration = 3600,
                    max_stack = 1,
                    generate = function( t )
                        if IsActiveSpell( 328282 ) then
                            t.name = class.auras.blessing_of_winter.name .. " Active"
                            t.count = 1
                            t.applied = now
                            t.expires = now + 3600
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.applied = 0
                        t.expires = 0
                        t.caster = "nobody"
                    end,
                }
            }
        },

        -- Paladin - Venthyr   - 316958 - ashen_hallow         (Ashen Hallow)
        ashen_hallow = {
            id = 316958,
            cast = function () return 1.5 * haste end,
            cooldown = 120,
            gcd = "spell",

            startsCombat = false,
            texture = 3565722,

            toggle = "essences",

            auras = {
                hammer_of_wrath_hallow = {
                    duration = 30,
                    max_stack = 1,
                    generate = function( t )
                        if IsUsableSpell( 24275 ) and not ( target.health_pct < 20 or ( level > 57 and ( buff.avenging_wrath.up or buff.crusade.up ) ) and not buff.final_verdict.up ) then
                            t.name = class.abilities.hammer_of_wrath.name .. " " .. class.abilities.ashen_hallow.name
                            t.count = 1
                            t.applied = action.ashen_hallow.lastCast
                            t.expires = action.ashen_hallow.lastCast + 30
                            t.caster = "player"
                            return
                        end

                        t.count = 0
                        t.applied = 0
                        t.expires = 0
                        t.caster = "nobody"
                    end,
                },
            }
        },


    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_unbridled_fury",

        package = "Protection Paladin",
    } )


    spec:RegisterPack( "Protection Paladin", 20201027, [[dmKGQaqiLqpcjv2eKQrHu1PqQSkLK6vifZcP0TeuHDrYVqGHjihdbTmLGNjOQPbP4AkPABGk8niLmobv05euP1bQO08euUhcTpKuoisQklej5HGkQUisQQojOIIvQeTtiPFcQiAOiPklfur6PQYuHe7f4VKAWICyQwmIEmLMSqxg1Mf1NHy0GCAPwTskVguPztXTvQDl53QmCbooOIWYH65enDfxxvTDqvFhjgVssoVsI1dPuZhu2pHbecqb8I(Wauxi0cHim0cOLku4U(cOj8G3SsadEbUfUocdELVzWJ6HVHTtFLir9CJh7c8c8vmNhbOaEY7JTm4bntGeolbeG0d0NuzVnbYE)n(0xzXEEiq2BlbGh5VndCMcqcErFyaQleAHqegAb0sfkCjm8HGdWZ)d0HbVxVHZbpOog5cqcErwAbpQtKOE4By70xjsup34XUelPorcoPDosglslGw0ksleAHqILILuNibNd5fclflPorkCisuFXihfj4uM8dxwjwsDIu4qKGt59bplspg7bq9wKWSCWTD6RKI0vI0(BMoWWI0UNgXN(krYjBtpnlvGNPLJeGc4T7Pr8PVcGcavcbOaEC5KgocOc8S4EyC7Gh5pNvsOMnr9L1deRXnc0W3xQIhLsKqxKOxKGoZk6GJcJvro32EejIIuircgmrI8NZQydFxSo4JdojR(bIeDGNBN(kWtc1SjQVSEGynUrGg((sWaqDbakGhxoPHJaQaplUhg3o4r(ZzLeQRUq0MgbA05VXO(bIe6Ie5pNvsOU6crBAeOrN)gJcZBVlPifMiHyJI0QfPfap3o9vGhLdh1xwJyo8kGbGA4bOaEC5KgocOc8S4EyC7Gh9Iee7MbsfyhrkmrcnHej6ap3o9vGhLdh1xwJyo8kGbGkAaOaEC5KgocOc8S4EyC7Gh9Iux2B3fIo6BhH1egkuOqBPifMibXUzGuBFvI0QfjcvlSUirNiHUibXUzGub2rKctKwFDrcDrACdxJc3iqdFFPoaFdBNdR4YjnCe8C70xbEuoCuFznI5WRagaQRdqb84YjnCeqf4zX9W42bp6fPUS3UleD03ocRjm8HcfAlfPWeji2ndKA7RsKwTirOcoej6ej0fji2ndKkWoIuyI06RdEUD6RapkhoQVSgXC4vadav4aGc4XLtA4iGkWZI7HXTdE0lsDzVDxi6OVDewdhHcfAlfPWeji2ndKA7RsKwTifsHwIeDIe6Iee7MbsfyhrkmrcowxKqxKg3W1OWnc0W3xQdW3W25WkUCsdhbp3o9vGhLdh1xwJyo8kGbGkAbqb84YjnCeqf4zX9W42bp6fPUS3UleD03ocRd3qHcTLIuyIee7MbsT9vjsRwKiuTGirNiHUibXUzGub2rKctKwFDWZTtFf4r5Wr9L1iMdVcyaOgobOaEC5KgocOc8S4EyC7Gxx2B3fIo6BhH1lSEOqBPirnrcIDZaP2(QePvlsHuOrKqxKwuKOxKi)5SYXrUgDKZCfzS6hisWGjsK)CwH8DCS9sFzTx2MRrd3UqKQFGibdMir(ZzvSHVlwlHA2ev)arcgmrI8NZQGB6Ru)arIoWZTtFf4H8DCS9sFzTx2MRrd3UqKGbGA4cqb84YjnCeqf4zX9W42bVXnCnQCxUrlhVIkUCsdhfj0fPUS3UleD03ocRxy9qH2srIAIee7MbsT9vjsRwKcPqJiHUiTOirVir(ZzLJJCn6iN5kYy1pqKGbtKi)5Sc574y7L(YAVSnxJgUDHiv)arcgmrI8NZQydFxSwc1SjQ(bIemyIe5pNvb30xP(bIeDGNBN(kWl2W3fRLqnBIGbGkHHaOaEC5KgocOc8S4EyC7Gxx2B3fIo6BhH1lSEOqBPirnrcIDZaP2(QePvlsHuOrKqxKwuKOxKi)5SYXrUgDKZCfzS6hisWGjsK)CwH8DCS9sFzTx2MRrd3UqKQFGibdMir(ZzvSHVlwlHA2ev)arcgmrI8NZQGB6Ru)arIoWZTtFf454ixJoYzUImgmaujKqakGhxoPHJaQaplUhg3o4bXUzGub2rKctKiCDWZTtFf4z8v0xPH8kkbdyap7DM4rPKauaOsiafWJlN0WravGNf3dJBh8i)5SYHNlKUq0uW(aP(bGNBN(kWl3yM0CxemauxaGc4XLtA4iGkWZTtFf45OTeYXUuNVA0xwhCuym4zX9W42bp7DM4rPusg7bq9wH5T3LuKcJOiryircgmrArrACdxJsYypaQ3kUCsdhbVY3m45OTeYXUuNVA0xwhCuymyaOgEakGhxoPHJaQap3o9vGNlHG3lwQXoAFyT9WUb8S4EyC7Gh9IuKj)5Sc7O9H12d7gDKj)5SsoUfUIe1ej0sKqxKi)5SYHNlKUq0uW(aP(bIeDIemyIuKj)5Sc7O9H12d7gDKj)5SsoUfUIerrke4v(MbpxcbVxSuJD0(WA7HDdyaOIgakGNBN(kWtYypaQ3GhxoPHJaQada11bOaEC5KgocOc8S4EyC7Gh5pNvo8CH0fIMc2hi1pqKGbtKS3zIhLs5WZfsxiAkyFGuyE7DjfjQjsHpe452PVc8GoZkAhEUqymyaOchauap3o9vGNlH4sd5gZrb84YjnCeqfyaOIwauapUCsdhbubEwCpmUDWJ8NZkjJ9aOER(bIemyIK9ot8OukjJ9aOERW827sksHjslisWGjslksJB4Ausg7bq9wXLtA4i452PVc8C45cPlenfSpqGbGA4eGc4XLtA4iGkWZI7HXTdEK)Cw5WZfsxiAkyFGu)aWZTtFf4fCtFfyaOgUauap3o9vGhPHLYUq0xwl)7nJbpUCsdhbubgaQegcGc452PVc8inSu2fI(YA)p)DbEC5KgocOcmaujKqakGNBN(kWJ0Wszxi6lRP01WyWJlN0WravGbGkHlaqb8C70xbEKgwk7crFzTma3fc4XLtA4iGkWaqLWWdqb8C70xbEW7fCIFlHySud57nJbpUCsdhbubgaQeIgakGhxoPHJaQaplUhg3o4bDMv0bhfgRICUT9isutKcbEUD6RaVydFxSEoJbmaujCDakGhxoPHJaQaplUhg3o4zVZepkLYHNlegl1sOMnrfM3ExsWZTtFf4TVnxJ(YAeZHxbmaujeoaOaEC5KgocOc8S4EyC7Gh5pNvsg7bq9w9dejyWePffPXnCnkjJ9aOER4YjnCe8C70xbEFjR7H3sWaqLq0cGc4XLtA4iGkWZTtFf4HGVcrQdW92nASJWGNf3dJBh8OxKOxKS3zIhLsT2pIS5Au5VXOXSfYXiSE6nlsutKqJibdMirViTOinUHRrzXFPhzSuV2pIS5AuC5KgoksOlsbygEnInQiuT2pIS5Aej6ej6ej0fj7DM4rPuo8CHWyPwc1SjQW827sksutKqJiHUir(ZzLKXEauVvyE7DjfjQjsOrKOtKGbtKOxKi)5SsYypaQ3kmV9UKIuyIeAej6aVY3m4HGVcrQdW92nASJWGbGkHHtakGhxoPHJaQap3o9vG3MXmChixQZEHaEwCpmUDWBrrI8NZkhEUq6crtb7dK6hisOls0lsK)CwjzSha1B1pqKGbtKwuKg3W1OKm2dG6TIlN0WrrIoWR8ndEBgZWDGCPo7fcyaOsy4cqb84YjnCeqf4v(MbpSJ2XFbxPMSr0yoQj)ZCf452PVc8WoAh)fCLAYgrJ5OM8pZvGbmGxKZ(3mauaOsiafWZTtFf4HzYpCzWJlN0WravGbG6cauapUCsdhbubEUD6RapRBmA3o9vAtlhWZ0Yrx(Mbp7DM4rPKGbGA4bOaEC5KgocOc8C70xbEw3y0UD6R0MwoGNPLJU8ndE7EAeF6Radav0aqb84YjnCeqf4zX9W42bpYFoRmDMjn3fvYXTWvKctKcp452PVc8OCyteEUlnMLx5LLbda11bOaEC5KgocOc8S4EyC7Gh0zwrhCuySkY522JiruKcjsOls0ls0lsK)Cw5WZfsxiAkyFGu)arcDrArrACdxJsYypaQ3kUCsdhfj6ejyWejYFoRKm2dG6T6his0bEUD6RapjuZMO(Y6bI14gbA47lbdav4aGc4XLtA4iGkWZI7HXTdE0lsK)Cw5WZfsxiAkyFGu)arcDrI8NZkhEUq6crtb7dKcZBVlPifMiHgrcDrArrACdxJsYypaQ3kUCsdhfj6ejyWej6fjYFoRKm2dG6TcZBVlPifMiHgrcDrI8NZkjJ9aOER(bIeDGNBN(kWtc1SjQVSEGynUrGg((sWaqfTaOaEC5KgocOc8S4EyC7Gh0zwrhCuySkY522Jirnrke452PVc8G89MX6lRPG9bcmaudNauapUCsdhbubEwCpmUDWJ8NZkjJ9aOER(bIe6Ie5pNvsg7bq9wH5T3LuKctKcp452PVc8mnc0i1R9JiBUgWaqnCbOaEC5KgocOc8S4EyC7G3IIK9kjBX(0xP(bGNBN(kWZELKTyF6Radavcdbqb84YjnCeqf4zX9W42bp6fj7DM4rPuR9JiBUgfM3ExsrkmrcXgfj0fj7DM4rPuR9JiBUgLfYXiSuNXUD6RCJirnrIqrcDrYENjEuknMD7is0jsWGjslksJB4Auw8x6rgl1R9JiBUgfxoPHJGNBN(kWBTFezZ1agaQesiafWJlN0WravGNf3dJBh8S3zIhLsJz3oGNBN(kWZHNlegl1sOMnrWaqLWfaOaEC5KgocOc8S4EyC7GN9ot8OuAm72rKGbtKwuKg3W1OS4V0JmwQx7hr2CnkUCsdhbp3o9vG3A)iYMRbmaujm8auapUCsdhbubEwCpmUDWJErArrACdxJsYypaQ3kUCsdhfjyWejYFoRKm2dG6T6his0jsOlslksXBu2RSCnyF4OoB8nRj)4sH5T3LuKOMifsKGbtKyPKllRgiwBXFBtAy9L1zJVzf2l4ksHjsHh8C70xbE2RSCnyF4OoB8ndgaQeIgakGhxoPHJaQaplUhg3o4TOinUHRrjzSha1BfxoPHJIemyIe5pNvsg7bq9w9dap3o9vGNPrGgPETFezZ1agaQeUoafWZTtFf45vVD9L1r2hiWJlN0WravGbGkHWbafWJlN0WravGNBN(kWJ0Wsjh1q(EZyWto4gUSe8cpyaOsiAbqb8C70xbEq(EZy9L1deRXnc0W3xcEC5KgocOcmaujmCcqb8C70xbE2RKSf7tFf4XLtA4iGkWaqLWWfGc4XLtA4iGkWZI7HXTdElks0lsSuYLLvdeRT4VTjnS(Y6SX3SA7RDyrcgmrILsUSSIYHnr45U0ywELxwwT91oSibdMiXsjxww5vVD9L1MoZAVI6i7dKA7RDyrcgmrILsUSSAZ7dVI(YAZ32rDeZ(wQ2(AhwKOd8C70xbEqSJhnlLCzzWagWlaZ2Bt6dafaQecqb8C70xbEMgbAK61(rKnxd4XLtA4iGkWagWaEWZyzFfa1fcTqicdTaCaEuCC1fIe8GZSdo8WrrcnIKBN(krY0YrQelbpzaBbOchWb4fGVCByWJ6ejQh(g2o9vIe1ZnESlXsQtKGtANJKXI0cOfTI0cHwiKyPyj1jsW5qEHWsXsQtKchIe1xmYrrcoLj)WLvILuNifoej4uEFWZI0JXEauVfjmlhCBN(kPiDLiT)MPdmSiT7Pr8PVsKCY20tZsLyPyj1jsu)RIT)HJIejNpmls2Bt6JirYiDjvIe1N1YbJuKQRchqoEN)grYTtFLuKUYSIsS0TtFLufGz7Tj9HgIeyAeOrQx7hr2CnILILuNir9Vk2(hoksm8mEfrA6nlsdelsUDoSi1srYH3BJtAyLyPBN(kjrmt(Hllw62PVssdrcSUXOD70xPnTCOT8nt0ENjEukPyPBN(kjnejW6gJ2TtFL20YH2Y3mXDpnIp9vILUD6RK0qKakh2eHN7sJz5vEzzA7mrYFoRmDMjn3fvYXTWnSWlw62PVssdrcKqnBI6lRhiwJBeOHVVK2ote6mROdokmwf5CB7Hyi0PNEYFoRC45cPlenfSpqQFa6loUHRrjzSha1BfxoPHJ0bdg5pNvsg7bq9w9dOtS0TtFLKgIeiHA2e1xwpqSg3iqdFFjTDMi9K)Cw5WZfsxiAkyFGu)a0j)5SYHNlKUq0uW(aPW827sggAqFXXnCnkjJ9aOER4YjnCKoyWON8NZkjJ9aOERW827sggAqN8NZkjJ9aOER(b0jw62PVssdrcG89MX6lRPG9bI2ote6mROdokmwf5CB7HAHelD70xjPHibMgbAK61(rKnxdTDMi5pNvsg7bq9w9dqN8NZkjJ9aOERW827sgw4flD70xjPHib2RKSf7tFfTDM4I2RKSf7tFL6hiw62PVssdrcw7hr2Cn02zI0BVZepkLATFezZ1OW827sggInIU9ot8OuQ1(rKnxJYc5yewQZy3o9vUHAeIU9ot8OuAm72HoyWwCCdxJYI)spYyPETFezZ1O4YjnCuS0TtFLKgIe4WZfcJLAjuZMiTDMO9ot8OuAm72rS0TtFLKgIeS2pIS5AOTZeT3zIhLsJz3oWGT44gUgLf)LEKXs9A)iYMRrXLtA4OyPBN(kjnejWELLRb7dh1zJVzA7mr6xCCdxJsYypaQ3kUCsdhHbJ8NZkjJ9aOER(b0H(IXBu2RSCnyF4OoB8nRj)4sH5T3LKAHGbJLsUSSAGyTf)TnPH1xwNn(MvyVGByHxS0TtFLKgIeyAeOrQx7hr2Cn02zIloUHRrjzSha1BfxoPHJWGr(ZzLKXEauVv)aXs3o9vsAisGx921xwhzFGelD70xjPHibKgwk5OgY3BgtRCWnCzjXWlw62PVssdrcG89MX6lRhiwJBeOHVVuS0TtFLKgIeyVsYwSp9vILUD6RK0qKai2XJMLsUSmTDM4I0ZsjxwwnqS2I)2M0W6lRZgFZQTV2HHbJLsUSSIYHnr45U0ywELxwwT91ommySuYLLvE1BxFzTPZS2ROoY(aP2(Ahggmwk5YYQnVp8k6lRnFBh1rm7BPA7RDy6elflD70xjv27mXJsjjMBmtAUlsBNjs(ZzLdpxiDHOPG9bs9delD70xjv27mXJsjPHibFjR7H30w(Mj6OTeYXUuNVA0xwhCuymTDMO9ot8OukjJ9aOERW827sggrcdbd2IJB4Ausg7bq9wXLtA4OyPBN(kPYENjEukjnej4lzDp8M2Y3mrxcbVxSuJD0(WA7HDdTDMi9rM8NZkSJ2hwBpSB0rM8NZk54w4sn0cDYFoRC45cPlenfSpqQFaDWGfzYFoRWoAFyT9WUrhzYFoRKJBHlXqILUD6RKk7DM4rPK0qKajJ9aOElw62PVsQS3zIhLssdrcGoZkAhEUqymTDMi5pNvo8CH0fIMc2hi1pagm7DM4rPuo8CH0fIMc2hifM3ExsQf(qILUD6RKk7DM4rPK0qKaxcXLgYnMJIyPBN(kPYENjEukjnejWHNlKUq0uW(arBNjs(ZzLKXEauVv)ayWS3zIhLsjzSha1BfM3ExYWwagSfh3W1OKm2dG6TIlN0WrXs3o9vsL9ot8OusAisqWn9v02zIK)Cw5WZfsxiAkyFGu)aXs3o9vsL9ot8OusAisaPHLYUq0xwl)7nJflD70xjv27mXJsjPHibKgwk7crFzT)N)UelD70xjv27mXJsjPHibKgwk7crFznLUgglw62PVsQS3zIhLssdrcinSu2fI(YAzaUleXs3o9vsL9ot8OusAisa8EbN43sigl1q(EZyXs3o9vsL9ot8OusAisqSHVlwpNXqBNjcDMv0bhfgRICUT9qTqILUD6RKk7DM4rPK0qKG9T5A0xwJyo8k02zI27mXJsPC45cHXsTeQztuH5T3LuS0TtFLuzVZepkLKgIe8LSUhElPTZej)5SsYypaQ3QFamyloUHRrjzSha1BfxoPHJILUD6RKk7DM4rPK0qKGVK19WBAlFZerWxHi1b4E7gn2ryA7mr6P3ENjEuk1A)iYMRrL)gJgZwihJW6P3m1qdmy0V44gUgLf)LEKXs9A)iYMRrXLtA4i6bygEnInQiuT2pIS5AOJo0T3zIhLs5WZfcJLAjuZMOcZBVlj1qd6K)CwjzSha1BfM3ExsQHg6GbJEYFoRKm2dG6TcZBVlzyOHoXs3o9vsL9ot8OusAisWxY6E4nTLVzIBgZWDGCPo7fcTDM4IK)Cw5WZfsxiAkyFGu)a0PN8NZkjJ9aOER(bWGT44gUgLKXEauVvC5KgosNyPBN(kPYENjEukjnej4lzDp8M2Y3mrSJ2XFbxPMSr0yoQj)ZCLyPyPBN(kPA3tJ4tFfrjuZMO(Y6bI14gbA47lPTZej)5Ssc1SjQVSEGynUrGg((sv8OuOtp0zwrhCuySkY522dXqWGr(ZzvSHVlwh8XbNKv)a6elD70xjv7EAeF6ROHibuoCuFznI5WRqBNjs(ZzLeQRUq0MgbA05VXO(bOt(ZzLeQRUq0MgbA05VXOW827sggInU6felD70xjv7EAeF6ROHibuoCuFznI5WRqBNjspe7MbsfyNWqti6elD70xjv7EAeF6ROHibuoCuFznI5WRqBNjsFx2B3fIo6BhH1egkuOqBzyqSBgi12x1QjuTW60Hoe7MbsfyNWwFD0h3W1OWnc0W3xQdW3W25WkUCsdhflD70xjv7EAeF6ROHibuoCuFznI5WRqBNjsFx2B3fIo6BhH1eg(qHcTLHbXUzGuBFvRMqfCqh6qSBgivGDcB91flD70xjv7EAeF6ROHibuoCuFznI5WRqBNjsFx2B3fIo6BhH1WrOqH2YWGy3mqQTVQvhsHw0Hoe7MbsfyNWGJ1rFCdxJc3iqdFFPoaFdBNdR4YjnCuS0TtFLuT7Pr8PVIgIeq5Wr9L1iMdVcTDMi9DzVDxi6OVDewhUHcfAlddIDZaP2(QwnHQfOdDi2ndKkWoHT(6ILuNi52PVsQ290i(0xrdrcKqnBI6lRhiwJBeOHVVK2otK8NZkjuZMO(Y6bI14gbA47lvXJsHo9qNzfDWrHXuBbyWi)5Sk2W3fRd(4GtYQFaDILUD6RKQDpnIp9v0qKaKVJJTx6lR9Y2CnA42fIK2otSl7T7crh9TJW6fwpuOTKAqSBgi12x1QdPqd6lsp5pNvooY1OJCMRiJv)ayWi)5Sc574y7L(YAVSnxJgUDHiv)ayWi)5Sk2W3fRLqnBIQFamyK)CwfCtFL6hqNyPBN(kPA3tJ4tFfneji2W3fRLqnBI02zIJB4Au5UCJwoEfvC5KgoIEx2B3fIo6BhH1lSEOqBj1Gy3mqQTVQvhsHg0xKEYFoRCCKRrh5mxrgR(bWGr(ZzfY3XX2l9L1EzBUgnC7crQ(bWGr(ZzvSHVlwlHA2ev)ayWi)5Sk4M(k1pGoXs3o9vs1UNgXN(kAisGJJCn6iN5kYyA7mXUS3UleD03ocRxy9qH2sQbXUzGuBFvRoKcnOVi9K)Cw54ixJoYzUImw9dGbJ8NZkKVJJTx6lR9Y2CnA42fIu9dGbJ8NZQydFxSwc1SjQ(bWGr(ZzvWn9vQFaDILUD6RKQDpnIp9v0qKaJVI(knKxrjTDMie7MbsfyNWiCDWagaaa]] )


end
