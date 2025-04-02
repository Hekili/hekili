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

    else
        -- Other colors?
    end

    if ability.empowered then
        if talent.power_swell.enabled then applyBuff( "power_swell" ) end -- TODO: Modify Essence regen rate.
        if talent.animosity.enabled and animosity_extension < 4 then
            animosity_extension = animosity_extension + 1
            buff.dragonrage.expires = buff.dragonrage.expires + 5
        end
        if talent.iridescence.enabled and color then
                local iridescenceBuffType = "iridescence_" .. color -- Constructs "iridescence_red", "iridescence_blue", etc.
                applyBuff( iridescenceBuffType, nil, 2 ) -- Apply the dynamically determined buff with 2 stacks.
        end
        if talent.mass_disintegrate.enabled then
            addStack( "mass_disintegrate_stacks" )
        end
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
            applyDebuff( "target", "fire_breath_damage" )

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

spec:RegisterPack( "Devastation", 20250330, [[Hekili:K3t)ZTnUX(3sMoNJD(qXI2oxAEXUtCCs7DV27UjkTDEtNNLPiHKynfjl)WoUJh93(B3fGKaGaKusu5UoVF4YzBaUyXI9BSa46Xx)LRN47MZU(NCo25SJp5KJhn(0XVE8zxpj)He21tsC9U1Db8drURG)9k2DUz5U5bXryBpeg76JWilUi1dAFzEEs2BF1RweKVSy2iV4vVklyvri9fEPUZZXF37vZcJN9Q8LS7DtVh6Aq0RyrlcIyVYl0nlB6Qy)Iqw2RCtcX)Bk7U4BzPJ8ssUEYSIGW8Fi66zMW8to53ditcZ76FA8PV(7bekW3NX7mlZ76jyNF5XN8Yto(TRVzsWQpS(M)AccN1)yztoNzTPX1FvbVPBompni6ww(r1964t49YRQxIMCEPZBGM(YF)VdTZCZIJwFJJsNo9Lh)7FPZyTrjRUTXiY9(WW47xFZvPUlIJG)bqJaauV)N)yzh)(x689Vy9nWhC8PI)poY)vb4UzEA8kXyu)fiA)LLaW(7UPW)qRlxpjmilpdxJz4)(teldlYDwiZ)6lVEIRhNzGLZsJcYFyAwrkYVWwLeFplDAE81tgF9eVh8cztZDH2aO9t4Fjna(KaxoiUJnLfXwfGi37oF9nJxFZZxFtUBilkFujSZMML4gnsm6RV5Xhb6)6BUZfad8xg55gnL91CwK)uFygCqfaCJcwfNbqq9BfTUcz58dYcIYzlsbcuDVoIGIocEbnSNiJIZJJYNgpF6k3fbE1Fp0HtxFZZ6CMCehHMvmF(i)QL1rPSvUbrijbOiJ((ZiqbS3HHtxcYHmc7S(rxWPJg(e7KLdSro5cqPbj8L7pkMiateUEd8yfzaStDJUD9naqZbQwssyGhcjyaJXbLw8hDDoiZUfCroBoxKdTc40NvGUi)oJ2gQVH1mC6FYwm9pzZN(Co0t670)jDXnFqFezANqIy1iNTGuAG(JuYt3ck5PTtj73u0e9(0(kWdyEoy)mLbgiN5MBsVAmyQlJLxpJkflXFkSa(FcdpJYhpcihtb5VPifuOA7x3gdYgTkinnof5IMNcZHIuMpq9xfd)17Zm9bzblIyeBh4yW0K0G40hOP9uUVhIEpDmnKzMuJSbenN2Ma)604gs0C2eIMtnrtx5t3en2)QiijH5pAgllhKidJbHgPb5EMBsCu9iOlukgHG5MhdnWK9qKNS8OTrhqTPSWm4dpE0zv46yeboBqMIKC8zJpLB)a9jwXe4F5bWbjWhV4iq91s3uFVyFu7WlbVOaZDxb)xWQKq2kqpaO3kEfdDOAb3xTmY9q0S4)Sanwc6HGFfD(IqOrMOlGF3t5OlmfFTDACnPRYuUMSdPU9qfbqV44q)47Jg5xKsERV(MVB9n1)1A1Y1Dau5DmNPS9(9DDns1asvLWYyuybyU9aYlG1hPTeCfZlWhOz3dlelR(yoDnXna8beJUq2tzWrfqT7Cwk5wWQGOc04JBKp5Qu5VlauMz1pCgulSs2yj)(TtMOw(vxSOXARJL1wNVzRTghjdRTowwBBLa(MnwMwLxAgleuJc)tgPQmRiYZnmezeAY3f9WQcgOPgMS3XcbHwW6DqKp6jRb7wjpScDhjnB69Sz6(jdAtwXJ5YTMVsiLdU88asFxLaOoQzGuausdbnlZf)jX3bmV(b3fqAzWVKARMsx1DU1LGCKxpg7F2O138NC54a6pdmV9Yr)09dMhGKGd9kaAtuE4dOtRN91J4YqlaxCOpAzWILy)idmKB)yZsGQCMnsecPXrjdwZdrChNLlDJwGteeTK6D9iee5LcbjJKUy4J9zIFfgI3d)T7HVG)1UYJXCSVbZLj3OwaSVXPL)uumQrgeOkvqusZZgzwKFLBuHBiYg(73E2qNnGn0ztydDmXgAshs90y8XB884yZKM4fE(GmCwob2n3nwJG1rdS7GJEKmAAXShME)swyY0SLeJtt5yWiceCbkiofy9CtJaX2PbEcO3yEZ(QxyHpzlE8M7sL6AxhONZgJEokO3w6pwjWkfjLT(8eP8euttQnaz36eoZ6Y2LQ5lSPP1Q5oICh7qJqHltZ7HeeuD7(OYm4O6buVhMXMhg9qI0mOnUAT3HwuS4J6(CrXu7MxxA4YjnvB0mrgQOL79vT39h(wSS1yLRbKQP9Iv0tOvulUK3hTawdawobwkQdmh4NHOMmdvtIO1MEXS00kthoD3spA9DxbEqoDVXhFGkLk8UqEcKKP1WFSDHZn3zZXJoUr(PuDf8ZuUrHOme5Is0xW5dxmcqWprf6u6yY83u6VJ4KjppszwXQk6DkqJzjC4ay0C3Iq4tETg293eFQWdkWyue3jpqhqkGElbhKiFufyFMOJfjG)Rudx9zX2qe)XruuWFI2KHvOZIuq1qFonJbsGzm2k47ddULj8yn7Eg48ysm6I7SIC051NIEjZqEva8KdGbO4zgGsZX9NagG)ujoryYQ4ucCUao8ACqaBJyGfOFWZylOmjItOzyw34U1cEHjYhTj3H2qI7u3yzc8PeCn5pupGBJuVla6Xeq3iVHKbjQLtS(jb0XAYETVPj1DqkEWsKzICeBo2sZnSS67gLdOYSuxpD5K)i6X(eAjcq60q8xFVVBsUqd)Vae8IWqdPSnJ39PUv9wkHR)KJUBqn)(WGKSCikJvk58MYl9YyaRhXJl7a5GIzWY)m4BYxoQiPEos9NgwDd9ng25bahrECQ6OEOmPMfTOiCUTfcY9rGycsLsBPunUunae(OBMY0AVbusAdZ0XMdAdtQrJqi2vW715HUKgT8AwWw2xrqNa9)1Y7tOlOyibdJdv5m5l8y(EiUaKRr1aUZIlejcAYeszbUPuy4TqSxS7CXuYrAnItyrmUcp87iiCp18vF(Lx8PlF5ftM8YlsJl307AQ1HTllyENqksk3ur(NxXhLT0npN7EpQXL6icaFgbcTMNk(ZL9sF3iUGV5xLBRiOMJgZ5qy85tL3wRtoB7YJUPKcvd3k)0Q6M6(Xu3vyH5nCpY)dQFaYbwkx1S36jcS26fO)hw7yiAYt7c3sweOnfiMY7yEgpjk3hNElzeHZWGwJw5(1GvfRqtf5GHPiXFw(R98fzneyysRnkcMVa3TItja(b0IiB(CkVgSYebPKHbeTMwd3no98LWjbiBtb(5Pb(guWeScmHc)aW1aQ3k8u0mkBCP5QRK2nz2MVNyNyzzSipg0R5bEOzwXooZDrJyqfDbColnlNyx5S(PUb(tz3r2z89ZgHsX4xZNKkJBD(Wa3RoE0PkQIwXcb99PGTFZBtzeRa0d7oliSHHmtYmNGSw23bJUTWkz0UXYqddQAmX)Jp6dFHi3EtEiny()lXYx9DCONrwbtz5fPKlniRzubQZLNcWQobnMWsbUIviqjTD5lr2EF50Ht7BFaPif8z11xkpIyMjdzFfm)(l)z83Ia8dHBfFIjTB81xJ487Onh9OTBhAAvJdU2TWZhwW)QAKQQE)29sIm3Jz)BS5pLH9Kr19)IeHbPvUv(9IIbHarhx7w6MK8qnb4FvWqNC4jjF(uy2Hgjl3jHYEjYnO8WAix5L9gt14u(VmfRRhE19OgKxMPSCAVodUGhRiOxjWlN2j9YblTiY6yHUkBklK95BPucc)PfPGQztUoO6nzkPaFcgQvgXT7ZxfaeEXcKU)(iVaAl6(uih3e4aBfO4i0F6mmkH4vv2jT6fR8sqoFo2IJnAw0BVMeo082WiK3kzMtbEs207cwiRnu2Vnlf)HHsCsu(ihvQm3ONFAKAS(ZekWXG7YWG5(5eK6ZtYoonrBQZPa1qJJu8LUI9yyry8m3qHzvruN8p0flyng0RpE56BwFZLUfR(aT9bGtoVf3P1ONIg3J5BhWN4(79tSI8uEYU1DVPMUkzgAf4W(kYAjxt1RvSJXD)xqVrnnkQEoglofUIpQ3nQDeCj272mTfSTRetospidd6iSf5vDKaQlDG4bs1RAM25ipymF)K3)lYemUZOrUjyxlNosXnWWcwyjJ7KFMC4x2Quhjt9AiL86mvsKeoE1LQ8qOF)4so9FF5t0A)Zp54B5rgC2xmwApwCl4GU8R4jw8qTMqyZJ3sp1BNqjJc2JYQv)5myCTRv)379VkcslTjXtdQQy2VdRn0)ByLI7QaV8rPAEWvKzhjwN7xgewcmm4lESkCpUbf7rq)hT(MFy9n3gHLXQWvdHZf8UTWnDg5NTizqC305ra8CNwxCBJY2zm11RE8gRLYjrptDXBjQXotEJULZ(SMh(CPyHPnfpBhpYP7eSic(PlFn(JaRnqHtdGp4ZKhLLcmsicQBLI5zrAa4apLBVsF1AZLHguCtO5bTAW6WAw5uC7P9OWimzYkZlo1dlBMM53OvttCGi8ndz4KKwv8My(Sg(ujfpw)CRkpiHVzUaXILPTw8Layo)rqmaJlfCXlnojGQCCULEKovGEFuN11Kq3hOLdYHeWpHeY1EyesVpa9wNa5NUCytgr7rEJCTDgmVG3VZ(PamJdxTUolLIAxR(hzYlwRUEz1Sd39cJ(v8BgVZm7AMjVRLLCrEVruARZJbFqycp5DAn24dk5AB(LJpR7CnDSrzSCdLnGYcYhO9h5tKfQljgfyrzcM6oalc(3uI5G1PFoctVhFZuqNceL0Iatkl9JqQ93K9CUehO4bf)y0ps7wa67klJcSg3jHtooRFkd3AjqfJkgdU1s8S4goOBYO9t6azsCAwqYY4iDzPdTV2(g1uU06XLyJu72OUo(paYPC2BPX)FcE2NeNxn4pb37P8PZIJkYgLF)9otpnXB7PG6vYEVILNrrX3OUuus1VLK30mPEua(MCxp3qTLSTH3AiBHumtKMddnUY9RtfDyVQJf)ytlNhOT6xJSoQ8iBJ3MVRBVnVG82upp48qKqNU5UseqXfZYOaKXGfNtNCSpE5lK8)Jix4Se)w0d8pCLU))0jAJcuhHnLkXpsiutpYZnuBlvPuH(Mo5f8JZLvCmLxYaANhejQSDNTVyhD2wpdTszL9h51TDmVWnJfjs9PopTrMurh)U6YpG5SDolf5H1ZOkeke2XVsep77phXWX5aW0s5wlJqwGDA4kNf1FYzk90EshkxctEiLBYwV8pQuqiPxR9v6bkvjvsAvSbs7gIKDcRJKIFPT3vb5MxHr1fD0ZXuan24ot9xrUI)Il6qXvsaK7IYhUedSnkVu60ZnHOT2c0WEUsOH5kka9sxKOtx6xWm8hXDOb3OLs3G4LarzyHb5pf)JyD5cFSp4gL7cxuEUSyA5Rci1(hUA0gUdtLEQBC)GOPRn)0jEn155V8aIVN(LNtYGNG)FEoc)BX4HmoKkFPxYfg4RzCPqKsd)5Fb4m4)cPd7QpRP5XKFVNsFzPjkJZurGusgAURcD2WWARTezwlyTonz8K2zm8Sg2mCUHshGApu1cP5CKvzrvhNAv0VsS1OpbCdaD2NXYE0WPChsw1Fzpxn1)0Z6XN(SsJtumOnQSOsMBLQHOllI1eEykgbwTn4hCzlnCc2Aa9Y8aNjbjd1rJYsIlFht44UuweOgdzUjvtSmPm(06wcBYRZXBZ84KAmz78Muxbop6Z)8Nkv0iMFGgeAcIvahQJ8TItvqvYBelhVO6N4z2e7nFNyzLvLaoVMjuAJDjlgi4eVJEyXGuhEK8hRHI)pX4o35laQVIzMW4f4HutCG))IjonS3PPfj5tXA3uCxlG7PGxyqcoxpOzOchKhasQxCUZbhAEpuUW5Xhv25eGUYa2QhMstc9HsQjCa3gORiWyBJDUqvXr9260lnxw2rMUDXGgbl(iLBOI(2CLeLgwk3AgzdkAQh6GbVIDfDQDEq2sHXYsql2BicV1dWSzH8PU7QImPfGN4L(LwLQaXLv5yYZIMkLKAuH3vjsz(UiN3RYd0eTvpcpC5cmk(VLQzaJlM5gQmWYo6(VlsrwN0GB19)5taPAgPNAUGi2GPG285QnZVTDGw7edP5zUX023mREJp5yf9)sqnLLeNQgJIWmd6nLTefI221p6HIOFvJjWWgKzawNEm1sNLpYP8WPf1yGkPXWEixseJyquaH4rlWnb1Jfbrm7Xs7IA2p)T6ePpReHTHgTSxWcweqlcEANL)9(WiCyh1G)gStPMk9rCvUUk(R6A1K)ijTUQB)IQhhToiYjgsF)diy0ygQCejgxXlVJtwXKXss3vsMuQYPJPoNg0uPncg2HEnDmSQkolzMmswF8m4NTqnmPXXZbNtAcPAFqnpF1hHIXV(4sYqlz7PwZrh5Zq3NudsNDsS6MyOVtGshL3sJTKhB0PRfncxwKO(R5hq4xugUogzoV0La2l6Y1bZvhEe3X)M(HChpeUc9)IYHM)TiT8u14I)iViNWpavyiLTGkhz9JlMH7NpsOwlDuKZPmms3(bKJT0q4oN2lLjtE1NUuGLsE6YtUiGE)CAfwxFQrARkredRZ2RCA8(r504FJQCY5xrLtJBt5Kjcw3YBow604(OCYXSYPgNrXUuoz8(n43GkNC6dXqZSVtBfoesmMcEuOuC5vqw(6FPVUhCypmx1nD354k(tZtvXa2LDTUjPNyA7gmPA5WEWQ3T1UoMyJBDInEBNy7OMI9ToVVr6Z6Z2k9Ttw(K(0PXDBtQBG40dVUlvAuRqWqPO1DagAfSQ6(s3LL7w89uBDZYrnw2B3nrjuJlzJ(OM6C((0wIBQLoSyBJ4ZRKu2Difz0y5J)YWYp2lnLTpL54s7H6)UQ8jRzoLYbaMWGN3205OMzH9hMJEpIf4d5WjszP9BvGR130nu1IJyx5rBHC)KkEo(NvTgX9cf3DRiwaV9UH2S4YTwRcov1pyRUTQzSDdfbC680VVfIao90ZmPo0Liql3Ux)wxeySrraJt5VvIaTvYPv6s))p6onJ)vxuqFByt(TOMsnZRTu5R16F()p6BmJ)FJzB(nO2LMX)LthUUUorDxwF)zmPaVrQOkPGGUT679BZbWIiTITQX8n5GPVRPP4Y5G40vPU)lHUjyQRIwy8UuTZKtzmYfL9ROQhMREE7OBRNcbPfT5ehv5Pagy243dcOBvIYo14rGUAxJAT45VkoQUwMQQnhQEm5xP801F)eN1IJIm(Fr8kQhxOZfh2hkPNa4FqS3JjXioJvtZWv2OQcZMlDuJNv5skHsTnRFbtlJK9POFSVNw8HRAlWYWwMgisuGwnOvvbqvY(AhtzvMqbmNxegcQq410dvl0TCgnkhXPSVMW8OCvJx61g8xFjUxV8jTCQG5LnkDkVGFcrsXz3exRLUmfQtfnDPC4XV7iPJmJ79iNr1Hd9ZJh1wCOwxNmTb62p1DavcVjIkaDXXUQhlqBuB9QZfRj0Y6M9NIdO72Yd)ujCHjsmEczNu4DB2rTfwH1zKJXe0zIhWycj0W3pdIPZlIIaADPN4lIJ9Xt0hDLrieoN8HrT5QQcY2n2PVe1I3mLLtSAvhqu33UWnD(BVEdRRy00mEC6fYavogGFO8U335xQQBX89ZJmWzr3sxSN9fIv93yMMklktBNToAHxQvq23FuDrWOae7kTqizHIQLDCJEQq1xVSFATFt30kHXOcSknNnYcyTkuzxgSFsdV20HPQIjmV9NSIuJLXhVpz4LyRH1g5wviy1ewv(Hn(jmPkFFs8u5wpBe9u)2FFjDF6q6PjD2OADUDESwIWRkNmgOCf8bGgs8gWdpJvP8dO1kw89KMKghhS(qRTxYKFRP19KArpCkWkdD1eJ3Bl5LpPk8Bab(fCSqJ9HKVrufgIzS6TCvFVLZA2VQht1FWYI8cR7l(554soOPlTOVMqf6fwjI9WPw9)CnzSougRUH9Y2CI7iQMoRQVZYXsQw2mDmN6rDu9(j)hZ0(62oMv2os)tIWBtg(HwDwWcGpQyvsJ5KYf5aYLBAxrmFD1wfOx7hjbYJp8CjGmXx2WjGslvTE8bKusB6AzqUzZxSdxB6y1unb648QOx0QuPPkmJ9UZhZRn2wk8ZHPWu7AuKDuT9ZkJC2juU2Wuw8ACIv4rHD31TD0FmCEnMG3A7yTKYWGao0NcpmK5E7r9TalnYskpDLoQf8NFQ6EOygGRnWJfYdK0e)J17ocUEwRhlNUoYtvLT9qWk0VfqllD6Us3Db7wDVkUKo)FFSSkxbXzSmxfwRaltLpUjWeS86EfT8JxRvmSOU)wwVVTCDjEGKhF2UUqThHKslYN4c9q4nuhWgR64(D8quwMqt2)riomdvzQ(zaH(JgorgvTPtfV20XoON2tBIt2LDLcWqtO)At1dV283czQZks)dPpyz2qj)C(mtj)CZc6UZOj4QL0tbJfppFUuQn1)KAnc2tDbEzN6MbbKfNpvnOmLOX0tYP0vTG6l7h)(ljvCbMu9O(rzNjk)vCeP9N4plPd43w0Td7nPtp6aB3xjxR9y(1sHz)FeuO2MUxRLn0wYMSL56H1EqBXb7b75WuzIUjViMM9y(CPAdUNSqgY4vVs58MqUgSNVYDMG1jBS14q2jYQtVZqSN8oJ2UunIQDr7pFaFXl3)e)DGcFY1IlMtWDv6oet8Ym7C21tU3nnI2ZmErWhSc3mtre4pLL9uCiP7GomXh8nQQipwuk88NkQSrR)X)CaUlv4Db4hIJGHHA(PgZF1t52Nm3y58f60HJ)6rDb5k6SgqBq)7j8AeGMgCTgaxpHVc3QgSnYj3t4(BqkSZEdtp5BnK35vnlWDW42o9xh4Vtu81)Obfoz5BMchlmz1fzGgs1S6d65uvEtO1LemS)06q9ml4PM2EDS1IXGEcDUVH6llkomQdPxVVHK6w1QllzCFC1H8V3mKL2kpnWAyt(6jml3mVgZC194RNqtAF90aOH9dSNWCG4G2VqF8XMbV0g8ObzdBmuFb6GP0Z2aStA9eG2IX2DJGS39PXIEgt7rGodElBJqFhM6DyqFc0yRh6niv3vIgegJ7zrdGBrv3Wr3)ElsNI8ZPlvQL2U(co1SWRbuZPOVVGwl79AW2sU9BaClkPusuQoABkz19fWnZcDd9F2stDFhcTmsRRmXC(Q1bUJfb)nM)WOlzIkk6PBKFzwWO6aQ1WPMfSR(K0Il0dSUhBoQV9QES66)aO5XMVQBBiBw0so0WBR4cmYBMKIfp7m3DL7uu138thnL6huPm9UxxHI1vgUXoPkUV7dq5ZE6waAEHP)qByEDxgwGVdyn0wMy3IBdZv72Wpi7WmGseyB4EzhgsaVd4lMo12qxr7diy3CKniB0QG004umhlZtD9Yb)qaVfIbvUPX3NzyG6XN0)b30B0R5X0spvTuBzOC6JEblDAOhaBRr9a020nySldlW3bSUnDcw72Wpi7WmWS(bdDyib8oGVg1q0S9beSBoY2dTi6dup(K(p49sXtB9uzOAeIALoUgNspdA3m1N9k43Ba(xF8gwWwgZpOytHWh9TybRrFAdVJtyCeiJFJn9uBhYXdoSn0)7(U6)uTN4LTE(Xp(yBT)DFxBWg)62MHhvsg2suFNW8DdXRwvAK8Jk55U5Mm3hLf9Hg87na)RpE3TqM5(0gE3TqMtdovdO)GjKza2k8QgMH2fY6hQVty(UH4vRkVPnnRZyHGPw4FY4N32IiSGwzPM1X2sVvyeADiJEyvbdCWiIo5tuzTMOUNrkJzBDV)dQ6bt38i1OpkGVr(iLLD6nzSRE3)HS)KXo7E)h0oiJM7JASJ28HJwcOnE8(LSWKPzlL3thLfkd9AdgJ7xgKLWRN6aGWNgHh(GapJoS0r3vh1gjUuMY15mZwV2GXO)ZSo7U6O2iTPvJkE9zpYn6HP(jzTzuYw)g6XbvkpDNHppb(tP7T0oNmADEVmITMkiBJX4Es1S3VHEC2UvhD43kTQJoVxgXwxDAKs)nMNUFRo7(40(QtFH)Wj7mqJ4wT60FE6DB1P)JZ2T6SHCYdWQZgoITU60Asb6v(E6DIMTow7HCl1Ct)RhRW7m6Aa)p3pOm2mugBekowkiWTElmTbWTApmfG0YwcpGLBGJLDgEhQlshlBMB1XCwdIv)9nfGBrTgAdu7ujb6yRcg36j8WvCL2a1woHPDwFECyy890Hd1f0lNT(M7z1xq9ygpOtmo)GzS(g8itkUxO49JUbeMhxeP0BFFSZ(U5UZCZyVD9psNVEmt9w2sF3yuIAx2mFHK9UvWUFZRZ(THlWmKgS6oZw1WpefZL1kwF)vwm7qr8ybI7tkXwWpybsdCjszZoWqqlgotcdzPhXHOfvUdpe3PYe3cmhOc5E4SG1i9M7m10ce35ZUJf4UfZzB1V6UzPYwLLU7wQATMv3OzUTstFhwUTbYT2tFBau(L5xN)XWJ2FFb7GzLUz6H3DA7qhfLnaoCeH9ZX2YgyhaHlRGElKUgEJD2otd7ciTC2agoEalAQhy)FSvk)1x2rAaV5doDFb5az12g43LftlGu5XNwdQgFyQ1bSJLdDL46ZrdKAp5YnaMTJh6MEWieGZsar78bqXA6A2s8SvvlB9HnXy46I8Xnq3taBUUVH34N99KSQSfexYcvGUoZMg6YEe42b7wtpTJGyQTlXadiNwZ9eOBZSEVc8obB)3IJETvk7(W06oPyh8Dx7v9O(jhAW3fd9oiwBFZr7KnXyx2Ja3oy3AXA7iyRI1nAUNaDBM17vG3jy7)(k3lX6DFyAvS2o47wURhvS5qd(UyO3bXA77QENSjDBAzyb(Ma2nI8U5y9gb(ob82js2tSE7a(Ma2nYc1MJ1Be4Td4Tw1)WNCGEmP3GLQ9kW7eSBNOCpX5Td4vG1EnCSnGvdNhwG3dWoi1BBpW6ns32Eg82b8oleUNj02RgNozp6wgFybEpaB3KKEuY89aR3iD97zWBhW7mV3EMqB7OpSDQM2RaVhGTBsspeh7bwVrkM2ZG3oG3zEV9mH225fz7unTxbEpaB3KKEio2dSEJumTNbVDaVZ8E7ncTXuRph7WUNu9HAtKmd9TiGeBBkZWGN2U2zhm8CNlOeRL)7Gm)3JBfWan))p0BTQbA9XwvfVRuvlWDRPc7RcjB9p(dKwoeOVrTCIrvzxpjjnEEqi76j)UF36BwMNNK92x9Qfb5llMbA7x9QSGvfHKQEVu3554V79kOHvb5zVkFj7E3u85hni6vVNG9ViEOR)Z4i8k2DX3YWxDM7a9WeugHay9pIJ2FnHpB8Phrd(Jy6KGvFaif)fx6Ts15n4wuJ3z8VeCd(0zN57)gCoXNgzJQUqYE(5VQ8qw)c8HL5CHHGYRZGxqNGKZRTG08(5P(ir3863YyBWAv5DmJX2PBZfJTG1JTCdbDCtMO1xtNsKnHM4yKMy6olQEGBEZazSnJ0e9B4gJTOst6(2DrRVBln5EMBsCKcbbDbijH5pAg96nHpo4zBaOYEiY7fXjNNXYdMla5y()FklmJD(XJo7fEXr(biaTmAG0XF5bqQYt8EuV0n13l2hLIbjHVacnxftoWesVwwC3vQE4PGFffYiHR)zbEWbONMg6icqiYOnz(aYT8dGvl0NND24tDE24Zim)kMxGpkrd4pielwN4OtIBqAPS(vvEa(cOHu2C8PXZz9nRcIkqnc07P146FxaOETyul)VHRhDFHOyWl4H6wMWaOLVRgmDFOSjedNDMy04IRWq4OdfXWaOLjgMU3ki2VpcCLOp7z0tIDftdNZF9nZEaFNFwLatnuAHekkhi(7pk9NeFhWz6hCxaj5HFj1wj6i1DKSWFY2bdQy)bRR38NC54qL(uGxo2pyEa9qM6vKMcYUHauhp6SVEexazra(4YbF0YGflX(LimOYBwcuLZm8vKLcNX0OKTK)k0oJvgbd8lUzk9UEecaJ847Dc0ogtKpt8RWq8E6ekHpeRIjv9yqXpHVoEUsc78xU(40YFIoVsi7xP0FjnpRxkJQLgx5gv4g2WGEG9BgdnbiRxMf6MzvIECtqshZizRxFhAm29ajnKELnbjhpnEHNpi4KLlWZJ3Kp3z3(8XtzF1lSWNzAHu)ISqBHX6vpXMGaowqaJ3KgAe9bbbkL60vh7iRoESKY4Ny10Kn10p(ODf4sAWnwJeh9Sdn8XOa8rpZ2NkFATp6IdLSy27HyS2q02bcFJS91KChmV2(Mb3aprEDObEwbU(S(0SLMlqn826znAcimarDVVW9U)W(FLBxw6mPXWK7)p35zQQkn0hKjOYFwtDOPSvj2C(j9zo47UYfFj(hEHERmvhinRdVl8czkf87KpsFMEelbFRfVBzIhxnWQSlgUa4afRpZU0XKbGPy)l9MC0Xpt(HAdhT)M4JeUkakwJ4EZGpjTWWTe8eGCgtGnzIowKaJl1a(OKJX18(4poIcb6tPXRaFqqVIkFJDpnJboxKXyRYWeCClt4Aw29mWlPKy0xo6auhK)u0Dqigwk2cYtNa09TmaLM7MsdWFQeNimbc6Kah(i9)ACqWvOmUdFZylcWBPoCcndPuC)3al89Z1g)uGTGLWjIcXKZFnYHKYaEKnfetDJRbZPBeyuEN8QGXXsWatBt3WbdQhHdyymCAsGGZOYB(GimRqt5VXkbrZlWhjVPhxPD5IE5jbISOZ)cEMQGzkr7XOS9t0Z)2Jp(Kg7)aXJsp5ZtOfVj8l(bGBR6MFy9n)cqFlajeZygl13nkhZcxQRhdh5Qm0PFjsWjI)JjpKgm))Lho)s85HMFEnOq1ZWnIyEref1bmo5OV50ZVopie8PMh(j6zASsCIgp8dap7rrRQRyIs2ExF)6n2awEsDrNWfkAYkfiJt4C1ZjbSfPbS5vzvWVaIFa7RrIa98Clp1RWa(tdp)57g5aoOoWU6hnF8Xw1iCRUPhKGD1F7GdFIs21RxFLUcgSyTr(jtwMzPc4GBFYW(GMqgtgjLXJq3hW3w8CoHAYxKEUWDrvhUZIlePazYeAvh4hPy)WNyY7CJk3hQ4eweJRKe)occ3tnF1NF5fF6YxEXKjV8I04sMjXedMoWOd)eoroSjp(JpsRbsbCxKCeq8Qwj0EOWHMF8rXJfU13q8hFeh96NN0lo35iyGafFhO88y(UtotZoaOjfMrmuMLhPoNjocylb2SAjt6Hthz5Vpo9wIpKtgr96RC)AWQIvOs3CqfF5DGH8x75lYIeqgtRnVaseGP(4ucGFaTTWMpNcfMvM7GrYuwvfpisoTEu01UjrIlN(GdvvnxECfHi)sR7YlFZrx8hQ7K0ZWQupoIR64hi1NRV5JcnSGUjUj8FqOknJZ8buJhEkX7DNBqiNUdQyPjTIYVAD6WCvOCUs9nUuZN3Q6Rr(SMSuh8eJZbLgAYPzNwl9S(lj9B68dQAUQ2nrJQAkxy((dyzz057h(6aVG8loF8bpHMwIgG5FAg(mYFWHPUb(tz3rMt89ZaZyxCohVvGD5a(SJhDALcK678IsLiAxUgnfLoHNnR)Xhbf0LzFsYOrLfnUf7mYifyQOiL0LJscrfOokEsQQ6e0ie6kqsxHaLu5Kt2F8LZgl9sNhqAZaN4C9LY0fM7Sq2xbRJ)YFwXaI1frv3kQxgRMcQRyg4Qo0WS9DNEu7dPSZbwyjAiQEX5l88H1MVwh9LI7zgq(dm7pXNlse67x5w5kkYcfcKtCvzPBsYdYZG)vb418l45ZC(uapoFSCZIubj)NWmhnL)RtXD0tjSjLfK0IOMDeDueF1)9eol1GdStiKLlma((F(JQBU4)16B(5euNmpzFOGoQOEo5hnQXL82WvKRZfHXZqfzKUArqb8p0f9eHHA7UC9nRV5s3IvFGsJjVGbUko6POfJyEAj)e306pXkaVBK8vdMPWuqtXZl8EWlecnJE4(Z4KGdnXBamGLl6shI9ANduoa6hOsfFhihFGQlk6Of3VjL1DevKu3Sc6XksXx07ETq)e3Bka1qg2kU3JhD2bhwUlDQNJBCo7DBM0SPrx0vc9UZpLReAcSuIAlkDmIYYThqWF)K3)l6Zhf)14oquEcAr7aLozPEf1qdJ8QlwamtOr9Qlv5CqBB4cn9FF5t0k(Zp54B5UED2x0XhjLZsYVA6FpOPI6EyktZyo6rK5P3bgDK0KDmU4Khvgsk7TGk553HLlY)nfhqT360Ue6kchwAX6(LbHLad9(K7ah35kqUgFqYHOQ)H13CBu89vQ5fk25DBHB6mYLkre0CpYY4eFh7eFJoVRrBA4cFn9LxXmLS3N2SjEutz4gdvNsknp0ExLg)NnEKJPiapIZM)hbUbGoKgaCDFMS5wY2j5tjQxICcTo2OAlWAZEZkONptIyuJehyr3ZHLCl1xhrvSz6faIUUMhFuybexILyJBiJOA86lbaF1hbof0lDWovACsavKgCLLi3rbgssD2CsGaGiAXNO1uW4g55bSkNEFa6mbbYpDP(aNhKW3heGuXY2SGxAZD561ClECd8lD0djqyyakLHvQwiDY)rnuRXnATnwR2BwNA14KKxHeplU8pIsZuEmy7GbEj4yW31dm1ZXNzo4WJjQ0hOmp(jsT3LIuBC1emGyaib)BkCxG49ZryqZ80uIwce7IkQVdaA5UngsT)MSNZ5rbzgKHLr)OV4fLa43YkZP3jhNTjYU9Kh18oDxQnZOhMy27Q1qjL2Qs2nP7aPJqvdnjZVPoQdDd8h1x9bMN8BKa6Wn5X8uqW)FcoWKeNta)jG)8tNfhvKnk)(7DMEAIxFN3QI7D4UWtmeoIEqJNWDsI8wbTVYvjgqoMYYipurV1MhIwx)4LVqYicjSIjug)w0y7hUs3upAPFc5PmcBkITpYLv7Y4BFC41qWUKJIVZqdqCrCVi3jnop(yZLUduwF5iGZr92ZG3z3ZGlowehTuSZ)iVMOI5fas86)VU7QTN2i3j(NfEtAwcKMDt4ojudsLsPQs3tQbDO7nqdjBcrfYgTjPTCQQF2ppZy7127yhtiL))v1Ptq3S7MzSNh)nJhO0DFr2lQLVl4)7StFdIhBEjSu4M3RiOj4g)Q7AprfSl5JlwzQ7DnvJOQG4bg3xSmNS5yzCPKfpuMRdf3EQaHl0cdZznyDTOOivoX9889b9YjSc(7dblQNzO4r2OFZPq4IZxPuegnCrnToJhIBrBRZPridPxlnqtsAXY7Buhdq4Bd)X(nvvUOvN2PjgliNHbOR8MbclzxaORmN89aWiP8yr1nsfW5SvVaUi01oIhESWJ3WPdbLCvR2qSleJ67pRDCz8WLTHhWUqo4VEaOKEx0c1z6c)KYj)V1tyl8tsZWC2hbzdui3TpeaLS4o6FGMSezU5rUSPB0d9oKSkXoMWer(PT0unQV8gqSY8dVo3joyESFN2)6rjpbLHQRzPOL0Gviu5xlGCTuoLXaD)SaFwQYh1j9B29WnSAwDRhf8w3ptkBtHQ9BNReiUlF4ckNtkx(pUgslDYXYU(sNBGC(HDG(3OClH7MWHmxvcayRsvFl4wwwiOaxbiR63WzOvTxi)2KRxQPyMvikSPqO2Qps(KmteE9oK9KhdYpbVSCPrniEH058GVSBqfPXsDDBSv(WPTY)PaalCSQ2jwMUVRyk0aYe2cdQJRsit2cX)zZf)eRA514)6AOxlWZdqBeA2QprSa1y1mHaVW3Nfo7gaFDIsCxb8vYbW3Ez56fRCEZJUB2cyrVbtOBBZxJqsk2B2NEEnC12K)hX7IvvtR4aHTmz2YBLMxvqSPqM7rQQOSEkFlnCuuQQq(RjXCzE(Y8yNbnWyCPqmTmpFUfm6gQnsVrUQsnyIbpidYWq2bsotn29qg7CbLEJyvhwq54KH)76syJPC2NQT4jX)(TYyEf6jqofQkOuITzduPxegL7Mnsw(ZcfukMTisoGZUDYjhitBrKChOuvFJZvWkTfBu4MOJzvoMgEZ0SEsuoHYFsZUT4abPvV9zPHK6zjQSLLkC7A21q10C1XgNADBUeFdEMm6L4SywIZGglJFr2h)L1ow2ZzHiAkVBmuE3wD9r57XTtgOqb(40(DBNfjV6SOenR2lGbSykPHp5tPQSjcu26XeqOLsKqlCqd9L0l1uHEYnseWvbJBjQzyLYnO1M(YZTVrMghvpNxWdKLHUgq3LmCPiQIIv6XB2R6BbaxC0B3Nh6TzeeShP1K4yKEppmchfghbsXU2ChBRmjwJLUAm9tt2DsrzH5TT2o5JG78S1Z1lt7o(g1EyLAfEM9UCS9gtF6RhrY8Y6MHTF1a47FP6pHrObYYztNcOU7e2OEnddheS2FFE5W7GSLlwUuKUrTBWPdlLFXNw1UTdwdNidePbC5P6vSCv9cCjiJfqi1ZNU05g3XvJVA9TQBiDVhxwzcEGEuDKZ3)ytQXaHZbQuKkXHODQIwnQNjrONuXZOMESyUbEEkSHW57)3)4L4)6IlVCqMQbJG)FUSwxgLrgr)sK1ZdYmzwuaCV4RSTdtYvqSTkZxJsmyGFnLV17NaLrhqCa1hKTKcMCmb5owmCXVj7NUcAhZS9cRW3dBEZr0bWdduy4xa2u3zlFi1Lhd5ZQPpNw2oEO3N2X0sGqVwiQA5blX2CGrRs1W112K1cJkL5eEwyzA8uyu17xyCzr(Ov5JB1JQlcaNUQIf)rXm84f28813b9E)AXV)HcO5GgSwK3RRGDixK8(BvV2RlfVvVCj1IwcrZjRNp)HQEPEArXyO)iWwjukqo4nrUlHo38UUgmj2nYSbzK3HlThpDy5KJDENYYqerzhwHTxgUbN0aVzZCQdC38TCn9kYN)j8ulg(5u3LrbFSA2bCLZ4kcXXXulaSNxV5E42khz)Y3(MDDO73Tdq1b75zw2GrdrQewRvxvAJ(D7IBOxEl2YZOHd0icyNHSIcUvHUzEzUq3uyHfFnWX3bkJDjvd87Zl(IRmBOKEnXkLU8YVGN6rKNnUs9WHR2e3iEb9ZQqHXUeHbfUraveMlXJtm0jRAOwOUfKouYslVnr)kiQZqvsoMe)p21Ssiqw(rTyeKjpvbRhG0hvI3tjwa7o9VUatkfqb3HtCX9IXtVVOl5CEQ9rEOppRj7lXDMfJWxp4Xr(wqR9Ss(KS1CSjCXoX5MztfIrRVNZQS32zKjRHQQ)HrnaLaeKmp1PplOOsJUqDmDsUbsDwTYisa1kflfA1NDjGqy47GDpcDU0A5R6NsBmbaW(XbC(MEB(lWllK7YoYyujo4rYHi5eoKalLIKA(KR9avPivgLvOgxBZvrfg)rgcWgclOGoOsuMEKi7PsRo3XURhjd9pTnivrwEul0(xUyb4xFmMUfBbL3QWpxirJaOtwHfwCvdFgHPv1jYe8xbT5EouHhhgBNxEaVNsPgAxTUvVJlMm51QSRzhETDLdaR1VteYOznd8Bw2SWJ4fQvCqp1suBAL97Y1gADH29CKRv0UFAMQ9K5iuQ2xL5C4sDKde3c4zB2Q87LhqaRXtHhl8nTJdlfIdJ2sRE6YCykMPByfrE1nzALW(zD4WMZjdjNNPxh2oVvNHEVojrWPctWIeBHZa)WfGZ953k2fPZdzDwMV1bcsfekbxymAAujsIUzWPfduMj1jyBSCG3CGkfBOxsiKzeIaybPafxyEmbxZDImbHwQohj0jyKEwapIE297XBjSBGhayzJ(Brx4)XfRX0LHvIVBmADwHnkhISXmnWrdNGOFmyWlp)uZ8VPodG6rob59NLAQU6WHhEJcgvvQJhJpCrAYn9eG7BzmhiG6NTnJtJV(UKBQQcIzJEdseHpxMwIZjbgrbPc1KTIQt4opAGlonZy(xQgZXJIltYmdsmjpMfB5CzjHzchOM(pMdeg2buXjUvmO6(R0YQsfStGgUdmPW01BQ(4WrVoaZgIHIxUnlE520DICB9rH8pE52SFuYTPEKBRZKH2kZy(W0qYTz1KB9m8w8k3Ymm0EMKBZcXqri3cmY1cNHJTGXYCG7eYMl3GMlUfNSocHHyM8o1S8eA1ORzV56QOXnIaJZcKhIn1lXMglXUvQr7gf8DQsCOEIExjQ3nO97awedQ)ekcaDnhkWJ1cgjeeHd21bYNRAKcIfnayjvFjGXfHhYk6X0VFk8ii3T55ZOpFZVTBkuDPC17jO(TDDMQfD1Jz2fPCeASl7z0jbrneNrHAJhVGwm6dO)AwAUoTtBS3IY8pd8Nyt3aSMhVWyqtrbiz5P51tMqV6ihqSfPg1TtlF0wYgsKX)(zg)(zwGzrv07NzHDdx9zb2pzhCQp37NPU7NmK8Z6(5pdAKCeMEYtUB23()o9WFg084iSD8(2)d03UAWW1RUTO8QbWGQ)QvI)7Q)7]] )