-- WarlockDestruction.lua
-- November 2022

if UnitClassBase( "player" ) ~= "WARLOCK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local PTR = ns.PTR
local GetSpellInfo, GetSpellTexture = C_Spell.GetSpellInfo, C_Spell.GetSpellTexture

local strformat = string.format


local spec = Hekili:NewSpecialization( 267 )
local GetSpellCount = C_Spell.GetSpellCastCount

spec:RegisterResource( Enum.PowerType.SoulShards, {
    infernal = {
        aura = "infernal",

        last = function ()
            local app = state.buff.infernal.applied
            local t = state.query_time

            return app + floor( ( t - app ) * 2 ) * 0.5
        end,

        interval = 0.5,
        value = 0.1
    },

    chaos_shards = {
        aura = "chaos_shards",

        last = function ()
            local app = state.buff.chaos_shards.applied
            local t = state.query_time

            return app + floor( ( t - app ) * 2 ) * 0.5
        end,

        interval = 0.5,
        value = 0.2,
    },

    immolate = {
        aura = "immolate",
        debuff = true,

        last = function ()
            local app = state.debuff.immolate.applied
            local t = state.query_time
            local tick = state.debuff.immolate.tick_time

            return app + floor( ( t - app ) / tick ) * tick
        end,

        interval = function () return state.debuff.immolate.tick_time end,
        value = 0.1
    },

    blasphemy = {
        aura = "blasphemy",

        last = function ()
            local app = state.buff.blasphemy.applied
            local t = state.query_time

            return app + floor( ( t - app ) * 2 ) * 0.5
        end,

        interval = 0.5,
        value = 0.1
    },
    -- TODO: Summon Overfiend from Avatar of Destruction
}, setmetatable( {
    actual = nil,
    max = nil,
    active_regen = 0,
    inactive_regen = 0,
    forecast = {},
    times = {},
    values = {},
    fcount = 0,
    regen = 0,
    regenerates = false,
}, {
    __index = function( t, k )
        if k == 'count' or k == 'current' then return t.actual

        elseif k == 'actual' then
            t.actual = UnitPower( "player", Enum.PowerType.SoulShards, true ) / 10
            return t.actual

        elseif k == 'max' then
            t.max = UnitPowerMax( "player", Enum.PowerType.SoulShards, true ) / 10
            return t.max

        else
            local amount = k:match( "time_to_(%d+)" )
            amount = amount and tonumber( amount )

            if amount then return state:TimeToResource( t, amount ) end
        end
    end
} ) )

spec:RegisterResource( Enum.PowerType.Mana )


