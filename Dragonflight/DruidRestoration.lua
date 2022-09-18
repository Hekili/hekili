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
    after_the_wildfire                 = { 71697, 371905, 1 }, --
    astral_influence                   = { 71631, 197524, 2 }, --
    berserk_persistence                = { 71704, 377779, 1 }, --
    berserk_ravage                     = { 71711, 343240, 1 }, --
    berserk_unchecked_aggression       = { 71725, 377623, 1 }, --
    blood_frenzy                       = { 71699, 203962, 1 }, --
    brambles                           = { 71721, 203953, 1 }, --
    bristling_fur                      = { 71721, 155835, 1 }, --
    circle_of_life_and_death           = { 71696, 338657, 2 }, --
    convoke_the_spirits                = { 71695, 337433, 1 }, --
    cyclone                            = { 71604, 33786 , 1 }, --
    dream_of_cenarius                  = { 71689, 372119, 1 }, --
    earthwarden                        = { 71724, 203974, 1 }, --
    elunes_favored                     = { 71693, 370586, 1 }, --
    feline_swiftness                   = { 71648, 131768, 2 }, --
    frenzied_regeneration              = { 71645, 22842 , 1 }, --
    front_of_the_pack                  = { 71708, 377835, 1 }, --
    furor                              = { 71609, 378986, 1 }, --
    fury_of_nature                     = { 71706, 370695, 2 }, --
    galactic_guardian                  = { 71701, 203964, 1 }, --
    gore                               = { 71720, 210706, 1 }, --
    gory_fur                           = { 71713, 200854, 1 }, --
    guardian_of_elune                  = { 71697, 155578, 1 }, --
    heart_of_the_wild                  = { 71612, 319454, 1 }, --
    hibernate                          = { 71603, 2637  , 1 }, --
    improved_barkskin                  = { 71644, 327993, 1 }, --
    improved_frenzied_regeneration_nnf = { 71602, 301768, 1 }, --
    improved_rejuvenation              = { 71627, 231040, 1 }, --
    improved_stampeding_roar           = { 71613, 288826, 1 }, --
    improved_sunfire                   = { 71608, 231050, 1 }, --
    incapacitating_roar                = { 71625, 99    , 1 }, --
    incarnation_guardian_of_ursoc      = { 71695, 102558, 1 }, --
    infected_wounds                    = { 71692, 345208, 1 }, --
    innate_resolve                     = { 71722, 377811, 1 }, --
    innervate                          = { 71634, 29166 , 1 }, --
    ironfur                            = { 71621, 192081, 1 }, --
    killer_instinct                    = { 71619, 108299, 3 }, --
    layered_mane                       = { 71712, 279552, 2 }, --
    lycaras_teachings                  = { 71614, 378988, 3 }, --
    maim                               = { 71606, 22570 , 1 }, --
    mangle_2                           = { 71714, 231064, 1 }, --
    mass_entanglement                  = { 71633, 102359, 1 }, --
    maul                               = { 71719, 6807  , 1 }, --
    mighty_bash                        = { 71625, 5211  , 1 }, --
    modal_cooldown_bonus               = { 71694, 0     , 1 }, --
    moonkin_form                       = { 71639, 24858 , 1 }, --
    natures_vigil                      = { 71635, 124974, 1 }, --
    new_resto_passive_nnf              = { 71629, 377796, 2 }, --
    nurturing_instinct                 = { 71640, 33873 , 3 }, --
    pawsitive_outlook                  = { 71723, 238121, 2 }, --
    primal_fury                        = { 71624, 159286, 1 }, --
    pulverize                          = { 71691, 80313 , 1 }, --
    rage_of_the_sleeper                = { 71698, 200851, 1 }, --
    rake                               = { 71607, 1822  , 1 }, --
    reinforced_fur                     = { 71705, 200395, 1 }, --
    reinvigoration                     = { 71726, 372945, 2 }, --
    rejuvenation                       = { 71643, 774   , 1 }, --
    remove_corruption                  = { 71641, 2782  , 1 }, --
    rend_and_tear                      = { 71690, 204053, 1 }, --
    renewal                            = { 71611, 108238, 1 }, --
    rip                                = { 71647, 1079  , 1 }, --
    scintillating_moonlight            = { 71702, 238049, 2 }, --
    skull_bash                         = { 71618, 106839, 1 }, --
    soothe                             = { 71617, 2908  , 1 }, --
    soul_of_the_forest                 = { 71699, 158477, 1 }, --
    stampeding_roar                    = { 71615, 106898, 1 }, --
    starfire                           = { 71637, 194153, 1 }, --
    starsurge                          = { 71636, 197626, 1 }, --
    sunfire                            = { 71632, 93402 , 1 }, --
    survival_instincts                 = { 71718, 61336 , 1 }, --
    survival_instincts_2               = { 71717, 328767, 1 }, --
    survival_of_the_fittest            = { 71700, 203965, 2 }, --
    swiftmend                          = { 71642, 18562 , 1 }, --
    swipe                              = { 71620, 213764, 1 }, --
    thick_hide                         = { 71622, 16931 , 2 }, --
    thrash                             = { 71646, 106832, 1 }, --
    tiger_dash                         = { 71616, 252216, 1 }, --
    tireless_pursuit                   = { 71605, 377801, 1 }, --
    tooth_and_claw                     = { 71710, 135288, 1 }, --
    twin_moonfire                      = { 71703, 372567, 1 }, --
    typhoon                            = { 71630, 132469, 1 }, --
    untamed_savagery                   = { 71690, 372943, 1 }, --
    ursine_adept                       = { 71716, 300346, 1 }, --
    ursine_vigor                       = { 71610, 377842, 2 }, --
    ursocs_endurance                   = { 71715, 200399, 2 }, --
    ursocs_endurance_nnf               = { 71623, 385786, 1 }, --
    ursocs_fury                        = { 71689, 377210, 1 }, --
    ursols_vortex                      = { 71633, 102793, 1 }, --
    vicious_cycle                      = { 71709, 371999, 1 }, --
    vulnerable_flesh                   = { 71707, 372618, 2 }, --
    wellhoned_instincts                = { 71626, 377847, 2 }, --
    wild_charge                        = { 71616, 102401, 1 }, --
    wild_growth                        = { 71628, 48438 , 1 }, --
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
    mark_of_the_wild    = 3752, -- 289318
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
        id = 279793,
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
    sign_of_the_emissary = {
        id = 225788,
        duration = 3600,
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
        id = 337433,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "convoke_the_spirits",
        startsCombat = false,
        texture = 3636839,

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

        pvptalent = "mark_of_the_wild",
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

        spend = 50,
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

spec:RegisterPriority( "Restoration", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )