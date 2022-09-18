-- PaladinProtection.lua
-- September 2022

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 66 )

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    afterimage                      = { 79064, 385414, 1 }, --
    ardent_defender                 = { 78925, 31850 , 1 }, --
    aspirations_of_divinity         = { 79063, 385416, 2 }, --
    auras_of_swift_vengeance        = { 78951, 385639, 1 }, --
    auras_of_the_resolute           = { 78953, 385633, 1 }, --
    avengers_shield                 = { 78918, 31935 , 1 }, --
    avenging_wrath                  = { 79050, 384376, 1 }, --
    avenging_wrath_might            = { 78927, 384442, 1 }, --
    bastion_of_light                = { 78946, 378974, 1 }, --
    blessed_hammer                  = { 78921, 204019, 1 }, --
    blessing_of_freedom             = { 78952, 1044  , 1 }, --
    blessing_of_protection          = { 79049, 1022  , 1 }, --
    blessing_of_sacrifice           = { 79065, 6940  , 1 }, --
    blessing_of_spellwarding        = { 79056, 204018, 1 }, --
    blinding_light                  = { 79067, 115750, 1 }, --
    bulwark_of_order                = { 78926, 209389, 2 }, --
    bulwark_of_righteous_fury       = { 78939, 386653, 1 }, --
    cavalier                        = { 78914, 230332, 1 }, --
    cleanse_toxins                  = { 79039, 213644, 1 }, --
    consecrated_ground              = { 78919, 204054, 1 }, --
    consecration_in_flame           = { 78929, 379022, 1 }, --
    crusaders_judgment              = { 78933, 204023, 1 }, --
    crusaders_resolve               = { 78948, 380188, 2 }, --
    divine_purpose                  = { 79057, 223817, 1 }, --
    divine_resonance                = { 78935, 386738, 1 }, --
    divine_steed                    = { 79052, 190784, 1 }, --
    divine_toll                     = { 78936, 375576, 1 }, --
    eye_of_tyr                      = { 78938, 387174, 1 }, --
    faith_barricade                 = { 78923, 385726, 1 }, --
    faith_in_the_light              = { 78934, 379043, 2 }, --
    faiths_armor                    = { 78937, 379017, 1 }, --
    ferren_marcuss_strength         = { 78955, 378762, 2 }, --
    final_stand                     = { 78940, 204077, 1 }, --
    fist_of_justice                 = { 78950, 234299, 2 }, --
    focused_enmity                  = { 78945, 378845, 1 }, --
    gift_of_the_golden_valkyr       = { 78956, 378279, 2 }, --
    golden_path                     = { 79040, 377128, 1 }, --
    grand_crusader                  = { 78924, 85043 , 1 }, --
    guardian_of_ancient_kings       = { 78942, 86659 , 1 }, --
    hallowed_ground                 = { 79047, 377043, 1 }, --
    hammer_of_the_righteous         = { 78921, 53595 , 1 }, --
    hammer_of_wrath                 = { 78949, 24275 , 1 }, --
    hand_of_the_protector           = { 78915, 315924, 1 }, --
    holy_aegis                      = { 79066, 385515, 2 }, --
    holy_avenger                    = { 79057, 105809, 1 }, --
    holy_shield                     = { 78920, 152261, 1 }, --
    improved_blessing_of_protection = { 79056, 384909, 1 }, --
    improved_sera__dt               = { 78935, 379391, 1 }, --
    incandescence                   = { 79048, 385464, 1 }, --
    inner_light                     = { 78917, 386568, 1 }, --
    inspiring_vanguard              = { 78922, 279387, 1 }, --
    judgment_4                      = { 79044, 231663, 1 }, --
    judgment_of_light               = { 79038, 183778, 1 }, --
    lay_on_hands                    = { 79068, 633   , 1 }, --
    light_of_the_titans             = { 78928, 378405, 2 }, --
    moment_of_glory                 = { 78954, 327193, 1 }, --
    obduracy                        = { 79055, 385427, 1 }, --
    of_dusk_and_dawn                = { 79062, 385125, 1 }, --
    rebuke                          = { 79043, 96231 , 1 }, --
    recompense                      = { 79036, 384914, 1 }, --
    redoubt                         = { 78917, 280373, 1 }, --
    relentless_inquisitor           = { 78943, 383388, 1 }, --
    repentance                      = { 79067, 20066 , 1 }, --
    resolute_defender               = { 78944, 385422, 1 }, --
    righteous_protector             = { 78941, 204074, 2 }, --
    sacrifice_of_the_just           = { 79036, 384820, 1 }, --
    sanctified_wrath                = { 79059, 171648, 1 }, --
    sanctuary                       = { 78930, 379021, 2 }, --
    seal_of_alacrity                = { 79058, 385425, 2 }, --
    seal_of_clarity                 = { 79041, 384815, 2 }, --
    seal_of_mercy                   = { 79042, 384897, 2 }, --
    seal_of_might_nyi               = { 79060, 385450, 2 }, --
    seal_of_order                   = { 79061, 385129, 1 }, --
    seal_of_reprisal                = { 79046, 377053, 2 }, --
    seal_of_the_crusader            = { 79054, 385728, 2 }, --
    seal_of_the_templar             = { 79051, 377016, 1 }, --
    seasoned_warhorse               = { 79051, 376996, 1 }, --
    sentinel                        = { 78927, 385438, 1 }, --
    seraphim                        = { 79059, 152262, 1 }, --
    shining_light                   = { 78916, 321136, 1 }, --
    soaring_shield                  = { 78945, 378457, 1 }, --
    strength_of_conviction          = { 78932, 379008, 2 }, --
    the_mad_paragon                 = { 79053, 391142, 1 }, --
    touch_of_light                  = { 79048, 385349, 1 }, --
    turn_evil                       = { 79045, 10326 , 1 }, --
    tyrs_enforcer                   = { 78947, 378285, 2 }, --
    unbreakable_spirit              = { 79037, 114154, 1 }, --
    uthers_guard                    = { 78931, 378425, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning               = 5554, -- 247675
    guarded_by_the_light            = 97  , -- 216855
    guardian_of_the_forgotten_queen = 94  , -- 228049
    hallowed_ground                 = 90  , -- 216868
    inquisition                     = 844 , -- 207028
    judgments_of_the_pure           = 93  , -- 355858
    luminescence                    = 3474, -- 199428
    sacred_duty                     = 92  , -- 216853
    shield_of_virtue                = 861 , -- 215652
    steed_of_glory                  = 91  , -- 199542
    unbound_freedom                 = 3475, -- 305394
    vengeance_aura                  = 5536, -- 210323
    warrior_of_light                = 860 , -- 210341
} )


