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


spec:RegisterPack( "Devastation", 20230528.1, [[Hekili:T33FZTTrsI(zrvQqtAltjckL1jprDLTLCwNAVnPc1MuV)ruGKGs4zsaUaGswBPIF2F9pMbyMbZaasrPyFNR7UCwed6z6E6F39m4YExEXLdN6NfC5)07qV(hES3B665DuVJo(YHz3Vm4YHl9N8j)RH)rK)c4)EwWT(Pz(zHXr4ZUFES)uegPXRsMap)MSSLP)0bhCDy2nRg3Ds8IdsdxSAo9gts8NLH)9KdgppE8btt8VooA28WRVj7GGORdJcoyYC)00rlINUAEq6b(lNJ)FJcUn(tbjDNSC5LdhVkCE2hJUCSZvE6YGjx(p7D0p83Gfu40Pb8GdsNC5qCWV(WJFT3B(P1xDEu6QKG1x9H3DW5dxF1e)O1xnlmkm9M1xfoB9vz(jxhKb)701x5poEf8pZIxF10WGUR)L1)Iew9ocG1VhCBykaRxmyWl4H9c8FmlobaCCuAyAwq0K71Frp4f)iqxcweeL5pF9vddx8(1xTAjIzRVQ90K4LWC)I0SrXldIcsaiUmjmojm7(oAG6qeFgUAmS5eLfIGAYn(rxhKYRfgUWwaav)R9dJ0FzebQyLaaP9WB8ZYcscJUgEgqy2hiBHiX7Djb(z3a)55WJJGfgUoa6g8l)29j4)V)r4T0R9H5apK6Y(Ox3)qAM)x00mfixjXlKZnr66Dy3EAVXHhR8g6VWK5b(r0mTA56RE7VEEbXcW61xnomtbu9zAgSZbBSaRxbzphMc(23J8TRVkja5nqWJ4fm8uqWaaCgYrmBwqcq5k4zMeVkkd5BIa0c2vM8j4pIbMQ3Fdoc4hFhWQRUG8ygjyLdSSWZpJepsOj5TrHlItje538NoLwfa3XOL8F0bMIGmalUU7LdNdSAPOqza(F)NKmEqK)45btV8Dxo0Fcl9gi2UgLI7wWFVyz8DbjJYIX3z4eGSbB3(8lCBWiG9BriYkCYayBz9vVcX15ao3vcP0rPl9J6kMR1x9WdanF1SzDNMJjDbgmG7dHcaKU)TJxF1lH1(YG5ZhDdqoauTvfV0P8uB(k2MiKfaavByhWy9dW4y(D2RwuOv5xhxd)a)(B3l)M1x1HvhLeUK3lkl6Sc1LK4h9P1xbB8a)K)YLZdNGqMLOz(S0UxMbAaB4wC17PE0EQhrEFK7SED3MnwlSd6SLEiY2FNGS9jKTFtr2coLzXrGY4zJw4FD4KMsrWjSR3wqtSqi1jj9rsYrnKKO(IhbVygyRmZMocnMZHxa6FiiIQYtZaUZWSxKsQuxeKMUpIdzYF8Awpe8BbO9I9KEo8jqTxeqc)8OSBcgnlmbSPrw(v3P2ZPC80a6bP5wHgb6utgj(5PX3frdlXpCk4TaUrTi(wYyw3q4rNcYSf0f3RflctfRoxa)esQPfXLqlNBGNMaR8lhcIXaZYSrxpzkPvvUcOryqN)VfWeOYXaVfqwViCraU3hMGwKNJ)kqYXf66RIcq2U0yCez3f4)jIOZWpTBA2RgCqg86J43E)WzdSV8pPFRjXXZrkOyDlyapDq)w7PJovi9beXG0S4KfMmpGBlODD5JrtYXta(K3o8T)MkXL3EJ8xIdvmzM81Aq(NrRSVnAsirYiFle(muW9uS(M4dYp8FmcnqQo1cjBFgwJMHGstlUCFvFecotXBRWYQ(Q50wnjC)P3lToLpaeVhnMCMstx6r6WrxMw3E6HIfeAzOlT7Nfpc8wL1L03JvtndzGgP(I9pKmjH0LrS061jbGxZWwWXo2VvPXABl)EWC)pB6(Y5rzj3J(i)VxfYUyIAna)TJIjhRMhctW94)YFc47D2nHjaec(CgX8SkAAaSTgbSpKJTXrtdj2CGa(U5XXtNVcTqc6Z)nu9g6i7SvPWao4pcWP9gaHH)lRX96a)KoOxwNbE8hdl6fH)hYlpW1RFncxet8rOH()pzvc7u3mwM7UW5OCi98(EPWeISBGB9OVEb0)CkSOqDcq0lOR33GHu0)Wuv2TVm2XXn3FWXMBw4ssZyki1aorQVbFr4s0BtCxaJCIPu0(4Y5(3tAHqBKSZUKvsMmHdlFeN)UpamaXWKKChf2ugc1Zh2TKkbRU0X)VnYOS04oOcB8Qe0)Dtb8o6KB1DfXmUN7DdCeD4zQD1JYao2NM6xTTQdP7GYYWM7FRkLNCOB80NBzbKFG9hWiscWpdqAjlnLExaY2J7F3hVcuVgh9ImuE6waeld5DxweC1YUMaz8C))dTLdMUtiPdaoqexPHtdyEKZ(9U7a5X3SzIJnXUGglMn974U(T(jOYRGUrG6Qrtvu6DQYdXq1scaPkYKCMPtL(YW7m5kB7w4(ncNoJrmRLl164qeU9HrhQW1PmfqSJJghhTkfMLGK(ho6OLtue1i5q2ZrIxqtfuokM0BeUtrOOI)WJLkOjU88FMbxOqrTumQvX8j4BgXSnB0uAOYOtUe6EndvNd8GzihZOLXGfimDknD(3Ro0BBOLT2Assht76ZgJQgEJd9(gExBQ4)MK474K)GPsA9vV)mqh(zS2a0fXj(lrzsK16TWFGPu5pcVooPSsDG2cIPaN4kW17Uu2ri0WYdx4)5rIbyiZqtXOBPzqImaY9JvP3Ziq7VP67BQ(QxFWgkU(nvFFrQ6dCKf0o07WQup8N(HzIGif1eat124akYemMnuumfdPLJ2oI8GD9v)87pdejJxnFkoY0vZZyzp4PsH4Oyuzt014WNfkYrcGdk6cafWbtQo(GcP37GLQ1Gyljo1YzsvCNWkioPjtrDVuyvoiXVuab9WfksgJtW)66c7ffY38jL2FntLLoj1ESuFrrvBkHZvyHNU1KoxPrEov)goqe7P3H4ZzJr9ytrEKqrQK1MDyygy0kijLLQc(CyM0DbpmIW0ge7xv02215)WRToaXd7q0N89NCfpquyGjBrcP6zM(RVuwWfBw()NvjOD2KWpfql5TmjAVJrCWNgmFDv51aoxtYmkA0JlNAMKERPMQNRCtvp)6yjYjsgjYfs)TWn2LK2zqtovw7YmMflnnd3Zd8xMpZPkH1Bzxu6sWEv(UU3(R1Bz2OR4XDNgmlCckWrvvGiFUY(ZY7tCq2ws19eTbc8YcdyZaTqXY8ZlkvovVfrPpj)MzhM9o0OsOVJvl4DHkbwKs)WOr5jn2ivR8Kpsm3LvjpHRW6OXubwfKJb883YEn5yksLPm5me1Ydx4C)e0b93FJpANh))qLC(ZiNVf5VmleNyKCnoMsZcfOqloYHWukuckSbaoZX8FjE9QGgjBUiM2haFBtWY9JODgLq09XYrVG82h9aj9NY9aMRsJGRhwcdh2v5hODQHdf7wXCSh0sAMm1DvIcW(hsiUCiOdiedajz1YSrHZUC4ETrBpN8JTCNASw6BiNmWR1E28v9Hh0h4PEDAjAmeSml46fLGAvwtClK2LEka4271wXnufNuBjCZSWJ9op8GJK1P8GsitNwTTxNLt9E4bAoKvtb8onazIgrKoIyPGnkpcXPCeWcYTbO0MS4kKiDg4qfvBZtjOKIYHLx9GWuKn56eSbEqjpZms4uYJ4hVW7hb25pfeSuKUzmk8GR9NaSTPRwIIfKXt7cP9LstDnK70fBJulKuvcEy92wF1FsbKhBe2(PEO3o0JKuOVEKvAoVsZzK3rtOwjJFg4pntQuDL98V7JCsmFaZtOL3huvlPZf5hVlmc2St3v1bNQHTzuU5igiZiuKzSI)xyvyodESSJUK2MXMrjItIK)0PPYupnHQ884GzSir2lWFujszQlZkQ8dB6gTs)XZ62mu1QDALewOS7IlmENf7JeHD(ICmfhD)NhXki0YYKOQnUa0pCOQxhUacvSfpZWoBcckaC4IfHrOlWW(rwYkANY0v5Q321yDv2HXfMzqD17(VFk2AFyKAnlxHBTR(2DR3ZvlguHB9VNe0(hFOu6vvCT3xIMea2Nznbhtjti)rqYusH(5lgN4JDj5QLgd58fbj(ZP06gNMgVq84pMeofRS90UyDNLX6wyfiF(1jZnugODvbkHSV5MkULXGrbmcuEab86FKy53vlNKHawaeuksIeaxuZMqWNdMSklOiVAcXMn8fToxJNVkptLwe5529RkwiKHPYiC)aW5o2xX1zPvyhbmNHV)m)vZlAmk5i)3RcMpxDMKDlKCaRG9UBdmhIl(5LXsjwvFDcOsiSmwKbrS5RYl)GpQQvPrKrZiVMBqqU7jMhClXftOk3XWah4nb47rq4o6XN97V(0p8UxF6WHV(0Kyz7CxBUmARxbBdLr5muo0B3P(K2FSTM(jEj5bAbDtMDl8FbSpkz3RCEwmOU)H4vLrifGqGBWzGkfHDv1NZ097d99C89y2Dt4wSIP(ycVGGTdxSAbA2l7UGaz(EvF7jtlcdorlySWRJI5UP(9OkJGzZcMGROuqAbxrDjevOC0Oal2AmhKmPLii3Kjxzo81YU)mpPsvUcmZFWgScSM03x30j2mmD3gPuSVaY3rFkil1w9pN4Svrrpf1YWLCUswf5CQ8JdSviYM8QPzSki2AyDDM5pNqCDdXMdnL6z4PSIby9EnvPbDJofRbdJbL0KzynrxJwgJIwwD1lREKbkqDPppAigoU7sF7KSvWwji0bsCt9fn2pwcL7WCL8RlrKMtCCkvmAPxOOGeI(Pu6MGx865XJXwgt2e(jzYx0hBZ)GamVZQCBAfRuSp6kT4vxT8D)QCs5oitthDv2AueGmYSxGmmeUI(YzgZPxc4SBIKJc1SL6plaRDo6BfRbmEml4E2VnedrpvKB)BINlGkzjsvTxefHWCsHkoi0raGjjgvNE)yPDkga6g(UowjAFrL0o73t3bfqF77LV668UklrTnRDYnSkBbV)vEhZHeB64MW2ZsbZqORUxFDsCZmOBQWB76nEND1whBMQS46U6rjIyOaXawdgTDt1l(Gs9trUZ(iN2JMl4RO2Oa0mTj9rHs(bFgQ8EfnJqRN626WsZoz6MIfUVsDf0)JHb02(GoFJlUs1Uz1w9lRM3S1Znt3tdZLUNY27OexEJ6ovBmt3zQToDEjFqRXCtXVkIpSHY0dHjbQi)qep6hFXcmDnPRwqJKTbGef6pPjiQC2qubP0NeYkRW1JI(Bj9gULwqZY(ug0Na4tAG8e)iokk4JbR5iKl8RjVrAkLrgLmPtof(FvBQqS5ZEZ8cJDVbJtMJVdxvtJdsZ7zXzZrNkp)D7RKPgQLcX0kJVl7wujzQTRMS7GoySWEP480i3cl22GhLx4AjzQir1zwAcQ8usuU0V8zDvu9fM952y8CXohT1qDojnIJU4vf)bs06lYCrEp)JL7L5Vdc52M683X67WSaXKooEBulLnqPFkdi4LIEcY5SKRq55YzrhOIkvUMoUUcNzPJofONqblyeS3XLluT(ise1)ww2B2nklzfvHwPMsulEEHkPokx3R411lLTTKQwURcuEORuTjMK9AW80UPnWGR5YiHHwlopL2(JvhB9L63vFcitjFPobBtyYz9a685)P83)d43fNq3YDer5gHy)IQGizMDXMPmuqEYWtYhfjrqwnz6yV9BTb7nwzBj69w0(yf5TNPiIMGrKJE0XNz)KPyVOPfu7NbwNX(sRkSpshHoprlsbvfcLkzofE0u)LCspLVAxNoTl70hnFJyFuu6biNegLXlM(rfZUIxX0i202hQvE79qMEKT6d1)AG3b9ODfZmcuoqsyFEMG384lekKdaZIpVNCxBbIECbtuLhz3Q7XT)VXyM)MkZoRsPDl6Qa(gF4c31M)lIIN3U8m(WdgD41jd61zRwgA7LWyjHTnPg5Br74zk)R3qsYtdC7pf8P)Sd3SEc3hbnXiR7)VvHypFaE5MHPktQ0l1IH48JwSQctdbzcnQmErLQjzuH0YLrkpJZ1Lg3)Kts4Y4qmlU0jLf9JEgDp0qOBekCEl16SS1fn)2xLYbkKXcXNmGlApDdsqPWJdDenXWVn7lCV3KY6)Mhmt8Q05rrCIE4PNh6Pd6FrxP(aEHIN8WOG5GU2KvnPZDD4XtFDNiSa7riEROmSPhutxLNYC9Lhc4Ri91Vu2Eb1wUeudvE)c)sznUEL(lB)m(A9n7WpO3BQVwzuZmQedKLDKksCTGXe0XbEpNP(3nzxS9JExOcpj6R7S4x(BtDuCswqh7M519g)0rsGZOKYdZN18zslnGIroQ4UlIldU1b5nk4ZtMVAAEkq2ZYG6nAHF0kmP7ACv5lPEDrQ9OPRseEfHBfg8CA4qVcCO4LoPOLzAxtwn9oSjPHQJzaiwsKvTunZRANlqNaedwA2HCmaVLacqZrYsWovKFI9LzPdZZbxJnY)dHvQL(aVZujOkU1d6wv9yelaVVjYTJe56vLixVTsKZZXG61eroVAe582uroVVse58irondlEvwORgymYUonC9LkxV1QE1(MKagD25KWQudBOr6JZKDmwCKiHxKVB5kPa)EVfZTcvpyCfl9UJ0BjocI4RLJ5RV6xfPripxB1dno)zAWXw17QsfwLezJnkxcLvUz)8Sr5LVrvIpoJkRufxREkQ1U09DQNfTTcn52Id2RMu4K3JC1F9H0PET9NSdVz(mT(ACLrQCl35Veymbnjuy5fxWDR5lsXdymR6R7onsVz(CQ)yfv9LUIT9L(1SV4TR3x2z3RE0otJVA9CtyRhXSS6CWPJR1I8mwq1Q4Y9P9ZW(Q79Jb7WB1VsBivEX(5ujJ4w9BzsWK4fJ9l3dRJXCbGucGGIzsBCsC0)XO)UkjGvFBDz4hgM7kovdg(H9m8q125YW(HnE8na38QAr8S8qB4MxbU5O1zXKkwi12ypPSgK33BVTakgaWElS(w94((6MjgqMgqolycvm57UjKUP4KE1GwmWiXkhh2(OlpbZqFG8WswhTcL2Oq36v83caLAN7j9(Ojo5qgfmpf(3h294CwME2CCsz3WgKkVVYZAf7CUCTYAScpj7CwNP8DUkjp2AF4gki2RByQTufAWRCUSxQjxDL7WIO6xtD1nOLCjmnC3teuG5Rl6XrX7Tpw6a0X5P8BYftihNZholdhQ4On4n(F3NxdycZNpNA07fXtdNfICLTf9eegbqVUh)5om381HI2dLsmrI6Dzn(yfqjXmyIOSByDwu7Ld(QbFkx2CLrxmdYo9iLRh00aXFctXBHFJVwKeivXCKFyH9xRMIf6GrMi)xu18qwBPOQKMR3Y7fcFcFXT0QnBalJNtwgBsEftPzBNSbtjXLMSA89JU7MG5lhLEdr1mmDbJb0LbEcKWv1DcwNRSGrHteqVe9qK9bBDkYgS68AWQZBJxDEQRUsTzYgQbuYowxeMQgWCRJ0AQlm0GwRs0dwxrkC6iZrwp0)UxvHj(8rAzbXIgCEUoT0QYQPYd0gqJxvMov5Ev1tzvPRwVxoNLN1MUOEoYEDpS8vCTME8FNcqSxEN5jgRSTk5ga8IF9SF9NaLrRMNfUCEjvE0SqnTwVU9LxstPCJ3XDnWu8lTaPb7839bCSHZNQPEqTHdT2WdiUca2f268mgKFGZkD6ikoVs0cJlgh1JDCR6HTjpz8s2H9IbUAjyyJEa2WDio(24Z5Eg8duPUxGwrcenk4rPbtW2DlyrkEgm(KmZsu3Kd6mZ0VHVVLUuDbWtwgcroNuSCL4zCaMG)UCnP0NFChz8dRf3BSPSbYXbxtHeX3Xw8bk2NpgbDT27cBdbov5a9neG4tfbE4fDT2kcLkeT7ZjRmE384yLGPaBnowo2k7UOiT34dkjcMokozmfRhaVa1J9ORbyRe4LWHkwI6nAOPfBnf51dmTwhiZY9eXgqDB0ewMatXtJLGgFE(3Ag8McJYOqQOIs8DcHG74fbPVa1Xq321yJmWS2RYIf1vs8TzP76F5FqF5r6bAUEFCemn0JFH1tDH8ZktLhjdyqT795oFvdzVNmi3)5gYA5UYaWwZRvbCx)lwySsZ2mgRJSVS0KsmwwwLGmrxhWTiErdGwo)7Mq8h25eWkHBPKcAUR7kPHFHa)hnD5VTZ3bDaX8dMuj(mJdSKj8EJd4P018MG0sd1Bc1FCNJ3oG4wJ39oCxdqhQQ3Ea(uPwPNdU9eTEE2aYjwBiAtq75GQQCTUyaxlx4lppa1X2LT7jgdOx1vjtPPXHz2h9MONHTW4LbCSOIWTEXELliuR28pAE)EOCvRDBPl4e17HTsxUjIgC1X9tYPQ3njDE4H2nEWwGR40o0X4Y5AWGETSJvsQ6)BHq4Ko4YnN86x9InYBNsC0ImDWj6GxUYSDMZzRNnKsdQApt38jqMULTa0lWCJKCFvR8IHSBb(JyvdplvCmAQALRpSD)K8iWakNuvT2Ldyxc4hX6fdkUQLR457qW6AXwkQiXR51e5fhdAxpbpI1UlzgRdz3c8hXQUkzfNdB3pjpcmWUCJLbSlb8Jy9AvYP8Z3HG11ITKJ75I5LkRGfrDBJ5jf8pza(VO1DjxHDvlRwTRc(F)3xvf6hCOI)GwE(3)9vb7bh2rIIB5I7rT2QBPLtzp2P8r9Bz2hJghXUg8pza(VO1D9CYELywSa)DgNSfyxfNCZwCpQ1wDlTCkBPCEKR8XEllyrdKZbQXBukbD58gnCIQyGAtuPm3PIrM9CGD0XYOA(u4SLfSpxvnCTjTuM(ujG1IxUgvZNIMJx1oCTjTCghFKAnEQHFtGmEAH76hD)OPltRc6UgxtXGMopOcNrBb8BCGmvhP0UygC5vPtyVT(p9ud)Ma5MTV6ECnfdA68SD8pBqMP2s(NnygAk)t5mg70vuxw2F4b328R2OVlr2oVSDVUh)khIeWtD0lxD6CA7QDy21MS5m2R2zSNygL0)Nr62bp70TdEcOBfSKpzL4YbGZBkfdGwQzvkbqxviERbOJc5U9a0vLCF00shaElwPuriMfpFE8DuBD5d8suJoJTV2k6qFN)bDKBwi(6kw0zC84OwBEg)XFTy0tNIdEQFM)y)0GFA9VWFh)scZCu9d)yKASb19Wbl1oOTwkfoj)YpIQL7aIBDTODW9)iwHpn9DGRQ6xCjJza0Y3CCnfKAxJxgq16f92F5aEhuFFxn5WUa0oQuU4IdYaMg3yyLaMdba59tKb0mV2IkaNvvhcdABy7h6Q4pSPAPH3xypOaLhRHOUbAULCrzLTayld5je41c2M7LEJIg4XpnvgmGBWVDrl9edE3a(rRk3vru6vnJDPh3qGwlVN1H8ec8AbBZtFrJySF8ttLm2UbF9CEninv7AW7gWpAgBxfSA70)9Kc868s9rqfCvSJTty5jf415)7wrfS6cWSXVyJm(7Qp(VDh1aZU6M)VwGVRZmWtm8F0n49t36E9V8rIJdb7B0dhgzRUCiWTDtCYLdhgU494Lrr8Sq8eAXdmTBE399Qbhm269rX6FX2yLPTzF8ionqiTjZO1(0XjCGUfE9Ss(WdwEQOnBS(SBlAIfRpNAxeRpHJUV5iHNvKWwQ5lMUY9kK1Nzfjm75fRpHrIVd)SG(0EPlSjukovD7hVCaDsIfuSE7xCOuhCy3J3hpMHHimhuFxm8e2Hf27IHnbF9E04BPAD)ewhE716MyI(2TXWxz3gdBcxQ8wAOKwy7nmWMaAp7G2vViSjGo)UuW2Y2Ss9Q65RQ46BYcWZXcWARcOQJExTaK8yM6x8u1V0tr7YtufLQQqCocE0Okp2Sv2WIlvvn5CKsgJj3M3gvvNjsH4FHxRbnHfr96oqA1P7HVu9oldXID3jO)RTROGMqenVRh2xCvem4iuIJUld2XuXHxS5lS0S81vV(klmRGr)0hTF4SbIih0kzxlzOkYsUzhAyrzdZcwWlkh3jb2F1CiRSeQz2uVobW3AVM9AnfLTaUCacGH(8rR(dIpx0cxS)l67(S6cI)IuJ4hPkZ8GPLRLS8nm9dpOFKVoDGxNhEaV2JBPDPgFs)Jn43)Y)dXSkfsxiY4UNvOL0MNYYR)XgdkqieWktiA)c3(1EVuENz)iHVL7K7xNd6V77WVW94hNeWwYNXvcE9w)BSPRpgnBfEfzKYSTa9)(xqCT36hoN3PbBNezwzBHGzXsoKGo4tedCYGkV85B4YqXK4GdLpKH6dL(DR4N2dSCNPRqkn)clQ5dL2MQX32zEGOEF(tin4kfS0nev8QfaPuNcaKQsFTK))8S)1sUqfjGw1BVJzWoIw9p1lfJnrKuBtwe3BHvZWV9LpE9g(Lp2KGROpHSjA(L380b99SBf4qAlOrFhJnNu9VmYUmwPlJDYG(VQ)lLz4uRZxE4bxQhyV0)k97tSjvZUkSzJr6x79kvRbLG2mSCCA(dmL1bkzUBrIM2PJ4twLLpdSNKdh1an4VPw2)8VA)nehdDTTFyATXm(gh8Ip8G9VNWQmaFn(jcUz8aUKHk2ovzlAxH3nUznA9uZf8y2X1DQsDt)BFIEfPN9)QKM)IpUXuGuLzFuSX(4)872al90kWYxL3tS8G8ViVkQSuAHpd9(n47SR56tjcWVt(HJ9BFcDBYNqxtkj(bwvjG7c6MPj(thCeODsmmTMruexG53ptXpB7(lba0EwHuB7GcyJCcR87uflFCvpDqVJ7uSQt06gXw2)YgisE4xMFXADT7Tzyiqr03Bh0VvnKWs8ckYWFb85L1KUyMiQC2nXCkCQP4ltPfmumgRFwz7W0RsFqzDjki(Htu(eY(6EfUO76leRjAPNnpNFYwDyXOv9FPyBz6wpNnPn4l8AjdzkdEF6dTkeJU(xK1b)L8bzDF1V)SdEY(8Zs7f8x7vJhzvcAx9bATobcH4GCcAzioqRnZVfRMWu9lYQi)jgEXR)fictN6A87q08WjICtIH)tUvQMT)ampn6onUFX3GfBP4bybELJGpn3eL(OIF0EuR1sPDBPp3d6PomBrdzAPCWXfU9OVCAzQK5hE4HMnW30PX0hpB0hVx55k8CxuiVUnLazqkB8kTVTvAvjsWw7z5gbgGF8GAgkyGRngdosW3)O)SBvmJZgl8Vv6(VjRVfDILuB7zXgFV86NuQf0Y9HA3jO0PzyKhBD2UJkTCTElHV9TGVEBh(U1S9neJ7R6VwzmR2n3thG(J5quO9oHqU7fOAiTrko9ZjurMgIaivE8ajHNKqoJqVLlmii5HOrb0VgFtuKv)AAS8amQ5OyIXQc(2jSRL)dmdoRff8gB8hWVd9QGdYXCAgghGouTxXSKwU2RpfER5WjKFGWL)BXVayc6IgS0VG64H0LHjywYfoUjsGruqrZmNDxGpxcqn8HlLn924A2(KFs)w5zWI90jNNOVW74chG0ap9Z7JeT4zZgD9KPS6ohtJxjG9Dedd62ur2bipMGDQ3o8T)MX0PvEBMslpkycO9ZOAAdgn25l1kSPbu7zaK45CxvBAYnV6oBvk3GTSNzq)PqO6vvGXtoQvn138KEh2YvXfmZSNO1AcM7)zKHPOJubN)IOpT()o3A84gfkVmXpItMxWCmTIu509PUC9MqSeqyXiXnTvrtrb7iyhb5oZ7iky3R97MhhpD(k09XxvQIOh8huZOG9ni8FjZ3GKPFsNDq6G32Y3qmd6vV55BlI2HUaR6d3QnaV77SLCk02bNMbY6rrIgYhX5V7dyW3yMWUlmVwsNpSRbM2Ssg1UTdRwont3Q(clBqU4SB4(PvuRAN2iTTOfzjI97BSOSvcnQahk1Rj(j8jvx28zCBKMx5XPXuc)UHsv8YqM8Zm5ygnmasP6EqjpspVYD3bC8BzbqQq73URgyPz2lb2wxzc1Ar1QDAq2OXXrRsbifK0)WrhTCcW1sSYnU0kYmlj1y1n)cIUuFtilE3MuhgRvJd9hSQf)CGzid36gTmgu2Mf6xls4Ovp680xOjwW6IBsWcxmK6IbUgfGMOZIZlSXe)LYCM8wQ0cRV6pORhadEYNHkzuQ0LFtpG76G(n9aFtpqtqqHEG)0pViQF4DhC(W1IofM8IC69mFCrfd9JeFT()zQFJ4s3YnT96IBmgwca7djzZ(mluejxOEXI15RVdwm7d(uvPVCA(5l4nTfvVRGSfTd4RSsvEj9w6UBXHc6aCVUQL6Pd2SjPwYHDFxFsPi1J42xuNUPOEr4LepeRLShRJ0Jy4sZzBilwCsZfTTwWNdZK2R8qhRn1zAMG(nG(0Uk7wV2L1UoYEATCU)1wyQz5)5DHvtq4VtwQKFJIXVjMG4aXvBv0njI8s0PcwI8Y2iY3qEbJfUQWvffuez2odU37lMiH5HMwSrPs7YJ3ffVshF60YOEBNoWtf1lxVBr1NTv47159iU0HhVdl3hdO0J3fgejzPURodNj6faNgQLQApW7WsPvLXQZWfBUdCNJLJewuy9ixx0HsZi3HejWaRjita4U7GDDRf7lxExDq(K9(5y8ZIxVkOP0Fq8LpaD8cgVkJii7JTiYczZofM(tA9bBoVylSZG6AwtrSzHi6Fm7niTKYpkJvJcg534rvA38sPArHYEQoBP2P5c3ik8PQZMujw1c(UxBuF)j)OZeVyRQkTS6EvPEhWdKz206jVbOSYzfwphgQFMIkLwKnHqnBGv3iBiakjhrCxx49JaZ5NcceDicfLd9D6cuaSAjFdB8AxIC9LYgDnKI0fcJ0pukUfJqMyS)DOdRRryrN6HgTPhjrZDkNFL8bnKg)fo3CZXcyT)O51(70zjG3a5ntTaIrnE(YZIWDHra9X0cSwXa2UIXu0npNb84f9YoBmdlkCeh1S)0PPYyT5d8OSZhdZEb(Jkr34Fnjfi1oZg5W8U)XZkPnU2ogTSfpiWqf6mUWqA8GEG1rz81kFp9WmRAB4)WHTSm4oB(6tafBFK9ATx17avvYgSXl)GrhSuRtIBMVHg9YtP(9n3FqF5AJD2J3AbpHiDI)bxtsqhOOOKCxXPoKZ56AI5bIkSP4XFmjCkw5LPDX6IiJbPqTw(8RtBm5HkD(nTSj9)e)(558dONzFqX2tSAtWs3q9N8jXIUdfWAxFphl4SW0BeWkc1oClfLi7QSwZOVkL9NoJ1IaQSViV5sOdqfRqbzY43MBc8EVjL95EEWmXRs5euK9uE65HE6G(QhNz5jURuXRTCpq4QkpMkz6lJhXcmgHOE3kRktLNjwZ5xWg8QJEzBN1asgC6aruMV0RZRQU(PkJSZjd69g7h8wiKcrMRdwREDGqhja83Ol2euyuEYxNkA()9Lwdqf)CVoqThGWQfEbaH)M5vaun7BPZJZKhHYEolj3wr4T0pW9D32ip17gGNT7PFjviFF1l0JCykGJLBnd5D1XGEwVsne3KiDAz7k6GVcvemg1C3wC6anoh179KIs8lg7jO112oZpU3H2ofrDKkP12TReJ70CMjV)3cZuphmtLV9bRI06z5H9QIzYZoZKJBPfNmtwUXxEMyM84u3)Xz5EJJvNdndrMUY1nkVXOOURcNcPXnsDPir(4RLJiRV6xfEcNF(CQhACkn0HtJz2jnNUVtESD)6KVtyBRLEToBXMGBLonhz8SJmLU)YSXG7KgSBqgjt)LzW)ZL)))d]] )