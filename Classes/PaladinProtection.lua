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

            usable = function () return target.health_pct < 20 or ( level > 57 and buff.avenging_wrath.up ) or buff.hammer_of_wrath_hallow.up or buff.negative_energy_token_proc.up, "requires low health, avenging_wrath, or ashen_hallow" end,
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

        potion = "phantom_fire",

        package = "Protection Paladin",
    } )


    spec:RegisterPack( "Protection Paladin", 20201206, [[dmuKUaqiiLEecQ2eczuQaNsf0QGu4vqQMfc1Turj2fv(LQsdtO6yiWYis9mHsnnvv6AQQyBQO4BiOyCQOKohckToIKqZdb5EqY(ek5GejjluvvpKij1ejscUOkkfNufLsRKOANQidLiPSuvuQEQctvfAVk9xbdwLomPfJOhtPjt4YO2SI(mOgTQCAPwTkQEnrIztv3gIDl63adxihNiPA5q9CKMUKRdY2vv8DIy8qk68cfRNijA(eL9tXlb7XDi0I3tshx64eiD8Z4KMG4XooHzhvmr8oIuRuuyEhPIW7qQHbfBRgKMRut9QOZDePX4bQypUdkacB5D8QkIkv87x4UEqKola5lTrG8A1G0I1z9L2i2V7GeQ91zBUK7qOfVNKoU0Xjq64NXjnbXJD8yVdfQEa8ognIu9oETqW5sUdbtT7GWnxPgguSTAqAUsn1RIonYjCZvQaBzesgBUNHyZv64sh3i3iNWnxP6NMWm1iNWn3ZI5kvjeSWCp7mjKuyNroHBUNfZ9SZiGpS5oySg9AeZfZ0c32Qbj1CbP5Ia5RoYZMlsxnSwninxLS9D1m1TdFtl6EChcEQq(ApUNiypUd1wni3bMjHKcVdovspl2)BTNKEpUdovspl2)7qTvdYDyvVpO2QbzW30Ah(MwHur4DybaVaijPBTNI9EChCQKEwS)3HARgK7WQEFqTvdYGVP1o8nTcPIW7aPRgwRgKBTN(DpUdovspl2)7qTvdYDyvVpO2QbzW30Ah(MwHur4DqlnfkwS1E6N94o4uj9Sy)VdlUlg36oEaFmHiGeg7e8STDzUOm34MlrM7bM7bMlj0C60pCc3jCqcwRNdkYCjYCrR5wQNZYrzSg9AehNkPNfM7HMRmzMlj0C6OmwJEnIdkYCpChQTAqUd6RzViaMH6XbCd)kgar3ApDM94o4uj9Sy)VdlUlg36ooWCjHMtN(Ht4oHdsWA9CqrMlrMlj0C60pCc3jCqcwRNdZiANuZLqM7VMlrMlAn3s9CwokJ1OxJ44uj9SWCp0CLjZCpWCjHMthLXA0RrCygr7KAUeYC)1CjYCjHMthLXA0RrCqrM7H7qTvdYDqFn7fbWmupoGB4xXai6w7jcZEChCQKEwS)3Hf3fJBDhpGpMqeqcJDcE22Um3yzUX3HARgK74PiimoaMbjyTEBTNoR7XDWPs6zX(FhwCxmU1DqcnNokJ1OxJ4GImxImxsO50rzSg9AehMr0oPMlHm3yVd1wni3HVHFfnCoKagHZAR9eHDpUdovspl2)7WI7IXTUd0AUwqszlwRgKoOODO2Qb5oSGKYwSwni3Aprq894o4uj9Sy)VdlUlg36ooWCTaGxaKKUZHeWiCwomJODsnxczUWwH5sK5AbaVaijDNdjGr4SC2NIHzAyIvB1Gu9MBSmxcmxImxla4fajzaZQTm3dnxzYmx0AUL65SCwmevfmMgohsaJWz54uj9SyhQTAqUJZHeWiCwBTNiGG94o4uj9Sy)VdlUlg36oSaGxaKKbmR2AhQTAqUd9dNWmMgOVM9IT2tei9EChCQKEwS)3Hf3fJBDhwaWlasYaMvBzUYKzUO1Cl1Zz5SyiQkymnCoKagHZYXPs6zXouB1GChNdjGr4S2AprqS3J7GtL0ZI9)oS4UyCR7aTMBPEolhLXA0RrCCQKEwyUYKzUKqZPJYyn61ioOODO2Qb5o8n8ROHZHeWiCwBTNi4394o4uj9Sy)Vd1wni3bPNPuweEkccJ3bTWTuy6oI9w7jc(zpUd1wni3XtrqyCamd1Jd4g(vmaIUdovspl2)BTNi4m7XDO2Qb5oSGKYwSwni3bNkPNf7)T2Ahry2cqi1ApUNiypUd1wni3HG)aQgKbfcR7GtL0ZI9)w7jP3J7qTvdYDm9m9zX6S2bNkPNf7)T2tXEpUd1wni3HfKu2I1Qb5o4uj9Sy)V1E6394ouB1GCh(g(v0W5qcyeoRDWPs6zX(FRT2bT0uOyXECprWEChCQKEwS)3Hf3fJBDhcMeAoDNdjGr4SCqr7qTvdYDqFn7fbWmupoGB4xXai6w7jP3J7GtL0ZI9)oS4UyCR74b8XeIasyS5IYC)XCLjZCjHMt3d4JjOF4eMXoOiZvMmZ9b8XeIasyS5IYC)1CjYCl1Zz5OAARE2SiibR1ZXPs6zH5sK5scnNo9dNWDchKG165GI2HARgK7G(A2lcGzOECa3WVIbq0T2tXEpUdovspl2)7qTvdYDCoKagHZAhwCxmU1DyFkgMPMlkZvAZvMmZfTMBPEolNfdrvbJPHZHeWiCwoovspl2HngRNdLIH5IUNiyR90V7XDO2Qb5oEkccJdGzqcwR3o4uj9Sy)V1E6N94ouB1GChKEMs7eoaMbkeccJ3bNkPNf7)T2tNzpUd1wni3bPNP0oHdGzqHkiKChCQKEwS)3Apry2J7qTvdYDq6zkTt4aygK0zX4DWPs6zX(FR90zDpUd1wni3bPNP0oHdGzGgH7eEhCQKEwS)3Apry3J7qTvdYDOF4eMX0a91SxSdovspl2)BTNii(EChCQKEwS)3HARgK74CibmcN1oSXy9COummx09ebBTNiGG94ouB1GChF0uQd10hJPHNIGW4DWPs6zX(FR9ebsVh3bNkPNf7)DyXDX4w3bAnxliPSfRvdshu0ouB1GChwqszlwRgKBTNii27XDO2Qb5oe9No5qb8(DWPs6zX(FR9eb)Uh3bNkPNf7)DO2Qb5oi9mLYIWtrqy8oS4UyCR7W(ummtnxuMBS3bTWTuy6oK297w7jc(zpUd1wni3HsFCgEQ3dKSdovspl2)BTNi4m7XDWPs6zX(FhwCxmU1DyFkgMPMlkZv6DO2Qb5oEkccJdGzOECa3WVIbq0T2teqy2J7GtL0ZI9)oS4UyCR7GeAoDF0uQd10hJPHNIGWyhu0ouB1GChsayramdWEaoMT2teCw3J7GtL0ZI9)ouB1GChKEMszr4PiimEh0c3sHP7qA3VBTNiGWUh3HARgK74PiimoaMH6XbCd)kgar3bNkPNf7)T2tshFpUd1wni3HVHFfnCoKagHZAhCQKEwS)3Apjnb7XDO2Qb5ouSvtouamMZAhCQKEwS)3ApjT07XDO2Qb5oSGKYwSwni3bNkPNf7)T2tsh794o4uj9Sy)VdlUlg36oiHMth91zNWbFd)QWeZSdkYCjYCrR5AbF4uZYLSfd8aSyhQTAqUdjaSiaMbypahZwBTdKUAyTAqUh3teSh3bNkPNf7)DyXDX4w3bj0C6OVM9IaygQhhWn8Ryae1jassZLiZ9aZ9b8XeIasyStWZ22L5IYCJBUYKzUKqZPt0F6Kdrq4iaLDqrM7H7qTvdYDqFn7fbWmupoGB4xXai6w7jP3J7GtL0ZI9)oS4UyCR7GeAoD0xNDch8n8RctiV3bfzUezUKqZPJ(6St4GVHFvyc59omJODsnxczUWwH5IgMR07qTvdYDibGfbWma7b4y2Apf794o4uj9Sy)VdlUlg36ooWCFS6RNlYwMlHm3FJBUhUd1wni3HeaweaZaShGJzR90V7XDWPs6zX(FhwCxmU1DCG52PfG0jCqOikmhiiE84XrOMlHm3hR(65qu00CrdZLaN0)yUhAUezUpw91ZfzlZLqM7p)yUezUL65SC4g(vmaIgIWGITfa74uj9SyhQTAqUdjaSiaMbypahZw7PF2J7GtL0ZI9)oS4UyCR74aZTtlaPt4GqruyoqqSJhpoc1CjK5(y1xphIIMMlAyUe4oJ5EO5sK5(y1xpxKTmxczU)8ZouB1GChsayramdWEaoMT2tNzpUdovspl2)7WI7IXTUJdm3oTaKoHdcfrH5WzIhpoc1CjK5(y1xphIIMMlAyUXDegZ9qZLiZ9XQVEUiBzUeYCpZpMlrMBPEolhUHFfdGOHimOyBbWoovspl2HARgK7qcalcGza2dWXS1EIWSh3bNkPNf7)DyXDX4w3XbMBNwasNWbHIOWCGWgpECeQ5siZ9XQVEoefnnx0WCjWjT5EO5sK5(y1xpxKTmxczU)8ZouB1GChsayramdWEaoMT2tN194o4uj9Sy)VdlUlg36o60cq6eoiuefMds)t84iuZnwM7JvF9CikAAUOH5g39R5sK5IwZ9aZLeAoDkwWzfe8KtbJDqrMRmzMlj0C6GHuSO1maMbnTnNvqkDctDqrMRmzMlj0C6e9No5a91Sx4GImxzYmxsO50fbQgKoOiZ9WDO2Qb5oGHuSO1maMbnTnNvqkDct3Apry3J7GtL0ZI9)oS4UyCR7OupNLB2P6d0stHJtL0ZcZLiZTtlaPt4Gqruyoi9pXJJqn3yzUpw91ZHOOP5IgMBC3VMlrMlAn3dmxsO50PybNvqWtofm2bfzUYKzUKqZPdgsXIwZayg002CwbP0jm1bfzUYKzUKqZPt0F6Kd0xZEHdkYCLjZCjHMtxeOAq6GIm3d3HARgK7q0F6Kd0xZEXw7jcIVh3bNkPNf7)DyXDX4w3rNwasNWbHIOWCq6FIhhHAUXYCFS6RNdrrtZfnm34UFnxImx0AUhyUKqZPtXcoRGGNCkySdkYCLjZCjHMthmKIfTMbWmOPT5ScsPtyQdkYCLjZCjHMtNO)0jhOVM9chuK5ktM5scnNUiq1G0bfzUhUd1wni3HIfCwbbp5uW4T2teqWEChCQKEwS)3Hf3fJBDhpw91ZfzlZLqMlb)Sd1wni3HxJjaYWttbDRT2Hfa8cGKKUh3teSh3bNkPNf7)DyXDX4w3bj0C60pCc3jCqcwRNdkAhQTAqUJzJzspai2Apj9EChQTAqUdkJ1OxJSdovspl2)BTNI9EChQTAqUd9dNWDchKG16Tdovspl2)BTN(DpUdovspl2)7WI7IXTUdsO50PF4eUt4GeSwphuK5ktM5AbaVaijD6hoH7eoibR1ZHzeTtQ5glZ9mX3HARgK74b8Xe0pCcZ4T2t)Sh3bNkPNf7)DyXDX4w3bj0C60pCc3jCqcwRNdkAhQTAqUJiq1GCR90z2J7GtL0ZI9)oS4UyCR7GeAoD6hoH7eoibR1ZjasYDO2Qb5ou6JZWt9EGKT2teM94ouB1GChF0uQd10hJPHNIGW4DWPs6zX(FR90zDpUdovspl2)7WI7IXTUJhWhticiHXobpBBxMBSm347qTvdYDi6pDYHc49BTNiS7XDWPs6zX(FhwCxmU1DqcnNokJ1OxJ4GImxzYmx0AUL65SCugRrVgXXPs6zXouB1GChquo0fJq3Aprq894o4uj9Sy)VdlUlg36oIW8NaSv4iWPF4eMX0a91SxyUezUwaWlassN(Htygtd0xZEHdZiAN0DO2Qb5oqaiCwbWma7b4y2Aprab7XDWPs6zX(FhQTAqUdymiHPHiCJO(awH5DyXDX4w3XbM7bMRfa8cGK0DoKagHZYnH8(aMTpfdZHQryZnwM7VMRmzM7bMlAn3s9CwolgIQcgtdNdjGr4SCCQKEwyUezUry(ta2kCe4ohsaJWzzUhAUhAUezUwaWlassN(Htygtd0xZEHdZiANuZnwM7VMlrMlj0C6OmwJEnIdZiANuZnwM7VM7HMRmzM7bMlj0C6OmwJEnIdZiANuZLqM7VM7H7iveEhWyqctdr4gr9bScZBTNiq694o4uj9Sy)Vd1wni3bcJzPupLgMAcVdlUlg36oqR5scnNo9dNWDchKG165GImxIm3dmxsO50rzSg9AehuK5ktM5IwZTupNLJYyn61ioovsplm3d3rQi8oqymlL6P0Wut4T2tee794o4uj9Sy)VJur4DGvPsbukfAGSHdyweiHQcK7qTvdYDGvPsbukfAGSHdyweiHQcKBT1w74dJPni3tshx64eiD8F2HefNDct3XzlseaxSWC)XCvB1G0C9nTOoJ8DqJy7E6mNzhryWS98oiCZvQHbfBRgKMRut9QOtJCc3CLkWwgHKXM7zi2CLoU0XnYnYjCZvQ(PjmtnYjCZ9SyUsvcblm3Zotcjf2zKt4M7zXCp7mc4dBUdgRrVgXCXmTWTTAqsnxqAUiq(QJ8S5I0vdRvdsZvjBFxntDg5g5eU5E2GMSfQyH5sYtaMnxlaHulZLKH7K6mxPkRLJkQ5MG8S8umYeYBUQTAqsnxq6JXzKR2Qbj1fHzlaHul0r9vWFavdYGcHvJC1wniPUimBbiKAHoQVtptFwSolJC1wniPUimBbiKAHoQVwqszlwRgKg5QTAqsDry2cqi1cDuF9n8ROHZHeWiCwg5g5eU5E2GMSfQyH5YFyCmMB1iS5wp2CvBbWMBtnx9J2EL0ZoJC1wniPOWmjKuyJC1wniPOJ6Rv9(GARgKbFtlItfHrzbaVaijPg5QTAqsrh1xR69b1wnid(MweNkcJcPRgwRgKg5QTAqsrh1xR69b1wnid(MweNkcJIwAkuSWi3ixTvdsk6O(sFn7fbWmupoGB4xXaikX9e1d4JjebKWyNGNTTluXj6GdiHMtN(Ht4oHdsWA9CqreH2s9CwokJ1OxJ44uj9S4qzYiHMthLXA0RrCqrhAKR2QbjfDuFPVM9IaygQhhWn8RyaeL4EI6asO50PF4eUt4GeSwphuerKqZPt)WjCNWbjyTEomJODsj0VeH2s9CwokJ1OxJ44uj9S4qzYoGeAoDugRrVgXHzeTtkH(LisO50rzSg9Aehu0Hg5QTAqsrh13NIGW4aygKG16rCpr9a(ycrajm2j4zB7kwXnYvB1GKIoQV(g(v0W5qcyeolI7jksO50rzSg9AehuerKqZPJYyn61iomJODsjuSnYvB1GKIoQVwqszlwRgKe3tuO1cskBXA1G0bfzKR2QbjfDuFphsaJWzrCprDGfa8cGK0DoKagHZYHzeTtkHGTcISaGxaKKUZHeWiCwo7tXWmnmXQTAqQ(yrarwaWlasYaMvBDOmzOTupNLZIHOQGX0W5qcyeolhNkPNfg5QTAqsrh1x9dNWmMgOVM9cI7jkla4fajzaZQTmYvB1GKIoQVNdjGr4SiUNOSaGxaKKbmR2sMm0wQNZYzXquvWyA4CibmcNLJtL0ZcJC1wniPOJ6RVHFfnCoKagHZI4EIcTL65SCugRrVgXXPs6zHmzKqZPJYyn61ioOiJC1wniPOJ6lPNPuweEkccJjMw4wkmfvSnYvB1GKIoQVpfbHXbWmupoGB4xXaiQrUARgKu0r91cskBXA1G0i3ixTvdsQJwAkuSaf91SxeaZq94aUHFfdGOe3tucMeAoDNdjGr4SCqrg5QTAqsD0stHIfOJ6l91SxeaZq94aUHFfdGOe3tupGpMqeqcJr9JmzKqZP7b8Xe0pCcZyhuKmzpGpMqeqcJr9lrL65SCunTvpBweKG1654uj9SGisO50PF4eUt4GeSwphuKrUARgKuhT0uOyb6O(EoKagHZIyBmwphkfdZfffbe3tu2NIHzkkPLjdTL65SCwmevfmMgohsaJWz54uj9SWixTvdsQJwAkuSaDuFFkccJdGzqcwRNrUARgKuhT0uOyb6O(s6zkTt4aygOqiim2ixTvdsQJwAkuSaDuFj9mL2jCamdkubHKg5QTAqsD0stHIfOJ6lPNP0oHdGzqsNfJnYvB1GK6OLMcflqh1xsptPDchaZanc3jSrUARgKuhT0uOyb6O(QF4eMX0a91SxyKR2Qbj1rlnfkwGoQVNdjGr4Si2gJ1ZHsXWCrrrGrUARgKuhT0uOyb6O((rtPoutFmMgEkccJnYvB1GK6OLMcflqh1xliPSfRvdsI7jk0AbjLTyTAq6GImYvB1GK6OLMcflqh1xr)PtouaV3ixTvdsQJwAkuSaDuFj9mLYIWtrqymX0c3sHPOK29lX9eL9PyyMIk2g5QTAqsD0stHIfOJ6RsFCgEQ3dKyKR2Qbj1rlnfkwGoQVpfbHXbWmupoGB4xXaikX9eL9PyyMIsAJC1wniPoAPPqXc0r9vcalcGza2dWXqCprrcnNUpAk1HA6JX0WtrqySdkYixTvdsQJwAkuSaDuFj9mLYIWtrqymX0c3sHPOK29RrUARgKuhT0uOyb6O((ueeghaZq94aUHFfdGOg5QTAqsD0stHIfOJ6RVHFfnCoKagHZYixTvdsQJwAkuSaDuFvSvtouamMZYixTvdsQJwAkuSaDuFTGKYwSwninYvB1GK6OLMcflqh1xjaSiaMbypahdX9efj0C6OVo7eo4B4xfMyMDqreHwl4dNAwUKTyGhGfg5g5QTAqsDwaWlasskQzJzspaiiUNOiHMtN(Ht4oHdsWA9Cqrg5QTAqsDwaWlassk6O(szSg9AeJC1wniPola4fajjfDuF1pCc3jCqcwRNrUARgKuNfa8cGKKIoQVpGpMG(HtygtCprrcnNo9dNWDchKG165GIKjZcaEbqs60pCc3jCqcwRNdZiAN0yDM4g5QTAqsDwaWlassk6O(gbQgKe3tuKqZPt)WjCNWbjyTEoOiJC1wniPola4fajjfDuFv6JZWt9EGeI7jksO50PF4eUt4GeSwpNaijnYvB1GK6SaGxaKKu0r99JMsDOM(ymn8ueegBKR2Qbj1zbaVaijPOJ6RO)0jhkG3tCpr9a(ycrajm2j4zB7kwXnYvB1GK6SaGxaKKu0r9fIYHUyekX9efj0C6OmwJEnIdksMm0wQNZYrzSg9AehNkPNfg5QTAqsDwaWlassk6O(Iaq4ScGza2dWXqCprfH5pbyRWrGt)WjmJPb6RzVGila4fajPt)WjmJPb6RzVWHzeTtQrUARgKuNfa8cGKKIoQVquo0fJqCQimkymiHPHiCJO(awHzI7jQdoWcaEbqs6ohsaJWz5MqEFaZ2NIH5q1iCS(vMSdqBPEolNfdrvbJPHZHeWiCwoovsplikcZFcWwHJa35qcyeoRdpKila4fajPt)WjmJPb6RzVWHzeTtAS(LisO50rzSg9AehMr0oPX63dLj7asO50rzSg9AehMr0oPe63dnYvB1GK6SaGxaKKu0r9fIYHUyeItfHrHWywk1tPHPMWe3tuOLeAoD6hoH7eoibR1Zbfr0bKqZPJYyn61ioOizYqBPEolhLXA0RrCCQKEwCOrUARgKuNfa8cGKKIoQVquo0fJqCQimkSkvkGsPqdKnCaZIajuvG0i3ixTvdsQdPRgwRgKOOVM9IaygQhhWn8RyaeL4EIIeAoD0xZEramd1Jd4g(vmaI6eajjrh8a(ycrajm2j4zB7cvCzYiHMtNO)0jhIGWrak7GIo0ixTvdsQdPRgwRgKOJ6ReaweaZaShGJH4EIIeAoD0xNDch8n8RctiV3bfrej0C6OVo7eo4B4xfMqEVdZiANucbBfOH0g5QTAqsDiD1WA1GeDuFLaWIaygG9aCme3tuh8y1xpxKTi0VXp0ixTvdsQdPRgwRgKOJ6ReaweaZaShGJH4EI6GoTaKoHdcfrH5abXJhpocLqpw91ZHOOjAqGt6FoKOhR(65ISfH(5hIk1Zz5Wn8RyaeneHbfBla2XPs6zHrUARgKuhsxnSwnirh1xjaSiaMbypahdX9e1bDAbiDchekIcZbcID84XrOe6XQVEoefnrdcCN5qIES6RNlYwe6NFmYvB1GK6q6QH1Qbj6O(kbGfbWma7b4yiUNOoOtlaPt4GqruyoCM4XJJqj0JvF9CikAIgXDeMdj6XQVEUiBrOZ8drL65SC4g(vmaIgIWGITfa74uj9SWixTvdsQdPRgwRgKOJ6ReaweaZaShGJH4EI6GoTaKoHdcfrH5aHnE84iuc9y1xphIIMObboPpKOhR(65ISfH(5hJCc3CvB1GK6q6QH1Qbj6O(sFn7fbWmupoGB4xXaikX9efj0C6OVM9IaygQhhWn8Ryae1jassIo4b8XeIasyCSKwMmsO50j6pDYHiiCeGYoOOdnYvB1GK6q6QH1Qbj6O(cdPyrRzamdAABoRGu6eMsCpr1PfG0jCqOikmhK(N4XrOX6XQVEoefnrJ4UFjcThqcnNofl4SccEYPGXoOizYiHMthmKIfTMbWmOPT5ScsPtyQdksMmsO50j6pDYb6RzVWbfjtgj0C6Iavdshu0Hg5QTAqsDiD1WA1GeDuFf9No5a91SxqCprvQNZYn7u9bAPPWXPs6zbrDAbiDchekIcZbP)jECeASES6RNdrrt0iU7xIq7bKqZPtXcoRGGNCkySdksMmsO50bdPyrRzamdAABoRGu6eM6GIKjJeAoDI(tNCG(A2lCqrYKrcnNUiq1G0bfDOrUARgKuhsxnSwnirh1xfl4SccEYPGXe3tuDAbiDchekIcZbP)jECeASES6RNdrrt0iU7xIq7bKqZPtXcoRGGNCkySdksMmsO50bdPyrRzamdAABoRGu6eM6GIKjJeAoDI(tNCG(A2lCqrYKrcnNUiq1G0bfDOrUARgKuhsxnSwnirh1xVgtaKHNMckX9e1JvF9Cr2Iqe8ZwBTla]] )


end
