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


    spec:RegisterPack( "Protection Paladin", 20190810.2255, [[diuGRaqievpcKuBsIAuevofrPvPcPxjHAwsq3IiI2fu)cKAyQGJHOSmjWZajzAQqDnjKTrePVjrQghIaNtIuwNejzEse3JiTperhuIKAHev9qjsKjIiiDrebXjLirTsvKDsegQejSueb1tbAQis7fYFj1GPYHPSyq9yjnzHUmQntvFwLgTsoTuRMiQxdsmBb3gWUv8BvnCewoHNtY0fDDLA7efFxf14vH48ery9icnFqSFKgrgIuey0sgjrbhiR0oqci7aUGckQOckabMsccgbsyvOyxgbogaJalfIp5A2)qDLclyXEqGeMKi8werkcu9BrLrGRmjuLkOH(25AdJRpa0QgyhSS)PkmFcTQbQqJaH3DilLhemcmAjJKOGdKvAhibKDaxqbfvezKaeOTZ1lqGGnqPecC1XipiyeyKvveiutDLcXNCn7FOUsHfSyp0tqn1TYKqvQGg6BNRnmU(aqRAGDWY(NQW8j0QgOcn9eutDL69DRsQJSdfsDfCGSsJ6KKuxbfuQGQIONONGAQRuAzZLv0tqn1jjPUsDmYrQJeMH3qHXiWqRsfIueiqN91Y(hePijidrkcKhdoWrK8iWQOtw0gcKCQlTapjwXcJy1ayEm4ahPUYuNvZ(hSA1CiQFVoxSw03vY)wHRltCzf1rsQRaQRm1ro1jh1bV9ESX3wPFVo03vI3euxzQdE79yte5j1r2ZtKf4nb1vM6G3Ep(UnrSTr)ETn1MNudLEUk8MG6ktDWBVhhBz6H1QvZHiEtqDLPo4T3Jj(S)bVjOozrGwn7FqGQvZHO(96CXArFxj)BfkrsuaIueipgCGJi5rGvrNSOnei5uxAbEsSIfgXQbW8yWbosDLPU0c8KyytL9p63Rd9DLyEm4ahPUYuNvZ(hSA1CiQFVoxSw03vY)wHRltCzf1vc1rgc0Qz)dce2uz)J(96qFxjkrsavisrG8yWboIKhbwfDYI2qGYrDl2c5ctutQReQ74duNSiqRM9piWqFxP(96CXAcXNCnFbkrsCmIueipgCGJi5rGvrNSOneOCu3ITqUWe1K6kH6o(a1jlc0Qz)dcCztu)EDUynH4tUMVaLijkcrkcKhdoWrK8iWQOtw0gcuoQRN6d0Zvhna7YAYoC4Wbaf1vc1TylKlmGDeQ7Ouhz4ckI6KL6ktDl2c5ctutQReQROIOUYuxAbEsSOVRK)Tsti(KR5lW8yWboIaTA2)Gad9DL63RZfRjeFY18fOejHKIifbYJbh4isEeyv0jlAdbkh11t9b65QJgGDznzq1Hdhauuxju3ITqUWa2rOUJsDKHLuQtwQRm1TylKlmrnPUsOUIkcbA1S)bbg67k1VxNlwti(KR5lqjsIshrkcKhdoWrK8iWQOtw0gcuoQRN6d0Zvhna7YAj9WHdakQReQBXwixya7iu3rPUd4sN6KL6ktDl2c5ctutQReQtslI6ktDPf4jXI(Us(3knH4tUMVaZJbh4ic0Qz)dcCztu)EDUynH4tUMVaLijibisrG8yWboIKhbwfDYI2qGYrD9uFGEU6ObyxwxAhoCaqrDLqDl2c5cdyhH6ok1rgUaQtwQRm1TylKlmrnPUsOUIkcbA1S)bbUSjQFVoxSMq8jxZxGsKeLgIueipgCGJi5rGvrNSOnei5uxAbEsSIfgXQbW8yWbosDLPUEQpqpxD0aSlRlOOdhauuhjPUfBHCHbSJqDhL6oGpM6ktDKtDYrDWBVhB8Tv63Rd9DL4nb1bbc1bV9ESjI8K6i75jYc8MG6GaH6G3Ep(UnrSTr)ETn1MNudLEUk8MG6GaH6G3Epo2Y0dRvRMdr8MG6GaH6G3EpM4Z(h8MG6KfbA1S)bbA8Tv63Rd9DLOejbzhqKIa5XGdCejpcSk6KfTHajN6slWtIvSWiwnaMhdoWrQRm11t9b65QJgGDzDbfD4aGI6ij1TylKlmGDeQ7Ou3b8XuxzQJCQtoQdE79yJVTs)EDOVReVjOoiqOo4T3JnrKNuhzpprwG3euheiuh827X3TjITn63RTP28KAO0ZvH3euheiuh827XXwMEyTA1CiI3euheiuh827XeF2)G3euNSiqRM9piW72eX2g9712uBEsnu65QqjscYidrkcKhdoWrK8iWQOtw0gcKCQlTapjwXcJy1ayEm4ahPUYuxAbEsSVhlOvPnrmpgCGJuxzQRN6d0Zvhna7Y6ck6Wbaf1rsQBXwixya7iu3rPUd4JPUYuh5uNCuh827XgFBL(96qFxjEtqDqGqDWBVhBIipPoYEEISaVjOoiqOo4T3JVBteBB0VxBtT5j1qPNRcVjOoiqOo4T3JJTm9WA1Q5qeVjOoiqOo4T3Jj(S)bVjOozrGwn7FqGXwMEyTA1CiIsKeKvaIueipgCGJi5rGvrNSOnei5uxAbEsSIfgXQbW8yWbosDLPUEQpqpxD0aSlRlOOdhauuhjPUfBHCHbSJqDhL6oGpM6ktDKtDYrDWBVhB8Tv63Rd9DL4nb1bbc1bV9ESjI8K6i75jYc8MG6GaH6G3Ep(UnrSTr)ETn1MNudLEUk8MG6GaH6G3Epo2Y0dRvRMdr8MG6GaH6G3EpM4Z(h8MG6KfbA1S)bbAIipPoYEEISaLijidQqKIa5XGdCejpcSk6KfTHajN6slWtIvSWiwnaMhdoWrQRm1TylKlmrnPUsOoYkcbA1S)bbgmjH(h9YMOcLOebw)pe)ZJcrkscYqKIa5XGdCejpcSk6KfTHaH3Ep2KHNBpx9zHLl8MabA1S)bb6Bbdh(pIsKefGifbYJbh4isEeOvZ(heOrIQLjmL2)tQFVM4pZceyv0jlAdbw)pe)ZdwXcJy1aybdy9OOUsKsDKDG6GaH6iN6slWtIvSWiwnaMhdoWre4yamc0ir1YeMs7)j1Vxt8NzbkrsavisrG8yWboIKhbA1S)bbAQLm2WkTWiXxORVWciWQOtw0gcuoQlYWBVhlms8f66lSGoYWBVhRsRcfQJKuxPtDLPo4T3Jnz452ZvFwy5cVjOozPoiqOUidV9ESWiXxORVWc6idV9ESkTkuOoPu3be4yamc0ulzSHvAHrIVqxFHfqjsIJrKIa5XGdCejpcSk6KfTHaR)hI)5bRwnhI63RZfRf9DL8Vv46YexwP9cRM9pwG6iPuQRaeOvZ(heOIfgXQbqjsIIqKIa5XGdCejpcSk6KfTHaH3EpwXcJy1a4nb1bbc1v)pe)ZdwXcJy1aybdy9OOUsOUcOoiqOoYPU0c8KyflmIvdG5XGdCebA1S)bbAYWZTNR(SWYfkrsiPisrG8yWboIKhbwfDYI2qG1)dX)8GvRMdr9715I1I(Us(3kCDzIlR0EHvZ(hlqDLiL6oGlcbA1S)bbcBQS)r)EDOVReLijkDePiqEm4ahrYJaRIozrBiq4T3Jnz452ZvFwy5cVjqGwn7FqGeF2)GsKeKaePiqEm4ahrYJaRIozrBiq4T3JvSWiwnaEtqDqGqDKtDPf4jXkwyeRgaZJbh4ic0Qz)dcCRyDNmGcLijknePiqEm4ahrYJaTA2)GaVIFUknHObSGwyxgbwfDYI2qGYrDYrD1)dX)8GL8oEb4jX(DiOfCDzIlRZgGPossDhtDqGqDYrDKtDPf4jXvXwzrwO0sEhVa8KyEm4ahPUYuhHGLrFRrmzyjVJxaEsQtwQtwQRm1v)pe)Zd2KHNlluA1Q5qelyaRhf1rsQ7yQRm1bV9ESIfgXQbWcgW6rrDKK6oM6KL6GaH6KJ6G3EpwXcJy1aybdy9OOUsOUJPozrGJbWiWR4NRstiAalOf2LrjscYoGifbYJbh4isEeOvZ(heialyOKltP92CrGvrNSOnei5uh827XMm8C75QplSCH3euxzQtoQdE79yflmIvdG3euheiuh5uxAbEsSIfgXQbW8yWbosDYIahdGrGaSGHsUmL2BZfLijiJmePiqEm4ahrYJahdGrGcJeJ7bkknCF1coQH3z(dc0Qz)dcuyKyCpqrPH7RwWrn8oZFqjkrGr2B7qIifjbzisrGwn7FqGcgEdfgbYJbh4isEuIKOaePiqEm4ahrYJaTA2)GaRwiOTA2)OdTkrGHwL6Xayey9)q8ppkuIKaQqKIa5XGdCejpc0Qz)dcSAHG2Qz)Jo0QebgAvQhdGrGaD2xl7FqjsIJrKIa5XGdCejpcSk6KfTHaLJ6G3Ep2KHNlluAzSWlWBcQRm1v)pe)ZdwTAoe1VxNlwl67k5FRW1LjUSs7fwn7FSa1rsPuxb4IOozPUYuNCux9)q8ppyflmIvdGfmG1JI6ij1DRrQdceQJCQlTapjwXcJy1ayEm4ahPozrGwn7FqGQvZHO(96CXArFxj)BfkrsueIueipgCGJi5rGvrNSOneOCuh827XMm8C75QplSCH3euxzQJCQlTapjwXcJy1ayEm4ahPozPoiqOo4T3JvSWiwnaEtqDLPo4T3Jnz45YcLwgl8c8MabA1S)bbQwnhI63RZfRf9DL8VvOejHKIifbYJbh4isEeyv0jlAdbkh1bV9ESjdp3EU6Zclx4nb1vM6G3Ep2KHNBpx9zHLlSGbSEuuxju3XuxzQJCQlTapjwXcJy1ayEm4ahPozPoiqOo5Oo4T3JvSWiwnawWawpkQReQ7yQRm1bV9ESIfgXQbWBcQtweOvZ(heOA1CiQFVoxSw03vY)wHsKeLoIueipgCGJi5rGvrNSOnei827XkwyeRgaVjOUYuh827XkwyeRgalyaRhf1vc1bviqRM9piWqFxPsl5D8cWtIsKeKaePiqEm4ahrYJaRIozrBiqYPU6pkUkSS)bVjqGwn7FqG1FuCvyz)dkrsuAisrG8yWboIKhbwfDYI2qGYrD1)dX)8GL8oEb4jXcgW6rrDLqD3AK6ktD1)dX)8GL8oEb4jX1LjUSs7fwn7FSa1rsQJmQRm1v)pe)ZJwWwnPozPoiqOoYPU0c8K4QyRSiluAjVJxaEsmpgCGJiqRM9piqjVJxaEsuIKGSdisrG8yWboIKhbwfDYI2qG1)dX)8OfSvteOvZ(heOjdpxwO0QvZHikrsqgzisrG8yWboIKhbwfDYI2qG1)dX)8OfSvtQdceQJCQlTapjUk2klYcLwY74fGNeZJbh4ic0Qz)dcuY74fGNeLijiRaePiqEm4ahrYJaRIozrBiqYPU0c8KyflmIvdG5XGdCK6GaH6G3EpwXcJy1a4nbc0Qz)dcm03vQ0sEhVa8KOejbzqfIueipgCGJi5rGwn7FqGWbwP4OEzaaSabQsrdfwHaHkuIKGSJrKIaTA2)Gaxgaal0VxNlwl67k5FRqG8yWboIKhLijiRiePiqRM9piW6pkUkSS)bbYJbh4isEuIseiHGRpaSLisrsqgIueipgCGJi5rjsIcqKIa5XGdCejpkrsavisrG8yWboIKhLijogrkcKhdoWrK8OejrrisrGwn7FqGeF2)Ga5XGdCejpkrsiPisrGwn7FqGH(UsLwY74fGNebYJbh4isEuIsuIaLHfQ(hKefCGSs7qPtgjaxqbKvec8SjMEUkeyPmaXlsosDhtDwn7FOUqRsfMEcbQi4kscjvsrGeI33bgbc1uxPq8jxZ(hQRuybl2d9eutDRmjuLkOH(25AdJRpa0QgyhSS)PkmFcTQbQqtpb1uxPEF3QK6i7qHuxbhiR0Oojj1vqbLkOQi6j6jOM6kLw2Czf9eutDssQRuhJCK6iHz4nuym9e9eutDKqocx3jhPoy2)cM6QpaSLuhmF7rHPUsDTYePI6MFKKlta43bQZQz)JI6(jijW0twn7FuycbxFaylL6dMck0twn7FuycbxFayllwk0()J0twn7FuycbxFayllwk02(cWtAz)d9eutDGJrOwFsDcRJuh8275i1Pslvuhm7FbtD1ha2sQdMV9OOoBIuhHGLKeFM9CPUwrDXFym9KvZ(hfMqW1ha2YILcTAmc16tTkTurpz1S)rHjeC9bGTSyPqt8z)d9KvZ(hfMqW1ha2YILcDOVRuPL8oEb4jPNONGAQJeYr46o5i1XYWcjb1LnatD5IPoRMVG6Af1zYyDWGdmMEYQz)JsQGH3qHPNSA2)Okwk0vle0wn7F0HwLfogalT(Fi(Nhf9KvZ(hvXsHUAHG2Qz)Jo0QSWXayPaD2xl7FONGAQJe6gGONl1b(jjm1vxM4Yk6jRM9pQILcTA1CiQFVoxSw03vY)wvy7Lkh827XMm8CzHslJfEbEtuU(Fi(NhSA1CiQFVoxSw03vY)wHRltCzL2lSA2)ybskTaCrYwwU6)H4FEWkwyeRgalyaRhfjV1ieiKNwGNeRyHrSAampgCGJYspz1S)rvSuOvRMdr9715I1I(Us(3QcBVu5G3Ep2KHNBpx9zHLl8MOm5Pf4jXkwyeRgaZJbh4OSqGaV9ESIfgXQbWBIYWBVhBYWZLfkTmw4f4nb9KvZ(hvXsHwTAoe1VxNlwl67k5FRkS9sLdE79ytgEU9C1NfwUWBIYWBVhBYWZTNR(SWYfwWawpQsoUm5Pf4jXkwyeRgaZJbh4OSqGih827XkwyeRgalyaRhvjhxgE79yflmIvdG3eYspz1S)rvSuOd9DLkTK3XlapzHTxk827XkwyeRgaVjkdV9ESIfgXQbWcgW6rvcurpz1S)rvSuOR)O4QWY(NcBVuYR)O4QWY(h8MGEYQz)JQyPql5D8cWtwy7Lkx9)q8ppyjVJxaEsSGbSEuLCRXY1)dX)8GL8oEb4jX1LjUSs7fwn7FSajjRC9)q8ppAbB1uwiqipTapjUk2klYcLwY74fGNeZJbh4i9KvZ(hvXsH2KHNlluA1Q5qSW2lT(Fi(NhTGTAspz1S)rvSuOL8oEb4jlS9sR)hI)5rlyRMqGqEAbEsCvSvwKfkTK3XlapjMhdoWr6jRM9pQILcDOVRuPL8oEb4jlS9sjpTapjwXcJy1ayEm4ahHabE79yflmIvdG3e0twn7FuflfA4aRuCuVmaawuOkfnuyLuOIEYQz)JQyPqVmaawOFVoxSw03vY)wrpz1S)rvSuOR)O4QWY(h6j6jRM9pkC9)q8ppkP(wWWH)Jf2EPWBVhBYWZTNR(SWYfEtqpz1S)rHR)hI)5rvSuO3kw3jdu4yaSuJevltykT)Nu)EnXFMff2EP1)dX)8GvSWiwnawWawpQsKs2biqipTapjwXcJy1ayEm4ahPNSA2)OW1)dX)8Okwk0BfR7KbkCmawQPwYydR0cJeFHU(cluy7LkxKH3EpwyK4l01xybDKH3EpwLwfkKS0ldV9ESjdp3EU6Zclx4nHSqGez4T3Jfgj(cD9fwqhz4T3JvPvHI0d0twn7Fu46)H4FEuflfAflmIvduy7Lw)pe)ZdwTAoe1VxNlwl67k5FRW1LjUSs7fwn7FSajLwa9KvZ(hfU(Fi(NhvXsH2KHNBpx9zHLRcBVu4T3JvSWiwnaEtabs9)q8ppyflmIvdGfmG1JQKcGaH80c8KyflmIvdG5XGdCKEYQz)Jcx)pe)ZJQyPqdBQS)r)EDOVRSW2lT(Fi(NhSA1CiQFVoxSw03vY)wHRltCzL2lSA2)yHsKEaxe9KvZ(hfU(Fi(NhvXsHM4Z(NcBVu4T3Jnz452ZvFwy5cVjONSA2)OW1)dX)8Okwk0BfR7Kbuf2EPWBVhRyHrSAa8MaceYtlWtIvSWiwnaMhdoWr6jRM9pkC9)q8ppQILc9wX6ozGchdGLEf)CvAcrdybTWUCHTxQCYv)pe)ZdwY74fGNe73HGwW1LjUSoBaMKhdbICKNwGNexfBLfzHsl5D8cWtI5XGdCSmHGLrFRrmzyjVJxaEszLTC9)q8ppytgEUSqPvRMdrSGbSEuK84YWBVhRyHrSAaSGbSEuK8yzHaro4T3JvSWiwnawWawpQsoww6jRM9pkC9)q8ppQILc9wX6ozGchdGLcWcgk5YuAVn3cBVuYH3Ep2KHNBpx9zHLl8MOSCWBVhRyHrSAa8MaceYtlWtIvSWiwnaMhdoWrzPNSA2)OW1)dX)8Okwk0BfR7KbkCmawQWiX4EGIsd3xTGJA4DM)qprpz1S)rHb6SVw2)ivTAoe1VxNlwl67k5FRkS9sjpTapjwXcJy1ayEm4ahlB1S)bRwnhI63RZfRf9DL8Vv46YexwrYcktUCWBVhB8Tv63Rd9DL4nrz4T3JnrKNuhzpprwG3eLH3Ep(UnrSTr)ETn1MNudLEUk8MOm827XXwMEyTA1CiI3eLH3EpM4Z(h8Mqw6jRM9pkmqN91Y(NILcnSPY(h971H(UYcBVuYtlWtIvSWiwnaMhdoWXYPf4jXWMk7F0Vxh67kX8yWbow2Qz)dwTAoe1VxNlwl67k5FRW1LjUSQeYONSA2)OWaD2xl7Fkwk0H(Us9715I1eIp5A(IcBVu5wSfYfMOMLC8bzPNSA2)OWaD2xl7Fkwk0lBI63RZfRjeFY18ff2EPYTylKlmrnl54dYspz1S)rHb6SVw2)uSuOd9DL63RZfRjeFY18ff2EPY1t9b65QJgGDznzhoC4aGQKfBHCHbSJCuYWfuKSLxSfYfMOMLuurLtlWtIf9DL8VvAcXNCnFbMhdoWr6jRM9pkmqN91Y(NILcDOVRu)EDUynH4tUMVOW2lvUEQpqpxD0aSlRjdQoC4aGQKfBHCHbSJCuYWsQSLxSfYfMOMLuur0twn7FuyGo7RL9pflf6Lnr9715I1eIp5A(IcBVu56P(a9C1rdWUSwspC4aGQKfBHCHbSJC0d4sx2Yl2c5ctuZsK0IkNwGNel67k5FR0eIp5A(cmpgCGJ0twn7FuyGo7RL9pflf6Lnr9715I1eIp5A(IcBVu56P(a9C1rdWUSU0oC4aGQKfBHCHbSJCuYWfiB5fBHCHjQzjfve9KvZ(hfgOZ(Az)tXsH24BR0Vxh67klS9sjpTapjwXcJy1ayEm4ahl3t9b65QJgGDzDbfD4aGIKl2c5cdyh5OhWhxMC5G3Ep24BR0Vxh67kXBciqG3Ep2erEsDK98ezbEtabc827X3TjITn63RTP28KAO0ZvH3eqGaV9ECSLPhwRwnhI4nbeiWBVht8z)dEtil9KvZ(hfgOZ(Az)tXsH(UnrSTr)ETn1MNudLEUQcBVuYtlWtIvSWiwnaMhdoWXY9uFGEU6ObyxwxqrhoaOi5ITqUWa2ro6b8XLjxo4T3Jn(2k971H(Us8Mace4T3JnrKNuhzpprwG3eqGaV9E8DBIyBJ(9ABQnpPgk9Cv4nbeiWBVhhBz6H1QvZHiEtabc827XeF2)G3eYspz1S)rHb6SVw2)uSuOJTm9WA1Q5qSW2lL80c8KyflmIvdG5XGdCSCAbEsSVhlOvPnrmpgCGJL7P(a9C1rdWUSUGIoCaqrYfBHCHbSJC0d4JltUCWBVhB8Tv63Rd9DL4nbeiWBVhBIipPoYEEISaVjGabE79472eX2g9712uBEsnu65QWBciqG3Epo2Y0dRvRMdr8Mace4T3Jj(S)bVjKLEYQz)Jcd0zFTS)PyPqBIipPoYEEISOW2lL80c8KyflmIvdG5XGdCSCp1hONRoAa2L1fu0HdaksUylKlmGDKJEaFCzYLdE79yJVTs)EDOVReVjGabE79yte5j1r2ZtKf4nbeiWBVhF3Mi22OFV2MAZtQHspxfEtabc827XXwMEyTA1CiI3eqGaV9EmXN9p4nHS0twn7FuyGo7RL9pflf6Gjj0)Ox2evf2EPKNwGNeRyHrSAampgCGJLxSfYfMOMLqwrOeLie]] )


end
