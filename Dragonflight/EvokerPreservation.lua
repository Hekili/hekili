-- EvokerPreservation.lua
-- September 2022

if UnitClassBase( 'player' ) ~= 'EVOKER' then return end

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
    aerial_mastery       = { 68659, 365933, 1 },
    ancient_flame        = { 68671, 369990, 1 },
    animosity            = { 68640, 375797, 1 },
    arcane_intensity     = { 68622, 375618, 2 },
    arcane_vigor         = { 68619, 386342, 1 },
    attuned_to_the_dream = { 68672, 376930, 2 },
    azure_essence_burst  = { 68643, 375721, 1 },
    blast_furnace        = { 68667, 375510, 2 },
    bountiful_bloom      = { 68572, 370886, 1 },
    burnout              = { 68633, 375801, 2 },
    cascading_power      = { 68575, 375796, 1 },
    catalyze             = { 68636, 386283, 1 },
    causality            = { 68617, 375777, 1 },
    cauterizing_flame    = { 68673, 374251, 1 },
    charged_blast        = { 68627, 370455, 1 },
    clobbering_sweep     = { 68570, 375443, 1 },
    continuum            = { 68617, 369375, 1 },
    dense_energy         = { 68646, 370962, 1 },
    draconic_legacy      = { 68685, 376166, 2 },
    dragonrage           = { 68641, 375087, 1 },
    engulfing_blaze      = { 68648, 370837, 1 },
    enkindled            = { 68677, 375554, 2 },
    essence_attunement   = { 68625, 375722, 1 },
    eternity_surge       = { 68623, 359073, 1 },
    eternitys_span       = { 68621, 375757, 1 },
    everburning_flame    = { 68615, 370819, 1 },
    expunge              = { 68689, 365585, 1 },
    extended_flight      = { 68679, 375517, 2 },
    exuberance           = { 68573, 375542, 1 },
    feed_the_flames      = { 68615, 369846, 1 },
    fire_within          = { 68654, 375577, 1 },
    firestorm            = { 68635, 368847, 1 },
    fly_with_me          = { 68658, 370665, 1 },
    focusing_iris        = { 68619, 386336, 1 },
    font_of_magic        = { 68632, 375783, 1 },
    forger_of_mountains  = { 68569, 375528, 1 },
    grovetenders_gift    = { 68680, 387761, 1 },
    heat_wave            = { 68637, 375725, 2 },
    heavy_wingbeats      = { 68570, 368838, 1 },
    honed_aggression     = { 68626, 371038, 2 },
    imminent_destruction = { 68631, 370781, 2 },
    imposing_presence    = { 68642, 371016, 1 },
    innate_magic         = { 68683, 375520, 2 },
    inner_radiance       = { 68642, 386405, 1 },
    iridescence          = { 68616, 370867, 1 },
    landslide            = { 68681, 358385, 1 },
    lay_waste            = { 68624, 371034, 2 },
    leaping_flames       = { 68662, 369939, 1 },
    lush_growth          = { 68652, 375561, 2 },
    might_of_the_aspects = { 68639, 386272, 2 },
    natural_convergence  = { 68682, 369913, 1 },
    obsidian_bulwark     = { 68674, 375406, 1 },
    obsidian_scales      = { 68675, 363916, 1 },
    onyx_legacy          = { 68630, 386348, 1 },
    oppressing_roar      = { 68668, 372048, 1 },
    overawe              = { 68660, 374346, 1 },
    permeating_chill     = { 68676, 370897, 1 },
    power_nexus          = { 68574, 369908, 1 },
    power_swell          = { 68620, 370839, 2 },
    protracted_talons    = { 68661, 369909, 1 },
    pyre                 = { 68644, 357211, 1 },
    pyrexia              = { 68654, 375574, 1 },
    quell                = { 68665, 351338, 1 },
    recall               = { 68684, 371806, 1 },
    regenerative_magic   = { 68651, 387787, 1 },
    renewing_blaze       = { 68653, 374348, 1 },
    rescue               = { 68688, 360995, 1 },
    roar_of_exhilaration = { 68664, 375507, 1 },
    ruby_embers          = { 68648, 365937, 1 },
    ruby_essence_burst   = { 68645, 376872, 1 },
    ruin                 = { 68638, 376888, 1 },
    scarlet_adaptation   = { 68687, 372469, 1 },
    scintillation        = { 68629, 370821, 2 },
    shattering_star      = { 68618, 370452, 1 },
    sleep_walk           = { 68571, 360806, 1 },
    snapfire             = { 68634, 370783, 1 },
    source_of_magic      = { 68669, 369459, 1 },
    suffused_with_power  = { 68666, 376164, 2 },
    tailwind             = { 68678, 375556, 1 },
    tempered_scales      = { 68670, 375544, 2 },
    terror_of_the_skies  = { 68649, 371032, 1 },
    time_spiral          = { 68650, 374968, 1 },
    tip_the_scales       = { 68686, 370553, 1 },
    twin_guardian        = { 68656, 370888, 1 },
    tyranny              = { 68628, 370845, 1 },
    unravel              = { 68663, 368432, 1 },
    volatility           = { 68647, 369089, 2 },
    walloping_blow       = { 68657, 387341, 1 },
    zephyr               = { 68655, 374227, 1 },
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    divide_and_conquer = 5472, -- 384689
    unburdened_flight = 5470, -- 378437
    nullifying_shroud = 5468, -- 378464
    youre_coming_with_me = 5465, -- 370388
    time_stop = 5463, -- 378441
    scouring_flame = 5461, -- 378438
    precognition = 5502, -- 377360
    obsidian_mettle = 5459, -- 378444
    chrono_loop = 5455, -- 383005
    dream_projection = 5454, -- 377509
} )

-- Auras
spec:RegisterAuras( {
    deep_breath = {
        id = 357210,
    },
    fire_breath = {
        id = 357208,
    },
    hover = {
        id = 358267,
    },
    sign_of_the_skirmisher = {
        id = 186401,
        duration = 3600,
        max_stack = 1,
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

        startsCombat = true,
        texture = 4622448,

        handler = function ()
        end,
    },


    deep_breath = {
        id = 357210,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        toggle = "cooldowns",

        startsCombat = true,
        texture = 4622450,

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
        end,
    },


    emerald_blossom = {
        id = 355913,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 3,
        spendType = "essence",

        startsCombat = true,
        texture = 4622457,

        handler = function ()
        end,
    },


    fire_breath = {
        id = 357208,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 4622458,

        handler = function ()
        end,
    },


    fury_of_the_aspects = {
        id = 390386,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        toggle = "cooldowns",

        startsCombat = true,
        texture = 4622462,

        handler = function ()
        end,
    },


    hover = {
        id = 358267,
        cast = 0,
        cooldown = 35,
        gcd = "spell",

        startsCombat = true,
        texture = 4622463,

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
        end,
    },


    mass_return = {
        id = 361178,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 4622473,

        handler = function ()
        end,
    },


    naturalize = {
        id = 360823,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 4630445,

        handler = function ()
        end,
    },


    ph_pocopoc_zone_ability_skill = {
        id = 363942,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 4239318,

        handler = function ()
        end,
    },


    ["return"] = {
        id = 361227,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 4622472,

        handler = function ()
        end,

        copy = "action_return"
    },
} )