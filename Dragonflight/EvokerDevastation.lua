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

local eb_col_casts = 0

spec:RegisterCombatLogEvent( function( _, subtype, _,  sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == state.GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            if spellID == firestorm_cast then
                wipe( firestorm_enemies )
                firestorm_last = GetTime()
                return
            elseif spellID == spec.abilities.emerald_blossom.id then
                eb_col_casts = ( eb_col_casts + 1 ) % 3
                return
            end
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

spec:RegisterStateExpr( "cycle_of_life_count", function()
    return eb_col_cast
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
        duration = 3600,
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
    cycle_of_life_count = nil

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

        spend = 0.014,
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

            if talent.ancient_flame.enabled then applyBuff( "ancient_flame" ) end
            if talent.cycle_of_life.enabled then
                if cycle_of_life_count > 1 then
                    cycle_of_life_count = 0
                    applyBuff( "cycle_of_life" )
                else
                    cycle_of_life_count = cycle_of_life_count + 1
                end
            end
            if talent.causality.enabled then reduceCooldown( "essence_burst", 1 ) end
            if talent.dream_of_spring.enabled and buff.ebon_might.up then buff.ebon_might.expires = buff.ebon_might.expires + 1 end
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


spec:RegisterPack( "Devastation", 20240203, [[Hekili:T3ZFZTTnw(zjtNkB1yllrzNK2lYZex7SnD62MjYBV5(hltjbjZnuKAjPIJ7KrF2V37basaqasQFy3076C3UBSiWdp8WdVFdGB6DZ13mCQFg7MF1RR3PD962Vt3x617SE3mm7HLSBgU0FYh9Nd)Ji)fW)9LSp5NM5NfehHF7HWy)PimsJxLmb((Dzzlt)HtozEq2DRg3zs8ItsdwSkK6XKe)zz4Fp5KXHXJpzAI)84OzHbZVl7ew08Gi2jtc9tthTiE6Qqw6j(ldX)Zi2NI)ilPZKLlVz44vbHzVl6MXwX8t)EazwYMCZV270x8saHcMoLXBmlDYndXgFCxVJ72)hwF7)mikoz9TV)He26BxTebxAN1)86FgAv)J75DCVxaT6TbFE9TlcstdIMd)1fRVniA9TV53UsPP9o277laimfTbVEC49Vs9hhcdyqgdAMpGFt1Au3xcn69(ztUB9T962XtcQIg19Lh7Dk0O3m9FVknB9TdxgheMU(2SKGOpYGFimEEWeL2)IJ9YNjxnKpbWPti74m)K5Sm92Qc73EXjyp8JMU(2ldGoLXMNOJnVGtn)X78JMdZRFNLm1pc66vlgN4pb(LjXrtdqoG0)R13MWsZIrcEuC0Xx3VB(qSkfy0ua7zA0ub5C9TZsIbY2WCUQFe5Q072RGUDvu6kCueaFIpmLNfefKcu1GzaTIM3W)gaP)44vW)mlE9Ttdau4213EimalddMfaloTvbEpK48b2NcsbGFWGbhW73b4)ygIOWKnninJfn5bnSQNh0X3bBcylyrz(H0C4hLtmyeNMeVeqMdsZgfVKfXsaiUmjioji7H2AGQlobhUAmStmklab1eI2NYXfoCH9Bau9N7heP3zCcubMKIt(78ZYyjed)qGsDeY7GuZlsy(z3b)5vWNJaedXdGqEeFxe8)8lbFIVpjeeyOI2NEC)U0i)VOHzQYk5pkiDa3EpTE09mLEO3HjHm)iAKwTK2nwqSGz96BhhOYu0NtZGvoyLgKZuq2TYoHCPiZccEH0bK5eaCgYImBglHHC4sMOjXRIYsf7sGvLjFe(J4z0EcOfWpEbixtfH84ms4(SP43VKKfMqdYBIcweNstK3dIhiSa4ogTK)hTHHGLbZI5DUzyiWQLIsGz4)9Vsc0zrOaMP3CXnd9NWfvZelxJsXvl4VxSm(EwYOS4BgcY6NaKny52N3HpXgbSFlcqwHxpawwwF7ZX5AimN7iHu6O0L(rDeJ16B)YxaA(QzZ6mnFM0byWaUpekaq68YZwF73b4(swy4O7aYbmvBvrNoNp0MDX2aHSaaOoewbmWFagNX7ZZQDk0QC3rC4f8(VDD(vRVTnx3tsWs(Ar5ToRqzjj(rFe0ZeJcD9xcYEMWvtG7O58zPDUjdu31WL4Qxt9O1upI8UJRSED2MfwlSd6SLE4KT)EzY2NMS9B6KTGtzwCeimE2Of(O(0gsrWbSJ3wqtSqi1jj9rsYPnKKO2XtHoMDZW5jmWwilIj04p)hyRqJkaSiLyoNk4ctcMpNLGcOMeqY)iH8kOWcwIF40rG1DPPXlY5wLF)tCldgX4ggOIce(nLnZFvywogk73)zfGk6TwhWRaQ5NyMnXfZZYy()R2S(swOpSLe(g38OHxZTt4H4vW(rufGIvcdblkoMVzn8buzriyxmsqi1yCT3RV9(7yy)iiCp95l)WXN)2lo(8Hdp(8KyPD0fmVULR9mujtC4047J6KMRDEeORjHAfYsAt(dSdVTGHfwtiOndT3EK6o4(NzJXkgm2gu0OS85dij8v8FfUc31jXOYC0gu3Fx0vG8DhQdLHqGBSbqLaYDe7ZOQvfTGOHzJbI79XjFKubYP(3bFAH)Nb91GA7XSS7jMv6Nv79KPcTXa1hwkeBgsbHTbZb7jja(Jx(b4lGY8jigLMfSGmyNMOJ4(7GO1Oc4IKPZSqMaeQjKj9TOfB(pwkjE(KPDiyvjg8IThdMbwXnAmzeN2W3Sb(Lo2qnXhKxX)JrObjCZseWr4uskcGxvLCN3b72UNDaTvleqXPpKVUrlx(6gHI20NMDeA7lBYhr3PsZB)cs6eSPKf2PantwfPJLPaUnjdf2OShSyivPwAtPzJXjZ3VttMOs2q)emHm1rOmNy0cuVUgtk3kwphyA1grNyLYO4htms9CzNAv9nnJRLyzcBs8IX(L1taqJ8shvzdseGLU4O)GztXXgjMtWb3jRxhqP8iqH4iuqTWSW)C)yqANfbjjXj4CEgOvnd86DkO0Frm8R3NQUJw0Tr9iqLAtf5gqm8QcX(Z5JBdXWRGy4qbyWm1TbscshdQPurTYAtH6XvjKQ(13(TkQXvuAw0aqLDx(8Q629T1nsCaz67XLSjbtzOs3am8s5bmcnQzPFaA0sakATWD0Jq)QzZq7z8WWGfTcnLLuT2R4VZfYBLDl9HOjozPgXctH)D3oNLZJ1ZLEwXQHnivEDLpQvSY55yLZ7jBLZ6iLVYvj5XMranCNlj1iLIziUrjIfcgLLSk1MWLXSqyVd8FLssutxfHk7rUHYTn6HfRyW2tUX4K5PldIMIOGUdWstTiD6swN13s4j3Opqa)sFUMsY0ojzIhvf6Ne97imGmFkGcIc2tULG5eZ8MZfyeKHSZXy7t7S(2FYNJdyunHzfAh4I4Pyu)Gj4HtwLGH5bTWVxNZ(CB(2K5GwqQt3b2rJTRiSt4NvaLCMbd01ikyDusVlEviI7mzu8qlxt1ADXieGrTZpfjDONgtzI)egI3G2sd9G3BF1XG8kbDMXxzl)9byBJtK)Ri0ZhCpJugGKMRBrCXU6f(rR8dTzx4gWl61mErVnGx0RgErBYkkMlMMOUbZfAtqYQXpmc8PjC5O07OLJYBuaPVGp(i79iyb1pjc2mmkyIa6Li0SppjC1uMnBo3aSZRbyN3gJDEQyxjRh3qz2s(CvP2pdLluHkx3s1XzwDY8RvS)jAna77OIp2MCA7qs8apgPfnv3qL8wAbH475At))NxcRSQC)eTg0ySY0ws3yvpfSsxruVColpRwYxphzVoDlhMlnfeFGcfAVCVFeTL7GemFcwOX(K0Be(Hr0VJ4Knt8tyoXkjCWqSNWwsWze6PsEaPgEQZ4zqYw5XWaf)JbKbqX7GLms7LmWdIgUAjOzJ(ag7bkpIXx1HCb)TuIiwGQrWyrGT50u2emy)Sfq)dd(itOll9EgOwzzmQ8BmgvKGSdq9NSKhitYivdb4kCkGsZ8tOb4NK4eHjlOCWbcBJOiCdJuC00uUgYXS5uGbWj0y0zlUcpmQEuiO7zZTHnLaNQeWVHaeFSiWdVMJZMw3lCQ8oFyVf4KqCYyYTXyYx7I5HRgGG00e185UzCo1JVkQ9Diiyne)hVzQ)YYbcue)5uERg5N3izqOPX30gWs9hdGbMT1f5DlhhZ)ebjtn4AYFRhyHus)gnJchm5KoU9PI8rzectyaFysiBKiphgbWWM90RwAqvPmaYbpUxHcKY13Hbre)pFmaDyjMBc0cggjukZOYu2jmcdmnmen3dnglHDpGbziFhAnkSmWWpT(2FBj(BCBKqKhB(mA3eYYr8O(cteNhgpgZVQmVGjzYo6JzEKbT6kRbLqsNuI)M(0fA8u(aIZ3F8sjCJIrmFUFImM9K8c)zm06XCJHxepMh3VlF)q((AERXDvCOsBMuJAAecxCUCFCc2O0ja6c6RXOX(asVOWCZbGECZNhxi1jmoIYGWLFifjLxoeJwoioi4piU7FaOUrivMlOhHJWiCryRLgRgsFVVx6Z5MWYIOuWYO)jjgd5cO1zUiU(Dt13Fqv9ajiklE00agpC599Qpy5DRk3czbl5gNcMMYmJc()cZZh0cHJeKJ3u4Wjb6il58K4MLpaZOXTDP5YACHXbPTT4HOnx(rAfqpGShtm58Cerl3POdjNmo0)piwayxFcU4eVklLcdbYPTZCbVAZycKRuLdADDXaMt2ounbHkRnA02CdQmIIozHx(hnn4Wm9J(YcbOa4TvSCL4o4j5Ji0AzLnFquToYYm4tXyDpeQniwYLnN9QTebOHwSUoIVS20r3gpD(SY1(Yx1GTLKPQLIsVPoAlmXLId))xKpwp0)Uxk05aDXFFO9OCvKo7k5YB9xu23hf2uEIxmnLl3aagq5KPGYcV7LxWzSIK5TgzfjZnOFrO7fv3edwLolm(EmvNPalgRJHzEou2iBnyREWe07ayTTFvzdSKTDwmCbtGo3MEeItJzPrhKPIJxDXrCtAOS((PG502qQVCdEkPMuGNGRTjPGLZyryruClFCH)NhjAGHa3Kj(rSr0WPAPDL5TSqtizDCH5GGtRrCNuGpXRq2uhgGBgxhzJw(qcRAJJn50r2qtVv5LWgvuOOCk(FE61pV4p6J)bYhTm0)bcL)98nwfTIBIzVZwRxJBxyn2pgtHkr4(eNMZT0wOavLerZrK4aMWReVrJPcXtS6tvI0zoaVlBY1C2XgRWV8wjPkK5VKB8l2yus(SFqSZmNqdSKrat(r5)lUhlRwEKUt6NIAdiA2rC1ePsxil8ou2vTT2AYlfJHLAzs(LQQMKtvAVfFtluLtTqm75uQuP8KNzDlPUWgAJRuWdSBLuj3ZAOhkBGnS2IH(aPgNDnNuHro(EPl)F8omMMHSptgQdBdbrXunO3m5Htz8PVUuUrIFMNKclAGqd0pRGjYnsylwfAtY)NymgDtfUYnvPMSZ3JlkQvaiaBFqef1oSvjjRwMncdhROI6XybojmyjUo1Q8eUvwaSn)8bETo8zhQOVoiA2Qu(kElHU044PHROfY2F5lo8Rq5dgLcd0RwhM4hmDe7tiB6cqtagMLobrN79LVqJXDO2bSLa2dSEpmIMBMZgLpHZP8jGHASx7TjJNgFb0wAJB(obzdv0ARSOuzKI2azj5sh4btiYF5mY5RLjXteMPcAlXna)7vbtOCfbmMOnic9mP2cWKamAgpzioWAOMkhrl9IcKNfQ3gG5NPz2QM7ZdbgojrdTKBj1BHHufJqePyNfV4hTfSlT5YBbuCmPCyMbY7)hRsWWwMe8rrqUKj4RQiDnfy(xmoiAkSTb2KSqwBkZXnfJifp3mezCJNnB08jtj17YWL2GUwqaXA4s1aCkLXLfpEzbuZTLYseO4OqqsWu)qAuHnwz3LoAbgVERbSZCsiPavaJkXDlrzrB28Ruk(eQ8OIunpoCk(BVkI75ep8uuG5E)7oIeEkS(SO)i1WJoXd5g3CfVKwxF71j(O4d8GtqbT3SVfXaSJK4vroi10ol9fsw(Sz0qXTqfDDtXyfpPhi5EOGz0H9zuAkqJxgiDYPjoP96ClVQU(abDXVuVzUkKrSo)L2Y5iaBNPeaJNv18WHo0IcA9zOdbzJghhTkfgiws)EJ8woz7OaoSkTD9LplItDl42DVOBjIAYo5kZ2UKm4U9Amww2vvtIpZBTGa7o)Pf(cBjtL1cMEkGXMXMfR0T0xfDsElnMS)ZkWUg2u3DztwE1K8Cro53u6bgi(C3XZnXNlP6itrg(ZOy8KlhBwrdWUIhlWB)nP0g6mIi6rCgv4j0pjj)2I1vdSY4TbI4gawkCbxL)jIdaaLZ1tEZFqhJoUApUwDsukpMwJvOectqGgDaMAJdwF7)WIB6QUz8xpwXCMk31IIQCsxTsxcKO4R17kq0wmAY0r96DAVoIci(XDVGTWqTbMN93RKF9SswHb32Si2D2FBgv6Vyl9)vFr1WrKsrNu2obXbSAinmot9VN0GmmUbwLEk1hNgJjSeRYAXQQKr2Q(J)uRgthBvdJAB1KmS7OuLef3gD2kpnhjAvuMCe59V2DCLi5fvs6aQaRS2O8A6tIk23XXRzsdmPu1OHZjdBQm6qHf65Dc329IUsYqLjt1RB(2OkYzLkj1glFJiwMft)1kLHSmknK9puLbJMhjpuztff38rYm(Hfmb3iqk0FIG6GvGp(BM1GpDJeCnFGsfvvrHnNNQhoEdpwpQWf4C7rNgVAmUxaPeRvkKAUpXX4XJVKvQdhEcE1xq4jnj5NypUrVOHQj54DrLTvvQnedR3xlsJ69NT0iB67(AvAuVQKg5sXD1BW8C0OEnrAKNDPrLQy36KgzTgG)kuAKhjnstTUxLzHRj2cuPHvT2N24T3OHvPz6MYNiZyQCmibC4cRQd0fNleYxyeJL3mdK4oHp3y3YN5CPEK)(Sa(3RhAJJrHKAWPYSzAtozLu59Kz0pbRu5N7IYCYzu97urC11oBUoVoto0zA8Qo2IhATes6jNjYQR7tSemEg5bxrBslGJ54RfS091LIIPPjg3wpkxWi(lbotqwcLUWI7weKBCvu2j8zw130iAKEZ8mlYdAq0OI6fwqYRNQ5yDPFnRlE771L92vAcTY04B1e3e26NywWohC6iUEwoLOGQvXLDYHpbRRUxpgShVqvkTGu5DQItHmIluL0mBIO0R3PRblHNWnK4x4LLo)0AikeD9JWXC(f7e6GaAc3ZEARzb7jeNe1)Igw6cMYmkWoxa)1k7Fj0PiD6UYOi1cd68)uatGkJ1abw9)un7bMANG2fkQmIf86UmIHSLP0jBj7EMp)ggHd)uWzINp4e(HuH69rbZgyh9FD)w5Ax54TGb88b9B9m9PtnB851cMbZZsQI3MvuBzy2(b(K3m8nVVKJt5jZNpyUyQlypmgTpWc9)msxuZF6vrz4Pk6dO3mj00gzzN4hrP4ib8Nbga6oWXNor53fGh9amtEiMVINM5ia3PRPU8lcqyl)fYAgHkB93ZpOxVtuzjN870Hzc9KgtBlTZDoZpP9EOqB3(JnGvpWuvCW99mVzvLN0UczN74brWvoFQ8GiCnEge4h5lXnAzPCwHAd4buG0hWPxAvi4vx82Je2fFFq(jB4QHDASh9h2q1p1RGXiWUUwEQDHPknk4I2PQASQfAVUouQPwT0QoQu712ZFJfJcLNLHIYbLU4R8tGDcymOeh4s(rjp)K8mnMkqxEbuGPNNonp0M3vl7ycKsvkpcN8QLhzQU8dD2d7KFekz(dRZDgnNZB(X7arxD7TEKoDhu)uRhpLFUu17P8nJnP5OIaEBATYxbCvd)HR9qLpkcKU3r3fNe8hXLpjtvof2NLRp)uL4Q231k8pBfFLw1AkcTkkawENXXlH)kfHwyIliq67BGGp0t9xPzP(dODviFqqK5jNWieHDXqewvsMQUA)V(UeSA(hshtsESIbDgxgNxT)t8xkJB8BOIVF9T)ov9928I)XQe)DWsAgM1gXp22wmV1OjLoUr)TK4)ws8tKe39PKqh3yCA86)3(y9frvgK4I4MFNcq(lG5mh5RkoNm(rIWS(pOt0m)qzd((SkmJZirHILZrIN0z5XjEwGWTzaBvySXBIIjvB1EbR49aQATGxkXB4oulvz7yEze8CNRGFNac62Ux4FUtWFCTQagSndQ14sRtsTB67xvu1Ms4Czf)5BnPBlobrcp(j(CUK1EC5QE0MIujRnxBkVe1t57QyFoitQl1dDplTboIvfT1UAxfnRhxLE52Q3OPfJLX5kWmIiFTGWUR2MshoNMVQMFeoerXj)8nkSeIFwXa5DYZk4K6QDs6N30ZzLQjZ277oyTfxvt5dnkgo2BQ6OWWp1E2iBlPdFiQPawXfI5Nb7vJLb2KxUc8imVo)A)vAJeMLk9ZRiFZJ31Qe46JVnFWhjg7YcUSEcdhWh)w2ddpNIuPt7xItnHfIxHNTj6rfa1fYZ7iJU57inSfNYumOnrWUdkkLqhcXiZi82i)qcZ)tra7WZj1A1BgOGflJtYOBT6XRYOy2bwU7NTyT4oRii9h0UHqYzUBHflshLFWxEIFPffEoyNqOu(fthpPOCRyBXnRnGFKG5hMX)(uSTxpfBveOFpfdjBWbBZLJWUIO9pr3mnCl4ezJx1zKH5p1mFafpgnLU1w3pP4GWxxUX6(C2Z9Bh(CX9Ccx6HsLv5pDAQ0Fi(1LL84afKDGSEVew8kU3HKC(CHl4E43Dzdpr(wLKO4VIYQlIy8vwmbLcjrfo(eh9WNhfYM7p5bBPi1fGErxv5IUac5jCptxHBYeua4GflcIqNSH1JSKv0kL5jcS6LDnwxLvymrvv63YxrNOrNtnvsL7lkmnyPrQTxl4EUk4IgDuvnISWr8Jlh3C1IGjWTr9Djy9XmPPxffQPjoOORGtQ6hYj2NztwLXmDkwTlJdxPgHqZ9tdeN1Cpt73DDqr5An5YrDA4iLWyqEkQXHE0Y63Zdu9dEirH8pvupPC9UcGEal9auWbL7TPYew6VklwuvPI39PoR)5FHEvJ6HVdxXrWWqF(azSQYuVgOKpzvw)OKVbA0H9(C7)sdzVhni3)PgYA59XaWwZjubCx)ZwySsZ2mgRZ27OvLWTuUWmPLUYv2xjWFNPlVWoClKjAa0YXhTHqmpsmgaSueAAi80clEzQA5qMBc3x6aU65SWeY2ZOHjSFLdAGsobmjdwsxqdH6otj((9opGdiU18a96UVbOdLbBpaDSbv3zEdOA3t)sG2X6UI9WgW1ILYpna1X6UndSnGEv2GBomEo5gumVT0cOfJJBkGlB1Rb0DBw8bvREm)nM5GnslzjdoefHn)4sicWK4A9phv1ptfLAu1w0S5dG86)Elan)E74HQW8IMSFb(oG1W3sfxOyvH56nB)pi7WmGQ)TQWDzd2NaEhWx0xUQqxX33JGDZr26ERGSmqnOlvBkVauEnzZQJgTVhaxeUgaAxByT2K9lW3bSUQnQoB2(Fq2HzG9nTwAW(eW7a(ADBB5VVhb7MJSnyRT5a1GUOn4N6uuuPJCOfzp2AZJk4F0a8Fs4D8sgVfIss6axh(Twhwf8)2VT4NkC3s(1bDvsoKLV)TFBvWEq32YP4wIC7eUvhQLtzl5sv(2O6xYS3gnoI9n4F0a8Fs4D9CYELywSa)9gNSfyxfNCZqUDc3Qd1YPSLIHvUWh7VkzwKa5SHA8gvoqUUgASpAv06MpKoVscSpMv1CTbTuW7Y3d0qcAfnS5duJjO116MpKnNGwBZ1g0sHdsDv081CZ(INLw18HW5JbN9XQQMRnOLIiLkXS25LRw18HO5ZRABU2GwoIO7OwGhB43eiJLRwh)OhgnDzAvq3v7A6mOPJdQaz0wa)g7vC1UDVpgbxUO4e2BR9Wp2WVjqUzRRUBxtNbnDC2o(NnigRBj)ZgmcnL)PKXIpZPRfUSu7lFXTnCvBeNRTST)Ud715SN7ylb8vldi(Eu2U95hwTdqUwKnhXE1oI9eJOK()es3o5jNUDYJaDRGL0rk42lzVrmeosgDEviAa5Is81faDKf6TaGu2LMfhggFp)mUaKwSybzf3IB5NSfEPdXF)cP6Uv2o6SzpJFKUkA90PyJN6N5p2pL9dR)z(bAijiZrAT8Jrdm3GeA94vNlLI7ZoNCBhqCRtDSd4v880yaWYVBnMq0XgHDyo7aI7ao6GXFhlrcxfkWoGO9CuDxIYo3aEgV7nLaMlzuIRudtjtgpBgnvE0oKjCR7NfcD3WIe0vixlFNUDqfEqu0KQ31StaVwWw(2nReyT2KgHZBhWRfSUVyGDnC5)ET3PWBu0o3GfI6K7StaVwWUDleneN3oGxlyDE5sx7ICDxl11p2pnCy7FHCoG7oXC9Oc8Ab72XC1qCE7aETG9PGZ11y)0W56ouU1sqRNdB)c8Ab72Xe0qCE7aETG9PGdZ1y)0WH5kO6BhtGXQ1(f4naSOt)Y(zbKgF(rexFubETGT5rySrrYC3hMkdKPBWNpZ3Oi9(idE3aEN9s2vMG2oPBpQaVbGTYnJL(8JiU(Oc8AbBZtxuJ2mU7dtLBgDd(63T0G0cUVbVBaVZBgBsgm3aH2pUqVc4U7eIsN1LDAdZJl0RaU7aHWAqTMn(GnkCwUo)OFApDe)CDks)Rc8Dfd)hz4VZhbYhp8E9p)oIJdb7R0Z6cYwDZqqK)Sa8DAL)P0o5NhONp4KX4D(acDXZX74K4O)GT(NT1wz6XocpL9deBWKzo8i6nbAGUMD9S)(LVy5RIAJ363(urLNB97unEB9lyAJu)qD138MmH9SoHTvUefyq5ddG1VzDcBwu7w)I(eU(c6E9p)n4fbYe6(n4(7cOR7AEV5CG4Z3u5hVPJWR7j2mg)o8Arq0k6Q)eZKxVI)waOnIQYt16rXlhKYYcMjOU94)VJyHPSbD7C2r5x62dQVQITyy((QorTa6bDBVjZxVDE(wQ2tTy7Z(A(Ab008fyIUs8SGLsVca5l983iS13o(b6wKzjG9ycJ535HcyXVznYuE5Xa(RPb4tnZuEpPVjhrLMJZ810dmR8PPPZ6B)jFooKV)dVilMgmlazxpuCHFIxCh96C2NBZzZNZVLTepZzji8KVmr4NvaLCMbdexpVTrj9o(18iEf5WvTpLFvRO06IriiAscZpfjDOXctzI)egI3qzvhVTDetQIXi)EMYFT6d2g224e5)IYXoYHj3dlP5OoHMZLkF(HkjD3EHTAiY1v8TmAM7NuSnat9SJPUkbxdzL1JPvxPRBcMM)gGzJOAwhOgKkNLU5MGaEoqaRfIQbfyVGaYDaMs)8uL(1tr23Ju9kztGzX3S6QSrneztRFdlDjBANk(wtgCB2yvvvmrIR)a9Wj1l)2Ut8GYiVnJOlAOgSuQE3Hk1D1P73P(40GJ2Vl6KqQ190BYikyfV9NGH7oGcq6fK39EIgUAjmU0huEag7qve0BtIxaIdrb04lsj2MttztWl7B2c86fKEAVjTeP3Zab2lJZ0FxA(e9ACaGNe6gGAssbuAgETEddWpjXjLlqq(T98lKVZePCDpJzZdIexyPJz87knF8comTzsz1UjN9JzhnLnZFvy2GtXDgjmyVXEMko86nhXsZYXRE9vqmBGblMo81eMdM078b(BWSZ4KXKdgXj0RAdoNOlLSH8IIdwDZRkohOhlzQp4MfBXyWwwg(g2iRELs1vNDiKxuBk9T4POXAxuVKWWE9SYDlVJqZ)pRW9rk)GqnHWuB6MmFjQwMVqSU4wqNEdu9ht3VK4YkEXbEmY6LMXFnAczFIU8kPvv5TRpWgG9JGW90NV8dhF(BV44Zho84ZtInOgacbJo8VWPcj0q7ojR1HplxEu53CZV8f97vSZh41(lFbVHTBPD7A)6(NzWXYVFnzOicUrICUx(dUAbgSMU1trt(UpoH)agXjh4(4f(FoyXQf4MSS7PNZFUDHk9EY0153vQjAxLNbZH95ea)rCxaB2mYkm5RzRYo1sBdmUg2fY5SzXSy63CqbBJGzLjeTFRnFS33jV5H3r4B560(4Cq)nFZ3G3WD492jyv)NrubFMJmElJsf30J3XE4aIT9t(bH8LAqnfrNvwx(zeMf4Cab9rmbWjDxC8x)sm1flk)cpTYNnx8TQY2ldlWUQWHRFjO2Qkw)wpZk4ARUwyEXjQzUd3xB8f78EgNKfkU9mfCPerZhVoglENd56JXhNQ7y41Yxa6sLO98xgmqMaluJ5nzvuzKy24JWBTVjGWBKQwmKQ0GMHHW(Usp3d7jSKL6cl13sulGqTOQqYqSLxTaiLk3yGC8MF7k9OP9FHo(HsPW)dWWnL7pQ4PVBT8UqLKcj9demJlefHZVYuVhm6ndfFHoedkTy4NwF7VTe)nUBAP0JlI8cxffyr659fEPopmEmUPKpiCT)8ocFCwcd35ErH2mGAaZtdE6JM8WKq2i(RNqkNmztM2QLeDyitEf2YFYtKdiEJvNWMtxbUioYT4YFgd5oYDuFr84usz2LVFi3YiERrtw4qL0PPkVoIUDzdjnbyJW75sqwxmQh4HXsnECaORcDECHDBYxtHl)q6E4fbzZEL1mxauKltgFy(SvaYS8SRnTlTe8VYFqYOqwqHOJuRsg4ICEZtInhu97XFxsu13F86b9FE)Vtg7zTsF)lFXL0tUFf8RnvDryht8OZNNh1c6fh5KspJl5x0Qi)WoVwTrVElMun7sYbHOoLDI6vkLDif3pn0mFE(hmT(hOW5fwOOA(Blv5z5bB515as1xmfSPOQZBPVkpOF72Y7iCBVllUGCz(ha)SXn)khmZQCkL0K8)zyw4B2CQcZgDSyPxLf6WkS00nBuRVA4y2bUJlvFghZVK)rfr0Vie0JsdXB19zH47YL86KVK03I7kBYlolIbnUj6pVVIMp0zmUplOl)tJzP5V3x8X9Qlos51VGo5iyCci7d4AmRrFSu0SL3OIxB5d5Vpfkcmuo1kgsJfp1QslkkEEIuEGfmWpf)Bbq9E6bRO4z9I(ZtV(5f)rF8p0Enn)9CgPIwXTAO3zLE)kmgD8bYWMjkMoGE622X(TkXU3uqXt1w5NgJZh07mf6oE5HZNUIxKeq0d9KKGKPFW8XjvCAEuF1jqlmxT8i9OpDkkzIMdhXfzLkJEIsSpeDT0MaZyzKVNxmMcPsfpklL94)urBSCsgrnb03k9cSiE3GnF3wK74ETCNhWuFCVcJDaQkgwoCcD218zlgI(7nNw6XBY5J5SR991)ol0Y0aj(68)tm6A3uzGi0EiefBvMrXPC41LehP04JOhfdG3s)1ZyWJ7JNXrQV7id(R8ZocTUcTaWzJpzD3O(J4I8CVXFbJegDasXr(V)9QGjuc6a(H1fpz1LevAUTsgusbOBzSPQiYNUFogAMrg0tCGYiQDwueB6mFjgAzzlaHrk3()wrb1l)FH3XgMVDeD6FXhzdm7cyGlHP0YLHbterbeDqKljvr0ed9cxF9)OIhMEBsVF9GEp3H7jMZnPHf968YZuZlrjMBPfvd6P2mBMPz6U0GZkubRJoTmfE(IV8LM1Wx1UX0hpB0hVN75YboxuiVonLazqkBmM23gMwLRM2kTk3tGb9741WPGXCTXZGtf89Qo4QZ0dS7jXlbZGZ043XG9a(vCcFgPY9pBSWwlPXPMS(hAHdS0YngxtdUYETEMRYhdB9EEJs7MnJ84wDy)LjRLl8T08TVL5R32nF3A2(goJjM(dDoZQDX98bN125wHd3leY9)gQgsBKBN(hju6CgIaivEdsqBEsc4HcWqrzo0jfG4wwrYagJXwmEr5gyK6qXaJ5F7nt4Mm)lbumS5jhweox9mgd7J5zAEmdnu8zfJsA5SE(yyfQddIEbnx(NIFbMjOPNaQFn9CbLUmibJJQWG0f8OFGVYEYcro7EMppzBAZhEAFPEJ4S9b)19BLBdh3QRCEI(clnkmgtd80pFes0INnB08jt5I7CmmELa23qmmOjCfEQkFfkFZW38EJHtlZVCkT8gpqaTpWc9)msvkk0rWcNOmSmb(aV2TrSbzka)SjV3syHyapOSZ6tfpj)PhetTfIzRIMICVrWW6tVJAIszbqXdVqAIm9qVAKFTt(DQ6eWYrdFZhrDua7NFs79qWU22OytKr9GyxvkfF9PTQjJMVUx3wBEyWVgJaoVam4VZ85rik3xAukjpWcKCY15VmD5T4QlEl6(mS1m5(G84QF1Wogt3Mf(8dp0H8zNkKAvjLRg6MlXWVU3PTvJxOdQEvdTBDOTSndfvte3Cirse))FV97g8mvL8G9rscsZ2t5iOKN6IFQKp9oc6VO)npuWwHtB1AoPuyauCTs99fc(zRO0MhPz(BHPwOBepJSOSfzv2Wd(SP0bTG4yr2GuvyVVVY97N79QCl20F0NmRHHUyrhWLcExcg15HuII5bygeODzCEuPN4VugWJ3qXfE9T)oDDgzmhSegAr9vSxIdT2QRz0FSU022wKf(BPkvLLP)AkvzFkbzZ33)F7JjYHI23BV4KRgUwu)M5pQT4IzrEs8JiJfOxSESMeO66aSOCvy26IRVooBawteYcpywGWNbySv4MmwCVhqMJaBAQ0GkT48jwGS5)OlRdeL41ZTsy)oQxwE1)DbUJRuI2GnBqQLCy3uMhvks9tC7i15B6uVWrgIhIlQOhxqHhXWLMZ2qI65HNvucnSphKjf07Hg2Ak4Wm40Ba9XMIGC59h7slrBzDkwoU3AiMA8KFArmvAEE2aeUoMNcxHs0LY0KAMLu3e3IzSqcxtZhM0QMYTFR0i3UugTh4Po1xszKfLZLqVoGOqk65bu(guZZJipMrffwRuTk(0BBKexXZiUbrIYJkqCQoyvjAVqH8zSLKSoWRBPiKXNvxIiRWmHRW8LbOeMWmHhImgDEYij(kz9gCrmcyTO4maDGEd)fgaMxXb8)u4BpMcmTtfa)OEtLE94vz08gmfZpBHS(Scs)bTABlNLRfwxbDmZifwQbezw8(stOu(X9ACm5JfzktlUTnb8ArqlFVLTp9VtY4oNKXg2wIB8NOsIKBqaFHuZGsCr2xwsL3henv74hxoIvBxedv8W5P51(3KbS(IUP0EzWKZYps)NpOhSVxAFQY7dkgWdBn)fDBzPXT3C8tafBpAOTEwDpv)BwMERWo)DirVoro5uRCLC4mfX7(RIFn6pTmWYeu44bY)C1hhFXgrlpm(TnRLTEM58MlqxedD3wQiYCaFtfW5SyCapiVMv5LSU)lLzGPf9AeibBH8sxyoYhoIQ3OYHfhTCroJ725SgmmirWpKGmiyp7U0r87CGsv0u9JfmF)v6mVkkSik)m5vNEsr0YLItuSs49V7iYWwrLZv0FsgefbJCliUINfN13EnDMo6WzQEt8vM9TOY470akHZZRl57CJonjGuPCZ6XJBz(zxzzq72vxJMVEq)QJ27lRpo59ThN8ZazLpZfEznjXoofl1pdmft3VT9t(fyEgXVCr(rP2Cnh9FUCi758xhzUqlm9kN7BwrdWUcIbWiWi4rO0Wl6HWBD6NKNu2gWQ46eGxEtYHg7sSFGIfnai8UoiYTTEtvur)eN552MLMhUaxaRMFLqcJbMCRLlbIPZEvZQ9BderbXhw55gZEIiPUuwHp5nOeu0DbsekP9JKrWvtmwHzru)vm8wtcGWb8iUyBLRwFV(AybjN06IZQLCWA8fi6Rhi9Vo)lid8Ojth1R3P96qMP94XjyDTyBSA5VxFE6wFmJ1s9t7VkwD(RhT)Be3lmIrqAcmjqJUCzq5DYtD8uX9JZrsxVqVS4k(Ocgr4IiEjmH)M51WeLsIRflYId)wHE2t1JoJHTvk((LRdEA8kQmnXfK1k3fpCR3IXuivsZ8WHNG5jZpp8L8J0nxrpQCojhVlUchQwrCAyCM8uZ2Zzk3BIvBN68ma7I9T1wE4GRN3OL7Tt77dLC5I2VpMgUceq9(uv9MDPmtFj6K8sBzqpR3TkIRuM2TSTrNF18OEx2y9(n58bAgzO2(cJufT91OJ(h6mvxEDTDMQqIHn)mRyYAxQQvwwVNkw2EpzSSLLK)eZY2ZblRnvmUxf9S8XEvXY6vIL1X9bKtwwl3TqprSSECLrVBwE4hr53OCzvFIkU50iB3XHqwpZK0CHBuy3YNiCH68yQhW)E9qJh2AD404TuKwa33(tBTLkB8IGBPAnFY4zFYu6E8BZmFAVmzK873m0Fv2DXj3mCyWIF8Mm4)7M)3]] )