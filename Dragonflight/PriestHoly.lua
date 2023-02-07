-- PriestHoly.lua
-- DF Pre-Patch Nov 2022

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 257 )

spec:RegisterResource( Enum.PowerType.Insanity )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Priest
    angelic_bulwark            = { 82675, 108945, 1 },
    angelic_feather            = { 82703, 121536, 1 },
    angels_mercy               = { 82678, 238100, 1 },
    apathy                     = { 82689, 390668, 1 },
    binding_heals              = { 82678, 368275, 1 },
    blessed_recovery           = { 82720, 390767, 1 },
    body_and_soul              = { 82706, 64129 , 1 },
    crystalline_reflection     = { 82681, 373457, 2 },
    death_and_madness          = { 82711, 321291, 1 },
    dispel_magic               = { 82715, 528   , 1 },
    dominate_mind              = { 82710, 205364, 1 },
    focused_mending            = { 82719, 372354, 1 },
    from_darkness_comes_light  = { 82707, 390615, 1 },
    holy_nova                  = { 82701, 132157, 1 },
    improved_fade              = { 82686, 390670, 2 },
    improved_flash_heal        = { 82714, 393870, 1 },
    improved_mass_dispel       = { 82698, 341167, 1 },
    inspiration                = { 82696, 390676, 1 },
    leap_of_faith              = { 82716, 73325 , 1 },
    lights_inspiration         = { 82679, 373450, 2 },
    manipulation               = { 82672, 390996, 2 },
    mass_dispel                = { 82699, 32375 , 1 },
    mind_control               = { 82710, 605   , 1 },
    mindgames                  = { 82687, 375901, 1 },
    move_with_grace            = { 82702, 390620, 1 },
    phantasm                   = { 82556, 108942, 1 },
    power_infusion             = { 82694, 10060 , 1 },
    power_word_life            = { 82676, 373481, 1 },
    protective_light           = { 82707, 193063, 1 },
    psychic_voice              = { 82695, 196704, 1 },
    rhapsody                   = { 82700, 390622, 1 },
    sanlayn                    = { 82690, 199855, 1 },
    shackle_undead             = { 82693, 9484  , 1 },
    shattered_perceptions      = { 82673, 391112, 1 },
    sheer_terror               = { 82708, 390919, 1 },
    spell_warding              = { 82720, 390667, 1 },
    surge_of_light             = { 82677, 109186, 2 },
    throes_of_pain             = { 82709, 377422, 2 },
    tithe_evasion              = { 82688, 373223, 1 },
    translucent_image          = { 82685, 373446, 1 },
    twins_of_the_sun_priestess = { 82683, 373466, 1 },
    twist_of_fate              = { 82684, 390972, 2 },
    unwavering_will            = { 82697, 373456, 2 },
    vampiric_embrace           = { 82691, 15286 , 1 },
    void_shield                = { 82692, 280749, 1 },
    void_shift                 = { 82674, 108968, 1 },
    void_tendrils              = { 82708, 108920, 1 },
    words_of_the_pious         = { 82721, 377438, 1 },

    -- Holy
    afterlife                  = { 82635, 196707, 1 },
    answered_prayers           = { 82608, 391387, 2 },
    apotheosis                 = { 82610, 200183, 1 },
    benediction                = { 82641, 193157, 1 },
    burning_vehemence          = { 82640, 372307, 1 },
    censure                    = { 82619, 200199, 1 },
    circle_of_healing          = { 82624, 204883, 1 },
    cosmic_ripple              = { 82630, 238136, 1 },
    crisis_management          = { 82627, 390954, 2 },
    desperate_times            = { 82609, 391381, 2 },
    divine_hymn                = { 82621, 64843 , 1 },
    divine_image               = { 82554, 392988, 1 },
    divine_service             = { 82642, 391233, 1 },
    divine_star                = { 82682, 110744, 1 },
    divine_word                = { 82554, 372760, 1 },
    empowered_renew            = { 82612, 391339, 1 },
    empyreal_blaze             = { 82607, 372616, 1 },
    enlightenment              = { 82618, 193155, 1 },
    everlasting_light          = { 82622, 391161, 1 },
    gales_of_song              = { 82613, 372370, 2 },
    guardian_angel             = { 82636, 200209, 1 },
    guardian_spirit            = { 82637, 47788 , 1 },
    guardians_of_the_light     = { 82636, 196437, 1 },
    halo                       = { 82682, 120517, 1 },
    harmonious_apparatus       = { 82611, 390994, 2 },
    healing_chorus             = { 82625, 390881, 1 },
    holy_mending               = { 82641, 391154, 1 },
    holy_word_chastise         = { 82639, 88625 , 1 },
    holy_word_salvation        = { 82610, 265202, 1 },
    holy_word_sanctify         = { 82632, 34861 , 1 },
    holy_word_serenity         = { 82638, 2050  , 1 },
    improved_purify            = { 82705, 390632, 1 },
    light_of_the_naaru         = { 82629, 196985, 2 },
    lightweaver                = { 82603, 390992, 1 },
    lightwell                  = { 82603, 372835, 1 },
    miracle_worker             = { 82605, 235587, 1 },
    orison                     = { 82626, 390947, 1 },
    pontifex                   = { 82628, 390980, 1 },
    prayer_circle              = { 82625, 321377, 1 },
    prayer_of_healing          = { 82631, 596   , 1 },
    prayer_of_mending          = { 82718, 33076 , 1 },
    prayerful_litany           = { 82623, 391209, 1 },
    prayers_of_the_virtuous    = { 82616, 390977, 2 },
    prismatic_echoes           = { 82614, 390967, 2 },
    rapid_recovery             = { 82612, 391368, 1 },
    renew                      = { 82717, 139   , 1 },
    renewed_faith              = { 82620, 341997, 1 },
    resonant_words             = { 82604, 372309, 2 },
    restitution                = { 82605, 391124, 1 },
    revitalizing_prayers       = { 82633, 391208, 1 },
    sanctified_prayers         = { 82633, 196489, 1 },
    say_your_prayers           = { 82615, 391186, 1 },
    searing_light              = { 82606, 372611, 2 },
    shadow_word_death          = { 82712, 32379 , 1 },
    shadowfiend                = { 82713, 34433 , 1 },
    symbol_of_hope             = { 82617, 64901 , 1 },
    trail_of_light             = { 82634, 200128, 2 },
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    cardinal_mending       = 115 ,
    catharsis              = 5485,
    delivered_from_evil    = 1927,
    divine_ascension       = 5366,
    eternal_rest           = 5482,
    greater_heal           = 112 ,
    holy_ward              = 101 ,
    precognition           = 5499,
    purification           = 5478,
    purified_resolve       = 5479,
    ray_of_hope            = 127 ,
    sanctified_ground      = 108 ,
    spirit_of_the_redeemer = 124 ,
    strength_of_soul       = 5476,
    thoughtsteal           = 5365,
} )


