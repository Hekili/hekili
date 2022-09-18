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
    adaptive_swarm                     = { 71664, 391888, 1 }, --
    apex_predators_craving             = { 71649, 391881, 1 }, --
    ashamanes_guidance                 = { 71658, 391548, 1 }, --
    astral_influence                   = { 71631, 197524, 2 }, --
    berserk                            = { 71657, 343223, 1 }, --
    berserk_frenzy                     = { 71651, 384668, 1 }, --
    berserk_heart_of_the_lion          = { 71671, 391174, 1 }, --
    bite_force                         = { 71666, 391972, 1 }, --
    bloodtalons                        = { 71666, 319439, 1 }, --
    brutal_slash                       = { 71686, 202028, 1 }, --
    carnivorous_instinct               = { 71672, 390902, 2 }, --
    cats_curiosity                     = { 71687, 386318, 2 }, --
    circle_of_life_and_death           = { 71660, 391969, 1 }, --
    convoke_the_spirits                = { 71659, 391528, 1 }, --
    cyclone                            = { 71604, 33786 , 1 }, --
    doubleclawed_rake                  = { 71668, 391700, 1 }, --
    dreadful_bleeding                  = { 71675, 391045, 1 }, --
    eye_of_fearful_symmetry            = { 71663, 391872, 2 }, --
    feline_swiftness                   = { 71648, 131768, 2 }, --
    feral_frenzy                       = { 71654, 274837, 1 }, --
    ferocious_frenzy                   = { 71685, 391709, 1 }, --
    frantic_momentum                   = { 71673, 391875, 1 }, --
    frenzied_regeneration              = { 71645, 22842 , 1 }, --
    furor                              = { 71609, 378986, 1 }, --
    heart_of_the_wild                  = { 71612, 319454, 1 }, --
    hibernate                          = { 71603, 2637  , 1 }, --
    improved_barkskin                  = { 71644, 327993, 1 }, --
    improved_bleeds                    = { 71679, 231063, 1 }, --
    improved_frenzied_regeneration_nnf = { 71602, 301768, 1 }, --
    improved_rejuvenation              = { 71627, 231040, 1 }, --
    improved_stampeding_roar           = { 71613, 288826, 1 }, --
    improved_sunfire                   = { 71608, 231050, 1 }, --
    incapacitating_roar                = { 71625, 99    , 1 }, --
    incarnation_avatar_of_ashamane     = { 71659, 102543, 1 }, --
    infected_wounds                    = { 71670, 48484 , 1 }, --
    innervate                          = { 71634, 29166 , 1 }, --
    ironfur                            = { 71621, 192081, 1 }, --
    killer_instinct                    = { 71619, 108299, 3 }, --
    lunar_inspiration                  = { 71655, 155580, 1 }, --
    lycaras_teachings                  = { 71614, 378988, 3 }, --
    maim                               = { 71606, 22570 , 1 }, --
    mass_entanglement                  = { 71633, 102359, 1 }, --
    mighty_bash                        = { 71625, 5211  , 1 }, --
    moment_of_clarity                  = { 71656, 236068, 1 }, --
    moonkin_form                       = { 71639, 24858 , 1 }, --
    natures_vigil                      = { 71635, 124974, 1 }, --
    new_resto_passive_nnf              = { 71629, 377796, 2 }, --
    nurturing_instinct                 = { 71640, 33873 , 3 }, --
    omen_of_clarity                    = { 71680, 16864 , 1 }, --
    piercing_claws                     = { 71652, 391037, 2 }, --
    pouncing_strikes                   = { 71653, 390772, 1 }, --
    predator                           = { 71683, 202021, 1 }, --
    predatory_swiftness                = { 71674, 16974 , 1 }, --
    primal_fury                        = { 71624, 159286, 1 }, --
    primal_wrath                       = { 71682, 285381, 1 }, --
    protective_growth                  = { 71650, 391947, 1 }, --
    raging_fury                        = { 71673, 391078, 1 }, --
    rake                               = { 71607, 1822  , 1 }, --
    rejuvenation                       = { 71643, 774   , 1 }, --
    remove_corruption                  = { 71556, 2782  , 1 }, --
    renewal                            = { 71611, 108238, 1 }, --
    rip                                = { 71647, 1079  , 1 }, --
    rip_and_tear                       = { 71688, 391347, 1 }, --
    sabertooth                         = { 71676, 202031, 1 }, --
    scent_of_blood                     = { 71667, 285564, 1 }, --
    skull_bash                         = { 71618, 106839, 1 }, --
    soothe                             = { 71617, 2908  , 1 }, --
    soul_of_the_forest                 = { 71661, 158476, 1 }, --
    stampeding_roar                    = { 71615, 106898, 1 }, --
    starfire                           = { 71637, 194153, 1 }, --
    starsurge                          = { 71636, 197626, 1 }, --
    sudden_ambush                      = { 71677, 384667, 2 }, --
    sunfire                            = { 71632, 93402 , 1 }, --
    survival_instincts                 = { 71662, 61336 , 1 }, --
    swiftmend                          = { 71642, 18562 , 1 }, --
    swipe                              = { 71620, 213764, 1 }, --
    taste_for_blood                    = { 71669, 384665, 2 }, --
    tear_open_wounds                   = { 71684, 391785, 1 }, --
    thick_hide                         = { 71622, 16931 , 2 }, --
    thrash                             = { 71646, 106832, 1 }, --
    tiger_dash                         = { 71616, 252216, 1 }, --
    tigers_fury                        = { 71681, 5217  , 1 }, --
    tireless_energy                    = { 71678, 383352, 2 }, --
    tireless_pursuit                   = { 71605, 377801, 1 }, --
    typhoon                            = { 71630, 132469, 1 }, --
    unbridled_swarm                    = { 71665, 391951, 2 }, --
    ursine_vigor                       = { 71610, 377842, 2 }, --
    ursocs_endurance_nnf               = { 71623, 385786, 1 }, --
    ursols_vortex                      = { 71633, 102793, 1 }, --
    veinripper                         = { 71688, 391978, 1 }, --
    wellhoned_instincts                = { 71626, 377847, 2 }, --
    wild_charge                        = { 71616, 102401, 1 }, --
    wild_growth                        = { 71628, 48438 , 1 }, --
    wild_slashes                       = { 71686, 390864, 1 }, --
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


    primal_wrath = {
        id = 285381,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 5,
        spendType = "combo_points",

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

        spend = 50,
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

spec:RegisterPriority( "Guardian", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )