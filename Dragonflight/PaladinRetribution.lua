-- PaladinRetribution.lua
-- September 2022

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 70 )

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    afterimage                      = { 79064, 385414, 1 }, --
    art_of_war                      = { 78996, 267344, 1 }, --
    ashes_to_ashes                  = { 78990, 383276, 2 }, --
    ashes_to_dust                   = { 78958, 383300, 1 }, --
    aspirations_of_divinity         = { 79063, 385416, 2 }, --
    auras_of_swift_vengeance        = { 78951, 385639, 1 }, --
    auras_of_the_resolute           = { 78953, 385633, 1 }, --
    avenging_wrath                  = { 79050, 384376, 1 }, --
    avenging_wrath_might            = { 78992, 384442, 1 }, --
    blade_of_justice                = { 78960, 184575, 1 }, --
    blade_of_wrath                  = { 78978, 231832, 1 }, --
    blessing_of_freedom             = { 78952, 1044  , 1 }, --
    blessing_of_protection          = { 79049, 1022  , 1 }, --
    blessing_of_sacrifice           = { 79065, 6940  , 1 }, --
    blessing_of_spellwarding        = { 79056, 204018, 1 }, --
    blinding_light                  = { 79067, 115750, 1 }, --
    boundless_judgment              = { 78969, 383876, 1 }, --
    calm_before_the_storm           = { 78966, 382536, 1 }, --
    cavalier                        = { 78914, 230332, 1 }, --
    cleanse_toxins                  = { 79039, 213644, 1 }, --
    condemning_blade                = { 78976, 383263, 1 }, --
    consecrated_blade               = { 78977, 382275, 1 }, --
    consecrated_ground              = { 78970, 204054, 1 }, --
    crusade                         = { 78992, 384392, 1 }, --
    divine_protection               = { 78994, 498   , 1 }, --
    divine_purpose                  = { 79057, 223817, 1 }, --
    divine_resonance                = { 78974, 384027, 1 }, --
    divine_steed                    = { 79052, 190784, 1 }, --
    divine_storm                    = { 78963, 53385 , 1 }, --
    divine_toll                     = { 78975, 375576, 1 }, --
    empyrean_endowment              = { 78973, 387170, 1 }, --
    empyrean_power                  = { 78981, 326732, 1 }, --
    execution_sentence              = { 78998, 343527, 1 }, --
    executioners_will               = { 78997, 384162, 1 }, --
    executioners_wrath              = { 78997, 387196, 1 }, --
    exorcism                        = { 78959, 383185, 1 }, --
    expurgation                     = { 78982, 383344, 1 }, --
    eye_for_an_eye                  = { 78984, 205191, 1 }, --
    final_reckoning                 = { 78988, 343721, 1 }, --
    final_verdict                   = { 78986, 383327, 1 }, --
    fires_of_justice                = { 78981, 203316, 1 }, --
    fist_of_justice                 = { 78950, 234299, 2 }, --
    golden_path                     = { 79040, 377128, 1 }, --
    hallowed_ground                 = { 79047, 377043, 1 }, --
    hammer_of_wrath                 = { 78949, 24275 , 1 }, --
    hand_of_hindrance               = { 78972, 183218, 1 }, --
    healing_hands                   = { 78991, 326734, 1 }, --
    highlords_judgment              = { 78968, 383271, 2 }, --
    holy_aegis                      = { 79066, 385515, 2 }, --
    holy_avenger                    = { 79057, 105809, 1 }, --
    holy_blade                      = { 78995, 383342, 1 }, --
    holy_crusader                   = { 78962, 386967, 1 }, --
    improved_blessing_of_protection = { 79056, 384909, 1 }, --
    improved_crusader_strike        = { 78964, 383254, 1 }, --
    incandescence                   = { 79048, 385464, 1 }, --
    inner_power                     = { 78971, 383334, 1 }, --
    judgment_4                      = { 79044, 231663, 1 }, --
    judgment_of_light               = { 79038, 183778, 1 }, --
    justicars_vengeance             = { 78984, 215661, 1 }, --
    lay_on_hands                    = { 79068, 633   , 1 }, --
    obduracy                        = { 79055, 385427, 1 }, --
    of_dusk_and_dawn                = { 79062, 385125, 1 }, --
    path_of_ruin                    = { 78958, 384052, 1 }, --
    rebuke                          = { 79043, 96231 , 1 }, --
    recompense                      = { 79036, 384914, 1 }, --
    relentless_inquisitor           = { 78999, 383388, 2 }, --
    repentance                      = { 79067, 20066 , 1 }, --
    righteous_verdict               = { 78965, 267610, 1 }, --
    sacrifice_of_the_just           = { 79036, 384820, 1 }, --
    sanctification                  = { 78971, 382430, 1 }, --
    sanctified_ground               = { 78970, 387479, 1 }, --
    sanctified_wrath                = { 79059, 171648, 1 }, --
    seal_of_alacrity                = { 79058, 385425, 2 }, --
    seal_of_clarity                 = { 79041, 384815, 2 }, --
    seal_of_mercy                   = { 79042, 384897, 2 }, --
    seal_of_might_nyi               = { 79060, 385450, 2 }, --
    seal_of_order                   = { 79061, 385129, 1 }, --
    seal_of_reprisal                = { 79046, 377053, 2 }, --
    seal_of_the_crusader            = { 79054, 385728, 2 }, --
    seal_of_the_templar             = { 79051, 377016, 1 }, --
    seal_of_wrath                   = { 78979, 386901, 1 }, --
    sealed_verdict                  = { 78983, 387640, 2 }, --
    seasoned_warhorse               = { 79051, 376996, 1 }, --
    selfless_healer                 = { 78991, 85804 , 1 }, --
    seraphim                        = { 79059, 152262, 1 }, --
    shield_of_vengeance             = { 78994, 184662, 1 }, --
    tempest_of_the_lightbringer     = { 78980, 383396, 1 }, --
    templars_vindication            = { 78987, 383274, 2 }, --
    the_mad_paragon                 = { 79053, 391142, 1 }, --
    timely_judgment                 = { 78961, 383228, 1 }, --
    touch_of_light                  = { 79048, 385349, 1 }, --
    truths_wake                     = { 78957, 383350, 1 }, --
    turn_evil                       = { 79045, 10326 , 1 }, --
    unbreakable_spirit              = { 79037, 114154, 1 }, --
    vanguards_momentum              = { 78985, 383314, 2 }, --
    virtuous_command                = { 78989, 383304, 2 }, --
    wake_of_ashes                   = { 78993, 255937, 1 }, --
    zeal                            = { 78967, 269569, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning     = 756 , -- 247675
    blessing_of_sanctuary = 752 , -- 210256
    divine_punisher       = 755 , -- 204914
    hallowed_ground       = 5535, -- 216868
    judgments_of_the_pure = 5422, -- 355858
    jurisdiction          = 757 , -- 204979
    law_and_order         = 858 , -- 204934
    lawbringer            = 754 , -- 246806
    luminescence          = 81  , -- 199428
    ultimate_retribution  = 753 , -- 355614
    unbound_freedom       = 641 , -- 305394
    vengeance_aura        = 751 , -- 210323
} )


