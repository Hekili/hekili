-- EvokerDevastation.lua
-- November 2022

if UnitClassBase( "player" ) ~= "EVOKER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 1467 )

spec:RegisterResource( Enum.PowerType.Essence )
spec:RegisterResource( Enum.PowerType.Mana, {
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
} )

-- Talents
spec:RegisterTalents( {
    -- Evoker
    aerial_mastery         = { 68659, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame          = { 68671, 369990, 1 }, -- Healing yourself with Living Flame reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream   = { 68672, 376930, 2 }, -- Your healing done and healing received are increased by 2%.
    blast_furnace          = { 68667, 375510, 2 }, -- Fire Breath's damage over time lasts 0 sec longer.
    bountiful_bloom        = { 68572, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame      = { 68673, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 7,854 upon removing any effect.
    clobbering_sweep       = { 68570, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 45 sec.
    draconic_legacy        = { 68685, 376166, 2 }, -- Your Stamina is increased by 2%.
    enkindled              = { 68677, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    extended_flight        = { 68679, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance             = { 68573, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    fire_within            = { 68654, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    foci_of_life           = { 68654, 375574, 1 }, -- While Renewing Blaze's initial effect is active, you receive 20% increased healing from all sources.
    forger_of_mountains    = { 68569, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    heavy_wingbeats        = { 68570, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 45 sec.
    inherent_resistance    = { 68670, 375544, 2 }, -- Magic damage taken reduced by 2%.
    innate_magic           = { 68683, 375520, 2 }, -- Essence regenerates 5% faster.
    instinctive_arcana     = { 68666, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    leaping_flames         = { 68662, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth            = { 68652, 375561, 2 }, -- Green spells restore 5% more health.
    natural_convergence    = { 68682, 369913, 1 }, -- Disintegrate channels 20% faster.
    obsidian_bulwark       = { 68674, 375406, 1 }, -- Obsidian Scales has an additional charge.
    obsidian_scales        = { 68675, 363916, 1 }, -- Reinforce your scales, reducing damage taken by 30%. Lasts 12 sec.
    oppressing_roar        = { 68668, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    overawe                = { 68660, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 20 sec for each Enrage dispelled.
    panacea                = { 68680, 387761, 1 }, -- Emerald Blossom instantly heals you for 6,451 when cast.
    permeating_chill       = { 68676, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by 50% for 3 sec.
    protracted_talons      = { 68661, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                  = { 68665, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall                 = { 68684, 371806, 1 }, -- You may reactivate Deep Breath within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic     = { 68651, 387787, 1 }, -- Source of Magic forms a bond with your ally, causing 15% of their healing to also heal you while you are below 50% health.
    renewing_blaze         = { 68653, 374348, 1 }, -- The flames of life surround you for 8 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    rescue                 = { 68658, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    roar_of_exhilaration   = { 68664, 375507, 1 }, -- Successfully interrupting an enemy with Quell generates 1 Essence.
    scarlet_adaptation     = { 68687, 372469, 1 }, -- Store 20% of your effective healing, up to 3,353. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk             = { 68571, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic        = { 68669, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 30 min. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    tailwind               = { 68678, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    terror_of_the_skies    = { 68649, 371032, 1 }, -- Deep Breath stuns enemies for 3 sec.
    time_spiral            = { 68650, 374968, 1 }, -- Bend time, allowing you and your allies to cast their major movement ability once in the next 10 sec, even if it is on cooldown.
    tip_the_scales         = { 68686, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian          = { 68656, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5 sec.
    unravel                = { 68663, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 12,255 Spellfrost damage to absorb shields.
    verdant_embrace        = { 68688, 360995, 1 }, -- Fly to an ally and heal them for 7,989, or heal yourself for the same amount.
    walloping_blow         = { 68657, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr                 = { 68655, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8 sec.

    -- Devastation
    animosity              = { 68640, 375797, 1 }, -- Casting an empower spell extends the duration of Dragonrage by 6 sec.
    arcane_intensity       = { 68622, 375618, 2 }, -- Disintegrate deals 8% more damage.
    arcane_vigor           = { 68619, 386342, 1 }, -- Shattering Star generates 1 Essence.
    azure_essence_burst    = { 68643, 375721, 1 }, -- Azure Strike has a 15% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    burnout                = { 68633, 375801, 2 }, -- Fire Breath damage has 6% chance to cause your next Living Flame to be instant cast, stacking 2 times.
    catalyze               = { 68636, 386283, 1 }, -- While channeling Disintegrate your Fire Breath on the target deals damage 100% more often.
    causality              = { 68617, 375777, 1 }, -- Essence abilities reduce the remaining cooldown of Eternity Surge by 1 sec.
    charged_blast          = { 68627, 370455, 1 }, -- Your Blue damage increases the damage of your next Pyre by 5%, stacking 20 times.
    dense_energy           = { 68646, 370962, 1 }, -- Pyre's Essence cost is reduced by 1.
    dragonrage             = { 68641, 375087, 1 }, -- Erupt with draconic fury and exhale Pyres at 3 enemies within 25 yds. For 14 sec, Essence Burst's chance to occur is increased to 100%, and you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    engulfing_blaze        = { 68648, 370837, 1 }, -- Living Flame deals 40% increased damage and healing, but its cast time is increased by 0.5 sec.
    essence_attunement     = { 68625, 375722, 1 }, -- Essence Burst stacks 2 times.
    eternity_surge         = { 68623, 359073, 1 }, -- Focus your energies to release a salvo of pure magic, dealing 9,166 Spellfrost damage to an enemy. Damages additional enemies within 12 yds of the target when empowered. I: Damages 2 enemies. II: Damages 4 enemies. III: Damages 6 enemies.
    eternitys_span         = { 68621, 375757, 1 }, -- Eternity Surge and Shattering Star hit twice as many targets.
    everburning_flame      = { 68615, 370819, 1 }, -- Red spells extend the duration of your Fire Breath's damage over time by 1 sec.
    expunge                = { 68689, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    eye_of_infinity        = { 68617, 369375, 1 }, -- Eternity Surge critical strikes generate 2 Essence.
    feed_the_flames        = { 68615, 369846, 1 }, -- Consuming Essence Burst reduces the remaining cooldown of Fire Breath by 2 sec.
    firestorm              = { 68635, 368847, 1 }, -- An explosion bombards the target area with white-hot embers, dealing 5,682 Fire damage to enemies over 12 sec.
    focusing_iris          = { 68619, 386336, 1 }, -- Shattering Star's damage taken effect lasts 2 sec longer.
    font_of_magic          = { 68632, 375783, 1 }, -- Your empower spells' maximum level is increased by 1.
    heat_wave              = { 68637, 375725, 2 }, -- Fire Breath deals 20% more damage.
    hoarded_power          = { 68575, 375796, 1 }, -- Essence Burst has a 20% chance to not be consumed.
    honed_aggression       = { 68626, 371038, 2 }, -- Azure Strike and Living Flame deal 5% more damage.
    imminent_destruction   = { 68631, 370781, 2 }, -- Empower spells reach maximum level in 20% less time.
    imposing_presence      = { 68642, 371016, 1 }, -- Quell's cooldown is reduced by 20 sec.
    inner_radiance         = { 68642, 386405, 1 }, -- Your Living Flame and Emerald Blossom are 30% more effective on yourself.
    iridescence            = { 68616, 370867, 1 }, -- Casting an empower spell increases the damage of your next 2 spells of the same color by 20% within 10 sec.
    landslide              = { 68681, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 30 sec. Damage may cancel the effect.
    lay_waste              = { 68624, 371034, 2 }, -- Deep Breath's damage is increased by 15%.
    onyx_legacy            = { 68630, 386348, 1 }, -- Deep Breath's cooldown is reduced by 1 min.
    power_nexus            = { 68574, 369908, 1 }, -- Increases your maximum Essence to 6.
    power_swell            = { 68620, 370839, 2 }, -- Casting an empower spell increases your Essence regeneration rate by 100% for 2 sec.
    pyre                   = { 68644, 357211, 1 }, -- Lob a ball of flame, dealing 2,573 Fire damage to the target and nearby enemies.
    ruby_embers            = { 68648, 365937, 1 }, -- Living Flame deals 541 damage over 12 sec to enemies, or restores 1,238 health to allies over 12 sec. Stacks 3 times.
    ruby_essence_burst     = { 68645, 376872, 1 }, -- Your Living Flame has a 20% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    scintillation          = { 68629, 370821, 2 }, -- Disintegrate has a 15% chance each time it deals damage to launch a level 1 Eternity Surge at 30% power.
    shattering_star        = { 68618, 370452, 1 }, -- Exhale bolts of concentrated power from your mouth at 2 enemies for 3,921 Spellfrost damage that cracks the targets' defenses, increasing the damage they take from you by 20% for 4 sec.
    snapfire               = { 68634, 370783, 1 }, -- Living Flame has a 12% chance to reset the cooldown of Firestorm, and make your next one instant cast and deal 40% increased damage.
    spellweavers_dominance = { 68628, 370845, 1 }, -- Your damaging critical strikes deal 230% damage instead of the usual 200%.
    titanic_wrath          = { 68639, 386272, 2 }, -- Essence Burst increases the damage of affected spells by 8.0%.
    tyranny                = { 68638, 376888, 1 }, -- During Deep Breath and Dragonrage you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    volatility             = { 68647, 369089, 2 }, -- Pyre has a 15% chance to flare up and explode again on a nearby target.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chrono_loop       = 5456, -- (383005) Trap the enemy in a time loop for 5 sec. Afterwards, they are returned to their previous location and health.
    crippling_force   = 5471, -- (384660) Disintegrate amplifies Permeating Chill to reduce movement speed by an additional 5% each time it deals damage, up to 80%.
    nullifying_shroud = 5467, -- (378464) Wreathe yourself in arcane energy, preventing the next 3 full loss of control effects against you. Lasts 30 sec.
    obsidian_mettle   = 5460, -- (378444) While Obsidian Scales is active you gain immunity to interrupt, silence, and pushback effects.
    precognition      = 5509, -- (377360) If an interrupt is used on you while you are not casting, gain 15% haste and become immune to control and interrupt effects for 4 sec.
    scouring_flame    = 5462, -- (378438) Fire Breath burns away 1 beneficial Magic effect per empower level from all targets.
    swoop_up          = 5466, -- (370388) Grab an enemy and fly with them to the target location.
    time_stop         = 5464, -- (378441) Freeze an ally's timestream for 4 sec. While frozen in time they are invulnerable, cannot act, and auras do not progress. You may reactivate Time Stop to end this effect early.
    unburdened_flight = 5469, -- (378437) Hover makes you immune to movement speed reduction effects.
} )


-- Auras
spec:RegisterAuras( {
    -- Talent: The cast time of your next Living Flame is reduced by $w1%.
    -- https://wowhead.com/beta/spell=375583
    ancient_flame = {
        id = 375583,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Next Living Flame's cast time is reduced by $w1%.
    -- https://wowhead.com/beta/spell=375802
    burnout = {
        id = 375802,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Pyre deals $s1% more damage.
    -- https://wowhead.com/beta/spell=370454
    charged_blast = {
        id = 370454,
        duration = 30,
        max_stack = 20
    },
    chrono_loop = {
        id = 383005,
        duration = 5,
        max_stack = 1
    },
    cycle_of_life = {
        id = 371877,
        duration = 15,
        max_stack = 1,
    },
    --[[ Suffering $w1 Volcanic damage every $t1 sec.
    -- https://wowhead.com/beta/spell=353759
    deep_breath = {
        id = 353759,
        duration = 1,
        tick_time = 0.5,
        type = "Magic",
        max_stack = 1
    }, -- TODO: Effect of impact on target. ]]
    -- Spewing molten cinders. Immune to crowd control.
    -- https://wowhead.com/beta/spell=357210
    deep_breath = {
        id = 357210,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $w1 Spellfrost damage every $t1 sec.
    -- https://wowhead.com/beta/spell=356995
    disintegrate = {
        id = 356995,
        duration = function () return 3 * ( talent.natural_convergence.enabled and 0.8 or 1 ) end,
        tick_time = function () return talent.natural_convergence.enabled and 0.8 or 1 end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Essence Burst has a $s2% chance to occur.$?s376888[    Your spells gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.][]
    -- https://wowhead.com/beta/spell=375087
    dragonrage = {
        id = 375087,
        duration = 14,
        max_stack = 1
    },
    -- Releasing healing breath. Immune to crowd control.
    -- https://wowhead.com/beta/spell=359816
    dream_flight = {
        id = 359816,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Healing for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=363502
    dream_flight_hot = {
        id = 363502,
        duration = 15,
        type = "Magic",
        max_stack = 1,
        dot = "buff"
    },
    -- When $@auracaster casts a non-Echo healing spell, $w2% of the healing will be replicated.
    -- https://wowhead.com/beta/spell=364343
    echo = {
        id = 364343,
        duration = 15,
        max_stack = 1
    },
    -- Healing and restoring mana.
    -- https://wowhead.com/beta/spell=370960
    emerald_communion = {
        id = 370960,
        duration = 5,
        max_stack = 1
    },
    -- Your next Disintegrate or Pyre costs no Essence.
    -- https://wowhead.com/beta/spell=359618
    essence_burst = {
        id = 359618,
        duration = 15,
        max_stack = function() return talent.essence_attunement.enabled and 2 or 1 end,
    },
    --[[ Your next Essence ability is free. TODO: ???
    -- https://wowhead.com/beta/spell=369299
    essence_burst = {
        id = 369299,
        duration = 15,
        max_stack = function() return talent.essence_attunement.enabled and 2 or 1 end,
    }, ]]
    eternity_surge_x3 = { -- TODO: This is the channel with 3 ranks.
        id = 359073,
        duration = 2.5,
        max_stack = 1
    },
    eternity_surge_x4 = { -- TODO: This is the channel with 4 ranks.
        id = 382411,
        duration = 3.25,
        max_stack = 1
    },
    eternity_surge = {
        alias = { "eternity_surge_x4", "eternity_surge_x3" },
        aliasMode = "first",
        aliasType = "buff",
        duration = 3.25,
    },
    fire_breath = {
        id = 357209,
        duration = function ()
            return 4 * empowerment_level + talent.blast_furnace.rank * 2
        end,
        -- TODO: damage = function () return 0.322 * stat.spell_power * action.fire_breath.spell_targets * ( talent.heat_wave.enabled and 1.2 or 1 ) * ( debuff.shattering_star.up and 1.2 or 1 ) end,
        max_stack = 1,
    },
    -- Burning for $w2 Fire damage every $t2 sec.$?$W3=1[ Silenced.][]
    -- https://wowhead.com/beta/spell=357209
    fire_breath_dot = {
        id = 357209,
        duration = 12,
        type = "Magic",
        max_stack = 1,
        copy = "fire_breath_damage"
    },
    firestorm = { -- TODO: Check for totem?
        id = 369372,
        duration = 12,
        max_stack = 1
    },
    -- Increases the damage of Fire Breath by $s1%.
    -- https://wowhead.com/beta/spell=377087
    full_belly = {
        id = 377087,
        duration = 600,
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed increased by $w2%.    Evoker spells may be cast while moving. Does not affect empowered spells.$?e9[    Immune to movement speed reduction effects.][]
    -- https://wowhead.com/beta/spell=358267
    hover = {
        id = 358267,
        duration = function () return talent.extended_flight.enabled and 10 or 6 end,
        tick_time = 1,
        max_stack = 1
    },
    -- Your next Blue spell deals $s1% more damage.
    -- https://wowhead.com/beta/spell=386399
    iridescence_blue = {
        id = 386399,
        duration = 10,
        max_stack = 2,
    },
    -- Your next Red spell deals $s1% more damage.
    -- https://wowhead.com/beta/spell=386353
    iridescence_red = {
        id = 386353,
        duration = 10,
        max_stack = 2
    },
    -- Talent: Rooted.
    -- https://wowhead.com/beta/spell=355689
    landslide = {
        id = 355689,
        duration = 30,
        mechanic = "root",
        type = "Magic",
        max_stack = 1
    },
    leaping_flames = {
        id = 370901,
        duration = 30,
        max_stack = function() return max_empower end,
    },
    -- Sharing $s1% of healing to an ally.
    -- https://wowhead.com/beta/spell=373267
    lifebind = {
        id = 373267,
        duration = 5,
        max_stack = 1
    },
    -- Burning for $w2 Fire damage every $t2 sec.
    -- https://wowhead.com/beta/spell=361500
    living_flame = {
        id = 361500,
        duration = 12,
        type = "Magic",
        max_stack = 3,
        copy = { "living_flame_dot", "living_flame_damage" }
    },
    -- Healing for $w2 every $t2 sec.
    -- https://wowhead.com/beta/spell=361509
    living_flame_hot = {
        id = 361509,
        duration = 12,
        type = "Magic",
        max_stack = 3,
        dot = "buff",
        copy = "living_flame_heal"
    },
    --
    -- https://wowhead.com/beta/spell=362980
    mastery_giantkiller = {
        id = 362980,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Armor increased by $w1%. Magic damage taken reduced by $w2%.$?$w3=1[  Immune to interrupt and silence effects.][]
    -- https://wowhead.com/beta/spell=363916
    obsidian_scales = {
        id = 363916,
        duration = 12,
        max_stack = 1
    },
    -- Talent: The duration of incoming crowd control effects are increased by $s2%.
    -- https://wowhead.com/beta/spell=372048
    oppressing_roar = {
        id = 372048,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=370898
    permeating_chill = {
        id = 370898,
        duration = 3,
        mechanic = "snare",
        max_stack = 1
    },
    -- Talent: $w1% of damage taken is being healed over time.
    -- https://wowhead.com/beta/spell=374348
    renewing_blaze = {
        id = 374348,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Restoring $w1 health every $t1 sec.
    -- https://wowhead.com/beta/spell=374349
    renewing_blaze_heal = {
        id = 374349,
        duration = 14,
        max_stack = 1
    },
    recall = {
        id = 371807,
        duration = 10,
        max_stack = function () return talent.essence_attunement.enabled and 2 or 1 end,
    },
    -- Talent: About to be picked up!
    -- https://wowhead.com/beta/spell=370665
    rescue = {
        id = 370665,
        duration = 1,
        max_stack = 1
    },
    -- Healing for $w1 every $t1 sec.
    -- https://wowhead.com/beta/spell=366155
    reversion = {
        id = 366155,
        duration = 12,
        max_stack = 1
    },
    -- Talent: Taking $w3% increased damage from $@auracaster.
    -- https://wowhead.com/beta/spell=370452
    shattering_star = {
        id = 370452,
        duration = function () return talent.focusing_iris.enabled and 6 or 4 end,
        type = "Magic",
        max_stack = 1,
        copy = "shattering_star_debuff"
    },
    -- Talent: Asleep.
    -- https://wowhead.com/beta/spell=360806
    sleep_walk = {
        id = 360806,
        duration = 20,
        mechanic = "sleep",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Your next Firestorm is instant cast and deals $s2% increased damage.
    -- https://wowhead.com/beta/spell=370818
    snapfire = {
        id = 370818,
        duration = 10,
        max_stack = 1
    },
    -- Talent: $@auracaster is restoring mana to you when they cast an empowered spell.
    -- https://wowhead.com/beta/spell=369459
    source_of_magic = {
        id = 369459,
        duration = 1800,
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=370845
    spellweavers_dominance = {
        id = 370845,
        duration = 3600,
        max_stack = 1
    },
    -- Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=368970
    tail_swipe = {
        id = 368970,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=372245
    terror_of_the_skies = {
        id = 372245,
        duration = 3,
        mechanic = "stun",
        max_stack = 1
    },
    -- Talent: May use Death's Advance once, without incurring its cooldown.
    -- https://wowhead.com/beta/spell=375226
    time_spiral = {
        id = 375226,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Your next empowered spell casts instantly at its maximum empower level.
    -- https://wowhead.com/beta/spell=370553
    tip_the_scales = {
        id = 370553,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbing $w1 damage.
    -- https://wowhead.com/beta/spell=370889
    twin_guardian = {
        id = 370889,
        duration = 5,
        max_stack = 1
    },
    -- Movement speed reduced by $s2%.
    -- https://wowhead.com/beta/spell=357214
    wing_buffet = {
        id = 357214,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage taken from area-of-effect attacks reduced by $w1%.  Movement speed increased by $w2%.
    -- https://wowhead.com/beta/spell=374227
    zephyr = {
        id = 374227,
        duration = 8,
        max_stack = 1
    }
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
spec:RegisterAura( "limitless_potential", {
    id = 394402,
    duration = 6,
    max_stack = 1
} )


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
        return ( 1 - 0.1 * talent.imminent_destruction.rank ) * stages[ args.empower_to or max_empower ] * haste
    end, state )
end


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

        spend = 0.009,
        spendType = "mana",

        startsCombat = true,

        minRange = 0,
        maxRange = 25,

        -- Modifiers:
        -- x Spark of Savagery (Conduit)
        -- P Honed Aggression (Talent)
        -- x Protracted Talons (Talent)
        -- P Shattering Star (Talent)
        -- x Tyranny (Talent)

        damage = function () return stat.spell_power * 0.755 * ( debuff.shattering_star.up and 1.2 or 1 ) end, -- PvP multiplier = 1.
        critical = function() return stat.crit + conduit.spark_of_savagery.mod end,
        critical_damage = function () return talent.tyranny.enabled and 2.2 or 2 end,
        spell_targets = function() return talent.protracted_talons.enabled and 3 or 2 end,

        handler = function ()
            if talent.azure_essence_burst.enabled and buff.dragonrage.up then addStack( "essence_burst", nil, 1 ) end -- TODO:  Does this give 2 stacks if hitting 2 targets w/ Essence Attunement?
            if talent.charged_blast.enabled then addStack( "charged_blast", nil, min( active_enemies, spell_targets.azure_strike ) ) end
        end,
    },

    -- Weave the threads of time, reducing the cooldown of a major movement ability for all party and raid members by 15% for 1 |4hour:hrs;.
    blessing_of_the_bronze = {
        id = 364342,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "arcane",
        color = "bronze",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        nobuff = "blessing_of_the_bronze",

        handler = function ()
            applyBuff( "blessing_of_the_bronze" )
            applyBuff( "blessing_of_the_bronze_evoker")
        end,
    },

    -- Talent: Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 4,480 upon removing any effect.
    cauterizing_flame = {
        id = 374251,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "fire",
        color = "red",

        spend = 0.013,
        spendType = "mana",

        talent = "cauterizing_flame",
        startsCombat = true,

        healing = function () return 3.50 * stat.spell_power end,

        usable = function()
            return buff.dispellable_poison.up or buff.dispellable_curse.up or buff.dispellable_disease.up, "requires dispellable effect"
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_curse" )
            removeBuff( "dispellable_disease" )
            health.current = min( health.max, health.current + action.cauterizing_flame.healing )
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
        end,
    },

    -- Take in a deep breath and fly to the targeted location, spewing molten cinders dealing 6,375 Volcanic damage to enemies in your path. Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    deep_breath = {
        id = function () return buff.recall.up and 371807 or 357210 end,
        cast = 0,
        cooldown = function ()
            return talent.onyx_legacy.enabled and 60 or 120
        end,
        gcd = "spell",
        school = "firestorm",
        color = "black",

        startsCombat = true,
        texture = 4622450,
        toggle = "cooldowns",

        min_range = 20,
        max_range = 50,

        damage = function () return 2.30 * stat.spell_power end,

        usable = function() return settings.use_deep_breath, "settings.use_deep_breath is disabled" end,

        handler = function ()
            if buff.recall.up then
                removeBuff( "recall" )
            else
                setCooldown( "global_cooldown", 6 ) -- TODO: Check.
                applyBuff( "recall", 9 )
                buff.recall.applied = query_time + 6
            end

            if talent.terror_of_the_skies.enabled then applyDebuff( "target", "terror_of_the_skies" ) end
        end,

        copy = { "recall", 371807, 357210 },
    },

    -- Tear into an enemy with a blast of blue magic, inflicting 4,930 Spellfrost damage over 2.1 sec, and slowing their movement speed by 50% for 3 sec.
    disintegrate = {
        id = 356995,
        cast = function() return 3 * ( talent.natural_convergence.enabled and 0.8 or 1 ) end,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        school = "spellfrost",
        color = "blue",

        spend = function () return buff.essence_burst.up and 0 or 3 end,
        spendType = "essence",

        startsCombat = true,

        damage = function () return 2.28 * stat.spell_power * ( 1 + 0.08 * talent.arcane_intensity.rank ) * ( talent.energy_loop.enabled and 1.2 or 1 ) * ( debuff.shattering_star.up and 1.2 or 1 ) end,
        critical = function () return stat.crit + conduit.spark_of_savagery.mod end,
        critical_damage = function () return talent.tyranny.enabled and 2.2 or 2 end,

        min_range = 0,
        max_range = 25,

        -- o Antique Oathstone (Anima Power)
        -- o Arcane Intensity
        -- x Disintegrate Rank 2 (built in)
        -- x Energy Loop (Preservation)
        -- x Essence Burst
        -- - Hover
        -- x Shattering Star

        start = function ()
            applyDebuff( "target", "disintegrate" )
            if buff.essence_burst.up then
                if talent.feed_the_flames.enabled then reduceCooldown( "fire_breath", 2 ) end
                removeStack( "essence_burst", 1 )
            end
            if talent.causality.enabled then reduceCooldown( "eternity_surge", 1 ) end
        end,

        tick = function ()
            if talent.charged_blast.enabled then addStack( "charged_blast" ) end
        end
    },

    -- Talent: Erupt with draconic fury and exhale Pyres at 3 enemies within 25 yds. For 14 sec, Essence Burst's chance to occur is increased to 100%, and you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    dragonrage = {
        id = 375087,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "physical",
        color = "red",

        talent = "dragonrage",
        startsCombat = true,

        toggle = "cooldowns",

        spell_targets = function () return min( 3, active_enemies ) end,
        damage = function () return action.living_pyre.damage * action.dragonrage.spell_targets end,

        handler = function ()
            applyBuff( "dragonrage" )
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
        end,
    },

    -- Grow a bulb from the Emerald Dream at an ally's location. After 2 sec, heal up to 3 injured allies within 10 yds for 2,208.
    emerald_blossom = {
        id = 355913,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "nature",
        color = "green",

        spend = 3,
        spendType = "essence",

        startsCombat = false,

        healing = function () return 2.5 * stat.spell_power end,    -- TODO: Make a fake aura so we know if an Emerald Blossom is pending for a target already?
                                                                    -- TODO: Factor in Fluttering Seedlings?  ( 0.9 * stat.spell_power * targets impacted )

        -- o Cycle of Life (?); every 3 Emerald Blossoms leaves a tiny sprout which gathers 10% of healing over 15 seconds, then heals allies w/in 25 yards.
        --    - Count shows on action button.

        handler = function ()
            if talent.cycle_of_life.enabled then
                if cycle_of_life_count == 2 then
                    cycle_of_life_count = 0
                    applyBuff( "cycle_of_life" )
                else
                    cycle_of_life_count = cycle_of_life_count + 1
                end
            end
            if talent.causality.enabled then reduceCooldown( "essence_burst", 1 ) end
        end,
    },

    -- Talent: Focus your energies to release a salvo of pure magic, dealing 4,754 Spellfrost damage to an enemy. Damages additional enemies within 12 yds of the target when empowered. I: Damages 1 enemy. II: Damages 2 enemies. III: Damages 3 enemies.
    eternity_surge = {
        id = function() return talent.font_of_magic.enabled and 382411 or 359073 end,
        known = 359073,
        cast = empowered_cast_time,
        -- channeled = true,
        empowered = true,
        cooldown = 30,
        gcd = "off",
        school = "spellfrost",
        color = "blue",

        talent = "eternity_surge",
        startsCombat = true,

        spell_targets = function () return min( active_enemies, ( talent.eternitys_span.enabled and 2 or 1 ) * empowerment_level ) end,
        damage = function () return spell_targets.eternity_surge * 3.4 * stat.spell_power end,

        handler = function ()
            if talent.animosity.enabled and buff.dragonrage.up then buff.dragonrage.expires = buff.dragonrage.expires + 6 end
            -- TODO: Determine if we need to model projectiles instead.
            if talent.charged_blast.enabled then addStack( "charged_blast", nil, spell_targets.eternity_surge ) end
            if talent.iridescence.enabled then addStack( "iridescence_blue", nil, 2 ) end

            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
            end

            if set_bonus.tier29_2pc > 0 then applyBuff( "limitless_potential" ) end
        end,

        copy = { 382411, 359073 }
    },

    -- Talent: Expunge toxins affecting an ally, removing all Poison effects.
    expunge = {
        id = 365585,
        cast = 0,
        cooldown = 8,
        gcd = "spell",
        school = "nature",
        color = "green",

        spend = 0.013,
        spendType = "mana",

        talent = "expunge",
        startsCombat = false,
        toggle = "interrupts",
        buff = "dispellable_poison",

        handler = function ()
            removeBuff( "dispellable_poison" )
        end,
    },

    -- Inhale, stoking your inner flame. Release to exhale, burning enemies in a cone in front of you for 8,395 Fire damage, reduced beyond 5 targets. Empowering causes more of the damage to be dealt immediately instead of over time. I: Deals 2,219 damage instantly and 6,176 over 20 sec. II: Deals 4,072 damage instantly and 4,323 over 14 sec. III: Deals 5,925 damage instantly and 2,470 over 8 sec. IV: Deals 7,778 damage instantly and 618 over 2 sec.
    fire_breath = {
        id = function() return talent.font_of_magic.enabled and 382266 or 357208 end,
        known = 357208,
        cast = empowered_cast_time,
        -- channeled = true,
        empowered = true,
        cooldown = 30,
        gcd = "off",
        school = "fire",
        color = "red",

        spend = 0.026,
        spendType = "mana",

        startsCombat = true,

        spell_targets = function () return active_enemies end,
        damage = function () return 1.334 * stat.spell_power * ( 1 + 0.1 * talent.blast_furnace.rank ) * ( debuff.shattering_star.up and 1.2 or 1 ) end,
        critical = function () return stat.crit + conduit.spark_of_savagery.mod end,
        critical_damage = function () return talent.tyranny.enabled and 2.2 or 2 end,

        handler = function()
            if talent.animosity.enabled and buff.dragonrage.up then buff.dragonrage.expires = buff.dragonrage.expires + 6 end
            if talent.iridescence.enabled then applyBuff( "iridescence_red", nil, 2 ) end
            if talent.leaping_flames.enabled then applyBuff( "leaping_flames", nil, empowerment_level ) end

            applyDebuff( "target", "fire_breath" )

            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
            end

            if set_bonus.tier29_2pc > 0 then applyBuff( "limitless_potential" ) end
        end,

        copy = { 382266, 357208 }
    },

    -- Talent: An explosion bombards the target area with white-hot embers, dealing 2,701 Fire damage to enemies over 12 sec.
    firestorm = {
        id = 368847,
        cast = function() return buff.snapfire.up and 0 or 2 end,
        cooldown = 20,
        gcd = "spell",
        school = "fire",
        color = "red",

        talent = "firestorm",
        startsCombat = true,

        min_range = 0,
        max_range = 25,

        spell_targets = function () return active_enemies end,
        damage = function () return action.firestorm.spell_targets * 0.276 * stat.spell_power * 7 end,

        handler = function ()
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
            removeBuff( "snapfire" )
        end,
    },

    -- Increases haste by 30% for all party and raid members for 40 sec. Allies receiving this effect will become Exhausted and unable to benefit from Fury of the Aspects or similar effects again for 10 min.
    fury_of_the_aspects = {
        id = 390386,
        cast = 0,
        cooldown = 300,
        gcd = "off",
        school = "arcane",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "fury_of_the_aspects" )
            applyDebuff( "player", "exhaustion" )
        end,
    },

    -- Launch yourself and gain 30% increased movement speed for 10 sec. Allows Evoker spells to be cast while moving. Does not affect empowered spells.
    hover = {
        id = 358267,
        cast = 0,
        charges = function() return talent.aerial_mastery.enabled and 2 or nil end,
        cooldown = 35,
        recharge = function() return talent.aerial_mastery.enabled and 35 or nil end,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        handler = function ()
            applyBuff( "hover" )
        end,
    },

    -- Talent: Conjure a path of shifting stone towards the target location, rooting enemies for 30 sec. Damage may cancel the effect.
    landslide = {
        id = 358385,
        cast = function() return ( talent.engulfing_blaze.enabled and 2.5 or 2 ) * ( buff.ancient_flame.up and 0.6 or 1 ) * ( buff.burnout.up and 0 or 1 ) end,
        cooldown = 90,
        gcd = "spell",
        school = "firestorm",
        color = "black",

        spend = 0.028,
        spendType = "mana",

        talent = "landslide",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    -- Send a flickering flame towards your target, dealing 2,625 Fire damage to an enemy or healing an ally for 3,089.
    living_flame = {
        id = 361469,
        cast = 2,
        cooldown = 0,
        gcd = "spell",
        school = "fire",
        color = "red",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        damage = function () return 1.61 * stat.spell_power * ( talent.engulfing_blaze.enabled and 1.4 or 1 ) end,
        healing = function () return 2.75 * stat.spell_power * ( talent.engulfing_blaze.enabled and 1.4 or 1 ) * ( 1 + 0.03 * talent.enkindled.rank ) * ( talent.inner_radiance.enabled and 1.3 or 1 ) end,
        spell_targets = function () return buff.leaping_flames.up and min( active_enemies, 1 + buff.leaping_flames.stack ) end,

        -- x Ancient Flame
        -- x Burnout
        -- x Engulfing Blaze
        -- x Enkindled
        -- - Hover
        -- x Inner Radiance

        handler = function ()
            if buff.burnout.up then removeStack( "burnout" )
            else removeBuff( "ancient_flame" ) end

            -- Burnout is not consumed.
            if talent.ruby_essence_burst.enabled and buff.dragonrage.up then
                addStack( "essence_burst", nil, buff.leaping_flames.up and ( true_active_enemies > 1 or group or health.percent < 100 ) and 2 or 1 )
            end
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end

            removeBuff( "leaping_flames" )
            removeBuff( "scarlet_adaptation" )
        end,
    },

    -- Talent: Reinforce your scales, reducing damage taken by 30%. Lasts 12 sec.
    obsidian_scales = {
        id = 363916,
        cast = 0,
        cooldown = function () return talent.obsidian_bulwark.enabled and 90 or 150 end,
        gcd = "off",
        school = "firestorm",
        color = "black",

        talent = "obsidian_scales",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "obsidian_scales" )
        end,
    },

    -- Talent: Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    oppressing_roar = {
        id = 372048,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "physical",
        color = "black",

        talent = "oppressing_roar",
        startsCombat = true,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "oppressing_roar" )
            if talent.overawe.enabled and debuff.dispellable_enrage.up then
                removeDebuff( "target", "dispellable_enrage" )
                reduceCooldown( "oppressing_roar", 20 )
            end
        end,
    },

    -- Talent: Lob a ball of flame, dealing 1,468 Fire damage to the target and nearby enemies.
    pyre = {
        id = 357211,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "fire",
        color = "red",

        spend = function()
            if buff.essence_burst.up then return 0 end
            return 3 - talent.dense_energy.rank
        end,
        spendType = "essence",

        talent = "pyre",
        startsCombat = true,

        -- TODO: Need to proc Charged Blast on Blue spells.

        handler = function ()
            if buff.essence_burst.up then
                if talent.feed_the_flames.enabled then reduceCooldown( "fire_breath", 2 ) end
                removeStack( "essence_burst", 1 )
            end
            if talent.causality.enabled then reduceCooldown( "eternity_surge", 1 ) end
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
            removeBuff( "charged_blast" )
        end,
    },

    -- Talent: Interrupt an enemy's spellcasting and preventing any spell from that school of magic from being cast for 4 sec.
    quell = {
        id = 351338,
        cast = 0,
        cooldown = function () return talent.imposing_presence.enabled and 20 or 40 end,
        gcd = "off",
        school = "physical",

        talent = "quell",
        startsCombat = true,

        toggle = "interrupts",
        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if talent.roar_of_exhilaration.enabled then gain( 1, "essence" ) end
        end,
    },

    -- Talent: The flames of life surround you for 8 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    renewing_blaze = {
        id = 374348,
        cast = 0,
        cooldown = function () return talent.fire_within.enabled and 60 or 90 end,
        gcd = "off",
        school = "fire",
        color = "red",

        talent = "renewing_blaze",
        startsCombat = false,

        toggle = "defensives",

        -- TODO: o Pyrexia would increase all heals by 20%.

        handler = function ()
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
            applyBuff( "renewing_blaze" )
            applyBuff( "renewing_blaze_heal" )
        end,
    },

    -- Talent: Swoop to an ally and fly with them to the target location.
    rescue = {
        id = 370665,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "physical",

        talent = "rescue",
        startsCombat = false,
        toggle = "interrupts",

        usable = function() return not solo, "requires an ally" end,

        handler = function ()
            if talent.twin_guardian.enabled then applyBuff( "twin_guardian" ) end
        end,
    },


    action_return = {
        id = 361227,
        cast = 10,
        cooldown = 0,
        school = "arcane",
        gcd = "spell",
        color = "bronze",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 4622472,

        handler = function ()
        end,

        copy = "return"
    },

    -- Talent: Exhale a bolt of concentrated power from your mouth for 2,237 Spellfrost damage that cracks the target's defenses, increasing the damage they take from you by 20% for 4 sec.
    shattering_star = {
        id = 370452,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "spellfrost",
        color = "blue",

        talent = "shattering_star",
        startsCombat = true,

        spell_targets = function () return min( active_enemies, talent.eternitys_span.enabled and 2 or 1 ) end,
        damage = function () return 1.6 * stat.spell_power end,
        critical = function () return stat.crit + conduit.spark_of_savagery.mod end,
        critical_damage = function () return talent.tyranny.enabled and 2.2 or 2 end,

        handler = function ()
            applyDebuff( "target", "shattering_star" )
            if talent.arcane_vigor.enabled then gain( 1, "essence" ) end
            if talent.charged_blast.enabled then addStack( "charged_blast" ) end
        end,
    },

    -- Talent: Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    sleep_walk = {
        id = 360806,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",
        school = "nature",
        color = "green",

        spend = 0.024,
        spendType = "mana",

        talent = "sleep_walk",
        startsCombat = true,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "sleep_walk" )
        end,
    },

    -- Talent: Redirect your excess magic to a friendly healer for 30 min. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    source_of_magic = {
        id = 369459,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "spellfrost",
        color = "blue",

        talent = "source_of_magic",
        startsCombat = false,

        handler = function ()
            active_dot.source_of_magic = 1
        end,
    },


    swoop_up = {
        id = 370388,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        pvptalent = "swoop_up",
        startsCombat = false,
        texture = 4622446,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    tail_swipe = {
        id = 368970,
        cast = 0,
        cooldown = function() return talent.clobbering_sweep.enabled and 45 or 90 end,
        gcd = "spell",

        startsCombat = true,

        toggle = "interrupts",

        handler = function()
            if talent.walloping_blow.enabled then applyDebuff( "target", "walloping_blow" ) end
        end,
    },

    -- Talent: Bend time, allowing you and your allies to cast their major movement ability once in the next 10 sec, even if it is on cooldown.
    time_spiral = {
        id = 374968,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "arcane",
        color = "bronze",

        talent = "time_spiral",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "time_spiral" )
            active_dot.time_spiral = group_members
            setCooldown( "hover", 0 )
        end,
    },


    time_stop = {
        id = 378441,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        pvptalent = "time_stop",
        startsCombat = false,
        texture = 4631367,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    -- Talent: Compress time to make your next empowered spell cast instantly at its maximum empower level.
    tip_the_scales = {
        id = 370553,
        cast = 0,
        cooldown = 120,
        gcd = "off",
        school = "arcane",
        color = "bronze",

        talent = "tip_the_scales",
        startsCombat = false,

        toggle = "cooldowns",
        nobuff = "tip_the_scales",

        handler = function ()
            applyBuff( "tip_the_scales" )
        end,
    },

    -- Talent: Sunder an enemy's protective magic, dealing 6,991 Spellfrost damage to absorb shields.
    unravel = {
        id = 368432,
        cast = 0,
        cooldown = 9,
        gcd = "spell",
        school = "spellfrost",
        color = "blue",

        spend = 0.01,
        spendType = "mana",

        talent = "unravel",
        startsCombat = true,
        debuff = "all_absorbs",

        usable = function() return settings.use_unravel, "use_unravel setting is OFF" end,

        handler = function ()
            removeDebuff( "all_absorbs" )
            if talent.charged_blast.enabled then addStack( "charged_blast" ) end
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

        spend = 0.03,
        spendType = "mana",

        talent = "verdant_embrace",
        startsCombat = false,

        handler = function ()
        end,
    },


    wing_buffet = {
        id = 357214,
        cast = 0,
        cooldown = function() return talent.heavy_wingbeats.enabled and 45 or 90 end,
        gcd = "spell",

        startsCombat = true,

        handler = function()
            if talent.walloping_blow.enabled then applyDebuff( "target", "walloping_blow" ) end
        end,
    },

    -- Talent: Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8 sec.
    zephyr = {
        id = 374227,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "physical",

        talent = "zephyr",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "zephyr" )
            active_dot.zephyr = min( 5, group_members )
        end,
    },
} )


spec:RegisterSetting( "dragonrage_pad", 0.5, {
    name = "|T4622452:0|t Dragonrage |T136088:0|t Animosity Padding",
    type = "range",
    desc = "If set above zero, the default priority can recommend |T4622458:0|t Fire Breath and |T4630444:0|t Eternity Surge sooner when |T4622452:0|t Dragonrage is expiring, reducing the risk that you will fail to extend it.\n\n"
        .. "If |T136088:0|t Animosity is not talented, this padding is set to |cFFFFD1000|r.",
    min = 0,
    max = 1.5,
    step = 0.05,
    width = "full",
} )

    spec:RegisterStateExpr( "dr_padding", function()
        return talent.animosity.enabled and settings.dragonrage_pad or 0
    end )

spec:RegisterSetting( "use_deep_breath", true, {
    name = "Use |T4622450:0|t Deep Breath",
    type = "toggle",
    desc = "If checked, the addon may recommend |T4622450:0|t Deep Breath, which causes your character to fly forward while damaging enemies.  This ability requires your Cooldowns toggle to be active by default.\n\n"
        .. "Disabling this setting will prevent the addon from ever recommending Deep Breath, which you may prefer due to the movement (or for any other reason).",
    width = "full",
} )

spec:RegisterSetting( "use_unravel", false, {
    name = "Use |T4630499:0|t Unravel",
    type = "toggle",
    desc = "If checked, the addon may recommend |T4630499:0|t Unravel when your target has an absorb shield applied.  By default, Unravel also requires your Interrupts toggle to be active.",
    width = "full",
} )

spec:RegisterSetting( "use_early_chain", false, {
    name = "Early Chain |T4622451:0|t Disintegrate",
    type = "toggle",
    desc = "If checked, the default priority may recommend |T4622451:0|t Disintegrate in the middle of a Disintegrate channel.",
    width = "full"
} )

spec:RegisterSetting( "use_clipping", false, {
    name = "Clip |T4622451:0t|t Disintegrate",
    type = "toggle",
    desc = "If checked, the default priority may recommend interrupting a |T4622451:0|t Disintegrate channel when another spell is ready.",
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

    potion = "spectral_intellect",

    package = "Devastation",
} )


spec:RegisterPack( "Devastation", 20230214, [[Hekili:T3ZAZTnos(BX1vrrYpKfPSDYmLLVA2jj3otT1KTgN72VjjkjkBEMIKlFyhpLl9B)6gpibbbaHE5Ku1v1UzKfaB0DJ(nAcn2z8xgF7cVC)X)H7a3HdCDUOVJZWbd)PX3M)CI)4Bt8M)G3DWhI8wb)7h8F0ll3lpioch75WyVfimYIlsNdJFFEEs2pF(53fKFFXS(ZJxDEwWQIqYtmp1Bzo(3ZpFwy8SZxK6DxC0YWG7Up)C)O7cI8pFEOxw2KvXlkc9Zo3lje))t8Fm(b)0(ZtsgF7SIGW8FlA8mLyUZ7aKjXF(4)W5IRGpFFWIf(0j7NnF8T4KpBG7zox8ZRNUE6VaJUy90pqWe4F8HVkkyvCwq(ZRN(p9wSii6U1t7UiDsc9p6TEAMFEo8P(JVnmilpdPFF8F)dc70pYBwO)IX)TX36nNYO8Z9tJaiojRif5L(RsIFYpDsEm(m3opnaMqGhbZddNK7bZkpRFYZPa(C9O1tDwp9K1tZ9c9JY7ZHw2KSeVO(S1B90xEz90zflx2Frj10p1FLxqugaL1tRObc0C6)Ulxp9yGCil69W(kSADmaJBOys9hHYytdsOK6hzi36P3I06PRNwKbGn1l6H1tb(A(6PEjjHbZrKgiPyKSOK74CyV0soy7Smxcr6sq39lJZT)2W3uWTRli4I0)W9g9pKGRdTL(pQCwlJJYNeVCYkV7cMBltAudU0W(UBbBsbVToxAiYLUWsUK4dEb8G5OW6sVIW8sTv(J(VlGfueOCHr(ekaS9rF5PiVFvTVitMfjmEyCwgHpSen7nruoB4Lvlxsm5)QGyJbBGGfOQP(OhSGWO4NclqHJ44WfXpfPGllPT()WEuyZ)Epq10hHayufWNNU3pA90i)VMJBTvMhdGXMbQ3pfN(azVoUihFCyOvEFfS1Vcg3p)jF8XjFT4tphKK8IG)5zWHbSE0nOmWmrWDrXPea(RF4pHrwU0FoIrz5bRqmQpHqNqDdHO1Kk4ISPlvWMaeYg2uDXMkbYZ42pUB(I(eyzedUA7XGLbP(tML67LFFTL3Uf(DBSeIt)HTyh)pjgSDk3IyZf2b9qB4WMcSB(Lp)HpdUrb)75bGnDYSUpUiCbkcG28gGQ754NG1l1pdMiqybrORa0q1Ie4pxgdp3h)BFcNBq4ImrQn1zcUGtW1dj13RrZFUhqh0)yc6uM6AMbKCqU6bW6icGFsRcRkdPOjPHWqaeMNt8vZxW0IiTRNxmbxDgSrR11BZsLLtnRLK6dXAnZRPHnyXZYa9k0KoOocszXr)LVklDBKeeJN2p3Ppi(mbCYpbT4rTX96oOO8cBktCiJKPYe9gqBUMqIxLbvrBUv0MgFdblff240xFjMdXlu3AS1kphfPKq2xp9nGkVc)jvtaurgqPbZZ7nTTsua1tYq0h8NhSWh9hfm)(sqqJCmXlamD8eKRHyi8GZeqDyjAncmFVkiQaJ8G41XP6VlnkOu6j75O5ALqM4hMbFEq)lRmOQZfeB3qfKAUVsxvd7CUA25CF125uUsL7CgzpQ8pAPIOt)GS(zjXbHzODSi)qiEL0c5Wz(ipyby7UAhE9uc4OHTawjt8OXzqcoHtnqCmlzFf75aXOfbpgqYpeFsASmL0C50P6Wb5Ouxmo)S(RN(39O4qquoyPNejdKtBWsIpYUZlstHqTdFg9mE5x7rLMVl4rFYdDpezioVK0aiKimxkCybqXPmyH(cIckxfrpXZV3l6oKq8YQn7QviaYo33ldzDO74f(S)ewIFbJgK47NruvRbX1DWsr2nQpIZnoL)POy4lrrBUQkNNxpMUkLVvErfEHBxKnccQ6ezuP5vTKYrySbljrknTy2ZtGGNdtMKDpHRj56cMdyldIaaLcNa8DV0iqMDsWCg0BWp8)68WIf(QcFzdWoxlWo3ng7CfXUgr8SHwa5IJI2apcvFn4atVnsKYAZcARgrpV2eWNDs1G9ibr3LOftRqtQsV4cZubcrvn6r(F30aRu6Q88AtWASsoOk9yLJawv3SUtPKfPGfoY18Ifx69Eak7VysC6msKNXPRalEvIb6Macs5OrReg4LOasxkdFcE5jQGB5qeiPp9CH6DOhyHG9FqlyzOhj7JCAO9gk0NqEz19m9lF(JGrY50nim(DW7Ixywm1EkeHEFrKZCEHyXwyjgseJBnp2R51bINoPIi(nx4cQYIUsnDvzjKuI4ia6vXJGufjjIKb5S5Rmc92lIs1UNWG1kvLHAGq0YCgqOkELXE0pDwbW8472nLfmMH5YzMklLaZq5USzuuxEPVBSuDKveb6HfdUACZcykhK3HfdUyCZIdkhZWEadqbk26G19VgKAWbKdG4vrA(YgiPCTqTso2VLAKOX2GPIN3LnmyJZpAo65jnlhTcnjl3B(dKYCPycSb7vV(BCIW7VkGTaSwjp0wPwoQj6vKiyX23pHVxw6oRPZK6LlXPwLHbxz5504LaSovEU6TUzCx9AbJ8htSX2rJ9vXh5kr(L1EhUYsUSSbUgoMFmgpPVqyvAAaf1Ajqr2iLK4fAhoUiVMSvOVxsPT5m(qhPuYrC3vYb(F4iBEYYndYj40QPOguQSPO9ZQrpChoRbsTdgCXKzHEvQnuiOaJ0v)0fbzyAH3LINOQYWKKKY1yFsEwIgP42OO7wKVI9zQW6zK6ZuEotkThmYS1ea1VhwpwbhC0BiJturEjOQuf1WzRvsH6LMChiAgOM2snBa5cLGwrWJ1cu8lPpZQv1DyU00eyzv7k9rsLWyhLgMG9k8J4tGNjpEkkKQTJjKlEOl3rkcsECmPOaPWm(FlWI4tozwSWfErp)K3Z9ldExvwZT6eGBOxXtpHHNvhcMUjsOT6ttLgYjCBw0KLA3g3O6wtDjEwoP(d3EW2Lpzp2XY)EYhnESE4HAkOjQI3QiC8YGLPYnqsxzHX5I)Tn7hh1iJ0QYDjL3FjxOeZvM(CvbJgvQTQiLwwnbiChQHAfzysR5sJ6JiLnlAktINk9akYpMKvYaoBOCTLo7mIji3b2eewpbwQUW4ALzjxA7ViuTrETXiLuKuaWmHt)CbRgMNYRPgwupq9DbYBsjnvbAYaRho(DYveVVQSSKeXC3CrkhtIuoBLiLRMj5yJiLRArQgLTPnrkLfc67qrkxIivnddUMYd1gJjTvUnnfmRgJu9Eddg927SqtwxK04(nWZyCew394i0fAeZjyPsiVe(K6YGymVbMi6LX5K6YJpwjLVE6Nz1apYpGoE7qBwmQGwdoMsFxLkQrMS(d2R1nkNx3nQYsV3uooNC82TfW0TFz90FHvyT)bTWAb5VnRSWA8GAE4ESs2H(FLu8jIvZjKopS1Kfj4(cFAml1JVDc7RrwB12L(LYyH3An5UnnTo36jdAmmfiNIbkRJPjph1RKx99L)BIwdeYji04JoNWU6H2urErcTvcTFsEko6T5iwHHVgLrIZLOYrEQGiGujHPITncOY9ViWjTikICsEF6lFIPyHsbF8wyQ8Esc3LYPNwhckeHiTPuWFr9GUjr2Qjn9szAXMvP1h8M2I80yaW3yHealYuEzU9HKejYJ0COfZ4XCLBv4rrvcI6QDLrZh8cxvbgpE73whk6k)MvL1IwEw91D4BarSdLNtUgg1u7(xEOke5Cz)0F7Cuvaf5XWfbg2INPEQYsansIMJxeZN2)1V(bulKCIX0g1I2Nw0djNOJgbakmo6oYb)gqAb6kLvQcgEAFZnBjRIuFcqvf5KRG3POeJwu5XsdFNOvh9ygeQBjRpnCwtG)S20EXym38fvv9RRZrvRS)Dft1w(Mo7w3STCoDf3QrbA1PX4I9HygvLH4o52BjnEe2GSCb9p8NNYce8PGmFb3o)6hSisIDQ6w1SN7)SpwfHGOLbrI1Bvr97vw)kPOOsi(OjA7HeTDhAfMCjMgYQ8GIK6sihu)0mU)9GYSxPmqlCPAseBpEIbkRNN5Zl4BlcBO476oZzHdPO2w6F3lDb30nlNNI8kJ1OOTxzCzKiSYihk9tEpNXCra)hwbsj5YmpZcjCRIvwSkG8sWY2z0vjS2fEzBXmuLkss(74h9tN7LKqCybmlY7QutPuvh8GYDSRBB)UJqvUVwrvUvEUqQRJC9(Blcmv6JDJfSXgga45heQBVOnkSv(XqKPQLKETNP0c7X)tWcmGfNvQBpZFjPDSrzcS)(roqfSSq7OBDcEipQsfSjUvWURB9Kf6yZblG1LzpQaYA5fvN2v9kjerzZKZB4C6MH3YCs6)Or0HOY3cVvKyeZdM)aW3)SO(h(WjKnIRW3OS5XrlK2jkIWw3MwHEfrMPwQUSP8t9FeKnYPlczo4seGyFMWXKClk(KMwKKpb7sRM7VDqKp7MrUD6YEl8W(hcjyCLF5fnjoimGKF(IKEaB1ln85jeSGSUcGwyiyb6yaJAtWKjMTppdlwRUCipdRAnltTZLZ8HNQ3EC9dru4eVPzVmw7HHFL45Bv3aCfkqkudKHLH2IsBdtuR0JDPvts(T2JCWMtwcgN9aUm9fjKE4nlIZfL6Mqv3KDnVbW8y2BQIXuVpyVjL01f5zpcAbr(Rc8z23CvvBLpbuoFBKAMplEfnpVq0B)t(bKaay8xSqLGfJuIbOYiEXGdM5p3JDuGzSU1fqIckuGbwwe(FUE6VT4H(LgxUfwjsfudJJFGxTLGmPsVz8n6ut74GTT4fwVH9DKqW3I3ku98W3Bn5EOzHvwF)b(flvRbm6BvkyaeuTYWPsFB0DChIPItAOWm2b9fapwkxV7T(zVfvv)3f0tSJQ66vKhZoUpAh7N1F9V)pcqfnhqR7xJJGLHm8Bv(k9(wAgzQhKZXHj115R9kHS7bdYdFTHCnjmjaRu6RcUR)DfBsLVvDB2Evdok7CyONxkrmT8DWOeltRDOQnMK5TSnFb4nb(waAwZCycZRMY(f47awJkOSEtZeMxFA7)fzhOaIrlt4oFc7taVd4l6qYe6YgFpcwDiBdZfShZ1g9fntAFVa7aURtNr5u2VaFhWAt6kAN2(Fr2bkqTEJIjSpb8oGVk1CAo(EeS6q2l0QM3OZBuOQRAohuWFWa83i8ooXNoJmAPKERUUaPtxtW)nVP6RQc7Mp6Obc1asX4V5nMG9Ob94K4wIC7eU1gQvYzVuR(r7BzQNtnjI9n4pya(BeE3UKSBdHffWFVjjRa2MKKTd52jCRnuRKZELwJpQFrQvybs7eRjB8oTYgwUqgMyTf69MOi53eA1KJIzz)sO9fPw9AzA61w0FYedSv6s3SSFjSNUAD61wuNb7zRghA4BdKXdJSVx0ZtwKKzc66MNTuGTRdAWzYwaFRtKXCMs7JvqxuLAH92g)0Hg(2az72x1ppBPaBxNTt(zdQm1wk)SbRGTYpncU4iTHIQZZ(lVO3NVzN(6uz7DCxN(xEIgvcyufliExo0R3nDnhWSUnz5v0P1v0HTIC()RiF78xD(25ha(wLiPMQZx20pLI4sFVUkN7OR05BoajfmFzCyy8t0EjfOBSTB8XgyG(Yjv2bPESo0hBMv8KAY5ZJCCJlJlIQn7flWjVWl3BMxM)pV(3PDoyAqUMk17fJ1lzdQrVg2qve0s8bHqR3SZKOXvlHeG1E1tid)gHAUZyStJ6nqFYQ3IBjq2817Ubi1GLs9uHeC10xgnaEJOszpoRfYKHQ0l3Bf4ukcXuc3WZLtxbRR)6wQjqgHHRrO6bAP1h2HBQaWkMYbe4Tcw7JSWQiy29LXyam6b)2fH3bg86b8oBCqxHFDmly3yylbARYEkNYbe4Tcw7t5Ykb7DFzmkyRh8Tl5zrQ17BW3Mx1DqWwxr23o7FhuGRhS7mxqxbA3oLLdkW1d2DGlOmeGSnSrp0flD9x1ojSsZlIxRss7aXAeILVAqsaSXRmuR7Y7mgQbIBng2OK27i8Au56DeEAcww6v7rcQAEXFAb2nRLbPuj1Aw4xEH8DkAA5rJumszhl)YlTIAecyZwYDAflzd6Y3D)KqIgvQdcWBSdQIB29iZlIWHfPPn3V5QxEHX1VrO12pZzBLokRc03p4Rz0vN3HLZ2pEh2LMu83iyecU3vVOk4YI)maeVmiS81joRFzhmEYOZNP8xcG1)UQ5Yln1P4lE8iM3zEv7oLCx0mQEgb1R8kOG2CuwRePCShRAuhLJtAjgLJqRkK9eHRsIq1XpuTCn7hkLJPKiK7RhLJqjI)J1tp0x39BcNIwoYtJtgrUdNzCmNtRUoGhnO)LNw(EfnQ9o14a2fjQ7uJnHED3z6TX55Fa71a1NNpri6))EW)hS7b)nrkLF1g1WkS6MIytaTRAqRRFl2eqxEbEPcTL7gbr78MAGGnbbC1GakBhcrB07leGlJjBFXv0(IJG1Ld0PMz6Wg1uSjPtYsLVslpantN7OMs4kT4QI2W0zPPElcpfUGC)v0Tinxg9QF0Yte70GLJ4XTX)o1pI4Roj(uh18XkFqy6KFl6e)c2V9CIFf93hoeyktQkolRtTR4PRhEjX1Wps)IVjsV11PKUfEyAsQ8BYFjWSguG2jqvYqu9DvYzUhZFTX3r4R4oK5SsqdBBFd)5ytpPjE5SWdwQ)WJfFV8eEw5B2OAwhRTks)GNrNOxS)P0FC0aJKGyFZBg5BgnSvOa)xZa56HOUiWXB7ELRstpRPbfT3aCeT)MASDS4kZO(6jirbG0KC01m5OoTimFDPWSA7hdiSLFuUw3Kyx1VXGuB2Stx5VJt7LoxeL41o9BmTBWQkHPNs92tVYAEjva5ohPC9ks6jXduRaUCMOhPk8siwcjty34C5lVCKCnoF5f1xrBwHe0TK9msuNpsKE)2E7OjXkWRQRtZ8NBu7viiJsQu1DIHorxMk9jkfHpM8ukUnT0bUZmHQ3mAZwKwzhQveoOCK2jC1i1nBkPxxyChV4XK4KsEr04ZzBRNRUAVt9AUpVhXKil5OO3G98UMiOZ0Xh6XDisHRW9dvDet8gB61fXi88dXf9LefwlNNTl(fM4MW19LOaZgE3DzJKr12vhD8XRnX97W((RRDQc06R9n5E4AZL66YjHHDosbPsoag1N)sN2o2LRhTJIU9OLQ8h67rl5yYfecoLqqqwg1VPRgTvx0vNkEjDPAJ(aChDPR0c6oXUdZj1z(O6K5)vxFv6StP9QW6ghd2uyPe2(pIFvWasxDZYsBKTPPnSrnhylMD54OiL3rWgJfjrqxftzrOsErvq9gkuZnod6WJV4rPoJwgveW0tRUuEOz23YsOQ6bVZs47ULW)klH)WTe(xyj8Ta)Bpzotcd6e(2cHHlnMrxDKXchIhSWWKu7B1qKQTkPcithqYwAB0SbMjpXNJVQJrdrxDSTwIUsh9JYJcPPv9AdiprRcCRXp(BAcMrhwysaBKT6sBpWgnKsgk(HAdFIgYoQcIqO4iBUB3l3C3UMuhABpKJNSa91N7utjyMF2FuUEdRiLLZAXDux3bN4EmJ108wZR3jMVd(UUTN)yN(d1wAXRRUb9obVXbfRqVotIGOP40E5fKuRUxkVEKRDupXztxNl((G6D7BlXlXMSJyjEU7((xbA9ivnmMEwWibEaE)jAhtqIBzhp4cMs8hz(maTj0Pb)x(i6De5QyYVzzjjHbZzNgjefn3Qz1c5JhKtDVpnuTufqRZj8yiZfVobTsgzl1qSgPD1H0Uv77BbAVheTBbXhQdXhEYqDi(3w50wiiUO63YFZnRqw(jHEsJUtOzN3Ol5oY3z(hGtED4m8JVP29NtU64UDBlQqEISh727KUwLYlmZEGo777P8Ghh5sp5XxVFTenVNG)oLXp2AhDBehvVxz4SbX(kQK1WiufnVdVLHg5OSZEyn0uVoQ6uiANCj2jvk7UMBgvJBlo)QqDzZ96rxnOtxTNiN7avj41dygQsf0aX2Z(na3w3aC0Sb08fnYeo5QyqhtBaUn2a00BvA3au0NwVsBaUSsZ(97pwI2lGqZDsBN0PQR4k3juTRsESEBXMGEDu7jgx1etJUowLSTwEW(HyQ(DC0RihC4n(2Bdw9RK7g7X)Fd]] )