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

    spec:RegisterResource( Enum.PowerType.HolyPower, {
        divine_resonance = {
            aura = "divine_resonance",

            last = function ()
                local app = state.buff.divine_resonance.applied
                local t = state.query_time

                return app + floor( t - app )
            end,

            interval = 5,
            value = 1,
        },        
    } )
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

                if legendary.divine_resonance.enabled then applyBuff( "divine_resonance" ) end
            end,

            auras = {
                divine_resonance = {
                    id = 355455,
                    duration = 30,
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


    spec:RegisterPack( "Protection Paladin", 20201225, [[dmukUaqieKhrHWMqiJsrYPev1QGuYRGunlku3suP0UOYVuvzykIJHaldH6zks10GuCnrv2MIu(gcQmoeu6CiOyDiOknpvL6EqY(evYbPqeluvvpKcrAIIkvCrrLkDseufRKIANkQgQOsXsfvQ6PkmvfL9Q0FfzWQ4WKwmIEmLMmHlJAZQ0Nb1OvLtl1QvvYRPqA2u1THy3s(nWWfLJtHOwouphPPlCDq2UQIVtbJhsPoVOI1JGQA(uK9t0lb7SDi0G35epH4jeqmX55iipINoXtBhroz8oYuRrvyEhLIW7i3GbbBJguYtUr9QORDKP54bQyNTdkacB5D8IiJs493p4oEqKola5hTrG8A0GYI1B8J2i2F7GeQ9bHNAj3HqdENt8eINqaXeNNJG8iE6eN3ouO4bW7y0igP741cbxl5oem1UdJqEYnyqW2ObL8KBuVk6sA2iKNCh2YiKmwEiopJLhINq8ePzPzJqEmsFAbZuPzJqEYTYJrIqWc5j3ZKqgLDsZgH8KBLNCpJa(WYZGXA2RrKhmtdCBJguu5buYdcKp6mplpiD0WA0GsEuY23rZu3o8nnO7SDi4Rc5JD2oNGD2ouB0GAhyMeYO8o4sj9Sy)VXoN4D2o4sj9Sy)Vd1gnO2Hv9(KAJgujFtJD4BAKkfH3Hfa8cGHIUXoF67SDWLs6zX(FhQnAqTdR69j1gnOs(Mg7W30ivkcVdKoAynAqTXohn7SDWLs6zX(FhQnAqTdR69j1gnOs(Mg7W30ivkcVdAOLqXIn255TZ2bxkPNf7)DyXDW4w3Xd4ZjLbmWyNGVTTd5bL8mrEisEMsEMsEiHUxN(Hl4UGtgWA8CqzYdrYdHKNq9CfokJ1SxJ44sj9SqEYxEmzsEiHUxhLXA2RrCqzYt(7qTrdQDqFn7fjWnfpoHB4xWai6g78PTZ2bxkPNf7)DyXDW4w3XuYdj0960pCb3fCYawJNdktEisEiHUxN(Hl4UGtgWA8Cygr7IkpFlpOrEisEiK8eQNRWrzSM9AehxkPNfYt(YJjtYZuYdj096OmwZEnIdZiAxu55B5bnYdrYdj096OmwZEnIdktEYFhQnAqTd6RzVibUP4XjCd)cgar3yNt42z7GlL0ZI9)oS4oyCR74b85KYagyStW322H8Kl5zYouB0GAhpfbHXjWnzaRXBJDoHDNTdUuspl2)7WI7GXTUdsO71rzSM9AehuM8qK8qcDVokJ1SxJ4WmI2fvE(wEM(ouB0GAh(g(f00xqcyeUIn25eMD2o4sj9Sy)VdlUdg36oiK8ybfLTynAq5GY2HAJgu7WckkBXA0GAJDobt2z7GlL0ZI9)oS4oyCR7yk5XcaEbWq5(csaJWv4WmI2fvE(wEGTc5Hi5XcaEbWq5(csaJWv4SpfdZ00fR2ObL6LNCjpeipejpwaWlagQeMvBip5lpMmjpesEc1Zv4SyiQkymn9fKagHRWXLs6zXouB0GAhFbjGr4k2yNtab7SDWLs6zX(FhwChmU1DybaVayOsywTXouB0GAh6hUGzmnrFn7fBSZjG4D2o4sj9Sy)VdlUdg36oSaGxamujmR2qEmzsEiK8eQNRWzXquvWyA6libmcxHJlL0ZIDO2Ob1o(csaJWvSXoNGPVZ2bxkPNf7)DyXDW4w3bHKNq9CfokJ1SxJ44sj9SqEmzsEiHUxhLXA2RrCqz7qTrdQD4B4xqtFbjGr4k2yNtaA2z7GlL0ZI9)ouB0GAhKEMszr6PiimEh0a3gLP7y6BSZjiVD2ouB0GAhpfbHXjWnfpoHB4xWai6o4sj9Sy)VXoNGPTZ2HAJgu7WckkBXA0GAhCPKEwS)3yJDKHzlaHuJD2oNGD2ouB0GAhc(diAqLuiSUdUuspl2)BSZjENTd1gnO2X1Z0NfR3yhCPKEwS)3yNp9D2ouB0GAhwqrzlwJgu7GlL0ZI9)g7C0SZ2HAJgu7W3WVGM(csaJWvSdUuspl2)BSXoSaGxamu0D2oNGD2o4sj9Sy)VdlUdg36oiHUxN(Hl4UGtgWA8Cqz7qTrdQDCBmt6baXg7CI3z7qTrdQDqzSM9AKDWLs6zX(FJD(03z7qTrdQDOF4cUl4KbSgVDWLs6zX(FJDoA2z7GlL0ZI9)oS4oyCR7Ge6ED6hUG7cozaRXZbLjpMmjpwaWlagkN(Hl4UGtgWA8Cygr7Ikp5sEM2KDO2Ob1oEaFoj9dxWmEJDEE7SDWLs6zX(FhwChmU1DqcDVo9dxWDbNmG145GY2HAJgu7idenO2yNpTD2o4sj9Sy)VdlUdg36oiHUxN(Hl4UGtgWA8CcGHAhQnAqTdL(4k9uVhyyJDoHBNTd1gnO2XhTmYqn9XyA6PiimEhCPKEwS)3yNty3z7GlL0ZI9)oS4oyCR74b85KYagyStW322H8Kl5zYouB0GAhI(txCkaE)g7CcZoBhCPKEwS)3Hf3bJBDhKq3RJYyn71ioOm5XKj5HqYtOEUchLXA2RrCCPKEwSd1gnO2beLtDWi0n25emzNTdUuspl2)7WI7GXTUJmm)jbBfocC6hUGzmnrFn7fYdrYJfa8cGHYPF4cMX0e91Sx4WmI2fDhQnAqTdeacxrcCtWEaoNn25eqWoBhCPKEwS)3HAJgu7agdkyAkd3iQpHvyEhwChmU1DmL8mL8ybaVayOCFbjGr4kCxiVpHz7tXWCkAewEYL8Gg5XKj5zk5HqYtOEUcNfdrvbJPPVGeWiCfoUusplKhIKNmm)jbBfocCFbjGr4kKN8LN8LhIKhla4fadLt)WfmJPj6RzVWHzeTlQ8Kl5bnYdrYdj096OmwZEnIdZiAxu5jxYdAKN8LhtMKNPKhsO71rzSM9AehMr0UOYZ3YdAKN83rPi8oGXGcMMYWnI6tyfM3yNtaX7SDWLs6zX(FhQnAqTdegZgnEknD1cEhwChmU1Dqi5He6ED6hUG7cozaRXZbLjpejptjpKq3RJYyn71ioOm5XKj5HqYtOEUchLXA2RrCCPKEwip5VJsr4DGWy2OXtPPRwWBSZjy67SDWLs6zX(FhLIW7aRe(cOYO0ezdNWSircfbO2HAJgu7aRe(cOYO0ezdNWSircfbO2yJDqdTekwSZ25eSZ2bxkPNf7)DyXDW4w3HGjHUx3xqcyeUchu2ouB0GAh0xZErcCtXJt4g(fmaIUXoN4D2o4sj9Sy)VdlUdg36oEaFoPmGbglpOKN8KhtMKhsO719a(Cs6hUGzSdktEmzsEEaFoPmGbglpOKh0ipejpH65kCuTSrFBwKmG1454sj9SqEisEiHUxN(Hl4UGtgWA8Cqz7qTrdQDqFn7fjWnfpoHB4xWai6g78PVZ2bxkPNf7)DO2Ob1o(csaJWvSdlUdg36oSpfdZu5bL8qS8yYK8qi5jupxHZIHOQGX00xqcyeUchxkPNf7WMJ1ZPqXWCq35eSXohn7SDO2Ob1oEkccJtGBYawJ3o4sj9Sy)VXopVD2ouB0GAhKEMs7cobUjkeccJ3bxkPNf7)n25tBNTd1gnO2bPNP0UGtGBsHciKAhCPKEwS)3yNt42z7qTrdQDq6zkTl4e4Mm0vW4DWLs6zX(FJDoHDNTd1gnO2bPNP0UGtGBIMH7cEhCPKEwS)3yNty2z7qTrdQDOF4cMX0e91SxSdUuspl2)BSZjyYoBhCPKEwS)3HAJgu74libmcxXoS5y9Ckummh0DobBSZjGGD2ouB0GAhF0Yid10hJPPNIGW4DWLs6zX(FJDobeVZ2bxkPNf7)DyXDW4w3bHKhlOOSfRrdkhu2ouB0GAhwqrzlwJguBSZjy67SDO2Ob1oe9NU4ua8(DWLs6zX(FJDobOzNTdUuspl2)7qTrdQDq6zkLfPNIGW4DyXDW4w3H9PyyMkpOKNPVdAGBJY0DqSdnBSZjiVD2ouB0GAhk9Xv6PEpWWo4sj9Sy)VXoNGPTZ2bxkPNf7)DyXDW4w3H9PyyMkpOKhI3HAJgu74PiimobUP4XjCd)cgar3yNtaHBNTdUuspl2)7qTrdQDq6zkLfPNIGW4DqdCBuMUdIDOzJDobe2D2ouB0GAhpfbHXjWnfpoHB4xWai6o4sj9Sy)VXoNacZoBhQnAqTdFd)cA6libmcxXo4sj9Sy)VXoN4j7SDO2Ob1ouSvlofamMRyhCPKEwS)3yNtmb7SDO2Ob1oSGIYwSgnO2bxkPNf7)n2yhiD0WA0GANTZjyNTdUuspl2)7WI7GXTUdsO71rFn7fjWnfpoHB4xWaiQtamuYdrYZuYZd4ZjLbmWyNGVTTd5bL8mrEmzsEiHUxNO)0fNYGWzak7GYKN83HAJgu7G(A2lsGBkECc3WVGbq0n25eVZ2bxkPNf7)DyXDW4w3bj096(OLrgQPpgttpfbHXoOSDO2Ob1omaWIe4MG9aCoBSZN(oBhCPKEwS)3Hf3bJBDhKq3RJ(6Ql4KVHFr6c59oOm5Hi5He6ED0xxDbN8n8lsxiV3HzeTlQ88T8aBfYdAjpelpejppw9XZLzd55B5HWorEisEiK8ybF4sRWvSfd8aSyhQnAqTddaSibUjypaNZg7C0SZ2bxkPNf7)DyXDW4w3XuYZJvF8Cz2qE(wEqZe5j)DO2Ob1omaWIe4MG9aCoBSZZBNTdUuspl2)7WI7GXTUJPKNUSaKUGtcfrH5ebtMmzccvE(wEES6JNdrrB5bTKhcCeNN8KV8qK88y1hpxMnKNVLN8YtEisEc1Zv4Wn8lyaenLHbbBda2XLs6zXouB0GAhgayrcCtWEaoNn25tBNTdUuspl2)7WI7GXTUJPKNUSaKUGtcfrH5ebtFYKjiu55B55XQpEoefTLh0sEiWnn5jF5Hi55XQpEUmBipFlp5L3ouB0GAhgayrcCtWEaoNn25eUD2o4sj9Sy)VdlUdg36oMsE6Ycq6cojuefMttBYKjiu55B55XQpEoefTLh0sEM4iCYt(YdrYZJvF8Cz2qE(wEMwEYdrYtOEUchUHFbdGOPmmiyBaWoUuspl2HAJgu7WaalsGBc2dW5SXoNWUZ2bxkPNf7)DyXDW4w3XuYtxwasxWjHIOWCIWmzYeeQ88T88y1hphII2YdAjpe4iwEYxEisEES6JNlZgYZ3YtE5Td1gnO2HbawKa3eShGZzJDoHzNTdUuspl2)7WI7GXTUJUSaKUGtcfrH5eX5nzccvEYL88y1hphII2YdAjptCOrEisEiK8mL8qcDVofl4ksc(YLGXoOm5XKj5He6EDWqkw0ALa3Kw2MRiz0UGPoOm5XKj5He6EDI(txCI(A2lCqzYJjtYdj096YardkhuM8K)ouB0GAhWqkw0ALa3Kw2MRiz0UGPBSZjyYoBhCPKEwS)3Hf3bJBDhH65kC3UuFIgAjCCPKEwipejpDzbiDbNekIcZjIZBYeeQ8Kl55XQpEoefTLh0sEM4qJ8qK8qi5zk5He6EDkwWvKe8LlbJDqzYJjtYdj096GHuSO1kbUjTSnxrYODbtDqzYJjtYdj096e9NU4e91Sx4GYKhtMKhsO71LbIguoOm5j)DO2Ob1oe9NU4e91SxSXoNac2z7GlL0ZI9)oS4oyCR7OllaPl4KqruyorCEtMGqLNCjppw9XZHOOT8GwYZehAKhIKhcjptjpKq3RtXcUIKGVCjySdktEmzsEiHUxhmKIfTwjWnPLT5ksgTlyQdktEmzsEiHUxNO)0fNOVM9chuM8yYK8qcDVUmq0GYbLjp5Vd1gnO2HIfCfjbF5sW4n25eq8oBhCPKEwS)3Hf3bJBDhpw9XZLzd55B5HG82HAJgu7WR5Kav6PLGUXgBSJpmM2GANt8eINqaXtM2omO4Qly6oi8GKbWblKN8Kh1gnOKhFtdQtAEh0m2UZN202rggCBpVdJqEYnyqW2ObL8KBuVk6sA2iKNCh2YiKmwEiopJLhINq8ePzPzJqEmsFAbZuPzJqEYTYJrIqWc5j3ZKqgLDsZgH8KBLNCpJa(WYZGXA2RrKhmtdCBJguu5buYdcKp6mplpiD0WA0GsEuY23rZuN0S0Srip5UOnBHcwipK8fGz5Xcqi1qEiz4UOo5XiXA5SGkpfOYTpfJCH8YJAJguu5bu(CCsZQnAqrDzy2cqi1aDu)e8hq0GkPqyvAwTrdkQldZwacPgOJ631Z0NfR3qAwTrdkQldZwacPgOJ6Nfuu2I1ObL0SAJguuxgMTaesnqh1pFd)cA6libmcxH0S0Srip5UOnBHcwip8hgNJ8enclpXJLh1gaS80u5r)OTxj9StAwTrdkkkmtczuwAwTrdkk6O(zvVpP2ObvY30W4sryuwaWlagkQ0SAJguu0r9ZQEFsTrdQKVPHXLIWOq6OH1ObL0SAJguu0r9ZQEFsTrdQKVPHXLIWOOHwcflKMLMvB0GIIoQF0xZErcCtXJt4g(fmaIACFr9a(Cszadm2j4BB7a1eIMAksO71PF4cUl4KbSgphugrekupxHJYyn71ioUusplY3KjsO71rzSM9Aehuw(sZQnAqrrh1p6RzVibUP4XjCd)cgarnUVOMIe6ED6hUG7cozaRXZbLrej0960pCb3fCYawJNdZiAx0VrdrekupxHJYyn71ioUusplY3KPPiHUxhLXA2RrCygr7I(nAiIe6EDugRzVgXbLLV0SAJguu0r97PiimobUjdynEg3xupGpNugWaJDc(22oY1ePz1gnOOOJ6NVHFbn9fKagHRW4(IIe6EDugRzVgXbLrej096OmwZEnIdZiAx0VNU0SAJguu0r9ZckkBXA0GY4(IIqwqrzlwJguoOmPz1gnOOOJ63xqcyeUcJ7lQPSaGxamuUVGeWiCfomJODr)g2kiYcaEbWq5(csaJWv4SpfdZ00fR2ObL6ZfbezbaVayOsywTr(MmrOq9CfolgIQcgttFbjGr4kCCPKEwinR2ObffDu)0pCbZyAI(A2lmUVOSaGxamujmR2qAwTrdkk6O(9fKagHRW4(IYcaEbWqLWSAdtMiuOEUcNfdrvbJPPVGeWiCfoUusplKMvB0GIIoQF(g(f00xqcyeUcJ7lkcfQNRWrzSM9AehxkPNfMmrcDVokJ1SxJ4GYKMvB0GIIoQFKEMszr6Piim2yAGBJYuutxAwTrdkk6O(9ueegNa3u84eUHFbdGOsZQnAqrrh1plOOSfRrdkPzPz1gnOOoAOLqXcu0xZErcCtXJt4g(fmaIACFrjysO719fKagHRWbLjnR2Obf1rdTekwGoQF0xZErcCtXJt4g(fmaIACFr9a(CszadmgvEMmrcDVUhWNts)WfmJDqzMm9a(CszadmgfAikupxHJQLn6BZIKbSgphxkPNfercDVo9dxWDbNmG145GYKMvB0GI6OHwcflqh1VVGeWiCfgBZX65uOyyoOOiW4(IY(ummtrrSjtekupxHZIHOQGX00xqcyeUchxkPNfsZQnAqrD0qlHIfOJ63trqyCcCtgWA8KMvB0GI6OHwcflqh1psptPDbNa3efcbHXsZQnAqrD0qlHIfOJ6hPNP0UGtGBsHciKsAwTrdkQJgAjuSaDu)i9mL2fCcCtg6kyS0SAJguuhn0sOyb6O(r6zkTl4e4MOz4UGLMvB0GI6OHwcflqh1p9dxWmMMOVM9cPz1gnOOoAOLqXc0r97libmcxHX2CSEofkgMdkkcKMvB0GI6OHwcflqh1VpAzKHA6JX00trqyS0SAJguuhn0sOyb6O(zbfLTynAqzCFrrilOOSfRrdkhuM0SAJguuhn0sOyb6O(j6pDXPa49sZQnAqrD0qlHIfOJ6hPNPuwKEkccJnMg42OmffXo0yCFrzFkgMPOMU0SAJguuhn0sOyb6O(P0hxPN69adsZQnAqrD0qlHIfOJ63trqyCcCtXJt4g(fmaIACFrzFkgMPOiwAwTrdkQJgAjuSaDu)i9mLYI0trqySX0a3gLPOi2HgPz1gnOOoAOLqXc0r97PiimobUP4XjCd)cgarLMvB0GI6OHwcflqh1pFd)cA6libmcxH0SAJguuhn0sOyb6O(PyRwCkaymxH0SAJguuhn0sOyb6O(zbfLTynAqjnlnR2Obf1zbaVayOOOUnMj9aGW4(IIe6ED6hUG7cozaRXZbLjnR2Obf1zbaVayOOOJ6hLXA2RrKMvB0GI6SaGxamuu0r9t)WfCxWjdynEsZQnAqrDwaWlagkk6O(9a(Cs6hUGzSX9ffj0960pCb3fCYawJNdkZKjla4fadLt)WfCxWjdynEomJODrZ10MinR2Obf1zbaVayOOOJ6xgiAqzCFrrcDVo9dxWDbNmG145GYKMvB0GI6SaGxamuu0r9tPpUsp17bgmUVOiHUxN(Hl4UGtgWA8CcGHsAwTrdkQZcaEbWqrrh1VpAzKHA6JX00trqyS0SAJguuNfa8cGHIIoQFI(txCkaEVX9f1d4ZjLbmWyNGVTTJCnrAwTrdkQZcaEbWqrrh1pikN6GrOg3xuKq3RJYyn71ioOmtMiuOEUchLXA2RrCCPKEwinR2Obf1zbaVayOOOJ6hcaHRibUjypaNJX9fvgM)KGTchbo9dxWmMMOVM9cISaGxamuo9dxWmMMOVM9chMr0UOsZQnAqrDwaWlagkk6O(br5uhmIXLIWOGXGcMMYWnI6tyfMnUVOMAkla4fadL7libmcxH7c59jmBFkgMtrJW5cnMmnfHc1Zv4SyiQkymn9fKagHRWXLs6zbrzy(tc2kCe4(csaJWvKF(ezbaVayOC6hUGzmnrFn7fomJODrZfAiIe6EDugRzVgXHzeTlAUqt(Mmnfj096OmwZEnIdZiAx0Vrt(sZQnAqrDwaWlagkk6O(br5uhmIXLIWOqymB04P00vlyJ7lkcrcDVo9dxWDbNmG145GYiAksO71rzSM9AehuMjtekupxHJYyn71ioUusplYxAwTrdkQZcaEbWqrrh1pikN6GrmUuegfwj8fqLrPjYgoHzrIekcqjnlnR2Obf1H0rdRrdku0xZErcCtXJt4g(fmaIACFrrcDVo6RzVibUP4XjCd)cgarDcGHIOPEaFoPmGbg7e8TTDGAIjtKq3Rt0F6Itzq4maLDqz5lnR2Obf1H0rdRrdk0r9ZaalsGBc2dW5yCFrrcDVUpAzKHA6JX00trqySdktAwTrdkQdPJgwJguOJ6NbawKa3eShGZX4(IIe6ED0xxDbN8n8lsxiV3bLrej096OVU6co5B4xKUqEVdZiAx0VHTc0IyIES6JNlZgFtyNqeHSGpCPv4k2IbEawinR2Obf1H0rdRrdk0r9ZaalsGBc2dW5yCFrn1JvF8Cz24B0mjFPz1gnOOoKoAynAqHoQFgayrcCtWEaohJ7lQP6Ycq6cojuefMtemzYKji0VFS6JNdrrB0IahX5Lprpw9XZLzJVZlpIc1Zv4Wn8lyaenLHbbBda2XLs6zH0SAJguuhshnSgnOqh1pdaSibUjypaNJX9f1uDzbiDbNekIcZjcM(KjtqOF)y1hphII2OfbUPLprpw9XZLzJVZlpPz1gnOOoKoAynAqHoQFgayrcCtWEaohJ7lQP6Ycq6cojuefMttBYKji0VFS6JNdrrB0AIJWLprpw9XZLzJVNwEefQNRWHB4xWaiAkddc2gaSJlL0ZcPz1gnOOoKoAynAqHoQFgayrcCtWEaohJ7lQP6Ycq6cojuefMteMjtMGq)(XQpEoefTrlcCeNprpw9XZLzJVZlpPzJqEuB0GI6q6OH1Obf6O(rFn7fjWnfpoHB4xWaiQX9ffj096OVM9Ie4MIhNWn8lyae1jagkIM6b85KYagyCUi2KjsO71j6pDXPmiCgGYoOS8LMvB0GI6q6OH1Obf6O(bdPyrRvcCtAzBUIKr7cMACFr1LfG0fCsOikmNioVjtqO56XQpEoefTrRjo0qeHMIe6EDkwWvKe8LlbJDqzMmrcDVoyiflATsGBslBZvKmAxWuhuMjtKq3Rt0F6It0xZEHdkZKjsO71LbIguoOS8LMvB0GI6q6OH1Obf6O(j6pDXj6RzVW4(IkupxH72L6t0qlHJlL0ZcI6Ycq6cojuefMteN3Kji0C9y1hphII2O1ehAiIqtrcDVofl4ksc(YLGXoOmtMiHUxhmKIfTwjWnPLT5ksgTlyQdkZKjsO71j6pDXj6RzVWbLzYej096Yardkhuw(sZQnAqrDiD0WA0GcDu)uSGRij4lxcgBCFr1LfG0fCsOikmNioVjtqO56XQpEoefTrRjo0qeHMIe6EDkwWvKe8LlbJDqzMmrcDVoyiflATsGBslBZvKmAxWuhuMjtKq3Rt0F6It0xZEHdkZKjsO71LbIguoOS8LMvB0GI6q6OH1Obf6O(51CsGk90sqnUVOES6JNlZgFtqEBSXUa]] )


end
