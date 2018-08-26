-- PaladinProtection.lua
-- May 2018

local addon, ns = ...
local Hekili = _G[ addon ]

local class = Hekili.Class
local state = Hekili.State


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
            duration = 20,
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
            generate = function ()
                local c = buff.consecration
                
                if FindUnitBuffByID( "player", 188370 ) then
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
            duration = 11.183,
            max_stack = 1,
        },
        sign_of_the_critter = {
            id = 186406,
            duration = 3600,
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
            
            defensive = true,

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
            defensive = true,

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
                addStack( "avengers_valor", nil, 1 )
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
            
            -- toggle = "cooldowns",
            defensive = true,

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
            
            defensive = true,

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
            
            defensive = true,

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
            defensive = true,

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
            
            defensive = true,

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
            charges = function () return talent.cavalier.enabled and 2 or 1 end,
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
            
            defensive = true,

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
            charges = function () return ( level < 116 and equipped.saruans_resolve ) and 2 or 1 end,
            cooldown = function () return ( ( level < 116 and equipped.saruans_resolve ) and 0.9 or 1 ) * 15 * haste end,
            recharge = function () return ( ( level < 116 and equipped.saruans_resolve ) and 0.9 or 1 ) * 15 * haste end,
            gcd = "spell",
            
            defensive = true,

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
            charges = function () return talent.crusaders_judgment.enabled and 2 or 1 end,
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
            
            defensive = true,

            startsCombat = false,
            texture = 135928,
            
            handler = function ()
                applyDebuff( "player", "forbearance" )
            end,
        },
        

        light_of_the_protector = {
            id = 184092,
            cast = 0,
            charges = function () return ( level < 116 and equipped.saruans_resolve ) and 2 or 1 end ,
            cooldown = function () return ( ( level < 116 and equipped.saruans_resolve ) and 0.9 or 1 ) * 17 * haste end,
            recharge = function () return ( ( level < 116 and equipped.saruans_resolve ) and 0.9 or 1 ) * 17 * haste end,
            hasteCD = true,
            gcd = "spell",
            
            defensive = true,

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

            usable = function () return debuff.casting.up end,
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
            gcd = "spell",

            interrupt = true,
            
            startsCombat = true,
            texture = 236265,
            
            handler = function ()
                removeBuff( "avengers_valor" )
                applyBuff( "shield_of_the_righteous", buff.shield_of_the_righteous.remains + 4.5 )

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
    
        package = "Protection Paladin",
    } )


    spec:RegisterPack( "Protection Paladin", 20180801.2345, [[dKeiWaqiPclcqKEeGQAtkkFcqLrjvLtjvvRcq4vOiZsQOBbOk7IKFbqdtQYXivSmsjpdfvtJukxtrQTbO4Bas14uufNJuQQ1POknpuuUhPyFKk5GKsflef6HKsLQjciIUiGi8rarzKKsLYjbKYkLkntsPk7eadfqslfqcpvPMQI4QaIQVskvYEv1FfAWu1HjwmOESctwkxgzZQ4ZO0OvYPfTAaLETIKzl42GSBj)gYWvPJdirlhvpNktNY1bA7OGVtQuJxrLZROQMpPQ9d1Vo)KF3eJEa0QNoZtV5PNokTyU20sBm)328V0VVYykHL(Djq0VbQCKrdlrf2duLG0Y63xz(bK0(j)2Ha5d63lZUU5fqaztBbcRgiiaDjeyqSevdUCmaDj0aq4acgq4Ja8AedaE5OtgihGtsIRLoaorlDIavjiTSIavoYOHLOs5sOXVHbZGb0Qh(3nXOhaT6PZ80BE6PJslMZCT6b0)TaAle)37es7(VBKB87jR0H9Pd7fS)kJPewc7rhSxgwIkSpKoZH9heh71UrtLHu97q6m3p53n6iGb7N8aOZp53YWsu9Bb0qrXmzm1VPsGdu7z8ThaT(j)wgwIQFZjyWPOFtLahO2Z4Bpam)N8BQe4a1Eg)Djq0VBzcjUiBqgPeIcXMUFldlr1VbDumnc6ThaT9t(TmSev)goGqT4bKp)FtLahO2Z4Bpat)t(TmSev)gM4oIpvwS)MkboqTNX3EaaMFYVLHLO63cFiffneNtL9BQe4a1EgF7baO)t(TmSev)oKSlZfbwWglev2VPsGdu7z8ThG55N8BzyjQ(nCaHAXdiF()MkboqTNX3Ea0()KFldlr1VHjUJ4tLf7VPsGdu7z8ThaD69t(TmSev)w4dPOOH4CQSFtLahO2Z4Bpa6OZp53YWsu97qYUmxeybBSquz)MkboqTNX3Ea0rRFYVPsGdu7z83YWsu97HecrzyjQIH0z)oKolwce97lhzV92VVCAGGGf7N8aOZp53ujWbQ9m(2dGw)KFtLahO2Z4Bpam)N8BQe4a1EgF7bqB)KFldlr1VVilr1VPsGdu7z8T3(9LJSFYdGo)KFtLahO2Z4Vh80iEk)UdS3KavMYrC5UsifvcCGAy)mSVpSxgwIkLBLuOfrNOTOipzxgHaDQXs4SKd71f2Rf23p2pd77a77d7HbphLqSPlIoXqYUmf4f7NH9WGNJs4nQSyJou1iUc8I9ZWEyWZrXck8wkveDIsnsQS4uzX6uGxSFg2ddEoQwYqwu0Tsk0uGxSFg2ddEoQlYsuPaVyF))wgwIQF7wjfAr0jAlkYt2Lriq3BpaA9t(nvcCGApJ)EWtJ4P87oWEtcuzkhXL7kHuujWbQH9ZWEtcuzkyXzjQIOtmKSltrLahOg2pd7LHLOs5wjfAr0jAlkYt2LriqNASeol5WEMH968BzyjQ(nS4Sevr0jgs2L92daZ)j)MkboqTNXFp4Pr8u(DFy)IKGTu3HH9md71wpSV)Fldlr1Vdj7YIOt0wu8Yrgnme)ThaT9t(nvcCGApJ)EWtJ4P87(W(fjbBPUdd7zg2RTEyF))wgwIQFVKQfrNOTO4LJmAyi(Bpat)t(nvcCGApJ)EWtJ4P87(W(SgiOSyJnbsyPOo961RhKd7zg2VijylfKmh2deyVokTMg77h7NH9lsc2sDhg2ZmSF6PX(zyVjbQmfpzxgHaDXlhz0WqCfvcCGA)wgwIQFhs2LfrNOTO4LJmAyi(BpaaZp53ujWbQ9m(7bpnINYV7d7ZAGGYIn2eiHLI6W8E96b5WEMH9lsc2sbjZH9ab2RJcyW((X(zy)IKGTu3HH9md7NE6Fldlr1Vdj7YIOt0wu8Yrgnme)ThaG(p53ujWbQ9m(7bpnINYV7d7ZAGGYIn2eiHLIatVE9GCypZW(fjbBPGK5WEGa77Pa6yF)y)mSFrsWwQ7WWEMH9aZ0y)mS3KavMINSlJqGU4LJmAyiUIkboqTFldlr1Vxs1IOt0wu8Yrgnme)ThG55N8BQe4a1Eg)9GNgXt539H9znqqzXgBcKWsrTFVE9GCypZW(fjbBPGK5WEGa71rPf23p2pd7xKeSL6omSNzy)0t)BzyjQ(9sQweDI2IIxoYOHH4V9aO9)j)MkboqTNXFp4Pr8u(DhyVjbQmLJ4YDLqkQe4a1W(zyFwdeuwSXMajSuuRP71dYH96c7xKeSLcsMd7bcSVNsBy)mSVdSVpShg8CucXMUi6edj7YuGxSxVEShg8CucVrLfB0HQgXvGxSxVEShg8CuSGcVLsfrNOuJKklovwSof4f71Rh7Hbphvlzilk6wjfAkWl2Rxp2ddEoQlYsuPaVyF))wgwIQFleB6IOtmKSl7ThaD69t(nvcCGApJ)EWtJ4P87oWEtcuzkhXL7kHuujWbQH9ZW(SgiOSyJnbsyPOwt3RhKd71f2VijylfKmh2deyFpL2W(zyFhyFFypm45OeInDr0jgs2LPaVyVE9ypm45OeEJkl2OdvnIRaVyVE9ypm45OybfElLkIorPgjvwCQSyDkWl2Rxp2ddEoQwYqwu0Tsk0uGxSxVEShg8CuxKLOsbEX(()TmSev)Mfu4TuQi6eLAKuzXPYI192dGo68t(nvcCGApJ)EWtJ4P87oWEtcuzkhXL7kHuujWbQH9ZWEtcuzQtwsi6mPAkQe4a1W(zyFwdeuwSXMajSuuRP71dYH96c7xKeSLcsMd7bcSVNsBy)mSVdSVpShg8CucXMUi6edj7YuGxSxVEShg8CucVrLfB0HQgXvGxSxVEShg8CuSGcVLsfrNOuJKklovwSof4f71Rh7Hbphvlzilk6wjfAkWl2Rxp2ddEoQlYsuPaVyF))wgwIQF3sgYIIUvsH2Bpa6O1p53ujWbQ9m(7bpnINYV7a7njqLPCexUResrLahOg2pd7ZAGGYIn2eiHLIAnDVEqoSxxy)IKGTuqYCypqG99uAd7NH9DG99H9WGNJsi20frNyizxMc8I961J9WGNJs4nQSyJou1iUc8I961J9WGNJIfu4TuQi6eLAKuzXPYI1PaVyVE9ypm45OAjdzrr3kPqtbEXE96XEyWZrDrwIkf4f77)3YWsu9BH3OYIn6qvJ4V9aOdZ)j)MkboqTNXFp4Pr8u(DhyVjbQmLJ4YDLqkQe4a1W(zy)IKGTu3HH9md71z6Fldlr1VdY8JOkUKQ5E7bqhT9t(nvcCGApJ)(ISev)gfArDl8Fldlr1VVilr1Vh80iEk)gg8CucduXMfBu3CXwkWl2pd7njqLPCexUResrLahOg2pd7LHLmqrQiOKCypZWEM)2dGot)t(nvcCGApJ)(ISev)(YrbuXsT4fPBI)BzyjQ(9fzjQ(9GNgXt53WGNJsyGk2SyJ6Ml2sbEX(zyVjbQmLJ4YDLqkQe4a1W(zyVmSKbksfbLKd71LgSN5V9aOdW8t(nvcCGApJ)(ISev)gSGPQLfB8ISev)wgwIQFFrwIQFp4Pr8u(DhyVjbQmLJ4YDLqkQe4a1E7bqhG(p53ujWbQ9m(7bpnINYV7a7njqLPCexUResrLahOg2pd7ZAGGYIn2eiHLIAnDVEqoSxxy)IKGTuqYCypqG99uAd7NH9DG99H9WGNJsi20frNyizxMc8I961J9WGNJs4nQSyJou1iUc8I961J9WGNJIfu4TuQi6eLAKuzXPYI1PaVyVE9ypm45OAjdzrr3kPqtbEXE96XEyWZrDrwIkf4f77)3YWsu9BNHk6G4qV9aOZ88t(nvcCGApJ)EWtJ4P87oWEtcuzkhXL7kHuujWbQ9BzyjQ(TWavSzXg1nxS1Bpa6O9)j)MkboqTNXFp4Pr8u(DhyVjbQmLJ4YDLqkQe4a1(TmSev)gybBSquzV9aOvVFYVPsGdu7z83dEAepLF3b2BsGkt5iUCxjKIkboqnSFg2BsGktn4GoPrCxeybBSquzkQe4a1(TmSev)wyGkwI7IUvsH2BpaAPZp53ujWbQ9m(7bpnINYV7a7njqLPCexUResrLahO2VLHLO63WbY5OwCjqqe)ThaT06N8BQe4a1Eg)9GNgXt53DG9MeOYuoIl3vcPOsGdu73YWsu9BHbQyjUl6wjfAV9aOfZ)j)MkboqTNXFp4Pr8u(DhyVjbQmLJ4YDLqkQe4a1(TmSev)EGkhn4ILO6ThaT02p53ujWbQ9m(7bpnINYV7a7njqLPCexUResrLahO2VLHLO63lbcI4r0jAlkYt2Lriq3BpaAn9p53ujWbQ9m(7bpnINYVnjqLPCexUResrLahOg2pd7LHLOs5wjfAr0jAlkYt2LriqNASeol5WEDPb7163YWsu9BhXL7kHE7bqlG5N8BQe4a1Eg)9GNgXt53MeOYuoIl3vcPOsGdud7NH99H9WGNJYrC5Usif4f71Rh7hiuOH0DPCexUResXjijlh2ZmSxByF))wgwIQFlmqfBwSrDZfB92dGwa9FYVPsGdu7z83dEAepLFBsGkt5iUCxjKIkboqnSFg23h2pqOqdP7snqLJgCXsuP4eKKLd71LgSVNshSFg23h2ldlrLYTsk0IOt0wuKNSlJqGo1yjCwYH96c71snn2pd7hiuOH0DPCexUResXjijlh2RlSN5yF)yVE9yFFypm45OCexUResbEX((X(()TmSev)2Tsk0IOt0wuKNSlJqGU3Ea0AE(j)MkboqTNXFp4Pr8u(TjbQmLJ4YDLqkQe4a1(TmSev)wyGkwI7IUvsH2BpaAP9)j)MkboqTNXFp4Pr8u(TjbQmLJ4YDLqkQe4a1W(zyFFyVmSKbksfbLKd7zg2Rf2Rxp27ilcJkqNYsIRvVOw3b23)VLHLO63alyJfIk7ThaM37N8BQe4a1Eg)9GNgXt53MeOYuoIl3vcPOsGdud7NH99H9WGNJYrC5UsifNGKSCyVUWEGb71Rh7HbphLJ4YDLqQgs3f23)VLHLO63du5ObxSevV9aWCD(j)MkboqTNXFp4Pr8u(TjbQmLJ4YDLqkQe4a1(TmSev)gybBSquzV9aWCT(j)MkboqTNXFp4Pr8u(TjbQmLJ4YDLqkQe4a1(TmSev)EGkhn4ILO6ThaMZ8FYVPsGdu7z83dEAepLFBsGkt5iUCxjKIkboqTFldlr1VHdKZrT4sGGi(BpamxB)KFtLahO2Z4Vh80iEk)2KavMYrC5UsifvcCGA)wgwIQFVeiiIhrNOTOipzxgHaDV92VHK5ITR7N8aOZp53YWsu9Bb0qrXmzm1VPsGdu7z8ThaT(j)MkboqTNXFxce97wMqIlYgKrkHOqSP73YWsu9BqhftJGE7bG5)KFldlr1VHdiulEa5Z)3ujWbQ9m(2dG2(j)wgwIQFdtChXNkl2FtLahO2Z4Bpat)t(TmSev)w4dPOOH4CQSFtLahO2Z4BpaaZp53YWsu97qYUmxeybBSquz)MkboqTNX3E73qYCrhiNHKbj8tEa05N8BzyjQ(TaAOOyMmM63ujWbQ9m(2dGw)KFtLahO2Z4VlbI(DltiXfzdYiLqui209BzyjQ(nOJIPrqV9aW8FYVLHLO63WbeQfpG85)BQe4a1EgF7bqB)KFldlr1VHjUJ4tLf7VPsGdu7z8ThGP)j)wgwIQFl8Huu0qCov2VPsGdu7z8ThaG5N8BzyjQ(DizxMlcSGnwiQSFtLahO2Z4BV92VzG4UevpaA1tN5P380thLwmV30)w3cVYI19BTlTdqbaanaaYMxSh7NSiSpHUiUH9heh7bUgDeWGbCypNakbto1WEhcIWEb0qqIrnSFSKILCkCxTxwe2RZ8I9a5Ld8ErCJAyVmSevypWjGgkkMjJPaofUlUR2L2bOaaGgaazZl2J9twe2Nqxe3W(dIJ9a3LJmGd75eqjyYPg27qqe2lGgcsmQH9JLuSKtH7Q9YIWEDa6Zl2dKxoW7fXnQH9YWsuH9aNZqfDqCiGtH7I7QDPDakaaObaq28I9y)KfH9j0fXnS)G4ypWbjZfBxhWH9CcOem5ud7Diic7fqdbjg1W(XskwYPWD1EzryVoZl2dKxoW7fXnQH9YWsuH9aNaAOOyMmMc4u4U4UAxAhGcaaAaaKnVyp2pzryFcDrCd7pio2dCqYCrhiNHKbjaCypNakbto1WEhcIWEb0qqIrnSFSKILCkCxTxwe2RZ8I9a5Ld8ErCJAyVmSevypWjGgkkMjJPaofUlUlqd6I4g1W(PXEzyjQW(q6mNc393xo6Kb63aFShiXC0a0Og2dtheNW(bccwmShMyZYPWETZyqxZH9fQaElHdDadyVmSevoShvH5RWDLHLOYPUCAGGGftZjiUPWDLHLOYPUCAGGGfJjnaEqOgUlWh73LCDlKH9CjBypm45qnS3zI5WEy6G4e2pqqWIH9WeBwoSxQg2F5eW7ImllwSpDyFdvKc3vgwIkN6YPbccwmM0aORKRBHSOZeZH7kdlrLtD50abblgtAa8ISev4U4UaFShiXC0a0Og2tmq85J9wcryVTiSxggIJ9Pd7fgKmiWbsH7kdlrLtJaAOOyMmMc3vgwIkhtAaKtWGtr4UYWsu5ysdGGokMgb1zjqKMwMqIlYgKrkHOqSPd3vgwIkhtAaeoGqT4bKpFCxzyjQCmPbqyI7i(uzXI7kdlrLJjnak8Huu0qCovgURmSevoM0ayizxMlcSGnwiQmCxzyjQCmPbq4ac1Ihq(8XDLHLOYXKgaHjUJ4tLflURmSevoM0aOWhsrrdX5uz4UYWsu5ysdGHKDzUiWc2yHOYWDLHLOYXKgahsieLHLOkgsN1zjqKMlhz4U4UaFSFYkDyF6WEb7xj7c4bKeOUX((GbnSpG0nWZbYzizqGZqAZVFSFGQtYcYflrLc3f4J9aTIb0ue2dpFSxATSyXEGuzyjQCmPbqoyfLHLOkgsN1zjqKgizUy76asXEdH92IWEyInRklwShDWEBryFJocyWWETdqv7PWDLHLOYPGK5ITRtJaAOOyMmMc3vgwIkNcsMl2UoM0aiOJIPrqDwcePPLjK4ISbzKsikeB6WDLHLOYPGK5ITRJjnachqOw8aYNpURmSevofKmxSDDmPbqyI7i(uzXI7kdlrLtbjZfBxhtAau4dPOOH4CQmCxzyjQCkizUy76ysdGHKDzUiWc2yHOYWDXDb(y)Kv6W(0H9c2Vs2fWZbYzizqGZqAZh77dg0W(as3apGKa1D)y)avNKfKlwIkfUlWh7bAfdOPiShE(yV0AzXI9aPYWsu5ysdGCWkkdlrvmKoRZsGinqYCrhiNHKbjaKI9gc7TfH9WeBwvwSyp6G92IW(gDeWGH9AhGQ2tH7kdlrLtbjZfDGCgsgKGgb0qrXmzmfURmSevofKmx0bYzizqcmPbqqhftJG6SeistltiXfzdYiLqui20H7kdlrLtbjZfDGCgsgKatAaeoGqT4bKpFCxzyjQCkizUOdKZqYGeysdGWe3r8PYIf3vgwIkNcsMl6a5mKmibM0aOWhsrrdX5uz4UYWsu5uqYCrhiNHKbjWKgadj7YCrGfSXcrLH7I7kdlrLtD5itJBLuOfrNOTOipzxgHaDDMhnDysGkt5iUCxjKIkboqTz9jdlrLYTsk0IOt0wuKNSlJqGo1yjCwYPlT6Fwh9bdEokHytxeDIHKDzkW7myWZrj8gvwSrhQAexbENbdEokwqH3sPIOtuQrsLfNklwNc8odg8CuTKHSOOBLuOPaVZGbph1fzjQuG3(XDLHLOYPUCKXKgaHfNLOkIoXqYUSoZJMomjqLPCexUResrLahO2mtcuzkyXzjQIOtmKSltrLahO2mzyjQuUvsHweDI2II8KDzec0PglHZsoMPdURmSevo1LJmM0ayizxweDI2IIxoYOHH4DMhn9Tijyl1DymtB96h3vgwIkN6YrgtAaCjvlIorBrXlhz0Wq8oZJM(wKeSL6omMPTE9J7kdlrLtD5iJjnags2LfrNOTO4LJmAyiEN5rtFznqqzXgBcKWsrD61RxpihZwKeSLcsMdi0rP109pBrsWwQ7Wy20tpZKavMINSlJqGU4LJmAyiUIkboqnCxzyjQCQlhzmPbWqYUSi6eTffVCKrddX7mpA6lRbckl2ytGewkQdZ71RhKJzlsc2sbjZbe6OaM(NTijyl1DymB6PXDLHLOYPUCKXKgaxs1IOt0wu8YrgnmeVZ8OPVSgiOSyJnbsyPiW0RxpihZwKeSLcsMdi6Pa69pBrsWwQ7WygWm9mtcuzkEYUmcb6IxoYOHH4kQe4a1WDLHLOYPUCKXKgaxs1IOt0wu8YrgnmeVZ8OPVSgiOSyJnbsyPO2VxVEqoMTijylfKmhqOJsR(NTijyl1DymB6PXDLHLOYPUCKXKgafInDr0jgs2L1zE00HjbQmLJ4YDLqkQe4a1ML1abLfBSjqclf1A6E9GC6ArsWwkizoGONsBZ6OpyWZrjeB6IOtmKSltbE1Rhg8CucVrLfB0HQgXvGx96HbphflOWBPur0jk1iPYItLfRtbE1Rhg8CuTKHSOOBLuOPaV61ddEoQlYsuPaV9J7kdlrLtD5iJjnaYck8wkveDIsnsQS4uzX66mpA6WKavMYrC5UsifvcCGAZYAGGYIn2eiHLIAnDVEqoDTijylfKmhq0tPTzD0hm45OeInDr0jgs2LPaV61ddEokH3OYIn6qvJ4kWRE9WGNJIfu4TuQi6eLAKuzXPYI1PaV61ddEoQwYqwu0Tsk0uGx96Hbph1fzjQuG3(XDLHLOYPUCKXKgaBjdzrr3kPqRZ8OPdtcuzkhXL7kHuujWbQnZKavM6KLeIotQMIkboqTzznqqzXgBcKWsrTMUxpiNUwKeSLcsMdi6P02So6dg8CucXMUi6edj7YuGx96HbphLWBuzXgDOQrCf4vVEyWZrXck8wkveDIsnsQS4uzX6uGx96Hbphvlzilk6wjfAkWRE9WGNJ6ISevkWB)4UYWsu5uxoYysdGcVrLfB0HQgX7mpA6WKavMYrC5UsifvcCGAZYAGGYIn2eiHLIAnDVEqoDTijylfKmhq0tPTzD0hm45OeInDr0jgs2LPaV61ddEokH3OYIn6qvJ4kWRE9WGNJIfu4TuQi6eLAKuzXPYI1PaV61ddEoQwYqwu0Tsk0uGx96Hbph1fzjQuG3(XDLHLOYPUCKXKgadY8JOkUKQ56mpA6WKavMYrC5UsifvcCGAZwKeSL6omMPZ04UYWsu5uxoYysdGxKLOQZsGinOqlQBH3zE0adEokHbQyZInQBUylf4DMjbQmLJ4YDLqkQe4a1MjdlzGIurqj5ygZXDLHLOYPUCKXKgaVilrvNLarAUCuavSulEr6M4DMhnWGNJsyGk2SyJ6Ml2sbENzsGkt5iUCxjKIkboqTzYWsgOiveusoDPH54UYWsu5uxoYysdGxKLOQZsGinGfmvTSyJxKLOQZ8OPdtcuzkhXL7kHuujWbQH7kdlrLtD5iJjna6murhehQZ8OPdtcuzkhXL7kHuujWbQnlRbckl2ytGewkQ1096b501IKGTuqYCarpL2M1rFWGNJsi20frNyizxMc8Qxpm45OeEJkl2OdvnIRaV61ddEokwqH3sPIOtuQrsLfNklwNc8Qxpm45OAjdzrr3kPqtbE1Rhg8CuxKLOsbE7h3vgwIkN6YrgtAauyGk2SyJ6Ml2QZ8OPdtcuzkhXL7kHuujWbQH7kdlrLtD5iJjnacSGnwiQSoZJMomjqLPCexUResrLahOgURmSevo1LJmM0aOWavSe3fDRKcToZJMomjqLPCexUResrLahO2mtcuzQbh0jnI7IalyJfIktrLahOgURmSevo1LJmM0aiCGCoQfxceeX7mpA6WKavMYrC5UsifvcCGA4UYWsu5uxoYysdGcduXsCx0Tsk06mpA6WKavMYrC5UsifvcCGA4UYWsu5uxoYysdGdu5ObxSevDMhnDysGkt5iUCxjKIkboqnCxzyjQCQlhzmPbWLabr8i6eTff5j7YieORZ8OPdtcuzkhXL7kHuujWbQH7kdlrLtD5iJjna6iUCxjuN5rJjbQmLJ4YDLqkQe4a1MjdlrLYTsk0IOt0wuKNSlJqGo1yjCwYPlnAH7kdlrLtD5iJjnakmqfBwSrDZfB1zE0ysGkt5iUCxjKIkboqTz9bdEokhXL7kHuGx96hiuOH0DPCexUResXjijlhZ0w)4UYWsu5uxoYysdGUvsHweDI2II8KDzec01zE0ysGkt5iUCxjKIkboqTz9nqOqdP7snqLJgCXsuP4eKKLtxA6P0zwFYWsuPCRKcTi6eTff5j7YieOtnwcNLC6sl10ZgiuOH0DPCexUResXjijlNUyE)613hm45OCexUResbE7VFCxzyjQCQlhzmPbqHbQyjUl6wjfADMhnMeOYuoIl3vcPOsGdud3vgwIkN6YrgtAaeybBSquzDMhnMeOYuoIl3vcPOsGduBwFYWsgOiveusoMPLE9oYIWOc0PSK4A1lQ1D0pURmSevo1LJmM0a4avoAWflrvN5rJjbQmLJ4YDLqkQe4a1M1hm45OCexUResXjijlNUag96HbphLJ4YDLqQgs3v)4UYWsu5uxoYysdGalyJfIkRZ8OXKavMYrC5UsifvcCGA4UYWsu5uxoYysdGdu5ObxSevDMhnMeOYuoIl3vcPOsGdud3vgwIkN6YrgtAaeoqoh1IlbcI4DMhnMeOYuoIl3vcPOsGdud3vgwIkN6YrgtAaCjqqepIorBrrEYUmcb66mpAmjqLPCexUResrLahO2VDxA8aamaZBV9p]] )


end
