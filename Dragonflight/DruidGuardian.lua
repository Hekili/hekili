-- DruidGuardian.lua
-- September 2022

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 104 )

spec:RegisterResource( Enum.PowerType.Rage )
spec:RegisterResource( Enum.PowerType.LunarPower )
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

-- Talents
spec:RegisterTalents( {
    after_the_wildfire            = { 82140, 371905, 1 }, --
    astral_influence              = { 82210, 197524, 2 }, --
    berserk_persistence           = { 82144, 377779, 1 }, --
    berserk_ravage                = { 82149, 343240, 1 }, --
    berserk_unchecked_aggression  = { 82155, 377623, 1 }, --
    blood_frenzy                  = { 82142, 203962, 1 }, --
    brambles                      = { 82161, 203953, 1 }, --
    bristling_fur                 = { 82161, 155835, 1 }, --
    circle_of_life_and_death      = { 82137, 391969, 1 }, --
    convoke_the_spirits           = { 82136, 391528, 1 }, --
    cyclone                       = { 82213, 33786 , 1 }, --
    dream_of_cenarius             = { 82151, 372119, 1 }, --
    earthwarden                   = { 82156, 203974, 1 }, --
    elunes_favored                = { 82134, 370586, 1 }, --
    feline_swiftness              = { 82239, 131768, 2 }, --
    flashing_claws                = { 82157, 393427, 2 }, --
    frenzied_regeneration         = { 82220, 22842 , 1 }, --
    front_of_the_pack             = { 82125, 377835, 1 }, --
    furor                         = { 82245, 378986, 1 }, --
    fury_of_nature                = { 82138, 370695, 2 }, --
    galactic_guardian             = { 82147, 203964, 1 }, --
    gore                          = { 82126, 210706, 1 }, --
    gory_fur                      = { 82132, 200854, 1 }, --
    guardian_of_elune             = { 82140, 155578, 1 }, --
    heart_of_the_wild             = { 82231, 319454, 1 }, --
    hibernate                     = { 82211, 2637  , 1 }, --
    improved_barkskin             = { 82219, 327993, 1 }, --
    improved_rejuvenation         = { 82240, 231040, 1 }, --
    improved_stampeding_roar      = { 82230, 288826, 1 }, --
    improved_sunfire              = { 82207, 231050, 1 }, --
    improved_survival_instincts   = { 82128, 328767, 1 }, --
    incapacitating_roar           = { 82237, 99    , 1 }, --
    incarnation_guardian_of_ursoc = { 82136, 102558, 1 }, --
    infected_wounds               = { 82162, 345208, 1 }, --
    innate_resolve                = { 82160, 377811, 1 }, --
    innervate                     = { 82243, 29166 , 1 }, --
    ironfur                       = { 82227, 192081, 1 }, --
    killer_instinct               = { 82225, 108299, 3 }, --
    layered_mane                  = { 82148, 279552, 2 }, --
    lycaras_teachings             = { 82233, 378988, 3 }, --
    maim                          = { 82221, 22570 , 1 }, --
    mangle                        = { 82131, 231064, 1 }, --
    mass_entanglement             = { 82242, 102359, 1 }, --
    maul                          = { 82127, 6807  , 1 }, --
    mighty_bash                   = { 82237, 5211  , 1 }, --
    moonkin_form                  = { 82212, 24858 , 1 }, --
    natural_recovery              = { 82206, 377796, 2 }, --
    natures_vigil                 = { 82244, 124974, 1 }, --
    nurturing_instinct            = { 82214, 33873 , 3 }, --
    primal_fury                   = { 82238, 159286, 1 }, --
    pulverize                     = { 82153, 80313 , 1 }, --
    rage_of_the_sleeper           = { 82141, 200851, 1 }, --
    rake                          = { 82199, 1822  , 1 }, --
    reinforced_fur                = { 82139, 393618, 1 }, --
    reinvigoration                = { 82154, 372945, 2 }, --
    rejuvenation                  = { 82217, 774   , 1 }, --
    remove_corruption             = { 82215, 2782  , 1 }, --
    rend_and_tear                 = { 82152, 204053, 1 }, --
    renewal                       = { 82232, 108238, 1 }, --
    rip                           = { 82222, 1079  , 1 }, --
    scintillating_moonlight       = { 82146, 238049, 2 }, --
    skull_bash                    = { 82224, 106839, 1 }, --
    soothe                        = { 82229, 2908  , 1 }, --
    soul_of_the_forest            = { 82142, 158477, 1 }, --
    stampeding_roar               = { 82234, 106898, 1 }, --
    starfire                      = { 82201, 194153, 1 }, --
    starsurge                     = { 82200, 197626, 1 }, --
    sunfire                       = { 82208, 93402 , 1 }, --
    survival_instincts            = { 82129, 61336 , 1 }, --
    survival_of_the_fittest       = { 82143, 203965, 2 }, --
    swiftmend                     = { 82216, 18562 , 1 }, --
    swipe                         = { 82226, 213764, 1 }, --
    thick_hide                    = { 82228, 16931 , 2 }, --
    thrash                        = { 82223, 106832, 1 }, --
    tiger_dash                    = { 82198, 252216, 1 }, --
    tireless_pursuit              = { 82197, 377801, 1 }, --
    tooth_and_claw                = { 82159, 135288, 1 }, --
    twin_moonfire                 = { 82145, 372567, 1 }, --
    typhoon                       = { 82209, 132469, 1 }, --
    untamed_savagery              = { 82152, 372943, 1 }, --
    ursine_adept                  = { 82150, 300346, 1 }, --
    ursine_vigor                  = { 82235, 377842, 2 }, --
    ursocs_endurance              = { 82130, 393611, 2 }, --
    ursocs_endurance_nnf          = { 82236, 385786, 1 }, --
    ursocs_fury                   = { 82151, 377210, 1 }, --
    ursocs_guidance               = { 82135, 393414, 1 }, --
    ursols_vortex                 = { 82242, 102793, 1 }, --
    verdant_heart                 = { 82218, 301768, 1 }, --
    vicious_cycle                 = { 82158, 371999, 1 }, --
    vulnerable_flesh              = { 82133, 372618, 2 }, --
    wellhoned_instincts           = { 82246, 377847, 2 }, --
    wild_charge                   = { 82198, 102401, 1 }, --
    wild_growth                   = { 82241, 48438 , 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    alpha_challenge     = 842 , -- 207017
    charging_bash       = 194 , -- 228431
    demoralizing_roar   = 52  , -- 201664
    den_mother          = 51  , -- 236180
    emerald_slumber     = 197 , -- 329042
    entangling_claws    = 195 , -- 202226
    freedom_of_the_herd = 3750, -- 213200
    grove_protection    = 5410, -- 354654
    malornes_swiftness  = 1237, -- 236147
    master_shapeshifter = 49  , -- 236144
    overrun             = 196 , -- 202246
    raging_frenzy       = 192 , -- 236153
    reactive_resin      = 5524, -- 203399
    sharpened_claws     = 193 , -- 202110
    toughness           = 50  , -- 201259
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
    bristling_fur = {
        id = 155835,
        duration = 8,
        max_stack = 1
    },
    cat_form = {
        id = 768,
        duration = 3600,
        max_stack = 1
    },
    convoke_the_spirits = {
        id = 323764,
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
    demoralizing_roar = {
        id = 201664,
        duration = 8,
        max_stack = 1
    },
    dream_of_cenarius = {
        id = 372152,
        duration = 30,
        max_stack = 1
    },
    emerald_slumber = {
        id = 329042,
        duration = 8,
        tick_time = 0.9,
        max_stack = 1
    },
    entangling_roots = {
        id = 339,
        duration = 30,
        tick_time = 2,
        max_stack = 1
    },
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 5
    },
    frenzied_regeneration = {
        id = 22842,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    gory_fur = {
        id = 201671,
        duration = 3600,
        max_stack = 1
    },
    grove_protection = {
        id = 354704,
        duration = 10, -- TODO: Check actual effect.  12?
        max_stack = 1
    },
    grove_protection_bypass = {
        id = 354789,
        duration = 12,
        max_stack = 1
    },
    growl = {
        id = 6795,
        duration = 3,
        max_stack = 1
    },
    guardian_of_elune = {
        id = 213680,
        duration = 15,
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
    incarnation_guardian_of_ursoc = {
        id = 102558,
        duration = 30,
        max_stack = 1,
        copy = "incarnation"
    },
    infected_wounds = {
        id = 345209,
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
    overrun = {
        id = 202249,
        duration = 1,
        max_stack = 1
    },
    prowl = {
        id = 5215,
        duration = 3600,
        max_stack = 1
    },
    pulverize = {
        id = 80313,
        duration = 10,
        max_stack = 1
    },
    rage_of_the_sleeper = {
        id = 200851,
        duration = 10,
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
    survival_instincts = {
        id = 61336,
        duration = 6,
        max_stack = 1
    },
    tiger_dash = {
        id = 252216,
        duration = 5,
        tick_time = 0.5,
        max_stack = 1
    },
    tooth_and_claw = {
        id = 135286,
        duration = 15,
        max_stack = 2
    },
    tooth_and_claw_debuff = {
        id = 135601,
        duration = 6,
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
    alpha_challenge = {
        id = 207017,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        pvptalent = "alpha_challenge",
        startsCombat = false,
        texture = 132270,

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


    bristling_fur = {
        id = 155835,
        cast = 0,
        cooldown = 40,
        gcd = "spell",

        talent = "bristling_fur",
        startsCombat = false,
        texture = 1033476,

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
        cast = 1.6,
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


    demoralizing_roar = {
        id = 201664,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        pvptalent = "demoralizing_roar",
        startsCombat = false,
        texture = 132117,

        handler = function ()
        end,
    },


    emerald_slumber = {
        id = 329042,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        pvptalent = "emerald_slumber",
        startsCombat = false,
        texture = 1394953,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    entangling_roots = {
        id = 339,
        cast = 1.6,
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


    grove_protection = {
        id = 354654,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "grove_protection",
        startsCombat = false,
        texture = 4067364,

        toggle = "cooldowns",

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


    incarnation_guardian_of_ursoc = {
        id = 102558,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "incarnation_guardian_of_ursoc",
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


    maul = {
        id = 6807,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 40,
        spendType = "rage",

        talent = "maul",
        startsCombat = false,
        texture = 132136,

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


    overrun = {
        id = 202246,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        pvptalent = "overrun",
        startsCombat = false,
        texture = 1408833,

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


    pulverize = {
        id = 80313,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "pulverize",
        startsCombat = false,
        texture = 1033490,

        handler = function ()
        end,
    },


    rage_of_the_sleeper = {
        id = 200851,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "rage_of_the_sleeper",
        startsCombat = false,
        texture = 1129695,

        toggle = "cooldowns",

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
        cast = 0,
        cooldown = 600,
        gcd = "spell",

        spend = 30,
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


    thrash = {
        id = 77758,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

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

spec:RegisterPriority( "Guardian", 20220922,
-- Notes
[[

]],
-- Priority
[[

]] )