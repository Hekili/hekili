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


spec:RegisterPack( "Devastation", 20240904, [[Hekili:S33)ZTTnYI)3IN3ufRghzjA7e3(XY3ex7CnDUxBNiF9M3Vyjkjiz(cfPosQy7B8O)2)S7casaqasQV4KE38M7ARTj5Ifl2VVlaUR3D3E3GP(zS7(vVUEN29h6EANUVR3pC67UBq2tlz3nyP)Kp7ph(Hi)fW)(A2x8tZ8ZcIJWN9uyS)uegPXRsMap)(SSLP)4Xhppi7(vJ7mjEXXPblwfsFXKe)zz4Vp54XHXJpo7E2d(jpaVAq0XSO5brSJNe6NMoCr80vHS0J9xgI)Zq2xI)mlPZKLlVBW4vbHzFm6UX2W8Z7DkGmlztU7x7D6BHzX9btNY4VmlDYDdWx(nDF3B8E3rRh19hEt3t)X1J(7lriLUE0SK4fRhniyXpT(xw)l5V7jW7C79S1J(h(jW)Iq47gegKMLItEg(V)vIwYI8hhYME3v3nWFcNkXYyjrbzpnmDvcsizlwg)alzyw8Dd6D3GjpnjKnmZhEgaTFf)ljbWNe4ZbXxydzrSfbi6Dr)1J6TE0RxpkZpKfL1rc70HPl9J6ig91JE(51JgVA2Sott8Nhhb)lwNe2c)Giekaq68UZwp67xpcivHHdVhwtHzxRk(Ol5dT5NyBGwTKa1HRhzI)amoJE2b5ZGzXrzdJNnCH)8Gj6taZV(scMNOo)D81Tje9WgsSAt)FRJiGWV1aHTdfo7vsWs(A(nIxc4LWfDGvBvkqTs8J(86rlItZGXA5YWGj4hdGogbpXb05UmGJElyL82CwjpI64reRDKHYRZ2WpzHleN(NSft)t28PpNt6KMo9BepRBAeoGD82cQKfslsKo1GiPsmo1nnRerkd(FdMNWaLKwuIPXv)xX3cyPrejLyPNk4DtcMpNbQgFF0KaGcTE0hcjZf5yXcwIF40HGA)004f584YN)fwYuFGOYwmoXhTJuGce(nLnZFvywTy41SqFqOBzmGcbiQEl8FNTE0tXRajUeGA7poEvghRhmy9O3WfhdHpkHfcg3qKFwmmvIxcmlW)9H7z43rq4b6Xx)P3C5hU6nxoyWBUmjwAmSGxZT(qGfAsCC404hI6KEVFg(brZhcgutO3YLoiVCnuJb6hbTzbZVpBOQi4jNvqpbca(FTOkjgSGMYYui9(asdpf)PWvihIedTYg)xOjYHkteDoSIxfiTNt49L)f9pywqcB44eMF29wE72glP)Ha)G1mGITEedrtU1AyPbwJJypc)5cKfwXHNngwrFio5Za9fwlPLC0a(c)hb3raB8JzzpqCZ0Fw9RNam1(rtPLCy9xixLc6WdMhfNqa8NU(tWtMnJnbXO0SGfig1HOMd5EkHO1Wc4AtVwLRfs4SeiBdboYHbtvzYeQIcwSa8AcKCaAwwYkcofAKALRYAblmBOFYI4eRp1pITcKb9hhecRKQg14YDd6AH9GXwwAz8cAzSfsuszrtyWBnlysqwUdeCBPKiI4vgoEvsAgW)BtRM6egvzbWJ(2jGAqyLagyG2D3aqveOqE2W5tMsk(Le0)5kqvLbd1NwTuOayH)NzcgGe)GPHm)POe)9GP5NqK5mh2HM4dkI5)Yq0jqURGI1lqxy0NrDRaaERZzJnPCWegSggaZh1PqYQiNJLFmXx9oh4zvFAAgxZ6Yeg4K(yFR6wRxzHy22jRxhWY0qCDaxF4kR(g)WG0olcssarhWw9mWUs2Qe2uWajifKe)qQQuM4Zg2Jav62P5mFS9QcX(28WTHy4vqmCO6kyMktTKG0XGAkn)PS2uOfzvczaD9OVtXeHIPNIxaer6YNxv)EFxDJehqMgAUMnjykdTQem5(CqW1uS0paDfac8dm)NpMGjbq8zgQZaSqdkIxH(Zr2o6v875keKSj9CYcnKfMc)C3oNzN3m9POj20sQSAuLPKI1vcqvTY55yLZ7R2kN1rkFLZc5sqBTO3EdKCjTgJzHGqb8Vshcgha)AIqn(4YCznmrpTyfdK7GPYxyHK3CldIMgYS9YPlFAb6)Es6WhyJnJzu6gbWcvW1SEeHIChAan1l95EGqwTKuiWdNzI)K47awZPbFb4NNY)sUxo50X8xNRRaTpVmjgF)0oRh9Z(CCiikdmFs(4SiEAWSaKeC4KvaTjICzUxNZESnxczoyoJ(O7bhtX3Bzsa4Segcm(yfqjNzDe5uX6OKEF8Qqe3Xz59(rZXjcIwkVDXieenbCeifjDOR7tzIFfgI3J(jcFb)R9vhdYnFm6aFfP9hcW3nor(tryOeO4Iu8xsZ192Rqgf8LALFOnR)BaBO3gWg6TjSHE2ydTPHOyAy6DXgmniM(KvJFAi4QE4YHP3tReLfmaDUq4TiN9qyT0pjcKdggmra9s0y2JtcxnL8958Th78Aa25TXyNNk29d7MIAjhUQQ6dqncvyN1TQCCIvNI(A11FS2lGF7WIhwK3nmNfVUcVtYFtliexAJNvUllHvwTOFS2l0ySY0bs3yvpfSs36tVCglpCfVx3nMHSxNULsWJriluEd7LhmQ4DbLr(yQeb7gASpj9gIpyi93rCYMF9jSAd9CAcWbcb5HWzigRrr8GN6mkDsRkpYCuXpMBdafVhwYi7wYWPfV4QLGnn6bye1ykBEF8nDO0b8bkx8lqdimkyV1JonLbRbPm2c47ddYJElfcLplDzmA2BmgRFq2RqlNSKNi)WiJcb4kCkGsZWK4ddWplXjcta)G55yiIY5lmsXrtt52ghZMtr3ItOXy8sCtDyYSO812ZwScBkbovjpxdo)fJ(o4wokVrjJqpY)GiSCmd55BmiA2QumeZUkYJGyBx1jkkMXEetuKF4WLbecy6eREQgrBXdicneUDsi(RVFQ)YmXa87azBfgAFPmIKYF9H(5VDr6mCLUreDmDASeGX0wLMfNSqldkhQvBGO5RcN5kTXKPgyiHvhLIpuGv5daHpUZDGsIOlJsK1l7ytRQWKc0ie8BeS0nJYGlLJau0VIcCzKjZQteVTaaejivGC(jt8Jyd)sWC1KvPoVCKK(wLtE6f80QOXA9(F7g(lI8rygrocDefZzi(pFoadFlM7v4cgMTv)5(OGdfxN0VuWB5q0dy0)0e2dW0ldLirh0bMpg(OFBj(x4onI0f8LNrkzqrrs21x4Z88W4X(HYHGlrZ)qFSMKm4TU5kB5KqUeCFmWsRsMX8znK9fk5EWZwq5kmIYp3B1sch9LYvG5tMQx7HUDotYLtV9cS4StdsrVWNNGUbby7KpNASew61QUWE4Q0PKOGrE8SK4bTLYbajEkMlCHyaTUmbG47h8(FVuk5tJ8xIVkMQr7cDvQs69t(NRcsykboztjbdtQc4Toj(yr6sB8m15yuTf)XRh9XKayg(jkooj7JsYQrUek72ZtcyZ4waa9SrPeiCNWYsiUI4OQav9IRbjyuJtOK9QTklSeHzPvjJ)AjHC24QZsA1PNU68Bxm7vsuTT4zkLIzYACwmWaZejM1R(IV0vz80s6VzakARX)DSQWzbl56dMtPBIQYb5rdQ6zEsCZQTKvvFBCfoTwKgCquStb4lpGuGTILAlmhT54pr(O(bs05kcGK3xGIdEndj)usXy0pECO))I4HbtkjOZxaRDkLuouL51dWQYbRob)lYU(pc6yJqnTCVGXi5f5MqScjJHpKE(5PVMhypWQgVc0mr)i5IhAiGu1ZD)7KUPnt2rZ4VnjiBLewwOVkRZ2LkXGy6gUPFf(rblIt1emANN4ohS0NZbIngzATUKqAP4ASSgB01d)FlZ)jFzUKEAZMfqHlGlOxksslCbxFfFrksweECrL8SH(lZJ55Ve03HUEmlm(HIQfA4MRdTDLRTi5LNd99LcoBR8B1sfljxFiQPLhUW)XHIx4RNRTdi3HW(AGhGisBMgZsJEvMk1(MRosXZbcBWaEjhFJWIBBnaXcAX04mv7ddN6VaxDYcMWl3UzyrMT6G2mxuqxJ3zO4ptMEC6jIEFY8UILwEOpwdZmNlrX90sl07QFUw4LSfJPexw(ucRA2pZv)l5UmZDKpxfIwVcOXz87pHMFdJNhmbcEM(LtV91YF8e8hrz2LH(prlH)rm2YMHKYC(7WJhP3zKkDGuWds6NUYAWQgtSQl7Tkf9l5JRgZVZjPvYSR6HBIn0s9K7XpgBnj)czAQzfoZb4n9OZAGZvUAQjDa6lIabrlwtKpPKPeRDqdQqadGd08qo8DMcKSKuejqPN7Z7BloURi0rpmK5VmFILlc4QloCQHUNvRf)TpizTeddyTIghm3vit5pkSBKZAkOkhL)t8a3X3g1JrrNX7jiKmnw4Xj(kPXW8MwcR0H1)NymNVtfGsv8oxcs0NW36uDsPfF8HjjRwMnet(VOFMXWDNegSeN3TkBSRfQrn9Y(ETo0E88x698ZArXdEUXGv6NgcC1brMdLYJWbCBGUgpSRKmCjvp8CMRIum0UgHzeZe1W1Z0FZnxktA9rg2VQcfd5RAynZz04jOraqE2geE2cgtXy5(FxfmHkijOirjXe8gkP6MRKsXPw)tYRz5hcWI(1mpvZDvuvC2qrQdbELhQXeQ5fiVprX5IlNQ8)xRsqRLjbF2SkgFaq8XK61zIPK9MrvwG4QY54uqSEX4GOPSKHHXXlWUAbJjDokUpKGB5UctM09g8PfKu9CIrPeZwq8xxavvVOCrMWSM4hsJlivMDF6qEfzTXrBFAubeQe3TKtndlIkLhgIhjoj3QyEh85WVCj)JE9L1T0yn3fLJpPNsakhwrMxq)(mBTerEV1DvZsYWTaRt72mFnpLhLSOv6mkNEE8f6)96YV4VsLWxyml1vc)wfXdHL6h57Pei)7FuOy6MVq6o(54KG)vC0rKbmruafaf5nbTZduCI7gE3zVE0Tj(Ov71J(iVqCMFBrcS7iN8oB8adBfv3vX5UbwBFcFb53R(6DM9gqM)QTBmCpxFTVcWEUeSvLXW2ni()IjUdpJRmTJeZFb)M7LI6s18v5DAIjNYpDTsW85UGXzvpYK9WFgLTLCg5zfVa(PSPDWu5i4SOneJ4lIZOwgI(tYIZlzWC1fmg8xU7DHC6LiDkUBbII0PyPzdQfm9uaJRQC4zJF056wPXK9pxbolc0XkA3NIDZut5BCsHTKB(8CaZN0G1O0W4m1FVj5Q2EFFiiFTQor0TQFBu0QXeRw1WYuybAhrPk2GzNOWtCWAZwMPOf)O0evh)DjYArtYXTEB9LY7zjBUOxWFZ7jmdmPu72GZjdoUwsMrJV0sN8GmNVTRKEKJeg7McEmgDntrQTCZQsBDLJ2APA1tvm0OERsVykJIGcNKApsm6c5UgzQOdppsMgBSKYC9PaFwQmOdSdKX)MzpiJDrPWF518D4uHY7t1ZvJHz(JkCMixX(04vJr5cKqTwPxs5osehXSOUFWGJ)WvcSuj4BU1duJFsowx0Ip2keNHUfVTxxsVV16sSz34BPUKEvPlXLrUQLk8C8s9AIUep76sk1qHnwxI1Ev8pH6s8AcvXWOQNTYiVjgIR0BLw7thN2B04nqv7hNHkBWces6NWfEvhjl6SDQBAqmwUDSjTvcFpJJuK64kTi)Ezb8Nxp0ghJ640GJTAJxLwUkjY7jxt)kSqvbFCgvp5ksSJwRIyEujO6WVP8Nw2d2xhVbou1w4kLmhJtItMCpQL2S)(4KOQRyMzEYuAvc9toa)La3hOpHsfDXHgaYXTkk7yoYu9riGg91DHzkuWxdPEVTX)Zj21qsVZ4upWs(SQzUwWwxXg5VYPD)94E5F7M3NylDs1kdDkxcmT(nspUX5F)eUz0)gVhj59uTORi1B0AGhK3G2JzO3khiJD)Z3JBwIq2J8wIdDNDyiAo)UgvN)Qlnm3tMwvwgI3wquCJlwKwkWU9xJu6Exkl6EtTfG)BXGbKFSKtypQgGveaC3mb9BsuiQf8gGjIH8TPu)sN9aZNxhEo8t7KM96(hZ7XC6RpkywF7ZRloPvUvf(esmlUS)jToqBEwDIKFr6CVktF6NyH(pIGwnBP3eLHBbGpXOw3eNKiN7e)ikFwjGh8aWOZ(bFApFEFqYurhuofdpIYMFuCYcKKJBiGaIIcQhUkmoEA4km(mSm68DLXhf9c)X)bTZdWy9WK0ss5Zz(jT35UB6eVnR9MSNd29tMvZDfofS5pooAvANShEO3WtxoX0)HkAi42BEkApSzOOO5NSHDT2imBx6lup1AwjzmRnHS3ITekFlOSE0hUYwoyrBx846jRxCMcTE44MR(Wrc)BFiiVrtVzqhNTIWM0BBnFrR21kH92AFVlQBWAvNLDCjvXf8snYQz6onYPtc29udOE5NNEdG(EDCE3vnXFPmvhVN60R1J(dQvVS56621lz6Iv27Nm1OuDrtLrRwrGS1lGOJmKXKH3Zl(KMMEnESS8mNyuDAb0kW4IY4zvhHtNlpZqlMvwfLUJ0DULQH1wTHBKE(PZt1PuR7y88syUIhfwavBtIUtQPvMaZKnLp7Tnu35SrjTK7U639yAmbJXJCKKPKbz7ncjzcgBllyOdzwBzqnGOTQ8on6yLnZNt1Bw8MXgwRUl3uE(WjH(G7E2YCJLy9KnPe5uxhWDc6uSYpbmWdt5sTlnQLpVLPrlax)Po7SNfFR6B6kZeH9MJgrxdfHv0B0ntlyTkXAGm3gP1SsBQ7P(5U69DtLnbxPE5))J3C)XBURULUxzsQVP)RCRF8p8XA8t9a3hU64BGfA(UKMcQA6t8f3uCJ6XJjnsKW1)k2AbpW3nLjS0vHz8vtkPSC2IOyKTlIV9rcePyaMmk8wOvh8KSPcd1f8dpaOQ1ULR0cKL84i8kOQCHL7mWRv4ou3m(uUFSzWnpxgob)BQZBeCLFZh07STPo0jP29g)pvu1Ms4CfyXLBnPZmXr22EQehnxrwpUAmpI9pvYeZJMG3uKPC5h2JbzYyj8Wq5sBq1qRIkApSdLilEtvXL0MOeLC2vTbALSdgBF8Q2hjFBNgo6zvB7zKcuEt36lSOpZBLhDhyJvEIX3cMs(cMHWo96O3654hQ8qE4rg)zplFJs6U9JSS3K5VvPQjl77H2LNuwpidKZl11)sKhla7B6MdQYKWieFZB(BXElpFJtjc5NVPfaty0rGEz5u1DXHK7El2sfLfwQqMRY8y8Z(yso5Myffov1HnC7JrnZbQy6bGhLoDa3J5RxYnAFRYl5qAKdA1UU3RRctNGUQ3CL2j4kUY7KbvLVZ8L0ch9TM14X20PoUyeq6M8QnXBVv)1QiTA9u7lbX6vq0W89VqhNhzcL2SvnHr5WCkrTNFThuhBLz6Q2Md6wTSDyU9rRm(DHoIL0wKd90fMMc3uNbu7yj2Z7BkUs215hVWYo4gl4U(UQJ7sG3TA2ESUU0urk6BTUz36ZrGw2BPiLeyt7FoBBFQCsxnBckZ9MeTdKeHOCr)E8TavfPRXiaUTC)hv3OOZW4ChEQxUoFmg0RvEr(w(PYqNUg5jefY7gK0aR8iTr26jm64BKcTk38cMU)iquIMSW7hI50x0jE5B2A(VkQMfsKxREgxfSa3uh0rz(4vzzX0rzytxcRFFSTnBRS)tztRvDn132tRMC)42AnaouExAxCzzFnbAdlo3o4kLu6Cu)PttL5QHFUOj3JibzVs2nRIebiohLK1PIJXih(hVUHB8FR6NuCyqzTfrm(6k6fGq)wHdfXrp94Wq2C)j6Pmej0vair3ewdqCBmXZDWq)PXAPwwm3yZLEvDcUlsmWoT5eRyIvSY4(qGtdwLP1hurKTvESVxSZiRmMIIDwQrsspIVPR4jdOiZO8ma8rLZyPgWZiyI56kk(uWqR(2bK9iBYkWYh3JsJeHtbjHuzmfV2QhSkKhhUQyOniGk)r7H9uFv2otQf2ubqFABL7kmipkmiRr5RSajoi8b2C6qZIFDsDE33Hz2kbT5KkANFUDtHP0xXsFfQzJASKPYEVXFvwSOP(5NAXPDw)l)TaSsW9(rWADCemm0JFLKoNPEIF8kE2FS)q5Aa8sh27X21bzTsGBayRLh)BmCF5Oe7FihVKXBY8uUxxVsNXe8L91vcEHpkLJZ7cS1i)EL2dS0XcG4fVSFp1xRmaxTS1H6yv)(N16GQwOE(z9p4Ydp51v9(T)(dRzE2UDjy2)T5iHtspT(8VfK0)9GIMZg79IjGCYxBiVdQHw)lw0NNMTz6ZDGwgUmzGyoCOQHt5cV1mbBj34mH4PUWwJWBlHVoc)9Rn8pZo8leonaC5mS1qiUdSvC4(w7WvTvTmaRTU4QHqDVrFDaFT2HWu61wRs0q4A0cfgq2rdw81e2VZoSv7aidaBR5GAiunA2jt6S9wHQHWEhX4Z37YDoGyE5InfomlJCdH3oZ56aU7fUlhWEVjn)d79vnhqCRx1CaV9gfOx39mc3ZrSfBpaDyYuwxytEwJcj3uWPxZxdGAVGWnf0kLb2aUwkqCtbQr6DmaSJAXvc4omnyKDutQH9CN2uGVdsxUa5lkXyxWxhgBSLFsdGxvkmB6WSd(b7eK7d3275qV((HTZa4LsbH9Id0Q6rPLRYc2VVx3wMbA6jr998yzDOkM5V0gl8CLPR9X6MNJyUvkEGbGTuwHVoa1ryN7zPAxdZoiv7eK7dPAphwQ0QsXRmT(BPghnfWLlEHPIFNv3O0q4ikxJS7)ktFnSM7)cGBnbkI7UOxTpYIYEMLB)ZX9YWWzLUMFd9Uzu2s60ehCe8JcgH6BXDPyoEMODEXu6L0niT7dG8MxBlan)Kv8PQW8Ixz)c8DaRHNLkoFRRcZ1FT9)GSdZak14vH7YxyFc4DaFXILwf6kE(EeSBoYw3DZSLbQbFIUHahdUxtewD8s77bWfHRbG2LaR1xz)c8DaRRsq15RT)hKDygyxO1YlSpb8oGVwfBl)89iy3CKTbI2Mdud(KQ9Ejxvurlilof1SO7X278Ic(xma)ncVlf6URdSRwhwf8)UVZwdJlFA)Up)Cvp)7(UQGD)UTLtXTe52jCRoulNYwkeQCXO6xYS)oACe7BW)Ib4Vr4D9CYELywSa)9gNSfyxfNCZqUDc3Qd1YPSLIupx5tfxf8wudv9BRXLu5q68Ko1(yw1R38bv)iZ3(iv6D0aFPKDNZ5VjKX6E7MpKnNmw7R38bTgYO93rd8LstU6QK5DMV91jlVvZhcNx5(2hRQEDTbTug6vjB1oVC9wnFiA(8Q2xxBqlLI8DuH)lm4BaGX9grh)ONgoDzAva3171q8VPddAOy4Md(gh8B1rxVhgaxbI4c0BRtVVWGVbaUzlPUFVgI)nDy2koNnijQBhNZgmanKZPKVGh4mYbxoI98ZUDrRAF0CjPInuBNZETdzb4PwgW0NIM0U9LhwD8nUwHnhXE1oI9eJOK8)vKUD8xD62XVa0TCosNnvY(RIA9C13OY6GBa5I6JVHaKxeodOPFlw1uqTBnQJREPzRNWU610Tyc7auB5eMk(2S4WW4hO9WTpWAI7UrwX1Qr(jueFxfTEeUfWO9rR89OtPZz8thRI3E6u8LN6N5p2pL9JR)f(bttsqMJQ(5hJU8Vl17tuj6DRVJF52rno6GH9wtD4QF42h90XxTUrxzp2zasLN4cMo7z8DQg1vd7TVI6U6J3DNt7p)DdRRUvDhqX9FdW6qGDxvW8YTLK65Ojn2pDv5l9oEXLTTIBiBdix(QZUeiDiJj2RUgWZ4EP2eyEoyWKNBbMKvJBH3sGZz)vV1DzLv7QcNh3WnVRRD32M7YIR0Fw(E3jhSw8FV4vEbbETGT8vqtjWA9vAeoVDaVwW6(Yw01WL)3R9EA8vUnpUtle1z7DNaEdalgiM87SasJh)cIRVOaVwW28u(0OmlT7dtLzwYn43UeV9cd(68SChCfYDHgQLnPE1x7xG3aWwPWyPh)cIRVOaVwW28m33iHXDFyQuy0n4RxAPbLNzFdE3aENfgDxDSAztQ3GW(f4Ub7otfAqvr2aHLxuG7gS7avWQR5ZWQqVboL7iIbZlqnd0Y19RMjv0rCP7jOV)pulQeU7mwV(x(iTwHa9C9SFIli3nautolaVUp4pkTt(2w419pwM6(JWZkR(cUnzvnoIUGq6RBHtVWup)SLNkAlxRp7lfn9Q1NFp)aEXYtWuYQ(G6ATY1)sZNWEwNW2QHBbguUpKT(mRtyZ(P16t0NW13lPR)L)l8ubCcD2L9W9b09Mg)R5mv4nvD57P6JOtP6zm(PF(IGOv45tnDqO2R43faAJOQ8YaDu8Y(PSSGzcQBp()DilmL1VBNZok)2BRF9n04lyZwAVHg3K5R3opFl12BVGTKN92EJyIUrCdONs3QK5l98Rd91Jg)eDKsUeWESym87fcbS4NAEzkxY6a)10a8I5Dk)lPNjhrLxhN54HtzXf5BN1J(zFooKl)HhvQtdMfGSRhkUzsWdLVEDo7X2C2858tYxXn6Eccp598m(yfqjNz4v1oz1Z2OKEp)QWapVm5g6GFXpv7TlgHGOjjm)uK0HMoNYe)kmeVNQyfE0BkMufJXm5rVP)A17ME8DJtK)ev)kKdtkdlP5OE(MZLkVSMlPDVIgRZqVRZ8Ty8E6DY2MGKE2rYk7(pdDLnajT0UDBcsMFHQBJuA2mAgKgN9p2MGaEoqaRDdNX0EVGas(EtDEEQ686POX7fQdkQQXtCeOOrxnyZwFdBMIQ6bfhPmYyWT5zvv9vbPK(t0fpDV8BmiXDxS88jLo6qBWsP6TQI0IvNUQh3E0O9hIpsORc4RI4QtXsXad39afGSgiWMuXlUAjmU0dWdqvSS7Vp(Moun2)qs8cqjiQwMLYVcHonLnbVaMylWZF7GpZe2gsFGbQPxgNPF7g)f6YCfapPQnaTFKcO0m8AGegGFwItkhX28lJQ3kVdpt5wCgZMhGDhfoHgZ4hxY(4jaEAZ0TQDrt5hZosSLR7FkkzKWazJ9mvCWTBoILMLJxNRGx1dfK7epSRWRP5HldeSj5C9br4Hc(q(TzDG4M2Dy3CU9l7st()kAuBarBhW7QhGziVTEwp63beDfWaBhHyjt9HWSGWGapFz4fLCEisMDiKDiK3(lkFB(FR1HhOvKONFw(7k9LIdNbvpCBryFGjWbnVQWUvziJHXroVtxHBlrd98fzUxb0fsGpY(6pMUGtqwg82a5niBDAg)IsoK9f6OJN4yIxYIyCwm87ii8a94R)0BU8dx9Mlhm4nxMeBqXGPdm6WpHtesHKIpK4PS5b5R6MLJD1YYN)LETF(z8o4TL2vE2fNCMH0aivcygd5R4UDYLmWl3nqWohdwt3vdOtKpeNWV3A4KduhXc)hdwSAbkaNbQlKn4J6xpzAXn8qsHqgEfQph0Hqa8Nqjm2SzKFDmPJWDuPq6chg3aDMchk0p50)VC4H5p2(v)XBoV9L)LIxYYXVm8gOzG)l8WPgL(aN2fcOLUZRtfNQ73ZE6vep0x8dc50DqcLM0kejcMfZvHSDU0pYtWN36I7o4xoW6Cq7bL5JCtRvoF)vKITDGtifYkAVL8)IEF0KRsSRWjMslGfhJ65RGN3sCX0apDwWKGSl73tClSx6gRHSvVAPqQDHFUrn8OSpK5t3K537VC5tQZ7)5kW(7rk3l9GBu0mMUzbfNYpOHBGU1bVK0Zu)AZdeDnV2svFZKvrLFr0cgECCpjJpQMI1NulesZeQ0E)VDJEsP()HXAHIX4)GNCA8qaXWH43Bb87Iasmvg6f4dviQJJFLf8a4XzgkFJXGcA(z4J(TL4FHhxukDpqlVUdq5zYeRViSW5HXJrXe(qWn8Y)q4HZsyOS0vfQ6bIbmln4sps7(3GtLSjYxC0lP2Ynfge0AxgJJAPluOZcSGU7lkZvy)MZ4I3kyjL3ygTWlImbl8LyQiADOm9vUUXvkeAmEftD9x0)uUBPvExAyoF0Sjt4I6LRbX)mHY6SAocQcgstV6Dli39dqINFG9dYJuYiKmikwiYVcXMNeWMXDfdpLpt1CRGpW2fYMnwbpk4eAvn3Hstd(8Z2VNynhEf9skJOH2TYQblbMclxf6xuU5sbPDp7gX5E193ZV)6PCVq5AKSMt(SJYZZtInhu9lTrx(AusC41N89wfCaV1CyNHZtYVBh43OZYlmL3qY(ZNNN(Lum3mhx6AZn)2Ga1J8182YDty3Y9ETGcA7qs3EQbLAeYd30mAMcNHZ7fX2To0gRY5p)SjtI6kqPRU4)dzrGZc)N5fbnLk6(CQS(C9vCYxKmae6oRcvNt)L5X889gZVHfNfg)q(v3xNAupDGfbCtFOoHBaHSFGr3WdcaJpFAmln6vzQJ7nxDKI6AYSkgup5pre6g)wyb3IdCKLWlS8G8B209QbEEeIiUu99zAr8QgtRNFUURzO2wnfL7wG37kTsQy23jvBB8HGwU)D6c6tCxRX)LtV91YF8e8hrwYLqKXe33FK3mTY3H77wVZkDt9zmpWljpB4VP3TN2QilLkbCSTG7e58VOnG3TbG76F5dRtigKZueMXRYioPrC5(aAd5EdncVEFcM9JcX6CsROVIpADXnRAG4TrHlYdmEi5iJPWRe6vsJJJkPbqlViwMh5SWIrtOSS4(jsrtPLiGVOV46c(7pt8Lw2RyiqONzEZv1MFMNw6EpYruCL0v1JO0)pXyevtLPAq7g(vWspJYY5GB3iPk6QRd(V63(E93Nx(EhHJU8(cSVTRlqlAS3MHbwOB6l7sUWcpDohkpkorud8Gne(saMgqFt)FxfmHkmhiKOexsjt71XUk13kgQwgmRfP489CwnWHteu8Q99b6keVzEtqxyzkJOgRRG)0KDULf7Reg9byigtxMOZSIcQ39wMZAri8gETDeTJ7W0xG1Fat)imfxUmmyIixEG7bcqOOsGHPkq3XJJeUKaoUGS81Pj159m03M7xixxWqn9IfY9fk0MCrc1ycSxtiWEV2ZvawUiXEDAkf2yTOXy(jnbZRk0q7RsUMq9pPJxdNsgZ9gpJo1HGMAaQ6szG8vs8sq1yMMagMcmicMJ5ZqvXTzJfzgr6cUMSgQtEplZuINTFVCNGnBITwhuZL1FJMgEL5d6dwuCoX2Ao12oNindrprROq6CHoX2TNnCxr3tfCJ)1eQikdqiNk3L1eVxsapIDddD5qNmGHsalyj(HOpQXPPGxqLEbJI6jgySQxVNEtWGpAvuwUxroI1RbmigWRD8yggVZbfJskwCo0JMGm2cUP1pFp2OdHSh5jhmaCUdm8cXk7ke16V48B5W5M3sZL)BXFbMjO7GaQFlDLEMUmibZbTWjXf80uGxS0Y2Rn7bMpVexAZhEHCPVUIm)EsrmECNRYzwoXiNWgKR9CcMnG(wNYsSekSq)hrYJA6AVjkd7aGpXBnz6(s6impqruGnjSq0zsQ4O(u3qYV3T53Bt4vLmv7LiWBqF6wsw0Lkax1HxfghpnCf6CZRlvrTJ)dQXdW(ldlDdQ7h4d9tAVZjN6eVTl7uCYBIAQCRS8HxCQsWv2Rb5fN26WdsHWPghhTkTt2dp0B4PlNuyqTu88TB3Q6b98w1v4Zlo)5NlpMoZGamIBsgR9ioPBXKvZB)dq1LAkVYJeg1sZtJaPNU4QXo)nU5QpaCAXGAKKhcYtb(nd6ySMuot3nmnH1rlRHqcMwQJuxf4Bz1LvEUCV9(embCdOQSXZ1gqkUoopbDt8xkdt79usXwp6pODAUbTXmJC5ULSPPGtj3OkjHRTA3kyqdW8cyrFFUPtl17k3bC17OSI8WzCbJPwscX(ogwtvxuT66XzvNZdk5U2coP2eLWDFqNBupflgptbNeA5l9XTlikgZEnsVEfze4FzGzWCOx4FLBeVHtc9bduIY0xKejL7mVI0VQFd9LNCuTlyVCY07et0kYLPvjvfBzQawXNEzUYiZ9Da7juF(4NWpmAkvUdutJXTqEND20Yww3dAXyJR9uEECm6ogh13inZE5nQw(1QaPt5XkKSTQ9DRkTIw9AlN7K)tJdOclA7doGnZxGTCjZs1W(h(yrNOKi(HRo(MbYgdLCKC6tCkDk2OdCh0Ji)aGqM(PRXwtJ6zLew6QWS1fN0u81OOyKhiIxXZarOlaAPSqBq5FaqMJa3v6xLoET0fkOE2sGRRWnfPs)15loQTf83BtJnf7JdW9MQTHTzdsTKd7U38IsrQFIBhPUCtN6fnudXdXLJ7XLI9igU0C2gYxmEwEt5CSShdYKEI5H(SAkvB26QBa9XMNA5oK9gxUX1(7f01YPpxdX0sl9xveZar28cYkVpqbNnIvUDqZFpqN3xWiR70RJUziLhiBc58)Kxh7oJQFpHwkVX9qpoT0jZCCtD13y60(LTaZfS151Xr0Ly5v0xeibVWLGY04vjtynI)TGPAdRXxzMmct)zFmPbC13XK5wnlZyNkqfHcfbFawS127PPLA98TmntYfC9oBR1Hwn(wDqgDHvxXKhIvw4sRj1OilI6ivlNnUBUF0VTifKfJFvmfx0VqZALrY82w1fuBpV2ToW(LGz1jJY2YYHIzH1gm(G6KdkC5SUEqwRZjxsn1a6HbGgc3dMbZ1yC3eIGMxYDUKEr)SJjIc)DVUL6dcYWG3TgZFQ9cq9ABYng6gERKYZbQp6y51k6VkL4QQQfUrnWPsqlCM7I(94iufrSTzfGUoOvDVSCnUWisP7niAdKFeVfPyciLycmj)kl0Oncyga(ncNG3peZJK)mY588wWI)RI0xIuaT90e)WAG2ChJxLLHK1nHa)NIMnyBG5MSW6UZcAydlxwrox6VOFLbRYBKSur7ZEnOkQOZu5sRybaJ4XK5pDAQmso(Ett26YbzVc)JkrMiAFEz(k5JmY19XRlXuuVcWsc0G9gfsoIyi5UFpq4xAhs5(SfSdy91FB3wwEzZma1a8BVRGwjnbMAOxpAtAWJkcAEh6VdNtfj9SClqzRZqe)nJMxPOfBmY8WryLpKHyuKUbECfFu54UTgVZSMWvU76k9)oOBVOisShztwbkGrxduY4J(1GRqyxfgJdxXbVXev8hk7sy1jq9S2gIcun7hP3FnCfYI695oCgrvo5c(W4SyCaVouMTTQC76uQkMtl(QHHXXlWe0JQvMJy9qs9E5s4PwAoTkZzBykzJGgxKa7hsdfyri7(0H8no)ooy8nmK2UWVq9AXFoHHw5eEB0ZwO8hy(jaK6ypNTToupPq9OScDOLIgb(1OwQmzQ8BPXkA(nN2T6yGov0w8)kDgfiAZYuxBkfPDafV8(9pk887MVqAI(zE2ppIYtGOPPlakzrHQytUBH3WRn)6r3M4tIUKi(7JVX8Bl2gvDAWYOZdDb9ksAleGtQPkgnPIL1v0SZRn(HZDvrX2vgvfI(MglpXArib(jAP)Q8tXcZvkmjILljjNv5iZLhHRH5msZkEb8tbvPyoIfRSuhfj(crklP)K8CiOblWUo8nO1xRhidIjoO921b5qBRNVpv8DIZmIs9CeqCvGvZpqzHXa7GGLlbYLZVQT99YSC98wLJ8gPTrkND0PqdAVuUzINkoiDos6th6(gF1K6ifyj6)FVCLSdcdce9VPP3mGEu9IN8m3jPgJXMOHKA7)VodLLwgqKuB6Xgwg4nlmm8WZb20IST2C(AciRgZd5u)OWDqNDtp73mLCVqkTWQRQbSQn1hSCC(BnJOG7UnaSjeBGRnVXMwsDrHRXUaERZoRDC(qAS1RhQEZ7tLfjHF1uSXbcek7zgxLXMEvCan4VOOXLO8o3I5BRZNksmDGpTTeIBdwrmmYcu(DelxJ8fJ)5HCkvAk3XNOAijVKJhMObubkf(nYzMCSb7Ha(RJEHqGd2WKybRiuXlMqItjv5d)45d)yRg8l0U4Fd(XIa)OmnhFZGt8twk4hpa(fH4Esd)iycOvc(XtjvOlIZ3SjqgSRc2l9D)6i(mSuhHr3ufWOv2rp2qZSYO2yRo7sT6))9E7IYKMbx)KT6bADoonovCea)8(ZIPRhDwvAyjlIWyqosrZq)DvNuiAFEs2)5t(o]] )