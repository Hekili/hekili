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
    accrued_vitality               = {  71953, 386613, 2 }, -- Drain Life heals for 15% of the amount drained over 7.5 sec.
    amplify_curse                  = {  71934, 328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within 15 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional 20%. Curse of Tongues Increases casting time by an additional 40%. Curse of Weakness Enemy is unable to critically strike.
    banish                         = {  71944,    710, 1 }, -- Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect.
    burning_rush                   = {  71949, 111400, 1 }, -- Increases your movement speed by 50%, but also damages you for 4% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until canceled.
    curses_of_enfeeblement         = {  71951, 386105, 1 }, -- Grants access to the following abilities: Curse of Tongues: Forces the target to speak in Demonic, increasing the casting time of all spells by 30% for 1 min. Curses: A warlock can only have one Curse active per target. Curse of Exhaustion: Reduces the target's movement speed by 50% for 12 sec. Curses: A warlock can only have one Curse active per target.
    dark_accord                    = {  71956, 386659, 1 }, -- Reduces the cooldown of Unending Resolve by 45 sec.
    dark_pact                      = {  71936, 108416, 1 }, -- Sacrifices 20% of your current health to shield you for 200% of the sacrificed health plus an additional 28,917 for 20 sec. Usable while suffering from control impairing effects.
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
    ashen_remains                  = {  71969, 387252, 1 }, -- Chaos Bolt, Shadowburn, and Incinerate deal 5% increased damage to targets afflicted by Immolate.
    avatar_of_destruction          = { 101998, 456975, 1 }, -- Consuming Ritual of Ruin summons an Overfiend for 8 sec.  Summon Overfiend
    backdraft                      = {  72067, 196406, 1 }, -- Conflagrate reduces the cast time of your next Incinerate, Chaos Bolt, or Soul Fire by 30%. Maximum 2 charges.
    backlash                       = {  71983, 387384, 1 }, -- Increases your critical strike chance by 3%. Physical attacks against you have a 25% chance to make your next Incinerate instant cast. This effect can only occur once every 6 sec.
    blistering_atrophy             = { 101996, 456939, 1 }, -- Increases the damage of Shadowburn by 20%. The critical strike chance of Shadowburn is increased by an additional 50% when damaging a target that is at or below 30% health.
    burn_to_ashes                  = {  71964, 387153, 1 }, -- Chaos Bolt and Rain of Fire increase the damage of your next 2 Incinerates by 15%. Shadowburn increases the damage of your next Incinerate by 15%. Stacks up to 6 times.
    cataclysm                      = {  71974, 152108, 1 }, -- Calls forth a cataclysm at the target location, dealing 39,235 Shadowflame damage to all enemies within 8 yards and afflicting them with Immolate.
    channel_demonfire              = {  72064, 196447, 1 }, -- Launches 17 bolts of felfire over 2.3 sec at random targets afflicted by your Immolate within 40 yds. Each bolt deals 3,713 Fire damage to the target and 1,477 Fire damage to nearby enemies.
    chaos_incarnate                = {  71966, 387275, 1 }, -- Chaos Bolt, Rain of Fire, and Shadowburn always gain at least 70% of the maximum benefit from your Mastery: Chaotic Energies.
    conflagrate                    = {  72068,  17962, 1 }, -- Triggers an explosion on the target, dealing 19,616 Fire damage. Reduces the cast time of your next Incinerate or Chaos Bolt by 30% for 10 sec. Generates 5 Soul Shard Fragments.
    conflagration_of_chaos         = {  72061, 387108, 1 }, -- Conflagrate and Shadowburn have a 50% chance to guarantee your next cast of the ability to critically strike, and increase its damage by your critical strike chance.
    crashing_chaos                 = {  71960, 417234, 1 }, -- Summon Infernal increases the damage of your next 8 casts of Chaos Bolt by 25% or your next 8 casts of Rain of Fire by 35%.
    decimation                     = { 101997, 456985, 1 }, -- Your critical strikes have a chance to reset the cooldown of Soul Fire and reduce the cast time of your next Soul Fire by 80%.
    demonfire_mastery              = { 101993, 456946, 1 }, -- Increases the damage of Channel Demonfire by 30% and it deals damage 35% faster.
    devastation                    = {  72066, 454735, 1 }, -- Increases the critical strike chance of your Destruction spells by 5%.
    diabolic_embers                = {  71968, 387173, 1 }, -- Incinerate now generates 100% additional Soul Shard Fragments.
    dimension_ripper               = { 102002, 457025, 1 }, -- Incinerate has a chance to tear open a Dimensional Rift or recharge Dimensional Rift if learned.
    dimensional_rift               = { 102003, 387976, 1 }, -- Rips a hole in time and space, opening a random portal that damages your target: Shadowy Tear Deals 99,592 Shadow damage over 14 sec. Unstable Tear Deals 85,195 Chaos damage over 6 sec. Chaos Tear Fires a Chaos Bolt, dealing 33,226 Chaos damage. This Chaos Bolt always critically strikes and your critical strike chance increases its damage. Generates 3 Soul Shard Fragments.
    emberstorm                     = {  72062, 454744, 1 }, -- Increases the damage done by your Fire spells by 2% and reduces the cast time of your Incinerate spell by 20%.
    eradication                    = {  71984, 196412, 1 }, -- Chaos Bolt and Shadowburn increases the damage you deal to the target by 5% for 7 sec.
    explosive_potential            = {  72059, 388827, 1 }, -- Reduces the cooldown of Conflagrate by 2 sec.
    fiendish_cruelty               = { 101994, 456943, 1 }, -- When Shadowburn fails to kill a target that is at or below 30% health, its cooldown is reduced by 5 sec.
    fire_and_brimstone             = {  71982, 196408, 1 }, -- Incinerate now also hits all enemies near your target for 25% damage.
    flashpoint                     = {  71972, 387259, 1 }, -- When your Immolate deals periodic damage to a target above 80% health, gain 2% Haste for 10 sec. Stacks up to 3 times.
    grimoire_of_sacrifice          = {  71971, 108503, 1 }, -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal 6,410 additional Shadow damage. Lasts until canceled or until you summon a demon pet.
    havoc                          = {  71979,  80240, 1 }, -- Marks a target with Havoc for 12 sec, causing your single target spells to also strike the Havoc victim for 60% of the damage dealt.
    improved_chaos_bolt            = { 101992, 456951, 1 }, -- Increases the damage of Chaos Bolt by 10% and reduces its cast time by 0.5 sec.
    improved_conflagrate           = {  72065, 231793, 1 }, -- Conflagrate gains an additional charge.
    indiscriminate_flames          = { 101995, 457114, 1 }, -- Backdraft increases the damage of your next Chaos Bolt by 5% and increases the critical strike chance of your next Incinerate or Soul Fire by 35%.
    inferno                        = {  71974, 270545, 1 }, -- Rain of Fire damage is increased by 20% and its Soul Shard cost is reduced by 1.
    internal_combustion            = {  71980, 266134, 1 }, -- Chaos Bolt consumes up to 5 sec of Immolate's damage over time effect on your target, instantly dealing that much damage.
    master_ritualist               = {  71962, 387165, 1 }, -- Ritual of Ruin requires 5 less Soul Shards spent.
    mayhem                         = {  71979, 387506, 1 }, -- Your single target spells have a 25% chance to apply Havoc to a nearby enemy for 5.0 sec.  Havoc Marks a target with Havoc for 5.0 sec, causing your single target spells to also strike the Havoc victim for 60% of the damage dealt.
    power_overwhelming             = {  71965, 387279, 1 }, -- Consuming Soul Shards increases your Mastery by 0.5% for 10 sec for each shard spent. Gaining a stack does not refresh the duration.
    pyrogenics                     = {  71975, 387095, 1 }, -- Enemies affected by your Rain of Fire take 5% increased damage from your Fire spells.
    raging_demonfire               = {  72063, 387166, 1 }, -- Channel Demonfire fires an additional 2 bolts. Each bolt increases the remaining duration of Immolate on all targets hit by 0.5 sec.
    rain_of_chaos                  = {  71960, 266086, 1 }, -- While your initial Infernal is active, every Soul Shard you spend has a 15% chance to summon an additional Infernal that lasts 8 sec.
    rain_of_fire                   = {  72069,   5740, 1 }, -- Calls down a rain of hellfire, dealing 28,756 Fire damage over 6.0 sec to enemies in the area.
    reverse_entropy                = {  71980, 205148, 1 }, -- Your spells have a chance to grant you 15% Haste for 8 sec.
    ritual_of_ruin                 = {  71970, 387156, 1 }, -- Every 20 Soul Shards spent grants Ritual of Ruin, making your next Chaos Bolt or Rain of Fire consume no Soul Shards and have its cast time reduced by 50%.
    roaring_blaze                  = {  72065, 205184, 1 }, -- Conflagrate increases your Channel Demonfire, Immolate, Incinerate, and Conflagrate damage to the target by 25% for 8 sec.
    rolling_havoc                  = {  71961, 387569, 1 }, -- Each time your spells duplicate from Havoc, gain 1% increased damage for 6 sec. Stacks up to 5 times.
    ruin                           = {  71967, 387103, 1 }, -- Increases the critical strike damage of your Destruction spells by 5%.
    scalding_flames                = {  71973, 388832, 1 }, -- Increases the damage of Immolate by 25% and its duration by 3 sec.
    shadowburn                     = {  72060,  17877, 1 }, -- Blasts a target for 15,728 Shadowflame damage, gaining 50% critical strike chance on targets that have 20% or less health. Restores 1 Soul Shard and refunds a charge if the target dies within 5 sec.
    soul_fire                      = {  71978,   6353, 1 }, -- Burns the enemy's soul, dealing 65,915 Fire damage and applying Immolate. Generates 1 Soul Shard.
    summon_infernal                = {  71985,   1122, 1 }, -- Summons an Infernal from the Twisting Nether, impacting for 8,299 Fire damage and stunning all enemies in the area for 2 sec. The Infernal will serve you for 30 sec, dealing 7,607 damage to all nearby enemies every 1.5 sec and generating 1 Soul Shard Fragment every 0.5 sec.
    summoners_embrace              = {  71971, 453105, 1 }, -- Increases the damage dealt by your spells and your demon by 3%.
    unstable_rifts                 = { 102427, 457064, 1 }, -- Bolts from Dimensional Rift now deal 25% of damage dealt to nearby enemies as Fire damage.

    -- Diabolist
    abyssal_dominion               = {  94831, 429581, 1 }, -- Summon Infernal becomes empowered, dealing 40% increased damage. When your Summon Infernal ends, it fragments into two smaller Infernals at 50% effectiveness that lasts 10 sec.
    annihilans_bellow              = {  94836, 429072, 1 }, -- Howl of Terror cooldown is reduced by 15 sec and range is increased by 5 yds.
    cloven_souls                   = {  94849, 428517, 1 }, -- Enemies damaged by your Overlord have their souls cloven, increasing damage taken by you and your pets by 5% for 15 sec.
    cruelty_of_kerxan              = {  94848, 429902, 1 }, -- Summon Infernal grants Diabolic Ritual and reduces its duration by 3 sec.
    diabolic_ritual                = {  94855, 428514, 1, "diabolist" }, -- Spending a Soul Shard on a damaging spell grants Diabolic Ritual for 20 sec. While Diabolic Ritual is active, each Soul Shard spent on a damaging spell reduces its duration by 1 sec. When Diabolic Ritual expires you gain Demonic Art, causing your next Chaos Bolt, Rain of Fire, or Shadowburn to summon an Overlord, Mother of Chaos, or Pit Lord that unleashes a devastating attack against your enemies.
    flames_of_xoroth               = {  94833, 429657, 1 }, -- Fire damage increased 2% and damage dealt by your demons is increased 2%.
    gloom_of_nathreza              = {  94843, 429899, 1 }, -- Enemies marked by your Havoc take 5% increased damage from your single target spells.
    infernal_bulwark               = {  94852, 429130, 1 }, -- Unending Resolve grants Soul Leech equal to 10% of your maximum health and increases the maximum amount Soul Leech can absorb by 10% for 8 sec.
    infernal_machine               = {  94848, 429917, 1 }, -- Your Soul Shard spending abilities decrease the duration of Diabolic Ritual by 1 additional sec while your Infernal is active.
    infernal_vitality              = {  94852, 429115, 1 }, -- Unending Resolve heals you for 30% of your maximum health over 10 sec.
    ruination                      = {  94830, 428522, 1 }, -- Summoning a Pit Lord causes your next Chaos Bolt to become Ruination.  Ruination
    secrets_of_the_coven           = {  94826, 428518, 1 }, -- Mother of Chaos empowers your next Incinerate to become Infernal Bolt.  Infernal Bolt
    souletched_circles             = {  94836, 428911, 1 }, -- You always gain the benefit of Soulburn when casting Demonic Circle: Teleport, increasing your movement speed by 50% and making you immune to snares and roots for 6 sec.
    touch_of_rancora               = {  94856, 429893, 1 }, -- Demonic Art increases the damage of your next Chaos Bolt, Rain of Fire, or Shadowburn by 100% and reduces its cast time by 50%.

    -- Hellcaller
    aura_of_enfeeblement           = {  94822, 440059, 1 }, -- While Unending Resolve is active, enemies within 30 yds are affected by Curse of Tongues and Curse of Weakness at 100% effectiveness.
    blackened_soul                 = {  94837, 440043, 1 }, -- Spending Soul Shards on damaging spells will further corrupt enemies affected by your Wither, increasing its stack count by 1. Each time Wither increases it has a chance to become acute, dealing 6,460 Shadowflame damage to its host every 1 sec until 1 stack remains. Wither will always become acute after reaching 8 stacks or when its host reaches 20% health.
    bleakheart_tactics             = {  94854, 440051, 1 }, -- Wither damage increased 20%. When Wither gains a stack from Blackened Soul, it has a chance to gain an additional stack.
    curse_of_the_satyr             = {  94822, 440057, 1 }, -- Curse of Weakness is empowered and transforms into Curse of the Satyr.  Curse of the Satyr
    hatefury_rituals               = {  94854, 440048, 1 }, -- Wither deals 50% increased periodic damage but its duration is 25% shorter.
    illhoofs_design                = {  94835, 440070, 1 }, -- Sacrifice 10% of your maximum health. Soul Leech now absorbs an additional 15% of your maximum health.
    malevolence                    = {  94842, 442726, 1 }, -- Dark magic erupts from you and corrupts your soul for 20 sec, causing enemies suffering from your Wither to take 47,445 Shadowflame damage and increase its stack count by 3. While corrupted your active Withers are acute, your haste is increased by 15% and Chaos Bolt grants 1 additional stack of Wither.
    mark_of_perotharn              = {  94844, 440045, 1 }, -- Critical strike damage dealt by Wither is increased by 10%. Wither has a chance to gain a stack when it critically strikes. Stacks gained this way do not activate Blackened Soul.
    mark_of_xavius                 = {  94834, 440046, 1 }, -- Wither damage increased by 25%. Blackened Soul deals 2% increased damage per stack of Wither.
    seeds_of_their_demise          = {  94829, 440055, 1 }, -- Blackened Soul damage increased by 30%. When Blackened Soul deals damage, you have a chance to gain 2 stacks of Flashpoint.
    wither                         = {  94840, 445465, 1, "hellcaller" }, -- Replaces Immolate. Bestows a vile malediction upon the target, burning the sinew and muscle of its host, dealing 3,008 Shadowflame damage immediately and an additional 69,530 Shadowflame damage over 21 sec. Periodic damage generates 1 Soul Shard Fragment and has a 50% chance to generate an additional 1 on critical strikes.
    xalans_cruelty                 = {  94845, 440040, 1 }, -- Your Fire spells gain 10% more critical strike chance from all sources. Your Shadow spells gain 10% more critical strike chance from all sources.
    xalans_ferocity                = {  94853, 440044, 1 }, -- Shadow damage increased by 2%. Fire damage increased by 2%.
    zevrims_resilience             = {  94835, 440065, 1 }, -- Dark Pact heals you for 2,522 every 1 sec while active.
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
    -- [428524] Your next Soul Shard spent summons an Overlord that unleashes a devastating attack.
    diabolic_ritual_overlord = {
        id = 431944,
        duration = 20.0,
        max_stack = 1,
        copy = "demonic_art_overlord"
    },
    diabolic_ritual_mother_of_chaos = {
        id = 432815,
        duration = 20.0,
        max_stack = 1,
        copy = "demonic_art_mother"
    },
    diabolic_ritual_pit_lord = {
        id = 432816,
        duration = 20.0,
        max_stack = 1,
        copy = "demonic_art_pit_lord"
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

spec:RegisterStateExpr( "diabolic_ritual", function ()
    return buff.diabolic_ritual_overlord.up or buff.diabolic_ritual_mother_of_chaos.up or buff.diabolic_ritual_pit_lord.up
end )

spec:RegisterStateExpr( "demonic_art", function ()
    return buff.demonic_art_overlord.up or buff.demonic_art_mother.up or buff.demonic_art_pit_lord.up
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
            summon_demon( "diabolic_imp", 1 )
            removeBuff( "ruination" )
        end,

        impact = function() end,
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

    spell_lock = {
        id = 19647,
        known = function () return IsSpellKnownOrOverridesKnown( 119910 ) or IsSpellKnownOrOverridesKnown( 132409 ) end,
        cast = 0,
        cooldown = 24,
        gcd = "off",

        startsCombat = true,
        -- texture = ?

        toggle = "interrupts",
        interrupt = true,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
        end,

        copy = { 19647, 119910, 132409, 119898 }
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
        cast = 0.0,
        cooldown = 0.0,
        gcd = "spell",

        spend = 0.015,
        spendType = 'mana',

        talent = "wither",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "wither" )
        end,

        -- Effects:
        -- #0: { 'type': SCHOOL_DAMAGE, 'subtype': NONE, 'sp_bonus': 0.138, 'variance': 0.05, 'target': TARGET_UNIT_TARGET_ENEMY, }
        -- #1: { 'type': DUMMY, 'subtype': NONE, }
        -- #2: { 'type': TRIGGER_SPELL, 'subtype': NONE, 'trigger_spell': 445474, 'target': TARGET_UNIT_TARGET_ENEMY, }

        -- Affected by:
        -- destruction_warlock[137046] #12: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 348, 'target': TARGET_UNIT_CASTER, }
        -- socrethars_guile[405936] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- bleakheart_tactics[440051] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER_BY_LABEL, 'points': 20.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- emberstorm[454744] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- flames_of_xoroth[429657] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- mark_of_perotharn[440045] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': SHOULD_NEVER_SEE_15, }
        -- mark_of_xavius[440046] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- scalding_flames[388832] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 25.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #2: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_cruelty[440040] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #0: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 2.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- xalans_ferocity[440044] #3: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 10.0, 'target': TARGET_UNIT_CASTER, 'modifies': CRIT_CHANCE, }
        -- absolute_corruption[196103] #1: { 'type': APPLY_AURA, 'subtype': ADD_PCT_MODIFIER, 'points': 15.0, 'target': TARGET_UNIT_CASTER, 'modifies': PERIODIC_DAMAGE_HEALING, }
        -- wither[445465] #0: { 'type': APPLY_AURA, 'subtype': OVERRIDE_ACTIONBAR_SPELLS, 'spell': 445468, 'value1': 3, 'target': TARGET_UNIT_CASTER, }
        -- wither[445465] #1: { 'type': APPLY_AURA, 'subtype': CAST_WHILE_WALKING, 'target': TARGET_UNIT_CASTER, }
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


spec:RegisterPack( "Destruction", 20240901, [[Hekili:S3ZwZTnVY9BXpezr7yfrARVe)vj3z6PVCY058IpD6dDQPPLOS5ejrvsQKp3rJ(TxascqCzxaqAk7Km(LCrC5If7UyVHfe35F3)8UBxeveF3)iyCWvJVECWOX(xozYv3DBXZBJV72TrZ)w0JK)XMO1K)8FpoViB38IK0n0N98Q0OfuCKNUlBo55pvuSn)p)0NEmP4PDpmAE66pLNSE3Qi6BmplAzb9)p)t3D7d7swv833C3dseWxciJC0UINsZU72Btw)3iOmzXI4k4IZNF3Tu4Uy8xUi4Q)8W9uqoC)2SK0SKINpC)UTuKD4Rh(AfyF(IGljG9pFk(W9)xrzK)GqyjBoC)W80SId3NU07UBxLKxKtNfjfXRP)J)rjFjEt0dRIxC3)gBY)q8Q0SmYFKhw8uCy(UnZJwTkMqP7YJdtxUm8X5lOV8Tr1Ci83yoHEJZsIU72HeI5W9fjRjK4nhUpy8H7hC4(5PPRwK(JnJY3TED6MWKnlJZ2eTAuw86OKn5Cy9oC)(9vOilzZ3Ilgv4pkjFe2qxIDrOdgXhloUPy8Kd3)9icfs4bJQbomi8HDlxwdG84rNaKrkjEzE4JrRFiPOK2aiVGwrE(TG88bjVaZKNhBijymlkzry83J3umkAXI8rX)fv1OcFQpB32QFpFB8QvHfrzpgxyAEDZSd3pHZqwM84tfH8z0uQW8UcYQafnpMMu(2NxhLtuzYd)r8dI6pBjZraTdYO5xPkbdW0zCDTHAKdv36QXWukfXxngDIqE8LJzRyuOAY87sK5xT0YxzLbxeZMaH0x47XCDGIOvujI6QK6rOcma9KFKqKzeHuC4Cc9jOeObBJTf6ehbHbHX)18v7wiqxnAFpfLhY0HHwnaRFBMqcANrIbYRx0yMdSqqtDzS4RLWxxoaBD76On7IwX5oiyiCXUSspjhU)8sHbvlxrbKyppFvAHGgfrR7kZADbVkADbDvRlavngvRZ3IwhMvvRQ)hlToic6fQ1fyrRlWQwxqN16cOADte16KSz3lky6Uq8NWNlic7MPIdmxI61245f0X7CMVlcVSIudJ3eVojoNPy04Ox953WuCEk67PZ5ZupMtcDxZuM3Fy1rHYYCTGWAy3gJvWQnjE0bgXHl20ngsvnd0MK3HfGcYnPvIBZI)oL7mYx9nDwVZJkA(SvRPkRfAPOX9fU4IMaertNcN8xhrZxuenyjMqjMWNI2SGjRA(b6QpUbkWSHs3sER4IKLn4Jbp9FTAh5VwKsc6KqPKm)IfSO)VE4E6t(bjlS4m2VlQpiAJOeTHvgjQ(DkgdP2lGcvUMSmquefbsIQRcZFkkBrLD8lB8nwZFJNNrcKNW1kdGFEkjIFjrmvNOXU9dPRk4Pcu(OfXZtwxAKT83RSzcmSE0eAxgTBfHI9fNQBj6qjBEKm0BwKuotaIB2(KLRoRHVkIvkTabxYAKQZ0z48hGc2YoPcsk1If0vunUYUW(6Us5qvswcZafVVA(SDI4RC2UCvAAgZZRIN5pzZxShlYcY)4KzMr259nxXRKaDaHI5k3Bt36zSkk1XQRtN2o6nXl1BZPFjKGDNj)bh4foHOlCjrpVspLJzeVNtUzR9UkUwVzaKZcdkwZ(ErFGnnMFVw0BD6Eux07YO3(f9wX6VesWUZK)Gd8cNqe0IET8S77f9QLEbklg6I(Sy0L9muUMeNCv4RcXff4df8nfJeWBzuYYOvzKPathQR70qPg2THbQEkwMmqzS3qjc0e2EDWZpen)BlO7YJEeZnpIkdbJ00x7xPvt(QMjfjsZLRIEmJUFraja0qouzCy1wQmLv3bUwI6yquAgnrOs70NTmjlgkS7MHqbfxnAsvbTQyezrpsdnErmrrLIlYpS5BvfZty6qY3At8QgOGIEUzev3ac62yDJurFQh8AXSOiGVKRr2ws2vKc7nAwaEgz13OQKu4uBur08vpNVgkmzgqmLz9n4AyvMFcA7ljR2EIIbzkujtVsYCYORywbQ2OL69ZjnCrs12MnrXUos(NSkNJ(yfDfpE63sVrrY8VrKVk1mfIYdSq3((ma0vOimXNNVkMT3s01FgkmgZOecJNV2)OZ2LTYOW0bEOrwEn8VLmCvhfsm4gNspfr(7h2LTz0YDeFnzXKL3e0WOmYsFA9Dwh9xLRUQR7WI4sJJXzrlsMxv0GgwJ4R0yArewXL4NWxntg408QktqwTVCf1DpdKAKSGWajzVty7jf7KQIeVIzva2yYLGzArrkrUCHOzg)P7JoHXqS7fvKLU9PNflovJ9voJcYNPALGG5gNvwwcymQ6A0DVcd1RD90QTF5crwsvChPntUlAE06TzPFpErOGiaamUPuj((zOgWpxsIO)YdCJaQgJtqhgpjxt1VoLL6pgLNQvS)QIBDbYG0mceVzL6tm)E(4bxaTq1OpuF8idAM9AXQGgNHFlIc4ZmnPQv)1bLITHnnXrt0k3Ktg8iILJeAqsnXc3qxQqvsC4bmyqFxWJ9M5jBIRNQKG9i2)I(ES5O9K3iNbARLUHVuLWHiXGpVqQ4Z0oIiS6)esTzu1boIf6TBL3LZnlXHSH0jsMQwh98tXRBe8Yf1mSrQMBoiWHLlNqtmHvxyNQEVqT5xf)9uc4ZbdiKbwfJ64qmMCG(fyVKQre2qxLlnjUAIYkWmWOgttZlRws9SycgyRX0svaUm8O(q4Xku7gwyDVqsLKxk(VINVRG5lxmxujvnKKiW2Vm9i24EykQQl9801pSlxZvpCGDnjypPC2zmAaVsBccVVsS)xXdedjQTMnobHi0hEzUyffuL1KoS7YPtxH4reuBz8w5OqAu85pxS6l1drZdfSoEJfMPNTLekbG1miCoof8Q3gE5JACq46iNieisFOMm0UMInLLlDqz5nwq(kicXd8Sj4TS0OYaKFyv0)xSKWYLKgc48zaa)cJbReBp7NRSkk)SW1Pu2utC9ImAWxGeCz2Q0Sf2HCBsrOmKvQr8jKhJLlTtLsoFrJidpG03ZjZ5CYGJkDwPlE4CRmeKEjpJPKSmmBxcD)VrZOWqT7SxMxcjE9yr(plzcjgHHCnWJO7im6kSqdXR3)JTcxhpiTHM171dcsousWfakrB2SyekQxQct57xsO4beIwfuKkv6Jx(gSA1Q4dfUwHN)cDRoWn34v(TitqUxoB5(Ixrf1WLVSUM1dTeaSWGxoVlYiziUcupa3)MYMa00AmU5aqkGAFvxT8KzHl)SXcpJkHNIfMVLAc7bgSdqzBKc2P55ImErFN9t4tsOqopyXSgadVQsteMBzUORiLwnO0poxglB2tuctH16UpH6a9N84IUGvJrXLclskZakC(dHbfi5ZjiAUW4RkgZfDL)yjtVsLa6FeG7A2ulLnWuLfzR)L9wjgEGQl6aCx0CQiA1Q0FeMrERGIW8TXBwWoNn(2PN6NS95S0hJ3Kmpx6P12dfEkAiGslOaDhRUU0K3DL4rRwvHZ3nWaXJZOrrjTM7zzuyZZonfuCqaZG8mmrWdAbO(pdqRXhONKa8anmSy0iZIa0lMFjTZ486A1gUOCGFbFw0oRECdkwA)Ii0AfDwb4RfbMndRgzziVepPnXILt4BeUri)NUq84fOxcDrUx97GM24L(Y0k3SNeHsRszAVvb8YNwbOW2kXk81W(RMT9yP2BBkjtQMm4BgI28VAxIoN)KMqPRtFLvoNlLDvPuB8FM3ygC7VQ99YW62h5cAT085(6RzlSqTmAKeRFm0lFOHEbOhIxfP0B6UjXs5sEmunubhBCJcZuHJP0qqLlHTjGRJ5pXw4Ri75bUZJwLZOCcwdSYLSKbOX(vaWs0v23G5ZlH6mtG4zAdS5sK3RoxlQohITZsDCjjgE4TWcQZ1olE4Lc8GLE3GBrIx)gzV(4vfh9uFqFanFQLjKq6RFIHI5HhwbWjKmqzT)edi25osqQ)bLdbYCTovIZ7YAVad1CeWL(EkQLIeT1Y)H7U0sVfcQNHvWT3GnSMcwZYbTg0bicSQOQDBxH4uOq0hswV5SjUtiy)fA1F9D30y(OvLxT35SwnK5lqbksOTke2hmCSAM9wYYBcUum)52XNXAVbJ5EKsprQ8YvZ9VyScGAL9vq(PvVMfSUmxZ)5mPEkxRCd4Ut6CqDwcytRYMM0uhcvX6xp916ifamNcQvzoSA(XFw(u)cwPySpmoDKh5uFpx7wbD7b6)EjFOtD38zaXVDKL7gKI(isSlBtvKWZwwBJJWkLhEDcRzjuidJ2Si8HSK15fPBSSdvGLkYCrdvWroHh)nMGtowg3B)u5I3zOQvBjzqLU(HOcZ1UIh7BZxFaIynALuu2lPgPsxlSNSbagQ3gRvKpLH1ExBwK(4JeT9L7OggfBfZQornmA7kOYP4aIBoKQ0pgo0pfcuXd8HcT8l9auLuAX4eyDCcAghKZCk2hvbDko)5nsrt)D4JsBop9uJNz3pyiq8gOQ26ij7i4aB9CcZ3iQsgzy8QCYeCmnxQAol4XVOLmQa7mkSVviGNZXJmJcCmDJrbD8dDuZ1YxmWYWiLGDZZR3ft013u2ka0iwZ3MSzXQyiGPgCu(07PdK6h4oiv(Qp7lqvvOfZvlF(bLOSG2mxdCzUg42CnqyUQvGJwmzlzTz7E45WF8u8QTH5K)Cfe7)hpLKVTQuuepmren0I4WK51yxtsu)HhdSmjTG8cCG8cAn5firET)CeiWzuoxYNRAjLqARtYYslBvGLzeuUllEbj8O1e1R0FKx12MJzvDt7LnOBv3VN4UR40fyTDAX0mWY0m4LmnTTeYW0mayAIegGREdyFo7UdzJEH8DI7VGQNAZBIvhkFYXdeFvpL5xYGhpQQjZeWSyOhcWdGAQ)qzmEbigTl0RYh8gT5jO3EO5j0x7dJZtFNNN(oopDznSNMZxF(QOaWc754htaOoyr8y5dwhl7RS)ULoKHWmgD91SO)hAkNXMTsW8rluCwXBReWYd1cYxO)uKwQHoTgpASV8AwyqNsb96RLiAXw8OPYuMYN8rsAKP0CkjyppI84LjZbkcpiyn1ZspzwLuJXlivB7f2ax7)bMgyDEKL)rby5xQ(6hVkD(345icaLXsbYKvGN1oNWaRyIy78GXxoP8J(nqMFg33u2hXn2IiUcNqwRTUHmOTDcqQHneIkvCsvVUjT44Lqa1h(tGSUAFlH0mKknTb(6khoPG4LaUQzl)z6KccT2gkEEndl9Zb7QAWF)8)L)co2yhLZ)htROEx)GYHstLaVX6nPrs3X7r1BoPl9yrDvk)950LP2Qv(sF7auouz47t)W3BBLYCYDQTvkv2AZHkdVTeQAACNpuzVQhTkLjbE0dhHXwzEJhWWWFUowx4rvyObugyF38Aih1wHsqTfOlPW6YcSp7v2Zj43SdtgE4wN42q6C0k2MIE2JzPJhd9UVtPo0cnVMbRC0dtXqQOsczDfCNfZTstEQYWzuFaCl6LJIfKUBtCSUq6TnC3URE6udhDmvqnOh4cN6iPpZ7yeTkIy5aiIhFOTGT(jp05FYoaIoC0)(14uxDLOYLUdwf1RjIqBRFz(d5k5HFQRcmujNxNtDvaEqtgA5g5E75AhlCzzLan29lCviotJIwNV6DAOITPL)nqvp7TbJ7Csxa4GEU813dh6hIZYJZOTCM8xV5bqJ0no8IOkjotGnm1MXaQyWVgmwNj6sUkTfgLyURstxeUCx2Zc8ObMzRqVsN5PcSsoEHkn(p)Ss6A)Y5GZCsO3OZmsaLto(nVBbhpg6VPl6J2mNETYsJcmA1Qsd5et5K4zO()Ut4IH9hrzBiucrjV8cDnz92YlX1L0V6(NwUpoNslE5)7oIGAb1FonWKODfPRJk5iuxWepvJo81)dIdeIk3FE4()w6gYiv(4tzBkSX2HImefPcaBU5Piqp0)V8SoK6xzyAJdiihrKBfTi37RWmiq4CK6BJ0Wg0onK63syatQUkn6gYTIwKR5wygKDPXLQddOrlo2nAsZkU5tbXBTsakx5XoIuRSB7RS6xKFKq7RdnF1ruXqd38Lmgvm0ESJi1kFW(I8(f5hj0(6qZtoIkgA4wNKzHNyIMfG5OIEje)FUjF3wAKkuutBDnAKkSQPC4()7d3RBn()5F5W9e2t2Z0QgvwmLfCC(h966Afor)ICC02J6ghtC)z7kgTyPYrf54O9yYp6fCF4RaXZZBlStBvm9biuiW16PkzA4M)8yBW4iJ(JgIFNUFNUDbXVr0D624kiYjwxi(ApD4WYlPpYFjw4Ipyc5EN77DYmOx78HCGvnXXE5lqHOghEEFWks88g0nYMq3Sxu(nTtw2X9(9DKz(MZlBlZ4dMNswF)lSDUh8UzShHWSHNBcgZwnaZ6)Knw)Xup(twrcMESvY(fOhBh3y6XwFZ3CEzBzg)ePg3M8nq9eadtBtNPvO)OH43P73PBxq8BeD36aPaq(X2bKBo)7ez)cCazh32dKc5nFZ5LTLz8bZtjRVVUhOGo7bYXaPEd0JDZ5FNi7xGESDCBpqQxF9y34LTLz8tKA8O6ANTmLEqxl)osfrWcXm9pIZIlR38Ikt2fuWyfDMEcoOThybdUnPLfEB3gjOxSGc8IOIOhIYJ)ZdFTSXWy0rz7MHu9U6tq6PTQ2Dxdx7oGMe9u5s3zOnsv9yImg82ntbZAThRk(8hdJqPdSLcsbpmxAiwBJEREzHZKHcAboTgUIuLEevbXi91QRih(OfPmgMp)rUou6hnjLHb)SlPnei7aUuxGQkyJa6quneJSdQVCeRTBtSL7NYpgoNkdDVRFHTjG8tjK66lTJpKgkr2FNQJLGc6KpJphtuHStiQN)hn5i8XdYv03RMc9)YB4GWp2cQ2bupUdUIWUBb)1WTZB6G0DEDV7T81GneCmDYfGSbJVyR3b4wVLc4IAbhmKl(N)XtBvqxM75g2NANtvREG2JDAdEcmJuTh7uXo66UgDKr)rdXVr0TwnGqQhC(GHMW)hSxBHzJ3V3kqM3vMzJ9yt2osMwja3OsBejNBJ1niDTuEkAj9n6pAi(nIUTRDhOP2aG)JG2nWOys72nY0kb4gvAJi5CBTG24gPAtZDBdAjnhJdj6xKq4X0e4UpOAFCqHhmiWCFqK)4IcpcAWiHETy04l5AJSYg0UpKUlRScU7dQDzfkyUpiwKvWWihqTw5Ne1fu)0QcRnaavlgd0pnRWdMjWLhvJh0bRZmmOAXy4(mZk4YJQwkeC(52S05JI28C4IT5MIAddU(ECKklDlWFILVPMW6g2ELwm6UBZWk4YJk(PQWnEkoC994yw2HJFheeaA)2ELwm6Ul7ScU8OILQBxJL8yJFxWmnH5YJrpTajexRZHCubcKR0UZJawE7gWTdkoVyDnhoUlgSa2DPExXVly2bzccqUs7opcTwQ7KP(xS3HRSKE3jOLfalJQ97XZ1YCYww3V3Zg6F(4rtodzbf55aOG(9TM(MxO8M2yvEE3m0CPpS2OFA0RVv61hHETlA9456(kkZ(0VyYmD69TwM1Suezx36(UsGGqGVq5kO2W3W8MbbS46rP0WjArz1r2dcLkPOqFQ1zX1tFuVU3JiC3Ec7iBSzNvgELWxh2Iyem9I2FDeC2l7SfgNS)7EdKrQhBEJJUuSZ6x0A35EpA4JcT2EcILvS8wqcUYv)kewZKlsZW0bgkw7V0lwgXqE17LQG06Fffzhx7SyUX6j0hGGE(NBn1fxQxiHNA2Jy1DfWPTYPiIY56ONFkwDLu1pIn7oMFEsoMkOVg91d2H0URnTXRrBc17n1dsBz(I8(IH0EX9lgYpc(FXgQE0bSn)qDUnzEVTm7II7rOTm)nUbiF59U9VSnIxhCf)M0UDDiWZG(lgwmu1C)ZRGoHlM(wIYxS5NGJLDTaeJkDrfcnu4xknEnQTx3AQYY7z9tBvqUyhnH2h3TXWr7GA77vKOLJupgqeAJp3HetXWv)u)tJJrN9GHGVoOf)krzVgCZom7XIDVlOcX3AhSubA7K(XyVxmD2lzEJ9HbRpW9VQvJ448jB8Wx)7RzUB)I8zoLkQlV0qNtVdd(8D3swbTmzf)EikFe)ummBj9YsiDDDgsFmz5mAZ2DZ4bNSnUyu0k6Nu7VQ9ANp7t1eibk4NZ2NRpsV0lN1CFz(XY7F2zfPp(4Q4rl3rVUgCbdkBgjdnzIBLo)klUf4laeFbDgFvBN3ht3oR8gZUgV(FS5InE24rt(i)o1yM9oN)vP)(H7C(2mZdEXZCTUQ(vP3VH7Q62mZ9dxhTHeILMsPHMZD)EjWq7Vkf40AfwLNl3iRTzseapjm2HXndU5MetbodtcGUXTntc)W4)A(QDlIHefQnQQcRdT1sBdbeGqaGDkRY0UxiaLosqJpa2yJNpuItySRdolySNc8OY9ZcA16OaJ0ostzE(qjMylODZ6STK23MLKss06zv7FbI2)8fS(DK6ZMEP1OG6hXw0Rn2fesTAtV0DuqntxlA3g769EoPoaDv4)X6VtheDbIYrwCUBXmXVy(R1K4tfOX4g)rxF9GtgQMp2a80O8QvvDIweVSXuPhoHkOGcsJJhn2FGrqMoMmnGjiWB4)YawRMHGpNf3msmSSc4c)yotKok63DQ34pb(9AU6SOHPxdrj(KVv4RyTm(rUDqP56zhQY7Of7GfLg)XQRUEIzjYeCifIM79(BMDP3GgBunbWBhZvWkHCzCFYmFbvfyulCF2traA8CSptpZMmrIY4Q503w4oVxeiU8NctPPd1R2(bdBUV6Mo7Q971HQC4NoR(YAJ41ya(Lf(nZKUwlfiLQIiiOodSdl0VHs6xjPxm5Sk0aEzF6nf4QC9SXJUYB)EDCn9Y97Hgc9bqCE4nDYaDiQUTn9gm8ewkTmUTy05Qx8LNxJiGl9YBaN8EEd0V5kV5ldordra3xLsAmnIlbXG0orzqYo1F0K971VRYfum2Vx5jFzWqLA0oyyL(vIt3tLNdcS6DujmuQ3pLEtRPtVbnA83mJEX2lUGHVJLLwmAeJMUU2BybeTl8lkBoymxwcWWLMqQ4dykykZrIQhZBiyzQjrFxxYnT6ltwCi9XkJiRWnUuoHYuV)0XzB2nLD9ygpqA)xWjHEbL89jVu2IlOKnITF)j6YRMFSzQ7j74WMR1bdXUmY5Y7ktbCXy1)Da81nUNcZt(wcvCbVYENRrhvlQaTdp0KwkUDDsWWn3XRG(eoPdofmrmEyUfUeXTGGzCUOtWm(C1Rh5B0rYr2tqV5hGjQlxfmeu6)se1tbVmTfy9Qdg3NSgvy3RSb1ghCy7UKwL06DznGeWetUNufuSMkPLWJXxW2HM38FACVFrWfnXYlLmhqWJCE)fiVcluHPI1jvZPe)LHUhPhG)LhL7MriSbHysUQX5IKRmZw4fFO61(SSCvOHfmeEyv8n53mu4cD(cFT4gytHAimN8H4D0mSUMq(KJi5VHMbwzdviLaw5VuFhPoO6)W4ZSWUQEilhnI1JHNGkJ2TvWfV8Z8ujXoKjNqmOtVA0NhOKB60zxEE9V04iGeha1CXLJ1iav5nLkuhaM8mqvc2uAkfSWTDRnEI96V8yDZSHxnAYfJh5FMa9ZmUPHO6aaM)mjf5AZt5vIt4GCamDZkaIvt4OoRvdisetQRY4yS(VRKjtN4XLGndvz60LIm)jGgS9)IMYouCBogEwtiwdqMyQJMsYokQGxDUwT2o)QZu)jVZKcoL(zq(33KM0wMoHZJQJnxJ9CUODjGSU0xBXssX2Io62xZnTuH)97P)i1b6YK4nlQ)vBisMK8dQvANO(EsEoumXemsdCzFLcMiUKyGyOGfIAMP3avVEq6S2ZRsjDjveu55aWIt3CgqcDLhNwz3wP4L5MRWcwJpAcUp4RLlNgLww(n2KjGftzMNBgn55ZGWtatX(fWvmKlqVZxyJfXxIBmdhQRoZ6psS)iwjQnrl0cY0PLAmvZU644sRnYCTuAposDIXCLL6aYny)(JhCIOBHEAYXthPc3uyQ80oPSy4GPzonya4plfan5LprcQIK507YFcorhZaVZK881RSEqMQVTOI1wa4w(jCVFa5dtF7WOnlcFilzDEr6g((XnWkcvY3sb(CcJ4BtdA87WFeoHjM8u1Eo1R5pbGC59qLMgCyJJEwlNXLULyTjWUgp1vT1pa(vYSQBUO9aqCphfaSlEiPH1DTRb234nVBaSCdGqXdjbVewVVvFat((PUEUiy(zQE7hdEzFZjvmwZI5h8y8nW4MK69RYUKEIu5nfTRdzR699nf1kVLTpT51ud52EHeTTPNycO(eZ))T3X2onYoSVLvinQHUD1mtH322Z77hbvq7ujeS0Q2YLvcD(2pXZLK4y7KjddWbDoAFPTBU4y747oSEKtuRd(4JkFTUwlfl8c8yG)1NTvbZkCTFy(pGCslBDGzrNEQUus9W24cjHy(BIcuc6dKS)DSoZWBiJGtnQKZpOXRKe1OzgEJ5VNlRHtLGBqCmOIU6Br3)F2(8Y2NSyz50(5v4gnxcWDyCVe8hUitxu4VpTFZgBMmA0AiktNWMKXanwIrARrRTktgxKYX0uFTbwVeZNAKmO2dXHxKfZ7uSMpbgYahP35SehqbfZyKJwIJqcUuhlAK863wgK5eo5gHJAH50D1pCj(AIQJAPBcllYquD6gG4qmctWHiltkxigOKZgbuoAVukTD6F4H7wuYSMrnwXMDIwjfgMXFRzzAd6ERetoF3O7z4ytoWGtYPi7Y6)sW(oeZYaHSKpUIkCY6ziUY(z77l9OGq88LUmJ5hzrgTJ59ev8FghbJD0reaNdiRObxhOeeWqQqKYzEzECw3xPDcZmFdA9sBpnv)zYlM6CS5hmOcFn9yyF5I5ZqRWGexgvtqGiN3nJpUcNXi)ezOTaX2vnxDZUONi0Q2WN)o8HDB3UsZrPLXuh4DPUxTrcuDmYkZ7ZFiObrmOggtALz7GzRJvgblKg8dT6ncxC7twLleeSZCz7E8aqqHpeukbbGJC(AtREbE2bE9v)FhYjG2UCTaTwX(IW7Yfxsm9PmpaDUMYIBuyGEIk7dJnIf5zC)hAPe5z4)SKVS8ICsqSkUiNgzR5HGUJ3V7uxRH2OPZGXnMj2CRpqPtWqKE(wnUuJ80wpRp3AsbzmD9HkQfRS8zTDNmSROE9SJhbXFrzCK3UY(CbYjihEOHm5D9NXwyLI2YSD9slhNEtFU7MEwHMmDAXsC5)O6jjVC0i5LPqYlz5zOK8cjsoNSIaCyJejNURdIKxksYldqYlFdK8MgaNiJe58E)P9EfAg4DsOwKokost43xT(u1MP2IMP1eJfGFM(n8zrgQKe6TowISo5oBx(2OwPI4SgMYuLX8up8tuUwdIRM9D)HQNGtQMgqizXtPEc4UsECxC2AoCh5PujjZa(6G7GnDL2A4nUgfc1ZLEE73bFDq3g)7FD2zDpQsM172hEA3D67lV0Mtbav1vAhpxDaM8Jhh6oQVpky)Cmm90I8PMb3cJyaAvUrQrg2ANEppI9pjaExsOm3OTyR6a4L94GRIgMql0ygPfgShsFJbdo4HJsO4J73TBZQTpE4pJd(O3qcI3XcfrzxygAYOdcwaCKTEH)mrcgGikoGoYKrbYCex)W6QJNoazUu7F04Gq(YDlXIv6o8G6GUp7uQE2yZzF(DSV0oUM10w0DSri9VObkSpqajXfT7Xe3WOp3gR5JvRpODfgcae4c86DA)LBcdVHY2uvv7PvSgKOy0YQmpUmfKNZLea5vRVX)vDHmMM2NWqUAnIhbnmaJREuxacIgmS8rPMxVztaI25TXdTj31pUNJi6pM(GH8UK1ECAbe2Elr(2v3DHzXy9vOqEidCwR1Woh2X4nzRwS0Hj4RPHEP)utluFBb3SMoghlv83SpiSsdbQ1GD38WtmoufDPbhWgcm9PJitfve8vGufD6ZeCJW(yDTmhIByS1zzAC)(HgPFC)mVpAFb4(fG6XG7xAPJY9lmXpDezQOIGVeOdH73)11Bu5(TzM2(SYvW8UYfEfa1OEZx)Zb0Z23fMf0Wlnw58vN0)7Q)5p]] )
