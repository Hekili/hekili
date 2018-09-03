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
            charges = function () return ( level < 116 and equipped.saruans_resolve ) and 2 or nil end,
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
            charges = function () return ( level < 116 and equipped.saruans_resolve ) and 2 or nil end,
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
            gcd = "off",

            interrupt = true,
            
            startsCombat = true,
            texture = 236265,

            nobuff = "shield_of_the_righteous_icd",

            readyTime = function () return gcd.remains end,            
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
    
        package = "Protection Paladin",
    } )


    spec:RegisterPack( "Protection Paladin", 20180902.2245, [[dCKkuaqisvEKQO2ePuFsvinkuvCkiuVcsmljKBjHYUe6xq0WufCmiPLbbpJuPMgQQCnsLSnuvvFtcv14ufPZbHK1bHyEKsCpuL9PkIdQkuTqvPEiesnrjujxucv5JOQk1jrvvSsi1mrvvYnvfI2Pe1qjvSusj9ujnvjYvLqL6RsOI2Rs)fLgSihMYIb6XKmzrDzIndYNrLrd40kwnPQEnQknBb3gu7wQFRYWrXXLqfwoINd10P66QQTRk57KIXRkeoVQqz(sW(r6f1T0wZMlBzeEa1N(aI6beIiGGUqq38BR(JXiBLXu814KT2gSSvDiNlkFUMM0XcwE6TYypw4S8wAR47tuYwbCNbJiirYnoWhmQoyK4b(hmFUwrmihjEGvibdhisqiRyz5fsgYbnbbJuhIOvBYyK6OvwDSGLNMvhY5IYNRJ4bwTvW)eC(tVGBnBUSLr4buF6diQhqiIac66b(X)B1(oWr2ADGr0Bnly1wFMM0HCUO85AAshly5PPOFMMaCNbJiirYnoWhmQoyK4b(hmFUwrmihjEGvibdhisqiRyz5fsgYbnbbJuhIOvBYyK6OvwDSGLNMvhY5IYNRJ4bwrr)mnvfgxGbfcnHqr0ecpG6tPPIrtO(aI8aQ0KopskAk6NPjenG1CcMI(zAQy00JNZsMM0Qa(5Re3AyWoElTv1DH8PPXBPTmQBPTkTbgK8(ERkY4czSTc(HGI2lP5MMJvdXCG4NzRMYNR3k0qeWWD513YiSL2Q0gyqY77TQiJlKX2Q6Uq(00rmWiHm7bX6aclz4aC5(4OcWiCcMfIykFU2c00t4rtiSvt5Z1BfleJbyGxFlR7T0wL2adsEFVvfzCHm2wb)qqrSqmgGbo(zOPcfOj1DH8PPJyHymadCKiW20yAsl0ec0uHc0KE0KBbP9iwigdWahL2adsERMYNR3Q9sAUP5y1qmhy9Tm)2sBvAdmi599wvKXfYyBf8dbfTxsZnnhRgI5aXpZwnLpxVvMZNRxFlRRT0wL2adsEFVvfzCHm2wb)qqrSqmgGbo(zOPcfOj9Oj3cs7rSqmgGbokTbgK8wnLpxV1pwyhxGXRV(wZcK9d(wAlJ6wARMYNR3Q99J1C3u8DRsBGbjVVxFlJWwARMYNR3kra)8v2Q0gyqY7713Y6ElTvPnWGK33B1u(C9wvwiWAkFUMnmyFRHb7STblBvDxiFAA86Bz(TL2Q0gyqY77TQiJlKX2kFOjWpeu0EjnNqWSVSWrIFgAsBAsDxiFA6igyKqM9GyDaHLmCaUCFCubyeobZcrmLpxBbA6j8OjeI6IMqmnPnnXhAsDxiFA6iwigdWahjcSnnMMEcnXPY0uHc0KE0KBbP9iwigdWahL2adsMMq8wnLpxVvmWiHm7bX6aclz4aC5(413Y6AlTvPnWGK33BvrgxiJTv(qtGFiOO9sAUP5y1qmhi(zOjTPj9Oj3cs7rSqmgGbokTbgKmnHyAQqbAc8dbfXcXyag44NHM0MMa)qqr7L0CcbZ(Ychj(z2QP856TIbgjKzpiwhqyjdhGl3hV(wM)3sBvAdmi599wvKXfYyBLp0e4hckAVKMBAowneZbIFgAsBAc8dbfTxsZnnhRgI5arIaBtJPjTqt8JM0MM0JMCliThXcXyag4O0gyqY0eIPPcfOj(qtGFiOiwigdWahjcSnnMM0cnXpAsBAc8dbfXcXyag44NHMq8wnLpxVvmWiHm7bX6aclz4aC5(413Yf)T0wL2adsEFVvfzCHm2wb)qqrSqmgGbo(zOjTPjWpeueleJbyGJeb2MgttAHM09wnLpxV1WWb4yw9)zoyP913YpDlTvPnWGK33BvrgxiJTv9Oj11yrrmFUo(z2QP856TQUglkI5Z1RVLruBPTkTbgK8(ERkY4czSTYhAsDxiFA6O()mhS0EKiW20yAsl0eNkttAttQ7c5tth1)N5GL2JkaJWjywiIP85AlqtpHMqLM0MMu3fYNMMLiMYPjettfkqt6rtUfK2JkYhBzHGz1)N5GL2JsBGbjVvt5Z1Bv)FMdwAF9TmQpSL2Q0gyqY77TQiJlKX2Q6Uq(00SeXu(wnLpxVv7L0CcbZIbgjKxFlJkQBPTkTbgK8(ERkY4czSTQUlKpnnlrmLttfkqt6rtUfK2JkYhBzHGz1)N5GL2JsBGbjVvt5Z1Bv)FMdwAF9TmQiSL2Q0gyqY77TQiJlKX2QE0KBbP9iwigdWahL2adsMMkuGMa)qqrSqmgGbo(z2QP856TggoahZQ)pZblTV(wgvDVL2Q0gyqY77TAkFUERGbbJLmlGbdlKTIDYWxbVvewFlJk)2sB1u(C9wbmyyHWEqSoGWsgoaxUpERsBGbjVVxFlJQU2sB1u(C9wvxJffX856TkTbgK8(E913kdruhmO5BPTmQBPTkTbgK8(E9TmcBPTkTbgK8(E9TSU3sBvAdmi5996Bz(TL2Q0gyqY7713Y6AlTvt5Z1BL5856TkTbgK8(E9Tm)VL2QP856TggoahZQ)pZblTVvPnWGK33RVLl(BPTAkFUER2lP5MMJvdXCGTkTbgK8(E9T8t3sB1u(C9wXcXyag4TkTbgK8(E91xFRVecEUElJWdO(0hE6dOgrq38txBvJr6P5WBT48X1Az(tz(BeHMOPsacnnWmhXPjOJqtpAwGSFWFuAIifh)HizAcFWcnzF)GnxY0KcWAobhPO5VMwOjureAQ4UXFgMJ4sMMmLpxttpQ99J1C3u89rJu0u08hyMJ4sMM0nnzkFUMMcd2Xrk6TYqoOjiB9zAshY5IYNRPjDSGLNMI(zAcWDgmIGej34aFWO6GrIh4FW85AfXGCK4bwHemCGibHSILLxizih0eemsDiIwTjJrQJwz1XcwEAwDiNlkFUoIhyff9Z0uvyCbgui0ecfrti8aQpLMkgnH6diYdOst68iPOPOFMMq0awZjyk6NPPIrtpEolzAsRc4NVsKIMI(zAQ49ie13LmnbkqhrOj1bdAonbkCtJJ00JRucJJPP(6IbyeyOFGMmLpxJPPRdpwKI2u(CnoYqe1bdAopOGH5lfTP85ACKHiQdg0Cu4He6UmfTP85ACKHiQdg0Cu4H0(CWs7Mpxtr)mnvBJbdConrSjttGFiijtty3CmnbkqhrOj1bdAonbkCtJPjRZ0edrkgZ5(0C00GPP81sKI2u(CnoYqe1bdAok8qIBJbdCol2nhtrBkFUghziI6GbnhfEizoFUMI2u(CnoYqe1bdAok8qggoahZQ)pZblTtrBkFUghziI6GbnhfEiTxsZnnhRgI5au0MYNRXrgIOoyqZrHhsSqmgGbMIMI(zAQ49ie13LmnjVeYJrt(al0Kdi0KP8JqtdMMSx2emWGePOnLpxJ5zF)yn3nfFPOnLpxJrHhsIa(5RqrBkFUgJcpKkleynLpxZggSxuBWcp1DH8PPXu0pttfxFyMP5OP65ALMuagHtWu0MYNRXOWdjgyKqM9GyDaHLmCaUCFCrdep(a(HGI2lP5ecM9Lfos8ZOT6Uq(00rmWiHm7bX6aclz4aC5(4OcWiCcMfIykFU2cpHhcrDHyT5J6Uq(00rSqmgGboseyBA8t4u5cf0ZTG0EeleJbyGJsBGbjJykAt5Z1yu4HedmsiZEqSoGWsgoaxUpUObIhFa)qqr7L0CtZXQHyoq8ZOTEUfK2JyHymadCuAdmizexOa4hckIfIXamWXpJ2GFiOO9sAoHGzFzHJe)mu0MYNRXOWdjgyKqM9GyDaHLmCaUCFCrdep(a(HGI2lP5MMJvdXCG4NrBWpeu0Ejn30CSAiMdejcSnnwl8tB9CliThXcXyag4O0gyqYiUqb(a(HGIyHymadCKiW20yTWpTb)qqrSqmgGbo(zqmfTP85Amk8qggoahZQ)pZblTx0aXd8dbfXcXyag44NrBWpeueleJbyGJeb2MgRfDtrBkFUgJcpKQRXIIy(CDrdep9uxJffX8564NHI2u(CngfEi1)N5GL2lAG4Xh1DH8PPJ6)ZCWs7rIaBtJ1cNkRT6Uq(00r9)zoyP9OcWiCcMfIykFU2cpbvTv3fYNMMLiMYrCHc65wqApQiFSLfcMv)FMdwApkTbgKmfTP85Amk8qAVKMtiywmWiHCrdep1DH8PPzjIPCkAt5Z1yu4Hu)FMdwAVObIN6Uq(00SeXuEHc65wqApQiFSLfcMv)FMdwApkTbgKmfTP85Amk8qggoahZQ)pZblTx0aXtp3cs7rSqmgGbokTbgKCHcGFiOiwigdWah)mu0MYNRXOWdjyqWyjZcyWWcPiStg(kyEiqrBkFUgJcpKagmSqypiwhqyjdhGl3htrBkFUgJcpKQRXIIy(CnfnfTP85ACuDxiFAAmpOHiGH7Yfnq8a)qqr7L0CtZXQHyoq8ZqrBkFUghv3fYNMgJcpKyHymadCrdep1DH8PPJyGrcz2dI1bewYWb4Y9XrfGr4emleXu(CTfEcpeOOnLpxJJQ7c5ttJrHhs7L0CtZXQHyoqrdepWpeueleJbyGJFMcfu3fYNMoIfIXamWrIaBtJ1ccfkONBbP9iwigdWahL2adsMI2u(CnoQUlKpnngfEizoFUUObIh4hckAVKMBAowneZbIFgkAt5Z14O6Uq(00yu4H8Jf2XfyCrdepWpeueleJbyGJFMcf0ZTG0EeleJbyGJsBGbjVvmJO2Y8p)V(67ca]] )


end
