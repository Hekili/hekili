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
        id = function ()
            if buff.recall.up then return 371807 end
            if talent.maneuverability.enabled then return 433874 end
            return 357210
        end,
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

        copy = { "recall", 371807, 357210, 433874 },
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
        gcd = "off",
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
        id = function() return talent.chrono_flame.enabled and 431443 or 361469 end,
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

        copy = { 361469, "chrono_flame", 431443 }
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


spec:RegisterPack( "Devastation", 20240915, [[Hekili:S336YTnoYc)S46uJI1ehzlz7eVZxS3kES9ozQDNDQOCMTo)XsusqsScfPwsk74TCPN9VUBCHaGaKuxCYuN6u7oX2KGnaA037ga339(pFF)jb5S7)TEN07St(lDpVt3ENd)Y99ZFAj7((ldg)LGzWVehSa(3BypeKLhKhMeJV7POKGjimYswLogE)888Lz)0XhplmF(QrDgNS44SWfRIOVyCAW0C8VhF8OOKrhNpN9yq6JqtdJpMfplmMD84OGSSblsMSkILDCWYi8)gWEi5lS0oJxU8((JwfgL)X47h5EK)oyWSKn((FR7zVf(95HtMW4nMLn(((yJFZj)L3098FA9WpefL846H3Kgmljg(h26HHXWJ)N3U(xx)R8M(U307DhTEi8jNCM4NxaF6)9sSZZwpCAAYI1d7hU4Nn(MtH2855aa)xbPW)qZX77hfMLNH4lg(V)gH(zXbJIytU)677hmMJyz5S04W8NgKTkfX9SfltEKLoip5((DVV)4NghXgKhaVdG2VHpjne(KWaoiEGnGfZweIdV3F56HDxp81RhMheXIZ7iHD2GSLbXDe9(6Hp)86HJwnDANjkSrNu2IGWyekaq68UZxp8hxpeWUrrdMdKbWSRvfF0v8U2(tC1rRwsG6W1dTh)xrp9u9zW0K48bjthSiyw44IjqBQRoSHt320)hhlL6ryy)wA4CqnqHttLgUKVQDROra1aUSbelRYG5BAq8xwpCrswo0xlxgfog)ya0ji4P1Wo3NdKXBbXqVnNyOhHD6riRDKKOxNTHIWbDeo9pDlM(NU5tFoL0PnD6FqDuDvJJWoStVTal5a1IiPZSqs6iJZ8JZkHKYH)x)LPmq(8OGCxIIsajTzS8cy(qaGtH3I)w0k4h5PHXFHL3jVBhy8naO1hGtjok578ldZ6SimnnjfxXMMcZHvPSjaAArc80hZOPZaUknXNnOlbQmxSIBaYOxvdSVpVCBqg9kqg2mMcKr4uDwnjcPJf2ukwxBTzCss0KKhJ7mzvkzwW6H)W6HfpTGJOObahXj85v1T7hQRN4aQTLK7ByJdNaCLpopC8Cfi4IOxgeckWrJu0nuaeUdSptzPKO0fHXRqU6G4jK6h5FlaKhYTSNIh7LKAalkd(9t6CUIgRRljaARgUGu51vEVwXkxppRC9(MTY5SNuRCvIEoF75CjPgJyratb8pzdaRtb5NXJdIIWL5YsyIFAXkgW3btLhyrHXZa9hHXtIyUAC2YNwGsXtZg8iBKTLdz5Hl4Mtguq1SEinebnfpHyVflHHE8m49OzLsm06Hjtfps8DaP5KWha65j8VKExbEu1CUSIWCKsobBFwN1d)La(yimohu8WgNJwUmjCAiIcoC8ka3eNh9eQg)8V2MZHmduYsF08WzZX2TmnmjLmecFTgOKZSocBJD2lzZtwfHJDCwopiEgorWHLwRl6HqWRcwqgI6sGpEct8Nqx8b4zpcFb)Rd07JPyBdNQJUrECSTjPYFlobEiYUiz)L4CWEnNm0lcIxfeHKHVD7jd7TbKH92eYWEUidDjHOyA8UTFAqe9PRg90GhNZIwoiBoTsuMXaK5cg5Gu2dG1YG0yGpyq4yb0lHJzFDC0QjKXqxS9JUEny01BJhD90hD)LDtqTKcxxu9bOeHk0Z6xuooXQtqFTY6p2Ob43oO4LfEFHwU(6kSor1shdio3g33SRknQCQr)yJg04rLTbK(hvD1gvMAF6QiS6HR4DpzJji725KsM5BQA4tK3JGnfct9fTfegfGouc6nmiFs7oaFXa654yYLD9PmVJkjCMKcuGSLeCgeKqJQPbRIYj)mmgH)H4ZfsvbgQyUG)mWHdyiohwYi9wIzqMOHRwc60OxCZNeXDj5wqS9Bwp8okMklqfimq1i2MZYyWAqgJTa((OWVWeAXYEKbkuwMGQ9gTkhvO9kuZjl9jYomsPqiUcNbdPPyWyGo4xKJjAKa2btGliM88h6PK4jzCDJJyZiNYWj0i0FjUQoqYm3R9UU8vytrWz5A43lEXWV9)mFi7XI(kOtv8DHXyK4gW96mmE6Qm4dgCIg)iW2EI(efzZyFfDiniAWYqAayBeRQFzPtca3SzlgbUPyZk83qL09PvG(GO4i8p)WKGL5IE(3b85QOiDjMcF3Z4nFqGQ1Qq4GdhBJgl99tdHv08K0ff(9ZLzQfHO4zRIM6l4bKQgywbRoAHGQyIR6aA8yB9GHga)djs7L7rtRQgjfdJiWUrqt30Oas6HgvzfbRe49OFA5rvuaWaUenHIt6XT36PKva)dYUfmkzLWfR(9jMsmezOPLGDpShaYabDCYswmJt4JFhbHhPxFZNEZv3D9BUQF)3CvAImQ0fyl)rz8an3rYMhKNZvXJCuuR8fxWEQOgoceaqqBky0B(a9WID65BxmeC5GubC)Rs1HQMzgLNIMcOYl4Aq)RMFasZmyeyFC(ChT22P4c5oGKraBZWHj3jfUmOyGTgeUQh88mUlhpMK(fsYdFjgLtVi4RHlwTafIMdISJL(LO91JNi8GgwItleNbc2dNbYXja(ZOSm20PKxamPBtg2JJdRbfWTIqyuTe6LaABaqboiCIdrcHlazRWVmaWz5PRgRlurNFBblcK7KcQyC(2Gy2kqQxWOWiyLupWYcTbN4G8Gb6nSxgFpTm2crkzS4XGR1SPHJrnyIWWZJNnXsiAcy5tAwoqV7kUc6tymSHa8OVfTUawjGogWD33hnGkbm5A24juWxLi0)9kgkj20uMvlfm8lcu6VtdcbxvcMGC4ZdwU8jxEXlHk6e0a(FmatLcpHkMwoN5Y)l)XegXoNcudWxpo3ykKUk2BFHwe5W)OM8Pz5CjRZsbUaxYvn15Ls8k9rB(YOekmHJcHX7Szis7dXJdzO0W7I4dnzmGxaKvrtgmcnvjzHsKKxDTfdbA8HtXkK6Bj1S6aX7sYMqySGriiDmWkm4HWz6mk6A08eK(wLfu)E(sQbEetP3q(yhnFmdnx8FUerTCx7X5akBAkzkikKHSWkqezJzrjJcIeINe2DX)WamdGmOv3ETlP(f4aKqFa7bIRp5by1bfIetmUV1G7Co82uj6b4RmtmWjOJmCLyuRxGPlDsyggCKzPO3PWWB8xYSWVLAMjs2fk8mdluOrvj(9kYBtHjnMReaPmIevVMc)0yOp)q)p87L0ENfhSeBQhPu11zFy8)EvyQuwdcrxw3XWOHpNXT7jt30qBbrw8MbJwp8JPHW05tu02KKpAk1qQesl4S0qqImzNoynCCgbc)c2knk1yD0j(RN1kmfJT3ysPGXIUqblknxZYadHvthvT00QvJvTEWIzVMcnLuv17kuKBiHQu0FKFqE4sEmZaCklZAj7ZHaQ5wWCZaEYyttwggqrQNKBHOZvOS0chTwc2XsRAK4vqQ3suOBc0dPpgIP3La5Dx3m7oDKG7nmPKTQYPJ2k)oCAZhooA7k2ug4OFMcSWDeBZ10hcu09r7WbRTc)pKv2)ei9mgTvNhfc0YErSHfgelJHAe9(lYEnhNceHicMr)k5InkoMHMsZD)(0tYAgxHHZxU4n8vMb(sfrHuwTyazhgeB)6cIdbVwmi5BRsCc3Uj6tZtaHVmUe8l4aXHFd88BuI9RuCLCSCzv7b)FRyF7wXkjm1o77AlOSmNbLZLGqxRY3CnFLlw6wnAOcztc9Kzj88dbwUGARNsf3K0FaRWi4rgvzVhqBPCfNRTYqqhUFqMRqythVe8ACGObF7SvSpzGcgucUkaenmjHLf)QCDe7TxFKM6DA0GXoe)w0iZF(gNXARaxmjjxx68GjblWfI8WXCFNTJWKDCkmM5cVZSAZaXJjb)EnxWSWtENMleK6LkJyNUjLnyPF3TwvZ03XZXoc9WjWGoQ7j2m9MTSGX3AH))g1N)pcqzB3O15CEUF(AmUgX5sIGXblDg8qjMz5tP1GrCvTBC7U1OLFibRDYi3cSQtQi69aWcr2vCwdrkvhfrdksbJiIOInfPA2tvxdEClAucWnc7IXYZV)eAsYzF(1uqRof)j3hS)qHJO30Th5JgqwXZ2nUYbp(3baZ)dkSI38jNXA1A5ZK81jfhfFLEnG7YA9WbXboG8ftbJyZwhDvbUhKJgdcOCOLv(MsQyDgMquqP(W)Cni5i86sGsVpGhIc(yxtye9YiwWs1etjiWxOQ8QKQRtfM)97K0iIUbw8P(btpcYx)tcvNkZ8fyLJu)gpQMyRrQgYpsEGpr00iH9XytYsG5nTeA7Acq2Gf)R9q8)jbdy1ebqNyiXjkzw4yvXf)zxl4yRttxTmFaMtzrfsJ(NpokCjoxBvwhFlu7s2vx2R1HUJhXv9E(zJOqaYizWQ7tdOjHDxP9kSd3gOBq36lijxrHExrqveIKAKF4unfUez7b0MZLj1kldqHUusl(RAinveAOHBtdZMlKqjbTicju4LQ0vakbzMXdKx7l3fIfpsZmtxzNSopRL7NE4Q1EPbvNHjW84EIZfFwbh8FwLIggKg(f7uaEhmWhrsDNkMsUlTvvSGRicMtaE3fJcJNWsheLKSaRosmWbZqE6beClhFBzYBBWNwGsndIhfdpxwECtbu1nH0NH3yCDcIO(fydZNNnGxzpUiBDpnQacvo2RiQF21xKLcuTxdoPLKQuIQYrHh)sK0vMW3unJZiUu2PTUAETDyfjYdng2U0ffwezATQdZKCaRZoPbMiiAxB5kKf60reqniJ(nQuWeASY8fsYvXC)3PmPoNcX9V)rHFK3(aj74xssd)pjXhr6MeUavauK2eeh3xZgRB5zBy9WpNgGQMxp8J8c6W(BlcXEh5K0BbSzPCO68JYdJwRgKXZ3RmgU2uPYBAz7T9b3lmxJRaSxibRVGoCArUMB4e3LZeNwt2QjI8c2x)lf1fm8RvvSOnLYpFJwqlu2zXjvpYM8iykfQjfH80IgGFkBshmowcklA71i(ckISIhjlYljbMVQP0I(6qV1aNcFj8RXFP0veljhfTwTGPRgy8LwMEUOh9UUvQpz)7vG1HaESIYgTD9v5GfDJxmSJShOcupFsdAJYIsY1)7ggj9klOXQIbER6laKwngz1QgsMcnn74qQITR2PA0ehS2U0lLqv4BFD03LqRffBnxlTZgPQ9vx2KxqFZRTyRrsPY2eNtwuCTKeJwFzHSr1xJeNV9ej(qniSQleUtfLcvKRatRJB9fG6AXA1JvSZvLwn9lDvG8uKkZE0fcz9VmrStbosgdFS055Ytb6mAFhI62XDYc(m79Ycwn(c7Lf1MvHW7ZmdLILA(JkmMqjyFsYQriFbIOwRTNe4gsKeZCiUVF)JV7AXOuZdBU2duIFQAuxuQO3xrbyi62EBVSKUFVLL4sVX3tzjDRswIpLCvZv0ZtJ62ezj9CllPuHP3yzjoR59)eklPxtWkwkv7vzgZtRxrCLwR0AFA40EdhVbIA)4uuydMDus(eUWRBizXoKIQ3hCel3C3K0kHTN4NPM5CHwKDVSq(7RhAJsqzCgWXv66RskxLi59KPPFdwOQGooNQHU6kCoSGJ)Wyot8FNxVx8DgaUpWanwMBxaWdm(2myedLvEG0ZHVmh3YprSVYRpiuz6GiuysZYMA1zLJlhTvLr98TfR2(hlFJQ7m)v7PO4Wmwa(hIodq)ySSpcRugmEKGYUuuQTic3l41EqmdPhYOI7p)rwapfOC4N1jl)1xEmFNsqF9rHtV09869N2srtZNqIzXvxEARdmMNUcJvPWGUFRSjVzrvr5yHe)elk4Ry3Ph)MBJZXn3YNyuTTHtCKAECqm5Hn4fgYkr1rFaTBMNhMoru1ztqd2O4lgNKUaxgWT6siHLbM6RJssMeTcTy81ycZO9B0hf7YJJ)dAp1GwFIHnIogdMXcsBVZfBYP92SQnXDuH2pX6rPCodKcnkjEvwN8hFS7GZwo2wIwfzPU9Mh0OdB2quulkUgDT2OrwvXDQsx)XM4kCqkTs1waE8nyfw1CUImeEqBW92GoQn4egyZuT42RV7iJAWlNxwFD8Mf0nPCJA(cxTRxcJ1RTDVVUoRyP1)HFt7Qc2sPQ0XYvZuSIw6tfbn3RlabFtsSwXoi9a7dus)xp8pOYVXcJt4ZTR(Em5TCxJp6gp7dPknIUc7RRNlXCWqAzgmNhtC)LdrUYHoRKMjGwXiUilcofu4l1aDp3suMtAfTkwZVlV1qBRNS)wc4yYx3Puzdy9(sJCntnCaQ22iDVytNeb2(aRM9U6kxroO(TNLXA9i8GZjDcP81DTZqQBXAfby8IyoRwldGyG8FNb6QYQMYRymhwZ4AuRVLN0E)GXrbG5EU8B0mJSucQL1bbzuh47ZVt7(VGuqzoMZNOG)dj4gKcLsA1r)TwLNrh6kOK(B(uND2kIVxLSAL(b5UUuXHRL8Ukkl1MjSRwzvnG1AJeowPUZ9uP0w9(sOYYyVufr))rBU)On3vtq3Rej1xV1vw1m)RamdJuf3C31hJBoe(E9NCGAYt8f3mCxlX9jnweUN)gMyZh5NvnPSSvr58vtkKqCYI4eKSlM2NEtdfHyaMmA0wOwh88yQc9Xf0dpcdvN1QtPfOwEv(B)yD8RsN)R1Oo0psjOs)ZLEvvSm8c(3uNrh4k)M3PoRNEtuQBRU)tfwTPioFoqC1wJ68vDrMfcNRDWhrNZfV1LlCRhXuKjjT5UsWluRmoxf7RHQCz1dDKlRbzOPkCRBFo0CR4nv5usBc)uYsxTk3R6s4)77a2tfZ5QC9lgYB6UoGf)fEHeyAaBI2BS(wqvYdyec70TJznTIFO2l5Ebz94Eo(MIbZ0GyhButERkLllzwxBxEs5844qoV0P8lHECaSVR7ldFbHPE2xvvNk2(TQDYIWFFE1sdk2Ot25Y8P6LpUKMFlQL7YSqvww((2OV)sagJtUwxrMC0THd3mpu2LrPspcKT0XE5Eme(scu3BLyjrtJSzRwsHUNOrhkqQMv7LBSTM19EPz1jfTBKHhQVvzjwftN6iSrazQfS2yU9wZMvre16QNOuX6vy8affKKuZosanHQ4q10U2ZbKdQJgYoQuBZbgYA9TQVvshkTDeKTJVfxCjByjTtBq7EHjTWO1PaIorox41WbxK7A1H2ISAsXK)zVbCOAg9ZgAICUK0uUj6BDUFCUKpaA5U8g6vz5)x32zZERqqB4bHlkV)YU8DCrfHR5(9Y2DOUEXKGXJFy2PRR02EZ9goWZEz5gKEqKsVBrKeSQJTuMcCgDCKsozPuPGb4pgyQOPn0(imk(IkcsT5w5)Pihwi6ET(z2w4cSiYPddQrRYZtOJMZTzRYSn7CL)x4(IX7EYWNE3T(08qzA3wlgGgV(CFX)oPMVvlGxxC6gWLnPvmBbtMKjdGd)i)tw26H5VswGDIOdemJiZLjPIpMrI9pEtd3Z1oftPzYG2IpoW4l8ODacXCfMuKe)0xheXMfm2moIiQUcajkWPAacf28E(Dg6pnAlnII5gRUSxvNewIadStBnQkMyflc(pXcnGvzC9bL9HTIWj6CFzTf(uuSL2ScD6r8nccpyafXlLhbGpQDY00akjbvmxCrXNcQFn3IsSVYgVc0hYnQ0k84KRt40ad8RRSbRd5rrRk6Al0Q2dD72t9Py7CPCABjaiZnTuqUb50lFTfiQKOMoYvjrPl(wjo0(2KPucC9e6I92natB3ESxuD5kMGK0XZrmRTV6cjfvgldNjQIlY38QzHFoaLkoiGu3kl4k4Q48J5dMQVJwmWVfiuhZWEM0XEq17TBwfBV08HsV36ALXrTrvZCvlkn(VPuQCAF5E8Ysz7M3NwvrA5Lh6S7fhPFGIg6y9sCJuDYfySLtrlaZeLZp3EvHjSVIL9k0mcQmUMiR(TGv5jII6NF63N1z9V(3dXsUO7pbwjNedDd96xjLPLRF8k8konS7xkN2qJoS7xBxhKnwjTaSZv5gc3xUr8EaY9EXG8PFRH8oS(T(xDqWMLVzeSEgwwwLznW8yZwdNYfgeAd2swkAdXZ8nAT8GU041Jh2FRH)5UHFHutlaxoIDneI7azfhUV1nC1l6llW6QEWAiu3B4xpW3OIlS5EDvngneUwvPHfK9udhFlH97CdB9ImYcWUQ)OgcvR6PYgp7UARAiS3Xr8f7D(opquLrABMd7mv3q4TZuUEG7EH6YdS3BCZ)L9(QMhiU1RAEG3Edd09K98aURhJY2Ea6rLPm1Z20Sw5QUPGZmTYwa1DoNBkO1Y0SfCDKd6McuRiizbyp52ReW9OAWkAR2yd3XITPaFh4U8bYxuKXUmE9OSXviqTaEvrjTPDZoyhSxqUpmBVRh567hYolGNSKX3iVz8mk9k3jBOv19slF5A8Yl7DslZy8C1L9Kd99CF5SRkM5V0kl65leb7J1TEE85wlvewa2rsk(2aupUDUN5Q91n7axTxqUp4Q75rtLrIqELT2FhPrPPaUC(rSf87nbkL6cpE5ALQGxzBRHZejuaCNbqrCTU8Q9ruu2ZKC7FkUxgcoN4v1vz9MHzljttSZ45N1fcX3IlDu14m14aXOuJmviT7DG8kkClan)OJ7PQg5fnz)c8DyudVltCC(w1i3Sz7)ozhMbugiQASlBW(eW7W4ftItvdxX73JGDZhS1DjM7OJAWNyQiWtN3RjmREA0(Ud8H4AaO9XW6Sj7xGVdJ6Qyu92S9FNSdZa3mToAW(eW7W41jBB53Vhb7MpyBaRTDh1GpPARxuIIkkPzXXeLdzpUAZlk4FXa83PXDjx39DIe16WQG)p8dUkaD5BV8KNFUQ3)d)qvW(YtAlNIB5GBNgB1n0uy2sUqPyJQFjZDBmOi23G)fdWFNg31tj3ReXId4V3OKDa7QOKB2GBNgB1n0uy2sEQRe(as39Dg06qmu1T2GkPYU07r5O7(SQM38o18mb3DpvQngGVuWUvu(BcASUw38US5OXABEZ70AqJUBJb4lfMC9vjk9opoNfTCqg8VrUxNC0QM3fpopmBjp3gHaApng3eiHJDQ4TMMB0PLIqVoAR25LVw18UO5ZRABUrNwke57Oa)xyW3aaJ71IobXpnyYYSQaUV21WXFt7gurXGnh8n253Q9UEp0b(CeXhO3wJEFHbFdaCZws93Ugo(BA3SvuoBqqu3okNnOdAiLtjBbpWRNd(me75N9BIw12O5JtT9pEy3oN)Ap8cWBD0HzpfpUD7RoSA)B8TcB3JDRTh7k6rj6)BiE74V54TJFbWBkksVfvY(lJAD9v3OY8GBb5I8JVHaKNeolOzED80uqTBfQJVAPzRNW(Q10Tyc7buB5eMs(20KOOKhdPJdjG0e3RKSI7na1HGeFNtWVV9PnORSD0b(5u(bWvrRNmbB8KG8GrbzSFA9VYp7BsdZ9K1VGe0K)DjFFImrVB1D838TIWEROo8vpC7JA64Bw1ORTH9SaPJB(EBy6TMX3PCuxnS3(mQ7RoE3DknFqEZL38N)6Q1xDVUddX9FP06H1Fxfv9YT5M66PCp2p1N5l9ENXxhyujEwa35fOCja7rQvX96SfulFHp3uq(Inw3cPa(aL9vgTBAy1R3uWVpOJ9Tjr478BlyAD9kxcyEKDjpimS5gSUmzTbxpVIz26YSZPHvcVh2WTNQVT34Mt94l(3LVzzuG1HdCfn5fe41c2YxYkLaRZM0OX82b8AbR)RtqFDN651Ete(k)2hTtle1z81ob8gaw0tC535aKwV(fCS(Ic8AbBZJ5xJcT4U3nvgAr)GF7I86lm49d4D2cw)zAQwYK6fFTFbEdaBLmJLE9l4y9ff41c2MN6MgXmU7DtLmJ(bF9Clni)C7BW7hW7mZO)0Jwlzs9ke2Va3py3zSqdsl2gWS8IcC)GDhWconnFkwgcBGr5EcoP95HJ1WY3XLJnw0t4e2tqF)FQMujC35r96F9J0Afc0lmd)nUGCFFqm50q8kLH)QSoQ9TYRV8yzUBocpp2UuqTjtR1r0LqZLMA4mZm5Zp74TI6Y257EOOQND(EQ(ID(gmM86VOUARD9V28jCpNtyxjXVyeuUq0D(oNty7cQ25BmNW1xmXR)1)l8qMCmDs4948q6E4J)1CIk8UyU8nX8r0jH(ug)S0Fry8k8KSIoED7w83caTryvEEapkz5LzS8WPcSBx(phWIYyxEsNZpsDBaEz9v06ly126UIw3K5BVDE(wQUhFbRjt319ireDR4o(oJU5svl98l871dh9eDcLUeg9y24439icyXpdgZ1UgXb6RjH4vp7e(xsVt2JAnhN54zDAXvvBN1d)La(yqX)HhcVtcNgIKRhkU9BWJ4XUDo)RT5K5Z4Np0I7S8ueEYBYy81AGsoZWlJCsRNREjBo)6wbp(v5k6G)iiZO1f9qy84uwqgI6qvNtyI)e6IpqPSepjxftQI(yQ8KCnyT(TVo22Ku5VrjWePWK8WsCokNV5uPYRJ4ss3ROYkTK76nElwTZSug3Kbzp3dYkl)tlzLnyq6OEl3KbP6kd3fQ0UAeTqnElGWnza0ZZaWz5qAnT3ldajDVTmVE6Y86QjX7fQeAQQYJ84OOvzT4sxFdRMMQkcjpHmYQZDzzvvfwdjK(t05iAx1TsL4OOuEA3sheTnyPu)M7rQXQZj)O(XAj2B)H4JeYQa6QyU4umdAq3nhWaK2aXOjt0WvlH(LEbEC8I1DXhsUTdvKf3LMSaecIILzz8RPQZYyJXl5l2c8KDp8lmHUHShzGy6Lj5M3G2pqxoWa4jrTHO(JmyinfVrrHo4xKJjTdVD(fE2BL3hSzCnoJyZcXYJdNqJy8tF7a8SLpRzYwnUmZcsyhj2Z9xEgYzKYaEJ9mwS)N38bwwUACDH24QEOGuN4PDgEvGpyzOGmrr1hgJhc9d4hoPHIBU5bNOO2V6eAY)3qLA9jCBFEzDbedQ66A9WFhgORacy3diw6KaWnlWniWYxgEzCRCrYUeXCdbv9pP9TQN16Wdmss0Zpl)BTctYJXG6hr1iSpWg4GKxDy3QmKr34iJ3PRjWLOIE(Im3Qa6AUiajFdgrxxoijdE9Y8gKSolNFXBhXEGUucikMKLSygNed)occpsV(Mp9MRU763Cv)(V5Q0elmgmDGEh(nCIqcK0SHC1sanPw1TZI(QLp)CPdlM2p)mENo3Y4A179NEUf3aWvcJmgsxXn7KZzGxGGaJTAeWVbqqJiFmjLF3iXrhOmIfbFnCXQfidCoiUqwHx6F94jf3BiPfmz410)mqgcbWFg5WytNs21XKgc3rhdzYCyDlhAZCOH)Kt))6HhQET77sM3Cr7R(RfnYXH5n0cunW)fEuNJCFGr7cg0s3H6zIljG5SNEfrd9qqyehVdCO0KwdjrWSyUk4TvC)inbFEBYU7HE5aNZbJxuMoYpUw7(KqJl21joIKjRO(MupXSqQuIepryetPfWIJQF1k4fTe30rWBNgoom)Ql7kUP)lDfir6QxTuW1UiqPudVzeIyb0nJ)8GLlFsFE)Vxb6FpcRY2KPtXBPmWmkAgt3ELIJ5juXnG36Gx6(56FT9HUVHvBz6TmDvC5gIAWWJ89X58E1MT(0AHqwUqK2h(N3AguQ)FRh(pxICNCFyYOR)B5nDbY7rQddeUWnlkzesstCTcLK8peE50ugs3FDHyzyGdJilkQJmUBw4ZixSNfNtw6v1uHWBJk5W6CX69A4eXOGUxukVc6(wv59Vvq(iVnvAHxmDcYTRWWg06qzOM8Dd8uqGB1eB5YV)YZ4Mqw5fPI98Xq)jnw0VzvO16XueI19NVkyivtAwANCtfaUt(v1aW7qboqsGOjnxD5XnlnKnLB20xPA4r3eaEh7MHy6iTXrbLqRQPo0QWZNF299gSD3RjdrRhTKevwKvjWOlME9WpJ3Dr4DhlQ8KFHciUpb0VlbeHqGuOUeSVGqu3r4AqQdk8HUBzFmeVCciqExjokZlYtF2gCyjEIxF6p6M7X0AlWkbFkk4eQ8R6d9BtHVT3oYBc5KYsYcSJ4IwYaD5omDsoELRF2EwuyyQQCoB36WYxQXxD5fp)SLvxNOJmlDvv)Np8jNs7pZ4td(Ftt50q13Cnh9flTRNUKXqjV0tMLWdJAc)AWCAuYJQRyXo1ij5ah8H2MMCkxwpjQhDAGlkaD7Dscll(v5697TxFKMKvsdi6Rm(TOg8F(MTqzRd7IiLwV3XluxkT7vDXCXm4yP6RVLc3aTMwp)CD3quTDQ1qPbV37Ovb6IaR81EhN(aVYcFmjoxUImoyzPLFTpYlQEBSrqyEHJdb0339KcMeJ3ZfN870924zF(1K7ONI)KBH2FOkQy6n4vJP9f04BqNvsI4)b53kWAynLX7fsxt1dTTk9mf5rr5md8YvTSiUuJ)XZ8mdT9CxrEyxZWfFVjPz72Tkc5PM3lnDs6Brb83OxLeCQzMMCi8QYIV0iU8OaCo3MRH41hv40FsirszMGOsJps9BCpWXwJlwKDECN0rEkHTputYssIlj8YisjUwsLirrVjKZxC)xPjK3HpXV)s5S(CXx6y7dIaHEN99LwB(XGBP7vlp(1vsmBxct))KG(ynrg8bdECXvv5ukUN9)8gXBtxRJWpnV)hVCFE9pEe27YBSYlDDHv6qzZ20nWcDtBSpUhh00kkuur60WS5cjksVuKo3SH0Ks9bcO0YIISiYMFGtpjSTMNKV7O7H(MzTdDx4P1Jg0NcIqBA2wo0)tJO7GUyeDZ0o15qq)ADZEwl8C3YarZRVmmQJKphrHJfHWlr63HEiZzyecmnm6OIRXkKUUmg3wBE3x7u0AzJaLIbW7Km9eyuIUvPvUREZCzvzlBTmhEQC0yu1pycDCpmB3UCyrFBl3AlAmERxtWB9EDp3EF5hZ1RttrCwO4gpYpTjJCV(nwOM1a77FcDjE5U1SPK1CVXZOZ8W)SZ39FfJGPJeXorA5VblekpDpZkuIM9YUktHSljTwhuTn1nBA0RmDWLG2aVtSTMsTT3jsZgONAKIhtQqVJ2TNmCxhUNjOg)BPukr6JqotUP5jAV0WzZqN1T0FPGoPxc5awWsdIqRqtYYalyk1aRu0j6ymhwFGAjOSgv2jtElwamGnuMz0fyd4zcEedDZ6GIEjdt1gAnsyoBbxJ5xMJLTqe7R8WhgcgMb6tbx095zC1(WHMv2YJHjVLMl)dXtGzcAk3ry8Yqv9zldtXOulmWBbp6i4fqUSyzZFKfWtyLX8HNww6RRi2WNwyPp3WifXYPwrn2cDTNdbTf036GAIjeHff8ve9Ohq3BJZX85)jEHgtx)vhHHFkMCkjLfHgcsP6mGQTr(9Zo)A4cVhTPmPeNKUiGUcTf1CcqvD41rjjtIwH2S86s5h74)GkJaSAXWeXGY(b6WG027CmXoT32fumo6vHzij8v64ZzAog5oJIV)mW51mWvOrjXRY6K)4JDhC2YXfkulfrG26(o7QtVOvDPX89x88ZL7tVXGa6rxbE70EUtICVIGGZlMdkY1frAt5flkLMhZbsoDX9MUQf3E9Dhzeh8CEO17yTMuoo4nm6K1HlRbrcQwQdvxf4B50KvE4B(88umUF9P8WXdXhGkUjjwpkucxS(af1J1d)dA7(BHBSdeOYSKnnYFAHKvl2FT1R9alCa6tVd59kvNoYiMYaC9RCUI47yDFXPNFcXUigwtRj4sx298QJxbftzx(CuBqo4MpysnAgEeR3PnMes5l9XTlqkwZEduVz6zeJ)YaZI4Wmn(AxWHdghfakOejDViaqAxbIfbHZ8cxuftwJ7lrfA6DIjAfrd1jNQMUmDaRztVmoxK6(oG(eQQDcs5NTq4vZcjubyisNik(cRBO(o7SQLTmDl0IXgN9kvmySQ1fpPvbJBQRSQun)RtgsV8JvWz7u67wLrhJm6woKi)VnkGk0OTpOa2mBb2YLmhjH7FfG56IIf4DxFmMVCEzEsgso5joModlfcUb6XKDaGlt)8ny(yOI)pLLTkkFDXbhgFnkobPbIj)NMgkCDbgwAl0wy(hHbZrG5kxwLmEJOakWEUc(Qp3nfHb)1Qfh9I89hDjXM89Xd4Et16W2SoPw0HBZBErXi1pXDpOUAtN6fLCdrdX5J7Y5I7reCzkYgYwmEWBffMm7RH5slX6H2SAZvBxiQBa(XLLAkdYEJpZ4A)Jc8A5OIBmWmI2830bM1azZZdS86Dfm2iP4VkAhiZ7b0Z6oD7yQgs7fYskw9OEDCBmQ51(AP4g3fT40rDjZhB6R(wtN2V451wqwRYbJOoYufsGWrcEshbHPjRshZAe9Bbr1gMFUYez0i9xcWGgWfFNqQBn0mJfibvAgil4JWITXojnRuHKVLHzsUGBw7BTo0PY3QDY4ey1vm5bFLfM0AJnkIIO5GQyX1UmCv2r)2Iqqw0)vru8(llKSwPNmVTvDo12Tx7wh4(onT6Gr5Az5qXSWz5cFqD8bfMCwxffBuBLlPQJaTWaggcZdMcZ1eCVbIGMNUCoNEr1PJbIc)7ENuUOjqfd9(S18NkGauU2MCbWUHxYS8yGwQ4vkf4QQYJTv(RP0hlmM79x2LpGQWJTnl5X1bnVwFsZ0BWfgriDVfh2a6hh3IqmbOsmaMKDLfs0gceda9gnMG2hHXrkykzCUQYV4)Pi8LigWyhkXp6fOTQXOv55iADtqW)POqb2gyUjlS(RkGgwsZLfKZ5(lQOzqR8gXlvuEx3aIIkktvo3kMaWyUpzbtMKj9KJVtZKf3Cy(RWhQ5zsWmIEtgVsEpJuDF8Msef1laSednOVrdLJdmeDFzxG5xQhs76jg0d4S5V9KwoASDeGAW4BVlGwlmb2sOxpCtQBJkCAEhkBdVtfj(SC5l5QGpepZQMukkpgRipCeM5dPlgfHBG7xXh1o9IRX6mNbCLBUUwfYdY2lsIe7RSXRabWOPbAr8X8wnwWSRdJrrR4G3AIkEqztcRoaQN32IvGYz)qZYMHlqwKVp)UZiYYjNXh6NfJc55HYUAzLB(MszXCsXxnikjzbgGEuSYmCupGeVxofE6PMZiZCU6Ms6iO(frWbruxbAeYNNnGVn43XoJV9Fm2t9fIxlECkd1YjS2ORlx5pW(tai1XDmBBDOzqH6srf6qhjncSRrpvzYq53YGu0(Bo7KQ9b6mrH1)B0joGOejZ8TTvK6b0SY73)OWYVBFGKe9l8OFEefNarTAxausJcLXgLzH3YZn)6HFonGyDjw8pKCR93wSrR60GLrVhHcMzK0LlaNwtwmAsglRlPzxuR)dx4lJITR0RkC4BRS8uNjHeONOL(RvNjf2RuyqelNssoPYr2lpctdvestlAa(PGOumgXIvwQIIeFHiKL0JKNQanyb23rPbT(684vqmXbP3(owgA7806PIVtCcquQMJaKRgSA(Xdl0hyfeSCjGU8(vTDVZKLRNFw7aSrQBKIzhDMYG6lLBn4jIJfNJK20HMVXxnPksrWzJN9s4ZSp9LWJEg52YKVfVliDoZ03plMCntkvKvtswrfJj3XsX4xjgjbZDBjIT(9pgtBEGkSK8c6Mt7I0BPQrDXj4q10wzrj5YDBAxRa(9)VxUA6bHbHH(VH4vWRQx8KN5oj6bJ7GzjlZ))Uw(QgArKmx2TrawHxFTRJ9su2CARbce67Ngw1WMUsgqdXl6AEzoEN7X6TnrfwK4aqfHLsCBXksuFvGJFhZYvq9xOVpu2PYlGouzNHvksoD8dpaf4uq7uMMm0Hdqc)7e)GqgYFls(2Wkcx(IvS4Awv7Wpt7Wp9Mb)k5f)BWpTa8JJAwEZWW0OUg8Zua)eKHN6WpgD9zJGFMAwfgI4Y9ubKbEvGVKg(nlJz4rDeM94PagzzdrSHULSrpzRV6sd(2)(ODBmwMH840S7bYollktDNbWpV)SA(6Ipv9MwYQymrKJZE918JXjN1o88SBE5Y9(p]] )