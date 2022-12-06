-- PaladinHoly.lua
-- DF Pre-Patch Nov 2022

if UnitClassBase( "player" ) ~= "PALADIN" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 65 )

spec:RegisterResource( Enum.PowerType.HolyPower )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Paladin
    afterimage                      = { 81613, 385414, 1 },
    aspiration_of_divinity          = { 81622, 385416, 2 },
    avenging_wrath                  = { 81606, 31884 , 1 },
    blessing_of_freedom             = { 81600, 1044  , 1 },
    blessing_of_protection          = { 81616, 1022  , 1 },
    blessing_of_sacrifice           = { 81614, 6940  , 1 },
    blinding_light                  = { 81598, 115750, 1 },
    cavalier                        = { 81605, 230332, 1 },
    sanctified_wrath                = { 81620, 31884 , 1 },
    divine_purpose                  = { 81618, 223817, 1 },
    divine_steed                    = { 81632, 190784, 1 },
    fist_of_justice                 = { 81602, 234299, 2 },
    golden_path                     = { 81610, 377128, 1 },
    hallowed_ground                 = { 81509, 377043, 1 },
    holy_aegis                      = { 81609, 385515, 2 },
    holy_avenger                    = { 81618, 105809, 1 },
    improved_blessing_of_protection = { 81617, 384909, 1 },
    incandescence                   = { 81628, 385464, 1 },
    judgment_of_light               = { 81608, 183778, 1 },
    obduracy                        = { 81627, 385427, 1 },
    of_dusk_and_dawn                = { 81624, 385125, 1 },
    rebuke                          = { 81604, 96231 , 1 },
    recompense                      = { 81607, 384914, 1 },
    repentance                      = { 81598, 20066 , 1 },
    sacrifice_of_the_just           = { 81607, 384820, 1 },
    seal_of_alacrity                = { 81619, 385425, 2 },
    seal_of_clarity                 = { 81612, 384815, 2 },
    seal_of_mercy                   = { 81611, 384897, 2 },
    seal_of_might                   = { 81621, 385450, 2 },
    seal_of_order                   = { 81623, 385129, 1 },
    seal_of_reprisal                = { 81629, 377053, 2 },
    seal_of_the_crusader            = { 81626, 385728, 2 },
    seal_of_the_templar             = { 81631, 377016, 1 },
    seasoned_warhorse               = { 81631, 376996, 1 },
    seraphim                        = { 81620, 152262, 1 },
    touch_of_light                  = { 81628, 385349, 1 },
    turn_evil                       = { 81630, 10326 , 1 },
    unbreakable_spirit              = { 81615, 114154, 1 },
    zealots_paragon                 = { 81625, 391142, 1 },

    -- Holy
    aura_mastery                    = { 81567, 31821 , 1 },
    auras_of_swift_vengeance        = { 81601, 385639, 1 },
    auras_of_the_resolute           = { 81599, 385633, 1 },
    avenging_crusader               = { 81584, 216331, 1 },
    awakening                       = { 81592, 248033, 2 },
    barrier_of_faith                = { 81558, 148039, 1 },
    beacon_of_faith                 = { 81554, 156910, 1 },
    beacon_of_virtue                = { 81554, 200025, 1 },
    bestow_faith                    = { 81564, 223306, 1 },
    blessing_of_summer              = { 81593, 388007, 1 },
    boundless_salvation             = { 81587, 392951, 1 },
    breaking_dawn                   = { 81582, 387879, 1 },
    avenging_wrath_might            = { 81584, 31884 , 1 },
    commanding_light                = { 81580, 387781, 2 },
    crusaders_might                 = { 81594, 196926, 2 },
    divine_favor                    = { 81570, 210294, 1 },
    divine_glimpse                  = { 81585, 387805, 2 },
    divine_insight                  = { 81572, 392914, 1 },
    divine_protection               = { 81568, 498   , 1 },
    divine_resonance                = { 81596, 387893, 1 },
    divine_revelations              = { 81578, 387808, 1 },
    divine_toll                     = { 81579, 375576, 1 },
    echoing_blessings               = { 81556, 387801, 1 },
    empyreal_ward                   = { 81575, 387791, 1 },
    empyrean_legacy                 = { 81591, 387170, 1 },
    glimmer_of_light                = { 81595, 325966, 1 },
    hammer_of_wrath                 = { 81510, 24275 , 1 },
    holy_light                      = { 81569, 82326 , 1 },
    holy_prism                      = { 81577, 114165, 1 },
    holy_shock                      = { 81555, 20473 , 1 },
    illumination                    = { 81572, 387993, 1 },
    imbued_infusions                = { 81557, 392961, 1 },
    improved_cleanse                = { 81508, 393024, 1 },
    inflorescence_of_the_sunwell    = { 81591, 392907, 1 },
    judgment_3                      = { 92220, 231644, 1 },
    lay_on_hands                    = { 81597, 633   , 1 },
    light_of_dawn                   = { 81565, 85222 , 1 },
    light_of_the_martyr             = { 81561, 183998, 1 },
    lights_hammer                   = { 81577, 114158, 1 },
    maraads_dying_breath            = { 81559, 388018, 1 },
    moment_of_compassion            = { 81571, 387786, 1 },
    power_of_the_silver_hand        = { 81589, 200474, 1 },
    protection_of_tyr               = { 81566, 200430, 1 },
    radiant_onslaught               = { 81574, 231667, 1 },
    relentless_inquisitor           = { 81590, 383388, 2 },
    resplendent_light               = { 81571, 392902, 1 },
    rule_of_law                     = { 81562, 214202, 1 },
    saved_by_the_light              = { 81563, 157047, 1 },
    second_sunrise                  = { 81583, 200482, 2 },
    shining_savior                  = { 81576, 388005, 1 },
    tirions_devotion                = { 81573, 392928, 1 },
    tower_of_radiance               = { 81586, 231642, 1 },
    tyrs_deliverance                = { 81588, 200652, 1 },
    unending_light                  = { 81564, 387998, 1 },
    untempered_dedication           = { 81560, 387814, 1 },
    unwavering_spirit               = { 81566, 392911, 1 },
    veneration                      = { 81581, 392938, 1 },
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    aura_of_reckoning       = 5553,
    avenging_light          = 82  ,
    blessed_hands           = 88  ,
    cleanse_the_weak        = 642 ,
    darkest_before_the_dawn = 86  ,
    divine_vision           = 640 ,
    hallowed_ground         = 3618,
    judgments_of_the_pure   = 5421,
    lights_grace            = 859 ,
    precognition            = 5501,
    spreading_the_word      = 87  ,
    ultimate_sacrifice      = 85  ,
    vengeance_aura          = 5537,
} )


