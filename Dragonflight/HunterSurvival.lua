-- HunterSurvival.lua
-- September 2022

if UnitClassBase( "player" ) ~= "HUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 255 )

spec:RegisterResource( Enum.PowerType.Focus )

-- Talents
spec:RegisterTalents( {
    agile_movement                 = { 79918, 378002, 2 }, --
    alpha_predator                 = { 79904, 269737, 1 }, --
    arctic_bola                    = { 79815, 390231, 2 }, --
    aspect_of_the_eagle            = { 79857, 186289, 1 }, --
    barrage                        = { 79914, 120360, 1 }, --
    beast_master                   = { 79926, 378007, 2 }, --
    binding_shackles               = { 79920, 321468, 1 }, --
    binding_shot                   = { 79937, 109248, 1 }, --
    birds_of_prey                  = { 79864, 260331, 1 }, --
    bloodseeker                    = { 79859, 260248, 1 }, --
    bloody_claws                   = { 79828, 385737, 2 }, --
    bombardier                     = { 79864, 389880, 1 }, --
    born_to_be_wild                = { 79933, 266921, 2 }, --
    butchery                       = { 79848, 212436, 1 }, --
    camouflage                     = { 79934, 199483, 1 }, --
    carve                          = { 79848, 187708, 1 }, --
    concussive_shot                = { 79906, 5116  , 1 }, --
    coordinated_assault            = { 79865, 360952, 1 }, --
    coordinated_kill               = { 79824, 385739, 2 }, --
    deadly_duo                     = { 79869, 378962, 2 }, --
    death_chakram                  = { 79916, 375891, 1 }, --
    energetic_ally                 = { 79855, 378961, 1 }, --
    explosive_shot                 = { 79914, 212431, 1 }, --
    explosives_expert              = { 79858, 378937, 2 }, --
    ferocity                       = { 79845, 378916, 1 }, --
    flanking_strike                = { 79841, 269751, 1 }, --
    frenzy_strikes                 = { 79844, 294029, 1 }, --
    fury_of_the_eagle              = { 79852, 203415, 1 }, --
    guerrilla_tactics              = { 79867, 264332, 1 }, --
    harpoon                        = { 79842, 190925, 1 }, --
    hiexplosive_trap               = { 79910, 236776, 1 }, --
    hunters_agility                = { 79832, 384799, 1 }, --
    hydras_bite                    = { 79911, 260241, 1 }, --
    improved_kill_command          = { 79932, 378010, 2 }, --
    improved_kill_shot             = { 79930, 343248, 1 }, --
    improved_mend_pet              = { 79936, 343242, 2 }, --
    improved_tranquilizing_shot    = { 79919, 343244, 1 }, --
    improved_traps                 = { 79923, 343247, 2 }, --
    improved_wildfire_bomb         = { 79850, 321290, 2 }, --
    intense_focus                  = { 79827, 385709, 1 }, --
    intimidation                   = { 79910, 19577 , 1 }, --
    keen_eyesight                  = { 79922, 378004, 2 }, --
    kill_command                   = { 79839, 259489, 1 }, --
    kill_shot                      = { 79833, 320976, 1 }, --
    killer_companion               = { 79854, 378955, 2 }, --
    killer_instinct                = { 79904, 273887, 1 }, --
    latent_poison_injectors        = { 79911, 378014, 1 }, --
    lone_survivor                  = { 79820, 388039, 1 }, --
    lunge                          = { 79846, 378934, 1 }, --
    master_marksman                = { 79913, 260309, 2 }, --
    misdirection                   = { 79924, 34477 , 1 }, --
    mongoose_bite                  = { 79861, 259387, 1 }, --
    muzzle                         = { 79837, 187707, 1 }, --
    natural_mending                = { 79925, 270581, 2 }, --
    natures_endurance              = { 79820, 388042, 1 }, --
    nesingwarys_trapping_apparatus = { 79929, 378759, 2 }, --
    posthaste                      = { 79921, 109215, 2 }, --
    predator                       = { 79860, 263186, 1 }, --
    quick_shot                     = { 79868, 378940, 1 }, --
    ranger                         = { 79825, 385695, 2 }, --
    raptor_strike                  = { 79847, 186270, 1 }, --
    rejuvenating_wind              = { 79909, 385539, 2 }, --
    ruthless_marauder              = { 79829, 385718, 3 }, --
    scare_beast                    = { 79927, 1513  , 1 }, --
    scatter_shot                   = { 79937, 213691, 1 }, --
    sentinel_nyi                   = { 79819, 388045, 1 }, --
    sentinels_perception_nyi       = { 79818, 388056, 1 }, --
    sentinels_wisdom_nyi           = { 79818, 388057, 1 }, --
    serpent_sting                  = { 79905, 271788, 1 }, --
    serrated_shots                 = { 79814, 389882, 2 }, --
    sharp_edges                    = { 79843, 378948, 2 }, --
    spear_focus                    = { 79853, 378953, 2 }, --
    spearhead                      = { 79866, 360966, 1 }, --
    stampede                       = { 79916, 201430, 1 }, --
    steel_trap                     = { 79908, 162488, 1 }, --
    survival_of_the_fittest        = { 79821, 264735, 1 }, --
    sweeping_spear                 = { 79856, 378950, 2 }, --
    tactical_advantage             = { 79851, 378951, 2 }, --
    tar_trap                       = { 79928, 187698, 1 }, --
    terms_of_engagement            = { 79862, 265895, 1 }, --
    tip_of_the_spear               = { 79849, 260285, 2 }, --
    trailblazer                    = { 79931, 199921, 2 }, --
    tranquilizing_shot             = { 79907, 19801 , 1 }, --
    vipers_venom                   = { 79826, 268501, 2 }, --
    wildfire_bomb                  = { 79863, 259495, 1 }, --
    wildfire_infusion              = { 79870, 271014, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chimaeral_sting     = 3609, -- 356719
    diamond_ice         = 686 , -- 203340
    dragonscale_armor   = 3610, -- 202589
    hunting_pack        = 661 , -- 203235
    interlope           = 5532, -- 248518
    mending_bandage     = 662 , -- 212640
    roar_of_sacrifice   = 663 , -- 53480
    sticky_tar          = 664 , -- 203264
    survival_tactics    = 3607, -- 202746
    trackers_net        = 665 , -- 212638
    tranquilizing_darts = 5420, -- 356015
    wild_kingdom        = 5443, -- 356707
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
    mastery_spirit_bond = {
        id = 263135,
    },
    sentinel_nyi = {
        id = 388045,
    },
    spearhead = {
        id = 360966,
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

        spend = 60,
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
        id = 259489,
        cast = 0,
        charges = 1,
        cooldown = 6,
        recharge = 6,
        gcd = "spell",

        talent = "kill_command",
        startsCombat = true,
        texture = 132176,

        handler = function ()
        end,
    },


    kill_shot = {
        id = 320976,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 10,
        spendType = "focus",

        talent = "kill_shot",
        startsCombat = false,
        texture = 236174,

        handler = function ()
        end,
    },


    mending_bandage = {
        id = 212640,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        pvptalent = "mending_bandage",
        startsCombat = false,
        texture = 1014022,

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


    primal_rage = {
        id = 272678,
        cast = 0,
        cooldown = 360,
        gcd = "off",

        startsCombat = true,
        texture = 136224,

        toggle = "cooldowns",

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


    trackers_net = {
        id = 212638,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        pvptalent = "trackers_net",
        startsCombat = false,
        texture = 1412207,

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

spec:RegisterPriority( "Survival", 20220917,
-- Notes
[[

]],
-- Priority
[[

]] )