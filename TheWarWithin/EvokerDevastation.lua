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
    aerial_mastery                  = { 93352, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame                   = { 93271, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream            = { 93292, 376930, 2 }, -- Your healing done and healing received are increased by 3%.
    blast_furnace                   = { 93309, 375510, 1 }, -- Fire Breath's damage over time lasts 4 sec longer.
    bountiful_bloom                 = { 93291, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame               = { 93294, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 41,237 upon removing any effect.
    clobbering_sweep                = { 93296, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 45 sec.
    draconic_legacy                 = { 93300, 376166, 1 }, -- Your Stamina is increased by 8%.
    enkindled                       = { 93295, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    expunge                         = { 93306, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    extended_flight                 = { 93349, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance                      = { 93299, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    fire_within                     = { 93345, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    foci_of_life                    = { 93345, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over 4 sec.
    forger_of_mountains             = { 93270, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    heavy_wingbeats                 = { 93296, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 45 sec.
    inherent_resistance             = { 93355, 375544, 2 }, -- Magic damage taken reduced by 4%.
    innate_magic                    = { 93302, 375520, 2 }, -- Essence regenerates 5% faster.
    instinctive_arcana              = { 93310, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    landslide                       = { 93305, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 15 sec. Damage may cancel the effect.
    leaping_flames                  = { 93343, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth                     = { 93347, 375561, 2 }, -- Green spells restore 5% more health.
    natural_convergence             = { 93312, 369913, 1 }, -- Disintegrate channels 20% faster.
    obsidian_bulwark                = { 93289, 375406, 1 }, -- Obsidian Scales has an additional charge.
    obsidian_scales                 = { 93304, 363916, 1 }, -- Reinforce your scales, reducing damage taken by 30%. Lasts 12 sec.
    oppressing_roar                 = { 93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    overawe                         = { 93297, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 30 sec.
    panacea                         = { 93348, 387761, 1 }, -- Emerald Blossom and Verdant Embrace instantly heal you for 21,170 when cast.
    permeating_chill                = { 93303, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by 50% for 3 sec.
    potent_mana                     = { 93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by 3%.
    protracted_talons               = { 93307, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                           = { 93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall                          = { 93301, 371806, 1 }, -- You may reactivate Deep Breath within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic              = { 93353, 387787, 1 }, -- Your Leech is increased by 4%.
    renewing_blaze                  = { 93354, 374348, 1 }, -- The flames of life surround you for 8 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    rescue                          = { 93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    scarlet_adaptation              = { 93340, 372469, 1 }, -- Store 20% of your effective healing, up to 23,667. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk                      = { 93293, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic                 = { 93344, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 1 |4hour:hrs;. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    spatial_paradox                 = { 93351, 406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by 100% for 10 sec. Affects the nearest healer within 60 yds, if you do not have a healer targeted.
    tailwind                        = { 93290, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    terror_of_the_skies             = { 93342, 371032, 1 }, -- Deep Breath stuns enemies for 3 sec.
    time_spiral                     = { 93351, 374968, 1 }, -- Bend time, allowing you and your allies within 40 yds to cast their major movement ability once in the next 10 sec, even if it is on cooldown.
    tip_the_scales                  = { 93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian                   = { 93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5 sec.
    unravel                         = { 93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 88,285 Spellfrost damage to absorb shields.
    verdant_embrace                 = { 93341, 360995, 1 }, -- Fly to an ally and heal them for 84,954, or heal yourself for the same amount.
    walloping_blow                  = { 93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr                          = { 93346, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8 sec.

    -- Devastation
    animosity                       = { 93330, 375797, 1 }, -- Casting an empower spell extends the duration of Dragonrage by 4 sec, up to a maximum of 16 sec.
    arcane_intensity                = { 93274, 375618, 2 }, -- Disintegrate deals 8% more damage.
    arcane_vigor                    = { 93315, 386342, 1 }, -- Shattering Star grants Essence Burst.
    azure_essence_burst             = { 93333, 375721, 1 }, -- Azure Strike has a 15% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    burnout                         = { 93314, 375801, 1 }, -- Fire Breath damage has 16% chance to cause your next Living Flame to be instant cast, stacking 2 times.
    catalyze                        = { 93280, 386283, 1 }, -- While channeling Disintegrate your Fire Breath on the target deals damage 100% more often.
    causality                       = { 93366, 375777, 1 }, -- Disintegrate reduces the remaining cooldown of your empower spells by 0.50 sec each time it deals damage. Pyre reduces the remaining cooldown of your empower spells by 0.40 sec per enemy struck, up to 2.0 sec.
    charged_blast                   = { 93317, 370455, 1 }, -- Your Blue damage increases the damage of your next Pyre by 5%, stacking 20 times.
    dense_energy                    = { 93284, 370962, 1 }, -- Pyre's Essence cost is reduced by 1.
    dragonrage                      = { 93331, 375087, 1 }, -- Erupt with draconic fury and exhale Pyres at 3 enemies within 25 yds. For 18 sec, Essence Burst's chance to occur is increased to 100%, and you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    engulfing_blaze                 = { 93282, 370837, 1 }, -- Living Flame deals 25% increased damage and healing, but its cast time is increased by 0.3 sec.
    essence_attunement              = { 93319, 375722, 1 }, -- Essence Burst stacks 2 times.
    eternity_surge                  = { 93275, 359073, 1 }, -- Focus your energies to release a salvo of pure magic, dealing 75,951 Spellfrost damage to an enemy. Damages additional enemies within 12 yds of the target when empowered. I: Damages 2 enemies. II: Damages 4 enemies. III: Damages 6 enemies.
    eternitys_span                  = { 93320, 375757, 1 }, -- Eternity Surge and Shattering Star hit twice as many targets.
    event_horizon                   = { 93318, 411164, 1 }, -- Eternity Surge's cooldown is reduced by 3 sec.
    eye_of_infinity                 = { 93318, 411165, 1 }, -- Eternity Surge deals 15% increased damage to your primary target.
    feed_the_flames                 = { 93313, 369846, 1 }, -- After casting 9 Pyres, your next Pyre will explode into a Firestorm. In addition, Pyre and Disintegrate deal 20% increased damage to enemies within your Firestorm.
    firestorm                       = { 93278, 368847, 1 }, -- An explosion bombards the target area with white-hot embers, dealing 34,610 Fire damage to enemies over 12 sec.
    focusing_iris                   = { 93315, 386336, 1 }, -- Shattering Star's damage taken effect lasts 2 sec longer.
    font_of_magic                   = { 93279, 411212, 1 }, -- Your empower spells' maximum level is increased by 1, and they reach maximum empower level 20% faster.
    heat_wave                       = { 93281, 375725, 2 }, -- Fire Breath deals 20% more damage.
    hoarded_power                   = { 93325, 375796, 1 }, -- Essence Burst has a 20% chance to not be consumed.
    honed_aggression                = { 93329, 371038, 2 }, -- Azure Strike and Living Flame deal 5% more damage.
    imminent_destruction            = { 93326, 370781, 1 }, -- Deep Breath reduces the Essence costs of Disintegrate and Pyre by 1 and increases their damage by 10% for 12 sec after you land.
    imposing_presence               = { 93332, 371016, 1 }, -- Quell's cooldown is reduced by 20 sec.
    inner_radiance                  = { 93332, 386405, 1 }, -- Your Living Flame and Emerald Blossom are 30% more effective on yourself.
    iridescence                     = { 93321, 370867, 1 }, -- Casting an empower spell increases the damage of your next 2 spells of the same color by 20% within 10 sec.
    lay_waste                       = { 93273, 371034, 1 }, -- Deep Breath's damage is increased by 20%.
    onyx_legacy                     = { 93327, 386348, 1 }, -- Deep Breath's cooldown is reduced by 1 min.
    power_nexus                     = { 93276, 369908, 1 }, -- Increases your maximum Essence to 6.
    power_swell                     = { 93322, 370839, 1 }, -- Casting an empower spell increases your Essence regeneration rate by 100% for 4 sec.
    pyre                            = { 93334, 357211, 1 }, -- Lob a ball of flame, dealing 21,320 Fire damage to the target and nearby enemies.
    ruby_embers                     = { 93282, 365937, 1 }, -- Living Flame deals 4,198 damage over 12 sec to enemies, or restores 8,755 health to allies over 12 sec. Stacks 3 times.
    ruby_essence_burst              = { 93285, 376872, 1 }, -- Your Living Flame has a 20% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    scintillation                   = { 93324, 370821, 1 }, -- Disintegrate has a 15% chance each time it deals damage to launch a level 1 Eternity Surge at 50% power.
    scorching_embers                = { 93365, 370819, 1 }, -- Fire Breath causes enemies to take 20% increased damage from your Red spells.
    shattering_star                 = { 93316, 370452, 1 }, -- Exhale bolts of concentrated power from your mouth at 2 enemies for 28,251 Spellfrost damage that cracks the targets' defenses, increasing the damage they take from you by 20% for 4 sec. Grants Essence Burst.
    snapfire                        = { 93277, 370783, 1 }, -- Pyre and Living Flame have a 15% chance to cause your next Firestorm to be instantly cast without triggering its cooldown, and deal 100% increased damage.
    spellweavers_dominance          = { 93323, 370845, 1 }, -- Your damaging critical strikes deal 230% damage instead of the usual 200%.
    titanic_wrath                   = { 93272, 386272, 2 }, -- Essence Burst increases the damage of affected spells by 8.0%.
    tyranny                         = { 93328, 376888, 1 }, -- During Deep Breath and Dragonrage you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    volatility                      = { 93283, 369089, 2 }, -- Pyre has a 15% chance to flare up and explode again on a nearby target.

    -- Flameshaper
    burning_adrenaline              = { 94946, 444020, 1 }, -- Engulf quickens your pulse, reducing the cast time of your next spell by $444019s1%. Stacks up to $444019u charges.
    conduit_of_flame                = { 94949, 444843, 1 }, -- Critical strike chance against targets $?c1[above][below] $s2% health increased by $s1%.
    consume_flame                   = { 94922, 444088, 1 }, -- Engulf consumes $s1 sec of $?c1[Fire Breath][Dream Breath] from the target, detonating it and $?c1[damaging][healing] all nearby targets equal to $s3% of the amount consumed, reduced beyond $s2 targets.
    draconic_instincts              = { 94931, 445958, 1 }, -- Your wounds have a small chance to cauterize, healing you for $s1% of damage taken. Occurs more often from attacks that deal high damage.
    engulf                          = { 94950, 443328, 1, "flameshaper" }, -- Engulf your target in dragonflame, damaging them for $443329s1 Fire or healing them for $443330s1. For each of your periodic effects on the target, effectiveness is increased by $s1%.
    enkindle                        = { 94956, 444016, 1 }, -- Essence abilities are enhanced with Flame, dealing $s1% of healing or damage done as Fire over 8 sec.
    expanded_lungs                  = { 94923, 444845, 1 }, -- Fire Breath's damage over time is increased by $s1%. Dream Breath's heal over time is increased by $s1%.
    fan_the_flames                  = { 94923, 444318, 1 }, -- Casting Engulf reignites all active Enkindles, increasing their remaining damage or healing over time by $s1%.
    lifecinders                     = { 94931, 444322, 1 }, -- Renewing Blaze also applies to your target or $s1 nearby injured $Lally:allies; at $s2% value.
    red_hot                         = { 94945, 444081, 1 }, -- Engulf gains $s2 additional charge and deals $s1% increased damage and healing.
    shape_of_flame                  = { 94937, 445074, 1 }, -- Tail Swipe and Wing Buffet scorch enemies and blind them with ash, causing their next attack within $445134d to miss.
    titanic_precision               = { 94920, 445625, 1 }, -- Living Flame and Azure Strike have $s1 extra chance to trigger Essence Burst when they critically strike.
    trailblazer                     = { 94937, 444849, 1 }, -- $?c1[Hover and Deep Breath][Hover, Deep Breath, and Dream Flight] travel $s1% faster, and Hover travels $s1% further.
    traveling_flame                 = { 99857, 444140, 1 }, -- Engulf increases the duration of $?c1[Fire Breath][Fire Breath or Dream Breath] by $s1 sec and causes it to spread to a target within $?c1[$s2][$s3] yds.

    -- Scalecommander
    bombardments                    = { 94936, 434300, 1 }, -- Mass Disintegrate marks your primary target for destruction for the next 10 sec. You and your allies have a chance to trigger a Bombardment when attacking marked targets, dealing 15,929 Volcanic damage split amongst all nearby enemies.
    diverted_power                  = { 94928, 441219, 1 }, -- Bombardments have a chance to generate Essence Burst.
    extended_battle                 = { 94928, 441212, 1 }, -- Essence abilities extend Bombardments by 1 sec.
    hardened_scales                 = { 94933, 441180, 1 }, -- Obsidian Scales reduces damage taken by an additional 5%.
    maneuverability                 = { 94941, 433871, 1 }, -- Deep Breath can now be steered in your desired direction. In addition, Deep Breath burns targets for 92,245 Volcanic damage over 12 sec.
    mass_disintegrate               = { 94939, 436335, 1, "scalecommander" }, -- Empower spells cause your next Disintegrate to strike up to 3 targets. When striking less than 3 targets, Disintegrate damage is increased by 25% for each missing target.
    melt_armor                      = { 94921, 441176, 1 }, -- Deep Breath causes enemies to take 20% increased damage from Bombardments and Essence abilities for 12 sec.
    menacing_presence               = { 94933, 441181, 1 }, -- Knocking enemies up or backwards reduces their damage done to you by 15% for 8 sec.
    might_of_the_black_dragonflight = { 94952, 441705, 1 }, -- Black spells deal 20% increased damage.
    nimble_flyer                    = { 94943, 441253, 1 }, -- While Hovering, damage taken from area of effect attacks is reduced by 10%.
    onslaught                       = { 94944, 441245, 1 }, -- Entering combat grants a charge of Burnout, causing your next Living Flame to cast instantly.
    slipstream                      = { 94943, 441257, 1 }, -- Deep Breath resets the cooldown of Hover.
    unrelenting_siege               = { 94934, 441246, 1 }, -- For each second you are in combat, Azure Strike, Living Flame, and Disintegrate deal 1% increased damage, up to 15%.
    wingleader                      = { 94953, 441206, 1 }, -- Bombardments reduce the cooldown of Deep Breath by 1 sec for each target struck, up to 3 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chrono_loop          = 5456, -- (383005) Trap the enemy in a time loop for 5 sec. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below 20%.
    crippling_force      = 5471, -- (384660)
    divide_and_conquer   = 5556, -- (384689) Deep Breath forms curtains of fire, preventing line of sight to enemies outside its walls and burning enemies who walk through them for 88,223 Fire damage. Lasts 6 sec.
    dream_catcher        = 5599, -- (410962) Sleep Walk no longer has a cooldown, but its cast time is increased by 0.2 sec.
    dreamwalkers_embrace = 5617, -- (415651) Verdant Embrace tethers you to an ally, increasing movement speed by 40% and slowing and siphoning 15,316 life from enemies who come in contact with the tether. The tether lasts up to 10 sec or until you move more than 30 yards away from your ally.
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
    -- Damage taken has a chance to summon air support from the Dracthyr.
    bombardments = {
        id = 434473,
        duration = 10.0,
        pandemic = true,
        max_stack = 1,
    },
    -- Next spell cast time reduced by $s1%.
    burning_adrenaline = {
        id = 444019,
        duration = 15.0,
        max_stack = 2,
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
        duration = function () return 3 * ( talent.natural_convergence.enabled and 0.8 or 1 ) * ( buff.burning_adrenaline.up and 0.7 or 1 ) end,
        tick_time = function () return ( talent.natural_convergence.enabled and 0.8 or 1 ) * ( buff.burning_adrenaline.up and 0.7 or 1 ) end,
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
    enkindle = {
        id = 444017,
        duration = 8,
        type = "Magic",
        tick_time = 2,
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
    -- Movement speed increased by $w2%.$?e0[ Area damage taken reduced by $s1%.][]; Evoker spells may be cast while moving. Does not affect empowered spells.$?e9[; Immune to movement speed reduction effects.][]
    hover = {
        id = 358267,
        duration = function () return talent.extended_flight.enabled and 10 or 6 end,
        tick_time = 1,
        max_stack = 1
    },
    -- Essence costs of Disintegrate and Pyre are reduced by $s1, and their damage increased by $s2%.
    imminent_destruction = {
        id = 411055,
        duration = 12,
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
        duration = 15,
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
    -- $?e0[Suffering $w1 Volcanic damage every $t1 sec.][]$?e1[ Damage taken from Essence abilities and bombardments increased by $s2%.][]
    melt_armor = {
        id = 441172,
        duration = 12.0,
        tick_time = 2.0,
        max_stack = 1,
    },
    -- Damage done to $@auracaster reduced by $s1%.
    menacing_presence = {
        id = 441201,
        duration = 8.0,
        max_stack = 1,
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
    -- Next attack will miss.
    shape_of_flame = {
        id = 445134,
        duration = 4.0,
        max_stack = 1,
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
    -- Able to cast spells while moving and spell range increased by $s4%.
    spatial_paradox = {
        id = 406732,
        duration = 10.0,
        tick_time = 1.0,
        max_stack = 1,
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


spec:RegisterGear( "tier30", 202491, 202489, 202488, 202487, 202486, 217178, 217180, 217176, 217177, 217179 )
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

        return stages[ power_level ] * ( talent.font_of_magic.enabled and 0.8 or 1 ) * ( buff.burning_adrenaline.up and 0.7 or 1 ) * haste
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
        notalent = "breath_of_eons",

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
        cast = function() return 3 * ( talent.natural_convergence.enabled and 0.8 or 1 ) * ( buff.burning_adrenaline.up and 0.7 or 1 ) end,
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
            removeStack( "burning_adrenaline" )
            removeBuff( "mass_disintegrate_stacks" )
            applyDebuff( "target", "disintegrate" )
            if talent.enkindle.enabled then applyDebuff( "target", "enkindle" ) end
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
            if talent.causality.enabled then reduceCooldown( "essence_burst", 1 ) end
            if talent.cycle_of_life.enabled then
                if cycle_of_life_count > 1 then
                    cycle_of_life_count = 0
                    applyBuff( "cycle_of_life" )
                else
                    cycle_of_life_count = cycle_of_life_count + 1
                end
            end
            if talent.dream_of_spring.enabled and buff.ebon_might.up then buff.ebon_might.expires = buff.ebon_might.expires + 1 end
            if talent.enkindle.enabled then applyDebuff( "target", "enkindle" ) end
        end,
    },

    -- Engulf your target in dragonflame, damaging them for $443329s1 Fire or healing them for $443330s1. For each of your periodic effects on the target, effectiveness is increased by $s1%.
    engulf = {
        id = 443328,
        color = 'red',
        cast = 0.0,
        cooldown = 30,
        charges = function() return talent.red_hot.enabled and 2 or nil end,
        recharge = function() return talent.red_hot.enabled and 30 or nil end,
        gcd = "spell",

        spend = 0.050,
        spendType = 'mana',

        talent = "engulf",
        startsCombat = true,

        handler = function()
            -- Assume damage occurs.
            if talent.burning_adrenaline.enabled then addStack( "burning_adrenaline" ) end
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
            if talent.mass_disintegrate.enabled then addStack( "mass_disintegrate_stacks" ) end

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
            if talent.mass_disintegrate.enabled then addStack( "mass_disintegrate_stacks" ) end

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
        cooldown = function() return buff.snapfire.up and 0 or 20 end,
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

        spend = 0.014,
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

    -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by $s2% in the next $d.$?s374346[; Removes $s1 Enrage effect from each enemy.][]
    oppressing_roar = {
        id = 372048,
        cast = 0,
        cooldown = function() return 120 - 30 * talent.overawe.rank end,
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
            if talent.enkindle.enabled then applyDebuff( "target", "enkindle" ) end
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

        spend = 0.01,
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


    -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by $s4% for $d.; Affects the nearest healer within $407497A1 yds, if you do not have a healer targeted.
    spatial_paradox = {
        id = 406732,
        color = 'bronze',
        cast = 0.0,
        cooldown = 180,
        gcd = "off",

        talent = "spatial_paradox",
        startsCombat = false,
        toggle = "cooldowns",

        handler = function()
            applyBuff( "spatial_paradox" )
        end,

        -- Effects:
        -- #0: { 'type': APPLY_AURA, 'subtype': MOD_DISPEL_RESIST, 'target': TARGET_UNIT_CASTER, }
        -- #1: { 'type': APPLY_AURA, 'subtype': ANIM_REPLACEMENT_SET, 'value': 1013, 'schools': ['physical', 'fire', 'frost', 'shadow', 'arcane'], 'target': TARGET_UNIT_CASTER, }
        -- #2: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
        -- #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- #4: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- #5: { 'type': APPLY_AURA, 'subtype': MOD_ATTACKER_RANGED_CRIT_CHANCE, 'points': 40.0, 'target': TARGET_UNIT_CASTER, }
        -- #6: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }
        -- #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
        -- #8: { 'type': DUMMY, 'subtype': NONE, 'attributes': ["Don't Fail Spell On Targeting Failure"], 'target': TARGET_UNIT_TARGET_ALLY, }
        -- #9: { 'type': APPLY_AURA, 'subtype': PERIODIC_DUMMY, 'tick_time': 1.0, 'target': TARGET_UNIT_CASTER, }
        -- #10: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 100.0, 'target': TARGET_UNIT_CASTER, 'modifies': RADIUS, }

        -- Affected by:
        -- spatial_paradox[406732] #7: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': -50.0, 'target': TARGET_UNIT_CASTER, 'modifies': RANGE, }
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
    rangeChecker = 30,

    damage = true,
    damageDots = true,
    damageOnScreen = true,
    damageExpiration = 8,

    potion = "spectral_intellect",

    package = "Devastation",
} )


spec:RegisterPack( "Devastation", 20240805, [[Hekili:S33EZTTrsI)zr1vHwmwMsKsY2x(jQRSIL3Ku7LnLP3C19pIcKyifodcGfpSSsPIF2)1DppWGbZaa(qXoB56U1rsaONE6PF39mZndV5d3mX3lNDZVo6KrNDYRp58bN8QHV(8ZUzs(djSBMK4n)JElHFiYBf8VVL9jVSCV8G4i8zpeg75JWilUiDo887YZtY(HJpEzq(DfZgmpE1XzbRkcPVyEQ3IC83NF8SW4zhNFh7EV07Hxni6yw0YGi2XZd9YYMUk2ViKLDSxsi()MY(u8hzPdMNKCZKzfbH5)C0nZSJ5NcitcB(n)6WZE5RaekW3NXFzw28BMGV8lo5vVy0R(H13(ptqiKT(2fPXRwF7KGv)46Fz9VOENtH35d3XwF7)Jxk8peIEZKWGS8mCsZW)9xjAilYBwiZ)MRUzI3Co1HLZsJcYFyAwrksazRsIVNLonp(MjdVzY8hMhYMM7bpdG2VI)L0a4tc84G4tSPSi2Qae9Uy86BhU(2NV(2CVqwu(ajSZMML4fnqm6RV9XhxF7SIflg4N6Tmoc(h2Gu2kVGiekaqg8QZxF73V(wGefgo9oyTeMD9A4JUKp0MFITbQiHa1HRV1e)byCo9SduZGfXr5tJxmDL3YG5vNaMF9LempvF(74R7ti6HDKy1N()ToIac)sde2ou4SvPbj818RfVeWlHl6hT(2ImGAL6f9X13UkolhgRKKWG54hdGogbpXbm4MCGtElyLgT5SsJiQZiIyTJmuJgSn8tw4cXP)PBX0)0nF6Z5KoTRt)oXZ6MgHd4GrBbvYcPfjsNzqK0jgN5MMvJiLd)FtwMYaLJwuIvHR(VHVfWsJisgXs7l4DtdwUKbQgFt08aGcT(23fsMjuyXkwQxO)uqDFww8kfpU85FIL67bev2QzPEO9JsuGWpF2cVIW8MuZMeZ)VvW43Yc9aHq4zRVnar9pa)3fRV9H4cqcmfO(EZIlY5ZIjtwF7l4INHWhLYcbJC4Kzrmm1ItaMh4)E)Dm87iiCp943((xC57U6fxozYlUmnwAuSK3ZT(rGLAECCOF89rdYUZlh)GOLtbdRP0B5sN0iLgRza9KG2IGL3LpvxK80ZTPkjgSCMXY1i9Eascpf)PWcKdrIrwzJ)Viex9ovzVkFpGoEgHKMFWIGu20zPmV87Q92glE)UaZGvhG2S(wgIGC70WIaSAgX(m8NlrtyTfE2myT7(40pcusyvJwCrt3R8(m4acyDFgl)EIpM(Z6F9CGD2lYNwCHvAHevgO9oyzuCkbWF8TVhEYIfS5igLLhScXObeDCk33ieTMwcxBA0kzo4sId8zexYCq6gggGYalp3mbKWa9mlMUCUpPptUM9VkajqdQ17lse8XR8(itm7s9c8dzE(iJ7DGfNhSP5qc15EG(f(Vmf9TH7HJysbI4rFevzaa4CNZgBmROJyWxdZh9PqArKZXYlMiAV0bE20NMLZvyKKYaFoN5zvLr7YaIz7G8HdafUtX1bC9HlZ9f(HbzdwfKMgNIMGwaQlZlsz(GE)vXWF9(mDwrXNnDibQSTtHGASh1eI9L5HBdXyujXWuUuqmcwOZuljidmOMsT4ARnL6olsj7aRV970u(PPrT8farKt4ZRMFVVRTrIditTOVLnpWNHQmdMFNceCnfjEbOfniEgWkMAmb9DG4ZcuNbyOzvqub6McPyCy5VRuiyLDl7HO5ozPMYcZGF(KbNR4XgAtXK2QHnivFDLpQnSYnYXk3O)0w5SosQvUgjpMQD3ajxsRXmwiiua)t2uW4ayXoc14JlZ11We9WQcgi3btLpXcjNsscI8dz2E5SKhwHULMMn9E2mZqHK2ibwOsUM13sOi3AnOPoXJBELSAjPqG57fI)K47awt)Gpb8Z(8VKBcxrhvVoxxrqoYjhJVF2G13(tECCiikhmFsgWxf7hSiajbhoVaOnrKNFdhC(N7ZLqwcMZOp6oW)k89ssdapbWi7WhRbk5mBGivbwhLS7IlcrChNL35fTeNiiAP92LJqq0CWrGmK0HEG6Ze)kmeVbDcc(c(x7PpgK3QOtUEAs73hGVBCQ8NIqpIrXfP4VKMx1vMsb6vErfEH2mlVbSHJ2a2WrBcB4iBSH20quonE12pniM(0Izpmf8dnmzA2D0krDbdqNle1gYzpfwl9sJa5GPbZfqVgnM955Hf(KVpVE7XUrDa7gTXy3iDS7)C3uul5W1vvFaQrOb7SUvLJtS2u03QU(JR8c43oT8HLPtcdf)5n4DI6nTGqCPnEYMUSgwz1I(XvEHoJvMoq6gRgQHvvT(muXyncxXhEYgZqoCWj1YBHrilu6WgQI0s8UGYipmdzGDJkSpPdNIpyk93rCYMF9PmNyLeo(PahilHGZumwdv6fWeN4ieusRkpStuXpgIoGI3blzKDlzSIIxSibSPrpadxeZ8WBIVEafO77OumVcnGWOG9GyFZyWAqgJTc((Wav0BzqCQ5zjXOzVzyGSb5pdTCYsFG8dJmkeGRWzakTaZnnma)KeNimb8dMhaDeLktyKIJ8Z42gNXwsHFJtOzy8sCtDyoAO0qo0wScBkbotl9nta2ONkc8KpWXzhU03LeEeeHLxykppAbrlkYWymprtGeKBprFMIYzq0(mq3z40KacbCfEDTCCvn3AOv6j0saeiEAi(RVX3ljxmY)gqqlWG(1tDaLnYm(Rp1t92QKsJOJ7G1LzZmawsZJtxvMjtv2PKPfnAzr4cxPdLS1aZky1rlP6LtC1aq4JP7dvmb4gLiZx2XMEnHjLOri44iyQBbLzskjbOSFdzu0iJCnNGzBrauKySi)M)X18e6HROywlocDwetAf()(yagIvm3ZTvmmXEEl9qEBk2lPVJGhTHOxQOpKPS7bmihfAqNOb2ag(O)rc(x4o2HOo(YlifbO0cjE5j8RDzy8mVq5qWf64FOhwomg8wxFvt1KOC1T6CDcGd(yEjfpMq85WC6ntEZVvl9OzrEj4RI0SgQaGRb7N8s9LMnIJqsqCrEgf3lspXm7stqC6FpqMPmduHZZrsAf5LZGvyQ4pZdsPK)BbdZ9a4ulXKLzkqvrMsBSQWK3y6xPQMCczVMdsGlHfnNjY0Mwniepa8ainlxLmzPkdJCnRJNotiDLsz8svgOBy60RLzdciLf9QVU10eFHSACTM(zSeNJKKPdulJbrtlvTW50m1wxt9ieXaRa0D7nliegjBQDwXcb1VPGPwZvCXleh9WNNgYw6n)HnyXwuIofVtxiovaAduNxQPKhSooDwCur2G87VF40ZsMBQHFfwlE)Gmmk1LGTqMzXt71neezD71TciiEBepSHF92ACZNbEMyIBxwoAh04YAFXqtjTN8VjpggDPa4O2RkZiP32sDAAiuZjxFxg1t0gVkvMWvs2Zds4HNdbNZYmu3(pXIzdVb3wYskDIujAipwrZwltJ7wjWmRyW2vywRCE4G03wO(vMl)iz04DbO1XROpK8Igu5XlPj5UzgMRLJNf69hKpNGQXu0jALrg0UYBNGfjewDc(dYlSFaSdtMI4MLWmYiYXKyfsMlMq65Vo758e0aQTJlaMz6hjx1rNfi3b4UXF6jznv0MsQENS3OIj0OSvKqH6HMXmzkR4ffSkoRI(rDJdWsCAoyBKCTU7giUK3Wi91ucsCsCp0PfLkAmuOREOICmPcT4tXyJivtDUjViNvuPfHgAbpWuolqxhDB8)9lnsyxU(1DqSwzgweFew8qnzGk1gBXmBzwYIWGr3R8VnYd2wfQYg7siz)Whl4dB(vBuOR3FrLbEY41nBVfn2DwMTuvAZQRnzG3EfNfns26iilnfdb9xwgZlxby(lg4jwegFVYz8bDl0c5B7ZwemhthZLyTYTLRTTkGulrbaF08psetlpCL3NNkEbdv7PZbxGN(PGLLoczgRhfQhgLfpbo4SXpMLf9SCD6Z1xDep4sQRmiaIE3rr9gHTwH1S6voL8JZ1vUn13BfspZdMZB2JEgS4odZbNGnhzxPc6wfSh9QYviEQjSM7S2cHT0per4YYq2ZWaPP5h8iE)1Mzlnonh7z7tJgkLzLqsQe)zdXAwj00rBgWv2mnYlqTS7PeN1caOMuqTqe4m6zsjX2IKWAxZ5orFjpKYAw20ujlsHmt98V9aU4hgVmac3H)lN9HNl)XtXFe1pLe69aXC87k95Y3HNgNHNtgVHPlpxi)4vwtlObY3Ch9Ot1QBhXb5YvKgMJiTKn)o8JXgg0RuXfL9JZDaEtN8TM2VgxvQO7a4LJa1uv1zWT(jEstnO3zvvDypEy49wo3hv8sr6ON9gl50TuJe9gHmVe18sXjFGtjYEAcKxuA8HgCW9UHw1g93FNKlsmCGHzA8WeWJ8F)GWCOIluqCos9t8uBwKCu1srCg6mhrWoI7LxMmP3EAj9M)P886B63kWHGnHVjI))gJv2YFTO1a0KMvctIM8)d24gW3onTijFkwmtX2naRK28WGeKc0RU18EObOSlhpQ3Hy)2nL9jsBcy3Bf(dbrxo6XhPp7o0wi8fq0)my6(WuAsyouApchqf0TmYBWawYNB)Bi)pgPXdk)whkzX1exox1DzoPLAPAEDRwgsBTWHQ434zYwaqEwNfrTaoEGjU4)Riyo1DfGAfTeuZ7ootFVQxKMQ94mVbmExa2bdDlkeveZey4ePkZBPqC13Wqc3OmdA(9Y7LBCU4QWgE)rrkAdmn4JMLH6DaIpJu2UqmLS3W4YUDPP6N4dk8wnliYhItjmoEf2IEOdklrfHtj4wVfxLvqSdFAjjfvJQhbf16u1Zy1BlHQUhNU8ulinW3lKgxqKm)USP82lXghT9PrdqOrCVHkGy2Klg2n1Eme5yCQY25yQq79CgnIKVQk8vg5CNaV6rQnuluTdBiMoBoDkQTxvhZSuWplW6St6M)6NXB1or)cxLCAPGavyJ(vQFKegMOT)GQWAPLjoRiINEcApcChvPTF7NfkMU(tKUJFkon4pIJoIStjIyQeOiVjOkEIMBBxZ3bfRV9dPEOH713(Z8UkW8BlR03a5K0zxuz49d31bXw1iNghUNYyK2A(GXlkHkuFJIGxzLdNTtVJpz3WsFCATqxCvwHZmzIYDwtHZ2KYv86Qmuna2x3LkdOcpTrkNTeIpYmM8gORvlOtal90HthLO68OnG07W1)gZtdjtxQTYnNNLkDurs7kvxcAky8JVvlZmkhp5sMhzkn4Tihv2RKBxu(c4NY8hGzLuiir7rpXxeNtT7j9NKnwLuEYvhmAioDy1o8sRVZu0lXcM72xRmXzwAuSwbZqnWylufbVvDjcNRB1gt2)QaCmgOJn0QMLCEDLVXjfUPkwXN0GX3SW4C9FV5ma3RsPf6G6pEWDofYeM9ASLeBQKv9AFFH1RZK(ETWa2xpZW7ok1irXH(K(AAgnASs5ikscFBss1i5LTsn39hRVKQZwLOIDjjENdBGj1AktCozWBB8bLkFvFe1qfQsJ3yb5gvRk12kzHoj1glFNiwMBKKpO1h(YGUOGSPwJhdgtUD48fD3)rYk6GTQexFmWzLjJrd39j4FZC)NGDqVi8I18nPzPY)ZQMmldVIoQ03lLHb)4IzOKashwRTpc4(DfhXSyUyYKJF3vcSKMI8DAi36dAXivH1LT3PTknBOBA0xl6Ig(LwxKnRyFTQlAyt6ICzoUzXRroEPHDrx0i76IQ126TPlYAJW)vOUOrKUOkg1hzRs21De4RdHTVz4Fde2(3id)9K(7(xwpaALQuZx7gQ4(3Sb(nBGFnyd0Uy5FLmg2kvXM1sNDvsP5s3XnBxhqP8Z(lph7nICZQTQezZpVqTRbWWbWvE98(uUjIPnfbIXYd0jk4arQIWptnZ5XiqPPIfWFE7qBwmgsrf4yTJyAsJAJu5E7Nuj9NWkvdCY5uNm2qDNQ0)JBWPT2H1LjRuwJ91zMMd1VJRxfE9UsU6ziMxcWfbkgO6AxE8HHCofr5hZP5nFyI5KmTHNKyLQYBHaU3oJWwZBR7M2KqwNyTCgHvYR2Wb8vJZXX7XZ4lXKSJhZxvMZ2lzBM1ZcNQ9X3hwF7BMZT9935Bpn(wovSH0QUpubOZ3)QZyO7hhitp(hVd3l5HSpZBhnmJptdrBW30P(ISJB5Qg6IHxwsxCJlwKmAVfjUqw8lj6x2KeUoRMO3WGo)FlGjqLXwsb3fGuBYcUjMI(0iAuLv8UIoIHmFz0Edn)EMhVzh5WpdCe(5JpMVtBPV(OGfJTJ(xCApL(EoEl4bVC8P9oO60PfXR9(g(ZvV05AW(2g(tVACuGsFBd)P5qH7n8xR7h6VTH)28nvNle8BB4V23WFUQNzjhIHUV3Zc9(mIB69CY1r54PcX7XKqKsA8rR1Z9IOYKNYcr)RPt1sp6ya7Uaubk28bOAYcEprfbIjO9h8mIiGmVaKYRcJJ9dlqnTy7hZpOo(zXPJWX)oDyuGLacB1fYVLLmV0(78()50rB2gaQIF8TYyUzTmYxajNxVjcoVEFj3St85nwaSM2oPFa3jP8tMK13(URS1EhOh5Ct7Kp5CgJk9)(1x9UJeXIFFGA)PE9Kb34QfVDzq2MNbDFHR11lrueT(Ex02G1RT4v6lIHWvHsQTFImQ3BkUPDWTDSS0Nab(TXQn1ZCVezzqFdThHwF7VtBsiRTv2t0orQAo1CruLUd1qA3khghnxvpd)5Yvz31OfEfqRexk7Pr7gOC5335gkPSYfOV75CMn9w4AhRTte6jGtvjwfzsbjJNxdZ7vsTTaQ(MeDNutRlVMjexn7Tnu2kkr7NkqvwRNHNLSP(Kz1Ql0sEgYqkUHvarQqdMbHZOvasfI)RQqUAC7k5ubLfpzTH16NErApF68qpicwRjkEdvF2yEbvp04mIQMOE99tUIrGtm349GARQ27M(Jwvs0bE6guf1VmsIDCNYAQVYnpSIGvNHqHRTT3lfc0U2g6sXSgpJP5Bq9AP7UIvPA7nDkxjdahtPt6DVuWvryAvBRPJ(kujfbV99d2zFuFc2J6FrfX2vNiFALpBrI4pdbbBeN6C(TUP0RT5GRWI))4HTOmTJLE3vhFnWIYpG(OG38FGZwwURG9IefG6VHDg998djSuwwryoNpKksfNHokgfyI4hKdbI03cKlnPc0UiEik3GhdLCY3dOQfdpwyT6509KMkzGYRKN7KT57TB5xLPoNG)fT5weYBT5dkT(AM70QKu7E8)vfvTReoxbVC5wt6CLj4Q7PqBzEM4Z5kMhYvlpIekYKS28Wy4BSTmUuf7ZbQMzDegezwhApLMOT2J3rlKMx0uar9j6tnFX12eK5w272FTGWo2HH5w283LOCBowyQ9Mf9r(orOQl2XApX4BbJGFcllZGHdQUFGXpu7H840m(ZJS8nLiZcViRP)hFRATxJSNQSysY6rOPCEPZ5BZVltG9f9yVOBBdFBIVQnWROSrQdkerUg47)CWWw9JaddHKsE(TyxYxxeIMx12(5DOwshQwscwTkicDMaM45PfenXmOH2xz0I30rfiuEP5OegUZcTZ9Yn)4zW2cwcDktGoJatAHNelaZbXY5cVZ65YbRv3SoYTej2Iizvoyk46Nh9HkQhSwih9jBt1GJ(wRNLeJ5iqp7TbhLlZM3l4VfNBIc1EnUJ9HzaUL9LD9dJUKciV4u8Sy2lJageQGSW7hIPOuSNduNXq8FvKGEuoFT(j5CWkCx9s37uZkYZJPdS)YZcH2p)coSoZ6JpkJ3OY5Bv)T4Gnquh56PWGafkmTnN8bBco3zu1iQRn8urqtZ7HAvL9y5PxyJMmVu1uYDjQKgtF0LvRc82M7iLwbJJ4bNNHaUp)S4B1E4XLNNICXATDNJNVFMmuA(5oUCBlhK)m5ogseTJ4mqwMWFo5cPn)8B74jTLvjCTvpTLEeX4l7yAmfAikxKSwxxraGnairpK2cqOevoYDtP8vJHg9hV5wAg10LHMiqND6OXOHjw5IG7tn9kWQoT(G6(K3TSBvEUCSfH4uEANyKeRJ4hea8GBkZCfpIMFof7Z05D9qPtWfZn4w(PttzvpIkyFMnVG0PVQMhXCxbXPbMbiBvwthYZclyvvnzE6k1GBCTxud1zhQPgaQxlfxvCa3lwjBX9h8Rq)AV3lfnaLj20JCBUcZWpJL9mu3evNDFzFz5vKhl26J871NSbR)L)EawtSH)ayPpoIBLc(EjHkx)eT9z8WrT)qjreEPdh(5(Tb5kvd0aWwRu4xy4(0rj2)qooHX3CaIC8(SQCwxmE4ZBe8cNqQhu1fyJU(9A9)zTJ7jXlE54H6VwDaIhluvXQXJpV3bnTq94Jv)Glp80N3073)7pSL5z)(1G54xQqcNKEA95VeK0)AqrvSXJEYeqo9pBiVdQHw)lw0NNLVz6ZpZbAvnmuteZEqQMtzhWUKv0aS1lquhHOHpsgG1rgK6iS3bS9C7q0WltdW6Wh0UcBLdUMGTMNVDeIA(3BaslE(3rywlUUA0ah1L7Rf4V9u5x(eJXp1W)v7DPehqChumYH7RTdx92UYaS26iRoc1knqHbyT2CfDeUgnDHbKD0sg)zc7)t7Wwp9oga2wQH6iun6ljt6S9UwQJWEhX4HNS3fmCbsvLtnzFnROAxb4oZ86cW7fomxaFxxWCeL1USG5aKB)cMdaU30M7Aa2vARdh03EcHdVN3Ea6WoPSQRMsbgLPTRGRAfvnaQ9YT2vqRvKvd4AP8RDfO7fhPh6WEJTS5AmcnLW3Uom7GZzob5(WJ9Hom8Sxc1Ye41YSJ9kp2R5rPNRkooE8Ot6zg)(ijQVNhlRdLAMp6PX8GjyRrq7CL56D4HIkN9DN(CxfsR)LdF8XdAa)E8XgkC2LNkg0gkyMT8a1xsy2IjZXF9nzkx8CywBNIL9PbOoSuUN1v6Ay2bDLob5(qx5iN271QuwnB(wQZwxbC9cOzA7Zzf2QneosKKrTKEMPhgwR0uBaVMAPdQly84Jh2urWUuVayLYToqiHKNLYEjEszjVe)HAL7QxtL66IXN3VNzc)hkjw)74SBiQ3YAUCtsXRXCiA2NTrP0TMEkXjKd)uVsyAoNfgYMNR4ctRC0yv7LQ6SXUpaYRZ)Ta08t4(hAcZlFL9lW3bSgEwM4MfQjmV6RT)hKDygqvtQjCx(c7taVd4l2GanHUINVhb7MJSbzdwfKMgNIzZCrkOzOif9oogm8MgFFMLbQdFsvlgog8rDry1XlTVhaxeUoaAxcSwFL9lW3bSUjbvNV2(Fq2HzGDHwlVW(eW7a(AvST(Z3JGDZr2oiABoqD4tQm41C)vPkQSf5fhyKw09y7DEsb)tgG)cH31Cx31jtyVdBc(F33zBdniF64tE8XME(39Dnb7XNOYkWwIC7eU1gQPOS1IYsjg1(sM93PchX(g8pza(leE3oN8OAmlwG)EJt2cSBItUBi3oHBTHAkkBTMmqP8b0U76UJXIAOMF7kCjnoKopWNTpMn96DFqRE1LzFKQ9ovaFTsAO483eYyBVD3hYUtgB917(G2cz0(7ub81Ahd9vjQ0s3FhlmzAg8VH2xNS8wDFiU)UGSeErMcaYEAeM43G5wn82YRxzqRvAhDYwRZlxVv3hIUpVA91RmO1QQ0oQW)jg8DaW4oMCGx0dt9tYAc4UEVoI)DDyqdft3CW35GFBo669Wa4kqexGEBD69jg8DaWDBj1971r8VRdZwX5SbjrD74C2GbOJCo1lcHZihC5i2Jp62fTM9rZLKk2d6do)5oKfGNAzaZEiAE)(xEyZX34Af2Ceh26ioumIsY)FI0TJ)tNUD8taDtXro0vNHV)QR3qhndSQhhmGCzVpSHaKxBkdOv9wdURG6jPjH2(jSZMUAZNW73UIIk(2I4WW47dOtHiG1e3sVSY7Rp1zpeF)nU(wCZqsBBD57rNXNl4NyxLVTVp(Y(E5EZ8Yy)W6FHFKZKgK7OQFEXOl)Bq9(CTZs2h9vKdyVdnjPRcWVp68S9p26qTYEPjhCb7TVNmCaXDQdvCsb2tTG6xk4V9uzxAX299i2FABUITUVzDHHvo2kmXYkpCdH8NId9YTjKv(axq0rZCUdutxqC3N9oG8om7DU7b2T9)IRogFVO)2vFJVxmL5QhY3BAAC5e2USi6qQq0gsgWt2CsUaMJgqwE5LyUMjVttCaoxnE7o0JEw9hs40)gEof4AJ8U5UA6QD(21nnZtfCDLM963KDkOBjoXYx5je4Tc263PB1aR1xPt482b8wbRZe57C4u)D3FATr3DvaADs1(Q8(f4DaSya)YVZcinE8tiU(Kc8wbB3tTyNYG5UpmnMbt3GF7sW7tm4Dd4D2Vq3f0Qv2K2vFTFbEhaBJcJ1E8tiU(Kc8wbB3RquNeg39HPrHr3GVDPLougW9n4Dd4Dwy0DvyBLnPDdc7xG3bWUdwg3V46tkWBfSD3KvNeg39HPrHr3GVDPLoyzCFdE3aENfg7qrG3aD2pPaVdGDhSmUFX1NuG3ky7UjRojmU7dZwvO9T101tm4Dd4DwySEkb3jL2pTqVb4U7ec37iNwr12Lg3ZqVb4UdecRPABb2nG7Es22HJUP1)YptyecUxxTwR4WEZeqLWIa8InJ)OSbQnj5ZhFSSrbocpJAhliQYEO4i6QqBCvT5vBdMhF0YtfBciRp7tLBXgRp)o(jWOLNGfaw)bTTrow)lDFcpY6e2whJvIb131twFM1jS5U3X6tQoHBFNRS(x(pWdE750Pd893fq3ZR8VMZrL4fKkpAGlV7ypIUTlwW43xkRcIkW75c606Fy5Vla0grv5nDYrXjJZy5bleu3H8)7uwygB8jdo)i1Tn7423(ewCgBF1q8wa94t6VjZ3r788Twt2BXE3(A(Ab008fyIUolpavGLr38)QL(BPjY6BN9aDQTNayp26h87xkbS4Nl10Fs8Da)LFWNcORdb8lPNjhrTxhN545)oDbGGVpO(62FYJJdk5p8EqWpyraYUEO4Uzdp2Rho48p3NZMVKFDtWVvIX3ljnigKLEG)ynqjNzWaX1TBBuYUJFLAHhj9C15WV4Lv5TlhHGO5PmVmK0Hgi8zIFfgI3q9hdE62lMuLJXc5PBVNMil)4Xpov(tu3YGCyszyjnh1Z3DU0HGLKOcVWAA3BOn(n076mR7gVx1(MFtqYr2rYg3Rbg6k7asAP5(3eKC4u2NNhw4ZSrknB9DdsJZUvFtqGroqaR9EVX0EVGas(EtDEJ015nutJ3tu)AAtnz5ZSguKrpuAZwFhBDtB2KkFwxgCBEw1uxCskPFVx0hjt0IBEq6obKUqnOBaa6W5VdlL63oBslwdor)8WMgTFx8rcDvaFvexDk2DcWWDhqbiRbcSjt8IfjW4spaVIcWM87nXxpG6OV3LgVcucIQLzz8RIWZYyZXBzr2k8Y1j4JmHTHS7zGA6Ky0yc1)Gb5pdThrx(8a4jvTbO9JmaLwG3y1Wa8tsCs7(ZHFDC(s59nEg3IZm2YaSxSXj0mg)gjXdVEFY6MU1kx1MEXSJ8zl8kcZhFgkzKYazJ9mvCYh2CellxHxdprdXAhmi7jEyHcAjcNMei4tuS9br4D4dVFDaTjlkWluHPNOy3V8eA2)3qRAtiI7eEtedCdQUiE9T)gGPfahSDeIL67brcXwndC9LDuWIXY2UOwdjBhcQUTv7Bv)TEhw9GUP8GVrRnyD4nO(92bc7dmbU6YkId7E1Hmghh59oDl2MGw65RYC3cORnlpK)1BgDNOH8mtMqC5RIZipGalISprxmueltCclIX5XWVJGW90JF77FXLV7QxC5KjV4Y0ydkgmDGrh(jCIqAK0CIeph8pqTQB2Is4j8tTJDU(p(iEvf3RYTZ6fNEUH4aiwcygd5R4(DYfnW73wqYwHbRPBum0lY7Jt5xaECYbQKyL3NdwvScLGZb9fY(jw)RN7xEpKLwkLbAvcwckria(JOigBXcYXoM0t4b6uOQchgxcVMchA0p50))6q1tTFbA(IZ6R)swoxKG3aiH)h4T)ck7b(SlepbXiU1GFwihMjU3KUJ9WZioOp5feYP6G8jnL1iremlNPcjBLSpYrWN1vf2DXTq)n2kwQxiePAQhE(qrNjDW4Yp67UC8P90UwDb3HpD40rjZbbqRZFaQnXccmOoGMTocsAkTiritTYtzZbpG)czE(iT8oVKKh05a(xfG5XJWDCr8If4ffj4LdPvHUIIfNvFODvCEci(8C9V28EcQItvz6VzAru9xenWG3TMZZ5JQPq3PTcHSCHcN38pUUAoJ()HHcHcz4)dpcx5rOHrRWV5U43gxKqKmYiWfNqude)s76EWHWCu6ddre0lZWh9psW)cpSfCLQ8c)cL2ilGEIO2wggpdzJ5db3Ui)dHhUiLH86xvQigigWS0Gr4O5pmpKnLVCKXPs2eilsiQG4cnuPVwDhu(MjV53mhQkMrO1zvF)ja3p5HxDFC3W4xktvU0Mq920KdN63dK4kjRYYGy5mCRxZxIx480XPhk418b1Y2P9Cgiu1Cj4Tq)EYtXsG9sCqUzE9zQSYzGu9CkUk1ho(L9lVp)uJFVMuHow50AZhFCVSxlQAVy4O(9oWX1mPXQI2nzMMpegBEbjDVST47DO4pPT5bAKIFbENh2O6)lEPgaCmXEzvDHIlS8snH1At3(WQCJd6Wt61MLl4DE8X6JAVonMA0xfZhcVdQrs73R(TbpWzoYU3gJ63V2szP96s92DcyCFzPB5WC8(7Ks5eLIvYhgkufup5Y0yZbT6DETlBMvvNFX4tF(PFV04vLnfHBtKCZA8lnU3fGQzLxfJVG0PUCPkRtzykPowCD9J60X7RFnnwOsQ3ob9NeOob)b5T4pak01US5q3lePItCn8ltzf)24(1zpNNhlqDrCbSYt)OVyVVYVri5XLD6j10eA3w5Izi1ZQMmvuZg(LDP6bMrRvYGP2nhoUErBsL0L4jv5HCpE4ohrKwLGHA41J4(XhvZHYEB388U8uqiHaRyvAkFrQnixN3QpQjQoN(RDWOdkLfEiJEXOXHPXDDTGJemRHQb(3ggmxINL8k68CBdZcS030l4KBT3xnSy7e7uvZhACuV9k(cEKmiy6wrg9xI(llJ5fDiMFXGVim(E19V7GwmyBZrk5N6Zwempi)Yt5EesoeIEQXdeftsKFmll6z56J71xDK2fvoTnGWmlrEnhHHsUf(PAX3kkqPlS8a110VMkmTTKK5OZt)aoinFR7xMmed8vDmK78owTFZC9JELHLjH)2YObYqpXdex07YBn7M8n2LtUnJfoksMY9lYHxho5Q8dEu7arOeUsacgCOA(c5KBOHZ1DNowr05FJUI2f3s58F5Sp8C5pEk(JOOwsO3der)3vkiKVdpYRHNx7UA3yEGxg82WFZytpBB)Wt7vtjwxbfpy863tcqGnNRXoI3UU8PR4iQgS1qCty(xrc1piubPixITp2rQFIh2CrYrvt38zO5iAECe3ovMm9NA5Su8P10Hvj7IwMDkzvboy5C3U2Iqlh52lN7JQw(EzKEwoYhqjD6z1poVpWQGJur7fsfUWa8IHe5))ngt8HVmFD6mXsE3fuTcM8Hns8HUi5H)B1BC(XD4cN3MB5D9cF4ieHK3b)JTDf8Bb6B(nTpU03X31kpUIJLNNfHgkEMpeEUbM1WOC()kcMtv2geA0sssn9YTXOknPigQEgSPLLi4n898iyGabfVC5VlalXB38DJUPT1gXk7Hsb7P5niEpl(gqy07GHygDX9VWkk49hfPO(40GpwBwlsYMHpYhrhqgycgXc4HPVhMIjjHbZf5chCTracnLbmmzEvDA6iH7uGNxi3EB6qDEt6(L5g011vOBxV6CDFL5UjxvUDMapQle4rpFKRq1DrIhnORuyJ1IoJ5N2fmVPKmyFvY1eA8Pdg1XPKXCVZZOZCiOPNQJQszG8vACcedtEfbmmj1q8IhZNH6IBlMj80ug(qBYAhUNLHQXdJZYUGDDGrfDD1j(U1mK97g(zLD0bpMtKC7zY6iw6If7VLsvwCccWm5jDeXqLgWt6HH1l1OrwLq2Ar1WMHDxa4vtTxWOs3Ibglf8BMZ9u8VJM6KnbHO0mv7mcaN5DuXmggN2bLJsgwXA0DKGC2kU9YpEh2(pHSpZJGkaCydSMcbVVdfFWHRjVKMl)3I)cmtq37au)dy3Qar)fKIL(r403kEMEIyLTwD(9mpEDFRmF4T3a91U9l6ItlD7L7AKIh5uH5)spMQaE6pxVAFogMr1aw3lXuwTgvGtP3NvyQ(ySLRXUI9(BfyAZlWeTO8T6l9x46lH9ral07ZOYQYURh8(pkh7sT3Z3Ki0f33rOSBeLlHuwiMyvQ)D8Oo2)Uau2MF1mdgyIOgqic4xqnJQoPe0CC4vHXX(HfOsGNxRTpo(3PMJd7bAS)fq3RaRcEP9RNT9))T312YjUrq0VL8qiOD9YIKXj(bJRA9cBI3hsLk4k5nBKn4yQaixGyVu1w8TNP7EUFtsymjBQT8tgKgntRZ0tpN(mnnKT9JZ2n62jiU0YGbnffo0RAmyV9og80QHGN2ueyJWsis6kiZIKefzbsOZiUK8jiujYDpgSe9gXGnVHx8oGVjMR5vFCMmFLdh1X6DIBAj96b3DrIQSLvyi1ZasatDSMVL3DfsZeV6Hva)8JkbPMquXZmfdkK83Fx(JcMqEdYy(2X)bwfVSSn2e2lJ0F)WqFIUG6SSbyYMCn6bKYKIZERFLW1ZsmVUnXEZLubf5PNOn5ZJXNsZJND5xjZIuK6MyoCyjVtRVtRpXJSY5MtugfRrVHb2mj58(VBJzbbmv7N2paR3C38CwqHCb)123VFRkLFA(tTF0FpxpR)pXhOn9h0vTOg0B4TV)LYDhZZGlfJDh2YgOItZxrvHvN00coumITCWV35jVcYoMVw8TXZTEawx6roaISb1KSJgWHz8P7ENzhEIT3NqJYjBRaWw5qYfVZEUXtFyCDd4OyG)FHeJSa6(aj2Sqp2FW2aGQ9dEYDivPwb(ZCiL8yAkE3fVE4iXz3aJJEYNP38QSjNVeddA74F(TdaXJJ6wLTpSnZl3Qk90eMzzbGjxskyzgNhf2Wtd4zHe(iRZCelAT(Xw8ZiHe83M(sfuikV4jL7LEFR9cFlLHBspqZ9Q4lU3ShsLMd)r39SArQEG7VtDEth6kYDqme5xjL8QKHaU1sydgkkLhP1eID6NMvkcendcz32lJ9HlPb2hFbQkJh9vHIIn5fC7QBc6m6ygj(6G2XS6inxvltx(38tckChI)tDDmFWFaO5RtAhD3PF5lAFH4ycj)OmRRvsPD(sn2XCYmvAIMptTtee130F7BVk7ZUkD4WAzMI5mwk17eFFuKujyotTLRty8Rcu1qre4cYItHMpMnfSLnBXIzlHLHMmLHI3GTIKOUGMoze9A8Vjx)1GOUeDJ4JOAAGfLyDd(kk3Z8)uaNrCOPj9FqGd1HucOUb()SUocWb9LKDL14h1admvWlFJHOSfVwpkKPF)SUwsfKHoWX1aO7YjQFiiJcwNc0rbNQc2daicdxGwbngZmrS3cit5SRFoWhr(9yuxsL(r)lNgmaRBC(nPYVcEo2UDtzjmUTragsczNLaItQN0E1BQZZKMiAJQ0gstESnx0ib3wj2uSRaJDT2TwBbN9F)XVmOx7Ztv(cnJjmYwGpxKdGMUdyL48hW8eO09onzbsk8skQ(8jtwl2laDGFfAqCw5paFOwSK8d9KGGnAWaW7lh4G(Q2)JZ8jMDuZKdDmWC3pLn3ty40y2NfAS3l)h72YZfBtMrn6F7D)JQpYXb52Xnr0pr221tqZpbhkc7PR838Pwi(NzjOjLSRS276rav9IGcvByLIe8Yvq9p5olnn7D9uVmesErMPAf2w0MiNBn9ttVBdoPFHwCkuanqBdBxuSpq92425BMQM3PlWWalIhNlWtsSvHoML9XMIUIC9ZZx87TY7REmO88KtZ9zpQf3oJYDITsSfNZsN8GprDx3mVOybqQmSi5FbD8Bq9a4Meyi0pHHTBNtI)yCK(a(CbBC(C8rXwnQ8H13qfKKN4dJoPNgv3evcLvF8QPWkQ817t9T)RVZ(wyTua)VTABYiqkk7)2E4EYue2sIPBzGgTVNEDJh4ApEbm6xXA)cxsTOenKh3u5DPwkqloRF7sESxd)a6m6xik4oc3Ch)CaOAuCrfmldYaZgsQ7y74RWd7ChAw(BkgAFVQZ)ANA8AmyXSrlHeXpL1zQkSIv1COLpshRi)Xhxbr)1j1DvL9OtRmZ6Ngk1ASTgfC0A6Z5mqluEPDL9X(oj5G4cRW0yVa)XEjFLnbaXQxilNr2qlGQk38(ry7JSXt84MLi)7vxaCRm3)aZOCOiQmo(DWjgd)irbPPgiYqvHjeq6TY8Wh4m7AOk6tI3c9wK7Jx8GC0khZ4Q1w1)3xc2Zast)JpYmxbVRe)10cX7ZR0Q9zI1ZrMHWYrgSgVOOsmHxr1osehkeYj92efHf3veu2(GpZUW9bvTm(BNTuXbrbD6zUDrlVsAHblHvtk2GQpgmOB1QDBKFVcibPoGTrJEnKB6Cj5xu96GWUaEBLSxRk(pXXwRNxukQecPbOvQDTC41ZBzLawnkybLA3Q4e1aY0k80bOdTJp3aJph3pitrR0RZvIMvVMG5oxWXojk3x9t9wvU4fJm2Um9mrLQNB6vbnVvgRZ7BmRs)6vED5x7zWEEAhmRkzD9DynbJHVqMJmytQpKn7qbztpyqwxpXhyiBAaiRVLic)wmZZxMgdYM5azduj5ccz9uv6oqq2Sgaz)Mx29pK9RmVSTGWz(VHR2iJQ6dP)Mx49pK(RmVWwq6)nDfhzuHBy4Y7fuaIrzdrpRVzmv9qgpRhWtxC2MWyU57FdUn5yKc9MseZm67RU1UTqquUQDQ9uo6u8eCcYoVFWg)(zV5)iyVAx3K6EzWiqoxpkFt5dfRUE0OzlE71LS)U(Fc]] )