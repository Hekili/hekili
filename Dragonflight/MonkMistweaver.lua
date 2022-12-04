-- MonkMistweaver.lua
-- DF Pre-Patch Nov 2022

if UnitClassBase( "player" ) ~= "MONK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 270 )

spec:RegisterResource( Enum.PowerType.Mana )


-- Talents
spec:RegisterTalents( {
    -- Monk
    bounce_back                   = { 80717, 389577, 2 },
    calming_presence              = { 80693, 388664, 1 },
    celerity                      = { 80685, 115173, 1 },
    chi_burst                     = { 80709, 123986, 1 },
    chi_torpedo                   = { 80685, 115008, 1 },
    chi_wave                      = { 80709, 115098, 1 },
    close_to_heart                = { 80707, 389574, 2 },
    dampen_harm                   = { 80704, 122278, 1 },
    diffuse_magic                 = { 80697, 122783, 1 },
    disable                       = { 80679, 116095, 1 },
    elusive_mists                 = { 80603, 388681, 2 },
    escape_from_reality           = { 80715, 394110, 2 },
    expeditious_fortification     = { 80681, 388813, 1 },
    eye_of_the_tiger              = { 80700, 196607, 1 },
    fast_feet                     = { 80705, 388809, 2 },
    fatal_touch                   = { 80703, 394123, 2 },
    ferocity_of_xuen              = { 80706, 388674, 2 },
    fortifying_brew               = { 80680, 115203, 1 },
    generous_pour                 = { 80683, 389575, 2 },
    grace_of_the_crane            = { 80710, 388811, 2 },
    hasty_provocation             = { 80696, 328670, 1 },
    improved_paralysis            = { 80687, 344359, 1 },
    improved_roll                 = { 80712, 328669, 1 },
    improved_touch_of_death       = { 80684, 322113, 1 },
    improved_vivify               = { 80692, 231602, 2 },
    ironshell_brew                = { 80681, 388814, 1 },
    paralysis                     = { 80688, 115078, 1 },
    profound_rebuttal             = { 80708, 392910, 1 },
    resonant_fists                = { 80702, 389578, 2 },
    ring_of_peace                 = { 80698, 116844, 1 },
    save_them_all                 = { 80714, 389579, 2 },
    spear_hand_strike             = { 80686, 116705, 1 },
    strength_of_spirit            = { 80682, 387276, 1 },
    summon_black_ox_statue        = { 80716, 115315, 1 },
    summon_jade_serpent_statue    = { 80713, 115313, 1 },
    summon_white_tiger_statue     = { 80701, 388686, 1 },
    tiger_tail_sweep              = { 80604, 264348, 2 },
    transcendence                 = { 80694, 101643, 1 },
    vigorous_expulsion            = { 80711, 392900, 1 },
    vivacious_vivification        = { 80695, 388812, 1 },
    windwalking                   = { 80699, 157411, 2 },
    
    -- Mistweaver
    accumulating_mist             = { 80564, 388564, 1 },
    ancient_concordance           = { 80569, 388740, 2 },
    ancient_teachings             = { 80598, 388023, 1 },
    attenuation                   = { 80596, 386941, 1 },
    awakened_faeline              = { 80577, 388779, 1 },
    bonedust_brew                 = { 80586, 386276, 1 },
    bountiful_brew                = { 80596, 386949, 1 },
    calming_coalescence           = { 80583, 388218, 1 },
    clouded_focus                 = { 80598, 388047, 1 },
    dancing_mists                 = { 80587, 388701, 2 },
    echoing_reverberation         = { 80564, 388604, 1 },
    enveloping_breath             = { 80582, 343655, 1 },
    enveloping_mist               = { 80568, 124682, 1 },
    essence_font                  = { 80597, 191837, 1 },
    faeline_stomp                 = { 80560, 388193, 1 },
    focused_thunder               = { 80593, 197895, 1 },
    font_of_life                  = { 80580, 337209, 1 },
    gift_of_the_celestials        = { 80576, 388212, 1 },
    healing_elixir                = { 80572, 122281, 1 },
    improved_detox                = { 81634, 388874, 1 },
    invigorating_mists            = { 80559, 274586, 1 },
    invoke_chiji_the_red_crane    = { 80590, 325197, 1 },
    invoke_yulon_the_jade_serpent = { 80590, 322118, 1 },
    invokers_delight              = { 80571, 388661, 1 },
    jade_bond                     = { 80576, 388031, 1 },
    life_cocoon                   = { 80584, 116849, 1 },
    lifecycles                    = { 80575, 197915, 1 },
    mana_tea                      = { 80575, 197908, 1 },
    mastery_of_mist               = { 80589, 281231, 1 },
    mending_proliferation         = { 80573, 388509, 1 },
    mist_wrap                     = { 80563, 197900, 1 },
    mists_of_life                 = { 80567, 388548, 1 },
    misty_peaks                   = { 80594, 388682, 2 },
    nourishing_chi                = { 80599, 387765, 1 },
    overflowing_mists             = { 80581, 388511, 2 },
    peaceful_mending              = { 80592, 388593, 2 },
    rapid_diffusion               = { 80579, 388847, 2 },
    refreshing_jade_wind          = { 80563, 196725, 1 },
    renewing_mist                 = { 80588, 115151, 1 },
    resplendent_mist              = { 80585, 388020, 2 },
    restoral                      = { 80574, 388615, 1 },
    revival                       = { 80574, 115310, 1 },
    rising_mist                   = { 80558, 274909, 1 },
    rising_sun_kick               = { 80690, 107428, 1 },
    secret_infusion               = { 80570, 388491, 2 },
    song_of_chiji                 = { 80561, 198898, 1 },
    soothing_mist                 = { 80691, 115175, 1 },
    spirit_of_the_crane           = { 80562, 210802, 1 },
    tea_of_plenty                 = { 80565, 388517, 1 },
    tea_of_serenity               = { 80565, 393460, 1 },
    teachings_of_the_monastery    = { 80595, 116645, 1 },
    tear_of_morning               = { 80558, 387991, 1 },
    thunder_focus_tea             = { 80600, 116680, 1 },
    tigers_lust                   = { 80689, 116841, 1 },
    unison                        = { 80573, 388477, 1 },
    uplifted_spirits              = { 80591, 388551, 1 },
    upwelling                     = { 80593, 274963, 1 },
    yulons_whisper                = { 80578, 388038, 1 },
    zen_pulse                     = { 80566, 124081, 1 },
} )


