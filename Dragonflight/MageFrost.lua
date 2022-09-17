-- MageFrost.lua
-- September 2022

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 64 )

spec:RegisterResource( Enum.PowerType.ArcaneCharges )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    accumulative_shielding   = { 62093, 382800, 2 }, --
    alter_time               = { 62115, 342245, 1 }, --
    arcane_warding           = { 62114, 383092, 2 }, --
    arctic_piercing          = { 62166, 378919, 1 }, --
    blast_wave               = { 62103, 157981, 1 }, --
    blizzard                 = { 62175, 190356, 1 }, --
    bone_chilling            = { 62167, 205027, 1 }, --
    brain_freeze             = { 62179, 190447, 1 }, --
    chain_reaction           = { 62155, 278309, 1 }, --
    cold_front               = { 62185, 382110, 1 }, --
    cold_snap                = { 62174, 235219, 1 }, --
    comet_storm              = { 62183, 153595, 1 }, --
    cryofreeze               = { 62107, 382292, 2 }, --
    deep_shatter             = { 62159, 378749, 2 }, --
    diverted_energy          = { 62101, 382270, 2 }, --
    dragons_breath           = { 62091, 31661 , 1 }, --
    ebonbolt                 = { 62180, 257537, 1 }, --
    energized_barriers       = { 62100, 386828, 1 }, --
    everlasting_frost        = { 62169, 385167, 1 }, --
    fingers_of_frost         = { 62164, 112965, 1 }, --
    flash_freeze             = { 62168, 379993, 1 }, --
    flow_of_time             = { 62096, 382268, 2 }, --
    flurry                   = { 62178, 44614 , 1 }, --
    fractured_frost          = { 62184, 378448, 2 }, --
    freezing_cold            = { 62087, 386763, 1 }, --
    freezing_rain            = { 62150, 270233, 1 }, --
    freezing_winds           = { 62151, 382103, 1 }, --
    frigid_shattering        = { 62160, 380154, 2 }, --
    frigid_winds             = { 62128, 235224, 2 }, --
    frostbite                = { 62149, 378756, 1 }, --
    frozen_orb               = { 62177, 84714 , 1 }, --
    frozen_touch             = { 62180, 205030, 1 }, --
    glacial_assault          = { 62182, 378947, 2 }, --
    glacial_spike            = { 62157, 199786, 1 }, --
    greater_invisibility     = { 62095, 110959, 1 }, --
    grounding_surge          = { 62104, 382297, 1 }, --
    hailstones               = { 62158, 381244, 2 }, --
    ice_barrier              = { 62117, 11426 , 1 }, --
    ice_block                = { 62122, 45438 , 1 }, --
    ice_floes                = { 62105, 108839, 1 }, --
    ice_lance                = { 62176, 30455 , 1 }, --
    ice_nine                 = { 62162, 379049, 2 }, --
    ice_nova                 = { 62126, 157997, 1 }, --
    ice_ward                 = { 62086, 205036, 1 }, --
    icy_propulsion           = { 62154, 378433, 1 }, --
    icy_veins                = { 62171, 12472 , 1 }, --
    improved_blizzard        = { 62169, 236662, 1 }, --
    improved_frost_nova      = { 62108, 343183, 1 }, --
    improved_icy_veins       = { 62153, 321702, 2 }, --
    incantation_of_swiftness = { 62112, 382293, 2 }, --
    incanters_flow           = { 62113, 1463  , 1 }, --
    invisibility             = { 62118, 66    , 1 }, --
    lonely_winter            = { 62173, 205024, 1 }, --
    mass_polymorph           = { 62106, 383121, 1 }, --
    master_of_time           = { 62102, 342249, 1 }, --
    meteor                   = { 62090, 153561, 1 }, --
    mirror_image             = { 62124, 55342 , 1 }, --
    overflowing_energy_nyi   = { 62120, 390218, 1 }, --
    perpetual_winter         = { 62181, 378198, 1 }, --
    ray_of_frost             = { 62163, 205021, 1 }, --
    reabsorption             = { 62125, 382820, 1 }, --
    reduplication            = { 62125, 382569, 1 }, --
    reflection               = { 62092, 389713, 1 }, --
    remove_curse             = { 62116, 475   , 1 }, --
    rigid_ice                = { 62110, 382481, 1 }, --
    ring_of_frost            = { 62088, 113724, 1 }, --
    rune_of_power            = { 62113, 116011, 1 }, --
    shatter                  = { 62165, 12982 , 1 }, --
    shifting_power           = { 62085, 382440, 1 }, --
    shimmer                  = { 62105, 212653, 1 }, --
    slick_ice                = { 62151, 382144, 1 }, --
    sloooow_down             = { 62109, 391102, 1 }, --
    slow                     = { 62097, 31589 , 1 }, --
    snap_freeze              = { 62152, 378901, 1 }, --
    snowstorm                = { 62170, 381706, 2 }, --
    spellsteal               = { 62084, 30449 , 1 }, --
    splitting_ice            = { 62161, 56377 , 1 }, --
    summon_water_elemental   = { 62173, 31687 , 1 }, --
    tempest_barrier          = { 62111, 382289, 2 }, --
    temporal_velocity        = { 62099, 382826, 2 }, --
    temporal_warp            = { 62094, 386539, 1 }, --
    thermal_void             = { 62156, 155149, 1 }, --
    time_anomaly             = { 62094, 383243, 1 }, --
    time_manipulation        = { 62129, 387807, 2 }, --
    tome_of_antonidas        = { 62098, 382490, 1 }, --
    tome_of_rhonin           = { 62127, 382493, 1 }, --
    volatile_detonation      = { 62089, 389627, 1 }, --
    winters_protection       = { 62123, 382424, 2 }, --
    wintertide               = { 62172, 378406, 2 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chilled_to_the_bone   = 66  , -- 198126
    concentrated_coolness = 632 , -- 198148
    frost_bomb            = 5496, -- 390612
    ice_form              = 634 , -- 198144
    ice_wall              = 5390, -- 352278
    netherwind_armor      = 3443, -- 198062
    precognition          = 5494, -- 377360
    prismatic_cloak       = 3532, -- 198064
    ring_of_fire          = 5490, -- 353082
    snowdrift             = 5497, -- 389794
} )


