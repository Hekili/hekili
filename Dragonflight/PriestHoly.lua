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
    angels_mercy               = { 82678, 238100, 1 }, -- Reduces the cooldown of Desperate Prayer by 20 sec.
    apathy                     = { 82689, 390668, 1 }, -- Your Holy Fire critical strikes reduce your target's movement speed by 75% for 4 sec.
    benevolence                = { 82676, 415416, 1 }, -- Increases the healing of your spells by 3%.
    binding_heals              = { 82678, 368275, 1 }, -- 20% of Heal or Flash Heal healing on other targets also heals you.
    blessed_recovery           = { 82720, 390767, 1 }, -- After being struck by a melee or ranged critical hit, heal 20% of the damage taken over 6 sec.
    body_and_soul              = { 82706, 64129 , 1 }, -- Power Word: Shield and Leap of Faith increase your target's movement speed by 40% for 3 sec.
    crystalline_reflection     = { 82681, 373457, 2 }, -- Power Word: Shield instantly heals the target for 4,118 and reflects 10% of damage absorbed.
    death_and_madness          = { 82711, 321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below 20% health, its cooldown is reset. Cannot occur more than once every 10 sec.
    dispel_magic               = { 82715, 528   , 1 }, -- Dispels Magic on the enemy target, removing 1 beneficial Magic effect.
    dominate_mind              = { 82710, 205364, 1 }, -- Controls a mind up to 1 level above yours for 30 sec while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings or players. This spell shares diminishing returns with other disorienting effects.
    essence_devourer           = { 82674, 415479, 1 }, -- Attacks from your Shadowfiend siphon life from enemies, healing a nearby injured ally for 22,433.
    focused_mending            = { 82719, 372354, 1 }, -- Prayer of Mending does 45% increased healing to the initial target.
    from_darkness_comes_light  = { 82707, 390615, 1 }, -- Each time Shadow Word: Pain deals damage, the healing of your next Flash Heal is increased by 1%, up to a maximum of 50%.
    holy_nova                  = { 82701, 132157, 1 }, -- An explosion of holy light around you deals up to 28,713 Holy damage to enemies and up to 19,629 healing to allies within 12 yds, reduced if there are more than 5 targets.
    improved_fade              = { 82686, 390670, 2 }, -- Reduces the cooldown of Fade by 5 sec.
    improved_flash_heal        = { 82714, 393870, 1 }, -- Increases healing done by Flash Heal by 15%.
    inspiration                = { 82696, 390676, 1 }, -- Reduces your target's physical damage taken by 5% for 15 sec after a critical heal with Flash Heal, Heal, or Holy Word: Serenity.
    leap_of_faith              = { 82716, 73325 , 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    lights_inspiration         = { 82679, 373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by 8%.
    manipulation               = { 82672, 390996, 2 }, -- Your Smite and Holy Fire casts reduce the cooldown of Mindgames by 0.5 sec.
    mass_dispel                = { 82699, 32375 , 1 }, -- Dispels magic in a 15 yard radius, removing all harmful Magic from 5 friendly targets and 1 beneficial Magic effect from 5 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mental_agility             = { 82698, 341167, 1 }, -- Reduces the mana cost of Purify and Mass Dispel by 50% and Dispel Magic by 10%.
    mind_control               = { 82710, 605   , 1 }, -- Controls a mind up to 1 level above yours for 30 sec. Does not work versus Demonic, Undead, or Mechanical beings. Shares diminishing returns with other disorienting effects.
    mindgames                  = { 82687, 375901, 1 }, -- Assault an enemy's mind, dealing 30,842 Shadow damage and briefly reversing their perception of reality. For 5 sec, the next 29,419 damage they deal will heal their target, and the next 29,419 healing they deal will damage their target.
    move_with_grace            = { 82702, 390620, 1 }, -- Reduces the cooldown of Leap of Faith by 30 sec.
    petrifying_scream          = { 82695, 55676 , 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear.
    phantasm                   = { 82556, 108942, 1 }, -- Activating Fade removes all snare effects.
    power_infusion             = { 82694, 10060 , 1 }, -- Infuses the target with power for 15 sec, increasing haste by 20%. Can only be cast on players.
    power_word_life            = { 82676, 373481, 1 }, -- A word of holy power that heals the target for 93,474. Only usable if the target is below 35% health.
    protective_light           = { 82707, 193063, 1 }, -- Casting Flash Heal on yourself reduces all damage you take by 10% for 10 sec.
    psychic_voice              = { 82695, 196704, 1 }, -- Reduces the cooldown of Psychic Scream by 15 sec.
    rhapsody                   = { 82700, 390622, 1 }, -- Every 1 sec, the damage of your next Holy Nova is increased by 20% and its healing is increased by 20%. Stacks up to 20 times.
    sanguine_teachings         = { 82691, 373218, 1 }, -- Increases your Leech by 3%.
    sanlayn                    = { 82690, 199855, 1 }, --  Sanguine Teachings Sanguine Teachings grants an additional 2% Leech.  Vampiric Embrace Reduces the cooldown of Vampiric Embrace by 30 sec, increases its healing done by 25%.
    shackle_undead             = { 82693, 9484  , 1 }, -- Shackles the target undead enemy for 50 sec, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shattered_perceptions      = { 82673, 391112, 1 }, -- Mindgames lasts an additional 2 sec, deals an additional 25% initial damage, and reverses an additional 25% damage or healing.
    sheer_terror               = { 82708, 390919, 1 }, -- Increases the amount of damage required to break your Psychic Scream by 75%.
    spell_warding              = { 82720, 390667, 1 }, -- Reduces all magic damage taken by 3%.
    surge_of_light             = { 82677, 109186, 2 }, -- Your healing spells and Smite have a 4% chance to make your next Flash Heal instant and cost no mana. Stacks to 2.
    throes_of_pain             = { 82709, 377422, 2 }, -- Shadow Word: Pain deals an additional 3% damage. When an enemy dies while afflicted by your Shadow Word: Pain, you gain 0.5% Mana.
    tithe_evasion              = { 82688, 373223, 1 }, -- Shadow Word: Death deals 50% less damage to you.
    translucent_image          = { 82685, 373446, 1 }, -- Fade reduces damage you take by 10%.
    twins_of_the_sun_priestess = { 82683, 373466, 1 }, -- Power Infusion also grants you 100% of its effects when used on an ally.
    twist_of_fate              = { 82684, 390972, 2 }, -- After damaging or healing a target below 35% health, gain 5% increased damage and healing for 8 sec.
    unwavering_will            = { 82697, 373456, 2 }, -- While above 75% health, the cast time of your Flash Heal, Heal, Prayer of Healing, and Smite are reduced by 5%.
    vampiric_embrace           = { 82691, 15286 , 1 }, -- Fills you with the embrace of Shadow energy for 12 sec, causing you to heal a nearby ally for 40% of any single-target Shadow spell damage you deal.
    void_shield                = { 82692, 280749, 1 }, -- When cast on yourself, 30% of damage you deal refills your Power Word: Shield.
    void_shift                 = { 82674, 108968, 1 }, -- You and the currently targeted party or raid member swap health percentages. Increases the lower health percentage of the two to 25% if below that amount.
    void_tendrils              = { 82708, 108920, 1 }, -- Summons shadowy tendrils, rooting all enemies within 8 yards for 20 sec or until the tendril is killed.
    words_of_the_pious         = { 82721, 377438, 1 }, -- For 12 sec after casting Power Word: Shield, you deal 10% additional damage and healing with Smite and Holy Nova.

    -- Holy
    afterlife                  = { 82635, 196707, 1 }, -- Increases the duration of Spirit of Redemption by 50% and the range of its spells by 50%. As a Spirit of Redemption, you may sacrifice your spirit to Resurrect an ally, putting yourself to rest.
    answered_prayers           = { 82608, 391387, 2 }, -- After your Prayer of Mending heals 50 times, gain Apotheosis for 8 sec.
    apotheosis                 = { 82610, 200183, 1 }, -- Reset the cooldown of your Holy Words, and enter a pure Holy form for 20 sec, increasing the cooldown reductions to your Holy Words by 300% and reducing their cost by 100%.
    benediction                = { 82641, 193157, 1 }, -- Your Prayer of Mending has a 12% chance to leave a Renew on each target it heals.
    burning_vehemence          = { 82607, 372307, 1 }, -- Increases the damage of Holy Fire by 30%. Holy Fire deals 75% of its initial damage to all nearby enemies within 12 yards of your target. Damage reduced beyond 5 targets.
    censure                    = { 82619, 200199, 1 }, -- Holy Word: Chastise stuns the target for 4 sec and is not broken by damage.
    circle_of_healing          = { 82624, 204883, 1 }, -- Heals the target and 4 injured allies within 30 yards of the target for 12,432.
    cosmic_ripple              = { 82630, 238136, 1 }, -- When Holy Word: Serenity or Holy Word: Sanctify finish their cooldown, you emit a burst of light that heals up to 5 injured targets within 40 yards for 4,973.
    crisis_management          = { 82627, 390954, 2 }, -- Increases the critical strike chance of Flash Heal and Heal by 8%.
    desperate_times            = { 82609, 391381, 2 }, -- Increases healing by 10% on friendly targets at or below 50% health.
    divine_hymn                = { 82621, 64843 , 1 }, -- Heals all party or raid members within 40 yards for 35,520 over 6.7 sec. Each heal increases all targets' healing taken by 4% for 15 sec, stacking. Healing increased by 100% when not in a raid.
    divine_image               = { 82554, 392988, 1 }, -- When you use a Holy Word spell, you summon an image of a Naaru at your side. For 9 sec, whenever you cast a healing or damaging spell, the Naaru will cast a similar spell. If an image has already been summoned, that image is empowered instead.
    divine_service             = { 82642, 391233, 1 }, -- Prayer of Mending heals 4% more for each bounce remaining.
    divine_star                = { 82682, 110744, 1 }, -- Throw a Divine Star forward 27 yds, healing allies in its path for 6,543 and dealing 7,853 Holy damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond 6 targets.
    divine_word                = { 82605, 372760, 1 }, -- The effectiveness of your next Holy Word: Serenity, Sanctify, or Chastise is increased by 30% and grants a corresponding Divine Favor for 15 sec. Chastise: Increases your damage by 20% and refunds 15 sec from the cooldown of Holy Word: Chastise. Sanctify: Blesses the target area, healing up to 5 allies for 66,467 over 15 sec. Serenity: Flash Heal, Heal, and Renew heal for 30% more and cost 20% less mana.
    empyreal_blaze             = { 82640, 372616, 1 }, -- Holy Word: Chastise causes your next 2 casts of Holy Fire to be instant, cost no mana, and incur no cooldown. Refreshing Holy Fire on a target now extends its duration by 7 sec.
    enlightenment              = { 82618, 193155, 1 }, -- You regenerate mana 10% faster.
    epiphany                   = { 82606, 414553, 2 }, -- Your Holy Words have a 25% chance to reset the cooldown of Prayer of Mending.
    everlasting_light          = { 82622, 391161, 1 }, -- Heal restores up to 15% additional health, based on your missing mana.
    gales_of_song              = { 82613, 372370, 1 }, -- Divine Hymn heals for 15% more. Stacks of Divine Hymn increase healing taken by an additional 2% per stack.
    guardian_angel             = { 82636, 200209, 1 }, -- When Guardian Spirit saves the target from death, it does not expire. When Guardian Spirit expires without saving the target from death, reduce its remaining cooldown to 60 seconds.
    guardian_spirit            = { 82637, 47788 , 1 }, -- Calls upon a guardian spirit to watch over the friendly target for 10 sec, increasing healing received by 60%. If the target would die, the Spirit sacrifices itself and restores the target to 40% health. Castable while stunned. Cannot save the target from massive damage.
    guardians_of_the_light     = { 82636, 196437, 1 }, -- Guardian Spirit also grants you 100% of its effects when used on an ally.
    halo                       = { 82682, 120517, 1 }, -- Creates a ring of Holy energy around you that quickly expands to a 30 yd radius, healing allies for 17,056 and dealing 20,221 Holy damage to enemies. Healing reduced beyond 6 targets.
    healing_chorus             = { 82625, 390881, 1 }, -- Your Renew healing increases the healing done by your next Circle of Healing by 5%, stacking up to 20 times.
    holy_mending               = { 82641, 391154, 1 }, -- When Prayer of Mending jumps to a target affected by your Renew, that target is instantly healed for 3,677.
    holy_word_chastise         = { 82639, 88625 , 1 }, -- Chastises the target for 34,456 Holy damage and incapacitates them for 4 sec. Cooldown reduced by 4 sec when you cast Smite.
    holy_word_salvation        = { 82610, 265202, 1 }, -- Heals all allies within 40 yards for 13,024, and applies Renew and 2 stacks of Prayer of Mending to each of them. Cooldown reduced by 15 sec when you cast Holy Word: Serenity or Holy Word: Sanctify.
    holy_word_sanctify         = { 82631, 34861 , 1 }, -- Releases miraculous light at a target location, healing up to 5 allies within 10 yds for 36,268. Cooldown reduced by 6 sec when you cast Prayer of Healing and by 2 sec when you cast Renew.
    holy_word_serenity         = { 82638, 2050  , 1 }, -- Perform a miracle, healing an ally for 107,807. Cooldown reduced by 6 sec when you cast Heal or Flash Heal.
    improved_purify            = { 82705, 390632, 1 }, -- Purify additionally removes all Disease effects.
    light_of_the_naaru         = { 82629, 196985, 2 }, -- The cooldowns of your Holy Words are reduced by an additional 10% when you cast the relevant spells.
    lightweaver                = { 82603, 390992, 1 }, -- Flash Heal reduces the cast time of your next Heal within 20 sec by 30% and increases its healing done by 15%. Stacks up to 2 times.
    lightwell                  = { 82603, 372835, 1 }, -- Creates a Holy Lightwell. Every 1 sec the Lightwell will attempt to heal a nearby party or raid member within 40 yards that is lower than 50% health for 18,694 and apply a Renew to them for 6 sec. Lightwell lasts for 2 min or until it heals 15 times. Cooldown reduced by 3 sec when you cast Holy Word: Serenity or Holy Word: Sanctify.
    miracle_worker             = { 82612, 235587, 1 }, -- Holy Word: Serenity and Holy Word: Sanctify gain an additional charge.
    orison                     = { 82626, 390947, 1 }, -- Circle of Healing heals 1 additional ally and its cooldown is reduced by 3 sec.
    pontifex                   = { 82628, 390980, 1 }, -- Flash Heal, Heal, Prayer of Healing, and Circle of Healing increase the healing done by your next Holy Word spell by 6%, stacking up to 5 times. Lasts 30 sec.
    prayer_circle              = { 82625, 321377, 1 }, -- Circle of Healing reduces the cast time and cost of your Prayer of Healing by 20% for 8 sec.
    prayer_of_healing          = { 82632, 596   , 1 }, -- A powerful prayer that heals the target and the 4 nearest allies within 40 yards for 10,360.
    prayer_of_mending          = { 82718, 33076 , 1 }, -- Places a ward on an ally that heals them for 7,868 the next time they take damage, and then jumps to another ally within 30 yds. Jumps up to 6 times and lasts 30 sec after each jump.
    prayerful_litany           = { 82623, 391209, 1 }, -- Prayer of Healing heals for 100% more to the most injured ally it affects.
    prayers_of_the_virtuous    = { 82616, 390977, 2 }, -- Prayer of Mending jumps 1 additional time.
    prismatic_echoes           = { 82614, 390967, 2 }, -- Increases the healing done by your Mastery: Echo of Light by 6%.
    renew                      = { 82717, 139   , 1 }, -- Fill the target with faith in the light, healing for 24,093 over 15 sec.
    renewed_faith              = { 82620, 341997, 1 }, -- Your healing on allies with your Renew is increased by 6%.
    resonant_words             = { 82604, 372309, 2 }, -- Casting a Holy Word spell increases the healing of your next Flash Heal, Heal, Prayer of Healing, or Circle of Healing by 15%. Lasts 30 sec.
    restitution                = { 82605, 391124, 1 }, -- After Spirit of Redemption expires, you will revive at up to 100% health, based on your healing done during Spirit of Redemption. After reviving, you cannot benefit from Spirit of Redemption for 10 min.
    revitalizing_prayers       = { 82633, 391208, 1 }, -- Prayer of Healing has a 25% chance to apply a 6 second Renew to allies it heals.
    sanctified_prayers         = { 82633, 196489, 1 }, -- Holy Word: Sanctify increases the healing done by Prayer of Healing by 15% for 15 sec.
    say_your_prayers           = { 82615, 391186, 1 }, -- Prayer of Mending has a 15% chance to not consume a charge when it jumps to a new target.
    shadow_word_death          = { 82712, 32379 , 1 }, -- A word of dark binding that inflicts 12,039 Shadow damage to your target. If your target is not killed by Shadow Word: Death, you take backlash damage equal to 8% of your maximum health. Damage increased by 150% to targets below 20% health.
    shadowfiend                = { 82713, 34433 , 1 }, -- Summons a shadowy fiend to attack the target for 15 sec. Generates 0.5% Mana each time the Shadowfiend attacks.
    symbol_of_hope             = { 82617, 64901 , 1 }, -- Bolster the morale of raid members within 40 yds. They each recover 30 sec of cooldown of a major defensive ability, and regain 10% of their missing mana, over 3.3 sec.
    trail_of_light             = { 82634, 200128, 2 }, -- When you cast Heal or Flash Heal, 18% of the healing is replicated to the previous target you healed with Heal or Flash Heal.
    voice_of_harmony           = { 82611, 390994, 2 }, -- Circle of Healing reduces the cooldown of Holy Word: Sanctify by 4 sec. Prayer of Mending reduces the cooldown of Holy Word: Serenity by 4 sec. Holy Fire and Holy Nova reduce the cooldown of Holy Word: Chastise by 4 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_faith         = 1927, -- (408853) Leap of Faith also pulls the spirit of the 3 furthest allies within 40 yards and shields you and the affected allies for 12,331.
    catharsis              = 5485, -- (391297) 15% of all damage you take is stored. The stored amount cannot exceed 12% of your maximum health. The initial damage of your next Shadow Word: Pain deals this stored damage to your target.
    divine_ascension       = 5366, -- (328530) You ascend into the air out of harm's way. While floating, your spell range is increased by 50%, but you are only able to cast Holy spells.
    greater_heal           = 112 , -- (289666) An exceptional spell that heals an ally for 65% of their maximum health, ignoring healing reduction effects.
    holy_ward              = 101 , -- (213610) Wards the friendly target against the next full loss of control effect.
    improved_mass_dispel   = 5634, -- (426438) Reduces the cooldown of Mass Dispel by ${$s1/-1000} sec.
    phase_shift            = 5569, -- (408557) Step into the shadows when you cast Fade, avoiding all attacks and spells for 1 sec. Interrupt effects are not affected by Phase Shift.
    purification           = 5479, -- (196439) Purify now has a maximum of 2 charges. Removing harmful effects with Purify grants your target an absorption shield equal to 5% of their maximum health. Lasts 8 sec.
    ray_of_hope            = 127 , -- (197268) For the next 6 sec, all damage and healing dealt to the target is delayed until Ray of Hope ends. All healing that is delayed by Ray of Hope is increased by 50%.
    sanctified_ground      = 108 , -- (357481) Holy Word: Sanctify blesses the ground with divine light, causing all allies who stand within to be immune to all silence and interrupt effects. Lasts for 5 sec.
    seraphic_crescendo     = 5620, -- (419110) Reduces the cooldown of by Divine Hymn by 60 sec and causes it to channel 50% faster. Additionally, the healing bonus from Divine Hymn now lasts an additional 10 sec.
    spirit_of_the_redeemer = 124 , -- (215982) Your Spirit of Redemption is now an active ability with a 2 minute cooldown, but the duration is reduced by 8 sec and you will no longer enter Spirit of Redemption upon dying.
    thoughtsteal           = 5365, -- (316262) Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for 20 sec. Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
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
     -- Healing $w1 every $t1 sec.
     echo_of_light = {
        id = 77489,
        duration = 4.0,
        max_stack = 1,
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
        id = 426401,
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
        duration = function () return talent.empyreal_blaze.enabled and debuff.holy_fire.up and 21 or 7 end,
        tick_time = 1,
        max_stack = 1
    },
    holy_ward = {
        id = 213610,
        duration = 15,
        max_stack = 1
    },
    holy_word_chastise = {
        id = 247587,
        duration = 5,
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
        duration = 15,
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
    resonant_words = {
        id = 372313,
        duration = 30,
        max_stack = 1
    },
    sanctified_prayers = {
        id = 196490,
        duration = 15,
        max_stack = 1
    },
    -- Taking $s1% increased damage from the Priest.
    schism = {
        id = 214621,
        duration = 9.0,
        max_stack = 1,

         -- Affected by:
        -- twilight_equilibrium[390707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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


spec:RegisterGear( "tier30", 202543, 202542, 202541, 202545, 202540 )
spec:RegisterAuras( {
    inspired_word = {
        id = 409479,
        duration = 3600,
        max_stack = 15
    }
} )

spec:RegisterGear( "tier31", 207279, 207280, 207281, 207282, 207284, 217202, 217204, 217205, 217201, 217203 )
spec:RegisterAura( "sacred_reverence", {
    id = 423510,
    duration = 3600,
    max_stack = 2
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

        talent = "circle_of_healing",
        startsCombat = false,

        handler = function ()
            removeBuff( "healing_chorus" )
            if talent.harmonious_apparatus.enabled then
                reduceCooldown( "holy_word_sanctify", 2 * talent.harmonious_apparatus.rank * ( buff.apotheosis.up and 3 or 1 ) )
            end
        end,
    },

    -- You ascend into the air out of harm's way. While floating, your spell range is increased by 50%, but you are only able to cast Holy spells.
    divine_ascension = {
        id = 328530,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        pvptalent = "divine_ascension",
        startsCombat = false,

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

        talent = "divine_hymn",
        startsCombat = false,

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

        talent = "divine_star",
        startsCombat = true,

        handler = function ()
        end,
    },

    -- The effectiveness of your next Holy Word: Serenity, Sanctify, or Chastise is increased by 50% and grants a corresponding Divine Favor for 15 sec. Chastise: Increases your damage by 30% and Smite has a 40% chance to apply Holy Fire. Sanctify: Blesses the target area, healing up to 6 allies for 8,655 over 15 sec. Serenity: Flash Heal, Heal, and Renew heal for 30% more, have a 20% increased chance to critically strike, and cost 20% less mana.
    divine_word = {
        id = 372760,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        talent = "divine_word",
        startsCombat = false,

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

        talent = "dominate_mind",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "dominate_mind" )
        end,
    },

    --[[ Refreshes Holy Fire. Your next 3 casts of Holy Fire cost no Mana, incur no cooldown, and cast instantly. Whenever Holy Fire is reapplied, its duration is now extended instead.
    empyreal_blaze = {
        id = 372616,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 500,
        spendType = "mana",

        talent = "empyreal_blaze",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "empyreal_blaze", nil, 3 )
            setCooldown( "holy_fire", 0 )
        end,
    }, ]]

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

        spend = function()
            if buff.surge_of_light.up then return 0 end
            return 0.04 * ( buff.divine_favor_serenity.up and 0.8 or 1 )
        end,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
            removeBuff( "resonant_words" )
            removeStack( "surge_of_light" )
            reduceCooldown( "holy_word_serenity", buff.apotheosis.up and 18 or 6 )
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

        pvptalent = "greater_heal",
        startsCombat = false,

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

        talent = "guardian_spirit",
        startsCombat = false,

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

        talent = "halo",
        startsCombat = true,

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
            reduceCooldown( "holy_word_serenity", buff.apotheosis.up and 18 or 6 )
            removeStack( "lightweaver" )
            removeBuff( "resonant_words" )
        end,
    },
    holy_fire = {
        id = 14914,
        cast = function() return buff.empyreal_blaze.up and 0 or 1.5 end,
        cooldown = 10,
        gcd = "spell",

        spend = function() return buff.empyreal_blaze.up and 0 or 0.01 end,
        spendType = "mana",

        startsCombat = true,

        cycle = "holy_fire",

        handler = function ()
            applyDebuff( "target", "holy_fire", buff.empyreal_blaze.up and debuff.holy_fire.up and ( debuff.holy_fire.remains + 7 ) or nil )

            if buff.empyreal_blaze.up then
                removeStack( "empyreal_blaze" )
                setCooldown( "holy_fire", 0 )
            end

            if talent.harmonious_apparatus.enabled then
                reduceCooldown( "holy_word_chastise", 2 * talent.harmonious_apparatus.rank * ( buff.apotheosis.up and 3 or 1 ) )
            end

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

        talent = "holy_nova",
        startsCombat = true,

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

        pvptalent = "holy_ward",
        startsCombat = false,

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

        talent = "holy_word_chastise",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "inspired_word" )
            applyDebuff( "target", "holy_word_chastise" )
            if buff.divine_word.up then
                applyBuff( "divine_favor_chastise" )
                removeBuff( "divine_word" )
            end

            if talent.empyreal_blaze.enabled then
                applyBuff( "empyreal_blaze", nil, 2 )
            end

            if talent.divine_image.enabled then applyBuff( "divine_image" ) end
            if talent.resonant_words.enabled then applyBuff( "resonant_words" ) end
        end,
    },
    holy_word_salvation = {
        id = 265202,
        cast = 2.5,
        cooldown = 720,
        gcd = "spell",

        spend = 0.06,
        spendType = "mana",

        talent = "holy_word_salvation",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "inspired_word" )
            applyBuff( "renew" )
            addStack( "prayer_of_mending", nil, 2 )
            if talent.divine_image.enabled then applyBuff( "divine_image" ) end
            if talent.resonant_words.enabled then applyBuff( "resonant_words" ) end
        end,
    },

    holy_word_sanctify = {
        id = 34861,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "spell",

        spend = function() return 0.04 * ( buff.sacred_reverence.up and 0.5 or 1 ) end,
        spendType = "mana",

        talent = "holy_word_sanctify",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "inspired_word" )
            reduceCooldown( "holy_word_salvation", 30 )
            removeBuff( "divine_word" )
            if buff.sacred_reverence.up then
                gainCharges( "holy_word_sanctify", 1)
                removeStack( "sacred_reverence" )
            end
            if talent.divine_image.enabled then applyBuff( "divine_image" ) end
            if talent.resonant_words.enabled then applyBuff( "resonant_words" ) end
        end,
    },

    holy_word_serenity = {
        id = 2050,
        cast = 0,
        charges = 1,
        cooldown = 60,
        recharge = 60,
        gcd = "spell",

        spend = function() return 0.02 * ( buff.sacred_reverence.up and 0.5 or 1 ) end,
        spendType = "mana",

        talent = "holy_word_serenity",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "inspired_word" )
            if buff.divine_word.up then
                applyBuff( "divine_favor_serenity" )
                removeBuff( "divine_word" )
            end
            if buff.sacred_reverence.up then
                gainCharges( "holy_word_serenity", 1 )
                removeStack( "sacred_reverence" )
            end
            reduceCooldown( "holy_word_salvation", 30 )

            if set_bonus.tier31_2pc > 0 then
                applyBuff( "renew", 14 )
            end

            if talent.resonant_words.enabled then applyBuff( "resonant_words" ) end
        end,
    },
    leap_of_faith = {
        id = 73325,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        talent = "leap_of_faith",
        startsCombat = false,

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

        talent = "lightwell",
        startsCombat = false,
        texture = 135980,

        toggle = "cooldowns",

        handler = function ()
            addStack( "lightwell", 15 )
        end,
    },

    mind_control = {
        id = 605,
        cast = 1.8,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "mind_control",
        startsCombat = true,
        texture = 136206,

        handler = function ()
            applyDebuff( "target", "mind_control" )
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
            applyDebuff( "target", "mind_soothe" )
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
            applyDebuff( "target", "mind_vision" )
        end,
    },

    mindgames = {
        id = 375901,
        cast = 1.5,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",
        damage = 1,

        spend = 0.02,
        spendType = "mana",

        talent = "mindgames",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mindgames" )
        end,
    },

    power_infusion = {
        id = 10060,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "power_infusion",
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

        usable = function () return health.pct < 35, "health must be under 35 percent" end,

        handler = function ()
            gain( 7.5 * stat.spell_power, "health" )
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

        talent = "prayer_of_healing",
        startsCombat = false,

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

        talent = "prayer_of_mending",
        startsCombat = false,

        handler = function ()
            addStack( "prayer_of_mending", 5 )
            if talent.harmonious_apparatus.enabled then
                reduceCooldown( "holy_word_serenity", 2 * talent.harmonious_apparatus.rank * ( buff.apotheosis.up and 3 or 1 ) )
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
            applyDebuff( "target", "psychic_scream" )
        end,
    },

    -- Dispels harmful effects on the target, removing all Magic$?s390632[ and Disease][] effects.
    purify = {
        id = 527,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = function() return 0.013 * ( talent.mental_agility.enabled and 0.5 or 1 ) end,
        spendType = "mana",

        startsCombat = false,
        texture = 135894,

        toggle = "interrupts",
        usable = function() return debuff.dispellable_magic.up or talent.improved_purify.enabled and debuff.dispellable_disease.up, "requires a dispellable effect" end,

        handler = function ()
            removeDebuff( "player", "dispellable_magic" )
            if talent.improved_purify.enabled then
                removeDebuff( "player", "dispellable_disease" )
            end
        end,
    },

    ray_of_hope = {
        id = 197268,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        pvptalent = "ray_of_hope",
        startsCombat = false,

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
            reduceCooldown( "holy_word_sanctify", buff.apotheosis.up and 6 or 2 )
        end,
    },

    shackle_undead = {
        id = 9484,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "shackle_undead",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "shackle_undead" )
        end,
    },

    shadow_word_death = {
        id = 32379,
        cast = 0,
        cooldown = 10,
        gcd = "spell",

        spend = 250,
        spendType = "mana",

        talent = "shadow_word_death",
        startsCombat = true,

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
            applyDebuff( "target", "shadow_word_pain" )
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

        cycle = "holy_fire",
        cycle_to = true,

        handler = function ()
            reduceCooldown( "holy_word_chastise", buff.apotheosis.up and 12 or 4 )
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

        talent = "symbol_of_hope",
        startsCombat = false,

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

        pvptalent = "thoughtsteal",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    vampiric_embrace = {
        id = 15286,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "vampiric_embrace",
        startsCombat = false,

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

        talent = "void_shift",
        startsCombat = false,

        toggle = "defensives",

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

        talent = "void_tendrils",
        startsCombat = true,

        toggle = "defensives",

        handler = function ()
            applyDebuff( "target", "void_tendrils" )
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


spec:RegisterRanges( "smite", "dispel_magic" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    potion = "potion_of_spectral_intellect",

    package = "Holy Priest",

    strict = false
} )


spec:RegisterPack( "Holy Priest", 20240714, [[Hekili:TVXAZTTnYFlE6m2sTk68Z8ASYmTPPxsUBAZCQD63KimjKjotrWJpSIUrd)TF7UaKeKeKIkXTxQN8HMklSyX((fGwC2IFDXCpwkFXpF(PNF5Pp7SlNE2vNE6LxSyE62i(I5rm37y3cFiKTg(33kd2M78HybpjfxCBGK5HijrMf7caSy(nzIG03fU4g7y(Ca2iUl81x9SfZ9fEECfS8e3fZryFYPp7jND5lZD(1nC2D5oVzD02yoli35hcy)x(083N)EaUlEYPx9KtVaGl353IWJYl3zvSCDUZCX6xBagGXR6eSfZdejPjKGqCViKVCf7Ez8sxFwsQiHVK5MkUNdR)ZK0IhYUjG7T4hwm3nwKYJfmIJccwMYIVLNMm1NfiZDE1SChGzXTldbof(YfPaBpqKOjMe4VBHlJ1quErduwEKGYAzO8EMs6glIuF)V6ZJ55om8FIyXPc3Sa8uUbKY3fjfHPj5oUY13icz4oG)sUk3j2NfLi9a9pleKHe5M7OPxy38Ts8734lC9ZD8jlf80XLyie875XBt9fH3cFoibo9nW)5YcZD8KMsIrASxjrl4eTOi35yaRzRwnTGOMccd37ulF2ZZDgN7SBxUZ(W0f9JPxmyeDz)i6Yse1lwUcvNxIQZcD4ArO3TGRxIPgga6QonJuOEQp4XK6pnYnn35AqKDAfot8zEYnl3iJ9w6bQgFeHp18ujYIwVWnOXX)Som5swdKbqnBDd4fmj640TVsdnBdt1FhnsyHapKcUueAbriEiQVXtSAfymtauyiIFFseyl7vyfUsGM6EsCvbyT99)YBaqePzkZ7jWE8fWABeOfnQenTFpbwXJTgJccC(ZnLtA21u0Kw6EkOT0BCdYEHfMSb4bVLrXST8yW1xUjKmNoIS7CLYa8RMwPvsyHafSA70SiLvLnyq5IiTxyk0UemJR4lwKm1Nltej2cz12kPGEAO9cqXGlOgaTX9CkSsm)jU4zIXak2vrafnbdajU1h0OSnSTtq9Vg()(R)ru96ZsrMjlWdJSK7KLGH0rTEuS0fTjqXpOPr5FHQBAUZ7aHAkNWfPXrlPnCEkATiH)9gwaqqCePPW3dqZ88OdETKSFmXlz0a05TGIebPsInrZoLSPIaYDiQhygfTgGhmreA6uLtIZOGNGZlTxLvikJHL(yezhFdFfrpvIYsj9I5VyVjeQzC0CNxEqrb6oi0bKq8PdejhqcXUIo91eI7np2xIjeF(qsi(Ih6eIND6GJ0RQyCfK9Gh)1cf)QFXFs(f)FSqXEtUuLTOvTCKomd1Ofabj(KXvjjX0JbskJAIsTRkkZNDp3mll857zIaKkQYisPtd5FmTkznsqqgzCBXBOJtgI2BenisrRqmtp9jv1Fi(i1bwteRijDciAHpkwRPrt83WISSoRkQDAmFntG(hxBSU27errfavMr9vVMxwm5XTekkG7s90E9S9I6YCJ9hvdQwdDQzPLXYkGpscvQQifqINcvq7TNGILTrdinYwSrzeqg80QZ4EgiiHvXpfKb)VtPVBPAaeC9WaagN7Ue1h2IvQrQyvD79aOgutTsXoQBNwbq1H8YCN5PKnMVCtHf63BynQmEsz3XvL3H7mlLBs62WBNS9smUNM3jPGcUAuV6ikfcDfD3Oy(6m6VL0WLcj8BX6sFDPZPYvqScDrWW7Hvgz6W7)O2t43PIuRCIq3NejqYWs188nfBJoFn2q2R)XXQtpMNu)8PGdu(aTtCZdC0zfyyAx(Hw8Fk9jE1EDAO41J2hyO3hauHwCAB70CNVZyDBgd0HnUmYUfvPXr3qxwxOOIXHATYeNjBdDr1tQVP4L0GJqavEhCVXTg4MPyDF9qQevhvGUkXWn0O70SKkehLdSbaQ(qTK2AWzzERrhtv5yqBlD7AvXUPiuVScmtgD)SqrwCtZHIwTh4wBSokyvHqleZjTIaJP5VHh6bfAwppFxnPRczlcxLLOmHmfwZjJIp8UcdJUKmv2sPs5D9M9RsWzkyQP47YzsBaTpBScNKUI3bEwT50FH8iulPgcKPdbjKWVUqk1yen1fIav0NtkeKBjS71nd3cSJhzfgEx5CQOaIkA4dVBqhlyDClpeaYTLTXE7xVlBKoZq8wIKndyJ2bvwfTJ2p0GfMbGb7HBD9MUM9XCNVLk12Q(9tQlQMkPhGUO6n00x7I6VADr90H0fvZjk9z3f1qgJmFflli1wrZ1m5WPB3)i3hT3msgjT8zXRLHczwYsweyVYsZsQdigIx4EhzyH)DmFfu3MVQxSXgtUURm89uqvrguRPwhpS8dn8)((GnSTj6yTV9NQYLP6PKxwTdrGaP5Htdg6IKhIHDHdfRbTsSG1mRLlaW44TJ5EzKgrdRQCz8Edcru5MfJxrb6GQLBqnX)srhPtQ1sQQD0AsumpbgInjlw7dFB5SJXgr4jy)U6gcXCzjjcSeZCN3r0aiHW8lIIlrHHWJZJV40imPSCkcP7j4Q45yha081Xp(VZskhADOivGcnFeVLZyhR0NfKG3mJm8eeDvxEdDUI1R5Ecwkh5yjnU9wkampdQivu3MYyNqhKrQjQBw(rp51m98IG0nnRzwrIkcB(V)YpqIXgJZxPr7QWiBSS(wQmIu7Ykh3Girjwu6esuIxRXe8(OiPXC1LBbbkcG9MeGxfckR03bHEmjP(yyCim2QmuDHeFZ2FQzd10TTSRgD4lS9JLPYLKEhdnc(atBk(MwzKv6LB6NwVJ)cp9cGm6Cvv)uZ8710nFau2KwNAMgAmP362lu4UmiyV6pwIxRVL2)Twv6Xvr)AhtPRk(BWUu170Jjq3VFpZbXsHj14(3Oy4IM6(jefGgvMQf)7RAD1vycI5sjtCwyDbtcuiQBAJef9QnhaZHNW9CBfjvJ9(xzHnOE8oAXPNN0Mlv8Is62j38LIAwFhawgtA3ca99)1L2vVCr)5hQkTU8Gqw1CVAZgII75Uzfp17MQACQ6MrQO)EiqJJROhMuvToqPQuJxQhl0LNbSWgwCieRkHkGgfdrqmt9aHoPSb5tWaD)NmOeiSgzjnE2Su5A178b0Ay(XP5V)FsYYZbVKxldHtJw(K2glNOI4yzLcP2j4mN(4y69fzHY0vTDy01z2PR6Lo1G0Sxkxf11lMTvKxd83xDGnpLlEqLR9IZ2EUnP7oDTBEcx9hav3boFaP6N2lvt(V2j7A((7ZkUZCxhMHDhoCv1c0GuBpC(MS)L)H5Q0HQ7lumN)(3rAmeHqd4Q4Sqdb4JzewgVfhjKnQS4OKPLxRZ3n7Vz7ICqC(n5oFTDPhZTlL)ET5ayeuo9Gj1gEWSZMiwnBKv7WD76j7WUDhPvy72zOsgF8rJSpjGJh1Xma2TZs))JpU)o)htMVpYAQZuF1SFmsnziORK)JpEu7g7E1SEBQdut9w(VE5ATXrs8dPvnt2PzZAtWkdN1DMhKDBNi(4otGE8EQINi(hQoTmzSg192hFPAyAIQYDLJx)DuJ08Ny7thgjQq4FiY8pJUFgkpqBRMy1sTqeX0xRm790k2X7lH0oVt2VaskU(x1UBFhXtKrZs4PtO78F2Peb(q(Ce(KitBeGMqfRM4kd9eioN1QeonBOoYUE5ctQEUdAg(X2ZsyGcDd5ggxFaxE2R67jjmUJKR6LVE2OEERcFxVVtHX6mT1y4h0NCWafzg8fkZ6V8GJhDuhL0yV4eft(z8Ccgit0MyrEXoTESLYIkljZgOwEHb7pyLkPesASajsmTVV1xn78bJf9Y41N2gzgls4ee5FrEFPdMBlVIrYlUJRFey1JTC5LVA2zpF8UDDVRlSVRx07MU0(MUe2uN75QbZVL3y6G3rR7dvLEUX1OE95Noym22fImK(Y6hp0G5gIcT1sw3gthgU7mcGQMVprh)Yn)y2FVsc9O2nVKn3N3DjGhGt930SYl36Lv9x5Nc((et2t2pQNNm(19wKhyqCqpt8RN1l62h53v4dQDQw1WQMxGTFDJhFKnY24x14UD9)lA066gf7PkE7R)(d)Z53FyN2dT1Tt06KzVyiBsRroOn1z53LGEqj3k21JZSA1eFpctNvWFDNhRaIdibwxyOzWr90H6Ua1d)51Ad51d6oK5gms)CB)2lgBLAhMds1gEK5B0qV9yYTOI1S4ruT4NGZGXMB6hu(ynkX8kbh0uOPWdXVab7Nu9hppPapQ9OSnlGYSIOSO9DBtQsmoOFxbDrOPAcKuTTE0)054VVF8a2XD5VfHUr)I5SSuFz8I5)dwe4hgkONKZI)3]] )
