-- WarriorFury.lua
-- September 2022

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 72 )

spec:RegisterResource( Enum.PowerType.Rage )

-- Talents
spec:RegisterTalents( {
    anger_management                = { 77952, 152278, 1 },
    annihilator                     = { 77954, 383916, 1 },
    armored_to_the_teeth            = { 77938, 384124, 2 },
    ashen_juggernaut                = { 77896, 392536, 1 },
    avatar                          = { 77922, 107574, 1 },
    barbaric_training               = { 77931, 390674, 1 },
    berserker_rage                  = { 78009, 18499 , 1 },
    berserker_shout                 = { 77946, 384100, 1 },
    berserker_stance                = { 77990, 386196, 1 },
    bitter_immunity                 = { 77936, 383762, 1 },
    blood_and_thunder               = { 77948, 384277, 1 },
    bloodborne                      = { 77959, 385703, 1 },
    bloodcraze                      = { 77968, 385735, 1 },
    bloodthirst                     = { 77983, 23881 , 1 },
    bounding_stride                 = { 77940, 202163, 1 },
    cacophonous_roar                = { 77942, 382954, 1 },
    cold_steel_hot_blood            = { 77958, 383959, 1 },
    concussive_blows                = { 77900, 383115, 1 },
    crackling_thunder               = { 77948, 203201, 1 },
    critical_thinking               = { 77976, 383297, 2 },
    cruel_strikes                   = { 77894, 392777, 2 },
    cruelty                         = { 77890, 392931, 1 },
    crushing_force                  = { 78000, 382764, 2 },
    dancing_blades                  = { 77956, 391683, 1 },
    defensive_stance                = { 78008, 386208, 1 },
    deft_experience                 = { 77960, 383295, 2 },
    depths_of_insanity              = { 77950, 383922, 1 },
    double_time                     = { 77941, 103827, 1 },
    dual_wield_specialization       = { 77917, 382900, 1 },
    elysian_might                   = { 77923, 386285, 1 },
    endurance_training              = { 77937, 382940, 1 },
    enraged_regeneration            = { 77985, 184364, 1 },
    fast_footwork                   = { 78005, 382260, 1 },
    focus_in_chaos                  = { 77966, 383486, 1 },
    frenzied_flurry                 = { 77961, 383605, 1 },
    frenzy                          = { 77969, 335077, 1 },
    fresh_meat                      = { 77963, 215568, 1 },
    frothing_berserker              = { 78001, 215571, 1 },
    furious_blows                   = { 77993, 390354, 1 },
    hack_and_slash                  = { 77953, 383877, 1 },
    heroic_leap                     = { 77939, 6544  , 1 },
    honed_reflexes                  = { 77996, 391270, 1 },
    hurricane                       = { 77972, 390563, 1 },
    impending_victory               = { 78004, 202168, 1 },
    improved_bloodthirst            = { 77965, 383852, 1 },
    improved_enrage                 = { 77964, 383848, 1 },
    improved_execute                = { 77982, 316402, 1 },
    improved_raging_blow            = { 77981, 383854, 1 },
    improved_whirlwind              = { 77980, 12950 , 1 },
    inspiring_presence              = { 78002, 382310, 1 },
    intervene                       = { 77944, 3411  , 1 },
    intimidating_shout              = { 77943, 5246  , 1 },
    invigorating_fury               = { 77949, 383468, 1 },
    massacre                        = { 77897, 206315, 1 },
    meat_cleaver                    = { 77974, 280392, 1 },
    memory_of_a_tormented_berserker = { 77918, 390123, 1 },
    memory_of_a_tormented_titan     = { 77918, 390135, 1 },
    menace                          = { 77942, 275338, 1 },
    odyns_fury                      = { 77957, 385059, 1 },
    onslaught                       = { 77978, 315720, 1 },
    overwhelming_rage               = { 77994, 382767, 2 },
    pain_and_gain                   = { 77930, 382549, 1 },
    piercing_howl                   = { 77946, 12323 , 1 },
    piercing_verdict                = { 77924, 382948, 1 },
    placeholder_talent              = { 77956, 390376, 1 },
    pulverize                       = { 77977, 388933, 1 },
    quick_thinking                  = { 77928, 382946, 2 },
    raging_armaments                = { 77975, 388049, 1 },
    raging_blow                     = { 77984, 85288 , 1 },
    rallying_cry                    = { 78007, 97462 , 1 },
    rampage                         = { 77987, 184367, 1 },
    ravager                         = { 77973, 228920, 1 },
    reckless_abandon                = { 77952, 202751, 1 },
    recklessness                    = { 77970, 1719  , 1 },
    reinforced_plates               = { 77921, 382939, 1 },
    rumbling_earth                  = { 77914, 275339, 1 },
    second_wind                     = { 78002, 29838 , 1 },
    seismic_reverberation           = { 77932, 382956, 1 },
    shattering_throw                = { 77997, 64382 , 1 },
    shockwave                       = { 77916, 46968 , 1 },
    sidearm                         = { 77901, 384404, 1 },
    singleminded_fury               = { 77962, 81099 , 1 },
    siphoning_strikes               = { 77991, 382258, 1 },
    slaughtering_strikes            = { 77988, 388004, 1 },
    sonic_boom                      = { 77915, 390725, 1 },
    spear_of_bastion                = { 77934, 376079, 1 },
    spell_reflection                = { 77945, 23920 , 1 },
    storm_bolt                      = { 77933, 107570, 1 },
    storm_of_steel                  = { 77972, 382953, 1 },
    storm_of_swords                 = { 77955, 388903, 1 },
    sudden_death                    = { 77979, 280721, 1 },
    swift_strikes                   = { 77971, 383459, 2 },
    thunder_clap                    = { 77947, 6343  , 1 },
    thunderous_roar                 = { 77927, 384318, 1 },
    thunderous_words                = { 77926, 384969, 1 },
    titanic_throw                   = { 77931, 384090, 1 },
    unbridled_ferocity              = { 77951, 389603, 1 },
    uproar                          = { 77925, 391572, 1 },
    vicious_contempt                = { 77967, 383885, 2 },
    war_machine                     = { 77989, 346002, 1 },
    warpaint                        = { 77986, 208154, 1 },
    wrath_and_fury                  = { 77895, 392936, 1 },
    wrecking_throw                  = { 77997, 384110, 1 },
    wrenching_impact                = { 77940, 392383, 1 },
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    barbarian = 166, -- 280745
    battle_trance = 170, -- 213857
    bloodrage = 172, -- 329038
    death_sentence = 25, -- 198500
    death_wish = 179, -- 199261
    demolition = 5373, -- 329033
    disarm = 3533, -- 236077
    enduring_rage = 177, -- 198877
    master_and_commander = 3528, -- 235941
    rebound = 5548, -- 213915
    slaughterhouse = 3735, -- 352998
    warbringer = 5431, -- 356353
} )


