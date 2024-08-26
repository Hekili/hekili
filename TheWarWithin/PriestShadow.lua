-- PriestShadow.lua
-- July 2024

if UnitClassBase( "player" ) ~= "PRIEST" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local FindUnitBuffByID, FindUnitDebuffByID, PTR = ns.FindUnitBuffByID, ns.FindUnitDebuffByID, ns.PTR

local spec = Hekili:NewSpecialization( 258 )

spec:RegisterResource( Enum.PowerType.Insanity, {
    mind_flay = {
        aura = "mind_flay",
        debuff = true,

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.mind_flay.tick_time ) * class.auras.mind_flay.tick_time
        end,

        interval = function () return class.auras.mind_flay.tick_time end,
        value = 2,
    },

    mind_flay_insanity = {
        aura = "mind_flay_insanity_dot",
        debuff = true,

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.mind_flay_insanity_dot.tick_time ) * class.auras.mind_flay_insanity_dot.tick_time
        end,

        interval = function () return class.auras.mind_flay_insanity_dot.tick_time end,
        value = 3,
    },

    void_lasher_mind_sear = {
        aura = "void_lasher_mind_sear",
        debuff = true,

        last = function ()
            local app = state.debuff.void_lasher_mind_sear.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = function () return class.auras.void_lasher_mind_sear.tick_time end,
        value = 1,
    },

    void_tendril_mind_flay = {
        aura = "void_tendril_mind_flay",
        debuff = true,

        last = function ()
            local app = state.debuff.void_tendril_mind_flay.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = function () return class.auras.void_tendril_mind_flay.tick_time end,
        value = 1,
    },

    void_torrent = {
        channel = "void_torrent",

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.abilities.void_torrent.tick_time ) * class.abilities.void_torrent.tick_time
        end,

        interval = function () return class.abilities.void_torrent.tick_time end,
        value = 6,
    },

    mindbender = {
        aura = "mindbender",

        last = function ()
            local app = state.buff.mindbender.expires - 15
            local t = state.query_time

            return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
        end,

        interval = function () return 1.5 * state.haste * ( state.conduit.rabid_shadows.enabled and 0.85 or 1 ) end,
        value = 2
    },

    shadowfiend = {
        aura = "shadowfiend",

        last = function ()
            local app = state.buff.shadowfiend.expires - 15
            local t = state.query_time

            return app + floor( ( t - app ) / ( 1.5 * state.haste ) ) * ( 1.5 * state.haste )
        end,

        interval = function () return 1.5 * state.haste * ( state.conduit.rabid_shadows.enabled and 0.85 or 1 ) end,
        value = 2
    }
} )
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
    cauterizing_shadows        = {  82687, 459990, 1 }, -- When your Shadow Word: Pain expires or is refreshed with less than 5 sec remaining, a nearby ally within 46 yards is healed for 3,528.
    crystalline_reflection     = {  82681, 373457, 2 }, -- Power Word: Shield instantly heals the target for 4,116 and reflects 10% of damage absorbed.
    death_and_madness          = {  82711, 321291, 1 }, -- If your Shadow Word: Death fails to kill a target at or below 20% health, its cooldown is reset. Cannot occur more than once every 10 sec. If a target dies within 7 sec after being struck by your Shadow Word: Death, you gain 8 Insanity.
    dispel_magic               = {  82715,    528, 1 }, -- Dispels Magic on the enemy target, removing 1 beneficial Magic effect.
    divine_star                = {  82680, 122121, 1 }, -- Throw a Divine Star forward 31 yds, healing allies in its path for 6,861 and dealing 5,983 Shadow damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond 6 targets. Generates 6 Insanity.
    dominate_mind              = {  82710, 205364, 1 }, -- Controls a mind up to 1 level above yours for 30 sec while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings or players. This spell shares diminishing returns with other disorienting effects.
    essence_devourer           = {  82674, 415479, 1 }, -- Attacks from your Shadowfiend siphon life from enemies, healing a nearby injured ally for 17,643. Attacks from your Mindbender siphon life from enemies, healing a nearby injured ally for 5,881.
    focused_mending            = {  82719, 372354, 1 }, -- Prayer of Mending does 45% increased healing to the initial target.
    from_darkness_comes_light  = {  82707, 390615, 1 }, -- Each time Shadow Word: Pain deals damage, the healing of your next Flash Heal is increased by 3%, up to a maximum of 60%.
    halo                       = {  82680, 120644, 1 }, -- Creates a ring of Shadow energy around you that quickly expands to a 34 yd radius, healing allies for 15,781 and dealing 15,406 Shadow damage to enemies. Healing reduced beyond 6 targets. Generates 10 Insanity.
    holy_nova                  = {  82701, 132157, 1 }, -- An explosion of holy light around you deals up to 4,014 Holy damage to enemies and up to 3,087 healing to allies within 13 yds, reduced if there are more than 5 targets.
    improved_fade              = {  82686, 390670, 2 }, -- Reduces the cooldown of Fade by 5 sec.
    improved_flash_heal        = {  82714, 393870, 1 }, -- Increases healing done by Flash Heal by 15%.
    inspiration                = {  82696, 390676, 1 }, -- Reduces your target's physical damage taken by 5% for 15 sec after a critical heal with Flash Heal.
    leap_of_faith              = {  82716,  73325, 1 }, -- Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    lights_inspiration         = {  82679, 373450, 2 }, -- Increases the maximum health gained from Desperate Prayer by 8%.
    manipulation               = {  82672, 459985, 1 }, -- You take 2% less damage from enemies affected by your Shadow Word: Pain.
    mass_dispel                = {  82699,  32375, 1 }, -- Dispels magic in a 15 yard radius, removing all harmful Magic from 5 friendly targets and 1 beneficial Magic effect from 5 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mental_agility             = {  82698, 341167, 1 }, -- Reduces the mana cost of Purify Disease and Mass Dispel by 50% and Dispel Magic by 10%.
    mind_control               = {  82710,    605, 1 }, -- Controls a mind up to 1 level above yours for 30 sec. Does not work versus Demonic, Undead, or Mechanical beings. Shares diminishing returns with other disorienting effects.
    move_with_grace            = {  82702, 390620, 1 }, -- Reduces the cooldown of Leap of Faith by 30 sec.
    petrifying_scream          = {  82695,  55676, 1 }, -- Psychic Scream causes enemies to tremble in place instead of fleeing in fear.
    phantasm                   = {  82556, 108942, 1 }, -- Activating Fade removes all snare effects.
    phantom_reach              = {  82673, 459559, 1 }, -- Increases the range of most spells by 15%.
    power_infusion             = {  82694,  10060, 1 }, -- Infuses the target with power for 15 sec, increasing haste by 20%. Can only be cast on players.
    power_word_life            = {  82676, 373481, 1 }, -- A word of holy power that heals the target for 101,450. Only usable if the target is below 35% health.
    prayer_of_mending          = {  82718,  33076, 1 }, -- Places a ward on an ally that heals them for 7,474 the next time they take damage, and then jumps to another ally within 30 yds. Jumps up to 4 times and lasts 30 sec after each jump.
    protective_light           = {  82707, 193063, 1 }, -- Casting Flash Heal on yourself reduces all damage you take by 10% for 10 sec.
    psychic_voice              = {  82695, 196704, 1 }, -- Reduces the cooldown of Psychic Scream by 15 sec.
    purify_disease             = {  82704, 213634, 1 }, -- Removes all Disease effects from a friendly target.
    renew                      = {  82717,    139, 1 }, -- Fill the target with faith in the light, healing for 27,692 over 15 sec.
    rhapsody                   = {  82700, 390622, 1 }, -- Every 1 sec, the damage of your next Holy Nova is increased by 20% and its healing is increased by 20%. Stacks up to 20 times.
    sanguine_teachings         = {  82691, 373218, 1 }, -- Increases your Leech by 4%.
    sanlayn                    = {  82690, 199855, 1 }, --  Sanguine Teachings Sanguine Teachings grants an additional 2% Leech.  Vampiric Embrace Reduces the cooldown of Vampiric Embrace by 30 sec, increases its healing done by 25%.
    shackle_undead             = {  82693,   9484, 1 }, -- Shackles the target undead enemy for 50 sec, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shadow_word_death          = {  82712,  32379, 1 }, -- A word of dark binding that inflicts 8,398 Shadow damage to your target. If your target is not killed by Shadow Word: Death, you take backlash damage equal to 5% of your maximum health. Damage increased by 250% to targets below 20% health. Generates 4 Insanity.
    shadowfiend                = {  82713,  34433, 1 }, -- Summons a shadowy fiend to attack the target for 15 sec. Generates 2 Insanity each time the Shadowfiend attacks.
    sheer_terror               = {  82708, 390919, 1 }, -- Increases the amount of damage required to break your Psychic Scream by 75%.
    spell_warding              = {  82720, 390667, 1 }, -- Reduces all magic damage taken by 3%.
    surge_of_light             = {  82677, 109186, 1 }, -- Your healing spells and Smite have a 8% chance to make your next Flash Heal instant and cost no mana. Stacks to 2.
    throes_of_pain             = {  82709, 377422, 2 }, -- Shadow Word: Pain deals an additional 3% damage. When an enemy dies while afflicted by your Shadow Word: Pain, you gain 3 Insanity.
    tithe_evasion              = {  82688, 373223, 1 }, -- Shadow Word: Death deals 50% less damage to you.
    translucent_image          = {  82685, 373446, 1 }, -- Fade reduces damage you take by 10%.
    twins_of_the_sun_priestess = {  82683, 373466, 1 }, -- Power Infusion also grants you 100% of its effects when used on an ally.
    twist_of_fate              = {  82684, 390972, 2 }, -- After damaging or healing a target below 35% health, gain 5% increased damage and healing for 8 sec.
    unwavering_will            = {  82697, 373456, 2 }, -- While above 75% health, the cast time of your Flash Heal is reduced by 5%.
    vampiric_embrace           = {  82691,  15286, 1 }, -- Fills you with the embrace of Shadow energy for 12 sec, causing you to heal a nearby ally for 50% of any single-target Shadow spell damage you deal.
    void_shield                = {  82692, 280749, 1 }, -- When cast on yourself, 30% of damage you deal refills your Power Word: Shield.
    void_shift                 = {  82674, 108968, 1 }, -- Swap health percentages with your ally. Increases the lower health percentage of the two to 25% if below that amount.
    void_tendrils              = {  82708, 108920, 1 }, -- Summons shadowy tendrils, rooting all enemies within 8 yards for 15 sec or until the tendril is killed.
    words_of_the_pious         = {  82721, 377438, 1 }, -- For 12 sec after casting Power Word: Shield, you deal 10% additional damage and healing with Smite and Holy Nova.

    -- Shadow
    ancient_madness            = {  82656, 341240, 1 }, -- Voidform and Dark Ascension increase the critical strike chance of your spells by 10% for 20 sec, reducing by 0.5% every sec.
    auspicious_spirits         = {  82667, 155271, 1 }, -- Your Shadowy Apparitions deal 15% increased damage and have a chance to generate 1 Insanity.
    dark_ascension             = {  82657, 391109, 1 }, -- Increases your non-periodic Shadow damage by 20% for 20 sec. Generates 30 Insanity.
    dark_evangelism            = {  82660, 391095, 2 }, -- Your Mind Flay, Mind Spike, and Void Torrent damage increase the damage of your periodic Shadow effects by 1%, stacking up to 5 times.
    deathspeaker               = {  82558, 392507, 1 }, -- Your Shadow Word: Pain damage has a chance to reset the cooldown of Shadow Word: Death, increase its damage by 25%, and deal damage as if striking a target below 20% health.
    devouring_plague           = {  82665, 335467, 1 }, -- Afflicts the target with a disease that instantly causes 21,658 Shadow damage plus an additional 24,947 Shadow damage over 6 sec. Heals you for 30% of damage dealt. If this effect is reapplied, any remaining damage will be added to the new Devouring Plague.
    dispersion                 = {  82663,  47585, 1 }, -- Disperse into pure shadow energy, reducing all damage taken by 75% for 6 sec and healing you for 25% of your maximum health over its duration, but you are unable to attack or cast spells. Increases movement speed by 50% and makes you immune to all movement impairing effects. Castable while stunned, feared, or silenced.
    distorted_reality          = {  82647, 409044, 1 }, -- Increases the damage of Devouring Plague by 20% and causes it to deal its damage over 12 sec, but increases its Insanity cost by 5.
    idol_of_cthun              = {  82643, 377349, 1 }, -- Mind Flay, Mind Spike, and Void Torrent have a chance to spawn a Void Tendril that channels Mind Flay or Void Lasher that channels Mind Sear at your target.  Mind Flay Assaults the target's mind with Shadow energy, causing 31,551 Shadow damage over 15 sec and slowing their movement speed by 30%. Generates 10 Insanity over the duration. Mind Sear Corrosive shadow energy radiates from the target, dealing 16,827 Shadow damage over 15 sec to all enemies within 10 yards of the target. Damage reduced beyond 5 targets. Generates 10 Insanity over the duration.
    idol_of_nzoth              = {  82552, 373280, 1 }, -- Your periodic Shadow Word: Pain and Vampiric Touch damage has a 30% chance to apply Echoing Void, max 4 targets. Each time Echoing Void is applied, it has a chance to collapse, consuming a stack every 1 sec to deal 1,175 Shadow damage to all nearby enemies. Damage reduced beyond 5 targets. If an enemy dies with Echoing Void, all stacks collapse immediately.
    idol_of_yoggsaron          = {  82555, 373273, 1 }, -- After conjuring Shadowy Apparitions, gain a stack of Idol of Yogg-Saron. At 25 stacks, you summon a Thing from Beyond that casts Void Spike at nearby enemies for 20 sec.  Void Spike Hurls a bolt of dark magic, dealing 9,203 Shadow damage and 1,932 Shadow damage to all enemies within 10 yards of the target. Damage reduced beyond 5 targets.
    idol_of_yshaarj            = {  82553, 373310, 1 }, -- Summoning Mindbender causes you to gain a benefit based on your target's current state or increases its duration by 5 sec if no state matches. Healthy: You and your Mindbender deal 5% additional damage. Enraged: Devours the Enraged effect, increasing your Haste by 5%. Stunned: Generates 5 Insanity every 1 sec. Feared: You and your Mindbender deal 5% increased damage and do not break Fear effects.
    inescapable_torment        = {  82644, 373427, 1 }, -- Mind Blast and Shadow Word: Death cause your Mindbender or Shadowfiend to teleport behind your target, slashing up to 5 nearby enemies for 5,885 Shadow damage and extending its duration by 0.7 sec.
    insidious_ire              = {  82560, 373212, 2 }, -- While you have Shadow Word: Pain, Devouring Plague, and Vampiric Touch active on the same target, your Mind Blast and Void Torrent deal 20% more damage.
    intangibility              = {  82659, 288733, 1 }, -- Dispersion heals you for an additional 25% of your maximum health over its duration and its cooldown is reduced by 30 sec.
    last_word                  = {  82652, 263716, 1 }, -- Reduces the cooldown of Silence by 15 sec.
    maddening_touch            = {  82645, 391228, 2 }, -- Vampiric Touch deals 10% additional damage and has a chance to generate 1 Insanity each time it deals damage.
    malediction                = {  82655, 373221, 1 }, -- Reduces the cooldown of Void Torrent by 15 sec.
    mastermind                 = {  82671, 391151, 2 }, -- Increases the critical strike chance of Mind Blast, Mind Spike, Mind Flay, and Shadow Word: Death by 4% and increases their critical strike damage by 20%.
    mental_decay               = {  82658, 375994, 1 }, -- Increases the damage of Mind Flay and Mind Spike by 10%. The duration of your Shadow Word: Pain and Vampiric Touch is increased by 1 sec when enemies suffer damage from Mind Flay and 2 sec when enemies suffer damage from Mind Spike.
    mental_fortitude           = {  82659, 377065, 1 }, -- Healing from Vampiric Touch and Devouring Plague when you are at maximum health will shield you for the same amount. The shield cannot exceed 10% of your maximum health.
    mind_devourer              = {  82561, 373202, 2 }, -- Mind Blast has a 4% chance to make your next Devouring Plague cost no Insanity and deal 20% additional damage.
    mind_melt                  = {  93172, 391090, 1 }, -- Mind Spike increases the critical strike chance of Mind Blast by 30%, stacking up to 3 times. Lasts 10 sec.
    mind_spike                 = {  82557,  73510, 1 }, -- Blasts the target for 14,255 Shadowfrost damage. Generates 4 Insanity.
    mindbender                 = {  82648, 200174, 1 }, -- Summons a Mindbender to attack the target for 15 sec. Generates 2 Insanity each time the Mindbender attacks.
    minds_eye                  = {  82647, 407470, 1 }, -- Reduces the Insanity cost of Devouring Plague by 5.
    misery                     = {  93171, 238558, 1 }, -- Vampiric Touch also applies Shadow Word: Pain to the target. Shadow Word: Pain lasts an additional 5 sec.
    phantasmal_pathogen        = {  82563, 407469, 2 }, -- Shadow Apparitions deal 0% increased damage to targets affected by your Devouring Plague.
    psychic_horror             = {  82652,  64044, 1 }, -- Terrifies the target in place, stunning them for 4 sec.
    psychic_link               = {  82670, 199484, 1 }, -- Your direct damage spells inflict 30% of their damage on all other targets afflicted by your Vampiric Touch within 46 yards. Does not apply to damage from Shadowy Apparitions, Shadow Word: Pain, and Vampiric Touch.
    screams_of_the_void        = {  82649, 375767, 2 }, -- Devouring Plague causes your Shadow Word: Pain and Vampiric Touch to deal damage 40% faster on all targets for 3 sec.
    shadow_crash               = {  82669, 205385, 1 }, -- Aim a bolt of slow-moving Shadow energy at the destination, dealing 6,743 Shadow damage to all enemies within 8 yds. Generates 6 Insanity. This spell is cast at a selected location.
    shadow_crash_2             = {  82669, 457042, 1 }, -- Hurl a bolt of slow-moving Shadow energy at your target, dealing 6,743 Shadow damage to all enemies within 8 yds. Generates 6 Insanity. This spell is cast at your target.
    shadowy_apparitions        = {  82666, 341491, 1 }, -- Mind Blast, Devouring Plague, and Void Bolt conjure Shadowy Apparitions that float towards all targets afflicted by your Vampiric Touch for 3,033 Shadow damage. Critical strikes increase the damage by 100%.
    shadowy_insight            = {  82662, 375888, 1 }, -- Shadow Word: Pain periodic damage has a chance to reset the remaining cooldown on Mind Blast and cause your next Mind Blast to be instant.
    silence                    = {  82651,  15487, 1 }, -- Silences the target, preventing them from casting spells for 4 sec. Against non-players, also interrupts spellcasting and prevents any spell in that school from being cast for 4 sec.
    surge_of_insanity          = {  82668, 391399, 1 }, -- Every 2 casts of Devouring Plague transforms your next Mind Flay or Mind Spike into a more powerful spell. Can accumulate up to 4 charges.  Mind Flay: Insanity Assaults the target's mind with Shadow energy, causing 53,851 Shadow damage over 1.2 sec and slowing their movement speed by 70%. Generates 12 Insanity over the duration. Mind Spike: Insanity Blasts the target for 37,377 Shadowfrost damage. Generates 12 Insanity.
    thought_harvester          = {  82653, 406788, 1 }, -- Mind Blast gains an additional charge.
    tormented_spirits          = {  93170, 391284, 2 }, -- Your Shadow Word: Pain damage has a 5% chance to create Shadowy Apparitions that float towards all targets afflicted by your Vampiric Touch. Critical strikes increase the chance to 10%.
    unfurling_darkness         = {  82661, 341273, 1 }, -- After casting Vampiric Touch on a target, your next Vampiric Touch within 8 sec is instant cast and deals 59,065 Shadow damage immediately. This effect cannot occur more than once every 15 sec.
    void_eruption              = {  82657, 228260, 1 }, -- Releases an explosive blast of pure void energy, activating Voidform and causing 15,184 Shadow damage to all enemies within 10 yds of your target. During Voidform, this ability is replaced by Void Bolt. Casting Devouring Plague increases the duration of Voidform by 2.5 sec.
    void_torrent               = {  82654, 263165, 1 }, -- Channel a torrent of void energy into the target, dealing 103,861 Shadow damage over 3 sec. Generates 24 Insanity over the duration.
    voidtouched                = {  82646, 407430, 1 }, -- Increases your Devouring Plague damage by 6% and increases your maximum Insanity by 50.
    whispering_shadows         = {  82559, 406777, 1 }, -- Shadow Crash applies Vampiric Touch to up to 8 targets it damages.

    -- Oracle
    assured_safety             = {  94691, 440766, 1 }, -- Prayer of Mending casts apply a Power Word: Shield to your target at 100% effectiveness.
    clairvoyance               = {  94687, 428940, 1 }, -- Casting Premonition of Solace invokes Clairvoyance, expanding your mind and opening up all possibilities of the future.  Premonition of Clairvoyance Grants Premonition of Insight, Piety, and Solace at 100% effectiveness.
    desperate_measures         = {  94690, 458718, 1 }, -- Desperate Prayer lasts an additional 10 sec. Angelic Bulwark's absorption effect is increased by 15% of your maximum health.
    divine_feathers            = {  94675, 440670, 1 }, -- Your Angelic Feathers increase movement speed by an additional 10%. When an ally walks through your Angelic Feather, you are also granted 100% of its effect.
    divine_providence          = {  94673, 440742, 1 }, -- Premonition gains an additional charge.
    fatebender                 = {  94700, 440743, 1 }, -- Increases the effects of Premonition by 40%.
    foreseen_circumstances     = {  94689, 440738, 1 }, -- Guardian Spirit lasts an additional 2 sec.
    miraculous_recovery        = {  94679, 440674, 1 }, -- Reduces the cooldown of Power Word: Life by 3 sec and allows it to be usable on targets below 50% health.
    perfect_vision             = {  94700, 440661, 1 }, -- Reduces the cooldown of Premonition by 15 sec.
    preemptive_care            = {  94674, 440671, 1 }, -- Increases the duration of Renew by 3 sec.
    premonition                = {  94683, 428924, 1, "oracle" }, -- Gain access to a spell that gives you an advantage against your fate. Premonition rotates to the next spell when cast.  Premonition of Insight Reduces the cooldown of your next 3 spell casts by 7 sec.  Premonition of Piety Increases your healing done by 15% and causes 70% of overhealing on players to be redistributed to up to 4 nearby allies for 15 sec.  Premonition of Solace Your next single target healing spell grants your target a shield that absorbs 233,287 damage and reduces their damage taken by 15% for 15 sec.
    preventive_measures        = {  94698, 440662, 1 }, -- Increases the healing done by Prayer of Mending by 25%. All damage dealt by Smite, Holy Fire and Holy Nova increased by 25%.
    prophets_will              = {  94690, 433905, 1 }, -- Your Flash Heal, Heal, and Holy Word: Serenity are 30% more effective when cast on yourself.
    save_the_day               = {  94675, 440669, 1 }, -- For 6 sec after casting Leap of Faith you may cast it a second time for free, ignoring its cooldown.
    waste_no_time              = {  94679, 440681, 1 }, -- Premonition causes your next Heal or Prayer of Healing cast to be instant and cost 15% less mana.

    -- Voidweaver
    collapsing_void            = {  94694, 448403, 1 }, -- Each time you cast Devouring Plague, Entropic Rift is empowered, increasing its damage and size by 20%. After Entropic Rift ends it collapses, dealing 47,009 Shadow damage split amongst enemy targets within 15 yds.
    concentrated_infusion      = {  94676, 453844, 1 }, -- Your Power Infusion effect grants you an additional 10% haste.
    dark_energy                = {  94693, 451018, 1 }, -- Void Torrent can be used while moving. While Entropic Rift is active, you move 20% faster.
    darkening_horizon          = {  94695, 449912, 1 }, -- Void Blast increases the duration of Entropic Rift by 1.0 sec, up to a maximum of 3 sec.
    darkening_horizon_2        = {  94668, 449912, 1 }, -- Void Blast increases the duration of Entropic Rift by 1.0 sec, up to a maximum of 3 sec.
    depth_of_shadows           = { 100212, 451308, 1 }, -- Shadow Word: Death has a high chance to summon a Shadowfiend for 5 sec when damaging targets below 20% health.
    devour_matter              = {  94668, 451840, 1 }, -- Shadow Word: Death consumes absorb shields from your target, dealing 25,194 extra damage to them and granting you 5 Insanity if a shield was present.
    divine_halo                = {  94702, 449806, 1 }, -- Halo now centers around you and returns to you after it reaches its maximum distance, healing allies and damaging enemies each time it passes through them.
    embrace_the_shadow         = {  94696, 451569, 1 }, -- You absorb 3% of all magic damage taken. Absorbing Shadow damage heals you for 100% of the amount absorbed.
    empowered_surges           = {  94688, 453799, 1 }, -- Increases the damage done by Mind Flay: Insanity and Mind Spike: Insanity by 60%. Increases the healing done by Flash Heals affected by Surge of Light by 30%.
    energy_compression         = {  94678, 449874, 1 }, -- Halo damage and healing is increased by 30%.
    energy_cycle               = {  94685, 453828, 1 }, -- Consuming Surge of Insanity has a 100% chance to conjure Shadowy Apparitions.
    entropic_rift              = {  94684, 447444, 1, "voidweaver" }, -- Void Torrent tears open an Entropic Rift that follows the enemy for 8 sec. Enemies caught in its path suffer 6,410 Shadow damage every 0.8 sec while within its reach.
    heightened_alteration      = {  94680, 453729, 1 }, -- Increases the duration of Dispersion by 2 sec.
    incessant_screams          = {  94686, 453918, 1 }, -- Psychic Scream creates an image of you at your location. After 4 sec, the image will let out a Psychic Scream.
    inner_quietus              = {  94670, 448278, 1 }, -- Vampiric Touch and Shadow Word: Pain deal 20% additional damage.
    manifested_power           = {  94699, 453783, 1 }, -- Creating a Halo grants Surge of Insanity.
    no_escape                  = {  94693, 451204, 1 }, -- Entropic Rift slows enemies by up to 70%, increased the closer they are to its center.
    perfected_form             = {  94677, 453917, 1 }, -- Your damage dealt is increased by 12% while Dark Ascension is active and by 20% while Voidform is active.
    power_surge                = {  94697, 453109, 1 }, -- Casting Halo also causes you to create a Halo around you at 100% effectiveness every 5 sec for 10 sec. Additionally, the radius of Halo is increased by 10 yards.
    resonant_energy            = {  94681, 453845, 1 }, -- Enemies damaged by your Halo take 2% increased damage from you for 8 sec, stacking up to 5 times.
    shock_pulse                = {  94686, 453852, 1 }, -- Halo damage reduces enemy movement speed by 5% for 5 sec, stacking up to 5 times.
    sustained_potency          = {  94678, 454001, 1 }, -- Creating a Halo extends the duration of Dark Ascension or Voidform by 1 sec. If Dark Ascension and Voidform are not active, up to 6 seconds is stored and applied the next time you gain Dark Ascension or Voidform.
    void_blast                 = {  94703, 450405, 1 }, -- Entropic Rift upgrades Mind Blast into Void Blast while it is active. Void Blast: Sends a blast of cosmic void energy at the enemy, causing 30,465 Shadow damage. Generates 6 Insanity.
    void_empowerment           = {  94695, 450138, 1 }, -- Summoning an Entropic Rift grants you Mind Devourer.
    void_infusion              = {  94669, 450612, 1 }, -- Void Blast generates 100% additional Insanity.
    void_leech                 = {  94696, 451311, 1 }, -- Every 2 sec siphon an amount equal to 3% of your health from an ally within 40 yds if they are higher health than you.
    voidheart                  = {  94692, 449880, 1 }, -- While Entropic Rift is active, your Shadow damage is increased by 10%.
    voidwraith                 = { 100212, 451234, 1 }, -- Transform your Shadowfiend or Mindbender into a Voidwraith. Voidwraith Summon a Voidwraith for 15 sec that casts Void Flay from afar. Void Flay deals bonus damage to high health enemies, up to a maximum of 50% if they are full health. Generates 2 Insanity each time the Voidwraith attacks.
    word_of_supremacy          = {  94680, 453726, 1 }, -- Power Word: Fortitude grants you an additional 5% stamina.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    absolute_faith       = 5481, -- (408853) Leap of Faith also pulls the spirit of the 3 furthest allies within 40 yards and shields you and the affected allies for 73,514.
    catharsis            = 5486, -- (391297) 15% of all damage you take is stored. The stored amount cannot exceed 12% of your maximum health. The initial damage of your next Shadow Word: Pain deals this stored damage to your target.
    driven_to_madness    =  106, -- (199259) While Voidform or Dark Ascension is not active, being attacked will reduce the cooldown of Void Eruption and Dark Ascension by 3 sec.
    improved_mass_dispel = 5636, -- (426438) Reduces the cooldown of Mass Dispel by 60 sec.
    mind_trauma          =  113, -- (199445) Siphon haste from enemies, stealing 2% haste per stack of Mind Trauma, stacking up to 9 times. Mind Spike and fully channeled Mind Flays grant 1 stack of Mind Trauma and fully channeled Void Torrents grant 3 stacks of Mind Trauma. Lasts 15 sec. You can only gain 3 stacks of Mind Trauma from a single enemy.
    mindgames            = 5638, -- (375901) Assault an enemy's mind, dealing 29,405 Shadow damage and briefly reversing their perception of reality. For 7 sec, the next 73,513 damage they deal will heal their target, and the next 73,513 healing they deal will damage their target. Generates 10 Insanity.
    phase_shift          = 5568, -- (408557) Step into the shadows when you cast Fade, avoiding all attacks and spells for 1 sec. Interrupt effects are not affected by Phase Shift.
    psyfiend             =  763, -- (211522) Summons a Psyfiend with 19,522 health for 12 sec beside you to attack the target at range with Psyflay.  Psyflay Deals up to 1% of the target's total health in Shadow damage every 0.8 sec. Also slows their movement speed by 50% and reduces healing received by 50%.
    thoughtsteal         = 5381, -- (316262) Peer into the mind of the enemy, attempting to steal a known spell. If stolen, the victim cannot cast that spell for 20 sec. Can only be used on Humanoids with mana. If you're unable to find a spell to steal, the cooldown of Thoughtsteal is reset.
    void_volley          = 5447, -- (357711) After casting Void Eruption or Dark Ascension, send a slow-moving bolt of Shadow energy at a random location every 0.5 sec for 3 sec, dealing 7,478 Shadow damage to all targets within 8 yds, and causing them to flee in Horror for 2 sec.
} )


