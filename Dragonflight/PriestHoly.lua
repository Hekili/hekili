-- PriestHoly.lua
-- DF Pre-Patch Nov 2022

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 257 )

spec:RegisterResource( Enum.PowerType.Insanity )
spec:RegisterResource( Enum.PowerType.Mana )

spec:RegisterTalents( {
    -- Priest Talents
    angelic_bulwark            = { 82675, 108945, 1 }, -- When an attack brings you below $s1% health, you gain an absorption shield equal to $s2% of your maximum health for $114214d. Cannot occur more than once every $s3 sec.
    angelic_feather            = { 82703, 121536, 1 }, -- Places a feather at the target location, granting the first ally to walk through it $121557s1% increased movement speed for $121557d. Only 3 feathers can be placed at one time.
    angels_mercy               = { 82678, 238100, 1 }, -- Damage you take reduces the cooldown of Desperate Prayer, based on the amount of damage taken.
    apathy                     = { 82689, 390668, 1 }, -- Your $?s137031[Holy Fire][Mind Blast] critical strikes reduce your target's movement speed by $390669s1% for $390669d.
    benevolence                = { 82676, 415416, 1 }, -- Increases the healing of your spells by $s1%.
    binding_heals              = { 82678, 368275, 1 }, -- $s1% of $?c2[Heal or ][]Flash Heal healing on other targets also heals you.
    blessed_recovery           = { 82720, 390767, 1 }, -- After being struck by a melee or ranged critical hit, heal $s1% of the damage taken over $390771d.
    body_and_soul              = { 82706, 64129 , 1 }, -- Power Word: Shield and Leap of Faith increase your target's movement speed by $65081s1% for $65081d.
    crystalline_reflection     = { 82681, 373457, 2 }, -- Power Word: Shield instantly heals the target for $s3 and reflects $s1% of damage absorbed.
    death_and_madness          = { 82711, 321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below $s2% health, its cooldown is reset. Cannot occur more than once every $390628d. $?c3[ If a target dies within $322098d after being struck by your Shadow Word: Death, you gain ${$321973s1/100} Insanity.][]
    dispel_magic               = { 82715, 528   , 1 }, -- Dispels Magic on the enemy target, removing $m1 beneficial Magic $leffect:effects;.
    dominate_mind              = { 82710, 205364, 1 }, -- Controls a mind up to 1 level above yours for $d while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings$?a205477[][ or players]. This spell shares diminishing returns with other disorienting effects.
    essence_devourer           = { 82674, 415479, 1 }, -- Attacks from your Shadowfiend siphon life from enemies, healing a nearby injured ally for $415673s1.$?a137031[][; Attacks from your Mindbender siphon life from enemies, healing a nearby injured ally for $415676s1.]
    focused_mending            = { 82719, 372354, 1 }, -- Prayer of Mending does $s1% increased healing to the initial target.
    from_darkness_comes_light  = { 82707, 390615, 1 }, -- Each time Shadow Word: Pain$?s137032[ or Purge the Wicked][] deals damage, the healing of your next Flash Heal is increased by $s1%, up to a maximum of ${$s1*$390617u}%.
    holy_nova                  = { 82701, 132157, 1 }, -- An explosion of holy light around you deals up to $s1 Holy damage to enemies and up to $281265s1 healing to allies within $A1 yds, reduced if there are more than $s3 targets.
    improved_fade              = { 82686, 390670, 2 }, -- Reduces the cooldown of Fade by ${$s1/-1000)} sec.
    improved_flash_heal        = { 82714, 393870, 1 }, -- Increases healing done by Flash Heal by $s1%.
    improved_mass_dispel       = { 82698, 341167, 1 }, -- Reduces the cooldown of Mass Dispel by ${$s1/-1000} sec and reduces its cast time by ${$s2/-1000}.1 sec.
    inspiration                = { 82696, 390676, 1 }, -- Reduces your target's physical damage taken by $390677s1% for $390677d after a critical heal with $?c1[Flash Heal or Penance]?c2[Flash Heal, Heal, or Holy Word: Serenity][Flash Heal].
    leap_of_faith              = { 82716, 73325 , 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    lights_inspiration         = { 82679, 373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by $s1%.
    manipulation               = { 82672, 390996, 2 }, -- Your $?a137033[Mind Blast, Mind Flay, and Mind Spike]?a137031[Smite and Holy Fire][Smite, Power Word: Solace, Mind Blast, and Penance] casts reduce the cooldown of Mindgames by ${$s1/2}.1 sec.
    mass_dispel                = { 82699, 32375 , 1 }, -- Dispels magic in a $32375a1 yard radius, removing all harmful Magic from $s4 friendly targets and $32592m1 beneficial Magic $leffect:effects; from $s4 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mind_control               = { 82710, 605   , 1 }, -- Controls a mind up to 1 level above yours for $d. Does not work versus Demonic$?A320889[][, Undead,] or Mechanical beings. Shares diminishing returns with other disorienting effects.
    mindgames                  = { 82687, 375901, 1 }, -- Assault an enemy's mind, dealing ${$s1*$m3/100} Shadow damage and briefly reversing their perception of reality.; For $d, the next $<damage> damage they deal will heal their target, and the next $<healing> healing they deal will damage their target.$?s137033[; Generates ${$m8/100} Insanity.][]
    move_with_grace            = { 82702, 390620, 1 }, -- Reduces the cooldown of Leap of Faith by ${$s1/-1000} sec.
    petrifying_scream          = { 82695, 55676 , 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear.
    phantasm                   = { 82556, 108942, 1 }, -- Activating Fade removes all snare effects.
    power_infusion             = { 82694, 10060 , 1 }, -- Infuses the target with power for $d, increasing haste by $s1%.; Can only be cast on players.
    power_word_life            = { 82676, 373481, 1 }, -- A word of holy power that heals the target for $s1. If the target is below $s2% health, Power Word: Life heals for $s3% more and the cooldown of Power Word: Life is reduced by $s4 sec.
    prayer_of_mending          = { 82718, 33076 , 1 }, -- Places a ward on an ally that heals them for $33110s1 the next time they take damage, and then jumps to another ally within $155793a1 yds. Jumps up to $s1 times and lasts $41635d after each jump.
    protective_light           = { 82707, 193063, 1 }, -- Casting Flash Heal on yourself reduces all damage you take by $193065s1% for $193065d.
    psychic_voice              = { 82695, 196704, 1 }, -- Reduces the cooldown of Psychic Scream by ${$m1/-1000} sec.
    renew                      = { 82717, 139   , 1 }, -- Fill the target with faith in the light, healing for $o1 over $d.
    rhapsody                   = { 82700, 390622, 1 }, -- Every $t1 sec, the damage of your next Holy Nova is increased by $390636s1% and its healing is increased by $390636s2%. ; Stacks up to $390636u times.
    sanguine_teachings         = { 82691, 373218, 1 }, -- Increases your Leech by $s1%.
    sanlayn                    = { 82690, 199855, 1 }, -- $@spellicon373218 $@spellname373218; Sanguine Teachings grants an additional $s3% Leech.; $@spellicon15286 $@spellname15286; Reduces the cooldown of Vampiric Embrace by ${$m1/-1000} sec, increases its healing done by $s2%.
    shackle_undead             = { 82693, 9484  , 1 }, -- Shackles the target undead enemy for $d, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shadow_word_death          = { 82712, 32379 , 1 }, -- A word of dark binding that inflicts $s1 Shadow damage to the target. If the target is not killed by Shadow Word: Death, the caster takes damage equal to the damage inflicted upon the target.$?A364675[; Damage increased by ${$s3+$364675s2}% to targets below ${$s2+$364675s1}% health.][; Damage increased by $s3% to targets below $s2% health.]$?c3[][]$?s137033[; Generates ${$s4/100} Insanity.][]
    shadowfiend                = { 82713, 34433 , 1 }, -- Summons a shadowy fiend to attack the target for $d.$?s137033[; Generates ${$262485s1/100} Insanity each time the Shadowfiend attacks.][; Generates ${$s4/10}.1% Mana each time the Shadowfiend attacks.]
    shattered_perceptions      = { 82673, 391112, 1 }, -- Mindgames lasts an additional ${$s3/1000} sec, deals an additional $s1% initial damage, and reverses an additional $s1% damage or healing.
    sheer_terror               = { 82708, 390919, 1 }, -- Increases the amount of damage required to break your Psychic Scream by $s1%.
    spell_warding              = { 82720, 390667, 1 }, -- Reduces all magic damage taken by $s1%.
    surge_of_light             = { 82677, 109186, 2 }, -- Your healing spells and Smite have a $s1% chance to make your next Flash Heal instant and cost no mana. Stacks to $114255u.
    throes_of_pain             = { 82709, 377422, 2 }, -- $?s137032[Shadow Word: Pain and Purge the Wicked deal][Shadow Word: Pain deals] an additional $s1% damage. When an enemy dies while afflicted by your $?s137032[Shadow Word: Pain or Purge the Wicked][Shadow Word: Pain], you gain $?a137033[${$s3/100} Insanity.][${$s5/10}.1% Mana.]
    tithe_evasion              = { 82688, 373223, 1 }, -- Shadow Word: Death deals $s1% less damage to you.
    translucent_image          = { 82685, 373446, 1 }, -- Fade reduces damage you take by $373447s1%.
    twins_of_the_sun_priestess = { 82683, 373466, 1 }, -- Power Infusion also grants you $s1% of its effects when used on an ally.
    twist_of_fate              = { 82684, 390972, 2 }, -- After damaging or healing a target below $s3% health, gain $s1% increased damage and healing for $390978d.
    unwavering_will            = { 82697, 373456, 2 }, -- While above $s2% health, the cast time of your $?a137033[Flash Heal is]?a137032[Flash Heal and Smite are][Flash Heal, Heal, Prayer of Healing, and Smite are] reduced by $s1%.
    vampiric_embrace           = { 82691, 15286 , 1 }, -- Fills you with the embrace of Shadow energy for $d, causing you to heal a nearby ally for $s1% of any single-target Shadow spell damage you deal.
    void_shield                = { 82692, 280749, 1 }, -- When cast on yourself, $s1% of damage you deal refills your Power Word: Shield.
    void_shift                 = { 82674, 108968, 1 }, -- You and the currently targeted party or raid member swap health percentages. Increases the lower health percentage of the two to $s1% if below that amount.
    void_tendrils              = { 82708, 108920, 1 }, -- Summons shadowy tendrils, rooting all enemies within $108920A1 yards for $114404d or until the tendril is killed.
    words_of_the_pious         = { 82721, 377438, 1 }, -- For $390933d after casting Power Word: Shield, you deal $390933s1% additional damage and healing with Smite and Holy Nova.

    -- Holy Talents
    afterlife                  = { 82635, 196707, 1 }, -- Increases the duration of Spirit of Redemption by $s1% and the range of its spells by $s2%.; As a Spirit of Redemption, you may sacrifice your spirit to Resurrect an ally, putting yourself to rest.
    answered_prayers           = { 82608, 391387, 2 }, -- After your Prayer of Mending heals $s1 times, gain Apotheosis for $s2 sec.
    apotheosis                 = { 82610, 200183, 1 }, -- $?s235587[Gain a charge][Reset the cooldown] of your Holy Words, and enter a pure Holy form for $d, increasing the cooldown reductions to your Holy Words by $s1% and reducing their cost by $s2%.
    benediction                = { 82641, 193157, 1 }, -- Your Prayer of Mending has a $s1% chance to leave a Renew on each target it heals.
    burning_vehemence          = { 82607, 372307, 1 }, -- Increases the damage of Holy Fire by $s1%.; Holy Fire deals $s3% of its initial damage to all nearby enemies within $400370A1 yards of your target. Damage reduced beyond $400370s2 targets.
    censure                    = { 82619, 200199, 1 }, -- Holy Word: Chastise stuns the target for $200200d and is not broken by damage.
    circle_of_healing          = { 82624, 204883, 1 }, -- Heals the target and ${$s2-1} injured allies within $A1 yards of the target for $s1.
    cosmic_ripple              = { 82630, 238136, 1 }, -- When Holy Word: Serenity or Holy Word: Sanctify finish their cooldown, you emit a burst of light that heals up to $s1 injured targets within $243241A1 yards for $243241s1.
    crisis_management          = { 82627, 390954, 2 }, -- Increases the critical strike chance of Flash Heal and Heal by $s1%.
    desperate_times            = { 82609, 391381, 2 }, -- Increases healing by $s1% on friendly targets at or below $s2% health.
    divine_hymn                = { 82621, 64843 , 1 }, -- Heals all party or raid members within $64844A1 yards for ${5*$64844s1} over $d. Each heal increases all targets' healing taken by $64844s2% for $64844d, stacking.; Healing increased by $s2% when not in a raid.
    divine_image               = { 82554, 392988, 1 }, -- When you use a Holy Word spell, you summon an image of a Naaru at your side. For $392990d, whenever you cast a healing or damaging spell, the Naaru will cast a similar spell.; If an image has already been summoned, that image is empowered instead.
    divine_service             = { 82642, 391233, 1 }, -- Prayer of Mending heals $s1% more for each bounce remaining.
    divine_star                = { 82682, 110744, 1 }, -- Throw a Divine Star forward $s2 yds, healing allies in its path for $110745s1 and dealing $<holydstardamage> Holy damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond $s1 targets.
    divine_word                = { 82554, 372760, 1 }, -- The effectiveness of your next Holy Word: Serenity, Sanctify, or Chastise is increased by $s1% and grants a corresponding Divine Favor for $372761d.; Chastise: Increases your damage by $372761s1% and Smite has a $372761s3% chance to apply Holy Fire.; Sanctify: Blesses the target area, healing up to $s2 allies for ${$372787s1*($372784d/$372784t3)} over $372784d.; Serenity: Flash Heal, Heal, and Renew heal for $372791s1% more, have a $372791s3% increased chance to critically strike, and cost $372791s4% less mana.
    empowered_renew            = { 82612, 391339, 1 }, -- Renew casts instantly heal your target for $s1% of its total periodic effect.
    empyreal_blaze             = { 82640, 372616, 1 }, -- Refreshes Holy Fire. Your next $s1 casts of Holy Fire cost no Mana, incur no cooldown, and cast instantly. ; Whenever Holy Fire is reapplied, its duration is now extended instead.
    enlightenment              = { 82618, 193155, 1 }, -- You regenerate mana $s1% faster.
    epiphany                   = { 82606, 414553, 2 }, -- Your Holy Words have a $s1% chance to reset the cooldown of Prayer of Mending.
    everlasting_light          = { 82622, 391161, 1 }, -- Heal restores up to $s1% additional health, based on your missing mana.
    gales_of_song              = { 82613, 372370, 2 }, -- Divine Hymn heals for $s1% more. Stacks of Divine Hymn increase healing taken by an additional $s2% per stack.
    guardian_angel             = { 82636, 200209, 1 }, -- When Guardian Spirit saves the target from death, it does not expire.; When Guardian Spirit expires without saving the target from death, reduce its remaining cooldown to $s1 seconds.
    guardian_spirit            = { 82637, 47788 , 1 }, -- Calls upon a guardian spirit to watch over the friendly target for $d, increasing healing received by $s1%. If the target would die, the Spirit sacrifices itself and restores the target to $s2% health.; Castable while stunned. Cannot save the target from massive damage.
    guardians_of_the_light     = { 82636, 196437, 1 }, -- Guardian Spirit also grants you 100% of its effects when used on an ally.
    halo                       = { 82682, 120517, 1 }, -- Creates a ring of Holy energy around you that quickly expands to a 30 yd radius, healing allies for $120692s1 and dealing $<holyhalodamage> Holy damage to enemies.; Healing reduced beyond $s1 targets.
    harmonious_apparatus       = { 82611, 390994, 2 }, -- Circle of Healing reduces the cooldown of Holy Word: Sanctify, Prayer of Mending reduces the cooldown of Holy Word: Serenity, and Holy Fire reduces the cooldown of Holy Word: Chastise by $s1 sec.
    healing_chorus             = { 82625, 390881, 1 }, -- Your Renew healing increases the healing done by your next Circle of Healing by $390885s1%, stacking up to $390885U times.
    holy_mending               = { 82641, 391154, 1 }, -- When Prayer of Mending jumps to a target affected by your Renew, that target is instantly healed for $196781s1.
    holy_word_chastise         = { 82639, 88625 , 1 }, -- Chastises the target for $s1 Holy damage and $?s200199[stuns][incapacitates] them for $?s200199[$200200d][$200196d].$?s63733[; Cooldown reduced by $s2 sec when you cast Smite.][]
    holy_word_salvation        = { 82610, 265202, 1 }, -- Heals all allies within $A1 yards for $s1, and applies Renew and $s2 stacks of Prayer of Mending to each of them.; Cooldown reduced by $s3 sec when you cast Holy Word: Serenity or Holy Word: Sanctify.
    holy_word_sanctify         = { 82631, 34861 , 1 }, -- Releases miraculous light at a target location, healing up to $s2 allies within $a1 yds for $s1.; Cooldown reduced by $s3 sec when you cast Prayer of Healing and by $s4 sec when you cast Renew.
    holy_word_serenity         = { 82638, 2050  , 1 }, -- Perform a miracle, healing an ally for $s1.$?s63733[; Cooldown reduced by $s2 sec when you cast Heal or Flash Heal.][]
    improved_purify            = { 82705, 390632, 1 }, -- Purify additionally removes all Disease effects.
    light_of_the_naaru         = { 82629, 196985, 2 }, -- The cooldowns of your Holy Words are reduced by an additional $s1% when you cast the relevant spells.
    lightweaver                = { 82603, 390992, 1 }, -- Flash Heal reduces the cast time of your next Heal within $390993d by $390993s2% and increases its healing done by $390993s1%.; Stacks up to $390993U times.
    lightwell                  = { 82603, 372835, 1 }, -- Creates a Holy Lightwell. Every $372840t1 sec the Lightwell will attempt to heal party and raid members within $372845a1 yards that are lower than $s2% health for $372847s1 over $372847d. Lightwell lasts for $d or until $372838n heals are expended.
    miracle_worker             = { 82605, 235587, 1 }, -- Holy Word: Serenity and Holy Word: Sanctify gain an additional charge.
    orison                     = { 82626, 390947, 1 }, -- Circle of Healing heals $s1 additional ally and its cooldown is reduced by ${$s2/-1000} sec.
    pontifex                   = { 82628, 390980, 1 }, -- Critical heals from Flash Heal and Heal increase your healing done by your next Holy Word spell by $390989s1%, stacking up to $390989U times.
    prayer_circle              = { 82625, 321377, 1 }, -- Using Circle of Healing reduces the cast time and cost of your Prayer of Healing by $321379m1% for $321379d.
    prayer_of_healing          = { 82632, 596   , 1 }, -- A powerful prayer that heals the target and the ${$s3-1} nearest allies within $A2 yards for $s2.
    prayerful_litany           = { 82623, 391209, 1 }, -- Prayer of Healing heals for $s1% more to the most injured ally it affects.
    prayers_of_the_virtuous    = { 82616, 390977, 2 }, -- Prayer of Mending jumps $s1 additional $Ltime:times;.
    prismatic_echoes           = { 82614, 390967, 2 }, -- Increases the healing done by your Mastery: Echo of Light by $s1%.
    rapid_recovery             = { 82612, 391368, 1 }, -- Increases healing done by Renew by $s1%, but decreases its base duration by ${$s2/-1000} sec.
    renewed_faith              = { 82620, 341997, 1 }, -- Your healing on allies with your Renew is increased by $s1%.
    resonant_words             = { 82604, 372309, 2 }, -- Casting a Holy Word spell increases the healing of your next Heal or Flash Heal by $s1%.
    restitution                = { 82605, 391124, 1 }, -- After Spirit of Redemption expires, you will revive at up to $s1% health, based on your healing done during Spirit of Redemption. After reviving, you cannot benefit from Spirit of Redemption for $211319d.
    revitalizing_prayers       = { 82633, 391208, 1 }, -- Prayer of Healing has a $s1% chance to apply a $s2 second Renew to allies it heals.
    sanctified_prayers         = { 82633, 196489, 1 }, -- Holy Word: Sanctify increases the healing done by Prayer of Healing by $196490s1% for $196490d.
    say_your_prayers           = { 82615, 391186, 1 }, -- Prayer of Mending has a $s1% chance to not consume a charge when it jumps to a new target.
    symbol_of_hope             = { 82617, 64901 , 1 }, -- Bolster the morale of raid members within $265144a1 yds. They each recover $s1 sec of cooldown of a major defensive ability, and regain ${$s2*($d/$t1+1)}% of their missing mana, over $d.
    trail_of_light             = { 82634, 200128, 2 }, -- When you cast Heal or Flash Heal, $s1% of the healing is replicated to the previous target you healed with Heal or Flash Heal.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_faith         = 1927, -- (408853) Leap of Faith also pulls the spirit of the $s1 furthest allies within $s2 yards and shields you and the affected allies for $<absfaith>.
    catharsis              = 5485, -- (391297) $s2% of all damage you take is stored. The stored amount cannot exceed $s3% of your maximum health. The initial damage of your next $?s204197[Purge the Wicked][Shadow Word: Pain] deals this stored damage to your target.
    divine_ascension       = 5366, -- (328530) You ascend into the air out of harm's way. While floating, your spell range is increased by $329543s3%, but you are only able to cast Holy spells.
    greater_heal           = 112, -- (289666) An exceptional spell that heals an ally for $m1% of their maximum health, ignoring healing reduction effects.
    holy_ward              = 101, -- (213610) Wards the friendly target against the next full loss of control effect.
    phase_shift            = 5569, -- (408557) Step into the shadows when you cast Fade, avoiding all attacks and spells for $408558d.; Interrupt effects are not affected by Phase Shift.
    purification           = 5479, -- (196439) Purify now has a maximum of ${$s2+1} charges.; Removing harmful effects with Purify grants your target an absorption shield equal to $s1% of their maximum health. Lasts $196440d.
    ray_of_hope            = 127, -- (197268) For the next $d, all damage and healing dealt to the target is delayed until Ray of Hope ends. All healing that is delayed by Ray of Hope is increased by $s5%.
    sanctified_ground      = 108, -- (357481) Holy Word: Sanctify blesses the ground with divine light, causing all allies who stand within to be immune to all silence and interrupt effects. Lasts for $289657d.
    seraphic_crescendo     = 5620, -- (419110) Reduces the cooldown of by Divine Hymn by ${$s3/-1000} sec and causes it to channel $s1% faster. Additionally, the healing bonus from Divine Hymn now lasts an additional ${$s4/1000} sec.
    spirit_of_the_redeemer = 124, -- (215982) Your Spirit of Redemption is now an active ability with a $m2 minute cooldown, but the duration is reduced by $m3 sec and you will no longer enter Spirit of Redemption upon dying.
    thoughtsteal           = 5365, -- (316262) Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for $322431d.; Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
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


spec:RegisterGear( "tier30", 202543, 202542, 202541, 202545, 202540 )
spec:RegisterAuras( {
    inspired_word = {
        id = 409479,
        duration = 3600,
        max_stack = 15
    }
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

        talent = "empyreal_blaze",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "empyreal_blaze", nil, 3 )
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

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,

        cycle = "holy_fire",

        handler = function ()
            applyDebuff( "holy_fire" )
            removeStack( "empyreal_blaze" )

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

        talent = "holy_word_salvation",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "inspired_word" )
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

        talent = "holy_word_sanctify",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "inspired_word" )
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

        talent = "holy_word_serenity",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            removeBuff( "inspired_word" )
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
        school = "shadow",
        damage = 1,

        spend = 0.02,
        spendType = "mana",

        talent = "mindgames",
        startsCombat = true,

        handler = function ()
            applyDebuff( "mindgames" )
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
            applyDebuff( "shackle_undead" )
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
            applyDebuff( "shadow_word_pain" )
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


spec:RegisterPack( "Holy Priest", 20230504, [[Hekili:TZvBZTTns4FlE6m2sTk6KFlnPtuMPxs71K7M2mNAN(njbrczHZue84lwX3OH)2VDxqqcccsr560lNN8LezcGf777dwqP5Np)xNpZNLYN)Zxm5IlNC9KRgpzYfxF93oFw69r85ZIyE3YUb(qiBl8V)Km4(8LFiwWtsXbVpqY8rIKiZI9GjmF2Qmrq67cNVYnLFom3iUh8yCt2i895Q5Yt8MpdN7ZMC9ZMC53LVmF5VfHKWpF56y528LZeBFZ483N)E10UcMzRtd4Uy5AraWtmVuHmmzCum3tUDfl9BM(xIK74Xl2jJ9xSwgNksZ85iL)Q8LFFWo29j5lZs45l)PFmFPyD(YDWN3WUd(x(2O7J5SG8LRcy)h4bd8LPWJ)ykpmb2NH5lLX4KJ3kdfYmGsSOiwmlf)4apGnJ5(zepvmxCdePNbdhIKYlloMhMIA6uH3TIWBgNV8xs3WJ3js4JG1eIJr83Un8qKGRJ5jByRcGhLkbwd()KSyUIXVHdufwF(Yaz4nGPlFPFgWqahKVmsMKiGfc7X7iEaukPBqgsrkpgoF(D4(O2nIsPSyIS7ebGQWxGBOeP3kwcAkWp(VYs0BSiuKkqL2gKU(STGtfSJ)omelib2gFz4zi5yH12xX2TCFbyDrjwg65YaiqJvKM7qbMHsoyUJIaLhYD3jc5KK5N)(c3bWjyd4nVyTiMpY7EVa(cLmLm98rI1thKYcaRWy92TG2T97lECL9DrP5D)(tkmy73BysgE6jdwLTETfPgNfD6apPmWxUlCSIhjpsyG97Pfu)HdpTC2eNtEVEBa9e4wGJtUVVvPivQVz)(39bYyt6bwKemgYeuHH(DA9YA2DYyisQKwommKgsB2tqpmpg5bI2trIY4P8Cid(F7nVnbCvteKnB2wrk8F(GWdRnjqCZgY)EReTuk3bCHmWaYagkdDQqMFSP9cuNG0RK7iMiKmtgk6k9)WthO40XPITGHvUa8qF9uisDSnrgRdfaZKPsNukMQ3IHRuIWZin(hahnYJdDBbFdEhQwtXXJfeSq9NlcejPJWCStDU9lqNzuCl8(mCmov7q2WL40oeh0lIy(FqXVVTGF)rCAqcfzAr6HDc0K2Q4Se3dk8ZqWIZc7RCHt7o(OK0yHxQkWRtJaXZ)ZSqlwc(pipepoPjRRyqL8EmSOIGFs0514FHY3VnnEXWQnK73xzGwwn1ADPqrwKzklSG1jc5WcmyMdTB6v8(Yz6w2j)xGi3XIfyKQA1L5d5FK7TaJuhjJMMWtfRh5jd9fifN6mp8O7ybz8PQn1oXksUSuUII0exWds4tNqcCvaC1(cU0ZsPCrBK7uLjbGagPlvL5sz3QdZvBXdsSDXaDi4vtVUqBKiQBb(3qBRzUFuaOI3VPkmgW5PbIKOQERl2aRn0VkdXVJfrl0himdSYlw5VOOHhMcNkmyQ(gCXwb88382HQDhYyxF)xJXWaiJySmp6rAVHdoxtHX9uPBO3W6eDv7mMVfQeK8ANvJlgCylfRlg(vthOTYJB6x)nLJ5Y4puv5(DeoZZqVq2kzwnCq1Y2nQevMnuiamd(CSUnIdQeuvcw9LrvLvg3qz4Z0LD1WdO62Q0L7eHGG2tfTvKjOS7wrD4GwfqMA2FfMxnuCYll5(qpD6YkpjYzDaorDotWN7hkvu)vsr1pbZG7RjvorFD6GtAbXOBSFkBU6aveWuJIQODhsDFZn9ckr3crtM1UiBb8YdNexvSgPjlqIubojhaHPat4y8PVE6f9MkfdNaRVjXmgKOjOR(viTaxdUNbhAZllGbkOvGE92iPieZCHNWtesvVW8yGBq8gwuI0)(cxdABQbK9Ej(8DBeEBW8)ObjuEhdhIHZGslLUHIrW0QgUG(YElTKDaPlLnYsZPhdevfccntpguaE3(6PN)IH733(QU09QEzNl6k3l6kyrTUMR7T8cPR9Vbk3L07vyImhoPq6gfSfcg)gi0jDZ4iV0xDXKEtXM((KJewNY4GMQt2KOoIc(eFX61C8i4gUj4ZtGqkMV2hbp4i6bGJILM((F5hWZ7KMPC(gHjuRGoOYRw5DHN0UibCFLgIdDDu12DMooA3Agafw4hyGF5IFkhVxPHEshMxkMhk6UCIhrq9xzJG0Ro8qnEfwIgHo(j02OcXu9NZeOl7oMiq1vSv81e(EcKti)JP1Bl0OcyNQdcz0GnS9gQgljsnH9QamJGFz6ECLa6dSLDBl4rt6Fi1K7Q0viona7RXr1jyvWHOl4k6EEayqJ4EagPx1jMTHhI9Bl9bDmZgyXv9rjmzheF7d4uy3dNCNoE8PN4ITtyHazxFp1ymxJJjRfPToUbknfQRaK3WoXcj0VJt5rI5pdXutb969tNbPG8WKW(wbpDh7(rky108XEDrDVc7tMmlWV4KruJqXchrXsVghPVSjOVd7PkNO1iTR0ooE(OKiSFWRybmQlAR4PWZXdK57tBCr7ZmPlv3rbD0QNFJkeNsXuhprC)owrrUGYMfxWNQMQZzu2siILw7gdCRGpevkuhIzOkBZFOPTDuHnz6l7ZIkSih1IAf3SEQ1HO3ofpQAG6v90S4xnT8tWQEA5R9YD6zCe15AJc25qlAU2bCIRMLT)R64L(17edEW4Q6QnBJJlcxp7DFAKYGB88hVL9XV(YHoLN(fcvTGNyrpww2NsbovIMJyMQbFaHlgl2osr7swDjrRfCWsHUcZOUe9H3D4RYq3CPuP822qVzUtQ7qweUodV3xYaEsZ7kWejMj0QSOdDDEkSk)cHffIafyF7ew99I4b8XkMOngnTGbjtBD(wFPkBOufa0HWBlpWR6kMPncuGoPnmLfG1yBs7KF(miQa)C57cWLZNTJfhcHjjZN9RkSgrY40cG(NvUbNHOj(3za8cmCusiRZsLBvx3pOSWRZEC(7)hKP6cWC(gziSB0WN10yCMsUCmYyEiEqbCgdo)JdPxZahCMpFnlli944RZDZx1ZxBXA2Dh1M76KYUUCAl67AkTTlx(OQx7KMnJeS57MHkTSdx)jGRBHMpIC9Z7KRjScUzBAO(6fBEiUAnm(Zfh7wcLRqIyrvZld7OmD)H4183)osVIe8fGMYtLKgVFuujnFg9j6LSYPghxWDCy8FMEtSkO)8)68zEXqs1ybJEBPSWiLV81tbnK(fBA(m8HZtHSR9KigaMAqlJXqsEPfjl3sDXF1BUvSis98plbEzQjguq9MWykuf5lpv1TwliqQHphmZdZxUFp4dCakDz3u6L9Mqx1nHUQKqDsLRrZ5vO5uBdlbOzAHHjDDRUrnaOLV8vGkBsfnBGRdj4Zn31MPcT2(VTfxoc1hWnM9)gdCApwXYYA5Q(51TaGs(lm1tfIRPQjTm8Ks23DEJ2BYg5oDc531DZ2uEvD3WTwNJbswWbTsUQYu7kLvtVen)yz9(sl8(ZPfELA65ZE5bliuZ5WELxDuzbU2C21RdBnZN3ZQEDw60oPZJqPZx8LsNpLkD(Y(u688jp21op)8ExuW8oz(cMYVey8NuGX)dXu2zDOQclnG99K8kMT8i74QJjnCx33RPB0rDnYaLNEqsxwVT7SALFDDkZLPNVRV8oDNuSwpoCLBugbSb((3wTl6xzt6tluF)NA(MDw3vUJUgGKr)I5oF2KI)uVDD92q6knSb)2y)B2leRqGhZ3aAtTJl66wF2HIOLxR5UkCyCKI6c6tT3852cXDeAwgU96dgpsLcgCOPHb2WK64LCoF53ymUlNbAZgww0WHP0gPFnZ5NDVG0M2JdR96xKUDLslquQm91ulFcFrPDkGTCgFLt0jAY1sAqvDf3Vs0f(gp4s7)bEzQB05K6xvNQKs51s1OIKXLoAb8PTgCu)wYSeKhJ7S0kxrLDXX1C0SyFDXNmUhY(RdTBllT6wiTK0J62nByKAEvJDKAP8MkTyHnh6Ip712cUhfxqDdNJd2RJl6DVoo6kGh)lasFd5nlWaEofVWh5l)A6ukotY)GoaA7NC4bFa0otW8LdG()Bha9B7ZbqT7g3F4dG(YdFcMIxwaxN3OMlhEhcDFXgd6vv1EC1(QjIfduFrPv)DTF)agAC)aTvNUdaJ6ReWrvunTpyLeR4VV8lYWt5Frg6cLK9xwFBKVpT(ToWkIVMpKDyB5P2ksFz87CGk1yN)whyeLBgNwVzj6iD9KQ9lFGl0i1SnhZVkcvgC7FteC0EdN4xpTk7xZCkMZQdXftjPELnk6NrhTqYb6MAs)J1pRcvAgRV)9qSb9L73QqrNwZEiC4oCNZZHwt8EG)cm0H085IzU46tCGsSDfWX9t4WXAs7418YLyi0Vnb2xPz9ZDL2(V6dDWGgBN(0oPkSoSS0nY45Z(7SiaCCOGE68)7p]] )
