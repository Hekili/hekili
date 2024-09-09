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


spec:RegisterPack( "Devastation", 20240908, [[Hekili:S3xBZTnosc)BX1vJI1ehzlANeVZJT3kES9ozQDNDQiFZw3xSeLiKmRqrQLKYVSLl9B)P7gaKaGaKuV4KPU6Q72jjIKnA0OFVBaCx)7U9Ubb(5S7(nVJ8o5O)YrN2R)jhFKN3DdYFEb7Ubl8N8v)zWFj2Fo8FVI9GFwUFEysm(SNJs8dqyKLSmDc887ZZxK9thE4SW87xoU3KK5hMfoFze9fts9NMJ)7jhookz8H53ZE0p9r4vdJpKfplmMD4Ki)SSHZtcwgXYo0Fre()gYEi5RS0EtwS4UbJxggL)547gBhZ7diZc2K7(T(N8HpciuyqaJ)YSSj3naF53D0hFN3hpy1OJ(lV7Ote)5P)0Qr)3lqiMTA000K5RgniC(pV6xx9RfFZXW7C79SvJ(x(PW)Hq87gefMLNHebg(F)nIMYI9hhXcU7Y7g4pHtTy5S04W8NhMTmfjOS5lsEKLomp5Ubasp55jrSH5(WZaO9B4VKgcFsOphepWgYIzZdr07SZxnQ)QrVD1OC)iwCEpjSZgMTWpUNy0xn6LxwnA8YPt7fK6pljg(pSEPS5(HXiuaG07JVF1OFC1iGKffn8EyTfMDDQ5JUGp0MFITbA5ccu7VAKj(Fb9RhRodMMeNpmz6W5(ZcNuob6sd1(TC62L()rCPYicO9hi0zVgGcNrjnCbFv7AXlbCd4YgWSSmdMVP(XFD1O5jz5WyTyru4e8JbqNGGNwd7DxoWBUbmdERpZGhrD8iI1wYs41Bt4iSWhHt)J3GP)XR)0NZjDCBN(71exx90iCa75TbujlKwKiDIbrsLyCIBAwfIuo8)nywkdu3zrnKgx9FdFlGLgrKmILoqW7MgoBgduU9P4jHafA1OBIif)fyXCwQFuWqqbEwwY8cEC5ZFGLg4dev28XP(OfHsuGWVa2u)Lr51POCrc)p1W4Ryr(Gqi8SvJcru)w4pNUA0ZjlbjWuG67pozzoFwmyWQrVJlEgbFuklcmBHtMPjWulzbW8a)5J3ZWVJGWJ0JV6lV7IBU8DxmyW7UinrAMRK3ZTgoGLAsssuqYJX9YU3ph)G4zdbtLP0B5sNKxHgRXa9KG20Wz3NpuvK843BtvscylmJLRq69bKeEk(3IwICismYkB8FLq89vqCDoSYxfiLNs45f)v9pyAykB44uMF(9wE7UglH)Ha)G1iGcTAedrtU9wyPawtJzpb)CjYcRWWZgdRGpMK(vGEcRD0smAcEU)tGJfGv6XS8hjUz6Nv)6jatTFCaTedR3c5QmqhE4S4KucG)8vFbEY0PSjigLLhohXOEe1Ci3NheTgwcxB61QDTqcNfazBiWbommqLPsOkkC(CW)hqYbOz5Plj4uQrQtHkR5SO8H(PZtsT(u)y2sqg0FCyeSsQAuJl3n4ilShm2IklJNrlJDqIsglEcdERPHtcZlCbGBlLejeVYWXltZYb(DBA1uNWOklaE03obudcReWad0U7gaQIafYthoBsaP4xsq)3lbvvgmuFz5cHa)C)VYemaP(Hbrm)auc)EW08ZiY8EhQAM4dkI5)JHOBCCN5eRxGUW4VI6wba8bNZgBs1GjmynmeMpQtH0LXohl)eIV6JoWZ6(0SCUM1fPmWD7X(w1T2SYcXSTxE)EGLPH46aU(Wvo9D(HHz9MhMMcIoGT6PGDL8LPSaWajifKM8yMQuM4Zg2Nav2MP5SyS9QdX((8WnHy4vsmCO6kCQktTKG0ZGAkn3PS2uQfzzkzWC1OFqXeHIPNYxaeroIpVQ)9(HMgjoGmn0CfBsyadTQeo5(cqW1uSWpen9dHUbM7lgtWKai(mf1zawKbfXlr)5iBh9l)3fkeSYUL9C8eNSudzrzWF)OEVVGhRVnTKkRg1zkPCDLpQ1SY55yLZ7B2kN1rQyLRwYJPE71qYL0AmMfbcfW)jBiyCa8Rjg14JlZv1We)88LmqUdMkpWIiV3wegheXS9YzlEEo6)EA2WhzJnJzu6gbWcvY1SAeHIChAan1l85EGqwTKuiWdNPIFs8DaRzq4da)Ca)l5E5uqhlEDUUc0(8I0e89Z6TA0V4ZXHW4CW8j5JZ8KGWPHijy)jlbAtm5IC)EV)PUCjKzG5m6JUhCefFVfPHGZsyiW4JvaLCM1tKveRJs29jlJqChNL37hpdNiiAP82LJqy8eWrGmK0HUQhWe)tyi(e6Ni8f8V2xDmi36XOb8vK2FmeF3Ku5FlgdDafxKI)sAUU3ELc0GVul9JSz9Fnyd9wd2qV1Hn0ZgBOnneLtdtVlwJPbX0NUC8Zdbx1Jwmm7EALOQGbOZfcVf5ShcRL(PXGCWWWjcOxHgZEAs0YaY3Nt3CSZRfyN3AJDEQy3Fz7uul5WvvvVhQrOg7SUvLJtSMu03OU(d1Eb8Bhw(WY8UH5S4T14DsXBAbH4sB8SYDrfSYQf9d1EHwJvMoq6gR6RGv6wF6xWy5HR49pATzi737Okj4XiKfkVH9lcgv8UGYiFmvIGDdn2N0(dXhmK(DeNS5xFkRXqpdsboqiipeodXynkJh8eNrPtAv5rMJk(XCzaO49Wsgz3sgoT4fxUaSPrpaJOgtrZNsUUhLoGBOSPphnGWOG9wn6KmgSgKXyZHVpkSi6Tmiu(8SfjOzVXyS(H5VbTCYsFM8dJmkeIRWzaknftdpma)IeNimb8dMNJHykNVWiLehKXTnoMnJIUfNqJX4L4M6WKzr5RTVTyfwxcCMsEUgC6Rg9DWTCuETsgHEK)HXyHvgYZ3yy80LzyiMhPipcIThPorrXm2tyII8JgUiKqatNyDMlq9CqIgPhqRaqC4Pr4)8tb(lYfJ8Vd0ZLym)vsvsg)1h6x82f55arhtNgR89yARYYtsNRLbL91Qnq8SLrtDL2yYudmRGvhLIpuoXlgacFCN7aLerxfLiRx2XMo1HjLOre43iyPBkLbxkhbOOFnzE1iZL1NiEBbaisiQa58tN4hZg(q4m1KvPoVCKK(ovtw6z80QOXb9P)518xezxWmIakn(Nlq5jUdE4CafZNskeqXgsoZx4F7SOKX(rIW8esF8p0hRaidERRV0w(dkPbyYMgYEGY8wYdS5uI8IPKN9bTmKDp80uj5z2Ka9cdCeAoJZcsV9CSgObHzOlYZsrFua0BYxZmOVvEnDISns4jA8PewvjNB1u3MsgB9vIbavpatDT4XuqitGX8td(0Vxjd6zX(lWx1rMcBAW(0K)9YWuMsCp2KXzyoraNTjU)mvfeM6hmQmI)4vJ(CAimD(cfZLK9rjXYixcLj6zPHSPCT1GoX4mceUtUyfSur0rL5VzrRWumcVjuIz1w0fwnWmQQKDETegoDC9z0S(ujxFUOlN9kjv2wShvshmz5mpb4NzIKO61CHrosz80sqVzWeY3kpCbpemyXHLzS2FBiqJVEai5WRQBAYIqFkXpekIRllXYevA3ErK)Z0YpvLmq95c0LUeyesFmeRtmbYBUSDfrYsLYxZQB2PoByDlmJzTaoiE01wOoA0OFM8t9gs(7s6dbrJbyr1GfWW)dzn(Na1WXywf4o1IbMls1GyrugsEe98tZElNMcCZibMr)vYJnuVodx(5EZD8rzTt8sZwUnHmBv4vwNUAlB2fkHuy6vTPBc(XHZtY0KD6wKhohC9NYbInEDs1Df54kHPyz5YOjg()wX(2TIvrRSzz8vwqzzwJXZMgvBRYxDjFLlwwJC0JhY5g6xMLWt3i4ceA2FAuYJLf3ZWRuh6OQwkq0PmBHnTrEuAPwIKFpe10YdN7)0qXl8TZPZbKNoyhgWnbGKHGeww8BYvjSxF5bk(jqydgkk(TO3Q)8vwdDRKweKKRQDEyG)CCHipCcVq4MbSy20bAZCrPwnENHIFMu870Vd9oy5JLlTCZl1gaOQVPTyPF7D7vXh6j3Jde2Ok(A8r9pYuOx)nlf8nw4)Vr75)dFu32vkdoxM7NVeBsH4CjtWe)fwJfvszw8CAdueBTnh3bEfE5hsWoRmYUcRM0kIHHaIqKFfN0sIs9bLQXrkeercvSUkv9rQ(M5J7rtHcCTEOqB553FgDj5KBFlLrOJX)Khm3FuqJON03Jc2dyR4fpbx5GF(3baZ)hu2wU6lwdD3y5tN91khh1SeETq6Yy9WcZbIqUAqaTq9BIVQK2d6rJbfuwSYkFsftSw75hurPk6)EfizjBnsGsp3N3PzCCxrze9WiM)IIjwHIax9DItJu9TAW8VFJKhrmmWIpnoy22q56Fsy6SWnFbv5GI)gVfLW3g5AOas5DXesMgl8pgFLSeyEtlHMHMaSnyxeBII)pjy(QdeanqtJtuYSWjfDP8T2wWX3onD5I8Hyjke9pngO)KOWf4CTtvB8DqRlzxCUxN9TNyJl8E5fT0za6izWQ7ZdPjH5qP8iCa3eORX36kBlxqvTVGHQmxlnO)WQzkCjYmcO1xktAvwMPdvTKgYxnWAwWOHoUnnm7EHgkjOfPAHYtvTHcq5BvVTo5Ls9MqSwKTZn9c)KvLznc)0HuTYd1460CbM3(Q4CXLxW()NLPOJbPHF1mJY3ai(ysR7uXuYEpYkRBDDPcnaKDNpomoGLomkjzo2SnyIdMHY0dj4wTz1K1cOfFAjjvpBGuYaT55XvLqv1fsxoEJjiYpIgxqmm)(SH8cfBJT1(0OgiulUxt6dnlxTHbuLhdbPLKwyeTOHdDexIKVsh(6MzSMXLQbT1xjQT9Rj5tOZWMDcJWJiDVvT4MKfyDYrTWfbX71vUczqoTKkvn2OFJ6SaHfRmx52Czmp(DQTOVNYv(V)zrCKx)aP74xssd)pjXhq2MeHavcuK3euhpqXhRR5nn(Qr3M6JMMxn6Z86dA(TL5QVNCs6SFimmouFZoZtJwNw0(YNv4mCJ9fn)vR6VTl4EQ(ACnG9ujyRl5ODBrYpkN42cM44gYWkXKxk(6EPOPSQFzrdWyYP8ZxPK0Ic)S4SQhyYE4pLs1ubJ80Yxa)uwqpmpwcolAF6i(ckJSIFs2ZasgmxnNJb)L7wQOGEjIRXDNzuMljl9arJGPVcyW3Xw2k8SXp6CDRYyY(3lbVdb6ynDHu5MSQT8noPWwkdrrI65tAC38fLKR(VBzM0RT)yQlh4DAE3C0P1eRonWYuAPzlrPA23BhRWtS3kZo5PSZdPy7BI)UczTS394wPT(sfTsLnFYl5V5TQMbMuPlGW5KbhxhjZOXxAPbJqMZpCKKEuGegBYdEqfvsvKTetRsBDLG6gPAntvmRvLslIkdvGIuK6Atmec5Mzjq04PhiZHp2jMC9PaFgTbgrB7yJrJ)MzRrJn3PWF5v8nAvPY7t0tLIHz(dkDMOqXEqYYXOCbsOwP0IRChjsIzwu3pyWH3CPalvIWMB9a14NwG1LDEKTAoAOBXBZ1L0)7TUeB2n(EQlPFD6sCzKREPcphVu)2OlXZUUKk95yR1LyTfk)tOUeV2qvmmQ6vBfZtB2qCTER0zx640oJgVgQA)8uuzdwDus)eUWR6izzd3tnoeIXYDjoPTs47j(zfZCUslYVxwi)5ndTXjOoon4yRC91PLRwI8oY10Vblu1WhNt1fVMe7O1vmMNbdQo8Bk)PLLGD15MGdvTLUsjtK4KK0j3JAPnB7qojQ(YfAMNmLU3q)anG30lPIUEP4Smq05lhYrM6pzd0OVLeulZqVc7v1rQ3zNhbfe7giP3zCym0q7WzzUwYwxZ5lqTt7Z3HhXaB28(4M6mpRYqNWLaZSUhu1lJ(TGBAt4Mr)78w3K3Q34g7b8zuV)VbEqEFJpMHERSNm29VEpUhoIypXB1p0D2HrO587Av)muFDX5EY0P26o8HsIIBC5BulK6EZtl6ZtTfG)HyWaYpwnPdWEvdRia4Uzk63KOgtZ5D)tmd5BZOU1o)rMpVje4WpRxw(Bp)qERVtF9bHtp3(86SJ7uyvHpHeZIlo)4o7PnpTj4vPqe72Mu0zFmuW5yqe)clY)jC4uZG61X54Uv4lmQnvXjoYnpXpMYXvk4vpma0XsHpT9uVpmnq0aPbyitug(JtsNJld4ExiKOYGkJlJsscIwIXS9wSK10gi5ZI22)W)G2Key8FyIBjj)zm)0UBD7EDS361Vx2Zl7UjBRfUhNb(bmojEzwV8hFS)WtwmX0NIA6tKURFAB3VDOOOBWSHDDwlmBBAlwpBjKTWVWgBbw(oMb7BvB5MfTPXJ3NSQXzmWxR4nU(YBoqRlyZ5nwBpN9HGn3)OjPf92TFHRX1lHD4gFVZAAW60KfFCzTU0DwPp5ms2tk2tzdO9ZapVhab(QKyL2nsMdKprTDZQr)b1aC28PDZ6WoDzl7DzNA4RUiQYWyRjc3MLs0rgYkZW75vLYDdjLxKsfJYwlGwjgxwhpRkkC6157nuLzLxrPNrDN0Pg4TvB3gPlH6Y19Q04ogpVcMR4QHfq11KO7KAALjWmlufZEBdLTC318MAtBTEmEsOKgqgFT39AK5wSBTabVidMbHdGAarJ4)rnYvT9TOt1yw8MXgwRU57uE(Wjr(G7E2YCJLy9KDIe5uxpW1b6W0YpfmMdt5Xr()hsXnOfkLSQJz8yzEgDkAGA6V6l92AVi(E1041Mjc7DgoIUg67QPXWBNYUg1v1crR1s5yT2o3rnZE9BXOA3ijv2tc)F8M7oEZT1f0DktsZ74HA7BT)LpwJFQN3U5YdXTNfFZBtbqf8mFXnd3aI8ysJfjC9VHTwWJ8dFKuw2YOC(QjLuwoBrCcY2fth4HtdfPyaMmk8wOvh8a2Pg7XL8dpcOQ1ULRYcKL84im(xxUWkS5)wfUd1Ziak3p2SRwKldNG)Dn50bUYV(d6D22rl6Ku7ED)NkQABjCUcG4InM05knR6TIQTnJlXNZvV1NRCZJekYKS28qj4TkzgxQI9uyUmqcpmqUSwuJ06OT2J5qjSI3vxqjDj6tfpDv6D263enFFryh9SQTnmtjkVU77hw8x5TYJUdSjkpX4BbtjpGziSx)E6Dvo(HkpKhfKXp7z5Bus3TFSL9Cn)TQunzzFp0T6KY65RGCEPY5xH8ybyFx3zuUsctZIVf99TyN0xSxYeX7Z3VcGHn6KxVQCQ6g4qYZVb7MIQIq3v3gJbzDTTN9)fFmhNCRUIAPQ6dhUD6O(7a1k9iW2sNJH7Wu4lzqTFQaizAALpBnYk0)if(qbrvVFlTtTv8U3jpRkRO5lPfH6hml7JTPttm2iG0Tc2yo3(G(Rvtg16R2QcI1RW4HfCqswn3NCaU5k2VyA34XQ7EnXdzMvQn583DL6PUHrrhQSHGKVhFtMzt3WcAVUH(9ctAHtRtbcDICUW7IkUk3vfNbYY(5gl)U5wGJ6A7B1SezDjPTst03ADhXDohb6yVbJ4h9wU6PHM2qPMBgjAlhjcr5SZ7Z3Zt1KUgJa42WnCutJIodJJ4WmlxxLnEQ9T8JJDt2vi)GOKExJejyvhFtztOWOZxskiRctkyc(JbHkAAdVFeMfFrp5vS9Y5)trnSqY9k1dHRW5424GoB1hVmppHoRf3KnR2MS3X(FH7mnN7kkx2D34dMNcx72y1ae(6k8f3NLb8n7e84YZxeUUjL2j1piitMah(z4MCJJeM)gzlUkYoG)mInxwKkooJm7F(QwEQhyvnLIldkl(iIXx4r)aeQ5kDPij(5NggXM5prppIiPUgajAXWgacL2Cp3bd9NgRLAzXCTnx6v3blViXaB1MtSMjw5IG7JGonyvLwVx1yyRjDIw3zKBqmfLBQuJuNEaFRyXtgqz(s5za4ZkhYuTGtsWfZvxu(PG5x9nji7j2KLG9qUtLgPhNcDcNgyIFTvnyvipoAz5qBqwv(r7H90Cj2EVupTPgau4MwkOWGSgLVYcK485hyZPZhm59v1jyMTsr7pzI25NBTuya9nSS3GkXOMijq27n(lZten1p)WuoR3QF9VhIf8T)pb2OtIHHHE8BKu0C1JxH3WZZJ9hkP2WlTF)N62eK1k1TbGTwg8wc3xpmEhazVxniF83AiVfRFR(vlmSz5RhdRd0YWMGbI5WIrlNYLMJmbBf7uMq8exyRH)7vWxh(3)Tg(V3o8l1HBa4Q5lOLqClyR4W9d2HRAlNyawBDJslH6oJ(6a(A171u61wTGBjCnQrSbKDub5VLW(J2HTAloyayBD)qlHQr3CysNT3RhTe2BjgF6oxUZbelQhMPWHzDYAj82AoxhWDNWD5a27mP5)YoFvZbe34vnhWBNrb6F0ogH77WPSnhGomzkl8LjpRrLYAl40lQLbqTxXR2cAL6CzaxlvaRTa1i(vda7OYcvaUdtdg56XKAyptqTf4BH0Llq(Qsm2g81HXgBjGXa41LJM2omBHFWob5UWT9(o0RVBy7maEYcgFJ8MXZN9BSNQZo1pkDCvPJZp37Oo6zo4IZ9KO(oESSouLZ8xBJfEUsrWUyDZZrm3kjc1aWwsr63gG6iSZDSuTRHzlKQDcYDHuTNdlvAPH9nMw)TKe32c4QzN1uXVZ03wziCeLRrIkFJPVgwtJzjWTMafXDgZB2fzrzhZYT754EDy4SsxlUzuxpkBfDAIDgp)SUqO(wCh2vGNPAhigvEjDdsB)aiVXR2aqZp64EUomV8v2TaFlWA4zzIJZ36WC9xB3piBXmG2AM1H7Yxyxc4TaFX6(uh6kE(oeSRpY20DIRLbQfFIUHahdUxBewD8s76bWfHRfG2LaR1xz3c8TaRRtq15RT7hKTygyxO1YlSlb8wGVwfBR(8DiyxFKTfI2Mdul(K69EPqvuzdvkoMOSO7X278Qc(xna)DcVRe6URtKOo7xh8)HFWw7VkF65h9Yl198F4hQd2NFux5uCdrUTc3Ac1kOSvcHQqmQ5Lm7VJghXUg8VAa(7eE3mNSxfMflWFNXjBb21Xj3oKBRWTMqTckBLi1lu(uZvWTf1q1)2ACj1oKopkhTpM196TFq1ptWTpsvEhnWxjz3fC(RdzSP3U9dz7jJn(6TFqBGmA)D0aFL0KRUkzExLBFDYYB1(HW5vDU9XQUxxBqRKHEvYwJZlxVv7hI2pVA811g0kPiFlv4)kd(wayStV75h)8WGfz1bCxVxlX)2omOHIHRp4BDWV1hD9oyaCfiIlqVPo9(kd(wa42TK6(9Aj(32HzJ4CwJKOUzCoRXa0soNk(cUNZihC5i2lV42fT69rZLKA3FC)(9E)BDilap1YaM9C8KUDVy)6JVX1kS5i2VXrSVyeLK)VH0Td)Mt3o8vGUvWr6SPs2DvuRVR(gvwhCdixwF81eG8IWzan9RJN2cQTRrDC1lnB8e2vVMUbtyhGAdNWuX3MMefL8iTTu9bwtCNAXkV3akocw4BBc(f3pT9aLVhDCdoLF8)u(2bb4lh4N7p2pJ9tR(v(jVrAyUJQ(5NGU8Vn17tuj6TRVJ)MVve2zn1HR(HBx0thFZ6gDLTlKbiTCf6BctN9m(wvJ66H9MxrDx9X72ZP5cYRV(M)83xTU671Taf39TsRdr)Tvv1R3MBQVJ29y30FMV27DgxdGwN4zaCRxGYvaSdTwL3RZgqT6f(CBb5RgUUbAbCbkZRmA78WfpEDb)UGp21MeHVVtnGPX1RCfG5q3LCB4BknyCzYAcopNQz242SZQJvIOhwZTNQRT346Z94k)3vVzzkaRLa4kFLxrG3iyREjRubSwFLwHZBgWBeSUVobDnCf)EJ3eHVXT)rB1crtoFTvaVfGfJex(DwaPXJFfX1xvG3iyBFo)AvQf3(HP2ul6g8BwMxFLbVBaV1EW6UstnYM0S6RDlWBbyRvySYJFfX1xvG3iyBFPBALW42pm1km6g8nlT0I6ZTRbVBaV1cJUlpAJSjnBqy3cC3GDRPcTOSyRHWYRkWDd2TGky118PyBiSgoL7i5KMxrygOLRBqmtQOJ0jSJG(U)unPw4U1y9QF9Z0Afc0t1t)nUGC3aqn50q8cTG)OSEf7BL3E(HYA3CaEAqDUGBtwwRdORaJZ1TWPxzYxEXYtf9LT1N9qzxpB95u)fB9jyo5vFqt9w7QFT9typRtyBfXVedQ2i6wFM1jSzdvB9j6t4MBM4v)6)fEe3nHohUE8(q6waJ)1CMk8UyU6nX8b05W8ug)K8EEy8s8eyMoCp7x(VfaATOQ86aEqYIZZy5Htfu3(8)CilkJD(r9E)bf3fzN3ChT(k2TT27O11z(6T1Z3k994RypzAVVhjMORf3X3z09MyXsp)c)E1OXptNpIlaShRgh)Mpqal(jaxUY1ioWFfeIx9Sb8VKEMCevEDCMJN0ILxvT9wn6x854qH8hEeGgeonezx3xC3BGhWC979(N6YzZNXpDAf3z5Pi8K3KX4JvaLCMHxg5KvpBJs298l7b8WFKBOd(h(zAVD5iegpjL5NHKo00zat8pHH4tujlXZrsXKQCmMkphj9xPE7RJVBsQ8VrfWe5WKYWsAoQNV9CPYRJ4kA3RPZkn076mFlgVNERmUoiPNDKS22)0qxzlqsl9B56GKfxz42iLMDJObPXzdeUoiGNdeWA7qAmT3jiGKV3uNNNQoV(kA8ELAHM668ihbkA0wl2S13YUPPUMqYrkJmgCBEwvxJ1qkP)cD1k3V4oXrC78kpRnPJbZwSuQEVHiTy17OFu9M(fhT)q8rcDvaFvmxDkwbny4UhOaK1ab2KjEXLlGXLEaEyGI9DXNsUUh1Kf3KMmhucIQLzz8ljNtYytWRyi2C8CLo8RmHTHShzGA6fj563FVpqxnPa4jvTHO9JmaLMI3NHWa8lsCs5OJMFDl9b5Trzg3IZy2SqS94Wj0yg)S)1hpzRZANUvTRsj)e2bI9C)5NGsgPmq2yhtfhC76Jyz5f41Pk4vZqb5oXt7m8IiE4IqbBsbxFymEeypKFFnhkU3yhEub3(fhrt()gAuBarBhWBRlGzOOVUwn63beDjWaBhHyPb(qywqyqGNVm8QaUiejZweZoek6)jLVT436S)EAfj6LxK)BLgtYHZGQhqUiS3Ze4GMxvy3PkKXW4iN3PlPSfOHE(Im3Ra6q23hzF9htxwhildE5w8oKTolNFT)gXEGos0joMKfSygNfd)occpsp(QV8UlU5Y3DXGbV7I0edkgmDGrh(B4eHuiP4d5YfazQyv3Sk6lx8YlvoSy6(Yl4nkBhTl1RZo(9gsdGujGzmKVI72jxYaV(Yab7cmGF)dGor(ysk)MzHtoqDeZ9FkC(Y5OaCoOUq2HxQF9KGYBTG0sHm8scFgOdHa4pJsySPtj)6yshH7PsH0fomUJ1mfouOFYP)FD)9lES9BYI3DA3l(RLVKLJsy4nqZa)x4bTmk9boTleqRCdoNjoIYVN98BiEOh8dJ40DqcLM0kejcMLZvHSDH0pYtWN36I7o4x2Z6Cq7bv5JCtRvon7vKITDIJifYk7VPIFrVrQkujEKWjMklGLhu4fRGN2rCpRapDA4KW8loVV4EgVYfWczRE5cHu7C)cJA45YEeZNUxUV3FXINvN3)7LG93duU51b3OOzmD35joMNqd3aDRhELFNR(1Mh53AETLP(MPlJR(IOfm8aNEsoFunfRpUriKLluP9P)516jL6)3Qr)ZfO0jpgMm6YhwEo7JYEK5qFriCZIsgJS0KuRWij)dHhonLH89xwQwgqCaJm4Ooq7MHGpJSjEwEozP2vtLkV16KdJZfRZuOjcSGUvgQUc64cS)dgxt9DuUk(VatBqN9LPAY19)rjdUXRyQx(SZpH7czTxJdMZhn7NeUOEVoqR1tOmeRgpFDWqAMuV1o5UkasN8dkE8cVpqHbrrBEXvx1S0q2uUBtpr9WJQla8b2UaX0Xk4rjNqN65ou6WZxEX(TwQ5WROdrzen0evvLvfWuALPuxGY9Ojiz6z3Gl3dSB5xy6GWdq1anoPjlc9PS7rGcZOWs6wyVW30IlF9BOfhqnfQTs5oyNa5nveb1V3bD5mX(veIE7X)ODXnD3Za3kCzzHZzZVzc43sXY77JVLxMRRd)xHRNLuhX9cJg5YEE9KQikIv0muKspzl6)ZUD23gVZPV8IjxJkXSYnR7F(ONCoT)mtp1uyO77NcP(Ql5KVyzGa0DIeQQM(Lzj88UMWV1(MgH3I)shsAq1ZEwKdn9L5yUXbY2agLbxvagNCqcll(n5QJ71xEGIQyYKjgCn(TOj)F(QnW6SfhPiRCNz5bf3HM7uJ3C1miUu)nNzzCJgtRxEPPl0MUwnZuyY37J0QaDVfv9w6IZFG3WApMeNlxrM4VOYYVYh5KuVjovi8hXYPg6z9pQuir75C1j)oDnZDYTVLIF9y8p5U09hfDHm9e8M8Z8(K7Dy0njr8)bfOliAymLXRXoBt19nDJ9Kc2JY(FgKLRBzrChS(JN4ygAgQFb7Hztgx(96SMD72PmhPkH702jPRffiafVAz4kMzk6HWB2h(sJ4UUbO5CN0gH32nHt)jHgPc3eeTM8bRkVOrdfVnUyrogYJQhLPeolrVswssCfLxAPwX2sQKikgnHE(YRRhfL8wcI(SZLZ63l(sl73qei0ZmVEN6Yp3CRCna5iqWkQz7tu6)NemOSaz2k0KXf3SEtPeLo421s2MUf6G)u)6Q78D5Tv3b4OlVG9o329RNfJnBYWal0T9LDj9yHNUGdfnKonm7EHgfzynYOHwtEsP9abu6yWrwMk0pX5Ne(wZRk4n01MD782HU6Uugrn(tbtOjpBhl2)jm6gyigtxKMtTIcQ3cvMZArO(goiEaT1mX0CG1PattjfZru4ero)sKXDOMJDgMsbDhJoq4Ye4yfYxxLIBAnV)BTQATQtGs1a979X3RwXJk8TfwL7R(A28QSJPvM9pwInATjewbi7Oz3UvZJ6h6y3ArRPBETHU59wp7rF5MY51RTeodsCRX8JBdM7mUXsZSAuF3tOZpUNxlNsgZ9wpJoXH8JA0Q6cp8q1tfXQNyeV(H8zOQu00XIKTi98xtec1NUJffQWZEE)cxHm7HTo71WTrFRMgEv5dohSg4CITXCQDDorAhIESwnH05cDITBoB42IUNi4g)BPunugGqotUl7jEV0WzZWG1nSFvaDYUekbmNL6hHEHMKLbEWu5fmQPNyGXIE9j6nbJ1OXoz1EXoMb8HsVeWGyaV0XJzyyw7vokzyT5qVrcZzZ5wm)69yFoeXEINVXqWXmWEkeIURiJB(AGVJdht(anx(hIFbMjORChG5ldn1NTimftRTWbV58SJG3xYYURn)rMpVcxAZhEDCPVUMKjFCPN(ChJkywo2inZgKRDCoRnG(gNfuSckSi)NqYJAgGVoohBaGVW7mz6(Y6am9tXuqjPSi0rqQ2O(uZqYVoP53Bx41(lv6L4K05(0n(ROjvaUQ9VmkjjiAj6ZYBRuqTd)dQVdW2ldRCdQ7h4d9t7U15e7yVnlPyCYBQA2HRT6HNDIsGr2lb5zNabVMbHcnojEzwV8hFS)WtwmP0GALmc0vn2zBd6PDAQUNND6lVuDmDMdcyexNKG7vMeCE3FqzUUmtBfrXIAP55CG0txEnpx8gxF5nhOLh8CEQ17zSMunp4Tm7KnrlBGqcMwAIuxh47y1LvE6BU9(umVFdOc3XtXhqkUkjwnluIqS(eL1JvJ(d68bWG2yMiWc3sw3m)PKswLC)1vTzfmObym9w03xy60sj0kCax9oQRm)ogxWCQ1NqSTJH10gsU059FF95RGYPSTyoAmjhC3h05g1tpIXZuWjHw(kFC3sIIXSxJ0RxEgb(xfygmh619x5grC4KiFWaLOk9Ljas5otSmjC63qJf5Kv7cwSGm9rXeTMSHAvsvXwMkGv8PxMNlYCFpWEc1Mp(P8dJi8UCHuQacePbIU1W4c1U3wBAzdl3cTyS2vVQihmgnhJJYQG5n1wvvQx(1QaPt5XAKSTQ9DJQOJwjGRMsK)3ghqnw02fCaRNVaB4sMLIW9V8XADr5c8MlpeRxoVVqjhjdEMtPZWENG7GEm5haeY0pFfwpgA3cKYYwgLVQ8KgJVgfNG8aXu8ttdfHUaOLYcTbL)razoaCx5860XRLfqb1ZwYxDfUPin4VTyXrTRG)rBASPyFCaU3vVnS1BqAKCy39MxvksZtC7i1fR7uVShDiEiUCCFUuShXWLvW2q(IXtEROtMzpfMl9eZd9z1uQ2SZvxd6Jnp1kCi7DUCJR7pkORvZkUgIPLT5VPiMbIS(1bwEFWcoBKu(VkFpqN3dyK1963t3mKYdK9GCXp51ZUZO63tSvYBCF0JtlnYmh3ux9nMoDF1RRTGTUOgmIgpROrcebsWl6iOmnzz6ewR4FlzQwZ6ZvLjJW0FXhtAax9DczUvZYm2GeuRzGIGpcl2AB90SkDE(gMMj5cUEZY1zFRgFRpiJJGvxXKhIvw4sRj1OmlI6iv5IRzF7w4h9hktbz54xhtXzNxQzT2iz(qNMcQTVx3o7z)sqT(KrzBzzFXSWA)fVxtYbLUC2uliR1mMlOUJa9WaqdH7btH5AcUzcrqZlxoxsVSD2XerH)BVJQ20eOHbVBnM)udeG61wNBm218wPLNd0knVsLexvxDSnQFnv(yHZCNDEFocvteBRxXJBcAo9(KMPxHlmIu6EnI2a5hXBrkMasjMatYVYsnAJaMbGFJWj49JW8i5pLCoVOZV4)tr6lrkG2wAIFwnq7TJXlZZrY66qG)trJcSjWCDwyD3vaTShORQiNl9x2c0Gv51swQS9UUcufv2MQCPvSaGX8yY8dcYKrYX3AAYUHom)n4pQezI)mIFtMVs(iJCDF(QkmfnRaSIanyVrHKJigsUpVpi8lTdPCFgd2bS(6F4OowEzZma1c8BNRGwjnbMAOxnAD6BJAcAElABdNtfj9SA7lzRHpe)MrpPu2EmgzE4aSYhYqmkt3apUIpRCCh3G3zwt4k3DDLwQh0Txwej2tSjlbfWORbkz8r)AqwiSRcJXrl5G3yIk(HQUewFcuFFxdrbQM9J0BBgUczr9(ChoJOkNCbFyCMpoKxhkZULvUBDQufZGYVAyusYCmb9OALziwpKuVxTeEQLMtRYC2gMk2iOXfjW(r0qbweYVpBiFFZVLdgF)cPTj8lvVw(ZPm0kNWBJ(2cLFpZpbGup75STZ(6jfQpLvO9Tu0iWVg1sLjtLFhnwrZV5KJQpgOtenw)VrhrbIwKmZ1(CrAhqXlVF)Zcp)U(bst0VWZ(5buEce9QDjqjlkufBkCl8AET5xn62uFs0LeX)uY1MFB5oZQxlwgDEMlOxrsBHaCCdvXOnvSSPIMDAJXpCQRkk2T2OQq030y5XwlcjWprl9xwCiwyUsHjrSAjj5SkhyU8iCnSGrAA5lGFkOkfZrSyLL6OiXxiszj9tYJHGwSa76S3GwFTEEmiM4G2BxNJdDTE8(uZ3joYiQ0ZraXvbwT)8KfgdSdcwSaixo)QU23kZY1ZBvoXBK2gPC2rhcnO9s5EjoqCo6CG0No09n(Qj1rkcjB8WAc)nZJRj8SQrUpo57j8swNt0J9ZqixXLYc2QGKLuZyYdSuG)fQrsWA3wHzBWGdXYM7xKwsEdDZ5Db07)FVCTZdcdce(FdPRGRQlo5KdStIoySjAAsL()xpEuod3HiP20Ts4XbF3JE947048Qor5dLXwpVpyJxpvjtc)6OiJdhqOTBzSOIdDbpGg8x008suENBC5BBeZejXbaZAl542SDKiHSaLFhX2vGUyWFpusPYZ4oyEQHK7s2V7dnabOuG7uYmzOdBHa(7y)Hqk0Tfj9AyhHkEXcsCjPQE4NQE4NC1GF52f)BWpjd8JY0m)HHIOrzj4Nkd(XWBpLHFeeb0kb)uLKkNlIJxNtGmyxfSxID)M49mxPocZESkGDwzdESHUnlJEJT(Sl17B)7J2LHyAgsJt1QhoRZ8S4uZra8ZNplMUo7QQ1WsweHjICm6Zt2BdJgTU)XbJ99J5f]] )