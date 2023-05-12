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


spec:RegisterPack( "Devastation", 20230512, [[Hekili:T33FZnUnYc(zX1vrJ0m2Yw02tMnNLF14XEUmPYBNuJ9MuV)XYusqY8nuKAjPShNYL(SF9paibbbOOKLDYUBQ7EBglc0aOr)l0DJgx376RU(YX(zIR)7Eh4D4bh3ZRBppVJp(4RVm7H5IRVCU)OV6pf(hr(ZG)3Zf35NM5NfehHF7HWy)XimsJxKmc((TzzZt)H93FAq2Tlg2Du8S9tdMTiK6XOe)jz4FpA)HHXd3FCI)04OjHbtVnBFr00GiX(Jc9tthmlE8Iqr6((ZdX)VbI7I)QiP7O5ZV(YHlccZ(u01dToZ96btM5Irx)37D0B)EycfmESGBSiD01xInEVdoEVEE)WYB(emLeZerz(HlV5YGzFy5nlMJaD5nThNeppD5nVknBq8CrKi5vlVzEsqCsq2dD6U8Nw(tkqDW7aqD5IHaEjklab1OB9JMkGENfRGlS6bO6p1piQCNpc6CnZeaiTV8w)Smrsq0u4Bz(j7U8MpgKaG7SeHF2TWFEb85iyIHZJKPc4x(LhsW)ZphCh1TpgcBF6t7J27WdOr(FqdZ4L3mjjEMASNeNS8MEh0TxPECWXA9OChgfk8JOrAX8L38(pFrbYcw1lVzyqMgOoKXzlV5lXlYGD9c0EomLKmFajzwEtIysadECDbnpfOjbadFACWKjIeaZbyBFyTd)3rXlIYaeNFeSSGDLrFf(J4jlV5d3ITa(XZaQm9jK3E949H3dulW3pNOmtOb59rbZItPfYV4pEmnlaQJbZ5)OdmeImyvmT71xggKMLI8dc8)9VtSxIi)HHIXxF21x6pIzCeYTRbP4Uf83ZMhFVizqwm2NlhbOny72N7WDIba53SaKu4K(W2YYBEdUwdH1CxfKshKo3pQRCSwEZJpc48ftM0DC(kPlqGbuFiuaG097pE5nVgM7ZfHHdUfqhWsTvnD6uEOn7ITbcjbaq1g2bmM)amoM7ZoRCj0QA3X5WB5(VzD(DlVPdljijyoVxuL1zrkSUs8J(6YBGnEGEYF(8WGriKzoAMolT71zGWNgUfx)EQhTN6rO3N4oRx3nzJ1c5qzYspCXE4wzXEiTypSPl2ckLjXrGW4jdM5pnyutXi4a21BdWjwqKLrjhIOKJAikrVJhbDmdjdN4VimlxqHQR)ZfWaQdufzMQblGz7DcZM4AZzEm)Flr1FUi0hi5HVT8MGiG2)k4)csiFiEbqVJIy9hcYMLAWUC5n7XmdHpGcJdbRaqbUKAcw74YBU)wb2pcc3tF(8VS3PF8S9o9Yl370KyLvdfehULBSdkepoCC89rDtZ1(naKLNqTc3YTXFdCqDKeeXPPe0MGwxmqNd5WJTTXfdMwacYlWB35dts4R4)kCbsvRMrvPymWU)QSRa67wuhLaHaRmhWsa6os8nu1LMwMa4BdbK79XjFLuXWy)BHpnZ)BG(qqT4qr29cS70pR37rJLA7aSpSvij2sbHzbtJIzlh(W5Fb(cOSCeoJsZcMHZOU0cDaBDhoTguaxenDSf0emHAcAQmlqbZ1EkjDthnUlbRANbVDZNbtaRKgmKmsQ0W3Sb(7DWqnYhKhW)XauHpR2xcNmaz)vq5acG3zaa3Ifpfqja5h05rzKjaQXkzrKZHYpMMM)nhtZ66AAglcAEIamrFOFvHqa0strEoqElqUbyX4OFxytQ0AXdjrpDZ61fKOoau1oaLci1P)I(r9DFztg0J(sQnXPRXAZRUjXlYhTT28kwBoK9fmrNgvT(6AGCuYO1qRfsgxKqs5xEZ3PjbxtEzrdaP1hWRH6B33TQrIbKPzDNlgfmwGYBdgDBoiy9zZ9dq9vWru1T0Fx8ilIjOQmq80SGOfOvcKu1Ef)Do)TvQN0hIg5KczGimf(3h094CsMEUeXk3nSbPQ7R8OwZoNNJDoVxSDoRJu(oxTOhBY)BiJyVUbPDtNhheMIYXIeHG(4KfMQRVqPmKoQQAhE5ne4y1YGuY5(SEus5RA1WNRK(jz)2fps6Db0XiXEY6QZxZ5nN5HdYqQUyS9PDxEZp6ZZHGOmWgqst9Sy4eUbivz7rlsWd6I2G1R7XFRdtnpf0KqD6wWshSDfh8g)SgOuRmyGUcNcwhL0BJxeIZDHYpgOTfPLADXieG(TWpfrDOTGJfY)egI3Jw7a9G7TV(yq2nIMB6RXzEFa224e1)kcTnfjTvSQkCEzBwky(M5hTWp0MM71GKXZjjJnoVIH0ux)AmKevAYIHpmamomC(G0BjSMHQlOnGSm4Wiiv4aaV7Neb0SdcgjHEf8H4BJcxm2QncRXSZRbZoV1E25Pp76DWttcOICuxg4oi7BnkWClJexzRsc6kfIUFPgG9DqXh7qw)2M4IzN5KyvlUwlTmHywJo0))tRmRSQQC)snOXZktJQCpR6PnRklwVxoLf5jHEMUgB1uK96Eq1ZJxso(xiF20l)8pY2cso8r34ac5bzAx95Z)8pacJGtEhmpSIipAugIN9Qx3dXZ6McnmLpK8Sy8aUJr3ctsWU4SpITniCCjXdj9gGd4aC8O1QnZKba7A1QGd6JXeXCcodqJ9Z9yWLh58aN0eJpKjk9hpXmSwUfifiLxQtgkB4I5GIn6d4HdX147JVOlDgPpsEIDgQfbpSi2MJsfJqVDkMb9pm4RcPQSu4uPzGmtu3hH6cYEfQ(uK8az4ePziaPCsHP0e)eAa(r1CIMjmUfK1grU4dgP4OXPScYHIP0j3Wf0q8alS(Uq4i(Kp46zZw91fbNQ5rMlbi(CHGV8kEoBAdU8Gz36d8SIXdItgsh9kobJkqX6WvdqqAAizH0qLd0GZdNI9q58Sc4M)jcsM2CvsU6Qbwif1HbtWGoWh0ejFT4q8vZ1BsPtHwGBnsdMI0CVFugOfgnl6RbrJ9LrJaTG4E0N(FEoUzX2qGBxir0eICd3tOnrFPjutdJhIrGrf5GKmvh9XytieitFT8O14sydhzzSW2(ZYInnB2PVyEDonuZtiLNMqJhZtjCd4dNRg5Oyuy5u)KX8KLfm4prGwjMB07S4HShyo)xUKzG5wJSpmujUgD)xfHWfxT3hNGnkDemDbf(OFXEaLytoCKbqzpyonUq8symyiBcoePijX5xI(Te20c(Ds7hOq4ZribeRPaHJ0yBPdevgLgsF)qV03WMQkIOGnjO)5yPEc01jkzzhEqAzgrm0bDjYLS4bJdeSJlp0B1UT8G683mOmJ8tt6iG708ao)dmIgqlKhyGohm5yssYngwYPjXnZZSMEUAZCOVvp0HdshBhiU0A5d0oGE8pjckGny608ZwKIh8y)HH()orcaCEj4Mt8ISuYRaiL2tMk4DRhrGB3hwG3BRhUdn8Fj8xUvxg(SKmdm)JMsMmdMIVkSMfaVJAtM2(54vqyYsbykFe0TZPiCksK(agN3KE6keI5thxmnVJ7RnwfY(tnhEozOnxjyHWYiCG)BeTLnuCzscxeCTT7PNIOLvlzxRxA6PTjDJiTUibmwaRuw6LvIPZpJ3PJuHzdPniT20VKSiItQHGzGnIePaaKSKfe4zZW)0RMHoqjDXmPZNqX24ILnQehGiMUdvYIWN1hxasLzeKIrP1cW5IIgljFlo7dsoPCOJYu(zmTj(zqbmc5ctrqBZ5qaQO9vZbnt6j74(VmmHSkTOnFO0mdNylsWyuYwLJZQXXI0Oxb)Jy4qitcr7aV4SDzCdfyT7cMs8YuFzlzQWRamza3hEO3K0SUuEKqujw(4m)Vnq2adPSjJ8JedOHl3ozloKXHkoY(6ITWITn4tCkxL6YeEtFQOA18hsmTPJZPMW4Pb5(A7Uym)Bcr1dO0mUfhD1Bk(dePDOmQXZd9FGJX4zk6BbagbDgzwo2q2vQStpt50eYgOigJYWlfnEJ9I4WyCYDHAukduAdhHRFwU9NZe85(1wf8cS3XllNAqNz2cGWKMdJf8aWw(y5uvA4QCXM2nwcf(CuUmvz3hXjL0GHuojPdHDSsRjTft9XGe03XJ4ga4dLQt5GStdgN21nus65AhRIHJAw5rsYxqPzYX6TvoVy88GGOjGM34stmg13niAqXHnvdPvViToe5SCGY05)M63)v43Lzc0CQJiTPjfbshZBX7Ye5yJueZUiZ0AkWpzy83tcLirRMeDSb6TwJ9gRKTw9KL1d8Bty2p)rfgboA(C(CzyJrdAM8dMS9a1xeSnSB()sjZy3Yok6i0OiAskXQWPFscPt0m2FEM0XMCx760oB5yyjHIuFPUuo5iT2lh(bfJUMHSulKREgtLAYlBLrx(JKQh5)g13qwh0ZQ7VQE2pyFEIK284RKcKfGArLBN(6TO)6dfFJodjqzbgarPL7k1BRtuAONEG8N54KzjJ8WZoECbrK7jHn)LvAr()eJ(FESuS)4GumyvttOukvYYlZSuaialqqe5rASvjjlMNnad1GmjJr)CpkmyoUp1Q6cUvwaWnFAFVwTt8dgpqChsdndm0a9dhWyEQ3JpsD7w04dOhGfLcGU4Hb0aBouAFchW2vhXhFuTTpwmjyuq2j971zJMgL2lH2smB5uVQgQzFRgI0Qhg3a()CoA27vr(ZrbzT)Q4R)whkwOJKMpcsIrs3)3fbJOancKuOn7sHEPwueRawjbMgmYwDVzPj8hHZqnKeloboqMiPyv6)7lsqhfNe8vPBnvru1MVnlb0FJ9RhfxryPLido7KG0BLl3iK58oYZXS2Ls2TViLpOqgZeFsFVRYZuvYRB8rcrvmCVzBH79Uuw(xOyISRN)fqt35XKXs8WZn90(hEv3C3qBlaOBI7HoL1(OBeHfypax3AcdD6EOwnl1anNF5NX7nK86xRIw2ktvnucLmzXOUX5x4Bk3zRzzM9E2rMc3VB15PiMnJhODgil7i14RzjHjEzicJZ0)7MSl2(jVluJLehw2yX)8Vn1rZizJi1wKgigXdpFuZhjRHvUirk6tbU0rSNLXkxnvShBBoxemOQChUxCRWGMR0AWAaKrSYBpqHpQ1rKEh0e3l1X8aiwCq1kXAM5(1vAPJJsTdzyaLHmO6iv6Vow6FIDvEFd9ZbivDmPPjvPLctym83mtzSU1fcf5eW7Vy52sSC9QJLR3gXY55Or9AclN3ky5QK3hRILZAMK8NqwopILRKIfVAJnvdugTQ81PDdeVAFtscJoBDuyDIHnKi9j6WxO7)JJKo8ISDlxiLkhaPq4IZyL1DKCRy2xAy3Yx5lV5Zs3iK7RTvdn2)zLGJTaUvNiSArYgBuUykRDZ(LzJkp39QshNr5h)QSOhVXmVFeZJ(ZCEiWP9cMPJGX4LZfMP8veevWGcU35L9G32pHiHhFBdp)TPHMfZoxa)esqHM3nkoFjEU3yq0iOgO0TDGAHbE()wctalJhKhqRxrr5jDEqck7vE8EzCkIe42EkLIqz3l857sdd)0UPzVP)(C2(q9E3Gj9Tp9p5Ww5KU88wsadhtQ1oLxo1ydqHl5niEMtbEysHl(Xd(c0jV)Y3)lvmyi)CT8G5smRZC24lIq)VzETwViIof6xe)ZfaOXLnsYoYpIdnLie5xOB7LpLa93gGP2bWjsZ8frJf0HwtMrx454OXbeog4CplmoEC4c06jWEGFHZeVpfnbodBC0()kLvyOLyW)lFt8Mk8t6SfcA6MNwgRWIfY2OwnXQi8wtZwbSIe9Wv(D4uuCD53XvyQDWPm3YB(4z2IKcE3jz)dq3EYcNqN3Ilo7J7kv1CFqEcJCXLDBSbSL8QAnxwtvoIa8pOJzY9CKPC7MAnSXUrz3HxxRAK3gw9ST1Qw0Q4vuVFNOuAzOmLwKI1a(h6IA6Na0Z4jrK51kNy95570y2Fo3sHLDEaV7YSGlM31eivYDbkUfLJHB3Ta)4Zqsm0EvA8lz9AZtqgC6w2CI6YpMvKyb1MexAGjfSdzyC0IuasIKdpyWrZhPXor8ARzwtK79RHkHWLDkgdUaPWyTOt0oVFRB6wyZHBLJl4onBPgc0zzivXG5XGwgSuA00XFNvT82eCzRngLq87vt)ixPrs953Wv3MG5VWLuoHYPQWU5EWfTbzK)CLRjEpLUblV5xP8n4fnJgmtEJsRHkzv1FjE7VeVTbSK)L4T)ukEJZsUAZPPFZppBX(4z7FbW5X3Md6agJFG52kYVj)iPpp()rPyoNJA8LXHzV4BHjXhIPEUk)UNeipNDqPSIdVLbJQ3m)cg07HPQLOlAHJPLZdMB(Z6y1CNF(gNy4xlHqzR(loqVtWV3Q8(kYhV(dQ1mkRmk1(rI(tfwTPioxNU70ng15kpLQjU5sxeq05S(MES2gpIPiDzEYwI2eWHQoL5QeFlitzrGhEWUMe826WTTxLjc7zTbYp2rVyFOj3PCm5D7GP)yNWod)F18UP57Q5jbH0Tp55JM0EoodPa5DQC80aBONysAA3w3Slsx3I9(6gjTsZgzntgPUISm9ynJEuOpljVNeTvnv8KPiNTCYBzEfXrz5i6ZyZC(ezE8Ushb7kd7koLFI70ZJ6Q1CSRpp(TShHopRPxtjCW5uECOSB(cmTHOkAhQnmp3YNqwHkDwhMIqm6I97pBXCl2e688LLmf(dHOZEKDVoOPLz3bZMhNKrv6PHlYiV)TlM8TZwktt9G0FO0D5kNQVfMV2D1(bFvkCt7wCKsgrtP8sfqTlb3j11oTrj0N83A52pqTkVHCsFVw7yZGUhFSCdp1RtR1oNX2PTDl5AjTfRWS2op(OdptP9HklMoRt(G180slFbyzXTglP1zYvWr6066AIRHNML7niX2Q1ZC6CEe94vE)nGC(RcHmtwPJJkM6JjQw6I5iBbPIXot6HkUPUg8DLzBJkxIVCZ4Hr2atDzQ8zyC(1t9qBcOpPWq)RdVsZPvAoH8wAalfCUxa6txUoYvaM(r6I4Y0bYapR7aeuuRV6I8EFqeSzNUTI4inFDDvECFJPO8u(C4ZfxRtw3mg76i2Bk(JhNQ8bdxgaujjzq2RuPVJ88KuP2TimhSQBul9NoVBZwQw1tRDQETDxCIX7SyoSi1Zx4SL4Oh(2awarj3TidrHla92d0T6Wfq4BcH5HVBYcucy1vfd2elU8z6g1SZQ22lr6QTdJXn219qQrPmSHx7Kz5V8(5igZRS9lN1)bu2vmVbOaj6Nn3t7QTaqU0H(eFtmArMW0HqoY2)8V762YyH0QVmv(9QnLd0YmzwzGsGUJtOKroEUM6qSMzfx7Uie3UXCiYszBbLTT1PbVr9rbuFlYXz92ALYyZ0i0OgBRvwGHdOLephqoufHlVIaJcLweLTpVYQV(axc1B6a4vFeK6JgPT9LdxX(I32EFzRviIPDMgxlIDGyBuGPB)cG6DJY6VfRuXvWz1wSIDkhGRuXGCemb9XMkl2(h8o0HEeoivMVTSrPsrtVsK(kucnLBjJvjKJ)ISyzw3kRq(Dx(t)mv)37bNu8dXrWWqF(vkCDMEzK4vmZM9pQ2fGg1U3368VtqoEUGZg0u(ybVY0i8EVPwWlnFTk5Zji72R1iBQyESSHN2VNEZQcqWm62LNv97F8JpUtTZlJdtCA)3(4JRxhExhf(9FjqjVmyKCYiVNnc0dFPHCjH2ga2Qa9c4U8NSiFkVWhVEIPQGrLz6kNA6snhYYKz(SSC(RxPrLw(BHbqvN(2aqpdPKtEOUzErt2Ua)jmRrDtYlXDDZ8YnB7pipHvajbPU5UQbBta)eMVOzv1nDLFFlcwxt2kIlKDZRj8loA02EaEcZDx8mwBY2f4pHzDD8koB22FqEcRa78nwAW2eWpH5RvoNQFFlcwxt2JCYMx5UnzHv3wBEwb)ZgG)dAEx5OcUUNnTAxh8)UVR4NkSOv91(hOfbklF)7(U6GD)dYnAFdNCpP52QMA5y2JDYFS6Tm7TPefX2g8pBa(pO59QPK9QqSyb(BnkzlWUok5Mn5EsZTvn1YXSV1PWh716ElsGC2Ws0gFVtAJgoq10Wsd07QBfzwS6TVCS0QMpeoR192hR6AEPb9VvhcCLRlxTQ5drZxxRS5Lg0EhSLLA8Cd)Mazm3T66h9WGXZtRd6UAxtxbnDCqbod2a434dYu)jL2gJGlRkDc7n1(PNB43ei3S9v3TRPRGMooBg9ZA4zQnK(zngHMs)uX4IDCAkQln7p(OBD(1R03flBNx3Ux3JFJdwc4Rwgq852OtNtBxVbZU2KnhXERCe7jhrf()feVT)loEB)Nb8wbjzfdPLEZwf2XCsCJF3zqJQyM3gdqYH5tIddJVNVngW6gt8gb)2lJqp)oyWXqKFlgO8rt1o6(hpHVswfTE8ySXJ9Z8h6Nk(HL)eN69jbzo8uVFm6VK1Wh9voQ9wl2eo2XkSn3aQAgTVEqm)sryaWkxwct45Ge4jmdRygSCMODlanNKwUGGRsESQVfLJvdGwTg72uqwkzSnGQ1sI7F4aoPu6LBa5eR5EEfq7i20pdGUIQ021cUw2tWIop(yL4hFih6vlzt)P97DCNkPyA)JulOT1uydMbf4jhrFvMZ7g4EJAqBfKUdbfQkdIb0mleMfGZQiwPsQ1mLnCfqNYvgVxz3qFTpxAH6gO5ANLXF3cGT0KNrGVsW2ClVBKf(p9HPwd8Dd(n7eqpZG3nGFYQ8CfyKE1tyx5ZneORK2ZAtEgb(kbBZDjrJiSF6dtTe2Ub)QP8AGRN22G3nGFYe2Ucc1Mj)7zf4RYA(NawWvam2mMLNvG7gSpbSGvtaMm8vRLYFx5(4Dg5gRX8YzUZUs1f)lg83(PXwTWDlmVTswKUM5hNlFA8ux2oG7wyz)hk8FY4LT)59DaXn2JevcjOSFpn)h4WRepH1Tl)CSPR7kHz7jcpxolyZbOdnRBdxeSQKsX(bWBv7G48O4977DqL0G2tnX3UdL1rQyD7Gis7M7zGpTCN(QGmFwaQdYtBxfqdOx3Tf0Cy8wzyximDPKM)Xh5RtUJlK3P6xgpzs3B9I4j)MLlHxNwMEAQNAn(NJ5tVxr6J)ePkgXBFFz3SJ6BV(sqn8TXjxF5LbZ(W1xchvAsa(UjZnmTBEgU)M(7peV(SiHo(GrFlEvFIJ(DXYFYwBvHUyxS0o1xADQkQo7svl)(LprSKbtgzUhF0YxLPAQ1VDxrICA973YxVclFHJAqZxeEwxe2cpDXWvnFzT(nRlcZ8(06x4fX)h8UppIUQR3FBavWD5MYeM4dqq1NFGDX6hJyIGlkqaB5c8IFr3R7Ef)TeqPRdMIdx1UXZ7NkYcMiXy92T4f9V)bDpE38Y(B)vNjFpJzzO9m5BDwVEp51BL896zmx0SNVxer0fYh2c8YYRT1ZVYflVz4d0fNFom75xturrzVAzXZ0TSF7IpLwyHKFm3t(X1soIAnhx5lP3MivHNV7YB(rFEoKZtHxy5XbtcqY12Y6Qiwyc6194V1HjZNgiFHZPhQJeeEQNDa8ZAGsTYGbIp2ITrr)TnLpPc8h(PLADXiOE5tt5lz(yH8pHH49uWpXcmGCrvmg51Ng)L6p5iuT4ir9VOqHIuykEyfohLK3CQu1JlqfPW2tAU1b0E2bTR8XBDaD(BPHTPTz2QPlNVUemBDMaEoMawtxoDz0BRjGIgZu(INU8LEAsxEMYQI6sgfhoB1ithSPRSHjyrD5LIJqyym42S2OUCTGei(f6c73lVoujVL0QAJcxshU6ZN)zWs1zlcZcMhwr2rVUhiZSHEDpuvgkLMWYvKhywlffCXzFeBBq44gXKOxgbvAD6EG(flLwf)QStYbHFX2qrIY3Z5BbmljrxvTTKnCXCyCPpGf6fC(((4l4hw6psVhIZqrRc5Rj9rPIry1Srmlfn08RcP8907fGO25XzLFtlUJQK)a4jXLbOoGuyknbRtXWa8JQ5KwLlIlhUVDPSy1NYAngkMs3LDCbnuWf2fFSIlL2m5JMV547owmXh2I6FeYXbBxISTmw8YRw)jwAw(8Q3H6tmKkvGfZdICBKpvOjq8cw2Psbfip0LBL1buKm2honMy2We)rc8fTqEqTQNcj)Ue7hnkapch5Zk7lemzMcYeZ4fs6T(aNlCy44KH0HiGJrdaWExZpOT2KP4LUWAx0lgmyV2PA3Y7i08)5cKfw7hwaMkDNiuAhnvnONREZ1Vu(YstLwoFKk0Fiv05WDESqiThsDMMXp2fHI7OcRf)UMphosgtPK)smEp95Z)YEN(XZ270lVCVttILV0SAtiy0H)fUuQEIYwT3jxuy1hYRQjvGxh4SJaVqRs1B5to8ydIAUO7jqPiSfGmbowLOlxkXq6k0EU7Jt43hfgDGS6Z8)wWSf0toEgW1RsBl9EpA8Y8kRysP67xWuquabWpGmkIjtitSup2AAmZv4umkL1srH2mhwv5lAmOaonyvzcr714198ETQoL(eHVLIV7E5GgzM)uewJYafgFdNj4JOIXlLskt2c4)hEfr1ENFqiVtdkij0S22IUacykhqqFGqcCsRjp9lxM(CqHY(bPAf9BhRRVsFWYttNgQ0S4NxYqPsBQjlIQ2qu4owEJgbYqXPUbRI3kbqkLMHaQ69F(IYov5)l9CobMaJYba2IX(yjOuG6RIW6V)YB(8CKFGnGpLQg)QQpgsTt6r8LNFzAy8qClLFJBzTlChX3W2eHGEe7ZffclRvRuJjWoIM9p3tfJnrevBJxe3BHzZLcvPKJFEcudawxw5xNwEojFt(NiWJBLF6XzXdtjHWN)lxYk95wJAJzOsYI1LZerv5Tqscg2i0FAaYlgLF9WqLKAgaLf9pnUWKevnd)8VKUfEnawVhFiteUM8esPPzb4)0(h6zxlWb0wW)i)b7Hohn53isDaz7gS4Nonj2CqlxTQDPSQmp2j9p8nh(Av8VkL2Sp(OlXdSP4CzDtVQArB7ab20P5hLMkF97x5jCiVqWH0dp59Q16LBWeRzxe2KHi(R9ovc4K2jZm0CCA(hm51lktm5HXPtl9QSAPI8)j5Wr)0eQQVQTI7V9EyRe2adRnIX394JMKH67XvEUp(3MTzxSjf7y678TRXag37(TEU3O3Sn1Z1FxXYlr0OKF(fJBrueTxQcqe6cTIier0aF6vZqxOLUyM09JOekCAXhUchGspBdkfjfGS0JIUuBwXRgH(H2XTvLl9uNBv(ibIFg0CqplW5QkZFEkmQ5KLo)kPd()QIW7IsEjD4LQKhAQjXtCWgMJJ44yrA(d5ZKq0qJloBxTccpfgC88YyFLQxxTYAAgyPSTFILpKxY21K6OfcEdr3YNRq1(qbUh(KSA1Bo)0oehaQFHQH7YQPmV9QLC)0tce1IJU6nf)bUWpuEoU8hSoS8TZ0FQha1loJ53hYo7EHQGWJfWpBGQ8tKhbVu0Qa2pVCfh)c1OugOYkpo8TSCdBOhDsGJsBvWlWEhVSsHNVClsK1ZEvzSNv6AIjX6FV2HQlWBMAPpT)rG0hzZkfiBPP9MVfaYF2w0jbaTJvi12oOaYiNWQJkAQUtPE75UVRC2VJDAkM1Pmz1VP(9Ff(Dz58S6dkq13razrNLEePK0oU2v1Aks(6y3B9wHBLlgHgtmwwD55V8fFaeWrp5d48(hm5jK3lb9I3pZqTBzx6DeQzLgnjoOCn5vgXiURDnrmME)jNEtoMsdtkE0lSScRl07Dy8vLx4cx8cYF4e1BxbiHCVEfMzdy6jsIHJVskWrGIUnwwLDHMZxxxhQmAT6kTDLIXo7rO)Ny800JvUUrRuIxuf7jN)E5vv0KP14DPAMoCo7Yfx9(URT6TTzxKXdaYj971zdQ467QxP67)Svj5P9cOfaan(KvoOYVFfQBDt7Vk(6V1HFBxKwpasEqkN)3fbJOinc7KllE9FROX0KHq5rx5a0YGDGMBAfhA6TaYeM61gAPpqmmtVCnogDj6sSshhgms6Fr8i8KDJ6ULxG(APS302TOeYAZnnoloN)XuuoDxvoBC140sv4SXiipBiiV3456m2UqrEDBkgYax24z6H2MP15naLt81ZKv3lG(yXpUzlbJ1AJxbhjj8FYv27IrCYqPfUQdays7BrOy1hrdlA571kNO0mlJZTIA7XP0PzRipw9C9jvzL5BL17HwwVEB26DJj7B4k(WsHJQmLC7TcEy7Zp0WLMIBadq27hXwO9ZONowkdWlMOlG67Yr9f4g4JRpuG2LStXyLwnUHphg94qx(BP1Y)T8xGvcAPdm1VIIWp)E)NB)J0rarIIB1q29cFoAyLwpCOBPEJZz7d(jhw8K5WgmKV1CO0iZc7ikbE6N3frAXtMmy6OXSqdhdJxfGHBF8BJwXPSvpQCV)Y3)lgdxPqZYyA1vfwcTVic9)gIvksZqWqHOmmu)FHVii4Sbjkg5hXE(reI(yIcFQpL6I87yeg8jCMTiAmE48iyy9PhUfzAUatX2NPEDOO3TrJiGT)VszyaMmy4t4gkPhi)8t6Sf8n4M6UEcnw2B91fZVtoY5JPuUe7dA5YF)wD1)Z7J9VXkTzHiODBhsiDkrV1QdKy1N2mDhQw9LPYDSjDkp22Kw6sH)d)143Gm45oMhPz2d5Hd3uBnoyqZT9qCbuNejBJ9NUYBdAVBDYFQs8WvbLzDC(U1OSaK2wFg1ut(AE7ODnkocHFNN)OlWmqB(ZwVbT3lG7T)RNN(gXVZka(l(91ID4)u43)J9bE3G(fFSX3fSrQwBZ08SwonOn3i66aAY056nwXkVM6LL3dCxGBV6MQN2F9gKvIoSBl6Zkgz1lC7tQtx3LEXzI2opE6gittNZUg4N21PFApxA16OYjXQ(9T0et3dVVStmDCEUpXB2tBEtqUfRyP83MgjhLuXQT31sQwli60YiygN23tFP)S98KBGKubsCDUBZR51NMww)1loEnlbdpc8KcC2l(RRD5WP9NT3951yj)C)gPJSzwnuRHaOcFerD9V0VF4Bvk)APdAio(p5uZnFvaZ9NmT2g8WFxNpI3mF0xKReVqpO3M0KRmH8QQXdo6v13H7t73d0oQoPQwH1a9fPTM)2dAzPXDw)5Nek2Q2gT2zvVg3lPBdYVYxnmuHiD3Wq)xGPGlzO744FqljDMbZKa6MphnIfqesKza6T0nplT(RCwP7vMAjunLCAzBbZ)wjiKVskn8WelXpeTHjonnE2Z9WRN1hpHNJ8vyN7Fok8i97zMkjSsdRc(TKqj)gFHuO7loqKHbVbps1KG0BLWkcXg3r0G4SYiHExKYwnNXIka5YxLhEE6EKWsnqSp3BorA79Uu2Y6qXezxjxOjD2ip8CtpT)H6xDt1fpQsGlTCN3Df8dtjjhQo1Hfymax6DRnyf1E1anhFjTWBo61TDgAK84jlpS2R968M21gZkTw25K(9EN97FiCUbPJEXWhLKx6dO0Qg)nQioGSoQla4yzcuVRsKpkDNlN8uOHLQMWIDc(BML7KvSVLggNPUjz9CgPQncXBjLkp0DK7FU3naZx3P8fYx1F9IxqomLWXsfcqvxc63ZA5dqw1e60Yw5iGlxescJvCp(pTFjkh9A8qXfKq22tqvOTD6ozVdSDtl6OYfzdbO1SI70CIjV)tHyQNdIPQvM06qTEw(yV6iM8Stm5OIu4KyYs1T4fIyYJ9a(NMKBYngmlsVFQUSrv1XHYSgCiuk3iXLs)HJDlFHS8Mpln3n)ooSAOX(TOmCAmXoj50D9hXwTejFNW2wl1ToBWMGBHonFX4zFXuPwnzJa3joy7Syue9xNb))U())]] )