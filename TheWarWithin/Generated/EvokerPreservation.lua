-- EvokerPreservation.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 1468 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Essence )

spec:RegisterTalents( {
    -- Evoker Talents
    aerial_mastery        = { 93352, 365933, 1 }, -- Hover gains $s1 additional charge.
    ancient_flame         = { 93271, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by $375583s1%.
    attuned_to_the_dream  = { 93292, 376930, 2 }, -- Your healing done and healing received are increased by $s1%.
    blast_furnace         = { 93309, 375510, 1 }, -- Fire Breath's damage over time lasts $s1 sec longer.
    bountiful_bloom       = { 93291, 370886, 1 }, -- Emerald Blossom heals $s1 additional allies.
    cauterizing_flame     = { 93294, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for $s2 upon removing any effect.
    clobbering_sweep      = { 93296, 375443, 1 }, -- Tail Swipe's cooldown is reduced by ${$s1/-1000} sec.
    draconic_legacy       = { 93300, 376166, 1 }, -- Your Stamina is increased by $s1%.
    enkindled             = { 93295, 375554, 2 }, -- Living Flame deals $s1% more damage and healing.
    expunge               = { 93306, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    extended_flight       = { 93349, 375517, 2 }, -- Hover lasts ${$s1/1000} sec longer.
    exuberance            = { 93299, 375542, 1 }, -- While above 75% health, your movement speed is increased by $s1%.
    fire_within           = { 93345, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by ${$s1/-1000} sec.
    foci_of_life          = { 93345, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over $<newDur> sec.
    forger_of_mountains   = { 93270, 375528, 1 }, -- Landslide's cooldown is reduced by ${$s1/-1000} sec, and it can withstand $s2% more damage before breaking.
    heavy_wingbeats       = { 93296, 368838, 1 }, -- Wing Buffet's cooldown is reduced by ${$s1/-1000} sec.
    inherent_resistance   = { 93355, 375544, 2 }, -- Magic damage taken reduced by $s1%.
    innate_magic          = { 93302, 375520, 2 }, -- Essence regenerates $s1% faster.
    instinctive_arcana    = { 93310, 376164, 2 }, -- Your Magic damage done is increased by $s1%.
    landslide             = { 93305, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for $355689d. Damage may cancel the effect.
    leaping_flames        = { 93343, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth           = { 93347, 375561, 2 }, -- Green spells restore $s1% more health.
    natural_convergence   = { 93312, 369913, 1 }, -- Disintegrate channels $s1% faster$?c3[ and Eruption's cast time is reduced by $s3%][].
    obsidian_bulwark      = { 93289, 375406, 1 }, -- Obsidian Scales has an additional charge.
    obsidian_scales       = { 93304, 363916, 1 }, -- Reinforce your scales, reducing damage taken by $s1%. Lasts $d.
    oppressing_roar       = { 93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by $s2% in the next $d.$?s374346[; Removes $s1 Enrage effect from each enemy.][]
    overawe               = { 93297, 374346, 1 }, -- Oppressing Roar removes $372048s1 Enrage effect from each enemy, and its cooldown is reduced by ${$s3/-1000} sec.
    panacea               = { 93348, 387761, 1 }, -- Emerald Blossom and Verdant Embrace instantly heal you for $387763s1 when cast.
    permeating_chill      = { 93303, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by $s1% for $370898d.
    potent_mana           = { 93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by $s1%.
    protracted_talons     = { 93307, 369909, 1 }, -- Azure Strike damages $s1 additional $Lenemy:enemies;.
    quell                 = { 93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for $d.
    recall                = { 93301, 371806, 1 }, -- You may reactivate $?s359816[Dream Flight and ][]$?s403631[Breath of Eons][Deep Breath] within $s1 sec after landing to travel back in time to your takeoff location.
    regenerative_magic    = { 93353, 387787, 1 }, -- Your Leech is increased by $s1%.
    renewing_blaze        = { 93354, 374348, 1 }, -- The flames of life surround you for $d. While this effect is active, $s1% of damage you take is healed back over $374349d.
    rescue                = { 93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    scarlet_adaptation    = { 93340, 372469, 1 }, -- Store $s1% of your effective healing, up to $<cap>. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk            = { 93293, 360806, 1 }, -- Disorient an enemy for $d, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic       = { 93344, 369459, 1 }, -- Redirect your excess magic to a friendly healer for $d. When you cast an empowered spell, you restore ${$372571s1/100}.2% of their maximum mana per empower level. Limit 1.
    spatial_paradox       = { 93351, 406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by $s4% for $d.; Affects the nearest healer within $407497A1 yds, if you do not have a healer targeted.
    tailwind              = { 93290, 375556, 1 }, -- Hover increases your movement speed by ${$378105s1+$358267s2}% for the first $378105d.
    terror_of_the_skies   = { 93342, 371032, 1 }, -- $?s403631[Breath of Eons][Deep Breath] stuns enemies for $372245d.
    time_spiral           = { 93351, 374968, 1 }, -- Bend time, allowing you and your allies within $A1 yds to cast their major movement ability once in the next $375234d, even if it is on cooldown.
    tip_the_scales        = { 93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian         = { 93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to $s1% of your maximum health for $370889d.
    unravel               = { 93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing $s1 Spellfrost damage to absorb shields.
    verdant_embrace       = { 93341, 360995, 1 }, -- Fly to an ally and heal them for $361195s1, or heal yourself for the same amount.
    walloping_blow        = { 93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec. 
    zephyr                = { 93346, 374227, 1 }, -- Conjure an updraft to lift you and your $s3 nearest allies within $A1 yds into the air, reducing damage taken from area-of-effect attacks by $s1% and increasing movement speed by $s2% for $d.

    -- Preservation Talents
    afterimage            = { 94929, 431875, 1 }, -- Empower spells send up to $s1 Chrono Flames to your targets.
    burning_adrenaline    = { 94946, 444020, 1 }, -- Engulf quickens your pulse, reducing the cast time of your next spell by $444019s1%. Stacks up to $444019u charges.
    call_of_ysera         = { 93250, 373834, 1 }, -- Verdant Embrace increases the healing of your next Dream Breath by $373835s1%, or your next Living Flame by $373835s2%.
    chrono_flame          = { 94954, 431442, 1 }, -- Living Flame is enhanced with Bronze magic, repeating $?c2[$s1%][$s3%] of the damage or healing you dealt to the target in the last $s2 sec as Arcane, up to $<cap>.
    conduit_of_flame      = { 94949, 444843, 1 }, -- Critical strike chance against targets $?c1[above][below] $s2% health increased by $s1%.
    consume_flame         = { 94922, 444088, 1 }, -- Engulf consumes $s1 sec of $?c1[Fire Breath][Dream Breath] from the target, detonating it and $?c1[damaging][healing] all nearby targets equal to $s3% of the amount consumed, reduced beyond $s2 targets.
    cycle_of_life         = { 93266, 371832, 1 }, -- Every $s2 Emerald Blossoms leaves behind a tiny sprout which gathers $s1% of your healing over $371871d. The sprout then heals allies within $371879a1 yds, divided evenly among targets.; 
    delay_harm            = { 93335, 376207, 1 }, -- Time Dilation delays ${$<base>+$s1}% of damage taken.
    doubletime            = { 94932, 431874, 1 }, -- $?c2[When Dream Breath or Fire Breath critically strike, their duration is extended by $s1 sec, up to a maximum of ${$s1*6} sec.][Ebon Might and Prescience gain a chance equal to your critical strike chance to grant $s2% additional stats.]
    draconic_instincts    = { 94931, 445958, 1 }, -- Your wounds have a small chance to cauterize, healing you for $s1% of damage taken. Occurs more often from attacks that deal high damage.
    dream_breath          = { 93240, 355936, 1 }, -- Inhale, gathering the power of the Dream. Release to exhale, healing $s1 injured allies in a 30 yd cone in front of you for ${$355941s3+$355941o1*8*$<ysera>}.; I:   Heals $355941s3 instantly and ${$355941o1*8*$<ysera>} over $<sOneDur> sec.; II:  Heals ${$355941s3+$355941o1*2*$<ysera>} instantly and ${$355941o1*6*$<ysera>} over $<sTwoDur> sec.; III: Heals ${$355941s3+$355941o1*4*$<ysera>} instantly and ${$355941o1*4*$<ysera>} over $<sThreeDur> sec.
    dream_flight          = { 93267, 359816, 1 }, -- Take in a deep breath and fly to the targeted location, healing all allies in your path for $363502s2 immediately, and $363502o1 over $363502d.; Healing increased by $s8% when not in a raid.; Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    dreamwalker           = { 93244, 377082, 1 }, -- You are able to move while communing with the Dream.
    echo                  = { 93339, 364343, 1 }, -- Wrap an ally with temporal energy, healing them for $s1 and causing your next non-Echo healing spell to cast an additional time on that ally at $s2% of normal healing.
    emerald_communion     = { 93245, 370960, 1 }, -- Commune with the Emerald Dream, restoring $s6% health and $s1% mana every $t1 sec for $d. Overhealing is transferred to an injured ally within $370984r yds.; Castable while stunned, disoriented, incapacitated, or silenced.
    empath                = { 93242, 376138, 1 }, -- Spiritbloom increases your Essence regeneration rate by $370840s1% for $370840d.
    energy_loop           = { 93261, 372233, 1 }, -- Disintegrate deals $s2% more damage and generates ${$372234s1*4} mana over its duration.
    engulf                = { 94950, 443328, 1 }, -- Engulf your target in dragonflame, damaging them for $443329s1 Fire or healing them for $443330s1. For each of your periodic effects on the target, effectiveness is increased by $s1%.
    enkindle              = { 94956, 444016, 1 }, -- Essence abilities are enhanced with Flame, dealing $s1% of healing or damage done as Fire over 8 sec.
    erasure               = { 93264, 376210, 1 }, -- Rewind has 2 charges, but its healing is reduced by $s2%.
    essence_attunement    = { 93238, 375722, 1 }, -- Essence Burst stacks ${$s1+1} times.
    essence_burst         = { 93239, 369297, 1 }, -- Living Flame has a $s1% chance, and Reversion has a $s2% chance to make your next Essence ability free.$?s375722[ Stacks $359618u times.][]
    exhilarating_burst    = { 93246, 377100, 2 }, -- Each time you gain Essence Burst, your critical heals are ${$s1+200}% effective instead of the usual 200% for $377102d.
    expanded_lungs        = { 94923, 444845, 1 }, -- Fire Breath's damage over time is increased by $s1%. Dream Breath's heal over time is increased by $s1%.
    fan_the_flames        = { 94923, 444318, 1 }, -- Casting Engulf reignites all active Enkindles, increasing their remaining damage or healing over time by $s1%.
    field_of_dreams       = { 93248, 370062, 1 }, -- Gain a $s1% chance for one of your Fluttering Seedlings to grow into a new Emerald Blossom.
    flow_state            = { 93256, 385696, 2 }, -- Empower spells cause time to flow $s1% faster for you, increasing movement speed, cooldown recharge rate, and cast speed. Lasts $390148d.
    fluttering_seedlings  = { 93247, 359793, 2 }, -- Emerald Blossom sends out flying seedlings when it bursts, healing $s1 $Lally:allies; up to $s2 yds away for $361361s1.
    font_of_magic         = { 93252, 375783, 1 }, -- Your empower spells' maximum level is increased by 1.
    golden_hour           = { 93255, 378196, 1 }, -- Reversion instantly heals the target for $s1% of damage taken in the last $s2 sec.
    golden_opportunity    = { 94942, 432004, 1 }, -- $?c2[Casting Echo has a $s1% chance to cause your next Echo to be $s2% more effective.][Prescience has a $s1% chance to cause your next Prescience to last $s2% longer.]
    grace_period          = { 93265, 376239, 1 }, -- Your healing is increased by $s1% on targets with your Reversion.
    instability_matrix    = { 94930, 431484, 1 }, -- Each time you cast an empower spell, unstable time magic reduces its cooldown by up to $s1 sec.
    just_in_time          = { 93335, 376204, 1 }, -- Time Dilation's cooldown is reduced by $s1 sec each time you cast an Essence ability.
    lifebind              = { 93253, 373270, 1 }, -- Verdant Embrace temporarily bonds your life with an ally, causing your healing on either partner to heal the other for $s1% of the amount. Lasts $373267d.
    lifecinders           = { 94931, 444322, 1 }, -- Renewing Blaze also applies to your target or $s1 nearby injured $Lally:allies; at $s2% value.
    lifeforce_mender      = { 93236, 376179, 2 }, -- Living Flame and Fire Breath deal additional damage and healing equal to $s1% of your maximum health.
    lifegivers_flame      = { 93237, 371426, 1 }, -- Fire Breath heals $s3 nearby injured allies for $s1% of damage done to up to $s2 targets, split evenly among them.
    lifespark             = { 99804, 443177, 1 }, -- Reversion healing has a chance to cause your next Living Flame to cast instantly and deal $s2% increased healing or damage. Stacks up to $394552u charges.
    master_of_destiny     = { 94930, 431840, 1 }, -- Casting Essence spells extends all your active Threads of Fate by $s1 sec.
    motes_of_acceleration = { 94935, 432008, 1 }, -- Warp leaves a trail of Motes of Acceleration. Allies who come in contact with a mote gain 20% increased movement speed for 30 sec.
    nozdormus_teachings   = { 93258, 376237, 1 }, -- Temporal Anomaly reduces the cooldowns of your empower spells by $s1 sec.
    ouroboros             = { 93251, 381921, 1 }, -- Casting Echo grants one stack of Ouroboros, increasing the healing of your next Emerald Blossom by $387350s1%, stacking up to $387350u times.
    power_nexus           = { 93249, 369908, 1 }, -- Increases your maximum Essence to $<max>.
    primacy               = { 94951, 431657, 1 }, -- For each $?c2[healing over time effect from Spiritbloom][damage over time effect from Upheaval], gain $s1% haste, up to $s2%.
    punctuality           = { 93260, 371270, 1 }, -- Reversion has ${$s1+1} charges.
    red_hot               = { 94945, 444081, 1 }, -- Engulf gains $s2 additional charge and deals $s1% increased damage and healing.
    renewing_breath       = { 93268, 371257, 2 }, -- Dream Breath healing is increased by $s1%.
    resonating_sphere     = { 93258, 376236, 1 }, -- Temporal Anomaly applies Echo at $s1% effectiveness to the first $s2 allies it passes through.
    reverberations        = { 94925, 431615, 1 }, -- $?c2[Spiritbloom heals for an additional $s1% over 8 sec.][Upheaval deals $s2% additional damage over 8 sec.]
    reversion             = { 93338, 366155, 1 }, -- Reverse an ally's injuries, $?s378196[instantly healing them for $378196s1% of damage taken in the last $378196s2 sec and an additional][healing them for] $o1 over $d.; When Reversion critically heals, its duration is extended by 2 sec, up to a maximum of ${2*$<cap>} sec.
    rewind                = { 93337, 363534, 1 }, -- Rewind $?s376210[${$s3/2}%][$s3%] of damage taken in the last $s2 seconds by all allies within $a1 yds. Always heals for at least $<min>.; Healing increased by $s4% when not in a raid.
    rush_of_vitality      = { 93244, 377086, 1 }, -- Emerald Communion increases your maximum health by $377088s1% for $377088d.
    shape_of_flame        = { 94937, 445074, 1 }, -- Tail Swipe and Wing Buffet scorch enemies and blind them with ash, causing their next attack within $445134d to miss.
    spark_of_insight      = { 93269, 377099, 1 }, -- Consuming a full Temporal Compression grants you Essence Burst.
    spiritbloom           = { 93243, 367226, 1 }, -- Divert spiritual energy, healing an ally for $367230s1. Splits to injured allies within $<range> yds when empowered.; I:   Heals one ally.; II:  Heals a second ally.; III: Heals a third ally.
    spiritual_clarity     = { 93242, 376150, 1 }, -- Spiritbloom's cooldown is reduced by ${$s1/-1000} sec.
    stasis                = { 93262, 370537, 1 }, -- Causes your next ${$s1*3} helpful spells to be duplicated and stored in a time lock. You may reactivate Stasis any time within $s2 sec to quickly unleash their magic.
    temporal_anomaly      = { 93257, 373861, 1 }, -- Send forward a vortex of temporal energy, absorbing $<shield> damage on you and any allies in its path. Absorption is reduced beyond $s2 targets.
    temporal_artificer    = { 93264, 381922, 1 }, -- Rewind's cooldown is reduced by ${$s1/-1000} sec.
    temporal_burst        = { 94955, 431695, 1 }, -- Tip the Scales overloads you with temporal energy, increasing your haste, movement speed, and cooldown recovery rate by ${$431698u*$431698s1}%, decreasing over $431698d.
    temporal_compression  = { 93241, 362874, 1 }, -- Each cast of a Bronze spell causes your next empower spell to reach maximum level in $s1% less time, stacking up to $362877u times.
    temporality           = { 94935, 431873, 1 }, -- Warp reduces damage taken by ${$s1/-1}%, starting high and reducing over $431872d.
    threads_of_fate       = { 94947, 431715, 1 }, -- Casting an empower spell during Temporal Burst causes a nearby ally to gain a Thread of Fate for $431716d, granting them a chance to echo their damage or healing spells, dealing $431716s1% of the amount again.
    time_convergence      = { 94932, 431984, 1 }, -- Non-defensive abilities with a $s1 second or longer cooldown grant $431991s1% Intellect for $431991d.; Essence spells extend the duration by $s2 sec.
    time_dilation         = { 93336, 357170, 1 }, -- Stretch time around an ally for the next $d, causing $s1% of damage they would take to instead be dealt over $d.$?s363899[; Healing a target under the effects of Time Dilation clears a portion of the delayed damage.][]
    time_lord             = { 93254, 372527, 2 }, -- Echo replicates $s1% more healing.
    time_of_need          = { 93259, 368412, 1 }, -- When you or an ally fall below $s1% health, a version of yourself enters your timeline and heals them for $361195s1. Your alternate self continues healing for $368415d before returning to their timeline.; May only occur once every $s2 sec.
    timeless_magic        = { 93263, 376240, 2 }, -- Reversion, Time Dilation, Echo, and Temporal Anomaly last $s1% longer and cost $s2% less mana.
    titanic_precision     = { 94920, 445625, 1 }, -- Living Flame and Azure Strike have $s1 extra chance to trigger Essence Burst when they critically strike.
    titans_gift           = { 99803, 443264, 1 }, -- Essence Burst increases the effectiveness of your next Essence ability by $s1%.
    trailblazer           = { 94937, 444849, 1 }, -- $?c1[Hover and Deep Breath][Hover, Deep Breath, and Dream Flight] travel $s1% faster, and Hover travels $s1% further.
    traveling_flame       = { 99857, 444140, 1 }, -- Engulf increases the duration of $?c1[Fire Breath][Fire Breath or Dream Breath] by $s1 sec and causes it to spread to a target within $?c1[$s2][$s3] yds.
    warp                  = { 94948, 429483, 1 }, -- Hover now causes you to briefly warp out of existence and appear at your destination. Hover's cooldown is also reduced by ${$s1/-1000} sec.; Hover continues to allow Evoker spells to be cast while moving.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    chrono_loop          = 5455, -- (383005) Trap the enemy in a time loop for $d. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below $s1%.
    divide_and_conquer   = 5595, -- (384689) $?s403631[Breath of Eons][Deep Breath] forms curtains of fire, preventing line of sight to enemies outside its walls and burning enemies who walk through them for $403516o1 Fire damage. Lasts $403727d.
    dream_catcher        = 5598, -- (410962) Sleep Walk no longer has a cooldown, but its cast time is increased by ${$s2/1000}.1 sec.
    dream_projection     = 5454, -- (377509) Summon a flying projection of yourself that heals allies you pass through for $377913s1. Detonating your projection dispels all nearby allies of Magical effects, and heals for $378001o1 over $378001d.
    dreamwalkers_embrace = 5616, -- (415651) Verdant Embrace tethers you to an ally, increasing movement speed by $415516s2% and slowing and siphoning $415649s2 life from enemies who come in contact with the tether.; The tether lasts up to $415516d or until you move more than $s1 yards away from your ally.
    nullifying_shroud    = 5468, -- (378464) Wreathe yourself in arcane energy, preventing the next $s1 full loss of control effects against you. Lasts $d.
    obsidian_mettle      = 5459, -- (378444) While Obsidian Scales is active you gain immunity to interrupt, silence, and pushback effects.
    scouring_flame       = 5461, -- (378438) Fire Breath burns away 1 beneficial Magic effect per empower level from all targets.
    swoop_up             = 5465, -- (370388) Grab an enemy and fly with them to the target location.
    time_stop            = 5463, -- (378441) Freeze an ally's timestream for $d. While frozen in time they are invulnerable, cannot act, and auras do not progress.; You may reactivate Time Stop to end this effect early.
    unburdened_flight    = 5470, -- (378437) Hover makes you immune to movement speed reduction effects.
} )

-- Auras
spec:RegisterAuras( {
    -- The cast time of your next Living Flame is reduced by $w1%.
    ancient_flame = {
        id = 375583,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- lifespark[394552] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Cooldown of Heroic Leap reduced by $s1%.
    blessing_of_the_bronze = {
        id = 381758,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Next spell cast time reduced by $s1%.
    burning_adrenaline = {
        id = 444019,
        duration = 15.0,
        max_stack = 1,
    },
    -- Healing of next Dream Breath increased by $s1%, or next Living Flame by $s2%.
    call_of_ysera = {
        id = 373835,
        duration = 20.0,
        max_stack = 1,
    },
    -- Trapped in a time loop.
    chrono_loop = {
        id = 383005,
        duration = 5.0,
        max_stack = 1,
    },
    -- Suffering $w1 Volcanic damage every $t1 sec.
    deep_breath = {
        id = 353759,
        duration = 1.0,
        tick_time = 0.5,
        max_stack = 1,

        -- Affected by:
        -- preservation_evoker[356810] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- Suffering $w1 Spellfrost damage every $t1 sec.
    disintegrate = {
        id = 356995,
        duration = 3.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- preservation_evoker[356810] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- preservation_evoker[356810] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- natural_convergence[369913] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- natural_convergence[369913] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- energy_loop[372233] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- burning_adrenaline[444019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- burning_adrenaline[444019] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- essence_burst[359618] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- Burning for $s1 every $t1 sec.
    divide_and_conquer = {
        id = 403516,
        duration = 6.0,
        tick_time = 3.0,
        max_stack = 1,
    },
    -- Healing $w1 every $t1 sec.
    dream_breath = {
        id = 355941,
        duration = 2.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- preservation_evoker[356810] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406732] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- expanded_lungs[444845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- renewing_breath[371257] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- renewing_breath[371257] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- call_of_ysera[373835] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- temporal_compression[362877] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Healing for $w1 every $t1 sec.
    dream_flight = {
        id = 363502,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- preservation_evoker[356810] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Tethered with an ally, causing enemies who touch the tether to be damaged and slowed.
    dreamwalkers_embrace = {
        id = 415516,
        duration = 10.0,
        tick_time = 0.5,
        max_stack = 1,
    },
    -- When $@auracaster casts a non-Echo healing spell, $w2% of the healing will be replicated.
    echo = {
        id = 364343,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- preservation_evoker[356810] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- attuned_to_the_dream[376930] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- time_lord[372527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- timeless_magic[376240] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- timeless_magic[376240] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
    },
    -- Healing and restoring mana.
    emerald_communion = {
        id = 370960,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- dreamwalker[377082] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- burning_adrenaline[444019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- burning_adrenaline[444019] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
    },
    -- Essence regeneration rate increased by $w1%.
    empath = {
        id = 370840,
        duration = 8.0,
        max_stack = 1,
    },
    -- Your next Disintegrate or Pyre costs no Essence.
    essence_burst = {
        id = 359618,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- essence_attunement[375722] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
    },
    -- Cannot benefit from Heroism or other similar effects.
    exhaustion = {
        id = 57723,
        duration = 600.0,
        max_stack = 1,
    },
    -- Critical healing increased by $w1%.
    exhilarating_burst = {
        id = 377102,
        duration = 10.0,
        max_stack = 1,
    },
    -- Time is moving $w1% faster.
    flow_state = {
        id = 390148,
        duration = 10.0,
        max_stack = 1,
    },
    -- Haste increased by $w1%.
    fury_of_the_aspects = {
        id = 390386,
        duration = 40.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w2%.$?e0[ Area damage taken reduced by $s1%.][]; Evoker spells may be cast while moving. Does not affect empowered spells.$?e9[; Immune to movement speed reduction effects.][]
    hover = {
        id = 358267,
        duration = 6.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- aerial_mastery[365933] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- extended_flight[375517] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- time_spiral[375234] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Rooted.
    landslide = {
        id = 355689,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- Sharing healing with an ally.
    lifebind = {
        id = 373267,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- preservation_evoker[356810] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Next Living Flame's cast time reduced by $s1% and deals $s2% increased damage or healing.
    lifespark = {
        id = 394552,
        duration = 15.0,
        max_stack = 1,
    },
    -- Healing for $w2 every $t2 sec.
    living_flame = {
        id = 361509,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- preservation_evoker[356810] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enkindled[375554] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enkindled[375554] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lifeforce_mender[376179] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ancient_flame[375583] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancient_flame[375583] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- lifespark[394552] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'pvp_multiplier': 0.5, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- call_of_ysera[373835] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
    },
    -- Warded against full loss of control effects.
    nullifying_shroud = {
        id = 378464,
        duration = 30.0,
        max_stack = 1,

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- Damage taken reduced by $w1%.$?$w2=1[; Immune to interrupt and silence effects.][]
    obsidian_scales = {
        id = 363916,
        duration = 12.0,
        max_stack = 1,

        -- Affected by:
        -- obsidian_bulwark[375406] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- The duration of incoming crowd control effects are increased by $s2%.
    oppressing_roar = {
        id = 372048,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- overawe[374346] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- spatial_paradox[406732] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },
    -- Next Emerald Blossom's healing  increased by $s1%.
    ouroboros = {
        id = 387350,
        duration = 3600,
        max_stack = 1,
    },
    -- Movement speed reduced by $w1%.
    permeating_chill = {
        id = 370898,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- permeating_chill[370897] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Restoring $w1 health every $t1 sec.
    renewing_blaze = {
        id = 374349,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- foci_of_life[375574] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- About to be picked up!
    rescue = {
        id = 370665,
        duration = 1.0,
        max_stack = 1,

        -- Affected by:
        -- spatial_paradox[406732] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Healing for $w1 every $t1 sec.
    reversion = {
        id = 366155,
        duration = 12.0,
        pandemic = true,
        max_stack = 1,

        -- Affected by:
        -- preservation_evoker[356810] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- grace_period[376239] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- punctuality[371270] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- timeless_magic[376240] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- timeless_magic[376240] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },
    -- Rewinding the last $s2 sec of damage.
    rewind = {
        id = 363534,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- spatial_paradox[406732] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- erasure[376210] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },
    -- Health increased by $s1%.
    rush_of_vitality = {
        id = 377088,
        duration = 15.0,
        max_stack = 1,
    },
    -- Next attack will miss.
    shape_of_flame = {
        id = 445134,
        duration = 4.0,
        max_stack = 1,
    },
    -- Asleep.
    sleep_walk = {
        id = 360806,
        duration = 20.0,
        max_stack = 1,

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- dream_catcher[410962] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- dream_catcher[410962] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- $@auracaster is restoring mana to you when they cast an empowered spell.$?$w2>0[; Healing and damage done increased by $w2%.][]
    source_of_magic = {
        id = 369459,
        duration = 3600.0,
        max_stack = 1,

        -- Affected by:
        -- potent_mana[418101] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- potent_mana[418101] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Able to cast spells while moving and spell range increased by $s4%.
    spatial_paradox = {
        id = 406732,
        duration = 10.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- spatial_paradox[406732] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Your next $s1 healing $Lspell:spells; will be held in a time lock.
    stasis = {
        id = 370537,
        duration = 3600,
        max_stack = 1,
    },
    -- About to be grabbed!
    swoop_up = {
        id = 370388,
        duration = 1.0,
        max_stack = 1,

        -- Affected by:
        -- spatial_paradox[406732] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Haste, movement speed, and cooldown recovery rate increased by $s1%.
    temporal_burst = {
        id = 431698,
        duration = 30.0,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Empower spells reach maximum level in $s1% less time.$?e1[ Healing of next empower spell increased by $s2%.][]
    temporal_compression = {
        id = 362877,
        duration = 15.0,
        max_stack = 1,
    },
    -- Damage taken reduced by $w1%.
    temporality = {
        id = 431872,
        duration = 3.0,
        tick_time = 0.3,
        max_stack = 1,
    },
    -- Stunned.
    terror_of_the_skies = {
        id = 372245,
        duration = 3.0,
        max_stack = 1,
    },
    -- Abilities have a chance to echo at $s1% power.
    thread_of_fate = {
        id = 431716,
        duration = 10.0,
        max_stack = 1,
    },
    -- Intellect increased by $s1%.
    time_convergence = {
        id = 431991,
        duration = 15.0,
        max_stack = 1,
    },
    -- $w1% of damage is being delayed and dealt to you over time.
    time_dilation = {
        id = 357170,
        duration = 8.0,
        max_stack = 1,

        -- Affected by:
        -- delay_harm[376207] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- timeless_magic[376240] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- timeless_magic[376240] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- May use Hover once, without incurring its cooldown.
    time_spiral = {
        id = 375234,
        duration = 10.0,
        max_stack = 1,
    },
    -- Frozen in time, incapacitated and invulnerable.
    time_stop = {
        id = 378441,
        duration = 5.0,
        max_stack = 1,

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- Your next empowered spell casts instantly at its maximum empower level.
    tip_the_scales = {
        id = 370553,
        duration = 3600,
        max_stack = 1,
    },
    -- Absorbing $w1 damage.
    twin_guardian = {
        id = 370889,
        duration = 5.0,
        max_stack = 1,
    },
    -- Damage taken from area-of-effect attacks reduced by $w1%.; Movement speed increased by $w2%.
    zephyr = {
        id = 374227,
        duration = 8.0,
        max_stack = 1,
    },
} )

-- Abilities
spec:RegisterAbilities( {
    -- Brings a dead party member back to life with $s1% health and mana. Cannot be cast when in combat.; 
    action_return = {
        id = 361227,
        color = 'bronze',
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 35.0, }
    },

    -- Project intense energy onto $s1 enemies, dealing $s2 Spellfrost damage to them.
    azure_strike = {
        id = 362969,
        color = 'blue',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.009,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 1.0879, 'pvp_multiplier': 1.68, 'variance': 0.05, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 355627, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- preservation_evoker[356810] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protracted_talons[369909] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },

    -- Weave the threads of time, reducing the cooldown of a major movement ability for all party and raid members by $381732s1% for $381732d.
    blessing_of_the_bronze = {
        id = 364342,
        color = 'bronze',
        cast = 0.0,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381732, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381741, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381746, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381748, 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381749, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381750, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381751, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381752, 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381753, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381754, 'target': TARGET_UNIT_CASTER, }
        -- #10: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381756, 'target': TARGET_UNIT_CASTER, }
        -- #11: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381757, 'target': TARGET_UNIT_CASTER, }
        -- #12: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 381758, 'target': TARGET_UNIT_CASTER, }
    },

    -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for $s2 upon removing any effect.
    cauterizing_flame = {
        id = 374251,
        color = 'red',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.014,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        talent = "cauterizing_flame",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL_MECHANIC, 'subtype': NONE, 'points': 100.0, 'value': 15, 'schools': ['physical', 'holy', 'fire', 'nature'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 3.5, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #2: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #3: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 2, 'schools': ['holy'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #4: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 3, 'schools': ['physical', 'holy'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- preservation_evoker[356810] #12: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Trap the enemy in a time loop for $d. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below $s1%.
    chrono_loop = {
        id = 383005,
        cast = 0.0,
        cooldown = 45.0,
        gcd = "global",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Take in a deep breath and fly to the targeted location, spewing molten cinders dealing $353759o1 Volcanic damage to enemies in your path.; Removes all root effects. You are immune to movement impairing and loss of control effects while flying.$?s395153[; Increases the duration of your active Ebon Might effects by ${$395153s3/1000} sec.][]
    deep_breath = {
        id = 357210,
        color = 'black',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 6.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY_MASK, 'value': 2360, 'schools': ['nature', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_MOVEMENT_FORCE_MAGNITUDE, 'points': -100.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- spatial_paradox[406732] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Tear into an enemy with a blast of blue magic, inflicting $o1 Spellfrost damage over $d, and slowing their movement speed by $370898s1% for $370898d.
    disintegrate = {
        id = 356995,
        color = 'blue',
        cast = 3.0,
        channeled = true,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'essence',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'sp_bonus': 1.441, 'chain_targets': 1, 'pvp_multiplier': 1.2, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- preservation_evoker[356810] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- preservation_evoker[356810] #16: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- natural_convergence[369913] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- natural_convergence[369913] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- energy_loop[372233] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 35.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- burning_adrenaline[444019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- burning_adrenaline[444019] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- essence_burst[359618] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Inhale, gathering the power of the Dream. Release to exhale, healing $s1 injured allies in a 30 yd cone in front of you for ${$355941s3+$355941o1*8*$<ysera>}.; I:   Heals $355941s3 instantly and ${$355941o1*8*$<ysera>} over $<sOneDur> sec.; II:  Heals ${$355941s3+$355941o1*2*$<ysera>} instantly and ${$355941o1*6*$<ysera>} over $<sTwoDur> sec.; III: Heals ${$355941s3+$355941o1*4*$<ysera>} instantly and ${$355941o1*4*$<ysera>} over $<sThreeDur> sec.
    dream_breath = {
        id = 355936,
        color = 'green',
        cast = empowered_cast_time,
        empowered = true,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.049,
        spendType = 'mana',

        talent = "dream_breath",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': AREA_TRIGGER, 'points': 5.0, 'value': 24231, 'schools': ['physical', 'holy', 'fire', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': AREA_TRIGGER, 'value': 24297, 'schools': ['physical', 'nature', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tip_the_scales[370553] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- tip_the_scales[370553] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- burning_adrenaline[444019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- temporal_compression[362877] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- [355936] Inhale, gathering the power of the Dream. Release to exhale, healing $s1 injured allies in a 30 yd cone in front of you for ${$355941s3+$355941o1*8*$<ysera>}.; I:   Heals $355941s3 instantly and ${$355941o1*8*$<ysera>} over $<sOneDur> sec.; II:  Heals ${$355941s3+$355941o1*2*$<ysera>} instantly and ${$355941o1*6*$<ysera>} over $<sTwoDur> sec.; III: Heals ${$355941s3+$355941o1*4*$<ysera>} instantly and ${$355941o1*4*$<ysera>} over $<sThreeDur> sec.
    dream_breath_355941 = {
        id = 355941,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 2.0, 'sp_bonus': 0.384, 'radius': 30.0, 'target': TARGET_UNIT_CONE_ALLY, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 0.768, 'radius': 30.0, 'target': TARGET_UNIT_CONE_ALLY, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }

        -- Affected by:
        -- preservation_evoker[356810] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406732] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- expanded_lungs[444845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- renewing_breath[371257] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- renewing_breath[371257] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- call_of_ysera[373835] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- temporal_compression[362877] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.5, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        from = "from_description",
    },

    -- Take in a deep breath and fly to the targeted location, healing all allies in your path for $363502s2 immediately, and $363502o1 over $363502d.; Healing increased by $s8% when not in a raid.; Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    dream_flight = {
        id = 359816,
        color = 'green',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        talent = "dream_flight",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 6.0, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY_MASK, 'value': 2360, 'schools': ['nature', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': MOD_MOVEMENT_FORCE_MAGNITUDE, 'points': -100.0, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406732] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Summon a flying projection of yourself that heals allies you pass through for $377913s1. Detonating your projection dispels all nearby allies of Magical effects, and heals for $378001o1 over $378001d.
    dream_projection = {
        id = 377509,
        cast = 0.5,
        cooldown = 60.0,
        gcd = "global",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': SUMMON, 'subtype': NONE, 'points': 20.0, 'value': 192459, 'schools': ['physical', 'holy', 'nature', 'arcane'], 'value1': 5396, 'radius': 4.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_DEST_DEST_FRONT, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Wrap an ally with temporal energy, healing them for $s1 and causing your next non-Echo healing spell to cast an additional time on that ally at $s2% of normal healing.
    echo = {
        id = 364343,
        color = 'bronze',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 2,
        spendType = 'essence',

        spend = 0.019,
        spendType = 'mana',

        talent = "echo",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': HEAL, 'subtype': NONE, 'sp_bonus': 1.2, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 70.0, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- preservation_evoker[356810] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- attuned_to_the_dream[376930] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- time_lord[372527] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 50.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- timeless_magic[376240] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- timeless_magic[376240] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
    },

    -- Grow a bulb from the Emerald Dream at an ally's location. After $d, heal up to $355916s2 injured allies within $s1 yds for $355916s1.
    emerald_blossom = {
        id = 355913,
        color = 'green',
        cast = 0.0,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.15,
        spendType = 'mana',

        -- spend = 3,
        -- spendType = 'essence',

        -- 1. [356810] preservation_evoker
        -- spend = 0.044,
        -- spendType = 'mana',

        -- 2. [396186] augmentation_evoker
        -- spend = 0.150,
        -- spendType = 'mana',

        -- 3. [356809] devastation_evoker
        -- spend = 0.150,
        -- spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 10.0, 'value': 23318, 'schools': ['holy', 'fire', 'frost'], 'target': TARGET_DEST_TARGET_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- preservation_evoker[356810] #12: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- improved_emerald_blossom[365262] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Commune with the Emerald Dream, restoring $s6% health and $s1% mana every $t1 sec for $d. Overhealing is transferred to an injured ally within $370984r yds.; Castable while stunned, disoriented, incapacitated, or silenced.
    emerald_communion = {
        id = 370960,
        color = 'green',
        cast = 0.0,
        cooldown = 180.0,
        gcd = "global",

        talent = "emerald_communion",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': OBS_MOD_POWER, 'tick_time': 1.0, 'points': 2.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_PACIFY_SILENCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 7, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 11, }
        -- #5: { 'type': APPLY_AURA, 'subtype': DUMMY, 'sp_bonus': 20.0, 'points': 20.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': MOD_ROOT, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- dreamwalker[377082] #0: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- burning_adrenaline[444019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- burning_adrenaline[444019] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
    },

    -- Engulf your target in dragonflame, damaging them for $443329s1 Fire or healing them for $443330s1. For each of your periodic effects on the target, effectiveness is increased by $s1%.
    engulf = {
        id = 443328,
        color = 'red',
        cast = 0.0,
        cooldown = 0.5,
        gcd = "global",

        spend = 0.014,
        spendType = 'mana',

        spend = 0.050,
        spendType = 'mana',

        spend = 0.050,
        spendType = 'mana',

        talent = "engulf",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- preservation_evoker[356810] #12: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- red_hot[444081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- red_hot[444081] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Expunge toxins affecting an ally, removing all Poison effects.
    expunge = {
        id = 365585,
        color = 'green',
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        spend = 0.100,
        spendType = 'mana',

        talent = "expunge",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- preservation_evoker[356810] #12: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Inhale, stoking your inner flame. Release to exhale, burning enemies in a cone in front of you for ${$<dmgI>+$<dotI>} Fire damage, reduced beyond 5 targets.$?s395153[; Increases the duration of your active Ebon Might effects by ${$395153s2/1000} sec.][]; Empowering causes more of the damage to be dealt immediately instead of over time.; I:   Deals $<dmgI> damage instantly and $<dotI> over $<durI> sec.; II:  Deals $<dmgII> damage instantly and $<dotII> over $<durII> sec.; III: Deals $<dmgIII> damage instantly and $<dotIII> over $<durIII> sec.
    fire_breath = {
        id = 357208,
        color = 'red',
        cast = empowered_cast_time,
        empowered = true,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.026,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- tip_the_scales[370553] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- tip_the_scales[370553] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- burning_adrenaline[444019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- temporal_compression[362877] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Increases haste by $s1% for all party and raid members for $d.; Allies receiving this effect will become Exhausted and unable to benefit from Fury of the Aspects or similar effects again for $57723d.
    fury_of_the_aspects = {
        id = 390386,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "none",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'points': 30.0, 'radius': 50000.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'points': 30.0, 'radius': 50000.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }
    },

    -- Launch yourself and gain $s2% increased movement speed for $<dura> sec.; Allows Evoker spells to be cast while moving. Does not affect empowered spells.
    hover = {
        id = 358267,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_AOE_DAMAGE_AVOIDANCE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': WATER_WALK, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ANIM_REPLACEMENT_SET, 'value': 1013, 'schools': ['physical', 'fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'amplitude': 1.0, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': UNKNOWN, 'subtype': NONE, 'trigger_spell': 358268, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 11, }
        -- #10: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': 56.0, 'target': TARGET_UNIT_CASTER, }
        -- #11: { 'type': APPLY_AURA, 'subtype': MOD_DISPEL_RESIST, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- aerial_mastery[365933] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- extended_flight[375517] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- time_spiral[375234] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Conjure a path of shifting stone towards the target location, rooting enemies for $355689d. Damage may cancel the effect.
    landslide = {
        id = 358385,
        color = 'black',
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        spend = 0.014,
        spendType = 'mana',

        talent = "landslide",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 6.0, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- forger_of_mountains[375528] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Send a flickering flame towards your target, $?c2[healing an ally for $361509s1 or dealing $361500s1 Fire damage to an enemy.][dealing $361500s1 Fire damage to an enemy or healing an ally for $361509s1.]
    living_flame = {
        id = 361469,
        color = 'red',
        cast = 2.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.12,
        spendType = 'mana',

        -- 0. [356810] preservation_evoker
        -- spend = 0.022,
        -- spendType = 'mana',

        -- 1. [356809] devastation_evoker
        -- spend = 0.120,
        -- spendType = 'mana',

        -- 3. [396186] augmentation_evoker
        -- spend = 0.120,
        -- spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- preservation_evoker[356810] #12: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- enkindled[375554] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enkindled[375554] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- chrono_flame[431442] #3: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 431443, 'value1': 2, 'target': TARGET_UNIT_CASTER, }
        -- ancient_flame[375583] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancient_flame[375583] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- lifespark[394552] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Players Only', 'Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Brings all dead party members back to life with $s1% health and mana. Cannot be cast when in combat.; 
    mass_return = {
        id = 361178,
        color = 'bronze',
        cast = 10.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT_WITH_AURA, 'subtype': NONE, 'points': 35.0, 'radius': 100.0, 'target': TARGET_CORPSE_SRC_AREA_RAID, }
    },

    -- Cleanses harmful effects from the target, removing all Magic and Poison effects.
    naturalize = {
        id = 360823,
        color = 'green',
        cast = 0.0,
        cooldown = 8.0,
        gcd = "global",

        spend = 0.014,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DISPEL, 'subtype': NONE, 'points': 100.0, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Wreathe yourself in arcane energy, preventing the next $s1 full loss of control effects against you. Lasts $d.
    nullifying_shroud = {
        id = 378464,
        color = 'pvp_talent',
        cast = 1.5,
        cooldown = 90.0,
        gcd = "global",

        spend = 0.009,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'mechanic': 18, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 1, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 2, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 5, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 13, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 24, }
        -- #6: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 14, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 17, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 30, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 10, }
        -- #10: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 12, }
        -- #11: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 383610, 'target': TARGET_UNIT_CASTER, }
        -- #12: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 383618, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Reinforce your scales, reducing damage taken by $s1%. Lasts $d.
    obsidian_scales = {
        id = 363916,
        color = 'black',
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        talent = "obsidian_scales",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -30.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'mechanic': 26, }
        -- #2: { 'type': APPLY_AURA, 'subtype': REDUCE_PUSHBACK, 'points': 100.0, 'value': 3, 'schools': ['physical', 'holy'], 'value1': 15, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': 9, }

        -- Affected by:
        -- obsidian_bulwark[375406] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by $s2% in the next $d.$?s374346[; Removes $s1 Enrage effect from each enemy.][]
    oppressing_roar = {
        id = 372048,
        color = 'black',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "oppressing_roar",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 1, 'schools': ['physical'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 27, 'schools': ['physical', 'holy', 'nature', 'frost'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 2, 'schools': ['holy'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 5, 'schools': ['physical', 'fire'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 13, 'schools': ['physical', 'fire', 'nature'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #6: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 24, 'schools': ['nature', 'frost'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 17, 'schools': ['physical', 'frost'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 7, 'schools': ['physical', 'holy', 'fire'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 30, 'schools': ['holy', 'fire', 'nature', 'frost'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #10: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 11, 'schools': ['physical', 'holy', 'nature'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #11: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 12, 'schools': ['fire', 'nature'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #12: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 23, 'schools': ['physical', 'holy', 'fire', 'frost'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #13: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 18, 'schools': ['holy', 'frost'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #14: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 10, 'schools': ['holy', 'nature'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #15: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 14, 'schools': ['holy', 'fire', 'nature'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #16: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 9, 'schools': ['physical', 'nature'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #17: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 3, 'schools': ['physical', 'holy'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }
        -- #18: { 'type': APPLY_AURA, 'subtype': MECHANIC_DURATION_MOD, 'pvp_multiplier': 0.6, 'points': 50.0, 'value': 26, 'schools': ['holy', 'nature', 'frost'], 'radius': 30.0, 'target': TARGET_UNIT_CONE_CASTER_TO_DEST_ENEMY, }

        -- Affected by:
        -- overawe[374346] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- spatial_paradox[406732] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for $d.
    quell = {
        id = 351338,
        cast = 0.0,
        cooldown = 40.0,
        gcd = "none",

        talent = "quell",
        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- The flames of life surround you for $d. While this effect is active, $s1% of damage you take is healed back over $374349d.
    renewing_blaze = {
        id = 374348,
        color = 'red',
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        talent = "renewing_blaze",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ALLY, 'target2': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': -10, 'target': TARGET_UNIT_TARGET_ALLY, 'target2': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- fire_within[375577] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Swoop to an ally and fly with them to the target location.
    rescue = {
        id = 370665,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "global",

        talent = "rescue",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -90.0, 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- spatial_paradox[406732] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Reverse an ally's injuries, $?s378196[instantly healing them for $378196s1% of damage taken in the last $378196s2 sec and an additional][healing them for] $o1 over $d.; When Reversion critically heals, its duration is extended by 2 sec, up to a maximum of ${2*$<cap>} sec.
    reversion = {
        id = 366155,
        color = 'bronze',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.028,
        spendType = 'mana',

        talent = "reversion",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'attributes': ['Suppress Points Stacking'], 'tick_time': 2.0, 'sp_bonus': 0.342, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- preservation_evoker[356810] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- grace_period[376239] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- punctuality[371270] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- timeless_magic[376240] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- timeless_magic[376240] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Rewind $?s376210[${$s3/2}%][$s3%] of damage taken in the last $s2 seconds by all allies within $a1 yds. Always heals for at least $<min>.; Healing increased by $s4% when not in a raid.
    rewind = {
        id = 363534,
        color = 'bronze',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 0.055,
        spendType = 'mana',

        talent = "rewind",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_HEAL, 'tick_time': 1.0, 'sp_bonus': 0.4, 'radius': 40.0, 'target': TARGET_SRC_CASTER, 'target2': TARGET_UNIT_SRC_AREA_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': DUMMY, 'subtype': NONE, 'pvp_multiplier': 1.52, }
        -- #3: { 'type': DUMMY, 'subtype': NONE, }

        -- Affected by:
        -- spatial_paradox[406732] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- erasure[376210] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Disorient an enemy for $d, causing them to sleep walk towards you. Damage has a chance to awaken them.
    sleep_walk = {
        id = 360806,
        color = 'green',
        cast = 1.5,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "sleep_walk",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_FEAR, 'chain_targets': 1, 'mechanic': asleep, 'value': 4, 'schools': ['fire'], 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': USE_NORMAL_MOVEMENT_SPEED, 'chain_targets': 1, 'points': 3.0, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- dream_catcher[410962] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- dream_catcher[410962] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 200.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Redirect your excess magic to a friendly healer for $d. When you cast an empowered spell, you restore ${$372571s1/100}.2% of their maximum mana per empower level. Limit 1.
    source_of_magic = {
        id = 369459,
        color = 'blue',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        talent = "source_of_magic",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_DONE_PERCENT, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- potent_mana[418101] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- potent_mana[418101] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by $s4% for $d.; Affects the nearest healer within $407497A1 yds, if you do not have a healer targeted.
    spatial_paradox = {
        id = 406732,
        color = 'bronze',
        cast = 0.0,
        cooldown = 0.5,
        gcd = "none",

        talent = "spatial_paradox",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DISPEL_RESIST, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ANIM_REPLACEMENT_SET, 'value': 1013, 'schools': ['physical', 'fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_RANGED_CRIT_CHANCE, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- #8: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #9: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }

        -- Affected by:
        -- spatial_paradox[406732] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Divert spiritual energy, healing an ally for $367230s1. Splits to injured allies within $<range> yds when empowered.; I:   Heals one ally.; II:  Heals a second ally.; III: Heals a third ally.
    spiritbloom = {
        id = 367226,
        color = 'green',
        cast = 2.5,
        channeled = true,
        empowered = true,
        cooldown = 30.0,
        gcd = "global",

        spend = 0.042,
        spendType = 'mana',

        talent = "spiritbloom",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- tip_the_scales[370553] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- tip_the_scales[370553] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spiritual_clarity[376150] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- burning_adrenaline[444019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- flow_state[390148] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- temporal_compression[362877] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Causes your next ${$s1*3} helpful spells to be duplicated and stored in a time lock. You may reactivate Stasis any time within $s2 sec to quickly unleash their magic.
    stasis = {
        id = 370537,
        color = 'bronze',
        cast = 0.0,
        cooldown = 90.0,
        gcd = "none",

        spend = 0.040,
        spendType = 'mana',

        talent = "stasis",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
    },

    -- Grab an enemy and fly with them to the target location.
    swoop_up = {
        id = 370388,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "global",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_ROOT, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- spatial_paradox[406732] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },

    -- Send forward a vortex of temporal energy, absorbing $<shield> damage on you and any allies in its path. Absorption is reduced beyond $s2 targets.
    temporal_anomaly = {
        id = 373861,
        color = 'bronze',
        cast = 1.5,
        cooldown = 15.0,
        gcd = "global",

        spend = 0.075,
        spendType = 'mana',

        talent = "temporal_anomaly",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': CREATE_AREATRIGGER, 'subtype': NONE, 'points': 1.0, 'value': 25294, 'schools': ['holy', 'fire', 'nature', 'arcane'], 'radius': 0.0, 'target': TARGET_DEST_CASTER_FRONT, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- preservation_evoker[356810] #8: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- timeless_magic[376240] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- timeless_magic[376240] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Stretch time around an ally for the next $d, causing $s1% of damage they would take to instead be dealt over $d.$?s363899[; Healing a target under the effects of Time Dilation clears a portion of the delayed damage.][]
    time_dilation = {
        id = 357170,
        color = 'bronze',
        cast = 0.0,
        cooldown = 60.0,
        gcd = "none",

        spend = 0.022,
        spendType = 'mana',

        talent = "time_dilation",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 50.0, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': -10, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- delay_harm[376207] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- timeless_magic[376240] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- timeless_magic[376240] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -15.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- flow_state[390148] #8: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- flow_state[390148] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- Bend time, allowing you and your allies within $A1 yds to cast their major movement ability once in the next $375234d, even if it is on cooldown.
    time_spiral = {
        id = 374968,
        color = 'bronze',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "time_spiral",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 40.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }

        -- Affected by:
        -- spatial_paradox[406732] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
    },

    -- Freeze an ally's timestream for $d. While frozen in time they are invulnerable, cannot act, and auras do not progress.; You may reactivate Time Stop to end this effect early.
    time_stop = {
        id = 378441,
        color = 'pvp_talent',
        cast = 0.0,
        cooldown = 1.0,
        gcd = "none",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': STRANGULATE, 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_PCT, 'points': -100.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_TIME_RATE, 'points': -100.0, 'target': TARGET_UNIT_TARGET_RAID, }

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    tip_the_scales = {
        id = 370553,
        color = 'bronze',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "none",

        talent = "tip_the_scales",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Sunder an enemy's protective magic, dealing $s1 Spellfrost damage to absorb shields.
    unravel = {
        id = 368432,
        color = 'blue',
        cast = 0.0,
        cooldown = 9.0,
        gcd = "global",

        spend = 0.010,
        spendType = 'mana',

        talent = "unravel",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 7.205, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- preservation_evoker[356810] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- preservation_evoker[356810] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Fly to an ally and heal them for $361195s1, or heal yourself for the same amount.
    verdant_embrace = {
        id = 360995,
        color = 'green',
        cast = 0.0,
        cooldown = 0.5,
        gcd = "global",

        spend = 0.033,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        spend = 0.100,
        spendType = 'mana',

        talent = "verdant_embrace",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- preservation_evoker[356810] #5: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -6000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- preservation_evoker[356810] #8: { 'type': APPLY_AURA, 'subtype': MOD_COOLDOWN_BY_HASTE_REGEN, 'target': TARGET_UNIT_CASTER, }
        -- preservation_evoker[356810] #12: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Conjure an updraft to lift you and your $s3 nearest allies within $A1 yds into the air, reducing damage taken from area-of-effect attacks by $s1% and increasing movement speed by $s2% for $d.
    zephyr = {
        id = 374227,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "zephyr",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_AOE_DAMAGE_AVOIDANCE, 'points': -20.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'radius': 20.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 30.0, 'radius': 20.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': HOVER, 'attributes': ['Players Only'], 'points': 4.0, 'radius': 20.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
    },

} )