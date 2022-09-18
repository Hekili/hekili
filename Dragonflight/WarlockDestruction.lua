-- WarlockDestruction.lua
-- September 2022

if UnitClassBase( "player" ) ~= "WARLOCK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 267 )

spec:RegisterResource( Enum.PowerType.SoulShards )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    abyss_walker                         = { 71954, 389609, 1 }, --
    accrued_vitality                     = { 71953, 386613, 2 }, --
    amplify_curse                        = { 71934, 328774, 1 }, --
    ashen_remains                        = { 71969, 387252, 2 }, --
    avatar_of_destruction                = { 71963, 387159, 1 }, --
    backdraft                            = { 72066, 196406, 1 }, --
    backlash                             = { 71983, 387384, 1 }, --
    banish                               = { 71944, 710   , 1 }, --
    burn_to_ashes                        = { 71964, 387153, 2 }, --
    burning_rush                         = { 71949, 111400, 1 }, --
    cataclysm                            = { 71974, 152108, 1 }, --
    channel_demonfire                    = { 72064, 196447, 1 }, --
    chaos_bolt                           = { 72068, 116858, 1 }, --
    chaos_incarnate                      = { 71966, 387275, 1 }, --
    claw_of_endereth                     = { 71926, 386689, 1 }, --
    conflagrate                          = { 72067, 17962 , 1 }, --
    conflagration_of_chaos               = { 72061, 387108, 2 }, --
    crashing_chaos                       = { 71960, 387355, 2 }, --
    cry_havoc                            = { 71981, 387522, 1 }, --
    curses_of_enfeeblement               = { 71951, 386105, 1 }, --
    dark_pact                            = { 71936, 108416, 1 }, --
    darkfury                             = { 71941, 264874, 1 }, --
    decimation                           = { 71977, 387176, 1 }, --
    demon_skin                           = { 71952, 219272, 2 }, --
    demonic_circle                       = { 71933, 268358, 1 }, --
    demonic_durability                   = { 71956, 386659, 1 }, --
    demonic_embrace                      = { 71930, 288843, 1 }, --
    demonic_fortitude                    = { 71922, 386617, 1 }, --
    demonic_gateway                      = { 71955, 111771, 1 }, --
    demonic_inspiration                  = { 71928, 386858, 1 }, --
    demonic_resilience                   = { 71917, 389590, 2 }, --
    desperate_power                      = { 71929, 386619, 2 }, --
    dimensional_rift                     = { 71966, 387976, 1 }, --
    embers_of_the_diabolic               = { 71968, 387173, 1 }, --
    eradication                          = { 71984, 196412, 2 }, --
    explosive_potential                  = { 72059, 388827, 1 }, --
    fel_armor                            = { 71950, 386124, 2 }, --
    fel_domination                       = { 71931, 333889, 1 }, --
    fel_synergy                          = { 71918, 389367, 1 }, --
    fire_and_brimstone                   = { 71982, 196408, 2 }, --
    flashpoint                           = { 71972, 387259, 2 }, --
    foul_mouth                           = { 71935, 387972, 1 }, --
    frequent_donor                       = { 71937, 386686, 1 }, --
    gorefiends_resolve                   = { 71916, 389623, 2 }, --
    greater_banish                       = { 71943, 386651, 1 }, --
    grimoire_of_sacrifice                = { 71971, 108503, 1 }, --
    grimoire_of_synergy                  = { 71924, 171975, 2 }, --
    havoc                                = { 71979, 80240 , 1 }, --
    howl_of_terror                       = { 71947, 5484  , 1 }, --
    ichor_of_devils                      = { 71937, 386664, 1 }, --
    imp_step                             = { 71948, 386110, 2 }, --
    improved_conflagrate                 = { 72065, 231793, 1 }, --
    improved_immolate                    = { 71976, 387093, 2 }, --
    infernal_brand                       = { 71958, 387475, 2 }, --
    inferno                              = { 71974, 270545, 1 }, --
    inquisitors_gaze                     = { 71939, 386344, 1 }, --
    internal_combustion                  = { 71980, 266134, 1 }, --
    lifeblood                            = { 71940, 386646, 2 }, --
    madness_of_the_azjaqir               = { 71967, 387400, 2 }, --
    master_ritualist                     = { 71962, 387165, 2 }, --
    mayhem_nyi                           = { 71979, 387506, 1 }, --
    mortal_coil                          = { 71947, 6789  , 1 }, --
    nightmare                            = { 71945, 386648, 2 }, --
    pandemonium                          = { 71981, 387509, 1 }, --
    power_overwhelming                   = { 71965, 387279, 2 }, --
    pyrogenics                           = { 71975, 387095, 1 }, --
    quick_fiends                         = { 71932, 386113, 2 }, --
    raging_demonfire                     = { 72063, 387166, 2 }, --
    rain_of_chaos                        = { 71959, 266086, 1 }, --
    rain_of_fire                         = { 72069, 5740  , 1 }, --
    resolute_barrier                     = { 71915, 389359, 2 }, --
    reverse_entropy                      = { 71980, 205148, 1 }, --
    ritual_of_ruin                       = { 71970, 387156, 1 }, --
    roaring_blaze                        = { 72065, 205184, 1 }, --
    rolling_havoc                        = { 71961, 387569, 2 }, --
    ruin                                 = { 72062, 387103, 2 }, --
    scalding_flames                      = { 71973, 388832, 2 }, --
    shadowburn                           = { 72060, 17877 , 1 }, --
    shadowflame                          = { 71941, 384069, 1 }, --
    shadowfury                           = { 71942, 30283 , 1 }, --
    soul_armor                           = { 71919, 389576, 2 }, --
    soul_conduit                         = { 71923, 215941, 2 }, --
    soul_fire                            = { 71978, 6353  , 1 }, --
    soul_link                            = { 71925, 108415, 1 }, --
    soulburn                             = { 71957, 385899, 1 }, --
    strength_of_will                     = { 71956, 317138, 1 }, --
    summon_infernal                      = { 71985, 1122  , 1 }, --
    summon_soulkeeper                    = { 71939, 386244, 1 }, --
    sweet_souls                          = { 71927, 386620, 1 }, --
    teachings_of_the_black_harvest       = { 71938, 385881, 1 }, --
    wilfreds_sigil_of_superior_summoning = { 71959, 387084, 1 }, --
    wrathful_minion                      = { 71946, 386864, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bane_of_fragility = 3502, -- 199954
    bane_of_havoc     = 164 , -- 200546
    bonds_of_fel      = 5401, -- 353753
    call_observer     = 5544, -- 201996
    casting_circle    = 3510, -- 221703
    cremation         = 159 , -- 212282
    essence_drain     = 3509, -- 221711
    fel_fissure       = 157 , -- 200586
    gateway_mastery   = 5382, -- 248855
    nether_ward       = 3508, -- 212295
    precognition      = 5507, -- 377360
    shadow_rift       = 5393, -- 353294
} )


