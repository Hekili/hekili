-- DemonHunterHavoc.lua
-- September 2022

if UnitClassBase( "player" ) ~= "DEMONHUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 577 )

spec:RegisterResource( Enum.PowerType.Fury )
spec:RegisterResource( Enum.PowerType.Pain )

-- Talents
spec:RegisterTalents( {
    aldrachi_design          = { 79295, 391409, 1 }, --
    any_means_necessary      = { 79219, 388114, 1 }, --
    aura_of_pain             = { 79288, 207347, 1 }, --
    blind_fury               = { 79227, 203550, 2 }, --
    blur                     = { 79318, 198589, 1 }, --
    bouncing_glaives         = { 79307, 320386, 1 }, --
    burning_hatred           = { 79269, 320374, 1 }, --
    burning_wound            = { 79208, 391189, 1 }, --
    chaos_fragments          = { 79280, 320412, 1 }, --
    chaos_nova               = { 79317, 179057, 1 }, --
    chaos_theory             = { 79212, 389687, 1 }, --
    chaotic_transformation   = { 79216, 388112, 1 }, --
    charred_warblades        = { 79302, 213010, 1 }, --
    concentrated_sigils      = { 79299, 207666, 1 }, --
    consume_magic            = { 79308, 278326, 1 }, --
    consume_magic_2          = { 79309, 320313, 1 }, --
    critical_chaos           = { 79275, 320413, 2 }, --
    cycle_of_hatred          = { 79210, 258887, 2 }, --
    dancing_with_fate        = { 79266, 389978, 2 }, --
    darkness                 = { 79286, 196718, 1 }, --
    demon_blades             = { 79226, 203555, 1 }, --
    demon_muzzle_nyi         = { 79297, 388111, 1 }, --
    demonic                  = { 79292, 213410, 1 }, --
    demonic_appetite         = { 79194, 206478, 1 }, --
    demonic_origins          = { 79292, 235893, 1 }, --
    desperate_instincts      = { 79278, 205411, 1 }, --
    disrupting_fury          = { 79290, 183782, 1 }, --
    elysian_decree           = { 79218, 390163, 1 }, --
    erratic_felheart         = { 79279, 391397, 2 }, --
    essence_break            = { 79211, 258860, 1 }, --
    extended_sigils          = { 79296, 389697, 2 }, --
    eye_beam                 = { 79272, 198013, 1 }, --
    fae_empowered_elixir     = { 79284, 389819, 1 }, --
    fel_barrage              = { 79222, 258925, 1 }, --
    fel_eruption             = { 79198, 211881, 1 }, --
    felblade                 = { 79288, 232893, 1 }, --
    felfire_haste            = { 79281, 389846, 1 }, --
    felfire_heart            = { 79268, 388109, 1 }, --
    first_blood              = { 79267, 206416, 1 }, --
    flames_of_fury           = { 79303, 389694, 1 }, --
    fodder_to_the_flame      = { 79218, 391429, 1 }, --
    furious_gaze             = { 79228, 343311, 1 }, --
    furious_throws           = { 79271, 393029, 1 }, --
    glaive_tempest           = { 79222, 342817, 1 }, --
    growing_inferno          = { 79214, 390158, 2 }, --
    hot_feet                 = { 79306, 320416, 1 }, --
    illidari_knowledge       = { 79316, 389696, 2 }, --
    imprison                 = { 79287, 217832, 1 }, --
    improved_chaos_strike    = { 79200, 343206, 1 }, --
    improved_disrupt         = { 79289, 320361, 1 }, --
    improved_fel_rush        = { 79270, 343017, 1 }, --
    improved_sigil_of_misery = { 79282, 320418, 1 }, --
    infernal_armor           = { 79310, 320331, 2 }, --
    initiative               = { 79276, 388108, 1 }, --
    inner_demon              = { 79217, 389693, 1 }, --
    insatiable_hunger        = { 79226, 258876, 1 }, --
    isolated_prey            = { 79277, 388113, 1 }, --
    know_your_enemy          = { 79213, 388118, 2 }, --
    long_night               = { 79283, 389781, 1 }, --
    looks_can_kill           = { 79207, 320415, 1 }, --
    lost_in_darkness         = { 79301, 389849, 1 }, --
    master_of_the_glaive     = { 79315, 389763, 1 }, --
    misery_in_defeat         = { 79282, 388110, 1 }, --
    moarg_bionics            = { 79223, 391275, 1 }, --
    momentum                 = { 79209, 206476, 1 }, --
    mortal_dance             = { 79199, 328725, 1 }, --
    netherwalk               = { 79201, 196555, 1 }, --
    pitch_black              = { 79283, 389783, 1 }, --
    precise_sigils           = { 79299, 389799, 1 }, --
    pursuit                  = { 79314, 320654, 1 }, --
    quickened_sigils         = { 79294, 209281, 1 }, --
    ragefire                 = { 79221, 388107, 1 }, --
    relentless_onslaught     = { 79224, 389977, 1 }, --
    restless_hunter          = { 79229, 390142, 1 }, --
    rush_of_chaos            = { 79311, 320421, 1 }, --
    serrated_glaive          = { 79215, 390154, 2 }, --
    shattered_destiny        = { 79206, 388116, 1 }, --
    shattered_restoration    = { 79304, 389824, 2 }, --
    sigil_of_flame           = { 79305, 204596, 1 }, --
    sigil_of_misery          = { 79293, 207684, 1 }, --
    sigil_of_silence         = { 79298, 202137, 1 }, --
    soul_rending             = { 79291, 204909, 2 }, --
    soulrend                 = { 79220, 388106, 2 }, --
    tactical_retreat         = { 79274, 389688, 1 }, --
    the_hunt                 = { 79285, 370965, 1 }, --
    trail_of_ruin            = { 79273, 258881, 1 }, --
    unbound_chaos            = { 79225, 347461, 2 }, --
    unleashed_power          = { 79280, 206477, 1 }, --
    unnatural_malice         = { 79284, 389811, 1 }, --
    unrestrained_fury        = { 79313, 320770, 2 }, --
    vengeful_restraint       = { 79197, 320635, 1 }, --
    vengeful_retreat         = { 79312, 198793, 1 }, --
    will_of_the_illidari     = { 79300, 389695, 2 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    blood_moon        = 5433, -- 355995
    chaotic_imprint   = 809 , -- 356510
    cleansed_by_flame = 805 , -- 205625
    cover_of_darkness = 1206, -- 357419
    demonic_origins   = 810 , -- 235893
    detainment        = 812 , -- 205596
    glimpse           = 813 , -- 354489
    mortal_dance      = 1204, -- 328725
    rain_from_above   = 811 , -- 206803
    reverse_magic     = 806 , -- 205604
    sigil_mastery     = 5523, -- 211489
    unending_hatred   = 1218, -- 213480
} )


-- Auras
spec:RegisterAuras( {
    blade_dance = {
        id = 188499,
        duration = 1,
        max_stack = 1
    },
    blur = {
        id = 212800,
        duration = 10,
        max_stack = 1
    },
    burning_wound = {
        id = 391191,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    chaos_nova = {
        id = 179057,
        duration = 2,
        max_stack = 1
    },
    darkness = { -- TODO: Link duration to totem or initial cast.
        id = 209426,
        duration = 8,
        max_stack = 1
    },
    elysian_decree = { -- TODO: This aura determines sigil pop time.
        id = 390163,
        duration = function () return talent.quickened_sigils.enabled and 1 or 2 end,
        max_stack = 1
    },
    eye_beam = { -- TODO: This is channel duration.
        id = 198013,
        duration = 2,
        tick_time = 0.2,
        max_stack = 1
    },
    fel_barrage = {
        id = 258925,
        duration = 3,
        tick_time = 0.25,
        max_stack = 1
    },
    fel_eruption = {
        id = 211881,
        duration = 4,
        max_stack = 1
    },
    felfire_haste = {
        id = 389847,
        duration = 8,
        max_stack = 1
    },
    fodder_to_the_flame = {
        id = 391430,
        duration = 25,
        max_stack = 1
    },
    glaive_tempest = { -- TODO: Model based on cast time?
        id = 342817,
        duration = 3,
        max_stack = 1
    },
    glide = {
        id = 131347,
        duration = 3600,
        tick_time = 0.333,
        max_stack = 1
    },
    immolation_aura = {
        id = 258920,
        duration = 6,
        tick_time = 1,
        max_stack = 1
    },
    imprison = {
        id = 217832,
        duration = 60,
        max_stack = 1
    },
    master_of_the_glaive = {
        id = 213405,
        duration = 6,
        max_stack = 1
    },
    metamorphosis = {
        id = 162264,
        duration = 25,
        tick_time = 1,
        max_stack = 1
    },
    mortal_dance = {
        id = 356608,
        duration = 5,
        max_stack = 1
    },
    netherwalk = {
        id = 196555,
        duration = 6,
        max_stack = 1
    },
    prepared = {
        id = 203650,
        duration = 10,
        max_stack = 1
    },
    rain_from_above_immune = {
        id = 206803,
        duration = 1,
        tick_time = 1,
        max_stack = 1
    },
    rain_from_above = { -- Gliding/floating.
        id = 206804,
        duration = 10,
        max_stack = 1
    },
    serrated_glaive = {
        id = 390155,
        duration = 10,
        max_stack = 1
    },
    sigil_of_flame = { -- TODO: Model placement pop.
        id = 204596,
        duration = function () return talent.quickened_sigils.enabled and 1 or 2 end,
        max_stack = 1
    },
    sigil_of_misery = { -- TODO: Model placement pop.
        id = 207684,
        duration = function () return talent.quickened_sigils.enabled and 1 or 2 end,
        max_stack = 1
    },
    sigil_of_silence = { -- TODO: Model placement pop.
        id = 202137,
        duration = function () return talent.quickened_sigils.enabled and 1 or 2 end,
        max_stack = 1
    },
    spectral_sight = {
        id = 188501,
        duration = 10,
        max_stack = 1
    },
    the_hunt = {
        id = 370966,
        duration = 30,
        max_stack = 1
    },
    the_hunt_dot = {
        id = 370969,
        duration = 6,
        tick_time = 2,
        max_stack = 1
    },
    the_hunt_root = {
        id = 370970,
        duration = 1.5,
        max_stack = 1
    },
    torment = {
        id = 185245,
        duration = 3,
        max_stack = 1
    },
    trail_of_ruin = {
        id = 258883,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    vengeful_retreat_snare = {
        id = 198813,
        duration = 3,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    blade_dance = {
        id = 188499,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 35,
        spendType = "fury",

        startsCombat = true,
        texture = 1305149,

        handler = function ()
        end,
    },


    blur = {
        id = 198589,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "blur",
        startsCombat = false,
        texture = 1305150,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    chaos_nova = {
        id = 179057,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 30,
        spendType = "fury",

        talent = "chaos_nova",
        startsCombat = false,
        texture = 135795,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    chaos_strike = {
        id = 162794,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 40,
        spendType = "fury",

        startsCombat = true,
        texture = 1305152,

        handler = function ()
        end,
    },


    consume_magic = {
        id = 278326,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        talent = "consume_magic",
        startsCombat = false,
        texture = 828455,

        handler = function ()
        end,
    },


    darkness = {
        id = 196718,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        talent = "darkness",
        startsCombat = false,
        texture = 1305154,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    demons_bite = {
        id = 162243,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 135561,

        handler = function ()
        end,
    },


    disrupt = {
        id = 183752,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        startsCombat = true,
        texture = 1305153,

        handler = function ()
        end,
    },


    elysian_decree = {
        id = 390163,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "elysian_decree",
        startsCombat = false,
        texture = 3565443,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    essence_break = {
        id = 258860,
        cast = 0,
        cooldown = 40,
        gcd = "spell",

        talent = "essence_break",
        startsCombat = false,
        texture = 136189,

        handler = function ()
        end,
    },


    eye_beam = {
        id = 198013,
        cast = 0,
        cooldown = 40,
        gcd = "spell",

        spend = 30,
        spendType = "fury",

        talent = "eye_beam",
        startsCombat = false,
        texture = 1305156,

        handler = function ()
        end,
    },


    fel_barrage = {
        id = 258925,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "fel_barrage",
        startsCombat = false,
        texture = 2065580,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    fel_eruption = {
        id = 211881,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 10,
        spendType = "fury",

        talent = "fel_eruption",
        startsCombat = false,
        texture = 1118739,

        handler = function ()
        end,
    },


    fel_rush = {
        id = 195072,
        cast = 0,
        charges = 1,
        cooldown = 10,
        recharge = 10,
        gcd = "off",
        icd = 0.25,

        startsCombat = false,
        texture = 1247261,

        handler = function ()
        end,
    },


    felblade = {
        id = 232893,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        talent = "felblade",
        startsCombat = false,
        texture = 1344646,

        handler = function ()
        end,
    },


    glaive_tempest = {
        id = 342817,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 30,
        spendType = "fury",

        talent = "glaive_tempest",
        startsCombat = false,
        texture = 1455916,

        handler = function ()
        end,
    },


    glide = {
        id = 131347,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        startsCombat = false,
        texture = 1305157,

        handler = function ()
        end,
    },


    immolation_aura = {
        id = 258920,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = false,
        texture = 1344649,

        handler = function ()
        end,
    },


    imprison = {
        id = 217832,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "imprison",
        startsCombat = false,
        texture = 1380368,

        handler = function ()
        end,
    },


    metamorphosis = {
        id = 191427,
        cast = 0,
        cooldown = 240,
        gcd = "spell",

        startsCombat = false,
        texture = 1247262,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    netherwalk = {
        id = 196555,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "netherwalk",
        startsCombat = false,
        texture = 463284,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    rain_from_above = {
        id = 206803,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "rain_from_above",
        startsCombat = false,
        texture = 1380371,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    reverse_magic = {
        id = 205604,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "reverse_magic",
        startsCombat = false,
        texture = 1380372,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    sigil_of_flame = {
        id = 204596,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "sigil_of_flame",
        startsCombat = false,
        texture = 1344652,

        handler = function ()
        end,
    },


    sigil_of_misery = {
        id = 207684,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "sigil_of_misery",
        startsCombat = false,
        texture = 1418287,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    sigil_of_silence = {
        id = 202137,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "sigil_of_silence",
        startsCombat = false,
        texture = 1418288,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    spectral_sight = {
        id = 188501,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        startsCombat = false,
        texture = 1247266,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    the_hunt = {
        id = 370965,
        cast = 1,
        cooldown = 90,
        gcd = "spell",

        talent = "the_hunt",
        startsCombat = false,
        texture = 3636838,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    throw_glaive = {
        id = 185123,
        cast = 0,
        charges = 1,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",

        spend = 0,
        spendType = "fury",

        startsCombat = true,
        texture = 1305159,

        handler = function ()
        end,
    },


    torment = {
        id = 185245,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 1344654,

        handler = function ()
        end,
    },


    vengeful_retreat = {
        id = 198793,
        cast = 0,
        cooldown = 25,
        gcd = "off",

        talent = "vengeful_retreat",
        startsCombat = false,
        texture = 1348401,

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Havoc", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )