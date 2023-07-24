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


spec:RegisterPack( "Devastation", 20230724, [[Hekili:T3ZFZTTnY(zjZnv2kXw2I2onTpl)MKyNRPtFx7eLRDE)JLPeHK5fksDKu2XD8Op7VDxaqcacqs9d7R376mV31yrGflwSy3f7UyX19V(ZxpmWpND9FZ7yVto(B9oTxFVtp7SV76H5pSGD9Wf(t(I)m4Fe7ph(FVKDNFwUFEysm(ThIs8dqyKLSmDc89BZZxK99hD0SW8BxoU3KK5hLfoFze1JjP(tZX)EYrJJsgFuqQ)SK4PrHZUn)iw8SWy2rtI8ZYgnpjyzel7i)fr4))i2DjFHL2BYIfxpC8YWO8pgF9y7y(BaKzbBY1)T(N(6VfqOWGagVXSSjxpeB8Hh)Th6D63V6M3g8pwMLV6MHlscJYwDtEAy8xyWpeLmlCsVv)4QFK3(xFO3RH2)HWVU6MRgU6MW4v3KfgplIDyUF6mwUEBvH9hE3ryp8JdwDZLHqNYzZsb8wRhhFc0J3FRF8m2QB(vwAGFm01RMpo1Fc8ltsIdcrky2)1QBszz5jPWVgNeF4Np54IHyzgSqPa2Zo077aW()egNKcFDbsTGj500K5WuUyv594QIE3Ed0TRIZwIJIa4t8HP80W4WSBHP)uGwrZB4FdG0FCYs4FMNS6MGqafUz1n7ddWIOWPHSGEDvbEFK48j2DHzaW3BWG949Bp8FmfruyYMfMLZIN8Ggw13d64hbMi2CwCUFenhEVCIbJyqAYcaz2llFuYcwmlfG4I0WK0W8h6QbQJXj4WLJbo548qeutiAFghx4Wf4xbO6pZpmwVZ4eOgmjdN836NNZaUPzW3ak1biVdsnFxkZp)w4pVc(CmGyiEaes4x(LhsX)ZpfEh1TpebB4ur7tp8KJPr(VtdtGYk57fKU(h3RVwpo(mLEO3Hjrm)yAKwUa4w)5RkjwWSE1nJdvzkoHtZGvoyLg2Nws2TYoHCPiZccECEjyobaNJSitNYszihUKjAsYY48mXUeyvzYxG)izkTNaAb8JVdKlOIqECgjCFwa(9ljzjP0G824W5jz0e5x8dciSa4ogTG)hDHHGLdZIz9UEyeWQLHsWy4)7FJeiYI9hhXcU(Dxp0FcxuhtSCnkdxTG)E(IK7zPJYtUEy)RhobiBWYTpVd3XgbSFZdrwHZhallRU5v4CncMZ9KqkBu2c)4EIXA1np(iqZxoDAVGIzspGbd4(qOaaP33E2QBEjG7lyrrJUfihWuTtnD6c(qB2fBdeYcaGAFyfWa)byCgVpVOXPqNQDhXHxZ7)M153S6MUCz3PHl4Rfv36SeLLK6h)Lv3al8a)K)cq2ZeeY8D0C(SSExNdQlA5sC9RPE0AQhrE3YvwVEBYcRf2bD2spCYEYozYEcnzpPTt2soLPjXGW4PJM7J6tBjfbhWEEBanXcHuNKCcssoTLKe1oEk0X8RholLb2syrmHg)5FfBfAubGfzeZzGGlmnC2mwkkGAsij)JeYRGcZzP(rbJaRJYYsMxWTk)(DCldgX4ggOIce(fWM6VmkVadL97FUeqf9wRd4La18oMztCX8SiH)F1M1xYI8HTKW34Mhn8ZC7eEizjSFevbOyLWqWIId5BwJEavweb2vIeesngx79QBU)wg2pcc3tF(YpD4fF4DhEXWHhErAI0o0sMx3Y1EbQKjjki5(4EzfANhb6AsPwHSK2K)a7W7kyyH1ecAtr7vhPUd(KZSXyLagRckAuw(8bKe(k(VIwI76KyuvoAdQ7Vk6kq(Uf1HYqiWn2aOsa5oM9vu1QIwq0WSXaX9(K0VqQa5u)BHpn3)RG(AqT9yw(9eZk9ZQ9EsGqBmq9HLcXMHmqyB4mWEscGV)YpbFbuMpbXOS8W5ig1JMOJ4NxarRrLWfjtNzHmbiuBit6Brl38FOus8Sjb9iyvlg86nhdMcwXnAmzeN2W3Ub(BDSHAIpiVI)hJqds4MLiGJ4qjziaEtDYD(iSB7E2E0wTiafdEOyDJwU81ncfTPpl)a02x2eqZziAaMO9ZjPtWMswuVs0mDzSowMb42KCuyJYEWYHuLAPnLMogNmF3wnzIRyd9ZWeYuhHYCIrlq9p2ys5wX6fatR2i6eRugf)eIrQVl7uRRVz5CTelszW5Yh7xvpbaTm8yTOkBqIaS0Le)7mBkowlXCco4E597bkLhbkehHcQfMf(S(r1nOIMmQp9LmBA8wJ5MxDiXZYhTn38kNBoupfovLjvo)6zqCKQrviRLkVwMskIxDZ3OOKvrLwzdafQhZNd13UVPPrIdiZtgCjBsyadvjgo5wf35GMCSWpenPief8vEyXdWt9YMIwBaAqMhgVen0Ku81V8VlebBL7j7H4jo5qgXIYG)9X9oRGLPVlTGIvdBqQ66kFuRzLZZXkN3Z2kN1rQyLRwYJnv0TCJy)EHz9Yip6HYXIzrGjtPlnTO6kP9kKIr5k8QBiWXTCcKsUWNRUHSpsoB4UMG(jr)oa9QXDHKNiWEYnNQyox0C(E4WCKRlbBFwVv38d(CCaDnyuezm18Ka01zax5(twMI(kbntUFVZ(Axo38mqvc1PBbJrX2v67g8ZkGsoZGb6ZikyDuYUnzzeI7mPRWqZ)Y0AD5ieIU(YpdjDO56bmXFcdXBrdsHEW7TV6yqM2JNiWxzN59HyBtsL)Ry84diRTCRQKMRBwz5MV5(Xl9JSzC1AWY45KLX2oVYH00CS1yijU00LJFyey)E0Irz3sundvxqBazzW5zrUWraD3png4zhfora9k0d2xNeTmGzZ(Q1a78Ab25T2yNNk2vXsP1ucOKDuvg4lWTV1OaZTmsCM1Ke0gfIEKwdW(oQ8JDPdOSpTlM7pWuRAXvAPfeIV1Ol9)DrfSYQQYJ0AqRXktJQCJv9vWkDX69l4S8SA1AZCK97DCvx6Ojh)tKB)6xyPVOT8ddaZNW5ASpP9hHFye97iozZC2uMtSsch0DYPSfeCgHwLx48LHN68S7Kiq(51rP0OZhau8wyjJuYipKTOHlxakGOpGNZg9PYBtUQhDCZpqoDFokThp3n2MtZytqhBZMd9pk8lmHkNm4a(5GSnuh1y0daH57HQ5yPpqg4qsWdXv4maLM6NsdWpiXjctMtXBcKjgtEZfgPK4GmUISXSz0HGXj0y8GfC9sOhSi3T23Mn1RlbotX5wdbi(urGh(zooBARCPigHJnZazDraVVFG)cUBO08KT09NH8G1nx(r3UYdhvtBcfhB7wFyhnlyus6y6Gzj0PzlbLRgGG00oQktKAqXIprqYu9QMu3MbwefwRrtjhEshdf30yXvQnltWC)ff7kERroFYfaVDsoOJgnA6lHXb(IWDH2xCpg0OFEbYIWTWazsqw3PetoYjqSo(cdSMfLmgdXNm0uP5Yo6Jb)IbT6Q3vRKblNzwzPt1tKgtSDpwwUOzZk(LlQZRVkUYshnHghWrjCb49xkh54e0ZUZ8tLU)Meh5pLH2qwys88KXCxOD5VmKl2G3ACtlhQ0EvvhqgJWfNT3NKInkBcGUG5aOJnFanHL8ymha6UGEwsPqTOKyYz8x(PmKL4YHOJNHfTWFN2p)9axsmYaX1JGWrykUWdWstwJOVFIx2R4gYYIPOzYO)jjLezlz08IKGEYXz6BePeiGyxYtgfeY4EE(eVM978X2oyVCblpCb5fhqwfm8glA)DmKzqlehNGoLm5zzsFbqUMnlnPDUw30XwBweJS6IvCq6A74YAZL3tRa6(28qABapCl0YDgESKJgh5)7elaSZlfxCswMNr(ma502AUG3SEmbYvQQ()TKUVVA80uO)A0VcBYmC6mzKyXhnLmzgToFzCZlbEx5ImT8Zdigrj1IGzXiOADvz86ee9rCAEB6PRyuxGoU208MwSNHmtTI3On1uAHdRI)M))nmz2O168gU4823UdHkJlBT8FDEUzSEsyG4U(3vWDcyWuwgeelCvx(o(sESmYPitcPhN(L0LX88OjCoyRkXtaajpDjbE(Xb(4EZrhUKTCUWzvOGCCwZnUfhGyodiQ2fHpxdDjiLgwqQkf2paNJkoqWhx6EiKVs6ai5rkMZzsXpdQKrixACcEgbEuDLBcK4GYrlil7(VnmQSktPnFU0otP42OGHDMF6aeRcsyzX7b)JeWy8PrOLHx9Ud40gkwP3foJ2ut9LBBtLnnWUnyBiEi50m4ybyQlrCjw(4C)Vos0ad5UPt8JzJOHRWY5McqwPspYI7YLWYLn4t88YmZLr9M(Gr2QfpKAALhpnUOeJuY(CxcMYxrOcduSgVfN(5xv(hir7erIaSiY)bEyJFNK)MbGbLED174c0gZD9k3jPz8mtZgOOng6WldnNJ71XXjiYDLCu0bkTGJW1pVWI05mUFcuMf8jy)ZwPNnAVZSfaJjHdbm(aWTfYY5SuOvQhu0I5tOuOtleUk6(eEEWnAmLgCQq4fw51ewNj)yyk6R5j8ga0dPYuXG8Iwmo7x3qj4NRDSkhoQz6JKyFbLztNP2wbEXPZJcJNcQGt0qmoPVxy8OYJFkhYAJvAByY5Yb05Z)n5V)RWVls(SfuhrEttock)yPL4d4m5yJKmZUyZuAkSFYWCWTIKiiRMmDCt27SgRnwzBT6rnRUaWMWSF6dskcCy9f8tQHngTSz63BUTh4(IHLHdk(xszghO7WQtrRJiKuqvf(UbMcfoVr21EoT8wmgwYHn5xQllIovP9wCDuPPTuleZEoLkZCVS1n6IFKu9i(3O(gY6G(wDdx1tdcRZtf8MN9zHazgOwu6iQVCl6F)i2xPtvcCwGbquU73OEBvMsd90Je)mpUAwscu80KNvYe5gjS53oTj5)Bc6V6aHy)aLCXVylVizMbGaBbcJjpyJTknD5I8ryOje3eb0V4tIcxGRtDQoH7Khc7MVyGxN9t9ddgXUd5HMdgAGEMd2yEH3JpsD7w04dOhGfLmGV4Hr0aBoukFchW9RoIp(OCzpGnnCsy(5d63DJqdT1sOT0MTcUxzdvSVvHqA1nMBW()ID0C)zf7VafKT)xyF536sXoDIW8rqsmY6(pwgoHcmjWsH2Sle6LzZZTcGPjW0yJSvxNQHWFaom1ysS4u4KzS0YzP)VVmfDyDA4xeo6ugbwBE70YUqXDrXNBqJAclS6MprNPNBcl3mNp8oAcGw2IIWKEGd)VNpWtSngSZNfecRp4HmXpDXGt(CH)LTf3Z243N6CAtNnpJlpP5mUeZlZJvm93YmOgNUkwpGT2GrJ5Q)DBM1B)eVgfONOBJKTdu)ksBYlL4sJ5gjsSezNi1nEcT(k9oBnTgT3ZUI70WBK)vbZGranlZwcJWgxmQfJK1OVwMVb87XGJq0kcPSevShcyEi7n4QChvuCPWGNZiW8wIZksvE9Xs6rTEKZ7424ELUM2DBXbnns1mtrQpRK1ksPlK(qkrsqPWYe5nqCS8dKEFcpEppz2j1UcHZyEvH)MzMv1RUyjiqaV)Cl3oAlx)62Y1FJ2Y55Or9BZwoVg2Yvj9iAAlN1eU4pGB58OTCAkw8QninTqzutP1Y(Tq8Q9fjbm6UZjH1jg2sMENeZTmr4Nh6i1fcPKPkhflteJL34lsUvc3fsy3kM5RU5NfNEUWftndnU9uAWXwKNQtewTezJfkxBkRDX(5zHQif3QYhNtHlPMlkPwk)78wsArARqsUTJ)51GNl6lNjYinchrbnMV40gAt6MK2VlVRLMAFnUeWk3Br)faJjijHonA5vwCf)QXEeFMv)fyuJ0B6gdxUeQtBOAowxoPH1fVD96Yo7MssRmT(Ys6MW28eZc25GthX1s3Rvs1Q5ouU)ZW6Q71Jb7W7PzLfKAVQMofYiUNMz5nEwB86j(2jCZi(jEodXtmomNLzzz6zl3m(9fhTbgTT8fpVUeZUVBir9VULEgZuMrj25c4NRS)1WZpOhPsaR3alv1U4sulmOZ)pcycuz0fBaz9ZuGyZweMIMhkC8MicIXmKTmJsIW87z(8lUih(z9YYF1GJ45di17dcNoWo6F(jDk0UYXBbd4fdoPZl0NonSXNhSmdMNfuibNwg8n0LuaFYBh(2FPYzAk84eFWCXuxYEymAFIf5)vKUOwJdUkohtGZpX(NlbqJtBKLDIFmpOXSiuLoD1A9PRcZTHyAybglqy(Y4a0OOya3PQFrr9fb2Y)UOKKGiQ2Lahz5x45u7hJNUmdAWr)kL3O4HfH)x(o3zm)0U7G8AyZtHQgoufD8ToT5GByj0qi7CltklNMnwxsz9zmFS4zxl3ZEvd2jQnGhLisFqzCIkAXvV7dhiml((WIS86QH9A9HT3VLQFAwbtxD6URLNgxyQtJcUODQQgRgH25nHsT1QLonrLWJR3yYfXnkCSiX1eceHDE09P3pf2jGUzrKB78lxtrwngKqb0(wkvlweYzh4BExUONjqQKysuSi1ZlJE7GDYpbzO0(nDCgTJM3(0GdrxD7TQll4K2dTM5RejXa73yPS1cVjOaUqHmw9VzSjTaveWBDtaQAGRQZpCThsjy)LBpaw)Btsd)9KQz1zTtHDzoyXtIpN5GLAmQSe0Ll1cgO)uIJffallff88YQwrOLM4ccK(Uwi4dpP(B0Su)b0UkKpimwH)BZZ6PpFBkMvtdPChNhAiq1WLjfz90e)fsp3(wkjKwDZVszHKTdR)uLQto48mDZBRy762yEtvjjo)tbU)Pa3NjbR7sbEoQ3eA86)MFr2xkkJF8BPfDSaSIAG8vL5lOFSWzQ)v6sCWZ5t4iolJY5ms8BbnXXHxUd5nOyAO40XHAzzkEpEMuVX5LSI3dOQLO1BH3WThvQZeXIOQ8kNRGVuabDt0lpgUtWFyJs6hSjdQ1KxtNKA3c3)qrvBlHZLX6xSXKUnip0ehSN4Z5sw7ZLR6rBkYwvK8YO2uEQFKX3vX(AyUuxQhEkS2Kff1rBTR2vrZ6H1PxURA9qQCSmYXfthF8hfe2z60unfVA)QArsfjCwtr(DkSeINXHG8ozotBqnut0pfvfRB26PAzS9(UfwBXv1yKkycVUwBYzzjzyfKTQP2QiLtTLJRRkkAysBKWGrzMd14MhVpRsGB2n2PUt3vQRwZz1b8XVJDVT71CEEDjo1kSq8kmn8OIskQnS4UAWpUGWfByk3Xjx8akYTnSd3yXI8pNm679rONzeDVoOPCtjcNVijnNkgEJxMt(SdmP3pF(kX1(im771UTKfC9DWSeRNYp4lVse0QfpeStiuQOuDu7uyhMKKVyF7ML1rymwPrCDF8rhNqq5dvo0A31jbiBFEywmbSm5wJP06GCn74(lksDdT(wtcB66uZUC)9pqxPxUDGIi3REKMHfL7A6Igfdljz7Q4Hq4RRdd7(MwXpKp85Ylikxgege2y(5J8dcYKNQIxgdK3OMW89K5)KWUzQQqx67vUikuA0hVSx7MQwLhPCQhLvxeX4RSy0mfYZkp(us8dFDueBM)KhSfpvxa61hRkD1fq43GcZdu3MjOaWYRygSiwEP1ufE)IMw21yDvwHXOAv7PF(Ry4Z1l1QROli0hmsz36ogCHfZeyS4ayjfqVfgwb4CQPsQAOMsyLuRDKqE5PfPlUYoJwLc2g(N4am6psJElDjb3s3pwEzFAdJVAmLvVNqPSanl(zFLnzzoZ8O1UUArw2pnqCVh8mpfGR04MRILlh1P5Nu0Lb5POSCXdpWR9EnEolk(azI8RKRKwa09yz7HcoOa1fiJUP)Y8erwwkQ989w9J)evz17JVfajXWWqFEpPhVYvV)8YYMV1pk5BGgTF)V29FRHS3tgKp55gYAbjYaWwdGujCx9JwySYYxpgRZ25OvTWTsGZmPLUcS2FqG)wtxETD4wkt0aOv9YAlHyH)Cmayf)80s4P5C9Qu1QoE3eUFRd4QhGdtiBp8hMW(noObkrwWKmyjOdTeQBnL47258aoG4gZd0)4DnaDOmyZbOJnO6UeWaQ29xqfq7yDxXEyd4AXs5NhG6yD3Mb2gqVoBWnhgpNCdkM3wzb0IXXTfWvT61a6UnlEV6vpwuNR3BT0swXGdrgBZVIfc3ujQkQfOQ(9WOsJQ3IM1FaKLLXna0ZXK2k9H6W8YMSBb(wG1W3Ye3b)6WC9MT7hKTygqjlxD4USb7saVf4lEwU6qxX33HG1fYwXAAr38AZ(fhnAxpaBbU7ApJ1MSBb(wG11TxXzZ29dYwmdSVVXsd2LaElWxR7CQ(9DiyDHSN6CBEL7ONLT62AZtk4FYa8)IW7KfmEleP3ZEUUVyD2Vo4)nFt5pvEOd5xhCSs8uS89V5BQd2doURCkUHi3wHBnHAfu2khSOy)rZlz2BJghXUg8pza(Fr4DZCYEvywSa)DgNSfyxhNC7qUTc3Ac1kOSv8KtHWh7pTbwKa5SHA8gvCTtbVrlhOAAO2av5q0QZiZ3Ma7thlTQ9dHZN2a7JvDnxBqRCoEvcyJZlxTQ9dr7Nxn2CTbTQFK2sPgp1WVnqgtvOE(XpmkyrwDq3v7A7mOTJdkWz0ga)wFqM6pP0UyeCzvPtyVP2p9ud)2a52TU6UDTDg02XzZ4FwdptTH8pRXi0w(Nkgx8cNMI6sZ(Jp6wNF9k9DTLT7l3VFVZELJTeWxTmG4RRs3UxSF9gm7Ar2Ce734i2xmIs6)ZiD7OND62rpb0TswYkhjCh6Z76hIIC3YaYLPxPla6iMGBoaDemWnaGKt(NMefLCp)claRvyoBX4VW8i0lUMc8m4G)GGq5kPSD09PDk)(5u26GaSXb(5(J9ZyF)QFKND6PH5oIUGFc6JN1iUcowO2bPBGJWJTfXy0be34i4T7Je(ttuGDfl0YkaSbqRwwNBli1YxzdOATkm)VCaVlc3QJqdVlaTJefsKUZgW0OC(wbyo2ailLdMIRnQPOLGZQOdHcJ1mTWCfCf9QT4E2n6w5ZAtu3aTqtPiV8Sayln5je4nc22BfCRS2E7hMAn22n43StJ8edE3aERfL7kif9RNXUYNBjqBK3ZAtEcbEJGT9UhOvm2B)WulJTBW3mNxlCd0Ug8Ub8wZy7kGqBM8VNuG3KvQBbvWvWe2SnlpPaVj7F3iQGvtaMoEV1s5VR8R(UDukW6klR)3f47kxUFIH)wNIWpD49QF8Jehhc23OFCyKT66HGW(PH4ZQPS8QvKVCVAWrJX7efcD89e9w8w2Le)7Sv)OT2kDeYb4TqzGy)L0hrhq1q6b66019Z3JpA5RIexX63URmTqS(DkbmS(f(55B)KWZ6KWMZUlhUQzFJ1VzDsyMfjw)cFs8xWl02e6E6C)THunEJ3uoNcwwURwuUpaV8ZSPm(nAFEy8sQE3GUcPF5Flau26qP4o)6GKfdO3WBbfR)bLph0doU3zhuuP5g0CEb8eMZc2ZlG1z(6T1Z3krp(jmY22JEmXeDLOCVJ3asLLEETFF1nJFGUnKlaSN)0YXkRzdRkFfxf97a8DvblVYb8EYFPveJOsZXz(k6rytwoM7T6MFWNJdf7PWlKvq40qKDDFr5VbVaA97D2x7YzZNfkEaCPYxFkcpzX4g)ScOKZmyG46JTnkQp0DCvWb8RmOsRlhb5ZGxg)MGgWe)jmeVLCljERrftQYXO4Yv7VsTq8JTnjv(ViNuYFw157HL0Cu2D75sLLC7ksHThc(1b0E2bTRO7VoGUOcZBdTnJ9TQC(6cx96GaEoqaRbFxvg9UcbK8yMYx8uLV0xr6YtumAQl0wooUOrCtSPRSLHRPUOC5WjmgdUnRnQlYnKaXpr1J7(ffrbrDkwEVxPRKAlwkvRvnsTd9o(LQ18yC02DVD9Vn5k(Rb6hOhXQ5OiqM4ja90m2eSYIYMJLZIWVWeYHPh7zy3AUE5o(oQiVcGNeRfIYQZauAkwg5Gb4hK4KsDPGxDXETS8LMXLUpMnJUsV4eAmJFR695VY3TsoM5lg7bbSP(lJYhCkUZiLb7n2XuXHFE9rSS8c8Q)jkiMvWO)U)JLWyPtKReZVoYtsuuNHTcsmMKH5S5Cml7wFyldlyus6yY6DOFaqS31ciRGhnmAQxHCSxVOA3k6i08)5sCVJYpSeSr5owKWawQA5Tq(Y3ou8(Ew(GT7pMkvj4sjwwjoez3YY5f24i2DuDqH)6YkkuJWsFX7y790NV8thEXhE3HxmC4HxKMiEV)uqiy0H)fovibfA3y9o7)IczqvFxzE8r9BD(fd86(4JyvCRJwfC78toZGlLxQwyOybUPxCowSk6bB4kWGvuL1bnK6(KuETWMtoOhoF)VgoFj9WVMdBJLrYuT3tcwvupEs1Fd9Nb7Tja(EKZNnDkzBJ8T)rz3zfwFJs9Nq2Mn7qL3O)wdkyRdmRmHO9kd2HEVuwDR2s4BPKTDybO)l)fS8hGvagWu5VIycwWSnQk2zIYaYTSh2J4AVZpmIVsdAMiYSYYcbZsuoKG(iMa4K6ko6Rx7yCWHYRM5vlZmVW68t7dwEPKuiLMvfdnluYigA8PB5EgFkhjknkcMmE85nFv(rnIyzk)wgvKKWZziApVgXdBPzrA8EPlJRIethFawsgMaYBrQs5qQoxBhggB5zDFhHLSmxyPohDJacv8PcjdPoEncGmkjgaYXB)5R0Df0)f9kiaMXJIubjmb(ynGIHKLyS0XU6MFEbkAHFiKmQqYklloOGdshRV4myZIsgJ7o4pAJCnV8oIpkJPmg9QmxOvbMwnRWNVx9uc7FQrfJ9diP2MynCBcGndzYACK8rxKpayHrlLnJQrsiojEKPNYqoSItappzCgPp7YFzi3GiERrlvuEE0vfzhtLFOisza2iSqOaeVeuvWdJLk94aqxl6SKsZ1KfTZl)u2oOWZUE1SFtcUIOzY(dZQJ6fdoXZUc1JPLG)Er5TN8fa57lsZkzxlm5NnlnXCq1lxKU07RVh78bN8QtEP05RAjLZJp6ssl)4eLVt7LIbpK4jNnRWDauHT9Okvl4IkXdYpS1RvRvrc2KQzxBaiigOF7)IkHbr50LgkHVO4dM71bkPaof5tu3oQvrnTY)75fWr9KwYQRMTQ3R9EikXAAl)WWAJz8no4fvxOROm5)3Sw7AVs5YM6Y)(1yqOBwGop1R2BXk7LQVhhfvRruha)jxzzCmTGkR2cOdbll3ceJWh3Bo6qWSLZfotfLvH4g)iO4aOvbLLQukbPuHhjBxOxRSaoR6(sCTv6Gs5P7fVYo4NbDi0t)zHsZIkfTr5)s7u(K24)7kIXlRkB0jcRYJOOWepgh)0o4igKWYkQg9tJqtoU6DhOuBwP01d9Qa2xHI2MvBtyGLkO65w(qr1tvr(JsQcAiex8E)ixhkP9WNefowt8t5KXaO(fQCQkkPO8LxLKiKQd9ulo9ZVQ8pWj(jIdhx8qVGvsvo)N8ro8Q3X30pM76(LYAZkwM0Sbk9NwgcEz8NDA0R18I)5vYrrhOIIak8T8ctCOxTjyBLYSGpb7F2Qk1aw9wKkkTSYkklx9RjLelfTkEQOKUzQV(IbNcIGentlPhfNxYSS8k(zlfyo4e9f630H0(2bfWg5ewiW4XWRA1Q9Ib9pRBjwNQL1JDSxGCfUSScpfFRJoB1Vj)9Ff(DXBpy1A7B1s67bL15sjVJRvvLMISVow9wVziqr0xBhCsNgiHv4fu2dx(gZlQ9YG8nQ4lJO93BULqKMOQLrx((Pd0975PO2vA0eKaHZ8aAyH38KDTNjDX0JAfSBIXuyHsz5N2Ymu0gl3Ba0Ag6BvQ10U2ki(HZLvrAqa5H9lT3gO0tf8cNjEF5hZqj3gtlD3s681PZHgJonxly7yAJo3lB)VjOhkcKUdt7LDrSfzk5H8HFUIImLgFavLFHdCRxoGh4UAaVVnBJmkf3NpOFxL6ECBR7VhOwFLhS2Lx52pmWAb0caGgFY6oi9kjTmjO3)lSV8BD5vzDHXdGGhKZ5FSmCcf2uyLCv5RNxffMMBiKoixmaDm2oq4MsL8KQURMWuTqEkCgIHP66VhROBMxHVkRrHte(Sfplpz7OASlyOtx09NZbLViL28xdWc8khNK0CruAik(eMQg5OkR2sdRh0xTz2oAJPMYbNvA2Jo60XuiZRF8X21W30T10hpB0hVx556S2UOqE9AlbYGu2Am9eByADEfWwAG5EcmaFkvB3uWyU26zWPc((T(riUCeNowyFR08FtwFlYeRi22ZIo((DEHRuDRWgQD3gLUTBg5X1oB3qLoUW3kZ3tSmF92S57gZ23Yz8jQ2RvDM14I7fdq7XCSvy)DcHC3VHQL0g52P)Akf8THiaYKxdrAZtAi3Tpg1G8cOt1RBCl7CwQFeAjBcCgY5vBGrqJfd829egxokzvdI8tH1Aomc510C5p8ptWgKl6Npq5HqMlUZXW4vby)fIHX9JiSXWPfNEoLU8rfMN1k)5JeCTE2KiJ6XBOUaaF(PDAi(ZN3)4oRFelEAFHFnMUTlsh7VVd5Zovi1Pwkxd0nxIHpV)PDvDBSdQEDdTBDODSndfop5)WF(Dn4zEQJZtwU9W8SMX5r6teLNrhXpvjtiCeGhr)BFOdScNUQziuLNDiLJwPwRWLEiC7J50A941Akmu1zhwKnivf2)7QD)(fEVPWIn9c4oxG3g)e0AGUw8YpFnC34MFTfs9446yvSRnNi8NcqQl4H)7PaKDPWI1Fl()AFdxnwCX3t0daZxQ12jfx2vSaz7OIUmeqK7DVYkH9LuVS8KF6cChwRWRbR3G0i5WUvlpPuKMN42rQlw3PE5zw2nVpQgettV(Ug0hBkckK3FOlTeDLjqAvhkRHyQUo(5fXuP5foBVDVEPTH4woJfs4ABiIKgWuT9BKg5UDmIsYfd8uN6pzVaPgejzakR3VuP6HTKAQLyroW74kodJpR(Z3u0AMc1yJ6AhqUN9NNZTmmDRbo9u)kO62zwvAlXtVbpjO15IRnZfJkhj655P(0KBTX8GQQebWW1QVqNxmOpi9qALRYJde6HeBn)1h3XsJ7U(4Nak2EXG68IMENo5UdV(xDZwDAbYV3AgnP8adj0jz(EBk(zNiNCQz5Aw5kH12(NeZg0cBzGLr0WXRJ5fQVmMInI2s0idgTb9ndsox6VWP7UT3reQbEIFq3QxyXKNIyQ1wa8wtIh(LNyFCj8Ohi6W36Jk8Kjjp(FpFGNiZragnwagVrsKrm(00EIIAz5TnPsakSCdJD5FZn6IWunfBoX(v7cuZl8ZbBL615MsUs83OlMoYDiVBvbI0O8aPeiuydpQruGweskXc4a(BMLWHE1tDYIsYLxsN(oD57grtSKzvN4oaCV60xUFJEZDGWq3x619v7xRxLvAz3Zh0)nKN30VKXY(REHSlGPaowU1ZY7A9G(wVs0IBcE3o2UI18RaVGXOH7M8fd04CuV36L5kTOTNJs033PNr8o2wsx3vMrIgcuQzg3T9mtE)NcZuFhmtvRxu1rA9S8X(1Xm5zNzYXTS3jZKLBS)ZeZKh3FvFCAHfGOVCrz6ugMuiBuwXpO4uJdHmhuiXLcVxHDRyIS6MFwy9vrMo3m04kH0HtRz2jjNURPc2QpcfRe2wAPU1DdweCl0P9tgp7tMk1FgBm4oPb7MjJKP)6H(lZVnj96HddN)E6z2(6)Vd]] )