-- EvokerPreservation.lua
-- January 2025

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
    aerial_mastery                  = {  93352, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame                   = {  93271, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream            = {  93292, 376930, 2 }, -- Your healing done and healing received are increased by 3%.
    blast_furnace                   = {  93309, 375510, 1 }, -- Fire Breath's damage over time lasts 4 sec longer.
    bombardments                    = {  94936, 434300, 1 }, -- Mass Eruption marks your primary target for destruction for the next 6 sec. You and your allies have a chance to trigger a Bombardment when attacking marked targets, dealing 73,725 Volcanic damage split amongst all nearby enemies.
    bountiful_bloom                 = {  93291, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame               = {  93294, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 65,292 upon removing any effect.
    clobbering_sweep                = { 103844, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 2 min.
    diverted_power                  = {  94928, 441219, 1 }, -- Bombardments have a chance to generate Essence Burst.
    draconic_legacy                 = {  93300, 376166, 1 }, -- Your Stamina is increased by 6%.
    enkindled                       = {  93295, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    expunge                         = {  93306, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    extended_battle                 = {  94928, 441212, 1 }, -- Essence abilities extend Bombardments by 1 sec.
    extended_flight                 = {  93349, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance                      = {  93299, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    fire_within                     = {  93345, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    foci_of_life                    = {  93345, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over 4 sec.
    forger_of_mountains             = {  93270, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    hardened_scales                 = {  94933, 441180, 1 }, -- Obsidian Scales reduces damage taken by an additional 10%.
    heavy_wingbeats                 = { 103843, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 2 min.
    inherent_resistance             = {  93355, 375544, 2 }, -- Magic damage taken reduced by 4%.
    innate_magic                    = {  93302, 375520, 2 }, -- Essence regenerates 5% faster.
    instinctive_arcana              = {  93310, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    landslide                       = {  93305, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 15 sec. Damage may cancel the effect.
    leaping_flames                  = {  93343, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth                     = {  93347, 375561, 2 }, -- Green spells restore 5% more health.
    maneuverability                 = {  94941, 433871, 1 }, -- Deep Breath can now be steered in your desired direction. In addition, Deep Breath burns targets for 128,628 Volcanic damage over 12 sec.
    melt_armor                      = {  94921, 441176, 1 }, -- Deep Breath causes enemies to take 20% increased damage from Bombardments and Essence abilities for 12 sec.
    menacing_presence               = {  94933, 441181, 1 }, -- Knocking enemies up or backwards reduces their damage done to you by 15% for 8 sec.
    might_of_the_black_dragonflight = {  94952, 441705, 1 }, -- Black spells deal 20% increased damage.
    natural_convergence             = {  93312, 369913, 1 }, -- Disintegrate channels 20% faster.
    nimble_flyer                    = {  94943, 441253, 1 }, -- While Hovering, damage taken from area of effect attacks is reduced by 10%.
    obsidian_bulwark                = {  93289, 375406, 1 }, -- Obsidian Scales has an additional charge.
    obsidian_scales                 = {  93304, 363916, 1 }, -- Reinforce your scales, reducing damage taken by 30%. Lasts 12 sec.
    onslaught                       = {  94944, 441245, 1 }, -- Entering combat grants a charge of Burnout, causing your next Living Flame to cast instantly.
    oppressing_roar                 = {  93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec. Removes 1 Enrage effect from each enemy.
    overawe                         = {  93297, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 30 sec.
    panacea                         = {  93348, 387761, 1 }, -- Emerald Blossom and Verdant Embrace instantly heal you for 24,717 when cast.
    potent_mana                     = {  93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by 3%.
    protracted_talons               = {  93307, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                           = {  93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall                          = {  93301, 371806, 1 }, -- You may reactivate Deep Breath within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic              = {  93353, 387787, 1 }, -- Your Leech is increased by 2%.
    renewing_blaze                  = {  93354, 374348, 1 }, -- The flames of life surround you for 8 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    rescue                          = {  93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location. Clears movement impairing effects from you and your ally.
    scarlet_adaptation              = {  93340, 372469, 1 }, -- Store 20% of your effective healing, up to 40,315. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk                      = {  93293, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    slipstream                      = {  94943, 441257, 1 }, -- Deep Breath resets the cooldown of Hover.
    source_of_magic                 = {  93344, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 1 |4hour:hrs;. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    spatial_paradox                 = {  93351, 406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by 100% for 10 sec. Affects the nearest healer within 60 yds, if you do not have a healer targeted.
    tailwind                        = {  93290, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    terror_of_the_skies             = {  93342, 371032, 1 }, -- Deep Breath stuns enemies for 3 sec.
    time_spiral                     = {  93351, 374968, 1 }, -- Bend time, allowing you and your allies within 40 yds to cast their major movement ability once in the next 10 sec, even if it is on cooldown.
    tip_the_scales                  = {  93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian                   = {  93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5 sec.
    unravel                         = {  93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 174,613 Spellfrost damage to absorb shields.
    unrelenting_siege               = {  94934, 441246, 1 }, -- For each second you are in combat, Azure Strike, Living Flame, and Eruption deal 1% increased damage, up to 15%.
    verdant_embrace                 = {  93341, 360995, 1 }, -- Fly to an ally and heal them for 99,187, or heal yourself for the same amount.
    walloping_blow                  = {  93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    wingleader                      = {  94953, 441206, 1 }, -- Bombardments reduce the cooldown of Breath of Eons by 1 sec for each target struck, up to 3 sec.
    zephyr                          = {  93346, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8 sec.

    -- Preservation
    call_of_ysera                   = {  93250, 373834, 1 }, -- Verdant Embrace increases the healing of your next Dream Breath by 40%, or your next Living Flame by 100%.
    cycle_of_life                   = {  93266, 371832, 1 }, -- Every 3 Emerald Blossoms leaves behind a tiny sprout which gathers 10% of your healing over 8 sec. The sprout then heals allies within 30 yds, divided evenly among targets.
    delay_harm                      = {  93335, 376207, 1 }, -- Time Dilation delays 70% of damage taken.
    dream_breath                    = {  93240, 355936, 1 }, -- Inhale, gathering the power of the Dream. Release to exhale, healing yourself and 5 injured allies in a 30 yd cone in front of you for 123,053. I: Heals 22,704 instantly and 100,349 over 16 sec. II: Heals 47,791 instantly and 75,262 over 12 sec. III: Heals 72,878 instantly and 50,174 over 8 sec.
    dream_flight                    = {  93267, 359816, 1 }, -- Take in a deep breath and fly to the targeted location, healing all allies in your path for 47,458 immediately, and 32,763 over 15 sec. Healing increased by 100% when not in a raid. Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    dreamwalker                     = {  93244, 377082, 1 }, -- You are able to move while communing with the Dream.
    echo                            = {  93339, 364343, 1 }, -- Wrap an ally with temporal energy, healing them for 23,729 and causing your next healing spell to cast an additional time on that ally at 105% of normal healing. Essence spells cannot be Echoed.
    emerald_communion               = {  93245, 370960, 1 }, -- Commune with the Emerald Dream, restoring 20% health and 2% mana every 0.9 sec for 4.5 sec. Overhealing is transferred to an injured ally within 40 yds. Castable while stunned, disoriented, incapacitated, or silenced.
    empath                          = {  93242, 376138, 1 }, -- Spiritbloom increases your Essence regeneration rate by 100% for 8 sec.
    energy_loop                     = {  93261, 372233, 1 }, -- Disintegrate deals 35% more damage and generates 7,200 mana over its duration.
    erasure                         = {  93264, 376210, 1 }, -- Rewind has 2 charges, but its healing is reduced by 50%.
    essence_attunement              = {  93238, 375722, 1 }, -- Essence Burst stacks 2 times.
    essence_burst                   = {  93239, 369297, 1 }, -- Living Flame has a 20% chance, and Reversion has a 15% chance to make your next Essence ability free. Stacks 2 times.
    exhilarating_burst              = {  93246, 377100, 2 }, -- Each time you gain Essence Burst, your critical heals are 230% effective instead of the usual 200% for 10 sec.
    field_of_dreams                 = {  93248, 370062, 1 }, -- Gain a 30% chance for one of your Fluttering Seedlings to grow into a new Emerald Blossom.
    flow_state                      = {  93256, 385696, 2 }, -- Empower spells cause time to flow 10% faster for you, increasing movement speed, cooldown recharge rate, and cast speed. Lasts 10 sec.
    fluttering_seedlings            = {  93247, 359793, 2 }, -- Emerald Blossom sends out flying seedlings when it bursts, healing 2 allies up to 40 yds away for 15,364.
    font_of_magic                   = {  93252, 375783, 1 }, -- Your empower spells' maximum level is increased by 1.
    golden_hour                     = {  93255, 378196, 1 }, -- Reversion instantly heals the target for 15% of damage taken in the last 5 sec.
    grace_period                    = {  93265, 376239, 1 }, -- Your healing is increased by 10% on targets with your Reversion.
    just_in_time                    = {  93335, 376204, 1 }, -- Time Dilation's cooldown is reduced by 2 sec each time you cast an Essence ability.
    lifebind                        = {  93253, 373270, 1 }, -- Verdant Embrace temporarily bonds your life with an ally, causing your healing on either partner to heal the other for 40% of the amount. Lasts 5 sec.
    lifeforce_mender                = {  93236, 376179, 2 }, -- Living Flame and Fire Breath deal additional damage and healing equal to 1.0% of your maximum health.
    lifegivers_flame                = {  93237, 371426, 1 }, -- Fire Breath heals 5 nearby injured allies for 80% of damage done to up to 5 targets, split evenly among them.
    lifespark                       = {  99804, 443177, 1 }, -- Reversion healing has a chance to cause your next Living Flame to cast instantly and deal 50% increased healing or damage. Stacks up to 2 charges.
    nozdormus_teachings             = {  93258, 376237, 1 }, -- Temporal Anomaly reduces the cooldowns of your empower spells by 5 sec.
    ouroboros                       = {  93251, 381921, 1 }, -- Casting Echo grants one stack of Ouroboros, increasing the healing of your next Emerald Blossom by 30%, stacking up to 5 times.
    power_nexus                     = {  93249, 369908, 1 }, -- Increases your maximum Essence to 6.
    punctuality                     = {  93260, 371270, 1 }, -- Reversion has 2 charges.
    renewing_breath                 = {  93268, 371257, 2 }, -- Dream Breath healing is increased by 15%.
    resonating_sphere               = {  93258, 376236, 1 }, -- Temporal Anomaly applies Echo at 30% effectiveness to the first 5 allies it passes through.
    reversion                       = {  93338, 366155, 1 }, -- Reverse an ally's injuries, instantly healing them for 15% of damage taken in the last 5 sec and an additional 58,287 over 15.6 sec. When Reversion critically heals, its duration is extended by 2 sec, up to a maximum of 12 sec.
    rewind                          = {  93337, 363534, 1 }, -- Rewind 33% of damage taken in the last 5 seconds by all allies within 40 yds. Always heals for at least 35,779. Healing increased by 100% when not in a raid.
    rush_of_vitality                = {  93244, 377086, 1 }, -- Emerald Communion increases your maximum health by 20% for 15 sec.
    spark_of_insight                = {  93269, 377099, 1 }, -- Consuming a full Temporal Compression grants you Essence Burst.
    spiritbloom                     = {  93243, 367226, 1 }, -- Divert spiritual energy, healing an ally for 120,663. Jumps to injured allies within 30 yds when empowered. I: Heals one ally. II: Heals a second ally. III: Heals a third ally.
    spiritual_clarity               = {  93242, 376150, 1 }, -- Spiritbloom's cooldown is reduced by 10 sec.
    stasis                          = {  93262, 370537, 1 }, -- Causes your next 3 helpful spells to be duplicated and stored in a time lock. You may reactivate Stasis any time within 30 sec to quickly unleash their magic.
    temporal_anomaly                = {  93257, 373861, 1 }, -- Send forward a vortex of temporal energy, absorbing 26,117 damage on you and any allies in its path. Absorption is reduced beyond 5 targets.
    temporal_artificer              = {  93264, 381922, 1 }, -- Rewind's cooldown is reduced by 60 sec.
    temporal_compression            = {  93241, 362874, 1 }, -- Each cast of a Bronze spell causes your next empower spell to reach maximum level in 10% less time, stacking up to 4 times.
    time_dilation                   = {  93336, 357170, 1 }, -- Stretch time around an ally for the next 10.4 sec, causing 50% of damage they would take to instead be dealt over 10.4 sec.
    time_lord                       = {  93254, 372527, 2 }, -- Echo replicates 50% more healing.
    time_of_need                    = {  93259, 368412, 1 }, -- When you or an ally fall below 30% health, a version of yourself enters your timeline and heals them for 99,187. Your alternate self continues healing for 8 sec before returning to their timeline. May only occur once every 60 sec.
    timeless_magic                  = {  93263, 376240, 2 }, -- Reversion, Time Dilation, Echo, and Temporal Anomaly last 15% longer and cost 15% less mana.
    titans_gift                     = {  99803, 443264, 1 }, -- Essence Burst increases the effectiveness of your next Essence ability by 25%.

    -- Chronowarden
    afterimage                      = {  94929, 431875, 1 }, -- Empower spells send up to 3 Chrono Flames to your targets.
    chrono_flame                    = {  94954, 431442, 1, "chronowarden" }, -- Living Flame is enhanced with Bronze magic, repeating 15% of the damage or healing you dealt to the target in the last 5 sec as Arcane, up to 29,455.
    doubletime                      = {  94932, 431874, 1 }, -- When Dream Breath or Fire Breath critically strike, their duration is extended by 2 sec, up to a maximum of 12 sec.
    golden_opportunity              = {  94942, 432004, 1 }, -- Casting Echo has a 20% chance to cause your next Echo to be 100% more effective.
    instability_matrix              = {  94930, 431484, 1 }, -- Each time you cast an empower spell, unstable time magic reduces its cooldown by up to 6 sec.
    master_of_destiny               = {  94930, 431840, 1 }, -- Casting Essence spells extends all your active Threads of Fate by 1 sec.
    motes_of_acceleration           = {  94935, 432008, 1 }, -- Warp leaves a trail of Motes of Acceleration. Allies who come in contact with a mote gain 20% increased movement speed for 30 sec.
    primacy                         = {  94951, 431657, 1 }, -- For each healing over time effect from Spiritbloom, gain 3% haste, up to 9%.
    reverberations                  = {  94925, 431615, 1 }, -- Spiritbloom heals for an additional 30% over 8 sec.
    temporal_burst                  = {  94955, 431695, 1 }, -- Tip the Scales overloads you with temporal energy, increasing your haste, movement speed, and cooldown recovery rate by 30%, decreasing over 30 sec.
    temporality                     = {  94935, 431873, 1 }, -- Warp reduces damage taken by 20%, starting high and reducing over 3 sec.
    threads_of_fate                 = {  94947, 431715, 1 }, -- Casting an empower spell during Temporal Burst causes a nearby ally to gain a Thread of Fate for 10 sec, granting them a chance to echo their damage or healing spells, dealing 15% of the amount again.
    time_convergence                = {  94932, 431984, 1 }, -- Non-defensive abilities with a 45 second or longer cooldown grant 5% Intellect for 15 sec. Essence spells extend the duration by 1 sec.
    warp                            = {  94948, 429483, 1 }, -- Hover now causes you to briefly warp out of existence and appear at your destination. Hover's cooldown is also reduced by 5 sec. Hover continues to allow Evoker spells to be cast while moving.

    -- Flameshaper
    burning_adrenaline              = {  94946, 444020, 1 }, -- Engulf quickens your pulse, reducing the cast time of your next spell by 30%. Stacks up to 2 charges.
    conduit_of_flame                = {  94949, 444843, 1 }, -- Critical strike chance against targets above 50% health increased by 15%.
    consume_flame                   = {  94922, 444088, 1 }, -- Engulf consumes 2 sec of Dream Breath from the target, detonating it and healing all nearby targets equal to 300% of the amount consumed, reduced beyond 5 targets.
    draconic_instincts              = {  94931, 445958, 1 }, -- Your wounds have a small chance to cauterize, healing you for 30% of damage taken. Occurs more often from attacks that deal high damage.
    engulf                          = {  94950, 443328, 1, "flameshaper" }, -- Engulf your target in dragonflame, damaging them for $443329s1 Fire or healing them for $443330s1. For each of your periodic effects on the target, effectiveness is increased by $s1%.
    enkindle                        = {  94956, 444016, 1 }, -- Essence abilities are enhanced with Flame, dealing 20% of healing or damage done as Fire over 8 sec.
    expanded_lungs                  = {  94956, 444845, 1 }, -- Fire Breath's damage over time is increased by 30%. Dream Breath's heal over time is increased by 30%.
    flame_siphon                    = {  99857, 444140, 1 }, -- Engulf reduces the cooldown of Fire Breath and Dream Breath by 6 sec.
    fulminous_roar                  = {  94923, 1218447, 1 }, -- Fire Breath and Dream Breath deal their damage and healing in 20% less time.
    lifecinders                     = {  94931, 444322, 1 }, -- Renewing Blaze also applies to your target or 1 nearby injured ally at 50% value.
    red_hot                         = {  94945, 444081, 1 }, -- Engulf gains 1 additional charge and deals 20% increased damage and healing.
    shape_of_flame                  = {  94937, 445074, 1 }, -- Tail Swipe and Wing Buffet scorch enemies and blind them with ash, causing their next attack within 4 sec to miss.
    titanic_precision               = {  94920, 445625, 1 }, -- Living Flame has 1 extra chance to trigger Essence Burst when it critically strikes.
    trailblazer                     = {  94937, 444849, 1 }, -- Hover, Deep Breath, and Dream Flight travel 40% faster, and Hover travels 40% further.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    chrono_loop          = 5455, -- (383005) Trap the enemy in a time loop for 5 sec. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below 20%.
    divide_and_conquer   = 5595, -- (384689) Deep Breath forms curtains of fire, preventing line of sight to enemies outside its walls and burning enemies who walk through them for 139,690 Fire damage. Lasts 6 sec.
    dreamwalkers_embrace = 5616, -- (415651) Verdant Embrace tethers you to an ally, increasing movement speed by 40% and slowing and siphoning 24,251 life from enemies who come in contact with the tether. The tether lasts up to 10 sec or until you move more than 30 yards away from your ally.
    nullifying_shroud    = 5468, -- (378464) Wreathe yourself in arcane energy, preventing the next 3 full loss of control effects against you. Lasts 30 sec.
    obsidian_mettle      = 5459, -- (378444) While Obsidian Scales is active you gain immunity to interrupt, silence, and pushback effects.
    scouring_flame       = 5461, -- (378438) Fire Breath burns away 1 beneficial Magic effect per empower level from all targets.
    swoop_up             = 5465, -- (370388) Grab an enemy and fly with them to the target location.
    time_stop            = 5463, -- (378441) Freeze an ally's timestream for 5 sec. While frozen in time they are invulnerable, cannot act, and auras do not progress. You may reactivate Time Stop to end this effect early.
    unburdened_flight    = 5470, -- (378437) Hover makes you immune to movement speed reduction effects.
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
    -- Next Living Flame's cast time reduced by $s1% and deals $s2% increased damage or healing.
    lifespark = {
        id = 394552,
        duration = 15.0,
        max_stack = 1,
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
    time_of_need = { -- ICD
        id = 368415,
        duration = 60,
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

-- TheWarWithin
spec:RegisterGear( "tww2", 229283, 229281, 229279, 229280, 229278 )

-- Dragonflight
spec:RegisterGear( "tier30", 202491, 202489, 202488, 202487, 202486 )
spec:RegisterAura( "spiritbloom", {
    id = 409895,
    duration = 8,
    tick_time = 2,
    max_stack = 1
} )
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

    if ( set_bonus.tier30_4pc > 0 or set_bonus.tier31_4pc ) and ability.empowered then
        if empowered_spell_count == 4 then
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
    --[[ lifespark = { -- now a talent
        id = 394552,
        duration = 15,
        max_stack = 2
    } ]]
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
        local power_level = args.empower_to or class.abilities[ this_action ].empowerment_default or max_empower

        if settings.fire_breath_fixed > 0 then
            power_level = min( settings.fire_breath_fixed, power_level )
        end

        return stages[ power_level ] * ( talent.font_of_magic.enabled and 0.8 or 1 ) * ( 1 - 0.1 * buff.temporal_compression.stack ) * haste
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
    -- Engulf your target in dragonflame, damaging them for $443329s1 Fire or healing them for $443330s1. For each of your periodic effects on the target, effectiveness is increased by $s1%.
    engulf = {
        id = 443328,
        color = 'red',
        cast = 0.0,
        cooldown = 27,
        hasteCD = true,
        charges = function() return talent.red_hot.enabled and 2 or nil end,
        recharge = function() return talent.red_hot.enabled and 30 or nil end,
        gcd = "spell",

        spend = 0.050,
        spendType = 'mana',

        talent = "engulf",
        startsCombat = true,

        handler = function()
            -- Assume damage occurs.
            if talent.burning_adrenaline.enabled then addStack( "burning_adrenaline" ) end
            if talent.flame_siphon.enabled then reduceCooldown( "dream_breath", 6 ) end
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
        id = function() return talent.chrono_flame.enabled and 431443 or 361469 end,
        cast = function() return buff.lifespark.up and 0 or 2 end,
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

        copy = { 361469, "chrono_flame", 431443 }
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
                -- TODO: See if we can determine the spells to cast from the stasis aura.
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

    potion = "tempered_potion",

    package = "Preservation",
} )


spec:RegisterPack( "Preservation", 20240730, [[Hekili:LAvuVTjpu0Fl9LOw1w(acTnFtR9HP9WwNu1Kys7nJDGlfRsWmBt6AvK)TVRnPjMqs166liZLJpN71(EUcse5hK0cMgi3fhgNeE10WGWzrjHZiP6NAbsAll)b294Ig2c853LGcKlzAUOX(XNQfScljkrNmhbqsN3XR1FTHmF)mFjITfYj3fLCjQsfVOa6bdQCs6xawnin0wjxi5AoOmuMem0p)90Zlf5DkOWqfn1pzU1CRL6ZdV68PHFWq)rfc7NmCZ)KRR428tkk51ywXYTjSkOvc5IfZz6tV()MxdkfV5(mrzMUcYMlfnpdwwxJgX8RoOU2pqoRtds(Z29vwJhj(FSRrYwcdWxaqlYmW0v(HBf2vd2RcY4AyHYpyjxcR39zWIwXJGmtlUo6mE51L87R0zsybJ3OUjk50CMsNP5dtPdWq8ygM9Miy6ycIFteKyjy974HzGhSvRgs8EPTsSeKwowiwI7FY8UYYaxWGcXJntuGwJXvb2dwx8bxlC8Mxd3lXguljUDJTdqtoMfDsLoORDYXh1t(QvESpkRoz1Q17mW(kwCzly)(JB((2ub77BkYwd2pDyp3HvVsl5p4sh7xwczqdSana3e7JTMVCtZNf7Fvo(AIT)dqskUszD5B8VK0hzYgBLqs)kEZj1wRym6pDCBO1CLwfyULK6w5MTaLSUAnU8o3SMEOKuNXIKcnm0gwq(erJ64dyKrBhWt9bV24TdKeFiEgXDGDHpSEJ5oiUCGwVyu3b0vwqBJSbVxJnwv4inSQy2WET4g6ngAuIHEQHU5odzBJDHKgz1y27vJzVMeXwj()3ReXVMetTsef(20y)tjm0vRm0X6FaLtCkhTJYBfP3fyOtm0DCcUyJhNSnT7F1sF8bPFVdyCmFSHEKH(I82AASrEyHzON0dCpJDm0poaPFQpy8JNZWBwORkMEWQy4CP(R7Te5pyXruYbj6nwXB1WF6NtJl(hUrpykRT)YW6)qy0iR9))cdNc4OaNCvjW(JVXQGh41CxuYFc]] )