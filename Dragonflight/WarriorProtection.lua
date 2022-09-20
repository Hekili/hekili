-- WarriorProtection.lua
-- September 2022

if UnitClassBase( "player" ) ~= "WARRIOR" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 73 )

spec:RegisterResource( Enum.PowerType.Rage )

-- Talents
spec:RegisterTalents( {
    anger_management                = { 78014, 152278, 1 },
    armored_to_the_teeth            = { 77938, 384124, 2 },
    avatar                          = { 77922, 107574, 1 },
    barbaric_training               = { 77929, 390675, 1 },
    battle_stance                   = { 77903, 386164, 1 },
    battlescarred_veteran           = { 78047, 386394, 1 },
    berserker_rage                  = { 78009, 18499 , 1 },
    berserker_shout                 = { 77946, 384100, 1 },
    best_served_cold                = { 78026, 202560, 1 },
    bitter_immunity                 = { 77936, 383762, 1 },
    blood_and_thunder               = { 77948, 384277, 1 },
    bloodborne                      = { 78032, 385704, 2 },
    bloodsurge                      = { 78042, 384361, 1 },
    bolster                         = { 78031, 280001, 1 },
    booming_voice                   = { 78024, 202743, 1 },
    bounding_stride                 = { 77940, 202163, 1 },
    brace_for_impact                = { 78036, 386030, 1 },
    brutal_vitality                 = { 78035, 384036, 1 },
    cacophonous_roar                = { 77942, 382954, 1 },
    challenging_shout               = { 78023, 1161  , 1 },
    champions_bulwark               = { 78015, 386328, 1 },
    concussive_blows                = { 77900, 383115, 1 },
    crackling_thunder               = { 77948, 203201, 1 },
    cruel_strikes                   = { 77894, 392777, 2 },
    crushing_force                  = { 77995, 390642, 2 },
    defensive_stance                = { 78008, 386208, 1 },
    demoralizing_shout              = { 78025, 1160  , 1 },
    devastator                      = { 78011, 236279, 1 },
    disrupting_shout                = { 78020, 386071, 1 },
    double_time                     = { 77941, 103827, 1 },
    elysian_might                   = { 77923, 386285, 1 },
    endurance_training              = { 77937, 382940, 1 },
    enduring_alacrity               = { 78018, 384063, 2 },
    enduring_defenses               = { 78044, 386027, 1 },
    fast_footwork                   = { 78005, 382260, 1 },
    focused_vigor                   = { 78030, 384067, 2 },
    frothing_berserker              = { 77999, 392790, 1 },
    fueled_by_violence              = { 78035, 383103, 1 },
    furious_blows                   = { 77993, 390354, 1 },
    heavy_repercussions             = { 78021, 203177, 1 },
    heroic_leap                     = { 77939, 6544  , 1 },
    honed_reflexes                  = { 77893, 391271, 1 },
    ignore_pain                     = { 78039, 190456, 1 },
    impending_victory               = { 78004, 202168, 1 },
    improved_heroic_throw           = { 78019, 386034, 1 },
    indomitable                     = { 78012, 202095, 1 },
    inspiring_presence              = { 78002, 382310, 1 },
    intervene                       = { 77944, 3411  , 1 },
    intimidating_shout              = { 77943, 5246  , 1 },
    into_the_fray                   = { 78021, 202603, 1 },
    juggernaut                      = { 78033, 383292, 1 },
    last_stand                      = { 78037, 12975 , 1 },
    massacre                        = { 78044, 281001, 1 },
    menace                          = { 77942, 275338, 1 },
    onehanded_weapon_specialization = { 77935, 382895, 1 },
    outburst                        = { 78017, 386477, 1 },
    overwhelming_rage               = { 77994, 382767, 2 },
    pain_and_gain                   = { 77930, 382549, 1 },
    piercing_howl                   = { 77946, 12323 , 1 },
    piercing_verdict                = { 77924, 382948, 1 },
    punish                          = { 78033, 275334, 1 },
    quick_thinking                  = { 77928, 382946, 2 },
    rallying_cry                    = { 78007, 97462 , 1 },
    ravager                         = { 78028, 228920, 1 },
    reinforced_plates               = { 77921, 382939, 1 },
    rend                            = { 78013, 772   , 1 },
    revenge                         = { 78040, 6572  , 1 },
    rumbling_earth                  = { 77914, 275339, 1 },
    second_wind                     = { 78002, 29838 , 1 },
    seismic_reverberation           = { 77932, 382956, 1 },
    shattering_throw                = { 77997, 64382 , 1 },
    shield_charge                   = { 78016, 385952, 1 },
    shield_specialization           = { 78045, 386011, 2 },
    shield_wall                     = { 78043, 871   , 1 },
    shockwave                       = { 77916, 46968 , 1 },
    show_of_force                   = { 78019, 385843, 1 },
    sidearm                         = { 77901, 384404, 1 },
    signet_of_tormented_kings       = { 77919, 382949, 1 },
    siphoning_strikes               = { 77991, 382258, 1 },
    sonic_boom                      = { 77915, 390725, 1 },
    spear_of_bastion                = { 77934, 376079, 1 },
    spell_block                     = { 78046, 392966, 1 },
    spell_reflection                = { 77945, 23920 , 1 },
    spiked_shield                   = { 78034, 385888, 1 },
    storm_bolt                      = { 77933, 107570, 1 },
    storm_of_steel                  = { 78027, 382953, 1 },
    strategist                      = { 78041, 384041, 1 },
    sudden_death                    = { 77898, 29725 , 1 },
    the_wall                        = { 78029, 384072, 1 },
    thunder_clap                    = { 77947, 6343  , 1 },
    thunderlord                     = { 78022, 385840, 1 },
    thunderous_roar                 = { 77927, 384318, 1 },
    thunderous_words                = { 77926, 384969, 1 },
    titanic_throw                   = { 77929, 384090, 1 },
    unbreakable_will                = { 78029, 384074, 1 },
    unnerving_focus                 = { 78038, 384042, 1 },
    unstoppable_force               = { 77919, 275336, 1 },
    uproar                          = { 77925, 391572, 1 },
    war_machine                     = { 78010, 316733, 1 },
    wrecking_throw                  = { 77997, 384110, 1 },
    wrenching_impact                = { 77940, 392383, 1 },
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bodyguard = 168, -- 213871
    demolition = 5374, -- 329033
    disarm = 24, -- 236077
    dragon_charge = 831, -- 206572
    morale_killer = 171, -- 199023
    oppressor = 845, -- 205800
    rebound = 833, -- 213915
    shield_bash = 173, -- 198912
    sword_and_board = 167, -- 199127
    thunderstruck = 175, -- 199045
    warbringer = 5432, -- 356353
    warpath = 178, -- 199086
} )


