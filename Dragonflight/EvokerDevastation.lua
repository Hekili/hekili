-- EvokerDevastation.lua
-- September 2022

if UnitClassBase( "player" ) ~= "EVOKER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 1467 )

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
    aerial_mastery         = { 68659, 365933, 1 }, --
    ancient_flame          = { 68671, 369990, 1 }, --
    animosity              = { 68640, 375797, 1 }, --
    arcane_intensity       = { 68622, 375618, 2 }, --
    arcane_vigor           = { 68619, 386342, 1 }, --
    attuned_to_the_dream   = { 68672, 376930, 2 }, --
    azure_essence_burst    = { 68643, 375721, 1 }, --
    blast_furnace          = { 68667, 375510, 2 }, --
    bountiful_bloom        = { 68572, 370886, 1 }, --
    burnout                = { 68633, 375801, 2 }, --
    cascading_power        = { 68575, 375796, 1 }, --
    catalyze               = { 68636, 386283, 1 }, --
    causality              = { 68617, 375777, 1 }, --
    cauterizing_flame      = { 68673, 374251, 1 }, --
    charged_blast          = { 68627, 370455, 1 }, --
    clobbering_sweep       = { 68570, 375443, 1 }, --
    dense_energy           = { 68646, 370962, 1 }, --
    draconic_legacy        = { 68685, 376166, 2 }, --
    dragonrage             = { 68641, 375087, 1 }, --
    engulfing_blaze        = { 68648, 370837, 1 }, --
    enkindled              = { 68677, 375554, 2 }, --
    essence_attunement     = { 68625, 375722, 1 }, --
    eternity_surge         = { 68623, 359073, 1 }, --
    eternitys_span         = { 68621, 375757, 1 }, --
    everburning_flame      = { 68615, 370819, 1 }, --
    expunge                = { 68689, 365585, 1 }, --
    extended_flight        = { 68679, 375517, 2 }, --
    exuberance             = { 68573, 375542, 1 }, --
    eye_of_infinity        = { 68617, 369375, 1 }, --
    feed_the_flames        = { 68615, 369846, 1 }, --
    fire_within            = { 68654, 375577, 1 }, --
    firestorm              = { 68635, 368847, 1 }, --
    foci_of_life           = { 68654, 375574, 1 }, --
    focusing_iris          = { 68619, 386336, 1 }, --
    font_of_magic          = { 68632, 375783, 1 }, --
    forger_of_mountains    = { 68569, 375528, 1 }, --
    heat_wave              = { 68637, 375725, 2 }, --
    heavy_wingbeats        = { 68570, 368838, 1 }, --
    honed_aggression       = { 68626, 371038, 2 }, --
    imminent_destruction   = { 68631, 370781, 2 }, --
    imposing_presence      = { 68642, 371016, 1 }, --
    innate_magic           = { 68683, 375520, 2 }, --
    inner_radiance         = { 68642, 386405, 1 }, --
    instinctive_arcana     = { 68666, 376164, 2 }, --
    iridescence            = { 68616, 370867, 1 }, --
    landslide              = { 68681, 358385, 1 }, --
    lay_waste              = { 68624, 371034, 2 }, --
    leaping_flames         = { 68662, 369939, 1 }, --
    lush_growth            = { 68652, 375561, 2 }, --
    natural_convergence    = { 68682, 369913, 1 }, --
    obsidian_bulwark       = { 68674, 375406, 1 }, --
    obsidian_scales        = { 68675, 363916, 1 }, --
    onyx_legacy            = { 68630, 386348, 1 }, --
    oppressing_roar        = { 68668, 372048, 1 }, --
    overawe                = { 68660, 374346, 1 }, --
    panacea                = { 68680, 387761, 1 }, --
    permeating_chill       = { 68676, 370897, 1 }, --
    power_nexus            = { 68574, 369908, 1 }, --
    power_swell            = { 68620, 370839, 2 }, --
    protracted_talons      = { 68661, 369909, 1 }, --
    pyre                   = { 68644, 357211, 1 }, --
    quell                  = { 68665, 351338, 1 }, --
    recall                 = { 68684, 371806, 1 }, --
    regenerative_magic     = { 68651, 387787, 1 }, --
    renewing_blaze         = { 68653, 374348, 1 }, --
    rescue                 = { 68658, 370665, 1 }, --
    roar_of_exhilaration   = { 68664, 375507, 1 }, --
    ruby_embers            = { 68648, 365937, 1 }, --
    ruby_essence_burst     = { 68645, 376872, 1 }, --
    scarlet_adaptation     = { 68687, 372469, 1 }, --
    scintillation          = { 68629, 370821, 2 }, --
    shattering_star        = { 68618, 370452, 1 }, --
    sleep_walk             = { 68571, 360806, 1 }, --
    snapfire               = { 68634, 370783, 1 }, --
    source_of_magic        = { 68669, 369459, 1 }, --
    spellweavers_dominance = { 68628, 370845, 1 }, --
    tailwind               = { 68678, 375556, 1 }, --
    tempered_scales        = { 68670, 375544, 2 }, --
    terror_of_the_skies    = { 68649, 371032, 1 }, --
    time_spiral            = { 68650, 374968, 1 }, --
    tip_the_scales         = { 68686, 370553, 1 }, --
    titanic_wrath          = { 68639, 386272, 2 }, --
    twin_guardian          = { 68656, 370888, 1 }, --
    tyranny                = { 68638, 376888, 1 }, --
    unravel                = { 68663, 368432, 1 }, --
    verdant_embrace        = { 68688, 360995, 1 }, --
    volatility             = { 68647, 369089, 2 }, --
    walloping_blow         = { 68657, 387341, 1 }, --
    zephyr                 = { 68655, 374227, 1 }, --
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    chrono_loop        = 5456, -- 383005
    crippling_force    = 5471, -- 384660
    divide_and_conquer = 5473, -- 384689
    nullifying_shroud  = 5467, -- 378464
    obsidian_mettle    = 5460, -- 378444
    precognition       = 5509, -- 377360
    scouring_flame     = 5462, -- 378438
    swoop_up           = 5466, -- 370388
    time_stop          = 5464, -- 378441
    unburdened_flight  = 5469, -- 378437
} )


