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
-- local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
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
        cycle = function () return not debuff.immolate.refreshable and "immolate" or nil end,
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

spec:RegisterPack( "Destruction", 20250812, [[Hekili:S3ZApnoYw(BbTQ9ednHydPByejxn35QvAgn7DVsmR2VrWKyaRojoRTt3dRq53(wpC9(upCibO7fnJAG4YN6uN3Ntv1jxNC9FE9vZYAYV(FMoiD4GZts7NG(L0RVQ5Xv5xF1QSPFj7E0VSmBb6F)h51nvRN2uuUe)ShNxMnddI6Y1vtrp)HMMv1)8jNCFrZdRVT)0YfNuxSy98m8BmTk7Ug8Fp9KRV621fZB(TLxFl48NCX1xLTU5HYQRV6QIf)kcYfZMLthEE90RV64J3CZF(q(MB(VZQq)dA(kwU5MRYZQlr)80n)ogEhp48Jts)5n38BllAkYMV5MF5F9hBUP300Hxm78pfV53387UbukdqO))tiaD1JlNU5MVHgf63rig7XNI(FGhF9vZlQBQXKOIM8f4F5FsO55lZUDE(SR)7O1zl5SE1JlYQBYRQN8TC06CAf6vQkYqe68M(flVlVAz28(v5lYkwwV5MXJ2CtYGn3eT5g4bCjAaP0bC767URV0euLVQSQPFDdI9sH0PNtgyVn3CxX9p0mrmniGCgckp9KXJWtqc(zX0hFBzDnbkaJ70bmziT1zdI1BHI0uvS8l5njY0cec(1m0VHglFjpb)cFnNIehS5MMS55lrRU1lwuUCcNW0od0HXbs7KmjzY3kMpFY8Y68jtr4hzvrPigJDvvrjcJECZnykGfaMoj)VMoF9mj8I(K(nP9FiREY0YY5Zk)2s6Z7P8C2ZeCtW5qbrsj4l)n1x(kCuQyXbUiMrEqOldzUIzKra6nwOS2apepFr2Y1yD2wQJfimz26kI5Ln3CeHzGLM1eaJrsDZlBKKOqsDN6wQl9frQlDBL6sTkgBvQlXJuxYwj1LS)K6GqONPuxQhPUuVsDPBTuxkwQ7mV260KuVAns0OenJ3pDg25HKujSAtOQvuPmFWieZsWeYwy06BWN2raYqij7v5tBWJwryAvv(xXuN(j6VzW6MXywZqVge0yNDK1eUSNDwtQfwJnDxNS3VFynFsJ1Ot4zSkmYm5HSLZy8kXh0G(VRy0cWaXkxHER8MI7eWJnE8VnFn6hZkrrAHWuueT5sgL(BBUb)eCGF5vSpxwE4HSVwoT1ihbStObdr)CmeN0uG(aGOHArlhifsqafa(8j1pKvnRnCoH59w6B(0Q8MAevBcchrEb(A(sfwmjerU54BlN30F9Q246WpAw(0IfetEKpNAFfyAJXrOFx265imorEPUcjdvS8E0uVCwbzLa4e2)ILloBapkYQelSKxfduny8CY0BHSC7hvbrLw2IvnkHJLJ9R3r4dxI14KxbAovHST5h57rtgyEzzf53mZm4ey7pIfqmZ5i6xoyKBGD0UMQetqWaaySumx7SLB7kwhKMqn0LtxN9wXSD5A67co42tK)qa0IGa0XHKRsmXt5agYhhKB2wVRY66IjqnrciVM7AL(uFsm)yP07D5Uxv6dz27UsVxO(DbhC7jYFiaArqacsP3ivXDTsVE1dOb5sIPekaxr4OTbfEB20VmdxvwZibfpcJBGrqLy8P4c9DMW8ckcQ7MNDFfU(Uab2kqhmUtI)LemdnMy(QxFoqeJ(dLkBk(z3vuLdfoPsfCAx0TbPlVInJDNmp0PG9ejK8qetSpnwx(AnRjB68hRx4kjFwMdAig9)1sT4UQC0kgbb1czOLWabph2)mMWutw19yzz0JM0uozwror8zOM5blPXWQHO1hRXAI5zXP8gnft)ckcATQhbH5PEW7Ke2a0ebodlcm9XPZrdN8Q1yXDhjXtzIwj8CU)ENSdiNL6si0jjVD8VMeC9GmeeyA2htYxMVOiVU16aZKTWQ3dzOFE76QL9VBnYywv(0hWtadNrVeUaclY(lIExBITZYjwPYRYMvmLMvQGOj)krC9E5XkR8FaxrhnXL10uFlwo5U5y)jSH0cKzislk9qedPOzTszk4LKHoqHTpeKXzDtaUA1GzwHX7reIKHY5mRPQC1dpkx9dHHooHct2)8wq21eLmiT2MRZ3Ad3uXEb5RyXQQYVMpBIePwMxaH7PYkrbcNEWGsuvKdC5oGXczM09IIdL8Ol7tGJCyQ4fbZXAlpbdmviYjwcI5KlzGvibP0kHnlxMpFYSCuugCyzpgbbjYimbRU4tS7J3a1(m3uarFVnohkhsFdeLSxmdjTTSgn5ziBff44teHxjWl9rrqo7rh4qowY79YPflZBxQO4Sq2cZ(AU7aTKR7hKo4yUkiIcHcRBAJs9mNMnNwfhKneSvc6(jlx7WTRIHCQjbgQMohQyCAr2JpKVqW4vRt2ebxT2B8xh4iwxwPgdQGWsL7DE(xlrdFAURWUOeQ9dY4Yz65HfIIaViQMiNlzvn2SIy3DREvARYrqGPJzeLoCLDT6BGh3qRJxj9EP8uqVu(FLpDDdZ7TC6nkIAwIFx3RM9O3yocw2ql150Yf3UU2W5oCqEIC2gswDo9)htSji9(6jcCg3bLLq4eUDSGfMZVkzKIcd5(Fuh76AA8Q8qqKKBzex1apes(8NlNrF7uiEO0kEShQzSpDcTyUetcNKJho9TH1F0dhXUqIuGh7e5KE(fv8kTCAaslVYCYxaEO9GHeb5vvMrck(25z)V5kCRqsuqe2iWa5h2jT45zFm1UO6ZMSOetMeXYltObFbueQvZlRM5FKRkAMOosQCeFbfZi5kB)LI7xRXKzpCX3Zdl48WGJlDeXjpCwtocTMqZycj3nPADbEtvT5Y3rq1bu7qekEXaz6plDcfcHJSnCe18UF21iH6r0TxNBnQU9W065wU3mmi1Gjbva0I3uOmcf3lwGH8(eeLesOiJbwDiLWD8OSxWao15ESOpp9qD)JWff8ONPlZOWCrtDjH89WDG5lXw7fTqpw4t7pKVgDfDR0Ktw3nvO0)MdYIT76sR46IJsry22vIwor3lkptv46m7ScZw5WxAlgEpf)ngmogGIQOehJ45YeEz3I7MiJuaHAsUYPeag5evseMA5mWPel1qnDGSkSMfnnf5uV7QJvFJVXd55ysqBhRQkmRGKDZKP3ojTXsYAsSMJD(QYHtH18hOyvvP(o)Zu7EDDDeKI8uBrQRFfhrYE(19(MA37lhlYMpV8BtQqVvAZK6v5lNLxjVdDHuRZvpwvEF(YIP1kpT1EO0tTgDNIcfONwD9sxoU1c1KQvzNU7GaApecHGszl1ZZSWwNB1sqZbbmbk2XcXE8iaf3jYAb8a9KKAVSsougDsSqd6ztVu2XzErR6cvunMU0pReQKrCdAwApxE0gvuwBWxipy(jWJmZQJ8u75JjxjCeDdrnMW)OJzNid46Jlt9AFhRzeEAIkUYn7PGO4sqw6P82HXzhsJVY(oaGrfG9Q5i(teHy2MXgRcgNQAcxRGW2nHdwPvDvoDBV15tzBB8RV3s1TA6Bzfn6r79w1pFSHa7G(Pdzg5105bV0eF)SohXJxrOMjhVYBiCDmipXw4r29gf(wErEQHUpHImKG82JCropGDY(4iNbT(EUr3yUj4lgq4lo4TQZUF2x)9h1Efc0p5x9iBTmXN0G(jY553ARMLxKnB4XCpzaG(0DeO9vLnDZ92RyGJti0oi5wlLGNd8EsX74OenmCqpQgJIykqhJHcMZTWH7LST4jsNRWO(s7Ti3hDYqFPfFUXM44Clc6uLOulBtKxAPV6k5SA6mB5sXHqScrPx9CjOazkCe9gEhllv3lGS5ch8FsgUHKOy4GwSTOwcVlwIU8(2qWh6wUneBSFwXm2jcGH9UC87YXVOYXrupeC)axYp5rwLUHkDkDZX4U05BmI2UFyVmA2UVGUkXG9yim2XkUQgVClQAA6NahLneie3(Q3SuqsKTZeniobHqrwIaJOEyzsdosxLtZVAHtCVVvunoT8fzbp2te)OUABSefUvfrMnAyTDNBrr7MdOUTJ2JcfedKZBr6giyDRHE1olCmdj8zs23IC0Ajd1Nr5rQZCebMclhMQhVMwGMVhLVZO8TeIVUuTD(EILdbPX2yXTaaS3L(24YDbVX2w59Dc3r1O8N2kwI9YLs3fOYVLxH17xxZCma4UMSVt4RRg3lJ22z6ExTm3XPzS7FMLGZcjqMTA)H260m9KcPXo54s0N6K7vtbWsKVJTi75onFEBbXFmlgBi1ZKgf0f5Q1zV1JbXU)YX1lORR1HQumvlt7h(UdUyIfo2N7YULz7m8gyiPwqb7LmQLkHH8KSLZMCBvXI6MYLEoCo2Q(TJ9WtdgTTyVl5LUvWYc)A1e8g2TcLMz5IBZACVTD8sZjAupioD2CI6iBAUdB3QCH0jntjvRwZ6RYn2FtTP1)TrPP8(7rka3TgBRu(kMqVHntYwnhAxGcaWI(5aU1NH7Aqy2tR7uXdlQXt(dL4bGyn10MmzvXkkC)L1nLyrVPBU5pkVh)J7Wxi()obu)jfmi1gCFJS9V2CZvZlr)BcCRAaJe1q7IshwsPUwsP7VLuk8frNVKS00jS1vLmjo1pUujbfl9sJAELjC20o(GJCBeJAervqXGP9b7TrHmIDYIi8Sj5ZRrlWb40CBzIjqB3shjuP(ju2AwyGn6G9mHcCodJqP7ROdkjevB9gRQIIWve58Sn3uVc5G5oSMGQ4FRImAPuIvsWN1k04x22kzNJSeJ)tK)JL4X1G7KSzcLR5yLly5CAZEdANo6Wcm9n7cmvAbASPjVgRW096k0sZKlKviri9BpuGqFs1sr(3ZqAsn5tkMsILsEX(VJnt)FIW9)R6C51jwDQMXjXjNq)O14rLF3D5tXd6XY14y(wIg13YW)lMGqgcMm1g5aOWABtfvuX1TBPMUBxQP7(LAQYsDlILrWvXgFv7tO9Cg1bjq)2nlfAW1f3VeHHL0o4hPjS(i9QornIcOuqKLfOq5DTFudZNoMyeSaVwtScSE3DGcL6HczgeJdku6BckukafYsmEy)8cF3h4PnSA33o2xSpp)ED(FsGDVi6PXiHq9h0NEdpKGSAeP8Xda6AsJsNwGHXg4iyuvq4iuBvZjoQNiGDCmrch9g8mXMsg26YTLy7rcJvzv5sMNOrjdi4WAPYw1BAdokHRgLcUllyHRQCRkGSPf6iJl1pmtb35f)Q2F1ZrshXw6FXfSCof1ufERtAFOZE9rS8QIFoUb3iLoG(shiCf1lRlRb9hKOQNcp0lXd9IluqA5Zun4w3yufJ7RkwuIRKbc61zOhJI5b48RaomW9ermdgf6BejJpEDjK3JPuLQsiv5g1s9KgyTlysFSkxWb8QCspoB6x0HSLAi5SPzWyq(BxfqKc(U9lBVwQkfoWbPU7H05j0gCKWy8HWgO6hkwK(tuivOGFw2G93H)vAKPZFeB6lBznU(EZAdYf3Y4WNAwuKsijY7QkxGIq(3(p(1pInp1GF1ILn0cbs87vNHlweYpmz1KnhzLQFGluhYvKAJiTkBBMka1eji2AjUtqdu9HGE5cYxnhaPKlW)qpO7Izu7OO74WfcDu0b20eVMf8DVVeZdV4Z9EJC2JPh6x6I3zBWG6nMZvv36CpfL9nvVrbYWjuEKgC5DtNSWKu)EhpPZ9jJ9shpHjwioiSoU))S9K261n2Li5L4WXyN5QaoJATBGXpoTtd9ZEEIs7stRlAypwb7NmiQI47NjWnbEMaboobEpBRoVBqH52oGUebh9i8c1JfRvuZzhK4fg10CvQ0ZiSEQj92ZiaK5HpfvwsHW)PD7hSUsH9G4oiSPmyp8(wIXb4NFl7vvB)zrW1bK7vWb)E31UJmXv4YMs4bZN7KO8LAtNOWAaYdGhcMt9CmA6ySFHG6VLcr0bJkKLYEsGJFOPmRAJ7EnI9ip79YF3)Jnd9q3)ZBS0AhhuAThrcT(q1WtJ34OngCQml00rJgt8m5r77GzfExM4u5Q6PDQ9D0pjM(Y0JdupoAok7iPYropTuC5C(Yed2G)MFuGfRkj)eO0L7SjJRcy97I1G0kL((C7iPrFBEvDEf(4lQ(nKbvN08lowVVilYv7iBWyQGmlMm3149fGuhm2tOZ4diRc5EEz5Sj3TU6rjQM58m23R88PYsex(eavu6VJiUylLKftW0wO345tAbeG5teu5WFrjX)OBQidLMCDtfoASS5ZVU9lqhKtFShYRPFNKF6GtX9xLQLiuQgVvlicCXc83F2ThAYFIS)b)eUYy)pRrSUz4GxwioXa4pa7Kg5UQ)MF)pih3i8xk5)A5s0mrE8pX2GA1VzOrWeFSv(jTTyx6X9s(R4aakN00skaamWq2JaFpb2xgC(ulGnXnZZ4Xk4QDG6fxbhYEe47jW(YGZNTtLj0W5DlW5GD4oLuOHZ7wGJa7MFhWgjFF37MDYaqoMxcxyN0y66AVtGFVb43X73X7qa8ReExUkNoIA6zH7N61J8Tgj6hYHP9bxap(OK4dgb9Ah1JpyBx2GJToIwyeh)bVajooA7qBeEZEr130pA5h2p90wsmF1PLDLy8b3ljVV)X(oFOXJheJqmFWzC6aM2amP)eFK(9PC8jEbIn5yVO9Zqo2pSTjh79nF1PLDLy8gsmMBW(t(Jm1QNa4XO4Ozxd(9gGFhVFhVdbWVs4DNdKca47BhqH58FRq7NHdi)W2FGuwEZxDAzxjgFW9sY77B6bkDR9afyGuVcYXH58FRq7NHCSFy7pqQxE54WOLDLy8gsm2wDT4DCJFQt11YwHcvVFAa5KR94GQ(O5vnfaWadjOsjK6gJnECGa1lgdoKG8zVTf)ypd(9gGFLWBJqzSKwtDupxW)d(DroAWtp5DqUlUWObXSf7wIMErGWWsFijNA)5DCePAsj7AWV3a8ReE7x6o1qSba(7bPBGzXL0DyOPxeimS0hsYP2N7YvMA3ab2xMXyuKsUWLFhpGhEmkGpzWEg(jUipw7VgWukxdxDwTVD6DAw9oC1z1((aVQQCA)SLpoz2QAx(SSnUD98OeBzhGV3yD8hDMBOd1xmSO2aps15Y(UChgLY(421ZJBoID47LJ4p6t3qpioIRrQox2JJE786TVHFiqgN3a5OwJpX8ZNNpTba0GdkuCp4zWw6lwH92gl9(g(Ha5aOkwguO4EWZqO0DJGXoWAq82I)5PNShzK7qJ8wKHd7LC0G(dp0Iqf65aGa38zIJh3ZDshE3PiJ5oX7CN0o3mEYliT8KxrAP5CVlPL9XLp63ivoclWEo7wHGB)C1n46crA0jtXxDIpJ7JRL3vGV1K)B)BBU5HMMv1)8jNCFrZdRVfH5loPUyX65eSAkUbYI)7PNC78YBpb5K4Bzv47ftXYt(fYC8VA7Tq)bEMoPTnRCcAu4EQYKz4da762RtecmB(D8CEfFc(v8eG12wSOa3eqrRhKY300Hxm78prh8)af72pJBYwPdpEW5hNKIxS01xDFEbYgP2qz)yXDJW3)LXdIoG39zbETJgDsB6eOrb)Cgz)J425XirBu5JK(6ZiL2llcJ3CZ239ttcbd00tyOHI9pMuZtpj(CJ2D2Zdxt7cUMcIRPwWvGwZwhMlQwXhlxnI0h0ANZKpkA0vJq6zFKFDYg5VKmVifocUKmDzLN(Sx5gPR)Iuub401jYNb29nFw9x0UqIznwvdToJSQFtI(PWOpqrb6c6)S69P7r03Fl(8z2nt7cUZ7YPqIowRxrGRJNzRkTlRJulRd31DrsCA77jMDbn1cVYGOdMJ)r9S7U8WKHXAphk55dtvSC9YSytDUyTuqJJ6z3FR6I1ALc4l2NzpRSlRvwVSu3nxQSBUejNC7Pmm2jjRbvLGaZYyNKWgu2YUY0iegfuVP8JT5fG4si2gPfIgcO4DkZwEmhVGMJX4U)z0b90Btir270NXTcrbHlYDstD8HJOsIoG4iUvEg5CixIBHNWieyl3KKPdDf6SZDcdsovcdg6f8K1gfhpYsi(82cb8Jf3gEPe1WVgVtBk)P6TorkXMrHQ9p0SY8pYB5Lsk7sjQrFmYOaAa90xKNghb9seZAV0n(s)RwkcQSI0wqj(bcUPe4FuK7DQ8WKA(t451Aa(SZ1YOHdv4)Qdddc5MgPm(WvqLeU1Ajgr9KEz8zwIyelWwYXrGdwVDCapk9wXr8L9OyUTwWrSKztzTh8AJodADoYOEIMHXLJo7PNmhfzMVCuBlR4W04i7TIVXJuAiisOcT)MirJb6Em4JvLzZl64HhAUO5njM4lH66thoO)zXp9KjWU8ue)dyo8qwVCyK5iOnMN4OEhO3oEKZivVf8CulGaA)oJbx9XXrM9qNXNhDGbGa6CokI6c(LeFqPJl6G1Ezs)Hp9Kz3(tsY4PN0EY5inhDvPxpDNw8mosiYpEeUVrkRXW77DsKikhbjDk4QU6)HckcsyZEppKpSiZEDiN5cjYhDaSzkKKOZ(y4tpzT3fI0vuopJiwxSDYI9Zzj3mWfdIG60FXTgy0(242Q9495mX7vGQUNKIrrL9d3oa1WD1(xKSAMw3)lQhut26iqZFag9fcd2nNIcHx0zVanfFWwyl2fYeB1A8PwSglz9Kt6LSEA0F9gBcK9Sb4DM5xgVMix3dK9)C41xc2U7Ki96tg3vObw43zOd5Mxm)Kaepx0NDexuZoKdtx8a9HAQCrbyztYlIKhRZIf25PsQVQrKo2tePhLEiZVRASPgglLFOEVDtrpQLqXP0YrWEQJaEAB0AJ7j1P2ooXW1hJS3oc1PgiDZ(OSc3UmwKce5YZ6)5iT8frRMJA)eHzjKtCSgWPY7wdfbK)(a2wcpTd9BzfnFSoF6OxrbNyIsYBVWdrwmthQeJyQo5tig8wBnmQvzuGHcRMVI41yfARo5eUKaKVNGLQ2I83BWrkFbfZG(hdAurAkz9gE0bkMtXoQSQ9UE1tpDaC3iZyDPBetZwfrJNztkv3kKOGRAqH7A3Rba50C6Dw)HhpOFYH9KSOW8GAALbF1SuE9t78RtKmyIn3nbhTTCa4mlr0yrv(oqEuYrxCXHhifkw7300eRAGrHdefjRwKBr0K9SfZoBo0DDflpj2(AWFC7pPwWVezJPNbHJucgIb(KHGrSKCUH2dushbMBHi)Gillz9ztlrWEa5yH33cnEHUo3Oe8Tvdf3IAgwEFTpHFNd64lHleKHJ14)FB28MmsnLV3zSVDzSrs2cUCyaSzZICyXzb(GRX9Y16)KBtqQUkgYr8smdjgPxn51RI5KfdRRY(U700yolraUPqcmMbYzpvIuPcdkm1kNGNuPZhJ9p2d7GuvGeLRgterMGZ8nTns9Nce)KTAwPpsAmvqmQTlIh4CQf6FY2pyUCsgkGN0ZJzUfdlcHF0cfaisavgFybdWRXKfYLumb7ecMEmgVsKmHk(NcJobS)GeJiRk)gkxi0hVUMAirZe74rjPd8zkT1xYQhRkVphLbEDF8sZ09Lnhe7Ni86IOIr1j3pclg(VhdWtHddEq0bUCxSLloEj7OWgpgAOcdjBNiyzhVmnc8Jvs(e9YhOmQ2mAqW06CMgFO8seQs5BpPhKOM4ld2NPxz31rPDXHb3KSLZMCBvXI6MYLCVLreiEB20VmdFs(baOwb)0gFnIY8LltfUF4pYoIjxNp65HiOcwqPa(lgbaWvpjq4AhpreNb7uTZz3eOkcvDip4Xfzp(q(ca4RvNYT0ZpaGFrcUaIBOevgyvp5J9v(arebZ3aqu7r90sT6Yw2rH(7hFINXo)ecN5n1UPUpiM7AsPM5AEGJqFhGg58KNe)9Yrp5aLDfu2YoK1kBN6IF0kRHzHm8AN3x5L5VME05(3yolNOeVmODjKvxS7siZRierMYUaIQNlHBAPHk57MtiGImGhtk8c9n)zMXs8dk77C)Hr9CegahOh1uHa1CnIQ6HWZio3oA3Wz2p2ZSdmng4iwSKotCNpop88r6OJREhOeN7H2DKf3HeGgcXYTCGpKi3qPXy485nJ3OJtpwinPCtdacuKtgp2YRW8SDPY9h1Q1x7hkMiTcHsnWlBmlm77UVteJs0NN2)suTMiZ63y4ZS3bqwBDCru5gv5oNJJStl6YYKFDqCaVoEAJaxCqCxRMdplYxAOQo4Siq6yj98odvDynA4Gcym2RtIKrcPTAWFSWtFENvjiJtYLYGym3Cw1RlIUNisDmLpxajrkCDZjqrcHBmrT4yr221fowkVbhABTiqAqTwXaZBYe4Ulv4wwRqiVldjT729qjeDubr4Y8fREWZaO42tYvpr2DcbrJbMcXvbjgTJzFskuJXh)u1I4)dCAzDNyOWKKwYa60Qj4yXYqpUJwGBuPXoQKkDYdGgV55RCl2)1HXYhKv(6r3)S6RnEemjWm1hFIJAwSDukB2B8YDm04Muvci2cVv2De56)HEr8vch)70AFR2LfWGs5qkW9XNmic6bi5HbuhysaQkh34IOBfaIPCEKAF8EC6zdmkgrYzdWNNTY66iTNC6ahRbC3sGDtYPMo5wN4bdqLsSwdCGlhEYe8L)efqpAAWuwK(TXyyxB9rjG3U82EQaEwvUA4mEnwjY8INZZ8Z(0Lgs)hxkvwnYqK9z9sFaoo28g2ZU69qxkF6LRvE73SCn2pkz8ifUECGS80DglpTlS8uqzgtwEInwEsNy5j7iwU5SUvS8uRS8uhS80Nblh)lLOxg5QdfGKHoV9gcHDPsu2LwFlNAMqRAYRfZ9YRrl9Y94FtdtyJRQY)kELIyxgIT(3PWoq7sHPD(zVq0oJgnfKiUvs(3p0o8Ko5bCdcqY1k((3JEp6xy)kfoiuls0oJNg8kw(1YVGcV5VARGkMuX2XA5JqZwnJiDuaVTbtUpkzWr8b3IOQy1Kb8WxuNKXb)EWre0bCCObps89f(oKQ5TgjcuIpsGV4YJ1duY5GFMehtkd)RQ)DiLjy0rrEsGkEfHag62rymOh4Kfiq)vNCWXeVudZrUDed7sjQFf4VdjnFFQdjOpmYa2bc73LoZsIYKi6ZvIwAL8HyQ90hbwSQ)MznBcbdmkSB7CiF4Qj5PZyy5tRYBQXPAJMk0R918L0S848y6PlzL5r3bVrAkGnM3ROsm6otDaLNm9w9M0KXyE6jOtyVc2aGmYEELriCH5WG3l3mB2mhmTdBlefDV9wVcIjQpMqOqAQBTlNwebGoGyVwfSzkeo)oY6)BGCOAAdYlnxC74q0(ou7wfSeE4)M1Ba4AYLWNbQe8wkK6Fl5sqJMG3rH0)7ixIlGKudkW7PQl5C1Ur23rUKsQF0hubIl1)aWDBiXfProUAQrQFs9MnKqACapGKudkW7jRm5K6NSVydJReGW4a8]] )