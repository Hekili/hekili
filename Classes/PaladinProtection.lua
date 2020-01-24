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
                if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
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
                if buff.avenging_wrath_crit.up then removeBuff( "avenging_wrath_crit" ) end
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


    spec:RegisterPack( "Protection Paladin", 20190925, [[dieTUaqiuspcLk2KKYOiPCksuRca1RKeMLKOBjPIAxq9la1WubhJeSmjv9mucMgaCnjP2gkH(gaIXHsLCojvyDOuPAEssUhjzFOeDqjvelKKQhIsvPjIsLsxusfPtIsLIvQcTtsOHIsv1srPQ4Panvuk7fYFj1GPYHPSyq9yQAYsCzKnl4ZGmALCAPwna51auZwOBRs7wXVv1WrXYr1ZjA6IUUsTDsKVdiJxsLopasRhLQmFv0(jmsbeBiWILesX6pOqDCOoQhayfyxaGfpupcmbOmecKX8a2Gie4yxcbY(5Fs(S)r4y)w0k9GazmaA8TcIneO83CpHaxzYiz3bgyOoxByS)Val77oAz)JNBHeyzF9aJaH3Dmz3miyeyXscPy9huOoouh1daScSlauTc1JaTDUEoceSVSViWvxk0GGrGfs6rGSJWX(5Fs(S)r4y)w0k9ioYoc3ktgj7oWad15AdJ9)fyzF3rl7F8ClKal7RhyXr2r4ajMKUWex4QV6kfU6pOqDiokoYoch77YgiskoYocxDw4QtkfQiCSpe8gWegbgBzkrSHaVD2qw2)GydPOci2qG0yWrQGuhb65Ds82qGSkCPfPjXsIBmR(IPXGJur4QjCMp7FWYvtXI(d6CrAEdTs63sSFzCiskCSu4Qx4QjCSkCQjCW7qaBeul1FqhBOvI3mcxnHdEhcyJxOj1fkqtH44nJWvt4G3HagAB8sBJ(dAB8nnPgW9ajXBgHRMWbVdbCPvQhslxnfl4nJWvt4G3HaM5Z(h8Mr4ugbA(S)bbkxnfl6pOZfP5n0kPFlrjsX6rSHaPXGJubPoc0Z7K4THazv4slstILe3yw9ftJbhPIWvt4slstIHnz2)O)Go2qRetJbhPIWvt4mF2)GLRMIf9h05I08gAL0VLy)Y4qKu4Qs4uabA(S)bbcBYS)r)bDSHwjkrkYci2qG0yWrQGuhb65Ds82qGQjClYI5cZ4tHRkHdaheoLrGMp7FqGXgAL6pOZfPz4Fs(85OePiaqSHaPXGJubPoc0Z7K4THavt4wKfZfMXNcxvchaoiCkJanF2)Gax2u0FqNlsZW)K85ZrjsXQrSHaPXGJubPoc0Z7K4THavt46X)3EG0f7AqKwHdhoC4kfUQeUfzXCHVwDfoaw4uaxF1cNYcxnHBrwmxygFkCvjCvxTWvt4slstI5n0kPFl1m8pjF(CmngCKkiqZN9piWydTs9h05I0m8pjF(CuIuKfrSHaPXGJubPoc0Z7K4THavt46X)3EG0f7AqKwbw4WHdxPWvLWTilMl81QRWbWcNcywu4uw4QjClYI5cZ4tHRkHR6QrGMp7FqGXgAL6pOZfPz4Fs(85OePiabXgcKgdosfK6iqpVtI3gcunHRh)F7bsxSRbrAw8WHdxPWvLWTilMl81QRWbWc3bmar4uw4QjClYI5cZ4tHRkHJfRw4QjCPfPjX8gAL0VLAg(NKpFoMgdosfeO5Z(he4YMI(d6CrAg(NKpFokrkYUqSHaPXGJubPoc0Z7K4THavt46X)3EG0f7AqKUooC4WvkCvjClYI5cFT6kCaSWPaUEHtzHRMWTilMlmJpfUQeUQRgbA(S)bbUSPO)GoxKMH)j5ZNJsKI1bIneingCKki1rGEENeVneiRcxArAsSK4gZQVyAm4iveUAcxp()2dKUyxdI01x9HdxPWXsHBrwmx4RvxHdGfUdyaiC1eowfo1eo4DiGncQL6pOJn0kXBgH78u4G3Ha24fAsDHc0uioEZiCNNch8oeWqBJxAB0FqBJVPj1aUhijEZiCNNch8oeWLwPEiTC1uSG3mc35PWbVdbmZN9p4nJWPmc08z)dc0iOwQ)Go2qReLifv4aIneingCKki1rGEENeVneiRcxArAsSK4gZQVyAm4iveUAcxp()2dKUyxdI01x9HdxPWXsHBrwmx4RvxHdGfUdyaiC1eowfo1eo4DiGncQL6pOJn0kXBgH78u4G3Ha24fAsDHc0uioEZiCNNch8oeWqBJxAB0FqBJVPj1aUhijEZiCNNch8oeWLwPEiTC1uSG3mc35PWbVdbmZN9p4nJWPmc08z)dceAB8sBJ(dAB8nnPgW9ajrjsrfuaXgcKgdosfK6iqpVtI3gcKvHlTinjwsCJz1xmngCKkcxnHlTinjo0Jf1Y0McMgdosfHRMW1J)V9aPl21GiD9vF4WvkCSu4wKfZf(A1v4ayH7agacxnHJvHtnHdEhcyJGAP(d6ydTs8Mr4opfo4DiGnEHMuxOanfIJ3mc35PWbVdbm024L2g9h024BAsnG7bsI3mc35PWbVdbCPvQhslxnfl4nJWDEkCW7qaZ8z)dEZiCkJanF2)GalTs9qA5QPybLifvOEeBiqAm4ivqQJa98ojEBiqwfU0I0KyjXnMvFX0yWrQiC1eUE8)ThiDXUgePRV6dhUsHJLc3ISyUWxRUchalChWaq4QjCSkCQjCW7qaBeul1FqhBOvI3mc35PWbVdbSXl0K6cfOPqC8Mr4opfo4DiGH2gV02O)G2gFttQbCpqs8Mr4opfo4DiGlTs9qA5QPybVzeUZtHdEhcyMp7FWBgHtzeO5Z(heOXl0K6cfOPqCuIuubwaXgcKgdosfK6iqpVtI3gcKvHlTinjwsCJz1xmngCKkcxnHBrwmxygFkCvjCkunc08z)dcmAau9p6Lnfjkrjc0)FS8anseBifvaXgcKgdosfK6iqpVtI3gceEhcytjAG6bsde3YfEZGanF2)GadnNGJ)xqjsX6rSHaPXGJubPoc08z)dc0yp5Y4Muh(j1FqZ8arCeON3jXBdb6)pwEGgSK4gZQVyoDTEKcxvQeofoiCNNchRcxArAsSK4gZQVyAm4ivqGJDjeOXEYLXnPo8tQ)GM5bI4OePilGydbsJbhPcsDeO5Z(heOjxkzdj1CJ9EU2)ClIa98ojEBiq1eUcbVdbm3yVNR9p3I6cbVdbSmnpGfowkCaeHRMWbVdbSPenq9aPbIB5cVzeoLfUZtHRqW7qaZn275A)ZTOUqW7qaltZdyHtLWDabo2LqGMCPKnKuZn275A)ZTikrkcaeBiqAm4ivqQJa98ojEBiq))XYd0GLRMIf9h05I08gAL0VLy)Y4qKuh4Mp7FSOWXsvcx9iqZN9piqjXnMvFrjsXQrSHaPXGJubPoc0Z7K4THaH3HawsCJz1x8Mr4opfo))XYd0GLe3yw9fZPR1Ju4Qs4Qx4opfowfU0I0KyjXnMvFX0yWrQGanF2)GanLObQhinqClxOePilIydbsJbhPcsDeON3jXBdb6)pwEGgSC1uSO)GoxKM3qRK(Te7xghIK6a38z)JffUQujChWvJanF2)GaHnz2)O)Go2qReLifbii2qG0yWrQGuhb65Ds82qGW7qaBkrdupqAG4wUWBgeO5Z(heiZN9pOePi7cXgcKgdosfK6iqpVtI3gceEhcyjXnMvFXBgH78u4yv4slstILe3yw9ftJbhPcc08z)dcCljDN0vIsKI1bIneingCKki1rGMp7FqGq8FGKAgEFTOMBqec0Z7K4THavt4ut48)hlpqdgq7c0LMeh2XOMt(LXHiD2xs4yPWbaH78u4ut4yv4slstI98T0kexQb0UaDPjX0yWrQiC1eogoPKgYxWkGb0UaDPjfoLfoLfUAcN))y5bAWMs0arCPwUAkwWC6A9ifowkCaq4QjCW7qaljUXS6lMtxRhPWXsHdacNYc35PWPMWbVdbSK4gZQVyoDTEKcxvchaeoLrGJDjeie)hiPMH3xlQ5geHsKIkCaXgcKgdosfK6iqZN9piWlXjaNltQd2aHa98ojEBiqwfo4DiGnLObQhinqClx4nJWvt4ut4G3HawsCJz1x8Mr4opfowfU0I0KyjXnMvFX0yWrQiCkJah7siWlXjaNltQd2aHsKIkOaIneingCKki1rGJDjei3yVYEaSud3qAov0W7m)bbA(S)bbYn2RShal1WnKMtfn8oZFqjkrGfky7yIydPOci2qGMp7FqGCcEdycbsJbhPcsDuIuSEeBiqAm4ivqQJanF2)Ga9wmQnF2)OJTmrGXwM6XUec0)FS8ansuIuKfqSHaPXGJubPoc08z)dc0BXO28z)Jo2YebgBzQh7siWBNnKL9pOePiaqSHaPXGJubPoc0Z7K4THavt4G3Ha2uIgiIl1kzXNJ3mcxnHZ)FS8any5QPyr)bDUinVHwj9Bj2Vmoej1bU5Z(hlkCSuLWvpUAHtzHRMWPMW5)pwEGgSK4gZQVyoDTEKchlfoiFr4opfowfU0I0KyjXnMvFX0yWrQiCkJanF2)GaLRMIf9h05I08gAL0VLOePy1i2qG0yWrQGuhb65Ds82qGQjCW7qaBkrdupqAG4wUWBgHRMWXQWLwKMeljUXS6lMgdosfHtzH78u4G3HawsCJz1x8Mr4QjCW7qaBkrdeXLALS4ZXBgeO5Z(heOC1uSO)GoxKM3qRK(TeLifzreBiqAm4ivqQJa98ojEBiq1eo4DiGnLObQhinqClx4nJWvt4G3Ha2uIgOEG0aXTCH5016rkCvjCaq4QjCSkCPfPjXsIBmR(IPXGJur4uw4opfo1eo4DiGLe3yw9fZPR1Ju4Qs4aGWvt4G3HawsCJz1x8Mr4ugbA(S)bbkxnfl6pOZfP5n0kPFlrjsracIneingCKki1rGEENeVnei8oeWsIBmR(I3mcxnHdEhcyjXnMvFXC6A9ifUQeowabA(S)bbgBOvk1aAxGU0KOePi7cXgcKgdosfK6iqpVtI3gcKvHZ)JK8Cl7FWBgeO5Z(heO)hj55w2)GsKI1bIneingCKki1rGEENeVneOAcN))y5bAWaAxGU0KyoDTEKcxvchKViC1eo))XYd0Gb0UaDPjX(LXHiPoWnF2)yrHJLcNccxnHZ)FS8anAoz(u4uw4opfowfU0I0KypFlTcXLAaTlqxAsmngCKkiqZN9piqaTlqxAsuIuuHdi2qG0yWrQGuhb65Ds82qG()JLhOrZjZNiqZN9piqtjAGiUulxnflOePOckGydbsJbhPcsDeON3jXBdb6)pwEGgnNmFkCNNchRcxArAsSNVLwH4snG2fOlnjMgdosfeO5Z(heiG2fOlnjkrkQq9i2qG0yWrQGuhb65Ds82qGQjCSkCPfPjXsIBmR(IPXGJur4opfo4DiGLe3yw9fVzeoLfUAchRcx5tS)hpnj3sQOdr7sA4nFWC6A9ifowkCheUZtHJKsA8eoxK2Z3(gos6pOdr7syUnaw4Qs4ybeO5Z(heO)hpnj3sQOdr7sOePOcSaIneingCKki1rGEENeVneiRcxArAsSK4gZQVyAm4iveUZtHdEhcyjXnMvFXBgeO5Z(heySHwPudODb6stIsKIkaaeBiqZN9piqB6RP)GUqwUqG0yWrQGuhLifvOAeBiqAm4ivqQJanF2)GaHJKusf9YUxIJaLjVbmjrGSakrkQalIydbA(S)bbUS7L46pOZfP5n0kPFlrG0yWrQGuhLifvaGGydbA(S)bb6)rsEUL9piqAm4ivqQJsKIkWUqSHaPXGJubPoc0Z7K4THazv4ut4iPKgpHZfP98TVHJK(d6q0Ue(Aa65c35PWrsjnEcd0ZJfLOE0Cs(JnEcFna9CH78u4iPKgpHTPVM(d6yhiTnfDHSCHVgGEUWDEkCKusJNWx6(CaQ(d6423fDHt2vIVgGEUWPmc08z)dcCrgp1KusJNqjkrGmCY)xylrSHuubeBiqAm4ivqQJsKI1JydbsJbhPcsDuIuKfqSHaPXGJubPokrkcaeBiqAm4ivqQJsKIvJydbA(S)bbY8z)dcKgdosfK6OePilIydbA(S)bbgBOvk1aAxGU0KiqAm4ivqQJsuIseOsex2)GuS(dkuhhyxkCaxF9vxnceiJp9ajrGSBUmppPIWbaHZ8z)JWfBzkXIJiqjd5rkYISicKH)Hosiq2r4y)8pjF2)iCSFlALEehzhHBLjJKDhyGH6CTHX()cSSV7OL9pEUfsGL91dS4i7iCGetsxyIlC1xDLcx9huOoehfhzhHJ9DzdejfhzhHRolC1jLcveo2hcEdyclokoYocxDADj)oPIWbtHNtcN)VWwkCWeupsSWvN49etkfU5N68Y43WokCMp7FKc3prakwC08z)JeZWj)FHTuviAsaloA(S)rIz4K)VWwwHkGd)xehnF2)iXmCY)xylRqfW2g6stAz)J4i7iCGJXixFkCCRlch8oeOIWjtlLchmfEojC()cBPWbtq9ifoBkchdNQZmFM9ajCTu4k)qyXrZN9psmdN8)f2YkubSCmg56tTmTukoA(S)rIz4K)VWwwHkGz(S)rC08z)JeZWj)FHTScvahBOvk1aAxGU0KIJIJSJWvNwxYVtQiCKsehGkCzFjHlxKWz(85cxlfotjRJgCKWIJMp7FKQ4e8gWK4O5Z(hzfQa2BXO28z)Jo2YSYXUKk))XYd0ifhnF2)iRqfWElg1Mp7F0XwMvo2LuD7SHSS)rCKDeo2T7ltpqch4NSpcNFzCiskoA(S)rwHkGLRMIf9h05I08gAL0VLv2bvQbVdbSPenqexQvYIphVzQ5)pwEGgSC1uSO)GoxKM3qRK(Te7xghIK6a38z)JfzPQ6XvRCn18)hlpqdwsCJz1xmNUwpswc5lNNSMwKMeljUXS6lMgdosfLfhnF2)iRqfWYvtXI(d6CrAEdTs63Yk7Gk1G3Ha2uIgOEG0aXTCH3m1ynTinjwsCJz1xmngCKkkFEcVdbSK4gZQV4ntn4DiGnLObI4sTsw854nJ4O5Z(hzfQawUAkw0FqNlsZBOvs)wwzhuPg8oeWMs0a1dKgiULl8MPg8oeWMs0a1dKgiULlmNUwpYQaqnwtlstILe3yw9ftJbhPIYNNQbVdbSK4gZQVyoDTEKvbGAW7qaljUXS6lEZOS4O5Z(hzfQao2qRuQb0UaDPjRSdQG3HawsCJz1x8MPg8oeWsIBmR(I5016rwflioA(S)rwHkG9)ijp3Y(Nk7Gkw9)ijp3Y(h8MrC08z)JScvadODb6stwzhuPM))y5bAWaAxGU0KyoDTEKvb5l18)hlpqdgq7c0LMe7xghIK6a38z)JfzPc18)hlpqJMtMpv(8K10I0KypFlTcXLAaTlqxAsmngCKkIJMp7FKvOcytjAGiUulxnflv2bv()JLhOrZjZNIJMp7FKvOcyaTlqxAYk7Gk))XYd0O5K5ZZtwtlstI98T0kexQb0UaDPjX0yWrQioA(S)rwHkG9)4Pj5wsfDiAxQYoOsnwtlstILe3yw9ftJbhPY5j8oeWsIBmR(I3mkxJ1YNy)pEAsULurhI2L0WB(G5016rYYdNNKusJNW5I0E(23Wrs)bDiAxcZTbWvXcIJMp7FKvOc4ydTsPgq7c0LMSYoOI10I0KyjXnMvFX0yWrQCEcVdbSK4gZQV4nJ4O5Z(hzfQa2M(A6pOlKLlXrZN9pYkubmCKKsQOx29s8kLjVbmjvXcIJMp7FKvOc4LDVex)bDUinVHwj9BP4O5Z(hzfQa2)JK8Cl7FehnF2)iRqfWlY4PMKsA8uLDqfRQrsjnEcNls75BFdhj9h0HODj81a0ZppjPKgpHb65XIsupAoj)XgpHVgGE(5jjL04jSn910Fqh7aPTPOlKLl81a0ZppjPKgpHV095au9h0XTVl6cNSReFna9CLfhfhnF2)iX()JLhOrQk0Cco(FPYoOcEhcytjAG6bsde3YfEZioA(S)rI9)hlpqJScvaVLKUt6w5yxsLXEYLXnPo8tQ)GM5bI4v2bv()JLhObljUXS6lMtxRhzvQu4W5jRPfPjXsIBmR(IPXGJurC08z)Je7)pwEGgzfQaEljDN0TYXUKktUuYgsQ5g79CT)5wSYoOsTcbVdbm3yVNR9p3I6cbVdbSmnpGzjaPg8oeWMs0a1dKgiULl8Mr5ZZcbVdbm3yVNR9p3I6cbVdbSmnpGvDqC08z)Je7)pwEGgzfQawsCJz13k7Gk))XYd0GLRMIf9h05I08gAL0VLy)Y4qKuh4Mp7FSilvvV4O5Z(hj2)FS8anYkubSPenq9aPbIB5QYoOcEhcyjXnMvFXBMZt))XYd0GLe3yw9fZPR1JSQ6ppznTinjwsCJz1xmngCKkIJMp7FKy))XYd0iRqfWWMm7F0FqhBOvwzhu5)pwEGgSC1uSO)GoxKM3qRK(Te7xghIK6a38z)JfRs1bC1IJMp7FKy))XYd0iRqfWmF2)uzhubVdbSPenq9aPbIB5cVzehnF2)iX()JLhOrwHkG3ss3jDLv2bvW7qaljUXS6lEZCEYAArAsSK4gZQVyAm4ivehnF2)iX()JLhOrwHkG3ss3jDRCSlPcI)dKuZW7Rf1CdIQSdQutn))XYd0Gb0UaDPjXHDmQ5KFzCisN9LyjaopvJ10I0KypFlTcXLAaTlqxAsmngCKk1y4KsAiFbRagq7c0LMuzLR5)pwEGgSPenqexQLRMIfmNUwpswcGAW7qaljUXS6lMtxRhjlbGYNNQbVdbSK4gZQVyoDTEKvbaLfhnF2)iX()JLhOrwHkG3ss3jDRCSlP6sCcW5YK6Gnqv2bvScVdbSPenq9aPbIB5cVzQPg8oeWsIBmR(I3mNNSMwKMeljUXS6lMgdosfLfhnF2)iX()JLhOrwHkG3ss3jDRCSlPIBSxzpawQHBinNkA4DM)iokoA(S)rIVD2qw2)OsUAkw0FqNlsZBOvs)wwzhuXAArAsSK4gZQVyAm4ivQz(S)blxnfl6pOZfP5n0kPFlX(LXHijlRVgRQbVdbSrqTu)bDSHwjEZudEhcyJxOj1fkqtH44ntn4DiGH2gV02O)G2gFttQbCpqs8MPg8oeWLwPEiTC1uSG3m1G3HaM5Z(h8MrzXrZN9ps8TZgYY(NkubmSjZ(h9h0XgALv2bvSMwKMeljUXS6lMgdosLAPfPjXWMm7F0FqhBOvIPXGJuPM5Z(hSC1uSO)GoxKM3qRK(Te7xghIKvPG4O5Z(hj(2zdzz)tfQao2qRu)bDUind)tYNpVYoOsTfzXCHz8zva4GYIJMp7FK4BNnKL9pvOc4Lnf9h05I0m8pjF(8k7Gk1wKfZfMXNvbGdkloA(S)rIVD2qw2)uHkGJn0k1FqNlsZW)K85ZRSdQuRh)F7bsxSRbrAfoC4WHRSQfzXCHVwDbyfW1xTY1wKfZfMXNvvD11slstI5n0kPFl1m8pjF(CmngCKkIJMp7FK4BNnKL9pvOc4ydTs9h05I0m8pjF(8k7Gk16X)3EG0f7AqKwbw4WHdxzvlYI5cFT6cWkGzrLRTilMlmJpRQ6QfhnF2)iX3oBil7FQqfWlBk6pOZfPz4Fs(85v2bvQ1J)V9aPl21GinlE4WHRSQfzXCHVwDb4dyaIY1wKfZfMXNvXIvxlTinjM3qRK(TuZW)K85ZX0yWrQioA(S)rIVD2qw2)uHkGx2u0FqNlsZW)K85ZRSdQuRh)F7bsxSRbr664WHdxzvlYI5cFT6cWkGRx5AlYI5cZ4ZQQUAXrZN9ps8TZgYY(NkubSrqTu)bDSHwzLDqfRPfPjXsIBmR(IPXGJuPwp()2dKUyxdI01x9HdxjlxKfZf(A1fGpGbqnwvdEhcyJGAP(d6ydTs8M58eEhcyJxOj1fkqtH44nZ5j8oeWqBJxAB0FqBJVPj1aUhijEZCEcVdbCPvQhslxnfl4nZ5j8oeWmF2)G3mkloA(S)rIVD2qw2)uHkGH2gV02O)G2gFttQbCpqYk7GkwtlstILe3yw9ftJbhPsTE8)ThiDXUgePRV6dhUswUilMl81QlaFadGASQg8oeWgb1s9h0XgAL4nZ5j8oeWgVqtQluGMcXXBMZt4DiGH2gV02O)G2gFttQbCpqs8M58eEhc4sRupKwUAkwWBMZt4DiGz(S)bVzuwC08z)JeF7SHSS)PcvaxAL6H0YvtXsLDqfRPfPjXsIBmR(IPXGJuPwArAsCOhlQLPnfmngCKk16X)3EG0f7AqKU(QpC4kz5ISyUWxRUa8bmaQXQAW7qaBeul1FqhBOvI3mNNW7qaB8cnPUqbAkehVzopH3HagAB8sBJ(dAB8nnPgW9ajXBMZt4DiGlTs9qA5QPybVzopH3HaM5Z(h8MrzXrZN9ps8TZgYY(NkubSXl0K6cfOPq8k7GkwtlstILe3yw9ftJbhPsTE8)ThiDXUgePRV6dhUswUilMl81QlaFadGASQg8oeWgb1s9h0XgAL4nZ5j8oeWgVqtQluGMcXXBMZt4DiGH2gV02O)G2gFttQbCpqs8M58eEhc4sRupKwUAkwWBMZt4DiGz(S)bVzuwC08z)JeF7SHSS)PcvahnaQ(h9YMISYoOI10I0KyjXnMvFX0yWrQuBrwmxygFwLcvJsuIq]] )


end