-- Auras
spec:RegisterAuras( {
    blink = {
        id = 1953,
    },
    ice_barrier = {
        id = 11426,
    },
    ice_block = {
        id = 45438,
    },
    ice_floes = {
        id = 108839,
    },
    ice_form = {
        id = 198144,
    },
    ice_wall = {
        id = 352278,
    },
    icy_veins = {
        id = 12472,
    },
    invisibility = {
        id = 66,
    },
    mastery_icicles = {
        id = 76613,
    },
    mirror_image = {
        id = 55342,
    },
    shifting_power = {
        id = 382440,
    },
    shimmer = {
        id = 212653,
    },
    sign_of_the_emissary = {
        id = 225788,
        duration = 3600,
        max_stack = 1,
    },
    snowdrift = {
        id = 389794,
    },
    summon_water_elemental = {
        id = 31687,
    },
} )


-- Abilities
spec:RegisterAbilities( {
    alter_time = {
        id = 342245,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0.01,
        spendType = "mana",

        talent = "alter_time",
        startsCombat = false,
        texture = 609811,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    arcane_explosion = {
        id = 1449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 136116,

        handler = function ()
        end,
    },


    arcane_intellect = {
        id = 1459,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 135932,

        handler = function ()
        end,
    },


    blast_wave = {
        id = 157981,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "blast_wave",
        startsCombat = false,
        texture = 135903,

        handler = function ()
        end,
    },


    blink = {
        id = 1953,
        cast = 0,
        charges = 1,
        cooldown = 15.14,
        recharge = 15.14,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 135736,

        handler = function ()
        end,
    },


    blizzard = {
        id = 190356,
        cast = 2,
        cooldown = 8,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "blizzard",
        startsCombat = false,
        texture = 135857,

        handler = function ()
        end,
    },


    cold_snap = {
        id = 235219,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        talent = "cold_snap",
        startsCombat = false,
        texture = 135865,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    comet_storm = {
        id = 153595,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "comet_storm",
        startsCombat = false,
        texture = 2126034,

        handler = function ()
        end,
    },


    cone_of_cold = {
        id = 120,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 135852,

        handler = function ()
        end,
    },


    conjure_refreshment = {
        id = 190336,
        cast = 3,
        cooldown = 15,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 134029,

        handler = function ()
        end,
    },


    counterspell = {
        id = 2139,
        cast = 0,
        cooldown = 24,
        gcd = "off",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135856,

        handler = function ()
        end,
    },


    dragons_breath = {
        id = 31661,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "dragons_breath",
        startsCombat = false,
        texture = 134153,

        handler = function ()
        end,
    },


    ebonbolt = {
        id = 257537,
        cast = 2.5,
        cooldown = 45,
        gcd = "spell",

        talent = "ebonbolt",
        startsCombat = false,
        texture = 1392551,

        handler = function ()
        end,
    },


    fire_blast = {
        id = 319836,
        cast = 0,
        charges = 1,
        cooldown = 12,
        recharge = 12,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 135807,

        handler = function ()
        end,
    },


    flurry = {
        id = 44614,
        cast = 0,
        charges = 1,
        cooldown = 30.28,
        recharge = 30.28,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "flurry",
        startsCombat = false,
        texture = 1506795,

        handler = function ()
        end,
    },


    frost_bomb = {
        id = 390612,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "frost_bomb",
        startsCombat = false,
        texture = 609814,

        handler = function ()
        end,
    },


    frost_nova = {
        id = 122,
        cast = 0,
        charges = 1,
        cooldown = 30.28,
        recharge = 30.28,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135848,

        handler = function ()
        end,
    },


    frostbolt = {
        id = 116,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135846,

        handler = function ()
        end,
    },


    frozen_orb = {
        id = 84714,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "frozen_orb",
        startsCombat = false,
        texture = 629077,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    glacial_spike = {
        id = 199786,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "glacial_spike",
        startsCombat = false,
        texture = 1698699,

        handler = function ()
        end,
    },


    greater_invisibility = {
        id = 110959,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "greater_invisibility",
        startsCombat = false,
        texture = 575584,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    ice_barrier = {
        id = 11426,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "ice_barrier",
        startsCombat = false,
        texture = 135988,

        handler = function ()
        end,
    },


    ice_block = {
        id = 45438,
        cast = 0,
        cooldown = 240,
        gcd = "spell",

        talent = "ice_block",
        startsCombat = false,
        texture = 135841,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    ice_floes = {
        id = 108839,
        cast = 0,
        charges = 3,
        cooldown = 20.18,
        recharge = 20.18,
        gcd = "off",

        talent = "ice_floes",
        startsCombat = false,
        texture = 610877,

        handler = function ()
        end,
    },


    ice_form = {
        id = 198144,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        pvptalent = "ice_form",
        startsCombat = false,
        texture = 1387355,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    ice_lance = {
        id = 30455,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "ice_lance",
        startsCombat = false,
        texture = 135844,

        handler = function ()
        end,
    },


    ice_nova = {
        id = 157997,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        talent = "ice_nova",
        startsCombat = false,
        texture = 1033909,

        handler = function ()
        end,
    },


    ice_wall = {
        id = 352278,
        cast = 1.5,
        cooldown = 90,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        pvptalent = "ice_wall",
        startsCombat = false,
        texture = 4226156,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    icy_veins = {
        id = 12472,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "icy_veins",
        startsCombat = false,
        texture = 135838,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    invisibility = {
        id = 66,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "invisibility",
        startsCombat = false,
        texture = 132220,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    mass_polymorph = {
        id = 383121,
        cast = 1.7,
        cooldown = 60,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "mass_polymorph",
        startsCombat = false,
        texture = 575585,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    meteor = {
        id = 153561,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "meteor",
        startsCombat = false,
        texture = 1033911,

        handler = function ()
        end,
    },


    mirror_image = {
        id = 55342,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "mirror_image",
        startsCombat = false,
        texture = 135994,

        toggle = "cooldowns",

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


    polymorph = {
        id = 118,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 136071,

        handler = function ()
        end,
    },


    ray_of_frost = {
        id = 205021,
        cast = 0,
        cooldown = 75,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "ray_of_frost",
        startsCombat = false,
        texture = 1698700,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    reflection = {
        id = 389713,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "reflection",
        startsCombat = false,
        texture = 132171,

        handler = function ()
        end,
    },


    remove_curse = {
        id = 475,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "remove_curse",
        startsCombat = false,
        texture = 136082,

        handler = function ()
        end,
    },


    ring_of_fire = {
        id = 353082,
        cast = 2,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        pvptalent = "ring_of_fire",
        startsCombat = false,
        texture = 4067368,

        handler = function ()
        end,
    },


    ring_of_frost = {
        id = 113724,
        cast = 2,
        cooldown = 45,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "ring_of_frost",
        startsCombat = false,
        texture = 464484,

        handler = function ()
        end,
    },


    rune_of_power = {
        id = 116011,
        cast = 1.5,
        charges = 1,
        cooldown = 45.42,
        recharge = 45.42,
        gcd = "spell",

        talent = "rune_of_power",
        startsCombat = false,
        texture = 609815,

        handler = function ()
        end,
    },


    shifting_power = {
        id = 382440,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        talent = "shifting_power",
        startsCombat = false,
        texture = 3636841,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    shimmer = {
        id = 212653,
        cast = 0,
        charges = 2,
        cooldown = 25.23,
        recharge = 25.23,
        gcd = "off",

        spend = 0.02,
        spendType = "mana",

        talent = "shimmer",
        startsCombat = false,
        texture = 135739,

        handler = function ()
        end,
    },


    slow = {
        id = 31589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "slow",
        startsCombat = false,
        texture = 136091,

        handler = function ()
        end,
    },


    slow_fall = {
        id = 130,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135992,

        handler = function ()
        end,
    },


    snowdrift = {
        id = 389794,
        cast = 1.5,
        cooldown = 60,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        pvptalent = "snowdrift",
        startsCombat = false,
        texture = 135783,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    spellsteal = {
        id = 30449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.21,
        spendType = "mana",

        talent = "spellsteal",
        startsCombat = false,
        texture = 135729,

        handler = function ()
        end,
    },


    summon_water_elemental = {
        id = 31687,
        cast = 1.5,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "summon_water_elemental",
        startsCombat = false,
        texture = 135862,

        handler = function ()
        end,
    },


    teleport_undercity = {
        id = 3563,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135766,

        handler = function ()
        end,
    },


    time_warp = {
        id = 80353,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 458224,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Frost", 20220917,
-- Notes
[[

]],
-- Priority
[[

]] )