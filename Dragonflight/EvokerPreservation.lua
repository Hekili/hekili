-- EvokerPreservation.lua
-- DF Season 1 Jan 2023

if UnitClassBase( "player" ) ~= "EVOKER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

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
    aerial_mastery       = { 68659, 365933, 1 },
    ancient_flame        = { 68671, 369990, 1 },
    attuned_to_the_dream = { 68672, 376930, 2 },
    blast_furnace        = { 68667, 375510, 2 },
    bountiful_bloom      = { 68572, 370886, 1 },
    cauterizing_flame    = { 68673, 374251, 1 },
    clobbering_sweep     = { 68570, 375443, 1 },
    draconic_legacy      = { 68685, 376166, 2 },
    enkindled            = { 68677, 375554, 2 },
    extended_flight      = { 68679, 375517, 2 },
    exuberance           = { 68573, 375542, 1 },
    fire_within          = { 68654, 375577, 1 },
    foci_of_life         = { 68654, 375574, 1 },
    forger_of_mountains  = { 68569, 375528, 1 },
    heavy_wingbeats      = { 68570, 368838, 1 },
    inherent_resistance  = { 68670, 375544, 2 },
    innate_magic         = { 68683, 375520, 2 },
    instinctive_arcana   = { 68666, 376164, 2 },
    leaping_flames       = { 68662, 369939, 1 },
    lush_growth          = { 68652, 375561, 2 },
    natural_convergence  = { 68682, 369913, 1 },
    obsidian_bulwark     = { 68674, 375406, 1 },
    obsidian_scales      = { 68675, 363916, 1 },
    oppressing_roar      = { 68668, 372048, 1 },
    overawe              = { 68660, 374346, 1 },
    panacea              = { 68680, 387761, 1 },
    permeating_chill     = { 68676, 370897, 1 },
    protracted_talons    = { 68661, 369909, 1 },
    quell                = { 68665, 351338, 1 },
    recall               = { 68684, 371806, 1 },
    regenerative_magic   = { 68651, 387787, 1 },
    renewing_blaze       = { 68653, 374348, 1 },
    rescue               = { 68658, 370665, 1 },
    roar_of_exhilaration = { 68664, 375507, 1 },
    scarlet_adaptation   = { 68687, 372469, 1 },
    sleep_walk           = { 68571, 360806, 1 },
    source_of_magic      = { 68669, 369459, 1 },
    tailwind             = { 68678, 375556, 1 },
    terror_of_the_skies  = { 68649, 371032, 1 },
    time_spiral          = { 68650, 374968, 1 },
    tip_the_scales       = { 68686, 370553, 1 },
    twin_guardian        = { 68656, 370888, 1 },
    unravel              = { 68663, 368432, 1 },
    verdant_embrace      = { 68688, 360995, 1 },
    walloping_blow       = { 68657, 387341, 1 },
    zephyr               = { 68655, 374227, 1 },

    -- Preservation
    call_of_ysera        = { 68599, 373834, 1 },
    cycle_of_life        = { 68602, 371832, 1 },
    delay_harm           = { 68584, 376207, 1 },
    dream_breath         = { 68606, 355936, 1 },
    dream_flight         = { 68580, 359816, 1 },
    dreamwalker          = { 68576, 377082, 1 },
    echo                 = { 68607, 364343, 1 },
    emerald_communion    = { 68577, 370960, 1 },
    empath               = { 68603, 376138, 1 },
    energy_loop          = { 68588, 372233, 1 },
    erasure              = { 68600, 376210, 1 },
    essence_attunement   = { 68610, 375722, 1 },
    essence_burst        = { 68609, 369297, 1 },
    exhilarating_burst   = { 68578, 377100, 2 },
    expunge              = { 68689, 365585, 1 },
    field_of_dreams      = { 68612, 370062, 1 },
    flow_state           = { 68591, 385696, 2 },
    fluttering_seedlings = { 68611, 359793, 2 },
    font_of_magic        = { 68579, 375783, 1 },
    golden_hour          = { 68595, 378196, 1 },
    grace_period         = { 68601, 376239, 2 },
    just_in_time         = { 68584, 376204, 1 },
    landslide            = { 68681, 358385, 1 },
    lifebind             = { 68613, 373270, 1 },
    lifeforce_mender     = { 68598, 376179, 2 },
    lifegivers_flame     = { 68597, 371426, 2 },
    nozdormus_teachings  = { 68590, 376237, 1 },
    ouroboros            = { 68583, 381921, 1 },
    power_nexus          = { 68581, 369908, 1 },
    punctuality          = { 68589, 371270, 1 },
    renewing_breath      = { 68582, 371257, 2 },
    resonating_sphere    = { 68590, 376236, 1 },
    reversion            = { 68608, 366155, 1 },
    rewind               = { 68593, 363534, 1 },
    rush_of_vitality     = { 68576, 377086, 1 },
    spark_of_insight     = { 68614, 377099, 1 },
    spiritbloom          = { 68604, 367226, 1 },
    spiritual_clarity    = { 68603, 376150, 1 },
    stasis               = { 68585, 370537, 1 },
    temporal_anomaly     = { 68592, 373861, 1 },
    temporal_artificer   = { 68600, 381922, 1 },
    temporal_compression = { 68605, 362874, 1 },
    time_dilation        = { 68594, 357170, 1 },
    time_lord            = { 68596, 372527, 2 },
    time_of_need         = { 68586, 368412, 1 },
    timeless_magic       = { 68587, 376240, 2 },
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
    mastery_lifebinder = {
        id = 363510,
    },
    nullifying_shroud = {
        id = 378464,
        duration = 30,
        max_stack = 3
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
        end,
    },
    chrono_loop = {
        id = 383005,
        cast = 0,
        cooldown = 90,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            if talent.temporal_compression.enabled then addStack("temporal_compression") end
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
            applyBuff("dream_breath")
            applyBuff("dream_breath_hot")
            removeBuff("call_of_ysera")
            removeBuff("temporal_compression")
            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
            end
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
            removeStack("essence_burst")
            -- if talent.cycle_of_life.enabled then
            --     if cycle_of_life_count == 2 then
            --         cycle_of_life_count = 0
            --         applyBuff( "cycle_of_life" )
            --     else
            --         cycle_of_life_count = cycle_of_life_count + 1
            --     end
            -- end
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
            removeBuff("temporal_compression")

            applyDebuff( "target", "fire_breath" )

            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
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
            applyBuff( "reversion")
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
        end,
    },
    rewind = {
        id = 363534,
        cast = 0,
        charges = 1,
        cooldown = 180,
        recharge = 180,
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
            if buff.tip_the_scales.up then
                removeBuff( "tip_the_scales" )
                setCooldown( "tip_the_scales", action.tip_the_scales.cooldown )
            end
            removeBuff( "temporal_compression" )
        end,

        copy = { 382731, 367226 }
    },
    stasis = {
        id = 370537,
        cast = 0,
        cooldown = 90,
        gcd = "off",

        spend = 0.04,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            if talent.temporal_compression.enabled then addStack( "temporal_compression" ) end
        end,
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
} )



spec:RegisterSetting( "experimental_msg", nil, {
    type = "description",
    name = "|cFFFF0000WARNING|r:  Healer support in this addon is focused on DPS output only.  This is more useful for solo content or downtime when your healing output is less critical in a group/encounter.  Use at your own risk.",
    width = "full",
} )

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