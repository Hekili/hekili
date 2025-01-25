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
        cycle = function() if talent.bombardments.enabled and buff.mass_eruption_stacks.up then return "bombardments" end end,

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


spec:RegisterPack( "Augmentation", 20241206, [[Hekili:T3ZAZTnYr(BrvQLMqYIgasw2BIO2kzZ9WUUSjxuYLVjqqIHM4miadaOKvkw83(19GxZBmGKYE362nv86LtJU7PFmt390yWdEp83E4(OWsYd)KVR)1E(U3mX97DF)vx9W9LpVH8W9Bcx85Wpb)L0W1WF(73(P1K0YWY4SuCWNtYcJqKuKTnFbaWQYYnf)238MNE6PjXlE(YhjXPftwKT(npL90BczE8ljpM9zs(LBEKCz0MIlZZQ)9fzzjrzpLwCz484K4YysXd3pFBCs5hsFyUk(9DxDdWbBilE4N8U(DaVVkokIubmPyXd3JaFPN)LU38B3p7(41)4(zB3G4z)h3)XQbDV0)kyqpVjUtEl3p7z4zOi8VKdejMKUGSF26SC4ph))(Mp)A(NYH7X8eESesrrlaUF)L(xdpo(VFpa4FIIZ)T1BYEIKtI2p7n7N9hYjHLR2pBz8xi8pPp8e)9c4b(3JXhRbqkJXchYc)vYJXfGmVaquw((zfzjz7N9yXK9Z(uE22n)U258SL5zRRNrmyX7Taw(V3sssaqjPfBrs(33SIe(yyY(zlclklW)v6(zHjpf(msO404IvDi5Dx6)UQjR73JSUb69UkD0FBfm()ie43)rC5QyWqmjgOdAggxswJ)LFIAztsdNNqIE4p8W9HlQmztFE9wsrW208WhjjXPFkOytCAucy6UihE684q4VvBbozov4fKTmGacPj5K1HXOW62P7ND1(zJan9(zL5XPFMuoP0BsCXeTeGc(JHabaEAs9dfSjpodO7Z7NbO0B)SD7yqO)XIq)9ZCQWjWNTZQLGHrq1uJFkDDfSTaUTwrkbLdL29kMUdMsUuqpJYbrK5BxUCcOJ2KLhMe8u220iGkvKDto5XGpTiAINacBO3jvw7FQL1GYZPzzs9wzLWkxcMMvps4CsEEyAjaj4nbEJ4IUnwTQgeW0vAmYlbX3IveWdUiOeEUI1XLGP9GnXRvELHjWI2tEcMhjKWis(KAAwjcNNbRDHWTm(tRkd4XWBBMF64jyACTMPrXMNxdlGqYlcEImNL7pj2sQy3RGz8L0rX)2fWVa2jN3kcItbg4PShjPbLRa8gv0jkCybuLScWRVllqLXRjbfFoEthmNZ7P2bbhB(9UnK7mBzT61amPRqMdbdf)pscIYkLKDGdTRUh)gxT(P8ksjy8N0oHJ2MtdcG6r5k5I2cx3sm1MPiGs(N(bKVSizBePveW7U3dF5zjF5nu(YJJVCAwHKAqZZtGbDJdKG3a438wTU)uY4X6XOGhqYv0qBfJVomDlUjUwaANevYTJ0PuJgKJlvzkGyVIbyWpZwCs0EBB4jvsEkltMNLgSMAvxqswsXAR1Sjdle58C2QWIGgUZclyLZBPDwKm5qUoOZSeT3eCkhv5UdwojzLmwfGLZnMTC8nA543JLJFFwo(FnSC80y549T1YXtVLJNjlhvRX0VLJVQf(oulhF0Y5D9UMJG129BliG2AjkcXWYzSSuVQYPEzPwiIcxdzYgOZfZkhvgauV)H4A45eWEUCsrjKhnSpzvCfCko0moGBFdFdB8PAJOE23RsmGwWSbM7oXtDqTEbzaSbyQB0iAXmOZJ3uPM)WY9ZYstEg)tc(hqcIyUM1pm6TK9ym8iqyevcJx3abM0wg8N5vpw7mA)S)m8tXaItjXvJ3p2MNHUNC4bToFFVRRjyrpqRZt)sFwzDkMRIUfdya4RO1zpHj1t0pd060N36e05FFVRi9RR4myD6Pyfh1Yk(fxKdnXZTxF4F1hDW6ZtHpQAzLb9jnGbpDvIdz3GvHPrnpfZpOFvz(fkMwTYX6WVqZg2DYnc7xrleA7Uuprc3aYkGTaYLTHKsYdwgNKqYvvYWmi1Rcszhh3m7X)wYwctOX14kIKecwd39dmsQ1XPXR3UoGfeDMW1WSiQaGRKSOetEVs4xvzwux1B65ouglOkRroYQO4th8K8syjmtesS2u9tOElj1DT2Rv4qeWQQLetlOo4NG)Nk4qwPRQQpPiZhb1ly1Dv38GKVTYytrg5D4QwRb4zDmgpdZoav1VzZ2nXj4ub(p)srzEyX)kuOoB4cdjGjmwpXLjWCQGwEGggjj(X2rAtYRTcI)RTqEnaEJ)mHLfPUcrKLHBtkBDcAEO)jwyFEORmGAaOUaNcGmCvV6S)Qv8S6qeIQrvP6Qju8Yd3kJLySRRQs7ACE1GKna9cwMLhehXAp0u1U1W6dWFbSTaDZ2kZ6gs0QxU3TL9hRDDFWI)9nRwtkkWZvAcGG4fXL1LJQzhVQ0wRab2SmVOeTJmuwGnTNuLqryRwvQztRoWMWYv1250duIcmZkyByodSBBYxDutrbwUnjbMGlwfMJB7c(ZvLAKDn)RQWERATlDC(AMk8mv0qzc8Tp2LspLtfUu(yD7REoRoQdQnWwBG3)cA9zlwb8BTFTHAYELRCfoeu7tP6DMvsctdxSkplnUyD3cin6iLgC16LAtIgLwLXIYtnQ(bot1zf1v)JAVAnMfSIwmOUNxKa6yutxwGRdPOydgcdap02U4uYdJJcipIsJ1zpsWZCEc5lX0dJCKIcudzzMg(LIG1K8fBbcKeq(0Nuf)TgaRvrQiBCAD5XPBm34rTcgoxkohfzWQy3iz9VRngsmUZzn7xjM7K0(vOpANjmBiJ249uVnnJljgOyTJ8j2xQB6Tiew1O6)iapy4QJhUznDehjzFkEHXKnmIJQdzwvST9h7qZbOuvFTgYLVnvl14JtfPk3wWreYMA3sHTH9e3hwA3N6dkc3dCzyjHB1IXgR6A)MBCM7LXBanfe)bixjvIon7DBZo3DNkw96q6ppTr2Eez4eIu1HfqquSl2XUz(Y5blYsJIB8F80hWxRba3ZyNb2s6X74PB74MLAvSO591ZHGYShU3JxLJavjJkZcIIjuRrghYlWvr972QqRNn8yDoOJuECLVykM25okG0V)aBwvSkaPu6LZDUDiCvLGg5jT9yqEPJRfcGKJJ1G)PnU)goMyNHzKORKN)CZizmROBDwsjOSjRNtYfKC4oomEFbv1CbyPfFgewcb7PStwAo612ij7pXYtLA3OAf1w63W1WJsTxuOyW55BBCLA5)omGC)cACZWpz1I2DMp8ZsAIFI7vYLjWylcb)AM8y1FQzcm2DTtsMORcJGLiWiRQhfrR4eQn4zPDBvm30Vr(xH5wFC)zwmbeRRJ2jGAxMFGcew2WlQCEy6sLS1z55zpb2DrHpZ1ujouWhBSJXoCu7uxQfx(nzm5e77YgZr9Mou5tVXcfbODnI1In0nAKYCsmHzPTsk2aiaM(jS1dwZO85IhMI5hvwv6gH9o5hJvensFq4nNBUuDayswqEovxI5PkhesvlOgGr94pCxvpcYuImiDPqyv15jGzC2AQcrxtFXvflz106WIIGMsUjRK4gUIFlyYwT3uG1lvU1cPICzxA009MT0DvPiAvPmUrib75zRNhMhHPBwWLIDt(xTIRVqwSTSPskvSL1LFSoJqHky6OoZDFD9MeFDi)v17xj1lzXQmABOsf8Ccwr96Dg1R6YjPTk48780BmI888381SKIMIV8TQKi6tcHPgkZXa3PzWuNdmtUaQRacWOmB4l(4ukRl0FtvtOTmcL0Y6UaTT6k8pdYW8XZj9wE72T1yQwT3dAoOjlWN6JlJPq4h05l84aonUEZj10PEn8QAyK1OXmPSusQolHdIJvDOgwONuDyAcQjXLk6xwWxu28TZFo4PvKKnbfWFMiupwkmpTkUytLJrC6IW80qyTK4fzYTpNLv5LcOYEXVBUlDi5QQv9aMT(wmB9hYS1uPQLb0YzRp7SvCPNbmB77n3qwDi2KeYqO9fEGRza(jkr3plUa3my9MK4fGam617N9NQ7iK)ZWQxfiv66QUgrvvZhWKVV3YezTJXjVVXjVkDy3SqQ23dyAqf6ZbYcBXuMrlT7CYZzPrQfDT9iIYIMpa66pe66lq3H36dmZxS1CXtRb3SUsjWFisYJ)1Eq5yxKxNsP2bF8cLhyWaKq(9iHun(x7b1lH8njH8zKqdSJdKf2fpNUq5XeiOpAJFVtDROdU(o8fuYTjwsNA1sajPaiQ7K32QN8uEAfdK797N791W9k7NWbY9AINWwUVPB90DmbQuady(X37(9zNvzPEMK7Chg09EniWb9kKFdha4ZY07)onVXz0Jp)cd(ov9)GjiAXLcwgTBARPNeFR00(nCaynFlUQOmFRyDtn8TxhFxbHxt9o55(4KhtON3nJSP63COZdpx32AAYBK71AI7R8aTS0extFPoel9(6KwPPgwrdbzG55MMqgX5gxjdyr6aJvYaWT1l9a93fFri(JzBNNW2BPxIVq)XzLX)l4)4dqQyqE2lkLFfjaCH9(X(zvrJ(A6BEp20n4V(eiiONYf9TLinlFngvkTDfGFlB)SpTnedvNaJILgPks2Cip(YjMxZtZo4A0vQIW1IKcfp6mMmcVr5rizjE7PXp6s7CY1kpnhljJUtotmXwPdBP6XpK3GBdNlr)vpQV6drdwPbe(6Q3rrALG03e0YvZt(WkqhriVIWMZGb)NUn4654v42KJ)qsypdxXQuo9u1)SChuHyl0Q)u1oZWjVmAFphEthaG2kpbCudJc3uD9NOPfjmD8ugpgjvcoMY2kFYm6Ti)QnN1pBgBLmrTbPJfYdyn4i0lLSEEE4csBj9ADJn1g1m9wMyNu3jYK99MB2VtZj3gg9S(QhZ2w4Y9ELOvDdKCn9eBpICTQMiPJdLpv7Rz13lZabkOLGyuIxi2JzkzFwuX07jI6FdDrIHdKgpILUdK(A2ZJEEcsSLBZtbDFhcVKEMmTDaSdZYj8c36Ltu4e1Ri(QHkIF)ViLG(2ibXXu3lE1sxDNDSwPRQ(l2O01Z)xKIxpwXRrrOUZNvRi0BWIWB(fPi01ArOUJc9N7lJACUr3tQKUriEXGvFpR5cXPE)tH5PvHdtVaUIX3vNY6loSxvfb5R2plN8p3gtVLYG4jaWc3wMToK(MSTyvy6NaF89F8)kgF7XXBGSFmlfifD4xPEB9xvL5JMrBeeauJ9(ItF4wvuIceWuGKIuXxnv4cDra9kdpYs8kh5KaY1hALLu4Ki7V6fsQObVNqPIgkCKsL9FuHddxB9pm)M3(cBBRKFRtb(KWPQArhbo10lgNOw7gD2BTVhuswBsVHuI48DI4SUqt6pi5wAWv)kDGAfX0FoUseZiO8RmQXix4LbrqKP5vfrc5xRb5nnJPiAfFZaSfHYn7GObK2UHqIeASFoCEwdcpL8SKjtfg4Bowb0RUZ1Tf1DvhtaTYTSUekFVAuYfCNawvg4NTi(uig0G6Jrm89NCu6RzFC(oRw0awzBx)1e1Vm7ZAg5hD4h(AwkIRPufTIv1pR2I4t2g61KrZUXhp)RbX8nDQaMv3rQVYCqiTDS4RguyiASioHRh)YVlL0EkSbKi28yVszSikGYEsOT3ZutltGBprTl2h7d0YiXuCenQjLAaTpIUE1w6GYEsyV2QxWTNO2PTSpsvJeZgTLba5iK0w9SMfApuz1ghMa3EIY31FQPKem2JEnTmOA6OhyockfCdR2YEHyVGBpr7riQgg7rVTcXEaMperxtQnvD(OADMgi5PLunYyNDwrltqYtlPGjBNxSDJJIjJWWdbR0IIg30kgAWTeqNCkCmCFLT5ZM49oqoXy)y4BySIWs8R3HrENhSxaQCmZHvO0Xe33aWjfZhdhJNLGjgUE8tjE1YUsXC3U4IrhEPHhcw7XDudqNCkCmCVoxsLGCIX(XW3MCf1c2lavoM5GA3sfaCsX8XWXkDmLh)uIxTSRukWTRJi1DVkwlrfmVS4xlMZGmHOGGVQqPaA01YOJgBIaF33557o11PHzoqSuJKoUvQylTQV(LdQHHxoFQXVwm3VC2xscPGa9kNTdlsYzD1kGVv)14LWmmV0vFfimIvPHTdRhQo7Lg)2G5n5zlMeM(Cq0MctyxhC2odSLoOruWbGFRdBONatobuq7A3wG7JiWKJg7dMVp09eEPXVny2o7r9Wz7mWw6Cy29di)4d0UFau4aSF61Y0ImWpASFa8n(E4OaB1)SDyXxnw8Tcls7QFM2aFSANA299gjJR23OUD7otq618uo72PNsMdkGzqo3aNZh7o5TxOzzQZVs3iWZP5TJZX5UXMdeuNlPiV4PLx86LxQEJ3Gr8UGJBqf)LcgcoFNNRRJtBCx)cwp)MFgPNFZp70ZVPwp35YB4GzgWchgAXQbSi23KZUrlvhqWy9ST3jGcA3(qpUhKmRxWTJQdyJ8duMnakmyzwVgoVq2zdIQ9cEnvPTCXYSKKmS1JWEQipSa)UPGFwNbrtu1E603o1Q2DF)m8vpeBa9Yg4sZO9RX2uoOJIqGJcldNhwq(T7)iTN7XcnPPxpIXBz7xnO(8q3bA1Rq)O0rFDvr))TzQME35i6zUx(E1rdfo988b3IQFdKbSwOhF7nOd9hAfPEHr)qqC9RTJj82bYq56bGClqB)QslAYItDH9FHr)qqSoPTsqgkxpaK3IwlkU)2nMmoOJYXPNcuAbYyZ0tb2egEOC4aClErrEVO1(62zv9bpEYWLJQi6TO(PkSneh9KJslqMrZnZNgJfC4aCDFrrEVO1(JhXkZTJNmgn30xxIEfo97OFArUfO9KS5QfC9GcK5fg9TiwF629kT73j60IClqB)Qslc51cUEqbY8cJ(weRVjA7vA3Vx5Pf5wG2(vLw4vAbxpi3Mxy03IydTNCVI7(DlpXy3g82V20chtB47b568sJ)jAk52sCQnG6TP5neK7MQOLHumM2xOm149OFDr1GxUReeb8Q86creVAQr1rZVAW7rZV6Ergpw(vdEpA(v3lU4XYVAW7rZVsH5E0(f7)4hOEQi6EhFT3r3XhUh8sxHx4I3hssa)C4b)WINV8)Hale6872p7(41)i(bFiBzCs7TsyXK23NYlM(MMdj814Tz402BIVxxFXpm171zBMsVff3)X(FEvFndArqloDTbvCOGEnvoT9anvsM4LtptB9kFjO4fTJkYhNc2G9BSWbkcR3nO7MaVEwXTrO4lC4UDCdR9DeuaoLVAFcWO4DYBitdFntdFZtdFlNg(wmn09QfU)J)MMR21()qdmK5CZhGavAoThMIGyNpmgHb18gQneE0xnpA(aFeKP64rtVfDdHhz(AeOsuQ6LzBiO3xl61(UYne0x3snsCo7rxVB3y(b4p4Bw1UyFOPCSh7EPluo(k8zvocE6UokAMN2LHgYu3x5u3x3uxvFsWAnPFQ73Zux896q5i6M6(hYuVQDDW1(Pxy21IaVx3Dfop1DYBFD7x52PABflgldP0cAAK(HWz(hnNj1lyksa9q4SMR(ArEZNL38y4SJP)1oO2x7q6EnvcNUXuwevH(gtLFbtZJj7yyzVSPYGQBmB4mvlwXWzYRwzDNTj0yB89VOngvAUG9pb2wQmvQgHNBVBk)KHgNXp)Ue6TryEWsrgjGH4jgzYsxiEc9i5mtwLyK9JTJBSLGoJuzlBE9hRmDfVt(LZG4gBqJXRGFfzLm5ABWQUBCFRtZb34hBuSk0zDAfs3x(Ogfbu3fUVo6ZEHXJzPxddmY)ClWcS)qToN9Ne8laTuWtyFZv7iu)9)e)9SCibe6ynL3upEy)KZl6B1UgTMVIYArkZ3bt28AvCln2PYQjEnP7SVzzWBFVZiHV4N3n1B0z0zU0NCzg2d0cf4L21cYR5UuDHvmqVZISKSruK0byZS8wVD7(eKdXMrmQ8oWU1hCghVCBscWKlwHOLEZ5E7uiYE8Bk65xTBxRGu(JjkdCJgxnpuFX8EzlCo3ovjGn7uEENSZKF4UD43j8rCxKW3o9kx2yl4e(tFpS(uLQK5oXSsUP57OBJ26wqj1keyVA6bq6gO9QzE7gNr12ZkuinccFyBTFtt5T6xlBuhzd5Gi4Q(W6dlyaXNS9t4hzxQehLl0rYZWfEdt)SdR13kCJYxJR(KTCzaGVkgcrCnrUdd8D04Zy(Q1VgEiKatiFbRB3i(TqSPGdkHb0UQisC6TtVHJP3Kr9pb(uJ1GRodiwSaRhMW(5LLz)bAmcclL2zWIO3S)qfwzDPAV2QprEi9prOTDmlycFnD5knx1T3lNeLTcG35ocLNSylIq20CnIZ8Z83c(mRWkCVRoAmyo)iAWbgn8RHR15x)I6lNh0gDL4geDTqk4ql2wPJ0xF1D70CPP3RKF5CobjlZXTpA9sksli0DvRx5mw7atz6YSGOyYDTMtx4oXFKjBX7AmSgDALinCVTIJZukpgPEZ076KEIH9H5DwFcgcwnkX0u3MzyxiAoFl1cJpt1b7SBhUedJvwqvMAa5w8zGXz2NM)RNsT4YZf2QVNyIoiHQzHhp0mE7DWpsHCBQ3BzYxuxSZ2SgUmdmESXiAUgWQk9eUTohLUd4rMDJcJIkaxc4x3TJNJGfMKwC8fLTuXaNjYbT(ZcexL1Zpm239cp3ZBwkG7QV1X5IXYrbz5J6ChOVg1RDPpNov4t5eJvLWfN7iLXwZSKs7z)n1Nz5HUFTj8CXVqtJAdLK53D0ed82nW6I8b(tJ)qM3OFb)NQyG2pV)JmyKC31CUESjSPkKYMvzyV3Bh1u0PUFQIUf0GDngTSU5ZTgNpIze5zorI7MEtpzKCtB03ZXuxZJWqeBnLUTjWR2l63VqwSTSkKAmgzQmr1Dn8UD1H6v)90AQhN0M9ZL1VkThK0M)(rEeVy(oEXCdMuMjSXPclP)Q5pYSjgtzf42iy41NrDCeit0BW8vrXZu(MjDzZGs3wCYcYY5kdBxZogHrpRMbzkQrfkzEo2yPUwz(VCBXD9iv9ssp2YTXIPnclT7ID7uCxSRpxvNXC5nNFLJtT5J0N4lh7MZx1)C(9FZME(6NE6sbYYPTF)tBp)VzZBpCEFuZpplMF38nB(5E0ZVxCxvTmi36t0f1eJ4PDdbXy32Td)GzIXuI)txIncXoQmEqmjkXWaAtbsDuduEq6BXQJc2xryTNPzLuLXF28JYFeOgPzoQl6wXPOcM9r(pFONuMvntnwRIIvF6ydZZgSgRLeTIyxiEwlApjlUDbvN6cKo6ilp)m5d)Q5ydP2ywD2AgWHp4lzmlpAoMgwlbIMPV808ChD2y1NLd63PTGEoNazK)jqgXeRPgBbJN7M6hrtNCzLXJNIItPUQhEVL7afA5LOSanmaSQDXNLlS)HO)el4aWn9kj57(TdLYGLJiPVY9YXx5EHNFZ(EY1P05CjP6L(D1OOPYiNpwrfrBj0376CU(sHIEBQ0t(UTjssdVNB2CNRi434k6BWl3m2mrywnkgUn5opxLDItD)74ySDfn2FvSew(1vrdHBBvohN6Ta4Pixces2ufjzLnTnHhx11f7XavDOsvZCAQ)9gn(Gmpn0QtNPq1GBZXGmMvP5isZIZo6Y0svpwOQXS47MltwlkMimlBYQUv2au3XhwiF9qnRn9vQn9n0vrA1M(NETPNO207RJ20R32SZKlOjTPpNJ)a0M42p)EmYQ9ZUVKgAv1lB1F()4h)JD9J1K9Z(qeelDYZyBxHDufi5tI2pBobBPRMtWU674B9nRiiZWgtT(UxQ6PW)Fr86ny9mMfI3atfe88mP9T1kypFSHUOxrtXli4mD)SO4LWU3vyhr7F8VC)e17AYvnp2nQracwef45DT3eUsj3PyABl6rASjAFgnnBhF8EI6o1RPitu)bsuFtgmyZdcYPpSe7Wou1LLsKB2U9ZaZLhJJW3iGWQpvZVUbcSd7YG)mV6XAjayFa)umG4usC149JT5z43MAE8OF1e(yCK2PyiTSODBv0RS2Oc28(UI7mMtW3wQ6I)ELRMt58oAGhkOj7w2gIfy0y2g(WDINCu0mg(Mc(tVYWxTY4yxPVxLHrd)DMEVsojkdnXpzi(ilug(2Pm(vFHdYxq1eEWY7F1C3AZDvtyw5nSZ0FVGD)ONiHBYs7nctK9cwbbp0t)T10fDUtUHTCrCTg1fd5vRKR1P(H2Fw774P4dY(IsoI2bOgZQ05uZZx6nqmY9MDAvd6ExDIYzsauLlEm2zM4FvpN0EyHX66ATPxP)PfRM8jPUV6jhBiNpuc)Vh()(d]] )