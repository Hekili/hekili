-- PriestDiscipline.lua
-- September 2022

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 256 )

spec:RegisterResource( Enum.PowerType.Insanity )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    aegis_of_wrath             = { 78258, 238135, 1 }, --
    angelic_bulwark            = { 78370, 108945, 1 }, --
    angelic_feather            = { 78398, 121536, 1 }, --
    angels_mercy               = { 78373, 238100, 1 }, --
    apathy                     = { 78384, 390668, 1 }, --
    atonement                  = { 78287, 81749 , 1 }, --
    binding_heals              = { 78373, 368275, 1 }, --
    blessed_recovery           = { 78415, 390767, 1 }, --
    body_and_soul              = { 78401, 64129 , 1 }, --
    borrowed_time              = { 78293, 390691, 2 }, --
    bright_pupil               = { 78284, 390684, 1 }, --
    castigation                = { 78270, 193134, 1 }, --
    contrition                 = { 78292, 197419, 2 }, --
    crystalline_reflection     = { 78376, 373457, 2 }, --
    dark_indulgence            = { 78289, 372972, 1 }, --
    death_and_madness          = { 78406, 321291, 1 }, --
    depth_of_the_shadows       = { 78402, 390615, 1 }, --
    dispel_magic               = { 78410, 528   , 1 }, --
    divine_aegis               = { 78295, 47515 , 2 }, --
    divine_star                = { 78377, 110744, 1 }, --
    dominate_mind              = { 78405, 205364, 1 }, --
    embrace_shadow             = { 78275, 372985, 1 }, --
    enduring_luminescence      = { 78284, 390685, 1 }, --
    evangelism                 = { 78260, 246287, 1 }, --
    exaltation                 = { 78269, 373042, 1 }, --
    expiation                  = { 78278, 390832, 2 }, --
    fiending_dark              = { 78263, 390770, 2 }, --
    focused_mending            = { 78414, 372354, 1 }, --
    halo                       = { 78377, 120517, 1 }, --
    harsh_discipline           = { 78265, 373180, 2 }, --
    holy_nova                  = { 78396, 132157, 1 }, --
    improved_fade              = { 78381, 390670, 2 }, --
    improved_mass_dispel       = { 78393, 341167, 1 }, --
    improved_purify            = { 78400, 390632, 1 }, --
    improved_shadow_word_pain  = { 78271, 390689, 2 }, --
    indemnity                  = { 78258, 373049, 1 }, --
    inspiration                = { 78391, 390676, 1 }, --
    leap_of_faith              = { 78411, 73325 , 1 }, --
    lenience                   = { 78260, 238063, 1 }, --
    lights_inspiration         = { 78374, 373450, 2 }, --
    lights_promise             = { 78285, 322115, 1 }, --
    lights_wrath               = { 78268, 373178, 1 }, --
    make_amends                = { 78294, 391079, 1 }, --
    malicious_scission         = { 78273, 372969, 1 }, --
    manipulation               = { 78367, 390996, 2 }, --
    masochism                  = { 78402, 193063, 1 }, --
    mass_dispel                = { 78394, 32375 , 1 }, --
    mind_control               = { 78405, 605   , 1 }, --
    mindbender                 = { 78277, 123040, 1 }, --
    mindgames                  = { 78382, 375901, 1 }, --
    move_with_grace            = { 78397, 390620, 1 }, --
    pain_suppression           = { 78280, 33206 , 1 }, --
    pain_transformation        = { 78281, 372991, 1 }, --
    painful_punishment         = { 78290, 390686, 1 }, --
    phantasm                   = { 78249, 108942, 1 }, --
    power_infusion             = { 78389, 10060 , 1 }, --
    power_of_the_dark_side     = { 78288, 198068, 1 }, --
    power_word_barrier         = { 78257, 62618 , 1 }, --
    power_word_life            = { 78371, 373481, 1 }, --
    power_word_radiance        = { 78286, 194509, 1 }, --
    power_word_solace          = { 78282, 129250, 1 }, --
    prayer_of_mending          = { 78413, 33076 , 1 }, --
    protector_of_the_frail     = { 78281, 373035, 1 }, --
    psychic_voice              = { 78390, 196704, 1 }, --
    purge_the_wicked           = { 78283, 204197, 1 }, --
    rapture                    = { 78291, 47536 , 1 }, --
    renew                      = { 78412, 139   , 1 }, --
    resplendent_light          = { 78267, 390765, 2 }, --
    revel_in_purity            = { 78259, 373003, 1 }, --
    rhapsody                   = { 78395, 390622, 1 }, --
    sanlayn                    = { 78385, 199855, 1 }, --
    schism                     = { 78272, 214621, 1 }, --
    shackle_undead             = { 78388, 9484  , 1 }, --
    shadow_covenant            = { 78274, 314867, 1 }, --
    shadow_mend                = { 78409, 186263, 1 }, --
    shadow_word_death          = { 78407, 32379 , 1 }, --
    shadowfiend                = { 78408, 34433 , 1 }, --
    shadowflame_prism          = { 78279, 373427, 1 }, --
    shattered_perceptions      = { 78368, 391112, 1 }, --
    sheer_terror               = { 78403, 390919, 1 }, --
    shield_discipline          = { 78282, 197045, 1 }, --
    sins_of_the_many           = { 78261, 280391, 2 }, --
    spell_warding              = { 78415, 390667, 1 }, --
    stolen_psyche              = { 78276, 373054, 2 }, --
    surge_of_light             = { 78372, 109186, 2 }, --
    throes_of_pain             = { 78404, 377422, 2 }, --
    tithe_evasion              = { 78383, 373223, 1 }, --
    tools_of_the_cloth         = { 78416, 377438, 1 }, --
    train_of_thought           = { 78294, 390693, 1 }, --
    translucent_image          = { 78380, 373446, 1 }, --
    twilight_corruption        = { 78275, 373065, 1 }, --
    twilight_equilibrium       = { 78264, 390705, 1 }, --
    twins_of_the_sun_priestess = { 78378, 373466, 1 }, --
    twist_of_fate              = { 78379, 390972, 2 }, --
    unwavering_will            = { 78392, 373456, 2 }, --
    vampiric_embrace           = { 78386, 15286 , 1 }, --
    void_shield                = { 78387, 280749, 1 }, --
    void_shift                 = { 78369, 108968, 1 }, --
    void_tendrils              = { 78403, 108920, 1 }, --
    weal_and_woe               = { 78262, 390786, 1 }, --
    wrath_unleashed            = { 78266, 390781, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    archangel              = 123 , -- 197862
    blaze_of_light         = 1244, -- 215768
    cardinal_mending       = 5475, -- 328529
    catharsis              = 5487, -- 391297
    dark_archangel         = 126 , -- 197871
    delivered_from_evil    = 5480, -- 196611
    dome_of_light          = 117 , -- 197590
    eternal_rest           = 5483, -- 322107
    inner_light_and_shadow = 5416, -- 356085
    precognition           = 5498, -- 377360
    purification           = 98  , -- 196162
    purified_resolve       = 100 , -- 196439
    strength_of_soul       = 111 , -- 197535
    thoughtsteal           = 855 , -- 316262
    trinity                = 109 , -- 214205
    ultimate_radiance      = 114 , -- 236499
} )


