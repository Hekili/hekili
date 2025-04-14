-- WarlockDestruction.lua
-- January 2025

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
    accrued_vitality               = {  71953, 386613, 2 }, -- Drain Life heals for 15% of the amount drained over 7.7 sec.
    amplify_curse                  = {  71934, 328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within 15 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional 20%. Curse of Tongues Increases casting time by an additional 40%. Curse of Weakness Enemy is unable to critically strike.
    banish                         = {  71944,    710, 1 }, -- Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect.
    burning_rush                   = {  71949, 111400, 1 }, -- Increases your movement speed by 50%, but also damages you for 4% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until canceled.
    curses_of_enfeeblement         = {  71951, 386105, 1 }, -- Grants access to the following abilities: Curse of Tongues: Forces the target to speak in Demonic, increasing the casting time of all spells by 30% for 1 min. Curses: A warlock can only have one Curse active per target. Curse of Exhaustion: Reduces the target's movement speed by 50% for 12 sec. Curses: A warlock can only have one Curse active per target.
    dark_accord                    = {  71956, 386659, 1 }, -- Reduces the cooldown of Unending Resolve by 45 sec.
    dark_pact                      = {  71936, 108416, 1 }, -- Sacrifices 20% of your current health to shield you for 200% of the sacrificed health plus an additional 33,815 for 20 sec. Usable while suffering from control impairing effects.
    darkfury                       = {  71941, 264874, 1 }, -- Reduces the cooldown of Shadowfury by 15 sec and increases its radius by 2 yards.
    demon_skin                     = {  71952, 219272, 2 }, -- Your Soul Leech absorption now passively recharges at a rate of 0.2% of maximum health every 1 sec, and may now absorb up to 10% of maximum health. Increases your armor by 45%.
    demoniacs_fervor               = {  94832, 449629, 1 }, -- Your demonic soul deals 100% increased damage to the main target of Hand of Gul'dan.
    demonic_circle                 = { 100941, 268358, 1 }, -- Summons a Demonic Circle for 15 min. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects. You also learn:  Demonic Circle: Teleport Teleports you to your Demonic Circle and removes all movement slowing effects.
    demonic_embrace                = {  71930, 288843, 1 }, -- Stamina increased by 10%.
    demonic_fortitude              = {  71922, 386617, 1 }, -- Increases you and your pets' maximum health by 5%.
    demonic_gateway                = {  71955, 111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per 90 sec.
    demonic_inspiration            = {  71928, 386858, 1 }, -- Increases the attack speed of your primary pet by 5%. Increases Grimoire of Sacrifice damage by 10%.
    demonic_resilience             = {  71917, 389590, 2 }, -- Reduces the chance you will be critically struck by 2%. All damage your primary demon takes is reduced by 8%.
    demonic_soul                   = {  94851, 449614, 1 }, -- A demonic entity now inhabits your soul, allowing you to detect if a Soul Shard has a Succulent Soul when it's generated. A Succulent Soul empowers your next Hand of Gul'dan, increasing its damage by 60%, and unleashing your demonic soul to deal an additional 27,312 Shadow damage.
    demonic_tactics                = {  71925, 452894, 1 }, -- Your spells have a 5% increased chance to deal a critical strike. You gain 10% more of the Critical Strike stat from all sources.
    eternal_servitude              = {  94824, 449707, 1 }, -- Fel Domination cooldown is reduced by 90 sec.
    feast_of_souls                 = {  94823, 449706, 1 }, -- When you kill a target, you have a chance to generate a Soul Shard that is guaranteed to be a Succulent Soul.
    fel_armor                      = {  71950, 386124, 2 }, -- When Soul Leech absorbs damage, 5% of damage taken is absorbed and spread out over 5 sec. Reduces damage taken by 1.5%.
    fel_domination                 = {  71931, 333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by 90%.
    fel_pact                       = {  71932, 386113, 1 }, -- Reduces the cooldown of Fel Domination by 60 sec.
    fel_synergy                    = {  71924, 389367, 2 }, -- Soul Leech also heals you for 8% and your pet for 25% of the absorption it grants.
    fiendish_stride                = {  71948, 386110, 1 }, -- Reduces the damage dealt by Burning Rush by 10%. Burning Rush increases your movement speed by an additional 20%.
    frequent_donor                 = {  71937, 386686, 1 }, -- Reduces the cooldown of Dark Pact by 15 sec.
    friends_in_dark_places         = {  94850, 449703, 1 }, -- Dark Pact now shields you for an additional 50% of the sacrificed health.
    gorebound_fortitude            = {  94850, 449701, 1 }, -- You always gain the benefit of Soulburn when consuming a Healthstone, increasing its healing by 30% and increasing your maximum health by 20% for 12 sec.
    gorefiends_resolve             = {  94824, 389623, 1 }, -- Targets resurrected with Soulstone resurrect with 40% additional health and 80% additional mana.
    horrify                        = {  71916,  56244, 1 }, -- Your Fear causes the target to tremble in place instead of fleeing in fear.
    howl_of_terror                 = {  71947,   5484, 1 }, -- Let loose a terrifying howl, causing 5 enemies within 10 yds to flee in fear, disorienting them for 20 sec. Damage may cancel the effect.
    ichor_of_devils                = {  71937, 386664, 1 }, -- Dark Pact sacrifices only 5% of your current health for the same shield value.
    lifeblood                      = {  71940, 386646, 2 }, -- When you use a Healthstone, gain 4% Leech for 20 sec.
    mortal_coil                    = {  71947,   6789, 1 }, -- Horrifies an enemy target into fleeing, incapacitating for 3 sec and healing you for 20% of maximum health.
    necrolyte_teachings            = {  94825, 449620, 1 }, -- Shadow Bolt damage increased by 20%. Power Siphon increases the damage of Demonbolt by an additional 20%.
    nightmare                      = {  71916, 386648, 1 }, -- Increases the amount of damage required to break your fear effects by 60%.
    pact_of_gluttony               = {  71926, 386689, 1 }, -- Healthstones you conjure for yourself are now Demonic Healthstones and can be used multiple times in combat. Demonic Healthstones cannot be traded.  Demonic Healthstone Instantly restores 35% health. 60 sec cooldown.
    quietus                        = {  94846, 449634, 1 }, -- Soul Anathema damage increased by 25% and is dealt 20% faster. Consuming Demonic Core activates Shared Fate or Feast of Souls.
    resolute_barrier               = {  71915, 389359, 2 }, -- Attacks received that deal at least 5% of your health decrease Unending Resolve's cooldown by 10 sec. Cannot occur more than once every 30 sec.
    sargerei_technique             = {  93179, 405955, 2 }, -- Incinerate damage increased by 5%.
    sataiels_volition              = {  94838, 449637, 1 }, -- Wild Imp damage increased by 5% and Wild Imps that are imploded have an additional 5% chance to grant a Demonic Core.
    shadow_of_death                = {  94857, 449638, 1 }, -- Your Summon Demonic Tyrant spell is empowered by the demonic entity within you, causing it to grant 3 Soul Shards that each contain a Succulent Soul.
    shadowflame                    = {  71941, 384069, 1 }, -- Slows enemies in a 12 yard cone in front of you by 70% for 6 sec.
    shadowfury                     = {  71942,  30283, 1 }, -- Stuns all enemies within 8 yds for 3 sec.
    shared_fate                    = {  94823, 449704, 1 }, -- When you kill a target, its tortured soul is flung into a nearby enemy for 3 sec. This effect inflicts 7,833 Shadow damage to enemies within 10 yds every 0.8 sec. Deals reduced damage beyond 8 targets.
    socrethars_guile               = {  93178, 405936, 2 }, -- Immolate damage increased by 10%.
    soul_anathema                  = {  94847, 449624, 1 }, -- Unleashing your demonic soul bestows a fiendish entity unto the soul of its targets, dealing 25,765 Shadow damage over 10 sec. If this effect is reapplied, any remaining damage will be added to the new Soul Anathema.
    soul_conduit                   = {  71939, 215941, 1 }, -- Every Soul Shard you spend has a 5% chance to be refunded.
    soul_leech                     = {  71933, 108370, 1 }, -- All single-target damage done by you and your minions grants you and your pet shadowy shields that absorb 3% of the damage dealt, up to 10% of maximum health.
    soul_link                      = {  71923, 108415, 2 }, -- 5% of all damage you take is taken by your demon pet instead. While Grimoire of Sacrifice is active, your Stamina is increased by 3%.
    soulburn                       = {  71957, 385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells. Demonic Circle: Teleport: Increases your movement speed by 50% and makes you immune to snares and roots for 6 sec. Demonic Gateway: Can be cast instantly. Drain Life: Gain an absorb shield equal to the amount of healing done for 30 sec. This shield cannot exceed 30% of your maximum health. Health Funnel: Restores 140% more health and reduces the damage taken by your pet by 30% for 10 sec. Healthstone: Increases the healing of your Healthstone by 30% and increases your maximum health by 20% for 12 sec.
    strength_of_will               = {  71956, 317138, 1 }, -- Unending Resolve reduces damage taken by an additional 15%.
    sweet_souls                    = {  71927, 386620, 1 }, -- Your Healthstone heals you for an additional 10% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount.
    swift_artifice                 = {  71918, 452902, 1 }, -- Reduces the cast time of Soulstone and Create Healthstone by 50%.
    teachings_of_the_black_harvest = {  71938, 385881, 1 }, -- Your primary pets gain a bonus effect. Imp: Successful Singe Magic casts grant the target 4% damage reduction for 5 sec. Voidwalker: Reduces the cooldown of Shadow Bulwark by 30 sec. Felhunter: Reduces the cooldown of Devour Magic by 5 sec. Sayaad: Reduces the cooldown of Seduction by 10 sec and causes the target to walk faster towards the demon.
    teachings_of_the_satyr         = {  71935, 387972, 1 }, -- Reduces the cooldown of Amplify Curse by 15 sec.
    wicked_reaping                 = {  94821, 449631, 1 }, -- Damage dealt by your demonic soul is increased by 10%. Consuming Demonic Core feeds the demonic entity within you, causing it to appear and deal 14,870 Shadow damage to your target.
    wrathful_minion                = {  71946, 386864, 1 }, -- Increases the damage done by your primary pet by 5%. Increases Grimoire of Sacrifice damage by 10%.

    -- Destruction
    ashen_remains                  = {  71969, 387252, 1 }, -- Chaos Bolt, Shadowburn, and Incinerate deal 5% increased damage to targets afflicted by Immolate.
    avatar_of_destruction          = { 101998, 456975, 1 }, -- Consuming Ritual of Ruin summons an Overfiend for 8 sec.  Summon Overfiend Generates 1 Soul Shard Fragment every 1 sec and casts Chaos Bolt at 80% effectiveness at its summoner's target.
    backdraft                      = {  72067, 196406, 1 }, -- Conflagrate reduces the cast time of your next Incinerate, Chaos Bolt, or Soul Fire by 30%. Maximum 2 charges.
    backlash                       = {  71983, 387384, 1 }, -- Increases your critical strike chance by 3%. Physical attacks against you have a 25% chance to make your next Incinerate instant cast. This effect can only occur once every 6 sec.
    blistering_atrophy             = { 101996, 456939, 1 }, -- Increases the damage of Shadowburn by 20%. The critical strike chance of Shadowburn is increased by an additional 50% when damaging a target that is at or below 30% health.
    burn_to_ashes                  = {  71964, 387153, 1 }, -- Chaos Bolt and Rain of Fire increase the damage of your next 2 Incinerates by 15%. Shadowburn increases the damage of your next Incinerate by 15%. Stacks up to 6 times.
    cataclysm                      = {  71974, 152108, 1 }, -- Calls forth a cataclysm at the target location, dealing 42,588 Shadowflame damage to all enemies within 8 yards and afflicting them with Immolate.
    channel_demonfire              = {  72064, 196447, 1 }, -- Launches 15 bolts of felfire over 2.3 sec at random targets afflicted by your Immolate within 40 yds. Each bolt deals 6,207 Fire damage to the target and 3,086 Fire damage to nearby enemies.
    chaos_incarnate                = {  71966, 387275, 1 }, -- Chaos Bolt, Rain of Fire, and Shadowburn always gain at least 70% of the maximum benefit from your Mastery: Chaotic Energies.
    conflagrate                    = {  72068,  17962, 1 }, -- Triggers an explosion on the target, dealing 33,270 Fire damage. Reduces the cast time of your next Incinerate or Chaos Bolt by 30% for 10 sec. Generates 5 Soul Shard Fragments.
    conflagration_of_chaos         = {  72061, 387108, 1 }, -- Conflagrate and Shadowburn have a 50% chance to guarantee your next cast of the ability to critically strike, and increase its damage by your critical strike chance.
    crashing_chaos                 = {  71960, 417234, 1 }, -- Summon Infernal increases the damage of your next 8 casts of Chaos Bolt by 25% or your next 8 casts of Rain of Fire by 35%.
    decimation                     = { 101997, 456985, 1 }, -- When your direct damaging abilities deal a critical strike, they have a chance to reset the cooldown of Soul Fire and reduce the cast time of your next Soul Fire by 80%.
    demonfire_infusion             = {  72064, 1214442, 1 }, -- Periodic damage from Immolate has a 4% chance to fire a Demonfire bolt at 100% increased effectiveness. Incinerate has a 25% chance to fire a Demonfire bolt at 100% increased effectiveness.
    demonfire_mastery              = { 101993, 456946, 1 }, -- Increases the damage of Channel Demonfire by 30% and it deals damage 35% faster.
    devastation                    = {  72066, 454735, 1 }, -- Increases the critical strike chance of your Destruction spells by 5%.
    diabolic_embers                = {  71968, 387173, 1 }, -- Incinerate now generates 100% additional Soul Shard Fragments.
    dimension_ripper               = { 102003, 457025, 1 }, -- Periodic damage dealt by Immolate has a 5% chance to tear open a Dimensional Rift.
    dimensional_rift               = { 102003, 387976, 1 }, -- Rips a hole in time and space, opening a random portal that damages your target: Shadowy Tear Deals 149,267 Shadow damage over 14 sec. Unstable Tear Deals 128,111 Chaos damage over 6 sec. Chaos Tear Fires a Chaos Bolt, dealing 50,492 Chaos damage. This Chaos Bolt always critically strikes and your critical strike chance increases its damage. Generates 3 Soul Shard Fragments.
    emberstorm                     = {  72062, 454744, 1 }, -- Increases the damage done by your Fire spells by 2% and reduces the cast time of your Incinerate spell by 20%.
    eradication                    = {  71984, 196412, 1 }, -- Chaos Bolt and Shadowburn increases the damage you deal to the target by 5% for 7 sec.
    explosive_potential            = {  72059, 388827, 1 }, -- Reduces the cooldown of Conflagrate by 2 sec.
    fiendish_cruelty               = { 101994, 456943, 1 }, -- When Shadowburn fails to kill a target that is at or below 30% health, its cooldown is reduced by 5 sec.
    fire_and_brimstone             = {  71982, 196408, 1 }, -- Incinerate now also hits all enemies near your target for 25% damage.
    flashpoint                     = {  71972, 387259, 1 }, -- When your Immolate deals periodic damage to a target above 80% health, gain 2% Haste for 10 sec. Stacks up to 3 times.
    grimoire_of_sacrifice          = {  71971, 108503, 1 }, -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal 6,958 additional Shadow damage. Lasts until canceled or until you summon a demon pet.
    havoc                          = {  71979,  80240, 1 }, -- Marks a target with Havoc for 15 sec, causing your single target spells to also strike the Havoc victim for 60% of the damage dealt.
    improved_chaos_bolt            = { 101992, 456951, 1 }, -- Increases the damage of Chaos Bolt by 10% and reduces its cast time by 0.5 sec.
    improved_conflagrate           = {  72065, 231793, 1 }, -- Conflagrate gains an additional charge.
    indiscriminate_flames          = { 101995, 457114, 1 }, -- Backdraft increases the damage of your next Chaos Bolt by 5% and increases the critical strike chance of your next Incinerate or Soul Fire by 35%.
    inferno                        = {  71974, 270545, 1 }, -- Rain of Fire damage is increased by 20% and its Soul Shard cost is reduced by 1.
    internal_combustion            = {  71980, 266134, 1 }, -- Chaos Bolt consumes up to 5 sec of Immolate's damage over time effect on your target, instantly dealing that much damage.
    master_ritualist               = {  71962, 387165, 1 }, -- Ritual of Ruin requires 5 less Soul Shards spent.
    mayhem                         = {  71979, 387506, 1 }, -- Your single target spells have a 35% chance to apply Havoc to a nearby enemy for 5.0 sec.  Havoc Marks a target with Havoc for 5.0 sec, causing your single target spells to also strike the Havoc victim for 60% of the damage dealt.
    power_overwhelming             = {  71965, 387279, 1 }, -- Consuming Soul Shards increases your Mastery by 0.5% for 10 sec for each shard spent. Gaining a stack does not refresh the duration.
    pyrogenics                     = {  71975, 387095, 1 }, -- Enemies affected by your Rain of Fire take 3% increased damage from your Fire spells.
    raging_demonfire               = {  72063, 387166, 1 }, -- Channel Demonfire fires an additional 2 bolts. Each bolt increases the remaining duration of Immolate on all targets hit by 0.5 sec.
    rain_of_chaos                  = {  71960, 266086, 1 }, -- While your initial Infernal is active, every Soul Shard you spend has a 15% chance to summon an additional Infernal that lasts 8 sec.
    rain_of_fire_targeted          = {  72069, 1214467, 1 }, -- Calls down a rain of hellfire upon your target, dealing 42,138 Fire damage over 6.1 sec to enemies in the area. This spell is cast at your target.
    rain_of_fire_ground            = {  72069,   5740, 1 }, -- Calls down a rain of hellfire the target location, dealing 42,138 Fire damage over 6.1 sec to enemies in the area. This spell is cast at a selected location.
    reverse_entropy                = {  71980, 205148, 1 }, -- Your spells have a chance to grant you 15% Haste for 8 sec.
    ritual_of_ruin                 = {  71970, 387156, 1 }, -- Every 15 Soul Shards spent grants Ritual of Ruin, making your next Chaos Bolt or Rain of Fire consume no Soul Shards and have its cast time reduced by 50%.
    roaring_blaze                  = {  72065, 205184, 1 }, -- Conflagrate increases your Soul Fire, Immolate, Incinerate, and Conflagrate damage to the target by 25% for 8 sec.
    rolling_havoc                  = {  71961, 387569, 1 }, -- Each time your spells duplicate from Havoc, gain 1% increased damage for 6 sec. Stacks up to 5 times.
    ruin                           = {  71967, 387103, 1 }, -- Increases the critical strike damage of your Destruction spells by 5%.
    scalding_flames                = {  71973, 388832, 1 }, -- Increases the damage of Immolate by 25% and its duration by 3 sec.
    shadowburn                     = {  72060,  17877, 1 }, -- Blasts a target for 46,096 Shadowflame damage, gaining 100% critical strike chance on targets that have 30% or less health. Restores 1 Soul Shard and refunds a charge if the target dies within 5 sec.
    soul_fire                      = {  71978,   6353, 1 }, -- Burns the enemy's soul, dealing 75,126 Fire damage and applying Immolate. Generates 1 Soul Shard.
    summon_infernal                = {  71985,   1122, 1 }, -- Summons an Infernal from the Twisting Nether, impacting for 8,115 Fire damage and stunning all enemies in the area for 2 sec. The Infernal will serve you for 30 sec, dealing 8,257 damage to all nearby enemies every 1.5 sec and generating 1 Soul Shard Fragment every 1 sec.
    summoners_embrace              = {  71971, 453105, 1 }, -- Increases the damage dealt by your spells and your demon by 3%.
    unstable_rifts                 = { 102427, 457064, 1 }, -- Bolts from Dimensional Rift now deal 25% of damage dealt to nearby enemies as Fire damage.

    -- Diabolist
    abyssal_dominion               = {  94831, 429581, 1 }, -- Summon Infernal becomes empowered, dealing 40% increased damage. When your Summon Infernal ends, it fragments into two smaller Infernals at 50% effectiveness that lasts 10 sec.
    annihilans_bellow              = {  94836, 429072, 1 }, -- Howl of Terror cooldown is reduced by 15 sec and range is increased by 5 yds.
    cloven_souls                   = {  94849, 428517, 1 }, -- Enemies damaged by your Overlord have their souls cloven, increasing damage taken by you and your pets by 5% for 15 sec.
    cruelty_of_kerxan              = {  94848, 429902, 1 }, -- Summon Infernal grants Diabolic Ritual and reduces its duration by 3 sec.
    diabolic_ritual                = {  94855, 428514, 1, "diabolist" }, -- Spending a Soul Shard on a damaging spell grants Diabolic Ritual for 20 sec. While Diabolic Ritual is active, each Soul Shard spent on a damaging spell reduces its duration by 1 sec. When Diabolic Ritual expires you gain Demonic Art, causing your next Hand of Gul'dan to summon an Overlord, Mother of Chaos, or Pit Lord that unleashes a devastating attack against your enemies.
    flames_of_xoroth               = {  94833, 429657, 1 }, -- Fire damage increased by 2% and damage dealt by your demons is increased by 2%.
    gloom_of_nathreza              = {  94843, 429899, 1 }, -- Enemies marked by your Havoc take 5% increased damage from your single target spells.
    infernal_bulwark               = {  94852, 429130, 1 }, -- Unending Resolve grants Soul Leech equal to 10% of your maximum health and increases the maximum amount Soul Leech can absorb by 10% for 8 sec.
    infernal_machine               = {  94848, 429917, 1 }, -- Spending Soul Shards on damaging spells while your Infernal is active decreases the duration of Diabolic Ritual by 1 additional sec.
    infernal_vitality              = {  94852, 429115, 1 }, -- Unending Resolve heals you for 30% of your maximum health over 10 sec.
    ruination                      = {  94830, 428522, 1 }, -- Summoning a Pit Lord causes your next Chaos Bolt to become Ruination.  Ruination Call down a demon-infested meteor from the depths of the Twisting Nether, dealing 174,430 Chaos damage on impact to all enemies within 8 yds of the target and summoning 1 Diabolic Imp. Damage is further increased by your critical strike chance and is reduced beyond 8 targets.
    secrets_of_the_coven           = {  94826, 428518, 1 }, -- Mother of Chaos empowers your next Incinerate to become Infernal Bolt.  Infernal Bolt Hurl a bolt enveloped in the infernal flames of the abyss, dealing 69,379 Fire damage to your enemy target and generating 2 Soul Shards.
    souletched_circles             = {  94836, 428911, 1 }, -- You always gain the benefit of Soulburn when casting Demonic Circle: Teleport, increasing your movement speed by 50% and making you immune to snares and roots for 6 sec.
    touch_of_rancora               = {  94856, 429893, 1 }, -- Demonic Art increases the damage of your next Chaos Bolt, Rain of Fire, or Shadowburn by 100% and reduces its cast time by 50%. Casting Chaos Bolt reduces the duration of Diabolic Ritual by 1 additional sec.

    -- Hellcaller
    aura_of_enfeeblement           = {  94822, 440059, 1 }, -- While Unending Resolve is active, enemies within 30 yds are affected by Curse of Tongues and Curse of Weakness at 100% effectiveness.
    blackened_soul                 = {  94837, 440043, 1 }, -- Spending Soul Shards on damaging spells will further corrupt enemies affected by your Wither, increasing its stack count by 1. Each time Wither gains a stack it has a chance to collapse, consuming a stack every 1 sec to deal 13,219 Shadowflame damage to its host until 1 stack remains.
    bleakheart_tactics             = {  94854, 440051, 1 }, -- Wither damage increased 20%. When Wither gains a stack from Blackened Soul, it has a chance to gain an additional stack.
    curse_of_the_satyr             = {  94822, 440057, 1 }, -- Curse of Weakness is empowered and transforms into Curse of the Satyr.  Curse of the Satyr Increases the time between an enemy's attacks by 20% and the casting time of all spells by 30% for 2 min. Curses: A warlock can only have one Curse active per target.
    hatefury_rituals               = {  94854, 440048, 1 }, -- Wither deals 30% increased periodic damage but its duration is 15% shorter.
    illhoofs_design                = {  94835, 440070, 1 }, -- Sacrifice 10% of your maximum health. Soul Leech now absorbs an additional 15% of your maximum health.
    malevolence                    = {  94842, 442726, 1 }, -- Dark magic erupts from you and corrupts your soul for 20 sec, causing enemies suffering from your Wither to take 51,500 Shadowflame damage and increase its stack count by 6. While corrupted your Haste is increased by 8% and spending Soul Shards on damaging spells grants 1 additional stack of Wither.
    mark_of_perotharn              = {  94844, 440045, 1 }, -- Critical strike damage dealt by Wither is increased by 10%. Wither has a chance to gain a stack when it critically strikes. Stacks gained this way do not activate Blackened Soul.
    mark_of_xavius                 = {  94834, 440046, 1 }, -- Wither damage increased by 25%. Blackened Soul deals 2% increased damage per stack of Wither.
    seeds_of_their_demise          = {  94829, 440055, 1 }, -- After Wither reaches 8 stacks or when its host reaches 20% health, Wither deals 13,219 Shadowflame damage to its host every 1 sec until 1 stack remains. When Blackened Soul deals damage, you have a chance to gain 2 stacks of Flashpoint.
    wither                         = {  94840, 445468, 1, "hellcaller" }, -- Bestows a vile malediction upon the target, burning the sinew and muscle of its host, dealing 4,725 Shadowflame damage immediately and an additional 108,658 Shadowflame damage over 21 sec. Periodic damage generates 1 Soul Shard Fragment and has a 50% chance to generate an additional 1 on critical strikes. Replaces Immolate.
    xalans_cruelty                 = {  94845, 440040, 1 }, -- Shadow damage dealt by your spells and abilities is increased by 2% and your Shadow spells gain 10% more critical strike chance from all sources.
    xalans_ferocity                = {  94853, 440044, 1 }, -- Fire damage dealt by your spells and abilities is increased by 2% and your Fire spells gain 10% more critical strike chance from all sources.
    zevrims_resilience             = {  94835, 440065, 1 }, -- Dark Pact heals you for 22,261 every 1 sec while active.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bane_of_havoc    =  164, -- (461917)
    bloodstones      = 5696, -- (1218692) Your Healthstones are replaced with Bloodstones which increase their user's haste by 30% for 12 sec instead of healing.
    bonds_of_fel     = 5401, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the 8 yd radius they explode, dealing 112,580 Fire damage split amongst all nearby enemies.
    fel_fissure      =  157, -- (200586)
    gateway_mastery  = 5382, -- (248855) Increases the range of your Demonic Gateway by 20 yards, and reduces the cast time by 30%. Reduces the time between how often players can take your Demonic Gateway by 30 sec.
    impish_instincts = 5580, -- (409835) Taking direct Physical damage reduces the cooldown of Demonic Circle by 3 sec. Cannot occur more than once every 5 sec.
    nether_ward      = 3508, -- (212295) Surrounds the caster with a shield that lasts 3 sec, reflecting all harmful spells cast on you.
    shadow_rift      = 5393, -- (353294) Conjure a Shadow Rift at the target location lasting 2 sec. Enemy players within the rift when it expires are teleported to your Demonic Circle. Must be within 40 yds of your Demonic Circle to cast.
    soul_rip         = 5607, -- (410598) Fracture the soul of up to 3 target players within 20 yds into the shadows, reducing their damage done by 25% and healing received by 25% for 8 sec. Souls are fractured up to 20 yds from the player's location. Players can retrieve their souls to remove this effect.
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
                summon_demon( "overlord", 2 )
                removeBuff( "art_overlord" )
            end

            if buff.art_mother.up then
                summon_demon( "mother_of_chaos", 6 )
                removeBuff( "art_mother" )
                if talent.secrets_of_the_coven.enabled then applyBuff( "infernal_bolt" ) end
            end

            if buff.art_pit_lord.up then
                summon_demon( "pit_lord", 5 )
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


-- The War Within
spec:RegisterGear( "tww2", 229325, 229323, 229328, 229326, 229324 )
spec:RegisterAuras( {
-- 2-set
-- https://www.wowhead.com/ptr-2/spell=1217798/jackpot
-- Hitting a Jackpot! increases your Mastery by 3% and your spells gain maximum benefit from Mastery: Chaotic Energies for 10 sec.
    jackpot = {
        id = 1217798,
        duration = 10,
        max_stack = 1,
    },
} )

-- Dragonflight
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


spec:RegisterPack( "Destruction", 20250303, [[Hekili:S31)VTnUs()wcouhRMgxl54UTpyNdVVGhUDX7EVdi7d3pC4IJISCIqTT8jj3U5GH)B)iPeP43gskzPK09c2fTPrudhoC4mFMHJiV1)2F92BwgweF7FpyCW0Xtgpz04Vm5lx9LBVP4PDX3EZUWOVg(a6h2gUb9N)L48IS9rfjPBXp7P1PHlX0ipDFwe65pwuSl)p8Xp(qsXJ7VFuu6MpMNSz)6q8BeLfUQa)VJ(4T3C)(K1f)82BVxpdm52Bc3x8yA2T3CtYM)mIYjlxgx2848OBVb38lhpb9))HJ3DZtBJoE33rDk6NjnFDsEroMZskI3G)H)ozSgVn8(1XlV9pHiF1OiF3tBcZlIZYx89ye5JYqVswsiA8fxmkz7Q4STHRhLfVjmzB(X7UE(X78hF8UbhVtFdMHAqqzdUF)QvJ46GS4DPzfJYlqs1skn5ZKgo84DRsE4XIf1DdIixHOYHdkpc3b(4N5v(47tZZjurt7MmMo1jnolqsCajsrwY2Vgx4Zllqm43cr)eQTSH8c8l8T4sM4SJ3veUoElA0TFZM0TlycMQEOSzmIu1jl8x89K1RxSonpEreI)iJQsjIsB3LLKI4ONoEhwcaqWGfX)w069l54RYNmQiy0JH5lIstxVm97BlF(qHNtFw9SP2(qGrci8l7nLh(cZOLQfNzsyoWcdnZL(YJkg1iVXkL5k8r9Z3eUDF4AM0bGclwUpJSQ(4DxqMmWAZskGEiTU1PfCAuiTUjM16cEw06cARwxaOAmOwNVfTo)wP153FAD6yOtuRlWIwxGvTUGwR1fG16UYQTojn1B2Junsr94drlXop40k1VSX1LvLAz2OHlML0liROrLVbBRoCqhcPzVloQa3AbLPDzXFdlDg5l)MoV20dp1m1QbbPPZgo14UUh8utaWud0AxJtV)4m18jPPgzbpDQcZmlEmC7s6Cv9VOa9F3qLfAbILUd9wXfjRQPhT94FA9E0FTmfH0cXPiGKXCgL(xpEh(jyGFXz0FpV(WJHFlnQYihHSlkbdv(7XuCrrc6xObnufBzGPqkciCVRxK)yy2Yk4C1M3RKVXrzXf5iP2cepI8c8T4TctXeiImZX3NUUy0(Dv46WpAzCuYgIjpYVV0(QMU1ddmEv4(1io2NFOUdPdLS9buxVDzczKOXjS9bltDwHELmRawyoVkkSQZ85IO71z52oRQLvQMwaxrv7y5s7R7iZdZWR44hbsov1zBZoZpSmyG1PPzKFsnYGpQ3(t9aWJ6Ce9dNn3mXUORLkEeg0bc6XH5QZgUvJyzsQsvxhonT3RuZ6YX0peZGTxi)ohKforOlDjwfpINYXuM3Zj3SvEx5xRx3bIbsOZRzxVOpWMgZVVw0BD42Rl6DP3B(IERu9hIzW2lKFNdYcNiKUf9kHk21l6LZEqjixcMsDaCRHJwbk8(WOVUeNmuvKG1pcZBArq5R8BXj67QAZlieuRwh(qgoTQAa2wZoyENG)LaMPetmB0l3hiHXOPCPnf)SvjzX6Gtw3fzHjlxe)n8OoC5YCeUmIC1FQmq5km88cevO9e2OKdOpHBm8E0C8OsOWmrryry06NY3ykha0alKY8u5)lf5XQSyKabrbX8CifpbHpNo6kQUwry2dyvD0JwuKUyzsmrkmvY6bquo0umc(yPzopwqEcVrrs0xraSLsUKoopWcF77tBGKgYvynKONIwJAo5vZXRgmeJF5KiOGNn737IDn6zbMucnkYRA)lPaxgdsTaUm4KfXBJ3KeNxz8GArV2O4JHO)((9zBhTApYwxwC0J4oGYZOxcNFHnH)gzDxvCVlJjgXIZcxMevg0ATqJ)vgWw3Z3w(f)NXwOJ6408YiJt2Uy1AS7gAtQiYsKOff9iAcjPyVqwmyzSPSH1MgrughuoH4IjlMAKgVfsirgkK0WIS0Dp(eFYrQTdYeuyX(p1cXUKQKIOfQV(CRTRxQ2xl(s2Sll9BXlxWjQ5Nl0X7b8lICKodTyWNsgIN40wXcWuL5kWkDVINUN5aPDLHN0uc7oppLdCdV)p2ebwJ5loRDwLPgkzqEXjRwO(79hdsj9oPUqVHuKPnoDvaZBCJLTBJxVyzmcUgJtGbBvlGvWBbIvYhgSKcR9tmJMelJvagRsDh0wYYzIDjAqVnhXfHiZRjyeF1awRzq5wr4sy8wgw6Zb4zBuY24QXmc5kY9r43IndDLptQ6mBDnZQfsuHakhviKH4OW1L5fdz2fByTCh65ZgB7YbltAsOHO3MPc2Z3e(0JXBQ1aeZ84I6P3CZiAlx6cg9an5ToLIDUeOVo(BPOMhfBcPAPGQFygt4p(SBO64ScGxJI8hhMvazmcgHICEVZIruGUytjUh95kh0DkdQvfwfodaC2LqVu8VfhTViU22KEvnGiIKbcad4L5dPOm5XrPBUFFUcEi94IRJcEkz0zeYKhXMa37xBWHe6uTFpaqV17UbatO29IsXsoykZlMyB3NJhUCG24uBPYwrOA1k(SNZ7YPQlQFiN1XRTim9STKqcLADNWK44Mx(26x(idGdwhHdQwNOMm0UMInLLjoOS8cpr(mmfcJOQgsAwAijkI7xh()glmz5sKv1GC10qwXJjfae9xxAvu8zl2KIft1b)WlO1(cii9zRtZwAVL7skwi2Ys1i2aYJkYf2orbNVGqZGXC(wGRoh4Qf4PZj(6zE0eI30auBIWJQTSAr2(e8Uvd553aiBhsklIf)Yy(jcAWjcsedXUya8C337sIqzGD9AFlj1HrRn08cav0qIyk1Usqc2z9QsDWFXkmK3NWOWidbZMmqgF9HZhdte(aEHclMszNPnkCwN9VoWn)5LoW4ds2w0WW5esg38KrtzJrtiHfIqhnUlYqHkUwREaSJoPT2OUqwCZtGaYAFzFUSOA1NgFJjWhCgEgeEFl5w3tlQhn5Xra1t9Z5f88or7gCucKqmGy(Wh0IZQutuV0YimlFGuuhqCOZMJfn7XpdJBR19ud0t6RCasxsG4DP4sHLjKqHweD)IGcGa74MAU04RYd(cVYFSGPxHCb93dGDnBQaWgyjDML4de8wXdpq2fDaSlAgxeUED63xKHERGIf57I3UmoJF)rDj9Q7Ekl9H4Tjr5cpTYEi3tbXckSGsR7y51LM8UlbmTCvfSC3GaegNrTIsAL0ZsVqhNTAii5GqVaYZWabg0IMebnamzFA9Kead0WWIrJcluJoz5LW(9ZsWvtKIIa)cGbb1i0nnahsWN5nTRKcBjB7FHVXuXuj7l2YjWHasD6GKLly5JVCNv5nbAj388ZgvubmE0j(ISnZmQapJt)zQLuR7MMY0s8AWBdbMv0SJtxWEs9KAv8I08Nmr0LGuYOHDjOnlVYlHLTLNhhr3L)xEVVI7w23dtkKrp(Af3GNIc74rbtPonKSHO9tG5hNX5Cg(N6LzJe34Wxl861ANtGGBb7DZ9TBJ8uL1(ejYucZdJeIpUIozpKoHT(d2x8ROnEf2tkFg6vlga5s4BizRTja3hpYNpLbvMPPoLHmF7XsLNgspPJiTTS6jBP399ZWqTD1bXndSxaQW1Hs9JyFidWrFm61ouNr3)ObYIEQiMBFlz(G9NAlmAGnHfEliAn6oEK0qsjBzIYy26PwR5qAqSZukXgAA(xNXU5LFr(ESTN0WsrDV8NOA9kuOlknNpXtxxcl1DsxVJTaG)84KPVTfjSM6WwKOBNrocx4FkBoIMM92AG3wd8dZAGbL(MyEGMXQNkJBEizjIo3uLB6hd6aBdFeJW3WMZb9bMAkRiWyvu2jo26vwgIexUkxGrc7HHvefdOa4lzCareuvYRLN0Xqdaq6rwNa0Pod8w4Z)qmnnM3QTHkXJsrOoSgKQ8IxvzB9eOIX6o3OI0xrI4gPcVjBw(Ax0YG8bkXV1LqBZvpwdGn3ZX1u7VgHUYktfgtY70JhckvsXVlv1TuEAVgVTED7azqOVfrcu4iLIp28k8Cjuyik7qhZsHMTL12EY2fYBODP8zxIp0Gr5prTYn0UV(bWRmfbaPX2VLfOGtQqhrygZPtk(4bHTnEmNyM3Gx4StQUDClPFAKa4bDb7uR2ZPwhrTT9lr2j8PS4H9)92QOk1njBgxdOaAwZJDM1OKXZUyvbayuLTe7eL32)GeRCTcwSjD)x4Pn2QSWsFVSGxJrYow7XGYGFVpX38nMuJwIJ4X1ZcM2eZYXdMYlc3UCX9zjBYls3APyQG2DHjwkyZAAuDGuoJLg96jF3)2PMieHNHneDhky70n3hwCR5pwEAQrRpwRq6mHRjXpr7MvytPPB4kFWanoD2fRSvYsDR9V0OI0hEaTuA1ES5B(pFOYVEQfH7wFRMDzZbcxF6NGpOaXNXw4PNYd60SKDLV2FCFrkwZk64D)T0hW)1k8PdXFc1YJ39RLKaT(chXr1)64D3Sof9N(6p3sW9b5tDQ5NrrChDd9chhO)qxGXXahWkqNGyQJ98N2kecfW5gto1wO5dOM3zi6R6wnNOily4eUXwpuCMtRJlYuYI415Ob4yCe6vZreBnYU5AOGkWUGc6GXt7H6rplO02NUjOKdPVbRb8hLKps(qewyHWne98WJ3LVd5EyfELGO6F16u0qjfVibxzBO2JEWF8)4VD8U1i7O4)jY6)wC7qOmr)Z6fxRXlU0RNxEWgERMDjQbdWGxTdWaUbOYgo1Grizk87pMGyFs(qr(Ucr6zfXlsIi4eAXGnORhSSty2B1TDdny0g0Kr7FfBY(FGy()zEm)afV0kNoqXr(u(R2JBv8QvXr4g9u6EmoWTOw99q8FILiKMGLtvya0oVYpuB(hfm3el26e7Kas7mjzcO2Er6QQFvb1NeMxBWSKypQlN2nyae8Spac0maaW0GDJiubegDJc76aBQ3MJfR(w(OJheuL1dHpjQ9XJk)CnaWZW1EnKoNCMZxgn81k8OwN264rDNqDg5rFN5rFoE0k2mYkYq8AZ7tXRMRxQhMfZT4UeeMgfh6PtnOADLVxFMwoPQ0u20dSYfkeBO1h0Uvx9FZD0Iws7MFs89nl1xoAAz0x(IAyQ63AbAaQMoxu84hvSIY(wDBPsdyFUQ7wy5f4WA8OX(IRt130z4M(LViW08fi9TM3HKkjYdOiBtXH5IOEEi6Xi)OAkTeTn7wD7osDpiNtqCrrfWN5sUnzr6tqPoSEX8a4AL(s1(OH1Yi8UyYXfx0xLPmqcgmMEv6eK2ZPcNOanbTq7bQXxoHCHAOjUrHDKs3SaBV45DvWf9CJlEqCLvRjCqblD)kcOdcsY2ISNqg5q)yjKX1pHnPgUnhNEQLvaYWNQF4sHfHFbPPVklDdcn3p)V)N)a2Sxb(vt2wuMhlI)08qCgkwTFlH)cxJS(nYeRZn(mOVsIyNBuwD6SOjCUAI4AjKxZDsf5T8k23Qs7UIZByvABOC(SFMQyOQ7Ktp5l)HQIodV6cTrX5r3Cgyu25VDuPKFcNWg9YrLcBDE5M0Rleqfvc4p9ytAKZWO5QQ4axQcSQKJ)7NdId5Ih3x48wt683W4rILlIV)Fzr0H3JUAd3v2vB1XVb8oKtKNzWfQFudoiiCdjHdNdfmlKeUtSkxbhJWfJ2ZpRjj1mwFBVMo(mAv5Pnq32tlUv3Wvyh3ccnfFhuPvbDmnBi2oRvTJ2HrTTsJacgA3yIlaqyzeY5I)ag02zU1LoJ5X2q0ZoYNwEUF1(AiWH6M75eYtVd2XWrDHWKSQcUZtZnstEMu3zuFqBXRmXs5V0q0WUW6nf0C7vpDQmd7tfud6bUiP6j9zwHuvqRIqMhFZ1bimktBW4ELda)v2b9IdNqi)yC6wa9rtO6RvmXG)x)BXFnzDY)9X7(lPBpVOA7nW2HtX567NRuG)4)zvvsJP73IhDBNuoOf0A(KYT2kfTFsmf0WNrgbgY9EYZ9zKHsf0jfZI(QytiDqtg7yY3jj12ybLXuSzYVY5uf026)(iQ5IDPK)wtc87SoJ5Y0WmHdld5UGiVGR13hNLhNHRvuXRCNY12Q3e1wFrpRQnoZP1I56ot3oD8SkQDM7jYzCrnliUxNMUCXQ9zpXj1u7NRT9kNUuMt4Y6aD7e0pqcxSHcYGXzzRU340fTAuGzDK5Tl7zqe)7DtfHBJIZlYWyCdxV(2QBKleAnSlvCi2bth7JCIEZ3dZ2IyPC8gdIeWjBWxi)vvM65KT28CCcE)F2JM6wIrRSPUUzW)cmQcKhVrh)L)gPqUc(dhV7pNUf1tKhFU(PkenXL(eWtPtKOwn0)38GPDvjGiEn2ZOTyrSW9yhjktSxjM1qynnPhjEpr2NhEEspQyOq7kgY3SIHYJDKOwLdABsps8EISpp88vDQ(Mep3TehMSDOYCFs7PD6uyVsCyY2NYJoH2h)fn(szvP05DI)unxJ6YSPHBADRYb1PokMftZDCTPxjFVr434734Bxi8leFNUlUSf5L1N85dhsUuKr)fFqdVZeX9UW37S56ETlgYAm03x0LGTOIgEEVZkr88g0o2gX30xu8nTZw2P9HdTuy(IllBQW4DMhswF)lTvZ(Exp2dXy2OZ1bJPRg0l6)OnrFFQh)rRebsp2kBFc6X2PnKES138fxw2uHXRi1yMb7pzpEdqpb6BJGJMUM89gHFJVFJVDHWVq8DJbsPH49Tdi3C(3k2(eCazN22bsb8MV4YYMkmEN5HK13x1duqR9a5iqQxa9y3C(3k2(e0JTtB7aPE(1JDtw2uHXRi1yOSNv9LeEEJYDMVV(KNPP(Voxm3zgQqmzxwqDcROnKiTsPVPqqGu(j8jDiruTFUhkegyly4Q3AjYQPsSDLOs1)LeHbQznxjU(pibP(W8xTGRDL6h0Gu3a)fpO0fazBwOcVKNyd1u9xkewb2uxr4FQp0yaiADn9lVIrPy)vi5N1tYYsotICIvKFFsQVanTiwT(kZm6lMFxjFNADly8lyNWkYy5v2YfNSReS12KdEo8K8I2jTxw31()EEed9PBRaGTW9eShRfue7Cd88gblcApXfpivoxo(ALh70wGeyMOkp2P0b029vPNjFVr4xi(wjljazmnFWqt0)D2J(E(4dhS2iZ7BX8XE0bBlztRmGBCPnMKjTvWbLDAj7sslPRjFVr4xi(2U2DGIAJg63dA3A6ftA3UXMwza34sBmjtARGJMzKs50tuJrkDTrqlrb8ltlXo513grW1kii5zFWdlq9JetnxSxvG(WpQCVxT2CXEfQIp9hTllnAu42NwSCxUjFkqTRR7hH0kPqFOcumWr6d3UUUFmpoCOOfBKfW(M(UqzmmpYN4egK(61XrfAiT2g5kV7CpaH2eK2TfxvFtFxOSdsfGg5kV7Cp4QCxXX8zGa6G8fE4aSxsZUjTMl73p0)IXJM(EaLk0Z1qc85oPN31dnda1AbjO03(w7B)Q(MoN8mkl)4lOSuTV7szzTQlqMxBD2uGiOMtmtjsB4m18CZPrimfNJMgKabG8y3IuK2p1FnqCe0KeHFTuzPx5VfIwajfUJYKBpNN4Uo7QqeSvswiI1cLPNTb6RzE702AgaI2jzffue0dBMhqx1LBMxxNhD4nRUnRQaiwB0CFUgOVM5TtBvfar7MvvqIGEyvfqx1LRQa2wMtyNtGIFH(YDJpwaWg8xLEaSDBiBBwQaqQ2VuP)3O8obgi82K3g7QaeJ7ituIGAUUwLjk0Uv3r6Mq7NApt(oX6g8Eb3IjpOTLTB4uGa36vI3oXaGLGUHt7YOUMa5WHEkjjroLRMVAcQnW3Yds(ZBuSVafN3MWNEmw2gA5VeC01Jg96ZVHCWz4oS8mGkrS2wtja(Q6uEgOpAnp)weEVWr4bvhUNmw0NFqUNkHbYt3PPkcL8VtOoqbHH3jqDGiFNAgbcx9Px(3ayxBFeaqW2BTfpq01n25A)IkfWYqlc9bQoe7qsvFpXlroUlq(gsYt2GspuHKvegWOsBuH6(QQxlkuY1n(5nceA3Hl2iu0wOeciZojhf9zKvq7Fx3JybON6qalqGC7MTo8fVpAH2iiS)wemAVZvT2pCVZz)otEbMh7MB(uRbD8bV85DH98ojC9(8a58h1uy0pLDWXF5Nj6bys(z6bxp(cUoVapvtU2lJWNZ5)0T3GmgUkzn7MqjFe7B5y(k8z0E6MQBWMpKSAo(Ck)6XdoBxCXOW14dc3Fr51Uy(hRyquR0)CA9S8b81O4867zYpqURuNxK(WdRJhTAp(uI)4V8VC8o1lfxIc(FAp(A2v8o(U6FvFZM7ahivasu2iJVWYyxRVNg)e0e(jql)iDvi3a6vw2qFiD3CYDeDfD9)q9La88XJM(b2TkWC7F)cplFLf6)(fAYip4Kh5k12(Zsf4RV22j6GoEB3FsxT)nre7xDL)RS6rPe3FvY(b6zFnvOFty)GNl23NEX8Rt8dwa(KHYFfB66FG4S)j(A2OEuGDzKthfyGrC314XRwfhHB0tP7XxQgBrT67H4)epCjnHCTLty6MmocaghM)qc4MskA9DUFtytPA4urORT87F25YaJCjWhjaGdUgDl03eMKE70lBCoG34SpNP5EQWH7KAWwxX)7yXd3j1HTUIG3ube7YeLUBB(puDmOGMLqtBzX5Ub1JD33xnhZ4lD9X147Z)bNnuoAQbWbY7vPe5eVWFlnjZpmgLt1rlpIVC(hySjZWxk)6ziTxI(eC2LJqJ3f)6jjtkHjt5Lvb9cm)65aGpzPdx)JRVzFWrwu1c8RXU785)TY3T6LcBQek3EtXbTAVvKlec7nlmn(dL3T7itiijYqzrYeVb12tQJeHye85(cQ3(WPKbfgrsdiFEIWvYp4McI7KEShnF6u(xhFDU)H84O5dhsSO44L02fABS8f0M(wjF5S55rM1KA2Gxo(zw1LS17X3w8EdQVZ0Uoqy6JzscZ)8xZW8lGOR7WTPS7LUf4hmSUdMn)QdhuBfHTMnNYwbEdGVxTVEUWD3i)unjVxCME0SpH4JZl1RpTlN((sYO9gT0BMM7RuKS7kVdhuP1SjhoORlu7a(XH3SPduBr5vkP3GHNrZAcvAZhaM8T74fvesZn741Ah8EEduVEgV(ZdotHqAUugf0yQNU4Mge2pvdZSZ8hn9Wb1R6BofJdhKEYNh8kCDLWsQ547aE(fmS9DNyvW0WfPjbFZpZAgfkbxByZC6uNhqvMKgpi1mkkfTBfZHd0m4QShki)pCMhqRWtZZhiCQ5HMPGnTqgIurp7cg3GqZUtGVmMkwe2erVkRpIxk3WCwF2tSRv7sVdGt0Ig8oC4m1576FzTGYt0tmhIk17P7R9Noyi0TZntFP0SbtnO8Foq)9VTNKmv8UYK34Gu1IOWhLla1AZEOjTCyFaOiwQV0t16)4Sw4aXeZ4b5czcGleot(SPoot(rY3xWxRsKE2RrN5ZGovtwfmu7S)Pmvpt7TlnNOxUZy(Vv4c7EWnO24GZD3NPLzToFUwZmGjHChPkizJvqlHf)gNTdfp)VAGcCzWL1rKjeKUgGMmz)LaVcfwXm(nmqXxf7L1DXkpWbpzCWo4WVCvTZfrhCKWlB51CSvVdo6eqVHC5B7yrfPYHnrSzc7Q6Tz8Sa6mHweouXxvRnhKe)vtSE9CU8umkmnUDrcZbeD2vJ(PbsPoy28jxu9BQLTih8y7at43CQsgG)JSckKWQM(wy3TlS7kXNO5UxtJH5v2VQ5WA7xVG811cYwzXP(errkvqH8qr(nvxpUdk)h0ft0GTKwanC6fIWJXUIbxzUFhhsDXNPWZYgXW8N8Q5ktnxhO1GuDQ4LifdgK1v41aHjvNKqCTdVA00lhpY)9d5mHqTzRAwbFeWl86tA8RBjorQPNsy8rpfHCGwcYiVC6vFOkAaGrtpTvGyGqULdRHNsY(7yuS6VlnapdzIyOIyGKanI9z)PAHD5)zfL)oX)6aGbMCVjfP(qnbbJ3VkjbU8YQ5(JX3yasAFYn6tEECTQkEuRK(t435Sg(s4C9P47eF5auVwV(7P43h505Wb5m4OyUGBYwZYT3M8)XDYFaNnLztbYONQ7dAkTS5xbx7DmVIv(B1fKHIchdiTo9n5nwy)oVbqgKhW7RVrDJAVmqJhmKwJkOoUqpKCNhWLK4A728zIKZ3j2Z5qSRtrLs(bBT4Unk8t0GGYwceLYl4XF5)RDUA7TTTbc)BXOacMXOfskoa7dXEFF)iQrITkwqYSnKDY2ak2V9Xt81J8osjf5MMG2(L0g(YXN749gpD4fq5SffxBuUlLt)W6LCzLWDP1xXKXEhComBP3VxySj)b2zdcFnuhlnK2pVnSPZJbsiZW8RausKkSPbwOCpvAhXvthHbNHLlDMoc0o0xV3YxFbgLwmzpJn49ofzEF2AaYeB7JZ6YLXnZPrCs(NjuIsYcrxewtWqP5MLfZqHu2xzMi1VJegSPeurfWOuEKCZxwYKL7BRli)VrrdlrKzOrD(HTpkVRjxt2TSwCLpwqL37XZIir)QXJ3SzqCCoiKo9oAIbwUn3TF3M7BF4VoD(WEBvsvWNYqZLpCYldg)jjg(4T1olB2FfpH5N(rvf7mP5rHyXXv2gKe7noFEmF)awbJUv156SZ9d1NHkX6hK(0X53HGyHNyxBO9BHIBKT(CCJ9nUmDkO5BeekVdv27S9)nzvR(VkQNX)QC9HX8Z0RLFjWYPgjduwBSrr22jkswouI3l1d1m0Jt6RxNsxfxX(8rljl5kukov95YdUDAH(8N)jdzQMPSCPPCLXh2PCL)HvYv(UmLlXj0iWp9fmfJVf(orC9xGYkJ3fb7IU4CRCPEkaTX1nAKpWduRsQqO4R9n6yKO9MHjOiXGlXhBund0S28ziFGVI3mNyaHrrjGYMRbhC)Rc2jOGD4vlZx5ob1EP6saUT40lf)P)(FwvfUp6)Ll5qfXPlkYI68W0pRnaMxdU10TOGhlgYX0(PpLy9gyjrrE4O4USQdxwKlevSLpgbYehPlvHE1pdu90ousBj8jEXtZcvfCX6ETrx2RVqUOuU5NMKoJbeeG2)pJPRqlzDPD1VYiQkqsnXBascZIM4u0vW94swQmRJjrVUkrSxALJ6)xlT0fSw8EM0gCuT)6ScNkpMKgTUbE1Rlr(ntKEt6CqkWLGhbJGpW6WGNNeajGbwtXvjbd9yUKqboMc43IFkIpWXcoCWaXK8oYex1XbuXOWW9MjeFuYrVluTFjAqm(50vMbx1CupIA5yj)tBZTnxpMxd)gHqqWFcD(apT1ROzetGzZSxJcmaLiR)Mz8dUydT2dqbjWiy6BIT7lMworOXbb)S6TcWT2eyPq1xI1VNQYcQFHu6Ruzu2BHABGMpL6PtK8YFRyo68UUEzzubsvTSKjNoxxM4ma9NetNKqP33QA16RJs4kr5qq0DeGpNBzqoYTbqwPYPOXyABfRQi7Ue6UycSROwdHHxdxzJB8e6dnXkA3U6ISoPkzjZ4GHc(D92ClSqe3HnmTEdQMYH6ZL3)HnzAJflQwVcX1f9KLxpzS86HWYRjLzIz5vCS8QbXYRMiwE8UokwEnllVoblV(vWYHF4GCYs70sV7IUZZ3qy4LkLrCZoRK3mPo1DttyDrjalZY9KsohB2EUzxhB8yBZlWjvYUIeBZ)YQda7QPXU8SxkSlQ9OrjIZc5VFWoyt38Nql)WZ0kusrY5D8a8prjtPVAK(V)4tFY0OgTR3d7F5WJsVI(hDwLbOY8c))Dtlm5Npn2DuEhnLRi5G7fvLlSdwtOyQAtP19f8MSU3ZJ2JGbqJ3eXJUx6Gstlef2eIAzZBKJKSJ0riUJBOJsjh8ReCIrMNoCy3MV9C7)oHitVjhK8KJuYkcrm0Xbmr4beJr3Q)MdhwkjlAepYXbg8sj3TFBZPZTWBCD3tpnHqZ7Z7qo8XadGbeZp7vJxUC846ZDUwANFrFPRwlYmT97XX22hkikz369WVW4xDTllcNA222C(eeHUCRKt7LM9QO8S8yv54CmUuNGhxeTScBVIRkQ7SnasEZ27dBsBrJ57FN6JJarneeJVLxFccYQiS8z5M3TBxcM2v6SOPEVZNpsXedhtFqOGRB6JJMqiWbj7LvW2CH4Z5e9f3wx2hIZ5FhoSkJG38Vj1s1ohFxnv)(vSOsmBf1Swmfhlr(o3l8w0JHQLKTzE4jMNQYU0qIPhdn9MdKdfks2lOfzN(Nzc8W1inxxkK0vU1z9WK(dtQq)K(jAePVdK(zO6Pq6NBPZk9ZmX3CGCOqrY(b(yK(dBJT9w6)RNL)9R))d]] )