-- Talents
spec:RegisterTalents( {
    -- Warlock
    abyss_walker                   = {  71954, 389609, 1 }, -- Using Demonic Circle: Teleport or your Demonic Gateway reduces all damage you take by 4% for 10 sec.
    accrued_vitality               = {  71953, 386613, 2 }, -- Drain Life heals for 15% of the amount drained over 7.0 sec.
    amplify_curse                  = {  71934, 328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within 15 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional 20%. Curse of Tongues Increases casting time by an additional 40%. Curse of Weakness Enemy is unable to critically strike.
    banish                         = {  71944,    710, 1 }, -- Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect.
    burning_rush                   = {  71949, 111400, 1 }, -- Increases your movement speed by 50%, but also damages you for 4% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until canceled.
    curses_of_enfeeblement         = {  71951, 386105, 1 }, -- Grants access to the following abilities: Curse of Tongues: Forces the target to speak in Demonic, increasing the casting time of all spells by 30% for 1 min. Curses: A warlock can only have one Curse active per target. Curse of Exhaustion: Reduces the target's movement speed by 50% for 12 sec. Curses: A warlock can only have one Curse active per target.
    dark_accord                    = {  71956, 386659, 1 }, -- Reduces the cooldown of Unending Resolve by 45 sec.
    dark_pact                      = {  71936, 108416, 1 }, -- Sacrifices 5% of your current health to shield you for 800% of the sacrificed health plus an additional 38,162 for 20 sec. Usable while suffering from control impairing effects.
    darkfury                       = {  71941, 264874, 1 }, -- Reduces the cooldown of Shadowfury by 15 sec and increases its radius by 2 yards.
    demon_skin                     = {  71952, 219272, 2 }, -- Your Soul Leech absorption now passively recharges at a rate of 0.2% of maximum health every 1 sec, and may now absorb up to 10% of maximum health. Increases your armor by 45%.
    demonic_circle                 = { 100941, 268358, 1 }, -- Summons a Demonic Circle for 15 min. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects. You also learn:  Demonic Circle: Teleport Teleports you to your Demonic Circle and removes all movement slowing effects.
    demonic_embrace                = {  71930, 288843, 1 }, -- Stamina increased by 10%.
    demonic_fortitude              = {  71922, 386617, 1 }, -- Increases you and your pets' maximum health by 5%.
    demonic_gateway                = {  71955, 111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per 90 sec.
    demonic_inspiration            = {  71928, 386858, 1 }, -- Increases the attack speed of your primary pet by 5%. Increases Grimoire of Sacrifice damage by 10%.
    demonic_resilience             = {  71917, 389590, 2 }, -- Reduces the chance you will be critically struck by 2%. All damage your primary demon takes is reduced by 8%.
    demonic_tactics                = {  71925, 452894, 1 }, -- Your spells have a 5% increased chance to deal a critical strike. You gain 10% more of the Critical Strike stat from all sources.
    fel_armor                      = {  71950, 386124, 2 }, -- When Soul Leech absorbs damage, 5% of damage taken is absorbed and spread out over 5 sec. Reduces damage taken by 1.5%.
    fel_domination                 = {  71931, 333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by 90%.
    fel_pact                       = {  71932, 386113, 1 }, -- Reduces the cooldown of Fel Domination by 60 sec.
    fel_synergy                    = {  71924, 389367, 2 }, -- Soul Leech also heals you for 8% and your pet for 25% of the absorption it grants.
    fiendish_stride                = {  71948, 386110, 1 }, -- Reduces the damage dealt by Burning Rush by 10%. Burning Rush increases your movement speed by an additional 20%.
    frequent_donor                 = {  71937, 386686, 1 }, -- Reduces the cooldown of Dark Pact by 15 sec.
    horrify                        = {  71916,  56244, 1 }, -- Your Fear causes the target to tremble in place instead of fleeing in fear.
    howl_of_terror                 = {  71947,   5484, 1 }, -- Let loose a terrifying howl, causing 5 enemies within 10 yds to flee in fear, disorienting them for 20 sec. Damage may cancel the effect.
    ichor_of_devils                = {  71937, 386664, 1 }, -- Dark Pact sacrifices only 5% of your current health for the same shield value.
    lifeblood                      = {  71940, 386646, 2 }, -- When you use a Healthstone, gain 4% Leech for 20 sec.
    mortal_coil                    = {  71947,   6789, 1 }, -- Horrifies an enemy target into fleeing, incapacitating for 3 sec and healing you for 20% of maximum health.
    nightmare                      = {  71916, 386648, 1 }, -- Increases the amount of damage required to break your fear effects by 60%.
    pact_of_gluttony               = {  71926, 386689, 1 }, -- Healthstones you conjure for yourself are now Demonic Healthstones and can be used multiple times in combat. Demonic Healthstones cannot be traded.  Demonic Healthstone 60 sec cooldown.
    resolute_barrier               = {  71915, 389359, 2 }, -- Attacks received that deal at least 5% of your health decrease Unending Resolve's cooldown by 10 sec. Cannot occur more than once every 30 sec.
    sargerei_technique             = {  93179, 405955, 2 }, -- Incinerate damage increased by 5%.
    shadowflame                    = {  71941, 384069, 1 }, -- Slows enemies in a 12 yard cone in front of you by 70% for 6 sec.
    shadowfury                     = {  71942,  30283, 1 }, -- Stuns all enemies within 8 yds for 3 sec.
    socrethars_guile               = {  93178, 405936, 2 }, -- Immolate damage increased by 10%.
    soul_conduit                   = {  71939, 215941, 1 }, -- Every Soul Shard you spend has a 5% chance to be refunded.
    soul_leech                     = {  71933, 108370, 1 }, -- All single-target damage done by you and your minions grants you and your pet shadowy shields that absorb 3% of the damage dealt, up to 10% of maximum health.
    soul_link                      = {  71923, 108415, 2 }, -- 5% of all damage you take is taken by your demon pet instead. While Grimoire of Sacrifice is active, your Stamina is increased by 3%.
    soulburn                       = {  71957, 385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells. Demonic Circle: Teleport: Increases your movement speed by 50% and makes you immune to snares and roots for 6 sec. Demonic Gateway: Can be cast instantly. Drain Life: Gain an absorb shield equal to the amount of healing done for 30 sec. This shield cannot exceed 30% of your maximum health. Health Funnel: Restores 140% more health and reduces the damage taken by your pet by 30% for 10 sec. Healthstone: Increases the healing of your Healthstone by 30% and increases your maximum health by 20% for 12 sec.
    strength_of_will               = {  71956, 317138, 1 }, -- Unending Resolve reduces damage taken by an additional 15%.
    sweet_souls                    = {  71927, 386620, 1 }, -- Your Healthstone heals you for an additional 10% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount.
    swift_artifice                 = {  71918, 452902, 1 }, -- Reduces the cast time of Soulstone and Create Healthstone by 50%.
    teachings_of_the_black_harvest = {  71938, 385881, 1 }, -- Your primary pets gain a bonus effect. Imp: Successful Singe Magic casts grant the target 4% damage reduction for 5 sec. Voidwalker: Reduces the cooldown of Shadow Bulwark by 30 sec. Felhunter: Reduces the cooldown of Devour Magic by 5 sec. Sayaad: Reduces the cooldown of Seduction by 10 sec and causes the target to walk faster towards the demon.
    teachings_of_the_satyr         = {  71935, 387972, 1 }, -- Reduces the cooldown of Amplify Curse by 15 sec.
    wrathful_minion                = {  71946, 386864, 1 }, -- Increases the damage done by your primary pet by 5%. Increases Grimoire of Sacrifice damage by 10%.

    -- Destruction
    ashen_remains                  = {  71969, 387252, 1 }, -- Chaos Bolt, Shadowburn, and Incinerate deal 5% increased damage to targets afflicted by Wither.
    avatar_of_destruction          = { 101998, 456975, 1 }, -- Consuming Ritual of Ruin summons an Overfiend for 8 sec.  Summon Overfiend
    backdraft                      = {  72067, 196406, 1 }, -- Conflagrate reduces the cast time of your next Incinerate, Chaos Bolt, or Soul Fire by 30%. Maximum 2 charges.
    backlash                       = {  71983, 387384, 1 }, -- Increases your critical strike chance by 3%. Physical attacks against you have a 25% chance to make your next Incinerate instant cast. This effect can only occur once every 6 sec.
    blistering_atrophy             = { 101996, 456939, 1 }, -- Increases the damage of Shadowburn by 20%. The critical strike chance of Shadowburn is increased by an additional 50% when damaging a target that is at or below 30% health.
    burn_to_ashes                  = {  71964, 387153, 1 }, -- Chaos Bolt and Rain of Fire increase the damage of your next 2 Incinerates by 15%. Shadowburn increases the damage of your next Incinerate by 15%. Stacks up to 6 times.
    cataclysm                      = {  71974, 152108, 1 }, -- Calls forth a cataclysm at the target location, dealing 48,643 Shadowflame damage to all enemies within 8 yards and afflicting them with Wither.
    channel_demonfire              = {  72064, 196447, 1 }, -- Launches 17 bolts of felfire over 1.4 sec at random targets afflicted by your Wither within 40 yds. Each bolt deals 6,584 Fire damage to the target and 3,273 Fire damage to nearby enemies.
    chaos_incarnate                = {  71966, 387275, 1 }, -- Chaos Bolt, Rain of Fire, and Shadowburn always gain at least 70% of the maximum benefit from your Mastery: Chaotic Energies.
    conflagrate                    = {  72068,  17962, 1 }, -- Triggers an explosion on the target, dealing 30,399 Fire damage. Reduces the cast time of your next Incinerate or Chaos Bolt by 30% for 10 sec. Generates 5 Soul Shard Fragments.
    conflagration_of_chaos         = {  72061, 387108, 1 }, -- Conflagrate and Shadowburn have a 50% chance to guarantee your next cast of the ability to critically strike, and increase its damage by your critical strike chance.
    crashing_chaos                 = {  71960, 417234, 1 }, -- Summon Infernal increases the damage of your next 8 casts of Chaos Bolt by 25% or your next 8 casts of Rain of Fire by 35%.
    decimation                     = { 101997, 456985, 1 }, -- When your direct damaging abilities deal a critical strike, they have a chance to reset the cooldown of Soul Fire and reduce the cast time of your next Soul Fire by 80%.
    demonfire_mastery              = { 101993, 456946, 1 }, -- Increases the damage of Channel Demonfire by 30% and it deals damage 35% faster.
    devastation                    = {  72066, 454735, 1 }, -- Increases the critical strike chance of your Destruction spells by 5%.
    diabolic_embers                = {  71968, 387173, 1 }, -- Incinerate now generates 100% additional Soul Shard Fragments.
    dimension_ripper               = { 102002, 457025, 1 }, -- Incinerate has a chance to tear open a Dimensional Rift or recharge Dimensional Rift if learned.
    dimensional_rift               = { 102003, 387976, 1 }, -- Rips a hole in time and space, opening a random portal that damages your target: Shadowy Tear Deals 133,467 Shadow damage over 14 sec. Unstable Tear Deals 114,729 Chaos damage over 6 sec. Chaos Tear Fires a Chaos Bolt, dealing 41,193 Chaos damage. This Chaos Bolt always critically strikes and your critical strike chance increases its damage. Generates 3 Soul Shard Fragments.
    emberstorm                     = {  72062, 454744, 1 }, -- Increases the damage done by your Fire spells by 2% and reduces the cast time of your Incinerate spell by 20%.
    eradication                    = {  71984, 196412, 1 }, -- Chaos Bolt and Shadowburn increases the damage you deal to the target by 5% for 7 sec.
    explosive_potential            = {  72059, 388827, 1 }, -- Reduces the cooldown of Conflagrate by 2 sec.
    fiendish_cruelty               = { 101994, 456943, 1 }, -- When Shadowburn fails to kill a target that is at or below 30% health, its cooldown is reduced by 5 sec.
    fire_and_brimstone             = {  71982, 196408, 1 }, -- Incinerate now also hits all enemies near your target for 25% damage.
    flashpoint                     = {  71972, 387259, 1 }, -- When your Wither deals periodic damage to a target above 80% health, gain 2% Haste for 10 sec. Stacks up to 3 times.
    grimoire_of_sacrifice          = {  71971, 108503, 1 }, -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal 7,948 additional Shadow damage. Lasts until canceled or until you summon a demon pet.
    havoc                          = {  71979,  80240, 1 }, -- Marks a target with Havoc for 12 sec, causing your single target spells to also strike the Havoc victim for 60% of the damage dealt.
    improved_chaos_bolt            = { 101992, 456951, 1 }, -- Increases the damage of Chaos Bolt by 10% and reduces its cast time by 0.5 sec.
    improved_conflagrate           = {  72065, 231793, 1 }, -- Conflagrate gains an additional charge.
    indiscriminate_flames          = { 101995, 457114, 1 }, -- Backdraft increases the damage of your next Chaos Bolt by 5% and increases the critical strike chance of your next Incinerate or Soul Fire by 35%.
    inferno                        = {  71974, 270545, 1 }, -- Rain of Fire damage is increased by 20% and its Soul Shard cost is reduced by 1.
    internal_combustion            = {  71980, 266134, 1 }, -- Chaos Bolt consumes up to 5 sec of Wither's damage over time effect on your target, instantly dealing that much damage.
    master_ritualist               = {  71962, 387165, 1 }, -- Ritual of Ruin requires 5 less Soul Shards spent.
    mayhem                         = {  71979, 387506, 1 }, -- Your single target spells have a 25% chance to apply Havoc to a nearby enemy for 5.0 sec.  Havoc Marks a target with Havoc for 5.0 sec, causing your single target spells to also strike the Havoc victim for 60% of the damage dealt.
    power_overwhelming             = {  71965, 387279, 1 }, -- Consuming Soul Shards increases your Mastery by 0.5% for 10 sec for each shard spent. Gaining a stack does not refresh the duration.
    pyrogenics                     = {  71975, 387095, 1 }, -- Enemies affected by your Rain of Fire take 3% increased damage from your Fire spells.
    raging_demonfire               = {  72063, 387166, 1 }, -- Channel Demonfire fires an additional 2 bolts. Each bolt increases the remaining duration of Wither on all targets hit by 0.5 sec.
    rain_of_chaos                  = {  71960, 266086, 1 }, -- While your initial Infernal is active, every Soul Shard you spend has a 15% chance to summon an additional Infernal that lasts 8 sec.
    rain_of_fire                   = {  72069,   5740, 1 }, -- Calls down a rain of hellfire, dealing 48,129 Fire damage over 5.6 sec to enemies in the area.
    reverse_entropy                = {  71980, 205148, 1 }, -- Your spells have a chance to grant you 15% Haste for 8 sec.
    ritual_of_ruin                 = {  71970, 387156, 1 }, -- Every 15 Soul Shards spent grants Ritual of Ruin, making your next Chaos Bolt or Rain of Fire consume no Soul Shards and have its cast time reduced by 50%.
    roaring_blaze                  = {  72065, 205184, 1 }, -- Conflagrate increases your Channel Demonfire, Wither, Incinerate, and Conflagrate damage to the target by 25% for 8 sec.
    rolling_havoc                  = {  71961, 387569, 1 }, -- Each time your spells duplicate from Havoc, gain 1% increased damage for 6 sec. Stacks up to 5 times.
    ruin                           = {  71967, 387103, 1 }, -- Increases the critical strike damage of your Destruction spells by 5%.
    scalding_flames                = {  71973, 388832, 1 }, -- Increases the damage of Wither by 25% and its duration by 3 sec.
    shadowburn                     = {  72060,  17877, 1 }, -- Blasts a target for 43,874 Shadowflame damage, gaining 50% critical strike chance on targets that have 20% or less health. Restores 1 Soul Shard and refunds a charge if the target dies within 5 sec.
    soul_fire                      = {  71978,   6353, 1 }, -- Burns the enemy's soul, dealing 85,807 Fire damage and applying Wither. Generates 1 Soul Shard.
    summon_infernal                = {  71985,   1122, 1 }, -- Summons an Infernal from the Twisting Nether, impacting for 9,799 Fire damage and stunning all enemies in the area for 2 sec. The Infernal will serve you for 30 sec, dealing 9,431 damage to all nearby enemies every 1.4 sec and generating 1 Soul Shard Fragment every 1 sec.
    summoners_embrace              = {  71971, 453105, 1 }, -- Increases the damage dealt by your spells and your demon by 3%.
    unstable_rifts                 = { 102427, 457064, 1 }, -- Bolts from Dimensional Rift now deal 25% of damage dealt to nearby enemies as Fire damage.

    -- Diabolist
    abyssal_dominion               = {  94831, 429581, 1 }, -- Summon Infernal becomes empowered, dealing 40% increased damage. When your Summon Infernal ends, it fragments into two smaller Infernals at 50% effectiveness that lasts 10 sec.
    annihilans_bellow              = {  94836, 429072, 1 }, -- Howl of Terror cooldown is reduced by 15 sec and range is increased by 5 yds.
    cloven_souls                   = {  94849, 428517, 1 }, -- Enemies damaged by your Overlord have their souls cloven, increasing damage taken by you and your pets by 5% for 15 sec.
    cruelty_of_kerxan              = {  94848, 429902, 1 }, -- Summon Infernal grants Diabolic Ritual and reduces its duration by 3 sec.
    diabolic_ritual                = {  94855, 428514, 1, "diabolist" }, -- Spenabolic Ritual is active, each Soul Shard spent on a damaging spell reduces its duration by 1 sec. When Diabolic Ritual expires you gain Demonic Art, causing your next Chaos Bolt, Rain of Fire, or Shadowburn to summon an Overlord, Mother of Chaos, or Pit Lord that unleashes a devastating attack against your enemies.
    flames_of_xoroth               = {  94833, 429657, 1 }, -- Fire damage increased by 2% and damage dealt by your demons is increased by 2%.
    gloom_of_nathreza              = {  94843, 429899, 1 }, -- Enemies marked by your Havoc take 5% increased damage from your single target spells.
    infernal_bulwark               = {  94852, 429130, 1 }, -- Unending Resolve grants Soul Leech equal to 10% of your maximum health and increases the maximum amount Soul Leech can absorb by 10% for 8 sec.
    infernal_machine               = {  94848, 429917, 1 }, -- Spending Soul Shards on damaging spells while your Infernal is active decreases the duration of Diabolic Ritual by 1 additional sec.
    infernal_vitality              = {  94852, 429115, 1 }, -- Unending Resolve heals you for 30% of your maximum health over 10 sec.
    ruination                      = {  94830, 428522, 1 }, -- Summoning a Pit Lord causes your next Chaos Bolt to become Ruination.  Ruination Call down a demon-infested meteor from the depths of the Twisting Nether, dealing 199,229 Chaos damage on impact to all enemies within 8 yds of the target and summoning 1 Diabolic Imp. Damage is further increased by your critical strike chance and is reduced beyond 8 targets.
    secrets_of_the_coven           = {  94826, 428518, 1 }, -- Mother of Chaos empowers your next Incinerate to become Infernal Bolt.  Infernal Bolt Hurl a bolt enveloped in the infernal flames of the abyss, dealing 79,242 Fire damage to your enemy target and generating 2 Soul Shards.
    souletched_circles             = {  94836, 428911, 1 }, -- You always gain the benefit of Soulburn when casting Demonic Circle: Teleport, increasing your movement speed by 50% and making you immune to snares and roots for 6 sec.
    touch_of_rancora               = {  94856, 429893, 1 }, -- Demonic Art increases the damage of your next Chaos Bolt, Rain of Fire, or Shadowburn by 100% and reduces its cast time by 50%.

    -- Hellcaller
    aura_of_enfeeblement           = {  94822, 440059, 1 }, -- While Unending Resolve is active, enemies within 30 yds are affected by Curse of Tongues and Curse of Weakness at 100% effectiveness.
    blackened_soul                 = {  94837, 440043, 1 }, -- Spending Soul Shards on damaging spells will further corrupt enemies affected by your Wither, increasing its stack count by 1. Each time Wither gains a stack it has a chance to collapse, consuming a stack every 1 sec to deal 15,098 Shadowflame damage to its host until 1 stack remains.
    bleakheart_tactics             = {  94854, 440051, 1 }, -- Wither damage increased 20%. When Wither gains a stack from Blackened Soul, it has a chance to gain an additional stack.
    curse_of_the_satyr             = {  94822, 440057, 1 }, -- Curse of Weakness is empowered and transforms into Curse of the Satyr.  Curse of the Satyr
    hatefury_rituals               = {  94854, 440048, 1 }, -- Wither deals 30% increased periodic damage but its duration is 15% shorter.
    illhoofs_design                = {  94835, 440070, 1 }, -- Sacrifice 10% of your maximum health. Soul Leech now absorbs an additional 15% of your maximum health.
    malevolence                    = {  94842, 442726, 1 }, -- Dark magic erupts from you and corrupts your soul for 20 sec, causing enemies suffering from your Wither to take 58,822 Shadowflame damage and increase its stack count by 6. While corrupted your Haste is increased by 8% and spending Soul Shards on damaging spells grants 1 additional stack of Wither.
    mark_of_perotharn              = {  94844, 440045, 1 }, -- Critical strike damage dealt by Wither is increased by 10%. Wither has a chance to gain a stack when it critically strikes. Stacks gained this way do not activate Blackened Soul.
    mark_of_xavius                 = {  94834, 440046, 1 }, -- Wither damage increased by 25%. Blackened Soul deals 2% increased damage per stack of Wither.
    seeds_of_their_demise          = {  94829, 440055, 1 }, -- After Wither reaches 8 stacks or when its host reaches 20% health, Wither deals 15,098 Shadowflame damage to its host every 1 sec until 1 stack remains. When Blackened Soul deals damage, you have a chance to gain 2 stacks of Flashpoint.
    wither                         = {  94840, 445468, 1, "hellcaller" }, -- Bestows a vile malediction upon the target, burning the sinew and muscle of its host, dealing 4,288 Shadowflame damage immediately and an additional 107,157 Shadowflame damage over 21 sec. Periodic damage generates 1 Soul Shard Fragment and has a 50% chance to generate an additional 1 on critical strikes. Replaces Immolate.
    xalans_cruelty                 = {  94845, 440040, 1 }, -- Shadow damage dealt by your spells and abilities is increased by 2% and your Shadow spells gain 10% more critical strike chance from all sources.
    xalans_ferocity                = {  94853, 440044, 1 }, -- Fire damage dealt by your spells and abilities is increased by 2% and your Fire spells gain 10% more critical strike chance from all sources.
    zevrims_resilience             = {  94835, 440065, 1 }, -- Dark Pact heals you for 26,879 every 1 sec while active.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bane_of_havoc    =  164, -- (461917)
    bonds_of_fel     = 5401, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the 8 yd radius they explode, dealing 74,083 Fire damage split amongst all nearby enemies.
    call_observer    = 5544, -- (201996) Summons a demonic Observer to keep a watchful eye over the area for 20 sec. Anytime an enemy within 30 yards casts a harmful magical spell, the Observer will deal up to 8% of the target's maximum health in Shadow damage.
    fel_fissure      =  157, -- (200586)
    gateway_mastery  = 5382, -- (248855)
    impish_instincts = 5580, -- (409835)
    nether_ward      = 3508, -- (212295) Surrounds the caster with a shield that lasts 3 sec, reflecting all harmful spells cast on you.
    shadow_rift      = 5393, -- (353294) Conjure a Shadow Rift at the target location lasting 2 sec. Enemy players within the rift when it expires are teleported to your Demonic Circle. Must be within 40 yds of your Demonic Circle to cast.
    soul_rip         = 5607, -- (410598) Fracture the soul of up to 3 target players within 20 yds into the shadows, reducing their damage done by 25% and healing received by 25% for 8 sec. Souls are fractured up to 20 yds from the player's location. Players can retrieve their souls to remove this effect.
} )


-- Auras
spec:RegisterAuras( {
    active_havoc = {
        duration = function () return class.auras.havoc.duration end,
        max_stack = 1,

        generate = function( ah )
            ah.duration = class.auras.havoc.duration

            if pvptalent.bane_of_havoc.enabled and debuff.bane_of_havoc.up and query_time - last_havoc < ah.duration then
                ah.count = 1
                ah.applied = last_havoc
                ah.expires = last_havoc + ah.duration
                ah.caster = "player"
                return
            elseif not pvptalent.bane_of_havoc.enabled and active_dot.havoc > 0 and query_time - last_havoc < ah.duration then
                ah.count = 1
                ah.applied = last_havoc
                ah.expires = last_havoc + ah.duration
                ah.caster = "player"
                return
            end

            ah.count = 0
            ah.applied = 0
            ah.expires = 0
            ah.caster = "nobody"
        end
    },
    -- Going to need to keep an eye on this.  active_dot.bane_of_havoc won't work due to no SPELL_AURA_APPLIED event.
    bane_of_havoc = {
        id = 200548,
        duration = function () return level > 53 and 12 or 10 end,
        max_stack = 1,
        generate = function( boh )
            boh.applied = action.bane_of_havoc.lastCast
            boh.expires = boh.applied > 0 and ( boh.applied + boh.duration ) or 0
        end,
    },

    accrued_vitality = {
        id = 386614,
        duration = 10,
        max_stack = 1,
        copy = 339298
    },
    -- Talent: Next Curse of Tongues, Curse of Exhaustion or Curse of Weakness is amplified.
    -- https://wowhead.com/beta/spell=328774
    amplify_curse = {
        id = 328774,
        duration = 15,
        max_stack = 1
    },
    -- Time between attacks increased $w1% and casting speed increased by $w2%.
    aura_of_enfeeblement = {
        id = 449587,
        duration = 8.0,
        max_stack = 1,
    },
    backdraft = {
        id = 117828,
        duration = 10,
        type = "Magic",
        max_stack = 2,
    },
    -- Talent: Your next Incinerate is instant cast.
    -- https://wowhead.com/beta/spell=387385
    backlash = {
        id = 387385,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Invulnerable, but unable to act.
    -- https://wowhead.com/beta/spell=710
    banish = {
        id = 710,
        duration = 30,
        mechanic = "banish",
        type = "Magic",
        max_stack = 1
    },
    blasphemy = {
        id = 367680,
        duration = 8,
        max_stack = 1,
    },
    -- Talent: Incinerate damage increased by $w1%.
    -- https://wowhead.com/beta/spell=387154
    burn_to_ashes = {
        id = 387154,
        duration = 20,
        max_stack = 6
    },
    -- Talent: Movement speed increased by $s1%.
    -- https://wowhead.com/beta/spell=111400
    burning_rush = {
        id = 111400,
        duration = 3600,
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=196447
    channel_demonfire = {
        id = 196447,
        duration = function() return 3 * ( 1 - 0.35 * talent.demonfire_mastery.rank ) * haste end,
        tick_time = function() return 3 * ( 1 - 0.35 * talent.demonfire_mastery.rank ) * ( 1 - 0.12 * talent.raging_demonfire.rank ) * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Damage taken from you and your pets is increased by $s1%.
    cloven_soul = {
        id = 434424,
        duration = 15.0,
        max_stack = 1
    },
    conflagrate = {
        id = 265931,
        duration = 8,
        type = "Magic",
        max_stack = 1,
        copy = "roaring_blaze"
    },
    conflagration_of_chaos_cf = {
        id = 387109,
        duration = 20,
        max_stack = 1
    },
    conflagration_of_chaos_sb = {
        id = 387110,
        duration = 20,
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=146739
    corruption = {
        id = 146739,
        duration = 14,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    crashing_chaos = {
        id = 417282,
        duration = 45,
        max_stack = 8,
    },
    -- Movement speed slowed by $w1%.
    -- https://wowhead.com/beta/spell=334275
    curse_of_exhaustion = {
        id = 334275,
        duration = 12,
        mechanic = "snare",
        type = "Magic",
        max_stack = 1
    },
    -- Speaking Demonic increasing casting time by $w1%.
    -- https://wowhead.com/beta/spell=1714
    curse_of_tongues = {
        id = 1714,
        duration = 60,
        type = "Magic",
        max_stack = 1
    },
    -- Time between attacks increased by $w1%. $?e1[Chance to critically strike reduced by $w2%.][]
    -- https://wowhead.com/beta/spell=702
    curse_of_weakness = {
        id = 702,
        duration = 120,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=108416
    dark_pact = {
        id = 108416,
        duration = 20,
        max_stack = 1
    },
    -- Damage of $?s137046[Incinerate]?s198590[Drain Soul]?a137044&!s137046[Demonbolt][Shadow Bolt] increased by $w2%.
    -- https://wowhead.com/beta/spell=325299
    decimating_bolt = {
        id = 325299,
        duration = 45,
        type = "Magic",
        max_stack = 3
    },
    -- The cast time of your next Soul Fire is reduced by $s1%.
    decimation = {
        id = 457555,
        duration = 10.0,
        max_stack = 1,
    },
    demonic_art_overlord = {
        id = 428524,
        duration = 60,
        max_stack = 1,
        copy = "art_overlord",
    },
    demonic_art_mother_of_chaos = {
        id = 432794,
        duration = 60,
        max_stack = 1,
        copy = "art_mother",
    },
    demonic_art_pit_lord = {
        id = 432795,
        duration = 60,
        max_stack = 1,
        copy = "art_pit_lord",
    },
    demonic_art = {
        alias = { "demonic_art_overlord", "demonic_art_mother_of_chaos", "demonic_art_pit_lord" },
        aliasMode = "first",
        aliasType = "buff"
    },
    -- [428524] Your next Soul Shard spent summons an Overlord that unleashes a devastating attack.
    diabolic_ritual_overlord = {
        id = 431944,
        duration = 20.0,
        max_stack = 1,
        copy = "ritual_overlord"
    },
    diabolic_ritual_mother_of_chaos = {
        id = 432815,
        duration = 20.0,
        max_stack = 1,
        copy = "ritual_mother"
    },
    diabolic_ritual_pit_lord = {
        id = 432816,
        duration = 20.0,
        max_stack = 1,
        copy = "ritual_pit_lord"
    },
    diabolic_ritual = {
        alias = { "diabolic_ritual_overlord", "diabolic_ritual_mother_of_chaos", "diabolic_ritual_pit_lord" },
        aliasMode = "first",
        aliasType = "buff"
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=268358
    demonic_circle = {
        id = 268358,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Attack speed increased by $w1%.
    -- https://wowhead.com/beta/spell=386861
    demonic_inspiration = {
        id = 386861,
        duration = 8,
        max_stack = 1,
        generate = function( t )
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 386861 )

            if name then
                t.name = name
                t.count = count
                t.expires = expires
                t.applied = expires - duration
                t.caster = caster
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    -- Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=339412
    demonic_momentum = {
        id = 339412,
        duration = 5,
        max_stack = 1
    },
    -- Damage done increased by $w2%.
    -- https://wowhead.com/beta/spell=171982
    demonic_synergy = {
        id = 171982,
        duration = 15,
        max_stack = 1
    },
    -- Doomed to take $w1 Shadow damage.
    -- https://wowhead.com/beta/spell=603
    doom = {
        id = 603,
        duration = 20,
        tick_time = 20,
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $s1 Shadow damage every $t1 seconds.  Restoring health to the Warlock.
    -- https://wowhead.com/beta/spell=234153
    drain_life = {
        id = 234153,
        duration = function () return 5 * haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
        tick_time = function () return haste * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=198590
    drain_soul = {
        id = 198590,
        duration = 5,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Healing for $m1% of maximum health every $t1 sec.; Spell casts are not delayed by taking damage.
    empowered_healthstone = {
        id = 262080,
        duration = 6.0,
        max_stack = 1,
    },
    -- Talent: Damage taken from the Warlock increased by $s1%.
    -- https://wowhead.com/beta/spell=196414
    eradication = {
        id = 196414,
        duration = 7,
        max_stack = 1
    },
    -- Controlling Eye of Kilrogg.  Detecting Invisibility.
    -- https://wowhead.com/beta/spell=126
    eye_of_kilrogg = {
        id = 126,
        duration = 45,
        type = "Magic",
        max_stack = 1
    },
    -- $w1 damage is being delayed every $387846t1 sec.; Damage Remaining: $w2
    fel_armor = {
        id = 387847,
        duration = 5,
        max_stack = 1,
        copy = 387846
    },
    -- Talent: Imp, Voidwalker, Succubus, Felhunter, or Felguard casting time reduced by $/1000;S1 sec.
    -- https://wowhead.com/beta/spell=333889
    fel_domination = {
        id = 333889,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Haste increased by $w1%.
    -- https://wowhead.com/beta/spell=387263
    flashpoint = {
        id = 387263,
        duration = 10,
        max_stack = 3
    },
    -- Talent: Sacrificed your demon pet to gain its command demon ability.    Your spells sometimes deal additional Shadow damage.
    -- https://wowhead.com/beta/spell=196099
    grimoire_of_sacrifice = {
        id = 196099,
        duration = 3600,
        max_stack = 1
    },
    -- Taking $s2% increased damage from the Warlock. Haunt's cooldown will be reset on death.
    -- https://wowhead.com/beta/spell=48181
    haunt = {
        id = 48181,
        duration = 18,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Spells cast by the Warlock also hit this target for $s1% of normal initial damage.
    -- https://wowhead.com/beta/spell=80240
    havoc = {
        id = 80240,
        duration = function()
            if talent.mayhem.enabled then return 5 end
            return talent.pandemonium.enabled and 15 or 12
        end,
        type = "Magic",
        max_stack = 1
    },
    -- Transferring health.
    -- https://wowhead.com/beta/spell=755
    health_funnel = {
        id = 755,
        duration = 5,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=5484
    howl_of_terror = {
        id = 5484,
        duration = 20,
        mechanic = "flee",
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $w1 Fire damage every $t1 sec.$?a339892[   Damage taken by Chaos Bolt and Incinerate increased by $w2%.][]
    -- https://wowhead.com/beta/spell=157736
    immolate = {
        id = 157736,
        duration = function() return ( 18 + 3 * talent.scalding_flames.rank ) * haste end,
        tick_time = function() return 3 * haste end,
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=322170
    impending_catastrophe = {
        id = 322170,
        duration = 12,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Every $s1 Soul Shards spent grants Ritual of Ruin, making your next Chaos Bolt or Rain of Fire consume no Soul Shards and have its cast time reduced by $387157s3%.
    -- https://wowhead.com/beta/spell=387158
    impending_ruin = {
        id = 387158,
        duration = 3600,
        max_stack = 15
    },
    infernal = {
        duration = 30,
        generate = function( inf )
            if pet.infernal.alive then
                inf.count = 1
                inf.applied = pet.infernal.expires - 30
                inf.expires = pet.infernal.expires
                inf.caster = "player"
                return
            end

            inf.count = 0
            inf.applied = 0
            inf.expires = 0
            inf.caster = "nobody"
        end,
    },
    infernal_awakening = {
        id = 22703,
        duration = 2,
        max_stack = 1,
    },
    infernal_bolt = {
        id = 433891,
        duration = 20,
        max_stack = 1
    },
    -- Soul Leech can absorb an additional $s1% of your maximum health.
    infernal_bulwark = {
        id = 434561,
        duration = 8.0,
        max_stack = 1,
    },
    -- Healing for ${$s1*($d/$t1)}% of your maximum health over $d.
    infernal_vitality = {
        id = 434559,
        duration = 10.0,
        max_stack = 1,
    },
    -- Inflicts Shadow damage.
    laserbeam = {
        id = 212529,
        duration = 0.0,
        max_stack = 1,
    },
    -- Talent: Leech increased by $w1%.
    -- https://wowhead.com/beta/spell=386647
    lifeblood = {
        id = 386647,
        duration = 20,
        max_stack = 1
    },
    -- Haste increased by $w1% and $?s324536[Malefic Rapture grants $w2 additional stack of Wither to targets affected by Unstable Affliction.][Chaos Bolt grants $w3 additional stack of Wither.]; All of your active Withers are acute.
    malevolence = {
        id = 442726,
        duration = 20.0,
        max_stack = 1,
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=6789
    mortal_coil = {
        id = 6789,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Reflecting all spells.
    -- https://wowhead.com/beta/spell=212295
    nether_ward = {
        id = 212295,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Movement speed increased by $s3%.
    -- https://wowhead.com/beta/spell=30151
    pursuit = {
        id = 30151,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Fire damage taken increased by $s1%.
    -- https://wowhead.com/beta/spell=387096
    pyrogenics = {
        id = 387096,
        duration = 2,
        type = "Magic",
        max_stack = 1
    },
    rain_of_chaos = {
        id = 266087,
        duration = 30,
        max_stack = 1
    },
    -- Talent: $42223s1 Fire damage every $5740t2 sec.
    -- https://wowhead.com/beta/spell=5740
    rain_of_fire = {
        id = 5740,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Haste increased by $s1%.
    -- https://wowhead.com/beta/spell=266030
    reverse_entropy = {
        id = 266030,
        duration = 8,
        type = "Magic",
        max_stack = 1
    },
    ritual_overlord = {

    },
    ritual_mother = {

    },
    ritual_pit_lord = {},
    -- Your next Chaos Bolt or Rain of Fire cost no Soul Shards and has its cast time reduced by 50%.
    ritual_of_ruin = {
        id = 387157,
        duration = 30,
        max_stack = 1
    },
    --
    -- https://wowhead.com/beta/spell=698
    ritual_of_summoning = {
        id = 698,
        duration = 120,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage increased by $W1%.
    -- https://wowhead.com/beta/spell=387570
    rolling_havoc = {
        id = 387570,
        duration = 6,
        max_stack = 5
    },
    ruination = {
        id = 433885,
        duration = 20,
        max_stack = 1
    },
    -- Covenant: Suffering $w2 Arcane damage every $t2 sec.
    -- https://wowhead.com/beta/spell=312321
    scouring_tithe = {
        id = 312321,
        duration = 18,
        type = "Magic",
        max_stack = 1
    },
    -- Disoriented.
    -- https://wowhead.com/beta/spell=6358
    seduction = {
        id = 6358,
        duration = 30,
        mechanic = "sleep",
        type = "Magic",
        max_stack = 1
    },
    -- Embeded with a demon seed that will soon explode, dealing Shadow damage to the caster's enemies within $27285A1 yards, and applying Corruption to them.    The seed will detonate early if the target is hit by other detonations, or takes $w3 damage from your spells.
    -- https://wowhead.com/beta/spell=27243
    seed_of_corruption = {
        id = 27243,
        duration = 12,
        type = "Magic",
        max_stack = 1
    },
    -- Maximum health increased by $s1%.
    -- https://wowhead.com/beta/spell=17767
    shadow_bulwark = {
        id = 17767,
        duration = 20,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: If the target dies and yields experience or honor, Shadowburn restores ${$245731s1/10} Soul Shard and refunds a charge.
    -- https://wowhead.com/beta/spell=17877
    shadowburn = {
        id = 17877,
        duration = 5,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Slowed by $w1% for $d.
    -- https://wowhead.com/beta/spell=384069
    shadowflame = {
        id = 384069,
        duration = 6,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=30283
    shadowfury = {
        id = 30283,
        duration = 3,
        mechanic = "stun",
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec and siphoning life to the casting Warlock.
    -- https://wowhead.com/beta/spell=63106
    siphon_life = {
        id = 63106,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=108366
    soul_leech = {
        id = 108366,
        duration = 15,
        max_stack = 1
    },
    -- Talent: $s1% of all damage taken is split with the Warlock's summoned demon.    The Warlock is healed for $s2% and your demon is healed for $s3% of all absorption granted by Soul Leech.
    -- https://wowhead.com/beta/spell=108446
    soul_link = {
        id = 108446,
        duration = 3600,
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $s2 Nature damage every $t2 sec.
    -- https://wowhead.com/beta/spell=386997
    soul_rot = {
        id = 386997,
        duration = 8,
        type = "Magic",
        max_stack = 1,
        copy = 325640
    },
    --
    -- https://wowhead.com/beta/spell=246985
    soul_shards = {
        id = 246985,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Consumes a Soul Shard, unlocking the hidden power of your spells.    |cFFFFFFFFDemonic Circle: Teleport|r: Increases your movement speed by $387633s1% and makes you immune to snares and roots for $387633d.    |cFFFFFFFFDemonic Gateway|r: Can be cast instantly.    |cFFFFFFFFDrain Life|r: Gain an absorb shield equal to the amount of healing done for $387630d. This shield cannot exceed $387630s1% of your maximum health.    |cFFFFFFFFHealth Funnel|r: Restores $387626s1% more health and reduces the damage taken by your pet by ${$abs($387641s1)}% for $387641d.    |cFFFFFFFFHealthstone|r: Increases the healing of your Healthstone by $387626s2% and increases your maximum health by $387636s1% for $387636d.
    -- https://wowhead.com/beta/spell=387626
    soulburn = {
        id = 387626,
        duration = 3600,
        max_stack = 1
    },
    soulburn_demonic_circle = {
        id = 387633,
        duration = 8,
        max_stack = 1,
    },
    soulburn_drain_life = {
        id = 394810,
        duration = 30,
        max_stack = 1,
    },
    soulburn_health_funnel = {
        id = 387641,
        duration = 10,
        max_stack = 1,
    },
    soulburn_healthstone = {
        id = 387636,
        duration = 12,
        max_stack = 1,
    },
    -- Soul stored by $@auracaster.
    -- https://wowhead.com/beta/spell=20707
    soulstone = {
        id = 20707,
        duration = 900,
        max_stack = 1
    },
    -- $@auracaster's subject.
    -- https://wowhead.com/beta/spell=1098
    subjugate_demon = {
        id = 1098,
        duration = 300,
        mechanic = "charm",
        type = "Magic",
        max_stack = 1
    },
    --
    -- https://wowhead.com/beta/spell=101508
    the_codex_of_xerrath = {
        id = 101508,
        duration = 3600,
        max_stack = 1
    },
    tormented_souls = {
        duration = 3600,
        max_stack = 20,
        generate = function( t )
            local n = GetSpellCount( 386256 )

            if n > 0 then
                t.applied = query_time
                t.duration = 3600
                t.expires = t.applied + 3600
                t.count = n
                t.caster = "player"
                return
            end

            t.applied = 0
            t.duration = 0
            t.expires = 0
            t.count = 0
            t.caster = "nobody"
        end,
        copy = "tormented_soul"
    },
    -- Damage dealt by your demons increased by $w1%.
    -- https://wowhead.com/beta/spell=339784
    tyrants_soul = {
        id = 339784,
        duration = 15,
        max_stack = 1
    },
    -- Dealing $w1 Shadowflame damage every $t1 sec for $d.
    -- https://wowhead.com/beta/spell=273526
    umbral_blaze = {
        id = 273526,
        duration = 6,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    unending_breath = {
        id = 5697,
        duration = 600,
        max_stack = 1,
    },
    -- Damage taken reduced by $w3%  Immune to interrupt and silence effects.
    -- https://wowhead.com/beta/spell=104773
    unending_resolve = {
        id = 104773,
        duration = 8,
        max_stack = 1
    },
    -- Suffering $w2 Shadow damage every $t2 sec. If dispelled, will cause ${$w2*$s1/100} damage to the dispeller and silence them for $196364d.
    -- https://wowhead.com/beta/spell=316099
    unstable_affliction = {
        id = 316099,
        duration = 16,
        type = "Magic",
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=386931
    vile_taint = {
        id = 386931,
        duration = 10,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Damage done increased by $w1%.
    -- https://wowhead.com/beta/spell=386865
    wrathful_minion = {
        id = 386865,
        duration = 8,
        max_stack = 1,
        generate = function( t )
            local name, _, count, _, duration, expires, caster = FindUnitBuffByID( "pet", 386865 )

            if name then
                t.name = name
                t.count = count
                t.expires = expires
                t.applied = expires - duration
                t.caster = caster
                return
            end

            t.count = 0
            t.expires = 0
            t.applied = 0
            t.caster = "nobody"
        end,
    },
    -- Suffering $w1 Shadowflame damage every $t1 sec.$?a339892[ ; Damage taken by Chaos Bolt and Incinerate increased by $w2%.][]
    wither = {
        id = 445474,
        duration = function() return ( 18.0 + 3 * talent.scalding_flames.rank ) * ( 1 - 0.15 * talent.hatefury_rituals.rank ) end,
        tick_time = 2.0,
        pandemic = true,
        max_stack = 8,
    },

    -- Azerite Powers
    chaos_shards = {
        id = 287660,
        duration = 2,
        max_stack = 1
    },

    -- Conduit
    combusting_engine = {
        id = 339986,
        duration = 30,
        max_stack = 1
    },

    -- Legendary
    odr_shawl_of_the_ymirjar = {
        id = 337164,
        duration = function () return class.auras.havoc.duration end,
        max_stack = 1
    },
} )


spec:RegisterHook( "runHandler", function( a )
    if talent.rolling_havoc.enabled and havoc_active and not debuff.havoc.up and action[ a ].startsCombat then
        addStack( "rolling_havoc" )
    end
end )


spec:RegisterHook( "spend", function( amt, resource )
    if resource == "soul_shards" then
        if amt > 0 then
            if legendary.wilfreds_sigil_of_superior_summoning.enabled then reduceCooldown( "summon_infernal", amt * 1.5 ) end

            if buff.art_overlord.up then
                summon_demon( "overlord" )
                removeBuff( "art_overlord" )
            end

            if buff.art_mother.up then
                summon_demon( "mother_of_chaos" )
                removeBuff( "art_mother" )
                if talent.secrets_of_the_coven.enabled then applyBuff( "infernal_bolt" ) end
            end

            if buff.art_pit_lord.up then
                summon_demon( "pit_lord" )
                removeBuff( "art_pit_lord" )
                if talent.ruination.enabled then applyBuff( "ruination" ) end
            end

            if talent.diabolic_ritual.enabled then
                if buff.diabolic_ritual.down then applyBuff( "diabolic_ritual" )
                else
                    if buff.ritual_overlord.up then buff.ritual_overlord.expires = buff.ritual_overlord.expires - amt; if buff.ritual_overlord.down then applyBuff( "art_overlord" ) end end
                    if buff.ritual_mother.up then buff.ritual_mother.expires = buff.ritual_mother.expires - amt; if buff.ritual_mother.down then applyBuff( "art_mother" ) end end
                    if buff.ritual_pit_lord.up then buff.ritual_pit_lord.expires = buff.ritual_pit_lord.expires - amt; if buff.ritual_pit_lord.down then applyBuff( "art_pit_lord" ) end end
                end
            end

            if talent.grand_warlocks_design.enabled then reduceCooldown( "summon_infernal", amt * 1.5 ) end
            if talent.power_overwhelming.enabled then addStack( "power_overwhelming", ( buff.power_overwhelming.up and buff.power_overwhelming.remains or nil ), amt ) end
            if talent.ritual_of_ruin.enabled then
                addStack( "impending_ruin", nil, amt )
                if buff.impending_ruin.stack > 15 - ceil( 2.5 * talent.master_ritualist.rank ) then
                    applyBuff( "ritual_of_ruin" )
                    removeBuff( "impending_ruin" )
                end
            end
        elseif amt < 0 and floor( soul_shard ) < floor( soul_shard + amt ) then
            if talent.demonic_inspiration.enabled then applyBuff( "demonic_inspiration" ) end
            if talent.wrathful_minion.enabled then applyBuff( "wrathful_minion" ) end
        end
    end
end )


spec:RegisterHook( "advance_end", function( time )
    if buff.art_mother.expires > query_time - time and buff.art_mother.down then
        summon_demon( "mother_of_chaos" )
        removeBuff( "art_mother" )
        if talent.secrets_of_the_coven.enabled then applyBuff( "infernal_bolt" ) end
    end
end )


local lastTarget
local lastMayhem = 0

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_CAST_SUCCESS" and destGUID ~= nil and destGUID ~= "" then
            lastTarget = destGUID
        elseif state.talent.mayhem.enabled and subtype == "SPELL_AURA_APPLIED" and spellID == 80240 then
            lastMayhem = GetTime()
        end
    end
end, false )


spec:RegisterStateExpr( "last_havoc", function ()
    if talent.mayhem.enabled then return lastMayhem end
    return pvptalent.bane_of_havoc.enabled and action.bane_of_havoc.lastCast or action.havoc.lastCast
end )

spec:RegisterStateExpr( "havoc_remains", function ()
    return buff.active_havoc.remains
end )

spec:RegisterStateExpr( "havoc_active", function ()
    return buff.active_havoc.up
end )

spec:RegisterStateExpr( "demonic_art", function ()
    return buff.demonic_art_overlord.up or buff.demonic_art_mother.up or buff.demonic_art_pit_lord.up
end )

spec:RegisterStateExpr( "diabolic_ritual", function ()
    return buff.ritual_overlord.up or buff.ritual_mother.up or buff.ritual_pit_lord.up
end )



spec:RegisterHook( "TimeToReady", function( wait, action )
    local ability = action and class.abilities[ action ]

    if ability and ability.spend and ability.spendType == "soul_shards" and ability.spend > soul_shard then
        wait = 3600
    end

    return wait
end )

spec:RegisterStateExpr( "soul_shard", function () return soul_shards.current end )



-- Tier 29
spec:RegisterGear( "tier29", 200336, 200338, 200333, 200335, 200337, 217212, 217214, 217215, 217211, 217213 )
spec:RegisterAura( "chaos_maelstrom", {
    id = 394679,
    duration = 10,
    max_stack = 1
} )

spec:RegisterGear( "tier30", 202534, 202533, 202532, 202536, 202531 )
spec:RegisterAura( "umbrafire_embers", {
    id = 409652,
    duration = 13,
    max_stack = 8
} )

spec:RegisterGear( "tier31", 207270, 207271, 207272, 207273, 207275 )
spec:RegisterAura( "searing_bolt", {
    id = 423886,
    duration = 10,
    max_stack = 1
} )



local SUMMON_DEMON_TEXT

spec:RegisterHook( "reset_precast", function ()
    last_havoc = nil
    soul_shards.actual = nil

    class.abilities.summon_pet = class.abilities[ settings.default_pet ]

    if not SUMMON_DEMON_TEXT then
        local summon_demon = GetSpellInfo( 180284 )
        SUMMON_DEMON_TEXT = summon_demon and summon_demon.name or "Summon Demon"
        class.abilityList.summon_pet = "|T136082:0|t |cff00ccff[" .. SUMMON_DEMON_TEXT .. "]|r"
    end

    for i = 1, 5 do
        local up, _, start, duration, id = GetTotemInfo( i )

        if up and id == 136219 then
            summonPet( "infernal", start + duration - now )
            break
        end
    end

    if pvptalent.bane_of_havoc.enabled then
        class.abilities.havoc = class.abilities.bane_of_havoc
    else
        class.abilities.havoc = class.abilities.real_havoc
    end

    if IsActiveSpell( 433891 ) then
        applyBuff( "infernal_bolt" )
    end
end )


spec:RegisterCycle( function ()
    if active_enemies == 1 then return end

    -- For Havoc, we want to cast it on a different target.
    if this_action == "havoc" and class.abilities.havoc.key == "havoc" then return "cycle" end

    if ( debuff.havoc.up or FindUnitDebuffByID( "target", 80240, "PLAYER" ) ) and not legendary.odr_shawl_of_the_ymirjar.enabled then
        return "cycle"
    end
end )


local Glyphed = IsSpellKnownOrOverridesKnown

-- Fel Imp          58959
spec:RegisterPet( "imp",
    function() return Glyphed( 112866 ) and 58959 or 416 end,
    "summon_imp",
    3600 )

-- Voidlord         58960
spec:RegisterPet( "voidwalker",
    function() return Glyphed( 112867 ) and 58960 or 1860 end,
    "summon_voidwalker",
    3600 )

-- Observer         58964
spec:RegisterPet( "felhunter",
    function() return Glyphed( 112869 ) and 58964 or 417 end,
    "summon_felhunter",
    3600 )

-- Fel Succubus     120526
-- Shadow Succubus  120527
-- Shivarra         58963
spec:RegisterPet( "sayaad",
    function()
        if Glyphed( 240263 ) then return 120526
        elseif Glyphed( 240266 ) then return 120527
        elseif Glyphed( 112868 ) then return 58963
        elseif Glyphed( 365349 ) then return 184600
        end
        return 1863
    end,
    "summon_sayaad",
    3600,
    "incubus", "succubus" )

-- Wrathguard       58965
spec:RegisterPet( "felguard",
    function() return Glyphed( 112870 ) and 58965 or 17252 end,
    "summon_felguard",
    3600 )


-- Abilities
spec:RegisterAbilities( {
    -- Calls forth a cataclysm at the target location, dealing $s1 Shadowflame damage to all enemies within $A1 yards and afflicting them with $?a445465[Wither][Immolate].
    cataclysm = {
        id = 152108,
        cast = 2,
        cooldown = 30,
        gcd = "spell",
        school = "shadowflame",

        spend = 0.01,
        spendType = "mana",

        talent = "cataclysm",
        startsCombat = true,

        toggle = function()
            if active_enemies == 1 then return "interrupts" end
        end,

        handler = function ()
            local applies = talent.wither.enabled and "wither" or "immolate"
            applyDebuff( "target", applies )
            active_dot[ applies ] = max( active_dot[ applies ], true_active_enemies )
            removeDebuff( "target", "combusting_engine" )
        end,
    },

    -- Launches $s1 bolts of felfire over $d at random targets afflicted by your $?a445465[Wither][Immolate] within $196449A1 yds. Each bolt deals $196448s1 Fire damage to the target and $196448s2 Fire damage to nearby enemies.
    channel_demonfire = {
        id = 196447,
        cast = function() return class.auras.channel_demonfire.duration end,
        channeled = true,
        cooldown = 25,
        gcd = "spell",
        school = "fire",

        spend = 0.015,
        spendType = "mana",

        talent = "channel_demonfire",
        startsCombat = true,

        usable = function () return active_dot[ talent.wither.enabled and "wither" or "immolate" ] > 0 end,

        start = function()
            removeBuff( "umbrafire_embers" )
        end

        -- With raging_demonfire, this will extend Immolates but it's not worth modeling for the addon ( 0.2s * 17-20 ticks ).
    },

    -- Talent: Unleashes a devastating blast of chaos, dealing a critical strike for 8,867 Chaos damage. Damage is further increased by your critical strike chance.
    chaos_bolt = {
        id = 116858,
        cast = function () return ( 3 - 0.5 * talent.improved_chaos_bolt.rank )
            * ( buff.ritual_of_ruin.up and 0.5 or 1 )
            * ( buff.backdraft.up and 0.7 or 1 )
            * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "chromatic",

        spend = function ()
            if buff.ritual_of_ruin.up then return 0 end
            return 2
        end,
        spendType = "soul_shards",

        startsCombat = true,
        nobuff = "ruination",
        cycle = function () return talent.eradication.enabled and "eradication" or nil end,

        texture = 236291,
        velocity = 16,

        handler = function ()
            removeStack( "crashing_chaos" )
            if buff.ritual_of_ruin.up then
                removeBuff( "ritual_of_ruin" )
                if talent.avatar_of_destruction.enabled then applyBuff( "blasphemy" ) end
            else
                removeStack( "backdraft" )
            end
            if debuff.wither.up then
                applyDebuff( "target", "wither", nil, debuff.wither.stack + 1 + ( buff.malevolence.up and 1 or 0 ) )
            end
            if talent.burn_to_ashes.enabled then
                addStack( "burn_to_ashes", nil, 2 )
            end
            if talent.eradication.enabled then
                applyDebuff( "target", "eradication" )
                active_dot.eradication = max( active_dot.eradication, active_dot.bane_of_havoc )
            end
            if talent.internal_combustion.enabled and debuff.immolate.up then
                if debuff.immolate.remains <= 5 then removeDebuff( "target", "immolate" )
                else debuff.immolate.expires = debuff.immolate.expires - 5 end
            end
        end,

        impact = function() end,

        bind = "ruination"
    },

    --[[ Commands your demon to perform its most powerful ability. This spell will transform based on your active pet. Felhunter: Devour Magic Voidwalker: Shadow Bulwark Incubus/Succubus: Seduction Imp: Singe Magic
    command_demon = {
        id = 119898,
        cast = 0,
        cooldown = 0,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        handler = function ()
        end,
    }, ]]

    -- Talent: Triggers an explosion on the target, dealing 3,389 Fire damage. Reduces the cast time of your next Incinerate or Chaos Bolt by 30% for 10 sec. Generates 5 Soul Shard Fragments.
    conflagrate = {
        id = 17962,
        cast = 0,
        charges = function() return talent.improved_conflagrate.enabled and 3 or 2 end,
        cooldown = function() return talent.explosive_potential.enabled and 11 or 13 end,
        recharge = function() return talent.explosive_potential.enabled and 11 or 13 end,
        gcd = "spell",
        school = "fire",

        spend = 0.01,
        spendType = "mana",

        talent = "conflagrate",
        startsCombat = true,
        cycle = function () return talent.roaring_blaze.enabled and "conflagrate" or nil end,

        handler = function ()
            gain( 0.5, "soul_shards" )
            addStack( "backdraft" )

            removeBuff( "conflagration_of_chaos_cf" )

            if talent.decimation.enabled and target.health_pct < 50 then reduceCooldown( "soulfire", 5 ) end
            if talent.roaring_blaze.enabled then
                applyDebuff( "target", "conflagrate" )
                active_dot.conflagrate = max( active_dot.conflagrate, active_dot.bane_of_havoc )
            end
            if conduit.combusting_engine.enabled then
                applyDebuff( "target", "combusting_engine" )
            end
        end,
    },

    -- Corrupts the target, causing $s3 Shadow damage and $?a196103[$146739s1 Shadow damage every $146739t1 sec.][an additional $146739o1 Shadow damage over $146739d.]
    corruption = {
        id = 172,
        cast = 2.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = true,

        handler = function()
            applyDebuff( "target", "corruption" )
        end,

        -- Effects:
        -- #0: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 146739, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.138, 'pvp_multiplier': 1.25, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- destruction_warlock[137046] #12: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 348, 'target': TARGET_UNIT_CASTER, }
        -- mark_of_perotharn[440045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- xalans_cruelty[440040] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- absolute_corruption[196103] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wither[445465] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 445468, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
    },

    --[[ Creates a Healthstone that can be consumed to restore 25% health. When you use a Healthstone, gain 7% Leech for 20 sec.
    create_healthstone = {
        id = 6201,
        cast = 3,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
        end,
    }, ]]


    -- Talent: Rips a hole in time and space, opening a random portal that damages your target: Shadowy Tear Deals 15,954 Shadow damage over 14 sec. Unstable Tear Deals 13,709 Chaos damage over 6 sec. Chaos Tear Fires a Chaos Bolt, dealing 4,524 Chaos damage. This Chaos Bolt always critically strikes and your critical strike chance increases its damage. Generates 3 Soul Shard Fragments.
    dimensional_rift = {
        id = 387976,
        cast = 0,
        charges = 3,
        cooldown = 45,
        recharge = 45,
        gcd = "spell",
        school = "chaos",

        spend = -0.3,
        spendType = "soul_shards",

        talent = "dimensional_rift",
        startsCombat = true,
    },

    --[[ Summons an Eye of Kilrogg and binds your vision to it. The eye is stealthed and moves quickly but is very fragile.
    eye_of_kilrogg = {
        id = 126,
        cast = 2,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "eye_of_kilrogg" )
        end,
    }, ]]


    -- Talent: Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal 1,678 additional Shadow damage. Lasts 1 |4hour:hrs; or until you summon a demon pet.
    grimoire_of_sacrifice = {
        id = 108503,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        talent = "grimoire_of_sacrifice",
        startsCombat = false,
        essential = true,

        nobuff = "grimoire_of_sacrifice",

        usable = function () return pet.active, "requires a pet to sacrifice" end,
        handler = function ()
            if pet.felhunter.alive then dismissPet( "felhunter" )
            elseif pet.imp.alive then dismissPet( "imp" )
            elseif pet.succubus.alive then dismissPet( "succubus" )
            elseif pet.voidawalker.alive then dismissPet( "voidwalker" ) end
            applyBuff( "grimoire_of_sacrifice" )
        end,
    },

    -- Talent: Marks a target with Havoc for 15 sec, causing your single target spells to also strike the Havoc victim for 60% of normal initial damage.
    havoc = {
        id = 80240,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "havoc",
        startsCombat = true,
        indicator = function () return active_enemies > 1 and ( lastTarget == "lastTarget" or target.unit == lastTarget ) and "cycle" or nil end,
        cycle = "havoc",

        bind = "bane_of_havoc",

        usable = function()
            if pvptalent.bane_of_havoc.enabled then return false, "pvptalent bane_of_havoc enabled" end
            return talent.cry_havoc.enabled or active_enemies > 1, "requires cry_havoc or multiple targets"
        end,

        handler = function ()
            if class.abilities.havoc.indicator == "cycle" then
                active_dot.havoc = active_dot.havoc + 1
                if legendary.odr_shawl_of_the_ymirjar.enabled then active_dot.odr_shawl_of_the_ymirjar = 1 end
            else
                applyDebuff( "target", "havoc" )
                if legendary.odr_shawl_of_the_ymirjar.enabled then applyDebuff( "target", "odr_shawl_of_the_ymirjar" ) end
            end
            applyBuff( "active_havoc" )
        end,

        copy = "real_havoc",
    },


    bane_of_havoc = {
        id = 200546,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        startsCombat = true,
        cycle = "DoNotCycle",

        bind = "havoc",

        pvptalent = "bane_of_havoc",
        usable = function () return active_enemies > 1, "requires multiple targets" end,

        handler = function ()
            applyDebuff( "target", "bane_of_havoc" )
            active_dot.bane_of_havoc = active_enemies
            applyBuff( "active_havoc" )
        end,
    },

    -- Talent: Let loose a terrifying howl, causing 5 enemies within 10 yds to flee in fear, disorienting them for 20 sec. Damage may cancel the effect.
    howl_of_terror = {
        id = 5484,
        cast = 0,
        cooldown = 40,
        gcd = "spell",
        school = "shadow",

        talent = "howl_of_terror",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "howl_of_terror" )
        end,
    },

    -- Burns the enemy, causing 1,559 Fire damage immediately and an additional 9,826 Fire damage over 24 sec. Periodic damage generates 1 Soul Shard Fragment and has a 50% chance to generate an additional 1 on critical strikes.
    immolate = {
        id = 348,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 0.015,
        spendType = "mana",

        startsCombat = true,
        cycle = function () return not debuff.immolate.refreshable and "immolate" or nil end,
        notalent = function() return state.spec.destruction and talent.wither.enabled and "wither" or nil end,

        handler = function ()
            applyDebuff( "target", "immolate" )
            active_dot.immolate = max( active_dot.immolate, active_dot.bane_of_havoc )
            removeDebuff( "target", "combusting_engine" )
            if talent.flashpoint.enabled and target.health_pct > 80 then addStack( "flashpoint" ) end
        end,

        bind = function() return state.spec.destruction and talent.wither.enabled and "wither" or nil end,
    },

    -- Draws fire toward the enemy, dealing 3,794 Fire damage. Generates 2 Soul Shard Fragments and an additional 1 on critical strikes.
    incinerate = {
        id = 29722,
        cast = function ()
            if buff.chaotic_inferno.up then return 0 end
            return 2 * haste
                * ( buff.backdraft.up and 0.7 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 0.015,
        spendType = "mana",

        startsCombat = true,
        nobuff = "infernal_bolt",

        handler = function ()
            removeBuff( "chaotic_inferno" )
            removeStack( "backdraft" )
            removeStack( "burn_to_ashes" )
            removeStack( "decimating_bolt" )

            if talent.decimation.enabled and target.health_pct < 50 then reduceCooldown( "soulfire", 5 ) end

            -- Using true_active_enemies for resource predictions' sake.
            gain( ( 0.2 + ( 0.125 * ( true_active_enemies - 1 ) * talent.fire_and_brimstone.rank ) )
                * ( legendary.embers_of_the_diabolic_raiment.enabled and 2 or 1 )
                * ( talent.diabolic_embers.enabled and 2 or 1 ), "soul_shards" )
        end,

        bind = "infernal_bolt"
    },

    infernal_bolt = {
        id = 434506,
        cast = function ()
            if buff.chaotic_inferno.up then return 0 end
            return 2 * haste
                * ( buff.backdraft.up and 0.7 or 1 )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        startsCombat = true,
        buff = "infernal_bolt",

        handler = function ()
            removeBuff( "infernal_bolt" )
            removeBuff( "chaotic_inferno" )
            removeStack( "backdraft" )
            removeStack( "burn_to_ashes" )
            removeStack( "decimating_bolt" )

            if talent.decimation.enabled and target.health_pct < 50 then reduceCooldown( "soulfire", 5 ) end

            -- Using true_active_enemies for resource predictions' sake.
            gain( 3, "soul_shards" )
        end,

        bind = "incinerate"
    },

    -- [430014] Dark magic erupts from you and corrupts your soul for $442726d, causing enemies suffering from your Wither to take $446285s1 Shadowflame damage and increase its stack count by $s1.; While corrupted your Haste is increased by $442726s1% and spending Soul Shards on damaging spells grants $s2 additional stack of Wither.
    malevolence = {
        id = 442726,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "spell",

        spend = 0.010,
        spendType = 'mana',

        talent = "malevolence",
        startsCombat = true,

        handler = function ()
            applyBuff( "malevolence")
        end,
    },

    -- Calls down a rain of hellfire, dealing ${$42223m1*8} Fire damage over $d to enemies in the area.
    rain_of_fire = {
        id = 5740,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = function ()
            if buff.ritual_of_ruin.up then return 0 end
            return 3
        end,
        spendType = "soul_shards",

        talent = "rain_of_fire",
        startsCombat = true,

        handler = function ()
            removeStack( "crashing_chaos" )
            if buff.ritual_of_ruin.up then
                removeBuff( "ritual_of_ruin" )
                if talent.avatar_of_destruction.enabled then applyBuff( "blasphemy" ) end
            end
            if talent.burn_to_ashes.enabled then
                addStack( "burn_to_ashes", nil, 2 )
            end
        end,
    },

    --[[ Begins a ritual that sacrifices a random participant to summon a doomguard. Requires the caster and 4 additional party members to complete the ritual.
    ritual_of_doom = {
        id = 342601,
        cast = 0,
        cooldown = 3600,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    },

    -- Begins a ritual to create a summoning portal, requiring the caster and 2 allies to complete. This portal can be used to summon party and raid members.
    ritual_of_summoning = {
        id = 698,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "shadow",

        spend = 0.05,
        spendType = "mana",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
        end,
    }, ]]

    ruination = {
        id = 434635,
        known = 116858,
        cast = function () return 1.5
            * ( buff.ritual_of_ruin.up and 0.5 or 1 )
            * ( buff.backdraft.up and 0.7 or 1 )
            * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "chromatic",

        startsCombat = true,
        buff = "ruination",
        cycle = function () return talent.eradication.enabled and "eradication" or nil end,

        texture = 135800,
        velocity = 16,

        handler = function ()
            removeStack( "crashing_chaos" )
            if buff.ritual_of_ruin.up then
                removeBuff( "ritual_of_ruin" )
                if talent.avatar_of_destruction.enabled then applyBuff( "blasphemy" ) end
            else
                removeStack( "backdraft" )
            end
            if debuff.wither.up then
                applyDebuff( "target", "wither", nil, debuff.wither.stack + 1 + ( buff.malevolence.up and 1 or 0 ) )
            end
            if talent.burn_to_ashes.enabled then
                addStack( "burn_to_ashes", nil, 2 )
            end
            if talent.eradication.enabled then
                applyDebuff( "target", "eradication" )
                active_dot.eradication = max( active_dot.eradication, active_dot.bane_of_havoc )
            end
            if talent.internal_combustion.enabled and debuff.immolate.up then
                if debuff.immolate.remains <= 5 then removeDebuff( "target", "immolate" )
                else debuff.immolate.expires = debuff.immolate.expires - 5 end
            end
            -- summon_demon( "diabolic_imp", 1 )
            removeBuff( "ruination" )
        end,

        impact = function() end,

        bind = "chaos_bolt"
    },

    -- Conjure a Shadow Rift at the target location lasting $d. Enemy players within the rift when it expires are teleported to your Demonic Circle.; Must be within $s2 yds of your Demonic Circle to cast.
    shadow_rift = {
        id = 353294,
        cast = 0.0,
        cooldown = 60.0,
        gcd = "spell",

        spend = 0.010,
        spendType = 'mana',

        startsCombat = false,
        pvptalent = "shadow_rift",
    },

    -- Blasts a target for $s1 Shadowflame damage, gaining $s3% critical strike chance on targets that have $s4% or less health.; Restores ${$245731s1/10} Soul Shard and refunds a charge if the target dies within $d.
    shadowburn = {
        id = 17877,
        cast = 0,
        charges = 2,
        cooldown = 12,
        recharge = 12,
        gcd = "spell",
        school = "shadowflame",

        spend = 1,
        spendType = "soul_shards",

        talent = "shadowburn",
        startsCombat = true,
        cycle = "shadowburn",
        nodebuff = "shadowburn",

        handler = function ()
            -- gain( 0.3, "soul_shards" )
            applyDebuff( "target", "shadowburn" )
            active_dot.shadowburn = max( active_dot.shadowburn, active_dot.bane_of_havoc )

            removeBuff( "conflagration_of_chaos_sb" )

            if talent.burn_to_ashes.enabled then
                addStack( "burn_to_ashes" )
            end
            if talent.eradication.enabled then
                applyDebuff( "target", "eradication" )
                active_dot.eradication = max( active_dot.eradication, active_dot.bane_of_havoc )
            end
        end,
    },

    -- Burns the enemy's soul, dealing $s1 Fire damage and applying $?a445465[Wither][Immolate].; Generates ${$281490s1/10} Soul Shard.
    soul_fire = {
        id = 6353,
        cast = function () return 4 * ( buff.decimation.up and 0.2 or 1 ) * haste end,
        cooldown = 45,
        gcd = "spell",
        school = "fire",

        spend = 0.02,
        spendType = "mana",

        talent = "soul_fire",
        startsCombat = true,
        aura = function() return talent.wither.enabled and "wither" or "immolate" end,

        handler = function ()
            removeBuff( "decimation" )
            gain( 1, "soul_shards" )
            applyDebuff( "target", talent.wither.enabled and "wither" or "immolate" ) -- Add stack?
        end,
    },

    -- Talent: Summons an Infernal from the Twisting Nether, impacting for 1,582 Fire damage and stunning all enemies in the area for 2 sec. The Infernal will serve you for 30 sec, dealing 1,160 damage to all nearby enemies every 1.6 sec and generating 1 Soul Shard Fragment every 0.5 sec.
    summon_infernal = {
        id = 1122,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "summon_infernal",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "infernal", 30 )
            if talent.rain_of_chaos.enabled then applyBuff( "rain_of_chaos" ) end
            if talent.crashing_chaos.enabled then applyBuff( "crashing_chaos", nil, 8 ) end
        end,
    },

    -- Bestows a vile malediction upon the target, burning the sinew and muscle of its host, dealing $s1 Shadowflame damage immediately and an additional $445474o1 Shadowflame damage over $445474d.$?s137046[; Periodic damage generates 1 Soul Shard Fragment and has a $s2% chance to generate an additional 1 on critical strikes.; Replaces Immolate.][; Replaces Corruption.]
    wither = {
        id = 445468,
        known = function() return talent.wither.enabled end,
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",
        school = "fire",

        spend = 0.015,
        spendType = 'mana',

        talent = "wither",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "wither" )
        end,

        bind = "immolate"
    },
} )


spec:RegisterRanges( "corruption", "subjugate_demon", "mortal_coil" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = true,

    nameplates = false,
    nameplateRange = 40,
    rangeFilter = false,


    damage = true,
    damageDots = false,
    damageExpiration = 6,

    potion = "spectral_intellect",

    package = "Destruction",
} )




spec:RegisterSetting( "default_pet", "summon_sayaad", {
    name = "|T136082:0|t Preferred Demon",
    desc = "Specify which demon should be summoned if you have no active pet.",
    type = "select",
    values = function()
        return {
            summon_sayaad = class.abilityList.summon_sayaad,
            summon_imp = class.abilityList.summon_imp,
            summon_felhunter = class.abilityList.summon_felhunter,
            summon_voidwalker = class.abilityList.summon_voidwalker,
        }
    end,
    width = "normal"
} )

spec:RegisterSetting( "cleave_apl", false, {
    name = "\n\nDestruction Warlock is able to do funnel damage. Head over to |cFFFFD100Toggles|r to learn how to turn the feature on and off. " ..
        "If funnel is enabled, the default priority will recommend spending with Chaos Bolt in AoE in order to do priority damage.\n\n",
    desc = "",
    type = "description",
    fontSize = "medium",
    width = "full",
} )

--[[
spec:RegisterVariable( "cleave_apl", function()
    if settings.cleave_apl ~= nil then return settings.cleave_apl end
    return false
end )
--]]

--[[ Retired 2023-02-20.
spec:RegisterSetting( "fixed_aoe_3_plus", false, {
    name = "Require 3+ Targets for AOE",
    desc = function()
        return "If checked, the default action list will only use its AOE action list (including |T" .. ( GetSpellTexture( 5740 ) ) .. ":0|t Rain of Fire) when there are 3+ targets.\n\n" ..
        "In multi-target Patchwerk simulations, this setting creates a significant DPS loss.  However, this option may be useful in real-world scenarios, especially if you are fighting two moving targets that will not stand in your Rain of Fire for the whole duration."
    end,
    type = "toggle",
    width = "full",
} ) ]]

spec:RegisterSetting( "havoc_macro_text", nil, {
    name = "When |T460695:0|t Havoc is shown with a |TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t indicator, the addon is recommending that you cast Havoc on a different target (without swapping).  A mouseover macro is useful for this and an example is included below.",
    type = "description",
    width = "full",
    fontSize = "medium"
} )

spec:RegisterSetting( "havoc_macro", nil, {
    name = "|T460695:0|t Havoc Macro",
    type = "input",
    width = "full",
    multiline = 2,
    get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.havoc.name end,
    set = function () end,
} )

spec:RegisterSetting( "immolate_macro_text", nil, {
    name = function () return "When |T" .. GetSpellTexture( 348 ) .. ":0|t Immolate is shown with a |TInterface\\Addons\\Hekili\\Textures\\Cycle:0|t indicator, the addon is recommending that you cast Immolate on a different target (without swapping).  A mouseover macro is useful for this and an example is included below." end,
    type = "description",
    width = "full",
    fontSize = "medium"
} )

spec:RegisterSetting( "immolate_macro", nil, {
    name = function () return "|T" .. GetSpellTexture( 348 ) .. ":0|t Immolate Macro" end,
    type = "input",
    width = "full",
    multiline = 2,
    get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.immolate.name end,
    set = function () end,
} )


spec:RegisterPack( "Destruction", 20240924, [[Hekili:S31)VTTos()wcouxRMgxlL4xBxyNd7ThwGTyXEhq2d7VfhfBLeJAB5tsU9Ldb(V9JKsKIFzgskzPK0hYDlET1IA4WHdN5ZmCe51Hx)pV(QLXfjx)pIghDX4VgDXOWVEEy4xV(QIh3LC9v7Ix8947j)LTXBi)3)ZK8IS9lkwLUL(ShxNgVKsJ809zlip)HIID5)Pp9P7xv8W(BhTiDZNYxTz)6y6BSil(Uc6)EXNU(QB3VADXFB713cZaF(6RI3x8qA21xD1Qn)fcLxTCzszZtYxC9v0MF24VEw0f)Pd38N3Mw8qs2HB(BB2Ks6SKd3KVlEZHBUB1VF4Bh(gVXHHKgtP3HB2VJ2TYpC8eYd)RKx4M7snjLCdpN3W)1kA3(Xd3uKTA73tkYRB2xiCg5bK)88XIoDx2Q0SvfpA29F(Sikv)Npq6V)vCwjPxT9WndZtZkoCt6DbxF16v5f5uX9QIKn0)Y)GnbMSn(21jlV()GiZQMAY394M48IKS85)mHiZwq61KSvXKjTKIrR2Exs2241JYs2eVAB(HBUC2HBchF4MbeEeSbtjniQSb3U)U7gj1bzj7iS4O8cIQsjLo)lSgoKk)V)HI51DdHixqOYtpz8iAhesFwq5JVnnpNrfG2D(yU(O24SGOgHirQMHcLLfeg8hXK)gPTIH8C6l8JKsM4eYmB86KTKr3EI6W25cbtvpu2mbrQ6K5HZ)5Q1RNVonpz(cc)XgvLseJ2wRtqLaiemAEYVVy9(Ls8v5tgven6H485lstxVm9NBlF(qLNZFw9SjyFOWirm(v8M6dFLz0s1ItSjmh4GHM6tFfWfJaYBQszUbFu)8nXB3hVwiDqOW8L7ZyMQoCZPSjdQ2SMcizDy(60cjnkIw35216IEw06IARwxeQAmQwxOdTUWwP1f2FADqm0rQ1f5qRlYPwxuR16IOADx40wNMM6v7jQgPKE8(flPopK0kHx247YQsTmx0WhZsWcYkAu5BW1Qdp0HiA27swuqBTIY0USKFqLoJc1FtVxBgqNAM40GG20zdNA8x3dFQjczQbBTR1P3FDMA(nTPgDbpFQIYmZFiE7s(Cv9puq()VIllabILUJ8wjfRURME82t)BR3t(JLPeKwvOmLmk9VF4g6t(jdBj)3L1hEi(hPlQmYXi78sWqL)oLIZlwr(ba0qvSLfMIOiqaZVEE(dXzlRGZvBEVs(MSiJa2Li1Mt4rIxGFKSvzkMbruyo(201fJ2VRcxh9rltwSAdZKh73lTVc0Tbu0(3fVFnHJdLhQ7i6qR2EpPR3UCfBKa4e29GvOoBqVsMvblSKxfdw1B(C(IBHSC7MvbzLQPf0vu1owoZ96o28Wu6ko5rGMtviBBUz(HLbdSoLgy1qOid(eS9N6bqa35i5VCYm7e70UwQeWyqpiyGeMRoB4wnI1jPjv9D400EVsnRlht)smd2EH878qw4fHoZNyvcyEkhZz(aVCZw5DvETEDhOgibKxZUErFKlnM)yTO35WTxx07tV38f9oP6VeZGTxi)opKfEriOf9gHk21l61ZEqjixgMsiaU1WrRafEB8IVVKMHxtKG1pIYBGiOcn(vAI(UO28cbb1DRJVpJMRyaGT1SdL3z4FzGzkXelg969brymAIuAtPp7UvzjqWjR7IS4vlNN8d6OoE5Y8r080sKRHt0bkxHHxwGycTNXgLCa)jsJHpqMJhvcfwikIlIxS(X8n2YbapWcTmpv()0I84USeIaHqb18COfpbJpNm6cUUwrC29uvDYJMxKoF5QeMuyIM1dKOC4Pye9XAZCbIG8uEJIvl(obGTwYLG48ih8DyiVbAAixq1qw84I1KMZE1C6QblX4xojIk4fZ(9UyhqplYMsOvrEv7Fjf46yqueW1M(EiM8N3UpB7O72tSOLLS4bkz4CgXUcnlcBI)D2QRQOBxMWmvLKfVC1IYqtRfnYVYaXQB52kVe)eXYzshNMxg)7QTZVBn1PcVjvezjrasIrKi2xvSxjxfI8Yu2WAdGektd9MrC1ucZnft3OiIGHe4zCrw6UhEuofi1w7eckQW9ZOcxn1cdbigf)sRTrpSuc(JK5jBt2SkPQxJyUgRfjLE3sRhCNv)On7Ys)rYY5stbantykvrU)bud4NQmJy(Yd8Jbk7Jtq7gzJ9IxNks)kQivxEvLbLZq6J6oG4mJPoXD7fogTpGwNkXNB3MSE(YecUdbTWrnup4naoG60pe3RVbR9zUIu5I)kKpLlt03srjJhljkLBZjDEmXWXkkILAax18LERymhoEblQ7soS3Uy12KQHkb5fX8x8psSd9sotGSXR2sPlfRujsicqVffkz4Cr86Y86qmOqnzuUdZYztSD5quinz0q1o6eflvBIF8HKn1t8QzoBE9SAUDezdzRMqr)Yt(OxPiwkbWRt(rkP5lsSH0Quq1pmJn)NFXpuj18fBPjXttCwbM9fCpS65TnlHqb(AmdC7W56f1fIaQqLxyP19srUqEPKFpzX(cURC5aEuu1qq0R7IdhWMWbtrzYpxKU5295gE6HX1vhf3e2OZkyGaMnbP3V2Gdd6)fcCyiG2QZopcty29QsXsoycBaz22950HReCej1wUSvfesTIV45YH4x1f1puY64LoeMbUwsOH)QUtesCAZlFB4Lp6GwW1rorchsxOMm0TMIlLLZ9qz5fEI8zykehKun2TS0yg(4Bxh))LOmz5tmdrc5mqdff)Kg0E(pxAvu9zZ3WkGTAy9YcAWxGGTmBDA2s3TC3QI5QTSunsmGc4ICLTdtX5lkImCWIVfsM3HKbJkDgZfpCOvwawZKzCLK7MNTFfDtwXC4BbsTh5sKWIFDSS8NhmHIGWsSgwWm399UMiuhpxV23AsDCqAdTR3Bccsfkj4can0M1lgHq9svyyVpJrXbeIMeuKevgINGbHi8E66dreK6(qHtv4PhPB1b(5gV0Vfzak8Y5k2x80FOdx(8rteJrBaGL6C24UiJeH4Aq9aC)BAzKVU(l8ZbGcG6qDxTIGzHZ(S18oJodpfdMVJuchac2biRnkGDQFUSGx23z3aFsHeQXblh1ai8QsnryPL9CUIKz1iMFCXCSQzp5zyABDUvqOoqFLJl6mEkgLxkSCflcO5lUDEubs8CstnNz9vLXCrx5pwX0RskG(hr4UMTv3sdSLyr(6FvVvYWd0DrhH7IwWfXRxN(Z5zK3kQyE(UKTlPFlg1BRNv(P6j7Eml9(KTRwKR80k7HspffcOYckq3X6RlT5DxdpA5QkC5UfbiooJAfL0kPNJEHpoB1qqZbbSakWYabh0cq(FgGMJpqpjr4anSSy0QWI0OJwEPSn1I8A1ePOkWVOplBN1e3GML2Vi3AJKoR14Vk3y(iSSNvB554bTjNSCICJinMl(PZ4LXbCk0LLEvVdAyJNhQYRcZEkmknlLPoYaUFZStkXxHVjbuwrF3MoxKLdYtQHywfwhpnhNRAcxlNX4MWbtgR(soDBV5jl4BM8lV3YaLb(pJxvOJ271QF(adf2XJIMWnYRTMh8lT4xNX5mbEL6LzY4vEfXRxcoNGbpc3BK)7kg7PgR95jdFy3TpohX2VH7y8LFppXdPxo54ABsV(sSzmw(cAmWNrN1dfGSRS7YJXr48b41pVbVURmKPBf2)TeWs590bXGIKoDtOVyPrrTp0bFahVBTZUP8TGrXLPSJrPT(t4FmCIRqsr2ht8S43O8aPM0KboLsUYQJ1eEdyk5c3fnYPSw9bBnjWwrPiMsg(wk39pL7ia)yk5kZy4XScprDk3Hd3dKL87FaVESmsXpqZEt77nTpp0(guApwy1DQOmCSDkluQCczAUCtJeUlfByGAyMw2ChSVRoBrvJ7F2yNCeRuezyqDHIEDPOKdCNErhOkHreryfhmipbXqdqaXuvx8GDQ3yfvQ6D1CfyFRA0coId7AObYlHoTPGTE2d0PR8(KHVhkoQbFWvpYqVL3zkSDXOhRSlAZgAfJSUCSm9tboqtjk(abtkLrcfurCjL8Mqu3sztkQqaHv9I0Xf9gizmeYLIpX8AZrgBSbmIfYa76MRTCRlK3yBc1ZUeFOfBM)g3o0q3(9hGVYSA9aUP5wgUJXU9uBQYswcsPhAbIDPr4JX((3HNmlZDBzj)d2YaQIin)oXr1QTuO1b55iaoJnA4yw8i(F92QOk1nnBgxINGdlAEItsdJeK1fRkqWkgHv0TTuE7(ZKQY1kATe09F3zUyRiEiuqiZ7tThlkdH9(eFZ38Q2dxgMfSSrxvJhkLNhVD58BZwTjViDRJALblz0N7OE8QPr1XK3urIzRN89)dH5CLaWSS)z7ibENU524IRT)j8YZwx9HTdrNjEnl8gE3Ch1uA6gPQdlcWPZUeJTBuRBD)9JuKE)9KLs3TNA(w(JcP8BIzE8U1xdSPmEq46ZKb6Xxg9K)Ho9uEMsMTAx5R9N3xKs1SwC4M)E690)GDGq(FqA5HB(NLKGS(IgXr1)6WnxToL8FdHpnfO9b7dyP5NCksFq59chhb)PGl4yKJ9bSZ1iZXE(JBvcHc50SiNBl0(XMX7Se9vDRklSgfdN4n25r1HOmDytjZtwNtgGJPbqxnhXS1O7MRHcQi3ckSJRlWJAGEwqb2N(jO0dPVbRbchTkFK(rBQYcHRy65X0ZSvI7H7OReuv)RwNsgkP0fj0cxI0EYd(Z)3)9d3SMyhL(pjw)3sBxb94ynUEX1A6Ily98YJBTRb24IgmaJE1oaJKgGg7bsdgHSPWF(Wkc7ZYnkX3vmrpRiz(QfmCcTyWg11dwX5E51q5HVbJ2OMmA)Rut2)xeM))jprEGsxALZhO0iFk)P90wLC3DjlOn6X09uCGBjT6NX0)lvIWAcvovHbaCEvEO28p1tPjwQ1jX5tc4mjBcO2Er6Dv)ub3NeLxBWSKApcLY5gmaIE2haradaemnu3ikBUUv3O4UoOM6D5yXPVLp55XttzX3hYIAF8OYQXhbpJu7bin11ipA4ln4rqN2q8i05MLvEm0BEmuIhDInJTImMU282u6Q56L6XzjslUlbHbO4WpZCrvRR89gk0YzfXKXEsqvUiHyJT(G3TqL3R0bEyjTB(5d2pCu(WKPLrF9RMHPEeh7cYJkrn3En0oE0a2xQ4DvwEHoSgpACO66u4MoL20V(vfMwU(xV2(oKujrUNezBknmxc1ZJjpM4hfyJxaB21IDhbiEC1a4Xd1UPFOqr(wCOCnqEOTcECxc7GSAX31zsKKmynfR8jjWtGaVOapjTyBtP1xEf7O(hi2Xf226F(5NkF1Jqttkc6gxsA0IXfiKWAgrNloP8laqzvXXWavhjgarBvZd(wqW1DPwj7QVG6TAUTR48gwZTwkam3hKfwQtl9Sh(YFswazEfkYddB7DZbpqzN)25trUOG)B(XAqVC(uiwNxUh6qrOzOsG)HFAtJCkfSvvbb4tbBvL76)4C6hOxsXHkNTvAh6bwphIERg4Q3qJo(qpaFJRzYSm8s6Erd(879dbHhF9)IbjJ7KRUgzwtBm65zC4ZcRPj1WbDn0UE7Z9HwqRQASbq7AS6oqxZo6vLPKspqbBIvXtyNPRgfKMPv()qDujyj4Xt8Rl9gRJRHyGBepT8qwQ9BTVhLZ2ZjuNEhKJLdyaLjztfCVNMBKM8uTUZQ(aynLCUJQsPHOG9H1Bky52RE6v1)1NkOw0d8rs1t6ZI6BQGxCFcp(2lppC0LUGQ9kh49RSJxdpoxg(14mfyISYLPdwn1RFtU1UklRpRMkw8ZuGilh2ZppNPagLqMw0bWLXLscxoFSNzEMLrxRvuLqfsi0OK17B4XAUyxk7pbYEDN1zcNtMtaEONlDDTDQuRVnjlpjJwJKQxagdG6Pl94frvs8MbRfQ19bus9FoeSEZ0mPkT0DveURttxo)U9zpkjJgyxSc9kTwMkjkf0fAloE9lkPR9zJbVLKqVrRfKakNc6BFxF6pb6Fqx0hVDb92lNIcmE96RRUGBi4zO()UU6(hpmKUTkzBjCcrjNDDCVAZo2vWnRKkFpB)4Epn1N)V7jtulP(Z3uxWh0FG6cM4PA0HV93zvGu0F6Wn)L0TKEI943dpXqOjTMDqEkFAJ0QHH)EaoTRQDb1BfAbTvR(cPh7jrfI9kXmaHbAsps8EISpp8859OIHbTRyOq7kggp2tI6uoa2KEK49ezFE45l6u9nnEUBjooz7qL5(K2t60PWEL44KTpLhDcTp8naFPIsR59DI)uGBLyD20YfxSt5G5uhhQIT5oP20RKV3i8B89B8Tpe(fIVt3Lu2I8YcR99dhYUJrj)HCqdVZgXdonm4KzqV2Pdfng7dJ5m0wurJGG35KibbdAhBt4B(lQ(MUzl30(PNAPW8fxw2uHX7SpKC((N5QyZdUCCaHXCrNlJgZxnal6)KlrFFQh)jNebtp2jBFe6XUPnMESZ38fxw2uHXRi1yHb7FZD8gOEcGBJIJMUM89gHFJVFJV9HWVq8DJbsbq8(2bKFo)BfBFeoGCtB3aPqEZxCzztfgVZ(qY57B6bkQ1EG8ei1lGESFo)BfBFe6XUPTBGup)6X(jlBQW4vKAmw2ZQ(83EFJYDwyiCYZaQqQ3RM7ml1qLUllSoruSfAK2O4Wmiisk)u(yh0ik4hcHbHr2cgPkswJSa1QSVevRcP0imsvD5lXHllFT(WET77Bxzww)ADdED)B0fizBwPgO0NyJbQpkdcBaBQRi8N7dngeIwx176RymkhEds(fyswwMTAKtTM17ts9vSPf16z3yMbUC39L8DQ1TOXVGDIOmC1xzRx(U(sWwBto65WtYlAN0EzDx7)75rm0NUTIq2c3JWEmiOiXbE37BeSiS9ex9ea596XxB8yV2cKi7e14XELoG2UVk9m57nc)cX3gzjbjJP5dgAJ(VZD03Zg)0toBK99Ty24a(GTLSPtgWpU0ftkK2g4GYoUKDPPL01KV3i8leF7w7oYqTbG(9G2nqVyt72p20jd4hx6IjfsBdC0cJugh7FagPGAJIwIb4xHwIBYd3gvW1giiLzF0t5o4rITMR2RgqFKhv(3RoBUAVIvXNHJ2LLUyu82hNVCxUnFkyTRR7hL0kzqFScumYt6J3UUUFSpo8OOfBKfW(M((qzkmp2NMefK(61jlkainyJ8L39UhWqBIs72IRQVPVpu2dPcsJ8L39Uh8vUB4y(euaDy(cF6jCVK2Dt6mx2Fyy4PJhn5dikvKNdqc6bMyqWLdTda1zbjy03Ho77WQ(MpN8mkl)0lOS0SV7szzTQlsMxBD2uWiiWr9OgPTCyq(E7PrioLMJMgKaH(PQPrq)ZtTd91s1hZL)kgTqsLBhL)1Eo7UDDorF2iyBYuocPoU9zaHODsk(qLM9WotH0vD5ot1)tLTxnRRty9ZgbBJ0dHuh3cbeI2nleWKM9WcbKUQlxi0)tLTxndzlloIDvadBp)L7gpziU0LVF0qyBRKT)3O2obqd(202cenyet6qTtJGa3ZL6efB3s7O5FS9ZRNjFNyDdFViBXKh22c2nCksGd9kXBNyaXEq3WPDz8dNJ5WHF66OroJ70SAccg4v5r897BuSxifh2M4hFir3Ls5pIo66rJE953Wm6mChwEayLOuBRPbeFvDkpJ0hTMNFlOSx4GYWQd0JgV3ZpqYJLWizC64ufXsJ1ruhIOqD7eOoyKVtnJGHR(4l)yeSRTpGimy7T2Ihk66g7CTFrLIyzOfH(GvhCDiPQVGT1iN0nVDdj5rBqPhQqVkcJyuPnQqDFvDdIcLDpn)(gbcT7WfBfkAlucrKzhLJI(mYkS9pQ7rSG0tDiGfuqUTi0lmA1nBdM1(O1(J6Ues9mXzphsZwm6r8c3ckHMX4MBOc00j9OXTtSC2jbg3Nh9I)QMSG(zRQp8T)gtpGsYVWpeVP3bV5f0PA2TY3c6Xp9NP3k9P3TAT4wHiFKOQ9NPEjZ)Xv3nJEUFF54bNiUr6p8nJx70zFQIbjTc(58kx4J0RsUz13cDFKDDoot5kN)W3(3oCt7Vt1d9Hd0k1eoBKjxcrIBE0JJFIAc)ebYpA3wRnGELfiYht3nJDn2wr3WpwFpLoB8OjFuCcRpZDLQ)Sup9WvQEtg5rh9i3OkMFwQ1A4QyMPd65fY9rD7J3erm)Ax3y1JrXm)QK9JGzFGAXUjS)rDDO3e2xCnPdj(rl1A2qP3VRZBY4iczCyVKXLMskA91cEtytTQ1ZqOdwO1p7CzKvUePCWrCW1Olk7MWK8lqBDJZrYgNdLmn3tLiANuTTqL5TNLjANuXTqL7STsf1NjkOle7pwDGxqMLitBS7TCFiL465UAowWxq9XL0RC8bNmupkYb4b)fuPe5fViFJ1OZpcgvs1bKhP3F4dS2KP07nCygc8E(MHZUCeA96chb6npjYWpwieP9I5fW3LHtGFV67FfA0fvTG2DIR3B5Fv)IJUuGZLs5UBknWv3TID8)7UzXPjFS82TMygHmShsBr9vJ9LZopyqTnL6OrCt5Y2QqCvAFYSqjfiyslvbmucGcoKFk0mBYe5xNEVt)X8KfZgoKTS3ZBvQtbBS(nkfCR0VnPccyIvTMn4LJFMwDxf9b61ADWG6l5PlJuMuf2nO8V0fzTIgoFbfTnLDV21v9GH1DW0zx80tMTIXwtNXzROGb4xaWxot5YMtEQMLmjj7daBBg90vY8Ic8SjFOKmGxbFbtbUGfjYUlcE6jtAn98NEcQlm7a5XrW0jdmBr5DGxWGHNWtTbxAlhLK(1r3Pvec4QO7sWbFqWaZ7tUl)YGtmieWTiNIgt90L00GY2lAzMDA4Ojp9K59pSKIXtpP9KVm4v46kLLuZOxw1YlyeBdnZQq90OTRG5Arar7c)6Rv0mogaP2iMnHuXhWvW0gJevpo8cWDR4PN4PE1yBgilouogZiZv4gxydiUWxCNi7LydZnWxhZfck7QwqL9h17ryCoRp7jXnbCP)b0PvvtEp90jMZU1)yTGkq1dTlKndgIDHcl0oknCiM0l)NdGVYGd0KPQ30FYMh0kFcd(OCjiOv7H20PX9cqcSO(EAe0dYjTWfInMjaZjY5iorKm6lM6Km6Vq)ko9stI0Z(n6mVg8PA2QGHGZ(hZu9uWlexjrVENj8GBWfU9HBrTXd37(ptRZAD(CnWmGnHChPkOzJvrlreILKTddF)VAadCw0z1bnPelnautHS)mKxHdSyQCE9n8vjEzO7c2bE4jtcKHecMlQDUO6GZQfE5hQF1TQoVwYfSrHfWKLOHYVCO0LY6zHgOm4dHQwypuf57zvyDnPW5hrcuUDXJkbhC6fJ(8aTiSNo78tR(LARSeNS01INlVpoLmG8xxdwGzvn9TGFBxWVvIpvtoVMgdZQSHuZH12qEb5RlvKT6It4KeXQFnLCeX(LQBi0bL)d(IjE4nAlGiyxpbDH4(DsGJvFMblQBOIYo6lE5gII0n9uNFAnQiaD4CTCnStw5vPeh5Wlgn5SXJc)GKTcUx6afd2ZgEU1M6iAlUXJsWWlECbXnuPR68Yjiya)aWy45I1jCguGR6bhitjDpockw9NLMqNswKp0W8klrumlSHtabVe(fd1xOyy8muL6WngGmW07nT4D1u4V4uJ0(F6fFq)Nc(GsGA0Jw8)4MUbdVQteYOQ4unepNkBPbiFfglxLMuaww82Ku)pjnqAn60jetzP55dCoVjs0Il7V0c3s44OYdee0xdfdb0si9c9eEVFxWamdCdKhUnQBm7LbaM)jg(mH5iHaxZJxKuYlRTdkfZHKBhQtNHsEDQMJLhR1sBtWbUYpLwAN0jqjociXFRGg80td18fRoQU8cSGERx(kN5pUJa64G3LsppG7S6pWEHbCcxoSQeP(5gwKTiercycmpcHILmT0nILHGRs)T6D2xpUdv9sIMd8YCFH14EhM5wFqsodACPmlssFMqujJo09zxG5NPFWF1nQtK)VouJImfQSq4sGju4zZXdorjAjF1zm8q2sXGiJtLCbTvLytMm6cKKOonAa4pReOhrICIsRkwT47K1AeAI2LrbFqfQqxofbk9dBV8gnJyTZtV9mxuXmuYnpE7Y53MTAtEr6wrTYmapBy8fFQjJtR95ez43Ngv7zt8iCgtoZALv(HTue8)3EhT9048W(TmHu1ct7uBhiDFGT773pcMGTIEq3eBQBa3jHE(TFj9LK4y7KMshJPdXx2GehhBh)wCmrNIacGdRVjvosxA8EPTkY1cgvq14eTX9J6N9hb8DYmy)87qqa4b21gA)wO4gblaeZypX1bscnFJar5DOsFMT7x5xn0)QQr6)L(0fgZNPlJ9yqlhAkPJY6wBuKpZ)eV1BJ4CPGBgbU7lB96u6Q(QeCy1Yhk3W6P56UF4lcJPozcYGgsid3SdjK)WkMhBVLcLZeAkWN(sXHXTcB)hM9nvblX7DGgOtoukb1ghQnSMerU)gPcfFrpXxvv0Hhr7idt8qIOlEeDanrArB8iG7VxYBHtereuucOSPzWqU)QuqCkfeE1Y81eItv9vFia2bs6KIF)paK5zURtZ3m5fkbNPiKX0XU5qUX2xyn4AR2IeEArmBt9BFXd8ISyBi3CuCxw1HxLek6uOLpgbspBPJCje5XafXy4tFILscQ6kI1j5vVVYlIs5KDgoQuMJxv30L4AjQkJP23SFwcGRJxaGeIwzcm7AjCxWJgld6yH56rAovte2uJYTMFRgxQIZcVMETHIQkuJvuFPGK0OZ1v)Rb)iKAspzMKo9HcyHHrWi4Jj2nU3bHG4WaZP4QKeJMXCmjf)Ze0wOToGbyTbjogdd2HrzaQAeZN6C1NtB)k(fLo115tNYzaxcej8atCj0vbcsHRvziUVy(SPaiqstWH)es2ZrRTNSC3oJpUcjtR)e4umdZ22Ku1ZdvorvNsr9560Id7LdkqbQjcTD(S0eQ)Gu6jT2iMfGkluDBN6BjqYI(EYyW(Dr(vPOmvKDvQGU8oML6zpOAidTpD(A9KAvrAhcQLz8CZ)6PyEo4V(y174vUmkkR84nAmTVtFWtAf12guRk4TW3YRvguXV0ED0F8lxEsqNYKSKrCKHe(v9MqawiWTuG2EnavxiOUdIyFhEmVB)jzlMd46IoYYZhmwEEmS8CszgmlpJJLNfflpBGy54vTxS8CwwEUhwE(7GLR(Ww5KL2(KEdHoZZ3bm4LkLryYolVNmP21vttOnY7qldY9Kso7kwDOyDfBCxzXlQDQKDHeBdFjIrq7YPPDHzVu0ou)GIseNLKF(q7ul6Y)t1PISmTQQEg582Tv9vqYd6QgP))NxCrBNPtdVhF6LT)s6SZVBYIQIu1Ez2VwuQM8Z777kkpJY4fsik9KS0j6b3GJqeAzQ2ZfO18fDEEOiXJa9UgXzUx6wsrPkwLHHwfmXigSrpsdoy2KUEg5DW9NKGPhB2UD9YhEU8pdd9OZycq2XGfbfxigA0KdevqfoqfGpLebnseKgGhz0KaEjI7EAvX(dLQ7Q5UnBggcYz3PedvPDZRmh0(zRItYKHdtB6Y0rUSRwPMYmImpt)aNULUGbOu12SgJTtC4mtg72xSQS4WEvy0YLsoTxkEQoMnnNTUos2HRrh1vJbaRq3QRYqnxQiq5LRU3ThtHgZBVrvE(aSHazSTJAJqQCQPaFqU5DRx7HPDztwLQVTUN3rXeDhtxOqohYA2onicbDqYEzfSBplmnKOV4M80UGCgV1Gbj1k4n(bPAPYXWJP(AxPIjzIrZPM1KHyBjc34rv3KAFWAjA3op4edJvbbTkTS9bNo5eYyjfEBLTIGtFktyeM(a4IuHeVcbNfXj97MIGUj9t0hfpdK(zW6Hq6Nd0bL(zM4jNqglPWB7mUps)UDHZol9F7b5p3(3d]] )
