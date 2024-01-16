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


spec:RegisterPack( "Devastation", 20231216, [[Hekili:S3t)ZTTnY(3sMov2QXw2s2onTV4mtCSZ10PxBMiF9M3VyzkjizEHIuhjvCCNm6V93(bajaiaf1hon9nDM7JyrGflwSy3f7UyXnDV56B6poixCZV274EN0Tx3N1PBVEN17z30p)H5IB6ppy0hcMc)J4GzW)7LIpgKLhKhMeJF7HOKGXimYswKoc((D55ZZ(XJoAAy(Dlg2zuYSJYcNTiI6XO0Gj54Fp6OHrjdpACAW0K4jrHtVl)ir80WyXrJIcYYgmlz8Iir2rbZJW)7aXht(GiTZO5ZVP)WfHr5Vn(MHoXCavMlgDZV290N99a6eoESGBQiB0n9XMEy3Eh29z)4YBFt4NwE7SWSSW4PWFDXYBdJxE7R(TR6S8Nx(ZCt7EyVFaA6)mmojD5TaQV82fZXHnZOre8(xzbdJeauYfqZcGrESrJo(7Hg9UG8r3T82Uh3PNcuLn64V)WENcn6vJ)plYYxEB)5jHrzlVnpnm(dc4hIsMgosR9p7WEfZKR6ZtaC6ejompiDQi3ST6W(nxCe2JG4XlV9YqOt5IPPMyZZo84tGE867cINcZRFxKooig66vZgMgmc(LrjXJdXv2S)NL3MkYYtsHFnoj(WRp54IHyrgWaPb2ZmOPsY5YBNKMaKT(fClVg5wm72ZHUDvC2cCuKaFuamLNeghMbu1WjaTIM3W)gazWWKfW)mpz5TJdbu42L3UpmaZJcNecloT1bExK48EXhdZaGV35NVh3V9W)XeerHjBwywUiE0dgyv3EqhFlWClMjIZdIO5WRvtmyehNMmhqM9YYhKmxelsbiopnmjnm)H2gG6yCc2FXqyhwCEicQreTpJXfgUW(iaQbtdcJn7mobQbtYWj)Db55IuIHVpqPoa5DqQ5fPIG87G)8k4ZXaIH4bqiHF5DpKI)F)s4h59jrGGaD0(0dp5yAK)x0WmwBL81sshWT31OhhFMwpm7WOirqmnslMt7gljwWSE5Tdd1zkoHPzWkhSsdYpkj7ozNqUuKzbbpoVKmNaGZrwKjtePcKdxXenkzrCEMCxcSQm6dWFKmH2taTa(Xla5v6iupMrc3Nng)(LKmUuAqEvC4SKmAI8oq8aHfa3XG58F0ggcromlM25M(raRwgkzvG)V)kjOweJcygFZf30pyelcwixUgKHRwWFpBEY9I0b5j30V7n9hbKny5oG7Whfda2VzHiRWlohwwwE7tX5AemN7OGu2GS5bXDKJ1YB)8NbA(Ijt6mUyM0byWaUpekaq689NT82VdW95IOOb3bKdyQ2QMo9sEOT7IRbczbaqTpScyH)amoJ7Ztw5uOv1UJ4WZ4(VzD(5lVTnRvjnCoVwuDRZcuwsAq8ha9mjOq3G5GSNrSAcChnZNL15MCqnwdxIRFnThTM2JiVB5kBVoBYcRd2bt2YE4K9KDYK9eAYEstNSLCktsIbHXtgmla1N2qkcoGD6Tb0ehestsYjij50gss074PqhZVP)0ubyLJdXeg8N)dSvOrfawKrmNJLCHPHtNksrbuJcj5FKqEnuyMiniA8aWQTSSKzfCRQV)r2YGbc2WaDuGWVXIjblIYlWqv)(VlauXS1MaEbqn)OWUj(yEMNW))gZ6lfrbWws4BS5r9VMTt4HKfW(rufGMvc9blkoK3Sg9aQSicS3fjiKAmw79YBV)ob2pcc3tF(Y3F4lFZfh(Y(9p8LPjk7JlzE9lx7jOsMKOXj3h3jRq78aqxtk1kKL0L8hyhEBjdlSMqqBcAh9a9DWNCMlgReWiAqrJ2YxaGKWxX)v0cCxNcJQYrBrD)DzxbY3DOoubcb2ydGkbK7yXNqvRAAbrdZgce37ts)aPcKP(3bFAwWNa91GA7HI87jMv6N179OXsTXa1hwkKBgYaHTHtb7jja(6lFp8fqz(ieJYYdNrgStt0b85yq0AqjCrY0zoitac1eYK5w0Yn)hQKepD04oeSQfdE2MJbtaR4gmKmIZy4B2a)9E2qnkaKxX)Xa0Ge2SejCKhkjdbWZRtUZBHDB3l2J2QfbO44hkw3OLRatJqrB6ZYpaT9vm6d4XPYkA)ms6eSPue1PentxeBILzaUnkhf2OThSCi1PwgtPjdXjZpSvtM4k2q)fyczRJqBojOfOUhBnP8Ry9LatRXi6fR0gLGeIrQRp7uRRVz5SwI5PIrjZgguvpban6u6OkBqIaS0Le)hcxkowlXCso4o5D7akLhakehGcQLMf(N7hdZ6mlmnnjfNZtaTQ5WPEhdk9NLa)69z67OLDBqxcuzUurUgeJE1Hy)58XnHy0RKy4rby4e9TbkcshlQPsrT2AtP6XfPKQ(L3(TAQX1uAw2aqL9X88Q(29TRAKyazF2JlfJchlqLUHO7LkCyeAuZ8Gq0OLqu0A5XrpapxTycAptp0nyXlqtzjvRDl)7cH8oz3YEiEKxwQbIOm4FFCNZk4X66tpRC1WfKQUUYJAnRC98SY17l2kNZrQyLRwYJlJaA4oxsQrg5ZqCJsSicmklDrMlHldfrWEh4)jJKOMTigv2JCdvBB8dZwiGTNSX4K5PZdJhJOG5bGvMAr60vSolVLWt2Opqa)8awtjzANImXEvH(jz)oaDiZhdjNOG9KTeSGyw0CwGryoYoNGTpRZYB)PaghqVAcZk0oWzjJrV(btW9hTifDZdAHF3oN9P282KPGwqQt3b2rJTR0Tt4N1aLAMbd01ik4CuYUlzreI7cLx8qlxZmAD5ieIETlidjD4jnglK)jmeVcTLg6b37a9XGovcEyMaTT83hITnjv9VIXt(G7zuYau0CtlIl3vpliErqKl7cxdEXEnJxS3AWl2Bf8IUKvuoxSnrDnMl0MG0fdFyaCMMO5dYUJwoQUrbK(cNXhzVhalObPXWMHbHJKqVcHw8PrrlglCzZ5AGD9Aa21BTXUE6yxfRhxtz2k(CDP2pbLluJkx)s1Xz2QK5VsX(hz0aSVdk)yB6qB7tIhyFKw2utdvkAPdeI3Z1M(pVScw5u5(rgnOXyLTTK(XQUAyLPIOUfCw9CAj)Q5i7254QU5YqbX7jxH2T40pY2YhqcMpHZmyFs7oa)Wa63rCYLj(PcVyLcoOl2tfZj4mapPsHdP6FQx)zqYwzFyGI)rhYaO4DWsgP9s54bzdxmh0SrFa99afhXKR6qhb)nuGiMHQrqFrGT50mXi0z)Izq)Jc)GqQll7EbOwzEcQ8Bi6vKW89q9NI0hitYivdH4kCgGstcsPb4Nu4eHjZOyWbcBJjpCdJus84mwd5qXuYXa4eAiEylwHh6vpYf0DDDSH1LaNP5WV(aeFSiW9VMXzBR7LhQ8UayVfCiHK0H0XgtOZAxop81aeK2MOwm3T9ZPP)vrTV9bbRr4)4vJdMx1rGs)pNXTAqqrJuoHMgFBBaR0F0bgy0wNv0TcCS4teKS1GBi)D1alIc63GjK7GPdPJBFQjEuwUWegWhgfjgiJZHLdmCzp9I5wuvkcGm4X9kKJuU(o0jI4)9dH4bwsytGMjqpHsrgvfYoPryGPHrO5EOXyPI7bmih57qRrHLbb(PL3(BZXFJTrcrES5tODtilhXJginrCAuYqm(QQ4cMMR6yag5rb0QRC6ucfDsZ)BMtxOXJ5beNVV(sfCJtqmFAqQYN9K8IGjc06XcJHNLmK973LVRpVVMBnURIHkTzs3RPXiCX5Y9jPyJYgbOlOVg9g7di9ICZndat)MpnPuQtusmfbHlFFgskVSp6TCqCq4FqC3)iqDJrQmlOhHJ0iCPBRvgRgrF)KEzpLnHvetHGvq)tsmgYfqRZSiUtooZC)bL1dKGO8KbJdfS7YpP3QDw(X1fBH8W5SXPGPPcBVG)VW48bTqEqc6G3K7Wjb6il500KMfpaBVXTzH5YPFHXbPTl)HymxEnTcy6q2djMCogr0YDgEGKJggf8helaSRpfxCswKNrUHa502AUGNVEmbQvQQoTEv(aMjB7RhGqT1gdABHbvwErNSWR4J2gCyh(XavIauc82AwUsChCq(icTruzlgeDRJCmd(ycM3drgdIJyzZSxTvian0Y11b8YAthDx80fZkF7lFEd2wsMQwXl926ODWexXp8))r(ytx)7FPWKd0h)9(U9Yvz4SRLlV1FrzFFuyt5aVyBkxHbacGYPcbLdE3lVGzSIvXTgzfjZnOFrQ7fv3KawLojk5EmuNzalMOJLzEEu2OAnyRE4i80bWA7j1fnWk225WWfma6Sn9iehNiYI3lxhhV6IdytAOO((XWP02qQVSbpvutkXt4OTPzGLZysyruChFCwWNgiBGLa30rbXIb0WPBPDTXTSutizDCP5GWHwJ5dPaFIZ81mpgGB7xhvJM)qQOEJJT50r2WZSWqof2o76N60jnB3yDQwgk4GulzIuFmmf986iUbrlCjYXNjl2HYGNuNETYYxCxWWe8FD1f0y(wySWeVd9PCiZFHJgYir7nMhf8aT6Oj)hgXAJp52qJ8kXY9etQXOal)9I(H6A4gHBfo5ARg(6lEQEBzHbcGgHkuqAdsbgYUANDkEgszC65KTBEFs9ZB9VoItusGPaZts9gSP8voPQ6emtMaDsg(vM7jfrcM(W0nK(vWm52zip(0SN0aY2(oOmWSrFdNhYQ7nA8MSUNT0m)wVWPVvC6xaxsn)L3OGCKiyoForSXOrpt(r71iahJb9bhu8VuRnhy6pRtrdNiA6b8QwMYBlLosr1vdTGgMwihdhP9N6l1L4vNQ1EhUXP0QxQfYzptPYS5UDY6l)rshNshnOyJSETRt3tv9SOWsjkaaPgNDTuWGa0)Q8o2hUdD)FK4t0zAbnwGvl01WOzMomwWtFtdcgi)zoEEomw7fSkmftKFKWLpWmMK)VjO7Shl96XyTRVG8osuK)3aqG9sHXKdUXwLMUyE(amYfYlvc628rrHZX1PwvNWTYdHDfV88ET2)j7RzABy8Kfz8kElPzNjjJJwqlKT)8N9CeCTpyL1yqVATFAq44bIpISPZaJMqps2jm(L9(8NPX4o0qkSLa2dSEpmGMB2ZgTpHZPIjGLfFVO36mEg8fqBPnUf7eunuZaxTffNUICdKLuiDG97wCW8jKFkMNMmsEIoWWsCdW)zr4ikSQaJjAUU0KSmx(IvcgdPSwIdOjqTglso)1m)z5a2(MqmuMn7yDfUhGadtsCQZ0SfwsvS8MQ2rs48egNl1MJBVbqXHKv0tSq(G)yrk6H)0Wpi9hSkw415u4XaZ)SHHXJHTnWMKzQ04AkUPyaPi9M(iJBYKjdMoAmPnvfzHg01sciMUJ6NvLYUIQIhVSeQfh7WHZAzuav0gerJkSXk)USbZWqB50322tcffOgyulU7WHKgZMFLIgUuLhLp3fUSwZ1ulIzNmWEYL8H97E7bKWt5b1k7psn6rxoOcBbUIZ(7L3EDAak(aVJru8TS7BP7Y7OiE1eUEdTZkRAuzAEonu8H5qVCipvNmZNBzgCtm4NIpHstbA88qL)aAI)mErHLz1NkTGU4V3Sz(Y5x8kXOS1ZJVOptndyZs8pp8OdTm3VFcE258bdtIxKbdKi9KUd6nF0Mrb8y1A7vNP5ioDCj3U)fDhoFw1jFjbIpjd(BVbJLJDvAuFx5iqrRLey)PAqPBJCeu)vcMUAGXLXMLR0Tmxf9sERmMI)7cWUg4WbE7Y6S8Ai55IcYVT0dmMvvpgglP6aBrgbti3HwihBszdWUI3G2B)nL0g66uj7rcFSx6NuKFxUfUbwz8MqPl2alfUGv5FK8UYqPNWrV6pOBCkR2J1QtIsz3)ouJsinbbA0Eyua3B5T)dhE0s)yg)1JvSGPYFABPlN0xRmLajVNcMDfiAZgmA8GUDpTBhzU2)4UxWLhBxdZZ(7vYVEwjRXGBxwe7prjAgv6Vyl9)vFr16GivCKVQDsIdy1qwusU(FpQbbJFnSkLDfSxJXKwIvBAl(KAIBV1NDDtbB1y6yRvWO2wpECBpkvlrXVrNTkIiyQrYxQgrU)RChxfsEzsxFoLlIoBur6VQqf37440l2ctQK4M4CYYMkRouAHErNWTDp7yfzO28oO3XfBJQj8U6KuxS8nIyz7d5R1YyFLxAi7FOKOhnpsD)lhlVhahOcooMBrSrGKR)Ko1bVSk4VzFDvOI3X18aLjtaPsBop1071wNy9GYJaxyp64KfdX9ciLyP2DoGptCcwjjQyLA)(hHvjgcpPjjF5wzJErdvtlW7YKaTUOakh2EFTinQ7F2sJCPV7RvPrDRtAKpf31VbRNNg1TjsJ65wAuLKBFvsJCMU8FfknQhjnYqTEVAJdEtSfOwdRATlTXBNrdRtZKL063sXecZCjsahUWQFa6YRqfDwyeJvfXesCN8m3y3kM5Sup68(QqrVAOXHZ3ao1gDExYjRLkVJmJ(lWkvXvuQkNCoLQB14xDJRXU3k)Z(EdJx9(wCFNzBvx1mrLvhFuKI(ZOW5kgtAjCShFdNLURQFq2MMyvyR0QfpbZbotqwcfUWYYWdYnUio)iEMvFr5XG0BhNzzCqdJhuMA9ss(QPAEwxozfRl921Rl7SQ)dTY04caKFc7QNyoWopC6uYuvqjkPA1uxG2)lW6Q)1JZ3H1EOkli1w(H8kKrw7HYYDjIYm1aVgSeEeBiXVW3Gd(InjVZgM32PPCnqdpGaAc3t(YMZcUdiojQ)znm1fSLzuID(a(l02)sOtz409frrQfw05)PeMavgZbc8IYqP3kyQDkAxOmZiMXPOCSazlZOlbw(9IaUy8WWpdomXtp)i((Cr9(GWjN7g9FXjTk0UY4TKb8LNFsRNyoDwXgFoTjTyEMtjh6KY0WeJ2pWN8Q(V6Dvo4urW85bZhtDj7H1O9EruWNq6IE8tVkohVaEVhpntknTrw2rbXuiosHZZadWd09OHk(c3fI3shmsEiMVGdZCmG7ufDSOMzcB5VqLZi0n84D8DI8TYml5OFNU3F4jPXW2s7CNkcsBVdYj9n)g248ey6ko4ZEw0S6It6XszNB5D2XxmFQ9o7CnEDD4BhPS4VwjMvO2a2HcK(aMEzKsMxDXBoqAx89HfxcOR63PXNOF)gQ(z1kySCSRVLNvUWuNgfCr7uDnwReAVyvOutTAP1QOsTx6o(nomkuDTFKceHDEunIlif2jG(GsE3K5QUqXLEBCcLEOCcuGHNNU4B0M3fZ7ydKkxQeeofxSeKP6Y33zhSt(r42LS)QooJXHZB(nHcrxt7TEKUiuu)0ZhpTFUs27P9nRnPfOIeER71kPg4Q7(dF7H0YO3YThaR)DjPH)rs1l9xTtHD5nBHVaw(YNpJe)ZvYxzKTMsxRIcGvLxr(2UuRi0stCbbs)qde8HNu)5gwQ)aAxfYhegBNg2wUi8y0fH1fKP6VymxFxkEXx6t3Oy2xXGoJltkUymJcMR8B8RO7PYYB)D6IQ46u8pw3ggpSK2UzTr8JTD5ZBdAsLBM3Flj(VLe)fsI7UusONIRObV()oaZVikZGK1SEU8BqNxyS8wPuELYcILUz9Fqx(FU(faN9zruoZirUIL5iXIcG6M3pjuESzaB1ySXI2YO6TAVKv8EavDMWlv4n87QL6SDSincEQ3vWVtcbtB3lpFUxWF4kvbC(MmOo9lTjj1TPVFvrvBkHZNv8VCJjD(CGAn5JN8e)eFolzTllxThTPitXAZAt5uupJ3vj(uyUsxAp84zzn4Gy1rBDR2vtZ6H1PxUTEX)TCSSUxb2Ee5Rfe2F22Sj3lm5QAXv4q6fNIRcS0si(UIbY7uxR2rRk3jPFEDVNv6Mm7UVBH1wSQMQ3VA0DS346cCPiF8nl0fzBoDx9qnfWkUum)eyVAIYXMC6kWEyEzrfYwzJegLkZR3hV5P316e4v7FBEWhih7QcUmV2IsYX5843YTB4zksThA)sCQjTq8k8UnrV)gOUqoUJcQirsAylVq2OtBIHDhKxkHoeHEMrEAJI7tp)Nsh2H3tQL6frRWzZtsZPc8(Wf5Kp7al3dYNTuwExcZ(rJIPtbZDlmzr6O9dbQlhpTOWXGDeHsf1WroOOSvSTyZA1UqQ)9TyBhFl2QXr)90mKClUyB(8O9prfXj2coz041pms)IxLP3JIhJhtf44DtioUX19yRyI5TKuWNBh(CzjbILEOLzvbJhNPopexz5uxhOW89u57L0Ixzj6sX5ZcxW9WV9Ygw8kCkjr78kARUiIXRSyakLsIkp4ts8dFAqKyAWOhCfIuFa6zhRlx0hqOtcx5Y21KjOeWHZMfgJhYgwpYtxqRu23iW6x2nyD1wHXavv75w(k6gn6DQPtQ8xt9mGLbP2DUG3Zxcx0ORQQLNfoGVUCS5QLotGTr9TLxI)MW4RhMy77)VUT6IpjgTixyFOyNfPJ2o3pDU8UM3Z2(DFxuuwRjlh1RHJuaJb5POgh572x3E)aEcjYL)zY8jL17kb6EIS9qbhuS3gRcyzWI8ezwLkFI06S8N)f6baRl(K1Leddd959u(QkxV8JOED3C(rfFd0O97(P2)LgY9E0G8jFPHSrCFSaSZycvc3L)SdgRS81JX6SDoAvlCRelmBAPVyL9vc83A6YZCd3szIwaTQ)rBiel8eJfaR4HMgcpd3IxLQw1L52W979axZywydz3r0Wg2p3dnqlMa2KbhHlOHqDRPe)WoNhWde3yEGUhVRbOhLbBoa9Sb18W8wq19j9RaApR7A2dBbxhwk)LbOEw3DzGTf0RZgC7HPNxUbnZBRSa6W44Mc4Qw9AbD)MfVx9QhlEoM2BT0swXGdzsyZxxcPdMKVagfOQ5DQOsJQ3IM1Fauvk)na0CD74H6W8YMSBb(wG1W3YKfCS6WCZMT7hKTygq5)wD4UQb7saVf4lEwU6qx533HGD9r2v9SA5yGAqxQ3uEjO61KnREA0UEa8r4AaO9TH1zt2TaFlW662O6Tz7(bzlMbU306Ob7saVf4RZTTv)(oeSRpY2GT22dud6IXGFQxrrvUYHoK94QnpQG)rdW)jH3jZfClKPK0E(U8BT2Vo4)TFB5pvECl1xp)yTGd547F73whSp)42QP4gICBfUTkuRGYw5ivfBJw9sM72yWrSRb)JgG)tcVxnNCVkmloG)oJt2bSRJtUzi3wHBRc1kOSv8HvHWh3pGFoKa5THg8g1oq(kdnUhTAADZhsVLKa3JzDn3yqR48UI9anKGwtdB(a1yc6QADZhYMtqxzZng0kUdsFv0(Hp09INJw18HW77MO7XQUMBmOv8iLoXCLZlFTQ5drZNxRS5gdAvpIULAbESHFtGmMUADcIFyW45z1bDFTRPZGMooOcKbBa8B8PIR)y37IrW3ru8c7n1E4hB43ei3S1v)TRPZGMooBg)ZA4J1nK)zngHMY)uXyXN49Of(Su7ZF2VnC1BeNVTST)U9725SN6zlb8vhdi(0T2U9l3V(da5Br2Ee7UYrSRCev0)VG0TJ(It3o6rGUvYs6jeC7KO3ihcpbJUileTGCzk(6dGEIc9gaqk6stsIIsUNVJlaPftwqrzvCR4MTWPoe)uFs5DRQD0DZEcFLUkB94XyJhhKhmmit8Jl)z(cnKgM7jSwbjObMRraTE8YZLk(9zRdUThiUXHo2d8kF(ASay131gBi6zJWwmN9aXTah9W4VLPiHVefyhWi5lLb2cAqxpjo2JainU0awq157Gufa7zl62GREa52JRE2sjVPawG06PkQPIOvvbflOz)sNubC(YnOnp5fCkcwQNCnZRtFEjVAz4BVQN3WrtQxq3wb8vc2QfKUkG1ztAeoVzaFLG1FTC23Wv87RSmqVwoOEnwiwLQITc4ReSB2crdX5nd4ReSERh4RCrEvvs8vp2Fz4W8MeOBSqopWDRyUEub(kb7MXC1qCEZa(kb7xcoxFJ9xgox)EFFLe0vZHTBb(kb7MXe0qCEZa(kb7xcomFJ9xgomFXbzZycSwT2TaVbGf9tJQFoaP1NFeX1hvGVsW2CNc3iNpV9dtT(E2p4lM5RLZ5FKbVFaV1o2WxW72mPBpQaVbGT2nJv(8JiU(Oc8vc2MhHVgTzC7hMA3m6h8RE3sdIK7Ug8(b8wVzSjbDEneA)4c9AG72tiQ4RXTAdZJl0RbUBbHWPtTMmCV1YDw(UYVFChDRm9DXF)Rc89f2Lhz4V13A1hp8E5p)wIJdb7ZndugYwDtFqK)Kq8P1L)uwNIRW1tp)OHyz6aHU8fuEyAs8Fiw(ZUARkIMhGfgHZLBWub79a6zC6Ctn7MbS)ZF2XxLxNbNF7JLxwaNFNslFNFbJ0N(hwvkPVot4EoNWUYWLsmO693W53CoHTVhco)I5eE15G)YF(BWA3YiQKuC)DHufkN7nZbIV4wvFVToaRqxIjcUSRnlmEbvTwXGV2T8VLaATOQC0Xpiz(5zI8WjsQBx()FGiktC(XDo7GI6K(5RorWDyy(Uk1EDa6ZpU96mF7T1Z3kPlSdBF2vZxhGMMVat0vYxYTm6HBOyPNFw3wE7WhOc)ZCa7Xy8ZLPsjS4IHsU2JfhWFnoeFDGgZ9K(MAe1AooZxsVjWQxtOolV9NcyCOy)hw7rghojezx3xwJwXATs3oN9P2mB(uUWOjFz6sr4PEmPWpRbk1mdgiwpVRrj7oUYCIv1iw1(yU64O16YrimEuQiidjDOXcJfY)egIxrjcbwGKKtQYXOO0GfSu)n2dBBsQ6FrPfbYHP2dRO5OoHMZLQEXOQiD3DUiBjY1N)TSAM)xbU1at75gt9L10wYkxnMwFYjVoyAXZ2MlIQDQ7ArQ8MTTRdc0Zdc4m3HTOa7eeqTdWw6xpDPFD1K99iLIzUeyw(nNhv2kTVCP1VHzBMlTtLFRjdUlBSQlXZiX1VNERR6wuGcLVbqQcqfvBOAWsPE5EvP7QZXFN(7jeoA)UStsPw3tpJMOGvSGDbd3DafG0lOkxIYgUyomU0h0EZm7qjX1BstMbIdrb04Jik2MtZeJW6ZUygwriPxJDslr29cqG98KCZNsOpspGka4jHUHOMKmaLMGvIDya(jfoPvZh5c09ZupnizSUNHIPHXYAm7qbxE7cWAszwZKYAu8Tdsehmwmjyru(5NI7msfWEJDmvS)1RpILLxGxDprdXCbgm)hXhaAgmz3fa83GzNjPdPdyKKsper4CIQJC958yewDlsKrpONiDCaCmlXSHGTSc8zhsL9kvsfs3qOipe16B5RhKZUOxx3WE9KQDROJqZ)VlW9rA)GunH0uBQ4ZphvlZlelllC90ZwBWqQKGIlRyTE8qK1llNFaHIeFKQ3O0QQ6braydW(rq4E6Zx((dF5BU4Wx2V)HVmnXIAaiem6W)cNkKqdJYixR9FsH8OQptQF(ZMLcUxEEV2F(ZyrrVLrbr)fNCMfhlxsufOic2irM7LFJClXGLuHQfn57(Ku(nNIjh4(4zbFkC2Iz4MSCylTklp179OXllkVTPgvF1WPW(CcGVg3fiMmHSct9aeRTtTY2aRkNVuoNllMLt)MdkyBemRSHO7cT9H9(ovXIElHVJkG(HfG(B(MVblkHyPwfSQ)tiQGVmvwp)uzYIZ5DIh2JyB)yqyeVudQPi6S26YpJWSeNdjOpqiboP7IXFZ6oRpwuUg1w7lDm(8I56X8fyx14WnRBTTQJ1V1tCcU26Rf216sdZD4ZAJpYQ3lyswKSGNk5sjIwawbnlFAkz9X47j2DcSskgIhPs2E(XCdKjiImyEtxexfjMm8aSqloceEJu1YHuNg0mme23v5f6yhHLImFyP5wIvciulQoKSeB1BLaiJYqCGC8QF7ktVP9)Gh8dLsH)xGHBmFEu5Rv4sv5RLKcPohiygxekcNRYT3dg9MJIVWdedkTe4NwE7Vnh)n(yAz07bJQg5IcSi98bYtPonkziUPKhew7p3r4Jtsf4o3lk1MbudyEAXtFWOhgfjgWp4fzmzYLmTfZj6qFHQQdZVsnQbelY4PIPuvlgXr2IRGjcK7O4G6ZsgMrkZU8D9zlJ4wJMSWqL0PPlVoMkiWrKMaSryPjfK1LG6bEyOsJhdatvOttkTBt9ayC57Z2bpIlR3dJN9cGMCzY4d7xAeqMvp3AtpMwc(xfVHCKllix0rQvjdCroVPPj2dQ5tVGpjQM7pEX5N80t(oLVNnsY8p)zFsp5ZvWv6wtryhs8OtNw41c6rI5OkV8of1gxKFyRxRwRhChBQMBj5GquVYor9kvIoK2XpT0m)YIpyB9pqHlsSq5fWOTsLNJ3yNxuai9ZIPHnLPZElZv5ZpPDBvzD31tPJpixL)bWpxCZp3dZSoNsfnj))gMfEZMxvyUOJLl96Sq7xJLM(zJA9vdhZwWDCP(lVzX7YaQiI(fPGEuAiwi(NeHpLAQxaGksFllV50P4Cig06Xd4LNOP5dpmgFMf8i)JtezfprB84E1fhO9GLqx2h0pbK9bSgZvOpwjA2XZkYlC8HINuenbgAx0ilPXYxhxLffLVOuAVjgw4N25Bbq9o6ng5SRFQDZWhFex2syFsXZ0aZPxRmFO8TTamybR14yrphuDqbnO4fUG3BA((RQj5a0lTPy1PWbEDqCr79zpQvTQOxsVnvn2wFckL5uGT)EXEk6DSJAeYwCY1wn81x8u92Ym7Iq(v)cPriLyihtLfQx2f0gTnD(xztV20qhdnP(64i(vEzJsUbjcrikIWLVtjBksEsvKu9lgxRQwR7sP2uLzh7EwLNcNDio)eNi9(vWoSI9t8zoNo6ciXNuagZLVtrG2n6Hkcxv(r7fn5fgt)TOHxSoW0bNNIk)O5Xb8YyMYbDAUxt21klQ2UlRqTICmLk(kFQMQ6uPtLTXX9Bgn2G(wL3LjFl(YF4fkH7GCZd7wApnSAJ7IWj0zxl3Djqb6wtltxA69jE3NQLv)6R0Y2gCwG5)Bc69GXkFDz88OkF1JMqUcV)1v04P14dONkhGv18n158h3NuNd0FnIo)VYpgr06k0caNT(KZDJMpTtQRwj)UMjTRfmua5)(plchrXag4hww(q2xrBS92kLFVLGUL1MQsNR7)rAPz2Xsp8jAJOX1DsUPZ(9zPLJTaegP9MG4ef0FsqKoGX6echq1ea8P3bdGf6BCyknFEu4iPJMrFqWcM1enjqh9yU(FG00CWGuxsWFX5DFQNtaBp3u2U2TZ3FMEOVQWCRmA)8U6nZ1jbSpr(5N5ZQJw2cpF2N)CZA4ZB3y6tpx0NEpTNpFe4Jc1RttjqwKYgJPN4ctRZBgUYEp)tGZpPtVgofSMRnEgCQKVx3hkMm9a7EAYC4Kw5g87O)eHJUEepJ05(NmuAoV68p2S(77GdSYYn66ClUYUfM0ujdfXwVJ3O0UzZOESvhUFVcB5dFRmFpXX8T3MnF3y2(goJjM(99oZw5IlC4S2E3kS)oHqU73q1qAJA70)iLIyyFeazQ6kdT5jnK92KLIYcOtkaXTSY4nneDFDYSQnWk60YbgdX7RgXMm)lHuys48pqgXaZKsa2hZjZWqbAO4tkhLSQbw)XWkupge9mAU8pL)cmtqtpbu)A6relBEyk6QEPbPZyhSHV9MQCDp)ErahpxJ5dNzbuVrC29G)ItAvydhB1vbpXjslnkngZa80pFas0sMmzW0rJzXDEgMEva23qmmOjCLodr920(Q(V6DwdNrYfWuAvr1qcT3lIc(esvkZLwWcN4CmtuEpF9aqSbzkgfetNElveH(uJsaGak)C5hKum6PiMTiESGCos6Sa61vuMTuakU)fktKPN)zRq4E0VtjadMXJ4lblQJcy)csBVd8N6MgOeImAgNK6IA9loT1kcA(l6ECR1pslxJbzHZXh8Dz3LdqqPKSpci5KllEVklDq1fVbp(m65M7dlcDZv97ynDBweA2FFpYN9QqQvTuUvq38jg(fDpTTUlP9q1RBO9RdTLRzOmH1yZHKXPwjOb4PP8PjiLR8xQuzJtz2IOcooH8af)AhJpDUuKbPTfOdmSasLqnGWX6DBSZoypYggZbINPU4tTlIdvw(okmuvoPU8NQCMEpXvs2)MhTbNWPTEAnvXnaAhTs)vht5)TTpux8lKRHRBKpU0OSfvICXX3Ww6GHtCCiBqPkS7pu7(9x275fwSz(uWzNMmhJ51clf8UumWg9PCrGJHbiq7YKIaFmkyUYHhVIc9WYB)DQiNznhCePdzk8Stc1HXQRT3FCU022LNf(BPk1fiZ)Akvzxkbz933)VdWyfsE77nxC0v9xktr4IN6ACXSmuCbXjCyE(hu61WPoeyr5IO8LLf1sMnat7gvUTmjuEMbyS14MSwCVhqMdaBAQ1Gkd)8jxGCD(rFwhiZIWN6KW(DuVmn3Hp0HhWDyTs0oF9gKvsoCBkZJkfz1tC3i1lx3PE5bziEiwurxwqrpIHlRGTHe1ZUNvMLwIpfMRe03dnS1wWHTZPxd6JlfbfY7p0NwI2QuHTQFVnqmD)j)LfX0P5frdqE0XISeqQeLdChSt3oq8(jULZyPeUMgpmLvnvB)gPrUDLKM48E6t95uWvr5CP0BgkkKIE0qvVm9CCezFgvM72k1Q4dYVv8yj2ZExBrKOWYceN6DwvQX7wkpJnlmN0GDEVJR4HmEwDjISsZeUcJxgGsyaZKNquiORSijXxlXkGJigdSwKFgGoeHNduAayrsTW)P8S9yiWmU4jC1eGYU)HlYP5nykwq(mvkagM9JgPpzblxlm1v6yhrkmBwiYS8vNNqPIBuiNqgSPmTyBBCfe)Q2N(3bzCRdYydBlXn(tuw3YgeWlKgguIlYbQS29(W4Xg3W9QESAZ8yO2jCeI5Lz9jVnfJCrmB1zW4XzkBv5ljLkBKcZ3d)rndJKjrTIHK3(IBTE7LvyaxDEDvzVmyYPgDgrmKgFExyFVY(uTxny0HhUA(ZoULJg3E9XpjuC9uc36j1VcSUr6Tg783Ia96f5utTQzYH3qexgkDRthDa66sLfkLhiInl5TLPpJndsL7Vv1bwfGc7KWrzUL4tIrlYf6hpWr2e12oDj7AhZBwGU0h6(Turg5aEtfW5mByi7Kx7ejuD1sQezGXL9AaibBMQUEmf5dhqPVuv3IJwUOMXh35SgmmiriiIGmiyp)USbCzTOscsT6XcMV)kDTQLjwefFMIlarAP3YvIt0Ss4DV9aYWwzYzw2Fsge5bJcliUIJIZYBVMU2qDyMQxLCLDFlV8fDAaLW7vcNo7CJUWsGuPcZ6XB0BX1JAEy721NgWV48tQ3BVF)Q9t(jU9t(zGSYN4dVCgKypxuQvpdSftFsB3xUqW8mIF5IIBRV9AoE(5QUSN5VoWEHwA6vb33KYgGDfedGEGrYJqHHx2d5P1PFsDzSBaRIVImq1nj7BTlX9Dwx2aGW77UU32zXqPM(jVw9TTtnpCbUewnVQJcJbgCR5ZbIP3ETIv73ek9csaSYZgZEKmOUuuHp6vOeu84cKius7hjJGvtmuJzrM)vcSWCbqyp2JlUw5w5zV(AybPG06JZQLAWACnQ9fNRoFDXxqg4bJgpOB3t72Hmt7XJtW5AXMy1YFV(8LB9X2xlREA)vXQZF9O9FJS0djhbLjWKanQ(fHY7uxS9XYsW0bQJEHNYIv8rjmI8iIyD(c)n7k9ffsIRLlYY7xzPE2tn9oJLTvAN9Rqh84KfuAAIlil1k3tS1BjyiKQOzUF)JW4Kfu4(sUQbWk6rLZPf4DzvcPEfXzrj5QlMDxVHCVjwTDQ3RzUp23wB49pF18gT8VDA9V37)FRy8UV3XCr7BmOPHdHda5JSxKp8GWmrpgHtWoxGS1qSE89a9ulst1WwgDiN(tiFCjH1Jqh7SfLgzGS6r0ivOQ1gqD0xdCovxgza222EAcBFfHw)mXJNf7LQI1KSgrVsYAiDljlMLKtNtYAiosYITQyWDSOryrsdXxswJWijlooYPWzswSC8vrNsYAeKkJ8mn4d)iOYVbvUmY9jcXHZh42UdYkGTEMbxAo0UrbsBW9iqkuhYyQdDVVrytdYWwJQ5q0zPaxlaUpGXi7wQqYrc4UunI3Zye29myCursAnFIQ4zGLEpUGtS0sYi)IIl4GZmxNJReGW4aa]] )