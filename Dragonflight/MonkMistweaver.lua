-- MonkMistweaver.lua
-- September 2022

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 270 )

spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.Chi )

-- Talents
spec:RegisterTalents( {
    anvil__stave                 = { 76506, 386937, 2 }, --
    attenuation                  = { 76526, 386941, 1 }, --
    black_ox_brew                = { 76516, 115399, 1 }, --
    blackout_combo               = { 76497, 196736, 1 }, --
    bob_and_weave                = { 76516, 280515, 1 }, --
    bonedust_brew                = { 76527, 386276, 1 }, --
    bounce_back                  = { 76379, 389577, 2 }, --
    bountiful_brew               = { 76526, 386949, 1 }, --
    breath_of_fire               = { 76521, 115181, 1 }, --
    call_to_arms                 = { 76504, 356684, 1 }, --
    calming_presence             = { 76411, 388664, 1 }, --
    celerity                     = { 76407, 115173, 1 }, --
    celestial_brew               = { 76496, 322507, 1 }, --
    celestial_brew_2             = { 76495, 322510, 1 }, --
    celestial_flames             = { 76520, 325177, 1 }, --
    charred_passions             = { 76522, 386965, 1 }, --
    chi_burst                    = { 76387, 123986, 1 }, --
    chi_torpedo                  = { 76407, 115008, 1 }, --
    chi_wave                     = { 76387, 115098, 1 }, --
    clash                        = { 76499, 324312, 1 }, --
    close_to_heart               = { 76389, 389574, 2 }, --
    counterstrike                = { 76503, 383785, 1 }, --
    dampen_harm                  = { 76396, 122278, 1 }, --
    detox                        = { 76410, 218164, 1 }, --
    diffuse_magic                = { 76386, 122783, 1 }, --
    disable                      = { 76375, 116095, 1 }, --
    dragonfire_brew              = { 76522, 383994, 1 }, --
    effusive_anima_accelerator   = { 76504, 352188, 1 }, --
    elusive_footwork             = { 76498, 387046, 2 }, --
    elusive_mists                = { 76384, 388681, 2 }, --
    escape_from_reality          = { 76392, 343250, 2 }, --
    exploding_keg                = { 76530, 325153, 1 }, --
    eye_of_the_tiger             = { 76394, 196607, 1 }, --
    face_palm                    = { 76502, 389942, 1 }, --
    fast_feet                    = { 76397, 388809, 2 }, --
    fatal_touch                  = { 76405, 337296, 2 }, --
    ferocity_of_xuen             = { 76409, 388674, 2 }, --
    fluidity_of_motion           = { 76501, 387230, 1 }, --
    fortifying_brew              = { 76377, 115203, 1 }, --
    fortifying_brew_cooldown     = { 76382, 388813, 1 }, --
    fortifying_brew_stagger      = { 76525, 322960, 1 }, --
    fortifying_brew_armor        = { 76382, 322960, 1 }, --
    fundamental_observation      = { 76494, 387035, 1 }, --
    gai_plins_imperial_brew      = { 76533, 383700, 1 }, --
    generous_pour                = { 76380, 389575, 2 }, --
    gift_of_the_ox               = { 76510, 124502, 2 }, --
    grace_of_the_crane           = { 76400, 388811, 2 }, --
    graceful_exit                = { 76515, 387256, 2 }, --
    healing_elixir               = { 76512, 122281, 1 }, --
    high_tolerance               = { 76524, 196737, 2 }, --
    hit_scheme                   = { 76519, 383695, 1 }, --
    invoke_niuzao_the_black_ox   = { 76532, 132578, 1 }, --
    invoke_niuzao_the_black_ox_2 = { 76528, 322740, 1 }, --
    keg_smash                    = { 76508, 121253, 1 }, --
    light_brewing                = { 76507, 325093, 1 }, --
    paralysis                    = { 76374, 115078, 1 }, --
    paralysis_2                  = { 76376, 344359, 1 }, --
    profound_rebuttal            = { 76388, 392910, 1 }, --
    provoke_2                    = { 76385, 328670, 1 }, --
    purifying_brew               = { 76511, 119582, 1 }, --
    purifying_brew_2             = { 76517, 343743, 1 }, --
    quick_sip                    = { 76514, 388505, 2 }, --
    resonant_fists               = { 76404, 389578, 2 }, --
    ring_of_peace                = { 76395, 116844, 1 }, --
    rising_sun_kick              = { 76372, 107428, 1 }, --
    roll                         = { 76402, 109132, 1 }, --
    rushing_jade_wind            = { 76535, 116847, 1 }, --
    salsalabims_strength         = { 76523, 383697, 1 }, --
    save_them_all                = { 76391, 389579, 2 }, --
    scalding_brew                = { 76523, 383698, 1 }, --
    shadowboxing_treads          = { 76501, 387638, 1 }, --
    shocking_blow_nyi            = { 76500, 389982, 1 }, --
    shuffle                      = { 76513, 322120, 1 }, --
    soothing_mist                = { 76412, 115175, 1 }, --
    spear_hand_strike            = { 76408, 116705, 1 }, --
    special_delivery             = { 76535, 196730, 1 }, --
    stagger                      = { 76509, 115069, 1 }, --
    staggering_strikes           = { 76518, 387625, 2 }, --
    stormstouts_last_keg         = { 76529, 383707, 1 }, --
    strength_of_spirit           = { 76381, 387276, 1 }, --
    strength_of_spirit_2         = { 76533, 387276, 1 }, --
    summon_black_ox_statue       = { 76378, 115315, 1 }, --
    summon_jade_serpent_statue   = { 76390, 115313, 1 }, --
    summon_white_tiger_statue    = { 76403, 388686, 1 }, --
    tiger_tail_sweep             = { 76383, 264348, 2 }, --
    tigers_lust                  = { 76373, 116841, 1 }, --
    touch_of_death_2             = { 76406, 322113, 1 }, --
    training_of_niuzao           = { 76507, 383714, 1 }, --
    transcendence                = { 76398, 101643, 1 }, --
    vigorous_expulsion           = { 76401, 392900, 1 }, --
    vivacious_vivification       = { 76399, 388812, 1 }, --
    vivify_2                     = { 76371, 231602, 2 }, --
    walk_with_the_ox             = { 76531, 387219, 2 }, --
    weapons_of_order             = { 76505, 387184, 1 }, --
    windwalking                  = { 76393, 157411, 2 }, --
    zen_meditation               = { 76534, 115176, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    alpha_tiger          = 5551, -- 287503
    chrysalis            = 678 , -- 202424
    counteract_magic     = 679 , -- 353502
    dematerialize        = 5398, -- 353361
    dome_of_mist         = 680 , -- 202577
    eminence             = 70  , -- 353584
    grapple_weapon       = 3732, -- 233759
    healing_sphere       = 683 , -- 205234
    mighty_ox_kick       = 5539, -- 202370
    peaceweaver          = 5395, -- 353313
    precognition         = 5508, -- 377360
    refreshing_breeze    = 682 , -- 353508
    thunderous_focus_tea = 5402, -- 353936
    zen_focus_tea        = 1928, -- 209584
} )


-- Auras
spec:RegisterAuras( {
    accumulating_mist = {
        id = 388566,
        duration = 30,
        max_stack = 6
    },
    bonedust_brew = {
        id = 386276,
        duration = 10,
        max_stack = 1
    },
    bounce_back = {
        id = 390239,
        duration = 4,
        max_stack = 1
    },
    calming_coalescence = {
        id = 388220,
        duration = 3600,
        max_stack = 50
    },
    chi_burst = { -- TODO: Hidden aura that procs Chi per enemy targeted.
        id = 123986,
        duration = 1,
        max_stack = 1
    },
    chi_torpedo = { -- Movement buff.
        id = 119085,
        duration = 10,
        max_stack = 2
    },
    --[[ chi_torpedo_115008 = { -- TODO: Actual duration of a Chi Torpedo roll?
        id = 115008,
        duration = 1.1,
        max_stack = 1
    }, ]]
    clouded_focus = {
        id = 388048,
        duration = 8,
        max_stack = 3
    },
    crackling_jade_lightning = {
        id = 117952,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    dampen_harm = {
        id = 122278,
        duration = 10,
        max_stack = 1
    },
    diffuse_magic = {
        id = 122783,
        duration = 6,
        max_stack = 1
    },
    disable = {
        id = 116095,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    enveloping_mist = {
        id = 124682,
        duration = 6,
        tick_time = 1,
        max_stack = 1
    },
    essence_font = {
        id = 191840,
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    eye_of_the_tiger = {
        id = 196608,
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    fae_exposure_buff = {
        id = 356774,
        duration = 10,
        max_stack = 1,
        friendly = true
    },
    fae_exposure_debuff = {
        id = 356773,
        duration = 10,
        max_stack = 1
    },
    faeline_stomp = {
        id = 388193,
        duration = 30,
        max_stack = 1
    },
    fatal_flying_guillotine = {
        id = 331679,
        duration = 3600,
        max_stack = 1
    },
    fatal_touch = {
        id = 337296,
        duration = 3600,
        max_stack = 1
    },
    fists_of_fury = {
        id = 113656,
        duration = 4,
        tick_time = 0.166,
        max_stack = 1
    },
    fists_of_fury_stun = {
        id = 120086,
        duration = 4,
        max_stack = 1
    },
    flying_serpent_kick = { -- TODO: May want to generate this from cast time, to enable stopping again.
        id = 101545,
        duration = 1.5,
        max_stack = 1
    },
    grapple_weapon = {
        id = 233759,
        duration = 6,
        max_stack = 1
    },
    invoke_chiji_the_red_crane = { -- TODO: Is a totem.
        id = 325197,
        duration = 25,
        max_stack = 1
    },
    invoke_yulon_the_jade_serpent = { -- TODO: Is a totem.
        id = 322118,
        duration = 25,
        tick_time = 1,
        max_stack = 1
    },
    invokers_delight = {
        id = 388663,
        duration = 20,
        max_stack = 1
    },
    leg_sweep = {
        id = 119381,
        duration = 3,
        max_stack = 1
    },
    life_cocoon = {
        id = 116849,
        duration = 12,
        max_stack = 1
    },
    mana_tea = {
        id = 197908,
        duration = 10,
        max_stack = 1
    },
    mark_of_the_crane = {
        id = 228287,
        duration = 20,
        max_stack = 1
    },
    overflowing_mists = {
        id = 388513,
        duration = 6,
        max_stack = 1
    },
    paralysis = {
        id = 115078,
        duration = 60,
        max_stack = 1
    },
    refreshing_jade_wind = {
        id = 196725,
        duration = 9,
        tick_time = 0.75,
        max_stack = 1
    },
    ring_of_peace = {
        id = 116844,
        duration = 5,
        max_stack = 1
    },
    rushing_jade_wind = {
        id = 116847,
        duration = 6,
        tick_time = 0.75,
        max_stack = 1
    },
    secret_infusion = {
        alias = { "secret_infusion_critical_strike", "secret_infusion_haste", "secret_infusion_mastery", "secret_infusion_versatility" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = 10,
    },
    secret_infusion_critical_strike = {
        id = 388498,
        duration = 10,
        max_stack = 1
    },
    secret_infusion_haste = {
        id = 388497,
        duration = 10,
        max_stack = 1
    },
    secret_infusion_mastery = {
        id = 388499,
        duration = 10,
        max_stack = 1
    },
    secret_infusion_versatility = {
        id = 388500,
        duration = 10,
        max_stack = 1
    },
    serenity = {
        id = 152173,
        duration = 12,
        max_stack = 1
    },
    sign_of_the_emissary = {
        id = 225788,
        duration = 3600,
        max_stack = 1
    },
    song_of_chiji = {
        id = 198909,
        duration = 20,
        max_stack = 1
    },
    soothing_mist = {
        id = 115175,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    spinning_crane_kick = {
        id = 101546,
        duration = 1.5,
        tick_time = 0.5,
        max_stack = 1
    },
    storm_earth_and_fire = {
        id = 137639,
        duration = 15,
        max_stack = 2
    },
    strike_of_the_windlord = {
        id = 392983,
        duration = 6,
        max_stack = 1
    },
    summon_black_ox_statue = { -- TODO: Is a totem.
        id = 115315,
        duration = 900,
        max_stack = 1
    },
    summon_jade_serpent_statue = { -- TODO: Is a totem.
        id = 115313,
        duration = 900,
        max_stack = 1
    },
    summon_white_tiger_statue = { -- TODO: Is a totem.
        id = 388686,
        duration = 30,
        max_stack = 1
    },
    thunder_focus_tea = {
        id = 116680,
        duration = 30,
        max_stack = 1
    },
    tigers_lust = {
        id = 116841,
        duration = 6,
        max_stack = 1
    },
    touch_of_karma = {
        id = 122470,
        duration = 10,
        max_stack = 1
    },
    transcendence = {
        id = 101643,
        duration = 900,
        max_stack = 1
    },
    vivacious_vivification = {
        id = 392883,
        duration = 3600,
        max_stack = 1
    },
    whirling_dragon_punch = { -- TODO: This is animation time, really.
        id = 152175,
        duration = 1,
        tick_time = 0.25,
        max_stack = 1
    },
    yulons_whisper = { -- TODO: If needed, this would be triggered by TFT cast.
        id = 388040,
        duration = 2,
        tick_time = 1,
        max_stack = 1
    },
    zen_flight = {
        id = 125883,
        duration = 3600,
        max_stack = 1
    },
    zen_focus_tea = {
        id = 209584,
        duration = 5,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    black_ox_brew = {
        id = 115399,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "black_ox_brew",
        startsCombat = false,
        texture = 629483,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    blackout_kick = {
        id = 100784,
        cast = 0,
        cooldown = 3,
        gcd = "spell",

        spend = 0,
        spendType = "chi",

        startsCombat = true,
        texture = 574575,

        handler = function ()
        end,
    },


    bonedust_brew = {
        id = 386276,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        talent = "bonedust_brew",
        startsCombat = false,
        texture = 3578227,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    breath_of_fire = {
        id = 115181,
        cast = 0,
        cooldown = 15,
        gcd = "totem",

        talent = "breath_of_fire",
        startsCombat = false,
        texture = 615339,

        handler = function ()
        end,
    },


    call_to_arms = {
        id = 356684,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "call_to_arms",
        startsCombat = false,
        texture = 3565447,

        handler = function ()
        end,
    },


    celestial_brew = {
        id = 322507,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        talent = "celestial_brew",
        startsCombat = false,
        texture = 1360979,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    chi_burst = {
        id = 123986,
        cast = 1,
        cooldown = 30,
        gcd = "spell",

        talent = "chi_burst",
        startsCombat = false,
        texture = 135734,

        handler = function ()
        end,
    },


    chi_torpedo = {
        id = 115008,
        cast = 0,
        charges = 1,
        cooldown = 20,
        recharge = 20,
        gcd = "off",

        talent = "chi_torpedo",
        startsCombat = false,
        texture = 607849,

        handler = function ()
        end,
    },


    chi_wave = {
        id = 115098,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        talent = "chi_wave",
        startsCombat = false,
        texture = 606541,

        handler = function ()
        end,
    },


    clash = {
        id = 324312,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        talent = "clash",
        startsCombat = false,
        texture = 628134,

        handler = function ()
        end,
    },


    crackling_jade_lightning = {
        id = 117952,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "energy",

        startsCombat = true,
        texture = 606542,

        handler = function ()
        end,
    },


    dampen_harm = {
        id = 122278,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "dampen_harm",
        startsCombat = false,
        texture = 620827,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    detox = {
        id = 115450,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "detox",
        startsCombat = false,
        texture = 460692,

        handler = function ()
        end,
    },


    diffuse_magic = {
        id = 122783,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "diffuse_magic",
        startsCombat = false,
        texture = 775460,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    disable = {
        id = 116095,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "disable",
        startsCombat = false,
        texture = 132316,

        handler = function ()
        end,
    },


    expel_harm = {
        id = 322101,
        cast = 0,
        cooldown = 15,
        gcd = "totem",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 627486,

        handler = function ()
        end,
    },


    exploding_keg = {
        id = 325153,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        talent = "exploding_keg",
        startsCombat = false,
        texture = 644378,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    fatal_touch = {
        id = 337296,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "fatal_touch",
        startsCombat = false,
        texture = 606552,

        handler = function ()
        end,
    },


    fortifying_brew = {
        id = 115203,
        cast = 0,
        cooldown = 360,
        gcd = "off",

        talent = "fortifying_brew",
        startsCombat = false,
        texture = 615341,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    grapple_weapon = {
        id = 233759,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        pvptalent = "grapple_weapon",
        startsCombat = false,
        texture = 132343,

        handler = function ()
        end,
    },


    healing_elixir = {
        id = 122281,
        cast = 0,
        charges = 2,
        cooldown = 30,
        recharge = 30,
        gcd = "off",

        talent = "healing_elixir",
        startsCombat = false,
        texture = 608939,

        handler = function ()
        end,
    },


    healing_sphere = {
        id = 205234,
        cast = 0,
        charges = 3,
        cooldown = 15,
        recharge = 15,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        pvptalent = "healing_sphere",
        startsCombat = false,
        texture = 606546,

        handler = function ()
        end,
    },


    invoke_niuzao_the_black_ox = {
        id = 132578,
        cast = 0,
        cooldown = 180,
        gcd = "totem",

        talent = "invoke_niuzao_the_black_ox",
        startsCombat = false,
        texture = 608951,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    keg_smash = {
        id = 121253,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "totem",

        spend = 40,
        spendType = "energy",

        talent = "keg_smash",
        startsCombat = false,
        texture = 594274,

        handler = function ()
        end,
    },


    leg_sweep = {
        id = 119381,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        startsCombat = true,
        texture = 642414,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    mighty_ox_kick = {
        id = 202370,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        pvptalent = "mighty_ox_kick",
        startsCombat = false,
        texture = 1381297,

        handler = function ()
        end,
    },


    paralysis = {
        id = 115078,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0,
        spendType = "energy",

        talent = "paralysis",
        startsCombat = false,
        texture = 629534,

        handler = function ()
        end,
    },


    provoke = {
        id = 115546,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 620830,

        handler = function ()
        end,
    },


    purifying_brew = {
        id = 119582,
        cast = 0,
        charges = 1,
        cooldown = 20,
        recharge = 20,
        gcd = "off",

        talent = "purifying_brew",
        startsCombat = false,
        texture = 133701,

        handler = function ()
        end,
    },


    reawaken = {
        id = 212051,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 1056569,

        handler = function ()
        end,
    },


    resuscitate = {
        id = 115178,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 132132,

        handler = function ()
        end,
    },


    ring_of_peace = {
        id = 116844,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "ring_of_peace",
        startsCombat = false,
        texture = 839107,

        handler = function ()
        end,
    },


    rising_sun_kick = {
        id = 107428,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "rising_sun_kick",
        startsCombat = false,
        texture = 642415,

        handler = function ()
        end,
    },


    roll = {
        id = 109132,
        cast = 0,
        charges = 1,
        cooldown = 20,
        recharge = 20,
        gcd = "off",

        talent = "roll",
        startsCombat = false,
        texture = 574574,

        handler = function ()
        end,
    },


    rushing_jade_wind = {
        id = 116847,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 0,
        spendType = "chi",

        talent = "rushing_jade_wind",
        startsCombat = false,
        texture = 606549,

        handler = function ()
        end,
    },


    soothing_mist = {
        id = 115175,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 0,
        spendType = "mana",

        talent = "soothing_mist",
        startsCombat = false,
        texture = 606550,

        handler = function ()
        end,
    },


    spear_hand_strike = {
        id = 116705,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        talent = "spear_hand_strike",
        startsCombat = false,
        texture = 608940,

        handler = function ()
        end,
    },


    spinning_crane_kick = {
        id = 101546,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "chi",

        startsCombat = false,
        texture = 606543,

        handler = function ()
        end,
    },


    summon_black_ox_statue = {
        id = 115315,
        cast = 0,
        cooldown = 10,
        gcd = "totem",

        talent = "summon_black_ox_statue",
        startsCombat = false,
        texture = 627607,

        handler = function ()
        end,
    },


    summon_jade_serpent_statue = {
        id = 115313,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        talent = "summon_jade_serpent_statue",
        startsCombat = false,
        texture = 620831,

        handler = function ()
        end,
    },


    summon_white_tiger_statue = {
        id = 388686,
        cast = 0,
        cooldown = 120,
        gcd = "totem",

        talent = "summon_white_tiger_statue",
        startsCombat = false,
        texture = 4667418,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    tiger_palm = {
        id = 100780,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "energy",

        startsCombat = true,
        texture = 606551,

        handler = function ()
        end,
    },


    tigers_lust = {
        id = 116841,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "tigers_lust",
        startsCombat = false,
        texture = 651727,

        handler = function ()
        end,
    },


    touch_of_death = {
        id = 322109,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = true,
        texture = 606552,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    transcendence = {
        id = 101643,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        talent = "transcendence",
        startsCombat = false,
        texture = 627608,

        handler = function ()
        end,
    },


    vivify = {
        id = 116670,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "energy",

        startsCombat = false,
        texture = 1360980,

        handler = function ()
        end,
    },


    weapons_of_order = {
        id = 387184,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        talent = "weapons_of_order",
        startsCombat = false,
        texture = 3565447,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    zen_flight = {
        id = 125883,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        startsCombat = false,
        texture = 660248,

        handler = function ()
        end,
    },


    zen_focus_tea = {
        id = 209584,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        pvptalent = "zen_focus_tea",
        startsCombat = false,
        texture = 651940,

        handler = function ()
        end,
    },


    zen_meditation = {
        id = 115176,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        talent = "zen_meditation",
        startsCombat = false,
        texture = 642417,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    zen_pilgrimage = {
        id = 126892,
        cast = 10,
        cooldown = 60,
        gcd = "totem",

        startsCombat = false,
        texture = 775462,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Mistweaver", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )