-- EvokerDevastation.lua
-- July 2024

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 1467 )

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Essence )

spec:RegisterTalents( {
    -- Evoker Talents
    aerial_mastery                  = { 93352, 365933, 1 }, -- Hover gains $s1 additional charge.
    ancient_flame                   = { 93271, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by $375583s1%.
    attuned_to_the_dream            = { 93292, 376930, 2 }, -- Your healing done and healing received are increased by $s1%.
    blast_furnace                   = { 93309, 375510, 1 }, -- Fire Breath's damage over time lasts $s1 sec longer.
    bountiful_bloom                 = { 93291, 370886, 1 }, -- Emerald Blossom heals $s1 additional allies.
    cauterizing_flame               = { 93294, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for $s2 upon removing any effect.
    clobbering_sweep                = { 93296, 375443, 1 }, -- Tail Swipe's cooldown is reduced by ${$s1/-1000} sec.
    draconic_legacy                 = { 93300, 376166, 1 }, -- Your Stamina is increased by $s1%.
    enkindled                       = { 93295, 375554, 2 }, -- Living Flame deals $s1% more damage and healing.
    expunge                         = { 93306, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    extended_flight                 = { 93349, 375517, 2 }, -- Hover lasts ${$s1/1000} sec longer.
    exuberance                      = { 93299, 375542, 1 }, -- While above 75% health, your movement speed is increased by $s1%.
    fire_within                     = { 93345, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by ${$s1/-1000} sec.
    foci_of_life                    = { 93345, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over $<newDur> sec.
    forger_of_mountains             = { 93270, 375528, 1 }, -- Landslide's cooldown is reduced by ${$s1/-1000} sec, and it can withstand $s2% more damage before breaking.
    heavy_wingbeats                 = { 93296, 368838, 1 }, -- Wing Buffet's cooldown is reduced by ${$s1/-1000} sec.
    inherent_resistance             = { 93355, 375544, 2 }, -- Magic damage taken reduced by $s1%.
    innate_magic                    = { 93302, 375520, 2 }, -- Essence regenerates $s1% faster.
    instinctive_arcana              = { 93310, 376164, 2 }, -- Your Magic damage done is increased by $s1%.
    landslide                       = { 93305, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for $355689d. Damage may cancel the effect.
    leaping_flames                  = { 93343, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth                     = { 93347, 375561, 2 }, -- Green spells restore $s1% more health.
    natural_convergence             = { 93312, 369913, 1 }, -- Disintegrate channels $s1% faster$?c3[ and Eruption's cast time is reduced by $s3%][].
    obsidian_bulwark                = { 93289, 375406, 1 }, -- Obsidian Scales has an additional charge.
    obsidian_scales                 = { 93304, 363916, 1 }, -- Reinforce your scales, reducing damage taken by $s1%. Lasts $d.
    oppressing_roar                 = { 93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by $s2% in the next $d.$?s374346[; Removes $s1 Enrage effect from each enemy.][]
    overawe                         = { 93297, 374346, 1 }, -- Oppressing Roar removes $372048s1 Enrage effect from each enemy, and its cooldown is reduced by ${$s3/-1000} sec.
    panacea                         = { 93348, 387761, 1 }, -- Emerald Blossom and Verdant Embrace instantly heal you for $387763s1 when cast.
    permeating_chill                = { 93303, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by $s1% for $370898d.
    potent_mana                     = { 93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by $s1%.
    protracted_talons               = { 93307, 369909, 1 }, -- Azure Strike damages $s1 additional $Lenemy:enemies;.
    quell                           = { 93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for $d.
    recall                          = { 93301, 371806, 1 }, -- You may reactivate $?s359816[Dream Flight and ][]$?s403631[Breath of Eons][Deep Breath] within $s1 sec after landing to travel back in time to your takeoff location.
    regenerative_magic              = { 93353, 387787, 1 }, -- Your Leech is increased by $s1%.
    renewing_blaze                  = { 93354, 374348, 1 }, -- The flames of life surround you for $d. While this effect is active, $s1% of damage you take is healed back over $374349d.
    rescue                          = { 93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    scarlet_adaptation              = { 93340, 372469, 1 }, -- Store $s1% of your effective healing, up to $<cap>. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk                      = { 93293, 360806, 1 }, -- Disorient an enemy for $d, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic                 = { 93344, 369459, 1 }, -- Redirect your excess magic to a friendly healer for $d. When you cast an empowered spell, you restore ${$372571s1/100}.2% of their maximum mana per empower level. Limit 1.
    spatial_paradox                 = { 93351, 406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by $s4% for $d.; Affects the nearest healer within $407497A1 yds, if you do not have a healer targeted.
    tailwind                        = { 93290, 375556, 1 }, -- Hover increases your movement speed by ${$378105s1+$358267s2}% for the first $378105d.
    terror_of_the_skies             = { 93342, 371032, 1 }, -- $?s403631[Breath of Eons][Deep Breath] stuns enemies for $372245d.
    time_spiral                     = { 93351, 374968, 1 }, -- Bend time, allowing you and your allies within $A1 yds to cast their major movement ability once in the next $375234d, even if it is on cooldown.
    tip_the_scales                  = { 93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian                   = { 93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to $s1% of your maximum health for $370889d.
    unravel                         = { 93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing $s1 Spellfrost damage to absorb shields.
    verdant_embrace                 = { 93341, 360995, 1 }, -- Fly to an ally and heal them for $361195s1, or heal yourself for the same amount.
    walloping_blow                  = { 93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec. 
    zephyr                          = { 93346, 374227, 1 }, -- Conjure an updraft to lift you and your $s3 nearest allies within $A1 yds into the air, reducing damage taken from area-of-effect attacks by $s1% and increasing movement speed by $s2% for $d.

    -- Devastation Talents
    animosity                       = { 93330, 375797, 1 }, -- Casting an empower spell extends the duration of Dragonrage by ${$s1/1000} sec, up to a maximum of ${$s2/1000} sec.
    arcane_intensity                = { 93274, 375618, 2 }, -- Disintegrate deals $s1% more damage.
    arcane_vigor                    = { 93315, 386342, 1 }, -- Shattering Star grants Essence Burst.
    azure_essence_burst             = { 93333, 375721, 1 }, -- Azure Strike has a $s1% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    bombardments                    = { 94936, 434300, 1 }, -- $?c1[Mass Disintegrate][Mass Eruption] marks your primary target for destruction for the next $434473d.; You and your allies have a chance to trigger a Bombardment when attacking marked targets, dealing $<dmg> Volcanic damage split amongst all nearby enemies.
    burning_adrenaline              = { 94946, 444020, 1 }, -- Engulf quickens your pulse, reducing the cast time of your next spell by $444019s1%. Stacks up to $444019u charges.
    burnout                         = { 93314, 375801, 1 }, -- Fire Breath damage has $s1% chance to cause your next Living Flame to be instant cast, stacking $375802u times.
    catalyze                        = { 93280, 386283, 1 }, -- While channeling Disintegrate your Fire Breath on the target deals damage $s1% more often.
    causality                       = { 93366, 375777, 1 }, -- Disintegrate reduces the remaining cooldown of your empower spells by ${$s1/-1000}.2 sec each time it deals damage.; Pyre reduces the remaining cooldown of your empower spells by ${$s2/-1000}.2 sec per enemy struck, up to $<pyreCap> sec.
    charged_blast                   = { 93317, 370455, 1 }, -- Your Blue damage increases the damage of your next Pyre by $370454s1%, stacking $370454u times.
    conduit_of_flame                = { 94949, 444843, 1 }, -- Critical strike chance against targets $?c1[above][below] $s2% health increased by $s1%.
    consume_flame                   = { 94922, 444088, 1 }, -- Engulf consumes $s1 sec of $?c1[Fire Breath][Dream Breath] from the target, detonating it and $?c1[damaging][healing] all nearby targets equal to $s3% of the amount consumed, reduced beyond $s2 targets.
    dense_energy                    = { 93284, 370962, 1 }, -- Pyre's Essence cost is reduced by $s1.
    diverted_power                  = { 94928, 441219, 1 }, -- Bombardments have a chance to generate Essence Burst.
    draconic_instincts              = { 94931, 445958, 1 }, -- Your wounds have a small chance to cauterize, healing you for $s1% of damage taken. Occurs more often from attacks that deal high damage.
    dragonrage                      = { 93331, 375087, 1 }, -- Erupt with draconic fury and exhale Pyres at $375088s1 enemies within $375088A1 yds.; For $d, Essence Burst's chance to occur is increased to $s2%$?s376888[, and you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health][].
    engulf                          = { 94950, 443328, 1 }, -- Engulf your target in dragonflame, damaging them for $443329s1 Fire or healing them for $443330s1. For each of your periodic effects on the target, effectiveness is increased by $s1%.
    engulfing_blaze                 = { 93282, 370837, 1 }, -- Living Flame deals $s2% increased damage and healing, but its cast time is increased by ${$s1/1000}.1 sec.
    enkindle                        = { 94956, 444016, 1 }, -- Essence abilities are enhanced with Flame, dealing $s1% of healing or damage done as Fire over 8 sec.
    essence_attunement              = { 93319, 375722, 1 }, -- Essence Burst stacks ${$s1+1} times.
    eternity_surge                  = { 93275, 359073, 1 }, -- Focus your energies to release a salvo of pure magic, dealing $<dmg> Spellfrost damage to an enemy. Damages additional enemies within $359077A2 yds of the target when empowered.; I:   Damages $?s375757[2 enemies][1 enemy].; II:  Damages $?s375757[4 enemies][2 enemies].; III: Damages $?s375757[6 enemies][3 enemies].
    eternitys_span                  = { 93320, 375757, 1 }, -- Eternity Surge and Shattering Star hit twice as many targets.
    event_horizon                   = { 93318, 411164, 1 }, -- Eternity Surge's cooldown is reduced by ${$s1/-1000} sec.
    expanded_lungs                  = { 94923, 444845, 1 }, -- Fire Breath's damage over time is increased by $s1%. Dream Breath's heal over time is increased by $s1%.
    extended_battle                 = { 94928, 441212, 1 }, -- Essence abilities extend Bombardments by $s1 sec.
    eye_of_infinity                 = { 93318, 411165, 1 }, -- Eternity Surge deals $s1% increased damage to your primary target.
    fan_the_flames                  = { 94923, 444318, 1 }, -- Casting Engulf reignites all active Enkindles, increasing their remaining damage or healing over time by $s1%.
    feed_the_flames                 = { 93313, 369846, 1 }, -- After casting $411288s2 Pyres, your next Pyre will explode into a Firestorm. ; In addition, Pyre and Disintegrate deal $s1% increased damage to enemies within your Firestorm.
    firestorm                       = { 93278, 368847, 1 }, -- An explosion bombards the target area with white-hot embers, dealing $456657o1 Fire damage to enemies over $369372d.
    focusing_iris                   = { 93315, 386336, 1 }, -- Shattering Star's damage taken effect lasts ${$s1/1000} sec longer.
    font_of_magic                   = { 93279, 411212, 1 }, -- Your empower spells' maximum level is increased by 1, and they reach maximum empower level $s3% faster.
    hardened_scales                 = { 94933, 441180, 1 }, -- Obsidian Scales reduces damage taken by an additional ${$s1/-1}%.
    heat_wave                       = { 93281, 375725, 2 }, -- Fire Breath deals $s1% more damage.
    hoarded_power                   = { 93325, 375796, 1 }, -- Essence Burst has a $s1% chance to not be consumed.
    honed_aggression                = { 93329, 371038, 2 }, -- Azure Strike and Living Flame deal $s1% more damage.
    imminent_destruction            = { 93326, 370781, 1 }, -- Deep Breath reduces the Essence costs of Disintegrate and Pyre by $411055s1 and increases their damage by $411055s2% for $411055d after you land.
    imposing_presence               = { 93332, 371016, 1 }, -- Quell's cooldown is reduced by ${$s1/-1000} sec.
    inner_radiance                  = { 93332, 386405, 1 }, -- Your Living Flame and Emerald Blossom are $s1% more effective on yourself.
    iridescence                     = { 93321, 370867, 1 }, -- Casting an empower spell increases the damage of your next $386353u spells of the same color by $386353s1% within $386353d.
    lay_waste                       = { 93273, 371034, 1 }, -- Deep Breath's damage is increased by $s1%.
    lifecinders                     = { 94931, 444322, 1 }, -- Renewing Blaze also applies to your target or $s1 nearby injured $Lally:allies; at $s2% value.
    maneuverability                 = { 94941, 433871, 1 }, -- $?s403631[Breath of Eons][Deep Breath] can now be steered in your desired direction.; In addition, $?s403631[Breath of Eons][Deep Breath] burns targets for $441172o1 Volcanic damage over $441172d.
    mass_disintegrate               = { 94939, 436335, 1 }, -- Empower spells cause your next Disintegrate to strike up to $s1 targets. When striking less than $s1 targets, Disintegrate damage is increased by $s2% for each missing target.
    melt_armor                      = { 94921, 441176, 1 }, -- $?c1[Deep Breath][Breath of Eons] causes enemies to take $s2% increased damage from Bombardments and Essence abilities for $441172d.
    menacing_presence               = { 94933, 441181, 1 }, -- Knocking enemies up or backwards reduces their damage done to you by $s1% for $441201d.
    might_of_the_black_dragonflight = { 94952, 441705, 1 }, -- Black spells deal $s1% increased damage.
    nimble_flyer                    = { 94943, 441253, 1 }, -- While Hovering, damage taken from area of effect attacks is reduced by ${$s1/-1}%.
    onslaught                       = { 94944, 441245, 1 }, -- Entering combat grants a charge of Burnout, causing your next Living Flame to cast instantly.
    onyx_legacy                     = { 93327, 386348, 1 }, -- Deep Breath's cooldown is reduced by 1 min.
    power_nexus                     = { 93276, 369908, 1 }, -- Increases your maximum Essence to $<max>.
    power_swell                     = { 93322, 370839, 1 }, -- Casting an empower spell increases your Essence regeneration rate by $376850s1% for $376850d.
    pyre                            = { 93334, 357211, 1 }, -- Lob a ball of flame, dealing $357212s1 Fire damage to the target and nearby enemies.
    red_hot                         = { 94945, 444081, 1 }, -- Engulf gains $s2 additional charge and deals $s1% increased damage and healing.
    ruby_embers                     = { 93282, 365937, 1 }, -- Living Flame deals $361500o2 damage over $361500d to enemies, or restores $361509o2 health to allies over $361509d. Stacks $361509u times.
    ruby_essence_burst              = { 93285, 376872, 1 }, -- Your Living Flame has a $s1% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    scintillation                   = { 93324, 370821, 1 }, -- Disintegrate has a $s2% chance each time it deals damage to launch a level 1 Eternity Surge at $s1% power.
    scorching_embers                = { 93365, 370819, 1 }, -- Fire Breath causes enemies to take $s1% increased damage from your Red spells.
    shape_of_flame                  = { 94937, 445074, 1 }, -- Tail Swipe and Wing Buffet scorch enemies and blind them with ash, causing their next attack within $445134d to miss.
    shattering_star                 = { 93316, 370452, 1 }, -- Exhale $?s375757[bolts][a bolt] of concentrated power from your mouth $?s375757[at $s1 enemies ][]for $s2 Spellfrost damage that cracks the $?s375757[targets'][target's] defenses, increasing the damage they take from you by $s3% for $d.$?s386342[; Grants Essence Burst.][]
    slipstream                      = { 94943, 441257, 1 }, -- Deep Breath resets the cooldown of Hover.
    snapfire                        = { 93277, 370783, 1 }, -- Pyre and Living Flame have a $s1% chance to cause your next Firestorm to be instantly cast without triggering its cooldown, and deal $370818s2% increased damage.
    spellweavers_dominance          = { 93323, 370845, 1 }, -- Your damaging critical strikes deal ${$s1+200}% damage instead of the usual 200%.
    titanic_precision               = { 94920, 445625, 1 }, -- Living Flame and Azure Strike have $s1 extra chance to trigger Essence Burst when they critically strike.
    titanic_wrath                   = { 93272, 386272, 2 }, -- Essence Burst increases the damage of affected spells by ${$s1}.1%.
    trailblazer                     = { 94937, 444849, 1 }, -- $?c1[Hover and Deep Breath][Hover, Deep Breath, and Dream Flight] travel $s1% faster, and Hover travels $s1% further.
    traveling_flame                 = { 99857, 444140, 1 }, -- Engulf increases the duration of $?c1[Fire Breath][Fire Breath or Dream Breath] by $s1 sec and causes it to spread to a target within $?c1[$s2][$s3] yds.
    tyranny                         = { 93328, 376888, 1 }, -- During Deep Breath and Dragonrage you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    unrelenting_siege               = { 94934, 441246, 1 }, -- For each second you are in combat, Azure Strike, Living Flame, and $?c1[Disintegrate][Eruption] deal $s1% increased damage, up to $s2%.
    volatility                      = { 93283, 369089, 2 }, -- Pyre has a $s1% chance to flare up and explode again on a nearby target.
    wingleader                      = { 94953, 441206, 1 }, -- Bombardments reduce the cooldown of $?c1[Deep Breath][Breath of Eons] by $s1 sec for each target struck, up to $s2 sec.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    chrono_loop          = 5456, -- (383005) Trap the enemy in a time loop for $d. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below $s1%.
    crippling_force      = 5471, -- (384660) Disintegrate amplifies Permeating Chill to reduce movement speed by an additional $s1% each time it deals damage, up to $s2%.
    divide_and_conquer   = 5556, -- (384689) $?s403631[Breath of Eons][Deep Breath] forms curtains of fire, preventing line of sight to enemies outside its walls and burning enemies who walk through them for $403516o1 Fire damage. Lasts $403727d.
    dream_catcher        = 5599, -- (410962) Sleep Walk no longer has a cooldown, but its cast time is increased by ${$s2/1000}.1 sec.
    dreamwalkers_embrace = 5617, -- (415651) Verdant Embrace tethers you to an ally, increasing movement speed by $415516s2% and slowing and siphoning $415649s2 life from enemies who come in contact with the tether.; The tether lasts up to $415516d or until you move more than $s1 yards away from your ally.
    nullifying_shroud    = 5467, -- (378464) Wreathe yourself in arcane energy, preventing the next $s1 full loss of control effects against you. Lasts $d.
    obsidian_mettle      = 5460, -- (378444) While Obsidian Scales is active you gain immunity to interrupt, silence, and pushback effects.
    scouring_flame       = 5462, -- (378438) Fire Breath burns away 1 beneficial Magic effect per empower level from all targets.
    swoop_up             = 5466, -- (370388) Grab an enemy and fly with them to the target location.
    time_stop            = 5464, -- (378441) Freeze an ally's timestream for $d. While frozen in time they are invulnerable, cannot act, and auras do not progress.; You may reactivate Time Stop to end this effect early.
    unburdened_flight    = 5469, -- (378437) Hover makes you immune to movement speed reduction effects.
} )

-- Auras
spec:RegisterAuras( {
    -- The cast time of your next Living Flame is reduced by $w1%.
    ancient_flame = {
        id = 375583,
        duration = 3600,
        max_stack = 1,

        -- Affected by:
        -- burnout[375802] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
    },
    -- Cooldown of Heroic Leap reduced by $s1%.
    blessing_of_the_bronze = {
        id = 381758,
        duration = 3600.0,
        max_stack = 1,
    },
    -- Damage taken has a chance to summon air support from the Dracthyr.
    bombardments = {
        id = 434473,
        duration = 10.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Next spell cast time reduced by $s1%.
    burning_adrenaline = {
        id = 444019,
        duration = 15.0,
        max_stack = 1,
    },
    -- Next Living Flame's cast time is reduced by $w1%.
    burnout = {
        id = 375802,
        duration = 15.0,
        max_stack = 1,
    },
    -- Your next Pyre deals $s1% more damage.
    charged_blast = {
        id = 370454,
        duration = 30.0,
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
        -- devastation_evoker[356809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation_evoker[356809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lay_waste[371034] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shattering_star[370452] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- spellweavers_dominance[370845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- Suffering $w1 Spellfrost damage every $t1 sec.
    disintegrate = {
        id = 356995,
        duration = 3.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- devastation_evoker[356809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation_evoker[356809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- natural_convergence[369913] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- natural_convergence[369913] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- arcane_intensity[375618] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shattering_star[370452] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- spellweavers_dominance[370845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- burning_adrenaline[444019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- burning_adrenaline[444019] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- imminent_destruction[411055] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- imminent_destruction[411055] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- imminent_destruction[411055] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- melt_armor[441172] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },
    -- Burning for $s1 every $t1 sec.
    divide_and_conquer = {
        id = 403516,
        duration = 6.0,
        tick_time = 3.0,
        max_stack = 1,
    },
    -- Essence Burst has a $s2% chance to occur.$?s376888[; Your spells gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.][]
    dragonrage = {
        id = 375087,
        duration = 18.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Tethered with an ally, causing enemies who touch the tether to be damaged and slowed.
    dreamwalkers_embrace = {
        id = 415516,
        duration = 10.0,
        tick_time = 0.5,
        max_stack = 1,
    },
    -- Cannot benefit from Heroism or other similar effects.
    exhaustion = {
        id = 57723,
        duration = 600.0,
        max_stack = 1,
    },
    -- After ${($411288s~2*-1)-$w1} more $LPyre:Pyres;, your next Pyre will explode into a Firestorm.
    feed_the_flames = {
        id = 405874,
        duration = 120.0,
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
        -- nimble_flyer[441253] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- time_spiral[375234] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Essence costs of Disintegrate and Pyre are reduced by $s1, and their damage increased by $s2%.
    imminent_destruction = {
        id = 411055,
        duration = 12.0,
        max_stack = 1,
    },
    -- Your next Red spell deals $s1% more damage.
    iridescence_red = {
        id = 386353,
        duration = 10.0,
        max_stack = 1,
    },
    -- Rooted.
    landslide = {
        id = 355689,
        duration = 15.0,
        max_stack = 1,

        -- Affected by:
        -- might_of_the_black_dragonflight[441705] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },
    -- Burning for $w2 Fire damage every $t2 sec.
    living_flame = {
        id = 361500,
        duration = 12.0,
        tick_time = 3.0,
        max_stack = 1,

        -- Affected by:
        -- devastation_evoker[356809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation_evoker[356809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enkindled[375554] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enkindled[375554] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- engulfing_blaze[370837] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- honed_aggression[371038] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- honed_aggression[371038] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_radiance[386405] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- shattering_star[370452] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- spellweavers_dominance[370845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- ancient_flame[375583] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancient_flame[375583] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
    },
    -- $?e0[Suffering $w1 Volcanic damage every $t1 sec.][]$?e1[ Damage taken from Essence abilities and bombardments increased by $s2%.][]
    melt_armor = {
        id = 441172,
        duration = 12.0,
        tick_time = 2.0,
        max_stack = 1,

        -- Affected by:
        -- devastation_evoker[356809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation_evoker[356809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- lay_waste[371034] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shattering_star[370452] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- spellweavers_dominance[370845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
    },
    -- Damage done to $@auracaster reduced by $s1%.
    menacing_presence = {
        id = 441201,
        duration = 8.0,
        max_stack = 1,
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
        -- hardened_scales[441180] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- might_of_the_black_dragonflight[441705] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- The duration of incoming crowd control effects are increased by $s2%.
    oppressing_roar = {
        id = 372048,
        duration = 10.0,
        max_stack = 1,

        -- Affected by:
        -- overawe[374346] #2: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- spatial_paradox[406732] #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- might_of_the_black_dragonflight[441705] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Movement speed reduced by $w1%.
    permeating_chill = {
        id = 370898,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- permeating_chill[370897] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Essence regeneration rate increased by $w1%.
    power_swell = {
        id = 376850,
        duration = 4.0,
        max_stack = 1,
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
    -- Next attack will miss.
    shape_of_flame = {
        id = 445134,
        duration = 4.0,
        max_stack = 1,
    },
    -- Taking $w3% increased damage from $@auracaster.
    shattering_star = {
        id = 370452,
        duration = 4.0,
        max_stack = 1,

        -- Affected by:
        -- devastation_evoker[356809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation_evoker[356809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- eternitys_span[375757] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- focusing_iris[386336] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- shattering_star[370452] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- spellweavers_dominance[370845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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
    -- Your next Firestorm is instant cast and deals $s2% increased damage.
    snapfire = {
        id = 370818,
        duration = 15.0,
        max_stack = 1,
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
    -- About to be grabbed!
    swoop_up = {
        id = 370388,
        duration = 1.0,
        max_stack = 1,

        -- Affected by:
        -- spatial_paradox[406732] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
    },
    -- Stunned.
    terror_of_the_skies = {
        id = 372245,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- might_of_the_black_dragonflight[441705] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- devastation_evoker[356809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation_evoker[356809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protracted_talons[369909] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- honed_aggression[371038] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- honed_aggression[371038] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shattering_star[370452] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- spellweavers_dominance[370845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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
        -- might_of_the_black_dragonflight[441705] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- onyx_legacy[386348] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -60000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
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
        -- devastation_evoker[356809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation_evoker[356809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- natural_convergence[369913] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- natural_convergence[369913] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- arcane_intensity[375618] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 8.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shattering_star[370452] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- spellweavers_dominance[370845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- burning_adrenaline[444019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- burning_adrenaline[444019] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- imminent_destruction[411055] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- imminent_destruction[411055] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- imminent_destruction[411055] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- melt_armor[441172] #1: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Erupt with draconic fury and exhale Pyres at $375088s1 enemies within $375088A1 yds.; For $d, Essence Burst's chance to occur is increased to $s2%$?s376888[, and you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health][].
    dragonrage = {
        id = 375087,
        color = 'red',
        cast = 0.0,
        cooldown = 120.0,
        gcd = "global",

        talent = "dragonrage",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 375088, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
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
        -- emerald_blossom[365261] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- lush_growth[375561] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- lush_growth[375561] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
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
        -- red_hot[444081] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- red_hot[444081] #1: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Focus your energies to release a salvo of pure magic, dealing $<dmg> Spellfrost damage to an enemy. Damages additional enemies within $359077A2 yds of the target when empowered.; I:   Damages $?s375757[2 enemies][1 enemy].; II:  Damages $?s375757[4 enemies][2 enemies].; III: Damages $?s375757[6 enemies][3 enemies].
    eternity_surge = {
        id = 359073,
        color = 'blue',
        cast = 2.5,
        channeled = true,
        empowered = true,
        cooldown = 30.0,
        gcd = "global",

        talent = "eternity_surge",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- tip_the_scales[370553] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- tip_the_scales[370553] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- event_horizon[411164] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -3000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- font_of_magic[411212] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- burning_adrenaline[444019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- [359073] Focus your energies to release a salvo of pure magic, dealing $<dmg> Spellfrost damage to an enemy. Damages additional enemies within $359077A2 yds of the target when empowered.; I:   Damages $?s375757[2 enemies][1 enemy].; II:  Damages $?s375757[4 enemies][2 enemies].; III: Damages $?s375757[6 enemies][3 enemies].
    eternity_surge_359077 = {
        id = 359077,
        color = 'blue',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'sp_bonus': 6.1985, 'variance': 0.05, 'radius': 12.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- devastation_evoker[356809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation_evoker[356809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shattering_star[370452] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- spellweavers_dominance[370845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        from = "from_description",
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
        -- font_of_magic[411212] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- burning_adrenaline[444019] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- An explosion bombards the target area with white-hot embers, dealing $456657o1 Fire damage to enemies over $369372d.
    firestorm = {
        id = 368847,
        color = 'red',
        cast = 2.0,
        cooldown = 20.0,
        gcd = "global",

        talent = "firestorm",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 369372, 'radius': 10.0, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- snapfire[370818] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- snapfire[370818] #2: { 'type': APPLY_AURA, 'subtype': IGNORE_SPELL_COOLDOWN, 'target': TARGET_UNIT_CASTER, }
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
        -- nimble_flyer[441253] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
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
        -- might_of_the_black_dragonflight[441705] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- enkindled[375554] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enkindled[375554] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- engulfing_blaze[370837] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 300.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- engulfing_blaze[370837] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- inner_radiance[386405] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- ancient_flame[375583] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancient_flame[375583] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- burnout[375802] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
    },

    -- [361469] Send a flickering flame towards your target, $?c2[healing an ally for $361509s1 or dealing $361500s1 Fire damage to an enemy.][dealing $361500s1 Fire damage to an enemy or healing an ally for $361509s1.]
    living_flame_361500 = {
        id = 361500,
        color = 'red',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 2.32001, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 3.0, 'sp_bonus': 0.066286, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- devastation_evoker[356809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation_evoker[356809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- enkindled[375554] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enkindled[375554] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- engulfing_blaze[370837] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- honed_aggression[371038] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- honed_aggression[371038] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_radiance[386405] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- shattering_star[370452] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- spellweavers_dominance[370845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- ancient_flame[375583] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancient_flame[375583] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        from = "from_description",
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
        -- hardened_scales[441180] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -5.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- might_of_the_black_dragonflight[441705] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- might_of_the_black_dragonflight[441705] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- might_of_the_black_dragonflight[441705] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Lob a ball of flame, dealing $357212s1 Fire damage to the target and nearby enemies.
    pyre = {
        id = 357211,
        color = 'red',
        cast = 0.0,
        cooldown = 0.0,
        gcd = "global",

        spend = 3,
        spendType = 'essence',

        talent = "pyre",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': TRIGGER_MISSILE, 'subtype': NONE, 'trigger_spell': 393568, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- dense_energy[370962] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- imminent_destruction[411055] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- imminent_destruction[411055] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- imminent_destruction[411055] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
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
        -- imposing_presence[371016] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- burning_adrenaline[444019] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'attributes': ['Suppress Points Stacking'], 'points': -30.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
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

    -- Exhale $?s375757[bolts][a bolt] of concentrated power from your mouth $?s375757[at $s1 enemies ][]for $s2 Spellfrost damage that cracks the $?s375757[targets'][target's] defenses, increasing the damage they take from you by $s3% for $d.$?s386342[; Grants Essence Burst.][]
    shattering_star = {
        id = 370452,
        color = 'blue',
        cast = 0.0,
        cooldown = 20.0,
        gcd = "global",

        talent = "shattering_star",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Area Effects Use Target Radius'], 'sp_bonus': 2.3056, 'variance': 0.05, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- devastation_evoker[356809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation_evoker[356809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- eternitys_span[375757] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- focusing_iris[386336] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 2000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- shattering_star[370452] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- spellweavers_dominance[370845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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
        -- devastation_evoker[356809] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- devastation_evoker[356809] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- shattering_star[370452] #2: { 'type': APPLY_AURA, 'subtype': MOD_SPELL_DAMAGE_FROM_CASTER, 'attributes': ['Area Effects Use Target Radius'], 'points': 20.0, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- spellweavers_dominance[370845] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 0.667, 'points': 30.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
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