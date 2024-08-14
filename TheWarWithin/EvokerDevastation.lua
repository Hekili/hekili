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
    titanic_wrath                   = { 93272, 386272, 1 }, -- Essence Burst increases the damage of affected spells by 8.0%.
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
        local partial = min( 0.99, ( query_time - lastEssenceTick ) * essence.regen )
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

            if talent.animosity.enabled and buff.dragonrage.up then buff.dragonrage.expires = min( buff.dragonrage.applied + class.auras.dragonrage.duration + 20, buff.dragonrage.expires + 5 ) end
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
            if talent.animosity.enabled and buff.dragonrage.up then buff.dragonrage.expires = min( buff.dragonrage.applied + class.auras.dragonrage.duration + 20, buff.dragonrage.expires + 5 ) end
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


spec:RegisterPack( "Devastation", 20240807, [[Hekili:S336YTTXsc)SOARqlgltjcjz7nFIAlRy5e76S5KY0NS1(hrbsoKeRbbWba0YkLk(S)1DpxWGbZaaEr2oPCT7XrsaONE6PV39mZn9V5d3mCQFo7MFZ7eVZo5LN8IE9FX5EN98BgMFFc7MHj(t(O)C4hI8xc)7RzFYpl3ppiocF29HX(tryKfVkDc88f55jz)0XhppiFXQX9MeV84SGLRcPVysQ)SC83NC84W4XhNVGDNF6DWRgeDmlAEqe74jH(zzJwgpDvil7y)Kq8)nI9P4pYs7njj5MHJxfeM)2OBgBfZp9LaYKWMCZV1)SN)caHcMoLXFzw2KBgIV8Zo5fpZ7f)06B)xjieYwF7S04LRVDyWYFE97w)o17Ck8oFybB9T)p(PW)qi6ndddYYZWjnd)3FJOHSi)XHSP3C1nd9NWPoSCwAuq(9JYwLIeq2YK47yPJYJVzy)Bgo5(jHSr5(WZaO9B4Fjna(KaFoi(eBelITmarVlgS(2(RV9PRVn3pKfL3tc7Srzj(r9eJ(6BF4H13oE1Sz9MM6ppoc(hwVu2s)Giekaq69IZxF7pU(wGefgoAbSwcZUo18rxYhAZpX2aTkHa1HRV1e)byCo9SduZGzXr5JINnAP)8GjLNaMF9LempvF(74R7si6HTKy1L()ToIac)Cde2ou4SvPbj818RfVeWlHl6hT(2vza1k1p6JRVDzCwomwjjHbtWpgaDmcEIdO3n5aN8wWk5T5SsEe1XJiw7idLxVTHFYcxio9pDlM(NU5tFoN0PTD63kEw30iCa75TfujlKwKiDMbrsNyCMBAwfIuo8)nC2460GnliLnACkZpFXgP(6WVqkHCi9IVSHC5BGzY6BVIMkLfkbXX04eaTZljpU(2jXRIYpMVYxV0PtY0gkAYLmXzudeW9MqhqcRtUZ5eRbHUwjXu7CCFk0iMKTuUP0C2UqZu2m)vH51j5KeZ)VLycFnl0hSmapB9TbrGjIpa)3zRV9(4vaFiYG6poEvoNnC4W13(mUnJq4JszHGNxrWdNfdUIeNaCnW)9Ufm87iiCh94x)(ND5BU6zxoC4ZUmnw6PwXAJBJ2hG88XHtJVlQx2c)C8dIMpc82lLElxgk9ucIJJZYiOnly(I8r6SSNEUnjOyWDUmwEbD7t(ascpf)PWvOAljgzLn5)IqC17uwNxX7b0XZiK08d0wSR82glE)HaZGvhG2S(wgIGCNhHfby1mI9z4pxGMWAl8SXWA3DXPFeOKWQgT4I(tU0)ZGxXGlNJz53XWpN(Z6F9eqoXpAkT4cR0c21mq7vW8O4ucG)8RFp8KzZytqmklpyjIr9i64iUd7iAnQaU2e3lyo4C69MYiUKjG0dmmaLbwEUziO0eeLNnA(KPK8UCn7FVce1mOwVFvIGpEP)hzIzxQFW0qM)uKXDbO39EBILsOoXhKF5)Yi0HBUB3Ijvom9)iksca4CNZgBmRGMRm4RH5J(uiDvKZXYpMiAp3bEw3NMLZvyKKYGaHg7BvLrZYaIzBV8(9afAJW1bC9HlZ9v(Hbz9wgKMgNIA5NLcZHvPSPGs1LXWF9UmDwrXNnQpbQSTtHGAS9QdX(68WTHy4vqmmLlfeJGz6m1scspdQPulU2AtHUZvPKDG13(dAk)00Ow8cGiYj85v9V3p00iXbKPw0xZMemLHQmdMSqbcUMIe)a0IgeKnyftnMG(oq8zgQZam0SmiAfArNum2V43vkeSYULDF0eNSuJyHzWpFsVZv8y9TPysB1WgKQUUYh1Aw58CSY59fBLZ6iPw5QL8yQ2DdKCjTgJzHGqb8pzJaJdGf7iuJpUmxvdt09lxXa5oyQ8jwi5ussq00qMTxol5(LOBFPzJUJn2m(CPnsGfQGRz9TekYTwdAQt85MxjRwskey(EM4pj(oG1CAWNa(5P8VKBcxrhvVoxxrqoYjhJVFwV13(R(CCiikhmFsgWxgpnywascoCYkG2erE(1V35FUlxczoyoJ(OfG)v47bXTaEcGPBaFSgOKZSEI8xzDuYweVkeXDCwUWpAoorq0s7TlgHGOjGJaziPd9aDkt8RWq8k0ji4l4FTV(yqERIo56RjTFxa(UXPYFkc9igfxKI)sAEzxzkeOx6hTYp0Mz5nGn0Bdyd92e2qpBSH20qumnEX2pniM(0vJVFe4hAyYOSf0krvbdqNleveYzpcwl9tJa5GrbteqVcnM95jHRMs((8YTh78Ab25TXyNNo29FUBkQLC4gbWwRDw3QYXjwtk6Bux)XLEb8Bhv8WICCIH6(0A8or9MwqiU0gpdOxwbRSAr)4sVqRXkthiDJv91WQYwF6RyS8Wv8(NSXmK97DsLKPzeYcLoO(QiTeVlOmYhtBly3Oe7tA)r4dgr)DeNS5xFkZjwjHZ0uGdKLqWzegRHk9cywjCeckPvLh2jQ4hdrhqXfWsgz3sgRO4fxLa20OhGHlIzE4vXx3Jc09nuDpwIgqyuWEqSVzmyniJXwcFFyGk6Tmio18SKy0S3ymq2G8NGwozP3t(HrgfcWv4maLMHfmbgGFvIteMa(bZdGoIYVomsXrtZ42ghZMtHFJtOXy8sCtDGMzE236BlwHnLaNPL(MHaB0JfbE4h44Sdx6BtcpcIWAEnINKQGOzRYWymprtGeKBprFMIYzq0(mq3z4OKacbCfEnSSn1pkFeB5yioftzHFbTspKwcGaXtdXF9vt9tYfJ8Vde0vyq)6PoGs4xg)1h5REBvLsq0XDW6YeggalP5XPllswOk7uYC1hnFv4mx5ONS1aZky1rRspLZVhnae(y6(G1CywfLiZx2XMo1HjfOri44iyQBwOpP(iNNNHAYOOrg5QpbS2IayvIXI8R(NxZtOhUIIzT4i0zrmPv4)7JbyiwXCp3wYWe75p3h5TPyVK(ocE0gIEPI(qMYUdWGCuObDIgydy4J(Nj4FH7yhI64lpJueGslK4LVWV25HXJ9dLdbxOJ)H(ynAzWBD9vnLkE(QB556qahMI5Lu8ycXNaZPxn8v)EL0JMf5NGVksZAi942gSF1pDQ0SrCescIxLNrX9I0tmZU0eeN(3bKzkZaL48CKKwrE5myfgj(Z8Guk4)MXWCpao1smzzMcuLKP0gRsm51M(vQQcNq2R5Ge4syrtyImTPvymXdapasZYvjtwQYWixZ64PZesxQubpxLb6AMoDAy2GaszrV8RBnnXxilrCJPFgl5LNKmDGAzmiAuHQfoNMP26kQhHigyRaD3(JdcHrYMANLSqq9BkyQ1Cfx8cXr3)5rHS5(tUFdwSf1nwX70gItjGwd155Ak5bRJJghhTkRx(D31F0zjtm1WVeBqKPbzyuQZbBHmZk63PDiiY62PDfqq82iEyd)6S142ug4zIjUDzXODqTlRDfdnL0EY)M8yy0LcGEnxvgpP32sDAAiu9jxFxg1t0gVsvMWvs2Zds4HNdbNZYmu3(VWI5cVb3wcv7wEjAipwrZwZtJBxjWmRyW21Taw58WbPRTq9lnx(zYOHE1QjVObvEZNRsNsgMRLJhh6)NKpNGQXu0jALrg0UYRhIfjewDc(tYlSFcSdtMI4MLWmYiYXKyfsMlMq65Vm7P8e0aQTX6GZOFKCvhDwGChG7g)PNKvxrBMO3uanBVrftOrzRiHc1dnJzYuwXpkyzCwj9J6ghGL40CW2i5AD7nqCjVlM6QPeK4K4EOtlkL0yOqx9qf5ysjAXNIXUJRI6CtEroROslcn0cEGrCwG2o624)7wyKWUC9lBHyTYmSi(iS4HLQNUwTXMn2wMLSimy0sv)TrEW2Qqz2yxcj7h(ybFy9VATcDD(lQmWJgVUzpxPXUZYSLQsBwDTjd86R4SOrYwhbzPPyiO)Y8yE5kaZFXapXSW47uoJ3RDHwiF7PSzbtW0XCjwRCB5ABRci1suaWhn5JeX0Ydx6)5rIxWq1E6eWf4rFkyEHJqMX6rH6HrzXtGdoBMgZYIEsUo956RoIhCj1vgearV7OOEJWwRWAw9kMstJZ1vUnAQ)sKEMhmH3ShDmyXDgMdobRpYUcf0nky79IIviEQjSM7SMcHTWper4YYq2ZWaPP5h8iEtFNzlno1h7zZtJAkLzPqskf)znXAwk0uVnd4kBMg5fOs29uIZAbaurkOsicCg9mPKytrsyTR0CNOVK7tz1lBAQKfPqMPE(3Vhx8dJNhaH7W)LZ(WtL)4P4pI6Nsc9VNyo(dL(C57WtJt)ZjJ3W0LNlKF(kRPf0a5RVJE0PAvTJ4GC5ksdZrKwYMSa)4PJgJodivCrz)4ChG30jFRP9RPEOTq3bWlhbQPkRZGB9t8K6AqVZkR6WE8WW7nFYuuXlfPJE2BSKt3cns0BeY8tuZlfN8boLi7OjqErHXhAWFw1U3LRn6F8gjxKy4adZ04HjGh5)(jH5qfxOG4CK6N4P2CvYrLlfXzOZCeb7iUxEzYKE7RL0B(NYZRVPFRahcUZqmr8)3ySYwtxlAnanPzLWKyNN8bBCd4BNMUkjFewmtXEGbRK2KWGeKc0PQ18oObOSlh415qSF7gX(ePnbS7Te)HGOl9E4b6ZwG2cHVaI(Nbt37hrtcZHs7r4aQGULrEdgWc(C7Fd5)HNgpO8BDOKfxtC5Cv7L5KwQLQ51TAziT1ahQIFJNjBba5zDwe1c44bM4I)VvbtOURauROLGAE3Xz67v1I08QOjbuqlVbNE8gW4nbyhm0UOqurmtGHtKknVLcXLFddjCJYmO5378uglIMlUkSH)FUkfTbMg8rZYq9gaXhtkBNjMs2BiBz3Uux9tMck8wooiAkeNsyC8sSf9qhuMJkchrWTAlUkRGyl(0cskQgvpckQ1PQMXQxxavDpoD5PwqAWu)qACbrY8fzJ4TxInoA7tJAGqT4EnvaXSjxmSBQ9yiYX4uLTZbuH274mAejFvz4RmY5obEvJuRVwOAhwtmD2C6uuBVYoMzPGFwG1zN0o)1pJ3QDI(fUm50sbbkXg9Bu)ijmmLrDHMSWAPfjoBvep9e0EeybvPTF)Tcftx)js3XVgNg8NXrhr2PermvauK3eufpuZTTRxYs9XY)9HuF0W96BFlVRcm)2Ik91tojD2fvgE)WDDGpqJYPXH7PmgPTMpy8IsOc13Oi4Lw5Wz7Of8j7gw6JtRe6IRYkCMjtuUZAkC2MuUIxwMHQgW(Y2uzav4P1s5SLqCpZyYRHUwUGobS0t7pYlr15rBaP3HR)1MNgsMUqBLBoplv6OKK2vQUe0uW4NFTwMzuoEYLmpYuAWFwoQSxj3oR4fWpLnThMvsHGeTh1eFrCo1UN0Fs2yvs5jxDWOH40HL7WlT(otrVelyUBFTIeNzPrXAem91aJTqve8wvLiCUUvzmz)7vGJXaDSMw1SGZRT8noPW1vXk(Kgm(MfgNR)71Nb4oLkTqlu)XdUZPqMWSxTTKyDLSQtZ7lSoTM03PbgWU6zgE3rPAjko0N0vtZOrJvkhrrs4BssQcjVOvQ5U)y9LuD2QevSljX7CydmPstzIZjdEBJpOq5R6JOgQqvA8AliNxLQuBRKf6KuBS8TIyzUrs(GwF4ld6IcYMAnEmym52HBQO7(pswrhSvL46JboRmzmA4Upb)BM7)eSd6fHxSMVjnlu(Fw5Kzz4v0rf(EPmmmnE1yusaPdR12hbC)UIJywmxmC4XV5kbwstr(onKB9bTyKQW6I270wLMn0n59TIUO(FT1fzZk23Q6I6xNUixMJRx8YZXl1Vn6I8SRlQsBR3KUiRnc)3G6I8iDrLmQ7zRs2vDe4BdHTVB4Fde2(BKH)os)D)lRhansvQ4RDnvC)72a)UnWVfSbAxS8VsgdBKQyZAPZUkPWCP74MTRdOq(z)LNJ9grUE1wLIS5TZu7AamCaCLxpVpfBIyAtrGyS8anIcoqKQi8ZuZCEmcuAQyb8N3m0ghJHuucow7iM60OwlvUZ(jvsFbwPQHtoNoLpSu3PYTK0hGGYMWfJ)h8DAdF3Zj2BnL3sDZz58TI3ygQj9azM((4cCBXgY(mVZAWGxhfIQtUPvT4vl39i1uq2NxSA7gxSudRMR27fY84FqL6966yNHEdd68)TaMavgRUoUHMOo(dS4LIQNf1CFjVbpJy4YEgTn3YVJ5Z7Blo8ZaB6pDWX8nni91hfmBGD0)It7OyD54TGb(YbN25GYtNTy7eTt7DjxTf0337sFFVl1PDLtQL7DPg3ANFFVlT57pOVV3L2(9UKRsZuWHyO779Sq)pJ4ME5ZVokh3G7VhJNkL04JwRN4hrv8lfIOcga6a6ZNorJweGkqX6OIQjxXBVJiqmbT)GB39aY8cqkVkmoEA4kutl2jL8ZCG3k2O3h)h0(QhZMnw1E6ymCoZpT7oVvgo1BZ2ldLQIyJmMBw1V)ki58YnrW5L7l5MDIpV2C5x3oJ7d4MIJFilS(23CLTkvJhqNCt70r0jNXOuR8E9vV5iryf3fO2QDxpSNZUv1LbzBEg0(fUgxVePQOX37IMgmn3qCEmt3TUC(wzRryu6QuC)hG7GszvCac8RJv7pHj(jYk68kA7oS(2)G2Vdw7qMhPnvr50d4IOkDhQMmiummo6tKog(ZLRsuLr3ikGwbUu0Ew2nq5YVVZnuszLlqFJa5mXGnW1oqRPQ7iGtzjwfzsbjJNxbZ7uqTTaQUMeDNutRlVM52tn7Tnu2YVAZhWjLwRhJhlMPtjZQLxOL8mKHuS37brQqdMbHZOLasjI)lkrUQDNx4ubLfpzTH16helApF0KqFicwR58AdvFwBkoup044UPIOE1TgRIrGtm34TtxJQ2BN(Jgvs0cE6Auf1TisIDCt)zQVYnpSIGvLHqHRnTnYec0U2rTU7X7k712kzURKvPkBZwkxj9ahtPdTA)uWvryAvzx2I(kukfbV(992zFuFe2UTFvfX2vNiFCLpBqI4lHGGnItvo)g3FTv2NJLyX)F8XUTK28fV5QJVgyr5N1yuWBtVNZwwSbh9Je5s)xWM88o(5DuklBvyoNpKY3oNHokgfyI47j9ar6BbYLMubAxeppyRXJHco57au1620OcRvhNUNy(N1xbvEL8uNSn)ODl)Qm15e8pRj3IqERnFqVX2oUSmj1Uh)FtrvBlHZvWlxU1KoxzcU82JYwMNj(CUI5(C1YEKqrMK1MhgdFp6KXLQyFoq1xEEyqKzTOs71rBThVJwinpRUaI6s0Nk(IRTFUSTnu)wbHDSzPSTpwlq5MCSWu7nl6J8MQUSl2XApX4BbJGFclltV(9kV1gXpu7H840m(ZEw(McKzMFK10)JVvLofq2Eiwmjz90auoV058T53LjW(QUd(B3ok2M4RAVikkBK6mpqKRb(wPfmSvD38BiKuWZVfB43QIq3yDN02IAjDOAjjy5YGi0zcyINNUIOjMbn08kJw8MoQaHYlnhLWWDwODUTu570CBlyj0gMhDgbM0cpjMbMdILZfEtcZLdwRUKqK7UlSA3zL2J9C9ZEFOK6bRfYrFYwxn4OV162IFahb6yVJEOCzw)2A914CtuO2RXnFmmdWDFSSbgy05To5fNINfZEzeWGqfKfE)qmfLI2NwDCPW)vrc6r5816hkTblXnOiDf6mEvEEmD2JxSTUBERyFyvM1hEqgVrPJQNUBXE0wuh5QPWGafkmTnBI7nbNBnQAe11gUbV108EOwvzpwEqSvRjZlv9xzBIkP20hDz5QaVT5osPvWy3Q7C7q7(OaIVRHHhxC0WXfR12Ob(tNMjdLMFekl3bMb5prU5her7iooxLj8NtUqAZBFDlp0GSkHRT6PT0JigFzhtJPqdrXIK166kcaSgajAhUgacLOsp3nLY3mgA0F8MBPXRU71jrGo70U8VMjwXIG7da6sWQkT(GQ(K3USBvCedSfH4uCWnyKeRJ47PzEWnfzUIhrZBtXwMBsBpFTeCXCdUfF6Ouw5DBp7ZSjRiD6lR4rm3vqCAGzaYwL10H84WvSYQMmpOyQXnUMlQH6yq0udakCtlfuOuwJArBbIAFo(YxtDq3VKs3sAdXJK)m5gKIUUgtd4hfGLpjm08Hw0Z2JXts(4LQ(ttvGcZtc9Y4xo9gyj5vx0WNJzsifTKMj2iACNhe(t8ew2tqLSuddmv2Gz(RYJfBhn(DTswV1V7FeGf3R)pbUSehXn3cFVCfpx)ug9j8PR9hk5gGx6W(FUBtqUuznnaS1sE(vgUpEuI9pKJty8g2wKS6Nuwe5Ib9FATGx4nv1OdVaVap)rT7VIkhbpIx8Yb91FTQaepQEkJvdgCENdQBH6Hhk)bxE4PpTU3V7pEydZZUDRaZbpxHeoj906ZFjiP)1GIQyJ9E0eqo9lnK3b1qRFNf95z5BM(8ZCGwLJN2eXShTT5u2bSlyfnaB1kD1siA4SNbyDKkSwc7DaBp3oenCx2aSoCMUTWw5PUjyR4cFlHOwGkgG0simTeMvcqTcnWrbg)wb(Bpv(5pYy8Jn8FXExkXbe3bfJC4(s7WvV)XmaRTwlRLqTuNGyawRDjslHRr3Jyazh9wYxsy)FAh265PYaW2YXvlHQrdwzsNT3(vTe27ig3)K9UGHlqQkbSj7RzPHBla3zMxxaEVWH5c476cMJOS2LfmhGC7xWCaW9M2CxdWUsBD4G(2tiC4982dqh2jLLp2ukWOEZTfCLlnSbqTx342cATQfBaxl1rUTaDV4iDFh2BSLwAJrOUmx32HzhCoZji3hES33HHN9sOwMaVsMDSxc1o1pkDCv60bd8oPJz87EsuFppwwhk1m37XX8GjyRqqBDjg7C4HIsa(dN(uxveS7L9F4HdQb)E4HAQa4LNkg0AQ8NT8a1vsy2IjZXF7nzkw8CywBNIL9XbOoSuUN1v6Ay2bDLob5(qxPNt79AL8RInFlfmSTaUALanT95SuHvgchjsYOOypX0ddRLmRjGxrT0bvfmE4HdRRAExQxjVc5whiKqYZs97epPO2DI)qL621PUA2DXGZ72XmH)9LeR)oo76J6TSMl3Ku8QLgIM9jBukDRONsCQLWpjIeMMZzHHSj5kUW0shxrvEPYoBS7dG8kwFlan)uh)(6W8Ixz)c8DaRHNLjUTxQdZl)A7)bzhMbu1KQd3LVW(eW7a(ID6qDOR457rWU5iBqwVLbPPXPy2mNLcAgwLIEhhdgEtJVlZYa1IpPSfdhdUxBewD8s77bWfHRfG2LaR1xz)c8DaRRtq15RT)hKDygyxO1YlSpb8oGVwfBR(89iy3CKTfI2Mdul(KsdEf3FvQIk61FXH4NfDp2ENhvW)Ob4Vs4Df31DDAX15W6G)p8d22zgYNo4KhEOUN)d)qDWEWjQScSLi3oHBnHAkkBLOSuIrnVKz)DkXrSVb)JgG)kH3nZj7vHzXc83BCYwGDDCYTd52jCRjutrzR0KbkLpG2Dx3Nhwudv)BxIlP2H05HWR9XSUxV9dA5Rtk7JuL3Pe4RusdfN)MqgB6TB)q2EYyJVE7h0giJ2FNsGVs7yOVkrLw6UfSWKrzW)gAFDYYB1(H4Ufbzj8ImfaK90imXVbtSA4THxV0GwP0o6KTgNxUER2peTFE14RxAqRuvPDuH)Jm4BbGXT(zp)O7hnnjRoG769Aj(32HbnumAZbFRd(T(OR3ddGRarCb6T1P3hzW3ca3ULu3VxlX)2omBfNZgKe1TJZzdgGwY5uTieoJCWLJyp8GBx0Q3hnxsQypO378N6qwaEQLbm7(OjD7E5H1hFJRvyZrSFJJyFXikj)FbPBh)fNUD8JaDtXr23vNHV)QRxFhndSQhhmGCrVpSHaKxBkdOv(MCTTG6rPjH2(jSZMUAZNW73UIIk(2S4WW47cOJtjG1e3BYSI7qn1HOeFV4T(wCxDs7)E57rhwPZ4h9yfV90P4lp1p3FSFg7Nw)o(zNtAqUJQ(5hJU8Vb17Z1olzF0xroG9o0KKUka)(OZZ2)yRd1k7LMCWfS3(EYWbe3PouXjfyp1cQFTG)2tLDPfB33JyFX2CfBDFZ6cdlD(ByILLE4gc5pfh6NBtiR4bUGOJM5ChOMUG4Up7Da5Dy27C3dSB7)fxDm(Er)TR(gFVykZvpKV3004YjSDzr0HuHOnKmGNS5KCbmhnGS8wyXCntE5S4aCUA82DOh9S6pKWP)n8CkW1g5DZD10v78TRBAMhl46kn7vVDXuq3sCIfVYJiWBeSvVNTQawRVsRW5Td4ncw33a8Ugo1FVXlp(N42jKDAHOjpC2jG3cWIb8l)olG04XpI46JkWBeSTp1ITkdM7(WuBgmDd(TlbVpYG3nG3z)cDxqRgztAw91(f4TaS1kmw5XpI46JkWBeSTVcrTsyC3hMAfgDd(MLwArza33G3nG3zHr3vHTr2KMniSFbEla7oyzC)IRpQaVrW2EtwTsyC3hMAfgDd(MLwAHLX9n4Dd4DwySffbEd0z)Oc8wa2DWY4(fxFubEJGT9MSALW4UpmBvH23wtxpYG3nG3zHXQPeCNuA)4c9AG7UtiCVJCAevBwACpd9AG7oqiSMQTzy3aU7jzBho6Mw)U3syecUxwUwR4WEZqaBweNEZWHbl)5BgckiMfeQoavZ6P2YKpDWXY2g4i8O3DGGel7OIJOB4TbL1TxUPyE4blpvSLGS(SpvSHBS(8f8ZJrlpblhS(dAABDS(DTFc7zDcBR)XkWGQ7bkRpZ6e2CV8y9jLNWnVpww)U)d88eFcDOhF3Ia66RL)1C(Re)Gu5jECXvI7r0L4Xmg)AGzzq0k867GUec6x87caTruvElOCuCYGmwEWmb1Tp))oIfMXgCsVZpsDj6oO5ntHfxZ2xThVfqp4KUBY81BNNVvA5Elw)2xZxlGMMVat01z5bO6m8aOxBP)wAIS(2X3thg9ja2Jncc)AZsal(XTn9NeFhWFnn4tb0T8a(L0ZKJO2RJZC8yTNUxtW3huMD7V6ZXbL8hE9omnywaYUEO4kNdpnV7378p3LZMpNFlAWVSLX3ljnigKLUN)ynqjNzWaX10BBuYwWVPWWtAFUYD4x8Zk92fJqq0KuMFgs6qZftzIFfgIxrDldEO9lMufJXm5H2VVMil)u)pov(tuVZGCyszyjnh163EU0(GDLOv(Hv0Uxtt9BO31zo4nEVYDr)MGKE2rYA35bg6kBbsAPv)3eKS)i2NNeUAkZgP0Sr4nino7D9nbb8CGaw7eFJP9EbbK89M6880151xtJ3Ju3BAtnzXZSgIKrhvAZwFlBKtB2KkEwBgCBEwvxpDskPFVF0hjt0Ilur6QoKUNqOl2a6ohOflL6x6Cslw9or)0XMgT)q8rcDvaFvexDk2RcWWTaOaK1ab2KjEXvjW4spaV5fWw(7vXx3J6VV3KgVeucIQLzz8ByXZYytWlps2s8odk4JmHTHS7yGA6Ky0yc1nHb5pbThr3P(a4jvTbO9JmaLMHxe3Wa8RsCs7AbIFlJ(C51OEg3IZy28aSZSXj0yg)IwXhV1IYANU1s3GO(XSJMYM5VkmFWzOKrkdKn2ZuXHFyZrSSCfE1)eneRzWGSN4rhkOLiCusGGprX2heHxnr8U3b0MmBfE9km6ef7(LNqZ(FbTQnKiUd5TumWnO6P413(7aMUc4GTJqLVwhoky2aztyuP9KTdbvV3Q9TQ)wNdlFS3uCm4O1uSo8gu)6ibH9bMaxDhmXHDNQqgJQJ8ENUCEtql98vzUBb0TbMpY)6pMUQ3qEMHdjU8LXzKhqGfr2NO77kILjoHfX48y43rq4o6XV(9p7Y3C1ZUC4WNDzASbfdMoWOd)eorinsAorINk(hOw1nByj88(PYHqx3hEaVbM7u6sN9Itp3qCaelbmJH8vC)o5Ig412lizRWG10fLg6f5DXP871po5avsS0)ZblxTeLGZVJUDr4UAQ91tMwC9QLwiLbAvcMdkria(ZOigB2mYXoM0t4E6uOYchg3TWMchA0p50))6q1tTFVG(SZ6Q)swoLKG3aiH)h4LAdk7b(SlepbXiU1G3kKdZexhuly3)eId6t(bHCQoiFstznsebZIzQqYwj7JCe8zDzHDxCl0FtEJTKN6JNwu0juhmU8dcVlhCAhTBlyWD4t7pYlzciaAD(dqTowqGb1b0S1FqstPRseYul9v2CWJ7VqM)uKwUWpj5EDoG)9kW84r4(ViE2m8(Ve8YH0Qq38YItUp0UkopbeFsU(xBE9hvYPQm93mDvu1xenWGx(otY5JQPq3PncHSCHcNx9pVUCgK()HHcHcz4)dpqx5rOHrRWVqY4xYyKqKmYiWfNqude)Ui7oWHWCu6ddre0lZWh9ptW)cpSfCLQ4EmdL2ilG(IO2MhgpgzJ5db3Ui)dHholLH86xvOigigWS0Gr4Oj3pjKnIVCKXPs2eixLqubX90OsFT6Q18vdF1VBouLmJqRZQUauaUF1hVrc5UHXVRPkDxuH6TPjho1VdiXLswLLbXYj6wN6VBYW5PJZsuWR5dQK7t75mqOQ5sWBHUDKNPLa7L4yDZ8wbvzLZaP64uCvQpCWZ7wCnfQg)o1PcDGYP16pm5EENgu1ErFVUDoWXTNPXQI2f0MMpegBLbjDVOj57CO4pPTvcQLIFbEvowR6)lEUgaCmXEEzDHI7H9cnHvAA3UWQCTdA)t60KLl4DE4HQJANwnMA0xfZhcVdQqs72P6LCpWz6z3BdVUDRSuwyVUqVDRag3xw6YBmhVwsPuorPyL8HHcvb1topn2CqlFvE7YMzz15xm40NE6pknEvAls42ej3Sg)UW7nbOAw5nm5ZiDQ8BynYpXmmLuhJNWJKRaGiAkgvKsJfQK61dr)jbQtWFsEl(tGcDT7qp09crQ4qLOa1sMYk(Lm(lZEkppwG6I4vWkp9Jtf7ew(fDjpUStpPIMq72kNngPEw1KPIA2WVSlvpWmATcgm1E7WXTMADQKUep3kpK7Xd35iI0QemudVEe3p8GAou0P7MN(LNccjeyfRsJ4lsnb5Q8wDrnrv50FPdgDqPSWdz0lgnomnURRfCKGznunWFByWCjEwWROZZTnmlWsFDVGtU1oFZWITtStLnFOXr96R4l4rYGGPl7z0Fj6VmpMx0Hy(9D(SW47uxRW9AWGTnhPKF6u2SGjb5xEk3JqYHq0tnEGOysIMgZYIEsU(4E9vhPD)RtBkimZsKxZryOKBHFQw8TIcu6clpac5LhoLMkmTnOK5OZt)aoi41LVMaTXTLFrYqmWx1HsUZRo2U1Z179cdltc)TLrdKHEIhiU)6Lxg415BSlNCRhlCuKmL7xKdVoCYv5hSxZarOeUuacgCOA(c5KBOMt5DNowr05FNU55fx(68F5Sp8u5pEk(JOOwsO)9er)pukiKVdpYR(Nx5kO3yEG3X92WFZytpBB)Wt7urjwBbfpy8Q3AcqGnNRXoIxAW8PR4aRgS1qCty(xrc1pjubPixInt2rQFIh28QKJkNU5ZqZr084iUDQmz6p1YzP4tROdRu2fTm7uYQcCWYPWDLfHgoaUNpzkQA5hLr6z5aGaL0PNv9W9(aRcosfTxiv4cdWZ6tK))3ymXhtL5RtNjwY7oJQvWWpSrIp09Jp8FlFr6pOf3J(2ClVTx)dhHiuA6QKCJbBsyqcsQSb9IBW)2pmZg0Y31kpUIJLNNfHgkEMpeEUbM1WOC()wfmHQSni0OLKKk6LBIrvAsrmuDmytlkrq5B(zE5YFtawI3257gDduRnIL2rLc2tZlg9ow8nGWO3adXyqzboZTHc63f2MZArs2m8r(i64YatWiwapm99WumjjmyIix4GRncqOPmGHjZRStthjCNc88c52BshQZ7v3Vo3NUUUqDB7fPR7lq3n5IZT1eyV2qG9EQNRq1DrI961wkSXArRX8tBdMxxsgSVk5Acn40EETCkzm3B9m6mhcA6P6OSugiFLgNaXWKxsadtsneV4X8zOU42SXcpnLHp0KS2H7zzOk8W4SSnyxlyurxxDIVBndz32HFwzhDWJ5ej3EMSwILUyX(LuQYIdraMjp3JigQ0aEspmSEPgnYQeYwlQg2yS7caVAQ8cgv6wmWyPGF1eUNI)d0uNSjieLMPCNra4mVJkgZW40oOyuYWkwJUJeKZwYTx(Xfy7)eY(mpcQaWHnWAke8(ou8bhUM8CAU8Fl(lWmbDVdq9pGDRce9xqkw6hHtFl5z6jIv0O153X8519T08H3Ed0x72VOloTWTxURrkEKtfM)l8yQe4P)C1Q95yy8QaS2xIPSknQaNsVpRWu1XylxJDf793lW0MxGjAr571x6VW1xc7JawO)NrLvfDxp49Fuo2LAVNVLrORXVJqz3ikxcPSqmXQu)74tDS)Iau2MFrndgyIOgqic4xqnJQoPe0CC4vHXXtdxHkbEk12h))BVRTDBBJGOFl9HQkM4ilsl36hSmqCLsR7dff1gPVflAl5gHklzOljPab6BVZL9(nskl72ue4NSe5YDhE2zN9mNDKPSpo8TK44qnqJ6xadVcwvOCz2JMT9Jk2n62ziUYYqbnLeo0RAmyV9og8KQHGN0ueyJWses6kmZISefHajmzexr(egQe7UNcwIFJyXM3WZFdY3e4AE5hNQYx5Wl748oXpTKb9G7Virv2YkmKMzajIPovZ3k4Uc5zIx9(Li)8xUgLActfpykgSqXF)TLpizc51eJ5Bh9wQME5yBCjSxfP)(HH(mtb15ydOKn5B0JiLjnN9o)MHBMLyrvCcEZLvbf55hBm5lGXNtZtGD5xjZICK62yoAyPUtNVZOpjISY7MZ0gfNrVLb2oj5I(VFJ5abSv7NXphRxF7SsiOqHG)Ah6xZvTYpT)H3p5VURN2)hed0M(Z7QrudMn82F5LQDhlYGlhJDhyzdsXPLl5AYQxAArhkwXwo4378OxbzhZxl924PwpaRwhqoaYSb1KSJgXHz6P7bNzhFIDWNqJYjBRiWw1qYhVdp30PpmTUb8umW)VqIjwaDFGeBwOh7pyBeq1(bp5pKQuRa)rjMsEknfV58dhEP8SBqXrp(V5386SjxoNcdA7OF6hhGIhN0TkSpSnZwVvxiQzmZ8fiMCoRGLPcEuGHNbWZbj8rOZCaeTw)ul(zLqcXBZqPckgLxIKY9YGV1ErOLYOnPhP5Ev6f3B2dPsZr4O7EsTivpWd3PoRPdDn5oegI9RKZEvkia3kfSHcfLZJ0kgXo5ttxldeTadz31lJ7HlPb2NqbQQIh9vXIIn7fc7QFc6S6ywj(6zTJ50rAUQwMm)VeNeu8oK)N(6aFWFaP5RtEht3PF(ZgFH8ycP(OcNRvrPD5Cd2X8YmvEMHptJtee33mF77Uk7tUkDeWAvMIfmwQ07KyFuSujaNPUY1jo(vdQAOic8bzPPqleZMs2YME)9tNJldnEcGI3qTIIOUOMove9g8VPw)1IOUmtJ4dKAAWfLGUHyfL7a)plWZio20S(pyWH(qkHu3G)Frxpb4q(skUYz8tAGbNkeKVXyu2sxBafY0VFrxhPccOdACna7UcI6hIYOa6uOokeuvapaKimAbAn0yeyIG3cet5W1pd5JO8okQlLs)4)vqdgI1To)MCXyHohB3Sz9ACC7IaSKeYolbeVupz8Q3wNNznr0gvPnKM8yBUOrIUTsQPGRGIDT2TwBjN9F7rVmQx7ZY1(cTJjmXwGptMdGMUdyT48haEc06ENNSGjfEohvF54XRK7fGpWVsnioD93HFOrSKId9KKGnEWGW7lg4H(Q2)J38jWoAyYXogAU7NdZ9KgodM9HqJdE5FF3wbUyxYmQr)BV7Fu)rEoi3oQjI(jX2UEeA(j6qrAp9L)wi1cj(mhbnPLDLZExpaPQxguOEdRCKGxSeR)j36OP5GRNgKHq2lYuDRaBrBSAU1Kpn52n0K(7nItHdObBBC7IY9bA2g3mBZe98otbggzr80CbECMRk0PSSpYw0vSRFr(IJhbQil58mF4bD)nt5mN4QdB5PS0ll4J1311ZwS4EKszCjY)e72xtQbWpfWyGFsZA3ohN(X4j8b65Iw4Yz0JcwlA97xDnxosEKpm(CEAvBt0Ptw)XlNGRNkwTpp0UV(g3BbAPiEFB12MpGCs0)TdW8KTeSv0s3Ycl6Ep96MoS1EIYx0Vsv(fHGAjbAOoSPQ7sVqGruw)2fIiVg(bYv0pZeWDaT1oXPaq3O0skuoguHLnK12X2rxrh15o8C8xVyO79Qp9RDQXRXOLYgJ0rK(mwxORVko1YHwHOCSIShFuf08xNe3vvUJoPY8QFsSeRbBmk6O12JZPOsOcs6k8XHoh5O0cRW04U8(rbPEfMaqy1ZvfZixOfsuLFw)yS9bU4jruZkK)D6laVvW5pYlQaks6ItChcAXOpswoAQbImwnyIaKbRlpIboyxJvpFYcwM3sCFIshKNs5aJRrBv)FRjGNbMK(hEamxrVRSWv0c57ZRmQ8zYvZjEHOIrgUcVSKsmwup1oqgfkgWj)2KKGLWvew0(WpZTS9H1SmXBNTCPbrdD6zVzrhVsgbbRGvJxSH0EmAq3Au52y)ElW0J6b2U8YdXmtxQO(IRwhm2fXBlv9ADP)jn2A1SfRL1bH8iKk1Uwo86fSOsGRgfTCsTB1BIAazAfF6a2H2XNBKXNN7hINOLMv5kzZAwrW8Nl4zNKf7R(5bRjxIsrgShZatu5Q5MznqlyDX6S(wZQmVETxxX1EkUJN2rZPsr3qhvt0yekG5ed2S6dzlEUGS5pBqwFpXpZq28iq2qlre)TyrGVmpfKTWdYgPoYffYgOM09mbzlAaK9REz3)q2VW8Y2cdN5)gUAtmQQpK(REH3)q6VW8c7aP)30vCIrfTHHlUtsaifLng9S5MX0vdz6KEGpD5jBII5wS)n82uJro0Bonmt5VV6w7MfsAY1TtTNYXNHNOtq259d243p7n)hr7v76Mu3ldgjY5DRH)E3)m]] )