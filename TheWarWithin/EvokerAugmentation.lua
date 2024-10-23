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
    aerial_mastery                  = {  93352, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame                   = {  93271, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream            = {  93292, 376930, 2 }, -- Your healing done and healing received are increased by 2%.
    blast_furnace                   = {  93309, 375510, 1 }, -- Fire Breath's damage over time lasts 4 sec longer.
    bountiful_bloom                 = {  93291, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame               = {  93294, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 41,237 upon removing any effect.
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
    obsidian_scales                 = {  93304, 363916, 1 }, -- Reinforce your scales, reducing damage taken by 30%. Lasts 13.9 sec.
    oppressing_roar                 = {  93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    overawe                         = {  93297, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 30 sec.
    panacea                         = {  93348, 387761, 1 }, -- Emerald Blossom and Verdant Embrace instantly heal you for 18,409 when cast.
    potent_mana                     = {  93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by 3%.
    protracted_talons               = {  93307, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                           = {  93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall                          = {  93301, 371806, 1 }, -- You may reactivate Breath of Eons within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic              = {  93353, 387787, 1 }, -- Your Leech is increased by 2%.
    renewing_blaze                  = {  93354, 374348, 1 }, -- The flames of life surround you for 9.3 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    rescue                          = {  93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    scarlet_adaptation              = {  93340, 372469, 1 }, -- Store 20% of your effective healing, up to 23,667. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk                      = {  93293, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic                 = {  93344, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 1.2 |4hour:hrs;. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    spatial_paradox                 = {  93351, 406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by 100% for 11.6 sec. Affects the nearest healer within 60 yds, if you do not have a healer targeted.
    tailwind                        = {  93290, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    terror_of_the_skies             = {  93342, 371032, 1 }, -- Breath of Eons stuns enemies for 3 sec.
    time_spiral                     = {  93351, 374968, 1 }, -- Bend time, allowing you and your allies within 40 yds to cast their major movement ability once in the next 11.6 sec, even if it is on cooldown.
    tip_the_scales                  = {  93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian                   = {  93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5.8 sec.
    unravel                         = {  93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 110,279 Spellfrost damage to absorb shields.
    verdant_embrace                 = {  93341, 360995, 1 }, -- Fly to an ally and heal them for 73,873, or heal yourself for the same amount.
    walloping_blow                  = {  93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr                          = {  93346, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 9.3 sec.

    -- Augmentation
    accretion                       = {  93229, 407876, 1 }, -- Eruption reduces the remaining cooldown of Upheaval by 1.0 sec.
    anachronism                     = {  93223, 407869, 1 }, -- Prescience has a 35% chance to grant Essence Burst.
    arcane_reach                    = {  93225, 454983, 1 }, -- The range of your helpful magics is increased by 5 yards.
    aspects_favor                   = {  93217, 407243, 2 }, -- Obsidian Scales activates Black Attunement, and amplifies it to increase maximum health by 4.0% for 13.9 sec. Hover activates Bronze Attunement, and amplifies it to increase movement speed by 25% for 4.6 sec.
    bestow_weyrnstone               = {  93195, 408233, 1 }, -- Conjure a pair of Weyrnstones, one for your target ally and one for yourself. Only one ally may bear your Weyrnstone at a time. A Weyrnstone can be activated by the bearer to transport them to the other Weyrnstone's location, if they are within 100 yds.
    blistering_scales               = {  93209, 360827, 1 }, -- Protect an ally with 15 explosive dragonscales, increasing their Armor by 20% of your own. Melee attacks against the target cause 1 scale to explode, dealing 3,675 Volcanic damage to enemies near them. This damage can only occur every few sec. Blistering Scales can only be placed on one target at a time. Casts on your enemy's target if they have one.
    breath_of_eons                  = {  93234, 403631, 1 }, -- Fly to the targeted location, exposing Temporal Wounds on enemies in your path for 11.6 sec. Temporal Wounds accumulate 10% of damage dealt by your allies affected by Ebon Might, then critically strike for that amount as Arcane damage. Applies Ebon Might for 5 sec. Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    chrono_ward                     = {  93235, 409676, 1 }, -- When allies deal damage with Temporal Wounds, they gain a shield for 100% of the damage dealt. Absorption cannot exceed 30% of your maximum health.
    defy_fate                       = {  93222, 404195, 1 }, -- Fatal attacks are diverted into a nearby timeline, preventing the damage, and your death, in this one. The release of temporal energy restores 168,392 health to you, and 56,131 to 4 nearby allies, over 9 sec. Healing starts high and declines over the duration. May only occur once every 6 min.
    draconic_attunements            = {  93218, 403208, 1 }, -- Learn to attune yourself to the essence of the Black or Bronze Dragonflights: Black Attunement: You and your 4 nearest allies have 2% increased maximum health. Bronze Attunement:You and your 4 nearest allies have 10% increased movement speed.
    dream_of_spring                 = {  93359, 414969, 1 }, -- Emerald Blossom no longer has a cooldown, deals 35% increased healing, and increases the duration of your active Ebon Might effects by 1 sec, but costs 3 Essence.
    ebon_might                      = {  93198, 395152, 1 }, -- Increase your 4 nearest allies' primary stat by 5.0% of your own, and cause you to deal 20% more damage, for 11.6 sec. May only affect 4 allies at once, and prefers to imbue damage dealers. Eruption, Breath of Eons, and your empower spells extend the duration of these effects.
    echoing_strike                  = {  93221, 410784, 1 }, -- Azure Strike deals 15% increased damage and has a 10% chance per target hit to echo, casting again.
    eruption                        = {  93200, 395160, 1 }, -- Cause a violent eruption beneath an enemy's feet, dealing 34,309 Volcanic damage split between them and nearby enemies. Increases the duration of your active Ebon Might effects by 1 sec.
    essence_attunement              = {  93219, 375722, 1 }, -- Essence Burst stacks 2 times.
    essence_burst                   = {  93220, 396187, 1 }, -- Your Living Flame has a 20% chance, and your Azure Strike has a 15% chance, to make your next Eruption cost no Essence. Stacks 2 times.
    fate_mirror                     = {  93367, 412774, 1 }, -- Prescience grants the ally a chance for their spells and abilities to echo their damage or healing, dealing 15% of the amount again.
    font_of_magic                   = {  93231, 408083, 1 }, -- Your empower spells' maximum level is increased by 1, and they reach maximum empower level 20% faster.
    hoarded_power                   = {  93212, 375796, 1 }, -- Essence Burst has a 20% chance to not be consumed.
    ignition_rush                   = {  93230, 408775, 1 }, -- Essence Burst reduces the cast time of Eruption by 40%.
    imminent_destruction            = { 102248, 459537, 1 }, -- Breath of Eons reduces the Essence cost of Eruption by 1 and increases its damage by 10% for 15 sec after you land.
    imposing_presence               = {  93199, 371016, 1 }, -- Quell's cooldown is reduced by 20 sec.
    infernos_blessing               = {  93197, 410261, 1 }, -- Fire Breath grants the inferno's blessing for 9.3 sec to you and your allies affected by Ebon Might, giving their damaging attacks and spells a high chance to deal an additional 10,782 Fire damage.
    inner_radiance                  = {  93199, 386405, 1 }, -- Your Living Flame and Emerald Blossom are 30% more effective on yourself.
    interwoven_threads              = {  93369, 412713, 1 }, -- The cooldowns of your spells are reduced by 10%.
    molten_blood                    = {  93211, 410643, 1 }, -- When cast, Blistering Scales grants the target a shield that absorbs up to 106,038 damage for 34.9 sec based on their missing health. Lower health targets gain a larger shield.
    molten_embers                   = { 102249, 459725, 1 }, -- Fire Breath causes enemies to take up to 40% increased damage from your Black spells, increased based on its empower level.
    momentum_shift                  = {  93207, 408004, 1 }, -- Consuming Essence Burst grants you 5% Intellect for 7.0 sec. Stacks up to 2 times.
    motes_of_possibility            = {  93227, 409267, 1 }, -- Eruption has a 15% chance to form a mote of diverted essence near you. Allies who comes in contact with the mote gain a random buff from your arsenal.
    overlord                        = {  93213, 410260, 1 }, -- Breath of Eons casts an Eruption at the first 3 enemies struck. These Eruptions have a 100% chance to create a Mote of Possibility.
    perilous_fate                   = {  93235, 410253, 1 }, -- Breath of Eons reduces enemies' movement speed by 70%, and reduces their attack speed by 50%, for 11.6 sec.
    plot_the_future                 = {  93226, 407866, 1 }, -- Breath of Eons grants you Fury of the Aspects for 15 sec after you land, without causing Exhaustion.
    power_nexus                     = {  93201, 369908, 1 }, -- Increases your maximum Essence to 6.
    prescience                      = {  93358, 409311, 1 }, -- Grant an ally the gift of foresight, increasing their critical strike chance by 3% and occasionally copying their damage and healing spells at 15% power for 20.9 sec. Affects the nearest ally within 25 yds, preferring damage dealers, if you do not have an ally targeted.
    prolong_life                    = {  93359, 410687, 1 }, -- Your effects that extend Ebon Might also extend Symbiotic Bloom.
    pupil_of_alexstrasza            = {  93221, 407814, 1 }, -- When cast at an enemy, Living Flame strikes 1 additional enemy for 100% damage.
    reactive_hide                   = {  93210, 409329, 1 }, -- Each time Blistering Scales explodes it deals 15% more damage for 13.9 sec, stacking 10 times.
    regenerative_chitin             = {  93211, 406907, 1 }, -- Blistering Scales has 5 more scales, and casting Eruption restores 1 scale.
    ricocheting_pyroclast           = {  93208, 406659, 1 }, -- Eruption deals 30% more damage per enemy struck, up to 150%.
    rumbling_earth                  = {  93205, 459120, 1 }, -- Upheaval causes an aftershock at its location, dealing 50% of its damage 2 additional times.
    seismic_slam                    = {  93368, 408543, 1 }, -- Landslide causes enemies who are mid-air to be slammed to the ground, stunning them for 4 sec.
    stretch_time                    = {  93382, 410352, 1 }, -- While flying during Breath of Eons, 50% of damage you would take is instead dealt over 10 sec.
    symbiotic_bloom                 = {  93215, 410685, 2 }, -- Emerald Blossom increases targets' healing received by 3% for 11.6 sec.
    tectonic_locus                  = {  93202, 408002, 1 }, -- Upheaval deals 50% increased damage to the primary target, and launches them higher.
    time_skip                       = {  93232, 404977, 1 }, -- Surge forward in time, causing your cooldowns to recover 1,000% faster for 2 sec.
    timelessness                    = {  93360, 412710, 1 }, -- Enchant an ally to appear out of sync with the normal flow of time, reducing threat they generate by 30% for 34.9 min. Less effective on tank-specialized allies. May only be placed on one target at a time.
    tomorrow_today                  = {  93369, 412723, 1 }, -- Time Skip channels for 1 sec longer.
    unyielding_domain               = {  93202, 412733, 1 }, -- Upheaval cannot be interrupted, and has an additional 10% chance to critically strike.
    upheaval                        = {  93203, 396286, 1 }, -- Gather earthen power beneath your enemy's feet and send them hurtling upwards, dealing 52,689 Volcanic damage to the target and nearby enemies. Increases the duration of your active Ebon Might effects by 2 sec. Empowering expands the area of effect. I: 3 yd radius. II: 6 yd radius. III: 9 yd radius.
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
    bombardments                    = {  94936, 434300, 1 }, -- Mass Eruption marks your primary target for destruction for the next 6 sec. You and your allies have a chance to trigger a Bombardment when attacking marked targets, dealing 46,562 Volcanic damage split amongst all nearby enemies.
    diverted_power                  = {  94928, 441219, 1 }, -- Bombardments have a chance to generate Essence Burst.
    extended_battle                 = {  94928, 441212, 1 }, -- Essence abilities extend Bombardments by 1 sec.
    hardened_scales                 = {  94933, 441180, 1 }, -- Obsidian Scales reduces damage taken by an additional 10%.
    maneuverability                 = {  94941, 433871, 1 }, -- Breath of Eons can now be steered in your desired direction. In addition, Breath of Eons burns targets for 92,245 Volcanic damage over 12 sec.
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
    born_in_flame        = 5612, -- (414937) Casting Ebon Might grants 2 charges of Burnout, reducing the cast time of Living Flame by 100%.
    chrono_loop          = 5564, -- (383005) Trap the enemy in a time loop for 5 sec. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below 20%.
    divide_and_conquer   = 5557, -- (384689) Breath of Eons forms curtains of fire, preventing line of sight to enemies outside its walls and burning enemies who walk through them for 366,531 Fire damage. Lasts 6 sec.
    dream_catcher        = 5613, -- (410962) Sleep Walk no longer has a cooldown, but its cast time is increased by 0.2 sec.
    dream_projection     = 5559, -- (377509) Summon a flying projection of yourself that heals allies you pass through for 73,423. Detonating your projection dispels all nearby allies of Magical effects, and heals for 363,446 over 20 sec.
    dreamwalkers_embrace = 5615, -- (415651) Verdant Embrace tethers you to an ally, increasing movement speed by 40% and slowing and siphoning 63,634 life from enemies who come in contact with the tether. The tether lasts up to 10 sec or until you move more than 30 yards away from your ally.
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
        max_stack = function() return 1 + ( talent.essence_attunement.enabled and 1 or 0 ) end,
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

    empowerment.active = false
end )


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
        local power_level = args.empower_to or max_empower

        if settings.fire_breath_fixed > 0 then
            power_level = min( settings.fire_breath_fixed, max_empower )
        end

        return stages[ power_level ] * ( talent.font_of_magic.enabled and 0.8 or 1 ) * haste
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
        id = function() return talent.maneuverability.enabled and 442204 or 403631 end,
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
        cooldown = 30.0,
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
            return 3 - ( talent.volcanism.enabled and 1 or 0 )
        end,
        spendType = "essence",

        talent = "eruption",
        startsCombat = true,

        handler = function()
            removeBuff( "essence_burst" )
            removeBuff( "trembling_earth" )
            removeBuff( "mass_eruption_stacks" )

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
            if talent.mass_disintegrate.enabled then addStack( "mass_disintegrate_stacks" ) end
            if talent.mass_eruption.enabled then applyBuff( "mass_eruption_stacks" ) end -- ???
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


spec:RegisterPack( "Augmentation", 20241023, [[Hekili:T3ZAZTnYr(BrvQLMqpOaGKLTte1wj7EpSRlBYfL9Y3eiibOiodcWaakzLIf)TFDp418gdiHS3TUnvfV2CA0tp97PNgdEW5H)(d3h4xe(Wp5A7ETJT7vtSV(Qpy)HhUV4LnHpC)g)fF2)r4VK4Vg(Z)42hxhMu4xeLMGd(sCQFaIK80TzlaawvuSj)3F5Lp)8ZtIw8YfpfgLKpzr66lFo95l9PE8lcFk9ZHzxS5PWlc2KFrwA1VVinnoi95K8l8NhfhvefM)W9Z3gfx8XKhMlNEFhqbBcx8Wp5C97UcOIOGGWsGdZx8W9iWx4yFH7v)(9ZCCMyp5T7)0(p18ZoWpFF06Fy)STBq0tpO9nWG)1maprHjlc3pBDAg8NJ)FV8ZNZ(uwmpMd3JfhMN3aG9hUW9A4XX)77ba)ZeC(VTEt6ZHzHb7ND5(z)PSq)Iv7NTm6lHSpPl8e)Co8a)7r4JvdiHWOHdjH)w4tr5aBnhquA2(z5PXP7N9u(K9ZEmlD7M)qZAE2YS01vRikS48wal)3BdJJbqdtY3It5pVzvO)t(X7NTWpVih)pj7N5h)S)l4efLeLVQfjV7c33vUyT)as6AMV3vkJ(7RGX)h(a9(pIkwfb6AXrW8GAArfHRX)YpruEdt8Nhhg8WF6H79xuQvM8Y6TH5EBtY8Fkmok5rV8nrjbXG25Im4PZI8H)wLs2K5eMNx6sVqGjnjlCTFeYSUD6(zxTF2iqsVFwrwuYNdlMu4mjkFIYjGa(t(Wea00KQhYBtwukmVVSFgGsN9Z2TJcHUhlcD3pZQeNaD2SQwckgELln2L01LW2a42kbPauwK5Ut20DWsYMa6jekiiC(2LlNaYOnPz(XEpNUnjaMLYPDtw4tEpUiyIdhcRNVbLx7o08Aq4zv7juTwwb4CIt1S8r8NhML5NuaqcwtG1i6xTwRv2GaMUsHsEbW(wSkeSGZ9kGNlFDubOA3Bv8kHxHFm4xEYZW6io0pimBs1CwYcNNc(Uq4wg94Qcpwm8261NkAcwgxRyzKV5L1GdKWSCVNdNtt9dIUKmY9kyfFbzu8VDg8lGEYPnSGOeGaEo9PWeVIvaEdYBzfw0akJxb411MgOIO1HE5FoAtlmNYAP2cbdz(b76P7etjTkFa6KviXHGHS)Nc9csle4DGbTTQh)gBL2PScsbyCN0SGd2MrIZtSOSfmrBGR1ftLAkcOG9PRx4xweVniSHfWAU3bD5yiD50x6YHHUSQ9qsuOzPjqHU2aIZAaSBERsZFY04qBXiHgWPlVEULm(A)KTyqCLa0Sik5BhPrPcjidvktvaXEjbqHFQqCcZ92M0tk58esoCEAI3AIwDEy8scwB0M1PyHiNLYw5N7vtDgOblDDlezrqLdPAVw1suFJZOCuP5oO5eNwqPvaAo3OxZXvRMJBhAoUDP54(1qZXrHMJZ3wnhh1Aoo60CK5JPBnhxzo(ounhxuZ5DD6ZHtB7(T5HG0AjYcX0YP0SK7vzODl1arG)AyZQEQmXmYqLca5Xp49HNfc6ZftYlGTkdXjlZRGrWHQXEmXnC1e4twGOoI7vYgqny6eZTN4ipPwhVuawpCRBKmAXnjNfTPum)XL7NLMe)c(NH4FaBqe3Rz1dJwlPpfbpcKgrjZ48AiWnTLc)zw5J1SI2p7Va)ueG4KWOYX7gBZtrZtg8GANVVt)ACA09u7C4D9zK2j)Evu5mGcGVIANDKMuhz)0tTtxwTtqM)Ho9i9BEC6TmDi84iNxX6Crm1eh7oTH)nB0ElphcBu58knYtscdoQQehsUER8tcQFkQFqTxzwhftl9CS2)lKDdBp5gU4vKcH2eL65q)naVcily6s3eMeM5TmkoomtwjdtHTELhw0sX1RE8VfVnKk14kCfeg7dAd399uCQ1rjrR3U2JgevQWvWSiihGRiCrbU59sMFzLzrzvNBp3IqyEL7AKzALu8PdErEb4ct3eXxBQUNOolj1Dn6RL4GhWYQLerkOoyNG)tjuin3vw1NKSZhoXlO1Dv76imBBPYMKDK3IRkPgGN1ry(murakRFZMTBIIXLc8p)sErMF()YNRoBOJHyqfgRN4YyynLtkpqnHeh9uZinBYRPcI)RTW(Aa8g95qAsKykeeU0FBCrJrq9d9pXc7ZcDPcunavf4KdK(l6LV7VkbpTmeHOCuzIUQjkA5HRLrpz0(vLjD1UUQrYgy(8wMM5ffqRpux1U1G)b4Va6wGSzBPAD9u0ixU3UH8hR0VpOX)(AV1H5545knbqq0IOIQYrvhXRCBRLGablZYlq9inLfytZjvXve2sVs1bTAbBcnvvPNtoqjcWuEW2qDgy3wVF1r1ffy524yybUyLFgg2fSNll1iTp)RkXEJyTD74S1mL7zkNdPBGV5XUq4PSkXL0hRnU6P0YOwO2aH2aR)fK6ZMVcO3k7An1K9kBXkCWj2NsK7uEs8t8xSklnjkFDRdKAzKufUk5sLkrTqRuzr6Pgv9aNi7SIi1)a0tEzrmiZqjxro6xrsXd0ewhpe228oY8Jc8cFcxDRtFkepM4jHFjIC4IJKuWzyxJj(Fj3BDy2ITWee7f(4JYYNwbGvSCztBusv5UjRYAlKvWWzc5TizhPsIUikpTnrXGY8mTo(d)EHeI)G2CTQK0PaAI1qvyxktmmXVkdZb22OD5TWh8cu(p8Wd6T84ER9rJ4io9XOfA38GwCuEOXYYvT7CbQpqKY6LvpDzBtuoBS5DIZkti1GWWnvMzCHvDuECFrBa(geDhwLy7qWKbCjq5tQILC20lzb)8OLtRppQYZncdjU0ViC04tufSC7MD7qP(Do2wsIQXHigVqJ1wn3Uv7R21VdFS)ow0l8bpBXKTgEokhMkYf0D(43nTksWPUJuE84uaTBNc)M6EAh3rvmW1PXfHjEHRNd7auNwSKd0T9mdR8sR(0ghz6biIILWY(pbsXKEjXOAVKCSuoQoxQ6vSKGd3xHDVI0hU3HvLcbQK6ls9cIcjwDuoEodJw42gItPhm4XADens6XS(QXYAw7idIppRodkGreBgc9o6vZViTTdoxTufNTkdfPa)tRDJP84Rn0vALgGQtj4xAAaJP5BmgDSSnmSjLsVxzHGasAXNbofxgOsBVM6ZdUj92U3T7qjZ10scLUsvNJIMhLOSirWGRZ3wBN0q)TyaP(fKK5HFYip(TQpSRscTRoJNXSSzv7l4AQnxR(O84iS7AwKuPi6ha2)y6HvJIOLFb1KrVqkdIRnx(Kz(QU26I6pXGfG60P4waYnz(EcqyTmpR04HQ1zsxNMLL(mO3f4)ctNUyraFS22y7WrTvv9FSzJGOZi21MovTQike(dFX4em8ca0UgXA(gsueHTZXVl(AVlngE5Baeal)y6IuRyu2ceajmfHBuKupjUaJSJrZIgPENe1hMVqXjO2XJ4AQQU3tLoiKRLxfaJ6WE4UYgxKQUDWE(8bVQZJb1401ebcFg2mkSDgAj8lHl2wuxOIV5lvbNWmLIQHnqv(sx11cLA)JZX49KSAQsEMk)b57(diuk)e8pozMvLZOUDs1SfQcsjQwKUEUFBrmPqgwOoyBLDvQUgRbQkV58GIIMBa(Kx6FQI6Dq1k9PECYcDMNQUk4RO6QhkPrC1kDB0YQl6brXYkqRbYjzhmaNyIpJ9U5fSfKkB78x8EEvy8gVC4pJ5QffbMNxfLVP0WikzHFwcS1zVOfPITcKQcxXuPC(tYtwb46XYW1GLHBFwgQR)MSLHl9YGpH1ESm6QVXf508hrRiekB3AMAs8tKjD)SOC0996nXrlaotW57N9NRop6)t)YxebzcXYZSwwn(6XIVRECxu(ODX7QDXltg2UkeQuxpwgeM(CyAHGcW(oWQ4mp8L0Ka5SUMtOwAj(6X862N51LBE7)bVsTEXgdeRTmgETPCTAh)R9GIzBi6asQ0H0SgslVzp4qUDWHKn(x7bvZHC1XHCP4q988ofz25VKSqA5M4Kh15XtjUL0)iFh(6ryxN9NvLyXlmohMu7jVTro5iTSG9K6D7M6Dvq9s7MPEs9kYaWuQVUxHEOhDJwpwFSDoCx6zTvpI1CUfdM0p(JnGjFjda4Zs15Xw1VVlKd77mn2oLN(QoiAWLesg1BA28UaDlv1(sgamMU59kks3s8BQGUDAP7siCQlSb3XDg)um505O4nL)MfzD4yB3u8cwLCNgvCxPvT1qvCfDfxF007Qp(ewAyDv44b6xBkszexBmBYNgP9mxjnaBjuxM(zVZ3g2)y625X0D22f4RtCuAr0)c(hFe28eSZ4ffInOnGl8KQ3pRmB0ZjV3V4r(J)6ZaJGuoBsVANKMTgZkLC4QWVLUF2JB9X3cXqyuSygLzYMb78UyIEFEkIGRqwjldxd2ghFnYP2d3nsRNQH4TJJPUDJItUwAvpnCAuvIC(TIku1WYh)qE)r1uVRUR3txv0HKSsnim9Mg1msQDJ6wWuS(BIvLeneH9v4xxSv8)1gGRJ6OQPAO0hwtf3y47EpMksY3aFQlp8jAkXANvPTfaqALfdgQ(b(BkVFfuCqN6QdT26flJX9GUsWQwJ8R2Aw9QzSr8e5kKwgWpaFWbOvA465z(lcBkcxJzSUM4KQty47JZwwMOT3C92DkoIg)GxuxVx6MsLR3uKOvxdjttfqFyWxl70IBPqXJV6AA59YuGHcsjihLOf8DIIuYNgvuhYmV8xZXfR5KNWJLR9KNUM(GNMhJt2YTzjGSVfHxq61SM(p0IYDclZTYDIeJOozXx1xw87)vjh01eoioM8EDPI7Q66kqj31TVCxh3FvYEDOzVAzHQoThLSqNEZcV5xLSqBJzHQ6v7FP7gv7AJetQGeieVwIAUiNak9z)SKY0Hjx)pr4Bkqr11w0BkZG8n7NLf(p3grUJKG8jaW83wKU2N8E0SyLFYJGn((p9FfHV7Q49F0pKMatfz43ipS(Bk35JIrRzeauJD(Ivx4wwwICtGUej5Nfx5ZctQlCOxA6rgIxXmN4qU6uRmCggeE)vVsCff4Da5kkMHJKRS)tsmyyAc5(z382xzDBP0B1wGhekv2RabhLQ71YHxQDJk9TM3cdbTnH3pdEC(oECwvOj1h9BZCWu)kvGA0KP(aAfMmTGY6zuHsoxlJZXYu0q5ci)AfiVURR4rlF)9AkcfBpbEfiL9VGWuOql9WPzvQ9dinRqNNTl44qV8wu1uu3wDmo0k2BQcOuqbV8jzsUJdRst8ZuepeSbfO(yydVFWrPRI8CyBHsEfyP9x5xtu)AM9HkKFePFinGyt)U9MEfsuH33b03WRVhtbpe0bh57qP3inUOeOmFku2GtYNlDGB(KAwC4bkOFNmrvqz(uyotStWnFsnJjAEYmcEuPLykpoq5snDGB(KY2VwYNjbymh9kA2l5ZJAGzMWpOtIzotStWnFs7GjkhgZrVPmXoaMn4UToXMSEwtUmtbKSZLqOz6vNrZLoizNlHWPnRl6(OqYIHB4(Gvs5SIQpeDf4waObFgogQVu38fD0Elidm2pg6ggl3VaVy31s7SG9kmlhZAyfYD0r91amOy(yOySkW6i4QXhs8QKCfYqTX5IwdEHH7dw7WCubqd(mCmuVktsPGmWy)yOBDMIkb7vywoM1GCZsjamOy(yOyPgMIJpK4vj5kSHXg)ic9LPeFjYG51f)kXCkSbfci4l5rcGgvn73OX6MGV77CCTNABvtmhiwQqsl1kuwWgXx38b5WWYNhA8ReZDZNDf4qsMGo5ZMHfb(SQTXZ2K2kSsOgML7QU4aAXQWWMH1dvM9AJFtW8MS0ft8tEXlytUoSRcotxbMopOsK3bGFJtBOJetgGzqPVBdW9rKyYrJ9Et3hAmHxB8BcMntFunCMUcmDEom9(ES)4duVVhZWbO)0PMPb7a)OX(bq34BqHeSv9ZMHfx5yX1iSiev)eLj(yuKA64EJeXvZ7c1UDNWX9QFkRD7upt6tkGAqgZaRthBp5TNPWn1PxPAe45u8EnzzD3y9jcQYKKNwCusloDslLVRsWioNXqnOG)cofbRVZX22YQjVRFflNV8xqY5l)fNC(Yk5CRjVMdNPhoo00Cm9Wj23KZUr5S2JKX6iS3amdkdFOg39IN1j4MnR9iq(bYZ6Xm0BEwNkoVs6z9Aw7e8QzL0GcltJJtXMgb7aHm)C8(2h)CGcSMGYy6K3RWYgvE)m8LgdBD4IA4ssjD3W2egOdcqGd8l8N7Nh(73)js3sJfAsrNrqUnxFtV6kcvhOvNm9Jsg91ve9)3wPk60LJOBNE97SffZWWtZhCZf(nGhqRHE8T3Gk0FOvK6vg99bXvVWf6WBli9LQ7bYnaTDlknOjlg6c7)kJ((GyvCBPG0xQUhiVbTguC)TB0PCqgLHshcuAaYO3PNeSXnCFPWEyw8QI8orR51TZO6dE8tdZEu5rVb1pvIUb)OdoknazAv30FAmgqH9W09vf5DIwZpEeJu3o(PrR6M66s0jZPBd9Hf5gG2bj4QbuDVsK5vg9niw92T7KB3Tr0WICdqB3Isds51aQUxjY8kJ(geRUjA7KB3Tv5WICdqB3IsdSknGQ7LzZRm6BqSM2tUt2D3MLdm2nbVDlnnWW0e6UxMoV24FIIsUTexA9OEBkEhPyUJbAiijJ1ZxR8J(f9tbEzUmh4WR0l6bE8QOgvhn9QaVhn9QO6phn9QaVhn9Q4nH9OPxf49OPxfV7RhHDX(p9rILkIU3Xw7D0C8H7bR0v4vL39(HXGDo8GFCXlx8)ecocT(d7NDF06FaVC9txgf3CFYLpP5Tp8SPxwFiHLFwTAUd1oV6v2FQZ5PBMsU)72)PUFEz3C8niObN2MGkguqUGbN2CGMsNMOLtprz9kFnMXZAgLNogcYG((S)azHvrdAVdNRwvmbc5Fpa3TJzyLV6ECWj)tXypisxfePREIu)7xihCkiYFx9fQz3xV79zfvFTVlJRR8Gq4yRSPGWnOI3US(qJUYPr9hwdhxvfnQ7nGRp0i1DaVmwPSxeT(GExLOx575wFqFv7Wiq50h78UDJzhG9qRPf789qM0XEQ9fMq64RWNv6i4jZAjPrCA)IY3JLUR0LURQLUSECGwBs9s3TJLo)7KH0ruT0DpKLEzR2G(TjxtXvSaNZBV4CNAp5TNdAwbrioNQSnQO0mesPVUj47dL5E0uMqFCjzZJhcLvFHdZtBU00MdfLDm9E2b16zhsNNjJ50oM0cGY1ZxYSlOA8lrddd7dnzkuTJzcLjZzffLj6TY4UsJRP0y79qtuQuCTMpa6wYuvkhHLAVBk7IHKNXV8U6VnHzEWCrkoGM8jgPttNlFc1i5eDALyw5JnJAmDcTgjtxwV)hJuD5Vj0fZ()gtqJ2l(Cj7OyY1MGvv3Z5gVffmWp2KxLOtYvBU8ht4wkhLOiGQUMZvn)0xt34oSRGbg5FUfib6FOsMt)tC2fGuY7zSN3QmeccjQD4VNMbBVGmwDPjvJh6pNV82wn(Ov8rQujsP(EbsVNuj3nETISQjVAQB1VPjWBFV1iUVmI3n1z0jKvUWx0skYdKc54vL0IWZzUktbpgO1zEAC6icsAbSEvERZUDpc7HyZikrEly36cgJJxUnogiYfRq0sUVsVT5t69vuFsVf)Olsb3OXLRd5xhQx0aN1TtLcyDKYtB5D6Sd3Td)mSoI56B92PxztNBbdZF67b)tLIsQBIWs(M079qGNvjuUfesnmbUVR5Td0CH4UDJfT0BfgO5C06nD5s87)EPydziv02DyIJJgFc1hv31WdTg)lHFbRz1iwxWs3oUjBzh4oYMKOKBNEddrVjLOFd0PcUPTkbanw4)Mzt5FLeJLZvuRahrVE9PsSsRs2Cz7oqAyDVqiTClnyCF1ozklv5DokdhLU6x3zpI85GMcBbHHBQV8JXuGAhr8J4FDJmYEHrc6uQ8cUDdOVamR7CSze8MJAWlYtO6mOsYIBLMMCRIf(GTvmj(EvubH5wQvxJvtTpf3rIgHIar5iJZgwZt74oswfY7w3y5Cg6N(tT)i(UoDK6YVUBNIBdB6OTvuTqWH2Rb7sxoIF4YVRXO5m7jUJ0zXDxT5ZOHDrvt9MYsL6p6U2FMpjqCxOvNfbNwQumn1UEL0MW23sM94tKP)TBN(pn)k01BvRTH4(DKG0bXtf4DmoxyHMY5sl8JKW3M68wQnpQkrAtcijsaJhRn9MRbSktobX4zNP7aAu8JIp8R72XsrGFqbp9VQKLmc4eEkOXSLBYLP989JDTpZX(0AlEMBFulRZgR2FAhpQ1DG8AuN6LUmYuUVMouAvC3DPJKMOn1MrBoeVPUuEhA)16C15)i5mQjVsQF3srcXyGxUDbqsMsK2iF2ZNkzGMVj6J0OKC31mME1FVZjYxTUEO)CU)vJuPSVP2(fJns)3hRCxSir0zsBLzRrTn3jTzTICZgCsdYY5stGsHXKFWlYjqQn)vIsQNJomZ1Y2niR1)1JKDE563QwBykLbFuAGF7u0a)6tLD6)xCdS5pRk1hHpanwMTMVQ7187)MT8CvV8uLhNHlB3Ux2qMQFRw3o46(OwFogS(U5B26Z(OxFV6MQkjqg)teNANXwkV2ac8H12Td)CUHHBX)xBoFCHvLgQeZVSY5C1h9TPonzhk7dIrLHJWxkqljKVKi(NOWtQ0qZ1)O4NOKrkwJQc8ZVeLqSpX(XTBqjw5e1yLckA5PLjep9xEpAnjsLpoJVM0kR4ptuq5z1bzQpYWZzq8qcQpEfIoMrNbHgC4c2sAtaMK(TgFjq2mDLcRJ9OtglVM3ODNYsRyna8i3bGh5y1LUG2ZNq(JOOJxms5XrY22LVHqN3U)t)U26q1qlbPEkiaWRD(NflG7Hi)43lgqnDYjz7sOdDMbnh(P(k7lgFfSDm3tvwPgRtf4Qx42U9T6nnE6yj1eQzI(GT1PQlgeATjto5crCOtVNz1CNnp43yZBBWY3020f4UAKmCZgoDSL2Xcv95GL226sBFOqpXITKVIjUPLISSQcbWoJmBGqqNkpoTO(4LDykOg)zXk7K8lB6nD950OXhK6PMwc5ejIgmmhfYO8sZmj1oNTuTtlzNfTSgyHTRx0PTizHq52KwClTrrUJnTq2sfPxA6kvA6QP7luknDhEPPdV005RJ00PZ2rsNjOoPPlJHFpKMy4N)iMz1(z4hnEi1QYxOK)Y)Xp8JT9TYK9Z(yaKlD8ly7PGDEcW5Jd2pBEi26l1hHB5xzYQBpoGNHnWx19lt5tH))8O1BW6zmZhVLzYdXZTI0FlRGy(yJVqUgAIweIR09ZcIwcrVlXoI2F8VE)e5rnPtqKjqncG3IaphNRDyRYwRGPP9rhPqNO5zu0usS57Xl7K7trCsD75K6QtHXQ8uU(4sStKqrxAsOytjTFgOU8uua250(LFirpVgcStKsH)mR8XAMaq)a(PiaXjHrLJ3n2MNIF5uzXJAVjS54iePOpT2LzHk6KxRvaRpUlFKXSq8ncPSuL3ELTIZ)5osIhsMt6q2AYfy0y6d23EIJyw0uk(6s(tTWWvUW4y903PWqRI)oD9F)GimuK)KM8Jmqy4AMW43SfoiBbzl4EZV)n1DJv3LTGP53qKPFoNoE0ZH(Bst6mdtK88wbjp0rFmv3Sf2tUHUCrmTaZz951hJPfz((MFw57Xg)ds)YGnI0PCA3vP1qtZx40tmY82RzuJmEx1gLtfaOCV4ryhSr(iKRKsOpCq5S(PxP(P5RM8Gu3x1thDkNKpB6p8)b]] )