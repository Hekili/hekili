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
    unrelenting_siege = {
        id = 441248,
        duration = 3600,
        max_stack = 15,
        meta = {
            stack = function( t )
                return max( t.count, min( 15, time ) )
            end
        }
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
        if k == "dot_duration" then return spec.auras.fire_breath.duration
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
                setCooldown( "global_cooldown", 4 * haste ) -- TODO: Check.
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
        recharge = function() return talent.red_hot.enabled and 27 or nil end,
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
            if talent.consume_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = max( query_time, debuff.fire_breath.expires - 2 ) end
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
        gcd = "spell",
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
        cooldown_estimate = function()
            if not talent.flame_siphon.enabled then return end
            if not talent.red_hot.enabled and cooldown.engulf.remains < action.fire_breath.cooldown then return action.fire_breath.cooldown - cooldown.engulf.remains end
            if cooldown.engulf.time_to_max_charges < action.fire_breath.cooldown then return action.fire_breath.cooldown - 12 end
            return action.fire_breath.cooldown - 6
        end,
        gcd = "spell",
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
            if talent.menacing_presence.enabled then applyDebuff( "target", "menacing_presence" ) end
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
            if talent.menacing_presence.enabled then applyDebuff( "target", "menacing_presence" ) end
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

spec:RegisterPack( "Devastation", 20250415.1, [[Hekili:K336YTnoYc)SKARrXkXwXI2Es28z7TIZLDM5mtMPIYUtDQTowMsesIBOi5Yl2XtLYp7FD3aGeaeGKswoto15hjwseeOrJ(oA04YXx(XlNe4xWU89Eh6DYHhp(KrEJp8fxoP42u2Lts9N)j)LWhI9xd))Byx7Nx4xeMeJp72Oe)aShYtkZMdpFvrrA(lF2ZwgwSQC2O5jRFwE46Yi6nMN5VOa)(8Nnlkz2ZkwXUXp7gOPHXpJfVmmM9S5r(55txNeugXYFMFAe(VPSRt(elB0800lNmRmmQ4hJVCMn4(5N8xbGjLn)Y3p(4V)5aafgeW4nMLp)YjyJp4WJpy8rV8UR(f)pXU7Q3gVSmAXDxTilKfheD7DxfgF3vt(4D)0D)eV5hDWrhcnFs46xF3v)JuCyvFO3jT8WX1Vzj)HxTxrwy8NyfdvB3HhXB38Q2v9qVd8Eb8Wp(7)o0cMFEcaEEgn74do8VEG3yJXkx9PJrW8vrrj3C3vVjZFzsm8Fm(S9v)6BRB6ZpW757F3vWRC4XI)IJ))q0LaIkzTyCuFhCc8Xvqh(7(zW)rlRxojkmVihjry4))EIEJf7plIfC5fxoXFoNwIvWYIdlUDAEzgsUXwNMCdlBArYLtgF5K53opInTWhEg0BVh)LSq4vc95DX1SPSy26qe8o9S7UA8Dx907UQWpIfxms235tZt9Jhjg97U6lFbwlU7QR9HUb(LrZ9JNY(CbqemnaMbdQ6a)4W1j5qpO)UINUgPydcZdJlylZauuDRgs9IjaEonShPcIlsIlMMSy6A)LHZRFFObhF3vpPZzYqoanRCXIrbvlTJYyR9dJrucGrg98tOUc4oIIMUcyJze058LoNJhT8kUrldCHo58FzHP8L73kMiazeUEduzL5qFN5h)P7Uc60caRLMgfoh7jyatWbLw8hDzbWYVfurEBovKhTc41NvGUq)EJ2gSVL1mC6F0wm9pAZN(Ck0J670)rDrnpOpSmTJirOAK3wGkTG)rm5XBbM842XK9BkAdFFCFz4biVau)MXa9RZ8lSjxnb0uMZkQNrs2s8trLWFekHgvmEeGoMc8FtrmOq02FUpmmF06WSSKmKkArgmhkZyba2FDc8R3KB7fYdxgZiYoWUIPPzHjz3st7PCtxeTE6yAiZTjgzdqAETnb(Z5HBisZBtqAE1intHpDJ0y)NYW0uwWOzS8cGJmkbyAugKBy(PjX1JGjtPyecxyFmm6M8BJNRYp6A0bqBklkhEXdhDsfSogbGt2jtrIp(KXhZ1Fm(edvG)YTGbsG1EjXG4Rv(zbZtcqPdhawrbQ7Ed8VW1PrS1GCaqUvYAgAq1sU9A5KHIOAX)DjQSeKdbFfn(IaOr2WlGz7t5Glmf)E344AuxLQCdEhsC7EAmGZtsIcsUjEuqzgzS)Dx9D3Dv9VwlwUUbGiVd5eLT3UVRRrQUJ0fjSkbzwaI75a6fG6HglbVHnpmaWz3aleRQEzoEn1peSbeDor1AzWqfqS7cwgzwW6W4su5JFCazQK87Iok3U4hobQdsjxKKpF74jQ5FnzlAS265yT17R2AR1rYYARNJ12wrGVyJ5P1PLMXIaXOW)LtIkZlJN7hfHecnP7IVDDjdKudt2RzratlO9oeCTKzvVv6TRrZrYYNEdBMPDYG0K1CVU8RPReC5Gjp3I431PaOJsgibasCiizzH4NeVhq8geEDijLbFt6z1y6QMZ1UewG06jy7ZhD3v)Gphgq7zG598c0o9GWfHikyV5LaUjUaDEE8Ot(8qop0sWeh6LwfUCf2osbdz2p(yLUsoZgjCH06OKdR5riSJZYv(XlXjccwkTUEecJNNbolJOUe4LdyIVcdXRGF7g4n4VTV6ySaBB4cv0nkfaBBsM8tXjOezGHskGqIZZhzNLFTFCPFesg(x3EYqVnGm0Btid9SrgAtgs90y8HB884q7OMKLZdaE48cQB3CZyT2TEgD79WqpIhnRC2TtVzflkDA(kIWPjFmOebCUazeNcKE(zXaB70W5IEVX8M955rLbKU4XBUjv6RDDaEEBm45PbEBP9yYotYsQQ95rkXjOgNuRaYT2jCM1LUlD1x4JMwlMBizo2Ew7fopnVfk9GUz3dLrWr3cOEpmJTpmMUezOqBC1AVhTO4Wg1hYffBp3(6sdtoPPAJhtOHkC5d(Q2P)TVglBnw5A0t14EXk6r0kQdtY7JuaNoaRgalnXb2D8ZIxt27vBSO1QEXO00krhoD3slAd8xdwqo9bJoEGoMk66iEaKuX1Wp2oZ5MBS54rh2i(u6Mc(bk2OGxgIyrjAly8Hp6biyNOgEkBmP(Bk97imzZYJmMtOQcFNb4ywkVFaiAHFze8kFVb09pfVQWckqzum3ipqgqgaERadKiBufqFUOHLPG9R0dEZheBfrYBhrEb)oABgwJglsovdT54CgWbMZyRH3pke39gYI18ByGXJPjOjUZklqJxFmALmdPvHUNmamezpZbqAbU)eWa8dsyIGK1jzu35dWW3JdcOBeDSaTdEgBjfjrCcndJ6g3SwWkmr8OTzo0gICN6NOIGpM6xB2d1J(TrO3fD6HuNUrwdP2LOuoX6NsNo2G3R9nnPUbk(d2m6VIHbwEgvMwZLqWVRWFdl3b(XfaiolZFUj)ZFhTKFcT0btMSi8RVkWpTqi5)3GfIYOilHYnN38P(vTwjqSV3Z08OMVFuyAEb49XATyHtZZvjaupI7V2avNLzazXm4Dkwria5CKApnSMga0yyxecukfjz6J6EQlbmARpDTarMvcitGBvzRMQHLQbGGht1x2OjSasKLQ2HMbTbj1Gre4tlyv7IiFssxrnP5wfxCBXROEdiQmHOQz6BvqDtbbmVGBS4Ft)fqKGCPTzRnJrvTGvq0eqYYqWKhraUq2yGrhKUPUHU5C)7Vjj7tK8TKsz0bx7)5W1LRrPyfGmZyXpR(2Zdeb062KYSA51GKvWsGKmQdFnkSMTyb5YntgJcnNFrWAAD)UXHBx2pPaABkiGEAyGfA8W1G0D4dtbCwrw5CnMtv5EnxDvyWu3OUNt0DS8Cw8Cg0QfHZrnaIndLB9axcfVjGDdz5fapQK7kZpmyk7Aseyqq(iuNg(28jP24whQgqZ)HJowJBynlce5KbQLSVdAXSsquG)SWOgYyn3CPZ5BM3Wno89o0N0yzOHSEdI4)1BdG3qe2Pj3MfU4)Hi5REpEVNtcIZyfLzK2wK0mUez75rNQQrWdbFzbQI1yNsQVlwHK9bQrQL2szCXdwBly(bkH4cdAwe7ZGgGF7NXVfdWh2Vv0j0sSIeG61xRW8P0(2nSLDVyBL4GRDlNhal4Fw3jkDdZ0K22udA3BBVtLYTzeGL9kr3M1Yur40x7xzSgYGeblh4Q6k)00BRrn)NsgQbMhz3ftH5nkbxUDfYwjcOL6WAgH8z1TM950Y4LAOOagF5nKSGgFJPPjH5a3jOQ1mwXZ67BY59S0I5GecwBna(mgAssrVoFZpW(eWFdmlVpbPv)rG87A)WiUcHf84AwasHjPYWpYcYRN5Z9lrW(pu1oQhasT526KRPUPPPjoHQpG2cVgelGer4YCui6KcLUgjlxcuPyOzZYaYGCzSsbtyUbZJPuFCxXXig3qJELroncZOSfGP(0Fn2oNiFO7stkQsHlkuUGImaVHw37pJRkeGVjtijqyUMGWqglc0SI70gHvtsbHNC)yW3J6HBOh)MpCW5V7IdoFYKdoplrMkC1yX96TjUgsxgQyEwLeHCqNFbpQDOJuMergpEQ4NLTYMEaV6Sfc8EHgZfHlxvmvvj4rNynAS1ewGpQ8VmfZVlEwEP7SFU1aVo3zcNCoaAGGs4TNxqzuHCWYkJDowOlt2cGQ7H5uk0eB4Wqrrg(PLzGjt2SQu3rJmYWQji7DoPfsWCad6YLiv1RINhs7Q77I4tdPOQ1Gc9OGPZqhltwxzZKthCufawWrhTKJDgulTNgl7zFN7muLKbAeytVoCPQvkQM0Bn)vSMvCImoAO0ilRofyGQX0wuyyfk7jh9))xtrSpxwdonrBDxq(2JgTsHKWxSTulJsM5hjm3veOc(l6Jz5idA1BV4URU7Ql8lx)AAhNaQ0xIBoF8JrJUt47G074YsEpRSiJV)iUP7vmpee4s7UpzI4PuuhuSVKl(vGVrla0mj4qmFM4YlOw3iDJWL45Fk3ybB7YkPHMIMTOH2Lt51ojQV0bShiwV6X0MnohgZxn5v)MkcJlOl2pfBQC6O4sjdZXLvmUgUCvpZ3ClXcskuDpBkpyJkyEUfGs3mikZcYyeYmmLOTQ3MWya8qPSkI5RmKZWtjvVfMQ5HW4rE9jgkdvTyJdatRSW1MjBs0HIRjglwQ0)uogtRDV5cDEluxlYkq)7JVJ4jE6rh(jU24t(OfhhC6gZGU8d6ro8OUMaXLh6sTJTtaPccUdmrB(FkxORHdE3OsnDC1cAf5G5kMWTcZWR0f)1RM)FkdZK2CZ3BcDbz)fmHT)VG1CUts8S6MsejFr4wvyoVzvyKSZqtN4wAWJ1aO6mgDZ4URa7t)umAENWjRQPa2SL(zZi6BreA5bOGh7JN61kzsBRrDgqREG)nBY8vOoXC1SpPvo2tVNCSI1yZTeXWSc)zagolmaT7oqH1tbqqTxKjUlZczl4bCx6LAB2VXniAkU5lTaNCSTK0pdZmK5uysSP6pFEs2CmJ1AgcXouX3y53bS0I9jFnatfdexmRYTXkHP1H(s3pvZ9Hr(cfHP8u6awDy5gl(FmeMxVf47Wqac(mNLKgsNLeUXBiUOenOSEVxsbFHO1FYgtW0VukkkWiKDtigyeQlF3f7wFxApiNiBsNXnvWS1z706mRdxTyAhjKE7RWcMsN(G2WCANQm5MmA1wXVzS42orUnVavzprIVr0UxvKa2vkmE5iVwJd5ajzBZ3C8jD7B6HwzYS5TP2cYRPTj9DKoXlikfyrzc6QpafH)b5ipSo9RXy4a47PkAqJiZ2eqImdWION)I8NYz5aPli)hJ(iTPHO)imCoW3qXJomVBXVn9aB74g10OznMIocJiUfKM6RA)Spr6JNMhMUkj2KVAp3lZVqps3TCaQSiMTfV9)MfLPgChA8)3GZzPjfvd(JWDCUy6SK4Y8rf3CJ30JtNVbyPUOTiv7F7IE0wMz8yh5EFvFKDOCGT9THI3JnpCkSKevBBKsSSHqK73KallpCT)NNkAWdQOD8LTrwnWGkSgy90Pv3gZQpTBZQpNmR2CRo5EvIExWnHjKcXclNI1cg3Hf0zx9TxSVIHUe6cNL47IUA863y6OdDYAPy(G9nfFx5z(101Jcl5Hvv05O3PDAbNEX1si0piJDDifKqDLtsxS4iwYwom7v4BdmfrAYYVzWs3bfjhmJwc5tmafZ8Zdzzu2P0ivRmcUcFzbd7OFnHlPn2RHDDoy(v3HQJ7LlpkXY)2mU6BZSMQIRvrOx7O)DuOWQi)Rwov2fAfPKohjnJuBVPc0npPdRZdXNIH4BS1mc4FGwV)l(OXfVrPd5MR86lq3QJlKSmZ9PD0Qr2F1DmFOH5nu4bKuK0bp)J4oRgZnUb3GBPjr8SIs6uAyXJXFetvF4LdatQ8x6JmzY8RNVkGy7F8nJS4ZxNrwX1(WtHF15(gH0A6ZZF7weEp(JpLKgCe(xEmG)NjyzliIYOXd4md81m((iJyA4N)nGYG)fsWYB(GHQbB2aFm9Ms9gwNPcVQuK(FDf4SH(XwREWE4nRd4OkCszKaE8JB6B3UsgGEl0Lczy5KtErDRQAL1VIT1QIA(wJ1zBgRAMbhZThPQ9GEUAA(QN0Jx9js9YKdPnskqjXTwIq1Ljl1iEykgdQsTyfO8jnmb0P39Q0aNO0twsHoTLeF(oIXHDLqkqpmI5NwnXYvcXJlraonfC82mpoQgs2ot8mfGZ9e9NFNuqJy(bsqOjiMuSOmYxkoOrvrYrSCSF1N4XvfBnpdyyYSbdNxZecTXMKNaiCI2PXgtTYhRshJnaX)7eCtCdeDAGMAMOKL45wvufq(OnkTQD9NC7qu9wW9mAEuykoxh00(9bfHaN65N5nyp77r25EF5l0Rj3zmaVYaYQBNstcZHs5r4aUn9UgdJRnU7CDbh1BBxVKCzZW9J7Jjg0i4WgPIwss2(lKqQyrU1BQkumep0bbEf5kU7RlcZxjuwk7AXE)rWTPxFnZHx9DpxevTq8qW1t3GR8dvvMJCiTLCBwANMjinLEP8qnICn)C5PtqrFYLxRlcM(NHRRG2Z)qzYyDvVWs26kBO)FuMH0yzHFY0qP3b4uUtgley7gupuwiuLaiTLkcgN2qdt4Tgq)MHcC8rhQPOqPxZyPjz6oZi0hHMD5k6IOraMhBzHVR6opyzhbT0xhFi9KoZVVJ5odls2eDuJLKjqIeJzG7cr4XsYpff4fd(7oNL1f2SFgM1jqFIeGDbgTKuacseqCdwPeu)EFie2RJZVZJ6)wdBl)QWv56tauvtRM8dvepRVPn6MM0zsC5AxhO(OXmu74vnUIw(EozftghrQxluq6NSU695KMkTHWWg0RPJLvvX5q1M206J2f)CjBajnoAF4CYGj14fQP5REjKn(7puIgAjNnQLC0rGpmnE1c3zNiRUrgM7FOszaqQvMmTJoz(O2Azw8hGDAujBFPF9Ol88CydiVOcZfgPnS8yG)MzbYapa)c5)ICUK)UiU8yDhOFlpB3WxafyOewHklEdskNHPDaIOUtPmguqXhKQCkKfW0q4VG2aMjtE27UqaLkMeZdniaE)AwfuxFIZSLUqgcR82EHtJFyeon(BuHtE)jkCACBcNSHW6MFZZrJg3hHtE2fo148n3LWjR1gLVbfo51hKHHAFV2sknezmfSOiWAy2vlDu918G96H6QUX7EhwrFAFQkgWU0R1nkvLuVvrl71ds9U121XeBCRtSXB7e7EkP4HwM3xj5znxN)ZKx(O(0OXDRtQ7oXRhwDlfAulqOLSIu0vwCWWiZL13v5U0C3ITNgRBoktbQw7UjcHAuGE6JyQZ47YQe20ZHCX(lXNxPzSRrmYOXQNpXDl9yVKu2(uMdlT7Q)PvbE2qDkfdamGbpTTPZWMHR9hxGwpIzfezWjIzPtwOawRRsw0XgaHo5zpKm)Ks5o(RvTgXTcf3gSywi)5D3BZsK7bxv)ylPrBA2QHY2nKfWRZkNXwWc41tlZuAqxSaTuza)wNfySvwaRt5VwSafnRyEnLT()DKDAh(RkYyFDit(wusPH612YV5k5p)Fh5n2H)VYKnFdkDPP)F0o0yBhd0tQ66AVZKsSA2rPCb17Usk4VoNepc1k2Qg7v7fBVxtvXY5G4y2PV)lr(PyORIxATom3zWPS65I2(vu1c75CVBWT1ZUGYI2cIIswMgaIn(HTgnRsusbSwcfQ21OwZ4(3KexN0tvjXdLnL8RJc6k0yI3DIAfb(VyEA4Jl0fIZKef0tO7VvSjLPjimJPDZUlPp1zMTN4NdBlQiklHx2O40RcK9j7GCVNw8HRAlWYXNmnueOaJKvRkvHQ49nQwe6eHI(CrzueicHN8pIdrPZt2HCeNY(CkBofRASG5BXE9v4McZN0QHcMN0N0Hrd(ecKIdXlUwRuTBQdfnLNLZ51DwkDl9VbPmQoLWFy8O28d156KTDA39XmeWsyvmReKfN4RFoiDHTnZTwS8NiZ613Nes1f39ENSFHjscEuPNuo)t5wplADoJ8SgGoB0awdiHb8(bGnDrzCmGRLwIVmjjaZkwQM(iyoN86rTzQQgW2n0zUe1I1mYKb2rw9(l8ckms3LikCsaP2hkX6FZBjoqU7F4LCcFRocfzZZYe6R4RDJpD1wquUgPgCsHP0OEC0L1oPYvwEGVOA6b05BIcV6A0oTs2HAxpQQIeYV7Bmo50vAsRfnAVeKPc6S4pr1042H3hPiLt0ERbktM8PUo0GeDRYtbrxbJQt2hToXTm3wWGgb3xmQTKVchPAVz7LfKwXqwfexTk2iAM1Qcun9X9zPKsczxzLBxxBpzwZBrEBYXc5TLfj1NQHWQXW6egB814uvClviUkCEcn6PC6FFfv42i9nKUNGeP9kOibSMSLZaLeGTm0qIvbu8aMLXpDARzj3WZ5)T9I26BdCDpXw0LhfSYqLNDSaHviVwP4L0dErExO5zpYgpkLkrrVVKlc)LCstx5yJE6YPBxRmR2WeDJFQsUG31u1X7ZPKiBm1l7HX5M)SQKu72AQyo5bTzm6qkjwRsOv5yPK8EfwotD9iFWE1K)xZ0MMIU8QWzfkjgloz8tS7SqqNCA560gZjTktcsLBB3DSxYURCyT9ZGbP)hpigir8fnmMrQYQ1ZlHIqAB1td1hBVICqtaxw521b0XmlDPCXvOg70ZgZtg4wY01DtM421OOAWD7hoi1OSOvFk1w8ACeD4EtEnHkDzETLdOYe8MRatEwg6mZEbKBUrm)pnSVjkQvss1PRYzlHFf8v3cn1aCPbZzrChITr)4SuDWLZU1NXRQ8uFxqk0VfqhlDMUe0Dgkxve6wrNcX3kZwxGDgtxxH2kqZK8cEcMGYsEnQ5hRsImml23bj4S6YU7cBCZ4cyj5IBq8DpZu6wQMD9gMT6BP2tupul9ysAnFTDziBlwlGgj83bpyTKFUMhZg6hTCOxQEMjwKGjxg81Hg8MWKBPfk(2yiMHGGwl)c)87CGMkSCyf0pnbz36y2qHnEXmBHnEZcxrN(VWfeAg8kh26Q6kR5RuldYDqFWArjwoqbxeNQ7pOM)FMHhwjcb63NQ86ftMOGXuDvQsX1kU4zCaP9lwvhbs5Bl82E9g1z6pIR6dZLgxHQTKs7)VcmuBt3lnIJClXH3XCDVAB2Dys)o7siwBIUj3dX2Tr)mLSQUNKqwIvyVcw)MGU2zxAW3BewNKXo985EHw96DS1NRUNYTZvJGAx4(Z2H3ZWp8i)7bg(Olf12wWazQiXvDD6F5KB8ZIPDBKF8bcxJBdSWN)hxD7d)yCKPAnigXf(o9vwKiolb87PV8r39t)CiUnFy1J81jXWOrp(XY9JMN32eQT6287XCTvpwzpRT2O9g)5H7YbqEzoTfDnFlZVTniVUj72o)Ea14AVW)V2GC9MT7hK7XmGy0Ad2Lnyx2X3d4ffx1g4kE(oSB3CGTR7tAldupEL(p42U5XSpMoAP2q55yO86JCbhnAxpaUwJ6rx7s2G1MSB787bu3MmbNnB3pi3JzGD5dwAWUSJVhWRvjenF(oSB3CGThsrmhOE8k9FW7LGN2AP2q99oLX1i)bTiDZwBEq7(hSo(pF4UXTgUDTjnAtBWDskJda58Zs6JDL(Ld2RnW)7(U6FQ2Zc5tp7WV8L2E(39DT134B32mCOenSLG(9cYVFaE1QYZDYp3n1K92OTOVR7(hSo(pF4UBMm7TPn4UBMmVguQwa)DgtML(wJw1Ym0ntw)a97fKF)a8QvLx0MKvxxm92LX2sR1ieADiDE)2BFmBR59Fq1tzE7JuJ2O19)124D6nASRw3)HS)OXoBE)h0oqJ2BJUVJUSHZ6n2V9fklTAdgdNxP(2hS2AU(OEuByUoNzUA1gmg9FM1zZ1h1JDoQyfaBKF8TtdsZBtPKR2TRhhuO807D)Ztwz(DGFNtgJg)GmITgkixJX4EI1C3UD94SDRoM9FR4QoA8dYi26QZj9Kc4(Y7C)hN2xD6B)V74D2rJ4wT60FA673Qt)hNTB1zdPK3bRoB4i26QtRbfOxX7P3bA25y9aeBPXT4hw01wnnG)Z9RxgBVxgB0l0UdUijkk5gkL18bAlWtTBy1L)l0Rnkpw5BEl)YAuCQ74TJYl7fjLXAToiaBCGFH)m)C2lV7NOS(fJ2i8XFYY2skas0JYnyxjDBmuL)sIDp1ck1st0qV72oVhDlYjiFphIXuE8diS(G25D2T9xIyVK8E)hMwf86U77oun9iCR76UVQJDB5tNlQwBIguVB78E0TTY604XpGW6dAN3z32Ft96fRZ9FyAL1XD33nTDpcI6UU7R6y3ML25IA3cB3TD(M0TBeYyZH6nQ77SJ3ogOEc1BxNVjD7gjZEZH6nQ73KoEdqhBouVbDEND72XU0tyE768QU1TJgBt3AaZ72oVhD7ojOW9aQ3i5hpWDFp64DcAXTdEDUy2nh5UTZ7r32nkPh7ctpG6ns63dC33JoENGwCT3xBhB)dAN3JUTBuspyE6buVrm9pWDFp64DcAX127TDS9pODEp62Urj9G5Phq9gX0)a399OJVNOL7(PFKIoh2RVqp4FyW3UCc4)3IWi2Lt(l)L7UAvrrA(lF2ZwgwSQCgaWRFwE46YicANN5VOa)(8NbpyDyr(ZkwXUXpdlftHXp7vuF)BII(3pJJWZ43gutdyxdah1lJWo4UFchT)rkFQeqhloEbDAs46x)s8YvKQBuEVal9EE8BOTNF8StccEboN4tJ8rvhbINE2ZKP1X(4rf9mb2rMav7tXS(SA0AZmcUojmAMW)wF211z1Q1Nt5pQ1NGrpv9bHDK7KgT1wCP3eCINvCITSKUEGBMlYwFMvCIzo1A9j64KUZNuJ2UT4e1YxVaHGbTonLfmAgDcWXcLy(g0v53gpF)K0ZYzfHleD5y(FNYIYzND4Ot2V6wP1XObCh)YTax1CrT5BLFwW8KaKlg4e(yc)2SpCDAeDI75byV6WRdFfzYiMR)DjgMF6WMsb0NaKrBY8b4B5B5tl4NNCY4J9EY4tii)nS5Hy9N)ga(XB5e(6ehCWBTKM3zj7tv)3fy51W7URwhgxIseOZK)46Vl6OETyuZ)VHRhDNcMweKVRYRnlDTA2Hzldm3eKH39gz0iv5Sy)ZUczyPRvrg2YuoI87TI7rNCQ8awr0WP8V7kSaWb4PuyQrL5nKPqoq8AyuHYv1Z(4DViwnWd4Vj9mj4O0CeTWlHCPIQh(O7U6h85WqL8uGwMxw6WIH08YSmG3flR5JhDYNhYzqwgIfOcFX9cew0lQQIU4Jv6k5mdRev02WzBuYxXRKv4DieFp3GV4NR166rieuYJNGXC(9zzat8vyiEfTFIyXCsmPQhJfYBuyFfMDEv8mjt(jA3frYpj3VeNN3lHr1CJ8ApCdf6HUZfpdgiNPpNPAw9sZ7gaKE2bYwtyqdc7EaKw8qytasLINTaopCtEDV73RxDnLyBH0m15mwyCMSBBca45aaSM7Egi9Dcai56mfh7PkoESIW4h5u1KlX0F5lUfGRib36wan8j7z5Lrg4HpX1RQMFidpFpfnM9EigBmeTLckBKUVMO7Wf163Syg4rQRdnGZQURpRpnFsZfOgwB9Kgpcqmas9bFH70)2d)k39zPZMedBM))uVNOlQ0sBqIGk7zT1GM8wsO5SJ6ZCWrjXFhW07KOAGYSo66OZvXuW3jBK(avwAgRuULPYLaOv2hDxGk(O9y2LnEAvbLvAn5OdFIAPxahT)P4LeMkCdD3bIwZGfzky4wbwcqgJjGMCrdltHXLEGYff4iYfO3r391RrRIK1PRJZzGXf5m26CmahFIjmnl)ggyLuAc)A7gR9Kfpgnhe8HL8TGS0jenFlpblq6z0a8dsyIGK1u1dUyfwOp)ECqWvOCUbFZyldXZfdoHMvxP1bn89Z0MGmGSGLYrIc2KZ(EKcjJb0iBAxm1pPUBoEJ6gTkFrvFCOsFGHTP7(bDQh7hqXy000qbLrL18HXyuHMYlbgHXlkXYEX0dRKUCEVSKWOUKw5mJeShJ82pYSKF8LVi)PAFpex74Iocw0Xk5ds3sLsUj0c6eErpdOaRQ6z3D1Vb48sGRXo0YYc8JlWsfsM)CgcnolGACe7)AYTzHl(F4U4tfCwETaMCFphtNUfLXKNiW4uG2RtL1rUJjyjS8UQk1TGfJgp8faR9r2TQlgbjRGFa1F80ZdwYY8rdZfcFYLmPjPCkD(fo)YSq2IQineuc(uGT1ksGk7FQt9kiGxYj5LfqKQyqTZE1fJtAHWw)wvXqv67QFBWEpsRamvVMRumRDObsTWOPsav15GPGQ99GM9mgGsnHEGyda5XqcuUBP8vh(TIQ6nZbUKpJQ(WzFIqW8RSDui2A)phUUCnkHPaKNjtpt13EEGiKj3Qwi9Z3xu9ZPo81ufIDXcYVp5foRIyQgCzg3EiMSYnlcpO1dvp2(TyXbVy45)T6gz5YWaAXqopXpsYkaN6fItaMoU(QFui3iN76jGnU9XOmA)R9dJ44DqEcnPvqsQcWG5QqsuLSkKMKpV1foHuce9QwrnCWJSoh0EGLlHqN4AL6GPczTTYkRUS5ABISYdjxyE(arz6fTflCEyX5NnEWJ4I(0QFVWeypLY6jiJihKzF(zC4wRVLd4toC0XvCg113wj3HrjT9lFb7Q6cv15NDep0n)R3csEKHArrAyL4BU6PCs6lidSmJesr3XWLiZNOiulBe8qWpnaLUg7ustoVsEhOg6rQq9rv))yWIf8AAOkSoyGIIyFge7)B)SMKrNlI66qRxgRMc6RywOQ2ZYS90Jh2(qQQj0bjrdw1ZptuCMRD1qZweu8xtnJdmNqdAOqLBIzzQiMVR9RSfdjRIaumUsTIkUZkZQ)tjy24(8a6r3WnNnw9XIyHO(tSpNIQF2xuhUa2baMffT0GqYmu8bGPgH5aLRqTE9LeX7tWv2FutQXcEKVkarKK0d4hzbAl4Z9lrw6)OwrrVh)V8flpDowr5D9q4ZunfRbS)buP1Ag3GaenhfI20JFQiz5syXKQITzWYqE1URTk5g4)zP(GLwm00bzfmtz6X1zRnLwNGAfnvzlc2FeEDSKsf1DGRCYhvQ2U01pU)mUASe8MbNyNb6gkSNy9s7A)y5rhijfKhW9paFpQhUHE8B(WbN)Ulo48jto48SePnt1Gmm6cP07508onMSHGncTiJUALWzbXTPimVHWab28pqRwVD6rNOt6Ox0G1C0vJilRmUzdrt75vzyU5TgWGxNDa8x3V)PhjmD5v)6B13Q4)F3D1VMIgDWjJqubAjYcYRi0KcYorFrKRxgLmd1uZVba4U4vDD9SiJX4fS(7U6c)Y1VMcknVEW8MK4hxiUpGY5L9DGA59IBiQk71aSam)mwA2xRIvZNE7zt4NIemLB9PAZ6kuVajgyGHafvd0nU0eS4CpAcXqqXEzY(0VxOawwEShOCjLDoUzmd2tUNRUkA616ynAIjj6PNDmxl7eyPevhknPL2ZI5ac)vtE1VzoF0S0MZtuxV9RWfg1CCZorxFfhXnTsBQqtv73OnNVNW8drrvv56t5PEpr)zHXaCGCHaBELQndlzpVsZ4tgpYZMBHCKLknkwS0Mq4U3CHo9pkXdjxP)9X3r0Tp9Od)exM4jF0eHOydLIncgMjnOP9u9WItdBUrrv2xKgy1rgBMBoqXIETQJ75GrF1XHYCDLJaF1C6qGPTpz6O1)cE0y(Vi)xR9YK2XBFrODuivVzvyKSZq1jCjYCFNarEy5YCe4DWDx9PyuxNWkobeXB2s)SzKht1x5CGdx58fnp3lAwD60aN2W1ZwWCMpI7TFoUjNojBpTBYwoA)VduraEilmanviqHCvXLruQmPCU2N(AdSnM92vDTy2(vL9(ZAald2tsvvFHnvroAwnvnLSUV1E0Hi97Za1G5u3q2pgceMVfi1qV45vYBrH8wTiEl2RtYZ(uWKiczs3(aGIk6IdHUgQVjeD2G6Y3DH5aRFjoUzMZ0M701eno8ihi46OfkDHLbqk8qRE)AIMBkpLRZFBu2)GPCVNegCAtC5FefZ1Ieq1lOt5ipl(2oWwlhFIDZfpKWsVMcdV(vo3BMGMidDs4FqgadiVFLUu05XShvbjsPar9gwU17r0ZFr(t50OaVbsWYOpgikOt87ArEaUp6WgkW7G5xyUv)iwTN)hs5IwDffJPDTSoLG5kP7ORnV8W0vGwhuwqt89lQdpHPHsd73Sf4iRf19vFUo8pfmm6Ne1))BWAtWllQZFuoRy6SK4Y8rf3CJ30JtNVbixdtFEKLiGygNQJ4MTswEH685szdjxfy5KpdO9ZlIqn(V9I9vuSr8)4g2GVlAaWRFJP5hO1htiFxMuDFAjUMo7WGG(4cIL4RrMUFQLhuDZADVeI9LV0C9zG2Iiha8g2BRvo1T1kNF4WgbM4Gm21HuvhW4sZuyRgVxjnK4wUXJpo5UpPpDgaDhuKCWm6AeJVwKJB2rEi4KK5IGWybl4ENgMA2f4v(uL7n85vaEl0ixRaP1EdSQVrYtjdK2XUDKGUjXACJuX4cUF9fOrOXfssz8(t2KVr5LSnB3A)ebQGkmLsiOfcwC2Jvgg0EZO)8K9K7T3tpC04HkiK3qM9ljqqguVpUF9L)lg7zPAm(oRknJnS4X4pI51g8Yb4fo4sFKnvMmA8Plse(JVPbrJD)VS67J9iKtZGF7weso(JpLKuCe(xXDED1T5f9KXEuCqMJ(yKiwTpa3jJKi(xiHoGFKoOl3Z0KIJpGlxX6vohyoyLSI6RvmNwdlfGy397ZnIr0toC0Zpz49GzO(30y0goWkrOu9tl01YDVTPi2Z8A5zJLAzo)S9o6GoWM1n9KwB6t8e02C73WBCkobH4UKcwP5Xh5k8UIjCXlf5fzLddIlIQ9R(e3JvS18nVGj33qCPsUBVytWR7XgK5A7MPnTtY1cXOjWx1xhwkI9T6xHCP(eXBA5UbRAfY8oZAixPuJRzl5AEJnLY0SGX9f6oAWwPfMVu(FNGbNnqUHRAIUJswIPOppIftAgLN2ezt3NEWF1VAgpJFIzgr7Nt9tWOVt3zJNFMN2MZPemXZLK7YGjcMmk3baJEEEuyAAve9n8FAlggGsQVn2fFEJyv2L(hOVSYQvX4GXKEry(kH4vzylLr7CdzvKspf9YadgL68fX8QhKCUnetX3(5MbDh31mOkACp7743fkRm50gyXi7wN)wMV6wkInLUM(O597Gjc3yTfwNOQxzCM4wXwo82c59gmDJcRF9PH7xef6LOW5IuQirg(f1CSIr7jOw8l2V(Q2b55AUUAs3n(PwnZwnKCABXBJTdTfxHmSv)89osoyAbo5Ph)eRWWWM(6jf1Hx5uQPDxdg7Q9uySwZmb(b2NK9gf71huShMzM2rYUMFEJ670Zar0Bi)O(a5h90JCb5pY2kzl7nJRz6z4TEv)MRgiLEpvpUf5B9zxKCrFkyLV3xdI1tKfZeHDxARUgPMIuktBADTHfNEMIJiN00PwubLMGUb2UtVo9m97YWEbVh91bE3RhaSdQ1H9BIC8xNjIniSFai30292XYkh2xHLMCmNnE4UJkYR952wlNCdMDow6TLre7U5nX9yLQf0m7eDS9ctV)4JEo5fBwhLsNtWXpxwXojbKzHlxIrQ3WQYkCgzTikTFnlZpcDMojph8gPrdmshzXaFrD(QpPepstuGii0tDxKx0CtXaWifT4oEzUrd3Xjarn(To1HnBJ5uzbDI4Kz53DxThp9IWdsTGKAObqBSZBnGEl(jDV2WnEQtr3J8YW9jdDegR3r3D1VtF7J)(VpXtM0I4)If7pMYExtbhdCk6wHJoPj4ShgYrgtsBBI2w5ySYgfOeGAU7y)4cCV7Xasq8dISaI8DMhtDAh4HpjYr3e(kMAklxh(pkMWZ5NGvYqb)BWPzvYe9HXMZX20zTNlLw6kE49xLIPCkn8asvnnyd1fhOK(LdmvTTOeeQKX4H7I2SfhBMQS)bHlPS5fSGNEmFJpWusvULeVpjKoFU79UYi8WRucF(djy(ynPeCl2KWUnvK213k72PzqV6CwYtXtG0CrzC8T1h8GLjjbyG(P0twqqo519CvYtlQ9M41wDITZjBRtK6nV4x4NQzH4xkX5zyUSIjK8B5P3p)OodoJYdzxOigDltOVIV2nK54CIEJDajPWexuNSd71rgqPKYtdhqnw1P9wA9x(s798PcsE1UBu1b76PQPAfjr22XPGdqS4prNsz7qrDme4TszdO0YBdAHw5xaUNaEwo8iNgF4ygwR397TUF7ND0HiO3A2EADUyHRwGfBKoPsjiUnvGic)9v0r)Ge2rc(csKs(rIk8uDKZa5jGwbQBWZShUD9z896Fnl5Mg0wT4OUA4F5)C(n0rDMMZk)stt4Rxj7mghN5vh5i99TSvgskiqaxgvdbWm6Vk8q8KkLxjceAl2J0fsbshznFjNJ6LMIcBlWqpuiJwNKxiJujg8s((oFbFkqNsNpNsIoWa7BmtmJvNfRtCzrSnf(v61pWL1adFIiu6wd75RMSzGVw4a)Qc(CARy6GhqzC0SqqKDA5ABAsCM1Rw80PEdnjH(4UAIuMcX(gws379E0YjQrj6IA5kkban2DzU5GxBcaTTTegBhbTBacPLNE2y(ctlXKFZ2lGU6n37zT1DrqKMiZZOQnedT(e0kHskbhX(KP8a5URkfklJ0DJfxjuuVzQJW4zr7rsLHWen9CWJVmTetsp9q5c6VFlqY9nAJq0Urxw3ZIQdWXkkVyERmM)afnf0FUuyqIRSItbIwLhdBuFfE0EyucEOpX2(D8yqLQtZnyu369QnMy72IeNN3JwgFBzW0JmKt6aiV7N()3Dxn908WWG)TmHeAvGGMSD8foGeWX3dLZfn0kA7aRtLooYVDItAsDtC8cOUbAA3wB6SR)io(JNDMX7)JQWMX1njUBECTz1Frq9tJuUvNRAYFlFFYHgbt8StS0ECA2uEomoSf8tHbZp7uWOUfyNY1TvV1n0kdW4Mi7ymDyCDciUoJiTF1nvaui66PhvKStPcjuMtLFsVtj6TM55KDMSllfZZZsGtvU0vhUhasJfBHGf2SsjfndqDilt3DfSuHjtjpHW3k7HP1BBPHCkOuB2jdEzhQzDPnndq72yYoLsfqxuoWraaQBW35dRBqOQ2rBYmlyM1c5Kz(WwI5Et(RGfaSmQfGC9gXY6D6ugaVj(eHpxT6UbuNDN1UKNT4vDgGkkU(H7W5GW08eMgburE)VXr19imbVGcW7o7eBfl3qtPGGf4(EpLj4iCE0qq6H7U6eQ2IcomdwAIGFc3gOoNXGZjcLzYpIQZOMZxylthZG)38aJXs(mjbqgHjpIx2DG7ugbmPyHqmmQsrIYn36x1K(7V3kR)8L5mdBe4sHOXaTT6INDndZYXqPR3ktxVvmk6THqc8HxVvEO0Bfr0BdzsorPK4Ico9wzGEBeeGkQElbIkEK0BLCmuc6TaJ8SAZWLdsLhg1U485sHwLP9YrMNHNWnVhmNNhU3gZWZLOVHgfoJMMhOieRikXksLy)rMrJJb(OAeZnpOJLQ(mw)3mEezTF4IaWv3LA94aPJecIWr35fDRRhxs1fobyjBVzOJlspCAML5E(MWJGZcUPAT567)P9sTTrU7FoS23dR1wq0vFhaqZUriskhb)1GOgsZPqagBY6X4giBY4YtMFL48jBBQ(a4pLqhL8NVVYiRRigsUBiYJCsO)Poh0GnmuhnAw(fXOTS9CqM4YtjT8uYaODjlpL8Bd3Fng5jj6lFSLNcF5jbjFuLNNcwKueMd(Ahh52Fo7WtblpkcBKLB)c2BLfl21UQUPSa(3UOSv9P8R]] )