-- EvokerPreservation.lua
-- DF Pre-Patch Nov 2022

if UnitClassBase( "player" ) ~= "EVOKER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 1468 )

spec:RegisterResource( Enum.PowerType.Essence )
spec:RegisterResource( Enum.PowerType.Mana, {
    disintegrate = {
        channel = "disintegrate",
        talent = "energy_loop",

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.disintegrate.tick_time ) * class.auras.disintegrate.tick_time
        end,

        interval = function () return class.auras.disintegrate.tick_time end,
        value = function () return 0.024 * mana.max end, -- TODO: Check if should be modmax.
    }
} )

-- Talents
spec:RegisterTalents( {
    -- Evoker
    aerial_mastery       = { 68659, 365933, 1 },
    ancient_flame        = { 68671, 369990, 1 },
    attuned_to_the_dream = { 68672, 376930, 2 },
    blast_furnace        = { 68667, 375510, 2 },
    bountiful_bloom      = { 68572, 370886, 1 },
    cauterizing_flame    = { 68673, 374251, 1 },
    clobbering_sweep     = { 68570, 375443, 1 },
    draconic_legacy      = { 68685, 376166, 2 },
    enkindled            = { 68677, 375554, 2 },
    extended_flight      = { 68679, 375517, 2 },
    exuberance           = { 68573, 375542, 1 },
    fire_within          = { 68654, 375577, 1 },
    foci_of_life         = { 68654, 375574, 1 },
    forger_of_mountains  = { 68569, 375528, 1 },
    heavy_wingbeats      = { 68570, 368838, 1 },
    inherent_resistance  = { 68670, 375544, 2 },
    innate_magic         = { 68683, 375520, 2 },
    instinctive_arcana   = { 68666, 376164, 2 },
    leaping_flames       = { 68662, 369939, 1 },
    lush_growth          = { 68652, 375561, 2 },
    natural_convergence  = { 68682, 369913, 1 },
    obsidian_bulwark     = { 68674, 375406, 1 },
    obsidian_scales      = { 68675, 363916, 1 },
    oppressing_roar      = { 68668, 372048, 1 },
    overawe              = { 68660, 374346, 1 },
    panacea              = { 68680, 387761, 1 },
    permeating_chill     = { 68676, 370897, 1 },
    protracted_talons    = { 68661, 369909, 1 },
    quell                = { 68665, 351338, 1 },
    recall               = { 68684, 371806, 1 },
    regenerative_magic   = { 68651, 387787, 1 },
    renewing_blaze       = { 68653, 374348, 1 },
    rescue               = { 68658, 370665, 1 },
    roar_of_exhilaration = { 68664, 375507, 1 },
    scarlet_adaptation   = { 68687, 372469, 1 },
    sleep_walk           = { 68571, 360806, 1 },
    source_of_magic      = { 68669, 369459, 1 },
    tailwind             = { 68678, 375556, 1 },
    terror_of_the_skies  = { 68649, 371032, 1 },
    time_spiral          = { 68650, 374968, 1 },
    tip_the_scales       = { 68686, 370553, 1 },
    twin_guardian        = { 68656, 370888, 1 },
    unravel              = { 68663, 368432, 1 },
    verdant_embrace      = { 68688, 360995, 1 },
    walloping_blow       = { 68657, 387341, 1 },
    zephyr               = { 68655, 374227, 1 },
    
    -- Preservation
    call_of_ysera        = { 68599, 373834, 1 },
    cycle_of_life        = { 68602, 371832, 1 },
    delay_harm           = { 68584, 376207, 1 },
    dream_breath         = { 68606, 355936, 1 },
    dream_flight         = { 68580, 359816, 1 },
    dreamwalker          = { 68576, 377082, 1 },
    echo                 = { 68607, 364343, 1 },
    emerald_communion    = { 68577, 370960, 1 },
    empath               = { 68603, 376138, 1 },
    energy_loop          = { 68588, 372233, 1 },
    erasure              = { 68600, 376210, 1 },
    essence_attunement   = { 68610, 375722, 1 },
    essence_burst        = { 68609, 369297, 1 },
    exhilarating_burst   = { 68578, 377100, 2 },
    expunge              = { 68689, 365585, 1 },
    field_of_dreams      = { 68612, 370062, 1 },
    flow_state           = { 68591, 385696, 2 },
    fluttering_seedlings = { 68611, 359793, 2 },
    font_of_magic        = { 68579, 375783, 1 },
    golden_hour          = { 68595, 378196, 1 },
    grace_period         = { 68601, 376239, 2 },
    just_in_time         = { 68584, 376204, 1 },
    landslide            = { 68681, 358385, 1 },
    lifebind             = { 68613, 373270, 1 },
    lifeforce_mender     = { 68598, 376179, 2 },
    lifegivers_flame     = { 68597, 371426, 2 },
    nozdormus_teachings  = { 68590, 376237, 1 },
    ouroboros            = { 68583, 381921, 1 },
    power_nexus          = { 68581, 369908, 1 },
    punctuality          = { 68589, 371270, 1 },
    renewing_breath      = { 68582, 371257, 2 },
    resonating_sphere    = { 68590, 376236, 1 },
    reversion            = { 68608, 366155, 1 },
    rewind               = { 68593, 363534, 1 },
    rush_of_vitality     = { 68576, 377086, 1 },
    spark_of_insight     = { 68614, 377099, 1 },
    spiritbloom          = { 68604, 367226, 1 },
    spiritual_clarity    = { 68603, 376150, 1 },
    stasis               = { 68585, 370537, 1 },
    temporal_anomaly     = { 68592, 373861, 1 },
    temporal_artificer   = { 68600, 381922, 1 },
    temporal_compression = { 68605, 362874, 1 },
    time_dilation        = { 68594, 357170, 1 },
    time_lord            = { 68596, 372527, 2 },
    time_of_need         = { 68586, 368412, 1 },
    timeless_magic       = { 68587, 376240, 2 },
} )


