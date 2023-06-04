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
    angels_mercy               = { 82678, 238100, 1 }, -- Damage you take reduces the cooldown of Desperate Prayer, based on the amount of damage taken.
    apathy                     = { 82689, 390668, 1 }, -- Your Mind Blast critical strikes reduce your target's movement speed by 75% for 4 sec.
    binding_heals              = { 82678, 368275, 1 }, -- 20% of Flash Heal healing on other targets also heals you.
    blessed_recovery           = { 82720, 390767, 1 }, -- After being struck by a melee or ranged critical hit, heal 20% of the damage taken over 6 sec.
    body_and_soul              = { 82706, 64129 , 1 }, -- Power Word: Shield and Leap of Faith increase your target's movement speed by 40% for 3 sec.
    crystalline_reflection     = { 82681, 373457, 2 }, -- Power Word: Shield instantly heals the target for 690 and reflects 10% of damage absorbed.
    death_and_madness          = { 82711, 321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below 20% health, its cooldown is reset. Cannot occur more than once every 20 sec.
    dispel_magic               = { 82715, 528   , 1 }, -- Dispels Magic on the enemy target, removing 1 beneficial Magic effect.
    dominate_mind              = { 82710, 205364, 1 }, -- Controls a mind up to 1 level above yours for 30 sec while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings or players. This spell shares diminishing returns with other disorienting effects.
    focused_mending            = { 82719, 372354, 1 }, -- Prayer of Mending does 45% increased healing to the initial target.
    from_darkness_comes_light  = { 82707, 390615, 1 }, -- Each time Shadow Word: Pain or Purge the Wicked deals damage, the healing of your next Flash Heal is increased by 1%, up to a maximum of 50%.
    holy_nova                  = { 82701, 132157, 1 }, -- An explosion of holy light around you deals up to 1,635 Holy damage to enemies and up to 1,968 healing to allies within 12 yds, reduced if there are more than 5 targets.
    improved_fade              = { 82686, 390670, 2 }, -- Reduces the cooldown of Fade by 5 sec.
    improved_flash_heal        = { 82714, 393870, 1 }, -- Increases healing done by Flash Heal by 15%.
    improved_mass_dispel       = { 82698, 341167, 1 }, -- Mass Dispel's cooldown is reduced to 25 sec and its cast time is reduced by 1 sec.
    inspiration                = { 82696, 390676, 1 }, -- Reduces your target's physical damage taken by 5% for 15 sec after a critical heal with Flash Heal or Penance.
    leap_of_faith              = { 82716, 73325 , 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    lights_inspiration         = { 82679, 373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by 8%.
    manipulation               = { 82672, 390996, 2 }, -- Your Smite, Power Word: Solace, Mind Blast, and Penance casts reduce the cooldown of Mindgames by 0.5 sec.
    mass_dispel                = { 82699, 32375 , 1 }, -- Dispels magic in a 15 yard radius, removing all harmful Magic from 5 friendly targets and 1 beneficial Magic effect from 5 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mind_control               = { 82710, 605   , 1 }, -- Controls a mind up to 1 level above yours for 30 sec. Does not work versus Demonic, Undead, or Mechanical beings. Shares diminishing returns with other disorienting effects.
    mindgames                  = { 82687, 375901, 1 }, -- Assault an enemy's mind, dealing 2,969 Shadow damage and briefly reversing their perception of reality. For 5 sec, the next 4,932 damage they deal will heal their target, and the next 4,932 healing they deal will damage their target.
    move_with_grace            = { 82702, 390620, 1 }, -- Reduces the cooldown of Leap of Faith by 30 sec.
    petrifying_scream          = { 82695, 55676 , 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear.
    phantasm                   = { 82556, 108942, 1 }, -- Activating Fade removes all snare effects.
    power_infusion             = { 82694, 10060 , 1 }, -- Infuses the target with power for 20 sec, increasing haste by 25%. Can only be cast on players.
    power_word_life            = { 82676, 373481, 1 }, -- A word of holy power that heals the target for 2,466. If the target is below 35% health, Power Word: Life heals for 400% more and the cooldown of Power Word: Life is reduced by 20 sec.
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
    throes_of_pain             = { 82709, 377422, 2 }, -- Shadow Word: Pain and Purge the Wicked deal an additional 3% damage. When an enemy dies while afflicted by your Shadow Word: Pain or Purge the Wicked, you gain 0.5% Mana.
    tithe_evasion              = { 82688, 373223, 1 }, -- Shadow Word: Death deals 75% less damage to you.
    translucent_image          = { 82685, 373446, 1 }, -- Fade reduces damage you take by 10%.
    twins_of_the_sun_priestess = { 82683, 373466, 1 }, -- Power Infusion also grants you 100% of its effects when used on an ally.
    twist_of_fate              = { 82684, 390972, 2 }, -- After damaging or healing a target below 35% health, gain 5% increased damage and healing for 8 sec.
    unwavering_will            = { 82697, 373456, 2 }, -- While above 75% health, the cast time of your Flash Heal and Smite are reduced by 5%.
    vampiric_embrace           = { 82691, 15286 , 1 }, -- Fills you with the embrace of Shadow energy for 15 sec, causing you to heal a nearby ally for 50% of any single-target Shadow spell damage you deal.
    void_shield                = { 82692, 280749, 1 }, -- When cast on yourself, 30% of damage you deal refills your Power Word: Shield.
    void_shift                 = { 82674, 108968, 1 }, -- You and the currently targeted party or raid member swap health percentages. Increases the lower health percentage of the two to 25% if below that amount.
    void_tendrils              = { 82708, 108920, 1 }, -- Summons shadowy tendrils, rooting up to 5 enemy targets within 8 yards for 20 sec or until the tendril is killed.
    words_of_the_pious         = { 82721, 377438, 1 }, -- For 12 sec after casting Power Word: Shield, you deal 10% additional damage and healing with Smite and Holy Nova.

    -- Discipline
    abyssal_reverie            = { 82583, 373054, 2 }, -- Atonement heals for 10% more when activated by Shadow spells.
    aegis_of_wrath             = { 86730, 238135, 1 }, -- Power Word: Shield absorbs 30% additional damage, but the absorb amount decays by 3% every 1 sec.
    atonement                  = { 82594, 81749 , 1 }, -- Power Word: Shield applies Atonement to your target for 30 sec. Your spell damage heals all targets affected by Atonement for 40% of the damage done.
    blaze_of_light             = { 82568, 215768, 2 }, -- The damage of your Smite, Power Word: Solace, and Penance is increased by 8%, and Penance increases or decreases your target's movement speed by 25% for 2 sec.
    borrowed_time              = { 82600, 390691, 2 }, -- Casting Power Word: Shield increases your Haste by 4% for 4 sec.
    bright_pupil               = { 82591, 390684, 1 }, -- Reduces the cooldown of Power Word: Radiance by 5 sec.
    castigation                = { 82577, 193134, 1 }, -- Penance fires one additional bolt of holy light over its duration.
    contrition                 = { 82599, 197419, 2 }, -- When you heal with Penance, everyone with your Atonement is healed for 153.
    dark_indulgence            = { 82596, 372972, 1 }, -- Mind Blast gains an additional charge and its Mana cost is reduced by 40%.
    divine_aegis               = { 82602, 47515 , 2 }, -- Critical heals create a protective shield on the target, absorbing 3% of the amount healed. Lasts 15 sec. Critical heals with Power Word: Shield absorb 5% additional damage.
    divine_star                = { 82682, 110744, 1 }, -- Throw a Divine Star forward 27 yds, healing allies in its path for 1,151 and dealing 1,211 Holy damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond 6 targets.
    embrace_shadow             = { 82582, 372985, 1 }, -- Shadow Covenant lasts an additional 8 sec.
    enduring_luminescence      = { 82591, 390685, 1 }, -- Reduces the cast time of Power Word: Radiance by 30% and causes it to apply Atonement at an additional 10% of its normal duration.
    evangelism                 = { 82567, 246287, 1 }, -- Extends the duration of all of your active Atonements by 6 sec.
    exaltation                 = { 82576, 373042, 1 }, -- Increases the duration of Rapture by 5 sec.
    expiation                  = { 82585, 390832, 2 }, -- Increases the damage of Mind Blast and Shadow Word: Death by 10%. Mind Blast and Shadow Word: Death consume 3 sec of Shadow Word: Pain or Purge the Wicked, instantly dealing that damage.
    halo                       = { 82682, 120517, 1 }, -- Creates a ring of Holy energy around you that quickly expands to a 30 yd radius, healing allies for 2,647 and dealing 3,119 Holy damage to enemies. Healing reduced beyond 6 targets.
    harsh_discipline           = { 82572, 373180, 2 }, -- Your next Penance fires an additional 3 bolts and costs no Mana after 10 casts of Smite, Power Word: Solace, or Mind Blast.
    improved_purify            = { 82705, 390632, 1 }, -- Purify additionally removes all Disease effects.
    indemnity                  = { 82576, 373049, 1 }, -- Atonements granted by Power Word: Shield last an additional 2 sec.
    inescapable_torment        = { 82586, 373427, 2 }, -- Mind Blast and Shadow Word: Death cause your Mindbender to teleport behind your target, slashing up to 5 nearby enemies for 1,340 Shadow damage and increasing the duration of Mindbender by 1.0 sec.
    lenience                   = { 82567, 238063, 1 }, -- Atonement reduces damage taken by 3%.
    lights_promise             = { 82592, 322115, 1 }, -- Power Word: Radiance gains an additional charge.
    lights_wrath               = { 82575, 373178, 1 }, -- Invoke the Light's wrath, dealing 4,733 Radiant damage to the target, increased by 6% per ally affected by your Atonement.
    make_amends                = { 92225, 391079, 1 }, -- When your Penance deals damage, the duration of Atonement on yourself is increased by 1 sec and when your Penance heals, the duration of Atonement on your target is increased by 1 sec.
    malicious_intent           = { 82580, 372969, 1 }, -- Increases the duration of Schism by 6 sec.
    mindbender                 = { 82584, 123040, 1 }, -- Summons a Mindbender to attack the target for 12 sec. Generates 0.2% Mana each time the Mindbender attacks.
    pain_and_suffering         = { 82578, 390689, 2 }, -- Increases the damage of Shadow Word: Pain and Purge the Wicked by 8%.
    pain_suppression           = { 82587, 33206 , 1 }, -- Reduces all damage taken by a friendly target by 40% for 8 sec. Castable while stunned.
    pain_transformation        = { 82588, 372991, 1 }, -- Pain Suppression also heals your target for 25% of their maximum health and applies Atonement.
    painful_punishment         = { 82597, 390686, 1 }, -- Each Penance bolt extends the duration of Shadow Word: Pain and Purge the Wicked on enemies hit by 1.5 sec.
    power_of_the_dark_side     = { 82595, 198068, 1 }, -- Shadow Word: Pain and Purge the Wicked have a chance to empower your next Penance with Shadow, increasing its effectiveness by 50%.
    power_word_barrier         = { 82564, 62618 , 1 }, -- Summons a holy barrier to protect all allies at the target location for 10 sec, reducing all damage taken by 25% and preventing damage from delaying spellcasting.
    power_word_radiance        = { 82593, 194509, 1 }, -- A burst of light heals the target and 4 injured allies within 30 yards for 6,732, and applies Atonement for 70% of its normal duration.
    power_word_solace          = { 82589, 129250, 1 }, -- Strikes an enemy with heavenly power, dealing 1,589 Holy damage and restoring 1% of your maximum mana.
    prayer_of_mending          = { 82718, 33076 , 1 }, -- Places a ward on an ally that heals them for 1,002 the next time they take damage, and then jumps to another ally within 20 yds. Jumps up to 4 times and lasts 30 sec after each jump.
    protector_of_the_frail     = { 82588, 373035, 1 }, -- Pain Suppression gains an additional charge. Power Word: Shield reduces the cooldown of Pain Suppression by 3 sec.
    purge_the_wicked           = { 82590, 204197, 1 }, -- Cleanses the target with fire, causing 583 Radiant damage and an additional 3,989 Radiant damage over 20 sec. Spreads to a nearby enemy when you cast Penance on the target.
    rapture                    = { 82598, 47536 , 1 }, -- Immediately Power Word: Shield your target, and for the next 8 sec, Power Word: Shield has no cooldown and absorbs an additional 40%.
    renew                      = { 82717, 139   , 1 }, -- Fill the target with faith in the light, healing for 3,765 over 15 sec.
    resplendent_light          = { 82574, 390765, 2 }, -- Light's Wrath deals an additional 2% damage per ally affected by your Atonement.
    revel_in_purity            = { 82566, 373003, 1 }, -- Purge the Wicked deals 5% additional damage and spreads to 1 additional target when casting Penance.
    schism                     = { 82579, 214621, 1 }, -- Attack the enemy's soul with a surge of Shadow energy, dealing 3,245 Shadow damage and increasing your spell damage to the target by 15% for 9 sec.
    shadow_covenant            = { 82581, 314867, 1 }, -- Make a shadowy pact, healing the target and 4 other injured allies within 30 yds for 2,712. For 7 sec, your Shadow spells deal 25% increased damage and healing, and Halo, Divine Star, and Penance are converted to Shadow spells.
    shadow_word_death          = { 82712, 32379 , 1 }, -- A word of dark binding that inflicts 1,839 Shadow damage to the target. If the target is not killed by Shadow Word: Death, the caster takes damage equal to the damage inflicted upon the target. Damage increased by 150% to targets below 20% health.
    shadowfiend                = { 82713, 34433 , 1 }, -- Summons a shadowy fiend to attack the target for 15 sec. Generates 0.5% Mana each time the Shadowfiend attacks.
    shield_discipline          = { 82589, 197045, 1 }, -- When your Power Word: Shield is completely absorbed, you restore 0.5% of your maximum mana.
    train_of_thought           = { 82601, 390693, 1 }, -- Your Flash Heal and Renew casts reduce the cooldown of Power Word: Shield by 1.0 sec. Your Smite and Power Word: Solace casts reduce the cooldown of Penance by 0.5 sec.
    twilight_corruption        = { 82582, 373065, 1 }, -- Shadow Covenant increases Shadow spell damage and healing by an additional 10%.
    twilight_equilibrium       = { 82571, 390705, 1 }, -- Your damaging Shadow spells increase the damage of your next Holy spell cast within 6 sec sec by 15%. Your damaging Holy spells increase the damage of your next Shadow spell cast within 6 sec sec by 15%.
    void_summoner              = { 82570, 390770, 1 }, -- Your Smite, Power Word: Solace, Mind Blast, and Penance casts reduce the cooldown of Mindbender by 2 sec.
    weal_and_woe               = { 82569, 390786, 1 }, -- Your Penance bolts increase the damage of your next Smite or Power Word: Solace by 12%, or the absorb of your next Power Word: Shield by 5%. Stacks up to 7 times.
    wrath_unleashed            = { 82573, 390781, 1 }, -- Reduces the cast time of Light's Wrath by 1 sec and increases its critical strike chance by 15%. Smite and Power Word: Solace deal 40% additional damage for 15 sec after casting Light's Wrath.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    archangel              = 123 , -- (197862) Refreshes the duration of your Atonement on all allies when cast. Increases your healing and absorption effects by 20% for 15 sec.
    cardinal_mending       = 5475, -- (328529) Prayer of Mending's healing is increased by 50% and its jump range is increased by 10 yds.
    catharsis              = 5487, -- (391297) 20% of all damage you take is stored. The stored amount cannot exceed 15% of your maximum health. The initial damage of your next Purge the Wicked deals this stored damage to your target.
    dark_archangel         = 126 , -- (197871) Increases your damage, and the damage of all allies with your Atonement by 15% for 8 sec.
    delivered_from_evil    = 5480, -- (196611) Leap of Faith removes all movement impairing effects, and increases your next heal on that target by 100%.
    dome_of_light          = 117 , -- (197590) Reduces the cooldown of Power Word: Barrier by 90 sec. Power Word: Barrier reduces damage taken by an additional 25%.
    eternal_rest           = 5483, -- (322107) Reduces the cooldown of Shadow Word: Death by 12 sec.
    inner_light_and_shadow = 5416, -- (356085) Inner Light: Healing spells cost 15% less mana. Inner Shadow: Spell damage and Atonement healing increased by 10%. Activate to swap from one effect to the other, incurring a 6 sec cooldown.
    precognition           = 5498, -- (377360) If an interrupt is used on you while you are not casting, gain 15% Haste and become immune to crowd control, interrupt, and cast pushback effects for 5 sec.
    purification           = 98  , -- (196162) Purify now has a maximum of 2 charges.
    purified_resolve       = 100 , -- (196439) Removing harmful effects with Purify will apply Purified Resolve to the target, granting an absorption shield equal to 5% of their maximum health. Lasts 8 sec.
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
        duration = function() return 7 + ( 8 * talent.embrace_shadow.rank ) end,
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

    lights_wrath = {
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
    },


    mind_blast = {
        id = 8092,
        cast = function() return 1.5 * haste end,
        charges = function()
            if talent.dark_indulgence.enabled then return 2 end
        end,
        cooldown = 9,
        recharge = function()
            if talent.dark_indulgence.enabled then return 9 * haste end
        end,
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

        spend = function() return buff.harsh_discipline_ready.up and 0 or 0.02 end,
        spendType = "mana",

        startsCombat = true,
        texture = function() return buff.shadow_covenant.up and 1394892 or 237545 end,

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

    power_word_solace = {
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
            if talent.manipulation.enabled then
                reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank )
            end
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
    },


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


    schism = {
        id = 214621,
        cast = function() return 1.5 * haste end,
        cooldown = 24,
        gcd = "spell",
        school = "shadow",
        damage = 1,

        spend = 1250,
        spendType = "mana",

        talent = "schism",
        startsCombat = true,
        texture = 463285,

        handler = function ()
            applyDebuff( "target", "schism" )
        end,
    },


    shadow_covenant = {
        id = 314867,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = 0.045,
        spendType = "mana",

        talent = "shadow_covenant",
        startsCombat = false,
        texture = 136221,

        handler = function ()
            applyBuff( "shadow_covenant" )
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

spec:RegisterPack( "Discipline", 20230603, [[Hekili:T3Z(VTTrA(3sqXzlLe7AlBz72l2a31S92MRB3GvDrbUFqs0I0rCRePo(Wo5GH(B)MV59BoKIsjz3cu0Kio8B(EnFphoZ0ZN(RtNehvLm9xgD2Olo7QZU40rJo)YX3mDs1N2KmDYMOf)E0hq)LSO1O))BtlxKUzvAg(rFAvEumaIY86IfOFA6K7Rtxv9tztV3oCVgn2njlq)84RMozzACCczSjLlMobg7jND1jNDX3VD(pM(XTZJ2oFDAzzs825VpjlkBrY25jzvfF60TVB77iJFm6vqJ)VKMLxSDE9gyEl3oVizf6VGEXQ8TZ)ZrfLl3oxG(QVpmFBN)3zV6df5R3oFs66Fy78bjFSkjRm9r0mxxI(F5pSD(JrfPr3VkP8FhHFrFA78LrWZry7MKIhYlwtW0LPvdpfXOkYFiDfI9eTOknpR80nfjlYxFFu1RU9B3K)usXSNYlINHEXQ0Q64ea3OJfnIfrRwnJ8pNTkTS61GO42f55RIZFkRuEOm8ImKQKzz5zjVoFZTLjvV(XOv1j3(I7RF4HtREkDv6hwwnl5)fjWsVViTE9SL5R(0SO1BoTEZrEgw5Yi0eth4239nBN)R0HTD(FsmUTZtrSsamPzFy7CYBTDEC0AK(KxKMmuv0oq055Nzq7uk1hmccuFqOhmWqrojwQdu7NZHjFcL7Si)rqnVIGBO)kA4XUXMvOxEwj6LuXNQOvOfjNs5mmyEe9NtwFFr0cgBgJetwIu9eYOwIfLWBhoA8c34bDzAmFzkSYcesjjzi0RczmcwrhLftqTIKOyKq7byHVoYFkSK()jPiN(IL0XLLBJqr2BQxTsBOLe2srsz9Qk0pMIqcqUn)p)wyLo1E0GlbBmiIAOjyE125NJ4GFSQisdovpLRah0ppymhqo51lJNrG9ScqpRijwLNFwhE10hE9I8S4u41ULRKkjvjG(sYFolzvzYTJdzEwuxuGK0wwSSee0ZeY5tXVXRgy)HRJ(ibKV06ZNHvdiGWhRZ6RPzDKQBQp2NFEaNXyqF3DRLNX4XdXk2)nIIAfrz0(ATnivDpwEweLndnziNfMR0gW8gOVydmLlqoRmGHp)mMRA(M(wXJhlYv(QvLZIRlIWENqYPG1g9dIO4ykiiV)PLlwMwU(0KpMSOgz(SkDDYRtFGBIb)umNMTSCNN4r7oiO4(60S4z3VkQSsb)33WxI)ehv87ZqJQE1hs6fMdtQqgoo6L4KOQLofq6d8lauG5pe)pMH8PGMJ4SKYs0dk(qcYiqs0ke82SO6nJ6pnzqA9b07v6cr5dO3MY40hHL7GLhNAiIH0Bt7YOv5UMp4z41RdaRzix(uGTD(jcBJKjs8qKd2VD78)RFa51eVaA(TiFRLO)kkSDsG5KG4yV3tjyF41RqHlKLWYfahfpcK4O(QwMap7JGfzmI8eI7dZnlYmYVM8ruqCRsqPjm48XyC88reS58thJXJryeRKAJhzfkgIvqhJeHAPd2RTc1tU40lccWdGak948dCHkf76dRYZlyopSA(NXZprkGaxs)H)BFyrm4Lglr)H86SkmZLJcm(C967tkiske(EYdfe0nAfeC06O0mPiXxGSNHiSOhJsxbaXnTXF1zwJo3ZsxRVPqpMt6sCps(e)13(x)EHE5SKpIsQfNSjjLIp8HpresuVrFlyagOXnfiL1S4xdAHyAnchqqv6c4PX1liRbGyEjpjl(eiArAKRp5MuyOWm6uoJdoBr5rxfIclnnBw(dZQqRsq5UWC9jhP3zeHA0Qf1RWRZwclpwxVyjrgXwlImSImRJLT6RFFkHLHmnIjq(YfSOa1)nwY121Xi6(XjOGFwJtki9bzGsMFyipLG)bGJfL9j91iWiq5IVac(MLpOuYAN2wdFgQzqMu0irApKcnKhrOEKNdzwoq)hjk2LVX6sB6djrM((UfVKwSskigvdKGzdm(z60lmS4w1DyaeWFPRUlBP3zoDigIkRx87u8JBwiaQawbeT6POpH0trXEqny(qAbSaBYV99VTxOUMdwsprcPHQPOz88W15MKawIO0fYojSi9PLqk(e7s8C8jbIHwhJJeJSWMIXi7Lrz(QutVYw8r39cFz4rdSf15Zpt)varMvLpd9ZZgD2BAE6g6m8wSi4)ioMAJ8jKrsWY8syIkjgWbvzKFmiLIEHblLHcDEEzZ5U48DV72Z1Ob5ajmieczGwqfvbH3TchSbzu0sX0HKXAImnuGg4KCMjWEeLDuiJ7nJq6ldgC(jbb1toF4ql8BgtaJJnyPDiyjpK56nNtXSqg8oJvy1G3ItDbznPd5U060L4l8KhKQfa5Ne0AFAPpHeI6bS3AwxCKd)uv8f)tHJOV1vyyjzqmKSuBibLjfvVE8zoIcd9eeD8iM(qrg(t0Piop74k2m9R)jHNIxl8B(qekEv0783jHwxUoTk54sMhJ08m5qfHyXtktGcVfHdETS6Kfr4yqxGO6I0CVXdcjvIsjWxS1w6hG3mUmIlYUqF4DmVwa9PkPvdB3f2VefPfI8jVIfc4fnuXqnNNgOXlTvRuw9qpXYZOzfm0mTJFKeaenxqwU8mb(9j0sOJOMtUJXip5osqWNCh8mTmVCZvGIaWJavI1qPwNvyLk2ELmDXzVVsncd(ljZU4JXmEFmp4N8SkJBjaXuWEdLZEUXmEAjZqyQHMUpyzHt2g5sF3z0sFJcMhH451fq1U1RnqltoVS(EkoCU)sLtrEx1jNLmIzzo8LncFqg8hAB0i59(BOOX(EWsjuOZ5S4CXLgiPQcQackyeOxsOG8le5NYmNgvKOfQlU1aEShHrNYNITO36gLF1OpVQxY47xCQwFdibWPZbcqqQbCiKOfVtbadkzhd)jwcr7szg8drpc)lqkdCZIfjBiEEG8CoM84pUjf4QDI9ifWK90uhmqVmYhjkaogTanBgEvcb2z8c8o0sX0SHdnRj(D3o6mEc4SKfSOKtv(f62yh5YQ37iFWzRpCHWS0pLsoql7ZdigDKRw0OhzljJyCDZjwiAlBMaaLaP4c4DHIBx3fSRizQYTlyutnEy3XbWddcf8hIGus5gvkwZvcJC4lOO6Lk)J24aXu63q7LXOHq59Rkpjwq7VeDOGRxH860JT7OFxOw14n92vuB94KxvfKCtPiDQP6rAHlXGcVQsheKUvDSLrnIoQQrhPvgLCSt2hdH6cVVV2mejA60VUeSdKs6q0Q0QkO6D3dusz66nWgemDXRHauG8TWQV3NdclN1flNKiLOrBZJy1FED(ACgYYfJMv5mOHQLIxVUmjgL79e6I3Cu4fRt))OTVHL4gmWn5LLPWIq)wxfSuBPOA6S1AX0yH9BP0vql9OVtFwfnvJK66fg53kAEXCL)bv8YS2NtdIS9w93nDAm28vNRavS(lrpbUsiu2qLHBbe)c6cCEDvzACczDSMJdUUGIeNh4pE7jZI8h6tDfmYDxXOtwYT1SJb6g(4McTN8YE2H1EHk93xMgsMYPNSEu45ndgl(L210P6xuYz(un5SbJcocOx47UPa5vjMw0Fc8BlLN0xvwDTH3FDy3ToBfS0ZVvvI6SqRhdbeQfM(TFMZozlbApSLvK7hlI7r6OL2ef1)hle7b0Ufgy6fBE9eszROr6rrUx4vHLiJFJUstMdZUYvwIz)sZERoglpLf1zMF3uG1qC)zSTBxK328dAQnyYFtaIpwIJ4fGDtnoTGLjZEkf(Uvoko38h5nED0zqPyFHV3vET1g0lj)UdhoSzsx8fDiBkwc35)M6hBqJqw8Dijdy(VgcC1Pyj9jdMXaTnftCAYDdo70lEPvomVXPdrYuuYX)oYjbIvxK8qrcILIqRJe8De)8H6vZ2uNLwUes(veuQ5ZoAGxr6UT13gQlt1f)ahYP(IxwKHI0(Mf5uZTVzr4wOkZy0wy7IFID8GBFIJxu6R3Jw7xlTer7ZeG1cYWbl9ni518Jq2EV99tqrS9ZqaziJ4pvGDABRp414pswLWyOBODSFPpLxdoN(9eoqGiFIkxY2v8Oa0Gc2KS1CRAJ7WFjPAzWoxOe2xgKTWbYqiSDQIsJHOnQGG1EnDYWFxSpH)YMa4tcZeabV6s3N8H0mYMdbMMiggV4tlGQqH3ZZiVp4k(atdWOrJwPWr4qvlNHPjjtg4)9mbjk9gsfwYTEIMCr8o6qIK1q4sy(7m0BB56z9uTuK0noq2uHG9HXVmGMyOUMBh5cEtWxEEGg3e4kB5ilchPKElfcu6l0UmFvKAUK7SWPxLf4vQWxpoY8X7rX4G7tiS6d7ZDR5hDi7DpLhwKdxXmVcD23R9PsBXydrCDutlkvjdD5witHDqH5RD)1TXq7oFKUvtWFgrSDCYpi9HmdBLCHDx8Nvbs8NwKG)wiOVG83ebTw9SSUXHrp)PuWjbXonYMVeHXdxuO(BrFszuQFueQpKTUgJrZiCLsCBAV72lC8oAlWBZRAvwiI5rkKhZ1MHlJ8XSuTv4lDyZI6PrlKWf6aJDu3zSUE1GPohVVQPGa5akoFcYtsqiDy(lByVY6hH9i0AKb1SWRnKBpsDYrJ5sN1P3unuvYvM6zKXpyySHNOPplskdsZGK8ZylBKY)NVDF1s5N8JcVsvSdZcuEunytsEgncxPhNyjy7C(TBsSlibu3v1Ci7z7PwK0nBWXsaWDI6ySyhCr5S92fWFKVd5cPtLHdLw7OpZAToM)Wf)7gQzF297TAVnLb5RBVm7b6PCNM5D0rRtM1UHvHOaSpMH(zj9byXBluy2TjQh1p0RBu3qmI)oh(dSL(z)pn8ut3nqJIY6Fuxs39qKVdkOxHf1z4Ik6476xKJy0954VVF2o0Q0RtYgwZ20kUav4Au1396UafPEej4qx)giAv(50hSxai7lhCs5BsGs6gtpisy8wEGR0tIKYxdzZxsAdo(GaHpN8JaqoX)qAsgTCnIwXDp63skonHCmUrpz)0xTihxHmCfaqYEFRG63G3ObXBN)(FsQIeevhtI2y)zAfRiccOxdLONjtW6yaf)eTOWXaoY3rOLZtil6kNYpLTa2yJaIYine16a1ROOmgMQucJHrayfsZ43Xkj(bjIHodPXTU0nuF(zrJwuFg1m5D8EHoDYJjfWJONDNJp7QPtEkQakuF50j)kSApD9gC5NWLO)44KhIQxvDmBtNcTuOmhkIuuDv(AYPW5ILWNRF5PBF3pJ3nmJ)EyTrgAUWp(y7INJjQmoEkt4DmCS88XHnbB1dCqnqR(qxq(Q9iw7a29awF(z2bTEogAa34C4Zf4VWbxbNLToZG(vo6auoycAB0bnyQ9uNa)AVspHJd7Yp590IJj4MpttGX(MrNbP)CNtW3zFc4UM1aS0EbXoah5q1tYlSoUk)5e5aON7sFEvUHom8Pa5amJubtokhQisWl4WGoUhpzSyOvpaYVLbsbH4WGN(X7KgVr)XU4tx4GD3BADx4yvVTpHEDAWYqCnnx6Gn1zLBxaS0ww5MR5nhtBNOEhZ5zYRbq(V7eGoST2lgUV0LzVDXiIlG2DwGdBNT0QKlW0z8ASdzDVT8DSJLVDw70fa7ml4khwW6Da27R8VA0Ew4DLJG36oR5Ydea7ftlx13R2U2vap9La76(wx(AxQy9b)9AhQxD22W1oSMP3(in4A0DPptG3HtN9n4n2xM6tGXa(Cofowt2xmjxG)aqb93uCJd7m9sPiUXT7TEa4oS30pa3H9gTneQgW1EQtG7Wtu)G57ZkI5b49B8k3SpRqMlG3zxF34VIq7i26g49mp3FzN2rQWHPSEb4F3(XoZ23zPk18o0CCRQtDFRYDEFh(25UnN2VQzUkZBhWCRcOs(2)6pKqFbiH(jSWbaZvBNtA7eCEJuwbC(PtW)n81hhP7pO)6VGVo5OGA6)j7(oB6e9BWmYBpd(0XqpK1jRPvt)LrAqiFZ0jLjvcqXkqk83wvJ(Jxq2FYnE9BTD(rBN7DWuZkKHJNjkgwrUUUa87IwJFboFBN)8ZIpZz2neg5IXRiDdb4HCnMrGk7ImtJmipeiKl7rcrHl3tKb5Bt3krapciHXTMe87)aRHWwzyTVAA0raxDBYOo3beG8xTpq(x0o8pKB9nzcqyGgOGRBnfCM28)h32BeajZJnpWCbE9n251PpyNB7bytqSFK)K0iXBCQKCDI4ekA6KXCj3Las8DTwGBDJSsUN2WmRbuZXUVW32o)LogJ8L(225o4H0dwya7p)SwJ(ILtU6eoXC3ajlEgZ9253DR1NlIWrf5TsNykq39AZuWaqP352AbBZqGz2)GMMpKqKo2bmAlPd(EUtMKv)OWXKA7Jd4mvlvy80s3tXq3Mx8O4ypqN8aBhrZYROyMOv2IdTaVS5u2pEnsJ)tnV0I50Mx0G4fITJNg)i4P2MpWDBQnefoQsDlqsBU5ccjPW1XjHIn1gZxO1yRnhfhySvomkNn1GoiTnR)25Vb2XiTGET5tki6vQpd(PtJgseo2nYMlNGWoxhPU20Wn70DlWqBUuccdnoIDTGAYD5Uf4KnB)47Ro)o68UXAWxUEp28MRb7U7B3oNUfB0SU(h3vH94DvOSgH09RhwfO9PzRNBXE6siugPnoXXWOE79HZvlL5cnopoY(fsjWyHORn6LEE5FUUvdLP2eNh3lozH00voJZrhH5qTpfBdLO)f4spSzdZyMzRcdQb4jPGkYoHDzgYtPs)r0nQoogbFFWp48PuRZbgagr8yjwEGsBviuDGsf3oICsvMA1ohKuDC5EXb2XvR5mVxKUG0cNwfuvh4aIqQSjUfpLI2s2HAnbYpm80L(oI)dkXBRIARdKVzKZw16ngv3xa04LlPXAd)zdaCPwf5y4Cj)SGENrH)VJWa0v2iKz06hEiEeHGiddkPiDZw93TKzhKV2IcVhKVMzWZpx6H6KDUgpi4RPsBRV1NGxY6JLZciaeERkou4eoXmVtSBMCyOyobwLjSX)gCi9CnzY)Do21rWZ5j43GSGWkJs5GUpq3n8Qh2gQ)nmmXKAcda9mf4uLC3V1r9O1AOx2QelcxV06HTQn7SwUwldHbQX9KpmS1PENv9ai)wvNYoq(0lgtt6w(6XSdemCVEQtOMfpbOqh5RypJopF2l6C8)L5(6uvYt)A3dpRrx1qYAK4UYzdzW4oUThZRgtSG2rNtdOBE87vszvIx0ytCCrXortSbu7T1s02Qt832RHyA1rNl9KeUZgwXLdVsDI5mf8tuJWr0MCfQtAC26OJY6NE)kivwMACs(JzADkbmtqzRxVgftcRVQx4J93fjaxmZQWkIEV0ARzRV3JsIECInCTbiZNSwoTl3TERQFBI22S25d1Iq8rL(KYAWhGZTVjPUNh8Ac9UjUNVptn0Ez3cEyQRtXHRcMVAwayD3yDyxa0P4RCYUhqtP2El0KZgU03gCuo)bVatANpPVNgLYY3sk(qQwJ0L(0PyVDZVQ7a2DXOUSv9iVrXsOmGD9kD1gb6iVMl7uLLBpfQubgx7kaR1FrkBo1YV0gQStvv2dv6Q3V(1ZBATINK12UxV)z1zL(sf8YwfE0U006DLz6X9242VD0c40axTu5QE7f6rQruG(Dmc1(iGAz0e7XR1wdwTyPOGJ3PkAAfAFTexXyR9r)GgxX4ov2QM46U35qMLQlGlCxD7enxE8XDpCjVK1oTRPSuMYTT9oaRdSIUhIsZSIwhTNnUahi60FWx)V280BpGTXEkUZIM7cIzBaSVhn(NMlbyDVrcwItJu2kCN1MliDf)Ei6fIQ7qBEGAFXW6GlwQM(b)6e26QB88lyaTkYnFa7RfpWx95V0wx1Po13at3FZYh4lBCf73nL9VEkzFrFVj3EFNxTBXK2wzt73dchSOiUQ7L7ZhNiOGe257CzBHh4OqaxTBXd3o68ZBnpUQ9FGMw2eyHKARoNXmKcYEadqQ2VRqBPpy9oCRid1VUsXOu3RaMb4(QXVO1qHoS(f7EWi(y7nTnYcYI0(5EQU9wLVUt7fYDGh9fShQR7ECu(5fbPr0WDGDlmlFD3J5ia64W7M56Uh5qa0JrbiCNXvysf7Ln462FEmyDJzjAaTHtstIv1nP0ZXyKU37fo3jZ6FsXdWr4ZNDxFyX6F60IpdDPT(hvm46SDdpsFxcZCllIgj(IWHQSvb57TyzOoKTlbzskTBiBLd7eG6WByfmlwpweloV1yk8Fx7BMoSjx98BqpSdlZo)iRy3NCLt)IR1D)BSUZROrSBTbfz6njgoQg0tod(k0EPdTcLnQ1qjTv6fwgxjr6EltEuuKlY1P0NE(V(gjbQnQ8ABFM0LpoKH21w1NBS4rp0OfYB2SEvczSc7ltjKxdb7zjK(CdsOB0dmZMeYypWX8GXHm5dJcGNEWnlK3khncsTJ9hABf9STlODSWgjIJ(cJt6bQSZ4e)qCrw)pHVHQUrpsc2yKVSO03DG)XL0(wRxs7wSP74u2eZ61J)Pf6Zwe026IG0VbtO7WB6OYLuzIgg8gCsf94vP4g3rg0rStz5ONQfzA4M9PoXSDpgB7oGnJGp7yIf5UJcPJuQHCiWQn7su4ouLgXobiHDvcgAU9S2rYv(6mtMBRfo)3HDyWn6PFrMjJtWO3NUdo0QyF3izshBNuLCRKJl3ZXyOrOsQUcc5c3xx9HfttBczQHGAbs2TNZqsmtpu)MTMQ74SnZNpTYkZdQWUbAIuVY8qdurXUF4)(cTUAQ05DPhvnCHrW3WE6vxE3VabTBctmJk(dEHJpkM6n(1Z6muTXcSOHPQZWUn70yw7W9oyRSZRNtHZHDKAYc2QFINZAnX6B9ffcUrLjxW(TtOmbA)od02Yf2eXVYbToxMxCHnpBekVHBPqYEIHwIb(fwiEzLO(cwwwPGJ2Vn5nCIWnzZ0Z1YAs1JPBlGduRgg)dtZAbWyps2eCf7y8ukLy8M1q5E6MWAUWmKd3gqpayMs0jAiOweknfq(UHNK(v5RKck1tWvKk7bxcghfSYgrBUpjodJFNzzYI2gcXQPG47peb)qFhiOYUqKZT)WIHUwFoYC9ztzeSxXmJ1NJCU(04aunq90(MkAqv04us1iMKd9kg1qLnoAtnWpVzPEaWvEQVgNtQFMyLnN1yJFs((vzoCUiDXP3Vo)csVSPsoTpqbMnqJtz1dXKRBF7a7IyFQqVF9PiILsGhkLiVYYzF6(hfSw(aJt409pEWR1GXjzQsAi)J6s6URMCmwazFwuNHBpGJtuqCYu4QYhDFo(KfmpJu59sRb9qohnnT4OM6c5iR0IvbTHnwjjid9oTrFL8OLxQPnURLhh2EG2aUrEanv4sYzxNQKqzevkTbVPufPhaQ65kc7UE4mvt04eCTfqEetlsWh(IAsoyi0pgIe6owJS)bLePWs(9wsO9s(IbaKwMt3)uMawi5kPVyvvo62tuVKxraaz3J9VjxuTpm99ue19FWV7n36ggQTzo)8Xnyr98RcYE)5xhMfC)XnT34fkg6vBqVQhHw14ls4c(9FSPizr(67Jex5vwG(dihhPv1XgVouOX6QLWPz()D0M6vrzP4FD6))p]] )
