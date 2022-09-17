-- MageArcane.lua
-- September 2022

if UnitClassBase( "player" ) ~= "MAGE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 62 )

spec:RegisterResource( Enum.PowerType.ArcaneCharges )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    accumulative_shielding     = { 62093, 382800, 2 }, --
    alter_time                 = { 62115, 342245, 1 }, --
    amplification              = { 62225, 236628, 1 }, --
    arcane_barrage             = { 62237, 44425 , 1 }, --
    arcane_bombardment         = { 62234, 384581, 1 }, --
    arcane_echo                = { 62131, 342231, 1 }, --
    arcane_familiar            = { 62145, 205022, 1 }, --
    arcane_harmony             = { 62135, 384452, 1 }, --
    arcane_missiles            = { 62238, 5143  , 1 }, --
    arcane_orb                 = { 62239, 153626, 1 }, --
    arcane_power               = { 62130, 321739, 1 }, --
    arcane_surge               = { 62230, 365350, 1 }, --
    arcane_tempo               = { 62144, 383980, 1 }, --
    arcane_warding             = { 62114, 383092, 2 }, --
    blast_wave                 = { 62103, 157981, 1 }, --
    cascading_power            = { 62133, 384276, 1 }, --
    charged_orb                = { 62241, 384651, 1 }, --
    chrono_shift               = { 62141, 235711, 1 }, --
    clearcasting               = { 62229, 79684 , 1 }, --
    concentration              = { 62134, 384374, 1 }, --
    conjure_mana_gem           = { 62132, 759   , 1 }, --
    cryofreeze                 = { 62107, 382292, 2 }, --
    diverted_energy            = { 62101, 382270, 2 }, --
    dragons_breath             = { 62091, 31661 , 1 }, --
    energized_barriers         = { 62100, 386828, 1 }, --
    enlightened                = { 62143, 321387, 1 }, --
    evocation                  = { 62147, 12051 , 1 }, --
    flow_of_time               = { 62096, 382268, 2 }, --
    foresight                  = { 62142, 384861, 1 }, --
    freezing_cold              = { 62087, 386763, 1 }, --
    frigid_winds               = { 62128, 235224, 2 }, --
    greater_invisibility       = { 62095, 110959, 1 }, --
    grounding_surge            = { 62104, 382297, 1 }, --
    harmonic_echo              = { 62236, 384683, 1 }, --
    ice_block                  = { 62122, 45438 , 1 }, --
    ice_floes                  = { 62105, 108839, 1 }, --
    ice_nova                   = { 62126, 157997, 1 }, --
    ice_ward                   = { 62086, 205036, 1 }, --
    illuminated_thoughts       = { 62223, 384060, 2 }, --
    impetus                    = { 62226, 383676, 1 }, --
    improved_arcane_barrage    = { 62139, 231564, 1 }, --
    improved_arcane_explosion  = { 62228, 321752, 2 }, --
    improved_arcane_missiles   = { 62240, 383661, 2 }, --
    improved_clearcasting      = { 62224, 321420, 1 }, --
    improved_frost_nova        = { 62108, 343183, 1 }, --
    improved_prismatic_barrier = { 62232, 321745, 1 }, --
    incantation_of_swiftness   = { 62112, 382293, 2 }, --
    incanters_flow             = { 62113, 1463  , 1 }, --
    invisibility               = { 62118, 66    , 1 }, --
    mana_adept                 = { 62231, 321526, 1 }, --
    mass_polymorph             = { 62106, 383121, 1 }, --
    master_of_time             = { 62102, 342249, 1 }, --
    meteor                     = { 62090, 153561, 1 }, --
    mirror_image               = { 62124, 55342 , 1 }, --
    nether_precision           = { 62227, 383782, 1 }, --
    nether_tempest             = { 62138, 114923, 1 }, --
    orb_barrage                = { 62136, 384858, 1 }, --
    overflowing_energy_nyi     = { 62120, 390218, 1 }, --
    presence_of_mind           = { 62146, 205025, 1 }, --
    prismatic_barrier          = { 62121, 235450, 1 }, --
    prodigious_savant          = { 62137, 384612, 2 }, --
    radiant_spark              = { 62235, 376103, 1 }, --
    reabsorption               = { 62125, 382820, 1 }, --
    reduplication              = { 62125, 382569, 1 }, --
    reflection                 = { 62092, 389713, 1 }, --
    remove_curse               = { 62116, 475   , 1 }, --
    resonance                  = { 62140, 205028, 1 }, --
    reverberate                = { 62138, 281482, 1 }, --
    rigid_ice                  = { 62110, 382481, 1 }, --
    ring_of_frost              = { 62088, 113724, 1 }, --
    rule_of_threes             = { 62145, 264354, 1 }, --
    rune_of_power              = { 62113, 116011, 1 }, --
    shifting_power             = { 62085, 382440, 1 }, --
    shimmer                    = { 62105, 212653, 1 }, --
    siphon_storm               = { 62148, 384187, 1 }, --
    slipstream                 = { 62222, 236457, 1 }, --
    sloooow_down               = { 62109, 391102, 1 }, --
    slow                       = { 62097, 31589 , 1 }, --
    spellsteal                 = { 62084, 30449 , 1 }, --
    supernova                  = { 62221, 157980, 1 }, --
    tempest_barrier            = { 62111, 382289, 2 }, --
    temporal_velocity          = { 62099, 382826, 2 }, --
    temporal_warp              = { 62094, 386539, 1 }, --
    time_anomaly               = { 62094, 383243, 1 }, --
    time_manipulation          = { 62129, 387807, 2 }, --
    tome_of_antonidas          = { 62098, 382490, 1 }, --
    tome_of_rhonin             = { 62127, 382493, 1 }, --
    touch_of_the_magi          = { 62233, 321507, 1 }, --
    volatile_detonation        = { 62089, 389627, 1 }, --
    winters_protection         = { 62123, 382424, 2 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    arcane_empowerment = 61  , -- 276741
    arcanosphere       = 5397, -- 353128
    ice_wall           = 5488, -- 352278
    kleptomania        = 3529, -- 198100
    mass_invisibility  = 637 , -- 198158
    master_of_escape   = 635 , -- 210476
    netherwind_armor   = 3442, -- 198062
    precognition       = 5492, -- 377360
    prismatic_cloak    = 3531, -- 198064
    ring_of_fire       = 5491, -- 353082
    temporal_shield    = 3517, -- 198111
} )


