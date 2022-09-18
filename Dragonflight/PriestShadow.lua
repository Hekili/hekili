-- PriestShadow.lua
-- September 2022

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 258 )

spec:RegisterResource( Enum.PowerType.Insanity )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    ancient_madness            = { 78350, 341240, 2 }, --
    angelic_bulwark            = { 78370, 108945, 1 }, --
    angelic_feather            = { 78398, 121536, 1 }, --
    angels_mercy               = { 78373, 238100, 1 }, --
    apathy                     = { 78384, 390668, 1 }, --
    auspicious_spirits         = { 78361, 155271, 1 }, --
    binding_heals              = { 78373, 368275, 1 }, --
    blessed_recovery           = { 78415, 390767, 1 }, --
    body_and_soul              = { 78401, 64129 , 1 }, --
    coalescing_shadows         = { 78347, 391242, 1 }, --
    crystalline_reflection     = { 78376, 373457, 2 }, --
    damnation                  = { 78348, 341374, 1 }, --
    dark_ascension             = { 78351, 391109, 1 }, --
    dark_evangelism            = { 78354, 391095, 2 }, --
    dark_void                  = { 78344, 263346, 1 }, --
    death_and_madness          = { 78406, 321291, 1 }, --
    deathspeaker               = { 78251, 392507, 1 }, --
    depth_of_the_shadows       = { 78402, 390615, 1 }, --
    derangement                = { 78255, 391235, 1 }, --
    devouring_plague           = { 78359, 335467, 1 }, --
    dispel_magic               = { 78410, 528   , 1 }, --
    dispersion                 = { 78357, 47585 , 1 }, --
    divine_star                = { 78375, 122121, 1 }, --
    dominate_mind              = { 78405, 205364, 1 }, --
    fiending_dark              = { 78338, 391218, 2 }, --
    focused_mending            = { 78414, 372354, 1 }, --
    halo                       = { 78375, 120644, 1 }, --
    harnessed_shadows          = { 78341, 391296, 1 }, --
    holy_nova                  = { 78396, 132157, 1 }, --
    idol_of_cthun              = { 78336, 377349, 1 }, --
    idol_of_nzoth              = { 78336, 373280, 1 }, --
    idol_of_yoggsaron          = { 78248, 373273, 1 }, --
    idol_of_yshaarj            = { 78342, 373310, 1 }, --
    improved_fade              = { 78381, 390670, 2 }, --
    improved_mass_dispel       = { 78393, 341167, 1 }, --
    insidious_ire              = { 78253, 373212, 2 }, --
    inspiration                = { 78391, 390676, 1 }, --
    intangibility              = { 78353, 288733, 1 }, --
    last_word                  = { 78346, 263716, 1 }, --
    leap_of_faith              = { 78411, 73325 , 1 }, --
    lights_inspiration         = { 78374, 373450, 2 }, --
    maddening_touch            = { 78339, 391228, 2 }, --
    malediction                = { 78349, 373221, 2 }, --
    manipulation               = { 78367, 390996, 2 }, --
    masochism                  = { 78402, 193063, 1 }, --
    mass_dispel                = { 78394, 32375 , 1 }, --
    mastermind                 = { 78366, 391151, 2 }, --
    mental_decay               = { 78355, 375994, 1 }, --
    mental_fortitude           = { 78353, 377065, 1 }, --
    mind_control               = { 78405, 605   , 1 }, --
    mind_devourer              = { 78254, 373202, 1 }, --
    mind_flay_insanity         = { 78251, 391399, 1 }, --
    mind_melt                  = { 78252, 391090, 1 }, --
    mind_sear                  = { 78358, 48045 , 1 }, --
    mind_spike                 = { 78362, 73510 , 1 }, --
    mindbender                 = { 78342, 200174, 1 }, --
    mindgames                  = { 78382, 375901, 1 }, --
    misery                     = { 78344, 238558, 1 }, --
    monomania                  = { 78343, 375767, 2 }, --
    move_with_grace            = { 78397, 390620, 1 }, --
    pain_of_death              = { 78365, 391288, 2 }, --
    phantasm                   = { 78249, 108942, 1 }, --
    power_infusion             = { 78389, 10060 , 1 }, --
    power_word_life            = { 78371, 373481, 1 }, --
    prayer_of_mending          = { 78413, 33076 , 1 }, --
    psychic_horror             = { 78346, 64044 , 1 }, --
    psychic_link               = { 78364, 199484, 2 }, --
    psychic_voice              = { 78390, 196704, 1 }, --
    puppet_master              = { 78340, 377387, 1 }, --
    purify_disease             = { 78399, 213634, 1 }, --
    renew                      = { 78412, 139   , 1 }, --
    rhapsody                   = { 78395, 390622, 1 }, --
    sanlayn                    = { 78385, 199855, 1 }, --
    shackle_undead             = { 78388, 9484  , 1 }, --
    shadow_crash               = { 78250, 205385, 1 }, --
    shadow_mend                = { 78409, 186263, 1 }, --
    shadow_word_death          = { 78407, 32379 , 1 }, --
    shadowfiend                = { 78408, 34433 , 1 }, --
    shadowflame_prism          = { 78337, 373427, 1 }, --
    shadowy_apparitions        = { 78360, 341491, 1 }, --
    shadowy_insight            = { 78356, 375888, 1 }, --
    shattered_perceptions      = { 78368, 391112, 1 }, --
    sheer_terror               = { 78403, 390919, 1 }, --
    silence                    = { 78345, 15487 , 1 }, --
    spell_warding              = { 78415, 390667, 1 }, --
    surge_of_darkness          = { 78363, 162448, 1 }, --
    surge_of_light             = { 78372, 109186, 2 }, --
    throes_of_pain             = { 78404, 377422, 2 }, --
    tithe_evasion              = { 78383, 373223, 1 }, --
    tools_of_the_cloth         = { 78416, 377438, 1 }, --
    tormented_spirits          = { 78361, 391284, 1 }, --
    translucent_image          = { 78380, 373446, 1 }, --
    twins_of_the_sun_priestess = { 78378, 373466, 1 }, --
    twist_of_fate              = { 78379, 390972, 2 }, --
    unfurling_darkness         = { 78352, 341273, 1 }, --
    unwavering_will            = { 78392, 373456, 2 }, --
    vampiric_embrace           = { 78386, 15286 , 1 }, --
    void_eruption              = { 78351, 228260, 1 }, --
    void_shield                = { 78387, 280749, 1 }, --
    void_shift                 = { 78369, 108968, 1 }, --
    void_tendrils              = { 78403, 108920, 1 }, --
    void_torrent               = { 78348, 263165, 1 }, --
    whispers_of_the_damned     = { 78256, 391137, 2 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    cardinal_mending    = 5474, -- 328529
    catharsis           = 5486, -- 391297
    delivered_from_evil = 5481, -- 196611
    driven_to_madness   = 106 , -- 199259
    eternal_rest        = 5484, -- 322107
    mind_trauma         = 113 , -- 199445
    precognition        = 5500, -- 377360
    psyfiend            = 763 , -- 211522
    strength_of_soul    = 5477, -- 197535
    thoughtsteal        = 5381, -- 316262
    void_origins        = 739 , -- 228630
    void_volley         = 5447, -- 357711
} )


