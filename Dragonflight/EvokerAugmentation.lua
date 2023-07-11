-- EvokerAugmentation.lua
-- July 2023

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 1473 )

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
    oppressing_roar       = { 93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by $s2% in the next $d.$?s374346[; Removes $s1 Enrage effect from each enemy. Oppressing Roar's cooldown is reduced by $374346s1 sec for each Enrage dispelled.][]
    overawe               = { 93297, 374346, 1 }, -- Oppressing Roar removes $372048s1 Enrage effect from each enemy, and its cooldown is reduced by $s1 sec for each Enrage dispelled.
    panacea               = { 93348, 387761, 1 }, -- Emerald Blossom instantly heals you for $387763s1 when cast.
    permeating_chill      = { 93303, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by $s1% for $370898d.
    potent_mana           = { 93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by $s1%.
    protracted_talons     = { 93307, 369909, 1 }, -- Azure Strike damages $s1 additional $Lenemy:enemies;.
    quell                 = { 93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for $d.
    recall                = { 93301, 371806, 1 }, -- You may reactivate $?s359816[Dream Flight and ][]$?s403631[Breath of Eons][Deep Breath] within $s1 sec after landing to travel back in time to your takeoff location.
    regenerative_magic    = { 93353, 387787, 1 }, -- Your Leech is increased by $s1%.
    renewing_blaze        = { 93344, 374348, 1 }, -- The flames of life surround you for $d. While this effect is active, $s1% of damage you take is healed back over $374349d.
    rescue                = { 93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    scarlet_adaptation    = { 93340, 372469, 1 }, -- Store $s1% of your effective healing, up to $<cap>. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk            = { 93293, 360806, 1 }, -- Disorient an enemy for $d, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic       = { 93354, 369459, 1 }, -- Redirect your excess magic to a friendly healer for $d. When you cast an empowered spell, you restore ${$372571s1/100}.2% of their maximum mana per empower level. Limit 1.
    tailwind              = { 93290, 375556, 1 }, -- Hover increases your movement speed by ${$378105s1+$358267s2}% for the first $378105d.
    terror_of_the_skies   = { 93342, 371032, 1 }, -- $?s403631[Breath of Eons][Deep Breath] stuns enemies for $372245d.
    time_spiral           = { 93351, 374968, 1 }, -- Bend time, allowing you and your allies within $A1 yds to cast their major movement ability once in the next $375234d, even if it is on cooldown.
    tip_the_scales        = { 93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian         = { 93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to $s1% of your maximum health for $370889d.
    unravel               = { 93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing $s1 Spellfrost damage to absorb shields.
    verdant_embrace       = { 93341, 360995, 1 }, -- Fly to an ally and heal them for $361195s1, or heal yourself for the same amount.
    walloping_blow        = { 93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr                = { 93346, 374227, 1 }, -- Conjure an updraft to lift you and your $s3 nearest allies within $A1 yds into the air, reducing damage taken from area-of-effect attacks by $s1% and increasing movement speed by $s2% for $d.

    -- Augmentation Talents
    accretion             = { 93229, 407876, 1 }, -- Eruption reduces the remaining cooldown of Upheaval by ${$411932s1/-1000}.1 sec.
    anachronism           = { 93223, 407869, 1 }, -- Prescience has a $s1% chance to grant Essence Burst.
    aspects_favor         = { 93217, 407243, 2 }, -- Obsidian Scales activates Black Attunement, and amplifies it to increase maximum health by $<blacktotal>% for $407254d.; Hover activates Bronze Attunement, and amplifies it to increase movement speed by $<bronzetotal>% for $407244d.
    bestow_weyrnstone     = { 93195, 408233, 1 }, -- Conjure a pair of Weyrnstones, one for your target ally and one for yourself. Only one ally may bear your Weyrnstone at a time.; A Weyrnstone can be activated by the bearer to transport them to the other Weyrnstone's location, if they are within 100 yds.
    blistering_scales     = { 93209, 360827, 1 }, -- Protect an ally with $n explosive dragonscales, increasing their Armor by $<perc>% of your own.; Melee attacks against the target cause 1 scale to explode, dealing $<dmg> Volcanic damage to enemies near them. This damage can only occur every few sec.; Blistering Scales can only be placed on one target at a time. Casts on your enemy's target if they have one.
    breath_of_eons        = { 93234, 403631, 1 }, -- Fly to the targeted location, exposing Temporal Wounds on enemies in your path for $409560d.; Temporal Wounds accumulate $409560s1% of damage dealt by your allies affected by Ebon Might, then critically strike for that amount as Arcane damage.$?s395153[; Applies Ebon Might for ${$395153s3/1000} sec.][]; Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    chrono_ward           = { 93235, 409676, 1 }, -- When allies deal damage with Temporal Wounds, they gain a shield for $s1% of the damage dealt. Absorption cannot exceed $s2% of your maximum health.
    defy_fate             = { 93222, 404195, 1 }, -- Fatal attacks are diverted into a nearby timeline, preventing the damage, and your death, in this one.; The release of temporal energy restores ${$404381o1*(1+$404381s2/100)} health to you, and $404381o1 to ${$404381i-1} nearby allies, over $404381d. Healing starts high and declines over the duration.; May only occur once every $404369d.
    draconic_attunements  = { 93218, 403208, 1 }, -- Learn to attune yourself to the essence of the Black or Bronze Dragonflights:; $@spellicon403264$@spellname403264: You and your $s2 nearest allies have $403264s1% increased maximum health.; $@spellicon403265$@spellname403265:You and your $s2 nearest allies have $403265s1% increased movement speed.
    dream_of_spring       = { 93359, 414969, 1 }, -- Emerald Blossom no longer has a cooldown, deals $s4% increased healing, and increases the duration of your active Ebon Might effects by $s2 sec, but costs $s1 Essence.
    ebon_might            = { 93198, 395152, 1 }, -- Increase your $i nearest allies' primary stat by $s1% of your own, and cause you to deal $395296s1% more damage, for $d.; May only affect $i allies at once, and prefers to imbue damage dealers.; Eruption, $?s403631[Breath of Eons][Deep Breath], and your empower spells extend the duration of these effects.
    echoing_strike        = { 93221, 410784, 1 }, -- Azure Strike has a $s1% chance per target hit to echo, casting again.
    eruption              = { 93200, 395160, 1 }, -- Cause a violent eruption beneath an enemy's feet, dealing $s1 Volcanic damage split between them and nearby enemies.$?s395153[; Increases the duration of your active Ebon Might effects by ${$395153s1/1000} sec.][]
    essence_attunement    = { 93219, 375722, 1 }, -- Essence Burst stacks ${$s1+1} times.
    essence_burst         = { 93220, 396187, 1 }, -- Your Living Flame has a $376872s1% chance, and your Azure Strike has a $375721s1% chance, to make your next Eruption $?s414969[or Emerald Blossom ][]cost no Essence.$?s375722[ Stacks $359618u times.][]
    fate_mirror           = { 93367, 412774, 1 }, -- Prescience grants the ally a chance for their spells and abilities to echo their damage or healing, dealing $s1% of the amount again.
    font_of_magic         = { 93207, 408083, 1 }, -- Your empower spells' maximum level is increased by 1, and they reach maximum empower level $s3% faster.
    geomancy              = { 93360, 410787, 1 }, -- Azure Strike reduces the remaining cooldown of Landslide by ${$s1/1000} sec per target hit.
    hoarded_power         = { 93212, 375796, 1 }, -- Essence Burst has a $s1% chance to not be consumed.
    ignition_rush         = { 93230, 408775, 1 }, -- Essence Burst reduces the cast time of Eruption by $s1%.
    imposing_presence     = { 93199, 371016, 1 }, -- Quell's cooldown is reduced by ${$s1/-1000} sec.
    infernos_blessing     = { 93197, 410261, 1 }, -- Fire Breath grants the inferno's blessing for $410263d to you and your allies affected by Ebon Might, giving their damaging attacks and spells a high chance to deal an additional $<dmg> Fire damage.
    inner_radiance        = { 93199, 386405, 1 }, -- Your Living Flame and Emerald Blossom are $s1% more effective on yourself.
    interwoven_threads    = { 93369, 412713, 1 }, -- The cooldowns of your spells are reduced by $s1%.
    molten_blood          = { 93211, 410643, 1 }, -- When cast, Blistering Scales grants the target a shield that absorbs up to $<shield> damage for $410651d based on their missing health. Lower health targets gain a larger shield.
    momentum_shift        = { 93231, 408004, 1 }, -- Consuming Essence Burst grants you $s1% Intellect for $408005d. Stacks up to $408005u times.
    motes_of_possibility  = { 93227, 409267, 1 }, -- Essence abilities have a chance to form a mote of diverted time near you. Anyone who comes in contact with the mote gains $s1 seconds of reduced cooldown to their major ability.
    overlord              = { 93213, 410260, 1 }, -- $?s403631[Breath of Eons][Deep Breath] casts an Eruption at the first $s1 enemies struck.
    perilous_fate         = { 93235, 410253, 1 }, -- Breath of Eons reduces enemies' movement speed by $409560s2%, and reduces their attack speed by $409560s3%, for $409560d.
    plot_the_future       = { 93226, 407866, 1 }, -- $?s403631[Breath of Eons][Deep Breath] grants you Fury of the Aspects for $s1 sec after you land, without causing Exhaustion.
    power_nexus           = { 93201, 369908, 1 }, -- Increases your maximum Essence to $<max>.
    prescience            = { 93358, 409311, 1 }, -- Grant an ally the gift of foresight, increasing their critical strike chance by $410089s1% $?s412774[and occasionally copying their damage and healing spells at $412774s1% power ][]for $410089d.; Affects the nearest ally within $A1 yds, preferring damage dealers, if you do not have an ally targeted.
    prolong_life          = { 93359, 410687, 1 }, -- Your effects that extend Ebon Might also extend Symbiotic Bloom.
    pupil_of_alexstrasza  = { 93221, 407814, 1 }, -- When cast at an enemy, Living Flame strikes $s1 additional enemy for $s2% damage.
    reactive_hide         = { 93210, 409329, 1 }, -- Each time Blistering Scales explodes it deals $410256s1% more damage for $410256d, stacking $410256u times.
    regenerative_chitin   = { 93211, 406907, 1 }, -- Blistering Scales has $s1 more scales, and casting Eruption restores $s3 $Lscale:scales;.
    ricocheting_pyroclast = { 93208, 406659, 1 }, -- Eruption deals $s1% more damage per enemy struck, up to ${$s2*$s1}%.
    seismic_slam          = { 93205, 408543, 2 }, -- Landslide causes enemies who are mid-air to be slammed to the ground, stunning them for $s1 sec.
    spatial_paradox       = { 93225, 406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by $s4% for $d.; Affects the nearest healer within $407497A1 yds, if you do not have a healer targeted.
    stretch_time          = { 93382, 410352, 1 }, -- While flying during $?s403631[Breath of Eons][Deep Breath], $410355s1% of damage you would take is instead dealt over $410355d.
    symbiotic_bloom       = { 93215, 410685, 2 }, -- Emerald Blossom increases targets' healing received by $s1% for $410686d.
    tectonic_locus        = { 93202, 408002, 1 }, -- Upheaval deals $s1% increased damage to the primary target, and launches them higher.
    time_skip             = { 93232, 404977, 1 }, -- Surge forward in time, causing your cooldowns to recover $s1% faster for $d.
    timelessness          = { 93368, 412710, 1 }, -- Enchant an ally to appear out of sync with the normal flow of time, reducing threat they generate by $s1% for $d. Less effective on tank-specialized allies. ; May only be placed on one target at a time.
    tomorrow_today        = { 93369, 412723, 1 }, -- Time Skip channels for ${$s1/1000} sec longer.
    unyielding_domain     = { 93202, 412733, 1 }, -- Upheaval cannot be interrupted, and has an additional $s1% chance to critically strike.
    upheaval              = { 93203, 396286, 1 }, -- Gather earthen power beneath your enemy's feet and send them hurtling upwards, dealing $396288s2 Volcanic damage to the target and nearby enemies.$?s395153[; Increases the duration of your active Ebon Might effects by ${$395153s2/1000} sec.][]; Empowering expands the area of effect.; I:   $<radiusI> yd radius.; II:  $<radiusII> yd radius.; III: $<radiusIII> yd radius.
    volcanism             = { 93206, 406904, 1 }, -- Eruption's Essence cost is reduced by $s1.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    born_in_flame        = 5612, -- (414937) Casting Ebon Might grants Burnout immediately and every $419240t1 sec for $419240d, reducing the cast time of Living Flame by $375802s1%.
    chrono_loop          = 5564, -- (383005) Trap the enemy in a time loop for $d. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below $s1%.
    divide_and_conquer   = 5557, -- (384689) $?s403631[Breath of Eons][Deep Breath] forms curtains of fire, preventing line of sight to enemies outside its walls and burning enemies who walk through them for $403516o1 Fire damage. Lasts $403727d.
    dream_catcher        = 5613, -- (410962) Sleep Walk no longer has a cooldown, but its cast time is increased by ${$s2/1000}.1 sec.
    dream_projection     = 5559, -- (377509) Summon a flying projection of yourself that heals allies you pass through for $377913s1. Detonating your projection dispels all nearby allies of Magical effects, and heals for $378001o1 over $378001d.
    dreamwalkers_embrace = 5615, -- (415651) Verdant Embrace tethers you to an ally, increasing movement speed by $415516s2% and slowing and siphoning $415649s2 life from enemies who come in contact with the tether.; The tether lasts up to $415516d or until you move more than $s1 yards away from your ally.
    nullifying_shroud    = 5558, -- (378464) Wreathe yourself in arcane energy, preventing the next $s1 full loss of control effects against you. Lasts $d.
    obsidian_mettle      = 5563, -- (378444) While Obsidian Scales is active you gain immunity to interrupt, silence, and pushback effects.
    scouring_flame       = 5561, -- (378438) Fire Breath burns away 1 beneficial Magic effect per empower level from all targets.
    swoop_up             = 5562, -- (370388) Grab an enemy and fly with them to the target location.
    time_stop            = 5619, -- (378441) Freeze an ally's timestream for $d. While frozen in time they are invulnerable, cannot act, and auras do not progress.; You may reactivate Time Stop to end this effect early.
    unburdened_flight    = 5560, -- (378437) Hover makes you immune to movement speed reduction effects.
} )

-- Auras
spec:RegisterAuras( {
    -- The cast time of your next Living Flame is reduced by $w1%.
    ancient_flame = {
        id = 375583,
        duration = 3600,
        max_stack = 1,
    },
    -- Black Attunement grants $w1% additional health.
    black_aspects_favor = {
        id = 407254,
        duration = function() return 12.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    -- $?$w1>0[Armor increased by $w1.][Armor increased by $w2%.] Melee attacks against you have a chance to cause an explosion of Volcanic damage.
    blistering_scales = {
        id = 360827,
        duration = function() return 600.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = function() return 15 + talent.regenerative_chitin.rank * 5 end,

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- regenerative_chitin[406907] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHARGES, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- Exposing Temporal Wounds on enemies in your path. Immune to crowd control.
    breath_of_eons = {
        id = 403631,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- spatial_paradox[406732] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- spatial_paradox[406789] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': RANGE, }
    },
    -- Bronze Attunement's grants $w1% additional movement speed.
    bronze_aspects_favor = {
        id = 407244,
        duration = function() return 4.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    -- Trapped in a time loop.
    chrono_loop = {
        id = 383005,
        duration = 5.0,
        max_stack = 1,
    },
    -- Absorbing $w1 damage.
    chrono_ward = {
        id = 409678,
        duration = function() return 20.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    -- Spewing molten cinders. Immune to crowd control.
    deep_breath = {
        id = 357210,
        duration = 6.0,
        max_stack = 1,

        -- Affected by:
        -- spatial_paradox[406732] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- spatial_paradox[406789] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': RANGE, }
    },
    -- Suffering $w1 Spellfrost damage every $t1 sec.
    disintegrate = {
        id = 356995,
        duration = 3.0,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- augmentation_evoker[396186] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- augmentation_evoker[396186] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- natural_convergence[369913] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- natural_convergence[369913] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- interwoven_threads[412713] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- ebon_might[395296] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.428, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ebon_might[395296] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.428, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- Your Ebon Might is active on allies.; Your damage done is increased by $w1%.
    ebon_might = {
        id = 395296,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,
        dot = "buff",

        -- Affected by:
        -- close_as_clutchmates[396043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Your next Eruption $?s414969[or Emerald Blossom ][]costs no Essence.
    essence_burst = {
        id = 392268,
        duration = function() return 15.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,

        -- Affected by:
        -- essence_attunement[375722] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': MAX_STACKS, }
        -- ignition_rush[408775] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- ignition_rush[408775] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Haste increased by $w1%.
    fury_of_the_aspects = {
        id = 390386,
        duration = 40.0,
        max_stack = 1,
    },
    -- Movement speed increased by $w2%.; Evoker spells may be cast while moving. Does not affect empowered spells.$?e9[; Immune to movement speed reduction effects.][]
    hover = {
        id = 358267,
        duration = function() return 6.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- aerial_mastery[365933] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- extended_flight[375517] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- time_spiral[375234] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },
    -- Granted the inferno's blessing by $@auracaster, giving your damaging attacks and spells a high chance to deal additional Fire damage.
    infernos_blessing = {
        id = 410263,
        duration = function() return 8.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    -- Absorbing $w1 damage.; Immune to interrupts and silence effects.
    lava_shield = {
        id = 405295,
        duration = function() return 15.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- Your next Living Flame will strike $w1 additional $?$w1=1[target][targets].
    leaping_flames = {
        id = 370901,
        duration = function() return 30.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },
    -- Absorbing $w1 damage.
    molten_blood = {
        id = 410651,
        duration = function() return 30.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,

        -- Affected by:
        -- augmentation_evoker[396186] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- augmentation_evoker[396186] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- attuned_to_the_dream[376930] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },
    -- Intellect increased by $w1%.
    momentum_shift = {
        id = 408005,
        duration = 6.0,
        duration = function() return 6.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    -- Your next Emerald Blossom will restore an additional $406054s1% of maximum health to you.
    nourishing_sands = {
        id = 406043,
        duration = function() return 20.0 * ( 1 + 1.25 * stat.mastery_value ) end,
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
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- Damage taken reduced by $w1%.$?$w2=1[; Immune to interrupt and silence effects.][]
    obsidian_scales = {
        id = 363916,
        duration = function() return 12.0 * ( 1 + 1.25 * stat.mastery_value ) end,
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
        -- spatial_paradox[406732] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- spatial_paradox[406789] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': RADIUS, }
    },
    -- Movement speed reduced by $w1%.
    permeating_chill = {
        id = 370898,
        duration = 3.0,
        max_stack = 1,

        -- Affected by:
        -- permeating_chill[370897] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- $?$W1>0[$@auracaster is increasing your critical strike chance by $w1%.][]$?e0&e1[; ][]$?e1[Your abilities have a chance to echo $412774s1% of their damage and healing.][]
    prescience = {
        id = 410089,
        duration = function() return 18.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    -- Blistering Scales deals $w1% increased damage.
    reactive_hide = {
        id = 410256,
        duration = function() return 12.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    -- $w1% of damage taken is being healed over time.
    renewing_blaze = {
        id = 374348,
        duration = function() return 8.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,

        -- Affected by:
        -- fire_within[375577] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },
    -- About to be picked up!
    rescue = {
        id = 370665,
        duration = 1.0,
        max_stack = 1,
    },
    -- Versatility increased by ${$W1}.1%. Cast by $@auracaster.
    shifting_sands = {
        id = 413984,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        tick_time = 1.0,
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
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- $@auracaster is restoring mana to you when they cast an empowered spell.$?$w2>0[; Healing and damage done increased by $w2%.][]
    source_of_magic = {
        id = 369459,
        duration = function() return 1800.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,

        -- Affected by:
        -- potent_mana[418101] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- potent_mana[418101] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },
    -- Able to cast spells while moving and range increased by $s5%. Cast by $@auracaster.
    spatial_paradox = {
        id = 406789,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- About to be grabbed!
    swoop_up = {
        id = 370388,
        duration = 1.0,
        max_stack = 1,
    },
    -- Healing received increased by $w1%.
    symbiotic_bloom = {
        id = 410686,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,

        -- Affected by:
        -- symbiotic_bloom[410685] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER_BY_LABEL, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Accumulating damage from $@auracaster's allies who are affected by Ebon Might.$?$w2<0[; Movement speed reduced by $w2%.; Attack speed reduced by $w3%.][]
    temporal_wound = {
        id = 409560,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        tick_time = 1.0,
        max_stack = 1,

        -- Affected by:
        -- close_as_clutchmates[396043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
    },
    -- Stunned.
    terror_of_the_skies = {
        id = 372245,
        duration = 3.0,
        max_stack = 1,
    },
    -- Surging forward in time, causing your cooldowns to recover $s1% faster.
    time_skip = {
        id = 404977,
        duration = 2.0,
        max_stack = 1,

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- tomorrow_today[412723] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- May use Hover once, without incurring its cooldown.
    time_spiral = {
        id = 375234,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
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
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },
    -- Threat generation reduced by $w1%. Cast by $@auracaster.
    timelessness = {
        id = 412710,
        duration = function() return 1800.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
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
        duration = function() return 5.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    -- Damage taken from area-of-effect attacks reduced by $w1%.; Movement speed increased by $w2%.
    zephyr = {
        id = 374227,
        duration = function() return 8.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
} )

local lastEssenceTick = 0

do
    local previous = 0

    spec:RegisterUnitEvent( "UNIT_POWER_UPDATE", "player", nil, function( event, unit, power )
        if power == "ESSENCE" then
            local value, cap = UnitPower( "player", Enum.PowerType.Essence ), UnitPowerMax( "player", Enum.PowerType.Essence )

            if value == cap then
                lastEssenceTick = 0

            elseif lastEssenceTick == 0 and value < cap or lastEssenceTick ~= 0 and value > previous then
                lastEssenceTick = GetTime()
            end

            previous = value
        end
    end )
end


spec:RegisterStateExpr( "empowerment_level", function()
    return buff.tip_the_scales.down and args.empower_to or max_empower
end )

-- This deserves a better fix; when args.empower_to = "maximum" this will cause that value to become max_empower (i.e., 3 or 4).
spec:RegisterStateExpr( "maximum", function()
    return max_empower
end )


spec:RegisterHook( "runHandler", function( action )
    local ability = class.abilities[ action ]
    local color = ability.color

    if color then
        if color == "red" and buff.iridescence_red.up then removeStack( "iridescence_red" )
        elseif color == "blue" and buff.iridescence_blue.up then removeStack( "iridescence_blue" ) end
    end

    if talent.power_swell.enabled and ability.empowered then
        applyBuff( "power_swell" ) -- TODO: Modify Essence regen rate.
    end

    empowerment.active = false
end )


spec:RegisterGear( "tier29", 200381, 200383, 200378, 200380, 200382 )
spec:RegisterGear( "tier30", 202491, 202489, 202488, 202487, 202486 )


spec:RegisterHook( "reset_precast", function()
    max_empower = talent.font_of_magic.enabled and 4 or 3

    if essence.current < essence.max and lastEssenceTick > 0 then
        local partial = min( 0.95, ( query_time - lastEssenceTick ) * essence.regen )
        gain( partial, "essence" )
        if Hekili.ActiveDebug then Hekili:Debug( "Essence increased to %.2f from passive regen.", partial ) end
    end
end )


spec:RegisterStateTable( "evoker", setmetatable( {},{
    __index = function( t, k )
        if k == "use_early_chaining" then k = "use_early_chain" end
        local val = state.settings[ k ]
        if val ~= nil then return val end
        return false
    end
} ) )


local empowered_cast_time

do
    local stages = {
        1,
        1.75,
        2.5,
        3.25
    }

    empowered_cast_time = setfenv( function()
        if buff.tip_the_scales.up then return 0 end
        return stages[ args.empower_to or max_empower ] * ( talent.font_of_magic.enabled and 0.8 or 1 ) * haste
    end, state )
end

-- Abilities
spec:RegisterAbilities( {
    -- Brings a dead party member back to life with $s1% health and mana. Cannot be cast when in combat.;
    action_return = {
        id = 361227,
        cast = 10.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = 0.008,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': RESURRECT, 'subtype': NONE, 'points': 35.0, }
    },

    -- Project intense energy onto $s1 enemies, dealing $s2 Spellfrost damage to them.
    azure_strike = {
        id = 362969,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = 0.009,
        spendType = 'mana',

        startsCombat = true,

        handler = function ()
            if talent.azure_essence_burst.enabled and buff.dragonrage.up then addStack( "essence_burst", nil, 1 ) end -- TODO:  Does this give 2 stacks if hitting 2 targets w/ Essence Attunement?
            if talent.charged_blast.enabled then addStack( "charged_blast", nil, min( active_enemies, spell_targets.azure_strike ) ) end
        end,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.755, 'pvp_multiplier': 1.2, 'variance': 0.05, 'radius': 6.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 355627, 'triggers': azure_strike, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- augmentation_evoker[396186] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- augmentation_evoker[396186] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- augmentation_evoker[396186] #14: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 2.0, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- augmentation_evoker[396186] #15: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 2.0, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- protracted_talons[369909] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- ebon_might[395296] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.428, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ebon_might[395296] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.428, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Conjure a pair of Weyrnstones, one for your target ally and one for yourself. Only one ally may bear your Weyrnstone at a time.; A Weyrnstone can be activated by the bearer to transport them to the other Weyrnstone's location, if they are within 100 yds.
    bestow_weyrnstone = {
        id = 408233,
        cast = 3.0,
        cooldown = 60.0,
        gcd = "spell",

        talent = "bestow_weyrnstone",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_RAID, }

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Protect an ally with $n explosive dragonscales, increasing their Armor by $<perc>% of your own.; Melee attacks against the target cause 1 scale to explode, dealing $<dmg> Volcanic damage to enemies near them. This damage can only occur every few sec.; Blistering Scales can only be placed on one target at a time. Casts on your enemy's target if they have one.
    blistering_scales = {
        id = 360827,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        talent = "blistering_scales",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_RESISTANCE, 'attributes': ['Suppress Points Stacking'], 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_BASE_RESISTANCE_PCT, 'attributes': ['Suppress Points Stacking'], 'points': 30.0, 'value': 1, 'schools': ['physical'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- regenerative_chitin[406907] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 5.0, 'target': TARGET_UNIT_CASTER, 'modifies': CHARGES, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Fly to the targeted location, exposing Temporal Wounds on enemies in your path for $409560d.; Temporal Wounds accumulate $409560s1% of damage dealt by your allies affected by Ebon Might, then critically strike for that amount as Arcane damage.$?s395153[; Applies Ebon Might for ${$395153s3/1000} sec.][]; Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    breath_of_eons = {
        id = 403631,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "spell",

        talent = "breath_of_eons",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 6.0, 'target': TARGET_DEST_DEST_GROUND, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY_MASK, 'value': 2360, 'schools': ['nature', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- spatial_paradox[406732] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- spatial_paradox[406789] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': RANGE, }
    },

    -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for $s2 upon removing any effect.
    cauterizing_flame = {
        id = 374251,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "spell",

        spend = 0.1,
        spendType = 'mana',

        -- 0. [356810] preservation_evoker
        -- spend = 0.013,
        -- spendType = 'mana',

        -- 1. [356809] devastation_evoker
        -- spend = 0.100,
        -- spendType = 'mana',

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
        cooldown = 60.0,
        gcd = "spell",

        spend = 0.020,
        spendType = 'mana',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 20.0, 'target': TARGET_UNIT_TARGET_ENEMY, }
    },

    -- Take in a deep breath and fly to the targeted location, spewing molten cinders dealing $353759o1 Volcanic damage to enemies in your path.; Removes all root effects. You are immune to movement impairing and loss of control effects while flying.$?s395153[; Increases the duration of your active Ebon Might effects by ${$395153s3/1000} sec.][]
    deep_breath = {
        id = 357210,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "spell",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 6.0, 'target': TARGET_DEST_DEST_GROUND, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ALLOW_ONLY_ABILITY, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -200.0, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY_MASK, 'value': 2360, 'schools': ['nature', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- spatial_paradox[406732] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- spatial_paradox[406789] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': RANGE, }
    },

    -- Tear into an enemy with a blast of blue magic, inflicting $o1 Spellfrost damage over $d, and slowing their movement speed by $370898s1% for $370898d.
    disintegrate = {
        id = 356995,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = 3,
        spendType = 'essence',

        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DAMAGE, 'tick_time': 1.0, 'sp_bonus': 0.874, 'pvp_multiplier': 1.2, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- augmentation_evoker[396186] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- augmentation_evoker[396186] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- natural_convergence[369913] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- natural_convergence[369913] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': AURA_PERIOD, }
        -- interwoven_threads[412713] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- ebon_might[395296] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.428, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ebon_might[395296] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.428, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Summon a flying projection of yourself that heals allies you pass through for $377913s1. Detonating your projection dispels all nearby allies of Magical effects, and heals for $378001o1 over $378001d.
    dream_projection = {
        id = 377509,
        cast = 0.5,
        cooldown = 60.0,
        gcd = "spell",

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

    -- Increase your $i nearest allies' primary stat by $s1% of your own, and cause you to deal $395296s1% more damage, for $d.; May only affect $i allies at once, and prefers to imbue damage dealers.; Eruption, $?s403631[Breath of Eons][Deep Breath], and your empower spells extend the duration of these effects.
    ebon_might = {
        id = 395152,
        cast = 1.5,
        cooldown = 30.0,
        gcd = "spell",

        spend = 0.010,
        spendType = 'mana',

        talent = "ebon_might",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'points': 10.0, 'radius': 100.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'value': 1, 'schools': ['physical'], 'radius': 100.0, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- close_as_clutchmates[396043] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 40.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_1_VALUE, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Grow a bulb from the Emerald Dream at an ally's location. After $d, heal up to $355916s2 injured allies within $s1 yds for $355916s1.$?s361361[; Allies healed are imbued with an $@spellname359793, healing for $359793o1 over $359793d.][]
    emerald_blossom = {
        id = 355913,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "spell",

        spend = 0.15,
        spendType = 'mana',

        -- spend = 3,
        -- spendType = 'essence',

        -- 1. [356810] preservation_evoker
        -- spend = 0.048,
        -- spendType = 'mana',

        -- 3. [356809] devastation_evoker
        -- spend = 0.150,
        -- spendType = 'mana',

        -- 4. [356816] initial_evoker
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
        -- dream_of_spring[414969] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- dream_of_spring[414969] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- dream_of_spring[414969] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- interwoven_threads[412713] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- essence_burst[392268] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- essence_burst[392268] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': IGNORE_SHAPESHIFT, }
        -- nourishing_sands[406043] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -3.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
    },

    -- Cause a violent eruption beneath an enemy's feet, dealing $s1 Volcanic damage split between them and nearby enemies.$?s395153[; Increases the duration of your active Ebon Might effects by ${$395153s1/1000} sec.][]
    eruption = {
        id = 395160,
        cast = 2.5,
        cooldown = 0.0,
        gcd = "spell",

        spend = 3,
        spendType = 'essence',

        talent = "eruption",
        startsCombat = true,

        handler = function()
            if buff.blistering_scales.up then
                addStack( "blistering_scales", nil, 1 )
            end
        end,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'attributes': ['Always AOE Line of Sight'], 'sp_bonus': 2.0, 'pvp_multiplier': 1.5, 'radius': 8.0, 'target': TARGET_DEST_TARGET_ENEMY, 'target2': TARGET_UNIT_DEST_AREA_ENEMY, }

        -- Affected by:
        -- augmentation_evoker[396186] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- augmentation_evoker[396186] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- natural_convergence[369913] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- volcanism[406904] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -1.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- essence_burst[392268] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': POWER_COST, }
        -- essence_burst[392268] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- essence_burst[392268] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'attributes': ['Suppress Points Stacking'], 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- ebon_might[395296] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.428, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ebon_might[395296] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.428, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Expunge toxins affecting an ally, removing all Poison effects.
    expunge = {
        id = 365585,
        cast = 0.0,
        cooldown = 8.0,
        gcd = "spell",

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
        cast = 0.0,
        cooldown = 30.0,
        gcd = "spell",

        spend = 0.026,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- tip_the_scales[370553] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- tip_the_scales[370553] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- font_of_magic[408083] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- interwoven_threads[412713] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Increases haste by $s1% for all party and raid members for $d.; Allies receiving this effect will become Exhausted and unable to benefit from Fury of the Aspects or similar effects again for $57723d.
    fury_of_the_aspects = {
        id = 390386,
        cast = 0.0,
        cooldown = 300.0,
        gcd = "off",

        spend = 0.040,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MELEE_SLOW, 'points': 30.0, 'radius': 50000.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_SCALE, 'points': 30.0, 'radius': 50000.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }
    },

    -- Launch yourself and gain $s2% increased movement speed for $d.; Allows Evoker spells to be cast while moving. Does not affect empowered spells.
    hover = {
        id = 358267,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "off",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DISPEL_RESIST, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_INCREASE_SPEED, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': WATER_WALK, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ANIM_REPLACEMENT_SET, 'value': 1013, 'schools': ['physical', 'fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'amplitude': 1.0, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #7: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_CASTER, }
        -- #8: { 'type': UNKNOWN, 'subtype': NONE, 'trigger_spell': 358268, 'triggers': hover, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': snared, }
        -- #10: { 'type': APPLY_AURA, 'subtype': UNKNOWN, 'points': 56.0, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- aerial_mastery[365933] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- extended_flight[375517] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 4000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- time_spiral[375234] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_TARGET_ALLY, }
    },

    -- Conjure a path of shifting stone towards the target location, rooting enemies for $355689d. Damage may cancel the effect.
    landslide = {
        id = 358385,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "spell",

        spend = 0.028,
        spendType = 'mana',

        talent = "landslide",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 6.0, 'target': TARGET_DEST_DEST, }

        -- Affected by:
        -- forger_of_mountains[375528] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Form a protective barrier of molten rock around an ally, absorbing up to $<shield> damage. While the barrier holds, your ally cannot be interrupted or silenced.
    lava_shield = {
        id = 405295,
        cast = 0.0,
        cooldown = 30.0,
        gcd = "spell",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'sp_bonus': 12.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 10, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': interrupted, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': silenced, }

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Send a flickering flame towards your target, $?c2[healing an ally for $361509s1 or dealing $361500s1 Fire damage to an enemy.][dealing $361500s1 Fire damage to an enemy or healing an ally for $361509s1.]
    living_flame = {
        id = 361469,
        cast = function() return 2.0 * ( buff.ancient_flame.up and 0.6 or 1 ) end,
        cooldown = 0.0,
        gcd = "spell",

        spend = 0.12,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ANY, }

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- enkindled[375554] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- enkindled[375554] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- inner_radiance[386405] #0: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_RECEIVED, 'points': 30.0, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- ancient_flame[375583] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': CAST_TIME, }
        -- ancient_flame[375583] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -40.0, 'target': TARGET_UNIT_CASTER, 'modifies': GLOBAL_COOLDOWN, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Wreathe yourself in arcane energy, preventing the next $s1 full loss of control effects against you. Lasts $d.
    nullifying_shroud = {
        id = 378464,
        cast = 1.5,
        cooldown = 90.0,
        gcd = "spell",

        spend = 0.009,
        spendType = 'mana',

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'mechanic': banished, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': charmed, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': disoriented, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': fleeing, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': frozen, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': horrified, }
        -- #6: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': incapacitated, }
        -- #7: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': polymorphed, }
        -- #8: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': sapped, }
        -- #9: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': asleep, }
        -- #10: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': stunned, }
        -- #11: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 383610, 'triggers': nullifying_shroud, 'target': TARGET_UNIT_CASTER, }
        -- #12: { 'type': APPLY_AURA, 'subtype': MOD_ATTACK_POWER_OF_ARMOR, 'trigger_spell': 383618, 'triggers': nullifying_shroud, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Reinforce your scales, reducing damage taken by $s1%. Lasts $d.
    obsidian_scales = {
        id = 363916,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "off",

        talent = "obsidian_scales",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_TAKEN, 'points': -30.0, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'points': 1.0, 'target': TARGET_UNIT_CASTER, 'mechanic': interrupted, }
        -- #2: { 'type': APPLY_AURA, 'subtype': REDUCE_PUSHBACK, 'points': 100.0, 'value': 3, 'schools': ['physical', 'holy'], 'value1': 15, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_CASTER, 'mechanic': silenced, }

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- obsidian_bulwark[375406] #0: { 'type': APPLY_AURA, 'subtype': MOD_MAX_CHARGES, 'points': 1.0, 'target': TARGET_UNIT_CASTER, }
    },

    -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by $s2% in the next $d.$?s374346[; Removes $s1 Enrage effect from each enemy. Oppressing Roar's cooldown is reduced by $374346s1 sec for each Enrage dispelled.][]
    oppressing_roar = {
        id = 372048,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "spell",

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
        -- spatial_paradox[406732] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- spatial_paradox[406789] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': RADIUS, }
    },

    -- Grant an ally the gift of foresight, increasing their critical strike chance by $410089s1% $?s412774[and occasionally copying their damage and healing spells at $412774s1% power ][]for $410089d.; Affects the nearest ally within $A1 yds, preferring damage dealers, if you do not have an ally targeted.
    prescience = {
        id = 409311,
        cast = 0.0,
        cooldown = 12.0,
        gcd = "spell",

        talent = "prescience",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'attributes': ['Add Target (Dest) Combat Reach to AOE'], 'radius': 26.5, 'target': TARGET_DEST_CASTER, 'target2': TARGET_UNIT_DEST_AREA_ALLY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- spatial_paradox[406732] #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- spatial_paradox[406789] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': RADIUS, }
    },

    -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for $d.
    quell = {
        id = 351338,
        cast = 0.0,
        cooldown = 40.0,
        gcd = "off",

        talent = "quell",
        startsCombat = true,
        interrupt = true,

        -- Effects:
        -- #0: { 'type': INTERRUPT_CAST, 'subtype': NONE, 'mechanic': interrupted, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- imposing_presence[371016] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -20000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
        -- interwoven_threads[412713] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -10.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- The flames of life surround you for $d. While this effect is active, $s1% of damage you take is healed back over $374349d.
    renewing_blaze = {
        id = 374348,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "off",

        talent = "renewing_blaze",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'points': 100.0, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': -10, 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- fire_within[375577] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': -30000.0, 'target': TARGET_UNIT_CASTER, 'modifies': COOLDOWN, }
    },

    -- Swoop to an ally and fly with them to the target location.
    rescue = {
        id = 370665,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "spell",

        talent = "rescue",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DECREASE_SPEED, 'points': -90.0, 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_DEST_DEST, }
    },

    -- Disorient an enemy for $d, causing them to sleep walk towards you. Damage has a chance to awaken them.
    sleep_walk = {
        id = 360806,
        cast = 1.5,
        cooldown = 15.0,
        gcd = "spell",

        spend = 0.024,
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
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Redirect your excess magic to a friendly healer for $d. When you cast an empowered spell, you restore ${$372571s1/100}.2% of their maximum mana per empower level. Limit 1.
    source_of_magic = {
        id = 369459,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        talent = "source_of_magic",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_DAMAGE_PERCENT_DONE, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_DONE_PERCENT, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- potent_mana[418101] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_2_VALUE, }
        -- potent_mana[418101] #1: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 3.0, 'target': TARGET_UNIT_CASTER, 'modifies': EFFECT_3_VALUE, }
    },

    -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by $s4% for $d.; Affects the nearest healer within $407497A1 yds, if you do not have a healer targeted.
    spatial_paradox = {
        id = 406732,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "off",

        talent = "spatial_paradox",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DISPEL_RESIST, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ANIM_REPLACEMENT_SET, 'value': 1013, 'schools': ['physical', 'fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_RANGED_CRIT_CHANCE, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- #7: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #8: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- spatial_paradox[406732] #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- spatial_paradox[406789] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': RANGE, }
    },

    -- Grab an enemy and fly with them to the target location.
    swoop_up = {
        id = 370388,
        cast = 0.0,
        cooldown = 90.0,
        gcd = "spell",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_DEST_DEST, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MOD_ROOT, 'points': 5.0, 'target': TARGET_UNIT_TARGET_ANY, }
    },

    -- Surge forward in time, causing your cooldowns to recover $s1% faster for $d.
    time_skip = {
        id = 404977,
        cast = 0.0,
        cooldown = 180.0,
        gcd = "spell",

        talent = "time_skip",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_RESISTANCE_EXCLUSIVE, 'points': 1000.0, 'value': 1216, 'schools': ['arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': RETAIN_COMBO_POINTS, 'points': 1000.0, 'value': 1948, 'schools': ['fire', 'nature', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': RETAIN_COMBO_POINTS, 'points': 1000.0, 'value': 2100, 'schools': ['fire', 'frost', 'shadow'], 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_RESISTANCE_EXCLUSIVE, 'points': 1000.0, 'value': 1425, 'schools': ['physical', 'frost'], 'target': TARGET_UNIT_CASTER, }
        -- #4: { 'type': APPLY_AURA, 'subtype': MOD_RESISTANCE_EXCLUSIVE, 'points': 1000.0, 'value': 1523, 'schools': ['physical', 'holy', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_RESISTANCE_EXCLUSIVE, 'points': 1000.0, 'value': 1862, 'schools': ['holy', 'fire', 'arcane'], 'target': TARGET_UNIT_CASTER, }

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- tomorrow_today[412723] #0: { 'type': APPLY_AURA, 'subtype': ADD_FLAT_MODIFIER, 'points': 1000.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Bend time, allowing you and your allies within $A1 yds to cast their major movement ability once in the next $375234d, even if it is on cooldown.
    time_spiral = {
        id = 374968,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "spell",

        talent = "time_spiral",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': DUMMY, 'subtype': NONE, 'radius': 40.0, 'target': TARGET_UNIT_CASTER_AREA_RAID, }

        -- Affected by:
        -- spatial_paradox[406732] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- spatial_paradox[406789] #9: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_TARGET_ALLY, 'modifies': RADIUS, }
    },

    -- Freeze an ally's timestream for $d. While frozen in time they are invulnerable, cannot act, and auras do not progress.; You may reactivate Time Stop to end this effect early.
    time_stop = {
        id = 378441,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "off",

        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': STRANGULATE, 'target': TARGET_UNIT_TARGET_RAID, }
        -- #1: { 'type': APPLY_AURA, 'subtype': SCHOOL_IMMUNITY, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MOD_HEALING_PCT, 'points': -100.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }
        -- #3: { 'type': APPLY_AURA, 'subtype': MOD_TIME_RATE, 'points': -100.0, 'target': TARGET_UNIT_TARGET_RAID, }

        -- Affected by:
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406789] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- spatial_paradox[415305] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Enchant an ally to appear out of sync with the normal flow of time, reducing threat they generate by $s1% for $d. Less effective on tank-specialized allies. ; May only be placed on one target at a time.
    timelessness = {
        id = 412710,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        talent = "timelessness",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_THREAT, 'points': -30.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_TARGET_RAID, }

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
    },

    -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    tip_the_scales = {
        id = 370553,
        cast = 0.0,
        cooldown = 120.0,
        gcd = "off",

        talent = "tip_the_scales",
        startsCombat = false,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
    },

    -- Sunder an enemy's protective magic, dealing $s1 Spellfrost damage to absorb shields.
    unravel = {
        id = 368432,
        cast = 0.0,
        cooldown = 9.0,
        gcd = "spell",

        spend = 0.010,
        spendType = 'mana',

        talent = "unravel",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 5.0, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- augmentation_evoker[396186] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- augmentation_evoker[396186] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- ebon_might[395296] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.428, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- ebon_might[395296] #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'pvp_multiplier': 1.428, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
    },

    -- Gather earthen power beneath your enemy's feet and send them hurtling upwards, dealing $396288s2 Volcanic damage to the target and nearby enemies.$?s395153[; Increases the duration of your active Ebon Might effects by ${$395153s2/1000} sec.][]; Empowering expands the area of effect.; I:   $<radiusI> yd radius.; II:  $<radiusII> yd radius.; III: $<radiusIII> yd radius.
    upheaval = {
        id = 396286,
        cast = empowered_cast_time,
        -- channeled = true,
        empowered = true,
        cooldown = 40.0,
        gcd = "spell",

        talent = "upheaval",
        startsCombat = true,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': DUMMY, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- tip_the_scales[370553] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -100.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- tip_the_scales[370553] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- font_of_magic[408083] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': -20.0, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- unyielding_domain[412733] #1: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_MELEE_CRIT_DAMAGE, 'points': 5.0, 'target': TARGET_UNIT_CASTER, }
    },
} )