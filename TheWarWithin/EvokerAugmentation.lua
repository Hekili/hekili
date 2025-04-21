-- EvokerAugmentation.lua
-- January 2025

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
    aerial_mastery                  = {  93352, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame                   = {  93271, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream            = {  93292, 376930, 2 }, -- Your healing done and healing received are increased by 2%.
    blast_furnace                   = {  93309, 375510, 1 }, -- Fire Breath's damage over time lasts 4 sec longer.
    bountiful_bloom                 = {  93291, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame               = {  93294, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 65,292 upon removing any effect.
    clobbering_sweep                = { 103844, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 2 min.
    draconic_legacy                 = {  93300, 376166, 1 }, -- Your Stamina is increased by 6%.
    enkindled                       = {  93295, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    expunge                         = {  93306, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    extended_flight                 = {  93349, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance                      = {  93299, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    fire_within                     = {  93345, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    foci_of_life                    = {  93345, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over 4 sec.
    forger_of_mountains             = {  93270, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    heavy_wingbeats                 = { 103843, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 2 min.
    inherent_resistance             = {  93355, 375544, 2 }, -- Magic damage taken reduced by 2%.
    innate_magic                    = {  93302, 375520, 2 }, -- Essence regenerates 5% faster.
    instinctive_arcana              = {  93310, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    landslide                       = {  93305, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 15 sec. Damage may cancel the effect.
    leaping_flames                  = {  93343, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth                     = {  93347, 375561, 2 }, -- Green spells restore 5% more health.
    natural_convergence             = {  93312, 369913, 1 }, -- Disintegrate channels 20% faster and Eruption's cast time is reduced by 20%.
    obsidian_bulwark                = {  93289, 375406, 1 }, -- Obsidian Scales has an additional charge.
    obsidian_scales                 = {  93304, 363916, 1 }, -- Reinforce your scales, reducing damage taken by 30%. Lasts 13.5 sec.
    oppressing_roar                 = {  93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    overawe                         = {  93297, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 30 sec.
    panacea                         = {  93348, 387761, 1 }, -- Emerald Blossom and Verdant Embrace instantly heal you for 29,148 when cast.
    potent_mana                     = {  93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by 3%.
    protracted_talons               = {  93307, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                           = {  93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall                          = {  93301, 371806, 1 }, -- You may reactivate Breath of Eons within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic              = {  93353, 387787, 1 }, -- Your Leech is increased by 2%.
    renewing_blaze                  = {  93354, 374348, 1 }, -- The flames of life surround you for 9.0 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    rescue                          = {  93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location. Clears movement impairing effects from you and your ally.
    scarlet_adaptation              = {  93340, 372469, 1 }, -- Store 20% of your effective healing, up to 40,315. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk                      = {  93293, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic                 = {  93344, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 1.1 |4hour:hrs;. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    spatial_paradox                 = {  93351, 406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by 100% for 11.2 sec. Affects the nearest healer within 60 yds, if you do not have a healer targeted.
    tailwind                        = {  93290, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    terror_of_the_skies             = {  93342, 371032, 1 }, -- Breath of Eons stuns enemies for 3 sec.
    time_spiral                     = {  93351, 374968, 1 }, -- Bend time, allowing you and your allies within 40 yds to cast their major movement ability once in the next 11.2 sec, even if it is on cooldown.
    tip_the_scales                  = {  93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian                   = {  93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5.6 sec.
    unravel                         = {  93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 174,613 Spellfrost damage to absorb shields.
    verdant_embrace                 = {  93341, 360995, 1 }, -- Fly to an ally and heal them for 116,966, or heal yourself for the same amount.
    walloping_blow                  = {  93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr                          = {  93346, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 9.0 sec.

    -- Augmentation
    accretion                       = {  93229, 407876, 1 }, -- Eruption reduces the remaining cooldown of Upheaval by 1.0 sec.
    anachronism                     = {  93223, 407869, 1 }, -- Prescience has a 35% chance to grant Essence Burst.
    arcane_reach                    = {  93225, 454983, 1 }, -- The range of your helpful magics is increased by 5 yards.
    aspects_favor                   = {  93217, 407243, 2 }, -- Obsidian Scales activates Black Attunement, and amplifies it to increase maximum health by 4.0% for 13.5 sec. Hover activates Bronze Attunement, and amplifies it to increase movement speed by 25% for 4.5 sec.
    bestow_weyrnstone               = {  93195, 408233, 1 }, -- Conjure a pair of Weyrnstones, one for your target ally and one for yourself. Only one ally may bear your Weyrnstone at a time. A Weyrnstone can be activated by the bearer to transport them to the other Weyrnstone's location, if they are within 100 yds.
    blistering_scales               = {  93209, 360827, 1 }, -- Protect an ally with 20 explosive dragonscales, increasing their Armor by 20% of your own. Melee attacks against the target cause 1 scale to explode, dealing 5,820 Volcanic damage to enemies near them. This damage can only occur every few sec. Blistering Scales can only be placed on one target at a time. Casts on your enemy's target if they have one.
    breath_of_eons                  = {  93234, 403631, 1 }, -- Fly to the targeted location, exposing Temporal Wounds on enemies in your path for 11.2 sec. Temporal Wounds accumulate 12% of damage dealt by your allies affected by Ebon Might, then critically strike for that amount as Arcane damage. Applies Ebon Might for 5 sec. Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    chrono_ward                     = {  93235, 409676, 1 }, -- When allies deal damage with Temporal Wounds, they gain a shield for 100% of the damage dealt. Absorption cannot exceed 30% of your maximum health.
    defy_fate                       = {  93222, 404195, 1 }, -- Fatal attacks are diverted into a nearby timeline, preventing the damage, and your death, in this one. The release of temporal energy restores 241,416 health to you, and 80,472 to 4 nearby allies, over 9 sec. Healing starts high and declines over the duration. May only occur once every 6 min.
    draconic_attunements            = {  93218, 403208, 1 }, -- Learn to attune yourself to the essence of the Black or Bronze Dragonflights: Black Attunement: You and your 4 nearest allies have 2% increased maximum health. Bronze Attunement:You and your 4 nearest allies have 10% increased movement speed.
    dream_of_spring                 = {  93359, 414969, 1 }, -- Emerald Blossom no longer has a cooldown, deals 35% increased healing, and increases the duration of your active Ebon Might effects by 1 sec, but costs 3 Essence.
    ebon_might                      = {  93198, 395152, 1 }, -- Increase your 4 nearest allies' primary stat by 5.0% of your own, and cause you to deal 25% more damage, for 11.2 sec. May only affect 4 allies at once, and does not affect tanks and healers. Eruption, Breath of Eons, and your empower spells extend the duration of these effects.
    echoing_strike                  = {  93221, 410784, 1 }, -- Azure Strike deals 15% increased damage and has a 10% chance per target hit to echo, casting again.
    eruption                        = {  93200, 395160, 1 }, -- Cause a violent eruption beneath an enemy's feet, dealing 54,324 Volcanic damage split between them and nearby enemies. Increases the duration of your active Ebon Might effects by 1 sec.
    essence_attunement              = {  93219, 375722, 1 }, -- Essence Burst stacks 2 times.
    essence_burst                   = {  93220, 396187, 1 }, -- Your Living Flame has a 20% chance, and your Azure Strike has a 15% chance, to make your next Eruption cost no Essence. Stacks 2 times.
    fate_mirror                     = {  93367, 412774, 1 }, -- Prescience grants the ally a chance for their spells and abilities to echo their damage or healing, dealing 15% of the amount again.
    font_of_magic                   = {  93231, 408083, 1 }, -- Your empower spells' maximum level is increased by 1, and they reach maximum empower level 20% faster.
    hoarded_power                   = {  93212, 375796, 1 }, -- Essence Burst has a 20% chance to not be consumed.
    ignition_rush                   = {  93230, 408775, 1 }, -- Essence Burst reduces the cast time of Eruption by 40%.
    imminent_destruction            = { 102248, 459537, 1 }, -- Breath of Eons reduces the Essence cost of Eruption by 1 and increases its damage by 10% for 15 sec after you land.
    imposing_presence               = {  93199, 371016, 1 }, -- Quell's cooldown is reduced by 20 sec.
    infernos_blessing               = {  93197, 410261, 1 }, -- Fire Breath grants the inferno's blessing for 9.0 sec to you and your allies affected by Ebon Might, giving their damaging attacks and spells a high chance to deal an additional 17,073 Fire damage.
    inner_radiance                  = {  93199, 386405, 1 }, -- Your Living Flame and Emerald Blossom are 30% more effective on yourself.
    interwoven_threads              = {  93369, 412713, 1 }, -- The cooldowns of your spells are reduced by 10%.
    molten_blood                    = {  93211, 410643, 1 }, -- When cast, Blistering Scales grants the target a shield that absorbs up to 167,897 damage for 33.7 sec based on their missing health. Lower health targets gain a larger shield.
    molten_embers                   = { 102249, 459725, 1 }, -- Fire Breath causes enemies to take up to 40% increased damage from your Black spells, increased based on its empower level.
    momentum_shift                  = {  93207, 408004, 1 }, -- Consuming Essence Burst grants you 5% Intellect for 6.7 sec. Stacks up to 2 times.
    motes_of_possibility            = {  93227, 409267, 1 }, -- Eruption has a 25% chance to form a mote of diverted essence near you. Allies who comes in contact with the mote gain a random buff from your arsenal.
    overlord                        = {  93213, 410260, 1 }, -- Breath of Eons casts an Eruption at the first 3 enemies struck. These Eruptions have a 100% chance to create a Mote of Possibility.
    perilous_fate                   = {  93235, 410253, 1 }, -- Breath of Eons reduces enemies' movement speed by 70%, and reduces their attack speed by 50%, for 11.2 sec.
    plot_the_future                 = {  93226, 407866, 1 }, -- Breath of Eons grants you Fury of the Aspects for 15 sec after you land, without causing Exhaustion.
    power_nexus                     = {  93201, 369908, 1 }, -- Increases your maximum Essence to 6.
    prescience                      = {  93358, 409311, 1 }, -- Grant an ally the gift of foresight, increasing their critical strike chance by 3% and occasionally copying their damage and healing spells at 15% power for 20.2 sec. Affects the nearest ally within 25 yds, preferring damage dealers, if you do not have an ally targeted.
    prolong_life                    = {  93359, 410687, 1 }, -- Your effects that extend Ebon Might also extend Symbiotic Bloom.
    pupil_of_alexstrasza            = {  93221, 407814, 1 }, -- When cast at an enemy, Living Flame strikes 1 additional enemy for 100% damage.
    reactive_hide                   = {  93210, 409329, 1 }, -- Each time Blistering Scales explodes it deals 15% more damage for 13.5 sec, stacking 10 times.
    regenerative_chitin             = {  93211, 406907, 1 }, -- Blistering Scales has 5 more scales, and casting Eruption restores 1 scale.
    ricocheting_pyroclast           = {  93208, 406659, 1 }, -- Eruption deals 30% more damage per enemy struck, up to 150%.
    rockfall                        = {  93368, 1219236, 1 }, -- Upheaval reaches maximum empower level 20% faster and has a 60% chance to grant Essence Burst.
    rumbling_earth                  = {  93205, 459120, 1 }, -- Upheaval causes an aftershock at its location, dealing 50% of its damage 2 additional times.
    stretch_time                    = {  93382, 410352, 1 }, -- While flying during Breath of Eons, 50% of damage you would take is instead dealt over 10 sec.
    symbiotic_bloom                 = {  93215, 410685, 2 }, -- Emerald Blossom increases targets' healing received by 3% for 11.2 sec.
    tectonic_locus                  = {  93202, 408002, 1 }, -- Upheaval deals 50% increased damage to the primary target, and launches them higher.
    time_skip                       = {  93232, 404977, 1 }, -- Surge forward in time, causing your cooldowns to recover 1,000% faster for 2 sec.
    timelessness                    = {  93360, 412710, 1 }, -- Enchant an ally to appear out of sync with the normal flow of time, reducing threat they generate by 30% for 33.7 min. Less effective on tank-specialized allies. May only be placed on one target at a time.
    tomorrow_today                  = {  93369, 412723, 1 }, -- Time Skip channels for 1 sec longer.
    unyielding_domain               = {  93202, 412733, 1 }, -- Upheaval cannot be interrupted, and has an additional 10% chance to critically strike.
    upheaval                        = {  93203, 396286, 1 }, -- Gather earthen power beneath your enemy's feet and send them hurtling upwards, dealing 83,426 Volcanic damage to the target and nearby enemies. Increases the duration of your active Ebon Might effects by 2 sec. Empowering expands the area of effect. I: 3 yd radius. II: 6 yd radius. III: 9 yd radius.
    volcanism                       = {  93206, 406904, 1 }, -- Eruption's Essence cost is reduced by 1.

    -- Chronowarden
    afterimage                      = {  94929, 431875, 1 }, -- Empower spells send up to 3 Chrono Flames to your targets.
    chrono_flame                    = {  94954, 431442, 1, "chronowarden" }, -- Living Flame is enhanced with Bronze magic, repeating 25% of the damage or healing you dealt to the target in the last 5 sec as Arcane, up to 29,455.
    doubletime                      = {  94932, 431874, 1 }, -- Ebon Might and Prescience gain a chance equal to your critical strike chance to grant 50% additional stats.
    golden_opportunity              = {  94942, 432004, 1 }, -- Prescience has a 20% chance to cause your next Prescience to last 100% longer.
    instability_matrix              = {  94930, 431484, 1 }, -- Each time you cast an empower spell, unstable time magic reduces its cooldown by up to 6 sec.
    master_of_destiny               = {  94930, 431840, 1 }, -- Casting Essence spells extends all your active Threads of Fate by 1 sec.
    motes_of_acceleration           = {  94935, 432008, 1 }, -- Warp leaves a trail of Motes of Acceleration. Allies who come in contact with a mote gain 20% increased movement speed for 30 sec.
    primacy                         = {  94951, 431657, 1 }, -- For each damage over time effect from Upheaval, gain 3% haste, up to 9%.
    reverberations                  = {  94925, 431615, 1 }, -- Upheaval deals 50% additional damage over 8 sec.
    temporal_burst                  = {  94955, 431695, 1 }, -- Tip the Scales overloads you with temporal energy, increasing your haste, movement speed, and cooldown recovery rate by 30%, decreasing over 30 sec.
    temporality                     = {  94935, 431873, 1 }, -- Warp reduces damage taken by 20%, starting high and reducing over 3 sec.
    threads_of_fate                 = {  94947, 431715, 1 }, -- Casting an empower spell during Temporal Burst causes a nearby ally to gain a Thread of Fate for 10 sec, granting them a chance to echo their damage or healing spells, dealing 15% of the amount again.
    time_convergence                = {  94932, 431984, 1 }, -- Non-defensive abilities with a 45 second or longer cooldown grant 5% Intellect for 15 sec. Essence spells extend the duration by 1 sec.
    warp                            = {  94948, 429483, 1 }, -- Hover now causes you to briefly warp out of existence and appear at your destination. Hover's cooldown is also reduced by 5 sec. Hover continues to allow Evoker spells to be cast while moving.

    -- Scalecommander
    bombardments                    = {  94936, 434300, 1 }, -- Mass Eruption marks your primary target for destruction for the next 6 sec. You and your allies have a chance to trigger a Bombardment when attacking marked targets, dealing 73,725 Volcanic damage split amongst all nearby enemies.
    diverted_power                  = {  94928, 441219, 1 }, -- Bombardments have a chance to generate Essence Burst.
    extended_battle                 = {  94928, 441212, 1 }, -- Essence abilities extend Bombardments by 1 sec.
    hardened_scales                 = {  94933, 441180, 1 }, -- Obsidian Scales reduces damage taken by an additional 10%.
    maneuverability                 = {  94941, 433871, 1 }, -- Breath of Eons can now be steered in your desired direction. In addition, Breath of Eons burns targets for 109,334 Volcanic damage over 12 sec.
    mass_eruption                   = {  98931, 438587, 1, "scalecommander" }, -- Empower spells cause your next Eruption to strike up to 3 targets. When striking less than 3 targets, Eruption damage is increased by 15% for each missing target.
    melt_armor                      = {  94921, 441176, 1 }, -- Breath of Eons causes enemies to take 20% increased damage from Bombardments and Essence abilities for 12 sec.
    menacing_presence               = {  94933, 441181, 1 }, -- Knocking enemies up or backwards reduces their damage done to you by 15% for 8 sec.
    might_of_the_black_dragonflight = {  94952, 441705, 1 }, -- Black spells deal 20% increased damage.
    nimble_flyer                    = {  94943, 441253, 1 }, -- While Hovering, damage taken from area of effect attacks is reduced by 10%.
    onslaught                       = {  94944, 441245, 1 }, -- Entering combat grants a charge of Burnout, causing your next Living Flame to cast instantly.
    slipstream                      = {  94943, 441257, 1 }, -- Deep Breath resets the cooldown of Hover.
    unrelenting_siege               = {  94934, 441246, 1 }, -- For each second you are in combat, Azure Strike, Living Flame, and Eruption deal 1% increased damage, up to 15%.
    wingleader                      = {  94953, 441206, 1 }, -- Bombardments reduce the cooldown of Breath of Eons by 1 sec for each target struck, up to 3 sec.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    born_in_flame        = 5612, -- (414937)
    chrono_loop          = 5564, -- (383005) Trap the enemy in a time loop for 5 sec. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below 20%.
    divide_and_conquer   = 5557, -- (384689) Breath of Eons forms curtains of fire, preventing line of sight to enemies outside its walls and burning enemies who walk through them for 139,690 Fire damage. Lasts 6 sec.
    dreamwalkers_embrace = 5615, -- (415651) Verdant Embrace tethers you to an ally, increasing movement speed by 40% and slowing and siphoning 24,251 life from enemies who come in contact with the tether. The tether lasts up to 10 sec or until you move more than 30 yards away from your ally.
    nullifying_shroud    = 5558, -- (378464) Wreathe yourself in arcane energy, preventing the next 3 full loss of control effects against you. Lasts 30 sec.
    obsidian_mettle      = 5563, -- (378444) While Obsidian Scales is active you gain immunity to interrupt, silence, and pushback effects.
    scouring_flame       = 5561, -- (378438) Fire Breath burns away 1 beneficial Magic effect per empower level from all targets.
    seismic_slam         = 5454, -- (408543)
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
    -- Damage taken has a chance to summon air support from the Dracthyr.
    bombardments = {
        id = 434473,
        duration = 6.0,
        pandemic = true,
        max_stack = 1,
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
    ebon_might_allies = {
        id = 426404,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 5, -- IDK, maybe?
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    -- Your Ebon Might is active on allies.; Your damage done is increased by $w1%.
    ebon_might_self = {
        id = 395296,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        tick_time = 1.0,
        pandemic = true,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    ebon_might = {
        alias = { "ebon_might_allies", "ebon_might_self" },
        aliasMode = "longest",
        aliasType = "buff",
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end
    },
    -- Your next Eruption $?s414969[or Emerald Blossom ][]costs no Essence.
    essence_burst = {
        id = 392268,
        duration = function() return 15.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = function() return 1 + talent.essence_attunement.rank end,
    },
    -- Movement speed increased by $w2%.$?e0[ Area damage taken reduced by $s1%.][]; Evoker spells may be cast while moving. Does not affect empowered spells.$?e9[; Immune to movement speed reduction effects.][]
    hover = {
        id = 358267,
        duration = function() return ( 6.0 + ( talent.extended_flight.enabled and 4 or 0 ) ) end,
        tick_time = 1.0,
        max_stack = 1,
    },
    -- Essence costs of Disintegrate and Pyre are reduced by $s1, and their damage increased by $s2%.
    imminent_destruction = {
        id = 411055,
        duration = 12.0,
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
        duration = 15,
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
    mass_disintegrate_stacks = {
        id = 436336,
        duration = 15,
        max_stack = 8,
        copy = "mass_disintegrate_ticks"
    },
    mass_eruption_stacks = {
        id = 438588,
        duration = 15,
        max_stack = 10,
        copy = "mass_eruption"
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
    -- Movement speed reduced by $w1%.; Attack speed reduced by $w2%.
    perilous_fate = {
        id = 439606,
        duration = function() return 10.0 * ( 1 + 1.25 * stat.mastery_value ) end,
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
        dot = "buff",
        friendly = true,
        no_ticks = true
    },
    prescience_applied = {
        duration = function() return 18.0 * ( 1 + 1.25 * stat.mastery_value ) end,
        max_stack = 1,
    },
    primacy = {
        id = 431654,
        duration = 8,
        max_stack = 3
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
    -- Watching for allies who use exceptionally powerful abilities.
    sense_power = {
        id = 361021,
        duration = 3600,
        max_stack = 1,
    },
    sense_power_active = {
        id = 361022,
        duration = 10,
        max_stack = 1,
        dot = "buff",
        friendly = true,
        no_ticks = true,
        shared = "target"
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
        duration = function() return 3600.0 * ( 1 + 1.25 * stat.mastery_value ) end,
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
    -- Accumulating damage from $@auracaster's allies who are affected by Ebon Might.
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
end )

-- TheWarWithin
spec:RegisterGear( "tww2", 229283, 229281, 229279, 229280, 229278 )

-- Dragonflight
spec:RegisterGear( "tier29", 200381, 200383, 200378, 200380, 200382 )
spec:RegisterGear( "tier30", 202491, 202489, 202488, 202487, 202486 )
spec:RegisterGear( "tier31", 207225, 207226, 207227, 207228, 207230, 217178, 217180, 217176, 217177, 217179 )
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

    boss = true
end )


spec:RegisterStateTable( "evoker", setmetatable( {}, {
    __index = setfenv( function( t, k )
        if k == "prescience_buffs" then return active_dot.prescience end
        if k == "allied_cds_up" then
            if buff.sense_power.up then return group and active_dot.sense_power_active or 1 end
            return 1 -- If Sense Power isn't used, always assume there's a CD active.
        end
        if k == "use_early_chaining" then k = "use_early_chain" end
        local val = settings[ k ]
        if val ~= nil then return val end
        return false
    end, state )
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
        local power_level = args.empower_to or class.abilities[ this_action ].empowerment_default or max_empower

        if settings.fire_breath_fixed > 0 then
            power_level = min( settings.fire_breath_fixed, power_level )
        end

        return stages[ power_level ] * ( talent.font_of_magic.enabled and 0.8 or 1 ) * ( talent.rockfall.enabled and action == "upheaval" and 0.8 or 1 ) * haste
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
        cooldown = function() return 30 * ( talent.interwoven_threads.enabled and 0.9 or 1 ) end,
        recharge = function() return talent.regenerative_chitin.enabled and 30 * ( talent.interwoven_threads.enabled and 0.9 or 1 ) or nil end,
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
        id = function() return talent.maneuverability.enabled and 442204 or 403631 end,
        color = "bronze",
        cast = 4.0,
        channeled = true,
        cooldown = function() return 120 * ( talent.interwoven_threads.enabled and 0.9 or 1 ) end,
        gcd = "spell",

        talent = "breath_of_eons",
        startsCombat = false,
        toggle = "cooldowns",

        start = function()
            applyBuff( "breath_of_eons" )
            if buff.ebon_might.up then buff.ebon_might.expires = buff.ebon_might.expires + 5
            else applyBuff( "ebon_might", 5 ) end
            if talent.overlord.enabled then
                for i = 1, ( max( 3, active_enemies ) ) do
                    spec.abilities.eruption.handler()
                end
            end
            if set_bonus.tww2 >= 2 then
                local ebon = buff.ebon_might.remains
                spec.abilities.upheaval.handler()
                -- Except ebon might extensions. Why blizz.
                buff.ebon_might.remains = ebon
            end
        end,

        finish = function()
            removeBuff( "breath_of_eons" )
            if talent.plot_the_future.enabled then applyBuff( "fury_of_the_aspects", 15 ) end
        end,

        copy = { 403631, 442204 }
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
        cooldown = 45.0,
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
        cooldown = function() return 30 * ( talent.interwoven_threads.enabled and 0.9 or 1 ) end,
        gcd = "spell",

        spend = 0.010,
        spendType = "mana",

        talent = "ebon_might",
        startsCombat = false,

        handler = function()
            applyBuff( "ebon_might" )
            applyBuff( "ebon_might_self" )
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
            return 3 - talent.volcanism.rank - ( buff.imminent_destruction.up and 1 or 0 )
        end,
        spendType = "essence",
        cycle = function() if talent.bombardments.enabled and buff.mass_eruption_stacks.up then return "bombardments" end end,

        talent = "eruption",
        startsCombat = true,

        handler = function()

            removeStack( "essence_burst" )

            if buff.mass_disintegrate_stacks.up then
                if talent.bombardments.enabled then applyDebuff( "target", "bombardments" ) end
                removeStack( "mass_disintegrate_stacks" )
            end

            if buff.ebon_might.up then
                buff.ebon_might.expires = buff.ebon_might.expires + 1 + ( set_bonus.tier31_4pc > 0 and ( active_dot.prescience * 0.2 ) or 0 )
            end
            if talent.accretion.enabled then reduceCooldown( "upheaval", 1 ) end
            if talent.regenerative_chitin.enabled and buff.blistering_scales.up then addStack( "blistering_scales" ) end

            if talent.reverberations.enabled then
                applyDebuff( "target", "upheaval" )
                active_dot.upheaval = active_enemies
                if talent.primacy.enabled then applyBuff( "primacy", max( 3, active_dot.upheaval ) ) end
            end


            -- Legacy
            removeBuff( "trembling_earth" )
        end
    },

    -- Inhale, stoking your inner flame. Release to exhale, burning enemies in a cone in front of you for 8,395 Fire damage, reduced beyond 5 targets. Empowering causes more of the damage to be dealt immediately instead of over time. I: Deals 2,219 damage instantly and 6,176 over 20 sec. II: Deals 4,072 damage instantly and 4,323 over 14 sec. III: Deals 5,925 damage instantly and 2,470 over 8 sec. IV: Deals 7,778 damage instantly and 618 over 2 sec.
    fire_breath = {
        id = function() return talent.font_of_magic.enabled and 382266 or 357208 end,
        known = 357208,
        cast = empowered_cast_time,
        empowered = true,
        cooldown = function() return 30 * ( talent.interwoven_threads.enabled and 0.9 or 1 ) end,
        gcd = "off",
        school = "fire",
        color = "red",

        spend = 0.026,
        spendType = "mana",

        startsCombat = true,
        caption = function()
            local power_level = settings.fire_breath_fixed
            if power_level > 0 then return power_level end
        end,

        spell_targets = function () return active_enemies end,
        damage = function () return 1.334 * stat.spell_power * ( 1 + 0.1 * talent.blast_furnace.rank ) * ( debuff.shattering_star.up and 1.2 or 1 ) end,
        critical = function () return stat.crit + conduit.spark_of_savagery.mod end,
        critical_damage = function () return talent.tyranny.enabled and 2.2 or 2 end,

        handler = function()
            -- Many Color, Essence and Empower interactions have been moved to the runHandler hook
            if talent.leaping_flames.enabled then applyBuff( "leaping_flames", nil, empowerment_level ) end
            if talent.mass_eruption.enabled then addStack( "mass_eruption_stacks" ) end -- ???

            applyDebuff( "target", "fire_breath" )
            applyDebuff( "target", "fire_breath_damage" )
            if talent.infernos_blessing.enabled then applyBuff( "infernos_blessing" ) end

            -- Legacy
            if set_bonus.tier29_2pc > 0 then applyBuff( "limitless_potential" ) end
            if set_bonus.tier30_4pc > 0 then applyBuff( "blazing_shards" ) end
        end,

        copy = { 382266, 357208 }
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

    -- Send a flickering flame towards your target, dealing 2,625 Fire damage to an enemy or healing an ally for 3,089.
    living_flame = {
        id = function() return talent.chrono_flame.enabled and 431443 or 361469 end,
        cast = function() return 2 * ( buff.ancient_flame.up and 0.6 or 1 ) * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",
        color = "red",

        spend = 0.12,
        spendType = "mana",

        startsCombat = true,

        damage = function () return 1.61 * stat.spell_power * ( talent.engulfing_blaze.enabled and 1.4 or 1 ) end,
        healing = function () return 2.75 * stat.spell_power * ( talent.engulfing_blaze.enabled and 1.4 or 1 ) * ( 1 + 0.03 * talent.enkindled.rank ) * ( talent.inner_radiance.enabled and 1.3 or 1 ) end,
        spell_targets = function () return buff.leaping_flames.up and min( active_enemies, 1 + buff.leaping_flames.stack ) end,

        handler = function ()
            if buff.burnout.up then removeStack( "burnout" )
            else removeBuff( "ancient_flame" ) end

            removeBuff( "leaping_flames" )
            removeBuff( "scarlet_adaptation" )
        end,

        copy = { 361469, "chrono_flame", 431443 }
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
        cooldown = function() return 10 * ( talent.interwoven_threads.enabled and 0.9 or 1 ) end,
        charges = 2,
        recharge = function() return 10 * ( talent.interwoven_threads.enabled and 0.9 or 1 ) end,
        gcd = "spell",

        talent = "prescience",
        startsCombat = false,

        handler = function()
            applyBuff( "prescience_applied" )
            if solo then applyBuff( "prescience" ) end
            active_dot.prescience = min( group_members, active_dot.prescience + 1 )

            if set_bonus.tier31_4pc > 0 then addStack( "trembling_earth" ) end
        end,
    },


    -- Gauge the magical energy of your allies, showing you when they are using an exceptionally powerful ability.
    sense_power = {
        id = 361021,
        cast = 0.0,
        cooldown = 1.0,
        gcd = "off",

        startsCombat = false,
        nobuff = "sense_power",

        handler = function()
            applyBuff( "sense_power" )
        end,
    },

    -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by $s4% for $d.; Affects the nearest healer within $407497A1 yds, if you do not have a healer targeted.
    spatial_paradox = {
        id = 406732,
        color = "bronze",
        cast = 0.0,
        cooldown = function() return 120 * ( talent.interwoven_threads.enabled and 0.9 or 1 ) end,
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
        empowerment_default = 1,
        cooldown = function() return 40 * ( talent.interwoven_threads.enabled and 0.9 or 1 ) end,
        gcd = "spell",

        talent = "upheaval",
        startsCombat = true,

        handler = function()
            if buff.ebon_might.up then buff.ebon_might.expires = buff.ebon_might.expires + 2 end
            if talent.mass_disintegrate.enabled then addStack( "mass_disintegrate_stacks" ) end
            if talent.mass_eruption.enabled then applyBuff( "mass_eruption_stacks" ) end
            -- This was reduced to 50% chance, can't gaurantee it atm
            -- if set_bonus.tww2 >= 4 then addStack( "essence_burst" ) end
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

local devastation = class.specs[ 1467 ]

spec:RegisterSetting( "fire_breath_fixed", 0, {
    name = strformat( "%s: Empowerment", Hekili:GetSpellLinkWithTexture( devastation.abilities.fire_breath.id ) ),
    type = "range",
    desc = strformat( "If set to |cffffd1000|r, %s will be recommended at different empowerment levels based on the action priority list.\n\n"
        .. "To force %s to be used at a specific level, set this to 1, 2, 3 or 4.\n\n"
        .. "If the selected empowerment level exceeds your maximum, the maximum level will be used instead.", Hekili:GetSpellLinkWithTexture( devastation.abilities.fire_breath.id ),
        devastation.abilities.fire_breath.name ),
    min = 0,
    max = 4,
    step = 1,
    width = "full"
} )

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


spec:RegisterRanges( "azure_strike" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    gcdSync = false,

    nameplates = false,
    nameplateRange = 30,

    damage = true,
    damageDots = true,
    damageOnScreen = true,
    damageExpiration = 8,

    package = "Augmentation",
} )


spec:RegisterPack( "Augmentation", 20250414, [[Hekili:T3ZAZnUns(BX1wrrA8yzr6hZKSwkv2K7rsTB2CN3C5dxDMIIeYI3qjYLpShNYL(TFDdWhaGaGGYYtsQlB2D2mcnB0OFHUB0e8oN7(h3DBOFb5UFWDM7vZU05YPUUx(UlCV72INsj3DBQFWh8Vh(x25Vf(ZVU8(TKDf(frj7WbFkoXpersEszwaaWMII08V88ZVpQyt5QPbjBpppABzm9jcY8xxG)9GZxfNS68InKh9ZEeanA35FDacYpMfLKfv80FnkVi)CYdjFGK55ZnRtXh)UBxvgfx8D7UBLs635DafLscU7hCGfdqvrHHegWKC4PrGpB2LN5C5xUF5TrB)g4pFAxW(VNnWfNnZfg4F8Z)m87e)8KD7x6UFzzkovuGGh19Szx380Idn7m3lGHCCMoB6vC)OJw4PO6hZaIlISlGSF52Km4ph))E(hER4ZmH7HCKEOysEE1WZ(IZCVeEu8))9ay)nk((x2MM8ijJeUF557x(xYi(fB2VCD0hj8phU2)PCa8)1i8HQbJssTqHt()j5HOCqOKdijjB)Y8K4K9lFiF6(L3NLuM(NBwPlxNLSTAL0GdNRaC8FusIJbaj7YlXP7Ns3q8FWpE)YaFqha))a2VF8J(pHtt0UO8n1O4DN5(o2IC2xGeT256DmjY)ydm6p7du6ptv6U72yupdvGxhfhtYG)TFGAuq25VkMeE3F5UBda9rswK)D3oE)YvLRxp1FhYXl8whdgftlt3V85Nb(J)o)9lxmh0vMH)h2VEY(Lf(Xa0tdb(4wVK1E5Pzr7UFA1uWa7bFygG)608uaiGdaRFatasMSF5iqtaybGbYdepYoY2iqEHd7WE4QjiTmnkgNa4V(X8Im)8FXxCwOuFmXpfMFg1Ntj)j3DRFaZMoo6HMbVRaSR0YnoPcFKvj782gD)McVCs8Akch1quI8QgQPfG8a)SysHNFOFALjopuwW)yqPrYmsnJRDbt2sY8Jd9aps55jBX18f)6VM1VAgBfprTc5el4hpqYc9HjLSDvMFavh4sKFupU)VaMPEG6v0hi8CPc4FUnjfWAMNEJPKuWZmPGB6Qu8X)T4ss7pmTcxHKy)NGLXxXzKSf8cSTew4CGijMKrtqyoaxbjOOIjpU2DfYQQyjHjftxrD3H8uc1X2cMviLW8y7ckmTkSro4f5zujH(jswXS)jkijjom5XDslRPzKT(rTlVAEqshalI2cs7i6(l3a6DrBjkOqEUBJgJsliDIxqj8coJYSYu6)gGRR0IRxnpI6DhET1McHK1(LXfngb1p0)e3VteAMcunaL7Y8FGidYWf9He6IRGaB6dE48EmPCxyTGNxgIqWgvLORAIIwF4Az8tg(7E1)UcPRX1vnssH5ZdI4WlkKxFOsQhTf8pG(nHG9kYkd49V2kxUDwd5pMZDbp9r14FpVJBP1NGQudtiKqs9yqoTlMoPxKX8sdXYHr1byBDuqubZeXry)Hkq8wvMLxGQT1kOC8ZA2yAtCIsr0WCcoQcLTGjq6vMv0G643dbDyMYfb6n0aLBczb(VRlJJb(zWg)S7jEO7dakyLCFq40T(FC)Y3ag(smW2Dx5iIUpdBouUFCZJDwNNAcdxkFSWYm6UXuyBvjAHk1Fxi4SjWRydSQ3a0BLBei2bkbTMcMavFbBJxHO8K0YMtvo4CCb7ChSjlbI1DRqKbuQwP(DLCPsLOwOXuwAySRHa6R1mREa(HlRc9MftiD4kNiAul4zTUDJor5QOXRRO2BEbKPjfPkgeMdVkaOmPgTih2wZbpfedkxOkgenp4VfmeEN2TnqQUD)pmkBilTwIpZpk0J8aUa2M8abZ8Ck5Jr0Cryabo839bsX0cNPr5ttGDi8)yUhehzqjmbXEK7VVIqRb01aGv6gQM2ODSL51cHOVbgod2NiNa(ow7blNQL877Fx3UkEZSrdMZpss9(YFrF7lJohATDQZNbNmBmBRchHZxaMpyLhKJUrmtWQHn1gJu)oVh13gbTiRctO0mojlutApdDIATDh3UtHwxgTwJ6efcoE50cd8bh7S)IhMfnlx66D5rSfNCFuaQP4mtZMsgXbOnTLgIGJ(mY1fnjLhpIPv3oDzL70oBIzUGZQ(mFRKmO6Jpe4liAw7xiMOhW7bFMpGgNtD6KtbY15gMt8zJXOGyOikf0JHOqbEjHXU0N(kHv)hmtrUTcASjhl4fYpmumpbNl64PIcd6LAbMKjBywr7McI2isinZaurtWgsgd1UxN0NH4CUHqdxVQvKhT8t2zHAyJyPkUCIbBuUSg1N)XliCrERU(bNMK)vus3wt01ROkl6ZuZK7jQlJT(55E1zQX2FoVXPsF8U2Xfqt)m42LhhNGUuKtLOjHQQWA0yju2uWrMKddIGL2BrIxyeHQ7YT3ZPyadUTSbTEoHhRDViznQTjXfKDyvwizsAg4(MCMNEH(B9VNaKuWha6vsDGpKob1bNHSLLjzTSqyrDKLA3(HlffT6ingz9xHIJLrFfipcmriJ)qWhLYntpq6yIycjhCWTWAbY)1duQkZNw84JUExMgiftqwsWhwdg3DmPuMwi1NqnTwKC3T0GfDKZuSJLVgg1yngjOo3v1eAdJQfjiBkGMci8t5wUrhDqdERBTYffB0vO(uaglQ6PlHZlneGuRsSeTVOHpOzJsCueTYRz(LCdJXIAAiODVLex45NTnjRTKhgyr6tz4talQpMWjYbWPybOplKX1X00JVYVIf6YeQN9XQshwfSS)7Ik90b4kZDgVC1K)Q(9Q1FYgvtOqaJybD)qeTArUYrM3XjGPtDrJ3gPq4eprlxPaWehvS(wkp)dZNXIKxyfkK0quLRTgxEWA9EpVpV3J6XCzb1AzIXJEYvoxhLfIURystqu9gQ2ilYruTK2290gPQuM1s6EleWcw1pec5rNRORLkA1QKTR8ZcXkPKlu2Q6sl0WU(ijOSOU6K1BXz5jiOojanfLYvoPYAXR4rj8hI3prIxsWMe0SIX4TiSxDYv5CUBmXRpilfTrGPeheP5F19zvRj142M7eyeK0gl0uNLWnTBiOzVeH9k6PgEnNuRsjK(eD5kx5kmbzAAHvfuPMnpsJmdzCCXNi)40zwxEPMkhvtDOkOhDtaQR3EwICidpVmGd03jM1Snl3bG5CNMZU2c8P(e45oBTd6ilFyahWFDGX7GF6riX1DEv1JRnU3ohtDZbPR5qopusJg6OYArQ64jpikw15KAHCs15ZljMKZdSFEH45FKvU6jVh3qIt9YH)SUokcW84MO8uMHr0Ua)SD(GVTOaSWiDb2MduHcO)kswg2RkaUJJbVr3lS2Ra2ZXJ8XG4YqIQJfAaRwxlwTUdz1A6uH6cOLRwx(vRC6Ddy1s5W7EABjj3RQLeO(1sJ2fgtujoYtFccebuUZ9EKSsfefG6EWgswszUhel1U8Trff4zzHTLzwu1oL)aDs3Vmkh3CABACuaWadF7(L)n)DLyMc)7(inOwwVLcJQdOAalE3HS4D7DX7ACXRsg2Uk6C4jdyzqz6RGPf2IPiHEobRipLSlunRl5(GqpSsNkp1LbmVUdzEDLM3H3nvIhj7gFqMLJbrSEnto034FQhSB4uDCvjDkeccuihWmYUWKCpi3KKci4b6XRorTqfNs1Nl0WySU9Wyvn(N6b1ZyD7HX6ougRlhJDGTmvxzu(t7cuESMsIXMSxA1hAR)tZrn8zqMkyrFM325IG00JeNdt6SPx1iEDuESjdK6D7N6D1q9UhbQxt0l2s9PvVVb3PP7rvjagW6dvpRxJ2OBwx2prphTyqUpI0qb9YKpxaa8z9AhCcTZjgx1xmNAWEJ1rvMGObxkizuVPPqQDOBLQ2NlaG10TSd4U0Tcx0AOBNw6MbHtDHJfP(O4hIPnYcVpg6VnHUoCM1wizrLCNgvCxLhJHLQ4SJn07LOPRwBTD8olnSEos8aZRnnbOIRnHcMWJ0bgzMbGB2k4aT3Nif563MuUcXlQnwIVbnNHVGorjfr)c8x(oiXpiR(GcoaQqjGl8Sx3VKf77BPVpnyB8H)6JaJGEWVf4RVYUKSTymW0URb(TK9lVV0htmGaJIvvHf3Cwgmttn7ZtZg)AKvQIN2IuqLpQuU8pVw5zqyjEnwni(KCNEPYkRB50O7amLtJUtPDzpUYS2AQ6RIbvvnXHuRQ(QgLWlZH4Pk0oJ06oXAalf1CQ(P1AzXtX9EOy0Z6vrKnMnDvzxwRyl0jo26lOxe62S974(otrUdg1WPjwb1eXQWQ9SdzT0bZR84MQGl1E)11m1qZNn54ZRDp28AwL2zwq61Yuu(Yd3Otxf8vMuWlDt06Yu0zxuTjHufzOXTJvpUQzsFEK1Sq1dQO0P18jTL3yGUcCeoFCv9Gc94cm04iqgn3wVJNAAsr9uRxgI1XrkkKxUnNkYfBGGZOJI)BNI5)qJTS36fxheQbE1zSZ)VfOMJ)VfM3i6rRfcbY8lMvpD2u8DEFLMKv1nnk)(As8UMM5vXJF9mT(ZKliNn5E2EKAQGt4ulRBVotzZnXMcfAtg9kOlNHsxILwQPsjufArAI(cWvFSrcwdkoTGwZF604yDzm61Typ1hRjt3d2OSoz7E7Xgk(18k)wP42EmXv7EzrI6NOwnRTfA4O9oTRn3yTnW6eZKR(0Dmucc5Iy0R1HY1DND37OolLmpYhLm4hv3oy5WgsCACkovhjTsxRlpvVBH2tbC(9PwPJgTsNFD1kDSVWy96BSFTsxvoSpuTsxvN(wxFLsAYYVtxhZOmTYDAdeAkEKMmRuZU5aq9(EY79KraBf(wp6c5nZ6(6G4ADBURJMvTnBp7QZywIVhHyzhzD9Kc2CZjC1TMrF3ASCqXpH)jPBLHqBQKhIcrRyFgl7T1qGLdkb(Zm2J1SI2V8Vd)ueG4DKi249JTvjOrSaEuDiQD9SkP3pqD4JVZxR0HLZyvNldoa(nNoCpHk2teGduh2vuhw1btBkuW)W91rv0FmCFPMJk6PQBKwDAlatHA9hg8hvP(XWGxnh1Gu3vztz0uJzsEbSSGhiVRNFwoKcG0QBOjEqLDQq9SHSqVn(yFKWOrUFq)2oDEF)5V2cMn96AnnY)SmknLeovGIf2SMETO1Sf9Je)u27HsXD8VYZYx5lTRYo1yF9kvfyxrjZeRZSF4tMcQMZQSZRhSojj3eCNWBl2LkAOwokS7R2ZLusRsXEDYUcuTgSmJcKFpYus(8OI71USr9T)xGYEQ5(yMb4PukTTYyRIXjBDz2o)aIqf0UM7UdPkfbwYDcm3Q30otLswhl(IHYIF)Vl5GU2WbXX09EQpXubO1YDDhk31X93LSxhE2RrwOUIFRLf6myw41)UKfoZAwOU6GQLfIV0fv)9HYmFDCOACvAQOAVcUX6DTj9kr7w9krBwpzcDpwyx2hGFgjD2Te7fZapcp6NTJDm(0lf0iSmDfvxJPFE1j7)57xMHbfqVWuZtqMMFzrYwF6Diyae3X9GtR9F)FncZC)DF5(LFtYoyUOd)51HTPVN2b8JTVXNlgZPoqh78Xj9oz6BP8otMrqRMS9FVcUtZ7JYW4pxBI)i3w9QznkGsGRyCk02v(QNltGB)KANOWE5UXjtXjBREQudO9ky9kT0bL9tH9sREb3(j1oPLngowmz2iTmaOWe9EtQfABGc1khMa3(jvmZz1ZuhySh9AozF1ZJEGfMWVWK0YEMyVGB)K2dtunm2JEBzI9aSWe6mZKyt17eIAzMgifNlhtRoRMltqkoxUAxx8DoSIfJ0WdbR0W5IQBBun4Udqh9z4Lq9mDZNmr7TGCKX(lHUXqg9lIIJkms7IG9kmlVK1WgK7yI6Rb4OI5xcfJjlyIGRg)yI3dGCJ007CQ9KPduXz7cTUYm6EPZWdbR9y8RbOJ(m8sOEDoaucYrg7Ve62KHVwWEfMLxYAqTtafaCuX8lHIv6gO74ht8EaKR1UxmcQ4SDPwNzDosjfEXubZRl(1I5eilpki57xI3NAFUUJvE0yttWN9zoUZMpBsnXCGyPcjTu7vALQ9ZhudJiF(yJFTyUF(SBhoKIjOx(SDyPdFwxDqe7wrn2KCdlYD1xDfJyTZW2H1dvM9AJFBWCAwsWu)Dp5fMMBc76GZ2vGTZdQe5Da436Gu6jmOJWmODNclW9limOxm2hmDFO7j8AJFBWSD6J6HZ2vGTZZHP3pGC)pq9(bmdhG(tVAMwuDHxm2pa6gFFOvGTQF2oS4QglUwHLo7QFI2aFSANA(99g1fxnTQ1ZpFIe3R(PM88Z6NjZbfWnOGzWK3mE20RovJBQ3CHUrGNtbPGVT)tMSyS5ab1zsktloAPfNEPf2npamIZPcudk4ptsryYN5mB2KjnXD97y585)gsoF(V5KZNxjNBn5nCOtdWXHHtZEaoX(v5CP0oRdiySE227imdA3(qpUhepRxWTBwhWg5hipBaZWG5z9Q48kPNnOzTxWRMvARySojoobFtFXETiZph7cv8ZMlWAcz7PtFTqy9QZ(L4vab2wqf1WTlH2hhL7eGomebo0VWFLFo5l3)90EIclRLMEaHE3q85dQ)p0DyD9Y0FrYOpTIO))2k9tArm1nzVkhiJUcTDKAUHJDD8ELr)qqCvd(zcVTGmuQEai3c02VO0IwSqVMs)8AlkZXXg9dbX642kbzOu9aqEdATOuNLPMuoOJkqPhduAbY4Zfsb2KgEOu4amlEvrEVO1(kBzvf0E5tJqwCYOxFsqM0nKh9OJslqMr1nZNxHfu4amDFvrEVO1(dqWk1Tx(0yuDtF(e9YC63q)4IClq7rzZvlO6bfiZRm6BqSU(U8W0ZLO6JlYTaT9lkTiKxlO6bfiZRm6BqS2oA9WSCKtB74IDBWB)stlmmTHUhKPZRn(BXS(0Z7LJ3VT5rg72G3(LNwyDAdDpi7NxB8pfRm13rlkfIV3jwZlSSt4xoNK1r41r6F6pTF5MII08V88ZVpQyt5kaJBpppABzmfDbz(RlW)EW5RItwDEXgYJ(zpcGgT78VMI4FS66e4VIO)C2x5yp)Y7XpavuCmfF89Fpox)ukBje6xaRDen7xEB02Vb4bFDAwu8E67yk(2Orl027CNDXfR)cCfXwe5tBEjRoD(51NqWBXxO(5nFkFEB1RP2CN3MKoNEv2AZZR6dytdcAW5mBqLakO3vWZBondLtt065NO9Ud81ygpTzuz64yqg8FwDoqwyLoE7D1q1QsW8w(nP65Nfgw7l)KeCkFNLKGrXlB0qwgUAwgUMxgUwUmCTyz4QDz8NQVFT7)BlZqwZ13tnQKCARKQeBx05S0GAE1Bgcn6QMgnxTxjEQoA09irJCx(mQyLQElDgc6D1IETVeqdb9vNNEfQh3s68hC1ZplnG4XEXl3L7cfLJ9qBdERC8n4ZQCe8SDMO4O8B8dnz04te4)klB(KHWICvZIC1XIuDAQ8QD6zrU9WIK71CLJOJf5QIfP)ymgelID2)4Ej0VccvSkN32EV8pF20RElOPggH4CU2(6GtrRtWt1DL7qOm3xmL1PXsueM(Hqz13ZtY0MlpT5WrzVKMH5G6fMdPvyuXCAhtz9MKAcfvMpCDIsx7hlBmgvkuTJzdLPY3hhL115N1TjJuxYi2mu2OuP5oe7iOBPsvHnIi1UyU4IHg3YV9(YIydZ8G5ICCadXNmYKMUu8j6rYjM0kXmfgBh1y7ec7Amy)pwP6k)HwPBgjxBdAm(DvrrwotV0gSQ7ZOI1PnHXhGDDcdDwNMsNpckOefbu3xrfDZp)NkfUe1Hr(NLajW)dvYC(FsYUaKsSBe6kdb13w0vfbspE4VzbLTTA8rR5JTGwKY9PDMppzfFyNBfzvtEDKDnQX8e4nVFKYl7WNFUD7ecjv6JPc8uNO8XMms6Zj9I5oJoHYg78zKMBTcI08GiC43kCxfbUFqt98K4KruK0cydP488Z3dj4KoIt)PfSBCbl7XRlJJHvCWgeT0BAPBMxDFd(Ml4wQD)yBZb3OXS1H6lYPZAGBYnZvcy92UVPvqyYO(5NXBW6rc3pt3m)Iz8bQiijN)EWzhtO4Vds7llzxu(wgFtZxa8AP1nGqQHjWFPgcG0oqZL6vz6Krvghkei1mcxmq8o0dSS6QnqVNoVrXanFu0HLgvQ5GrHIfZZwLhJIE7wfm8bzAtGyO4kTiYUPJKLGBo4V7dtEnwYxnH3uzdgIWBlBVxnzltURtZfyi)aHK5hb788a7Q46bcs2tjFeRt6iXnpTP0nkHbufvnjr7Uz(1ceDAc1ZeqNAuDNPtBNhlWobX8FB252zKgDK0MiTwxi6nB8YWkV9FZDY2rYCEKA)VlMHzKOYv6itoGXhR6Pq9H4KSqnEKvJg0cE8jMCnuR0QMH1ydnPFbeTRu5bt6tSVqXBzFI9f0u4Rr8IzJOF4AOUa(VV9PSO1)p0WU)2KDFEb1RqjqepH9aleKaOogwfhDCzEHSNJ1LzpH8jS2s(O5Dro3MR0p5ob0dh5E0(SAFm5F2RjSu0B54kJ5fZDvA2JfKRqGPjEBBYp)SkFJe4A)cYOXP6((u88ZCdXjM1Ufs)cT1Rqkr91qiymnMZU3pmSjaMfoxi4tGow0UfUG(k7WzMctxejKwL(YuQ6Vm8mNut0zX0QzihBTotjn7yoFgN)6AZONFUYfs1NPJ5onwAdkcPAdeZGbQjxnrqCWbeNUqJrED(35EKSs69FmBZICQjB3ft9Vi8iDxJcbkxTn)BBVfjz7XWPnudtZwGuRIIeVWiYIgxNNoBQ7itUrwu7eTvoiCRr(8ZOJCovppwLaGPl4daDWXCv8j)dI9uV3vzgRihzHJo)MvEb0icafQEcX)GuFR(5201gD4ZYK64yhC4iNiDFFEzAqZMozjbFyTpE6rQJ2xqhxKM5uZ5wGJvOyn35kUc2Ol5vTE9gPXlGzsB8yJPhCPMnkrDbbsybq8k8m6C1ZplsQiLsxbgsYRrLyljUWZpBBs2NSvHk69e2UY87Qv99QJn5JnAN(vUZMC64U5zWp(KjlazOfMxUZ0Lr7qcqIdDcQUqeUz(Gb1QyybNSLt3neEWTisZtrxKJuAgWTNwthdGrkO4xRZB2FhMzsbRghikAsWG73NOj5uCtbPmYPXARXbWCtoagzqdAXLcCj(YYOkPmvBkzCRTrgJvvfVUFhADkvHJ5m8xm)6EkvW1nPfVclqvwiMouJQ5n1jzuT6G4CibLfSKsr)DuEsAzAumQgb)1pcls)8FXV7(1cCB)FPeSPayJ(WFWThg3MeSjHwLrkZRtqat0MOHy6fyP9lzhN5(L0IFMx9o55J3s2XRzxc4Y5FWCsMgbEu(eL3Xs4FKiIKuS6h5ixilXp7teHW7sTscPS0Fgvr4fPFY8ZXfbcxrzRuM1MmTeXDJgUdcQD1tyH4(shqf1vhzoUW7nzDww6TLKVTgmO8SbJTaSELYmD1evGF4tQjoUQgZqj3ZXNUYLkReOqCmxwVpQW1BFp(KAYSrB(kAdI5M5JDND6LVPoge(V5bND9BUyYKkfIoF9nMy3A(I(xZV)xTLNR(LhyBOSkdwUSD7Fz74(R262bx3VO1NJfRVR)vB9n7fV(a3U9VcFzgRAjr7Oq7mSusGD)azmsf)NNvr9SkhcDZoHYjd88ZB935JzPG)N2uCKsgrzcgy1VKJRSjVs1HHsPbiN70gst2bvn5RipPt04sxzcn1)i4Milg4I(H(PStDzKM1OU0LKxIkiwisMq8yRbPrgOxFujw1e1yTckE55eBiE(O)57vDAz3pv(i612aecBhRo36BMFXilB7IU9mrD3Mq1XSQLmmGdxWK2yjfOv0WGtnimU(kKGZSrNmw3hmAHkUlIGjhbEK7rGhXLJOgDbJTRH6hrzVusTx029mQgH12ZJewJkrn4rtx33OS1TKqS(wKTVfQMoN2kReNMkq1wIs1fL05kHSXAOLWepneaSlu(h6E8VhIIQCD8aQPxvgXUn)qNzWerEQVy2zJVy2PoU1rA09vazYB6WvpZD2B4twfl44BADm08BTYMVy2K3O)LDbDROsoHhFfFYucRMfZKb)6zYobe5BgB2wmVvfd3uwe8mnuO5x39ZgF9am2)X8tC3x6nntCBNPpPAVoXzuiLTo6u4xZZ62k0r4qFhGxedTl)OXhI6P2kfRlMaXDPboLPMj(efcxmIGuLFb)fiZ69XMOJsu1fJQA9zX(L2K(MIfc3om8kmkBX4fIbkps4ycmRp4QuFWcN)g6(7FlPp4iRp48PrFWP3wH3KBat6dUcoFgG(aUf4xJHXUFj(bogIJLv80)()238TT9m909l)UqcR7ok2GD9mi7Id3VCfbB766o4I95uS6Quf4zSIYsVS1ypf()YJ2MIvWAPpwb3Cc2Hk0EREdeGf20107KTOacUs3VmmAneQed7iA)2F82PQ35wOw88blGa4fe654CPZuHdcQvW08QqnsJorZZOPH4fdUww2P2Ru3j1DGtQRjfgS7ga(03Tg7cEu0LSJ0TH43VeuxEikeFla9zfl)T1qGDVtc8NzShRzca9d4NIaeVJeXgVFSTkbFRFfXJE)rIXz1z3QdkOxJBx1lV2Oa28E)Y7oZ)ns)MlMPPjzwqd(rBJj0Lw4dNWqCkJgZ3YIZM60nvgodctbMQxi5Qwi9s3dPxHKrdINn9oM(QkK0eZNHy6Sqi5ANq6pSDoQ2oQyedwo8hMhVyZdvmcRKd0SPxrYlaYdej5DtPxtiD0Dt)PC(9qFK4NMSR34QrwH3giGNE6E86oFF20RhDcEtYMMscNYrR8vzuOTDpDixmecT17x18ZAVHkKFq(R5Hr0xreJ5Op5ytZN5mqmkCVuy1Rd0IQYoK0bawLnIGasVH(DdxlL0C46r66O65xO)PLpeIJYXfOF64dE(UB9ll2KKD3T36tIbdY9lh)DbpD2)fbdQ8pZU5wOFiXV7)7]] )