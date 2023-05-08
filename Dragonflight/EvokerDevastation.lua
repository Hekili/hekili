-- EvokerDevastation.lua
-- November 2022

if UnitClassBase( "player" ) ~= "EVOKER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

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
    name = strformat( "%s: %s Padding", Hekili:GetSpellLinkWithTexture( spec.abilities.dragonrage.id ), Hekili:GetSpellLinkWithTexture( spec.talents.animosity[2] ) ),
    type = "range",
    desc = strformat( "If set above zero, extra time is allotted to help ensure that %s and %s are used before %s expires, reducing the risk that you'll fail to extend "
        .. "it.\n\nIf %s is not talented, this setting is ignored.", Hekili:GetSpellLinkWithTexture( spec.abilities.fire_breath.id ),
        Hekili:GetSpellLinkWithTexture( spec.abilities.eternity_surge.id ), Hekili:GetSpellLinkWithTexture( spec.abilities.dragonrage.id ),
        Hekili:GetSpellLinkWithTexture( spec.talents.animosity[2] ) ),
    min = 0,
    max = 1.5,
    step = 0.05,
    width = "full",
} )

    spec:RegisterStateExpr( "dr_padding", function()
        return talent.animosity.enabled and settings.dragonrage_pad or 0
    end )

spec:RegisterSetting( "use_deep_breath", true, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( spec.abilities.deep_breath.id ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended, which will force your character to select a destination and move.  By default, %s requires your Cooldowns "
        .. "toggle to be active.\n\n"
        .. "If unchecked, |W%s|w will never be recommended, which may result in lost DPS if left unused for an extended period of time.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.deep_breath.id ), spec.abilities.deep_breath.name, spec.abilities.deep_breath.name ),
    width = "full",
} )

spec:RegisterSetting( "use_unravel", false, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( spec.abilities.unravel.id ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended if your target has an absorb shield applied.  By default, %s also requires your Interrupts toggle to be active.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.unravel.id ), spec.abilities.unravel.name ),
    width = "full",
} )

spec:RegisterSetting( "use_early_chain", false, {
    name = strformat( "%s: Chain Channel", Hekili:GetSpellLinkWithTexture( spec.abilities.disintegrate.id ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended while already channeling |W%s|w, extending the channel.",
        Hekili:GetSpellLinkWithTexture( spec.abilities.disintegrate.id ), spec.abilities.disintegrate.name ),
    width = "full"
} )

spec:RegisterSetting( "use_clipping", false, {
    name = strformat( "%s: Clip Channel", Hekili:GetSpellLinkWithTexture( spec.abilities.disintegrate.id ) ),
    type = "toggle",
    desc = strformat( "If checked, other abilities may be recommended during %s, breaking its channel.", Hekili:GetSpellLinkWithTexture( spec.abilities.disintegrate.id ) ),
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


spec:RegisterPack( "Devastation", 20230508, [[Hekili:T33AZTnoYI(BX1TgfPeBzlk7SzMRLpvsCYUzQ9UzQyFMPoFXYusqY8eksTKujXt5s)2V9dasqqakQh2t2DN68yIfbA0OrJ(fA04ME3C9nxnXptCZ)W7eV(NC2jVQBVENEYP3Cv29le3C1c)XF2Fg8pI8Nd))Vu8f)0m)SG4i8B3hg7pbbrA8YKXW3VllBr6pD8XZcYUB5OUJJNFCAW8LHupgN4pnd)7XhpkmE0Xts8Nfhnnmy2DzhlIMfejoECOFA6W5Xtwgksp2Fri()nu8L4pls6oEXIBUA0YGWSpeDZiRiE)FeqMfIX38p6D6l)lacfmzIGBSiD8nxHn(Oto7OtE1pT62RwocMmrzb(HRUD8D(rZePRUnlg(sW83U6waLfRU1FMFqu3v)8QFoVZNcDE1TFaMrI5IOmS7CpwUaXjaiTV6o)Smrsq0m4Bz(jhU623hKaG7njc)S7G)8DWNJcYUhXJKzc4x(L7tW)ZFp4lu3EFiqZ7OnYNEu)tOr()MgMjRUDAs8C1ypnoz1T9oPBVs94KZ06r5omou4hrJ0YfRU91F8DRUDrsqCcHt(RUDuqMgO6Z0Sv3(P4LzWsLAYQbt568BX15v3MiMgWGhNxqZtbgjaWWNMemDQibOCa12hM7W)DC8YOmGW5hbtlyvz8NH)iE6QBF7DylGF8naRHoc5DupED41Wsm89lj2PeAqEDuW84uAI8l(tMqyr7jjdxW)rhyiezWSyw3BUkminlfzIf4)))bTLqe5pkum5M3CZv(JzUDHC5AykUAb)98fXFvKmmlg7ZvJbYgSC7ZD4lIHIiX8aKv48bWYYQBFboxdH5CxfKshMUWpQRCSwD7dpa08LtN2Ds(mPlWGbCFiuaG09VC2QBFoG7leHHdVdihWuTvnD6cEOn7ITbczbaq1gwbmWFagNX95G1ofAvT7io8sU)BxNF1QB7WBFtcwWRfv36SmfMxj(rFE1TWcpWp5VyryWyeY8oAMplT7nzGeJgUex)AQhTM6rK3DCL1R72SWAHDOmBPhoz7VxMS9PjB)Mozl4uMghLnmE6W5(Zcg3ukcoGD92cAIfczzssFKKCAdjj6D8uOJzGUfyYSaOmj2evuIh9JuZaMY4mF6huJsbUxhV4yFycW)XqucflNAiRgE6O8vwv7Zcwmm7oXWuOJGGmnqQMWQwMMRzAiiNnXOPNzGpfSfI0ubPq8CIrOfTktRgYVmC0YeqcTusc9fM(fenDzkm2WNkqJqsl3WPOsoCGFPZb(Gsal9RWsBjivlPcOfaW)loOYtcsdIYeZsqljUc)NjjlxKnmyksrNlo)hBnoooCs8xJ6wM7aWGwL3OC(aVwhaQvgokoAzA3Sars)tgE6IXTKMVaYOgoomyXcyE3QDLPKKr(8zJN0DU)3E4H2s6659BDGv6CNoTYcafLxmWdMD(jH3peSIjiIqFTbv7t4qxv0VgyOwDZv9y29jIP(ldZYz2v0T)5saJn4C80BWsa0Fry2exYIwelxo03aDPi0hKWdFB1TbrGO(RH)lyqW9XlbX7Off(JatrKgSD1QBpIL9hEpA7riyPkAFbzvuSCV4xVtG9JGWxPpF5No6I3)MJU4QRo6cCNQKJkN3ZTAYdqBwKSggBPOwHs4SPoduy0rk)lonLG2u0c4H6ke6FMn5uXatpWGvq3(IpGKWxX)v4suiUcJQkG0G6(RYUcKV7qtYeieyBxbQeqUJeFdTutZOQa4BJaI7xJt(mzrft9Vd(eWVcM)bwbosK9vb2D6N1794jsJ7aQpSuiLTMc6UdMffZgk)2l)e8fW2WXigLc7armQlnrL7Nr0AyzrOMISqYeGqnHmzSNoFj4iLID5MX1GbMYU2amyk4uWWrKpbLg(MnWUKRvRiXmGy)zWwieaVQovy)1yCNhT966InrXWQBVJ803nojo6zWk2DWwEWG7paTbA319pPaHswgvgFk2IHYzjM(FK2m4wERvleLwIXAJSj9T0uVq9nm3)rNACQSVfgdSZjbJZiR9DoT0gl)yAjQ3jowJQRVPzS83fjcWh6r(vLadqlnff4a2wH69hLeh97cBIK3ibisEJUz96cwpne1EGIaL2V)K(rDwFztg2J(sQnDjBWCZRoK4j5J2MBEfZnhc(r16fmPQ5xxdIJsbLgzTqTWYesf3QB)bTDAAklkAaSV6eEouF7(H1nsmGmDH7sX4GjcuztW47YbbRmFHFaQSoi7oDV6pedpHykkcc2WppiAj6raPsPxXFNlCZk3t69rJDYHmueMc)7t6Ewoltpx6xKRg2Gu11vEuRzLZZXkN3t2kN1rkFLRwYJnLFnCJyVUbPDtxeheMIYXIeHGXijlnTv5DklbOWsPwHxDlbo2Meqk5cF2icYYd1SHJHe9tY(Dig(PVeqHmc7jBOs(CoV58E4GmKRlgBFA3v3(38zCa9uimKmtzE8KGPbixz7XltWGAHgG2R7zFRdZnpla1kcD6oWmpSDfbzllUeOuZmyGUgrbRJs6DXldrCxOIzjAyvAPwxmcbymk9trshQtEIq(NWq8A0upOhCV91hdYOzu7UV2oZVgGTnor9VIqdZrwB1wvfnVSbBfB(M7hT0p0MzlBalJNtwgB78kgstdD2GHK4stwo6(HGLXHlgMEhr1muDbTbKLLUGDdaO7(jrap7WGXsOxHEi(24WLte2mfzdWoVgGDEBm25PJDvmHzdLaQyhnCQVwfyULrIZS1jbDTcrpUudW(oS4JDit)Bt7I5a3MyvlUwlTGq8wJo0)7fvWkRQkpUudAmwzAuLBSQNgwvwSEVColkQH9mJT165i719KQXERKC8prXNTxUZFY2cso8Xq2YocC9hV8J)eimAzywWIWkI8Orze64zVU9rh9tHgMYriyEm6D)KfPsjyV7nVhBBq4KsIhs6nehWH44rZvBMjda21Svbh88eseli4meT2ppCjxDQtVTjeJ9WgL(JHla9CcyfiLxk3ILnC5cqXg9b0ZyCo(6431LCq890PUmh1IGEkJT50uXy0jiXCO)HbFwivLLcUKNbYmrDFePli7zO6trY9KHtKMHaKZjfqPP(j0a83u4eHjmTfK1grHZhgP4OjPScYrIzKBR4eAe6WcRVlmoLJ3EpB2QVPe4uTWrDfaXhlc8vxZ4SPn4shZUZh2ZkMmmoze56vCcEcGLIUQ1gGG0DSvt8dMmu8fmG5(tMK2frekg)ENO8Tvgp94O7)2WqXm)X3xoA6UaXlzi4U7ArdvaeBowee(6oKSQG7haRI4mS0H4Caj75pYPejDtnRYrsAozA6rjns)R00Yi(5zCahSCQeRxYTP0k6OG5wJYrsr5gVECgyjfAA7NdIM4lp9y0kWVINblEAhk7aXTCOGGPKidCFfTr0xAg8SW4r4jMRoP3Kmvh9XZswiqb31kNTMJnPYHBu5mz2Vyzb7JnFTwUOUOERfkVYOj04jmkHlaV9s1ihfJk8M5NmHrww4U)ubAPFUJlZJhXHq8YF5kwim3AueidvsYNEayJq4IZ2VgNGnkDmGUGrByGDVh16sr5Jbq5qWplUqfrym4mscoePilXLxHXmew0c(DYcgqP(hJqgiwBpchPdtYiGRCSiK(EFV0xWUBiIOKdqq)ZjsD9y4Vu6J6FsAzHt4r92LyxYIhojqW7V67T(4UFITWVOwWmpJTslA)34jqdTGj2uonWrwN0(IPrYSK4MD0c2IX5MFaSwdXmoiDSfuJsZL3sRa65RcXqbBdMnl3)q6uRoEuO)VtSaWoVeCXjEzwkfzhKtBN5cE1MXeOwPQg)7c6EBDH0A0)s0VClNnc6ozkF(hnLmzE43(Q0qrtcUAr215)r8H5JGUTQfhRQKOpKP5nPNUs5JC0X1MMxX912wfsDuLtL20OblmwgPVX)gXBzJexMLWfdxB7rRRi7gQLTR1tn)0(KVznhrVMrP2yMU8n8kDK6CIrEdsRn9ljlJ4KqlyoyNpXkaajlzjbE2vQp8S5yqWsxoxgaruSnozzhdWbiI57qLSi8z9XfGuzgbPyuATa4BB0ej7BH)Ri7KkOCk3XMZ8M4NbfWiKlmfb9VIpdBfVVch0ClJSJ7)YwotuXyeZ4G1mdNylsWdzN9ScXQjXIu6y)IbhjNgI2b(U3CitBOtg(lbZO9YuFzlzQSxPCknq59hXLy5JZ9)2qzdmKYMm2psmKgUCNASeunhQ4il9lwclw2GpX51AQlNjCD0ElUpX0MoohidJNfKhV0VeJ5lziQEaLMXT40RFrXFGeT(YdADrO)98HK)gf)TaaJGIZblhBehoCoW1PCADAdu0gJYWlfnEJJe8Oye5ENAukduAbhHRFwU9NZjdFMl0Mf8eS3zRkNkNVXSfaJjHdte8aWw(yXttnALUpzwmwcf(CAUmvz3hZjr6WruoKA4vNfEnPTyQpgKGX)Fm3aGEOuDkhKdAW40UUHsYpx7yvmCuZkpsY9fKJONP3wjEX0zmrSanVXLqmM0doHoSWTx1qAnsGBctolhOmF(VP(9Ff(DzMBUG6iYBAYrG8X8s8Hmto2ifZSl2mTMc7Nmm(BNijsYQjt3avkX141gRSTwJgPvh(Tjm7V)EffbCnFb7xg2y0GMP)K52EG7lcwgom)FPKzCy5G9DkAueHKsQk49tsi5rZe)fzYGtZDTRt7SLJHLeav9L6YzQt1AVC4hwm6AgYsTqo7zkvQ5EzRB01ZTr5)g13qwh0ZAimR67hSopvYBE21sbYcqTOk0HF(o8mxcfFJ8He4SadGO7(WA1BRZuAONEO8N5Z6SLDFhpRGjYnsylMNLMK)pX4zimrk2xpZjZ3YlVjaxRLgHgjvPTuHS6eopFeB1wlyzZbdnWyPcBmVW7HhOUDhA8bMkK3Sbjaz7QJ4dpOw2NiMgmoi78b96SvOH1G6Q1hoBI0yOv9vZKx9Ss1wGJ3crc5BY5aAf5VaLT1(ZIp)BDOJ4ES0Isq4mYn))UmymD(XaxgAgVuoyQfDZkGvsgQXEBRXtUec)EWTQrKKYPGpAIKIzP)VVmbJ)FsWNLr6uDq52c3zjG(BCO(OJlgMAjYZCFAq6DYPBeUF9l0bcWkCkzk)Yu23HmEF95d8Uo)YgqbIJ9se16W9MnpU3RszrIHIPYUE5NaLFxY5jhp8CtVyq)R7MF6c2ox7TjIrxWkK0TRWcShIZBn5JoJyuRMLURM4xUBFVGeH)C1HGU20VefAjtasQBCoZ(IYD2AMtAVNDK3cNxT(CVftNqT8w02ksnHFwYycI9adQZ0)7MSk2ENxfQX4I(LTF87)LPoA2nBCa8fz3JrAoKpQ5JK1SfOi)ygqNhTJukqMcekuXEklWPyIbxL7tXhxkm45knhSMxaNxC6qTxtSj9oPjrCQJPpjwIz1APAMP031AzzLsTdzRaL4tO6ivkDprgYIdvbKdd9bivDcPPjvPLcZdq83mZeWU1DQkseW7p3YTN2Y1RUTC92QTCEoAuVMSLZBnB5QKopRBlN1ee67WTCE0wUskw8Q94QAGYi7Y0q8lnpcVRt8Q9fjjm6S3jH1jg2qI0hi)XWteiosgdmY2TCHuQu7KovxeJvw3rYTI5WRHDlFMV62pkJSqE43wp04qQvco2odU6eHvlr2yHY1MYAxSFAwOYtjZQ8Xz0jivZnWwtS2nUV(1wK2w)vhP2O60tntuN5kyYm6vtUBxLM0RtA)(8sCBQ91O6cODHO9xamMGKeYt9I7c9k(o3FmpZQ)MrxI0BgIhxHlRvtOAowx6VM1fV996YE7kytRmn(wy7GWwmXQ5(t3(jG07MKnypEhTRqZQ9AA7uoq(D0ETXfaVpBVEmRP)VZj4eNtKyAWdU0xorjNX1kc0mv08VdEAJOxnHr6LnmWEMBRxFmQoxBlgHofrPcdOwmyGfymzP7ch1cd68)pjmbQmgHqGSEnD8XPlcsql4KXnuEaOrcKTmLYF0SVk85Bzkd)0UPzVyWXCQGs9(WGPdSJ(N3V4wBZ4TKb8IbQRsD(0zn7n5Z6ZG5zbDIMtlo7qm8zaFYRV61)sf3oYJogpyUyQlypmgTpjc9)gsx0RVjVlIIL1Ne)ZLaOXPnYYo2pIpZBriQ1LUh0(0TR6UamNXa95eMVmAIGc9vYCQY3ehnjGOXWw(3eghpjCj6dg4vXVWPP9hKxG)J)vkLHr)5WB7jTZDMWpPZEiBm2(89An(9qEy1Qj(wHLphPSZ6ZGmxjoMtd6QlXXUgZzSkPet(PNrjX(r4gNfMPKf7xm0GM5RRlcqJda46vPuO4y9TT16srT6dxCjkXD4bxRvvHuKdzqEVgt6KtxasA(cEZNW8Ou9t55GHizwqX1hZihFW0GncvqMiMSCm(pGwmwwVJwXN(DZYqO2RZ25s(b28SpdXXYgMxxYNTMS2P2mKudm2UV1QVPmEydtjjA4X(nsjiQC4LRurr0qhz)20Czkh2g7A6KZpFqZMQHGSVmuq1WfXGKwSUI10X)G1n92gAzRTMK0zL1C7ZvoAvFYdD9DjyYbDfLW1CEaDy(zHG6Hh7Vqjm71uU8S62FLsMNN00fQ2sHqf5Z)PeN)uIZwV96pL4SEjoCwHwBo89B(5zh57FZXV7QvYBGgz37K7zBolYNp)iza9(R0vQGZjt(ceY2yk3iIm24gw19zyAG09VGszbkERAgxV1NfBq)kGQwo6Cl7yS4(S0cm3(IRfz)x4Kc)CjekBmAHFMob)rR7OfW9XB(GAndkltsTBP(3vu1Ms4C50XfBnPZvysRjPqKEUs85Sxx9yxU8OnfPfjxmQJHZdJuExL4Bb5hQNh60rtYmH6OTTxNw7JS2a5h7OxDM0K7uoHtCh3J)yryN52s18mR5RQ5z4JmAe5EqknXIZiqqENkNMnOg6jINM2TnnB601TyVVUjsR1sowZKrQAjdRO1mytr(SKSQsYw1upvMsO2Yb1v5LWmv1UcpqeZCCg384DTobE9XPnXD6OsD1AoLoGh)w2p(zpR5owzZAXeJJQXUO(p1TNipnBLj2prvgZTXFkfygsesFmOst8Nt2jI5khyP7BdX4uK3kkUt4NyORByP29xiy(I4KmQG8bMgNHr7dZtyQEJyecPl8qbs0NMNhCXS4jX)urbjEC8CkKyW)AeyqEsK78r8G2OW29szE8Hhk3Wl86yTYpwv0JwEgEqB7gL1sAwvHfQDE4bhHpr7dvMmD2KuzS5zuz(eWYKBdMsBcYvS5YPHY7VeWS2qrDjLPFYmGLC(Z7hbN8(SqitcB6YXs3KBqwXYfiV()6Wr28vKMZUSNgWshYYtaxGRWF46Gc(B0n1MLDjtdb9lXfEDQ8v30BqilSyNUVo5icFDDxVCFL6Oez)s4ZfHwLvMHNOCehdESMfOcDpxRpuPmBq2ZujZL0bmQ25xOqH11HQ1(WLDB2u1QInn3G3X6XqraR3LQYGmG19CxrjDpbLawDxcHfXIBNOUvahSUL9sSULRKhEUUOAnkbYnU5HYRbI8cCjMWZSJlFTqOGuHy0Ajb6h0S(DFcGCjVKeFtmEzMWmckoUoi5F311PYcR1a5D9WZLNvGaIjGrkdfZhL4p2KGPLa7SLnSSgR(NooaxQREGiwPreovQ6kxYRbnmvw1qX06gBN6PX4u0tz6mysLzPjBWLetFMi9z4kjDwI5haR)YSyzUAkFAm6U6N)70d)qpWwR3ghbdd95NPoRNm96rWZy)gT)r1KgAu7EFRZ)ob54fcohctztEFMPY6EVOwWlvZv1j0ZXSn55Aznrf1O5NYDp9MvfGG622LXQbdo7HhoOw8YWOJlg8YhEyZ6WR6OOV)lbj5PHIKZg59OXG2)PgYLYzjdaBnFMkG7QF2I8P8QG8MjMQcfvMFKCcnZAhu1mZCSSCwpxPrLM(7Hbqv0(2cqph5KtUVomVOj7xGVdynQBsEBGRdZl3S9)GSdZascsD4UQb7taVd4lA(rDOR877rW6czRiUq2nVMSFXrJ23dWoG7U2ZyTj7xGVdyDD7vC2S9)GSdZa77BS0G9jG3b816oNQFFpcwxi7Po3Mx5gXyzRUT28Oc(hna)heExXvbx3oJwTRd()Wpu8tfw0Q(6Gt0IhSLV)d)qDWEWj5gTVLi3oHBRd1YPSN5C)X6xYS3MsCe7BW)Ob4)GW71Zj7vHzXc83BCYwGDDCYnd52jCBDOwoL9Lof(yVW3BrcKZgwI34V4K3OHdunnS0a9Q6MrMvUE7thlTQ5dHZcFV9XQUMxAq)X6iGRDE5QvnFiA(8ATnV0G27K9SuJhB43eiJjfrx)O7hozrADq3v7A6mOPJdkWz4wa)g7it9EkTpgbxwv6e2BR9tp2WVjqUzRRUBxtNbnDC2o(NniYuBj)ZgmcnL)PIXfh40uuxA2F4b368RxPVRTSDEE7EDp7fo2saF1YaIV9gD6Cr76ny21IS5i2BTJyp5iQO)pH0TJFYPBh)iq3kyjRyiDLJdoNj35bfxHp)rbOvSFug3DvokyaYI8rBdb4JcwUBaTIfT76u3baFuWYTeO0XLmnouLME(axpMEgc(j3hhH8uBNp(y(jDGY0ov7OBn604LrLA9KjyJN4N5pYpv8tR(zoJMtcYCCon(Xy0Y2GtOPsGw2BNmLJTwfEMzavnx22miMNR5gaSsoOBcph7a2bmSItqsmr7(ozIKwUkuRtBSQVfv1vdGwTu92uqwkhxnGQ1kR7F4aoPuw7Aa5eRP0Bfq7iZeEeaDfdPAxl4AzpRL78WdvYEG(8bVBjjLVyqVZ6ujrehCQAcTVqHTadkOtoo7DzgXBq7nkLTvi6oeuOQdagqZS4zwaoRIyLMOSHjSJRJZRC107z2DZt7ZLMOUbAUTzYSVWcGT0KhrGVwW2C)UAK)D7(WuR7DUb)25)7Jm4Dd4DwLNRJfRx9m2v(Cdb6A59S2KhrGVwW28as1ig7DFyQLX2n4xpNxdc84(g8Ub8oZy76ii3o5FpQaFDwZVdubxhF12Tz5rf4Ub7oqfSAcW0rpBJu(7kZx)IrLzXaVCw5wwR6I)fd(7)KySw4UhWBRSfPBy2r6GpDpGEpnWF)7)SdiU1E47iqp7O)4o8YFhM3UIBW2oVRCOL7i8C5892dqhAQ2hUCVUu8XUdTTQDqC6A7GbENujPY9ui((DOSosfZBhmrBzunFmbQd2tBxaldOx3D0YCy8w7Hyru6sxbHhEGVQSoUguxOFfOKxHbRx)j53SC1N60YmYn9uZXVpWNEAEl6WWLs3EQkB9TCZQ0vC(bsNjcUxvoE4OIXBUc0xExCYnxDvW83EZvGpntdW3jzUHPDZVicVyWXJWBdjUdcFKVVdV(1Xr)Uy1pBRTQty6qS02mqAgP6W3oKkf(dk76QCNR8auF4blFvMrWw)2xkY3wRF)o(wWy5lC49B(KWZ6KWwweumCvtRzRFZ6KWm9CT(fEs8)bVkRJPBU4xVlGQdMCtzEg81fO6BlWHy9ZqmvWfffy)(sSIcqxt3Ef)TeqPBcLIpvXdJxmivKfmvsX6X)3HIWuXGt6E2H5vJZbRpHlFetgu7jC5MmF9255BL0Y7rmLbTNwEet07KVAfPu5boFPNFclwD7O7P7b9ca7lQMBsyTQ4z5w2VdXQghwL4NW9KFmTKJOwZXz(k6Hhsvv57U62)MpJd57PWRz6KGPbi7ABz1vfVN596E236WS5ZcKVO50RWrccp1Bka(znqPMzWaX(xyBu0FltzxkG)WpTuRlgb1lDAkFNHNiK)jmeVMoLs8(IlNufJXu19f3FL(7jcvoqsu)l6mlrom1EyfnhLK3CUu1lhqfPW2ZTXnb0E2bTR0MCtaD(dLHn02mPc1LZxxEaUjiGNdeWAwnQlJEFHakEmt5lE6Yx6PjD5rk5xQlNHCevuJesXMUYgMhm1L(qooRbJb3M1g1LsmKaXprpRaG6qzXxxwl3vL6c(g6F9hV8JGbCZxgMfSiSISJEDprMcc962xvg(K2gZffiaRLIcOsG8OLbHtA0Me9YOMsRt3t0V)V0S4xLDsoi8ZXgksu((nFhqzjj6YzPcBwUagx6dyD7aX3xh)o(HK(907F4Cu0Qq(6rFAQymwCseZXIetWNfs57PFvaIAxeNvUuZ)fQaBdGNexgG6asbuAkw6uHb4VPWjTINextSFjoii3EkR1yKygv5eWj0ibxNo8XYutAZKpA(gJF4eXuFyjAWP4ooy5sKTNPIxD9MJyPz54vV(6igYLkWsWaXUn2NEomq6cwREsbfi33LBL1bSCDEal08s)lQ6Et(v(UKRh2NiyoNfKjMZtK078HDUGx2XjJiNia)ZbayVRAf0dJ6EVSyLCXGEGh6hu1p4hEWwJF5jTQ2u7dDEWd0Od5)wRdA)4Glom1uVGLG4ZbpLiuokbiY)CjkXt7hwcww(frO0TJqFyB8c1ts)vYhEBQUX5JBA9hrLMpCJcwgGoc3mNMXLS)qXxOsHg)SVVaCnM3yL)Qu(v6Zx(PJU49V5OlU6QJUijw(q8QHqWOd)lKiv1Z(wTpixZr1h1SQjlHxhWhEq0rRsLN3Z7FMHma(PZxGcDzdMz5byrfUCXFd3gIM)(14e(vEGjhOKX5(Fly(s6fzpdesQshn9EpEsrH4lPq0c(kEmdKCsa8TOCfX0PKfPQhEonzFveSyu5JLAoS59GQS00yqbcMGzLjeTxsqpY75QYA5ocFl1Q1JSaAZAhDj7SsPf4)k7OqmZjRyjr)v6DKNoV9KyQOEZLgXF5dS96yHVwB8swgvD4a11myjHm7RcG2AhwuXgwgDgd6pWr2GV3BTaiLYfsGe96p(UYbu6)l9cZaM)JBQbE8jG23XHcuxDewo0xD7hxGm3SZlPuXrxviTqwxshQV03TzHXJWNQd(X7L1SYDel44jcb9G9NlXeMwRxHoZTCkH9p2OIHmgKuBBJ1Yfe2CLqvv04QfVAaWAYj)S7Y4eBiL)ub6QzUNZZJhLssuV8xUIn4HBnAjcdvsWQUqJiQGLfsIJWgHbPeiEXOWO7hPe7YaOSC8zXfMJPQx0x(P0N83dftcUMWbsRTzXx)Ib99Sls)eAjGkeCzyP8KIHafZms2oz3km5Nnlj2CqlxPIDP5XCVB)x0)5s1TLZT3hE4aRYYwUGDdHRqzLFiqoI4jNnlpmcuPl)yz9ihDbbli5A10mKFyNxRE1USuzx(70ri9R9bvofpnVsnudCr(hm3RxujJYpBSoT0llNLkW7NNdhDpPuLRtBf2D79WwvwcgwBmJV6Hhmzd1xJR86l8VnlZU2MuSIPVY3UgRrCV636XEHE7wuV8nmfpszLmUgrAv4hXQLrr0AP6u3WWhwCSBepWhE2Cm8HPlNld9kkHcrl2XsCakvY(vkskazPx7DP2SIxma9awGlRQWzM)eEW8i4Nbnh07DCUQY8NMaJYNyjF3jDW)xveEx2zplNmNMAs09b2kBCeNelsZFxvWA3mQn(qTIboLBbyScW(kvVUEL1egyPKDFULpKxUU1K6OLxdgIULVGAQ1HcAp8jzLk3e)kE41qq9lu97ww(D5LxTBGaURNBXPx)II)aN49LgUUa8vJ9y4nk(p1l767EdVFFehO)LQIbowdjTbkIXTm8srRc4yCZVcSVtnkLbkTOHW1pl3Wg6DWdFOxkgnEc27Svvk64LBrISwMRkH5Ssxtkjw7Z18QVGUzQL(IbNcsFKnRu2biFp9mRd8YF22r(ca6aRqQTDqbSroHvh1ru7oV)TFbdCDXc6yNNI36uMT63u)(Vc)U8bxTAXKVAnKxw)uPcSUK3X1QQwtr2xhREB2mCVC7n02eJviwg)Lv7FqahvU)r8(Nm3tiV8ehUQ45kG3qDy5WzEkQzLgnjnOC5LvEAzCx7Asymdsuo)MCmLgMu8Ghyzgwx(m0HPxvEDdCTxq(dNRE3cajKh1RWmBGspvYmC21sbocu0TX0QC4dD(GF6qLrR1x0OR4wnhEN)NymuatuXHrRQyxu2ZPaFF11v0KP14dPY)n4ND56e(a3Lj822SlY4XF48b96Sffp8d1l66dE0kk6UFJsR0wRBPY3KWEBlVRqT)S4Z)wh(H(qAobikczL(FxgmMo2vyPDvXluAfvOM7quH3woaTm2Fq4Mw9nMEyymHPErjwgued72l)SuJb8Cf(4uhgmwg9q0NEYqs9ZOqGbFPCiGoS4v)1wCBCwqz)JPqY6UsY24kiRLkhBJjqE2iqEVWZLt3UirEDBkfYGw2ymTVnmTUWdOc(VE6y7EcmaFVQB2uWyU24zWPsg)D(XyVyeNosAYRYJatEFlsjRgFulQ97LFGivY56CZQ2F7u60SzKhRVU(uxTc(wz(23Y81B7MVBnBFdNX9lDmwL5KBVxOd7)9dnCQP2nSBV26fJvA1dr9XWkihkSFjnx(U)fn3GCr)8HAVz7SqdhdJxfGHlF19ENBmCLoSyMsx8(NZjpYF(EMxB0cjYy5W3x3j6D(PopNSCj24XzB)aaSg7)9WdsUX0PzhmqnN3NRdcOEr6oftw7Xk893llUb18X(adsZSFEboIXR1drcAUTdKTv7n8uhuUQR9kHj)PkVNyQt0ytICT1JOayDSEAYkKVMhDxxJYbUq5nJASfHMN5P3(NGBdEVNGyd)D5tTDJ2cYI2(ZTGBeh6)PSf8p2hRAd(x8Ht(WuX4AnTqlWq58G2clMl)lK5A0lSsvEo1llVTXUa3r1HQxmyZgK1soSBk1Jkfz9tC7i1fB6uVWK(9ZdbTbX0m2IBa9PDDQmoYLIMoQeMRAyllHy6bO8PfX0P5J2SNP5MqClMXs5Vn9KjusfR2ExtPAvQ3PLrW5VyGN(u)r7Pw2GiPoySn5cqVH3XA2sL)Z41t2030D6mDEYFPGlFspFV966Ubt5h737zChJvBUAiaOTeBZBH8EL)QwQDdNjFNZZ08zbG778k6w8igxxmb3UyYwCy5prpoXM8KRnJSQQIa8vzdUjky8QA(DrPZMJFsOyRgw06G19YcBC407Wlc8ASN57JQqXGEMN4nRTvQXS8uW9TfR0vcRL104ZPbQYJo5JY7AbEbFcIlPkwEHjkfTy7F3vadT36Y(myVngmk2BK5ARkny67kpzSRkCtMtCey0D1NDP3fuE001uwdYEt)HvLfUJNJ09dyh06O9DksIgjN3VXxge6EQdchtK1lGPbP3j3peH7O)c5yictJKPDzkBHFglLgMsxNFs40D4GfyJsq4EZjXAVxLYEbekMk76LFQBESk5HNB6fd6RFLrv3yPkNrOL7AVRJGWuiEFLhswGXqCQ3T2dNO27yN54lx0EXPpVTZJcj)OBLRSp3RZlAx7XdP1YoNpO3RSFr(aFCKXjg9fjjVKlqP0m(BuXJaf)RUjDtKjV8HkTTOIvUEZtNcR0QaSiRG)MzzwznRBPHXzQRGwpxlwT3kcVL0zSV7dj)XE1aSp)GYfcav)1lAc5WuchlvMav9qyqpRLTaz1AOtlBLbbUmvizmwt9d4IbL4C0RTefxobzBphTEPTZqF7DITB5qhvEaByeqnZ4onNzY7)uyM65GzQAPlTosRNLp2RoMjp7mtoQegozMSuvnEIyM84O1)HP5E7GNfgz7AQUSrvv5HsIfCiuk3iXLYy3JDlFIagZj90i)(fSEOX3zGYWPXm7KKt319eB1WK8vcBlTu36SflcUf608jJN9jtLAeLngCN0G9ZKrX0Ftg8)CZ))d]] )