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


    spec:RegisterPack( "Protection Paladin", 20201026, [[dqebRaqibXJGOQnbeJIOQtruAvajEfrXSiQClLGYUq6xqLgMG6yqKLPK4zkbMgeLRPKY2usY3ucY4isvDoiQyDajPMNG09iI9rKYbbsQfsK8qIufxujOYijsv6KkbvTsLODcv8tGKWqHOslfij6PQYuHG9c6VuzWsCyklgkpwOjtvxg1ML0NH0OvvNwQvRKQxdKA2K62k1Uf9BvgUahhijz5iEojtxX1bSDi03HQgVssDELqRNivMpqTFcdrcIa85THH4Ss4vcJu4vwffP1qcziBbW3SyadFbwe0gkdFPTz4d5sUHJtFPOGCnT57e(cSf1N5HiaFQdGez47ptGcunU4I2ZhaJgVnUQEdOTPVmsS6GRQ3rCHpmGwpl8jed(82WqCwj8kHrk8kRII0AiTG1wi4ZaM)rGVxVLEGVF79CcXGppRIWhYlkixYnCC6lffKRPnFNILiVOaQiohgteLvwLCIYkHxjSyPyjYlkspFlrzLyjYlklmrbu79SxuavYyaGMPILiVOSWefqT3ZErr690lkkGAe5eLju4t3Qrbra(290O20xcraIdsqeGponmn7HsbFrspmPn4ddOwPQFZAV7QU5ZosJ(h(auu)Hpffqef5fL)Px0fC4zc1Z1o2JOiruclkGblkya1k13i2j7caibNIPabIISWNfN(s4t9Bw7Dx1nF2rA0)WhGcoqCwbIa8XPHPzpuk4ls6HjTbFya1kv97StuNUr)JRcO1uGarberbdOwPQFNDI60n6FCvaTMs4T1PsucvuqJErbueLvGplo9LWh(J4Dx1HQpYIWbIZcGiaFCAyA2dLc(IKEysBWN8IYNn98PbXrucvuqwyrrw4ZItFj8H)iE3vDO6JSiCG4GmicWhNgMM9qPGViPhM0g8jVO0z82DI6822qzhsHdho8wjkHkkF20ZNUTvlkGIOGeDL1efzffqeLpB65tdIJOeQOS2AIciIYyAohkPr)dFakxa5goohHYPHPzp8zXPVe(WFeV7Qou9rweoqCwdIa8XPHPzpuk4ls6HjTbFYlkDgVDNOoVTnu2H0ccho8wjkHkkF20ZNUTvlkGIOGeDvIISIciIYNn98PbXrucvuwBn4ZItFj8H)iE3vDO6JSiCG4SkicWhNgMM9qPGViPhM0g8jVO0z82DI6822qz3Qcho8wjkHkkF20ZNUTvlkGIOeMUqIISIciIYNn98PbXrucvuw1AIciIYyAohkPr)dFakxa5goohHYPHPzp8zXPVe(WFeV7Qou9rweoqCwiicWhNgMM9qPGViPhM0g8jVO0z82DI6822qzhYjC4WBLOeQO8ztpF62wTOakIcs0vefzffqeLpB65tdIJOeQOS2AWNfN(s4d)r8UR6q1hzr4aXr6dra(40W0Shkf8fj9WK2GVqeLX0CouftSGFVPCAyA2lkGikDgVDNOoVTnu2TYAHdVvII0eLpB65t32QffqructrMOaIOeIOiVOGbuRuJ45CCEUYPNjuGarbmyrbdOwPOagX3w6UQZYyZ54aDNOkkqGOagSOGbuRuFJyNSt9Bw7PabIcyWIcgqTsdUPVKceikYcFwC6lHpuaJ4BlDx1zzS5CCGUtufCG4GCGiaFCAyA2dLc(IKEysBWxiIYyAohQIjwWV3uonmn7ffqeLX0Co0ANM2Pgl9uonmn7ffqeLoJ3UtuN32gk7wzTWH3krrAIYNn98PBB1IcOikHPituarucruKxuWaQvQr8Coopx50ZekqGOagSOGbuRuuaJ4BlDx1zzS5CCGUtuffiquadwuWaQvQVrSt2P(nR9uGarbmyrbdOwPb30xsbcefzHplo9LWNVrSt2P(nR9WbIdsHHiaFCAyA2dLc(IKEysBWxiIYyAohQIjwWV3uonmn7ffqeLoJ3UtuN32gk7wzTWH3krrAIYNn98PBB1IcOikHPituarucruKxuWaQvQr8Coopx50ZekqGOagSOGbuRuuaJ4BlDx1zzS5CCGUtuffiquadwuWaQvQVrSt2P(nR9uGarbmyrbdOwPb30xsbcefzHplo9LWNr8Coopx50Ze4aXbjKGiaFCAyA2dLc(IKEysBWxiIYyAohQIjwWV3uonmn7ffqeLpB65tdIJOeQOG0AWNfN(s4tBl6U09T0RGdCGV4DA)HpvqeG4Geeb4JtdtZEOuWxK0dtAd(WaQvQHiNODI6WtS5tbcGplo9LWxTjmM(opCG4Sceb4JtdtZEOuWNfN(s4ZKo13iMYvVCCx1fC4zc8fj9WK2GV4DA)HpPkMyb)Etj826ujkHkruqkSOagSOeIOmMMZHQyIf87nLtdtZE4lTndFM0P(gXuU6LJ7QUGdptGdeNfara(40W0Shkf8zXPVe(m1hrlzLJys3rCXJyA4ls6HjTbFYlkEgdOwPet6oIlEet78mgqTsvJfbTOinrzHefqefmGALAiYjANOo8eB(uGarrwrbmyrXZya1kLys3rCXJyANNXaQvQASiOffjIsy4lTndFM6JOLSYrmP7iU4rmnCG4GmicWNfN(s4tXel43B4JtdtZEOuWbIZAqeGponmn7HsbFrspmPn4ddOwPgICI2jQdpXMpfiquadwuI3P9h(KAiYjANOo8eB(ucVTovII0eLfeg(S40xcF)tVOZqKtuMahioRcIa8zXPVe(m1Nt3306dp8XPHPzpuk4aXzHGiaFCAyA2dLc(IKEysBWhgqTsvmXc(9MceikGblkX70(dFsvmXc(9Ms4T1PsucvuwruadwucrugtZ5qvmXc(9MYPHPzp8zXPVe(me5eTtuhEInF4aXr6dra(40W0Shkf8fj9WK2GpmGALAiYjANOo8eB(uGa4ZItFj8fCtFjCG4GCGiaFwC6lHpmnRuDI6UQtbS3mb(40W0ShkfCG4GuyicWNfN(s4dtZkvNOUR6mGbyNWhNgMM9qPGdehKqcIa8zXPVe(W0Ss1jQ7Qo8Domb(40W0ShkfCG4G0kqeGplo9LWhMMvQorDx1PciDIcFCAyA2dLcoqCqAbqeGplo9LWhIwcQcOvFMOCFBVzc8XPHPzpuk4aXbjKbra(40W0Shkf8fj9WK2GV)Px0fC4zc1Z1o2JOinrjm8zXPVe(8nIDYU50A4aXbP1GiaFCAyA2dLc(IKEysBWx8oT)WNudrorzIYP(nR9ucVTovWNfN(s4BFBoh3vDO6JSiCG4G0QGiaFCAyA2dLc(IKEysBWhgqTsvmXc(9MceikGblkHikJP5COkMyb)Et50W0Sh(S40xcFak21dVvWbIdsleeb4JtdtZEOuWNfN(s4dLCjQYfq6TPDedLHViPhM0g8jVOiVOeVt7p8jDDap6MZHwb0AhHJFJGYUP3SOinrbzIcyWII8IsiIYyAohAKaOmptuU1b8OBohkNgMM9IciIsaHr0Hg9uKORd4r3CoIISIISIciIs8oT)WNudrorzIYP(nR9ucVTovII0efKjkGikya1kvXel43BkH3wNkrrAIcYefzffWGff5ffmGALQyIf87nLWBRtLOeQOGmrrw4lTndFOKlrvUasVnTJyOmCG4GK0hIa8XPHPzpuk4ZItFj8Tzcd65Bkx1su4ls6HjTbFHikya1k1qKt0orD4j28PabIciII8IcgqTsvmXc(9MceikGblkHikJP5COkMyb)Et50W0SxuKf(sBZW3MjmONVPCvlrHdehKqoqeGponmn7HsbFPTz4JysNhibTYH1Ooc7DyaZCj8zXPVe(iM05bsqRCynQJWEhgWmxch4aFEUAa6bIaehKGiaFwC6lHpcJbaAg(40W0ShkfCG4Sceb4JtdtZEOuWNfN(s4lAATZItFPt3Qb(0TACPTz4lEN2F4tfCG4SaicWhNgMM9qPGplo9LWx00ANfN(sNUvd8PB14sBZW3UNg1M(s4aXbzqeGponmn7HsbFrspmPn4ddOwP6UYy678u1yrqlkHkkla(S40xcF4pI2Ji3PJWQlTmYWbIZAqeGponmn7HsbFrspmPn47F6fDbhEMq9CTJ9ikseLWIciII8II8IcgqTsne5eTtuhEInFkqGOaIOeIOmMMZHQyIf87nLtdtZErrwrbmyrbdOwPkMyb)EtbcefzHplo9LWN63S27UQB(SJ0O)HpafCG4SkicWhNgMM9qPGViPhM0g8jVOGbuRudror7e1HNyZNceikGikya1k1qKt0orD4j28PeEBDQeLqffKjkGikHikJP5COkMyb)Et50W0SxuKvuadwuKxuWaQvQIjwWV3ucVTovIsOIcYefqefmGALQyIf87nfiquKf(S40xcFQFZAV7QU5ZosJ(h(auWbIZcbra(40W0Shkf8fj9WK2GV)Px0fC4zc1Z1o2JOinrjm8zXPVe((2EZe3vD4j28HdehPpeb4JtdtZEOuWxK0dtAd(WaQvQIjwWV3uGarberbdOwPkMyb)Etj826ujkHkkla(S40xcF6g9pk36aE0nNdCG4GCGiaFCAyA2dLc(IKEysBWxiIs8sfhj20xsbcGplo9LWx8sfhj20xchioifgIa8XPHPzpuk4ls6HjTbFYlkX70(dFsxhWJU5COeEBDQeLqff0OxuaruI3P9h(KUoGhDZ5qJFJGYkxLyXPV00II0efKefqeL4DA)HpDe2IJOiROagSOeIOmMMZHgjakZZeLBDap6MZHYPHPzp8zXPVe(whWJU5CGdehKqcIa8XPHPzpuk4ls6HjTbFX70(dF6iSfh4ZItFj8ziYjktuo1VzThoqCqAficWhNgMM9qPGViPhM0g8fVt7p8PJWwCefWGfLqeLX0Co0ibqzEMOCRd4r3Couonmn7Hplo9LW36aE0nNdCG4G0cGiaFCAyA2dLc(IKEysBWN8IsiIYyAohQIjwWV3uonmn7ffWGffmGALQyIf87nfiquKvuarucru83qJxg5Ci2WExvBB2HbqskH3wNkrrAIsyrbmyrHvkoJmD(SlsaInMMDx1v12MPelbTOeQOSa4ZItFj8fVmY5qSH9UQ22mCG4GeYGiaFCAyA2dLc(IKEysBWxiIYyAohQIjwWV3uonmn7ffWGffmGALQyIf87nfia(S40xcF6g9pk36aE0nNdCG4G0AqeGplo9LWNL92Cx15zB(WhNgMM9qPGdehKwfeb4JtdtZEOuWNfN(s4dtZkf7DFBVzc8PgsdAwbFlaoqCqAHGiaFwC6lHVVT3mXDv38zhPr)dFak4JtdtZEOuWbIdssFicWNfN(s4lEPIJeB6lHponmn7HsbhioiHCGiaFCAyA2dLc(IKEysBWxiII8IcRuCgz68zxKaeBmn7UQRQTnt326hruadwuyLIZitXFeThrUthHvxAzKPBB9JikGblkSsXzKPw2BZDvNURSZsVZZ28PBB9JikGblkSsXzKPBEFKfDx1PbIT35jSTv0TT(refzHplo9LW3NnY4yLIZidh4aFbeoEBmBGiaXbjicWNfN(s4t3O)r5whWJU5CGponmn7Hsbh4ah4drMO6lH4Ss4vcJuyKwa8H3izNOk4BHFhCKH9IcYeflo9LIIUvJIkwcFbKR2Ag(qErb5sUHJtFPOGCnT57uSe5ffqfX5WyIOSYQKtuwj8kHflflrErr65BjkRelrErzHjkGAVN9IcOsgda0mvSe5fLfMOaQ9E2lksVNErrbuJiNOmHkwkwI8IYc3Q5iWWErbJRhHfL4TXSruWy0ovurbuhJCWOeL8Yf23i7kGwuS40xQeLl1lsflT40xQObeoEBmBKrcU6g9pk36aE0nNJyPyjYlklCRMJad7ffgrMSOOm9MfL5ZIIfNJikTsumeTwByAMkwAXPVujHWyaGMflT40xQKrcUrtRDwC6lD6wnYL2MLeVt7p8PsS0ItFPsgj4gnT2zXPV0PB1ixABwYUNg1M(sXslo9LkzKGl(JO9iYD6iS6slJSCDvcgqTs1DLX035PQXIGo0fiwAXPVujJeCv)M1E3vDZNDKg9p8bOKRRs(NErxWHNjupx7ypscdI8YJbuRudror7e1HNyZNceasiJP5COkMyb)Et50W0SxwWGXaQvQIjwWV3uGazflT40xQKrcUQFZAV7QU5ZosJ(h(auY1vjYJbuRudror7e1HNyZNceacgqTsne5eTtuhEInFkH3wNQqrgiHmMMZHQyIf87nLtdtZEzbdwEmGALQyIf87nLWBRtvOidemGALQyIf87nfiqwXslo9LkzKG732BM4UQdpXMVCDvY)0l6co8mH65Ah7rAHflT40xQKrcU6g9pk36aE0nNJCDvcgqTsvmXc(9MceacgqTsvmXc(9Ms4T1Pk0fiwAXPVujJeCJxQ4iXM(s56QKqIxQ4iXM(skqGyPfN(sLmsWDDap6MZrUUkr(4DA)HpPRd4r3CoucVTovHIg9GeVt7p8jDDap6MZHg)gbLvUkXItFPPLgsGeVt7p8PJWwCKfm4qgtZ5qJeaL5zIYToGhDZ5q50W0SxS0ItFPsgj4AiYjktuo1VzTxUUkjEN2F4thHT4iwAXPVujJeCxhWJU5CKRRsI3P9h(0ryloGbhYyAohAKaOmptuU1b8OBohkNgMM9ILwC6lvYib34LrohInS3v12MLRRsKpKX0CouftSGFVPCAyA2dgmgqTsvmXc(9MceiliH4VHgVmY5qSH9UQ22SddGKucVTovslmyWSsXzKPZNDrcqSX0S7QUQ22mLyjOdDbILwC6lvYibxDJ(hLBDap6MZrUUkjKX0CouftSGFVPCAyA2dgmgqTsvmXc(9MceiwAXPVujJeCTS3M7QopBZxS0ItFPsgj4IPzLI9UVT3mro1qAqZkjlqS0ItFPsgj4(T9MjUR6Mp7in6F4dqjwAXPVujJeCJxQ4iXM(sXslo9LkzKG7NnY4yLIZilxxLeI8SsXzKPZNDrcqSX0S7QUQ22mDBRFeWGzLIZitXFeThrUthHvxAzKPBB9JagmRuCgzQL92Cx1P7k7S078SnF62w)iGbZkfNrMU59rw0DvNgi2ENNW2wr326hrwXsXslo9LkA8oT)WNkj1MWy678Y1vjya1k1qKt0orD4j28PabILwC6lv04DA)HpvYibxaf76H3YL2MLysN6Bet5QxoUR6co8mrUUkjEN2F4tQIjwWV3ucVTovHkbPWGbhYyAohQIjwWV3uonmn7flT40xQOX70(dFQKrcUak21dVLlTnlXuFeTKvoIjDhXfpIPLRRsK3Zya1kLys3rCXJyANNXaQvQASiOL2cbcgqTsne5eTtuhEInFkqGSGb7zmGALsmP7iU4rmTZZya1kvnwe0sclwAXPVurJ3P9h(ujJeCvmXc(9wS0ItFPIgVt7p8Psgj4(p9IodrorzICDvcgqTsne5eTtuhEInFkqayWX70(dFsne5eTtuhEInFkH3wNkPTGWILwC6lv04DA)HpvYibxt9509nT(WlwAXPVurJ3P9h(ujJeCne5eTtuhEInF56QemGALQyIf87nfiam44DA)HpPkMyb)Etj826uf6kGbhYyAohQIjwWV3uonmn7flT40xQOX70(dFQKrcUb30xkxxLGbuRudror7e1HNyZNceiwAXPVurJ3P9h(ujJeCX0Ss1jQ7QofWEZeXslo9LkA8oT)WNkzKGlMMvQorDx1zadWoflT40xQOX70(dFQKrcUyAwP6e1Dvh(ohMiwAXPVurJ3P9h(ujJeCX0Ss1jQ7QovaPtuXslo9LkA8oT)WNkzKGlIwcQcOvFMOCFBVzIyPfN(sfnEN2F4tLmsW13i2j7MtRLRRs(NErxWHNjupx7ypslSyPfN(sfnEN2F4tLmsWDFBoh3vDO6JSOCDvs8oT)WNudrorzIYP(nR9ucVTovILwC6lv04DA)HpvYibxaf76H3k56QemGALQyIf87nfiam4qgtZ5qvmXc(9MYPHPzVyPfN(sfnEN2F4tLmsWfqXUE4TCPTzjOKlrvUasVnTJyOSCDvI8YhVt7p8jDDap6MZHwb0AhHJFJGYUP3S0qgyWYhYyAohAKaOmptuU1b8OBohkNgMM9GeqyeDOrpfj66aE0nNJSYcs8oT)WNudrorzIYP(nR9ucVTovsdzGGbuRuftSGFVPeEBDQKgYKfmy5XaQvQIjwWV3ucVTovHImzflT40xQOX70(dFQKrcUak21dVLlTnlzZeg0Z3uUQLOY1vjHGbuRudror7e1HNyZNceaI8ya1kvXel43BkqayWHmMMZHQyIf87nLtdtZEzflT40xQOX70(dFQKrcUak21dVLlTnlHysNhibTYH1Ooc7DyaZCPyPyPfN(sfD3tJAtFPe1VzT3Dv38zhPr)dFak56QemGALQ(nR9UR6Mp7in6F4dqr9h(ee5)NErxWHNjupx7ypscdgmgqTs9nIDYUaasWPykqGSILwC6lv0DpnQn9LYibx8hX7UQdvFKfLRRsWaQvQ63zNOoDJ(hxfqRPabGGbuRu1VZorD6g9pUkGwtj826ufkA0dkRiwAXPVur390O20xkJeCXFeV7Qou9rwuUUkr(pB65tdItOilSSILwC6lv0DpnQn9LYibx8hX7UQdvFKfLRRsKVZ4T7e15TTHYoKchoC4Tk0pB65t32QbfKORSMSG8ztpFAqCcDT1azmnNdL0O)HpaLlGCdhNJq50W0SxS0ItFPIU7PrTPVugj4I)iE3vDO6JSOCDvI8DgVDNOoVTnu2H0ccho8wf6Nn98PBB1Gcs0vjliF20ZNgeNqxBnXslo9Lk6UNg1M(szKGl(J4Dx1HQpYIY1vjY3z82DI6822qz3Qcho8wf6Nn98PBB1Gsy6cjliF20ZNgeNqx1AGmMMZHsA0)WhGYfqUHJZrOCAyA2lwAXPVur390O20xkJeCXFeV7Qou9rwuUUkr(oJ3UtuN32gk7qoHdhERc9ZME(0TTAqbj6kYcYNn98PbXj01wtSe5fflo9Lk6UNg1M(szKGR63S27UQB(SJ0O)HpaLCDvcgqTsv)M1E3vDZNDKg9p8bOO(dFcI8)tVOl4WZePTcyWya1k13i2j7caibNIPabYkwAXPVur390O20xkJeCrbmIVT0DvNLXMZXb6orvY1vjHmMMZHQyIf87nLtdtZEq6mE7orDEBBOSBL1chERK2Nn98PBB1GsykYaje5XaQvQr8Coopx50ZekqayWya1kffWi(2s3vDwgBohhO7evrbcadgdOwP(gXozN63S2tbcadgdOwPb30xsbcKvS0ItFPIU7PrTPVugj46Be7KDQFZAVCDvsiJP5COkMyb)Et50W0ShKX0Co0ANM2Pgl9uonmn7bPZ4T7e15TTHYUvwlC4TsAF20ZNUTvdkHPidKqKhdOwPgXZ548CLtptOabGbJbuRuuaJ4BlDx1zzS5CCGUtuffiamymGAL6Be7KDQFZApfiamymGALgCtFjfiqwXslo9Lk6UNg1M(szKGRr8Coopx50Ze56QKqgtZ5qvmXc(9MYPHPzpiDgVDNOoVTnu2TYAHdVvs7ZME(0TTAqjmfzGeI8ya1k1iEohNNRC6zcfiamymGALIcyeFBP7QolJnNJd0DIQOabGbJbuRuFJyNSt9Bw7PabGbJbuR0GB6lPabYkwAXPVur390O20xkJeC12IUlDFl9k56QKqgtZ5qvmXc(9MYPHPzpiF20ZNgeNqrAn4tfWrioRAvWboqia]] )


end