spec:RegisterTotem( "mindbender", 136214 )
spec:RegisterTotem( "shadowfiend", 136199 )

local unfurling_darkness_triggered = 0

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_AURA_REMOVED" and spellID == 341207 then
            Hekili:ForceUpdate( subtype )

        elseif subtype == "SPELL_AURA_APPLIED" then
            if spellID == 341273 then
                unfurling_darkness_triggered = GetTime()
            elseif spellID == 341207 then
                Hekili:ForceUpdate( subtype )
            end
        end
    end
end, false )


local ExpireVoidform = setfenv( function()
    applyBuff( "shadowform" )
    if Hekili.ActiveDebug then Hekili:Debug( "Voidform expired, Shadowform applied.  Did it stick?  %s.", buff.voidform.up and "Yes" or "No" ) end
end, state )

local PowerSurge = setfenv( function()
    class.abilities.halo.handler()
end, state )


spec:RegisterGear( "tier29", 200327, 200329, 200324, 200326, 200328 )
spec:RegisterAuras( {
    dark_reveries = {
        id = 394963,
        duration = 8,
        max_stack = 1
    },
    gathering_shadows = {
        id = 394961,
        duration = 15,
        max_stack = 3
    }
} )

spec:RegisterGear( "tier30", 202543, 202542, 202541, 202545, 202540, 217202, 217204, 217205, 217201, 217203 )
spec:RegisterAuras( {
    darkflame_embers = {
        id = 409502,
        duration = 3600,
        max_stack = 4
    },
    darkflame_shroud = {
        id = 410871,
        duration = 10,
        max_stack = 1
    }
} )

