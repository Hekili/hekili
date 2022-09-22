-- DruidRestoration.lua
-- September 2022

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 105 )

spec:RegisterResource( Enum.PowerType.Rage )
spec:RegisterResource( Enum.PowerType.LunarPower )
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

-- Talents
spec:RegisterTalents( {
    abundance                = { 82052, 207383, 1 }, --
    adaptive_swarm           = { 82067, 391888, 1 }, --
    astral_influence         = { 82210, 197524, 2 }, --
    budding_leaves           = { 82072, 392167, 2 }, --
    cenarion_ward            = { 82052, 102351, 1 }, --
    cenarius_guidance        = { 82063, 393371, 1 }, --
    circle_of_life_and_death = { 82074, 391969, 1 }, --
    convoke_the_spirits      = { 82064, 391528, 1 }, --
    cultivation              = { 82056, 200390, 1 }, --
    cyclone                  = { 82213, 33786 , 1 }, --
    dreamstate               = { 82053, 392162, 1 }, --
    efflorescence            = { 82057, 145205, 1 }, --
    embrace_of_the_dream     = { 82070, 392124, 2 }, --
    feline_swiftness         = { 82239, 131768, 2 }, --
    flash_of_clarity         = { 82083, 392220, 1 }, --
    flourish                 = { 82079, 197721, 1 }, --
    frenzied_regeneration    = { 82220, 22842 , 1 }, --
    furor                    = { 82245, 378986, 1 }, --
    germination              = { 82071, 155675, 1 }, --
    grove_tending            = { 82047, 383192, 1 }, --
    harmonious_blooming      = { 82065, 392256, 2 }, --
    heart_of_the_wild        = { 82231, 319454, 1 }, --
    hibernate                = { 82211, 2637  , 1 }, --
    improved_barkskin        = { 82219, 327993, 1 }, --
    improved_ironbark        = { 82081, 382552, 1 }, --
    improved_natures_cure    = { 82203, 392378, 1 }, --
    improved_regrowth        = { 82055, 231032, 1 }, --
    improved_rejuvenation    = { 82240, 231040, 1 }, --
    improved_stampeding_roar = { 82230, 288826, 1 }, --
    improved_sunfire         = { 82207, 231050, 1 }, --
    improved_wild_growth     = { 82045, 328025, 1 }, --
    incapacitating_roar      = { 82237, 99    , 1 }, --
    incarnation_tree_of_life = { 82064, 33891 , 1 }, --
    inner_peace              = { 82053, 197073, 1 }, --
    innervate                = { 82243, 29166 , 1 }, --
    invigorate               = { 82077, 392160, 1 }, --
    ironbark                 = { 82082, 102342, 1 }, --
    ironfur                  = { 82227, 192081, 1 }, --
    killer_instinct          = { 82225, 108299, 3 }, --
    lifebloom                = { 82049, 33763 , 1 }, --
    luxuriant_soil           = { 82068, 392315, 2 }, --
    lycaras_teachings        = { 82233, 378988, 3 }, --
    maim                     = { 82221, 22570 , 1 }, --
    mass_entanglement        = { 82242, 102359, 1 }, --
    mighty_bash              = { 82237, 5211  , 1 }, --
    moonkin_form             = { 82212, 24858 , 1 }, --
    natural_recovery         = { 82206, 377796, 2 }, --
    natural_wisdom           = { 82078, 326228, 1 }, --
    natures_splendor         = { 82051, 392288, 1 }, --
    natures_swiftness        = { 82050, 132158, 1 }, --
    natures_vigil            = { 82244, 124974, 1 }, --
    nourish                  = { 82043, 50464 , 1 }, --
    nurturing_dormancy       = { 82076, 392099, 1 }, --
    nurturing_instinct       = { 82214, 33873 , 3 }, --
    omen_of_clarity          = { 82084, 113043, 1 }, --
    overgrowth               = { 82061, 203651, 1 }, --
    passing_seasons          = { 82051, 382550, 1 }, --
    photosynthesis           = { 82073, 274902, 1 }, --
    power_of_the_archdruid   = { 82077, 392302, 1 }, --
    primal_fury              = { 82238, 159286, 1 }, --
    rake                     = { 82199, 1822  , 1 }, --
    rampant_growth           = { 82058, 278515, 1 }, --
    reforestation            = { 82069, 392356, 1 }, --
    regenerative_heartwood   = { 82075, 392116, 1 }, --
    regenesis                = { 82062, 383191, 2 }, --
    rejuvenation             = { 82217, 774   , 1 }, --
    renewal                  = { 82232, 108238, 1 }, --
    rip                      = { 82222, 1079  , 1 }, --
    skull_bash               = { 82224, 106839, 1 }, --
    soothe                   = { 82229, 2908  , 1 }, --
    soul_of_the_forest       = { 82059, 158478, 1 }, --
    spring_blossoms          = { 82061, 207385, 1 }, --
    stampeding_roar          = { 82234, 106898, 1 }, --
    starfire                 = { 82201, 194153, 1 }, --
    starsurge                = { 82200, 197626, 1 }, --
    stonebark                = { 82081, 197061, 1 }, --
    sunfire                  = { 82208, 93402 , 1 }, --
    swiftmend                = { 82216, 18562 , 1 }, --
    swipe                    = { 82226, 213764, 1 }, --
    thick_hide               = { 82228, 16931 , 2 }, --
    thrash                   = { 82223, 106832, 1 }, --
    tiger_dash               = { 82198, 252216, 1 }, --
    tireless_pursuit         = { 82197, 377801, 1 }, --
    tranquility              = { 82054, 740   , 1 }, --
    typhoon                  = { 82209, 132469, 1 }, --
    unbridled_swarm          = { 82066, 391951, 1 }, --
    undergrowth              = { 82044, 392301, 1 }, --
    unstoppable_growth       = { 82080, 382559, 2 }, --
    ursine_vigor             = { 82235, 377842, 2 }, --
    ursocs_endurance_nnf     = { 82236, 385786, 1 }, --
    ursols_vortex            = { 82242, 102793, 1 }, --
    verdancy                 = { 82060, 392325, 1 }, --
    verdant_heart            = { 82218, 301768, 1 }, --
    verdant_infusion         = { 82079, 392410, 1 }, --
    waking_dream             = { 82046, 392221, 1 }, --
    wellhoned_instincts      = { 82246, 377847, 2 }, --
    wild_charge              = { 82198, 102401, 1 }, --
    wild_growth              = { 82241, 48438 , 1 }, --
    yseras_gift              = { 82048, 145108, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    deep_roots          = 700 , -- 233755
    disentanglement     = 59  , -- 233673
    early_spring        = 1215, -- 203624
    entangling_bark     = 692 , -- 247543
    focused_growth      = 835 , -- 203553
    high_winds          = 838 , -- 200931
    keeper_of_the_grove = 5387, -- 353114
    malornes_swiftness  = 5514, -- 236147
    master_shapeshifter = 3048, -- 289237
    precognition        = 5504, -- 377360
    reactive_resin      = 691 , -- 203399
    thorns              = 697 , -- 305497
} )


-- Auras
spec:RegisterAuras( {
    barkskin = {
        id = 22812,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    bear_form = {
        id = 5487,
        duration = 3600,
        max_stack = 1
    },
    cat_form = {
        id = 768,
        duration = 3600,
        max_stack = 1
    },
    cenarion_ward = {
        id = 102351,
        duration = 30,
        max_stack = 1
    },
    cenarion_ward_heal = {
        id = 102352,
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    clearcasting = {
        id = 16870,
        duration = 15,
        max_stack = 1
    },
    convoke_the_spirits = {
        id = 391528,
        duration = 4,
        tick_time = 0.25,
        max_stack = 99 -- ???
    },
    cyclone = {
        id = 33786,
        duration = 6,
        max_stack = 1
    },
    dash = {
        id = 1850,
        duration = 10,
        max_stack = 1
    },
    efflorescence = { -- TODO: Is a totem.
        id = 145205,
        duration = 30,
        max_stack = 1
    },
    entangling_roots = {
        id = 339,
        duration = 30,
        tick_time = 2,
        max_stack = 1
    },
    flourish = {
        id = 197721,
        duration = 8,
        tick_time = 0.25,
        max_stack = 1
    },
    frenzied_regeneration = {
        id = 22842,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    grove_tending = {
        id = 383193,
        duration = 9,
        tick_time = 3,
        max_stack = 1
    },
    growl = {
        id = 6795,
        duration = 3,
        max_stack = 1
    },
    heart_of_the_wild = {
        id = 319454,
        duration = 45,
        max_stack = 1
    },
    hibernate = {
        id = 2637,
        duration = 40,
        max_stack = 1
    },
    incapacitating_roar = {
        id = 99,
        duration = 3,
        max_stack = 1
    },
    incarnation_tree_of_life = {
        id = 33891,
        duration = 3600,
        tick_time = 7,
        max_stack = 1,
        copy = "incarnation"
    },
    innervate = {
        id = 29166,
        duration = 10,
        max_stack = 1
    },
    ironbark = {
        id = 102342,
        duration = 12,
        max_stack = 1
    },
    ironfur = {
        id = 192081,
        duration = 7,
        max_stack = 1
    },
    lifebloom = {
        id = 33763,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    mark_of_the_wild = {
        id = 1126,
        duration = 3600,
        max_stack = 1
    },
    mass_entanglement = {
        id = 102359,
        duration = 30,
        tick_time = 2,
        max_stack = 1
    },
    mighty_bash = {
        id = 5211,
        duration = 4,
        max_stack = 1
    },
    moonkin_form = {
        id = 24858,
        duration = 3600,
        max_stack = 1
    },
    natures_swiftness = {
        id = 132158,
        duration = 3600,
        max_stack = 1
    },
    natures_vigil = {
        id = 124974,
        duration = 30,
        tick_time = 0.5,
        max_stack = 1
    },
    power_of_the_archdruid = {
        id = 392303,
        duration = 15,
        max_stack = 1
    },
    prowl = {
        id = 5215,
        duration = 3600,
        max_stack = 1
    },
    rake = {
        id = 155722,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    regrowth = {
        id = 8936,
        duration = 12,
        tick_time = 2,
        max_stack = 1
    },
    rejuvenation = {
        id = 774,
        duration = 12,
        tick_time = 3,
        max_stack = 1
    },
    rip = {
        id = 1079,
        duration = 24,
        tick_time = 2,
        max_stack = 1
    },
    stampeding_roar = {
        id = 106898,
        duration = 8,
        max_stack = 1
    },
    thorns = {
        id = 305497,
        duration = 12,
        max_stack = 1
    },
    tiger_dash = {
        id = 252216,
        duration = 5,
        tick_time = 0.5,
        max_stack = 1
    },
    tranquility = {
        id = 157982,
        duration = 8,
        tick_time = 2,
        max_stack = 5
    },
    travel_form = {
        id = 783,
        duration = 3600,
        max_stack = 1
    },
    typhoon = {
        id = 61391,
        duration = 6,
        max_stack = 1
    },
    unbridled_swarm = {
        id = 391951,
        duration = 3600,
        max_stack = 1
    },
    ursine_vigor = {
        id = 340541,
        duration = 4,
        max_stack = 1
    },
    ursocs_endurance = {
        id = 385787,
        duration = 8,
        max_stack = 1
    },
    ursols_vortex = {
        id = 102793,
        duration = 10,
        max_stack = 1
    },
    wild_charge = {
        id = 102401,
        duration = 0.5,
        max_stack = 1
    },
    wild_growth = {
        id = 48438,
        duration = 7,
        tick_time = 1,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    adaptive_swarm = {
        id = 391888,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        talent = "adaptive_swarm",
        startsCombat = false,
        texture = 3578197,

        handler = function ()
        end,
    },


    barkskin = {
        id = 22812,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        startsCombat = false,
        texture = 136097,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    bear_form = {
        id = 5487,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132276,

        handler = function ()
        end,
    },


    cat_form = {
        id = 768,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132115,

        handler = function ()
        end,
    },


    cenarion_ward = {
        id = 102351,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.09,
        spendType = "mana",

        talent = "cenarion_ward",
        startsCombat = false,
        texture = 132137,

        handler = function ()
        end,
    },


    convoke_the_spirits = {
        id = 391528,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "convoke_the_spirits",
        startsCombat = false,
        texture = 3636839,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    cyclone = {
        id = 33786,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        talent = "cyclone",
        startsCombat = false,
        texture = 136022,

        handler = function ()
        end,
    },


    dash = {
        id = 1850,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 132120,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    efflorescence = {
        id = 145205,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.17,
        spendType = "mana",

        talent = "efflorescence",
        startsCombat = false,
        texture = 134222,

        handler = function ()
        end,
    },


    entangling_roots = {
        id = 339,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 136100,

        handler = function ()
        end,
    },


    ferocious_bite = {
        id = 22568,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132127,

        handler = function ()
        end,
    },


    flourish = {
        id = 197721,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "flourish",
        startsCombat = false,
        texture = 538743,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    frenzied_regeneration = {
        id = 22842,
        cast = 0,
        charges = 1,
        cooldown = 36,
        recharge = 36,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        talent = "frenzied_regeneration",
        startsCombat = false,
        texture = 132091,

        handler = function ()
        end,
    },


    growl = {
        id = 6795,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 132270,

        handler = function ()
        end,
    },


    heart_of_the_wild = {
        id = 319454,
        cast = 0,
        cooldown = 300,
        gcd = "spell",

        talent = "heart_of_the_wild",
        startsCombat = false,
        texture = 135879,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    hibernate = {
        id = 2637,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "hibernate",
        startsCombat = false,
        texture = 136090,

        handler = function ()
        end,
    },


    incapacitating_roar = {
        id = 99,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "incapacitating_roar",
        startsCombat = false,
        texture = 132121,

        handler = function ()
        end,
    },


    incarnation_tree_of_life = {
        id = 33891,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "incarnation_tree_of_life",
        startsCombat = false,
        texture = 236157,

        toggle = "cooldowns",

        handler = function ()
        end,

        copy = "incarnation"
    },


    innervate = {
        id = 29166,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "innervate",
        startsCombat = false,
        texture = 136048,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    invigorate = {
        id = 392160,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "invigorate",
        startsCombat = false,
        texture = 136073,

        handler = function ()
        end,
    },


    ironbark = {
        id = 102342,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "ironbark",
        startsCombat = false,
        texture = 572025,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    ironfur = {
        id = 192081,
        cast = 0,
        cooldown = 0.5,
        gcd = "off",

        spend = 40,
        spendType = "rage",

        talent = "ironfur",
        startsCombat = false,
        texture = 1378702,

        handler = function ()
        end,
    },


    lifebloom = {
        id = 33763,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "lifebloom",
        startsCombat = false,
        texture = 134206,

        handler = function ()
        end,
    },


    maim = {
        id = 22570,
        cast = 0,
        cooldown = 20,
        gcd = "totem",

        spend = 30,
        spendType = "energy",

        talent = "maim",
        startsCombat = false,
        texture = 132134,

        handler = function ()
        end,
    },


    mangle = {
        id = 33917,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        startsCombat = true,
        texture = 132135,

        handler = function ()
        end,
    },


    mark_of_the_wild = {
        id = 1126,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.2,
        spendType = "mana",

        startsCombat = false,
        texture = 136078,

        handler = function ()
        end,
    },


    mass_entanglement = {
        id = 102359,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "mass_entanglement",
        startsCombat = false,
        texture = 538515,

        handler = function ()
        end,
    },


    mighty_bash = {
        id = 5211,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "mighty_bash",
        startsCombat = false,
        texture = 132114,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    moonfire = {
        id = 8921,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 136096,

        handler = function ()
        end,
    },


    moonkin_form = {
        id = 24858,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "moonkin_form",
        startsCombat = false,
        texture = 136036,

        handler = function ()
        end,
    },


    natures_cure = {
        id = 88423,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 236288,

        handler = function ()
        end,
    },


    natures_swiftness = {
        id = 132158,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "natures_swiftness",
        startsCombat = false,
        texture = 136076,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    natures_vigil = {
        id = 124974,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "natures_vigil",
        startsCombat = false,
        texture = 236764,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    nourish = {
        id = 50464,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        talent = "nourish",
        startsCombat = false,
        texture = 236162,

        handler = function ()
        end,
    },


    overgrowth = {
        id = 203651,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        talent = "overgrowth",
        startsCombat = false,
        texture = 1408836,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    prowl = {
        id = 5215,
        cast = 0,
        cooldown = 6,
        gcd = "off",

        startsCombat = false,
        texture = 514640,

        handler = function ()
        end,
    },


    rake = {
        id = 1822,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        talent = "rake",
        startsCombat = false,
        texture = 132122,

        handler = function ()
        end,
    },


    rebirth = {
        id = 20484,
        cast = 2,
        cooldown = 600,
        gcd = "spell",

        spend = 0,
        spendType = "rage",

        startsCombat = true,
        texture = 136080,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    regrowth = {
        id = 8936,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.17,
        spendType = "mana",

        startsCombat = false,
        texture = 136085,

        handler = function ()
        end,
    },


    rejuvenation = {
        id = 774,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.11,
        spendType = "mana",

        talent = "rejuvenation",
        startsCombat = false,
        texture = 136081,

        handler = function ()
        end,
    },


    renewal = {
        id = 108238,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "renewal",
        startsCombat = false,
        texture = 136059,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    revitalize = {
        id = 212040,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 132125,

        handler = function ()
        end,
    },


    revive = {
        id = 50769,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 132132,

        handler = function ()
        end,
    },


    rip = {
        id = 1079,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 5,
        spendType = "combo_points",

        talent = "rip",
        startsCombat = false,
        texture = 132152,

        handler = function ()
        end,
    },


    shred = {
        id = 5221,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 40,
        spendType = "energy",

        startsCombat = true,
        texture = 136231,

        handler = function ()
        end,
    },


    skull_bash = {
        id = 106839,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        talent = "skull_bash",
        startsCombat = false,
        texture = 236946,

        handler = function ()
        end,
    },


    soothe = {
        id = 2908,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "soothe",
        startsCombat = false,
        texture = 132163,

        handler = function ()
        end,
    },


    stampeding_roar = {
        id = 106898,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "stampeding_roar",
        startsCombat = false,
        texture = 464343,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    starfire = {
        id = 194153,
        cast = 2.25,
        cooldown = 0,
        gcd = "spell",

        talent = "starfire",
        startsCombat = false,
        texture = 135753,

        handler = function ()
        end,
    },


    starsurge = {
        id = 197626,
        cast = 2,
        cooldown = 10,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "starsurge",
        startsCombat = false,
        texture = 135730,

        handler = function ()
        end,
    },


    sunfire = {
        id = 93402,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.12,
        spendType = "mana",

        talent = "sunfire",
        startsCombat = false,
        texture = 236216,

        handler = function ()
        end,
    },


    swiftmend = {
        id = 18562,
        cast = 0,
        charges = 1,
        cooldown = 15,
        recharge = 15,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "swiftmend",
        startsCombat = false,
        texture = 134914,

        handler = function ()
        end,
    },


    swipe = {
        id = 213764,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        talent = "swipe",
        startsCombat = false,
        texture = 134296,

        handler = function ()
        end,
    },


    teleport_moonglade = {
        id = 18960,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 10,
        spendType = "mana",

        startsCombat = false,
        texture = 135758,

        handler = function ()
        end,
    },


    thorns = {
        id = 305497,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 0.18,
        spendType = "mana",

        pvptalent = "thorns",
        startsCombat = false,
        texture = 136104,

        handler = function ()
        end,
    },


    thrash = {
        id = 106832,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "thrash",
        startsCombat = false,
        texture = 451161,

        handler = function ()
        end,
    },


    tiger_dash = {
        id = 252216,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "tiger_dash",
        startsCombat = false,
        texture = 1817485,

        handler = function ()
        end,
    },


    tranquility = {
        id = 740,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        talent = "tranquility",
        startsCombat = false,
        texture = 136107,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    travel_form = {
        id = 783,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132144,

        handler = function ()
        end,
    },


    typhoon = {
        id = 132469,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "typhoon",
        startsCombat = false,
        texture = 236170,

        handler = function ()
        end,
    },


    unbridled_swarm = {
        id = 391951,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "unbridled_swarm",
        startsCombat = false,
        texture = 3578197,

        handler = function ()
        end,
    },


    ursols_vortex = {
        id = 102793,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "ursols_vortex",
        startsCombat = false,
        texture = 571588,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    wild_charge = {
        id = 102401,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        talent = "wild_charge",
        startsCombat = false,
        texture = 538771,

        handler = function ()
        end,
    },


    wild_growth = {
        id = 48438,
        cast = 1.5,
        cooldown = 10,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        talent = "wild_growth",
        startsCombat = false,
        texture = 236153,

        handler = function ()
        end,
    },


    wrath = {
        id = 5176,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 535045,

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Restoration", 20220922,
-- Notes
[[

]],
-- Priority
[[

]] )