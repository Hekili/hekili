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
            cooldown = function () return ( essence.vision_of_perfection.enabled and 0.87 or 1 ) * 120 end,
            gcd = "spell",

            toggle = "cooldowns",

            startsCombat = false,
            texture = 135875,

            handler = function ()
                applyBuff( "avenging_wrath" )
                applyBuff( "avenging_wrath_crit" )
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

            readyTime = function () return debuff.forbearance.remains end,

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

            readyTime = function () return debuff.forbearance.remains end,

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

            spend = 0.06,
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

            readyTime = function () return debuff.forbearance.remains end,

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
                if PTR and buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
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

            readyTime = function () return debuff.forbearance.remains end,

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
                if PTR and buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
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

            spend = 0.06,
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


    spec:RegisterPack( "Protection Paladin", 20190712.0045, [[diuNQaqiOkpcKsBss1OiP6uKuwLku9kjHzjj6wGu0Uq8lvudts6yqvTmvipdKQMMkORjP02aPY3uHIXPcaNdQuTovOK5jP4EKO9rc1bHkfwijXdHkfnrvOuDrvOuoPkaALQi7KemuvaTuva6PanvOI9c5VuzWK6WuwmOESetwKlJAZI6ZQ0OvYPLA1KqEnujZMQUnGDR43QA4qz5eEortx46k12jj9DqY4vb68Guy9qLsZhe7hPr4JWbbMSGrkCuv8X9Qhd(hrQw9qOdFOhbgqdmgbIzfCzxgbogaJapqXhCj6FO6d08wQheiMbn8VLq4GaL)wuye4kcm5X685BhRnmP8aNLnW2Br)try54SSbkNH9p8z4SbntSQNXeFU9S88bk4dO1j55d8a6oqZBPEChO4dUe9pezduqGW72hhGdcgbMSGrkCuv8X9Qhd(hrQw9qORkUJaTDSEbceSbWnrGRoL4bbJatSSGaHwQ(afFWLO)HQpqZBPEONGwQEfbM8yD(8TJ1gMuEGZYgy7TO)PiSCCw2aLZ0tqlvFA7Hgun(hvjvFuv8XDQgAs1vRESoSw6j6jOLQXnx2Czj9e0s1qtQg3iL4evFaz4nUycc03YqIWbbc0rFTO)bHdsb8r4Ga5XG9CcPccSi6GfTHaXJQdZZtqKSWWwnaHhd2ZjQUovBLO)Hixn7tUp7If7e9Df8VLKYYexws1kMQpIQRt14r1Qt1W7CMy8TLUp789DfKngvxNQH35mXejEcxIZ8KybzJr11PA4DotUBtKABCF2ztP5jC4QNRKSXO66un8oNjPw1EyNC1Spr2yuDDQgENZeSp6FiBmQwneOvI(heOC1Sp5(SlwSt03vW)wIcKchHWbbYJb75esfeyr0blAdbIhvhMNNGizHHTAacpgSNtuDDQomppbb2Kr)J7ZoFFxbHhd2ZjQUovBLO)Hixn7tUp7If7e9Df8VLKYYexws11q14JaTs0)GaHnz0)4(SZ33vGcKcqpcheipgSNtivqGfrhSOneO6u9InFSiyLGQRHQpSkvRgc0kr)dc033v4(SlwSdt8bxIxGcKchIWbbYJb75esfeyr0blAdbQovVyZhlcwjO6AO6dRs1QHaTs0)Gax2KCF2fl2Hj(GlXlqbsHAr4Ga5XG9CcPccSi6GfTHavNQ7P8a9CDjdWUSd)QvRwfqs11q1l28XIayhKQpovJp5OAPA1O66u9InFSiyLGQRHQRTwQUovhMNNGi67k4FlDyIp4s8ccpgSNtiqRe9piqFFxH7ZUyXomXhCjEbkqkaDiCqG8yWEoHubbweDWI2qGQt19uEGEUUKbyx2Hp0xTAvajvxdvVyZhlcGDqQ(4un(eOJQvJQRt1l28XIGvcQUgQU2ArGwj6FqG((Uc3NDXIDyIp4s8cuGu4yq4Ga5XG9CcPccSi6GfTHavNQ7P8a9CDjdWUSd6QwTkGKQRHQxS5JfbWoivFCQUk5yOA1O66u9InFSiyLGQRHQHUAP66uDyEEcIOVRG)T0Hj(GlXli8yWEoHaTs0)Gax2KCF2fl2Hj(GlXlqbsHdaeoiqEmypNqQGalIoyrBiq1P6EkpqpxxYaSl7W9QvRciP6AO6fB(yraSds1hNQXNCevRgvxNQxS5JfbReuDnuDT1IaTs0)Gax2KCF2fl2Hj(GlXlqbsbChHdcKhd2ZjKkiWIOdw0gcepQomppbrYcdB1aeEmypNO66uDpLhONRlza2LDhvB1QasQwXu9InFSia2bP6Jt1vjhs11PA8OA1PA4Dotm(2s3ND((UcYgJQHaHQH35mXejEcxIZ8KybzJr1qGq1W7CMC3Mi124(SZMsZt4WvpxjzJr1qGq1W7CMKAv7HDYvZ(ezJr1qGq1W7CMG9r)dzJr1QHaTs0)Gan(2s3ND((UcuGua)QiCqG8yWEoHubbweDWI2qG4r1H55jiswyyRgGWJb75evxNQ7P8a9CDjdWUS7OARwfqs1kMQxS5JfbWoivFCQUk5qQUovJhvRovdVZzIX3w6(SZ33vq2yuneiun8oNjMiXt4sCMNeliBmQgceQgENZK72eP2g3ND2uAEchU65kjBmQgceQgENZKuRApStUA2NiBmQgceQgENZeSp6FiBmQwneOvI(he4DBIuBJ7ZoBknpHdx9CLOaPa(4JWbbYJb75esfeyr0blAdbIhvhMNNGizHHTAacpgSNtuDDQomppbj3J5DYWMeHhd2ZjQUov3t5b656sgGDz3r1wTkGKQvmvVyZhlcGDqQ(4uDvYHuDDQgpQwDQgENZeJVT09zNVVRGSXOAiqOA4DotmrINWL4mpjwq2yuneiun8oNj3TjsTnUp7SP08eoC1Zvs2yuneiun8oNjPw1EyNC1Spr2yuneiun8oNjyF0)q2yuTAiqRe9piWuRApStUA2Nqbsb8pcHdcKhd2ZjKkiWIOdw0gcepQomppbrYcdB1aeEmypNO66uDpLhONRlza2LDhvB1QasQwXu9InFSia2bP6Jt1vjhs11PA8OA1PA4Dotm(2s3ND((UcYgJQHaHQH35mXejEcxIZ8KybzJr1qGq1W7CMC3Mi124(SZMsZt4WvpxjzJr1qGq1W7CMKAv7HDYvZ(ezJr1qGq1W7CMG9r)dzJr1QHaTs0)GanrINWL4mpjwGcKc4d9iCqG8yWEoHubbweDWI2qG4r1H55jiswyyRgGWJb75evxNQxS5JfbReuDnun(1IaTs0)Ga9g0W9JBztsIcuGal)7tpuJeHdsb8r4Ga5XG9CcPccSi6GfTHaH35mXuLNBpxhuclwKngc0kr)dcm3cg2)FcfifocHdcKhd2ZjKkiqRe9piqd3kxMWKU8pH7ZoShkwGalIoyrBiWY)(0d1qKSWWwnarWawpsQUgLun(vPAiqOA8O6W88eejlmSvdq4XG9CcbogaJanCRCzct6Y)eUp7WEOybkqka9iCqG8yWEoHubbweDWI2qGL)9PhQHixn7tUp7If7e9Df8VLKYYexw6YcRe9pMNQvSsQ(ieOvI(heOKfg2QbqbsHdr4Ga5XG9CcPccSi6GfTHaH35mrYcdB1aKngvdbcvx(3NEOgIKfg2QbicgW6rs11q1hr1qGq14r1H55jiswyyRgGWJb75ec0kr)dc0uLNBpxhuclwOaPqTiCqG8yWEoHubbweDWI2qGL)9PhQHixn7tUp7If7e9Df8VLKYYexw6YcRe9pMNQRrjvxLulc0kr)dce2Kr)J7ZoFFxbkqkaDiCqG8yWEoHubbweDWI2qGW7CMyQYZTNRdkHflYgdbALO)bbI9r)dkqkCmiCqG8yWEoHubbweDWI2qGW7CMizHHTAaYgJQHaHQXJQdZZtqKSWWwnaHhd2ZjeOvI(he4wYUoyajkqkCaGWbbYJb75esfeOvI(he4v8Zv6WenG5Dc7YiWIOdw0gcuDQwDQU8Vp9qnefTtxaEcsE79obxwM4YUObyQwXu9HuneiuT6unEuDyEEcsrSLwIfsNI2PlapbHhd2ZjQUovJjyvD3sIGprr70fGNGQvJQvJQRt1L)9PhQHyQYZLfsNC1SpremG1JKQvmvFivxNQH35mrYcdB1aebdy9iPAft1hs1Qr1qGq1Qt1W7CMizHHTAaIGbSEKuDnu9HuTAiWXaye4v8Zv6WenG5Dc7YOaPaUJWbbYJb75esfeOvI(heialyCflt6Y2CrGfrhSOneiEun8oNjMQ8C756GsyXISXO66uT6un8oNjswyyRgGSXOAiqOA8O6W88eejlmSvdq4XG9CIQvdbogaJabybJRyzsx2MlkqkGFveoiqEmypNqQGahdGrGcd3M2dUKo4(6eCYbVJ4heOvI(heOWWTP9GlPdUVobNCW7i(bfOabM4ST9bchKc4JWbbALO)bbky4nUyeipgSNtivqbsHJq4Ga5XG9CcPcc0kr)dcSyEVZkr)JZ3Yab6Bz4gdGrGL)9PhQrIcKcqpcheipgSNtivqGwj6FqGfZ7Dwj6FC(wgiqFld3yamceOJ(Ar)dkqkCicheipgSNtivqGfrhSOneO6un8oNjMQ8CzH0PQ5FbzJr11P6Y)(0d1qKRM9j3NDXIDI(Uc(3sszzIllDzHvI(hZt1kwjvFePwQwnQUovRovx(3NEOgIKfg2QbicgW6rs1kMQVLevdbcvJhvhMNNGizHHTAacpgSNtuTAiqRe9piq5QzFY9zxSyNOVRG)TefifQfHdcKhd2ZjKkiWIOdw0gcuDQgENZetvEU9CDqjSyr2yuDDQgpQomppbrYcdB1aeEmypNOA1OAiqOA4DotKSWWwnazJr11PA4Dotmv55YcPtvZ)cYgdbALO)bbkxn7tUp7If7e9Df8VLOaPa0HWbbYJb75esfeyr0blAdbQovdVZzIPkp3EUoOewSiBmQUovdVZzIPkp3EUoOewSicgW6rs11q1hs11PA8O6W88eejlmSvdq4XG9CIQvJQHaHQvNQH35mrYcdB1aebdy9iP6AO6dP66un8oNjswyyRgGSXOA1qGwj6FqGYvZ(K7ZUyXorFxb)BjkqkCmiCqG8yWEoHubbweDWI2qGW7CMizHHTAaYgJQRt1W7CMizHHTAaIGbSEKuDnun0JaTs0)Ga99DfsNI2PlapbkqkCaGWbbYJb75esfeyr0blAdbIhvx(rYfHf9pKngc0kr)dcS8JKlcl6FqbsbChHdcKhd2ZjKkiWIOdw0gcuDQU8Vp9qnefTtxaEcIGbSEKuDnu9TKO66uD5FF6HAikANUa8eKYYexw6YcRe9pMNQvmvJpvxNQl)7tpuJtWwjOA1OAiqOA8O6W88eKIylTelKofTtxaEccpgSNtiqRe9piqfTtxaEcuGua)QiCqG8yWEoHubbweDWI2qGL)9PhQXjyReiqRe9piqtvEUSq6KRM9juGuaF8r4Ga5XG9CcPccSi6GfTHal)7tpuJtWwjOAiqOA8O6W88eKIylTelKofTtxaEccpgSNtiqRe9piqfTtxaEcuGua)Jq4Ga5XG9CcPccSi6GfTHaXJQdZZtqKSWWwnaHhd2ZjQgceQgENZejlmSvdq2yiqRe9piqFFxH0POD6cWtGcKc4d9iCqG8yWEoHubbALO)bbc7zPKtULbaWceOmenUyjce6rbsb8peHdc0kr)dcCzaaSW9zxSyNOVRG)TebYJb75esfuGua)Ar4GaTs0)Gal)i5IWI(heipgSNtivqbkqGycU8aWwGWbPa(iCqG8yWEoHubfifocHdcKhd2ZjKkOaPa0JWbbYJb75esfuGu4qeoiqEmypNqQGcKc1IWbbALO)bbI9r)dcKhd2ZjKkOaPa0HWbbALO)bbw(rYfHf9piqEmypNqQGcKchdcheOvI(heOVVRq6u0oDb4jqG8yWEoHubfOafiqvzHS)bPWrvXh3REmvXDc(1EyTiqOmX0ZvIapabWErWjQ(qQ2kr)dv7Bzij0tiqmXNBpJaHwQ(afFWLO)HQpqZBPEONGwQEfbM8yD(8TJ1gMuEGZYgy7TO)PiSCCw2aLZ0tqlvFA7Hgun(hvjvFuv8XDQgAs1vRESoSw6j6jOLQXnx2Czj9e0s1qtQg3iL4evFaz4nUyc9e9e0s1hBhKl7GtunmNFbt1Lha2cQgMV9ijunUrPWyHKQNFGMltaK3EQ2kr)JKQ)Xdni0twj6FKembxEayluM9Mex0twj6FKembxEaylQq558)j6jRe9pscMGlpaSfvO8STVa8ew0)qpbTun4yyY1huTW6evdVZzor1YWcjvdZ5xWuD5bGTGQH5BpsQ2MevJjyOj2hrpxQULuD6hMqpzLO)rsWeC5bGTOcLNLJHjxF4KHfs6jRe9pscMGlpaSfvO8m2h9p0twj6FKembxEaylQq55YpsUiSO)HEYkr)JKGj4YdaBrfkp777kKofTtxaEc6j6jOLQp2oix2bNOAwvwanO6ObyQowmvBL4fuDlPAtvR9gSNj0twj6FKkfm8gxm9KvI(hzfkpxmV3zLO)X5Bzu5yaSYY)(0d1iPNSs0)iRq55I59oRe9poFlJkhdGvc0rFTO)HEcAP6J9nawpxQg8JdivxwM4Ys6jRe9pYkuEwUA2NCF2fl2j67k4FlRSZkvhENZetvEUSq6u18VGSXQx(3NEOgIC1Sp5(SlwSt03vW)wskltCzPllSs0)yEfR8isTQvx9Y)(0d1qKSWWwnarWawpsfFljiqWlmppbrYcdB1aeEmypNuJEYkr)JScLNLRM9j3NDXIDI(Uc(3Yk7Ss1H35mXuLNBpxhuclwKnwD8cZZtqKSWWwnaHhd2Zj1GabENZejlmSvdq2y1H35mXuLNllKovn)liBm6jRe9pYkuEwUA2NCF2fl2j67k4FlRSZkvhENZetvEU9CDqjSyr2y1H35mXuLNBpxhuclwebdy9iR5W64fMNNGizHHTAacpgSNtQbbI6W7CMizHHTAaIGbSEK1CyD4DotKSWWwnazJPg9KvI(hzfkp777kKofTtxaEIk7Ss4DotKSWWwnazJvhENZejlmSvdqemG1JSgONEYkr)JScLNl)i5IWI(Nk7Ss8k)i5IWI(hYgJEYkr)JScLNv0oDb4jQSZkvV8Vp9qnefTtxaEcIGbSEK1ClP6L)9PhQHOOD6cWtqkltCzPllSs0)yEfJF9Y)(0d14eSvc1GabVW88eKIylTelKofTtxaEccpgSNt0twj6FKvO8SPkpxwiDYvZ(uLDwz5FF6HACc2kb9KvI(hzfkpROD6cWtuzNvw(3NEOgNGTsabcEH55jifXwAjwiDkANUa8eeEmypNONSs0)iRq5zFFxH0POD6cWtuzNvIxyEEcIKfg2Qbi8yWEobbc8oNjswyyRgGSXONSs0)iRq5zyplLCYTmaawuPmenUyPsONEYkr)JScLNxgaalCF2fl2j67k4FlPNSs0)iRq55YpsUiSO)HEIEYkr)JKu(3NEOgPYClyy))Pk7Ss4Dotmv552Z1bLWIfzJrpzLO)rsk)7tpuJScLN3s21bdu5yaSsd3kxMWKU8pH7ZoShkwuzNvw(3NEOgIKfg2QbicgW6rwJs8RcbcEH55jiswyyRgGWJb75e9KvI(hjP8Vp9qnYkuEwYcdB1av2zLL)9PhQHixn7tUp7If7e9Df8VLKYYexw6YcRe9pMxXkpIEYkr)JKu(3NEOgzfkpBQYZTNRdkHfRk7Ss4DotKSWWwnazJbbs5FF6HAiswyyRgGiyaRhznhbbcEH55jiswyyRgGWJb75e9KvI(hjP8Vp9qnYkuEg2Kr)J7ZoFFxrLDwz5FF6HAiYvZ(K7ZUyXorFxb)BjPSmXLLUSWkr)J5RrzvsT0twj6FKKY)(0d1iRq5zSp6FQSZkH35mXuLNBpxhuclwKng9KvI(hjP8Vp9qnYkuEElzxhmGSYoReENZejlmSvdq2yqGGxyEEcIKfg2Qbi8yWEorpzLO)rsk)7tpuJScLN3s21bdu5yaSYR4NR0HjAaZ7e2LRSZkvx9Y)(0d1qu0oDb4ji5T37eCzzIl7IgGv8HqGOoEH55jifXwAjwiDkANUa8eeEmypNQJjyvD3sIGprr70fGNqn1Qx(3NEOgIPkpxwiDYvZ(erWawpsfFyD4DotKSWWwnarWawpsfFOAqGOo8oNjswyyRgGiyaRhznhQg9KvI(hjP8Vp9qnYkuEElzxhmqLJbWkbybJRyzsx2MBLDwjEW7CMyQYZTNRdkHflYgRU6W7CMizHHTAaYgdce8cZZtqKSWWwnaHhd2Zj1ONSs0)ijL)9PhQrwHYZBj76GbQCmawPWWTP9GlPdUVobNCW7i(HEIEYkr)JKa0rFTO)rPC1Sp5(SlwSt03vW)wwzNvIxyEEcIKfg2Qbi8yWEov3kr)drUA2NCF2fl2j67k4FljLLjUSuXhvhp1H35mX4BlDF2577kiBS6W7CMyIepHlXzEsSGSXQdVZzYDBIuBJ7ZoBknpHdx9CLKnwD4DotsTQ9Wo5QzFISXQdVZzc2h9pKnMA0twj6FKeGo6Rf9pvO8mSjJ(h3ND((UIk7Ss8cZZtqKSWWwnaHhd2ZP6H55jiWMm6FCF2577ki8yWEov3kr)drUA2NCF2fl2j67k4FljLLjUSSg8PNSs0)ijaD0xl6FQq5zFFxH7ZUyXomXhCjErLDwP6l28XIGvIAoSQA0twj6FKeGo6Rf9pvO88YMK7ZUyXomXhCjErLDwP6l28XIGvIAoSQA0twj6FKeGo6Rf9pvO8SVVRW9zxSyhM4dUeVOYoRu9EkpqpxxYaSl7WVA1QvbK1SyZhlcGDWJJp5OAvR(InFSiyLOMARTEyEEcIOVRG)T0Hj(GlXli8yWEorpzLO)rsa6OVw0)uHYZ((Uc3NDXIDyIp4s8Ik7Ss17P8a9CDjdWUSdFOVA1QaYAwS5JfbWo4XXNaDQvFXMpweSsutT1spzLO)rsa6OVw0)uHYZlBsUp7If7WeFWL4fv2zLQ3t5b656sgGDzh0vTAvaznl28XIayh84vjhJA1xS5JfbRe1aD1wpmppbr03vW)w6WeFWL4feEmypNONSs0)ijaD0xl6FQq55Lnj3NDXIDyIp4s8Ik7Ss17P8a9CDjdWUSd3RwTkGSMfB(yraSdEC8jhPw9fB(yrWkrn1wl9KvI(hjbOJ(Ar)tfkpB8TLUp789Dfv2zL4fMNNGizHHTAacpgSNt17P8a9CDjdWUS7OARwfqQ4fB(yraSdE8QKdRJN6W7CMy8TLUp789DfKngeiW7CMyIepHlXzEsSGSXGabENZK72eP2g3ND2uAEchU65kjBmiqG35mj1Q2d7KRM9jYgdce4DotW(O)HSXuJEYkr)JKa0rFTO)PcLNVBtKABCF2ztP5jC4QNRSYoReVW88eejlmSvdq4XG9CQEpLhONRlza2LDhvB1QasfVyZhlcGDWJxLCyD8uhENZeJVT09zNVVRGSXGabENZetK4jCjoZtIfKngeiW7CMC3Mi124(SZMsZt4WvpxjzJbbc8oNjPw1EyNC1Spr2yqGaVZzc2h9pKnMA0twj6FKeGo6Rf9pvO8CQvTh2jxn7tv2zL4fMNNGizHHTAacpgSNt1dZZtqY9yENmSjr4XG9CQEpLhONRlza2LDhvB1QasfVyZhlcGDWJxLCyD8uhENZeJVT09zNVVRGSXGabENZetK4jCjoZtIfKngeiW7CMC3Mi124(SZMsZt4WvpxjzJbbc8oNjPw1EyNC1Spr2yqGaVZzc2h9pKnMA0twj6FKeGo6Rf9pvO8Sjs8eUeN5jXIk7Ss8cZZtqKSWWwnaHhd2ZP69uEGEUUKbyx2DuTvRciv8InFSia2bpEvYH1XtD4Dotm(2s3ND((UcYgdce4DotmrINWL4mpjwq2yqGaVZzYDBIuBJ7ZoBknpHdx9CLKngeiW7CMKAv7HDYvZ(ezJbbc8oNjyF0)q2yQrpzLO)rsa6OVw0)uHYZEdA4(XTSjjRSZkXlmppbrYcdB1aeEmypNQVyZhlcwjQb)ArGsmUGua6GouGceca]] )


end