-- Auras
spec:RegisterAuras( {
    avatar = {
        id = 107574,
    },
    berserker_rage = {
        id = 18499,
    },
    berserker_shout = {
        id = 384100,
    },
    bloodrage = {
        id = 329038,
    },
    bloodthirst = {
        id = 23881,
    },
    death_wish = {
        id = 199261,
    },
    defensive_stance = {
        id = 386208,
    },
    dual_wield = {
        id = 231842,
    },
    enrage = {
        id = 184361,
    },
    enraged_regeneration = {
        id = 184364,
    },
    mastery_unshackled_fury = {
        id = 76856,
    },
    raging_blow = {
        id = 85288,
    },
    ravager = {
        id = 228920,
    },
    recklessness = {
        id = 1719,
    },
    spell_reflection = {
        id = 23920,
    },
    titans_grip = {
        id = 46917,
    },
} )


-- Abilities
spec:RegisterAbilities( {
    avatar = {
        id = 107574,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "avatar",
        startsCombat = false,
        texture = 613534,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    battle_shout = {
        id = 6673,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        startsCombat = false,
        texture = 132333,

        handler = function ()
        end,
    },


    berserker_rage = {
        id = 18499,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "berserker_rage",
        startsCombat = false,
        texture = 136009,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    berserker_shout = {
        id = 384100,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "berserker_shout",
        startsCombat = false,
        texture = 136009,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    berserker_stance = {
        id = 386196,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "berserker_stance",
        startsCombat = false,
        texture = 132275,

        handler = function ()
        end,
    },


    bitter_immunity = {
        id = 383762,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        talent = "bitter_immunity",
        startsCombat = false,
        texture = 136088,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    bloodrage = {
        id = 329038,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        spend = 6777,
        spendType = "health",

        pvptalent = "bloodrage",
        startsCombat = false,
        texture = 132277,

        handler = function ()
        end,
    },


    bloodthirst = {
        id = 23881,
        cast = 0,
        cooldown = 4.5,
        gcd = "spell",

        talent = "bloodthirst",
        startsCombat = false,
        texture = 136012,

        handler = function ()
        end,
    },


    charge = {
        id = 100,
        cast = 0,
        charges = 1,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",

        startsCombat = true,
        texture = 132337,

        handler = function ()
        end,
    },


    death_wish = {
        id = 199261,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = 6777,
        spendType = "health",

        pvptalent = "death_wish",
        startsCombat = false,
        texture = 136146,

        handler = function ()
        end,
    },


    defensive_stance = {
        id = 386208,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "defensive_stance",
        startsCombat = false,
        texture = 132341,

        handler = function ()
        end,
    },


    disarm = {
        id = 236077,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        pvptalent = "disarm",
        startsCombat = false,
        texture = 132343,

        handler = function ()
        end,
    },


    enraged_regeneration = {
        id = 184364,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "enraged_regeneration",
        startsCombat = false,
        texture = 132345,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    execute = {
        id = 5308,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        startsCombat = false,
        texture = 135358,

        handler = function ()
        end,
    },


    hamstring = {
        id = 1715,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        startsCombat = true,
        texture = 132316,

        handler = function ()
        end,
    },


    heroic_leap = {
        id = 6544,
        cast = 0,
        charges = 1,
        cooldown = 45,
        recharge = 45,
        gcd = "spell",

        talent = "heroic_leap",
        startsCombat = false,
        texture = 236171,

        handler = function ()
        end,
    },


    heroic_throw = {
        id = 57755,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        startsCombat = true,
        texture = 132453,

        handler = function ()
        end,
    },


    impending_victory = {
        id = 202168,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 10,
        spendType = "rage",

        talent = "impending_victory",
        startsCombat = false,
        texture = 589768,

        handler = function ()
        end,
    },


    intervene = {
        id = 3411,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        talent = "intervene",
        startsCombat = false,
        texture = 132365,

        handler = function ()
        end,
    },


    intimidating_shout = {
        id = 5246,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "intimidating_shout",
        startsCombat = false,
        texture = 132154,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    odyns_fury = {
        id = 385059,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "odyns_fury",
        startsCombat = false,
        texture = 1278409,

        handler = function ()
        end,
    },


    onslaught = {
        id = 315720,
        cast = 0,
        cooldown = 18,
        gcd = "spell",

        talent = "onslaught",
        startsCombat = false,
        texture = 132364,

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


    piercing_howl = {
        id = 12323,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "piercing_howl",
        startsCombat = false,
        texture = 136147,

        handler = function ()
        end,
    },


    pummel = {
        id = 6552,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        startsCombat = true,
        texture = 132938,

        handler = function ()
        end,
    },


    raging_blow = {
        id = 85288,
        cast = 0,
        charges = 1,
        cooldown = 7.557,
        recharge = 7.557,
        gcd = "spell",

        talent = "raging_blow",
        startsCombat = false,
        texture = 589119,

        handler = function ()
        end,
    },


    rallying_cry = {
        id = 97462,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "rallying_cry",
        startsCombat = false,
        texture = 132351,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    rampage = {
        id = 184367,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 80,
        spendType = "rage",

        talent = "rampage",
        startsCombat = false,
        texture = 132352,

        handler = function ()
        end,
    },


    ravager = {
        id = 228920,
        cast = 0,
        charges = 1,
        cooldown = 90,
        recharge = 90,
        gcd = "spell",

        talent = "ravager",
        startsCombat = false,
        texture = 970854,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    recklessness = {
        id = 1719,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "recklessness",
        startsCombat = false,
        texture = 458972,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    shattering_throw = {
        id = 64382,
        cast = 1.5,
        cooldown = 180,
        gcd = "spell",

        talent = "shattering_throw",
        startsCombat = false,
        texture = 311430,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    shield_block = {
        id = 2565,
        cast = 0,
        charges = 1,
        cooldown = 15.115,
        recharge = 15.115,
        gcd = "spell",

        spend = 30,
        spendType = "rage",

        startsCombat = false,
        texture = 132110,

        handler = function ()
        end,
    },


    shield_slam = {
        id = 23922,
        cast = 0,
        cooldown = 9,
        gcd = "spell",

        startsCombat = true,
        texture = 134951,

        handler = function ()
        end,
    },


    shockwave = {
        id = 46968,
        cast = 0,
        cooldown = 40,
        gcd = "spell",

        talent = "shockwave",
        startsCombat = false,
        texture = 236312,

        handler = function ()
        end,
    },


    slam = {
        id = 1464,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 20,
        spendType = "rage",

        startsCombat = true,
        texture = 132340,

        handler = function ()
        end,
    },


    spear_of_bastion = {
        id = 376079,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "spear_of_bastion",
        startsCombat = false,
        texture = 3565453,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    spell_reflection = {
        id = 23920,
        cast = 0,
        charges = 1,
        cooldown = 25,
        recharge = 25,
        gcd = "spell",

        talent = "spell_reflection",
        startsCombat = false,
        texture = 132361,

        handler = function ()
        end,
    },


    storm_bolt = {
        id = 107570,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        talent = "storm_bolt",
        startsCombat = false,
        texture = 613535,

        handler = function ()
        end,
    },


    taunt = {
        id = 355,
        cast = 0,
        cooldown = 8,
        gcd = "off",

        startsCombat = true,
        texture = 136080,

        handler = function ()
        end,
    },


    thunder_clap = {
        id = 6343,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 30,
        spendType = "rage",

        talent = "thunder_clap",
        startsCombat = false,
        texture = 136105,

        handler = function ()
        end,
    },


    thunderous_roar = {
        id = 384318,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        talent = "thunderous_roar",
        startsCombat = false,
        texture = 642418,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    titanic_throw = {
        id = 384090,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        talent = "titanic_throw",
        startsCombat = false,
        texture = 132453,

        handler = function ()
        end,
    },


    victory_rush = {
        id = 34428,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 132342,

        handler = function ()
        end,
    },


    whirlwind = {
        id = 190411,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 132369,

        handler = function ()
        end,
    },


    wrecking_throw = {
        id = 384110,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "wrecking_throw",
        startsCombat = false,
        texture = 311430,

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Fury", 20220915,
-- Notes
[[

]],
-- Priority
[[

]] )