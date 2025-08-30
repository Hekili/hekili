-- EvokerAugmentation.lua
-- August 2025
-- Patch 11.2

--- TODO
-- Hover while moving recommendation spec option

if UnitClassBase( "player" ) ~= "EVOKER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local spec = Hekili:NewSpecialization( 1473 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
-- local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)

-- Resources
spec:RegisterResource( Enum.PowerType.Mana )
spec:RegisterResource( Enum.PowerType.Essence )

-- Talents
spec:RegisterTalents( {

    -- Evoker
    aerial_mastery                 = {  93352,  365933, 1 }, -- Hover gains $s1 additional charge
    ancient_flame                  = {  93271,  369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by $s1%
    attuned_to_the_dream           = {  93292,  376930, 2 }, -- Your healing done and healing received are increased by $s1%
    blast_furnace                  = {  93309,  375510, 1 }, -- Fire Breath's damage over time lasts $s1 sec longer
    bountiful_bloom                = {  93291,  370886, 1 }, -- Emerald Blossom heals $s1 additional allies
    cauterizing_flame              = {  93294,  374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for $s1 upon removing any effect
    clobbering_sweep               = { 103844,  375443, 1 }, -- Tail Swipe's cooldown is reduced by $s1 min
    draconic_legacy                = {  93300,  376166, 1 }, -- Your Stamina is increased by $s1%
    enkindled                      = {  93295,  375554, 2 }, -- Living Flame deals $s1% more damage and healing
    expunge                        = {  93306,  365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects
    extended_flight                = {  93349,  375517, 2 }, -- Hover lasts $s1 sec longer
    exuberance                     = {  93299,  375542, 1 }, -- While above $s1% health, your movement speed is increased by $s2%
    fire_within                    = {  93345,  375577, 1 }, -- Renewing Blaze's cooldown is reduced by $s1 sec
    foci_of_life                   = {  93345,  375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over $s1 sec
    forger_of_mountains            = {  93270,  375528, 1 }, -- Landslide's cooldown is reduced by $s1 sec, and it can withstand $s2% more damage before breaking
    heavy_wingbeats                = { 103843,  368838, 1 }, -- Wing Buffet's cooldown is reduced by $s1 min
    inherent_resistance            = {  93355,  375544, 2 }, -- Magic damage taken reduced by $s1%
    innate_magic                   = {  93302,  375520, 2 }, -- Essence regenerates $s1% faster
    instinctive_arcana             = {  93310,  376164, 2 }, -- Your Magic damage done is increased by $s1%
    landslide                      = {  93305,  358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for $s1 sec. Damage may cancel the effect
    leaping_flames                 = {  93343,  369939, 1 }, -- Fire Breath causes your next Living Flame to strike $s1 additional target per empower level
    lush_growth                    = {  93347,  375561, 2 }, -- Green spells restore $s1% more health
    natural_convergence            = {  93312,  369913, 1 }, -- Disintegrate channels $s1% faster and Eruption's cast time is reduced by $s2%
    obsidian_bulwark               = {  93289,  375406, 1 }, -- Obsidian Scales has an additional charge
    obsidian_scales                = {  93304,  363916, 1 }, -- Reinforce your scales, reducing damage taken by $s1%. Lasts $s2 sec
    oppressing_roar                = {  93298,  372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by $s1% in the next $s2 sec
    overawe                        = {  93297,  374346, 1 }, -- Oppressing Roar removes $s1 Enrage effect from each enemy, and its cooldown is reduced by $s2 sec
    panacea                        = {  93348,  387761, 1 }, -- Emerald Blossom and Verdant Embrace instantly heal you for $s1 when cast
    potent_mana                    = {  93715,  418101, 1 }, -- Source of Magic increases the target's healing and damage done by $s1%
    protracted_talons              = {  93307,  369909, 1 }, -- Azure Strike damages $s1 additional enemy
    quell                          = {  93311,  351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for $s1 sec
    recall                         = {  93301,  371806, 1 }, -- You may reactivate Breath of Eons within $s1 sec after landing to travel back in time to your takeoff location
    regenerative_magic             = {  93353,  387787, 1 }, -- Your Leech is increased by $s1%
    renewing_blaze                 = {  93354,  374348, 1 }, -- The flames of life surround you for $s1 sec. While this effect is active, $s2% of damage you take is healed back over $s3 sec
    rescue                         = {  93288,  370665, 1 }, -- Swoop to an ally and fly with them to the target location. Clears movement impairing effects from you and your ally
    scarlet_adaptation             = {  93340,  372469, 1 }, -- Store $s1% of your effective healing, up to $s2. Your next damaging Living Flame consumes all stored healing to increase its damage dealt
    sleep_walk                     = {  93293,  360806, 1 }, -- Disorient an enemy for $s1 sec, causing them to sleep walk towards you. Damage has a chance to awaken them
    source_of_magic                = {  93344,  369459, 1 }, -- Redirect your excess magic to a friendly healer for $s1 |$s2hour:hrs;. When you cast an empowered spell, you restore $s3% of their maximum mana per empower level. Limit $s4
    spatial_paradox                = {  93351,  406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by $s1% for $s2 sec. Affects the nearest healer within $s3 yds, if you do not have a healer targeted
    tailwind                       = {  93290,  375556, 1 }, -- Hover increases your movement speed by $s1% for the first $s2 sec
    terror_of_the_skies            = {  93342,  371032, 1 }, -- Breath of Eons stuns enemies for $s1 sec
    time_spiral                    = {  93351,  374968, 1 }, -- Bend time, allowing you and your allies within $s1 yds to cast their major movement ability once in the next $s2 sec, even if it is on cooldown
    tip_the_scales                 = {  93350,  370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level
    twin_guardian                  = {  93287,  370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to $s1% of your maximum health for $s2 sec
    unravel                        = {  93308,  368432, 1 }, -- Sunder an enemy's protective magic, dealing $s$s2 Spellfrost damage to absorb shields
    verdant_embrace                = {  93341,  360995, 1 }, -- Fly to an ally and heal them for $s1, or heal yourself for the same amount
    walloping_blow                 = {  93286,  387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by $s1% for $s2 sec
    zephyr                         = {  93346,  374227, 1 }, -- Conjure an updraft to lift you and your $s1 nearest allies within $s2 yds into the air, reducing damage taken from area-of-effect attacks by $s3% and increasing movement speed by $s4% for $s5 sec

    -- Augmentation
    accretion                      = {  93229,  407876, 1 }, -- Eruption reduces the remaining cooldown of Upheaval by $s1 sec
    anachronism                    = {  93223,  407869, 1 }, -- Prescience has a $s1% chance to grant Essence Burst
    arcane_reach                   = {  93225,  454983, 1 }, -- The range of your helpful magics is increased by $s1 yards
    aspects_favor                  = {  93217,  407243, 2 }, -- Obsidian Scales activates Black Attunement, and amplifies it to increase maximum health by $s1% for $s2 sec. Hover activates Bronze Attunement, and amplifies it to increase movement speed by $s3% for $s4 sec
    bestow_weyrnstone              = {  93195,  408233, 1 }, -- Conjure a pair of Weyrnstones, one for your target ally and one for yourself. Only one ally may bear your Weyrnstone at a time. A Weyrnstone can be activated by the bearer to transport them to the other Weyrnstone's location, if they are within $s1 yds
    blistering_scales              = {  93209,  360827, 1 }, -- Protect an ally with $s3 explosive dragonscales, increasing their Armor by $s4% of your own. Melee attacks against the target cause $s5 scale to explode, dealing $s$s6 Volcanic damage to enemies near them$s$s7 This damage can only occur every few sec. Blistering Scales can only be placed on one target at a time. Casts on your enemy's target if they have one
    breath_of_eons                 = {  93234,  403631, 1 }, -- Fly to the targeted location, exposing a Temporal Wound on enemies in your path for $s1 sec and granting Ebon Might for $s2 sec. Removes roots and grants immunity to movement impairing and loss of control effects while flying.  Temporal Wound $s5% of damage dealt by allies affected by Ebon Might is copied as additional Arcane damage to enemies after $s6 sec
    chrono_ward                    = {  93235,  409676, 1 }, -- When allies deal damage with Temporal Wounds, they gain a shield for $s1% of the damage dealt. Absorption cannot exceed $s2% of your maximum health
    defy_fate                      = {  93222,  404195, 1 }, -- Fatal attacks are diverted into a nearby timeline, preventing the damage, and your death, in this one. The release of temporal energy restores $s1 health to you, and $s2 to $s3 nearby allies, over $s4 sec. Healing starts high and declines over the duration. May only occur once every $s5 min
    draconic_attunements           = {  93218,  403208, 1 }, -- Learn to attune yourself to the essence of the Black or Bronze Dragonflights: Black Attunement: You and your $s3 nearest allies have $s4% increased maximum health. Bronze Attunement:You and your $s7 nearest allies have $s8% increased movement speed
    dream_of_spring                = {  93359,  414969, 1 }, -- Emerald Blossom no longer has a cooldown, deals $s1% increased healing, and increases the duration of your active Ebon Might effects by $s2 sec, but costs $s3 Essence
    ebon_might                     = {  93198,  395152, 1 }, -- Increase your $s1 nearest allies' primary stat by $s2% of your own, and cause you to deal $s3% more damage, for $s4 sec. May only affect $s5 allies at once, and does not affect tanks and healers. Eruption, Breath of Eons, and your empower spells extend the duration of these effects
    echoing_strike                 = {  93221,  410784, 1 }, -- Azure Strike deals $s1% increased damage and has a $s2% chance per target hit to echo, casting again
    eruption                       = {  93200,  395160, 1 }, -- Cause a violent eruption beneath an enemy's feet, dealing $s$s2 Volcanic damage split between them and nearby enemies. Increases the duration of your active Ebon Might effects by $s3 sec
    essence_attunement             = {  93219,  375722, 1 }, -- Essence Burst stacks $s1 times
    essence_burst                  = {  93220,  396187, 1 }, -- Your Living Flame has a $s1% chance, and your Azure Strike has a $s2% chance, to make your next Eruption cost no Essence. Stacks $s3 times
    fate_mirror                    = {  93367,  412774, 1 }, -- Prescience grants the ally a chance for their spells and abilities to echo their damage or healing, dealing $s1% of the amount again
    font_of_magic                  = {  93231,  408083, 1 }, -- Your empower spells' maximum level is increased by $s1, and they reach maximum empower level $s2% faster
    hoarded_power                  = {  93212,  375796, 1 }, -- Essence Burst has a $s1% chance to not be consumed
    ignition_rush                  = {  93230,  408775, 1 }, -- Essence Burst reduces the cast time of Eruption by $s1%
    imminent_destruction           = { 102248,  459537, 1 }, -- Breath of Eons reduces the Essence cost of Eruption by $s1 and increases its damage by $s2% for $s3 sec after you land
    imposing_presence              = {  93199,  371016, 1 }, -- Quell's cooldown is reduced by $s1 sec
    infernos_blessing              = {  93197,  410261, 1 }, -- Fire Breath grants the inferno's blessing for $s2 sec to you and your allies affected by Ebon Might, giving their damaging attacks and spells a high chance to deal an additional $s$s3 Fire damage
    inner_radiance                 = {  93199,  386405, 1 }, -- Your Living Flame and Emerald Blossom are $s1% more effective on yourself
    interwoven_threads             = {  93369,  412713, 1 }, -- The cooldowns of your spells are reduced by $s1%
    molten_blood                   = {  93211,  410643, 1 }, -- When cast, Blistering Scales grants the target a shield that absorbs up to $s1 damage for $s2 sec based on their missing health. Lower health targets gain a larger shield
    molten_embers                  = { 102249,  459725, 1 }, -- Fire Breath causes enemies to take up to $s1% increased damage from your Black spells, increased based on its empower level
    momentum_shift                 = {  93207,  408004, 1 }, -- Consuming Essence Burst grants you $s1% Intellect for $s2 sec. Stacks up to $s3 times
    motes_of_possibility           = {  93227,  409267, 1 }, -- Eruption has a $s1% chance to form a mote of diverted essence near you. Allies who comes in contact with the mote gain a random buff from your arsenal
    overlord                       = {  93213,  410260, 1 }, -- Breath of Eons casts an Eruption at the first $s1 enemies struck. These Eruptions have a $s2% chance to create a Mote of Possibility
    perilous_fate                  = {  93235,  410253, 1 }, -- Breath of Eons reduces enemies' movement speed by $s1%, and reduces their attack speed by $s2%, for $s3 sec
    plot_the_future                = {  93226,  407866, 1 }, -- Breath of Eons grants you Fury of the Aspects for $s1 sec after you land, without causing Exhaustion
    power_nexus                    = {  93201,  369908, 1 }, -- Increases your maximum Essence to $s1
    prescience                     = {  93358,  409311, 1 }, -- Grant an ally the gift of foresight, increasing their critical strike chance by $s1% and occasionally copying their damage and healing spells at $s2% power for $s3 sec. Affects the nearest ally within $s4 yds, preferring damage dealers, if you do not have an ally targeted
    prolong_life                   = {  93359,  410687, 1 }, -- Your effects that extend Ebon Might also extend Symbiotic Bloom
    pupil_of_alexstrasza           = {  93221,  407814, 1 }, -- When cast at an enemy, Living Flame strikes $s1 additional enemy for $s2% damage
    reactive_hide                  = {  93210,  409329, 1 }, -- Each time Blistering Scales explodes it deals $s1% more damage for $s2 sec, stacking $s3 times
    regenerative_chitin            = {  93211,  406907, 1 }, -- Blistering Scales has $s1 more scales, and casting Eruption restores $s2 scale
    ricocheting_pyroclast          = {  93208,  406659, 1 }, -- Eruption deals $s1% more damage per enemy struck, up to $s2%
    rockfall                       = {  93368, 1219236, 1 }, -- Upheaval reaches maximum empower level $s1% faster and has a $s2% chance to grant Essence Burst
    rumbling_earth                 = {  93205,  459120, 1 }, -- Upheaval causes an aftershock at its location, dealing $s1% of its damage $s2 additional times
    stretch_time                   = {  93382,  410352, 1 }, -- While flying during Breath of Eons, $s1% of damage you would take is instead dealt over $s2 sec
    symbiotic_bloom                = {  93215,  410685, 2 }, -- Emerald Blossom increases targets' healing received by $s1% for $s2 sec
    tectonic_locus                 = {  93202,  408002, 1 }, -- Upheaval deals $s1% increased damage to the primary target, and launches them higher
    time_skip                      = {  93232,  404977, 1 }, -- Surge forward in time, causing your cooldowns to recover $s1% faster for $s2 sec
    timelessness                   = {  93360,  412710, 1 }, -- Enchant an ally to appear out of sync with the normal flow of time, reducing threat they generate by $s1% for $s2 min. Less effective on tank-specialized allies. May only be placed on one target at a time
    tomorrow_today                 = {  93369,  412723, 1 }, -- Time Skip channels for $s1 sec longer
    unyielding_domain              = {  93202,  412733, 1 }, -- Upheaval cannot be interrupted, and has an additional $s1% chance to critically strike
    upheaval                       = {  93203,  396286, 1 }, -- Gather earthen power beneath your enemy's feet and send them hurtling upwards, dealing $s$s2 Volcanic damage to the target and nearby enemies. Increases the duration of your active Ebon Might effects by $s3 sec. Empowering expands the area of effect. I: $s4 yd radius. II: $s5 yd radius. III: $s6 yd radius
    volcanism                      = {  93206,  406904, 1 }, -- Eruption's Essence cost is reduced by $s1

    -- Chronowarden
    afterimage                     = {  94929,  431875, 1 }, -- Empower spells send up to $s1 Chrono Flames to your targets
    chrono_flame                   = {  94954,  431442, 1 }, -- Living Flame is enhanced with Bronze magic, repeating $s1% of the damage or healing you dealt to the target in the last $s2 sec as Arcane, up to $s3
    doubletime                     = {  94932,  431874, 1 }, -- Ebon Might and Prescience gain a chance equal to your critical strike chance to grant $s1% additional stats
    golden_opportunity             = {  94942,  432004, 1 }, -- Prescience has a $s1% chance to cause your next Prescience to last $s2% longer
    instability_matrix             = {  94930,  431484, 1 }, -- Each time you cast an empower spell, unstable time magic reduces its cooldown by up to $s1 sec
    master_of_destiny              = {  94930,  431840, 1 }, -- Casting Essence spells extends all your active Threads of Fate by $s1 sec
    motes_of_acceleration          = {  94935,  432008, 1 }, -- Warp leaves a trail of Motes of Acceleration. Allies who come in contact with a mote gain $s1% increased movement speed for $s2 sec
    primacy                        = {  94951,  431657, 1 }, -- For each damage over time effect from Upheaval, gain $s1% haste, up to $s2%
    reverberations                 = {  94925,  431615, 1 }, -- Upheaval deals $s1% additional damage over $s2 sec
    temporal_burst                 = {  94955,  431695, 1 }, -- Tip the Scales overloads you with temporal energy, increasing your haste, movement speed, and cooldown recovery rate by $s1%, decreasing over $s2 sec
    temporality                    = {  94935,  431873, 1 }, -- Warp reduces damage taken by $s1%, starting high and reducing over $s2 sec
    threads_of_fate                = {  94947,  431715, 1 }, -- Casting an empower spell during Temporal Burst causes a nearby ally to gain a Thread of Fate for $s1 sec, granting them a chance to echo their damage or healing spells, dealing $s2% of the amount again
    time_convergence               = {  94932,  431984, 1 }, -- Non-defensive abilities with a $s1 second or longer cooldown grant $s2% Intellect for $s3 sec. Essence spells extend the duration by $s4 sec
    warp                           = {  94948,  429483, 1 }, -- Hover now causes you to briefly warp out of existence and appear at your destination. Hover's cooldown is also reduced by $s1 sec. Hover continues to allow Evoker spells to be cast while moving

    -- Scalecommander
    bombardments                   = {  94936,  434300, 1 }, -- Mass Eruption marks your primary target for destruction for the next $s2 sec. You and your allies have a chance to trigger a Bombardment when attacking marked targets, dealing $s$s3 Volcanic damage split amongst all nearby enemies
    diverted_power                 = {  94928,  441219, 1 }, -- Bombardments have a chance to generate Essence Burst
    extended_battle                = {  94928,  441212, 1 }, -- Essence abilities extend Bombardments by $s1 sec
    hardened_scales                = {  94933,  441180, 1 }, -- Obsidian Scales reduces damage taken by an additional $s1%
    maneuverability                = {  94941,  433871, 1 }, -- Breath of Eons can now be steered in your desired direction. In addition, Breath of Eons burns targets for $s$s2 Volcanic damage over $s3 sec
    mass_eruption                  = {  98931,  438587, 1 }, -- Empower spells cause your next Eruption to strike up to $s1 targets. When striking less than $s2 targets, Eruption damage is increased by $s3% for each missing target
    melt_armor                     = {  94921,  441176, 1 }, -- Breath of Eons causes enemies to take $s1% increased damage from Bombardments and Essence abilities for $s2 sec
    menacing_presence              = {  94933,  441181, 1 }, -- Knocking enemies up or backwards reduces their damage done to you by $s1% for $s2 sec
    might_of_the_black_dragonflight = {  94952,  441705, 1 }, -- Black spells deal $s1% increased damage
    nimble_flyer                   = {  94943,  441253, 1 }, -- While Hovering, damage taken from area of effect attacks is reduced by $s1%
    onslaught                      = {  94944,  441245, 1 }, -- Entering combat grants a charge of Burnout, causing your next Living Flame to cast instantly
    slipstream                     = {  94943,  441257, 1 }, -- Deep Breath resets the cooldown of Hover
    unrelenting_siege              = {  94934,  441246, 1 }, -- For each second you are in combat, Azure Strike, Living Flame, and Eruption deal $s1% increased damage, up to $s2%
    wingleader                     = {  94953,  441206, 1 }, -- Bombardments reduce the cooldown of Breath of Eons by $s1 sec for each target struck, up to $s2 sec
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    born_in_flame                  = 5612, -- (414937)
    chrono_loop                    = 5564, -- (383005) Trap the enemy in a time loop for $s1 sec. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below $s2%
    divide_and_conquer             = 5557, -- (384689)
    dreamwalkers_embrace           = 5615, -- (415651)
    nullifying_shroud              = 5558, -- (1241352)
    obsidian_mettle                = 5563, -- (378444)
    scouring_flame                 = 5561, -- (378438)
    seismic_slam                   = 5454, -- (408543)
    swoop_up                       = 5562, -- (370388) Grab an enemy and fly with them to the target location
    time_stop                      = 5619, -- (378441) Freeze an ally's timestream for $s1 sec. While frozen in time they are invulnerable, cannot act, and auras do not progress. You may reactivate Time Stop to end this effect early
    unburdened_flight              = 5560, -- (378437) Hover makes you immune to movement speed reduction effects
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
    melt_armor = {
        id = 441172,
        duration = 12,
        max_stack = 1
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
        max_stack = 2,
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
    temporal_burst = {
        id = 431698,
        duration = 30,
        max_stack = 30
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
    upheaval = {
        id = 431620,
        duration = 8,
        max_stack = 1
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

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237658, 237656, 237655, 237654, 237653 },
        auras = {
            -- Scalecommander
            draconic_inspiration = {
                id = 1237241,
                duration = 30,
                max_stack = 1
            },
        }
    },
    tww2 = {
        items = { 229283, 229281, 229279, 229280, 229278 }
    },
    -- Dragonflight
    tier31 = {
        items = { 207225, 207226, 207227, 207228, 207230, 217178, 217180, 217176, 217177, 217179 },
        auras = {
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
        }
    },
    tier30 = {
        items = { 202491, 202489, 202488, 202487, 202486 }
    },
    tier29 = {
        items = { 200381, 200383, 200378, 200380, 200382 }
    }
} )

-- Pets
spec:RegisterPets({
    dracthyr_commando = {
        id = 219827,
        spell = "breath_of_eons",
        duration = 30,
    },
})

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

    if ability.empowered then
        if buff.tip_the_scales.up then
            removeBuff( "tip_the_scales" )
            setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
        end
        if talent.mass_disintegrate.enabled then
            if talent.eruption.enabled then
                addStack( "mass_eruption_stacks" )
            else
                addStack( "mass_disintegrate_stacks" )
            end
        end
    end

    if ability.spendType == "essence" then
        if buff.essence_burst.up then
            removeStack( "essence_burst" )
            if talent.momentum_shift.enabled then addStack( "momentum_shift" ) end
        end
        if talent.extended_battle.enabled and debuff.bombardments.up then
            debuff.bombardments.expires = debuff.bombardments.expires + 1
        end
    end
end )

spec:RegisterHook( "runHandler_startCombat", function( action )
    if talent.onslaught.enabled then addStack( "burnout" ) end
    if talent.unrelenting_siege.enabled then applyBuff( "unrelenting_siege" ) end
end )

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

spec:RegisterStateTable( "evoker", setmetatable( {
    allied_cds_up = 1
}, {
    __index = setfenv( function( t, k )
        if k == "prescience_buffs" then return active_dot.prescience end
        if k == "allied_cds_up" then
            -- Will never reach this point since allied_cds_up is set in the evoker table.
            if buff.sense_power.up then return group and active_dot.sense_power_active or 1 end
            return 1
        end
        if k == "scales_up" then return active_dot.blistering_scales > 0 end
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

local GenerateEssenceBurst = setfenv( function ( baseChance, targets )

    local burstChance = baseChance or 0
    if not targets then targets = 1 end

    if burstChance >= 1 then
        addStack( "essence_burst" )
    end

end, state )



-- Abilities
spec:RegisterAbilities( {
    -- Project intense energy onto 3 enemies, dealing 1,161 Spellfrost damage to them.
    azure_strike = {
        id = 362969,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "spellfrost",
        color = "blue",

        startsCombat = true,

        minRange = 0,
        maxRange = 25,

        cycle = function() if talent.bombardments.enabled then return "bombardments" end end,
        cycle_to = true,

        damage = function () return stat.spell_power * 0.755 * ( debuff.shattering_star.up and 1.2 or 1 ) end, -- PvP multiplier = 1.
        critical = function() return stat.crit + conduit.spark_of_savagery.mod end,
        critical_damage = function () return talent.tyranny.enabled and 2.2 or 2 end,
        spell_targets = function() return talent.protracted_talons.enabled and 3 or 2 end,

        handler = function ()
            --[[ Disabled for now because Aug has no scalers/bonuses for essence burst chance
            if talent.essence_burst.enabled then GenerateEssenceBurst( 0.15, 1 ) end
            ]]--
        end
    },
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

            if talent.melt_armor.enabled then
                applyDebuff( "target", "melt_armor" )
            end

            if talent.overlord.enabled then
                for i = 1, ( max( 3, active_enemies ) ) do
                    spec.abilities.eruption.handler()
                end
            end

            if talent.slipstream.enabled then gainCharges( "hover", 1 ) end

            if set_bonus.tww2 >= 2 then
                local ebon = buff.ebon_might.expires
                spec.abilities.upheaval.handler()
                -- Except ebon might extensions. Why blizz.
                buff.ebon_might.expires = ebon
            end

            if set_bonus.tww3_scalecommander >= 4 then applyBuff( "draconic_inspiration" ) end
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
        cast = function() return 2.5 * ( talent.ignition_rush.enabled and buff.essence_burst.up and 0.6 or 1 ) * ( talent.natural_convergence.enabled and 0.8 or 1 ) * haste end,
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

            if buff.mass_disintegrate_stacks.up then
                if talent.bombardments.enabled then applyDebuff( "target", "bombardments" ) end
                removeStack( "mass_disintegrate_stacks" )
            end

            if buff.mass_eruption_stacks.up then
                if talent.bombardments.enabled then applyDebuff( "bombardments" ) end
                removeStack( "mass_eruption_stacks" )
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

        cycle = function() if talent.bombardments.enabled then return "bombardments" end end,
        cycle_to = true,

        damage = function () return 1.61 * stat.spell_power * ( talent.engulfing_blaze.enabled and 1.4 or 1 ) end,
        healing = function () return 2.75 * stat.spell_power * ( talent.engulfing_blaze.enabled and 1.4 or 1 ) * ( 1 + 0.03 * talent.enkindled.rank ) * ( talent.inner_radiance.enabled and 1.3 or 1 ) end,
        spell_targets = function () return buff.leaping_flames.up and min( active_enemies, 1 + buff.leaping_flames.stack ) end,

        handler = function ()
            if buff.burnout.up then removeStack( "burnout" )
            else removeBuff( "ancient_flame" ) end

            removeBuff( "leaping_flames" )
            removeBuff( "scarlet_adaptation" )
            --[[ Disabled for now because Aug has no scalers/bonuses for essence burst chance
            if talent.essence_burst.enabled then GenerateEssenceBurst( 0.2, max( 2, ( group or health.percent < 100 and 2 or 1 ), action.living_flame.spell_targets ) ) end
            ]]--
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
            --[[ Disabled for now because Aug has no scalers/bonuses for essence burst chance
            if talent.essence_burst.enabled and talent.anachronism.enabled then GenerateEssenceBurst( 0.35, 1 ) end
            ]]--
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
    tip_the_scales = {
        id = 370553,
        cast = 0,
        cooldown = function()
            if set_bonus.tww3_chronowarden >= 2 then return 60 end
            return 120
        end,
        gcd = "off",
        school = "arcane",
        color = "bronze",

        talent = "tip_the_scales",
        startsCombat = false,

        toggle = "cooldowns",
        nobuff = "tip_the_scales",

        handler = function ()
            applyBuff( "tip_the_scales" )
        end
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
            -- This was reduced to 50% chance, can't gaurantee it atm
            -- if set_bonus.tww2 >= 4 then addStack( "essence_burst" ) end
            --[[ Disabled for now because Aug has no scalers/bonuses for essence burst chance
            if talent.essence_burst.enabled and talent.rockfall.enabled then GenerateEssenceBurst( 0.6, 1 ) end
            ]]--
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

spec:RegisterPack( "Augmentation", 20250829.1, [[Hekili:T3ZAVnoos(BjyrR2kDhhj5K0pUyVyUza2Rhm3Sdq29(YHlYYsYXcTSKxj5Kodm8V9RkQxKuKuu2oDpd2E2Dg0TfvX6nRQyrQ7TV)FC)DbEfH3)RowoxB9ENpm2(Qjwx)H7VR45nH3F3gp)p79a8hs8wd)3Fy7dRdtk8kIstWh(CCQxacK80Tz(WawvuSj)JxE5drfR2UySF66lZJwVnM8g(zEllW)U)LlItxCzXQWN8YEcgAuYL)GpoKFllknlQ45FjkVi)YGWLEBJlUm8X0phM56rn7JrWC)Dl2gfx8PK7xiKoMCfGzBc9V)xTV6DtaSlkiiSCWH5WBJd(cR3FHZh(4(539CI)(5i2a)5O1)4(FE)pxpaRBGb8PKOIiV49Z)HF7xU)UyedrsFzuCCyg8N(vc7mmXBrCyW9)N3FNpqjHzrE3F3O9ZxSD5YXEj(raf4UmgyNJ3Uz)8D72pFTxI3(5ZMUFUJf(pL)6z7Nx4fdJECqwO3A30LU5BYIsEyC1uuoSh9Gza(RJZ3adAviIGaKaGyUFUX(5Wu7bS2hdDdtcxhfMtESD5lxnbB2UjkgNa4V(L8ImV8F3RDwmV)op)sjEC0JacuI(3xaCBKIRFO3VVnl0fE9OphsZhkG)3DPBGPpZvoZkDdiRclAbxnHH)P4THT)W4kyfeg79mW3(RumH1rjG6gWSOgcTG4mQXwng)GCyCfH(fiXcCSsTTXEXXrHbKhJcQzapLGdULMcmZqnR4uqpxashvt0Kbpr2VOCa63gXVRKAfitac6JtAr)WSTBi)jawxlfwhLoTCf6B0wHUY3uJQC9l9V2gghZoAwZKTjzEpgYpKHlvdcjUukcxVjnZl29P0TjbJZcx7fLKtlNWru(urIN(Ni)004G0NsgVa8dvSc5PHPj5IMk83DR)DbYpLtwnq2aZN7Y0m3OGw28DwC(tb9yasUlst2MpU4PNM4E1g)gpNRcZsDlYcdh7VklnjfwNb88x7tSsfjAn4UaDhdRguKTLGsTQivu)ik7fAYB)8B3p)90GJJ904)S0jCHx2dHfJlIwh6wK6gefsSOSNqgqMxuGB4Jiy8ccYhhLu(0RlPOfP55KXTm6HvfmOWKsp94OAeubHHBClrNXDr3Z6fJl5sH55Hj(Ha0wg5hvuAOAxdcIYx1qCxSnlVawpRXesOn7d(bTOdcmRXxxZEoJHhSo9XqCP(XHFbxMTHhcl)9zKjApokFCky669LC31Hz(BHji2n8HhQ8bupqhfdSIRjAAr2)TacEdZQFRGhNbgW5HalBPlqoOTpqYVJJKRFHnzqygrihcydp7hdsEIwqo(ESQZ5PXPeYKWxBFrg5xLhUhYsr)XgnRShKwq9kKH6qT(p8)xUnoguB8xHZVlQewsGOizT3x2p)CqtItlkeSTCxJkCuir33PCokvhAEd38W4LTV2fDElZsyj81c2MrIXJm2wJV2rTXlja8777wScO6va(2JzYug7ez2ZtjwiuRHaXLrCFeLVMXCMG1c9EujxQSlQfALwmnm2LrWYkvMNvVa9J3UbIId8(qEwJqulfeAMStjPixfP6jKv5ZPMPZut)egDxJ)8civbcCf8qaNCRgaH92O)zBrSWWWXZI2uTSlHvMpUY1)BMEjXPz(NJ282s7h3OLtbq(XQLaxKUEb4FhTCBwv6TWqeYW7AjmZYOzKu8v1dKZ1P6b3irfnSsbblb3Ig0uCuYhhvrYDL)xa5oC(OQvzYsbTBVcKJVBh9VbzdfhZ(tbBYnFZ1wNx9By(sJPZ0YezLJg1f1VDAL625t2TtHxdQXzmsLFIlAgN5Ttv6z4C98kSBh6rWGXBWTtNyzUBNqFa3o99iVHx33qL9UrLM(T2gNjXcN6bu22MgsLL3wZiCmgDwx8bilj2F3QY2dinIuZ2Y0qH0exq799hdFxFNw64eMAXX06O8)GQ8MhP3Yl(E5fvRRDYxAPXZOeIFwdT3FOvg9fMwlWeftiHjs7eDw5kBulATonUimXnC9IWSorHYeYSJRdviZ9G4uZagguCAwataJ0lFOE9X2fqKjpzIYq9I2LSldjqKedFL254jh1cXTX5hKUfWdK9ZhXSmfvE0aPNxkLAYeqf0A7GrtnBljHQ6dHb4w(xCXsBvwGRQmYaZX1K85SLxIlzj3tkAq9SKTnr6KWwHiCY4lPs7KvjjqBuVGCuzDPxriVYo4y9rmk9X2CA1LsaQhtzjQJtmUaLfNxCvHnSyKgfrBaplqWma)oSKLYN5FlvIz2)uiPKFuAQnQpYRst3i5K4uGHmAu3zO2rKGIFZ(5xruVQ9seJQMl3MbRkrX3VGKYu7WwMc2)aFzT3dr(sDxiJrw7SOLmAk2r5sBmautD5LliCD(YGu)UuAcGEFcijWYrbHFXK(6TtTiqrE9PQq4NaHxmOJcYjALt(QxnRonbHvjyAtzcuvyUAkGLjQMimkI8)C(miKac5ip1D1KJSYB0I4JKuIdSM3x3iL5hsD2)IwnKXktsvu8t3MuSF(LWaWknCBxgFJMiDzrBPsSmu(K4JGFQTmeepYVcq9RSknsCMuAZX(KztRt1TFxkNe5hFDi0nSnoYAsfvz70f5rwSmQW(6wTHElWgBmlHXfUEzRtZeUTdhblrEKS)5wP9KWC4d8UPe1vReizXO6h3SsuVXYaEOAdsXShxzdA1lSUgulo6g4bR1eogPtav5wHJoEpwrHvNq4o4IBWxyANYctBqtqzP(FEjq6S0I4QQcORFrTqVskaAR426GBTaFaDcsEQh6)VI77izcEd7W7gqa1yl))1H4yW(MQIiYXIoyAvPB0Fsjg9Mn10ge2q)St6jAdJkyW9CwnQR5I7RQcwezM8OO7BhFnuPIyWMKk7gc7WLgf7tzlRF3TP2GQMG0ptZeGQzSD2sbQYgi1QBAFwDg9u06zKGxPZjADii2cCxedlRLUMit4t2OESm7qyxj1AV8C36TSSRCI5XL4BovQM9wi5JWxKHODWPws3Vh7PKq5zCFkBdbUPw8ROESnlKHCPg21xc93wuVFemHoOULeq0IFvXsTytb70ckE5ZYQw8YUhVFx8(vs8g6VkfnRkz8AKBKm5QS844nX1Blg2ebVewV76vaWF1pn5XqysbwTXzLo(5(zxmMR44qFCpqngvjxMn1ryLAjERnfv2)0nyTGZrgtwQx2xhezGl)02Ss3CDzZk17Ad9TYIauR6jJeVsB1tfT))dyvE(2UQDdcd)xBJ2SjmyCqeeozsbad3htJc8tZcBycJ34xTN4xtQXdQnkVEaacabFfuR(wnVsJLqnfkD73L2xlo8P23yNu3Tnc6wnvHZZAB)TETDjtsBCrIIiVBI)uDEcJ6Ns1Oo09TTrBjrZMjqSE28HYmIK5(tEg)N1KIvzTgDzm24RGmWEPYOelxgjvpQ6u6WNjD9Ovvt3MI5wqAgcFCLJ2wMIcyyJbbKCFTgutqRmngKKUVtd4jUDbzb9W7mRhhq3iwxPemP9NsFeYYTQO20nIKSwbC49YLsuJKaOW64lynIddJf1qyAiNe1QHCIjEhC9Zly7MOSTlE29PvHXBCZH)BvXnyhZtRIY3uAyeL47LL4bEaJ8XIA0DW60EsKb6TimldwLXLS58G7NhyO9Qb7A7g(f)4TbHI64ObqToAqTodHAv1JvDhOMuRdn1Y76zaulHdN886TOhWYoVK4xBtusqCOiXr(MNHW6bL7C3NcxiAef46kyhgUn3fYmjjFDubmErdDvAz3I5c8VGCUOq)vcATFEuoUi36nXr(alo4T7N)F7LSfZm))YdXsXAdRjJr0(Npa2JZqypo9YEC0N94iI9ispOLo7S5LdGqjsJfaIbltvKs2dUfHpNMeiM5M(GFGlU9Rc31ZbmVodzED4M3H3t5Jyuax5bs1CmYJLllz)998V2pSBmyDC3Xw8owbkeFBwysqAU7MO40ciaeiKgs0sIeQ4ukEpxhgJ1PhgRON)1(HYzSo9WyDgkJ1HIXkjIeCNiuT(ERmk)5eFHBCfNySPEcT6dTvcUzRgEfUjwwnhiMkPPByComPwJVUr8AlC7Chi270p27ib7DobyVKiG0f73uD0RUxYHfrKaya0hQEwtJ6OBIA3N1XZrle4BlijyqVm5lzgWMSu)XEjp7gSjFmZwwDobwKow)nkS7k7UzvJObwcq9CYzqRARv6G)cvXVKzadg)5Di3f)f4Ywc(B3I)LJWUElLyPIO4hJj9kcTphYVzwUVNwTBXeRsVDJkVJWn8wtv(Ynj09y08fR92(8oKgwVhoEGAAtsqViTXUj2uaDGXYPyWnlnCG2)8n19prAAU9ZrTrqxIi(Xd7zr0VhIhTYQYwsnGkqcWc73W9ZlJwgcoM0tgL)6taJGSnVqCv7NNKMTgJAoo9HiqnSiD)8h26HjBecpflntzK2zzybsv7dusGasKvIIaxJ0AXk84wVLUazrLt7nc3CxnHRYskrN484ReUFKAonY6tMofN5aRotyIAWkkkonalPisadcDPvj47aA(4ykFtH5UwpvIEO6AclOeD9veoMZNi7wt2ofKYTTCHO6S1o5sAkaVGNLxMqA8RBNmkBhuPMG7zAGHReuutkmKRdJkR0B7MniP3cn0z3VyAT22qG7TBt6VxjX41gAZsoPE1UMsgZYCj1m2uuTi7LfpzOS43)NsoOJoCqsX6L0sTMIkNAVCxNHYDTD(tj71MM9QKfY7SRxwO9GzH38NswOL2Sqz7uNuwiUBzv)9HYmFzCOQKkfv96EjXd3nwV0MOteJrF6jMLRXwEUieSmBnbjnaBHRelRR5Qo0pDk4H6i4ffEED8Tm3xc6MsqVaSTDHh1xthIK0vAzVDvDUi9YMMv2hNLjNnQPDv4UGeQxjqXHdX80ZRDo186YwIPmSu5AzcIk7WJKvAWhIQv4XMlD9(B0jzAP1MSQGrkZkx8ZfntYlVCnlu8dvegHK9fzWUcSz65grhjdsuqkoUb2xxteYWjflLZUbqCfJ44T5eHUyhgFb5Ptkx6fJJQDTx5BfDDTOuWRUOC982b10QUTJ5CwpATJGbn)Gv90PZ(6t7Ruan7u16m90M8cEZBSK6bJFV74gJW6J22fpIghtdfABjTMS0B5qxhH9GxcR7Pa8YEO4f7Emzw7IGOcZItKuFRlFaJ(VIi243DtQdtrvA)RIwI1VQ2d1S2vkumIMw8S)LyFNwlX(oQ1s4WzfbRvXeT1E3A61nFpBdOrDPKpyNm17PGxFhQajv)G8mK(z6p12qPAWEbLyIkhezE572AySh15PnhuftPgAmSBrwSTDwjfJQZXlL6zTN2ht18g5LmwX26WVXq96OriD3j0OoEgKSXiipLXhkyFdlMtPDlO9t4SaC0Eh)6n8JE2tSVBb0RfGTela7VTwa26VXM9UKw)waoIwN9aTaiBWHSdki7PNGzdF(b8r7NFh5zKnTz)8)(F7h)PgCkF8(5FkieISbq6Iv4wZaQXylVUie3BO27QiS0cWtXZEjiGIju5ITf1Vf(V5rR3eJ7sKxsaMtpKx(EYgaTcsjc3zi8FlI8drsaSFIwcP4ucDeS)0VD3yHXHJz4drD5ABFLnLIJa5BtN7WNhHa9UMxxYgrkj98UQcYxhqc6iCHaTqh(myfPzAwvclP3YenEv59YYFPQDkZEuRWk0IhOJirROB5JWmle8JtF2FMWhYAxhH1zi0V7Cz4SOGP7j29sMf7f5h2vbLXKQ2SGFlH)0sC3ErR)0KWUB8l6co9XOaCfgVsw2BRhbUBVPW)nR81AOiWfd8traGtcJkFE)qBrk6ZNbo3lQR)6USpNJYbQeF6JmqlLyDmK5gWF4uI7jJqvM7dxj2HvjwuJzQkNOV7)6Kk6pf(VeZrzDv1nnGoDnQQ8a(Ub)jvQFkm4fZrvi1l7ThzLZDryEbqwWlK31ZFzXuygsRUHQCRKQDwP60pxHU6HkL5DU4luQZ2VrOWjwvTcl9LkRoZ4GDx5HDkFPuH6hKVq7d83XWpqDLOAn(MABRMJ4jJmIj(K)zoDujpf6TjLCRwt26VhbdaCunFWbU)UN8Ysk7tP)bgFseMBErvMpVUQ)IEnMcdm1zOgEEkUBPEBlsx7rU619bQ7HqiXOF(xIWqIWV6a)i509sE8RR5QYpFrVUmRNxZAllBOJS)IzVtM8J3tNjt5qzMmBUzlDtyPAuvEEVwAf7ng19w7z2u7jgJ6Ex9mBQZ172DM4BOND7KC78qGMWBLNxzp(6BzR(HPPXzngnYAioaNbK9vVY5kRBN6mbVgEQ(RZMoXu2TuAd79pISIlpowblNOpgrRAZ76rTr4kp4fFuLeycmT2o1Zesz8tN91iBTCZBuC9v1CpX29QRYSwW1dY81bxA5DVVhE33qTjHgw1SXVH4LqTCKLs8WVmnoo9js)h7bRcIfWkeR5fSErqjpLKOA5cA7NJn0zvHRkhxskz5HTjmJoiahCGxH3cV8WpU)NlBvEP30d43Pgbl40CCRpHl5WFQrfVAJGrP1cnQpITINlvdx)jvVv3o(LsLDCFfpvIhiZe9ovRz3R0s2O0Fk0xA17W1Fs1tAPFSikNmDKwkgiZe9EvQfsBIhXkhQgU(tkBsEINPoJrFWlP7seppYhS(ti7UxlEE6mggW)bvkd6lJ6D46pP9iJepg9bVUYOEgS(typYiXJHn5blv6aIoS1I1eKms25YwfTO1CPAKSZLJu6I(i4jGy4E8qGkPyenbtib2Dg0jFgogSVu1)zv4E7qoXq)yWBSgcqe44gAQc3zh2lWSCm0WkK7Oc7RhWjfYhdgJ1ksfcx98tjCpa0nss3Nk2tMSHYoBtK6ktP7LopEiqThJFjd6Kpdhd2lZbGWHCIH(XG3Qm8LoSxGz5yObXobemGtkKpgmwOBGUp)uc3daD129IYHYoBxj1zwNnlqGxmrJ5Lf(sHS8QkwbV6TJXyKQj4vVY2XAQv3YbomOubKwS9APs1(5dIhdlF(udFPqUF(SthoKGjOx(SEqPdFw(gIGgD1aqInj1Jz5UYRnKsO25X6b1dvM9sdFDGSWgwua0LnoDPaTdIONWuobZGup5Aa7JimLJg6dgVpuF2V0WxhiRNEP8XPlfOHwJwzNFcMHdq(2RMJgzNF0q)aWB8I5ra0Q(z9GIJyO4Ofu6SQ4zsdCqRv6Ox3WOlSA6POD7oJJ7v)w0FUm7mtQxuL6HcnhmpFK14RFJe3jNpr2tG3takHx)uMMZgPoGQ(mr5XjBP4KDV4u5vIf8e73WGvOIWfCkgMVY2YYSDFp)tSC)Y)ak3V8pSY9lRK7TUeuSLudWXImOmmNCFt21kPZ6acMQNLfpbZG0LxKd7bXZ6D46nRdyH(dKNnGzyW8SEvCEH0Zg0S27WRM1V69ncw2ijDic52l51dQ7qKTzy9Y0pkz0xxr0)UrPFvlsOSj7fzdpKviRtuRpCQRt2lm4hcGRAmovWTDidfRhaW1aS9lk1OdjKRP0pVwJYuCQb)qaSmUTWHmuSEaaVbSYJTT5D2UrLYb5Pmy6PaKAam6CJeanUhpumCaMfVOaVxWEIRaM84(uj84F6jhKAamL6dQlyVgy4aSTErbEVG9exPEznp2qeEVaGSxGDywBAIPhgWhcy71b5WX0EbzVa7W0y1etpmG3awPDH4HjR4tf40cDDG7jjskDW7bf26ln8BHS8u(6LJ3Vs4jg66a3(LNAKKJo49GID9Lg(TqwwZ1Dywq849Pf66a3(LN6yFQbEpi7NxA43cz51oOxoUg2NNwORdC7xEQJ9Pg49GSFEPHFlKp19ZfpMFQH)GG8a0voa8EaqVF4EOwM6I3hk8heKhGV2daVha0hJvB)tKcTJq7g264JLsh)u4MUmcVeW)l)L9Z)NBYXJvZAalwvuSj)JxE5drfR2UaG96lZJwVnMWp8Z8wwG)D)lxeNU4YIvHp5L9em0OKl)bYC8Bvx7h)cotxwDLdCz5vjQR32hWpz7eyngbZ(FgN(7AMGFeNaKvSEn(TY5UNt8bC6dbV3Y7Q3vo4FYRi8J4T8GZ1xy9(lCEhsSL0x(4MtC6BMEz9gI(w8IWyAZNT33wHttTEB6MPKVvl68(I(y12aGwyQdOyab5B4Z0MnVv40eTC6zsVmFFjMX308uE84uGg0FcDpqwyL2F7DSsfvXSYg)XkD3oMhl9KGYnoHhGtUXi4KxoeYWrcz4OMmC0KmC0GmCKsg)L6V7v9)vIDi0C99lLijN0noIJTZgxc3dLCqb5gf7X8BieGJycq9oFXXWLraoAraohhbqDDtjsii64coeW7if8oNcWx1isvGEulQtVd)72X9a2(dGwxGVD(e(ShBpPjcF(k8Df(eCtWnf0dunEWmngDgd)x4(lAoewKJywKJmwKO2oHwBtolYPhwe)HEr4tKXICeXIKVFVdIfv2Ku4QqKVRHvSk732(L2BQ14RFlOPgeHWCQ0gIJsrRtCK1hpGHGzohnM1PJ8eeH7HGz13SB84MdnUztHzhtxeEqnr4H0dHIyoTptNU1tK5dvl711(rZojuKcv7Z0bZe57JcZ668t7(jKRDcz7IuDuQKCRbEc0TePQu(ewSD2uwIHeXZF8(wHQdZ8G5IuCafbVyOstNlSe5a5mvALyogJ0dB0DcHvngS)hTuD5)0P2nxMB0bmk)sPki)OXxPduLD5NDGjCX9Dq9aHIGBKFTHe(oy7cwcjTt4QZ3Wus208FZtf)U0FCtPQYa8K)1wywP)Hk1o6FIZ0euuk)gjuzlk(7NqvjCKdh67XTkZ7ka2SiHKpCtKQNCeGT67)ZJrzfqwp4nspEHGvdE6IuW9fFqkTSbanQD6gfWwvM2zV10L5cS79gcNkH3gHcUy1IsMzFTWR6Vjwq0cTl3ggUH7JAdm1IjttJW8C8ArdERLr(rfZMABCgrgx9aW1swEX4TBio5oJ5R(3e3R24drWGP7bMgHHJ9xLLMK(eKuxyIPHIRGpA(7kCvM3wMqi5Qjf8Ydtg1ns6mmQrioAkwYA4LWYYvDh1zW6)vN6giCmMmx2DntsuYTtVXKSiBlE385S6TLcqxaPx79LpwzKSaTiZcW3pNwHRrqr)1hA524yqE6VcHerhDMLrZi308rDONbYzfPEWnFuJenmAcTD6PP0OKpoQIuPWVkc9chlRZRvSZsbtbVc86ogVYfB)nIFq2Fcci08nxBDE1VbJacuKQcSMe9WrDr5BNwDJ1E(ekJH21PASfAhNXOsnDXFDoVOzCM3ov4aRdC98w7Dvllk7A6KouF2B8Y33Cdv6L4rSTIYxBug8HO71YTBQTNVfmJfQObd5SUAaB3yAivwEBnJWbtLTd(aKvx)fK726Bf8a8JUAELMarQzBzAOqAs7OGspK5RAAP)Ir5PXPgYOb7D7EilfOEeCpg6gKwqnSBDGaU(Us1PxPsTqPrXA3oXILQFLSkEU5lK6hFqgQvZuQKONrKmFBSEcl8s(8lcjFTjJrvk(NqktI(ILmvmAO0QJw6FwTrqZ384tKraD2s0i)mlS(kcd6sv4s4R1n6lGKl5GZMy1ycX8Dog02d5)OildbAGag8tCAwGjkRvzfwl1fZtBucLz4dR8l89jHScs5XtgOXDD4DbKQoqKMs891of72DQumaGXOgdjff7w(xDXSNkdwNCuTOhw22KUJQAl(wgbzZNXyjqVtIqmrehf)V39Cw0Y)ps1v(P0Kxxq8DST87XfjrmWGoOQCjXBZl49VSCB2ZOAaUfcEOtGICQDPK)clUkCC53JXOOyuLj)SPocDoGBktHPHyfJPVNMdveTHGzTjEwJyL7zkI5l9kcngTr2NlVD7OEeL9LmhjulTkonWz4cA9lTxUarxXF(0bnprFsybRIgpSm2Yu4e)h)ZBNo69V5QZRnRP)a2FXn1)SWpC6eBCz0kAHxJknjyteFMm0ofd9T(EGmo2LnBPBNY4AMDAOeOTvBPoOOQRQ7z2gsU6WfZcLIggfr(FgVMWhmc9n8Ul)R7hRGJM3jBv7t2n3)UU3s(Mhnw)hn57ajOAxcVTUsQfPLrhs58PEmGNhLl6nRz)pKyEj1dfgSmLlo3YTLymIXacq5btW354zKeVgDGbsEgxGoxTXVPctzP(FEPhMxVOcjvUsKj7ko11rPm0rLO9F1XY8nJK6BM8CttCbdJr9UQIJL4sYDyrncGR)y4e6GVmYm2FJsqXgWE46qyqbUlIbd601u(pda8znIR5BqnqdzSFQOLB6WmmWbb)AD1abRJiKCiLvMk4pMFxw8FiDZvNrswfs09MQs3Zqrw4ZUIHrrxjCrzYvBu5LN7gMTL81lQKNX8tLZBojoyLzjFq2sDkaRT6cimB6n9ujIBAkLJOkqEBj)zCn1b(rd93wuMjBZ6aB2Ujkg1KG)6xaI0l)39AYrVYP5uBgUn9N02VZThe3o0FvkzVEimVobJjUUZBIaVaFDYBGEYt3G12ihr3SuVSVsiWb5(BTxIhiaV2c(hH(RK5BtaEGOQiN0WV3Dlr6DrGsmZXI8pqOznFu1cIGLWtkG3Y9X0Oa)0SqczmEJFXSPxBj3)gWgGzbVosQn7Gjq46kIrzXB6ddJVshwyTxvAerR0)1ALa5AtgDJDHo8EQ93RsKlvmYrj3krhghQE1XAgRawVTbwCzDqgtVf(OSIh09I(YfclbGKqY8cEw8StV50eqs9E0XmFLWkSsNEYSRmeLrDpUTBQJ0bLDVJL807NyAwjKz5sy1U1JMN0pn)(VzKNJCYd03fwzfnjBN(jBBNVz0Tns3hf9zRb9DZ3m6Z6OPpWVB)u4XzSkff1dd1ZWsic2TU9gI4)MmUkjopNYVk8iHXuWUMFB(LCXSimhmmRs(qVBsKuuK6M8ijx450ubPc5VHVtLK2xAmlgioT6BNoXqZUHRBRSv3eGekuRoLtbmWQEPSAc3o9kLMuxzkT1kASPTmoBK42IcL6sRrU5jGh5Cc4rujXjrxqzxRj(ve2I7KGx6GiYB816ZAJbdnke0G9uNx3rkGD4bS8tUqFeQKt7Iwwj2njL0wrzXvj2(AMTqQbxciDDLiea8bM)5UTu1HOOkdL6vVH9ycDOtpyNWp1tSUy0eR3y7uVyx3d2N55DyTx4yDoDMQybhpV17qZV1kG(GL55YpcJOVfomZbCSlPeUCJ8glE7FwULYJ)aMXKGh3uYcBlHNDG6ZJIYtZLYtec9e39etlzIBpRqMvjzYoJm5kiwtI90IrkZEvoqRIwI9MEPPoPgcsEITrple8oLle8ovA743a96Mr3MzlzgGtofhYkJrhIHJ0AyljHn(YoHRaZgmsktpq3ZozkzRMTjbIk3zTa9AS0luujZE6s971cntzeOOwQx05WH9W7OYutaHqTUkTTIWZ7Ym2Gt1udZrOgMgR2P4ui9VbAy28Ay2FD0WS79KEPYNQknmhgp56PHbbr8dyIa7NFxbjtGYR04)(F7h)P2dd049Z)uqyz)SuScpopGYqCW(5lcXZtuDNTTFoM4w1hBbGBHhEYQRB5Y3c)38O1BWsmn3dBjM8qSDCihAOvqiQ4PjICRmh5hI04(5brlHGnlHoc2F63UBCx7cMTAGoulCayp(BBFLnrQkqC0C(EnKOj08osoLxSPMWlXe7DR7K6mWj1rLAIz5we8PL4r7cfBPjHDpLx7NdkjpgfGhkEpusTC5BRhb2RsPW)nR81AMaq3a(PiaWjHrLpVFOTaGepCK7CJnk1olMEqPmOC10E51kfWQdFIpaNSq8cnPANPMyj1RLJ0ovuiUqhrMIq9mgr1mdZSgB3nrqkdcvX4ixi5iwiDSli1RqsPbXovx5cVOcjjHnlxFuhHKJEcPVB7CsTDeXigSC47MhhT5HigHwYbsYJlcZHebrrsE3cIilsvHYEIetjPuwca589QMUsQ6Gs9vwGloX)Y4a(N50R()uO3M0(tVaHH7kimTEojE1NJbRX3yCwZgxtXLPRUmtNv)MHCdpX051)1MFw6vnf)lsFFnjPV6o1O5f2deIm3Pu1xvgNCIPzF7JK1y7tNi)T53EJbTreYblDi83FN32IvPz3F3DEHXG6((5J(K)Zx8)eIH2(FqUQ1(X7lG)39)))]] )