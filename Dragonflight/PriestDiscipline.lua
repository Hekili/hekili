-- PriestDiscipline.lua
-- September 2022

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 256 )

spec:RegisterResource( Enum.PowerType.Insanity )
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
    death_and_madness = {
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
        max_stack = 10
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
        duration = 5,
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
        max_stack = 1
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
        tick_time = 2,
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
        duration = 9,
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
    wrath_unleashed = {
        id = 390782,
        duration = 15,
        max_stack = 1
    },
} )


spec:RegisterGear( "tier30", 202543, 202542, 202541, 202545, 202540 )
spec:RegisterAuras( {
    radiant_providence = {
        id = 410638,
        duration = 3600,
        max_stack = 2
    }
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

    -- Throw a Divine Star forward 27 yds, healing allies in its path for 1,151 and dealing 1,211 Holy damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond 6 targets.
    divine_star = {
        id = 110744,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holy",
        damage = 1,

        spend = 0.02,
        spendType = "mana",

        talent = "divine_star",
        startsCombat = true,
        texture = 537026,

        handler = function ()
        end,
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
        end,
    },

    -- Creates a ring of Holy energy around you that quickly expands to a 30 yd radius, healing allies for 2,647 and dealing 3,119 Holy damage to enemies. Healing reduced beyond 6 targets.
    halo = {
        id = function() return buff.shadow_covenant.up and 120644 or 120517 end,
        known = 120517,
        cast = 1.5,
        cooldown = 40,
        gcd = "spell",
        school = function() return buff.shadow_covenant.up and "shadow" or "holy" end,

        spend = 0.03,
        spendType = "mana",

        talent = "halo",
        startsCombat = false,
        texture = function() return buff.shadow_covenant.up and 632353 or 632352 end,

        handler = function ()
        end,

        copy = 120644
    },


    lights_wrath = {
        id = 373178,
        cast = 2.5,
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
        cast = 1.5,
        charges = function()
            if talent.dark_indulgence.enabled then return 2 end
        end,
        cooldown = 9,
        recharge = function()
            if talent.dark_indulgence.enabled then return 9 end
        end,
        gcd = "spell",
        school = "shadow",
        damage = 1,

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = 136224,

        handler = function ()
            if talent.harsh_discipline.enabled then
                if buff.harsh_discipline.up and buff.harsh_discipline.stack == 9 then
                    removeBuff( "harsh_discipline" )
                    applyBuff( "harsh_discipline_ready" )
                else
                    addStack( "harsh_discipline" )
                end
            end

            if talent.inescapable_torment.enabled and pet.fiend.active then pet.fiend.expires = pet.fiend.expires + 1 end

            if talent.void_summoner.enabled then reduceCooldown( "mindbender", 2 ) end
        end,
    },


    pain_suppression = {
        id = 33206,
        cast = 0,
        cooldown = 180,
        gcd = "off",
        school = "holy",

        spend = 0.02,
        spendType = "mana",

        talent = "pain_suppression",
        startsCombat = false,
        texture = 135936,

        toggle = "defensives",

        handler = function ()
            applyBuff( "pain_suppression" )
        end,
    },


    penance = {
        id = function() return buff.shadow_covenant.up and 400169 or 47540 end,
        known = 47540,
        cast = 2,
        channeled = true,
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
            if debuff.purge_the_wicked.up then active_dot.purge_the_wicked = min( active_dot.purge_the_wicked + 1, true_active_enemies ) end

            if talent.void_summoner.enabled then reduceCooldown( "mindbender", 2 ) end
        end,

        copy = { 186720, 400169, "dark_reprimand" }
    },


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
        texture = 253400,

        toggle = "cooldowns",

        handler = function ()
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

    -- Strikes an enemy with heavenly power, dealing 1,692 Holy damage and restoring 1% of your maximum mana.
    power_word_solace = {
        id = 129250,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holy",
        damage = 1,

        talent = "power_word_solace",
        startsCombat = false,
        texture = 612968,

        handler = function ()
            gain( 0.01 * mana.max, "mana" )

            if talent.harsh_discipline.enabled then
                if buff.harsh_discipline.up and buff.harsh_discipline.stack == 9 then
                    removeBuff( "harsh_discipline" )
                    applyBuff( "harsh_discipline_ready" )
                else
                    addStack( "harsh_discipline" )
                end
            end

            if talent.void_summoner.enabled then reduceCooldown( "mindbender", 2 ) end
        end,
    },

    -- Cleanses the target with fire, causing 583 Radiant damage and an additional 3,989 Radiant damage over 20 sec. Spreads to a nearby enemy when you cast Penance on the target.
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

    -- Immediately Power Word: Shield your target, and for the next 8 sec, Power Word: Shield has no cooldown and absorbs an additional 40%.
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

        toggle = "interrupts",

        handler = function ()
            applyBuff( "rapture" )
            applyBuff( "power_word_shield" )
            applyDebuff( "player", "weakened_soul" )
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
        end,
    },

    -- Attack the enemy's soul with a surge of Shadow energy, dealing 3,245 Shadow damage and increasing your spell damage to the target by 15% for 9 sec.
    schism = {
        id = 214621,
        cast = 1.5,
        cooldown = 24,
        gcd = "spell",
        school = "shadow",
        damage = 1,

        spend = 1250,
        spendType = "mana",

        talent = "schism",
        startsCombat = false,
        texture = 463285,

        handler = function ()
            applyDebuff( "target", "schism" )
        end,
    },

    -- Make a shadowy pact, healing the target and 4 other injured allies within 30 yds for 2,712. For 7 sec, your Shadow spells deal 25% increased damage and healing, and Halo, Divine Star, and Penance are converted to Shadow spells.
    shadow_covenant = {
        id = 314867,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = 0.04,
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

    -- Smites an enemy for 1,315 Holy damage.
    smite = {
        id = 585,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",
        damage = 1,

        spend = 0.004,
        spendType = "mana",

        startsCombat = true,
        texture = 135924,

        handler = function ()
            if talent.harsh_discipline.enabled then
                if buff.harsh_discipline.up and buff.harsh_discipline.stack == 9 then
                    removeBuff( "harsh_discipline" )
                    applyBuff( "harsh_discipline_ready" )
                else
                    addStack( "harsh_discipline" )
                end
            end

            if talent.void_summoner.enabled then reduceCooldown( "mindbender", 2 ) end
        end,
    },

    -- Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for 20 sec. Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
    thoughtsteal = {
        id = 316262,
        cast = 0,
        cooldown = 90,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "thoughtsteal",
        startsCombat = false,
        texture = 3718862,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    -- Fills you with the embrace of Shadow energy for 15 sec, causing you to heal a nearby ally for 50% of any single-target Shadow spell damage you deal.
    vampiric_embrace = {
        id = 15286,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "shadow",

        talent = "vampiric_embrace",
        startsCombat = false,
        texture = 136230,

        toggle = "defensives",

        handler = function ()
            applyBuff( "vampiric_embrace" )
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



spec:RegisterPack( "Discipline", 20230504, [[Hekili:T31)ZTTTs()wY05SLsIDLLTSt6f7zUR5171E96RZ5(MoZ9dsIwK2IxLi1rsfNCJh93(HDbi(oabPOCsUxNPttIi4IDxSy3p7cqGPNn93MEBCuvY0Fz8OXNpAYOloD0OXJVy6TvFAtY0B3eT4pIEG8xYIwt()VpTCr6MvPz4J(0Q8OyGcL5Blwq(PP3E320vv)y207Sq2rJUycPTBswq(5jxo92LPXXj02MuUy6TqBpz0KtgD(3TB(U5)9najk3n)(I817MFB66VF38bjFSkjRm9dj7MVTK8)YVF38pevKgD3QKY)5DZxh9PDZxgbppA38njf3NxSokBb5FVmTA4PegVi)(0ve2nArvAEw5PBkswKV(UOQxD93Uj)XKIzpMxepJ8IvPvBJt29t7(jwBjTyr0QvZO)ZzRslREnOAUErE(Q48hZkLBAnFrBsvYSS8SKxNV56YKQx)HOvBtU(f3T9(7pT6X0vPpSSAwY)drbMExr621ZwMV6tZIwV50TBoYtZkxgr6ywd39tFZU5)gRz7M)xeTB38uIQeitA2d7MtFRDZJJwtgF9Y00MQY2bYop9un1oLj9bZGG0he7bnmuMtsL6G1(5COZVLPDwK)HKSOSkkVr(RKMh7MBwrE5zLKxsLFQIwLKvDktZutZJy)CY67kIwuRMrM42LetpXyul5Is4TdNnEHB(4VgvuUKmiWN1dZSGbPKKmc7vrCoqyK5rzXuwRijkMmOrM4yY8NctP)VskYzVyjRDz52e0DZ)HTRwP10sQAPiPC7QkYpMsycyCB(F99Wm9m6S8bxSBEvorOgAsMxTB(zen4hRkI0Ot1J5k0H8ZdMWjKtD9Y4zuApRaSZksIv15J6WRME)RxKNfNcV21CJuPrvkPVG(NZswvMC9Kq6NfBlkiJ0wMSSegONjgNpfFJxnW(dxh9rkjFP1NpdndOKWNQZ6RP5DKzBQ32NEAaxXyiF3CTLNvRJhIg2)Nud1kQXO95ABiM6E88SikBgPZiblmNPnOoAG(KnWvUG5SQag(0tOw18n9nJhBlj06QvLZI3weHrNiJtbBn6NerXXmsqF)tlxSmTC9PjFmzXwI7ZQ01jVo9EUlg8POMUEA5E3XJ3FsW491PzXZUBvuzLc)FOPVK(joQ4pMrA12vpK0lkN6rfAZr0lXjrvlDoaP3WVayH64H4)ygjMcPpIZskljpO4HeItGKOve6Tzr17g3FwYWO1dK3R0fJYBqV1LXPFaMUdEECAHiAsV1TlJwL7Q)GNHZxhaEZiH8zeB38te(gPDK4HKaSF7U5)BFpjQjobA(1KyRLK)kb2ofyofex979ycgdF7kcCHSea5a4agrXtijI6RAzc8SpcEKrg5rI2h67AKz0Fn5JeqCRsiPjm4SjipE2yk3C2Ptq(ymYyLmF8eVqXawbDosa1sNSxzLQNC(PNheHhaak9e8dcHkHD9(v55f1bpS6(VwNFIeGaxJ(d)NEyrmeLghr)(8TzvOYLZc165TRVlPGosr43tUVGYUrRaWrRJsZKqIVG4pJiyrFikDfqe3Yg)vNzfDUNPUwFtHDmx0L0E08j(BV)V9Dc7YzjFKKKzvsCDkfp8WNOdsSOrFl4agKXnfeJ1S4xdwHOSgHacQsxapnE7c6CaaZl9jzXNaOfzixF0TOuZcZyD5mo5SHYJnlKalnnBw(9ZQiZsi5UWKBI1NmwVr0H1Ovl2UcNPTeMGSE7IL0rP6zJexReh74OR(m4htQZrMHzcgH5dTeO6)ED612TYOw)Xje4pRX0csVxMO0(hAYJj4pa6SOSpPplbAbjB8fa876mcLsx70266ZWqdYLIHfP9ukuqpcWE0Nd5woq)hPM2LVZ6KB2dPyt)1UHysdTKcJXSbPC2aJFM19cxlUnEhgGa8F01aMTm(mxoenrv1l(Dg)XDmeGuaZaIw9y0Ni2Pe0hmxM3NwatWU93)U33lsxZWL0tLqQPAgAgppCBUBtaFrm5I4PeMK(4sijFQNjEw(uOyK5Xiwm6eBght8ygL5Rwn9QAXNC3l6LHhnWgUZNEI9RaJmRkFg5NNnE07AU7g6eGloe8VehZ8r(iXjj4zEj0rLuh4GPmjsgKurVOGLYrH1pVS5SxC(U3C9zAYGmucdbHkgKjurvaaVviCdARyfJPdPJ1KyAyanWP4mtW9ej7OqA37gtSxgm4StcIQNC2WHw031kbKhBWt7qWtEi917oJXzH049MRqZG3JjVq8M0HSxADct8jEYns1dG8tcAUpR4Nqkr9a3BnVloZHpvLFXFkCg99UGHLKbOiRtUHcktcxVo(mhOWipHihFaLpcYWFK1fX5zhxv3t)2FreP41I4M3hrWRsEN)ofCD560QKJlRJyKMNjdveqJNuMaLElcbVwwDYIied6cIuxKM7fpiKwjjPaFORTSIaEZ5YaxK9b9H3uh1cKp1rAvy7U4(LeKweXN(kweGx0qnd1cEAWgV0w1sRRi6jwEglRGHMPD8duaqSSbRZMVEa)Uewr0jsZj3uRip5gki4tUbEMwUxU1kqza4iqLunmP1znwzdBVswU4Q3xPIWG)sYQlEBmX7J6GF0ZSmUNaIsbJgkN)CJz80sLHWvdlHFWZcxSnYM(MrSIFtaZty88Tfq9U1RoqltpVC7D1PP6Vy5mM3vLYRtgXSqh(YgH3id9dBH0O59(7e0yFh4Pek158ACUyXbsQQGAGqaJaRMebKFHi)0A3PrfjAqDXfhWJ)iKDkFm2IDRBw(vJ)8AEjZVFXzA9nWiaMohmacJAGgIm0I7vaWHs2XWFIJqS1Pmd(HOpa)lyug0Mfls2qJ8a55Cm9XFCtkOv7K6rcWK90uhmqVqYhjkboYwGLDnFvca7mEb(A0Y40SHdnRk(nxpEepb86KfSyKZm(f22yGCzZ79up4CXpCXW1PFkLCGw2NpJC0rUwKgDKT0mIXkNt9q0w1mLakaP4dW7Je3U1xWUHKPj3(WrnT0d7pparyiSGFicsjLBuRyTqj1IdFcfZUu5F0MaiMJ(nSaZiBimE)QksIf2(lXaky9kKNNES9a97J0QI3076IABvo5vvHmUPuKo1u9OlIl1HcVQsplmDRwZ2APrSMQAYrALrjh7K)XqKUWx5xBoIel70VTe8dKsxJOvPvvq17UdKKY01BGTiy6IxdauG8TqZ37YHblN1flNMiLyP2Mhvx)515RXmKLlgDDLZGLuTu86BltIj5EFlBYBobEX60)x2Y3uN4g0Wn5LLPWKq)ExfQuBPOAgS1AX0QH9BP0vWI6XEN(SkAQoj1TlmYVvS4fZv(hSH3AV95mqKT3R)(ztJCZxDHcu56VeJe4kHqzhvgHfi6lyDGZ3wvMgNqNhRf4GBlOmIZb(JBq5AK)WkvxbTC)nm6KNCBl2XaDhFCxH2tE5ahW6GiL(xxMgsMYzKSECWZBgmwIlTVPt1VSKZ8PAkydYcoa0lID3eqEvHPfRpb(2s5j9vLxxB89xh(D3MTcM653Rk1Cwy1JuGWAHzF7x5Sx(sGLh2YmYdJhXdOC0sFII6)JdI9aB3chm9IpVEIPSv0iDuKheDvyjY43PRuN5WTRCLLQ9FP5VvNJL7YITzMF5uG3qC9zSTBxK348dAAzWK)QaeFUehXla7MTyAbltM9yk8LRCuCU5pYx41XJGsX(cFVR8CRnKxs(DhoCyZIU4B6q2vSeVZ)n1p3GgPS4lrsMW8Fne6QlXs2tgkJbABkM40KBgm60jV0QgMVWPdjJPKKJ)dsqcIQUi5(IeIkLWwhj07e959BxnBZ2S0YLqYVcqPMp7ObEhs3VT(2q9Xu9HFqd50EXRkYWq6qRICA523QiCjuLvmAtSDPpXap4YN44fL((9y1(1YsIO9HcuVeKHtw2Bm8iFFPtSp7YFasg89)6TeaD)mGxJ4J)XcmMUTLjhkpJgkh2oEhdB9P8TqSR)iHteayuu5Y6Tnpb)gupNKDM7LBCdauslMgW3LW22GUdpimmSBRIsJbWivawUxZ6m8dN9r8tFcOpffkqcEXNUl5H0m6Ehb6MOAoEXNwafPc3u0KGtybHGUbghiTwPUsis2YzOmj5rb)3ZeIO0Biv3j3MrAdBI3rNs0Kkc3aG)od9UQD9SzSwgu6(oO75qQ7JawJd1PK7PwWB()Y9ZsT9pLm6IW7zP3srkK(oTlZxfPMp5Epc0RkCC6i8nKt8r8ReCo4AfctXW4U7m)0dRF3t5qJCeoUoYqNJ)AVR0MX1aQRJAAMNQyOpUfsxyNuOET7VUnfA31JSTBc(XevVRt(EPpNzy7KlCUIFAfKH)0Ie87HG9cYFxeS61xN5ncLE(JPqKaQZyIJDjbJdzuy(BXEsPvQFyewjH6miFjkAwUlvcQ)DG2XUZX7RAXgilP4imiVAbX0H57UHT1PFg2XZv846sb5Ob2(GddqC7M0rMQ8FVTKTYi094juhesMmiIiRFZsomRSnjwaywcVSPt9WNCBTRLrY4I7CgKst1kfHq9aO47nMdZZHZ3eDLgPnp3cbAEENfmjVqoFv6MVvlbC6pkIpuvF4siRtLzhf859p5dxApe9UFFuhSUmipChKEpq)J7vpVNUxDQS2pUkedGdrpabaou02a(E)3foGTVpDupAFyputxyoyXqulStphNsMT1t4EFyzhkgBq67)UHd3F)iDxWEiJ7o6UC87MUENVu6nuwdUAAYrrGZtACgRB3fboK6zibXT8nauf(jGgSgR097aMOZMeOwyXSJ4Hs90DzNXdLVgYqQKU8I4rSaVp5hUACH)(0KmwkWIL44oYVLuCAc9aYIDMPPpjx6C0rHUccifMQvu9BWfWnMKK)pkLLh10XuOn23Bw5k6abud3sYZKfyDoGXFIs)6Obh57WjY5zpeBMt5NYwaBymGrRfnI06G1RySmstvjPwHrjyfXY4pqJe)KKOqNrS4wx6MQp9KOa2QpJ5D)g(Amn92pKuapIDkfoE0KP3(yubuHZYP3(BWS901BWu6XABECCY9rBxvDC9M5dQfBzoKyE02QC4ypjg3oEzpKuE6UF6NXDzWKVdMBKr6l8XhBF45yQjJJNwp4DmCGN8XHnrB1JYnnsR(qxu(Ydix7G29axF2i7KwVUqAe34eoZf5p3HwbtXsxzW(6XCqkhkbTfqwJMAp1jXVY7ONiWH9Xp59kGJo4nFM6aJ9JGUcs)5o7G3AVd4HM1iS0ASBNGJDy6jffwNxL)mnCq0ZCzpVk3Wgg(elCqMXQKjNK6xef8ccd64E8mhQMT6bs(T1KuiioC4PFW5OPB0FSl905ou39Mv35oM1B7ttwxgS0exDZfoutD242fblTvmbZ58MTPTDuVZ58cqOrq(V7KGo8T2loUVWLBV9XjIlI2DvGdFNT0RKlY0z(AIJX6EB67ehtF7S1Plc2zvWLo8G17eS3N5F54d8G3LoaV1DvZfpteSxCTCzFpB7kxaE6RbSR6BB5RCzI1h63RCyE1zFdx5WBMEfa1ORrbc)mrEhbDo0K3y)UP3bgn4Zzx4yozFPKCr(NbjO)6I34WptVukI34o8wpqCh(B6hI7WFJ2oPtJ4Ap1jXDejQF48dzfX8q8(fVYBoKviZfX7COV34VIq7j36M49So3H3MErkE7HXvWUFYsHK5lIYXTQuY9oc2EMEpB2b9gFBD0rS3C(ZHNp3dp)ioYaK5YDZPRjeCiluwbQ9P3I)n8sSIU0mK)6VGxQvmsn9FT(AEA6T6xCt03Eg89YqEy9YmnTA6VmwJc5BMEBzsLGu1vVe(BR2s(Jxq3qMnERdTB(r7M7TXmhk0MJ9eJdRO3sra)DER5Va7VDZF6jX32z9fJKgxqFd6L2vr6gApgYv6e9fRVuNab5IEuqu0Ybigq77Gqq)gDfIWKwlc(JCGwi1ZmSUOxYYbpqIMKeW1yfW8xEiy(x0c(x4Qvtac5kWcKGRATemsU)npom14J)8kWIsiqx)g76607TRT9PJzJfxW(B4jWY0BNq8dxKsIZKgji1Ps2ieM4TTEa36NUf96PcvhdyUJDFpxTB(lD0g576QDZhAxSzNMQa3F2OwZ(IPtUwMAQ7UbsE8m67DZV5ARpxaVrL5TkNOeOhETzjyayw7CpNG(meCM9VGJ5dPcPJTNImRR(fTQnDo4l(luuBpoGrQo3q(0YsBIu3wu8O4ypuN(aBNlTb2TstVQDKRSlfq(Ywqz)814q7ELXcMBgSpTffniDHyVY1f9b012Ib(m01Mdfok0mYK2cZfetY4ahh)dDMxTqwjU1wGIVi5wzWwoxxcwJ0(mb2n)DWM(aLxBXKcsELweG(qonwtbmzgBHCcI7CDoI2z(ZYIvJCOTqkbXHgNRODM1KxOAKNS57hVMU8hOZ7UEbVtX(qZ78fmC33UBoB)Vilusx9vAUt)ZBUTE8MBdnbAFA2kH)noaK0gWoqxmBiR3(y4CZsflmFsd0poY(fsjqnZ6px3qBC5JyiilojopelCQJyjPmYI3dxBWmuh1(KSdafPUT0)aCBWHkZwbeQjvyaWQvlkb2c5XFrEn139B8KX0FeB)NJ4g895hbzIbsARarfOKowtGy31CwLiXLghxKKLkTJhg1qBUNDHH2cud0kyvbQbAa4LI2HFWDzv)iiHTbDXtzcLKlVWe)ZBfUT2j(nHZwrn04nHN9jegDH15ggTQLttoVvyhpGAPE8k0twF6xz17Qu8)ocjORmEO9O1pRsSfHWiddkXlC81go8EA8vkbE(zX9lRxLj3P3RmSh812N8GQN(hkt3zOG3QYd1zbpirB)Vn)0mPhytlBEcFZuhOXsyT)Dy(dCBy6)DggCk4(8e8nOtfSAoOCcJhyanEfmBJ0)UAoXuAcJa9SeG2LTk1I2zx6UGdkgMYNFVwJ9OEvaA6I0YfcyiAau8BvLkBN4BPAgARf1QCRYl7oe0uqLVjbdwcDKVIroD)JZ9oiFGYvbEScc2vYsKzs3WNuAEz9PA3W(u27usPE(IHWbAhRDAaRNh)60ZaYKH4GEGSV2uI1E6e)RD1qpc7lACXJqz1XAx6jjCNlzfFW(vQCnxPGprfdPyHYvunsTZ)A6yCaJRnxS3VwgrLwNsaZcRY0O8YzQW6hUZiDRRMSrDSWzJyD8VW6IZU9opgjNjl5nvWVgok1rwy)wDv9lrX2MvoVPwheLxHvPfV7I2VmPU7hCoXyd7P6RJlJDjcTswhO73ru66eoCnM(RLjaw3pwpVta6e(k7QBjCVnwRhwBoy3TKMja5An7KtnU032UuoLcVetAdzPVvlLs53s((q2x0L48IwTk5bpS0CsO77DzPkUiFsyNQSCpiHnEZfeKiOuqf3BKGl6uvL9kLDiPTDh0RoZWw4z)28nnVb1LTcEuWlBTMY2qwKxP69xiM0(nKwahaYQf7wnAVSDKmIcYVJmu7ra1A0eIjMUC5WMi2332NOa2PkAANV)kbxXeRRK(ZkUIjDQSvE16Qz4f2Qee6noAd(85B9OjDhUuVlwT)(nYMN6oVlSM0DiknOkccazpDVMArL0AqDO2WtXDSTZm()nxIP8bpxfAx6Eg95yDbudozXstogO4XoDnARgyHX)8LwAs7lgwNcXIgTUIWYMM8SFjRIkGwHCZRC9vse4l)8xARl70k17tP3LivFzFrVgsyF9C(TKtVs4HMQHao2SFys7PXMEbfHlLwG73Gl7E5(8RjcRya79TnRf8dwXhC5(HhEFLZww0dpg6nxZJlB)NOPLTXviP2AQz0dUt3ozat1(DfARJbRFvm6Bz0bwQ7vaZSN(AjUOvOqpVXf7oyeNQ9U499WCv8gMZz6okZT3QR60EHS)1rFjeH6QUJJQjDry(UB42)nep3OC0Dmh9JC0LyqEcZCv3roeI80ybi8EndhszfqHO9Nidw3vvIfG2iiPnHvomP0Zrosp6DnJODV3o1ZMqw)RnEaIpMZwU(MJ1)QQfFi6s7ipM201zYg2sFxkT8P)IfZ7fHtvzVxY3JRYuL9Fkh3jGqGByfufRJfjavSlLc)31)mSL7CLpO)R0HD0MENF(xeCNloXmG(wp8VXSeVJaIDjnyiZURwqWfKNmc(YZEPJbFLDd2qjJs2vcd3wq6MHrUvmMlY1HONEsI(AjLQnAJABFM0Lp(JHQgL1J269no8OdnAH82(QxhHmMi9L5iK357h4ri9(ggHEJoWmBJqg7bowZfuM(Dvb0thCZc5DnrJKu7G)HTSIE2Hd0vpWQiIGWqEshOYEZt8dQfkF57KfboBl4trs475Q3Od2qD3a(N3e17SEtuBXbVJtetHwx(c0cv96qKAHjVfBbBL8x63Gouhb0EB)jvgPHbVDJuzpEHmEJo4H9M7uMX6PYpM(2R)kKuDVhW(vWNRoHFaDGk7TKAmoeyvBDnuGOzQF0s8RfqWUqdChpTJsG8DmMScude)BhjZzg3UyAS5BpKbbEUTAE7yzrhDiQkUvYysTC8fQ4z3(TdRbluRsagqT)zFbZk6B9yjTRyfoNC(c1uNOFidwZQQ(rYq4RQp24csl72N8HJrKch72dTxn4HJ3SQKC7P(Z0qPACo3UxdXN4ZaRkC02eN(8OiB2FwtFUxn466ZWKkf9SXPL3ZfhimknoU7Eoybm0DLLdGUNJoxl0TXXu3HJho02ZgNSD9ROqxzjFvlqPubUe3Uvcj)fsX4817qj5UtBY4C27WZcM4mRSCu6D45dkOVklhmEky763RLyR4uONuDM(AvXdoEKERQtqvTzNPGS0ygNwRvWHk7KrRDN3qsm0Z2QqZLGEcv5h(T4S)Uj439WTAS96fGRbLYfnCD(GopXtvv84fImhUVpSj7rxjEvBPnOOPiZdI74nHChQOYGMB2rQ1h1umPuYHoWURL67wyBzGOOnSFVjllO2VnJL7WkwhP7k3shzEFk3Cxrf)gU8KPBIukpntCpkxZK87Nz68QnfjlYxFxK4u53YS27ZlQsR2gBoTuAzIAAEj7SaupVyy7LcNErIAjIgIe7K0Ie8OhtZHk0e2EmoHTPnO7VgjpTG67lReUdj3y9GbQmu7ZFT3t18WKvyVNa3HcBAqbMpBudXgp7SGICFwGXI9J9)qPkmGPVxOKSu9WVGGKBfTS2GWLTbVdfERF8oIf)Vj)Q)kPr43Nj4ymbwqDZa46HRR1UpBAs3iEKrZ7AtEiJFpS1JX9KIM7pFdKwar0nsZZ3WBwFh(rg0ylAB1s4qt(FpAZ2vrzP4Vo9)7d]] )
