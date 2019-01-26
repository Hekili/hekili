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


    spec:RegisterPack( "Protection Paladin", 20181022.2059, [[dOKTNaqicQhbcztksFceugLIWPueTkqGxrinlPQ6wsfQDH0VuugMuPJrqwgb6zqvPPbvvxtQOTbc13ajvJdQkoNuvY6ajX8KQ09iu7tQcheeKwib8qqsQjkvLsUiii8rPQu4KGKKvQOAMsvPOBkvLQ2ji1pbbrdvQGLkvipfWubrxvQkv8vPQuP9c5VcgmLomPfd0JfAYI6YO2Su(SknAfoTKvlvrVgKy2ICBqTBL(TQgouoUuvk1Yj65umDQUUk2oH47qvgVuvCEqsz9GGQ5dv2pIrcHGebKvNrqlyxHWhH6kOGub72zF1TVqaoudJrayAek6LraRcZiGoiFNJE9lX2bnP5Araykul9AgbjcW8hzKrad3XmqLzZULpoG04dpZuWNK61VrP28zMcoodm9GZaBAhNzrMHj)wLyZSoi5osRSzwh6Oqh0KMRn0b57C0RFPMcoIaapvYHQweiciRoJGwWUcHpc1vqbPc2TZ(QleJa0JpEjcaOGHQraJkN5fbIaYSjIaGiITdY35Ox)sSDqtAUwYCiIyhUJzGkZMDlFCaPXhEMPGpj1RFJsT5ZmfCCgy6bNb20ooZImdt(TkXMzDqYDKwzZSo0rHoOjnxBOdY35Ox)snfCKmhIiwiKr)bzjXkOG9tSc2vi8Hy7yIfFGkDIpeBh67jZjZHiIfQEO7LnK5qeX2XeleAoZzITJyWduykcivg3GGebaxEDvV(fbjcAHqqIa4vbtCgjaciklNLLIaeMyDnXRtnSuXgfmLxfmXzIDkXQrV(LAgfNYHVf8bhK1D48Fm04qLx2qS9GyfKyNsSctStqSGNwJQ8TmHVfs1D40dgXoLybpTgvLzE9qMB8Mzj9GrStjwWtRrVhvMlDdFlOBS41dqP2RHEWi2Pel4P1O5sKA5GzuCktpye7uIf80AuS3RFPhmIDseGg96xeGzuCkh(wWhCqw3HZ)XGCe0cIGebWRcM4msaequwollfbimX6AIxNAyPInkykVkyIZe7uI11eVofunE9B4BHuDhoLxfmXzIDkXQrV(LAgfNYHVf8bhK1D48Fm04qLx2qS9sScHa0Ox)IaavJx)g(wiv3HJCe04lcseaVkyIZibqarz5SSueWee7G1KpOyrNy7LyXFxIDseGg96xeqQUdp8TGp4aM8Do6Ve5iOXpcseaVkyIZibqarz5SSueWee7G1KpOyrNy7LyXFxIDseGg96xeWq3C4BbFWbm57C0FjYrq3jcseaVkyIZibqarz5SSueWeeBTXhU2BiRW6Ldc1TB3UWgITxIDWAYhuyTpeleqScrfStIDsIDkXoyn5dkw0j2Ej2o7KyNsSUM41PY6oC(pMaM8Do6VKYRcM4mcqJE9lciv3Hh(wWhCat(oh9xICe0qmcseaVkyIZibqarz5SSueWeeBTXhU2BiRW6LdcHVD72f2qS9sSdwt(GcR9HyHaIviketStsStj2bRjFqXIoX2lX2zNian61ViGuDhE4BbFWbm57C0FjYrqd1rqIa4vbtCgjaciklNLLIaMGyRn(W1EdzfwVCaI72TlSHy7LyhSM8bfw7dXcbeBxkuNyNKyNsSdwt(GIfDITxIfI7KyNsSUM41PY6oC(pMaM8Do6VKYRcM4mcqJE9lcyOBo8TGp4aM8Do6Ve5iOXheKiaEvWeNrcGaIYYzzPiGji2AJpCT3qwH1lh6RUD7cBi2Ej2bRjFqH1(qSqaXkevqIDsIDkXoyn5dkw0j2Ej2o7ebOrV(fbm0nh(wWhCat(oh9xICe09fcseaVkyIZibqarz5SSueGWeRRjEDQHLk2OGP8QGjotStj2AJpCT3qwH1lheSZUDHneBpi2bRjFqH1(qSqaX2LIFIDkXkmXobXcEAnQY3Ye(wiv3HtpyeloCel4P1OQmZRhYCJ3mlPhmIfhoIf80A07rL5s3W3c6glE9auQ9AOhmIfhoIf80A0CjsTCWmkoLPhmIfhoIf80AuS3RFPhmIDseGg96xeGY3Ye(wiv3HJCe0c1fbjcGxfmXzKaiGOSCwwkcqyI11eVo1WsfBuWuEvWeNj2PeBTXhU2BiRW6Ldc2z3UWgIThe7G1KpOWAFiwiGy7sXpXoLyfMyNGybpTgv5BzcFlKQ7WPhmIfhoIf80AuvM51dzUXBML0dgXIdhXcEAn69OYCPB4BbDJfVEak1En0dgXIdhXcEAnAUePwoygfNY0dgXIdhXcEAnk271V0dgXojcqJE9lc4EuzU0n8TGUXIxpaLAVgKJGwiHqqIa4vbtCgjaciklNLLIaeMyDnXRtnSuXgfmLxfmXzIDkX6AIxN2QvtbJRBMYRcM4mXoLyRn(W1EdzfwVCqWo72f2qS9GyhSM8bfw7dXcbeBxk(j2PeRWe7eel4P1OkFlt4BHuDho9GrS4WrSGNwJQYmVEiZnEZSKEWiwC4iwWtRrVhvMlDdFlOBS41dqP2RHEWiwC4iwWtRrZLi1YbZO4uMEWiwC4iwWtRrXEV(LEWi2jraA0RFra5sKA5GzuCkJCe0cjicseaVkyIZibqarz5SSueGWeRRjEDQHLk2OGP8QGjotStj2AJpCT3qwH1lheSZUDHneBpi2bRjFqH1(qSqaX2LIFIDkXkmXobXcEAnQY3Ye(wiv3HtpyeloCel4P1OQmZRhYCJ3mlPhmIfhoIf80A07rL5s3W3c6glE9auQ9AOhmIfhoIf80A0CjsTCWmkoLPhmIfhoIf80AuS3RFPhmIDseGg96xeGkZ86Hm34nZsKJGwi8fbjcGxfmXzKaiGOSCwwkcqyI11eVo1WsfBuWuEvWeNj2Pe7G1KpOyrNy7LyfQteGg96xeqsHAHFddDZgKJCeq8)u(XBniirqlecseaVkyIZibqarz5SSuea4P1OQi8ER9gWtQ(GEWqaA0RFraTsYGP)ZihbTGiira8QGjoJeabeLLZYsraX)t5hVLAgfNYHVf8bhK1D48Fm04qLx2eAsn61VAIy7HyIvqeGg96xeGHLk2OGrocA8fbjcGxfmXzKaiGOSCwwkca80AudlvSrbtpyeloCeB8)u(XBPgwQyJcMkzyTwdX2lXkiXIdhXkmX6AIxNAyPInkykVkyIZian61ViaveEV1Ed4jvFGCe04hbjcGxfmXzKaiGOSCwwkci(Fk)4TuZO4uo8TGp4GSUdN)JHghQ8YMqtQrV(vteBVIj2Uian61Viaq141VHVfs1D4ihbDNiira8QGjoJeabeLLZYsraGNwJQIW7T2BapP6d6bdbOrV(fbG9E9lYrqdXiira8QGjoJeabeLLZYsraGNwJAyPInky6bJyXHJyfMyDnXRtnSuXgfmLxfmXzeGg96xeWXWHYzydYrqd1rqIa4vbtCgjacyvygbivi88zHIjaw3GKZbWJ7)Ia0Ox)IaKkeE(SqXeaRBqY5a4X9FroYrazUPNKJGebTqiiraA0RFra6X)G6UgHccGxfmXzKaihbTGiiraA0RFrasg8afgbWRcM4msaKJGgFrqIa4vbtCgjacqJE9lciQPuqJE9BivghbKkJhwfMraWLxx1RFrocA8JGebWRcM4msaeGg96xequtPGg963qQmocivgpSkmJaI)NYpERb5iO7ebjcGxfmXzKaiGOSCwwkcycIf80AuveEVS0eertVKEWi2PeB8)u(XBPMrXPC4BbFWbzDho)hdnou5LnHMuJE9RMi2EiMyfK2jXojXoLyNGyJ)NYpEl1WsfBuWujdR1Ai2EqS3yMyXHJyfMyDnXRtnSuXgfmLxfmXzIDseGg96xeGzuCkh(wWhCqw3HZ)XGCe0qmcseaVkyIZibqarz5SSueWeel4P1OQi8ER9gWtQ(GEWi2PeRWeRRjEDQHLk2OGP8QGjotStsS4WrSGNwJAyPInky6bJyNsSGNwJQIW7LLMGiA6L0dgcqJE9lcWmkoLdFl4doiR7W5)yqocAOocseaVkyIZibqarz5SSueWeel4P1OQi8ER9gWtQ(GEWi2Pel4P1OQi8ER9gWtQ(GkzyTwdX2lXIFIDkXkmX6AIxNAyPInkykVkyIZe7KeloCe7eel4P1OgwQyJcMkzyTwdX2lXIFIDkXcEAnQHLk2OGPhmIDseGg96xeGzuCkh(wWhCqw3HZ)XGCe04dcseaVkyIZibqarz5SSuea4P1OgwQyJcMEWi2Pel4P1OgwQyJcMkzyTwdX2lXIVian61ViGuDhUj0Zt(cZRJCe09fcseaVkyIZibqarz5SSueGWeB8xdhLQx)spyian61ViG4VgokvV(f5iOfQlcseaVkyIZibqarz5SSueWeeB8)u(XBP98KVW86ujdR1Ai2Ej2BmtStj24)P8J3s75jFH51PXHkVSj0KA0RF1eX2dIviIDkXg)pLF82GK1OtStsS4WrSctSUM41Pr5XOzwAc98KVW86uEvWeNraA0RFra98KVW86ihbTqcHGebWRcM4msaequwollfbe)pLF82GK1OJa0Ox)Iaur49YstWmkoLrocAHeebjcGxfmXzKaiGOSCwwkci(Fk)4TbjRrNyXHJyfMyDnXRtJYJrZS0e65jFH51P8QGjoJa0Ox)Ia65jFH51rocAHWxeKiaEvWeNrcGaIYYzzPiaHjwxt86udlvSrbt5vbtCMyXHJybpTg1WsfBuW0dgcqJE9lciv3HBc98KVW86ihbTq4hbjcGxfmXzKaian61ViaWeBmComuyywIamUSGcBqacICe0c1jcseGg96xeWqHHzz4BbFWbzDho)hdcGxfmXzKaihbTqqmcseGg96xeq8xdhLQx)Ia4vbtCgjaYrocatYXhguDeKiOfcbjcGxfmXzKaihbTGiira8QGjoJea5iOXxeKiaEvWeNrcGCe04hbjcGxfmXzKaihbDNiiraA0RFrayVx)Ia4vbtCgjaYrqdXiiraA0RFraP6oCtONN8fMxhbWRcM4msaKJGgQJGebOrV(fbOIW7T2BapP6deaVkyIZibqocA8bbjcqJE9lcWWsfBuWiaEvWeNrcGCKJCeGiS0u)IGwWUcHpD7RU9fvWUc1jcapvU1EniG(UqODe0qvq33aQqSelKdMylySx6eB7LelewMB6j5qyeRK7BFkjNjwZdZeRE8hwDotSXHUx2qjZ7BwltScbvi2(oR5GH9sNZeRg96xIfctp(hu31iuGWOK5K5qvWyV05mXIFIvJE9lXMkJBOK5iadghrqdXqmcat(TkXiaiIy7G8Do61VeBh0KMRLmhIi2H7ygOYSz3YhhqA8HNzk4ts963OuB(mtbhNbMEWzGnTJZSiZWKFRsSzwhKChPv2mRdDuOdAsZ1g6G8Do61VutbhjZHiIfcz0FqwsScky)eRGDfcFi2oMyXhOsN4dX2H(EYCYCiIyHQh6EzdzoerSDmXcHMZCMy7ig8afMsMtMdreleI(WXJZzIfKBVKj24ddQoXcY3AnuIfcngzm3qS7VD8qLWTtIy1Ox)Ai2FtqnkzUg96xdftYXhguDXTKAGczUg96xdftYXhguDrfpR9FMmxJE9RHIj54ddQUOINPNlmVU61VK5qeXcSkMz8oXk1ktSGNwJZeRXv3qSGC7LmXgFyq1jwq(wRHy1ntSysUJXE3R9sSLHyZ)YuYCn61VgkMKJpmO6IkEMzvmZ49GXv3qMRrV(1qXKC8HbvxuXZWEV(LmxJE9RHIj54ddQUOINLQ7WnHEEYxyEDYCn61VgkMKJpmO6IkEMkcV3AVb8KQpiZ1Ox)AOyso(WGQlQ4zgwQyJcMmNmhIiwie9HJhNZellclHAeRxWmX6dMy1O)sITmeRkIwjfmXuYCn61VgX6X)G6UgHczUg96xJOINjzWduyYCn61VgrfplQPuqJE9BivgV)vHzXWLxx1RFjZ1Ox)Aev8SOMsbn61VHuz8(xfMfh)pLF8wdzoerS9ToWy1EjwG37iInou5LnK5A0RFnIkEMzuCkh(wWhCqw3HZ)X0F1epb4P1OQi8EzPjiIMEj9Gnn(Fk)4TuZO4uo8TGp4GSUdN)JHghQ8YMqtQrV(vt9qSG0oNC6eX)t5hVLAyPInkyQKH1An94gZ4WjSRjEDQHLk2OGP8QGjopjzUg96xJOINzgfNYHVf8bhK1D48Fm9xnXtaEAnQkcV3AVb8KQpOhSPc7AIxNAyPInkykVkyIZtIdh4P1OgwQyJcMEWMcEAnQkcVxwAcIOPxspyK5A0RFnIkEMzuCkh(wWhCqw3HZ)X0F1epb4P1OQi8ER9gWtQ(GEWMcEAnQkcV3AVb8KQpOsgwR10l(NkSRjEDQHLk2OGP8QGjopjoCtaEAnQHLk2OGPsgwR10l(NcEAnQHLk2OGPhSjjZ1Ox)Aev8SuDhUj0Zt(cZR3F1edEAnQHLk2OGPhSPGNwJAyPInkyQKH1An9IVK5A0RFnIkEw8xdhLQx)2F1elC8xdhLQx)spyK5A0RFnIkEwpp5lmVE)vt8eX)t5hVL2Zt(cZRtLmSwRP3Bmpn(Fk)4T0EEYxyEDACOYlBcnPg96xn1dHMg)pLF82GK1OpjoCc7AIxNgLhJMzPj0Zt(cZRt5vbtCMmxJE9RruXZur49YstWmkoL7VAIJ)NYpEBqYA0jZ1Ox)Aev8SEEYxyE9(RM44)P8J3gKSgDC4e21eVonkpgnZstONN8fMxNYRcM4mzUg96xJOINLQ7WnHEEYxyE9(RMyHDnXRtnSuXgfmLxfmXzC4apTg1WsfBuW0dgzUg96xJOINbMyJHZHHcdZY(nUSGcBelizUg96xJOINnuyywg(wWhCqw3HZ)XqMRrV(1iQ4zXFnCuQE9lzozUg96xdn(Fk)4TgXTsYGP)Z9xnXGNwJQIW7T2BapP6d6bJmxJE9RHg)pLF8wJOINzyPInk4(RM44)P8J3snJIt5W3c(GdY6oC(pgACOYlBcnPg96xn1dXcsMRrV(1qJ)NYpERruXZur49w7nGNu9r)vtm4P1OgwQyJcMEWWHl(Fk)4TudlvSrbtLmSwRPxbXHtyxt86udlvSrbt5vbtCMmxJE9RHg)pLF8wJOINbQgV(n8TqQUdV)Qjo(Fk)4TuZO4uo8TGp4GSUdN)JHghQ8YMqtQrV(vt9kUlzUg96xdn(Fk)4Tgrfpd7963(RMyWtRrvr49w7nGNu9b9GrMRrV(1qJ)NYpERruXZogouodB6VAIbpTg1WsfBuW0dgoCc7AIxNAyPInkykVkyIZK5A0RFn04)P8J3Aev8SJHdLZW9VkmlwQq45ZcftaSUbjNdGh3)LmNmxJE9RHcxEDvV(vSzuCkh(wWhCqw3HZ)X0F1elSRjEDQHLk2OGP8QGjopvJE9l1mkoLdFl4doiR7W5)yOXHkVSPhcov4japTgv5BzcFlKQ7WPhSPGNwJQYmVEiZnEZSKEWMcEAn69OYCPB4BbDJfVEak1En0d2uWtRrZLi1YbZO4uMEWMcEAnk271V0d2KK5A0RFnu4YRR61VIkEgOA863W3cP6o8(RMyHDnXRtnSuXgfmLxfmX5PUM41PGQXRFdFlKQ7WP8QGjopvJE9l1mkoLdFl4doiR7W5)yOXHkVSPxHiZ1Ox)AOWLxx1RFfv8SuDhE4BbFWbm57C0Fz)vt8edwt(GIf9EXF3jjZ1Ox)AOWLxx1RFfv8SHU5W3c(GdyY35O)Y(RM4jgSM8bfl69I)UtsMRrV(1qHlVUQx)kQ4zP6o8W3c(GdyY35O)Y(RM4jQn(W1EdzfwVCqOUD72f207G1KpOWAFGaHOc25KthSM8bfl692zNtDnXRtL1D48Fmbm57C0FjLxfmXzYCn61VgkC51v96xrfplv3Hh(wWhCat(oh9x2F1eprTXhU2BiRW6LdcHVD72f207G1KpOWAFGaHOq8KthSM8bfl692zNK5A0RFnu4YRR61VIkE2q3C4BbFWbm57C0Fz)vt8e1gF4AVHScRxoaXD72f207G1KpOWAFGGUuO(KthSM8bfl69cXDo11eVovw3HZ)XeWKVZr)LuEvWeNjZ1Ox)AOWLxx1RFfv8SHU5W3c(GdyY35O)Y(RM4jQn(W1EdzfwVCOV62TlSP3bRjFqH1(abcrfCYPdwt(GIf9E7StYCn61VgkC51v96xrfpt5BzcFlKQ7W7VAIf21eVo1WsfBuWuEvWeNNwB8HR9gYkSE5GGD2TlSPhdwt(GcR9bc6sX)uHNa80AuLVLj8TqQUdNEWWHd80AuvM51dzUXBML0dgoCGNwJEpQmx6g(wq3yXRhGsTxd9GHdh4P1O5sKA5GzuCktpy4WbEAnk271V0d2KK5A0RFnu4YRR61VIkE29OYCPB4BbDJfVEak1En9xnXc7AIxNAyPInkykVkyIZtRn(W1EdzfwVCqWo72f20JbRjFqH1(abDP4FQWtaEAnQY3Ye(wiv3Htpy4WbEAnQkZ86Hm34nZs6bdhoWtRrVhvMlDdFlOBS41dqP2RHEWWHd80A0CjsTCWmkoLPhmC4apTgf796x6bBsYCn61VgkC51v96xrfplxIulhmJIt5(RMyHDnXRtnSuXgfmLxfmX5PUM41PTA1uW46MP8QGjopT24dx7nKvy9Ybb7SBxytpgSM8bfw7de0LI)Pcpb4P1OkFlt4BHuDho9GHdh4P1OQmZRhYCJ3mlPhmC4apTg9EuzU0n8TGUXIxpaLAVg6bdhoWtRrZLi1YbZO4uMEWWHd80AuS3RFPhSjjZ1Ox)AOWLxx1RFfv8mvM51dzUXBML9xnXc7AIxNAyPInkykVkyIZtRn(W1EdzfwVCqWo72f20JbRjFqH1(abDP4FQWtaEAnQY3Ye(wiv3Htpy4WbEAnQkZ86Hm34nZs6bdhoWtRrVhvMlDdFlOBS41dqP2RHEWWHd80A0CjsTCWmkoLPhmC4apTgf796x6bBsYCn61VgkC51v96xrfplPqTWVHHUzt)vtSWUM41PgwQyJcMYRcM480bRjFqXIEVc1jYrocba]] )


end
