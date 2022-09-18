-- PaladinHoly.lua
-- September 2022

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 65 )

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
    aura_of_reckoning       = 5553, -- 247675
    avenging_light          = 82  , -- 199441
    blessed_hands           = 88  , -- 199454
    cleanse_the_weak        = 642 , -- 199330
    darkest_before_the_dawn = 86  , -- 210378
    divine_vision           = 640 , -- 199324
    hallowed_ground         = 3618, -- 216868
    judgments_of_the_pure   = 5421, -- 355858
    lights_grace            = 859 , -- 216327
    precognition            = 5501, -- 377360
    spreading_the_word      = 87  , -- 199456
    ultimate_sacrifice      = 85  , -- 199452
    vengeance_aura          = 5537, -- 210323
} )


-- Auras
spec:RegisterAuras( {
    aspirations_of_divinity = {
        id = 385417,
        duration = 6,
        max_stack = 3
    },
    aura_mastery = {
        id = 31821,
        duration = 8,
        max_stack = 1
    },
    avenging_crusader = {
        id = 216331,
        duration = 20,
        max_stack = 1
    },
    avenging_wrath = {
        id = 31884,
        duration = 20,
        max_stack = 1
    },
    barrier_of_faith = {
        id = 148039,
        duration = 18,
        tick_time = 6,
        max_stack = 1
    },
    beacon_of_faith = {
        id = 156910,
        duration = 3600,
        max_stack = 1
    },
    beacon_of_light = {
        id = 53563,
        duration = 3600,
        max_stack = 1
    },
    beacon_of_virtue = {
        id = 200025,
        duration = 8,
        max_stack = 1
    },
    bestow_faith = {
        id = 223306,
        duration = 5,
        tick_time = 5,
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
    blessing_of_summer = {
        id = 388007,
        duration = 30,
        max_stack = 1
    },
    blessing_of_the_seasons = { -- TODO: Original SL auras in SL/Covenants module.
        alias = { "blessing_of_autumn", "blessing_of_spring", "blessing_of_summer", "blessing_of_winter" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3600,
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
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1
    },
    divine_favor = {
        id = 210294,
        duration = 3600,
        max_stack = 1
    },
    divine_protection = {
        id = 498,
        duration = 8,
        max_stack = 1
    },
    divine_resonance = {
        id = 387895,
        duration = 15,
        tick_time = 5,
        max_stack = 1
    },
    divine_shield = {
        id = 642,
        duration = 8,
        max_stack = 1
    },
    empyreal_ward = {
        id = 387792,
        duration = 60,
        max_stack = 1
    },
    glimmer_of_light = {
        id = 287280,
        duration = 30,
        max_stack = 1,
        friendly = true
    },
    hammer_of_justice = {
        id = 853,
        duration = 6,
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
    infusion_of_light = {
        id = 54149,
        duration = 15,
        max_stack = 1
    },
    judgment_of_light = {
        id = 196941,
        duration = 30,
        max_stack = 1
    },
    lights_hammer = { -- TODO: Is totem?
        id = 122773,
        duration = 15.5,
        max_stack = 1
    },
    power_of_the_silver_hand = {
        id = 200656,
        duration = 10,
        max_stack = 1
    },
    repentance = {
        id = 20066,
        duration = 60,
        max_stack = 1
    },
    rule_of_law = {
        id = 214202,
        duration = 10,
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
    seraphim = {
        id = 152262,
        duration = 15,
        max_stack = 1
    },
    turn_evil = {
        id = 10326,
        duration = 40,
        max_stack = 1
    },
    tyrs_deliverance = {
        id = 200652,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    untempered_dedication = {
        id = 387815,
        duration = 15,
        max_stack = 5
    },
    veneration = {
        id = 392939,
        duration = 15,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    absolution = {
        id = 212056,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 1030102,

        handler = function ()
        end,
    },


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


    beacon_of_light = {
        id = 53563,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 236247,

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


    cleanse = {
        id = 4987,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 135949,

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
        id = 275773,
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

spec:RegisterPriority( "Holy", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )