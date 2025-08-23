-- WarlockDestruction.lua
-- August 2025
-- Patch 11.2

if UnitClassBase( "player" ) ~= "WARLOCK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR
local spec = Hekili:NewSpecialization( 267 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellCastCount = C_Spell.GetSpellCastCount
local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
-- local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)
local GetSpellTexture = C_Spell.GetSpellTexture
local Glyphed = C_SpellBook.IsSpellInSpellBook

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
    abyss_walker                   = {  71954,  389609, 1 }, -- Using Demonic Circle: Teleport or your Demonic Gateway reduces all damage you take by $s1% for $s2 sec
    accrued_vitality               = {  71953,  386613, 2 }, -- Drain Life heals for $s1% of the amount drained over $s2 sec
    amplify_curse                  = {  71934,  328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within $s1 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional $s2%. Curse of Tongues Increases casting time by an additional $s3%. Curse of Weakness Enemy is unable to critically strike
    banish                         = {  71944,     710, 1 }, -- Banishes an enemy Demon, Aberration, or Elemental, preventing any action for $s1 sec. Limit $s2. Casting Banish again on the target will cancel the effect
    burning_rush                   = {  71949,  111400, 1 }, -- Increases your movement speed by $s1%, but also damages you for $s2% of your maximum health every $s3 sec. Movement impairing effects may not reduce you below $s4% of normal movement speed. Lasts until canceled
    curses_of_enfeeblement         = {  71951,  386105, 1 }, -- Grants access to the following abilities: Curse of Tongues: Forces the target to speak in Demonic, increasing the casting time of all spells by $s3% for $s4 min. Curses: A warlock can only have one Curse active per target. Curse of Exhaustion: Reduces the target's movement speed by $s7% for $s8 sec. Curses: A warlock can only have one Curse active per target
    dark_accord                    = {  71956,  386659, 1 }, -- Reduces the cooldown of Unending Resolve by $s1 sec
    dark_pact                      = {  71936,  108416, 1 }, -- Sacrifices $s1% of your current health to shield you for $s2% of the sacrificed health plus an additional $s3 for $s4 sec. Usable while suffering from control impairing effects
    darkfury                       = {  71941,  264874, 1 }, -- Reduces the cooldown of Shadowfury by $s1 sec and increases its radius by $s2 yards
    demon_skin                     = {  71952,  219272, 2 }, -- Your Soul Leech absorption now ly recharges at a rate of $s1% of maximum health every $s2 sec, and may now absorb up to $s3% of maximum health. Increases your armor by $s4%
    demonic_circle                 = { 100941,  268358, 1 }, -- Summons a Demonic Circle for $s1 min. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects. You also learn:  Demonic Circle: Teleport Teleports you to your Demonic Circle and removes all movement slowing effects
    demonic_embrace                = {  71930,  288843, 1 }, -- Stamina increased by $s1%
    demonic_fortitude              = {  71922,  386617, 1 }, -- Increases you and your pets' maximum health by $s1%
    demonic_gateway                = {  71955,  111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per $s1 sec
    demonic_inspiration            = {  71928,  386858, 1 }, -- Increases the attack speed of your primary pet by $s1%. Increases Grimoire of Sacrifice damage by $s2%
    demonic_resilience             = {  71917,  389590, 2 }, -- Reduces the chance you will be critically struck by $s2%$s$s3 All damage your primary demon takes is reduced by $s4%
    demonic_tactics                = {  71925,  452894, 1 }, -- Your spells have a $s1% increased chance to deal a critical strike. You gain $s2% more of the Critical Strike stat from all sources
    fel_armor                      = {  71950,  386124, 2 }, -- When Soul Leech absorbs damage, $s2% of damage taken is absorbed and spread out over $s3 sec$s$s4 Reduces damage taken by $s5%
    fel_domination                 = {  71931,  333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by $s1%
    fel_pact                       = {  71932,  386113, 1 }, -- Reduces the cooldown of Fel Domination by $s1 sec
    fel_synergy                    = {  71924,  389367, 2 }, -- Soul Leech also heals you for $s1% and your pet for $s2% of the absorption it grants
    fiendish_stride                = {  71948,  386110, 1 }, -- Reduces the damage dealt by Burning Rush by $s1%. Burning Rush increases your movement speed by an additional $s2%
    frequent_donor                 = {  71937,  386686, 1 }, -- Reduces the cooldown of Dark Pact by $s1 sec
    horrify                        = {  71916,   56244, 1 }, -- Your Fear causes the target to tremble in place instead of fleeing in fear
    howl_of_terror                 = {  71947,    5484, 1 }, -- Let loose a terrifying howl, causing $s1 enemies within $s2 yds to flee in fear, disorienting them for $s3 sec. Damage may cancel the effect
    ichor_of_devils                = {  71937,  386664, 1 }, -- Dark Pact sacrifices only $s1% of your current health for the same shield value
    lifeblood                      = {  71940,  386646, 2 }, -- When you use a Healthstone, gain $s1% Leech for $s2 sec
    mortal_coil                    = {  71947,    6789, 1 }, -- Horrifies an enemy target into fleeing, incapacitating for $s1 sec and healing you for $s2% of maximum health
    nightmare                      = {  71916,  386648, 1 }, -- Increases the amount of damage required to break your fear effects by $s1%
    pact_of_gluttony               = {  71926,  386689, 1 }, -- Healthstones you conjure for yourself are now Demonic Healthstones and can be used multiple times in combat. Demonic Healthstones cannot be traded.  Demonic Healthstone Instantly restores $s3% health. $s4 sec cooldown
    resolute_barrier               = {  71915,  389359, 2 }, -- Attacks received that deal at least $s1% of your health decrease Unending Resolve's cooldown by $s2 sec. Cannot occur more than once every $s3 sec
    sargerei_technique             = {  93179,  405955, 2 }, -- Incinerate damage increased by $s1%
    shadowflame                    = {  71941,  384069, 1 }, -- Slows enemies in a $s1 yard cone in front of you by $s2% for $s3 sec
    shadowfury                     = {  71942,   30283, 1 }, -- Stuns all enemies within $s1 yds for $s2 sec
    socrethars_guile               = {  93178,  405936, 2 }, -- Immolate damage increased by $s1%
    soul_conduit                   = {  71939,  215941, 1 }, -- Every Soul Shard you spend has a $s1% chance to be refunded
    soul_leech                     = {  71933,  108370, 1 }, -- All single-target damage done by you and your minions grants you and your pet shadowy shields that absorb $s1% of the damage dealt, up to $s2% of maximum health
    soul_link                      = {  71923,  108415, 2 }, -- $s1% of all damage you take is taken by your demon pet instead. While Grimoire of Sacrifice is active, your Stamina is increased by $s2%
    soulburn                       = {  71957,  385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells. Demonic Circle: Teleport: Increases your movement speed by $s1% and makes you immune to snares and roots for $s2 sec. Demonic Gateway: Can be cast instantly. Drain Life: Gain an absorb shield equal to the amount of healing done for $s3 sec. This shield cannot exceed $s4% of your maximum health. Health Funnel: Restores $s5% more health and reduces the damage taken by your pet by $s6% for $s7 sec. Healthstone: Increases the healing of your Healthstone by $s8% and increases your maximum health by $s9% for $s10 sec
    strength_of_will               = {  71956,  317138, 1 }, -- Unending Resolve reduces damage taken by an additional $s1%
    sweet_souls                    = {  71927,  386620, 1 }, -- Your Healthstone heals you for an additional $s1% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount
    swift_artifice                 = {  71918,  452902, 1 }, -- Reduces the cast time of Soulstone and Create Healthstone by $s1%
    teachings_of_the_black_harvest = {  71938,  385881, 1 }, -- Your primary pets gain a bonus effect. Imp: Successful Singe Magic casts grant the target $s1% damage reduction for $s2 sec. Voidwalker: Reduces the cooldown of Shadow Bulwark by $s3 sec. Felhunter: Reduces the cooldown of Devour Magic by $s4 sec. Sayaad: Reduces the cooldown of Seduction by $s5 sec and causes the target to walk faster towards the demon
    teachings_of_the_satyr         = {  71935,  387972, 1 }, -- Reduces the cooldown of Amplify Curse by $s1 sec
    wrathful_minion                = {  71946,  386864, 1 }, -- Increases the damage done by your primary pet by $s1%. Increases Grimoire of Sacrifice damage by $s2%

    -- Destruction
    ashen_remains                  = {  71969,  387252, 1 }, -- Chaos Bolt, Shadowburn, and Incinerate deal $s1% increased damage to targets afflicted by Wither
    avatar_of_destruction          = { 101998,  456975, 1 }, -- Consuming Ritual of Ruin summons an Overfiend for $s1 sec.  Summon Overfiend Generates $s4 Soul Shard Fragment every $s5 sec and casts Chaos Bolt at $s6% effectiveness at its summoner's target
    backdraft                      = {  72067,  196406, 1 }, -- Conflagrate reduces the cast time of your next Incinerate, Chaos Bolt, or Soul Fire by $s1%. Maximum $s2 charges
    backlash                       = {  71983,  387384, 1 }, -- Increases your critical strike chance by $s1%. Physical attacks against you have a $s2% chance to make your next Incinerate instant cast. This effect can only occur once every $s3 sec
    blistering_atrophy             = { 101996,  456939, 1 }, -- Increases the damage of Shadowburn by $s1%. The critical strike chance of Shadowburn is increased by an additional $s2% when damaging a target that is at or below $s3% health
    burn_to_ashes                  = {  71964,  387153, 1 }, -- Chaos Bolt and Rain of Fire increase the damage of your next $s1 Incinerates by $s2%. Shadowburn increases the damage of your next Incinerate by $s3%. Stacks up to $s4 times
    cataclysm                      = {  71974,  152108, 1 }, -- Calls forth a cataclysm at the target location, dealing $s$s2 Shadowflame damage to all enemies within $s3 yards and afflicting them with Wither
    channel_demonfire              = {  72064,  196447, 1 }, -- Launches $s3 bolts of felfire over $s4 sec at random targets afflicted by your Wither within $s5 yds. Each bolt deals $s$s6 Fire damage to the target and $s$s7 Fire damage to nearby enemies
    chaos_incarnate                = {  71966,  387275, 1 }, -- Chaos Bolt, Rain of Fire, and Shadowburn always gain at least $s1% of the maximum benefit from your Mastery: Chaotic Energies
    conflagrate                    = {  72068,   17962, 1 }, -- Triggers an explosion on the target, dealing $s$s2 Fire damage. Reduces the cast time of your next Incinerate or Chaos Bolt by $s3% for $s4 sec. Generates $s5 Soul Shard Fragments
    conflagration_of_chaos         = {  72061,  387108, 1 }, -- Conflagrate and Shadowburn have a $s1% chance to guarantee your next cast of the ability to critically strike, and increase its damage by your critical strike chance
    crashing_chaos                 = {  71960,  417234, 1 }, -- Summon Infernal increases the damage of your next $s1 casts of Chaos Bolt by $s2% or your next $s3 casts of Rain of Fire by $s4%
    decimation                     = { 101997,  456985, 1 }, -- When your direct damaging abilities deal a critical strike, they have a chance to reset the cooldown of Soul Fire and reduce the cast time of your next Soul Fire by $s1%
    demonfire_infusion             = {  72064, 1214442, 1 }, -- Periodic damage from Wither has a $s1% chance to fire a Demonfire bolt at $s2% increased effectiveness. Incinerate has a $s3% chance to fire a Demonfire bolt at $s4% increased effectiveness
    demonfire_mastery              = { 101993,  456946, 1 }, -- Increases the damage of Channel Demonfire by $s1% and it deals damage $s2% faster
    devastation                    = {  72066,  454735, 1 }, -- Increases the critical strike chance of your Destruction spells by $s1%
    diabolic_embers                = {  71968,  387173, 1 }, -- Incinerate now generates $s1% additional Soul Shard Fragments
    dimension_ripper               = { 102003,  457025, 1 }, -- Periodic damage dealt by Wither has a $s1% chance to tear open a Dimensional Rift
    dimensional_rift               = { 102003,  387976, 1 }, -- Rips a hole in time and space, opening a random portal that damages your target: Shadowy Tear Deals $s$s6 Shadow damage over $s7 sec. Unstable Tear Deals $s$s10 Chaos damage over $s11 sec. Chaos Tear Fires a Chaos Bolt, dealing $s$s14 Chaos damage. This Chaos Bolt always critically strikes and your critical strike chance increases its damage. Generates $s15 Soul Shard Fragments
    emberstorm                     = {  72062,  454744, 1 }, -- Increases the damage done by your Fire spells by $s1% and reduces the cast time of your Incinerate spell by $s2%
    eradication                    = {  71984,  196412, 1 }, -- Chaos Bolt and Shadowburn increases the damage you deal to the target by $s1% for $s2 sec
    explosive_potential            = {  72059,  388827, 1 }, -- Reduces the cooldown of Conflagrate by $s1 sec
    fiendish_cruelty               = { 101994,  456943, 1 }, -- When Shadowburn fails to kill a target that is at or below $s1% health, its cooldown is reduced by $s2 sec
    fire_and_brimstone             = {  71982,  196408, 1 }, -- Incinerate now also hits all enemies near your target for $s1% damage
    flashpoint                     = {  71972,  387259, 1 }, -- When your Wither deals periodic damage to a target above $s1% health, gain $s2% Haste for $s3 sec. Stacks up to $s4 times
    grimoire_of_sacrifice          = {  71971,  108503, 1 }, -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal $s1 additional Shadow damage. Lasts until canceled or until you summon a demon pet
    havoc                          = {  71979,   80240, 1 }, -- Marks a target with Havoc for $s1 sec, causing your single target spells to also strike the Havoc victim for $s2% of the damage dealt
    improved_chaos_bolt            = { 101992,  456951, 1 }, -- Increases the damage of Chaos Bolt by $s1% and reduces its cast time by $s2 sec
    improved_conflagrate           = {  72065,  231793, 1 }, -- Conflagrate gains an additional charge
    indiscriminate_flames          = { 101995,  457114, 1 }, -- Backdraft increases the damage of your next Chaos Bolt by $s1% and increases the critical strike chance of your next Incinerate or Soul Fire by $s2%
    internal_combustion            = {  71980,  266134, 1 }, -- Chaos Bolt consumes up to $s1 sec of Wither's damage over time effect on your target, instantly dealing that much damage
    master_ritualist               = {  71962,  387165, 1 }, -- Ritual of Ruin requires $s1 less Soul Shards spent
    mayhem                         = {  71979,  387506, 1 }, -- Your single target spells have a $s1% chance to apply Havoc to a nearby enemy for $s2 sec.  Havoc Marks a target with Havoc for $s5 sec, causing your single target spells to also strike the Havoc victim for $s6% of the damage dealt
    power_overwhelming             = {  71965,  387279, 1 }, -- Consuming Soul Shards increases your Mastery by $s1% for $s2 sec for each shard spent. Gaining a stack does not refresh the duration
    pyrogenics                     = {  71975,  387095, 1 }, -- Enemies affected by your Rain of Fire take $s1% increased damage from your Fire spells
    raging_demonfire               = {  72063,  387166, 1 }, -- Channel Demonfire fires an additional $s1 bolts. Each bolt increases the remaining duration of Wither on all targets hit by $s2 sec
    rain_of_chaos                  = {  71960,  266086, 1 }, -- While your initial Infernal is active, every Soul Shard you spend has a $s1% chance to summon an additional Infernal that lasts $s2 sec
    rain_of_fire_ground            = {  72069,    5740, 1 }, -- Calls down a rain of hellfire the target location, dealing $s$s2 Fire damage over $s3 sec to enemies in the area. This spell is cast at a selected location
    rain_of_fire_targeted          = {  72069, 1214467, 1 }, -- Calls down a rain of hellfire upon your target, dealing $s$s2 Fire damage over $s3 sec to enemies in the area. This spell is cast at your target
    reverse_entropy                = {  71980,  205148, 1 }, -- Your spells have a chance to grant you $s1% Haste for $s2 sec
    ritual_of_ruin                 = {  71970,  387156, 1 }, -- Every $s1 Soul Shards spent grants Ritual of Ruin, making your next Chaos Bolt or Rain of Fire consume no Soul Shards and have its cast time reduced by $s2%
    roaring_blaze                  = {  72065,  205184, 1 }, -- Conflagrate increases your Soul Fire, Wither, Incinerate, and Conflagrate damage to the target by $s1% for $s2 sec
    rolling_havoc                  = {  71961,  387569, 1 }, -- Each time your spells duplicate from Havoc, gain $s1% increased damage for $s2 sec. Stacks up to $s3 times
    ruin                           = {  71967,  387103, 1 }, -- Increases the critical strike damage of your Destruction spells by $s1%
    scalding_flames                = {  71973,  388832, 1 }, -- Increases the damage of Wither by $s1% and its duration by $s2 sec
    shadowburn                     = {  72060,   17877, 1 }, -- Blasts a target for $s$s2 Shadowflame damage, gaining $s3% critical strike chance on targets that have $s4% or less health. Restores $s5 Soul Shard and refunds a charge if the target dies within $s6 sec
    soul_fire                      = {  71978,    6353, 1 }, -- Burns the enemy's soul, dealing $s$s2 Fire damage and applying Wither. Generates $s3 Soul Shard
    summon_infernal                = {  71985,    1122, 1 }, -- Summons an Infernal from the Twisting Nether, impacting for $s$s2 Fire damage and stunning all enemies in the area for $s3 sec. The Infernal will serve you for $s4 sec, dealing $s5 damage to all nearby enemies every $s6 sec and generating $s7 Soul Shard Fragment every $s8 sec
    summoners_embrace              = {  71971,  453105, 1 }, -- Increases the damage dealt by your spells and your demon by $s1%
    unstable_rifts                 = { 102427,  457064, 1 }, -- Bolts from Dimensional Rift now deal $s1% of damage dealt to nearby enemies as Fire damage

    -- Diabolist
    abyssal_dominion               = {  94831,  429581, 1 }, -- Summon Infernal becomes empowered, dealing $s1% increased damage. When your Summon Infernal ends, it fragments into two smaller Infernals at $s2% effectiveness that lasts $s3 sec
    annihilans_bellow              = {  94836,  429072, 1 }, -- Howl of Terror cooldown is reduced by $s1 sec and range is increased by $s2 yds
    cloven_souls                   = {  94849,  428517, 1 }, -- Enemies damaged by your Overlord have their souls cloven, increasing damage taken by you and your pets by $s1% for $s2 sec
    cruelty_of_kerxan              = {  94848,  429902, 1 }, -- Summon Infernal grants Diabolic Ritual and reduces its duration by $s1 sec
    diabolic_ritual                = {  94855,  428514, 1 }, -- Casting Chaos Bolt, Rain of Fire, or Shadowburn grants Diabolic Ritual for $s1 sec. If Diabolic Ritual is already active, its duration is reduced by $s2 sec instead. When Diabolic Ritual expires you gain Demonic Art, causing your next Chaos Bolt, Rain of Fire, or Shadowburn to summon an Overlord, Mother of Chaos, or Pit Lord that unleashes a devastating attack against your enemies
    flames_of_xoroth               = {  94833,  429657, 1 }, -- Fire damage increased by $s1% and damage dealt by your demons is increased by $s2%
    gloom_of_nathreza              = {  94843,  429899, 1 }, -- Enemies marked by your Havoc take $s1% increased damage from your single target spells
    infernal_bulwark               = {  94852,  429130, 1 }, -- Unending Resolve grants Soul Leech equal to $s1% of your maximum health and increases the maximum amount Soul Leech can absorb by $s2% for $s3 sec
    infernal_machine               = {  94848,  429917, 1 }, -- Spending Soul Shards on damaging spells while your Infernal is active decreases the duration of Diabolic Ritual by $s1 additional sec
    infernal_vitality              = {  94852,  429115, 1 }, -- Unending Resolve heals you for $s1% of your maximum health over $s2 sec
    ruination                      = {  94830,  428522, 1 }, -- Summoning a Pit Lord causes your next Chaos Bolt to become Ruination.  Ruination Call down a demon-infested meteor from the depths of the Twisting Nether, dealing $s$s4 Chaos damage on impact to all enemies within $s5 yds of the target and summoning $s6 Diabolic Imp. Damage is further increased by your critical strike chance and is reduced beyond $s7 targets
    secrets_of_the_coven           = {  94826,  428518, 1 }, -- Mother of Chaos empowers your next Incinerate to become Infernal Bolt.  Infernal Bolt Hurl a bolt enveloped in the infernal flames of the abyss, dealing $s$s4 Fire damage to your enemy target and generating $s5 Soul Shards
    souletched_circles             = {  94836,  428911, 1 }, -- You always gain the benefit of Soulburn when casting Demonic Circle: Teleport, increasing your movement speed by $s1% and making you immune to snares and roots for $s2 sec
    touch_of_rancora               = {  94856,  429893, 1 }, -- Demonic Art increases the damage of your next Chaos Bolt, Rain of Fire, or Shadowburn by $s1% and reduces its cast time by $s2%. Casting Chaos Bolt reduces the duration of Diabolic Ritual by $s3 additional sec

    -- Hellcaller
    aura_of_enfeeblement           = {  94822,  440059, 1 }, -- While Unending Resolve is active, enemies within $s1 yds are affected by Curse of Tongues and Curse of Weakness at $s2% effectiveness
    blackened_soul                 = {  94837,  440043, 1 }, -- Spending Soul Shards on damaging spells will further corrupt enemies affected by your Wither, increasing its stack count by $s2. Each time Wither gains a stack it has a chance to collapse, consuming a stack every $s3 sec to deal $s$s4 Shadowflame damage to its host until $s5 stack remains
    bleakheart_tactics             = {  94854,  440051, 1 }, -- Wither damage increased $s1%. When Wither gains a stack from Blackened Soul, it has a chance to gain an additional stack
    curse_of_the_satyr             = {  94822,  440057, 1 }, -- Curse of Weakness is empowered and transforms into Curse of the Satyr.  Curse of the Satyr Increases the time between an enemy's attacks by $s3% and the casting time of all spells by $s4% for $s5 min. Curses: A warlock can only have one Curse active per target
    hatefury_rituals               = {  94854,  440048, 1 }, -- Wither deals $s1% increased periodic damage but its duration is $s2% shorter
    illhoofs_design                = {  94835,  440070, 1 }, -- Sacrifice $s1% of your maximum health. Soul Leech now absorbs an additional $s2% of your maximum health
    malevolence                    = {  94842,  442726, 1 }, -- Dark magic erupts from you and corrupts your soul for $s2 sec, causing enemies suffering from your Wither to take $s$s3 Shadowflame damage and increase its stack count by $s4. While corrupted your Haste is increased by $s5% and spending Soul Shards on damaging spells grants $s6 additional stack of Wither
    mark_of_perotharn              = {  94844,  440045, 1 }, -- Critical strike damage dealt by Wither is increased by $s1%. Wither has a chance to gain a stack when it critically strikes. Stacks gained this way do not activate Blackened Soul
    mark_of_xavius                 = {  94834,  440046, 1 }, -- Wither damage increased by $s1%. Blackened Soul deals $s2% increased damage per stack of Wither
    seeds_of_their_demise          = {  94829,  440055, 1 }, -- After Wither reaches $s2 stacks or when its host reaches $s3% health, Wither deals $s$s4 Shadowflame damage to its host every $s5 sec until $s6 stack remains. When Blackened Soul deals damage, you have a chance to gain $s7 stacks of Flashpoint
    wither                         = {  94840,  445468, 1 }, -- Bestows a vile malediction upon the target, burning the sinew and muscle of its host, dealing $s$s4 Shadowflame damage immediately and an additional $s$s5 Shadowflame damage over $s6 sec$s$s7 Periodic damage generates $s8 Soul Shard Fragment and has a $s9% chance to generate an additional $s10 on critical strikes. Replaces Immolate
    xalans_cruelty                 = {  94845,  440040, 1 }, -- Shadow damage dealt by your spells and abilities is increased by $s1% and your Shadow spells gain $s2% more critical strike chance from all sources
    xalans_ferocity                = {  94853,  440044, 1 }, -- Fire damage dealt by your spells and abilities is increased by $s1% and your Fire spells gain $s2% more critical strike chance from all sources
    zevrims_resilience             = {  94835,  440065, 1 }, -- Dark Pact heals you for $s1 every $s2 sec while active
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bane_of_havoc                  =  164, -- (461917) Replaces Havoc. Curses the ground with a demonic bane, causing all of your single target spells to also strike targets marked with the bane for $s1% of the damage dealt. Lasts $s2 sec
    bloodstones                    = 5696, -- (1218692) Your Healthstones are replaced with Bloodstones which increase their user's haste by $s1% for $s2 sec instead of healing
    bonds_of_fel                   = 5401, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the $s2 yd radius they explode, dealing $s$s3 Fire damage split amongst all nearby enemies
    fel_fissure                    =  157, -- (200586) Chaos Bolt creates a $s1 yd wide eruption of Felfire under the target, reducing movement speed by $s2% and reducing all healing received by $s3% on all enemies within the fissure. Lasts $s4 sec
    gateway_mastery                = 5382, -- (248855) Increases the range of your Demonic Gateway by $s1 yards, and reduces the cast time by $s2%. Reduces the time between how often players can take your Demonic Gateway by $s3 sec
    impish_instincts               = 5580, -- (409835) Taking direct Physical damage reduces the cooldown of Demonic Circle by $s1 sec. Cannot occur more than once every $s2 sec
    nether_ward                    = 3508, -- (212295) Surrounds the caster with a shield that lasts $s1 sec, reflecting all harmful spells cast on you
    shadow_rift                    = 5393, -- (353294) Conjure a Shadow Rift at the target location lasting $s1 sec. Enemy players within the rift when it expires are teleported to your Demonic Circle. Must be within $s2 yds of your Demonic Circle to cast
    soul_rip                       = 5607, -- (410598) Fracture the soul of up to $s1 target players within $s2 yds into the shadows, reducing their damage done by $s3% and healing received by $s4% for $s5 sec. Souls are fractured up to $s6 yds from the player's location. Players can retrieve their souls to remove this effect
} )




spec:RegisterHook( "TALENTS_UPDATED", function()
    talent.rain_of_fire = talent.rain_of_fire_targeted.enabled and talent.rain_of_fire_targeted or talent.rain_of_fire_ground
    talent.cataclysm.rank = IsSpellKnownOrOverridesKnown( 152108 ) and 1 or 0
end )

-- Auras
spec:RegisterAuras( {
    active_havoc = {
        duration = function () return talent.mayhem.enabled and class.auras.mayhem.duration or class.auras.havoc.duration end,
        max_stack = 1,

        generate = function( ah )
            ah.duration = class.auras.havoc.duration

            if talent.mayhem.enabled and active_dot.mayhem > 0 then
                ah.count = 1
                ah.applied = last_havoc
                ah.expires = last_havoc + ah.duration
                ah.caster = "player"
            elseif pvptalent.bane_of_havoc.enabled and debuff.bane_of_havoc.up and query_time - last_havoc < ah.duration then
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
    demonic_art_mother_of_chaos = {
        id = 432794,
        duration = 60,
        max_stack = 1,
        copy = { "demonic_art_mother", "art_mother" }
    },
    demonic_art_overlord = {
        id = 428524,
        duration = 60,
        max_stack = 1,
        copy = "art_overlord",
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
            return 15
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
            local n = GetSpellCastCount( 386256 )

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
        tick_time = 3.0,
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

spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237700, 237698, 237703, 237701, 237699 },
        auras = {
            -- Diabolist
            demonic_oculus = {
                id = 1238810,
                duration = 60,
                max_stack = 3
            },
            demonic_intelligence= {
                id = 1239569,
                duration = 10,
                max_stack = 3
            },
            -- Hellcaller
            maintained_withering = {
                id = 1239577,
                duration = 8,
                max_stack = 1
            }
        }
    },
    tww2 = {
        items = { 229325, 229323, 229328, 229326, 229324 },
        auras = {
            jackpot = {
                id = 1217798,
                duration = 10,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207270, 207271, 207272, 207273, 207275 },
        auras = {
            searing_bolt = {
                id = 423886,
                duration = 10,
                max_stack = 1
            }
        }
    },
    tier30 = {
        items = { 202534, 202533, 202532, 202536, 202531 },
        auras = {
            umbrafire_embers = {
                id = 409652,
                duration = 13,
                max_stack = 8
            }
        }
    },
    tier29 = {
        items = { 200336, 200338, 200333, 200335, 200337, 217212, 217214, 217215, 217211, 217213 },
        auras = {
            chaos_maelstrom = {
                id = 394679,
                duration = 10,
                max_stack = 1
            }
        }
    }
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

            local ArtConsumed = false

            if buff.art_overlord.up then
                summon_demon( "overlord", 2 )
                removeBuff( "art_overlord" )
                ArtConsumed = true
            end

            if buff.art_mother.up then
                summon_demon( "mother_of_chaos", 6 )
                removeBuff( "art_mother" )
                if talent.secrets_of_the_coven.enabled then applyBuff( "infernal_bolt" ) end
                ArtConsumed = true
            end

            if buff.art_pit_lord.up then
                summon_demon( "pit_lord", 5 )
                removeBuff( "art_pit_lord" )
                if talent.ruination.enabled then applyBuff( "ruination" ) end
                ArtConsumed = true
            end

            if ArtConsumed and set_bonus.tww3 >= 2 then
                local oculi = buff.demonic_oculus.stack or 0
                removeBuff( "demonic_oculus" )
                if set_bonus.tww3 >= 4 then
                    addStack( "demonic_intelligence", oculi )
                end
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
        summon_demon( "mother_of_chaos", 6 )
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

        usable = function()
            return settings.cataclysm_ttd == 0 or fight_remains >= settings.cataclysm_ttd, strformat( "cataclysm_ttd[%d] < fight_remains[%d]", settings.cataclysm_ttd, fight_remains )
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
            if set_bonus.tww3_diabolist >= 2 then
                addStack( "demonic_oculus" )
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
        cast = 0,
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
        cycle = "immolate",
        notalent = function() return state.spec.destruction and talent.wither.enabled and "wither" or nil end,

        usable = function()
            return settings.low_ttd_dot == 0 or fight_remains >= settings.low_ttd_dot, strformat( "low_ttd_dot[%d] < fight_remains[%d]", settings.low_ttd_dot, fight_remains )
        end,

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
            if debuff.wither.up then applyDebuff( "target", "wither", debuff.wither.remains, debuff.wither.stack + 6 + ( set_bonus.tww3 >= 2 and 2 or 0 ) ) end
            if set_bonus.tww3 >= 4 then
                addStack( "backdraft", 2 )
                applyBuff( "maintained_withering" )
            end

        end,
    },

    -- Calls down a rain of hellfire, dealing ${$42223m1*8} Fire damage over $d to enemies in the area.
    rain_of_fire = {
        id = function() return talent.rain_of_fire_targeted.enabled and 1214467 or 5740 end,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = function ()
            if buff.ritual_of_ruin.up then return 0 end
            return 3
        end,
        spendType = "soul_shards",


        usable = function() return raid_event.adds.remains > 4 end,
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
            if set_bonus.tww3_diabolist >= 2 then
                addStack( "demonic_oculus" )
            end
        end,

        copy = { 5740, 1214467 }
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
            if set_bonus.tww3_diabolist >= 2 then
                addStack( "demonic_oculus" )
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
        -- in_flight referenced in APL
        velocity = 30,

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
            if set_bonus.tww2 >= 2 then applyBuff( "jackpot" ) end
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

        usable = function()
            return settings.low_ttd_dot == 0 or fight_remains >= settings.low_ttd_dot, strformat( "low_ttd_dot[%d] < fight_remains[%d]", settings.low_ttd_dot, fight_remains )
        end,

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

    potion = "tempered_potion",

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

spec:RegisterSetting( "low_ttd_dot", 11, {
    name = function () return string.format( "%s: Enemy Time-to-Die", Hekili:GetSpellLinkWithTexture( state.talent.wither.enabled and spec.auras.wither.id or spec.auras.immolate.id ) ) end,
    type = "range",
    desc = function () return string.format( "If set above zero, %s should not be recommended unless your target / enemies will survive for at least this many seconds.", Hekili:GetSpellLinkWithTexture( state.talent.wither.enabled and spec.auras.wither.id or spec.auras.immolate.id ) ) end,
    min = 0,
    max = 21,
    step = 0.5,
    width = "full",
} )

spec:RegisterSetting( "cataclysm_ttd", 11, {
    name = function () return string.format( "%s: Enemy Time-to-Die", Hekili:GetSpellLinkWithTexture( spec.abilities.cataclysm.id ) ) end,
    type = "range",
    desc = function () return string.format( "If set above zero, %s should not be recommended unless your target or one of your enemies will survive for at least this many seconds.", Hekili:GetSpellLinkWithTexture( spec.abilities.cataclysm.id ) ) end,
    min = 0,
    max = 21,
    step = 0.5,
    width = "full",
} )

spec:RegisterPack( "Destruction", 20250822, [[Hekili:S3ZAVTnss(BXyr4iAhllsBLypqsl2DwSaZG5MBb8EF1Y0uu2ersuhjvC8bd9B)6hK9ZQFqzjBNzd2ftseBwD117Q6UlEt0n)7BUEwsD2n)r8G4HdUmoUFu8Gbx85BUU(P1z3C96K0VKCp6VSkzj6)(pYQQl3KwNxSc)SNwuKmddJQInLPON)qD96QF(SZUpV(Hn31pTy5zv5l3Sib)gPLjZRX)70ZU5672KVO(xxDZD6iq0WlJhEZ1jBQFOO8MRVoF5VGGC(Szz0HNvLEZ14HF6Glpno(N3E7)m)BBVTUmF1xYQ3E7xtkZtUBrw12BtwnB7T)6YLfimiB7TvpMSED(Q73(BB)TwaeHbWVUkVopzX2B)B)RFF7T9sJhE1Sl)u4nxViVQUcVcZRZwI)l)bHMLTcpbZU5VJqZgQr16NwMuvNvwn9XmeAMwIEfeIGOtz19ZxnpRCvYI(LzltYxHqTjJ3EB0GT3gS9w4bmcnGy6aUBZ859fMGYS1fL19RQrChkKo)sYa7T92553)q9u(0GaYfiO88ZApcpbr4NfsF8DfvveOamUZh0kcOSoRrCoduKggsKiTOhN9WwYtXVWxZOiXrigzYISvOv3geFB1ugHPzgOdJbKMjzA00hZxSy6IIQSPPi8JSQOueTXUUmVaHrpT9wmfWaaJNM9T0fBMjGx0N0VoU)djvttlkwmR4Xv0N3t65TpJZnbNdjejMGVS3uD5lXrPIfhzJyg4aHg5ZCf2sgbO3yHYkn8G)8LjR2GvPAOogGW0zBkjwh2E7jeMbwAwraePhwTOOwqIcj1DUDPU4xfPU4DvQl2OySrPUihsDr7Kux0HtQdcHEHsDXoK6IDk1fVZsDXyPUlCARtrs96nirJc0mEF6mSZdbPsy1gFvROszUGHpMLGjKnWOX3GlTdpKHqs2RZsRXJwsyADz2xXuN(rQVP36MHywZqNgeuyNDK14VSNzwtSbwJjDxRS3VFynFsH1Os4BzvyKz6dOG2A5v8FOg9)UMfzhuGyfRrVvwD(Co8Ahp(VTyd6pMvGI0QjCqbJs)1T3IFYJOOwZkB)Dr5Hhs(ArAJrocyNsdgI(7yioToh9dard1GwwqkKGak(5ftREiPCwt4CCZ7n03S0YS6kevBkchrEb(A2kjwmjerM547kwu3FZ6M46WpAwwA(sIjpYVtTVcmTH4aSNNSzbcJJexQRrYqOqNrt9Qz5KvcGty3lwM4Sg8OiRuSWcEv0qvVXZPP3bz52nQcIknSfJAuChlN6wVJWhgH14exbkovHST5g57rqZEeNBixCZxuuucLFWzWwH4ldQZ4JglcdDWCYELKCMxqluiAR96cfay6WRdRfFM3qMO1EBP8(NLTJu1p4X63laDQpPLesCkoqa5Dd4jQ60COlNWaK3XdJYD8)POC7yHEWuUTmV7QYTfq((NLTJu1p4X63la96RCRwnaAqRKyeHcyLhEztqE3LK(Lz4IKQhzh)ryCdmIOiTFfx4Ul4MrqrenFrY9L4YTceOkhDW4ojEwsWj0yCzRE15arm6puOmO4NnpVmdk8qPkY0SOBc6wCfRhlozEOtr7teqYJrCW(0yxzR1K6K0fpvT0ws7TzcOGy0)VsQcZlZqRyeeKlmHscae8Cy)lAfMQtkVhliJE006IPZYZiIpdvmjyiTK2AcA8XkSMqwwzsVrDE6xWf9wUAqqyESd8okQDakIaxGfbsFkDbA4KxTclUBjPCkt0iHNX9p4KDa5SyBcHwj5nJ)TKGRgmbNatZMyA2QSL549gHyDO1En3Q3djO)8UnLR6pFdYywzw6d4jOfNrVeUGalt(grVRjr1zzeRuzLjZYtPzzYjAIVsatVxCSIk)hXu0rtCrfnv28vtNVa7mPDinazgI0Is3dXqYR3iv2bwjwOdKB7dbzCw0eGlxD3wRW498brYq5qMuxwS(HNeRMb3qhJqHj7FEhi7kIsAKwtZ1L7SHBQypN8LVCDzXxZMnvGulYlGW9yrLipHtpyqXRYXr2Ch0YcBnP7efhke3LOpbgYHPIx5nhRPCdTGPeroXsqTo5IgyesqkTcyZQvzlMoldfLbdwMJrGtI0ctWOl(iZ(41qTpZmfq03BIZHYHu3qqb7fZqsBRQqtEcYwroo(eESvC8sDueKZC0bwKJf8EVknFvwZsffNfYwyYxZShOLyD8G0bNWubruiuyDP1s1NmnzbTQmiBiyRe09hwSwG7wfazutcmKnDouY40YKNEiBjNXlx3RPCUALZ4VoYsSUTLo0Rc8ku(2fzFTan80mBHDrjuhgKXMZ0l9lefoErunroxskRnzfXS7w1QUwMHGqRoMwu6WvQ1OVbwCdnoEf07fYtb9szFllDtDR3BX0BKe1me)UQxnZrV16iyvnT0LPflVBtLMZD4G84jSnKS6S6)pKytq49vte4cMdkdHWXD7yal0NFzYiffgY8)ip2nv04vzHGii32sCLd8Gl5ZEUyI8ntb)HcR4joOMHU0juI5IpjmsoE403gw)rnCeZcjcbESxKt65wuXP0Y5EiT8gZjFf4HMdgIhKxzrcjO47wK8)LjXT8jrbEyJadKD4LuINV9NP2fLF20LfyYepwErcn4lGIqTCrr5m3JCDE9u5rsLJylOWwsU02zj5(1ymzMdx8h5H5DEyWXLoM4KhoRjlHwtOzTcjZNwUjhVjPMC5BjOApQDicfVAGi9VnDcjcHLSnSe18(F2viHQr0DqNBfQU5W06zxUxpmi5GjbvauI3KRmcf3lwGH8(eeLesipJH26qkG74rzUGbmQZ9yrFw6HQ(hHlk4jVqxMb(5IM6sc57H5aZvITMlAHASWN3FiBnAl6wHjNSURlrP)TaKfB21LsX15hnc)STlfTCKQxuwMQW1z2AfMnYHhzkgEhf)nemogGIQifhd)5IeEr3I7NiJKaHCsUIPeag5evseMAznWPid1qnEGOkSIfnff5yN7QJrFJVZd55usqBNkRkmlNKDZ007MgxBiznbwZPwFvXWPWA(dKSQkvFN)i2SxxBhPOah1wK66xYrKONFvVVXM9(YWIKflkECAj6TIRNwToB1SSsXDOZNADU(PYI7ZwLNwj90g7Hcp1y0DskuGEAv1lT54wjutQwLz6UfcO5qi4ckfnuphZs76CNwckoiGjqHwwiMJhbO4obglGhONKyZLvYIYOvIfAqVy6L0ooZkAvxOIYX0f)zPqL0IBqXs7LIJwRIYkd(kXbZorDKzwEKNBoFmXkHJOBiQXu2pDkrD2qEiYuVM3XygHNhjJRmZEsikUeKfokVTFC2H04RmVdayubyVAoH9eEiMnzS1wbJZLnHRuqyZMWbR0QQkNQT3QS02Tn(T3BP8wn9ysETA0EVx9ZhQjWoOF8WwJ8k68GxcIVFwNJzXRWvZeJx5DeUobKNyk8iZEJ8FlVipvt3NqrgsqEZrUiMhWEzFCeZGwDp3OBm3u8b93)fh8w1z2p7B)(JAUcbQN8REKTwM4tAq)iX88BSv3MxKjB4HmpzaG(89eODvLnvZ9MRyGLti0Ei5wdLGNb8EcX7yPenT4GAunAfXKJoAdfmNBUd3rTBXtGkxPL6lS3ImF0rdDLw8LABIJ1TiOtvIsUSnboPLUQRK1QP3AlxioeIvik9QNnbfitHJP3y7qrP6EEKnN)G)tIW1Nef9h08Tf1q4DHc0LFSneSHUJBdXwZNvmTDIayy)qo(hYXVQYXbupem)aJyN8iJs3qLoLU5ymx6Sngrz3pmxgnt3)pBLyWCmeA7yftvJvUfznn1tGJ0gc4JBF5BkkijY0zIgeNGqOadrGrupmmPEhPR0P5xUWj233kQgNs(ITbp2Jh)OQABOafUrfrKnQzTDVBrr5MdiVTJMJc1ks0tFQMyGRrm0yCRGmDNg02SjT9DqgRmaMy14NAh1B2H0RL8XMjrNEIHrgnuDgfhPQudpIzyfeT9Xrjc4xP0pg)9A(hcI2IjFOQeyMXhz44zQTXpmBta7QQRTu9LXCSVjJFNWDKDx8PDILy29nD)PkEmReR4VPQ1LfqGeKDedFr6y()u2Ov7BxK(EHnR9MXziSrFcXAN2WNDobyhj3QTnqVer)xS0)ylI)KxMiP40DN9spWA9iUJJk20PtExOoUVzzaUP5L7RB3tVgVwWNtJMqC84AJDSmvs2o0lGrVBNLIidCPUVRD7EOXWOGLD4RHkHH80KvZMExz(YQ6IvooKqMQc)5ooJHCy006(gXkHmNL5)175CPKTSSXHRrP7wS8UK6BSFnKBlriVbaH40jliQGTtZCSvQILcN4njSOXi(6mT9zvzADFRyQlU)EKcW8nylJIx1f6n9zAYAIpIU3yxeAEe4wQgUBeHzpnop5pmVcp5puGhaI1ur79KL5RPW9VTPUal6LU92FV4E8FmhFF8)7eq9VPGbP2KVI9V2E71lkq)3i4wdbgji3BNU3UxeUY8wwsXhULum8fINTKm0Klm1TM0jovpTskFed3T)QwBG27qiFWsQm8rnMOkizW08GD2vsg3EcNi8SPzlQqlWb40TByIeRvQE16iHk2nHYutidSBlCGjuGZPFek1mZ7Gscr1wTHTkPiCnropz7TvRroyMJ1eKf)BuKrlLcSsc(mFHg)QMoi7cKL4T0Up7k84qHaI(NCLRfyLly5CAtK7gGDCPdlW43TlWyHfO2M38wScJpORqdnPoFwHeH0hFihH(KQ2I8VNG0KQZMMNsILsCX(pXMP)Vr4()tvM46eRov1YjXPIq)Pn4rLnFEwkEqpvSbhZ3k0OEmb)FXeeYqWKPMihafwBAwP3udCTi6WsnE)UuJ3)l1yPL6oeldNRIn(k3)r7znQdsG(nBAl0GRYVFfcdlODgqsZD9j6vUIAefqPGilZrHI5n)uDRpDmXWBbELMQZnq1DVduOyhui9GySqHIFxqHIbOqgIXd7NxQgZwJZXSVDSVyxE(D68)mFAGUHTNkeAJTAqF6nnraYYrKYgpaOXXU0UJat0WrWOQGWrO28KvCunraZ4yKao6m4zInLeS1L7kW2J4gRskZemprJsgqWPTvnBuVPj4OiMAe5a6PTBpyHRYmJkGTtl0rxxOpBsHTHauTOA)vhhnEeBP)vx1MZjVcQWBHtZdT2ZrcfxvSZt(nqBOthqFHdMUK6LXL1G(dIK1tHh6i8qV6kjKw8SDFJxB4Z9L5llWvYab9Qe0JrX8aCoAah2nq7feFguROkUyGXc1LqAlLKooZcvUrUup(w7IwPV2kxWa86msVwl9lQq2qnKS28oAzqUBBgqKIZf2ctgRwOkfDUxIGpP3aL2qYCZ)gfVekYMv1yNz4)knSZfpHTRLSQcx8UznrWI7lD4JMlkmiK428YILOWF)1)RF5JyBp14xnFvnTkFeNAvj4kbHCYsWVKfitq9TH6cRplcnKcFiSkB6ylaf8WlIubU9rduAbVE5CY3ZdG8T54VVNME(mQCE3TCcgHoV7a7)HtDExxUm(8WQSCV3jhW5rSDj3rV2G6QLXvL3FEZ2Sulp8BFdybYQiusIAC59t7YqNu)J2QsNBghhK2QsRyb)02APjd0U9YgVtZ2ejhHJ1Q9GD5XbHRz3j(Ztp7q9aUhj1t2uAvhMdeW6j)P3po4HKTDOz)S2)hGwRxaj)CB7rROGHEeEH8zV1iQzTnv8kJAkUkLAmfgpAMoBmfaY8WNikd5hy5i15ZjNPNPTN(DBRVWCqCh53u6ThExlXqp8ZVJneRD)Ggy7SU9g4G)G7A3sA2sCzDjCV5ZDsuEKY0XRAgG8a4XBroYpq8UlX(5dQ)EkerlmkFwkhibo2PGsVKm2BOjMJ8S3RFdgiup0dv)pVZsRDIxP1Ecj06JLdpnCRLELW5ISqDhnkmXlehTRtDL)TYIZflzNYvdWstRi91Prki3pjSutrsLJSEuOyY5SLjgSE)5IKJfRli)jqDj3BtgtfW4hWvV0kf(iWDIWOVlRSkReF2eL)gCq1j1)AZ68fBJC1mY6nMYjZ8jZEbCFfi1EJ9e6m(eVkrUxuumB68nLpjq10NNjUELxovwG4YMaOIs)DeXfBPKSy8M2c9gVCslGamBIGkh(Rkj(p7MksqPjxvxIJglzXIBA(k9GC6J9qEtZ3H8OyCtCPCfcLQWB1cIaNVe)r3U5er(tK9p4NWvg7)DdI1ndh8Ys(Xba)dyN0i3v93(B)o5SeH)qJ)lfRqZe5X)u7Upl)5Kgbt8zs5Nu2)CHh3l6BHEaugPPHuaayGHCab(bcSVo485gaBKDMN2JLWvZa1jUcoKdiWpqG91bNVyVktOGZ7xGZa7W9kPqbN3Vahb2T)gGns2MQ3n7KEGCTEjSHDcJPRR9ob(dgG)bE)d82ha)gH3fRZOJOIEq3(PE96fDc5JszpPa1(GnWhgE0y67i)sNWgPPlsWPghrdic)GtyeggSRin71KFppWk7qo85N3nu6TMm2r6WhSVCC((N66uFgozacVCbMjXdA1cmj)EMlrHdfH)mNWWS8RtKENLFDazZYVoEX3AYyhPdVFeFzgO)K7irnA5hEmsow23G)Gb4FG3)aV9bWVr49oe4ea4pKoE80J)UH07SJhhq2NaNaFX3AYyhPdFW(YX57Vh984DGtVYYVE6XF3q6Dw(1bK9jWPxx5xpjJDKo8(r81uDRyTlJFQt1TYuHaLVCza5CR8yVQUO(9efaWadXRsfeBhJ1ESNa1jgdoeV8rVRf34ad(dgGFJWBTqxmD7ud6zd(FWTNXXdE(zNdYEnegpiSDXUJOPteWpS0fsYO2FEphbQIuY(g8hma)gH3ULUJ1eBaG)bq6gywSjD7hA6eb8dlDHKmQ9L2CLj3kpG9LPngjPKRS53Xb4HhJe4JgCGHFKnYJXMJbmLY2WLNvZBxENMvNdxEwnVpVRlls7NS6PPZwxzZNLPXTVNhPql7a8DgRJ7OZSdDOMAHb1g4rkpxM3fB)OuMh3(EESZrmdFNCe3rFAh6EXrSns55YCC07MxVdn89bY48gihLA8jIFXIS0AaqdoiFXDVNbtPVye27AS0hA47dK9GQyyq(I7Epd(s31cg7iJbXBk(NNF2CKr2dnYW7XRXWX9Iozq)HhBqOc9CaqG7CmHHt6zpPdN13qBUJCo3rnZDlp5vKwE2BiTuFU3N0Y(4Yh9RKkhHfyVS9wFG7DCv146cr6sjP4RgXNXnH1I554Bf5F5VS92hQRxx9ZND2951pS5oeMV8SQ8LBwqWQuC3Ff)Vtp7Uff3DgYjXJjL479s(QZ(BK54F10yG(D8mDwtps5m0OWneLPZWhW1nnxxiey2(B458A2e8l4jaRTTCzoUdEIwpiLV04Hxn7Yprh8)af72pJ7qwXdpDWLNgfJxS01xvFwbYgl3ny)y(8X473YKbbhXADSaV2jJpRjDc0OGFElz)J421XyEVu5JKMYZyPEdlcJ3E7U36sJ8bdu0tArdj7FTsnp)m)316vzVmCnUl4AmiUgBaxb6RADyUOAfFSy9ystmRzoJ(iVlvngPN9r21fBS7sY8Qu4i4sY0LvE8lELRLU(RsrfGtxNiF6zRZ8f1Cq7cjUTROQP1PLv97s0pgg9bkkqxq)xuJl9aI(U7pNVWwrAxWDwlkfs0Xy9k8CD8c7ZODzDeByDyVUlcIt7EdTSlOPs4vAeDWC8pPNz3Lhhnmu55qjpFCSKLRxNfBS1fRHcACspZ(BLxSgRuaBX(cB4KDzT22ikvDZfl6MlsWj3bkdJ9sYAqvjWZSm2ljSbLTSTmn8Hrb1yj)ytEbiUeITr6)N(akwBUSHhZWlO5ycU1DgCup12asG520zyJqKx4IyBWufFyiQGOdioI7dNbwhYiC)3egHa7xMKmDORqRTDtyqYOsyWqVaNTTjXjJneIpRTpa)y(TDxirn8RXAtMI)QARrKsSBPqvUhAsr2hPn9rKwpAr0tDvCEya3eap9nIDRx7oxP7LdfbLwrklOi3ab3vbCpkYfhvCycDVj88Amc(2dUY4HdLyWYdddcXU(Oi(W0afKEv6Pfb9eEz8bsIyLYZEQXjGdwTFAapk1EPr4OEum3up0iuWUOO6bETrNbLw)yqpE3Sy04lE(z9rrM5rJB65ehhhgyUx6nzSuh9qavOnOebAmq7FbFSP07(qNo8y9fnRlVeocQTnD8G(xe(8Z6aB05i(hWC4GSoAyG(iODwNWGEhP2pDet5uTh6CsdGa6Fotax9HHb6nbNjxgCKgGaA9nsI6C(LaFqQLjAH1okQ)WNFwVD9jiz88Zkp5sKMJQQ0BNUtdEggWf5Nmg34hf1yynUobseLJGKo5CvBnWqofbjSzUPfYgwGEZkKXCHe5doc2mfss0AJi85Nn28br6ksNxreRl0mzPNBZXxniaQv9f2yGr5B2Tr7XhYzI1S)KDpjeeIm7hUF(PG7YnGir1mL23xqpOUK1jGM)am6ZfgmBoffJoV1CbAk(ODWwSnKj0O14ZnynwW6jJ0ly9uRb5nrhihydW7nZVT8AICDpq2)lHxpcSF1jq6vNmMRqnSWTZqlYnVA(jbiE2Op7jUOIDilMUyb6d1v4c8WYMGxebpwxeYTZtLuFtJiDIJispj(4w)UYXMQzSu8HQnNnj9OgcfJslgb75wc4PPtPnPNqRw70inxFTK9Mrip1a5t2hL23ULXIqGiJUO)NduYxeTAoP5x4MLqoXXAaNlUDmueq8BZRPeEAg6Jj51FSklD8BOGtirj59x4HilMXdLIrmwL8XfdEVTgg3OmYXqUvZ3q8AIeTvLCcxsaYxX3MIpmfrMf)Q(gi9TdUf6F0RrfOOK1B4jhjzof7OYO27M1p)8rWTtmT1LQrmfBven(wBsXQwH4vuvbkmx7onaiMMtVl6p80b9JoUNGfLwpO6wzW37kPx)8o)6ejJwXM5tXrBlgaERLiASOsFHIhhDYvxD8rcHI18DGMyvdmkCGOiBl24oenzptXS3ohQUUcfNetFs6N08Nul4Jq2y6Pr4iLGHyGpAiyelrxQP9aL0HN5wWZpiWWswD2useShqow4nMqHxOQZnoAa9Q9jNHLZx7t435Oo(s4cbP5yn8)yZMxNrQO89dg77xgBGGTGrd9GnRxKddolWNmnMxUg)NmBcc1vrtoIvIziXi1QjVzDiJSOzDv672FxMg9zjaWnfsGrpqoZPseluyqUPwXe8ekD(eS)XEyhKYcKOC1Afrej4T(M2fP(ZbIFsOMvkGtDlOaOlAvhG5v1(mjnrQJKg9gKiXUfBfC27CnDrlvTo3IgYHNWZdBDa7xSi7)Gog)2g1bqqhYcj(f3bRCwgOxqcu7kfdkCM3isg3AYN8JobSvKe7vRlEeL2f6N3urTzPynFY4O4bUSA342A9tLf3NHs2VQpEPP7P0KVOdtWK7hrLDuwbeDX8DYCBXoiC82dcoYMFPDBPXknif04brdjzy)lmuS24aWFwkfxK5oPb1K2eYjJXjmo8yXLhu549IQdRHcrqJCLM8l01V9I10S4WGBAYQztVRmFzvDXkMl5aceVlj9lZW3haaaQuvrLXxHOmFzum3Zd7rMrmXIjsp0fEvvekfWDfpaaU85jcxG6P8GzApB8m2nbQ84HhYIqDzYtpKTea(kfdDhD6da4xL4kG4gsH(bwAv2yFJp1fbW8nae1CapnuRUSVGuO)JZOXly7L8HZ8UAlBpeeZ9nPuXCnlKrOVuObwpElHFVC(wosARhfTSdzTY0r74pB1orVAjoTZ7Qg2SxtnUC37(NHJTItg0(eYYl29jKzLDIitzwar2Zf3nTWqf8DZieqrgWIjfEH(U)G5yi(bPn3U)WGEwcdGb0tQlrGAHcrv(K(PfNBhTBylZhvsOqQpGzXahXIH0zc78zgILpshDC17iP4Cp2SJSWoKa0qiwUHtvIa5gkngnNpVB8gDA8PCPjP7RaqGImY4PgELwpBJKUfQgT(A(K3eOuEuQbErJz(zF3(nRyCK6808V41PjqVYnA(m7DeK1wlxNvMrvMZ5WaZ0IUSmzxQelWRJhPjWfhe31O5WlcCLgQSdodcKwwsVSdQvhwJAoOagJ56KiyKqy)mChlC6l7arbzCsSugeJ56ZQADru9erQGP4HpikqIRRpbssimJjY1glW0w7WWsX92qz)lbsdQXkgyEt6a3QZsTZck3DPTcfc6DziPH5UZvqm0yjeTubr4Y8fkF62aO4MtYvnr29cbrHbgdXvbjgnJ5qskKJXh)u5Y3)N40Y6oXqIjjSKb0PLtWXGLb(onaCVm12lLyHJ3a041peN7WM8omu80YYwpQ(NLFTjJHjb6P(4sCuXITLsz3(gVEN1nMjvPaInWBfDhrUJHOxeFXYX)DATVL7vdyqjDsiy(4Jgea9aK8WaQdmbavMHB)r0TcaXuUmqUzGpj(IbAfJi6Ib4dnxrvvGYtoFGL1aUNl0EF0PMozwNybdqLsmwdCGRyE0u8nmffqpAAWu2Wa97HD7LFFCe4DuVPZmGNvPlyElVgRePF91zz(zE6I9PlMlKkRcziW8SoYfGdd1VN(TxGFOR2p9g8kU9BgUm8NenzSexp0twE8EJLh3fwEmOmJolpYelpQtS8O9elxFw3jwESrwESfwE8lGLJ)lfOxg5QdfGKMoV52kHzPsu2LgFlRAMqRAYRfY8YRqlDY9yFpIjSX1LzFfVsrSlnXw37uyhODXW0o3SxiANw7Qcse3ij)7hAhEsN(aUlei4AfFj)rVh9Z6VuHd81IeT)6PaV8vFT4lOWB(wtfuXKQ2DSw8WZStZishfWBR3K7tIgW)AI0GOYy10bSWxKNKjE)EWre0bCCOgpI)vfFps1CwJeokXgjWN38q1aLSo4xiXrNYW(G(VhPmEJosYtCuXPieWq3ncJg9aNSab6V5KdgM4KAOpYDJyywkr(dL)EK089PoeN(0sgWoqA)7cNzjEzs4DllEJXs8qm1C6Jalw1FvVMn(GbAf2Tzoepb3K80BzyzPLz1v4uTrtf61(A2kAwEmEm90LSw)O7G3injWgY64urA94PoGYttVtTvpPnMNFg6y8lHnaiJONxrecxyom4DYntMnZct74Mcrr3BVnRHyIQJXhkKI6wZYPbraOdi2Rrb7wfItt))hH6pGniVOCXTJdr77qTBvWs4rOlLp68LQlHphvjI72qQ9DQl(nynj8nBi99g1LiddjXqb8EO8spVy4iLu9OpyceBQE68nIirgJrwUzkpvpjEFiIF9nqhgsIHc49azMEMQpUsacJdW]] )