-- EvokerDevastation.lua
-- October 2023

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
    aerial_mastery         = { 93352, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame          = { 93271, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream   = { 93292, 376930, 2 }, -- Your healing done and healing received are increased by 2%.
    blast_furnace          = { 93309, 375510, 1 }, -- Fire Breath's damage over time lasts 4 sec longer.
    bountiful_bloom        = { 93291, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame      = { 93294, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 14,714 upon removing any effect.
    clobbering_sweep       = { 93296, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 45 sec.
    draconic_legacy        = { 93300, 376166, 1 }, -- Your Stamina is increased by 6%.
    enkindled              = { 93295, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    extended_flight        = { 93349, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance             = { 93299, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    fire_within            = { 93345, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    foci_of_life           = { 93345, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over 4 sec.
    forger_of_mountains    = { 93270, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    heavy_wingbeats        = { 93296, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 45 sec.
    inherent_resistance    = { 93355, 375544, 2 }, -- Magic damage taken reduced by 2%.
    innate_magic           = { 93302, 375520, 2 }, -- Essence regenerates 5% faster.
    instinctive_arcana     = { 93310, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    leaping_flames         = { 93343, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth            = { 93347, 375561, 2 }, -- Green spells restore 5% more health.
    obsidian_bulwark       = { 93289, 375406, 1 }, -- Obsidian Scales has an additional charge.
    oppressing_roar        = { 93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    overawe                = { 93297, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 20 sec for each Enrage dispelled.
    panacea                = { 93348, 387761, 1 }, -- Emerald Blossom instantly heals you for 15,108 when cast.
    permeating_chill       = { 93303, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by 50% for 3 sec.
    potent_mana            = { 93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by 3%.
    protracted_talons      = { 93307, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                  = { 93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall                 = { 93301, 371806, 1 }, -- You may reactivate Deep Breath within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic     = { 93353, 387787, 1 }, -- Your Leech is increased by 3%.
    renewing_blaze         = { 93344, 374348, 1 }, -- The flames of life surround you for 8 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    rescue                 = { 93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    scarlet_adaptation     = { 93340, 372469, 1 }, -- Store 20% of your effective healing, up to 9,442. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk             = { 93293, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic        = { 93354, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 30 min. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    tailwind               = { 93290, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    terror_of_the_skies    = { 93342, 371032, 1 }, -- Deep Breath stuns enemies for 3 sec.
    time_spiral            = { 93351, 374968, 1 }, -- Bend time, allowing you and your allies within 40 yds to cast their major movement ability once in the next 10 sec, even if it is on cooldown.
    tip_the_scales         = { 93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian          = { 93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5 sec.
    unravel                = { 93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 23,543 Spellfrost damage to absorb shields.
    walloping_blow         = { 93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr                 = { 93346, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8 sec.

    -- Devastation
    animosity              = { 93330, 375797, 1 }, -- Casting an empower spell extends the duration of Dragonrage by 4 sec.
    arcane_intensity       = { 93274, 375618, 2 }, -- Disintegrate deals 8% more damage.
    arcane_vigor           = { 93315, 386342, 1 }, -- Shattering Star grants Essence Burst.
    azure_essence_burst    = { 93333, 375721, 1 }, -- Azure Strike has a 15% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    burnout                = { 93314, 375801, 1 }, -- Fire Breath damage has 16% chance to cause your next Living Flame to be instant cast, stacking 2 times.
    catalyze               = { 93280, 386283, 1 }, -- While channeling Disintegrate your Fire Breath on the target deals damage 100% more often.
    causality              = { 93366, 375777, 1 }, -- Disintegrate reduces the remaining cooldown of your empower spells by 0.50 sec each time it deals damage. Pyre reduces the remaining cooldown of your empower spells by 0.40 sec per enemy struck, up to 2.0 sec.
    charged_blast          = { 93317, 370455, 1 }, -- Your Blue damage increases the damage of your next Pyre by 5%, stacking 20 times.
    dense_energy           = { 93284, 370962, 1 }, -- Pyre's Essence cost is reduced by 1.
    dragonrage             = { 93331, 375087, 1 }, -- Erupt with draconic fury and exhale Pyres at 3 enemies within 25 yds. For 18 sec, Essence Burst's chance to occur is increased to 100%.
    engulfing_blaze        = { 93282, 370837, 1 }, -- Living Flame deals 25% increased damage and healing, but its cast time is increased by 0.3 sec.
    essence_attunement     = { 93319, 375722, 1 }, -- Essence Burst stacks 2 times.
    eternity_surge         = { 93275, 359073, 1 }, -- Focus your energies to release a salvo of pure magic, dealing 17,610 Spellfrost damage to an enemy. Damages additional enemies within 12 yds of the target when empowered. I: Damages 1 enemy. II: Damages 2 enemies. III: Damages 3 enemies.
    eternitys_span         = { 93320, 375757, 1 }, -- Eternity Surge and Shattering Star hit twice as many targets.
    event_horizon          = { 93318, 411164, 1 }, -- Eternity Surge's cooldown is reduced by 3 sec.
    everburning_flame      = { 93365, 370819, 1 }, -- Red spells extend the duration of your Fire Breath's damage over time by 1 sec.
    expunge                = { 93306, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    eye_of_infinity        = { 93318, 411165, 1 }, -- Eternity Surge deals 15% increased damage to your primary target.
    feed_the_flames        = { 93313, 369846, 1 }, -- After casting 9 Pyres, your next Pyre will explode into a Firestorm.
    firestorm              = { 93278, 368847, 1 }, -- An explosion bombards the target area with white-hot embers, dealing 10,916 Fire damage to enemies over 12 sec.
    focusing_iris          = { 93315, 386336, 1 }, -- Shattering Star's damage taken effect lasts 2 sec longer.
    font_of_magic          = { 93279, 411212, 1 }, -- Your empower spells' maximum level is increased by 1, and they reach maximum empower level 20% faster.
    heat_wave              = { 93281, 375725, 2 }, -- Fire Breath deals 20% more damage.
    hoarded_power          = { 93325, 375796, 1 }, -- Essence Burst has a 20% chance to not be consumed.
    honed_aggression       = { 93329, 371038, 2 }, -- Azure Strike and Living Flame deal 5% more damage.
    imminent_destruction   = { 93326, 370781, 1 }, -- Deep Breath reduces the Essence costs of Disintegrate and Pyre by 1 for 10 sec after you land.
    imposing_presence      = { 93332, 371016, 1 }, -- Quell's cooldown is reduced by 20 sec.
    inner_radiance         = { 93332, 386405, 1 }, -- Your Living Flame and Emerald Blossom are 30% more effective on yourself.
    iridescence            = { 93321, 370867, 1 }, -- Casting an empower spell increases the damage of your next 2 spells of the same color by 20% within 10 sec.
    landslide              = { 93305, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 30 sec. Damage may cancel the effect.
    lay_waste              = { 93273, 371034, 1 }, -- Deep Breath's damage is increased by 20%.
    natural_convergence    = { 93312, 369913, 1 }, -- Disintegrate channels 20% faster.
    obsidian_scales        = { 93304, 363916, 1 }, -- Reinforce your scales, reducing damage taken by 30%. Lasts 12 sec.
    onyx_legacy            = { 93327, 386348, 1 }, -- Deep Breath's cooldown is reduced by 1 min.
    power_nexus            = { 93276, 369908, 1 }, -- Increases your maximum Essence to 6.
    power_swell            = { 93322, 370839, 1 }, -- Casting an empower spell increases your Essence regeneration rate by 100% for 4 sec.
    pyre                   = { 93334, 357211, 1 }, -- Lob a ball of flame, dealing 4,944 Fire damage to the target and nearby enemies.
    raging_inferno         = { 93277, 405659, 1 }, -- Firestorm's radius is increased by 25%, and Pyre deals 20% increased damage to enemies within your Firestorm.
    ruby_embers            = { 93282, 365937, 1 }, -- Living Flame deals 905 damage over 12 sec to enemies, or restores 2,526 health to allies over 12 sec. Stacks 3 times.
    ruby_essence_burst     = { 93285, 376872, 1 }, -- Your Living Flame has a 20% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    scintillation          = { 93324, 370821, 1 }, -- Disintegrate has a 15% chance each time it deals damage to launch a level 1 Eternity Surge at 50% power.
    shattering_star        = { 93316, 370452, 1 }, -- Exhale a bolt of concentrated power from your mouth for 7,534 Spellfrost damage that cracks the target's defenses, increasing the damage they take from you by 20% for 4 sec.
    snapfire               = { 93277, 370783, 1 }, -- Living Flame has a 15% chance to reset the cooldown of Firestorm, and make your next one instant cast and deal 100% increased damage.
    spellweavers_dominance = { 93323, 370845, 1 }, -- Your damaging critical strikes deal 230% damage instead of the usual 200%.
    titanic_wrath          = { 93272, 386272, 2 }, -- Essence Burst increases the damage of affected spells by 8.0%.
    tyranny                = { 93328, 376888, 1 }, -- During Deep Breath and Dragonrage you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    verdant_embrace        = { 93341, 360995, 1 }, -- Fly to an ally and heal them for 25,295, or heal yourself for the same amount.
    volatility             = { 93283, 369089, 2 }, -- Pyre has a 15% chance to flare up and explode again on a nearby target.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chrono_loop          = 5456, -- (383005) Trap the enemy in a time loop for 5 sec. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below 20%.
    crippling_force      = 5471, -- (384660) Disintegrate amplifies Permeating Chill to reduce movement speed by an additional 5% each time it deals damage, up to 80%.
    divide_and_conquer   = 5556, -- (384689) Deep Breath forms curtains of fire, preventing line of sight to enemies outside its walls and burning enemies who walk through them for 30,269 Fire damage. Lasts 6 sec.
    dream_catcher        = 5599, -- (410962) Sleep Walk no longer has a cooldown, but its cast time is increased by 0.2 sec.
    dreamwalkers_embrace = 5617, -- (415651) Verdant Embrace tethers you to an ally, increasing movement speed by 40% and slowing and siphoning 5,255 life from enemies who come in contact with the tether. The tether lasts up to 10 sec or until you move more than 30 yards away from your ally.
    nullifying_shroud    = 5467, -- (378464) Wreathe yourself in arcane energy, preventing the next 3 full loss of control effects against you. Lasts 30 sec.
    obsidian_mettle      = 5460, -- (378444) While Obsidian Scales is active you gain immunity to interrupt, silence, and pushback effects.
    scouring_flame       = 5462, -- (378438) Fire Breath burns away 1 beneficial Magic effect per empower level from all targets.
    swoop_up             = 5466, -- (370388) Grab an enemy and fly with them to the target location.
    time_stop            = 5464, -- (378441) Freeze an ally's timestream for 5 sec. While frozen in time they are invulnerable, cannot act, and auras do not progress. You may reactivate Time Stop to end this effect early.
    unburdened_flight    = 5469, -- (378437) Hover makes you immune to movement speed reduction effects.
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
            return 4 * empowerment_level + talent.blast_furnace.rank * 4
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
        max_stack = 1,
        dot = "buff",
        friendly = true
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
    time_stop = {
        id = 378441,
        duration = 5,
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

spec:RegisterGear( "tier31", 207225, 207226, 207227, 207228, 207230 )
-- (2) While Dragonrage is active you gain Emerald Trance every 6 sec, increasing your damage done by 5%, stacking up to 5 times.
spec:RegisterAura( "emerald_trance", {
    id = 424155,
    duration = 10,
    max_stack = 5,
    copy = { "emerald_trance_stacking", 424402 }
} )

local EmeraldTranceTick = setfenv( function()
    addStack( "emerald_trance" )
end, state )

local EmeraldBurstTick = setfenv( function()
    addStack( "essence_burst" )
end, state )

local ExpireDragonrage = setfenv( function()
    buff.emerald_trance.expires = query_time + 5 * buff.emerald_trance.stack
    for i = 1, buff.emerald_trance.stack do
        state:QueueAuraEvent( "emerald_trance", EmeraldBurstTick, query_time + i * 5, "AURA_PERIODIC" )
    end
end, state )

local QueueEmeraldTrance = setfenv( function()
    local tick = buff.dragonrage.applied + 6
    while( tick < buff.dragonrage.expires ) do
        if tick > query_time then state:QueueAuraEvent( "dragonrage", EmeraldTranceTick, tick, "AURA_PERIODIC" ) end
        tick = tick + 6
    end
    if set_bonus.tier31_4pc > 0 then
        state:QueueAuraExpiration( "dragonrage", ExpireDragonrage, buff.dragonrage.expires )
    end
end, state )


spec:RegisterHook( "reset_precast", function()
    max_empower = talent.font_of_magic.enabled and 4 or 3

    if essence.current < essence.max and lastEssenceTick > 0 then
        local partial = min( 0.95, ( query_time - lastEssenceTick ) * essence.regen )
        gain( partial, "essence" )
        if Hekili.ActiveDebug then Hekili:Debug( "Essence increased to %.2f from passive regen.", partial ) end
    end

    if buff.dragonrage.up and set_bonus.tier31_2pc > 0 then
        QueueEmeraldTrance()
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
        local power_level = args.empower_to or max_empower

        if settings.fire_breath_fixed > 0 then
            power_level = min( settings.fire_breath_fixed, max_empower )
        end

        return stages[ power_level ] * ( talent.font_of_magic.enabled and 0.8 or 1 ) * haste
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

        spend = 0.10,
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
            if set_bonus.tier31_2pc > 0 then
                QueueEmeraldTrance()
            end
        end,
    },

    -- Grow a bulb from the Emerald Dream at an ally's location. After 2 sec, heal up to 3 injured allies within 10 yds for 2,208.
    emerald_blossom = {
        id = 355913,
        cast = 0,
        cooldown = function()
            if talent.dream_of_spring.enabled or state.spec.preservation and level > 57 then return 0 end
            return 30.0 * ( talent.interwoven_threads.enabled and 0.9 or 1 )
        end,
        gcd = "spell",
        school = "nature",
        color = "green",

        spend = function()
            if state.spec.preservation then return 2 end
            if talent.dream_of_spring.enabled then return 3 end
            return level > 57 and 0 or 3
        end,
        spendType = "essence",

        startsCombat = false,

        healing = function () return 2.5 * stat.spell_power end,    -- TODO: Make a fake aura so we know if an Emerald Blossom is pending for a target already?
                                                                    -- TODO: Factor in Fluttering Seedlings?  ( 0.9 * stat.spell_power * targets impacted )

        -- o Cycle of Life (?); every 3 Emerald Blossoms leaves a tiny sprout which gathers 10% of healing over 15 seconds, then heals allies w/in 25 yards.
        --    - Count shows on action button.

        handler = function ()
            if state.spec.preservation then
                removeBuff( "ouroboros" )
                if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
                removeStack( "stasis" )
            end

            removeBuff( "nourishing_sands" )

            if talent.dream_of_spring.enabled then
                if buff.ebon_might.up then buff.ebon_might.expires = buff.ebon_might.expires + 1 end
            end

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

        spend = 0.10,
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

    -- Launch yourself and gain $s2% increased movement speed for $<dura> sec.; Allows Evoker spells to be cast while moving. Does not affect empowered spells.
    hover = {
        id = 358267,
        cast = 0,
        charges = function()
            local actual = 1 + ( talent.aerial_mastery.enabled and 1 or 0 ) + ( buff.time_spiral.up and 1 or 0 )
            if actual > 1 then return actual end
        end,
        cooldown = 35,
        recharge = function()
            local actual = 1 + ( talent.aerial_mastery.enabled and 1 or 0 ) + ( buff.time_spiral.up and 1 or 0 )
            if actual > 1 then return 35 end
        end,
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
        cooldown = function() return 90 - ( talent.forger_of_mountains.enabled and 30 or 0 ) end,
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

        spend = 0.12,
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
        charges = function() return talent.obsidian_bulwark.enabled and 2 or nil end,
        cooldown = 90,
        recharge = function() return talent.obsidian_bulwark.enabled and 90 or nil end,
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
        cast = function() return 1.5 + ( talent.dream_catcher.enabled and 0.2 or 0 ) end,
        cooldown = function() return talent.dream_catcher.enabled and 0 or 15.0 end,
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
        gcd = "off",
        icd = 1,

        pvptalent = "time_stop",
        startsCombat = false,
        texture = 4631367,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "target", "time_stop" )
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
        icd = 0.5,

        spend = 0.10,
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


spec:RegisterSetting( "fire_breath_fixed", 0, {
    name = strformat( "%s: Empowerment", Hekili:GetSpellLinkWithTexture( spec.abilities.fire_breath.id ) ),
    type = "range",
    desc = strformat( "If set to |cffffd1000|r, %s will be recommended at different empowerment levels based on the action priority list.\n\n"
        .. "To force %s to be used at a specific level, set this to 1, 2, 3 or 4.\n\n"
        .. "If the selected empowerment level exceeds your maximum, the maximum level will be used instead.", Hekili:GetSpellLinkWithTexture( spec.abilities.fire_breath.id ),
        spec.abilities.fire_breath.name ),
    min = 0,
    max = 4,
    step = 1,
    width = "full"
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


spec:RegisterRanges( "azure_strike" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    gcdSync = false,

    nameplates = false,
    rangeCheck = "azure_strike",

    damage = true,
    damageDots = true,
    damageOnScreen = true,
    damageExpiration = 8,

    potion = "spectral_intellect",

    package = "Devastation",
} )


spec:RegisterPack( "Devastation", 20231116, [[Hekili:T3ZFZTTnw(zXZov2QXw2I2ojTxKNjo2z30z32mrE7n3)yzkrizUHIuhjvCChp6Z(9(bajiiafLTC2T96C31lwe4bG37H3VbW19V(QRhg4NlU(N9oY74(97)YEh9QJFL3Pxpm)(fIRhUWFYN9Nb)Jy)5W)9cXx8ZY9ZdtIXVDFuIFacJSKLPtGVFBE(ISF8WdNfMF7YX9MKm)WSW5lJOEmj1FAo(3toCCuY4dds9NLepnkC2T5hkINfgloCsKFw2O5jblJezh6Vic))gj(sYNfP9MSyX1dhVmmk)dXxp2(m)eyYSqm56FU)jV8vWekmiqWnwKn56HyJpOF)d6)YFC1n)Zm)XrIv3eMlMV6gFOLb9w9tR(jvJo6vqJ(OF(KBxDt)J65T6MLlWXSSrh9Qd8obA0Bd(xlZYxDZWfjHrzRUjpnm(Zc4hIsMforR9V8apCKFF4xxDZLdHHoE1nzHXZIehK7NotKxTT6W(9NFi2d)4Gv3Cri0PCXS0QZMxEWrhd94D36hpdwx)QinWpg66LZhN6pb(LjjXbHiTi7)A1nPIS8Ku4xJtIp4QJpQyiwMbKCnWE6bE)aa2)ryCsQchalYPPjaAByb99Di9TA3En0TlJZwIJIe4t8HL80W4WmaRgofWv06g(3ai9hNSe(N5jRUjieMc3S6M9Gbyru40qG40vh49rKZNeFjmda(UdgSl3VDX)XuCIcl2SWSCr8K7RmR67bD8da7OyUio3pIwdVtTWGrminzbmz2nlFuYcrSifG4I0WK0W877wbuhHlWHlhd7jIZdrqnHW9z8CHHlW5dq1FMFyC1oJlGgMjz4I)w)8CbWnnd(gGP2h5DqS55Pc)8BH)8s4ZXWedNhaIe(LpEFk()7Vh(fQBVpc26QpTp5GJpIg5)jnmbAuY3jrDa3E)k94Ot16r1omjs4htJ0Yfa36VCzjYcw1RUzCOotXXmodOCaLg2XxI2TYoHCPiZccECDjzobaNJSitNksfihUIjAsYY48m5UeGQm5ZWFKmL2taTa(XZbjm6tipMrc3NfGF)csQukniVnoCEsgTq(iiEGMfa3XOf8F0fgcroSkM176HraRwgkluG)3FMeTkIrbmbxF(1d9NWcnfsY1OmKAb)98fj3jshLNC9W(xpCcG2aYTp3HVigbSFZdrwH3mailRU5f4AncwZ9uqkBu2c)4EYXA1np8aGZxoDAVGIvspGbd4(qOaaP3RoD1nFpm3xiIIgDlGoGLANg60z8qB2fBdeYcaGApGcym)byCk3NDw7sOt9UJZHxY9)X15xV6MUSwG0WfmTO(wNLOSKu)4pV6gGWd8t(lazpty1e4oAMplR315GINwsIBMM6r0upc9(ePSE9EmewlSdvzl9Wf7XBLf7X0I942Uyl5uMMedcJNoAUpQpTLyeCa759iWjwqKvrjhJOKtAjkrVJNaDmhmrj3MmIkmNdVcK)qqefLNLVpANYUzKi15ISS9X1qU6hNXYHGFtG6l2rzW2NbXEXak8RJYVvmAAykOtJm4sNsTJZ9Xbc6dzfAHgbYuthj)5GK7IPML6hgagPHeQ5jFHuM1dTS5mypBjEX9CXYMPYzNlG)gAxthIlHMo3cFnfM5xpe2gdmlthnBsaILlMbulmWZ)djmbSmARgGwVkCUaP9HPOgzYcoaLJtuWujbY2LLGTi)oH)NjKod)SEz5VyWH5q3hX9E)WPdSp9FZXDMKKeHyq58wYaE2GJ7St1Ltd7(aKize3CtMhWSfuVU6ZOk5KjaFYBh(2pQJCzYBS)cSPYbZfFDj7HXO9jrK)xn1DEzCE69ObA)Vldz7BqwwW6V4esREuima3J)lF0(68Bdtbii(AonZxghisrlttNtwvvy3kOB58OKKGiYMyqyYhX9wOvutxMbn4qWOxaQ3cKl4)YB3Nj8t7IQ4VaS)mbM0Zd)nYedqV)VeJtIj(i0qRrNSmLTOyktWVlmczcOVFSxgmGO9rGnLOHgc6FgKX2XdESG29DlAG7XhLPJMlO1iAE0yY2TkIUpH4KlAwvrivvFFe1uP3ceZwEYiWAzw01XEsPIj4KPJCDmshchFesLp1bvopCbT)mBcSvnZGsFv4c0MhKCGg0ZOmIGUiY)EAVakPMn5IKvZ4lSzfT4YZFpWjKads6DKX75iuVCyVAmMwnSG)FBLQbLkgyJ04LPOvKJMIwdx2QUvX7UipRLW0KgfKODcnu4CAVwaT3SUPuNkwr5E51zDyPUOvra3WlBsve7Xbphkeic78acki7lf2jaqAbVpm7obUHbj43NSe0GKeVBoUt8laiweYSd8M3Ll6zcKXr()gXJaACsP9vaCahfYcdemt1fFQ3wyN8R3SnYQ9gWwIOr8FmcT3xNHTcpPgBqfgYV4NII9e9IbbDJc0exEM2hrpmsfW2qstsUPTq(kVsmzJ5DgeFiBXbrmQWwvmgP9hHOkAm0SJASs2kTHR4NzWfkLXw9BgBslMks4re0rm9CJMk1HBbO3X9Ei1uRY2dG1)wWH0FlPU9LnUeCjK91Tqgl5UbYKmITeB6yCF2RCPBvlGog7((NOis9a(aBxMsCSOayoafmFlS3OjrOLM4ccK(Hwi4dAN3R1fIiUhTRc5dcJRW)1H8eE04K4Lza6sKE8rJ8wmbxXV2Xk2WMstfn3MMChhYdmakG)7xa6mUGfMGggnXFbULgfi9w4pWaj8RHZss7zSNKqcW(zyJoSaxc2C2JclarLS8X5(FDKSbg76Orz0xObP(gVDCGmBn)ijg(hAsmSH7Q)PK4)us83mjUBtjHGvLaRE)JAIx))2pmxglszCJXOVmwq(leCpZxLHE5WoGftMtU6M)67Ua4VswgfqX3EzuoZibFvXrgNG7CINHnFAO0Tzy2QXydsNetA2Q9swX7GPQo7NBEdlgjknRTjBhbNyrPsKZooOGFVecvTDV0)CNG)G1QcyWJzqj6Rz0nQIsTB67)rHvBlIZLv8N9OrDUISyefsF2iF7E8t85SK1(SCvpAtrMI1M1MofKalsZ4DvIVgMR0L6HUNL1chXAc3AxTRMM1dAsVCxc)uqFuJf6HdO)rgJI(Mre5)uMWLel)FBzkQ0in8ZcAk7kUkRNQkx7frXbPv0FlTeAbjddK3rPHTo5Re3vrvrKWFrXiNP(6owxRA2X0qFFcwBXQAKFUxGyA4eKTKchlH(CfWIf3N6aTTGsyeQPaO4sX8tH9QjQaBkt6ifOAzoJitLyBK8oYifsNZBE8UshblJfAy8OIOTPWgszw8Gpso21fCnHtn1OXuMPKOJb843XEYmymsJoTFbU0KwiEPFkAr27U1h1fsXSriOSDrAyHPTKZbdAtmS7GIsj0HimYmsVnypmk(tza7YdXzlbM5uYKdNVijnNs784L5um72htx3CYoouDCgyIOmM4CuSLm3WAD4WEA)arqgoususyRkPP0uvqLgNqHKGSITdBwBygzNlytlqMWvmLyn07P00LlYhfofqACbfGXjgbiYj3PUCJo4Il7SbED2BN9SB9vhPnxL2Q19HhC4iG2hQ50A3o7zpqXN59Wd0yOchmylLajNJO1M5Qr7t4AQybySV6nEBY4T(yXFgP5OWqYYiXB1)wK31LJWUIO9FZh52yl4yoHkoJmSOYi(ekEmgWYzBRuCqZxxUXgia3dysSv)2HpRswVs6bMNXy2Zg)GGmL)qtOKkmwmL3gLVl(JAw8sfqqz4uzHl4E4pCrV2TuTkjrZFfnQloXyklMIqPKOshFsIV)RJIeZ8Nu11hzaoDbOxEKUCrxaH8eUVPRWTzbkbC485HXOt2a9ipDjrPQi2DN1r2RW6QrHXev1OFl)vSieEB8KqYFxQ0la8Egw1gOfxTZb2cBDjWyjMUkmq1wyO)25sthvbwEMgjYh5h4VGRRlRdufuDfN5MLke0oepxv8qdM38oA78F)91ISW(ycDuMRwgmb2g1pKgIqHKN1c(cjpjRLUSRGtQbvSvx8vXKL5ctNI17Y4OL6ri0C)eUvHqfM2VxnA6aLFSVMwtwoQtdhZX(p1hCLTiNXQw()UuefPpsQePQAWsan8fHztCLnXfjkoED7ieuCHwKi9KgZlDrmL8rrvAfTfkg(aU2j4C7fj(czkaTuvXQ8oWvDHec3rF(IpDWzV)8doB4WdolnrvGHR1MEJ4UzWXxq9Di3R76JDXP2YhAYc0zwncMYlp8FbCiAE5w3FddS7Vk7QY4ibcbU2VaSumAO2xHFwp(uODDJVhJYrkN9zg7Jo(bMthoF5CuTr(DcHkUh69EsqPHUPvSdlCwCcxOzVd33jMovmbNrzWgcCg1JwOYT9grnZwcfr0ufhICJMC5b9bQcJPW5QgNbM2dVbZaRb)4G2oWUmMPUqEnjNYAenZwqYRWJ8by32DIDPTArsJbK0no4xvRjqwyjMR9BfOuMqSE4KTNl0bytPiQx50mDzC1zjk7zsov6eL7blhsDSLLCC0yqSx7IjUwjn(nybzwYoRpALtCwNtOTWvgrNZkTrXprynOzTPVz5Swcwv86QRO)AkjyyiwAtzufVfWYUHj8mkOOvnFPCoaQPs9Jq)ubjMjZRPS5lC5gpsWvBCvLo58A0YSB9ItpXyjq1yk3AG2Z1g1BNKVe2Tb8mGqXaFzzPIr79omlf)YcCrZ2pKrjvszOnkRdx(zKp)qhNfLmgR5evjKMwy4HpwKQcbgImDbcvssGKq6kcEnN1RT)SCs9sqPQTCnyoGMmoJWRiuEAXzMtnYyGvsb75tvCuOYNm)PcCRmAyhRKkzmlB9IpoeJqrMmmK3MejHkzSGUMPyYjOisNh2i0CmGjjb14D)yLPemaQABYSezrPKwg0)l(u2wiXvp(Ib6jx6oUcKyJLUZ)SOsBqKnvS0SjhzGLcyWwMnlnPD2CzkX7XvzNotxAxBwtyXVHQk9oG2gWsWiYnLYTdRLhZcpnqoTNmxWVJsFjizAtYFPw8UADYllIv)2mhKD26jGKntPXONYCy1me5pmmzUCuE9CE61VMT0P0m)xNV1mwplmqSnHoRLhNHeK5QUqVUj5OQV2WyyZjH2ztbRSgDmNDOetQsqIiROsAMgHMiD557RLxjQkxWA6b7lRKVg3ZJlnpRVOAwRleLs)L12SYiPY6bOmJg2ISSn75lIbcLnPj3dMposEypmCBWw0eo1ykYhvPtV6fnAu)JBSorl0hs0y1mivz7QSfFjbpuvrvf1BDsFYvkZ5W(ugV5Qv577Oaj5mr1pUv2X6rM02mwTtUPfDNMYGP2hTgxpPaU1Izliaogh9mL6kaIDDrbW9BhlJYMgcxARFSiKl1LlpNjoim5HIJnec(dsspqDG50bNjreJnnAwmhJAozAxQgPQawMuTv0jVtAzpDkiabQ0XHQwk5BpZaHNSMguk9d23DXmP9p1mjT0C5rKR9YGrZqwMHBqJaLIBeb(JMyqzQk1ZIjtc2xLouwV8jOcBItFFMOjJ7oMbivG3vD1ScglzgvPXVYgCwVOwc(DfXZt0AVLW(xATf1InT2a6uK7EsjGkFJujCCGmU41sHFDhuasjYUHyJtVsYFlafuFBppt2CW50sMOgpitnNv()NemOFbQaZwPQELjRxEoybGS1YED7t1B7tT8E1hXhEWmnZd639rnnQqlH2sB22gPxEd2)xTmeuNrkUgCKw)dwlHmT)RLHtWssmgyM0o0vzwYPxXrTsxvIXwyAb0yeH1sHKrAfRN7OIWm3WHsoamwD(4q8mxnkkjzowK3iR9m0i2rKKBBBwVOSBLwjQIj26HOLWKvzm(57NVKK7MPctzr0W083vLkDTc35JFyFAdM0A3Y(t5FNQQ8c9fxYb1C1nxL6hJbTugKFAShjZFgjOa2MfG4HkcNlQCmzSrZjOWg7IbwwtngNP9c3uU1pBeEA3qjjJW6wXY5dYA5QvyO0Ap1sVQAZA6qLPm9YrKPovj9VXP)6sOgvttLCDUXXneusuBa4PCusghQRLXOBU4waZd9jtiD3(k0rmpp6UWEuVtvw5vG)CoFl7P0Up8mpUyHiWDx2e8vLnfNxSEmzSX4Ww3gpEt0(M7eKfXvXwSPLna7km1BkqJOjTazhrOGwH8BZgnheE6Mi4U9LeHAuG16xEnCdju6d0yHBUNEavn4ffmdQXTs0viVBZsaJFSfXXwOY49Hsp4bX(NZYVpuMFf6OJF4B)n6QpHLhZgztYP44(mwJwk1NanAxm697svTBnBKnkKZc(mxC5vfa4QvvfUOx5TfDfMfZhnjyu)(N0VNmTDpVBpSfIUAQtDxIm)Hg10qi(SvAoMgdvIg))hyjZkX2vG0KMkbITaNIZ1)7jTiRiBGPaCiCmoXC9XtmNUzaf6ALZJrEJWbitPl2zcu6S(YIPt7XJ6rf5PpKnUODeui9dzNex0l3JmbrnIYGDv(XIPsfENAO0YBQOb0jMWAJ8alDMeTmqOMk7yPr9bDAXlrnpvMj97H0SrbltLo5JRjdDzgDO08VIo9MYINCV1K8hVJAtK81rPUYfWArwMHV6ku9vXvFg7ffPsdVngeOgpvXefGqpAPyFLQymjUSLjK70sNUw4dSzbkqvA1pDWdVs6yJmtVLgcDs1iczyHVw13wyKuqYYXrfX6sUck8HibpCP1mDA4WdFVksz0IKRul2sSE2cITHygV)trSs))uSI(2VgeR0)rjwXZrJ63gXkE2fR4TPIv8(DIyfpsSsf9VEnMWM2O02U86sU(9AHQd7ehjm6U1XHnPIXsj1jpseOKkKWs3JzfsIxKM8fmheKFk4mwDtNrYTKNCwSBfR8v38lQ0(Os3W6HgN(GkWPX0FztoyJyzdkLRDJnsT)2qP8kOu14KZP6pOHGXvP4kDE9aUNZyCBl41E6cCnBaRmVJ(QT5BmhjCmh)kbuABDjdAAJHXTFP2f2N)cGZeKLqXsV8U6d5gxgNFiVYA(M7RcQ3mjmR)G(18fXJn6YXRHU4TTPlBTRiqIY06Bjq3i21VWSm7CWPtzIVatuI1A4gIAVVb0v30JbBXlOWAeKgVJcDkKrEbfUivmjz(y)6N5KXOTZiMqgr)XPjX)MrX(wBd26RXxddWW4iYwJBya2)o(yywV5HPPjP4AEAkSgwcULaOR5jWVIh0WYIb2qHJTnfBaYWRPj2)E(4Jbz4vImCCyAWCnwkxO1gRz1z5VZEgukBWGIOl3C7(U1nsmGmvrDHycv7F3DBiDZgQmCc1jHE0w3F29rRQetrZS8WRAY4L0T8e6Az)Y)wcihSBz3hpXjl1irug8VpQ3Pf8y9TfZBnQHnivNUYJAduoxgVz1FKNfkN1rQGY1i6X2bkQL7CjPgz01bpUrjweLFRF6Y6r7bAM7GVwVTnKyYkmHxQo2wKz6kwhzyxwrhGmqa)cy(JbaHCeO0P3IA1x2V9Xsvan6pG7jx8cfiZIMZcmc1Csa8K4V5ZZbmb9WQcptzZtcWl0DybUNSUxrVx6370V2L3MmluEmhOihLQFJIJFwduQvgmqu4NSokz3Y3iqyuM4lO9aozmATUCecXlKD)me1HjLjqi)tyiEBgE6LWawjxuLJrXvsG)k9yGHTnjv9VOCZH7zuYau48QNUUYD1s3iSee)nGx0RD8IEBaVO3A4fTjROCTyga(nyTqBcsxo((r3DRiAXOSBjYr9nkG0xW6iK9EeqqXc2jxmkCIe61q0YqXylUDBWSZRfZoVnE25Pp7QfiKnuMTIpFDEDRRY1TuDRb0XqM)Af7FyLgG9vlWwDjdD3JepWx)9LnTQHkfT0YeI3ZX5C)SAZkRk3pSsdA9SY0ws3ZQ(AZQQkI6xWz5znckRNJSFVJQFdMxrbXNiNM7xCqRKTvLBASgq0zF0RQ(RTv6V4CcCFY1SY5HLBO6WTx7y(vE2OjzRC5Rthco(4UHN3ls7L6OIjB4YfGMn6d4PVatp)BtUShvgIVNQTU5OAemveyBojtmbJFSyEgEyc)SkSy0XIceAMx9Iw)l01l9C(PqbFakWkiagy8W6bdWFtnN0UrC4sa9LRKxCYzSgYXIzK7C89AhF5F4ZNho7Lt7JbbNPD5bmeG4ZfcE4v8C206E5bu9wFyVf4Kqs6yYTXK0Q34bUAGTAgTyTBEAtRS0O7HJHQIS9TfL5QTsYZ5vGX12kNZA9VmQbQwvXl7YJCG70WRfQc3aRsDOipYVasaViIupcsh9k8IZJcurMmDC81XKKWTRiBx8Wrqxj7uTVqCDlbN34KYjF9A6T6N(70BZsF81ekjggg6Z7A9K9PE4DA8y)bnAV(FT7VRHS3ZgKp(BnKResmdaBnCzLWD1pzHXklFZySoDRpTAeU1IGNjU0ve((pe4)KXlV0oClDE2aO1t3rlHyXrk1aG1oQPTeEvUTKRJvRFtkBc3x5aUvVkRnHS9l6Aty)Ah4aTt1MjAWYbERLq9jJj(HTopGdi(O5b6F02gGoug84bOJnOPvUJhnGAQ1laYAG2bDx7AsZaUwUa1(2auh0DB37AgqVPRMnZHXZj3GwrFwJaAPGqBlGRBjOb0DBQ4UnRESiDk7UrAjRzWH0jt2htzARKrWQyQw1r0AnQzlA28bq5P7Ja0CrGFFtZ8YMSDb(tywdFltEYuBAMxTzB)b5jScOWb00Cx1GTjGFcZx0rPMMUYVVfb7MpzxxAXSmqTOlnBkVeuETzZQJgTThaxiUwaAxByT2KTlWFcZ6M2O6SzB)b5jScSVP1sd2Ma(jmFTUTT(33IGDZNSTyRT5a1IUuzWpXPOOAXY2IShBT5zf8pBa(FtZ7KfcUfzCeq31vcu6SxtW)7(UMsK9GJ0UZWT89V77Ac2doQRAj(iNCpP526MAfy2AUuvSnA9Km7TPchX2g8pBa(FtZ71Zj7vJzXc83ACYwGDtCYTBY9KMBRBQvGzRfdRcHp2taVfjqoByfEJghixPW3(O1qRB)q6SsaSpMn18kdATG3vShOLi0gAy7hOwJqxxRB)q2Ee6ABELbTw4G0PIMfUGDINLw1(HWzDpyFSAQ5vg0ArKshzU21LRw1(HO9RR128kdA9iI(e1c8Cd)2az8guPNF89JcwK1e0D1U2UcA74Gkqg9iGFR9kUz3U3gJGlxuCc7hR9Wp3WVnqUD0v3TRTRG2oopo(NnigRps(NnyeAl)tnJf3XPRfUSu7HhCBdxZgX5AlB3VFV(9o9fo2saF1rbH1T7z71SdqUiYMJy)1oI9LJOc))neVD43C82Hpd4TswshPGBRK9g5q4iz0fvNJbKRv1o1aOJSq)iaiLDPPjrrj3rLGLpGAPQsU8qWx8GNYLoeFh5lRInUDuDipLFPFlBDqa24a)C)X(zIFC1pXVZLPH5osRLFcAG5gKqRArNrM(6NEDU4GP4jKCBhq8rN64TFjy88u(bUYzEL7Ntd4A9AsTTaU8ME1aQ1VcyRbshLK1ZaiF6l)Nna7yxL8YIYaKgxIOTvsL6Il0uMQX9zyj4SkWqkvFdRcrxXz39fguHgj5PMunRl(91ExdT(W858YqATd(6UgLw)y)TzL7SeVEI1FHRqj9TaJ6AS)2GrDfZNVfRCxJ93MvUROcX2CQG4UMENu7ZTkut1VdpSayln5ze4RfST3DZw5w7tFyA0Rw3G)X52)Zm4xNjtpbJWCfwW(nZyx7ZTeORL3ZAtEgb(AbB7JdxRySF6dtJm2Ub)658Ar8w32G3nGFYm2Tj0WBGaWNxO3aCF6iIA(T8K2W88c9gG7tary1y(PJ3DJmJ31bZ5lBPZoHRJNZVxGVRdb0Zm8FYNTKNV59QF6dehhc2xxnCwiB11dbUTBtsVE4WW5VdV0AsMgINgsUHz9kk76xm4WXwV3Aw9t2ARkkK7JNFXbYTBQa0UpDeBhuvpF1GS)Wdw(QSeeT(TVuwGFw)ovkDw)cgDo9pSUYiBtwWEwxW2Ykv5mOEnxA9BwxWM1oO1VuDbV(6MB1p9xWNH)N3RKLnbRYr0E)KfdOtTVe72F)Yda(GJ6D6(4rfoeH5G1x8wpJfwM9I3AtwVEp51BTs85zS8JSxIpet0FELQ87SRuLnHlvDvRut6U96hYqKRROWy0m33hUBWm1Z(m1vLoziRC9Z0MlOOnzMwCRQydPAwUngOkNviZMmb8CmbSwVpgyGTYeqTdWu6NNU0V(AY(EMslCtzt3HJZgPQ1Mw)wMH4MsSUJWrzm42SXQPKftIRBXfCsBiL6x8jkDx9o671V5fXrB7DxA87TlRK2GenV1x2xEPKm4eCNbDRMSLXIdVAZNyz5fZR(hRnXSbgSMfW30cgmoUatO1KRRIehtVQxRj7hoDGkvB1kFb7qOO2b06BXVzVl6xTiyV2PE3k6i08)3L4(iTFqQMqAQDKpW0Tq942ou(0tw(MS7pMEw1qYk(S0EaY6LrMRa6LeFXpwfHHKfIybZgG9JGWD0NV4thC27p)GZgo8GZstmWgWecgD4FHlfsOHMfFlx0zVDkKhv)cL)HhqOuEFUE2aVUp8a(ke1PY1R(Bo(udow(1uxGIiyJezUx(zbOCgSIEkbqt(Ulj9ZeplJoO3gF)VgoFj9K2MFh9ocX2fQ17jbs3qa0rA1Nj)zW(CcGVd3fiMoLSct9MlOTtT22aJ7aBPCoBwmRUgABnOGTrWQYeI2FlYoW77vpEmpr4B5jr7Gcq)x(laH7dX4tBiyvV8rmB1nFK1s8H4PlXlvNSvQNnQ73LyB)IFyetQb1ueEwJU8timlNZHe0lFH0q2qE(Zx1UHYbXflk)6k24B(WzdoUJTN9aGDvJdV6lQqNMy97SJvW1vNwy(GdvXCh2xB86O)obJYIKV0psUucP5B(Y9JQx3h9IqGpKfHOlvY2tYqVbKjiIQW8MUmU(Ky649XN4NjGWBeRwoK64G2ndJT80VVLMLImxZYQBjwlGqTO6qYqSL3Abqgvvxa64T)YLvJT2)f8BtYbxmqzYadxaqYMejq0sm(wHV6MFzbkBI93c5Ewv(0m(jPcBFP7MZIsgJ7U4xrtwno3r8TYmviOxC4c1sWYA9wpWB2pHM9p3tfJ9jiQ2MCXLlOzZq6nLdhz(HGrnaXjO2Tz(Pb8CITAZFQa5WkC2FEY4msH4fFCiBDf3A0ShgQKErDz(XiCXffOnbBe(qtdiVeuxY9JvAnzauvn8SKsB)W3aAu23fFkdjVxmev(cO7WFJuT(JaAMEGjytNr4idYGXlQxe99J9YEb7IUiMU89f0)mqwZW8JVdBO5XhLzIW1KTtgWy(KucY98SRr(iIeqVcG5HlKH9GcZhPAMmsgw8ZMLMyoOq7z)HbbCWwuhsLRUh7ndo(fh)9QOzxPkfF4bxsGzFtkFc7lfdEaXtoBwrKpYWWIC44i)FJiuaJykIcbRfYOGzI8dpzA1RFkKk7AdabXa(BVDQLxjnxvn0IFwXhm3RdyYIslswGLDLV9WSMuclP0X)Mc4O72g)4ilrKJy8yZ9q(IexH8ddRnMXx7GxuNqxtzYFyO1U2Rus20j)71GfLUzb68CtTFcu2loFv5JUkIfbcLP8mbSw49)KVv1rwAAoqhIUR4LloirWV7(4dE90iu37LNVpRtHCAGkKx0xDSVsnoRx)fBBzLNWDYIY3y5dGbZSDNABe1kIydPzSZIfAGZaDZS)6WNYa)vMiQXxP5Jjak(P9)0REHzZwaFyF6DJEetRYSA2ZGt1aZjxPu)IL97QIxc2QVqUVRMk)2owN0PqixLc19HhK)Az1g3vBAH0PJLEfRply7skEWLatr43)Eo7cCEaYWyDaYpsspWg4QTYUXpd1TZbxNFGMUunsvbmXNHW2pVW8K5cooz9ESyOJ7udtG71QJY6SJfEp0LeoOFPyIpMWFcM1Kag74EGKyfsa7Rlq1TRo1Hzy6F6QkpIGTNjHtszL62w6Uw)t12Tu(oZdgwVGTedd)c515pAsjLfT9(RkFv6zwH9Rg3Utqb6eUFFM5jtf3jTOgj7AnIQzuGkqWYXuQuS8niUESsor2glh1gubk9n56LhNSsICnAV8hEJ8)pkk6G(LM4byvKZfxqNELCRIaLrASSQgPUpFlgk)iXxjZ9OhBsqDgiG3HS5oYNhidXOJK)mQmRJPzHmD()jbDkoqfcNWmm01ZsPNNQOKzHtqFoWi8o8QAQm0A8(aVuymWBjau69JO)Ae65igGbWT9m6n1w9fy(jToYqDScjgiMgojm)nd63TtEiWFF2aVo7L6hgmIUej7nh01GE02lm(mpj58wu)dsb3hNwPPlxKBmfMefUaPQDSGbFmddqlGwaa04tw3bvSNGDStEKeOmMozL6L1ob5z(xldNqPJeOHOjssvp1ukzUvqfcwjO7ySrGMvVhmqAm9wConeZOMjm1FfILEEByxy13ZmmOORWx1SOWjYimIooYYA028kqp8Rg8G9lFrNSjxgi(VWHBlMKpLvp4taMEopQrNvwXnOVEZSzhTPBudoT00IQtNoMIxEzHM110Wx3T14hpB4hVx45YXoxyiVETfbzGkB9m9yBZ0MCb1wrC5EbmaFkYA3sWyT26vWjs((N8J4x5ioDS0gsLj2MS(wKgwtGngIFtUY(D2XvHQHTElVrPB7wrESEz7pzDDCnFRTEp2Y617XTEF0S9TCftm975CLTwIl4rqxNBf2BRGi3(BOAjUrTD6VMsPkAicGm1HaM28KgYXy4T8XYc25HlJsOpd7jULvMOHXymhtMxVbgPLuoWyU9E7e2OY)EifFCoXZyz8awCunB0W(yol2JfOPu7uokz1ZO6ZHDAom)4L0A5Fi)fyLGgNbt9RWkea8HnmfJVQ0KT5CyvIfLL8C(DcForEvwpCkLPEJZz7d(BoUtrmryBCk4jowAxCPPpvap9Z7JiTKPthnBsalUZXW4vdy)fIHbnyQ0dCYIjGs92HV9JgdxLSkZyA1r)ucTpjI8)kIvklIsWcN4CSee(exL44SbzkM4ht(3KkIWOXqz(1NkmZBdXiKJPndNzlJdqU3yyyrsqrzYatX9opkjjiAjAJ0lQL7Ud)vQYhWsDd(VKokG9ZpT7wikAp2OBtOXQb3UP0v(Mt6SMSL(M(h1zZdp(vyKX5I7aehCUT4gGsjz3Ej5KLboPOfxE(7rhmXavCxyr82VCypJLB7cR(E75q(StfsDAeZTg8MlXWVP)jD1JrPdSEtdTBDODSTcLbEGnhsMGsLGgGNMkKc)u(AAqvdtCTswKkNGekWn3s54AritR4TfOl(gaPwaMr4ueKzKIFXN6Tf2J8iJ0mXZ8CNubm(C2YPWgMubv0quIHiVS1aHkd)L)Uz2eK9V9XP2kC6QxplgSS6XHVYteHkAyp9eCqHI5Ikb3WFkrVrzlQk4HJmUP0HkH5WISbLQW()qJ73pZ71fwSv9D7WS(ioclObwk4TPy00hsjmMdCoiq7IKIOTpXFHk8cVLI39QB(v6wZWynyj86YA3yReF9ku3Qzs0bPTRTil8NsvAk9v)(uQY2ucYMVV))2htqffBT3F(HxoCLS2qjt5WcQbjML5)XpoHZQXFLQjc(SdawuUmkFv5nqeZgG1kHQGeMgk9zagBnUjdI7DWKzFWMMgnOsloEfeiB(p6Y6az5J9cRi2VN6vvZDyNoCaUdAuI2GnBqwl6WUPmpRyK1VWTpPoBtx6LoYq8qSOI(SGcpIHlRGTHe1ZHNvwAnIVgMRe07Hg2Ak4WmuWBa(XMIGc59h4slrxvnqwpkZvMy6Xt(B7ethNxe7DPRJfPMwQeLtTfSt3m7VUrULRyPeU2MXiLvn1B)JsJC3ogjn5SbE6l9fu(cr5CP0d8ekKIEHNWd4ecyotBCmJwvu0Uk1QEhvlfJe7P3vgijktJaYP5GvLw5rMIxXwsd5aVJQfHmEvDbozLMjCjMrjykHPus6HOqqNvnsIVw28bxeJbwlkodqhIq)aLgaklhc1Fk9ThZguLtCaFOYPY6E8YCADVpMf65Q62km7hRuZBfSCDW6LONz(FWsOGqZjSPf0uQ4OKX5aNnLPdBBtrUVB0(0nonCfP9Ym1BBuIWEs5BBN9SB6GQezknYOR25J00mt3Ex0DtwjUInvT2sCJ)nQujzdcyczfdkrISVQulVlmoOYrBUEeRECrmuZdhHyrzP6XBtXmxeZwD6heKPSvLpDmQsGjmFx8h1mmYFgTPsXqYBFXTwF4IAmGRT0HQVxgm5udpJtmehpOpSVxzFQ2t8ggWdBn)Lh1XsJ7U5ZpjuS9UV1zNMPasob68ZyeaBQCwEVrAwBWoFkm2vm3r7AktQnP6vxwHsgNto1sRETo0XvnEvM4AdVJ2hdDPYcLshIyZs(qzjRyYGu7G7uFGvjOqVWxsfbfMBj(QyYYCHU7b2QrgdgTb9nZ5nlqxgdD3wQiZCaVPc4CMpoKdYRz1RPotb1YmqqzVgbsWMRUqhMH8HJOkYHgIFMocRYQDHsjsrHHNwgGA1oynfZF8d7t2sklcVY(tB7PGguO0(soXjRU5k6iA0IPVZtwl5jARo3hELhgu8CrwCitwe2T5AS8ndoU5iN(Q1hZ5JThZ5t7SJZjL9dqfyjcrNoV4ejBIRrxfRhDAMUUVjXrALrbvFAzdWUcC8TG4460rxppl7H2cR2dDuVtlVCcA)9PhyVkMxKflGjNZETgShTrcLqGjibMHhqoyxOCHUSG1JKcz5AwcygqlqhHeCjubyCt(TzJ470J6OJkydRty5899Hsh(9bkpB32HY8xsja9W3IclqlJjPfKGEAVjlrCSgZISWEe4vreaHD5GlyBvTo3mkOcUO)Due3wFrn(MbkV4k(cIxhnjyu)(N0VhzmWZhtJv0WJr34)pb1y6m9Fex2)f595HCeuMxq7GOlfeCdM60IgiVxt2xj4aTGLL0sjJxA(nE55G)M51NdfU3Ruhlq(ahvky)KQE(AOevZU6cH(bjlPsGJDRwUckutNGHNVMQGHdp89QADMwK8rXL1SSgXFzrj5QJ1yFN5TSnkRpX5H00592WJ80B2cMGT8rdTEbaFmMWcflC1lVv97xJ6SW1qgQRoJb9TEdxiVyp62X2nMbFbPOFJIy9wM4SbvurP3(sJOKT9nOlr75mPaEhz7eV0vvn6gwK3WI1U4jR8LEFR4l7)hm(Y(o4lRFDk2ePYZYh73eFPxn(shx9ko5lTCnU8nIV0J1F8HPfrJbf5IIsPI3SqLI6sQISVdhcv5DscGL5ac7wXcz1n)sQkeJYt(Y6HghfVQWP17Bi55UVODSDP5uQP1Lq7UpcIGBrxTFX4zFXu7ktZgVTtCW2zXO43Voh(FU()7p]] )