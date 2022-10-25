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
    aerial_mastery         = { 68659, 365933, 1 }, -- Hover gains 1 additional charge.
    ancient_flame          = { 68671, 369990, 1 }, -- Healing yourself with Living Flame reduces the cast time of your next Living Flame by 40%.
    animosity              = { 68640, 375797, 1 }, -- Casting an empower spell extends the duration of Dragonrage by 6 sec.
    arcane_intensity       = { 68622, 375618, 2 }, -- Disintegrate deals 8% more damage.
    arcane_vigor           = { 68619, 386342, 1 }, -- Shattering Star generates 1 Essence.
    attuned_to_the_dream   = { 68672, 376930, 2 }, -- Your healing done and healing received are increased by 2%.
    azure_essence_burst    = { 68643, 375721, 1 }, -- Azure Strike has a 15% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    blast_furnace          = { 68667, 375510, 2 }, -- Fire Breath's damage over time lasts 0 sec longer.
    bountiful_bloom        = { 68572, 370886, 1 }, -- Emerald Blossom heals 2 additional allies.
    burnout                = { 68633, 375801, 2 }, -- Fire Breath damage has 6% chance to cause your next Living Flame to be instant cast, stacking 2 times.
    catalyze               = { 68636, 386283, 1 }, -- While channeling Disintegrate your Fire Breath on the target deals damage 100% more often.
    causality              = { 68617, 375777, 1 }, -- Essence abilities reduce the remaining cooldown of Eternity Surge by 1 sec.
    cauterizing_flame      = { 68673, 374251, 1 }, -- Cauterize an ally's wounds, removing all Bleed, Poison, Curse, and Disease effects. Heals for 2,404 upon removing any effect.
    charged_blast          = { 68627, 370455, 1 }, -- Your Blue damage increases the damage of your next Pyre by 5%, stacking 20 times.
    clobbering_sweep       = { 68570, 375443, 1 }, -- Tail Swipe's cooldown is reduced by 45 sec.
    dense_energy           = { 68646, 370962, 1 }, -- Pyre's Essence cost is reduced by 1.
    draconic_legacy        = { 68685, 376166, 2 }, -- Your Stamina is increased by 2%.
    dragonrage             = { 68641, 375087, 1 }, -- Erupt with draconic fury and exhale Pyres at 3 enemies within 25 yds. For 14 sec, Essence Burst's chance to occur is increased to 100%.
    engulfing_blaze        = { 68648, 370837, 1 }, -- Living Flame deals 40% increased damage and healing, but its cast time is increased by 0.5 sec.
    enkindled              = { 68677, 375554, 2 }, -- Living Flame deals 3% more damage and healing.
    essence_attunement     = { 68625, 375722, 1 }, -- Essence Burst stacks 2 times.
    eternity_surge         = { 68623, 359073, 1 }, -- Focus your energies to release a salvo of pure magic, dealing 2,335 Spellfrost damage to an enemy. Damages additional enemies within 12 yds of the target when empowered. I: Damages 1 enemy. II: Damages 2 enemies. III: Damages 3 enemies.
    eternitys_span         = { 68621, 375757, 1 }, -- Eternity Surge and Shattering Star hit twice as many targets.
    everburning_flame      = { 68615, 370819, 1 }, -- Red spells extend the duration of your Fire Breath's damage over time by 1 sec.
    expunge                = { 68689, 365585, 1 }, -- Expunge toxins affecting an ally, removing all Poison effects.
    extended_flight        = { 68679, 375517, 2 }, -- Hover lasts 4 sec longer.
    exuberance             = { 68573, 375542, 1 }, -- While above 75% health, your movement speed is increased by 10%.
    eye_of_infinity        = { 68617, 369375, 1 }, -- Eternity Surge critical strikes grant you Essence Burst.
    feed_the_flames        = { 68615, 369846, 1 }, -- Consuming Essence Burst reduces the remaining cooldown of Fire Breath by 2 sec.
    fire_within            = { 68654, 375577, 1 }, -- Renewing Blaze's cooldown is reduced by 30 sec.
    firestorm              = { 68635, 368847, 1 }, -- An explosion bombards the target area with white-hot embers, dealing 1,327 Fire damage to enemies over 12 sec.
    foci_of_life           = { 68654, 375574, 1 }, -- While Renewing Blaze's initial effect is active, you receive 20% increased healing from all sources.
    focusing_iris          = { 68619, 386336, 1 }, -- Shattering Star's damage taken effect lasts 2 sec longer.
    font_of_magic          = { 68632, 375783, 1 }, -- Your empower spells' maximum level is increased by 1.
    forger_of_mountains    = { 68569, 375528, 1 }, -- Landslide's cooldown is reduced by 30 sec, and it can withstand 200% more damage before breaking.
    heat_wave              = { 68637, 375725, 2 }, -- Fire Breath deals 20% more damage.
    heavy_wingbeats        = { 68570, 368838, 1 }, -- Wing Buffet's cooldown is reduced by 45 sec.
    hoarded_power          = { 68575, 375796, 1 }, -- Essence Burst has a 20% chance to not be consumed.
    honed_aggression       = { 68626, 371038, 2 }, -- Azure Strike and Living Flame deal 5% more damage.
    imminent_destruction   = { 68631, 370781, 2 }, -- Empower spells reach maximum level in 20% less time.
    imposing_presence      = { 68642, 371016, 1 }, -- Quell's cooldown is reduced by 20 sec.
    innate_magic           = { 68683, 375520, 2 }, -- Essence regenerates 5% faster.
    inner_radiance         = { 68642, 386405, 1 }, -- Your Living Flame and Emerald Blossom are 30% more effective on yourself.
    instinctive_arcana     = { 68666, 376164, 2 }, -- Your Magic damage done is increased by 2%.
    iridescence            = { 68616, 370867, 1 }, -- Casting an empower spell increases the damage of your next 2 spells of the same color by 15% within 10 sec.
    landslide              = { 68681, 358385, 1 }, -- Conjure a path of shifting stone towards the target location, rooting enemies for 30 sec. Damage may cancel the effect.
    lay_waste              = { 68624, 371034, 2 }, -- Deep Breath's damage is increased by 10%.
    leaping_flames         = { 68662, 369939, 1 }, -- Fire Breath causes your next Living Flame to strike 1 additional target per empower level.
    lush_growth            = { 68652, 375561, 2 }, -- Green spells restore 5% more health.
    natural_convergence    = { 68682, 369913, 1 }, -- Disintegrate channels 20% faster.
    obsidian_bulwark       = { 68674, 375406, 1 }, -- Obsidian Scales's cooldown is reduced by 60 sec.
    obsidian_scales        = { 68675, 363916, 1 }, -- Reinforce your scales, increasing your armor by 200% and reducing magic damage taken by 20%. Lasts 12 sec.
    onyx_legacy            = { 68630, 386348, 1 }, -- Deep Breath's cooldown is reduced by 1 min.
    oppressing_roar        = { 68668, 372048, 1 }, -- Let out a bone-shaking roar at enemies in a cone in front of you, increasing the duration of crowd controls that affect them by 50% in the next 10 sec.
    overawe                = { 68660, 374346, 1 }, -- Oppressing Roar removes 1 Enrage effect from each enemy, and its cooldown is reduced by 20 sec for each Enrage dispelled.
    panacea                = { 68680, 387761, 1 }, -- Emerald Blossom instantly heals you for 987 when cast.
    permeating_chill       = { 68676, 370897, 1 }, -- Your damaging Blue spells reduce the target's movement speed by 50% for 3 sec.
    power_nexus            = { 68574, 369908, 1 }, -- Increases your maximum Essence to 6.
    power_swell            = { 68620, 370839, 2 }, -- Casting an empower spell increases your Essence regeneration rate by 100% for 2 sec.
    protracted_talons      = { 68661, 369909, 1 }, -- Azure Strike damages 1 additional enemy.
    pyre                   = { 68644, 357211, 1 }, -- Lob a ball of flame, dealing 556 Fire damage to the target and nearby enemies.
    quell                  = { 68665, 351338, 1 }, -- Interrupt an enemy's spellcasting and preventing any spell from that school of magic from being cast for 4 sec.
    recall                 = { 68684, 371806, 1 }, -- You may reactivate Deep Breath within 3 sec after landing to travel back in time to your takeoff location.
    regenerative_magic     = { 68651, 387787, 1 }, -- Source of Magic forms a bond with your ally, causing 10% of their healing to also heal you while you are below 50% health.
    renewing_blaze         = { 68653, 374348, 1 }, -- The flames of life surround you for 8 sec. While this effect is active, 100% of damage you take is healed back over 14 sec.
    rescue                 = { 68658, 370665, 1 }, -- Swoop to an ally and fly with them to the target location.
    roar_of_exhilaration   = { 68664, 375507, 1 }, -- Successfully interrupting an enemy with Quell generates 1 Essence.
    ruby_embers            = { 68648, 365937, 1 }, -- Living Flame deals 128 damage over 12 sec to enemies, or restores 321 health to allies over 12 sec. Stacks 3 times.
    ruby_essence_burst     = { 68645, 376872, 1 }, -- Your Living Flame has a 20% chance to cause an Essence Burst, making your next Disintegrate or Pyre cost no Essence.
    scarlet_adaptation     = { 68687, 372469, 1 }, -- Store 20% of your effective healing, up to 1,106. Your next damaging Living Flame consumes all stored healing to increase its damage dealt.
    scintillation          = { 68629, 370821, 2 }, -- Disintegrate has a 15% chance each time it deals damage to launch a level 1 Eternity Surge at 30% power.
    shattering_star        = { 68618, 370452, 1 }, -- Exhale a bolt of concentrated power from your mouth for 1,099 Spellfrost damage that cracks the target's defenses, increasing the damage they take from you by 20% for 4 sec.
    sleep_walk             = { 68571, 360806, 1 }, -- Disorient an enemy for 20 sec, causing them to sleep walk towards you. Damage has a chance to awaken them.
    snapfire               = { 68634, 370783, 1 }, -- Living Flame has a 12% chance to reset the cooldown of Firestorm, and make your next one instant cast and deal 40% increased damage.
    source_of_magic        = { 68669, 369459, 1 }, -- Redirect your excess magic to a friendly healer for 30 min. When you cast an empowered spell, you restore 0.25% of their maximum mana per empower level. Limit 1.
    spellweavers_dominance = { 68628, 370845, 1 }, -- Your damaging critical strikes deal 220% damage instead of the usual 200%.
    tailwind               = { 68678, 375556, 1 }, -- Hover increases your movement speed by 70% for the first 4 sec.
    tempered_scales        = { 68670, 375544, 2 }, -- Magic damage taken reduced by 2%.
    terror_of_the_skies    = { 68649, 371032, 1 }, -- Deep Breath stuns enemies for 3 sec.
    time_spiral            = { 68650, 374968, 1 }, -- Bend time, allowing you and your allies to cast their major movement ability once in the next 10 sec, even if it is on cooldown.
    tip_the_scales         = { 68686, 370553, 1 }, -- Compress time to make your next empowered spell cast instantly at its maximum empower level.
    titanic_wrath          = { 68639, 386272, 2 }, -- Essence Burst increases the damage of affected spells by 8.0%.
    twin_guardian          = { 68656, 370888, 1 }, -- Rescue protects you and your ally from harm, absorbing damage equal to 30% of your maximum health for 5 sec.
    tyranny                = { 68638, 376888, 1 }, -- During Deep Breath and Dragonrage you gain the maximum benefit of Mastery: Giantkiller regardless of targets' health.
    unravel                = { 68663, 368432, 1 }, -- Sunder an enemy's protective magic, dealing 3,435 Spellfrost damage to absorb shields.
    verdant_embrace        = { 68688, 360995, 1 }, -- Fly to an ally and heal them for 2,445.
    volatility             = { 68647, 369089, 2 }, -- Pyre has a 20% chance to flare up and explode again on a nearby target.
    walloping_blow         = { 68657, 387341, 1 }, -- Wing Buffet and Tail Swipe knock enemies further and daze them, reducing movement speed by 70% for 4 sec.
    zephyr                 = { 68655, 374227, 1 }, -- Conjure an updraft to lift you and your 4 nearest allies within 20 yds into the air, reducing damage taken from area-of-effect attacks by 20% and increasing movement speed by 30% for 8 sec.
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
        max_stack = function() return talent.essence_attunement.enabled and 2 or 1 end,
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
            return ( talent.font_of_magic.enabled and 16 or 12 ) + talent.blast_furnace.rank * 2
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
    leaping_flames = {
        id = 370901,
        duration = 30,
        max_stack = 4,
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
    power_swell = {
        id = 376850,
        duration = 2,
        max_stack = 1,
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
    scarlet_adaptation = {
        id = 372470,
        duration = 3600,
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
    twin_guardian = {
        id = 370889,
        duration = 5,
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

spec:RegisterHook( "runHandler", function( action )
    local color = ability.color
    if color then
        if color == "red" and buff.iridescence_red.up then removeStack( "iridescence_red" )
        elseif color == "blue" and buff.iridescence_blue.up then removeStack( "iridescence_blue" ) end
    end

    if talent.power_swell.enabled and ability.empowered then
        applyBuff( "power_swell" ) -- TODO: Modify Essence regen rate.
    end
end )

-- Abilities
spec:RegisterAbilities( {
    azure_strike = {
        id = 362969,
        cast = 0,
        cooldown = 0,
        color = "blue",
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
            if talent.azure_essence_burst.enabled and buff.dragonrage.up then addStack( "essence_burst", nil, 1 ) end -- TODO:  Does this give 2 stacks if hitting 2 targets w/ Essence Attunement?
        end,
    },


    blessing_of_the_bronze = {
        id = 364342,
        cast = 0,
        cooldown = 15,
        color = "bronze",
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
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
        end,
    },


    deep_breath = {
        id = function () return buff.recall.up and 371807 or 357210 end,
        cast = 0,
        cooldown = function ()
            return talent.onyx_legacy.enabled and 60 or 120
        end,
        color = "black",
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

            if talent.terror_of_the_skies.enabled then applyDebuff( "target", "terror_of_the_skies" ) end
        end,

        copy = { "recall", 371807, 357210 },
    },


    disintegrate = {
        id = 356995,
        cast = function() return 3 * ( talent.natural_convergence.enabled and 0.8 or 1 ) end,
        channeled = true,
        cooldown = 0,
        color = "blue",
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
            if buff.essence_burst.up then
                if talent.feed_the_flames.enabled then reduceCooldown( "fire_breath", 2 ) end
                removeStack( "essence_burst", 1 )
            end
            if talent.causality.enabled then reduceCooldown( "essence_burst", 1 ) end
        end,
    },


    dragonrage = {
        id = 375087,
        cast = 0,
        cooldown = 120,
        color = "red",
        gcd = "spell",

        talent = "dragonrage",
        startsCombat = false,
        texture = 4622452,

        toggle = "cooldowns",

        spell_targets = function () return min( 3, active_enemies ) end,
        damage = function () return action.living_pyre.damage * action.dragonrage.spell_targets end,

        handler = function ()
            applyBuff( "dragonrage" )
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
        end,
    },


    emerald_blossom = {
        id = 355913,
        cast = 0,
        cooldown = 30,
        color = "green",
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
            if talent.causality.enabled then reduceCooldown( "essence_burst", 1 ) end
        end,
    },


    eternity_surge = {
        id = function() return talent.font_of_magic.enabled and 382411 or 359073 end,
        cast = function ()
            if buff.tip_the_scales.up then return 0 end
            return ( talent.font_of_magic.enabled and 3.25 or 2.5 ) * ( talent.imminent_destruction.enabled and 0.8 or 1 )
        end,
        -- channeled = true,
        empowered = true,
        cooldown = 30,
        color = "blue",
        gcd = "spell",

        talent = "eternity_surge",
        startsCombat = true,
        texture = 4630444,

        -- TODO: Determine how to know what level of empowerment a cast will be.
        --       Based on buff.casting.remains vs. buff.casting.duration ?
        -- spell_targets = function () return min( active_enemies, ( talent.eternitys_span.enabled and 2 or 1 ) * empowerment_level end,
        damage = function () return spell_targets.eternity_surge * 3.4 * stat.spell_power end,

        finish = function ()
            if buff.dragonrage.up then buff.dragonrage.expires = buff.dragonrage.expires + 6 end
            if talent.iridescence.enabled then applyBuff( "iridescence_blue", nil, 2 ) end
            removeBuff( "tip_the_scales" )
        end,

        copy = { 382411, 359073 }
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
        id = function() return talent.font_of_magic.enabled and 382266 or 357208 end,
        cast = function ()
            if buff.tip_the_scales.up then return 0 end
            return ( talent.font_of_magic.enabled and 3.25 or 2.5 ) * ( talent.imminent_destruction.enabled and 0.8 or 1 )
        end,
        -- channeled = true,
        empowered = true,
        cooldown = 30,
        color = "red",
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = true,
        texture = 4622458,

        spell_targets = function () return active_enemies end,
        damage = function () return 1.334 * stat.spell_power * ( 1 + 0.1 * talent.blast_furnace.rank ) * ( debuff.shattering_star.up and 1.2 or 1 ) end,
        critical = function () return stat.crit + conduit.spark_of_savagery.mod end,
        critical_damage = function () return talent.tyranny.enabled and 2.2 or 2 end,

        finish = function()
            if buff.dragonrage.up then buff.dragonrage.expires = buff.dragonrage.expires + 6 end
            if talent.iridescence.enabled then applyBuff( "iridescence_red", nil, 2 ) end
            if talent.leaping_flames.enabled then applyBuff( "leaping_flames", nil, 4 ) end -- TODO: Stack is based on Empowerment level.
            applyDebuff( "target", "fire_breath" )
        end,

        copy = { 382266, 357208 }
    },


    firestorm = {
        id = 368847,
        cast = function() return buff.snapfire.up and 0 or 2 end,
        cooldown = 20,
        color = "red",
        gcd = "spell",

        talent = "firestorm",
        startsCombat = false,
        texture = 4622459,

        min_range = 0,
        max_range = 25,

        spell_targets = function () return active_enemies end,
        damage = function () return action.firestorm.spell_targets * 0.276 * stat.spell_power * 7 end,

        handler = function ()
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
            removeBuff( "snapfire" )
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
            removeBuff( "time_spiral" )
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
        cast = function() return ( talent.engulfing_blaze.enabled and 2.5 or 2 ) * ( buff.ancient_flame.up and 0.6 or 1 ) * ( buff.burnout.up and 0 or 1 ) end,
        cooldown = 0,
        color = "red",
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
            if buff.burnout.up then removeStack( "burnout" )
            else removeBuff( "ancient_flame" ) end
            -- Burnout is not consumed.
            if talent.ruby_essence_burst.enabled and buff.dragonrage.up then addStack( "essence_burst", nil, 1 ) end
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
            removeBuff( "leaping_flames" )
            removeBuff( "scarlet_adaptation" )
        end,
    },


    obsidian_scales = {
        id = 363916,
        cast = 0,
        cooldown = function () return talent.obsidian_bulwark.enabled and 90 or 150 end,
        color = "black",
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
        color = "black",
        gcd = "spell",

        talent = "oppressing_roar",
        startsCombat = true,
        texture = 4622466,

        toggle = "interrupts",

        handler = function ()
            applyDebuff( "target", "oppressing_roar" )
            if talent.overawe.enabled and debuff.dispellable_enrage.up then
                removeDebuff( "target", "dispellable_enrage" )
                reduceCooldown( "oppressing_roar", 20 )
            end
        end,
    },


    pyre = {
        id = 357211,
        cast = 0,
        cooldown = 0,
        color = "red",
        gcd = "spell",

        spend = function()
            if buff.essence_burst.up then return 0 end
            return 3 - talent.dense_energy.rank
        end,
        spendType = "essence",

        talent = "pyre",
        startsCombat = false,
        texture = 4622468,

        -- TODO: Need to proc Charged Blast on Blue spells.

        handler = function ()
            if buff.essence_burst.up then
                if talent.feed_the_flames.enabled then reduceCooldown( "fire_breath", 2 ) end
                removeStack( "essence_burst", 1 )
            end
            if talent.causality.enabled then reduceCooldown( "essence_burst", 1 ) end
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
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
        debuff = "casting",

        handler = function ()
            interrupt()
            if talent.roar_of_exhilaration.enabled then gain( 1, "essence" ) end
        end,
    },


    renewing_blaze = {
        id = 374348,
        cast = 0,
        cooldown = function () return talent.fire_within.enabled and 60 or 90 end,
        color = "red",
        gcd = "off",

        talent = "renewing_blaze",
        startsCombat = false,
        texture = 4630463,

        toggle = "defensives",

        -- TODO: o Pyrexia would increase all heals by 20%.

        handler = function ()
            if talent.everburning_flame.enabled and debuff.fire_breath.up then debuff.fire_breath.expires = debuff.fire_breath.expires + 1 end
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

        usable = function() return not solo, "requires an ally" end,

        handler = function ()
            if talent.twin_guardian.enabled then applyBuff( "twin_guardian" ) end
        end,
    },


    action_return = {
        id = 361227,
        cast = 10,
        cooldown = 0,
        color = "bronze",
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
        color = "blue",
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
        color = "blue",
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
        color = "bronze",
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
        color = "blue",
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
        color = "green",
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        talent = "verdant_embrace",
        startsCombat = false,
        texture = 4622471,

        handler = function ()
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
            active_dot.zephyr = min( 5, group_members )
        end,
    },
} )

spec:RegisterPack( "Devastation", 20220906, [[Hekili:nsvttXnoq0)nCGqShpdHeimCyZMdWbQTktoLcBjl32w1il5vFWWSh0V9TLhiwEidvoWGC3TEVx3Q7UiR4HI8AQfkUF5ILlxC5IlswS48vlZkYT7gGI8bkBdTfpiP94V)n8e1yPwUsg8TtOO1bmmkNMH(7S2bZvPPTCBNRkHP6tn8ENy8gmnTXg(MLwjuvP1AARs2i4TD2uq2YLqktqnMYEvTtaMu6Gi8xj8KAdOtyddf5voUWERSO63O8vFz1fOygawX9zNFXNrbXRRH9bdg2SeWt((iS(7839pckd6uIAKLICb3ynJLgOH6ew849JLkkBFM)VoqikYbjTsa1f)vHfLrCadQ9)FweRcrmzjNP5wqZP4jfsTARmzFjb)bs0qpLlnEY1R9KvEYPEslRoPN(8en1CdxAHwDOqGmCESgMW6aD8P4OmDuBqfY2sSUOpi0loqYVElaVIKB3vAC6r87huBbDPvvKNfU4NpAUw5AAIZt3WeSw(qPTdknmk(8hW5lXATHRHYknqTDhOZlpkDyZGquIzwlynjd70GNCJNSm6TcTfWiBX7R5kNwQCwuWEYjEYOnWyajdfLtBSjybKTbFW(ToXhUYXaMywWFku3BeHzRGcM1Kn7XDE6MT8pmFP)NdlzgRMV5n5DSVrqxfZ(mTnJDlwY0aoAxrdtgJg2sX2bzRPi)Hoo2ZoOvnCbsz4JEUbZKwpX4gguARN0O0y3mirjZ8eubYnb16jEYT29xAKHEqwd1yeytQNapb6DbS5kmDXtCjt4W5A0fUVb0xHJYKp6j)8hgiGe0BE8mpzBhN1fhnvUBIvprQcG)8GGZ4wXeU1HtbYHjs)QNO0VsZd7HWtYEmaADSPLrmVLlerz0lqAFn0XQXOjPRVc0bIncLnXF3T9HcwWqgYaB)ARX1tOt8XYz7u4mBoV)BHxLXI(RVHM1JRP839YNFyD6(1sXwIBYoJ3S(D2eD96vN(YgOzi8RaJTEWALyxZ3DC20QJ1zXHnFxqqBVDZrC8rlhMLY40D4YVDpWnlJJlUF)xKnnYFYXg3V(9g1pwLo2E8y4BfAS3Jl4XHWI)p]] )