-- Auras
spec:RegisterAuras( {
    apathy = {
        id = 390669,
        duration = 4,
        max_stack = 1
    },
    body_and_soul = {
        id = 65081,
        duration = 3,
        max_stack = 1
    },
    coalescing_shadows = {
        id = 391243,
        duration = 60,
        max_stack = 3
    },
    dark_ascension = {
        id = 391109,
        duration = 20,
        tick_time = 1,
        max_stack = 1
    },
    dark_evangelism = {
        id = 391099,
        duration = 25,
        max_stack = 5
    },
    death_and_madness = {
        id = 322098,
        duration = 7,
        max_stack = 1
    },
    deathspeaker = {
        id = 392511,
        duration = 15,
        max_stack = 1
    },
    depth_of_the_shadows = {
        id = 390617,
        duration = 15,
        max_stack = 50
    },
    desperate_prayer = {
        id = 19236,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    devouring_plague = {
        id = 335467,
        duration = 6,
        tick_time = 3,
        max_stack = 1
    },
    dispersion = {
        id = 47585,
        duration = 6,
        tick_time = 1,
        max_stack = 1
    },
    dominate_mind = {
        id = 205364,
        duration = 30,
        max_stack = 1
    },
    fade = {
        id = 586,
        duration = 10,
        max_stack = 1
    },
    focused_will = {
        id = 45242,
        duration = 8,
        max_stack = 1
    },
    idol_of_nzoth = {
        id = 373281,
        duration = 20,
        max_stack = 10
    },
    idol_of_yoggsaron = {
        id = 373276,
        duration = 3600,
        max_stack = 50
    },
    inspiration = {
        id = 390677,
        duration = 15,
        max_stack = 1
    },
    leap_of_faith = {
        id = 73325,
        duration = 1.5,
        max_stack = 1
    },
    levitate = {
        id = 1706,
        duration = 0,
        max_stack = 1
    },
    mind_control = {
        id = 605,
        duration = 30,
        max_stack = 1
    },
    mind_flay = {
        id = 15407,
        duration = 4.5,
        tick_time = 0.75,
        max_stack = 1
    },
    mind_flay_insanity = {
        id = 391399,
        duration = 0,
        max_stack = 1
    },
    mind_melt = {
        id = 391092,
        duration = 10,
        max_stack = 2
    },
    mind_sear = {
        id = 48045,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    mind_soothe = {
        id = 453,
        duration = 20,
        max_stack = 1
    },
    mind_spike = {
        id = 217673,
        duration = 10,
        max_stack = 3
    },
    mind_vision = {
        id = 2096,
        duration = 60,
        max_stack = 1
    },
    mindgames = {
        id = 375901,
        duration = 5,
        max_stack = 1
    },
    phantasm = {
        id = 114239,
        duration = 0,
        max_stack = 1
    },
    power_infusion = {
        id = 10060,
        duration = 20,
        max_stack = 1
    },
    power_word_fortitude = {
        id = 21562,
        duration = 3600,
        max_stack = 1
    },
    power_word_shield = {
        id = 17,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    prayer_of_mending = {
        id = 33076,
        duration = 0,
        max_stack = 1
    },
    psychic_horror = {
        id = 64044,
        duration = 4,
        max_stack = 1
    },
    psychic_scream = {
        id = 8122,
        duration = 8,
        max_stack = 1
    },
    renew = {
        id = 139,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    shackle_undead = {
        id = 9484,
        duration = 50,
        max_stack = 1
    },
    shadow_word_pain = {
        id = 589,
        duration = 16,
        tick_time = 2,
        max_stack = 1
    },
    shadowfiend = {
        id = 34433,
        duration = 15,
        max_stack = 1
    },
    shadowform = {
        id = 232698,
        duration = 3600,
        max_stack = 1
    },
    sign_of_the_emissary = {
        id = 225788,
        duration = 3600,
        max_stack = 1
    },
    silence = {
        id = 15487,
        duration = 4,
        max_stack = 1
    },
    surge_of_darkness = {
        id = 87160,
        duration = 10,
        max_stack = 3
    },
    tools_of_the_cloth = {
        id = 390933,
        duration = 12,
        max_stack = 1
    },
    unfurling_darkness = {
        id = 341282,
        duration = 8,
        max_stack = 1
    },
    unfurling_darkness_icd = {
        id = 341291,
        duration = 15,
        max_stack = 1
    },
    vampiric_embrace = {
        id = 15286,
        duration = 15,
        tick_time = 0.5,
        max_stack = 1
    },
    vampiric_touch = {
        id = 34914,
        duration = 21,
        tick_time = 3,
        max_stack = 1
    },
    voidform = {
        -- id = ?,
    },
    void_tendrils = {
        id = 108920,
        duration = 0.5,
        max_stack = 1
    },
    void_torrent = {
        id = 263165,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    void_torrent_insanity = {
        id = 289577,
        duration = 3.9,
        tick_time = 0.975,
        max_stack = 1
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


    damnation = {
        id = 341374,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "damnation",
        startsCombat = false,
        texture = 236295,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dark_ascension = {
        id = 391109,
        cast = 1.5,
        cooldown = 120,
        gcd = "spell",

        talent = "dark_ascension",
        startsCombat = false,
        texture = 1445237,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dark_void = {
        id = 263346,
        cast = 2,
        cooldown = 30,
        gcd = "spell",

        talent = "dark_void",
        startsCombat = false,
        texture = 132851,

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


    devouring_plague = {
        id = 335467,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 50,
        spendType = "insanity",

        talent = "devouring_plague",
        startsCombat = false,
        texture = 252997,

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


    dispersion = {
        id = 47585,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "dispersion",
        startsCombat = false,
        texture = 237563,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    divine_star = {
        id = 122121,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 1250,
        spendType = "mana",

        talent = "divine_star",
        startsCombat = false,
        texture = 631519,

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


    halo = {
        id = 120644,
        cast = 1.5,
        cooldown = 40,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "halo",
        startsCombat = false,
        texture = 632353,

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


    mind_blast = {
        id = 8092,
        cast = 1.5,
        charges = 1,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",

        spend = 625,
        spendType = "mana",

        startsCombat = true,
        texture = 136224,

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


    mind_flay = {
        id = 15407,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 136208,

        handler = function ()
        end,
    },


    mind_sear = {
        id = 48045,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 25,
        spendType = "insanity",

        talent = "mind_sear",
        startsCombat = false,
        texture = 237565,

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


    mind_spike = {
        id = 73510,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        talent = "mind_spike",
        startsCombat = false,
        texture = 457655,

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


    mindbender = {
        id = 200174,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "mindbender",
        startsCombat = false,
        texture = 136214,

        toggle = "cooldowns",

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


    psychic_horror = {
        id = 64044,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "psychic_horror",
        startsCombat = false,
        texture = 237568,

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


    psyfiend = {
        id = 211522,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "psyfiend",
        startsCombat = false,
        texture = 537021,

        handler = function ()
        end,
    },


    purify_disease = {
        id = 213634,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "purify_disease",
        startsCombat = false,
        texture = 135935,

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


    shadow_crash = {
        id = 205385,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "shadow_crash",
        startsCombat = false,
        texture = 136201,

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
        startsCombat = true,
        texture = 136149,

        handler = function ()
        end,
    },


    shadow_word_pain = {
        id = 589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
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
        startsCombat = true,
        texture = 136199,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    shadowform = {
        id = 232698,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 136200,

        handler = function ()
        end,
    },


    silence = {
        id = 15487,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        talent = "silence",
        startsCombat = false,
        texture = 458230,

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


    vampiric_touch = {
        id = 34914,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 135978,

        handler = function ()
        end,
    },


    void_eruption = {
        id = 228260,
        cast = 1.5,
        cooldown = 120,
        gcd = "spell",

        talent = "void_eruption",
        startsCombat = false,
        texture = 1386548,

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


    void_torrent = {
        id = 263165,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "void_torrent",
        startsCombat = false,
        texture = 1386551,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Shadow", 20220917,
-- Notes
[[

]],
-- Priority
[[

]] )