-- PvP Talents
spec:RegisterPvpTalents( { 
    alpha_tiger          = 5551,
    chrysalis            = 678 ,
    counteract_magic     = 679 ,
    dematerialize        = 5398,
    dome_of_mist         = 680 ,
    eminence             = 70  ,
    grapple_weapon       = 3732,
    healing_sphere       = 683 ,
    mighty_ox_kick       = 5539,
    peaceweaver          = 5395,
    precognition         = 5508,
    refreshing_breeze    = 682 ,
    thunderous_focus_tea = 5402,
    zen_focus_tea        = 1928,
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
    close_to_heart = {
        id = 389574,
    },
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
    fatal_touch = {
        id = 337296,
        duration = 3600,
        max_stack = 1
    },
    generous_pour = {
        id = 389575,
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
    mastery_gust_of_mists = {
        id = 117907,
    },
    mystic_touch = {
        id = 8647,
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
    profound_rebuttal = {
        id = 392910,
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
    save_them_all = {
        id = 389579,
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
    strength_of_spirit = {
        id = 387276,
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
    transcendence = {
        id = 101643,
        duration = 900,
        max_stack = 1
    },
    transcendence_transfer = {
        id = 119996,
    },
    vigorous_expulsion = {
        id = 392900,
    },
    vivacious_vivification = {
        id = 392883,
        duration = 3600,
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
    zen_pilgrimage = {
        id = 126892,
    },
} )


-- Abilities
spec:RegisterAbilities( {
    blackout_kick = {
        id = 100784,
        cast = 0,
        cooldown = 3,
        gcd = "spell",
        
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
        
        startsCombat = true,
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
        
        startsCombat = true,
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
        
        startsCombat = false,
        texture = 607849,
        
        handler = function ()
            applyBuff("chi_torpedo")
        end,
    },
    chi_wave = {
        id = 115098,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        
        startsCombat = true,
        texture = 606541,
        
        handler = function ()
        end,
    },
    crackling_jade_lightning = {
        id = 117952,
        cast = 4,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        
        startsCombat = true,
        texture = 606542,
        
        handler = function ()
            applyDebuff("crackling_jade_lightning")
        end,
    },
    dampen_harm = {
        id = 122278,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        
        startsCombat = false,
        texture = 620827,
        
        toggle = "cooldowns",

        handler = function ()
            applyBuff("dampen_harm")
        end,
    },
    detox = {
        id = 115450,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",
        
        spend = 0.065,
        spendType = "mana",
        
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
        
        startsCombat = true,
        texture = 775460,
        
        toggle = "cooldowns",

        handler = function ()
            applyBuff("diffuse_magic")
        end,
    },
    disable = {
        id = 116095,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        
        startsCombat = true,
        texture = 132316,
        
        handler = function ()
            applyDebuff("disable")
        end,
    },
    enveloping_mist = {
        id = 124682,
        cast = 2,
        cooldown = 0,
        gcd = "spell",
        
        spend = 0.24,
        spendType = "mana",
        
        startsCombat = false,
        texture = 775461,
        
        handler = function ()
            applyBuff("enveloping_mist")
        end,
    },
    essence_font = {
        id = 191837,
        cast = 0,
        cooldown = 12,
        gcd = "spell",
        
        spend = 0.36,
        spendType = "mana",
        
        startsCombat = false,
        texture = 1360978,
        
        handler = function ()
            applyBuff("essence_font")
        end,
    },
    expel_harm = {
        id = 322101,
        cast = 0,
        cooldown = 15,
        gcd = "totem",
        
        spend = 0.15,
        spendType = "mana",
        
        startsCombat = false,
        texture = 627486,
        
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
        
        startsCombat = true,
        texture = 3636842,
        
        handler = function ()
            applyDebuff("fae_exposure_debuff")
            applyBuff("fae_exposure_buff")
            applyBuff("faeline_stomp")
        end,
    },
    fortifying_brew = {
        id = 115203,
        cast = 0,
        cooldown = 360,
        gcd = "off",
        
        startsCombat = false,
        texture = 615341,
        
        toggle = "cooldowns",

        handler = function ()
            applyBuff("fortifying_brew")
        end,
    },
    grapple_weapon = {
        id = 233759,
        cast = 0,
        cooldown = 45,
        gcd = "totem",
        
        startsCombat = true,
        texture = 132343,
        
        handler = function ()
            applyDebuff("grapple_weapon")
        end,
    },
    healing_elixir = {
        id = 122281,
        cast = 0,
        charges = 2,
        cooldown = 30,
        recharge = 30,
        gcd = "off",
        
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
        
        spend = 0.095,
        spendType = "mana",
        
        startsCombat = false,
        texture = 606546,
        
        handler = function ()
        end,
    },
    invoke_chiji_the_red_crane = {
        id = 325197,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        
        spend = 0.25,
        spendType = "mana",
        
        startsCombat = false,
        texture = 877514,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    invoke_yulon_the_jade_serpent = {
        id = 322118,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        
        spend = 0.25,
        spendType = "mana",
        
        startsCombat = false,
        texture = 574571,
        
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
            applyDebuff("leg_sweep")
        end,
    },
    life_cocoon = {
        id = 116849,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        
        spend = 0.12,
        spendType = "mana",
        
        startsCombat = false,
        texture = 627485,
        
        toggle = "cooldowns",

        handler = function ()
            applyBuff("life_cocoon")
        end,
    },
    mana_tea = {
        id = 197908,
        cast = 0,
        cooldown = 90,
        gcd = "off",
        
        startsCombat = false,
        texture = 608949,
        
        toggle = "cooldowns",

        handler = function ()
            applyBuff("mana_tea")
        end,
    },
    mighty_ox_kick = {
        id = 202370,
        cast = 0,
        cooldown = 30,
        gcd = "totem",
        
        startsCombat = true,
        texture = 1381297,
        
        handler = function ()
        end,
    },
    paralysis = {
        id = 115078,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        startsCombat = false,
        texture = 629534,
        
        handler = function ()
            applyDebuff("paralysis")
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
            applyDebuff("provoke")
        end,
    },
    reawaken = {
        id = 212051,
        cast = 10,
        cooldown = 0,
        gcd = "spell",
        
        spend = 0.04,
        spendType = "mana",
        
        startsCombat = false,
        texture = 1056569,
        
        handler = function ()
        end,
    },
    refreshing_jade_wind = {
        id = 196725,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        
        spend = 0.25,
        spendType = "mana",
        
        startsCombat = false,
        texture = 606549,
        
        handler = function ()
        end,
    },
    renewing_mist = {
        id = 115151,
        cast = 0,
        charges = 2,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",
        
        spend = 0.09,
        spendType = "mana",
        
        startsCombat = false,
        texture = 627487,
        
        handler = function ()
            applyBuff("renewing_mist")
        end,
    },
    restoral = {
        id = 388615,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "spell",
        
        spend = 0.2187,
        spendType = "mana",
        
        startsCombat = false,
        texture = 1381300,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    resuscitate = {
        id = 115178,
        cast = 10,
        cooldown = 0,
        gcd = "spell",
        
        spend = 0.04,
        spendType = "mana",
        
        startsCombat = false,
        texture = 132132,
        
        handler = function ()
        end,
    },
    revival = {
        id = 115310,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
        gcd = "spell",
        
        spend = 0.2187,
        spendType = "mana",
        
        startsCombat = false,
        texture = 1020466,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    ring_of_peace = {
        id = 116844,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        
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

        startsCombat = true,
        texture = 642415,
        
        handler = function ()
        end,
    },
    roll = {
        id = 109132,
        cast = 0,
        charges = 2,
        cooldown = 15,
        recharge = 15,
        gcd = "off",
        
        startsCombat = false,
        texture = 574574,
        
        handler = function ()
        end,
    },
    song_of_chiji = {
        id = 198898,
        cast = 1.8,
        cooldown = 30,
        gcd = "spell",
        
        startsCombat = false,
        texture = 332402,
        
        handler = function ()
            applyDebuff("song_of_chiji")
        end,
    },
    soothing_mist = {
        id = 115175,
        cast = 8,
        channeled = true,
        cooldown = 0,
        gcd = "totem",
        
        spend = 0.16,
        spendType = "mana",
        
        startsCombat = false,
        texture = 606550,
        
        handler = function ()
            applyBuff("soothing_mist")
        end,
    },
    spear_hand_strike = {
        id = 116705,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        
        startsCombat = true,
        texture = 608940,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },
    spinning_crane_kick = {
        id = 101546,
        cast = 0,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        
        spend = 0.05,
        spendType = "mana",
        
        startsCombat = true,
        texture = 606543,
        
        handler = function ()
        end,
    },
    summon_black_ox_statue = {
        id = 115315,
        cast = 0,
        cooldown = 10,
        gcd = "totem",
        
        startsCombat = true,
        texture = 627607,
        
        handler = function ()
        end,
    },
    summon_jade_serpent_statue = {
        id = 115313,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        
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
        
        startsCombat = true,
        texture = 4667418,
        
        toggle = "cooldowns",

        handler = function ()
        end,
    },
    thunder_focus_tea = {
        id = 116680,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        
        startsCombat = false,
        texture = 611418,
        
        handler = function ()
            applyBuff("thunder_focus_tea")
        end,
    },
    tiger_palm = {
        id = 100780,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

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
        
        startsCombat = false,
        texture = 651727,
        
        handler = function ()
            applyBuff("tigers_lust")
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
        
        startsCombat = false,
        texture = 627608,
        
        handler = function ()
        end,
    },
    transcendence_transfer = {
        id = 119996,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        
        startsCombat = false,
        texture = 237585,
        
        handler = function ()
        end,
    },
    vivify = {
        id = 116670,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        
        spend = 0.19,
        spendType = "mana",
        
        startsCombat = false,
        texture = 1360980,
        
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
            applyBuff("zen_flight")
        end,
    },
    zen_focus_tea = {
        id = 209584,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        
        startsCombat = false,
        texture = 651940,
        
        handler = function ()
            applyBuff("zen_focus_tea")
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
    zen_pulse = {
        id = 124081,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        
        spend = 0.05,
        spendType = "mana",
        
        startsCombat = true,
        texture = 613397,
        
        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Mistweaver", 20221113,
-- Notes
[[

]],
-- Priority
[[

]] )