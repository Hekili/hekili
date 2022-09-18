-- DruidBalance.lua
-- September 2022

if UnitClassBase( "player" ) ~= "DRUID" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 102 )

spec:RegisterResource( Enum.PowerType.Rage )
spec:RegisterResource( Enum.PowerType.LunarPower )
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

-- Talents
spec:RegisterTalents( {
    adaptive_swarm                     = { 71739, 325727, 1 }, --
    astral_influence                   = { 71631, 197524, 2 }, --
    balance_of_all_things              = { 71739, 339942, 1 }, --
    blessing_of_anshe                  = { 71737, 202739, 1 }, --
    blessing_of_elune                  = { 71737, 202737, 1 }, --
    celestial_alignment                = { 71755, 194223, 1 }, --
    circle_of_life_and_death           = { 71746, 338657, 2 }, --
    convoke_the_spirits                = { 71731, 323764, 1 }, --
    cyclone                            = { 71604, 33786 , 1 }, --
    eclipse                            = { 71752, 79577 , 1 }, --
    feline_swiftness                   = { 71648, 131768, 2 }, --
    force_of_nature                    = { 71750, 205636, 1 }, --
    frenzied_regeneration              = { 71645, 22842 , 1 }, --
    furor                              = { 71609, 378986, 1 }, --
    fury_of_elune                      = { 71727, 202770, 1 }, --
    fury_of_the_skies                  = { 71732, 384656, 2 }, --
    heart_of_the_wild                  = { 71612, 319454, 1 }, --
    hibernate                          = { 71603, 2637  , 1 }, --
    improved_barkskin                  = { 71644, 327993, 1 }, --
    improved_eclipse                   = { 71751, 328021, 2 }, --
    improved_frenzied_regeneration_nnf = { 71602, 301768, 1 }, --
    improved_moonfire                  = { 71753, 328023, 2 }, --
    improved_rejuvenation              = { 71627, 231040, 1 }, --
    improved_stampeding_roar           = { 71613, 288826, 1 }, --
    improved_starsurge                 = { 71734, 328022, 1 }, --
    improved_sunfire                   = { 71608, 231050, 1 }, --
    incapacitating_roar                = { 71625, 99    , 1 }, --
    incarnation_chosen_of_elune        = { 71731, 102560, 1 }, --
    innervate                          = { 71634, 29166 , 1 }, --
    ironfur                            = { 71621, 192081, 1 }, --
    killer_instinct                    = { 71619, 108299, 3 }, --
    light_of_the_sun                   = { 71601, 202918, 1 }, --
    lycaras_teachings                  = { 71614, 378988, 3 }, --
    maim                               = { 71606, 22570 , 1 }, --
    mass_entanglement                  = { 71633, 102359, 1 }, --
    mighty_bash                        = { 71625, 5211  , 1 }, --
    modal_cooldown_bonus_nyi           = { 71730, 0     , 1 }, --
    moonkin_form                       = { 71639, 24858 , 1 }, --
    natures_balance                    = { 71748, 202430, 2 }, --
    natures_vigil                      = { 71635, 124974, 1 }, --
    new_moon                           = { 71727, 274281, 1 }, --
    new_resto_passive_nnf              = { 71629, 377796, 2 }, --
    nurturing_instinct                 = { 71640, 33873 , 3 }, --
    oneths_clear_vision_nnf            = { 71738, 338661, 1 }, --
    orbit_breaker                      = { 71740, 383197, 1 }, --
    owlkin_frenzy                      = { 71747, 231042, 1 }, --
    power_of_goldrinn                  = { 71757, 202996, 2 }, --
    precise_alignment                  = { 71744, 340706, 1 }, --
    primal_fury                        = { 71624, 159286, 1 }, --
    primordial_arcanic_pulsar          = { 71741, 338668, 1 }, --
    rake                               = { 71607, 1822  , 1 }, --
    rejuvenation                       = { 71643, 774   , 1 }, --
    remove_corruption                  = { 71558, 2782  , 1 }, --
    renewal                            = { 71611, 108238, 1 }, --
    rip                                = { 71647, 1079  , 1 }, --
    shooting_stars                     = { 71742, 202342, 1 }, --
    skull_bash                         = { 71618, 106839, 1 }, --
    solar_beam                         = { 71756, 78675 , 1 }, --
    solstice                           = { 71745, 343647, 2 }, --
    soothe                             = { 71617, 2908  , 1 }, --
    soul_of_the_forest                 = { 71729, 114107, 1 }, --
    stampeding_roar                    = { 71615, 106898, 1 }, --
    starfall                           = { 71749, 191034, 1 }, --
    starfall_2                         = { 71735, 327541, 2 }, --
    starfire                           = { 71637, 194153, 1 }, --
    starlord                           = { 71743, 202345, 2 }, --
    starsurge                          = { 71638, 78674 , 1 }, --
    stellar_drift                      = { 71736, 202354, 1 }, --
    stellar_flare                      = { 71759, 202347, 1 }, --
    stellar_inspiration                = { 71733, 383194, 2 }, --
    sunfire                            = { 71632, 93402 , 1 }, --
    swiftmend                          = { 71642, 18562 , 1 }, --
    swipe                              = { 71620, 213764, 1 }, --
    syzygy                             = { 71741, 390378, 1 }, --
    thick_hide                         = { 71622, 16931 , 2 }, --
    thrash                             = { 71646, 106832, 1 }, --
    tiger_dash                         = { 71616, 252216, 1 }, --
    timeworn_dreambinder_nnf           = { 71738, 339949, 1 }, --
    tireless_pursuit                   = { 71605, 377801, 1 }, --
    twin_moons                         = { 71759, 279620, 1 }, --
    typhoon                            = { 71630, 132469, 1 }, --
    umbral_infusion_nnf                = { 71728, 383196, 2 }, --
    umbral_intensity                   = { 71758, 383195, 2 }, --
    ursine_vigor                       = { 71610, 377842, 2 }, --
    ursocs_endurance_nnf               = { 71623, 385786, 1 }, --
    ursols_vortex                      = { 71633, 102793, 1 }, --
    warrior_of_elune                   = { 71754, 202425, 1 }, --
    wellhoned_instincts                = { 71626, 377847, 2 }, --
    wild_charge                        = { 71616, 102401, 1 }, --
    wild_growth                        = { 71628, 48438 , 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    celestial_guardian     = 180 , -- 233754
    crescent_burn          = 182 , -- 200567
    deep_roots             = 834 , -- 233755
    dying_stars            = 822 , -- 232546
    faerie_swarm           = 836 , -- 209749
    high_winds             = 5383, -- 200931
    malornes_swiftness     = 5515, -- 236147
    moon_and_stars         = 184 , -- 233750
    moonkin_aura           = 185 , -- 209740
    owlkin_adept           = 5407, -- 354541
    precognition           = 5503, -- 377360
    protector_of_the_grove = 3728, -- 209730
    reactive_resin         = 5526, -- 203399
    star_burst             = 3058, -- 356517
    thorns                 = 3731, -- 305497
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
    blessing_of_anshe = {
        id = 202739,
        duration = 3600,
        tick_time = 3,
        max_stack = 1
    },
    blessing_of_elune = {
        id = 202737,
        duration = 3600,
        max_stack = 1
    },
    cat_form = {
        id = 768,
        duration = 3600,
        max_stack = 1
    },
    celestial_alignment = {
        id = 194223,
        duration = 20,
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
    entangling_roots = {
        id = 339,
        duration = 30,
        tick_time = 2,
        max_stack = 1
    },
    faerie_swarm = {
        id = 209749,
        duration = 5,
        max_stack = 1
    },
    force_of_nature = { -- TODO: Is a totem?  Summon?
        id = 248280,
        duration = 10,
        max_stack = 1
    },
    frenzied_regeneration = {
        id = 22842,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    fury_of_elune = {
        id = 202770,
        duration = 8,
        tick_time = 0.5,
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
    incarnation_chosen_of_elune = {
        id = 102560,
        duration = 30,
        max_stack = 1,
        copy = "incarnation"
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
    solar_beam = { -- Silence.
        id = 78675,
        duration = 8,
        max_stack = 1
    },
    solstice = {
        id = 343648,
        duration = 6,
        max_stack = 1
    },
    stampeding_roar = {
        id = 106898,
        duration = 8,
        max_stack = 1
    },
    starfall = {
        id = 393040,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    stellar_flare = {
        id = 202347,
        duration = 24,
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
    timeworn_dreambinder = {
        id = 340049,
        duration = 5,
        max_stack = 2
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
    warrior_of_elune = {
        id = 202425,
        duration = 3600,
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
        id = 325727,
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


    blessing_of_anshe = {
        id = 202739,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "blessing_of_anshe",
        startsCombat = false,
        texture = 608954,

        handler = function ()
        end,
    },


    blessing_of_elune = {
        id = 202737,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "blessing_of_elune",
        startsCombat = false,
        texture = 236704,

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


    celestial_alignment = {
        id = 194223,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "celestial_alignment",
        startsCombat = false,
        texture = 136060,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    convoke_the_spirits = {
        id = 323764,
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


    faerie_swarm = {
        id = 209749,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        pvptalent = "faerie_swarm",
        startsCombat = false,
        texture = 538516,

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


    force_of_nature = {
        id = 205636,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "force_of_nature",
        startsCombat = false,
        texture = 132129,

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


    fury_of_elune = {
        id = 202770,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "fury_of_elune",
        startsCombat = false,
        texture = 132123,

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


    incarnation_chosen_of_elune = {
        id = 102560,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "incarnation_chosen_of_elune",
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


    new_moon = {
        id = 274281,
        cast = 1,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "totem",

        talent = "new_moon",
        startsCombat = false,
        texture = 1392545,

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


    solar_beam = {
        id = 78675,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0.17,
        spendType = "mana",

        talent = "solar_beam",
        startsCombat = false,
        texture = 252188,

        toggle = "cooldowns",

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


    starfall = {
        id = 191034,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 50,
        spendType = "lunar_power",

        talent = "starfall",
        startsCombat = false,
        texture = 236168,

        handler = function ()
        end,
    },


    starfire = {
        id = 194153,
        cast = 2.25,
        cooldown = 0,
        gcd = "spell",

        talent = "starfire",
        startsCombat = true,
        texture = 135753,

        handler = function ()
        end,
    },


    starsurge = {
        id = 78674,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "lunar_power",

        talent = "starsurge",
        startsCombat = true,
        texture = 135730,

        handler = function ()
        end,
    },


    stellar_flare = {
        id = 202347,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        talent = "stellar_flare",
        startsCombat = false,
        texture = 1052602,

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


    warrior_of_elune = {
        id = 202425,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        talent = "warrior_of_elune",
        startsCombat = false,
        texture = 135900,

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
        id = 190984,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 535045,

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Balance", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )