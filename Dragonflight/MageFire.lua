-- MageFire.lua
-- September 2022

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 63 )

spec:RegisterResource( Enum.PowerType.ArcaneCharges )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    accumulative_shielding   = { 62093, 382800, 2 }, --
    alexstraszas_fury        = { 62220, 235870, 1 }, --
    alter_time               = { 62115, 342245, 1 }, --
    arcane_warding           = { 62114, 383092, 2 }, --
    blast_wave               = { 62103, 157981, 1 }, --
    blaster_master           = { 62195, 383391, 2 }, --
    blazing_barrier          = { 62119, 235313, 1 }, --
    cauterize                = { 62206, 86949 , 1 }, --
    combustion               = { 62207, 190319, 1 }, --
    combustion_duration_2    = { 62201, 321710, 1 }, --
    conflagration            = { 62188, 205023, 1 }, --
    controlled_destruction   = { 62204, 383669, 2 }, --
    critical_mass            = { 62219, 117216, 2 }, --
    cryofreeze               = { 62107, 382292, 2 }, --
    diverted_energy          = { 62101, 382270, 2 }, --
    dragons_breath           = { 62091, 31661 , 1 }, --
    energized_barriers       = { 62100, 386828, 1 }, --
    enhanced_pyrotechnics    = { 62218, 157642, 1 }, --
    fervent_flickering       = { 62192, 387044, 1 }, --
    fevered_incantation      = { 62187, 383810, 2 }, --
    fiery_rush               = { 62203, 383634, 1 }, --
    fire_blast               = { 62214, 108853, 1 }, --
    fire_frenzy              = { 62186, 383860, 1 }, --
    firemind                 = { 62208, 383499, 2 }, --
    firestarter              = { 62083, 205026, 1 }, --
    flame_on                 = { 62190, 205029, 2 }, --
    flame_patch              = { 62193, 205037, 1 }, --
    flamestrike              = { 62216, 2120  , 1 }, --
    flow_of_time             = { 62096, 382268, 2 }, --
    freezing_cold            = { 62087, 386763, 1 }, --
    frigid_winds             = { 62128, 235224, 2 }, --
    from_the_ashes           = { 62220, 342344, 1 }, --
    greater_invisibility     = { 62095, 110959, 1 }, --
    grounding_surge          = { 62104, 382297, 1 }, --
    ice_block                = { 62122, 45438 , 1 }, --
    ice_floes                = { 62105, 108839, 1 }, --
    ice_nova                 = { 62126, 157997, 1 }, --
    ice_ward                 = { 62086, 205036, 1 }, --
    improved_flamestrike     = { 62191, 343230, 1 }, --
    improved_frost_nova      = { 62108, 343183, 1 }, --
    improved_scorch          = { 62211, 383604, 2 }, --
    incantation_of_swiftness = { 62112, 382293, 2 }, --
    incanters_flow           = { 62113, 1463  , 1 }, --
    incendiary_eruptions     = { 62189, 383665, 1 }, --
    invisibility             = { 62118, 66    , 1 }, --
    kindling                 = { 62198, 155148, 1 }, --
    living_bomb              = { 62194, 44457 , 1 }, --
    mass_polymorph           = { 62106, 383121, 1 }, --
    master_of_flame          = { 62196, 384174, 1 }, --
    master_of_time           = { 62102, 342249, 1 }, --
    meteor                   = { 62090, 153561, 1 }, --
    mirror_image             = { 62124, 55342 , 1 }, --
    molten_skyfall           = { 62197, 384033, 1 }, --
    overflowing_energy_nyi   = { 62120, 390218, 1 }, --
    phoenix_flames           = { 62217, 257541, 1 }, --
    phoenix_flames_2         = { 62210, 343222, 1 }, --
    phoenix_reborn           = { 62209, 383476, 1 }, --
    pyroblast                = { 62215, 11366 , 1 }, --
    pyroclasm                = { 62199, 269650, 1 }, --
    pyromaniac               = { 62197, 205020, 1 }, --
    reabsorption             = { 62125, 382820, 1 }, --
    reduplication            = { 62125, 382569, 1 }, --
    reflection               = { 62092, 389713, 1 }, --
    remove_curse             = { 62116, 475   , 1 }, --
    rigid_ice                = { 62110, 382481, 1 }, --
    ring_of_frost            = { 62088, 113724, 1 }, --
    rune_of_power            = { 62113, 116011, 1 }, --
    scorch                   = { 62213, 2948  , 1 }, --
    searing_touch            = { 62212, 269644, 1 }, --
    shifting_power           = { 62085, 382440, 1 }, --
    shimmer                  = { 62105, 212653, 1 }, --
    sloooow_down             = { 62109, 391102, 1 }, --
    slow                     = { 62097, 31589 , 1 }, --
    spellsteal               = { 62084, 30449 , 1 }, --
    sun_kings_blessing       = { 62205, 383886, 1 }, --
    tempered_flames          = { 62201, 383659, 1 }, --
    tempest_barrier          = { 62111, 382289, 2 }, --
    temporal_velocity        = { 62099, 382826, 2 }, --
    temporal_warp            = { 62094, 386539, 1 }, --
    time_anomaly             = { 62094, 383243, 1 }, --
    time_manipulation        = { 62129, 387807, 2 }, --
    tinder                   = { 62200, 203275, 2 }, --
    tome_of_antonidas        = { 62098, 382490, 1 }, --
    tome_of_rhonin           = { 62127, 382493, 1 }, --
    volatile_detonation      = { 62089, 389627, 1 }, --
    wildfire                 = { 62202, 383489, 2 }, --
    winters_protection       = { 62123, 382424, 2 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    flamecannon       = 647 , -- 203284
    glass_cannon      = 5495, -- 390428
    greater_pyroblast = 648 , -- 203286
    ice_wall          = 5489, -- 352278
    netherwind_armor  = 53  , -- 198062
    precognition      = 5493, -- 377360
    prismatic_cloak   = 828 , -- 198064
    pyrokinesis       = 646 , -- 203283
    ring_of_fire      = 5389, -- 353082
    world_in_flames   = 644 , -- 203280
} )


