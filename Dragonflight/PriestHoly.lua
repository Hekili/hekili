-- PriestHoly.lua
-- September 2022

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 257 )

spec:RegisterResource( Enum.PowerType.Insanity )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    afterlife                  = { 78328, 196707, 1 }, --
    angelic_bulwark            = { 78370, 108945, 1 }, --
    angelic_feather            = { 78398, 121536, 1 }, --
    angels_mercy               = { 78373, 238100, 1 }, --
    answered_prayers           = { 78301, 391387, 2 }, --
    apathy                     = { 78384, 390668, 1 }, --
    apotheosis                 = { 78303, 200183, 1 }, --
    benediction                = { 78334, 193157, 1 }, --
    binding_heals              = { 78373, 368275, 1 }, --
    blessed_recovery           = { 78415, 390767, 1 }, --
    body_and_soul              = { 78401, 64129 , 1 }, --
    burning_vehemence          = { 78333, 372307, 1 }, --
    censure                    = { 78312, 200199, 1 }, --
    circle_of_healing          = { 78317, 204883, 1 }, --
    cosmic_ripple              = { 78323, 238136, 1 }, --
    crisis_management          = { 78320, 390954, 2 }, --
    crystalline_reflection     = { 78376, 373457, 2 }, --
    death_and_madness          = { 78406, 321291, 1 }, --
    depth_of_the_shadows       = { 78402, 390615, 1 }, --
    desperate_times            = { 78302, 391381, 2 }, --
    dispel_magic               = { 78410, 528   , 1 }, --
    divine_hymn                = { 78314, 64843 , 1 }, --
    divine_image               = { 78247, 392988, 1 }, --
    divine_service             = { 78335, 391233, 1 }, --
    divine_star                = { 78377, 110744, 1 }, --
    divine_word                = { 78247, 372760, 1 }, --
    dominate_mind              = { 78405, 205364, 1 }, --
    empowered_renew            = { 78305, 391339, 1 }, --
    empyreal_blaze             = { 78300, 372616, 1 }, --
    enlightenment              = { 78311, 193155, 1 }, --
    everlasting_light          = { 78315, 391161, 1 }, --
    focused_mending            = { 78414, 372354, 1 }, --
    gales_of_song              = { 78306, 372370, 2 }, --
    guardian_angel             = { 78329, 200209, 1 }, --
    guardian_spirit            = { 78330, 47788 , 1 }, --
    guardians_of_the_light     = { 78329, 196437, 1 }, --
    halo                       = { 78377, 120517, 1 }, --
    harmonious_apparatus       = { 78304, 390994, 2 }, --
    healing_chorus             = { 78318, 390881, 1 }, --
    holy_mending               = { 78334, 391154, 1 }, --
    holy_nova                  = { 78396, 132157, 1 }, --
    holy_word_chastise         = { 78332, 88625 , 1 }, --
    holy_word_salvation        = { 78303, 265202, 1 }, --
    holy_word_sanctify         = { 78325, 34861 , 1 }, --
    holy_word_serenity         = { 78331, 2050  , 1 }, --
    improved_fade              = { 78381, 390670, 2 }, --
    improved_mass_dispel       = { 78393, 341167, 1 }, --
    improved_purify            = { 78400, 390632, 1 }, --
    inspiration                = { 78391, 390676, 1 }, --
    leap_of_faith              = { 78411, 73325 , 1 }, --
    light_of_the_naaru         = { 78322, 196985, 2 }, --
    lights_inspiration         = { 78374, 373450, 2 }, --
    lightweaver                = { 78296, 390992, 1 }, --
    lightwell                  = { 78296, 372835, 1 }, --
    manipulation               = { 78367, 390996, 2 }, --
    masochism                  = { 78402, 193063, 1 }, --
    mass_dispel                = { 78394, 32375 , 1 }, --
    mind_control               = { 78405, 605   , 1 }, --
    mindgames                  = { 78382, 375901, 1 }, --
    miracle_worker             = { 78298, 235587, 1 }, --
    move_with_grace            = { 78397, 390620, 1 }, --
    orison                     = { 78319, 390947, 1 }, --
    phantasm                   = { 78249, 108942, 1 }, --
    pontifex                   = { 78321, 390980, 1 }, --
    power_infusion             = { 78389, 10060 , 1 }, --
    power_word_life            = { 78371, 373481, 1 }, --
    prayer_circle              = { 78318, 321377, 1 }, --
    prayer_of_healing          = { 78324, 596   , 1 }, --
    prayer_of_mending          = { 78413, 33076 , 1 }, --
    prayerful_litany           = { 78316, 391209, 1 }, --
    prayers_of_the_virtuous    = { 78309, 390977, 2 }, --
    prismatic_echoes           = { 78307, 390967, 2 }, --
    psychic_voice              = { 78390, 196704, 1 }, --
    rapid_recovery             = { 78305, 391368, 1 }, --
    renew                      = { 78412, 139   , 1 }, --
    renewed_faith              = { 78313, 341997, 1 }, --
    resonant_words             = { 78297, 372309, 2 }, --
    restitution                = { 78298, 391124, 1 }, --
    revitalizing_prayers       = { 78326, 391208, 1 }, --
    rhapsody                   = { 78395, 390622, 1 }, --
    sanctified_prayers         = { 78326, 196489, 1 }, --
    sanlayn                    = { 78385, 199855, 1 }, --
    say_your_prayers           = { 78308, 391186, 1 }, --
    searing_light              = { 78299, 372611, 2 }, --
    shackle_undead             = { 78388, 9484  , 1 }, --
    shadow_mend                = { 78409, 186263, 1 }, --
    shadow_word_death          = { 78407, 32379 , 1 }, --
    shadowfiend                = { 78408, 34433 , 1 }, --
    shattered_perceptions      = { 78368, 391112, 1 }, --
    sheer_terror               = { 78403, 390919, 1 }, --
    spell_warding              = { 78415, 390667, 1 }, --
    surge_of_light             = { 78372, 109186, 2 }, --
    symbol_of_hope             = { 78310, 64901 , 1 }, --
    throes_of_pain             = { 78404, 377422, 2 }, --
    tithe_evasion              = { 78383, 373223, 1 }, --
    tools_of_the_cloth         = { 78416, 377438, 1 }, --
    trail_of_light             = { 78327, 200128, 2 }, --
    translucent_image          = { 78380, 373446, 1 }, --
    twins_of_the_sun_priestess = { 78378, 373466, 1 }, --
    twist_of_fate              = { 78379, 390972, 2 }, --
    unwavering_will            = { 78392, 373456, 2 }, --
    vampiric_embrace           = { 78386, 15286 , 1 }, --
    void_shield                = { 78387, 280749, 1 }, --
    void_shift                 = { 78369, 108968, 1 }, --
    void_tendrils              = { 78403, 108920, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    cardinal_mending       = 115 , -- 328529
    catharsis              = 5485, -- 391297
    delivered_from_evil    = 1927, -- 196611
    divine_ascension       = 5366, -- 328530
    eternal_rest           = 5482, -- 322107
    greater_heal           = 112 , -- 289666
    holy_ward              = 101 , -- 213610
    precognition           = 5499, -- 377360
    purification           = 5478, -- 196162
    purified_resolve       = 5479, -- 196439
    ray_of_hope            = 127 , -- 197268
    sanctified_ground      = 108 , -- 357481
    spirit_of_the_redeemer = 124 , -- 215982
    strength_of_soul       = 5476, -- 197535
    thoughtsteal           = 5365, -- 316262
} )


