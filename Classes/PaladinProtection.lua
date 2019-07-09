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


    spec:RegisterPack( "Protection Paladin", 20190709.1545, [[dieIPaqiOQEeiP2KKYOisofrPvPcQxjjAwssDlqcTle)sf1WKuDmIOLPI4zeHmnvKUMKW2aj5BssY4KKGZbs06KKuMNkW9iQ2hrWbjcflKO4HeHktussvxKiu1jLKuzLQq7eQYqLKOLkjHEkqtfKAVq(lvgmPomLfdQhlQjlYLrTzj(SknALCAPwnuPEnujZMQUnGDR43QA4qz5eEojtx46k12js9DOIXRcY5bjy9eHsZhe7hPrsIGgbMSGr4DsDjHY6vvDOKijuvVEfvbeyafWyeiMLXLDze4yamcSkfFW5O)HQRsZBPEqGyguW)wcbncu9BrMrGRiWuvTZNVDS2WK8dCw1aBVf9pzHvIZQgiFg2)WNHlgumXsFgt8L2ZQZvPGRIwNuNRYQORknVL6XvLIp4C0)qunqgbcVBFu1niyeyYcgH3j1LekRxv1HsIKqv96NwfqG2owVabc2asCiWvNs8GGrGjwLrGqnvxLIp4C0)q1vP5Tup0JqnvVIatv1oF(2XAdtYpWzvdS9w0)KfwjoRAG8z6rOMQpU9qbQgkRMQpPUKqjvdfPAjROQvrf0J0JqnvlXTS5Yk6rOMQHIuTetkXjQUkYWBCXeeOVvHcbnceOJ(Ar)dcAeEsIGgbYJb75esgeyw0blAdbIpvhMNNGOyHHTAacpgSNtuDnQ2Yr)drTA2NCFXfl2j67k4FRi5LjUSIQLavFcvxJQXNQLIQH3LcX4BRCFX577kiBmQUgvdVlfIjs8eUex4jXcYgJQRr1W7sHC3Mi124(IZMCZt4WvpxfzJr11OA4DPqsT09Wo1QzFISXO6Aun8UuiyF0)q2yuTSiqlh9piq1QzFY9fxSyNOVRG)Tcfi8obbncKhd2ZjKmiWSOdw0gceFQomppbrXcdB1aeEmypNO6AuDyEEccSPI(h3xC((UccpgSNtuDnQ2Yr)drTA2NCFXfl2j67k4FRi5LjUSIQpGQLebA5O)bbcBQO)X9fNVVRafi8Kie0iqEmypNqYGaZIoyrBiqPO6fB(yrWYbvFavFADQwweOLJ(heOVVRW9fxSyhM4dohVafi8ofbncKhd2ZjKmiWSOdw0gcukQEXMpweSCq1hq1NwNQLfbA5O)bbUSj5(IlwSdt8bNJxGceEvGGgbYJb75esgeyw0blAdbkfv3t(b656sgGDzNK1RxVoGIQpGQxS5JfbWoevFyQwsYjvq1Ys11O6fB(yrWYbvFavxrfuDnQomppbr03vW)w5WeFW54feEmypNqGwo6FqG((Uc3xCXIDyIp4C8cuGWdQqqJa5XG9Ccjdcml6GfTHaLIQ7j)a9CDjdWUStsjQE96akQ(aQEXMpwea7qu9HPAjjqfvllvxJQxS5Jfblhu9buDfvGaTC0)Ga99DfUV4If7WeFW54fOaHxvHGgbYJb75esgeyw0blAdbkfv3t(b656sgGDzhuvVEDafvFavVyZhlcGDiQ(WuDDsvr1Ys11O6fB(yrWYbvFavdvvq11O6W88eerFxb)BLdt8bNJxq4XG9CcbA5O)bbUSj5(IlwSdt8bNJxGceEvbe0iqEmypNqYGaZIoyrBiqPO6EYpqpxxYaSl7GY61RdOO6dO6fB(yraSdr1hMQLKCcvllvxJQxS5Jfblhu9buDfvGaTC0)Gax2KCFXfl2Hj(GZXlqbcpOebncKhd2ZjKmiWSOdw0gceFQomppbrXcdB1aeEmypNO6AuDp5hONRlza2LDNur96akQwcu9InFSia2HO6dt11jNs11OA8PAPOA4DPqm(2k3xC((UcYgJQHaHQH3LcXejEcxIl8KybzJr1qGq1W7sHC3Mi124(IZMCZt4WvpxfzJr1qGq1W7sHKAP7HDQvZ(ezJr1qGq1W7sHG9r)dzJr1YIaTC0)Gan(2k3xC((UcuGWtY6iOrG8yWEoHKbbMfDWI2qG4t1H55jikwyyRgGWJb75evxJQ7j)a9CDjdWUS7KkQxhqr1sGQxS5JfbWoevFyQUo5uQUgvJpvlfvdVlfIX3w5(IZ33vq2yuneiun8UuiMiXt4sCHNeliBmQgceQgExkK72eP2g3xC2KBEchU65QiBmQgceQgExkKulDpStTA2NiBmQgceQgExkeSp6FiBmQwweOLJ(he4DBIuBJ7loBYnpHdx9CvOaHNKsIGgbYJb75esgeyw0blAdbIpvhMNNGOyHHTAacpgSNtuDnQomppbP0J5DQWMeHhd2ZjQUgv3t(b656sgGDz3jvuVoGIQLavVyZhlcGDiQ(WuDDYPuDnQgFQwkQgExkeJVTY9fNVVRGSXOAiqOA4DPqmrINWL4cpjwq2yuneiun8Uui3TjsTnUV4Sj38eoC1Zvr2yuneiun8UuiPw6EyNA1Spr2yuneiun8UuiyF0)q2yuTSiqlh9piWulDpStTA2NqbcpjpbbncKhd2ZjKmiWSOdw0gceFQomppbrXcdB1aeEmypNO6AuDp5hONRlza2LDNur96akQwcu9InFSia2HO6dt11jNs11OA8PAPOA4DPqm(2k3xC((UcYgJQHaHQH3LcXejEcxIl8KybzJr1qGq1W7sHC3Mi124(IZMCZt4WvpxfzJr1qGq1W7sHKAP7HDQvZ(ezJr1qGq1W7sHG9r)dzJr1YIaTC0)GanrINWL4cpjwGceEskriOrG8yWEoHKbbMfDWI2qG4t1H55jikwyyRgGWJb75evxJQxS5Jfblhu9buTKvGaTC0)Ga9guW9JBztsHcuGaZ)7tpoJcbncpjrqJa5XG9Ccjdcml6GfTHaH3LcXKMNBpxhoclwKngc0Yr)dcS0cg2)Fcfi8obbncKhd2ZjKmiWSOdw0gcm)Vp94me1QzFY9fxSyNOVRG)TIKxM4Ykxry5O)X8uTeKt1NGaTC0)GavSWWwnakq4jriOrG8yWEoHKbbMfDWI2qGW7sHOyHHTAaYgJQHaHQZ)7tpodrXcdB1aebdy9OO6dO6tOAiqOA8P6W88eeflmSvdq4XG9CcbA5O)bbAsZZTNRdhHfluGW7ue0iqEmypNqYGaZIoyrBiW8)(0JZquRM9j3xCXIDI(Uc(3ksEzIlRCfHLJ(hZt1hiNQRtQabA5O)bbcBQO)X9fNVVRafi8QabncKhd2ZjKmiWSOdw0gceExketAEU9CD4iSyr2yiqlh9piqSp6FqbcpOcbncKhd2ZjKmiWSOdw0gceExkeflmSvdq2yuneiun(uDyEEcIIfg2Qbi8yWEoHaTC0)Ga3k21bdOqbcVQcbncKhd2ZjKmiqlh9piWR4NRYHjAaZ7e2LrGzrhSOneOuuTuuD(FF6Xzi4ENUa8eKY27DcoVmXLDrdWuTeO6tPAiqOAPOA8P6W88eKSyRSeluoCVtxaEccpgSNtuDnQgtWs7U5erscU3PlapbvllvllvxJQZ)7tpodXKMNlluo1QzFIiyaRhfvlbQ(uQUgvdVlfIIfg2QbicgW6rr1sGQpLQLLQHaHQLIQH3LcrXcdB1aebdy9OO6dO6tPAzrGJbWiWR4NRYHjAaZ7e2LrbcVQacAeipgSNtizqGwo6FqGaSGXvSmLRyZfbMfDWI2qG4t1W7sHysZZTNRdhHflYgJQRr1sr1W7sHOyHHTAaYgJQHaHQXNQdZZtquSWWwnaHhd2ZjQwwe4yamceGfmUILPCfBUOaHhuIGgbYJb75esge4yamcuysSP9GlLdUVobNCW7i(bbA5O)bbkmj20EWLYb3xNGto4De)GcuGatCX2(abncpjrqJaTC0)Gafm8gxmcKhd2ZjKmOaH3jiOrG8yWEoHKbbA5O)bbMnV3z5O)X5BvGa9TkCJbWiW8)(0JZOqbcpjcbncKhd2ZjKmiqlh9piWS59olh9poFRceOVvHBmagbc0rFTO)bfi8ofbncKhd2ZjKmiWSOdw0gcukQgExketAEUSq5K28VGSXO6AuD(FF6XziQvZ(K7lUyXorFxb)BfjVmXLvUIWYr)J5PAjiNQpHubvllvxJQLIQZ)7tpodrXcdB1aebdy9OOAjq13CIQHaHQXNQdZZtquSWWwnaHhd2ZjQwweOLJ(heOA1Sp5(IlwSt03vW)wHceEvGGgbYJb75esgeyw0blAdbkfvdVlfIjnp3EUoCewSiBmQUgvJpvhMNNGOyHHTAacpgSNtuTSuneiun8UuikwyyRgGSXO6Aun8UuiM08CzHYjT5FbzJHaTC0)GavRM9j3xCXIDI(Uc(3kuGWdQqqJa5XG9Ccjdcml6GfTHaLIQH3LcXKMNBpxhoclwKngvxJQH3LcXKMNBpxhoclwebdy9OO6dO6tP6Aun(uDyEEcIIfg2Qbi8yWEor1Ys1qGq1sr1W7sHOyHHTAaIGbSEuu9bu9PuDnQgExkeflmSvdq2yuTSiqlh9piq1QzFY9fxSyNOVRG)Tcfi8Qke0iqEmypNqYGaZIoyrBiq4DPquSWWwnazJr11OA4DPquSWWwnarWawpkQ(aQwIqGwo6FqG((UcLd370fGNafi8QciOrG8yWEoHKbbMfDWI2qG4t15FuCwyr)dzJHaTC0)GaZ)O4SWI(huGWdkrqJa5XG9Ccjdcml6GfTHaLIQZ)7tpodb370fGNGiyaRhfvFavFZjQUgvN)3NECgcU3PlapbjVmXLvUIWYr)J5PAjq1ss11O68)(0JZ4eSLdQwwQgceQgFQomppbjl2klXcLd370fGNGWJb75ec0Yr)dce370fGNafi8KSocAeipgSNtizqGzrhSOney(FF6XzCc2Ybc0Yr)dc0KMNlluo1QzFcfi8Kuse0iqEmypNqYGaZIoyrBiW8)(0JZ4eSLdQgceQgFQomppbjl2klXcLd370fGNGWJb75ec0Yr)dce370fGNafi8K8ee0iqEmypNqYGaZIoyrBiq8P6W88eeflmSvdq4XG9CIQHaHQH3LcrXcdB1aKngc0Yr)dc033vOC4ENUa8eOaHNKsecAeipgSNtizqGwo6FqGWEwP4KBzaaSabQcrJlwHaLiuGWtYtrqJaTC0)GaxgaalCFXfl2j67k4FRqG8yWEoHKbfi8KSce0iqlh9piW8pkolSO)bbYJb75esguGceiMGZpaSfiOr4jjcAeipgSNtizqbcVtqqJa5XG9Ccjdkq4jriOrG8yWEoHKbfi8ofbncKhd2ZjKmOaHxfiOrGwo6FqGyF0)Ga5XG9Ccjdkq4bviOrGwo6FqG5FuCwyr)dcKhd2ZjKmOaHxvHGgbA5O)bb677kuoCVtxaEceipgSNtizqbkqbcuAwO6Fq4DsDjHY6NizvrQx)KQcbIJjMEUkeyvha2lcor1Ns1wo6FOAFRcfHEebIj(s7zeiut1vP4doh9puDvAEl1d9iut1RiWuvTZNVDS2WK8dCw1aBVf9pzHvIZQgiFMEeQP6JBpuGQHYQP6tQljus1qrQwYkQAvub9i9iut1sClBUSIEeQPAOivlXKsCIQRIm8gxmHEKEeQPAj(dX5DWjQgMlVGP68daBbvdZ3EueQwIjNzSqr1ZpqXLjakBpvB5O)rr1)4Hce6rlh9pkcMGZpaSfYlEtHl6rlh9pkcMGZpaSfvk)C5)e9OLJ(hfbtW5ha2IkLF22xaEcl6FOhHAQgCmm16dQwyDIQH3LcNOAvyHIQH5YlyQo)aWwq1W8ThfvBtIQXemue7JONlv3kQo9dtOhTC0)Oiyco)aWwuP8ZQXWuRpCQWcf9OLJ(hfbtW5ha2IkLFg7J(h6rlh9pkcMGZpaSfvk)C(hfNfw0)qpA5O)rrWeC(bGTOs5N99DfkhU3Plapb9i9iut1s8hIZ7GtunlnlGcuD0amvhlMQTC8cQUvuTjT1Ed2Ze6rlh9pk5cgEJlME0Yr)JQs5NZM37SC0)48TkQEmawE(FF6Xzu0Jwo6Fuvk)C28ENLJ(hNVvr1JbWYb6OVw0)qpc1uDv)gaRNlvd(rvKQZltCzf9OLJ(hvLYpRwn7tUV4If7e9Df8Vvv3f5sbVlfIjnpxwOCsB(xq2y1Y)7tpodrTA2NCFXfl2j67k4FRi5LjUSYvewo6FmVeKFcPczRjv(FF6XzikwyyRgGiyaRhLeU5eei4hMNNGOyHHTAacpgSNtYspA5O)rvP8ZQvZ(K7lUyXorFxb)Bv1DrUuW7sHysZZTNRdhHflYgRg(H55jikwyyRgGWJb75KSqGaVlfIIfg2QbiBSAW7sHysZZLfkN0M)fKng9OLJ(hvLYpRwn7tUV4If7e9Df8Vvv3f5sbVlfIjnp3EUoCewSiBSAW7sHysZZTNRdhHflIGbSEuhCAn8dZZtquSWWwnaHhd2ZjzHark4DPquSWWwnarWawpQdoTg8UuikwyyRgGSXKLE0Yr)JQs5N99DfkhU3Plapr1Dro8UuikwyyRgGSXQbVlfIIfg2QbicgW6rDGerpA5O)rvP8Z5FuCwyr)t1Dro(5FuCwyr)dzJrpA5O)rvP8Z4ENUa8ev3f5sL)3NECgcU3PlapbrWawpQdU5uT8)(0JZqW9oDb4ji5LjUSYvewo6FmVeKSw(FF6XzCc2YHSqGGFyEEcswSvwIfkhU3PlapbHhd2Zj6rlh9pQkLF2KMNlluo1QzFQ6Uip)Vp94mobB5GE0Yr)JQs5NX9oDb4jQUlYZ)7tpoJtWwoGab)W88eKSyRSeluoCVtxaEccpgSNt0Jwo6Fuvk)SVVRq5W9oDb4jQUlYXpmppbrXcdB1aeEmypNGabExkeflmSvdq2y0Jwo6Fuvk)mSNvko5wgaalQwfIgxSsUerpA5O)rvP8ZldaGfUV4If7e9Df8Vv0Jwo6Fuvk)C(hfNfw0)qpspA5O)rrY)7tpoJsEPfmS))u1Dro8UuiM08C756WryXISXOhTC0)Oi5)9PhNrvP8ZkwyyRgO6Uip)Vp94me1QzFY9fxSyNOVRG)TIKxM4Ykxry5O)X8sq(j0Jwo6FuK8)(0JZOQu(ztAEU9CD4iSyvDxKdVlfIIfg2QbiBmiqY)7tpodrXcdB1aebdy9Oo4eiqWpmppbrXcdB1aeEmypNOhTC0)Oi5)9PhNrvP8ZWMk6FCFX577kQUlYZ)7tpodrTA2NCFXfl2j67k4FRi5LjUSYvewo6Fm)bYRtQGE0Yr)JIK)3NECgvLYpJ9r)t1Dro8UuiM08C756WryXISXOhTC0)Oi5)9PhNrvP8ZBf76Gbuv3f5W7sHOyHHTAaYgdce8dZZtquSWWwnaHhd2Zj6rlh9pks(FF6Xzuvk)8wXUoyGQhdGLFf)CvomrdyENWUC1DrUusL)3NECgcU3PlapbPS9ENGZltCzx0aSeofcePWpmppbjl2klXcLd370fGNGWJb75unmblT7Mtejj4ENUa8eYkBT8)(0JZqmP55YcLtTA2NicgW6rjHtRbVlfIIfg2QbicgW6rjHtLfcePG3LcrXcdB1aebdy9Oo4uzPhTC0)Oi5)9PhNrvP8ZBf76GbQEmawoalyCflt5k2CRUlYXhExketAEU9CD4iSyr2y1KcExkeflmSvdq2yqGGFyEEcIIfg2Qbi8yWEojl9OLJ(hfj)Vp94mQkLFERyxhmq1JbWYfMeBAp4s5G7RtWjh8oIFOhPhTC0)OiaD0xl6FKRwn7tUV4If7e9Df8Vvv3f54hMNNGOyHHTAacpgSNt1SC0)quRM9j3xCXIDI(Uc(3ksEzIlRKWj1Wxk4DPqm(2k3xC((UcYgRg8UuiMiXt4sCHNeliBSAW7sHC3Mi124(IZMCZt4WvpxfzJvdExkKulDpStTA2NiBSAW7sHG9r)dzJjl9OLJ(hfbOJ(Ar)tLYpdBQO)X9fNVVRO6Uih)W88eeflmSvdq4XG9CQwyEEccSPI(h3xC((UccpgSNt1SC0)quRM9j3xCXIDI(Uc(3ksEzIlRoqs6rlh9pkcqh91I(NkLF233v4(IlwSdt8bNJxuDxKl1InFSiy54GtRll9OLJ(hfbOJ(Ar)tLYpVSj5(IlwSdt8bNJxuDxKl1InFSiy54GtRll9OLJ(hfbOJ(Ar)tLYp777kCFXfl2Hj(GZXlQUlYLQN8d0Z1Lma7YojRxVEDa1bl28XIayh6WssoPczRTyZhlcwooOIkQfMNNGi67k4FRCyIp4C8ccpgSNt0Jwo6FueGo6Rf9pvk)SVVRW9fxSyhM4dohVO6UixQEYpqpxxYaSl7KuIQxVoG6GfB(yraSdDyjjqLS1wS5Jfblhhurf0Jwo6FueGo6Rf9pvk)8YMK7lUyXomXhCoEr1DrUu9KFGEUUKbyx2bv1RxhqDWInFSia2HoCDsvjBTfB(yrWYXbqvf1cZZtqe9Df8VvomXhCoEbHhd2Zj6rlh9pkcqh91I(NkLFEztY9fxSyhM4dohVO6UixQEYpqpxxYaSl7GY61RdOoyXMpwea7qhwsYjYwBXMpweSCCqfvqpA5O)rra6OVw0)uP8ZgFBL7loFFxr1Dro(H55jikwyyRgGWJb75uTEYpqpxxYaSl7oPI61busyXMpwea7qhUo50A4lf8UuigFBL7loFFxbzJbbc8UuiMiXt4sCHNeliBmiqG3Lc5UnrQTX9fNn5MNWHREUkYgdce4DPqsT09Wo1QzFISXGabExkeSp6FiBmzPhTC0)OiaD0xl6FQu(572eP2g3xC2KBEchU65QQUlYXpmppbrXcdB1aeEmypNQ1t(b656sgGDz3jvuVoGscl28XIayh6W1jNwdFPG3LcX4BRCFX577kiBmiqG3LcXejEcxIl8KybzJbbc8Uui3TjsTnUV4Sj38eoC1Zvr2yqGaVlfsQLUh2Pwn7tKngeiW7sHG9r)dzJjl9OLJ(hfbOJ(Ar)tLYpNAP7HDQvZ(u1Dro(H55jikwyyRgGWJb75uTW88eKspM3PcBseEmypNQ1t(b656sgGDz3jvuVoGscl28XIayh6W1jNwdFPG3LcX4BRCFX577kiBmiqG3LcXejEcxIl8KybzJbbc8Uui3TjsTnUV4Sj38eoC1Zvr2yqGaVlfsQLUh2Pwn7tKngeiW7sHG9r)dzJjl9OLJ(hfbOJ(Ar)tLYpBIepHlXfEsSO6Uih)W88eeflmSvdq4XG9CQwp5hONRlza2LDNur96akjSyZhlcGDOdxNCAn8LcExkeJVTY9fNVVRGSXGabExketK4jCjUWtIfKngeiW7sHC3Mi124(IZMCZt4WvpxfzJbbc8UuiPw6EyNA1Spr2yqGaVlfc2h9pKnMS0Jwo6FueGo6Rf9pvk)S3GcUFClBsQQ7IC8dZZtquSWWwnaHhd2ZPAl28XIGLJdKSceOcJZi8GkOcfOaHa]] )


end
