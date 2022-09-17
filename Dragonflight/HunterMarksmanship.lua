-- HunterMarksmanship.lua
-- September 2022

if UnitClassBase( "player" ) ~= "HUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 254 )

spec:RegisterResource( Enum.PowerType.Focus )

-- Talents
spec:RegisterTalents( {
    agile_movement                 = { 79918, 378002, 2 }, --
    aimed_shot                     = { 79873, 19434 , 1 }, --
    alpha_predator                 = { 79904, 269737, 1 }, --
    arctic_bola                    = { 79815, 390231, 2 }, --
    barrage                        = { 79914, 120360, 1 }, --
    beast_master                   = { 79926, 378007, 2 }, --
    binding_shackles               = { 79920, 321468, 1 }, --
    binding_shot                   = { 79937, 109248, 1 }, --
    bombardment                    = { 79889, 378880, 1 }, --
    born_to_be_wild                = { 79933, 266921, 2 }, --
    bulletstorm                    = { 79817, 389019, 1 }, --
    bullseye                       = { 79876, 204089, 2 }, --
    bursting_shot                  = { 79872, 186387, 1 }, --
    calling_the_shots              = { 79902, 260404, 1 }, --
    camouflage                     = { 79934, 199483, 1 }, --
    careful_aim                    = { 79879, 260228, 2 }, --
    chimaera_shot                  = { 79915, 342049, 1 }, --
    concussive_shot                = { 79906, 5116  , 1 }, --
    counter_shot                   = { 79836, 147362, 1 }, --
    crack_shot                     = { 79895, 321293, 1 }, --
    dead_eye                       = { 79892, 321460, 1 }, --
    death_chakram                  = { 79916, 375891, 1 }, --
    deathblow                      = { 79883, 378769, 1 }, --
    double_tap                     = { 79874, 260402, 1 }, --
    eagletalons_true_focus         = { 79901, 389449, 2 }, --
    explosive_shot                 = { 79914, 212431, 1 }, --
    focused_aim                    = { 79896, 378767, 2 }, --
    heavy_ammo                     = { 79903, 378910, 1 }, --
    hiexplosive_trap               = { 79910, 236776, 1 }, --
    hunters_agility                = { 79832, 384799, 1 }, --
    hunters_knowledge              = { 79888, 378766, 2 }, --
    hydras_bite                    = { 79911, 260241, 1 }, --
    improved_kill_command          = { 79932, 378010, 2 }, --
    improved_kill_shot             = { 79930, 343248, 1 }, --
    improved_mend_pet              = { 79936, 343242, 2 }, --
    improved_steady_shot           = { 79898, 321018, 1 }, --
    improved_tranquilizing_shot    = { 79919, 343244, 1 }, --
    improved_traps                 = { 79923, 343247, 2 }, --
    intimidation                   = { 79910, 19577 , 1 }, --
    keen_eyesight                  = { 79922, 378004, 2 }, --
    kill_command                   = { 79838, 34026 , 1 }, --
    kill_shot                      = { 79834, 53351 , 1 }, --
    killer_instinct                = { 79904, 273887, 1 }, --
    killing_blow                   = { 79900, 378765, 2 }, --
    latent_poison_injectors        = { 79911, 378014, 1 }, --
    legacy_of_the_windrunners      = { 79899, 190852, 2 }, --
    lethal_shots                   = { 79897, 260393, 1 }, --
    light_ammo                     = { 79903, 378913, 1 }, --
    lock_and_load                  = { 79884, 194595, 1 }, --
    lone_survivor                  = { 79820, 388039, 1 }, --
    lone_wolf                      = { 79871, 155228, 1 }, --
    master_marksman                = { 79913, 260309, 2 }, --
    misdirection                   = { 79924, 34477 , 1 }, --
    multishot                      = { 79840, 257620, 1 }, --
    natural_mending                = { 79925, 270581, 2 }, --
    natures_endurance              = { 79820, 388042, 1 }, --
    nesingwarys_trapping_apparatus = { 79929, 378759, 2 }, --
    posthaste                      = { 79921, 109215, 2 }, --
    precise_shots                  = { 79877, 260240, 2 }, --
    quick_load                     = { 79878, 378771, 1 }, --
    rapid_fire                     = { 79880, 257044, 1 }, --
    razor_fragments                = { 79831, 384790, 1 }, --
    readiness                      = { 79813, 389865, 1 }, --
    rejuvenating_wind              = { 79909, 385539, 2 }, --
    salvo                          = { 79830, 384791, 1 }, --
    scare_beast                    = { 79927, 1513  , 1 }, --
    scatter_shot                   = { 79937, 213691, 1 }, --
    sentinel_nyi                   = { 79819, 388045, 1 }, --
    sentinels_perception_nyi       = { 79818, 388056, 1 }, --
    sentinels_wisdom_nyi           = { 79818, 388057, 1 }, --
    serpent_sting                  = { 79905, 271788, 1 }, --
    serpentstalkers_trickery       = { 79881, 378888, 1 }, --
    serrated_shots                 = { 79814, 389882, 2 }, --
    sharpshooter                   = { 79887, 378907, 2 }, --
    stampede                       = { 79916, 201430, 1 }, --
    steady_focus                   = { 79891, 193533, 2 }, --
    steel_trap                     = { 79908, 162488, 1 }, --
    streamline                     = { 79893, 260367, 2 }, --
    surging_shots                  = { 79897, 391559, 1 }, --
    survival_of_the_fittest        = { 79821, 264735, 1 }, --
    tar_trap                       = { 79928, 187698, 1 }, --
    trailblazer                    = { 79931, 199921, 2 }, --
    tranquilizing_shot             = { 79907, 19801 , 1 }, --
    trick_shots                    = { 79875, 257621, 1 }, --
    true_aim                       = { 79886, 321287, 1 }, --
    trueshot                       = { 79882, 288613, 1 }, --
    unerring_vision                = { 79902, 386878, 1 }, --
    volley                         = { 79890, 260243, 1 }, --
    wailing_arrow                  = { 79885, 392060, 1 }, --
    windrunners_barrage            = { 79813, 389866, 1 }, --
    windrunners_guidance           = { 79894, 378905, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting        = 653 , -- 356719
    consecutive_concussion = 5440, -- 357018
    diamond_ice            = 5533, -- 203340
    dragonscale_armor      = 649 , -- 202589
    hunting_pack           = 3729, -- 203235
    interlope              = 5531, -- 248518
    rangers_finesse        = 659 , -- 248443
    roar_of_sacrifice      = 3614, -- 53480
    sniper_shot            = 660 , -- 203155
    survival_tactics       = 651 , -- 202746
    tranquilizing_darts    = 5419, -- 356015
    trueshot_mastery       = 658 , -- 203129
    wild_kingdom           = 5442, -- 356707
} )


-- Auras
spec:RegisterAuras( {
    aspect_of_the_cheetah = {
        id = 186257,
    },
    aspect_of_the_eagle = {
        id = 186289,
    },
    aspect_of_the_turtle = {
        id = 186265,
    },
    barrage = {
        id = 120360,
    },
    coordinated_assault = {
        id = 360952,
    },
    double_tap = {
        id = 260402,
    },
    eagle_eye = {
        id = 6197,
    },
    feign_death = {
        id = 5384,
    },
    fury_of_the_eagle = {
        id = 203415,
    },
    interlope = {
        id = 248518,
    },
    mastery_sniper_training = {
        id = 193468,
    },
    sentinel_nyi = {
        id = 388045,
    },
    sniper_shot = {
        id = 203155,
    },
    spearhead = {
        id = 360966,
    },
    stampede = {
        id = 201430,
    },
    trueshot = {
        id = 288613,
    },
    volley = {
        id = 260243,
    },
    wild_kingdom = {
        id = 356707,
    },
} )


-- Abilities
spec:RegisterAbilities( {
    aimed_shot = {
        id = 19434,
        cast = 2.5,
        charges = 2,
        cooldown = 12,
        recharge = 12,
        gcd = "spell",

        spend = 35,
        spendType = "focus",

        talent = "aimed_shot",
        startsCombat = false,
        texture = 135130,

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


    aspect_of_the_eagle = {
        id = 186289,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "aspect_of_the_eagle",
        startsCombat = false,
        texture = 612363,

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


    barrage = {
        id = 120360,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 30,
        spendType = "focus",

        talent = "barrage",
        startsCombat = false,
        texture = 236201,

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


    bursting_shot = {
        id = 186387,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 10,
        spendType = "focus",

        talent = "bursting_shot",
        startsCombat = false,
        texture = 1376038,

        handler = function ()
        end,
    },


    butchery = {
        id = 212436,
        cast = 0,
        charges = 3,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",

        spend = 30,
        spendType = "focus",

        talent = "butchery",
        startsCombat = false,
        texture = 999948,

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


    carve = {
        id = 187708,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 35,
        spendType = "focus",

        talent = "carve",
        startsCombat = false,
        texture = 1376039,

        handler = function ()
        end,
    },


    chimaera_shot = {
        id = 342049,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 40,
        spendType = "focus",

        talent = "chimaera_shot",
        startsCombat = false,
        texture = 236176,

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


    coordinated_assault = {
        id = 360952,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "coordinated_assault",
        startsCombat = false,
        texture = 2032587,

        toggle = "cooldowns",

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


    double_tap = {
        id = 260402,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "double_tap",
        startsCombat = false,
        texture = 537468,

        toggle = "cooldowns",

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


    flanking_strike = {
        id = 269751,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "flanking_strike",
        startsCombat = false,
        texture = 236184,

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


    fury_of_the_eagle = {
        id = 203415,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "fury_of_the_eagle",
        startsCombat = false,
        texture = 1239829,

        handler = function ()
        end,
    },


    harpoon = {
        id = 190925,
        cast = 0,
        charges = 1,
        cooldown = 32.99,
        recharge = 32.99,
        gcd = "off",

        talent = "harpoon",
        startsCombat = false,
        texture = 1376040,

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
        startsCombat = false,
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
        startsCombat = true,
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


    mongoose_bite = {
        id = 259387,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "focus",

        talent = "mongoose_bite",
        startsCombat = false,
        texture = 1376044,

        handler = function ()
        end,
    },


    multishot = {
        id = 257620,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 20,
        spendType = "focus",

        talent = "multishot",
        startsCombat = false,
        texture = 132330,

        handler = function ()
        end,
    },


    muzzle = {
        id = 187707,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        talent = "muzzle",
        startsCombat = false,
        texture = 1376045,

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


    rapid_fire = {
        id = 257044,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        talent = "rapid_fire",
        startsCombat = false,
        texture = 461115,

        handler = function ()
        end,
    },


    raptor_strike = {
        id = 186270,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "focus",

        talent = "raptor_strike",
        startsCombat = false,
        texture = 1376046,

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


    sniper_shot = {
        id = 203155,
        cast = 3,
        cooldown = 10,
        gcd = "spell",

        spend = 40,
        spendType = "focus",

        pvptalent = "sniper_shot",
        startsCombat = false,
        texture = 1412205,

        handler = function ()
        end,
    },


    spearhead = {
        id = 360966,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "spearhead",
        startsCombat = false,
        texture = 4667416,

        toggle = "cooldowns",

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


    trueshot = {
        id = 288613,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "trueshot",
        startsCombat = false,
        texture = 132329,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    volley = {
        id = 260243,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "volley",
        startsCombat = false,
        texture = 132205,

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


    wildfire_bomb = {
        id = 259495,
        cast = 0,
        charges = 1,
        cooldown = 18,
        recharge = 18,
        gcd = "spell",

        talent = "wildfire_bomb",
        startsCombat = false,
        texture = 2065634,

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

spec:RegisterPriority( "Marksmanship", 20220917,
-- Notes
[[

]],
-- Priority
[[

]] )