-- PriestDiscipline.lua
-- July 2024

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 256 )

spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Priest
    angelic_bulwark            = {  82675, 108945, 1 }, -- When an attack brings you below 30% health, you gain an absorption shield equal to 15% of your maximum health for 20 sec. Cannot occur more than once every 90 sec.
    angelic_feather            = {  82703, 121536, 1 }, -- Places a feather at the target location, granting the first ally to walk through it 40% increased movement speed for 5 sec. Only 3 feathers can be placed at one time.
    angels_mercy               = {  82678, 238100, 1 }, -- Reduces the cooldown of Desperate Prayer by 20 sec.
    apathy                     = {  82689, 390668, 1 }, -- Your Mind Blast critical strikes reduce your target's movement speed by 75% for 4 sec.
    benevolence                = {  82676, 415416, 1 }, -- Increases the healing of your spells by 3%.
    binding_heals              = {  82678, 368275, 1 }, -- 20% of Flash Heal healing on other targets also heals you.
    blessed_recovery           = {  82720, 390767, 1 }, -- After being struck by a melee or ranged critical hit, heal 20% of the damage taken over 6 sec.
    body_and_soul              = {  82706,  64129, 1 }, -- Power Word: Shield and Leap of Faith increase your target's movement speed by 40% for 3 sec.
    cauterizing_shadows        = {  82687, 459990, 1 }, -- When your Shadow Word: Pain or Purge the Wicked expires or is refreshed with less than 5 sec remaining, a nearby ally within 40 yards is healed for 14,690.
    crystalline_reflection     = {  82681, 373457, 2 }, -- Power Word: Shield instantly heals the target for 4,116 and reflects 10% of damage absorbed.
    death_and_madness          = {  82711, 321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below 20% health, its cooldown is reset. Cannot occur more than once every 10 sec.
    dispel_magic               = {  82715,    528, 1 }, -- Dispels Magic on the enemy target, removing 1 beneficial Magic effect.
    divine_star                = {  82680, 122121, 1 }, -- Throw a Divine Star forward 27 yds, healing allies in its path for 6,855 and dealing 6,191 Shadow damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond 6 targets.
    dominate_mind              = {  82710, 205364, 1 }, -- Controls a mind up to 1 level above yours for 30 sec while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings or players. This spell shares diminishing returns with other disorienting effects.
    essence_devourer           = {  82674, 415479, 1 }, -- Attacks from your Shadowfiend siphon life from enemies, healing a nearby injured ally for 17,627. Attacks from your Mindbender siphon life from enemies, healing a nearby injured ally for 5,875.
    focused_mending            = {  82719, 372354, 1 }, -- Prayer of Mending does 45% increased healing to the initial target.
    from_darkness_comes_light  = {  82707, 390615, 1 }, -- Each time Shadow Word: Pain or Purge the Wicked deals damage, the healing of your next Flash Heal is increased by 1%, up to a maximum of 50%.
    halo                       = {  82680, 120644, 1 }, -- Creates a ring of Shadow energy around you that quickly expands to a 30 yd radius, healing allies for 15,767 and dealing 15,943 Shadow damage to enemies. Healing reduced beyond 6 targets.
    holy_nova                  = {  82701, 132157, 1 }, -- An explosion of holy light around you deals up to 4,527 Holy damage to enemies and up to 3,084 healing to allies within 12 yds, reduced if there are more than 5 targets.
    improved_fade              = {  82686, 390670, 2 }, -- Reduces the cooldown of Fade by 5 sec.
    improved_flash_heal        = {  82714, 393870, 1 }, -- Increases healing done by Flash Heal by 15%.
    inspiration                = {  82696, 390676, 1 }, -- Reduces your target's physical damage taken by 5% for 15 sec after a critical heal with Flash Heal or Penance.
    leap_of_faith              = {  82716,  73325, 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    lights_inspiration         = {  82679, 373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by 8%.
    manipulation               = {  82672, 459985, 2 }, -- You take 1% less damage from enemies affected by your Shadow Word: Pain or Purge the Wicked.
    mass_dispel                = {  82699,  32375, 1 }, -- Dispels magic in a 15 yard radius, removing all harmful Magic from 5 friendly targets and 1 beneficial Magic effect from 5 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mental_agility             = {  82698, 341167, 1 }, -- Reduces the mana cost of Purify and Mass Dispel by 50% and Dispel Magic by 10%.
    mind_control               = {  82710,    605, 1 }, -- Controls a mind up to 1 level above yours for 30 sec. Does not work versus Demonic, Undead, or Mechanical beings. Shares diminishing returns with other disorienting effects.
    move_with_grace            = {  82702, 390620, 1 }, -- Reduces the cooldown of Leap of Faith by 30 sec.
    petrifying_scream          = {  82695,  55676, 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear.
    phantasm                   = {  82556, 108942, 1 }, -- Activating Fade removes all snare effects.
    phantom_reach              = {  82673, 459559, 1 }, -- Increases the range of most spells by 15%.
    power_infusion             = {  82694,  10060, 1 }, -- Infuses the target with power for 15 sec, increasing haste by 20%. Can only be cast on players.
    power_word_life            = {  82676, 373481, 1 }, -- A word of holy power that heals the target for 84,466. Only usable if the target is below 35% health.
    prayer_of_mending          = {  82718,  33076, 1 }, -- Places a ward on an ally that heals them for 5,974 the next time they take damage, and then jumps to another ally within 30 yds. Jumps up to 4 times and lasts 30 sec after each jump.
    protective_light           = {  82707, 193063, 1 }, -- Casting Flash Heal on yourself reduces all damage you take by 10% for 10 sec.
    psychic_voice              = {  82695, 196704, 1 }, -- Reduces the cooldown of Psychic Scream by 15 sec.
    purify_disease             = {  82704, 213634, 1 }, -- Removes all Disease effects from a friendly target.
    renew                      = {  82717,    139, 1 }, -- Fill the target with faith in the light, healing for 27,667 over 15 sec.
    rhapsody                   = {  82700, 390622, 1 }, -- Every 1 sec, the damage of your next Holy Nova is increased by 12% and its healing is increased by 20%. Stacks up to 20 times.
    sanguine_teachings         = {  82691, 373218, 1 }, -- Increases your Leech by 4%.
    sanlayn                    = {  82690, 199855, 1 }, --  Sanguine Teachings Sanguine Teachings grants an additional 2% Leech.  Vampiric Embrace Reduces the cooldown of Vampiric Embrace by 30 sec, increases its healing done by 25%.
    shackle_undead             = {  82693,   9484, 1 }, -- Shackles the target undead enemy for 50 sec, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shadow_word_death          = {  82712,  32379, 1 }, -- A word of dark binding that inflicts 9,398 Shadow damage to your target. If your target is not killed by Shadow Word: Death, you take backlash damage equal to 8% of your maximum health. Damage increased by 150% to targets below 20% health.
    shadowfiend                = {  82713,  34433, 1 }, -- Summons a shadowy fiend to attack the target for 15 sec. Generates 0.5% Mana each time the Shadowfiend attacks.
    sheer_terror               = {  82708, 390919, 1 }, -- Increases the amount of damage required to break your Psychic Scream by 75%.
    spell_warding              = {  82720, 390667, 1 }, -- Reduces all magic damage taken by 3%.
    surge_of_light             = {  82677, 109186, 2 }, -- Your healing spells and Smite have a 4% chance to make your next Flash Heal instant and cost no mana. Stacks to 2.
    throes_of_pain             = {  82709, 377422, 2 }, -- Shadow Word: Pain and Purge the Wicked deal an additional 3% damage. When an enemy dies while afflicted by your Shadow Word: Pain or Purge the Wicked, you gain 0.5% Mana.
    tithe_evasion              = {  82688, 373223, 1 }, -- Shadow Word: Death deals 50% less damage to you.
    translucent_image          = {  82685, 373446, 1 }, -- Fade reduces damage you take by 10%.
    twins_of_the_sun_priestess = {  82683, 373466, 1 }, -- Power Infusion also grants you 100% of its effects when used on an ally.
    twist_of_fate              = {  82684, 390972, 2 }, -- After damaging or healing a target below 35% health, gain 5% increased damage and healing for 8 sec.
    unwavering_will            = {  82697, 373456, 2 }, -- While above 75% health, the cast time of your Flash Heal and Smite are reduced by 5%.
    vampiric_embrace           = {  82691,  15286, 1 }, -- Fills you with the embrace of Shadow energy for 12 sec, causing you to heal a nearby ally for 50% of any single-target Shadow spell damage you deal.
    void_shield                = {  82692, 280749, 1 }, -- When cast on yourself, 30% of damage you deal refills your Power Word: Shield.
    void_shift                 = {  82674, 108968, 1 }, -- Swap health percentages with your ally. Increases the lower health percentage of the two to 25% if below that amount.
    void_tendrils              = {  82708, 108920, 1 }, -- Summons shadowy tendrils, rooting all enemies within 8 yards for 15 sec or until the tendril is killed.
    words_of_the_pious         = {  82721, 377438, 1 }, -- For 12 sec after casting Power Word: Shield, you deal 10% additional damage and healing with Smite and Holy Nova.

    -- Shadow
    ancient_madness            = {  82656, 341240, 1 }, -- Voidform and Dark Ascension increase the critical strike chance of your spells by 10% for 20 sec, reducing by 0.5% every sec.
    auspicious_spirits         = {  82667, 155271, 1 }, -- Your Shadowy Apparitions deal 15% increased damage and have a chance to generate 1 Insanity.
    dark_ascension             = {  82657, 391109, 1 }, -- Increases your non-periodic Shadow damage by 25% for 20 sec. Generates 30 Insanity.
    dark_evangelism            = {  82660, 391095, 2 }, -- Your Mind Flay, Mind Spike, and Void Torrent damage increase the damage of your periodic Shadow effects by 1%, stacking up to 5 times.
    deathspeaker               = {  82558, 392507, 1 }, -- Your Shadow Word: Pain damage has a chance to reset the cooldown of Shadow Word: Death, increase its damage by 25%, and deal damage as if striking a target below 20% health.
    devouring_plague           = {  82665, 335467, 1 }, -- Afflicts the target with a disease that instantly causes 21,144 Shadow damage plus an additional 24,614 Shadow damage over 6 sec. Heals you for 30% of damage dealt. If this effect is reapplied, any remaining damage will be added to the new Devouring Plague.
    dispersion                 = {  82663,  47585, 1 }, -- Disperse into pure shadow energy, reducing all damage taken by 75% for 6 sec and healing you for 25% of your maximum health over its duration, but you are unable to attack or cast spells. Increases movement speed by 50% and makes you immune to all movement impairing effects. Castable while stunned, feared, or silenced.
    distorted_reality          = {  82647, 409044, 1 }, -- Increases the damage of Devouring Plague by 20% and causes it to deal its damage over 12 sec, but increases its Insanity cost by 5.
    idol_of_cthun              = {  82643, 377349, 1 }, -- Mind Flay, Mind Spike, and Void Torrent have a chance to spawn a Void Tendril that channels Mind Flay or Void Lasher that channels Mind Sear at your target.  Mind Flay Assaults the target's mind with Shadow energy, causing 32,998 Shadow damage over 15 sec and slowing their movement speed by 30%. Generates 15 Insanity over the duration. Mind Sear Corrosive shadow energy radiates from the target, dealing 17,413 Shadow damage over 15 sec to all enemies within 10 yards of the target. Damage reduced beyond 5 targets. Generates 15 Insanity over the duration.
    idol_of_nzoth              = {  82552, 373280, 1 }, -- Your periodic Shadow Word: Pain and Vampiric Touch damage has a 30% chance to apply Echoing Void, max 4 targets. Each time Echoing Void is applied, it has a chance to collapse, consuming a stack every 1 sec to deal 1,216 Shadow damage to all nearby enemies. Damage reduced beyond 5 targets. If an enemy dies with Echoing Void, all stacks collapse immediately.
    idol_of_yoggsaron          = {  82555, 373273, 1 }, -- After conjuring Shadowy Apparitions, gain a stack of Idol of Yogg-Saron. At 25 stacks, you summon a Thing from Beyond that casts Void Spike at nearby enemies for 20 sec.  Void Spike
    idol_of_yshaarj            = {  82553, 373310, 1 }, -- Summoning Mindbender causes you to gain a benefit based on your target's current state or increases its duration by 5 sec if no state matches. Healthy: You and your Mindbender deal 5% additional damage. Enraged: Devours the Enraged effect, increasing your Haste by 5%. Stunned: Generates 5 Insanity every 1 sec. Feared: You and your Mindbender deal 5% increased damage and do not break Fear effects.
    inescapable_torment        = {  82644, 373427, 1 }, -- Penance, Mind Blast and Shadow Word: Death cause your Mindbender or Shadowfiend to teleport behind your target, slashing up to 5 nearby enemies for 13,053 Shadow damage and extending its duration by 0.7 sec.
    insidious_ire              = {  82560, 373212, 2 }, -- While you have Shadow Word: Pain, Devouring Plague, and Vampiric Touch active on the same target, your Mind Blast and Void Torrent deal 20% more damage.
    intangibility              = {  82659, 288733, 1 }, -- Dispersion heals you for an additional 25% of your maximum health over its duration and its cooldown is reduced by 30 sec.
    last_word                  = {  82652, 263716, 1 }, -- Reduces the cooldown of Silence by 15 sec.
    maddening_touch            = {  82645, 391228, 2 }, -- Vampiric Touch deals 10% additional damage and has a chance to generate 1 Insanity each time it deals damage.
    malediction                = {  82655, 373221, 1 }, -- Reduces the cooldown of Void Torrent by 15 sec.
    mastermind                 = {  82671, 391151, 2 }, -- Increases the critical strike chance of Mind Blast, Mind Spike, Mind Flay, and Shadow Word: Death by 4% and increases their critical strike damage by 20%.
    mental_decay               = {  82658, 375994, 1 }, -- Increases the damage of Mind Flay and Mind Spike by 10%. The duration of your Shadow Word: Pain and Vampiric Touch is increased by 1 sec when enemies suffer damage from Mind Flay and 2 sec when enemies suffer damage from Mind Spike.
    mental_fortitude           = {  82659, 377065, 1 }, -- Healing from Vampiric Touch and Devouring Plague when you are at maximum health will shield you for the same amount. The shield cannot exceed 10% of your maximum health.
    mind_devourer              = {  82561, 373202, 2 }, -- Mind Blast has a 4% chance to make your next Devouring Plague cost no Insanity and deal 20% additional damage.
    mind_melt                  = {  93172, 391090, 1 }, -- Mind Spike increases the critical strike chance of Mind Blast by 20%, stacking up to 4 times. Lasts 10 sec.
    mind_spike                 = {  82557,  73510, 1 }, -- Blasts the target for 8,941 Shadowfrost damage. Generates 4 Insanity.
    mindbender                 = {  82648, 200174, 1 }, -- Summons a Mindbender to attack the target for 15 sec. Generates 2 Insanity each time the Mindbender attacks.
    minds_eye                  = {  82647, 407470, 1 }, -- Reduces the Insanity cost of Devouring Plague by 5.
    misery                     = {  93171, 238558, 1 }, -- Vampiric Touch also applies Shadow Word: Pain to the target. Shadow Word: Pain lasts an additional 5 sec.
    phantasmal_pathogen        = {  82563, 407469, 2 }, -- Shadow Apparitions deal 0% increased damage to targets affected by your Devouring Plague.
    psychic_horror             = {  82652,  64044, 1 }, -- Terrifies the target in place, stunning them for 4 sec.
    psychic_link               = {  82670, 199484, 1 }, -- Your direct damage spells inflict 30% of their damage on all other targets afflicted by your Vampiric Touch within 40 yards. Does not apply to damage from Shadowy Apparitions, Shadow Word: Pain, and Vampiric Touch.
    screams_of_the_void        = {  82649, 375767, 2 }, -- Devouring Plague causes your Shadow Word: Pain and Vampiric Touch to deal damage 40% faster on all targets for 3 sec.
    shadow_crash               = {  82669, 205385, 1 }, -- Aim a bolt of slow-moving Shadow energy at the destination, dealing 6,978 Shadow damage to all enemies within 8 yds. Generates 6 Insanity. This spell is cast at a selected location.
    shadow_crash_2             = {  82669, 457042, 1 }, -- Hurl a bolt of slow-moving Shadow energy at your target, dealing 6,978 Shadow damage to all enemies within 8 yds. Generates 6 Insanity. This spell is cast at your target.
    shadowy_apparitions        = {  82666, 341491, 1 }, -- Mind Blast, Devouring Plague, and Void Bolt conjure Shadowy Apparitions that float towards all targets afflicted by your Vampiric Touch for 2,729 Shadow damage. Critical strikes increase the damage by 100%.
    shadowy_insight            = {  82662, 375888, 1 }, -- Shadow Word: Pain periodic damage has a chance to reset the remaining cooldown on Mind Blast and cause your next Mind Blast to be instant.
    silence                    = {  82651,  15487, 1 }, -- Silences the target, preventing them from casting spells for 4 sec. Against non-players, also interrupts spellcasting and prevents any spell in that school from being cast for 4 sec.
    surge_of_insanity          = {  82668, 391399, 1 }, -- Every 2 casts of Devouring Plague transforms your next Mind Flay or Mind Spike into a more powerful spell. Can accumulate up to 2 charges.  Mind Flay: Insanity Assaults the target's mind with Shadow energy, causing 51,222 Shadow damage over 1.7 sec and slowing their movement speed by 70%. Generates 12 Insanity over the duration. Mind Spike: Insanity Blasts the target for 30,577 Shadowfrost damage. Generates 8 Insanity.
    thought_harvester          = {  82653, 406788, 1 }, -- Mind Blast gains an additional charge.
    tormented_spirits          = {  93170, 391284, 2 }, -- Your Shadow Word: Pain damage has a 5% chance to create Shadowy Apparitions that float towards all targets afflicted by your Vampiric Touch. Critical strikes increase the chance to 10%.
    unfurling_darkness         = {  82661, 341273, 1 }, -- After casting Vampiric Touch on a target, your next Vampiric Touch within 8 sec is instant cast and deals 22,432 Shadow damage immediately. This effect cannot occur more than once every 15 sec.
    void_eruption              = {  82657, 228260, 1 }, -- Releases an explosive blast of pure void energy, activating Voidform and causing 15,713 Shadow damage to all enemies within 10 yds of your target. During Voidform, this ability is replaced by Void Bolt. Casting Devouring Plague increases the duration of Voidform by 2.5 sec.
    void_torrent               = {  82654, 263165, 1 }, -- Channel a torrent of void energy into the target, dealing 108,625 Shadow damage over 3 sec. Generates 24 Insanity over the duration.
    voidtouched                = {  82646, 407430, 1 }, -- Increases your Devouring Plague damage by 6% and increases your maximum Insanity by 50.
    whispering_shadows         = {  82559, 406777, 1 }, -- Shadow Crash applies Vampiric Touch to up to 8 targets it damages.

    -- Voidweaver
    collapsing_void            = {  94694, 448403, 1 }, -- Each time Penance damages or heals, Entropic Rift is empowered, increasing its damage and size by 10%. After Entropic Rift ends it collapses, dealing 30,161 Shadow damage split amongst enemy targets within 15 yds.
    dark_energy                = {  94693, 451018, 1 }, -- While Entropic Void is active, you move 20% faster.
    darkening_horizon          = {  94695, 449912, 1 }, -- Void Blast increases the duration of Entropic Rift by 1.0 sec, up to a maximum of 3 sec.
    darkening_horizon_2        = {  94668, 449912, 1 }, -- Void Blast increases the duration of Entropic Rift by 1.0 sec, up to a maximum of 3 sec.
    depth_of_shadows           = { 100212, 451308, 1 }, -- Shadow Word: Death has a high chance to summon a Shadowfiend for 5 sec when damaging targets below 20% health.
    devour_matter              = {  94668, 451840, 1 }, -- Shadow Word: Death consumes absorb shields from your target, dealing up to 300% extra damage to them and granting you 1% mana if a shield was present.
    embrace_the_shadow         = {  94696, 451569, 1 }, -- You absorb 3% of all magic damage taken. Absorbing Shadow damage heals you for 100% of the amount absorbed.
    entropic_rift              = {  94684, 447444, 1 }, -- Mind Blast tears open an Entropic Rift that follows the enemy for 8 sec. Enemies caught in its path suffer 6,634 Shadow damage every 0.8 sec while within its reach.
    inner_quietus              = {  94670, 448278, 1 }, -- Power Word: Shield absorbs 20% additional damage.
    no_escape                  = {  94693, 451204, 1 }, -- Entropic Rift slows enemies by up to 70%, increased the closer they are to its center.
    void_blast                 = {  94703, 450405, 1 }, -- Entropic Rift upgrades Smite into Void Blast while it is active. Void Blast:
    void_empowerment           = {  94695, 450138, 1 }, -- Summoning an Entropic Rift extends the duration of your 5 shortest Atonements by 1 sec.
    void_infusion              = {  94669, 450612, 1 }, -- Atonement healing with Void Blast is 100% more effective.
    void_leech                 = {  94696, 451311, 1 }, -- Every 2 sec siphon an amount equal to 3% of your health from a nearby ally if they are higher health than you.
    voidheart                  = {  94692, 449880, 1 }, -- While Entropic Rift is active, your Atonement healing is increased by 10%.
    voidwraith                 = { 100212, 451234, 1 }, -- Transform your Shadowfiend into a Voidwraith that casts Void Flay from afar. Void Flay deals bonus damage to high health enemies, up to a maximum of 50% if they are full health.

    -- Archon
    concentrated_infusion      = {  94676, 453844, 1 }, -- Your Power Infusion effect grants you an additional 10% haste.
    divine_halo                = {  94702, 449806, 1 }, -- Halo now centers around you and returns to you after it reaches its maximum distance, healing allies and damaging enemies each time it passes through them.
    empowered_surges           = {  94688, 453799, 1 }, -- Increases the healing done by Flash Heals affected by Surge of Light by 30%.
    energy_compression         = {  94678, 449874, 1 }, -- Halo damage and healing is increased by 30%.
    energy_cycle               = {  94685, 453828, 1 }, -- Consuming Surge of Insanity has a 100% chance to conjure Shadowy Apparitions.
    heightened_alteration      = {  94680, 453729, 1 }, -- Increases the duration of Dispersion by 2 sec.
    incessant_screams          = {  94686, 453918, 1 }, -- Psychic Scream creates an image of you at your location. After 4 sec, the image will let out a Psychic Scream.
    manifested_power           = {  94699, 453783, 1 }, -- Creating a Halo grants Surge of Light.
    perfected_form             = {  94677, 453917, 1 }, -- Your damage dealt is increased by 10% while Dark Ascension is active and by 15% while Voidform is active.
    power_surge                = {  94697, 453109, 1 }, -- Casting Halo also causes you to create a Halo around you at 100% effectiveness every 5 sec for 10 sec. Additionally, the radius of Halo is increased by 10 yards.
    resonant_energy            = {  94681, 453845, 1 }, -- Allies healed by your Halo receive 2% increased healing from you for 8 sec, stacking up to 5 times.
    shock_pulse                = {  94686, 453852, 1 }, -- Halo damage reduces enemy movement speed by 5% for 5 sec, stacking up to 5 times.
    sustained_potency          = {  94678, 454001, 1 }, -- Creating a Halo extends the duration of Dark Ascension or Voidform by 1 sec. If Dark Ascension and Voidform are not active, up to 6 seconds is stored and applied the next time you gain Dark Ascension or Voidform.
    word_of_supremacy          = {  94680, 453726, 1 }, -- Power Word: Fortitude grants you an additional 5% stamina.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_faith       = 5481, -- (408853)
    catharsis            = 5486, -- (391297)
    driven_to_madness    =  106, -- (199259)
    improved_mass_dispel = 5636, -- (426438)
    mind_trauma          =  113, -- (199445)
    mindgames            = 5638, -- (375901) Assault an enemy's mind, dealing 20,233 Shadow damage and briefly reversing their perception of reality. For 7 sec, the next 39,207 damage they deal will heal their target, and the next 39,207 healing they deal will damage their target.
    phase_shift          = 5568, -- (408557)
    psyfiend             =  763, -- (211522) Summons a Psyfiend with 19,522 health for 12 sec beside you to attack the target at range with Psyflay.  Psyflay Deals up to 1% of the target's total health in Shadow damage every 0.8 sec. Also slows their movement speed by 50% and reduces healing received by 50%.
    thoughtsteal         = 5381, -- (316262) Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for 20 sec. Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
    void_volley          = 5447, -- (357711)
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
        id = 373183,
        duration = 30,
        max_stack = 2,
        copy = "harsh_discipline_ready"
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
    prayer_of_mending = {
        id = 41635,
        duration = 30,
        max_stack = 5
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
        max_stack = 3
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
        max_stack = 1,
        copy = 421454
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

spec:RegisterGear( "tier31", 207279, 207280, 207281, 207282, 207284, 217202, 217204, 217205, 217201, 217203 )


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
            if buff.harsh_discipline.up then return 0 end
            return 0.016 * ( buff.inner_light.up and 0.9 or 1 )
        end,
        spendType = "mana",

        startsCombat = true,
        texture = function() return buff.shadow_covenant.up and 1394892 or 237545 end,

        -- TODO: Could implement Heaven's Wrath if APL suggests breaking Penance channel.
        start = function ()
            removeBuff( "power_of_the_dark_side" )
            removeStack( "harsh_discipline" )
            if set_bonus.tier29_4pc > 0 then
                applyBuff( "shield_of_absolution" )
            end
            if talent.manipulation.enabled then
                reduceCooldown( "mindgames", 0.5 * talent.manipulation.rank )
            end
            if talent.painful_punishment.enabled then
                local swp = talent.purge_the_wicked.enabled and "purge_the_wicked" or "shadow_word_pain"
                if debuff[ swp ].up then
                    debuff[ swp ].expires = debuff[ swp ].expires + 1.5 * ( 3 + ( talent.castigation.enabled and 1 or 0 ) + ( buff.harsh_discipline.up and 3 or 0 ) )
                end
            end
            if talent.weal_and_woe.enabled then
                if buff.harsh_discipline.up then
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

            if talent.harsh_discipline.enabled then addStack( "harsh_discipline" ) end
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
            applyBuff( "rapture", nil, 3 )
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


spec:RegisterRanges( "penance", "smite", "dispel_magic" )

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

spec:RegisterPack( "Discipline", 20240730, [[Hekili:T3ZAZTnos(BjvQZwoJTIL8RmPCCv3nE2BsQz2n16C18nlrtszXlsKAjPIJVYL(TFOBacINKGuqoj3CB5DITiuJUB0VrtGBhD7NU9MOGY4B)7JpE8PhFXjhp84FE0jNE7nLpUk(2Bwfe(5G7j)sAWsY)96KIWKvlssXh94ISGiacfzRZdjF08YYvfV91V((KY5RVByy2YxxKSC9IGYKS0W8GzLWFh(6BV5U1jlkFF6T3zC6p52Bcwxopl)2BUjz5VqaCsuumD0XfH3EZVfhSioFZ0v5jz5jLjXfBMgKhVz61F8MJMLfUUioAZ0S0fpU5dB(aa7Jo(IJo543Uz6NMtg2Fgq(Y)jbltsV9MfjfLfiJiEwW6fLKF9VJmM40G7wehD7)bbDcbs42BcdwSyc9pMaFp63EcL7eMLTik7H0IBljeKceYwr4tXL1G6lb5jWtHFBXAY)8IntVB9SzdlFizrY9ZlNe)ViCPK7YtwVCY8Sfpojy5QHRxTz6EBM24GlMhqWd2WXzIHHLXtsZilEe87KoJFooFBM(0tBMw9ThwnLYyb9BqxoZtwrNXpXG9MP)AnW3mnPGsRjP3Vzk9lUzAuWsqUKqiN6rcrIl7azaJVheb81ejHZ6mjusK)tlhYy8HzFH8Tj)DfmeWYfzP3pPGmcf883Zam5gg7SccueTcmeu78oJAvAbmKBwsCAeNFISEvSwwgnmiDcH2IZnH1)Z4GicRRmJijugKxwlqutbRMhuGS1l6mUFSiIWqZIvXlwumjADoAgBYYGVca)ngaEquudaFS7a)N7mWPpy4YK0Oj3TiOGil814W1ez0YKLXUpZJoUltTdW0veuAzEfSucEuiFersijGlXhfK)5jeySEX9XKrmuquDKQrBN5Am0)HS8OjrXbLZ7dZthxnawbS1KdIVlXw0Ftf7hEWKaYA4YGO04IcLbLFFC5W5eVZKV(QqIY4LBMo(yKEn5WXj6fezUNqpf(HofaNWQHjVioHDrjFHeo0eWAKFWpjakGHMCs4egopyrMFqnkKeWjtEhMTidcCZkwnWIxGQ5EZ0Je87Ah)2m9GntF9MP3hgnKzOPIOi)5eZENha(uiUEfNRkpi05O(HuW)F(lxteSjCTntFhXZyb5xjbSscUCwLF8QV3dXaSYwVGOmKgdQeGBksOOiirh)LqWNPXFf8BHiYdeHryU3mL6pM(PXFLedYIys0QdgDgIJJgtXMrdpdXJXiIvW8esmxIH7QIrG)9S8sdG9cJq9OtgEItaEael0bOiWw6KnpEzqskH5yzb7xYwNwI8Uk4CyfBC9Y7GCaGfcc6C0SC6mgSyZuouRq8qIdhihHVeKSarga17UlCUyPKewtudmpM8MtyrjZudD8FC9)4T1YFtI)6Q4WsqqIg9493)iDXG5E81GZqGyjPbTKyt(qqAdj6am8OYKq4PrRdPY6bfvpjn6OeYhmllh4DpWPpPquQM(jSPBchuw5qtIxuqxH1SDuMt4mtYMnHKx3As8XI2rgBkOJoiez2iHQKuWIqiv0yqMGOYTCD4CQGrL(nX1x5CQaLQnbq3EEWxi)3W155e6beQ4stdjjtgZu1nJlu9POycpH4)HmSKzIaLo)WqEig)ay1ji9rv9oyeRYZilRL80meYFziYm7uyqTXcRfmKyMFupanEC)mXfEm)dWF0EmvxPq2CVDzo0C)Lw8DWHfAtACNcTYroqlbJiXD(JQbzK)udcboKHNYikbZaos(DksRUr(Tf7PeBa0jcw8qWJemJexiZU9SKCqL7M)8TxBK9OpfMyt6JIZeCKl1Pi(2HCPBIdZaVSadHvZQPpmpoTkMByHpagan6AIjbm8AQncgCjM5dsVxsDSzML3zP4p7Ha0wwa0zK9uGrmPmBc5XtGhDPBiYboLmcU(2P4L726RqsSHZb6HGzVISk1LuC)3JIyM4FGyJhCSubjW)dadcphaI4IAdZ)vK43gHeUPGY9pH7ePjgtMg9HWbmkeucbcVaJBJokQWnf0sI0dmXLzqEI4SHSduyXTXFjgtnxgM(Zi05KZZ5r43GQkyuCOI8Mq937Kdn8NA3OUHjxwHj6uJBaWZuakxAktbpjxApjCjbZRXHrm1sgNrFpIWXKjsXN3bJJi53PSn6g5BidFj6(3ip3i9IFrtek(GUsHUMNZ12cdoofsnOkDvQiMqQCQXhBjkyQC7xqofjY83ZMIOS09lRMPp9R1UxpSokLzbK8xiFN)lAAufljCS9lQCZMKLkgQoK3vCrmuY5am5HIYJiPta5aes4c5jzd5lu2k6HXGGTLcbrt6kUsjIBnuwhOoeKSq7vQAg2AerxRN0901mUPaCI)NQPkHhBJ2G6NWZpWG0(FJgGjlL)QkYuTeFhz953UgsJkE1rxvTqC0vfHZtkwE0vWZuYRgP5ELvLbuLXq4vTsc1FFdQdvYbG4k6GvS2gTMAO4YmxqtRCfOagwU2tmU)LRVRH14rIuEB115Fc51rOXS15Gzh1I8GOq33Ist5zAUUITNOjFOgxef3TQQDRaW5UVBK2NhuXySM8uXdrgZJGvYI)Ke28B3m9Ai4ySeGyEfyfKIllHkMrI4IqLzKSXYRlTqLLyCB0LsTa3pnS0cN0RyQvq6FuuamUZNpVka9kIjZSBHq5AT8fSXacpGedSAqeREl83GvX09H)f)6WJiYoPWhe8f4VajmyLlpmEfvBcYPDF6J)6QeyfupMEBBnJy2EfmGdQSvqxyG1rj3iWEb)5XmSjvcghyBJSGekO7K1j9ksUwxwApVQ)OoPqtk0mf9A9ymEhbvzzx9nrHDA)N9ifwvleH0dLlfItKGuncSVFXN2RT6UrQSh5HWkUdeWnZ4Bhxvzaqk8wUSTB7VyZY8TP3G8YofEKZ7oPcZwJwe3qspqeDVNTAOMvg2ghTOkeLJeJOG85ic19iG6C0e1kM2m5Wue3mv4p6s4e6cS8o050EvewZ49piXvCQXM96znUIt7vfcBKRlL(MJf(gltOO5T9nh6zl285DyYP9pCjVtwW2SkvxF5cDerdohnCZQDTjl19UzBoT)HO0cRWPairwaFKQeFs5g1T2WzNxDoOoKB4AHPyBa)NMdM3G)pzzCrszjuE(7a0Uiz5kOHFtcpeIeMyfG2xh3LblNwRWDgTSd89lM8RyHVj)YYSLyfKe3ASQAGdnrsr9xhAQ5He5jMnOmcsVm5)HLBBvzoGbUkROibmdXx8Sv7yOng4y9UVu3YoNmiPj6dS(XwnnAQgwUH)8Dl5SUxlRE5IffAT5HLPMq9WwPZqf)QCYMXYMQ7oBBsbdyaDkYTgPRFq8aF23(sBDwV2I(My69XtLTkdjA5wZBmznc6AOS1LfjrXuBDYJOwEusQJN)o0)s8e4H6IxcJSfR)nTLYdAkNEj3dTvdbCTz7Ij1tRnEjkcBmnh3c9Z6F5(AMt4wXaAPChwJVOP4hmgFWzBx8WBlD2XIE0GGE7184SU3UMg6mjxsTvNZO6CN2HuaszkAvp7dwOQhTvrgeL6FfW0NPFq8lEUXqHEw9lEE)dgXkBVpwF19mUoDbX6yl(9OQTCDtkei0PBfVuQjPSBT68E1DJ(Nh99GhQZ7FCuTXlCZ2TMpQ6TzgKBCXYnsh9pMd)qh9XhudUzoV)ro4c90AbiuZJQTffTYkGeXw8UpkwK96nGwZjPjIv0nPWZrms17DfIKVov(TswJcvB8eXWgK8WFxCAuCo(ozk8Qnd(JMaTmbIgQ(RDan40n)9rfNA(hR(wFkm31VbRWCR6ywJsxTgl7W84jpKe(54ijsTU9ub2n0aQrjXOlqYtogE7xEfKmIbOi1go8oRdsTG8C0rglvK84z5Xe29DqDEQhfd5iEiNTEXKvRttkMVmwCLqovMMgjfQgrtXE2Yu3q0NUUx6N6vB15gwEUqngI6LhbMGxwHeDwbmRVtxH0qZNXvi15gxHudXkuCV4Lsv2SbdPxlE2Mv1W(MtRjTrucDTJ4KAinU6RbNuSX6wL9aX2b(6ffpbhneM2qGZkBJtJnFPWRqyfwku7ra9uJYyRzzmKqwDkM3frxOgoGjTi3NntvsvHcv9xV1uOq25h4CxCiJE88dVq1r8wJDsISnKqTUXOQ3xHk7rNH2JCyBGBs3Swrq1b)wtPARdowmmBlfQU(7GKzniHTThHMDN59KCfcysIBRei1BS7MQNtSGe1ZTqZBql68Ha9fSiTbk43qcDlmB5Db1hUnCZoOHteIZYYltkxhP)1RpzBmC24yseqissr9PxyPnOHOnfL3OFv1A0qRMm(wwUkg6T3QxR6cwRpgYpdqOVx1fhs(nIjoCqWR1mWUA1xJFW9s9JyNoOROgRrtHVpqtuYPZCfTW5qbbiKMcQkJiVFEgS5IF89BQFN2FibsTxN1RUzVaNWU)mbN3vtTehDvwPo2u8yAiSnNuvekI8X3J1TRJteLdvhCG8Z5XiaBxilXMQXwJIeUXeYSSSWiwwser)mkTkGNLIzu1Qkvv4RDj64wYFPHO4LjIpsWqSR0G1Dmbn918M1QAU1)VKwmtw2VgmkLheLW7U6MSAVR5l4QwDUOgw1KyCYNVs)sfRYIPc7SpQ)iUVg(l2b3cHPhTN8jxv1cgpViCJJNq5yfdP9EiiJFIUp62I9DNIzsUZvqqfx62nX4d8KwP8MYRukPsBbcSdekBWKNlLx1ACVBnltCPTLiyAl((DbIiMU1Z203OY3yDLp7rB)mGzAkFJTQ81ur5Aqg03erlIzANTzAH(9CRniNfU2byMg(1ykBpd4kppqTtVSVrSY2t4QTxC1wezE(C)zJtVBDS5KCzBvhAxGcvMa1oJXEoMCfZBAhYv7oCyNlqVBDPuhNKAfjknCqyjfW8)96cwRlsFjQHCiZxNIB5ULdLjmHkSZzdUldpCMYsJsqJIgD0tpNP0vZKk3b7auYGQGYWglomDMTYOprC0IYxkJ7uXXHkbkd4mPP1u1Eiy6xIZXS4HZv5tgnA0Pdjro)qqo0Ege6fpeKtwUcpC4WtbS9zh(X7x1xZGb7ImOFAcwxMbN5DryNjNEFCXWnF43X2L5S3cP2KsMn8X7BUAf7tZE0YtR8pqg1GrF9aoShDSzGRSvaka3YgfOb8rnI51lJMX9h0oKm1MGXFJMaT(LqLbzRFk0MGtmpbC1gfaRTh6Aa8ulyCTYGkUQ)QQPbulIGGMJc0eFzX0aZ5YGjJeFfg9cRhy3FqJNzLhjyAehHHZRYd(3yBZufA5bq(6kqwti)Sz(H6XVNcVX2PZNkFAST1qFj1n2g(B4mPqLgA4yRqDAo5cplCBdGgJyxxN3Eu9UorEhZ5bWRaqTa71aOLLqVy4(uBEf2gJi2aAVzbNAX9shTkzdm9hVSSw7n13tFJNLoTbWEZcoZIBnVdqVR5F2U227zw8L2FwZ5pta0lMwo33ABNVRdr7CFllFUnrmVWFTiE1BBdNB3N72N(X5w8IPwcEfOBR32Cg8AnvM6eyTRZ(gmfxyXXPNyswb)Zaf4XPO5Cn3oX0lSzJXhASxy31MhWCl2A8dW3LvMObG7xp(xyXDNFOcF7C(IDP54gaUN55wc40puHftYEb4VXIPSTe4B(GHQfY7dI99r9c7TiNTAe2FaA3wTFfZSv(UEG5B(W7X1gamNv1NsWbxrrjW5HM)lBwYcE71umK3nG)07ETP()dGjBSKrOEN3Di8Az8oElbko0QAwrhsj9ot7WSvVRiU8q8DK5DVWPBFT9Ayymjw2102hE5MPUCNRr)wv36AnI00HkJ2oIop9K4UHauVZiO4LcxJOhmqxrobwQfuZH7bo7yd3mGm(y20coDoFbUzFsLFvHKNzlnc5tpzRjiTolfwR6Q8mEmHSEzLwxxbtquedm0V)q6Pq7qXxTTdtMXzO4t7loxpzJ3EqWW36DhtcNXL6QxYHD8CjWFucR1BZmB4wEVyfxGuh43bOWEvmh1QkSNwV5C54J9gclK9UzeT(ntWxtPTtFrrjeHEAYxtR2jyOW8HD3fOm8)FXJ5XlEm7lDc3lxWAfEx0XwT8W2TvTdE4k6o6MjZoTPD(kO5iQtFZA5yoPlW9OHT8T6cjZoPy)fHKXnsMDiVlqQ0cv3DZk3G0)fpfXq)4Kf1)cCjH1vdF6X7quVzrI09qF6syp1rZrFoei3a1pK16tx2uFrDaI0FSFbKOe7KeIvFxNrWSb2EjtRnUyx89ahiG)OVUm7OhAdh5pYS(6pNHFCtdoqfTETG5fQR9aMA86Xssqt75UlZ5XB3RNj2st0Tx4lhS3atrE(0tg75XlBF6oWAiU4sGZ30wEHblKLcBEEv75Vy97E17gPqdB)vQLVjtnbObwjhHZGtcLTNlJ7YXe5LbdgDKtq9OrhCGb(T0PrAlwApaSK7YCD5igM5YG3AScfdKo449XYytPmz8WSr2cGH7dlhSj(BysrEa7nM5L8DyLm(kETw5aI(xNlQQMwoy96DtXxBO0JnM1LwCrMx0p4QkVwAx2vkHUJlxE)IFYoxr7yh0HYqYi6FsYtS(vDfsk7UtfWost16CSCFbvm(YMwILxDmRkVnEu)1XmvlwFhdhg1CvHziV8AHEu56583uy58bPFutIb4XscChDTl1YYv1fiHmjBhL)PXFBfVeX3V7eTEjScG51SZU6J6f7riYbZ5RnyGAnv3RP9KeIWr7l8c1nA8Gd0lq8vVB8X8mr3MRIOTLpyDFaSHWTEah(CIr7zB)kudXBNE3aTnuC3k1UzbjDrUTbJARk8BpoWoMFA0tVPdXN6AJiBxUIC4kum5sFFr70cxTw49hkpjgq7VhDO46LCZ2qTsbu28weAAd)4LxytxplFFMq6oT9Lvut92l23RFgpqDUVjOMmevVdm)FMBKMMTUwZsnLSPUZwJvvQkSFd1Wr46UXNLts2iPQCHCIQsvX)5)gFXbzAeB(HZvGmw)9ONGVVVTv2cwChSKBQQ)dun8XnfAo5LDSdRDcv28guS1x0jBpz1ygmg8lTTPt5xuYA(uT5Sbrblb0x77UTa5LjMouOEJNb8)Oy11eE)JHDxFCxESvmNTYwcSpPg0i3nwe3H0rhTjkFho4d0Udgy8InppHuMkAuJ33f(cTClrMMn6kmzwm7A6MZqXERkgloLkxbf0zMFwRkGWkBj1Es295xcgBu6WjZGh61rAZOlAUR(J3J)zY9UERiED)1lcy(N6cCvFxlfybQpI3xgatLDCvE1GJhEYRA8qQeAOJxWolmjHZjCqycFoBQcuFBjRd8t)z7nOP72Il3U(Sc)FICirZxaUaCOx0lwKkK25SiTj0RSizrF6(KkYCuuHSXtrd842uy5lk8MPWQXQHTEqP30fkvGvtJ712ndXE24sxYB0xbfj2Ml6oHW(gmoj5N)gKl31F8gs8y)oeUfXe9d5b0JrB9nRgQUIsqkSE3g968y2AW1ZNJ5abIRjOyEvdGtWFOCmXB07kzC)0lO1cdysfq7hq7uH8ySnLdsIGyjkHqXoKnzldGEOcFfDa4tdIeabV2r3fFFskThiGPjOcJdFmeQXe2EVeFly9CGPbwEjJEOQSggmAXeKUewFX)EsnzAvEWT1N6VJkKO5f4(kn)7CqJB8MN1quscs10eT)5aRtN9kh2MczJIBjxOXu4fNhyRzC0MIySdUJucFlntAcV7JfzlcKZyCRxG866bQXY6Zfxot25F3H8GFSemqLFPE793YuPFeUdZwtDgZL8tcE3X((J0iR08P0E90Zd1IPsqdmusosAmkVHEspRsuFWledrK2Cvex96FyD4DLvVuQKajWsalD8rF17oX8mQPX4Xjwa2wNFJly9cjGK7LdIsigkDvn3LcmUiAsZVPuyfSb3lQRIfBHlkg4H)b)ouSC83yXslZV7RVBhQz3mIwKR7wjijN5n5zENm7wy3ELUT5STLE8TvM12HvUiaSlMb)Os)mO82bbMTBI6P8Hn38Q5N0pKJ6uZcpaI3B7bnb)975QDJUOArHQn1bhLgAvU0Usrd8AmGWxcXaYpxtG9Xz7VZXQNt(rMcNQWWFft)rO4JX0dFd2jHIQmQWrxHeCRbGGv2ob1xIBsuupVTVmJvY3RwnKVxf(vx6lldyp1xdTwpQpyQdMV7WSH2Lm01YThwna1VMVmds(LfMDO(0t1LLY49r2v8SOU9gIoBiCOWFoEUVF7)7d]] )