-- Auras
spec:RegisterAuras( {
    apotheosis = {
        id = 200183,
    },
    desperate_prayer = {
        id = 19236,
    },
    divine_ascension = {
        id = 328530,
    },
    divine_hymn = {
        id = 64843,
    },
    divine_word = {
        id = 372760,
    },
    fade = {
        id = 586,
    },
    focused_will = {
        id = 45243,
    },
    mastery_echo_of_light = {
        id = 77485,
    },
    power_infusion = {
        id = 10060,
    },
    spirit_of_redemption = {
        id = 20711,
    },
    symbol_of_hope = {
        id = 64901,
    },
    vampiric_embrace = {
        id = 15286,
    },
} )


-- Abilities
spec:RegisterAbilities( {
    angelic_feather = {
        id = 121536,
        cast = 0,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",

        talent = "angelic_feather",
        startsCombat = false,
        texture = 642580,

        handler = function ()
        end,
    },


    apotheosis = {
        id = 200183,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "apotheosis",
        startsCombat = false,
        texture = 1060983,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    circle_of_healing = {
        id = 204883,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "circle_of_healing",
        startsCombat = false,
        texture = 135887,

        handler = function ()
        end,
    },


    desperate_prayer = {
        id = 19236,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        startsCombat = false,
        texture = 237550,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dispel_magic = {
        id = 528,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "dispel_magic",
        startsCombat = false,
        texture = 136066,

        handler = function ()
        end,
    },


    divine_ascension = {
        id = 328530,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        pvptalent = "divine_ascension",
        startsCombat = false,
        texture = 642580,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    divine_hymn = {
        id = 64843,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "divine_hymn",
        startsCombat = false,
        texture = 237540,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    divine_star = {
        id = 110744,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "divine_star",
        startsCombat = false,
        texture = 537026,

        handler = function ()
        end,
    },


    divine_word = {
        id = 372760,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "divine_word",
        startsCombat = false,
        texture = 521584,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dominate_mind = {
        id = 205364,
        cast = 1.8,
        cooldown = 120,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "dominate_mind",
        startsCombat = false,
        texture = 1386549,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    empyreal_blaze = {
        id = 372616,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 500,
        spendType = "mana",

        talent = "empyreal_blaze",
        startsCombat = false,
        texture = 525023,

        handler = function ()
        end,
    },


    fade = {
        id = 586,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 135994,

        handler = function ()
        end,
    },


    flash_heal = {
        id = 2061,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
        end,
    },


    greater_heal = {
        id = 289666,
        cast = 3,
        cooldown = 12,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        pvptalent = "greater_heal",
        startsCombat = false,
        texture = 135915,

        handler = function ()
        end,
    },


    guardian_spirit = {
        id = 47788,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        spend = 0.01,
        spendType = "mana",

        talent = "guardian_spirit",
        startsCombat = false,
        texture = 237542,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    halo = {
        id = 120517,
        cast = 1.5,
        cooldown = 40,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "halo",
        startsCombat = false,
        texture = 632352,

        handler = function ()
        end,
    },


    heal = {
        id = 2060,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 135913,

        handler = function ()
        end,
    },


    holy_fire = {
        id = 14914,
        cast = 1.5,
        cooldown = 10,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135972,

        handler = function ()
        end,
    },


    holy_nova = {
        id = 132157,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "holy_nova",
        startsCombat = false,
        texture = 135922,

        handler = function ()
        end,
    },


    holy_ward = {
        id = 213610,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "holy_ward",
        startsCombat = false,
        texture = 458722,

        handler = function ()
        end,
    },


    holy_word_chastise = {
        id = 88625,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "holy_word_chastise",
        startsCombat = false,
        texture = 135886,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    holy_word_salvation = {
        id = 265202,
        cast = 2.5,
        cooldown = 720,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "holy_word_salvation",
        startsCombat = false,
        texture = 458225,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    holy_word_sanctify = {
        id = 34861,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "holy_word_sanctify",
        startsCombat = false,
        texture = 237541,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    holy_word_serenity = {
        id = 2050,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "holy_word_serenity",
        startsCombat = false,
        texture = 135937,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    leap_of_faith = {
        id = 73325,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        talent = "leap_of_faith",
        startsCombat = false,
        texture = 463835,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    levitate = {
        id = 1706,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135928,

        handler = function ()
        end,
    },


    lightwell = {
        id = 372835,
        cast = 0.5,
        cooldown = 180,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "lightwell",
        startsCombat = false,
        texture = 135980,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    mass_dispel = {
        id = 32375,
        cast = 1.5,
        cooldown = 45,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "mass_dispel",
        startsCombat = false,
        texture = 135739,

        handler = function ()
        end,
    },


    mass_resurrection = {
        id = 212036,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 413586,

        handler = function ()
        end,
    },


    mind_control = {
        id = 605,
        cast = 1.8,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "mind_control",
        startsCombat = false,
        texture = 136206,

        handler = function ()
        end,
    },


    mind_soothe = {
        id = 453,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 135933,

        handler = function ()
        end,
    },


    mind_vision = {
        id = 2096,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 135934,

        handler = function ()
        end,
    },


    mindgames = {
        id = 375901,
        cast = 1.5,
        cooldown = 45,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "mindgames",
        startsCombat = false,
        texture = 3565723,

        handler = function ()
        end,
    },


    power_infusion = {
        id = 10060,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "power_infusion",
        startsCombat = false,
        texture = 135939,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    power_word_fortitude = {
        id = 21562,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 135987,

        handler = function ()
        end,
    },


    power_word_life = {
        id = 373481,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 1250,
        spendType = "mana",

        talent = "power_word_life",
        startsCombat = false,
        texture = 4667420,

        handler = function ()
        end,
    },


    power_word_shield = {
        id = 17,
        cast = 0,
        cooldown = 7.5,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135940,

        handler = function ()
        end,
    },


    prayer_of_healing = {
        id = 596,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "prayer_of_healing",
        startsCombat = false,
        texture = 135943,

        handler = function ()
        end,
    },


    prayer_of_mending = {
        id = 33076,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "prayer_of_mending",
        startsCombat = false,
        texture = 135944,

        handler = function ()
        end,
    },


    psychic_scream = {
        id = 8122,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 136184,

        handler = function ()
        end,
    },


    purify = {
        id = 527,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135894,

        handler = function ()
        end,
    },


    ray_of_hope = {
        id = 197268,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "ray_of_hope",
        startsCombat = false,
        texture = 1445239,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    renew = {
        id = 139,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "renew",
        startsCombat = false,
        texture = 135953,

        handler = function ()
        end,
    },


    resurrection = {
        id = 2006,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 135955,

        handler = function ()
        end,
    },


    shackle_undead = {
        id = 9484,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "shackle_undead",
        startsCombat = false,
        texture = 136091,

        handler = function ()
        end,
    },


    shadow_mend = {
        id = 186263,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "shadow_mend",
        startsCombat = false,
        texture = 136202,

        handler = function ()
        end,
    },


    shadow_word_death = {
        id = 32379,
        cast = 0,
        charges = 1,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",

        spend = 1250,
        spendType = "mana",

        talent = "shadow_word_death",
        startsCombat = false,
        texture = 136149,

        handler = function ()
        end,
    },


    shadow_word_pain = {
        id = 589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 750,
        spendType = "mana",

        startsCombat = true,
        texture = 136207,

        handler = function ()
        end,
    },


    shadowfiend = {
        id = 34433,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "shadowfiend",
        startsCombat = false,
        texture = 136199,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    smite = {
        id = 585,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = 135924,

        handler = function ()
        end,
    },


    symbol_of_hope = {
        id = 64901,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "symbol_of_hope",
        startsCombat = false,
        texture = 135982,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    thoughtsteal = {
        id = 316262,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "thoughtsteal",
        startsCombat = false,
        texture = 3718862,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    vampiric_embrace = {
        id = 15286,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "vampiric_embrace",
        startsCombat = false,
        texture = 136230,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    void_shift = {
        id = 108968,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        talent = "void_shift",
        startsCombat = false,
        texture = 537079,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    void_tendrils = {
        id = 108920,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "void_tendrils",
        startsCombat = false,
        texture = 537022,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Holy", 20220917,
-- Notes
[[

]],
-- Priority
[[

]] )