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
    cauterizing_shadows        = {  82687, 459990, 1 }, -- When your Shadow Word: Pain or Purge the Wicked expires or is refreshed with less than 5 sec remaining, a nearby ally within 40 yards is healed for 30,400.
    crystalline_reflection     = {  82681, 373457, 2 }, -- Power Word: Shield instantly heals the target for 5,165 and reflects 10% of damage absorbed.
    death_and_madness          = {  82711, 321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below 20% health, its cooldown is reset. Cannot occur more than once every 10 sec.
    dispel_magic               = {  82715,    528, 1 }, -- Dispels Magic on the enemy target, removing 1 beneficial Magic effect.
    divine_star                = {  82682, 110744, 1 }, -- Throw a Divine Star forward 27 yds, healing allies in its path for 8,867 and dealing 8,264 Holy damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond 6 targets.
    dominate_mind              = {  82710, 205364, 1 }, -- Controls a mind up to 1 level above yours for 30 sec while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings or players. This spell shares diminishing returns with other disorienting effects.
    essence_devourer           = {  82674, 415479, 1 }, -- Attacks from your Shadowfiend siphon life from enemies, healing a nearby injured ally for 22,800. Attacks from your Mindbender siphon life from enemies, healing a nearby injured ally for 7,600.
    focused_mending            = {  82719, 372354, 1 }, -- Prayer of Mending does 45% increased healing to the initial target.
    from_darkness_comes_light  = {  82707, 390615, 1 }, -- Each time Shadow Word: Pain or Purge the Wicked deals damage, the healing of your next Flash Heal is increased by 3%, up to a maximum of 60%.
    halo                       = {  82682, 120517, 1 }, -- Creates a ring of Holy energy around you that quickly expands to a 30 yd radius, healing allies for 20,393 and dealing 21,281 Holy damage to enemies. Healing reduced beyond 6 targets.
    holy_nova                  = {  82701, 132157, 1 }, -- An explosion of holy light around you deals up to 6,043 Holy damage to enemies and up to 3,990 healing to allies within 12 yds, reduced if there are more than 5 targets.
    improved_fade              = {  82686, 390670, 2 }, -- Reduces the cooldown of Fade by 5 sec.
    improved_flash_heal        = {  82714, 393870, 1 }, -- Increases healing done by Flash Heal by 15%.
    improved_purify            = {  82705, 390632, 1 }, -- Purify additionally removes all Disease effects.
    inspiration                = {  82696, 390676, 1 }, -- Reduces your target's physical damage taken by 5% for 15 sec after a critical heal with Flash Heal or Penance.
    leap_of_faith              = {  82716,  73325, 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    lights_inspiration         = {  82679, 373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by 8%.
    manipulation               = {  82672, 459985, 1 }, -- You take 2% less damage from enemies affected by your Shadow Word: Pain or Purge the Wicked.
    mass_dispel                = {  82699,  32375, 1 }, -- Dispels magic in a 15 yard radius, removing all harmful Magic from 5 friendly targets and 1 beneficial Magic effect from 5 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mental_agility             = {  82698, 341167, 1 }, -- Reduces the mana cost of Purify and Mass Dispel by 50% and Dispel Magic by 10%.
    mind_control               = {  82710,    605, 1 }, -- Controls a mind up to 1 level above yours for 30 sec. Does not work versus Demonic, Undead, or Mechanical beings. Shares diminishing returns with other disorienting effects.
    move_with_grace            = {  82702, 390620, 1 }, -- Reduces the cooldown of Leap of Faith by 30 sec.
    petrifying_scream          = {  82695,  55676, 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear.
    phantasm                   = {  82556, 108942, 1 }, -- Activating Fade removes all snare effects.
    phantom_reach              = {  82673, 459559, 1 }, -- Increases the range of most spells by 15%.
    power_infusion             = {  82694,  10060, 1 }, -- Infuses the target with power for 15 sec, increasing haste by 20%. Can only be cast on players.
    power_word_life            = {  82676, 373481, 1 }, -- A word of holy power that heals the target for 131,103. Only usable if the target is below 35% health.
    prayer_of_mending          = {  82718,  33076, 1 }, -- Places a ward on an ally that heals them for 7,727 the next time they take damage, and then jumps to another ally within 30 yds. Jumps up to 4 times and lasts 30 sec after each jump.
    protective_light           = {  82707, 193063, 1 }, -- Casting Flash Heal on yourself reduces all damage you take by 10% for 10 sec.
    psychic_voice              = {  82695, 196704, 1 }, -- Reduces the cooldown of Psychic Scream by 15 sec.
    renew                      = {  82717,    139, 1 }, -- Fill the target with faith in the light, healing for 36,720 over 15 sec.
    rhapsody                   = {  82700, 390622, 1 }, -- Every 1 sec, the damage of your next Holy Nova is increased by 12% and its healing is increased by 20%. Stacks up to 20 times.
    sanguine_teachings         = {  82691, 373218, 1 }, -- Increases your Leech by 4%.
    sanlayn                    = {  82690, 199855, 1 }, --  Sanguine Teachings Sanguine Teachings grants an additional 2% Leech.  Vampiric Embrace Reduces the cooldown of Vampiric Embrace by 30 sec, increases its healing done by 25%.
    shackle_undead             = {  82693,   9484, 1 }, -- Shackles the target undead enemy for 50 sec, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shadow_word_death          = {  82712,  32379, 1 }, -- A word of dark binding that inflicts 12,544 Shadow damage to your target. If your target is not killed by Shadow Word: Death, you take backlash damage equal to 5% of your maximum health. Damage increased by 150% to targets below 20% health.
    shadowfiend                = {  82713,  34433, 1 }, -- Summons a shadowy fiend to attack the target for 15 sec. Generates 0.5% Mana each time the Shadowfiend attacks.
    sheer_terror               = {  82708, 390919, 1 }, -- Increases the amount of damage required to break your Psychic Scream by 75%.
    spell_warding              = {  82720, 390667, 1 }, -- Reduces all magic damage taken by 3%.
    surge_of_light             = {  82677, 109186, 1 }, -- Your healing spells and Smite have a 8% chance to make your next Flash Heal instant and cost no mana. Stacks to 2.
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

    -- Discipline
    abyssal_reverie            = {  82583, 373054, 2 }, -- Atonement heals for 10% more when activated by Shadow spells.
    aegis_of_wrath             = {  86730, 238135, 1 }, -- Power Word: Shield absorbs 30% additional damage, but the absorb amount decays by 3% every 1 sec.
    atonement                  = {  82594,  81749, 1 }, -- Power Word: Shield, Flash Heal, Renew, Power Word: Radiance, and Power Word: Life apply Atonement to your target for 15 sec. Your spell damage heals all targets affected by Atonement for 35% of the damage done. Healing increased by 100% when not in a raid.
    blaze_of_light             = {  82568, 215768, 2 }, -- The damage of Smite and Penance is increased by 8%, and Penance increases or decreases your target's movement speed by 25% for 2 sec.
    borrowed_time              = {  82600, 390691, 2 }, -- Casting Power Word: Shield increases your Haste by 4% for 4 sec.
    bright_pupil               = {  82591, 390684, 1 }, -- Reduces the cooldown of Power Word: Radiance by 3 sec.
    castigation                = {  82577, 193134, 1 }, -- Penance fires one additional bolt of holy light over its duration.
    contrition                 = {  82599, 197419, 1 }, -- When you heal with Penance, everyone with your Atonement is healed for 2,302.
    dark_indulgence            = {  82596, 372972, 1 }, -- Mind Blast has a 100% chance to grant Power of the Dark Side and its mana cost is reduced by 40%.
    divine_aegis               = {  82602,  47515, 1 }, -- Critical heals create a protective shield on the target, absorbing 5% of the amount healed. Lasts 15 sec. Critical heals with Power Word: Shield absorb 10% additional damage.
    enduring_luminescence      = {  82591, 390685, 1 }, -- Reduces the cast time of Power Word: Radiance by 30% and causes it to apply Atonement at an additional 10% of its normal duration.
    evangelism                 = {  82567, 246287, 1 }, -- Extends the duration of all of your active Atonements by 6 sec.
    exaltation                 = {  82576, 373042, 1 }, -- Rapture enhances 2 additional shields.
    expiation                  = {  82585, 390832, 2 }, -- Increases the damage of Mind Blast and Shadow Word: Death by 10%. Mind Blast and Shadow Word: Death consume 3 sec of Shadow Word: Pain or Purge the Wicked, instantly dealing that damage.
    harsh_discipline           = {  82572, 373180, 2 }, -- Power Word: Radiance causes your next Penance to fire 3 additional bolts, stacking up to 2 times.
    heavens_wrath              = {  82574, 421558, 1 }, -- Each Penance bolt you fire reduces the cooldown of Ultimate Penitence by 2 sec.
    indemnity                  = {  82576, 373049, 1 }, -- Atonements granted by Power Word: Shield last an additional 3 sec.
    inescapable_torment        = {  82586, 373427, 1 }, -- Penance, Mind Blast and Shadow Word: Death cause your Mindbender or Shadowfiend to teleport behind your target, slashing up to 5 nearby enemies for 17,424 Shadow damage and extending its duration by 0.7 sec.
    lenience                   = {  82567, 238063, 1 }, -- Atonement reduces damage taken by 3%.
    lights_promise             = {  82592, 322115, 1 }, -- Power Word: Radiance gains an additional charge.
    luminous_barrier           = {  82564, 271466, 1 }, -- Create a shield on all allies within 40 yards, absorbing 121,395 damage on each of them for 10 sec. Absorption decreased beyond 5 targets.
    malicious_intent           = {  82580, 372969, 1 }, -- Increases the duration of Schism by 6 sec.
    mindbender                 = {  82584, 123040, 1 }, -- Summons a Mindbender to attack the target for 12 sec. Generates 0.2% Mana each time the Mindbender attacks.
    overloaded_with_light      = {  82573, 421557, 1 }, -- Ultimate Penitence emits an explosion of light, healing up to 10 allies around you for 22,800 and applying Atonement at 50% of normal duration.
    pain_and_suffering         = {  82578, 390689, 2 }, -- Increases the damage of Shadow Word: Pain and Purge the Wicked by 8%.
    pain_suppression           = {  82587,  33206, 1 }, -- Reduces all damage taken by a friendly target by 40% for 8 sec. Castable while stunned.
    pain_transformation        = {  82588, 372991, 1 }, -- Pain Suppression also heals your target for 15% of their maximum health and applies Atonement.
    painful_punishment         = {  82597, 390686, 1 }, -- Each Penance bolt extends the duration of Shadow Word: Pain and Purge the Wicked on enemies hit by 1.5 sec.
    power_of_the_dark_side     = {  82595, 198068, 1 }, -- Shadow Word: Pain and Purge the Wicked have a chance to empower your next Penance with Shadow, increasing its effectiveness by 50%.
    power_word_barrier         = {  82564,  62618, 1 }, -- Summons a holy barrier to protect all allies at the target location for 10 sec, reducing all damage taken by 20% and preventing damage from delaying spellcasting.
    power_word_radiance        = {  82593, 194509, 1 }, -- A burst of light heals the target and 4 injured allies within 30 yards for 57,052, and applies Atonement for 60% of its normal duration.
    protector_of_the_frail     = {  82588, 373035, 1 }, -- Pain Suppression gains an additional charge. Power Word: Shield reduces the cooldown of Pain Suppression by 3 sec.
    purge_the_wicked           = {  82590, 204197, 1 }, -- Cleanses the target with fire, causing 5,154 Radiant damage and an additional 35,769 Radiant damage over 20 sec. Spreads to 2 nearby enemies when you cast Penance on the target.
    rapture                    = {  82598,  47536, 1 }, -- Immediately Power Word: Shield your target, and your next 3 Power Word: Shields have no cooldown and absorb 80% additional damage.
    revel_in_purity            = {  82566, 373003, 1 }, -- Purge the Wicked deals 5% additional damage and spreads to 1 additional target when casting Penance.
    sanctuary                  = {  92225, 231682, 1 }, -- Smite prevents the next 9,838 damage dealt by the enemy.
    schism                     = {  82579, 424509, 1 }, -- Mind Blast fractures the enemy's mind, increasing your spell damage to the target by 10% for 15 sec.
    shadow_covenant            = {  82581, 314867, 1 }, -- Casting Shadowfiend enters you into a shadowy pact, transforming Halo, Divine Star, and Penance into Shadow spells and increasing the damage and healing of your Shadow spells by 35% while active.
    shield_discipline          = {  82589, 197045, 1 }, -- When your Power Word: Shield is completely absorbed, you restore 0.5% of your maximum mana.
    train_of_thought           = {  82601, 390693, 1 }, -- Flash Heal and Renew casts reduce the cooldown of Power Word: Shield by 1.0 sec. Smite reduces the cooldown of Penance by 0.5 sec.
    twilight_corruption        = {  82582, 373065, 1 }, -- Shadow Covenant increases Shadow spell damage and healing by an additional 10%.
    twilight_equilibrium       = {  82571, 390705, 1 }, -- Your damaging Shadow spells increase the damage of your next Holy spell cast within 6 sec by 15%. Your damaging Holy spells increase the damage of your next Shadow spell cast within 6 sec by 15%.
    ultimate_penitence         = {  82575, 421453, 1 }, -- Ascend into the air and unleash a massive barrage of Penance bolts, causing 354,339 Holy damage to enemies or 1 million healing to allies over 4.8 sec. While ascended, gain a shield for 50% of your health. In addition, you are unaffected by knockbacks or crowd control effects.
    void_summoner              = {  82570, 390770, 1 }, -- Your Smite, Mind Blast, and Penance casts reduce the cooldown of Shadowfiend by 4.0 sec.
    weal_and_woe               = {  82569, 390786, 1 }, -- Your Penance bolts increase the damage of your next Smite by 20%, or the absorb of your next Power Word: Shield by 10%. Stacks up to 8 times.

    -- Oracle
    assured_safety             = {  94691, 440766, 1 }, -- Power Word: Shield casts apply 4 stacks of Prayer of Mending to your target.
    clairvoyance               = {  94687, 428940, 1 }, -- Casting Premonition of Solace invokes Clairvoyance, expanding your mind and opening up all possibilities of the future.  Premonition of Clairvoyance Grants Premonition of Insight, Piety, and Solace at 100% effectiveness.
    desperate_measures         = {  94690, 458718, 1 }, -- Desperate Prayer lasts an additional 10 sec. Angelic Bulwark's absorption effect is increased by 15% of your maximum health.
    divine_feathers            = {  94675, 440670, 1 }, -- Your Angelic Feathers increase movement speed by an additional 10%. When an ally walks through your Angelic Feather, you are also granted 100% of its effect.
    divine_providence          = {  94673, 440742, 1 }, -- Premonition gains an additional charge.
    fatebender                 = {  94700, 440743, 1 }, -- Increases the effects of Premonition by 40%.
    foreseen_circumstances     = {  94689, 440738, 1 }, -- Pain Suppression reduces damage taken by an additional 10%.
    miraculous_recovery        = {  94679, 440674, 1 }, -- Reduces the cooldown of Power Word: Life by 3 sec and allows it to be usable on targets below 50% health.
    perfect_vision             = {  94700, 440661, 1 }, -- Reduces the cooldown of Premonition by 15 sec.
    preemptive_care            = {  94674, 440671, 1 }, -- Increases the duration of Atonement by 3 sec and the duration of Renew by 3 sec.
    premonition                = {  94683, 428924, 1, "oracle" }, -- Gain access to a spell that gives you an advantage against your fate. Premonition rotates to the next spell when cast.  Premonition of Insight Reduces the cooldown of your next 3 spell casts by 7 sec.  Premonition of Piety Increases your healing done by 15% and causes 70% of overhealing on players to be redistributed to up to 4 nearby allies for 15 sec.  Premonition of Solace Your next single target healing spell grants your target a shield that absorbs 301,473 damage and reduces their damage taken by 15% for 15 sec.
    preventive_measures        = {  94698, 440662, 1 }, -- Power Word: Shield absorbs 40% additional damage. All damage dealt by Penance, Smite and Holy Nova increased by 40%.
    prophets_will              = {  94690, 433905, 1 }, -- Your Flash Heal and Power Word: Shield are 30% more effective when cast on yourself.
    save_the_day               = {  94675, 440669, 1 }, -- For 6 sec after casting Leap of Faith you may cast it a second time for free, ignoring its cooldown.
    waste_no_time              = {  94679, 440681, 1 }, -- Premonition causes your next Power Word: Radiance cast to be instant and cost 15% less mana.

    -- Voidweaver
    collapsing_void            = {  94694, 448403, 1 }, -- Each time Penance damages or heals, Entropic Rift is empowered, increasing its damage and size by 10%. After Entropic Rift ends it collapses, dealing 40,259 Shadow damage split amongst enemy targets within 15 yds.
    dark_energy                = {  94693, 451018, 1 }, -- While Entropic Rift is active, you move 20% faster.
    darkening_horizon          = {  94668, 449912, 1 }, -- Void Blast increases the duration of Entropic Rift by 1.0 sec, up to a maximum of 3 sec.
    depth_of_shadows           = { 100212, 451308, 1 }, -- Shadow Word: Death has a high chance to summon a Shadowfiend for 5 sec when damaging targets below 20% health.
    devour_matter              = {  94668, 451840, 1 }, -- Shadow Word: Death consumes absorb shields from your target, dealing 37,633 extra damage to them and granting you 1% mana if a shield was present.
    embrace_the_shadow         = {  94696, 451569, 1 }, -- You absorb 3% of all magic damage taken. Absorbing Shadow damage heals you for 100% of the amount absorbed.
    entropic_rift              = {  94684, 447444, 1, "voidweaver" }, -- Mind Blast tears open an Entropic Rift that follows the enemy for 8 sec. Enemies caught in its path suffer 6,110 Shadow damage every 0.8 sec while within its reach.
    inner_quietus              = {  94670, 448278, 1 }, -- Power Word: Shield absorbs 20% additional damage.
    no_escape                  = {  94693, 451204, 1 }, -- Entropic Rift slows enemies by up to 70%, increased the closer they are to its center.
    void_blast                 = {  94703, 450405, 1 }, -- Entropic Rift upgrades Smite into Void Blast while it is active. Void Blast: Sends a blast of cosmic void energy at the enemy, causing 12,175 Shadow damage.
    void_empowerment           = {  94695, 450138, 1 }, -- Summoning an Entropic Rift extends the duration of your 5 shortest Atonements by 1 sec.
    void_infusion              = {  94669, 450612, 1 }, -- Atonement healing with Void Blast is 100% more effective.
    void_leech                 = {  94696, 451311, 1 }, -- Every 2 sec siphon an amount equal to 3% of your health from an ally within 40 yds if they are higher health than you.
    voidheart                  = {  94692, 449880, 1 }, -- While Entropic Rift is active, your Atonement healing is increased by 20%.
    voidwraith                 = { 100212, 451234, 1 }, -- Transform your Shadowfiend or Mindbender into a Voidwraith. Voidwraith Summon a Voidwraith for 15 sec that casts Void Flay from afar. Void Flay deals bonus damage to high health enemies, up to a maximum of 50% if they are full health. Generates 0.5% Mana each time the Voidwraith attacks.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_faith         = 5480, -- (408853) Leap of Faith also pulls the spirit of the 3 furthest allies within 40 yards and shields you and the affected allies for 92,238.
    archangel              =  123, -- (197862) Refreshes the duration of your Atonement on all allies when cast. Increases your healing and absorption effects by 20% for 15 sec.
    catharsis              = 5487, -- (391297) 15% of all damage you take is stored. The stored amount cannot exceed 12% of your maximum health. The initial damage of your next Purge the Wicked deals this stored damage to your target.
    dark_archangel         =  126, -- (197871) Increases your damage, and the damage of all allies with your Atonement by 15% for 8 sec.
    improved_mass_dispel   = 5635, -- (426438) Reduces the cooldown of Mass Dispel by 60 sec.
    inner_light_and_shadow = 5416, -- (356085) Inner Light: Healing spells cost 10% less mana. Inner Shadow: Spell damage and Atonement healing increased by 10%. Activate to swap from one effect to the other, incurring a 6 sec cooldown.
    mindgames              = 5640, -- (375901) Assault an enemy's mind, dealing 44,273 Shadow damage and briefly reversing their perception of reality. For 7 sec, the next 92,237 damage they deal will heal their target, and the next 92,237 healing they deal will damage their target.
    phase_shift            = 5570, -- (408557) Step into the shadows when you cast Fade, avoiding all attacks and spells for 1 sec. Interrupt effects are not affected by Phase Shift.
    purification           =  100, -- (196439)
    strength_of_soul       =  111, -- (197535)
    thoughtsteal           =  855, -- (316262) Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for 20 sec. Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
    trinity                =  109, -- (214205)
    ultimate_radiance      =  114, -- (236499)
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
    from_darkness_comes_light = {
        id = 390617,
        duration = 30,
        max_stack = 20
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


-- The War Within
spec:RegisterGear( "tww1", 212084, 212083, 212081, 212086, 212082 )
spec:RegisterAuras( {
    darkness_from_light = {
        id = 455033,
        duration = 30,
        max_stack = 3
    }
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


local entropic_rift_expires = 0
local er_extensions = 0

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, _, _, _, _, _, _, _, spellID )
    if sourceGUID ~= GUID then return end

    if ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" ) and spellID == 450193 then
        entropic_rift_expires = GetTime() + 8 -- Assuming it will re-refresh from VT ticks and be caught by SPELL_AURA_REFRESH.
        er_extensions = 0
        return

    elseif state.talent.darkening_horizon.enabled and subtype == "SPELL_CAST_SUCCESS" and er_extensions < 3 and spellID == 450405 and entropic_rift_expires > GetTime() then
        entropic_rift_expires = entropic_rift_expires + 1
        er_extensions = er_extensions + 1
    end

end, false )

spec:RegisterStateExpr( "rift_extensions", function()
    return er_extensions
end )


spec:RegisterHook( "reset_precast", function ()
    if buff.voidheart.up then
        applyBuff( "entropic_rift", buff.voidheart.remains )
    elseif entropic_rift_expires > query_time then
        applyBuff( "entropic_rift", entropic_rift_expires - query_time )
    end

    rift_extensions = nil
end )

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
            if talent.entropic_rift.enabled then
                applyBuff( "entropic_rift" )
                if talent.voidheart.enabled then applyBuff( "voidheart" ) end
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

            if talent.pain_transformation.enabled then
                gain( 0.15 * health.max, "health" )
                applyBuff( "atonement" )
            end
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
            if set_bonus.tww1 >= 4 then
                addStack( "darkness_from_light" )
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

        toggle = "cooldowns",
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
        cooldown = function() return 18 - ( 3 * talent.bright_pupil.rank ) end,
        recharge = function() if talent.lights_promise.enabled then return 18 - ( 3 * talent.bright_pupil.rank ) end end,
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

    power_word_shield = {
        id = 17,
        cast = 0,
        cooldown = function() return buff.rapture.up and 0 or 7.5 end,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 135940,

        handler = function ()
            applyBuff( "power_word_shield" )
            removeStack( "rapture" )

            removeBuff( "darkness_from_light" ) -- Tww season 1 set

            if talent.body_and_soul.enabled then
                applyBuff( "body_and_soul" )
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
        id = function() return state.spec.discipline and talent.void_blast.enabled and buff.entropic_rift.up and 450215 or 585 end,
        known = 585,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",
        damage = 1,

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        texture = function()
            return buff.entropic_rift.up and 4914668 or 135924
        end,

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

            if set_bonus.tww1 >= 4 then
                addStack( "darkness_from_light" )
            end

            if talent.darkening_horizon.enabled and rift_extensions < 3 then
                buff.entropic_rift.expires = buff.entropic_rift.expires + 1
                if buff.voidheart.up then buff.voidheart.expires = buff.voidheart.expires + 1 end
                rift_extensions = rift_extensions + 1
            end
        end,

        copy = { 585, "void_blast", 450215, 450405, 450983 }
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

    potion = "tempered_potion",

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

spec:RegisterPack( "Discipline", 20240811, [[Hekili:T3ZAZTnos(Bj1uNTCgBfB5xzt54QUBYU3KuZmBQ15Q5BwIwKYIxKi1ssfhFLl9B)q3aeeVjifKtYT3wzZeBc2O7g9B0e42tU9t3EtCuvYT)XOJhD2XV(Ktgs(Rxp6YBVP6Xvj3EZQOPFo6EY)ilAj5VFxA500vlsZWh94I8OyaeL5RlMs(vZRQwv(Mx9Q7tRMV(UHtZx(QY0LRxevLMNnTiAwf8ZtF1T3C360fvVp727KM)lp94BVjAD188IBV5M0L)cbKPXXj0XLuo92B(1KOfjfBMSQinViTknPCZKOIKntE3hV5Oz5txxMeVzsE2Ih38HnFaG6rhF5rNE8B2m5tZjd7pJiV8FsWV0SBVzrAzvjYdsMfTErf5F(hipjjl6UfjX3(FqqNPaYF7ntJwSym9hgdVh9Tht5ltZZxeN)qw5Tvesrbc5RiCOKQgq9LOIu4PW)AXAY)5fBMC36zZgw9q6I07Nxno5Fs4pP3vKUE5455lECC0YvdxVAZK92mX5GlNhrWd2WXzIHHvjJZYjlBe870oJFEoFBM80tBMu)2dRNszSG(g0LZI0v0z8tmyVzYFTb4BMKwsP10S73mH(IBMehTeKijeYzbKqK4YEqgW47braVMijCENjHkI8Fw1qgJFA(xiVn5NRHHawUip7(XLKrOGN)woGj3WyN1qGIO1GHGAx0zuRwlGHCZstYI58tK1RI1YYOtJYgtOTKcty9)ijkMW6QYjscvrfvncenuWQ5rLiB9YoJ7hlIim0SCvYIfLJJxxGgWgVm6RaWFTbGhfh7a4J8h4)LodC6dgUmnlE8DlIkjYcFnz6AImAv6Ye)N5toUltThW0xeuAzEfSuc(si)kIKqAexIpoQ4ZJjWy9I7tiJyOGO6jQgT9MRXq)hYlIhhNevnVpmpDC1ayfWwtoi(UeBr)n1SF4bJJiRHlJIZsklvguX9jvdNt8otE9vtjkJxTzYOJr61KdhVOxqK5Ec9ugg6uaCcRgM8I4f2fN(fsGqJbRrHb)KaOagAYjHxy48Of5Hb1OqsaNm5Dy2ICiWnRy1alEbQN7ntosWVRD8BZKd2m5vBMC)04Hmdn1ef5hhB278aWNcX1R4Cv7bHohnpKc()ZF5DebBcxBZK3s8mws(NKqvjbxoR2pE979qcaR81likdzjGkb4MIekkcs0XFfe8zwYxb)wiI8aryeM7ntO(JP)2KVsIbzrcjA1bNCoIJNmIInNm8CepgHiwjZtiXCjgURkgb(3ZlQma2lnc1JoD4PEb4bqSqhGIaBPt2IKLrPzeMJLfSFjFDwfY7QHZH1SX1lVdYbawiiOZrZkOZy0Int4qTgXNsC4a5i8LO0fiYaOE3DHZflLKWCrnW8yYBoHfLoZGkwvbbaJZNnMK(ZAsyKMcPl5RRsMwLepM5MCCrs8AokxhRHfIyCYIs6IGCyR)9393FtJS)465OoY17V)rQGaBoFf4igy0KuWws8hCiiPJm8im0SQ0PWtz4f53ww)KS4Jsj)Iz5fW62dyUsMc6OdcrMnsOkjfTykKeAcitqu5wUE6CQGrT(nX1x1CQaLQnbq3EE0xi)901ffKfkqOIlnnKKmzctv3mUq1NItil2e)pKHLoteO05hgYdj4Va4qrzpQQ3bJyvroH1wXtZqi)LHiZStHb1glSrEsIz(r9a04X9ZKq4X8pa)J2JP6kLYM7TlAJM7VYIVdoSqBsJ6uOvEYbAjyejUZVxpiJ8NgqiWHm8ugrjOk6j53PiT6g53wSNsSbqNiAXdrpsWmsCHm72ZslavUB(Z38oJSh9PWeBsFuCMGNCPofX3oKlDtY0CWllWqy1SAYdZtYQJ5gw4JGbqJUMysadVMAJGbxIP2OS7LuhDZScolf)ZEiaTLfaDgzpfyeJRYhtE8y4rx5hICGxjJGRVDkE5UT(kKe705a9qWSxswL6skU)7XXmt8pqSXdowQHe4)bGbHNdarCr1X8Fnj(Ttqc3uq5HNW9I0eJjtJ(q4agfIQGaHxGXTrhfv4McAjr6bM4YmipwC2q2bkS434VcJPMldt)ZjOZjVNZJW3GQkyuCOM8gt937Ldn8pnUr9dtUQgt0Pg)aqGPauU0uMcbsU0Es4scMVdhgXulzCg99ichtMifFEhmoIKFNY2OBKVHm8LO7FL8CJ0l(IMiu8bDLc7uEogk)UPCDOjutsNItZ2QFGX4jTfnorO8AU8D5scYPW)SK4HLSNENTa7tYGS4QtaNQ0iKCQAe)wIRNIPFbXDsUgVNnfX5z7xvptF6V2eWWHnXDnlIGWK35)IMCgsQ7xwh4aYlAs(aYMlPmbkIEeMouz1rKeKGSAMsyYfP5yggN2901mUPa8vSFUzPq4X2kzfu)eE(bgK2)B0amzP8xxrMAgYDeQ5xFhKgvYQJUUw65ORlNopTC5rxdptj3wKM7vwvgqvgdHx1kju)9oeEQfEHfx0bRyTnAn1qrvqU2Hw5kqTcSCTNAC)lxFNJ14teP82QRZ)aYRJqJ5RlaZoQf5brHUVfLMYZ0CDfBprt(qnUikUBv17wbGZDF3iTppOIXin5PYhInMhbRKf)jjS53SzY7GGJXsaI5vGvXjPQcQygjIlcvMtYgROP0c12TWTrxk1cC)0Ok(9kMAfK(hffaJ785ZRcqVIyYm7wiuUwlFbBmGWdiXaRgeXQ3a)myvmBF4)IVo8iIStg8lI(c8tGegSYvmnzfvBcYPDF6J)6QuyfupMEBBnJy2ELmGdQS1qxyGnrj7eyVG)8eg2KjbJdSTrwqcf0DY60EfjxRllTNx1V3KuOjfAMIEJEmgDGGQSCyyUOWoT)ZbKcRRfIq6HYLcXlsqQgb23V4Z61wD7Kk7rEiSI7abCZm(2XvvgaKcgKlB73(l6wMVn9gKx2PWJ8E3jvy2A0I4gsgaIO79SLJAwzyRu0IQquosmIcYVhrOUhbuNJMOrX0MjhMI4Mjc)qxcNqxGL3HoN1RIWAgV)bjUIZm2SxpRXvCwVQqOtUUu6BEw4BSmHIM323CONTyZN3HjN1)WLcozbB1PuD9Lllqmn4C0WnR21MSu37MT5S(hIslScVcGezb8rQs8PvBu3AdVDE15G6qUHxfMspqfR1vw1CDZ7Wzx2Qwl04a8kHV7lUSS7aT1wlMCC3JaFAoy9h()eP8fPvvWUxChSQwMUCf0p0PtpesuGyKK22l3Lds7w3aGCAvz4BNo5FI7la5FSmFjwokXDoSElcGESPS51HE(EirDJzIoNG0lt)FyP(xxfiyGRYlltbEciBCE3RLvVCXIcT28WYutOEyR1zO83ANS5SSP6UZwxkyadOtrU5KU(bXd85F7lT159Al6DX07JNkBvgs0YTM3yYAe05o5RRktJtOkZYJOrEusQJN)o0dr8e4HI5xbJSfR)U2s5bUYPxY9qB1qaxB2Uysd0AtqIIWgtZZTq)8(xUp3Cc)kgqlL7WA8fUIFWy8bNVDXdVT0zhl6Hdb92R5X5DVDnn0zs(KARoNrnIjAhsbiLPOvdSpyHQE0wfzquQ)vatFM(bXV4fgdf6z1V4f9pyeRS9(y9v3Z46SfeRJT43JQ2Y1nPqGqN(v8sPMKYU1Ql6v3ngEE03dEOUO)Xr1gVWpB3A(OA2MzqUXhl3iD0)yocdD0hFqoCZCr)JCWh6P1cqOMhvBlkALvajIT4BFuSi7nBaTMtsteROBsHNJyKQ37AePyDM8xLSgfQ2TmIHni5H)UKS4Kc8BYu4tBg8hngAzcenu9x7bAWPB(3Jko18FT6x9PWC38fScZTQJznkD1ASiiZtg)q60pNelrQnTNkWUHgqnonbDbsEYXWx)YlHKrmafPEhI3zDqQfKNJoYyPIuKmRiHWUVdkKrZOyihXd5S1lgVADwA58LjIReYPY4AKuOAenf7zltDdrF66EP)0SARo3WYZLQXq0S8iWecYkKOZkGz9D6kKgA(mUcPo34kKAiwtf3lEPuLnBWq6ZINTzvo23CAnPnIsORDeNudPXxFn4KIDd4Q8hi2oWVBQKX4OHW0gcCwzBCAS5Re(ecRXsHc6cONAugBnlJHeYQtj8Ui6s1WbmPf5)SjwEAluOQ)6TMcfYo)aV7Idz0JNF4LQoI3AStsK1rc16gJQ)EfQThDoApYJTb2LUzJIGQd(TMs1wh8Syy2wkuD93bjZgqcBBpcn7oZ7j5keWKe3wjqQxB3nvpNybjQNBHMxJw05db6WxrAduWVHe6208L3f1C42Wn7GgoriolVOkTADS(R3CY244SXPj6r1IRqldm(5rUkbAk36Vh6swploLF4Dq)GOlpK8Vi2MWbbFpYMf0eIxvuR9fw6q81y0RT6RP7q1elOs)i2rMLdbpusfofzwZZH9P6JVFtZxp(dPqs068k1TvTtAJQrZ4kbHbAcREDQUSH)TFO6pRHtuPZbkFmBkSlDufakX)X3lsCcE8R5ISfxv)y1teHpoM82llnoxvePXpJcM(pBukVjSc5NZJUa2Vywkr1JLQs1KrLdvkTqSLX(psEDSLXarfm7jDXevHI6yH7sO2TKmKBTk3T()v0IzQSF0cgLkIIt5DxTlR2HHuCLDtLyUOgw1KwBKpFL(f(QHztf2zFu)rCFn8VhgU(RPhTN8jxvTmbpViCJJht5yLdP9EiiPEQUp62I9DNIzsUZvqqfx62dzoe4jTs5UYRukPsBbcSdek1m5nTtLx1ACVBnltCPTLiyAl((DbIiMU1Z207u5BKUYN9OTFgWmnLVrwv(CvuohYGHMiArmt7Sntl0VNBTb5SW1oaZ0WpNPS9mGR88a1o9Y(gXkBpHR2(WvBrK55Z9Nno9U1XMxYLTvDODbkuBcu7mg75yYvmVPDixT7WHDUa9U1LstCsQvKOYWbHLuaZ)3RlzTUi9togYSTyDgUL7wouMWK1Wwdn6UC8WzkplofnkA0rp9CMsxntQChSdqjdQckdBK4W0z2kJ(uXrlkFPmUZehhQeOmGZLMwtv7b6c5KcS2ccNOYpevanNbHAXJa50LRWJgo8C4AF2rF8(1TTlyUUmh6MMO1v5WjExm24Tz3NuoCZh(nSzzo)nqInzK5cF8(MRKW(00tT80AVdKrn4KVEah2NCSzGRSraka3Y2eOb8tCI5nlIMX9h0oIm1MGrFJMaTULqLbzRBk0MGtnpbCLgfaRTd6Aa8mlyCJQGkUQ)HQPbulIGGEJc0e)uX0aZfYGjNeDfg7cRdy3FGZtSYJemmIJWWPv5b)BSnzQgTcaiFvniBiK)Iz(H6PkOcVX2HoOkFAKT1Wqj1nYg(B40crLgCCGIOonNEzGfUTbqJXRRRZBpMEFNOGJ58W3vaOwy9Aa0YsyqmCFMnVcBJreBaT3SGZS4EPJwLSbM(JxwwRdM67zVoWsN2ayVzbNBXTwWbyW18pFxB79Cl(s7pR5INjagetlxeATTl21HODrOLLVWMiwq4VweV6TTHlS7ZD7t)4clEXulaVc0T1zBEdETwktDcS2ZzFdMIlT44mqmjRG)zGcc4u4oxZTtm9sB2ycHg7L2DTfam3ITMWa8DzLjCa8W6X)slU7cdveANZxUlnh7a4bMNBjGZWqfwmjheG)AlMY2sGV5dgQwiVli2pe1lS3IC2Qry)bODB1HvmZw576bMV5dVhxBaWCEDVgbNldLvaNhA9V8zPl4nxt5qEVa(ZV9vM6(paMSXsgH6nE3HWhLXB5neO4qRRzfDiv0BmTdZx92YKQdXVqM3(cVU712ZXWysSSlPTp8tBM4ZnUg9TQVZ1CI00HkJ2EIop9K4EHauV3iO4vcNt0dgOViNal1cQ5XTaNDSHBgqgFmBAbNoVV(2SpPYFOqYZSLMu8PNS1GIwNLsRvDvEgpMqw)uTwxxbtuCmdm03Fi9mODO4h22HPZ4mu8P9fNBMSrBpiy4BZEJjHZ4sD9N4WoEUe4pkH1gSzMnClFvSIlqQd87auyVAMJAvf2tRZCUA0XbdHfYE3mI28DjeQP02zVOOeIqhnfQPv78luy(WE7cug()V2Xc41oM9LoHBLlyTcVj6yRwby72Q3bpCfDhDVKzN20oDf0Ce1P3SroMt6cCpAylFRUsWStk2)mizCJ0zhY7bKATq1D3S2ni9)IN1zOFCYI6)cCfH1vdF6X7quVzrI09qF6sypnrZrFoei3a1FjRXNUYvxrDaI0FSFbKOe7KeI1CtNrWSb2(etBmUyx89apiGFVVUm7OhAdh4pYS(MFpd)4Mg8GkA9sbliux7bm58YXssqt75(lZfW72RNj2Il6oi8Ld2BGPipF6jJD84vTpDhynexCjW77zRGWGfYsHnpVS98xS(Ux)2tuOHT)c1k0KPMa0aRKJW5zkHY2ZNXD1iI8YGbNCKxq9Oto4ad8BPtg1wS0Eayj3N56QtyyMpdERXkumq6yJpelJUszY4rzJSfad3gwEyt8xXKIca2BmZl5BWkz8v8sTYde9FDUuNCTCW60BxXxBO0JoZ6slUiZl6hCDTxlT7NlLq3XLRGFTpzNRODOd6rzize9pl5jw)IUcjLD3zcyhPPgDowUVGkgFztlXYRpMvLxNh0FDmt1Y13XWHtCxvygYlVwOhvUEo)UclNpi9dAsmapwsG7OlDPwwUQV(iKjz7O8pp6BR4Li((DNO1pbRayEn7Sl(OEXEeICWC(AdgOwt19CTNKqeoAVWlu3OXdoqVaXx)2rhZZeDBUiI2w(G19bWgc36XB4ZjgTNT9RqneVD6nd02qXDRu7MfK0f52gmQTQWV94a7q(XPNEthHpn1gr2UCn5WvOyYLH(A2PfUAJW7puEsmG2Fp6qX3R4MTHALcO09weAAd)4LxytxpjFFMq6oT9L1utZ2l23lFMaqD(VjOMme1Sdm)FMlCf3wxByPMs2u3zRXQkvh2VHA4iC17eYYjjBKuvUqorvPQ4)8FFV4HmnIn)W5kqgR)E0tW3331kBblUdwYnv1)bQg(4McnN8Yo2H1oHkDVbfB91CY2twoZGXGFPTnDQWIswZNQnNnikyjG(gF3TfiVmX0Hc1B8eG)hfRUMW7FmS7gIBYJTI5Sv2sG9j1Gg5UXI4oKo6Onr5BWHqG2DWatqS5fiKYurJCEBxek0YVezCB0vyYSy2109MHI9wvmwCkvUakOZm)KwvaHv2sQ9KS7ZVcm2O0HtMbp0RJ0Mrx0CxZVEp(VtU31BfXB6VEraZ)T(ax1V1sbwG6J49LbWuzhwLxp44HN(sNhrLqdD8c2jHjjCoHJbt43ZMQi1VwYMa)0F2EdCDZwC121Nv4)tKdjA(cWfGd9IEXIuH0oNfPnHbLfjl6t3NurMJIkKnEkAGh3MclVOWxMcRgRg26bLEtxOubwnnUxB3le7zJlDfVrFfuKyBUO)ec7nyCsYF(BqUCV7J3qIh73GWTiMOFOiIE0ERVz1q1vucsH172OxNhZxdUE(CchiqCnrLZRBaCc(dLJjzJExjJ7NEjTwyatQeA)aANkuKGTPCuAmelrfek2HSjBze0dv4NOdaFAqKai41o6UK7tZO9abmnr1y80hNc1ycBVxIVfSEoW0alVKrpuvwddgTCmsxcRV4ppUHmTkp436tZ7OcjAEb(VsZFNdCUXBbwdrjjivtt0(NdSoD(l9yBkKnkULCbNPWlopWwZ4PnfXyh8hPeElntAcF7JL5lIKZyCRxGc66bQXY6ZfFo035V7qEWpwcgO2VuV9(BzQ0pa3HzZvNXCf)CG3FSV)inYknFgT3m98qTyQe0adLKJKgJYxON0ZQf1h8cXqePnxfXvV(VSj8UQ6pkvsGeyjGLo8OV(TNAEg10yc4elaBRZVXfSEHeqY9YbrjedLUQM)sbgxenP57kfwbBW9I6QzXw4IIbEeEWVdflh9nwS0Y87)672HA2nJOf56UvcsYzUlpZ7Kz3c7oO0TnNTT0JVTYS2oSYhbGDXmegv6NbL3oiWSDtupLpS5Mxn)K(HCuNAw4bq8EBpOj4FypvTD6IQffQ2uh8uAOv5s7kfo41yaH)eedi)Cnb2hNT)IlRzo5hzkCQcd)vm9hHIpMqp8nyNekQYOchDfsWTbacwz7eu)jCtII75nqMzSs(UXYr(E14xtPVSmG9u)m0A9O(GPoy(UfZgAxXqxl3aynau)ceZmi5xdz2H6tp1uwkJ3PyxZZI62Bi6StHJe(lWt99B)F)]] )