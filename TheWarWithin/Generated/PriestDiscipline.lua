-- PriestDiscipline.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 256 )

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

    -- Discipline Talents
    abyssal_reverie            = { 82583, 373054, 2 }, -- Atonement heals for $s1% more when activated by Shadow spells.
    aegis_of_wrath             = { 86730, 238135, 1 }, -- Power Word: Shield absorbs $s1% additional damage, but the absorb amount decays by $s2% every $17t2 sec.
    assured_safety             = { 94691, 440766, 1 }, -- $?a137032[Power Word: Shield casts apply $s1 $Lstack:stacks; of Prayer of Mending to your target.][Prayer of Mending casts apply a Power Word: Shield to your target at $s2% effectiveness.]
    atonement                  = { 82594, 81749 , 1 }, -- $?s214205[Power Word: Shield applies Atonement to your target for $214206d.; Your spell damage heals all targets affected by Atonement for $s1% of the damage done.][Power Word: Shield, Flash Heal, Renew, Power Word: Radiance, and Power Word: Life apply Atonement to your target for $194384d.; Your spell damage heals all targets affected by Atonement for $s1% of the damage done.] ; Healing increased by $s3% when not in a raid.
    blaze_of_light             = { 82568, 215768, 2 }, -- The damage of Smite and Penance is increased by $m1%, and Penance increases or decreases your target's movement speed by $s2% for $355851d.
    borrowed_time              = { 82600, 390691, 2 }, -- Casting Power Word: Shield increases your Haste by $s2% for $390692d.
    bright_pupil               = { 82591, 390684, 1 }, -- Reduces the cooldown of Power Word: Radiance by ${$s1/-1000} sec.
    castigation                = { 82577, 193134, 1 }, -- Penance fires one additional bolt of holy light over its duration.
    clairvoyance               = { 94687, 428940, 1 }, -- [440725] Grants Premonition of Insight, Piety, and Solace at $428940s2% effectiveness.
    collapsing_void            = { 94694, 448403, 1 }, -- Each time $?c3[you cast Devouring Plague][Penance damages or heals], Entropic Rift is empowered, increasing its damage and size by $?c1[$s4][$s3]%.; After Entropic Rift ends it collapses, dealing $448405s1 Shadow damage split amongst enemy targets within $448405a1 yds.
    contrition                 = { 82599, 197419, 2 }, -- When you heal with Penance, everyone with your Atonement is healed for $s2.
    dark_energy                = { 94693, 451018, 1 }, -- $?c3[Void Torrent can be used while moving. ][]While Entropic Void is active, you move $s1% faster. 
    dark_indulgence            = { 82596, 372972, 1 }, -- Mind Blast has a $s1% chance to grant Power of the Dark Side and its mana cost is reduced by $s2%.
    darkening_horizon          = { 94668, 449912, 1 }, -- Void Blast increases the duration of Entropic Rift by $?c1[${$s1}.1][${$s3}.1] sec, up to a maximum of $s2 sec.
    depth_of_shadows           = { 100212, 451308, 1 }, -- Shadow Word: Death has a high chance to summon a Shadowfiend for $s1 sec when damaging targets below $s2% health.
    desperate_measures         = { 94690, 458718, 1 }, -- Desperate Prayer lasts an additional ${$s1/1000} sec.; Angelic Bulwark's absorption effect is increased by $s2% of your maximum health.
    devour_matter              = { 94668, 451840, 1 }, -- Shadow Word: Death consumes absorb shields from your target, dealing $32379s1 extra damage to them and granting you $?c3[$s3 Insanity][$s2% mana] if a shield was present.
    divine_aegis               = { 82602, 47515 , 1 }, -- Critical heals create a protective shield on the target, absorbing $s1% of the amount healed. Lasts $47753d.; Critical heals with Power Word: Shield absorb $s2% additional damage.
    divine_feathers            = { 94675, 440670, 1 }, -- Your Angelic Feathers increase movement speed by an additional $s2%.; When an ally walks through your Angelic Feather, you are also granted $s1% of its effect.; 
    divine_providence          = { 94673, 440742, 1 }, -- Premonition gains an additional charge.
    divine_star                = { 82682, 110744, 1 }, -- Throw a Divine Star forward $s2 yds, healing allies in its path for $110745s1 and dealing $<holydstardamage> Holy damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond $s1 targets.
    embrace_the_shadow         = { 94696, 451569, 1 }, -- You absorb $s3% of all magic damage taken. Absorbing Shadow damage heals you for $s2% of the amount absorbed.
    enduring_luminescence      = { 82591, 390685, 1 }, -- Reduces the cast time of Power Word: Radiance by $s2% and causes it to apply Atonement at an additional $s1% of its normal duration.
    entropic_rift              = { 94684, 447444, 1 }, -- $?c3[Void Torrent][Mind Blast] tears open an Entropic Rift that follows the enemy for $450193d. Enemies caught in its path suffer $447448s1 Shadow damage every $459314t1 sec while within its reach.
    evangelism                 = { 82567, 246287, 1 }, -- Extends the duration of all of your active Atonements by $s1 sec.
    exaltation                 = { 82576, 373042, 1 }, -- Rapture enhances $s1 additional shields.
    expiation                  = { 82585, 390832, 2 }, -- Increases the damage of Mind Blast and Shadow Word: Death by $s1%.; Mind Blast and Shadow Word: Death consume $s2 sec of Shadow Word: Pain or Purge the Wicked, instantly dealing that damage.
    fatebender                 = { 94700, 440743, 1 }, -- Increases the effects of Premonition by $s1%.
    foreseen_circumstances     = { 94689, 440738, 1 }, -- $?a137032[Pain Suppression reduces damage taken by an additional $s1%.][Guardian Spirit lasts an additional ${$s2/1000} sec.]
    halo                       = { 82682, 120517, 1 }, -- Creates a ring of Holy energy around you that quickly expands to a $s2 yd radius, healing allies for $120692s1 and dealing $<holyhalodamage> Holy damage to enemies.; Healing reduced beyond $s1 targets.
    harsh_discipline           = { 82572, 373180, 2 }, -- Power Word: Radiance causes your next Penance to fire $s2 additional $Lbolt:bolts;, stacking up to $373183u times.
    heavens_wrath              = { 82574, 421558, 2 }, -- Each Penance bolt you fire reduces the cooldown of Ultimate Penitence by $s1 sec.
    improved_purify            = { 82705, 390632, 1 }, -- Purify additionally removes all Disease effects.
    indemnity                  = { 82576, 373049, 1 }, -- Atonements granted by Power Word: Shield last an additional $s1 sec.
    inescapable_torment        = { 82586, 373427, 1 }, -- $?a137032[Penance, ][]Mind Blast and Shadow Word: Death cause your Mindbender or Shadowfiend to teleport behind your target, slashing up to $s1 nearby enemies for $<value> Shadow damage and extending its duration by ${$s2/1000}.1 sec.
    inner_quietus              = { 94670, 448278, 1 }, -- $?c3[Vampiric Touch and Shadow Word: Pain deal $s1% additional damage.][Power Word: Shield absorbs $s2% additional damage.]
    lenience                   = { 82567, 238063, 1 }, -- Atonement reduces damage taken by $s1%.
    lights_promise             = { 82592, 322115, 1 }, -- Power Word: Radiance gains an additional charge.
    luminous_barrier           = { 82564, 271466, 1 }, -- Create a shield on all allies within $A1 yards, absorbing $s1 damage on each of them for $d.; Absorption decreased beyond $s2 targets.
    malicious_intent           = { 82580, 372969, 1 }, -- Increases the duration of Schism by ${$s1/1000} sec.
    mindbender                 = { 82584, 123040, 1 }, -- Summons a Mindbender to attack the target for $d. ; Generates ${$123051m1/100}.1% Mana each time the Mindbender attacks.
    miraculous_recovery        = { 94679, 440674, 1 }, -- Reduces the cooldown of Power Word: Life by ${$s1/-1000} sec and allows it to be usable on targets below $s2% health.; 
    no_escape                  = { 94693, 451204, 1 }, -- Entropic Rift slows enemies by up to $s1%, increased the closer they are to its center.
    overloaded_with_light      = { 82573, 421557, 1 }, -- Ultimate Penitence emits an explosion of light, healing up to $s2 allies around you for $421676s1 and applying Atonement at $s1% of normal duration.
    pain_and_suffering         = { 82578, 390689, 2 }, -- Increases the damage of Shadow Word: Pain and Purge the Wicked by $s1%.
    pain_suppression           = { 82587, 33206 , 1 }, -- Reduces all damage taken by a friendly target by $s1% for $d. Castable while stunned.
    pain_transformation        = { 82588, 372991, 1 }, -- Pain Suppression also heals your target for $372994s1% of their maximum health and applies Atonement.
    painful_punishment         = { 82597, 390686, 1 }, -- Each Penance bolt extends the duration of Shadow Word: Pain and Purge the Wicked on enemies hit by ${$s1/1000}.1 sec.
    perfect_vision             = { 94700, 440661, 1 }, -- Reduces the cooldown of Premonition by ${$s1/-1000} sec.; 
    power_of_the_dark_side     = { 82595, 198068, 1 }, -- Shadow Word: Pain and Purge the Wicked have a chance to empower your next Penance with Shadow, increasing its effectiveness by $198069s1%.
    power_word_barrier         = { 82564, 62618 , 1 }, -- Summons a holy barrier to protect all allies at the target location for $d, reducing all damage taken by $81782s2% and preventing damage from delaying spellcasting.
    power_word_radiance        = { 82593, 194509, 1 }, -- A burst of light heals the target and $s3 injured allies within $A2 yards for $s2, and applies Atonement for $s4% of its normal duration.
    preemptive_care            = { 94674, 440671, 1 }, -- Increases the duration of $?a137032[Atonement by ${$s1/1000} sec and the duration of ][]Renew by ${$s2/1000} sec.; 
    premonition                = { 94683, 428924, 1 }, -- [428933] Reduces the cooldown of your next $s2 spell casts by $?a440743[${$s1/-1000}.1][${$s1/-1000}] sec.
    preventive_measures        = { 94698, 440662, 1 }, -- $?a137032[Power Word: Shield absorbs $s1% additional damage.; All damage dealt by Penance, Smite and Holy Nova increased by $s3%.][Increases the healing done by Prayer of Mending by $s2%.; All damage dealt by Smite, Holy Fire and Holy Nova increased by $s4%.]; 
    prophets_will              = { 94690, 433905, 1 }, -- $?a137032[Your Flash Heal and Power Word: Shield are $s1%][Your Flash Heal, Heal, and Holy Word: Serenity are $s1%] more effective when cast on yourself.
    protector_of_the_frail     = { 82588, 373035, 1 }, -- Pain Suppression gains an additional charge.; Power Word: Shield reduces the cooldown of Pain Suppression by ${$abs($s2/1000)} sec.
    purge_the_wicked           = { 82590, 204197, 1 }, -- Cleanses the target with fire, causing $s1 Radiant damage and an additional $?a390706[${$204213o1*(1+$390706s1/100)}][$204213o1] Radiant damage over $204213d. Spreads to $?s373003[${1+$373003s2} nearby enemies][a nearby enemy] when you cast Penance on the target.
    rapture                    = { 82598, 47536 , 1 }, -- Immediately Power Word: Shield your target, and your next $s1 Power Word: Shields have no cooldown and absorb $s2% additional damage.$?a336067[; Power Word: Shield costs $s3% less mana and its Atonement lasts $336067s2 seconds longer.][]
    revel_in_purity            = { 82566, 373003, 1 }, -- Purge the Wicked deals $s1% additional damage and spreads to $s2 additional $Ltarget:targets; when casting Penance.
    sanctuary                  = { 92225, 231682, 1 }, -- Smite prevents the next $<shield> damage dealt by the enemy.
    save_the_day               = { 94675, 440669, 1 }, -- For $458650d after casting Leap of Faith you may cast it a second time for free, ignoring its cooldown.
    schism                     = { 82579, 424509, 1 }, -- Mind Blast fractures the enemy's mind, increasing your spell damage to the target by $214621s1% for $214621d.
    shadow_covenant            = { 82581, 314867, 1 }, -- Casting $?s123040[Mindbender][Shadowfiend] enters you into a shadowy pact, transforming Halo, Divine Star, and Penance into Shadow spells and increasing the damage and healing of your Shadow spells by $?s123040[$<mindbender>][$<shadowfiend>]% while active.
    shield_discipline          = { 82589, 197045, 1 }, -- When your Power Word: Shield is completely absorbed, you restore $<mana>% of your maximum mana.
    train_of_thought           = { 82601, 390693, 1 }, -- Flash Heal and Renew casts reduce the cooldown of Power Word: Shield by ${$s1/-1000}.1 sec.; Smite reduces the cooldown of Penance by ${$s2/-1000}.1 sec.
    twilight_corruption        = { 82582, 373065, 1 }, -- Shadow Covenant increases Shadow spell damage and healing by an additional $s1%.
    twilight_equilibrium       = { 82571, 390705, 1 }, -- Your damaging Shadow spells increase the damage of your next Holy spell cast within $390706d by $390706s1%.; Your damaging Holy spells increase the damage of your next Shadow spell cast within $390707d by $390707s1%.
    ultimate_penitence         = { 82575, 421453, 1 }, -- Ascend into the air and unleash a massive barrage of Penance bolts, causing $<penancedamage> Holy damage to enemies or $<penancehealing> healing to allies over $421434d.; While ascended, gain a shield for $s1% of your health. In addition, you are unaffected by knockbacks or crowd control effects.
    void_blast                 = { 94703, 450405, 1 }, -- [450215] Sends a blast of cosmic void energy at the enemy, causing $s1 Shadow damage.$?c3[; Generates ${$c/100*-1} Insanity.][]
    void_empowerment           = { 94695, 450138, 1 }, -- Summoning an Entropic Rift $?c1[extends the duration of your $s4 shortest Atonements by $s1 sec][grants you Mind Devourer].
    void_infusion              = { 94669, 450612, 1 }, -- $?c1[Atonement healing with Void Blast is 100% more effective.][Void Blast generates 100% additional Insanity.]
    void_leech                 = { 94696, 451311, 1 }, -- Every $t1 sec siphon an amount equal to $s1% of your health from an ally within $s3 yds if they are higher health than you.
    void_summoner              = { 82570, 390770, 1 }, -- Your Smite, Mind Blast, and Penance casts reduce the cooldown of $?s123040[Mindbender by ${$s2/-1000}.1][Shadowfiend by ${$s1/-1000}.1 sec.]
    voidheart                  = { 94692, 449880, 1 }, -- While Entropic Rift is active, your $?c3[Shadow damage is increased by $s1%] [Atonement healing is increased by $s2%].
    voidwraith                 = { 100212, 451234, 1 }, -- [451235] Summon a Voidwraith for $d that casts Void Flay from afar. Void Flay deals bonus damage to high health enemies, up to a maximum of $451435s2% if they are full health.$?s137033[; Generates ${$262485s1/100} Insanity each time the Voidwraith attacks.][; Generates ${$34433s4/10}.1% Mana each time the Voidwraith attacks.]
    waste_no_time              = { 94679, 440681, 1 }, -- Premonition causes your next $?a137032[Power Word: Radiance][Heal or Prayer of Healing] cast to be instant and cost $440683s2% less mana.; 
    weal_and_woe               = { 82569, 390786, 1 }, -- Your Penance bolts increase the damage of your next Smite by $390787s1%, or the absorb of your next Power Word: Shield by $390787s2%.; Stacks up to $390787U times.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_faith         = 5480, -- (408853) Leap of Faith also pulls the spirit of the $s1 furthest allies within $s2 yards and shields you and the affected allies for $<absfaith>.
    archangel              = 123 , -- (197862) Refreshes the duration of your Atonement on all allies when cast.; Increases your healing and absorption effects by $s1% for $d.
    catharsis              = 5487, -- (391297) $s2% of all damage you take is stored. The stored amount cannot exceed $s3% of your maximum health. The initial damage of your next $?s204197[Purge the Wicked][Shadow Word: Pain] deals this stored damage to your target.
    dark_archangel         = 126 , -- (197871) Increases your damage, and the damage of all allies with your Atonement by $s1% for $d.
    improved_mass_dispel   = 5635, -- (426438) Reduces the cooldown of Mass Dispel by ${$s1/-1000} sec.
    inner_light_and_shadow = 5416, -- (356085) $@spellicon355897$@spellname355897: Healing spells cost $355897s1% less mana.; $@spellicon355898$@spellname355898: Spell damage and Atonement healing increased by $355898s1%.; Activate to swap from one effect to the other, incurring a $<cooldown> sec cooldown.
    mindgames              = 5640, -- (375901) Assault an enemy's mind, dealing ${$s1*$m3/100} Shadow damage and briefly reversing their perception of reality.; For $d, the next $<damage> damage they deal will heal their target, and the next $<healing> healing they deal will damage their target.$?s137033[; Generates ${$m8/100} Insanity.][]
    phase_shift            = 5570, -- (408557) Step into the shadows when you cast Fade, avoiding all attacks and spells for $408558d.; Interrupt effects are not affected by Phase Shift.
    purification           = 100 , -- (196439) Purify now has a maximum of ${$s2+1} charges.; Removing harmful effects with Purify grants your target an absorption shield equal to $s1% of their maximum health. Lasts $196440d.
    strength_of_soul       = 111 , -- (197535) Your Power Word: Shield reduces all Physical damage taken by $197548s1% while the shield persists.
    thoughtsteal           = 855 , -- (316262) Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for $322431d.; Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
    trinity                = 109 , -- (214205) Atonement's duration is increased by $m2 sec, but can only be applied through Power Word: Shield.; Smite, Penance, and Shadowfiend critical strike chance increased by $290793m1% when you have Atonement on $m1 or more allies.
    ultimate_radiance      = 114 , -- (236499) Your Power Word: Radiance is now instant cast and the healing is increased by $m2%.
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
    -- Increases healing and absorption effects by $s1%.
    archangel = {
        id = 197862,
        duration = 15.0,
        max_stack = 1,
    },
    -- Flying.
    ascension = {
        id = 161862,
        duration = 20.0,
        max_stack = 1,
    },
    -- Healed whenever the Priest damages an enemy.
    atonement = {
        id = 214206,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- lenience[238063] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- preemptive_care[440671] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Movement speed increased by $w1%.
    blaze_of_light = {
        id = 355851,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- blaze_of_light[215768] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
    -- Haste increased by $w1%.
    borrowed_time = {
        id = 390692,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- borrowed_time[390691] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 4.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Damage increased by 15%.
    dark_archangel = {
        id = 197871,
        duration = 8.0,
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
    -- Absorbs $w1 damage.
    divine_aegis = {
        id = 47753,
        duration = 15.0,
        max_stack = 1,
    },
    -- A Naaru is at your side. Whenever you cast a spell, the Naaru will cast a similar spell.
    divine_image = {
        id = 392990,
        duration = 9.0,
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
        -- discipline_priest[137032] #14: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- holy_priest[137031] #12: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Penance bolts increased by $w2.
    harsh_discipline = {
        id = 373183,
        duration = 30.0,
        max_stack = 1,
    },
    -- Reduces mana cost of healing spells by $s1%.
    inner_light = {
        id = 355897,
        duration = 3600,
        max_stack = 1,
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
    -- Increases the threshold at which Shadow Word: Death will do extra damage by $s1%. Increases the extra damage by $s2%.
    looming_death = {
        id = 364675,
        duration = 3600,
        max_stack = 1,
    },
    -- Absorbs $w1 damage.
    luminous_barrier = {
        id = 271466,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- phantom_reach[459559] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
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
        -- discipline_priest[137032] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -38.81, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twilight_equilibrium[390707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- All damage taken reduced by $s1%.
    pain_suppression = {
        id = 33206,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- foreseen_circumstances[440738] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- protector_of_the_frail[373035] #2: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
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
    -- Haste increased by $w1%.
    power_infusion = {
        id = 10060,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your next Penance will deal $w1% additional damage or healing.
    power_of_the_dark_side = {
        id = 198069,
        duration = 30.0,
        max_stack = 1,
    },
    -- Reduces all damage taken by $s2%, and you resist all pushback while casting spells.
    power_word_barrier = {
        id = 81782,
        duration = 12.0,
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
        -- discipline_priest[137032] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- discipline_priest[137032] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- priest[137030] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- benevolence[415416] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- aegis_of_wrath[238135] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.66667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- aegis_of_wrath[238135] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.66667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- inner_quietus[448278] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- preventive_measures[440662] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- rapture[47536] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- rapture[47536] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rapture[47536] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- weal_and_woe[390787] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- shadow_priest[137033] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- shadow_priest[137033] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- shadow_priest[137033] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- inner_light[355897] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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
    -- $w1 Radiant damage every $t1 seconds.
    purge_the_wicked = {
        id = 204213,
        duration = 20.0,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- manipulation[459985] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- throes_of_pain[377422] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- throes_of_pain[377422] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- pain_and_suffering[390689] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- pain_and_suffering[390689] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- revel_in_purity[373003] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- revel_in_purity[373003] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twilight_equilibrium[390706] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Absorbs $w1 damage.
    purification = {
        id = 196440,
        duration = 8.0,
        max_stack = 1,
    },
    -- Power Word: Shield has no cooldown and absorbs $w2% additional damage.$?a336067[ Also costs $s3% less mana.][]
    rapture = {
        id = 47536,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- exaltation[373042] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- exaltation[373042] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- exaltation[373042] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': ADDITIONAL_CHARGES, }
        -- clarity_of_mind[336067] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Healing $w1 health every $t1 sec.
    renew = {
        id = 139,
        duration = 15.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- preemptive_care[440671] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- shadow_priest[137033] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_light[355897] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- The damage of your next Holy Nova is increased by $w1% and its healing is increased by $w2%.
    rhapsody = {
        id = 390636,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- discipline_priest[137032] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -37.5, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
        -- malicious_intent[372969] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
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
        -- discipline_priest[137032] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 18.1, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 18.1, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- manipulation[459985] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- throes_of_pain[377422] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- throes_of_pain[377422] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_quietus[448278] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_quietus[448278] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- pain_and_suffering[390689] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- pain_and_suffering[390689] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
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
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 69.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 69.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- 343726
    shadowfiend = {
        id = 34433,
        duration = 15.0,
        max_stack = 1,
    },
    -- Reduces Physical damage taken by $m% while Power Word: Shield holds.
    strength_of_soul = {
        id = 197548,
        duration = 15.0,
        max_stack = 1,
    },
    -- Next Flash Heal is instant$?$w5>0[, heals for $w5% more,][] and costs no mana.
    surge_of_light = {
        id = 114255,
        duration = 20.0,
        max_stack = 1,
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
    -- Critical strike chance of your Penance, Smite and Shadowfiend increased by $w1%.
    trinity = {
        id = 290793,
        duration = 3600,
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
    -- Absorbing $w3 damage.
    ultimate_penitence = {
        id = 432154,
        duration = 0.0,
        max_stack = 1,
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
    },
    -- $?a137031[Heal and Prayer of Healing][Power Word: Radiance] is instant and costs $w2% less mana.
    waste_no_time = {
        id = 440683,
        duration = 20.0,
        max_stack = 1,
    },
    -- The damage of your next Smite is increased by $w1%, or the absorb of your next Power Word: Shield is increased by $w2%.
    weal_and_woe = {
        id = 390787,
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

    -- Refreshes the duration of your Atonement on all allies when cast.; Increases your healing and absorption effects by $s1% for $d.
    archangel = {
        id = 197862,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_DONE_PERCENT, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_ABSORB_EFFECTS_DONE_PCT, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'radius': 60.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
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

    -- Increases your damage, and the damage of all allies with your Atonement by $s1% for $d.
    dark_archangel = {
        id = 197871,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'points': 15.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'radius': 60.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
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
        -- inner_light[355897] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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

    -- Extends the duration of all of your active Atonements by $s1 sec.
    evangelism = {
        id = 246287,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        talent = "evangelism",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SCRIPT_EFFECT, 'subtype': NONE, 'points': 6.0, 'radius': 60.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
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
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 63.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- improved_flash_heal[393870] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- unwavering_will[373456] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- unwavering_will[373456] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- prophets_will[433905] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- shadow_priest[137033] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 46.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- surge_of_light[114255] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- surge_of_light[114255] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- surge_of_light[114255] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- surge_of_light[114255] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- surge_of_light[114255] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_light[355897] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 28.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- inner_light[355897] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- preventive_measures[440662] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preventive_measures[440662] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- words_of_the_pious[390933] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- rhapsody[390636] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twilight_equilibrium[390706] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- inner_light[355897] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Embrace the light, reducing the mana cost of healing spells by $s1%.
    inner_light = {
        id = 355897,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 6.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #3: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS_TRIGGERED, 'points': 355898.0, 'value': 355897, 'schools': ['physical', 'nature', 'frost', 'shadow'], 'value1': 2, 'target': TARGET_UNIT_CASTER, }
    },

    -- $@spellicon355897$@spellname355897: Healing spells cost $355897s1% less mana.; $@spellicon355898$@spellname355898: Spell damage and Atonement healing increased by $355898s1%.; Activate to swap from one effect to the other, incurring a $<cooldown> sec cooldown.
    inner_light_and_shadow = {
        id = 356085,
        cast = 0.0,
        cooldown = 15.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_TARGET_ABILITY_ABSORB_SCHOOL, 'points': 355897.0, 'value': 355897, 'schools': ['physical', 'nature', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
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

    -- Create a shield on all allies within $A1 yards, absorbing $s1 damage on each of them for $d.; Absorption decreased beyond $s2 targets.
    luminous_barrier = {
        id = 271466,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        talent = "luminous_barrier",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'sp_bonus': 9.5836, 'variance': 0.05, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 40.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
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
        -- discipline_priest[137032] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- dark_indulgence[372972] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- expiation[390832] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twilight_equilibrium[390707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #8: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 600.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- shadow_priest[137033] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 49.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 37.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- trinity[290793] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Summons a Mindbender to attack the target for $d. ; Generates ${$123051m1/100}.1% Mana each time the Mindbender attacks.
    mindbender = {
        id = 123040,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "mindbender",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'value': 62982, 'schools': ['holy', 'fire'], 'value1': 4449, 'target': TARGET_DEST_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 41967, 'points': 50.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
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
        -- discipline_priest[137032] #12: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -38.81, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twilight_equilibrium[390707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },

    -- Reduces all damage taken by a friendly target by $s1% for $d. Castable while stunned.
    pain_suppression = {
        id = 33206,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "none",

        spend = 0.016,
        spendType = 'mana',

        talent = "pain_suppression",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -40.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- foreseen_circumstances[440738] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- protector_of_the_frail[373035] #2: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Launches a volley of holy light at the target, causing $<penancedamage> Holy damage to an enemy or $<penancehealing> healing to an ally over $47758d. Castable while moving.
    penance = {
        id = 47540,
        cast = 0.0,
        channeled = true,
        cooldown = 9.0,
        gcd = "global",

        spend = 0.016,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- inner_light[355897] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- trinity[290793] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
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

    -- Summons a holy barrier to protect all allies at the target location for $d, reducing all damage taken by $81782s2% and preventing damage from delaying spellcasting.
    power_word_barrier = {
        id = 62618,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        talent = "power_word_barrier",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 1489, 'schools': ['physical', 'frost', 'arcane'], 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ALLY, }
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
        -- inner_light[355897] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- A burst of light heals the target and $s3 injured allies within $A2 yards for $s2, and applies Atonement for $s4% of its normal duration.
    power_word_radiance = {
        id = 194509,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.045,
        spendType = 'mana',

        talent = "power_word_radiance",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 4.504, 'variance': 0.05, 'radius': 30.0, 'target': TARGET_DEST_TARGET_ALLY, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- enduring_luminescence[390685] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- enduring_luminescence[390685] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- lights_promise[322115] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- ultimate_radiance[236499] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ultimate_radiance[236499] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- waste_no_time[440683] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- waste_no_time[440683] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- inner_light[355897] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- discipline_priest[137032] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 33.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- discipline_priest[137032] #21: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- priest[137030] #0: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- benevolence[415416] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- aegis_of_wrath[238135] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.66667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- aegis_of_wrath[238135] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'pvp_multiplier': 0.66667, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- inner_quietus[448278] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- preventive_measures[440662] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- rapture[47536] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- rapture[47536] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- rapture[47536] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- weal_and_woe[390787] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- shadow_priest[137033] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- shadow_priest[137033] #18: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- shadow_priest[137033] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- inner_light[355897] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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
        -- inner_light[355897] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
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

    -- Cleanses the target with fire, causing $s1 Radiant damage and an additional $?a390706[${$204213o1*(1+$390706s1/100)}][$204213o1] Radiant damage over $204213d. Spreads to $?s373003[${1+$373003s2} nearby enemies][a nearby enemy] when you cast Penance on the target.
    purge_the_wicked = {
        id = 204197,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.018,
        spendType = 'mana',

        talent = "purge_the_wicked",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.234, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 204213, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- manipulation[459985] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- throes_of_pain[377422] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- throes_of_pain[377422] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- pain_and_suffering[390689] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- pain_and_suffering[390689] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- revel_in_purity[373003] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- revel_in_purity[373003] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twilight_equilibrium[390706] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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

    -- Immediately Power Word: Shield your target, and your next $s1 Power Word: Shields have no cooldown and absorb $s2% additional damage.$?a336067[; Power Word: Shield costs $s3% less mana and its Atonement lasts $336067s2 seconds longer.][]
    rapture = {
        id = 47536,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 0.031,
        spendType = 'mana',

        talent = "rapture",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 80.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_24, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #3: { 'type': APPLY_AURA, 'subtype': WATER_WALK, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_DISPEL_RESIST, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }

        -- Affected by:
        -- exaltation[373042] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- exaltation[373042] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- exaltation[373042] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': ADDITIONAL_CHARGES, }
        -- clarity_of_mind[336067] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
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
        -- discipline_priest[137032] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- light_of_tuure[208065] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'trigger_spell': 196685, 'points': 25.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- benevolence[415416] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- benevolence[415416] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- renew[139] #1: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- preemptive_care[440671] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- shadow_priest[137033] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_light[355897] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- holy_priest[137031] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #13: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #20: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -9.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #24: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #25: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #26: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 6.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #27: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- discipline_priest[137032] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- expiation[390832] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twilight_equilibrium[390707] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
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
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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
        -- discipline_priest[137032] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 18.1, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 18.1, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- manipulation[459985] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_4_VALUE, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- throes_of_pain[377422] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- throes_of_pain[377422] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_quietus[448278] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_quietus[448278] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- pain_and_suffering[390689] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- pain_and_suffering[390689] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
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
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 69.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 69.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- discipline_priest[137032] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.5, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #11: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- discipline_priest[137032] #22: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- discipline_priest[137032] #23: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- phantom_reach[459559] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- unwavering_will[373456] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- unwavering_will[373456] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- blaze_of_light[215768] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preventive_measures[440662] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preventive_measures[440662] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- words_of_the_pious[390933] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- weal_and_woe[390787] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- voidform[194249] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- voidform[194249] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- shadow_priest[137033] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shadow_priest[137033] #29: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- shadow_priest[137033] #30: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.0, 'points': -2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twist_of_fate[390978] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- twist_of_fate[390978] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- twilight_equilibrium[390706] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- schism[214621] #0: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 10.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- trinity[290793] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- holy_priest[137031] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- holy_priest[137031] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 43.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- holy_priest[137031] #17: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 86.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
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

    -- Ascend into the air and unleash a massive barrage of Penance bolts, causing $<penancedamage> Holy damage to enemies or $<penancehealing> healing to allies over $421434d.; While ascended, gain a shield for $s1% of your health. In addition, you are unaffected by knockbacks or crowd control effects.
    ultimate_penitence = {
        id = 421453,
        cast = 1.5,
        cooldown = 240.0,
        gcd = "global",

        talent = "ultimate_penitence",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 432154, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 7, }
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