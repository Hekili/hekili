-- DruidFeral.lua
-- September 2022

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 103 )

spec:RegisterResource( Enum.PowerType.Rage )
spec:RegisterResource( Enum.PowerType.LunarPower )
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

-- Talents
spec:RegisterTalents( {
    adaptive_swarm                 = { 82112, 391888, 1 }, --
    apex_predators_craving         = { 82092, 391881, 1 }, --
    ashamanes_guidance             = { 82113, 391548, 1 }, --
    astral_influence               = { 82210, 197524, 2 }, --
    berserk                        = { 82101, 106951, 1 }, --
    berserk_frenzy                 = { 82090, 384668, 1 }, --
    berserk_heart_of_the_lion      = { 82105, 391174, 1 }, --
    bloodtalons                    = { 82109, 319439, 1 }, --
    brutal_slash                   = { 82091, 202028, 1 }, --
    carnivorous_instinct           = { 82110, 390902, 2 }, --
    cats_curiosity                 = { 82094, 386318, 2 }, --
    circle_of_life_and_death       = { 82095, 391969, 1 }, --
    convoke_the_spirits            = { 82114, 391528, 1 }, --
    cyclone                        = { 82213, 33786 , 1 }, --
    doubleclawed_rake              = { 82086, 391700, 1 }, --
    dreadful_bleeding              = { 82117, 391045, 1 }, --
    feline_swiftness               = { 82239, 131768, 2 }, --
    feral_frenzy                   = { 82108, 274837, 1 }, --
    frantic_momentum               = { 82115, 391875, 2 }, --
    frenzied_regeneration          = { 82220, 22842 , 1 }, --
    furor                          = { 82245, 378986, 1 }, --
    heart_of_the_wild              = { 82231, 319454, 1 }, --
    hibernate                      = { 82211, 2637  , 1 }, --
    improved_barkskin              = { 82219, 327993, 1 }, --
    improved_rejuvenation          = { 82240, 231040, 1 }, --
    improved_stampeding_roar       = { 82230, 288826, 1 }, --
    improved_sunfire               = { 82207, 231050, 1 }, --
    incapacitating_roar            = { 82237, 99    , 1 }, --
    incarnation_avatar_of_ashamane = { 82114, 102543, 1 }, --
    infected_wounds                = { 82103, 48484 , 1 }, --
    innervate                      = { 82243, 29166 , 1 }, --
    ironfur                        = { 82227, 192081, 1 }, --
    killer_instinct                = { 82225, 108299, 3 }, --
    lions_strength                 = { 82109, 391972, 1 }, --
    lunar_inspiration              = { 82087, 155580, 1 }, --
    lycaras_teachings              = { 82233, 378988, 3 }, --
    maim                           = { 82221, 22570 , 1 }, --
    mass_entanglement              = { 82242, 102359, 1 }, --
    merciless_strikes              = { 82098, 231063, 1 }, --
    mighty_bash                    = { 82237, 5211  , 1 }, --
    moment_of_clarity              = { 82100, 236068, 1 }, --
    moonkin_form                   = { 82212, 24858 , 1 }, --
    natural_recovery               = { 82206, 377796, 2 }, --
    natures_vigil                  = { 82244, 124974, 1 }, --
    nurturing_instinct             = { 82214, 33873 , 3 }, --
    omen_of_clarity                = { 82123, 16864 , 1 }, --
    pouncing_strikes               = { 82119, 390772, 1 }, --
    predator                       = { 82122, 202021, 1 }, --
    predatory_swiftness            = { 82106, 16974 , 1 }, --
    primal_claws                   = { 82085, 391037, 2 }, --
    primal_fury                    = { 82238, 159286, 1 }, --
    primal_wrath                   = { 82120, 285381, 1 }, --
    protective_growth              = { 82097, 391947, 1 }, --
    raging_fury                    = { 82107, 391078, 1 }, --
    rake                           = { 82199, 1822  , 1 }, --
    rampant_ferocity               = { 82099, 391709, 1 }, --
    rejuvenation                   = { 82217, 774   , 1 }, --
    relentless_predator            = { 82088, 393771, 1 }, --
    remove_corruption              = { 82204, 2782  , 1 }, --
    renewal                        = { 82232, 108238, 1 }, --
    rip                            = { 82222, 1079  , 1 }, --
    rip_and_tear                   = { 82093, 391347, 1 }, --
    sabertooth                     = { 82102, 202031, 1 }, --
    skull_bash                     = { 82224, 106839, 1 }, --
    soothe                         = { 82229, 2908  , 1 }, --
    soul_of_the_forest             = { 82096, 158476, 1 }, --
    stampeding_roar                = { 82234, 106898, 1 }, --
    starfire                       = { 82201, 194153, 1 }, --
    starsurge                      = { 82200, 197626, 1 }, --
    sudden_ambush                  = { 82104, 384667, 2 }, --
    sunfire                        = { 82208, 93402 , 1 }, --
    survival_instincts             = { 82116, 61336 , 1 }, --
    swiftmend                      = { 82216, 18562 , 1 }, --
    swipe                          = { 82226, 213764, 1 }, --
    taste_for_blood                = { 82118, 384665, 2 }, --
    tear_open_wounds               = { 82089, 391785, 1 }, --
    thick_hide                     = { 82228, 16931 , 2 }, --
    thrash                         = { 82223, 106832, 1 }, --
    tiger_dash                     = { 82198, 252216, 1 }, --
    tigers_fury                    = { 82124, 5217  , 1 }, --
    tigers_tenacity                = { 82107, 391872, 1 }, --
    tireless_energy                = { 82121, 383352, 2 }, --
    tireless_pursuit               = { 82197, 377801, 1 }, --
    typhoon                        = { 82209, 132469, 1 }, --
    unbridled_swarm                = { 82111, 391951, 1 }, --
    ursine_vigor                   = { 82235, 377842, 2 }, --
    ursocs_endurance_nnf           = { 82236, 385786, 1 }, --
    ursols_vortex                  = { 82242, 102793, 1 }, --
    veinripper                     = { 82093, 391978, 1 }, --
    verdant_heart                  = { 82218, 301768, 1 }, --
    wellhoned_instincts            = { 82246, 377847, 2 }, --
    wild_charge                    = { 82198, 102401, 1 }, --
    wild_growth                    = { 82241, 48438 , 1 }, --
    wild_slashes                   = { 82091, 390864, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    ferocious_wound      = 611 , -- 236020
    freedom_of_the_herd  = 203 , -- 213200
    fresh_wound          = 612 , -- 203224
    high_winds           = 5384, -- 200931
    king_of_the_jungle   = 602 , -- 203052
    leader_of_the_pack   = 3751, -- 202626
    malornes_swiftness   = 601 , -- 236012
    reactive_resin       = 5525, -- 203399
    savage_momentum      = 820 , -- 205673
    strength_of_the_wild = 3053, -- 236019
    thorns               = 201 , -- 305497
    wicked_claws         = 620 , -- 203242
} )


-- Auras
spec:RegisterAuras( {
    apex_predators_craving = {
        id = 391882,
        duration = 15,
        max_stack = 1
    },
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
    berserk = {
        id = 106951,
        duration = 20,
        max_stack = 1
    },
    cat_form = {
        id = 768,
        duration = 3600,
        max_stack = 1
    },
    clearcasting = {
        id = 135700,
        duration = 15,
        max_stack = 1
    },
    convoke_the_spirits = {
        id = 391528,
        duration = 4,
        tick_time = 0.25,
        max_stack = 99
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
    entangling_roots = {
        id = 339,
        duration = 30,
        tick_time = 2,
        max_stack = 1
    },
    eye_of_fearful_symmetry = {
        id = 391873,
        duration = 15,
        max_stack = 1
    },
    feral_frenzy = { -- TODO: Model CP gain every 0.2 seconds?
        id = 274837,
        duration = 1,
        tick_time = 0.2,
        max_stack = 1
    },
    frantic_momentum = {
        id = 391876,
        duration = 6,
        max_stack = 1
    },
    frenzied_regeneration = {
        id = 22842,
        duration = 3,
        tick_time = 1,
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
    incarnation_avatar_of_ashamane = {
        id = 102543,
        duration = 30,
        max_stack = 1,
        copy = "incarnation"
    },
    incarnation_prowl = {
        id = 252071,
        duration = 30,
        max_stack = 1
    },
    infected_wounds = {
        id = 58180,
        duration = 12,
        max_stack = 1
    },
    innervate = {
        id = 29166,
        duration = 10,
        max_stack = 1
    },
    ironfur = {
        id = 192081,
        duration = 7,
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
    natures_vigil = {
        id = 124974,
        duration = 30,
        tick_time = 0.5,
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
    sudden_ambush = {
        id = 391974,
        duration = 15,
        max_stack = 1
    },
    survival_instincts = {
        id = 61336,
        duration = 6,
        max_stack = 1
    },
    tear = {
        id = 391356,
        duration = 6,
        tick_time = 2,
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
    tigers_fury = {
        id = 5217,
        duration = 10,
        max_stack = 1
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


    berserk = {
        id = 106951,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "berserk",
        startsCombat = false,
        texture = 236149,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    brutal_slash = {
        id = 202028,
        cast = 0,
        charges = 3,
        cooldown = 8,
        recharge = 8,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        talent = "brutal_slash",
        startsCombat = false,
        texture = 132141,

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


    feral_frenzy = {
        id = 274837,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        talent = "feral_frenzy",
        startsCombat = false,
        texture = 132140,

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


    incarnation_avatar_of_ashamane = {
        id = 102543,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "incarnation_avatar_of_ashamane",
        startsCombat = false,
        texture = 571586,

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


    primal_wrath = {
        id = 285381,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 20,
        spendType = "energy",

        talent = "primal_wrath",
        startsCombat = false,
        texture = 1392547,

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
        startsCombat = true,
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


    remove_corruption = {
        id = 2782,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "remove_corruption",
        startsCombat = false,
        texture = 135952,

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


    survival_instincts = {
        id = 61336,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "off",

        talent = "survival_instincts",
        startsCombat = false,
        texture = 236169,

        toggle = "cooldowns",

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
        id = 106830,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 40,
        spendType = "energy",

        talent = "thrash",
        startsCombat = true,
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


    tigers_fury = {
        id = 5217,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        talent = "tigers_fury",
        startsCombat = false,
        texture = 132242,

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

spec:RegisterPriority( "Feral", 20220922,
-- Notes
[[

]],
-- Priority
[[

]] )