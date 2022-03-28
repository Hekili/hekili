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
        guarded_by_the_light = 97, -- 216855
        guardian_of_the_forgotten_queen = 94, -- 228049
        hallowed_ground = 90, -- 216868
        inquisition = 844, -- 207028
        judgments_of_the_pure = 93, -- 355858
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
    -- Tier 28
	spec:RegisterGear( "tier28", 188933, 188932, 188931, 188929, 188928 )
    spec:RegisterSetBonuses( "tier28_2pc", 364304, "tier28_4pc", 363675 )
    -- 2-Set - Glorious Purpose - Casting Shield of the Righteous increases your Block chance by 4% for 15 sec, stacking up to 3 times.
    -- 4-Set - Glorious Purpose - When you take damage, you have a chance equal to 100% of your Block chance to cast Judgment at your attacker.
    spec:RegisterAuras( {
        glorious_purpose = {
            id = 364305,
            duration = 15,
            max_stack = 3
        }
    } )


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

        if buff.divine_resonance.up then
            state:QueueAuraEvent( "divine_toll", class.abilities.avengers_shield.handler, buff.divine_resonance.expires, "AURA_PERIODIC" )
            if buff.divine_resonance.remains > 5 then state:QueueAuraEvent( "divine_toll", class.abilities.avengers_shield.handler, buff.divine_resonance.expires - 5, "AURA_PERIODIC" ) end
            if buff.divine_resonance.remains > 10 then state:QueueAuraEvent( "divine_toll", class.abilities.avengers_shield.handler, buff.divine_resonance.expires - 10, "AURA_PERIODIC" ) end
        end
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

                if set_bonus.tier28_2pc > 0 then
                    addStack( "glorious_purpose", nil, 1 )
                end

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

                removeStack( "vanquishers_hammer" )
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
                local spellToCast

                if state.spec.protection then spellToCast = class.abilities.avengers_shield.handler
                elseif state.spec.retribution then spellToCast = class.abilities.judgment.handler
                else spellToCast = class.abilities.holy_shock.handler end

                for i = 1, min( 5, true_active_enemies ) do
                    spellToCast()
                end

                if legendary.divine_resonance.enabled then
                    applyBuff( "divine_resonance" )
                    state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires, "AURA_PERIODIC" )
                    state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires - 5, "AURA_PERIODIC" )
                    state:QueueAuraEvent( "divine_toll", spellToCast, buff.divine_resonance.expires - 10, "AURA_PERIODIC" )
                end
            end,

            auras = {
                divine_resonance = {
                    id = 355455,
                    duration = 15,
                    max_stack = 1,
                },
            }
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
                applyBuff( "vanquishers_hammer", nil, legendary.dutybound_gavel.enabled and 2 or nil )
                if soulbind.kevins_oozeling.enabled then applyBuff( "kevins_oozeling" ) end
            end,

            auras = {
                vanquishers_hammer = {
                    id = 328204,
                    duration = 15,
                    max_stack = function () return legendary.dutybound_gavel.enabled and 2 or 1 end,
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

                -- Leaving reactive for now, will see if we need to do anything differently.
                equinox = {
                    id = 355567,
                    duration = 10,
                    max_stack = 1,
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
                    duration = function () return legendary.radiant_embers.enabled and 45 or 30 end,
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


    spec:RegisterPack( "Protection Paladin", 20210710, [[diuEVaqieKhHGInHqgLOQoLOkRccvVcbMfc1Tirk7IQ(LQsdtv4yQQSmsupdcPPPkPRPkX2Gq5Bqimoeu5CiOQ1HGs18uvL7br7tujhebLSqi4HKirxecrDseukRKKANQkgkjs1sHqKNQWuvfTxL(RidwrhMYIr0Jj1KjCzuBwL(mOgTkoTuRwvv9AseZMk3gs7wYVbgUOCCsK0YH65inDHRdY2vL67KW4fvQZlQy9KiH5ts2prV)2N7qybVFu(HY)EGi(9W)7vLFr5x2rKtgVJmtRedM3rzO8ou6yqW6ObLCQ0nNj6AhzwooGj2N7GcGWAEhNiYOe2)(fUJdePxdq)sBuiNfnO0y7gFPnQ(7oiHAxqyRwYDiSG3pk)q5Fpqe)E4)9QYVO8VDyqXbG3XOrvk3XPfcUwYDiyQEhkDmiyD0Gsov6MZeDjvRgYLJC(7bXYPYpu(NuTuTs5XkyMkvR0KtclHGfYjIetcPe2lvR0Ktejgf8MLZbJTStJkNyMg4whnOOYjOKtuix0zowor7OHTObLCAKTRJMP(D4AAq3N7qWxdYf7Z9ZV95o4YiDSyryhcMQXDw0GAhiY5M1qblKt(nJZroJgLLZ4WYPPdawoBQCAVT2zKo2VdthnO2bMjHucVX(r595o4YiDSyryhMoAqTdT5CjthnOsUMg7W10ivgkVdna4eaffDJ9dIUp3bxgPJflc7W0rdQDOnNlz6ObvY10yhUMgPYq5DG2rdBrdQn2pVUp3bxgPJflc7W0rdQDOnNlz6ObvY10yhUMgPYq5DqdRegwSX(5L95o4YiDSyryhAChmUTDCaUCszafm2l4BR7qorkNpKtIKZ8LZ8LtsO71BV5cUl4KcSfhpuMCsKCsi5mmhxHNYyl70OEUmshlKZ8KtvQKtsO71tzSLDAupuMCM3omD0GAh0tZorcCtXHt4g(emaIUX(bX2N7GlJ0XIfHDOXDW422r(Yjj096T3Cb3fCsb2IJhktojsojHUxV9Ml4UGtkWwC8yg16IkN)jNVkNejNesodZXv4Pm2YonQNlJ0Xc5mp5uLk5mF5Ke6E9ugBzNg1JzuRlQC(NC(QCsKCscDVEkJTStJ6HYKZ82HPJgu7GEA2jsGBkoCc3WNGbq0n2piI95o4YiDSyryhAChmUTDCaUCszafm2l4BR7qoZLC(yhMoAqTJJHIY4e4MuGT4SX(HWTp3bxgPJflc7qJ7GXTTdsO71tzSLDAupuMCsKCscDVEkJTStJ6XmQ1fvo)tor0Dy6Ob1oCn8jOP)HeWOCfBSFi87ZDWLr6yXIWo04oyCB7GqYPguuwJTObLhkBhMoAqTdnOOSgBrdQn2p)ESp3bxgPJflc7qJ7GXTTJ8Ltna4eafL)FibmkxHhZOwxu58p5ewlKtIKtna4eafL)FibmkxHxFmmmttxSPJguMtoZLC(tojso1aGtauujmB6qoZtovPsojKCgMJRWRXqutWyA6FibmkxHNlJ0XIDy6Ob1o(hsaJYvSX(53V95o4YiDSyryhAChmUTDObaNaOOsy20XomD0GAh2BUGzmnrpn7eBSF(P8(ChCzKowSiSdnUdg32o0aGtauujmB6qovPsojKCgMJRWRXqutWyA6FibmkxHNlJ0XIDy6Ob1o(hsaJYvSX(5hIUp3bxgPJflc7qJ7GXTTdcjNH54k8ugBzNg1ZLr6yHCQsLCscDVEkJTStJ6HY2HPJgu7W1WNGM(hsaJYvSX(53R7ZDWLr6yXIWomD0GAhKoMszr6yOOmEh0a3kHP7ar3y)87L95omD0GAhhdfLXjWnfhoHB4tWai6o4YiDSyryJ9ZpeBFUdthnO2HguuwJTOb1o4YiDSyryJn2rgM1ausl2N7NF7ZDWLr6yXIWoemvJ7SOb1oqKZnRHcwiNK8fGz5udqjTqojz4UOE5KWsR5SGkNfOuAhdJEHCYPPJguu5euUC87W0rdQDi43GObvYGW2g7hL3N7W0rdQDCDm9OX2n2bxgPJflcBSFq095omD0GAhAqrzn2Igu7GlJ0XIfHn2pVUp3HPJgu7W1WNGM(hsaJYvSdUmshlwe2y)8Y(ChMoAqTdJE4kDmNdOyhCzKowSiSXg7aTJg2Igu7Z9ZV95o4YiDSyryhAChmUTDqcDVE6PzNibUP4WjCdFcgar9cGIsojsoZxopaxoPmGcg7f8T1DiNiLZhYPkvYjj096f97U4ugeodqzpuMCM3omD0GAh0tZorcCtXHt4g(emaIUX(r595o4YiDSyryhAChmUTDqcDV(3wPuHA6HX00XqrzShkBhMoAqTdfaSibUjyhaNZg7heDFUdUmshlwe2Hg3bJBBhKq3RNE6Ql4KRHpr6c5CEOm5Ki5Ke6E90txDbNCn8jsxiNZJzuRlQC(NCcRfYjIlNklNejNh2CXXNPd58p5KW9qojsojKCQbV5YQWxSgdCaSyhMoAqTdfaSibUjyhaNZg7Nx3N7GlJ0XIfHDOXDW422r(Y5HnxC8z6qo)toF9HCM3omD0GAhkayrcCtWoaoNn2pVSp3bxgPJflc7qJ7GXTTJ8LZU0a0UGtcd1G50VhpE8aLkN)jNh2CXXJA5worC58Nx5xKZ8KtIKZdBU44Z0HC(NC(YlYjrYzyoUcpUHpbdGOPmmiyDaWEUmshl2HPJgu7qbalsGBc2bW5SX(bX2N7GlJ0XIfHDOXDW422r(YzxAaAxWjHHAWC6hI(4XduQC(NCEyZfhpQLB5eXLZFEetoZtojsopS5IJpthY5FY5lVSdthnO2HcawKa3eSdGZzJ9dIyFUdUmshlwe2Hg3bJBBh5lNDPbODbNegQbZje7XJhOu58p58WMloEul3YjIlNp8ic5mp5Ki58WMlo(mDiN)jNi2lYjrYzyoUcpUHpbdGOPmmiyDaWEUmshl2HPJgu7qbalsGBc2bW5SX(HWTp3bxgPJflc7qJ7GXTTJ8LZU0a0UGtcd1G5eH)XJhOu58p58WMloEul3YjIlN)8klN5jNejNh2CXXNPd58p58Lx2HPJgu7qbalsGBc2bW5SX(HWVp3bxgPJflc7W0rdQDadzyrBvcCtwPBUIKs6cMUdbt14olAqTdthnOOE0oAylAqraYV0tZorcCtXHt4g(emaIsCFrscDVE6PzNibUP4WjCdFcgar9cGIIO8paxoPmGcgNlLvPIe6E9I(DxCkdcNbOShklVDOXDW422rxAaAxWjHHAWCs5xE8aLkN5sopS5IJh1YTCI4Y5d)RYjrYjHKZ8LtsO71BybxrsWxUem2dLjNQujNKq3RhgYWI2Qe4MSs3CfjL0fm1dLjNQujNKq3Rx0V7It0tZoHhktovPsojHUxFgiAq5HYKZ82y)87X(ChCzKowSiSdnUdg32ocZXv4VDzUenSs45YiDSqojso7sdq7cojmudMtk)YJhOu5mxY5HnxC8OwULtexoF4FvojsojKCMVCscDVEdl4ksc(YLGXEOm5uLk5Ke6E9Wqgw0wLa3Kv6MRiPKUGPEOm5uLk5Ke6E9I(DxCIEA2j8qzYPkvYjj096ZardkpuMCM3omD0GAhI(DxCIEA2j2y)873(ChCzKowSiSdnUdg32o6sdq7cojmudMtk)YJhOu5mxY5HnxC8OwULtexoF4FvojsojKCMVCscDVEdl4ksc(YLGXEOm5uLk5Ke6E9Wqgw0wLa3Kv6MRiPKUGPEOm5uLk5Ke6E9I(DxCIEA2j8qzYPkvYjj096ZardkpuMCM3omD0GAhgwWvKe8LlbJ3y)8t595o4YiDSyryhAChmUTDCyZfhFMoKZ)KZFVSdthnO2HZYjbQ0XkbDJn2HgaCcGIIUp3p)2N7GlJ0XIfHDOXDW422bj096T3Cb3fCsb2IJhkBhMoAqTJBJzshai2y)O8(ChMoAqTdkJTStJUdUmshlwe2y)GO7ZDy6Ob1oS3Cb3fCsb2IZo4YiDSyryJ9ZR7ZDWLr6yXIWo04oyCB7Ge6E92BUG7coPaBXXdLjNQujNAaWjakkV9Ml4UGtkWwC8yg16IkN5sorSh7W0rdQDCaUCs2BUGz8g7Nx2N7GlJ0XIfHDOXDW422bj096T3Cb3fCsb2IJhkBhMoAqTJmq0GAJ9dITp3bxgPJflc7qJ7GXTTdsO71BV5cUl4KcSfhVaOO2HPJgu7WOhUshZ5ak2y)Gi2N7W0rdQD82kLkutpmMMogkkJ3bxgPJflcBSFiC7ZDWLr6yXIWo04oyCB74aC5KYakySxW3w3HCMl58XomD0GAhI(DxCkao3g7hc)(ChCzKowSiSdnUdg32oiHUxpLXw2Pr9qzYPkvYjHKZWCCfEkJTStJ65YiDSyhMoAqTdikN6GrPBSF(9yFUdUmshlwe2Hg3bJBBhzy(Dcwl8)82BUGzmnrpn7eYjrYPgaCcGIYBV5cMX0e90St4XmQ1fDhMoAqTduakxrcCtWoaoNn2p)(Tp3bxgPJflc7W0rdQDaJbfmnLHBuZLWgmVdnUdg32oYxoZxo1aGtauu()HeWOCf(lKZLWS(yyyofnklN5soFvovPsoZxojKCgMJRWRXqutWyA6FibmkxHNlJ0Xc5Ki5mdZVtWAH)N)FibmkxHCMNCMNCsKCQbaNaOO82BUGzmnrpn7eEmJADrLZCjNVkNejNKq3RNYyl70OEmJADrLZCjNVkN5jNQujN5lNKq3RNYyl70OEmJADrLZ)KZxLZ82rzO8oGXGcMMYWnQ5sydM3y)8t595o4YiDSyryhMoAqTdugZkjognDTcEhAChmUTDqi5Ke6E92BUG7coPaBXXdLjNejN5lNKq3RNYyl70OEOm5uLk5KqYzyoUcpLXw2Pr9CzKowiN5TJYq5DGYywjXXOPRvWBSF(HO7ZDWLr6yXIWokdL3b2ukeqLsOjYgoHzrIekcqTdthnO2b2ukeqLsOjYgoHzrIekcqTXg7GgwjmSyFUF(Tp3bxgPJflc7qJ7GXTTdbtcDV()HeWOCfEOSDy6Ob1oONMDIe4MIdNWn8jyaeDJ9JY7ZDWLr6yXIWo04oyCB74aC5KYakySCIuoFrovPsojHUx)b4YjzV5cMXEOm5uLk58aC5KYakySCIuoFvojsodZXv4PwPJ(2SiPaBXXZLr6yHCsKCscDVE7nxWDbNuGT44HY2HPJgu7GEA2jsGBkoCc3WNGbq0n2pi6(ChCzKowSiSdthnO2X)qcyuUIDOXDW422H(yyyMkNiLtLLtvQKtcjNH54k8Ame1emMM(hsaJYv45YiDSyh6C0oofggMd6(53g7Nx3N7W0rdQDCmuugNa3KcSfNDWLr6yXIWg7Nx2N7W0rdQDq6ykTl4e4MOqOOmEhCzKowSiSX(bX2N7W0rdQDq6ykTl4e4MmOacT2bxgPJflcBSFqe7ZDy6Ob1oiDmL2fCcCtk6ky8o4YiDSyryJ9dHBFUdthnO2bPJP0UGtGBIMH7cEhCzKowSiSX(HWVp3HPJgu7WEZfmJPj6PzNyhCzKowSiSX(53J95o4YiDSyryhMoAqTJ)HeWOCf7qNJ2XPWWWCq3p)2y)873(ChMoAqTJ3wPuHA6HX00Xqrz8o4YiDSyryJ9ZpL3N7GlJ0XIfHDOXDW422bHKtnOOSgBrdkpu2omD0GAhAqrzn2IguBSF(HO7ZDy6Ob1oe97U4uaCUDWLr6yXIWg7NFVUp3bxgPJflc7W0rdQDq6ykLfPJHIY4DOXDW422H(yyyMkNiLteDh0a3kHP7qz)RBSF(9Y(ChMoAqTdJE4kDmNdOyhCzKowSiSX(5hITp3bxgPJflc7qJ7GXTTd9XWWmvorkNkVdthnO2XXqrzCcCtXHt4g(emaIUX(5hIyFUdUmshlwe2HPJgu7G0XuklshdfLX7Gg4wjmDhk7FDJ9Zpc3(ChMoAqTJJHIY4e4MIdNWn8jyaeDhCzKowSiSX(5hHFFUdthnO2HRHpbn9pKagLRyhCzKowSiSX(r5h7ZDy6Ob1omS2kofamMRyhCzKowSiSX(r5F7ZDy6Ob1o0GIYASfnO2bxgPJflcBSXg74nJPnO2pk)q5h)uw5x2HcdxDbt3bHn0maoyHC(ICA6ObLC6AAq9s17GMX69dIHy7iddUTJ3bHrov6yqW6ObLCQ0nNj6sQMWiNQHC5iN)EqSCQ8dL)jvlvtyKtLYJvWmvQMWiNkn5KWsiyHCIiXKqkH9s1eg5uPjNismk4nlNdgBzNgvoXmnWToAqrLtqjNOqUOZCSCI2rdBrdk50iBxhnt9s1s1eg5ero3SgkyHCsYxaMLtnaL0c5KKH7I6LtclTMZcQCwGsPDmm6fYjNMoAqrLtq5YXlvB6Obf1NHznaL0ccq(vWVbrdQKbHnPAthnOO(mmRbOKwqaYVxhtpASDdPAthnOO(mmRbOKwqaYVAqrzn2Igus1MoAqr9zywdqjTGaKFDn8jOP)HeWOCfs1MoAqr9zywdqjTGaKFn6HR0XCoGcPAPAcJCIiNBwdfSqo53moh5mAuwoJdlNMoay5SPYP92ANr6yVuTPJguuKyMesjSuTPJguucq(vBoxY0rdQKRPbXLHYi1aGtauuuPAthnOOeG8R2CUKPJgujxtdIldLrI2rdBrdkPAthnOOeG8R2CUKPJgujxtdIldLrsdRegwivlvB6ObfLaKFPNMDIe4MIdNWn8jyaeL4(I8aC5KYakySxW3w3bYheLF(Kq3R3EZfCxWjfyloEOmIiuyoUcpLXw2Pr9CzKowKNkvKq3RNYyl70OEOS8KQnD0GIsaYV0tZorcCtXHt4g(emaIsCFrMpj096T3Cb3fCsb2IJhkJisO71BV5cUl4KcSfhpMrTUO)9krekmhxHNYyl70OEUmshlYtLQ8jHUxpLXw2Pr9yg16I(3RercDVEkJTStJ6HYYtQ20rdkkbi)EmuugNa3KcSfhI7lYdWLtkdOGXEbFBDh56HuTPJguucq(11WNGM(hsaJYvqCFrscDVEkJTStJ6HYiIe6E9ugBzNg1JzuRl6FiQuTPJguucq(vdkkRXw0GI4(IKqAqrzn2IguEOmPAthnOOeG87)qcyuUcI7lY81aGtauu()HeWOCfEmJADr)dwlisdaobqr5)hsaJYv41hddZ00fB6ObL5Y1pI0aGtauujmB6ipvQiuyoUcVgdrnbJPP)HeWOCfEUmshlKQnD0GIsaYV2BUGzmnrpn7ee3xKAaWjakQeMnDivB6ObfLaKF)hsaJYvqCFrQbaNaOOsy20HkvekmhxHxJHOMGX00)qcyuUcpxgPJfs1MoAqrja5xxdFcA6FibmkxbX9fjHcZXv4Pm2YonQNlJ0XcvQiHUxpLXw2Pr9qzs1MoAqrja5xshtPSiDmuugtmnWTsyksevQ20rdkkbi)EmuugNa3uC4eUHpbdGOs1MoAqrja5xnOOSgBrdkPAPAthnOOEAyLWWcK0tZorcCtXHt4g(emaIsCFrkysO71)pKagLRWdLjvB6Obf1tdRegwqaYV0tZorcCtXHt4g(emaIsCFrEaUCszafmg5lQurcDV(dWLtYEZfmJ9qzQuDaUCszafmg5RefMJRWtTsh9Tzrsb2IJNlJ0XcIiHUxV9Ml4UGtkWwC8qzs1MoAqr90WkHHfeG87)qcyuUcI15ODCkmmmhuK)iUVi1hddZuKkRsfHcZXv41yiQjymn9pKagLRWZLr6yHuTPJguupnSsyybbi)EmuugNa3KcSfhPAthnOOEAyLWWccq(L0XuAxWjWnrHqrzSuTPJguupnSsyybbi)s6ykTl4e4MmOacTKQnD0GI6PHvcdlia5xshtPDbNa3KIUcglvB6Obf1tdRegwqaYVKoMs7cobUjAgUlyPAthnOOEAyLWWccq(1EZfmJPj6PzNqQ20rdkQNgwjmSGaKF)hsaJYvqSohTJtHHH5GI8NuTPJguupnSsyybbi)(2kLkutpmMMogkkJLQnD0GI6PHvcdlia5xnOOSgBrdkI7lscPbfL1ylAq5HYKQnD0GI6PHvcdlia5xr)UlofaNtQ20rdkQNgwjmSGaKFjDmLYI0XqrzmX0a3kHPiv2)kX9fP(yyyMIerLQnD0GI6PHvcdlia5xJE4kDmNdOqQ20rdkQNgwjmSGaKFpgkkJtGBkoCc3WNGbquI7ls9XWWmfPYs1MoAqr90WkHHfeG8lPJPuwKogkkJjMg4wjmfPY(xLQnD0GI6PHvcdlia53JHIY4e4MIdNWn8jyaevQ20rdkQNgwjmSGaKFDn8jOP)HeWOCfs1MoAqr90WkHHfeG8RH1wXPaGXCfs1MoAqr90WkHHfeG8RguuwJTObLuTuTPJguuVgaCcGIII82yM0bacI7lssO71BV5cUl4KcSfhpuMuTPJguuVgaCcGIIsaYVugBzNgvQ20rdkQxdaobqrrja5x7nxWDbNuGT4ivB6Obf1RbaNaOOOeG87b4YjzV5cMXe3xKKq3R3EZfCxWjfyloEOmvQ0aGtauuE7nxWDbNuGT44XmQ1fnxi2dPAthnOOEna4eaffLaKFZardkI7lssO71BV5cUl4KcSfhpuMuTPJguuVgaCcGIIsaYVg9Wv6yohqbX9fjj096T3Cb3fCsb2IJxauus1MoAqr9AaWjakkkbi)(2kLkutpmMMogkkJLQnD0GI61aGtauuucq(v0V7ItbW5iUVipaxoPmGcg7f8T1DKRhs1MoAqr9AaWjakkkbi)cr5uhmkL4(IKe6E9ugBzNg1dLPsfHcZXv4Pm2YonQNlJ0XcPAthnOOEna4eaffLaKFrbOCfjWnb7a4CiUViZW87eSw4)5T3CbZyAIEA2jisdaobqr5T3CbZyAIEA2j8yg16IkvB6Obf1RbaNaOOOeG8leLtDWOexgkJegdkyAkd3OMlHnyM4(Im)81aGtauu()HeWOCf(lKZLWS(yyyofnkNRxvPkFcfMJRWRXqutWyA6FibmkxHNlJ0XcIYW87eSw4)5)hsaJYvKxEePbaNaOO82BUGzmnrpn7eEmJADrZ1RercDVEkJTStJ6XmQ1fnxVMNkv5tcDVEkJTStJ6XmQ1f9VxZtQ20rdkQxdaobqrrja5xikN6GrjUmugjkJzLehJMUwbtCFrsisO71BV5cUl4KcSfhpugr5tcDVEkJTStJ6HYuPIqH54k8ugBzNg1ZLr6yrEs1MoAqr9AaWjakkkbi)cr5uhmkXLHYiXMsHaQucnr2WjmlsKqrakPAPAthnOOE0oAylAqHKEA2jsGBkoCc3WNGbquI7lssO71tpn7ejWnfhoHB4tWaiQxauueL)b4YjLbuWyVGVTUdKpuPIe6E9I(DxCkdcNbOShklpPAthnOOE0oAylAqraYVkayrcCtWoaohI7lssO71)2kLkutpmMMogkkJ9qzs1MoAqr9OD0Ww0GIaKFvaWIe4MGDaCoe3xKKq3RNE6Ql4KRHpr6c5CEOmIiHUxp90vxWjxdFI0fY58yg16I(hSwG4kt0HnxC8z64pc3dIiKg8MlRcFXAmWbWcPAthnOOE0oAylAqraYVkayrcCtWoaohI7lY8pS5IJpth)96J8KQnD0GI6r7OHTObfbi)QaGfjWnb7a4CiUViZVlnaTl4KWqnyo97XJhpqP)DyZfhpQLBe)Nx5xYJOdBU44Z0XFV8crH54k84g(emaIMYWGG1ba75YiDSqQ20rdkQhTJg2IgueG8RcawKa3eSdGZH4(Im)U0a0UGtcd1G50pe9XJhO0)oS5IJh1YnI)ZJy5r0HnxC8z64VxErQ20rdkQhTJg2IgueG8RcawKa3eSdGZH4(Im)U0a0UGtcd1G5eI94Xdu6Fh2CXXJA5gXF4re5r0HnxC8z64pe7fIcZXv4Xn8jyaenLHbbRda2ZLr6yHuTPJguupAhnSfnOia5xfaSibUjyhaNdX9fz(DPbODbNegQbZjc)JhpqP)DyZfhpQLBe)Nx58i6WMlo(mD83lVivtyKtthnOOE0oAylAqraYV0tZorcCtXHt4g(emaIsCFrscDVE6PzNibUP4WjCdFcgar9cGIIO8paxoPmGcgNlLvPIe6E9I(DxCkdcNbOShklpPAthnOOE0oAylAqraYVWqgw0wLa3Kv6MRiPKUGPe3xKDPbODbNegQbZjLF5XduAUoS5IJh1YnI)W)krekFsO71BybxrsWxUem2dLPsfj096HHmSOTkbUjR0nxrsjDbt9qzQurcDVEr)Ulorpn7eEOmvQiHUxFgiAq5HYYtQ20rdkQhTJg2IgueG8ROF3fNONMDcI7lYWCCf(BxMlrdReEUmshliQlnaTl4KWqnyoP8lpEGsZ1HnxC8OwUr8h(xjIq5tcDVEdl4ksc(YLGXEOmvQiHUxpmKHfTvjWnzLU5kskPlyQhktLksO71l63DXj6PzNWdLPsfj096ZardkpuwEs1MoAqr9OD0Ww0GIaKFnSGRij4lxcgtCFr2LgG2fCsyOgmNu(LhpqP56WMloEul3i(d)RerO8jHUxVHfCfjbF5sWypuMkvKq3RhgYWI2Qe4MSs3CfjL0fm1dLPsfj096f97U4e90St4HYuPIe6E9zGObLhklpPAthnOOE0oAylAqraYVolNeOshReuI7lYdBU44Z0XF)EzJn2f]] )


end
