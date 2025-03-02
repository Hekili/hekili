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
            return 4 * empowerment_level + talent.blast_furnace.rank * 4 * ( talent.fulminous_roar.enabled and 0.8 or 1 )
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

    empowerment.active = false
end )

-- TheWarWithin
spec:RegisterGear( "tww2", 229283, 229281, 229279, 229280, 229278 )
spec:RegisterAuras( {
    jackpot = { -- Need the ID and name
        id = 1217769,
        duration = 40,
        max_stack = 2
    }
} )

-- Dragonflight
spec:RegisterGear( "tier29", 200381, 200383, 200378, 200380, 200382 )
spec:RegisterAura( "limitless_potential", {
    id = 394402,
    duration = 6,
    max_stack = 1
} )
spec:RegisterGear( "tier30", 202491, 202489, 202488, 202487, 202486, 217178, 217180, 217176, 217177, 217179 )
spec:RegisterAura( "obsidian_shards", {
    id = 409776,
    duration = 8,
    tick_time = 2,
    max_stack = 1
} )
spec:RegisterAura( "blazing_shards", {
    id = 409848,
    duration = 5,
    max_stack = 1
} )
spec:RegisterGear( "tier31", 207225, 207226, 207227, 207228, 207230 )
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

        spend = 0.01,
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

        spend = 0.14,
        spendType = "mana",

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
        end,
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

        handler = function()
            -- Assume damage occurs.
            if talent.burning_adrenaline.enabled then addStack( "burning_adrenaline" ) end
            if talent.flame_siphon.enabled then reduceCooldown( "fire_breath", 6 ) end
            if talent.consume_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires - 2 end
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

        handler = function ()
            -- Many Color, Essence and Empower interactions have been moved to the runHandler hook
            if buff.burnout.up then removeStack( "burnout" )
            else removeBuff( "ancient_flame" ) end
            if talent.ruby_embers.enabled then addStack( "living_flame" ) end

            if talent.ruby_essence_burst.enabled and buff.dragonrage.up then
                addStack( "essence_burst", nil, buff.leaping_flames.up and ( true_active_enemies > 1 or group or health.percent < 100 ) and 2 or 1 )
            end

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
            if talent.charged_blast.enabled then addStack( "charged_blast", nil, min( action.shattering_star.spell_targets, active_enemies ) ) end
            if set_bonus.tww2 >= 4 then addStack( "jackpot" ) end
        end,
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
        cooldown = function() return 180 - ( talent.clobbering_sweep.enabled and 120 or 0 ) end,
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
        spell_targets = 1,

        usable = function() return settings.use_unravel, "use_unravel setting is OFF" end,

        handler = function ()
            removeDebuff( "all_absorbs" )
            if buff.iridescence_blue.up then removeStack( "iridescence_blue" ) end
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

    potion = "tempered_potion",

    package = "Devastation",
} )


