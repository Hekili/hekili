-- RogueOutlaw.lua
-- September 2022

if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 260 )

spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

-- Talents
spec:RegisterTalents( {
    ace_up_your_sleeve     = { 79533, 381828, 1 }, --
    acrobatic_strikes      = { 79636, 196924, 1 }, --
    adrenaline_rush        = { 79541, 13750 , 1 }, --
    alacrity               = { 79630, 193539, 3 }, --
    ambidexterity          = { 79542, 381822, 1 }, --
    atrophic_poison        = { 79647, 381637, 1 }, --
    audacity               = { 79512, 381845, 1 }, --
    between_the_eyes       = { 79544, 315341, 1 }, --
    blade_flurry           = { 79543, 13877 , 1 }, --
    blade_rush             = { 79514, 271877, 1 }, --
    blind                  = { 79655, 2094  , 1 }, --
    blinding_powder        = { 79515, 256165, 1 }, --
    cheat_death            = { 79625, 31230 , 1 }, --
    cloak_of_shadows       = { 79653, 31224 , 1 }, --
    cold_blood             = { 79639, 382245, 1 }, --
    combat_potency         = { 79524, 61329 , 1 }, --
    combat_stamina         = { 79535, 381877, 1 }, --
    count_the_odds         = { 79523, 381982, 2 }, --
    dancing_steel          = { 79531, 272026, 1 }, --
    deadened_nerves        = { 79649, 231719, 1 }, --
    deadly_precision       = { 79638, 381542, 2 }, --
    deeper_stratagem       = { 79615, 193531, 1 }, --
    deeper_stratagem_2     = { 79525, 193531, 1 }, --
    dirty_tricks           = { 79517, 108216, 1 }, --
    dispatcher             = { 79521, 381990, 2 }, --
    dreadblades            = { 79529, 343142, 1 }, --
    echoing_reprimand      = { 79617, 385616, 1 }, --
    elusiveness            = { 79616, 79008 , 1 }, --
    evasion                = { 79646, 5277  , 1 }, --
    fan_the_hammer         = { 79527, 381846, 2 }, --
    fatal_flourish         = { 79536, 35551 , 1 }, --
    feint                  = { 79656, 1966  , 1 }, --
    find_weakness          = { 79624, 91023 , 2 }, --
    fleet_footed           = { 79648, 378813, 1 }, --
    float_like_a_butterfly = { 79537, 354897, 1 }, --
    ghostly_strike         = { 79510, 196937, 1 }, --
    gouge                  = { 79632, 1776  , 1 }, --
    grappling_hook         = { 79547, 195457, 1 }, --
    greenskins_wickers     = { 79526, 386823, 1 }, --
    heavy_hitter_nyi       = { 79511, 381885, 1 }, --
    hidden_opportunity     = { 79508, 383281, 1 }, --
    hit_and_run            = { 79518, 196922, 1 }, --
    improved_ambush        = { 79635, 381620, 1 }, --
    improved_main_gauche   = { 79530, 382746, 2 }, --
    improved_sap           = { 79628, 379005, 1 }, --
    improved_sprint        = { 79633, 231691, 1 }, --
    improved_wound_poison  = { 79641, 319066, 1 }, --
    iron_stomach           = { 79643, 193546, 1 }, --
    keep_it_rolling        = { 79520, 381989, 1 }, --
    killing_spree          = { 79529, 51690 , 1 }, --
    leeching_poison        = { 79621, 280716, 1 }, --
    lethality              = { 79637, 382238, 3 }, --
    loaded_dice            = { 79539, 256170, 1 }, --
    long_arm_of_the_outlaw = { 79532, 381878, 1 }, --
    marked_for_death       = { 79629, 137619, 1 }, --
    master_poisoner        = { 79642, 378436, 1 }, --
    nightstalker           = { 79635, 14062 , 1 }, --
    nimble_fingers         = { 79644, 378427, 1 }, --
    numbing_poison         = { 79647, 5761  , 1 }, --
    opportunity            = { 79546, 279876, 1 }, --
    precise_cuts_nyi       = { 79528, 381985, 1 }, --
    prey_on_the_weak       = { 79489, 131511, 1 }, --
    quick_draw             = { 79534, 196938, 1 }, --
    recuperator            = { 79634, 378996, 1 }, --
    resounding_clarity     = { 79618, 381622, 2 }, --
    restless_blades        = { 79538, 79096 , 1 }, --
    restless_crew_nyi      = { 79522, 382794, 1 }, --
    retractable_hook       = { 79516, 256188, 1 }, --
    riposte                = { 79548, 344363, 1 }, --
    roll_the_bones         = { 79540, 315508, 1 }, --
    rushed_setup           = { 79654, 378803, 1 }, --
    ruthlessness           = { 79549, 14161 , 1 }, --
    sap                    = { 79652, 6770  , 1 }, --
    seal_fate              = { 79622, 14190 , 2 }, --
    sepsis                 = { 79510, 385408, 1 }, --
    shadow_dance           = { 79623, 185313, 1 }, --
    shadowrunner           = { 79651, 378807, 1 }, --
    shadowstep             = { 79627, 36554 , 1 }, --
    shiv                   = { 79645, 5938  , 1 }, --
    sleight_of_hand        = { 79519, 381839, 1 }, --
    slicerdicer            = { 79550, 381988, 1 }, --
    so_versatile           = { 79631, 381619, 2 }, --
    subterfuge             = { 79650, 108208, 1 }, --
    take_em_by_surprise    = { 79509, 382742, 2 }, --
    thistle_tea            = { 79620, 381623, 1 }, --
    tight_spender          = { 79488, 381621, 2 }, --
    tricks_of_the_trade    = { 79626, 57934 , 1 }, --
    triple_threat          = { 79513, 381894, 2 }, --
    vigor                  = { 79619, 14983 , 1 }, --
    virulent_poisons       = { 79640, 381543, 1 }, --
    weaponmaster           = { 79545, 200733, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    boarding_party       = 853 , -- 209752
    control_is_king      = 138 , -- 354406
    dagger_in_the_dark   = 5549, -- 198675
    death_from_above     = 3619, -- 269513
    dismantle            = 145 , -- 207777
    drink_up_me_hearties = 139 , -- 354425
    enduring_brawler     = 5412, -- 354843
    maneuverability      = 129 , -- 197000
    smoke_bomb           = 3483, -- 212182
    take_your_cut        = 135 , -- 198265
    thick_as_thieves     = 1208, -- 221622
    turn_the_tables      = 3421, -- 198020
    veil_of_midnight     = 5516, -- 198952
} )


-- Auras
spec:RegisterAuras( {
    adrenaline_rush = {
        id = 13750,
    },
    amplifying_poison = {
        id = 381664,
    },
    atrophic_poison = {
        id = 381637,
    },
    blade_flurry = {
        id = 13877,
    },
    cloak_of_shadows = {
        id = 31224,
    },
    cold_blood = {
        id = 382245,
    },
    crimson_vial = {
        id = 185311,
    },
    deadly_poison = {
        id = 2823,
    },
    death_from_above = {
        id = 269513,
    },
    dreadblades = {
        id = 343142,
    },
    evasion = {
        id = 5277,
    },
    feint = {
        id = 1966,
    },
    indiscriminate_carnage = {
        id = 381802,
    },
    keep_it_rolling = {
        id = 381989,
    },
    killing_spree = {
        id = 51690,
    },
    mastery_main_gauche = {
        id = 76806,
    },
    numbing_poison = {
        id = 5761,
    },
    roll_the_bones = {
        id = 315508,
    },
    safe_fall = {
        id = 1860,
    },
    shadow_dance = {
        id = 185313,
    },
    shadowstep = {
        id = 36554,
    },
    shroud_of_concealment = {
        id = 114018,
    },
    sign_of_the_emissary = {
        id = 225788,
        duration = 3600,
        max_stack = 1,
    },
    slice_and_dice = {
        id = 315496,
    },
    stealth = {
        id = 1784,
    },
    wound_poison = {
        id = 8679,
    },
} )


-- Abilities
spec:RegisterAbilities( {
    adrenaline_rush = {
        id = 13750,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "adrenaline_rush",
        startsCombat = false,
        texture = 136206,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    ambush = {
        id = 8676,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 50,
        spendType = "energy",

        startsCombat = true,
        texture = 132282,

        handler = function ()
        end,
    },


    amplifying_poison = {
        id = 381664,
        cast = 1.5,
        cooldown = 0,
        gcd = "totem",

        talent = "amplifying_poison",
        startsCombat = false,
        texture = 134207,

        handler = function ()
        end,
    },


    atrophic_poison = {
        id = 381637,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        talent = "atrophic_poison",
        startsCombat = false,
        texture = 132300,

        handler = function ()
        end,
    },


    between_the_eyes = {
        id = 315341,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        talent = "between_the_eyes",
        startsCombat = false,
        texture = 135610,

        handler = function ()
        end,
    },


    blade_flurry = {
        id = 13877,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        spend = 15,
        spendType = "energy",

        talent = "blade_flurry",
        startsCombat = false,
        texture = 132350,

        handler = function ()
        end,
    },


    blade_rush = {
        id = 271877,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        talent = "blade_rush",
        startsCombat = false,
        texture = 1016243,

        handler = function ()
        end,
    },


    blind = {
        id = 2094,
        cast = 0,
        cooldown = 120,
        gcd = "totem",

        talent = "blind",
        startsCombat = true,
        texture = 136175,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    cheap_shot = {
        id = 1833,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 40,
        spendType = "energy",

        startsCombat = true,
        texture = 132092,

        handler = function ()
        end,
    },


    cloak_of_shadows = {
        id = 31224,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "cloak_of_shadows",
        startsCombat = false,
        texture = 136177,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    cold_blood = {
        id = 382245,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        talent = "cold_blood",
        startsCombat = false,
        texture = 135988,

        handler = function ()
        end,
    },


    crimson_tempest = {
        id = 121411,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        talent = "crimson_tempest",
        startsCombat = false,
        texture = 464079,

        handler = function ()
        end,
    },


    crimson_vial = {
        id = 185311,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        spend = 20,
        spendType = "energy",

        startsCombat = false,
        texture = 1373904,

        handler = function ()
        end,
    },


    deadly_poison = {
        id = 2823,
        cast = 1.5,
        cooldown = 0,
        gcd = "totem",

        talent = "deadly_poison",
        startsCombat = false,
        texture = 132290,

        handler = function ()
        end,
    },


    death_from_above = {
        id = 269513,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        icd = 2,

        spend = 25,
        spendType = "energy",

        pvptalent = "death_from_above",
        startsCombat = false,
        texture = 1043573,

        handler = function ()
        end,
    },


    deathmark = {
        id = 360194,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "deathmark",
        startsCombat = false,
        texture = 4667421,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dismantle = {
        id = 207777,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        pvptalent = "dismantle",
        startsCombat = false,
        texture = 236272,

        handler = function ()
        end,
    },


    dispatch = {
        id = 2098,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        startsCombat = false,
        texture = 236286,

        handler = function ()
        end,
    },


    distract = {
        id = 1725,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        spend = 30,
        spendType = "energy",

        startsCombat = true,
        texture = 132289,

        handler = function ()
        end,
    },


    dreadblades = {
        id = 343142,
        cast = 0,
        cooldown = 90,
        gcd = "totem",

        spend = 30,
        spendType = "energy",

        talent = "dreadblades",
        startsCombat = false,
        texture = 1301078,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    echoing_reprimand = {
        id = 385616,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 10,
        spendType = "energy",

        talent = "echoing_reprimand",
        startsCombat = false,
        texture = 3565450,

        handler = function ()
        end,
    },


    evasion = {
        id = 5277,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "evasion",
        startsCombat = false,
        texture = 136205,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    exsanguinate = {
        id = 200806,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        talent = "exsanguinate",
        startsCombat = false,
        texture = 538040,

        handler = function ()
        end,
    },


    feint = {
        id = 1966,
        cast = 0,
        cooldown = 15,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        talent = "feint",
        startsCombat = false,
        texture = 132294,

        handler = function ()
        end,
    },


    ghostly_strike = {
        id = 196937,
        cast = 0,
        cooldown = 35,
        gcd = "totem",

        spend = 30,
        spendType = "energy",

        talent = "ghostly_strike",
        startsCombat = false,
        texture = 132094,

        handler = function ()
        end,
    },


    gouge = {
        id = 1776,
        cast = 0,
        cooldown = 20,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        talent = "gouge",
        startsCombat = false,
        texture = 132155,

        handler = function ()
        end,
    },


    grappling_hook = {
        id = 195457,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        talent = "grappling_hook",
        startsCombat = false,
        texture = 1373906,

        handler = function ()
        end,
    },


    indiscriminate_carnage = {
        id = 381802,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "indiscriminate_carnage",
        startsCombat = false,
        texture = 4667422,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    keep_it_rolling = {
        id = 381989,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        talent = "keep_it_rolling",
        startsCombat = false,
        texture = 4667423,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    kick = {
        id = 1766,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        startsCombat = true,
        texture = 132219,

        handler = function ()
        end,
    },


    kidney_shot = {
        id = 408,
        cast = 0,
        cooldown = 20,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132298,

        handler = function ()
        end,
    },


    killing_spree = {
        id = 51690,
        cast = 0,
        cooldown = 120,
        gcd = "totem",

        talent = "killing_spree",
        startsCombat = false,
        texture = 236277,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    kingsbane = {
        id = 385627,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        talent = "kingsbane",
        startsCombat = false,
        texture = 1259291,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    marked_for_death = {
        id = 137619,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "marked_for_death",
        startsCombat = false,
        texture = 236364,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    numbing_poison = {
        id = 5761,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        talent = "numbing_poison",
        startsCombat = false,
        texture = 136066,

        handler = function ()
        end,
    },


    ph_pocopoc_zone_ability_skill = {
        id = 363942,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        startsCombat = false,
        texture = 4239318,

        handler = function ()
        end,
    },


    pick_lock = {
        id = 1804,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        startsCombat = true,
        texture = 136058,

        handler = function ()
        end,
    },


    pick_pocket = {
        id = 921,
        cast = 0,
        cooldown = 0.5,
        gcd = "off",

        startsCombat = true,
        texture = 133644,

        handler = function ()
        end,
    },


    pistol_shot = {
        id = 185763,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 40,
        spendType = "energy",

        startsCombat = true,
        texture = 1373908,

        handler = function ()
        end,
    },


    roll_the_bones = {
        id = 315508,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        talent = "roll_the_bones",
        startsCombat = false,
        texture = 1373910,

        handler = function ()
        end,
    },


    sap = {
        id = 6770,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        talent = "sap",
        startsCombat = false,
        texture = 132310,

        handler = function ()
        end,
    },


    sepsis = {
        id = 385408,
        cast = 0,
        cooldown = 90,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        talent = "sepsis",
        startsCombat = false,
        texture = 3636848,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    serrated_bone_spike = {
        id = 385424,
        cast = 0,
        charges = 3,
        cooldown = 30,
        recharge = 30,
        gcd = "totem",

        spend = 15,
        spendType = "energy",

        talent = "serrated_bone_spike",
        startsCombat = false,
        texture = 3578230,

        handler = function ()
        end,
    },


    shadow_dance = {
        id = 185313,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "off",

        talent = "shadow_dance",
        startsCombat = false,
        texture = 236279,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    shadowstep = {
        id = 36554,
        cast = 0,
        charges = 1,
        cooldown = 30,
        recharge = 30,
        gcd = "off",

        talent = "shadowstep",
        startsCombat = false,
        texture = 132303,

        handler = function ()
        end,
    },


    shiv = {
        id = 5938,
        cast = 0,
        cooldown = 25,
        gcd = "totem",

        spend = 20,
        spendType = "energy",

        talent = "shiv",
        startsCombat = false,
        texture = 135428,

        handler = function ()
        end,
    },


    shroud_of_concealment = {
        id = 114018,
        cast = 0,
        cooldown = 360,
        gcd = "totem",

        startsCombat = false,
        texture = 635350,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    sinister_strike = {
        id = 193315,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 45,
        spendType = "energy",

        startsCombat = false,
        texture = 136189,

        handler = function ()
        end,
    },


    slice_and_dice = {
        id = 315496,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = false,
        texture = 132306,

        handler = function ()
        end,
    },


    smoke_bomb = {
        id = 212182,
        cast = 0,
        cooldown = 180,
        gcd = "totem",

        pvptalent = "smoke_bomb",
        startsCombat = false,
        texture = 458733,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    sprint = {
        id = 2983,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 132307,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    stealth = {
        id = 1784,
        cast = 0,
        cooldown = 2,
        gcd = "off",

        startsCombat = false,
        texture = 132320,

        handler = function ()
        end,
    },


    thistle_tea = {
        id = 381623,
        cast = 0,
        charges = 3,
        cooldown = 60,
        recharge = 60,
        gcd = "off",

        talent = "thistle_tea",
        startsCombat = false,
        texture = 132819,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    tricks_of_the_trade = {
        id = 57934,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        talent = "tricks_of_the_trade",
        startsCombat = false,
        texture = 236283,

        handler = function ()
        end,
    },


    vanish = {
        id = 1856,
        cast = 0,
        charges = 1,
        cooldown = 120,
        recharge = 120,
        gcd = "off",

        startsCombat = false,
        texture = 132331,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    wound_poison = {
        id = 8679,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        startsCombat = false,
        texture = 134197,

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Outlaw", 20220917,
-- Notes
[[

]],
-- Priority
[[

]] )