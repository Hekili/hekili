-- EvokerAugmentation.lua
-- October 2023

if UnitClassBase( "player" ) ~= "EVOKER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 1473 )

local strformat = string.format


-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Essence )

-- Talents
spec:RegisterTalents( {
    -- Evoker
    aerial_mastery        = { 93352, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame         = { 93271, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream  = { 93292, 376930, 2 }, -- Your healing done and healing received are increased by 2%.
    blast_furnace         = { 93309, 375510, 1 }, -- Fire Breath's damage over time lasts 4 sec longer.
    bountiful_bloom       = { 93291, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame     = { 93294, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 18,417 upon removing any effect.
    clobbering_sweep      = { 93296, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 45 sec.
    draconic_legacy       = { 93300, 376166, 1 }, -- Your Stamina is increased by 6%.
    enkindled             = { 93295, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    extended_flight       = { 93349, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance            = { 93299, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    fire_within           = { 93345, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    foci_of_life          = { 93345, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over 4 sec.
    forger_of_mountains   = { 93270, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    heavy_wingbeats       = { 93296, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 45 sec.
    inherent_resistance   = { 93355, 375544, 2 }, -- Magic damage taken reduced by 2%.
    innate_magic          = { 93302, 375520, 2 }, -- Essence regenerates 5% faster.
    instinctive_arcana    = { 93310, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    leaping_flames        = { 93343, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth           = { 93347, 375561, 2 }, -- Green spells restore 5% more health.
    obsidian_bulwark      = { 93289, 375406, 1 }, -- Obsidian Scales has an additional charge.
    oppressing_roar       = { 93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    overawe               = { 93297, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 20 sec for each Enrage dispelled.
    panacea               = { 93348, 387761, 1 }, -- Emerald Blossom instantly heals you for 18,910 when cast.
    permeating_chill      = { 93303, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by 50% for 3 sec.
    potent_mana           = { 93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by 3%.
    protracted_talons     = { 93307, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                 = { 93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall                = { 93301, 371806, 1 }, -- You may reactivate Breath of Eons within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic    = { 93353, 387787, 1 }, -- Your Leech is increased by 3%.
    renewing_blaze        = { 93344, 374348, 1 }, -- The flames of life surround you for 8.5 sec. While this effect is active, 100% of damage you take is healed back over 4 sec.
    rescue                = { 93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    scarlet_adaptation    = { 93340, 372469, 1 }, -- Store 20% of your effective healing, up to 11,630. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk            = { 93293, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic       = { 93354, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 32.0 min. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    tailwind              = { 93290, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    terror_of_the_skies   = { 93342, 371032, 1 }, -- Breath of Eons stuns enemies for 3 sec.
    time_spiral           = { 93351, 374968, 1 }, -- Bend time, allowing you and your allies within 40 yds to cast their major movement ability once in the next 10.7 sec, even if it is on cooldown.
    tip_the_scales        = { 93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian         = { 93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5.3 sec.
    unravel               = { 93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 27,362 Spellfrost damage to absorb shields.
    walloping_blow        = { 93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr                = { 93346, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8.5 sec.

    -- Augmentation
    accretion             = { 93229, 407876, 1 }, -- Eruption reduces the remaining cooldown of Upheaval by 1.0 sec.
    anachronism           = { 93223, 407869, 1 }, -- Prescience has a 35% chance to grant Essence Burst.
    aspects_favor         = { 93217, 407243, 2 }, -- Obsidian Scales activates Black Attunement, and amplifies it to increase maximum health by 12.0% for 12.8 sec. Hover activates Bronze Attunement, and amplifies it to increase movement speed by 25% for 4.3 sec.
    bestow_weyrnstone     = { 93195, 408233, 1 }, -- Conjure a pair of Weyrnstones, one for your target ally and one for yourself. Only one ally may bear your Weyrnstone at a time. A Weyrnstone can be activated by the bearer to transport them to the other Weyrnstone's location, if they are within 100 yds.
    blistering_scales     = { 93209, 360827, 1 }, -- Protect an ally with 15 explosive dragonscales, increasing their Armor by 30% of your own. Melee attacks against the target cause 1 scale to explode, dealing 1,641 Volcanic damage to enemies near them. This damage can only occur every few sec. Blistering Scales can only be placed on one target at a time. Casts on your enemy's target if they have one.
    breath_of_eons        = { 93234, 403631, 1 }, -- Fly to the targeted location, exposing Temporal Wounds on enemies in your path for 10.7 sec. Temporal Wounds accumulate 21% of damage dealt by your allies affected by Ebon Might, then critically strike for that amount as Arcane damage. Applies Ebon Might for 5 sec. Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    chrono_ward           = { 93235, 409676, 1 }, -- When allies deal damage with Temporal Wounds, they gain a shield for 100% of the damage dealt. Absorption cannot exceed 30% of your maximum health.
    defy_fate             = { 93222, 404195, 1 }, -- Fatal attacks are diverted into a nearby timeline, preventing the damage, and your death, in this one. The release of temporal energy restores 79,323 health to you, and 26,441 to 4 nearby allies, over 9 sec. Healing starts high and declines over the duration. May only occur once every 6 min.
    draconic_attunements  = { 93218, 403208, 1 }, -- Learn to attune yourself to the essence of the Black or Bronze Dragonflights: Black Attunement: You and your 4 nearest allies have 4% increased maximum health. Bronze Attunement:You and your 4 nearest allies have 10% increased movement speed.
    dream_of_spring       = { 93359, 414969, 1 }, -- Emerald Blossom no longer has a cooldown, deals 35% increased healing, and increases the duration of your active Ebon Might effects by 1 sec, but costs 3 Essence.
    ebon_might            = { 93198, 395152, 1 }, -- Increase your 4 nearest allies' primary stat by 14% of your own, and cause you to deal 14% more damage, for 10.7 sec. May only affect 4 allies at once, and prefers to imbue damage dealers. Eruption, Breath of Eons, and your empower spells extend the duration of these effects.
    echoing_strike        = { 93221, 410784, 1 }, -- Azure Strike has a 10% chance per target hit to echo, casting again.
    eruption              = { 93200, 395160, 1 }, -- Cause a violent eruption beneath an enemy's feet, dealing 10,944 Volcanic damage split between them and nearby enemies. Increases the duration of your active Ebon Might effects by 1 sec.
    essence_attunement    = { 93219, 375722, 1 }, -- Essence Burst stacks 2 times.
    essence_burst         = { 93220, 396187, 1 }, -- Your Living Flame has a 20% chance, and your Azure Strike has a 15% chance, to make your next Eruption cost no Essence. Stacks 2 times.
    expunge               = { 93306, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    fate_mirror           = { 93367, 412774, 1 }, -- Prescience grants the ally a chance for their spells and abilities to echo their damage or healing, dealing 15% of the amount again.
    font_of_magic         = { 93207, 408083, 1 }, -- Your empower spells' maximum level is increased by 1, and they reach maximum empower level 20% faster.
    geomancy              = { 93360, 410787, 1 }, -- Azure Strike reduces the remaining cooldown of Landslide by 1 sec per target hit.
    hoarded_power         = { 93212, 375796, 1 }, -- Essence Burst has a 20% chance to not be consumed.
    ignition_rush         = { 93230, 408775, 1 }, -- Essence Burst reduces the cast time of Eruption by 40%.
    imposing_presence     = { 93199, 371016, 1 }, -- Quell's cooldown is reduced by 20 sec.
    infernos_blessing     = { 93197, 410261, 1 }, -- Fire Breath grants the inferno's blessing for 8.5 sec to you and your allies affected by Ebon Might, giving their damaging attacks and spells a high chance to deal an additional 4,815 Fire damage.
    inner_radiance        = { 93199, 386405, 1 }, -- Your Living Flame and Emerald Blossom are 30% more effective on yourself.
    interwoven_threads    = { 93369, 412713, 1 }, -- The cooldowns of your spells are reduced by 10%.
    landslide             = { 93305, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 30 sec. Damage may cancel the effect.
    molten_blood          = { 93211, 410643, 1 }, -- When cast, Blistering Scales grants the target a shield that absorbs up to 94,715 damage for 32.0 sec based on their missing health. Lower health targets gain a larger shield.
    momentum_shift        = { 93231, 408004, 1 }, -- Consuming Essence Burst grants you 5% Intellect for 6.4 sec. Stacks up to 2 times.
    motes_of_possibility  = { 93227, 409267, 1 }, -- Essence abilities have a chance to form a mote of diverted time near you. Anyone who comes in contact with the mote gains 10 seconds of reduced cooldown to their major ability.
    natural_convergence   = { 93312, 369913, 1 }, -- Disintegrate channels 20% faster and Eruption's cast time is reduced by 20%.
    obsidian_scales       = { 93304, 363916, 1 }, -- Reinforce your scales, reducing damage taken by 30%. Lasts 12.8 sec.
    overlord              = { 93213, 410260, 1 }, -- Breath of Eons casts an Eruption at the first 3 enemies struck.
    perilous_fate         = { 93235, 410253, 1 }, -- Breath of Eons reduces enemies' movement speed by 70%, and reduces their attack speed by 50%, for 10.7 sec.
    plot_the_future       = { 93226, 407866, 1 }, -- Breath of Eons grants you Fury of the Aspects for 15 sec after you land, without causing Exhaustion.
    power_nexus           = { 93201, 369908, 1 }, -- Increases your maximum Essence to 6.
    prescience            = { 93358, 409311, 1 }, -- Grant an ally the gift of foresight, increasing their critical strike chance by $410089s1% $?s412774[and occasionally copying their damage and healing spells at $412774s1% power ][]for $410089d.; Affects the nearest ally within $s2 yds, preferring damage dealers, if you do not have an ally targeted.    prolong_life          = { 93359, 410687, 1 }, -- Your effects that extend Ebon Might also extend Symbiotic Bloom.
    pupil_of_alexstrasza  = { 93221, 407814, 1 }, -- When cast at an enemy, Living Flame strikes 1 additional enemy for 100% damage.
    reactive_hide         = { 93210, 409329, 1 }, -- Each time Blistering Scales explodes it deals 10% more damage for 12.8 sec, stacking 10 times.
    regenerative_chitin   = { 93211, 406907, 1 }, -- Blistering Scales has 5 more scales, and casting Eruption restores 1 scale.
    ricocheting_pyroclast = { 93208, 406659, 1 }, -- Eruption deals 30% more damage per enemy struck, up to 150%.
    seismic_slam          = { 93205, 408543, 2 }, -- Landslide causes enemies who are mid-air to be slammed to the ground, stunning them for 2 sec.
    spatial_paradox       = { 93225, 406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by 100% for 10.7 sec. Affects the nearest healer within 60 yds, if you do not have a healer targeted.
    stretch_time          = { 93382, 410352, 1 }, -- While flying during Breath of Eons, 50% of damage you would take is instead dealt over 10 sec.
    symbiotic_bloom       = { 93215, 410685, 2 }, -- Emerald Blossom increases targets' healing received by 3% for 10.7 sec.
    tectonic_locus        = { 93202, 408002, 1 }, -- Upheaval deals 50% increased damage to the primary target, and launches them higher.
    time_skip             = { 93232, 404977, 1 }, -- Surge forward in time, causing your cooldowns to recover 1,000% faster for 2 sec.
    timelessness          = { 93368, 412710, 1 }, -- Enchant an ally to appear out of sync with the normal flow of time, reducing threat they generate by 30% for 32.0 min. Less effective on tank-specialized allies. May only be placed on one target at a time.
    tomorrow_today        = { 93369, 412723, 1 }, -- Time Skip channels for 1 sec longer.
    unyielding_domain     = { 93202, 412733, 1 }, -- Upheaval cannot be interrupted, and has an additional 10% chance to critically strike.
    upheaval              = { 93203, 396286, 1 }, -- Gather earthen power beneath your enemy's feet and send them hurtling upwards, dealing 23,531 Volcanic damage to the target and nearby enemies. Increases the duration of your active Ebon Might effects by 2 sec. Empowering expands the area of effect. I: 3 yd radius. II: 6 yd radius. III: 9 yd radius.
    verdant_embrace       = { 93341, 360995, 1 }, -- Fly to an ally and heal them for 31,661, or heal yourself for the same amount.
    volcanism             = { 93206, 406904, 1 }, -- Eruption's Essence cost is reduced by 1.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    born_in_flame        = 5612, -- (414937) Casting Ebon Might grants $s3 charges of Burnout, reducing the cast time of Living Flame by $375802s1%.
    chrono_loop          = 5564, -- (383005) Trap the enemy in a time loop for 5 sec. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below 20%.
    divide_and_conquer   = 5557, -- (384689) Breath of Eons forms curtains of fire, preventing line of sight to enemies outside its walls and burning enemies who walk through them for 39,401 Fire damage. Lasts 6 sec.
    dream_catcher        = 5613, -- (410962) Sleep Walk no longer has a cooldown, but its cast time is increased by 0.2 sec.
    dream_projection     = 5559, -- (377509) Summon a flying projection of yourself that heals allies you pass through for 12,103. Detonating your projection dispels all nearby allies of Magical effects, and heals for 59,908 over 20 sec.
    dreamwalkers_embrace = 5615, -- (415651) Verdant Embrace tethers you to an ally, increasing movement speed by 40% and slowing and siphoning 6,840 life from enemies who come in contact with the tether. The tether lasts up to 10 sec or until you move more than 30 yards away from your ally.
    nullifying_shroud    = 5558, -- (378464) Wreathe yourself in arcane energy, preventing the next 3 full loss of control effects against you. Lasts 30 sec.
    obsidian_mettle      = 5563, -- (378444) While Obsidian Scales is active you gain immunity to interrupt, silence, and pushback effects.
    scouring_flame       = 5561, -- (378438) Fire Breath burns away 1 beneficial Magic effect per empower level from all targets.
    swoop_up             = 5562, -- (370388) Grab an enemy and fly with them to the target location.
    time_stop            = 5619, -- (378441) Freeze an ally's timestream for 5 sec. While frozen in time they are invulnerable, cannot act, and auras do not progress. You may reactivate Time Stop to end this effect early.
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
    -- Maximum health increased by $w1%.
    black_attunement = {
        id = 403264,
        duration = 3600,
        tick_time = 2.0,
        max_stack = 1,
    },
    -- $?$w1>0[Armor increased by $w1.][Armor increased by $w2%.] Melee attacks against you have a chance to cause an explosion of Volcanic damage.
    blistering_scales = {
        id = 360827,
        duration = function() return 600.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = function() return 15 + talent.regenerative_chitin.rank * 5 end,
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    -- Exposing Temporal Wounds on enemies in your path. Immune to crowd control.
    breath_of_eons = {
        id = 403631,
        duration = 6.0,
        max_stack = 1,
    },
    -- Bronze Attunement's grants $w1% additional movement speed.
    bronze_aspects_favor = {
        id = 407244,
        duration = function() return 4.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    bronze_attunement = {
        id = 403265,
        duration = 3600,
        tick_time = 2.0,
        max_stack = 1,
    },
    -- Next Living Flame's cast time is reduced by $w1%.
    burnout = {
        id = 375802,
        duration = 15.0,
        max_stack = 2,
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
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    -- Suffering $w1 Volcanic damage every $t1 sec.
    deep_breath = {
        id = 353759,
        duration = 1.0,
        tick_time = 0.5,
        max_stack = 1,
    },
    -- Healing $w1 every $t1 sec.
    defy_fate = {
        id = 404381,
        duration = 9.0,
        max_stack = 1,
        dot = "buff",
        friendly = true
    },
    -- Suffering $w1 Spellfrost damage every $t1 sec.
    disintegrate = {
        id = 356995,
        duration = function() return 3.0 * ( talent.natural_convergence.enabled and 0.8 or 1 ) * haste end,
        tick_time = function() return ( talent.natural_convergence.enabled and 0.8 or 1 ) * haste end,
        max_stack = 1,
    },
    -- Burning for $s1 every $t1 sec.
    divide_and_conquer = {
        id = 403516,
        duration = 6.0,
        tick_time = 3.0,
        max_stack = 1,
    },
    -- Tethered with an ally, causing enemies who touch the tether to be damaged and slowed.
    dreamwalkers_embrace = {
        id = 415516,
        duration = 10.0,
        tick_time = 0.5,
        max_stack = 1,
        dot = "buff",
        friendly = true
    },
    -- Your Ebon Might is active on allies.; Your damage done is increased by $w1%.
    ebon_might = {
        id = 395296,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    -- Your next Eruption $?s414969[or Emerald Blossom ][]costs no Essence.
    essence_burst = {
        id = 392268,
        duration = function() return 15.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = function() return 1 + ( talent.essence_attunement.enabled and 1 or 0 ) end,
    },
    -- Movement speed increased by $w2%.; Evoker spells may be cast while moving. Does not affect empowered spells.$?e9[; Immune to movement speed reduction effects.][]
    hover = {
        id = 358267,
        duration = function() return ( 6.0 + ( talent.extended_flight.enabled and 4 or 0 ) ) end,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Granted the inferno's blessing by $@auracaster, giving your damaging attacks and spells a high chance to deal additional Fire damage.
    infernos_blessing = {
        id = 410263,
        duration = function() return 8.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    -- Rooted.
    landslide = {
        id = 355689,
        duration = 30.0,
        max_stack = 1,
    },
    -- Absorbing $w1 damage.; Immune to interrupts and silence effects.
    lava_shield = {
        id = 405295,
        duration = function() return 15.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    -- Your next Living Flame will strike $w1 additional $?$w1=1[target][targets].
    leaping_flames = {
        id = 370901,
        duration = function() return 30.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    -- Healing for $w2 every $t2 sec.
    living_flame = {
        id = 361509,
        duration = 12.0,
        max_stack = 1,
        dot = "buff",
        friendly = true
    },
    -- Absorbing $w1 damage.
    molten_blood = {
        id = 410651,
        duration = function() return 30.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    -- Intellect increased by $w1%.
    momentum_shift = {
        id = 408005,
        duration = function() return 6.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        no_ticks = true
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
        max_stack = 3,
    },
    -- Damage taken reduced by $w1%.$?$w2=1[; Immune to interrupt and silence effects.][]
    obsidian_scales = {
        id = 363916,
        duration = function() return 12.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    -- The duration of incoming crowd control effects are increased by $s2%.
    oppressing_roar = {
        id = 372048,
        duration = 10.0,
        max_stack = 1,
    },
    -- Movement speed reduced by $w1%.
    permeating_chill = {
        id = 370898,
        duration = 3.0,
        max_stack = 1,
    },
    -- $?$W1>0[$@auracaster is increasing your critical strike chance by $w1%.][]$?e0&e1[; ][]$?e1[Your abilities have a chance to echo $412774s1% of their damage and healing.][]
    prescience = {
        id = 410089,
        duration = function() return 18.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
        dot = "buff"
    },
    prescience_applied = {
        duration = function() return 18.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    -- Blistering Scales deals $w1% increased damage.
    reactive_hide = {
        id = 410256,
        duration = function() return 12.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    recall = {
        id = 403760,
        duration = 3,
        max_stack = 1
    },
    -- Restoring $w1 health every $t1 sec.
    renewing_blaze = {
        id = 374349,
        duration = function() return ( 8.0 - ( talent.foci_of_life.enabled and 4 or 0 ) ) * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
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
        dot = "buff",
        no_ticks = true,
        friendly = true
    },
    -- Asleep.
    sleep_walk = {
        id = 360806,
        duration = 20.0,
        max_stack = 1,
    },
    -- $@auracaster is restoring mana to you when they cast an empowered spell.$?$w2>0[; Healing and damage done increased by $w2%.][]
    source_of_magic = {
        id = 369459,
        duration = function() return 1800.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
        dot = "buff",
        no_ticks = true,
        friendly = true
    },
    -- Able to cast spells while moving and range increased by $s5%. Cast by $@auracaster.
    spatial_paradox = {
        id = 406789,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        tick_time = 1.0,
        max_stack = 1,
        dot = "buff",
        no_ticks = true,
        friendly = true
    },
    -- $w1% of damage is being delayed and dealt to you over time.
    stretch_time = {
        id = 410355,
        duration = 10.0,
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
        dot = "buff",
        no_ticks = true,
        friendly = true
    },
    -- Accumulating damage from $@auracaster's allies who are affected by Ebon Might.$?$w2<0[; Movement speed reduced by $w2%.; Attack speed reduced by $w3%.][]
    temporal_wound = {
        id = 409560,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        tick_time = 1.0,
        max_stack = 1,
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
        duration = function() return 2.0 + ( talent.tomorrow_today.enabled and 1 or 0 ) end,
        max_stack = 1,
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
    },
    -- Threat generation reduced by $w1%. Cast by $@auracaster.
    timelessness = {
        id = 412710,
        duration = function() return 1800.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
        dot = "buff",
        no_ticks = true,
        friendly = true
    },
    -- Your next empowered spell casts instantly at its maximum empower level.
    tip_the_scales = {
        id = 370553,
        duration = 3600,
        max_stack = 1,
        onRemove = function()
            setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
        end,
    },
    -- Absorbing $w1 damage.
    twin_guardian = {
        id = 370889,
        duration = function() return 5.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
        dot = "buff",
        no_ticks = true,
        friendly = true
    },
    -- Damage taken from area-of-effect attacks reduced by $w1%.; Movement speed increased by $w2%.
    zephyr = {
        id = 374227,
        duration = function() return 8.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
        dot = "buff",
        no_ticks = true,
        friendly = true
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
spec:RegisterGear( "tier31", 207225, 207226, 207227, 207228, 207230 )
spec:RegisterAuras( {
    t31_2pc_proc = {
        duration = 3600,
        max_stack = 1
    },
    t31_2pc_stacks = {
        duration = 3600,
        max_stack = 3
    },
    trembling_earth = {
        id = 424368,
        duration = 3600,
        max_stack = 5
    }
} )


spec:RegisterHook( "reset_precast", function()
    max_empower = talent.font_of_magic.enabled and 4 or 3

    if essence.current < essence.max and lastEssenceTick > 0 then
        local partial = min( 0.95, ( query_time - lastEssenceTick ) * essence.regen )
        gain( partial, "essence" )
        if Hekili.ActiveDebug then Hekili:Debug( "Essence increased to %.2f from passive regen.", partial ) end
    end

    local prescience_remains = action.prescience.lastCast + class.auras.prescience.duration - query_time
    if prescience_remains > 0 then
        applyBuff( "prescience_applied", prescience_remains )
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
    -- Conjure a pair of Weyrnstones, one for your target ally and one for yourself. Only one ally may bear your Weyrnstone at a time.; A Weyrnstone can be activated by the bearer to transport them to the other Weyrnstone's location, if they are within 100 yds.
    bestow_weyrnstone = {
        id = 408233,
        color = "bronze",
        cast = 3.0,
        cooldown = 60.0,
        gcd = "spell",

        talent = "bestow_weyrnstone",
        startsCombat = false,

        usable = function() return not solo, "requires allies" end,

        handler = function()
        end,
    },

    -- Attune to Black magic, granting you and your $403208s2 nearest allies $s1% increased maximum health.
    black_attunement = {
        id = 403264,
        color = "black",
        cast = 0.0,
        cooldown = function() return 3 * ( talent.interwoven_threads.enabled and 0.9 or 1 ) end,
        gcd = "off",

        startsCombat = false,
        disabled = function() return not settings.manage_attunement, "manage_attunement setting not enabled" end,

        function()
            applyBuff( "black_attunement" )
            removeBuff( "bronze_attunement" )
            setCooldown( "bronze_attunement", action.bronze_attunement.cooldown )
        end,
    },

    -- Protect an ally with $n explosive dragonscales, increasing their Armor by $<perc>% of your own.; Melee attacks against the target cause 1 scale to explode, dealing $<dmg> Volcanic damage to enemies near them. This damage can only occur every few sec.; Blistering Scales can only be placed on one target at a time. Casts on your enemy's target if they have one.
    blistering_scales = {
        id = 360827,
        color = "black",
        cast = 0.0,
        charges = function() return talent.regenerative_chitin.enabled and 2 or nil end,
        cooldown = 30.0,
        recharge = function() return talent.regenerative_chitin.enabled and 30 or nil end,
        gcd = "spell",

        talent = "blistering_scales",
        startsCombat = false,

        handler = function()
            applyBuff( "blistering_scales", nil, class.auras.blistering_scales.max_stack )
            if talent.molten_blood.enabled then applyBuff( "molten_blood" ) end
        end
    },

    -- Fly to the targeted location, exposing Temporal Wounds on enemies in your path for $409560d.; Temporal Wounds accumulate $409560s1% of damage dealt by your allies affected by Ebon Might, then critically strike for that amount as Arcane damage.$?s395153[; Applies Ebon Might for ${$395153s3/1000} sec.][]; Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    breath_of_eons = {
        id = 403631,
        color = "bronze",
        cast = 4.0,
        channeled = true,
        cooldown = 120.0,
        gcd = "spell",

        talent = "breath_of_eons",
        startsCombat = false,
        toggle = "cooldowns",

        start = function()
            applyBuff( "breath_of_eons" )
            if buff.ebon_might.up then buff.ebon_might.expires = buff.ebon_might.expires + 5
            else applyBuff( "ebon_might", 5 ) end
        end,

        finish = function()
            removeBuff( "breath_of_eons" )
        end,
    },

    -- Attune to Bronze magic...
    bronze_attunement = {
        id = 403265,
        color = "bronze",
        cast = 0.0,
        cooldown = function() return 3 * ( talent.interwoven_threads.enabled and 0.9 or 1 ) end,
        gcd = "off",

        startsCombat = false,
        disabled = function() return not settings.manage_attunement, "manage_attunement setting not enabled" end,

        function()
            applyBuff( "black_attunement" )
            removeBuff( "bronze_attunement" )
            setCooldown( "black_attunement", action.black_attunement.cooldown )
        end,
    },

    -- Trap the enemy in a time loop for $d. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below $s1%.
    chrono_loop = {
        id = 383005,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "spell",

        spend = 0.020,
        spendType = "mana",

        startsCombat = true,

        handler = function()
            applyDebuff( "target", "time_loop" )
        end
    },

    -- Increase your $i nearest allies' primary stat by $s1% of your own, and cause you to deal $395296s1% more damage, for $d.; May only affect $i allies at once, and prefers to imbue damage dealers.; Eruption, $?s403631[Breath of Eons][Deep Breath], and your empower spells extend the duration of these effects.
    ebon_might = {
        id = 395152,
        color = "black",
        cast = 1.5,
        cooldown = 30.0,
        gcd = "spell",

        spend = 0.010,
        spendType = "mana",

        talent = "ebon_might",
        startsCombat = false,

        handler = function()
            applyBuff( "ebon_might" )
            active_dot.ebon_might = min( group_members, 5 )
            if pvptalent.born_in_flame.enabled then addStack( "burnout", nil, 2 ) end
        end,
    },

    -- Cause a violent eruption beneath an enemy's feet, dealing $s1 Volcanic damage split between them and nearby enemies.$?s395153[; Increases the duration of your active Ebon Might effects by ${$395153s1/1000} sec.][]
    eruption = {
        id = 395160,
        color = "black",
        cast = function() return 2.5 * ( talent.ignition_rush.enabled and buff.essence_burst.up and 0.6 or 1 ) * ( talent.natural_convergence.enabled and 0.8 or 1 ) end,
        cooldown = 0.0,
        gcd = "spell",

        spend = function()
            if buff.essence_burst.up then return 0 end
            return 3 - ( talent.volcanism.enabled and 1 or 0 )
        end,
        spendType = "essence",

        talent = "eruption",
        startsCombat = true,

        handler = function()
            removeBuff( "essence_burst" )
            removeBuff( "trembling_earth" )
            if buff.ebon_might.up then
                buff.ebon_might.expires = buff.ebon_might.expires + 1 + ( set_bonus.tier31_4pc > 0 and ( active_dot.prescience * 0.2 ) or 0 )
            end
            if talent.regenerative_chitin.enabled and buff.blistering_scales.up then addStack( "blistering_scales" ) end
        end
    },

    -- Form a protective barrier of molten rock around an ally, absorbing up to $<shield> damage. While the barrier holds, your ally cannot be interrupted or silenced.
    lava_shield = {
        id = 405295,
        color = "black",
        cast = 0.0,
        cooldown = 30.0,
        gcd = "spell",

        startsCombat = false,
        toggle = "defensives",

        handler = function()
            applyBuff( "lava_shield" )
            active_dot.lava_shield = 1
        end,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'sp_bonus': 12.0, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 10, 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #1: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 26, }
        -- #2: { 'type': APPLY_AURA, 'subtype': MECHANIC_IMMUNITY, 'target': TARGET_UNIT_TARGET_ALLY, 'mechanic': 9, }
        -- #0: { 'type': APPLY_AURA, 'subtype': SCHOOL_ABSORB, 'ap_bonus': 0.075, 'value': 127, 'schools': ['physical', 'holy', 'fire', 'nature', 'frost', 'shadow', 'arcane'], 'value1': 10, 'target': TARGET_UNIT_TARGET_ALLY, }

        -- Affected by:
        -- mastery_timewalker[406380] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'sp_bonus': 0.5, 'target': TARGET_UNIT_CASTER, 'modifies': BUFF_DURATION, }
        -- hover[358267] #4: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- spatial_paradox[406732] #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
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
        spendType = "mana",

        pvptalent = "nullifying_shroud",
        startsCombat = false,
        toggle = "defensives",

        handler = function()
            applyBuff( "nullifying_shroud" )
        end,
    },

    -- Grant an ally the gift of foresight, increasing their critical strike chance by $410089s1% $?s412774[and occasionally copying their damage and healing spells at $412774s1% power ][]for $410089d.; Affects the nearest ally within $s2 yds, preferring damage dealers, if you do not have an ally targeted.
    prescience = {
        id = 409311,
        color = "bronze",
        cast = 0,
        cooldown = 12,
        charges = 2,
        recharge = 12,
        gcd = "spell",

        talent = "prescience",
        startsCombat = false,

        handler = function()
            applyBuff( "prescience_applied" )
            active_dot.prescience = min( group_members, active_dot.prescience + 1 )

            if set_bonus.tier31_4pc > 0 then addStack( "trembling_earth" ) end
        end,
    },

    -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by $s4% for $d.; Affects the nearest healer within $407497A1 yds, if you do not have a healer targeted.
    spatial_paradox = {
        id = 406732,
        color = "bronze",
        cast = 0.0,
        cooldown = 120.0,
        gcd = "off",
        icd = 0.5,

        talent = "spatial_paradox",
        startsCombat = false,
        toggle = "interrupts", -- Utility CD...

        handler = function()
            applyBuff( "spatial_paradox" )
            if not solo then active_dot.spatial_paradox = 2 end
        end
    },

    -- Surge forward in time, causing your cooldowns to recover $s1% faster for $d.
    time_skip = {
        id = 404977,
        color = "bronze",
        cast = function() return 2.0 + ( talent.tomorrow_today.enabled and 1 or 0 ) end,
        channeled = true,
        cooldown = 180.0,
        gcd = "spell",

        talent = "time_skip",
        notalent = "interwoven_threads",
        startsCombat = false,
        toggle = "cooldowns",

        start = function()
            applyBuff( "time_skip" )
        end,

        finish = function()
            removeBuff( "time_skip" )
        end,
    },

    -- Enchant an ally to appear out of sync with the normal flow of time, reducing threat they generate by $s1% for $d. Less effective on tank-specialized allies. ; May only be placed on one target at a time.
    timelessness = {
        id = 412710,
        color = "bronze",
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        talent = "timelessness",
        startsCombat = false,

        handler = function()
            applyBuff( "timelessness" )
            active_dot.timelessness = 1
        end,
    },

    -- Gather earthen power beneath your enemy's feet and send them hurtling upwards, dealing $396288s2 Volcanic damage to the target and nearby enemies.$?s395153[; Increases the duration of your active Ebon Might effects by ${$395153s2/1000} sec.][]; Empowering expands the area of effect.; I:   $<radiusI> yd radius.; II:  $<radiusII> yd radius.; III: $<radiusIII> yd radius.
    upheaval = {
        id = function() return talent.font_of_magic.enabled and 408092 or 396286 end,
        color = "black",
        cast = empowered_cast_time,
        empowered = true,
        cooldown = 40.0,
        gcd = "spell",

        talent = "upheaval",
        startsCombat = true,

        handler = function()
            if buff.ebon_might.up then buff.ebon_might.expires = buff.ebon_might.expires + 2 end
        end,

        copy = { 396286, 408092 }
    },
} )


spec:RegisterSetting( "use_unravel", false, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( 368432 ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended if your target has an absorb shield applied.  By default, your Interrupts toggle must also be active.",
    Hekili:GetSpellLinkWithTexture( 368432 ) ),
    width = "full",
} )

spec:RegisterSetting( "use_hover", nil, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( 358267 ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended.  In the default priority, this occurs when you are moving and you have charges available.", Hekili:GetSpellLinkWithTexture( 358267 ) ),
    get = function()
        return not Hekili.DB.profile.specs[ 1473 ].abilities.hover.disabled
    end,
    set = function()
        Hekili.DB.profile.specs[ 1473 ].abilities.hover.disabled = not Hekili.DB.profile.specs[ 1473 ].abilities.hover.disabled
    end,
} )

spec:RegisterSetting( "use_verdant_embrace", false, {
    name = strformat( "Use %s with %s", Hekili:GetSpellLinkWithTexture( 360995 ), Hekili:GetSpellLinkWithTexture( spec.talents.ancient_flame[2] ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended to cause %s.", Hekili:GetSpellLinkWithTexture( 360995 ), spec.auras.ancient_flame.name ),
    width = "full"
} )

--[[ spec:RegisterSetting( "skip_boe", false, {
    name = strformat( "%s: Skip %s", Hekili:GetSpellLinkWithTexture( spec.abilities.time_skip.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.breath_of_eons.id ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended without %s on cooldown.  This setting will waste cooldown recovery, but may be useful to you.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.time_skip.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.breath_of_eons.id ) ),
    width = "full",
} ) ]]

spec:RegisterSetting( "manage_attunement", false, {
    name = strformat( "Manage %s", Hekili:GetSpellLinkWithTexture( spec.talents.draconic_attunements[2] ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended when out-of-combat, resuming %s if no one else is supplying the aura or otherwise switching to %s.\n\n"
        .. "This option can be distracting as some abilities can swap your attunement in combat.", Hekili:GetSpellLinkWithTexture( spec.talents.draconic_attunements[2] ),
        spec.abilities.black_attunement.name, spec.abilities.bronze_attunement.name ),
    width = "full"
} )

spec:RegisterSetting( "manage_source_of_magic", false, {
    name = strformat( "Manage %s", Hekili:GetSpellLinkWithTexture( spec.talents.source_of_magic[2] ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended when out-of-combat when you are in a group and none of your allies appear to have your aura applied.\n\n"
        .. "This option can be distracting because some groups may not have a healer.", Hekili:GetSpellLinkWithTexture( spec.talents.source_of_magic[2] ) ),
    width = "full"
} )

--[[ spec:RegisterSetting( "upheaval_rank_1", true, {
    name = strformat( "%s: Rank 1 Only", Hekili:GetSpellLinkWithTexture( spec.abilities.upheaval.id ) ),
    type = "toggle",
    desc = strformat( "If checked, %s will only be recommended at Rank 1, which is the default.\n\n"
        .. "Otherwise, %s may be recommended at higher ranks when more targets are detected which can help ensure they are caught in its radius.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.upheaval.id ), spec.abilities.upheaval.name ),
    width = "full",
} ) ]]

spec:RegisterSetting( "use_early_chain", false, {
    name = strformat( "%s: Chain Channel", Hekili:GetSpellLinkWithTexture( 356995 ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended while already channeling it, extending the channel.",
        Hekili:GetSpellLinkWithTexture( 356995 ) ),
    width = "full"
} )

spec:RegisterSetting( "use_clipping", false, {
    name = strformat( "%s: Clip Channel", Hekili:GetSpellLinkWithTexture( 356995 ) ),
    type = "toggle",
    desc = strformat( "If checked, other abilities may be recommended during %s, breaking its channel.", Hekili:GetSpellLinkWithTexture( 356995 ) ),
    width = "full",
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    gcdSync = false,

    nameplates = false,
    nameplateRange = 35,

    damage = true,
    damageDots = true,
    damageOnScreen = true,
    damageExpiration = 8,

    package = "Augmentation",
} )

spec:RegisterPack( "Augmentation", 20231114.3, [[Hekili:T31EZTTns8pl(pkTutSIiLTtspl1PjTDAYK25Mt5U7)efLiKnptrYYhwXz0Op73ca(aaeae0woPtFC5sCib29hwSVWcqKf2l(4I5(E5Of)MZyNj222NpY(LJhp(vlMNFFcAX8eV136Dn8drEBHF)hkUElkk3lpioc)Y7dJ98XejlUiDn0GBYZtY(Ux8ID72nky99NDhkikB064TVyx8Ux4X09Zq3fFlk9SK7qN5NKDwAC5Zxhhh6hVlk7mVvbHb5bOSfZxveeM)UOfRKJ3xciibTEXVzF(lNaOiW3hrBmkB9I54gFMT9z2N)Dhw(RX3HoSmp(WY5bBF7HLjPbXPb53p6W7p8(6wAdT8WY)zk0)au06YE4DxCG)HLR9sscIUg(7jjHa(OVmjfbd0vE5WZHhTdfgYrZXVMqZ)DYniV78cpSm1l62dlTpSmobpYHUbW2)FCy5hcUJq(FoeK6hwwKbtbhwEdMQRVXl6AKpMWlp7WY3s(R8aTS5YWBCuiZ4C8RpZ5ccM(q8UZqBtI3HsbUgKcD)nPiV8BGUSEDrkE4Cdcq4hqEjnqdECa8)JIHHCUxim1srwn5hFjH8)l0wIqpobfH5GW4BTxwEPm0lm4AGn7cWS()gdm1dW)1fb(igc)k4xectNl)yqc07BGFA(AafaPkGhee1m3ceoYxG6SdtgA)YZSPG(J7qE3YoDfgFDWAkmd2MKsy9MyyshGpcOEworUFx2iGtRZlW9P8z7UjierM8sVgg5a7oddEmaOYnaZBG(apXhJCQ6KOEjgB05RF(nVOfUWZeaCoS8zFmalvNFBqYZbLK3bZkP7a0cJ8pEdmC9ZAueW6q)uuwbgjEIt9LAeiF6uempGianiki7gUz6xsnToS8h895PsBCsWyeyOlfyydD)mEspPH0Zj(za8VbKFEe6XA2Hnhx7rnMc2q1b8WgAb1wm)yC0PqtjDcCgb08xaiaqAl2srM6Gtf7XcIgzBLEuTHcWVFkokRYCUIH)CWNK1O1Xr(buKoyLxgM24F(NwH)9Fn46Baq(2FCyfv(b))xbEk4nHbG2wkX8PwBVXGFf8NWZYWdq)IiFVOCoCWpbtmkAMG269PsD0kVi8ccQpX3fbWg3CWiiev7ph4DZO4DGR))d21)PvgVlMJbEgowXMGWquk8t)gj(dkYBviYFXBwmFnOVdJnVfZhG1e2SzKxe2RwU7gSNIryZ697XancMvNn9WsNX4)J(0tQmMg5dJVTUXBCZsWsQrLSG2S78aoa)1rzjqJGXomuakbez4HLwWSbX6n4oKl4SAlX7(uIxACNlzqsrsqiMbWF9tz5PEzF2RHldxmhtbCiYqINok8xKdHTWJ4Qx69zWUZf6EWTiw5qo8)Mt9v6QwyfNab9q5nKRAGH)PWcuZdgvslFuOh4kC23Zie2cgZBlaHfttyNioHPTLTzTFg0UC0AWRhHjU0Kd4ir1y9yayq51whJM0Bgz)4gICVgaW59gaQhPoSqd97fbjjGR2O73wGYClIs9UdfIvPYG4W(4GkwyFj0uMu3mW0rNe8cHbqfUvspwqwZ9ve3kyZce4IBukARxa2v3vG9ZKQuivtsahxQ0HWJYKuT94ln2E0hTXRimV2sSQt)EbKNhFRBP53mmaTICaazJkYqvYGgAv9GkD6QNV2Ra3)p3aDE(jQ)PGF3qd0bkmq6yKiiwLUzjVzeEsS5zcZM4x2GishKP50TQVpIq(CC2fPEHU7IH4uvklSkP4wqFREvJnfHHUq8CsGl3CsaASk31R9hrcP9TG6hvxPulYpg0xyYyM6(N1qcbHHD3IJcZRgZsZZBgKneRwPsBynzK)mAwwLdGHu(j2A)I0YOTaagp6C6WsjnXHiPyK91mSb37S4W4MHst7WdLxPCOOk4sLOe8Q2T3Rg2Mwe5s)zxCIc00f49wvgkeq1RvIk5kx48gSAlMW(eRNbJj)jqC7X)bXzOTye)kGeKczuvK5Uj1JSEAZeaefLyCQHw4C4bbGlpOgRuirbBl2IXOORUAFPWkeYWJEyDzUOTRqPzXfHFHqQcMJXRyUcv4DBqAACkUpWWdw8gK(SBE82y4P7Y(cbB9yaJErh9vOFfe0BdKAV7QuiJ5B(cHxrUIrOQmjYsIdcjZjrOWCWvDbNuLWejTXDlEX1P3xzcpG4yza5xqC6OBr5JYThfKnsu7Sm5aU2OvaxL)ptxQnMRexSC1XaU60FU6WZ1HLuK4T(BGKECgtCY6mw)eyvtVcA6fKLKqNZKnpGN3edVwRzH8GvQc4LylTcDpSSvirfiBI4nBCHWH40HQ0hK22MjzCWZMqt44x2vtQ05vTEVBnPxlN4c350SAW6quLDY12f9P1Hf(iM16jtWBmbD4i4qHfykHTwMqKA9CCDlCr3HtV1Z3pBe6tbKkLH5I47QurZsG8rDZX5cLNns2ucDyDHCYGRycm1C546HJsxeyrdr3rmFNgDNqqjh(Tmc3ZkIw7rcHRu)rv7)BDO)SRdjMOzLou5auCb7Dnl3zAyZkdWz2SILkDHTErfEqAnzHX5mGfpIetsvye58LEe1sXv(Ww6iYHSQwXeJvzvkSoPXJUKzjUGLp0RTzTCcG5G6ccwp8XrcDZUniPs2uU()MNxxhol2AcguxTzqnMuS52vha7Ur5Qq2SIarvj8wuwgvGk3Voevz9qCVvwiDWesO0t0grXoyF5hGiwomlq7zy5NJ0eXyDdY0dlgDLNaHfwgiMen3cC7Cn0kw0Az2oeqkvQyFb5Tk82u(2bgUYtkgmOWzCQ12DK11vutWU96nzmtysodASoxeYfSjMBdrwXIB1L3HiddP7jhTYqzvZ01dTYm0j7Rb7kEBvAAXu35MvfL6SkF2tQ96OkAZW(zKPkB0)izKDmek4XQ2QfjDwSMnpJPbvIg5VTPavJKvUSHLHpUGjmvLlccivxhOU2YLAzAwgM9URksZYzIRPy7yCeYdI)T2v(RuSjr1jajZjdMULOzKpSa21b5vLaSXVehAZY9wFlPnsEjeMZTSbwD49BgX5hJTaAlcI177UcY5nlElruRU4w60nrFcTUihXuwVVEdrMXxArsvD1MOj9H04Ie3T0k1qTEQMG9AQy7Q6T(0nRCNpLyWYxN6w9HGe1PzCICvMMiN86ASA5LnaytAiKjLNVxcDNrveJvNfJAnBl57oPwvQjgUFe3HsXBymUIzPERrCi5PuGOEOoWibgwLU9wcp0aHLWiMiSuvHqDvOUU005K9cGEEewOytBbxXQ2GKQT(O2BxZ(onNMH8dJEY3L3Astwcw)3f176XMi3DILA2EYhX(RkdAKqJs3)cjb2Eyiw22IzW8K0TFMFAsm1OULf9VoPcf2vwtKxIDzTSJuW7vfAB3bP1vMzpefx87cj7pxpeHgx0x9IqhJfHo9reAs5MB3bdfHoSIqX8b7Hi8ViAHshrsRKMS2PQqOY0SlRyJK9fThZk)frXw6iQ7zfN(oR4WmR0AdLfYOFf(a7Hh7LsSvPXrFg1krwznAHSTjwiVA20GWPrtpQ2y6SLEakXRlGzJ64F9czBYBRbaS0axV88IiY5bSf05F9cz7dRijjdprA2KWFlwwoopr17H8aqSLCrG8lKT7QTgMcRLOArtxrlmKvxRwHxqlBPj5KkGO9KrQOIaE(3lD5qSv8jpiHQ5wVsivfZKH2TlSsRkV0aoHcDHxi3LDwwLMZ0IfBL7OMSWZZCjLmcSpxFJxCMSCv7e3o9g3DxoOhaUvT)9kX9K(I7x9uaBvBQVsyFEFH95SRyCtmSKSkhqClwu35NIBOvxLdEDEAXHKLgDNdPh4mXXbXv(2mB6s1(X(1Z6WyORABa)65qYuOtCEFhKQdgVnFEsGODNxAeUgllM)r83OsaEd(Yl)oioLw5GtXNxFGlKV1ISyCj88kGCB8iFyj0V5h8hfXhGOyWq47oS8TXraZiV(u51hbOj(lcqXBRmRGwnW(td7I2YoDTcmq3bWTHlhEVeHa3b8RFYIZfXBzkBQ3qhMkMxncmyBGGgxZZl)AiJkRcq)KoKpxizIhPlcRgSAxQwlngT8qBs7YzyxDXuUlzIMHr8V94tZUPM0LC1IQQALziU7fojNHD1ft5Uo5L4Bp(0uj1ahoux8z0VrStjHd0F(dTgCYGb6nn2VVhAYdTKR5SF)a9t(mCP75kgUWjBgcujyl6B(gBNXZCgVFpEZQT4cxsE3voxmSsk)xwHKgzuLiQrvRv0H2opk7SopinnH3S44s9UPB7t0MoBU(I6hg1BO7lpQsdruFCPE309Hjnmf1pmQxtxhfzgwFobes1P1rmseOQiy7nCrGYQ3rMwSW5yJzfe8yI5jp8mAfMxniT22tZV6jCXftumLZT3VcKw6(lBkHBV3Zcux9MtBkloocgf6vpEbJccFmfmkyXJuWiDrq17T(P9AzqTmPo6wTTwg6rNdQd8BYQimALCAzHW((iNdTBK5mq(UgjNpkBR5StPpr5CuxZnNPDTSkjmURUyoZLK5UCwkVHCmsDsgMOnA0AA1YIU0gv0iZzGHAJ6BR5SZCTXoBU5mTlvljmURUyoZnrButd5yuRCwo((g1YIU0gnX3OwgyO2yp8nQLDMRn2zZnNPDPA9y9nQL5MOnAQVr9QksoSbk0xK3Y(Wk5NxbvStzR5y5RF698RLfDzRzINFTmWqBTE45xl7m3wRZMBot7YW5X65xlZnXwZup)6vvmXwtxl7dRm0wRRwRB1pBwDAVw2tRsOtxZb32RFk)6rKU17SW6DeeHj3fvxTihwsUAVGxJp8ZXBcAUxpYgvVITNn9fvN(SNJpRutRpJZpVCRTMA)84KPKtj7H33D)LDYERjqnnhBcP4ib5KXnv7bi(5bBMEIYvW9uWXNj94kJXXXagSN34hOiSubV5G2woQ4IiPUi9YYqs4TY91k0iLUhfANwVzcTv2XiShsehfsKo22czXXeEBxse9bmeANHsevoM7JeP6iR(NAverGljctRMipQqFeToYfT)5sxte4AfTAd4kx0Us6zTf7STRZRRC6jCKAXeICYCT8uEQCv50v8CTYakjNbxf0q8WV2qePN6wlvN4wRtuFwBvbFHZ8kd(LE4AVYEmRuQvRWYPAwbmGCB8X(GsDrmFKD37X20w3YESVKCH31IkKNArVn9OIPMBsVsXwARBrpwYkyfxFJ3vA)Q9UYJLonFFVym2(t89QPL3idF7K97zeOn9B6yR69lQ95IRP)NZY2MgIz7afhQUZQ)WPhE1uX2uDy7(2XJoF)Efuy2ukpLEl2TFp(gSJfwcFQEC56qpKzy4knLQzJToXGBpawrp5MJdtqvxHhwTpu2CQOLxjguyQKNyoupdj)sa5QPtutyr3)6qSSJ6aq8X9AKipKXtoB1gC5jN7crrFY5NKWJ1(u7Xr1XKCVm8i0O6C6ysoigYIh8jzsZ8MKKiEoZnudS4uCy7M75MzJhzBnyWjkn6zfUI7q)SPyGEsThOMmJlxRWqRbsgSD076vAmeKjQPTLUocAfYVUk2VV9Tff45TZBkQztVODxdIMD54HsnaCgRBssEAC)9e1FCMOW3BuvR7GmvOrW3r4SzGZq9IplzZm0va1j4CEAaNToW5ObCz61IRtaB8Ol5ZAL)60HAPSzfx6cS3duwIh2jldkLfgNLxWmpN77TaaAZNJbf1TVVDMvNR2ZgpYPv8TQHyDRSoQaNF(JKOQ2mDLKgkeLXsYWY(cljgmWthyqoKnH(m)KDnBQT0aCxnrHr6KXpV86KAQT9lzLkSx)t1zm06QKQzMG)AKYunWbkUIKMzdRdrHdSHFT06E0GTwZKxjtYD30ZysGH)EBQ5nAVZMgc(FUGBPy837lmLgw4OwvkieUoMSgu7SQUW8tDyIo18u7Y19lEJTaHKAB3SFVW9q00XvMxTV)HMk5f139q6wE6SZ5MhQU2HQ1RL0d2lmPVuGKZRuRsHWPHxxKOQRfPzGyNzH7T6El9BXsnirb5K2ZxwYoDHwkpuG1UGfvYKRIuvlNYRJNP2C1cH)Y4PvXweEV1Xa9Yr5afJQ97XxZq4S6W)3qTJgP1GGw8bMswnIRQeTkiKUTjIRQfFF37xLyhz30NJnEoZUNuKBhOOe2(lpQjPe2DKBREe4Mjuzlu(0u4NwSrmsVOwlKicvBx2xNOAYY(VwkSA0BwrIeY(rmZncADVfOREhuQX0f(4(Ijfa8Hl)Nz2xQmUFvHhT6(Z71m44yaCuNgYrhot6goV6lhAoVB0CULSdHq7KkeXyzO6wF38dndzgjNE4GGTCYpor4rs)6OHNJK5Nr4HbrQCRnqASC(q2qA8QISljrxic)GE5SCOeyY)pQuEf53eNUy(CpuiiboSCq9)u5n8FCyjqMOSq6P5z19hw(lOBdcdi3Tal()p]] )