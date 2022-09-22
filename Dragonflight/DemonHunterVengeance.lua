-- DemonHunterVengeance.lua
-- September 2022

if UnitClassBase( "player" ) ~= "DEMONHUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 581 )

spec:RegisterResource( Enum.PowerType.Fury )
spec:RegisterResource( Enum.PowerType.Pain )

-- Talents
spec:RegisterTalents( {
    aldrachi_design          = { 82964, 391409, 1 }, --
    any_means_necessary      = { 82920, 388114, 1 }, --
    aura_of_pain             = { 82951, 207347, 1 }, --
    blind_fury               = { 82913, 203550, 2 }, --
    bouncing_glaives         = { 82941, 320386, 1 }, --
    burning_hatred           = { 82899, 320374, 1 }, --
    burning_wound            = { 82918, 391189, 1 }, --
    chaos_fragments          = { 82849, 320412, 1 }, --
    chaos_nova               = { 82960, 179057, 1 }, --
    chaos_theory             = { 82934, 389687, 1 }, --
    chaotic_transformation   = { 82906, 388112, 1 }, --
    charred_warblades        = { 82855, 213010, 1 }, --
    collective_anguish       = { 82850, 390152, 1 }, --
    concentrated_sigils      = { 82967, 207666, 1 }, --
    consume_magic            = { 82953, 320313, 1 }, --
    consume_magic            = { 82952, 278326, 1 }, --
    critical_chaos           = { 82907, 320413, 2 }, --
    cycle_of_hatred          = { 82937, 258887, 2 }, --
    dancing_with_fate        = { 82901, 389978, 2 }, --
    darkness                 = { 82959, 196718, 1 }, --
    demon_blades             = { 82939, 203555, 1 }, --
    demon_muzzle_nyi         = { 82848, 388111, 1 }, --
    demonic                  = { 82957, 213410, 1 }, --
    demonic_appetite         = { 82893, 206478, 1 }, --
    demonic_origins          = { 82957, 235893, 1 }, --
    desperate_instincts      = { 82891, 205411, 1 }, --
    disrupting_fury          = { 82853, 183782, 1 }, --
    elysian_decree           = { 82916, 390163, 1 }, --
    erratic_felheart         = { 82851, 391397, 2 }, --
    essence_break            = { 82932, 258860, 1 }, --
    extended_sigils          = { 82963, 389697, 2 }, --
    eye_beam                 = { 82940, 198013, 1 }, --
    fae_empowered_elixir     = { 82968, 389819, 1 }, --
    fel_barrage              = { 82935, 258925, 1 }, --
    fel_eruption             = { 82902, 211881, 1 }, --
    felblade                 = { 82951, 232893, 1 }, --
    felfire_haste            = { 82948, 389846, 1 }, --
    felfire_heart            = { 82898, 388109, 1 }, --
    first_blood              = { 82897, 206416, 1 }, --
    flames_of_fury           = { 82856, 389694, 1 }, --
    fodder_to_the_flame      = { 82916, 391429, 1 }, --
    furious_gaze             = { 82914, 343311, 1 }, --
    furious_throws           = { 82892, 393029, 1 }, --
    glaive_tempest           = { 82935, 342817, 1 }, --
    growing_inferno          = { 82919, 390158, 2 }, --
    hot_feet                 = { 82943, 320416, 1 }, --
    illidari_knowledge       = { 82961, 389696, 2 }, --
    imprison                 = { 82942, 217832, 1 }, --
    improved_chaos_strike    = { 82895, 343206, 1 }, --
    improved_disrupt         = { 82950, 320361, 1 }, --
    improved_fel_rush        = { 82894, 343017, 1 }, --
    improved_sigil_of_misery = { 82971, 320418, 1 }, --
    infernal_armor           = { 82954, 320331, 2 }, --
    initiative               = { 82908, 388108, 1 }, --
    inner_demon              = { 82915, 389693, 1 }, --
    insatiable_hunger        = { 82939, 258876, 1 }, --
    internal_struggle        = { 82852, 393822, 1 }, --
    isolated_prey            = { 82912, 388113, 1 }, --
    know_your_enemy          = { 82933, 388118, 2 }, --
    long_night               = { 82958, 389781, 1 }, --
    looks_can_kill           = { 82905, 320415, 1 }, --
    lost_in_darkness         = { 82854, 389849, 1 }, --
    master_of_the_glaive     = { 82947, 389763, 1 }, --
    misery_in_defeat         = { 82971, 388110, 1 }, --
    moarg_bionics            = { 82917, 391275, 1 }, --
    momentum                 = { 82909, 206476, 1 }, --
    mortal_dance             = { 82896, 328725, 1 }, --
    netherwalk               = { 82891, 196555, 1 }, --
    pitch_black              = { 82958, 389783, 1 }, --
    precise_sigils           = { 82967, 389799, 1 }, --
    pursuit                  = { 82949, 320654, 1 }, --
    quickened_sigils         = { 82962, 209281, 1 }, --
    ragefire                 = { 82890, 388107, 1 }, --
    relentless_onslaught     = { 82903, 389977, 1 }, --
    restless_hunter          = { 82936, 390142, 1 }, --
    rush_of_chaos            = { 82955, 320421, 1 }, --
    serrated_glaive          = { 82904, 390154, 2 }, --
    shattered_destiny        = { 82938, 388116, 1 }, --
    shattered_restoration    = { 82857, 389824, 2 }, --
    sigil_of_flame           = { 82858, 204596, 1 }, --
    sigil_of_misery          = { 82970, 207684, 1 }, --
    sigil_of_silence         = { 82965, 202137, 1 }, --
    soul_rending             = { 82956, 204909, 2 }, --
    soulrend                 = { 82921, 388106, 2 }, --
    tactical_retreat         = { 82910, 389688, 1 }, --
    the_hunt                 = { 82969, 370965, 1 }, --
    trail_of_ruin            = { 82900, 258881, 1 }, --
    unbound_chaos            = { 82911, 347461, 2 }, --
    unleashed_power          = { 82849, 206477, 1 }, --
    unnatural_malice         = { 82968, 389811, 1 }, --
    unrestrained_fury        = { 82946, 320770, 2 }, --
    vengeful_restraint       = { 82945, 320635, 1 }, --
    vengeful_retreat         = { 82944, 198793, 1 }, --
    will_of_the_illidari     = { 82966, 389695, 2 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    blood_moon        = 5434, -- 355995
    chaotic_imprint   = 5439, -- 356510
    cleansed_by_flame = 814 , -- 205625
    cover_of_darkness = 5520, -- 357419
    demonic_trample   = 3423, -- 205629
    detainment        = 3430, -- 205596
    everlasting_hunt  = 815 , -- 205626
    glimpse           = 5522, -- 354489
    illidans_grasp    = 819 , -- 205630
    jagged_spikes     = 816 , -- 205627
    rain_from_above   = 5521, -- 206803
    reverse_magic     = 3429, -- 205604
    sigil_mastery     = 1948, -- 211489
    tormentor         = 1220, -- 207029
    unending_hatred   = 3727, -- 213480
} )


-- Auras
spec:RegisterAuras( {
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
    demonic_trample = {
        id = 205629,
        duration = 3,
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
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 5
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
    illidans_grasp = {
        id = 205630,
        duration = 6,
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
        id = 187827,
        duration = 15,
        tick_time = 2,
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
    vengeful_retreat_198793 = { -- TODO: Disambiguate -- TODO: Check Aura (https://wowhead.com/beta/spell=198793)
        id = 198793,
        duration = 1,
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


    demon_spikes = {
        id = 203720,
        cast = 0,
        charges = 2,
        cooldown = 20,
        recharge = 20,
        gcd = "off",

        startsCombat = false,
        texture = 1344645,

        handler = function ()
        end,
    },


    demonic_trample = {
        id = 205629,
        cast = 0,
        charges = 1,
        cooldown = 20,
        recharge = 20,
        gcd = "off",

        pvptalent = "demonic_trample",
        startsCombat = false,
        texture = 134294,

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

        talent = "fel_eruption",
        startsCombat = false,
        texture = 1118739,

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


    fiery_brand = {
        id = 204021,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "spell",

        startsCombat = true,
        texture = 1344647,

        toggle = "cooldowns",

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


    illidans_grasp = {
        id = 205630,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "illidans_grasp",
        startsCombat = false,
        texture = 1380367,

        toggle = "cooldowns",

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


    infernal_strike = {
        id = 189110,
        cast = 0,
        charges = 1,
        cooldown = 20,
        recharge = 20,
        gcd = "off",

        startsCombat = false,
        texture = 1344650,

        handler = function ()
        end,
    },


    metamorphosis = {
        id = 187827,
        cast = 0,
        cooldown = 240,
        gcd = "off",

        startsCombat = false,
        texture = 1247263,

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


    shear = {
        id = 203782,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 1344648,

        handler = function ()
        end,
    },


    sigil_of_flame = {
        id = 204596,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "sigil_of_flame",
        startsCombat = true,
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


    soul_cleave = {
        id = 228477,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 35,
        spendType = "fury",

        startsCombat = false,
        texture = 1344653,

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
        id = 204157,
        cast = 0,
        cooldown = 9,
        gcd = "spell",

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


    tormentor = {
        id = 207029,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        pvptalent = "tormentor",
        startsCombat = false,
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

spec:RegisterPriority( "Vengeance", 20220921,
-- Notes
[[

]],
-- Priority
[[

]] )