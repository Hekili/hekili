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
                return 3
            end,
            spendType = "holy_power",

            startsCombat = false,
            texture = 1030103,

            talent = "seraphim",

            handler = function ()
                removeBuff( "divine_purpose" )                
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
                return 3
            end,
            spendType = "holy_power",

            defensives = true,

            startsCombat = true,
            texture = 236265,

            handler = function ()
                if talent.redoubt.enabled then addStack( "redoubt", nil, 3 ) end

                removeBuff( "divine_purpose" )                

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
                return 3
            end,
            spendType = "holy_power",
            
            startsCombat = false,
            texture = 133192,
            
            handler = function ()
                if buff.royal_decree.up then removeBuff( "royal_decree" )
                elseif buff.divine_purpose.up then removeBuff( "divine_purpose" )
                else removeBuff( "shining_light_full" ) end

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
                return 1
            end,
            spendType = "holy_power",

            startsCombat = true,
            texture = 3578228,

            toggle = "essences",

            handler = function ()
                removeBuff( "divine_purpose" )                
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


    spec:RegisterPack( "Protection Paladin", 20200926, [[diutRaqiQepcQsTjqPrrf5uuHwLsf9kOQMfvu3sPOQDrYVGidJk1XicltPWZuQW0GQ4AkvzBkf5BkfLXrfeNJkOwhuLqZJkP7bv2hvGdsfKSqiQhcvj6IubPojuLGvQuANGQgkuL0svkQ0tvLPck2lWFfAWsCyklgspMQMSGlJSzj9zOmAv1PLA1kv61GkMnPUTs2TOFRYWjQJRuuXYr55OA6kUoiBNi67ePXdQKZRuvRhuPMpe2pHbsaGb8c2qa43W9gUD7WBSjLeB42H3XEG3SVmbEYMhoggbEPTiWdVYUH8tFPOGxnTf6e8KT91NfaWaE8dI5jW7pJmhVisiH1Zhcv5Vfs8EbPTPV0ZS6GeVxEKapuOwp4fsak4fSHaWVH7nC72H3ytkj2WTdVHdb8mO5FmW71l8sW73HaLauWlqCp4H3IcELDd5N(srbVAAl0PylElkpsEOfkXeLn2KZIYgU3WTyRylElk4LFlXiUylElkBErXHkeOGOS5sOqWHuGNU5dhad4T6PXSPVeadaEjaWaEuAOAkaqg88SEiwBGhkuTQ4)M0H4vJZNISg7p0bXvHtAkkWkkojk)tVFu(KsmvGQTVhrbNO4wuqGquqHQvvOLStkkdXKpoPGKffhbpZp9LGh)3KoeVAC(uK1y)HoioyaWVbagWJsdvtbaYGNN1dXAd8qHQvf)3zNyrDJ9NyfsRvqYIcSIckuTQ4)o7elQBS)eRqATIrlRtUO4QOG5dIYofLnapZp9LGN0JfIxnIPp2(Gba)oaWaEuAOAkaqg88SEiwBGNtIYNm98vY(ruCvuWJBrXrWZ8tFj4j9yH4vJy6JTpyaWJhamGhLgQMcaKbppRhI1g45KO0P)wDIfd2YWOOeUD729IlkUkkFY0ZxTm4su2POiHAJ9efhffyfLpz65RK9JO4QOS3EIcSIYyAkhfRX(dDq8Om7gYphtrPHQPa4z(PVe8KESq8Qrm9X2hma43dad4rPHQPaazWZZ6HyTbEojkD6VvNyXGTmmkkXoC729IlkUkkFY0ZxTm4su2POiHAtIIJIcSIYNm98vY(ruCvu2BpWZ8tFj4j9yH4vJy6JTpyaWVjamGhLgQMcaKbppRhI1g45KO0P)wDIfd2YWO4MC729IlkUkkFY0ZxTm4su2PO4wTzIIJIcSIYNm98vY(ruCvu20EIcSIYyAkhfRX(dDq8Om7gYphtrPHQPa4z(PVe8KESq8Qrm9X2hma43mamGhLgQMcaKbppRhI1g45KO0P)wDIfd2YWOOd72T7fxuCvu(KPNVAzWLOStrrc1gIIJIcSIYNm98vY(ruCvu2BpWZ8tFj4j9yH4vJy6JTpyaW7qaWaEuAOAkaqg88SEiwBGNlIYyAkhfNyM8VxkknunfefyfLo93QtSyWwggf3yp3UxCrXbIYNm98vldUeLDkkUv4ruGvuCruCsuqHQvLXcuoXavPmqmfKSOGaHOGcvRkmiJfAlJxnAPVPCIWPtmUcswuqGquqHQvvOLStkY)nPdkizrbbcrbfQwvY30xQGKffhbpZp9LGhgKXcTLXRgT03uor40jghma4DyamGhLgQMcaKbppRhI1g45IOmMMYrXjMj)7LIsdvtbrbwrzmnLJQ2PPJ8XYGIsdvtbrbwrPt)T6elgSLHrXn2ZT7fxuCGO8jtpF1YGlrzNIIBfEefyffxefNefuOAvzSaLtmqvkdetbjlkiqikOq1QcdYyH2Y4vJw6BkNiC6eJRGKffeiefuOAvfAj7KI8Ft6GcswuqGquqHQvL8n9LkizrXrWZ8tFj4fAj7KI8Ft6ayaWlHBamGhLgQMcaKbppRhI1g45IOmMMYrXjMj)7LIsdvtbrbwrPt)T6elgSLHrXn2ZT7fxuCGO8jtpF1YGlrzNIIBfEefyffxefNefuOAvzSaLtmqvkdetbjlkiqikOq1QcdYyH2Y4vJw6BkNiC6eJRGKffeiefuOAvfAj7KI8Ft6GcswuqGquqHQvL8n9LkizrXrWZ8tFj4zSaLtmqvkdedma4LqcamGhLgQMcaKbppRhI1g45IOmMMYrXjMj)7LIsdvtbrbwr5tME(kz)ikUkksSh4z(PVe802(XlJFldCWagWZFNoCstoaga8saGb8O0q1uaGm45z9qS2apuOAvzssjwNyrPmB(kizWZ8tFj4vBgHQVlaga8BaGb8O0q1uaGm4z(PVe8m4M)nMXJ1lN4vJYNuIbEEwpeRnWZFNoCstfNyM8VxkgTSo5IIR4efjClkiqikUikJPPCuCIzY)EPO0q1ua8sBrGNb38VXmESE5eVAu(KsmWaGFhayapknunfaidEMF6lbpJ)L0sIhzgCFSO)yMg88SEiwBGNtIsGqHQvfZG7Jf9hZ0XaHcvRk(yE4ikoqu2mrbwrbfQwvMKuI1jwukZMVcswuCuuqGqucekuTQygCFSO)yMogiuOAvXhZdhrbNO4g8sBrGNX)sAjXJmdUpw0Fmtdga84bad4z(PVe84eZK)9c8O0q1uaGmyaWVhagWZ8tFj4z8pLXVP1NuWJsdvtbaYGba)MaWaEuAOAkaqg88SEiwBGhkuTQ4eZK)9sbjlkiqik(70HtAQ4eZK)9sXOL1jxuCvu2quqGquCrugtt5O4eZK)9srPHQPa4z(PVe8mjPeRtSOuMnFWaGFZaWaEuAOAkaqg88SEiwBGhkuTQmjPeRtSOuMnFfKm4z(PVe8KVPVema4DiayapZp9LGhQM48oXIxnYHwlIbEuAOAkaqgma4DyamGN5N(sWdvtCENyXRgnObALGhLgQMcaKbdaEjCdGb8m)0xcEOAIZ7elE1O0ohIbEuAOAkaqgma4LqcamGN5N(sWdvtCENyXRg5YSoXapknunfaidga8sSbagWZ8tFj4jPLBoqn)tmE8BRfXapknunfaidga8sSdamGhLgQMcaKbppRhI1g49p9(r5tkXubQ2(EefhikUbpZp9LGxOLStkoNwdga8sGhamGhLgQMcaKbppRhI1g45VthoPPYKKsmIXJ8Ft6GIrlRto4z(PVe8w3IYjE1iM(y7dga8sShagWJsdvtbaYGNN1dXAd8qHQvfNyM8VxkizrbbcrXfrzmnLJItmt(3lfLgQMcGN5N(sWdItXEOfhma4LytayapknunfaidEMF6lbpm2Ly8OmRxMoYmmc88SEiwBGNtIItII)oD4KMQDHcylkhvfsRJmY)nggfNErIIdef8ikiqikojkUikJPPCuEge3ceJh3fkGTOCuuAOAkikWkkYmsYiMpOKqTluaBr5ikokkokkWkk(70HtAQmjPeJy8i)3KoOy0Y6KlkoquWJOaROGcvRkoXm5FVumAzDYffhik4ruCuuqGquCsuqHQvfNyM8VxkgTSo5IIRIcEefhbV0we4HXUeJhLz9Y0rMHrGbaVeBgagWJsdvtbaYGN5N(sWBrmcoZ34XQLyGNN1dXAd8CruqHQvLjjLyDIfLYS5RGKffyffNefuOAvXjMj)7LcswuqGquCrugtt5O4eZK)9srPHQPGO4i4L2IaVfXi4mFJhRwIbga8s4qaWaEuAOAkaqg8sBrGhZG7auchEeTXImkerHM5sWZ8tFj4Xm4oaLWHhrBSiJcruOzUemGb8cu1G0daga8saGb8m)0xcEmcfcoe4rPHQPaazWaGFdamGhLgQMcaKbpZp9LGN306O5N(YOU5d4PB(etBrGN)oD4KMCWaGFhayapknunfaidEMF6lbpVP1rZp9LrDZhWt38jM2IaVvpnMn9LGbapEaWaEuAOAkaqg88SEiwBGhkuTQ0DLq13fu8X8WruCvu2b4z(PVe8KEmDqsQZiJ4xAPNada(9aWaEuAOAkaqg88SEiwBG3)07hLpPetfOA77ruWjkUffyffNefNefuOAvzssjwNyrPmB(kizrbwrXfrzmnLJItmt(3lfLgQMcIIJIcceIckuTQ4eZK)9sbjlkocEMF6lbp(VjDiE148PiRX(dDqCWaGFtayapknunfaidEEwpeRnWZjrbfQwvMKuI1jwukZMVcswuGvuqHQvLjjLyDIfLYS5Ry0Y6KlkUkk4ruGvuCrugtt5O4eZK)9srPHQPGO4OOGaHO4KOGcvRkoXm5FVumAzDYffxff8ikWkkOq1QItmt(3lfKSO4i4z(PVe84)M0H4vJZNISg7p0bXbda(ndad4rPHQPaazWZZ6HyTbE)tVFu(KsmvGQTVhrXbIIBWZ8tFj49T1IyXRgLYS5dga8oeamGhLgQMcaKbppRhI1g4HcvRkoXm5FVuqYIcSIckuTQ4eZK)9sXOL1jxuCvu2b4z(PVe80n2F4XDHcylkhWaG3HbWaEuAOAkaqg88SEiwBGNlII)so5z20xQGKbpZp9LGN)so5z20xcga8s4gad4rPHQPaazWZZ6HyTbEojk(70HtAQ2fkGTOCumAzDYffxffmFquGvu83PdN0uTluaBr5O8FJHr8yLz(PV00IIdefjefyff)D6WjnJmY8JO4OOGaHO4IOmMMYr5zqClqmECxOa2IYrrPHQPa4z(PVe82fkGTOCadaEjKaad4rPHQPaazWZZ6HyTbE(70HtAgzK5hWZ8tFj4zssjgX4r(VjDama4LydamGhLgQMcaKbppRhI1g45VthoPzKrMFefeiefxeLX0uokpdIBbIXJ7cfWwuokknunfapZp9LG3UqbSfLdyaWlXoaWaEuAOAkaqg88SEiwBGNtIIlIYyAkhfNyM8VxkknunfefeiefuOAvXjMj)7LcswuCuuGvuCruc3O8x6PCy2qHyvBlkIcXsfJwwNCrXbIIBrbbcrH4Ck9KA(u0ZG8nQMIxnw12IumlHJO4QOSdWZ8tFj45V0t5WSHcXQ2weyaWlbEaWaEuAOAkaqg88SEiwBGNlIYyAkhfNyM8VxkknunfefeiefuOAvXjMj)7Lcsg8m)0xcE6g7p84UqbSfLdyaWlXEayapZp9LGNL9YIxngiB(GhLgQMcaKbdaEj2eagWJsdvtbaYGN5N(sWdvtCofIFBTig4XhwdhIdE7ama4LyZaWaEMF6lbVVTwelE148PiRX(dDqCWJsdvtbaYGbaVeoeamGN5N(sWZFjN8mB6lbpknunfaidga8s4WayapknunfaidEEwpeRnWZfrXjrH4Ck9KA(u0ZG8nQMIxnw12IulB3JjkiqikeNtPNuspMoij1zKr8lT0tQLT7XefeiefIZP0tkl7LfVAu3vkAzigiB(QLT7XefeiefIZP0tQfTo2(XRg1q(oedmYwC1Y29yIIJGN5N(sW7tgBIeNtPNadyapzg5VfQnayaWlbagWJsdvtbaYGba)gayapknunfaidga87aad4rPHQPaazWaGhpayapknunfaidga87bGb8m)0xcEY30xcEuAOAkaqgma43eagWZ8tFj4PBS)WJ7cfWwuoGhLgQMcaKbdyad4jjX49La43W9gUD7Wsib4j1yzNyCWdVWs(ydfef8ikMF6lffDZhUsSf8KzxT1e4H3IcELDd5N(srbVAAl0PylElkpsEOfkXeLn2KZIYgU3WTyRylElk4LFlXiUylElkBErXHkeOGOS5sOqWHuITIT4TO4qdxKhAOGOGs1JrII)wO2ikOewNCLO4q59K8WfL8Yn)3yRkKwum)0xYfLl17ReBn)0xYvYmYFluBWv1ghoITMF6l5kzg5VfQn4JdP6DbXwZp9LCLmJ83c1g8XHKbHTOCSPVuSfVfLxAY8)nIcZ6GOGcvRuqu4JnCrbLQhJef)TqTruqjSo5IILbrrMrBE5BMoXeLMlkHljLyR5N(sUsMr(BHAd(4qINMm)FtKp2WfBn)0xYvYmYFluBWhhsY30xk2A(PVKRKzK)wO2GpoK0n2F4XDHcylkhXwXw8wuCOHlYdnuquijj2(IY0lsuMpjkMFoMO0CrXK0ATHQjLyR5N(soogHcbhsS18tFjhFCi5nToA(PVmQB(4CAlcN)oD4KMCXwZp9LC8XHK306O5N(YOU5JZPTiCREAmB6lfBn)0xYXhhsspMoij1zKr8lT0to3vCOq1Qs3vcvFxqXhZdhx3HyR5N(so(4qI)BshIxnoFkYAS)qhe35UI7F69JYNuIPcuT99GZnSo5ekuTQmjPeRtSOuMnFfKmSUmMMYrXjMj)7LIsdvtbhrGafQwvCIzY)EPGKDuS18tFjhFCiX)nPdXRgNpfzn2FOdI7CxX5ekuTQmjPeRtSOuMnFfKmSOq1QYKKsSoXIsz28vmAzDYDfpW6YyAkhfNyM8VxkknunfCebcNqHQvfNyM8VxkgTSo5UIhyrHQvfNyM8VxkizhfBn)0xYXhhsFBTiw8QrPmB(o3vC)tVFu(KsmvGQTVhh4wS18tFjhFCiPBS)WJ7cfWwuoo3vCOq1QItmt(3lfKmSOq1QItmt(3lfJwwNCx3HyR5N(so(4qYFjN8mB6lDUR4CXFjN8mB6lvqYITMF6l54JdPDHcylkhN7koN83PdN0uTluaBr5Oy0Y6K7kMpaR)oD4KMQDHcylkhL)BmmIhRmZp9LM2bsaR)oD4KMrgz(XreiCzmnLJYZG4wGy84UqbSfLJIsdvtbXwZp9LC8XHKjjLyeJh5)M0bN7ko)D6WjnJmY8JyR5N(so(4qAxOa2IYX5UIZFNoCsZiJm)GaHlJPPCuEge3ceJh3fkGTOCuuAOAki2A(PVKJpoK8x6PCy2qHyvBlY5UIZjxgtt5O4eZK)9srPHQPaceOq1QItmt(3lfKSJW6s4gL)spLdZgkeRABrruiwQy0Y6K7a3iqqCoLEsnFk6zq(gvtXRgRABrkMLWX1Di2A(PVKJpoK0n2F4XDHcylkhN7koxgtt5O4eZK)9srPHQPaceOq1QItmt(3lfKSyR5N(so(4qYYEzXRgdKnFXwZp9LC8XHeQM4Cke)2ArmN5dRHdXXTdXwZp9LC8XH03wlIfVAC(uK1y)HoiUyR5N(so(4qYFjN8mB6lfBn)0xYXhhsFYytK4Ck9KZDfNlorCoLEsnFk6zq(gvtXRgRABrQLT7XqGG4Ck9Ks6X0bjPoJmIFPLEsTSDpgceeNtPNuw2llE1OURu0Yqmq28vlB3JHabX5u6j1IwhB)4vJAiFhIbgzlUAz7EmhfBfBn)0xYv(70HtAYXvBgHQVl4CxXHcvRktskX6elkLzZxbjl2A(PVKR83PdN0KJpoKG4uShA5CAlcNb38VXmESE5eVAu(KsmN7ko)D6WjnvCIzY)EPy0Y6K7kojCJaHlJPPCuCIzY)EPO0q1uqS18tFjx5VthoPjhFCibXPyp0Y50weoJ)L0sIhzgCFSO)yM25UIZPaHcvRkMb3hl6pMPJbcfQwv8X8WXbBgSOq1QYKKsSoXIsz28vqYoIarGqHQvfZG7Jf9hZ0XaHcvRk(yE4GZTyR5N(sUYFNoCsto(4qItmt(3lXwZp9LCL)oD4KMC8XHKX)ug)MwFsfBn)0xYv(70HtAYXhhsMKuI1jwukZMVZDfhkuTQ4eZK)9sbjJaH)oD4KMkoXm5FVumAzDYDDdeiCzmnLJItmt(3lfLgQMcITMF6l5k)D6Wjn54Jdj5B6lDUR4qHQvLjjLyDIfLYS5RGKfBn)0xYv(70HtAYXhhsOAIZ7elE1ihATiMyR5N(sUYFNoCsto(4qcvtCENyXRgnObALITMF6l5k)D6Wjn54JdjunX5DIfVAuANdXeBn)0xYv(70HtAYXhhsOAIZ7elE1ixM1jMyR5N(sUYFNoCsto(4qssl3CGA(Ny843wlIj2A(PVKR83PdN0KJpoKcTKDsX50AN7kU)P3pkFsjMkq123JdCl2A(PVKR83PdN0KJpoKw3IYjE1iM(y77CxX5VthoPPYKKsmIXJ8Ft6GIrlRtUyR5N(sUYFNoCsto(4qcItXEOf35UIdfQwvCIzY)EPGKrGWLX0uokoXm5FVuuAOAki2A(PVKR83PdN0KJpoKG4uShA5CAlchg7smEuM1lthzgg5CxX5Kt(70HtAQ2fkGTOCuviToYi)3yyuC6f5a8GaHtUmMMYr5zqClqmECxOa2IYrrPHQPaSYmsYiMpOKqTluaBr54OJW6VthoPPYKKsmIXJ8Ft6GIrlRtUdWdSOq1QItmt(3lfJwwNChGhhrGWjuOAvXjMj)7LIrlRtUR4XrXwZp9LCL)oD4KMC8XHeeNI9qlNtBr4weJGZ8nESAjMZDfNlOq1QYKKsSoXIsz28vqYW6ekuTQ4eZK)9sbjJaHlJPPCuCIzY)EPO0q1uWrXwZp9LCL)oD4KMC8XHeeNI9qlNtBr4ygChGs4WJOnwKrHik0mxk2k2A(PVKRw90y20xIJ)BshIxnoFkYAS)qhe35UIdfQwv8Ft6q8QX5trwJ9h6G4QWjnH1P)P3pkFsjMkq123do3iqGcvRQqlzNuugIjFCsbj7OyR5N(sUA1tJztFj(4qs6XcXRgX0hBFN7kouOAvX)D2jwu3y)jwH0AfKmSOq1QI)7StSOUX(tScP1kgTSo5UI5d7CdXwZp9LC1QNgZM(s8XHK0JfIxnIPp2(o3vCo9jtpFLSFCfpUDuS18tFjxT6PXSPVeFCij9yH4vJy6JTVZDfNtD6VvNyXGTmmkkHB3UDV4U(jtpF1YGRDkHAJ9Ce2pz65RK9JR7ThSJPPCuSg7p0bXJYSBi)CmfLgQMcITMF6l5QvpnMn9L4JdjPhleVAetFS9DUR4CQt)T6elgSLHrrj2HB3UxCx)KPNVAzW1oLqTjhH9tME(kz)46E7j2A(PVKRw90y20xIpoKKESq8Qrm9X235UIZPo93QtSyWwggf3KB3UxCx)KPNVAzW1oDR2mhH9tME(kz)46M2d2X0uokwJ9h6G4rz2nKFoMIsdvtbXwZp9LC1QNgZM(s8XHK0JfIxnIPp2(o3vCo1P)wDIfd2YWOOd72T7f31pz65RwgCTtjuB4iSFY0Zxj7hx3BpXw8wum)0xYvREAmB6lXhhs8Ft6q8QX5trwJ9h6G4o3vCOq1QI)BshIxnoFkYAS)qhexfoPjSo9p9(r5tkXCWgiqGcvRQqlzNuugIjFCsbj7OyR5N(sUA1tJztFj(4qcdYyH2Y4vJw6BkNiC6eJ7CxX5YyAkhfNyM8VxkknunfGTt)T6elgSLHrXn2ZT7f3bFY0ZxTm4ANUv4bwxCcfQwvglq5eduLYaXuqYiqGcvRkmiJfAlJxnAPVPCIWPtmUcsgbcuOAvfAj7KI8Ft6GcsgbcuOAvjFtFPcs2rXwZp9LC1QNgZM(s8XHuOLStkY)nPdo3vCUmMMYrXjMj)7LIsdvtbyhtt5OQDA6iFSmOO0q1ua2o93QtSyWwggf3yp3UxCh8jtpF1YGRD6wHhyDXjuOAvzSaLtmqvkdetbjJabkuTQWGmwOTmE1OL(MYjcNoX4kizeiqHQvvOLStkY)nPdkizeiqHQvL8n9LkizhfBn)0xYvREAmB6lXhhsglq5eduLYaXCUR4CzmnLJItmt(3lfLgQMcW2P)wDIfd2YWO4g7529I7Gpz65RwgCTt3k8aRloHcvRkJfOCIbQszGykizeiqHQvfgKXcTLXRgT03uor40jgxbjJabkuTQcTKDsr(VjDqbjJabkuTQKVPVubj7OyR5N(sUA1tJztFj(4qsB7hVm(TmWDUR4CzmnLJItmt(3lfLgQMcW(jtpFLSFCvI9apUm5bWVPnbgWaa]] )


end