-- Auras
spec:RegisterAuras( {
    apathy = {
        id = 390669,
        duration = 4,
        max_stack = 1
    },
    apotheosis = {
        id = 200183,
        duration = 20,
        max_stack = 1
    },
    body_and_soul = {
        id = 65081,
        duration = 3,
        max_stack = 1
    },
    desperate_prayer = {
        id = 19236,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    divine_ascension_immune = {
        id = 328530,
        duration = 1,
        max_stack = 1
    },
    divine_ascension = {
        id = 329543,
        duration = 10,
        max_stack = 1
    },
    divine_hymn = {
        id = 64843,
        duration = 8,
        tick_time = 2,
        max_stack = 1
    },
    divine_hymn_buff = {
        id = 64844,
        duration = 15,
        max_stack = 5
    },
    divine_word = {
        id = 372760,
        duration = 10,
        max_stack = 1
    },
    dominate_mind = {
        id = 205364,
        duration = 30,
        max_stack = 1
    },
    empyreal_blaze = {
        id = 372617,
        duration = 30,
        max_stack = 3
    },
    fade = {
        id = 586,
        duration = 10,
        max_stack = 1
    },
    focused_will = {
        id = 45242,
        duration = 8,
        max_stack = 1
    },
    guardian_spirit = {
        id = 47788,
        duration = 10,
        max_stack = 1
    },
    healing_chorus = {
        id = 390885,
        duration = 20,
        max_stack = 50
    },
    holy_fire = {
        id = 14914,
        duration = 7,
        tick_time = 1,
        max_stack = 1
    },
    holy_ward = {
        id = 213610,
        duration = 15,
        max_stack = 1
    },
    inspiration = {
        id = 390677,
        duration = 15,
        max_stack = 1
    },
    leap_of_faith = {
        id = 73325,
        duration = 1.5,
        max_stack = 1
    },
    lightweaver = {
        id = 390993,
        duration = 20,
        max_stack = 2
    },
    lightwell = {
        id = 372835,
        duration = 180,
        max_stack = 15
    },
    mind_control = {
        id = 605,
        duration = 30,
        max_stack = 1
    },
    mind_soothe = {
        id = 453,
        duration = 20,
        max_stack = 1
    },
    mind_vision = {
        id = 2096,
        duration = 60,
        max_stack = 1
    },
    mindgames = {
        id = 375901,
        duration = function() return 5 + ( 2 * talent.shattered_perceptions.rank ) end,
        max_stack = 1
    },
    pontifex = {
        id = 390989,
        duration = 30,
        max_stack = 2
    },
    power_infusion = {
        id = 10060,
        duration = 20,
        max_stack = 1
    },
    power_word_fortitude = {
        id = 21562,
        duration = 3600,
        max_stack = 1
    },
    power_word_shield = {
        id = 17,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    prayer_circle = {
        id = 321379,
        duration = 8,
        max_stack = 1
    },
    psychic_scream = {
        id = 8122,
        duration = 8,
        max_stack = 1
    },
    ray_of_hope = {
        id = 232707,
        duration = 6,
        max_stack = 1
    },
    renew = {
        id = 139,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    sanctified_prayers = {
        id = 196490,
        duration = 15,
        max_stack = 1
    },
    shackle_undead = {
        id = 9484,
        duration = 50,
        max_stack = 1
    },
    shadow_word_pain = {
        id = 589,
        duration = 16,
        tick_time = 2,
        max_stack = 1
    },
    shadowfiend = {
        id = 34433,
        duration = 15,
        max_stack = 1
    },
    symbol_of_hope = {
        id = 64901,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    symbol_of_hope_buff = {
        id = 265144,
        duration = 1.1,
        max_stack = 1
    },
    vampiric_embrace = {
        id = 15286,
        duration = 15,
        tick_time = 0.5,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    -- Reset the cooldown of your Holy Words, and enter a pure Holy form for 20 sec, increasing the cooldown reductions to your Holy Words by 300% and reducing their cost by 100%.
    apotheosis = {
        id = 200183,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 1060983,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "apotheosis" )
            setCooldown( "holy_word_chastise", 0 )
            setCooldown( "holy_word_sanctify", 0 )
            setCooldown( "holy_word_serenity", 0 )
        end,
    },

    -- Heals the target and 4 injured allies within 30 yards of the target for 1,968.
    circle_of_healing = {
        id = 204883,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135887,

        handler = function ()
        end,
    },

    -- You ascend into the air out of harm's way. While floating, your spell range is increased by 50%, but you are only able to cast Holy spells.
    divine_ascension = {
        id = 328530,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        startsCombat = false,
        texture = 642580,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "divine_ascension" )
        end,
    },

    divine_hymn = {
        id = 64843,
        cast = 8,
        channeled = true,
        cooldown = 180,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 237540,

        toggle = "cooldowns",

        start = function ()
            applyBuff( "divine_hymn_buff" )
        end,
    },

    divine_star = {
        id = 110744,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 537026,

        handler = function ()
        end,
    },

    -- The effectiveness of your next Holy Word: Serenity, Sanctify, or Chastise is increased by 50% and grants a corresponding Divine Favor for 15 sec. Chastise: Increases your damage by 30% and Smite has a 40% chance to apply Holy Fire. Sanctify: Blesses the target area, healing up to 6 allies for 8,655 over 15 sec. Serenity: Flash Heal, Heal, and Renew heal for 30% more, have a 20% increased chance to critically strike, and cost 20% less mana.
    divine_word = {
        id = 372760,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        startsCombat = false,
        texture = 521584,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    dominate_mind = {
        id = 205364,
        cast = 1.8,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 1386549,

        handler = function ()
            applyDebuff( "dominate_mind" )
        end,
    },

    -- Refreshes Holy Fire. Your next 3 casts of Holy Fire cost no Mana, incur no cooldown, and cast instantly. Whenever Holy Fire is reapplied, its duration is now extended instead.
    empyreal_blaze = {
        id = 372616,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 500,
        spendType = "mana",

        startsCombat = false,
        texture = 525023,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "empyreal_blaze" )
            setCooldown( "holy_fire", 0 )
        end,
    },
    fade = {
        id = 586,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        startsCombat = false,
        texture = 135994,

        handler = function ()
            applyBuff( "fade" )
        end,
    },
    flash_heal = {
        id = 2061,
        cast = 1.35,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
            removeBuff( "resonant_words" )
            reduceCooldown( "holy_word_serenity", 6 )
            if buff.apotheosis.up then
                reduceCooldown ( "holy_word_serenity", 12 )
            end
            if talent.lightweaver.enabled then
                addStack( "lightweaver" )
            end
        end,
    },
    greater_heal = {
        id = 289666,
        cast = 3,
        cooldown = 12,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 135915,

        handler = function ()
        end,
    },

    -- Calls upon a guardian spirit to watch over the friendly target for 10 sec, increasing healing received by 60%. If the target would die, the Spirit sacrifices itself and restores the target to 40% health. Castable while stunned. Cannot save the target from massive damage.
    guardian_spirit = {
        id = 47788,
        cast = 0,
        cooldown = 180,
        gcd = "off",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 237542,

        toggle = "defensives",

        handler = function ()
            applyBuff( "guardian_spirit" )
        end,
    },

    -- Creates a ring of Holy energy around you that quickly expands to a 30 yd radius, healing allies for 3,176 and dealing 3,082 Holy damage to enemies. Healing reduced beyond 6 targets.
    halo = {
        id = 120517,
        cast = 1.5,
        cooldown = 40,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 632352,

        handler = function ()
        end,
    },
    heal = {
        id = 2060,
        cast = 2.25,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 135913,

        handler = function ()
            reduceCooldown( "holy_word_serenity", 6 )
            if buff.apotheosis.up then
                reduceCooldown ( "holy_word_serenity", 12 )
            end
            removeStack( "lightweaver" )
            removeBuff( "resonant_words" )
        end,
    },
    holy_fire = {
        id = 14914,
        cast = 1.5,
        cooldown = 10,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 135972,

        handler = function ()
            applyDebuff( "holy_fire" )
            if talent.manipulation.enabled then
                reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank )
            end
        end,
    },
    holy_nova = {
        id = 132157,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135922,

        handler = function ()
            removeBuff( "rhapsody" )
        end,
    },
    holy_ward = {
        id = 213610,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 458722,

        handler = function ()
            applyBuff( "holy_ward" )
        end,
    },
    holy_word_chastise = {
        id = 88625,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 135886,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "holy_word_chastise" )
        end,
    },
    holy_word_salvation = {
        id = 265202,
        cast = 2.5,
        cooldown = 720,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        startsCombat = false,
        texture = 458225,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "renew" )
            addStack( "prayer_of_mending", 2 )
        end,
    },
    holy_word_sanctify = {
        id = 34861,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 237541,

        toggle = "cooldowns",

        handler = function ()
            reduceCooldown( "holy_word_salvation", 30 )
        end,
    },
    holy_word_serenity = {
        id = 2050,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 135937,

        toggle = "cooldowns",

        handler = function ()
            reduceCooldown( "holy_word_salvation", 30 )
        end,
    },
    leap_of_faith = {
        id = 73325,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 463835,

        toggle = "cooldowns",

        handler = function ()
            if talent.body_and_soul.enabled then
                applyBuff( "body_and_soul" )
            end
        end,
    },
    levitate = {
        id = 1706,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135928,

        handler = function ()
            applyBuff( "levitate" )
        end,
    },
    lightwell = {
        id = 372835,
        cast = 0.5,
        cooldown = 180,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 135980,

        toggle = "cooldowns",

        handler = function ()
            addStack( "lightwell", 15 )
        end,
    },
    mass_dispel = {
        id = 32375,
        cast = 0.5,
        cooldown = 45,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = true,
        texture = 135739,

        handler = function ()
        end,
    },
    mass_resurrection = {
        id = 212036,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 413586,

        handler = function ()
        end,
    },
    mind_control = {
        id = 605,
        cast = 1.8,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 136206,

        handler = function ()
            applyDebuff( "mind_control" )
        end,
    },
    mind_soothe = {
        id = 453,
        cast = 0,
        cooldown = 5,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135933,

        handler = function ()
            applyDebuff( "mind_soothe" )
        end,
    },
    mind_vision = {
        id = 2096,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135934,

        handler = function ()
            applyDebuff( "mind_vision" )
        end,
    },
    mindgames = {
        id = 375901,
        cast = 1.5,
        cooldown = 45,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 3565723,

        handler = function ()
            applyDebuff( "mindgames" )
        end,
    },
    power_infusion = {
        id = 10060,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        startsCombat = false,
        texture = 135939,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "power_infusion" )
            if group and talent.twins_of_the_sun_priestess.enabled then
                active_dot.power_infusion = 2
            end
        end,
    },
    power_word_life = {
        id = 373481,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 250,
        spendType = "mana",

        startsCombat = false,
        texture = 4667420,

        handler = function ()
        end,
    },
    power_word_shield = {
        id = 17,
        cast = 0,
        cooldown = 7.5,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135940,

        handler = function ()
            applyBuff( "power_word_shield" )
            if talent.body_and_soul.enabled then
                applyBuff( "body_and_soul" )
            end
        end,
    },
    prayer_of_healing = {
        id = 596,
        cast = 1.8,
        cooldown = 0,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 135943,

        handler = function ()
            reduceCooldown( "holy_word_sanctify", 6 )
        end,
    },
    prayer_of_mending = {
        id = 33076,
        cast = 0,
        cooldown = 12,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,
        texture = 135944,

        handler = function ()
            addStack( "prayer_of_mending", 5 )
            if talent.harmonious_apparatus.enabled then
                reduceCooldown( "holy_word_serenity", 2 )
            end
        end,
    },
    psychic_scream = {
        id = 8122,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 136184,

        handler = function ()
            applyDebuff( "psychic_scream" )
        end,
    },
    purify = {
        id = 527,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135894,

        handler = function ()
        end,
    },
    ray_of_hope = {
        id = 197268,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 1445239,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "ray_of_hope" )
        end,
    },
    renew = {
        id = 139,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "renew",
        startsCombat = false,
        texture = 135953,

        handler = function ()
            applyBuff( "renew" )
            reduceCooldown( "holy_word_sanctify", 2 )
        end,
    },
    resurrection = {
        id = 2006,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 135955,

        handler = function ()
        end,
    },
    shackle_undead = {
        id = 9484,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 136091,

        handler = function ()
            applyDebuff( "shackle_undead" )
        end,
    },
    shadow_word_death = {
        id = 32379,
        cast = 0,
        charges = 1,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",

        spend = 250,
        spendType = "mana",

        startsCombat = true,
        texture = 136149,

        handler = function ()
        end,
    },
    shadow_word_pain = {
        id = 589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = 136207,

        handler = function ()
            applyDebuff( "shadow_word_pain" )
        end,
    },
    shadowfiend = {
        id = 34433,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = true,
        texture = 136199,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    smite = {
        id = 585,
        cast = 1.35,
        cooldown = 0,
        gcd = "spell",

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = 135924,

        handler = function ()
            reduceCooldown( "holy_word_chastise", 4 )
            if buff.apotheosis.up then
                reduceCooldown( "holy_word_chastise", 8 )
            end
            if talent.manipulation.enabled then
                reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank )
            end
        end,
    },
    symbol_of_hope = {
        id = 64901,
        channeled = true,
        cast = 4,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,
        texture = 135982,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "symbol_of_hope_buff" )
        end,
    },
    thoughtsteal = {
        id = 316262,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 3718862,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    vampiric_embrace = {
        id = 15286,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 136230,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "vampiric_embrace" )
        end,
    },
    void_shift = {
        id = 108968,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        startsCombat = false,
        texture = 537079,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    void_tendrils = {
        id = 108920,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 537022,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "void_tendrils" )
        end,
    },
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )


spec:RegisterSetting( "sw_death_protection", 50, {
    name = "|T136149:0|t Shadow Word: Death Health Threshold",
    desc = "If set above 0, the addon will not recommend |T136149:0|t Shadow Word: Death while your health percentage is below this threshold.  This setting can help keep you from killing yourself.",
    type = "range",
    min = 0,
    max = 100,
    step = 0.1,
    width = "full",
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,
    cycle = true,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_intellect",

    package = "Holy Priest",

    strict = false
} )


spec:RegisterPack( "Holy Priest", 20230205, [[Hekili:1wvxVTjmu0Fl9LOMUjgHajPsj5H9uxNu1KOpBWbmjE1GJSnTRsi)BF2M0aeWO0jnP20u7RVNZ9RZfmd8mimfkqGN8C9M765g44bcfVFebcpctEbUx9LcyU6ZhOK3LX)IHrCH(Y3juyQ(9CAjlrzaiCxjMi(rbyxpNo7(G7d8v2EeLOooyji8aonfvBlINacF(aMlJ1)cLXNWwgtZu)FIatlKXemxOUoJYKXpGEbtWoGqZHMWaLbljc1xFYew1VcewYrrybkNdcrfWDeuk47aHIeAJAojmHPSIHH6WilZzhHstjLCHddPCLmUQsgFRmMbXPrOxrfchyAk3P8OmEYG3Wq5qCHIWBLXEU1o4sBslzW6GBDTrtn)OnDhLZnUodV)Gi6S3wVrgp3Tj(osn)vfrZTgrQ0oHejGS9ib35GQsgvqFfAqnOXvMlEJYsJsoa5cmhPDRVv3Ez0Glmb7ClbB7eYQRiFSQHz7qmoI9cUyVMrbFwgzl93MrlUcgTOHrzygY0JOj0I)heA210ZmRvNaSirnBYGKOeiHO51YplVcUcE5Ff0YVHveD7lp63LP7ZvgRP1kR0AGXOtmZ)kyM3vWmpZaMASQ7mbKLalqrhljCuTVALxBDNM(3BL(3iJtPI6bmDdIJaNOBAhaWUdHlVyiu)ynuQY7NEMwpbEH70xyCxhLrEUYxxOkoZRTfnC5cRSl10k5NtFfPl5DQr7tsDYH)rgFNm21z(4zgL9Udhk6vqmucnFhSVK)abM5fVbzfQQHAtWpYpszcuQPFOZ(fh5JkhvkoqzGWFcvfDybwdgndtqFGb35m6FzZ3m4jFu(4PlvhDERt7dRLQ)koBZqRyQQUT)YLj9o7uYCRNBvLTo91EUtNwvPxHmPZ6J1BuIZTyuFfFn7Supwh0(PnsY6N0FQD78bi4hKF1iCFvBuolZAbKHYcFaYIrazrBq6kC(pG0SXQfZ6KXVqo0cybJaM)iy53jSAPBPXPxRKci)raYBSgSPtSlGU1RxpMUoQ5WndQpoXwh3YEosF8i9OBN3(fNgmhGlw97i6xBvAx3P0SSX2TUgzgWF)]] )