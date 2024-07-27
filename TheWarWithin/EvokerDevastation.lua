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
    -- Chronowarden
    afterimage                      = { 94929, 431875, 1 }, -- Empower spells send up to 3 Chrono Flames to your targets.
    chrono_flame                    = { 94954, 431442, 1 }, -- Living Flame is enhanced with Bronze magic, repeating 25% of the damage or healing you dealt to the target in the last 5 sec as Arcane, up to 29,455.
    doubletime                      = { 94932, 431874, 1 }, -- Ebon Might and Prescience gain a chance equal to your critical strike chance to grant 50% additional stats.
    golden_opportunity              = { 94942, 432004, 1 }, -- Prescience has a 20% chance to cause your next Prescience to last 100% longer.
    instability_matrix              = { 94930, 431484, 1 }, -- Each time you cast an empower spell, unstable time magic reduces its cooldown by up to 6 sec.
    master_of_destiny               = { 94930, 431840, 1 }, -- Casting Essence spells extends all your active Threads of Fate by 1 sec.
    motes_of_acceleration           = { 94935, 432008, 1 }, -- Warp leaves a trail of Motes of Acceleration. Allies who come in contact with a mote gain 20% increased movement speed for 30 sec.
    primacy                         = { 94951, 431657, 1 }, -- For each damage over time effect from Upheaval, gain 3% haste, up to 9%.
    reverberations                  = { 94925, 431615, 1 }, -- Upheaval deals 50% additional damage over 8 sec.
    temporal_burst                  = { 94955, 431695, 1 }, -- Tip the Scales overloads you with temporal energy, increasing your haste, movement speed, and cooldown recovery rate by 30%, decreasing over 30 sec.
    temporality                     = { 94935, 431873, 1 }, -- Warp reduces damage taken by 20%, starting high and reducing over 3 sec.
    threads_of_fate                 = { 94947, 431715, 1 }, -- Casting an empower spell during Temporal Burst causes a nearby ally to gain a Thread of Fate for 10 sec, granting them a chance to echo their damage or healing spells, dealing 15% of the amount again.
    time_convergence                = { 94932, 431984, 1 }, -- Non-defensive abilities with a 45 second or longer cooldown grant 5% Intellect for 15 sec. Essence spells extend the duration by 1 sec.
    warp                            = { 94948, 429483, 1 }, -- Hover now causes you to briefly warp out of existence and appear at your destination. Hover's cooldown is also reduced by 5 sec. Hover continues to allow Evoker spells to be cast while moving.
    -- Scalecommander
    bombardments                    = { 94936, 434300, 1 }, -- Mass Disintegrate marks your primary target for destruction for the next 10 sec. You and your allies have a chance to trigger a Bombardment when attacking marked targets, dealing 15,929 Volcanic damage split amongst all nearby enemies.
    burning_adrenaline              = { 94946, 444020, 1 }, -- Engulf quickens your pulse, reducing the cast time of your next spell by 30%. Stacks up to 2 charges.
    conduit_of_flame                = { 94949, 444843, 1 }, -- Critical strike chance against targets above 50% health increased by 10%.
    consume_flame                   = { 94922, 444088, 1 }, -- Engulf consumes 4 sec of Fire Breath from the target, detonating it and damaging all nearby targets equal to 300% of the amount consumed, reduced beyond 5 targets.
    diverted_power                  = { 94928, 441219, 1 }, -- Bombardments have a chance to generate Essence Burst.
    draconic_instincts              = { 94931, 445958, 1 }, -- Your wounds have a small chance to cauterize, healing you for 30% of damage taken. Occurs more often from attacks that deal high damage.
    engulf                          = { 94950, 443328, 1 }, -- Engulf your target in dragonflame, damaging them for 45,337 Fire or healing them for 57,584. For each of your periodic effects on the target, effectiveness is increased by 50%.
    enkindle                        = { 94956, 444016, 1 }, -- Essence abilities are enhanced with Flame, dealing 20% of healing or damage done as Fire over 8 sec.
    expanded_lungs                  = { 94923, 444845, 1 }, -- Fire Breath's damage over time is increased by 20%. Dream Breath's heal over time is increased by 20%.
    extended_battle                 = { 94928, 441212, 1 }, -- Essence abilities extend Bombardments by 1 sec.
    fan_the_flames                  = { 94923, 444318, 1 }, -- Casting Engulf reignites all active Enkindles, increasing their remaining damage or healing over time by 100%.
    hardened_scales                 = { 94933, 441180, 1 }, -- Obsidian Scales reduces damage taken by an additional 5%.
    lifecinders                     = { 94931, 444322, 1 }, -- Renewing Blaze also applies to your target or 1 nearby injured ally at 100% value.
    maneuverability                 = { 94941, 433871, 1 }, -- Deep Breath can now be steered in your desired direction. In addition, Deep Breath burns targets for 92,245 Volcanic damage over 12 sec.
    mass_disintegrate               = { 94939, 436335, 1 }, -- Empower spells cause your next Disintegrate to strike up to 3 targets. When striking less than 3 targets, Disintegrate damage is increased by 25% for each missing target.
    melt_armor                      = { 94921, 441176, 1 }, -- Deep Breath causes enemies to take 20% increased damage from Bombardments and Essence abilities for 12 sec.
    menacing_presence               = { 94933, 441181, 1 }, -- Knocking enemies up or backwards reduces their damage done to you by 15% for 8 sec.
    might_of_the_black_dragonflight = { 94952, 441705, 1 }, -- Black spells deal 20% increased damage.
    nimble_flyer                    = { 94943, 441253, 1 }, -- While Hovering, damage taken from area of effect attacks is reduced by 10%.
    onslaught                       = { 94944, 441245, 1 }, -- Entering combat grants a charge of Burnout, causing your next Living Flame to cast instantly.
    red_hot                         = { 94945, 444081, 1 }, -- Engulf gains 1 additional charge and deals 20% increased damage and healing.
    shape_of_flame                  = { 94937, 445074, 1 }, -- Tail Swipe and Wing Buffet scorch enemies and blind them with ash, causing their next attack within 4 sec to miss.
    slipstream                      = { 94943, 441257, 1 }, -- Deep Breath resets the cooldown of Hover.
    titanic_precision               = { 94920, 445625, 1 }, -- Living Flame and Azure Strike have 1 extra chance to trigger Essence Burst when they critically strike.
    trailblazer                     = { 94937, 444849, 1 }, -- Hover and Deep Breath travel 40% faster, and Hover travels 40% further.
    traveling_flame                 = { 99857, 444140, 1 }, -- Engulf increases the duration of Fire Breath by 8 sec and causes it to spread to a target within 25 yds.
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


