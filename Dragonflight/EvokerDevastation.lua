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


spec:RegisterPack( "Devastation", 20231129, [[Hekili:S3t)ZTTnY(3sMov2QXw2IYonTVyptCStBY07Umr(6BE)ILPKGK5fksDKuXXDYO)2F7haKGGauuFy30z6m3hXIalwSyXUl2DXIB6EZ130FSFM4M)P3XE96217N60TxVx09hVPF2dZf30FU)Op5pf(hr(ZG)3lfF2pnZplioc)2dHX(JryKgVize897YYMN(ZhD00GS7wmSZO4zhLgmBri1Jrj(tYW)E0rddJhE04e)PXrtcdMEx2rIOPbrIJgf6NMoyw84fHI0J8NhI)3bIph)jrsNrZNFt)HlccZEx0ndTJ5NciZCXOB(NDp5fWS4UGXJfCJfPJUPp24d729qVF6NxE7)iikoz5TagT82fZrOL2z57x(EvJ6(cOr)7u)HHIL3gKjGM5dGBCPgD8pcn6d(zJUB5TDpUJNcufn64F8qVtGg96X)NfPzlVT)84GW0L3MLee9jb8dHXtdgP1(xCOhoYVn4llV9Q(WqhHiz00qXHz(jtfzLBRoSF7fhH9WpA8YBVma6uMyAszS5fhECpOhV5o)OPW863fjJ9JGUE1SHj(JGFzuC04aCbl9)z5TjI0S4e4xJIJo86EhNpelsb(cnWEAjAQKCU82jjXazRFotWBqMGYD7Lq3UkkDboksGpYhMYtcIcsbQAWeGwrZB4FdG0Fy8c4FMfV82XbakC7YB3hgG5HbtcGfN26aVlsC(O4ZbPaW37SZ2J73E4)ycIOWKnninten6HsyvxpOJVd4zfZerz(H0C4nQjgmIJtINdiZEPzdINlIejaeNNeeNeK9q7sG6yCc2FXqyJtuwacQreTpLXfgUW2daQ(t9dIk3zCcudMKIt(78ZYea30u4BaL6aK3bPMxKi8ZUd(ZRGphbigIhaHe(Lp8qc()9BbFM62BdH936O9jh27yAK)30WmwBL8nsshWT3Tupo(uTEuUdJcf(r0iTyoWT(VUQGybZ6L3omqNPOhtZGvoyLgeluq2TYoHCPiZccECEjzobaNHSitMiseihUIjAu8IOSu5Ueyvz0NG)iEcTNaAb8JxaIH0ripMrc3Nng)(LKOReAqEDuWS4uAI8bq8aHfa3XG58F0ggcrgmlM25M(HaRwkkWuG)V)ts(RicfWm(MlUPV)iwYQqUCnifxTG)E2847fjdYIVPF3B6pciBWYTp3HplgaSFZcqwHxDgSSS82NJZ1qyo3rbP0bPZ9J6ihRL3(1Vc08ftM0zC(mPdWGbCFiuaG05hpD5T)aG7ZfHHdUdihWuTvnD6CEOn7ITbczbaqTpScyG)amoL7ZZw5uOv1UJ4Wl4(VzD(LlVTnRQijyoVwuDRZcuwsIF0NwElSWd8t(ZbzpJy1e4oAMplTZnzG2PgUex)AQhTM6rK3TCL1RZMSWAHDOmBPhoz7TtMS9OjBVMozl4uMehbcJNmyMpQpTHueCa74Tb0eleYYKKEij5Kgss074jqhZUP)KH1jJyciHFWqsaFnci235UphSzTz6L99MDPEQT18ZIKHlsqjVdMGAqki6fW5jrmJ5Uwd9FABzHnRGMBG4KvA3QuRWr8mR(9ULi9LO1aPzSGW9GObyZqJNMPi5RMQ5yDP3kwx821Rl7mHe0ktJLt4MWU6jMfSZbN(5SwM2RH4J9FcwxFAervzbPwPuofYifrnwmXFrywUCkv)(VlGbuhIQDtQgSaW2plmBIl(I5X8)FPT4xkc9bTYW34ti1)A(OcpeVaO242FTdk0houXHS(6Whq7fdHtYI2eswYYgWV827VtG9JGW90NV8JhE(BV4WZ73)WZtIvN8TG10TPnpdLOehoo((OoP5gOpam3mHAfUQBJZSqg8W40ucAtWtipqF)zVtTTQfdhpgS1SGU9zFajHVI)RWfOIxfgvLJXG6(7YUcKV7qZOfie4ZBaujGChj(cADDsHHW4zZgce37Jt(ezfmt9Vd(0m)VaMSdwUpuKDVa7o9Z69E0yPb5a1hwkKmBPGW7GPWrkja(Ml)i8fWE(rigLMfmJoZonrhWEOarRbfWfjtNAHmbiutitL1sxS56qLXythnUdbRAXGxS5yG2oWsdFZg4F0XgQr(G8a(pgGNjHpzIeos)sKIa4LgaOepY7GDB3l2J2QfcO44hYx3OLl)YNdfpwFA2b4XFfJ(e6rL082pJoGgSPue2PantwevgltbCBugkSrBpyXq2PK8kTPeykf0RFARMmrvog9tWeY0mrT5KGwG6ESXKYTT1NdmTLgrNyL2O4htmsDDzgAD9nnJ1smprmkE2q)Q6jaOLIE2cv7cseGLU4O)qytXXAjMtYb3jRBhqP3aW6VbOGA5jd)Z9JbPDMfKKeNGZ5jjWCyrIymOuDwm8R3NQVJw2TbDjqLAtf5Aqm8QdX(Z5JBcXWRGy4qbyWe9TbkcshdQPsrT2AtH6XfjKQ(L3(9AQX1uAw0aqL9X88Q(299RAKyazEqMlfJcglqLUbOhMZ9zmAuZC)a0OLau0AHhPoaDTMycApdOJAwq0c0Qps1A3I)oxiVv2T0hIg5KLAGimf(3h350CESUU0ZkxnSbPQRR8OwZkNNJvoVNSvoRJu(kxTKhBgb0WDUKuJukSb4gLiriyuwYIuBcxgkcH9oW)tkjrnDreQSh5gQ22OhMTqaBpzJXjZtNhengrHY(atzQfPtxX6S8wcpzJ(ab8Z9znLKPDkYe7yv6NK97a0NSFoG8Jk2t2sWCIzEZzbgbzi7Cm2(0olV9x9zCadSbmRq7aNfpgD8pmb3F0Ie0tVOf(D7C6xAZBtMcAbPoDhyhn2UcppJFwduQzgmqxJOG1rj9U4fHiUluoYhTCnTuRlgHa0X9(PiPdpPXyH8pHH41OT0qp4E7Rpg0PsWdZ4RTL)(aSTXjQ)veEYhCpJsgGIMx2I4ID1Z8Jw4hAZUW1Gx0Rz8IERbVO3k4fTjROyUyAI6AmxOnbjlg(Wa4mnHZhKEhTCuDJci9fodnYEpawq9tIGnddcgjHEfcT4lJcxmwyZMZ1a78Aa25T2yNNo2vX6X1uMTIpxxQ9Zq5c1OY1TuDCMTkz(RuS)rLAa23bfFSnDOT9jXdCyskAAzdvYBPfeI3Z1M(pNxbRSQC)OsnOXyLPTKUXQUAyvzfrDZ5S8SAj)Q5i7254QE6UKcIpsUwTB(PFKTLpGemFcMvI9jP7a8ddOFhXjBM4NiCIvk4GrzlrmNGZa8Kk5oKQ)jo9NbjBL9Hbk(hDidGI3blzK2lLJhKnCXCqZg9b03dOFMED8vDOJG)wkwKZq1iOViW2CsQyegVpXmO)HbFsi1LLEVauRmpgv(ne9ksq2EO(trYdKjzKQHaCfofqPj(j0a8RkCIWKzuy4bHTruqUGrkoACkRHCOyk5yaCcnepSfRWde8YEYURTJnSUe4unh(1hG4JfbU)1moBADV8qL35d7TGdjeNmKo2ymDw7I5HRgGG00e185oNeedeCoqym1(fu7BFqWAi(pE9y)5vDeO0hWPCRg4N3iLtGPX30gWk9VW3YQwvYxS0NiizQbVK83vdSqkU)SBQ5dPJBFQjCtgUWegWhgfkgid1PHdmSzp9I5guvkjayWJ7vihPC9DOteX)7NcWdSeZMantGEcLsocvu7LgHbMggIM7HgJLiUhWGmKVdTgfwge4NwE7)Ao(BSnsiYJnFcTBcz5iEuFPjItdJhIPyHk1asYuD0ht(ab0QRS6ucfDsZ)BLNUqJhZdioFFZLk4gfJy(u)KXmQWYl8NiqRhZngEw8q2VFx(H(8(AU14UkgQ0MjDVMgHWfNl3hNGnkDeGUG(A0BSpG0lYn3mak738PXfsDcJbdCtWHifjLx2h9woioi4piU7FgOUrivMf0JWrAeU0T1kJvdPV3Zl95SjSIikEBc6FsIXqUaADMfX1740Y7pOeFIeeLfpyCGGDxEpVv7S8JRl2czbZzJtbttfMEb)FJXneAH8Ge0bVj3Htc0rwYPjXnlEaMEJBZI0Tv)cJdsBB(dP0C5n0kqfxyEiXNpDA(XosXZKC0Wq))G4cGn(j46t8ISuYteiZ2wZi8Y1JpqTyv1V1nWRP2ZaavmykexQ9XsK99T7GGIiTPzoMPfjQvFA05WNr03srBnV362fLp2fi4NJXKEkeMy1gzX8al2UicHYLZb8Qztg925EzXXoVx2GnEKXOv8zTlTWJfaLt59El8UxEbZyfPc5hYkssQPFrk2c3Pgdk0NegFpgLOuGft0XqdPJ9PQwdM5emcnScwB7zZ5novlArMpg7r2CieIJJfPr7LPJJxDXbS2akGzFoykTnK6lRROIegjEcNkijfm6atHnIIB5JZ8)YazdkZU7NmYpsmGgoDJumTSWYcXBvgwuOjfS3pITVd(eNoWPoSDX8a7Qgn)Her92vyYPtrY3ad5ea80RFUTtFVDd1jAX21cLwYdP(yqc6ZQrCdGZrzrIJlH9MobMNtNCTYMbCtWWy8FD1f0y(oySWSwe9gxaZEHJgYhrBnMh6)aT4Oj(hgrRUayxqJCkWY(etQWihl)98(HQA4gH7e6DTrdFZfpxVTSSabqJq9jiTbPadzNuYUtmfPm1grRnBE3R(5T(xhXzzkWuGjzQEd2u(kRuvDcwzMaDsg(vM7jbrcM(W0nK(LZm1X650F8PzpRbKT9TqzGzJ(gohKv7B04nzDpDz5Kd(cRNK26jQSj083ERcYHc)5Sf2yJrBEM8ZMRryIebQdoi)FPwBoOSNaobTBIOPhWRAPQZPwCeuvxlPeSKLfYXWsotQ(sDPSYjAT3YbGjcDHPiYzptPsn5UTY6l)rsfNsfnOxJmETRvFfu1kEyPefaGuJtVwkyqaQFv(v4t3Hoonu8f60aGclWOf6QP0mlhKPhMH9adK)mhjehzb2PfmrUrcBEVO0K8)lgDe4y55fhRD3pKxWK8KNhacSxkiICni2QKKfZZgG(8vErBqhookmyoUo1Q6eUvwaSR48Z8AT)Z2xZY2GOjls5v8wsRoJJhhUGwiB)1V64WlAFWiFBGE1A)e)GXdeFgztNb2mH(YPtq05EF9R0yChAhf2sa7bwVhgqZnZzJ2NW5u(eWWGVx5ToJxj(cOT0g38DcQgQzFR2IIv3bTbYsYLoWESiYF(ekLBMNepsEGoWUsCdW)zrWikGuaJjATU0ISuBEXscMQzxzH4aREHQQBZED0Oa6qG0nmHd11BdWGa1St1PmwLbJL8QuTLSClmKQy4hkTtKmnriy7GQnvNElGIdjJONyG8()XIe03OjbFs6jnvueRZDAJbM)zddIgdBBGnjZujaZuCtXasr6n9rg34jtgmD0ysBQYNSnORfeqmrX0pQkfx6QIhVSaQ5N6WIBUyuav06hsJkSXk7U0bZWGcy1RGMtcffOgyulUBXvoLMn)tkoIsvEPuqMvo7lPiBdxeX(yG9bg59Vp8UdiHNYZPv0FKA4r3SQCBbUAMiXhDC21j(O4d8cArrgWSVfoASJI4vtGolPDwzvJGhRbz0qXNLdDYH8qDNNN)36HfcdBK4lO0uGgppq5oGM4oJxLBzw9jHiOl(hl3mxzljMO)kB9C4fVt1IV3ZQBE4qhQNE(CNc2FmmoArkmqIKEDh4nF0MrbCy1A7vNJUioDCb3U7fDlUTt1jxHp3LKb3TVeJLLDvAuFBrxnV1scS7G0w41ilHdDLGPRgySzSzXkDRYRIojVvgtX)DbyxdC4aNDzDwElj55ICYVP0d0B)vpgglP6atrg(tiVHMlhBsrdWUIx)4B)xkPn0fBr2Jy(yV0pPi)15UTASY4TbspSbwkCbRY)OFjHsCBkWUh96)GUUUSApwRojkL9(7qnkH0eeOr7HXpzVL3(lwCOL(Xm(RhRyotL7eErxoPRwvwcKmdVl3vGOnBWOXd629KUDKzP8J7EbBE)Cnmp7Vxj)2zLSgdUTzrS7qm3mQ0FXw6)R(IQXbrC6MDjXbSAinmot)Vh1GWyUgwLYUc2PXyslXQnHVQlINTw9DSQvJPJTwbJAB9WXT9OuTef3gD2kpGGjLsBn1iY9FL74QqYlsx1ZOS4YAJYtCqfQyFhhNyMgysLuEdNtg2uz0Hcl0Z7eUT7fhRid5JTX9EIVOlhNVnQMO7QtsTXY3iILPpKVwlxNvEPHS)Hs)y08i1nxBSmdQpqfBCmRmyJajx)jDQdMM)4VzMO)uLp5AEGsLPUrHnNNu271gNy9GIJaNBp644fdX9ciLyPw2AZNjogldhvSsTF)JE7fs8KMK81cKn6fnunjhVlsFU6ImNCy9(wrAu3)SLgztF33QsJ6wN0ixkURFdMNJg1TjsJ8SlnQsAbVkPrwt04VbLg5rsJkPw3R2y82eBbQ1WQw7sB82z0W60mziT(DumHWexIeWHlS6hGU4YNqNfgXyv5KGe3jpZn2T8zol1JoVVku0RgAC48lbNAJsTn5K1sL3rMr)eSsLF5oQYjt3ywB(vVCA3CnOMzeVl934elLZ3AzQKwojSNYvNju7lkF8zpTbe0E0Mi64lAyCbn9rFb25c4VsRKHqOtrSQC5UEQfg05)HeMavgdWiM)UuQJb6XsqHUYWooJt)VibUSNs5ME29cFUgbWWpf0u)8ZoItZCQ3hem5m7O)R61kN1LXBjd85N1R1ZkpDQjVplsjjdMN5uIxnPifNWqPb8jVU)R)qfRsYJugpyU8KRZSc(JIq)VG0f9GtCvugEVa(iAQqcnTrw2r(rK)dHtMI7xOQyHpDNqVlatEy0n5iMVGJHteG7uTMlVA(b7CVqfqwkXt)aFvnENmSTh9701rantfJjcvSqMk8tAVdY3ZnpXFTAEJEOfyd7YBwDbHG1wV1PsSlhQwBQeFnMfX8L2alZH2CimwaAyR1PsqdtVkLVtxDXBpqQ05(G8Ct(Q(DAS5Y7RlxUMkEZQRPngEnX1YZkxyAvveAPfTt0T3DLq7vRcLAPtaQVK9upvQTdNJA4iD8uzdL1)cParyNhv6A8tGDc4b8Kxzk(YGMNl(JJPCVIJojg7lkF8PnVlM3XeivsyBeo5jTnYuD5h7Sd2j)iK527VkBfkz5RntoY)OXfwY0qeFvTA0Iv3QZsUbzPn1p9KDr7NRKAmAFZytAoQiH36MY21ax9Zw4ApKL8tf19o4o4ag)rC17IqTtHDzwJZvVfx1YMszvJTmBOuQqj9Bbkawv1N4mjVwrO54hWR19NAGGp0m4xQler8aAxfYheezMJJgN)(y88315b36t68RVlbtQ8(0fDIDedOZ4Y48KoFK)CLtzEnLd4lV93PKa3ypj7zLhPmn3blPPpmAe)yBBouQenPYTE5VLe)3sIFIK4UlLe6OMpvIx))1hdEpf2Dz10MVvW05fglt57IRRHFK0hg)cDNe5RvjC2NfHzmJe5NdMJeVRIQle4Ka5XMbSvJXgVl5JQ3Q9cwX7bu1A0KRWByXirPzT1z7yEm6EUZvWFqcHY2UxC(CNG)WvQc4SnzqT60NYKu7M((nfvTPeoxwXF(gt6CDdfQjzxKN4N4ZzjRDz5QE0MIufRnRnLZ)ZuExL4lbzkDPE4XZsBWbXQJ2AxTRMM1dRtVCB9AsyXyzK0UMEe5Bfe2DOSRKE)nFvnp)OLEXj)A2jTeIVigG8o1vwB0Qsmj6Nx3lXGUjZ277wyTfRQP6DxeJiG1loGI8XxBhBKT50fHb1uaR4sX8tG9QXkhBYXcKdo0Y8c3PYgj0fWLV7m8MhVR1jWRUK6Yd(a5yxvWv57eKKCCgp(TSh7kpRzEFjAWL4utAH4v4fhGEzaqDHSt9fuTRI0WwCzhrN2eb7oiVucDie9mJ80g53vv(pLoSdVecl1RThbZMhNKr1D2HlYiF2bwU7NnBP8wNhK(ZLUJ)5m3TWiX2r7h8vx8uArHdWXicLYlTuCehyRyBXM1QDBV(7RiYo(kIuJJ(90mKSb3Aexhe2LhT)vQ2sWwWjd1L(Hr6N)EX8ru8y0yQUlUBcXH1lwr(eZ519Mp3o85Ishll9qlTf8hpovDEiUG3OY1(GS9ujtH0IxzLdrX5ZcxW9WV7YgEXWTkjr78kARUiIXRSy(HiLevCWN4Oh(YGqXu)rLp6J0bNUa0lowxUOlGqNeUR5rHBYeuc4GzZcIWdzdRhzjlOvkZRBt9l7LyD1wHXavv75w(g66c5CQPtQCxQFkbRsKA7jAPNRG82O7bMHNfoGVlkS5QfotGTr9Df3q2MW4l5jzT0gxUwDB1fFrmArMW8qXwVb8TTUF6m5f50Z0(Dx3clwRjlh1PHJzkI8QIySm327J52EQkfNOQXtsaxAukZywmIQmpAiwtEINLhpw13RuzPkqbz1rgAbQru9qMbMMaNGJcjrQmzYy7cKt69eP7Hc2Oydowfqv)fzXYukt(4s1z57)n6PtQl(yFfhbdd959u(sltV2dOExSS(rfFn0O97(L2)LgYEpAqU3tnKlfxkdaBnMvfWD57TWyLMTEmwNUZrRAHBLy1zslDflVVrG)wtxEHD4wiZ2aOv9FBdHyUNImayfpi1q4vYT9vPQvDPVjC)rhWTCmvmHS9iUyc7x6GgOfZctYGLWz0qOU1uIFANZd4aIBmpq3J31a0HYGnhGo2Gw2zdgq1UNiQaAhR7A2RBaxlwY)0auhR72oaGb0R7mcMdJNtUbnZVRSaAX49Mc4QwLBaD3MTVx9QhZFfl2BT0swXGdzgyY5kT0byYchEoQwoHQR0O6TOz9havbgEdanFP9FOomVOj7wGVfyn8Tuz1gQomVCZ29dYwmdO8ZRoCx1GDjG3c8fpRzDOR877qWU(i7QEnsSmqnOl1BkVeuEnzZQJgTRhaxeUgaAxByT2KDlW3cSUUnQoB2UFq2IzG9nTwAWUeWBb(ADBB1VVdb76JSnyRT5a1GUuAWpXPOOk33ilYES1MhvW)Ob4)KW745cUfYuMApx38Lw7xh8)(VV4NkoUL6RNDSwWRS89V)7Rd2NDCB1uCdrUTc3wfQLtzRCKQ8TrREjZEBkXrSRb)JgG)tcVxnNSxfMflWFNXjBb21Xj3mKBRWTvHA5u2k(Wkx4J939ilsGC2Ws8g1oqUQbf2hTAADZhsN3hz7JzDnV0GwX5D57bAibTMg28bQXe0v16MpKnNGUYMxAqR4oi9vrZ3lk7lEwAvZhcNp3u2hR6AEPbTIhP0jMRCE5QvnFiA(8ALnV0Gw1JOBPwGhB43eiJPtxh)OhgmEEADq3v7A6mOPJdQazWga)gFQ46p29UyeCDefNWEtTh(Xg(nbYnBD1D7A6mOPJZMX)Sg(yDd5FwJrOP8pvmw8zopAHll1(6xDBdx9gX5AlB7Fy)UDo95o2saF1YaIV4DTBF((1FaixlYMJy3voIDLJOI()es3o6jNUD0JaDRGL0ri42jrVroeocgDEwsAa5kpwAvaOJOqVbaKIU0K4WW4757GdqAXKzuuucNYV5nCIeXVqAuEbRAhD3XNWx5SIwpEm24X(z(d9tf)8Y3Zx4IKGmhH1YpgnWCncO1JxEUuXVpBDWTDaXI3Acdiw9rOWeIUszITlDbCem2Dan1v443csGRaY)iaYs53VbuT(EGubWoY3RTbxDaYThxDSZsMu)gG04j7OPI)ufSet5Qgv8)Mk8BlIJVvPrsvgRzko6YHXvlhv7vZ5FkAs9Yq2kGVsWwTWmvbSwBsJW5nd4ReSURPPUgU8FFLLd11YxTRXcHbfB3c8vc2nBHOH48Mb8vcwN1f3vUiVQkQ7Qh7NgomN5d5glKZbC3kMRhvGVsWUzmxneN3mGVsW(uW56ASFA4CD7i6vsqxnh2Uf4ReSBgtqdX5nd4ReSpfCyUg7NgomxHeyZycmwT2TaVbGfDzHQFwaPXNFeX1hvGVsW2C)J2i)WU9dtTUH1n4ZN5RLFQFKbVBaV1(1WvCS2mPBpQaVbGT2nJv(8JiU(Oc8vc2MhSRgTzC7hMA3m6g8RE3sdcQ5Ug8Ub8wVzSjXFDneA)4c9AG72tiQ4fVTAdZJl0RbUBbHWQtTMmCV1YDwUU9RFEhDbfDDhy)Rc8DfbIhz4V1xGZhp8E57FhXXHG9LLJzeYwDtFGB7U4KB63py2BUPpOaysqy(TypTt(DB65ND0qS(AGJL8DfDysC0Fiw(EBTvfQVdWkAWzYTBQOGEa94MCwz98LJK9x)QLVkZZFRF7ZfzrV1Vt5RU1VGHat)dRkxTxNjSN1jSTu)OadQEXgS(nRtyZe036xkpHxDYPV89Fhw0vgr1sI7VlGkT4CVz(r8DOP6RqZbyP1smrW1lTzbrlOYSkgvYUf)TeqRfvLdB8bXZplvKfmrsD7Y))deHPIZoUZPhKxGZpB1ziTfZ03v58QfqF2XTxN5R3wpFRKhTwSeAxnFTaAA(cmrxjFFJsPxCH8LE(XoA5TdFGQypZbShd(nxFjLWIRIjzApHshGpM54BMXyUN03uJOwZXz(s6LYu9gB0z5T)QpJd57)WIgY4Gjbi76(YIRkwKu6250V0MzZNYv0m571uccp1tSc(znqPMzWaXA9TnkP3XLutSCeXk6hZL1gTwxmcbrJse(PiPdnDySq(NWq8AkdbWkBKCsvmg510l)L6V8uyBJtu)lkFbqom1Eyfnh1q0CUu17OsfP72tsxdrUU82LrZC)2iTgyQNDm1v6eBiRC1yA9zT76GP5pMr2iQM50QbPYzAOUoiGNdeWAs1Aqb2jiGAhGP0ppDPFD1K99iL7v2eyw8nRhC2iFOSP1VHPHLnTtfFRjdUnBSQlJSiX1F0p6tKYAzLfu(g)QQCuurDQblL61PvLURoh)deSgqMPqJ2Vl7KuQ190JlhkyfR0wWWDhqbi9cQ6COSHlMdJl9bTxsUou2n92K4zG4quan(06HT5KuXiSWQlMHLYr6nkM0sKEVaeyppoR8Ba0NPx(ea8Kq3autskGstWsOoma)QcN0kwJCL1(fQ30Juw3ZqX0GizXHDOGRlD(yXKmTzszlv1S9JfhmwmXFry2zNG7mseWEJDmvS)1RpILMLJxD7PHy2adMyG4ZIkdM078b(BWSZ4KH0bmItOxqiCorfaU(Cc(bRU5z4Nd0RCH1cFVGu5YsLCe0oeYtqpT(w8S)yTl6fKnSxpRA3Y7i08)7cCFK2pivtin1MQA8Zr1Y8cXYIkop9yo6pKQLN4YkwKgpez9sZ4x(NqXNPcfkTQQEjda2aSFeeUN(8LF8WZF7fhEE)(hEEsSb1aqiy0H)foviHgLRHN7)SC5rvF8a)6xlxd3o)mV2F9Ry1mVvPkz(R6DQbhlxltfOic2irM7LF5ilWGLufMfn57(4e(XIIjh4(4z(Fjy2Iz4MSS7PA3gBxOwVhnEzEDPnPuztnykSpNa4BWDbIjtiRWuplNA7uRSnWOK3lLZzZIz50V5Gc2gbZktiAVczFO3pOQYZBj8Tu6Ypmh0F339Dy1eeRrQGv9Fbrf8jLY4DJkvwvnVt8WEeB7N9dc5LAqnfrN1wxEpcZcCoGG(aHe4KUlg)lxWyDXIYfx2AF)pX3fmBpXLa7QghE5coBR6y9B9mRGRT(AHzrQSK5o8zTXNEW7fmjluwPsLCPerZhl9L4xv1avu9k(qGDNalbIb4rQKTNFf2azcIWsmVjlIQIetgEawHehbcVrQAXqQtdAggc77Q80ASJWsrQlSS8wIvciulQoKmeB5TsaKsPonqoE9)6QY(w7)bp4hkLc)Vad3y(8OYNzWLQ6oljfsDoqWmUqueoxEAVhm6ndfFHhiguAjWpT82)1C834JPLspKlQIBlkWI0Z7lpL60W4H4MsEqyT)ChHpojrG7CVOqBgqnG5Pbp9bJEyuOya)svKYKjBY0wmNOd9fQYfm)8YOgqS6GNiMsLByehzlU8NiqUJ8dQplEykPm7Yp0NTmIBnAYcdvsNMU86iQs(gsAcWgH1uuqwxmQh4HHknEmakRcDACHDBQxUIl)y6o41xz9Er7mxa0KltgFy(eHaYS8SRn9yAj4FN)4VrUSGCrhPwLmWf58MMeBoOLFZeCjrT8(JxDwVN37huEIUukN)1V6s6jFUcUe1wwe2HepkxsvPff61D5Okpzo5f1wKFyRxRwRxkNLV)5LjB2fLdsrDk8evSujyrAN)0q1855FW08FGeNNNHYQAxBLoplVooVkhq6hgtdBkYU9wLxMpRx72QcYUThbhxqUkdeGF2yNFPdUzDwLkQs(lb3styw4DBo1HzJowS0RZcTFnMA6MnQ13mCmBb3XL6VzM5VOcOMi6xKs6rXHyj0Fsi(iOPQD)ve)wuyYPJXzroOrz))8EAQ(WtJXhAbpZ)4yrA(JRgpUxDXbAp1i0v)bDuazGaRYCfkKvYMT8GG8klFi)XartGH21oYqCS8DTvzsrXBbL2RzHb(PDaxauFGEDqo96NB2m8zdXMXeMhv8unWCY1k7hkEvkalwWQeowUYbDhuudYFBk49MLF5u1KCakM2uS6e4eVwiUOb)Sl1QwpZlO3L1n2wFckL5KJT)E(Ek6fOJAeYw07AJg(MlEUEBzMD1BkosJqkXqoOkluVjlOrAB68VYMETPHogwM6RJJ4x5LnkxhKieHOicx8cJSPizVQiP6xkDlRATUlLAtvMDS7PvEeB2H48ZSI07xb7WATpXNzD6OlGeFmaymx(cdbA3ONyiCv5Nnx0K3Fm9xrgEX6GYE48eu5hnpoGxgtvEOtZ)AYUwzr10Fz5QvKJPuXxXJSuvVkDISnwU5VOXg03Q8Ik5AXx(dVsjChKBEy3cdQHvBCxeoHo9A5Ulbkq3yAv2NMoFC2DPAz1VBkTmncNfy()fJUpySYzxLEytLVxrtiFH3)6kA80A8b0JCdWQw(1W5Sh3hdNd0FhHo7VYpJq06k0caNn(K1DJLFuMu30s(fjtAxlyOaY)9FwemIccmWpSS4jOVI2yZTvkhFlbDlJnvfEx39ZRsZSJLEnn0gXs3(j5MoZxwLww2cqyK2R5Hvuq)X8q6bgJtiCaDB5XhnhmcwOZXHP085HbJKEAgDcblywt0Ka90t51)dKMMdgKAtc(RoR7ZDCeyZ5MY21UD(Xt1J9vfMBLr7N1vVz2ojG5rYp7uxwD0Yu45l(6xBwdFz7gtF8SrF8EUNlNe4Ic51PPeidszJX0E2W06CNHTK5Z9e4SED8A4uWyU24zWjs(EDNOuMPhy3tINdN0kRe)o6qr4ORhXZiDU)jdLMZRo)JjR)(w4aRSCJ(o3GRSBUjnvsyrS174nkTB2mYJT6W(lnylx4BL5BplZxVnB(UXS9nCgtm977CMTYfx4WzTDUvy)DcHC3VHQH0g12P195EQa6KcqClB5N9PQnWi80YbgJX7RhXMm)BbuCs4eqqgYGYzLaSpMZMHHc0qXNvmkPvJS(JHvOomi6f0C5Fi)fyMGMEcO(10Z)v68Ge0x9sdsNXoydF1mvP(E29cFoGULMpCQfq9gXz7d(R61k3go2QRCEIEslnkmgRe4PF(aKOfpzYGPJgZI7CmmEva23rmmOjCfodr9QY(6(V(dgdxPSlGP0QASHeAFue6)fKQuKmTGforzyQO8r(2cGydYumYpIo9wIie9PgLba(uc6YpLOy4trmBr0yb5CKKz(07IOmDPauC)luMitpCZgXW9OFNYagmLhX3WvuhfW(5N0Eh4p1nnsjezSCGsQlS1V6KwRiQ5VQ7XTw)qTCngLfojFWxuDBoabLsY(iGKtUm)LMSWbvx8w84ZONBUpip2nx1VJX0TzHOz)9DiF2PcPw1s5wbDZLy4x19K26UK2bvVUH2To0w2MHYmwJnhsgOALGgGNMsOg)eUMyPYLnoNzZdl44yYdu87um(O3sHgK2wGoWWaivc1achJxCXo7G9iBymhiEM6Ip1UiouPz7OWqv5K6YFQYz6Dexjz)BE0gScN2651uf3aOD0k93JlL)32(qDXVTTLCDJ8zHgLTOYKlo(gMshk5ehlYguQc7(t1UF)CVxMBXw5hjnZ8K5ymXwyPG3LGb2OpLmcCmmabAxgNh4Jr(Zvo841uOhwE7VtL8mJ5GLiDiZHNDsOokT6A69hRlTTT5zH)wQsDbY8VMsv2Lsqw)99)V(yScjV992lo6Q(lL5iC(JunUyweko)Oyomp)cLFnCUdbwuUimBzr5EKzdW8UrLCltcKNzagBnUjJf37bK5aWMMAnOQKF(Klq2o)OlRdKPr4ZTsy)bQxLn3Hp0HdWDyTs0oB9gKvsoSBkZJkfz1tC7i15R7uV4GmepelQOllOWJy4sZzBir9S7zLPPL4lbzkb9EOHTMcomDo9AqFSPiixE)HU0s0wLlSv97Djet3FYpTiMonppAaYJoMNLasLOCG7GD6MbI3nXTyglLW104HPSQPA73inYTRK0eN5Pp1NtbxfLZLqVMMOqk650u9MYZXrK9zurYBRuRIpL(gXJLyp9U2GirHLfio17SQKsVON8mUCD6KgSZ8oUIhY4z1LiYknt4kmEzakHbmtEcrHGUZIKeFTeRaoIyeWAr(za6qiEoqPbG5j1c)NYZ2JHaR0npHlUau69pCrgnVbtX8ZMPYbWG0FUu(tMZY1ctDLoMrKcZMfImlFV4juk)kfYjKbBktl22gBbXVQ9P)Dqg36Gm2W2sCJ)kL2TSbb8czjdkXfzFvA7EFq04sxX9QESAZ8yO2jCeI5fP9jVnfJCreB1P)4XPkBv5BjLkBKcY2d)rndJKzrTIHK3(IBTE3LvyaxDEDvzVmyYPgDgrmKgFwxyFVY(uT3tx0Hh2A(loULLg3E9XpjuS9i726z1VcSUr6Tg783Ia96e5utTQzYHZqexekDJthDa66sLfkfhiInl5DfPpJjdsLlWv1bwfGcZKWrzUL4lIrlYe6hpWs2e12mDj7AgZBwGU0h6UTurg5aEtfW5mBya7KxZejuD3sQezGXf9AaibBMQWEmf5dhqPVuv3IJwUOMXh350gmmirWpKGmiyp7U0bCDTOscsT6XcMV)t6EvltSik(m53aIKcVLReNOzLWhE3bKHTYKZSO)KmiYdg5wqCfhfNL3EnDVH6WmvVo(kZ(wC7l60akHZ7eoD25gDJLaPs5M1JxP387h18G2TRpnGF1z9Q3BV)4Q9tEp7(j)uqw5ZCHxwdsSJBk1QNbMIP712(TlempJ4xUi)66BUMJNFUQl7z(RdmxOLMELZ9nPObyxbXaOhyK8iuy4L9qEAD6Nu3g7gWQ4QkduDtY(g7sSFP1Lnai8UUS7TTwnuQPFY7vFBZuZdxGlGvZlcPWyGb3A(CGy6SxRy1(TbsVG4dR8SXShjdQlfv4JEnkbfpUajcL0(rYiy1ed1ywK5FLaRtxae2J94ITvUvE2RVfwqYjTU4SAPgSgxYAF1zQZxN)fKbEWOXd629KUDiZ0E84eSUwSjwT83RppDRpM(Az1t7VjwD(RhT)7K1Ei5iOmbMeOrfWiuEN6MTpwwdMoqD0l8uwSIpkHrKhrel0x4VzwQVOqsCTCrwEbll0ZEszVZyyBL2z)Y1bpoEbLMM4cYsT69eB9wmgcPkAM73)imoz(5UVKlBaSIEu5CsoExuMqQxrCAyCM6Mz31zi3BIvBN48EM7I9T1gEb0xnVrl3BN21x89QjTFpmmCfiGEf8vV6bvLPVcDsvyGoRR163JSSf1ULTn6C5FsVEjzTg6C(zLmYqV9fgPkB7RWd6VVZqD5DSTRTxB19kY4CM1mzTlv1klR3tflB3Nmw2QsYFIzz76GL1Mkg3RIEw(y36yz9QWY6OMt5KL1s9RYjl7))OUjzncsLrEMg8HFeu53Gkxg5(eH405dCB3bzfWwpZGlnhA3OaPn4EeifQdzm1HU33iSPbzyRr1Ci6SuGRfa3NWyKDlvi5ibCxQgX7zmc7EgmoRijTMprv8mWsVhxjaHXb4d]] )