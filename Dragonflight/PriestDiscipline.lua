-- PriestDiscipline.lua
-- May 2023

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 256 )

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Priest
    angelic_bulwark            = { 82675, 108945, 1 }, -- When an attack brings you below 30% health, you gain an absorption shield equal to 15% of your maximum health for 20 sec. Cannot occur more than once every 90 sec.
    angelic_feather            = { 82703, 121536, 1 }, -- Places a feather at the target location, granting the first ally to walk through it 40% increased movement speed for 5 sec. Only 3 feathers can be placed at one time.
    angels_mercy               = { 82678, 238100, 1 }, -- Reduces the cooldown of Desperate Prayer by 20 sec.
    apathy                     = { 82689, 390668, 1 }, -- Your Mind Blast critical strikes reduce your target's movement speed by 75% for 4 sec.
    benevolence                = { 82676, 415416, 1 }, -- Increases the healing of your spells by 3%.
    binding_heals              = { 82678, 368275, 1 }, -- 20% of Flash Heal healing on other targets also heals you.
    blessed_recovery           = { 82720, 390767, 1 }, -- After being struck by a melee or ranged critical hit, heal 20% of the damage taken over 6 sec.
    body_and_soul              = { 82706, 64129 , 1 }, -- Power Word: Shield and Leap of Faith increase your target's movement speed by 40% for 3 sec.
    crystalline_reflection     = { 82681, 373457, 2 }, -- Power Word: Shield instantly heals the target for 690 and reflects 10% of damage absorbed.
    death_and_madness          = { 82711, 321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below 20% health, its cooldown is reset. Cannot occur more than once every 10 sec.
    dispel_magic               = { 82715, 528   , 1 }, -- Dispels Magic on the enemy target, removing 1 beneficial Magic effect.
    dominate_mind              = { 82710, 205364, 1 }, -- Controls a mind up to 1 level above yours for 30 sec while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings or players. This spell shares diminishing returns with other disorienting effects.
    essence_devourer           = { 82674, 415479, 1 }, -- Attacks from your Shadowfiend siphon life from enemies, healing a nearby injured ally for 1,808. Attacks from your Mindbender siphon life from enemies, healing a nearby injured ally for 986.
    focused_mending            = { 82719, 372354, 1 }, -- Prayer of Mending does 45% increased healing to the initial target.
    from_darkness_comes_light  = { 82707, 390615, 1 }, -- Each time Shadow Word: Pain$?s137032[ or Purge the Wicked][] deals damage, the healing of your next Flash Heal is increased by $s1%, up to a maximum of $?a137033&$?a134735[$390617s2][${$s1*$390617u}]%.
    holy_nova                  = { 82701, 132157, 1 }, -- An explosion of holy light around you deals up to 980 Holy damage to enemies and up to 517 healing to allies within 12 yds, reduced if there are more than 5 targets.
    improved_fade              = { 82686, 390670, 2 }, -- Reduces the cooldown of Fade by 5 sec.
    improved_flash_heal        = { 82714, 393870, 1 }, -- Increases healing done by Flash Heal by 15%.
    inspiration                = { 82696, 390676, 1 }, -- Reduces your target's physical damage taken by 5% for 15 sec after a critical heal with Flash Heal or Penance.
    leap_of_faith              = { 82716, 73325 , 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    lights_inspiration         = { 82679, 373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by 8%.
    manipulation               = { 82672, 390996, 2 }, -- Your $?a137033[Mind Blast, Mind Flay, and Mind Spike]?a137031[Smite and Holy Fire][Smite, Mind Blast, and Penance] casts reduce the cooldown of Mindgames by ${$s1/2}.1 sec.
    mass_dispel                = { 82699, 32375 , 1 }, -- Dispels magic in a 15 yard radius, removing all harmful Magic from 5 friendly targets and 1 beneficial Magic effect from 5 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mental_agility             = { 82698, 341167, 1 }, -- Reduces the mana cost of $?a137033[Purify Disease][Purify] and Mass Dispel by $s1% and Dispel Magic by $s2%.;
    mind_control               = { 82710, 605   , 1 }, -- Controls a mind up to 1 level above yours for 30 sec. Does not work versus Demonic, Undead, or Mechanical beings. Shares diminishing returns with other disorienting effects.
    mindgames                  = { 82687, 375901, 1 }, -- Assault an enemy's mind, dealing 3,285 Shadow damage and briefly reversing their perception of reality. For 5 sec, the next 4,932 damage they deal will heal their target, and the next 4,932 healing they deal will damage their target.
    move_with_grace            = { 82702, 390620, 1 }, -- Reduces the cooldown of Leap of Faith by 30 sec.
    petrifying_scream          = { 82695, 55676 , 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear.
    phantasm                   = { 82556, 108942, 1 }, -- Activating Fade removes all snare effects.
    power_infusion             = { 82694, 10060 , 1 }, -- Infuses the target with power for 20 sec, increasing haste by 25%. Can only be cast on players.
    power_word_life            = { 82676, 373481, 1 }, -- A word of holy power that heals the target for 2,466. If the target is below 35% health, Power Word: Life heals for 400% more and the cooldown of Power Word: Life is reduced by 20 sec.
    protective_light           = { 82707, 193063, 1 }, -- Casting Flash Heal on yourself reduces all damage you take by 10% for 10 sec.
    psychic_voice              = { 82695, 196704, 1 }, -- Reduces the cooldown of Psychic Scream by 15 sec.
    rhapsody                   = { 82700, 390622, 1 }, -- Every 2 sec, the damage of your next Holy Nova is increased by 10% and its healing is increased by 20%. Stacks up to 20 times.
    sanguine_teachings         = { 82691, 373218, 1 }, -- Increases your Leech by 3%.
    sanlayn                    = { 82690, 199855, 1 }, --  Sanguine Teachings Sanguine Teachings grants an additional 2% Leech.  Vampiric Embrace Reduces the cooldown of Vampiric Embrace by 45 sec, increases its healing done by 25%.
    shackle_undead             = { 82693, 9484  , 1 }, -- Shackles the target undead enemy for 50 sec, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shattered_perceptions      = { 82673, 391112, 1 }, -- Mindgames lasts an additional 2 sec, deals an additional 25% initial damage, and reverses an additional 25% damage or healing.
    sheer_terror               = { 82708, 390919, 1 }, -- Increases the amount of damage required to break your Psychic Scream by 75%.
    spell_warding              = { 82720, 390667, 1 }, -- Reduces all magic damage taken by 3%.
    surge_of_light             = { 82677, 109186, 2 }, -- Your healing spells and Smite have a 4% chance to make your next Flash Heal instant and cost no mana. Stacks to 2.
    throes_of_pain             = { 82709, 377422, 2 }, -- Shadow Word: Pain and Purge the Wicked deal an additional 3% damage. When an enemy dies while afflicted by your Shadow Word: Pain or Purge the Wicked, you gain 0.5% Mana.
    tithe_evasion              = { 82688, 373223, 1 }, -- Shadow Word: Death deals 75% less damage to you.
    translucent_image          = { 82685, 373446, 1 }, -- Fade reduces damage you take by 10%.
    twins_of_the_sun_priestess = { 82683, 373466, 1 }, -- Power Infusion also grants you 100% of its effects when used on an ally.
    twist_of_fate              = { 82684, 390972, 2 }, -- After damaging or healing a target below 35% health, gain 5% increased damage and healing for 8 sec.
    unwavering_will            = { 82697, 373456, 2 }, -- While above 75% health, the cast time of your Flash Heal and Smite are reduced by 5%.
    vampiric_embrace           = { 82691, 15286 , 1 }, -- Fills you with the embrace of Shadow energy for 12 sec, causing you to heal a nearby ally for 50% of any single-target Shadow spell damage you deal.
    void_shield                = { 82692, 280749, 1 }, -- When cast on yourself, 30% of damage you deal refills your Power Word: Shield.
    void_shift                 = { 82674, 108968, 1 }, -- You and the currently targeted party or raid member swap health percentages. Increases the lower health percentage of the two to 25% if below that amount.
    void_tendrils              = { 82708, 108920, 1 }, -- Summons shadowy tendrils, rooting all enemies within 8 yards for 20 sec or until the tendril is killed.
    words_of_the_pious         = { 82721, 377438, 1 }, -- For 12 sec after casting Power Word: Shield, you deal 10% additional damage and healing with Smite and Holy Nova.

    -- Discipline
    abyssal_reverie            = { 82583, 373054, 2 }, -- Atonement heals for 10% more when activated by Shadow spells.
    aegis_of_wrath             = { 86730, 238135, 1 }, -- Power Word: Shield absorbs 30% additional damage, but the absorb amount decays by 3% every 1 sec.
    atonement                  = { 82594, 81749 , 1 }, -- $?s214205[Power Word: Shield applies Atonement to your target for $214206d.; Your spell damage heals all targets
    blaze_of_light             = { 82568, 215768, 2 }, -- The damage of Smite and Penance is increased by $m1%, and Penance increases or decreases your target's movement
    borrowed_time              = { 82600, 390691, 2 }, -- Casting Power Word: Shield increases your Haste by 4% for 4 sec.
    bright_pupil               = { 82591, 390684, 1 }, -- Reduces the cooldown of Power Word: Radiance by 5 sec.
    castigation                = { 82577, 193134, 1 }, -- Penance fires one additional bolt of holy light over its duration.
    contrition                 = { 82599, 197419, 2 }, -- When you heal with Penance, everyone with your Atonement is healed for 153.
    dark_indulgence            = { 82596, 372972, 1 }, -- Mind Blast has a $s1% chance to grant Power of the Dark Side and its mana cost is reduced by $s2%.
    divine_aegis               = { 82602, 47515 , 1 }, -- Critical heals create a protective shield on the target, absorbing $s1% of the amount healed. Lasts $47753d.; Critical heals with Power Word: Shield absorb $s2% additional damage.
    divine_star                = { 82682, 110744, 1 }, -- Throw a Divine Star forward 27 yds, healing allies in its path for 1,151 and dealing 1,340 Holy damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond 6 targets.
    enduring_luminescence      = { 82591, 390685, 1 }, -- Reduces the cast time of Power Word: Radiance by 30% and causes it to apply Atonement at an additional 10% of its normal duration.
    evangelism                 = { 82567, 246287, 1 }, -- Extends the duration of all of your active Atonements by 6 sec.
    exaltation                 = { 82576, 373042, 1 }, -- Increases the duration of Rapture by 5 sec.
    expiation                  = { 82585, 390832, 2 }, -- Increases the damage of Mind Blast and Shadow Word: Death by 10%. Mind Blast and Shadow Word: Death consume 3 sec of Shadow Word: Pain or Purge the Wicked, instantly dealing that damage.
    halo                       = { 82682, 120517, 1 }, -- Creates a ring of Holy energy around you that quickly expands to a 30 yd radius, healing allies for 2,647 and dealing 3,451 Holy damage to enemies. Healing reduced beyond 6 targets.
    harsh_discipline           = { 82572, 373180, 2 }, -- Power Word: Radiance causes your next Penance to fire $s2 additional $Lbolt:bolts;, stacking up to $373183u times.
    heavens_wrath              = { 82574, 421558, 2 }, -- Each Penance bolt you fire reduces the cooldown of Ultimate Penitence by $s1 sec.
    improved_purify            = { 82705, 390632, 1 }, -- Purify additionally removes all Disease effects.
    indemnity                  = { 82576, 373049, 1 }, -- Atonements granted by Power Word: Shield last an additional 2 sec.
    inescapable_torment        = { 82586, 373427, 1 }, -- $?a137032[Penance, ][]Mind Blast and Shadow Word: Death cause your Mindbender or Shadowfiend to teleport behind your target, slashing up to $s1 nearby enemies for $<value> Shadow damage and extending its duration by ${$s2/1000}.1 sec.
    lenience                   = { 82567, 238063, 1 }, -- Atonement reduces damage taken by 3%.
    lights_promise             = { 82592, 322115, 1 }, -- Power Word: Radiance gains an additional charge.
    luminous_barrier           = { 82564, 271466, 1 }, -- Create a shield on all allies within $A1 yards, absorbing $s1 damage on each of them for $d.; Absorption increased by $s2% when not in a raid.
    malicious_intent           = { 82580, 372969, 1 }, -- Increases the duration of Schism by 6 sec.
    mindbender                 = { 82584, 123040, 1 }, -- Summons a Mindbender to attack the target for 12 sec. Generates 0.2% Mana each time the Mindbender attacks.
    overloaded_with_light      = { 82573, 421557, 1 }, -- Ultimate Penitence emits an explosion of light, healing up to $s2 allies around you for $421676s1 and applying Atonement at $s1% of normal duration.
    pain_and_suffering         = { 82578, 390689, 2 }, -- Increases the damage of Shadow Word: Pain and Purge the Wicked by 8%.
    pain_suppression           = { 82587, 33206 , 1 }, -- Reduces all damage taken by a friendly target by 40% for 8 sec. Castable while stunned.
    pain_transformation        = { 82588, 372991, 1 }, -- Pain Suppression also heals your target for 25% of their maximum health and applies Atonement.
    painful_punishment         = { 82597, 390686, 1 }, -- Each Penance bolt extends the duration of Shadow Word: Pain and Purge the Wicked on enemies hit by 1.5 sec.
    power_of_the_dark_side     = { 82595, 198068, 1 }, -- Shadow Word: Pain and Purge the Wicked have a chance to empower your next Penance with Shadow, increasing its effectiveness by 50%.
    power_word_barrier         = { 82564, 62618 , 1 }, -- Summons a holy barrier to protect all allies at the target location for 10 sec, reducing all damage taken by 25% and preventing damage from delaying spellcasting.
    power_word_radiance        = { 82593, 194509, 1 }, -- A burst of light heals the target and 4 injured allies within 30 yards for 6,732, and applies Atonement for 70% of its normal duration.
    prayer_of_mending          = { 82718, 33076 , 1 }, -- Places a ward on an ally that heals them for 1,002 the next time they take damage, and then jumps to another ally within 30 yds. Jumps up to 4 times and lasts 30 sec after each jump.
    protector_of_the_frail     = { 82588, 373035, 1 }, -- Pain Suppression gains an additional charge. Power Word: Shield reduces the cooldown of Pain Suppression by 3 sec.
    purge_the_wicked           = { 82590, 204197, 1 }, -- Cleanses the target with fire, causing 644 Radiant damage and an additional 4,414 Radiant damage over 20 sec. Spreads to a nearby enemy when you cast Penance on the target.
    rapture                    = { 82598, 47536 , 1 }, -- Immediately Power Word: Shield your target, and for the next 8 sec, Power Word: Shield has no cooldown and absorbs an additional 40%.
    renew                      = { 82717, 139   , 1 }, -- Fill the target with faith in the light, healing for 4,706 over 15 sec.
    revel_in_purity            = { 82566, 373003, 1 }, -- Purge the Wicked deals 5% additional damage and spreads to 1 additional target when casting Penance.
    sanctuary                  = { 92225, 231682, 1 }, -- Smite prevents the next $<shield> damage dealt by the enemy.
    schism                     = { 82579, 424509, 1 }, -- Mind Blast fractures the enemy's mind, increasing your spell damage to the target by $214621s1% for $214621d.
    shadow_covenant            = { 82581, 314867, 1 }, -- $?s123040[Mindbender][Shadowfiend] enters you into a shadowy pact, transforming Halo, Divine Star, and Penance into Shadow spells and increasing the damage and healing of your Shadow spells by $?s123040[$<mindbender>][$<shadowfiend>]% while active.    shield_discipline          = { 82589, 197045, 1 }, -- When your Power Word: Shield is completely absorbed, you restore 0.5% of your maximum mana.
    train_of_thought           = { 82601, 390693, 1 }, -- Flash Heal and Renew casts reduce the cooldown of Power Word: Shield by ${$s1/-1000}.1 sec.; Smite reduces the cooldown of Penance by ${$s2/-1000}.1 sec.
    twilight_corruption        = { 82582, 373065, 1 }, -- Shadow Covenant increases Shadow spell damage and healing by an additional 10%.
    twilight_equilibrium       = { 82571, 390705, 1 }, -- Your damaging Shadow spells increase the damage of your next Holy spell cast within 6 sec by 15%. Your damaging Holy spells increase the damage of your next Shadow spell cast within 6 sec by 15%.
    ultimate_penitence         = { 82575, 421453, 1 }, -- Ascend into the air and unleash a massive barrage of Penance bolts, causing $<penancedamage> Holy damage to enemies or $<penancehealing> healing to allies over $421434d.; While ascended, gain a shield for $s1% of your health. In addition, you are unaffected by knockbacks or crowd control effects.
    void_summoner              = { 82570, 390770, 1 }, -- Your Smite, Mind Blast, and Penance casts reduce the cooldown of $?s123040[Mindbender by ${$s2/-1000}.1][Shadowfiend by ${$s1/-1000}.1 sec.]
    weal_and_woe               = { 82569, 390786, 1 }, -- Your Penance bolts increase the damage of your next Smite by $390787s1%, or the absorb of your next Power Word: Shield by $390787s2%.; Stacks up to $390787U times.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_faith         = 5480, -- (408853) Leap of Faith also pulls the spirit of the 3 furthest allies within 40 yards and shields you and the affected allies for 12,331.
    archangel              = 123 , -- (197862) Refreshes the duration of your Atonement on all allies when cast. Increases your healing and absorption effects by 20% for 15 sec.
    catharsis              = 5487, -- (391297) 15% of all damage you take is stored. The stored amount cannot exceed 12% of your maximum health. The initial damage of your next Purge the Wicked deals this stored damage to your target.
    dark_archangel         = 126 , -- (197871) Increases your damage, and the damage of all allies with your Atonement by 15% for 8 sec.
    improved_mass_dispel   = 5635, -- (426438) Reduces the cooldown of Mass Dispel by ${$s1/-1000} sec.
    inner_light_and_shadow = 5416, -- (356085) Inner Light: Healing spells cost 10% less mana. Inner Shadow: Spell damage and Atonement healing increased by 10%. Activate to swap from one effect to the other, incurring a 6 sec cooldown.
    phase_shift            = 5570, -- (408557) Step into the shadows when you cast Fade, avoiding all attacks and spells for 1 sec. Interrupt effects are not affected by Phase Shift.
    purification           = 100 , -- (196439) Purify now has a maximum of 2 charges. Removing harmful effects with Purify grants your target an absorption shield equal to 5% of their maximum health. Lasts 8 sec.
    strength_of_soul       = 111 , -- (197535) Your Power Word: Shield reduces all Physical damage taken by 15% while the shield persists.
    thoughtsteal           = 855 , -- (316262) Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for 20 sec. Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
    trinity                = 109 , -- (214205) Atonement's duration is increased by 15 sec, but can only be applied through Power Word: Shield. Smite, Penance, and Shadowfiend critical strike chance increased by 30% when you have Atonement on 3 or more allies.
    ultimate_radiance      = 114 , -- (236499) Your Power Word: Radiance is now instant cast and the healing is increased by 10%.
} )


-- Auras
spec:RegisterAuras( {
    apathy = {
        id = 390669,
        duration = 4,
        max_stack = 1
    },
    archangel = {
        id = 197862,
        duration = 15,
        max_stack = 1
    },
    atonement = {
        id = 194384,
        duration = 15,
        max_stack = 1
    },
    body_and_soul = {
        id = 65081,
        duration = 3,
        max_stack = 1
    },
    borrowed_time = {
        id = 390692,
        duration = 4,
        max_stack = 1
    },
    dark_archangel = {
        id = 197871,
        duration = 8,
        max_stack = 1
    },
    death_and_madness_debuff = {
        id = 322098,
        duration = 7,
        max_stack = 1
    },
    depth_of_the_shadows = {
        id = 390617,
        duration = 15,
        max_stack = 50
    },
    desperate_prayer = {
        id = 19236,
        duration = 10,
        tick_time = 1,
        max_stack = 1
    },
    dominate_mind = {
        id = 205364,
        duration = 30,
        max_stack = 1
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
    harsh_discipline = {
        id = 373181,
        duration = 3600,
        max_stack = function() return 8 / talent.harsh_discipline.rank end,
    },
    harsh_discipline_ready = {
        id = 373183,
        duration = 30,
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
    levitate = {
        id = 1706,
        duration = 600,
        max_stack = 1
    },
    -- Absorbs $w1 damage.
    luminous_barrier = {
        id = 271466,
        duration = 10.0,
        max_stack = 1,
        dot = "buff"
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
    mindbender = { -- TODO: Check Aura (https://wowhead.com/beta/spell=123040)
        id = 123040,
        duration = 12,
        max_stack = 1
    },
    mindgames = {
        id = 375901,
        duration = function() return talent.shattered_perceptions.enabled and 7 or 5 end,
        max_stack = 1
    },
    pain_suppression = {
        id = 33206,
        duration = 8,
        max_stack = 1
    },
    power_infusion = {
        id = 10060,
        duration = 20,
        max_stack = 1
    },
    power_of_the_dark_side = {
        id = 198069,
        duration = 20,
        max_stack = 1
    },
    power_word_barrier = { -- TODO: Check for totem to help correct for remaining time.
        id = 81782,
        duration = 12,
        max_stack = 1
    },
    power_word_fortitude = {
        id = 21562,
        duration = 3600,
        max_stack = 1,
        shared = "player" -- use anyone's buff on the player
    },
    power_word_shield = {
        id = 17,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    psychic_scream = {
        id = 8122,
        duration = 8,
        max_stack = 1
    },
    purge_the_wicked = {
        id = 204213,
        duration = 20,
        tick_time = function () return 2 * haste end,
        max_stack = 1
    },
    rapture = {
        id = 47536,
        duration = 8,
        max_stack = 1
    },
    renew = {
        id = 139,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    schism = {
        id = 214621,
        duration = function() return talent.malicious_intent.enabled and 15 or 9 end,
        max_stack = 1
    },
    shackle_undead = {
        id = 9484,
        duration = 50,
        max_stack = 1
    },
    shadow_covenant = {
        id = 322105,
        duration = 7,
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
    shield_of_absolution = {
        id = 394624,
        duration = 15,
        max_stack = 1
    },
    surge_of_light = {
        id = 114255,
        duration = 20,
        max_stack = 2
    },
    tools_of_the_cloth = {
        id = 390933,
        duration = 12,
        max_stack = 1
    },
    twilight_equilibrium_holy_amp = {
        id = 390706,
        duration = 6,
        max_stack = 1
    },
    twilight_equilibrium_shadow_amp = {
        id = 390707,
        duration = 6,
        max_stack = 1
    },
    twist_of_fate = {
        id = 390978,
        duration = 8,
        max_stack = 1
    },
    ultimate_penitence = {
        id = 421453,
        duration = 6,
        max_stack = 1
    },
    vampiric_embrace = {
        id = 15286,
        duration = 15,
        tick_time = 0.5,
        max_stack = 1
    },
    void_tendrils = {
        id = 108920,
        duration = 0.5,
        max_stack = 1
    },
    weal_and_woe = {
        id = 390787,
        duration = 20,
        max_stack = 7
    },
    words_of_the_pious = {
        id = 390933,
        duration = 12,
        max_stack = 1
    },
    wrath_unleashed = {
        id = 390782,
        duration = 15,
        max_stack = 1
    },
    light_weaving = {
        id = 394609,
        duration = 15,
        max_stack = 1
    },
} )


spec:RegisterGear( "tier29", 200327, 200329, 200324, 200326, 200328 )
spec:RegisterGear( "tier30", 202543, 202542, 202541, 202545, 202540 )
spec:RegisterAuras( {
    radiant_providence = {
        id = 410638,
        duration = 3600,
        max_stack = 2
    }
} )

spec:RegisterGear( "tier31", 207279, 207280, 207281, 207282, 207284 )


spec:RegisterStateTable( "priest", {
    self_power_infusion = true
} )

local holy_schools = {
    holy = true,
    holyfire = true
}

spec:RegisterHook( "runHandler", function( action )
    if talent.twilight_equilibrium.enabled then
        local ability = class.abilities[ action ]
        if not ability then return end
        local school = ability.school

        if school and ability.damage then
            if holy_schools[ school ] and ( buff.twilight_equilibrium_holy_amp.up or buff.twilight_equilibrium_shadow_amp.down ) then
                removeBuff( "twilight_equilibrium_holy_amp" )
                applyBuff( "twilight_equilibrium_shadow_amp" )
            elseif school == "shadow" and ( buff.twilight_equilibrium_shadow_amp.up or buff.twilight_equilibrium_holy_amp.down )  then
                removeBuff( "twilight_equilibrium_shadow_amp" )
                applyBuff( "twilight_equilibrium_holy_amp" )
            end
        end
    end
end )


-- Abilities
spec:RegisterAbilities( {
    archangel = {
        id = 197862,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "holy",

        pvptalent = "archangel",
        startsCombat = false,
        texture = 458225,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "archangel" )
        end,
    },


    dark_archangel = {
        id = 197871,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        pvptalent = "dark_archangel",
        startsCombat = false,
        texture = 1445237,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "dark_arkangel" )
        end,
    },


    divine_star = {
        id = function() return buff.shadow_covenant.up and 122121 or 110744 end,
        known = 110744,
        flash = { 122121, 110744 },
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = function() return buff.shadow_covenant.up and "shadow" or "holy" end,
        damage = 1,

        spend = 0.02,
        spendType = "mana",

        talent = "divine_star",
        startsCombat = true,
        texture = function() return buff.shadow_covenant.up and 631519 or 537026 end,

        handler = function ()
        end,

        copy = { 122121, 110744 }
    },


    evangelism = {
        id = 246287,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        school = "holy",

        talent = "evangelism",
        startsCombat = false,
        texture = 135895,

        toggle = "cooldowns",

        handler = function ()
            if buff.atonement.up then buff.atonement.expires = buff.atonement.expires + 6 end
        end,
    },


    flash_heal = {
        id = 2061,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function() return buff.surge_of_light.up and 0 or 0.04 end,
        spendType = "mana",

        startsCombat = false,
        texture = 135907,

        handler = function ()
            removeBuff( "from_darkness_comes_light" )
            removeStack( "surge_of_light" )
            if talent.protective_light.enabled then applyBuff( "protective_light" ) end
            applyBuff( "atonement" )
        end,
    },


    halo = {
        id = function() return buff.shadow_covenant.up and 120644 or 120517 end,
        known = 120517,
        flash = { 120644, 120517 },
        cast = 1.5,
        cooldown = 40,
        gcd = "spell",
        school = function() return buff.shadow_covenant.up and "shadow" or "holy" end,
        damage = 1,

        spend = 0.03,
        spendType = "mana",

        talent = "halo",
        startsCombat = false,
        texture = function() return buff.shadow_covenant.up and 632353 or 632352 end,

        handler = function ()
        end,

        copy = { 120644, 120517 }
    },

    -- Embrace the light, reducing the mana cost of healing spells by $s1%.
    inner_light_and_shadow = {
        id = 356085,
        cast = 0,
        cooldown = 6,
        gcd = "spell",

        spend = 0.010,
        spendType = "mana",

        pvptalent = "inner_light_and_shadow",
        startsCombat = false,

        handler = function()
            if buff.inner_shadow.up then
                removeBuff( "inner_shadow" )
                applyBuff( "inner_light" )
            else
                removeBuff( "inner_light" )
                applyBuff( "inner_shadow" )
            end
        end,

        copy = { "inner_light", "inner_shadow", 355897, 355898 }

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- #3: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS_TRIGGERED, 'points': 355898.0, 'value': 355897, 'schools': ['physical', 'nature', 'frost', 'shadow'], 'value1': 2, 'target': TARGET_UNIT_CASTER, }
    },

    --[[ lights_wrath = {
        id = 373178,
        cast = function() return talent.wrath_unleashed.enabled and 1.5 or 2.5 end,
        cooldown = 90,
        gcd = "spell",
        school = "holyfire",
        damage = 1,

        talent = "lights_wrath",
        startsCombat = false,
        texture = 1271590,

        toggle = "cooldowns",

        handler = function ()
        end,
    }, ]]

    -- Talent: Create a shield on all allies within $A1 yards, absorbing $s1 damage on each of them for $d.; Absorption increased by $s2% when not in a raid.
    luminous_barrier = {
        id = 271466,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "spell",

        spend = 0.040,
        spendType = 'mana',

        talent = "luminous_barrier",
        startsCombat = false,

        handler = function()
            applyBuff( "luminous_barrier" )
            active_dot.luminous_barrier = group_members
        end,
    },

    mind_blast = {
        id = 8092,
        cast = 1.5,
        cooldown = 9,
        hasteCD = true,
        gcd = "spell",
        school = "shadow",
        damage = 1,

        spend = function() return talent.dark_indulgence.enabled and 0.0015 or 0.0025 end,
        spendType = "mana",

        startsCombat = true,
        texture = 136224,

        handler = function ()
            if talent.harsh_discipline.enabled then
                if buff.harsh_discipline.up and buff.harsh_discipline.stack == buff.harsh_discipline.max_stack - 1 then
                    removeBuff( "harsh_discipline" )
                    applyBuff( "harsh_discipline_ready" )
                else
                    addStack( "harsh_discipline" )
                end
            end
            if talent.void_summoner.enabled then
                reduceCooldown( "mindbender", 2 )
            end
            if talent.manipulation.enabled then
                reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank )
            end
            if talent.inescapable_torment.enabled then
                if buff.mindbender.up then buff.mindbender.expires = buff.mindbender.expires + ( talent.inescapable_torment.rank * 0.5 )
                elseif buff.shadowfiend.up then buff.shadowfiend.expires = buff.shadowfiend.expires + ( talent.inescapable_torment.rank * 0.5 ) end
            end
            if talent.expiation.enabled then
                if talent.purge_the_wicked.enabled then
                    if debuff.purge_the_wicked.remains <= 6 then
                        removeDebuff( "purge_the_wicked" )
                    else
                        debuff.purge_the_wicked.expires = debuff.purge_the_wicked.expires - 6
                    end
                else
                    if debuff.shadow_word_pain.remains <= 6 then
                        removeDebuff( "shadow_word_pain" )
                    else
                        debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires - 6
                    end
                end
            end
        end,
    },

-- Reduces all damage taken by a friendly target by $s1% for $d. Castable while stunned.
    pain_suppression = {
        id = 33206,
        cast = 0.0,
        cooldown = 1.5,
        gcd = "off",

        spend = 0.016,
        spendType = 'mana',

        talent = "pain_suppression",
        startsCombat = false,

        handler = function()
            applyBuff( "pain_suppression" )
        end,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -40.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- protector_of_the_frail[373035] #2: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    penance = {
        id = function() return buff.shadow_covenant.up and 400169 or 47540 end,
        known = 47540,
        flash = { 400169, 47540 },
        cast = 2,
        channeled = true,
        breakable = true,
        cooldown = 9,
        gcd = "spell",
        school = function() return buff.shadow_covenant.up and "shadow" or "holy" end,
        damage = 1,

        spend = function()
            if buff.harsh_discipline_ready.up then return 0 end
            return 0.016 * ( buff.inner_light.up and 0.9 or 1 )
        end,
        spendType = "mana",

        startsCombat = true,
        texture = function() return buff.shadow_covenant.up and 1394892 or 237545 end,

        -- TODO: Could implement Heaven's Wrath if APL suggests breaking Penance channel.
        start = function ()
            removeBuff( "power_of_the_dark_side" )
            removeBuff( "harsh_discipline_ready" )
            if set_bonus.tier29_4pc > 0 then
                applyBuff( "shield_of_absolution" )
            end
            if talent.manipulation.enabled then
                reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank )
            end
            if talent.painful_punishment.enabled then
                local swp = talent.purge_the_wicked.enabled and "purge_the_wicked" or "shadow_word_pain"
                if debuff[ swp ].up then
                    debuff[ swp ].expires = debuff[ swp ].expires + 1.5 * ( 3 + ( talent.castigation.enabled and 1 or 0 ) + ( buff.harsh_discipline_ready.up and 3 or 0 ) )
                end
            end
            if talent.weal_and_woe.enabled then
                if buff.harsh_discipline_ready.up then
                    addStack( "weal_and_woe", 7 )
                else
                    addStack( "weal_and_woe", 4 )
                end
            end
            if talent.void_summoner.enabled then
                reduceCooldown( "mindbender", 2 )
            end
            if debuff.purge_the_wicked.up then active_dot.purge_the_wicked = min( active_dot.purge_the_wicked + 1, true_active_enemies ) end
        end,

        copy = { 47540, 186720, 400169, "dark_reprimand" }

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- inner_light[355897] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- trinity[290793] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
    },


    power_infusion = {
        id = 10060,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "holy",

        talent = "power_infusion",
        startsCombat = false,
        indicator = function () return group and ( talent.twins_of_the_sun_priestess.enabled or legendary.twins_of_the_sun_priestess.enabled ) and "cycle" or nil end,

        handler = function ()
            applyBuff( "power_infusion" )
            stat.haste = stat.haste + 0.25
        end,
    },

    -- Summons a holy barrier to protect all allies at the target location for $d, reducing all damage taken by $81782s2% and preventing damage from delaying spellcasting.
    power_word_barrier = {
        id = 62618,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        school = "holy",

        spend = 0.04,
        spendType = "mana",

        talent = "power_word_barrier",
        startsCombat = false,

        handler = function()
            applyBuff( "power_word_barrier" )
        end,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'value': 1489, 'schools': ['physical', 'frost', 'arcane'], 'radius': 8.0, 'target': TARGET_UNIT_DEST_AREA_ALLY, }
    },


    power_word_radiance = {
        id = 194509,
        cast = function() return buff.radiant_providence.up and 0 or ( 2 * ( talent.enduring_luminescence.enabled and 0.7 or 1 ) ) end,
        charges = function() if talent.lights_promise.enabled then return 2 end end,
        cooldown = 20,
        recharge = function() if talent.lights_promise.enabled then return 20 end end,
        gcd = "spell",
        school = "radiant",

        spend = function() return buff.radiant_providence.up and 0.03 or 0.06 end,
        spendType = "mana",

        talent = "power_word_radiance",
        startsCombat = false,
        texture = 1386546,

        handler = function ()
            if buff.atonement.down then
                applyBuff( "atonement", ( ( talent.enduring_luminescence.enabled and 0.7 or 0.6 ) * class.auras.atonement.duration ) + ( buff.radiant_providence.up and 3 or 0 ) )
                active_dot.atonement = min( active_dot.atonement + 3, group_members )
            else
                active_dot.atonement = min( active_dot.atonement + 4, group_members )
            end
        end,
    },

    --[[ power_word_solace = {
        id = 129250,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holy",
        damage = 1,

        talent = "power_word_solace",
        startsCombat = true,
        texture = 612968,

        handler = function ()
            gain( 0.01 * mana.max, "mana" )
            if talent.train_of_thought.enabled then
                reduceCooldown( "penance", 0.5 )
            end
            if talent.harsh_discipline.enabled then
                if buff.harsh_discipline.stack == buff.harsh_discipline.max_stack - 1 then
                    applyBuff( "harsh_discipline_ready" )
                    removeBuff( "harsh_discipline" )
                else
                    addStack( "harsh_discipline" )
                end
            end
            if talent.weal_and_woe.enabled then
                removeBuff( "weal_and_woe" )
            end
            if talent.void_summoner.enabled then
                reduceCooldown( "mindbender", 2 )
            end
        end,
    }, ]]


    purge_the_wicked = {
        id = 204197,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holyfire",
        damage = 1,

        spend = 0.02,
        spendType = "mana",

        talent = "purge_the_wicked",
        startsCombat = true,
        texture = 236216,
        cycle = "purge_the_wicked",

        handler = function ()
            applyDebuff( "target", "purge_the_wicked" )
        end,
    },


    rapture = {
        id = 47536,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        school = "holy",

        spend = 0.03,
        spendType = "mana",

        talent = "rapture",
        startsCombat = false,
        texture = 237548,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "rapture" )
            applyBuff( "power_word_shield" )
            applyBuff( "target", "atonement" )
        end,
    },


    renew = {
        id = 139,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.02,
        spendType = "mana",

        talent = "renew",
        startsCombat = false,
        texture = 135953,

        handler = function ()
            applyBuff( "renew" )
            applyBuff( "atonement" )
        end,
    },


    shadow_word_pain = {
        id = 589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",
        damage = 1,

        spend = 0,
        spendType = "mana",

        notalent = "purge_the_wicked",
        startsCombat = true,
        texture = 136207,
        cycle = "shadow_word_pain",

        handler = function ()
            applyDebuff( "target", "shadow_word_pain" )
        end,
    },

    smite = {
        id = 585,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",
        damage = 1,

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = 135924,

        handler = function ()
            if talent.train_of_thought.enabled then
                reduceCooldown( "penance", 0.5 )
            end
            if talent.harsh_discipline.enabled then
                if buff.harsh_discipline.up and buff.harsh_discipline.stack == buff.harsh_discipline.max_stack - 1 then
                    removeBuff( "harsh_discipline" )
                    applyBuff( "harsh_discipline_ready" )
                else
                    addStack( "harsh_discipline" )
                end
            end
            if talent.void_summoner.enabled then
                reduceCooldown( "mindbender", 2 )
            end
            if talent.weal_and_woe.enabled then
                removeBuff( "weal_and_woe" )
            end
            if talent.manipulation.enabled then
                reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank )
            end
        end,
    },

    -- Ascend into the air and unleash a massive barrage of Penance bolts, causing $<penancedamage> Holy damage to enemies or $<penancehealing> healing to allies over $421434d.; While ascended, gain a shield for $s1% of your health. In addition, you are unaffected by knockbacks or crowd control effects.
    ultimate_penitence = {
        id = 421453,
        cast = 1.5,
        cooldown = 240,
        gcd = "spell",

        talent = "ultimate_penitence",
        startsCombat = true,

        handler = function()
            applyBuff( "ultimate_penitence" )
        end,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }
        -- #1: { 'type': UNKNOWN, 'subtype': NONE, 'points': 2.0, 'value': 852, 'schools': ['fire', 'frost', 'arcane'], 'target': TARGET_UNIT_CASTER, 'target2': TARGET_DEST_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
    },
} )


spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
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

    package = "Discipline",

    strict = false
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

spec:RegisterPack( "Discipline", 20231105, [[Hekili:T3ZFZTTTs(zjtNZwkXw1s2YoTNJN5UMxVMETVM550PZC)HLOfPT4vksDKuXX34rF2pSlabXVjifLtY96BYRnveCXUl2FJLa3m(MpCZ1HbLr383NCYKthp(KPJgFXPNn913CD5JRJU561bl(ZG7j)L0GvK)5BJlweVojofF0JjzbHaikY2KVG8t3C9TBItkFx6n3AeUNCkzSRJwq(5PNFZ1lJddJOJnQyXnxdJ94XJp(KPF)25VpOCXYTZhFYOjBNhNgxghKSDEq4)9MIYvrPLfJ2(ZB)z8vo58Jp5uYR8JXFImITZxfxuefsaruAq6IOTZjdp)rHXpL8kKX)RXPz5BNVznGQfBNNhLq(lKxSmB78FkiVGm)1uS87dZ325)E1RExE2QTZVoE1pSD(GOpvgLwe)rYmVPG8pYUB78pgKhhCBsuX)kb)cEC78LbWZjy76O87YYxrX0LXLdhDZ1jXfLf4It0DbBskj)1)oUyrOicqcV5F)MRdwugNLEZ1lcssMr)pMbVh9TNrxWwKLLeM9qAXnLeMUceYwtwoIkRbvfsc)TKnK)1l2o)2n3D3OYhItIVFz5SO)hYcC8T5XBwnBzwYJZcwTE0M1BNFW25ohCXYacEWgootmmSmAwAgrEIGFN2A8ZZ5B78NEQEjyu1ukJf03GklMhVMoJFGb7TZ)B1aNipwqP14073oN(IBNhgScuvieYz9iHiXL9GmGX3bIaEnrsyARjHYGeIE2igJFr2hbTVYrmyGsiSHeT628GfvC8QrishjzP3pRGadfk5xYaC9AgdVAoOKsfyii)5Tg5Nko7ldNvusm8vmlhwjYbCtcny2gc52ga1zGBgfLsKhG3fO4G0qkQLhfes4U3bwBkuq(rGDK)RO8m2lwWgxAM(yHH(JBssugAXYS8sywkiMkkaRLeBoas9tVfmVWmco4mWWgzjyOoyEfXqlHd(PY8af4u(qMeCi)8GPvac41x0AEnkRVeyHZQ5GJqubXKbm7iAdzvWNMXg2lTmMziRUcydnVQUytEoroeW(x3AS)fCXyn8JlQdQPde0u1M6TZV6ngFELaNkUBKmbc47AnbmaKNOEf0uwzwYRrmJZlb5O0iUeOddrmFrq6mcbhLBsD(FqHwjv2hKH1L4xt0SqlsJpP1K6jIycdpjXFKKumlCtEa6YKiuHqx19ka9GWqhqFINqxMMz6r4CAYHS75K(GrRItdNDBsqbXy6NIwSHy3VmEvKNiem1M81(mm1xtyeeHH4aU)IWG8)CgbMBsUpIWxgjygFSj)OEHKmm4HS8WzHrbLl7hC1ayfWwtUm)IeBf9fJpygXtfbiHPrffkdk)(iILUOGeYRVEbrF8YTZNCcsVM8Y6f9cIq3tONI(HofaNWQHj)sEHDHXFeS0bgK6h8tcGcyOjFpEHHldsY6huJcjbCYK7K7sYYYD7qXOJGQ5E78JfCPyh)q3kF7253ViCeIU1ef453CSTda3kKqXeNRkNi05O(HuW)F8dKOzaU225eFWrfK)kjhoAwA0OGREVhIWyR2KqugsJQsmetPJasmS5YLrWZ(e46crKhicJWCVDonwv6Vg9jse8jrKCghmEkIJJNqXMXJMI4XeeXkyodjojcHy4uXii2xmwpnWEHrOE8PJo1lapaYKaJNBYo6MnpAvajDDs87MxW(HSnPLiVRcohvXg3S62OC6cbbDo(UC6mc59ZHAfIVG4aIG3bFmiobrga1BVpCUyPKeMlQbMhljshFNAIx)2B)TVVw(Bw0NwhTaRWan3R7V)r6IblOGVfCgce76CIqzA4rG0gs0byesLXlGNgUzbvwhY5G(K0WJHO1zzo8aN(KIrPA6NXMUzCqzLdnlkPGUcRz7GKRqC6SS7MvsurizxkAhzs7tL3Jy1uLKcswSjb1DxcQCR2afmcemQ0VjU(kxsfOuTj8quvjyyHKdcvCPjssz)rv1BmJlu9PWicpzfMay8DIaLo)WqEic)by1ji9rv9oyeRZZwajAvLKUq2)JqMzRcdQjwyTGHeZKvRmX1zEwcmXfEfigG)r7XuDLczZ92L5qZ9xAX3bhwuBsTk0kp5anemIe35xRgKr(tnie4qgEkJOemd4j53QiTAh53uSNsSbqNii5HGhjygjUqMD77IZbvUR)JV)Tgzp6tHj2K(O4mbp5sTkIV9ix66OfzGxwGHaM3b99hwcvgIA5KxAiA01etcy41uBem4smZhKEVK6OBMvVZsX)CacqBzbqNr2tbgXSYSzKhpdE0L(Hid9kzeC9TvXl3U1xHKAxSeONcSetnLYR0Y()wyiZe)deB8GJLkib(Fayq45aqexuDm)qfIgJeUPGY7Fc3lstmMmn6dHdyuiOeceobJBJokwXerqljspWexMb5zIZgYoqHf)g)Lym1Czy6FgJoN8EopgFdQQGrXHkYBg1FVxo04vpRnu)LvyIo14ha6zka3Ugtzk0tYL2tcxsW8T4WiMAjJZOVhr4yYeP4ZBHXrK8Bv2gTJ8nKHVYgqKKzKEXx0eHIpOTuOV558wBHbhLcPguLUkvetivo14JTefmvU9JiNIez(7ytryw6HLvZ0h(B1UxpQokL7ci5VqENFNMgvXkch7WIk3SXzPIHQd5DfvGLNpatEOO8ys6eqoaliCH84Sr8fkBf9WyqW2sHGOjDfxPeXnhL1bQdbjl0oLQMHnwu016PwsxdwODjmVKewpHPXrwPqM0ih0cK5TfPEBpo292Mm0bX(Ig34cKwB)MZAD7s4l2VsgR5mf8jsXqExCuAO1vzOss8mLmO3)J0qTzf)OQ2uvc73gX2QoY0F8vvy5XxvSyzCXQJVcEMsfgqosNYUYaQYyx863jH6VZHHHkncqXfd1qSkpnMKSOmaFvqRWnOQgw46tnU9WBU1HeWyrkVPkC9pGmCj0y2MCWaSA5UquO97AQPmUnxH1Mt5MpuJlIIBDNWUvDA73Ru7ZdQymrtEQ4HqJzuXkEZFqsG473o)TqAcyXqXmSWAPfvwc1oKe7jS53K8sZRlYsLpPG8iLKSWnxelYYPDkiBfK(RefGZmwI3NvfGZ6uWtMz3cb12yHCyJbeEajgy1GiwH9Yfyvm9q4FJVoRLosHFi4JW)fiHbRC5lIwt1MGS7pK(4pTogwb1ZUX2MujM3Bbd4GkBf0fgyD(cobwDNjeXWMujym02w6bPwr3tVZA1os79YsZzy(R1PhBsHMPOxRhJr(jOklh0JlkSvB8DpsHvvfsirz5Ic5fjivTe77C(zDQKXoPYoKrgRmxqQhmJVTCvLbaPa95Y2(TtRUL5BsVb5LTk8iV3NwfMTgTiU1S9ar0(wIZr17mSHwArvikhjgrb53reQ9ra16OjQvmTzYHPiITcCOvRp2dNqxGL3UsN1PYvAgV)AjUcJnJ2ZACft7unPCY1LsFZZTaalyQO5Tdnh6zd2859AZ0UhUuVtwWgolTdhYL8jKgCoA4MvfFtwQ7CBhnT7HO0aRWRairwaFKQeFC5w1n5XBNxToOoKB4OYnMAfHpSemVb)FYYysCzjSrf3cODr8Q1Whoq8IJGiHH6XGAx3MblNwR1FgTSd8DoN8xHFg2xWvzRWA2iUjHv7ga0onf1V(MIOWre5jMnOmcsVk()LLBBvzoGbUoROigmdXx8SvfDOHo4y9(VO)YoNmiPj6dS(XwnnAQax(H)89nAA7R0vNCXIcT28WYutOEyR0zOIFvozZyzt1ENTUuWagqRICZjD9vIh4PF(lT10oTn8Uy6DXtLTkdjA5wZBmznc6FQSnLfXHruBDYJOwEusQJN)o(1CvLapSdbLWiBW6VRnxFGRC6LCp0uneW1MDlM0EATPxIIWgtZZMjyA3l3NBoHFfdOHYDyn(cxXpym(GZ3T4H3v6SLf9WHGEZ184CtXi7zkU1XE5tQT6CgvN70EfdqQ2)nx2AFWcv9OPkYGOu3RaM(m9vIFXZngk0ZQFXZ7EWiwz7DX6RUNXnPjeRJn43JQ2Y1nPqGqN(v8sP2fZH1Qo1OJ9pp6lbpuN394OAIx4NTBnFu1BZmi34JLBKo6Emh9dD0fFqUCZ09ih8HEASaeQ5r10IIwzfaI4I2)rEySLPQ3aAnNKMiwr3KcphXiBhVb5BsLpDd0Oq1UYqmSbjp83gLggLlCCfWXylTlI4jPa42cBSdeBvDR7b2YNm(h3U83AR6xkRWCx)5WdZTQ)BngY6ny1jwgn7Hy4lrxIJu3pVWQc0XUHXrONsYtob(CHEjKZIbOi13s8wreYaH8C0FhlJL8O7YJiRk3cLdQEumKJ4i9UnjZwVjnUy5QiXfm5mECnskunIMIn5MPMMOlFMcs)PE1wDUXLh1qnwi2Gs96kKOpnGz9f6kKgA(mUcPo34kKAKyle3YEPmQnBxr6u4GTNwo2EDAPRnIsyeaioPg5ZoJt8Z9br51iE38CHA4fAwrEihIobcomOyzTiAn0WWYlMHJtTp1G6O823Fnj6(FbhfXNBogVKPEwBdEA9if(j7JPe9t)y2gG()Zioq4ifnrbsMhq5IJ2Q)DeIDHybTW8q)Awa9pAkgChXep0G6bXHqGELqe7hXMm8a65b84haGpnLeae8ABFB09XP0MyfMMGkmEXJlavk87WJeuqmWoGPbKhiJgB1OluJiYKfc)xOnvmzHFdMq1qw2zHlHcum07gzrg94Pi)A1yr2zStsD0rnf0n0w9XRuzRDkAR1JDc3LDhUs(RvJXzNPuT1bpRhOTLc1WAAHKzniHoxaHM9av6i5keZOe3wjwYxJUG5g9YEGetfUsuKLeaFJJ14em69P7GNDrSZfjD06Nm5wkgjRHtvm5v8QWgAtujne3OJONK9H8EcgInneycgdmER2XddqYoLzBicF9iWB2AQDP6MNpxsLL6NByDd00v9s9ZWljb799IjkQvF8Z1OOwD2QS00eTu)clFTfWznK4Qe9vvlakDRAWpM71rqSivNEdQItBzhFdfhbU)lOfXdo9eClN1R4Etsy(ynAqZd7a5qV1roNNWtAR(O0mKmqb1GSi)FzgeW37F326JpJhIPXcQY(v7Mc3kfiYjp1sC11zL6ytXJPlG(iGketrK3)o3QlMNikhQo7f5NZtIb2pEwjbQgBnks4gZiZYQcJyzjrm9prjwb8KOwrmEViB1Tb1NlKgmRqIbTmUCtOUdG6YjyqRucnKpV9(HkRUwKBTRHmqUCl8pMj9JknHhjAAUS60cui1wSfbMrTJvmI2LPaZ(u9qrAksK9kMjf1IccQe5IDz9(apP7jIRsdivxaBrWShCv4q3ZNcPBn8(DMLjU02qOxnLbF)Hi4dDD8hkzemQoN)Nxm0M(5edPk85eZ00pNyv)0EI0oft7BIObjrTtkrTqvEUvyKJGw7Swud)CM86ZaUYZiw7iA8ZeRS5KjB675UbrMNppK2407xFFEjx2uLa2hOqLjqTJtXNJjxX8M2HM4(dh27c07xxk1HsvJhs1dV0WHP4(hfmwvbTt0V9pEWlbH2rYNu6fWz5pTrmPhZcqQF5BsX9cWYX2gMhewc(GBZWJVTSuAz2lmgZd9S6t3IJuorSZRodwfugMuHf1L7ug9uXrlQQPmoPA2H2dugWfwsXZy9mPNtsYRekzasORpgLJPQJxqdNCoCZm8qqoSJgeEZha(B8Q14rnjUxghYUicoS6Bda8ZvKb9KwWMYSv07nHflHdTk4Mz4xWwodUhh(HSuYCHp(qZfL4qAHbS80k3QKrny8Ng2eSLpB5vaT5dEEvi)AZqwnwBfyB70axf6Jp1m4vA5efOBPHu0a(zo541IQM55IDhLLjW9s6(Bc06vkvgKTEPsBco38eWnnOayT(NrdGxybJRv4vXv9ptvnGAvimjttWR(dfvdmFNmyYiHtJbRY6)9dh48K79ybZ)4imCQ9o8FH18NvOvpaYVTcKCczYeZ8d1dHufEJTZOuv(0eBRH9Lu3P2WFdNmpQ0GJdVh1P5SX9SWTnaAmbnDDE7jX57e17yopFnvFdQ5XPbW9PH7ZSy4ENmIydODNfyX4ClTkzdmDgVMAzTU3uFNAr9TZsN2ay3zbwSG17aS318NAXvx)T49D9mR58tEMayVyA58(wB7Clrq1BlyN33YYNBteRx4VweV6STHlS7ZD3tB6clEXu3ugfOBRHv9g8ADkQ6eyTvs)CmfwCC2xmjBG)zGc6XPyFMD)fwSX0pahSV87PfBwdv4aapTAjeajwdVdLFbdyJslYQGnwAGwnSXIXP(HuTyCAFd8(neHxBX)yVqf2aEN92869P9BhaVN55wIqTFOcl2W7hGFMv1BTANwRJ)69J5ST)SHIPYBaNd7JYP2zb1X9TK)4NlHZX9D6ty92AJlbSYATwiBIDppgFlJsp8(3TDspN22P(DRQg506bJ3mXKhdnHw2DXj8VEXIr8Us7vV5Bn1hAamzJLmc1RT4JGp1T3WByuXHwvYq6qkPx7ThLT(nfrLhHFEIV5fEDb6EGJHX0Kz30U)83SDUpxBU03Q6IZ1jsthQmA7j680tIB4gq9EJGI3RVorpyG(ICcSulOMhxuV2XgU5rz8XSj3dQuXL2Bhej(RRPxgGSYP1pb2Lz5t95vzho7geEmFj)(QbnC9((YgVAFDrsgFnfRfmzg1X(0td4sZA03vVXWZQyBdrboVVpBTJ(YFfWYO9ahTR9b1iNrgWWNEYwVCBfxyJ1Wo0iJxNqi(VPYfrBbtqyidm03Fe90QFK4Na)rX3X1(XNIC7kvMoI)1t8KDhemCVUZbKW)9n8f4pkfTQ3Mz2WTC(ziUaPoWVaqHkFeAvG8aT228YjN0BiSqL(mJO1F(E91uA7uAwucrODx7RPv7Kowy(Wg)f0x)RRQ1E8QA1(sNWnzkSwH3EVvoq29TMVA3(Xv090D5QDAt7CysZruREZA5yoPlW9OXy)56kC1oPy)KqGXnIV7iExXvPfQ2jevU(O)B80gf9Jtwu)NGRv12A4tpEhI6DvKiTo0N2e2tDiF0NdzCnq9hzDf7LUAzwAeQVVBXmPeVKeIvF7WsWSb2ompQnUyx8DOheWV2vxMT0dTXl3vrwF9VZWpUPbpOIgViv7fQR5aMCEHIkjOP9C)L56X7d1Nj2Il6Ux4ldpyGPipF6jJTd)LnpDdTgIlUe49DtAVWGfYsHnpVS58xS(Ux9MXk0WUFjK23KPMa0aRKJWz1nHYoWNXD5eI8YGbJp2lOE84HdnWVLo1YBWs7qWsUpZ1LJzyMpdENXkumq6cMPpwgDLYKL7rurlagUbr9WM4pHjf1dyVXmVuVoqfXxXlcupq0)55Q901Yb7BFXv81gQtUZSU0IlY8I(WRQ8APDFAQe6UnSx8(O0eb8IgQCOIZtn04LMQzAvDrp2WZyzgmup1JE)6T0oxr7Wvwoe)MUYpFLiDXzVVskcd9R6tKi3FNkYTKARTLWYPhmDWPlTeMV6ewnUDEuh3YmWl2Cldhg7UM4mK3wbXvVrm9lDd(G0pQTXaxzj3UNU2jBy5Q6c0sMKTJYVAYNxXlr89lorRVbwbW812Bx9JDI9ierK58qhmqTwXh4QHjGi30EHxO2fedhQx47REZKt4zy74UjO5lTVDKpyD)nSHWnEap)CIrhyBFyudDDVE3iUluC72cbZcs6IC7cg10UlS74a7u7ZDmapOFM8vxZhz7YvKdxHIjx23x0GnWvRfE)QYtIb0(lrhk(Ej)TluRuaLU36ttBKjVSjBB7DzWZes3QTLTIAQ320UE971duN)BURjdr17S0)V5g5ZT11AwQPCq1D2ASAzvH9BO2ucx3F9zzYKnsQkxOLa7NZB8opKPrS5RoxbYy9xIEc(Y(2MBhyXTWsUPDZyGQHpUPqZjVSNDyTxOs3B8YoFrVT7KLZmym4xAxtNQFrjR5t1KZgefSeqFTV7McKxMyAXgqy8oW5RfRUMW7VoS72h3Lz7eZzNSLa7)RbnY9JfX9iD0sBIY3Hv9bA3cdm9InVEcPmv0iN33x9fA5xImUn6kmzwm7A6MdtXERkgloLk3Tw0zM)XqjGWk7zZbMVeWoOPn(ARsRDzE(HM8K2R(I2dR)56gZxU1(BKYQ)kyebm)x9bUQFq6c8i1hXBifGRZoLNVAWjJo9LopBNHoz5fSJqAs8EcNF0WVZMQa1pP86id1F2bdCDRED5U1Gz4)tKdjAFdWfGd9IoXIuH0ENfPnH9klsw0NUfRImhfDmB8u0daUpgwErHVFmwrynS3eknLF1Eb6pyzVbnbJ)6YPkFRXlNkrES4x9QGzdLZ0aX3qOcp2LtuwxQFhvirdF3)vy(7m05(J1ZYPk5QOAGG2(EGnIPV0JDtq200oYfCMPT48a7GINA2IU49hPeEljcu7ZoUxxC611cutf((LjMp85EjI)UJ4XNyXDCLNHo7)18uPOm2qKoh0KsPmzOUU5ZuyguiFT7VUjgA35J4QR5B8K6PNh)fJjtdNuYFP0yQ(Efn9SknVbVqmUrARMj(POY)X61PYQp0zs0fyHJLUNfU6nNAEg1uG7Xjwa2wNFJlyDcjGscihzLqGv6A)(lfyCr0KXixj(k4sOtuxfl2cxum(NDb8h4(se5zxQDYNzPwlZV)l)7gQz3ktTP8NfbmPqpCfhXEz2TWU7v62w4bn0q0nYS2nSYhbG9Xm0pQ0pdkVTqGz3MOEu(qntQUHyu)Dw8hykGS(FA4bRTBGMeOu)EVp40jzd6SnPX5PaxJI(2178Cj1Xscg563abRYp7KGTPA3V1lRNt(XYeN4XMBxmTrHARgrpGFyN2sQAlIXvic3AaiyVVvq9BW9alSJ31KMXk5B1rh5jxHF1fUZYaoW1X4I1tPfMMJ5BVsBOEjdLryQF)vwdq9lAsZGKFDvAhQp9uD5hnEJyEfFdbU56GnLlZYV56)ZG1BscsJX7MKB()(]] )