spec:RegisterGear( "tier31", 207279, 207280, 207281, 207282, 207284 )
spec:RegisterAura( "deaths_torment", {
    id = 423726,
    duration = 60,
    max_stack = 12
} )


-- Don't need to actually snapshot this, the APL only cares about the power of the cast.
spec:RegisterStateExpr( "pmultiplier", function ()
    if this_action ~= "devouring_plague" then return 1 end

    local mult = 1
    if buff.gathering_shadows.up then mult = mult * ( 1 + ( buff.gathering_shadows.stack * 0.12 ) ) end
    if buff.mind_devourer.up     then mult = mult * 1.2                                             end

    return mult
end )


spec:RegisterHook( "reset_precast", function ()
    if buff.voidform.up or time > 0 then
        applyBuff( "shadowform" )
    end

    if unfurling_darkness_triggered > 0 and now - unfurling_darkness_triggered < 15 then
        applyBuff( "unfurling_darkness_icd", now - unfurling_darkness_triggered )
    end

    if pet.mindbender.active then
        applyBuff( "mindbender", pet.mindbender.remains )
        buff.mindbender.applied = action.mindbender.lastCast
        buff.mindbender.duration = 15
        buff.mindbender.expires = action.mindbender.lastCast + 15
    elseif pet.shadowfiend.active then
        applyBuff( "shadowfiend", pet.shadowfiend.remains )
        buff.shadowfiend.applied = action.shadowfiend.lastCast
        buff.shadowfiend.duration = 15
        buff.shadowfiend.expires = action.shadowfiend.lastCast + 15
    end

    if buff.voidform.up then
        state:QueueAuraExpiration( "voidform", ExpireVoidform, buff.voidform.expires )
    end

    if IsActiveSpell( 356532 ) then
        applyBuff( "direct_mask", class.abilities.fae_guardians.lastCast + 20 - now )
    end

    -- If we are channeling Mind Sear, see if it started with Thought Harvester.
    local _, _, _, start, finish, _, _, spellID = UnitChannelInfo( "player" )

    if settings.pad_void_bolt and cooldown.void_bolt.remains > 0 then
        reduceCooldown( "void_bolt", latency * 2 )
    end

    if settings.pad_ascended_blast and cooldown.ascended_blast.remains > 0 then
        reduceCooldown( "ascended_blast", latency * 2 )
    end

    if talent.entropic_rift.enabled and query_time - action.void_torrent.lastCast < 8 then
        applyBuff( "entropic_rift", 8 - ( query_time - action.void_torrent.lastCast ) )
    end

    if talent.power_surge.enabled and query_time - action.halo.lastCast < 10 then
        applyBuff( "power_surge", 10 - ( query_time - action.halo.lastCast ) )
        if buff.power_surge.remains > 5 then
            state:QueueAuraEvent( "power_surge", PowerSurge, buff.power_surge.expires - 5, "TICK" )
        end
        state:QueueAuraExpiration( "power_surge", PowerSurge, buff.power_surge.expires )
    end
end )

spec:RegisterHook( "TALENTS_UPDATED", function()
    local sf = talent.mindbender.enabled and "mindbender" or "shadowfiend"
    class.totems.fiend = spec.totems[ sf ]
    totem.fiend = totem[ sf ]
    cooldown.fiend = cooldown[ sf ]
    pet.fiend = pet[ sf ]
end )


spec:RegisterHook( "pregain", function( amount, resource, overcap )
    if amount > 0 and resource == "insanity" and state.buff.memory_of_lucid_dreams.up then
        amount = amount * 2
    end

    return amount, resource, overcap
end )


spec:RegisterStateTable( "priest", {
    self_power_infusion = true
} )