spec:RegisterPack( "Devastation", 20250228, [[Hekili:S3ZIYTnos(T46QrXoXwrs2ojZCXERK4KDNuZotQOSZwxD1zjkjilEHIKlFyhpLl9TFD3aGeaeGK6vsM626UDITbyJgn63ObW19V(txpCMxg76FDqVbN370E972)h79Jdo96Hz3hZUEyS30p7Dd8dHElH)7vSB9sZ8Y8JcX2UpiYBgcJ0O8KPq7lYYIt)PN(0B8ZwKpP70OLpn1FzEa9ftt8MNH)(0NojiAYtZwWUZl5oOR(HpLfEJFi7Ptd8sthTmAwEal9PEXb4)Be72OpZs6ono(6HtY9dY(5WRNydZF25aMNgZME9V2)SN9CaH8NnJX7mlD61dXoFsVbNm4f)0QXF6F(pxnEiZlnkC14bRgNhJqC17x9EOBNDsVF8Kb9HUn0F5BKnMQ2A)ZHwFvqq0DRgFvI3nrHW)HTASpaUx9BVTSRp)Kbp)4vJHpP3zI)fh))HaKJNNeTumoQFZPioUaa4)0lb(peH66Hb(PzPirNH)3FLwdzHEtcyZU(1xp0BkF1HLXsc9ZUFuAEcUaYwghDhlzuw01d7F9WP3pnGnkZdAdG2VI)LeF4t894G4w2iwiBPpIEV8IvJ7VA8twnoZlGfM1vc70rPXEHDfJ(QXp8WQXtYNpV7ScQr3e2sp)qekaq6(8Zxn(XRgdlrbbJwa8sWSRtnF0L8H28tSnq5XeOoC1yt8)s6VEQ6myEuy2OO5Jw6DJ)0YjWr0qDylNUhr))iUuzeb0(ze6CqdqHZyM4hZx1EROta3aUSbml5PW8nXl8ZRgVmkndgR44a)P4hdGocbpTg296mqwydyggS(mddiQZaIyTLSed6UjCew4JWP)PBW0)01F6Z5KoTTt)dAIRREAeoGDhSbujlKwKiDMbrsLyCMBAwfIug8)nC(K60bn3pHnAscZlBrvfqfK4d)kP04i6RelfEH(G4em)kxgGgV1dWi436o1lCe7lzSWzJMLyxghhedP33bZ3vJFnnH1fDbH2KOya4zAsTRgpnkpm7PCKQEzynIPBguU4jIWnqx3zsEBnLv8HPtJsMcM4UzeB5ewsQ23FOMQ0WBYdMRlajAAc4ar2O55jHEtzvKdNgffml6Uqjee2mkH80f46YSreyu00BQYSgLnowNALwGAxY2Lkc(ZWA2rMkQTO8QrnnNX1tnJn3lpiRoLvXr8)vtI(kwGhymgAJ7w3Wpb)78vJVpkheQrPDVjr5zCz6Hdxn(eUz6a4JsybG7YHqJZJaQwumiJc)7Dly43rq4oQ5R(4jx(UxFYLdhEYLjrs3RlzDC7PJklD6cVm8dG1cWf9eQxirEgJ(EJMhj(ZYEzZdMbf(3mjknLgZ5(3SiBKQAKtp3MsRiWt9uwwj1vYlH)uqoAprI3w51)l007qvjwn7rLDfi4VGWZl)l6FGclHLEFKXc9VlWpyLeiuRgZq0K7DoSGbR8HGaaqmvDZhABcSoFxuYNbYkSctmcOd7l9(ce2d4t)ew2Dm8ZP)S6xpf4W9cNrmcaxHGNnfmB4FtyucbW3C1hHwMpNnfXO0m)Lig1LOMJ4rKHO1Os4AtXuTRfs4edKTraF6i)zQSEcju)LlHOZa1wanlljNGJQhSCHRH9SS6YyXvwfa2MNtStS0uwiiZdqWFQFwHPBUozIbv0LrtYtanYLS(jE(ZGadjTxZML2fLoXVMpj1gxjYqkb719mnLplzbzJ8swgLOP7s2Qxil)wwI3e)an1JUKzofzTSOOQvlcA6zTSmurnTbt8)9BNbFXmoB5W7t8N))qS8fFhh6P(yaVjSmqJBQG1mmh1Fd8WGYTIobngZsaUILiqjTyqmOPQmYs3C8jfKGLfVzCGqqDA0Y4a2xGWH)WVG)wiGFiCl4tQjioB4mW4CMGaFUbbwJq8X8yHo5LEFMjqgKJjaWpCAUaCi7(YfJ)voyz86HWmbmmpF0ntNX9W9xFgokYELd44TSa1Hf6YZDypzQhySL)lJWy25rUlwPZab8pJosda4fgaWTVDedgWhbF90mkqf5GLKh6CS8Ii1c)Od8SUpnnJB(moHblLt8SAaTzD9IzB3S(DbVpgHKzCHxih(TTr)0Ul9tsanFGlzZtG5qEc4ayweOrij6Uuv5tXNnQpbQ0nZWxXypOoe7BtJBcXyqjXWHLh)5Qm1fEvAqnLc(kRnLwrYtiVIwn(huSWRO3OSdGisp(8Q((9dnnsCaz6NWvSP(ZyOtb(txuacUUMypF0)o)SfQ5de0qcIpZrToGdvGD0C09BY0F)YFVqHGv2T07dN6KLAelif(5EDpVGhRFnMGWvJ6mcvUUYh1Aw5g4yLBWxTvoRJuXkxTKhtdiRHKlP1yclaekG)t6iW8c4wAiQXNLytdt49lZzGCh3ac5dESF4SaMToNgF)smgTK0r3XMyMGqPxGalujxdgRgGICd)OrxpUdKcJWs3FkSll(oG1CM)Ta)SWLbUtQf0XIUZ1vGM4JtIW(N2D14)Mhhh8dZaJNKlQlJM5p3hjbhonhOnHuCq97E(xoIlHCdyoJ(OfqCey)It8bFDX8DInRak5mRRif4whL0fr5biUJZYfEH3GteeTu6D5i4hof8hmfjDONmZyIFfgIxHU5dFb)R9uhdYRhmKppfP978X(gLi)Pqm(quCrk(lP56oRxkqd(vM7fu4HXMXgoynydhSoSHdSXgAtdr50W0lOMNg9StzIaNVgn1J88OIRrBiuhOdvtpHAgQ6cOj5tUFeevyq8O0fextvHyW(qAmpCBGVZljeKzh5pva9kZA2xMgKpJ8tRFVnh9g0c0BWAJEd0qphU)1wZks5rJCJvRxbUn8GZSMml1OLPNQ1b8Bhv2y5wcHzr7j14lvrpTGqCDd8nm6YkyLv)pEQwhAnwz6URBSQVcwPBRSFbNfLPZ(oCYTPL8zElbl3J2MvEBTRU8QYvhCBapejvjr4pw)CBTYwc37HU9QSVkgHFs58VFrwDe9fml4H7GhybxJoL0NunnI(7iozZZTewJPpywcqJzXeCgHr9vMzMZCMUlY(gpfxOjym3GakUayhjpiK5Ls0X8yW7cQbm1u0gDh92UusgEhTj2lrt5yQQW(Cwkd4VszSLW3h4xejE6DmW0ECe6aYemPz(zpc9HHLCp5rmzE2h5EtbuAoU73Wa83K4eHjqej8K1fsB1kmsrHZs5EPmHDdLNjCcnbJCL70byJKVfl9T57xliWfjjB6eTSEHG0MD8wasT1SuLmvp8f7TLSHFItfSzZUfOSrwQmOdRVj7cDF(HyDEmIN8E)W55ysFg1trNiO6uZapQQdrfW(vWOyFcbCLNdG7AMxygUrfqGTMIS)v0TUHeNcmbtcWF9vZ8IZeJ8hGfPCmhrvskxkV7J8k6Dr25W8dyAnVY3J5Ponlkz56T3jLTs27n3(LJ03BeAai8X08T1DOQkkPKXutSPtDysjAearAaUBmpWJ0YLXtmvnBiJXowu)(0BlKrrYeLjpnbyCzJU1)g1u9QoVCSh(DQMP3xYteNghewXpISpJk7srLB)wmkKYdjaNdO6O5KIluwKeE9ereDtq0eVarIbeI08p0dlqig0R3(ABzCQKgOKs8Lr3YwszUNN10NPLt9fqRjsYd4zS(2f2dDPOt5MrUeljRz(Pyqv3KGokcO30pNAqFR0T6twoscptJpLWkBjHTUDALZyRVsmeO6y(QLntHTofgZxn8vFOYgRLg6fJDfMo2YAstd2RM(VY9tKw2qiAtgNHzrdcpJ4(tvvquBES)RjEtwn(Nt8HPZhPO0LSpk7KeYLqB90nj(S5CtaYuMxx6ORGLkIoQm)1iADyXQVFcMwGP0U5yt4Y9gfl2IrHvlOhD12mxLSrpFITaMRmnCUNnk8Qv20NscLYohveyBrBLB0M(MayA1t(bz(X8WYbYpl1y19t(av8TdbzJmzfIikqe1IdrKNbYCFCG390c87i(OfEX0E2aJqYD(42WqG8DV2O8Ak1SBBjM2Gxl7dZrYL463svuqUXDPTtlSEuBTeyRYn0svORr(LnH)T0yRle4GwG)hj2Zktxt04gEdfBGAjebI5dX6ga8n0)pipl(jWKsiMtnEGeyAPejAtS18YesfqT)I0NW5EaXsKvIr)i5LmAJIHBQp3d6t7L2ovfBm3KR86wA6rjupZizmj1wQxffDnKs2rP(XlI0RwtPglu6Qlb7SiWKfJB37fAaPgZzRRgRkz0rvLLDC50b2TAk2I5oUNf9pxSgutjB0ZQgnBj3XchQrjQ(VzsxdM0QCoMLzPcZdl1AYxSzNY260vVMt7dL1Ue6Yj5Dj9xUjIVdbGpOOFxZPQyxwpggHf4yx6Rw9gOxX2sQYg5spnQ6L)b54jXdBPXLEFzKOdF986Fi5Qjw5xCl0izyweln8rzQe23(6JvCuJWgmNf43IHl8MRSM3hjzJBYPEQ1H44MPQjAep)Bg1cOIIWcozJIisTqAgPv8m97oWKl3M4L5MM6QUuEFEQoNivkjpAWJQuljEed9BWQwzolbx0nRPKvJ)m2XVyn)ogmv6v5PGNHuEoOIppo0cGrnbmCev5SwstKlNX3NWSMZOcrBfZoTqgz7dqRWhOcwcL6btrDPZrsZBW67QGCZtkDzQDEcg4zFR1M3)a5k(7EOHGRuaix92BEnwbEHzs5TPEXwtULgXxh(F4E0NRZ(0tiMYtX)Lh59VhHNCPaYy3jCUd(KGZwIdn8N)aqQ4)cLVTR(OHyPnB4NrFPmcBRLxNWfCfvv3wGoRziwL6YSRIOuGxfpPILdl37QbcSRek07HRIVUYobOXCwW72SSqbFSvRkLvoFT9PVQTpoL7qYPStA5QP5NEEl(0hl1CFK1KSAnhBnzUOKWdtXqWWKf)JKTuX5iNHcQYdCUcKSKMuTLeVWP(4mNWDL4pPgdyEXftSu9cG2YIvn(N0FtMhNwIjBM)iMA04EO9lVtQOrm)ani0eetApQD7Ne(Qve2Vy544IFIxfYyV5fNjtwOY48AIiksSlPrab3A(XbPo8yfAEww(VIWnrBMaOZ007geDJ)0IJT4NSXPH9ojjpoBeUlHIdWjMAVPb(X4CTtvNk7K5dsQxEXGohApvMxo4Hh0sGjEeba2Q7hrtcZHsPjCa3eORjW4k)QxQR4Om7QTsZLJeJ2SnxAeC40GTDEy9vsinSiZqQQbfd1dnWGxWUIE5n3pDHWyPe0Iu0ADhkQUpnVIRRqKgmEr78oFSQxAx8HfbOPQYrDYDGtLsknQX7Qf52njmwinxCNS(6OTMjJcxUaJI)bRA2kn2vLFDGRqV8(J8eK1jX)ZM()8oGunH0tnxqeTFy)e7RETh7yZQgYWvvRPqUAgk6FApn9)kqfI4okr3PDHzMdRjPhOTDZIlu)mG5o9KwG1z90tkPv)He97i5HN3G0yzRCkYAmNqdYIPbrzQ)EBiN2RafS)PsUlRM)kzVlA22zkcPvwkNMI59rfRgB5avZzR(ufNspyLzj5ugYk5DCDil2HkeRYsg8IchgSqrfffLn18LLYcVc5mWKkLZdoNmyZm(alfieYi(SETiy(sE)gcr10RklzhRrIvZedZDbrPGuLMliFoOAefnJip5tZeL56XYeiI19jyOFg5UdD24XeQGLHn(3mleBSusfAWwXp7E8VfPLNPhz3BxYs8Wkl9tjGja6qUeYZezHRyZIYNei2XVvkfuBgLgOOqMW1mAi8MtP1C4WN(UxlWsfF14zacqVFRS8XlRUM62buXWoyZvm0F)OyO)3zkg6xNIbBiBZ86dC0P(TrXWa7kgQu9HnPyWA9m(DOIHbTHyyyUBqDBhVBtKg1pWwwSHLAWnOMokUrvBgnA5rPdvk462SqFb)GoiXn9k5qKpn(8koHDlsr62x9Kr2UCb3wUerpC77rZt5oL5eZPlFVSiVcgcgKVGOJJpPUPJL8l(ZZrDW4owrQTrklLi6cJsYt9avloi2jp1JKsCA735FwXAexxoT9lmFE7ndTjr4sIgCSvHivv(Bi2SMIadASEB3arGbTuhRshAseOUtP135Ia9TkcyDk)1seWsL0uv36))r3PD8V4yJ81Hn57rnLgMxZCFGNl1)8)F03yh))kZ28DO2LQEYLrNMClzosF70)eeZZuoP(x41ql)SbGNjpiam9dmWnSm(bnycdds4azMw(8c8enfW(cVMlXydhfGZL2vxd1FJPWdGOtTPd(zLsfUXLVs1YBv3bKOMOGB1wa(7Ibdi)ys(pglPqmfRPX(jOiPi1)l51Xtid5ltPYMp7oMh)EqHdFCNEFYfpLFWgOV(y)5xyFE9Yt7uiRXNqIzXLxCANd0MN1goCJvBj)yIGLiPsXXuetpEZmXtaaD3mDSwPvMXRwZU7KcnQ6wQU51wjogh2I(PbmxLcPSe6CE)i2rDkBMTuRx9jvY59UTaDDxRhntEl2PLARCWs0AQxEQx1nGVzspnqfMmsbL2tIcZt7MD3D9hDw8ut1)1x9HfCpTzg(IDXmSeZSxvBDAjlyb6yJe0Pnt)2GnhjGv91wzDvi5axviP7Qp3HXe3iAhNIrDmOpdkOpsT()VGL64OID6UWASXn1wh9KPzu6Y1ugIU3fTkfOOl3bRuRFgz9nbRlUH0HIHNauqD7vrHk1XJmzOVIQHVvJ)DQi(mKWjYXMTR8gSswRuqvp9CXElPNo8Oqr6R181KfYrla)B)dd50dRt)Rai2wWpYXCXm)RfwS0nMw0MngZJQ7iqSNkErvIWNPlXaDYacVIwWT(NSWB5ZTE85KqqD7vLOuDaZmD1QRCL9Y5HLP57QpZb0jOMNdsUjmEnvr1OCB8a4j61EqvVwkAszGHHzMcY18KqNx3jnRvtdZV2C7gKdsDfhNdEp9mQ3VxD9vZlRZBxCFxSvfzBDuNAJoZWwTHCU((xB4FJvEgLoEqlO369Zy0v17stWQ79E)EFJRU4Apfp8ZVJm3Iu0sDxn(d0TiQxsuog8bwkhesb8Uj0bDataDEwkDZsHO0vFS7FApxf1MOJYC5OFU3BNFDRJL46nKUw2KBWO(g4sDXCPHZIuBdiOiAGwR71P(ZYOtD4qBDohCqJn3aZtTCanSC42TiHYKDXb26WslV1CNOkT33ULd5s8MDtKQWlTnGPgI7roJ9U(ZlwLtk2)wD4UtDi2HnoiAvDP2COxLzqnuZ2P20IFX870Ju8owtFkqdHARA26lkc7QsWR)bNtJ38F6HfeovdQV71pfpe28llg0haVz3Z5NsXlsaEkndf7Y7F9nxHN3e6ANlHLMhKXzG430EeNwyeYPhEdD7X5lYqnmLuyNXRef8QvSg)QkzbVdqvRvVQTmkuNsBL)SAYokiYQP1x9ojI8k1ME9IuH7e8N0gNhx)b16HmuNKApfuFxrvBlHZv20UCJjDUQQg9sdFMLlvdIpNRrTpxF6asOivYAZZMdVqIt5svSV4xuzFdWZczAlYBwD0w7P9rjZoNuxEHoIOpfRpYXsPw2BXri8Bgc7OIUR74e28QAr55lUOukoPQImXXpCkG(o6D(k1wk4mpPqn5CCZB8HXjWrXPu7hhOdSsdlZlHRlB(MJW1g2y9qgwrDI1Kl1XPJQDkzvuPNDCNmkZ8oGtMw13ck6bYSqy9B8dHFNcchcpHhTI7dFGZZLMLdDPGZlMo7LOXwqOryPeIbhTHY9sMxgT8A9CvXlMaEdUJ)oUX5Pghjtu)ZGpPUyi83gNl(YB2k90Z74c6PKLZ6rg(coc0XETOoW(XT6F7(yZqVbF9wJDNOM7FnEOzL3(tQt(gtF1gZsvI9fFyZN6PQh(zfpz0pT4MNho6uVjYG2lVOp)y3vZzk76DYzERPrPLmAC1tfS5ApsjCLr0CuSymbFIcsMH4yrEmTEkSSfnRLJC(vqZL3fpC1kkhfa8zhrgJj)oMuE7C5N9i5XtqenH3nEivtExsZN54m8NVQLx2gw1WiLdp097HsFHgQsTbrH3)LrbSB8Mw9MjPgajQO8gaYrwpeATzc(voZkA6ICLAfNj(yqJf5qJtI6FaB03sa6rRPgxCCJNvCJ1(P99k0iRO2EElQbbmLUGyz51WmJUJ4PWLl8ceRsMqybK0ja9palqgXjDP4(MH)Rzl8tWGh8Pdzy513Q)sSWZOhbRj5zzr09L(MCyIx)Z2BNdRYh(WdvnjUNpIXRbASl0l7qBQ72WB6wRgAqMlxbCuAzZQpFfn36lMXDGzxeFnDx)71twC97)BHlkUU3z1GvvfThypcdTqs8REIJTE(MB3frHJJgUroEbtR)COmfcLj2LN3GFwzFUBH9eHTmoZIXovRM)e2xytZZKBDQTDrOcLqr6sfYtcYlh6k03I)O9qxBo8ZITu20pa0epTuu)2swEeV5AF5QmCMmHm5ICtfS7FnHEE7gI3V5PYJ7i9aNM4FdLcuDrkL6cHFglbcxuAA0YIYHv2EL7R5suq8Qub9GUJtXNa8Z69JGl0dVZlbveNkowPC7lIj9JyPpcnFr3xRZKLTQxEwK4WLYFcrs7U69)IpwVr4J)9BIcHHHA(rs(Im1BmShXNU2BuYZaD6W(F5OMGSwvxAayRvKzlH7(dJ3bqEWEdYN(1gYBX63Q3BHHnnB9yyDGwL6gnWPQjDy)prRFPHu5AUKOLKmtiDMDiz4tVbiD4XFBHDr4eMGTsCgMq8Ch0tLSKAsoTKa1wc1IcpWaKvkiHwcVkbQxHQ6iq(wc))CqfksMMb8QKKTwcV9nvDJX3N91bEBGm)ZDGzkvWRjYzP4EBju3zRpoGVwfkzsgSv9sTfURpD9fUGeVmARal96UTLqtzlrmaOLnlPLW0iGjd46OatBjSvCY3aUwQ92VHWCFsdmthUjWDKT8wc9TW)KVj4R(UQBaB7f0QjK)XDoLWbe3yT1oG3wRTYbC3zAzDa)T03chqDJ9T4Bev4pb8xRVvR(9COK1sg4n12wts6B7WSfrd4eK7IGx(th(6ifdBbpRlqUXmTUa4otU9B2aOucMgG2sPBwbOoYHZMtNDKFGnhGoc(ylnl03HV3BLpUUa6MOA0HhmgBsI5m3(wOub47EJmUa5MVUVVn0U3hGbo05UJCX1f43jCid23AZg4qXJs1jyaAl1TWxhG6qJ2o2jfxdZwy03ji3fg9h4ifR7AYIl1)7eUCxPJsDlERO4YYge3waxDNFRi87ARHB7qyS3NpYMrNk7mAfG7mFsBfWTUvjIxH2hTl2VKDmZ3UxKCFkr6qGCdSaBDDkobFpMN4TMRuvmKiULR43RRIAcjdCrLnnRadlVjSS2jD74B)aiFZ13aqVKUiUUVomVSl7wGVfyn0wQ4bPPomxVB7(bzlMb0J3ED4USd7saVf4lw3l1HUI23HGD9rw)0Ul9tsIsWnbEEI30S8e0oAeOqlj6Uuldul(eDdlog8bTry1rN21dGlcxlaTlbwRDz3c8TaRRtq1z329dYwmdSl0APd7saVf4RvX2QTVdb76JSTq02CGAXNuV3qfQIQC)DAr3JT(Sxb)EdWFJW7OygVhP8Y((rUUFs7CyDW)h(HY)uzEIKTErVhEOU2)HFOoyFrVJKtXne52kCRjuZTV3fIrnVKzVp17A)wc(9gG)gH3nZjpOcZIf4VZ4KTa764KBhYTv4wtOwbLTsTivO8b0UpHfaAYH)tkFNYZdXsQNLyrnu99wJlP2Hm8(L5mW(fmFULfqvbrSEnTOnM1192pO6x(Y2hPk9rd8vsBvbN)6qgBQ3TFiBpzSXU3(bTbYO9(Ob(k5OxDvI2rM7wWcIhLUqD7V0wNS0R2pe3TWpnMx8n(azpjeplK(tTA4THURhewLK3Rs3ACI5QxRXy0(zwJDxFuDfF5MQZFFd)2az8Wo11l8(rZItRd6U6xBNbTDCqZfJ2a436yGRpi7DXi4m9eUZprZRVTW56Do8BdKB36Q7(12zqBhNnJ)znYO6gY)SgJqB5FQ4A4bodKWLFzp8GBp2Q3LnxISh94d7398N4qKaA1YaMEF40Jo6YdRpChxlYMJy)ghX(Irus))ks3E6xD62t3d0TswYAsYsWTwTUZ)Z6m2UGsF7qPVDO4OQh2L7mPRctqEUFnGC55bEnb4guwnUa1wv2pUkwInFc76m7TbtyhGAdNW0(copkii6oF621detWRsdw5JYzXDQh)4GUAmE8JPBjaz)ONUJ58RqYYEpBg25zEzEt8sz)0Q3ZVk1s8ZCSHKEry0iBZwrk2i0T7WN4ATA7pRIoQMLDwn44ydJ3jLwHJJ00wuHzoG4wDGmCaZDufA5O0v2jB2VlyV5LMWxTJ4XgOf7BYHf57o8C3x1M76I28R6r4yNPh8pf1VUR6QElnET)oP99DyEzBOQ7ERkUkV8DhZLJ6072OaVmBgakByDb5osnJlWVnuzhGu7Uz0aQ63BJUaSdnUIBWfdqkVxxC5VLRc2wCDgzspL3YrRPR3BF1L6WXWnfpDDpEShk2tr0P7ORZL13aT7iXlsjG4Y7PaSwYtrzx2JaVfGftfH87SasJM3J46Ef4nc22N3ZwLF1TFyQn9QUb)ML)59m4Dd4T2QqlQZfxSjw7YEe4TaS1kmwP59iUUxbEJGT9BIvReg3(HPwHr3GVzPLwSzL7AW7gWBTWylkvN1qN9Ef4TaS7KIpOfy9AT6TNbVBaVhzo2jeA31ItJShnR)B3c8wa2MjjTO(HAbwVwMX3ZG3nG3AEV9mH2Dbm1i7rZ692TaVfGTzsslehBbwVwkM2ZG3nG3AEV9mHUswr2kvt7vG3cW2mjPfIJTaRxlft7zW7gWBnV3EJqBnXmZXoS9PKzJZV9U(EiXvkY2nPiT2mMzaZ1mHuImvIj9C088KqVk7RPwBRjC36eU(v(ALDJx)DaVD06)U7sW1bK2I1)vV)NjjBeCVqVkmqX3Rhcs1lIsUE4q)LV56Hqy0Z9dkUDVt7wCoVFYfpvwCthJ3E8xiuViR7RJV1liV4VAT29E4blTkohJwBdOdYtjO12PZJN1wWcfrTb)golAREF7NWdSoHTvSRLyq1dUP12SoHnpaIwBrFc38HVB17)pWhgNP092)Dl8NUy1yXxZ5VI98tKxA)xvyE6y8PEaFCTxHppfl9dZZyIxZR(L)UaqRfvLxOChhfFrklZFUG62N)VJybPSl6198JlEjVVO5taMTkIC7o3m)qnG(IEhToZ3bB98TY5eYwnNUJMVwannFbMO3MM5JUfGVKskl9JPjYk6XChifXa2tVF707RQawY3T9swgG)AM)T(0Rud(LuBYruP74mhFFMOxEeS)GYSX)npooui)HpqcZ8N7JSRhkEuHXhKI(Dp)lhXzZVH)C0TA8c)BOhg24e)iqw6EEZkGsoZGbI7XKTrjDb)jLfFYO4ojnJ)4JO07YrWpCAcZlfjDOBxZyIFfgIxr1rh(6tjMuLJXC5RpLNIil)5Rkkr(tuv1HCyszyjnh163EU0(GD6WCVGkA3R5KizO315HhYOF6oOUoi5a7izThxkdDLTajTeb36GK9hfDZ0z0J7Qap7ToF(GT7Z7pI9LPb5Zy2winp6qglmopSpRdcmWbcy9Slzq03jiGuQZuJ7avnU9v03UNQW96oyao2gdJQo3MNgTSy3R7mc4ydnngCB(1vxDV3MLi(tu6O9Wkv1wKlikmyb3gCPQab87KHTp6f(zYTgXlyj9oItpsGEyjmtp1qTy2P(IolTY3T3JjynICOJgTFx8rc97G0qi3eeEnFdd3cyDJSGkWMurhZJHXLAaFWLWcO(vrVTlvT0VljAjy4anLXs5pF5NLYMIV1NSL47eN)Nzc7PP3XatBXrObyQ2S9ZEeAdhCuLCRJmp5J2CtbuAUxcna)njoP8uWXF79Fgoi4kuk3k9e2n(4zUbNqty8xzrp8LQlTD2J0Eyu9IyhlUNWU4mKljHb8jTbmkphAfqONce2PRdd)06p1aT7s86fR1mBQxiOHnJfoB0SeRZTMHbkzJWauWgmk2xWSwOXWpeFV8gXVhz9dNNJpAtJ6vOP4YEebKE)1gsRWd5NseGLS4yISA8hGjBoigzhH0FSOo2F(ffbJBEItSdHIJtHY3w836C4bAXH)WdYFx5Co4qNL6tHgc7dmboy1sf2DQczmCCkSRapqSkgDrJZOW9NJEpK9qHiVj0R2nY2nCijQTmkLCDfCLHDl9qlsCDrXSqgNnf)occ3rnF1hp5Y396tUC4WtUmjYGIbthy0HFcNiKYCfV)ZJbYuXQU5doa(Sg20J25dpGJt5RB2Lxm4OhEyciS3zo9gulYJ8lp9Cdzoq7bG7mKZJhsbx(dF0Kbfqf4i)XKgdq4UOKptsDCcgQlBP3x8xMVev0KDh9QMXJIq5RNoR8jOoPuugu(5FdORJa4Bq5y285Kp7mzqoDvPH6IpgVSZMIpkuy50)VC4HfnR)2il7YjV4Ol)lLDYYZkh0dmoS)d8r3dLpHaYeIWGOg3S1plKvtfpATly3)iIl7wp)aoDhKHPjTcrIGz5Cvi9xOFaxQLkvvvi4GJ6aRZbTgQYP5MwR8MxQiNB72CuxxiOjSY6s5lTAXcZZ7y8iZF5f97CanTmFYw1EIqfpaSxEbhV1GTCaFCVUNvOQO8GyivxyCIpQkkDkpS7)73cE)idtE49j(Z)Fifff5cLBoiL05MWYYti7VOKqyoQnIhnDrNGgbFSbs6seOKYLSfOu2m1K)KJVNY(KElWXfVzkHKJb5hW(cOS)d)c(BcVZsDViQBZQCzSykOVIztpLLz7lpJtG(yESqf6sVc)CW1QaaVXP)cV447vXU)vo4s2X4P5mA(8rq4wx0xTzrWHQ)jZNquTqo0M5j5Hv7i6id(unond8NfM)vwQBecPzcBkV63ERE2D)pxn(3IrLF8W)rjQYh2Au1g5tJNi7h3eenb1yqkffE6W)qOX5jmuTYRlTlcioGrgcShR9G)YNr20(bRBYfALZKqP1tTZtqhDAYlvOjcSGEAC1x1Wr2(dR7lFMqmw(G62b(aPy)Lyg3epKVvQO)Y388sjvJUykR(YleSI1(E5AoF0CGHBNv5b0LwRNsBmNAQWQdgs)u0pQECF1a1m83KvqEHuMizqumwI8bK11Bs8zZ5((wOAXyGTlqmFIcEuYj0Xb3XHs15LhzVcUdZ9Kb8Rqy9g(BQ2wmXmfvXkiJH22ovulxbmQgixn(t4BL9Bbx0q3wa9jjrX(EukWjPaupyo6nwzOeXGVFenKEgvbrOysvmSWKCNpQDLa57QiSP)EeHtHcFzlXjXRsTg58Oo16)WlVObxq6y1RwZ1HY1sXoCHEb2aKFzD4Lfx1Tneh4IVGl5XFKIFhjT8AoFX4RgI(nd(Z5)hKxX)eOPu5DkgDrsKRyuKfCxvMt1aQ9xK(e(6jWxIlUm6hNjUqjG1MuzqWN2lDDKpA56P9u2lvHvKWdZiMljvf2mleQup2DhHIFiVBx6lZIavCSlV4fLUSyQ2R9IGLEsqsGvhLthyXFNo26z)ZThqrpLL93k46afWiB33JR8RLK8UBLxFjtx6uHaE1R5eLqzKQOFdKlc0F5Mi(w6aosGwtNheDhgPe3X5g0)EGfV5m95(uUXtY2jggmxbk695SiwA4JYuh33(6JvmvrUuG5Gc)w0LO3C1g49Ifh(jVaEPLgGOo5UiSLo3uJR9VppvNQtEJ)ObpQI74E0I3Bqh)NZsqS00T8vJ)m2XVysv4QwTrmoCwuMQ09iEABlDEAaO6OGj0iy4llSY84(DhuYrw2JJmXK47tyflc6vJcrNbDadumTzrIaDTdwwE8zogpGu)pqk4F3dLCVsrLgNT)nVgZVqyMKrBQxCfUALpYjh0M4ljy(RGwQeSRqTGtiwyuV(Ur)ZJpuM5UN0RBFHbZpCpAQ8Sp9eIJ7u8F5Xb87fhevQL(dO4eaGX55qA1jyghIc4)cfbjOVWXQ6HMQ5p7eUJ3wFrgaVykeHkprSoDkukxzNJ9sJ4SGaYF(5hTfSsL)nn20J6yDjewzBIRqSkBrZZfdQPT(snOxEXHNEsduZYUEETD9Xd0CL6xENKHacJoMN8FE8eJHOtaXMFsyCOWpxXXS94IFIN8oS38KmWK53dxQeEoqDjncWatgiT0WAtnLCTqmAc6L8W(Qzf1Q7WYL6ZfFPLR6OIvi9dOl6Rn9NfKg5LIcLqv7jpY0Kx)2IDN2zJmoXxk)VIWeumtMyunfFbr34pfJ5h37OHFATu4bS)(HW)Yak29JOFBeSKWWmhcbBdHOR0cqG6K5dm8GLdTKOPeU(Ls2Dz46hDmo6jj5XzgqEAGFms07yXXInzyaoP22zxY5vYgqtAVbyzvuRqWbn6p3pDHq9kpXa)FL316VTTrm8)wYx0IBYCTKDlggAkq3sBrb2Wgwk2(wBSDus0QRvGK8sA)q(BFhjV3hVtY55qhYNSECIhpsE8XVJbmyt5tylvvuwpLJsMNIIPAoVIeZLXSsqs5nvamkgMxUN1uwU2jbFwQnYeY4RkLX4HyYjiZeYncYk1PthNyVrqPleCDGHYntM)1nnWctt1NcyEYCU5fFHk9OnyDJHc2GPeyv1szTnQvPfWUMNLqU9C9aFFPV5IGDaLQWfoFbR89yDVmmgcLzKCXoE2vGoqPr7uxU9JXfuIVy(l3DQIACG6lGJaEYC0OWG(EUzTZ5zhmFRyi8TI9kEYwY5kgpugNhlEWu(0Hq5t3BAmkFhoUF8j0bthxmWPK3CFWZOzr0FStlJRYdLjTgzQ0Q9sN2tPzOTw0PlKz9ufIPJkeym)owvyuMFm1gyb5uxdFzBRAkKKQlcx2bN)IopUXcMBXmjM72bPQt5cMn20ztGxgVNZdJfn1Pm8UI7r5t3C59hkg1aN9ZKArVTbRX9raH2QA7IOott1zNb5OYB7B9OJBldAUFUSz(kG3x32kC7l4b8qLH8ddWw4vlPKj8lWE9kudbOvv4)PluIeQVeeKwucPDzhZxPfqxb4cxvx5Njhg(05ak)wvEfvWIkHpSc3jo78UyPoknIeazUSiEZ9CCU8RYRiMjG)V7dPHh80P9IQgOUysVI)mLuW1LMtfv3LLZjei4mFi08GVDIQrn1K2CYBsTS3uV6u5XUUJl6LPwgeQTWcqys9NowoqjJI3hvZ23PWfDuTqg7rQpAfUqyeOVcqCqYkqW6gJNtLJ8MT36YmrJsJDMYtZgMXMgF1Ny58nTZPKL0hZyMW8uRiq3f1R30oU7YlZ)4SlwACOimX)IvO002pmuAlmd1z9U4jg8qYnrXzd)gJylTauecUslu4TiLkJ(CbH6V5HJCuMZuPaNkKs7Flcs5IAmBb8B3KXwyS053)9N3ajn)ievau(XfkZhwV2oxNYOpFfMi7Rp(pXwhOhtWpl6AxT22mtyT(yL48r2qrZtoal)xiJoEHQmFc0e5hpVUP6RcXXHuPXrouIlgMKgVCn0HxpCrnn4DUFZWpUGDltWVHv9j55JaEl1VgdzArq8wpOf8hPN1oOD1Ni818KR0wDDWeqF4q0mCoV2PBekUnLKlNyzYsVrWEZy3EsErRHwmONGF2(imR6w7(i9qC(qKtsGJI7XzK1uvM)FXb5tI9m6njF2TQWo8tPyJNTDFpfkTC4S0jjfFGy4cWCh3rxWcDn3lymwbPQsln6h44Rp(3re8oVHAB5qwLqvwX6tZjsywwVPRfpDLGc7H)X4hRYpNyVQe4oi66nFzMB743dpTXBoRXjnFNWAFshmIdQH4o3i8TzaQXrvn1fdW1lGy7uSt0BWS4eWPJWA8CvTFCAW5cRgnwm1hkBN(zrkgCFiDDKg3x9(OSt3rC5K9Bnn2ebqDxOXUvEupYpEHcz8cEUTMa5qMnOP0A0EjE6)WbW6kbL)Qx8R8xZbyIGfj5n)0tba6rN8iWFP5N8fAPRfGLjf6(Amo2Rp(T)8Hqn)XZWBtz7MvDxB(NsbTOVUgeQwJzw50kzsneeNLKJ3s5LcIzFrG1jDYWP8iQqeIzaHjVwsoZE6vB7ZD2t4SUGzfjYW99P3GD7(i9Yo4dW7ELJ0)eNNOE52o1nW)fLHidd5KzHcuGRvl2GrIrLJsEw5kVQQtfhwbaYjFZe(LaBl4pCXPPdh77zUjvb5Ni5RHLl0HWCQF2dkHzZZ1vovc4AnaXKX4siyqOPxVPzzzFm3D9MY8oFmWc4hfRaXoNjHhjLbdwa)SufPWPwXQ5LDc)zEwSi5mbnepAp9Zi4b7q0f7ZvTw8B0PCHdBQkaj(ZA99ceUsGXCHeK0sSiEyWgn5ccHKeQokMZ8fC4pGFxmjeftGoyX79yykylj9RbOSk1)2Mm52XdI90cmd01oOyIh0)ebx))X9)tUnUd7qZU12sSoveXaLUGw2QfmQuabOb03SGdgyi5samkc3J)r5NBbCOrBobY)UoUvFuXGGsrgUPiAtsyjb0q2oiP03Ofh4HSGzXawYdfrhyWspPSafVDn5olCc4uobthZB1rkPQ77GlA5d28ZMd(wPANjefbzf7Dh6NMXbGE4afkraCChnVCHYNsWVE9xU6JRkpB(sas0Sp(ZNKX8W9K2Fo67opokl9k3aPgujjyjdogGo)otgplYEtO0XHGHwzDYEniQlmNEoUaJ1rsOPPpyHM9Bpwq7c(dkhlE(vqjKMFkgOKgV50p7oVQbCIQcHSJPFdqnUq8ipVytxhmRtPU(iazTSGArhKAy0q7aW2296hFBmVWJ4nMRUCH921ABWrobC9BQ)gzsFWGylXoV3cmSfp)069T8Hykh63KxZYjmhF0QCG3MbcHEz1yF48GRI2WKkdkeJ3z9pjVECzKnHtsiC7LrCvOtLxvUCthLby)KtPPEMSQVy1gA49M)Yle6bDAVIF2iV9kai54IiqY8IesaXJRbacH6MQd9BawgCBzurcfAx3KpNpDIClCR3w46MWsh5bjDaO2LPmLcFlTl1RgOnU(Z79oZMWEwmnjux2R3EVvRAtjZGH1IDpnqos1Oeor2a42x5maSVpHnfeohsFXHUmiCn)(mi0K1uNIAQLyqVl4VXmxF2FnHEf4fe6FLw(IOHTWj1BqeycC0RTA1CD4bkQgkUzLg6mY9Bo6ONcyGyUoYDcJ6uTsfK3V1OPAtF3jT4q7Q6o1HdppMGaxFCcEU2BwluiJPVtzQAu0sAMCmzWR5umvEn2nOk1ay3mV8jbMoMLQ7pbr3YWkKDrSrmT2jvVQZU9LX2sRE5boI)2pVrlqxGmHdGXR(fOSfgm2ifE)9mpMyYMAcnCPQIHlvLFNivf2BWV3KQYJivfscPy0fm3mpLuvrGuvKU0wuPkMo(2dKuvrQjeAq)DNQCdaTccw3qihOTXRAVMiQ(GVUcOUOnrzwZHxtphjtJKp)v097F0wuRIM0mojL6DH(wGL1TPLWPuZSwqI0r6aBsPmMzUxqRImP4WbID731gtEtgNNTZfnL)dm)es4wHWLQw88YnIRfBpLKKSm0HiEG8IN5vXCHljtNSxmAZoI5TB9SGF9Sirl(BWRNfPnJyUxI1t(wb8d86zU)6jdj)GUE(TGgjhHP7cR3nRB)Ntp8Bbnpoc7oED7rqF7dDI)(W)o]] )