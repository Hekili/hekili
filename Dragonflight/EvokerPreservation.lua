-- EvokerPreservation.lua
-- September 2022

if UnitClassBase( "player" ) ~= "EVOKER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 1468 )

spec:RegisterResource( Enum.PowerType.Essence )
spec:RegisterResource( Enum.PowerType.Mana, {
    disintegrate = {
        channel = "disintegrate",
        talent = "energy_loop",

        last = function ()
            local app = state.buff.casting.applied
            local t = state.query_time

            return app + floor( ( t - app ) / class.auras.disintegrate.tick_time ) * class.auras.disintegrate.tick_time
        end,

        interval = function () return class.auras.disintegrate.tick_time end,
        value = function () return 0.024 * mana.max end, -- TODO: Check if should be modmax.
    }
} )

-- Talents
spec:RegisterTalents( {
    aerial_mastery       = { 68659, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame        = { 68671, 369990, 1 }, -- Healing yourself with Living Flame reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream = { 68672, 376930, 2 }, -- Your healing done and healing received are increased by 2%.
    blast_furnace        = { 68667, 375510, 2 }, -- Fire Breath's damage over time lasts 0 sec longer.
    bountiful_bloom      = { 68572, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    call_of_ysera        = { 68599, 373834, 1 }, -- Verdant Embrace increases the healing of your next Dream Breath by 40%, or your next Living Flame by 100%.
    cauterizing_flame    = { 68673, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 2,404 upon removing any effect.
    clobbering_sweep     = { 68570, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 45 sec.
    cycle_of_life        = { 68602, 371832, 1 }, -- Every 3 Emerald Blossoms leaves behind a tiny sprout which gathers 15% of your healing over 10 sec. The sprout then heals allies within 30 yards, divided evenly among targets.
    delay_harm           = { 68584, 376207, 1 }, -- Time Dilation delays 70% of damage taken.
    draconic_legacy      = { 68685, 376166, 2 }, -- Your Stamina is increased by 2%.
    dream_breath         = { 68606, 355936, 1 }, -- Inhale, gathering the power of the Dream. Release to exhale, healing 5 injured allies in a 30 yd cone in front of you. I: Heals for 1,905 and incurs a 35 sec cooldown. II: Heals for 2,143 and incurs a 30 sec cooldown. III: Heals for 2,381 and incurs a 25 sec cooldown.
    dream_flight         = { 68580, 359816, 1 }, -- Take in a deep breath and fly to the targeted location, healing all allies in your path for 1,800 immediately, and 1,122 over 15 sec. You are immune to movement impairing and loss of control effects while flying.
    dreamwalker          = { 68576, 377082, 1 }, -- You are able to move while communing with the Dream.
    echo                 = { 68607, 364343, 1 }, -- Wrap an ally with temporal energy, healing them for 900 and causing your next non-Echo healing spell to cast an additional time on that ally at 105% of normal healing.
    emerald_communion    = { 68577, 370960, 1 }, -- Commune with the Emerald Dream, restoring 20% health and 2% mana every 1.0 sec for 4.9 sec. Overhealing is transferred to a nearby injured ally. Castable while stunned, feared, or silenced.
    empath               = { 68603, 376138, 1 }, -- Spiritbloom increases your Essence regeneration rate by 100% for 8 sec.
    energy_loop          = { 68588, 372233, 1 }, -- Disintegrate deals 20% more damage and generates 960 mana over its duration.
    enkindled            = { 68677, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    erasure              = { 68600, 376210, 1 }, -- Rewind has 2 charges, but its healing is reduced by 50%.
    essence_attunement   = { 68610, 375722, 1 }, -- Essence Burst stacks 2 times.
    essence_burst        = { 68609, 369297, 1 }, -- Living Flame has a 20% chance to make your next Essence ability free. Stacks 2 times.
    exhilarating_burst   = { 68578, 377100, 2 }, -- Each time you gain Essence Burst, your critical healing is increased by 15% for 10 sec.
    expunge              = { 68689, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    extended_flight      = { 68679, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance           = { 68573, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    field_of_dreams      = { 68612, 370062, 1 }, -- Gain a 30% chance for one of your Fluttering Seedlings to grow into a new Emerald Blossom.
    fire_within          = { 68654, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    flow_state           = { 68591, 385696, 2 }, -- Empower spells cause time to flow 10% faster for you for 10 sec.
    fluttering_seedlings = { 68611, 359793, 2 }, -- Emerald Blossom sends out 2 flying seedlings when it bursts, healing allies up to 30 yds away for 405.
    foci_of_life         = { 68654, 375574, 1 }, -- While Renewing Blaze's initial effect is active, you receive 20% increased healing from all sources.
    font_of_magic        = { 68579, 375783, 1 }, -- Your empower spells' maximum level is increased by 1.
    forger_of_mountains  = { 68569, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    golden_hour          = { 68595, 378196, 1 }, -- Reversion instantly heals the target for 15% of damage taken in the last 5 sec.
    grace_period         = { 68601, 376239, 2 }, -- Your healing is increased by 5% on targets with your Reversion.
    heavy_wingbeats      = { 68570, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 45 sec.
    innate_magic         = { 68683, 375520, 2 }, -- Essence regenerates 5% faster.
    instinctive_arcana   = { 68666, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    just_in_time         = { 68584, 376204, 1 }, -- Time Dilation's cooldown is reduced by 2 sec each time you cast an Essence ability.
    landslide            = { 68681, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 30 sec. Damage may cancel the effect.
    leaping_flames       = { 68662, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lifebind             = { 68613, 373270, 1 }, -- Verdant Embrace temporarily bonds your life with an ally, causing healing either of you receive to also heal the bonded partner for 40% of the amount. Lasts 5 sec.
    lifeforce_mender     = { 68598, 376179, 2 }, -- Living Flame and Fire Breath deal additional damage and healing equal to 0% of your maximum health.
    lifegivers_flame     = { 68597, 371426, 2 }, -- Fire Breath heals a nearby injured ally for 80% of damage done to up to 5 targets.
    lush_growth          = { 68652, 375561, 2 }, -- Green spells restore 5% more health.
    natural_convergence  = { 68682, 369913, 1 }, -- Disintegrate channels 20% faster.
    nozdormus_teachings  = { 68590, 376237, 1 }, -- Temporal Anomaly shields 1 additional target each time it pulses.
    obsidian_bulwark     = { 68674, 375406, 1 }, -- Obsidian Scales's cooldown is reduced by 60 sec.
    obsidian_scales      = { 68675, 363916, 1 }, -- Reinforce your scales, increasing your armor by 200% and reducing magic damage taken by 20%. Lasts 12 sec.
    oppressing_roar      = { 68668, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    ouroboros            = { 68583, 381921, 1 }, -- For each ally healed by Emerald Blossom or Dream Breath gain a stack of Ouroboros, increasing your next Echo's direct healing by 15% and decreasing its cast time by 5%, stacking up to 20 times.
    overawe              = { 68660, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 20 sec for each Enrage dispelled.
    panacea              = { 68680, 387761, 1 }, -- Emerald Blossom instantly heals you for 937 when cast.
    permeating_chill     = { 68676, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by 50% for 3 sec.
    power_nexus          = { 68581, 369908, 1 }, -- Increases your maximum Essence to 6.
    protracted_talons    = { 68661, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    punctuality          = { 68589, 371270, 1 }, -- Reversion has 2 charges.
    quell                = { 68665, 351338, 1 }, -- Interrupt an enemy's spellcasting and preventing any spell from that school of magic from being cast for 4 sec.
    recall               = { 68684, 371806, 1 }, -- You may reactivate Dream Flight and Deep Breath within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic   = { 68651, 387787, 1 }, -- Source of Magic forms a bond with your ally, causing 10% of their healing to also heal you while you are below 50% health.
    renewing_blaze       = { 68653, 374348, 1 }, -- The flames of life surround you for 8 sec. While this effect is active, 100% of damage you take is healed back over 14 sec.
    renewing_breath      = { 68582, 371257, 2 }, -- Allies healed by Dream Breath are healed for an additional 10% over 8 sec.
    rescue               = { 68658, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    resonating_sphere    = { 68590, 376236, 1 }, -- Temporal Anomaly applies Echo at 30% effectiveness to allies it heals.
    reversion            = { 68608, 366155, 1 }, -- Repair an ally's injuries, healing them for 1,535 over 12 sec. When Reversion critically heals, its duration is extended by 2.0 sec.
    rewind               = { 68593, 363534, 1 }, -- Rewind 50% of damage taken in the last 5 seconds by all allies within 40 yds. Always heals for at least 1,098. Healing increased by 100% when not in a raid.
    roar_of_exhilaration = { 68664, 375507, 1 }, -- Successfully interrupting an enemy with Quell generates 1 Essence.
    rush_of_vitality     = { 68576, 377086, 1 }, -- Emerald Communion increases your maximum health by 20% for 15 sec.
    scarlet_adaptation   = { 68687, 372469, 1 }, -- Store 20% of your effective healing, up to 1,106. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk           = { 68571, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic      = { 68669, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 30 min. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    spark_of_insight     = { 68614, 377099, 1 }, -- Consuming a full Temporal Compression grants you Essence Burst.
    spiritbloom          = { 68604, 367226, 1 }, -- Divert spiritual energy, healing an ally for 3,815. Splits to injured allies within 30 yards when empowered. I: Heals one ally. II: Heals a second ally. III: Heals a third ally.
    spiritual_clarity    = { 68603, 376150, 1 }, -- Spiritbloom's cooldown is reduced by 10 sec.
    stasis               = { 68585, 370537, 1 }, -- Causes your next 3 helpful spells to be duplicated and stored in a time lock. You may reactivate Stasis any time within 30 sec to quickly unleash their magic.
    tailwind             = { 68678, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    tempered_scales      = { 68670, 375544, 2 }, -- Magic damage taken reduced by 2%.
    temporal_anomaly     = { 68592, 373861, 1 }, -- Send forward a vortex of temporal energy, absorbing 1,202 damage on 2 nearby allies every 2.0 sec. Lasts 5.9 sec.
    temporal_artificer   = { 68600, 381922, 1 }, -- Rewind's cooldown is reduced by 60 sec.
    temporal_compression = { 68605, 362874, 1 }, -- Each cast of a Bronze spell causes your next empower spell to reach maximum level in 5% less time, stacking up to 4 times.
    terror_of_the_skies  = { 68649, 371032, 1 }, -- Deep Breath stuns enemies for 3 sec.
    time_dilation        = { 68594, 357170, 1 }, -- Stretch time around an ally for the next 8 sec, causing 50% of damage they would take to instead be dealt over 8 sec.
    time_lord            = { 68596, 372527, 2 }, -- Echo replicates 50% more healing.
    time_of_need         = { 68586, 368412, 1 }, -- When you or an ally fall below 20% health, a version of yourself enters your timeline and heals them for 2,322. Your alternate self continues healing for 8 sec before returning to their timeline. May only occur once every 90 sec.
    time_spiral          = { 68650, 374968, 1 }, -- Bend time, allowing you and your allies to cast their major movement ability once in the next 10 sec, even if it is on cooldown.
    timeless_magic       = { 68587, 376240, 2 }, -- Reversion, Time Dilation, and Echo last 15% longer.
    tip_the_scales       = { 68686, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian        = { 68656, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5 sec.
    unravel              = { 68663, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 3,950 Spellfrost damage to absorb shields.
    verdant_embrace      = { 68688, 360995, 1 }, -- Fly to an ally and heal them for 2,322.
    walloping_blow       = { 68657, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr               = { 68655, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8 sec.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chrono_loop        = 5455, -- 383005
    divide_and_conquer = 5472, -- 384689
    dream_projection   = 5454, -- 377509
    nullifying_shroud  = 5468, -- 378464
    obsidian_mettle    = 5459, -- 378444
    precognition       = 5502, -- 377360
    scouring_flame     = 5461, -- 378438
    swoop_up           = 5465, -- 370388
    time_stop          = 5463, -- 378441
    unburdened_flight  = 5470, -- 378437
} )


-- Auras
spec:RegisterAuras( {
    chrono_loop = {
        id = 383005,
        duration = 5,
        max_stack = 1
    },
    deep_breath = {
        id = 357210,
        duration = 6,
        max_stack = 1
    },
    disintegrate = {
        id = 356995,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    dream_breath = { -- TODO: This is the empowerment cast.
        id = 355936,
        duration = 2.5,
        max_stack = 1
    },
    dream_flight = {
        id = 359816,
        duration = 6,
        max_stack = 1
    },
    dream_projection = { -- TODO: PvP talent summon/pet?
        id = 377509,
        duration = 5,
        max_stack = 1
    },
    echo = {
        id = 364343,
        duration = 15,
        max_stack = 1
    },
    emerald_blossom = { -- TODO: Check Aura (https://wowhead.com/beta/spell=355913)
        id = 355913,
        duration = 2,
        max_stack = 1
    },
    emerald_communion = {
        id = 370960,
        duration = 5,
        tick_time = 1,
        max_stack = 1
    },
    fire_breath = { -- TODO: This is the empowerment cast.
        id = 357208,
        duration = 2.5,
        max_stack = 1
    },
    fly_with_me = {
        id = 370665,
        duration = 1,
        max_stack = 1
    },
    fury_of_the_aspects = {
        id = 390386,
        duration = 40,
        max_stack = 1
    },
    hover = {
        id = 358267,
        duration = 6,
        tick_time = 1,
        max_stack = 1
    },
    nullifying_shroud = {
        id = 378464,
        duration = 30,
        max_stack = 3
    },
    obsidian_scales = {
        id = 363916,
        duration = 12,
        max_stack = 1
    },
    oppressing_roar = {
        id = 372048,
        duration = 10,
        max_stack = 1
    },
    permeating_chill = {
        id = 370898,
        duration = 3,
        max_stack = 1
    },
    renewing_blaze = {
        id = 374348,
        duration = 8,
        max_stack = 1
    },
    reversion = {
        id = 366155,
        duration = 12,
        tick_time = 2,
        max_stack = 1
    },
    rewind = {
        id = 363534,
        duration = 4,
        tick_time = 1,
        max_stack = 1
    },
    sleep_walk = {
        id = 360806,
        duration = 20,
        max_stack = 1
    },
    source_of_magic = {
        id = 369459,
        duration = 1800,
        max_stack = 1
    },
    spiritbloom = { -- TODO: This is the empowerment channel.
        id = 367226,
        duration = 2.5,
        max_stack = 1
    },
    stasis = {
        id = 370537,
        duration = 3600,
        max_stack = 3
    },
    temporal_anomaly = { -- TODO: Creates an absorb vortex effect.
        id = 373861,
        duration = 6,
        tick_time = 2,
        max_stack = 1
    },
    terror_of_the_skies = {
        id = 372245,
        duration = 3,
        max_stack = 1
    },
    time_dilation = {
        id = 357170,
        duration = 8,
        max_stack = 1
    },
    time_stop = {
        id = 378441,
        duration = 4,
        max_stack = 1
    },
    tip_the_scales = {
        id = 370553,
        duration = 3600,
        max_stack = 1
    },
    youre_coming_with_me = {
        id = 370388,
        duration = 1,
        max_stack = 1
    },
    zephyr = {
        id = 374227,
        duration = 8,
        max_stack = 1
    },
} )


-- Abilities
spec:RegisterAbilities( {
    azure_strike = {
        id = 362969,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 4622447,

        handler = function ()
        end,
    },


    blessing_of_the_bronze = {
        id = 364342,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 4622448,

        nobuff = "blessing_of_the_bronze",

        handler = function ()
            applyBuff( "blessing_of_the_bronze" )
            applyBuff( "blessing_of_the_bronze_evoker")
        end,
    },


    cauterizing_flame = {
        id = 374251,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "cauterizing_flame",
        startsCombat = false,
        texture = 4630446,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    chrono_loop = {
        id = 383005,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        pvptalent = "chrono_loop",
        startsCombat = false,
        texture = 4630470,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    deep_breath = {
        id = 357210,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        startsCombat = false,
        texture = 4622450,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    disintegrate = {
        id = 356995,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 3,
        spendType = "essence",

        startsCombat = true,
        texture = 4622451,

        handler = function ()
        end,
    },


    dream_breath = {
        id = 355936,
        cast = 0,
        cooldown = 25,
        gcd = "off",

        spend = 0.04,
        spendType = "mana",

        talent = "dream_breath",
        startsCombat = false,
        texture = 4622454,

        handler = function ()
        end,
    },


    dream_flight = {
        id = 359816,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        talent = "dream_flight",
        startsCombat = false,
        texture = 4622455,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    dream_projection = {
        id = 377509,
        cast = 0.5,
        cooldown = 90,
        gcd = "spell",

        pvptalent = "dream_projection",
        startsCombat = false,
        texture = 4622475,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    echo = {
        id = 364343,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",

        spend = 2,
        spendType = "essence",

        talent = "echo",
        startsCombat = false,
        texture = 4622456,

        handler = function ()
        end,
    },


    emerald_blossom = {
        id = 355913,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 3,
        spendType = "essence",

        startsCombat = false,
        texture = 4622457,

        handler = function ()
        end,
    },


    emerald_communion = {
        id = 370960,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        talent = "emerald_communion",
        startsCombat = false,
        texture = 4630447,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    expunge = {
        id = 365585,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "expunge",
        startsCombat = false,
        texture = 4630445,

        handler = function ()
        end,
    },


    fire_breath = {
        id = 357208,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,
        texture = 4622458,

        handler = function ()
        end,
    },


    fury_of_the_aspects = {
        id = 390386,
        cast = 0,
        cooldown = 300,
        gcd = "off",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,
        texture = 4723908,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    hover = {
        id = 358267,
        cast = 0,
        charges = function() return 1 + talent.aerial_mastery.rank end,
        cooldown = 35,
        recharge = 35,
        gcd = "off",

        startsCombat = false,
        texture = 4622463,

        handler = function ()
        end,
    },


    landslide = {
        id = 358385,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "landslide",
        startsCombat = false,
        texture = 1016245,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    living_flame = {
        id = 361469,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 4622464,

        handler = function ()
        end,
    },


    mass_return = {
        id = 361178,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 4622473,

        handler = function ()
        end,
    },


    naturalize = {
        id = 360823,
        cast = 0,
        cooldown = 8,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,
        texture = 4630445,

        handler = function ()
        end,
    },


    nullifying_shroud = {
        id = 378464,
        cast = 1.5,
        cooldown = 90,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "nullifying_shroud",
        startsCombat = false,
        texture = 135752,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    obsidian_scales = {
        id = 363916,
        cast = 0,
        cooldown = 150,
        gcd = "off",

        talent = "obsidian_scales",
        startsCombat = false,
        texture = 1394891,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    oppressing_roar = {
        id = 372048,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "oppressing_roar",
        startsCombat = false,
        texture = 4622466,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    quell = {
        id = 351338,
        cast = 0,
        cooldown = 40,
        gcd = "off",

        talent = "quell",
        startsCombat = false,
        texture = 4622469,

        handler = function ()
        end,
    },


    renewing_blaze = {
        id = 374348,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        talent = "renewing_blaze",
        startsCombat = false,
        texture = 4630463,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    rescue = {
        id = 370665,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "rescue",
        startsCombat = false,
        texture = 4622460,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    action_return = {
        id = 361227,
        cast = 10,
        cooldown = 0,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,
        texture = 4622472,

        handler = function ()
        end,

        copy = "return"
    },


    reversion = {
        id = 366155,
        cast = 0,
        charges = 2,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "reversion",
        startsCombat = false,
        texture = 4630467,

        handler = function ()
        end,
    },


    rewind = {
        id = 363534,
        cast = 0,
        charges = 1,
        cooldown = 240,
        recharge = 240,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        talent = "rewind",
        startsCombat = false,
        texture = 4622474,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    sleep_walk = {
        id = 360806,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        talent = "sleep_walk",
        startsCombat = true,
        texture = 1396974,

        handler = function ()
        end,
    },


    source_of_magic = {
        id = 369459,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        talent = "source_of_magic",
        startsCombat = false,
        texture = 4630412,

        handler = function ()
        end,
    },


    spiritbloom = {
        id = 367226,
        cast = 0,
        cooldown = 30,
        gcd = "off",

        spend = 0.04,
        spendType = "mana",

        talent = "spiritbloom",
        startsCombat = false,
        texture = 4622476,

        handler = function ()
        end,
    },


    stasis = {
        id = 370537,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = 0.04,
        spendType = "mana",

        talent = "stasis",
        startsCombat = true,
        texture = 4630476,

        toggle = "cooldowns",

        handler = function ()
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
        end,
    },


    temporal_anomaly = {
        id = 373861,
        cast = 1.5,
        cooldown = 6,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        talent = "temporal_anomaly",
        startsCombat = false,
        texture = 4630480,

        handler = function ()
        end,
    },


    time_dilation = {
        id = 357170,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0.02,
        spendType = "mana",

        talent = "time_dilation",
        startsCombat = false,
        texture = 4622478,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    time_spiral = {
        id = 374968,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "time_spiral",
        startsCombat = false,
        texture = 4622479,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    time_stop = {
        id = 378441,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        pvptalent = "time_stop",
        startsCombat = false,
        texture = 4631367,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    tip_the_scales = {
        id = 370553,
        cast = 0,
        cooldown = 120,
        gcd = "off",

        talent = "tip_the_scales",
        startsCombat = false,
        texture = 4622480,

        toggle = "cooldowns",

        handler = function ()
        end,
    },


    unravel = {
        id = 368432,
        cast = 0,
        cooldown = 9,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        talent = "unravel",
        startsCombat = false,
        texture = 4630499,

        handler = function ()
        end,
    },


    verdant_embrace = {
        id = 360995,
        cast = 0,
        cooldown = 24,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "verdant_embrace",
        startsCombat = false,
        texture = 4622471,

        handler = function ()
        end,
    },


    zephyr = {
        id = 374227,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "zephyr",
        startsCombat = false,
        texture = 4630449,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
} )

spec:RegisterPriority( "Preservation", 20220922,
-- Notes
[[

]],
-- Priority
[[

]] )