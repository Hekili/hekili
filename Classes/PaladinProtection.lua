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

            aura = "judgment",

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


    spec:RegisterPack( "Protection Paladin", 20201029, [[dCeo6aqiLcpIuj2ePWNivsyusL6usLSksr5vquZIuXTqGYUOYVaQgMsPJHGwgPQEgPsnnsrUgcyBiq(MsvX4ivsDoLQsRJujP5buCpiSpsvCqsvsleI8qLQkCrLQQYhvQQOoPsvvwPuXmvQQQ2jq6NKkjAOiq1svQQ0tvYubIVQuvr2Rk)vWGLYHPSye9ysMmrxg1Mf6ZqA0aoTIvdu61kvz2u1Tb1Uf9BvnCPQJtQsSCOEostxY1bz7kv(oP04jfvNxPO1tQsnFeA)e(i8a5wsR4du93Q)wc3Q7TUTB1NaB33BvB2Z3Q3u7zO8TsdMVfbh)fRQ5trJGBEto5T6Tn9VjpqUf9HWk(wav1t1vbhC0PaGiDQhgC6ad5TA(uHTyboDGvGFlsOXx7V8iVL0k(av)T6VLWT6ERB7w9jWwc6wgub84BTg49JBbmsjNh5TKmvDlDr0i44VyvnFkAeCZBYjfD0frtxPQEsglA6VV6iA6Vv)TIoIo6IOTFayjktfD0frJGjA6vPKLI2(LjH2JDIo6IOrWeT9ld)7yrBXyRhyGfnmtl8OQ5tQO9PObd5RP3ZIg8udQvZNIMro(PgM6eD0frJGjA7VSyuSvSOb)yw0(OOvaSOTam5R1BPKkA6vc((V7w(Hw0dKBj5Ob5RdKducpqULPQ5ZBHzsO94BXPr6z5H0vhO6FGClonsplpKULPQ5ZBPmVpyQA(m4hADl)qRqAW8Tu)7LV2KE1bQUpqUfNgPNLhs3Yu185TuM3hmvnFg8dTULFOviny(wWtnOwnFE1bQMoqUfNgPNLhs3Yu185TuM3hmvnFg8dTULFOviny(w0YsPHLxDGsGdKBXPr6z5H0Tu4Py8y3IekgD(jYK()LoAzQ9enWiA6(wMQMpVL2h7L74jdyM(PLk(Qduc6a5wCAKEwEiDlfEkgp2TaE)MH(xlJDsooQPeneI2wrtdrRBrRBrJekgD2oorNenOfBfGdQx00q02q0kZZz5Om26bgyhNgPNLIwxIgrIIgjum6Om26bgyhuVO11TmvnFElkWWEz4JHcGd4bfO4hIE1b6(CGClonsplpKULcpfJh7wDlAKqXOZ2Xj6KObTyRaCq9IMgIgjum6SDCIojAql2kahMHTjPIgyennjAAiABiAL55SCugB9adSJtJ0ZsrRlrJirrRBrJekgDugB9adSdZW2KurdmIMMennensOy0rzS1dmWoOErRRBzQA(8wuGH9YWhdfahWdkqXpe9QduD9bYT40i9S8q6wk8umESBb8(nd9Vwg7KCCutjA6r02EltvZN3cWGHzC4JbTyRaU6aDFpqUfNgPNLhs3sHNIXJDlsOy0rzS1dmWoOErtdrJekgDugB9adSdZW2KurdmIMUVLPQ5ZB5huGIgalKefMZ6Qduc3EGClonsplpKULcpfJh7wBiAQpPScB18PdQ)wMQMpVL6tkRWwnFE1bkHeEGClonsplpKULcpfJh7wDlAQ)9YxB6alKefMZYHzyBsQObgrdvjfnnen1)E5RnDGfsIcZz5uaggLPHi2u18P5fn9iAekAAiAQ)9YxBgWSPkrRlrJirrBdrRmpNLtHHOMKX0ayHKOWCwoonsplVLPQ5ZBbwijkmN1vhOeQ)bYT40i9S8q6wk8umESBP(3lFTzaZMQULPQ5ZBz74eLX0afyyV8Qduc19bYT40i9S8q6wk8umESBP(3lFTzaZMQenIefTneTY8CwofgIAsgtdGfsIcZz540i9S8wMQMpVfyHKOWCwxDGsOMoqUfNgPNLhs3sHNIXJDRUfTneTY8CwokJTEGb2XPr6zPOrKOOrcfJokJTEGb2b1lADjAAiABiAYVCQpvCwyRyzi6nyoqcHthMHTjPIMEeTTIgrIIgtPCQyxbWbfgsnKEo8Xq0BWSdB5EIgyenDFltvZN3s9PIZcBfldrVbZxDGsiboqUfNgPNLhs3sHNIXJDRneTY8CwokJTEGb2XPr6zPOrKOOrcfJokJTEGb2b1FltvZN3YpOafnawijkmN1vhOesqhi3Yu185TSCGTWhds2kGBXPr6z5H0vhOeUphi3ItJ0ZYdPBzQA(8wKEMszzaWGHz8TOfE2JP3s3xDGsOU(a5wMQMpVfGbdZ4WhdfahWdkqXpe9wCAKEwEiD1bkH77bYTmvnFEl1NuwHTA(8wCAKEwEiD1bQ(BpqUfNgPNLhs3sHNIXJDRneTUfnMs5uXUcGdkmKAi9C4JHO3GzhSb2hlAejkAmLYPIDAFSxUJNmGz6NwQyhSb2hlAejkAmLYPIDwoWw4Jb)e5GLYGKTcWbBG9XIgrIIgtPCQyhmd)4ndFm4HuJmiXSbtDWgyFSO11TmvnFEla2WvGPuov8vxDREmREysRoqoqj8a5wMQMpVv0Zuaf2I1T40i9S8q6Qdu9pqULPQ5ZBP(KYkSvZN3ItJ0ZYdPRoq19bYTmvnFEl)Gcu0ayHKOWCw3ItJ0ZYdPRU6wQ)9YxBspqoqj8a5wCAKEwEiDlfEkgp2TiHIrNTJt0jrdAXwb4G6VLPQ5ZBfhmt6)xE1bQ(hi3ItJ0ZYdPBzQA(8wMEtbmSrdXpRWhd9VwgFlfEkgp2Tu)7LV20rzS1dmWomdBtsfnWGq0iCROrKOOTHOvMNZYrzS1dmWoonsplVvAW8Tm9McyyJgIFwHpg6FTm(QduDFGClonsplpKULPQ5ZBzuGDwY0a207hhup283sHNIXJDRUfnjtcfJoSP3poOES5dsMekgD0Yu7jA6r02hrtdrJekgD2oorNenOfBfGdQx06s0isu0Kmjum6WME)4G6XMpizsOy0rltTNOHq02ER0G5BzuGDwY0a207hhup28xDGQPdKBzQA(8wugB9ad8T40i9S8q6QducCGCltvZN3Y2Xj6KObTyRaUfNgPNLhsxDGsqhi3ItJ0ZYdPBPWtX4XUfjum6SDCIojAql2kahuVOrKOOP(3lFTPZ2Xj6KObTyRaCyg2MKkA6r0iOT3Yu185TaE)MbBhNOm(Qd095a5wCAKEwEiDlfEkgp2TiHIrNTJt0jrdAXwb4G6VLPQ5ZB1)185vhO66dKBXPr6z5H0Tu4Py8y3IekgD2oorNenOfBfGt(AZBzQA(8wgfGZaG59V2Roq33dKBzQA(8wKEMsNen8XafcgMX3ItJ0ZYdPRoqjC7bYTmvnFElsptPtIg(yWGki48wCAKEwEiD1bkHeEGCltvZN3I0Zu6KOHpg0ozX4BXPr6z5H0vhOeQ)bYTmvnFElsptPtIg(yG2JNe9wCAKEwEiD1bkH6(a5wMQMpV1ol1lqdfGX0aGbdZ4BXPr6z5H0vhOeQPdKBXPr6z5H0Tu4Py8y3c49Bg6FTm2j54OMs00JOT9wMQMpVLC2njhQ37V6aLqcCGClonsplpKULcpfJh7wKqXOJYyRhyGDq9IgrII2gIwzEolhLXwpWa740i9S8wMQMpVfaB4kWukNk(QducjOdKBXPr6z5H0Tu4Py8y3IekgDugB9adSdQx0isu02q0kZZz5Om26bgyhNgPNL3Yu185TGOCykgME1bkH7ZbYT40i9S8q6wk8umESB1J5DbuL0rOZ2XjkJPbkWWEPOPHOP(3lFTPZ2XjkJPbkWWEPdZW2K0BzQA(8wWpmNv4Jbu)J38Qduc11hi3ItJ0ZYdPBzQA(8wO4prPHE8aB(a2q5BPWtX4XUv3Iw3IM6FV81MoWcjrH5SCriVpGzfGHr5qnWSOPhrttIgrIIw3I2gIwzEolNcdrnjJPbWcjrH5SCCAKEwkAAiA9yExavjDe6alKefMZs06s06s00q0u)7LV20z74eLX0afyyV0HzyBsQOPhrttIMgIgjum6Om26bgyhMHTjPIMEennjADjAejkADlAKqXOJYyRhyGDyg2MKkAGr00KO11TsdMVfk(tuAOhpWMpGnu(Qduc33dKBXPr6z5H0TmvnFElygZ7vagneTe9wk8umESBTHOrcfJoBhNOtIg0ITcWb1lAAiADlAKqXOJYyRhyGDq9IgrII2gIwzEolhLXwpWa740i9Su066wPbZ3cMX8EfGrdrlrV6av)Thi3ItJ0ZYdPBLgmFlSP3sOCpAGCqdywgiHQ6ZBzQA(8wytVLq5E0a5GgWSmqcv1NxD1TOLLsdlpqoqj8a5wCAKEwEiDlfEkgp2TiHIrNFImP)FPJwMAprdmIMUVLPQ5ZBP9XE5oEYaMPFAPIV6av)dKBXPr6z5H0Tu4Py8y3sYKqXOdSqsuyolhuVOPHO1TOjzsOy0TJtuoc5duGxTNdQx0isu02q0uFkHMYTJtuoc5duGxTNJtJ0ZsrRRBzQA(8wuGH9YWhdfahWdkqXpe9QduDFGClonsplpKULcpfJh7waVFZq)RLXIgcrJaIgrIIgjum6aE)MbBhNOm2b1lAejkAaVFZq)RLXIgcrttIMgIwzEolh1svnXHLbTyRaCCAKEwkAAiAKqXOZ2Xj6KObTyRaCq93Yu185TOad7LHpgkaoGhuGIFi6vhOA6a5wCAKEwEiDltvZN3cSqsuyoRBPWtX4XULcWWOmv0qiA6lAejkABiAL55SCkme1KmMgalKefMZYXPr6z5TuBQ8COmmkx0ducV6aLahi3ItJ0ZYdPBPWtX4XULKjHIr3oor5iKpqbE1Eo5Rnfnnen1NsOPC74eLJq(af4v7540i9S8wMQMpVLTJtugtduGH9YRoqjOdKBzQA(8wagmmJdFmOfBfWT40i9S8q6Qd095a5wMQMpVLTJtugtduGH9YBXPr6z5H0vhO66dKBXPr6z5H0TmvnFElWcjrH5SULAtLNdLHr5IEGs4vhO77bYTmvnFERDwQxGgkaJPbadgMX3ItJ0ZYdPRoqjC7bYT40i9S8q6wk8umESBTHOP(KYkSvZNoO(BzQA(8wQpPScB185vhOes4bYTmvnFEl5SBsouV3FlonsplpKU6aLq9pqUfNgPNLhs3Yu185Ti9mLYYaGbdZ4BPWtX4XULcWWOmv0qiA6(w0cp7X0BPVttxDGsOUpqULPQ5ZBzuaodaM3)AVfNgPNLhsxDGsOMoqUfNgPNLhs3sHNIXJDlfGHrzQOHq00)wMQMpVfGbdZ4WhdfahWdkqXpe9QducjWbYT40i9S8q6wk8umESBrcfJUDwQxGgkaJPbadgMXoO(BzQA(8wAFSm8XaQ)XBE1bkHe0bYTmvnFEllhyl8XGKTc4wCAKEwEiD1bkH7ZbYT40i9S8q6wMQMpVfPNPuwgamyygFlAHN9y6T03PPRoqjuxFGCltvZN3cWGHzC4JHcGd4bfO4hIElonsplpKU6aLW99a5wCAKEwEiDlfEkgp2T6w02q0kZZz5Om26bgyhNgPNLIgrIIgjum6Om26bgyhuVO1LOPHOTHOj)YP(uXzHTILHO3G5ajeoDyg2MKkA6r02kAejkAmLYPIDfahuyi1q65WhdrVbZoSL7jAGr009TmvnFEl1NkolSvSme9gmF1bQ(BpqULPQ5ZB5huGIgalKefMZ6wCAKEwEiD1bQ(eEGCltvZN3YWkl5q9ymN1T40i9S8q6Qdu91)a5wMQMpVL6tkRWwnFElonsplpKU6avFDFGClonsplpKULcpfJh7wKqXOJcm5KOb)GcuHiMzhuVOPHOTHOP(DCAz5swHF)JL3Yu185T0(yz4Jbu)J38QRUf8udQvZNhihOeEGClonsplpKULcpfJh7wKqXOJcmSxg(yOa4aEqbk(HOo5RnfnneTUfnG3VzO)1YyNKJJAkrdHOTv0isu0iHIrNC2njh6HW9pLDq9Iwx3Yu185TOad7LHpgkaoGhuGIFi6vhO6FGClonsplpKULcpfJh7wKqXOJcm5KOb)GcuHiK37G6fnnensOy0rbMCs0GFqbQqeY7Dyg2MKkAGr0qvsrtZen9VLPQ5ZBP9XYWhdO(hV5vhO6(a5wCAKEwEiDlfEkgp2T6w0ayZxaUEvjAGr000wrRRBzQA(8wAFSm8XaQ)XBE1bQMoqUfNgPNLhs3sHNIXJDRUfTjvp8KObPbBOCGWTB3UfMkAGr0ayZxaoytZfnnt0i0PpbeTUennena28fGRxvIgyencqartdrRmpNLdpOaf)q0qp(lwvp2XPr6z5TmvnFElTpwg(ya1)4nV6aLahi3ItJ0ZYdPBPWtX4XUv3I2KQhEs0G0GnuoqOU3UDlmv0aJObWMVaCWMMlAAMOrOJGeTUennena28fGRxvIgyencqGBzQA(8wAFSm8XaQ)XBE1bkbDGClonsplpKULcpfJh7wDlAtQE4jrdsd2q5abTD7wyQObgrdGnFb4Gnnx00mrBRBFeTUennena28fGRxvIgyencIaIMgIwzEolhEqbk(HOHE8xSQESJtJ0ZYBzQA(8wAFSm8XaQ)XBE1b6(CGClonsplpKULcpfJh7wDlAtQE4jrdsd2q5W(UD7wyQObgrdGnFb4Gnnx00mrJqN(IwxIMgIgaB(cW1RkrdmIgbiWTmvnFElTpwg(ya1)4nV6avxFGClonsplpKULcpfJh7wtQE4jrdsd2q5G(ey7wyQOPhrdGnFb4Gnnx00mrBRttIMgI2gIw3Igjum6mSKZki5iNsg7G6fnIefnsOy0Hczy5yz4JblvdNvyVjrPoOErJirrJekgDYz3KCGcmSx6G6fnIefnsOy01)18PdQx066wMQMpVfkKHLJLHpgSunCwH9MeLE1b6(EGClonsplpKULcpfJh7wL55SCXjnFGwwkDCAKEwkAAiAtQE4jrdsd2q5G(ey7wyQOPhrdGnFb4Gnnx00mrBRttIMgI2gIw3Igjum6mSKZki5iNsg7G6fnIefnsOy0Hczy5yz4JblvdNvyVjrPoOErJirrJekgDYz3KCGcmSx6G6fnIefnsOy01)18PdQx066wMQMpVLC2njhOad7LxDGs42dKBXPr6z5H0Tu4Py8y3As1dpjAqAWgkh0NaB3ctfn9iAaS5lahSP5IMMjABDAs00q02q06w0iHIrNHLCwbjh5uYyhuVOrKOOrcfJouidlhldFmyPA4Sc7njk1b1lAejkAKqXOto7MKduGH9shuVOrKOOrcfJU(VMpDq9Iwx3Yu185TmSKZki5iNsgF1bkHeEGClonsplpKULcpfJh7waS5laxVQenWiAesGBzQA(8wEBZWNbalL0RU6QBTJX05Zdu93Q)wc3Q)(ClTgoNeLER9t619lO7pq3pRRkAIgiaSOnW9pUeT4JfnDf0YsPHL6kenmRxGgmlfn6dZIMbvpSvSu0uawIYuNOdiaSOfFV)1ojQOzqyJkAAzmlAquwkAtkAfalAMQMpfn)qlrJeQenTmMfT8lrl(qPu0Mu0kaw0mP8trtALrAuwxv0r0iyIgfyYjrd(bfOcrmZIoIo7p4(hxSu0iGOzQA(u08dTOorNBr7z1bkbrq3Qh)XXZ3sxenco(lwvZNIgb38MCsrhDr00vQQNKXIM(7RoIM(B1FROJOJUiA7hawIYurhDr0iyIMEvkzPOTFzsO9yNOJUiAemrB)YW)ow0wm26bgyrdZ0cpQA(KkAFkAWq(A69SObp1GA18POzKJFQHPorhDr0iyI2(llgfBflAWpMfTpkAfalAlat(A9wkPIMELGV)7eDeD0frB)tZzfuXsrJKJpMfn1dtALOrYOtsDIMEvP4(IkA5NemaddhH8IMPQ5tQO9PFtNOJPQ5tQRhZQhM0kKraE0Zuaf2ILOJPQ5tQRhZQhM0kKraU6tkRWwnFk6yQA(K66XS6HjTczeG7huGIgalKefMZs0r0rxeT9pnNvqflfnEhJ3u0QbMfTcGfntvpw0gQOz7SXBKE2j6yQA(KIaZKq7XIoMQMpPiJaCL59btvZNb)qlDsdMrO(3lFTjv0Xu18jfzeGRmVpyQA(m4hAPtAWmc4PguRMpfDmvnFsrgb4kZ7dMQMpd(Hw6KgmJGwwknSu0r0Xu18jfzeGR9XE5oEYaMPFAPI1zIiiHIrNFImP)FPJwMApWOBrhtvZNuKraofyyVm8XqbWb8Gcu8dr1zIiaE)MH(xlJDsooQPqSvJU7MekgD2oorNenOfBfGdQxJnkZZz5Om26bgyhNgPNLDrKijum6Om26bgyhuFxIoMQMpPiJaCkWWEz4JHcGd4bfO4hIQZer0njum6SDCIojAql2kahuVgKqXOZ2Xj6KObTyRaCyg2MKcgnPXgL55SCugB9adSJtJ0ZYUisSBsOy0rzS1dmWomdBtsbJM0GekgDugB9adSdQVlrhtvZNuKraoGbdZ4WhdAXwbOZera8(nd9Vwg7KCCutPNTIoMQMpPiJaC)Gcu0ayHKOWCw6mreKqXOJYyRhyGDq9AqcfJokJTEGb2HzyBsky0TOJPQ5tkYiax9jLvyRMp1zIi2q9jLvyRMpDq9IoMQMpPiJaCWcjrH5S0zIi6w9Vx(AthyHKOWCwomdBtsbdQsQH6FV81MoWcjrH5SCkadJY0qeBQA(086Hqnu)7LV2mGztvDrK4gL55SCkme1KmMgalKefMZYXPr6zPOJPQ5tkYia32XjkJPbkWWEPoteH6FV81MbmBQs0Xu18jfzeGdwijkmNLoteH6FV81MbmBQIiXnkZZz5uyiQjzmnawijkmNLJtJ0ZsrhtvZNuKraU6tfNf2kwgIEdM1zIi6EJY8CwokJTEGb2XPr6zjrIKqXOJYyRhyGDq9DPXgYVCQpvCwyRyzi6nyoqcHthMHTjP6zlrImLYPIDfahuyi1q65WhdrVbZoSL7bgDl6yQA(KImcW9dkqrdGfsIcZzPZerSrzEolhLXwpWa740i9SKirsOy0rzS1dmWoOErhtvZNuKraULdSf(yqYwbi6yQA(KImcWj9mLYYaGbdZyDOfE2JPi0TOJPQ5tkYiahWGHzC4JHcGd4bfO4hIk6yQA(KImcWvFszf2Q5trhtvZNuKraoaB4kWukNkwNjIyJUzkLtf7kaoOWqQH0ZHpgIEdMDWgyFmrImLYPIDAFSxUJNmGz6NwQyhSb2htKitPCQyNLdSf(yWproyPmizRaCWgyFmrImLYPIDWm8J3m8XGhsnYGeZgm1bBG9XDj6i6yQA(K6OLLsdlrO9XE5oEYaMPFAPI1zIiiHIrNFImP)FPJwMApWOBrhtvZNuhTSuAyjYiaNcmSxg(yOa4aEqbk(HO6mresMekgDGfsIcZz5G61OBjtcfJUDCIYriFGc8Q9Cq9ejUH6tj0uUDCIYriFGc8Q9CCAKEw2LOJPQ5tQJwwknSezeGtbg2ldFmuaCapOaf)quDMicG3VzO)1YyeeGirsOy0b8(nd2oorzSdQNirG3VzO)1YyeAsJY8CwoQLQAIdldAXwb440i9SudsOy0z74eDs0GwSvaoOErhtvZNuhTSuAyjYiahSqsuyolDuBQ8COmmkxueeQZerOammktrOprIBuMNZYPWqutYyAaSqsuyolhNgPNLIoMQMpPoAzP0WsKraUTJtugtduGH9sDMicjtcfJUDCIYriFGc8Q9CYxBQH6tj0uUDCIYriFGc8Q9CCAKEwk6yQA(K6OLLsdlrgb4agmmJdFmOfBfGOJPQ5tQJwwknSezeGB74eLX0afyyVu0Xu18j1rllLgwImcWblKefMZsh1MkphkdJYffbHIoMQMpPoAzP0WsKra(ol1lqdfGX0aGbdZyrhtvZNuhTSuAyjYiax9jLvyRMp1zIi2q9jLvyRMpDq9IoMQMpPoAzP0WsKraUC2njhQ37fDmvnFsD0YsPHLiJaCsptPSmayWWmwhAHN9ykc9DAsNjIqbyyuMIq3IoMQMpPoAzP0WsKraUrb4mayE)Rv0Xu18j1rllLgwImcWbmyygh(yOa4aEqbk(HO6mrekadJYue6l6yQA(K6OLLsdlrgb4AFSm8XaQ)XBQZerqcfJUDwQxGgkaJPbadgMXoOErhtvZNuhTSuAyjYia3Yb2cFmizRaeDmvnFsD0YsPHLiJaCsptPSmayWWmwhAHN9ykc9DAs0Xu18j1rllLgwImcWbmyygh(yOa4aEqbk(HOIoMQMpPoAzP0WsKraU6tfNf2kwgIEdM1zIi6EJY8CwokJTEGb2XPr6zjrIKqXOJYyRhyGDq9DPXgYVCQpvCwyRyzi6nyoqcHthMHTjP6zlrImLYPIDfahuyi1q65WhdrVbZoSL7bgDl6yQA(K6OLLsdlrgb4(bfOObWcjrH5SeDmvnFsD0YsPHLiJaCdRSKd1JXCwIoMQMpPoAzP0WsKraU6tkRWwnFk6yQA(K6OLLsdlrgb4AFSm8XaQ)XBQZerqcfJokWKtIg8dkqfIyMDq9ASH63XPLLlzf(9pwk6i6yQA(K6u)7LV2KIioyM0)VuNjIGekgD2oorNenOfBfGdQx0Xu18j1P(3lFTjfzeGdr5WumSoPbZim9McyyJgIFwHpg6FTmwNjIq9Vx(AthLXwpWa7WmSnjfmiiClrIBuMNZYrzS1dmWoonsplfDmvnFsDQ)9YxBsrgb4quomfdRtAWmcJcSZsMgWME)4G6XMxNjIOBjtcfJoSP3poOES5dsMekgD0Yu7PN9rdsOy0z74eDs0GwSvaoO(UisuYKqXOdB69JdQhB(GKjHIrhTm1Ei2k6yQA(K6u)7LV2KImcWPm26bgyrhtvZNuN6FV81MuKraUTJt0jrdAXwbi6yQA(K6u)7LV2KImcWbE)MbBhNOmwNjIGekgD2oorNenOfBfGdQNir1)E5RnD2oorNenOfBfGdZW2Ku9qqBfDmvnFsDQ)9YxBsrgb49FnFQZerqcfJoBhNOtIg0ITcWb1l6yQA(K6u)7LV2KImcWnkaNbaZ7FT6mreKqXOZ2Xj6KObTyRaCYxBk6yQA(K6u)7LV2KImcWj9mLojA4JbkemmJfDmvnFsDQ)9YxBsrgb4KEMsNen8XGbvqWPOJPQ5tQt9Vx(AtkYiaN0Zu6KOHpg0ozXyrhtvZNuN6FV81MuKraoPNP0jrdFmq7XtIk6yQA(K6u)7LV2KImcW3zPEbAOamMgamyygl6yQA(K6u)7LV2KImcWLZUj5q9EVotebW73m0)AzStYXrnLE2k6yQA(K6u)7LV2KImcWbydxbMs5uX6mreKqXOJYyRhyGDq9ejUrzEolhLXwpWa740i9Su0Xu18j1P(3lFTjfzeGdr5WummvNjIGekgDugB9adSdQNiXnkZZz5Om26bgyhNgPNLIoMQMpPo1)E5RnPiJaC4hMZk8XaQ)XBQZer0J5DbuL0rOZ2XjkJPbkWWEPgQ)9YxB6SDCIYyAGcmSx6WmSnjv0Xu18j1P(3lFTjfzeGdr5WumSoPbZiqXFIsd94b28bSHY6mreD3T6FV81MoWcjrH5SCriVpGzfGHr5qnWSE0erIDVrzEolNcdrnjJPbWcjrH5SCCAKEwQrpM3fqvshHoWcjrH5S6Qlnu)7LV20z74eLX0afyyV0HzyBsQE0KgKqXOJYyRhyGDyg2MKQhn1frIDtcfJokJTEGb2HzyBsky0uxIoMQMpPo1)E5RnPiJaCikhMIH1jnygbmJ59kaJgIwIQZerSbjum6SDCIojAql2kahuVgDtcfJokJTEGb2b1tK4gL55SCugB9adSJtJ0ZYUeDmvnFsDQ)9YxBsrgb4quomfdRtAWmcSP3sOCpAGCqdywgiHQ6trhrhtvZNuh8udQvZNiOad7LHpgkaoGhuGIFiQotebjum6Oad7LHpgkaoGhuGIFiQt(Atn6g49Bg6FTm2j54OMcXwIejHIrNC2njh6HW9pLDq9Dj6yQA(K6GNAqTA(ezeGR9XYWhdO(hVPotebjum6OatojAWpOavic59oOEniHIrhfyYjrd(bfOcriV3HzyBskyqvsntFrhtvZNuh8udQvZNiJaCTpwg(ya1)4n1zIi6gGnFb46vfy002UeDmvnFsDWtnOwnFImcW1(yz4Jbu)J3uNjIO7jvp8KObPbBOCGWTB3UfMcga28fGd20CnJqN(eOlnayZxaUEvbgcqankZZz5WdkqXpen0J)Iv1JDCAKEwk6yQA(K6GNAqTA(ezeGR9XYWhdO(hVPoter3tQE4jrdsd2q5aH6E72TWuWaWMVaCWMMRze6iOU0aGnFb46vfyiabeDmvnFsDWtnOwnFImcW1(yz4Jbu)J3uNjIO7jvp8KObPbBOCGG2UDlmfmaS5lahSP5A2w3(0LgaS5laxVQadbrankZZz5WdkqXpen0J)Iv1JDCAKEwk6yQA(K6GNAqTA(ezeGR9XYWhdO(hVPoter3tQE4jrdsd2q5W(UD7wykyayZxaoytZ1mcD63LgaS5laxVQadbiGOJUiAMQMpPo4PguRMprgb4uGH9YWhdfahWdkqXpevNjIGekgDuGH9YWhdfahWdkqXpe1jFTPgDd8(nd9VwgRh9jsKekgDYz3KCOhc3)u2b13LOJPQ5tQdEQb1Q5tKraokKHLJLHpgSunCwH9MeLQZermP6HNeninydLd6tGTBHP6bGnFb4GnnxZ260KgB0njum6mSKZki5iNsg7G6jsKekgDOqgwowg(yWs1Wzf2BsuQdQNirsOy0jNDtYbkWWEPdQNirsOy01)18PdQVlrhtvZNuh8udQvZNiJaC5SBsoqbg2l1zIikZZz5ItA(aTSu640i9SuJjvp8KObPbBOCqFcSDlmvpaS5lahSP5A2wNM0yJUjHIrNHLCwbjh5uYyhuprIKqXOdfYWYXYWhdwQgoRWEtIsDq9ejscfJo5SBsoqbg2lDq9ejscfJU(VMpDq9Dj6yQA(K6GNAqTA(ezeGByjNvqYroLmwNjIys1dpjAqAWgkh0NaB3ct1daB(cWbBAUMT1Pjn2OBsOy0zyjNvqYroLm2b1tKijum6qHmSCSm8XGLQHZkS3KOuhuprIKqXOto7MKduGH9shuprIKqXOR)R5thuFxIoMQMpPo4PguRMprgb4EBZWNbalLuDMica28fGRxvGHqcC1v3b]] )


end
