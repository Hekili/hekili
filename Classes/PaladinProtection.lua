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
                gain( buff.holy_avenger.up and 3 or 1, "holy_power" )

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


    spec:RegisterPack( "Protection Paladin", 20201013, [[dm08PaqiQkEerLSjGyueLofrXQuQOxrenlIQUfkLODr4xqudJQQJbrwMsrptPGPHsX1uQ02as5BevQXHsP6CkfY6qPeAEuv6EOK9ruXbrPKAHOu9qukjxuPqPtQuOyLkL2je6NOucgkkLYsvku5PQYuHG9c6VuzWs6WuwmKESGjl0Lr2SeFgfJwvDAPwTsvEnqYSj1TvYUf9Bvgov54kfQA5q9CunDfxhW2jcFNinELkCELQA9aPA(a1(jzisqeGVOneeXn9VPFK8J0ge(3On3DdYn8n77rWNNfaLXqWxAlc(yB4BOW0xQQSntBXoHppBF9zricWh)aWbc((Z4XzlImYm98bqfHBHmVxaAB6ldyRmiZ7vaz4dfO1ZgtcrHVOneeXn9VPFK8J0ge(3On3Dd7cFgW8pm896fBf897yKsik8fjEa(KlvLTHVHctFPQY2mTf7uTvUuv2cH5qjSQI0gKxv30)M(vBvBLlvLT6BjdXvBLlvLTuvzRJrkQQBCekaOib8PB(WHiaFREAgB6lHiarejicWhLgQMIq2HVaUhc3g8Hcukc(VjD0Df38jhUz(dDaCr8KMQkiQQSQ6)0778oPewePsh6rvzPQ(vvWGvvuGsreBj6KCEayVJtcapvvg4ZctFj8X)nPJUR4Mp5WnZFOdGdhiIBcra(O0q1ueYo8fW9q42GpuGsrW)D2jJt3m)Xva0AbGNQcIQIcukc(VZozC6M5pUcGwlW0Y6KRQ(QQmHOQUtvDt4ZctFj8j9Wr3vCm6dVpCGiUbicWhLgQMIq2HVaUhc3g8jRQ(jtpFHxyuvFvv24xvLb(SW0xcFspC0DfhJ(W7dhiISbIa8rPHQPiKD4lG7HWTbFYQQDgUvNmUOTmgYHKF)(9V4QQVQ6Nm98flBhQ6ovvKeBURQkJQcIQ(jtpFHxyuvFv1D3vvbrvhtt5iWnZFOdG78W3qH5WcknunfHplm9LWN0dhDxXXOp8(WbI4UqeGpknunfHSdFbCpeUn4twvTZWT6KXfTLXqoK2GF)(xCv1xv9tME(ILTdvDNQkscqtvLrvbrv)KPNVWlmQQVQ6U7cFwy6lHpPho6UIJrF49HderqdIa8rPHQPiKD4lG7HWTbFYQQDgUvNmUOTmgYbA(97FXvvFv1pz65lw2ou1DQQ(fYTQkJQcIQ(jtpFHxyuvFvvqBxvfevDmnLJa3m)HoaUZdFdfMdlO0q1ue(SW0xcFspC0DfhJ(W7dhiIYneb4Jsdvtri7Wxa3dHBd(Kvv7mCRozCrBzmKBJ873)IRQ(QQFY0ZxSSDOQ7uvrsSPQkJQcIQ(jtpFHxyuvFv1D3f(SW0xcFspC0DfhJ(W7dhiISDicWhLgQMIq2HVaUhc3g85JQoMMYrWjS597LGsdvtrvfevTZWT6KXfTLXqUn31V)fxvLJQ(jtpFXY2HQUtv1VGnQkiQQpQQSQkkqPimCKYXfPcLrcla8uvWGvvuGsrWay4yBP7koldnLJduDYWfaEQkyWQkkqPiITeDso(VjDua4PQGbRQOaLIW7M(sbGNQkd8zHPVe(yamCST0DfNLHMYXbQoz4WbI4gbra(O0q1ueYo8fW9q42GpFu1X0uocoHnVFVeuAOAkQQGOQJPPCeLonTJpwgfuAOAkQQGOQDgUvNmUOTmgYT5U(9V4QQCu1pz65lw2ou1DQQ(fSrvbrv9rvLvvrbkfHHJuoUivOmsybGNQcgSQIcukcgadhBlDxXzzOPCCGQtgUaWtvbdwvrbkfrSLOtYX)nPJcapvfmyvffOueE30xka8uvzGplm9LWxSLOtYX)nPJWbIis(HiaFuAOAkczh(c4EiCBWNpQ6yAkhbNWM3Vxcknunfvvqu1od3Qtgx0wgd52Cx)(xCvvoQ6Nm98flBhQ6ovv)c2OQGOQ(OQYQQOaLIWWrkhxKkugjSaWtvbdwvrbkfbdGHJTLUR4Sm0uooq1jdxa4PQGbRQOaLIi2s0j54)M0rbGNQcgSQIcukcVB6lfaEQQmWNfM(s4ZWrkhxKkugjmCGiIesqeGpknunfHSdFbCpeUn4ZhvDmnLJGtyZ73lbLgQMIQkiQ6Nm98fEHrv9vvrAx4ZctFj8PT9Dx6(wg5WboWx4oD8KMCicqercIa8rPHQPiKD4lG7HWTbFOaLIWKGsMozCsX28faEWNfM(s4R0ycvFxeoqe3eIa8rPHQPiKD4ZctFj8zGo)ByJ7kxoUR48oPeg(c4EiCBWx4oD8KMcoHnVFVeyAzDYvvFzPQi5xvbdwv9rvhtt5i4e28(9sqPHQPi8L2IGpd05FdBCx5YXDfN3jLWWbI4gGiaFuAOAkczh(SW0xcFg)lHLe3Hnq)WUWHnn8fW9q42Gpzv1iHcukcSb6h2foSPDrcfOue8XcGsvLJQk3QkiQkkqPimjOKPtgNuSnFbGNQkJQcgSQgjuGsrGnq)WUWHnTlsOaLIGpwauQklv1p8L2IGpJ)LWsI7WgOFyx4WMgoqezdeb4ZctFj8XjS597f8rPHQPiKD4arCxicWNfM(s4Z4FkDFtRpPWhLgQMIq2HderqdIa8rPHQPiKD4lG7HWTbFOaLIGtyZ73lbGNQcgSQgUthpPPGtyZ73lbMwwNCv1xvDtvfmyv1hvDmnLJGtyZ73lbLgQMIWNfM(s4ZKGsMozCsX28Hder5gIa8rPHQPiKD4lG7HWTbFOaLIWKGsMozCsX28faEWNfM(s4Z7M(s4arKTdra(SW0xcFOAIZ7KXDfhhyTim8rPHQPiKD4arCJGiaFwy6lHpunX5DY4UIZagGvcFuAOAkczhoqerYpeb4ZctFj8HQjoVtg3vCs7Cim8rPHQPiKD4arejKGiaFwy6lHpunX5DY4UIJ7H7Kb(O0q1ueYoCGiI0MqeGplm9LWNewUXd08pH5UVTweg(O0q1ueYoCGiI0gGiaFuAOAkczh(c4EiCBW3)0778oPewePsh6rvLJQ6h(SW0xcFXwIoj3CAnCGiIeBGiaFuAOAkczh(c4EiCBWx4oD8KMctckzim3X)nPJcmTSo5WNfM(s4BDlkh3vCm6dVpCGiI0UqeGpknunfHSdFbCpeUn4dfOueCcBE)Eja8uvWGvvFu1X0uocoHnVFVeuAOAkcFwy6lHpao56HwC4arejqdIa8rPHQPiKD4ZctFj8XGVKH78W9Y0oSXqWxa3dHBd(KvvLvvd3PJN0uShqKzr5ikaATdtHVHzi30lsvLJQYgvfmyvvwv1hvDmnLJiGb4wKWC3EarMfLJGsdvtrvfev1dts4ycrbsI9aImlkhvvgvvgvfevnCNoEstHjbLmeM74)M0rbMwwNCvvoQkBuvquvuGsrWjS597LatlRtUQkhvLnQQmQkyWQQSQkkqPi4e28(9sGPL1jxv9vvzJQkd8L2IGpg8LmCNhUxM2HngcoqersUHiaFuAOAkczh(SW0xcFlctGA(g3vSKb(c4EiCBWNpQkkqPimjOKPtgNuSnFbGNQcIQkRQIcukcoHnVFVeaEQkyWQQpQ6yAkhbNWM3VxcknunfvvzGV0we8TimbQ5BCxXsg4arej2oeb4Jsdvtri7WxAlc(WgOhbsqXDOnJdtrhkWmxcFwy6lHpSb6rGeuChAZ4Wu0HcmZLWboWxKkgGEGiarejicWNfM(s4dtOaGIGpknunfHSdhiIBcra(O0q1ueYo8zHPVe(cMw7SW0x60nFGpDZhxAlc(c3PJN0KdhiIBaIa8rPHQPiKD4ZctFj8fmT2zHPV0PB(aF6MpU0we8T6PzSPVeoqezdeb4Jsdvtri7Wxa3dHBd(qbkfHUleQ(UOGpwauQQVQ6gGplm9LWN0dRJsqD6We)sldeCGiUleb4Jsdvtri7Wxa3dHBd((NEFN3jLWIiv6qpQklv1VQcIQkRQkRQIcukctckz6KXjfBZxa4PQGOQ(OQJPPCeCcBE)EjO0q1uuvLrvbdwvrbkfbNWM3Vxcapvvg4ZctFj8X)nPJUR4Mp5WnZFOdGdhiIGgeb4Jsdvtri7Wxa3dHBd(KvvrbkfHjbLmDY4KIT5la8uvquvuGsrysqjtNmoPyB(cmTSo5QQVQkBuvquvFu1X0uocoHnVFVeuAOAkQQYOQGbRQYQQOaLIGtyZ73lbMwwNCv1xvLnQkiQkkqPi4e28(9sa4PQYaFwy6lHp(VjD0Df38jhUz(dDaC4aruUHiaFuAOAkczh(c4EiCBW3)0778oPewePsh6rvLJQ6h(SW0xcFFBTiS7koPyB(WbIiBhIa8rPHQPiKD4lG7HWTbFOaLIGtyZ73lbGNQcIQIcukcoHnVFVeyAzDYvvFv1naFwy6lHpDZ8hUBpGiZIYboqe3iicWhLgQMIq2HVaUhc3g85JQgUKtbSn9Lcap4ZctFj8fUKtbSn9LWbIis(HiaFuAOAkczh(c4EiCBWNSQA4oD8KMI9aImlkhbMwwNCv1xvLjevvqu1WD64jnf7bezwuoIW3Wme3vWwy6lnTQkhvfjvfevnCNoEsthMSWOQYOQGbRQ(OQJPPCebma3IeM72diYSOCeuAOAkcFwy6lHV9aImlkh4arejKGiaFuAOAkczh(c4EiCBWx4oD8KMomzHb(SW0xcFMeuYqyUJ)BshHderK2eIa8rPHQPiKD4lG7HWTbFH70XtA6WKfgvfmyv1hvDmnLJiGb4wKWC3EarMfLJGsdvtr4ZctFj8ThqKzr5ahiIiTbicWhLgQMIq2HVaUhc3g8jRQ6JQoMMYrWjS597LGsdvtrvfmyvffOueCcBE)Eja8uvzuvquvFu14nIWLbkhSnu0v02ICOa4uGPL1jxvLJQ6xvbdwvjoNYajMp5cyGqJQj3vCfTTib2sqPQ(QQBa(SW0xcFHlduoyBOOROTfbhiIiXgicWhLgQMIq2HVaUhc3g85JQoMMYrWjS597LGsdvtrvfmyvffOueCcBE)Eja8Gplm9LWNUz(d3ThqKzr5ahiIiTleb4ZctFj8zzVm3vCrYMp8rPHQPiKD4arejqdIa8rPHQPiKD4ZctFj8HQjoNIUVTweg(4dUbfXHVnahiIij3qeGplm9LW33wlc7UIB(Kd3m)Hoao8rPHQPiKD4arej2oeb4ZctFj8fUKtbSn9LWhLgQMIq2HderK2iicWhLgQMIq2HVaUhc3g85JQkRQsCoLbsmFYfWaHgvtUR4kABrILT3HvvWGvvIZPmqcPhwhLG60Hj(LwgiXY27WQkyWQkX5ugiHL9YCxXP7c5Sm6IKnFXY27WQkyWQkX5ugiXIwhEF3vCAGqhDrmzlUyz7Dyvvg4ZctFj89jdpoIZPmqWboWNhMc3c1gicqercIa8zHPVe(0nZF4U9aImlkh4Jsdvtri7WboWb(KGW8(siIB6Ft)(3Onbn4tQHZoz4W3gZY7Wdfvv2OQwy6lvvDZhUqTf(8WxP1e8jxQkBdFdfM(svLTzAl2PARCPQSfcZHsyvfPniVQUP)n9R2Q2kxQkB13sgIR2kxQkBPQYwhJuuv34iuaqrc1w1w5sv3y3bfagkQQOu5WKQgUfQnQkkX0jxOQS1Ha5nCvnVKT8B4vbqRQwy6l5Q6L69fQTwy6l5cpmfUfQnsYczDZ8hUBpGiZIYrTvTvUu1n2DqbGHIQkjbH3xvNErQ68jv1cZHv1MRQMewRnunjuBTW0xYzHjuaqrQTwy6l5sYc5GP1olm9LoDZh5tBrSc3PJN0KR2AHPVKljlKdMw7SW0x60nFKpTfXA1tZytFPARfM(sUKSqw6H1rjOoDyIFPLbs(UWcfOue6UqO67Ic(ybq57guBTW0xYLKfY8Ft6O7kU5toCZ8h6a4Y3fw)tVVZ7KsyrKkDOhw(brwzrbkfHjbLmDY4KIT5la8aXNX0uocoHnVFVeuAOAkkdyWOaLIGtyZ73lbGNmQTwy6l5sYcz(VjD0Df38jhUz(dDaC57clzrbkfHjbLmDY4KIT5la8abfOueMeuY0jJtk2MVatlRtUVSbeFgtt5i4e28(9sqPHQPOmGbllkqPi4e28(9sGPL1j3x2ackqPi4e28(9sa4jJARfM(sUKSq(BRfHDxXjfBZx(UW6F69DENuclIuPd9ih)QTwy6l5sYczDZ8hUBpGiZIYr(UWcfOueCcBE)Eja8abfOueCcBE)EjW0Y6K77guBTW0xYLKfYHl5uaBtFP8DHLpHl5uaBtFPaWtT1ctFjxswiVhqKzr5iFxyjB4oD8KMI9aImlkhbMwwNCFzcrqc3PJN0uShqKzr5icFdZqCxbBHPV00Ybjqc3PJN00HjlmYagSpJPPCebma3IeM72diYSOCeuAOAkQ2AHPVKljlKnjOKHWCh)3KokFxyfUthpPPdtwyuBTW0xYLKfY7bezwuoY3fwH70XtA6WKfgWG9zmnLJiGb4wKWC3EarMfLJGsdvtr1wlm9LCjzHC4YaLd2gk6kABrY3fwY6ZyAkhbNWM3VxcknunfbdgfOueCcBE)Eja8KbeFI3icxgOCW2qrxrBlYHcGtbMwwNC54hmyIZPmqI5tUagi0OAYDfxrBlsGTeu(Ub1wlm9LCjzHSUz(d3ThqKzr5iFxy5ZyAkhbNWM3VxcknunfbdgfOueCcBE)Eja8uBTW0xYLKfYw2lZDfxKS5R2AHPVKljlKr1eNtr33wlclpFWnOioRnO2AHPVKljlK)2Ary3vCZNC4M5p0bWvBTW0xYLKfYHl5uaBtFPARfM(sUKSq(tgECeNtzGKVlS8rwIZPmqI5tUagi0OAYDfxrBlsSS9omyWeNtzGespSokb1Pdt8lTmqILT3HbdM4CkdKWYEzUR40DHCwgDrYMVyz7DyWGjoNYajw06W77UItde6OlIjBXflBVdlJARARfM(sUiCNoEstoRsJju9Dr57cluGsrysqjtNmoPyB(cap1wlm9LCr4oD8KMCjzHmaNC9ql5tBrSmqN)nSXDLlh3vCENuclFxyfUthpPPGtyZ73lbMwwNCFzHKFWG9zmnLJGtyZ73lbLgQMIQTwy6l5IWD64jn5sYczao56HwYN2Iyz8VewsCh2a9d7ch20Y3fwYgjuGsrGnq)WUWHnTlsOaLIGpwauYrUbbfOueMeuY0jJtk2MVaWtgWGJekqPiWgOFyx4WM2fjuGsrWhlakw(vBTW0xYfH70XtAYLKfYCcBE)EP2AHPVKlc3PJN0KljlKn(Ns3306tQARfM(sUiCNoEstUKSq2KGsMozCsX28LVlSqbkfbNWM3VxcapWGd3PJN0uWjS597LatlRtUVBcgSpJPPCeCcBE)EjO0q1uuT1ctFjxeUthpPjxswi7DtFP8DHfkqPimjOKPtgNuSnFbGNARfM(sUiCNoEstUKSqgvtCENmUR44aRfHvBTW0xYfH70XtAYLKfYOAIZ7KXDfNbmaRuT1ctFjxeUthpPjxswiJQjoVtg3vCs7CiSARfM(sUiCNoEstUKSqgvtCENmUR44E4ozuBTW0xYfH70XtAYLKfYsy5gpqZ)eM7(2Ary1wlm9LCr4oD8KMCjzHCSLOtYnNwlFxy9p9(oVtkHfrQ0HEKJF1wlm9LCr4oD8KMCjzH86wuoUR4y0hEF57cRWD64jnfMeuYqyUJ)BshfyAzDYvBTW0xYfH70XtAYLKfYaCY1dT4Y3fwOaLIGtyZ73lbGhyW(mMMYrWjS597LGsdvtr1wlm9LCr4oD8KMCjzHmaNC9ql5tBrSyWxYWDE4EzAh2yi57clzLnCNoEstXEarMfLJOaO1omf(gMHCtVi5WgWGL1NX0uoIagGBrcZD7bezwuocknunfbXdts4ycrbsI9aImlkhzKbKWD64jnfMeuYqyUJ)BshfyAzDYLdBabfOueCcBE)EjW0Y6Klh2idyWYIcukcoHnVFVeyAzDY9LnYO2AHPVKlc3PJN0KljlKb4KRhAjFAlI1IWeOMVXDflzKVlS8bfOueMeuY0jJtk2MVaWdezrbkfbNWM3VxcapWG9zmnLJGtyZ73lbLgQMIYO2AHPVKlc3PJN0KljlKb4KRhAjFAlIf2a9iqckUdTzCyk6qbM5s1w1wlm9LCXQNMXM(sw8Ft6O7kU5toCZ8h6a4Y3fwOaLIG)BshDxXnFYHBM)qhaxepPjiY(p9(oVtkHfrQ0HEy5hmyuGsreBj6KCEayVJtcapzuBTW0xYfREAgB6lLKfYspC0DfhJ(W7lFxyHcukc(VZozC6M5pUcGwla8abfOue8FNDY40nZFCfaTwGPL1j3xMqCNBQ2AHPVKlw90m20xkjlKLE4O7kog9H3x(UWs2pz65l8cJVSXVmQTwy6l5IvpnJn9LsYczPho6UIJrF49LVlSKTZWT6KXfTLXqoK873V)f33pz65lw2o2jsIn3vgq(KPNVWlm(U7UGmMMYrGBM)qha35HVHcZHfuAOAkQ2AHPVKlw90m20xkjlKLE4O7kog9H3x(UWs2od3Qtgx0wgd5qAd(97FX99tME(ILTJDIKa0KbKpz65l8cJV7URARfM(sUy1tZytFPKSqw6HJUR4y0hEF57clz7mCRozCrBzmKd0873)I77Nm98flBh70VqULbKpz65l8cJVG2UGmMMYrGBM)qha35HVHcZHfuAOAkQ2AHPVKlw90m20xkjlKLE4O7kog9H3x(UWs2od3Qtgx0wgd52i)(9V4((jtpFXY2XorsSPmG8jtpFHxy8D3DvBLlv1ctFjxS6PzSPVuswiZ)nPJUR4Mp5WnZFOdGlFxyHcukc(VjD0Df38jhUz(dDaCr8KMGi7)0778oPewoBcgmkqPiITeDsopaS3XjbGNmQTwy6l5IvpnJn9LsYczgadhBlDxXzzOPCCGQtgU8DHLpJPPCeCcBE)EjO0q1ueKod3Qtgx0wgd52Cx)(xC58jtpFXY2Xo9lydi(ilkqPimCKYXfPcLrcla8adgfOuemago2w6UIZYqt54avNmCbGhyWOaLIi2s0j54)M0rbGhyWOaLIW7M(sbGNmQTwy6l5IvpnJn9LsYc5ylrNKJ)BshLVlS8zmnLJGtyZ73lbLgQMIGmMMYru600o(yzuqPHQPiiDgUvNmUOTmgYT5U(9V4Y5tME(ILTJD6xWgq8rwuGsry4iLJlsfkJewa4bgmkqPiyamCST0DfNLHMYXbQoz4capWGrbkfrSLOtYX)nPJcapWGrbkfH3n9LcapzuBTW0xYfREAgB6lLKfYgos54IuHYiHLVlS8zmnLJGtyZ73lbLgQMIG0z4wDY4I2Yyi3M763)IlNpz65lw2o2PFbBaXhzrbkfHHJuoUivOmsybGhyWOaLIGbWWX2s3vCwgAkhhO6KHla8adgfOueXwIojh)3Koka8adgfOueE30xka8KrT1ctFjxS6PzSPVuswiRT9Dx6(wg5Y3fw(mMMYrWjS597LGsdvtrq(KPNVWlm(I0UWh3JcqebnqdoWbcb]] )


end