-- Auras
spec:RegisterAuras( {
    aspirations_of_divinity = {
        id = 385417,
        duration = 6,
        max_stack = 3
    },
    avenging_wrath = {
        id = 31884,
        duration = 20,
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
    blessing_of_sanctuary = {
        id = 210256,
        duration = 5,
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
    consecration = {
        id = 26573,
        duration = 12,
        tick_time = 1,
        max_stack = 1
    },
    crusader_aura = {
        id = 32223,
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
    empyrean_power = {
        id = 326733,
        duration = 15,
        max_stack = 1
    },
    execution_sentence = {
        id = 343527,
        duration = 8,
        max_stack = 1
    },
    expurgation = {
        id = 383346,
        duration = 6,
        tick_time = 2,
        max_stack = 1
    },
    eye_for_an_eye = {
        id = 205191,
        duration = 10,
        max_stack = 1
    },
    final_reckoning = {
        id = 343721,
        duration = 8,
        max_stack = 1
    },
    fires_of_justice = {
        id = 209785,
        duration = 15,
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
    judgment_of_light = {
        id = 196941,
        duration = 30,
        max_stack = 1
    },
    repentance = {
        id = 20066,
        duration = 60,
        max_stack = 1
    },
    retribution_aura = {
        id = 183435,
        duration = 3600,
        max_stack = 1
    },
    seal_of_the_crusader = {
        id = 385723,
        duration = 5,
        max_stack = 1
    },
    selfless_healer = {
        id = 114250,
        duration = 15,
        max_stack = 4
    },
    sense_undead = {
        id = 5502,
        duration = 3600,
        max_stack = 1
    },
    seraphim = {
        id = 152262,
        duration = 15,
        max_stack = 1
    },
    shield_of_vengeance = {
        id = 184662,
        duration = 15,
        max_stack = 1
    },
    turn_evil = {
        id = 10326,
        duration = 40,
        max_stack = 1
    },
    vanguards_momentum = {
        id = 383311,
        duration = 10,
        max_stack = 3
    },
    wake_of_ashes = {
        id = 255937,
        duration = 5,
        max_stack = 1
    },
    zeal = {
        id = 269571,
        duration = 20,
        max_stack = 9
    },
} )


-- Abilities
spec:RegisterAbilities( {
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


    blessing_of_sanctuary = {
        id = 210256,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "blessing_of_sanctuary",
        startsCombat = false,
        texture = 135911,

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


    crusader_aura = {
        id = 32223,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135890,

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


    hammer_of_wrath = {
        id = 24275,
        cast = 0,
        charges = 1,
        cooldown = 7.5,
        recharge = 7.5,
        gcd = "spell",

        talent = "hammer_of_wrath",
        startsCombat = true,
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


    intercession = {
        id = 391054,
        cast = 2,
        cooldown = 600,
        gcd = "spell",

        spend = 0,
        spendType = "holy_power",

        startsCombat = true,
        texture = 237550,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    judgment = {
        id = 20271,
        cast = 0,
        charges = 1,
        cooldown = 12,
        recharge = 12,
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


    retribution_aura = {
        id = 183435,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135889,

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


    templars_verdict = {
        id = 85256,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        startsCombat = true,
        texture = 461860,

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

spec:RegisterPriority( "Retribution", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )