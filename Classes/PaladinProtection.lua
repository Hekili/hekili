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

        final_stand = 22705, -- 204077
        unbreakable_spirit = 21795, -- 114154
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
        sacred_duty = 92, -- 216853
        judgments_of_the_pure = 93, -- 216860
        guarded_by_the_light = 97, -- 216855
        guardian_of_the_forgotten_queen = 94, -- 228049
    } )

    -- Auras
    spec:RegisterAuras( {
        aegis_of_light = {
            id = 204150,
        },
        ardent_defender = {
            id = 31850,
        },
        avenging_wrath = {
            id = 31884,
        },
        blinding_light = {
            id = 115750,
        },
        consecration = {
            id = 26573,
        },
        divine_shield = {
            id = 642,
        },
        grand_crusader = {
            id = 85043,
        },
        guardian_of_ancient_kings = {
            id = 86659,
        },
        heart_of_the_crusader = {
            id = 32223,
        },
        retribution_aura = {
            id = 203797,
            duration = 3600,
            max_stack = 1,
        },
        seraphim = {
            id = 152262,
        },
    } )

    -- Abilities
    spec:RegisterAbilities( {
        aegis_of_light = {
            id = 204150,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135909,
            
            handler = function ()
            end,
        },
        

        ardent_defender = {
            id = 31850,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135870,
            
            handler = function ()
            end,
        },
        

        avengers_shield = {
            id = 31935,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135874,
            
            handler = function ()
            end,
        },
        

        avenging_wrath = {
            id = 31884,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135875,
            
            handler = function ()
            end,
        },
        

        bastion_of_light = {
            id = 204035,
            cast = 0,
            cooldown = 120,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 535594,
            
            handler = function ()
            end,
        },
        

        blessed_hammer = {
            id = 204019,
            cast = 0,
            charges = 3,
            cooldown = 4.5,
            recharge = 4.5,
            gcd = "spell",
            
            startsCombat = true,
            texture = 535595,
            
            handler = function ()
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
            
            startsCombat = true,
            texture = 135968,
            
            handler = function ()
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
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135964,
            
            handler = function ()
            end,
        },
        

        blessing_of_sacrifice = {
            id = 6940,
            cast = 0,
            charges = 1,
            cooldown = 120,
            recharge = 120,
            gcd = "spell",
            
            spend = 0.07,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135966,
            
            handler = function ()
            end,
        },
        

        blessing_of_spellwarding = {
            id = 204018,
            cast = 0,
            cooldown = 180,
            gcd = "spell",
            
            spend = 0.15,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135880,
            
            handler = function ()
            end,
        },
        

        blinding_light = {
            id = 115750,
            cast = 0,
            cooldown = 90,
            gcd = "spell",
            
            spend = 0.08,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 571553,
            
            handler = function ()
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
            
            startsCombat = true,
            texture = 135953,
            
            handler = function ()
            end,
        },
        

        consecration = {
            id = 26573,
            cast = 0,
            cooldown = 4.5,
            gcd = "spell",
            
            startsCombat = true,
            texture = 135926,
            
            handler = function ()
            end,
        },
        

        divine_shield = {
            id = 642,
            cast = 0,
            cooldown = 300,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 524354,
            
            handler = function ()
            end,
        },
        

        divine_steed = {
            id = 190784,
            cast = 0,
            charges = 1,
            cooldown = 45,
            recharge = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1360759,
            
            handler = function ()
            end,
        },
        

        flash_of_light = {
            id = 19750,
            cast = 1.5,
            cooldown = 0,
            gcd = "spell",
            
            spend = 0.2,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135907,
            
            handler = function ()
            end,
        },
        

        guardian_of_ancient_kings = {
            id = 86659,
            cast = 0,
            cooldown = 300,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135919,
            
            handler = function ()
            end,
        },
        

        hammer_of_justice = {
            id = 853,
            cast = 0,
            cooldown = 60,
            gcd = "spell",
            
            spend = 0.04,
            spendType = "mana",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135963,
            
            handler = function ()
            end,
        },
        

        hammer_of_the_righteous = {
            id = 53595,
            cast = 0,
            charges = 2,
            cooldown = 4.5,
            recharge = 4.5,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236253,
            
            handler = function ()
            end,
        },
        

        hand_of_reckoning = {
            id = 62124,
            cast = 0,
            charges = 1,
            cooldown = 8,
            recharge = 8,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135984,
            
            handler = function ()
            end,
        },
        

        hand_of_the_protector = {
            id = 213652,
            cast = 0,
            charges = 1,
            cooldown = 15,
            recharge = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236248,
            
            handler = function ()
            end,
        },
        

        judgment = {
            id = 275779,
            cast = 0,
            charges = 1,
            cooldown = 6,
            recharge = 6,
            gcd = "spell",
            
            spend = 0.03,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135959,
            
            handler = function ()
            end,
        },
        

        lay_on_hands = {
            id = 633,
            cast = 0,
            cooldown = 600,
            gcd = "spell",
            
            toggle = "cooldowns",

            startsCombat = true,
            texture = 135928,
            
            handler = function ()
            end,
        },
        

        light_of_the_protector = {
            id = 184092,
            cast = 0,
            charges = 1,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1360763,
            
            handler = function ()
            end,
        },
        

        rebuke = {
            id = 96231,
            cast = 0,
            cooldown = 15,
            gcd = "spell",
            
            startsCombat = true,
            texture = 523893,
            
            handler = function ()
            end,
        },
        

        redemption = {
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
        },
        

        repentance = {
            id = 20066,
            cast = 1.7,
            cooldown = 15,
            gcd = "spell",
            
            spend = 0.1,
            spendType = "mana",
            
            startsCombat = true,
            texture = 135942,
            
            handler = function ()
            end,
        },
        

        seraphim = {
            id = 152262,
            cast = 0,
            cooldown = 45,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1030103,
            
            handler = function ()
            end,
        },
        

        shield_of_the_righteous = {
            id = 53600,
            cast = 0,
            charges = 3,
            cooldown = 20,
            recharge = 20,
            gcd = "spell",
            
            startsCombat = true,
            texture = 236265,
            
            handler = function ()
            end,
        },
        

        wartime_ability = {
            id = 264739,
            cast = 0,
            cooldown = 0,
            gcd = "spell",
            
            startsCombat = true,
            texture = 1518639,
            
            handler = function ()
            end,
        },
    } )


    spec:RegisterOptions( {
        enabled = false,

        aoe = 2,
    
        nameplates = true,
        nameplateRange = 8,
        
        damage = true,
        damageExpiration = 8,
    
        package = nil,
    } )
end
