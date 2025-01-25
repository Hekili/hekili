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
    aerial_mastery                  = {  93352, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame                   = {  93271, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream            = {  93292, 376930, 2 }, -- Your healing done and healing received are increased by 3%.
    blast_furnace                   = {  93309, 375510, 1 }, -- Fire Breath's damage over time lasts 4 sec longer.
    bountiful_bloom                 = {  93291, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame               = {  93294, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 41,237 upon removing any effect.
    clobbering_sweep                = { 103844, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 2 min.
    draconic_legacy                 = {  93300, 376166, 1 }, -- Your Stamina is increased by 8%.
    enkindled                       = {  93295, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    expunge                         = {  93306, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    extended_flight                 = {  93349, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance                      = {  93299, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    fire_within                     = {  93345, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    foci_of_life                    = {  93345, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over 4 sec.
    forger_of_mountains             = {  93270, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    heavy_wingbeats                 = { 103843, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 2 min.
    inherent_resistance             = {  93355, 375544, 2 }, -- Magic damage taken reduced by 4%.
    innate_magic                    = {  93302, 375520, 2 }, -- Essence regenerates 5% faster.
    instinctive_arcana              = {  93310, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    landslide                       = {  93305, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 15 sec. Damage may cancel the effect.
    leaping_flames                  = {  93343, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth                     = {  93347, 375561, 2 }, -- Green spells restore 5% more health.
    natural_convergence             = {  93312, 369913, 1 }, -- Disintegrate channels 20% faster.
    obsidian_bulwark                = {  93289, 375406, 1 }, -- Obsidian Scales has an additional charge.
    obsidian_scales                 = {  93304, 363916, 1 }, -- Reinforce your scales, reducing damage taken by 30%. Lasts 12 sec.
    oppressing_roar                 = {  93298, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    overawe                         = {  93297, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 30 sec.
    panacea                         = {  93348, 387761, 1 }, -- Emerald Blossom and Verdant Embrace instantly heal you for 21,170 when cast.
    potent_mana                     = {  93715, 418101, 1 }, -- Source of Magic increases the target's healing and damage done by 3%.
    protracted_talons               = {  93307, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                           = {  93311, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall                          = {  93301, 371806, 1 }, -- You may reactivate Deep Breath within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic              = {  93353, 387787, 1 }, -- Your Leech is increased by 4%.
    renewing_blaze                  = {  93354, 374348, 1 }, -- The flames of life surround you for 8 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    rescue                          = {  93288, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    scarlet_adaptation              = {  93340, 372469, 1 }, -- Store 20% of your effective healing, up to 23,667. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk                      = {  93293, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic                 = {  93344, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 1 |4hour:hrs;. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    spatial_paradox                 = {  93351, 406732, 1 }, -- Evoke a paradox for you and a friendly healer, allowing casting while moving and increasing the range of most spells by 100% for 10 sec. Affects the nearest healer within 60 yds, if you do not have a healer targeted.
    tailwind                        = {  93290, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    terror_of_the_skies             = {  93342, 371032, 1 }, -- Deep Breath stuns enemies for 3 sec.
    time_spiral                     = {  93351, 374968, 1 }, -- Bend time, allowing you and your allies within 40 yds to cast their major movement ability once in the next 10 sec, even if it is on cooldown.
    tip_the_scales                  = {  93350, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian                   = {  93287, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5 sec.
    unravel                         = {  93308, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 120,204 Spellfrost damage to absorb shields.
    verdant_embrace                 = {  93341, 360995, 1 }, -- Fly to an ally and heal them for 84,954, or heal yourself for the same amount.
    walloping_blow                  = {  93286, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr                          = {  93346, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8 sec.

    -- Devastation
    animosity                       = {  93330, 375797, 1 }, -- Casting an empower spell extends the duration of Dragonrage by 5 sec, up to a maximum of 20 sec.
    arcane_intensity                = {  93274, 375618, 2 }, -- Disintegrate deals 8% more damage.
    arcane_vigor                    = {  93315, 386342, 1 }, -- Shattering Star grants Essence Burst.
    azure_essence_burst             = {  93333, 375721, 1 }, -- Azure Strike has a 15% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    burnout                         = {  93314, 375801, 1 }, -- Fire Breath damage has 16% chance to cause your next Living Flame to be instant cast, stacking 2 times.
    catalyze                        = {  93280, 386283, 1 }, -- While channeling Disintegrate your Fire Breath on the target deals damage 100% more often.
    causality                       = {  93366, 375777, 1 }, -- Disintegrate reduces the remaining cooldown of your empower spells by 0.50 sec each time it deals damage. Pyre reduces the remaining cooldown of your empower spells by 0.40 sec per enemy struck, up to 2.0 sec.
    charged_blast                   = {  93317, 370455, 1 }, -- Your Blue damage increases the damage of your next Pyre by 5%, stacking 20 times.
    dense_energy                    = {  93284, 370962, 1 }, -- Pyre's Essence cost is reduced by 1.
    dragonrage                      = {  93331, 375087, 1 }, -- Erupt with draconic fury and exhale Pyres at 3 enemies within 25 yds. For 18 sec, Essence Burst's chance to occur is increased to 100%, and you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    engulfing_blaze                 = {  93282, 370837, 1 }, -- Living Flame deals 25% increased damage and healing, but its cast time is increased by 0.3 sec.
    essence_attunement              = {  93319, 375722, 1 }, -- Essence Burst stacks 2 times.
    eternity_surge                  = {  93275, 359073, 1 }, -- Focus your energies to release a salvo of pure magic, dealing 91,088 Spellfrost damage to an enemy. Damages additional enemies within 12 yds of the target when empowered. I: Damages 2 enemies. II: Damages 4 enemies. III: Damages 6 enemies.
    eternitys_span                  = {  93320, 375757, 1 }, -- Eternity Surge and Shattering Star hit twice as many targets.
    event_horizon                   = {  93318, 411164, 1 }, -- Eternity Surge's cooldown is reduced by 3 sec.
    eye_of_infinity                 = {  93318, 411165, 1 }, -- Eternity Surge deals 15% increased damage to your primary target.
    feed_the_flames                 = {  93313, 369846, 1 }, -- After casting 9 Pyres, your next Pyre will explode into a Firestorm. In addition, Pyre and Disintegrate deal 20% increased damage to enemies within your Firestorm.
    firestorm                       = {  93278, 368847, 1 }, -- An explosion bombards the target area with white-hot embers, dealing 37,725 Fire damage to enemies over 10 sec.
    focusing_iris                   = {  93315, 386336, 1 }, -- Shattering Star's damage taken effect lasts 2 sec longer.
    font_of_magic                   = {  93279, 411212, 1 }, -- Your empower spells' maximum level is increased by 1, and they reach maximum empower level 20% faster.
    heat_wave                       = {  93281, 375725, 2 }, -- Fire Breath deals 20% more damage.
    hoarded_power                   = {  93325, 375796, 1 }, -- Essence Burst has a 20% chance to not be consumed.
    honed_aggression                = {  93329, 371038, 2 }, -- Azure Strike and Living Flame deal 5% more damage.
    imminent_destruction            = {  93326, 370781, 1 }, -- Deep Breath reduces the Essence costs of Disintegrate and Pyre by 1 and increases their damage by 10% for 12 sec after you land.
    imposing_presence               = {  93332, 371016, 1 }, -- Quell's cooldown is reduced by 20 sec.
    inner_radiance                  = {  93332, 386405, 1 }, -- Your Living Flame and Emerald Blossom are 30% more effective on yourself.
    iridescence                     = {  93321, 370867, 1 }, -- Casting an empower spell increases the damage of your next 2 spells of the same color by 20% within 10 sec.
    lay_waste                       = {  93273, 371034, 1 }, -- Deep Breath's damage is increased by 20%.
    onyx_legacy                     = {  93327, 386348, 1 }, -- Deep Breath's cooldown is reduced by 1 min.
    power_nexus                     = {  93276, 369908, 1 }, -- Increases your maximum Essence to 6.
    power_swell                     = {  93322, 370839, 1 }, -- Casting an empower spell increases your Essence regeneration rate by 100% for 4 sec.
    pyre                            = {  93334, 357211, 1 }, -- Lob a ball of flame, dealing 23,239 Fire damage to the target and nearby enemies.
    ruby_embers                     = {  93282, 365937, 1 }, -- Living Flame deals 4,576 damage over 12 sec to enemies, or restores 8,755 health to allies over 12 sec. Stacks 3 times.
    ruby_essence_burst              = {  93285, 376872, 1 }, -- Your Living Flame has a 20% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    scintillation                   = {  93324, 370821, 1 }, -- Disintegrate has a 15% chance each time it deals damage to launch a level 1 Eternity Surge at 50% power.
    scorching_embers                = {  93365, 370819, 1 }, -- Fire Breath causes enemies to take 20% increased damage from your Red spells.
    shattering_star                 = {  93316, 370452, 1 }, -- Exhale bolts of concentrated power from your mouth at 2 enemies for 30,793 Spellfrost damage that cracks the targets' defenses, increasing the damage they take from you by 20% for 4 sec. Grants Essence Burst.
    snapfire                        = {  93277, 370783, 1 }, -- Pyre and Living Flame have a 15% chance to cause your next Firestorm to be instantly cast without triggering its cooldown, and deal 100% increased damage.
    spellweavers_dominance          = {  93323, 370845, 1 }, -- Your damaging critical strikes deal 230% damage instead of the usual 200%.
    titanic_wrath                   = {  93272, 386272, 1 }, -- Essence Burst increases the damage of affected spells by 15.0%.
    tyranny                         = {  93328, 376888, 1 }, -- During Deep Breath and Dragonrage you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    volatility                      = {  93283, 369089, 2 }, -- Pyre has a 15% chance to flare up and explode again on a nearby target.

    -- Flameshaper
    burning_adrenaline              = {  94946, 444020, 1 }, -- Engulf quickens your pulse, reducing the cast time of your next spell by $444019s1%. Stacks up to $444019u charges.
    conduit_of_flame                = {  94949, 444843, 1 }, -- Critical strike chance against targets $?c1[above][below] $s2% health increased by $s1%.
    consume_flame                   = {  94922, 444088, 1 }, -- Engulf consumes $s1 sec of $?c1[Fire Breath][Dream Breath] from the target, detonating it and $?c1[damaging][healing] all nearby targets equal to $s3% of the amount consumed, reduced beyond $s2 targets.
    draconic_instincts              = {  94931, 445958, 1 }, -- Your wounds have a small chance to cauterize, healing you for $s1% of damage taken. Occurs more often from attacks that deal high damage.
    engulf                          = {  94950, 443328, 1, "flameshaper" }, -- Engulf your target in dragonflame, damaging them for $443329s1 Fire or healing them for $443330s1. For each of your periodic effects on the target, effectiveness is increased by $s1%.
    enkindle                        = {  94956, 444016, 1 }, -- Essence abilities are enhanced with Flame, dealing $s1% of healing or damage done as Fire over 8 sec.
    expanded_lungs                  = {  94923, 444845, 1 }, -- Fire Breath's damage over time is increased by $s1%. Dream Breath's heal over time is increased by $s1%.
    fan_the_flames                  = {  94923, 444318, 1 }, -- Casting Engulf reignites all active Enkindles, increasing their remaining damage or healing over time by $s1%.
    lifecinders                     = {  94931, 444322, 1 }, -- Renewing Blaze also applies to your target or $s1 nearby injured $Lally:allies; at $s2% value.
    red_hot                         = {  94945, 444081, 1 }, -- Engulf gains $s2 additional charge and deals $s1% increased damage and healing.
    shape_of_flame                  = {  94937, 445074, 1 }, -- Tail Swipe and Wing Buffet scorch enemies and blind them with ash, causing their next attack within $445134d to miss.
    titanic_precision               = {  94920, 445625, 1 }, -- Living Flame and Azure Strike have $s1 extra chance to trigger Essence Burst when they critically strike.
    trailblazer                     = {  94937, 444849, 1 }, -- $?c1[Hover and Deep Breath][Hover, Deep Breath, and Dream Flight] travel $s1% faster, and Hover travels $s1% further.
    traveling_flame                 = {  99857, 444140, 1 }, -- Engulf increases the duration of $?c1[Fire Breath][Fire Breath or Dream Breath] by $s1 sec and causes it to spread to a target within $?c1[$s2][$s3] yds.

    -- Scalecommander
    bombardments                    = {  94936, 434300, 1 }, -- Mass Disintegrate marks your primary target for destruction for the next 6 sec. You and your allies have a chance to trigger a Bombardment when attacking marked targets, dealing 46,562 Volcanic damage split amongst all nearby enemies.
    diverted_power                  = {  94928, 441219, 1 }, -- Bombardments have a chance to generate Essence Burst.
    extended_battle                 = {  94928, 441212, 1 }, -- Essence abilities extend Bombardments by 1 sec.
    hardened_scales                 = {  94933, 441180, 1 }, -- Obsidian Scales reduces damage taken by an additional 10%.
    maneuverability                 = {  94941, 433871, 1 }, -- Deep Breath can now be steered in your desired direction. In addition, Deep Breath burns targets for 100,547 Volcanic damage over 12 sec.
    mass_disintegrate               = {  94939, 436335, 1, "scalecommander" }, -- Empower spells cause your next Disintegrate to strike up to $s1 targets. When striking fewer than $s1 targets, Disintegrate damage is increased by $s2% for each missing target.
    melt_armor                      = {  94921, 441176, 1 }, -- Deep Breath causes enemies to take 20% increased damage from Bombardments and Essence abilities for 12 sec.
    menacing_presence               = {  94933, 441181, 1 }, -- Knocking enemies up or backwards reduces their damage done to you by 15% for 8 sec.
    might_of_the_black_dragonflight = {  94952, 441705, 1 }, -- Black spells deal 20% increased damage.
    nimble_flyer                    = {  94943, 441253, 1 }, -- While Hovering, damage taken from area of effect attacks is reduced by 10%.
    onslaught                       = {  94944, 441245, 1 }, -- Entering combat grants a charge of Burnout, causing your next Living Flame to cast instantly.
    slipstream                      = {  94943, 441257, 1 }, -- Deep Breath resets the cooldown of Hover.
    unrelenting_siege               = {  94934, 441246, 1 }, -- For each second you are in combat, Azure Strike, Living Flame, and Disintegrate deal 1% increased damage, up to 15%.
    wingleader                      = {  94953, 441206, 1 }, -- Bombardments reduce the cooldown of Deep Breath by 1 sec for each target struck, up to 3 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    born_in_flame        = 5612, -- (414937) Casting Ebon Might grants 2 charges of Burnout, reducing the cast time of Living Flame by 100%.
    chrono_loop          = 5564, -- (383005) Trap the enemy in a time loop for 5 sec. Afterwards, they are returned to their previous location and health. Cannot reduce an enemy's health below 20%.
    divide_and_conquer   = 5557, -- (384689) Deep Breath forms curtains of fire, preventing line of sight to enemies outside its walls and burning enemies who walk through them for 88,223 Fire damage. Lasts 6 sec.
    dream_catcher        = 5613, -- (410962) Sleep Walk no longer has a cooldown, but its cast time is increased by 0.2 sec.
    dream_projection     = 5559, -- (377509) Summon a flying projection of yourself that heals allies you pass through for 27,099. Detonating your projection dispels all nearby allies of Magical effects, and heals for 134,138 over 20 sec.
    dreamwalkers_embrace = 5615, -- (415651) Verdant Embrace tethers you to an ally, increasing movement speed by 40% and slowing and siphoning 15,316 life from enemies who come in contact with the tether. The tether lasts up to 10 sec or until you move more than 30 yards away from your ally.
    nullifying_shroud    = 5558, -- (378464) Wreathe yourself in arcane energy, preventing the next 3 full loss of control effects against you. Lasts 30 sec.
    obsidian_mettle      = 5563, -- (378444) While Obsidian Scales is active you gain immunity to interrupt, silence, and pushback effects.
    scouring_flame       = 5561, -- (378438) Fire Breath burns away 1 beneficial Magic effect per empower level from all targets.
    swoop_up             = 5562, -- (370388) Grab an enemy and fly with them to the target location.
    time_stop            = 5619, -- (378441) Freeze an ally's timestream for 5 sec. While frozen in time they are invulnerable, cannot act, and auras do not progress. You may reactivate Time Stop to end this effect early.
    unburdened_flight    = 5560, -- (378437) Hover makes you immune to movement speed reduction effects.
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
            if talent.mass_eruption.enabled then applyBuff( "mass_eruption_stacks" ) end -- ???

            applyDebuff( "target", "fire_breath" )
            applyDebuff( "target", "fire_breath_damage" )

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


spec:RegisterPack( "Devastation", 20240921, [[Hekili:S3xBZTnosc)BX1vJI1eBzjA7KSZJL3ko2ENm1UZmvuUzR7lwIscsIvOi1sszzVLl9B)P7gGKaGaKuV5j1ExD3oo2eSrJg97DdIh68WxFO3y3e2d)QtBNlA)xC60Q977CzBNh6L88c2d9w4o6BUtH)rG7C4)El7r34e3eVWa8zp7h6ogHrC4YOrWZNLKSi(No7SPEjZwoS1OW5Nf7nFPp9gJICNKG)(OZg6ho8SKzSvUrRGH6fCglyQxa7Sr(UXX9NhoEPpl(m3f(4)Rp7XWVXIAnAXIh6nCPNFYNdEyOjm)IZVaqMfSrp8RDU4DVhqiVXJz8bZIh9qpCWN2(VCQtNFA9GEEZ)06blxGWjE9VS(xsFANlHN(rF)WvRhCBK70Wa4)WwpWla(Z)2D5d99N68(twpaEL2xi(5hGx9)waYbtIcNlMh535CymFDgaW)PBe8FikWd989ItIrQjd)V)kT5WcCh6Zg)Wnp0ZDeNSZsyrbEjp3pEzeUZWMViCflQFs4d968qVrppYN1pXfEgaTFf)lrEWR45YbXJS(Sa2Cpe9UQ76bDwp4TRhK46ZcsALc74(XlCdAjM91dE5L1dgUCYKwJZOgTIyZD9cqOaaP17VC9GFC9aG2773FgWKaRUgL8sxZNA9xX0eTCbbQJxpqh)VM(RNlVcMegK0pCs)5Ut9gLVaAst1X1C52K()rCPWmcO97i05OkGcNJlYBbFx7oXGaUbCBdywwgdR3i3GVTEW8W4eyUwSW3Be(YaOdrWt7HTEibyY3cMbNnNzWHOooeXAhzjCATnCeg4JWL)5BXY)8nF5Z5KoVUl)JQIRRCAeoHTC2cQKbslsKUqJijtmUWonRarkb()6nzyz6GM4fX6pmI5MmROcOms8XVsknSiRYhm(eXUu8OWOrGQ2P9zZhYIIZ3O4YZJdHDY8vw)XUZXPpXB03GxstG(EyGRhCdnsvPzqookCbqbsueKxpyu4YGKZ4it5I1k0x78SCjwCfwbPEVjmMrSRGKQRjQezylR1AjCv6YEFkFTDR7ZnjwwPm0fCjWXSjUl9tktmCri)NkmM3Y8DbZmWZ4oS07RWpNSEWZHlbEtKP1Dy4YeoRzVERhCk3aKp8srmFWdVa4HtcbptcxaSAWpxnJHVhbHv0JV9lNE993C6196D61rHPEeMV7z3g(rOCqO)4WvbTIN5MGVaqgbVkJOrzZQRt2wWWW4ycAt8MolPVmF(5xAsQkeCBmMLKt3E0fqs4P4)YFjQdmfJmYi9xje)yjexvhA(qbs5hi886)Q6liTzBy0n12c)db(b7rafA9agIMCpkHTcypnG9e8Nhl7Ak8SHWo4QWiuzfS3rBXOtMZDFc8bh8dDilzfdFD6pl)2Ja5j3GX0wmSFl4gJb9AEtdcJia(PB)c8KjtyJqmkoXBoIrTiQzFE4biA1phUMK6lDVifolaYwFGdSV3yzMkHSN385qOcGobGMLeTKGJIQCX4MZ8t67gnpmY4tDdylFKf5o0Zh2jLDBJl31RTb2dgBrHTXROTXgirjMfmIbJAI3iVKm7vCRlKiHyi9hUmkob43nPGqHv4llxievN7(nMyRlY1BSpZDmkBodm38Co58FTe0z9qpWCeOYCs)PJgZnP)RxIZs6Owc7ppY8LNwyiVZIAMrUGAq(V0hdsHhQIyVkb4o(g65aaG3Rba7wUqkd4GgS)5nkH8mlDYIwgyDUCdjEQpybpl7vJt4AvxeXGOsh6AuVA1kkeR2wjDAb2f6JKzCFvyB4p3h6f3AUxuei2aglNebRHLrSXGjfqcikCvSSeM4163Hav82P1mBUDkdX(Z5HBdXWjNyyrTL3ezM6ucslnQzQPoP9MCnilJiJLRh8dsMhKm7KpaqePnFDv(4(HQMjoG0nYClBK3ygArXB0SmqW11SW1dn77LmtobiG5aq8zcQ1bSgdkHxIogr2n6K)7zkemYUf)CWiRSu9z(XW)UDRlZ4X6ysdP0UrzMrY3x5ZAj7Cow25CE125motz7CLsEUC7LCjTgdz(Gqb8FI7dMxaFAcqn(42CrnmbppFjdK74gqip3w4fm2NzAWXlEEo69CuC)vSH6zej1fcGfkNRz9acf5oZaAQx4Y9(GS7LsHaVBMi(tI3dynh79iWppM)MCpCYOJzdNRRaTndXOHJpU16b)Slhh8csaJNK)nZdh7nXdjbhpAjqBci3J706YNAYLqMcMZOxAg4ekooiGpWrjmbp4JLav6kRLiNFgNL4zHl9rChxLZCdMIleeTKgD(m4fmc8bjgjDOB6JzIFfMIpI(icVb)TDLNdYLEmsaxjP9vE4ydJs)xbyydO4sQ4Fknx1tVCbAWpQLU(MCFydydD2a2qNnHn0XeBOjne5ldDNyQEz02mLjeC(Q)ixYZJc(SSLq1rfQ)LngQQcOrlh(CFiKc)f9JNrCnffIb7dqGWOuyFGVZnkaKz77nsa9cRA2tJ8xoM8tRt7Th9CQb65SXONJc6zX9V6AwjvEulRfL6vGDdp4kRkZsvAz6mLbGVB)8hMNdCm)gVTeFPYgPbeIRBGNH8RlGvg9)4mLbuBSs3Dx7yvhjSs1wzNmolkhuDS4KBvB58mb2Fx25n9C5TxzUA)h95Hijljc)XYxBBuO2CVhA1UqIK1c)KYOzNSuciglywWflzbybxHof1Hun1N(7iozYZTiwLjayCeqJHqTr40hJ6lpQ8lSMReY(gp)iOjymJsakodyhjpistQHyGlxaExqpaZRbvzVW7ArjL5EQQDZrt5yEoWXCrmd4VIzS5W777LfjE8kgyAFri6aYqmJlEjVb9HHf9m5rmzE2d5EJbuAcwUpyc(5uCIWeiIeEMEcOAlbZuyW4yUxkdztPCmGlOHyKRCNoaBK8ei3XKVFBkbowkBJ9(WbJ(27RCuEZ9titNIxawj4(8CL6fmzzm8c9BlPRbujPy4evHWEctxNRF)fEecOBHpBEzrJDdsWu6cbmQlk83q3L6r7a9a7m(4V(XXUlseZ8Vd0ZLyUxkKWQy(W77Mn6SSnHOJURbfEFm5HXjHrZvYJ1Xk1Gmy6s)j2kpfzhvVMhnvtfnnbe(O7uHXCYxeLKYoUo20Ommjhn8bp4bZ4t8DjThj8e(us(V1YFC5f8ZuOyI0slqo3OrUbS(p6nvoLHYRllfdSrXuwFfpbxkCqyRdmGJ7OsKyuPXVTaLN4UAJRbumFcPqafBi5mxrKgt9dh66lc4wi9XFrxStdyWOU7gtzYjNgGjoSp7rk)NHpYMtPtnGsH57uYt5m4PrPKhWJt1cK0gnv3iV8lZXM2ySxmgSY0i0bma9g9Tyn6BHHPsKnrcVqHpLWktj3SSAlXzSv3j6bu9XybeepMchCemNFS3h)9c1XioWDboul5RTQj7JJ(xl9IsTyGq0KmodZofe2dX9hlRGqxfVQwPi3HRh85ipy58fk63u2hP07JCju9aMg5XMW1wd6edIjqKI)ftZBbSus0rM5VArlVimw7ru6Xv20fwnaCQLsbXKsD7KHMIUSaUzjH(LxrG8vVuQ9ZIcm7z5L0qnJ52YeDI3cEmSanLfRTL9vpG0CxpGHpjTyXIAflxNyrq5K52f(Upt7A3tmhZCxGEIfcZq0kpSWZeiV)M6vbodnsZg28dnkZ0tZmRpgR(fIhnnf7Qcn6tK7LY1yh4O7HvKe8yX7Ftgr)jq7zaMwgUVOyMne5QruAW0CA4tp)dXVLttbMqKaZO)j5OfQoMHfvK7e25TJRNuHIjytYgu5knSryl1G5AzLIwq3zyDR7UbEZdJvy5BMUxRvIuu59h4VVHINYt1ybjVcHXByNsR9M()2S2MnlU8Fl6vtcblLS6SJvqpQEd(iTHYInM4dt6anTlF7n8DUG0Ela9rHChH(ltd5PQfCAbnupH6FY0IIQ5hPf1tflHk6gLPi33kFaPzvTgSKNke10WdN7(uFXaE9CtSh5Bc2zgCT)izyCilo4njYe27U5ejl7e2GbpIVl6F5NU1ysbYPfL3TtfdXqVznuw5JzCpLuhtFXFM05B1tb1EV595BTCllgZJqghRK3K1yRF3DuvYR3rZWjAC)HOklj(OoT1f6vhzUGV2g))nAk)F4I62UvAY5YCF6gS5ocsszcg5UWycasPmlEoQckIPgQL7YTeV8JHyZB7BwHvvAfXahariYLIlQjrP8Wiv4ifcIiHkqvLQ6mvEB(QLBoLEprz753Fg9g5IV(wkhoNJ)Kh(1FKrJON0XHcpdyR4fEc35G)8VdaM)lu(rU9lgtgI22Nk7RrooQjtCQH0L2(HbMJYsoIsW5vXxLt7b9ObGckdwztFsbtSg7vkurPm6FPeKmKFLuGsp3nyKhGlCCxsze9qFM7ISfwMIaB9RJvJuDmAW8VFFkpIyAGnFAEW8JHY1)KW0zMh(cQYjz)lERDHJg5AOqi5D)fsMgkCnghsCiSUnNqPzU45lqhf)FcXKlpwa0XkAC8dN6nk78l8vtB44OJIwUiPpM9CXr0adnFKV3cCT2OOn(gO1L4R7604yZPI4ANxErjbeGosgS7(CFArOpvspcNWTb6k8T2YpY1znARw2rQq)HrZuMYX2MlLLAvon3eYAj1KVQG1mJrdDCBIx8mHgQuqlsocLzPsdfGYq6h5cBIyv5LH(EpSoU1Zn9m)KLLz1I80IuT0dv46uCbEAeJfqRfBEb7(VxgHoge59n9CaFpG4djTUteljZDpVOUnLEoE0RkDDcDVyiaDeXaKURlbvimKWivZecTMOhm2AIw0hm9Mxryiw1jjdwNnaRlAxdltIX1m9yMPrAmKsZSeTWj0GKrSFyI8VxhYP5kCQuZoR5WOr1TYmsRmuU2S1DZSDJDCIk5WkDUK7AhTwVKV5nud52vziloGceR8wsj)WwyGIkk6Uj1L5LkL3bgAysHYfJRjn2mTxWqbOrgX31oLmKn3ATRmxnFbN3nLQazsQTugujXQAIHEIdLA4PuL3KTBQhKqL6PTL9yrBuDsAwvW(kcmyYZ5nDyZW4eX28d)B6n6h2QscnyIJma)DrA5fQo3E3CwKl25sFncuitNRTaE6zYCPzC4YH(S0EVsG)NqOo2AwbmHlo0u4oHY1tVEND)ncSuYNhEGTa69B5TNyE1BlRsaIP1z7vm05WOyOZ3zkg6uMIbtiB186owguN6OyWXSIHcD3svkgm2VmFhQyWPoednZDoLvwk7Mi1QJ2o2ml5AW1OMwAEgLdOxvwEKgqHg6RoB0IgPnf3uROjwqZSJPXIi2JifPvh5t7H07Uh4seJWUVhvVKBKNhkRU8DvwyYgkda544BlB50SygQ(8euhmMgFsTnszPd(yMrP0UQLQjnIDPhnssjovXk(RLThX1LtzvM5XFE1qByiULOahtvkTOYFnXMnueWPY(5AlebCQPowPbuLiqzNcGVZfb6yueW4s(1seWqXNlQB9)9O70m(N1wYVoSjFpQPuZ8AsXwjVmNr)pD9nMX)xz2MVd1Uu0tUe60kAiZrQvj8RqmpJ4K6)oVxY49EkEMpGaWuBi1PSeEJSoKHbjCuAMw(2mSJ59zpX79im2W((4APELRT8Y(XdGOrPPv9D5sf2XLxPEARO7aPOMOXZu2a(hIjdi)yYYpb7chmHNXl8Iqrsrk0NZBUHagYxgtTpAYkMlVgRC4dmFjVT7z8EXLE7t8M01866QZBKjRXxqIvX1DpVXrkRttHdxipR73UMYAzAZ4C0iIFH57(eoDYTR2Dbjy7t)fg13C4ch5Mh5gqLkjI5JYt0xRax6KloZlASOJ2gJ5FGox0bHrZXTbSzQ9iQmiqFJFy4y)LO6M3IvKJ6O9pl6J4Z(dQRTXKPGhRA6R(WuMBuZDUBwo3zZANfLAsurDXYQSAE2Atm)XjGp0mTXXG(WHHblJBLSAvN(xSyKUM1skdEZ1gQcSne8dfgzjOOOzxmHDn2imZw30CEALCk5ZiHtPrtuzZ9XBHFSJ8K6xMS8HHFpt4jpJ(IMWzmWHLnI7U5(tu6VVeEld2AV0pt1FJRY9lCkQ5(A5tw(wR9pGxL6jEH2aslZPrylZ0JAWAEsebc8THbsDtrAcf)i1vbRh8hu)9OrXj6521arQYwMBIizVLSruttJujzyQAPevKHSY0Fg4J4)w7tPHctws2HTuRQCcOLJX51lYOIcBfbkT(uLZRi1sC2ZGBf82YDtqdbCuLRBvOVe0EEbmxYvddGQPor3k10itGEYFZw9MMktXEu9PSrzVEi(rYiAmz81CZ5qMBXMrbe881ygeoaQaefI)7vixL2wwwvJzWBgtyT8Pbs659h57cU7zQlUvl5lvb80uGqo11cCDG(gl5gbgZHL8qF3)nP4g0cfrw1X8KTmjM(alGA6V9lT2zVi(ZQNylnES8qovprzf03vsFVwpLDvQRQgIwBKYXsTDUN6v3YpZdL2I8fA56)pEZ9hV5U6c6ELjP6g6U02Y5F6I9Og1sp3FZz4bpHFAsPaOg)mFZngpru8ysdePP)V9PBXwoL(UueXIx6NW3n5FkoOT9GqKTlyk95LWtKIbyXiXBHwDWV9kLypoNFyfGQgBgOcBqnSA8x)pltFZS5lNxg5dTm1BHMSRMLldRG)0QC6a3538j1yd7Rssn7193vu16s4SfaX1BnPZwNdP2PDMoDGeFox9whUYnhsOioL1MhkbVtWI5svSN8ssdKWbdKlUgnCqz0wZXCifwXPLfustI(uWtxPwdS8ZiWFUiSLwYZ05bihL30J1al4B0hognhydLEI27kxEmLMMfFrPhYJcs7p7y4DYrMjUbgoeO8rvOjosBIOMfxugpW3PRlzo)cKhda7p1d(HTKWuT4BwBTkoAVzhvgr8(82XgmSrF76lkNk3F6P88BrZIxueQ0((32Hi(NDXCCYT6kQaVSpC4PfIAwkuR0kGTL(e3ThtHFkdQ5JPCkttT8zRswHoY1nsquZAAPSWblsTL8U3kpRmRO(GuIq9DzEIvYYPkgBeqQwbRmNBVtDyLKrToYTkKy)YlOF(NMbbRM9VkN25kooBzx5xB1JQIhspRuBZNL11YFga0k6qHZ7q644NHgt6gwqhLh0VxyrlCADcqOdtxl8wsKRYDD2NgxSSa4VJfHu)e(GUc48vflrg3sQR0e9UgpWpD5iqdZ91NtPNVGQoVC6N1c6evicr5QUD4hPJssxZd7LZtrvZIkdJL4W0lxxHZvN5t0GLdlZTi)GOKE3HejyxhhzARlXOp9GuqwzMuWe8hacv0YggVpMfFrdUMD6z5)QOgwi5ET8xfiV5y9MPp52dxMKesFg(2MZIZ2C0y(pWdEJ1d9Hn7UB9xkKmx72A1ae(Al8f7hvB6uKEl848VCcCDts9MT74XXPjWH)rLk9ZgIxYBs7xCr2bCNsS5PfPIJZiZ(NVTMhQBJQPKCzqAZhrm(gp6hGqnxUlfHbp)uFF2u3rQ5rej1Lairl(wbqO0M7ypyOVBSwQKfZn2CPJ9yNYsmWoD2RkzHLVjy)BILcSksRpQymSLKorJh8RTiMI8ZmNwQtpb7FG0KbKNVuEga(S0x9MAWjj4I5QlYFvW8RARAYEInAjypK7uPw6XPqNWLbM4xtvdwgYd9xMp1AKvP)O5WEQUeBxMQNwxdakCtBfuyqgJYxAdIAjk(2xvDf1FlIUGd6HFKcJtptj0DWsK3uknLQNprPyo5hKfGKeghhopRNJYkxM(hhov8lHgb9bvsCJKbHU2BLBeAFmwC2D4wZfg4Fdl(nOswQjxgN2BqUltcfNGh(3b44wR)L)UhwqA8kl7tHbW0qp(nP74jYNU93WxUMFyk3amOJ78uZQGSsP41aSXY0xt4E4W49aKDoyq(8xBiVd7FR)fdmSXjBgdRf0sZMLgIzXIwnxY5Ml1bBb7O6q8cByRw8ffWxlXF8Ad)lnd)CBmAaUy(mQje3b2koCFNz4k3smAG1u3YutOU3OVwGVs9O1LEnvR6AcxTAyRbzlv4(1e2V3mSLBbdnaBQ7mQju162eD6S5ErPMWEhX4pS3L7SaXS61PlCOxhVAcVDMZ1cC3lCxwG9EtA(VS331SaXTExZc82BuGoT3ZiChloLT9a0IjZ0cZPZZQvjV6co1IUPbuZvKRUGwQoCAW1qf6Qlq1IVwdWwQ8rbGBX0GwUO0PgMZuvDb(oiDzdKhuIXUGVwm2ykbrAaVSCiv3Pzh8d2ki3hUT3XIE99dBNgWdxW4hgTyE(2FJ5uX2O8zPHTkX0TRt7gQz246UoPO(EEUmov5R8dTXchBPiyFSV5yjMBPe1QbydPW91bOwc7CplvBBA2bPARGCFiv7yXsLsAIFJU1FdjzUUaUy2J1v8Bn9YfMclr5QLi13O7RHX0SMdCJjqrCjB8M9rwu2ZSC7FoUdddNr6A2L65MrzlOttCGG5FcCeQVfx)Az4z(Hg24GuniT7tq61F0waA(zw(5YW88HSFb(oG1WZIfFnvldZvh2(Fs2HvaD0rld3thW(eW7a(I1LQm0v889iy3CKTQRZvdtunEfvdbwMCN6iSAzq77jWgHRgG2MaRXHSFb(oG1LjOADy7)jzhwbMfAnmG9jG3b81OyBXNVhb7MJS1q0wFIQXRuU3lzQIk8PoXGUhtJ5Gc(dgG)tcVle6UTpLlnoUm4)d)GP2Zn9PDB)YlL98F4hkd2DB3mDjULi3oHBvHAzu2cHqLjgv9wM5XOWrSVb)bdW)jH3vZj7uGzXa83BCYgGDzCY1d52jCRkulJYwis9mLpLC7rBqnu5JwHlP0P06LqT55SSHx)jv97uL5zQWyuaFHKDNX5VjKXQgD9NY6tgRC41FsRGmAEmkGVqkxL3L0V5QnVpzyu1FkSEXxBEUkB4QbHvOUGY0Tkxy2g1gmh1FLv5WvNvBXxUT68p0WVoqgBh9wUbp3F8I4YGUTXv3vqDNh0Cr)Ta(1og4YdYEFmdwtpH98tu9(BnCUEVd)6a56TVAFC1Dfu35z74F2GmQUL8pBWmux(NcUgEK1ajS5x2lVy3JTYDzZMiBZF84oTU8TwejGNAycXBF)MnV(4Yd3X2MS(m2PYzSJygtP)VI0TZE1PBNDaOB5SKLKKf)hnADN)NvzSTbLoMHshZqXsJhShl2N12piTe9AqoV09Bia51hudAQ3yo1fu7wpezPXa2(fSfaUnlylGAlxWuDbNe67hUIorVUGycEi3y53FjzF9A4hQd(LWoDYkthh9LACc)lNu(Ohpgh8y3e3HUXSFA9VW)OLe5LyPGKUHy0i7sPiffjF3Aj6x9tjXERFtS1QE7J2n5vRr5LoPvAG0W1HUomT2o77u5Zlh2BFX(TPgC3502Fky)(VLFT1sU7akU)7YxlI(7QQQd35UQJLorz)06Oh6J1JTjqPjb1aUXRw3ca2IwR8B8xnOw8QaUUG8GHRBHwaBGs)Ye2mpC2J3uWVp4JTD(v4hzxnyQDX7wayw0DL(fmqxAq7AgvhCowvZS1DaOrhReHqSNo5SBo3J9WLYIBtCcOZaRHGjZhYbe41aSy8IPVNbqQ94diUEqbELGT(jNQwjbB3NMsZbMDWVDjj8adE7aEN9TPgnJGn2eJd5ac8Aa2sfgl84diUEqbELGT(vAOwcJ7(0uQWODWxT0snQO0(g82b8olmwJ(Pyd0zFqbEna7EPcX1aR3ODVdm4Td4diZXEHqBVHjQK9OA9F7xGxdWwnjPgn5rnW6nYm(bg82b8oZ7DGj027YKkzpQwV3(f41aSvtsQH4ynW6nsX0bg82b8oZ7DGj0fsiWoPA6Gc8Aa2Qjj1qCSgy9gPy6adE7aEN59oyeAJjMzcoGDpLmXJcJgndt6QXcaQ)4ANMM9k03)FUTkfU7mwV(x(mTxHa9dQf)e3qEOhSpnlm6HE98M)Ph6bbgnXZp7tJxCRSJx5B7EwApfCc(rvSRGHjTDloHUjP6MZPvSLzE5fdpvC8Hm(ShZpCogFoDmym(eS(SYpWRIJaY6FP(lyhJlyt9ywogu88sz8zgxW6N7hJprDbx9zEz9V8FHFPyhrFolxnZJUmn5VnNfBHRxu63YY8lOZtORZGjm(fIXCVGL4fza9nYUt(Vla0grv59NYjHl6gZs8MiOUD4)SpZpM1TDRlpj7k9SB1h8ctnI0U1U6)qjGUB7MBY61zNxVfApFtT61EA9Aa006fyIUloXdv0htx)WzB9dOfY6bdFM(mdVaWESZm4xGqcyX)qQs)jX7b8xJ9W79)X83KEw6mknCCLJFWIPpjZ44bLzd(zxooKj)HFjTh7nXdzxpwCfwHFNw706YNAYzZNY)iVZV6xXXLFFzJpwcuPRmyI42annlXZ43zs43qzUzp4xCJvgD(m4fmkI5gJKo0q6yM4xHP4Ju7RGFoMflQ85ys6NJzxjrw(3Z5WO0)f1mlihwQmCknh16xFU00lN(cA3l5aaOP31Ap7RnoTlH7najDmJKLEkf00vwdK00fm)gGKsxt(c8S9M86o72R3Pp7Pr(lhZmTrQ3X(ABmw7X(nbbCSGagpYaAe99ccKk1PRX1rwJBhj9ThOglTS(X1sIP1A2ttEAuZEmTSwZ1sjQ0MCt(1vw7MwNTi(9qu)dWovXNKUHiXG5)O)1YceWVtg2(IBW3i3AexhF0fLh9vZ3f7Cq6lWDnwDYxzzPw5B1(hjy1NCOJMT)q8sc97G0qa3ee2bkW0nd23ilOcSjwmWLlG5LEa(Dih7BXpgExlQjfVpkCoy4anLXI53pFxeZgH3UHS54vAH33yc7PXRyGPTfHObyQLi9sEdAdNUv0bWtMN8qBUXaknbVkLHj4NtXjPBTc(n947sViSJ5wPhYM6HT6oUGgY4x7aU4LQrC9ShPClo6gYor850P7fixsed4t2ZuXEFDZrmq3CkE9bj8QAOGYu4hYuq1MF)fEc2KmzvVa823OpHXGkq(vwF)2zYOx3Mw8)n0rGEeTThVTObMHS(IE9GFhq0LadSzes9BC(jEt6MfKPElwBgcz9pS07M93AC8rknzXlVK(7sn2RfTfYFB(ryFKoWb7fYWUrriJbctb8q3pQlqNJ4BYCpPO73hxK91DiDpHHSm49Q1PiBDm50i4eb7r62yH4ycxWcyCwm89iiSIE8TF50RV)MtVUxVtVokuJIblhy2H)fUqi1Os(DVCbqMY2117cTLlE5LcFh4A(Yl4LzFdL7t0Ro)snPbqQeWmgYxXDvNlzG3CQGGDggWV6JqhVxfgXVu44KduhXC3N8MVCokaNSI(u7Z9ox6Thno)ctkkxiduQ4nf0Hqa8tOegBYeYxywAWdTKPqQchAxVR6chs0V0L)F94JZES5lrRt)qZR)R5dYWTyamcm(M)l8oEaL(GaDecOGGe3CWNfsIXIBhLzSNFdXd9ORNpNUdsO0IwIirWmFTkKTZK(rEc(6wvC3c)YrgxdkpOiFKDAT0fPJKuSPpMyPcz59hC2FrTrKZuj2wyqVWgy(Dus2o4hAiUI3GNoXBKxY1D704iA9x4UFJSvVCHqQDUBMrn8kHXN5og3RM5UyXZYR7)1sW(7j4jMjCYe86zSBh5hlIeq(pPFdJO4FzS8iJwguCGOvl8(Tyuc48cqB1fLpVsieNiuJ9XF7o1u59)B9GFBbkrYJ1d3MZVwFq5nYeORiu3P(Hdr2yssvyyK)IWdNeXqE9BYvfdioGrACrNOCruXxrMejZ)Sxk3jW5kSv6(rTpZLxjrteybDjqPURHZS5RqQRENGLj9QJQbElCkyXUgtVsJJttjNTRBSCMATHORl(QUxWZhsP3Au6RhfBMeUiFnsr71JO8QlN3JYGrQPr1Jdb39aqIKFV0aYlucwszqK0GNDtzonYJnH7Q0tuFVkB2NpXMfiMmucpY5eAuo3H0PI4LxmFjPRp9s6nKMrnTpfvtvamYQMxp4R4f1gErzJgmbLgrHl8CPKAsS6yIuwIw5ZDVCb4tbrOOBvgqozbQWHUiTx5HxixeiVVGeL6TwSn)boUGmXBp)hnl9O6Hf4zGnJdCgv(9A09eZv6Tf2R5vb)MWoL59yo1rCRYPqUmNoZuj(SGb1JMi3z0SJarZghR4s11D)WlVO5KvBz6yHRK)V)iLCMS)miLfVm8ntpve9v9CtIuF7nCYxqQB80LPiQ0L(ltd5zAoKFD)oXpCv2vjBRkuICKbrqDproNRMN0YJXiW1cGr5ooKfh8Me559UBorsPkz8ddngFx049NUDlSZAWniYE1vgEq2LV9E1mmxddIlLFLBNh1N2Y6LxQ6MWRPrdgzsJoVN2fOl8WIxVNC(d8QzDvyqs6oYi3ff2(LEjRK6TX9aHNfg(CEFvN25cjkpNRo53P7N2l(6BPOpph)j35S)i7m4qpbVcG1ViApfJnj0N)luyQGOH2sgV)BnTupw3H0lYypYp9pGSCzBlIlV9F8clRq9a1Zyp0pIn5VVkRzZMs50tkyL6UiTTPaHx4ukdx2ktspeELaY3AexsEanN7U1a8AYZBYpj0iL5HG4G5CY68BOCpXOXnlYfpEm5OmLWThAiXHHbfuEPKyetBPPerXSj0ZNFp)jPK3qiWx1nDvFP4nnCA7rGqpt)EHSj)dAFH7pqlHXvqnBhIs))eIHxnonxdkY4IRK3juAo791ns2MU(AHFQEp32DFEn3Eco7P3mVDnDX8AWyZ2mnWgDDhSnPhd80zCOOH0jEXZeAusdqjnUMnKNm1EGakn04iZtKP6L1iVoO37H1UREE7qxAKsZOc)PGjuNNTHb7)egDpmfdPBG7jgrb5RVs9vTiODnhepH(WeGjPaRYaMKrkCdFVrIm2fMgYHCgYzyYbuDm6eHltGJviFDrkUU18oV1OQ1IobMQgOtR3FPC9kkW3MzvUJ8Wm5vzdDRmhFEk2O0MuyvNmJMnBwmlOVRHzRf1MU5uh6MZBDmh4LDkNtR6s40iX1gZpVoyU1qgZnZQq9TVG6EElNAUK0w71EfDHf5h5avvfE4rPhjctpulu9Z4RqzPOjdfPnj1ZFfriuF6EwuOapB3ozUcP3dFnoQCFQR3YWPiFqxWAG1f2wZP206cPEi65kv0rLl0k2U9SH7k6EHGBCtVSHZHozxcLauV0HloaTkYjMySKvFKgjySgn2LwRwShHaFOulGligWl87qggM1r5Zsmwzn0BeVe2CUfZVnd7TcF2t8mh6boMb2tHq0TfzC5XWHUv2WIJjVJwl)dXFbwjORCNGPkdn1hVWlctqTWbV58SJeWY7U4KvmxE9Puwp8QWsVDjPf(8Cp95ogLXSCUwcJ1ix75SpRb9ToFMy9py(UpHKh5C5Exqcw((VW7mB6IS8em9tbuqjrmF0rqQYMUu7FoZlASiDVWpxgqfojimAoUxK1Ufax1X34hgo2Fj6ZYBluoSZ(dQRbWgQdR7cQ7h4dDJAUZ5e7CNTlPyCYBgLH0WxAGpxifyK5ciE1fqWRXqOqdddwg3kz1Qo9VyXOCdQfYiqt5yNnnPFOrvvT8Qp8YlfNtR5GaMrtjE7ChZ1m2jp)38E3GsADEM2YIIf1sZZ5aPNMVJGdlBe3DZ9NOKc8eEw1BPTNumf41m7KvrlRGqcMwQIuxg4By0LvE6B(6SimVF9OsWXtXhqkUnmqoluIqS(iL1J1d(d6RJJgTrprGzULSPz(tkLSs5(RPCRgOrdWy6nOVpZ0PHIHL5aU8LhBE(D0U5xLlnH4JUbSNwrYL625YYZxbLtztXCuzso4UpOYnQMEeTNjHtcT8fE5M5efTvVcPxTYmc8ViW0youRAV0vvC)r(UGbkrn2ZtaK0LzCEs4uV6KZYjRYnFCgz69IfAjzd1OKQKTmzal5tFAEUiZ9Ta7jut64gX)u8HxYAKsfqGiASOxlcxMethDbul0TFP1oBAzll3cTzSXfUklhmAT2ILYQG5n1uvvkx(1OaPv5XsKSnQ9DRQOJsXClMsK)tJdOelA7doGnZxGTClZqr4(NUyTUOCbE)nNHLkN3vNKJKJFMtPJXUGG7GEa5haeY0NUfRhdD(iIyXl9twN)D2KVhfeI8abu8tt8eHUaOL0gTgLFfGmNaUR0TmD8kzbuq9mL8vBHBksd(BZ2CK7P3F0KgBk2hlG70YTHTztsLKdZU3CqPivVWnJuxVPl98UTH4H4YXD4sXoedxCgBd5lgp5TI(qM9KxsQNyoOpR6s169D6gqFm5PwMdzNAZnUM)OGUwmR4kiMs2MFvrmnezZRdC6f1o4Sry(VLpoqN3JyK1T60s1mK0ds7G4S)KtlZoJQEbUxiVXDqpon0gYCCtE3xB508GxxBbBDwnyeTqwwJeicKGx0rqzA4YOrSAX)MZuTH1NRitgHP)SlM0aU67qYCRILzSbjOwZafbxbB2kh224c9n(wMMP0nC12ERXXgn(wEqgTHDxXIhIvw4sRo1iplIQiv(MREx3M5h97Ytbz(8xgtXvDZ1SwAKmVRrvb12XPzJJmF7KxEYOmTTCSyvyS7GpQk5GCxoRQbIvARYfu3rGEyaOHW9GjWAnep(KiO5LlNlPN3m6yIOWF3PDXMManm48vT1p1abOETn5QCFdVU455aTqZRuiXvLvhBT6xtLpw4m3vD7WrOsIyBZkECvqZQ3N0k9wCJrKs37q0gi)iElsXeqkXeys(vMRrBaWma8BeobJ3hZJK7eY58So)I)RI0xIuaLdKe)BvbDYmgUmjbjRBcb(7IgfyBG5MSXAVRaQz3mxurox6pVzMbRYBKSuE7DDlOkkVdv5sRybad4XK5oECCAKC8dwwAFn7L8g8pkfzI7uIFlnFL8zg56(8TfykQwbybbAWEJejhrmKC3Tdi8NAhkm45N67ZM6o6zWoGXH)U2nmmy9mavd8Ref0))7MRNEsOyy4Fw8crIe9TbCd8Mh4Kh4obrEgjHes4pjEIp7UUTU13wxLhIOX4T3J3SBTRRR9x)DEoOjPji1d9X5Tb3gcxA(BaBJItfC9mh(sCa(W)SemPeHhtsMh6bv(aVIrmDdU7vmHq2)Fr0zSjC1fUobC8gF7XIiv)r9RhmoGHqdiz8XgEmm2qItW0NthJfRp4g(KjQ)b5HekNa1HDt2kyRz)8MWMX5q2xVVYxNbQYj(sS1AYkuzZUWVWnGAIF7rQ(v(dWiF92A4SHaeahcl45vgXC4nTEqy(Q70y9o9BgujhO)GkSEb1hP04W(393M1sifGLe2JCl9CQrp0Bh4yZv4zBTA9r7ae3c8SuQBb4TcSxLC96O7BbhQdAgv0tUstdFGzRwnXzBOcpl3CWctjxixE5VNv0bhSqvnwfQlU)e6PtFakO0lHlS7G6ORijgX75TbPo2kZYMd7wVzp2cwQsgcCTgp872DEDpxhMw53Rwbx6N1yYaQP(2BzUL2Z)4aq5hHurGHecWgQhaDcZsHNyg6Y0T8i9Fqzecwwc4XXnm)P)(4Ua)VDeCc3TfZaQMap64JHfdohKctwPj0PBvPpDRk1fXQkNa9(XSQufSQYfbPfAnZlvswv6mRQceFrrRkgs04kzvPLMqwh6tElKieWli4DZIvTGpEKXISq2b(VJOzZ6t0NSC4ZcZrNRr3TKw5E)xpAl2GHlhhhrR(M4AjZZAByzdCBgrHuGKpSaHtWzw8DzSVJO5Wyinoua3uDVQZn0SlgJFUBRTBmpR0zkIISVRqkebYOHjvJXess)Q7kjB0Re0o9PMxFQfynLtwFQLDJeFNG(KND1UY6tvQ(KrKVQ6Z)d7i5eSaXwDz0B)52h(FyNhNGDH1B)c73MT383Sp)d]] )