-- PaladinProtection.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


local PTR = ns.PTR


if UnitClassBase( 'player' ) == 'PALADIN' then
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
            duration = 3,
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


    -- Gear Sets
    spec:RegisterGear( 'tier19', 138350, 138353, 138356, 138359, 138362, 138369 )
    spec:RegisterGear( 'tier20', 147160, 147162, 147158, 147157, 147159, 147161 )
        spec:RegisterAura( 'sacred_judgment', {
            id = 246973,
            duration = 8,
            max_stack = 1,
        } )        

    spec:RegisterGear( 'tier21', 152151, 152153, 152149, 152148, 152150, 152152 )
    spec:RegisterGear( 'class', 139690, 139691, 139692, 139693, 139694, 139695, 139696, 139697 )

    spec:RegisterGear( "breastplate_of_the_golden_valkyr", 137017 )
    spec:RegisterGear( "heathcliffs_immortality", 137047 )
    spec:RegisterGear( 'justice_gaze', 137065 )
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
            end,
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
            cooldown = 300,
            gcd = "off",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 135919,

            handler = function ()
                applyBuff( "guardian_of_ancient_kings" )
            end,
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
            end,
        },


        turn_evil = {
            id = 10326,
            cast = 1.5,
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
                if buff.divine_purpose.up or buff.shining_light.stack == 5 then return 0 end
                return 3
            end,
            spendType = "holy_power",
            
            startsCombat = false,
            texture = 133192,
            
            handler = function ()
                if buff.divine_purpose.up then removeBuff( "divine_purpose" )
                else removeBuff( "shining_light_full" ) end

                gain( 2.9 * stat.spell_power * ( 1 + stat.versatility_atk_mod ), "health" )

                if buff.vanquishers_hammer.up then
                    applyBuff( "shield_of_the_righteous" )
                    removeBuff( "vanquishers_hammer" )
                end 
            end,
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
                if spec.protection then
                    -- Cast Avenger's Shield x5.
                    -- This is lazy and may be wrong/bad.
                    for i = 1, active_enemies do
                        class.abilities.avengers_shield.handler()
                    end
                elseif spec.retribution then
                    -- Cast Judgment x5.
                    for i = 1, active_enemies do
                        class.abilities.judgment.handler()
                    end
                elseif spec.holy then
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
                    duration = 30,
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


    spec:RegisterPack( "Protection Paladin", 20200911, [[di0tRaqiQkEeuuTjqPrrv0POkSkLs5vKGzrvQBPus1Ui6xqKHrv1XGOwMsvEMsjMgOIRPuX2GI4BkLKXbfjNJQKADqrknpQkDpO0(OkXbPkjzHqHhcfP6IuLK6KqrkwPsXobvnuQsILQusPNQktfuSxG)k0GL4WuwmKEmvMSGlJSzj9zOA0QQtl1QvQ0RbvA2K62kz3I(TkdNKoUsjflhLNJQPR46GSDsOVtIgVsP68kv16HIY8HW(jmazamGxWgca)E(3ZVFVgzKL(XuWzNT41G3SVkbEQMdUgobEPTiWZRWUHCtFPO4vmTf6e8uT91NfaWaE8dI5iW7pJkhtlsiH3Zhcv6Ufs8EbPTPV0XS6GeVxoKapuOwpyAsak4fSHaWVN)9873RrgzPFmfC2zlyc4zqZ)yG3Rxy6G3VdbkbOGxG4oWdZffVc7gYn9LIIxX0wOtXgmxuEK6qluIjkiJS3IYE(3ZVyJydMlky6FlXjUydMlkBDrXRkeOGOS1sOqWLKGNU5dhad4T6PXTPVeadaEKbWaEuAOAkaWa8CSEiwBGhkuTk5)M0H4vJZNISg)p0bXLHtzkkWkkEkk)tVFu9usmzGQTRhrbRO4xuqGquqHQvzOvStkQcXupojHuffpapZn9LGh)3KoeVAC(uK14)HoioyaWVhagWJsdvtbagGNJ1dXAd8qHQvj)3zN4rDJ)NyfsRLqQIcSIckuTk5)o7epQB8)eRqATKrlRtUO4ROG7cIY2eL9apZn9LGNYJfIxnIRp2(Gba)waWaEuAOAkaWa8CSEiwBGNNIYNm98LQUru8vuGJFrXdWZCtFj4P8yH4vJ46JTpyaWdhamGhLgQMcamaphRhI1g45PO0P7wDIhd2YWPiY(973)Ilk(kkFY0ZxUSTlkBtuqwU3oIIhIcSIYNm98LQUru8vu2zhrbwrzmnLJK14)HoiEuLDd5MJjP0q1ua8m30xcEkpwiE1iU(y7dga87aGb8O0q1uaGb45y9qS2appfLoD3Qt8yWwgofrEl(97FXffFfLpz65lx22fLTjkilXerXdrbwr5tME(sv3ik(kk7Sd4zUPVe8uESq8QrC9X2hma4XeamGhLgQMcamaphRhI1g45PO0P7wDIhd2YWPiM43V)fxu8vu(KPNVCzBxu2MO4xUvIIhIcSIYNm98LQUru8vuWKDefyfLX0uoswJ)h6G4rv2nKBoMKsdvtbWZCtFj4P8yH4vJ46JTpyaWVvayapknunfayaEowpeRnWZtrPt3T6epgSLHtrV2VF)lUO4RO8jtpF5Y2UOSnrbz5EIIhIcSIYNm98LQUru8vu2zhWZCtFj4P8yH4vJ46JTpyaWJPaWaEuAOAkaWa8CSEiwBGNpIYyAkhjNyM6VxsknunfefyfLoD3Qt8yWwgof3Bh)(xCrXlIYNm98LlB7IY2ef)s4ikWkk(ikEkkOq1Q0ybkNyGQugiMesvuqGquqHQvjoKXcTLXRgT01uor42joxcPkkiqikOq1Qm0k2jf5)M0bjKQOGaHOGcvRs1B6lLqQIIhGN5M(sWdhYyH2Y4vJw6AkNiC7eNdga8EnagWJsdvtbagGNJ1dXAd88rugtt5i5eZu)9ssPHQPGOaROmMMYrw700r(yzqsPHQPGOaRO0P7wDIhd2YWP4E743)IlkEru(KPNVCzBxu2MO4xchrbwrXhrXtrbfQwLglq5eduLYaXKqQIcceIckuTkXHmwOTmE1OLUMYjc3oX5sivrbbcrbfQwLHwXoPi)3KoiHuffeiefuOAvQEtFPesvu8a8m30xcEHwXoPi)3Koaga8i7had4rPHQPaadWZX6HyTbE(ikJPPCKCIzQ)EjP0q1uquGvu60DRoXJbBz4uCVD87FXffVikFY0ZxUSTlkBtu8lHJOaRO4JO4POGcvRsJfOCIbQszGysivrbbcrbfQwL4qgl0wgVA0sxt5eHBN4CjKQOGaHOGcvRYqRyNuK)BshKqQIcceIckuTkvVPVucPkkEaEMB6lbpJfOCIbQszGyGbapYidGb8O0q1uaGb45y9qS2apFeLX0uosoXm1FVKuAOAkikWkkFY0ZxQ6grXxrb5DapZn9LGN22pEz8BzGdgWaEU70HtzYbWaGhzamGhLgQMcamaphRhI1g4HcvRstrkX7epQKzZxcPcEMB6lbVAZiu9DbWaGFpamGhLgQMcamapZn9LGNHz8VXmESE5eVAu9usmWZX6HyTbEU70Htzk5eZu)9sYOL1jxu8fROGSFrbbcrXhrzmnLJKtmt93ljLgQMcGxAlc8mmJ)nMXJ1lN4vJQNsIbga8Bbad4rPHQPaadWZCtFj4z8VIws8iZWSJfDhZ0GNJ1dXAd88uucekuTkzgMDSO7yMogiuOAvYhZbxrXlIYwjkWkkOq1Q0uKs8oXJkz28LqQIIhIcceIsGqHQvjZWSJfDhZ0XaHcvRs(yo4kkyff)GxAlc8m(xrljEKzy2XIUJzAWaGhoayapZn9LGhNyM6VxGhLgQMcamada(DaWaEMB6lbpJ)Pm(nT(ucEuAOAkaWama4XeamGhLgQMcamaphRhI1g4HcvRsoXm1FVKqQIcceII7oD4uMsoXm1FVKmAzDYffFfL9efeiefFeLX0uosoXm1FVKuAOAkaEMB6lbptrkX7epQKzZhma43kamGhLgQMcamaphRhI1g4HcvRstrkX7epQKzZxcPcEMB6lbp1B6lbdaEmfagWZCtFj4HQjoVt84vJCO1IyGhLgQMcamadaEVgad4zUPVe8q1eN3jE8QrdAGwj4rPHQPaadWaGhz)ayapZn9LGhQM48oXJxnQSZHyGhLgQMcamadaEKrgad4zUPVe8q1eN3jE8QrUkRtCWJsdvtbagGbapY7bGb8m30xcEkA5wduZ)eJh)2ArmWJsdvtbagGbapYBbad4rPHQPaadWZX6HyTbE)tVFu9usmzGQTRhrXlIYwapZn9LGxOvStkoNwdga8idhamGhLgQMcamaphRhI1g45UthoLP0uKsCIXJ8Ft6GKrlRto4zUPVe8w3IYjE1iU(y7dga8iVdagWJsdvtbagGNJ1dXAd8qHQvjNyM6VxsivrbbcrXhrzmnLJKtmt93ljLgQMcGN5M(sWdItXEOfhma4rgtaWaEuAOAkaWa8m30xcE4SlX5rvwVmDKz4e45y9qS2appffpff3D6WPmL7cfWxuoYkKwhzK7BmCko9IefVikWruqGqu8uu8rugtt5iDmiUfigpUluaFr5iP0q1uquGvuuzKIrCxqISCxOa(IYru8qu8quGvuC3PdNYuAksjoX4r(VjDqYOL1jxu8IOahrbwrbfQwLCIzQ)Ejz0Y6KlkEruGJO4HOGaHO4POGcvRsoXm1FVKmAzDYffFff4ikEaEPTiWdNDjopQY6LPJmdNadaEK3kamGhLgQMcamapZn9LG3IyeCNVXJvlXbphRhI1g45JOGcvRstrkX7epQKzZxcPkkWkkEkkOq1QKtmt93ljKQOGaHO4JOmMMYrYjMP(7LKsdvtbrXdWlTfbElIrWD(gpwTehma4rgtbGb8O0q1uaGb4L2IapMHzbOeU8iAJhzuiIcnZLGN5M(sWJzywakHlpI24rgfIOqZCjyad4fOQbPhama4rgad4zUPVe8yekeCjWJsdvtbagGba)EayapknunfayaEMB6lbpNP1rZn9LrDZhWt38jM2Iap3D6WPm5Gba)waWaEuAOAkaWa8m30xcEotRJMB6lJ6MpGNU5tmTfbEREACB6lbdaE4aGb8O0q1uaGb45y9qS2apuOAvQ7kHQVli5J5GRO4ROSfWZCtFj4P8y6GIuNrgXV0shbga87aGb8O0q1uaGb45y9qS2aV)P3pQEkjMmq121JOGvu8lkWkkEkkEkkOq1Q0uKs8oXJkz28LqQIcSIIpIYyAkhjNyM6VxsknunfefpefeiefuOAvYjMP(7Lesvu8a8m30xcE8Ft6q8QX5trwJ)h6G4GbapMaGb8O0q1uaGb45y9qS2appffuOAvAksjEN4rLmB(sivrbwrbfQwLMIuI3jEujZMVKrlRtUO4ROahrbwrXhrzmnLJKtmt93ljLgQMcIIhIcceIINIckuTk5eZu)9sYOL1jxu8vuGJOaROGcvRsoXm1FVKqQIIhGN5M(sWJ)BshIxnoFkYA8)qhehma43kamGhLgQMcamaphRhI1g49p9(r1tjXKbQ2UEefVik(bpZn9LG33wlIfVAujZMpyaWJPaWaEuAOAkaWa8CSEiwBGhkuTk5eZu)9scPkkWkkOq1QKtmt93ljJwwNCrXxrzlGN5M(sWt34)Hh3fkGVOCadaEVgad4rPHQPaadWZX6HyTbE(ikUl5KJztFPesf8m30xcEUl5KJztFjyaWJSFamGhLgQMcamaphRhI1g45PO4UthoLPCxOa(IYrYOL1jxu8vuWDbrbwrXDNoCkt5Uqb8fLJ09ngoXJvM5M(stlkEruqwuGvuC3PdNYmYiZnIIhIcceIIpIYyAkhPJbXTaX4XDHc4lkhjLgQMcGN5M(sWBxOa(IYbma4rgzamGhLgQMcamaphRhI1g45UthoLzKrMBapZn9LGNPiL4eJh5)M0bWaGh59aWaEuAOAkaWa8CSEiwBGN7oD4uMrgzUruqGqu8rugtt5iDmiUfigpUluaFr5iP0q1ua8m30xcE7cfWxuoGbapYBbad4rPHQPaadWZX6HyTbEEkk(ikJPPCKCIzQ)EjP0q1uquqGquqHQvjNyM6VxsivrXdrbwrXhrjCJ0DPJYHzdfIvTTOikelLmAzDYffVik(ffeiefIZP0rY5trhdY1OAkE1yvBlsYSeUIIVIYwapZn9LGN7shLdZgkeRABrGbapYWbad4rPHQPaadWZX6HyTbE(ikJPPCKCIzQ)EjP0q1uquqGquqHQvjNyM6VxsivWZCtFj4PB8)WJ7cfWxuoGbapY7aGb8m30xcEw2llE1yGS5dEuAOAkaWama4rgtaWaEuAOAkaWa8m30xcEOAIZPq8BRfXap(WA4sCWBlGbapYBfagWZCtFj49T1IyXRgNpfzn(FOdIdEuAOAkaWama4rgtbGb8m30xcEUl5KJztFj4rPHQPaadWaGhzVgad4rPHQPaadWZX6HyTbE(ikEkkeNtPJKZNIogKRr1u8QXQ2wKCz7EmrbbcrH4CkDKu5X0bfPoJmIFPLosUSDpMOGaHOqCoLosAzVS4vJ6UsrldXazZxUSDpMOGaHOqCoLosUO1X2pE1OgY1HyGr2Ilx2Uhtu8a8m30xcEFYytK4CkDeyad4PYi3TqTbadaEKbWaEuAOAkaWama43dad4rPHQPaadWaGFlayapknunfayaga8Wbad4rPHQPaadWaGFhamGN5M(sWt9M(sWJsdvtbagGbapMaGb8m30xcE6g)p84Uqb8fLd4rPHQPaadWagWaEksmEFja(98VNF)ETF4i3d8uASStCo4HPzPESHcIcCefZn9LIIU5dxk2aECvYbGhtWeWtLD1wtGhMlkEf2nKB6lffVIPTqNInyUO8i1HwOetuqgzVfL98VNFXgXgmxuW0)wItCXgmxu26IIxviqbrzRLqHGljfBeBWCrXRE7KdAOGOGs1JrII7wO2ikOeENCPO4v5CK6WfL8YT(3yRkKwum30xYfLl17lfBm30xYLQmYDluBWw1ghUInMB6l5svg5UfQnkGfP6DbXgZn9LCPkJC3c1gfWIKbHVOCSPVuSbZfLxAQ8)nIcZ6GOGcvRuqu4JnCrbLQhJef3TqTruqj8o5IILbrrLrBD1BMoXfLMlkHljPyJ5M(sUuLrUBHAJcyrINMk)FtKp2WfBm30xYLQmYDluBualsQ30xk2yUPVKlvzK7wO2OawK0n(F4XDHc4lkhXgXgmxu8Q3o5GgkikKIeBFrz6fjkZNefZnhtuAUOykAT2q1KuSXCtFjhlJqHGlj2yUPVKRawKCMwhn30xg1nF8oTfH1DNoCktUyJ5M(sUcyrYzAD0CtFzu38X70we2vpnUn9LInMB6l5kGfjLhthuK6mYi(Lw6iV7kwuOAvQ7kHQVli5J5GRVBrSXCtFjxbSiX)nPdXRgNpfzn(FOdI7DxX(p9(r1tjXKbQ2UEW6hwp9efQwLMIuI3jEujZMVesfwFgtt5i5eZu)9ssPHQPGhiqGcvRsoXm1FVKqQEi2yUPVKRawK4)M0H4vJZNISg)p0bX9URy9efQwLMIuI3jEujZMVesfwuOAvAksjEN4rLmB(sgTSo5(chy9zmnLJKtmt93ljLgQMcEGaHNOq1QKtmt93ljJwwNCFHdSOq1QKtmt93ljKQhInMB6l5kGfPVTwelE1OsMnFV7k2)P3pQEkjMmq121Jx8l2yUPVKRawK0n(F4XDHc4lkhV7kwuOAvYjMP(7LesfwuOAvYjMP(7LKrlRtUVBrSXCtFjxbSi5UKtoMn9LE3vS(4UKtoMn9LsivXgZn9LCfWI0Uqb8fLJ3DfRNU70Htzk3fkGVOCKmAzDY9f3fG1DNoCkt5Uqb8fLJ09ngoXJvM5M(st7fKH1DNoCkZiJm34bce(mMMYr6yqClqmECxOa(IYrsPHQPGyJ5M(sUcyrYuKsCIXJ8Ft6G3DfR7oD4uMrgzUrSXCtFjxbSiTluaFr54DxX6UthoLzKrMBqGWNX0uoshdIBbIXJ7cfWxuosknunfeBm30xYvalsUlDuomBOqSQTf5DxX6PpJPPCKCIzQ)EjP0q1uabcuOAvYjMP(7Les1dy9jCJ0DPJYHzdfIvTTOikelLmAzDY9IFeiioNshjNpfDmixJQP4vJvTTijZs467weBm30xYvals6g)p84Uqb8fLJ3DfRpJPPCKCIzQ)EjP0q1uabcuOAvYjMP(7LesvSXCtFjxbSizzVS4vJbYMVyJ5M(sUcyrcvtCofIFBTiM38H1WL4y3IyJ5M(sUcyr6BRfXIxnoFkYA8)qhexSXCtFjxbSi5UKtoMn9LInMB6l5kGfPpzSjsCoLoY7UI1hpjoNshjNpfDmixJQP4vJvTTi5Y29yiqqCoLosQ8y6GIuNrgXV0shjx2UhdbcIZP0rsl7LfVAu3vkAzigiB(YLT7XqGG4CkDKCrRJTF8QrnKRdXaJSfxUSDpMhInInMB6l5s3D6WPm5yRnJq13f8URyrHQvPPiL4DIhvYS5lHufBm30xYLU70HtzYvalsqCk2dT8oTfH1Wm(3ygpwVCIxnQEkjM3DfR7oD4uMsoXm1FVKmAzDY9flY(rGWNX0uosoXm1FVKuAOAki2yUPVKlD3PdNYKRawKG4uShA5DAlcRX)kAjXJmdZow0Dmt7DxX6zGqHQvjZWSJfDhZ0XaHcvRs(yo46LTcwuOAvAksjEN4rLmB(sivpqGiqOq1QKzy2XIUJz6yGqHQvjFmhCX6xSXCtFjx6UthoLjxbSiXjMP(7LyJ5M(sU0DNoCktUcyrY4FkJFtRpLInMB6l5s3D6WPm5kGfjtrkX7epQKzZ37UIffQwLCIzQ)EjHurGWDNoCktjNyM6VxsgTSo5(Uhce(mMMYrYjMP(7LKsdvtbXgZn9LCP7oD4uMCfWIK6n9LE3vSOq1Q0uKs8oXJkz28LqQInMB6l5s3D6WPm5kGfjunX5DIhVAKdTwetSXCtFjx6UthoLjxbSiHQjoVt84vJg0aTsXgZn9LCP7oD4uMCfWIeQM48oXJxnQSZHyInMB6l5s3D6WPm5kGfjunX5DIhVAKRY6exSXCtFjx6UthoLjxbSiPOLBnqn)tmE8BRfXeBm30xYLU70HtzYvalsHwXoP4CAT3Df7)07hvpLetgOA76XlBrSXCtFjx6UthoLjxbSiTUfLt8QrC9X237UI1DNoCktPPiL4eJh5)M0bjJwwNCXgZn9LCP7oD4uMCfWIeeNI9qlU3DflkuTk5eZu)9scPIaHpJPPCKCIzQ)EjP0q1uqSXCtFjx6UthoLjxbSibXPyp0Y70wewC2L48OkRxMoYmCY7UI1tpD3PdNYuUluaFr5iRqADKrUVXWP40lYlWbbcp9zmnLJ0XG4wGy84Uqb8fLJKsdvtbyvzKIrCxqISCxOa(IYXdpG1DNoCktPPiL4eJh5)M0bjJwwNCVahyrHQvjNyM6VxsgTSo5EboEGaHNOq1QKtmt93ljJwwNCFHJhInMB6l5s3D6WPm5kGfjiof7HwEN2IWUigb35B8y1sCV7kwFqHQvPPiL4DIhvYS5lHuH1tuOAvYjMP(7LesfbcFgtt5i5eZu)9ssPHQPGhInMB6l5s3D6WPm5kGfjiof7HwEN2IWYmmlaLWLhrB8iJcruOzUuSrSXCtFjxU6PXTPVel)3KoeVAC(uK14)HoiU3DflkuTk5)M0H4vJZNISg)p0bXLHtzcRN)tVFu9usmzGQTRhS(rGafQwLHwXoPOket94Kes1dXgZn9LC5QNg3M(sfWIKYJfIxnIRp2(E3vSOq1QK)7St8OUX)tScP1sivyrHQvj)3zN4rDJ)NyfsRLmAzDY9f3f22EInMB6l5YvpnUn9LkGfjLhleVAexFS99URy98tME(sv34lC87HyJ5M(sUC1tJBtFPcyrs5XcXRgX1hBFV7kwp70DRoXJbBz4uez)(97FX99tME(YLT9THSCVD8a2pz65lvDJV7SdSJPPCKSg)p0bXJQSBi3CmjLgQMcInMB6l5YvpnUn9LkGfjLhleVAexFS99URy9St3T6epgSLHtrK3IF)(xCF)KPNVCzBFBilXepG9tME(sv347o7i2yUPVKlx90420xQawKuESq8QrC9X237UI1ZoD3Qt8yWwgofXe)(9V4((jtpF5Y2(28l3kpG9tME(sv34lMSdSJPPCKSg)p0bXJQSBi3CmjLgQMcInMB6l5YvpnUn9LkGfjLhleVAexFS99URy9St3T6epgSLHtrV2VF)lUVFY0ZxUSTVnKL75bSFY0ZxQ6gF3zhXgmxum30xYLREACB6lvals8Ft6q8QX5trwJ)h6G4E3vSOq1QK)BshIxnoFkYA8)qhexgoLjSE(p9(r1tjX8YEiqGcvRYqRyNuufIPECscP6HyJ5M(sUC1tJBtFPcyrchYyH2Y4vJw6AkNiC7eN7DxX6ZyAkhjNyM6VxsknunfGTt3T6epgSLHtX92XV)f3lFY0ZxUSTVn)s4aRpEIcvRsJfOCIbQszGysiveiqHQvjoKXcTLXRgT01uor42joxcPIabkuTkdTIDsr(VjDqcPIabkuTkvVPVucP6HyJ5M(sUC1tJBtFPcyrk0k2jf5)M0bV7kwFgtt5i5eZu)9ssPHQPaSJPPCK1onDKpwgKuAOAkaBNUB1jEmyldNI7TJF)lUx(KPNVCzBFB(LWbwF8efQwLglq5eduLYaXKqQiqGcvRsCiJfAlJxnAPRPCIWTtCUesfbcuOAvgAf7KI8Ft6GesfbcuOAvQEtFPes1dXgZn9LC5QNg3M(sfWIKXcuoXavPmqmV7kwFgtt5i5eZu)9ssPHQPaSD6UvN4XGTmCkU3o(9V4E5tME(YLT9T5xchy9XtuOAvASaLtmqvkdetcPIabkuTkXHmwOTmE1OLUMYjc3oX5siveiqHQvzOvStkY)nPdsiveiqHQvP6n9LsivpeBm30xYLREACB6lvalsAB)4LXVLbU3DfRpJPPCKCIzQ)EjP0q1ua2pz65lvDJViVdyadaaa]] )


end
