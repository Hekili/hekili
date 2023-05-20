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


spec:RegisterPack( "Devastation", 20230514, [[Hekili:T33FZTnosI(zX1RgfPeBzlA7mzYlYxfh7CtMAFBMk27m1(pwMscsMxOi1sszhpLl9z)1)aGeeeGIsw2ZS3MQUB2yrGgan6FHUB04QExD5vxm2ptC1F37aVdp44Eh19Gd69tEV5QlYUFU4QlM7p6R(tH)rK)m4)EM4w)0m)SG4i8B3hg7pgHrA8IKrW3VjlBE6B3F)Pbz3Syy3rXZ2pny2IqQhJs8NKH)9O9hggpC)Xj(tJJMegm9MS9frtdIe7pk0pnDWS4XlcfP77ppe))hiUn(RIKUJMp)QlgUiim7trxn0(m)hHjZCXOR(79o61W)(MGXJfCJfPJU6cSX7DWX717O3U86ViUnivS86x0V)lwEDwm(VG)XK4KLxpkokninten6(Ul)LL)sEh9Go(jyTiMjIY8dxE9fbZ(WYRxmhNnlVU94K45PaKsZgepxejsaiopjioji7(oLa1bVba1flgci0OSaeuJUXpAQiLNlmCb0gav)P(brL7mUaQzMaaP9f34NLjscIMcFlZpz3Lx)XGeaCNMi8ZUb(ZZHphbtmCEKmva)YVEFc()83cUL62hdH9D9P9r7D4b0i)pOHzmGUsINPgBc117GU9k1JdowRhL7WOqHFenslMV863)5ZlqwWQE51ddY0a1Hmod25IxKbKlfO9CykP1(asRT86eXKag846cAEkqmdag(04GjtejaMdW2(WApd3ZxeLbio)iyzb7kJ(k8hXtwE9hUbBb8JNcKN6tipMqcM5azg89Zis6eAqEFuWS4uAH8R(JhtZcG6yWC(p6adHidwft7E1fHaPwkYijW)7FN4lfr(ddfJV60RUWFeZXjKBxdsXDl4VNnp(orYGSySpxmcqBW2Tp3HBfdaYVzbiPW76dBllV(v4AnewZDvqkDq6C)OUYXA51p8aGZxmzs3X5RKUabgq9Hqbas3F84Lx)syUpxego4gaDal1w10Pt4H2Sl2giKeaavByhWy(dW4yUp7SYLqRQDhNdVM7)M153S86oSiKKG58ErvwNfOSKe)OVU8AyJhON8NppmyeczMJMPZs7Evgi1QHBX1VN6r7PEe69rUZ61Dt2yTqouMS0dxShUvwShsl2dB6ITGszsCeimEYGz(tdg1umcoGD92aCIfezzuYHik5OgIs074rqhZqYWj(lcZYfuO66)AbmG6avrMPAWcy2ERWSjU2CMhZ)VLO6pte6dK8W3wEDqeq7Fj8)csiVpEbqVJIy9hcYMLAWUy517XmdH3JcJdbZhqbUKAcw74YRV7gb2pcc3rF(SVS3jF809o5Il27KKyL5gfehULBSdkepoCC8DrDtZ1(naKLNqTc3YTXFdCqDKeeXPPe0MGMLmqNd5WJTTXfd2KacYlWB36dts4R4)kCbsvRMrvPymWU)MSRa67guhLaHaRmhWsa6os8nu1LMwMa4BdbK7DXjFLuXWy)BGpnZ)BG(qqT4qr2DcS70pR37rJLA7aSpSvij2sbHzbtJIzlh(WzFb(cOSCeoJsZcMHZOU0cDaBwioTguaxenDSf0emHAcAQmlqbZ1EkjDthnUlbRANbVEZNbtaRKgmKmsQ0W3Sb(hDWqnYhKhW)XauHpR2xcNmaz)vq5acG3yaa3Ifpbqja5h05rzKjaQXkzrKZHYpMMM)KJPzDDnnJfbnpra22p0VQqiaAPPiphiVfi3aSyC0FiSjvAT4HKONUz96csuhaQAhGsbK60Fw)O(UVSjd6rFj1M401yT5v3K4z5J2wBEfRnhY(cMOtJQwFDnqokz0AO1cjJlsiP8lV(h0KGRjVSObG06d41q9T7hw1iXaY0SUZeJcglq5TbJUjheS(S5(bO(k4ST6w6VlEKfXeuvgiEAwq0c0kbsQAVI)oN)2k1t69rJCsHmqeMc)7d6ECojtpxIyL7g2Gu19vEuRzNZZXoN3Z2oN1rkFNRw0Jn5)nKrSx3G0UPZJdctr5yrIqqFCYct11NRugshvvTdV8AcCSAzqk5CFwpkP8vTA4Zvs)KSF7Ihj92a6yKypzD15R58MZ8Wbzivxm2(0UlV(N955qqugydiPPEwmCc3aKQS9Ofj4bDrBW6194V1HPMNcAsOoDdyPd2UIdEJFwduQvgmqxItbRJs6nXlcX5Uq5hd02I0sTUyecq)w4NIOo0wWXc5FcdX7rRDGEW92xFmi7grZn914mVlaBBCI6FfH2MIK2kwvfoVSnlfmFZ8Jw4hAtZ9AqY45KKXgNxXqAQRFngsIknzXW7haghgoFq6newZq1f0gqwgCyeKkCaG39tIaA2bbJKqVc(q8TrHlgB1gH1y251GzN3Ap780ND9o4XjburoQldChK9TgfyULrIRSvjbDLcr3VudW(oO4JDiRFBtCXSZCsSQfxRLwMqmRrh6)7KkZkRQk3VudA8SY0Ok3ZQEAZQYI17LtzrEsONPRXwnfzVUhu984LKJ)fYNn9Yp)JSTGKdF0noGqEqM2LF(Sp)wqyeCY7G5Hve5rJYq8Sx96EiEw3uOHP8HKNfJhWDm6wysc25N(rSTbHJljEiP3aCahGJhTwTzMmayxRwfCqFmMiMtWzaASFUhdU4iNh4KMy8HmrP)4jMH1YnaPaP8sDYqzdxmhuSrFapCiUgFF85DPZi9rYtSZqTi4HfX2CuQye6TtXmO)HbFvivLLcNkndKzI6(iuxq2lq1NIK7jdNindbiLtkmLM4NqdWpRMt0mHXTGS2iYfFWifhnoLvqoumLo5gUGgIhyH13fchXN8bxpB2QVUi4unpYCbaXNke8fxYZztBWLhm7gFGNvmEqCYq6OxXjyubkwhUAacstdjlKgQCGgCE4uShkNNva38prqY0MRsYvxnWcPOomycg0b(GMi5RfhIVAUEtkDk0cCRrAWuKM79JYaTWOzrFniASVmAeOfe3H(0)ZZXnl2gcC7cjIMqKB4EcTj6lnHAAy8qmcmQihKKP6OpgBcHaz6RLhTgxcB4ilJf22FwwSPzZo9fZRZPHAEcP80eA8yEkHBaF4m1ihfJclN6NmMNSSGb)jc0kXCJENfpK9aZz)6fmdm3AK9HHkX1O7)QieU4Q9U4eSrPJGPlOWh9l29OeBYHJmak7bZPXfIxcJbdztWHifjjo7c0VLWMwWFqA)afcFocjGynfiCKgBlDGOYO0q67h6L(k2uvrefSjb9phl1tGUorjl7WdslZiIHoOlrUKfpyCGGDC5HER2TLhuN)MbLzKFAshbCNMhW5FGr0aAH8ad05GjhtssUXWsonjUzEM10ZvBMd9T6HoCq6y7aXLwlFG2b0J)jrqbSbtNMF2Iu8Gh7pm0)pisaGZlb3CIxKLsEfaP0E0ubVz9icC7(Wc8EB9WDOH)lH)YT6YWNLKzG5F0uYKzWu8vH1Sa4DuBY02phVcctwkat5JGUDofHtrI0hW48M0txHqmF64IP5nCFTXQq2FQ5WZjdT5kblewgHd8)frBzdfxMKWfbxB7E6PiAz1s2165MEABs3isRlsaJfWkLLEzLy6St5D6ivy2qAdsRn9ljlI4KAiygyJirkaajlzbbE2m8p9IzOdusxmt68juSnUyzJkXbiIP7qLSi8z9XfGuzgbPyuATaCUOOXsY3IZ(GKtkh6OmLFgtBIFguaJqUWue02CoeGkAF1CqZKEYoU)ldtiRslAZhknZWj2IemgLSv54SACSin6fW)igoeYKq0oWZpDxg3qbw72GPeVm1x2sMk8katgW9Hh6njnRlLhjevILpoZ)BdKnWqkBYi)iXaA4YTt2IdzCOIJSVUylSyBd(eNRwPUmH30NkQwn)(etB64CQjmEAqUV2UngZ)Mqu9aknJBXrx(QI)arAhkJA88q)75ymEQI(waGrqNrMLJnKDLk70ZuonHSbkIXOm8srJ3yViomgNCNRgLYaL2Wr46NLB)5mbFUFTvbVa7D8YYPg0PMTaimP5WybpaSLpwovLgUkxSPDJLqHphLltv29rCsjnyiLts6qyhR0AsBXuFmib9D8iUba(qP6uoi70GXPDDdLKEU2XQy4OMvEKK8fuAMCSEBLZlgppiiAcO5nU0eJr9DdIguCyt1qA1lsRdrolhOmD(VR(9Fd(DzManN6isBAsrG0X8w8Umro2ifXSlYmTMc8tgg)9Oqjs0QjrhBGER1yVXkzRvpzz9a)2eM93(OcJahnFoFUmSXObntERjBpq9fbBd7M)VuYm2TSJIocnkIMKsSkC6NKq6enJ9NNjDSj31UoTZwogwsOi1xQlLtosR9YHFqXORzil1c5QNXuPM8Ywz0L)iP6r(Vr9nK1b9S6(RQN9d2NNiPnp(sPazbOwu52PVEd6V(qX3OZqcuwGbqu(8Us926eLg6Phi)zoozwYip8SJhxqe5EsyZFzLwK)Zy0)ZJLI9hhKIbRAAcLsPswEzMLcabybcIipsJTkjzX8SbyOgKzNm6N7rHbZX9PwvxWTYcaU5t671QDIFW4bIBrAOzGHgOF4agZt8E4bQB3GgFa9aSOua0f3pGgyZHs7t4a2U6i(WdQT9XIjbJcYEx)ED2OPrP9sOTeZwo1RQHA23QHiT6HXnG)pNJM9EvK)Cuqw7Vk(6V3HIf6iP5JGKyK09)zrWikqJajfAZUuOxQffXkGvsGPbJSv3BwAc)r4mudjXItGdKjskwL()XIe0rXjbFv6wtvevT5BZsa93z)6rXvewAjYGZoji9g5YnczoVL8CmRDPKD7ls5dkKXmXVRV3L5zQk51n(iHOkgU3STW9Etkl)lumr21Z(cOP7SyYyjE45MEs)dVSBUBOTfa0nX9qNWAF0nIWcShGRBnHHoDpuRMLAGMZV8Z49ksE9lvrlBLPQgkHsMSyu348l8vL7S1SmZEp7itH73S68ueZMXd0odKLDKA81SKWeKXbwpNP)3nzxS9JExOgljoSSXI)1FBQJMrYgrQTinqmIhE(OMpswdRCrIu0NcCPJyplJvUAQyp22CUiyqv5oCV4wHbnxP1G1aiJyLxFGcFuRJi9oOjUxQJ5bqS4GQvI1mZ9Rl1shhLAhYWakdzq1rQ0FDS0)e7Q8(g6NdqQ6ysttQslfMWy4VzMYyDRlekYjG33z52sSC9QJLR3gXY55Or9AclN3ky5QK3hRILZAMK8xqwopILRKIfVAJnvdugTQ81PDdeVAFtscJoBDuyDIHnKi9j6WxO7)JJKo8ISDlxiLkhaPq4IZyL1DKCRy2xAy3Yx5lV(Zs3iK7RTvdn2)zLGJTaUvNiSArYgBuUykRDZ(5zJkp39QshNr5h)QSOhVXmVFeZJ(348qGt7fmthbJXlNlmt5RiiQGbfCVZZ7bVTFcrcp(6gE(BtdnlMDUa(7ibfAE3O48L45EJbrJGAGs32bQfg45)Fsycyz8G8aA9skkpPZdsqzVYJ3lJtrKa32tPuek7oHpFxAy4N2nn7v93NZ2hQ37gmPV9P)7oSvoPlpVLeWWXKATt5Ltn2au4sEdIN5uGhMu4IF8GVaDY7V49)AfdgYpxlpyUeZ6mNn(Ii0)BMxR1ZJOtH(fX)AbaACzJKSJ8J4qtjcr(f62E5tjq)nbyQDaCI0mFr0ybDO1Kz0fEooACaHJbo3tdJJhhUaTEcSh4x5mX7trtGZWghT)VrzfgAjg8F5BI3uHFsNTqqt380YyfwSq2g1QjwfH3AA2kGvKOhUYVdNIIRl)oUetTdoL5wE9hp1wKuW7oj7Fa62tw4e68wC(PFCxPQM7cYtyKZVOBJnGTKxvR5YAQYreG)bDmtUNJmLB3uRHn2nk7o86AvJ82WQNTTw1IwfVI697eLsldLP0IuSgW)qxut)eGEgpjImVw5eRppFNgZ(Z5gkSSZd4DxMfCX8UMaPsUlqXTOCmC7Uf4hFcsIH2RsJFjRxBEcYGt3YMtux(XSIelO2K4sdmPGDidJJwKcqsKC4bdoA(in2jIxBnZAICVFnujeUStXyWfifgRfDI259BDt3cBoCRCCb3Pzl1qGoldPkgmpg0YGLsJMo(7SQL3MGlBTXOeIFVA6h5knsQp)gU8Mem)fUGYjuovf2n3dUOniJ8NRCnX7P0ny51)gLVbpRz0GzYBuAnujRQ(U4TVlEBdyj)U4T)skEJZsUAZPPF3ppBX(4P7FoW5X3Md6agJVN52kYVj)iPpp(VPumNZrn(Y4WSx8TWK4dXupxLF3tcKNZoOuwXH3YGr1BMFbd6DWu1s0fTWX0Y5bZn)zDSAUZpFLtm8lLqOSv)fhO3j43BvEFf5Jx)b1AgLvgLA)ir)LcR2ueNRt3DYgJ6CLNs1e3CPlci6CwFtpwBJhXuKUmpzlrBc4qvNYCvIVfKPSiWdpyxtcEBD422RYeH9S2a5h7OxSp0K7uoM8UDW0FUtyNH)VAE308D18KGq62N88rtAphNHuG8ovoEAGn0tmjnTBRB2fPRBXEFDJKwPzJSMjJuxrwMESMrpk0NLK3tI2QMkEYuKZwo5TmVI4OSCe9zSzoFImpExQJGDLHDfNYpXD65rD1Ao21Nh)w2JqNN10RPeo4mkpou2nFoM2qufTd1gMNB5tiRqLoRdtrigDX(9NTyUfBcDE(YsMc)Hq0zpYUxh00YS7GzZJtYOk90WfzK3)2ft(2zlLPPEq6BlDxUYP6BH5RDxTFWxLc30UfhPKr0ukVubu7sWDsDTtBuc97(PwU9duRYBiVRVxRDSzq3dpuUHN41P1ANZy702ULCTK2IvywBNhEWHNP0(qLftN1jFWAEAPLVaSS4wJL06m5k4iDADDnX1WtZY9gKyB16zoDopIE8sVFciN)QqiZKv64OIP(yIQLUyoYwqQySZKEOIBQRbFxz22OYL4l3mEyKnWuxMkFggNF9ep0Ma6tkm0)(WR0CALMtiVLgWsbN7zG(0LRJCfGPFMUiUmDGmWZ6oabf16RUiV3febB2PBRiosZxxxLh33ykkpLpd(CX16K1nJXUoI9MI)4XPkFWWLbavssgK9cv67ippjvQDlcZbR6g1s)PZ62SLQv90ANQxB3fNy8olMdls98foBjo6(VnGfquYDlYqu4cqV(aDRoCbe(MqyE47MSaLawDvXGnXIlFMUrn7SQT9sKUA7WyCJDDpKAukdB41ozw(lVFoIX8kB)Yz9FaLDfZBakqI(zZ90UAlaKlDOpX3eJwKjmDiKJS9p)7UUTmwiT6ltLFVAt5aTmtMvgOeO74ekzKJNRPoeRzwXvUlcXTBmhISu2wqzBBDAWBuFua13ICCwVTwPm2mncnQX2ALfy4aAjXZbKdvr4YRiWOqPfrz7ZRS6RpWLq9MoaE1hbP(OrABF5WvSV4TT3x2AfIyANPX1Iyhi2gfy62pdOE3OS(BXkvCfCwTfRyNYb4kvmihbtqFSPQQ0Vh6qpchKkZ3w2OuPOPxisFbkHMYTKXQeYXFrwSmRBLvi)Ul)L)gv)37bNu8dXrWWqF(fkCDMEzKqvC)T(r1Ua0O29(wN)TgYEpzq(WNBixIBZaWw5elG7YFXcHvEfRD9OVQGrLPOiNtXswEz9nmFwwoXJR0O63Yw)bqvG12aqpd55tUVUzErt2Ua)rmRrHkYBFBDZ8YnB7pipIvajRTU5UQbBta)iMVO(W6MUYVVfbRRjBfXfYU51e(fhnABpapI5UlEgRnz7c8hXSUoEfNnB7pipIvGD(glnyBc4hX81kNt1VVfbRRj7rozZRCPuSWQBRnpPG)jdW)jnVJNl4wKYU(9fUUGeTAxh8)HFO4NkoTG6R9pql0bw((p8d1b7(h0rTe3Wj3JAUTQPwoM9yN8hRElZEBkrrSTb)tgG)tAEVAkzVkelwG)wJs2cSRJsUztUh1CBvtTCm7RDk8XErk3IeiNnSeTXp6K2OHdunnS0a9M6wrMvzC7lhlTQ5dHZIuU9XQUMxAq)P6qGRCD5QvnFiA(6ALnV0G27GTSuJNA43eiJjDtx)O7hmEEADq3v7A6kOPJdkWzWga)gFqM6pP02yeCzvPtyVP2p9ud)Ma5MTV6UDnDf00XzZOFwdptTH0pRXi0u6NkgxSJttrDPz)HhCRZVEL(Uyz78Y296E8RCWsaF1YaIVtcD6Cs76ny21MS5i2BLJyp5iQW)pJ4T9F2XB7)eG3kijRyiT0B2Q4fLtIB87oJJqfZ82yasomFsCyy8DCA0dRBmJje8JMlc98KNNd(dxe9Pejs1o6IJoHVlnfTE8ySXJ9Z8h6NkE7YFHZz6KGmhEQ3pg9xYA4J(kh1ERfBch7yf2MBavnJ2xpiMNn7gaSswUBcphKapIzyfZGLZeTRVL5K0Yn7AvYJv9TOoAAa0Qfh1McYszrRbuTwlt)thWjLYlydiNynPHRaAhbvCBaAhrvuMeUgW0OOywbyoyauLQadOzwz(kaNvrhsHVRzmKDfOIYLQRxy3awTpxAH6gO5ADKXI3cGT0KNqGVsW2ClkBKLRp(HPwdxDd(nZY(NyW7gWpAr5UC4FV6jSR85gc0vs7zTjpHaFLGT5h1Ure2p(HPwcB3GF1uEnWLkBBW7gWpAcBxbxzZK)9Kc8vzL6Jal4YX8BgZYtkWxL9VBewWQjatg(I1s5VRKX6wJK1ZyE5mz(wP6I)nd(B)0ZQw4UfM3wjlsxZ8(Y1z1FSlBhWDlSS)tf(pA8Y2)CSoG4gFs7kH6s2Vh35IDCA7hX62153301DLWh9iHNRdbV5a0HM1TXrFDGm1UsngW1YLT55bOo2MSDhDmGEDxJhDPQFIeOIa)hl7equQ5vxaM4ojaFao5pL2npJBFv)9hI3dleHJV8O3G5mEC0Fiw(l2ARYvQ7I1iK(sRkuEzExQSl3V8jzkhPGhEWYxLP(M1VDBrILz97ukCz9lSxmB(IWZ6IWw4YkgUQ5VN1VzDryMhAw)cVi()GxIUr0DM6UBcOk3i3uMybRK1vRJ17IfIaXebxDjaYOf4niGUGG9k(BjGsxhmf7(8DJN3NEpVLySE7w80q3)GUhVBE9JS)QZSONWSEYEMfToRxVh96Ts(N8eMBm2Z)eIi6CzfshV1LAB9C5sF51dVNUbMZHzp)S0jkQFkllEVxL9Bx8nzbRiXJ5EYVslYruR54kFj9ixOQGXDxE9p7ZZHCEk8MVnoyc90D3wwGUWB4AVUh)Tomz(0a5tLlvX3tq4PQF14N1aLALbdeBUPTrr)rYJTWe(d)0sTUyeupHEP8TvCSq(NWq8Ekym4nvvUOkgJ8cDG)s9AxpDPUtu)lk0m8tSoZdRW5OS7MtLQQs1vKcBpjEwhq7zh0UYpO1b05fLDBtBZSNrxoFDj8Y6mb8CmbSM(o6YO3wtafnMP8fpD5l90KU8efL36coUdNKze5vB6kByaFRlo5oC9SXGBZAJ6I9ljq8l0n)SxEbnrED7uxYE(UbF5Np7ZGbCZweMfmpSISJEDpqgP1EDpuvpZKzYaxAhGzTuuW5N(rSTbHJBetIE9OsP1P7bVu)kbIRIT37y)7JpNFHs)i9WAndfTkKplPhLkgHLfbXmSWze8vHu(o9CtdsbYkxC0VLkj0a4jXLbOoGuyknbl4LWa8ZQ5KwjWGRRIVEPSQhNYAngkMsxksCbnuWvia)L07mEJKpA(41U7yXeFylQ)rihhSDjY2YyXlUC9NyPz5ZREhQpXqQubERWjYTr(0nwgXly9ljfuGCFxUvwhqrYyF40dIzdt8hjWsJU8GfvVN7GSn1H6gfGh5G81G9fcMCfbzIz8cj9gFGZvmEqCYq6qeXjuXD3AxZt0bTjtrjt3Ax0RQayV2PA3Y7i08)1cKfw7hwaMkDRiuAhnvwrNRE8EVq(eLw8cZ7pKQEr4opwrn2dPotZ4QMEO4wQcTWpqUZfrcMsj)j96o6ZN9L9o5JNU3jxCXENKelFYc1MqWOd)lCPqYR0mNBX8wT3jxuy1xeMkLGL(EDE4bS4D2QuH78DhESbrnx9MeOue2cqMahl3OLRjniDfAp3DXjCH2Nrh0l9V)3cMTGE7AZaUEvAKO37rJxMxIUsk)O)pfefqa8diJIyYeYel1R2JgZCfofJAIQuuOnZHvxH6gdkGtdwvMq0EXcCpVxQk4Dps4BPkoUxoOrM5pfHf7gqHX3Wzcwn(nk5(PYkGYnI7Fbr1ERFqiVtdkij0S22IUacykhqqFGqcCsRjp9lxVNCqHYpvcvlnu7yD9v6dwEJJ0qLMvr3sgkvAtnzru1gIc3X6KXiqgko1nyv8wjasP0EcqvV)ZNx2nk)FP3feWeyuoaWwm2hRLzcuFvewiNxE9NNJ8dSb8PuzDwvgBqQDspIV88ltdJhIBP8JLiRDH7i(yiMie0RHCUOqyzTALAmb2r0S)PEQySjIOAB8I4ElmBUqOQjrCDUwnayb(JFMd55K8XDEIapUv(PhNfpmLecF2VEbR0NBnQnw7zjxxotevUGcjjyyJWQ1cG8Ir5x3pujPMbqzr)tJlmjrv8zp7lPBHYk969kwyIW1KNqknnRKZN0)qp7AboG2c(h5V8d05Oj)grQdiB3Gf)0PjXMdA5YEQlLvL5XEx)dF1HVuf3IsPX3dp4s8aBkEX7JErTIApIMC608Jst1b59RulWZROqi9WJEVATkb4Myn7IWMmeXFT3PsGc0ozMHMJtY)GjVoGjnD)ENw6LRVsvl63Ldh9ttOkJF2Qs027HSCPvA7hgwBeJV5Hhmjd13JRu34)FnBZUytk2X035BxJbmU39B9uVrVzBQNP)a1KxRrrj)8tp0IOiAVufqd0fAfr0GOb(0lMHUqlDXmP7hrju40IpCfoaLQ)3kfjfGS0RRRuBwr5hx)q742QYLEQZTkFTPWpdAoO3xYCvL515CJIxwPZVs6G)VQi8UO2PrhEPk5HMAs8ehSH54ioowKM)Iqmjen048t3vRYctHVepVm2xP61vRSMMbwQ)VVZYhYR9VAsD0cDQHOB57ELAFOa3dFsw2JnNFAhIdavLh0)LMVM)Clo6Yxv8hQxN)sV8ryDaMP)uVKENFkZVpKD29cvLfgReu2av53AjcEPOvbSFE5sx75QrPmqLLWw4Bz5g2qVEzahL2QGxG4J0VzfmUClsKfgzv9qMv6AIjXcPS2HQlWBMAPpP)rG0hzZkLC0st7nlQ0YF2sTVdo8zUwTYqQTDqbKroHfcmoQxvR1YN0V3XDkM1jLcrCl7f4lPt(QqtXSoLjR(D1V)BWVlRlCvRm1vli17wunkv0oU2v1Aks(6y3B9wHagP8EB)dBTcuyfAbnE4Ix0DzLdhKVrLoCCA)wtwcz6KRxeOz(PDl7rVJqfR0OjrbLRTJYagXDTRjEX05p5KBYXuAxsrXt3Yku2gR12Xom(QsLs3fRG8hENQgOdci3RxHv2aMEIKw44lLYBeOKBJLvzpO58vA0HgJwRUITwPO(Yoe6FgJhMESYZnALK2IQHm573lUSIImTgVlv7DHJzxUi923Dn6TTnZImkK8VRFVoBqL7Dx9kEC)NSksmTxaTaaOXNSYbvUoORUSeT)Q4R)Eh(ncqA8ai4bPC(FwemIc0iStUS4vKSIcttgcLdDLdqld2bAUPvKrP3uctyQxJrLUaXWk9Y1kt0JOlXkMzyWiP7fXtWtMnQ7vEb6QLYotB3IsrOnV0aKaVYX5hn3evgIILxs9yIuz3wztD)E6nZ2bAm1u2)4cZEkpDAzkK515(pFfn8nDAm(XZg(X7vEUoHTlmKx3MIGmqLnEMEOTzAD(cq5cF98p09cOpwdnB2sWyT24vWrs6(hDbITyeNmuAFRY8FtsFlYeRwl2TOJVxRCIsZCdn3gQThJsNMTI8yTZ2nuPLR5BL17HwwVEB26DJj7B4k(WsbJQmLC7TcEy7Zp0WLMIB4X9GyxmwPvJA4tHnpouL)AAT8x(hDAd0f9Z7Q9SAZcnCmmEvagU9v3tsTXWvkWSmMU4jQMZwIV)KtxRRbj0yzF1xxe)E3roFtoYLyFqlxE73QJ(FAFZOnwPnlabTB7qcPtj6TwDyeR(c5O7o1QpWjUJmPt5X2M0shk8F4pQZgKbp1r8inZEapC4KARrbdAUT3ZfG6KizBS30voBq75ps(tvIgUkKmRJR3TgJfG026RXJAYxZtqQRrXra8780hBbMbAZF9JnO9EgCU93FLJBe)oRa4787Rf7W)PWV)N77eSb9l(M1UlyJuT2MP5yTCAqBEr01b0KjZ1RSIvEj1llpRSUa3E1nvpP)6niReDy3w0NumYQx42NuNSUl9IZeTDEdEnqMM(MDnWpTRt)0EU0Q1rLrIvD7BPjMUdEFENy648CxI3Sxi3MGClwXs5VnnqokPIvBVRLuTwq0PLrSmoPVN(s)j7vU1ajPcJy9UFkPCWfPMAjIH99oOI7R5v13F3ARzjy4qGhvyZE2FJwlhmT)Q96HUgl5N6xAxKlZQDAneav4JiQR)T(vODRs5xlDqdXX)fNAU5RcyU)OP12GNp26Cr8M5I(ImL4z6zH1KMCLzJxvnEWjVQ(AUEs)EG2r1bv1QceORiT18xFqllnUZ6p)KqXwPHO1oR6nDDjDvq(n(EHHkePlgg6(cm)Bj7Chh)wTu0zgmtOh9W4OrSaIqImdqVLU2zP1FFZkDPYulHQjKtlBly(3kbH8vsPHhMyj(HOjmXPPXZEQhE9C(4r8O2UcZCTmLurg0X7B7j6VTT1L7tYVzlx8m4c63ZmpsyDgwL7BjBs(D(YOq3vCGgddDdEGQjbP3iHveImULibXjLrY8UiLTzoJLuaILVmp480DiHfAGiFU3Cs027nPSD1HIjYUsoqt6QrE45MEs)d1V2MQlDuLWwA5(U7k0hMcsouDMdlWyaU07wBOkQ9AbAo(ssHxD0lB7mWi5rtwEuTx615vTRnIvATSZ7637n2V7HWXgKU5fdEusEzpGsPA83Oc4aY5OU8FJLjp9Ukj(OWDU0wtbgwQzcl0j4VzwQtwX(wAyCM6wK1ZzCQ2ieVL8P8q3XT)PE3aSEDNYxgFv)1lCb5WuchlvhavnjOFpRLoazftOtlBLIaUurijmwXD4)K(LOC0RVdfxoczBFhQbTTtNj7DGTBzrhvEiBi)SMvCNMtm59Fket9CqmvTAswhQ1ZYh7vhXKNDIjhvJcNetwQSfptetES)V)0KClUXqzrQ9t1LnQQmouE1GdHs5gjUu6nCSB5lKLx)zP1U53VHvdn2TfLHtJj2jjNUR9i2QJi57e22APU1zd2eCl0P5lgp7lMk1PjBe4oXbBNfJIO)Ql8xKDtCYvxCrWSpqVy3x9))p]] )