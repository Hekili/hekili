-- RogueAssassination.lua
-- September 2022

if UnitClassBase( "player" ) ~= "ROGUE" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 259 )

spec:RegisterResource( Enum.PowerType.ComboPoints )
spec:RegisterResource( Enum.PowerType.Energy )

-- Talents
spec:RegisterTalents( {
    acrobatic_strikes      = { 79636, 196924, 1 }, --
    alacrity               = { 79630, 193539, 3 }, --
    amplifying_poison      = { 79498, 381664, 1 }, --
    atrophic_poison        = { 79647, 381637, 1 }, --
    blind                  = { 79655, 2094  , 1 }, --
    blindside              = { 79503, 328085, 1 }, --
    bloody_mess            = { 79609, 381626, 2 }, --
    cheat_death            = { 79625, 31230 , 1 }, --
    cloak_of_shadows       = { 79653, 31224 , 1 }, --
    cold_blood             = { 79639, 382245, 1 }, --
    crimson_tempest        = { 79600, 121411, 1 }, --
    cut_to_the_chase       = { 79596, 51667 , 2 }, --
    dashing_scoundrel      = { 79495, 381797, 3 }, --
    deadened_nerves        = { 79649, 231719, 1 }, --
    deadly_poison          = { 79607, 2823  , 1 }, --
    deadly_precision       = { 79638, 381542, 2 }, --
    deathmark              = { 79507, 360194, 1 }, --
    deeper_stratagem       = { 79615, 193531, 1 }, --
    doomblade              = { 79613, 381673, 1 }, --
    dragontempered_blades  = { 79494, 381801, 1 }, --
    echoing_reprimand      = { 79617, 385616, 1 }, --
    elaborate_planning     = { 79598, 193640, 2 }, --
    elusiveness            = { 79616, 79008 , 1 }, --
    evasion                = { 79646, 5277  , 1 }, --
    exsanguinate           = { 79493, 200806, 1 }, --
    feint                  = { 79656, 1966  , 1 }, --
    find_weakness          = { 79624, 91023 , 2 }, --
    fleet_footed           = { 79648, 378813, 1 }, --
    flying_daggers         = { 79499, 381631, 1 }, --
    gouge                  = { 79632, 1776  , 1 }, --
    improved_ambush        = { 79635, 381620, 1 }, --
    improved_garrote       = { 79610, 381632, 1 }, --
    improved_poisons       = { 79605, 381624, 2 }, --
    improved_sap           = { 79628, 379005, 1 }, --
    improved_shiv          = { 79599, 319032, 1 }, --
    improved_sprint        = { 79633, 231691, 1 }, --
    improved_wound_poison  = { 79641, 319066, 1 }, --
    indiscriminate_carnage = { 79601, 381802, 1 }, --
    intent_to_kill         = { 79491, 381630, 1 }, --
    internal_bleeding      = { 79490, 381627, 2 }, --
    iron_stomach           = { 79643, 193546, 1 }, --
    iron_wire              = { 79492, 196861, 1 }, --
    kingsbane              = { 79606, 385627, 1 }, --
    leeching_poison        = { 79621, 280716, 1 }, --
    lethal_dose_nyi        = { 79612, 381640, 2 }, --
    lethality              = { 79637, 382238, 3 }, --
    maim_mangle            = { 79504, 381652, 1 }, --
    marked_for_death       = { 79629, 137619, 1 }, --
    master_assassin        = { 79611, 255989, 1 }, --
    master_poisoner        = { 79642, 378436, 1 }, --
    nightstalker           = { 79635, 14062 , 1 }, --
    nimble_fingers         = { 79644, 378427, 1 }, --
    numbing_poison         = { 79647, 5761  , 1 }, --
    poison_bomb            = { 79497, 255544, 2 }, --
    poison_damage          = { 79604, 392384, 1 }, --
    poisoned_katar         = { 79595, 381629, 1 }, --
    prey_on_the_weak       = { 79489, 131511, 1 }, --
    recuperator            = { 79634, 378996, 1 }, --
    resounding_clarity     = { 79618, 381622, 2 }, --
    rushed_setup           = { 79654, 378803, 1 }, --
    sap                    = { 79652, 6770  , 1 }, --
    scent_of_blood         = { 79602, 381799, 3 }, --
    seal_fate              = { 79622, 14190 , 2 }, --
    sepsis                 = { 79614, 385408, 1 }, --
    serrated_bone_spike    = { 79614, 385424, 1 }, --
    shadow_dance           = { 79623, 185313, 1 }, --
    shadowrunner           = { 79651, 378807, 1 }, --
    shadowstep             = { 79627, 36554 , 1 }, --
    shadowstep             = { 79608, 36554 , 1 }, --
    shiv                   = { 79645, 5938  , 1 }, --
    shiv                   = { 79506, 5938  , 1 }, --
    shrouded_suffocation   = { 79597, 385478, 1 }, --
    so_versatile           = { 79631, 381619, 2 }, --
    subterfuge             = { 79650, 108208, 1 }, --
    thistle_tea            = { 79620, 381623, 1 }, --
    tight_spender          = { 79488, 381621, 2 }, --
    tiny_toxic_blade       = { 79500, 381800, 1 }, --
    tricks_of_the_trade    = { 79626, 57934 , 1 }, --
    twist_the_knife        = { 79496, 381669, 1 }, --
    venom_rush             = { 79502, 152152, 1 }, --
    venomous_wounds        = { 79603, 79134 , 1 }, --
    vicious_venoms         = { 79505, 381634, 2 }, --
    vigor                  = { 79619, 14983 , 1 }, --
    virulent_poisons       = { 79640, 381543, 1 }, --
    zoldyck_recipe         = { 79501, 381798, 3 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    control_is_king    = 5530, -- 354406
    creeping_venom     = 141 , -- 354895
    dagger_in_the_dark = 5550, -- 198675
    death_from_above   = 3479, -- 269513
    dismantle          = 5405, -- 207777
    hemotoxin          = 830 , -- 354124
    maneuverability    = 3448, -- 197000
    smoke_bomb         = 3480, -- 212182
    system_shock       = 147 , -- 198145
    thick_as_thieves   = 5408, -- 221622
    veil_of_midnight   = 5517, -- 198952
} )


-- Auras
spec:RegisterAuras( {
    amplifying_poison = {
        id = 381664,
    },
    atrophic_poison = {
        id = 381637,
    },
    cloak_of_shadows = {
        id = 31224,
    },
    cold_blood = {
        id = 382245,
    },
    crimson_vial = {
        id = 185311,
    },
    deadly_poison = {
        id = 2823,
    },
    death_from_above = {
        id = 269513,
    },
    envenom = {
        id = 32645,
    },
    evasion = {
        id = 5277,
    },
    feint = {
        id = 1966,
    },
    indiscriminate_carnage = {
        id = 381802,
    },
    mastery_potent_assassin = {
        id = 76803,
    },
    numbing_poison = {
        id = 5761,
    },
    safe_fall = {
        id = 1860,
    },
    shadow_dance = {
        id = 185313,
    },
    shadowstep = {
        id = 36554,
    },
    shroud_of_concealment = {
        id = 114018,
    },
    sign_of_the_emissary = {
        id = 225788,
        duration = 3600,
        max_stack = 1,
    },
    slice_and_dice = {
        id = 315496,
    },
    stealth = {
        id = 1784,
    },
    wound_poison = {
        id = 8679,
        duration = 3600,
        max_stack = 1,
    },
} )


-- Abilities
spec:RegisterAbilities( {
    ambush = {
        id = 8676,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 50,
        spendType = "energy",

        startsCombat = true,
        texture = 132282,

        handler = function ()
        end,
    },


    amplifying_poison = {
        id = 381664,
        cast = 1.5,
        cooldown = 0,
        gcd = "totem",

        talent = "amplifying_poison",
        startsCombat = false,
        texture = 134207,

        handler = function ()
        end,
    },


    atrophic_poison = {
        id = 381637,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        talent = "atrophic_poison",
        startsCombat = false,
        texture = 132300,

        handler = function ()
        end,
    },


    blind = {
        id = 2094,
        cast = 0,
        cooldown = 120,
        gcd = "totem",

        talent = "blind",
        startsCombat = false,
        texture = 136175,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    cheap_shot = {
        id = 1833,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 40,
        spendType = "energy",

        startsCombat = true,
        texture = 132092,

        handler = function ()
        end,
    },


    cloak_of_shadows = {
        id = 31224,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "cloak_of_shadows",
        startsCombat = false,
        texture = 136177,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    cold_blood = {
        id = 382245,
        cast = 0,
        cooldown = 45,
        gcd = "off",

        talent = "cold_blood",
        startsCombat = false,
        texture = 135988,

        handler = function ()
        end,
    },


    crimson_tempest = {
        id = 121411,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        talent = "crimson_tempest",
        startsCombat = false,
        texture = 464079,

        handler = function ()
        end,
    },


    crimson_vial = {
        id = 185311,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        spend = 20,
        spendType = "energy",

        startsCombat = false,
        texture = 1373904,

        handler = function ()
        end,
    },


    deadly_poison = {
        id = 2823,
        cast = 1.5,
        cooldown = 0,
        gcd = "totem",

        talent = "deadly_poison",
        startsCombat = false,
        texture = 132290,

        handler = function ()
        end,
    },


    death_from_above = {
        id = 269513,
        cast = 0,
        cooldown = 30,
        gcd = "off",
        icd = 2,

        spend = 25,
        spendType = "energy",

        pvptalent = "death_from_above",
        startsCombat = false,
        texture = 1043573,

        handler = function ()
        end,
    },


    deathmark = {
        id = 360194,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "deathmark",
        startsCombat = false,
        texture = 4667421,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dismantle = {
        id = 207777,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        pvptalent = "dismantle",
        startsCombat = false,
        texture = 236272,

        handler = function ()
        end,
    },


    distract = {
        id = 1725,
        cast = 0,
        cooldown = 30,
        gcd = "totem",

        spend = 30,
        spendType = "energy",

        startsCombat = true,
        texture = 132289,

        handler = function ()
        end,
    },


    echoing_reprimand = {
        id = 385616,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 10,
        spendType = "energy",

        talent = "echoing_reprimand",
        startsCombat = false,
        texture = 3565450,

        handler = function ()
        end,
    },


    envenom = {
        id = 32645,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        startsCombat = false,
        texture = 132287,

        handler = function ()
        end,
    },


    evasion = {
        id = 5277,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "evasion",
        startsCombat = false,
        texture = 136205,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    exsanguinate = {
        id = 200806,
        cast = 0,
        cooldown = 45,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        talent = "exsanguinate",
        startsCombat = false,
        texture = 538040,

        handler = function ()
        end,
    },


    fan_of_knives = {
        id = 51723,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        startsCombat = true,
        texture = 236273,

        handler = function ()
        end,
    },


    feint = {
        id = 1966,
        cast = 0,
        cooldown = 15,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        talent = "feint",
        startsCombat = false,
        texture = 132294,

        handler = function ()
        end,
    },


    garrote = {
        id = 703,
        cast = 0,
        cooldown = 6,
        gcd = "totem",

        spend = 45,
        spendType = "energy",

        startsCombat = true,
        texture = 132297,

        handler = function ()
        end,
    },


    gouge = {
        id = 1776,
        cast = 0,
        cooldown = 20,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        talent = "gouge",
        startsCombat = false,
        texture = 132155,

        handler = function ()
        end,
    },


    indiscriminate_carnage = {
        id = 381802,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "indiscriminate_carnage",
        startsCombat = false,
        texture = 4667422,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    kick = {
        id = 1766,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        startsCombat = true,
        texture = 132219,

        handler = function ()
        end,
    },


    kidney_shot = {
        id = 408,
        cast = 0,
        cooldown = 20,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = true,
        texture = 132298,

        handler = function ()
        end,
    },


    kingsbane = {
        id = 385627,
        cast = 0,
        cooldown = 60,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        talent = "kingsbane",
        startsCombat = false,
        texture = 1259291,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    marked_for_death = {
        id = 137619,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "marked_for_death",
        startsCombat = false,
        texture = 236364,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    mutilate = {
        id = 1329,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 50,
        spendType = "energy",

        startsCombat = false,
        texture = 132304,

        handler = function ()
        end,
    },


    numbing_poison = {
        id = 5761,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        talent = "numbing_poison",
        startsCombat = false,
        texture = 136066,

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


    pick_lock = {
        id = 1804,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        startsCombat = true,
        texture = 136058,

        handler = function ()
        end,
    },


    pick_pocket = {
        id = 921,
        cast = 0,
        cooldown = 0.5,
        gcd = "off",

        startsCombat = true,
        texture = 133644,

        handler = function ()
        end,
    },


    poisoned_knife = {
        id = 185565,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 40,
        spendType = "energy",

        startsCombat = true,
        texture = 1373909,

        handler = function ()
        end,
    },


    rupture = {
        id = 1943,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 5,
        spendType = "combo_points",

        startsCombat = true,
        texture = 132302,

        handler = function ()
        end,
    },


    sap = {
        id = 6770,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 35,
        spendType = "energy",

        talent = "sap",
        startsCombat = false,
        texture = 132310,

        handler = function ()
        end,
    },


    sepsis = {
        id = 385408,
        cast = 0,
        cooldown = 90,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        talent = "sepsis",
        startsCombat = false,
        texture = 3636848,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    serrated_bone_spike = {
        id = 385424,
        cast = 0,
        charges = 3,
        cooldown = 30,
        recharge = 30,
        gcd = "totem",

        spend = 15,
        spendType = "energy",

        talent = "serrated_bone_spike",
        startsCombat = true,
        texture = 3578230,

        handler = function ()
        end,
    },


    shadow_dance = {
        id = 185313,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "off",

        talent = "shadow_dance",
        startsCombat = false,
        texture = 236279,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    shadowstep = {
        id = 36554,
        cast = 0,
        charges = 1,
        cooldown = 30,
        recharge = 30,
        gcd = "off",

        talent = "shadowstep",
        startsCombat = true,
        texture = 132303,

        handler = function ()
        end,
    },


    shiv = {
        id = 5938,
        cast = 0,
        cooldown = 25,
        gcd = "totem",

        spend = 20,
        spendType = "energy",

        talent = "shiv",
        startsCombat = true,
        texture = 135428,

        handler = function ()
        end,
    },


    shroud_of_concealment = {
        id = 114018,
        cast = 0,
        cooldown = 360,
        gcd = "totem",

        startsCombat = false,
        texture = 635350,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    slice_and_dice = {
        id = 315496,
        cast = 0,
        cooldown = 0,
        gcd = "totem",

        spend = 25,
        spendType = "energy",

        startsCombat = false,
        texture = 132306,

        handler = function ()
        end,
    },


    smoke_bomb = {
        id = 212182,
        cast = 0,
        cooldown = 180,
        gcd = "totem",

        pvptalent = "smoke_bomb",
        startsCombat = false,
        texture = 458733,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    sprint = {
        id = 2983,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 132307,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    stealth = {
        id = 1784,
        cast = 0,
        cooldown = 2,
        gcd = "off",

        startsCombat = false,
        texture = 132320,

        handler = function ()
        end,
    },


    thistle_tea = {
        id = 381623,
        cast = 0,
        charges = 3,
        cooldown = 60,
        recharge = 60,
        gcd = "off",

        talent = "thistle_tea",
        startsCombat = false,
        texture = 132819,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    tricks_of_the_trade = {
        id = 57934,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        talent = "tricks_of_the_trade",
        startsCombat = false,
        texture = 236283,

        handler = function ()
        end,
    },


    vanish = {
        id = 1856,
        cast = 0,
        charges = 1,
        cooldown = 120,
        recharge = 120,
        gcd = "off",

        startsCombat = false,
        texture = 132331,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    wound_poison = {
        id = 8679,
        cast = 1.5,
        cooldown = 0,
        gcd = "off",

        startsCombat = false,
        texture = 134197,

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Assassination", 20220917,
-- Notes
[[

]],
-- Priority
[[

]] )