-- Auras
spec:RegisterAuras( {
    abyss_walker = {
        id = 389614,
        duration = 10,
        max_stack = 1
    },
    amplify_curse = {
        id = 328774,
        duration = 15,
        max_stack = 1
    },
    backlash = {
        id = 387385,
        duration = 15,
        max_stack = 1
    },
    bane_of_fragility = {
        id = 199954,
        duration = 10,
        max_stack = 1
    },
    bane_of_havoc = { -- TODO: Check for Bane of Havoc totem to control duration.
        id = 200548,
        duration = 10,
        max_stack = 1
    },
    banish = {
        id = 710,
        duration = 30,
        max_stack = 1
    },
    bonds_of_fel = {
        id = 353807,
        duration = 6,
        max_stack = 1
    },
    burn_to_ashes = {
        id = 387154,
        duration = 20,
        max_stack = 4
    },
    burning_rush = {
        id = 111400,
        duration = 3600,
        tick_time = 1,
        max_stack = 1
    },
    call_observer = { -- TODO: Check for totem to control duration.  See if enemy is debuffed.
        id = 201996,
        duration = 20,
        max_stack = 1
    },
    casting_circle = { -- TODO: Virtual aura; model from successful cast.
        id = 221705,
        duration = 12,
        max_stack = 1
    },
    channel_demonfire = { -- TODO: Channel controller, modified by Raging Demonfire talent.
        id = 196447,
        duration = 3,
        tick_time = 0.2,
        max_stack = 1
    },
    curse_of_exhaustion = {
        id = 334275,
        duration = 12,
        max_stack = 1
    },
    dark_pact = {
        id = 108416,
        duration = 20,
        max_stack = 1
    },
    demonic_circle = {
        id = 48018,
        duration = 900,
        max_stack = 1
    },
    demonic_inspiration = {
        id = 386861,
        duration = 8,
        max_stack = 1
    },
    drain_life = {
        id = 234153,
        duration = 5,
        tick_time = 1,
        max_stack = 1
    },
    eradication = {
        id = 196414,
        duration = 7,
        max_stack = 1
    },
    eye_of_kilrogg = {
        id = 126,
        duration = 45,
        max_stack = 1
    },
    fel_domination = {
        id = 333889,
        duration = 15,
        max_stack = 1
    },
    grimoire_of_sacrifice = {
        id = 196099,
        duration = 3600,
        max_stack = 1
    },
    havoc = {
        id = 80240,
        duration = 12,
        max_stack = 1
    },
    health_funnel = {
        id = 755,
        duration = 5,
        tick_time = 1,
        max_stack = 1
    },
    howl_of_terror = {
        id = 5484,
        duration = 20,
        max_stack = 1
    },
    infernal_awakening = {
        id = 22703,
        duration = 2,
        max_stack = 1
    },
    inquisitors_gaze = {
        id = 388068,
        duration = 3600,
        max_stack = 1
    },
    lifeblood = {
        id = 386647,
        duration = 20,
        max_stack = 1
    },
    mortal_coil = {
        id = 6789,
        duration = 3,
        max_stack = 1
    },
    nether_ward = {
        id = 212295,
        duration = 3,
        max_stack = 1
    },
    rain_of_fire = {
        id = 5740,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    reverse_entropy = {
        id = 266030,
        duration = 8,
        max_stack = 1
    },
    shadow_rift = {
        id = 353293,
        duration = 2,
        max_stack = 1
    },
    shadowburn = {
        id = 17877,
        duration = 5,
        max_stack = 1
    },
    shadowflame = {
        id = 384069,
        duration = 6,
        max_stack = 1
    },
    shadowfury = {
        id = 30283,
        duration = 3,
        max_stack = 1
    },
    soulburn = {
        id = 387626,
        duration = 3600,
        max_stack = 1
    },
    soulstone = {
        id = 20707,
        duration = 900,
        max_stack = 1
    },
    subjugate_demon = {
        id = 1098,
        duration = 300,
        max_stack = 1
    },
    summon_infernal = { -- TODO: Totem?
        id = 111685,
        duration = 30,
        max_stack = 1
    },
    tormented_soul = { -- TODO: This isn't a visible aura; instead it sets the count on the Summon Soulkeeper spell.
        id = 386251,
        duration = 3600,
        max_stack = 10
    },
    unending_breath = {
        id = 5697,
        duration = 600,
        max_stack = 1
    },
    unending_resolve = {
        id = 104773,
        duration = 8,
        max_stack = 1
    },
    wrathful_minion = {
        id = 386865,
        duration = 8,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    amplify_curse = {
        id = 328774,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        talent = "amplify_curse",
        startsCombat = false,
        texture = 136132,

        handler = function ()
        end,
    },


    bane_of_fragility = {
        id = 199954,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "bane_of_fragility",
        startsCombat = false,
        texture = 132097,

        handler = function ()
        end,
    },


    bane_of_havoc = {
        id = 200546,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "bane_of_havoc",
        startsCombat = false,
        texture = 1380866,

        handler = function ()
        end,
    },


    banish = {
        id = 710,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "banish",
        startsCombat = false,
        texture = 136135,

        handler = function ()
        end,
    },


    bonds_of_fel = {
        id = 353753,
        cast = 1.5,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        pvptalent = "bonds_of_fel",
        startsCombat = false,
        texture = 1117883,

        handler = function ()
        end,
    },


    burning_rush = {
        id = 111400,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "burning_rush",
        startsCombat = false,
        texture = 538043,

        handler = function ()
        end,
    },


    call_observer = {
        id = 201996,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "call_observer",
        startsCombat = false,
        texture = 538445,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    casting_circle = {
        id = 221703,
        cast = 0.5,
        cooldown = 60,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        pvptalent = "casting_circle",
        startsCombat = false,
        texture = 1392953,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    cataclysm = {
        id = 152108,
        cast = 2,
        cooldown = 30,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "cataclysm",
        startsCombat = false,
        texture = 409545,

        handler = function ()
        end,
    },


    channel_demonfire = {
        id = 196447,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "channel_demonfire",
        startsCombat = false,
        texture = 840407,

        handler = function ()
        end,
    },


    chaos_bolt = {
        id = 116858,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 2,
        spendType = "soul_shards",

        talent = "chaos_bolt",
        startsCombat = false,
        texture = 236291,

        handler = function ()
        end,
    },


    conflagrate = {
        id = 17962,
        cast = 0,
        charges = 2,
        cooldown = 11.81,
        recharge = 11.81,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "conflagrate",
        startsCombat = false,
        texture = 135807,

        handler = function ()
        end,
    },


    create_healthstone = {
        id = 6201,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 538745,

        handler = function ()
        end,
    },


    create_soulwell = {
        id = 29893,
        cast = 3,
        cooldown = 120,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,
        texture = 136194,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    curse_of_exhaustion = {
        id = 334275,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 136162,

        handler = function ()
        end,
    },


    dark_pact = {
        id = 108416,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "dark_pact",
        startsCombat = false,
        texture = 136146,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    demonic_circle = {
        id = 48018,
        cast = 0.5,
        cooldown = 10,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 237559,

        handler = function ()
        end,
    },


    demonic_circle_teleport = {
        id = 48020,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 237560,

        handler = function ()
        end,
    },


    demonic_gateway = {
        id = 111771,
        cast = 2,
        cooldown = 10,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        talent = "demonic_gateway",
        startsCombat = false,
        texture = 607512,

        handler = function ()
        end,
    },


    dimensional_rift = {
        id = 387976,
        cast = 0,
        charges = 3,
        cooldown = 45,
        recharge = 45,
        gcd = "spell",

        talent = "dimensional_rift",
        startsCombat = false,
        texture = 607513,

        handler = function ()
        end,
    },


    drain_life = {
        id = 234153,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = 136169,

        handler = function ()
        end,
    },


    eye_of_kilrogg = {
        id = 126,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 136155,

        handler = function ()
        end,
    },


    fear = {
        id = 5782,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,
        texture = 136183,

        handler = function ()
        end,
    },


    fel_domination = {
        id = 333889,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "fel_domination",
        startsCombat = false,
        texture = 237564,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    grimoire_of_sacrifice = {
        id = 108503,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "grimoire_of_sacrifice",
        startsCombat = false,
        texture = 538443,

        handler = function ()
        end,
    },


    havoc = {
        id = 80240,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "havoc",
        startsCombat = false,
        texture = 460695,

        handler = function ()
        end,
    },


    health_funnel = {
        id = 755,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 136168,

        handler = function ()
        end,
    },


    howl_of_terror = {
        id = 5484,
        cast = 0,
        cooldown = 40,
        gcd = "spell",

        talent = "howl_of_terror",
        startsCombat = false,
        texture = 607852,

        handler = function ()
        end,
    },


    immolate = {
        id = 348,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 135817,

        handler = function ()
        end,
    },


    incinerate = {
        id = 29722,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 135789,

        handler = function ()
        end,
    },


    inquisitors_gaze = {
        id = 386344,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        talent = "inquisitors_gaze",
        startsCombat = false,
        texture = 1387707,

        handler = function ()
        end,
    },


    mortal_coil = {
        id = 6789,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "mortal_coil",
        startsCombat = false,
        texture = 607853,

        handler = function ()
        end,
    },


    nether_ward = {
        id = 212295,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "nether_ward",
        startsCombat = false,
        texture = 135796,

        handler = function ()
        end,
    },


    rain_of_fire = {
        id = 5740,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 3,
        spendType = "soul_shards",

        talent = "rain_of_fire",
        startsCombat = false,
        texture = 136186,

        handler = function ()
        end,
    },


    ritual_of_doom = {
        id = 342601,
        cast = 0,
        cooldown = 3600,
        gcd = "spell",

        spend = 1,
        spendType = "soul_shards",

        startsCombat = false,
        texture = 538538,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    ritual_of_summoning = {
        id = 698,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = 136223,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    shadow_bulwark = {
        id = 119907,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        startsCombat = false,
        texture = 136121,

        handler = function ()
        end,
    },


    shadow_rift = {
        id = 353294,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "shadow_rift",
        startsCombat = false,
        texture = 4067372,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    shadowburn = {
        id = 17877,
        cast = 0,
        charges = 2,
        cooldown = 12,
        recharge = 12,
        gcd = "spell",

        spend = 1,
        spendType = "soul_shards",

        talent = "shadowburn",
        startsCombat = false,
        texture = 136191,

        handler = function ()
        end,
    },


    shadowflame = {
        id = 384069,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        talent = "shadowflame",
        startsCombat = false,
        texture = 236302,

        handler = function ()
        end,
    },


    shadowfury = {
        id = 30283,
        cast = 1.5,
        cooldown = 60,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "shadowfury",
        startsCombat = false,
        texture = 607865,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    soul_fire = {
        id = 6353,
        cast = 4,
        cooldown = 45,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "soul_fire",
        startsCombat = false,
        texture = 135809,

        handler = function ()
        end,
    },


    soulburn = {
        id = 385899,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        spend = 1,
        spendType = "soul_shards",

        talent = "soulburn",
        startsCombat = false,
        texture = 463286,

        handler = function ()
        end,
    },


    soulstone = {
        id = 20707,
        cast = 3,
        cooldown = 600,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 136210,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    subjugate_demon = {
        id = 1098,
        cast = 3,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 136154,

        handler = function ()
        end,
    },


    summon_infernal = {
        id = 1122,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "summon_infernal",
        startsCombat = false,
        texture = 136219,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    unending_breath = {
        id = 5697,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136148,

        handler = function ()
        end,
    },


    unending_resolve = {
        id = 104773,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 136150,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Destruction", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )