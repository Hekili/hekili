-- HunterBeast Mastery.lua
-- September 2022

if UnitClassBase( "player" ) ~= "HUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 253 )

spec:RegisterResource( Enum.PowerType.Focus )

-- Talents
spec:RegisterTalents( {
    a_murder_of_crows              = { 79943, 131894, 1 }, --
    agile_movement                 = { 79918, 378002, 2 }, --
    alpha_predator                 = { 79904, 269737, 1 }, --
    animal_companion               = { 79947, 267116, 1 }, --
    arctic_bola                    = { 79815, 390231, 2 }, --
    aspect_of_the_beast            = { 79944, 191384, 1 }, --
    aspect_of_the_wild             = { 79950, 193530, 1 }, --
    barbed_shot                    = { 79968, 217200, 1 }, --
    barbed_wrath                   = { 79822, 231548, 1 }, --
    barrage                        = { 79914, 120360, 1 }, --
    beast_cleave                   = { 79956, 115939, 2 }, --
    beast_master                   = { 79926, 378007, 2 }, --
    bestial_wrath                  = { 79955, 19574 , 1 }, --
    binding_shackles               = { 79920, 321468, 1 }, --
    binding_shot                   = { 79937, 109248, 1 }, --
    bloodshed                      = { 79943, 321530, 1 }, --
    bloody_frenzy                  = { 79946, 378739, 1 }, --
    born_to_be_wild                = { 79933, 266921, 2 }, --
    brutal_companion               = { 79816, 386870, 1 }, --
    call_of_the_wild               = { 79967, 359844, 1 }, --
    camouflage                     = { 79934, 199483, 1 }, --
    cobra_senses                   = { 79963, 378244, 1 }, --
    cobra_shot                     = { 79949, 193455, 1 }, --
    concussive_shot                = { 79906, 5116  , 1 }, --
    counter_shot                   = { 79912, 147362, 1 }, --
    death_chakram                  = { 79916, 375891, 1 }, --
    dire_beast                     = { 79959, 120679, 1 }, --
    dire_command                   = { 79953, 378743, 3 }, --
    dire_frenzy                    = { 79823, 385810, 2 }, --
    dire_pack                      = { 79940, 378745, 1 }, --
    explosive_shot                 = { 79914, 212431, 1 }, --
    flamewakers_cobra_sting        = { 79941, 378750, 2 }, --
    hiexplosive_trap               = { 79910, 236776, 1 }, --
    hunters_agility                = { 79832, 384799, 1 }, --
    hydras_bite                    = { 79911, 260241, 1 }, --
    improved_kill_command          = { 79932, 378010, 2 }, --
    improved_kill_shot             = { 79930, 343248, 1 }, --
    improved_mend_pet              = { 79936, 343242, 2 }, --
    improved_tranquilizing_shot    = { 79919, 343244, 1 }, --
    improved_traps                 = { 79923, 343247, 2 }, --
    in_for_the_kill                = { 79951, 378210, 1 }, --
    intimidation                   = { 79910, 19577 , 1 }, --
    keen_eyesight                  = { 79922, 378004, 2 }, --
    kill_cleave                    = { 79954, 378207, 1 }, --
    kill_command                   = { 79935, 34026 , 1 }, --
    kill_shot                      = { 79835, 53351 , 1 }, --
    killer_cobra                   = { 79961, 199532, 1 }, --
    killer_command                 = { 79939, 378740, 2 }, --
    killer_instinct                = { 79904, 273887, 1 }, --
    kindred_spirits                = { 79957, 56315 , 2 }, --
    latent_poison_injectors        = { 79911, 378014, 1 }, --
    lone_survivor                  = { 79820, 388039, 1 }, --
    master_handler                 = { 79962, 389654, 1 }, --
    master_marksman                = { 79913, 260309, 2 }, --
    misdirection                   = { 79924, 34477 , 1 }, --
    multishot                      = { 79917, 2643  , 1 }, --
    natural_mending                = { 79925, 270581, 2 }, --
    natures_endurance              = { 79820, 388042, 1 }, --
    nesingwarys_trapping_apparatus = { 79929, 378759, 2 }, --
    one_with_the_pack              = { 79960, 199528, 2 }, --
    pack_tactics                   = { 79958, 321014, 1 }, --
    posthaste                      = { 79921, 109215, 2 }, --
    qapla_eredun_war_order         = { 79952, 336830, 2 }, --
    rejuvenating_wind              = { 79909, 385539, 2 }, --
    rylakstalkers_piercing_fangs   = { 79961, 392053, 1 }, --
    scare_beast                    = { 79927, 1513  , 1 }, --
    scatter_shot                   = { 79937, 213691, 1 }, --
    scent_of_blood                 = { 79965, 193532, 2 }, --
    sentinel_nyi                   = { 79819, 388045, 1 }, --
    sentinels_perception_nyi       = { 79818, 388056, 1 }, --
    sentinels_wisdom_nyi           = { 79818, 388057, 1 }, --
    serpent_sting                  = { 79905, 271788, 1 }, --
    serrated_shots                 = { 79814, 389882, 2 }, --
    sharp_barbs                    = { 79945, 378205, 2 }, --
    snake_bite                     = { 79962, 389660, 1 }, --
    stampede                       = { 79916, 201430, 1 }, --
    steel_trap                     = { 79908, 162488, 1 }, --
    stomp                          = { 79942, 199530, 2 }, --
    survival_of_the_fittest        = { 79821, 264735, 1 }, --
    tar_trap                       = { 79928, 187698, 1 }, --
    thrill_of_the_hunt             = { 79964, 257944, 3 }, --
    trailblazer                    = { 79931, 199921, 2 }, --
    training_expert                = { 79948, 378209, 2 }, --
    tranquilizing_shot             = { 79907, 19801 , 1 }, --
    wailing_arrow                  = { 79938, 392060, 1 }, --
    wild_call                      = { 79966, 185789, 1 }, --
    wild_instincts                 = { 79946, 378442, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting     = 3604, -- 356719
    diamond_ice         = 5534, -- 203340
    dire_beast_basilisk = 825 , -- 205691
    dire_beast_hawk     = 824 , -- 208652
    dragonscale_armor   = 3600, -- 202589
    hunting_pack        = 3730, -- 203235
    interlope           = 1214, -- 248518
    kindred_beasts      = 5444, -- 356962
    roar_of_sacrifice   = 3612, -- 53480
    survival_tactics    = 3599, -- 202746
    the_beast_within    = 693 , -- 356976
    tranquilizing_darts = 5418, -- 356015
    wild_kingdom        = 5441, -- 356707
} )


-- Auras
spec:RegisterAuras( {
    aspect_of_the_cheetah = {
        id = 186257,
    },
    aspect_of_the_turtle = {
        id = 186265,
    },
    aspect_of_the_wild = {
        id = 193530,
    },
    barrage = {
        id = 120360,
    },
    bestial_wrath = {
        id = 19574,
    },
    call_of_the_wild = {
        id = 359844,
    },
    eagle_eye = {
        id = 6197,
    },
    exotic_beasts = {
        id = 53270,
    },
    feign_death = {
        id = 5384,
    },
    interlope = {
        id = 248518,
    },
    mastery_master_of_beasts = {
        id = 76657,
    },
    predators_thirst = {
        id = 264663,
        duration = 3600,
        max_stack = 1,
    },
    sentinel_nyi = {
        id = 388045,
    },
    sign_of_the_emissary = {
        id = 225788,
        duration = 3600,
        max_stack = 1,
    },
    stampede = {
        id = 201430,
    },
    wild_kingdom = {
        id = 356707,
    },
} )


-- Abilities
spec:RegisterAbilities( {
    a_murder_of_crows = {
        id = 131894,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 30,
        spendType = "focus",

        talent = "a_murder_of_crows",
        startsCombat = false,
        texture = 645217,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    arcane_shot = {
        id = 185358,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 40,
        spendType = "focus",

        startsCombat = true,
        texture = 132218,

        handler = function ()
        end,
    },


    aspect_of_the_cheetah = {
        id = 186257,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        startsCombat = false,
        texture = 132242,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    aspect_of_the_turtle = {
        id = 186265,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        startsCombat = false,
        texture = 132199,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    aspect_of_the_wild = {
        id = 193530,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "aspect_of_the_wild",
        startsCombat = false,
        texture = 136074,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    barbed_shot = {
        id = 217200,
        cast = 0,
        charges = 2,
        cooldown = 12,
        recharge = 12,
        gcd = "spell",

        talent = "barbed_shot",
        startsCombat = false,
        texture = 2058007,

        handler = function ()
        end,
    },


    barrage = {
        id = 120360,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 60,
        spendType = "focus",

        talent = "barrage",
        startsCombat = false,
        texture = 236201,

        handler = function ()
        end,
    },


    bestial_wrath = {
        id = 19574,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "bestial_wrath",
        startsCombat = false,
        texture = 132127,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    binding_shot = {
        id = 109248,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "binding_shot",
        startsCombat = false,
        texture = 462650,

        handler = function ()
        end,
    },


    bloodshed = {
        id = 321530,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "bloodshed",
        startsCombat = false,
        texture = 132139,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    call_of_the_wild = {
        id = 359844,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "call_of_the_wild",
        startsCombat = false,
        texture = 4667415,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    camouflage = {
        id = 199483,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "camouflage",
        startsCombat = false,
        texture = 461113,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    chimaeral_sting = {
        id = 356719,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "chimaeral_sting",
        startsCombat = false,
        texture = 132211,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    cobra_shot = {
        id = 193455,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 35,
        spendType = "focus",

        talent = "cobra_shot",
        startsCombat = false,
        texture = 461114,

        handler = function ()
        end,
    },


    command_pet = {
        id = 272651,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        startsCombat = false,
        texture = 457329,

        handler = function ()
        end,
    },


    concussive_shot = {
        id = 5116,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        talent = "concussive_shot",
        startsCombat = false,
        texture = 135860,

        handler = function ()
        end,
    },


    counter_shot = {
        id = 147362,
        cast = 0,
        cooldown = 24,
        gcd = "off",

        talent = "counter_shot",
        startsCombat = false,
        texture = 249170,

        handler = function ()
        end,
    },


    death_chakram = {
        id = 375891,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "death_chakram",
        startsCombat = false,
        texture = 3578207,

        handler = function ()
        end,
    },


    dire_beast = {
        id = 120679,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        talent = "dire_beast",
        startsCombat = false,
        texture = 236186,

        handler = function ()
        end,
    },


    dire_beast_basilisk = {
        id = 205691,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 60,
        spendType = "focus",

        pvptalent = "dire_beast_basilisk",
        startsCombat = false,
        texture = 1412204,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dire_beast_hawk = {
        id = 208652,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 30,
        spendType = "focus",

        pvptalent = "dire_beast_hawk",
        startsCombat = false,
        texture = 612363,

        handler = function ()
        end,
    },


    disengage = {
        id = 781,
        cast = 0,
        charges = 1,
        cooldown = 21.99,
        recharge = 21.99,
        gcd = "off",

        startsCombat = false,
        texture = 132294,

        handler = function ()
        end,
    },


    eagle_eye = {
        id = 6197,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132172,

        handler = function ()
        end,
    },


    exhilaration = {
        id = 109304,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 461117,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    explosive_shot = {
        id = 212431,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 20,
        spendType = "focus",

        talent = "explosive_shot",
        startsCombat = false,
        texture = 236178,

        handler = function ()
        end,
    },


    eyes_of_the_beast = {
        id = 321297,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132150,

        handler = function ()
        end,
    },


    feign_death = {
        id = 5384,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 132293,

        handler = function ()
        end,
    },


    flare = {
        id = 1543,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        startsCombat = true,
        texture = 135815,

        handler = function ()
        end,
    },


    freezing_trap = {
        id = 187650,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        startsCombat = true,
        texture = 135834,

        handler = function ()
        end,
    },


    hiexplosive_trap = {
        id = 236776,
        cast = 0,
        cooldown = 40,
        gcd = "spell",

        talent = "hiexplosive_trap",
        startsCombat = false,
        texture = 135826,

        handler = function ()
        end,
    },


    hunters_mark = {
        id = 257284,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        startsCombat = true,
        texture = 236188,

        handler = function ()
        end,
    },


    interlope = {
        id = 248518,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        pvptalent = "interlope",
        startsCombat = false,
        texture = 132180,

        handler = function ()
        end,
    },


    intimidation = {
        id = 19577,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "intimidation",
        startsCombat = false,
        texture = 132111,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    kill_command = {
        id = 34026,
        cast = 0,
        charges = 1,
        cooldown = 7.5,
        recharge = 7.5,
        gcd = "spell",

        spend = 30,
        spendType = "focus",

        talent = "kill_command",
        startsCombat = true,
        texture = 132176,

        handler = function ()
        end,
    },


    kill_shot = {
        id = 53351,
        cast = 0,
        charges = 1,
        cooldown = 11,
        recharge = 11,
        gcd = "spell",

        spend = 10,
        spendType = "focus",

        talent = "kill_shot",
        startsCombat = false,
        texture = 236174,

        handler = function ()
        end,
    },


    misdirection = {
        id = 34477,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        talent = "misdirection",
        startsCombat = false,
        texture = 132180,

        handler = function ()
        end,
    },


    multishot = {
        id = 2643,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 40,
        spendType = "focus",

        talent = "multishot",
        startsCombat = false,
        texture = 132330,

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


    roar_of_sacrifice = {
        id = 53480,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        pvptalent = "roar_of_sacrifice",
        startsCombat = false,
        texture = 464604,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    scare_beast = {
        id = 1513,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 25,
        spendType = "focus",

        talent = "scare_beast",
        startsCombat = false,
        texture = 132118,

        handler = function ()
        end,
    },


    scatter_shot = {
        id = 213691,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "scatter_shot",
        startsCombat = false,
        texture = 132153,

        handler = function ()
        end,
    },


    sentinel_nyi = {
        id = 388045,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "sentinel_nyi",
        startsCombat = false,
        texture = 4067367,

        handler = function ()
        end,
    },


    serpent_sting = {
        id = 271788,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 10,
        spendType = "focus",

        talent = "serpent_sting",
        startsCombat = false,
        texture = 1033905,

        handler = function ()
        end,
    },


    stampede = {
        id = 201430,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "stampede",
        startsCombat = false,
        texture = 461112,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    steady_shot = {
        id = 56641,
        cast = 1.75,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132213,

        handler = function ()
        end,
    },


    steel_trap = {
        id = 162488,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "steel_trap",
        startsCombat = false,
        texture = 1467588,

        handler = function ()
        end,
    },


    survival_of_the_fittest = {
        id = 264735,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "survival_of_the_fittest",
        startsCombat = false,
        texture = 136094,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    tame_beast = {
        id = 1515,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132164,

        handler = function ()
        end,
    },


    tar_trap = {
        id = 187698,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "tar_trap",
        startsCombat = false,
        texture = 576309,

        handler = function ()
        end,
    },


    tranquilizing_shot = {
        id = 19801,
        cast = 0,
        cooldown = 10,
        gcd = "totem",

        talent = "tranquilizing_shot",
        startsCombat = false,
        texture = 136020,

        handler = function ()
        end,
    },


    wailing_arrow = {
        id = 392060,
        cast = 2,
        cooldown = 60,
        gcd = "spell",

        spend = 15,
        spendType = "focus",

        talent = "wailing_arrow",
        startsCombat = false,
        texture = 132323,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    wild_kingdom = {
        id = 356707,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "wild_kingdom",
        startsCombat = false,
        texture = 236159,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    wing_clip = {
        id = 195645,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 20,
        spendType = "focus",

        startsCombat = true,
        texture = 132309,

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Beast Mastery", 20220917,
-- Notes
[[

]],
-- Priority
[[

]] )