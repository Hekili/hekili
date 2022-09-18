-- MonkWindwalker.lua
-- September 2022

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 269 )

spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Energy )
spec:RegisterResource( Enum.PowerType.Chi )

-- Talents
spec:RegisterTalents( {
    ascension                      = { 76460, 115396, 1 }, --
    attenuation                    = { 76449, 386941, 1 }, --
    bone_marrow_hops               = { 76482, 392987, 1 }, --
    bonedust_brew                  = { 76483, 386276, 1 }, --
    bounce_back                    = { 76379, 389577, 2 }, --
    calming_presence               = { 76411, 388664, 1 }, --
    celerity                       = { 76407, 115173, 1 }, --
    chi_burst                      = { 76387, 123986, 1 }, --
    chi_torpedo                    = { 76407, 115008, 1 }, --
    chi_wave                       = { 76387, 115098, 1 }, --
    close_to_heart                 = { 76389, 389574, 2 }, --
    crane_vortex                   = { 76484, 388848, 2 }, --
    dampen_harm                    = { 76396, 122278, 1 }, --
    dance_of_chiji                 = { 76465, 325201, 1 }, --
    detox                          = { 76410, 218164, 1 }, --
    diffuse_magic                  = { 76386, 122783, 1 }, --
    disable                        = { 76375, 116095, 1 }, --
    drinking_horn_cover            = { 76481, 391370, 1 }, --
    elusive_mists                  = { 76384, 388681, 2 }, --
    empowered_tiger_lightning      = { 76492, 335913, 1 }, --
    escape_from_reality            = { 76392, 343250, 2 }, --
    eye_of_the_tiger               = { 76394, 196607, 1 }, --
    faeline_harmony                = { 76475, 391412, 1 }, --
    faeline_stomp                  = { 76476, 388193, 1 }, --
    fast_feet                      = { 76397, 388809, 2 }, --
    fatal_flying_guillotine        = { 76485, 331679, 1 }, --
    fatal_touch                    = { 76405, 337296, 2 }, --
    feathers_of_a_hundred_flocks   = { 76454, 388846, 1 }, --
    ferocity_of_xuen               = { 76409, 388674, 2 }, --
    fists_of_fury                  = { 76458, 113656, 1 }, --
    flashing_fists                 = { 76468, 388854, 2 }, --
    flying_serpent_kick            = { 76467, 101545, 1 }, --
    fortifying_brew                = { 76377, 115203, 1 }, --
    fortifying_brew_cooldown       = { 76382, 388813, 1 }, --
    fortifying_brew_stagger        = { 76382, 322960, 1 }, --
    fury_of_xuen                   = { 76450, 287055, 1 }, --
    generous_pour                  = { 76380, 389575, 2 }, --
    glory_of_the_dawn              = { 76469, 392958, 1 }, --
    grace_of_the_crane             = { 76400, 388811, 2 }, --
    hardened_soles                 = { 76459, 391383, 2 }, --
    hidden_masters_forbidden_touch = { 76453, 213112, 1 }, --
    hit_combo                      = { 76452, 196740, 1 }, --
    inner_peace                    = { 76466, 195243, 1 }, --
    invoke_xuen_the_white_tiger    = { 76493, 123904, 1 }, --
    invokers_delight               = { 76490, 388661, 1 }, --
    jade_ignition                  = { 76470, 392979, 1 }, --
    keefers_skyreach               = { 76488, 392991, 1 }, --
    last_emperors_capacitor        = { 76487, 392989, 1 }, --
    mark_of_the_crane              = { 76462, 228287, 1 }, --
    meridian_strikes               = { 76480, 391330, 1 }, --
    open_palm_strikes              = { 76456, 392970, 1 }, --
    paralysis                      = { 76374, 115078, 1 }, --
    paralysis_cooldown             = { 76376, 344359, 1 }, --
    power_strikes                  = { 76457, 121817, 1 }, --
    profound_rebuttal              = { 76388, 392910, 1 }, --
    provoke                        = { 76385, 328670, 1 }, --
    resonant_fists                 = { 76404, 389578, 2 }, --
    ring_of_peace                  = { 76395, 116844, 1 }, --
    rising_star                    = { 76477, 388849, 2 }, --
    rising_sun_kick                = { 76372, 107428, 1 }, --
    roll                           = { 76402, 109132, 1 }, --
    rushing_jade_wind              = { 76464, 116847, 1 }, --
    save_them_all                  = { 76391, 389579, 2 }, --
    serenity                       = { 76451, 152173, 1 }, --
    shadowboxing_treads            = { 76463, 392982, 1 }, --
    soothing_mist                  = { 76412, 115175, 1 }, --
    spear_hand_strike              = { 76408, 116705, 1 }, --
    spiritual_focus                = { 76479, 280197, 1 }, --
    storm_earth_and_fire           = { 76451, 137639, 1 }, --
    strength_of_spirit             = { 76381, 387276, 1 }, --
    strike_of_the_windlord         = { 76471, 392983, 1 }, --
    summon_black_ox_statue         = { 76378, 115315, 1 }, --
    summon_jade_serpent_statue     = { 76390, 115313, 1 }, --
    summon_white_tiger_statue      = { 76403, 388686, 1 }, --
    teachings_of_the_monastery     = { 76478, 116645, 1 }, --
    thunderfist                    = { 76472, 392985, 1 }, --
    tiger_tail_sweep               = { 76383, 264348, 2 }, --
    tigers_lust                    = { 76373, 116841, 1 }, --
    touch_of_death_2               = { 76406, 322113, 1 }, --
    touch_of_karma                 = { 76455, 122470, 1 }, --
    touch_of_the_tiger             = { 76461, 388856, 2 }, --
    transcendence                  = { 76398, 101643, 1 }, --
    transfer_the_power             = { 76491, 195300, 1 }, --
    vigorous_expulsion             = { 76401, 392900, 1 }, --
    vivacious_vivification         = { 76399, 388812, 1 }, --
    vivify_2                       = { 76371, 231602, 2 }, --
    way_of_the_fae                 = { 76474, 392994, 1 }, --
    whirling_dragon_punch          = { 76473, 152175, 1 }, --
    windwalking                    = { 76393, 157411, 2 }, --
    xuens_battlegear               = { 76489, 392993, 1 }, --
    xuens_bond                     = { 76486, 392986, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    alpha_tiger         = 3734, -- 287503
    disabling_reach     = 3050, -- 201769
    grapple_weapon      = 3052, -- 233759
    mighty_ox_kick      = 5540, -- 202370
    perpetual_paralysis = 5448, -- 357495
    pressure_points     = 3744, -- 345829
    reverse_harm        = 852 , -- 342928
    ride_the_wind       = 77  , -- 201372
    tigereye_brew       = 675 , -- 247483
    turbo_fists         = 3745, -- 287681
    wind_waker          = 3737, -- 357633
} )


-- Auras
spec:RegisterAuras( {
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
    chi_burst = { -- TODO: Hidden aura that procs Chi per enemy targeted.
        id = 123986,
        duration = 1,
        max_stack = 1
    },
    chi_energy = {
        id = 393057,
        duration = 45,
        max_stack = 30
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
    dance_of_chiji = {
        id = 325202,
        duration = 15,
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
    invoke_xuen_the_white_tiger = { -- TODO: Is a totem.
        id = 123904,
        duration = 24,
        tick_time = 4,
        max_stack = 1,
        copy = "invoke_xuen"
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
    mark_of_the_crane = {
        id = 228287,
        duration = 20,
        max_stack = 1
    },
    paralysis = {
        id = 115078,
        duration = 60,
        max_stack = 1
    },
    power_strikes = {
        id = 129914,
        duration = 3600,
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
    serenity = {
        id = 152173,
        duration = 12,
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
    the_emperors_capacitor = { -- TODO: There are at least 4 versions of this to double-check.
        id = 393039,
        duration = 3600,
        max_stack = 20
    },
    tigereye_brew = {
        id = 247483,
        duration = function () return max( 2, min( 10, buff.tigereye_brew_stack.stack * 2 ) ) end,
        max_stack = 1
    },
    tigereye_brew_stack = {
        id = 248646,
        duration = 120,
        max_stack = 20,
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
    transfer_the_power = {
        id = 195321,
        duration = 30,
        max_stack = 10
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
    zen_flight = {
        id = 125883,
        duration = 3600,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    blackout_kick = {
        id = 100784,
        cast = 0,
        cooldown = 3,
        gcd = "spell",

        spend = 1,
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
        id = 218164,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 20,
        spendType = "energy",

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


    empowered_tiger_lightning = {
        id = 335913,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "empowered_tiger_lightning",
        startsCombat = false,
        texture = 620832,

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


    faeline_harmony = {
        id = 391412,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "faeline_harmony",
        startsCombat = false,
        texture = 3636842,

        handler = function ()
        end,
    },


    faeline_stomp = {
        id = 388193,
        cast = 0,
        charges = 1,
        cooldown = 30,
        recharge = 30,
        gcd = "totem",

        spend = 0.04,
        spendType = "mana",

        talent = "faeline_stomp",
        startsCombat = false,
        texture = 3636842,

        handler = function ()
        end,
    },


    fatal_flying_guillotine = {
        id = 331679,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "fatal_flying_guillotine",
        startsCombat = false,
        texture = 606552,

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


    fists_of_fury = {
        id = 113656,
        cast = 0,
        cooldown = 24,
        gcd = "totem",

        spend = 3,
        spendType = "chi",

        talent = "fists_of_fury",
        startsCombat = false,
        texture = 627606,

        handler = function ()
        end,
    },


    flying_serpent_kick = {
        id = 101545,
        cast = 0,
        cooldown = 25,
        gcd = "totem",

        talent = "flying_serpent_kick",
        startsCombat = false,
        texture = 606545,

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


    invoke_xuen_the_white_tiger = {
        id = 123904,
        cast = 0,
        cooldown = 120,
        gcd = "totem",

        talent = "invoke_xuen_the_white_tiger",
        startsCombat = false,
        texture = 620832,

        toggle = "cooldowns",

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


    mark_of_the_crane = {
        id = 228287,
        cast = 0,
        cooldown = 0,
        gcd = "off",

        talent = "mark_of_the_crane",
        startsCombat = false,
        texture = 606543,

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

        spend = 20,
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
        startsCombat = true,
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

        spend = 1,
        spendType = "chi",

        talent = "rushing_jade_wind",
        startsCombat = false,
        texture = 606549,

        handler = function ()
        end,
    },


    serenity = {
        id = 152173,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "serenity",
        startsCombat = false,
        texture = 988197,

        toggle = "cooldowns",

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

        spend = 2,
        spendType = "chi",

        startsCombat = false,
        texture = 606543,

        handler = function ()
        end,
    },


    storm_earth_and_fire = {
        id = 137639,
        cast = 0,
        charges = 2,
        cooldown = 90,
        recharge = 90,
        gcd = "off",

        talent = "storm_earth_and_fire",
        startsCombat = false,
        texture = 136038,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    strike_of_the_windlord = {
        id = 392983,
        cast = 0,
        cooldown = 40,
        gcd = "totem",

        spend = 2,
        spendType = "chi",

        talent = "strike_of_the_windlord",
        startsCombat = false,
        texture = 1282595,

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

        spend = 50,
        spendType = "energy",

        startsCombat = true,
        texture = 606551,

        handler = function ()
        end,
    },


    tigereye_brew = {
        id = 247483,
        cast = 0,
        cooldown = 1,
        gcd = "spell",

        pvptalent = "tigereye_brew",
        startsCombat = false,
        texture = 613399,

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


    touch_of_karma = {
        id = 122470,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "touch_of_karma",
        startsCombat = false,
        texture = 651728,

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

        spend = 30,
        spendType = "energy",

        startsCombat = false,
        texture = 1360980,

        handler = function ()
        end,
    },


    whirling_dragon_punch = {
        id = 152175,
        cast = 0,
        cooldown = 24,
        gcd = "totem",

        talent = "whirling_dragon_punch",
        startsCombat = false,
        texture = 988194,

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

spec:RegisterPriority( "Windwalker", 20220918,
-- Notes
[[

]],
-- Priority
[[

]] )