-- PvP Talents
spec:RegisterPvpTalents( { 
    chrono_loop       = 5455,
    dream_projection  = 5454,
    nullifying_shroud = 5468,
    obsidian_mettle   = 5459,
    precognition      = 5502,
    scouring_flame    = 5461,
    swoop_up          = 5465,
    time_stop         = 5463,
    unburdened_flight = 5470,
} )


-- Auras
spec:RegisterAuras( {
    boon_of_the_covenants = {
        id = 387168,
    },
    call_of_ysera = {
        id = 373835,
        duration = 15,
        max_stack = 1
    },
    chrono_loop = {
        id = 383005,
        duration = 5,
        max_stack = 1
    },
    deep_breath = {
        id = 357210,
        duration = 6,
        max_stack = 1
    },
    disintegrate = {
        id = 356995,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    dream_breath = { -- TODO: This is the empowerment cast.
        id = 355936,
        duration = 2.5,
        max_stack = 1
    },
    dream_flight = {
        id = 359816,
        duration = 6,
        max_stack = 1
    },
    dream_projection = { -- TODO: PvP talent summon/pet?
        id = 377509,
        duration = 5,
        max_stack = 1
    },
    dreamwalker = {
        id = 377082,
    },
    echo = {
        id = 364343,
        duration = 15,
        max_stack = 1
    },
    emerald_blossom = { -- TODO: Check Aura (https://wowhead.com/beta/spell=355913)
        id = 355913,
        duration = 2,
        max_stack = 1
    },
    emerald_communion = {
        id = 370960,
        duration = 5,
        tick_time = 1,
        max_stack = 1
    },
    essence_burst = {
        id = 369299,
        duration = 15,
        max_stack = 2
    },
    fire_breath = { -- TODO: This is the empowerment cast.
        id = 357208,
        duration = 2.5,
        max_stack = 1
    },
    fly_with_me = {
        id = 370665,
        duration = 1,
        max_stack = 1
    },
    fury_of_the_aspects = {
        id = 390386,
        duration = 40,
        max_stack = 1
    },
    hover = {
        id = 358267,
        duration = 6,
        tick_time = 1,
        max_stack = 1
    },
    mastery_lifebinder = {
        id = 363510,
    },
    nullifying_shroud = {
        id = 378464,
        duration = 30,
        max_stack = 3
    },
    obsidian_scales = {
        id = 363916,
        duration = 12,
        max_stack = 1
    },
    oppressing_roar = {
        id = 372048,
        duration = 10,
        max_stack = 1
    },
    permeating_chill = {
        id = 370898,
        duration = 3,
        max_stack = 1
    },
    renewing_blaze = {
        id = 374348,
        duration = 8,
        max_stack = 1
    },
    reversion = {
        id = 366155,
        duration = 12,
        tick_time = 2,
        max_stack = 1
    },
    rewind = {
        id = 363534,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    sleep_walk = {
        id = 360806,
        duration = 20,
        max_stack = 1
    },
    source_of_magic = {
        id = 369459,
        duration = 1800,
        max_stack = 1
    },
    spiritbloom = { -- TODO: This is the empowerment channel.
        id = 367226,
        duration = 2.5,
        max_stack = 1
    },
    stasis = {
        id = 370537,
        duration = 3600,
        max_stack = 3
    },
    temporal_anomaly = { -- TODO: Creates an absorb vortex effect.
        id = 373861,
        duration = 6,
        tick_time = 2,
        max_stack = 1
    },
    temporal_compression = {
        id = 362877,
        duration = 15,        
        max_stack = 4
    },
    terror_of_the_skies = {
        id = 372245,
        duration = 3,
        max_stack = 1
    },
    time_dilation = {
        id = 357170,
        duration = 8,
        max_stack = 1
    },
    time_stop = {
        id = 378441,
        duration = 4,
        max_stack = 1
    },
    tip_the_scales = {
        id = 370553,
        duration = 3600,
        max_stack = 1
    },
    youre_coming_with_me = {
        id = 370388,
        duration = 1,
        max_stack = 1
    },
    zephyr = {
        id = 374227,
        duration = 8,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    azure_strike = {
        id = 362969,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        spend = 0.01,
        spendType = "mana",
        
        startsCombat = true,
        texture = 4622447,
        
        handler = function ()
        end,
    },
    blessing_of_the_bronze = {
        id = 364342,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        
        spend = 0.04,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4622448,
        
        handler = function ()
        end,
    },
    boon_of_the_covenants = {
        id = 387168,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        
        startsCombat = false,
        texture = 3601566,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    cauterizing_flame = {
        id = 374251,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        
        spend = 0.01,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4630446,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    chrono_loop = {
        id = 383005,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        
        spend = 0.02,
        spendType = "mana",
        
        startsCombat = true,
        texture = 4630470,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    deep_breath = {
        id = 357210,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        
        startsCombat = true,
        texture = 4622450,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    disintegrate = {
        id = 356995,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        spend = 3,
        spendType = "essence",
        
        startsCombat = true,
        texture = 4622451,
        
        handler = function ()
            removeStack("essence_burst")
        end,
    },
    dream_breath = {
        id = 355936,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        icd = 0.5,
        
        spend = 0.04,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4622454,
        
        handler = function ()
            removeBuff("call_of_ysera")
            removeBuff("tip_the_scales")
            removeBuff("temporal_compression")
        end,
    },
    dream_flight = {
        id = 359816,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        
        spend = 0.04,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4622455,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    dream_projection = {
        id = 377509,
        cast = 0.5,
        cooldown = 90,
        gcd = "spell",
        
        startsCombat = false,
        texture = 4622475,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    echo = {
        id = 364343,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        spend = 2,
        spendType = "essence",
        
        startsCombat = false,
        texture = 4622456,
        
        handler = function ()
            removeStack("essence_burst")
        end,
    },
    emerald_blossom = {
        id = 355913,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        
        spend = 3,
        spendType = "essence",
        
        startsCombat = false,
        texture = 4622457,
        
        handler = function ()
            removeStack("essence_burst")
        end,
    },
    emerald_communion = {
        id = 370960,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        
        startsCombat = false,
        texture = 4630447,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    expunge = {
        id = 365585,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        
        spend = 0.01,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4630445,
        
        handler = function ()
        end,
    },
    fire_breath = {
        id = 357208,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        icd = 0.5,
        
        spend = 0.03,
        spendType = "mana",
        
        startsCombat = true,
        texture = 4622458,
        
        handler = function ()
            removeBuff("tip_the_scales")
            removeBuff("temporal_compression")
        end,
    },
    fury_of_the_aspects = {
        id = 390386,
        cast = 0,
        cooldown = 300,
        gcd = "off",
        
        spend = 0.04,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4723908,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    hover = {
        id = 358267,
        cast = 0,
        charges = 2,
        cooldown = 35,
        recharge = 35,
        gcd = "off",
        
        startsCombat = false,
        texture = 4622463,
        
        handler = function ()
        end,
    },
    landslide = {
        id = 358385,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        
        spend = 0.03,
        spendType = "mana",
        
        startsCombat = true,
        texture = 1016245,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    living_flame = {
        id = 361469,
        cast = 2,
        cooldown = 0,
        gcd = "spell",
        
        spend = 0.02,
        spendType = "mana",
        
        startsCombat = true,
        texture = 4622464,
        
        handler = function ()
            removeBuff("call_of_ysera")
        end,
    },
    naturalize = {
        id = 360823,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        
        spend = 0.01,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4630445,
        
        handler = function ()
        end,
    },
    nullifying_shroud = {
        id = 378464,
        cast = 1.5,
        cooldown = 90,
        gcd = "spell",
        
        spend = 0.01,
        spendType = "mana",
        
        startsCombat = false,
        texture = 135752,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    obsidian_scales = {
        id = 363916,
        cast = 0,
        charges = 2,
        cooldown = 90,
        recharge = 90,
        gcd = "off",
        
        startsCombat = false,
        texture = 1394891,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    oppressing_roar = {
        id = 372048,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        
        startsCombat = false,
        texture = 4622466,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    quell = {
        id = 351338,
        cast = 0,
        cooldown = 40,
        gcd = "off",
        
        startsCombat = true,
        texture = 4622469,
        
        handler = function ()
        end,
    },
    renewing_blaze = {
        id = 374348,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        
        startsCombat = false,
        texture = 4630463,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    rescue = {
        id = 370665,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        
        startsCombat = false,
        texture = 4622460,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    reversion = {
        id = 366155,
        cast = 0,
        charges = 1,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",
        
        spend = 0.02,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4630467,
        
        handler = function ()
        end,
    },
    rewind = {
        id = 363534,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "spell",
        
        spend = 0.05,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4622474,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    sleep_walk = {
        id = 360806,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",
        
        spend = 0.02,
        spendType = "mana",
        
        startsCombat = true,
        texture = 1396974,
        
        handler = function ()
        end,
    },
    source_of_magic = {
        id = 369459,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        startsCombat = false,
        texture = 4630412,
        
        handler = function ()
        end,
    },
    spiritbloom = {
        id = 367226,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        icd = 0.5,
        
        spend = 0.04,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4622476,
        
        handler = function ()
            removeBuff("tip_the_scales")
            removeBuff("temporal_compression")
        end,
    },
    stasis = {
        id = 370537,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        
        spend = 0.04,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4630476,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    swoop_up = {
        id = 370388,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        
        startsCombat = false,
        texture = 4622446,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    temporal_anomaly = {
        id = 373861,
        cast = 1.5,
        cooldown = 6,
        gcd = "spell",
        
        spend = 0.08,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4630480,
        
        handler = function ()
        end,
    },
    time_dilation = {
        id = 357170,
        cast = 0,
        cooldown = 60,
        gcd = "off",
        
        spend = 0.02,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4622478,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    time_spiral = {
        id = 374968,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        
        startsCombat = false,
        texture = 4622479,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    time_stop = {
        id = 378441,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        
        startsCombat = false,
        texture = 4631367,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    tip_the_scales = {
        id = 370553,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        
        startsCombat = false,
        texture = 4622480,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    unravel = {
        id = 368432,
        cast = 0,
        cooldown = 9,
        gcd = "spell",
        
        spend = 0.01,
        spendType = "mana",
        
        startsCombat = true,
        texture = 4630499,
        
        handler = function ()
        end,
    },
    verdant_embrace = {
        id = 360995,
        cast = 0,
        cooldown = 24,
        gcd = "spell",
        
        spend = 0.03,
        spendType = "mana",
        
        startsCombat = false,
        texture = 4622471,
        
        handler = function ()
        end,
    },
    zephyr = {
        id = 374227,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        
        startsCombat = false,
        texture = 4630449,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Preservation", 20221116,
-- Notes
[[

]],
-- Priority
[[

]] )