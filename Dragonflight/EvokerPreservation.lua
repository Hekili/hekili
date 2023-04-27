-- EvokerPreservation.lua
-- DF Season 1 Jan 2023

if UnitClassBase( "player" ) ~= "EVOKER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 1468 )

spec:RegisterResource( Enum.PowerType.Essence )
spec:RegisterResource( Enum.PowerType.Mana--[[, {
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
}]] --TODO: this breaks and causes bugs because it isn't referencing mana well from State.lua, but it wouldn't be discovered in Devastation testing because Devastation doesn't have the Energy Loop talent.
)

-- Talents
spec:RegisterTalents( {
    -- Evoker
    aerial_mastery       = { 68659, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame        = { 68671, 369990, 1 }, -- Casting Emerald Blossom or Verdant Embrace reduces the cast time of your next Living Flame by 40%.
    attuned_to_the_dream = { 68672, 376930, 2 }, -- Your healing done and healing received are increased by 2%.
    blast_furnace        = { 68667, 375510, 2 }, -- Fire Breath's damage over time lasts 0 sec longer.
    bountiful_bloom      = { 68572, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    cauterizing_flame    = { 68673, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 8,939 upon removing any effect.
    clobbering_sweep     = { 68570, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 45 sec.
    draconic_legacy      = { 68685, 376166, 2 }, -- Your Stamina is increased by 3%.
    enkindled            = { 68677, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    extended_flight      = { 68679, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance           = { 68573, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    fire_within          = { 68654, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    foci_of_life         = { 68654, 375574, 1 }, -- Renewing Blaze restores you more quickly, causing damage you take to be healed back over 4 sec.
    forger_of_mountains  = { 68569, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    heavy_wingbeats      = { 68570, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 45 sec.
    inherent_resistance  = { 68670, 375544, 2 }, -- Magic damage taken reduced by 2%.
    innate_magic         = { 68683, 375520, 2 }, -- Essence regenerates 5% faster.
    instinctive_arcana   = { 68666, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    leaping_flames       = { 68662, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth          = { 68652, 375561, 2 }, -- Green spells restore 5% more health.
    natural_convergence  = { 68682, 369913, 1 }, -- Disintegrate channels 20% faster.
    obsidian_bulwark     = { 68674, 375406, 1 }, -- Obsidian Scales has an additional charge.
    obsidian_scales      = { 68675, 363916, 1 }, -- Reinforce your scales, reducing damage taken by 30%. Lasts 12 sec.
    oppressing_roar      = { 68668, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    overawe              = { 68660, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 20 sec for each Enrage dispelled.
    panacea              = { 68680, 387761, 1 }, -- Emerald Blossom instantly heals you for 6,640 when cast.
    permeating_chill     = { 68676, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by 50% for 3 sec.
    protracted_talons    = { 68661, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    quell                = { 68665, 351338, 1 }, -- Interrupt an enemy's spellcasting and prevent any spell from that school of magic from being cast for 4 sec.
    recall               = { 68684, 371806, 1 }, -- You may reactivate Deep Breath within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic   = { 68651, 387787, 1 }, -- Source of Magic forms a bond with your ally, causing 15% of their healing to also heal you while you are below 50% health.
    renewing_blaze       = { 68653, 374348, 1 }, -- The flames of life surround you for 8 sec. While this effect is active, 100% of damage you take is healed back over 8 sec.
    rescue               = { 68658, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    scarlet_adaptation   = { 68687, 372469, 1 }, -- Store 20% of your effective healing, up to 3,883. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    sleep_walk           = { 68571, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    source_of_magic      = { 68669, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 30 min. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    tailwind             = { 68678, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    terror_of_the_skies  = { 68649, 371032, 1 }, -- Deep Breath stuns enemies for 3 sec.
    time_spiral          = { 68650, 374968, 1 }, -- Bend time, allowing you and your allies within 40 yds to cast their major movement ability once in the next 10 sec, even if it is on cooldown.
    tip_the_scales       = { 68686, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    twin_guardian        = { 68656, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5 sec.
    unravel              = { 68663, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 14,687 Spellfrost damage to absorb shields.
    verdant_embrace      = { 68688, 360995, 1 }, -- Fly to an ally and heal them for 8,223, or heal yourself for the same amount.
    walloping_blow       = { 68657, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr               = { 68655, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8 sec.

    -- Preservation
    call_of_ysera        = { 68599, 373834, 1 }, -- Verdant Embrace increases the healing of your next Dream Breath by 40%, or your next Living Flame by 100%.
    cycle_of_life        = { 68602, 371832, 1 }, -- Every 3 Emerald Blossoms leaves behind a tiny sprout which gathers 15% of your healing over 10 sec. The sprout then heals allies within 30 yds, divided evenly among targets.
    delay_harm           = { 68584, 376207, 1 }, -- Time Dilation delays 70% of damage taken.
    dream_breath         = { 68606, 355936, 1 }, -- Inhale, gathering the power of the Dream. Release to exhale, healing 5 injured allies in a 30 yd cone in front of you for 14,590. I: Heals 2,651 instantly and 11,938 over 16 sec. II: Heals 5,636 instantly and 8,954 over 12 sec. III: Heals 8,621 instantly and 5,969 over 8 sec.
    dream_flight         = { 68580, 359816, 1 }, -- Take in a deep breath and fly to the targeted location, healing all allies in your path for 6,374 immediately, and 4,483 over 15 sec. Removes all root effects. You are immune to movement impairing and loss of control effects while flying.
    dreamwalker          = { 68576, 377082, 1 }, -- You are able to move while communing with the Dream.
    echo                 = { 68607, 364343, 1 }, -- Wrap an ally with temporal energy, healing them for 3,187 and causing your next non-Echo healing spell to cast an additional time on that ally at 105% of normal healing.
    emerald_communion    = { 68577, 370960, 1 }, -- Commune with the Emerald Dream, restoring 20% health and 2% mana every 0.9 sec for 4.4 sec. Overhealing is transferred to an injured ally within 40 yds. Castable while stunned, disoriented, incapacitated, or silenced.
    empath               = { 68603, 376138, 1 }, -- Spiritbloom increases your Essence regeneration rate by 100% for 8 sec.
    energy_loop          = { 68588, 372233, 1 }, -- Disintegrate deals 20% more damage and generates 1,200 mana over its duration.
    erasure              = { 68600, 376210, 1 }, -- Rewind has 2 charges, but its healing is reduced by 50%.
    essence_attunement   = { 68610, 375722, 1 }, -- Essence Burst stacks 2 times.
    essence_burst        = { 68609, 369297, 1 }, -- Living Flame has a 20% chance to make your next Essence ability free. Stacks 2 times.
    exhilarating_burst   = { 68578, 377100, 2 }, -- Each time you gain Essence Burst, your critical healing is increased by 15% for 10 sec.
    expunge              = { 68689, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    field_of_dreams      = { 68612, 370062, 1 }, -- Gain a 30% chance for one of your Fluttering Seedlings to grow into a new Emerald Blossom.
    flow_state           = { 68591, 385696, 2 }, -- Empower spells cause time to flow 10% faster for you, increasing movement speed, cooldown recharge rate, and cast speed. Lasts 10 sec.
    fluttering_seedlings = { 68611, 359793, 2 }, -- Emerald Blossom sends out 2 flying seedlings when it bursts, healing allies up to 40 yds away for 1,721.
    font_of_magic        = { 68579, 375783, 1 }, -- Your empower spells' maximum level is increased by 1.
    golden_hour          = { 68595, 378196, 1 }, -- Reversion instantly heals the target for 15% of damage taken in the last 5 sec.
    grace_period         = { 68601, 376239, 2 }, -- Your healing is increased by 5% on targets with your Reversion.
    just_in_time         = { 68584, 376204, 1 }, -- Time Dilation's cooldown is reduced by 2 sec each time you cast an Essence ability.
    landslide            = { 68681, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 30 sec. Damage may cancel the effect.
    lifebind             = { 68613, 373270, 1 }, -- Verdant Embrace temporarily bonds your life with an ally, causing your healing on either partner to heal the other for 40% of the amount. Lasts 5 sec.
    lifeforce_mender     = { 68598, 376179, 2 }, -- Living Flame and Fire Breath deal additional damage and healing equal to 0% of your maximum health.
    lifegivers_flame     = { 68597, 371426, 2 }, -- Fire Breath heals a nearby injured ally for 80% of damage done to up to 5 targets.
    nozdormus_teachings  = { 68590, 376237, 1 }, -- Temporal Anomaly reduces the cooldowns of your empower spells by 5 sec.
    ouroboros            = { 68583, 381921, 1 }, -- Casting Echo grants one stack of Ouroboros, increasing the healing of your next Emerald Blossom by 30%, stacking up to 5 times.
    power_nexus          = { 68581, 369908, 1 }, -- Increases your maximum Essence to 6.
    punctuality          = { 68589, 371270, 1 }, -- Reversion has 2 charges.
    renewing_breath      = { 68582, 371257, 2 }, -- Dream Breath healing is increased by 15%.
    resonating_sphere    = { 68590, 376236, 1 }, -- Temporal Anomaly applies Echo at 30% effectiveness to the first 4 allies it passes through.
    reversion            = { 68608, 366155, 1 }, -- Repair an ally's injuries, healing them for 6,134 over 12 sec. When Reversion critically heals, its duration is extended by 1.8 sec.
    rewind               = { 68593, 363534, 1 }, -- Rewind 50% of damage taken in the last 5 seconds by all allies within 40 yds. Always heals for at least 4,821. Healing increased by 100% when not in a raid.
    rush_of_vitality     = { 68576, 377086, 1 }, -- Emerald Communion increases your maximum health by 20% for 15 sec.
    spark_of_insight     = { 68614, 377099, 1 }, -- Consuming a full Temporal Compression grants you Essence Burst.
    spiritbloom          = { 68604, 367226, 1 }, -- Divert spiritual energy, healing an ally for 13,506. Splits to injured allies within 30 yds when empowered. I: Heals one ally. II: Heals a second ally. III: Heals a third ally.
    spiritual_clarity    = { 68603, 376150, 1 }, -- Spiritbloom's cooldown is reduced by 10 sec.
    stasis               = { 68585, 370537, 1 }, -- Causes your next 3 helpful spells to be duplicated and stored in a time lock. You may reactivate Stasis any time within 30 sec to quickly unleash their magic.
    temporal_anomaly     = { 68592, 373861, 1 }, -- Send forward a vortex of temporal energy, absorbing 3,576 damage on you and any allies in its path. Absorption is reduced beyond 5 targets.
    temporal_artificer   = { 68600, 381922, 1 }, -- Rewind's cooldown is reduced by 60 sec.
    temporal_compression = { 68605, 362874, 1 }, -- Each cast of a Bronze spell causes your next empower spell to reach maximum level in 5% less time, stacking up to 4 times.
    time_dilation        = { 68594, 357170, 1 }, -- Stretch time around an ally for the next 8 sec, causing 50% of damage they would take to instead be dealt over 8 sec.
    time_lord            = { 68596, 372527, 2 }, -- Echo replicates 50% more healing.
    time_of_need         = { 68586, 368412, 1 }, -- When you or an ally fall below 20% health, a version of yourself enters your timeline and heals them for 8,223. Your alternate self continues healing for 8 sec before returning to their timeline. May only occur once every 60 sec.
    timeless_magic       = { 68587, 376240, 2 }, -- Reversion, Time Dilation, and Echo last 15% longer.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chrono_loop       = 5455,
    dream_projection  = 5454,
    nullifying_shroud = 5468,
    obsidian_mettle   = 5459,
    precognition      = 5502,
    scouring_flame    = 5461,
    swoop_up          = 5465,
    time_stop         = 5463,
    unburdened_flight = 5470,
} )


-- Auras
spec:RegisterAuras( {
    call_of_ysera = {
        id = 373835,
        duration = 15,
        max_stack = 1
    },
    dream_breath = { -- TODO: This is the empowerment cast.
        id = 355936,
        duration = 2.5,
        max_stack = 1
    },
    dream_breath_hot = {
        id = 355941,
        duration = function ()
            return 16 - (4 * (empowerment_level - 1))
        end,
        tick_time = 2,
        max_stack = 1
    },
    dream_breath_hot_echo = { -- This is the version applied when the target has your Echo on it.
        id = 376788,
        duration = function ()
            return 16 - (4 * (empowerment_level - 1))
        end,
        tick_time = 2,
        max_stack = 1
    },
    dream_projection = { -- TODO: PvP talent summon/pet?
        id = 377509,
        duration = 5,
        max_stack = 1
    },
    dreamwalker = {
        id = 377082,
    },
    emerald_blossom = { -- TODO: Check Aura (https://wowhead.com/beta/spell=355913)
        id = 355913,
        duration = 2,
        max_stack = 1
    },
    essence_burst = { -- This is the Preservation version of the talent.
        id = 369299,
        duration = 15,
        max_stack = function() return talent.essence_attunement.enabled and 2 or 1 end,
    },
    fire_breath = {
        id = 357209,
        duration = function ()
            return 4 * empowerment_level
        end,
        -- TODO: damage = function () return 0.322 * stat.spell_power * action.fire_breath.spell_targets * ( talent.heat_wave.enabled and 1.2 or 1 ) * ( debuff.shattering_star.up and 1.2 or 1 ) end,
        max_stack = 1,
    },
    fly_with_me = {
        id = 370665,
        duration = 1,
        max_stack = 1
    },
    hover = {
        id = 358267,
        duration = function () return talent.extended_flight.enabled and 8 or 6 end,
        tick_time = 1,
        max_stack = 1
    },
    lifebind = {
        id = 373267,
        duration = 5,
        max_stack = 1
    },
    mastery_lifebinder = {
        id = 363510,
    },
    nullifying_shroud = {
        id = 378464,
        duration = 30,
        max_stack = 3
    },
    ouroboros = {
        id = 387350,
        duration = 3600,
        max_stack = 5
    },
    reversion = {
        id = 366155,
        duration = 12,
        tick_time = 2,
        max_stack = 1
    },
    reversion_echo = {  -- This is the version applied when the target has your Echo on it.
        id = 367364,
        duration = 12,
        tick_timer = 2,
        max_stack = 1
    },
    rewind = {
        id = 363534,
        duration = 4,
        tick_time = 1,
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
    stasis_ready = {
        id = 370562,
        duration = 30,
        max_stack = 1
    },
    temporal_anomaly = { -- TODO: Creates an absorb vortex effect.
        id = 373861,
        duration = 6,
        tick_time = 2,
        max_stack = 1
    },
    temporal_compression = {
        id = 362877,
        duration = 15,
        max_stack = 4
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
    youre_coming_with_me = {
        id = 370388,
        duration = 1,
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

    empowerment.active = false
end )

spec:RegisterGear( "tier29", 200381, 200383, 200378, 200380, 200382 )
spec:RegisterAuras( {
    time_bender = {
        id = 394544,
        duration = 6,
        max_stack = 1
    },
    lifespark = {
        id = 394552,
        duration = 15,
        max_stack = 2
    }
} )

spec:RegisterGear( "tier30", 202491, 202489, 202488, 202487, 202486 )
-- 2 pieces (Preservation) : Spiritbloom applies a heal over time effect for 40% of healing done over 8 sec. Dream Breath's healing is increased by 15%.
spec:RegisterAura( "spiritbloom", {
    id = 409895,
    duration = 8,
    tick_time = 2,
    max_stack = 1
} )
-- 4 pieces (Preservation) : After casting 3 empower spells, gain Essence Burst immediately and another 3 sec later.
spec:RegisterAura( "essence_rush", {
    id = 409899,
    duration = 3,
    max_stack = 1
} )


spec:RegisterHook( "reset_precast", function()
    max_empower = talent.font_of_magic.enabled and 4 or 3

    if essence.current < essence.max and lastEssenceTick > 0 then
        local partial = min( 0.95, ( query_time - lastEssenceTick ) * essence.regen )
        gain( partial, "essence" )
        if Hekili.ActiveDebug then Hekili:Debug( "Essence increased to %.2f from passive regen.", partial ) end
    end
end )


spec:RegisterStateTable( "evoker", setmetatable( {},{
    __index = function( t, k )
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
        return stages[ args.empower_to or max_empower ] * haste
    end, state )
end

-- Abilities
spec:RegisterAbilities( {
    cauterizing_flame = {
        id = 374251,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        healing = function () return 3.50 * stat.spell_power end,

        toggle = "interrupts",

        usable = function()
            return buff.dispellable_poison.up or buff.dispellable_curse.up or buff.dispellable_disease.up, "requires dispellable effect" --add dispellable_bleed later?
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_curse" )
            removeBuff( "dispellable_disease" )
            -- removeBuff( "dispellable_bleed" )
            health.current = min( health.max, health.current + action.cauterizing_flame.healing )
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,
    },
    chrono_loop = {
        id = 383005,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
        end,
    },
    disintegrate = {
        id = 356995,
        cast = function() return 3 * ( talent.natural_convergence.enabled and 0.8 or 1 ) end,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.essence_burst.up and 0 or 3 end,
        spendType = "essence",

        startsCombat = true,

        damage = function () return 2.28 * stat.spell_power * ( talent.energy_loop.enabled and 1.2 or 1 ) end,

        min_range = 0,
        max_range = 25,

        start = function ()
            removeStack( "essence_burst" )
            if talent.energy_loop.enabled then gain( 0.0277 * mana.max, "mana" ) end
        end,
    },
    dream_breath = {
        id = function() return talent.font_of_magic.enabled and 382614 or 355936 end,
        known = 355936,
        cast = empowered_cast_time,
        empowered = true,
        cooldown = 30,
        gcd = "off",
        icd = 0.5,

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "dream_breath" )
            applyBuff( "dream_breath_hot" )
            removeBuff( "call_of_ysera" )
            removeBuff( "temporal_compression" )
            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
            end
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,

        copy = { 382614, 355936 }
    },
    dream_flight = {
        id = 359816,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    dream_projection = {
        id = 377509,
        cast = 0.5,
        cooldown = 90,
        gcd = "spell",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    echo = {
        id = 364343,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.essence_burst.up and 0 or 2 end,
        spendType = "essence",

        startsCombat = false,

        handler = function ()
            removeStack( "essence_burst" )
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )

            if talent.ouroboros.enabled then addStack( "ouroboros" ) end
            if talent.temporal_compression.enabled then addStack("temporal_compression") end
        end,
    },
    emerald_blossom = {
        id = 355913,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.essence_burst.up and 0 or 3 end,
        spendType = "essence",

        startsCombat = false,

        healing = function () return 2.5 * stat.spell_power end,    -- TODO: Make a fake aura so we know if an Emerald Blossom is pending for a target already?
                                                                    -- TODO: Factor in Fluttering Seedlings?  ( 0.9 * stat.spell_power * targets impacted )

        -- o Cycle of Life (?); every 3 Emerald Blossoms leaves a tiny sprout which gathers 10% of healing over 15 seconds, then heals allies w/in 25 yards.
        --    - Count shows on action button.

        handler = function ()
            removeStack( "essence_burst" )
            removeBuff( "ouroboros" )
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,
    },
    emerald_communion = {
        id = 370960,
        cast = 0,
        cooldown = 180,
        gcd = "spell",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    fire_breath = {
        id = function() return talent.font_of_magic.enabled and 382266 or 357208 end,
        known = 357208,
        cast = empowered_cast_time,
        empowered = true,
        cooldown = 30,
        gcd = "off",
        icd = 0.5,

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,

        spell_targets = function () return active_enemies end,
        damage = function () return 1.334 * stat.spell_power * ( 1 + 0.1 * talent.blast_furnace.rank ) end,

        handler = function()
            applyDebuff( "target", "fire_breath" )

            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
            else
                removeBuff( "temporal_compression" )
            end

            if talent.leaping_flames.enabled then applyBuff( "leaping_flames", nil, empowerment_level ) end
        end,

        copy = { 382266, 357208 }
    },
    living_flame = {
        id = 361469,
        cast = 2,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        damage = function () return 1.61 * stat.spell_power end,
        healing = function () return 2.75 * stat.spell_power * ( 1 + 0.03 * talent.enkindled.rank ) end,
        spell_targets = function () return buff.leaping_flames.up and min( active_enemies, 1 + buff.leaping_flames.stack ) end,

        handler = function ()
            removeBuff( "ancient_flame" )
            removeBuff( "leaping_flames" )
            removeBuff( "scarlet_adaptation" )
            removeBuff( "call_of_ysera" )
            removeStack( "lifespark" )
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
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

        toggle = "interrupts",

        usable = function()
            return buff.dispellable_poison.up or buff.dispellable_magic.up, "requires dispellable effect"
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_magic" )
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,
    },
    nullifying_shroud = {
        id = 378464,
        cast = 1.5,
        cooldown = 90,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    },
    renewing_blaze = {
        id = 374348,
        cast = 0,
        cooldown = function () return talent.fire_within.enabled and 60 or 90 end,
        gcd = "off",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "renewing_blaze" )
            applyBuff( "renewing_blaze_heal" )
        end,
    },
    reversion = {
        id = 366155,
        cast = 0,
        charges = function() return talent.punctuality.enabled and 2 or 1 end,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "reversion" )
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,
    },
    rewind = {
        id = 363534,
        cast = 0,
        charges = function() return talent.erasure.enabled and 2 or nil end,
        cooldown = function() return talent.temporal_artificer.enabled and 180 or 240 end,
        recharge = function() return talent.temporal_artificer.enabled and 180 or 240 end,
        gcd = "spell",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
        end,
    },
    spiritbloom = {
        id = function() return talent.font_of_magic.enabled and 382731 or 367226 end,
        known = 367226,
        cast = empowered_cast_time,
        empowered = true,
        cooldown = 30,
        gcd = "off",
        icd = 0.5,

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            if set_bonus.tier30_2pc > 0 then applyBuff( "spiritbloom" ) end
            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
            else
                removeBuff( "temporal_compression" )
            end
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,

        copy = { 382731, 367226 }
    },
    stasis = {
        id = function () return buff.stasis_ready.up and 370564 or 370537 end,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = function () return buff.stasis_ready.up and 0 or 0.04 end,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        usable = function () return buff.stasis_ready.up or buff.stasis.stack < 1, "Stasis not ready" end,

        handler = function ()
            if buff.stasis_ready.up then
                setCooldown( "stasis", 90 )
                removeBuff( "stasis_ready" )
            else
                if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
                addStack( "stasis", 3 )
            end
        end,

        copy = { 370564, 370537, "stasis" }
    },
    temporal_anomaly = {
        id = 373861,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",

        spend = 0.08,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
            if talent.resonating_sphere.enabled then applyBuff( "echo" ) end
            if talent.nozdormus_teachings.enabled then
                reduceCooldown( "dream_breath", 5 )
                reduceCooldown( "fire_breath", 5 )
                reduceCooldown( "spiritbloom", 5 )
            end
            if buff.stasis.stack == 1 then applyBuff( "stasis_ready" ) end
            removeStack( "stasis" )
        end,
    },
    time_dilation = {
        id = 357170,
        cast = 0,
        cooldown = 60,
        gcd = "off",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
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

        spend = 0.03,
        spendType = "mana",

        talent = "verdant_embrace",
        startsCombat = false,

        handler = function ()
            if talent.lifebind.enabled then applyBuff( "lifebind" ) end
            if talent.call_of_ysera.enabled then applyBuff( "call_of_ysera" ) end
        end,
    },
} )



spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )

local deep_breath = GetSpellInfo( 357210 ) or "Deep Breath"

spec:RegisterSetting( "use_deep_breath", true, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( 357210 ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended, which will force your character to select a destination and move.  By default, %s requires your Cooldowns "
        .. "toggle to be active.\n\n"
        .. "If unchecked, |W%s|w will never be recommended, which may result in lost DPS if left unused for an extended period of time.",
        Hekili:GetSpellLinkWithTexture( 357210 ), deep_breath, deep_breath ),
    width = "full",
} )

local unravel = GetSpellInfo( 368432 ) or "Unravel"

spec:RegisterSetting( "use_unravel", false, {
    name = strformat( "Use %s", Hekili:GetSpellLinkWithTexture( 368432 ) ),
    type = "toggle",
    desc = strformat( "If checked, %s may be recommended if your target has an absorb shield applied.  By default, %s also requires your Interrupts toggle to be active.",
        Hekili:GetSpellLinkWithTexture( 368432 ), unravel ),
    width = "full",
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = true,
    nameplateRange = 30,

    damage = true,
    damageDots = true,
    damageExpiration = 8,
    damageOnScreen = true,
    damageRange = 30,

    potion = "potion_of_spectral_intellect",

    package = "Preservation",
} )


spec:RegisterPack( "Preservation", 20230205, [[Hekili:LwvtVjomq0Fl9svRAvwYhTL9q3d7PTCaTsPNDSjzcXQH4S2ou1kK)TVJDOGjb6UOkeOW438EJh)ghsi5zsAbtdK5rtIINen5UGWhcNgFhjv)wlqsBz5VWwIp0WwH)(BjOa5AMMlASl(wTGvyjrj6K5ias6IoET(PgYIJZCmjL1PRess6VGx41CsAfVOa6tau5K0NR4kd1(LzOBladvuI)p3kSHwZvAC5sH0q7zjaRgPOKxJ1qpkvqReYfRwW03843wudkfVzzMOmtxbzlKIM3bZmZSTOrm)PdQR9dKJvki5VBZRSgBa(l21izRHdWxaqlYmW0v(HBfUQ2pxfKX1WkLFWsUe2M9TWQwXRGmtlEm8wE5JL8Lv6mjSIXBu)im5MCMsNP5hwsNGHOXmm9SiiEmbrNfbjJj4OPxjwdsl2vI1yt)GElhp(0Wsj6PSiw0vwgGNPqtoQyNuPd6AV8Ql6ZCZg36o(cgj51(exZxV781s8)fd(eWEVd30kTK)cSV2V0l9cXR40c(KYo2SBGGK(kt2GyvK0NWMLudfgA0aBEGzgoE1c5K5Hj3pLK6I6gCHswxTgFCUBqUpnsQZhtsHgg66li)KOrn9bmYxpaCSp4T(8bqs8H457ha7oFy9ZbdqC)bA9XCXaqpybTpYo8E2nCxj52DfZg2ZPzO)Wqdtm0Bm0DNFiB7CN2UhQX0VQgt)mjISs89VQerFMeXwjcN8v14eSN4ypCa77jQ31VxpNZ3Lt0jZ5OZWg6Lg6vg6fg62BbOB2yOJNgpSAn0R9mKExw4QH4twdNPm71W)EdNgj)JEJBJn6wHpOZ)weKoT99zBF91Ob8J)YSdNz(4d5Vd]] )
