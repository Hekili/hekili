-- EvokerPreservation.lua
-- DF Season 1 Jan 2023

if UnitClassBase( "player" ) ~= "EVOKER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local GetSpellInfo = C_Spell.GetSpellInfo

local spec = Hekili:NewSpecialization( 1468 )

spec:RegisterResource( Enum.PowerType.Essence )
spec:RegisterResource( Enum.PowerType.Mana--[[, {
    disintegrate = {
        channel = "disintegrate",
        talent = "energy_loop",

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.disintegrate.tick_time ) * class.auras.disintegrate.tick_time
        end,

        interval = function () return class.auras.disintegrate.tick_time end,
      value = function () return 0.024 * mana.max end, -- TODO: Check if should be modmax.
    }
}]] --TODO: this breaks and causes bugs because it isn't referencing mana well from State.lua, but it wouldn't be discovered in Devastation testing because Devastation doesn't have the Energy Loop talent.
)

-- Talents
spec:RegisterTalents( {
    -- Evoker
    aerial_mastery                  = { 93352, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame                   = { 93271, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream            = { 93292, 376930, 2 }, -- Your healing done and healing received are increased by 2%.
    blast_furnace                   = { 93309, 375510, 1 }, -- Fire Breath's damage over time lasts 4 sec longer.
    bountiful_bloom                 = { 93291, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame               = { 93294, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 41,237 upon removing any effect.
    clobbering_sweep                = { 93296, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 45 sec.
    draconic_legacy                 = { 93300, 376166, 1 }, -- Your Stamina is increased by 6%.
    enkindled                       = { 93295, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    expunge                         = { 93306, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    extended_flight                 = { 93349, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance                      = { 93299, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    fire_within                     = { 93345, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    foci_of_life                    = { 93345, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over 4 sec.
    forger_of_mountains             = { 93270, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    heavy_wingbeats                 = { 93296, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 45 sec.
    inherent_resistance             = { 93355, 375544, 2 }, -- Magic damage taken reduced by 2%.
    innate_magic                    = { 93302, 375520, 2 }, -- Essence regenerates 5% faster.
    instinctive_arcana              = { 93310, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    landslide                       = { 93305, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 15 sec. Damage may cancel the effect.
    leaping_flames                  = { 93343, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth                     = { 93347, 375561, 2 }, -- Green spells restore 5% more health.
    natural_convergence             = { 93312, 369913, 1 }, -- Disintegrate channels 20% faster and Eruption's cast time is reduced by 20%.
    obsidian_bulwark                = { 93289, 375406, 1 }, -- Obsidian Scales has an additional charge.
    obsidian_scales                 = { 93304, 363916, 1 }, -- Reinforce your scales, reducing damage taken by 30%. Lasts 13.9 sec.
    oppressing_roar                 = { 93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    overawe                         = { 93297, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 30 sec.
    panacea                         = { 93348, 387761, 1 }, -- Emerald Blossom and Verdant Embrace instantly heal you for 18,409 when cast.
    permeating_chill                = { 93303, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by 50% for 3 sec.
    potent_mana                     = { 93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by 3%.
    protracted_talons               = { 93307, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                           = { 93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall                          = { 93301, 371806, 1 }, -- You may reactivate Breath of Eons within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic              = { 93353, 387787, 1 }, -- Your Leech is increased by 2%.
    renewing_blaze                  = { 93354, 374348, 1 }, -- The flames of life surround you for 9.3 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    rescue                          = { 93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    scarlet_adaptation              = { 93340, 372469, 1 }, -- Store 20% of your effective healing, up to 23,667. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk                      = { 93293, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic                 = { 93344, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 1.2 |4hour:hrs;. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    spatial_paradox                 = { 93351, 406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by 100% for 11.6 sec. Affects the nearest healer within 60 yds, if you do not have a healer targeted.
    tailwind                        = { 93290, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    terror_of_the_skies             = { 93342, 371032, 1 }, -- Breath of Eons stuns enemies for 3 sec.
    time_spiral                     = { 93351, 374968, 1 }, -- Bend time, allowing you and your allies within 40 yds to cast their major movement ability once in the next 11.6 sec, even if it is on cooldown.
    tip_the_scales                  = { 93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian                   = { 93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5.8 sec.
    unravel                         = { 93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 88,285 Spellfrost damage to absorb shields.
    verdant_embrace                 = { 93341, 360995, 1 }, -- Fly to an ally and heal them for 73,873, or heal yourself for the same amount.
    walloping_blow                  = { 93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec. 
    zephyr                          = { 93346, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 9.3 sec.
    -- Augmentation
    accretion                       = { 93229, 407876, 1 }, -- Eruption reduces the remaining cooldown of Upheaval by 1.0 sec.
    anachronism                     = { 93223, 407869, 1 }, -- Prescience has a 35% chance to grant Essence Burst.
    arcane_reach                    = { 93225, 454983, 1 }, -- The range of your helpful magics is increased by 5 yards.
    aspects_favor                   = { 93217, 407243, 2 }, -- Obsidian Scales activates Black Attunement, and amplifies it to increase maximum health by 4.0% for 13.9 sec. Hover activates Bronze Attunement, and amplifies it to increase movement speed by 25% for 4.6 sec.
    bestow_weyrnstone               = { 93195, 408233, 1 }, -- Conjure a pair of Weyrnstones, one for your target ally and one for yourself. Only one ally may bear your Weyrnstone at a time. A Weyrnstone can be activated by the bearer to transport them to the other Weyrnstone's location, if they are within 100 yds.
    blistering_scales               = { 93209, 360827, 1 }, -- Protect an ally with 15 explosive dragonscales, increasing their Armor by 30% of your own. Melee attacks against the target cause 1 scale to explode, dealing 3,675 Volcanic damage to enemies near them. This damage can only occur every few sec. Blistering Scales can only be placed on one target at a time. Casts on your enemy's target if they have one.
    breath_of_eons                  = { 93234, 403631, 1 }, -- Fly to the targeted location, exposing Temporal Wounds on enemies in your path for 11.6 sec. Temporal Wounds accumulate 11% of damage dealt by your allies affected by Ebon Might, then critically strike for that amount as Arcane damage. Applies Ebon Might for 5 sec. Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    chrono_ward                     = { 93235, 409676, 1 }, -- When allies deal damage with Temporal Wounds, they gain a shield for 100% of the damage dealt. Absorption cannot exceed 30% of your maximum health.
    defy_fate                       = { 93222, 404195, 1 }, -- Fatal attacks are diverted into a nearby timeline, preventing the damage, and your death, in this one. The release of temporal energy restores 168,392 health to you, and 56,131 to 4 nearby allies, over 9 sec. Healing starts high and declines over the duration. May only occur once every 6 min.
    draconic_attunements            = { 93218, 403208, 1 }, -- Learn to attune yourself to the essence of the Black or Bronze Dragonflights: Black Attunement: You and your 4 nearest allies have 2% increased maximum health. Bronze Attunement:You and your 4 nearest allies have 10% increased movement speed.
    dream_of_spring                 = { 93359, 414969, 1 }, -- Emerald Blossom no longer has a cooldown, deals 35% increased healing, and increases the duration of your active Ebon Might effects by 1 sec, but costs 3 Essence.
    ebon_might                      = { 93198, 395152, 1 }, -- Increase your 4 nearest allies' primary stat by 6.5% of your own, and cause you to deal 22% more damage, for 11.6 sec. May only affect 4 allies at once, and prefers to imbue damage dealers. Eruption, Breath of Eons, and your empower spells extend the duration of these effects.
    echoing_strike                  = { 93221, 410784, 1 }, -- Azure Strike deals 15% increased damage and has a 10% chance per target hit to echo, casting again.
    eruption                        = { 93200, 395160, 1 }, -- Cause a violent eruption beneath an enemy's feet, dealing 34,309 Volcanic damage split between them and nearby enemies. Increases the duration of your active Ebon Might effects by 1 sec.
    essence_attunement              = { 93219, 375722, 1 }, -- Essence Burst stacks 2 times.
    essence_burst                   = { 93220, 396187, 1 }, -- Your Living Flame has a 20% chance, and your Azure Strike has a 15% chance, to make your next Eruption cost no Essence. Stacks 2 times.
    fate_mirror                     = { 93367, 412774, 1 }, -- Prescience grants the ally a chance for their spells and abilities to echo their damage or healing, dealing 15% of the amount again.
    font_of_magic                   = { 93231, 408083, 1 }, -- Your empower spells' maximum level is increased by 1, and they reach maximum empower level 20% faster.
    hoarded_power                   = { 93212, 375796, 1 }, -- Essence Burst has a 20% chance to not be consumed.
    ignition_rush                   = { 93230, 408775, 1 }, -- Essence Burst reduces the cast time of Eruption by 40%.
    imminent_destruction            = { 102248, 459537, 1 }, -- Breath of Eons reduces the Essence cost of Eruption by 1 and increases its damage by 10% for 12 sec after you land.
    imposing_presence               = { 93199, 371016, 1 }, -- Quell's cooldown is reduced by 20 sec.
    infernos_blessing               = { 93197, 410261, 1 }, -- Fire Breath grants the inferno's blessing for 9.3 sec to you and your allies affected by Ebon Might, giving their damaging attacks and spells a high chance to deal an additional 10,782 Fire damage.
    inner_radiance                  = { 93199, 386405, 1 }, -- Your Living Flame and Emerald Blossom are 30% more effective on yourself.
    interwoven_threads              = { 93369, 412713, 1 }, -- The cooldowns of your spells are reduced by 10%.
    molten_blood                    = { 93211, 410643, 1 }, -- When cast, Blistering Scales grants the target a shield that absorbs up to 106,038 damage for 34.9 sec based on their missing health. Lower health targets gain a larger shield.
    molten_embers                   = { 102249, 459725, 1 }, -- Fire Breath causes enemies to take 20% increased damage from your Black spells.
    momentum_shift                  = { 93207, 408004, 1 }, -- Consuming Essence Burst grants you 5% Intellect for 7.0 sec. Stacks up to 2 times.
    motes_of_possibility            = { 93227, 409267, 1 }, -- Eruption has a 15% chance to form a mote of diverted essence near you. Allies who comes in contact with the mote gain a random buff from your arsenal.
    overlord                        = { 93213, 410260, 1 }, -- Breath of Eons casts an Eruption at the first 3 enemies struck. These Eruptions have a 100% chance to create a Mote of Possibility.
    perilous_fate                   = { 93235, 410253, 1 }, -- Breath of Eons reduces enemies' movement speed by 70%, and reduces their attack speed by 50%, for 11.6 sec.
    plot_the_future                 = { 93226, 407866, 1 }, -- Breath of Eons grants you Fury of the Aspects for 15 sec after you land, without causing Exhaustion.
    power_nexus                     = { 93201, 369908, 1 }, -- Increases your maximum Essence to 6.
    prescience                      = { 93358, 409311, 1 }, -- Grant an ally the gift of foresight, increasing their critical strike chance by 3% for 20.9 sec. Affects the nearest ally within 25 yds, preferring damage dealers, if you do not have an ally targeted.
    prolong_life                    = { 93359, 410687, 1 }, -- Your effects that extend Ebon Might also extend Symbiotic Bloom.
    pupil_of_alexstrasza            = { 93221, 407814, 1 }, -- When cast at an enemy, Living Flame strikes 1 additional enemy for 100% damage.
    reactive_hide                   = { 93210, 409329, 1 }, -- Each time Blistering Scales explodes it deals 15% more damage for 13.9 sec, stacking 10 times.
    regenerative_chitin             = { 93211, 406907, 1 }, -- Blistering Scales has 5 more scales, and casting Eruption restores 1 scale.
    ricocheting_pyroclast           = { 93208, 406659, 1 }, -- Eruption deals 30% more damage per enemy struck, up to 150%.
    rumbling_earth                  = { 93205, 459120, 1 }, -- Upheaval causes an aftershock at its location, dealing 50% of its damage 2 additional times.
    seismic_slam                    = { 93368, 408543, 1 }, -- Landslide causes enemies who are mid-air to be slammed to the ground, stunning them for 4 sec.
    stretch_time                    = { 93382, 410352, 1 }, -- While flying during Breath of Eons, 50% of damage you would take is instead dealt over 10 sec.
    symbiotic_bloom                 = { 93215, 410685, 2 }, -- Emerald Blossom increases targets' healing received by 3% for 11.6 sec.
    tectonic_locus                  = { 93202, 408002, 1 }, -- Upheaval deals 50% increased damage to the primary target, and launches them higher.
    time_skip                       = { 93232, 404977, 1 }, -- Surge forward in time, causing your cooldowns to recover 1,000% faster for 2 sec.
    timelessness                    = { 93360, 412710, 1 }, -- Enchant an ally to appear out of sync with the normal flow of time, reducing threat they generate by 30% for 34.9 min. Less effective on tank-specialized allies. May only be placed on one target at a time.
    tomorrow_today                  = { 93369, 412723, 1 }, -- Time Skip channels for 1 sec longer.
    unyielding_domain               = { 93202, 412733, 1 }, -- Upheaval cannot be interrupted, and has an additional 10% chance to critically strike.
    upheaval                        = { 93203, 396286, 1 }, -- Gather earthen power beneath your enemy's feet and send them hurtling upwards, dealing 52,689 Volcanic damage to the target and nearby enemies. Increases the duration of your active Ebon Might effects by 2 sec. Empowering expands the area of effect. I: 3 yd radius. II: 6 yd radius. III: 9 yd radius.
    volcanism                       = { 93206, 406904, 1 }, -- Eruption's Essence cost is reduced by 1.
    -- Chronowarden
    afterimage                      = { 94929, 431875, 1 }, -- Empower spells send up to 3 Chrono Flames to your targets.
    chrono_flame                    = { 94954, 431442, 1 }, -- Living Flame is enhanced with Bronze magic, repeating 25% of the damage or healing you dealt to the target in the last 5 sec as Arcane, up to 29,455.
    doubletime                      = { 94932, 431874, 1 }, -- Ebon Might and Prescience gain a chance equal to your critical strike chance to grant 50% additional stats.
    golden_opportunity              = { 94942, 432004, 1 }, -- Prescience has a 20% chance to cause your next Prescience to last 100% longer.
    instability_matrix              = { 94930, 431484, 1 }, -- Each time you cast an empower spell, unstable time magic reduces its cooldown by up to 6 sec.
    master_of_destiny               = { 94930, 431840, 1 }, -- Casting Essence spells extends all your active Threads of Fate by 1 sec.
    motes_of_acceleration           = { 94935, 432008, 1 }, -- Warp leaves a trail of Motes of Acceleration. Allies who come in contact with a mote gain 20% increased movement speed for 30 sec.
    primacy                         = { 94951, 431657, 1 }, -- For each damage over time effect from Upheaval, gain 3% haste, up to 9%.
    reverberations                  = { 94925, 431615, 1 }, -- Upheaval deals 50% additional damage over 8 sec.
    temporal_burst                  = { 94955, 431695, 1 }, -- Tip the Scales overloads you with temporal energy, increasing your haste, movement speed, and cooldown recovery rate by 30%, decreasing over 30 sec.
    temporality                     = { 94935, 431873, 1 }, -- Warp reduces damage taken by 20%, starting high and reducing over 3 sec.
    threads_of_fate                 = { 94947, 431715, 1 }, -- Casting an empower spell during Temporal Burst causes a nearby ally to gain a Thread of Fate for 10 sec, granting them a chance to echo their damage or healing spells, dealing 15% of the amount again.
    time_convergence                = { 94932, 431984, 1 }, -- Non-defensive abilities with a 45 second or longer cooldown grant 5% Intellect for 15 sec. Essence spells extend the duration by 1 sec.
    warp                            = { 94948, 429483, 1 }, -- Hover now causes you to briefly warp out of existence and appear at your destination. Hover's cooldown is also reduced by 5 sec. Hover continues to allow Evoker spells to be cast while moving.
    -- Scalecommander
    bombardments                    = { 94936, 434300, 1 }, -- Mass Eruption marks your primary target for destruction for the next 10 sec. You and your allies have a chance to trigger a Bombardment when attacking marked targets, dealing 15,929 Volcanic damage split amongst all nearby enemies.
    diverted_power                  = { 94928, 441219, 1 }, -- Bombardments have a chance to generate Essence Burst.
    extended_battle                 = { 94928, 441212, 1 }, -- Essence abilities extend Bombardments by 1 sec.
    hardened_scales                 = { 94933, 441180, 1 }, -- Obsidian Scales reduces damage taken by an additional 5%.
    maneuverability                 = { 94941, 433871, 1 }, -- Breath of Eons can now be steered in your desired direction. In addition, Breath of Eons burns targets for 92,245 Volcanic damage over 12 sec.
    mass_eruption                   = { 98931, 438587, 1 }, -- Empower spells cause your next Eruption to strike up to 3 targets. When striking less than 3 targets, Eruption damage is increased by 25% for each missing target.
    melt_armor                      = { 94921, 441176, 1 }, -- Breath of Eons causes enemies to take 20% increased damage from Bombardments and Essence abilities for 12 sec.
    menacing_presence               = { 94933, 441181, 1 }, -- Knocking enemies up or backwards reduces their damage done to you by 15% for 8 sec.
    might_of_the_black_dragonflight = { 94952, 441705, 1 }, -- Black spells deal 20% increased damage.
    nimble_flyer                    = { 94943, 441253, 1 }, -- While Hovering, damage taken from area of effect attacks is reduced by 10%.
    onslaught                       = { 94944, 441245, 1 }, -- Entering combat grants a charge of Burnout, causing your next Living Flame to cast instantly.
    slipstream                      = { 94943, 441257, 1 }, -- Deep Breath resets the cooldown of Hover.
    unrelenting_siege               = { 94934, 441246, 1 }, -- For each second you are in combat, Azure Strike, Living Flame, and Eruption deal 1% increased damage, up to 15%.
    wingleader                      = { 94953, 441206, 1 }, -- Bombardments reduce the cooldown of Breath of Eons by 1 sec for each target struck, up to 3 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( { 
    born_in_flame        = 5612, -- (414937) Casting Ebon Might grants 2 charges of Burnout, reducing the cast time of Living Flame by 100%.
    chrono_loop          = 5564, -- (383005) Trap the enemy in a time loop for 5 sec. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below 20%.
    divide_and_conquer   = 5557, -- (384689) Breath of Eons forms curtains of fire, preventing line of sight to enemies outside its walls and burning enemies who walk through them for 88,223 Fire damage. Lasts 6 sec.
    dream_catcher        = 5613, -- (410962) Sleep Walk no longer has a cooldown, but its cast time is increased by 0.2 sec.
    dream_projection     = 5559, -- (377509) Summon a flying projection of yourself that heals allies you pass through for 17,673. Detonating your projection dispels all nearby allies of Magical effects, and heals for 87,481 over 20 sec.
    dreamwalkers_embrace = 5615, -- (415651) Verdant Embrace tethers you to an ally, increasing movement speed by 40% and slowing and siphoning 15,316 life from enemies who come in contact with the tether. The tether lasts up to 10 sec or until you move more than 30 yards away from your ally.
    nullifying_shroud    = 5558, -- (378464) Wreathe yourself in arcane energy, preventing the next 3 full loss of control effects against you. Lasts 30 sec.
    obsidian_mettle      = 5563, -- (378444) While Obsidian Scales is active you gain immunity to interrupt, silence, and pushback effects.
    scouring_flame       = 5561, -- (378438) Fire Breath burns away 1 beneficial Magic effect per empower level from all targets.
    swoop_up             = 5562, -- (370388) Grab an enemy and fly with them to the target location.
    time_stop            = 5619, -- (378441) Freeze an ally's timestream for 5 sec. While frozen in time they are invulnerable, cannot act, and auras do not progress. You may reactivate Time Stop to end this effect early.
    unburdened_flight    = 5560, -- (378437) Hover makes you immune to movement speed reduction effects.
} )


-- Auras
spec:RegisterAuras( {
    call_of_ysera = {
        id = 373835,
        duration = 15,
        max_stack = 1
    },
    dream_breath = { -- TODO: This is the empowerment cast.
        id = 355936,
        duration = 2.5,
        max_stack = 1
    },
    dream_breath_hot = {
        id = 355941,
        duration = function ()
            return 16 - (4 * (empowerment_level - 1))
        end,
        tick_time = 2,
        max_stack = 1
    },
    dream_breath_hot_echo = { -- This is the version applied when the target has your Echo on it.
        id = 376788,
        duration = function ()
            return 16 - (4 * (empowerment_level - 1))
        end,
        tick_time = 2,
        max_stack = 1
    },
    dream_projection = { -- TODO: PvP talent summon/pet?
        id = 377509,
        duration = 5,
        max_stack = 1
    },
    dreamwalker = {
        id = 377082,
    },
    emerald_blossom = { -- TODO: Check Aura (https://wowhead.com/beta/spell=355913)
        id = 355913,
        duration = 2,
        max_stack = 1
    },
    essence_burst = { -- This is the Preservation version of the talent.
        id = 369299,
        duration = 15,
        max_stack = function() return talent.essence_attunement.enabled and 2 or 1 end,
    },
    fire_breath = {
        id = 357209,
        duration = function ()
            return 4 * empowerment_level
        end,
        -- TODO: damage = function () return 0.322 * stat.spell_power * action.fire_breath.spell_targets * ( talent.heat_wave.enabled and 1.2 or 1 ) * ( debuff.shattering_star.up and 1.2 or 1 ) end,
        max_stack = 1,
    },
    flow_state = {
        id = 390148,
        duration = 10,
        max_stack = 1
    },
    fly_with_me = {
        id = 370665,
        duration = 1,
        max_stack = 1
    },
    hover = {
        id = 358267,
        duration = function () return talent.extended_flight.enabled and 8 or 6 end,
        tick_time = 1,
        max_stack = 1
    },
    lifebind = {
        id = 373267,
        duration = 5,
        max_stack = 1
    },
    mastery_lifebinder = {
        id = 363510,
    },
    nullifying_shroud = {
        id = 378464,
        duration = 30,
        max_stack = 3
    },
    ouroboros = {
        id = 387350,
        duration = 3600,
        max_stack = 5
    },
    reversion = {
        id = 366155,
        duration = 12,
        tick_time = 2,
        max_stack = 1
    },
    reversion_echo = {  -- This is the version applied when the target has your Echo on it.
        id = 367364,
        duration = 12,
        tick_timer = 2,
        max_stack = 1
    },
    rewind = {
        id = 363534,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    spiritbloom = { -- TODO: This is the empowerment channel.
        id = 367226,
        duration = 2.5,
        max_stack = 1
    },
    stasis = {
        id = 370537,
        duration = 3600,
        max_stack = 3
    },
    stasis_ready = {
        id = 370562,
        duration = 30,
        max_stack = 1
    },
    temporal_anomaly = { -- TODO: Creates an absorb vortex effect.
        id = 373861,
        duration = 6,
        tick_time = 2,
        max_stack = 1
    },
    temporal_compression = {
        id = 362877,
        duration = 15,
        max_stack = 4
    },
    time_dilation = {
        id = 357170,
        duration = 8,
        max_stack = 1
    },
    time_stop = {
        id = 378441,
        duration = 4,
        max_stack = 1
    },
    youre_coming_with_me = {
        id = 370388,
        duration = 1,
        max_stack = 1
    }
} )

local lastEssenceTick = 0
local actual_empowered_spell_count, essence_rush_gained = 0, 0

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

    local empowered_spells = {
        [382266] = 1,
        [357208] = 1,
        [382731] = 1,
        [367226] = 1,
        [382614] = 1,
        [355936] = 1
    }

    spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
        if sourceGUID ~= state.GUID or state.set_bonus.tier30_4pc == 0 then return end

        local now = GetTime()

        if subtype == "SPELL_CAST_SUCCESS" and empowered_spells[ spellID ] and now - essence_rush_gained > 0.5 then
            actual_empowered_spell_count = actual_empowered_spell_count + 1

        elseif ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_APPLIED_DOSE" or subtype == "SPELL_AURA_REFRESH" ) and spellID == 409899 then
            essence_rush_gained = now
            actual_empowered_spell_count = 0
        end
    end )
end

spec:RegisterGear( "tier30", 202491, 202489, 202488, 202487, 202486 )
-- 2 pieces (Preservation) : Spiritbloom applies a heal over time effect for 40% of healing done over 8 sec. Dream Breath's healing is increased by 15%.
spec:RegisterAura( "spiritbloom", {
    id = 409895,
    duration = 8,
    tick_time = 2,
    max_stack = 1
} )
-- 4 pieces (Preservation) : After casting 3 empower spells, gain Essence Burst immediately and another 3 sec later.
spec:RegisterAura( "essence_rush", {
    id = 409899,
    duration = 3,
    max_stack = 1
} )

spec:RegisterGear( "tier31", 207225, 207226, 207227, 207228, 207230 )


spec:RegisterStateExpr( "empowered_spell_count", function()
    return actual_empowered_spell_count
end )

local TriggerEssenceRushT30 = setfenv( function()
    addStack( "essence_burst" )
end, state )

spec:RegisterStateExpr( "empowerment_level", function()
    return buff.tip_the_scales.down and args.empower_to or max_empower
end )

-- This deserves a better fix; when args.empower_to = "maximum" this will cause that value to become max_empower (i.e., 3 or 4).
spec:RegisterStateExpr( "maximum", function()
    return max_empower
end )

spec:RegisterStateExpr( "empowered_spell_count", function()
    return actual_empowered_spell_count
end )

spec:RegisterHook( "runHandler", function( action )
    local ability = class.abilities[ action ]
    local color = ability.color

    empowerment.active = false

    if set_bonus.tier30_4pc > 0 and ability.empowered then
        if empowered_spell_count == 3 then
            empowered_spell_count = 0
            applyBuff( "essence_rush" )
            addStack( "essence_burst" )
            state:QueueAuraEvent( "essence_rush", TriggerEssenceRushT30, buff.essence_rush.expires, "AURA_EXPIRATION" )
        else
            empowered_spell_count = empowered_spell_count + 1
        end
    end
end )

spec:RegisterGear( "tier29", 200381, 200383, 200378, 200380, 200382, 217178, 217180, 217176, 217177, 217179 )
spec:RegisterAuras( {
    time_bender = {
        id = 394544,
        duration = 6,
        max_stack = 1
    },
    lifespark = {
        id = 394552,
        duration = 15,
        max_stack = 2
    }
} )


spec:RegisterHook( "reset_precast", function()
    max_empower = talent.font_of_magic.enabled and 4 or 3

    if essence.current < essence.max and lastEssenceTick > 0 then
        local partial = min( 0.95, ( query_time - lastEssenceTick ) * essence.regen )
        gain( partial, "essence" )
        if Hekili.ActiveDebug then Hekili:Debug( "Essence increased to %.2f from passive regen.", partial ) end
    end

    empowered_spell_count = nil
end )


spec:RegisterStateTable( "evoker", setmetatable( {},{
    __index = function( t, k )
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
        local power_level = args.empower_to or max_empower

        if settings.fire_breath_fixed > 0 then
            power_level = min( settings.fire_breath_fixed, max_empower )
        end

        return stages[ power_level ] * ( talent.font_of_magic.enabled and 0.8 or 1 ) * haste
    end, state )
end

-- Abilities
spec:RegisterAbilities( {
    cauterizing_flame = {
        id = 374251,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.014,
        spendType = "mana",

        startsCombat = false,

        healing = function () return 3.50 * stat.spell_power end,

        toggle = "interrupts",

        usable = function()
            return buff.dispellable_poison.up or buff.dispellable_curse.up or buff.dispellable_disease.up, "requires dispellable effect" --add dispellable_bleed later?
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_curse" )
            removeBuff( "dispellable_disease" )
            -- removeBuff( "dispellable_bleed" )
            health.current = min( health.max, health.current + action.cauterizing_flame.healing )
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,
    },
    chrono_loop = {
        id = 383005,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
        end,
    },
    disintegrate = {
        id = 356995,
        cast = function() return 3 * ( talent.natural_convergence.enabled and 0.8 or 1 ) end,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.essence_burst.up and 0 or 3 end,
        spendType = "essence",

        startsCombat = true,

        damage = function () return 2.28 * stat.spell_power * ( talent.energy_loop.enabled and 1.2 or 1 ) end,

        min_range = 0,
        max_range = 25,

        start = function ()
            removeStack( "essence_burst" )
            if talent.energy_loop.enabled then gain( 0.0277 * mana.max, "mana" ) end
        end,
    },
    dream_breath = {
        id = function() return talent.font_of_magic.enabled and 382614 or 355936 end,
        known = 355936,
        cast = empowered_cast_time,
        empowered = true,
        cooldown = 30,
        gcd = "off",
        icd = 0.5,

        spend = 0.049,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "dream_breath" )
            applyBuff( "dream_breath_hot" )
            removeBuff( "call_of_ysera" )
            removeBuff( "temporal_compression" )
            if talent.flow_state.enabled then applyBuff( "flow_state" ) end
            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
            end
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,

        copy = { 382614, 355936 }
    },
    dream_flight = {
        id = 359816,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    dream_projection = {
        id = 377509,
        cast = 0.5,
        cooldown = 90,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    echo = {
        id = 364343,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.essence_burst.up and 0 or 2 end,
        spendType = "essence",

        startsCombat = false,

        handler = function ()
            removeStack( "essence_burst" )
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )

            if talent.ouroboros.enabled then addStack( "ouroboros" ) end
            if talent.temporal_compression.enabled then addStack("temporal_compression") end
        end,
    },
    emerald_communion = {
        id = 370960,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    fire_breath = {
        id = function() return talent.font_of_magic.enabled and 382266 or 357208 end,
        known = 357208,
        cast = empowered_cast_time,
        empowered = true,
        cooldown = 30,
        gcd = "off",
        icd = 0.5,

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        caption = function()
            local power_level = settings.fire_breath_fixed
            if power_level > 0 then return power_level end
        end,

        spell_targets = function () return active_enemies end,
        damage = function () return 1.334 * stat.spell_power * ( 1 + 0.2 * talent.blast_furnace.rank ) end,

        handler = function()
            applyDebuff( "target", "fire_breath" )
            if talent.flow_state.enabled then applyBuff( "flow_state" ) end
            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
            else
                removeBuff( "temporal_compression" )
            end

            if talent.leaping_flames.enabled then applyBuff( "leaping_flames", nil, empowerment_level ) end
        end,

        copy = { 382266, 357208 }
    },
    living_flame = {
        id = 361469,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        damage = function () return 1.61 * stat.spell_power end,
        healing = function () return 2.75 * stat.spell_power * ( 1 + 0.03 * talent.enkindled.rank ) end,
        spell_targets = function () return buff.leaping_flames.up and min( active_enemies, 1 + buff.leaping_flames.stack ) end,

        handler = function ()
            removeBuff( "ancient_flame" )
            removeBuff( "leaping_flames" )
            removeBuff( "scarlet_adaptation" )
            removeBuff( "call_of_ysera" )
            removeStack( "lifespark" )
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,
    },
    naturalize = {
        id = 360823,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.014,
        spendType = "mana",

        startsCombat = false,

        toggle = "interrupts",

        usable = function()
            return buff.dispellable_poison.up or buff.dispellable_magic.up, "requires dispellable effect"
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_magic" )
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,
    },
    nullifying_shroud = {
        id = 378464,
        cast = 1.5,
        cooldown = 90,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    renewing_blaze = {
        id = 374348,
        cast = 0,
        cooldown = function () return talent.fire_within.enabled and 60 or 90 end,
        gcd = "off",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "renewing_blaze" )
            applyBuff( "renewing_blaze_heal" )
        end,
    },
    reversion = {
        id = 366155,
        cast = 0,
        charges = function() return talent.punctuality.enabled and 2 or 1 end,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",

        spend = 0.028,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "reversion" )
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,
    },
    rewind = {
        id = 363534,
        cast = 0,
        charges = function() return talent.erasure.enabled and 2 or nil end,
        cooldown = function() return talent.temporal_artificer.enabled and 180 or 240 end,
        recharge = function() return talent.temporal_artificer.enabled and 180 or 240 end,
        gcd = "spell",

        spend = 0.055,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
        end,
    },
    spiritbloom = {
        id = function() return talent.font_of_magic.enabled and 382731 or 367226 end,
        known = 367226,
        cast = empowered_cast_time,
        empowered = true,
        cooldown = 30,
        gcd = "off",
        icd = 0.5,

        spend = 0.042,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            if set_bonus.tier30_2pc > 0 then applyBuff( "spiritbloom" ) end
            if talent.flow_state.enabled then applyBuff( "flow_state" ) end
            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
            else
                removeBuff( "temporal_compression" )
            end
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,

        copy = { 382731, 367226 }
    },
    stasis = {
        id = function () return buff.stasis_ready.up and 370564 or 370537 end,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = function () return buff.stasis_ready.up and 0 or 0.04 end,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        usable = function () return buff.stasis_ready.up or buff.stasis.stack < 1, "Stasis not ready" end,

        handler = function ()
            if buff.stasis_ready.up then
                setCooldown( "stasis", 90 )
                removeBuff( "stasis_ready" )
            else
                if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
                addStack( "stasis", 3 )
            end
        end,

        copy = { 370564, 370537, "stasis" }
    },
    temporal_anomaly = {
        id = 373861,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
            if talent.resonating_sphere.enabled then applyBuff( "echo" ) end
            if talent.nozdormus_teachings.enabled then
                reduceCooldown( "dream_breath", 5 )
                reduceCooldown( "fire_breath", 5 )
                reduceCooldown( "spiritbloom", 5 )
            end
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,
    },
    time_dilation = {
        id = 357170,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0.022,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
        end,
    },
        -- Talent: Fly to an ally and heal them for 4,557.
    verdant_embrace = {
        id = 360995,
        cast = 0,
        cooldown = 24,
        gcd = "spell",
        school = "nature",
        color = "green",
        icd = 0.5,

        spend = 0.033,
        spendType = "mana",

        talent = "verdant_embrace",
        startsCombat = false,

        handler = function ()
            if talent.lifebind.enabled then applyBuff( "lifebind" ) end
            if talent.call_of_ysera.enabled then applyBuff( "call_of_ysera" ) end
        end,
    },
} )



spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )

local spellInfo = GetSpellInfo( 357210 )
local deep_breath = spellInfo and spellInfo.name or "Deep Breath"

spec:RegisterSetting( "use_deep_breath", true, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( 357210 ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended, which will force your character to select a destination and move.  By default, %s requires your Cooldowns "
        .. "toggle to be active.\n\n"
        .. "If unchecked, |W%s|w will never be recommended, which may result in lost DPS if left unused for an extended period of time.",
        Hekili:GetSpellLinkWithTexture( 357210 ), deep_breath, deep_breath ),
    width = "full",
} )

spellInfo = GetSpellInfo( 368432 )
local unravel = spellInfo and spellInfo.name or "Unravel"

spec:RegisterSetting( "use_unravel", false, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( 368432 ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended if your target has an absorb shield applied.  By default, %s also requires your Interrupts toggle to be active.",
        Hekili:GetSpellLinkWithTexture( 368432 ), unravel ),
    width = "full",
} )


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

spec:RegisterSetting( "spend_essence", false, {
    name = strformat( "%s: Spend Essence", Hekili:GetSpellLinkWithTexture( devastation.abilities.disintegrate.id ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended when you will otherwise max out on Essence and risk wasting resources.\n\n"
        .. "Recommendation: Leave disabled in content where you are actively healing and spending Essence on healing spells.", Hekili:GetSpellLinkWithTexture( devastation.abilities.disintegrate.id ) ),
    width = "full"
} )


spec:RegisterRanges( "azure_strike", "living_flame" )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 40,

    damage = true,
    damageDots = true,
    damageExpiration = 8,
    damageOnScreen = true,
    damageRange = 30,

    potion = "potion_of_spectral_intellect",

    package = "Preservation",
} )


spec:RegisterPack( "Preservation", 20231119, [[Hekili:LAv0UnQoq0VL(suRAf3cjDVPsT9H9PT9kvTsSpBSdmeSkGzTnP7wf5V97ydnXajvB2(qIShF85md2NrMes(bjoJPbYZrxhnpmm82GW53CB4TKy9VBasCdl9f2ACqnRc))7sqbYnmnxuBx83LcwMLeLOvMIaiXRA5L6hRjRoiZxVeX2aPKNdx8fCCbpld6adQus8pk4kd1(JzO9IBOICCEQvudTKR04Y5cPH(n4fEjpaZePiNxI63Hsf0iHur1kM(Y7)NvLGsXRxNiYt0fqYkPO(nW8K5PE0iMF2cLL(bszTAqYFZUV8sS49xSTwY2adWNbqdYmW0f(HBeUS2FVkiHRHkLFWCUe639vqvJ4vqMOf3hEfp)(C(6cDIeQy8A1dHlUmLP0jA(Wu6imenLHLNebZNsq0jrWclb9ZXpMbEW2UDiXhK2cXgqA5OsSb3)SvT55bUGbzIxRNPaTgJRcSFyDXhCSWXtEnSwIxfTK42nEDaQtXSOvQ0bTnZo)SoY3U1J9jz1fB32VZa7uS4sQy)6UDRVpvWB41zj9G9th2BTy1R0s(lU0XUYgibQHkoGFz9XwY3S7YNf7Fuo(rID4pGKyCKY6NF3PI2YxzYABLqIFep5KAiZqJg5bdmprIDJCDrGCwBPgh(SRRshusSZyrIHAgAdZiFLOrD8bmXOnc8CFW9gVrqw4dXZioc2n(W6mMJq8LbA9UrDeO)1cAFKD49UyJvLKBRkMnS3vCd9bdnCHHEPHU7mdzBNDHehA1y5NvJLFKerwjU9Zkr0hjXCReHxFAAC4Ueg62Ty)(j6FeLx4uoCKY7fPZfyOZm0robxSPTt2N2DtT0hDu6pydghZNBONzOVlVTMMAKhwyg6fDapqBhd9Ubi9t9bTF8CgE9cDvX8Jwfd7l1DCVNi)gloIwCuIoXkEVg(D)CACZFXj6rtzT9jd9VqyslRd)EHHDbCuGDUke49J)Jv4EiIlk5)d]] )
