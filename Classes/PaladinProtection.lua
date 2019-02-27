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
        blessed_hammer = 22430, -- 204019

        first_avenger = 22431, -- 203776
        crusaders_judgment = 22604, -- 204023
        bastion_of_light = 22594, -- 204035

        fist_of_justice = 22179, -- 198054
        repentance = 22180, -- 20066
        blinding_light = 21811, -- 115750

        retribution_aura = 22433, -- 203797
        cavalier = 22434, -- 230332
        blessing_of_spellwarding = 22435, -- 204018

        unbreakable_spirit = 22705, -- 114154
        final_stand = 21795, -- 204077
        hand_of_the_protector = 17601, -- 213652

        judgment_of_light = 22189, -- 183778
        consecrated_ground = 22438, -- 204054
        aegis_of_light = 23087, -- 204150

        last_defender = 21201, -- 203791
        righteous_protector = 21202, -- 204074
        seraphim = 22645, -- 152262
    } )

    -- PvP Talents
    spec:RegisterPvpTalents( { 
        gladiators_medallion = 3469, -- 208683
        adaptation = 3470, -- 214027
        relentless = 3471, -- 196029
        shield_of_virtue = 861, -- 215652
        warrior_of_light = 860, -- 210341
        inquisition = 844, -- 207028
        cleansing_light = 3472, -- 236186
        holy_ritual = 3473, -- 199422
        luminescence = 3474, -- 199428
        unbound_freedom = 3475, -- 199325
        hallowed_ground = 90, -- 216868
        steed_of_glory = 91, -- 199542
        judgments_of_the_pure = 93, -- 216860
        guarded_by_the_light = 97, -- 216855
        guardian_of_the_forgotten_queen = 94, -- 228049
        sacred_duty = 92, -- 216853
    } )

    -- Auras
    spec:RegisterAuras( {
        aegis_of_light = {
            id = 204150,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
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
        avengers_valor = {
            id = 197561,
            duration = 15,
            max_stack = 1,
        },
        avenging_wrath = {
            id = 31884,
            duration = function () return azerite.lights_decree.enabled and 25 or 20 end,
            max_stack = 1,
        },
        blessed_hammer = {
            id = 204301,
            duration = 10,
            max_stack = 1,
        },
        blessing_of_freedom = {
            id = 1044,
            duration = function () return ( ( level < 116 and equipped.uthers_guard ) and 1.5 or 1 ) * 8 end,
            type = "Magic",
            max_stack = 1,
        },
        blessing_of_protection = {
            id = 1022,
            duration = function () return ( ( level < 116 and equipped.uthers_guard ) and 1.5 or 1 ) * 10 end,
            max_stack = 1,
            type = "Magic",
        },
        blessing_of_sacrifice = {
            id = 6940,
            duration = function () return ( ( level < 116 and equipped.uthers_guard ) and 1.5 or 1 ) * 12 end,
            max_stack = 1,
            type = "Magic",
        },
        blessing_of_spellwarding = {
            id = 204018,
            duration = function () return ( ( level < 116 and equipped.uthers_guard ) and 1.5 or 1 ) * 10 end,
            type = "Magic",
            max_stack = 1,
        },
        blinding_light = {
            id = 115750,
            duration = 6,
            type = "Magic",
            max_stack = 1,
        },
        consecration = {
            id = 188370,
            duration = 12,
            max_stack = 1,
            generate = function( c, type )
                if type == "buff" and FindUnitBuffByID( "player", 188370 ) then
                    c.count = 1
                    c.expires = last_consecration + 12
                    c.applied = last_consecration
                    c.caster = "player"
                    return
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
        contemplation = {
            id = 121183,
        },
        divine_shield = {
            id = 642,
            duration = 8,
            type = "Magic",
            max_stack = 1,
        },
        divine_steed = {
            id = 221883,
            duration = 3,
            max_stack = 1,
        },
        final_stand = {
            id = 204079,
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
        heart_of_the_crusader = {
            id = 32223,
        },
        judgment_of_light = {
            id = 196941,
            duration = 30,
            max_stack = 25,
        },
        redoubt = {
            id = 280375,
            duration = 8,
            max_stack = 1,
        },
        repentance = {
            id = 20066,
            duration = 6,
            max_stack = 1,
        },
        retribution_aura = {
            id = 203797,
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
        shield_of_the_righteous_icd = {
            duration = 1,
            max_stack = 1,
            generate = function( t, type )
                if type ~= "buff" then return end

                local applied = action.shield_of_the_righteous.lastCast

                if applied > 0 then
                    t.applied = applied
                    t.expires = applied + 1
                    t.count = 1
                    t.caster = "player"
                end
            end,
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


    -- Abilities
    spec:RegisterAbilities( {
        aegis_of_light = {
            id = 204150,
            cast = 6,
            channeled = true,
            cooldown = 180,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,


            startsCombat = false,
            texture = 135909,

            handler = function ()
                applyBuff( "aegis_of_light" )
            end,
        },


        ardent_defender = {
            id = 31850,
            cast = 0,
            cooldown = function ()
                return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * ( ( level < 116 and equipped.pillars_of_inmost_light ) and 0.75 or 1 ) * 120 end,
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
            cooldown = 15,
            gcd = "spell",

            interrupt = true,

            startsCombat = true,
            texture = 135874,

            handler = function ()
                applyBuff( "avengers_valor" )
                applyDebuff( "target", "avengers_shield" )
                interrupt()

                if level < 116 and equipped.breastplate_of_the_golden_valkyr then
                    cooldown.guardian_of_ancient_kings.expires = cooldown.guardian_of_ancient_kings.expires - ( 3 * min( 3 + ( talent.redoubt.enabled and 1 or 0 ) + ( equipped.tyelca_ferren_marcuss_stature and 2 or 0 ), active_enemies ) )
                end

                if talent.redoubt.enabled then
                    applyBuff( "redoubt" ) 
                end
            end,
        },


        avenging_wrath = {
            id = 31884,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135875,

            handler = function ()
                applyBuff( "avenging_wrath" )
            end,
        },


        bastion_of_light = {
            id = 204035,
            cast = 0,
            cooldown = 120,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 535594,

            talent = "bastion_of_light",

            handler = function ()
                gainCharges( "shield_of_the_righteous", 3 )
            end,
        },


        blessed_hammer = {
            id = 204019,
            cast = 0,
            charges = 3,
            cooldown = 4.5,
            recharge = 4.5,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 535595,

            talent = "blessed_hammer",

            handler = function ()
                applyDebuff( "target", "blessed_hammer" )
                last_blessed_hammer = query_time
            end,
        },


        blessing_of_freedom = {
            id = 1044,
            cast = 0,
            charges = 1,
            cooldown = 25,
            recharge = 25,
            gcd = "spell",

            spend = 0.15,
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
            charges = 1,
            cooldown = 300,
            recharge = 300,
            gcd = "spell",

            spend = 0.15,
            spendType = "mana",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 135964,

            notalent = "blessing_of_spellwarding",

            usable = function () return debuff.forbearance.down end,
            handler = function ()
                applyBuff( "blessing_of_protection" )
                applyDebuff( "player", "forbearance" )
            end,
        },


        blessing_of_sacrifice = {
            id = 6940,
            cast = 0,
            charges = 1,
            cooldown = 120,
            recharge = 120,
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

            -- toggle = "cooldowns",
            defensives = true,

            startsCombat = false,
            texture = 135880,

            talent = "blessing_of_spellwarding",

            usable = function () return debuff.forbearance.down end,
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

            spend = 0.08,
            spendType = "mana",

            interrupt = true,

            startsCombat = true,
            texture = 571553,

            toggle = "interrupts",

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

            handler = function ()
            end,
        },


        consecration = {
            id = 26573,
            cast = 0,
            cooldown = 4.5,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 135926,

            handler = function ()
                applyBuff( "consecration", 12 )
                applyDebuff( "target", "consecration_dot" )
                last_consecration = query_time
            end,
        },


        --[[ contemplation = {
            id = 121183,
            cast = 0,
            cooldown = 8,
            gcd = "spell",

            startsCombat = true,
            texture = 134916,

            handler = function ()
            end,
        }, ]]


        divine_shield = {
            id = 642,
            cast = 0,
            cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 300 end,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 524354,

            handler = function ()
                applyBuff( "divine_shield" )
                applyDebuff( "player", "forbearance" )

                if talent.last_defender.enabled then
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
            recharge = 45,
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
                gain( 0.5 * health.max, "health" )
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
            cooldown = function () return ( level < 116 and equipped.justice_gaze ) and 15 or 60 end,
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
            cooldown = 4.5,
            recharge = 4.5,
            hasteCD = true,
            gcd = "spell",

            startsCombat = true,
            texture = 236253,

            notalent = "blessed_hammer",

            handler = function ()
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


        hand_of_the_protector = {
            id = 213652,
            cast = 0,
            charges = function () return ( level < 116 and equipped.saruans_resolve ) and 2 or nil end,
            cooldown = function () return ( ( level < 116 and equipped.saruans_resolve ) and 0.9 or 1 ) * 15 * haste end,
            recharge = function () return ( ( level < 116 and equipped.saruans_resolve ) and 0.9 or 1 ) * 15 * haste end,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 236248,

            talent = "hand_of_the_protector",

            handler = function ()
                gain( 0.1 * health.max, "health" )
            end,
        },


        judgment = {
            id = 275779,
            cast = 0,
            charges = function () return talent.crusaders_judgment.enabled and 2 or nil end,
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

                if talent.judgment_of_light.enabled then applyDebuff( "target", "judgment_of_light", 30, 25 ) end

                if talent.fist_of_justice.enabled then
                    cooldown.hammer_of_justice.expires = max( 0, cooldown.hammer_of_justice.expires - 6 ) 
                end
            end,
        },


        lay_on_hands = {
            id = 633,
            cast = 0,
            cooldown = function () return ( ( level < 116 and equipped.tyrs_hand_of_faith ) and 0.3 or 1 ) * ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 600 end,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 135928,

            handler = function ()
                gain( health.max, "health" )
                applyDebuff( "player", "forbearance" )
                if azerite.empyreal_ward.enabled then applyBuff( "empyrael_ward" ) end
            end,
        },


        light_of_the_protector = {
            id = 184092,
            cast = 0,
            charges = function () return ( level < 116 and equipped.saruans_resolve ) and 2 or nil end,
            cooldown = function () return ( ( level < 116 and equipped.saruans_resolve ) and 0.9 or 1 ) * 17 * haste end,
            recharge = function () return ( ( level < 116 and equipped.saruans_resolve ) and 0.9 or 1 ) * 17 * haste end,
            hasteCD = true,
            gcd = "spell",

            toggle = "defensives",
            defensives = true,

            startsCombat = false,
            texture = 1360763,

            notalent = "hand_of_the_protector",

            handler = function ()
                gain( 0.1 * health.max, "health" )
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

            spend = 0.1,
            spendType = "mana",

            startsCombat = false,
            texture = 135942,

            handler = function ()
                applyDebuff( "target", "repentance" )
            end,
        },


        seraphim = {
            id = 152262,
            cast = 0,
            cooldown = 45,
            gcd = "spell",

            startsCombat = false,
            texture = 1030103,

            usable = function () return cooldown.shield_of_the_righteous.charges > 0 end,
            handler = function ()
                local used = min( 2, cooldown.shield_of_the_righteous.charges )
                applyBuff( "seraphim", used * 8 )
                spendCharges( "shield_of_the_righteous", used )
            end,
        },


        shield_of_the_righteous = {
            id = 53600,
            cast = 0,
            charges = 3,
            cooldown = 18,
            recharge = 18,
            hasteCD = true,
            gcd = "off",

            defensives = true,

            startsCombat = true,
            texture = 236265,

            readyTime = function () return max( gcd.remains, buff.shield_of_the_righteous_icd.remains, ( not talent.bastion_of_light.enabled or cooldown.bastion_of_light.remains > 0 ) and ( recharge * ( 2 - charges_fractional ) ) or 0 ) end,
            handler = function ()
                removeBuff( "avengers_valor" )

                applyBuff( "shield_of_the_righteous", buff.shield_of_the_righteous.remains + 4.5 )
                applyBuff( "shield_of_the_righteous_icd" )

                if talent.righteous_protector.enabled then
                    cooldown.light_of_the_protector.expires = max( 0, cooldown.light_of_the_protector.expires - 3 )
                    cooldown.hand_of_the_protector.expires = max( 0, cooldown.hand_of_the_protector.expires - 3 )
                    cooldown.avenging_wrath.expires = max( 0, cooldown.avenging_wrath.expires - 3 )
                end

                last_shield = query_time
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = true,

        aoe = 2,

        nameplates = true,
        nameplateRange = 8,

        damage = true,
        damageExpiration = 8,

        potion = "potion_of_bursting_blood",

        package = "Protection Paladin",
    } )


    spec:RegisterPack( "Protection Paladin", 20190217.0027, [[dKeDQaqiIOhbK0MKO(KsjvJscCkIIvbe6vsqZsc1Tukj7cPFPuzysKJrewMeYZGQstdi6AkLABaj(grsghqaNJiPwhuvyEkfUhr1(GQQdceOfsu6HqvrnrLIu6IkLuSrLsk9rLIuCsLIeRuPQzQuKKDcvzOkf1svkINcQPcvCvLIu1xvksQ9c5VuzWK6WuwmipwstwKlJAZI6ZQ0OvYPLA1ejEnqQztv3gWUv8BvnCOCCLIuz5eEojtx46Qy7eP(ouPXRuIZde06HQImFGA)igjbcheCYcgHxrLKqQlvKesfTuj8vQKqceCacXyemMvbTDze8yamcEZIp4A0)q0B28wQhemMbc9VLq4GGv)ruze8kcmf(y3UBhRdeT(a7unWXBr)tvy5yNQbQ7G8p0oOSTvjw6DyIp3EwTBZcEtSoP2T5nXTzZBPECBw8bxJ(hQQbQiyOt7JnLbbHGtwWi8kQKesDPIKqQOLkHVsvjPgbBNy9cemCdGpJGxDkXdccbNyvfbdQe9MfFW1O)HO3S5TupK9GkrVIatHp2T72X6arRpWovdC8w0)ufwo2PAG6oi)dTdkBBvILEhM4ZTNv72SG3eRtQDBEtCB28wQh3MfFW1O)HQAGkzpOs0BTmK4ycqirlHuvmrxujjKAIERi6sLWhfbkK9K9GkrJpVS5YkYEqLO3kIgemL4erVjm0b0mfb7BvOq4GGb6OVw0)GWbHNeiCqW8yqEoHKfbxfDWI2qWss0H55jOkwyyRgGYJb55erxMOTA0)qvRM9j3NDXIDI(Uc(pkADzIlRiA8t0fr0LjAjj6ciAOtotn(2k3ND((Uc6bJOlt0qNCMAIepHlXzEsSGEWi6Yen0jNP3JjsTnUp7SP28eoq3ZvrpyeDzIg6KZ0ulDpStTA2NOhmIUmrdDYzk2h9p0dgrldc2Qr)dcwTA2NCF2fl2j67k4)OqbcVIq4GG5XG8CcjlcUk6GfTHGLKOdZZtqvSWWwnaLhdYZjIUmrhMNNGczQO)X9zNVVRGYJb55erxMOTA0)qvRM9j3NDXIDI(Uc(pkADzIlRi6niAjqWwn6FqWqMk6FCF2577kqbcp8fHdcMhdYZjKSi4QOdw0gcUaIEXMpwuSAq0Bq0GSerldc2Qr)dc233v4(SlwSdt8bxJxGceEGeHdcMhdYZjKSi4QOdw0gcUaIEXMpwuSAq0Bq0GSerldc2Qr)dcEztY9zxSyhM4dUgVafi82gHdcMhdYZjKSi4QOdw0gcUaIUN6d0Z1Lma7YojkvQujafrVbrVyZhlkGTfIgejAjOfTnrldrxMOxS5JffRge9ge92Bt0Lj6W88eurFxb)hLdt8bxJxq5XG8CcbB1O)bb777kCF2fl2Hj(GRXlqbcpqbHdcMhdYZjKSi4QOdw0gcUaIUN6d0Z1Lma7YojW3sLkbOi6ni6fB(yrbSTq0GirlbfuiAzi6Ye9InFSOy1GO3GO3EBeSvJ(heSVVRW9zxSyhM4dUgVafi8KkeoiyEmipNqYIGRIoyrBi4ci6EQpqpxxYaSl7aLsLkbOi6ni6fB(yrbSTq0GirxIkveTmeDzIEXMpwuSAq0Bq0GY2eDzIomppbv03vW)r5WeFW14fuEmipNqWwn6FqWlBsUp7If7WeFW14fOaHhiachempgKNtizrWvrhSOneCbeDp1hONRlza2LDsDPsLaue9ge9InFSOa2wiAqKOLGwerldrxMOxS5JffRge9ge92BJGTA0)GGx2KCF2fl2Hj(GRXlqbcpPgHdcMhdYZjKSi4QOdw0gcwsIomppbvXcdB1auEmipNi6YeDp1hONRlza2LDfTDPsakIg)e9InFSOa2wiAqKOlrbjrxMOLKOlGOHo5m14BRCF2577kOhmIgmyIg6KZutK4jCjoZtIf0dgrdgmrdDYz69yIuBJ7ZoBQnpHd09Cv0dgrdgmrdDYzAQLUh2Pwn7t0dgrdgmrdDYzk2h9p0dgrldc2Qr)dc24BRCF2577kqbcpjkHWbbZJb55esweCv0blAdbljrhMNNGQyHHTAakpgKNteDzIUN6d0Z1Lma7YUI2UujafrJFIEXMpwuaBlenis0LOGKOlt0ss0fq0qNCMA8TvUp789Df0dgrdgmrdDYzQjs8eUeN5jXc6bJObdMOHo5m9EmrQTX9zNn1MNWb6EUk6bJObdMOHo5mn1s3d7uRM9j6bJObdMOHo5mf7J(h6bJOLbbB1O)bbFpMi124(SZMAZt4aDpxfkq4jHeiCqW8yqEoHKfbxfDWI2qWss0H55jOkwyyRgGYJb55erxMOdZZtqZ9yENkSjr5XG8CIOlt09uFGEUUKbyx2v02LkbOiA8t0l28XIcyBHObrIUefKeDzIwsIUaIg6KZuJVTY9zNVVRGEWiAWGjAOtotnrINWL4mpjwqpyenyWen0jNP3JjsTnUp7SP28eoq3ZvrpyenyWen0jNPPw6EyNA1SprpyenyWen0jNPyF0)qpyeTmiyRg9pi4ulDpStTA2NqbcpjkcHdcMhdYZjKSi4QOdw0gcwsIomppbvXcdB1auEmipNi6YeDp1hONRlza2LDfTDPsakIg)e9InFSOa2wiAqKOlrbjrxMOLKOlGOHo5m14BRCF2577kOhmIgmyIg6KZutK4jCjoZtIf0dgrdgmrdDYz69yIuBJ7ZoBQnpHd09Cv0dgrdgmrdDYzAQLUh2Pwn7t0dgrdgmrdDYzk2h9p0dgrldc2Qr)dc2ejEcxIZ8Kybkq4jb(IWbbZJb55esweCv0blAdbljrhMNNGQyHHTAakpgKNteDzIEXMpwuSAq0Bq0sSnc2Qr)dc2BGq3pULnjfkqbcU(Vp94okeoi8KaHdcMhdYZjKSi4QOdw0gcg6KZutAEU9CD4kSyrpyiyRg9pi4Clyi))juGWRieoiyEmipNqYIGRIoyrBi46)(0J7qvRM9j3NDXIDI(Uc(pkADzIlRCzHvJ(hZt04xorxec2Qr)dcwXcdB1aOaHh(IWbbZJb55esweCv0blAdbdDYzQIfg2QbOhmIgmyIU(Vp94ouflmSvdqfmG1JIO3GOlIObdMOLKOdZZtqvSWWwnaLhdYZjeSvJ(heSjnp3EUoCfwSqbcpqIWbbZJb55esweCv0blAdbx)3NEChQA1Sp5(SlwSt03vW)rrRltCzLllSA0)yEIEd5eDjeSvJ(hemKPI(h3ND((UcuGWBBeoiyEmipNqYIGRIoyrBiyOtotnP552Z1HRWIf9GHGTA0)GGX(O)bfi8afeoiyEmipNqYIGRIoyrBiyOtotvSWWwna9Gr0Gbt0ss0H55jOkwyyRgGYJb55ec2Qr)dc(OyxhmGcfi8KkeoiyEmipNqYIGTA0)GGVIFUkhMObmVtyxgbxfDWI2qWfq0fq01)9Ph3HkLt6cWtqZhV3j46Yex2fnat04NObjrdgmrxarljrhMNNGwfhLLyHYjLt6cWtq5XG8CIOlt0ycwA3TMOsqLYjDb4jiAziAzi6YeD9FF6XDOM08CzHYPwn7tubdy9OiA8t0GKOlt0qNCMQyHHTAaQGbSEuen(jAqs0Yq0Gbt0fq0qNCMQyHHTAaQGbSEue9genijAzqWJbWi4R4NRYHjAaZ7e2LrbcpqaeoiyEmipNqYIGTA0)GGbybd6yzkx2MlcUk6GfTHGLKOHo5m1KMNBpxhUclw0dgrxMOlGOHo5mvXcdB1a0dgrdgmrljrhMNNGQyHHTAakpgKNteTmi4Xayemalyqhlt5Y2CrbcpPgHdcMhdYZjKSi4XayeSWWNsNb0khuFDco5Gor8dc2Qr)dcwy4tPZaALdQVobNCqNi(bfOabN4SD8bcheEsGWbbB1O)bbBN4Dwewf0iyEmipNqYIceEfHWbbB1O)bblyOdOzempgKNtizrbcp8fHdcMhdYZjKSiyRg9pi4Q59oRg9poFRceSVvHBmagbd0rFTO)bfi8ajchempgKNtizrWwn6FqWvZ7Dwn6FC(wfiyFRc3yamcU(Vp94okuGWBBeoiyEmipNqYIGRIoyrBi4ciAOtotnP55YcLtAZ)c6bJOlt01)9Ph3HQwn7tUp7If7e9Df8Fu06Yexw5YcRg9pMNOXVCIUi62eTmeDzIUaIU(Vp94ouflmSvdqfmG1JIOXprFRjIgmyIwsIomppbvXcdB1auEmipNiAzqWwn6FqWQvZ(K7ZUyXorFxb)hfkq4bkiCqW8yqEoHKfbxfDWI2qWfq0qNCMAsZZTNRdxHfl6bJOlt0ss0H55jOkwyyRgGYJb55erldrdgmrdDYzQIfg2QbOhmIUmrdDYzQjnpxwOCsB(xqpyiyRg9piy1QzFY9zxSyNOVRG)Jcfi8KkeoiyEmipNqYIGRIoyrBi4ciAOtotnP552Z1HRWIf9Gr0LjAOtotnP552Z1HRWIfvWawpkIEdIgKeDzIwsIomppbvXcdB1auEmipNiAziAWGj6ciAOtotvSWWwnavWawpkIEdIgKeDzIg6KZuflmSvdqpyeTmiyRg9piy1QzFY9zxSyNOVRG)Jcfi8abq4GG5XG8CcjlcUk6GfTHGHo5mvXcdB1a0dgrxMOHo5mvXcdB1aubdy9Oi6niA8fbB1O)bb777kuoPCsxaEcuGWtQr4GG5XG8CcjlcUk6GfTHGLKOR)O4QWI(h6bdbB1O)bbx)rXvHf9pOaHNeLq4GG5XG8CcjlcUk6GfTHGlGOR)7tpUdvkN0fGNGkyaRhfrVbrFRjIUmrx)3NEChQuoPlapbTUmXLvUSWQr)J5jA8t0sq0Lj66)(0J74eSvdIwgIgmyIwsIomppbTkoklXcLtkN0fGNGYJb55ec2Qr)dcwkN0fGNafi8KqceoiyEmipNqYIGRIoyrBi46)(0J74eSvdeSvJ(heSjnpxwOCQvZ(ekq4jrriCqW8yqEoHKfbxfDWI2qW1)9Ph3XjyRgenyWeTKeDyEEcAvCuwIfkNuoPlapbLhdYZjeSvJ(heSuoPlapbkq4jb(IWbbZJb55esweCv0blAdbljrhMNNGQyHHTAakpgKNtenyWen0jNPkwyyRgGEWqWwn6FqW((UcLtkN0fGNafi8KaKiCqW8yqEoHKfbB1O)bbd5zLItULbaWceSkenOzfcUiuGWtITr4GGTA0)GGxgaalCF2fl2j67k4)OqW8yqEoHKffi8Kauq4GGTA0)GGR)O4QWI(hempgKNtizrbkqWycU(aqwGWbHNeiCqW8yqEoHKffi8kcHdcMhdYZjKSOaHh(IWbbZJb55eswuGWdKiCqW8yqEoHKffi82gHdc2Qr)dcg7J(hempgKNtizrbcpqbHdc2Qr)dc233vOCs5KUa8eiyEmipNqYIcuGceS0Sq1)GWROssacirPIkIwuPTLAemUMy65QqWBQbb3e82uWBtd(GOjACwmr3ayVii68li6TEIZ2XhBDIwWB6oTGteT6byI2oXdybNi66YMlROK9BQ6HjAjWhe9M(rDWWErWjI2Qr)drV1Tt8olcRc6ToLSNSFtba7fbNiAqs0wn6FiAFRcfLShbJj(C7zemOs0Bw8bxJ(hIEZM3s9q2dQe9kcmf(y3UBhRdeT(a7unWXBr)tvy5yNQbQ7G8p0oOSTvjw6DyIp3EwTBZcEtSoP2T5nXTzZBPECBw8bxJ(hQQbQK9GkrV1YqIJjaHeTesvXeDrLKqQj6TIOlvcFueOq2t2dQen(8YMlRi7bvIERiAqWuIte9MWqhqZuYEYEqLO3A2cxpbNiAio)cMORpaKfeneF7rrjAqWALXcfrp)SvltaKpEI2Qr)JIO)XdcPK9wn6FuumbxFailKN9Mc0K9wn6FuumbxFailku(U8)jYERg9pkkMGRpaKffkFNDUa8ew0)q2dQen8yyQ1heTW6erdDYzor0QWcfrdX5xWeD9bGSGOH4BpkI2MerJj4Tc7JONlr3kIo9dtj7TA0)OOycU(aqwuO8DQXWuRpCQWcfzVvJ(hfftW1haYIcLVd7J(hYERg9pkkMGRpaKffkFNVVRq5KYjDb4ji7j7bvIERzlC9eCIOzPzbiKOJgGj6yXeTvJxq0TIOnPT2BqEMs2B1O)rj3oX7SiSkOj7TA0)Oku(obdDant2B1O)rvO8DvZ7Dwn6FC(wffpgalhOJ(Ar)dzVvJ(hvHY3vnV3z1O)X5Bvu8yaS86)(0J7Oi7bvIEt7baRNlrd)XMq01LjUSIS3Qr)JQq57uRM9j3NDXIDI(Uc(pQI7S8cGo5m1KMNlluoPn)lOhSY1)9Ph3HQwn7tUp7If7e9Df8Fu06Yexw5YcRg9pMh)YlIUTmLlO(Vp94ouflmSvdqfmG1Jc)3AcmyjdZZtqvSWWwnaLhdYZjzi7TA0)Oku(o1QzFY9zxSyNOVRG)JQ4olVaOtotnP552Z1HRWIf9GvwYW88euflmSvdq5XG8CsgWGHo5mvXcdB1a0dwzOtotnP55YcLtAZ)c6bJS3Qr)JQq57uRM9j3NDXIDI(Uc(pQI7S8cGo5m1KMNBpxhUclw0dwzOtotnP552Z1HRWIfvWawpQnazzjdZZtqvSWWwnaLhdYZjzadUaOtotvSWWwnavWawpQnazzOtotvSWWwna9GjdzVvJ(hvHY3577kuoPCsxaEII7SCOtotvSWWwna9Gvg6KZuflmSvdqfmG1JAd8LS3Qr)JQq57Q)O4QWI(NI7SCjR)O4QWI(h6bJS3Qr)JQq57KYjDb4jkUZYlO(Vp94ouPCsxaEcQGbSEuBCRPY1)9Ph3HkLt6cWtqRltCzLllSA0)yE8lr56)(0J74eSvdzadwYW88e0Q4OSeluoPCsxaEckpgKNtK9wn6FufkFNjnpxwOCQvZ(uXDwE9FF6XDCc2QbzVvJ(hvHY3jLt6cWtuCNLx)3NEChNGTAagSKH55jOvXrzjwOCs5KUa8euEmipNi7TA0)Oku(oFFxHYjLt6cWtuCNLlzyEEcQIfg2QbO8yqEobgm0jNPkwyyRgGEWi7TA0)Oku(oipRuCYTmaawuSkenOzL8Ii7TA0)Oku(ULbaWc3NDXIDI(Uc(pkYERg9pQcLVR(JIRcl6Fi7j7TA0)OO1)9Ph3rjp3cgY)FQ4olh6KZutAEU9CD4kSyrpyK9wn6Fu06)(0J7Oku(oflmSvduCNLx)3NEChQA1Sp5(SlwSt03vW)rrRltCzLllSA0)yE8lViYERg9pkA9FF6XDufkFNjnp3EUoCfwSkUZYHo5mvXcdB1a0dgyW1)9Ph3HQyHHTAaQGbSEuBueyWsgMNNGQyHHTAakpgKNtK9wn6Fu06)(0J7Oku(oitf9pUp789Dff3z51)9Ph3HQwn7tUp7If7e9Df8Fu06Yexw5YcRg9pMFd5Li7TA0)OO1)9Ph3rvO8DyF0)uCNLdDYzQjnp3EUoCfwSOhmYERg9pkA9FF6XDufkF3rXUoyavXDwo0jNPkwyyRgGEWadwYW88euflmSvdq5XG8CIS3Qr)JIw)3NEChvHY3DuSRdgO4Xay5xXpxLdt0aM3jSlxCNLxqb1)9Ph3HkLt6cWtqZhV3j46Yex2fnaJFqcgCbsgMNNGwfhLLyHYjLt6cWtq5XG8CQmMGL2DRjQeuPCsxaEczKPC9FF6XDOM08CzHYPwn7tubdy9OWpildDYzQIfg2QbOcgW6rHFqkdyWfaDYzQIfg2QbOcgW6rTbiLHS3Qr)JIw)3NEChvHY3DuSRdgO4Xay5aSGbDSmLlBZT4olxsOtotnP552Z1HRWIf9GvUaOtotvSWWwna9GbgSKH55jOkwyyRgGYJb55KmK9wn6Fu06)(0J7Oku(UJIDDWafpgalxy4tPZaALdQVobNCqNi(HSNS3Qr)JIc0rFTO)rUA1Sp5(SlwSt03vW)rvCNLlzyEEcQIfg2QbO8yqEov2Qr)dvTA2NCF2fl2j67k4)OO1LjUSc)fvwYcGo5m14BRCF2577kOhSYqNCMAIepHlXzEsSGEWkdDYz69yIuBJ7ZoBQnpHd09Cv0dwzOtottT09Wo1QzFIEWkdDYzk2h9p0dMmK9wn6FuuGo6Rf9pfkFhKPI(h3ND((UII7SCjdZZtqvSWWwnaLhdYZPYH55jOqMk6FCF2577kO8yqEov2Qr)dvTA2NCF2fl2j67k4)OO1LjUSAdji7TA0)OOaD0xl6Fku(oFFxH7ZUyXomXhCnErXDwEbl28XIIvJnazjzi7TA0)OOaD0xl6Fku(ULnj3NDXIDyIp4A8II7S8cwS5JffRgBaYsYq2B1O)rrb6OVw0)uO8D((Uc3NDXIDyIp4A8II7S8c6P(a9CDjdWUStIsLkvcqTXInFSOa2warjOfTTmLxS5JffRgBS92LdZZtqf9Df8FuomXhCnEbLhdYZjYERg9pkkqh91I(NcLVZ33v4(SlwSdt8bxJxuCNLxqp1hONRlza2LDsGVLkvcqTXInFSOa2warjOGImLxS5JffRgBS92K9wn6FuuGo6Rf9pfkF3YMK7ZUyXomXhCnErXDwEb9uFGEUUKbyx2bkLkvcqTXInFSOa2waXsuPsMYl28XIIvJnaLTlhMNNGk67k4)OCyIp4A8ckpgKNtK9wn6FuuGo6Rf9pfkF3YMK7ZUyXomXhCnErXDwEb9uFGEUUKbyx2j1LkvcqTXInFSOa2warjOfjt5fB(yrXQXgBVnzVvJ(hffOJ(Ar)tHY3z8TvUp789Dff3z5sgMNNGQyHHTAakpgKNtL7P(a9CDjdWUSROTlvcqH)fB(yrbSTaILOGSSKfaDYzQX3w5(SZ33vqpyGbdDYzQjs8eUeN5jXc6bdmyOtotVhtKABCF2ztT5jCGUNRIEWadg6KZ0ulDpStTA2NOhmWGHo5mf7J(h6btgYERg9pkkqh91I(NcLV7EmrQTX9zNn1MNWb6EUQI7SCjdZZtqvSWWwnaLhdYZPY9uFGEUUKbyx2v02LkbOW)InFSOa2waXsuqwwYcGo5m14BRCF2577kOhmWGHo5m1ejEcxIZ8Kyb9Gbgm0jNP3JjsTnUp7SP28eoq3ZvrpyGbdDYzAQLUh2Pwn7t0dgyWqNCMI9r)d9GjdzVvJ(hffOJ(Ar)tHY3LAP7HDQvZ(uXDwUKH55jOkwyyRgGYJb55u5W88e0CpM3PcBsuEmipNk3t9b656sgGDzxrBxQeGc)l28XIcyBbelrbzzjla6KZuJVTY9zNVVRGEWadg6KZutK4jCjoZtIf0dgyWqNCMEpMi124(SZMAZt4aDpxf9Gbgm0jNPPw6EyNA1SprpyGbdDYzk2h9p0dMmK9wn6FuuGo6Rf9pfkFNjs8eUeN5jXII7SCjdZZtqvSWWwnaLhdYZPY9uFGEUUKbyx2v02LkbOW)InFSOa2waXsuqwwYcGo5m14BRCF2577kOhmWGHo5m1ejEcxIZ8Kyb9Gbgm0jNP3JjsTnUp7SP28eoq3ZvrpyGbdDYzAQLUh2Pwn7t0dgyWqNCMI9r)d9GjdzVvJ(hffOJ(Ar)tHY35nqO7h3YMKQ4olxYW88euflmSvdq5XG8CQ8InFSOy1ydj2gbRW4kcpqbuqbkqi]] )


end