-- Auras
spec:RegisterAuras( {
    afterimage = {
        id = 385414,
    },
    aspiration_of_divinity = {
        id = 385416,
    },
    aura_mastery = {
        id = 31821,
        duration = 8,
        max_stack = 1,
    },
    avenging_crusader = {
        id = 216331,
        duration = 25,
        max_stack = 1,
    },
    avenging_wrath = {
        id = 31884,
        duration = 25,
        max_stack = 1,
    },
    barrier_of_faith = {
        id = 148039,
        duration = 18,
        max_stack = 1,
    },
    beacon_of_faith = {
        id = 156910,
        duration = 3600,
        max_stack = 1,
    },
    beacon_of_light = {
        id = 53563,
        duration = 3600,
        max_stack = 1,
    },
    beacon_of_virtue = {
        id = 200025,
        duration = 8,
        max_stack = 1,
    },
    bestow_faith = {
        id = 223306,
        duration = 5,
        max_stack = 1,
    },
    blessing_of_autumn = {
        id = 388010,
        duration = 30,
        max_stack = 1,
    },
    blessing_of_freedom = {
        id = 1044,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    blessing_of_protection = {
        id = 1022,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    blessing_of_sacrifice = {
        id = 6940,
        duration = 12,
        max_stack = 1,
    },
    blessing_of_spring = {
        id = 388013,
        duration = 30,
        max_stack = 1,
    },
    blessing_of_summer = {
        id = 388007,
        duration = 30,
        max_stack = 1,
    },
    blessing_of_winter = {
        id = 388011,
        duration = 30,
        max_stack = 1,
    },
    blinding_light = {
        id = 115750,
    },
    concentration_aura = {
        id = 317920,
        duration = 3600,
        max_stack = 1,
    },
    consecration = {
        id = 26573,
    },
    contemplation = {
        id = 121183,
        duration = 8,
        max_stack = 1,
    },
    crusader_aura = {
        id = 32223,
        duration = 3600,
        max_stack = 1,
    },
    devotion_aura = {
        id = 465,
        duration = 3600,
        max_stack = 1,
    },
    divine_favor = {
        id = 210294,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
    },
    divine_protection = {
        id = 498,
        duration = 8,
        max_stack = 1,
    },
    divine_purpose = {
        id = 223819,
        duration = 12,
        max_stack = 1,
    },
    divine_resonance = {
        id = 387895,
        duration = 15,
        max_stack = 1,
    },
    divine_shield = {
        id = 642,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    divine_steed = {
        id = 276112,
        duration = 6.15,
        max_stack = 1,
    },
    echoing_freedom = {
        id = 339321,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    echoing_protection = {
        id = 339324,
        duration = 8,
        type = "Magic",
        max_stack = 1,
    },
    fleshcraft = {
        id = 324631,
        duration = 120,
        max_stack = 1,
    },
    forbearance = {
        id = 25771,
        duration = 30,
        max_stack = 1,
    },
    golden_path = {
        id = 377128,
    },
    holy_avenger = {
        id = 105809,
        duration = 20,
        max_stack = 1,
    },
    incandescence = {
        id = 385464,
    },
    infusion_of_light = {
        id = 54149,
        duration = 15,
        max_stack = 2,
        copy = 53576
    },
    light_of_the_martyr = {
        id = 196917,
        duration = 5.113,
        max_stack = 1,
    },
    mastery_lightbringer = {
        id = 183997,
    },
    of_dusk_and_dawn = {
        id = 385125,
    },
    recompense = {
        id = 384914,
    },
    retribution_aura = {
        id = 183435,
        duration = 3600,
        max_stack = 1,
    },
    rule_of_law = {
        id = 214202,
        duration = 10,
        max_stack = 1,
    },
    seal_of_clarity = {
        id = 384815,
    },
    seal_of_mercy = {
        id = 384897,
    },
    seal_of_might = {
        id = 385450,
    },
    seal_of_the_templar = {
        id = 377016,
    },
    seraphim = {
        id = 152262,
        duration = 15,
        max_stack = 1,
    },
    shield_of_the_righteous = {
        id = 132403,
        duration = 4.5,
        max_stack = 1,
    },
    shielding_words = {
        id = 338788,
        duration = 10,
        type = "Magic",
        max_stack = 1,
    },
    tyrs_deliverance = {
        id = 200652,
        duration = 10,
        max_stack = 1,
    },
    unending_light = {
        id = 394709,
        duration = 30,
        type = "Magic",
        max_stack = 6,
    },
    untempered_dedication = {
        id = 387815,
        duration = 15,
        max_stack = 5,
    },
    vanquishers_hammer = {
        id = 328204,
    },
    zealots_paragon = {
        id = 391142,
    },
} )


-- Abilities
spec:RegisterAbilities( {
    absolution = {
        id = 212056,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 1030102,

        handler = function ()
        end,
    },


    aura_mastery = {
        id = 31821,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,
        texture = 135872,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("aura_mastery")
        end,
    },


    avenging_crusader = {
        id = 216331,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0.5,
        spendType = "mana",

        startsCombat = false,
        texture = 589117,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("avenging_crusader")
        end,
    },


    avenging_wrath = {
        id = 31884,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 135875,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("avenging_wrath")
        end,
    },


    barrier_of_faith = {
        id = 148039,
        cast = 0,
        cooldown = 25,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = false,
        texture = 4067370,

        handler = function ()
            applyBuff("barrier_of_faith")
        end,
    },


    beacon_of_faith = {
        id = 156910,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 1030095,

        handler = function ()
            applyBuff("beacon_of_faith")
        end,
    },


    beacon_of_light = {
        id = 53563,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 236247,

        handler = function ()
            applyBuff("beacon_of_light")
        end,
    },


    beacon_of_virtue = {
        id = 200025,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = false,
        texture = 1030094,

        handler = function ()
            applyBuff("beacon_of_virtue")
        end,
    },


    bestow_faith = {
        id = 223306,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 236249,

        handler = function ()
            applyBuff("bestow_faith")
        end,
    },


    blessing_of_autumn = {
        id = 388010,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636843,

        handler = function ()
            setCooldown( "blessing_of_winter", 45 )
            setCooldown( "blessing_of_summer", 90 )
            setCooldown( "blessing_of_spring", 135 )
        end,
    },


    blessing_of_freedom = {
        id = 1044,
        cast = 0,
        charges = 1,
        cooldown = 25,
        recharge = 25,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 135968,

        handler = function ()
            applyBuff("blessing_of_freedom")
        end,
    },


    blessing_of_protection = {
        id = 1022,
        cast = 0,
        charges = 1,
        cooldown = 300,
        recharge = 300,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 135964,

        toggle = "defensives",
        defensives = true,

        handler = function ()
            applyDebuff("forbearance")
            applyBuff("blessing_of_protection")
        end,
    },


    blessing_of_sacrifice = {
        id = 6940,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 135966,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("blessing_of_sacrifice")
        end,
    },


    blessing_of_spring = {
        id = 388013,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636844,

        handler = function ()
            setCooldown( "blessing_of_summer", 45 )
            setCooldown( "blessing_of_autumn", 90 )
            setCooldown( "blessing_of_winter", 135 )
        end,
    },


    blessing_of_summer = {
        id = 388007,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636845,

        handler = function ()
            setCooldown( "blessing_of_autumn", 45 )
            setCooldown( "blessing_of_winter", 90 )
            setCooldown( "blessing_of_spring", 135 )
        end,
    },


    blessing_of_winter = {
        id = 388011,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,
        texture = 3636846,

        handler = function ()
            setCooldown( "blessing_of_spring", 45 )
            setCooldown( "blessing_of_summer", 90 )
            setCooldown( "blessing_of_autumn", 135 )
        end,
    },


    blinding_light = {
        id = 115750,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = true,
        texture = 571553,

        handler = function ()
            applyDebuff("blinding_light")
        end,
    },


    cleanse = {
        id = 4987,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 135949,

        handler = function ()
        end,
    },


    concentration_aura = {
        id = 317920,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135933,

        handler = function ()
            applyBuff("concentration_aura")
            removeBuff("devotion_aura")
            removeBuff("crusader_aura")
            removeBuff("retribution_aura")
        end,
    },


    consecration = {
        id = 26573,
        cast = 0,
        cooldown = 9,
        gcd = "spell",

        startsCombat = true,
        texture = 135926,

        handler = function ()
        end,
    },


    contemplation = {
        id = 121183,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        startsCombat = false,
        texture = 134916,

        handler = function ()
        end,
    },


    crusader_aura = {
        id = 32223,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135890,

        handler = function ()
            applyBuff("crusader_aura")
            removeBuff("devotion_aura")
            removeBuff("retribution_aura")
            removeBuff("concentration_aura")
        end,
    },


    crusader_strike = {
        id = 35395,
        cast = 0,
        charges = 2,
        cooldown = 6,
        recharge = 6,
        gcd = "spell",

        spend = 0.11,
        spendType = "mana",

        startsCombat = true,
        texture = 135891,

        handler = function ()
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )

            if talent.crusaders_might.enabled then
                setCooldown( "holy_shock", max( 0, cooldown.holy_shock.remains - 2.0 ) )
            end
        end,
    },


    devotion_aura = {
        id = 465,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135893,

        handler = function ()
            applyBuff("devotion_aura")
            removeBuff("retribution_aura")
            removeBuff("crusader_aura")
            removeBuff("concentration_aura")
        end,
    },


    divine_favor = {
        id = 210294,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        startsCombat = false,
        texture = 135915,

        handler = function ()
            applyBuff("divine_favor")
        end,
    },


    divine_protection = {
        id = 498,
        cast = 0,
        cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 60 end,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 524353,

        toggle = "defensives",
        defensives = true,

        handler = function ()
            applyBuff("divine_protection")
        end,
    },


    divine_shield = {
        id = 642,
        cast = 0,
        cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 300 end,
        gcd = "spell",

        startsCombat = false,
        texture = 524354,

        toggle = "defensives",
        defensives = true,

        handler = function ()
            applyDebuff("forbearance")
            applyBuff("divine_shield")
        end,
    },


    divine_steed = {
        id = 190784,
        cast = 0,
        charges = 2,
        cooldown = 45,
        recharge = 45,
        gcd = "spell",

        startsCombat = false,
        texture = 1360759,

        handler = function ()
            applyBuff("divine_steed")
        end,
    },


    divine_toll = {
        id = 375576,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = true,
        texture = 3565448,

        toggle = "cooldowns",

        handler = function ()
            gain( buff.holy_avenger.up and 5 or 2, "holy_power" )
        end,
    },


    flash_of_light = {
        id = 19750,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.22,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
            removeBuff("infusion_of_light")
            removeBuff("divine_favor")
        end,
    },


    fleshcraft = {
        id = 324631,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 3586267,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("fleshcraft")
        end,
    },


    hammer_of_justice = {
        id = 853,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = true,
        texture = 135963,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff("hammer_of_justice")
        end,
    },


    hammer_of_wrath = {
        id = 24275,
        cast = 0,
        cooldown = 7.5,
        gcd = "spell",

        startsCombat = true,
        texture = 613533,

        usable = function () return target.health_pct < 20 end,

        handler = function ()
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
        end,
    },


    hand_of_reckoning = {
        id = 62124,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 135984,

        handler = function ()
            applyDeuff("hand_of_reckoning")
        end,
    },


    holy_avenger = {
        id = 105809,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,
        texture = 571555,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("holy_avenger")
        end,
    },


    holy_light = {
        id = 82326,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.15,
        spendType = "mana",

        startsCombat = false,
        texture = 135981,

        handler = function ()
            removeBuff("infusion_of_light")
            removeBuff("divine_favor")
        end,
    },


    holy_prism = {
        id = 114165,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        spend = 0.13,
        spendType = "mana",

        startsCombat = true,
        texture = 613408,

        handler = function ()
        end,
    },


    holy_shock = {
        id = 20473,
        cast = 0,
        cooldown = 7.5,
        gcd = "spell",

        spend = 0.16,
        spendType = "mana",

        startsCombat = true,
        texture = 135972,

        handler = function ()
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
        end,
    },


    intercession = {
        id = 391054,
        cast = 2.0003372583008,
        cooldown = 600,
        gcd = "spell",

        spend = 0,
        spendType = "holy_power",

        startsCombat = false,
        texture = 4726195,

        handler = function ()
        end,
    },


    judgment = {
        id = 275773,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 135959,

        handler = function ()
        end,
    },


    lay_on_hands = {
        id = 633,
        cast = 0,
        cooldown = function () return ( talent.unbreakable_spirit.enabled and 0.7 or 1 ) * 600 end,
        gcd = "spell",

        startsCombat = false,
        texture = 135928,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff("forbearance")
        end,
    },


    light_of_dawn = {
        id = 85222,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = false,
        texture = 461859,

        handler = function ()
            removeBuff("divine_purpose")
        end,
    },


    light_of_the_martyr = {
        id = 183998,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.07,
        spendType = "mana",

        startsCombat = false,
        texture = 1360762,

        handler = function ()
            removeBuff( "maraads_dying_breath" )
        end,
    },


    lights_hammer = {
        id = 114158,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.18,
        spendType = "mana",

        startsCombat = true,
        texture = 613955,

        handler = function ()
        end,
    },


    rebuke = {
        id = 96231,
        cast = 0,
        cooldown = 15,
        gcd = "off",

        startsCombat = true,
        texture = 523893,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },


    redemption = {
        id = 7328,
        cast = 10.000345582886,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 135955,

        handler = function ()
        end,
    },


    repentance = {
        id = 20066,
        cast = 1.7,
        cooldown = 15,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 135942,

        handler = function ()
            applyDebuff("repentance")
        end,
    },


    retribution_aura = {
        id = 183435,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        startsCombat = false,
        texture = 135889,

        handler = function ()
            applyBuff("retribution_aura")
            removeBuff("devotion_aura")
            removeBuff("crusader_aura")
            removeBuff("concentration_aura")
        end,
    },


    rule_of_law = {
        id = 214202,
        cast = 0,
        charges = 2,
        cooldown = 30,
        recharge = 30,
        gcd = "off",

        startsCombat = false,
        texture = 571556,

        handler = function ()
            applyBuff("rule_of_law")
        end,
    },


    seraphim = {
        id = 152262,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 3,
        spendType = "holy_power",

        startsCombat = false,
        texture = 1030103,

        handler = function ()
            applyBuff("seraphim")
        end,
    },


    shield_of_the_righteous = {
        id = 53600,
        cast = 0,
        cooldown = 1,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = true,
        texture = 236265,

        handler = function ()
            applyBuff("shield_of_the_righteous")
        end,
    },


    turn_evil = {
        id = 10326,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",

        spend = 0.1,
        spendType = "mana",

        startsCombat = true,
        texture = 571559,

        handler = function ()
            applyDebuff("turn_evil")
        end,
    },


    tyrs_deliverance = {
        id = 200652,
        cast = 2,
        cooldown = 90,
        gcd = "spell",

        startsCombat = false,
        texture = 1122562,

        toggle = "cooldowns",

        handler = function ()
            applyBuff("tyrs_deliverance")
        end,
    },


    vanquishers_hammer = {
        id = 328204,
        cast = 0,
        charges = 2,
        cooldown = 30,
        recharge = 30,
        gcd = "spell",

        startsCombat = true,
        texture = 3578228,

        handler = function ()
            gain( buff.holy_avenger.up and 3 or 1, "holy_power" )
            applyBuff("vanquishers_hammer")
        end,
    },


    word_of_glory = {
        id = 85673,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function ()
            if buff.divine_purpose.up then return 0 end
            return 3
        end,
        spendType = "holy_power",

        startsCombat = false,
        texture = 133192,

        handler = function ()
            removeBuff("divine_purpose")
        end,
    },
} )