-- Auras
spec:RegisterAuras( {
    ancient_flame = {
        id = 375583,
        duration = 3600,
        max_stack = 1
    },
    burnout = {
        id = 375802,
        duration = 4,
        max_stack = 1,
    },
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
    deep_breath = {
        id = 357210,
        duration = 6,
        max_stack = 1
    },
    disintegrate = {
        id = 356995,
        duration = function () return 3 * ( talent.natural_convergence.enabled and 0.8 or 1 ) end,
        tick_time = function () return talent.natural_convergence.enabled and 0.8 or 1 end,
        max_stack = 1,
    },

    dragonrage = {
        id = 375087,
        duration = 14,
        max_stack = 1
    },
    essence_burst = {
        id = 359618,
        duration = 15,
        max_stack = 1,
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
        duration = 3.25,
    },
    fire_breath = {
        id = 357209,
        duration = function ()
            -- TODO: Empowerment Level impact on duration.
            -- return empowerment_level * 4
            return talent.font_of_magic.enabled and 16 or 12
        end,
        -- TODO: damage = function () return 0.322 * stat.spell_power * action.fire_breath.spell_targets * ( talent.heat_wave.enabled and 1.2 or 1 ) * ( debuff.shattering_star.up and 1.2 or 1 ) end,
        max_stack = 1,
    },
    firestorm = { -- TODO: Check for totem?
        id = 369372,
        duration = 12,
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
        duration = function () return talent.extended_flight.enabled and 10 or 6 end,
        tick_time = 1,
        max_stack = 1,
    },
    landslide = {
        id = 355689,
        duration = 30,
        max_stack = 1,
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
    recall = {
        id = 371807,
        duration = 10,
        max_stack = function () return talent.essence_attunement.enabled and 2 or 1 end,
    },
    renewing_blaze = {
        id = 374348,
        duration = 8,
        max_stack = 1,
    },
    renewing_blaze_heal = {
        id = 374349,
        duration = 14,
        max_stack = 1,
    },
    shattering_star = {
        id = 370452,
        duration = function () return talent.focusing_iris.enabled and 6 or 4 end,
        max_stack = 1
    },
    sleep_walk = {
        id = 360806,
        duration = 20,
        max_stack = 1
    },
    snapfire = {
        id = 370818,
        duration = 10,
        max_stack = 1
    },
    source_of_magic = {
        id = 369459,
        duration = 1800,
        max_stack = 1,
        friendly = true,
    },
    terror_of_the_skies = {
        id = 372245,
        duration = 3,
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
        max_stack = 1,
    },
    unravel_absorb = {
        duration = 15,
        max_stack = 1,
        -- TODO: Check if function works.
        generate = function( t, auraType )
            local unit = auraType == "debuff" and "target" or "player"
            local amount = UnitGetTotalAbsorbs( unit )

            if amount > 0 then
                t.name = action.unravel.name .. " " .. ABSORB
                t.count = 1
                t.expires = now + 10
                t.applied = now - 5
                t.caster = unit
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end
    },
    youre_coming_with_me = {
        id = 370388,
        duration = 1,
        max_stack = 1
    },
    zephyr = {
        id = 374227,
        duration = 8,
        max_stack = 1,
    },
} )


--[[
Notes on Empowered Spells:
1. Starting cast of Fire Breath fires UNIT_SPELLCAST_SENT, then ACTIONBAR_SLOT_CHANGED will fire for that spell's slot.  UNIT_SPELLCAST_EMPOWER_START fires with UNIT_SPELLCAST_SUCCEEDED in the same frame.
2. SPELL_TEXT_UPDATE fires soon after (has the replacement spell ID).
3. UNIT_SPELLCAST_EMPOWER_STOP is fired when the "cast" is completed.
4. UNIT_SPELLCAST_SENT&SUCCEEDED for "Don't Start GCD" occurs after.  https://www.wowhead.com/beta/spell=359115/dnt-activate-gcd
  ]]

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
            if talent.azure_essence_burst.enabled and buff.dragonrage.up and talent.ruin.enabled then addStack( "essence_burst", nil, 1 ) end -- TODO:  Does this give 2 stacks if hitting 2 targets w/ Essence Attunement?
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

        spend = 0.013,
        spendType = "mana",

        talent = "cauterizing_flame",
        startsCombat = true,
        texture = 4630446,

        toggle = "interrupts",

        healing = function () return 3.50 * stat.spell_power end,

        usable = function()
            return buff.dispellable_poison.up or buff.dispellable_curse.up or buff.dispellable_disease.up, "requires dispellable effect"
        end,

        handler = function ()
            removeBuff( "dispellable_poison" )
            removeBuff( "dispellable_curse" )
            removeBuff( "dispellable_disease" )
            health.current = min( health.max, health.current + action.cauterizing_flame.healing )
        end,
    },


    deep_breath = {
        id = function () return buff.recall.up and 371807 or 357210 end,
        cast = 0,
        cooldown = function ()
            return talent.onyx_legacy.enabled and 60 or 120
        end,
        gcd = "spell",

        startsCombat = false,
        texture = 4622450,

        toggle = "cooldowns",

        min_range = 20,
        max_range = 50,

        damage = function () return 2.30 * stat.spell_power end,

        handler = function ()
            if buff.recall.up then
                removeBuff( "recall" )
            else
                setCooldown( "global_cooldown", 6 ) -- TODO: Check.
                applyBuff( "recall", 9 )
                buff.recall.applied = query_time + 6
            end
        end,

        copy = { "recall", 371807, 357210 },
    },


    disintegrate = {
        id = 356995,
        cast = 3,
        channeled = true,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.essence_burst.up and 0 or 3 end,
        spendType = "essence",

        startsCombat = true,
        texture = 4622451,

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
            applyDebuff( "target", "disintegrate" )
            if buff.essence_burst.up then removeStack( "essence_burst", 1 ) end
        end,
    },


    dragonrage = {
        id = 375087,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "dragonrage",
        startsCombat = false,
        texture = 4622452,

        toggle = "cooldowns",

        spell_targets = function () return min( 3, active_enemies ) end,
        damage = function () return action.living_pyre.damage * action.dragonrage.spell_targets end,

        handler = function ()
            applyBuff( "dragonrage" )
        end,
    },


    emerald_blossom = {
        id = 355913,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0,
        spendType = "essence",

        startsCombat = false,
        texture = 4622457,

        healing = function () return 2.5 * stat.spell_power end,    -- TODO: Make a fake aura so we know if an Emerald Blossom is pending for a target already?
                                                                    -- TODO: Factor in Fluttering Seedlings?  ( 0.9 * stat.spell_power * targets impacted )

        -- o Cycle of Life (?); every 3 Emerald Blossoms leaves a tiny sprout which gathers 10% of healing over 15 seconds, then heals allies w/in 25 yards.
        --    - Count shows on action button.

        handler = function ()
            if talent.cycle_of_life.enabled then
                if cycle_of_life_count == 2 then
                    cycle_of_life_count = 0
                    applyBuff( "cycle_of_life" )
                else
                    cycle_of_life_count = cycle_of_life_count + 1
                end
            end
        end,
    },


    eternity_surge = {
        id = 359073,
        cast = function ()
            if buff.tip_the_scales.up then return 0 end
            return 2.5 * ( talent.imminent_destruction.enabled and 0.8 or 1 )
        end,
        -- channeled = true,
        empowered = true,
        cooldown = 30,
        gcd = "spell",

        talent = "eternity_surge",
        startsCombat = true,
        texture = 4630444,

        -- TODO: Determine how to know what level of empowerment a cast will be.
        --       Based on buff.casting.remains vs. buff.casting.duration ?
        -- spell_targets = function () return min( active_enemies, ( talent.eternitys_span.enabled and 2 or 1 ) * empowerment_level end,
        damage = function () return spell_targets.eternity_surge * 3.4 * stat.spell_power end,

        finish = function ()
            removeBuff( "tip_the_scales" )
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

        toggle = "interrupts",

        buff = "dispellable_poison",

        handler = function ()
            removeBuff( "dispellable_poison" )
        end,
    },


    fire_breath = {
        id = 357208,
        cast = function ()
            if buff.tip_the_scales.up then return 0 end
            return 2.5 * ( talent.imminent_destruction.enabled and 0.8 or 1 )
        end,
        -- channeled = true,
        empowered = true,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 4622458,

        spell_targets = function () return active_enemies end,
        damage = function () return 1.334 * stat.spell_power * ( 1 + 0.1 * talent.blast_furnace.rank ) * ( debuff.shattering_star.up and 1.2 or 1 ) end,
        critical = function () return stat.crit + conduit.spark_of_savagery.mod end,
        critical_damage = function () return talent.tyranny.enabled and 2.2 or 2 end,

        finish = function ()
            applyDebuff( "target", "fire_breath" )
        end,
    },


    firestorm = {
        id = 368847,
        cast = 2,
        cooldown = 20,
        gcd = "spell",

        talent = "firestorm",
        startsCombat = false,
        texture = 4622459,

        min_range = 0,
        max_range = 25,

        spell_targets = function () return active_enemies end,
        damage = function () return action.firestorm.spell_targets * 0.276 * stat.spell_power * 7 end,

        handler = function ()
        end,
    },


    fly_with_me = {
        id = 370665,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        talent = "fly_with_me",
        startsCombat = false,
        texture = 4622460,

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
        texture = 4622462,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "fury_of_the_aspects" )
            applyDebuff( "player", "exhaustion" )
        end,
    },


    hover = {
        id = 358267,
        cast = 0,
        charges = function() return talent.aerial_mastery.enabled and 2 or 1 end,
        cooldown = 35,
        recharge = 35,
        gcd = "off",

        startsCombat = false,
        texture = 4622463,

        handler = function ()
            applyBuff( "hover" )
        end,
    },


    landslide = {
        id = 358385,
        cast = 0,
        cooldown = function () return talent.forger_of_mountains.enabled and 60 or 90 end,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "landslide",
        startsCombat = true,
        texture = 1016245,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "landslide" )
        end,
    },


    living_flame = {
        id = 361469,
        cast = function() return ( talent.engulfing_blaze.enabled and 2.5 or 2 ) * ( buff.ancient_flame.up and 0.6 or 0.4 ) * ( buff.burnout.up and 0.7 or 0.3 ) end,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,
        texture = 4622464,

        damage = function () return 1.61 * stat.spell_power * ( talent.engulfing_blaze.enabled and 1.4 or 1 ) end,
        healing = function () return 2.75 * stat.spell_power * ( talent.engulfing_blaze.enabled and 1.4 or 1 ) * ( 1 + 0.03 * talent.enkindled.rank ) * ( talent.inner_radiance.enabled and 1.3 or 1 ) end,

        -- x Ancient Flame
        -- x Burnout
        -- x Engulfing Blaze
        -- x Enkindled
        -- - Hover
        -- x Inner Radiance

        handler = function ()
            removeBuff( "ancient_flame" )
            -- Burnout is not consumed.
            if talent.ruby_essence_burst.enabled and buff.dragonrage.up and talent.ruin.enabled then addStack( "essence_burst", nil, 1 ) end
        end,
    },


    obsidian_scales = {
        id = 363916,
        cast = 0,
        cooldown = function () return talent.obsidian_bulwark.enabled and 90 or 150 end,
        gcd = "off",

        talent = "obsidian_scales",
        startsCombat = false,
        texture = 1394891,

        toggle = "defensives",

        handler = function ()
            applyBuff( "obsidian_scales" )
        end,
    },


    oppressing_roar = {
        id = 372048,
        cast = 0,
        cooldown = 120,
        gcd = "spell",

        talent = "oppressing_roar",
        startsCombat = true,
        texture = 4622466,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "oppressing_roar" )
            if talent.overawe.enabled and debuff.dispellable_enrage.up then removeDebuff( "target", "dispellable_enrage" ) end
        end,
    },


    pyre = {
        id = 357211,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 3,
        spendType = "essence",

        talent = "pyre",
        startsCombat = false,
        texture = 4622468,

        -- TODO: Need to proc Charged Blast on Blue spells.

        handler = function ()
            removeBuff( "charged_blast" )
        end,
    },


    quell = {
        id = 351338,
        cast = 0,
        cooldown = function () return talent.imposing_presence.enabled and 20 or 40 end,
        gcd = "off",

        talent = "quell",
        startsCombat = true,
        texture = 4622469,

        toggle = "interrupts",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,
    },


    renewing_blaze = {
        id = 374348,
        cast = 0,
        cooldown = function () return talent.fire_within.enabled and 60 or 90 end,
        gcd = "off",

        talent = "renewing_blaze",
        startsCombat = false,
        texture = 4630463,

        toggle = "defensives",

        -- TODO: o Pyrexia would increase all heals by 20%.

        handler = function ()
            applyBuff( "renewing_blaze" )
            applyBuff( "renewing_blaze_heal" )
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

        toggle = "interrupts",

        handler = function ()
            -- Not implementing.
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


    shattering_star = {
        id = 370452,
        cast = 0,
        cooldown = 15,
        gcd = "spell",

        talent = "shattering_star",
        startsCombat = true,
        texture = 4622449,

        spell_targets = function () return min( active_enemies, talent.eternitys_span.enabled and 2 or 1 ) end,
        damage = function () return 1.6 * stat.spell_power end,
        critical = function () return stat.crit + conduit.spark_of_savagery.mod end,
        critical_damage = function () return talent.tyranny.enabled and 2.2 or 2 end,

        handler = function ()
            applyDebuff( "target", "shattering_star" )
            if talent.arcane_vigor.enabled then gain( 1, "essence" ) end
        end,
    },


    sleep_walk = {
        id = 360806,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",

        spend = 0.024,
        spendType = "mana",

        talent = "sleep_walk",
        startsCombat = true,
        texture = 1396974,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "sleep_walk" )
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
            active_dot.source_of_magic = 1
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
            applyBuff( "time_spiral" )
            active_dot.time_spiral = group_members
            setCooldown( "hover", 0 )
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
            applyBuff( "tip_the_scales" )
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

        debuff = "unravel_absorb",

        handler = function ()
            removeDebuff( "unravel_absorb" )
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

        toggle = "defensives",

        handler = function ()
            applyBuff( "zephyr" )
            active_dot.zephyr = group_members
        end,
    },
} )

