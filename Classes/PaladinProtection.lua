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
        crusader_aura = {
            id = 32223,
            duration = 3600,
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


        -- Generic Aura to cover any Aura.
        paladin_aura = {
            alias = { "concentration_aura", "crusader_aura", "devotion_aura", "retribution_aura" },
            aliasMode = "first",
            aliasType = "buff",
            duration = 3600,
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

            nobuff = "paladin_aura",

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

            nobuff = "paladin_aura",

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
            id = function () return IsSpellKnownOrOverridesKnown( 212641 ) and 212641 or 86659 end,
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
            },

            copy = { 86659, 212641 }
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

            nobuff = "paladin_aura",

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


    spec:RegisterPack( "Protection Paladin", 20201205, [[dquwWaqiqspckv2euYOeLCkrPwfukEfeAwKi3ckv1UOYVardtLYXGclJKYZir10ajUMkvTnvQ03GsjJdkv5CKOW6GsPQ5bf19GO9PsfhKeLAHGupKefzIqPu5IqrGtcfHwPOyMqrq7eegkueTuOukpvHPQsAVk9xrgSkomLfdvpMutMWLrTzf9zqnAv50sTAiWRHGMnvDBiTBHFdmCr1XjrjlhXZrA6sUUQA7QeFNegpuKopjvRNef18jj7NOxm2R7qyfVqO2n1UHHA3U3HHAkh7PCOSJs9CEh5MgHgmVJWq5DGjjGI1vdc5btAEt0XoYn19atSx3bf8jAEhVQYPy7Hes4UEFCNgGcjTr)ERAqOj2SGK2OAi3b(V9fMyS47qyfVqO2n1UHHA3U3HHAkh7PCLVd7xpazhJgvzAhVwi4yX3HGP6DGDYdMKakwxniKhmP5nrhYmyN8GTJ1mkotKhLRK8O2n1UjZiZGDYJY0ZcyMkZGDYd2xEu2cblKhSng)Jq2jZGDYd2xEW2yuWfwEgmXYFnQ8qyArAD1GGkpGqEq)(QZ9S8G2vdBvdc5XWBFxntDYmyN8G9LhmXOyyIvS8GciS8aMYt9y5z8mbqH3cbvEu2ysmHUD4BAr3R7qWt77R96cbg71Dy6QbXoim(hH8o4WW9SyHERfc12R7Gdd3ZIf6Dy6QbXo0M3NmD1Gi5BATdFtRuyO8o0aGxaue0Twiu(EDhCy4EwSqVdtxni2H28(KPRgejFtRD4BALcdL3bAxnSvni2AHak71DWHH7zXc9omD1GyhAZ7tMUAqK8nT2HVPvkmuEh0YcHreBTqC)EDhCy4EwSqVdnPlM02oEaV6PCGcM4e8S1DjpiLNBYdwYtwYtwYd(FoD2foG7aoPGy1Z9ZLhSKhOkpL55OCuMy5Vg1XHH7zH8KT8OsL8G)NthLjw(RrD)C5j7Dy6QbXoOVM9IeyMQhNin8RyWNU1cXD3R7Gdd3ZIf6DOjDXK22rwYd(FoD2foG7aoPGy1Z9ZLhSKh8)C6SlCa3bCsbXQNJWOwhu5bZYduKhSKhOkpL55OCuMy5Vg1XHH7zH8KT8OsL8KL8G)NthLjw(RrDeg16GkpywEGI8GL8G)NthLjw(RrD)C5j7Dy6QbXoOVM9IeyMQhNin8RyWNU1cb2AVUdomCplwO3HM0ftABhpGx9uoqbtCcE26UKN7ip32HPRge74zOOmjbMjfeREBTqG92R7Gdd3ZIf6DOjDXK22b(FoDuMy5Vg19ZLhSKh8)C6OmXYFnQJWOwhu5bZYJY3HPRge7W3WVIMqWxaJYrT1cHYyVUdomCplwO3HM0ftABhqvE0GGYAIvniC)8Dy6QbXo0GGYAIvni2AHaJB71DWHH7zXc9o0KUysB7il5rdaEbqr4qWxaJYr5imQ1bvEWS8aRfYdwYJga8cGIWHGVagLJYPFgbMPPjX0vdcZlp3rEWqEWsE0aGxauejcB6sEYwEuPsEGQ8uMNJYPjFQjycnHGVagLJYXHH7zXomD1Gyhi4lGr5O2AHadm2R7Gdd3ZIf6DOjDXK22Hga8cGIirytx7W0vdIDyx4aMj0e91SxS1cbgQTx3bhgUNfl07qt6IjTTdna4fafrIWMUKhvQKhOkpL55OCAYNAcMqti4lGr5OCCy4EwSdtxni2bc(cyuoQTwiWq571DWHH7zXc9o0KUysB7aQYtzEokhLjw(RrDCy4EwipQujp4)50rzIL)Au3pFhMUAqSdFd)kAcbFbmkh1wleyaL96o4WW9SyHEhMUAqSdCptPSi9muuMSdArAeY0DO8TwiW4(96omD1GyhpdfLjjWmvporA4xXGpDhCy4EwSqV1cbg3DVUdtxni2HgeuwtSQbXo4WW9SyHERT2roH1auCR2RleySx3HPRge7qWxavdIK9j2o4WW9SyHERfc12R7W0vdIDm9m9Pj2S2bhgUNfl0BTqO896omD1GyhAqqznXQge7Gdd3ZIf6TwiGYEDhMUAqSdFd)kAcbFbmkh1o4WW9SyHERT2bTSqyeXEDHaJ96o4WW9SyHEhAsxmPTDiy8)C6qWxaJYr5(5YdwYtwYJGX)ZP7chW887t0hqJq3pxEuPsEGQ8ObH43L7chW887t0hqJqhhgUNfYt27W0vdIDqFn7fjWmvporA4xXGpDRfc12R7Gdd3ZIf6DOjDXK22Xd4vpLduWe5bP8CV8OsL8G)Nt3d4vpzx4aMjUFU8OsL88aE1t5afmrEqkpqrEWsEkZZr5OwORE2SiPGy1ZXHH7zH8GL8G)NtNDHd4oGtkiw9C)8Dy6QbXoOVM9IeyMQhNin8RyWNU1cHY3R7Gdd3ZIf6Dy6QbXoqWxaJYrTdnPlM02o0pJaZu5bP8OM8OsL8av5PmphLtt(utWeAcbFbmkhLJdd3ZIDOvx75uzeyUOleyS1cbu2R7Gdd3ZIf6DOjDXK22HGX)ZP7chW887t0hqJqNaOiKhSKhnie)UCx4aMNFFI(aAe64WW9SyhMUAqSd7chWmHMOVM9ITwiUFVUdtxni2XZqrzscmtkiw92bhgUNfl0BTqC396omD1Gyh2foGzcnrFn7f7Gdd3ZIf6TwiWw71DWHH7zXc9omD1Gyhi4lGr5O2HwDTNtLrG5IUqGXwleyV96omD1GyhxSqz9B6Jj00ZqrzYo4WW9SyHERfcLXEDhCy4EwSqVdnPlM02oGQ8ObbL1eRAq4(57W0vdIDObbL1eRAqS1cbg32R7W0vdIDi6lDWPc497Gdd3ZIf6TwiWaJ96o4WW9SyHEhMUAqSdCptPSi9muuMSdnPlM02o0pJaZu5bP8O8DqlsJqMUd1CqzRfcmuBVUdtxni2HrFCKEM3duSdomCplwO3AHadLVx3bhgUNfl07qt6IjTTd9ZiWmvEqkpQTdtxni2XZqrzscmt1JtKg(vm4t3AHadOSx3bhgUNfl07qt6IjTTd8)C6UyHY630htOPNHIYe3pFhMUAqSdfaIibMjypGO(wleyC)EDhCy4EwSqVdtxni2bUNPuwKEgkkt2bTincz6ouZbLTwiW4U71Dy6QbXoEgkktsGzQECI0WVIbF6o4WW9SyHERfcmWw71Dy6QbXo8n8ROje8fWOCu7Gdd3ZIf6TwiWa7Tx3HPRge7WiAl4ubieoQDWHH7zXc9wleyOm2R7W0vdIDObbL1eRAqSdomCplwO3AHqTB71DWHH7zXc9o0KUysB7a)pNo6RJoGt(g(vPjHz3pxEWsEGQ8Obx4WIYfSMa8aIyhMUAqSdfaIibMjypGO(wBTdna4fafbDVUqGXEDhCy4EwSqVdnPlM02oW)ZPZUWbChWjfeREUF(omD1GyhZMW4EaqS1cHA71Dy6QbXoOmXYFn6o4WW9SyHERfcLVx3HPRge7WUWbChWjfeRE7Gdd3ZIf6TwiGYEDhCy4EwSqVdnPlM02oW)ZPZUWbChWjfeREUFU8OsL8ObaVaOiC2foG7aoPGy1ZryuRdQ8Ch55U32HPRge74b8QNSlCaZKTwiUFVUdomCplwO3HM0ftABh4)50zx4aUd4KcIvp3pFhMUAqSJCq1GyRfI7Ux3bhgUNfl07qt6IjTTd8)C6SlCa3bCsbXQNtaue7W0vdIDy0hhPN59afBTqGT2R7W0vdIDG7zkTd4eyMOFuuMSdomCplwO3AHa7Tx3HPRge7a3ZuAhWjWmz)6Jg7Gdd3ZIf6Twiug71Dy6QbXoW9mL2bCcmtk6OyYo4WW9SyHERfcmUTx3HPRge7a3ZuAhWjWmrZjDaVdomCplwO3AHadm2R7W0vdIDCXcL1VPpMqtpdfLj7Gdd3ZIf6TwiWqT96o4WW9SyHEhAsxmPTD8aE1t5afmXj4zR7sEUJ8CBhMUAqSdrFPdovaVFRfcmu(EDhCy4EwSqVdnPlM02oW)ZPJYel)1OUFU8OsL8av5PmphLJYel)1OoomCpl2HPRge74t5uxmkDRfcmGYEDhCy4EwSqVdnPlM02oYj8LeSw4WWzx4aMj0e91SxipyjpAaWlakcNDHdyMqt0xZEHJWOwh0Dy6QbXoqbOCujWmb7be13AHaJ73R7Gdd3ZIf6Dy6QbXoGjGaMMYjnQ5tedM3HM0ftABhzjpzjpAaWlakchc(cyuok3879jcRFgbMtvJYYZDKhOipQujpzjpqvEkZZr50Kp1emHMqWxaJYr54WW9SqEWsEYj8LeSw4WWHGVagLJsEYwEYwEWsE0aGxaueo7chWmHMOVM9chHrToOYZDKhOipyjp4)50rzIL)AuhHrToOYZDKhOipzlpQujpzjp4)50rzIL)AuhHrToOYdMLhOipzVJWq5DatabmnLtAuZNigmV1cbg3DVUdomCplwO3HPRge7aLjmcRNrttlG3HM0ftABhqvEW)ZPZUWbChWjfeREUFU8GL8KL8G)NthLjw(RrD)C5rLk5bQYtzEokhLjw(RrDCy4EwipzVJWq5DGYegH1ZOPPfWBTqGb2AVUdomCplwO3ryO8oiMYS4hiKMWB4eHfj8FvGyhMUAqSdIPml(bcPj8goryrc)xfi2ARDG2vdBvdI96cbg71DWHH7zXc9o0KUysB7a)pNo6RzVibMP6Xjsd)kg8PobqripyjpzjppGx9uoqbtCcE26UKhKYZn5rLk5b)pNorFPdoL)j5ak7(5Yt27W0vdIDqFn7fjWmvporA4xXGpDRfc12R7Gdd3ZIf6DOjDXK22b(FoD0xhDaN8n8RsZV37(5YdwYd(FoD0xhDaN8n8RsZV37imQ1bvEWS8aRfYd2ipQTdtxni2HcarKaZeShquFRfcLVx3bhgUNfl07qt6IjTTJSKNhB(65Y1L8Gz5bk3KNS3HPRge7qbGisGzc2diQV1cbu2R7Gdd3ZIf6DOjDXK22rwYthAaAhWjHHAWCcJB3UDdLkpywEES5RNd1Wu5bBKhmCQDV8KT8GL88yZxpxUUKhmlp3FV8GL8uMNJYrA4xXGpnLtafRlaXXHH7zXomD1GyhkaercmtWEar9TwiUFVUdomCplwO3HM0ftABhzjpDObODaNegQbZjmu(TB3qPYdMLNhB(65qnmvEWg5bd3DLNSLhSKNhB(65Y1L8Gz55(73HPRge7qbGisGzc2diQV1cXD3R7Gdd3ZIf6DOjDXK22rwYthAaAhWjHHAWC6U3UDdLkpywEES5RNd1Wu5bBKNBoSL8KT8GL88yZxpxUUKhmlp39E5bl5PmphLJ0WVIbFAkNakwxaIJdd3ZIDy6QbXouaiIeyMG9aI6BTqGT2R7Gdd3ZIf6DOjDXK22rwYthAaAhWjHHAWCszC72nuQ8Gz55XMVEoudtLhSrEWWPM8KT8GL88yZxpxUUKhmlp3F)omD1GyhkaercmtWEar9TwiWE71DWHH7zXc9o0KUysB7OdnaTd4KWqnyoP293UHsLN7ipp281ZHAyQ8GnYZnhuKhSKhOkpzjp4)50zebhvsWtoemX9ZLhvQKh8)C6G)gr0wKaZKf6MJkHWoGPUFU8OsL8G)NtNOV0bNOVM9c3pxEuPsEW)ZPlhuniC)C5j7Dy6QbXoG)gr0wKaZKf6MJkHWoGPBTqOm2R7Gdd3ZIf6DOjDXK22rzEok3SdZNOLfchhgUNfYdwYthAaAhWjHHAWCsT7VDdLkp3rEES5RNd1Wu5bBKNBoOipyjpqvEYsEW)ZPZicoQKGNCiyI7NlpQujp4)50b)nIOTibMjl0nhvcHDatD)C5rLk5b)pNorFPdorFn7fUFU8OsL8G)NtxoOAq4(5Yt27W0vdIDi6lDWj6RzVyRfcmUTx3bhgUNfl07qt6IjTTJo0a0oGtcd1G5KA3F7gkvEUJ88yZxphQHPYd2ip3CqrEWsEGQ8KL8G)NtNreCujbp5qWe3pxEuPsEW)ZPd(BerBrcmtwOBoQec7aM6(5YJkvYd(FoDI(shCI(A2lC)C5rLk5b)pNUCq1GW9ZLNS3HPRge7WicoQKGNCiyYwleyGXEDhCy4EwSqVdnPlM02oES5RNlxxYdMLhmUFhMUAqSdVPEcePNfc6wBT1oUWeAdIfc1UP2nmWqnLVdfgj6aMUdmr0CaPyH8CV8y6QbH84BArDYm7iNaMTN3b2jpyscOyD1GqEWKM3eDiZGDYd2owZO4mrEuUsYJA3u7MmJmd2jpktplGzQmd2jpyF5rzleSqEW2y8pczNmd2jpyF5bBJrbxy5zWel)1OYdHPfP1vdcQ8ac5b97Ro3ZYdAxnSvniKhdV9D1m1jZGDYd2xEWeJIHjwXYdkGWYdykp1JLNXZeafEleu5rzJjXe6KzKzWo5btaMY6FXc5bNNaclpAakUvYdod3b1jpkBTMZlQ8eGa7)mc687LhtxniOYdi8Q7KzmD1GG6YjSgGIBfIiHuWxavdIK9jMmJPRgeuxoH1auCRqejKtptFAInlzgtxniOUCcRbO4wHisi1GGYAIvniKzmD1GG6YjSgGIBfIiH03WVIMqWxaJYrjZiZGDYdMamL1)IfYdFHjQlpvJYYt9y5X0fGipnvESlw7nCp7KzmD1GGIKW4FeYYmMUAqqrejKAZ7tMUAqK8nTukmugPga8cGIGkZy6QbbfrKqQnVpz6QbrY30sPWqzKOD1Ww1GqMX0vdckIiHuBEFY0vdIKVPLsHHYiPLfcJiKzKzmD1GGIisiPVM9IeyMQhNin8RyWNQupr(aE1t5afmXj4zR7c5nSYkl8)C6SlCa3bCsbXQN7NJfulZZr5OmXYFnQJdd3ZISvPc)pNoktS8xJ6(5zlZy6QbbfrKqsFn7fjWmvporA4xXGpvPEIml8)C6SlCa3bCsbXQN7NJf(FoD2foG7aoPGy1ZryuRdkMHcwqTmphLJYel)1OoomCplYwLQSW)ZPJYel)1OocJADqXmuWc)pNoktS8xJ6(5zlZy6QbbfrKq(muuMKaZKcIvpL6jYhWREkhOGjobpBDx35MmJPRgeuercPVHFfnHGVagLJsPEIe)pNoktS8xJ6(5yH)NthLjw(RrDeg16GIzLlZy6QbbfrKqQbbL1eRAqOuprcvniOSMyvdc3pxMX0vdckIiHebFbmkhLs9ezwAaWlakchc(cyuokhHrToOygwlWsdaEbqr4qWxaJYr50pJaZ00Ky6QbH5VdgyPbaVaOise20v2Qub1Y8Cuon5tnbtOje8fWOCuoomCplKzmD1GGIisiTlCaZeAI(A2luQNi1aGxauejcB6sMX0vdckIiHebFbmkhLs9ePga8cGIirytxQub1Y8Cuon5tnbtOje8fWOCuoomCplKzmD1GGIisi9n8ROje8fWOCuk1tKqTmphLJYel)1OoomCpluPc)pNoktS8xJ6(5YmMUAqqrejK4EMszr6zOOmrjArAeYuKkxMX0vdckIiH8zOOmjbMP6Xjsd)kg8PYmMUAqqrejKAqqznXQgeYmYmMUAqqD0YcHreiIes6RzVibMP6Xjsd)kg8Pk1tKcg)pNoe8fWOCuUFowzjy8)C6UWbmp)(e9b0i09ZvPcQAqi(D5UWbmp)(e9b0i0XHH7zr2YmMUAqqD0YcHreiIes6RzVibMP6Xjsd)kg8Pk1tKpGx9uoqbtqEVkv4)509aE1t2foGzI7NRs1d4vpLduWeKqbRY8CuoQf6QNnlskiw9CCy4EwGf(FoD2foG7aoPGy1Z9ZLzmD1GG6OLfcJiqejKi4lGr5OusRU2ZPYiWCrrIHs9eP(zeyMIunvQGAzEokNM8PMGj0ec(cyuokhhgUNfYmMUAqqD0YcHreiIes7chWmHMOVM9cL6jsbJ)Nt3foG553NOpGgHobqrGLgeIFxUlCaZZVprFancDCy4EwiZy6Qbb1rllegrGisiFgkktsGzsbXQNmJPRgeuhTSqyebIiH0UWbmtOj6RzVqMX0vdcQJwwimIarKqIGVagLJsjT6ApNkJaZffjgYmMUAqqD0YcHreiIeYlwOS(n9XeA6zOOmrMX0vdcQJwwimIarKqQbbL1eRAqOuprcvniOSMyvdc3pxMX0vdcQJwwimIarKqk6lDWPc49YmMUAqqD0YcHreiIesCptPSi9muuMOeTinczks1CqrPEIu)mcmtrQCzgtxniOoAzHWicercPrFCKEM3duiZy6Qbb1rllegrGisiFgkktsGzQECI0WVIbFQs9eP(zeyMIunzgtxniOoAzHWicercPcarKaZeShquxPEIe)pNUlwOS(n9XeA6zOOmX9ZLzmD1GG6OLfcJiqejK4EMszr6zOOmrjArAeYuKQ5GImJPRgeuhTSqyebIiH8zOOmjbMP6Xjsd)kg8PYmMUAqqD0YcHreiIesFd)kAcbFbmkhLmJPRgeuhTSqyebIiH0iAl4ubieokzgtxniOoAzHWicercPgeuwtSQbHmJPRgeuhTSqyebIiHubGisGzc2diQRuprI)Nth91rhWjFd)Q0KWS7NJfu1GlCyr5cwtaEariZiZy6Qbb1PbaVaOiOiNnHX9aGqPEIe)pNo7chWDaNuqS65(5YmMUAqqDAaWlakckIiHKYel)1OYmMUAqqDAaWlakckIiH0UWbChWjfeREYmMUAqqDAaWlakckIiH8b8QNSlCaZeL6js8)C6SlCa3bCsbXQN7NRsLga8cGIWzx4aUd4KcIvphHrToO35U3KzmD1GG60aGxaueuerczoOAqOuprI)NtNDHd4oGtkiw9C)CzgtxniOona4fafbfrKqA0hhPN59afk1tK4)50zx4aUd4KcIvpNaOiKzmD1GG60aGxaueuercjUNP0oGtGzI(rrzImJPRgeuNga8cGIGIisiX9mL2bCcmt2V(OHmJPRgeuNga8cGIGIisiX9mL2bCcmtk6OyImJPRgeuNga8cGIGIisiX9mL2bCcmt0CshWYmMUAqqDAaWlakckIiH8IfkRFtFmHMEgkktKzmD1GG60aGxaueuercPOV0bNkG3Rupr(aE1t5afmXj4zR76o3KzmD1GG60aGxaueuerc5NYPUyuQs9ej(FoDuMy5Vg19ZvPcQL55OCuMy5Vg1XHH7zHmJPRgeuNga8cGIGIisirbOCujWmb7be1vQNiZj8LeSw4WWzx4aMj0e91SxGLga8cGIWzx4aMj0e91Sx4imQ1bvMX0vdcQtdaEbqrqrejKFkN6IrvkmugjmbeW0uoPrnFIyWSs9ezwzPbaVaOiCi4lGr5OCZV3NiS(zeyovnkFhOOsvwqTmphLtt(utWeAcbFbmkhLJdd3ZcSYj8LeSw4WWHGVagLJk7SXsdaEbqr4SlCaZeAI(A2lCeg16GEhOGf(FoDuMy5Vg1ryuRd6DGs2QuLf(FoDuMy5Vg1ryuRdkMHs2YmMUAqqDAaWlakckIiH8t5uxmQsHHYirzcJW6z000cyL6jsOI)NtNDHd4oGtkiw9C)CSYc)pNoktS8xJ6(5Qub1Y8CuoktS8xJ64WW9SiBzgtxniOona4fafbfrKq(PCQlgvPWqzKetzw8dest4nCIWIe(VkqiZiZy6Qbb1H2vdBvdcK0xZErcmt1JtKg(vm4tvQNiX)ZPJ(A2lsGzQECI0WVIbFQtaueyL1d4vpLduWeNGNTUlK3uPc)pNorFPdoL)j5ak7(5zlZy6Qbb1H2vdBvdcercPcarKaZeShquxPEIe)pNo6RJoGt(g(vP537D)CSW)ZPJ(6Od4KVHFvA(9EhHrToOygwlWg1KzmD1GG6q7QHTQbbIiHubGisGzc2diQRuprM1JnF9C56cZq5w2YmMUAqqDOD1Ww1GarKqQaqejWmb7be1vQNiZQdnaTd4KWqnyoHXTB3UHsX8JnF9COgMIny4u7(SX6XMVEUCDH57VhRY8Cuosd)kg8PPCcOyDbioomCplKzmD1GG6q7QHTQbbIiHubGisGzc2diQRuprMvhAaAhWjHHAWCcdLF72nukMFS5RNd1WuSbd3DZgRhB(65Y1fMV)EzgtxniOo0UAyRAqGisivaiIeyMG9aI6k1tKz1HgG2bCsyOgmNU7TB3qPy(XMVEoudtXMBoSv2y9yZxpxUUW8DVhRY8Cuosd)kg8PPCcOyDbioomCplKzmD1GG6q7QHTQbbIiHubGisGzc2diQRuprMvhAaAhWjHHAWCszC72nukMFS5RNd1WuSbdNAzJ1JnF9C56cZ3FVmd2jpMUAqqDOD1Ww1GarKqsFn7fjWmvporA4xXGpvPEIe)pNo6RzVibMP6Xjsd)kg8PobqrGvwpGx9uoqbtUJAQuH)NtNOV0bNY)KCaLD)8SLzmD1GG6q7QHTQbbIiHe(BerBrcmtwOBoQec7aMQupr2HgG2bCsyOgmNu7(B3qP35XMVEoudtXMBoOGfuZc)pNoJi4OscEYHGjUFUkv4)50b)nIOTibMjl0nhvcHDatD)CvQW)ZPt0x6Gt0xZEH7NRsf(FoD5GQbH7NNTmJPRgeuhAxnSvniqejKI(shCI(A2luQNilZZr5MDy(eTSq44WW9SaRo0a0oGtcd1G5KA3F7gk9op281ZHAyk2CZbfSGAw4)50zebhvsWtoemX9ZvPc)pNo4VreTfjWmzHU5OsiSdyQ7NRsf(FoDI(shCI(A2lC)CvQW)ZPlhuniC)8SLzmD1GG6q7QHTQbbIiH0icoQKGNCiyIs9ezhAaAhWjHHAWCsT7VDdLENhB(65qnmfBU5Gcwqnl8)C6mIGJkj4jhcM4(5QuH)Nth83iI2IeyMSq3Cuje2bm19ZvPc)pNorFPdorFn7fUFUkv4)50LdQgeUFE2YmMUAqqDOD1Ww1GarKq6n1tGi9SqqvQNiFS5RNlxxygJ73bnN1le39UBT1Ua]] )


end