-- Auras
spec:RegisterAuras( {
    arcanosphere = {
        id = 353128,
    },
    blink = {
        id = 1953,
    },
    evocation = {
        id = 12051,
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
    mastery_savant = {
        id = 190740,
    },
    mirror_image = {
        id = 55342,
    },
    presence_of_mind = {
        id = 205025,
    },
    prismatic_barrier = {
        id = 235450,
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
    temporal_shield = {
        id = 198111,
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


    arcane_barrage = {
        id = 44425,
        cast = 0,
        cooldown = 3,
        gcd = "spell",

        talent = "arcane_barrage",
        startsCombat = false,
        texture = 236205,

        handler = function ()
        end,
    },


    arcane_blast = {
        id = 30451,
        cast = 2.25,
        cooldown = 0,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 135735,

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


    arcane_familiar = {
        id = 205022,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        talent = "arcane_familiar",
        startsCombat = false,
        texture = 1041232,

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


    arcane_missiles = {
        id = 5143,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        talent = "arcane_missiles",
        startsCombat = false,
        texture = 136096,

        handler = function ()
        end,
    },


    arcane_orb = {
        id = 153626,
        cast = 0,
        charges = 1,
        cooldown = 20.18,
        recharge = 20.18,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "arcane_orb",
        startsCombat = false,
        texture = 1033906,

        handler = function ()
        end,
    },


    arcane_surge = {
        id = 365350,
        cast = 2.5,
        cooldown = 90,
        gcd = "spell",

        spend = 350001,
        spendType = "mana",

        talent = "arcane_surge",
        startsCombat = false,
        texture = 4667417,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    arcanosphere = {
        id = 353128,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "arcanosphere",
        startsCombat = false,
        texture = 4226155,

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


    conjure_mana_gem = {
        id = 759,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        talent = "conjure_mana_gem",
        startsCombat = false,
        texture = 134132,

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


    evocation = {
        id = 12051,
        cast = 0,
        charges = 1,
        cooldown = 90.83,
        recharge = 90.83,
        gcd = "spell",

        talent = "evocation",
        startsCombat = false,
        texture = 136075,

        toggle = "cooldowns",

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


    mass_invisibility = {
        id = 198158,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "mass_invisibility",
        startsCombat = false,
        texture = 1387356,

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


    nether_tempest = {
        id = 114923,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "nether_tempest",
        startsCombat = false,
        texture = 610471,

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


    presence_of_mind = {
        id = 205025,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        talent = "presence_of_mind",
        startsCombat = false,
        texture = 136031,

        handler = function ()
        end,
    },


    prismatic_barrier = {
        id = 235450,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "prismatic_barrier",
        startsCombat = false,
        texture = 135991,

        handler = function ()
        end,
    },


    radiant_spark = {
        id = 376103,
        cast = 1.5,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "radiant_spark",
        startsCombat = false,
        texture = 3565446,

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


    supernova = {
        id = 157980,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        talent = "supernova",
        startsCombat = false,
        texture = 1033912,

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


    temporal_shield = {
        id = 198111,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "temporal_shield",
        startsCombat = false,
        texture = 610472,

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


    touch_of_the_magi = {
        id = 321507,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 0.05,
        spendType = "mana",

        talent = "touch_of_the_magi",
        startsCombat = false,
        texture = 1033909,

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Arcane", 20220917,
-- Notes
[[

]],
-- Priority
[[

]] )