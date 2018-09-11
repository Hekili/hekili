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
                applyDebuff( "player", "forbearance" )
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


    spec:RegisterPack( "Protection Paladin", 20180909.2015, [[dG03MaqisupsrkBsr8jGimkPQCkPQAvks1RKkmlGWTqeSlK(LIQHjv6yKGLrs6ziImnefxtQsBdiQVjvegNur6CiQ06aI08uKCpsQ9jvuherfwijYdrurMiIkQUiqe5JaruNeriwPIYmres3uQiQDIinuevTuer9uqMkq6Qsfr6RsfrSxO(RKgmrhMYIb1JfzYI6YO2Su(mGrRWPfwTuf9AeLMTe3wL2Ts)wvdhHJJOIYYj8CsnDQUUk2oj03jjgVufopIqnFGA)qgRagumu2CgtQQDvOt7sUDjxQQDvGK6vbmKtIjymeHLiRbWyO1UmgI8I35Kh)IKK3kwowmeHrIlVLXGIH0)rKym0WDcniD(CGWhhyA6VZ1X9ump(njSMpxh30C4YdphUzKqMvCoH4BrH1ZjVGjzlY65KNKRK3kwo2k5fVZjp(LQJBcdbFIItISyymu2CgtQQDvOt7sUDjxQQDvGKitNIHSJpEbgckUKtyOmRtyOPHKKx8oN84xKK8wXYXIMnnKC4oHgKoFoq4Jdmn93564EkMh)MewZNRJBAoC5HNd3msiZkoNq8TOW65KxWKSfz9CYtYvYBflhBL8I35Kh)s1XnHMnnKeIjC(cZcKKCbbsQAxf6uKKeqsqgKQAxKK8DYOzOztdjjNg2cWA0SPHKKassoYzoJKKmdFiltrZMgsscijjZA)fCgjVHhaMh)scWMMZiPGt)9YB284xns2e)fjztucwGKKdYtIsXqLq7AmOyOB4bG5XVyqXKQagumeVgCHZyLWqjr4SimmKYiPBfEDQMfgXiUuEn4cNrYjiPL84xQEeCjx)w1hCveadN)JMMgMaG1izNrsvrYjiPYizFij8P1Ogde663QLay40dbsobjHpTg1ezE9AMB8Mzb9qGKtqs4tRrboMih2w)w12uWRxjBSaA6HajNGKWNwJMdfJLR6rWLm9qGKtqs4tRrjEp(LEiqY(XqwYJFXq6rWLC9BvFWvramC(pASJjvvmOyiEn4cNXkHHsIWzryyiLrs3k86unlmIrCP8AWfoJKtqs3k86uyt7XV1VvlbWWP8AWfoJKtqsl5XVu9i4sU(TQp4Qiago)hnnnmbaRrYPqsfWqwYJFXqWM2JFRFRwcGHJDmPKegumeVgCHZyLWqjr4SimmuFi5GTIpOejhjNcjjtxKSFmKL84xmujagE9BvFWvcX7CYFb2XKsgmOyiEn4cNXkHHsIWzryyO(qYbBfFqjsosofssMUiz)yil5XVyOHT563Q(GReI35K)cSJjTxmOyiEn4cNXkHHsIWzryyO(qYyt)nwGA2UgaxvOB3UDVAKCkKCWwXh0R1dKC6iPcuv7fj7hjNGKd2k(GsKCKCkKS3ErYjiPBfEDQiago)hDLq8oN8xq51GlCgdzjp(fdvcGHx)w1hCLq8oN8xGDmPGmgumeVgCHZyLWqjr4SimmuFizSP)glqnBxdGRkqsD729QrYPqYbBfFqVwpqYPJKkqbzKSFKCcsoyR4dkrYrYPqYE7fdzjp(fdvcGHx)w1hCLq8oN8xGDmPDcmOyiEn4cNXkHHsIWzryyO(qYyt)nwGA2Ugaxb5UD7E1i5ui5GTIpOxRhi50rYU0obs2psobjhSv8bLi5i5uiji3lsobjDRWRtfbWW5)OReI35K)ckVgCHZyil5XVyOHT563Q(GReI35K)cSJjTtXGIH41GlCgRegkjcNfHHH6djJn93ybQz7AaCLC72T7vJKtHKd2k(GETEGKthjvGQks2psobjhSv8bLi5i5uizV9IHSKh)IHg2MRFR6dUsiENt(lWoMuYfdkgIxdUWzSsyOKiCweggszK0TcVovZcJyexkVgCHZi5eKm20FJfOMTRbWvv7TB3Rgj7msoyR4d616bsoDKSlLmi5eKuzKSpKe(0AuJbcD9B1samC6HajbdgjHpTg1ezE9AMB8Mzb9qGKGbJKWNwJcCmroST(TQTPGxVs2yb00dbscgmscFAnAoumwUQhbxY0dbscgmscFAnkX7XV0dbs2pgYsE8lgYyGqx)wTeadh7ysvOlgumeVgCHZyLWqjr4SimmKYiPBfEDQMfgXiUuEn4cNrYjizSP)glqnBxdGRQ2B3Uxns2zKCWwXh0R1dKC6izxkzqYjiPYizFij8P1Ogde663QLay40dbscgmscFAnQjY861m34nZc6HajbdgjHpTgf4yICyB9BvBtbVELSXcOPhcKemyKe(0A0COySCvpcUKPhcKemyKe(0AuI3JFPhcKSFmKL84xmeWXe5W263Q2McE9kzJfqJDmPkOagumeVgCHZyLWqjr4SimmKYiPBfEDQMfgXiUuEn4cNrYjiPBfEDAlwRu1UTzkVgCHZi5eKm20FJfOMTRbWvv7TB3Rgj7msoyR4d616bsoDKSlLmi5eKuzKSpKe(0AuJbcD9B1samC6HajbdgjHpTg1ezE9AMB8Mzb9qGKGbJKWNwJcCmroST(TQTPGxVs2yb00dbscgmscFAnAoumwUQhbxY0dbscgmscFAnkX7XV0dbs2pgYsE8lgkhkglx1JGlzSJjvbvXGIH41GlCgRegkjcNfHHHugjDRWRt1SWigXLYRbx4msobjJn93ybQz7AaCv1E729QrYoJKd2k(GETEGKthj7sjdsobjvgj7djHpTg1yGqx)wTeadNEiqsWGrs4tRrnrMxVM5gVzwqpeijyWij8P1OahtKdBRFRABk41RKnwan9qGKGbJKWNwJMdfJLR6rWLm9qGKGbJKWNwJs8E8l9qGK9JHSKh)IHmrMxVM5gVzwGDmPkqsyqXq8AWfoJvcdLeHZIWWqkJKUv41PAwyeJ4s51GlCgjNGKd2k(GsKCKCkKuHEXqwYJFXqfJex)ToSnRXo2XqP)l5xLvJbftQcyqXq8AWfoJvcdLeHZIWWqWNwJAkYlqSavveMpOhcmKL84xmulemC5)m2XKQkgumeVgCHZyLWqjr4Simmu6)s(vzP6rWLC9BvFWvramC(pAAAycawxBcl5XVwbj7SAKuvmKL84xmKMfgXiUyhtkjHbfdXRbx4mwjmuseolcddbFAnQMfgXiU0dbscgmsM(VKFvwQMfgXiUubFTy1i5uiPQijyWiPYiPBfEDQMfgXiUuEn4cNXqwYJFXqMI8celqvfH5dSJjLmyqXq8AWfoJvcdLeHZIWWqWNwJAkYlqSavveMpOhcmKL84xmeX7XVyhtAVyqXq8AWfoJvcdLeHZIWWqWNwJQzHrmIl9qGKGbJKkJKUv41PAwyeJ4s51GlCgdzjp(fdD0CnC(QXo2XqzUzNIJbftQcyqXqwYJFXq2X)Q5ULilgIxdUWzSsyhtQQyqXqwYJFXqcg(qwgdXRbx4mwjSJjLKWGIH41GlCgRegYsE8lgkzLs1sE8BTeAhdvcTxx7YyO0)L8RYQXoMuYGbfdXRbx4mwjmKL84xmuYkLQL843Aj0ogQeAVU2LXq3WdaZJFXoM0EXGIH41GlCgRegkjcNfHHH6djHpTg1uKxawORkALxqpei5eKm9Fj)QSu9i4sU(TQp4Qiago)hnnnmbaRRnHL84xRGKDwnsQkTxKSFKCcs2hsM(VKFvwQMfgXiUubFTy1izNrsGugjbdgjvgjDRWRt1SWigXLYRbx4ms2pgYsE8lgspcUKRFR6dUkcGHZ)rJDmPGmgumeVgCHZyLWqjr4SimmuFij8P1OMI8celqvfH5d6HajNGKkJKUv41PAwyeJ4s51GlCgj7hjbdgjHpTgvZcJyex6HajNGKWNwJAkYlal0vfTYlOhcmKL84xmKEeCjx)w1hCveadN)Jg7ys7eyqXq8AWfoJvcdLeHZIWWq9HKWNwJAkYlqSavveMpOhcKCcscFAnQPiVaXcuvry(Gk4RfRgjNcjjdsobjvgjDRWRt1SWigXLYRbx4ms2pscgms2hscFAnQMfgXiUubFTy1i5uijzqYjij8P1OAwyeJ4speiz)yil5XVyi9i4sU(TQp4Qiago)hn2XK2PyqXq8AWfoJvcdLeHZIWWqWNwJQzHrmIl9qGKtqs4tRr1SWigXLk4RfRgjNcjjjmKL84xmujagUU2Ztg4YRJDmPKlgumeVgCHZyLWqjr4SimmKYiz6xnNeMh)speyil5XVyO0VAojmp(f7ysvOlgumeVgCHZyLWqjr4SimmuFiz6)s(vzP98KbU86ubFTy1i5uijqkJKtqY0)L8RYs75jdC51PPHjayDTjSKh)AfKSZiPci5eKm9Fj)QSvbBjhj7hjbdgjvgjDRWRttIJ2YSqx75jdC51P8AWfoJHSKh)IH65jdC51XoMufuadkgIxdUWzSsyOKiCweggk9Fj)QSvbBjhdzjp(fdzkYlal0v9i4sg7ysvqvmOyiEn4cNXkHHsIWzryyO0)L8RYwfSLCKemyKuzK0TcVonjoAlZcDTNNmWLxNYRbx4mgYsE8lgQNNmWLxh7ysvGKWGIH41GlCgRegkjcNfHHHugjDRWRt1SWigXLYRbx4mscgmscFAnQMfgXiU0dbgYsE8lgQeadxx75jdC51XoMufidgumeVgCHZyLWqwYJFXqWfwR5CDy3llWqAxeKL1yivXoMuf6fdkgYsE8lgAy3llQFR6dUkcGHZ)rJH41GlCgRe2XKQaiJbfdzjp(fdL(vZjH5XVyiEn4cNXkHDSJHieC6VWMJbftQcyqXq8AWfoJvc7ysvfdkgIxdUWzSsyhtkjHbfdXRbx4mwjSJjLmyqXq8AWfoJvc7ys7fdkgYsE8lgI494xmeVgCHZyLWoMuqgdkgYsE8lgQeadxx75jdC51Xq8AWfoJvc7ys7eyqXqwYJFXqMI8celqvfH5dmeVgCHZyLWoM0ofdkgYsE8lgsZcJyexmeVgCHZyLWo2XogsrwOJFXKQAxf60UKBxvPQQkz6fdPIj2yb0yOojKdsMusesbjdsrsKe0bJKXL4fos2EbscsK5MDkoibskyYzNqWzKu)xgjTJ)xZ5msMg2cWAkAgjASmsQaifj7KU6dbXlCoJKwYJFrsqc74F1C3sKfKGIMHMrICjEHZzKKmiPL84xKSeAxtrZWqeIVffgdnnKK8I35Kh)IKK3kwow0SPHKd3j0G05ZbcFCGPP)oxh3tX843KWA(CDCtZHlp8C4MrczwX5eIVffwpN8cMKTiRNtEsUsERy5yRKx8oN84xQoUj0SPHKqmHZxywGKKliqsv7QqNIKKascYGuv7IKKVtgndnBAij50WwawJMnnKKeqsYroZzKKKz4dzzkA20qssajjzw7VGZi5n8aW84xsa20CgjfC6VxEZMh)QrYM4VijBIsWcKKCqEsukAgA20qsqs9GthNZijm3EbJKP)cBoscZaXQPij5iLycxJK7VKWWe32PGKwYJF1i5VfsmfnZsE8RMsi40FHnxDRyAYIMzjp(vtjeC6VWM3H65T)ZOzwYJF1ucbN(lS5DOEUDaU86Mh)IMnnKeAnc94DKuyrgjHpTgNrsTBUgjH52lyKm9xyZrsygiwnsABgjjemjq8UhlasgAKm)ltrZSKh)QPeco9xyZ7q9C9Ae6X7vTBUgnZsE8RMsi40FHnVd1ZjEp(fnZsE8RMsi40FHnVd1ZlbWW11EEYaxED0ml5XVAkHGt)f28oup3uKxGybQQimFGMzjp(vtjeC6VWM3H65AwyeJ4IMHMzjp(vtVHhaMh)QwpcUKRFR6dUkcGHZ)rdIOPwz3k86unlmIrCP8AWfopXsE8lvpcUKRFR6dUkcGHZ)rttdtaW6oR6eL7d(0AuJbcD9B1samC6Hyc8P1OMiZRxZCJ3mlOhIjWNwJcCmroST(TQTPGxVs2yb00dXe4tRrZHIXYv9i4sMEiMaFAnkX7XV0dr)OzwYJF10B4bG5XVDOEoSP94363QLay4GiAQv2TcVovZcJyexkVgCHZtCRWRtHnTh)w)wTeadNYRbx48el5XVu9i4sU(TQp4Qiago)hnnnmbaRNsb0ml5XVA6n8aW843oupVeadV(TQp4kH4Do5VaertDFd2k(GsK8Pit3(rZSKh)QP3WdaZJF7q98HT563Q(GReI35K)cqen19nyR4dkrYNImD7hnZsE8RMEdpamp(Td1ZlbWWRFR6dUsiENt(lar0u3xSP)glqnBxdGRk0TB3Ux9ud2k(GETEmDfOQ2B)tgSv8bLi5t1BVtCRWRtfbWW5)OReI35K)ckVgCHZOzwYJF10B4bG5XVDOEEjagE9BvFWvcX7CYFbiIM6(In93ybQz7AaCvbsQB3Ux9ud2k(GETEmDfOGC)tgSv8bLi5t1BVOzwYJF10B4bG5XVDOE(W2C9BvFWvcX7CYFbiIM6(In93ybQz7AaCfK72T7vp1GTIpOxRhtVlTt0)KbBfFqjs(uGCVtCRWRtfbWW5)OReI35K)ckVgCHZOzwYJF10B4bG5XVDOE(W2C9BvFWvcX7CYFbiIM6(In93ybQz7AaCLC72T7vp1GTIpOxRhtxbQQ9pzWwXhuIKpvV9IMzjp(vtVHhaMh)2H65gde663QLay4GiAQv2TcVovZcJyexkVgCHZtIn93ybQz7AaCv1E729Q78GTIpOxRhtVlLmtuUp4tRrngi01VvlbWWPhcWGHpTg1ezE9AMB8Mzb9qagm8P1OahtKdBRFRABk41RKnwan9qagm8P1O5qXy5QEeCjtpeGbdFAnkX7XV0dr)OzwYJF10B4bG5XVDOEoWXe5W263Q2McE9kzJfqdIOPwz3k86unlmIrCP8AWfopj20FJfOMTRbWvv7TB3RUZd2k(GETEm9UuYmr5(GpTg1yGqx)wTeadNEiadg(0AutK51RzUXBMf0dbyWWNwJcCmroST(TQTPGxVs2yb00dbyWWNwJMdfJLR6rWLm9qagm8P1OeVh)spe9JMzjp(vtVHhaMh)2H655qXy5QEeCjdIOPwz3k86unlmIrCP8AWfopXTcVoTfRvQA32mLxdUW5jXM(BSa1SDnaUQAVD7E1DEWwXh0R1JP3LsMjk3h8P1Ogde663QLay40dbyWWNwJAImVEnZnEZSGEiadg(0AuGJjYHT1VvTnf86vYglGMEiadg(0A0COySCvpcUKPhcWGHpTgL494x6HOF0ml5XVA6n8aW843oup3ezE9AMB8MzbiIMALDRWRt1SWigXLYRbx48Kyt)nwGA2UgaxvT3UDV6opyR4d616X07sjZeL7d(0AuJbcD9B1samC6Hamy4tRrnrMxVM5gVzwqpeGbdFAnkWXe5W263Q2McE9kzJfqtpeGbdFAnAoumwUQhbxY0dbyWWNwJs8E8l9q0pAML84xn9gEayE8BhQNxmsC936W2SgertTYUv41PAwyeJ4s51GlCEYGTIpOejFkf6fndnBAijiPEWPJZzKKvKfKyK0JlJK(Grsl5VajdnsAkArXGlmfnZsE8RwTD8VAUBjYIMzjp(v3H65cg(qwgnZsE8RUd1ZtwPuTKh)wlH2bXAxwD6)s(vz1OzwYJF1DOEEYkLQL843Aj0oiw7YQVHhaMh)IMnnKKC(5selasc9ojJKPHjaynAML84xDhQNRhbxY1Vv9bxfbWW5)Obr0u3h8P1OMI8cWcDvrR8c6Hys6)s(vzP6rWLC9BvFWvramC(pAAAycawxBcl5XVwPZQvL2B)t6l9Fj)QSunlmIrCPc(AXQ7mqkdgSYUv41PAwyeJ4s51GlCUF0ml5XV6oupxpcUKRFR6dUkcGHZ)rdIOPUp4tRrnf5fiwGQkcZh0dXeLDRWRt1SWigXLYRbx4C)GbdFAnQMfgXiU0dXe4tRrnf5fGf6QIw5f0dbAML84xDhQNRhbxY1Vv9bxfbWW5)Obr0u3h8P1OMI8celqvfH5d6Hyc8P1OMI8celqvfH5dQGVwS6PiZeLDRWRt1SWigXLYRbx4C)Gb3h8P1OAwyeJ4sf81IvpfzMaFAnQMfgXiU0dr)OzwYJF1DOEEjagUU2Ztg4YRdIOPg(0AunlmIrCPhIjWNwJQzHrmIlvWxlw9uKeAML84xDhQNN(vZjH5XVGiAQvo9RMtcZJFPhc0ml5XV6oupVNNmWLxhertDFP)l5xLL2Ztg4YRtf81Ivpfqkpj9Fj)QS0EEYaxEDAAycawxBcl5XVwPZkmj9Fj)QSvbBjVFWGv2TcVonjoAlZcDTNNmWLxNYRbx4mAML84xDhQNBkYlal0v9i4sgertD6)s(vzRc2soAML84xDhQN3Ztg4YRdIOPo9Fj)QSvbBjhmyLDRWRttIJ2YSqx75jdC51P8AWfoJMzjp(v3H65Lay46AppzGlVoiIMALDRWRt1SWigXLYRbx4myWWNwJQzHrmIl9qGMzjp(v3H65WfwR5CDy3llaH2fbzzTAvrZSKh)Q7q98HDVSO(TQp4Qiago)hnAML84xDhQNN(vZjH5XVOzOzwYJF100)L8RYQv3cbdx(pdIOPg(0AutrEbIfOQIW8b9qGMzjp(vtt)xYVkRUd1Z1SWigXfertD6)s(vzP6rWLC9BvFWvramC(pAAAycawxBcl5XVwPZQvfnZsE8RMM(VKFvwDhQNBkYlqSavveMpar0udFAnQMfgXiU0dbyWP)l5xLLQzHrmIlvWxlw9uQcgSYUv41PAwyeJ4s51GlCgnZsE8RMM(VKFvwDhQNt8E8liIMA4tRrnf5fiwGQkcZh0dbAML84xnn9Fj)QS6oup)O5A48vdIOPg(0AunlmIrCPhcWGv2TcVovZcJyexkVgCHZyinbNWKcYGm2Xogd]] )


end
