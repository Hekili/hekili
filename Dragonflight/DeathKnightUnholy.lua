-- DeathKnightUnholy.lua
-- September 2022

if UnitClassBase( "player" ) ~= "DEATHKNIGHT" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 252 )

spec:RegisterResource( Enum.PowerType.Runes )
spec:RegisterResource( Enum.PowerType.RunicPower )

-- Talents
spec:RegisterTalents( {
    abomination_limb         = { 76049, 383269, 1 }, --
    acclimation              = { 76047, 373926, 1 }, --
    all_will_serve           = { 76181, 194916, 1 }, --
    anticipation             = { 76045, 378848, 1 }, --
    antimagic_barrier        = { 76046, 205727, 1 }, --
    antimagic_shell          = { 76070, 48707 , 1 }, --
    antimagic_zone           = { 76065, 51052 , 1 }, --
    apocalypse               = { 76185, 275699, 1 }, --
    army_of_the_damned       = { 76153, 276837, 1 }, --
    army_of_the_dead         = { 76196, 42650 , 1 }, --
    asphyxiate               = { 76064, 221562, 1 }, --
    assimilation             = { 76048, 374383, 1 }, --
    blinding_sleet           = { 76044, 207167, 1 }, --
    blood_draw               = { 76079, 374598, 2 }, --
    blood_scent              = { 76066, 374030, 1 }, --
    brittle                  = { 76061, 374504, 1 }, --
    bursting_sores           = { 76164, 207264, 1 }, --
    chains_of_ice            = { 76081, 45524 , 1 }, --
    clawing_shadows          = { 76183, 207311, 1 }, --
    cleaving_strikes         = { 76073, 316916, 1 }, --
    clenching_grasp          = { 76062, 389679, 1 }, --
    coil_of_devastation      = { 76156, 390270, 1 }, --
    commander_of_the_dead    = { 76149, 390259, 1 }, --
    control_undead           = { 76059, 111673, 1 }, --
    dark_transformation      = { 76187, 63560 , 1 }, --
    death_pact               = { 76077, 48743 , 1 }, --
    death_rot                = { 76158, 377537, 1 }, --
    death_strike             = { 76071, 49998 , 1 }, --
    deaths_echo              = { 76056, 356367, 1 }, --
    deaths_reach             = { 76057, 276079, 1 }, --
    defile                   = { 76180, 152280, 1 }, --
    ebon_fever               = { 76164, 207269, 1 }, --
    empower_rune_weapon      = { 76050, 47568 , 1 }, --
    enfeeble                 = { 76060, 392566, 1 }, --
    epidemic                 = { 76161, 207317, 1 }, --
    eternal_agony            = { 76195, 390268, 1 }, --
    feasting_strikes         = { 76193, 390161, 1 }, --
    festering_strike         = { 76189, 85948 , 1 }, --
    festering_strike_2       = { 76192, 316867, 2 }, --
    festermight              = { 76152, 377590, 2 }, --
    ghoulish_frenzy          = { 76154, 377587, 2 }, --
    gloom_ward               = { 76052, 391571, 1 }, --
    grip_of_the_dead         = { 76057, 273952, 1 }, --
    harbinger_of_doom        = { 76175, 276023, 1 }, --
    icebound_fortitude       = { 76084, 48792 , 1 }, --
    icy_talons               = { 76051, 194878, 2 }, --
    improved_death_coil      = { 76184, 377580, 2 }, --
    improved_death_strike    = { 76067, 374277, 1 }, --
    infected_claws           = { 76182, 207272, 1 }, --
    insidious_chill          = { 76088, 391566, 1 }, --
    magus_of_the_dead        = { 76148, 390196, 1 }, --
    march_of_darkness        = { 76069, 391546, 1 }, --
    merciless_strikes        = { 76085, 373923, 1 }, --
    might_of_thassarian      = { 76076, 374111, 1 }, --
    mind_freeze              = { 76082, 47528 , 1 }, --
    morbidity                = { 76197, 377592, 2 }, --
    outbreak                 = { 76191, 77575 , 1 }, --
    permafrost               = { 76083, 207200, 1 }, --
    pestilence               = { 76157, 277234, 1 }, --
    pestilent_pustules       = { 76160, 194917, 1 }, --
    plaguebearer             = { 76159, 390279, 1 }, --
    plaguebringer            = { 76183, 390175, 1 }, --
    proliferating_chill      = { 76086, 373930, 1 }, --
    raise_dead               = { 76188, 46584 , 1 }, --
    raise_dead_2             = { 76072, 46585 , 1 }, --
    reaping                  = { 76177, 377514, 1 }, --
    replenishing_wounds      = { 76163, 377585, 1 }, --
    rotten_touch             = { 76178, 390275, 1 }, --
    rune_mastery             = { 76080, 374574, 2 }, --
    runic_attenuation        = { 76087, 207104, 1 }, --
    runic_mastery            = { 76186, 390166, 2 }, --
    ruptured_viscera         = { 76148, 390236, 1 }, --
    sacrificial_pact         = { 76074, 327574, 1 }, --
    scourge_strike           = { 76190, 55090 , 1 }, --
    soul_reaper              = { 76053, 343294, 1 }, --
    sudden_doom              = { 76179, 49530 , 1 }, --
    summon_gargoyle          = { 76176, 49206 , 1 }, --
    superstrain              = { 76155, 390283, 1 }, --
    suppression              = { 76075, 374049, 1 }, --
    unholy_assault           = { 76151, 207289, 1 }, --
    unholy_aura              = { 76150, 377440, 2 }, --
    unholy_blight            = { 76162, 115989, 1 }, --
    unholy_bond              = { 76055, 374261, 2 }, --
    unholy_command           = { 76194, 316941, 2 }, --
    unholy_endurance         = { 76063, 389682, 1 }, --
    unholy_ground            = { 76058, 374265, 1 }, --
    unholy_pact              = { 76180, 319230, 1 }, --
    veteran_of_the_third_war = { 76068, 48263 , 2 }, --
    will_of_the_necropolis   = { 76054, 206967, 2 }, --
    wraith_walk              = { 76078, 212552, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    dark_simulacrum      = 41  , -- 77606
    doomburst            = 5436, -- 356512
    life_and_death       = 40  , -- 288855
    necromancers_bargain = 3746, -- 288848
    necrotic_aura        = 3437, -- 199642
    necrotic_wounds      = 149 , -- 356520
    raise_abomination    = 3747, -- 288853
    reanimation          = 152 , -- 210128
    rot_and_wither       = 5511, -- 202727
    spellwarden          = 5423, -- 356332
    strangulate          = 5430, -- 47476
} )


-- Auras
spec:RegisterAuras( {
    abomination_limb = {
        id = 383269,
        duration = 12,
        tick_time = 1,
        max_stack = 1
    },
    abomination_limb_immune = {
        id = 383312,
        duration = 4,
        max_stack = 1
    },
    antimagic_shell = {
        id = 48707,
        duration = 5,
        max_stack = 1
    },
    antimagic_zone = { -- TODO: Modify expiration based on last cast.
        id = 145629,
        duration = 8,
        max_stack = 1
    },
    army_of_the_dead = {
        id = 42650,
        duration = 4,
        tick_time = 0.5,
        max_stack = 1
    },
    asphyxiate = {
        id = 221562,
        duration = 5,
        max_stack = 1
    },
    blinding_sleet = {
        id = 207167,
        duration = 5,
        max_stack = 1
    },
    blood_draw = {
        id = 374609,
        duration = 180,
        max_stack = 1
    },
    blood_plague = {
        id = 55078,
        duration = 24,
        tick_time = 3,
        max_stack = 1
    },
    blooddrinker = {
        id = 206931,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    bonestorm = {
        id = 194844,
        duration = 1,
        tick_time = 1,
        max_stack = 1
    },
    chains_of_ice = {
        id = 45524,
        duration = 8,
        max_stack = 1
    },
    control_undead = {
        id = 111673,
        duration = 300,
        max_stack = 1
    },
    dancing_rune_weapon = {
        id = 81256,
        duration = 8,
        max_stack = 1
    },
    dark_command = {
        id = 56222,
        duration = 3,
        max_stack = 1
    },
    dark_simulacrum = {
        id = 77606,
        duration = 12,
        max_stack = 1
    },
    dark_succor = {
        id = 101568,
        duration = 20,
        max_stack = 1
    },
    dark_transformation = {
        id = 63560,
        duration = 15,
        max_stack = 1
    },
    death_and_decay = { -- TODO: Double-check aura ID.
        id = 188290,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    death_pact = {
        id = 48743,
        duration = 15,
        max_stack = 1
    },
    deaths_advance = {
        id = 48265,
        duration = 10,
        max_stack = 1
    },
    defile = {
        id = 152280,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    empower_rune_weapon = {
        id = 47568,
        duration = 20,
        tick_time = 5,
        max_stack = 1
    },
    heart_strike = {  -- Snare.
        id = 206930,
        duration = 8,
        max_stack = 1
    },
    icebound_fortitude = {
        id = 48792,
        duration = 8,
        max_stack = 1
    },
    icy_talons = {
        id = 194879,
        duration = 6,
        max_stack = 3
    },
    insidious_chill = {
        id = 391568,
        duration = 30,
        max_stack = 4
    },
    lichborne = {
        id = 49039,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    march_of_darkness = {
        id = 391547,
        duration = 3,
        max_stack = 1
    },
    mark_of_blood = {
        id = 206940,
        duration = 15,
        max_stack = 1
    },
    path_of_frost = {
        id = 3714,
        duration = 600,
        tick_time = 0.5,
        max_stack = 1
    },
    plaguebringer = {
        id = 390178,
        duration = 5,
        max_stack = 1
    },
    raise_abomination = { -- TODO: Is a totem.
        id = 288853,
        duration = 25,
        max_stack = 1
    },
    raise_dead = { -- TODO: Is a pet.
        id = 46585,
        duration = 60,
        max_stack = 1
    },
    reanimation = { -- TODO: Summons a zombie (totem?).
        id = 210128,
        duration = 20,
        max_stack = 1
    },
    rune_tap = {
        id = 194679,
        duration = 4,
        max_stack = 1
    },
    soul_reaper = {
        id = 343294,
        duration = 5,
        tick_time = 5,
        max_stack = 1
    },
    strangulate = {
        id = 47476,
        duration = 4,
        max_stack = 1
    },
    sudden_doom = {
        id = 81340,
        duration = 10,
        max_stack = 1
    },
    summon_gargoyle = { -- TODO: Is a totem?
        id = 49206,
        duration = 25,
        max_stack = 1
    },
    summon_gargoyle_buff = { -- TODO: Buff on the gargoyle? Or on the player?
        id = 61777,
        duration = 25,
        max_stack = 1
    },
    tombstone = {
        id = 219809,
        duration = 8,
        max_stack = 1
    },
    unholy_assault = {
        id = 207289,
        duration = 20,
        max_stack = 1
    },
    unholy_blight_buff = {
        id = 115989,
        duration = 6,
        tick_time = 1,
        max_stack = 1,
        dot = "buff"
    },
    unholy_blight = {
        id = 115994,
        duration = 14,
        tick_time = 2,
        max_stack = 4,
        copy = { "unholy_blight_debuff", "unholy_blight_dot" }
    },
    unholy_pact = {
        id = 319255,
        duration = 15,
        max_stack = 1
    },
    vampiric_blood = {
        id = 55233,
        duration = 10,
        max_stack = 1
    },
    virulent_plague = {
        id = 191587,
        duration = 27,
        tick_time = 3,
        max_stack = 1
    },
    voidtouched = {
        id = 97821,
        duration = 300,
        max_stack = 1
    },
    wraith_walk = {
        id = 212552,
        duration = 4,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    abomination_limb = {
        id = 383269,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "abomination_limb",
        startsCombat = false,
        texture = 3578196,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    antimagic_shell = {
        id = 48707,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "antimagic_shell",
        startsCombat = false,
        texture = 136120,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    antimagic_zone = {
        id = 51052,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "antimagic_zone",
        startsCombat = false,
        texture = 237510,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    apocalypse = {
        id = 275699,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "apocalypse",
        startsCombat = false,
        texture = 1392565,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    army_of_the_dead = {
        id = 42650,
        cast = 0,
        cooldown = 480,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        talent = "army_of_the_dead",
        startsCombat = false,
        texture = 237511,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    asphyxiate = {
        id = 221562,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "asphyxiate",
        startsCombat = false,
        texture = 538558,

        handler = function ()
        end,
    },


    blinding_sleet = {
        id = 207167,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "blinding_sleet",
        startsCombat = false,
        texture = 135836,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    blood_boil = {
        id = 50842,
        cast = 0,
        charges = 2,
        cooldown = 7.5,
        recharge = 7.5,
        gcd = "spell",

        talent = "blood_boil",
        startsCombat = false,
        texture = 237513,

        handler = function ()
        end,
    },


    blood_tap = {
        id = 221699,
        cast = 0,
        charges = 2,
        cooldown = 60,
        recharge = 60,
        gcd = "off",

        talent = "blood_tap",
        startsCombat = false,
        texture = 237515,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    blooddrinker = {
        id = 206931,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        talent = "blooddrinker",
        startsCombat = false,
        texture = 838812,

        handler = function ()
        end,
    },


    bonestorm = {
        id = 194844,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 100,
        spendType = "runic_power",

        talent = "bonestorm",
        startsCombat = false,
        texture = 342917,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    chains_of_ice = {
        id = 45524,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        talent = "chains_of_ice",
        startsCombat = false,
        texture = 135834,

        handler = function ()
        end,
    },


    clawing_shadows = {
        id = 207311,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "clawing_shadows",
        startsCombat = false,
        texture = 615099,

        handler = function ()
        end,
    },


    consumption = {
        id = 274156,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "consumption",
        startsCombat = false,
        texture = 1121487,

        handler = function ()
        end,
    },


    control_undead = {
        id = 111673,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        talent = "control_undead",
        startsCombat = false,
        texture = 237273,

        handler = function ()
        end,
    },


    dancing_rune_weapon = {
        id = 49028,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "dancing_rune_weapon",
        startsCombat = false,
        texture = 135277,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dark_command = {
        id = 56222,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 136088,

        handler = function ()
        end,
    },


    dark_simulacrum = {
        id = 77606,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        pvptalent = "dark_simulacrum",
        startsCombat = false,
        texture = 135888,

        handler = function ()
        end,
    },


    dark_transformation = {
        id = 63560,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "dark_transformation",
        startsCombat = false,
        texture = 342913,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    death_and_decay = {
        id = 43265,
        cast = 0,
        charges = 1,
        cooldown = 30,
        recharge = 30,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,
        texture = 136144,

        handler = function ()
        end,
    },


    death_coil = {
        id = 47541,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        startsCombat = true,
        texture = 136145,

        handler = function ()
        end,
    },


    death_gate = {
        id = 50977,
        cast = 4,
        cooldown = 60,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = false,
        texture = 135766,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    death_grip = {
        id = 49576,
        cast = 0,
        charges = 1,
        cooldown = 25,
        recharge = 25,
        gcd = "off",
        icd = 0.5,

        startsCombat = true,
        texture = 237532,

        handler = function ()
        end,
    },


    death_pact = {
        id = 48743,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "death_pact",
        startsCombat = false,
        texture = 136146,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    death_strike = {
        id = 49998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 45,
        spendType = "runic_power",

        talent = "death_strike",
        startsCombat = false,
        texture = 237517,

        handler = function ()
        end,
    },


    deaths_advance = {
        id = 48265,
        cast = 0,
        charges = 1,
        cooldown = 45,
        recharge = 45,
        gcd = "off",

        startsCombat = false,
        texture = 237561,

        handler = function ()
        end,
    },


    deaths_caress = {
        id = 195292,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        talent = "deaths_caress",
        startsCombat = false,
        texture = 1376743,

        handler = function ()
        end,
    },


    defile = {
        id = 152280,
        cast = 0,
        charges = 1,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "defile",
        startsCombat = false,
        texture = 1029008,

        handler = function ()
        end,
    },


    empower_rune_weapon = {
        id = 47568,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "empower_rune_weapon",
        startsCombat = false,
        texture = 135372,

        handler = function ()
        end,
    },


    epidemic = {
        id = 207317,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        talent = "epidemic",
        startsCombat = false,
        texture = 136066,

        handler = function ()
        end,
    },


    festering_strike = {
        id = 85948,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 2,
        spendType = "runes",

        talent = "festering_strike",
        startsCombat = false,
        texture = 879926,

        handler = function ()
        end,
    },


    gorefiends_grasp = {
        id = 108199,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "gorefiends_grasp",
        startsCombat = false,
        texture = 538767,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    heart_strike = {
        id = 206930,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "health",

        talent = "heart_strike",
        startsCombat = false,
        texture = 135675,

        handler = function ()
        end,
    },


    icebound_fortitude = {
        id = 48792,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "icebound_fortitude",
        startsCombat = false,
        texture = 237525,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    lichborne = {
        id = 49039,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 136187,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    mark_of_blood = {
        id = 206940,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        talent = "mark_of_blood",
        startsCombat = false,
        texture = 132205,

        handler = function ()
        end,
    },


    marrowrend = {
        id = 195182,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 2,
        spendType = "runes",

        talent = "marrowrend",
        startsCombat = false,
        texture = 1376745,

        handler = function ()
        end,
    },


    mind_freeze = {
        id = 47528,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        spend = 0,
        spendType = "runic_power",

        talent = "mind_freeze",
        startsCombat = false,
        texture = 237527,

        handler = function ()
        end,
    },


    outbreak = {
        id = 77575,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "outbreak",
        startsCombat = false,
        texture = 348565,

        handler = function ()
        end,
    },


    path_of_frost = {
        id = 3714,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = false,
        texture = 237528,

        handler = function ()
        end,
    },


    plaguebearer = {
        id = 390279,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        talent = "plaguebearer",
        startsCombat = false,
        texture = 136182,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    raise_abomination = {
        id = 288853,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        pvptalent = "raise_abomination",
        startsCombat = false,
        texture = 298667,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    raise_ally = {
        id = 61999,
        cast = 0,
        cooldown = 600,
        gcd = "spell",

        spend = 30,
        spendType = "runic_power",

        startsCombat = true,
        texture = 136143,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    raise_dead = {
        id = 46585,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "raise_dead",
        startsCombat = true,
        texture = 1100170,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    reanimation = {
        id = 210128,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        pvptalent = "reanimation",
        startsCombat = false,
        texture = 1390947,

        handler = function ()
        end,
    },


    rune_strike = {
        id = 316239,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        startsCombat = true,
        texture = 237518,

        handler = function ()
        end,
    },


    rune_tap = {
        id = 194679,
        cast = 0,
        charges = 2,
        cooldown = 25,
        recharge = 25,
        gcd = "off",

        spend = 1,
        spendType = "runes",

        talent = "rune_tap",
        startsCombat = false,
        texture = 237529,

        handler = function ()
        end,
    },


    runeforging = {
        id = 53428,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        startsCombat = false,
        texture = 237523,

        handler = function ()
        end,
    },


    sacrificial_pact = {
        id = 327574,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 20,
        spendType = "runic_power",

        talent = "sacrificial_pact",
        startsCombat = false,
        texture = 136133,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    scourge_strike = {
        id = 55090,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "scourge_strike",
        startsCombat = false,
        texture = 237530,

        handler = function ()
        end,
    },


    soul_reaper = {
        id = 343294,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 1,
        spendType = "runes",

        talent = "soul_reaper",
        startsCombat = false,
        texture = 636333,

        handler = function ()
        end,
    },


    strangulate = {
        id = 47476,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0,
        spendType = "runes",

        pvptalent = "strangulate",
        startsCombat = false,
        texture = 136214,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    summon_gargoyle = {
        id = 49206,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "summon_gargoyle",
        startsCombat = false,
        texture = 458967,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    tombstone = {
        id = 219809,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "tombstone",
        startsCombat = false,
        texture = 132151,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    unholy_assault = {
        id = 207289,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "unholy_assault",
        startsCombat = false,
        texture = 136224,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    unholy_blight = {
        id = 115989,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = -10,
        spendType = "runic_power",

        talent = "unholy_blight",
        startsCombat = false,
        texture = 136132,

        handler = function ()
        end,
    },


    vampiric_blood = {
        id = 55233,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "vampiric_blood",
        startsCombat = false,
        texture = 136168,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    wraith_walk = {
        id = 212552,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "wraith_walk",
        startsCombat = false,
        texture = 1100041,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Unholy", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )