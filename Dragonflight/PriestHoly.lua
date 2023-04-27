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
    angelic_bulwark            = { 82675, 108945, 1 }, -- When an attack brings you below 30% health, you gain an absorption shield equal to 15% of your maximum health for 20 sec. Cannot occur more than once every 90 sec.
    angelic_feather            = { 82703, 121536, 1 }, -- Places a feather at the target location, granting the first ally to walk through it 40% increased movement speed for 5 sec. Only 3 feathers can be placed at one time.
    angels_mercy               = { 82678, 238100, 1 }, -- Damage you take reduces the cooldown of Desperate Prayer, based on the amount of damage taken.
    apathy                     = { 82689, 390668, 1 }, -- Your Holy Fire critical strikes reduce your target's movement speed by 75% for 4 sec.
    binding_heals              = { 82678, 368275, 1 }, -- 20% of Heal or Flash Heal healing on other targets also heals you.
    blessed_recovery           = { 82720, 390767, 1 }, -- After being struck by a melee or ranged critical hit, heal 20% of the damage taken over 6 sec.
    body_and_soul              = { 82706, 64129 , 1 }, -- Power Word: Shield and Leap of Faith increase your target's movement speed by 40% for 3 sec.
    crystalline_reflection     = { 82681, 373457, 2 }, -- Power Word: Shield instantly heals the target for 690 and reflects 10% of damage absorbed.
    death_and_madness          = { 82711, 321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below 20% health, its cooldown is reset. Cannot occur more than once every 20 sec.
    dispel_magic               = { 82715, 528   , 1 }, -- Dispels Magic on the enemy target, removing 1 beneficial Magic effect.
    dominate_mind              = { 82710, 205364, 1 }, -- Controls a mind up to 1 level above yours for 30 sec while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings or players. This spell shares diminishing returns with other disorienting effects.
    focused_mending            = { 82719, 372354, 1 }, -- Prayer of Mending does 45% increased healing to the initial target.
    from_darkness_comes_light  = { 82707, 390615, 1 }, -- Each time Shadow Word: Pain deals damage, the healing of your next Flash Heal is increased by 1%, up to a maximum of 50%.
    holy_nova                  = { 82701, 132157, 1 }, -- An explosion of holy light around you deals up to 808 Holy damage to enemies and up to 899 healing to allies within 12 yds, reduced if there are more than 5 targets.
    improved_fade              = { 82686, 390670, 2 }, -- Reduces the cooldown of Fade by 5 sec.
    improved_flash_heal        = { 82714, 393870, 1 }, -- Increases healing done by Flash Heal by 15%.
    improved_mass_dispel       = { 82698, 341167, 1 }, -- Mass Dispel's cooldown is reduced to 25 sec and its cast time is reduced by 1 sec.
    inspiration                = { 82696, 390676, 1 }, -- Reduces your target's physical damage taken by 5% for 15 sec after a critical heal with Flash Heal, Heal, or Holy Word: Serenity.
    leap_of_faith              = { 82716, 73325 , 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    lights_inspiration         = { 82679, 373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by 8%.
    manipulation               = { 82672, 390996, 2 }, -- Your Smite and Holy Fire casts reduce the cooldown of Mindgames by 0.5 sec.
    mass_dispel                = { 82699, 32375 , 1 }, -- Dispels magic in a 15 yard radius, removing all harmful Magic from 5 friendly targets and 1 beneficial Magic effect from 5 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mind_control               = { 82710, 605   , 1 }, -- Controls a mind up to 1 level above yours for 30 sec. Does not work versus Demonic, Undead, or Mechanical beings. Shares diminishing returns with other disorienting effects.
    mindgames                  = { 82687, 375901, 1 }, -- Assault an enemy's mind, dealing 4,700 Shadow damage and briefly reversing their perception of reality. For 5 sec, the next 4,932 damage they deal will heal their target, and the next 4,932 healing they deal will damage their target.
    move_with_grace            = { 82702, 390620, 1 }, -- Reduces the cooldown of Leap of Faith by 30 sec.
    petrifying_scream          = { 82695, 55676 , 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear.
    phantasm                   = { 82556, 108942, 1 }, -- Activating Fade removes all snare effects.
    power_infusion             = { 82694, 10060 , 1 }, -- Infuses the target with power for 20 sec, increasing haste by 25%. Can only be cast on players.
    power_word_life            = { 82676, 373481, 1 }, -- A word of holy power that heals the target for 3,058. If the target is below 35% health, Power Word: Life heals for 400% more and the cooldown of Power Word: Life is reduced by 20 sec.
    protective_light           = { 82707, 193063, 1 }, -- Casting Flash Heal on yourself reduces all damage you take by 10% for 10 sec.
    psychic_voice              = { 82695, 196704, 1 }, -- Reduces the cooldown of Psychic Scream by 15 sec.
    rhapsody                   = { 82700, 390622, 1 }, -- For every 5 sec that you do not cast Holy Nova, the damage of your next Holy Nova is increased by 10% and its healing is increased by 20%. This effect can stack up to 20 times.
    sanguine_teachings         = { 82691, 373218, 1 }, -- Increases your Leech by 3%.
    sanlayn                    = { 82690, 199855, 1 }, --  Sanguine Teachings Sanguine Teachings grants an additional 2% Leech.  Vampiric Embrace Reduces the cooldown of Vampiric Embrace by 45 sec, increases its healing done by 25%.
    shackle_undead             = { 82693, 9484  , 1 }, -- Shackles the target undead enemy for 50 sec, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shattered_perceptions      = { 82673, 391112, 1 }, -- Mindgames lasts an additional 2 sec, deals an additional 25% initial damage, and reverses an additional 25% damage or healing.
    sheer_terror               = { 82708, 390919, 1 }, -- Increases the amount of damage required to break your Psychic Scream by 75%.
    spell_warding              = { 82720, 390667, 1 }, -- Reduces all magic damage taken by 3%.
    surge_of_light             = { 82677, 109186, 2 }, -- Your healing spells and Smite have a 4% chance to make your next Flash Heal instant and cost no mana. Stacks to 2.
    throes_of_pain             = { 82709, 377422, 2 }, -- Shadow Word: Pain deals an additional 3% damage. When an enemy dies while afflicted by your Shadow Word: Pain, you gain 0.5% Mana.
    tithe_evasion              = { 82688, 373223, 1 }, -- Shadow Word: Death deals 75% less damage to you.
    translucent_image          = { 82685, 373446, 1 }, -- Fade reduces damage you take by 10%.
    twins_of_the_sun_priestess = { 82683, 373466, 1 }, -- Power Infusion also grants you 100% of its effects when used on an ally.
    twist_of_fate              = { 82684, 390972, 2 }, -- After damaging or healing a target below 35% health, gain 5% increased damage and healing for 8 sec.
    unwavering_will            = { 82697, 373456, 2 }, -- While above 75% health, the cast time of your Flash Heal, Heal, Prayer of Healing, and Smite are reduced by 5%.
    vampiric_embrace           = { 82691, 15286 , 1 }, -- Fills you with the embrace of Shadow energy for 15 sec, causing you to heal a nearby ally for 50% of any single-target Shadow spell damage you deal.
    void_shield                = { 82692, 280749, 1 }, -- When cast on yourself, 30% of damage you deal refills your Power Word: Shield.
    void_shift                 = { 82674, 108968, 1 }, -- You and the currently targeted party or raid member swap health percentages. Increases the lower health percentage of the two to 25% if below that amount.
    void_tendrils              = { 82708, 108920, 1 }, -- Summons shadowy tendrils, rooting up to 5 enemy targets within 8 yards for 20 sec or until the tendril is killed.
    words_of_the_pious         = { 82721, 377438, 1 }, -- For 12 sec after casting Power Word: Shield, you deal 10% additional damage and healing with Smite and Holy Nova.

    -- Holy
    afterlife                  = { 82635, 196707, 1 }, -- Increases the duration of Spirit of Redemption by 50% and the range of its spells by 50%. As a Spirit of Redemption, you may sacrifice your spirit to Resurrect an ally, putting yourself to rest.
    answered_prayers           = { 82608, 391387, 2 }, -- After your Prayer of Mending heals 50 times, gain Apotheosis for 8 sec.
    apotheosis                 = { 82610, 200183, 1 }, -- Reset the cooldown of your Holy Words, and enter a pure Holy form for 20 sec, increasing the cooldown reductions to your Holy Words by 300% and reducing their cost by 100%.
    benediction                = { 82641, 193157, 1 }, -- Your Prayer of Mending has a 12% chance to leave a Renew on each target it heals.
    burning_vehemence          = { 82606, 372307, 2 }, -- Increases the damage of Holy Fire by 15%. Holy Fire deals 25% of its initial damage to all nearby enemies within 12 yards of your target. Damage reduced beyond 5 targets.
    censure                    = { 82619, 200199, 1 }, -- Holy Word: Chastise stuns the target for 4 sec and is not broken by damage.
    circle_of_healing          = { 82624, 204883, 1 }, -- Heals the target and 4 injured allies within 30 yards of the target for 2,033.
    cosmic_ripple              = { 82630, 238136, 1 }, -- When Holy Word: Serenity or Holy Word: Sanctify finish their cooldown, you emit a burst of light that heals up to 5 injured targets within 40 yards for 813.
    crisis_management          = { 82627, 390954, 2 }, -- Increases the critical strike chance of Flash Heal and Heal by 8%.
    desperate_times            = { 82609, 391381, 2 }, -- Increases healing by 10% on friendly targets at or below 50% health.
    divine_hymn                = { 82621, 64843 , 1 }, -- Heals all party or raid members within 40 yards for 5,809 over 6.5 sec. Each heal increases all targets' healing taken by 4% for 15 sec, stacking. Healing increased by 100% when not in a raid.
    divine_image               = { 82554, 392988, 1 }, -- When you use a Holy Word spell, you summon an image of a Naaru at your side. For 9 sec, whenever you cast a healing or damaging spell, the Naaru will cast a similar spell.
    divine_service             = { 82642, 391233, 1 }, -- Prayer of Mending heals 4% more for each bounce remaining.
    divine_star                = { 82682, 110744, 1 }, -- Throw a Divine Star forward 27 yds, healing allies in its path for 1,427 and dealing 1,196 Holy damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond 6 targets.
    divine_word                = { 82554, 372760, 1 }, -- The effectiveness of your next Holy Word: Serenity, Sanctify, or Chastise is increased by 50% and grants a corresponding Divine Favor for 15 sec. Chastise: Increases your damage by 30% and Smite has a 40% chance to apply Holy Fire. Sanctify: Blesses the target area, healing up to 6 allies for 8,943 over 15 sec. Serenity: Flash Heal, Heal, and Renew heal for 30% more, have a 20% increased chance to critically strike, and cost 20% less mana.
    empowered_renew            = { 82612, 391339, 1 }, -- Renew instantly heals your target for 10% of its total periodic effect.
    empyreal_blaze             = { 82640, 372616, 1 }, -- Refreshes Holy Fire. Your next 3 casts of Holy Fire cost no Mana, incur no cooldown, and cast instantly. Whenever Holy Fire is reapplied, its duration is now extended instead.
    enlightenment              = { 82618, 193155, 1 }, -- You regenerate mana 10% faster.
    everlasting_light          = { 82622, 391161, 1 }, -- Heal restores up to 15% additional health, based on your missing mana.
    gales_of_song              = { 82613, 372370, 2 }, -- Divine Hymn heals for 8% more. Stacks of Divine Hymn increase healing taken by an additional 1% per stack.
    guardian_angel             = { 82636, 200209, 1 }, -- When Guardian Spirit saves the target from death, it does not expire. When Guardian Spirit expires without saving the target from death, reduce its remaining cooldown to 60 seconds.
    guardian_spirit            = { 82637, 47788 , 1 }, -- Calls upon a guardian spirit to watch over the friendly target for 10 sec, increasing healing received by 60%. If the target would die, the Spirit sacrifices itself and restores the target to 40% health. Castable while stunned. Cannot save the target from massive damage.
    guardians_of_the_light     = { 82636, 196437, 1 }, -- Guardian Spirit also grants you 100% of its effects when used on an ally.
    halo                       = { 82682, 120517, 1 }, -- Creates a ring of Holy energy around you that quickly expands to a 30 yd radius, healing allies for 3,282 and dealing 3,082 Holy damage to enemies. Healing reduced beyond 6 targets.
    harmonious_apparatus       = { 82611, 390994, 2 }, -- Circle of Healing reduces the cooldown of Holy Word: Sanctify, Prayer of Mending reduces the cooldown of Holy Word: Serenity, and Holy Fire reduces the cooldown of Holy Word: Chastise by 4 sec.
    healing_chorus             = { 82625, 390881, 1 }, -- Your Renew healing increases the healing done by your next Circle of Healing by 1%, stacking up to 50 times.
    holy_mending               = { 82641, 391154, 1 }, -- When Prayer of Mending jumps to a target affected by your Renew, that target is instantly healed for 616.
    holy_word_chastise         = { 82639, 88625 , 1 }, -- Chastises the target for 2,992 Holy damage and incapacitates them for 4 sec. Cooldown reduced by 4 sec when you cast Smite.
    holy_word_salvation        = { 82610, 265202, 1 }, -- Heals all allies within 40 yards for 2,130, and applies Renew and 2 stacks of Prayer of Mending to each of them. Cooldown reduced by 30 sec when you cast Holy Word: Serenity or Holy Word: Sanctify.
    holy_word_sanctify         = { 82632, 34861 , 1 }, -- Releases miraculous light at a target location, healing up to 6 allies within 10 yds for 4,745. Cooldown reduced by 6 sec when you cast Prayer of Healing and by 2 sec when you cast Renew.
    holy_word_serenity         = { 82638, 2050  , 1 }, -- Perform a miracle, healing an ally for 13,556. Cooldown reduced by 6 sec when you cast Heal or Flash Heal.
    improved_purify            = { 82705, 390632, 1 }, -- Purify additionally removes all Disease effects.
    light_of_the_naaru         = { 82629, 196985, 2 }, -- The cooldowns of your Holy Words are reduced by an additional 10% when you cast the relevant spells.
    lightweaver                = { 82603, 390992, 1 }, -- Flash Heal reduces the cast time of your next Heal within 20 sec by 30% and increases its healing done by 15%. Stacks up to 2 times.
    lightwell                  = { 82603, 372835, 1 }, -- Creates a Holy Lightwell. Every 1 sec the Lightwell will attempt to heal party and raid members within 20 yards that are lower than 50% health for 2,352 over 6 sec. Lightwell lasts for 2 min or until 15 heals are expended.
    miracle_worker             = { 82605, 235587, 1 }, -- Holy Word: Serenity and Holy Word: Sanctify gain an additional charge.
    orison                     = { 82626, 390947, 1 }, -- Circle of Healing heals 1 additional ally and its cooldown is reduced by 3 sec.
    pontifex                   = { 82628, 390980, 1 }, -- Critical heals from Flash Heal and Heal increase your healing done by your next Holy Word spell by 10%, stacking up to 2 times.
    prayer_circle              = { 82625, 321377, 1 }, -- Using Circle of Healing reduces the cast time and cost of your Prayer of Healing by 20% for 8 sec.
    prayer_of_healing          = { 82631, 596   , 1 }, -- A powerful prayer that heals the target and the 4 nearest allies within 40 yards for 1,694.
    prayer_of_mending          = { 82718, 33076 , 1 }, -- Places a ward on an ally that heals them for 1,181 the next time they take damage, and then jumps to another ally within 20 yds. Jumps up to 6 times and lasts 30 sec after each jump.
    prayerful_litany           = { 82623, 391209, 1 }, -- Prayer of Healing heals for 30% more to the most injured ally it affects.
    prayers_of_the_virtuous    = { 82616, 390977, 2 }, -- Prayer of Mending jumps 1 additional time.
    prismatic_echoes           = { 82614, 390967, 2 }, -- Increases the healing done by your Mastery: Echo of Light by 6%.
    rapid_recovery             = { 82612, 391368, 1 }, -- Increases healing done by Renew by 35%, but decreases its base duration by 3 sec.
    renew                      = { 82717, 139   , 1 }, -- Fill the target with faith in the light, healing for 4,015 over 15 sec.
    renewed_faith              = { 82620, 341997, 1 }, -- Your healing on allies with your Renew is increased by 6%.
    resonant_words             = { 82604, 372309, 2 }, -- Casting a Holy Word spell increases the healing of your next Heal or Flash Heal by 15%.
    restitution                = { 82605, 391124, 1 }, -- After Spirit of Redemption expires, you will revive at up to 100% health, based on your healing done during Spirit of Redemption. After reviving, you cannot benefit from Spirit of Redemption for 10 min.
    revitalizing_prayers       = { 82633, 391208, 1 }, -- Prayer of Healing has a 25% chance to apply a 6 second Renew to allies it heals.
    sanctified_prayers         = { 82633, 196489, 1 }, -- Holy Word: Sanctify increases the healing done by Prayer of Healing by 15% for 15 sec.
    say_your_prayers           = { 82615, 391186, 1 }, -- Prayer of Mending has a 15% chance to not consume a charge when it jumps to a new target.
    searing_light              = { 82607, 372611, 1 }, -- Smite and Holy Nova deal 25% additional damage to targets affected by your Holy Fire.
    shadow_word_death          = { 82712, 32379 , 1 }, -- A word of dark binding that inflicts 1,471 Shadow damage to the target. If the target is not killed by Shadow Word: Death, the caster takes damage equal to the damage inflicted upon the target. Damage increased by 150% to targets below 20% health.
    shadowfiend                = { 82713, 34433 , 1 }, -- Summons a shadowy fiend to attack the target for 15 sec. Generates 0.5% Mana each time the Shadowfiend attacks.
    symbol_of_hope             = { 82617, 64901 , 1 }, -- Bolster the morale of raid members within 40 yds. They each recover 60 sec of cooldown of a major defensive ability, and regain 15% of their missing mana, over 3.2 sec.
    trail_of_light             = { 82634, 200128, 2 }, -- When you cast Heal or Flash Heal, 18% of the healing is replicated to the previous target you healed with Heal or Flash Heal.
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
    answered_prayers = {
        id = 394289,
        duration = 3600,
        max_stack = function() return talent.answered_prayers.rank > 1 and 50 or 100 end,
    },
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
    divine_favor_chastise = {
        id = 372761,
        duration = 15,
        max_stack = 1
    },
    divine_favor_serenity = {
        id = 372791,
        duration = 15,
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
    divine_image = {
        id = 392990,
        duration = 9,
        max_stack = 1
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
            applyBuff( "divine_word" )
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

        spend = function() return 0.04 * ( buff.divine_favor_serenity.up and 0.8 or 1 ) end,
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

        spend = function() return 0.02 * ( buff.divine_favor_serenity.up and 0.8 or 1 ) end,
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
            applyDebuff( "target", "holy_word_chastise" )
            if buff.divine_word.up then
                applyBuff( "divine_favor_chastise" )
                removeBuff( "divine_word" )
            end

            if talent.divine_image.enabled then applyBuff( "divine_image" ) end
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
            addStack( "prayer_of_mending", nil, 2 )
            if talent.divine_image.enabled then applyBuff( "divine_image" ) end
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
            removeBuff( "divine_word" )
            if talent.divine_image.enabled then applyBuff( "divine_image" ) end
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
            if buff.divine_word.up then
                applyBuff( "divine_favor_serenity" )
                removeBuff( "divine_word" )
            end
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
        cast = 0,
        cooldown = 120,
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

        spend = function() return 0.02 * ( buff.divine_favor_serenity.up and 0.8 or 1 ) end,
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


spec:RegisterPack( "Holy Priest", 20230405, [[Hekili:DR1EVTnos8plflU8y3e1KM4(iOPaP9AVn52lTOU7T)NTySOTjQSOosQ46dg6Z(nKuuIuVtJstXHfBRR0Wz(ndNxCOMC8KVmzCasGNC9Zo6zNC0PhnY74to9KrVCYyXMy8KXXOzFfTa(reAf8N)onCtQ)NyemxiF5MqkkqYeonHndiyY4BsiHIlJMCtvo)Stp5Kxa0gJNbpEe8ZLKGaSMwmF2KXsAp8Otp8OrNL6N6)NXsweK6pNrxL6pMS6DEGyz05KqqyOzccnI7fZWZORUbj(TZFAmDnMnDnLfmDoLjiIKaC6vPx9lP()7l(8Lx82)49JtVYSYvis00Brmc6MqmhwU53hi13ZNTeXfeoE6Sa2b04Z5yXb3IctWNV3EZO0Wa66iVaYTKiSsKEmSKJ8)MM)E8veb2d)n8SebEQGScV)VE6(zW5Z)51P(x8UVC5hVUaraeyjrt1)RPHeUqJejBZw3)6IlV2vdGfndfgw)QkuVEUiJIXvs7IW1On8u)eoo1)3)qQpzEQ)A43lr3c)jEv8gggfM6Fti6)cpGYKVITIgrOjW6qXXigsi)zQ)hflXS1Gb9aGWiPRKITeHMTru4hcYSVsIwO5edpNH5lLWVc6xc(ItNty4diZpFpbkehj8m4zQcoB3M94cennhq7VD7EpjtAB3AjP9vk(FNgTlaNzGha459xN9Pu)GeMczOykOiuoPQjf4ay70(FXWJuyZI3B3Ae5(7CtY85Ef8YtA01Iw5rL6)xaxmgkJzFgkk1NVjAg8pjILP(VlZh1tAGV0zZ595BoVvAnoWDHILiqZqC5kcd9QOkw(1sTi3Fxz3vkOj8WljEhWuw)oq(6CFbSgTDwNszTsvnme8Rqm5Jfu4)zKflWGZqqMzzo6wk7mlQR1ZWbHsfqzUTdwtIva49rcj3ng9pi5o45rfijtnwRgfUVKVGJCCfyuBGCgauSjhEkYUTckDjYG3pNevcoWFrcdXmEvyRbN2Z6odpnxLOkBV1Y6TJjYQITENwuHCxChLGSckX0Sjx)67c8vROkUZy0VyLik1FbocZiZSeFVKKzzx5eXM58S3fQ9Z9lyvBB716X27L6gw17LvK3PRG7SAAV54J6nZTZcgGrIL69c2cm4WayvS0lEM41J6phxrIcwa2DEVxHstIO3IS8dylrXCAWgTlQ5F5XfqxoN7(SvOVnv98DG2vGYKA0Z9Yz7Bo)KEJLSxd8J171Sefs7nXQgnAWx8dQO4M8f1X4nM0CV28mG6HQiMdnTy4z3W0(VUTwK6co3xxOCg1LNJRbyWDyA2njxWD7DuGXMDkkSC14lCPBku78HoB9CueqY8n9Humdhre9H0gZPziTJCygYgKCwgM1BhSDEYEL7uljE7w9ZI4WXnWqVEm0gOaSURMgKyUNOusdftFW8Ahm12Y9EqvCiuyi5NDyZ)WuC3qBw1(o8QlOQjh6ckUF(Yf85hGBCHWggp4sgZFUCEla3q53APU3xxwRTDlV13LFGD4eGJvNW7tx295wmNOuqPFTGo1bXYfy(Sa(nZKvirZt4W7u6r1JfaNPUMZk06HA0hd8JQt5cweI8aaKshYvjB5J1cVjakYaMsEU4vBIPC(o5XALiWeNnNSyPyAEBka2a30a15qJ(k4EPpvQAWfAWbg7AXdqYuyxAfFOHuDctNhyobhfmz8TGNdqr2S3E2rJMmEnIfrIwWNm(llvNPkMYGJ)px2I4UUZjAx5Cx(pjeMCYBC6kGCuIGUspkoyNlAbM7LE1FOCyo(mPhyeis1RPXyDtHC9U4U3NjLTR2w3bpEA78WtgMuJsNB9Ux67UvD3nOU6B8WrslSKI9o(B7)aXtLUoNggsxRhxf0MUAkpmSYVnqVZiKKPnDP(Yd2kNwGWqNAwCZPjrouheijoajq3G44ZalR)HMChLISBWQBx19Uz4Fz9gjt1GswO8Iep(MNY50BWYi9LVBwKtQ3I428rj7sPPW1GdzdCUUXOwI)1rstsz0dg(BWx57mGQvEwTJTYwKQT01GeEvRO2eYudSvV6Nap9VJeb1orJ7wyWZhOed1cZSwUECq0p8nWEMQYzVtp4H7Mb60bYaLE1LkGjzYRCTbsHnzS6xYlO0Tfh4jxRU8Zmoo5TtgtJNmMJfMRve6IkJA5VctG)ApqUGU02uT8FQbf10osQ)(P()kO9Wp034jJeRLv(DtQe7u9TTApnTjc4)uArDy3HxYliSqlkFjFABsMekzveqhJL4CVytERusoCsBy7NMRteand2FanxTV2A1Lu)TBZjPTcCQnyjTahFILSLpY(QmLB)gdB(1ykTDN2MTRx3izj9YrQsyydlaS7OVIOYxdzb8kFHMsuoQvuMDqYFOxEPTw3(fvQu5STNU3ZB(YlD2dTYeiTppVn7Z9)(oTvw7twRseLexY1YXair3lAdDd1LHwaIs3EwtGVYybCsW0wZcsD6LTPtFNxyAVuHMBFu5O1zlGfrG1Bh0aPjlHwlKgGx1BdqFUS1Vdv3Pf06qSMXaup(O2WAB3mBlWYsEzltxW0r4Dv4052sQlmYC9i5fkRHKSRfXwkMIITex6s9P2u7M6PeLLtf3V0G5DR8MuFy7ixuwLrQjnM9wFP5lN6)A44ChP8MFIk)A1jCQZO20uoDYNwzO21L3QaodGeZNSDDztQ4ZxUH0IOy35vN6FE5NNpZA1ACMBnSDaKFYqzeZhUED5hguJxwqMCs51gGpOctoeDLuo2oir1STBSHm6hphLek6mW3(tXRFjzwPBfs(rqA(4dZLIz919PiwbIfTo3fih8X8xAJPTszz902r1UwRN7Sj6oN76o3HBrH7YLduPdJktDpZBJY5ky3X03vzjDMaVTEiYWFRN6PZlq4hjMZVwIkvACUdHYHs103rxESn8LOu6ik95lmrnCIA)ktuNI51TFQ8U6iUSVx3f66OuLt1(Isl1uK)rRktd1jgzJC786Uy)5oTZiZi7((x0DUztBAD5eLDx89ApSxTmvosDiBzQT90hHwMAU7WbqIoTm1wVIp8oZdLr0ju4bTFZsTm1ChNdGSmDm9QUdkB9C2DfP2Whb7)Vg52NyVUQb8if2u8vS2E1Gx0VQbVSJQbD74jN6EIyjf48)efNeIIiQNo5)9]] )