-- Auras
spec:RegisterAuras( {
    angelic_feather = {
        id = 121557,
        duration = 5,
        max_stack = 1,
    },
    -- Talent: Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=390669
    apathy = {
        id = 390669,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    blessed_recovery = {
        id = 390771,
        duration = 6,
        tick_time = 2,
        max_stack = 1,
    },
    -- Talent: Movement speed increased by $s1%.
    -- https://wowhead.com/beta/spell=65081
    body_and_soul = {
        id = 65081,
        duration = 3,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: Your non-periodic Shadow damage is increased by $w1%. $?s341240[Critical strike chance increased by ${$W4}.1%.][]
    -- https://wowhead.com/beta/spell=391109
    dark_ascension = {
        id = 391109,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Periodic Shadow damage increased by $w1%.
    -- https://wowhead.com/beta/spell=391099
    dark_evangelism = {
        id = 391099,
        duration = 25,
        max_stack = 5
    },
    dark_thought = {
        id = 341207,
        duration = 10,
        max_stack = 1,
        copy = "dark_thoughts"
    },
    death_and_madness_debuff = {
        id = 322098,
        duration = 7,
        max_stack = 1,
    },
    -- Talent: Shadow Word: Death damage increased by $s2% and your next Shadow Word: Death deals damage as if striking a target below $32379s2% health.
    -- https://wowhead.com/beta/spell=392511
    deathspeaker = {
        id = 392511,
        duration = 15,
        max_stack = 1
    },
    -- Maximum health increased by $w1%.
    -- https://wowhead.com/beta/spell=19236
    desperate_prayer = {
        id = 19236,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $w2 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=335467
    devouring_plague = {
        id = 335467,
        duration = function() return talent.distorted_reality.enabled and 12 or 6 end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken reduced by $s1%. Healing for $?s288733[${$s5+$288733s2}][$s5]% of maximum health.    Cannot attack or cast spells.    Movement speed increased by $s4% and immune to all movement impairing effects.
    -- https://wowhead.com/beta/spell=47585
    dispersion = {
        id = 47585,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Healing received increased by $w2%.
    -- https://wowhead.com/beta/spell=64844
    divine_hymn = {
        id = 64844,
        duration = 15,
        type = "Magic",
        max_stack = 5
    },
    -- Talent: Under the control of the Priest.
    -- https://wowhead.com/beta/spell=205364
    dominate_mind = {
        id = 205364,
        duration = 30,
        mechanic = "charm",
        type = "Magic",
        max_stack = 1
    },
    echoing_void = {
        id = 373281,
        duration = 20,
        max_stack = 20
    },
    entropic_rift = {
        duration = 8,
        max_stack = 1
    },
    -- Reduced threat level. Enemies have a reduced attack range against you.$?e3  [   Damage taken reduced by $s4%.][]
    -- https://wowhead.com/beta/spell=586
    fade = {
        id = 586,
        duration = 10,
        type = "Magic",
        max_stack = 1
    },
    -- Covenant: Damage taken reduced by $w2%.
    -- https://wowhead.com/beta/spell=324631
    fleshcraft = {
        id = 324631,
        duration = 3,
        tick_time = 0.5,
        max_stack = 1
    },
    -- All magical damage taken reduced by $w1%.; All physical damage taken reduced by $w2%.
    -- https://wowhead.com/beta/spell=426401
    focused_will = {
        id = 426401,
        duration = 8,
        max_stack = 1
    },
    -- Penance fires $w2 additional $Lbolt:bolts;.
    harsh_discipline = {
        id = 373183,
        duration = 30,
        max_stack = 1
    },
    -- Talent: Conjuring $373273s1 Shadowy Apparitions will summon a Thing from Beyond.
    -- https://wowhead.com/beta/spell=373276
    idol_of_yoggsaron = {
        id = 373276,
        duration = 120,
        max_stack = 25
    },
    insidious_ire = {
        id = 373213,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Reduces physical damage taken by $s1%.
    -- https://wowhead.com/beta/spell=390677
    inspiration = {
        id = 390677,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Being pulled toward the Priest.
    -- https://wowhead.com/beta/spell=73325
    leap_of_faith = {
        id = 73325,
        duration = 1.5,
        mechanic = "grip",
        type = "Magic",
        max_stack = 1
    },
    levitate = {
        id = 111759,
        duration = 600,
        type = "Magic",
        max_stack = 1,
    },
    mental_fortitude = {
        id = 377066,
        duration = 15,
        max_stack = 1,
        copy = 194022
    },
    -- Talent: Under the command of the Priest.
    -- https://wowhead.com/beta/spell=605
    mind_control = {
        id = 605,
        duration = 30,
        mechanic = "charm",
        type = "Magic",
        max_stack = 1
    },
    mind_devourer = {
        id = 373204,
        duration = 15,
        max_stack = 1,
        copy = 338333
    },
    -- Movement speed slowed by $s2% and taking Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=15407
    mind_flay = {
        id = 15407,
        duration = function () return 4.5 * haste end,
        tick_time = function () return 0.75 * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Movement speed slowed by $s2% and taking Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=391403
    mind_flay_insanity = {
        id = 391401,
        duration = 30,
        max_stack = 4
    },
    mind_flay_insanity_dot = {
        id = 391403,
        duration = function () return 2 * haste end,
        tick_time = function () return 0.5 * haste end,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: The cast time of your next Mind Blast is reduced by $w1% and its critical strike chance is increased by $s2%.
    -- https://wowhead.com/beta/spell=391092
    mind_melt = {
        id = 391092,
        duration = 10,
        max_stack = 3
    },
    -- Reduced distance at which target will attack.
    -- https://wowhead.com/beta/spell=453
    mind_soothe = {
        id = 453,
        duration = 20,
        type = "Magic",
        max_stack = 1
    },
    mind_spike_insanity = {
        id = 407468,
        duration = 30,
        max_stack = 4
    },
    -- Sight granted through target's eyes.
    -- https://wowhead.com/beta/spell=2096
    mind_vision = {
        id = 2096,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    mindbender = {
        duration = 15,
        max_stack = 1,
    },
    -- Talent / Covenant: The next $w2 damage and $w5 healing dealt will be reversed.
    -- https://wowhead.com/beta/spell=323673
    mindgames = {
        id = 375901,
        duration = 5,
        type = "Magic",
        max_stack = 1,
        copy = 323673
    },
    mind_trauma = {
        id = 247776,
        duration = 15,
        max_stack = 1
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=10060
    power_infusion = {
        id = 10060,
        duration = 15,
        max_stack = 1
    },
    power_surge = {
        duration = 10,
        tick_time = 5,
        max_stack = 1
    },
    -- Stamina increased by $w1%.$?$w2>0[  Magic damage taken reduced by $w2%.][]
    -- https://wowhead.com/beta/spell=21562
    power_word_fortitude = {
        id = 21562,
        duration = 3600,
        type = "Magic",
        max_stack = 1,
        shared = "player", -- use anyone's buff on the player, not just player's.
    },
    -- Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=17
    power_word_shield = {
        id = 17,
        duration = 15,
        mechanic = "shield",
        type = "Magic",
        max_stack = 1
    },
    protective_light = {
        id = 193065,
        duration = 10,
        max_stack = 1,
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=64044
    psychic_horror = {
        id = 64044,
        duration = 4,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Disoriented.
    -- https://wowhead.com/beta/spell=8122
    psychic_scream = {
        id = 8122,
        duration = 8,
        mechanic = "flee",
        type = "Magic",
        max_stack = 1
    },
    -- $w1 Radiant damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=204213
    purge_the_wicked = {
        id = 204213,
        duration = 20,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Healing $w1 health every $t1 sec.
    -- https://wowhead.com/beta/spell=139
    renew = {
        id = 139,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    rhapsody = {
        id = 390636,
        duration = 3600,
        max_stack = 20
    },
    -- Taking $s2% increased damage from the Priest.
    -- https://wowhead.com/beta/spell=214621
    schism = {
        id = 214621,
        duration = 9,
        type = "Magic",
        max_stack = 1
    },
    -- Shadow Word: Pain and Vampiric Touch are dealing damage $w2% faster.
    screams_of_the_void = {
        id = 393919,
        duration = 3,
        max_stack = 1,
    },
    -- Talent: Shackled.
    -- https://wowhead.com/beta/spell=9484
    shackle_undead = {
        id = 9484,
        duration = 50,
        mechanic = "shackle",
        type = "Magic",
        max_stack = 1
    },
    shadow_crash_debuff = {
        id = 342385,
        duration = 15,
        max_stack = 2
    },
    -- Suffering $w2 Shadow damage every $t2 sec.
    -- https://wowhead.com/beta/spell=589
    shadow_word_pain = {
        id = 589,
        duration = function() return talent.misery.enabled and 21 or 16 end,
        tick_time = function () return 2 * haste * ( 1 - 0.4 * ( buff.screams_of_the_void.up and talent.screams_of_the_void.rank or 0 ) ) end,
        type = "Magic",
        max_stack = 1,
    },
    -- Talent: 343726
    -- https://wowhead.com/beta/spell=34433
    shadowfiend = {
        id = 34433,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Spell damage dealt increased by $s1%.
    -- https://wowhead.com/beta/spell=232698
    shadowform = {
        id = 232698,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    shadowy_apparitions = {
        id = 78203,
    },
    shadowy_insight = {
        id = 375981,
        duration = 10,
        max_stack = 1,
        copy = 124430
    },
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=15487
    silence = {
        id = 15487,
        duration = 4,
        mechanic = "silence",
        type = "Magic",
        max_stack = 1
    },
    -- Taking Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=363656
    torment_mind = {
        id = 363656,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Increases damage and healing by $w1%.
    -- https://wowhead.com/beta/spell=390978
    twist_of_fate = {
        id = 390978,
        duration = 8,
        max_stack = 1
    },
    -- Absorbing $w3 damage.
    ultimate_penitence = {
        id = 421453,
        duration = 6.0,
        max_stack = 1,
    },
    unfurling_darkness = {
        id = 341282,
        duration = 15,
        max_stack = 1,
    },
    unfurling_darkness_icd = {
        id = 341291,
        duration = 15,
        max_stack = 1
    },
    -- Suffering $w1 damage every $t1 sec. When damaged, the attacker is healed for $325118m1.
    -- https://wowhead.com/beta/spell=325203
    unholy_transfusion = {
        id = 325203,
        duration = 15,
        tick_time = 3,
        type = "Magic",
        max_stack = 1
    },
    -- $15286s1% of any single-target Shadow spell damage you deal heals a nearby ally.
    vampiric_embrace = {
        id = 15286,
        duration = 12.0,
        tick_time = 0.5,
        pandemic = true,
        max_stack = 1,
    },
    -- Suffering $w2 Shadow damage every $t2 sec.
    -- https://wowhead.com/beta/spell=34914
    vampiric_touch = {
        id = 34914,
        duration = 21,
        tick_time = function () return 3 * haste * ( 1 - 0.4 * ( buff.screams_of_the_void.up and talent.screams_of_the_void.rank or 0 ) ) end,
        type = "Magic",
        max_stack = 1
    },
    void_bolt = {
        id = 228266,
    },
    -- Talent: A Shadowy tendril is appearing under you.
    -- https://wowhead.com/beta/spell=108920
    void_tendrils_root = {
        id = 108920,
        duration = 0.5,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Dealing $s1 Shadow damage to the target every $t1 sec.
    -- https://wowhead.com/beta/spell=263165
    void_torrent = {
        id = 263165,
        duration = 3,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: |cFFFFFFFFGenerates ${$s1*$s2/100} Insanity over $d.|r
    -- https://wowhead.com/beta/spell=289577
    void_torrent_insanity = {
        id = 289577,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    voidform = {
        id = 194249,
        duration = 15, -- function () return talent.legacy_of_the_void.enabled and 3600 or 15 end,
        max_stack = 1,
    },
    void_tendril_mind_flay = {
        id = 193473,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    void_lasher_mind_sear = {
        id = 394976,
        duration = 15,
        tick_time = 1,
        max_stack = 1
    },
    weakened_soul = {
        id = 6788,
        duration = function () return 7.5 * haste end,
        max_stack = 1,
    },
    -- The damage of your next Smite is increased by $w1%, or the absorb of your next Power Word: Shield is increased by $w2%.
    weal_and_woe = {
        id = 390787,
        duration = 20.0,
        max_stack = 1,
    },
    -- Talent: Damage and healing of Smite and Holy Nova is increased by $s1%.
    -- https://wowhead.com/beta/spell=390933
    words_of_the_pious = {
        id = 390933,
        duration = 12,
        max_stack = 1
    },

    -- Azerite Powers
    chorus_of_insanity = {
        id = 279572,
        duration = 120,
        max_stack = 120,
    },
    death_denied = {
        id = 287723,
        duration = 10,
        max_stack = 1,
    },
    depth_of_the_shadows = {
        id = 275544,
        duration = 12,
        max_stack = 30
    },
    searing_dialogue = {
        id = 288371,
        duration = 1,
        max_stack = 1
    },
    thought_harvester = {
        id = 288343,
        duration = 20,
        max_stack = 1,
        copy = "harvested_thoughts" -- SimC uses this name (carryover from Legion?)
    },

    -- Legendaries (Shadowlands)
    measured_contemplation = {
        id = 341824,
        duration = 3600,
        max_stack = 4
    },
    shadow_word_manipulation = {
        id = 357028,
        duration = 10,
        max_stack = 1,
    },

    -- Conduits
    dissonant_echoes = {
        id = 343144,
        duration = 10,
        max_stack = 1,
    },
    lights_inspiration = {
        id = 337749,
        duration = 5,
        max_stack = 1
    },
    translucent_image = {
        id = 337661,
        duration = 5,
        max_stack = 1
    },
} )





-- Abilities
spec:RegisterAbilities( {
    -- Talent: Places a feather at the target location, granting the first ally to walk through it $121557s1% increased movement speed for $121557d. Only 3 feathers can be placed at one time.
    angelic_feather = {
        id = 121536,
        cast = 0,
        charges = 3,
        cooldown = 20,
        recharge = 20,
        gcd = "spell",
        school = "holy",

        talent = "angelic_feather",
        startsCombat = false,

        handler = function ()
        end,
    },

    -- Heals the target and ${$s2-1} injured allies within $A1 yards of the target for $s1.
    circle_of_healing = {
        id = 204883,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holy",

        spend = 0.033,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
        end,
    },

    -- Talent: Increases your non-periodic Shadow damage by $s1% for 20 sec.    |cFFFFFFFFGenerates ${$m2/100} Insanity.|r
    dark_ascension = {
        id = 391109,
        cast = function ()
            if pvptalent.void_origins.enabled then return 0 end
            return 1.5 * haste
        end,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        spend = -30,
        spendType = "insanity",

        talent = "dark_ascension",
        startsCombat = false,
        toggle = "cooldowns",

        handler = function ()
            applyBuff( "dark_ascension" )
            if talent.ancient_madness.enabled then applyBuff( "ancient_madness", nil, 20 ) end
        end,
    },

    desperate_prayer = {
        id = 19236,
        cast = 0,
        cooldown = function() return talent.angels_mercy.enabled and 70 or 90 end,
        gcd = "off",
        school = "holy",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "desperate_prayer" )
            health.max = health.max * 1.25
            gain( 0.8 * health.max, "health" )
            if conduit.lights_inspiration.enabled then applyBuff( "lights_inspiration" ) end
        end,
    },

    -- Talent: Afflicts the target with a disease that instantly causes $s1 Shadow damage plus an additional $o2 Shadow damage over $d. Heals you for ${$e2*100}% of damage dealt.    If this effect is reapplied, any remaining damage will be added to the new Devouring Plague.
    devouring_plague = {
        id = 335467,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = function ()
            if buff.mind_devourer.up then return 0 end
            return 50 + ( talent.distorted_reality.enabled and 5 or 0 ) + ( talent.minds_eye.enabled and -5 or 0 )
        end,
        spendType = "insanity",

        talent = "devouring_plague",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "devouring_plague" )
            if buff.voidform.up then buff.voidform.expires = buff.voidform.expires + 2.5 end

            removeBuff( "mind_devourer" )
            removeBuff( "gathering_shadows" )

            if talent.surge_of_insanity.enabled then
                addStack( talent.mind_spike.enabled and "mind_spike_insanity" or "mind_flay_insanity" )
            end

            if set_bonus.tier29_4pc > 0 then applyBuff( "dark_reveries" ) end

            if set_bonus.tier30_4pc > 0 then
                -- TODO: Revisit if shroud procs on 4th cast or 5th (simc implementation looks like it procs on 5th).
                if buff.darkflame_embers.stack == 3 then
                    removeBuff( "darkflame_embers" )
                    applyBuff( "darkflame_shroud" )
                else
                    addStack( "darkflame_embers" )
                end
            end
        end,
    },

    -- Talent: Dispels Magic on the enemy target, removing $m1 beneficial Magic $leffect:effects;.
    dispel_magic = {
        id = 528,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function () return ( state.spec.shadow and 0.14 or 0.02 ) * ( 1 + conduit.clear_mind.mod * 0.01 ) * ( 1 - 0.1 * talent.mental_agility.rank ) end,
        spendType = "mana",

        talent = "dispel_magic",
        startsCombat = false,

        buff = "dispellable_magic",
        handler = function ()
            removeBuff( "dispellable_magic" )
        end,

        -- Affected by:
        -- mental_agility[341167] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- mental_agility[341167] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- mental_agility[341167] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Talent: Disperse into pure shadow energy, reducing all damage taken by $s1% for $d and healing you for $?s288733[${$s5+$288733s2}][$s5]% of your maximum health over its duration, but you are unable to attack or cast spells.    Increases movement speed by $s4% and makes you immune to all movement impairing effects.    Castable while stunned, feared, or silenced.
    dispersion = {
        id = 47585,
        cast = 0,
        cooldown = function () return talent.intangibility.enabled and 90 or 120 end,
        gcd = "spell",
        school = "shadow",

        talent = "dispersion",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "dispersion" )
            setCooldown( "global_cooldown", 6 )
        end,
    },

    -- Talent: Throw a Divine Star forward 24 yds, healing allies in its path for $110745s1 and dealing $122128s1 Shadow damage to enemies. After reaching its destination, the Divine Star returns to you, healing allies and damaging enemies in its path again. Healing reduced beyond $s1 targets.
    divine_star = {
        id = 122121,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "divine_star",
        startsCombat = true,

        handler = function ()
            if time > 0 then gain( 6, "insanity" ) end
        end,
    },

    -- Talent: Controls a mind up to 1 level above yours for $d while still controlling your own mind. Does not work versus Demonic, Mechanical, or Undead beings$?a205477[][ or players]. This spell shares diminishing returns with other disorienting effects.
    dominate_mind = {
        id = 205364,
        cast = 1.8,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "dominate_mind",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "dominate_mind" )
        end,
    },

    -- Fade out, removing all your threat and reducing enemies' attack range against you for $d.
    fade = {
        id = 586,
        cast = 0,
        cooldown = function() return 30 - 5 * talent.improved_fade.rank end,
        gcd = "off",
        school = "shadow",

        startsCombat = false,

        handler = function ()
            applyBuff( "fade" )
            if conduit.translucent_image.enabled then applyBuff( "translucent_image" ) end
        end,
    },

    -- A fast spell that heals an ally for $s1.
    flash_heal = {
        id = 2061,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = function() return buff.surge_of_light.up and 0 or 0.10 end,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            removeBuff( "from_darkness_comes_light" )
            removeStack( "surge_of_light" )
            if talent.protective_light.enabled then applyBuff( "protective_light" ) end
        end,
    },

    -- Talent: Creates a ring of Shadow energy around you that quickly expands to a 30 yd radius, healing allies for $120692s1 and dealing $120696s1 Shadow damage to enemies.    Healing reduced beyond $s1 targets.
    halo = {
        id = 120644,
        cast = 1.5,
        cooldown = 40,
        gcd = "spell",
        school = "shadow",

        spend = 0.04,
        spendType = "mana",

        talent = "halo",
        startsCombat = true,

        handler = function ()
            gain( 10, "insanity" )
            if talent.power_surge.enabled then applyBuff( "power_surge" ) end
        end,
    },

    -- Talent: An explosion of holy light around you deals up to $s1 Holy damage to enemies and up to $281265s1 healing to allies within $A1 yds, reduced if there are more than $s3 targets.
    holy_nova = {
        id = 132157,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",
        damage = 1,

        spend = 0.016,
        spendType = "mana",

        talent = "holy_nova",
        startsCombat = true,

        handler = function ()
            removeBuff( "rhapsody" )
        end,
    },

    -- Talent: Pulls the spirit of a party or raid member, instantly moving them directly in front of you.
    leap_of_faith = {
        id = 73325,
        cast = 0,
        charges = function () return legendary.vault_of_heavens.enabled and 2 or nil end,
        cooldown = function() return talent.move_with_grace.enabled and 60 or 90 end,
        recharge = function () return legendary.vault_of_heavens.enabled and ( talent.move_with_grace.enabled and 60 or 90 ) or nil end,
        gcd = "off",
        school = "holy",

        spend = 0.026,
        spendType = "mana",

        talent = "leap_of_faith",
        startsCombat = false,
        toggle = "interrupts",

        usable = function() return group, "requires an ally" end,
        handler = function ()
            if talent.body_and_soul.enabled then applyBuff( "body_and_soul" ) end
            if azerite.death_denied.enabled then applyBuff( "death_denied" ) end
            if legendary.vault_of_heavens.enabled then setDistance( 5 ) end
        end,
    },

    --[[  Talent: You pull your spirit to an ally, instantly moving you directly in front of them.
    leap_of_faith = {
        id = 336471,
        cast = 0,
        charges = 2,
        cooldown = 1.5,
        recharge = 90,
        gcd = "off",
        school = "holy",

        talent = "leap_of_faith",
        startsCombat = false,

        handler = function ()
        end,
    }, ]]

    -- Levitates a party or raid member for $111759d, floating a few feet above the ground, granting slow fall, and allowing travel over water.
    levitate = {
        id = 1706,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.009,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "levitate" )
        end,
    },

    --[[ Invoke the Light's wrath, dealing $s1 Radiant damage to the target, increased by $s2% per ally affected by your Atonement.
    lights_wrath = {
        id = 373178,
        cast = 2.5,
        cooldown = 90,
        gcd = "spell",
        school = "holyfire",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    }, ]]

    -- Talent: Dispels magic in a $32375a1 yard radius, removing all harmful Magic from $s4 friendly targets and $32592m1 beneficial Magic $leffect:effects; from $s4 enemy targets. Potent enough to remove Magic that is normally undispellable.
    mass_dispel = {
        id = 32375,
        cast = 1.5,
        cooldown = function () return pvptalent.improved_mass_dispel.enabled and 60 or 120 end,
        gcd = "spell",
        school = "holy",

        spend = function () return 0.20 * ( talent.mental_agility.enabled and 0.5 or 1 ) end,
        spendType = "mana",

        talent = "mass_dispel",
        startsCombat = false,

        usable = function () return buff.dispellable_magic.up or debuff.dispellable_magic.up, "requires a dispellable magic effect" end,
        handler = function ()
            removeBuff( "dispellable_magic" )
            removeDebuff( "player", "dispellable_magic" )
            if time > 0 and state.spec.shadow then gain( 6, "insanity" ) end
        end,
    },

    -- Blasts the target's mind for $s1 Shadow damage$?s424509[ and increases your spell damage to the target by $424509s1% for $214621d.][.]$?s137033[; Generates ${$s2/100} Insanity.][]
    mind_blast = {
        id = function() return talent.void_blast.enabled and buff.entropic_rift.up and 450405 or 8092 end,
        cast = function () return buff.shadowy_insight.up and 0 or ( 1.5 * haste ) end,
        charges = function ()
            if talent.thought_harvester.enabled then return 2 end
        end,
        cooldown = 9,
        recharge = function ()
            if talent.thought_harvester.enabled then return 9 * haste end
        end,
        hasteCD = true,
        gcd = "spell",
        school = "shadow",

        spend = function() return set_bonus.tier30_2pc > 0 and buff.shadowy_insight.up and -10 or -6 end,
        spendType = "insanity",

        startsCombat = true,
        velocity = 15,

        handler = function ()
            removeBuff( "empty_mind" )
            removeBuff( "harvested_thoughts" )
            removeBuff( "mind_melt" )
            removeBuff( "shadowy_insight" )

            if talent.inescapable_torment.enabled then
                if buff.mindbender.up then buff.mindbender.expires = buff.mindbender.expires + 0.7
                elseif buff.shadowfiend.up then buff.shadowfiend.expires = buff.shadowfiend.expires + 0.7 end
            end

            if talent.schism.enabled then applyDebuff( "target", "schism" ) end

            if set_bonus.tier29_2pc > 0 then
                addStack( "gathering_shadows" )
            end
        end,

        copy = { 8092, "void_blast", 450405 }
    },

    -- Talent: Controls a mind up to 1 level above yours for $d. Does not work versus Demonic$?A320889[][, Undead,] or Mechanical beings. Shares diminishing returns with other disorienting effects.
    mind_control = {
        id = 605,
        cast = 1.8,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "mind_control",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mind_control" )
        end,
    },

    -- Assaults the target's mind with Shadow energy, causing $o1 Shadow damage over $d and slowing their movement speed by $s2%.    |cFFFFFFFFGenerates ${$s4*$s3/100} Insanity over the duration.|r
    mind_flay = {
        id = function() return buff.mind_flay_insanity.up and 391403 or 15407 end,
        known = 15407,
        cast = function() return ( buff.mind_flay_insanity.up and 1.5 or 4.5 ) * haste end,
        channeled = true,
        breakable = true,
        cooldown = 0,
        hasteCD = true,
        gcd = "spell",
        school = "shadow",

        spend = 0,
        spendType = "insanity",

        startsCombat = true,
        texture = function()
            if buff.mind_flay_insanity.up then return 425954 end
            return 136208
        end,
        notalent = "mind_spike",
        nobuff = "boon_of_the_ascended",
        bind = "ascended_blast",

        aura = function() return buff.mind_flay_insanity.up and "mind_flay_insanity" or "mind_flay" end,
        tick_time = function () return class.auras.mind_flay.tick_time end,

        start = function ()
            if buff.mind_flay_insanity.up then
                removeStack( "mind_flay_insanity" )
                applyDebuff( "target", "mind_flay_insanity_dot" )
            else
                applyDebuff( "target", "mind_flay" )
            end
            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end
            if talent.mental_decay.enabled then
                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 1 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 1 end
            end
        end,

        tick = function ()
            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end
            if talent.mental_decay.enabled then
                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 1 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 1 end
            end
        end,

        breakchannel = function ()
            removeDebuff( "target", "mind_flay" )
            removeDebuff( "target", "mind_flay_insanity_dot" )
        end,

        copy = { "mind_flay_insanity", 391403 }
    },

    -- Soothes enemies in the target area, reducing the range at which they will attack you by $s1 yards. Only affects Humanoid and Dragonkin targets. Does not cause threat. Lasts $d.
    mind_soothe = {
        id = 453,
        cast = 0,
        cooldown = 5,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mind_soothe" )
        end,
    },

    -- Talent: Blasts the target for $s1 Shadowfrost damage.$?s391090[    Mind Spike reduces the cast time of your next Mind Blast by $391092s1% and increases its critical strike chance by $391092s2%, stacking up to $391092U times.][]    |cFFFFFFFFGenerates ${$s2/100} Insanity|r$?s391137[ |cFFFFFFFFand an additional ${$s3/100} Insanity from a critical strike.|r][.]
    mind_spike = {
        id = 73510,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "shadowfrost",

        spend = -4,
        spendType = "insanity",

        talent = "mind_spike",
        startsCombat = true,
        nobuff = "mind_flay_insanity",

        handler = function ()
            if talent.mental_decay.enabled then
                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 2 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 2 end
            end

            if talent.mind_melt.enabled then addStack( "mind_melt" ) end

            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end
        end,

        bind = "mind_spike_insanity"
    },

    -- Implemented separately, unlike mind_flay_insanity, based on how it is used in the SimC APL.
    mind_spike_insanity = {
        id = 407466,
        known = 73510,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "shadowfrost",

        spend = -12,
        spendType = "insanity",

        talent = "mind_spike",
        startsCombat = true,
        buff = "mind_spike_insanity",

        handler = function ()
            removeStack( "mind_spike_insanity" )

            if talent.mental_decay.enabled then
                if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 2 end
                if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 2 end
            end

            if talent.mind_melt.enabled then addStack( "mind_melt" ) end

            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end
        end,

        bind = "mind_spike"
    },

    -- Allows the caster to see through the target's eyes for $d. Will not work if the target is in another instance or on another continent.
    mind_vision = {
        id = 2096,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "mind_vision" )
        end,
    },

    -- Talent: Summons a Mindbender to attack the target for $d.     |cFFFFFFFFGenerates ${$123051m1/100}.1% mana each time the Mindbender attacks.|r
    mindbender = {
        id = function()
            if talent.voidwrath.enabled then
                return 451235
            end
            if talent.mindbender.enabled then
                return state.spec.discipline and 123040 or 200174
            end
            return 34433
        end,
        known = 34433,
        flash = { 123040, 200174, 34433 },
        cast = 0,
        cooldown = function () return talent.mindbender.enabled and 60 or 180 end,
        gcd = "spell",
        school = "shadow",

        toggle = function()
            if not talent.mindbender.enabled then return "cooldowns" end
        end,
        startsCombat = true,
        -- texture = function() return talent.mindbender.enabled and 136214 or 136199 end,

        handler = function ()
            local fiend = talent.mindbender.enabled and "mindbender" or "shadowfiend"
            summonPet( fiend, 15 )
            applyBuff( fiend )

            if talent.shadow_covenant.enabled then applyBuff( "shadow_covenant" ) end
        end,

        copy = { "shadowfiend", 34433, 123040, 200174, "voidwraith", 451235 }
    },

    -- Covenant (Venthyr): Assault an enemy's mind, dealing ${$s1*$m3/100} Shadow damage and briefly reversing their perception of reality.    $?c3[For $d, the next $<damage> damage they deal will heal their target, and the next $<healing> healing they deal will damage their target.    |cFFFFFFFFReversed damage and healing generate up to ${$323706s2*2} Insanity.|r]  ][For $d, the next $<damage> damage they deal will heal their target, and the next $<healing> healing they deal will damage their target.    |cFFFFFFFFReversed damage and healing restore up to ${$323706s3*2}% mana.|r]
    mindgames = {
        id = function() return pvptalent.mindgames.enabled and 375901 or 323673 end,
        cast = 1.5,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",
        damage = 1,

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mindgames" )
            gain( 10, "insanity" )
        end,

        copy = { 375901, 323673 }
    },

    -- Talent: Infuses the target with power for $d, increasing haste by $s1%.
    power_infusion = {
        id = 10060,
        cast = 0,
        cooldown = function () return 120 - ( conduit.power_unto_others.mod and group and conduit.power_unto_others.mod or 0 ) end,
        gcd = "off",
        school = "holy",

        talent = "power_infusion",
        startsCombat = false,

        toggle = "cooldowns",
        indicator = function () return group and ( talent.twins_of_the_sun_priestess.enabled or legendary.twins_of_the_sun_priestess.enabled ) and "cycle" or nil end,

        handler = function ()
            applyBuff( "power_infusion" )
            stat.haste = stat.haste + 0.25
        end,
    },

    -- Infuses the target with vitality, increasing their Stamina by $s1% for $d.    If the target is in your party or raid, all party and raid members will be affected.
    power_word_fortitude = {
        id = 21562,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        nobuff = "power_word_fortitude",

        handler = function ()
            applyBuff( "power_word_fortitude" )
        end,
    },

    -- Talent: A word of holy power that heals the target for $s1. ; Only usable if the target is below $s2% health.
    power_word_life = {
        id = 373481,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "holy",

        spend = function () return state.spec.shadow and 0.1 or 0.025 end,
        spendType = "mana",

        talent = "power_word_life",
        startsCombat = false,
        usable = function() return health.pct < 35, "requires target below 35% health" end,

        handler = function ()
            gain( 7.5 * stat.spell_power, "health" )
        end,
    },

    -- Shields an ally for $d, absorbing ${$<shield>*$<aegis>*$<benevolence>} damage.
    power_word_shield = {
        id = 17,
        cast = 0,
        cooldown = function() return buff.rapture.up and 0 or ( 7.5 * haste ) end,
        gcd = "spell",
        school = "holy",

        spend = 0.10,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "power_word_shield" )

            if talent.body_and_soul.enabled then
                applyBuff( "body_and_soul" )
            end

            if state.spec.discipline then
                applyBuff( "atonement" )
                removeBuff( "shield_of_absolution" )
                removeBuff( "weal_and_woe" )

                if set_bonus.tier29_2pc > 0 then
                    applyBuff( "light_weaving" )
                end
                if talent.borrowed_time.enabled then
                    applyBuff( "borrowed_time" )
                end
            else
                applyDebuff( "player", "weakened_soul" )
            end
        end,
    },

    -- Talent: Places a ward on an ally that heals them for $33110s1 the next time they take damage, and then jumps to another ally within $155793a1 yds. Jumps up to $s1 times and lasts $41635d after each jump.
    prayer_of_mending = {
        id = 33076,
        cast = 0,
        cooldown = 12,
        hasteCD = true,
        gcd = "spell",
        school = "holy",

        spend = 0.04,
        spendType = "mana",

        talent = "prayer_of_mending",
        startsCombat = false,

        handler = function ()
            applyBuff( "prayer_of_mending" )
        end,
    },

    -- Talent: Terrifies the target in place, stunning them for $d.
    psychic_horror = {
        id = 64044,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",

        talent = "psychic_horror",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "psychic_horror" )
        end,
    },

    -- Lets out a psychic scream, causing $i enemies within $A1 yards to flee, disorienting them for $d. Damage may interrupt the effect.
    psychic_scream = {
        id = 8122,
        cast = 0,
        cooldown = function() return talent.psychic_void.enabled and 30 or 45 end,
        gcd = "spell",
        school = "shadow",

        spend = 0.012,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "psychic_scream" )
        end,
    },

    -- PvP Talent: [199845] Deals up to $s2% of the target's total health in Shadow damage every $t1 sec. Also slows their movement speed by $s3% and reduces healing received by $s4%.
    psyfiend = {
        id = 211522,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        startsCombat = true,
        pvptalent = "psyfiend",

        function()
            -- Just assume the fiend is immediately flaying your target.
            applyDebuff( "target", "psyflay" )
        end,

        auras = {
            psyflay = {
                id = 199845,
                duration = 12,
                max_stack = 1
            }
        }

        -- Effects:
        -- [x] #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 4.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- [x] #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 199824, 'target': TARGET_UNIT_CASTER, }
    },

    -- Talent: Removes all Disease effects from a friendly target.
    purify_disease = {
        id = 213634,
        cast = 0,
        charges = 1,
        cooldown = 8,
        recharge = 8,
        gcd = "spell",
        school = "holy",

        spend = function() return 0.013 * ( talent.mental_agility.enabled and 0.5 or 1 ) end,
        spendType = "mana",

        talent = "purify_disease",
        startsCombat = false,
        debuff = "dispellable_disease",

        handler = function ()
            removeDebuff( "player", "dispellable_disease" )
            -- if time > 0 then gain( 6, "insanity" ) end
        end,
    },

    -- Talent: Fill the target with faith in the light, healing for $o1 over $d.
    renew = {
        id = 139,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.04,
        spendType = "mana",

        talent = "renew",
        startsCombat = false,

        handler = function ()
            applyBuff( "renew" )
        end,
    },

    -- Talent: Shackles the target undead enemy for $d, preventing all actions and movement. Damage will cancel the effect. Limit 1.
    shackle_undead = {
        id = 9484,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "holy",

        spend = 0.012,
        spendType = "mana",

        talent = "shackle_undead",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "shackle_undead" )
        end,
    },

    -- Talent: Hurl a bolt of slow-moving Shadow energy at the destination, dealing $205386s1 Shadow damage to all targets within $205386A1 yards and applying Vampiric Touch to $391286s1 of them.    |cFFFFFFFFGenerates $/100;s2 Insanity.|r
    shadow_crash = {
        id = function() return talent.shadow_crash_2.enabled and 457042 or 205385 end,
        cast = 0,
        cooldown = 20,
        gcd = "spell",
        school = "shadow",

        spend = -6,
        spendType = "insanity",

        talent = function()
            return talent.shadow_crash_2.enabled and "shadow_crash_2" or "shadow_crash"
        end,
        startsCombat = false,

        velocity = 2,

        impact = function ()
            removeBuff( "deaths_torment" )
            if talent.whispering_shadows.enabled then
                applyDebuff( "target", "vampiric_touch" )
                active_dot.vampiric_touch = min( active_enemies, active_dot.vampiric_touch + 7 )
            end
        end,

        copy = { 205385, 457042 }
    },

    -- Talent: A word of dark binding that inflicts $s1 Shadow damage to your target. If your target is not killed by Shadow Word: Death, you take backlash damage equal to $s5% of your maximum health.$?A364675[; Damage increased by ${$s3+$364675s2}% to targets below ${$s2+$364675s1}% health.][; Damage increased by $s3% to targets below $s2% health.]$?c3[][]$?s137033[; Generates ${$s4/100} Insanity.][]
    shadow_word_death = {
        id = 32379,
        cast = 0,
        charges = function()
            if buff.deathspeaker.up then return 2 end
        end,
        cooldown = 10,
        recharge = function()
            if buff.deathspeaker.up then return 20 end
        end,
        gcd = "spell",
        school = "shadow",
        damage = 1,

        spend = 0.005,
        spendType = "mana",

        talent = "shadow_word_death",
        startsCombat = true,

        usable = function ()
            if settings.sw_death_protection == 0 then return true end
            return health.percent >= settings.sw_death_protection, "player health [ " .. health.percent .. " ] is below user setting [ " .. settings.sw_death_protection .. " ]"
        end,

        handler = function ()
            gain( 4, "insanity" )

            if set_bonus.tier31_4pc > 0 then
                addStack( "deaths_torment", nil, ( buff.deathspeaker.up or target.health.pct < 20 ) and 3 or 2 )
            end

            removeBuff( "deathspeaker" )
            removeBuff( "zeks_exterminatus" )

            if talent.death_and_madness.enabled then
                applyDebuff( "target", "death_and_madness_debuff" )
            end

            if talent.inescapable_torment.enabled then
                local fiend = talent.mindbender.enabled and "mindbender" or "shadowfiend"
                if buff[ fiend ].up then buff[ fiend ].expires = buff[ fiend ].expires + ( talent.inescapable_torment.rank * 0.5 ) end
                if pet[ fiend ].up then pet[ fiend ].expires = pet[ fiend ].expires + ( talent.inescapable_torment.rank * 0.5 ) end
            end

            if talent.expiation.enabled then
                local swp = talent.purge_the_wicked.enabled and "purge_the_wicked" or "shadow_word_pain"
                if debuff[ swp ].up then
                    if debuff[ swp ].remains <= 6 then removeDebuff( "target", swp )
                    else debuff[ swp ].expires = debuff[ swp ].expires - 6 end
                end
            end

            if legendary.painbreaker_psalm.enabled then
                local power = 0
                if debuff.shadow_word_pain.up then
                    power = power + 15 * min( debuff.shadow_word_pain.remains, 8 ) / 8
                    if debuff.shadow_word_pain.remains < 8 then removeDebuff( "shadow_word_pain" )
                    else debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires - 8 end
                end
                if debuff.vampiric_touch.up then
                    power = power + 15 * min( debuff.vampiric_touch.remains, 8 ) / 8
                    if debuff.vampiric_touch.remains <= 8 then removeDebuff( "vampiric_touch" )
                    else debuff.vampiric_touch.expires = debuff.vampiric_touch.expires - 8 end
                end
                if power > 0 then gain( power, "insanity" ) end
            end

            if legendary.shadowflame_prism.enabled then
                if pet.fiend.active then pet.fiend.expires = pet.fiend.expires + 1 end
            end
        end,
    },

    -- A word of darkness that causes $?a390707[${$s1*(1+$390707s1/100)}][$s1] Shadow damage instantly, and an additional $?a390707[${$o2*(1+$390707s1/100)}][$o2] Shadow damage over $d.$?s137033[    |cFFFFFFFFGenerates ${$m3/100} Insanity.|r][]
    shadow_word_pain = {
        id = 589,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = -3,
        spendType = "insanity",

        startsCombat = true,
        cycle = "shadow_word_pain",

        handler = function ()
            removeBuff( "deaths_torment" )
            applyDebuff( "target", "shadow_word_pain" )
        end,
    },

    -- Assume a Shadowform, increasing your spell damage dealt by $s1%.
    shadowform = {
        id = 232698,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        startsCombat = false,
        essential = true,
        nobuff = function () return buff.voidform.up and "voidform" or "shadowform" end,

        handler = function ()
            applyBuff( "shadowform" )
        end,
    },

    -- Talent: Silences the target, preventing them from casting spells for $d. Against non-players, also interrupts spellcasting and prevents any spell in that school from being cast for $263715d.
    silence = {
        id = 15487,
        cast = 0,
        cooldown = function() return talent.last_word.enabled and 30 or 45 end,
        gcd = "off",
        school = "shadow",

        talent = "silence",
        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            applyDebuff( "target", "silence" )
        end,
    },

    -- Talent: Fills you with the embrace of Shadow energy for $d, causing you to heal a nearby ally for $s1% of any single-target Shadow spell damage you deal.
    vampiric_embrace = {
        id = 15286,
        cast = 0,
        cooldown = function() return talent.sanlayn.enabled and 75 or 120 end,
        gcd = "off",
        school = "shadow",

        talent = "vampiric_embrace",
        startsCombat = false,
        texture = 136230,

        toggle = "defensives",

        handler = function ()
            applyBuff( "vampiric_embrace" )
            -- if time > 0 then gain( 6, "insanity" ) end
        end,
    },

    -- A touch of darkness that causes $34914o2 Shadow damage over $34914d, and heals you for ${$e2*100}% of damage dealt. If Vampiric Touch is dispelled, the dispeller flees in Horror for $87204d.    |cFFFFFFFFGenerates ${$m3/100} Insanity.|r
    vampiric_touch = {
        id = 34914,
        cast = function () return buff.unfurling_darkness.up and 0 or 1.5 * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = -4,
        spendType = "insanity",

        startsCombat = true,
        cycle = function () return talent.misery.enabled and "shadow_word_pain" or "vampiric_touch" end,

        handler = function ()
            applyDebuff( "target", "vampiric_touch" )

            if talent.misery.enabled then
                applyDebuff( "target", "shadow_word_pain" )
            end

            if talent.unfurling_darkness.enabled then
                if buff.unfurling_darkness.up then
                    removeBuff( "unfurling_darkness" )
                elseif debuff.unfurling_darkness_icd.down then
                    applyBuff( "unfurling_darkness" )
                    applyDebuff( "player", "unfurling_darkness_icd" )
                end
            end
        end,
    },

    -- Sends a bolt of pure void energy at the enemy, causing $s2 Shadow damage$?s193225[, refreshing the duration of Devouring Plague on the target][]$?a231688[ and extending the duration of Shadow Word: Pain and Vampiric Touch on all nearby targets by $<ext> sec][].     Requires Voidform.    |cFFFFFFFFGenerates $/100;s3 Insanity.|r
    void_bolt = {
        id = 205448,
        known = 228260,
        cast = 0,
        cooldown = 6,
        hasteCD = true,
        gcd = "spell",
        school = "shadow",

        spend = -10,
        spendType = "insanity",

        startsCombat = true,
        velocity = 40,
        buff = function () return buff.dissonant_echoes.up and "dissonant_echoes" or "voidform" end,
        bind = "void_eruption",

        handler = function ()
            removeBuff( "dissonant_echoes" )

            if debuff.shadow_word_pain.up then debuff.shadow_word_pain.expires = debuff.shadow_word_pain.expires + 3 end
            if debuff.vampiric_touch.up then debuff.vampiric_touch.expires = debuff.vampiric_touch.expires + 3 end
            if talent.legacy_of_the_void.enabled and debuff.devouring_plague.up then debuff.devouring_plague.expires = query_time + debuff.devouring_plague.duration end

            removeBuff( "anunds_last_breath" )
        end,

        impact = function ()
        end,

        copy = 343355,
    },

    -- Talent: Releases an explosive blast of pure void energy, activating Voidform and causing ${$228360s1*2} Shadow damage to all enemies within $a1 yds of your target.    During Voidform, this ability is replaced by Void Bolt.    Each $s4 Insanity spent during Voidform increases the duration of Voidform by ${$s3/1000}.1 sec.
    void_eruption = {
        id = 228260,
        cast = function ()
            if pvptalent.void_origins.enabled then return 0 end
            return haste * 1.5
        end,
        cooldown = 120,
        gcd = "spell",
        school = "shadow",

        talent = "void_eruption",
        startsCombat = true,
        toggle = "cooldowns",
        nobuff = function () return buff.dissonant_echoes.up and "dissonant_echoes" or "voidform" end,
        bind = "void_bolt",

        cooldown_ready = function ()
            return cooldown.void_eruption.remains == 0 and buff.voidform.down
        end,

        handler = function ()
            applyBuff( "voidform" )
            if talent.ancient_madness.enabled then applyBuff( "ancient_madness", nil, 20 ) end
        end,
    },

    -- Talent: You and the currently targeted party or raid member swap health percentages. Increases the lower health percentage of the two to $s1% if below that amount.
    void_shift = {
        id = 108968,
        cast = 0,
        cooldown = 300,
        gcd = "off",
        school = "shadow",

        talent = "void_shift",
        startsCombat = false,

        toggle = "defensives",
        usable = function() return group, "requires an ally" end,

        handler = function ()
        end,
    },

    -- Talent: Summons shadowy tendrils, rooting up to $108920i enemy targets within $108920A1 yards for $114404d or until the tendril is killed.
    void_tendrils = {
        id = 108920,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "void_tendrils",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "void_tendrils_root" )
        end,
    },

    -- Talent: Channel a torrent of void energy into the target, dealing $o Shadow damage over $d.    |cFFFFFFFFGenerates ${$289577s1*$289577s2/100} Insanity over the duration.|r
    void_torrent = {
        id = 263165,
        cast = 3,
        channeled = true,
        fixedCast = true,
        cooldown = function() return 45 - 15 * talent.malediction.rank end,
        gcd = "spell",
        school = "shadow",

        spend = -15,
        spendType = "insanity",

        talent = "void_torrent",
        startsCombat = true,
        aura = "void_torrent",
        tick_time = function () return class.auras.void_torrent.tick_time end,

        breakchannel = function ()
            removeDebuff( "target", "void_torrent" )
        end,

        start = function ()
            applyDebuff( "target", "void_torrent" )
            applyDebuff( "target", "devouring_plague" )
            if debuff.vampiric_touch.up then applyDebuff( "target", "vampiric_touch" ) end -- This should refresh/pandemic properly.
            if debuff.shadow_word_pain.up then applyDebuff( "target", "shadow_word_pain" ) end -- This should refresh/pandemic properly.
            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end
            if talent.entropic_rift.enabled then applyBuff( "entropic_rift" ) end
            if talent.idol_of_cthun.enabled then applyDebuff( "target", "void_tendril_mind_flay" ) end
        end,

        tick = function ()
            if debuff.vampiric_touch.up then applyDebuff( "target", "vampiric_touch" ) end -- This should refresh/pandemic properly.
            if debuff.shadow_word_pain.up then applyDebuff( "target", "shadow_word_pain" ) end -- This should refresh/pandemic properly.
            if talent.dark_evangelism.enabled then addStack( "dark_evangelism" ) end
        end,
    },
} )


spec:RegisterRanges( "mind_blast", "dispel_magic" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,

    damage = true,
    damageExpiration = 6,

    potion = "potion_of_spectral_intellect",

    package = "Shadow",
} )


spec:RegisterSetting( "pad_void_bolt", true, {
    name = "Pad |T1035040:0|t Void Bolt Cooldown",
    desc = "If checked, the addon will treat |T1035040:0|t Void Bolt's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Voidform.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "pad_ascended_blast", true, {
    name = "Pad |T3528286:0|t Ascended Blast Cooldown",
    desc = "If checked, the addon will treat |T3528286:0|t Ascended Blast's cooldown as slightly shorter, to help ensure that it is recommended as frequently as possible during Boon of the Ascended.",
    type = "toggle",
    width = "full"
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


spec:RegisterPack( "Shadow", 20240822, [[Hekili:D3t)ZTTnw(3INDwfPyBfjzRuNSwQtBsZTjZ1UDQtV(d3CwIIIYIRPi5YpSJVXJ(B)EVhaibabiPKLtZEZUB2ekqGhE499hexp86pF9vlDY8U(xgny05dUy0O(dV48Zhn(6RYEi276RIDCV15g4Ve6Sb(ZRw7Sm6E8Xpee5SeF90O8ex4NwNLfN(2x9QB8ZwNVOVB0MxL6VjpWjZpk0nXzvg(VDF11xTi3pi7JHxVWWAF23n8nxFLtE26Oey5838oyM9xU0JnCVu3RVch(PdU40rJE725FoXp8wVSTZZJXjB7N2(jXVpCi87)y(QvBN)Rr37LSD(FeLSeE2hIsY8ZYxQm6b4O)HLl3o)Q)4TV3ZjB925EHzjpSD(QKOnBNdqVyv(BBN7egLTgNtPhxoDF3PJEdcC375C725zoj3GGy69oXBNheDJVRYqVah6Apa(CqGeqG(HxFvGFAwkIHx5he4La)TFHoV8cDwe4T86FeWtUiY96RUZztSFIV7SSOC31xFL7dUbEZylBk(AeMlXpMn835KcqZ)f)LG1gFlamJ2o3nkmnFdak)E4Q8Ka)WB2o)9oj3g6LMEY25XjER8sONMHaSyNDVpIUOhfaOAC6FF0N3oFzEcD(d4lauVditaOidMbhKmy1Q(5ILz2s(Q0pp(6mGMqBRw(ElJY6V07oGSdFT4aNBY96N4TXXpmD78PSLkkS)g)WLZsJ9V1RVlSHNL5J7RhFC78JqapaoCLhJyTUkndqkzewtGFDDccMX(hZWJf2HZmgpH3MyK6YB5m(bf8UNzf6zyS(R9CcYw3p2fWuxUD(ObmiR725eAzjs)LgdupEjacH9JPEzZwefMN2pZ3l5SHZgfdhE92oVdGOnHuY8DVf(NL7JuI9D29aBWmAjmqQaq)51a9eAZhoOCDIXbaKCjBWNXhpbnXWoCLVx4Y(IJ9DecgBfci0ZDr(lxbRBbQXnkkaM3W(iv0mNuxVWuKgq870Brh2mKeHvlHkDmhccV2kiaNla5ahGjkojsL1obrASBx5CNhkIGXHnAa8o(GmjNLlH)MtIhc(BiEQ0iaMXf)7SWOVZeIxyzIkj8nFa8M6EVvbopysiJFiGHsYJZM5VcOvaQV0PtgP88nB8w6Jc9VcgV7AhuqhTGdhGRyXbI)Dan2Suy2LbdCC6YalpxsC8xoZ7oKyeXTavkD4G8wDiM(kmqNh7wH0euvLUw7e83tHdjMUVTZFhoaqK3A)a4PBIUJo6CWZss63PXj(raq9GqseowVqXb(9WzZ25G2d6yhMbemrym1de(cGnTl1f)Tl8p1a7CfGC1B7YwaHsVV45MN51gXz0Mqxk4HhU2nedct6Y2m9(Xez5EGx)vh)WDb8fko)8zd3oNigLKYyIyf3b6Yg)gyheLNzEtyJPld(px5e5n7ohyCWoj1K5nrXeAq2oh2OX)waiMwvuCFvZGaM)VhenpIEnUiYnoFz2DaUaqeRCYdGPg(DdwB08kpqEA9tHzDwCuAQpnMYz3KXanp5dRBYRW8Hg2aB5zl9HZSPtG98ff2eOIsaZKwL4bek4ezqrFZqwxHLCZQo7BNF825Ws)sYogUvyYsvbjYGUd)BwNrWh3ycGydogjTVSbNwAlrp6)I7jbK0NFewyjxXpOJNkXGaOMod13Rq()5)X7)haf)V5H7cMU5v(FbuuhcdZpbx(fERDUZhmnqWOMhcQKCVf)Tv4(i1KXkTclwD)CATO2EKG1ZjeNffDdhZqkM(z4DhoW4l7gLhMrV)(avYO51Gny4PixdAjDAXSQmI2sdyaM9(c5BKbR0AfUVnuWYuwAG9bGICJtyUta(wZCIJd8bGNejwXeUAC6R0eUzGNpoHGuzZ68S7kvPzXOjDftJITX1zXhbZcHDcqTqFeOdjeJmGI9B7UKwBKZJTt7TxcD7k5gb6GXmp0KvugwHZLxch734UepXjIKZKPHvFNcY3MCpPCc0(rzHG4KiVmGtxj6oDX)940hCxde0Gt13Q87QBoXmOS3yIx6suXM55Ob0Gwx4SPgbrWYyrovPp8WyETWO9A4czdq3JqzYIyyppdE(m3LP17zlxMGxO3gFpMxDJ29ybaM0ysJG4DtYdT(Q4ENXqfNaEcSzHtvwks4aZcVvIyy1a)LITyeQIjGTazPA(i(yBSpGLd2yGk00MGaMR3m0orj7GgyZAJwmNGXngNtJbkOTZzf7ahytBslMnRM)nWKV8TCsrsxKChL)UiWjTk0EHmPHtIRtONGTwJOq3B(g8zgy)gn2aNUSTCmozMHMlGDUKKdtw8ZJGvnthtSrpl(JxeHaBK2CPFkMBQid2IAKrJBfODrH2D2M1y84O9zdyTjkrlslWTc3IQtTFtYFKCPYG4allCtUk(3bJDbNdR48hA0Cm68h5byLikJdPqIA2ANmr4pc8XqIH)7apky0Oll8aGCszSYgoseIz49z2mf8qH7PGCY4yYb1Fi6NKjhaYqjhD4khR1vPUg9wIh)0Qg2XDOq4FcBcmA(mq6mOIMSQw)jgsdonPg86gCCss7iMhJOyyFL4VkJS6ONjH8g58AI0WuSXWZoCN9GLSm4WooFOiiOW)ti(S44DHhH79wTY313lSildvMr(zn(7HiwqtYqnEFy(yxH2br5ghJKztMiUmBBIyvnjm606xOECREzNDaBpAsJb5ekSbMJwo9uMTe(HRYRgPCZMP2vssp597mfSqH9LAZCXGoMd(s8mAtdYrEMixieKSiikAzqEkAOQdgDrUXW1biNnq2Ij2)Vjp)F3Ap3Bb6PF6vV)hOC9HPZdfb5JddMSfoPiVekfd54BHVu2qQ1aTxucSR8t8OnSjMZN(kHHctSul8ss9sOSdvRzX79AnwATWT0Sv5jpyYITd7A5aECcgTdsxr9KMSPJPOm8Hn5EGm8WeN78i7SapPdxYSEtx62VGd(fibHhWhHsOG)3nryqXrPzu8Heu)Pgd8rHcJgyJqIxH3EguyvWavyRvdUowNZNkRkXDw4ABTyCHqOcCUDCPbRFBR4P9se0fCKNbXkdpFat0JU3ucsn9K29qOBrDd8r(ykubXbz4SpHLFCWgebSwyAUXDTWlDATtZHdzfN07wn5P0Zloez)IYw7CUfofz0EbmeVevQGJQDemTvAlI48WKRXIxPnjewD5RjkhS9FbuqrEIC9PV7AKDiLmFEG(m2MaVyjGot1cOZ5keigYL7p7ClCGaNBWF(ZfisqsqQapvkLioIBEQgbcggzW8C4nEikF781u6HbWX)MqFWwhh0uh2wdNdqgtkJollksy2KWASA9TZ8j6(tK1mz0tGAjXj82DNiGvthtRiss54(qCeIC8BN)t8zegy4sS6wWehuawrRyt425)ya5uJywWYpHRPTgNyFEosEg5Slr3Q800(CVCFnJvmxeDDLuGxIPuY2mGi(ojdaGJAWNiNmmCrop4LysF(7fJbDPfheZReCAz(EMUokpyPT0tJ8I8I)APZgNBq6fwnrr8Zl8cW357g)xz2PxSPmySopQza6BteGqwcgKoBr0xqLsEjHrQyyldPeV49VY9JJ9w23(OnycRnyiXNIOGvaG97TA1PHAWMwBl9shkXb2xB(aA1IZgRbRClMEW1Inl8r(MzGPQBMfTAgC8o7g45zZi3FV(Q8up45RMbAliFGlxAu)HC5NnOr7NgnOyR3IL2GnZSxgCv5FMJ5kYfCyo4MGOfs4mt)OvRH9Dz(DWQCI0qNePzY4pQygxnzlWuK3kQNnLWKzyzyI5g3StFIkor3ytEDrrsTjZs9CsMTkX5MnumsRkz4N4dfy9XXUD(h4dwy5xHz(NSvPaUYPWUg8GqM6jCv2yfrUIf8gwKV8q9dO7(mlaYw7Ow(pMSq2Ipr2WR1IMe6ylyySIDeN)2gGbZCz4BuaiGocIsjA508quOVzrX)io2xqdM5OTabJvBKRxCgx0CekoEfIs9dfvlhd)tpdlNUaGNzjwTUoU0ppM9BBivWcdMEgiCTTDlOE39Ze7yWs)3TmcdwekovCacm0xs8fw49aqTz(ebhhdTtKV)in0)990P62(jDYyclwEQy4xlS6txfI4iArdAt6Wfd4SWlbmtoBgTdb0n47ivok8K3koPnmoJMKXgDA8dBa7t9ssNDV3cPGaR9CT40i9ZjEXrjzcqzcLhNo2fD1PmYOQRrJXNSXGNmKFIHtsdHkqjkJMd2qDV(RLF9QHxV0FC1Ft2S86dHPEi8RGQAWg5dAWF54Zg9MUOiJ4282Vm2tfncGa71RLQ1liir2hy3TH5DGftjlS(3p8UOBrSLB0sVVyY)a9ryYysBdMmShbttg13CPMW97YubinPQxzcp1EIvtNXkIZ1AbqGrf0K7c8DhwH3kkp(brGr5jUgKTxK56VF783vAHuui(N5uS1jLgOZ1375Ch43AbkAyt5c3cYDMxqQhvEMvI5gr1YcLGwi3AQ0y(E1S7PLiPxAoFomcC9sgQljE8yfF2NTXlqcMyfwuTzORQx0sINFsbxUJiYY22T2JBqpfF5BSIB4jFtVSLlZ6AhtzC9aXmifQPNg(6ziy87zy4lJ(J9m0sH)Hh9k5yFPABhMo2GirLFxjFR0BBSUXjFHerVIgwkfgDMVtgItEBQL921Md6vOGTolaBedkmneSIfwKFr3SrfZXwE7(9EQNGa0KtwgIsLcuxcq0N1NvusSwhA2gAuY0Ek)qHmydUGlF(Xep14MLhFrMXZlYtW)XBV3hlm53ETX6IrT3NuijfwyO3EuwnWrXsfoXQjVVbpAX4qunqUjESyMsTKxjc4EhFfbzn(QexqDayN6mqR2DMexyNgIgnYjwFoFmwfaRYbr46BNjQRBx1iXM6V0pkpDMFIN6rydTe5KIw3HVovdZot3yuGeo4vsWYP1p0)Q0q7rkWk(N4wAq)rJFExXP0QmyOzUj1MFnAtCGVlyuhgb)iERyfbgF4IDNBHjgCby5OWtFUJUXjrzEyuNDUbbd4VChLxae2a4fNqpuINjVWlSxrSzAKlNKBJ2gXMEYPCumfQ29b1EULifZe5dbbvqhvFq6NNypIzHGKoVGkvluFkgQAxNC1vbZccZanhxxprj5q0EESTllXNGQvuxWn5oORMEiJaCy4VjFdvYoawsMdWxuz5l9WQ5H1VbdFTkZLHJzg1ZqJzoP0IETM3Sj867RCOZAWTIAOx3MytSx8spG2b1Z(vlt9bm3LNv4qvvSnbRVU2eZiB6BJOqEhKte)FM9oBPY5dWOaPZAszCzVIHraQ0iFdgbAR1LfMFvhUQcjuXqqjT9ANZ4wn41OB27Vzkxf6hJwJ9hVpTWSiVykRsRegTKY4GtJDqJXIXOyHw2GDE)2YYHu8YCehmcoDjxoXM(gCbAjUwysg09n0Kl17HHjKilPCGMYo7Ztji8JL5sKiBybwNeZwAsgmawkxlZRActcmpa6FbSg1J3R04NzaoZmtq9kj)p)zHO8(AuCMuN3O64J1vIIuML5SvHDxDGhRQRQJLSV3Ccx1E3AuW3PQpAuIsLeavJnFnA2yVwi2BQbysMlZGp9iryB6p32XQ1opcq9D6vbarIrKq6jQXHokHdHGCIf8MBqs5KOOnxBmt(kufDvPMgEiOgmEktisBUw9v1(JpG(irOTsVlDzLD5AVe(q3ivqg4x8fKYYln8filVdZ0RiHdPD97JZ79E(jOlSF4TFuyZLaG(pE377z0lIgmVq3TSgmz4NV6Jmjt)8h(i9DoHOx(jr)7b7KCM0RU)qI76OWE9Rl6ns9zu1q4AOr)ebBVOGnK5xv(EMi5fNHg9tFAoQ2zsvxArRksvXwQ1sorxNCJFZkgAVMbRlM5LHy(ykzi2TpuvJCShxbevOFmedJA3GY1Ywyav10Y07oCat2MTpgh7SfS8QyPc0X4MaRW9)F9Wkzbzh7Js(Isq)t8tCZr(je0nOWf3YLiG7PpdrGzLJzFsIGfeo2GjcpI)npNaAuU4(dpeYOaaXtNhTRJc54lhHCbAe5bz(NYdOw9UiqjczSsmveqaCYtaGbQ8D5laJvN7lZ2uBSc)mvxEvvHAXQ1E1K)iIyPw)hBRD6fIWLmthp9lnN6g8Z3uivRdOjqy8UWSmrDUrarXxyEgRqfFx26CrbWPwvCKvQ5HebGOy6qAkkg))eFpc0oWMe)UC5hGFStuJwvn9QXrTWk(MJdYO(JPKAyZzYNCRVOg70sUms7bFxXrj86hHqK6Xy1pTKdmggcOE3ftZq4nkfFttDVstE2m6a9ff7xpi9a2OuTGlZXPiYGWFo354hW2zO5)YyIw1WxSokRZtQFV6uBNEzk7itKS1twIIs(luOsRRpGWvOUCZuYN0QSFC02MsNYomPej1b0zzMQ53l9XqdfXe52CtwWufO(vuJGUdLtUoijS9s)LI4XtjXjSz79CDvY8a8rHsqkfVu2lKQYKVUsj18u87RMWsPw1d2v61kVahzZlWARE4cliPSZdgQtzzI)1LC4qmbdjHWIbup0xBr)nXKDrKW4xWE7xGTt4)kN95FjL((C5KNfTHfUy48oen1D7N(p9r9C4hGY3ffclf9ZVOITZVGztw1FqGtGb0D4x6vmJNBEgn4gO2uxJJILRX2pzyJR0ZW72(3c0wvgHgWAxiIo(y8Z4kyeBGsz3nKWWNrqSwYSY6zqBMRwOdTCglkgbt0TYfPqljBpG4alRGQ1(AZU5eX3ssmL83QpXMYTR(8(6AWXcrRMWZ6ID1N3lSjIqk9Gveoyi1HnmVruLp5tnclQI6f6zXSt1qME5eUtqD6EuDl9JpwNL6tNih4WED6Apeo)v(6DAndrmMEVK)xUCcMqYd20oDcM5rbg)BrS0RAX2z3rs7YSYXrLYmhuJinHDdMKQPBtHor8qlsJF2MypzNr1MyptoQwzITilwpvnvebzotovM(ZEwTOO(f5jlRB4ZR9q8fPoj17NzCFfNs94WQtdAjmTvMElQvQeYnD6qBHKRTlWtNZ8nptCMJ(kyz3xHL45I302e)eoqT5FYl2jdYTiq9GGtncHUl3r)MSWkFamM1ctM0NBaTP1WhIGwoNBkYAQbQh12q(pTz8GQNWMeYNTtTNaNeBETiz8jGNTz42ZWuEGo7mYXk6j7DJTLG0FpmnpoMNhmrpPuMSJ)B4VwT)R(F(BfxMiGctccFoTSK2XRIccIUNIjOtEcMnI7PuUZA8cFr28faoginm6GzIXrrBCvuEOYOxUK(Ci5K5GFDKElGFPprWv3YwW88pHH7gI)WRPP259aWrxheZtENjaw776AlNv5p5R6I3n81GvM34JBeKYVrLuar(yPUhTYpOOgTt7x8Tj94jVY0xJ0TFY0izQtrpIpXF1KJyn0wXZWyhB81erL8em(Utu(2IEcNoAYGtIINqFonBZCO8TeTyogUBZblJp7jeO(TcDpNKQrnV1tK63j0TF6V8xeN7QJtizJTGg5VTFsZsIeEwxTXOMoz04oPw)czE5Kl6Gv5rNUhz67R5JpA)vNoSNnKNCQ0isqo7HsoV4Shp(yvG(YrJRDLV4XhpcHAyqga6A2UtgICHCGgXFSpA2Yps9OxjJF4znSGNqD(MbC9LdhBFMK)2iRorDRVOhkIF1lpRJjPTp(OTUCkpUJrPO9E8rdsb7yqgwNABvVlNCoq3yUPX1oeuPjMo04P(KXvFCr43EDNJmNh2EDoQshFiDkONdlohwK3jSQadehbuOQjrE6i5zq7ZiTqSeOKUKwQpmH1TyLP8bKbSD(3(FGx13zAm1k5SLHc7kvtaDQwpatNm8IoDTxgaalTEQL71Rt3U6P(F6ajcHQFAx7CedUTKFDyv4K5vD)uqi5PvFq9OJSV9(WRQFePOmWWbKf(hJhksNLS4IBU(iUCs1d6QSJD6wLz)u7tApqoApzEl8PvTpHrJOkkLZgxDU1yWF8XAPs6yLgPQSIlpJipom9JDd7zdgIW2((R4iGHNu2w2GXjfFEvNilWNEv9CnOlB)77AMC5Lvpl71Ruhv3Hhl5kkLfZxEwVk7lZckrvJacMmirPKtV8SbOoRkYugoguazgozhXYY0RWh)Tu75wbdv6jpjCTUE3UJUGZ9M8ge4Uli)ELPut1cd72KiMto9YJpAy9i2FdAjpWnzCfuUm(LkMjtsrT3oYfgBj)qAJuxdexLLVGf1OqCzUlrmJrZHnvNra21Ax3wWYwbaWUa4eW4Hjn2rWia14GU0om0XO(wtpvJSPtnTi8LdjC(xJgp1itl)SdLJ90to9blP07uo2BFwP3PPLLw6sPWpTMD5pZMT1ctlSkM4z91Q1(PdFDh74lePZqs135SvGbDQetGIKbs6d)Yjd7uhXMbsvB(HA0p2PL(XcoGQJtGv)1m(2NsVUA(CHBAJrNwQRDyvDtwSF6yTKm71Xu8IT53kTB)A2GQ7N(UcLAQfarjx83E9FADILnrd0UguTG()yzHUp(yL2p8sfPYhlK(1rVXd7ypVkDQmPQI67O5dYKVdykTycGrlg6vlR(uL16OAkF4DWoTdvRFUFKXgoL6kophUBNnvW9hknA)j1(M7MYS9tX1U3)MT0Lr9oAujQEDRVHoNoQJmVbneUjZ0dm08MWRCuL3PuUVw1)05i7LV)N(lyUa(7petxdki(aLvJ9qOFQOqqzH4BLpg0hkubF(F8HcXR43pButWvylLX9kj7ES(8bP0RWVIE4iMLehVzYL4FovMaI1Zyl8yrIOVAMjQfJtZkgi7SOvL5xszLlmIxfECDcNbNo3CJxYmykXGpsWifIiokmzTtCA0Yhk09kD3Kx8m8McG5I4xN2jTztTmh1IjIMK94ZlLr8)dAK0MXhTWk4lNC24cxM1lRnoByLeAiZEkPLZO)GivvtMKE2llceHrJA7z0fAI9vsK)3QT75oBoSTqeFKrdBR310r9hBnW5p)TTPnReSgD86dcETgX)Nt7yAiwXnLIMgYqZWr7AcA6yi9m6bEDYq5atOerYcAf7jd4XhTfE36sKt3NqwGK1RyOxi3pZp1XCDm1XKLSl)Bs7oURoATtUOynEcLP1wvuDdoQ0kJBygrQLy3YK3wjJmIQtHNfQIsCzepFm1Mf8VF4O2UoA1XIssVguUShIPJ71FfPdy(BBOb4r63dY98FB3hgtcyxPGCPcShFXl7wRGHAYmsVPt0L1jlrufJ2w4VMYlPIK1tTUT6D55Dmu5pdnuofyrQmOYGDJYdZMUlROImnvBfSIcRSS8RxGwIRQMR)D4y3wTJSBhQYe4761zz520DjU5yxvMLEPkLNaUnNv(QXBZOyJjTR0rDZxqOhpCmwFfkVeyp8Ob8vr7QaTNXm1n5Sb67RIBvZImGyAFyyQUqFMkV0m31PswUkFUkUum355AS(CPEPxUpZNqn)oDtxQdgQLmO1BfsJwF81klVNDCBYZ7(F5pwLPs(mOoMRwYeDbGu0yrgE(GE9yXlHoeVe8tEnOfCYlwNLfN(2x9Q7V)((3hD)ApNLGO1nVImcyYWbdE9ageEQacFXuTD9LVYzArLb16z(nNp6838kXM8ftf4m2SH4T2ovN9MHdh8MxHyNtllj7PAOD28wEd(1hfhsMAUe4(DzxmtRijISiZqHYSTWqRruArTIrcWU6iM59fy5dbEu80wu9m7nXHO0WQErEStqqHmv7cn0zrgPtaE5KZhqCn71fR4Z2DJPoNigIoP0hj13tD6wjy7fIr0s5X5YXNLT)uDwG9mPWSkUWfRw9pDoYEi9lNuTcLTJXCdXDmBYalbnQ9zc98E7)r5H4oYu)utbCPacvbZUlhFMoS2Ttg6IkT5JbuH1usDI6(r94unpq7dW)KP00bqZEHk6xk5GgN(v5o0Sccu7(9erHL3hOxo57gZTkMN2EtvblyuCAogh5FheZLeuihcWoyXjhtzY2VOITycuuZygi9aN(3h9z5p8KCwJcqM58ERIegj8nxapZwYbNks0lMYV5ZfIGs5x)JRe4U39BcP3OJi4rbFf5jsINeek6qSOVIKcSBwd4ig1EHi4uLqpsPRmQik0PmJwbPjfX72VixeSa4YHjxwQ5nIDL6TP01(EblpCitoAYn5baTfeG4pGGlWJabd0o7rAgRno4SPskBH9rebV2bQMlrdquRcWi3YDjEt0YHUMcZOHUMzuSRLkcq8r6BVblBscRKYDdlHX0SvXKnBoHynBrmNoiBDeDgXOb8Axr(wgLF1kYk9KQqNWehLy8nDOGxKExhHmAghjYHjeaFlGzx44EBQCUDrEkXac9YrVmpbHagxgl1bi3NFByLc8x5DWyK2BwLNKa1I7gomAnr3MoBteiykebQKSoIq(G81EPN2D4Gtzh4SbL4S0hDwVpfGimcEdh0X4aYJpHKm4UCYydB0s2tDACBdglDGk8dUOpsiFbgSi0iRz(B24bGqMN6tb(gG4aZHMjMIsLawZVg3bYnr35lsYMdPg904k9CeR(Pz09mcmktaUrIu)kDD5AInqjXA(g7bXrd6yS9cRc)6L2D73giKYlBP9xyvvzOhqqCpGkRRolXo7WIZfa95ZgUDoH5RfyWUlWegANoe3pyKYJ6temTqSvoB6YOu4Xlk5h7m72EFJS9cLwgQPiuSQKTB)DqJctFKJl1T(aM4E6dfa6i3hiZ)jLuidl16EuDCGvXds0w0rrybiqUdsvnIi3Es3A25XAQpKL7YvTjbxVNe5ahWOmNVfGpvzGfOVi8D)LO7Ces1(nUf0SvblbJhqBv55A6BGnYAaKNfcqCbvIWOFw9MnbeDQ5nGmDSWrXJ1dhC17LF)qWlRWifLQwh1ETcj8ocPMPhhYEn3lr10nm50yAZSN45SzHp6p)SGOOnO1p4fi9nWZZMrCVNiD5rZ4GXi2imPFGXOzpAqlwBql6)mhLB4cIfdUjiArBGydxw)u4lT071vt7hz0Ft3))tNm2CwEK1c(N)v2FlWxECGu7o0VmKVgYvJjuMrCrVonDz(xIT(kFF73cuJTBY(Nk9KT5Dk2u)nHhTEN(lHi)t7AYVvi1Qxe9pDeA15SLitdxb)1Uhuf2X(Kfu9lqsfPGmxPSEn5F5KZBbQt9IwVqlOL77(jd7yjTjhP)ASRTDBPs3y2(gc4rmMjgYdyrAXRM3qtd)1dSu3OM7qiZzwVNTnvTO106sSvRlPaan0qomaxPTETZJiGE21L0irHTlcEvdaSE1Ydp396Fz04lOpn9x))9]] )