-- Auras
spec:RegisterAuras( {
    blazing_barrier = {
        id = 235313,
    },
    blink = {
        id = 1953,
    },
    cauterize = {
        id = 86949,
    },
    combustion = {
        id = 190319,
    },
    critical_mass = {
        id = 117216,
    },
    firemind = {
        id = 383499,
    },
    ice_block = {
        id = 45438,
    },
    ice_floes = {
        id = 108839,
    },
    ice_wall = {
        id = 352278,
    },
    invisibility = {
        id = 66,
    },
    mastery_ignite = {
        id = 12846,
    },
    mirror_image = {
        id = 55342,
    },
    overflowing_energy_nyi = {
        id = 390218,
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
    temporal_warp = {
        id = 386539,
    },
    tinder = {
        id = 203277,
        duration = 3600,
        max_stack = 1,
    },
    wildfire = {
        id = 383489,
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


    blazing_barrier = {
        id = 235313,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "blazing_barrier",
        startsCombat = false,
        texture = 132221,

        handler = function ()
        end,
    },


    blink = {
        id = 1953,
        cast = 0,
        charges = 1,
        cooldown = 13.38,
        recharge = 13.38,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 135736,

        handler = function ()
        end,
    },


    combustion = {
        id = 190319,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        spend = 0.1,
        spendType = "mana",

        talent = "combustion",
        startsCombat = false,
        texture = 135824,

        toggle = "cooldowns",

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


    fire_blast = {
        id = 108853,
        cast = 0,
        charges = 3,
        cooldown = 10,
        recharge = 10,
        gcd = "off",

        spend = 0.01,
        spendType = "mana",

        talent = "fire_blast",
        startsCombat = false,
        texture = 135807,

        handler = function ()
        end,
    },


    fireball = {
        id = 133,
        cast = 1.35,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135812,

        handler = function ()
        end,
    },


    flamestrike = {
        id = 2120,
        cast = 4,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "flamestrike",
        startsCombat = true,
        texture = 135826,

        handler = function ()
        end,
    },


    frost_nova = {
        id = 122,
        cast = 0,
        charges = 2,
        cooldown = 30.88,
        recharge = 30.88,
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


    greater_pyroblast = {
        id = 203286,
        cast = 4.5,
        cooldown = 15,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        pvptalent = "greater_pyroblast",
        startsCombat = false,
        texture = 1387354,

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
        cooldown = 20.59,
        recharge = 20.59,
        gcd = "off",

        talent = "ice_floes",
        startsCombat = false,
        texture = 610877,

        handler = function ()
        end,
    },


    ice_nova = {
        id = 157997,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        talent = "ice_nova",
        startsCombat = true,
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


    living_bomb = {
        id = 44457,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "living_bomb",
        startsCombat = true,
        texture = 236220,

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
        startsCombat = true,
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


    phoenix_flames = {
        id = 257541,
        cast = 0,
        charges = 2,
        cooldown = 25.74,
        recharge = 25.74,
        gcd = "spell",

        talent = "phoenix_flames",
        startsCombat = true,
        texture = 1392549,

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


    pyroblast = {
        id = 11366,
        cast = 2.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "pyroblast",
        startsCombat = true,
        texture = 135808,

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
        cooldown = 46.32,
        recharge = 46.32,
        gcd = "spell",

        talent = "rune_of_power",
        startsCombat = true,
        texture = 609815,

        handler = function ()
        end,
    },


    scorch = {
        id = 2948,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "scorch",
        startsCombat = true,
        texture = 135827,

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
        cooldown = 23.68,
        recharge = 23.68,
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


    spellsteal = {
        id = 30449,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.21,
        spendType = "mana",

        talent = "spellsteal",
        startsCombat = true,
        texture = 135729,

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

spec:RegisterPriority( "Fire", 20220917,
-- Notes
[[

]],
-- Priority
[[

]] )