-- Auras
spec:RegisterAuras( {
    ardent_defender = {
        id = 31850,
        duration = 8,
        max_stack = 1
    },
    aspirations_of_divinity = {
        id = 385417,
        duration = 6,
        max_stack = 3
    },
    avengers_shield = {
        id = 31935,
        duration = 3,
        max_stack = 1
    },
    avenging_wrath = {
        id = 31884,
        duration = 20,
        max_stack = 1
    },
    bastion_of_light = {
        id = 378974,
        duration = 30,
        max_stack = 3
    },
    blessed_hammer = { -- TODO: Model based on cast time.
        id = 204019,
        duration = 5,
        max_stack = 1
    },
    blessing_of_dawn = {
        id = 385127,
        duration = 15,
        max_stack = 1
    },
    blessing_of_dusk = {
        id = 385126,
        duration = 15,
        max_stack = 1
    },
    blessing_of_freedom = {
        id = 1044,
        duration = 8,
        max_stack = 1
    },
    blessing_of_protection = {
        id = 1022,
        duration = 10,
        max_stack = 1
    },
    blessing_of_sacrifice = {
        id = 6940,
        duration = 12,
        max_stack = 1
    },
    blessing_of_spellwarding = {
        id = 204018,
        duration = 10,
        max_stack = 1
    },
    blinding_light = {
        id = 105421,
        duration = 6,
        max_stack = 1
    },
    concentration_aura = {
        id = 317920,
        duration = 3600,
        max_stack = 1
    },
    consecration = {
        id = 26573,
        duration = 12,
        tick_time = 1,
        max_stack = 1
    },
    crusaders_resolve = {
        id = 383843,
        duration = 10,
        max_stack = 3
    },
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1
    },
    divine_protection = {
        id = 498,
        duration = 8,
        max_stack = 1
    },
    divine_resonance = {
        id = 384029,
        duration = 15,
        tick_time = 5,
        max_stack = 1
    },
    divine_shield = {
        id = 642,
        duration = 8,
        max_stack = 1
    },
    execution_sentence = {
        id = 343527,
        duration = 8,
        max_stack = 1
    },
    eye_for_an_eye = {
        id = 205191,
        duration = 10,
        max_stack = 1
    },
    eye_of_tyr = {
        id = 387174,
        duration = 9,
        max_stack = 1
    },
    faith_barricade = {
        id = 385724,
        duration = 10,
        max_stack = 1
    },
    faith_in_the_light = {
        id = 379041,
        duration = 5,
        max_stack = 1
    },
    final_reckoning = {
        id = 343721,
        duration = 8,
        max_stack = 1
    },
    first_avenger = {
        id = 327225,
        duration = 8,
        max_stack = 1
    },
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 5
    },
    guardian_of_ancient_kings = {
        id = 86659,
        duration = 8,
        max_stack = 1
    },
    guardian_of_the_forgotten_queen_228048 = { -- TODO: Disambiguate -- TODO: Check Aura (https://wowhead.com/beta/spell=228048)
        id = 228048,
        duration = 10,
        max_stack = 1
    },
    guardian_of_the_forgotten_queen_228049 = { -- TODO: Disambiguate -- TODO: Check Aura (https://wowhead.com/beta/spell=228049)
        id = 228049,
        duration = 10,
        max_stack = 1
    },
    hammer_of_justice = {
        id = 853,
        duration = 6,
        max_stack = 1
    },
    hand_of_hindrance = {
        id = 183218,
        duration = 10,
        max_stack = 1
    },
    hand_of_reckoning = {
        id = 62124,
        duration = 3,
        max_stack = 1
    },
    holy_avenger = {
        id = 105809,
        duration = 20,
        max_stack = 1
    },
    inquisition = { -- TODO: Check Aura (https://wowhead.com/beta/spell=207028)
        id = 207028,
        duration = 300,
        max_stack = 1
    },
    inspiring_vanguard_279387 = { -- TODO: Disambiguate -- TODO: Check Aura (https://wowhead.com/beta/spell=279387)
        id = 279387,
        duration = 3600,
        max_stack = 1
    },
    inspiring_vanguard_279397 = { -- TODO: Disambiguate
        id = 279397,
        duration = 8,
        max_stack = 1
    },
    judgment_of_light = {
        id = 196941,
        duration = 30,
        max_stack = 1
    },
    light_of_the_titans = {
        id = 378412,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    moment_of_glory = { -- TODO: Check Aura (https://wowhead.com/beta/spell=327193)
        id = 327193,
        duration = 15,
        max_stack = 1
    },
    rebuke = { -- TODO: Check Aura (https://wowhead.com/beta/spell=96231)
        id = 96231,
        duration = 4,
        max_stack = 1
    },
    redoubt = {
        id = 280375,
        duration = 10,
        max_stack = 3
    },
    repentance = {
        id = 20066,
        duration = 60,
        max_stack = 1
    },
    seal_of_the_crusader = {
        id = 385723,
        duration = 5,
        max_stack = 1
    },
    sense_undead = {
        id = 5502,
        duration = 3600,
        max_stack = 1
    },
    seraphim_152262 = { -- TODO: Disambiguate
        id = 152262,
        duration = 15,
        max_stack = 1
    },
    shield_of_vengeance = {
        id = 184662,
        duration = 15,
        max_stack = 1
    },
    shield_of_virtue_215652 = { -- TODO: Disambiguate
        id = 215652,
        duration = 3600,
        max_stack = 1
    },
    shield_of_virtue_217824 = { -- TODO: Disambiguate
        id = 217824,
        duration = 4,
        max_stack = 1
    },
    sign_of_the_emissary = {
        id = 225788,
        duration = 3600,
        max_stack = 1
    },
    turn_evil = {
        id = 10326,
        duration = 40,
        max_stack = 1
    },
    wake_of_ashes = {
        id = 255937,
        duration = 5,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    ardent_defender = {
        id = 31850,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "ardent_defender",
        startsCombat = false,
        texture = 135870,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    avengers_shield = {
        id = 31935,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        talent = "avengers_shield",
        startsCombat = false,
        texture = 135874,

        handler = function ()
        end,
    },


    bastion_of_light = {
        id = 378974,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "bastion_of_light",
        startsCombat = false,
        texture = 535594,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    blade_of_justice = {
        id = 184575,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        talent = "blade_of_justice",
        startsCombat = false,
        texture = 1360757,

        handler = function ()
        end,
    },


    blessed_hammer = {
        id = 204019,
        cast = 0,
        charges = 3,
        cooldown = 6,
        recharge = 6,
        gcd = "spell",

        talent = "blessed_hammer",
        startsCombat = false,
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

        spend = 0.07,
        spendType = "mana",

        talent = "blessing_of_freedom",
        startsCombat = false,
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

        talent = "blessing_of_protection",
        startsCombat = false,
        texture = 135964,

        toggle = "cooldowns",

        handler = function ()
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

        talent = "blessing_of_sacrifice",
        startsCombat = false,
        texture = 135966,

        toggle = "cooldowns",

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

        talent = "blessing_of_spellwarding",
        startsCombat = false,
        texture = 135880,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    blinding_light = {
        id = 115750,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "blinding_light",
        startsCombat = false,
        texture = 571553,

        toggle = "cooldowns",

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

        talent = "cleanse_toxins",
        startsCombat = false,
        texture = 135953,

        handler = function ()
        end,
    },


    concentration_aura = {
        id = 317920,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135933,

        handler = function ()
        end,
    },


    consecration = {
        id = 26573,
        cast = 0,
        cooldown = 9,
        gcd = "spell",

        startsCombat = false,
        texture = 135926,

        handler = function ()
        end,
    },


    crusader_strike = {
        id = 35395,
        cast = 0,
        charges = 1,
        cooldown = 6,
        recharge = 6,
        gcd = "spell",

        spend = 0.11,
        spendType = "mana",

        startsCombat = true,
        texture = 135891,

        handler = function ()
        end,
    },


    devotion_aura = {
        id = 465,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135893,

        handler = function ()
        end,
    },


    divine_protection = {
        id = 498,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0.04,
        spendType = "mana",

        talent = "divine_protection",
        startsCombat = false,
        texture = 524353,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    divine_shield = {
        id = 642,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        startsCombat = false,
        texture = 524354,

        toggle = "cooldowns",

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

        talent = "divine_steed",
        startsCombat = false,
        texture = 1360759,

        handler = function ()
        end,
    },


    divine_storm = {
        id = 53385,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        talent = "divine_storm",
        startsCombat = false,
        texture = 236250,

        handler = function ()
        end,
    },


    divine_toll = {
        id = 375576,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        talent = "divine_toll",
        startsCombat = false,
        texture = 3565448,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    execution_sentence = {
        id = 343527,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        talent = "execution_sentence",
        startsCombat = false,
        texture = 613954,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    exorcism = {
        id = 383185,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        talent = "exorcism",
        startsCombat = false,
        texture = 135903,

        handler = function ()
        end,
    },


    eye_for_an_eye = {
        id = 205191,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "eye_for_an_eye",
        startsCombat = false,
        texture = 135986,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    eye_of_tyr = {
        id = 387174,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "eye_of_tyr",
        startsCombat = false,
        texture = 1272527,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    final_reckoning = {
        id = 343721,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "final_reckoning",
        startsCombat = false,
        texture = 135878,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    flash_of_light = {
        id = 19750,
        cast = 1.43,
        cooldown = 0,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
        end,
    },


    guardian_of_ancient_kings = {
        id = 86659,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        talent = "guardian_of_ancient_kings",
        startsCombat = false,
        texture = 135919,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    guardian_of_the_forgotten_queen = {
        id = 228049,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        pvptalent = "guardian_of_the_forgotten_queen",
        startsCombat = false,
        texture = 135919,

        toggle = "cooldowns",

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

        startsCombat = true,
        texture = 135963,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    hammer_of_the_righteous = {
        id = 53595,
        cast = 0,
        charges = 1,
        cooldown = 6,
        recharge = 6,
        gcd = "spell",

        talent = "hammer_of_the_righteous",
        startsCombat = false,
        texture = 236253,

        handler = function ()
        end,
    },


    hammer_of_wrath = {
        id = 24275,
        cast = 0,
        charges = 1,
        cooldown = 7.5,
        recharge = 7.5,
        gcd = "spell",

        talent = "hammer_of_wrath",
        startsCombat = false,
        texture = 613533,

        handler = function ()
        end,
    },


    hand_of_hindrance = {
        id = 183218,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        talent = "hand_of_hindrance",
        startsCombat = false,
        texture = 1360760,

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
        end,
    },


    holy_avenger = {
        id = 105809,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "holy_avenger",
        startsCombat = false,
        texture = 571555,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    inquisition = {
        id = 207028,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        pvptalent = "inquisition",
        startsCombat = false,
        texture = 135984,

        handler = function ()
        end,
    },


    inspiring_vanguard = {
        id = 279387,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "inspiring_vanguard",
        startsCombat = false,
        texture = 133176,

        handler = function ()
        end,
    },


    intercession = {
        id = 391054,
        cast = 0,
        cooldown = 600,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        startsCombat = true,
        texture = 237550,

        toggle = "cooldowns",

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


    justicars_vengeance = {
        id = 215661,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        talent = "justicars_vengeance",
        startsCombat = false,
        texture = 135957,

        handler = function ()
        end,
    },


    lay_on_hands = {
        id = 633,
        cast = 0,
        cooldown = 600,
        gcd = "off",

        talent = "lay_on_hands",
        startsCombat = false,
        texture = 135928,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    moment_of_glory = {
        id = 327193,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "moment_of_glory",
        startsCombat = false,
        texture = 237537,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    rebuke = {
        id = 96231,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        talent = "rebuke",
        startsCombat = false,
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

        spend = 0.06,
        spendType = "mana",

        talent = "repentance",
        startsCombat = false,
        texture = 135942,

        handler = function ()
        end,
    },


    sense_undead = {
        id = 5502,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135974,

        handler = function ()
        end,
    },


    seraphim = {
        id = 152262,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        talent = "seraphim",
        startsCombat = false,
        texture = 1030103,

        handler = function ()
        end,
    },


    shield_of_the_righteous = {
        id = 53600,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        spend = 3,
        spendType = "holy_power",

        startsCombat = true,
        texture = 236265,

        handler = function ()
        end,
    },


    shield_of_vengeance = {
        id = 184662,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "shield_of_vengeance",
        startsCombat = false,
        texture = 236264,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    shield_of_virtue = {
        id = 215652,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        pvptalent = "shield_of_virtue",
        startsCombat = false,
        texture = 237452,

        handler = function ()
        end,
    },


    turn_evil = {
        id = 10326,
        cast = 1.43,
        cooldown = 15,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        talent = "turn_evil",
        startsCombat = false,
        texture = 571559,

        handler = function ()
        end,
    },


    wake_of_ashes = {
        id = 255937,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "wake_of_ashes",
        startsCombat = false,
        texture = 1112939,

        handler = function ()
        end,
    },


    word_of_glory = {
        id = 85673,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        startsCombat = false,
        texture = 133192,

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Protection", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )