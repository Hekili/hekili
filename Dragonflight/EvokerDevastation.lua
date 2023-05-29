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


spec:RegisterPack( "Devastation", 20230528.2, [[Hekili:T33)ZTTnYI)3INBQIuITSfLDAU(jYVjo25A603Lor(AN3Vyzkriz(cfPosk74oE0F7F2DbajaiafLSSV0x78ExJTjWcGfl2VJfx17QlVAyGFo7Q)P3rE9p6eV301RV3X9UAy(9lyxnCH)KV4pd(Hy)5W)9C2T(z5(5HjX43UpkXpabrwYY0jW3VjpFr2pC4HZcZVz54UtsMFyw48LrupMK6pnh)9jhookz8HbP(ZsINgfo7M8dzXZcJzhojYplB08KGLrSSd9xeH)VrSBt(clT7KflUA44LHr5Fm(QXwM496FuFyYSGn5Q)zVJF93dtOWGagVXSSjxneB8bhDYbEV5hwD9fXzltzRU(dND4fdxD9e)4vxpnmom7MvxhoD115(PZy5WpNT6A)XjlHFmpz11bHSURUE11ThgoFru40qwq3oR(Pv)Ke49oga(Nz3gMba)fdg8cE)Eb(dttsHrkjolmlNfp5(UAD0d64hbefBolo3pA11Wq8(vxVCbUuHrminzbmzErw(OKfSywkaXfPHjPH533rduhHlWHlhd7wX5HiOMCJF8mwgFUWHlSNaq1FMFySENXfqnZKmCXFJFEolnmEg8natTpGhdrS5zPm)8BGF9c4ZXWedNhaIe(l)Y9P4)8ZH3sD7drarL60(4d6FenY)lAyca0vAYC5ytOUEh1TNwpo6eLEO3Hjrm)yAKwUy11V7txuISGv9QRhhMRaQ(CCgSZb70aTyjAVaMcc53JeYRUoLHeli4X1f08m4Kca4CKez6uwkG5kjIMKSmohjKIHLfSRm5lWVKauzV)gSfWF8mG2xDc5XjKGzoqddF)C68skniVloCEsgTq(f)GaAwauhJwW)LoWqWYHvXSUxnmci1YWtPm8)(pPZ8Sy)XrSGRo7QH(t4hNzITRrz4Uf87ZxKChlDuEc2NHta0gSD7Z7WTSra538qKu4TdGTLvx)kCTgbR5UsiLnkBHFCxXyT66hEaW5lNoTBqXkPlqGbuFiuaG097pz11VeM7lyrrJUbqhWsTvnD6u(qB2fBdescaGQnSdym)byCcVp7T2LqRQDhNdVM3)TRZVz11D48NsdxW3lQE0zjYlj1p(lRUg24b6j)faVNjiK5NO50zzDVkhyj2WT463t9O9upc9(i3z96UnBSwih0jl9WfB)DYITpTy730fBjLY0KyGz80rZ9NfoPPyeCa76Tf4elisDusFeLCCdrjQD8yOJ5xnC6464rmf4WpAmXGVggeTDE6Zbzwho(Y(zZEupvoAEllD8YuKZ7OPOeKsKEjCEwyZyEQ1q(NYrw4Wki5gqo5ANwfsfoKVYQ)SRgQxdxdOMagn3dJhHnllpjDUeLVESMJ9L(RzFXBxVVSZysq7mnMpHBe76xywMDoO0pLlLPZgW(O9ZW(6ZdlQkBi1YLYjtgblQa2u)Lr5f8PK97FVegqvikpnjBWsy2ElZSjUOlwKW)xTJ4NZI8bPYW3aZcaZfgEj3uH7twcyB84VIHcdbJkoGlVo6EuFXiW8juNqstwUc8RU(UByy)iiCh95Z)8bN(HZo40Hdp400eP5wLKMUvTzpKJssuqYDXDZkuqFeOUzk1kCx3gLzjp4Xjzze0MIMLns98z)tSTRLa2Kb6AwI3U1hMKWxXFkAjk4voJQsXyGD)vrxb03nOA0mecC7naSeGUJzFf1UoTury02SXaY9UK0VqAbZX(3aFAU)xbv2bn3hZYVJHDN(ZQ9EsGqHCa7dBfcITmG5D4S4eUXnV)8pdFb0NFcoJYYdNJZOU0cDe3SyCAnQeUiA6elOjyc1e0KUu6YdxhivgB2KGUeSQDg86TFgOCcuB4B2a)9ooqnXh4hW)LrOnjClteWjhq2Fb0FfbWBmaGgnYhHtB3XEbDulcMIb3xSVrBx(62HIM1NLVpA(lBcijoeTbt0(5KbAWHswu3YPz6Yy9zzgm3MKBOJt5q2vJFLYscuLc61F)rTyIRyg9ZWcYunrL1eJ2G6DKXIYTU1NceTAJOZzLYO4Nqes9CPgAD9nlNlLyrkBsY8X(vLtaqlldzlcIDbocWwxs8VZSj4yJyZjOG7M3Rli0BeO93iKrTWYWN1pQEav0Kr9OVKztI3gS28QBs8S8rBRnVY1MdXtHtvjsLRVUgihPyuf0APWRLPKG4vx)DkczvePv2aqG6r81q9T77w3iXbKPzgNZMegWqrIHtUPaeCvow4hIQueIm(k9x0(OJVytrTnajiZdJxI6Krc(6v(7fSGTs9KDF8eNuiJyrzWpFu3tkiz65skOy3WgKQUVYh1A258CSZ59STZzDKk25Qf9yteDdpi2RByw3SfjHrziFSyweOYu6stnQUqQVcjyuUdV6AcCCnNaUKl85IBi9JKRgU3jP)KOF7Jo282qYzKyp5QtvSMlAo)mCyos1LGTpR7QR)rF(CimohutNuMAEsa69CGQS9KLPO7sr1K719KV2HtnpdeLqD6gqzuSDLUVf)ScOKRmyGUeNcwhLSBswgHZDM0B4O6FzATUCecrVF7NHOouD9aM4xHH4DOcPqp492xDmiv7rlc8vozExi22Ku5pfJMpGK2YJQsCUUALLh(M7hV0pYMYvBajJNtsgBN8khst1X2GHKOstxo((rG(7rlgLDdH1meDbTb4Lb2lIuHJa8UFAmqZokCIa6vWhSVojAzaZM(vBWSZRbZoVnE25Po7QOP0gYbusoQYdCp84BncWCZJexzRJd6AzIEOwdW(oQ8JDiduAtNI5Hei1QuCLwAzcXpA0H()pTYSYQOYd1AqJNvMkv5Ew1tzwPZwVxbLLNvTwxpfzVUhv1RUA8X)m5gXEfA6lAl3yay9eoh4PD5No)t)aWmAzuE4IOkS8OrzmAECVU9r3rKbnmJ7hJ5jOnibyWfjoyxC2hW2ggfOXEiT3iCahHJhTwTPMmayxRwjCWivLYwqWzeQTFHtDgEStFcqtmUFaqU)OtnG1YnaPaj8sA8UOHlxac2OpG2VJRX3LCrxYm2pqXZBokfbTNhBZXzSjymZyZH(hf(fMquw2DmqQYIeu2hH6cZFbk(KLEpP4ejziePCYGP0u)uAa(r5CIMjCClWRnMcuemsjXbzCbKJzZiJRXf0y0GfU8UOKmU3G7ztx9nfbNP40SHaeFQqWdVKpNn1bVK1LWPL(XtcH)1IdlLEfTWBNsWuUAzPb(qFzZhN6pHtfAQMPWsWB8bMeSGrjPJjB9sidKlbLRgGG0u1SkRHAMIfFIGKPeBng5RhyruWY5OkcEMIJ3aSBJgWQi4CUf5wIl06zTzECMIcpV14bnYtgVBsoOQbQ73xcJd8fbUhvt6om83FAbsrYvucPjXtktPZuiHhrP6l0tCwuYymzfKbzpnx2rFmm(mgYzRwgrwm9xHCr1HQglSD)SSCJ1MXilxuNZRv8iN(0eACaFkHBaV)C5ihNGseM5NgWNSCUF(tzOQWfA2ppzm3tGN)ld5CP4Tg5rWHkXAq1pQXiCXv7DjPyJYMatxqRg0)S3JILihFZbGUN0NLuYdnkb0wpfhImKK48HO)ZHnTWFNeXds9(umsaXfhIWryrHWr2snVJOV33l7vC9XzXue4y0pgiegI(hsYWU)rz6hXW421LixYtgfeY4oqVV36DF(r28pHCddKytoJkBcCa10kU)fgjrOfcRIiJ9jhKtINa01SzPjnlcbM(NB7I9TvpfJdshBw9RTwEpTdO7I2dOJbZMvyavgAD1HJJ8)DIeao5LIBojlZZixFGuApAQG3SzebYDQQUX2mAScCOc(xd)vOAPHVZjDDl(OjNjZah6lZaiTWS2QmQE84MrysTWSwmcQkZvgwpbsFehN3KE6kBBkMoUo08MgCMH02UIt1nLoBHcRIBZ))mez2W160gUO8AB3VwLHVTw6Vwp3ewpjeq8iy4kgvbmyjlJLJfQQZpJVLhldamsKqYXP)s6YyEgbgohunMOjaGKNUKap36Jp(I5OFJYwox4ZnKroUQ56sJdqmNaef7IWNlHUeKsflirLc9haZbJde0XLM8H0vs)yjTGzoNif)misgHCPYjOjj8GtlpeiNdkwYqA29FzOiBvIsBUoQzQsX1rbJEo3yeCwfKWYIFb8djG(PtJqndV4S954gkKV3goJout9LRBtLdnWPn4yiARFAwExkjmjQelFCU)xhjAGbF30j(XSr0WvO886IZxPqpsP7YTWYTn4t8SOoZLHeMUss2Qf3NAQLhpHuJsMfw4IXBtWKxncfyGS14T44lFv5VGiT(I8zyrK)98OFFMK(MbGHrUgGZqBm3dYCF9MXZXwBGIoyOdVmuDoUZthNGtUlKJIoqPnCeU(5fAKoNXD3HYQGVa7DYk98Q9mZwaeM0CGNvnsDHSybLcUs18jlQpHCHoUG5QO7t4z07OXuc9AyaMfAnH2zYpgMIUmFcVba(qkmvmi71GXPDDdLGEU2XYidH0hjX5ck9RorTTI5fhppkmEkicorBI5kHM6iuD0ziFBcroNpGoD(Vj)7)k83f5K3cQJiTPjfbLP)0w8(CICSrsIzxKzknfopzphY2ouIaTAs0XvzV1gS3yLS1Qd8S62bBmZ(5piXiGX6l4wQHng1Sz6pyEShtrnyBy)IFsYZyFD)JDmQDenjfyvWEO0iYgNa)f5c)5Y7AxNAElgdlzJR8l1LmuhR0EXWpQC0vuTLAHy1ZXuzMNLTEqx8hjrpIFgL3qAh0ZQx)QAniSppvqBEYLcgYmqSO05xF5gmmfrSVswvcuwGcq0nTzTYTvjknKtps8N5Hh0r(fEsjrK7jHn3eQTi)Fsq3Uhiy7heMHXOBwkLaTIJ8IRLbae4iqym5iESvPPlxKpcJWI4EdHU3Fsu4cCFQv1fCR8q408Pd8A1o1pmye7wKgAoOOb6nq4G5PEp8a1TBqLpGEGzZiqxC)iAGnhkLpHdy7QJ4dpi32dytdNeM)2b96SvtdT9sOT0HTcQxzdv0VvbrA11PBX5)It0C)zf7VazK1(lSV8BDOqaprO(iWjgjD)FxgoHIVkqsH6Sly6LzrqSeyvZ42YdYwDxREEzdgtnMylofSmJLwUk9)9LPO)Xtd)IWrNYajBZBNAa934E6JcNkS0sfXKEkD7XOLBmE48wYH5CPlA6TVmJBOqo)q8Bh4DzroJt(HJBBikIH3BUUW9EtgN)xeBQORN)zqs35jKYs8HN30th0)YUfod3wCF3ghgDkx6JQsewG9iCDRWm0PdJA1SKw1C(vyJ3Ri(1VugKW1MeLihkrAmsDJN5RVsVZwZ)r79SJ4(p9M1NbTyE2EKInqw2rQX7ZcctGhhO9CU6V3KDX2p6DHA0KOVUYIF7Vn1rrjzJauxM9lgPbqXOwmswJMEz(JmGIxRJqUlsra5uXEi95PGHbvL7OCJBfg0CARbRXnhXkV(ij(Owxt6Dut8ZuhtdqS4PQ1I1mt5TlvYcjPyhsXakXGqXrYeZoq4FI9LUHd9ZbWvnGK0KjLsH5jh(3mZuUU1fufXeW7VoYTJoY1RUJC92QJCEoAuVMCKZBnh5QKUlR7iN1eO5BWJCE0ronblE1gTQgimYopnC(LjNVRL9Q9njbm6SZrH1Xg2sM7NqXbijw4Wls3TcMuYuFKcQloJLA3r8Ts4(sd7wXkF11Fs4gHcFTTEOX9FMgCSfcU6yHvls2yJY1HYA3SFE2OkszXQ0X0DEyTA0J3LR3nHFg9N5zMapBFWe8eugxpfGMXVF9OagKX9EpVgEB3crcp(6gA)TPIMLZoxa)Tkx6td7lr7EtawJGyaTB5b1cd88)TaMawgnKhqRxsH7jBrykY7vyEViofXmCBpJYmQ87y(8B5fh(zDZYF1Gd5j5e179dNoW(0)T9Bvq6YN3ccyWmPw7PVCQrhGsxYBq8SGc8W0sx8Jg(c0jVB47(LkkmuyxlFWQ1ti)d88)7450JOMzimWunjpAsGdBs(brtp9wiOmR5qzlxXvKUqtTAIkeKYkTAIAkynarmHQpxmAs0aNLYyX1XW0zI08zwK)xXfVAz54IyYraFM9VxcRsKYd5AmXpMhDqweYYIUkO(0v34MqmFBaMHeXZY4ag53G05ubBjjoiKiZbe4zrjjbrlrfybvY(fEoG(X4PlZGgC4Vs5JiQmm8F5342zm)0o7GayV95kZ3g742sxGcPH1L0nxI5BdpznXseKTGzHxEBUlAORVDzCakAXfN9H9fs7VlSilEUyy3gBdHMJTR52IV(7dEhD09AmiXy3qpIe11QwnXUN1pBBTUfTmKrMHYx31FuEgnwKNrcjlW5h6wC7Nc0ZOXGImQMFLokscTaUl1UHIm(Iq(Ul)i4YfDnbsL8iHcDKEy07Udop(eKqjTxNsxAgq08SwcNU6A0vxsl9itYdjyYavbhNeVmdGelT)rJoEXeLJt0zTnmdwkCa5yjtyD)sYbxOGzC3Yae1UOFBAQVua7Q5uvNcKAtwQraDwosvmArciLblfynD83BDlVTbx2ARrjDmLDZtfSTlftU8MumfsgsjQlpBr2VWj6OAGt8xi9o07Om(y11)kLYhF7KujvYWT)I92FXEBlos(xS3(MK9MJsTGEqi9lYyprrSKFrIilmqBVWJBL5yMFSWVt)dkX)55ji)EGXpFXVaW0br8cbiZ6(PHcFDeQLzI4D)ys965xEc9oyQA1y0khzA505iM)zv0AHdOFLtu8lfqqxT)sNQ4e8hSoZxXdYB(GAnHN0rP2Tj6BkSAtrCUmV70Tg1Tf5UKWnneDoxGtpU4gp6qr2QIeEfvkGNUaz8tvSVgMlvjWdTSRjbqVoCB71PJWbwBG4JDulfqkmE0Zlct3y9TYe2zkySM0cYTZWotMfk)c63T60mWA5V5X5BmtuVvxmTn5AJGETifBeovSiBhfQQYZ)oGtUmdIn2Nvt7nfb3BAURPk20EFDV9VwnI5cDnsmkr5jZAo(irFwsnubARAIEksatBz85QIkbMuPymIeMzumYwW7sve86RrFPUt(tQRwZGZb8XVL94)YXi166JZPSesAsWfysPrfByuoFXnxykPGTWpKycOXrx8OkXngOf36GISXM0Y)9rOFSeDVoOPCVbcNVijnNQWDJxMto2CFm1UNVsCjicZ(bT7oybvFl82a0v5p4lVGa0UfpoCtOPur93O2LG7ugCV2OSN3(3B52fxT03qE7aVw7ztx1hEqVHN61P1gNrI71wrnufLuBjuZSuJ9op8GdNUP8HklMoBs2g28KESybyzXTblPnzYvEI0PHd1e1mpfJsAqAtwBjQt9KhrpEP3FhiN)cJjYtAYsB2mFmniZwUapwqcpTFiTV80uxJZD6hBJ1lTHUp4HXndtmEQM0yyA(PEO2o0NKyO)4CwP50knNqEhnGAH(9zG(00XrRl8L)iDXV50bI0Aq13oiRwF5fh)UWyyZoBxfpBkw0UUBtUVpEuwWFo85YRrmx2mMzeXChf5heKjDVeV2Aitb3W8xitomHLY0RGqzeC4IUrP0F88UnBPAvoTIdlu2DXjgFNfZqkHC(s)iLeF)xhXzqO5jjr0xCbOxFKQwhUacf0eptZoBYcuay5fre2elVAJgQkx)2UgPRYomoXmnQB9Q)JxJSpyKy3pjHb3UA9EUsvGgLc9vUOLfQ27lxMeaexhgqXuseYVYlshGidEv6qCvAuBYfZzP(0fbfRtdjZfF(JPHbyeQd6IXpwARBPuGIXxhn3WZaTRZqjK8TquHrzgPAdy85)iX0VRMpjvV3APWAr1BcSVYMSmNv6xnXXMnSJwhl17iNLJ8dukx92jHqcMATWv5YkWLGlLc7WG5CjP46sVP)rkvdKhI1nQmzoXsL6J0q(TIxFhVCen2jksEi53nRymktbrXyfVnaytlFSE6H(UIc8BMi9E5APiw2VGL9cK1mLhfbY8)XFzEIijFfVMnDx9t)m9wT0dmD49jXWarF(fYamNRwhlKpepw)OKfa0O29(AN)qdzVNmi3)5gYAr)3aWwZmGs4U6NSqyLLVzewhBFAPDW2yAzvYI5Y1bClzPAa0QbUYeIVENJaRfUvYDdZDDx52X3iW)rJx((D(oOdiw4n)k0zgE53eEVXb8uI2SjiTeiAtO(335RBhqCRx39oAxdqhSQ3Ea(uXwPNdQDDFqAaz7oO0e0EoWQkgAyaxlMG88auhBx2SCXa61zCtLHXHy2h9MONHSWKfm(LhjJ7NNxSNf3s0EpRACQ48VBROYTQNbROUTWlgo0y(uvTL78WdTBCJTaxHA1DmCx0Gb9AzFvjXQ)zbr4ep4snNIN)GxSrA7uHIwCXp43ul(0vwSSlOS1VoxvAu9AMU5dGSA9UfGEoMB0P3x3mVSj7wG)iM1W3Ye10K6M56nB3pipIvaLt61n3Lnyxc4hX8fD1rDtxX33HG11KTIvrIU51KZloA0UEaEeZDxNzS2KDlWFeZ66oR4Sz7(b5rScSFUXsd2La(rmFTEYP633HG11KTII7fhZRCvFTCu3wBEsb)tgG)p08UIQWUU2PTAxh8)UVZ2fwt(1bhPOpOLV)DFxDWEWrDKlXTCY9OMBRBQvGzpX55J1VLzVnAue7AW)Kb4)dnVxpLSxfIflWFNrjBb21rj3Sj3JAUTUPwbMTIppky(y)fVXchiNnuJ2OId6kOnA4avtd1gOkEUtDfz(K1yF5yPvnFiC(I3yFSQR5AdAfp9PIax76YvRA(q0811ABU2Gw1JJpsUgp1WVjqgt20U(X3pkyrwDq3v7A6kOPJdYWz0wa)gBit9wkTlgbxAv6e2BR(tp1WVjqUz7RUBxtxbnDC2o6NnWZuBj9ZgmcnL(PQhJDQkQlj7p8GBz(1l031r2oVSDVUN8khhjGVAzaXhDRoDoTD9km7At2Ce7T2rSNyeL4)Nr82Hp74TdFcWBLKKpzH4YbGlYTrdGw5ToQcaDfH4TgGocK72dqxrY9rJlDa4TyMsbHyAsuuYD8lBiqlHzFj962ZZ2OIRyipZH4pauusjlBhvFnMYVYXLToiaBCGFU)y)m2pS6N43SS0WChr)WpbXgBqCpCqsTdsRLkMtY78JiA5oG4whlAhu)pIz4ttEh4kQ(Lv8DdGwTm(3uqQDJCmGQ1QU))Xb8oi((UsYHDbODePCXf6XaMgLV9kaZXbazr1YaAM1q6sWzL1HqG2gM(HUc(JErL9f2nkq5ZAlu3aTqsUiSYwaSLM8ec81c2MRLEJSg4Xpm1AmGBWVDwl9edE3a(rZk3vqu6vpHDLp3qGUwApRn5je4RfSn39fnIW(Xpm1sy7g8RNYRbUPAxdE3a(rty7kGvBh)VNuGVoTuFeybxb7y7oS8Kc81P)7wHfSQcW0XVyJe(7kp(VDhLaZUYM))OaFx3zGNy4)OtW7NU59QF6Jefhc23OBomswD1qGA7MK0RgomC(7VAiW6FAyuXnYjRBr299QbhogVRJ4yHVG13Gx77K4FNT6NS1wPBB2hVdBdeN2KE0AFQW5pqxcVUxjF4blFvKMnw)2TLjXI1VtPlI1VWTUV5lcpRlcBUMVC4QMRqw)M1fHzoVy9l8fXFdVOQtOB53D3esf(vEt50n4Brq1xIG9XI9bBkJxBAMhgVeRQR0LWTx5Vlau2MGP4UQB)KfdYy5HtfySE8)DelkJn4OUNSFr5NDW6ZIHNWmSWEwmSjRxVh96TsSUFcJdV9yDterxiEJlWB2SYwp)bVy11JVNULZlGzp)HfLvEBkxv(gEl63(4RQfwt5d49K)oBjgrLMJR8v0ZuKSg03D11)OpFouCMcVOIbHtdrY12I67hENs719KV2HtMplu88NtVzhPi8KVab4NvaLCLbdex6STrr9zoLlqoGFvGvAD5iiFeuZ4xc2aM4xHH4DKtkXBdUyrvogffte)vQV(iuHtiv(tKllrkm5zyjoh5K3CQu57mqfUW2tyGnb0E2bTRCrytaDXZQHTPTzK6v5ZxxW13KjGNJjG1ufqLh9UAciPXm5V4PYFPNc3LNOikvxG4Cy8OruESjRSHbxQUyY5WLmgdUnTnQlotedXp7h)fsCOOObr16qQypqxLD(94(YpD(Naf5MVmkpCrufEh96EKice962xwnefrnLx(uGzTGvWfN9bSTHrbn6qIA1Stk1P7rVKMJJiLgOvXVk6Kyq4pEBilrXt78naML4OllnsIgUCbmU0hW7WpoFFxYf83y6pqpnIZrwRmXdl9XzSjyPhHnhlonHFHj4VNDhdy1Uijx)5T4wQIYdGNyxgIYaYGP0uSE5cdWpkNtkLzgEzz91YIMEgxQXy2m6(1JlOXmEv4WhlpoznJ)O57q((bSP(Ww0GJXtCW2flFhJfhE5MpXYYlMx96RmXScg9BFe(KviSCqlKDTKMQu8KsyfAyqzdZzZ5tQSB8HtHSGrjPJjdcG(baXExlGSYuynJMAnTa71EnRBnDjBbCfaeaZ)EjE6w5pSe0I6wwKqfBQGfVq(YSpu8(ttLimFKa1FmvylqIcSG2Cas4MLZFpgIy3s1td(RF(cwmJtev8EnEh95Z)8bN(HZo40Hdp400eX7rRYecgD4NW1hXkZ8IPvWLS6Z9vLkG0aVop8awwGBPvsGFB)tmO35fpngYGHRCiN2hlKX6LekSSuHQ6Dxsk)vuHJoqUaZ9)A48L0dtE(DuDIGRpOsVNeSQOc5LQvN2cNbCjia(E8meB6us7l5tYMY58khImQ2YcUK20uwwOoAmOGdHWQYeI2RcPh49szL08rcFlLh2dka9F7VH1CfSwtbYs(kotW35dJhZJmrbi6g29VGOAV1pmIVtdYoj0SY2cbZYPCib9rmbWjbQ8PVE5wZbfk)sgwTYSTN11N2hS8a2PGknRhpA6qLre04lQ1Dm(sosuuMeez88jG)a6xwUNqzR4RRYnmQ(NHcTfTN)6cbhPzrA0EPlJRojMoEFEfbf0sdWkLdP6ATzZq4ytLIY(oAwYYCnl1POxlGqrOQqYGRJ3AbqgL0fa64DF6cDxx9)JE)SadnqwQahMaFSQmYq0smwT9xD9NwGSw4MjLr1EFzb5czCqsR9fwjolkzmE6G)OcZLHZ7i(ObNYWJqNvkTbwwRx1b(z1JPz)t9uX48aIQTXwdpMaZMHmz1vJ)yeihaSuLYFoG5ZjUkB(tzifwHn6ZtgNrYZo)xgYvTI3AuNhoujXAQSSJPcFwejmaBeE)JbKxckk4(XsHECaOlfDwsPIFYce(5FoBhu7)3SNAiteUcRzs9cZYT)Pd67zxG6r0wW)Q455H8wb5DosYkPHmS4NnlnXCq1ln1UK7RFg7Td6)Q(Vu6SyTKi6HhCXPLBWdVUHPZg8aIMKxbNOnfQy1FyLhSHIkngsp8O3R2O3PbtSMDPbaJya)1EVkHTrX(xdHWNw8bZZ6aMSqdtr(p1PLAHhvRK()2c4OAZMSGKARu(BVhIB0V22pmS2igFJdAr1n6kct()m71UoRuUTPU93UgfcDtc06PE3(rSZEU67jwr9tgLbWFP4wghtBOYYrc6YYY6rcri8XxmhDzz2Y5c39I8QW5g3ywCaIRwAbvbP27rVqUw5JfHQtsW9wPluL(jq8(mIFgKHqViZfcnlEvkQuEdv8xajn()QcB8Y6bjzGzvAefbMOzCCRDWrmiHLv8a(mncv54IZ2xPKgsPxi6FcSVcbTRxSnndSutZFRLpuupZv4)OKAJgmXfVuKY9HsCp8jrPC3C(PyzmaQFHkW5IsnmF7vjPhPNciQfhF5Rk)fCH3xyCCXdvhwBZ50FY3E2loJFOFmp4clLvlDS6hAdu6pnEe8Yq9d4(vNxoUVqok6avuwUHVLxOId9EFchRuwf8fyVtwvPQSR3IurXExwJ35IFnXKyXHxXreL4nt51No4yGfKOzAjPPWEjZcLV4pBRUUaaApRqQTDqbKroHvrTMXs9J)0b9oPt5SovllnBzVK1lCQAfAk(rhDYQFt(3)v4VlEkIRwT9RwK9ffHu6XJsq74AxvPPi5RJDVnBfcye992b9BTguyfAbLZWybCLp9fVgcII1kzc)pyEKqKwRQf2E(5P919G6XO0vA0eOaq5Y0isf0a)fcFoj6Axt8IPd6ki3eJPqdLYheclRqrBed7OYrL0MH(wLx)bxhfe)H3kFxhagKh0RuFBatpvqlCYLc(nmKZTXYs3lNoFxJDiXO16Rc1vku5CVS9)KGEOiq6omLYSDzfEN81(WlRiitPX7t1tCWGB9cp(a31D8220nY4XX4Td61zlQg57Rwf3h8KvL1P9cOfaan(K1tq6VTdYK2U9xyF536WF3tekpamEqkN)3LHtOa7c7KRkF3LRiW08aH44GCaAzCCGMBk1GxQUsBct1sWRWzigQQlFE2tPiuHUzgwylwefor4Zw0wEs3r1OGWqNUO7pN9fgTdAxAZFnajWRCyjP5MOur0ED)(tuJbvLDBPI1d6P2mBM2ykPCWjLQ9OpDAzYK51p8qZA4B60y8JNn8J3R8CzRTlmKx3MIGmqLnEM232mToVcylT1CVag0VRxdxcgR1gVcowq3R6lcDIEGCpnzby2uUg9oMFeGnKhYxrQu)thl0VvQ(VjPVfEIvFFjSiJVxrCLQKAEf6qT7oO0PzRipU0z7kQ0Y18TY6TVL1R32TE3AY(gUI7RQVw1v2A3CpDaQpMJJcT3jiYD)bQgIBKhN20I0Ej0PIapEKvV8vwTbgXIvmWy0sF3eUQL)CifYcEIaGjefO3HE2baNJ5UzymdvOAVYrjRAmPFk0wZHsiVMwl)3I)cSsqv0GP(LuMGKTimfD5TqXnHdmIzLj5D(DmFEOr1wp8q8t9gNZ2h832V8DWHRPtbnrFH2XLkaPbE6pVpI0sMoD0SjbC2DoggVka7VremOAtLEhq(sX9UHV7xmgoTW(ZX0YRiNaAUFL9uJ8OgqT7MpIMZD0(Pb3SKM2QIdaBz39F(bGP61f413ESZxMOcE8h1YvKcS7(UpZI8)ksWuMPUGYFX5y2Y8z(vga3OWZlt8J5oZJfH(oKsZaFk7F5VBtyqAXnTLXb4b7yyhXNEOAezkgS71(m5RHf9cCAeP4d)vkjDW8PeF2pqX3Wjt)0o7aF(UTXIHig0dfZZ3weTdDjgchEkiHVkU2Cofk7G7Mbs6rPJgkAXfN9b04B0ty3fweyOlg21yL2S4)0UTdPwoft3A9bCV6t5MQJYR(sC5og(oLrABsl8sexVprWX)Z3lpEJ4(T7cOvwU94zTrHFOvBBp8ya1jrY244Ki9GKY70N4pvjVrKrCBtcQI1qOH69v3KVMNbCxJIJuDPZtFuJ4hGU8MumafdPupGhlcGJZ5jfbWyI)cPVrEhfcHvx)Ru5rWG27ziIfvId5FDE3Dqn)RZ7B0XH)SCE))Spv)g0V4Zg)(Gos1QBMME7cAqBwP7YOzrAp(kRyLxs9YYl7UlWDqDt1thSzdYArh21f9jfJS(fU9j1PB6sV0CXDZZGVbY00H7Ba(PDDYNoWLuToYC3TQV81MyQET)5DITgJQ1F66BKOgUH1Q5X5MyHDf8ujjrryyA2lnFt27lhiH4HMg8qjt7QT3fgVwfC60Yi(zNoWtDP)K9AXBGKKHUUEpwMQhqBQPwIs9aVJQ4Mu(Q6VE)3Rzjy4VIhvOAF2FRZ1dG73AVc3BWs(P(fRhpLzvnYgcGkNJiQR)q)AUVtP8RLoOH44VXPMB(QaM7pAATT4zyVoN7VDbxPm7CEMEE1nPjxBgGwvIhyyy1xf9th0dKokTJw5Dde9uQTM)6JAzPXD285Nak2EmbBT36EB0DRTy5lD(gOK4MPBOrU58hMNN81Oi6FwENaD(qbAMxtC5jwLjyj7M(n(1KIQveySOVNBl40WSBeWkg5oClzLixvzTKlFzgxF6CoxeGL9LfjlcD7M4muqImEV5j1DV3KX15oInv0vY3FcVKYhEEtpDqF1RTT8Mfwjy0wQ3fUIAJjtM(s7rSaJr4sVBTrzP27(R54lidE1XVSTZy6inoDGWkZx615v1hpuLw25Td69g7xWyWKcHhQzRul7juk(J)nQaUGhgL3W3arY8VVuAaY4NN7cu4(fsTWcDe(3ml1rRzFllkjxEvr75meBBfI3s(923DAG8uVBaA2UNEX4q2F1cxsbmfWXs1brwtsg0ZAPdruXu60YwPiHxQyeegRPgEC6ankh167szi7fT9TO012o9dU3r2U6pDKmP12TRDf3P5etE)zHyQNdIPQvzX6qTEw(yV6iM8Stm5OA04KyYsLT5zIyYJ76(poTqBCmkCOyis0vbVrzLXIYwkCiKc3i2Lch5JDRyHS66pj0eU4(2SEOXDPHoCAmXoX50DThYwDeQyNW2wl1ToBXMGBMonFX4zFXuPoTzJa3joy3SyKe9xLd)Fx9))]] )