-- Auras
spec:RegisterAuras( {
    apathy = {
        id = 390669,
        duration = 4,
        max_stack = 1
    },
    archangel = {
        id = 197862,
        duration = 15,
        max_stack = 1
    },
    body_and_soul = {
        id = 65081,
        duration = 3,
        max_stack = 1
    },
    borrowed_time = {
        id = 390692,
        duration = 4,
        max_stack = 1
    },
    dark_archangel = {
        id = 197871,
        duration = 8,
        max_stack = 1
    },
    death_and_madness = {
        id = 322098,
        duration = 7,
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
        duration = 600,
        max_stack = 1
    },
    mind_control = {
        id = 605,
        duration = 30,
        max_stack = 1
    },
    mind_soothe = {
        id = 453,
        duration = 20,
        max_stack = 1
    },
    mind_vision = {
        id = 2096,
        duration = 60,
        max_stack = 1
    },
    mindbender = { -- TODO: Check Aura (https://wowhead.com/beta/spell=123040)
        id = 123040,
        duration = 12,
        max_stack = 1
    },
    mindgames = {
        id = 375901,
        duration = 5,
        max_stack = 1
    },
    pain_suppression = {
        id = 33206,
        duration = 8,
        max_stack = 1
    },
    power_infusion = {
        id = 10060,
        duration = 20,
        max_stack = 1
    },
    power_of_the_dark_side = {
        id = 198069,
        duration = 20,
        max_stack = 1
    },
    power_word_barrier = { -- TODO: Check for totem to help correct for remaining time.
        id = 81782,
        duration = 12,
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
    psychic_scream = {
        id = 8122,
        duration = 8,
        max_stack = 1
    },
    purge_the_wicked = {
        id = 204213,
        duration = 20,
        tick_time = 2,
        max_stack = 1
    },
    rapture = {
        id = 47536,
        duration = 8,
        max_stack = 1
    },
    renew = {
        id = 139,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    schism = {
        id = 214621,
        duration = 9,
        max_stack = 1
    },
    shackle_undead = {
        id = 9484,
        duration = 50,
        max_stack = 1
    },
    shadow_covenant = {
        id = 322105,
        duration = 7,
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
    tools_of_the_cloth = {
        id = 390933,
        duration = 12,
        max_stack = 1
    },
    vampiric_embrace = {
        id = 15286,
        duration = 15,
        tick_time = 0.5,
        max_stack = 1
    },
    void_tendrils = {
        id = 108920,
        duration = 0.5,
        max_stack = 1
    },
    weal_and_woe = {
        id = 390787,
        duration = 20,
        max_stack = 7
    },
    wrath_unleashed = {
        id = 390782,
        duration = 15,
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


    archangel = {
        id = 197862,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "archangel",
        startsCombat = false,
        texture = 458225,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dark_archangel = {
        id = 197871,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "dark_archangel",
        startsCombat = false,
        texture = 1445237,

        toggle = "cooldowns",

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


    evangelism = {
        id = 246287,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "evangelism",
        startsCombat = false,
        texture = 135895,

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


    lights_wrath = {
        id = 373178,
        cast = 2.5,
        cooldown = 90,
        gcd = "spell",

        talent = "lights_wrath",
        startsCombat = false,
        texture = 1271590,

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


    mind_blast = {
        id = 8092,
        cast = 1.5,
        charges = 1,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",

        spend = 0,
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


    mindbender = {
        id = 123040,
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


    pain_suppression = {
        id = 33206,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        spend = 0.02,
        spendType = "mana",

        talent = "pain_suppression",
        startsCombat = false,
        texture = 135936,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    penance = {
        id = 47540,
        cast = 0,
        cooldown = 9,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 237545,

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


    power_word_barrier = {
        id = 62618,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "power_word_barrier",
        startsCombat = false,
        texture = 253400,

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


    power_word_radiance = {
        id = 194509,
        cast = 2,
        charges = 1,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "power_word_radiance",
        startsCombat = false,
        texture = 1386546,

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


    power_word_solace = {
        id = 129250,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        talent = "power_word_solace",
        startsCombat = false,
        texture = 612968,

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


    purge_the_wicked = {
        id = 204197,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "purge_the_wicked",
        startsCombat = false,
        texture = 236216,

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


    rapture = {
        id = 47536,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "rapture",
        startsCombat = false,
        texture = 237548,

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


    schism = {
        id = 214621,
        cast = 1.5,
        cooldown = 24,
        gcd = "spell",

        spend = 1250,
        spendType = "mana",

        talent = "schism",
        startsCombat = false,
        texture = 463285,

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


    shadow_covenant = {
        id = 314867,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "shadow_covenant",
        startsCombat = false,
        texture = 136221,

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


    smite = {
        id = 585,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 1000,
        spendType = "mana",

        startsCombat = true,
        texture = 135924,

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

spec:RegisterPriority( "Discipline", 20220917,
-- Notes
[[

]],
-- Priority
[[

]] )