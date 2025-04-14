-- EvokerDevastation.lua
-- January 2025

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
    aerial_mastery                  = {  93352, 365933, 1 }, -- Hover gains 1 additional charge.
    afterimage                      = {  94929, 431875, 1 }, -- Empower spells send up to 3 Chrono Flames to your targets.
    ancient_flame                   = {  93271, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream            = {  93292, 376930, 2 }, -- Your healing done and healing received are increased by 3%.
    blast_furnace                   = {  93309, 375510, 1 }, -- Fire Breath's damage over time lasts 4 sec longer.
    bountiful_bloom                 = {  93291, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame               = {  93294, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 65,292 upon removing any effect.
    chrono_flame                    = {  94954, 431442, 1 }, -- Living Flame is enhanced with Bronze magic, repeating 25% of the damage or healing you dealt to the target in the last 5 sec as Arcane, up to 46,638.
    clobbering_sweep                = { 103844, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 2 min.
    doubletime                      = {  94932, 431874, 1 }, -- Ebon Might and Prescience gain a chance equal to your critical strike chance to grant 50% additional stats.
    draconic_legacy                 = {  93300, 376166, 1 }, -- Your Stamina is increased by 8%.
    enkindled                       = {  93295, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    expunge                         = {  93306, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    extended_flight                 = {  93349, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance                      = {  93299, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    fire_within                     = {  93345, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    foci_of_life                    = {  93345, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over 4 sec.
    forger_of_mountains             = {  93270, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    golden_opportunity              = {  94942, 432004, 1 }, -- Prescience has a 20% chance to cause your next Prescience to last 100% longer.
    heavy_wingbeats                 = { 103843, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 2 min.
    inherent_resistance             = {  93355, 375544, 2 }, -- Magic damage taken reduced by 4%.
    innate_magic                    = {  93302, 375520, 2 }, -- Essence regenerates 5% faster.
    instability_matrix              = {  94930, 431484, 1 }, -- Each time you cast an empower spell, unstable time magic reduces its cooldown by up to 6 sec.
    instinctive_arcana              = {  93310, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    landslide                       = {  93305, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 15 sec. Damage may cancel the effect.
    leaping_flames                  = {  93343, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth                     = {  93347, 375561, 2 }, -- Green spells restore 5% more health.
    master_of_destiny               = {  94930, 431840, 1 }, -- Casting Essence spells extends all your active Threads of Fate by 1 sec.
    motes_of_acceleration           = {  94935, 432008, 1 }, -- Warp leaves a trail of Motes of Acceleration. Allies who come in contact with a mote gain 20% increased movement speed for 30 sec.
    natural_convergence             = {  93312, 369913, 1 }, -- Disintegrate channels 20% faster.
    obsidian_bulwark                = {  93289, 375406, 1 }, -- Obsidian Scales has an additional charge.
    obsidian_scales                 = {  93304, 363916, 1 }, -- Reinforce your scales, reducing damage taken by 30%. Lasts 12 sec.
    oppressing_roar                 = {  93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    overawe                         = {  93297, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 30 sec.
    panacea                         = {  93348, 387761, 1 }, -- Emerald Blossom and Verdant Embrace instantly heal you for 35,196 when cast.
    potent_mana                     = {  93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by 3%.
    primacy                         = {  94951, 431657, 1 }, -- For each damage over time effect from Upheaval, gain 3% haste, up to 9%.
    protracted_talons               = {  93307, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                           = {  93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall                          = {  93301, 371806, 1 }, -- You may reactivate Deep Breath within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic              = {  93353, 387787, 1 }, -- Your Leech is increased by 4%.
    renewing_blaze                  = {  93354, 374348, 1 }, -- The flames of life surround you for 8 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    rescue                          = {  93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location. Clears movement impairing effects from you and your ally.
    reverberations                  = {  94925, 431615, 1 }, -- Upheaval deals 50% additional damage over 8 sec.
    scarlet_adaptation              = {  93340, 372469, 1 }, -- Store 20% of your effective healing, up to 40,315. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk                      = {  93293, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic                 = {  93344, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 1 |4hour:hrs;. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    spatial_paradox                 = {  93351, 406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by 100% for 10 sec. Affects the nearest healer within 60 yds, if you do not have a healer targeted.
    tailwind                        = {  93290, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    temporal_burst                  = {  94955, 431695, 1 }, -- Tip the Scales overloads you with temporal energy, increasing your haste, movement speed, and cooldown recovery rate by 30%, decreasing over 30 sec.
    temporality                     = {  94935, 431873, 1 }, -- Warp reduces damage taken by 20%, starting high and reducing over 3 sec.
    terror_of_the_skies             = {  93342, 371032, 1 }, -- Deep Breath stuns enemies for 3 sec.
    threads_of_fate                 = {  94947, 431715, 1 }, -- Casting an empower spell during Temporal Burst causes a nearby ally to gain a Thread of Fate for 10 sec, granting them a chance to echo their damage or healing spells, dealing 15% of the amount again.
    time_convergence                = {  94932, 431984, 1 }, -- Non-defensive abilities with a 45 second or longer cooldown grant 5% Intellect for 15 sec. Essence spells extend the duration by 1 sec.
    time_spiral                     = {  93351, 374968, 1 }, -- Bend time, allowing you and your allies within 40 yds to cast their major movement ability once in the next 10 sec, even if it is on cooldown.
    tip_the_scales                  = {  93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian                   = {  93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5 sec.
    unravel                         = {  93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 197,312 Spellfrost damage to absorb shields.
    verdant_embrace                 = {  93341, 360995, 1 }, -- Fly to an ally and heal them for 141,237, or heal yourself for the same amount.
    walloping_blow                  = {  93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    warp                            = {  94948, 429483, 1 }, -- Hover now causes you to briefly warp out of existence and appear at your destination. Hover's cooldown is also reduced by 5 sec. Hover continues to allow Evoker spells to be cast while moving.
    zephyr                          = {  93346, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8 sec.

    -- Devastation
    animosity                       = {  93330, 375797, 1 }, -- Casting an empower spell extends the duration of Dragonrage by 5 sec, up to a maximum of 20 sec.
    arcane_intensity                = {  93274, 375618, 2 }, -- Disintegrate deals 8% more damage.
    arcane_vigor                    = {  93315, 386342, 1 }, -- Casting Shattering Star grants Essence Burst.
    azure_celerity                  = {  93325, 1219723, 1 }, -- Disintegrate ticks 1 additional time, but deals 10% less damage.
    azure_essence_burst             = {  93333, 375721, 1 }, -- Azure Strike has a 15% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    burnout                         = {  93314, 375801, 1 }, -- Fire Breath damage has 16% chance to cause your next Living Flame to be instant cast, stacking 2 times.
    catalyze                        = {  93280, 386283, 1 }, -- While channeling Disintegrate your Fire Breath on the target deals damage 100% more often.
    causality                       = {  93366, 375777, 1 }, -- Disintegrate reduces the remaining cooldown of your empower spells by 0.50 sec each time it deals damage. Pyre reduces the remaining cooldown of your empower spells by 0.40 sec per enemy struck, up to 2.0 sec.
    charged_blast                   = {  93317, 370455, 1 }, -- Your Blue damage increases the damage of your next Pyre by 5%, stacking 20 times.
    dense_energy                    = {  93284, 370962, 1 }, -- Pyre's Essence cost is reduced by 1.
    dragonrage                      = {  93331, 375087, 1 }, -- Erupt with draconic fury and exhale Pyres at 3 enemies within 25 yds. For 18 sec, Essence Burst's chance to occur is increased to 100%, and you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    engulfing_blaze                 = {  93282, 370837, 1 }, -- Living Flame deals 25% increased damage and healing, but its cast time is increased by 0.3 sec.
    essence_attunement              = {  93319, 375722, 1 }, -- Essence Burst stacks 2 times.
    eternity_surge                  = {  93275, 359073, 1 }, -- Focus your energies to release a salvo of pure magic, dealing 149,519 Spellfrost damage to an enemy. Damages additional enemies within 25 yds when empowered. I: Damages 2 enemies. II: Damages 4 enemies. III: Damages 6 enemies.
    eternitys_span                  = {  93320, 375757, 1 }, -- Eternity Surge and Shattering Star hit twice as many targets.
    event_horizon                   = {  93318, 411164, 1 }, -- Eternity Surge's cooldown is reduced by 3 sec.
    eye_of_infinity                 = {  93318, 411165, 1 }, -- Eternity Surge deals 15% increased damage to your primary target.
    feed_the_flames                 = {  93313, 369846, 1 }, -- After casting 9 Pyres, your next Pyre will explode into a Firestorm. In addition, Pyre and Disintegrate deal 20% increased damage to enemies within your Firestorm.
    firestorm                       = {  93278, 368847, 1 }, -- An explosion bombards the target area with white-hot embers, dealing 55,401 Fire damage to enemies over 6 sec.
    focusing_iris                   = {  93315, 386336, 1 }, -- Shattering Star's damage taken effect lasts 2 sec longer.
    font_of_magic                   = {  93279, 411212, 1 }, -- Your empower spells' maximum level is increased by 1, and they reach maximum empower level 20% faster.
    heat_wave                       = {  93281, 375725, 2 }, -- Fire Breath deals 20% more damage.
    honed_aggression                = {  93329, 371038, 2 }, -- Azure Strike and Living Flame deal 5% more damage.
    imminent_destruction            = {  93326, 370781, 1 }, -- Deep Breath reduces the Essence costs of Disintegrate and Pyre by 1 and increases their damage by 10% for 12 sec after you land.
    imposing_presence               = {  93332, 371016, 1 }, -- Quell's cooldown is reduced by 20 sec.
    inner_radiance                  = {  93332, 386405, 1 }, -- Your Living Flame and Emerald Blossom are 30% more effective on yourself.
    iridescence                     = {  93321, 370867, 1 }, -- Casting an empower spell increases the damage of your next 2 spells of the same color by 20% within 10 sec.
    lay_waste                       = {  93273, 371034, 1 }, -- Deep Breath's damage is increased by 20%.
    onyx_legacy                     = {  93327, 386348, 1 }, -- Deep Breath's cooldown is reduced by 1 min.
    power_nexus                     = {  93276, 369908, 1 }, -- Increases your maximum Essence to 6.
    power_swell                     = {  93322, 370839, 1 }, -- Casting an empower spell increases your Essence regeneration rate by 100% for 4 sec.
    pyre                            = {  93334, 357211, 1 }, -- Lob a ball of flame, dealing 45,820 Fire damage to the target and nearby enemies.
    ruby_embers                     = {  93282, 365937, 1 }, -- Living Flame deals 6,613 damage over 12 sec to enemies, or restores 12,203 health to allies over 12 sec. Stacks 3 times.
    ruby_essence_burst              = {  93285, 376872, 1 }, -- Your Living Flame has a 20% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    scintillation                   = {  93324, 370821, 1 }, -- Disintegrate has a 15% chance each time it deals damage to launch a level 1 Eternity Surge at 50% power.
    scorching_embers                = {  93365, 370819, 1 }, -- Fire Breath causes enemies to take up to 40% increased damage from your Red spells, increased based on its empower level.
    shattering_star                 = {  93316, 370452, 1 }, -- Exhale bolts of concentrated power from your mouth at 2 enemies for 50,547 Spellfrost damage that cracks the targets' defenses, increasing the damage they take from you by 20% for 4 sec. Grants Essence Burst.
    snapfire                        = {  93277, 370783, 1 }, -- Pyre and Living Flame have a 15% chance to cause your next Firestorm to be instantly cast without triggering its cooldown, and deal 100% increased damage.
    spellweavers_dominance          = {  93323, 370845, 1 }, -- Your damaging critical strikes deal 230% damage instead of the usual 200%.
    titanic_wrath                   = {  93272, 386272, 1 }, -- Essence Burst increases the damage of affected spells by 15.0%.
    tyranny                         = {  93328, 376888, 1 }, -- During Deep Breath and Dragonrage you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    volatility                      = {  93283, 369089, 2 }, -- Pyre has a 15% chance to flare up and explode again on a nearby target.

    -- Scalecommander
    bombardments                    = {  94936, 434300, 1 }, -- Mass Disintegrate marks your primary target for destruction for the next 6 sec. You and your allies have a chance to trigger a Bombardment when attacking marked targets, dealing 73,725 Volcanic damage split amongst all nearby enemies.
    diverted_power                  = {  94928, 441219, 1 }, -- Bombardments have a chance to generate Essence Burst.
    extended_battle                 = {  94928, 441212, 1 }, -- Essence abilities extend Bombardments by 1 sec.
    hardened_scales                 = {  94933, 441180, 1 }, -- Obsidian Scales reduces damage taken by an additional 10%.
    maneuverability                 = {  94941, 433871, 1 }, -- Deep Breath can now be steered in your desired direction. In addition, Deep Breath burns targets for 174,419 Volcanic damage over 12 sec.
    mass_disintegrate               = {  94939, 436335, 1, "scalecommander" }, -- Empower spells cause your next Disintegrate to strike up to $s1 targets. When striking fewer than $s1 targets, Disintegrate damage is increased by $s2% for each missing target.
    melt_armor                      = {  94921, 441176, 1 }, -- Deep Breath causes enemies to take 20% increased damage from Bombardments and Essence abilities for 12 sec.
    menacing_presence               = {  94933, 441181, 1 }, -- Knocking enemies up or backwards reduces their damage done to you by 15% for 8 sec.
    might_of_the_black_dragonflight = {  94952, 441705, 1 }, -- Black spells deal 20% increased damage.
    nimble_flyer                    = {  94943, 441253, 1 }, -- While Hovering, damage taken from area of effect attacks is reduced by 10%.
    onslaught                       = {  94944, 441245, 1 }, -- Entering combat grants a charge of Burnout, causing your next Living Flame to cast instantly.
    slipstream                      = {  94943, 441257, 1 }, -- Deep Breath resets the cooldown of Hover.
    unrelenting_siege               = {  94934, 441246, 1 }, -- For each second you are in combat, Azure Strike, Living Flame, and Disintegrate deal 1% increased damage, up to 15%.
    wingleader                      = {  94953, 441206, 1 }, -- Bombardments reduce the cooldown of Deep Breath by 1 sec for each target struck, up to 3 sec.

    -- Flameshaper
    burning_adrenaline              = {  94946, 444020, 1 }, -- Engulf quickens your pulse, reducing the cast time of your next spell by 30%. Stacks up to 2 charges.
    conduit_of_flame                = {  94949, 444843, 1 }, -- Critical strike chance against targets above 50% health increased by 15%.
    consume_flame                   = {  94922, 444088, 1 }, -- Engulf consumes 2 sec of Fire Breath from the target, detonating it and damaging all nearby targets equal to 750% of the amount consumed, reduced beyond 5 targets.
    draconic_instincts              = {  94931, 445958, 1 }, -- Your wounds have a small chance to cauterize, healing you for 30% of damage taken. Occurs more often from attacks that deal high damage.
    engulf                          = {  94950, 443328, 1, "flameshaper" }, -- Engulf your target in dragonflame, damaging them for $443329s1 Fire or healing them for $443330s1. For each of your periodic effects on the target, effectiveness is increased by $s1%.
    enkindle                        = {  94956, 444016, 1 }, -- Essence abilities are enhanced with Flame, dealing 20% of healing or damage done as Fire over 8 sec.
    expanded_lungs                  = {  94956, 444845, 1 }, -- Fire Breath's damage over time is increased by 30%. Dream Breath's heal over time is increased by 30%.
    flame_siphon                    = {  99857, 444140, 1 }, -- Engulf reduces the cooldown of Fire Breath by 6 sec.
    fulminous_roar                  = {  94923, 1218447, 1 }, -- Fire Breath deals its damage in 20% less time.
    lifecinders                     = {  94931, 444322, 1 }, -- Renewing Blaze also applies to your target or 1 nearby injured ally at 50% value.
    red_hot                         = {  94945, 444081, 1 }, -- Engulf gains 1 additional charge and deals 20% increased damage and healing.
    shape_of_flame                  = {  94937, 445074, 1 }, -- Tail Swipe and Wing Buffet scorch enemies and blind them with ash, causing their next attack within 4 sec to miss.
    titanic_precision               = {  94920, 445625, 1 }, -- Living Flame and Azure Strike have 1 extra chance to trigger Essence Burst when they critically strike.
    trailblazer                     = {  94937, 444849, 1 }, -- Hover and Deep Breath travel 40% faster, and Hover travels 40% further.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    chrono_loop          = 5456, -- (383005) Trap the enemy in a time loop for 5 sec. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below 20%.
    divide_and_conquer   = 5556, -- (384689)
    dreamwalkers_embrace = 5617, -- (415651)
    nullifying_shroud    = 5467, -- (378464) Wreathe yourself in arcane energy, preventing the next 3 full loss of control effects against you. Lasts 30 sec.
    obsidian_mettle      = 5460, -- (378444)
    scouring_flame       = 5462, -- (378438)
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
local animosityExtension = 0 -- Maintained by CLEU

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
            elseif spellID == 375087 then  -- Dragonrage
                animosityExtension = 0
                return
            end

            if state.talent.animosity.enabled and animosityExtension < 4 then
                -- Empowered spell casts increment this extension tracker by 1
                for _, ability in pairs( class.abilities ) do
                    if ability.empowered and spellID == ability.id then
                        animosityExtension = animosityExtension + 1
                        break
                    end
                end
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
        duration = 6.0,
        pandemic = true,
        max_stack = 1
    },
    -- Next spell cast time reduced by $s1%.
    burning_adrenaline = {
        id = 444019,
        duration = 15.0,
        max_stack = 2
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
        max_stack = 1
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
        tick_time = function () return spec.auras.disintegrate.duration / ( 4 + talent.azure_celerity.rank ) end,
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
        max_stack = function() return talent.essence_attunement.enabled and 2 or 1 end
    },
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
        duration = 3.25
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
            local base = 26 + 4 * talent.blast_furnace.rank
            base = base - 6 * empowerment_level
            return base * ( talent.fulminous_roar.enabled and 0.8 or 1 )
        end,
        -- TODO: damage = function () return 0.322 * stat.spell_power * action.fire_breath.spell_targets * ( talent.heat_wave.enabled and 1.2 or 1 ) * ( debuff.shattering_star.up and 1.2 or 1 ) end,
        type = "Magic",
        max_stack = 1,
        copy = { "fire_breath_damage", "fire_breath_dot" }
    },
    firestorm = { -- TODO: Check for totem?
        id = 369372,
        duration = 6,
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
        duration = 6,
        max_stack = 1,
        generate = function( t )
            t.name = class.auras.firestorm.name

            if firestorm_last + 6 > query_time and firestorm_enemies[ target.unit ] then
                t.applied = firestorm_last
                t.duration = 6
                t.expires = firestorm_last + 6
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
        max_stack = 2
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
        max_stack = function() return max_empower end
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
        max_stack = 1
    },
    -- Damage done to $@auracaster reduced by $s1%.
    menacing_presence = {
        id = 441201,
        duration = 8.0,
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
        max_stack = function () return talent.essence_attunement.enabled and 2 or 1 end
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
    -- Able to cast spells while moving and spell range increased by $s4%.
    spatial_paradox = {
        id = 406732,
        duration = 10.0,
        tick_time = 1.0,
        max_stack = 1
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

spec:RegisterStateExpr( "animosity_extension", function() return animosityExtension end )

spec:RegisterHook( "runHandler", function( action )
    local ability = class.abilities[ action ]
    local color = ability.color

    if color == "blue" then
        if buff.iridescence_blue.up then removeStack( "iridescence_blue" ) end
        if talent.charged_blast.enabled then
            addStack( "charged_blast", nil, ( min( active_enemies, ability.spell_targets ) ) )
        end

    elseif color == "red" then
       if buff.iridescence_red.up then removeStack( "iridescence_red" ) end

    end

    if ability.empowered then
        if talent.animosity.enabled and animosity_extension < 4 then
            animosity_extension = animosity_extension + 1
            buff.dragonrage.expires = buff.dragonrage.expires + 5
        end

        if talent.enkindle.enabled then applyDebuff( "target", "enkindle" ) end

        if talent.iridescence.enabled and color then
            local iridescenceBuffType = "iridescence_" .. color -- Constructs "iridescence_red", "iridescence_blue", etc.
            applyBuff( iridescenceBuffType, nil, 2 ) -- Apply the dynamically determined buff with 2 stacks.
        end

        if talent.mass_disintegrate.enabled then
            addStack( "mass_disintegrate_stacks" )
        end

        if talent.power_swell.enabled then applyBuff( "power_swell" ) end -- TODO: Modify Essence regen rate.

        if buff.tip_the_scales.up then
            removeBuff( "tip_the_scales" )
            setCooldown( "tip_the_scales", spec.abilities.tip_the_scales.cooldown )
        end

        removeBuff( "jackpot" )
    end

    if ability.spendType == "essence" then
        removeStack( "essence_burst" )
        if talent.enkindle.enabled then
            applyDebuff( "target", "enkindle" )
        end
        if talent.extended_battle.enabled then
            if debuff.bombardments.up then debuff.bombardments.expires = debuff.bombardments.expires + 1 end
        end
    end
end )

spec:RegisterGear({
    -- The War Within
    tww2 = {
        items = { 229283, 229281, 229279, 229280, 229278 },
        auras = {
            jackpot = {
                id = 1217769,
                duration = 40,
                max_stack = 2
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207225, 207226, 207227, 207228, 207230 },
        auras = {
            emerald_trance = {
                id = 424155,
                duration = 10,
                max_stack = 5,
                copy = { "emerald_trance_stacking", 424402 }
            }
        }
    },
    tier30 = {
        items = { 202491, 202489, 202488, 202487, 202486, 217178, 217180, 217176, 217177, 217179 },
        auras = {
            obsidian_shards = {
                id = 409776,
                duration = 8,
                tick_time = 2,
                max_stack = 1
            },
            blazing_shards = {
                id = 409848,
                duration = 5,
                max_stack = 1
            }
        }
    },
    tier29 = {
        items = { 200381, 200383, 200378, 200380, 200382 },
        auras = {
            limitless_potential = {
                id = 394402,
                duration = 6,
                max_stack = 1
            }
        }
    }
})

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
    animosity_extension = nil
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

    empowered_cast_time = setfenv( function( n )
        if buff.tip_the_scales.up then return 0 end
        local power_level = n or args.empower_to or class.abilities[ this_action ].empowerment_default or max_empower

        -- Is this also impacting Eternity Surge?
        if settings.fire_breath_fixed > 0 then
            power_level = min( settings.fire_breath_fixed, power_level )
        end

        return stages[ power_level ] * ( talent.font_of_magic.enabled and 0.8 or 1 ) * ( buff.burning_adrenaline.up and 0.7 or 1 ) * haste
    end, state )
end

-- Support SimC expression release.dot_duration
spec:RegisterStateTable( "release", setmetatable( {},{
    __index = function( t, k )
        if k == "dot_duration" then
            return spec.auras.fire_breath.duration
        else return 0 end

    end
} ) )

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

        -- spend = 0.009,
        -- spendType = "mana",

        startsCombat = true,

        minRange = 0,
        maxRange = 25,

        damage = function () return stat.spell_power * 0.755 * ( debuff.shattering_star.up and 1.2 or 1 ) end, -- PvP multiplier = 1.
        critical = function() return stat.crit + conduit.spark_of_savagery.mod end,
        critical_damage = function () return talent.tyranny.enabled and 2.2 or 2 end,
        spell_targets = function() return talent.protracted_talons.enabled and 3 or 2 end,

        handler = function ()
            -- Many Color, Essence and Empower interactions have been moved to the runHandler hook
            if talent.azure_essence_burst.enabled and buff.dragonrage.up then addStack( "essence_burst", nil, 1 ) end
            if talent.charged_blast.enabled then addStack( "charged_blast", nil, min( active_enemies, spell_targets.azure_strike ) ) end
        end
    },

    -- Weave the threads of time, reducing the cooldown of a major movement ability for all party and raid members by 15% for 1 |4hour:hrs;.
    blessing_of_the_bronze = {
        id = 364342,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "arcane",
        color = "bronze",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        nobuff = "blessing_of_the_bronze",

        handler = function ()
            applyBuff( "blessing_of_the_bronze" )
            applyBuff( "blessing_of_the_bronze_evoker")
        end
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
        end
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

        copy = { "recall", 371807, 357210, 433874 }
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

        cycle = function() if talent.bombardments.enabled and buff.mass_disintegrate_stacks.up then return "bombardments" end end,

        startsCombat = true,

        damage = function () return 2.28 * stat.spell_power * ( 1 + 0.08 * talent.arcane_intensity.rank ) * ( talent.energy_loop.enabled and 1.2 or 1 ) * ( debuff.shattering_star.up and 1.2 or 1 ) end,
        critical = function () return stat.crit + conduit.spark_of_savagery.mod end,
        critical_damage = function () return talent.tyranny.enabled and 2.2 or 2 end,
        spell_targets = function() if buff.mass_disintegrate_stacks.up then return min( active_enemies, 3 ) end
            return 1
        end,

        min_range = 0,
        max_range = 25,

        start = function ()
            -- Many Color, Essence and Empower interactions have been moved to the runHandler hook
            applyDebuff( "target", "disintegrate" )
            if buff.mass_disintegrate_stacks.up then
                if talent.bombardments.enabled then applyDebuff( "target", "bombardments" ) end
                removeStack( "mass_disintegrate_stacks" )
            end

            removeStack( "burning_adrenaline" )

            -- Legacy
            if set_bonus.tier30_2pc > 0 then applyDebuff( "target", "obsidian_shards" ) end

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

            for i = 1, ( max( 3, active_enemies ) ) do
                spec.abilities.pyre.handler()
            end
            applyBuff( "dragonrage" )

            if set_bonus.tww2 >= 2 then
            -- spec.abilities.shattering_star.handler()
            -- Except essence burst, so we can't use the handler.
                applyDebuff( "target", "shattering_star" )
                if talent.charged_blast.enabled then addStack( "charged_blast", nil, min( action.shattering_star.spell_targets, active_enemies ) ) end
            end

            -- Legacy
            if set_bonus.tier31_2pc > 0 then
                QueueEmeraldTrance()
            end
        end
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

        spend = 0.14,
        spendType = "mana",

        startsCombat = false,

        healing = function () return 2.5 * stat.spell_power end,

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
        end
    },

    -- Engulf your target in dragonflame, damaging them for $443329s1 Fire or healing them for $443330s1. For each of your periodic effects on the target, effectiveness is increased by $s1%.
    engulf = {
        id = 443328,
        color = 'red',
        cast = 0.0,
        cooldown = 27,
        hasteCD = true,
        charges = function() return talent.red_hot.enabled and 2 or nil end,
        recharge = function() return talent.red_hot.enabled and 30 or nil end,
        gcd = "spell",

        spend = 0.050,
        spendType = 'mana',

        talent = "engulf",
        startsCombat = true,

        velocity = 80,

        handler = function()
            -- Assume damage occurs.
            if talent.burning_adrenaline.enabled then addStack( "burning_adrenaline" ) end
            if talent.flame_siphon.enabled then reduceCooldown( "fire_breath", 6 ) end
            if talent.consume_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires - 2 end
        end,

        impact = function() end,

        copy = { "engulf_damage", "engulf_healing", 443329, 443330 }
    },

    -- Talent: Focus your energies to release a salvo of pure magic, dealing 4,754 Spellfrost damage to an enemy. Damages additional enemies within 12 yds of the target when empowered. I: Damages 1 enemy. II: Damages 2 enemies. III: Damages 3 enemies.
    eternity_surge = {
        id = function() return talent.font_of_magic.enabled and 382411 or 359073 end,
        known = 359073,
        cast = empowered_cast_time,
        -- channeled = true,
        empowered = true,
        empowerment_default = function()
            local n = min( max_empower, active_enemies / ( talent.eternitys_span.enabled and 2 or 1 ) )
            if n % 1 > 0 then n = n + 0.5 end
            if Hekili.ActiveDebug then Hekili:Debug( "Eternity Surge empowerment level, cast time: %.2f, %.2f", n, empowered_cast_time( n ) ) end
            return n
        end,
        cooldown = function() return 30 - ( 3 * talent.event_horizon.rank ) end,
        gcd = "off",
        school = "spellfrost",
        color = "blue",

        talent = "eternity_surge",
        startsCombat = true,

        spell_targets = function () return min( active_enemies, ( talent.eternitys_span.enabled and 2 or 1 ) * empowerment_level ) end,
        damage = function () return spell_targets.eternity_surge * 3.4 * stat.spell_power end,

        handler = function ()
            -- Many Color, Essence and Empower interactions have been moved to the runHandler hook

            -- TODO: Determine if we need to model projectiles instead.
            if talent.charged_blast.enabled then addStack( "charged_blast", nil, spell_targets.eternity_surge ) end

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
        end
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
            -- Many Color, Essence and Empower interactions have been moved to the runHandler hook
            if talent.leaping_flames.enabled then applyBuff( "leaping_flames", nil, empowerment_level ) end
            if talent.mass_eruption.enabled then applyBuff( "mass_eruption_stacks" ) end -- ???

            applyDebuff( "target", "fire_breath" )
            -- applyDebuff( "target", "fire_breath_damage" ) -- This was causing Fire Breath durations to be wonky.

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
            if buff.snapfire.up then
                removeBuff( "snapfire" )
                setCooldown( "firestorm", max( 0, action.firestorm.cooldown - action.firestorm.time_since ) ) -- Attempt to avoid (false) CD reset from Snapfire
            end
            applyDebuff( "target", "in_firestorm" )
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
        end
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
        end
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
        end
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
        end
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

        velocity = 45,
        startsCombat = true,

        damage = function () return 1.61 * stat.spell_power * ( talent.engulfing_blaze.enabled and 1.4 or 1 ) end,
        healing = function () return 2.75 * stat.spell_power * ( talent.engulfing_blaze.enabled and 1.4 or 1 ) * ( 1 + 0.03 * talent.enkindled.rank ) * ( talent.inner_radiance.enabled and 1.3 or 1 ) end,
        spell_targets = function () return buff.leaping_flames.up and min( active_enemies, 1 + buff.leaping_flames.stack ) end,

        handler = function ()
            -- Many Color, Essence and Empower interactions have been moved to the runHandler hook
            if buff.burnout.up then removeStack( "burnout" )
            else removeBuff( "ancient_flame" ) end

            if talent.ruby_embers.enabled then applyDebuff( "target", "living_flame" ) end

            if talent.ruby_essence_burst.enabled and buff.dragonrage.up then
                addStack( "essence_burst", nil, buff.leaping_flames.up and ( true_active_enemies > 1 or group or health.percent < 100 ) and 2 or 1 )
            end

            removeBuff( "leaping_flames" )
            removeBuff( "scarlet_adaptation" )
        end,

        impact = function()
            if talent.ruby_embers.enabled then addStack( "living_flame" ) end
        end,

        copy = "living_flame_damage"
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
        end
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
        end
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
            return 3 - talent.dense_energy.rank - ( buff.imminent_destruction.up and 1 or 0 )
        end,
        spendType = "essence",
        timeToReadyOverride = function()
            return buff.essence_burst.up and 0 or nil -- Essence Burst makes the spell ready immediately.
        end,

        talent = "pyre",
        startsCombat = true,

        handler = function ()
            -- Many Color, Essence and Empower interactions have been moved to the runHandler hook
            removeBuff( "feed_the_flames_pyre" )

            if talent.causality.enabled then
                reduceCooldown( "fire_breath", min( 2, true_active_enemies * 0.4 ) )
                reduceCooldown( "eternity_surge", min( 2, true_active_enemies * 0.4 ) )
            end
            if talent.feed_the_flames.enabled then
                if buff.feed_the_flames_stacking.stack == 8 then
                    applyBuff( "feed_the_flames_pyre" )
                    removeBuff( "feed_the_flames_stacking" )
                else
                    addStack( "feed_the_flames_stacking" )
                end
            end
            removeBuff( "charged_blast" )

            -- Legacy
            if set_bonus.tier30_2pc > 0 then applyDebuff( "target", "obsidian_shards" ) end
        end
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
        end
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
        end
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
        end
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
            if talent.charged_blast.enabled then addStack( "charged_blast", nil, min( action.shattering_star.spell_targets, active_enemies ) ) end
            if set_bonus.tww2 >= 4 then addStack( "jackpot" ) end
        end
    },

    -- Talent: Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    sleep_walk = {
        id = 360806,
        cast = function() return 1.7 + ( talent.dream_catcher.enabled and 0.2 or 0 ) end,
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
        end
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
        end
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
        end
    },

    tail_swipe = {
        id = 368970,
        cast = 0,
        cooldown = function() return 180 - ( talent.clobbering_sweep.enabled and 120 or 0 ) end,
        gcd = "spell",

        startsCombat = true,
        toggle = "interrupts",

        handler = function()
            if talent.walloping_blow.enabled then applyDebuff( "target", "walloping_blow" ) end
        end
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
        end
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
        end
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
        end
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
        spell_targets = 1,

        usable = function() return settings.use_unravel, "use_unravel setting is OFF" end,

        handler = function ()
            removeDebuff( "all_absorbs" )
            if buff.iridescence_blue.up then removeStack( "iridescence_blue" ) end
            if talent.charged_blast.enabled then addStack( "charged_blast" ) end
        end
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
        end
    },

    wing_buffet = {
        id = 357214,
        cast = 0,
        cooldown = function() return 180 - ( talent.heavy_wingbeats.enabled and 120 or 0 ) end,
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
        end
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

    potion = "tempered_potion",

    package = "Devastation",
} )

spec:RegisterPack( "Devastation", 20250413, [[Hekili:S33)ZTTnYI)3sMBQIuITSeTCsU8j23ehN0l91RTtuURZB6CrMsesINPi5XVyh3XJ(B)ZUlajbabiPSLB79EVFOP2MGlwSy)(Ua8lJ)YN)Yup3m2x(bNroNmAY4JhoE04jN8LPz3gZ(Y0y3fx5Uc(Hq3nW)Eb7A30m3m)Oq8z3ge56HGinkpzb881zzXPV(OJw5NToF(WfrBok1FtEa9glsCxMH)(IJMhen)OS1SBCtUbgQF4rSWv(HSJwe4MMoBtKxEal9i34a8)MXUo6kwYWfXXFz68C)GSpg(L5MqChN)mGmXSfF5hgp5fVeqiFppgFWS0fFzko4dhn5WXh)6Tx(3CVIT9Y3hUkpy52lxM4Zc9cUD7L(HBVC6N3(DB)o(Wp(WJhbdFQ)M3T9Y)EmoTYp05KgE44Q3mN)Wl7NL4hEflBG84gDmFClkhx5dDo05vWd)8p)ZWiyUPra65OnSjho6pFOZyT5kv(PJr08Tbbr3S9YlsCxffc)dJVAF7p((QH(YdDE5bBVeELrte)FC()7cqceQOnI5r(DWfWNxda8NDtG)H2w)Y0a)0SuKfHH)7pqmCSq35bmVVC(xM6UGZlXYyjH(z3olnpbz3yBIJUHLmll6lthZ38s8J5J99IXc4aoyafZtHPnXn8QTxUjknB7LUXXb(lWzz7LzrW)5cdmlD4xMcGbEDFx(uFnBglKTXhxwV50TxoE7LphhDalmByboLoln2nCOaR3E5D3b7HBV8AxamWFz4c3WzSVMbmpZ8GvEVsa4g6dOdab13v80niNUNFQFygBvcqARg1ack6i4z00ESmkUmkmBw0YzBCx5VO69Hbmz7LpR1vYaocnpF5YHELSedtyBC9drscqrg(YtiqbsvbbZwdI)mc7S(sNXPJgEf7KLE2iNWg2TlcyZeBGidugiYFp4ICABV3HOBoDHU1grZz49HMzGsBE5F89y5FCBlFoF1XDD5)K24b71fg9MjKiwn05Eqknq)ntjNCpOKtKPKDBjAIEpPRIPgX8mWmxMjfQkAkpNbwGb6LlQQmgW4OKcD)vR1kIOjrRQLAIRVhyjMwUrxZ2G)aA7a43FbTL8eXUYA4PjdZJP)4QfEQ7nJW9gj1GPb(XPzjm3nk8oMEVVmfu0dSAlNbpfx6QR2pe4cZ5n(HRsRwDeYysOPAHPZkjW8frrbEr3eoCPFcB2CadZwRYCwocv2LIb1c6kT5Se5qHTgosaQ5xIBurHWtfCEdQwrz(XZaxNMLUaiGPM4IRwA9fBjS0uw4cyvKNKcK8mWRoAJZWd34(1zIbOkN7MaAMzZU2FvuIKjKkelDTBgoVHRqaKOTCVautaRjy3ybFBkB92l)heW4ElqE4mf0)cooaey8)cz5zjUbiEcVRFg(AbWVcGhS(teP4iK0HgtqkXjwKNL2cRjmRGLFeCee0xatXIOKfao5g6HyeStW9serl8N4(w4fX3)a3Fl3Qa3rcHngyC3gLJmj5baiarxyO3G4nFPdV2NgpuBZQqMGMCKqY2mNLKAsRkJCBv5j8vBXtYtXNmJerbMvV8eYlCsTdjeoOUDxKHTCzildiG5YCqFAcBXAux0SmFK)vrsqwwPygbR5Gh5zfoMG7tVyx3N0fEM66v55(pe5NIQv7)H8Gn(Hr5Wp)Pi0l0P5lUkDGbf2gOEfMZkGXSeae2DrrIuHROxURRihTv0Nao)L5HHadcF4aptuemXESLU5bzc(9PVtHNPXDVNu3mzEmISVYQcdRlX2xqKb1)CtQI8IYKzqM55Ur10nSjK4EnlqWzXzqfVil8kFi8SggUQ6QYXR5vDF5b5N4JBcO6pdoLi9uGP3Jmmyai2LwrizzrxjoIYpVGpwJIxTzj65LV(8iuRdGEl9xToBMQJuJKPNmA9PPWEM4p3ib2ckku9ObrzDqYM8TsWKSMWLq1es(wsE)1RCtwcrB(l)v2v(b()ZTx(rKoh(0mY4bggygGiqGH(lfAHxgKpFoodFV)1WeV9sWzHnyOJWtFk8NbAAag6)nUOvM8Wm)aHA)qiwey4aLF7LNlemXqkPyo5AGitpJhDp8LuxjWpVgXbUfdcVrdmC7H4Cc)PKugmHGTsIuIU46ce3eCdhc(LfDJUjLk(u(0MEd4tSbMD5NQW5uXPQkGTZXVYJXQNIqQLimArz749rAeOKhayj6qreWNWktRazZNOeO)fK20(KhiHrzCEQxZ5oF9G)WqSBKCz3PEl((2uWTM9PuYTXdBYPZbuapO39WBunxWyaBUzO9PYnZasuD2Yak1JQ(oZhoio)bHDX3FoFN5Ipb7KFnMextJGXIR)D23)FJw)vRv3FnhuTdXb5FL(A9Tt7Ys0EmaCv9HUXO1dAbAkKukSzvR8PzrjB0fAa4edIiFaqQ5(GE048nKlfJ1D9UMlx(Ba)QGFamZaRZ8cFvLenk41zbzZCt2ihMHsEZGWcGWiCNd6(RsIKuaTmwCPhkky)Fh1ztA1VagdkxZ1OtlaB(Kkl1ziw8Pm3KGBNbge9dN5VeJpd85uy89nNoUhr)Rj)YzwsjgEfC8V5IgXVOAO8OCUwttJTOXpJuYwQOPkw8bvm2nGmDmVnCL4L6CIbhuMb8OZ89isPUZW14fkzh1dFPglPmcDDewibAtNNS3QrOO7LlmTGfWdm0et0sgZJIIM0Uy2dK4Bt0LfNYwKGbYLXWyd77rX0gWCVAaTU19RURSqQbk)iT1BBdBkX6k8FFSUd8QUFHR93gUWNC9GCHsYhR1GRIfUer(yDEG7VYeMtbtNRP)iU2qDl8FjfFT4ywi8Rv0RfGr5z8FzgwabdCqUCSGV)PZysRF1riyTlEOfxFvfasxaI2mqxKNBmVOxgNO6MpEsnRA1JChN65ibQsbgUuNXl02QegJuS7O7wPMID5POCRh4iJlnDMQ(mDYsNS3IMz)wiAuU)eo6UFTWAMLpZGtF6c)D2kOegO7rJg2AzrHVPUVakV57sU1c2qPCvekUP8UgbeYuww1BxiRH)uqok2xefNr)k(lKoS(TMurY9IxrY0N9xuFbJrhwo6bekjyVWGAMjL4xvQW)qG68WOaNnWvaV2F3SMfwetu17ZfKNtXUKCfjztENrMAb)C83KVbEol7gg(60Fw(Tx4j0sCRCI0sXa4wfgLqa8DKBplxYwGyeO)ydIrdnLZ6g3lkibkQaRTfv5cHIVFVKyLfo2bJAP)cmErrjVKK8v99ti)RQ721ZlLR3(0Y4NLN3cKHCyC0WjT6JuV2CrYUNFht8hfS3thTJUVzk)6DAtqRwFITblAv7JmjIshYFRu)iEbiMiWFjM4F59E(uohr2YP3M4V8Fssdgbbyuh0JMweYFoMwcruHfdcEi4XiWWSbbk5qopW8keTOs0ilbWXKXWKuIaHG6IOnXbmiMN3(tFp(BHa(HW1OXnTkKAkl)pqno42EzyyptY3aVKzXjaBiMBh99kLmc2oAlZtkHdslkkQb9YKyt78NYJZ4jczd15gezfLOa7DE4gg6kHKc8)DoeFDz6Ml(R5HuoTKNg983oxkJcFnope1qwTAf(kao1HLxeFJzXr(PG4GHSRox2RMCec)QKr2UburIeRpIfy6GAAaWpZCtz1JYOk1z)qeYr(rqW4Ax)aUAFI72dmaTG7Mg8hzEP1YVR0AJxMnP1d4zk9Q9u8gf5gTIjFclig4nRhY4G7Yb8u5HPalA1kG1K8Dmb4cslQIcmX3GDftSl6BnMbpjMRAPKBH5C1uN10CLP1Z)BP8vT0EQUJ0GZMwdfVQ5mSLuxqR9jsbRejc1qjucwawWPykTv8MAQYDDxm)bUZ5gQbA80PK(rSbAq6yce(01UHf1Dic8rhfXahaW3JGWn0JV4thE2ho)WZMo9WZsIenhwtjPRU39so(k6nQ0wYBLrJyynXt8xKrkrkMTK8qRtMBeZy(H6Y7MMX9jK7PEBvI)BtipFMIsMPKzcbpoGWRwHew1WQKuaTbSJh4bXkamcrBk93PuRplXd2hWuPN4I9GNSATm(ASHgVQwrBBj6uStXeERGcOPyw2)XyCTXfirGGU6bmnmEQQWvzkfAOlyXjiAowqxEkwHXMjvp0LarINMli2r38nVBTBi6EOZRbiXtVpvW1uE(NaM1FGxGynjBt29udbZCTSL8VQHetRZ6jAEMb6P2wPcJLBBnyRBXJsRw0RkJLp88(0qZSmq3yGbFcx0qsjviEwspZxAp)KaRi6EwXJbLFjrlaS8TtF7pzYlQAoXy135ET589tSelw1QZwSDfwcAl5u65qW0tA0p9oKJuzbpQFsjc6fNRkuJwrqzq6)(8hiHXNF8OR42zo5ZL(21ePUP1zF7YsCALERjix1YjMhcVOL8krnIpe5(4ulOyoNTq9VsWyJh6OxFgtUqmqrOWgh7Bx8VZPu5tEZIYf6Q)(tyN1(FbBy8il4TFlSu8w4ksJMe7(nR9dkagArN7RbpaDWCgMNTHu9sVke9CsezIiwer7T4MmNw)vDDdevppxcp3rDpwpP5Ag9CNdZvIVh6CNNehKerg1(t(GSkXNXZByzmx7ugbnTf0RrJbvnCJ1(aOmtGwRyDJQ95areXes6v6EcjVjwoVmiKsruP0ZiBtVHU34H7v7dUP3kfRADCw7BOYruPuZspM2gX3ExZPYO(zFGg8EqAbZ2fedzsuSp1Q(C3GOM4I6ETKImGfdowx1hbGtuu1KIGzi5gFmhaei)W51IzsF)63rFvm7OIDpdTAMG7FMrhZAokmo5DiMPHzzrGphmHN8onMQQEfBm1FZXN0EutJmkJzkIf1Cd7MwRrqUykgzeGf()kf3dqi(Xqm6Pf0GrRKqm6jKF9l59ObVdgdON)Q0NZzQafpihgJ(rVuUgwEteMTgBWJJhL2nLH3BvakgmnMWil5iAgeHHU5WMp5dK5(zP(XRJc1fM7BFV9vALbUPoIyNu7wloZ)JMqlNHcA()xGp(XrvLic(7PSSzZJcZthMDZnoZMeV4(tB175gjYlV9KBO9lSxcT65yNcW3K)RzgA)H7B4TCVDrhN4659PyozPuWNyynlPZp17p)ajpxivZirfFx0lQ3DHUpC0P7IccEAz7Ci6EvDVQu5XmunHU2(2pQMqWx2exupnMUkK1XyZtUtU2)M2DT)mY1EE54T1n4fTwyl8c)Iuvd(UCuF9QiYMFz7)9uNNwlt)OlexC(7WeOTKLG7m6z8h89gh4x12PBT7ypvLgApULZEGXTqepDp71IDNtWX0s5wXsswGDQ5lPfLCYvFys3qSQ0DI9MrMHwnPubXU0YfuFbvRXByCd4V7CmaOWScnalCJRrnE4zwPuUWupAizmX6mP4xDZdvSB9mEVaREUaglIBnZq7SulKRMBPRE2lhAxsebTPCbf2BH7w0jF9ZhuDclWAOw4sf)00ueIPF2tX)4Cg1BVEyxDUYf1WIQEXTv(saXZpEbVbEB0pDtUIoHunuOK2iXqeCLKQwPMyYKM4gp6hcKWSMIk5Ez8KQD8lpXuiE7lXs1rOQyqZReR83QES0O4uPOGrRINQ2eu2gZyzNm4uU(KDTd74UP(REshE1NvOaV5Mm7NUfzGN85NtG8y8)loTuLSo0tqnTC6c32dQOc(Z)eqx5)c5MXfFIY9STUtxTPFArpjpeiSzG4iKOpJW2RhJcgp25OW1RfDkDzqYIMu6GYFINOjC086OZk6PeKTU44VGdb7Vv7D0ErZpv3NB92IQ98AiZ2FIeKm0eyn2pvBL70sdnILkNUX(eXKVVJVpRJJRWK7NlKKDGAT7LfBSfTrObUOYc3sDiR46CalfYIa)yKc1REya9OgP9StD613C9qoZ5U7uQcciwP3mUstL0JWj8(a9fpETHzbJHLQR0U9FAg0Kx)VJWIP6jKW8uCTjiAL)IYlZbkzU16QU9IsIsrE0T5L(PRfkMkQ(JOengCVWyxcRjEt4DJ90NXMwLsvf42G8jBRd5y(b21Pk83w63ZwlqLrQIEavg6UuJBM4mQhMKc17darzoPlyPg5sTznnFg1lRMVHkqlkJE8TBOt)C6SBysnuI(FxZHBJjZVEU(gxDS34kZRGAclokrnYfHAF0HUgojDoJmhcQQR(gkqNbynze9KwBuRjfX0QlHw0oNGt8bZsVfynqnDHRb2q59kRdOzYA389RvS)et1cUmX8CweqlsAquM8VRMIEudM4zfAwiTARbQkd14u0tOEOc2GC2bfbgGXaWB4cqSHUDyW80e7cYqEfGQQIu4zRtW1k6rg(7IXEmr1HR3ZBnd8fqYPuCjLE(4fLphRhhsDlX)diupuCc)jpHOPWDjLb4Ptp6dNVv6KNZDnINyja9(XKsS(t8Sg92O332wzVI(lU04JazM5mdhFAHAKUwcBt98uVYL4WmNYgyTIzyGKHm1cYO6AuRnwLT69qWO2kmgV4liVMpT0rQ(p4fRyXyPgfkP6QIMS2nvkNm0sPjcgoGoTCmSRY(6IGCpMj)okg04zBCdZX(Xrbtgpe3HMvLzaCnPP9s7fQ0bOEUMhvqgAiBvvQuBj9p6opBqBvReR2jgn3Li7MS14hhzRX)bv2Y53rzRXnjBzIG1o7IJLbnUlYwoMLTC2vzlN)dr2YPleJAM9D0m770CJdvc4BGaRb30RKU6GXT(DqzB7KDNrLSNMxPIjSnTYTtrp2uY(nPzPFh40BxxDllSXnUWgFFxypqffp2Q8(nsDwxkQZVDIYh3LbnUDtsTdeNo4ZyLod8VmdICXRqPr1FWqRO1EagnE9CH3euruVCqEPJsjun)eVoL1IRXUgJADzKqxC8FiF2PwbI)ALRjUR7yXhcz(8N3o0Mhvu5Js4Ovb9286Ob3(0y64fsyMT9BBkiTPb1pDOAy8Drh7P8c4wGBQn1SOcv81vCc7ACVB4y5Zn3(vyQtQ5BEjZXLMt)WBkZ5SMRauEjWKy88MwodezhWwXqTASTMiqZmwoTWy5CFySC6OVAsdOnglJ24(pdgRXgzSmUK)nKXYELG)F66FmJ)ra3XmEp(9BbtXFa120U51g781)NU2fZ4)VXSn)buxs7MKO6gSCUPkgu8UkDZztxNAYnRR61eoVjVteD5D5ne(wENEFeNyREFH3Lg0OFtnV2PMUeorYP(RuvSq7ftapEM4j71lkBMACCkBoMQzWFuxs978QsxOW2XdOdSmhBQ2e)rLc10YTdR1jnNAZ(v6amvjN95LbVYcDxUp450o9aPpvk1UDKfQdKRXnNlQ2jx7TRb(hmbRv2ytuvLgoD)rwDmfSUINbnlvJOAB0(t3J3C8p(e)9nf(yUruimMfrBM7EpVVIKCyaZSogPis6Q5nXVhpe8GzJFssucYFSmbwd5j4zjnAte8xVXSlp(RczedfMNqYjXBLVFt08AYKLZDGO500c43NhUJenNDHO5ur02PlciIOX(35(XXmVHZP7fo0HWu5jroz)MmHjMbSFVmnhAGj92WfLt9yXpnJfKc)k9rgOsxKreZGrH73sK3QHJNW)KJm(et4AMB2mbiu8S9VDB2AS9TOCtsNf4i6At5WTx(5i(PXZhVUHWUsd7IYnSYRFp4xPpZqOxV)l(XAGUsdXSwst1qtkOLOXAxXil8XS(FdGoR3wLpte6ylwuVbloGsWYsm7NWkFJFyoQJL62HXv)UaqPQ7u1Lv57MwO7M3vBmFfwQLsLc5VXCdVOhjOIlEgh3302mvbivfzRJ4zTdIKmbB)DJP(RJYevYV7GyrJrU3FBljy5rHa2qQCQRuZibupfxTltRURmNfaQrH)jLxhQ8qSFczjM2bdVDtod0uhs3evuPIIPlR(2dv3Suqr1vvenFFXLKhvtHcbkHq(w6ErdVtYGLfDOM43eaCIO01wM49oa7FuScfE83K3rPLK6YHZT84lvrJHBV8V6YXbS9tbAcEd(TjYZFPpD1AloHSyPwgp8KVoGR8yLV4kJHAWl8IqTmTo4JLavXkBO47pMXzjDn)wvhBgSf0HYZJ3fOsJUAg8dxKGoJLYBqDpM4xHP4TWFJF1GlwuvZXYIZwIRKIqEpOrNCC6NOoJhf2k0mwqZ53LH6PmBhydD2b2qNDHn0qIgnRdPQbAQDOVBFDmYmRDzoZiWU7UXAeSoAG9b4OhjJMKp)2z3SMfeplDnXCuxogSqMgZlmmWE5MeInVT)cb0RTUf1tNqVD3Lk19UwqpNDg9CuqV7P)yfaRqSRe5DuT(0AzPKTFB32eUKBZYLQXl8rsHInO4iZzakCbA(iKGGQ)4d2k(g(P6KrNNMXMNg9yLmF4xFOBkhRUPud5QEHUVz1ATokFAn)HvVZkLCTxIg)OVBwDR9(yUDU1YjYDh0cynay5V5HkQd6AGFM22ld2X8mAskvT)tOL790JwlfdAVOCPTQwjtcdUoGNsj5nb4psRTD3zZXdhPNyk5vDYyYyM4sBvXnWprf8yS03NmcgBf3rj0BKz44VI4ucR1RWx1RlwLzU6EKEz1nNdDDaYV4)wdo(q(EwCHplgyEm4xk9aPgCFifC7hOJR0g0jWI7q(jPSf4DraBtkEJewEXWMEddCkmoIFSdZOJem69ld5bXpXxOJD(OewkEWKWRTqyc(Rf4eHjBI43mx4vWYlWjbpe)PC)BNZwrPnexqZR(w(HxtJdrcH4Uu(fuIKm5o0osCXR)dj4sjZV2rZRJWv7Exw6IFoZWXaRZxLZkxpWvHsAk5UwUHyAQqNs4j)RaBhkBJTlWFP1I(9Nz9dp2uAVDkhyaZyj02E5pb7o58lz4oCYTm)PUKsiD19Jl93QIMv6gbx(CZxEhlw74BvBAlVD40RAvfX20TWr1tj3hB4t1v1vBhIpDk1(1rjPmLBVYxgWKk0q7GTr5ahis0fjh)Re(X4D)0nGVT(03iuE0IBWAClK3FAzoZFkMqE6M5ZJN)mq4oplsCaJ4rqcHd(DFVpMbo8Is8DrHWSrp(Pf6852YPn4Y4mFkxLXt1m4xBq9h)1b7ZjOWJI7bO5b(DBtyE1q2Va)bG14EVl)8Y3eMRoS9)K8awbKz(MW9IbSpb8daFrr9MqxXZ3JGD3r22QcIHjQdVs3NCt(eBEoTmsLPYXYu50f9cwg0(EcSTh1bqBt3GXHSFb(daRBsNG1HT)NKhWkWS(bddyFc4ha(Audr9NVhb7UJSDqlI(e1HxP7tENu800ivMQxyvhxTcXyq7MPX8Oc(hna)7pExRGwMTMuBmnH3rXmocKYJ)(P2slsV(nH(FZ30uf8oD0D310Z)MVPjyJVDtRWbfKH7jQ)GW8hgIxUR8sRYZTZnzEmkB67BW)Ob4F)X72fYmpMMW72fYCQXPAa93BczgGTcVQHvODHSUH6pim)HH4L7kVQjnR2kNQzDSnmAfgHgNsRvL18C20W7(KQwDxZZuTXOa()CtYoDMm22O7(u2DYyRdV7tAlKrZJrn2rB(WzSoZM3OmmQDyoSwiyZtwtdxDwpUjkxRRmBJAhMJUVYAD4QZ6eRZkE1Mn0n82zEXPnzuY2423ZdQuE2dg(80WZleBRlgTb)OmJnMkiBZX4os1SpU998C)2D0HFJ0Qwg8JYm24UZjDKd4Hk78WNNM3D6k83FYo7Pz8ET70DE6h2Ut3NN73UZoYjVh2D2XzSXDNgtkqNY3tNt0S156ri3sJBioSGRn6Aa)p3nOm2mugRbfQ6GlJccIUHAiaxG3I69ZQ7eqmQnQxd4LGK)bru0Tb8XrD75YO8qLr75Hd2ZnZDUBk71B)oQ1dWSnc)43zOSKcKeJOChQkPDNHkJxsCOImqsnmefY7(f4DaSOKqX7zrnM0JFeX1hvG3ky7UgXoP59HpnnQ41o4BpvnDiDR7BWxcy7E(06MQXHOG17xG3bW2OOtTh)iIRpQaVvW2Dx96KOZdFAAu0Xo4BN3UdjrDFd(saB3T0w3uBxz7(f47cy3jIXUJ17e4BfW3pbOoI13pGVlGDN0zV7y9ob(DbW7a5y3X6Da4Tc27N4shX57hWlbR9anUpGvdN3VaVdGDVKu4oG17K(JhzW3baVxil2dWR1nZ2Li3VaVdGTDsshQcthW6Ds73Jm47aG3lKfB1(6(j2)Oc8oa22jjDq4Pdy9oj0)id(oa49czXw59UFI9pQaVdGTDssheE6awVtc9pYGVda(bsw2(DFKYohc1xPM8pm5BFzQBE26OKVmDQ)M3H3dprl9XdlZF6pT9Y1zzXPV(OJw5NToFoG(Bok1FtEaH7lsCxMH)(IJGhSXpl9OS1SBCtWtkUF4rVLMPFsCK2(EC(oI)fUAMh7A3uXzCHUFp(oC2(7X8fMhDp3XpV5is9A8ZDzcEHD48k8wg0H)5R7LtMFIN3RWviFrLoS8ar88tpQOjpoapXpNkOvfTt1bugSpTIixV)GRAjJ6T)VXNDDvpUA85u3KA8jyUuLFGFlDsP2ynEWf3bAIJrAIPEMUAIR3zYgFMrAIEh2A8jQ0K27UuTXEFPjY3EpccIXBdNUdk8yZEqu8P0PbvaYXhuDQopD0WtoO8ZTRLzdKoEuVeD2L1t5PAUb6ZZWBkONn(ecZFSV1D6cYxj)VJ7hT3qMguRVV6YndGwUxXm1pM7cXW5btmQ14Cg8gAFrmmaAzIHP(MJy)()Uzz(pSBwMDHfU42eQMbDF7DMNMaK1MPt3mR6Tq8oGKoMrYgBFqng7oGKgIxyxqsPlVgbEoAxEDNh2RxEfYyAJuVr602yS26B7cc4ybbm2jFAe99ccui1PRo2rwD8yjLXpXQPjBQPV7o7kWL0GBSGqdEwFdVmkap4z2Ev5UfzWz9LSy25PyS2u0udPSt2(QtU9xwzFZGBGhlVpudplbxx2FQ)K6Bq1826z1EeqyaI6J(g3B(lp(7CpKTotAmm5()ZDEMQQsdJbzcA8cHPUSvb2C6XDzny5cFzpi0BLPQN0Qo46GZKPu49(c6JuhU2v6YQt(IDPWBYHJEM89tmoB)V3RALUqeLVgvoqiMC6lqoe6UszxbbEtSucMj7eyuU4vkHXijyGPTPD4Gb1JWbmmgml2xWzu6nVFiMvOz8ReA)WL54LGXSrLAxoRtEsODLUugmtbApgLTFI(f6YD39KAxHlepAhVlvSGzQxtl4mB9sEHte)LP3M4V8FYdNFn(v2f8opb)suSIcwbIgopKI6aMNm03C6leppie8Axb(jXh(hH4enF4laE2JIwLxNlfS9UEe84nMhS9K4IoHlu0KwiqgfZ5Q5F61xL4ZwwMvbVCi(bCSgjc0L(I8sVed4F)8RUez6vfyNYfiJz4wEDSib7Y)wV(pr5EzPA)v62yXI1g5RKfzMLsGdU9jd7E1HmMmsffCGkcG4XqMrEiO8Dh(hjz5p4i4woUxEtuYvebM)vOhvyTX9R(BY3GAtYaDxfnMP8BVWtKEKBJYtQ0BcB1GnSOecGVdvAYwUKIXR47pTKkPAsuAFuu0fBRFR0JEku(ygkVdsyqinjvd5Wxn4S)s1GK)8ewnIbCzIps6fGa4fQoaHoUTPpk0rKYdZeOg3(uuFS71U(bC6oO7Gw0ks1vkRG1QqRtPEjKNKVUvveHCce)Q06npU3tmUguEGHpUIwP1XWlndmTmZ3tIT2Fdypc(HzEW(vso9UQ6HR8)XOmuXgZl7XstzHlyOFx(l8Zo70X9EcTSepaw)jPz4cOFIRV3m21KEspVuq)8zNYXBfyxmHpB0WjLsgByGpDUjG9XcPdi0xwoiP7oxKgyeuvF5go70J5PP5xEpO5PiTksAdlvvZnfLsAFbDG5jKsk6toEok8XZ(s5GGhcXKbK0niqjR2zKIvp50mMJFLDq9BavkJ56jLchmPqbSVcQ9)PVxrZO1nrv7LvBJLlb1DmdCv9nSAFZKbnpLYw9SWsutu9StXpzCGMLQWku87WaY3ZSHYpLhlYL7g3sFSqwOaGCI7kRDJJVvEf8VZb3bpGNOo6J53PJLFSihhY)j2xJrtnhiUfTawFa)8yCcOp5Ej(aWfc)uGlff0qoQ)k7kGNdyJ(HiCx8JkAiwYZOvgOoK0ua)rMNYM7c3Cu89xRmk055)U7m80fGegZ2dHFM(GAud3)eAGAdJB8hjZb(OV64pLfTAfSXHPUljb2gslRA26OBG)Lf7cEqXq3ekUEYKwEC7ZklPnrOfqDZZIK4h4cWjokJB7F6N5kFbdoazL0(oNBYcqSPtjrxGVHsNj(Xc5A3WIdiqumi7Z97hFpcc3qp(IpD4zF48dpB60dpljQW)OkugMDHg5(1DB7U7Qlqna8hOb9XL7eApAM4pJJqxDLZayIaF57P8Ho5nhFIkRdeWd)xNHvAvjawfMSK8W6deDzhu47Vq42AnvMTcH0mHRiV9hFVArF))T9YFmgDIGZQGlx0ZILuenOlcKFFUISoVkiAoA5LCUqeEg)fDrFczO55Z3E52lp3nFZ7OekZVzxUik8POlor8ee)bohXpWYb)mL8AgwPWsqJ8FWIBxaIe8VYzPCsqFtkZanMfAPsanHSzx7VkkPYnnHliPZsJDd7PsfFdy4PNQZI6OfxcrrrfIks2hbbgQGBGm4BEHWGkxWbqnPpANNHfsPx)I6LMII7Oy7ku(Cg9jRlvA1uBi6SHV50jCRMtHTs08wHlQu9gwae83o9T)K(6rXZzoFFOBm(xjhxkC3LH1vDnJRZJx8r5Dx8cdBknRxCUkNdQpa3OP)7ZFG2XF(XJUIRX4KpRJpsEtizWrZHHE19SOd(EP59jkiBE51ZOl9MC8IloTGoqtkv5rL88NWJ5X)ffrwvCtu9ADfjMqAZ6M1(bfadvAY17WJgaKRXR(XHG)UBV8QquJUWVeHNi8HTYnzofdGixg8qis5eFh7eFJHrPrBQfmvf9v5th3ztQ)iE8RPyj6QsoOwifVP0fLNnEOJPyXhWzZ)wGBaOdj(EObrpj2oPGGq9sKjOQOuRCzuB1Bwb9Y5seJkKONfDp9l4wsWc8TaDJUKnt)dOLUUM7Ut4YgUflXgxtgr1BRp7d8vVh4uWWk5FxifFwiL)Kqkk0gfQzmy3MOfFG2tbVXixLHD5KB8rVFjq(HZ1Ny1Vr97Mn3MIVRAp3siIa)slJqcegMGczyLViB6K)b1uRXnADFSw9OzDQrJtsHXq8S42)qkHFzrGTdg4LGJHGT6zAKJpXSpnJiQ07OCal)5jfOutr)4aG4)RKxAaX7hPV)88egJwce1Zw8fHROUVb0ZFv6Z58OGmdYWYOF0tC3cb8BPfzx94rP7ISBh5rn3ZbfAZmgseMh1knusjqSGDdfVML6hVokCaQAOoz(vvHjRBGFqx1hyEXVtcO7Vfp6Enb))f4ad4Cob8NabGoBEuyE6WSBUXz2K4fDDDRkU3I7cpXq8Z6z54yUtsK3kO9vUkrFYXuwk5Hk6T2Ya0667p)ajJiKWkMAF8DrJTV7cDt9OL(PKNYiSPyBEpxwTnJVDXHxdzNHCu8ngEaeip3lYhKgN7UR(wxpL9xoc4mOZEg8g7EgC2irIFKs2Z3X7oTiER4ejYpZtDEATe0G2)U483rzghcJeif6jQbCAch4x1P9CSWij3lktw2BgVADvoXJlCB(YCw7(YOJjX3MWkDfNtv8Mnh1qYj0GIzNEgnTuGrfjXzIL5d7QwKc(3CrnQxij4X1r)UZr3fdZkeew4gxtQt6Lmr0U3X0a8qL0sP0Fk0yzfIL(a08WO)3Z6xudPNpA44bseKlih0lSMHmloFgthyi32dM3Zclw8k4v4WPF2tX)i2)uWl7bw8Cx5Ic5fn9eF5I(O(Xlg2TiEmfTHLSZsRGF6wetM85NtYmhJ)FEm5)JOar32spzSdfZ(cmAGiXU9Hyw0Jc4)cPYcICZcFzFDVhMCixRKjeg98RutZ1LiIvhIlu)ywM7mTCE8SrdF5jdEacdv)nfbTb9mYewyxRb(AbFQbf0N60WZgxyJ6St7F8HTqnRg6jno0N5i4T5UQ99FOGHiG5gZJ5Khl)L4hUB)LVw0)DLXgayyiy17GYFIhBjoAEIZzf1Sc3QkQ0ioK0iad0zGuQKMjfTf7fIztqVe)MQlkgdHOyR(eXBA4BNr5oKB4cFKKrydfFc9NfKgrOUu4CwkiIUtfJ7k2DCV7LnC(w5)DeMSqVII9PO6oiAf2k48ClmTEEvAsLnW(7hc)FQ(XZOFBgSLWpzgdPAju9emBWz(adpy7tPWqsj(6Sc29IeFn4GYmsRb5fb(XXLzywluP7X0aCsDDW2KZRLxT2S)aWYOOwPGd62Ys)01c1RfPyRiZC7OOsH2tbu6PjOu1RcVLZMlIZxehRp91uStHqSkHXcvQ7JKyJWAKUOupd(G34c0Wcs1rsCOGI5FLNTJpay6CGQJeutRe3Fnpb3ys8VQgXtK)73l85fKtWykkk5xc1WtybkO0Oe4VquV(OIuPi3SomQiukbNCq13WCuOQ(gNoJ14NB0lC5SJPu)WEwJ0SEquAUYFw)JFUPKG88jpZiomOEuIf6YWpW)Y9Vvnj3sFJhRmmDKVN5fzNjXoDHe7GT4NzIST1NZWUU80ieDgZpUly(Xp)yBy(tmTt2qHcSTsp94HoDCTQru68sDsdkW6sjnSXFkeLLZaLQCmprOjImHgPLn0J4avwGE5CrgWlCgxHvtslLUtR9TfN7PsrACs9yErlqkk66Hfffl4l4)B5TQZBovjbCDdFp(3g8TFhqylCRd62czYVnletyy3qqUVR93Z6kh0vLL6smNoEW(JlYP5129wp5oS6SS1BQe87V1nj9yKRfSmBLCC)vM(WPhDCXlQBg1VGtX5pT4IGKuqM4VAfM1Dn3glPzK7GO2(nSe3amA5O0uiCJAdqRxxft85vn(80C8SXqzAGipvGinREbUa0igDPoCvQ2a3ZvJVI(w1xQ6JrFPSKoAvfTq22l7Z7Nf8e5kyPgOH0AvrRg2BiqOhuXZ49QtuOu(8kYneMk4HBV8NPF7Z)8pp1POJ4W)luuRlPYitz)cI65wrKmXr4QhMYHAlstfe7Ef5RujgKYFnpERpUelJoMXbsEq0skuWX8uUtfdh(jrdGgX3XK7h2Q87r9C0c(rHKCuW9gCzw2zlFAS(ASjBw9Tz0s1WdhELgMsP((cyvvSGnqvDGuV91t302YCqPscJNplQmnwkmAb8bLlXSfzmVNpHxxemD6fvS4hI8Pd6z)pKhGNcIC4N)ue2CqtZH4E1zSBYePz7TfGDwcavRRsEpfcSMlZddVTQR2xff5H9hb17RcgYPVRJ7sKXnR01gdIT1fBJlKVLiTVELBcMZTQM67Jidkv(j8q6FfVGghi1rDldYNphvw)9u4Zc1Zhqp9PEuUNdWYTEJlkQco56hOKMo1Q1wwjf(Mnq1Kp4g0suuvKoufKmQ9mj(Tb9OblhIFdJ2CV4Zbbl8k64S287vmkP6pP07f0gP0FbKo84DKWtS6CHLvBLD1xC3DQLf)0JhHyDJDoOXLHbbwHoHATMyHYb7EbOXI(q2)(doXVovRjtKp)fg7LH)OSPbYD)8A6CEqgFiHD0wf3smkOIhHJugkLE5NjWGhgpSvis49rXgw0n669AkXjY5BN)NtVHodZ0Aw6VupKQQn)wZ50PovzYtTmZnQGKskhOkIUCaW23VmDD8ooLFfdiSE3N8nHQCbQO81CE(xxtuOHe19yrmACrEErQHXSfZBtGZ5lb6i581ysznwjfTvIEUtn4TOTium5awPFwhAZ7Sbptu7cJ5z(Tt3n0xj9S)MI(CERq6KhqDZ1CFWgAC(gtw2T2sSgI8SQcYKXwSmYiN55A9QdpYMoxSxdhFgPS9Q0oSecuRC(C3ZVwhbAQoqA1)Hk)IqB5BoDmFJPHIGSBfFPnOzVjbmw2grx9SiHUgHyy0aGHmutjey8v66dkkNDHs5IkpuBZTalQQE9qm)IurPkdmH4PxarGNO09xQDolxr)dBdQOqD7eH2o5YyrIk93Cn1gtVVOgmahnvegUwyqJBXvjfOAT48vJ2RWZ2ddRsO2cBVxIjRhqJELMA1RaSj)6f)Tk9AQHOPw9juB93cHDix3j7QLLlEn9hQvGzl1JUu1QX5sxhADM2NOXxxG72XzE9lLVq0QnvY3QEfhBfyiOLn)m2gXHmr5YMXIg((Q(Hng9dJVLw92jm8gkSSPNo5U76BYfoNrMYVRwu2AVZKrg7E7YS8mz0GoSsbvWjUb4nAHBmACpCnSlYpDZ1xYMB)KgXcEMM(S0fnvrYiiZm0D)ewQYIJTRN46R6GI00G9Jep7EalavutuWfVD1W)M(9Rg6AzXzrIF4T4VlMtRjQ9m0755)dFbCjl1JuLnpIxuoLYfKsSv6IYkJA2sk7y(LjF0DjLbTPtp6dNlNdhEyR8(SeqVFmPeRfx1d))7URLDIyyyGFlCbrfsOMuXnajoWVXIeI9axOiaX3pXPnpAI9SExLTGQ2J9HS7m25L9Spo(egOiHNl0Ivs7T2vCAHcDFFPPPsQBGSmT1iExZGA4qvxUdGEJa3sAlOZDabhX4ctojRUJRjCPH4Iot(FYg5IDuPtYOOq5MhZh7zvwQJrVscA5vU8oXk3mpuEQtP7pfLLwczpOOnPukmvozOwGkIRbolYH0ZBT65TMMWBRvQ3ZpV1EU4TgbEBTtIGslZfniERTI3kiftI8wgPnCL4TwKdPG3soYZUbdFDXwHMlFwOCUCYgPUpo2EhzqJoAvL5b91yiV(Uld04e8tDzGemwJOXA0ASNuyuBcWBAqmQU6BfvFaM)gKreg)GMbq8CRg9TgLFMq0mC8Bf)8ZLeiu)bprUuO2w8ZlY3OEtpw89pn9iATBVV)TPRF432lJHkDp9EGX3lpRYQzxDmkrwyGWmuwqi0OznOlPqLyxcZyCpT7V5hVB)nMlV4Jp3)d5FoqpBZAoEYimveWKN7iCHvcD3TfN8GBPrd9xlzBDhyHmY4PLhpTaLLtnEAXddNUgapzLb51gpnL4jJjVQ45wiIKZWI6iBBWT)DXHBHipodRX42Fq82UVD)297d]] )