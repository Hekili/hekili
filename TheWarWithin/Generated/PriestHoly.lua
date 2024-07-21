-- PriestHoly.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 257 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Insanity )

spec:RegisterTalents( {
    -- Priest Talents
    angelic_bulwark            = { 82675, 108945, 1 }, -- When an attack brings you below $s1% health, you gain an absorption shield equal to $s2% of your maximum health for $114214d. Cannot occur more than once every $s3 sec.
    angelic_feather            = { 82703, 121536, 1 }, -- Places a feather at the target location, granting the first ally to walk through it $121557s1% increased movement speed for $121557d.$?a440670[ When an ally walks through a feather, you are also granted $440670s3% of its effect.][] Only 3 feathers can be placed at one time.
    angels_mercy               = { 82678, 238100, 1 }, -- Reduces the cooldown of Desperate Prayer by ${$s1/-1000} sec.
    apathy                     = { 82689, 390668, 1 }, -- Your $?s137031[Holy Fire][Mind Blast] critical strikes reduce your target's movement speed by $390669s1% for $390669d.
    benevolence                = { 82676, 415416, 1 }, -- Increases the healing of your spells by $s1%.
    binding_heals              = { 82678, 368275, 1 }, -- $s1% of $?c2[Heal or ][]Flash Heal healing on other targets also heals you.
    blessed_recovery           = { 82720, 390767, 1 }, -- After being struck by a melee or ranged critical hit, heal $s1% of the damage taken over $390771d.
    body_and_soul              = { 82706, 64129 , 1 }, -- Power Word: Shield and Leap of Faith increase your target's movement speed by $65081s1% for $65081d.
    cauterizing_shadows        = { 82687, 459990, 1 }, -- When your Shadow Word: Pain$?a137032[ or Purge the Wicked][] expires or is refreshed with less than $s1 sec remaining, a nearby ally within $459992A1 yards is healed for $?a137033[${$459992s1*$s2/100}][$459992s1]. 
    crystalline_reflection     = { 82681, 373457, 2 }, -- Power Word: Shield instantly heals the target for $s3 and reflects $s1% of damage absorbed.
    death_and_madness          = { 82711, 321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below $s2% health, its cooldown is reset. Cannot occur more than once every $390628d. $?c3[ If a target dies within $322098d after being struck by your Shadow Word: Death, you gain ${$321973s1/100} Insanity.][]
    dispel_magic               = { 82715, 528   , 1 }, -- Dispels Magic on the enemy target, removing $m1 beneficial Magic $leffect:effects;.
    dominate_mind              = { 82710, 205364, 1 }, -- Controls a mind up to 1 level above yours for $d while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings$?a205477[][ or players]. This spell shares diminishing returns with other disorienting effects.
    essence_devourer           = { 82674, 415479, 1 }, -- Attacks from your Shadowfiend siphon life from enemies, healing a nearby injured ally for $415673s1.$?a137031[][; Attacks from your Mindbender siphon life from enemies, healing a nearby injured ally for $415676s1.]
    focused_mending            = { 82719, 372354, 1 }, -- Prayer of Mending does $s1% increased healing to the initial target.
    from_darkness_comes_light  = { 82707, 390615, 1 }, -- Each time Shadow Word: Pain$?s137032[ or Purge the Wicked][] deals damage, the healing of your next Flash Heal is increased by $s1%, up to a maximum of $?a137033&$?a134735[$390617s2][${$s1*$390617u}]%.
    holy_nova                  = { 82701, 132157, 1 }, -- An explosion of holy light around you deals up to $s1 Holy damage to enemies and up to $281265s1 healing to allies within $A1 yds, reduced if there are more than $s3 targets.
    improved_fade              = { 82686, 390670, 2 }, -- Reduces the cooldown of Fade by ${$s1/-1000)} sec.
    improved_flash_heal        = { 82714, 393870, 1 }, -- Increases healing done by Flash Heal by $s1%.
    inspiration                = { 82696, 390676, 1 }, -- Reduces your target's physical damage taken by $390677s1% for $390677d after a critical heal with $?c1[Flash Heal or Penance]?c2[Flash Heal, Heal, or Holy Word: Serenity][Flash Heal].
    leap_of_faith              = { 82716, 73325 , 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    lights_inspiration         = { 82679, 373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by $s1%.
    manipulation               = { 82672, 459985, 2 }, -- You take $s1% less damage from enemies affected by your Shadow Word: Pain$?a137032[ or Purge the Wicked]?a137031[ or Holy Fire][]. 
    mass_dispel                = { 82699, 32375 , 1 }, -- Dispels magic in a $32375a1 yard radius, removing all harmful Magic from $s4 friendly targets and $32592m1 beneficial Magic $leffect:effects; from $s4 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mental_agility             = { 82698, 341167, 1 }, -- Reduces the mana cost of $?a137033[Purify Disease][Purify] and Mass Dispel by $s1% and Dispel Magic by $s2%.; 
    mind_control               = { 82710, 605   , 1 }, -- Controls a mind up to 1 level above yours for $d. Does not work versus Demonic$?A320889[][, Undead,] or Mechanical beings. Shares diminishing returns with other disorienting effects.
    move_with_grace            = { 82702, 390620, 1 }, -- Reduces the cooldown of Leap of Faith by ${$s1/-1000} sec.
    petrifying_scream          = { 82695, 55676 , 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear.
    phantasm                   = { 82556, 108942, 1 }, -- Activating Fade removes all snare effects.
    phantom_reach              = { 82673, 459559, 1 }, -- Increases the range of most spells by $s1%.
    power_infusion             = { 82694, 10060 , 1 }, -- Infuses the target with power for $d, increasing haste by $s1%.; Can only be cast on players.
    power_word_life            = { 82676, 373481, 1 }, -- A word of holy power that heals the target for $s1. ; Only usable if the target is below $s2% health.
    prayer_of_mending          = { 82718, 33076 , 1 }, -- Places a ward on an ally that heals them for $33110s1 the next time they take damage, and then jumps to another ally within $155793a1 yds. Jumps up to $s1 times and lasts $41635d after each jump.
    protective_light           = { 82707, 193063, 1 }, -- Casting Flash Heal on yourself reduces all damage you take by $193065s1% for $193065d.
    psychic_voice              = { 82695, 196704, 1 }, -- Reduces the cooldown of Psychic Scream by ${$m1/-1000} sec.
    renew                      = { 82717, 139   , 1 }, -- Fill the target with faith in the light, healing for $o1 over $d.
    rhapsody                   = { 82700, 390622, 1 }, -- Every $t1 sec, the damage of your next Holy Nova is increased by $390636s1% and its healing is increased by $390636s2%. ; Stacks up to $390636u times.
    sanguine_teachings         = { 82691, 373218, 1 }, -- Increases your Leech by $s1%.
    sanlayn                    = { 82690, 199855, 1 }, -- $@spellicon373218 $@spellname373218; Sanguine Teachings grants an additional $s3% Leech.; $@spellicon15286 $@spellname15286; Reduces the cooldown of Vampiric Embrace by ${$m1/-1000} sec, increases its healing done by $s2%.
    shackle_undead             = { 82693, 9484  , 1 }, -- Shackles the target undead enemy for $d, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shadow_word_death          = { 82712, 32379 , 1 }, -- A word of dark binding that inflicts $s2 Shadow damage to your target. If your target is not killed by Shadow Word: Death, you take backlash damage equal to $s6% of your maximum health.$?A364675[; Damage increased by ${$s4+$364675s2}% to targets below ${$s3+$364675s1}% health.][; Damage increased by $s4% to targets below $s3% health.]$?c3[][]$?s137033[; Generates ${$s5/100} Insanity.][]
    shadowfiend                = { 82713, 34433 , 1 }, -- Summons a shadowy fiend to attack the target for $d.$?s137033[; Generates ${$262485s1/100} Insanity each time the Shadowfiend attacks.][; Generates ${$s4/10}.1% Mana each time the Shadowfiend attacks.]
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
    void_shift                 = { 82674, 108968, 1 }, -- Swap health percentages with your ally. Increases the lower health percentage of the two to $s1% if below that amount.
    void_tendrils              = { 82708, 108920, 1 }, -- Summons shadowy tendrils, rooting all enemies within $108920A1 yards for $114404d or until the tendril is killed.
    words_of_the_pious         = { 82721, 377438, 1 }, -- For $390933d after casting Power Word: Shield, you deal $390933s1% additional damage and healing with Smite and Holy Nova.

    -- Holy Talents
    afterlife                  = { 82635, 196707, 1 }, -- Increases the duration of Spirit of Redemption by $s1% and the range of its spells by $s2%.; As a Spirit of Redemption, you may sacrifice your spirit to Resurrect an ally, putting yourself to rest.
    answered_prayers           = { 82608, 391387, 2 }, -- After your Prayer of Mending heals $s1 times, gain Apotheosis for $s2 sec.
    apotheosis                 = { 82610, 200183, 1 }, -- $?s235587[Gain a charge][Reset the cooldown] of your Holy Words, and enter a pure Holy form for $d, increasing the cooldown reductions to your Holy Words by $s1% and reducing their cost by $s2%.
    assured_safety             = { 94691, 440766, 1 }, -- $?a137032[Power Word: Shield casts apply $s1 $Lstack:stacks; of Prayer of Mending to your target.][Prayer of Mending casts apply a Power Word: Shield to your target at $s2% effectiveness.]
    benediction                = { 82641, 193157, 1 }, -- Your Prayer of Mending has a $s1% chance to leave a Renew on each target it heals.
    burning_vehemence          = { 82607, 372307, 1 }, -- Increases the damage of Holy Fire by $s1%.; Holy Fire deals $s3% of its initial damage to all nearby enemies within $400370A1 yards of your target. Damage reduced beyond $400370s2 targets.
    censure                    = { 82619, 200199, 1 }, -- Holy Word: Chastise stuns the target for $200200d and is not broken by damage.
    circle_of_healing          = { 82624, 204883, 1 }, -- Heals the target and ${$s2-1} injured allies within $A1 yards of the target for $s1.
    clairvoyance               = { 94687, 428940, 1 }, -- [440725] Grants Premonition of Insight, Piety, and Solace at $428940s2% effectiveness.
    concentrated_infusion      = { 94676, 453844, 1 }, -- Your Power Infusion effect grants you an additional $s1% haste.
    cosmic_ripple              = { 82630, 238136, 1 }, -- When Holy Word: Serenity or Holy Word: Sanctify finish their cooldown, you emit a burst of light that heals up to $s1 injured targets within $243241A1 yards for $243241s1.
    crisis_management          = { 82627, 390954, 2 }, -- Increases the critical strike chance of Flash Heal and Heal by $s1%.
    desperate_measures         = { 94690, 458718, 1 }, -- Desperate Prayer lasts an additional ${$s1/1000} sec.; Angelic Bulwark's absorption effect is increased by $s2% of your maximum health.
    desperate_times            = { 82609, 391381, 2 }, -- Increases healing by $s1% on friendly targets at or below $s2% health.
    divine_feathers            = { 94675, 440670, 1 }, -- Your Angelic Feathers increase movement speed by an additional $s2%.; When an ally walks through your Angelic Feather, you are also granted $s1% of its effect.; 
    divine_halo                = { 94702, 449806, 1 }, -- Halo now centers around you and returns to you after it reaches its maximum distance, healing allies and damaging enemies each time it passes through them.
    divine_hymn                = { 82621, 64843 , 1 }, -- Heals all party or raid members within $64844A1 yards for ${5*$64844s1} over $d. Each heal increases all targets' healing taken by $64844s2% for $64844d, stacking.; Healing reduced beyond $s5 targets.
    divine_image               = { 82554, 392988, 1 }, -- When you use a Holy Word spell, you summon an image of a Naaru at your side. For $392990d, whenever you cast a healing or damaging spell, the Naaru will cast a similar spell.; If an image has already been summoned, that image is empowered instead.
    divine_providence          = { 94673, 440742, 1 }, -- Premonition gains an additional charge.
    divine_service             = { 82642, 391233, 1 }, -- Prayer of Mending heals $s1% more for each bounce remaining.
    divine_star                = { 82682, 110744, 1 }, -- Throw a Divine Star forward $s2 yds, healing allies in its path for $110745s1 and dealing $<holydstardamage> Holy damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond $s1 targets.
    divine_word                = { 82605, 372760, 1 }, -- The effectiveness of your next Holy Word: Serenity, Sanctify, or Chastise is increased by $s1% and grants a corresponding Divine Favor for $372761d.; Chastise: Increases your damage by $372761s1% and refunds $s2 sec from the cooldown of Holy Word: Chastise.; Sanctify: Blesses the target area, healing up to $372787s2 allies for ${$372787s1*($372784d/$372784t3)} over $372784d.; Serenity: Flash Heal, Heal, and Renew heal for $372791s1% more and cost $372791s3% less mana.
    empowered_surges           = { 94688, 453799, 1 }, -- $?a137033[Increases the damage done by Mind Flay: Insanity and Mind Spike: Insanity by $s2%.; ][]Increases the healing done by Flash Heals affected by Surge of Light by $s1%.
    empyreal_blaze             = { 82640, 372616, 1 }, -- Holy Word: Chastise causes your next $s1 casts of Holy Fire to be instant, cost no mana, and incur no cooldown.; Refreshing Holy Fire on a target now extends its duration by $14914d.
    energy_compression         = { 94678, 449874, 1 }, -- Halo damage and healing is increased by $s1%.
    energy_cycle               = { 94685, 453828, 1 }, -- $?a137031[Consuming Surge of Light reduces the cooldown of Holy Word: Sanctify by ${$s1/-1000} sec.][Consuming Surge of Insanity has a $s2% chance to conjure Shadowy Apparitions.]
    enlightenment              = { 82618, 193155, 1 }, -- You regenerate mana $s1% faster.
    epiphany                   = { 82606, 414553, 2 }, -- Your Holy Words have a $s1% chance to reset the cooldown of Prayer of Mending.
    everlasting_light          = { 82622, 391161, 1 }, -- Heal restores up to $s1% additional health, based on your missing mana.
    fatebender                 = { 94700, 440743, 1 }, -- Increases the effects of Premonition by $s1%.
    foreseen_circumstances     = { 94689, 440738, 1 }, -- $?a137032[Pain Suppression reduces damage taken by an additional $s1%.][Guardian Spirit lasts an additional ${$s2/1000} sec.]
    gales_of_song              = { 82613, 372370, 1 }, -- Divine Hymn heals for $s1% more. Stacks of Divine Hymn increase healing taken by an additional $s2% per stack.
    guardian_angel             = { 82636, 200209, 1 }, -- When Guardian Spirit saves the target from death, it does not expire.; When Guardian Spirit expires without saving the target from death, reduce its remaining cooldown to $s1 seconds.
    guardian_spirit            = { 82637, 47788 , 1 }, -- Calls upon a guardian spirit to watch over the friendly target for $d, increasing healing received by $s1%. If the target would die, the Spirit sacrifices itself and restores the target to $s2% health.; Castable while stunned. Cannot save the target from massive damage.
    guardians_of_the_light     = { 82636, 196437, 1 }, -- Guardian Spirit also grants you 100% of its effects when used on an ally.
    halo                       = { 82682, 120517, 1 }, -- Creates a ring of Holy energy around you that quickly expands to a $s2 yd radius, healing allies for $120692s1 and dealing $<holyhalodamage> Holy damage to enemies.; Healing reduced beyond $s1 targets.
    healing_chorus             = { 82625, 390881, 1 }, -- Your Renew healing increases the healing done by your next Circle of Healing by $390885s1%, stacking up to $390885U times.
    heightened_alteration      = { 94680, 453729, 1 }, -- $?a137031[Increases the duration of Spirit of Redemption by ${$s1/1000} sec.][Increases the duration of Dispersion by ${$s2/1000} sec.]
    holy_mending               = { 82641, 391154, 1 }, -- When Prayer of Mending jumps to a target affected by your Renew, that target is instantly healed for $196781s1.
    holy_word_chastise         = { 82639, 88625 , 1 }, -- Chastises the target for $s1 Holy damage and $?s200199[stuns][incapacitates] them for $?s200199[$200200d][$200196d].$?s63733[; Cooldown reduced by $s2 sec when you cast Smite.][]
    holy_word_salvation        = { 82610, 265202, 1 }, -- Heals all allies within $A1 yards for $s1, and applies Renew and $s2 stacks of Prayer of Mending to each of them.; Cooldown reduced by $s3 sec when you cast Holy Word: Serenity or Holy Word: Sanctify.
    holy_word_sanctify         = { 82631, 34861 , 1 }, -- Releases miraculous light at a target location, healing up to $s2 allies within $a1 yds for $s1.; Cooldown reduced by $s3 sec when you cast Prayer of Healing and by $s4 sec when you cast Renew.
    holy_word_serenity         = { 82638, 2050  , 1 }, -- Perform a miracle, healing an ally for $s1.$?s63733[; Cooldown reduced by $s2 sec when you cast Heal or Flash Heal.][]
    improved_purify            = { 82705, 390632, 1 }, -- Purify additionally removes all Disease effects.
    incessant_screams          = { 94686, 453918, 1 }, -- Psychic Scream creates an image of you at your location. After $s1 sec, the image will let out a Psychic Scream.
    light_of_the_naaru         = { 82629, 196985, 2 }, -- The cooldowns of your Holy Words are reduced by an additional $s1% when you cast the relevant spells.
    lightweaver                = { 82603, 390992, 1 }, -- Flash Heal reduces the cast time of your next Heal within $390993d by $390993s2% and increases its healing done by $390993s1%.; Stacks up to $390993U times.
    lightwell                  = { 82603, 372835, 1 }, -- Creates a Holy Lightwell. Every $372840t1 sec the Lightwell will attempt to heal a nearby party or raid member within $372845a1 yards that is lower than $s2% health for $372847s1 and apply a Renew to them for ${$s3/1000} sec. Lightwell lasts for $d or until it heals $372838n times.; Cooldown reduced by ${$440616s1/-1000} sec when you cast Holy Word: Serenity or Holy Word: Sanctify.
    manifested_power           = { 94699, 453783, 1 }, -- Creating a Halo grants $?a137033[Surge of Insanity][Surge of Light].
    miracle_worker             = { 82612, 235587, 1 }, -- Holy Word: Serenity and Holy Word: Sanctify gain an additional charge.
    miraculous_recovery        = { 94679, 440674, 1 }, -- Reduces the cooldown of Power Word: Life by ${$s1/-1000} sec and allows it to be usable on targets below $s2% health.; 
    orison                     = { 82626, 390947, 1 }, -- Circle of Healing heals $s1 additional ally and its cooldown is reduced by ${$s2/-1000} sec.
    perfect_vision             = { 94700, 440661, 1 }, -- Reduces the cooldown of Premonition by ${$s1/-1000} sec.; 
    perfected_form             = { 94677, 453917, 1 }, -- $?a137031[Your healing done is increased by $s3% while Apotheosis is active and for 20 sec after you cast Holy Word: Salvation.][Your damage dealt is increased by $s5% while Dark Ascension is active and by $s1% while Voidform is active.]
    pontifex                   = { 82628, 390980, 1 }, -- Flash Heal, Heal, Prayer of Healing, and Circle of Healing increase the healing done by your next Holy Word spell by $390989s1%, stacking up to $390989U times. Lasts $390989d.
    power_surge                = { 94697, 453109, 1 }, -- Casting Halo also causes you to create a Halo around you at $s2% effectiveness every $453112t sec for $453112d.; Additionally, the radius of Halo is increased by $s1 yards.
    prayer_circle              = { 82625, 321377, 1 }, -- Circle of Healing reduces the cast time and cost of your Prayer of Healing by $321379m1% for $321379d.
    prayer_of_healing          = { 82632, 596   , 1 }, -- A powerful prayer that heals the target and the ${$s3-1} nearest allies within $A2 yards for $s2.
    prayerful_litany           = { 82623, 391209, 1 }, -- Prayer of Healing heals for $s1% more to the most injured ally it affects.
    prayers_of_the_virtuous    = { 82616, 390977, 2 }, -- Prayer of Mending jumps $s1 additional $Ltime:times;.
    preemptive_care            = { 94674, 440671, 1 }, -- Increases the duration of $?a137032[Atonement by ${$s1/1000} sec and the duration of ][]Renew by ${$s2/1000} sec.; 
    premonition                = { 94683, 428924, 1 }, -- [428933] Reduces the cooldown of your next $s2 spell casts by $?a440743[${$s1/-1000}.1][${$s1/-1000}] sec.
    preventive_measures        = { 94698, 440662, 1 }, -- $?a137032[Power Word: Shield absorbs $s1% additional damage.; All damage dealt by Penance, Smite and Holy Nova increased by $s3%.][Increases the healing done by Prayer of Mending by $s2%.; All damage dealt by Smite, Holy Fire and Holy Nova increased by $s4%.]; 
    prismatic_echoes           = { 82614, 390967, 2 }, -- Increases the healing done by your Mastery: Echo of Light by $s1%.
    prophets_will              = { 94690, 433905, 1 }, -- $?a137032[Your Flash Heal and Power Word: Shield are $s1%][Your Flash Heal, Heal, and Holy Word: Serenity are $s1%] more effective when cast on yourself.
    renewed_faith              = { 82620, 341997, 1 }, -- Your healing on allies with your Renew is increased by $s1%.
    resonant_energy            = { 94681, 453845, 1 }, -- $?a137033[Enemies damaged by your Halo take $453850s1% increased damage from you for $453846d, stacking up to $453846U times.][Allies healed by your Halo receive $453850s1% increased healing from you for $453850d, stacking up to $453850U times.]
    resonant_words             = { 82604, 372309, 2 }, -- Casting a Holy Word spell increases the healing of your next Flash Heal, Heal, Prayer of Healing, or Circle of Healing by $s1%. Lasts $372313d.
    restitution                = { 82605, 391124, 1 }, -- After Spirit of Redemption expires, you will revive at up to $s1% health, based on your healing done during Spirit of Redemption. After reviving, you cannot benefit from Spirit of Redemption for $211319d.
    revitalizing_prayers       = { 82633, 391208, 1 }, -- Prayer of Healing has a $s1% chance to apply a $s2 second Renew to allies it heals.
    sanctified_prayers         = { 82633, 196489, 1 }, -- Holy Word: Sanctify increases the healing done by Prayer of Healing by $196490s1% for $196490d.
    save_the_day               = { 94675, 440669, 1 }, -- For $458650d after casting Leap of Faith you may cast it a second time for free, ignoring its cooldown.
    say_your_prayers           = { 82615, 391186, 1 }, -- Prayer of Mending has a $s1% chance to not consume a charge when it jumps to a new target.
    shock_pulse                = { 94686, 453852, 1 }, -- Halo damage reduces enemy movement speed by $453848s1% for $453848d, stacking up to $453848U times.
    sustained_potency          = { 94678, 454001, 1 }, -- Creating a Halo extends the duration of $?a137031[Apotheosis by ${$s1/1000} sec. ; If Apotheosis is not active][Dark Ascension or Voidform by ${$s1/1000} sec.; If Dark Ascension and Voidform are not active], up to $454002U seconds is stored and applied the next time you gain $?a137031[Apotheosis][Dark Ascension or Voidform].
    symbol_of_hope             = { 82617, 64901 , 1 }, -- Bolster the morale of raid members within $265144a1 yds. They each recover $s1 sec of cooldown of a major defensive ability, and regain ${$s2*($d/$t1+1)}% of their missing mana, over $d.
    trail_of_light             = { 82634, 200128, 2 }, -- When you cast Heal or Flash Heal, $s1% of the healing is replicated to the previous target you healed with Heal or Flash Heal.
    voice_of_harmony           = { 82611, 390994, 2 }, -- Circle of Healing reduces the cooldown of Holy Word: Sanctify by $s1 sec.; Prayer of Mending reduces the cooldown of Holy Word: Serenity by $s2 sec.; Holy Fire and Holy Nova reduce the cooldown of Holy Word: Chastise by $s3 sec.
    waste_no_time              = { 94679, 440681, 1 }, -- Premonition causes your next $?a137032[Power Word: Radiance][Heal or Prayer of Healing] cast to be instant and cost $440683s2% less mana.; 
    word_of_supremacy          = { 94680, 453726, 1 }, -- Power Word: Fortitude grants you an additional $s1% stamina.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_faith         = 1927, -- (408853) Leap of Faith also pulls the spirit of the $s1 furthest allies within $s2 yards and shields you and the affected allies for $<absfaith>.
    catharsis              = 5485, -- (391297) $s2% of all damage you take is stored. The stored amount cannot exceed $s3% of your maximum health. The initial damage of your next $?s204197[Purge the Wicked][Shadow Word: Pain] deals this stored damage to your target.
    divine_ascension       = 5366, -- (328530) You ascend into the air out of harm's way. While floating, your spell range is increased by $329543s3%, but you are only able to cast Holy spells.
    greater_heal           = 112 , -- (289666) An exceptional spell that heals an ally for $m1% of their maximum health, ignoring healing reduction effects. 
    holy_ward              = 101 , -- (213610) Wards the friendly target against the next full loss of control effect.
    improved_mass_dispel   = 5634, -- (426438) Reduces the cooldown of Mass Dispel by ${$s1/-1000} sec.
    mindgames              = 5639, -- (375901) Assault an enemy's mind, dealing ${$s1*$m3/100} Shadow damage and briefly reversing their perception of reality.; For $d, the next $<damage> damage they deal will heal their target, and the next $<healing> healing they deal will damage their target.$?s137033[; Generates ${$m8/100} Insanity.][]
    phase_shift            = 5569, -- (408557) Step into the shadows when you cast Fade, avoiding all attacks and spells for $408558d.; Interrupt effects are not affected by Phase Shift.
    purification           = 5479, -- (196439) Purify now has a maximum of ${$s2+1} charges.; Removing harmful effects with Purify grants your target an absorption shield equal to $s1% of their maximum health. Lasts $196440d.
    ray_of_hope            = 127 , -- (197268) For the next $d, all damage and healing dealt to the target is delayed until Ray of Hope ends. All healing that is delayed by Ray of Hope is increased by $s5%.
    sanctified_ground      = 108 , -- (357481) Holy Word: Sanctify blesses the ground with divine light, causing all allies who stand within to be immune to all silence and interrupt effects. Lasts for $289657d.
    seraphic_crescendo     = 5620, -- (419110) Reduces the cooldown of Divine Hymn by ${$s3/-1000} sec and causes it to channel $s1% faster. Additionally, the healing bonus from Divine Hymn now lasts an additional ${$s4/1000} sec. 
    spirit_of_the_redeemer = 124 , -- (215982) Your Spirit of Redemption is now an active ability with a $m2 minute cooldown, but the duration is reduced by $m3 sec and you will no longer enter Spirit of Redemption upon dying.
    thoughtsteal           = 5365, -- (316262) Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for $322431d.; Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
} )

-- Auras
spec:RegisterAuras( {
    -- Absorbs $w1 damage.
    angelic_bulwark = {
        id = 114214,
        duration = 20.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w1%.
    angelic_feather = {
        id = 121557,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- divine_feathers[440670] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Movement speed reduced by $s1%.
    apathy = {
        id = 390669,
        duration = 4.0,
        max_stack = 1,
    },
    -- Effects that reduce Holy Word cooldowns increased by $s1%. Cost of Holy Words reduced by $s2%.$?$w3>0[; All healing done increased by $w3%.][]
    apotheosis = {
        id = 200183,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- perfected_form[453917] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- perfected_form[453917] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },
    -- Flying.
    ascension = {
        id = 161862,
        duration = 20.0,
        max_stack = 1,
    },
    -- Healing $w1 damage every $t1 sec.
    blessed_recovery = {
        id = 390771,
        duration = 6.0,
        max_stack = 1,
    },
    -- Movement speed increased by $s1%.
    body_and_soul = {
        id = 65081,
        duration = 3.0,
        max_stack = 1,
    },
    -- If the target dies within $d, the Priest gains ${$321973s1/100} Insanity.
    death_and_madness = {
        id = 322098,
        duration = 7.0,
        max_stack = 1,
    },
    -- Maximum health increased by $w1%.
    desperate_prayer = {
        id = 19236,
        duration = 10.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- lights_inspiration[373450] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- lights_inspiration[373450] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Slowly falling. Spell range increased by $s3%.
    divine_ascension = {
        id = 329543,
        duration = 10.0,
        max_stack = 1,
    },
    -- Increases the damage done by spells by $s1%.
    divine_favor_chastise = {
        id = 372761,
        duration = 15.0,
        max_stack = 1,
    },
    -- Healing received increased by $w2%.
    divine_hymn = {
        id = 64844,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- apotheosis[200183] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- apotheosis[200183] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- gales_of_song[372370] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- gales_of_song[372370] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- seraphic_crescendo[419110] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- divine_ascension[329543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- spirit_of_redemption[27827] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- A Naaru is at your side. Whenever you cast a spell, the Naaru will cast a similar spell.
    divine_image = {
        id = 392990,
        duration = 9.0,
        max_stack = 1,
    },
    -- The effectiveness of your next Holy Word: Serenity, Sanctify, or Chastise is increased by $s1% and grants a corresponding Divine Favor for $372761d.
    divine_word = {
        id = 372760,
        duration = 10.0,
        max_stack = 1,
    },
    -- Under the control of $@auracaster.
    dominate_mind = {
        id = 205364,
        duration = 30.0,
        max_stack = 1,
    },
    -- Healing $w1 every $t1 sec.
    echo_of_light = {
        id = 77489,
        duration = 4.0,
        max_stack = 1,
    },
    -- Reduced threat level. Enemies have a reduced attack range against you.$?e3; [ ; Damage taken reduced by $s4%.][]
    fade = {
        id = 586,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- improved_fade[390670] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- All magical damage taken reduced by $w1%.; All physical damage taken reduced by $w2%.
    focused_will = {
        id = 426401,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- holy_priest[137031] #12: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- discipline_priest[137032] #14: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Increased healing received by $w1%$?$w1<100[ and will prevent 1 killing blow][].
    guardian_spirit = {
        id = 47788,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- foreseen_circumstances[440738] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- The healing of your next Circle of Healing is increased by $w1%.
    healing_chorus = {
        id = 390885,
        duration = 20.0,
        max_stack = 1,
    },
    -- $w2 Holy damage every $t2 seconds.
    holy_fire = {
        id = 14914,
        duration = 7.0,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- manipulation[459985] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- burning_vehemence[372307] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- burning_vehemence[372307] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- preventive_measures[440662] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preventive_measures[440662] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_fire[231687] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Warded against the next full loss of control effect.
    holy_ward = {
        id = 213610,
        duration = 15.0,
        max_stack = 1,
    },
    -- Stunned.
    holy_word_chastise = {
        id = 200200,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- phantom_reach[459559] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- apotheosis[200183] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_word[372760] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Reduces physical damage taken by $s1%.
    inspiration = {
        id = 390677,
        duration = 15.0,
        max_stack = 1,
    },
    -- Being pulled toward the Priest.
    leap_of_faith = {
        id = 73325,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- save_the_day[458650] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Levitating.$?a343988[; Movement speed increased by $343988w%.][]
    levitate = {
        id = 111759,
        duration = 600.0,
        max_stack = 1,
    },
    -- Healing taken from the Priest increased by $s1%.
    light_of_tuure = {
        id = 208065,
        duration = 10.0,
        max_stack = 1,
    },
    -- The cast time of your next Heal is reduced by $w2% and its healing is increased by $w1%.
    lightweaver = {
        id = 390993,
        duration = 20.0,
        max_stack = 1,
    },
    -- Increases the threshold at which Shadow Word: Death will do extra damage by $s1%. Increases the extra damage by $s2%.
    looming_death = {
        id = 364675,
        duration = 3600,
        max_stack = 1,
    },
    -- Under the command of $@auracaster.
    mind_control = {
        id = 605,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Reduced distance at which target will attack.
    mind_soothe = {
        id = 453,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Sight granted through target's eyes.
    mind_vision = {
        id = 2096,
        duration = 60.0,
        max_stack = 1,

        -- Affected by:
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- The next $w2 damage and $w5 healing dealt will be reversed.
    mindgames = {
        id = 375901,
        duration = 7.0,
        max_stack = 1,

        -- Affected by:
        -- holy_priest[137031] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twilight_equilibrium[390707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -38.81, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Movement speed is unhindered.
    phantasm = {
        id = 114239,
        duration = 0.0,
        max_stack = 1,
    },
    -- Most melee attacks, ranged attacks, and spells will miss you.
    phase_shift = {
        id = 408558,
        duration = 1.0,
        max_stack = 1,
    },
    -- The healing of your next Holy Word spell is increased by $w1%.
    pontifex = {
        id = 390989,
        duration = 30.0,
        max_stack = 1,
    },
    -- Haste increased by $w1%.
    power_infusion = {
        id = 10060,
        duration = 15.0,
        max_stack = 1,
    },
    -- Stamina increased by $w1%.$?$w2>0[; Magic damage taken reduced by $w2%.][]
    power_word_fortitude = {
        id = 21562,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    power_word_shield = {
        id = 17,
        duration = 15.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- priest[137030] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- benevolence[415416] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- preventive_measures[440662] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- divine_ascension[329543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- spirit_of_redemption[27827] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- discipline_priest[137032] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- discipline_priest[137032] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- shadow_priest[137033] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- shadow_priest[137033] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- shadow_priest[137033] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- inner_quietus[448278] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
    },
    -- Cast time and cost of Prayer of Healing reduced by $w1%.
    prayer_circle = {
        id = 321379,
        duration = 8.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w1%.
    protective_light = {
        id = 193065,
        duration = 10.0,
        max_stack = 1,
    },
    -- Disoriented.
    psychic_scream = {
        id = 8122,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- petrifying_scream[55676] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- psychic_voice[196704] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- Absorbs $w1 damage.
    purification = {
        id = 196440,
        duration = 8.0,
        max_stack = 1,
    },
    -- Delaying damage and healing.  Ray of Hope will heal when it expires.
    ray_of_hope = {
        id = 232707,
        duration = 6.0,
        max_stack = 1,
    },
    -- Healing $w1 health every $t1 sec.
    renew = {
        id = 139,
        duration = 15.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- apotheosis[200183] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- apotheosis[200183] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- preemptive_care[440671] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- renewed_faith[341997] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- divine_ascension[329543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- spirit_of_redemption[27827] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- The healing done by your next Flash Heal, Heal, Prayer of Healing, or Circle of Healing is increased by $w1%.
    resonant_words = {
        id = 372313,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- resonant_words[372309] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- The power of Light recently revived you.; You have recently benefited from Spirit of Redemption and cannot benefit from it again.
    restitution = {
        id = 211319,
        duration = 600.0,
        max_stack = 1,
    },
    -- The damage of your next Holy Nova is increased by $w1% and its healing is increased by $w2%.
    rhapsody = {
        id = 390636,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- discipline_priest[137032] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -37.5, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Prayer of Healing heals for $w1% more.
    sanctified_prayers = {
        id = 196490,
        duration = 15.0,
        max_stack = 1,
    },
    -- Leap of Faith is free and ignores its cooldown.
    save_the_day = {
        id = 458650,
        duration = 6.0,
        max_stack = 1,
    },
    -- Taking $s1% increased damage from the Priest.
    schism = {
        id = 214621,
        duration = 9.0,
        max_stack = 1,

        -- Affected by:
        -- twilight_equilibrium[390707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Shackled.
    shackle_undead = {
        id = 9484,
        duration = 50.0,
        max_stack = 1,

        -- Affected by:
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Suffering $w2 Shadow damage every $t2 sec.
    shadow_word_pain = {
        id = 589,
        duration = 16.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 69.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 69.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- manipulation[459985] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- throes_of_pain[377422] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- throes_of_pain[377422] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- discipline_priest[137032] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 18.1, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 18.1, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 21.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 21.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_quietus[448278] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_quietus[448278] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- 343726
    shadowfiend = {
        id = 34433,
        duration = 15.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $w1%.
    shock_pulse = {
        id = 453848,
        duration = 5.0,
        max_stack = 1,
    },
    -- You have become more powerful than anyone can possibly imagine.
    spirit_of_redemption = {
        id = 27827,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- afterlife[196707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- afterlife[196707] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- afterlife[196707] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- heightened_alteration[453729] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Next Flash Heal is instant$?$w5>0[, heals for $w5% more,][] and costs no mana.
    surge_of_light = {
        id = 114255,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- empowered_surges[453799] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
    },
    -- Rapidly recovering a major defensive ability, and regaining $64901s2% missing mana every $64901t1 sec.
    symbol_of_hope = {
        id = 265144,
        duration = 1.1,
        max_stack = 1,

        -- Affected by:
        -- phantom_reach[459559] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- divine_ascension[329543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- spirit_of_redemption[27827] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Stolen a spell from an enemy, preventing them from casting it for $d.
    thoughtsteal = {
        id = 322431,
        duration = 20.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w%.
    translucent_image = {
        id = 373447,
        duration = 8.0,
        max_stack = 1,
    },
    -- The damage of your next Holy spell is increased by $s1%.
    twilight_equilibrium = {
        id = 390706,
        duration = 6.0,
        max_stack = 1,
    },
    -- Increases damage and healing by $w1%.
    twist_of_fate = {
        id = 390978,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- twist_of_fate[390972] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- twist_of_fate[390972] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- $15286s1% of any single-target Shadow spell damage you deal heals a nearby ally.
    vampiric_embrace = {
        id = 15286,
        duration = 12.0,
        tick_time = 0.5,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- sanlayn[199855] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- sanlayn[199855] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- A Shadowy tendril is appearing under you.
    void_tendrils = {
        id = 108920,
        duration = 0.5,
        max_stack = 1,
    },
    -- Dealing $s1 Shadow damage to the target every $t sec.; Insanity drain temporarily stopped.
    void_torrent = {
        id = 205065,
        duration = 4.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Spell damage dealt increased by $w1%.; $?s341240[Critical strike chance increased by ${$W3}.1%.][]
    voidform = {
        id = 194249,
        duration = 20.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- perfected_form[453917] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- perfected_form[453917] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- $?a137031[Heal and Prayer of Healing][Power Word: Radiance] is instant and costs $w2% less mana.
    waste_no_time = {
        id = 440683,
        duration = 20.0,
        max_stack = 1,
    },
    -- Damage and healing of Smite and Holy Nova is increased by $s1%.
    words_of_the_pious = {
        id = 390933,
        duration = 12.0,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Places a feather at the target location, granting the first ally to walk through it $121557s1% increased movement speed for $121557d.$?a440670[ When an ally walks through a feather, you are also granted $440670s3% of its effect.][] Only 3 feathers can be placed at one time.
    angelic_feather = {
        id = 121536,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "angelic_feather",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 2.0, 'target': TARGET_UNIT_DEST_AREA_ALLY, }
    },

    -- $?s235587[Gain a charge][Reset the cooldown] of your Holy Words, and enter a pure Holy form for $d, increasing the cooldown reductions to your Holy Words by $s1% and reducing their cost by $s2%.
    apotheosis = {
        id = 200183,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "apotheosis",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 300.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- #4: { 'type': APPLY_AURA, 'subtype': WATER_WALK, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_DISPEL_RESIST, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- perfected_form[453917] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
        -- perfected_form[453917] #3: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
    },

    -- Ascend into the air, keeping you out of harm's way. Lasts $d. Can only be used while in Ashran.
    ascension = {
        id = 161862,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': FLY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_VEHICLE_SPEED_ALWAYS, 'points': 150.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Heals the target and ${$s2-1} injured allies within $A1 yards of the target for $s1.
    circle_of_healing = {
        id = 204883,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.033,
        spendType = 'mana',

        talent = "circle_of_healing",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 0.9975, 'variance': 0.05, 'radius': 30.0, 'target': TARGET_DEST_TARGET_ALLY, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- priest[137030] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- apotheosis[200183] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- apotheosis[200183] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- orison[390947] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- orison[390947] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- healing_chorus[390885] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- resonant_words[372313] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Increases maximum health by $?s373450[${$s1+$373450s1}][$s1]% for $?a458718[${($458718s1+$s4)/1000}][${$s4/1000}] sec, and instantly heals you for that amount.
    desperate_prayer = {
        id = 19236,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_HEALTH_PERCENT, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': HEAL_PCT, 'subtype': NONE, 'points': 25.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- lights_inspiration[373450] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- lights_inspiration[373450] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- Dispels Magic on the enemy target, removing $m1 beneficial Magic $leffect:effects;.
    dispel_magic = {
        id = 528,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        spend = 0.020,
        spendType = 'mana',

        spend = 0.140,
        spendType = 'mana',

        talent = "dispel_magic",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 1.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- mental_agility[341167] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- mental_agility[341167] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- mental_agility[341167] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- You ascend into the air out of harm's way. While floating, your spell range is increased by $329543s3%, but you are only able to cast Holy spells.
    divine_ascension = {
        id = 328530,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 1.5,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': KNOCK_BACK, 'subtype': NONE, 'points': 400.0, 'value': 5, 'schools': ['physical', 'fire'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 329543, 'value': 1000, 'schools': ['nature', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 329541, 'value': 500, 'schools': ['fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 7, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 12, }
        -- #5: { 'type': APPLY_AURA, 'subtype': DAMAGE_IMMUNITY, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': MOD_SILENCE, 'value': 124, 'schools': ['fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING_BY_SPELL_LABEL, 'value': 954, 'schools': ['holy', 'nature', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 18, }
    },

    -- Heals all party or raid members within $64844A1 yards for ${5*$64844s1} over $d. Each heal increases all targets' healing taken by $64844s2% for $64844d, stacking.; Healing reduced beyond $s5 targets.
    divine_hymn = {
        id = 64843,
        cast = 8.0,
        channeled = true,
        cooldown = 180.0,
        gcd = "global",

        spend = 0.044,
        spendType = 'mana',

        talent = "divine_hymn",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 2.0, 'trigger_spell': 64844, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }
        -- #4: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- seraphic_crescendo[419110] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- seraphic_crescendo[419110] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- seraphic_crescendo[419110] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Throw a Divine Star forward $s2 yds, healing allies in its path for $110745s1 and dealing $<holydstardamage> Holy damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond $s1 targets.
    divine_star = {
        id = 110744,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "divine_star",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 6.0, 'value': 2148, 'schools': ['fire', 'shadow', 'arcane'], 'target': TARGET_DEST_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_DEST_CASTER, }

        -- Affected by:
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- phantom_reach[459559] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Controls a mind up to 1 level above yours for $d while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings$?a205477[][ or players]. This spell shares diminishing returns with other disorienting effects.
    dominate_mind = {
        id = 205364,
        cast = 1.8,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "dominate_mind",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_CHARM, 'points_per_level': 1.0, 'points': 2.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
    },

    -- Fade out, removing all your threat and reducing enemies' attack range against you for $d.; 
    fade = {
        id = 586,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_TOTAL_THREAT, 'points': -90000000.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DETECTED_RANGE, 'points': -10.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_MINIMUM_SPEED, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -10.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- improved_fade[390670] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- A fast spell that heals an ally for $s1.
    flash_heal = {
        id = 2061,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.1,
        spendType = 'mana',

        -- 0. [137031] holy_priest
        -- spend = 0.036,
        -- spendType = 'mana',

        -- 1. [137033] shadow_priest
        -- spend = 0.100,
        -- spendType = 'mana',

        -- 2. [137032] discipline_priest
        -- spend = 0.036,
        -- spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'amplitude': 1.0, 'sp_bonus': 3.4104, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 28.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_flash_heal[393870] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- unwavering_will[373456] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- unwavering_will[373456] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- apotheosis[200183] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- apotheosis[200183] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crisis_management[390954] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- prophets_will[433905] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- resonant_words[372313] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 63.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 46.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- surge_of_light[114255] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- surge_of_light[114255] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- surge_of_light[114255] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- surge_of_light[114255] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- surge_of_light[114255] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- An exceptional spell that heals an ally for $m1% of their maximum health, ignoring healing reduction effects. 
    greater_heal = {
        id = 289666,
        color = 'pvp_talent',
        cast = 3.0,
        cooldown = 12.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL_PCT, 'subtype': NONE, 'points': 40.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Calls upon a guardian spirit to watch over the friendly target for $d, increasing healing received by $s1%. If the target would die, the Spirit sacrifices itself and restores the target to $s2% health.; Castable while stunned. Cannot save the target from massive damage.
    guardian_spirit = {
        id = 47788,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "none",

        spend = 0.009,
        spendType = 'mana',

        talent = "guardian_spirit",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_PCT, 'points': 60.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB_OVERKILL, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 20, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- foreseen_circumstances[440738] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Creates a ring of Holy energy around you that quickly expands to a $s2 yd radius, healing allies for $120692s1 and dealing $<holyhalodamage> Holy damage to enemies.; Healing reduced beyond $s1 targets.
    halo = {
        id = 120517,
        cast = 1.5,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.027,
        spendType = 'mana',

        talent = "halo",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 6.0, 'value': 658, 'schools': ['holy', 'frost'], 'target': TARGET_DEST_CASTER, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 30.0, 'value': 33742, 'schools': ['holy', 'fire', 'nature', 'arcane'], 'target': TARGET_DEST_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': AREA_TRIGGER, 'value': 33742, 'schools': ['holy', 'fire', 'nature', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- phantom_reach[459559] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- energy_compression[449874] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- power_surge[453109] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },

    -- An efficient spell that heals an ally for $s1.
    heal = {
        id = 2060,
        cast = 2.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.024,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'amplitude': 1.0, 'sp_bonus': 5.885, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- unwavering_will[373456] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- apotheosis[200183] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- apotheosis[200183] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- crisis_management[390954] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- prophets_will[433905] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- lightweaver[390993] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lightweaver[390993] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- resonant_words[372313] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- waste_no_time[440683] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- waste_no_time[440683] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Consumes the enemy in Holy flames that cause $s1 Holy damage and an additional $o2 Holy damage over $d.$?a231687[ Stacks up to $u times.][]
    holy_fire = {
        id = 14914,
        cast = 1.5,
        cooldown = 10.0,
        gcd = "global",

        spend = 0.004,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.8975, 'pvp_multiplier': 0.8, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'sp_bonus': 0.104363, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': AREA_TRIGGER, 'value': 19526, 'schools': ['holy', 'fire', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_TARGET_RESIST, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- manipulation[459985] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- burning_vehemence[372307] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- burning_vehemence[372307] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- preventive_measures[440662] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preventive_measures[440662] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_fire[231687] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- An explosion of holy light around you deals up to $s1 Holy damage to enemies and up to $281265s1 healing to allies within $A1 yds, reduced if there are more than $s3 targets.
    holy_nova = {
        id = 132157,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.016,
        spendType = 'mana',

        talent = "holy_nova",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.4095, 'variance': 0.05, 'radius': 12.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 281265, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- preventive_measures[440662] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preventive_measures[440662] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- words_of_the_pious[390933] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rhapsody[390636] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twilight_equilibrium[390706] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Wards the friendly target against the next full loss of control effect.
    holy_ward = {
        id = 213610,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.009,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 2078, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 1, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 2, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 5, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 13, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 24, }
        -- #6: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 14, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 17, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 30, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 10, }
        -- #10: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 12, }
    },

    -- Chastises the target for $s1 Holy damage and $?s200199[stuns][incapacitates] them for $?s200199[$200200d][$200196d].$?s63733[; Cooldown reduced by $s2 sec when you cast Smite.][]
    holy_word_chastise = {
        id = 88625,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.006,
        spendType = 'mana',

        talent = "holy_word_chastise",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.457, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- apotheosis[200183] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- divine_word[372760] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Heals all allies within $A1 yards for $s1, and applies Renew and $s2 stacks of Prayer of Mending to each of them.; Cooldown reduced by $s3 sec when you cast Holy Word: Serenity or Holy Word: Sanctify.
    holy_word_salvation = {
        id = 265202,
        cast = 2.5,
        cooldown = 720.0,
        gcd = "global",

        spend = 0.060,
        spendType = 'mana',

        talent = "holy_word_salvation",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 1.045, 'variance': 0.05, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ALLY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ALLY, }

        -- Affected by:
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- apotheosis[200183] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- apotheosis[200183] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- pontifex[390989] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_ascension[329543] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Releases miraculous light at a target location, healing up to $s2 allies within $a1 yds for $s1.; Cooldown reduced by $s3 sec when you cast Prayer of Healing and by $s4 sec when you cast Renew.
    holy_word_sanctify = {
        id = 34861,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.035,
        spendType = 'mana',

        talent = "holy_word_sanctify",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 2.91, 'pvp_multiplier': 1.1, 'variance': 0.05, 'radius': 10.0, 'target': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- apotheosis[200183] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- apotheosis[200183] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- apotheosis[200183] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_word[372760] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- miracle_worker[235587] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- pontifex[390989] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Perform a miracle, healing an ally for $s1.$?s63733[; Cooldown reduced by $s2 sec when you cast Heal or Flash Heal.][]
    holy_word_serenity = {
        id = 2050,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.025,
        spendType = 'mana',

        talent = "holy_word_serenity",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'amplitude': 1.0, 'sp_bonus': 10.38, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- apotheosis[200183] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- apotheosis[200183] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- apotheosis[200183] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_word[372760] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- miracle_worker[235587] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- prophets_will[433905] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- pontifex[390989] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    leap_of_faith = {
        id = 73325,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        spend = 0.026,
        spendType = 'mana',

        talent = "leap_of_faith",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING_2, 'target': TARGET_UNIT_TARGET_RAID, }

        -- Affected by:
        -- save_the_day[458650] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Levitates a party or raid member for $111759d, floating a few feet above the ground, granting slow fall, and allowing travel over water.
    levitate = {
        id = 1706,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.009,
        spendType = 'mana',

        spend = 0.009,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_RAID, }

        -- Affected by:
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Applies Light of the Naaru to the target, healing for $s2 and increasing your healing done to that target by $208065s1% for $d.
    light_of_tuure = {
        id = 208065,
        color = 'artifact',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 1.0, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Draws upon the power of Light's Wrath, dealing $s1 Radiant damage to the target, increased by $s2% per ally affected by your Atonement.
    lights_wrath = {
        id = 207946,
        color = 'artifact',
        cast = 2.5,
        cooldown = 90.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.75, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Creates a Holy Lightwell. Every $372840t1 sec the Lightwell will attempt to heal a nearby party or raid member within $372845a1 yards that is lower than $s2% health for $372847s1 and apply a Renew to them for ${$s3/1000} sec. Lightwell lasts for $d or until it heals $372838n times.; Cooldown reduced by ${$440616s1/-1000} sec when you cast Holy Word: Serenity or Holy Word: Sanctify.
    lightwell = {
        id = 372835,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        spend = 0.037,
        spendType = 'mana',

        talent = "lightwell",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 1.0, 'value': 189820, 'schools': ['fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 1141, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': UNKNOWN, 'subtype': NONE, 'points': 50.0, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- phantom_reach[459559] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- Dispels magic in a $32375a1 yard radius, removing all harmful Magic from $s4 friendly targets and $32592m1 beneficial Magic $leffect:effects; from $s4 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mass_dispel = {
        id = 32375,
        cast = 1.5,
        cooldown = 120.0,
        gcd = "global",

        spend = 0.080,
        spendType = 'mana',

        spend = 0.080,
        spendType = 'mana',

        spend = 0.200,
        spendType = 'mana',

        talent = "mass_dispel",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 1, 'schools': ['physical'], 'radius': 15.0, 'target': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 32592, 'points': 1.0, 'radius': 10.0, 'target': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 72734, 'points': 72734.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mental_agility[341167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- mental_agility[341167] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- mental_agility[341167] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- improved_mass_dispel[426438] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- shadow_priest[137033] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 42.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Brings all dead party members back to life with $s1% health and mana. Cannot be cast when in combat.
    mass_resurrection = {
        id = 212036,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT_WITH_AURA, 'subtype': NONE, 'points': 35.0, 'radius': 100.0, 'target': TARGET_CORPSE_SRC_AREA_RAID, }

        -- Affected by:
        -- phantom_reach[459559] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -13.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Blasts the target's mind for $s1 Shadow damage$?s424509[ and increases your spell damage to the target by $424509s1% for $214621d.][.]$?s137033[; Generates ${$s2/100} Insanity.][]
    mind_blast = {
        id = 8092,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.04,
        spendType = 'mana',

        -- 0. [137032] discipline_priest
        -- spend = 0.016,
        -- spendType = 'mana',

        -- 1. [137031] holy_priest
        -- spend = 0.003,
        -- spendType = 'mana',

        -- 2. [137033] shadow_priest
        -- spend = 0.003,
        -- spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.78336, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': insanity, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- twilight_equilibrium[390707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- discipline_priest[137032] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 600.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- shadow_priest[137033] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 49.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 37.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Controls a mind up to 1 level above yours for $d. Does not work versus Demonic$?A320889[][, Undead,] or Mechanical beings. Shares diminishing returns with other disorienting effects.
    mind_control = {
        id = 605,
        cast = 30.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        talent = "mind_control",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_POSSESS, 'points_per_level': 1.0, 'points': 35.0, 'radius': 100.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Soothes enemies in the target area, reducing the range at which they will attack you by $s1 yards. Only affects Humanoid and Dragonkin targets. Does not cause threat. Lasts $d.
    mind_soothe = {
        id = 453,
        cast = 0.0,
        cooldown = 5.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DETECT_RANGE, 'points': -10.0, 'radius': 12.0, 'target': TARGET_DEST_DEST, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'radius': 12.0, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Allows the caster to see through the target's eyes for $d. Will not work if the target is in another instance or on another continent.
    mind_vision = {
        id = 2096,
        cast = 60.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': BIND_SIGHT, 'radius': 100.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_STALKED, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Assault an enemy's mind, dealing ${$s1*$m3/100} Shadow damage and briefly reversing their perception of reality.; For $d, the next $<damage> damage they deal will heal their target, and the next $<healing> healing they deal will damage their target.$?s137033[; Generates ${$m8/100} Insanity.][]
    mindgames = {
        id = 375901,
        cast = 1.5,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 3.0, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 400.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 375902, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 400.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #5: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 450.0, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #6: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 375903, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': ENERGIZE, 'subtype': NONE, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'resource': insanity, }

        -- Affected by:
        -- holy_priest[137031] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twilight_equilibrium[390707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -38.81, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Infuses the target with power for $d, increasing haste by $s1%.; Can only be cast on players.
    power_infusion = {
        id = 10060,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "power_infusion",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'sp_bonus': 0.25, 'points': 20.0, 'value': 126, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Infuses the target with vitality, increasing their Stamina by $s1% for $d.; If the target is in your party or raid, all party and raid members will be affected.
    power_word_fortitude = {
        id = 21562,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_TOTAL_STAT_PERCENTAGE, 'points': 5.0, 'radius': 100.0, 'target': TARGET_UNIT_TARGET_ALLY_OR_RAID, 'modifies': unknown, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'schools': ['holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 100.0, 'target': TARGET_UNIT_TARGET_ALLY_OR_RAID, }
    },

    -- A word of holy power that heals the target for $s1. ; Only usable if the target is below $s2% health.
    power_word_life = {
        id = 373481,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.025,
        spendType = 'mana',

        spend = 0.025,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        talent = "power_word_life",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 10.35, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #3: { 'type': UNKNOWN, 'subtype': NONE, 'points': 20.0, }

        -- Affected by:
        -- miraculous_recovery[440674] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Shields an ally for $d, absorbing $s1 damage.
    power_word_shield = {
        id = 17,
        cast = 0.0,
        cooldown = 7.5,
        gcd = "global",

        spend = 0.1,
        spendType = 'mana',

        -- 0. [137032] discipline_priest
        -- spend = 0.024,
        -- spendType = 'mana',

        -- 1. [137031] holy_priest
        -- spend = 0.031,
        -- spendType = 'mana',

        -- 2. [137033] shadow_priest
        -- spend = 0.100,
        -- spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'sp_bonus': 4.032, 'variance': 0.05, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- priest[137030] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- benevolence[415416] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- preventive_measures[440662] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- divine_ascension[329543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- spirit_of_redemption[27827] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- discipline_priest[137032] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- discipline_priest[137032] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- shadow_priest[137033] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- shadow_priest[137033] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- shadow_priest[137033] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- inner_quietus[448278] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
    },

    -- A powerful prayer that heals the target and the ${$s3-1} nearest allies within $A2 yards for $s2.
    prayer_of_healing = {
        id = 596,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.044,
        spendType = 'mana',

        talent = "prayer_of_healing",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 98367, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 0.83125, 'variance': 0.05, 'radius': 40.0, 'target': TARGET_DEST_TARGET_ALLY, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- unwavering_will[373456] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- apotheosis[200183] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- apotheosis[200183] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- prayer_circle[321379] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- prayer_circle[321379] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- resonant_words[372313] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- sanctified_prayers[196490] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- waste_no_time[440683] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- waste_no_time[440683] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Places a ward on an ally that heals them for $33110s1 the next time they take damage, and then jumps to another ally within $155793a1 yds. Jumps up to $s1 times and lasts $41635d after each jump.
    prayer_of_mending = {
        id = 33076,
        cast = 0.0,
        cooldown = 12.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        spend = 0.020,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        talent = "prayer_of_mending",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- priest[137030] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- prayers_of_the_virtuous[390977] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- [428933] Reduces the cooldown of your next $s2 spell casts by $?a440743[${$s1/-1000}.1][${$s1/-1000}] sec.
    premonition = {
        id = 428924,
        cast = 0.0,
        cooldown = 0.5,
        gcd = "none",

        talent = "premonition",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- divine_providence[440742] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Lets out a psychic scream, causing all enemies within $A1 yards to flee, disorienting them for $d. Damage may interrupt the effect.
    psychic_scream = {
        id = 8122,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.012,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_FEAR, 'value': 1, 'schools': ['physical'], 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'points': 4.0, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_ROOT_2, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }

        -- Affected by:
        -- petrifying_scream[55676] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- psychic_voice[196704] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -15000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Dispels harmful effects on the target, removing all Magic$?s390632[ and Disease][] effects.
    purify = {
        id = 527,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        spend = 0.013,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DISPEL, 'subtype': NONE, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- mental_agility[341167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- purification[196439] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- [213634] Removes all Disease effects from a friendly target.
    purify_disease = {
        id = 440006,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- mental_agility[341167] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- purification[196439] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- For the next $d, all damage and healing dealt to the target is delayed until Ray of Hope ends. All healing that is delayed by Ray of Hope is increased by $s5%.
    ray_of_hope = {
        id = 197268,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        spend = 0.030,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 10, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_HEAL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 10, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #4: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 50.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #5: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 232707, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Fill the target with faith in the light, healing for $o1 over $d.
    renew = {
        id = 139,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.018,
        spendType = 'mana',

        spend = 0.024,
        spendType = 'mana',

        spend = 0.080,
        spendType = 'mana',

        talent = "renew",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 3.0, 'sp_bonus': 0.32, 'pvp_multiplier': 1.22, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- apotheosis[200183] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- apotheosis[200183] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- preemptive_care[440671] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- renewed_faith[341997] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- divine_ascension[329543] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- spirit_of_redemption[27827] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Brings a dead ally back to life with $s1% health and mana. Cannot be cast when in combat.
    resurrection = {
        id = 2006,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 35.0, }

        -- Affected by:
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Blesses the ground with divine light, causing all allies who stand within to be immune to all silence and interrupt effects. Lasts for $d.
    sanctified_ground = {
        id = 289657,
        cast = 0.5,
        cooldown = 45.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 8.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 6.0, 'value': 16000, 'target': TARGET_DEST_DEST, }
    },

    -- Shackles the target undead enemy for $d, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shackle_undead = {
        id = 9484,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.012,
        spendType = 'mana',

        talent = "shackle_undead",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_STUN, 'variance': 0.25, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- A word of dark binding that inflicts $s2 Shadow damage to your target. If your target is not killed by Shadow Word: Death, you take backlash damage equal to $s6% of your maximum health.$?A364675[; Damage increased by ${$s4+$364675s2}% to targets below ${$s3+$364675s1}% health.][; Damage increased by $s4% to targets below $s3% health.]$?c3[][]$?s137033[; Generates ${$s5/100} Insanity.][]
    shadow_word_death = {
        id = 32379,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.005,
        spendType = 'mana',

        talent = "shadow_word_death",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.55, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.85, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 150.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #4: { 'type': ENERGIZE, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, 'resource': insanity, }
        -- #5: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twilight_equilibrium[390707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- discipline_priest[137032] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 60.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #19: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -42.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #22: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 400.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_5_VALUE, }
        -- shadow_priest[137033] #24: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- A word of darkness that causes $?a390707[${$s1*(1+$390707s1/100)}][$s1] Shadow damage instantly, and an additional $?a390707[${$o2*(1+$390707s1/100)}][$o2] Shadow damage over $d.$?s137033[; Generates ${$m3/100} Insanity.][]
    shadow_word_pain = {
        id = 589,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.02,
        spendType = 'mana',

        -- 0. [137032] discipline_priest
        -- spend = 0.018,
        -- spendType = 'mana',

        -- 1. [137031] holy_priest
        -- spend = 0.003,
        -- spendType = 'mana',

        -- 2. [137033] shadow_priest
        -- spend = 0.003,
        -- spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.1292, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 2.0, 'sp_bonus': 0.09588, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': ENERGIZE, 'subtype': NONE, 'points': 300.0, 'target': TARGET_UNIT_CASTER, 'resource': insanity, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_IGNORE_TARGET_RESIST, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 69.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 69.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- manipulation[459985] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- throes_of_pain[377422] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- throes_of_pain[377422] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- discipline_priest[137032] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 18.1, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 18.1, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 21.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 21.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_quietus[448278] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_quietus[448278] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Summons a shadowy fiend to attack the target for $d.$?s137033[; Generates ${$262485s1/100} Insanity each time the Shadowfiend attacks.][; Generates ${$s4/10}.1% Mana each time the Shadowfiend attacks.]
    shadowfiend = {
        id = 34433,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "shadowfiend",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'value': 19668, 'schools': ['fire', 'frost', 'arcane'], 'value1': 3255, 'target': TARGET_DEST_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 41967, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Smites an enemy for $s1 Holy damage$?s231682[ and absorbs the next $<shield> damage dealt by the enemy]?s231687[ and has a $231687s1% chance to reset the cooldown of Holy Fire][].
    smite = {
        id = 585,
        cast = 1.5,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.03,
        spendType = 'mana',

        -- 0. [137032] discipline_priest
        -- spend = 0.004,
        -- spendType = 'mana',

        -- 1. [137031] holy_priest
        -- spend = 0.002,
        -- spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.705, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 86.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- unwavering_will[373456] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- unwavering_will[373456] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- preventive_measures[440662] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preventive_measures[440662] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- words_of_the_pious[390933] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- discipline_priest[137032] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- divine_favor_chastise[372761] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twilight_equilibrium[390706] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Bolster the morale of raid members within $265144a1 yds. They each recover $s1 sec of cooldown of a major defensive ability, and regain ${$s2*($d/$t1+1)}% of their missing mana, over $d.
    symbol_of_hope = {
        id = 64901,
        cast = 4.0,
        channeled = true,
        cooldown = 180.0,
        gcd = "global",

        talent = "symbol_of_hope",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_TRIGGER_SPELL, 'tick_time': 1.0, 'trigger_spell': 265144, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
    },

    -- Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for $322431d.; Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
    thoughtsteal = {
        id = 316262,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 100.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- thoughtsteal[322431] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'target': TARGET_UNIT_CASTER, }
    },

    -- Fills you with the embrace of Shadow energy for $d, causing you to heal a nearby ally for $s1% of any single-target Shadow spell damage you deal.
    vampiric_embrace = {
        id = 15286,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "vampiric_embrace",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 0.5, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- sanlayn[199855] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- sanlayn[199855] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Swap health percentages with your ally. Increases the lower health percentage of the two to $s1% if below that amount.
    void_shift = {
        id = 108968,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "none",

        talent = "void_shift",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Summons shadowy tendrils, rooting all enemies within $108920A1 yards for $114404d or until the tendril is killed.
    void_tendrils = {
        id = 108920,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "void_tendrils",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_ROOT, 'points': 6.0, 'radius': 8.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ENEMY, }
    },

    -- Raise your dagger into the sky, channeling a torrent of void energy into the target for $o Shadow damage over $d. Insanity does not drain during this channel.; Requires Voidform.
    void_torrent = {
        id = 205065,
        color = 'artifact',
        cast = 4.0,
        channeled = true,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'sp_bonus': 0.55, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }
    },

} )