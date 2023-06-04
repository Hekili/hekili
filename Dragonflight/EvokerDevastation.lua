-- EvokerDevastation.lua
-- November 2022

if UnitClassBase( "player" ) ~= "EVOKER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local L = LibStub("AceLocale-3.0"):GetLocale( addon )
local class, state = Hekili.Class, Hekili.State

local W = ns.WordWrapper

local strformat = string.format

local spec = Hekili:NewSpecialization( 1467 )

spec:RegisterResource( Enum.PowerType.Essence )
spec:RegisterResource( Enum.PowerType.Mana )

-- Talents
spec:RegisterTalents( {
    -- Evoker
    aerial_mastery         = { 68659, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame          = { 68671, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream   = { 68672, 376930, 2 }, -- Your healing done and healing received are increased by 2%.
    blast_furnace          = { 68667, 375510, 2 }, -- Fire Breath's damage over time lasts 0 sec longer.
    bountiful_bloom        = { 68572, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame      = { 68673, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 7,854 upon removing any effect.
    clobbering_sweep       = { 68570, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 45 sec.
    draconic_legacy        = { 68685, 376166, 2 }, -- Your Stamina is increased by 3%.
    enkindled              = { 68677, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    extended_flight        = { 68679, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance             = { 68573, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    fire_within            = { 68654, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    foci_of_life           = { 68654, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over 4 sec.
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
    panacea                = { 68680, 387761, 1 }, -- Emerald Blossom instantly heals you for 8,064 when cast.
    permeating_chill       = { 68676, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by 50% for 3 sec.
    protracted_talons      = { 68661, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                  = { 68665, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall                 = { 68684, 371806, 1 }, -- You may reactivate Deep Breath within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic     = { 68651, 387787, 1 }, -- Source of Magic forms a bond with your ally, causing 15% of their healing to also heal you while you are below 50% health.
    renewing_blaze         = { 68653, 374348, 1 }, -- The flames of life surround you for 8 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    rescue                 = { 68658, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    scarlet_adaptation     = { 68687, 372469, 1 }, -- Store 20% of your effective healing, up to 3,353. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk             = { 68571, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic        = { 68669, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 30 min. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    tailwind               = { 68678, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    terror_of_the_skies    = { 68649, 371032, 1 }, -- Deep Breath stuns enemies for 3 sec.
    time_spiral            = { 68650, 374968, 1 }, -- Bend time, allowing you and your allies within 40 yds to cast their major movement ability once in the next 10 sec, even if it is on cooldown.
    tip_the_scales         = { 68686, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian          = { 68656, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5 sec.
    unravel                = { 68663, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 12,255 Spellfrost damage to absorb shields.
    verdant_embrace        = { 68688, 360995, 1 }, -- Fly to an ally and heal them for 13,502, or heal yourself for the same amount.
    walloping_blow         = { 68657, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr                 = { 68655, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8 sec.

    -- Devastation
    animosity              = { 68640, 375797, 1 }, -- Casting an empower spell extends the duration of Dragonrage by 4 sec.
    arcane_intensity       = { 68622, 375618, 2 }, -- Disintegrate deals 8% more damage.
    arcane_vigor           = { 68619, 386342, 1 }, -- Shattering Star grants Essence Burst.
    azure_essence_burst    = { 68643, 375721, 1 }, -- Azure Strike has a 15% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    burnout                = { 68633, 375801, 1 }, -- Fire Breath damage has 16% chance to cause your next Living Flame to be instant cast, stacking 2 times.
    catalyze               = { 68636, 386283, 1 }, -- While channeling Disintegrate your Fire Breath on the target deals damage 100% more often.
    causality              = { 93364, 375777, 1 }, -- Disintegrate reduces the remaining cooldown of your empower spells by 0.50 sec each time it deals damage. Pyre reduces the remaining cooldown of your empower spells by 0.40 sec per enemy struck, up to 2.0 sec.
    charged_blast          = { 68627, 370455, 1 }, -- Your Blue damage increases the damage of your next Pyre by 5%, stacking 20 times.
    dense_energy           = { 68646, 370962, 1 }, -- Pyre's Essence cost is reduced by 1.
    dragonrage             = { 68641, 375087, 1 }, -- Erupt with draconic fury and exhale Pyres at 3 enemies within 25 yds. For 18 sec, Essence Burst's chance to occur is increased to 100%, and you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    engulfing_blaze        = { 68648, 370837, 1 }, -- Living Flame deals 25% increased damage and healing, but its cast time is increased by 0.3 sec.
    essence_attunement     = { 68625, 375722, 1 }, -- Essence Burst stacks 2 times.
    eternity_surge         = { 68623, 359073, 1 }, -- Focus your energies to release a salvo of pure magic, dealing 9,166 Spellfrost damage to an enemy. Damages additional enemies within 12 yds of the target when empowered. I: Damages 2 enemies. II: Damages 4 enemies. III: Damages 6 enemies.
    eternitys_span         = { 68621, 375757, 1 }, -- Eternity Surge and Shattering Star hit twice as many targets.
    event_horizon          = { 68617, 411164, 1 }, -- Eternity Surge's cooldown is reduced by 3 sec.
    everburning_flame      = { 93363, 370819, 1 }, -- Red spells extend the duration of your Fire Breath's damage over time by 1 sec.
    expunge                = { 68689, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    eye_of_infinity        = { 68617, 411165, 1 }, -- Eternity Surge deals 15% increased damage to your primary target.
    feed_the_flames        = { 68615, 369846, 1 }, -- After casting 9 Pyres, your next Pyre will explode into a Firestorm.
    firestorm              = { 68635, 368847, 1 }, -- An explosion bombards the target area with white-hot embers, dealing 5,682 Fire damage to enemies over 12 sec.
    focusing_iris          = { 68619, 386336, 1 }, -- Shattering Star's damage taken effect lasts 2 sec longer.
    font_of_magic          = { 68632, 411212, 1 }, -- Your empower spells' maximum level is increased by 1, and they reach maximum empower level 20% faster.
    heat_wave              = { 68637, 375725, 2 }, -- Fire Breath deals 20% more damage.
    hoarded_power          = { 68575, 375796, 1 }, -- Essence Burst has a 20% chance to not be consumed.
    honed_aggression       = { 68626, 371038, 2 }, -- Azure Strike and Living Flame deal 5% more damage.
    imminent_destruction   = { 68631, 370781, 1 }, -- Deep Breath reduces the Essence costs of Disintegrate and Pyre by 1 for 10 sec after you land.
    imposing_presence      = { 68642, 371016, 1 }, -- Quell's cooldown is reduced by 20 sec.
    inner_radiance         = { 68642, 386405, 1 }, -- Your Living Flame and Emerald Blossom are 30% more effective on yourself.
    iridescence            = { 68616, 370867, 1 }, -- Casting an empower spell increases the damage of your next 2 spells of the same color by 20% within 10 sec.
    landslide              = { 68681, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 30 sec. Damage may cancel the effect.
    lay_waste              = { 68624, 371034, 1 }, -- Deep Breath's damage is increased by 20%.
    onyx_legacy            = { 68630, 386348, 1 }, -- Deep Breath's cooldown is reduced by 1 min.
    power_nexus            = { 68574, 369908, 1 }, -- Increases your maximum Essence to 6.
    power_swell            = { 68620, 370839, 1 }, -- Casting an empower spell increases your Essence regeneration rate by 100% for 4 sec.
    pyre                   = { 68644, 357211, 1 }, -- Lob a ball of flame, dealing 2,573 Fire damage to the target and nearby enemies.
    raging_inferno         = { 68634, 405659, 1 }, -- Firestorm's radius is increased by 25%, and Pyre deals 20% increased damage to enemies within your Firestorm.
    ruby_embers            = { 68648, 365937, 1 }, -- Living Flame deals 541 damage over 12 sec to enemies, or restores 1,548 health to allies over 12 sec. Stacks 3 times.
    ruby_essence_burst     = { 68645, 376872, 1 }, -- Your Living Flame has a 20% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    scintillation          = { 68629, 370821, 1 }, -- Disintegrate has a 15% chance each time it deals damage to launch a level 1 Eternity Surge at 50% power.
    shattering_star        = { 68618, 370452, 1 }, -- Exhale bolts of concentrated power from your mouth at 2 enemies for 3,921 Spellfrost damage that cracks the targets' defenses, increasing the damage they take from you by 20% for 4 sec.
    snapfire               = { 68634, 370783, 1 }, -- Living Flame has a 15% chance to reset the cooldown of Firestorm, and make your next one instant cast and deal 100% increased damage.
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


-- Support 'in_firestorm' virtual debuff.
local firestorm_enemies = {}
local firestorm_last = 0
local firestorm_cast = 368847
local firestorm_tick = 369374

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
        if subtype == "SPELL_CAST_SUCCESS" and spellID == firestorm_cast then
            wipe( firestorm_enemies )
            firestorm_last = GetTime()
            return
        end

        if subtype == "SPELL_DAMAGE" and spellID == firestorm_tick then
            local n = firestorm_enemies[ destGUID ]

            if n then
                firestorm_enemies[ destGUID ] = n + 1
                return
            else
                firestorm_enemies[ destGUID ] = 1
            end
            return
        end
    end
end )


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
        duration = 18,
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
    feed_the_flames_stacking = {
        id = 405874,
        duration = 120,
        max_stack = 9
    },
    feed_the_flames_pyre = {
        id = 411288,
        duration = 60,
        max_stack = 1
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
    imminent_destruction = {
        id = 411055,
        duration = 10,
        max_stack = 1
    },
    in_firestorm = {
        duration = 12,
        max_stack = 1,
        generate = function( t )
            t.name = class.auras.firestorm.name

            if firestorm_last + 12 > query_time and firestorm_enemies[ target.unit ] then
                t.applied = firestorm_last
                t.duration = 12
                t.expires = firestorm_last + 12
                t.count = 1
                t.caster = "player"
                return
            end

            t.applied = 0
            t.duration = 0
            t.expires = 0
            t.count = 0
            t.caster = "nobody"
        end
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
    power_swell = {
        id = 376850,
        duration = 4,
        max_stack = 1
    },
    -- Talent: $w1% of damage taken is being healed over time.
    -- https://wowhead.com/beta/spell=374348
    renewing_blaze = {
        id = 374348,
        duration = function() return talent.foci_of_life.enabled and 4 or 8 end,
        max_stack = 1
    },
    -- Talent: Restoring $w1 health every $t1 sec.
    -- https://wowhead.com/beta/spell=374349
    renewing_blaze_heal = {
        id = 374349,
        duration = function() return talent.foci_of_life.enabled and 4 or 8 end,
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
    scarlet_adaptation = {
        id = 372470,
        duration = 3600,
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


spec:RegisterGear( "tier30", 202491, 202489, 202488, 202487, 202486 )
-- 2 pieces (Devastation) : Disintegrate and Pyre pierce enemies with Obsidian Shards, dealing 12% of damage done as Volcanic damage over 8 sec.
spec:RegisterAura( "obsidian_shards", {
    id = 409776,
    duration = 8,
    tick_time = 2,
    max_stack = 1
} )
-- 4 pieces (Devastation) : Empower spells deal 8% increased damage and cause your Obsidian Shards to blaze with power, dealing 200% more damage for 5 sec. During Dragonrage, shards always blaze with power.
spec:RegisterAura( "blazing_shards", {
    id = 409848,
    duration = 5,
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

        spend = function () return buff.essence_burst.up and 0 or ( buff.imminent_destruction.up and 2 or 3 ) end,
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
            if set_bonus.tier30_2pc > 0 then applyDebuff( "target", "obsidian_shards" ) end
            if buff.essence_burst.up then
                removeStack( "essence_burst", 1 )
            end
        end,

        tick = function ()
            if talent.causality.enabled then
                reduceCooldown( "fire_breath", 0.5 )
                reduceCooldown( "eternity_surge", 0.5 )
            end
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
            if talent.ancient_flame.enabled then applyBuff( "ancient_flame" ) end
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
        cooldown = function() return 30 - ( 3 * talent.event_horizon.rank ) end,
        gcd = "off",
        school = "spellfrost",
        color = "blue",

        talent = "eternity_surge",
        startsCombat = true,

        spell_targets = function () return min( active_enemies, ( talent.eternitys_span.enabled and 2 or 1 ) * empowerment_level ) end,
        damage = function () return spell_targets.eternity_surge * 3.4 * stat.spell_power end,

        handler = function ()
            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
            end

            if talent.animosity.enabled and buff.dragonrage.up then buff.dragonrage.expires = buff.dragonrage.expires + 4 end
            -- TODO: Determine if we need to model projectiles instead.
            if talent.charged_blast.enabled then addStack( "charged_blast", nil, spell_targets.eternity_surge ) end
            if talent.iridescence.enabled then addStack( "iridescence_blue", nil, 2 ) end

            if set_bonus.tier29_2pc > 0 then applyBuff( "limitless_potential" ) end
            if set_bonus.tier30_4pc > 0 then applyBuff( "blazing_shards" ) end
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
            if set_bonus.tier30_4pc > 0 then applyBuff( "blazing_shards" ) end
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
            removeBuff( "snapfire" )
            applyDebuff( "target", "in_firestorm" )
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
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
        cast = function() return ( talent.engulfing_blaze.enabled and 2.5 or 2 ) * ( buff.burnout.up and 0 or 1 ) end,
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
        cast = function() return ( talent.engulfing_blaze.enabled and 2.3 or 2 ) * ( buff.ancient_flame.up and 0.6 or 1 ) * haste end,
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
            return ( buff.imminent_destruction.up and 2 or 3 ) - talent.dense_energy.rank
        end,
        spendType = "essence",

        talent = "pyre",
        startsCombat = true,

        -- TODO: Need to proc Charged Blast on Blue spells.

        handler = function ()
            removeBuff( "feed_the_flames_pyre" )

            if buff.essence_burst.up then
                removeStack( "essence_burst", 1 )
            end

            if set_bonus.tier30_2pc > 0 then applyDebuff( "target", "obsidian_shards" ) end

            if talent.causality.enabled then
                reduceCooldown( "fire_breath", min( 2, true_active_enemies * 0.4 ) )
                reduceCooldown( "eternity_surge", min( 2, true_active_enemies * 0.4 ) )
            end
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
            if talent.feed_the_flames.enabled then
                if buff.feed_the_flames_stacking.stack == 8 then
                    applyBuff( "feed_the_flames_pyre" )
                    removeBuff( "feed_the_flames_stacking" )
                else
                    addStack( "feed_the_flames_stacking" )
                end
            end
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
        cooldown = 20,
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
            if talent.arcane_vigor.enabled then addStack( "essence_burst" ) end
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

        usable = function()
            return settings.use_verdant_embrace, "use_verdant_embrace setting is off"
        end,

        handler = function ()
            if talent.ancient_flame.enabled then applyBuff( "ancient_flame" ) end
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
    name = strformat( L["%s: %s Padding"],
        Hekili:GetSpellLinkWithTexture( spec.abilities.dragonrage.id ), Hekili:GetSpellLinkWithTexture( spec.talents.animosity[2] ) ),
    type = "range",
    desc = strformat( L["If set above zero, extra time is allotted to help ensure that %1$s and %2$s are used before %3$s expires, reducing the risk that you'll fail to extend it."],
        Hekili:GetSpellLinkWithTexture( spec.abilities.fire_breath.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.eternity_surge.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.dragonrage.id ) ) .. "\n\n"
        .. strformat( L["If %s is not talented, this setting is ignored."], Hekili:GetSpellLinkWithTexture( spec.talents.animosity[2] ) ),
    min = 0,
    max = 1.5,
    step = 0.05,
    width = "full",
} )

    spec:RegisterStateExpr( "dr_padding", function()
        return talent.animosity.enabled and settings.dragonrage_pad or 0
    end )

spec:RegisterSetting( "use_deep_breath", true, {
    name = strformat( L["Use %s"],
        Hekili:GetSpellLinkWithTexture( spec.abilities.deep_breath.id ) ),
    type = "toggle",
    desc = strformat( L["If checked, %s may be recommended, which will force your character to select a destination and move."],
        Hekili:GetSpellLinkWithTexture( spec.abilities.deep_breath.id ) ) .. "  "
        .. strformat( L["By default, %1$s also requires the %2$s toggle to be active."],
        W( spec.abilities.deep_breath.name ), "|cFFFFD100" .. L["Cooldowns"] .. "|r" ) .. "\n\n"
        .. strformat( L["If unchecked, %s will never be recommended, which may result in lost DPS if left unused for an extended period of time."],
        W( spec.abilities.deep_breath.name ) ),
    width = "full",
} )

spec:RegisterSetting( "use_unravel", false, {
    name = strformat( L["Use %s"],
        Hekili:GetSpellLinkWithTexture( spec.abilities.unravel.id ) ),
    type = "toggle",
    desc = strformat( L["If checked, %s may be recommended if your target has an absorb shield applied."],
        Hekili:GetSpellLinkWithTexture( spec.abilities.unravel.id ) ) .. "  "
        .. strformat( L["By default, %1$s also requires the %2$s toggle to be active."],
        W( spec.abilities.unravel.name ), "|cFFFFD100" .. L["Interrupts"] .. "|r" ),
    width = "full",
} )

spec:RegisterSetting( "use_early_chain", false, {
    name = strformat( L["%s: Chain Channel"],
        Hekili:GetSpellLinkWithTexture( spec.abilities.disintegrate.id ) ),
    type = "toggle",
    desc = strformat( L["If checked, %1$s may be recommended while already channeling %2$s, extending the channel."],
        Hekili:GetSpellLinkWithTexture( spec.abilities.disintegrate.id ), W( spec.abilities.disintegrate.name ) ),
    width = "full"
} )

spec:RegisterSetting( "use_clipping", false, {
    name = strformat( L["%s: Clip Channel"],
        Hekili:GetSpellLinkWithTexture( spec.abilities.disintegrate.id ) ),
    type = "toggle",
    desc = strformat( L["If checked, other abilities may be recommended during %s, breaking its channel."],
        Hekili:GetSpellLinkWithTexture( spec.abilities.disintegrate.id ) ),
    width = "full",
} )

spec:RegisterSetting( "use_verdant_embrace", false, {
    name = strformat( "%s: %s", Hekili:GetSpellLinkWithTexture( spec.abilities.verdant_embrace.id ), Hekili:GetSpellLinkWithTexture( spec.talents.ancient_flame[2] ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended to cause %s.", spec.abilities.verdant_embrace.name, spec.auras.ancient_flame.name ),
    width = "full"
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


spec:RegisterPack( "Devastation", 20230603.1, [[Hekili:T3tyZTnoU(BjZnRtCBItSCsVU7loVPPj92UZEx3Po3UZ7lXr2I2rVkl5tsoPzNm(3(daKuIKIuw2XjBV3TZ7D31yrcccccacacED3RV66bb(5SR)hEh517O3CuVoEDp5KEF)1dYFyo76bZ9h)f)PW)i2Fg8FFb7o)SC)8WKy8BpeL4hGWilzr6y473MNpp7ho8WPH53UyuNXjZomlC2IiQhJt9NKJ)94dhfLm6WGu)PjXtIcNEB(HS4PHXSdhh5NLnCwsWIiw2H(ZJW)Zq2DjFHL2z885xpy0IWO8pgF9i7y(BbKzoB81)JUh)M)kGqHbbmEJzzJVEa24do6nhCuVFy5nV)w)4PSL38RS0a)48L3C5SrP(JHFzCsCqiIZz)xlVjLLLNKc)ACs8bx17OL38HZp8YblVzrgqA6S8Nw(tCWEYbEFpa2)EyCsk815i(LT8MjPjZwEZGc6W7r6GE3El0TlJZwGJIa4J9JHUgghMD7YBcNS8MC)0Pmajdbq6pkzb8pZtwEtqiGc3S8M9GbyEu4KqwqN2QaV7XaW)m7UWma472V)U8(Tl(pMGikmzZcZYzXJFqdR66bD8JWYgBglo3pIMdVxoXGrminzoGm7MLpmzolMLcqCEAysAy(dT1a1r4eCWIraVtCEicQXeTpJJlC4cCiau9N6hgR3zCcudMKHt(B9ZZzPHXtHVbuQ9b6yisnppL5NFl8NxcFogqmepacj8l)YdP4)ZphEh1TpebS4QO9Xh07iAK)N0WeOSs(EbPR7rD6Q1JJorPh6DyCeZpMgPfZxEZ7(0LLelywV8MrHQmf940myLdwPHDgLKDRStixkYSGGhNxcMtaW5ilYKjSugYHlzIgNSiohzKIHPfSQm(lWFKmH2taTa(XZHDIQiKhNrcWCyhf89lODVP0G8U4Wzjz0e5x8dciSa4ogoN)hTHHGLdZIPDUEqeWQLHYmy4)9)GebXI9hfXcU(8Rh4pMlCHjwUgMHRwWFpBEY9S0H5jyFgmgiBWYTpVd3XgcSFZcrwHt7dlllV514CncMZDKqkBy2C)4oIXA5np(iqZxmzsNGIzshGbd4(qOaaPZF9KL38ka3NZIIgElqoGPARA60z8H2Sl2giKfaa1EWkGb(dW4eEF2zLtHwv7oIdVH3)nRZVD5nT5sltdNZxlQU1zbklj1p(llVbw4b(j)5GSNXiK57O58zzDUoheq3WL46xt9O1upI8(exz96SjlSwyh0zl9WjBVTYKThnz710jBjNYKKyqy8KHZ8NgoUPueCa74Tb0elesDsspKKCCdjjQD8yOJ5xpyAkd0EBrmHg)5FdBfWCIyrgXCgi4ctdNoLLIcOghsY)iH8kOWmwQFuWqWEKSSKzfCRYVFh3YGHmUHbQOaHFbSj(lIYlWqz)(xlaurV16aEbqnVJz2exmpZt4)VAZ6lyr(Wws4BGnb40)kUDcpKSa2pIQauSsyayrXb8nRrpGklIal5qccPgJR9E5n3Fld7hbH7PpFXNp4SpC(bNnyWbNLMiT8RK51TCTDqLmjrbj3h3jRq78qqxtk1kKL0M8hyhEBbdlSMqqBcAH4q1DW9oXgJvcyEiOOrz5Zhqs4R4)kAbURtIrv5OnOU)QORa57wuhkdHa3ydGkbK7y2xrvRkAbrdZgbe37ts)cPcKt9Vf(0m)Vc6Rb12Jy53tmR0pR27XbcTXa1hwkeBgYaHTHtb7jja((l(m8fqz(yeJYYdNHyuhAIoKBHoIwdlHlsMoXczcqOMqM03IwU5)aPK4PJd6qWQwm4nBogmbSIB4iYioTHVzd8F1XgQX(G8k(FmeniHBwIaoGuJ4VakVqa826K78ry329SDPTArakg8qX6gTC5RBekAtFw((OTVSXGMZq0amr7NrsNGnLSOoLOz6IyDSmdWTX5gwavoKQulTP0Kr4K57FstM4k2q)cmHm1rOmNy0cu3JmMuUvSEgW0QnIoXkLrXpHyK66Yo166BwoxlX8ugCs4r(v1taqlldflcQSbjcWsxs8VZSP4yTeZj4G7K3TdOuEiOqCikOwyw4l6hv3GkAYWU0xYSPXBnMBE1HeViF02CZRCU5q9u4evMu58RJbXrQgvHSwQ8ArkPiE5nFNIswfvALnauOEeFouF7(UvnsCazEYGlyJddyOkXWX3wacUjhZ9drtkcrbFLhwCF8uVSjO1gGgKzHXlqdnjfFDl)7crWw5EYEiEStoKHSOm4FFuNtkyz66slOy1WgKQUUYh1Aw58CSY59ITYzDKkw5QL8ytfDd3i2TtywNS5jHrzOCSyweyYu6ctlQUuAVcPyuUcV8gcCClNaPKZ95QBi7JKZgURjOFs0V9rVACxi5jcSNCZPkMZfnNVhomh56sW2N1z5n)OphhcJZbZ0jJPMLeGUod4k3B8Iu0xjOzYD7CYxBZ5MNcQsOoDlymk2UsF3GFwbuYzgmqxHOG1rj72KfriUZKUcdn)ltR1LJqi66l)mK0HMRhWe)jmeVdnif6bV3(QJbzApEIaFLDM3hITnjv(VIXJpGS2YTQsAUUzLLB(M5hVWpYMXvRblJNtwgB78khstZXwJHK4stxm6HHG97rZhMDlr1muDbTbKLbNNf5chc0D)0yGNDy4yb0RqpyFDC0IaMn7RwdSZRbyN3AJDEQyxflLwtjGs2rvzG7GBFRrbMBzK4mBvsqxPq0d1Aa23HLFSnDaL9ODXC)bMAvlUslTGq8TgTP))ZQGvwvvEOwdAmwzAuLBSQRcwPlwVBbNLNvRwxnhz3ohv1LoAYX)m52VUfw6lAl)WaW8jCgit7QpDXN(bqy0IO8W5rve5rJYi84XD70JIWc0WmUFmMrXAjaJSajb7YZ)a22WOanXdPDhId4qC8O5QnZKba7A2kHd6M6u2CcodrR9lCQZGJD6tacX4(baL(Jo1aMl3cScKYl5H3fnCXCqXg9b8874C8Djx2Hog7hiN5pd1IGNNhBZXzSXOdZzZG(hf(fMqvw29mqRY8eu3hr6cZ3fvFYsFGmCI0meICozaknXpLgGFuIteMWPTGS2yYlXWiLehKXvqoInLoCnoHgHhyHRVd9mg5g3U2SvFDjWzkonBaaXNlc8GR44SPn4LIUeomndKHgb7P8d8NZDVLMhYLUvnKheWzYp62fH4OAARP44G36dskybdtshrh4lHoLCjOC1aeKM2NvzIudkw8jcsMQT1KMVAGfrHlB4eYrQ0XBXnnwCr7QL1yU)IIjgV1iNp5AH3noh09JgJ9LW4aFry0q7wUhdg1NMJSiClxqMeK1DcXKJCceRJVWWTPrjJWqhkd5vAUSJ(yq1ymuutTsgSCwCLLovpCAmX2(yz5IMTthSyEDEtwXfz6Oj04aokHlaV)c5ihNGION6NkDRojoYFcdTnTWu7zjJ4UM7IFzaxSbV14MwouP9QQo2mgHloBVpjfBu2yaDbZmqhM(aQNG8enha6U2EAsPqTOKyYj)x85mKL4IbOdTHfTWFN2pdQH(umYaX1pHWryIVWZYstHJOV3Zl71CdKzXuusz0)mqODcDyJucAVJY03iIX8QdXUKNmmiKX9ODpVv7p7JS5Wa5cgOcL8oeiRcgEJfT)jgkoOfIJPqN(M8ynPVaixtNMM0mx2B6WSnlsuwDDloiTTDmCT5Y7PvaDFMEaTnGhghA5odpUZHJI8)DIfa25LIlojlYZiFrGCApzUG3UEmbYvQQ(vUKUVNAC6uO)A0VcB9mCMnz8zXhnLmzgfqFz84lbEB5ImT8Zd0grj1ImAXiOADvzCafe9HCAEt6PRyFxGoU2082gSNHm)TIxUn1uAHdRIFS))nmz2O168gU482ZUJMkJ3BT8FTEPzSEwyG4HuWvqJcyWuwgCflCvxCoFjpwgrwKjH0Jt)s6IyE(5eodSvL4jaGKNUGap)4aFC3zOJCYwmt4emuqooR5g3IdqmNbev7IWNRHUeKsdlivLc7hGZNfhi4JlpdgYxjDSK8ifZ4mP4NbvYiKlnobpJapAXYnbsCq5OfKLD)3ggvwLP0MVCAMPuCBuWWzZpDaIvbjSS4DH)rcym(Ki0YWlpFFoTHIb7DHtPn1uF522uztdSBd2gIh(ondowaMsuexILpoZ)RdfnWqUB6y)y2qA4kSCEvbERuPhzXD5sy5Yg8jEgwM5YOEtF7iB18hsnTYJNEyrjtdl853DjyQKfHkmqXA8wC8vVU8pqIwprcgmpY)bE4OpxYFZaWWOZQZfOnI7sxUZxZ4z8MnqrBm0HxgAoh3BMJsqK7s5OOduAbhHRFEHfPZyC)pOml4tWUNSupl3o3SfaJjHdbm(aWTfYY5SuOvQhu0I5tOuOJleUk6(yE(1nCeLEDQqyhR8AcRZKFmmf9H9yEda6HuzQyq2PbJZE1nuc(5AhRYHJAM(ij2xqzm1jQTvGxC68WW4jGk4eneJt67egpS84NYHS2yW2eMCUCaD(8Ft(7)k87IKABo1rK30KJGY7wAjEFoto2ijZSl2mLMc7Nmmh8jrseKvtMoUj7TwJ1gRSTw9OMvxayty2p)bjfboS(C(j1WgJw2m5hm32dCFXWYW(f)lPmJ91Dy1XO1reskOQcF3atHcN3i7AhNwElgdl5gN8l1LDshR0ElUoQ00wQfIzpNsLzUx26gDXpsQEe)BuFdzDqxRUHR6PbH15jcEZtUsiqMbQfLoI6l3IXniI9v6uLaNfyaeLf(RuVTktPHE6HIFMhVoljxkEAYtkzICJe28BN2K8)jb9dEGqSFqygg0SPPu2rl2YlssAaiWwGWyYZ4yRstxmpFigYdXDka93(4OW546uRQt4w5HWU5Z671AVu)WGHS7qEOzGHgON5GnMN594Ju3Ufn(a6byrjd4lEyinWMdLYNWbCVQJ4Jpkx2dytchhMFA)UT3i0qBTeAlTzRG7v2qf7BviKwDJ5gS)Vyhn3FwX(Zrbz79f2x(T2umzhlmFeKeJSU)Vlchtb8eyPqB2fc9YS55wbW0eyASr2QRt1q4pahMAejwCcCYmwA5S0)3xKIoSon8lchDkJSRnVDQb0FJ7Ppk(MWulveK4j0D5GMUX4MZ7ipyZ1UOz3(Im(bfY5BIpTV3vfjDn5ho(zdrvm8EZTfU7BZ4Y)IyteD9IpdA6UiHmwIp88MEw)Ex1PWX02ce7M4WOZ4AFunIWcShIZBfHHoDyuRMLfPM4xXz8EnjV(vYO2TYSAeLqjYRqQB8ur916D2AcjAVNTf3gH3U6uAft81JuodKLvKA8(SGXeKXbwpNR(3nzvCVN8Qqnws0t3yXV9xMARyKSreJlthfJ4YxmQfJK1WBxMqh9PaO6ig4Iy2lrf7XyNNtegCvUd7mUuyWZPnhSgiBKQ8MJK0JADnP3rnXptTnpaIfpvTsQMzoODLsAbjv7qggqzQdQosMP0bc)tSV0nCOFo43waY(dHwkmX1WFZm116uxqveiG3FULBlTLRBDB56UrB58C0OUnzlN3k2Yvj)tw1woRz0Y3GB58OTCAkw8QnAvnqz0QYBO9AG4v7lscy0ERtcRtmSLuPpHIdqsSWHxKTBfcPK5IifuxeJLw3rYTs4(sd7wXmF5nFs4gHcFTTAOX9FMgCSfcU6eHvlr2yHY1MYAxSFzwOkYHWQ8X5uCJQ5MOQDNkCEnuTiTvij325G9wHlC6kNjYqUcMmJNQP4yxAt6vjTFBEzwn1(AClRvUyO(ZbgtqscDS8Y7e6s(Dp(q(mR(BiQgP30FoU8nwRMq1CSU0BfRlEB71LT2vrLwzA8Tr1nHD1tmlyNdoDexl9ZyjvRMlP6EVaRRUxp6VfViSvwqQ9UW6uiJ4IWMLVsNoG3)Z3nMBgXpZtEkEgcIjfolltpTbNYVq(OnWOTL78Y6Bq7oXIe1)Mg6IqtzgLyNlGFQY(xcDkDbg6AUeW6nWsvTBgg1cd68FxatGkJ(AeiRxrrKoBEykAEOWdKIqPgZq2YmkBkZVN5ZVzOC4N1jl)19pKNyKuV3pCsF7O)P9AvODLJ3cgWZ63R1o6tNvSXNh1qdMN5uSrNugfs03CaFY7g8UFPYzAkC9gFWCXuxYEymAFMf5)vKUOwejUmMCu2Nz)RfaOXPnYYo2pMh9CweQsNU7Y(0Dn62qmF0aJfimFrCaJ8Rw6mQ8IuuaxGT8NhLKeeTapGhCKLFHN0YFmEYImObh(Ruc0Ihwe(V57CNY8tBVfsWJnpxYwXHQOJV1QjhCdRrjczNpXStZPzJ1LDAxHjMgpnJXkBJTO(IAd4(YK0hugWSIwC55FyFHzX3hwKUBxoOtJpS9Enu9ZQvW0wNUVItUBSSiArTgQDSQQQvaOv7dHvpHATk6cEa9vMxvCZahjYzpHiqyVgvIc8tbEF0XkIRla)(kvKqNbC3tFlLLjZd5ma8TRlM3XeivYjlkmS6PKsNTWE3NHKZkdojYOK4fzWUqwAVJgE88XkhpF7NAG48q30R6YmqPPrRzoCrcpW(nskMv3Z8CWfke360R9LHoDVc4TUjfwnWv1pi1TRsNCrQHhEBsA4VNuntxRDkSnZlnEInAMxA6BapVm2Nix7vEFpiZ8lmMi870Ek2uFm6AzlMppjnVzmT7GYV)3c(2iyREoUXC48eWOaSoJ1uMMDCZR2UuK9AUXO1gZh)mYeTzzD3v3MIzv3a6UlWtGU9lIRiA25y)5shM)okj4wEZVszbNnFK8CLQDo2LBQzSrBXBVY82Rsse)NA9(tTE1P17Lq722uGHJcSI(MGb)PAN)JtTZAW8uFAY4xKt5IIEk)UNsNXhR)qO0QYSG2pwezK)gD104zYo)QdZfpXRzeKCm8kRjVxytcfU6kul35rjtJR)K2LSQ3dOQLCqYc)HLZ31GJ9veI0x7C15vciOFE7sFQ5e8hSQy0IlTR)GAnfr1jP29kX3uu1Ms4C5GLZ2ysNlx0vt21j8shXNZ1x3LRT2J2uKTS4kzG2OXtOTm(Uk2xdZLwO5HUuPjP4vD0w7gZPyV2b1zTxB1QhNIml9m3Z9T3(pwe2zscUr5mPyvTivjfEETiR1f2xZ1OcY7K3eedQHA6lRyNX6MdYQ6LS3x3ePvAdpxdJrcUkcHI1C1us(SKI)cYw1e2xKi92YC)LfLyrPL3yKLnVzi4MhVRujWRoMuPUtIFQRwZe)(8XVL9qNXPi1EQ)lOS9uEUJlXKlMkHZO2WIBG2eYkEH)YXejMtU4zha)ehT4hbP4w1qhL49rOBwfDVoOPC)VcNHM4rLo0rlYjhWd2d6NpBP4YSfM9dA3b8cU(w4T6QJYp4lVOx0QfpFkgtOurHnQ2PW1ot97D2dLqF633YTJGAPVGCAFVw7yZE0hFuVHN51U1ANz57SNDRaBjSJR8agTF8rhhRv5dvMmTxNSgV5jVEXeWYKBnMsRdY1GtvwtOf9uodvds)9AR9NQ78A6jFivm23K2tUBQJX(o9TTX61mw3B8WGlIxWjQyFzC()Z8qBcOpjPq)7ZELMZR0Cg5T0a2SdVU94pn9o1QIX7psfWdoFGi90uDGekQ1xwaqUpmgwSZ2wb9NcyVR7OQ77vnDBMUa(Cz5GGRBgZ0OyU3O8dcYK(WIx0IKxLIW8DLj5R48K0Blrzag5QUrT0F8IonBQAvpTIhbuwDreJVYIPSJqpFPRfsIF4Rd5ciSL0qUa0Bos1QdxaH8EPN5HVBYeuay5fkhwelVI6Qg1SZQw21yDvwHreZ8uJAl6)nmhX0ly7lPRd8hmUGo15(OItssGXsmpLua9wyyDSZPMkPAfvqkRKAnxLWlY9iDzdosy5fUYWBW7JP4G8WGLka4Na8JLxT3MW4l4j52aRCRGtzbANeM9v24f5mt)v66IeBz)uFXTC0R2laOYL2IRbuQfZXXYOuOcV1r4hlEWGq)pqHeptCjc46qfaDxw2UOGdkBucKPWJ)I8eXvjq8c20z5p9Z07Zsx8ffkjggg6Z7kJVqUA1Yr(47y9Js(gOr719RT)3Ai79Sb5EV0qwlVimaS1CMOeUl)jlmwz5RhJ1jBD0Qw4wjxrmPLUYLKVrG)tMU8g7WTuMObqRgbIgcXc)CAaWk()SHWtluMvPQvdZPjC)RB9zUdiUXZ836aEkrd2eKwcuCdH6tME(9BD6PdiUX0ZUhT1rrxGCZXrhAP2Ca6q50MdqhBit1CkObutT6Xqtq75GAQy5VbCTCMGxgG6yzY2rjmGEDN2OYW4CXtXq(klGwogqtbCv77nGU7daSB9gcu8UGS7Azpqf8uCbS43ysHJQfvr(cuv)AvwPr1B726paYYy9ga6zyoyN(qDyEzt2Ua)jG1W3Ye1wO6WC9MT9hKNWmGY996WDzd2Ma(jGV4PwRdDfFFlcwxiBLZni6Mxt2V4OrB7b4jG7U2ZyTjBxG)eW662R4SzB)b5jmdSVVXsd2Ma(jGVw35u97BrW6czp2528kx5ElB1T1MNvW)Sb4)GW7K5mElY4HSAxxx)7w7vh8)UVR8Nkp1H8R9psjKNw((39D1b7(h1wof3qK7jHBRc1kOSv8XrX(JvVKzVnACeBBW)Sb4)GW7vZj7vHzXc83ACYwGDDCYnd5Es42QqTckBLJixi8X(tbLfjqoBOgVrfxovWB0WbQMgQnqv8AK6mY8TCY(0XsRA(q48PGY(yvxZ1g0k(ysLaUY5LRw18HO5ZRv2CTbTQJPEIsnEUHFtGmMSGD8JFyyW8S6GUR210zqthhuGZWna(n(Gm1FsPTXi4YQsNWEtTF65g(nbYnBD1D7A6mOPJZMX)SgEMAd5FwJrOP8pvmUyhNMI6sZ(Jp6wNF9k9DTLT9R2RBNtETJTeWxTmG4Rrx72NTx9gm7Ar2Ce7UYrSRyeL0)xq62HV40TdFgOBLSKvos4w0N31pefzPMbKltW61mylBoaDeKYnaGKt(NKefLCp)klbRvy2PXW8rJxPjlUOs8Cvzj9qNrjTPSDu5Xyc)EFw26GaSXb(5(J8Zy)WYFIF)usdZDeDb)e0hpRrCfCSqTfsSchrQ)jeKrhqCJJG32pM)pprQ2vWvlFzdmaA1NRIMcsTBSGbuT(6s8hoG3cHB1vSM3gG2r8ffx4bdyA8mfubyo2aiRmtMIRnQv6LGZQOdHcJ1mb4CfCf9IN8U2n6w5ZAtu3aTqtPideTayln5ze4ReSn3k4gzT9tFyQ1yB3GFZonYZm4Dd4NSOCxbPOB9m2v(Cdb6k59S2KNrGVsW2C3d0ig7N(WulJTBWVAoVg4gOTn4Dd4NmJTRacTzY)Ewb(QSs9jqfCfmHnBZYZkWxL9VBevWQjatgT7AP83vMKF3wkzFDLp5)7c8DL16pZW)jNm0pF49YF6Jehhc23QFCyKT66bGW(jH4Zfo)tzDkYxUx3)Wr4T)cHo(oPFlErytI)D2YFYwBLoczF8(20xS)s6JO9PNeI(66019Z3JpA5RIexX63URmTqS(DkbmS(f(55B(KWZ6KWMZUlhUQzFJ1VzDsyMfjw)cFs8xWRU3y6gjD)THujBL3uoNc(kBu9n2yFS8hWMW410IzHXlW6XkDTe7w(3caLToukUZV2pzE)mwE4ebfRl))DilkJ1)OoNSFrHJT)QZlGNXCwWEEbSoZxVN88Ts0JFgJST9OhtmrxkE9wW76PYs)n0ez5nJEGU3NZbSN)K5YkRAlllFD6f9BF89IdFTec49K)cYjgrLMJZ8L0dWL81vOZYB(rFoouSNcV6zbHtcr219eLvn8Q21TZjFTnNnFAO4H9NEnAsr4jFBnWpRak5mdgiU(yBJI6d4lxfCa)YrQ06Yrq(8(MXVZRbmXFcdX7i3sI3pwXKQCmkkVc(lvFxDORsEQ8FroPe5WK7HL0Cu2DZ5sLVGgvKcBpe8RdO9SdAxr3FDaDXdgJn02m23QY5RlC1Rdc45abSg8Dvz0BleqYJzkFXtv(sxfPlptXOPUqB544IgXnXMUYggUM6IYLdNWym42S2OUi3qce)m98A0TOmQiE2bK3Wx(LV9QpDXNat3MTikpCEufzhD7CKiMdD70twf1eXHKxqjaSwik4YZ)a22WOGgTjrTkyj1605OxP(0iGZIFv0jXGWFwcrrIIhT8BbkljrxwSyenCXCyCPpGxTzeFFxYL8xp9pqp6NZqrRmXtM(XzSXyXyGndlxhHFHjKVNDpde1opjx)vr4oQwWdGNexgI6aYauAcw2tHb4hL4KsH3GxnmFJSkNNX1AmInLUu04eAeJxxc8XcgswZKpA(c7VFaBIpSe1)yChhSCXY3YuXbxT(iwwEbE1TNcIzfmS0aF4ahSzJs9hZWx6aPZPRelXwYtOu8CeyfKySodZzZ4yw2T(WwrwWWK0r0PcG(baXExlGScESIrt9s4J9ANQDROJqZ)xlW9Kk)WcW2N7yrcdJPQ76CujkN4VSSYW6JSv(JOIGeUuIfMJdq2TSC(7Fqe7oQqVWFn(NZIz8L(I3p07PpFXNp4SpC(bNnyWbNLMiEFKvqiy0H)fovibqk2NTyER92Pq2w1NFUkvYL(ETF8rS4I2sR2qEAVtm4s5fbkgkwGBshNJfRrN6L2gS86GgODFsk)jZGtoW9UZ8)A4Sf0dLFoSnwgHu1EpoyzrL(kvREtfof2Bta89iNpBYeYMj5teOYUZkS(gfsuHSnB23kRjcnguWwhywzcr71CWd8ELSU59eHVLIb5bfG(V8xWcibwZCanaFfXe8D1W4XZituivUL9WUex7D(Hr8vAqJhrMvwwiywIYHe0hYeaNudYrF9YgLdou(JEs1km1owNFAFWYdQOcP0SUIOz5tgXqJVWB3Z4t5irXLrWKXJ7pwTskFyS4QMXxZKBzuDCcv1kAp)PKb2sZI049sxexfjMmAFSOwmgK3IuLYHuDU2mme22uPcwVLWswMlSuNJELacv8PcjdPoEReazuYraKJ39Pl1DX0)f9yjbhpafPcsyc8XQlhdjlXyPoF5nFAokAHF4MmQWNllSqOGdshRV4SDtJsgH7o4pY1CnV8oIpI1PmCl05LAvGP1Qv4Z3REmH9p3OIX(bKuBtSgUnbWMbmzvIIxj4LdawYf5pp1CCIBOL)egYHvCY6zjJYi9zx8ld4geXBnAPchQKAnvr2XubCkIugGnclLmaXlbvf8WiPspoa01IonP0Cnz5a(IpNTfku6R3t7Jjbxr0mz)Hz5w(S(98SRq9iAj4Fw8k4q(yG8PgPzLSRfM8tNMMyoO6fIwx6913JDA)EVU3RKo1vlzFE8rxsA5htHxzI0fdEaXtoDAHBgOQA9HvQU9f1YiKF4jVwTwf1EtQMDTbGGyG(T3ovcVIYPwnucFwXhm3RdusbCkYtP2TulGIA1(7tlGJ6jTKfwrB18B79qua70w(HH1gZ4BDWlQUqxrzY)VzT21ELYLn1L)9QXGq3SaTEUxTFcRSxO(SDvuhyrDa8xMTfXX0cQSkoGoASSmoqmcFC3zOJgZwmt4KwuwfIB8JGIdGwTzxQsPeKsfEKSDHETYsdVQRnW1wPJpLNUx8y8HFg0HqVq4fknlQb9gfqnTt5tAJ)VRigVSU2rNiSkpIIct8yC8t7GJyqclR41tzseAYXLNVVsvFMsdq0RcyFfkAxTABcdSuBMp1YhkQlZkYFusbrdH4INfq56qjTh(KOKuBIFkNmga1VqfQzrjtLV8QKCI07Mc1IJV61L)boX7joCCX7bhwJM58FY3c5lpNVPFepKalKv9zSqZzdu6VaDe8Yq7d4EdNxwHVuok6avuEHHVLxyId94ocBRuMf8jy3twwP6sR3IurrRwwRQ5QFnPKyrUwXtfL0nt91N1)yqeKOzAjtP48sMf8BXpBPe9bNOVq)MoK2ZoOa2iNWcbgp2GvRd2N1V7jTlX6uTSPSL9sVTWvOv4P4BD0zR(n5V)RWVlEIIRw1WRwSW3VSsHk5DCTQQ0uK91XQ36ndbkI(AB)ETwbjScVGYEySerYrFrvDhKVrL1DeT)bZTeI0pvTaDZ3pTVUFppg1UsJMGeiCMhqdl8MNSRDmPlMEuRGDtmMcluklS9wMHI2y5(iGwZqFRsvS31wbXpCQS(0dcipOBP92aLEIGx4KReYByOKBJPLUBjD(i26qJrRvxnDRuWL5Ez7)jb9qrG0DykLl4Ykvn5H8bxvrrMsJ3NQlYWbU1lGY9Dx)K3ZMTrgf5)t73T9guvL3xTAu3)zRArtRfqlaaA8jR7G0Rr9YKREVVW(YV1M)(nimEae8GCo)VlchtHJfwjxw(i7wrHP5gcPdYfdqlJTdeUPuluP6JRjmvlfQcNHyyQU(Z2o6M5L4J3Eu4yHpBXZYt2oQg7cg60fD)5SF5dxTn)1aSaV2XjjnxeLgIIV05QroQYQT0W6(DvBMTJ2yQPS)jLM9OJoTmfY8MhFSzn8TTBm9XZg9X71EUoRTlkKxNMsGmiLngt7zdtRZRa2sVm3tG(4lUEZMcgZ1gpdowW3R6lcDMEGDpnzoCSPCn(DmRgGZqEiFgPY9pzKW(wP5)MS(wKjwTo5BrhF3w74kf6kSHA7TrPDZMrECTZ2nuPLl8TY8TNL5R3MnF3y2(goJ7PAVw1z2kxCpRpApMJTc7TviKB)nunK2i3o93sPGVnabqM86nsBEsd5U9XOkUxaDQINJBzNXs9JqlztGZqoRAdmcASyGXOL(UXCtl)5qkKf8W3JPXey3HEm9H9XC3mmIHguTt5OKvniYphwR5WiK3qZL)U4xGzcAIgG6xr5Vr28Wu0L3cd3eoWiMvMm253Z85HgvB(Wdmp1BeNTp4N2R898GBPtbprpH1XLgaPbE6N3hjAjtMmC64aU4ohdJxfG9xigg0SPsVdiFXRE3G39lgdNwC65uA5vztaTpZI8)ksvktIuWcN4Cmro(mp)1rSbzkg7hZ9yflcDqgflDFkXu5pYkyKirmBrCaY9gddRp9QsisIjaf37C5txd9OYzeo0d)vk)rWu9dFFPqDua7NFA7TGJn30aoqKr94nuxaGp9yNV0lf6AoQ16hXIRWGvWtrg81E0MByqPK8dutYjlpsDrlU88pGhZe95Z9HfHa5YbDmMUnlsh7TNd5Zovi1A1HwU6RJJtv2h3w1BXv7O7az7urHT5JWvj)h(l0VbhsDr1X2t3tRTrOEYYThPN1mups3IO8iAj(PkjdHJy8i6FZJEGv40wnjHQW(QC6k1sLU0jHp9WoTbV49RbtG1xWQxaUGAEnHDT04iryA)TzmL28NsEJvplr)Gtc3oH)qJ7wxaSdw722CUYFkQTUGQ(h0MSgVNyne1UnfRU(7Q2G3H91yz6pfgU61s3lB2xX(J9Xp3yXhFiU3hSoV2JgO4r6ILkBEcXLbVIul91wjFVI6LL3kBxG7G6q1Z6VEdYkjh2pk0Zkfz1tC7i1zR7uV8i5BNhwCdIPzqnwd6Jn95fQTpWLY(2Y8JUA8s0qm1iJ8YIyQ08Iyj1SN97MqClNXcDsnncOsXNvBVRPuTgw1ULrqapRVN6u)z7P72GijJ)E9UDnvpQ8utTeQ9(EhvXxV8z1F(yCxZuWWFupP4n)I)WtRhf6V1EsKxJP8Z9ZhUtB6BiaQSpQXgZ(n7tR9wLZVw(GgsJ)gNBU5ZcxNlPHqG412G3e76IqXMfHOYum6f6TU2KNCLPXAvnEWr0Q(evFw)UG2r555uEZ4qpDBR5V5OwwAC71h)eqX2djxRDw1dvnpAM1)St3OtltHTu7qbkV7CcBUmFWPf)StKto1SClzDLVXp93e6vyLPLbwgqAhpp0NP(0ql2iAlprny0631mhN4ILTkA1sMo9B8RmfvThW4s)a)mltcZUvaRyCt2D0Pz4wCQLO5lY4MLMZ3mcs(UQiXrOB6eFFjsD59MNG3DFBg301i2erxj)Wj8YjF45n9S(9uV41YBzyLatBPIv4kUwM7v7jnR3cmgIt9o1gSPAVhWMJVy5(1h)Q9CgAl5HO6lon0R8A)69QnMKkTS9P97(w7x2yWYCHhMzlvlCju6(J)gvcwqgE5T9nqKy)7lfQIYp55Xaf6FHWFSufH)MzXkAfRBzrj5YRnAxNbHCJi8wY13EUtjKN7vd0v56Ltdz)vl9ifWuahl13dzvfPFxRf)drnpPDlBfteEXErWySIQWXz914CuRqlL3EhrBpfvsTNt3A6DKTRbuBzoYBiJSMzC7MZm59FkmtDDWmvTYiwhP1ZYh7whZKNDMjh1tgNmtwQnnVqmtECxm)Xjfg1IrrdvdrQUkKnkRTvuMtHdHu5gjUu4WzSBftKL38jHbLf39MvdnUNb0HtJz2jjNUREq2QeqfRe2wAPU1EdweCl0P5tgp7tMkvAnBm4oPbBNjJKP)6b(lYVnj96bdcN9(RZH)VR))(]] )