spec:RegisterPack( "Devastation", 20240727, [[Hekili:S3xBZTTrsc)Br1vHwmwMsesY2xEe1vwXYBCQ9YMY0BU6(IOajgsHZGayXlIwPuXF7pD3ZGbdgmda4lY2zlx7MejbGE6PN(9UNzUz4nF8MXEUzSB(nNtCo7Kx58QbN8QZF153mo7Hy2nJJDN9j3fWpe6Ue(3VLDVBAMBMFui(ShcIC9qqKgLNmdE(DzzXP)0XhVWp7U8PdMfT84u)L5b0xmlXDEg(7ZoEAq00JZUJTYnzf8Q(HhZcx4hYoEwGBA6KLrE5bS0JDJdW)zc7(OpXsgmlo(MXtZ9dYEF4ntnH4V8maZtJzZU53gE2lFfGq(EEm(lZsNDZy8LFXjV6foV6NwF7)mgHq66BNNeTC9TJ9x(ZR)11)Q8DofENpEhB9T)pUjW)Iq0Bgh4NMLItAg(V)nIeYcDNgW8U5QBg7oJtDyzSKq)ShMKMNGeq2Y4OvSKjzr3mE4nJN9WSa2Kmx4za0(n8VK4dFIVlhe3ZMWczl9r07IrRVD46BF(6BZCdyHzdkGD6K0y3WbIrF9Tp(46BNMpF(aVe3frHW)IniHT01peHcaKbV6813(JRVfirbbtUdwlHzxVg(Ol5dT(NyAGYJjqD46B1XFagNtp7a5myEuy2KO5tw6UWFw1jG(xFjbZtvN)w(6(eIEyhjw9P)VXreq4xQHWMHcNTkXpMVMFT4LaEjCr)O13MNcuRe3WpT(2LrPzWyfhh4pd)ya0ri4joGb3KbCYBbRKZMZk5quhhIyTJmuod2g(jdCH40)0Ty6F6Mp95CsN21PFN4zTtJWbCGZwqLmqArI0zAejvIXz2Pz1iszW)BCCcdurp1nZKISiqzBklReM37c0u4P4pfKd)NSe)WpXYgKnCaGFtaE9j4uIts(k)q)0bl9tsIsWvS5jWCipH5bKPLrWFDvknDMWTQj(SjdjqLAsuCdigonHyFDE42qmCkjg6cMcIH)CvrTccYanQzHrbL1MzrrbErRch4LNqEgS(2Fy9TL)1sjIYxaKioHpVA(9(H2gjoG6RP5(TSz(EGu5Q78NDNeeCv0XU(G5F0pL13(w5yck3bXN5Sesv6s)WCuQ2n0Jm)u87cazHDl9HWzwzPMWcsHF(KbNl5XgAsdGYQHjivFDLpQnSY5yzLZ5l2kNXrsUY1i558TxYL0AmLfacfW)kDc4GkO)mCMBqaUmxxdt4dlZzGChmvUNf4hUaSF4h6fWm9YPXpSe1INKozfBQUNdPz(l5oJ6wY1S(wcfblfpGuVLXaQhUaEo6uAbfA9TrZf)jX3bSME(3d8ZE8VKEwjDu(6CDf(ziNCe((PdwF7V4YXb)WmWWdBwg65IN)CFKeC4SCG2eMf8aAg)8p3NlHSamYsF0D(lUdFV4e)OeYri8XkGQyMnq4zTXrj9UO8ae3Xz5DUHlWjcIwkVD5i4dbwWCtrsxe8XEmXVcdXBG)2k4l4FTR6ymhFx)5QKBughF3OKIFkmc(JO4sH4Fbnh8xZOa9s3WC3aKn8LBpBOZgWg6SjSHoMydnPHOCA8QTFAqm9j5tFyYQ7ybXtsVJwjQlya6CbNCqo7jWAPBsiihmXFMa61OXSppli3JCg61Bp250bSZzJXohvS7)C3uuxWHRQQ(auJqd2zTRkhNyTPOVvD9hx5fWVDs5dlJ(c9C95n4DI8nnGqCPnESzxwdRmAr)4kVqNXkDhiTJvdvWQQwFgkzSCWv8HNSXmKdhCsn38RAA4du0JGpfcx9fVlOmYfdOeSBuH9jz4e8btO)oItM8RpHzfRkGJxcWbYIj4mXnIWQ5U5bzuCgvWW)q85cTQGavixXFkeWbGI3blzKDlXmiv8I5XGnn6bV9dOECqHD01GA7xS(23rzKzjAaHbMgX35SugSgKYylHVpW)tmHvS0vmWGsCeA2BAEgAq7zOLtwYdKFyKrbFCfofqP5yQCGb4xkWjcta)GjW5gsr(dJuuOxk324u2ckOmCcnfJxIBQd0mZJAFOPyf2ucCAMc9fyJEQiWJ)ihNT4sFdmQsbp)qmBCt4HD6hoppf(GjNOiqcYTNOotr5m2NXisDdMe7tiGUxSYXLL45cXzZwofItrxw4VHwPhtlbJbDXb4V(gp34mXi)7abnpiqvLPi49u(RpXv(2YC4GOJUxJ1((5(WsAwuYYYa)5knvsru4I8G52YEazRbMvWQJsoOkN4YbGWhD3hQycWokrMVmJn9ActkrJaWXrWu38axs9HcBzd56ee(O)RwivbUGeym6dfN1J7W1dr5GaekV5onkxeJ14XKujMJm03sWXh29aBGGpokMfY4m(43rqyf943(HxC57U6fxoE8lUmjQiZ0Lul7jP8aL4rsVZnlJBJhLOO3YwIbDKPnCkObGG2CWR3SjQ5f70Z3UKiykcPs4(FriU8DQMJNY3dOJNriP(hGmmtMcEhNDxT32QghqPiqNzicYJpHR9jeeOb9Qs0ewBt5rBSkk5tKoh(IlQIEP7N9xMVe1FMbARdlcjr5RN5jcEgwCtkvKb609xaQWja(ZOwm285uaaSIiMQ4koIwtkHRPSxOkAJPdBGhJ4sqRMWWaugy55MXOJbrGRelM5rjvSyn7FLZqfmvnrNhl4Jx6kTlL46dUG76HmU35gh)GPG3lGk6C)e(VmblWaVmdv9im1u4T2Z1jYSEA5iKKhADaqZ7gIzPlFAAgxlXIeyD1KoIQ6VtOv)XOdmPu2X940nykUybsPEt4mFgkz)UaoQvKqZLSe3aVjtr7UrlLIxwTBuIce(HtXg0GPPbO5SkBsknpwBQ(M)X1CfiODjKGDegYlkKG)diH4XJehJkLHksCx4IQjjHGIiGH4Ydq9HyKWjSvagKH0pmvaGXmg(O)rm(x4HNIOo(YZj3zqPfYjbxr05lcIM6gumeCxh4FOlwdmg8wxFvtfIO0gv15kSEIGu(ycXNbZP3m(n)En1XPHUX4RI0Sgs7VTb7xCt8kC(nkejbGIMuk7Di9eTKqtqC6VciZu(nRy)0IrbHEanwHjI)mpvlLwrNZWmOcHMtMkt1DlOINbkJvft1nQUNkvYjKICoibUew4mMqYwPWdIhaXXKKMjnEv44JMTnv80QbWk1V4LslEnmD61YSbbKmUKQVUrZsxuucUwn3H110PGmDGCz0pCsPdsConDLV1CYBPBilh0K4o1pagjtopTKfaorMabmOVIlEHOWh(8Ka2c3zpSbl2I6Yj5D6cXPcqBG68sfxEa3pMmnkmpDq2QvdNCw8mD)uxIfG3ZpfZ12cWJEMEft71neezD71nhweVnIhMWVEBnU5XG4R0XTllhTdACzTVyOjNeOO0YIGrVqa0PDVaDkYzqHonfeQzJ57YOEIY4vXtiB23Z8J5jze8cHLQPU9FIvWgEdUTKfurrixcP4UrZwlsI6Ml36EOSDvJ1iNhoi9nLWYkZLFMmA8oF064v0hs()cQ84oFqbBKIzm(4PbU)j50jOAmbtfG0idAx5TJXGsGvh))Kc54Na7WKPiUzjmmhrMYfRqfzuoGE(RtFopnZGA7OCGzM(rkHdOZcK7a8KrC6jPn5KyjvVt2BKz2sZnzsOq(q9m)OlR4g6dXPvr)OQXbyjojdSnsoW3DdexY7sK(kkbjojEEgOfLkAmKORAcV4ysfAX9ry3hvtDUoViNvuQfHgAbpWeolqxhDt8)9lnsywU(1DqSwAgweCegSIImqf3YNp1u(XnimO1Yk)BJ8GPvHQSX2es2p8Xc(WMF1gf669xuzGNmED9EArHDNLAQGlMS6Asg4TxXzrdlsvfYstXqq)Lfr8IUcM)IaEI5brRKoJpOBHwu82ES5(ZWKkFjgBUPkgSvbKAika4JM9jIyA4HlD)8eXlOPApzg4c8K79xu6iKESEuOEyuw8ebHZgViwA4ZYuPpxF1r8GlPSarae9UJI6netLJXAtuoL8IYuvUnXZDjspZ8NXtUupnwCRH5GtWMJSRubDRc2oVsjJeucwnwbG2cHT0per4YfHSNIbstZp4r8MQn1uYOBo2Z2Ngn0qgvcjPs8NneRzLqtD2mGlTzQLxGA1OqkoReaqnPGAHiWz0tlKeBlscJTkN9Yve)qcRzzttPLtVaA)(d4IFq0cFiCh(VC2hFEXpEk(JO(P4a3hiMJ)qQpV4D4PXz45KXBy6YZfYpFLXIBOH8nNbrvQwD7iwix2I0qFe5jE9o8JXu75wQ4IY(X5waVUt(fGVsXlACvPIUdGxoeutvvNb36N4jnvqGZQQ6WC8WW7TyMhQ4LI0rn7ngQmvPgj6ncyUXY5LKt(aRsK9ueiVO04dn4G7DdnQn6V)UcUiXWbgMPXdlJiY)9tcZHsUqbX5i5pXtTzE8rvlO6zOZCeb7iUxEPfLUZvP0D8pLxDsD)wboeSZ71r8)3imV4ygKPQjOinlfMeD2)hnXnGVDssEC2eSLme7XamT)Zc8JrkqV6wZ7HgGsVCKtVdX87pHDpPnbS7Te)b)WlDE8r6ZUdTfcFbe9pdMUpmHMe6dLYJWbucDdJ8gmGL85M)gY)dhfEWIV1IswCnXMZvDxMRWsDHAEvRwAsBTWHk534zYwaqEwNfrTaoEGjU4)l3Fg1JyGAfLeuZ7XxDFVQxQ5QvJG3gzVZh7dRUffImIzcmCIuL5DHqC13qtcxRmdk(9YR6coxSvyd3)mpbTbM4)j9IP)oaXNskBNlMsM7sCz5NAO(jEGcVLt9d9G4ucIIwInAm6GYcur4ecU1lPwrFq0HpTKKIQrvJGIAa06zS6TLqv1JtBEQ5N475gqJlisMDx6eEtYzIJ280Obi0iU3qfq0Bvpn7MkpgICmkrA7Ce1Uq9SgnsbFvv4lnYzpbE1JuBOsOAh2qmDMC6u0HcvDmZqBlyawNDs38x)mEddlkvzvYPHccuHn63OUQuyyIkuPSWAjLjolpKNEcQNeUJQ02V)EHIPRVN0D8lrj()zu4rKDkretLaf5nbvXJvCB7AEToxF7htCrd3RV998EJs)BlR03GIjP1EbvZ7hURdIIQMrJd3tzmsBfFW4fLqgQVwR8uzLdNTtUJpz3WsFCATqxSvwHZ0zIYSwtHZ2KYv86Qmuna2x3LkdidpTrkNPeI7OhtEd01Qf0XNLC6WjoXY(NCdi9wC9VX80qY0LARSZ5zOshvK0Us2RZ6cg)8BvYmJ0XtUK5r6sdUZZqL9s525LVa(PmVbywjfcs0gZt8frzutRt)PI2dTqEYwFyRjoX))M6Ewj9sSGzVjCltCMH2DTvWmubmMcvrWBvxIW66wTXK9VYbhJb6ydnCEjNxx5BSsHBQIv8jny8nnikt93BodW9QuAHoO(JhCNvHmHzVgBS6MkzvV27dTEDM03RfgW(QzgE3rPgjkw0N0xrZOw7HxmIIKW3MKunsE5gcH7(JXxs2F(fOIzjj((FqdtQ1A54CsJ3w7dkv(k)iQHkKLgVXcY5uRk1MkzHkj1elFNiw6T)3hv2nrfbDrbztBWhmySI2VZtShLoQOIoyRkX1hdCwPfXOH7Ho8VPVl6W9bKi8crtHwQ8)SQjZsZROJk99sAyWlkFkkjG0H1k7gkUFxrHmdMlgp(43DLalPPiVZg5wFqlgjsSUSj1nvPznDtoFROlA4xBDrMSI9TQUOHnPlYM54MfVCS8sd7IUihZ6IQT5BAtxKXTZZ3G6ICiDrvmQ7yQs21De4BdHTVB4Fde2(3id)9k839VSEa0kvPMV2nuX9VBd872a)wWgOzXY)kzmSvQIjRLw7QKsZL2JB2SoGs5N9xEo2Be5MvBvjYM3pxURbWWbWvE18(uEuiqBkceJlofNOGdePkc)m5mNhJaLMkMp)5TdTPryifvGJXoIPjnQnsL7TFsL0xGvQg4KZOnyuB7QiCNf(MzCX4)oFN2W3dWI9wt1ng8cwgFdfpLHAspOitFF6oCZ9hW(mVZAWGxNeGQtUPtT4vh39inuq2xwUABhxmudR2R27ff5X)GA17122CJEdn68)TaMavgRUoUHMOo(dS4LGQNf1CFjVbpdz4YEkTzDZwXC59Tfh(PGn9Np6y(wFM(6J8NpYm6FXP9KSUC8wWaF5Ot7Dq1PZwSDI2P9UKT2c677DPVV3L61TYj1X9UuRBq9VV3L289h0337sB)ExYwPzk5q0099bwG7NrCtT85xhMHhthFaJNkH04JwRN5gsv8lbIOcga6abWLox2UZhvGI1rfvtMZBVJqqmbT)GhAh(K5fGuEvquKxqoQPf7Ks(jNY7fhxfh)h0PdcMnBSQ90bY4cMBs)DERmCQZMTxgQufXwzm3SQF)vqY51BIGZR3xYn7eFEJ5YVPDg3hXnfh)OIz9TV7ktvQgpYq5M2PdnuoJrLw596RE3rIWkw5l3QDxpEG1Uv1MbztEg09fUwxVePQO137I2gmf3qSEm(2VPC(wBRrOv6QeC)hG7GYIQ4ae43gj3FcZCJlQOZBOT7W6B)dA)oySdzEI2ufvtpGnIAH7qnKbHYHXsFI0tZFUmzIQ06grb0kXLY2ZYSbkB(9DUMskJCbQBeiRjgSfU2rknvDpbCQkXkjtsiP98AyEVsQTbq1xNOBLAAC5vp3EYzVPHYu(vB)eKPYA9u8W9nXJmRwDHUGNHmKI9EpisfOXmiCgTcqQq8FvfYvJ78cRkOm4jRjSw9mEr55tMf4crWAmNxBO6ZgtXH8HAhAx1e1RV1yLmcCI5gVD6Av1E30F0QsIoWt3GQO(LrsSJB6pD9v25HLeS6mesCTTTrMqG22oQ1EpExBV2wlZDvSkvBB2s5kza4ykDiz5MaUkctRA7Yw0xHkPi4TFyWo7J6tW2T9RQi2U6e5tR8zlseFjeemrCQZ536(RT2(CScl()Jl2TL0MV4DxD81alk)etKcEZ7boBz5gC0nuKl9)g2KNR4N3rjS08GmoFiLVDodDyekWeY3t6(I03cKlfPc0UiEQw3GhdLCYRau1420OgRvpRUNO)NvxbLEL8CRSn)Ozl)Ym1zf8VOn3IqERnFqVX0oUSkj1Sh)Ftrv7kHZwWlxU1KoBzcU62JYuMNj(CUI5HC1YoKqrAbRnpmg(E0jLlvX(SVSV8CWGit7qL2BI2AoEhLqAErtbe1NOp18fxz)CzABO(TccBzZszAFSwIYT5yHU2Bw4N4nvDvxSJuEI23cgbVhllZGHdQU1gXpu5H8400(Zog(MsKzUBOX0)JVvTofOO9qmysY4zAAX8sLZ3KFx6a7R6o4VB7OytIVY9IOOSrYZ8arUg4BLwWWw9DZVMqsjp)wSHFRlcDJXDsBhQL0HYLe)Ll9drNjGjEwsort0dAO9vgL4nTubcPxAwkHH9SqBDBPY3P5MwWIPnmp6mcmPfEsmhmhevmx4njmxoyT8qjTy3DHv7oTYESNRF25JvupySqoQt2MQbh9Tg3w8J4iqpZD0dLlZM3wRVfNBIc1EnU5JHzaU7JlAGbgDRrqEXj5zXSxgcmiubzH3patrPO9PLhxk8FvKGEuoFT6rRT)sCdkshzVtZZYIOBqHYT1D7Bf7dRZS(4JfXBu5O6P)wShTf1rUEkmiqHctBZM4EtW5oJQArDTHBWBfnVhQuv2Jloi2A0K5LY(RSlrL0y6JUSAvG32Chj1kOTB1TUDOTFuaX31WWJlpA44I1kB0axpV0IqP5he8f7at)SNvS5her7iooxls4pNCH0M3)2oEObzucxz1tzPhrm(YoMgtHgIYfjJ11veaydas0oCTaekrLo2BkLVzm0O(4n3sJttNJ0IaD2PD5FdtSYfb7hJ9vGvDA9b19jVBz3Q8igylcXP8GBqljwhX3tZ8GBkZCfpIM3NGTm3SUE(Aj4I5gCl)0jjSQ72E2NzZYjD6lR5rm3vqCAGzaYuL1uH80GCwvvt6humn4gx7f1qEmiQRbafU5Df38PM6ko12psQLBdU4rpS5yU2BxFO9nhQXO6NnnQNvNvVonbpRtIIb0MUM1K3KMi9npm7y(6AZ3RMwjtB4LQzzdo3cbCVDDzk062uVUzCI1Y1LPseI2VRlBCoIfDFFDDxkMKD8gVSYC24bzsgDkXJT)bDPb)QtEfOtF8k3e0RTuXMEK7OQW31NXsFgAqNAofVIMz0nplsS1h53ozPdw)R)DFSqYd)jW94OqURDW3xODjt9eT9zC(vZpSGwdV0Hd)C)2GCL1jnaBCn8RmCF6Oe7FihfZ4BoGuEyopRQC)fJg(8gbVWZ96C8xGI0)OcNETJ7jXlE5OHQVwDaIhluvXQrJoV3bnTq94Jv)Glp80N3073)hpSL5z)(1G5OxkrcRKEA95VeK0)AqrLSXopzciN(LgY7GAO1)Qb95PzBM(8ZSGwvZDJoIzoZo6tzlWUKvudSk8OBge1cSqdSws7AhH9oGTNBgIAHMPbwlbU1vylJkuhS1cxSJqujOynqAiC5ocZAjdPgnWsXS)wb(Bpv(LpXy8tn8F1ExkXce3bfJC4(AZWvTxf1aRP2ySJqTsxhPbwJDKuhHRwNkPbzl9X0xsy)FAg2Q5evdWMYNAhHQwZ8PtNn3QFDe27igp8K9UGHnqkB3aD2x92qORaCNzETb49chMnGVRlywIYAxwWSaYTFbZca3BAZTna7kT1Id6BpHWI3ZBpaTyNSOvf0Lc06THUcUQTHGgqn3JcDf0kDMGgCn0ZcDfO7fhPhAXEJPsGOncnvLKUom7GZzwb5(WJ9Hwm8Sxc1sh41YSJ5Y13R5rHNIbdLPF0iNt6Ph)UtbQVNhlJdLCM780yEqhS1iODUC29o8qr5M)HtFo9idvFU)LdF8XdAa)E8XgQ28LNkg0gQYSP8a1VGWSftMJ)2BYuU4zXS2ofl7tdqTyPCpRR02WSd6kTcY9HUshR27vkVCnB(gkoDxbC9QoRB7ZAzPRnewsKKwbyFMUhgglpBBaVMAPdQly84Jh2uLJVuTQXLYTwqiHKNHAflEszDIf)HA1iUxt1h(IrN3VNEc)hwqS(3Xz3quVLXC5gNWMHki3Wu6wtpL4eYHFQxjmnNXccyZYKCHjvoASQ9svD2y3haSPYWxClan)eU)HMW8Yxz)c8DaRHNLkUzHAcZR(A7)bzhMbu1KAc3lEH9jG3b8fl6FtOR457rWU5iRF6GL(jjrjy2mNNaAgYtqVJJadVjrRsnmqD4tQAXWYG70fHvlV0(EaSr46aOTjWA8v2VaFhW6MeuT(A7)bzhMbMfAn8c7taVd4RrX26pFpc2nhz7GOT(a1HpPYGxZ9xPQOY9vI4aJ0GUhtVZtk4FYa8xj8UM762ozc7DytW)h(bt7cOINo6KhFSPN)d)qtWE0jYScSLi3oHBTHAskBTOSKIrTVKz(DQWrSVb)tgG)kH3TZj7uJzXa83BCYgGDtCYDd52jCRnutszR1KbsLpG2DB3Dmgud18BxHlPXH06b(S5XSPxV7dA1RUmZJuT3Pc4RvsdjN)MqgB7T7(q2DYyRVE3h0wiJMFNkGVw7yOUkrLwA1DSG4jPW)oW86KH3Q7dXQ78tJ5fzYhi7jHyIF9Nz0WBlVELbTwPDujBToVS9wDFi6(8Q1xVYGwRQs7Oc)NyW3baJBZ4bUHpmXloTjGB796i(31HbnumzZbFNd(T5OR3ddGTarSb6T1P3NyW3ba3TLu7VxhX)UomBfNZgKe1TJZzdgGoY5uViewJCWMJyp(ODx0A2hnBsQypOp48NBrwaEQHbm9HWz97F5HnhFJTvy9rCyRJ4qXiwq()cs3o(loD74Na6MKJCOTodF)vxVHwAgyzpoOb5YEFydbiV2uAqR6TgCxb1tstcT9tyRnD1MpH3VDffv8T5rbbrR8PJUlG1e3h8SY7Rp5b2fF74T(wChetN1dfVhDW4oNFm3v(2EE4l75M5o1nL9tR)v(50uIFMLQ(5gHU8Vb17Z2olzF0xrwG9o0KK2ka)(OZZ2)yRf1k7LMCWgS3(EYWce3PouXkfyp1cQFTG)2tLTPfB33JyFX2CfBDFZAddRCwVOJLvE4gc57JcCZmjKv(aBq0sZCUdutBqC3N9wG8om7TU7b2T9)ITogFVO)2wFJVxmLzRhY3BAAS5e2USiArQq0gsAWRO5KSbmlnGCXn(J(AwXfbKfWzRXB3HE0ZO)qcN(3WZPaBBK3n3vtBTZ3UUPzEQGRT0Sx)MStcDdXjw(kpHaVvWw)oDRgyn(kDcN3oG3kyTMiFRdN8VB)tRn62RcqRtQ2xL3VaVdGfd4V47masTh)eIRpPaVvW29ul2PmyU7dtJzW0o43Ue8(edE7aEN9l0EbTALnPD1x7xG3bW2OWyTh)eIRpPaVvW29ke1jHXDFyAuy0o4BxAPdLbCFdE7aENfgTxf2wztA3GW(f4DaS7GLX9lU(Kc8wbB3nz1jHXDFyAuy0o4BxAPdwg33G3oG3zHXoue4nqN9tkW7ay3blJ7xC9jf4Tc2UBYQtcJ7(WSvfAFBnD9edE7aENfgRNsWDsP9tl0BaU7oHW(oYPvuTDPX9m0BaU7aHWyQ2MJDd4UNKTD4OBA9V(EcJqW96Q1Afh2BgdQeM7J3gG8hLoqUjjF(OJlAuGJWd25rcIArpuCeD)boQQ28QTbZJpA4PInbKXNDF5wSX4ZVJFcmA4jybGvFqBBKJ1)A3NWogNWM6ySsmO(UEY4ZmoH139ogFs1jC77CL1)6)bEA1pJosTxDNpD5iZ)AohvSRFsX5PD5fU8r0veZCg)sgAPFyoEm7sxXfdl)DbG2iQkVPtokkEuklZFUG6oK)FNWcszJozW5hjVIMh1(2NWGZy7RgI3aOhDs)nz(6SZZ3AnzVb7D7R5RbqtZxGj660mFubgE9gOS0FlnrwF70hOR6Gya7Xw)GFPSjGf)WCN(tIVd4V88V3NUdrWVKEwXiQ864mhV0eOBnh89b1x3(lUCCqk)HxEiE(Z9r21dfxOH4zf)WbN)5(C28f87Of(v5n(EXj(rGS0d8hRaQIzgmqCD7MgL0743dD494axDo8lUPvE7YrWpCwcZnfjDObcpM4xHH4nu)XGxjeIjv5ymV4kHWvrKLFNseLu8tu3YGCyfYWf0CupF35shcwscZDdQPDVH24xtVR1SUR9Ev7B(nbjDmJKnUxd00v2bK0qZ9Vji5WjSppli3JzIuQ367AKgRDR(MGaowqaJ9EV20EVGaf89668Cu15nurJ3tu)AAsnz5ZmguKwpuAYwFhBDtt2KkFwxgCtEw1uxCskP)aDLhmuEDDkoN8lU2mOB0IoSuQELgwyXAWjQNh20O9hIpsORc4Rc5QtXUtagU7akaznqGnPIxmpggx6b496b2KFVj66buh99UKOLGsquTmlLF)DEwkBgE1KYwMIUW(jMW2q6kgOMoocnMq9pOF2Zq7rGtxKlkKQwF0(rkGsZXR5Dya(LcCs5sNIFh2(YIlP)uUfNPSf(yVyJtOPm(14JlENyL2nDRvUFADJyh5XM7MhKn6muYiHbYg7zQ44pU5iwAMeVgEIcI1oyq2t8Wcf0semj2xWNiz79dXl(kE)6aAtMNJxOctorYUF5j0S)VHw1gte3X8Mig4gKDr86B)DatZboyZielXZfIeITCk46l7i)5JkA7IAnKSzii72wLVv(36Dy1d6MYd(gL2G1I3GQx2niSpqh4YB4loS7vhYyCCK370v)CmAPNVkZDlGUR5Cr(x3P0fjiYZmEmXLVmkL8acSiYUNUn1iwMOywiJZJHFhbHv0JF7hEXLV7QxC54XV4YKinkgmDGrh(jCIqAKuCIeph8pqUQR3Is4j8tTJDU(p(iE)E3RYvA8fNEUM4aiwcygd5R4(DYfnWlfAqYwIbRPRHp0lYvrj8Bnso5avsS09Z(lZxIsWzG(II(jw9RN5vE59LukLbAv8xakria(ZOigB(CYXowHNWduPqvfo0U5Q1fouOFft))RdLp18To7loRV6lz4CrcEdGe(FGxzsOSh4ZUq8eeJ4wdEVqomvCzJDh7HNrCq376hWP6G8jnLviremlNPcjBPSpYrWN1vf2TXTq)n2swIBaePAIlE(qrNjDW4Yp67UC0P9uUlQb3HpD4eN4zGaOX5pa1MybbgulqZuhbvyknpwitT0vAZbpG)cyUEiT8o344hu5a(x5G5XJWDCr0854TRk4LdPvHUxVfNvFODvCEci(Sm1Vw)Y1QItvPQVzsEy9xenWadMUS2PT(HPzc9mV5FCD1uf9)dJacLTW)bp5w5bMHbPWVL743CDKStrarGNnbOIh(fC3kWpWmuOdJmeuhZWh9pIX)cpAfCbQ8YXdfYidFUIG1weenf5E5db3Ci)dHhopHHS4xvQ)fObWSuB9)Ok3Xp8LetYH5XevqC5FkvtlVVwFZ43876dvfRh0YRSD)eG7xCXR5sU3x8lWSkxWzO6AAYHt9vajUsoQmmigo62618fEhopTCOHcolFqTKCAovbcnmxcoj0VxXHxjWEjo)20VQzLg30qQEwLsludo6L9lV7lLJFVM0Cos6RAZNACVSxlAyVyOt)Ehy5kzvBvr5w)tX1bT9SqbDVSB47DO4pPSNbAKIFbE)G2Ow)lEPcaSmXEzvvGIl3)sfG16o3(WQCJd6Wt61Mbl4DE8X6JAVonMk0xjZhcVdQrs73tOHL8NnlcGjYz6y2jdN(9RTuwAMUuDDNag3fw6gbndVRBPmnrzwLCDHIqb1tUijsFqRE)WBZuzv15xm60NF6pwyZQYEHWULrU1m(fSO6TKh5Nii6TyHmztPyMOogpkhjpaar0emyiPgluj1BhJUrcuh))KCs8Naf6kxmJOxfImWHkrbQvrMQ43C9Vo9580xbQlW7Fpg9JEIT8k)2tLho2PNuttOztKZNIupJAYKblR5o2LYhOhKwjdMCtCy5Q4TjvsxIhqLhYD0H7terALcgYHxnq7hFuohkBPD9J5YtbHecSIvPj8fP2GCDER(OMO6C6V2cJoOuw4ym68IchMc311cosWSgQg4FByWSjEwYROYZTnmlWsFtVGvU1EFZWITtStvnFOWr92R4l4HfX(s3G4O)s0FzreVwdr8lr)5brRK3v1dAXGTjhPk(up2C)z(zxEk3JqYHq0tnE8NyUH8IyPHpltDCV(QJuUu)PD)dMqjYR5qmcYTWpvd(wrXhDHHhar6YJIsrfMYorsF05zDaheVOmvb6jEUlr6bE7K7JxO6hy2vo5PpU17J4(nZ178knltc)TlIgif9eNwGHhvCdZ3KVX2CYTzSWsTXKUFro8AXjxPFWoTdeHs4kbiOXHQ4lKvUHgoo3T6yfrN)9hqIQ4g9N)lN9XNx8JNI)ikQfh4(ar0)dPcII3Hh51WZjT6WqYdH5NRfawm82MWF9ytpBB)Wt7vtjwxbfpg86xpcqGnNRWoI3e18PR4KPgS1qCtyAxrc1pjubjjxIDn2rYFIh2CE8rvZY8zO5iAECe3ovArwpvsvP4tRPdRssfnm7KYQcCWWXTDTfHwoPTxmZdvT8Jfr6z4KEaL0PNv)u8(aJcofkAVOqHlmaVyir()FJW8D4vKMovM4cE35ujcg)Xns8bwY9dH)ldW(hMq)2eGGXWmzLmaZzJYtq1EO6pu9qT7hu0T8UEppCeIqjj5XzAd2Sa)yKuzc6YrEdgM5J647AKhxYXYZZIqdfpZhcp3aZAyuo)F5(ZOcAdcnkjjPME52yulmPigQEASPLvg4n8T6iyGabfVk5VZhRSB38DJUv6vgXkBDsb7P(TTFpd(gqy07GHykOSaN5Mqb3)mpb1hN4)PAZArs208rU6vvoM1(14fwEG)mrkWbxBeGqrzadtMxvNMoQ82Ug52BthQ1lq3VoxCU2U5C76nMR9Bk3n5gYTZeyNUqGDEUJTq1TrIDg0vkS2ArNX8t7cM3usgmVkzBcncVJ372usBU35z0zwe0ut1rvPmq(kjkgIHjRIagMKAiEXJ5ZqvXT5tfEAwe(qBYAhUNLHQXdJZYUGDDGrfDD1k(U1mK97g(zKD0cpMvKC7zY6iwAJf7VLqfuCmcW0Id4iIHkXNN0dnRxYrJSkHS1IIGnfBQaWRMAVGwbUfdmwb43mJ7P4Fhn1v07dIsZuTHiaCM3iftzyCAhuokPyHQr3r8Zyl52l)0Dyx)eW(mpckFWHnWAke8(ou8blUM8sAU8Fl(lWmbDVdq9pInPce9NFcw6hHtFl5z6jKv2r1zRyU8Y9wz(W7Qb6RT7x0fNw62l31ijpYPcZ)LEmvb80FUEr(Smmo1aw3lXuAT(tGtP3NvyQ(ySLRX2I9(7fyAZlWeTO896l9x46lHTpalW9ZOYQYMQh8(pmdBoTpW3Bi0913rOSBiLlHewaMyvQTDCPg1)oFu2MFJmdgycP(oie4xqnJYgOe0CC4vbrrEb5OsGNxRBpo(pOEIdB9zSTfq3RaRcUj97y22))3ExBlN4gbr)wYdHG21llsgN4hmUQ1lSjEFivQGRK3Sr2GJPcGCbI9svBX3EMU75(njHXKSP2YpzqA0mTotp9C6Z0eMT9JZ2n62jiU0YGbnffo0RAmyV9og80QHGN2ueyJWsis6kiZIKYezbsOZiUK8jiujYDpgSe9gXGnVHx8oGVjMR5vFCMmFLdh1X6DIBAj96b3DrIQSLvyi1ZasatDSMVL3DfsZeV6Hva)8JkbPMquXZmfdkK83Fx(JcMqEdYy(2X)bw8USSn2e2lJ0F)WqFIUo6SSbyYMCn6buWKIZERFCW1ZsmVCnXEZLubf5PNOn5ZJXNsZJND5xjZIuK6MyoCyjVtRVtRpXJSY5MtugfRrVHb2mj58(VBJzbbmf5N2V7Q3C38CwqHCD(123pBRkbFA(lSF0FgxpR)pXhOn93XvTOg0B4TV)LYDhZZGlfJDh2YgOqtZxrfFvN00coumITCWV35jVcYoMVw8TXZTEawx6roaISb1KSJgWHz8P7ENzhEIT3NqJYjBRaWw5qYfVZEUXtFyCDd4OyG)FHeJSa6(aj2Sqp2FW2aGQ9dEYDivPwb(ZCiL8yAkE3fVE4iXr2aJJEYNP38QSjNVeddA74F(TdanJJ6wLTpSnZl3QQ40eMzzbGjxskyzgNhf2Wtd4zHe(iRZCelAT(Xw8ZiHe83M(sfuikV4jL7LEFR9cFlLHBspqZ9Q4lU3ShsLMd)r39SArQEG7VtDEth6kYDqme5xjL8QKHaU1sydgkkLhP1eID6NMvkcendcz32lJ9zkPb2hFbQkJh9vHIIn5fC7QBc6m6ygj(6G2XS6inxvltx(38dakChI)tDDmFWFaO5RtAhD3PF5lAFH40bj)OmRRvsPD(sn2XCYmvAIMptTdce130F7BVk7ZUkD4WAzMI5mwk17eFFuKujyotTLRty8Rcu1qre4cYItHMpMnfSLnBXIzlHLHMmLHI3GTIKOUGMoze9A8Vjx)1GOUeDJ4JOAAGfLyDd(kk3Z8)uahnCOPj9FqGd1ztcOUb()SUocWb9LKDL14h1admvWlFJHOSfVwpkKPF)SUwsfKHoWX1aO7YjQFiiJcwNc0rbNQc2daicdxGwbngZmrS3cit5SRFoWhr(9yuxsL(r)lNgmaRBCSnPQUcE81UDtzjmUTragsczNLaItQN0E1BQZZKMiAJQ0gstESnx0ib3wj2uSRaJDT2TwBbN9F)XVmOx7Ztv(cnJjmYwGpxKdGMUdyL48hW8eO09onzbsk8skQ(8jtwl2laDoFfAqCw5paFOwSK8d9KGGnAWaW7lh4G(Q2)JZ8jMDuZKdDmWC3pLn3ty40y2NfAS3l)h72YZfBtMrn6F7D)JQpYXb52Xnr0pr221tqZpbhkc7PR838Pwi(NzjOjLSRS276rav9IGcvByLIe8Yvqzp5olnn7D9uVmesErMPAf2w0MiNBn9ttVBdoPFHwCkuanqBdBxuSpq92425BMQM3PlWWalIhNlWtsSvHoML9XMIUIC9ZZx87TY7REmO88KtZ9zpQf3oJYDITsSfhVsN8GprDx3mVOybqQmSi5FbD8Bq9a4Meyi0pHHTBNtI)yCK(a(CbBC(C8rXwnQ8H13q1HKN4dJoPNgf1evcLvF8QPWkQ817t9T)RVZ(wyTua)VTABYiqkk7)2E4EYue2sIPBzGgTVNEDJh4ApEDl6xXs(cxsTOenKh3u5DPwkqloRF7sESxd)a6m6xik4oc3Ch)CaOAuCrfmldYaZgsQ7y74RWZ4ChAw(BkgAFVQZ)ANA8AmynSrlHeXpC1zQcRIvrCOLpshRi)Xhxbr)1j1DvL9OtRmZ6Ngk1ASTgfC0A6Z5mqluEPDL9X(oa5G4cRW0yVa)XEjFLnbaXQxiRIr2qlGQk38(ry7JSXt84MLi)7vxaCRm3)aZOCOiQmo(DWjgd)irDOPgiYqfFjeq6TG8Wh4m7AOc5tI367wK7JxZGC0khZ4Q1w1)Nvc2Zast)JpYmxbVRe)LYcX7ZR0k5zI1ZrMHWQqgSgVOwsmHxi1osehkeYj92efHf3veuT(GpZUE9bfRm(BNTunbrbD6zUDrlVsAHblHvtk2GQpgmOB1kzBKFVcibPoGTrJEnKB6Cj5xuz6GWUaEBLSxRQ5pXXwRNxukkacPbOvQDTC41ZB1KawnkyDKA3k0e1aY0k80bOdTJp3aJph3pitrR0lVvIMvVuG5oxWXojQYx9t9wmU41Gm2Um9mrLkJB6f)mVfeRZ7BmRs)6vED5x7zWEEAhmRkzD9DynbJHVqMJmytQpKn7qbztpyqwxpXhyiBAaiRVLic)wmZZxMgdYM5azdua5ccz9um6oqq2Sgaz)Mx29pK9RmVSTGWz(VHR2iJQ6dP)Mx49pK(RmVWwq6)nDfhzuHBy4Y7fuaIrzdrpRVzmvzqgpRhWtxC2MWyU57FdUn5yKc9MseZm67RU1UTqquUQDQ9uo6u8eCcYoVFWg)(zV5)iyVAx3K6EzWiqoxpkFt5dfRUE0OzlE71LS)U(F(d]] )