spec:RegisterPack( "Devastation", 20220906, [[Hekili:nsvttXnoq0)nCGqShpdHeimCyZMdWbQTktoLcBjl32w1il5vFWWSh0V9TLhiwEidvoWGC3TEVx3Q7UiR4HI8AQfkUF5ILlxC5IlswS48vlZkYT7gGI8bkBdTfpiP94V)n8e1yPwUsg8TtOO1bmmkNMH(7S2bZvPPTCBNRkHP6tn8ENy8gmnTXg(MLwjuvP1AARs2i4TD2uq2YLqktqnMYEvTtaMu6Gi8xj8KAdOtyddf5voUWERSO63O8vFz1fOygawX9zNFXNrbXRRH9bdg2SeWt((iS(7839pckd6uIAKLICb3ynJLgOH6ew849JLkkBFM)VoqikYbjTsa1f)vHfLrCadQ9)FweRcrmzjNP5wqZP4jfsTARmzFjb)bs0qpLlnEY1R9KvEYPEslRoPN(8en1CdxAHwDOqGmCESgMW6aD8P4OmDuBqfY2sSUOpi0loqYVElaVIKB3vAC6r87huBbDPvvKNfU4NpAUw5AAIZt3WeSw(qPTdknmk(8hW5lXATHRHYknqTDhOZlpkDyZGquIzwlynjd70GNCJNSm6TcTfWiBX7R5kNwQCwuWEYjEYOnWyajdfLtBSjybKTbFW(ToXhUYXaMywWFku3BeHzRGcM1Kn7XDE6MT8pmFP)NdlzgRMV5n5DSVrqxfZ(mTnJDlwY0aoAxrdtgJg2sX2bzRPi)Hoo2ZoOvnCbsz4JEUbZKwpX4gguARN0O0y3mirjZ8eubYnb16jEYT29xAKHEqwd1yeytQNapb6DbS5kmDXtCjt4W5A0fUVb0xHJYKp6j)8hgiGe0BE8mpzBhN1fhnvUBIvprQcG)8GGZ4wXeU1HtbYHjs)QNO0VsZd7HWtYEmaADSPLrmVLlerz0lqAFn0XQXOjPRVc0bIncLnXF3T9HcwWqgYaB)ARX1tOt8XYz7u4mBoV)BHxLXI(RVHM1JRP839YNFyD6(1sXwIBYoJ3S(D2eD96vN(YgOzi8RaJTEWALyxZ3DC20QJ1zXHnFxqqBVDZrC8rlhMLY40D4YVDpWnlJJlUF)xKnnYFYXg3V(9g1pwLo2E8y4BfAS3Jl4XHWI)p]] )