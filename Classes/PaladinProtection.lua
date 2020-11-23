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
        shining_light_free = {
            id = 327510,
            duration = 15,
            max_stack = 1,
            copy = "shining_light_full"
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


    spec:RegisterPack( "Protection Paladin", 20201123, [[diKs5aqifQEeLs1MOegLcLtrPQvrPGxbrnlkr3csQyxu8lGQHbKogKyzuQ8mkfnnijxdO02GKY3ukvnoiPQZPuQSoLsbnpLkDpiSpkLCqLsPSqiYdvkf6IkLcCsLsPALkKDcedvPu0sHKk9ufnvLQ2Rk)LkdwjhM0Ir0JjmzIUmQnl0Nry0aoTuRgO41kvmBb3gu7w0Vv1WvWXvkLSCOEostxY1bz7kfFNsA8uk05vkz9ukL5dP2pv9HYT)MsT4de7a1oqrbf7SPbfWIkWcwuUzT1aFZbvSJsW3mvy(MBt8xSO6p9RTPguzN3Cq3k8Q82Ft6dHf8nbQAGUneCWj6caI0iEyWPnmuqR(tbwJf40gwa(njH6qTTNh5nLAXhi2bQDGIck2ztdkGfvGfvB3nvOc4X3C2WBJ3eOLsopYBkzQ4M2UFTnXFXIQ)0V2MAqLD6hz7(fi)ggMKX(LD20s)YoqTdu)i)iB3V2gb0KGP(r2UFH64xBBsjl9luxMeAh24hz7(fQJFH6YW)g2VMmwhaAy)cZ0c3IQ)K6xF6xWqHQhcSFb3vtOv)PFPKDORMPMBgAArV93uYrfku3(deuU93ufv)5nXmj0o8n5ujdS8q6Qde7U93KtLmWYdPBQIQ)8McneCQO6pDHMw3m00YLkmFtX)b5BnPxDGyZB)n5ujdS8q6MQO6pVPqdbNkQ(txOP1ndnTCPcZ3eURMqR(ZRoqq1T)MCQKbwEiDtvu9N3uOHGtfv)Pl006MHMwUuH5BslnLkwE1bcyV93KtLmWYdPBkWDX4wVjjumAcDKjd)ln0sf74x76x28MQO6pVP1hhKB4oDyM(PMc(Qdeu72FtovYalpKUPa3fJB9MaFyl3WBLXgjhBrx(fc)cu)Yc)Am)Am)Iekgn6goj6KWzfRfGbAWVSWVg3VknWzzOmwhaAydNkzGL(L9(fA0(fjumAOmwhaAyd0GFz)nvr1FEtkqZbP7JUcGD4MaO4hIE1bY2F7VjNkzGLhs3uG7IXTEZX8lsOy0OB4KOtcNvSwagOb)Yc)Iekgn6goj6KWzfRfGbZWANu)Ax)cv(Lf(14(vPboldLX6aqdB4ujdS0VS3VqJ2VgZViHIrdLX6aqdBWmS2j1V21VqLFzHFrcfJgkJ1bGg2an4x2Ftvu9N3Kc0Cq6(ORayhUjak(HOxDGG6V93KtLmWYdPBkWDX4wVjWh2Yn8wzSrYXw0LFzl)c0BQIQ)8MakmmJDF0zfRfWvhiB3T)MCQKbwEiDtbUlg36njHIrdLX6aqdBGg8ll8lsOy0qzSoa0WgmdRDs9RD9lBEtvu9N3m0eaf1bgijbmN1vhiOa6T)MCQKbwEiDtbUlg36nh3VeFszbwR(td0Wnvr1FEtXNuwG1Q)8Qdeuq52FtovYalpKUPa3fJB9MJ5xI)dY3AAadKKaMZYGzyTtQFTRFriK(Lf(L4)G8TMgWajjG5SmcaftWuxeRIQ)ud(LT8lu8ll8lX)b5BnDywfLFzVFHgTFnUFvAGZYiWquvYyQdmqscyoldNkzGL3ufv)5nbdKKaMZ6QdeuS72FtovYalpKUPa3fJB9MI)dY3A6WSkQBQIQ)8M6gojym1rbAoiV6abfBE7VjNkzGLhs3uG7IXTEtX)b5BnDywfLFHgTFnUFvAGZYiWquvYyQdmqscyoldNkzGL3ufv)5nbdKKaMZ6Qdeuq1T)MCQKbwEiDtbUlg36nhZVg3VknWzzOmwhaAydNkzGL(fA0(fjumAOmwhaAyd0GFzVFzHFnUFj)Yi(uWzH1ILUyqHzhjeonygw7K6x2YVa1VqJ2VykLtbBka2jWqIMmWUp6IbfMnyn3XV21VS5nvr1FEtXNcolSwS0fdkmF1bckG92FtovYalpKUPa3fJB9MJ7xLg4SmugRdanSHtLmWs)cnA)IekgnugRdanSbA4MQO6pVzOjakQdmqscyoRRoqqb1U93ufv)5n1SHv3hDswlGBYPsgy5H0vhiOS93(BYPsgy5H0nvr1FEtYatPS0bOWWm(M0c37W0BAZRoqqb1F7VPkQ(ZBcOWWm29rxbWoCtau8drVjNkzGLhsxDGGY2D7VPkQ(ZBk(KYcSw9N3KtLmWYdPRoqSd0B)n5ujdS8q6McCxmU1BoUFnMFXukNc2uaStGHenzGDF0fdkmBGvW8y)cnA)IPuofSX6JdYnCNomt)utbBGvW8y)cnA)IPuofSrZgwDF0f6i70u6KSwagyfmp2VqJ2VykLtbBGz4hVL7JUaKOLojMvyQbwbZJ9l7VPkQ(ZBcWkUCmLYPGV6QBoGzXdtQ1T)abLB)nvr1FEtjV5R(tNcH1BYPsgy5H0vhi2D7VPkQ(ZBgdmfqG1yDtovYalpKU6aXM3(BQIQ)8MIpPSaRv)5n5ujdS8q6QdeuD7VPkQ(ZBgAcGI6adKKaMZ6MCQKbwEiD1v3u8Fq(wt6T)abLB)n5ujdS8q6McCxmU1BscfJgDdNeDs4SI1cWanCtvu9N3m2yMm8V8Qde7U93KtLmWYdPBQIQ)8MQTrbuSsDXpl3hDdVvgFtbUlg36nf)hKV10qzSoa0WgmdRDs9RDr4xOaQFHgTFnUFvAGZYqzSoa0WgovYalVzQW8nvBJcOyL6IFwUp6gERm(QdeBE7VjNkzGLhs3ufv)5nvkWgnzQdR22JDIhRHBkWDX4wV5y(LKjHIrdwTTh7epwdojtcfJgAPID8lB5xBVFzHFrcfJgDdNeDs4SI1cWan4x27xOr7xsMekgny12ESt8yn4KmjumAOLk2XVq4xGEZuH5BQuGnAYuhwTTh7epwdxDGGQB)nvr1FEtkJ1bGg(MCQKbwEiD1bcyV93ufv)5n1nCs0jHZkwlGBYPsgy5H0vhiO2T)MCQKbwEiDtbUlg36njHIrJUHtIojCwXAbyGg8l0O9lX)b5Bnn6goj6KWzfRfGbZWANu)Yw(fQb6nvr1FEtGpSLt3WjbJV6az7V93KtLmWYdPBkWDX4wVjjumA0nCs0jHZkwlad0Wnvr1FEZHV6pV6ab1F7VjNkzGLhs3uG7IXTEtsOy0OB4KOtcNvSwag5BnVPkQ(ZBQuaoDaAi8wV6az7U93ufv)5njdmL2jH7JokemmJVjNkzGLhsxDGGcO3(BQIQ)8MKbMs7KW9rNcvqW5n5ujdS8q6Qdeuq52Ftvu9N3KmWuANeUp6S2zX4BYPsgy5H0vhiOy3T)MQO6pVjzGP0ojCF0rhWDsCtovYalpKU6abfBE7VPkQ(ZBUrZTfutbym1bOWWm(MCQKbwEiD1bckO62FtovYalpKUPa3fJB9MaFyl3WBLXgjhBrx(LT8lqVPkQ(ZBk7nDYU6dHRoqqbS3(BYPsgy5H0nf4UyCR3KekgnugRdanSbAWVqJ2Vg3VknWzzOmwhaAydNkzGL3ufv)5nbyfxoMs5uWxDGGcQD7VjNkzGLhs3uG7IXTEtsOy0qzSoa0WgOb)cnA)AC)Q0aNLHYyDaOHnCQKbwEtvu9N3eIYUUyy6vhiOS93(BYPsgy5H0nf4UyCR3CaZBCecPbfJUHtcgtDuGMds)Yc)s8Fq(wtJUHtcgtDuGMdsdMH1oP3ufv)5nHFyol3hDeHhV1vhiOG6V93KtLmWYdPBQIQ)8Me4pjOUbCdRbhwj4BkWDX4wV5y(1y(L4)G8TMgWajjG5SmrOqWHzbGIjyx1WSFzl)cv(fA0(1y(14(vPbolJadrvjJPoWajjG5SmCQKbw6xw4xdyEJJqinOyadKKaMZYVS3VS3VSWVe)hKV10OB4KGXuhfO5G0GzyTtQFzl)cv(Lf(fjumAOmwhaAydMH1oP(LT8lu5x27xOr7xJ5xKqXOHYyDaOHnygw7K6x76xOYVS)MPcZ3Ka)jb1nGByn4WkbF1bckB3T)MCQKbwEiDtvu9N3eMX8ofGsDrnjUPa3fJB9MJ7xKqXOr3WjrNeoRyTamqd(Lf(1y(fjumAOmwhaAyd0GFHgTFnUFvAGZYqzSoa0WgovYal9l7VzQW8nHzmVtbOuxutIRoqSd0B)n5ujdS8q6MPcZ3eR2Mek3H6iBchMLosOQ(8MQO6pVjwTnjuUd1r2eomlDKqv95vxDt4UAcT6pV9hiOC7VjNkzGLhs3uG7IXTEtsOy0qbAoiDF0vaSd3eaf)quJ8TM(Lf(1y(fWh2Yn8wzSrYXw0LFHWVa1VqJ2ViHIrJS30j7gGWdpLnqd(L93ufv)5nPanhKUp6ka2HBcGIFi6vhi2D7VjNkzGLhs3uG7IXTEtsOy0qb6StcxOjakxekemqd(Lf(fjumAOaD2jHl0eaLlcfcgmdRDs9RD9lcH0VSb)YUBQIQ)8MwFS09rhr4XBD1bInV93KtLmWYdPBkWDX4wV5y(faRHcWmik)Ax)cvG6x2Ftvu9N306JLUp6icpERRoqq1T)MCQKbwEiDtbUlg36nhZV6u8WDs4KkSsWouafuqbfM6x76xaSgkadSAJ(Ln4xOySdS(L9(Lf(faRHcWmik)Ax)cSG1VSWVknWzzWnbqXpe1nG)If1JnCQKbwEtvu9N306JLUp6icpERRoqa7T)MCQKbwEiDtbUlg36nhZV6u8WDs4KkSsWouSjOGckm1V21Vaynuagy1g9lBWVqXGA(L9(Lf(faRHcWmik)Ax)cSG9MQO6pVP1hlDF0reE8wxDGGA3(BYPsgy5H0nf4UyCR3Cm)QtXd3jHtQWkb7qnqbfuyQFTRFbWAOamWQn6x2GFbQz79l79ll8lawdfGzqu(1U(fQbw)Yc)Q0aNLb3eaf)qu3a(lwup2WPsgy5nvr1FEtRpw6(OJi84TU6az7V93KtLmWYdPBkWDX4wV5y(vNIhUtcNuHvc2TDGckOWu)Ax)cG1qbyGvB0VSb)cfJD(L9(Lf(faRHcWmik)Ax)cSG9MQO6pVP1hlDF0reE8wxDGG6V93KtLmWYdPBkWDX4wVzNIhUtcNuHvc2zhybfuyQFzl)cG1qbyGvB0VSb)cudQ8ll8RX9RX8lsOy0OyjNLtYroLm2an4xOr7xKqXOHasXYwt3hDAkAol3oDsqnqd(fA0(fjumAK9MozhfO5G0an4xOr7xKqXOz4R(td0GFz)nvr1FEtciflBnDF0PPO5SC70jb9QdKT72FtovYalpKUPa3fJB9MLg4SmXo1GJwAknCQKbw6xw4xDkE4ojCsfwjyNDGfuqHP(LT8lawdfGbwTr)Yg8lqnOYVSWVg3VgZViHIrJILCwojh5uYyd0GFHgTFrcfJgciflBnDF0PPO5SC70jb1an4xOr7xKqXOr2B6KDuGMdsd0GFHgTFrcfJMHV6pnqd(L93ufv)5nL9MozhfO5G8Qdeua92FtovYalpKUPa3fJB9MDkE4ojCsfwjyNDGfuqHP(LT8lawdfGbwTr)Yg8lqnOYVSWVg3VgZViHIrJILCwojh5uYyd0GFHgTFrcfJgciflBnDF0PPO5SC70jb1an4xOr7xKqXOr2B6KDuGMdsd0GFHgTFrcfJMHV6pnqd(L93ufv)5nvSKZYj5iNsgF1bckOC7VjNkzGLhs3uG7IXTEtawdfGzqu(1U(fkG9MQO6pVzq3Y9Pdqtj9QRUjT0uQy5T)abLB)n5ujdS8q6McCxmU1BscfJMqhzYW)sdTuXo(1U(LnVPkQ(ZBA9Xb5gUthMPFQPGV6aXUB)n5ujdS8q6McCxmU1BkzsOy0agijbmNLbAWVSWVgZVKmjumA2WjbhHcokWl2Xan4xOr7xJ7xIpLqDz2WjbhHcokWl2XWPsgyPFz)nvr1FEtkqZbP7JUcGD4MaO4hIE1bInV93KtLmWYdPBkWDX4wVjWh2Yn8wzSFHWVaRFHgTFrcfJgGpSLt3WjbJnqd(fA0(fWh2Yn8wzSFHWVqLFzHFvAGZYq1uuDSzPZkwladNkzGL(Lf(fjumA0nCs0jHZkwlad0Wnvr1FEtkqZbP7JUcGD4MaO4hIE1bcQU93KtLmWYdPBQIQ)8MGbssaZzDtbUlg36nfakMGP(fc)Yo)cnA)AC)Q0aNLrGHOQKXuhyGKeWCwgovYalVPylrGDLIj4IEGGYvhiG92FtovYalpKUPa3fJB9MsMekgnB4KGJqbhf4f7yKV10VSWVeFkH6YSHtcocfCuGxSJHtLmWYBQIQ)8M6gojym1rbAoiV6ab1U93ufv)5nbuyyg7(OZkwlGBYPsgy5H0vhiB)T)MQO6pVPUHtcgtDuGMdYBYPsgy5H0vhiO(B)n5ujdS8q6MQO6pVjyGKeWCw3uSLiWUsXeCrpqq5QdKT72Ftvu9N3CJMBlOMcWyQdqHHz8n5ujdS8q6Qdeua92FtovYalpKUPa3fJB9MJ7xIpPSaRv)PbA4MQO6pVP4tklWA1FE1bckOC7VPkQ(ZBk7nDYU6dHBYPsgy5H0vhiOy3T)MCQKbwEiDtvu9N3KmWuklDakmmJVPa3fJB9McaftWu)cHFzZBslCVdtVPDguD1bck282Ftvu9N3uPaC6a0q4TEtovYalpKU6abfuD7VjNkzGLhs3uG7IXTEtbGIjyQFHWVS7MQO6pVjGcdZy3hDfa7WnbqXpe9Qdeua7T)MCQKbwEiDtbUlg36njHIrZgn3wqnfGXuhGcdZyd0Wnvr1FEtRpw6(OJi84TU6abfu72Ftvu9N3uZgwDF0jzTaUjNkzGLhsxDGGY2F7VjNkzGLhs3ufv)5njdmLYshGcdZ4BslCVdtVPDguD1bckO(B)nvr1FEtafgMXUp6ka2HBcGIFi6n5ujdS8q6Qdeu2UB)n5ujdS8q6McCxmU1BoMFnUFvAGZYqzSoa0WgovYal9l0O9lsOy0qzSoa0WgOb)YE)Yc)AC)s(Lr8PGZcRflDXGcZosiCAWmS2j1VSLFbQFHgTFXukNc2uaStGHenzGDF0fdkmBWAUJFTRFzZBQIQ)8MIpfCwyTyPlguy(Qde7a92Ftvu9N3m0eaf1bgijbmN1n5ujdS8q6Qde7q52Ftvu9N3uXcnzx9ymN1n5ujdS8q6Qde7S72Ftvu9N3u8jLfyT6pVjNkzGLhsxDGyNnV93KtLmWYdPBkWDX4wVjjumAOaD2jHl0eaLlIz2an4xw4xJ7xIFdNAwMKf4p8y5nvr1FEtRpw6(OJi84TU6QRU5ggt7ppqSdu7affqTB7UPvfNDsqV52o8WJlw6xG1Vur1F6xHMwuJF0nhWFSd8nTD)ABI)Ifv)PFTn1Gk70pY29lq(nmmjJ9l7SPL(LDGAhO(r(r2UFTncOjbt9JSD)c1XV22Ksw6xOUmj0oSXpY29luh)c1LH)nSFnzSoa0W(fMPfUfv)j1V(0VGHcvpey)cURMqR(t)sj7qxntn(r(r2UFTnWgzbuXs)IKJpM9lXdtQLFrYeDsn(12MqWdf1VYprDaumCek4xQO6pP(1NHTm(rQO6pPMbmlEysTqgb4sEZx9NofcR(rQO6pPMbmlEysTqgb4Xatbeynw(rQO6pPMbmlEysTqgb4IpPSaRv)PFKkQ(tQzaZIhMulKraEOjakQdmqscyol)i)iB3V2gyJSaQyPFXBy8w(v1WSFvaSFPI6X(vt9lDJ2bLmWg)ivu9NueyMeAh2psfv)jfzeGl0qWPIQ)0fAAzzQWmcX)b5BnP(rQO6pPiJaCHgcovu9NUqtlltfMra3vtOv)PFKkQ(tkYiaxOHGtfv)Pl00YYuHze0stPIL(r(rQO6pPiJaCRpoi3WD6Wm9tnfSLDebjumAcDKjd)ln0sf7SRn9Jur1Fsrgb4uGMds3hDfa7WnbqXpe1YoIa4dB5gERm2i5yl6cbOwm2yKqXOr3WjrNeoRyTamqdwmEPboldLX6aqdB4ujdS0E0OjHIrdLX6aqdBGgS3psfv)jfzeGtbAoiDF0vaSd3eaf)qul7iIXiHIrJUHtIojCwXAbyGgSGekgn6goj6KWzfRfGbZWAN0DrLfJxAGZYqzSoa0WgovYalThn6XiHIrdLX6aqdBWmS2jDxuzbjumAOmwhaAyd0G9(rQO6pPiJaCafgMXUp6SI1cWYoIa4dB5gERm2i5yl6YwG6hPIQ)KImcWdnbqrDGbssaZzzzhrqcfJgkJ1bGg2anybjumAOmwhaAydMH1oP7At)ivu9NuKraU4tklWA1FAzhrmU4tklWA1FAGg8Jur1Fsrgb4GbssaZzzzhrmM4)G8TMgWajjG5Smygw7KUlHqAH4)G8TMgWajjG5SmcaftWuxeRIQ)ud2cfle)hKV10Hzvu2Jg94Lg4SmcmevLmM6adKKaMZYWPsgyPFKkQ(tkYiax3WjbJPokqZbPLDeH4)G8TMomRIYpsfv)jfzeGdgijbmNLLDeH4)G8TMomRIcn6XlnWzzeyiQkzm1bgijbmNLHtLmWs)ivu9NuKraU4tbNfwlw6IbfMTSJigB8sdCwgkJ1bGg2WPsgyjA0KqXOHYyDaOHnqd2BX4YVmIpfCwyTyPlguy2rcHtdMH1oP2cu0OzkLtbBka2jWqIMmWUp6IbfMnyn3zxB6hPIQ)KImcWdnbqrDGbssaZzzzhrmEPboldLX6aqdB4ujdSenAsOy0qzSoa0WgOb)ivu9NuKraUMnS6(OtYAb4hPIQ)KImcWjdmLYshGcdZylPfU3HPiSPFKkQ(tkYiahqHHzS7JUcGD4MaO4hI6hPIQ)KImcWfFszbwR(t)ivu9NuKraoaR4YXukNc2YoIy8XykLtbBka2jWqIMmWUp6IbfMnWkyEmA0mLYPGnwFCqUH70Hz6NAkydScMhJgntPCkyJMnS6(Ol0r2PP0jzTamWkyEmA0mLYPGnWm8J3Y9rxas0sNeZkm1aRG5X27h5hPIQ)KAOLMsflry9Xb5gUthMPFQPGTSJiiHIrtOJmz4FPHwQyNDTPFKkQ(tQHwAkvSezeGtbAoiDF0vaSd3eaf)qul7icjtcfJgWajjG5SmqdwmMKjHIrZgoj4iuWrbEXogOb0Ohx8PeQlZgoj4iuWrbEXogovYalT3psfv)j1qlnLkwImcWPanhKUp6ka2HBcGIFiQLDebWh2Yn8wzmcWIgnjumAa(WwoDdNem2anGgnWh2Yn8wzmcuzrPboldvtr1XMLoRyTamCQKbwAbjumA0nCs0jHZkwlad0GFKkQ(tQHwAkvSezeGdgijbmNLLITeb2vkMGlkcuSSJieakMGPiSdn6XlnWzzeyiQkzm1bgijbmNLHtLmWs)ivu9NudT0uQyjYiax3WjbJPokqZbPLDeHKjHIrZgoj4iuWrbEXog5BnTq8PeQlZgoj4iuWrbEXogovYal9Jur1Fsn0stPILiJaCafgMXUp6SI1cWpsfv)j1qlnLkwImcW1nCsWyQJc0Cq6hPIQ)KAOLMsflrgb4GbssaZzzPylrGDLIj4IIaf)ivu9NudT0uQyjYiaFJMBlOMcWyQdqHHzSFKkQ(tQHwAkvSezeGl(KYcSw9Nw2reJl(KYcSw9NgOb)ivu9NudT0uQyjYiax2B6KD1hc(rQO6pPgAPPuXsKraozGPuw6auyygBjTW9omfHDguzzhriaumbtryt)ivu9NudT0uQyjYiaxPaC6a0q4T6hPIQ)KAOLMsflrgb4akmmJDF0vaSd3eaf)qul7icbGIjykc78Jur1Fsn0stPILiJaCRpw6(OJi84TSSJiiHIrZgn3wqnfGXuhGcdZyd0GFKkQ(tQHwAkvSezeGRzdRUp6KSwa(rQO6pPgAPPuXsKraozGPuw6auyygBjTW9omfHDgu5hPIQ)KAOLMsflrgb4akmmJDF0vaSd3eaf)qu)ivu9NudT0uQyjYiax8PGZcRflDXGcZw2reJnEPboldLX6aqdB4ujdSenAsOy0qzSoa0WgOb7TyC5xgXNcolSwS0fdkm7iHWPbZWANuBbkA0mLYPGnfa7eyirtgy3hDXGcZgSM7SRn9Jur1Fsn0stPILiJa8qtauuhyGKeWCw(rQO6pPgAPPuXsKraUIfAYU6Xyol)ivu9NudT0uQyjYiax8jLfyT6p9Jur1Fsn0stPILiJaCRpw6(OJi84TSSJiiHIrdfOZojCHMaOCrmZgOblgx8B4uZYKSa)Hhl9J8Jur1FsnI)dY3AsreBmtg(xAzhrqcfJgDdNeDs4SI1cWan4hPIQ)KAe)hKV1KImcWHOSRlg2YuHzeQTrbuSsDXpl3hDdVvgBzhri(piFRPHYyDaOHnygw7KUlcuafn6XlnWzzOmwhaAydNkzGL(rQO6pPgX)b5BnPiJaCik76IHTmvygHsb2OjtDy12ESt8ynyzhrmMKjHIrdwTTh7epwdojtcfJgAPIDS12BbjumA0nCs0jHZkwlad0G9OrlzsOy0GvB7XoXJ1GtYKqXOHwQyheG6hPIQ)KAe)hKV1KImcWPmwhaAy)ivu9NuJ4)G8TMuKraUUHtIojCwXAb4hPIQ)KAe)hKV1KImcWb(WwoDdNem2YoIGekgn6goj6KWzfRfGbAanAX)b5Bnn6goj6KWzfRfGbZWANuBHAG6hPIQ)KAe)hKV1KImcWh(Q)0YoIGekgn6goj6KWzfRfGbAWpsfv)j1i(piFRjfzeGRuaoDaAi8wTSJiiHIrJUHtIojCwXAbyKV10psfv)j1i(piFRjfzeGtgykTtc3hDuiyyg7hPIQ)KAe)hKV1KImcWjdmL2jH7JofQGGt)ivu9NuJ4)G8TMuKraozGP0ojCF0zTZIX(rQO6pPgX)b5BnPiJaCYatPDs4(OJoG7KWpsfv)j1i(piFRjfzeGVrZTfutbym1bOWWm2psfv)j1i(piFRjfzeGl7nDYU6dbl7icGpSLB4TYyJKJTOlBbQFKkQ(tQr8Fq(wtkYiahGvC5ykLtbBzhrqcfJgkJ1bGg2anGg94Lg4SmugRdanSHtLmWs)ivu9NuJ4)G8TMuKraoeLDDXWul7icsOy0qzSoa0WgOb0OhV0aNLHYyDaOHnCQKbw6hPIQ)KAe)hKV1KImcWHFyol3hDeHhVLLDeXaM34iesdkgDdNemM6OanhKwi(piFRPr3WjbJPokqZbPbZWANu)ivu9NuJ4)G8TMuKraoeLDDXWwMkmJGa)jb1nGByn4WkbBzhrm2yI)dY3AAadKKaMZYeHcbhMfakMGDvdZ2cvOrp24Lg4SmcmevLmM6adKKaMZYWPsgyPfdyEJJqinOyadKKaMZYE7Tq8Fq(wtJUHtcgtDuGMdsdMH1oP2cvwqcfJgkJ1bGg2GzyTtQTqL9OrpgjumAOmwhaAydMH1oP7Ik79Jur1FsnI)dY3Asrgb4qu21fdBzQWmcygZ7uak1f1KWYoIyCsOy0OB4KOtcNvSwagOblgJekgnugRdanSbAan6XlnWzzOmwhaAydNkzGL27hPIQ)KAe)hKV1KImcWHOSRlg2YuHzey12Kq5ouhzt4WS0rcv1N(r(rQO6pPg4UAcT6prqbAoiDF0vaSd3eaf)qul7icsOy0qbAoiDF0vaSd3eaf)quJ8TMwmgWh2Yn8wzSrYXw0fcqrJMekgnYEtNSBacp8u2anyVFKkQ(tQbURMqR(tKraU1hlDF0reE8ww2reKqXOHc0zNeUqtauUiuiyGgSGekgnuGo7KWfAcGYfHcbdMH1oP7siK2GD(rQO6pPg4UAcT6prgb4wFS09rhr4XBzzhrmgaRHcWmiQDrfO27hPIQ)KAG7Qj0Q)ezeGB9Xs3hDeHhVLLDeXyDkE4ojCsfwjyhkGckOGct3fG1qbyGvB0gqXyhyT3cawdfGzqu7cwWArPboldUjak(HOUb8xSOESHtLmWs)ivu9NudCxnHw9NiJaCRpw6(OJi84TSSJigRtXd3jHtQWkb7qXMGckOW0Dbynuagy1gTbumOM9waWAOamdIAxWcw)ivu9NudCxnHw9NiJaCRpw6(OJi84TSSJigRtXd3jHtQWkb7qnqbfuy6UaSgkadSAJ2aOMT3ElaynuaMbrTlQbwlknWzzWnbqXpe1nG)If1JnCQKbw6hPIQ)KAG7Qj0Q)ezeGB9Xs3hDeHhVLLDeXyDkE4ojCsfwjy32bkOGct3fG1qbyGvB0gqXyN9waWAOamdIAxWcw)iB3Vur1FsnWD1eA1FImcWPanhKUp6ka2HBcGIFiQLDebjumAOanhKUp6ka2HBcGIFiQr(wtlgd4dB5gERm2w2HgnjumAK9Moz3aeE4PSbAWE)ivu9NudCxnHw9NiJaCciflBnDF0PPO5SC70jb1YoIOtXd3jHtQWkb7SdSGckm1waSgkadSAJ2aOguzX4JrcfJgfl5SCsoYPKXgOb0OjHIrdbKILTMUp60u0CwUD6KGAGgqJMekgnYEtNSJc0CqAGgqJMekgndF1FAGgS3psfv)j1a3vtOv)jYiax2B6KDuGMdsl7iIsdCwMyNAWrlnLgovYalTOtXd3jHtQWkb7SdSGckm1waSgkadSAJ2aOguzX4JrcfJgfl5SCsoYPKXgOb0OjHIrdbKILTMUp60u0CwUD6KGAGgqJMekgnYEtNSJc0CqAGgqJMekgndF1FAGgS3psfv)j1a3vtOv)jYiaxXsolNKJCkzSLDerNIhUtcNuHvc2zhybfuyQTaynuagy1gTbqnOYIXhJekgnkwYz5KCKtjJnqdOrtcfJgciflBnDF0PPO5SC70jb1anGgnjumAK9MozhfO5G0anGgnjumAg(Q)0anyVFKkQ(tQbURMqR(tKraEq3Y9Pdqtj1YoIaG1qbyge1UOa2BshyXbcQHAxD1Da]] )


end