-- Auras
spec:RegisterAuras( {
    avatar = {
        id = 107574,
        duration = 20,
        max_stack = 1
    },
    battle_shout = {
        id = 6673,
        duration = 3600,
        max_stack = 1
    },
    battle_stance = {
        id = 386164,
        duration = 3600,
        max_stack = 1
    },
    battlescarred_veteran = {
        id = 386397,
        duration = 8,
        max_stack = 1
    },
    berserker_rage = {
        id = 18499,
        duration = 6,
        max_stack = 1
    },
    berserker_shout = {
        id = 384100,
        duration = 6,
        max_stack = 1
    },
    bladestorm = {
        id = 227847,
        duration = 6,
        tick_time = 1,
        max_stack = 1
    },
    bodyguard = {
        id = 213871,
        duration = 60,
        tick_time = 1,
        max_stack = 1
    },
    brace_for_impact = {
        id = 386029,
        duration = 9,
        max_stack = 5
    },
    challenging_shout = {
        id = 1161,
        duration = 6,
        max_stack = 1
    },
    concussive_blows = {
        id = 383116,
        duration = 10,
        max_stack = 1
    },
    deep_wounds = {
        id = 115767,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    defensive_stance = {
        id = 386208,
        duration = 3600,
        max_stack = 1
    },
    demoralizing_shout = {
        id = 1160,
        duration = 8,
        max_stack = 1
    },
    die_by_the_sword = {
        id = 118038,
        duration = 8,
        max_stack = 1
    },
    disarm = {
        id = 236077,
        duration = 6,
        max_stack = 1
    },
    disrupting_shout = {
        id = 386071,
        duration = 6,
        max_stack = 1
    },
    dragon_charge = { -- TODO: This is the duration of the sprint.
        id = 206572,
        duration = 1.2,
        max_stack = 1
    },
    elysian_might = {
        id = 386286,
        duration = 8, -- Check vs. Spear of Bastion duration.
        max_stack = 1
    },
    focused_assault = {
        id = 206891,
        duration = 6,
        max_stack = 5
    },
    hamstring = {
        id = 1715,
        duration = 15,
        max_stack = 1
    },
    ignore_pain = {
        id = 190456,
        duration = 12,
        max_stack = 1
    },
    intimidating_shout = {
        id = 5246,
        duration = 8,
        max_stack = 1
    },
    juggernaut = {
        id = 383290,
        duration = 12,
        max_stack = 15
    },
    last_stand = {
        id = 12975,
        duration = 15,
        max_stack = 1
    },
    overpower = {
        id = 7384,
        duration = 15,
        max_stack = 1
    },
    piercing_howl = {
        id = 12323,
        duration = 8,
        max_stack = 1
    },
    punish = {
        id = 275335,
        duration = 9,
        max_stack = 5
    },
    quick_thinking = {
        id = 392778,
        duration = 10,
        max_stack = 1
    },
    ravager = {
        id = 228920,
        duration = 12,
        tick_time = 2,
        max_stack = 1
    },
    rend = {
        id = 388539,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    revenge = {
        id = 5302,
        duration = 6,
        max_stack = 1
    },
    shield_bash = {
        id = 198912,
        duration = 8,
        max_stack = 1
    },
    shield_block = {
        id = 132404,
        duration = 6,
        max_stack = 1
    },
    shield_wall = {
        id = 871,
        duration = 8,
        max_stack = 1
    },
    show_of_force = {
        id = 385842,
        duration = 12,
        max_stack = 1
    },
    spear_of_bastion = {
        id = 376080,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    spell_block = { -- TODO: Check spell ID.
        id = 386014,
        duration = 14,
        max_stack = 1
    },
    spell_reflection = {
        id = 23920,
        duration = 5,
        max_stack = 1
    },
    spell_reflection_defense = {
        id = 385391,
        duration = 5,
        max_stack = 1
    },
    sweeping_strikes = {
        id = 260708,
        duration = 15,
        max_stack = 1
    },
    taunt = {
        id = 355,
        duration = 3,
        max_stack = 1
    },
    thunder_clap = {
        id = 6343,
        duration = 10,
        max_stack = 1
    },
    thunderous_roar = {
        id = 384318,
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    unnerving_focus = {
        id = 384043,
        duration = 15,
        max_stack = 1
    },
    war_machine = {
        id = 262232,
        duration = 8,
        max_stack = 1
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


    battle_stance = {
        id = 386164,
        cast = 0,
        cooldown = 3,
        gcd = "off",

        talent = "battle_stance",
        startsCombat = false,
        texture = 132349,

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


    bodyguard = {
        id = 213871,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        pvptalent = "bodyguard",
        startsCombat = false,
        texture = 132359,

        handler = function ()
        end,
    },


    challenging_shout = {
        id = 1161,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "challenging_shout",
        startsCombat = false,
        texture = 132091,

        toggle = "cooldowns",

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


    demoralizing_shout = {
        id = 1160,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        talent = "demoralizing_shout",
        startsCombat = false,
        texture = 132366,

        handler = function ()
        end,
    },


    devastate = {
        id = 20243,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = true,
        texture = 135291,

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


    disrupting_shout = {
        id = 386071,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "disrupting_shout",
        startsCombat = false,
        texture = 132091,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dragon_charge = {
        id = 206572,
        cast = 0,
        cooldown = 20,
        gcd = "off",

        pvptalent = "dragon_charge",
        startsCombat = false,
        texture = 1380676,

        handler = function ()
        end,
    },


    execute = {
        id = 163201,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 40,
        spendType = "rage",

        startsCombat = true,
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


    ignore_pain = {
        id = 190456,
        cast = 0,
        cooldown = 1,
        gcd = "off",

        spend = 35,
        spendType = "rage",

        talent = "ignore_pain",
        startsCombat = false,
        texture = 1377132,

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


    last_stand = {
        id = 12975,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "last_stand",
        startsCombat = false,
        texture = 135871,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    oppressor = {
        id = 205800,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        pvptalent = "oppressor",
        startsCombat = false,
        texture = 136080,

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


    rend = {
        id = 772,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "rage",

        talent = "rend",
        startsCombat = false,
        texture = 132155,

        handler = function ()
        end,
    },


    revenge = {
        id = 6572,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 20,
        spendType = "rage",

        talent = "revenge",
        startsCombat = false,
        texture = 132353,

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


    shield_bash = {
        id = 198912,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        pvptalent = "shield_bash",
        startsCombat = false,
        texture = 132357,

        handler = function ()
        end,
    },


    shield_block = {
        id = 2565,
        cast = 0,
        charges = 2,
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


    shield_charge = {
        id = 385952,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        talent = "shield_charge",
        startsCombat = false,
        texture = 4667427,

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


    shield_wall = {
        id = 871,
        cast = 0,
        charges = 1,
        cooldown = 210,
        recharge = 210,
        gcd = "spell",

        talent = "shield_wall",
        startsCombat = false,
        texture = 132362,

        toggle = "cooldowns",

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


    spell_block = {
        id = 392966,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "spell_block",
        startsCombat = false,
        texture = 132358,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    spell_reflection = {
        id = 23920,
        cast = 0,
        charges = 1,
        cooldown = 20,
        recharge = 20,
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

        spend = 0,
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
        id = 1680,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 30,
        spendType = "rage",

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

spec:RegisterPriority( "Protection", 20220915,
-- Notes
[[

]],
-- Priority
[[

]] )