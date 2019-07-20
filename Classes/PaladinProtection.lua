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

        potion = "potion_of_unbridled_fury",

        package = "Protection Paladin",
    } )


    spec:RegisterPack( "Protection Paladin", 20190718.2215, [[diKgQaqiOQEeiHnjrgfjPtrsSkve9kjWSKGUfjuzxi(fi1WubhdQyzsOEgijttfPRjrzBGe9njQ04ajLZjrfRtfbMNeY9ir7dQshKeQYcjP8qqsLjQIG6IQiiNKeQQvQcTtsWqjHslfKu1tbAQqL2lK)sLbtQdtzXG6XsAYICzuBwuFwLgTsoTuRMeYRHQy2u1TbSBf)wvdhklNWZjA6cxxP2ojvFxf14LOQZRIqRNekMpi2psJWbHlcmzbJuO4d4uohkxCGAKIlghOeQGkeyCIymceZQ4XUmcCmagbQyfFW1O)HQvSM3s9GaXSt0)wcHlcu(BrLrGRiWKNaOH(2XAdtQpa0Ygy7TO)PkSCaTSbQqJaH3Tpu8hemcmzbJuO4d4uohkxCGAKIlghO8q5IaTDSEbceSbG6qGRoL4bbJatSSIaHcQwXk(GRr)dvRynVL6HEekO6veyYta0qF7yTHj1haAzdS9w0)ufwoGw2avOPhHcQ(42FIunoqTcP6IpGt5q1koQU4Ipb4ug9i9iuq1qDlBUSKEekOAfhvR4LsCIQH6z4nEycc03YqIWfbc0rFTO)bHlsbCq4Ia5XG9CcPgcSk6GfTHaXNQdZZtqKSWWwnaHhd2ZjQUevB1O)Hixn7tUp7If7e9Df8VLK6Yexws14LQlMQlr14t1Qs1W7CMy8TLUp789DfKngvxIQH35mXejEcxIZ8KybzJr1LOA4DotUBtKABCF2ztT5jC4PNRKSXO6sun8oNjPw9EyNC1Spr2yuDjQgENZeSp6FiBmQwfeOvJ(heOC1Sp5(SlwSt03vW)wIcKcfJWfbYJb75esneyv0blAdbIpvhMNNGizHHTAacpgSNtuDjQomppbb2Kr)J7ZoFFxbHhd2ZjQUevB1O)Hixn7tUp7If7e9Df8VLK6Yexws1fr14GaTA0)GaHnz0)4(SZ33vGcKcqfcxeipgSNti1qGvrhSOneOQu9InFSiy1GQlIQp9avRcc0Qr)dc033v4(SlwSdt8bxJxGcKcNIWfbYJb75esneyv0blAdbQkvVyZhlcwnO6IO6tpq1QGaTA0)Gax2KCF2fl2Hj(GRXlqbsHYq4Ia5XG9CcPgcSk6GfTHavLQ7P(a9CDjdWUSdNdhoCaqs1fr1l28XIayLNQpjvJdP4YOAvO6su9InFSiy1GQlIQlRmQUevhMNNGi67k4FlDyIp4A8ccpgSNtiqRg9piqFFxH7ZUyXomXhCnEbkqkaLiCrG8yWEoHudbwfDWI2qGQs19uFGEUUKbyx2HduD4WbajvxevVyZhlcGvEQ(KunoeOKQvHQlr1l28XIGvdQUiQUSYqGwn6FqG((Uc3NDXIDyIp4A8cuGuOCr4Ia5XG9CcPgcSk6GfTHavLQ7P(a9CDjdWUSdkpC4aGKQlIQxS5JfbWkpvFsQ(aPCPAvO6su9InFSiy1GQlIQHYYO6suDyEEcIOVRG)T0Hj(GRXli8yWEoHaTA0)Gax2KCF2fl2Hj(GRXlqbsbOgcxeipgSNti1qGvrhSOneOQuDp1hONRlza2LDLZHdhaKuDru9InFSiaw5P6ts14qkMQvHQlr1l28XIGvdQUiQUSYqGwn6FqGlBsUp7If7WeFW14fOaPq5GWfbYJb75esneyv0blAdbIpvhMNNGizHHTAacpgSNtuDjQUN6d0Z1Lma7YUIl7WbajvJxQEXMpweaR8u9jP6dKtP6sun(uTQun8oNjgFBP7ZoFFxbzJr1qGq1W7CMyIepHlXzEsSGSXOAiqOA4DotUBtKABCF2ztT5jC4PNRKSXOAiqOA4DotsT69Wo5QzFISXOAiqOA4DotW(O)HSXOAvqGwn6FqGgFBP7ZoFFxbkqkGZbeUiqEmypNqQHaRIoyrBiq8P6W88eejlmSvdq4XG9CIQlr19uFGEUUKbyx2vCzhoaiPA8s1l28XIayLNQpjvFGCkvxIQXNQvLQH35mX4BlDF2577kiBmQgceQgENZetK4jCjoZtIfKngvdbcvdVZzYDBIuBJ7ZoBQnpHdp9CLKngvdbcvdVZzsQvVh2jxn7tKngvdbcvdVZzc2h9pKngvRcc0Qr)dc8UnrQTX9zNn1MNWHNEUsuGuahCq4Ia5XG9CcPgcSk6GfTHaXNQdZZtqKSWWwnaHhd2ZjQUevhMNNGK7X8ozytIWJb75evxIQ7P(a9CDjdWUSR4YoCaqs14LQxS5JfbWkpvFsQ(a5uQUevJpvRkvdVZzIX3w6(SZ33vq2yuneiun8oNjMiXt4sCMNeliBmQgceQgENZK72eP2g3ND2uBEchE65kjBmQgceQgENZKuREpStUA2NiBmQgceQgENZeSp6FiBmQwfeOvJ(heyQvVh2jxn7tOaPaofJWfbYJb75esneyv0blAdbIpvhMNNGizHHTAacpgSNtuDjQUN6d0Z1Lma7YUIl7WbajvJxQEXMpweaR8u9jP6dKtP6sun(uTQun8oNjgFBP7ZoFFxbzJr1qGq1W7CMyIepHlXzEsSGSXOAiqOA4DotUBtKABCF2ztT5jC4PNRKSXOAiqOA4DotsT69Wo5QzFISXOAiqOA4DotW(O)HSXOAvqGwn6FqGMiXt4sCMNelqbsbCGkeUiqEmypNqQHaRIoyrBiq8P6W88eejlmSvdq4XG9CIQlr1l28XIGvdQUiQgNYqGwn6FqGE7eD)4w2KKOafiW6)(0FEKiCrkGdcxeipgSNti1qGvrhSOnei8oNjM68C756olSyr2yiqRg9piWClyy))juGuOyeUiqEmypNqQHaTA0)GanfJCzct6Y)eUp7W(ZSabwfDWI2qG1)9P)8qKSWWwnarWawpsQUiLunohOAiqOA8P6W88eejlmSvdq4XG9CcbogaJanfJCzct6Y)eUp7W(ZSafifGkeUiqEmypNqQHaRIoyrBiW6)(0FEiYvZ(K7ZUyXorFxb)BjPUmXLLUSWQr)J5PA8QKQlgbA1O)bbkzHHTAauGu4ueUiqEmypNqQHaRIoyrBiq4DotKSWWwnazJr1qGq11)9P)8qKSWWwnarWawpsQUiQUyQgceQgFQomppbrYcdB1aeEmypNqGwn6FqGM68C756olSyHcKcLHWfbYJb75esneyv0blAdbw)3N(ZdrUA2NCF2fl2j67k4Flj1LjUS0Lfwn6FmpvxKsQ(aPmeOvJ(heiSjJ(h3ND((UcuGuakr4Ia5XG9CcPgcSk6GfTHaH35mXuNNBpx3zHflYgdbA1O)bbI9r)dkqkuUiCrG8yWEoHudbwfDWI2qGW7CMizHHTAaYgJQHaHQXNQdZZtqKSWWwnaHhd2ZjeOvJ(he4wYUoyajkqka1q4Ia5XG9CcPgc0Qr)dc8k(5kDyIgW8oHDzeyv0blAdbQkvRkvx)3N(Zdrr70fGNGK3EVtW1LjUSlAaMQXlvFkvdbcvRkvJpvhMNNGufBPLyH0POD6cWtq4XG9CIQlr1ycwD3TMi4qu0oDb4jOAvOAvO6suD9FF6ppetDEUSq6KRM9jIGbSEKunEP6tP6sun8oNjswyyRgGiyaRhjvJxQ(uQwfQgceQwvQgENZejlmSvdqemG1JKQlIQpLQvbbogaJaVIFUshMObmVtyxgfifkheUiqEmypNqQHaTA0)GabybJNyzsx2MlcSk6GfTHaXNQH35mXuNNBpx3zHflYgJQlr1Qs1W7CMizHHTAaYgJQHaHQXNQdZZtqKSWWwnaHhd2ZjQwfe4yamceGfmEILjDzBUOaPaohq4Ia5XG9CcPgcCmagbkmftAp4r6G7RtWjh8oIFqGwn6FqGctXK2dEKo4(6eCYbVJ4huGceyIZ22hiCrkGdcxeOvJ(heOGH34HrG8yWEoHudfifkgHlcKhd2ZjKAiqRg9piWQ59oRg9poFldeOVLHBmagbw)3N(ZJefifGkeUiqEmypNqQHaTA0)GaRM37SA0)48TmqG(wgUXayeiqh91I(huGu4ueUiqEmypNqQHaRIoyrBiqvPA4Dotm155YcPtDZ)cYgJQlr11)9P)8qKRM9j3NDXIDI(Uc(3ssDzIllDzHvJ(hZt14vjvxmPmQwfQUevRkvx)3N(ZdrYcdB1aebdy9iPA8s13AIQHaHQXNQdZZtqKSWWwnaHhd2ZjQwfeOvJ(heOC1Sp5(SlwSt03vW)wIcKcLHWfbYJb75esneyv0blAdbQkvdVZzIPop3EUUZclwKngvxIQXNQdZZtqKSWWwnaHhd2ZjQwfQgceQgENZejlmSvdq2yuDjQgENZetDEUSq6u38VGSXqGwn6FqGYvZ(K7ZUyXorFxb)BjkqkaLiCrG8yWEoHudbwfDWI2qGQs1W7CMyQZZTNR7SWIfzJr1LOA4Dotm1552Z1DwyXIiyaRhjvxevFkvxIQXNQdZZtqKSWWwnaHhd2ZjQwfQgceQwvQgENZejlmSvdqemG1JKQlIQpLQlr1W7CMizHHTAaYgJQvbbA1O)bbkxn7tUp7If7e9Df8VLOaPq5IWfbYJb75esneyv0blAdbcVZzIKfg2QbiBmQUevdVZzIKfg2QbicgW6rs1fr1qfc0Qr)dc033viDkANUa8eOaPaudHlcKhd2ZjKAiWQOdw0gceFQU(JKRcl6FiBmeOvJ(hey9hjxfw0)GcKcLdcxeipgSNti1qGvrhSOneOQuD9FF6ppefTtxaEcIGbSEKuDru9TMO6suD9FF6ppefTtxaEcsDzIllDzHvJ(hZt14LQXHQlr11)9P)84eSvdQwfQgceQgFQomppbPk2slXcPtr70fGNGWJb75ec0Qr)dcur70fGNafifW5acxeipgSNti1qGvrhSOney9FF6ppobB1abA1O)bbAQZZLfsNC1SpHcKc4GdcxeipgSNti1qGvrhSOney9FF6ppobB1GQHaHQXNQdZZtqQIT0sSq6u0oDb4ji8yWEoHaTA0)Gav0oDb4jqbsbCkgHlcKhd2ZjKAiWQOdw0gceFQomppbrYcdB1aeEmypNOAiqOA4DotKSWWwnazJHaTA0)Ga99DfsNI2PlapbkqkGduHWfbYJb75esneOvJ(heiSNLso5wgaalqGYq04HLiqOcfifW5ueUiqRg9piWLbaWc3NDXIDI(Uc(3seipgSNti1qbsbCkdHlc0Qr)dcS(JKRcl6FqG8yWEoHudfOabIj46daBbcxKc4GWfbYJb75esnuGuOyeUiqEmypNqQHcKcqfcxeipgSNti1qbsHtr4Ia5XG9CcPgkqkugcxeOvJ(hei2h9piqEmypNqQHcKcqjcxeOvJ(heOVVRq6u0oDb4jqG8yWEoHudfOafiq1zHS)bPqXhWPCouU4um5WHtldbE2etpxjcuXha7fbNO6tPARg9puTVLHKqpIaLyCfPaucLiqmXNBpJaHcQwXk(GRr)dvRynVL6HEekO6veyYta0qF7yTHj1haAzdS9w0)ufwoGw2avOPhHcQ(42FIunoqTcP6IpGt5q1koQU4Ipb4ug9i9iuq1qDlBUSKEekOAfhvR4LsCIQH6z4nEyc9i9iuq1NqLNR7GtunmNFbt11ha2cQgMV9ijuTIxTYyHKQNFuCltaK3EQ2Qr)JKQ)XFIe6rRg9pscMGRpaSfkZEtIh6rRg9pscMGRpaSffOe68)j6rRg9pscMGRpaSffOeABFb4jSO)HEekOAWXWKRpOAH1jQgENZCIQLHfsQgMZVGP66daBbvdZ3EKuTnjQgtWkoSpIEUuDlP60pmHE0Qr)JKGj46daBrbkHwogMC9HtgwiPhTA0)ijycU(aWwuGsOX(O)HE0Qr)JKGj46daBrbkH233viDkANUa8e0J0JqbvFcvEUUdor1S6S4eP6ObyQowmvB14fuDlPAtDR9gSNj0Jwn6FKkfm8gpm9OvJ(hzbkHUAEVZQr)JZ3YOWXayL1)9P)8iPhTA0)ilqj0vZ7Dwn6FC(wgfogaReOJ(Ar)d9iuq1NWBaSEUun4hq9uDDzIllPhTA0)ilqj0YvZ(K7ZUyXorFxb)BzHDwPQW7CMyQZZLfsN6M)fKnwP6)(0FEiYvZ(K7ZUyXorFxb)BjPUmXLLUSWQr)J5XRYIjLPsjvR)7t)5HizHHTAaIGbSEK49wtqGGFyEEcIKfg2Qbi8yWEoPc9OvJ(hzbkHwUA2NCF2fl2j67k4FllSZkvfENZetDEU9CDNfwSiBSs4hMNNGizHHTAacpgSNtQabc8oNjswyyRgGSXkbVZzIPopxwiDQB(xq2y0Jwn6FKfOeA5QzFY9zxSyNOVRG)TSWoRuv4Dotm1552Z1DwyXISXkbVZzIPop3EUUZclwebdy9il60s4hMNNGizHHTAacpgSNtQabIQW7CMizHHTAaIGbSEKfDAj4DotKSWWwnazJPc9OvJ(hzbkH233viDkANUa8ef2zLW7CMizHHTAaYgRe8oNjswyyRgGiyaRhzrqf9OvJ(hzbkHU(JKRcl6FkSZkXV(JKRcl6FiBm6rRg9pYcucTI2PlaprHDwPQ1)9P)8qu0oDb4jicgW6rw0TMkv)3N(Zdrr70fGNGuxM4Ysxwy1O)X84fNs1)9P)84eSvdvGab)W88eKQylTelKofTtxaEccpgSNt0Jwn6FKfOeAtDEUSq6KRM9Pc7SY6)(0FECc2Qb9OvJ(hzbkHwr70fGNOWoRS(Vp9NhNGTAabc(H55jivXwAjwiDkANUa8eeEmypNOhTA0)ilqj0((UcPtr70fGNOWoRe)W88eejlmSvdq4XG9Ccce4DotKSWWwnazJrpA1O)rwGsOH9SuYj3YaayrHYq04HLkHk6rRg9pYcuc9YaayH7ZUyXorFxb)Bj9OvJ(hzbkHU(JKRcl6FOhPhTA0)ij1)9P)8ivMBbd7)pvyNvcVZzIPop3EUUZclwKng9OvJ(hjP(Vp9NhzbkHElzxhmqHJbWknfJCzct6Y)eUp7W(ZSOWoRS(Vp9NhIKfg2QbicgW6rwKsCoabc(H55jiswyyRgGWJb75e9OvJ(hjP(Vp9NhzbkHwYcdB1af2zL1)9P)8qKRM9j3NDXIDI(Uc(3ssDzIllDzHvJ(hZJxLftpA1O)rsQ)7t)5rwGsOn1552Z1DwyXQWoReENZejlmSvdq2yqGu)3N(ZdrYcdB1aebdy9ilQyiqWpmppbrYcdB1aeEmypNOhTA0)ij1)9P)8ilqj0WMm6FCF2577kkSZkR)7t)5Hixn7tUp7If7e9Df8VLK6Yexw6YcRg9pMViLhiLrpA1O)rsQ)7t)5rwGsOX(O)PWoReENZetDEU9CDNfwSiBm6rRg9pss9FF6ppYcuc9wYUoyazHDwj8oNjswyyRgGSXGab)W88eejlmSvdq4XG9CIE0Qr)JKu)3N(ZJSaLqVLSRdgOWXayLxXpxPdt0aM3jSlxyNvQQQ1)9P)8qu0oDb4ji5T37eCDzIl7IgGX7PqGOk(H55jivXwAjwiDkANUa8eeEmypNkHjy1D3AIGdrr70fGNqfvkv)3N(ZdXuNNllKo5QzFIiyaRhjEpTe8oNjswyyRgGiyaRhjEpvfiqufENZejlmSvdqemG1JSOtvHE0Qr)JKu)3N(ZJSaLqVLSRdgOWXayLaSGXtSmPlBZTWoReF4Dotm1552Z1DwyXISXkPk8oNjswyyRgGSXGab)W88eejlmSvdq4XG9Csf6rRg9pss9FF6ppYcuc9wYUoyGchdGvkmftAp4r6G7RtWjh8oIFOhPhTA0)ijaD0xl6Fukxn7tUp7If7e9Df8VLf2zL4hMNNGizHHTAacpgSNtLSA0)qKRM9j3NDXIDI(Uc(3ssDzIllXBXLWxv4Dotm(2s3ND((UcYgRe8oNjMiXt4sCMNeliBSsW7CMC3Mi124(SZMAZt4WtpxjzJvcENZKuREpStUA2NiBSsW7CMG9r)dzJPc9OvJ(hjbOJ(Ar)tbkHg2Kr)J7ZoFFxrHDwj(H55jiswyyRgGWJb75uPW88eeytg9pUp789DfeEmypNkz1O)Hixn7tUp7If7e9Df8VLK6Yexwweo0Jwn6FKeGo6Rf9pfOeAFFxH7ZUyXomXhCnErHDwPQl28XIGvJIo9Gk0Jwn6FKeGo6Rf9pfOe6Lnj3NDXIDyIp4A8Ic7SsvxS5JfbRgfD6bvOhTA0)ijaD0xl6Fkqj0((Uc3NDXIDyIp4A8Ic7Ssv7P(a9CDjdWUSdNdhoCaqw0InFSiaw5pjoKIltLsl28XIGvJIkRSsH55jiI(Uc(3shM4dUgVGWJb75e9OvJ(hjbOJ(Ar)tbkH233v4(SlwSdt8bxJxuyNvQAp1hONRlza2LD4avhoCaqw0InFSiaw5pjoeOuLsl28XIGvJIkRm6rRg9pscqh91I(Ncuc9YMK7ZUyXomXhCnErHDwPQ9uFGEUUKbyx2bLhoCaqw0InFSiaw5p5bs5QsPfB(yrWQrrqzzLcZZtqe9Df8VLomXhCnEbHhd2Zj6rRg9pscqh91I(Ncuc9YMK7ZUyXomXhCnErHDwPQ9uFGEUUKbyx2vohoCaqw0InFSiaw5pjoKIvP0InFSiy1OOYkJE0Qr)JKa0rFTO)PaLqB8TLUp789Dff2zL4hMNNGizHHTAacpgSNtL6P(a9CDjdWUSR4YoCaqI3fB(yraSYFYdKtlHVQW7CMy8TLUp789DfKngeiW7CMyIepHlXzEsSGSXGabENZK72eP2g3ND2uBEchE65kjBmiqG35mj1Q3d7KRM9jYgdce4DotW(O)HSXuHE0Qr)JKa0rFTO)PaLqF3Mi124(SZMAZt4WtpxzHDwj(H55jiswyyRgGWJb75uPEQpqpxxYaSl7kUSdhaK4DXMpweaR8N8a50s4Rk8oNjgFBP7ZoFFxbzJbbc8oNjMiXt4sCMNeliBmiqG35m5UnrQTX9zNn1MNWHNEUsYgdce4DotsT69Wo5QzFISXGabENZeSp6FiBmvOhTA0)ijaD0xl6Fkqj0Pw9EyNC1SpvyNvIFyEEcIKfg2Qbi8yWEovkmppbj3J5DYWMeHhd2ZPs9uFGEUUKbyx2vCzhoaiX7InFSiaw5p5bYPLWxv4Dotm(2s3ND((UcYgdce4DotmrINWL4mpjwq2yqGaVZzYDBIuBJ7ZoBQnpHdp9CLKngeiW7CMKA17HDYvZ(ezJbbc8oNjyF0)q2yQqpA1O)rsa6OVw0)uGsOnrINWL4mpjwuyNvIFyEEcIKfg2Qbi8yWEovQN6d0Z1Lma7YUIl7WbajExS5JfbWk)jpqoTe(QcVZzIX3w6(SZ33vq2yqGaVZzIjs8eUeN5jXcYgdce4DotUBtKABCF2ztT5jC4PNRKSXGabENZKuREpStUA2NiBmiqG35mb7J(hYgtf6rRg9pscqh91I(NcucT3or3pULnjzHDwj(H55jiswyyRgGWJb75uPfB(yrWQrr4ugkqbcba]] )


end
