-- WarlockDestruction.lua
-- November 2022

if UnitClassBase( "player" ) ~= "WARLOCK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local PTR = ns.PTR

local spec = Hekili:NewSpecialization( 267 )

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
    }
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
    abyss_walker                   = { 71954, 389609, 1 }, -- Using Demonic Circle: Teleport or your Demonic Gateway reduces all damage you take by 4% for 10 sec.
    accrued_vitality               = { 71953, 386613, 2 }, -- Drain Life heals for 15% of the amount drained over 7.9 sec.
    amplify_curse                  = { 71934, 328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within 15 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional 20%. Curse of Tongues Increases casting time by an additional 40%. Curse of Weakness Enemy is unable to critically strike.
    ashen_remains                  = { 71969, 387252, 2 }, -- Chaos Bolt and Incinerate deal 5% increased damage to targets afflicted by Immolate.
    avatar_of_destruction          = { 71963, 387159, 1 }, -- When Chaos Bolt or Rain of Fire consumes a charge of Ritual of Ruin, you summon a Blasphemy for 8 sec.  Blasphemy Summons a Blasphemy from the Twisting Nether, impacting for 1,582 Fire damage and stunning all enemies in the area for 2 sec. The Blasphemy will serve you for 8 sec, dealing 1,160 damage to all nearby enemies every 1.6 sec and generating 1 Soul Shard Fragment every 0.5 sec.
    backdraft                      = { 72066, 196406, 1 }, -- Conflagrate reduces the cast time of your next Incinerate, Chaos Bolt, or Soul Fire by 30%. Maximum 2 charges.
    backlash                       = { 71983, 387384, 1 }, -- Increases your critical strike chance by 3%. Physical attacks against you have a 25% chance to make your next Incinerate instant cast. This effect can only occur once every 6 sec.
    banish                         = { 71944, 710   , 1 }, -- Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect.
    burn_to_ashes                  = { 71964, 387153, 2 }, -- Chaos Bolt and Rain of Fire increase the damage of your next 2 Incinerates by 15%. Stacks up to 4 times.
    burning_rush                   = { 71949, 111400, 1 }, -- Increases your movement speed by 50%, but also damages you for 4% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until canceled.
    cataclysm                      = { 71974, 152108, 1 }, -- Calls forth a cataclysm at the target location, dealing 6,264 Shadowflame damage to all enemies within 8 yards and afflicting them with Immolate.
    channel_demonfire              = { 72064, 196447, 1 }, -- Launches 15 bolts of felfire over 2.4 sec at random targets afflicted by your Immolate within 40 yds. Each bolt deals 561 Fire damage to the target and 223 Fire damage to nearby enemies.
    chaos_bolt                     = { 72068, 116858, 1 }, -- Unleashes a devastating blast of chaos, dealing a critical strike for 8,867 Chaos damage. Damage is further increased by your critical strike chance.
    chaos_incarnate                = { 71966, 387275, 1 }, -- Chaos Bolt, Rain of Fire, and Shadowburn always gains maximum benefit from your Mastery: Chaotic Energies.
    conflagrate                    = { 72067, 17962 , 1 }, -- Triggers an explosion on the target, dealing 3,389 Fire damage. Reduces the cast time of your next Incinerate or Chaos Bolt by 30% for 10 sec. Generates 5 Soul Shard Fragments.
    conflagration_of_chaos         = { 72061, 387108, 2 }, -- Conflagrate and Shadowburn have a 25% chance to guarantee your next cast of the ability to critically strike, and increase its damage by your critical strike chance.
    crashing_chaos                 = { 71960, 387355, 2 }, -- Summon Infernal reduces the Soul Shard cost of your next 3 casts of Chaos Bolt, Shadowburn, or Rain of Fire by 1.
    cry_havoc                      = { 71981, 387522, 1 }, -- When Chaos Bolt damages a target afflicted by Havoc, it explodes, dealing 1,318 damage to enemies within 8 yards.
    curses_of_enfeeblement         = { 71951, 386105, 1 }, -- Grants access to the following abilities: Curse of Tongues: Forces the target to speak in Demonic, increasing the casting time of all spells by 30% for 1 min. Curses: A warlock can only have one Curse active per target. Curse of Exhaustion: Reduces the target's movement speed by 50% for 12 sec. Curses: A warlock can only have one Curse active per target.
    dark_accord                    = { 71956, 386659, 1 }, -- Reduces the cooldown of Unending Resolve by 45 sec.
    dark_pact                      = { 71936, 108416, 1 }, -- Sacrifices 20% of your current health to shield you for 250% of the sacrificed health plus an additional 12,365 for 20 sec. Usable while suffering from control impairing effects.
    darkfury                       = { 71941, 264874, 1 }, -- Reduces the cooldown of Shadowfury by 15 sec and increases its radius by 2 yards.
    decimation                     = { 71977, 387176, 1 }, -- Your Incinerate and Conflagrate casts on targets that have 50% or less health reduce the cooldown of Soulfire by 5 sec.
    demon_skin                     = { 71952, 219272, 2 }, -- Your Soul Leech absorption now passively recharges at a rate of 0.2% of maximum health every 1 sec, and may now absorb up to 15% of maximum health.
    demonic_circle                 = { 71933, 268358, 1 }, -- Summons a Demonic Circle for 15 min. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects. You also learn:  Demonic Circle: Teleport Teleports you to your Demonic Circle and removes all movement slowing effects.
    demonic_embrace                = { 71930, 288843, 1 }, -- Stamina increased by 10%.
    demonic_fortitude              = { 71922, 386617, 1 }, -- Increases you and your pets' maximum health by 6%.
    demonic_gateway                = { 71955, 111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per 1.5 min.
    demonic_inspiration            = { 71928, 386858, 1 }, -- Filling a Soul Shard increases the attack speed of your primary pet by 5% for 8 sec. Increases Grimoire of Sacrifice damage by 15%.
    demonic_resilience             = { 71917, 389590, 2 }, -- Reduces the chance you will be critically struck by 2%. All damage your primary demon takes is reduced by 8%.
    desperate_pact                 = { 71929, 386619, 2 }, -- Drain Life heals for 15% more while below 50% health.
    diabolic_embers                = { 71968, 387173, 1 }, -- Incinerate now generates 100% additional Soul Shard Fragments.
    dimensional_rift               = { 71966, 387976, 1 }, -- Rips a hole in time and space, opening a random portal that damages your target: Shadowy Tear Deals 15,954 Shadow damage over 14 sec. Unstable Tear Deals 13,709 Chaos damage over 6 sec. Chaos Tear Fires a Chaos Bolt, dealing 4,524 Chaos damage. This Chaos Bolt always critically strikes and your critical strike chance increases its damage. Generates 3 Soul Shard Fragments.
    eradication                    = { 71984, 196412, 2 }, -- Chaos Bolt increases the damage you deal to the target by 5% for 7 sec.
    explosive_potential            = { 72059, 388827, 1 }, -- Reduces the cooldown of Conflagrate by 2 sec.
    fel_armor                      = { 71950, 386124, 2 }, -- When Soul Leech absorbs damage, 5% of damage taken is absorbed and spread out over 5 sec. Reduces damage taken by 1.5%.
    fel_domination                 = { 71931, 333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by 5.5 sec.
    fel_pact                       = { 71932, 386113, 2 }, -- Reduces the cooldown of Fel Domination by 30 sec.
    fel_synergy                    = { 71918, 389367, 1 }, -- Soul Leech also heals you for 25% and your pet for 50% of the absorption it grants.
    fiendish_stride                = { 71948, 386110, 2 }, -- Reduces the damage dealt by Burning Rush by 25%. Burning Rush increases your movement speed by an additional 5%.
    fire_and_brimstone             = { 71982, 196408, 2 }, -- Incinerate now also hits all enemies near your target for 13% damage.
    flashpoint                     = { 71972, 387259, 2 }, -- When your Immolate deals periodic damage to a target above 80% health, gain 2% Haste for 10 sec. Stacks up to 3 times.
    frequent_donor                 = { 71937, 386686, 1 }, -- Reduces the cooldown of Dark Pact by 15 sec.
    gorefiends_resolve             = { 71916, 389623, 2 }, -- Targets resurrected with Soulstone resurrect with 20% additional health and 15% additional mana.
    grand_warlocks_design          = { 71959, 387084, 1 }, -- Every Soul Shard you spend reduces the cooldown of Summon Infernal by 1.5 sec.
    greater_banish                 = { 71943, 386651, 1 }, -- Increases the duration of Banish by 30 sec. Banish now affects Undead.
    grim_feast                     = { 71926, 386689, 1 }, -- Drain Life now channels 30% faster and restores health 30% faster.
    grimoire_of_sacrifice          = { 71971, 108503, 1 }, -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal 1,678 additional Shadow damage. Lasts 1 |4hour:hrs; or until you summon a demon pet.
    grimoire_of_synergy            = { 71924, 171975, 2 }, -- Damage done by you or your demon has a chance to grant the other one 5% increased damage for 15 sec.
    havoc                          = { 71979, 80240 , 1 }, -- Marks a target with Havoc for 15 sec, causing your single target spells to also strike the Havoc victim for 60% of normal initial damage.
    howl_of_terror                 = { 71947, 5484  , 1 }, -- Let loose a terrifying howl, causing 5 enemies within 10 yds to flee in fear, disorienting them for 20 sec. Damage may cancel the effect.
    ichor_of_devils                = { 71937, 386664, 1 }, -- Dark Pact sacrifices only 5% of your current health for the same shield value.
    improved_conflagrate           = { 72065, 231793, 1 }, -- Conflagrate gains an additional charge.
    improved_immolate              = { 71976, 387093, 2 }, -- Increases the duration of Immolate by 3 sec.
    infernal_brand                 = { 71958, 387475, 2 }, -- Your Infernal's melee attacks cause its target to take 3% increased damage from its Immolation, stacking up to 15 times.
    inferno                        = { 71974, 270545, 1 }, -- Rain of Fire damage is increased by 20% and has a 20% chance to generate a Soul Shard Fragment.
    inquisitors_gaze               = { 71939, 386344, 1 }, -- Summon an Inquisitor's Eye that periodically blasts enemies for 254 Shadowflame damage and occasionally dealing 290 Shadowflame damage instead. Lasts 1 |4hour:hrs;.
    internal_combustion            = { 71980, 266134, 1 }, -- Chaos Bolt consumes up to 5 sec of Immolate's damage over time effect on your target, instantly dealing that much damage.
    lifeblood                      = { 71940, 386646, 2 }, -- When you use a Healthstone, gain 7% Leech for 20 sec.
    madness_of_the_azjaqir         = { 71967, 387400, 2 }, -- Chaos Bolt increases the damage of Chaos Bolt by 12% and reduces the cast time of Chaos Bolt by 10% for 4 sec. Rain of Fire increases the damage of Rain of Fire by 12% for 4 sec. Shadowburn increases the damage of Shadowburn by 12% for 4 sec.
    master_ritualist               = { 71962, 387165, 2 }, -- Ritual of Ruin requires 2 less Soul Shards spent.
    mayhem                         = { 71979, 387506, 1 }, -- Your single target spells have a 35% chance to apply Havoc to a nearby enemy for 5.0 sec.  Havoc Marks a target with Havoc for 5.0 sec, causing your single target spells to also strike the Havoc victim for 60% of normal initial damage.
    mortal_coil                    = { 71947, 6789  , 1 }, -- Horrifies an enemy target into fleeing, incapacitating for 3 sec and healing you for 20% of maximum health.
    nightmare                      = { 71945, 386648, 2 }, -- When Fear ends, the target is slowed by 15% for 4 sec.
    pandemonium                    = { 71981, 387509, 1 }, -- Increases the base duration of Havoc by 3 sec. Mayhem has an additional 10% chance to trigger.
    power_overwhelming             = { 71965, 387279, 2 }, -- Consuming Soul Shards increases your Mastery by 0.5% for 10 sec for each shard spent. Gaining a stack does not refresh the duration.
    profane_bargain                = { 71919, 389576, 2 }, -- When your health drops below 35%, the percentage of damage shared via your Soul Link is increased by an additional 5%. While Grimoire of Sacrifice is active, your Stamina is increased by 5%.
    pyrogenics                     = { 71975, 387095, 1 }, -- Enemies affected by your Rain of Fire take 5% increased damage from your Fire spells.
    raging_demonfire               = { 72063, 387166, 2 }, -- Channel Demonfire fires an additional 2 bolts. Each bolt increases the remaining duration of Immolate on all targets hit by 0.2 sec.
    rain_of_chaos                  = { 71959, 266086, 1 }, -- While your initial Infernal is active, every Soul Shard you spend has a 15% chance to summon an additional Infernal that lasts 8 sec.
    rain_of_fire                   = { 72069, 5740  , 1 }, -- Calls down a rain of hellfire, dealing 3,369 Fire damage over 6.4 sec to enemies in the area. Rain of Fire has a 20% chance to generate a Soul Shard Fragment.
    resolute_barrier               = { 71915, 389359, 2 }, -- Attacks received that deal at least 5% of your health decrease Unending Resolve's cooldown by 10 sec. Cannot occur more than once every 30 sec.
    reverse_entropy                = { 71980, 205148, 1 }, -- Your spells have a chance to grant you 15% Haste for 8 sec.
    ritual_of_ruin                 = { 71970, 387156, 1 }, -- Every 15/12/10 Soul Shards spent grants Ritual of Ruin, making your next Chaos Bolt or Rain of Fire consume no Soul Shards and have its cast time reduced by 50%.
    roaring_blaze                  = { 72065, 205184, 1 }, -- Conflagrate increases your Immolate, Incinerate, and Conflagrate damage to the target by 25% for 8 sec.
    rolling_havoc                  = { 71961, 387569, 2 }, -- Each time your spells duplicate from Havoc, gain 1% increased damage for 6 sec. Stacks up to 5 times.
    ruin                           = { 72062, 387103, 2 }, -- Increases the damage of Conflagrate, Channel Demonfire, Shadowburn, and Soulfire by 10%.
    scalding_flames                = { 71973, 388832, 2 }, -- Increases the damage of Immolate by 13%.
    shadowburn                     = { 72060, 17877 , 1 }, -- Blasts a target for 2,320 Shadowflame damage, gaining 50% critical strike chance on targets that have 20% or less health. Restores 1 Soul Shard and refunds a charge if the target dies within 5 sec.
    shadowflame                    = { 71941, 384069, 1 }, -- Slows enemies in a 12 yard cone in front of you by 70% for 6 sec.
    shadowfury                     = { 71942, 30283 , 1 }, -- Stuns all enemies within 8 yds for 3 sec.
    soul_conduit                   = { 71923, 215941, 2 }, -- Every Soul Shard you spend has a 5% chance to be refunded.
    soul_fire                      = { 71978, 6353  , 1 }, -- Burns the enemy's soul, dealing 9,135 Fire damage and applying Immolate. Generates 1 Soul Shard.
    soul_link                      = { 71925, 108415, 1 }, -- 10% of all damage you take is taken by your demon pet instead. While Grimoire of Sacrifice is active, your Stamina is increased by 10%.
    soulburn                       = { 71957, 385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells. Demonic Circle: Teleport: Increases your movement speed by 50% and makes you immune to snares and roots for 8 sec. Demonic Gateway: Can be cast instantly. Drain Life: Gain an absorb shield equal to the amount of healing done for 30 sec. This shield cannot exceed 30% of your maximum health. Health Funnel: Restores 140% more health and reduces the damage taken by your pet by 30% for 10 sec. Healthstone: Increases the healing of your Healthstone by 30% and increases your maximum health by 20% for 12 sec.
    strength_of_will               = { 71956, 317138, 1 }, -- Unending Resolve reduces damage taken by an additional 15%.
    summon_infernal                = { 71985, 1122  , 1 }, -- Summons an Infernal from the Twisting Nether, impacting for 1,582 Fire damage and stunning all enemies in the area for 2 sec. The Infernal will serve you for 30 sec, dealing 1,160 damage to all nearby enemies every 1.6 sec and generating 1 Soul Shard Fragment every 0.5 sec.
    summon_soulkeeper              = { 71939, 386256, 1 }, -- Summons a Soulkeeper that consumes all Tormented Souls you've collected, blasting nearby enemies for 580 Chaos damage every 1 sec for each Tormented Soul consumed. You collect Tormented Souls from each target you kill and occasionally escaped souls you previously collected.
    sweet_souls                    = { 71927, 386620, 1 }, -- Your Healthstone heals you for an additional 10% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount.
    teachings_of_the_black_harvest = { 71938, 385881, 1 }, -- TODO: Your primary pets gain a bonus effect. Imp: Successful Singe Magic casts grant the target 4% damage reduction for 5 sec. Voidwalker: Reduces the cooldown of Shadow Bulwark by 30 sec. Felhunter: Reduces the cooldown of Devour Magic by 5 sec. Sayaad: Reduces the cooldown of Seduction by 10 sec and causes the target to walk faster towards the demon.
    teachings_of_the_satyr         = { 71935, 387972, 1 }, -- Reduces the cooldown of Amplify Curse by 10 sec.
    wrathful_minion                = { 71946, 386864, 1 }, -- Filling a Soul Shard increases the damage done by your primary pet by 5% for 8 sec. Increases Grimoire of Sacrifice damage by 15%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bane_of_fragility = 3502, -- (199954) Reduces the target's maximum health by up to 15% for 10 sec.
    bane_of_havoc     = 164 , -- (200546) Curses the ground with a demonic bane, causing all of your single target spells to also strike targets marked with the bane. Lasts 13 sec.
    bonds_of_fel      = 5401, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the 8 yd radius they explode, dealing 10,282 Fire damage split amongst all nearby enemies.
    call_observer     = 5544, -- (201996) Summons a demonic Observer to keep a watchful eye over the area for 20 sec. Anytime an enemy within 20 yards casts a harmful magical spell, the Observer will deal up to 5% of the target's maximum health in Shadow damage.
    casting_circle    = 3510, -- (221703) Summons a Casting Circle for 12 sec. While within the casting circle, you are immune to silence and interrupt effects.
    cremation         = 159 , -- (212282) Conflagrate deals up to an additional 3% of the target's maximum health in Fire damage if the target is affected by your Immolate.
    essence_drain     = 3509, -- (221711) Whenever you heal yourself with Drain Life, the enemy target deals 9% reduced damage to you for 10 sec. Stacks up to 4 times.
    fel_fissure       = 157 , -- (200586) Chaos Bolt creates a 5 yd wide eruption of Felfire under the target, reducing movement speed by 50% and reducing all healing received by 25% on all enemies within the fissure. Lasts 6 sec.
    gateway_mastery   = 5382, -- (248855) Increases the range of your Demonic Gateway by 20 yards, and reduces the cast time by 30%. Reduces the time between how often players can take your Demonic Gateway by 30 sec.
    nether_ward       = 3508, -- (212295) Surrounds the caster with a shield that lasts 3 sec, reflecting all harmful spells cast on you.
    precognition      = 5507, -- (377360) If an interrupt is used on you while you are not casting, gain 15% haste and become immune to control and interrupt effects for 4 sec.
    shadow_rift       = 5393, -- (353294) Conjure a Shadow Rift at the target location lasting 2 sec. Enemy players within the rift when it expires are teleported to your Demonic Circle. Must be within 40 yds of your Demonic Circle to cast.
} )


-- Auras
spec:RegisterAuras( {
    active_havoc = {
        duration = function () return level > 53 and 12 or 10 end,
        max_stack = 1,

        generate = function( ah )
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
        duration = function() return talent.greater_banish.enabled and 60 or 30 end,
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
        max_stack = 4
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
        duration = 3,
        tick_time = 0.2,
        type = "Magic",
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
        id = 387356,
        duration = 45,
        max_stack = 3,
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
    fear = {
        id = 118699,
        duration = 20,
        type = "Magic",
        max_stack = 1,
    },
    fel_armor = {
        id = 387846,
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
        duration = function() return talent.pandemonium.enabled and 15 or 12 end,
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
        duration = function() return 18 + 3 * talent.improved_immolate.rank end,
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
    -- Talent: Taking $w1% increased Fire damage from Infernal.
    -- https://wowhead.com/beta/spell=340045
    infernal_brand = {
        id = 340045,
        duration = 8,
        max_stack = 15
    },
    -- Talent: Observed by an Inquisitor's Eye.
    -- https://wowhead.com/beta/spell=388068
    inquisitors_gaze = {
        id = 388068,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Leech increased by $w1%.
    -- https://wowhead.com/beta/spell=386647
    lifeblood = {
        id = 386647,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Chaos Bolt damage is increased by $w1% and its cast time is reduced by $w2%.
    -- https://wowhead.com/beta/spell=387409
    madness_of_the_azjaqir_cb = {
        id = 387409,
        duration = 5,
        max_stack = 1,
        copy = "madness_cb"
    },
    -- Talent: Rain of Fire damage is increased by $w1%.
    -- https://wowhead.com/beta/spell=387413
    madness_of_the_azjaqir_rof = {
        id = 387413,
        duration = 5,
        max_stack = 1,
        copy = "madness_rof"
    },
    -- Talent: Shadowburn damage is increased by $w1%.
    -- https://wowhead.com/beta/spell=387414
    madness_of_the_azjaqir_sb = {
        id = 387414,
        duration = 5,
        max_stack = 1,
        copy = "madness_sb"
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
    -- Talent: Movement speed reduced by $w1%.
    -- https://wowhead.com/beta/spell=386649
    nightmare = {
        id = 386649,
        duration = 4,
        type = "Magic",
        max_stack = 1
    },
    -- Dealing damage to all nearby targets every $t1 sec and healing the casting Warlock.
    -- https://wowhead.com/beta/spell=205179
    phantom_singularity = {
        id = 205179,
        duration = 16,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: The percentage of damage shared via your Soul Link is increased by an additional $s2%.
    -- https://wowhead.com/beta/spell=394747
    profane_bargain = {
        id = 394747,
        duration = 3600,
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
    -- Talent:
    -- https://wowhead.com/beta/spell=386256
    summon_soulkeeper = {
        id = 386256,
        duration = 20,
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

spec:RegisterStateExpr( "last_havoc", function ()
    return pvptalent.bane_of_havoc.enabled and action.bane_of_havoc.lastCast or action.havoc.lastCast
end )

spec:RegisterStateExpr( "havoc_remains", function ()
    return buff.active_havoc.remains
end )

spec:RegisterStateExpr( "havoc_active", function ()
    return buff.active_havoc.up
end )

spec:RegisterHook( "TimeToReady", function( wait, action )
    local ability = action and class.abilities[ action ]

    if ability and ability.spend and ability.spendType == "soul_shards" and ability.spend > soul_shard then
        wait = 3600
    end

    return wait
end )

spec:RegisterStateExpr( "soul_shard", function () return soul_shards.current end )


local lastTarget

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID and subtype == "SPELL_CAST_SUCCESS" and destGUID ~= nil and destGUID ~= "" then
        lastTarget = destGUID
    end
end, false )


local SUMMON_DEMON_TEXT

spec:RegisterHook( "reset_precast", function ()
    last_havoc = nil
    soul_shards.actual = nil

    class.abilities.summon_pet = class.abilities[ settings.default_pet ]

    if not SUMMON_DEMON_TEXT then
        SUMMON_DEMON_TEXT = GetSpellInfo( 180284 )
        class.abilityList.summon_pet = "|T136082:0|t |cff00ccff[" .. ( SUMMON_DEMON_TEXT or "Summon Demon" ) .. "]|r"
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
    -- Talent: Calls forth a cataclysm at the target location, dealing 6,264 Shadowflame damage to all enemies within 8 yards and afflicting them with Immolate.
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

        handler = function ()
            applyDebuff( "target", "immolate" )
            active_dot.immolate = max( active_dot.immolate, true_active_enemies )
            removeDebuff( "target", "combusting_engine" )
        end,
    },

    -- Talent: Launches 15 bolts of felfire over 2.4 sec at random targets afflicted by your Immolate within 40 yds. Each bolt deals 561 Fire damage to the target and 223 Fire damage to nearby enemies.
    channel_demonfire = {
        id = 196447,
        cast = 3,
        channeled = true,
        cooldown = 25,
        gcd = "spell",
        school = "fire",

        spend = 0.015,
        spendType = "mana",

        talent = "channel_demonfire",
        startsCombat = true,

        usable = function () return active_dot.immolate > 0 end,
        -- With raging_demonfire, this will extend Immolates but it's not worth modeling for the addon ( 0.2s * 17-20 ticks ).
    },

    -- Talent: Unleashes a devastating blast of chaos, dealing a critical strike for 8,867 Chaos damage. Damage is further increased by your critical strike chance.
    chaos_bolt = {
        id = 116858,
        cast = function () return ( 3 - ( buff.crashing_chaos.up and 1 or 0 ) )
            * haste
            * ( buff.ritual_of_ruin.up and 0.5 or 1 )
            * ( buff.backdraft.up and 0.7 or 1 )
            * ( 1 - 0.1 * ( buff.madness_of_the_azjaqir_cb.up and talent.madness_of_the_azjaqir.rank or 0 ) )
        end,
        cooldown = 0,
        gcd = "spell",
        school = "chromatic",

        spend = function ()
            if buff.ritual_of_ruin.up then return 0 end
            return 2 - ( buff.crashing_chaos.up and 1 or 0 )
        end,
        spendType = "soul_shards",

        talent = "chaos_bolt",
        startsCombat = true,
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
            if talent.madness_of_the_azjaqir.enabled then
                applyBuff( "madness_of_the_azjaqir_cb" )
            end
        end,
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

        usable = function () return not pvptalent.bane_of_havoc.enabled and active_enemies > 1, "requires multiple targets and no bane_of_havoc" end,

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

        handler = function ()
            applyDebuff( "target", "immolate" )
            active_dot.immolate = max( active_dot.immolate, active_dot.bane_of_havoc )
            removeDebuff( "target", "combusting_engine" )
            if talent.flashpoint.enabled and target.health_pct > 80 then addStack( "flashpoint" ) end
        end,
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
    },

    -- Talent: Calls down a rain of hellfire, dealing 3,369 Fire damage over 6.4 sec to enemies in the area. Rain of Fire has a 20% chance to generate a Soul Shard Fragment.
    rain_of_fire = {
        id = 5740,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = function ()
            if buff.ritual_of_ruin.up then return 0 end
            return 3 - ( buff.crashing_chaos.up and 1 or 0 )
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
            if talent.madness_of_the_azjaqir.enabled then applyBuff( "madness_of_the_azjaqir_rof" ) end
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

    -- Talent: Blasts a target for 2,320 Shadowflame damage, gaining 50% critical strike chance on targets that have 20% or less health. Restores 1 Soul Shard and refunds a charge if the target dies within 5 sec.
    shadowburn = {
        id = 17877,
        cast = 0,
        charges = 2,
        cooldown = 12,
        recharge = 12,
        gcd = "spell",
        school = "shadowflame",

        spend = function() return buff.crashing_chaos.up and 0 or 1 end,
        spendType = "soul_shards",

        talent = "shadowburn",
        startsCombat = true,

        handler = function ()
            gain( 0.3, "soul_shards" )
            applyDebuff( "target", "shadowburn" )
            active_dot.shadowburn = max( active_dot.shadowburn, active_dot.bane_of_havoc )

            removeBuff( "conflagration_of_chaos_sb" )

            if talent.madness_of_the_azjaqir.enabled then applyBuff( "madness_of_the_azjaqir_sb" ) end
        end,
    },

    -- Talent: Burns the enemy's soul, dealing 9,135 Fire damage and applying Immolate. Generates 1 Soul Shard.
    soul_fire = {
        id = 6353,
        cast = function () return 4 * haste end,
        cooldown = 45,
        gcd = "spell",
        school = "fire",

        spend = 0.02,
        spendType = "mana",

        talent = "soul_fire",
        startsCombat = true,
        aura = "immolate",

        handler = function ()
            gain( 1, "soul_shards" )
            applyDebuff( "target", "immolate" )
        end,
    },

    -- Talent: Summons an Infernal from the Twisting Nether, impacting for 1,582 Fire damage and stunning all enemies in the area for 2 sec. The Infernal will serve you for 30 sec, dealing 1,160 damage to all nearby enemies every 1.6 sec and generating 1 Soul Shard Fragment every 0.5 sec.
    summon_infernal = {
        id = 1122,
        cast = 0,
        cooldown = 180,
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
            if talent.crashing_chaos.enabled then applyBuff( "crashing_chaos", nil, 3 ) end
        end,
    },

    -- Talent: Summons a Soulkeeper that consumes all Tormented Souls you've collected, blasting nearby enemies for 580 Chaos damage every 1 sec for each Tormented Soul consumed. You collect Tormented Souls from each target you kill and occasionally escaped souls you previously collected.
    summon_soulkeeper = {
        id = 386256,
        cast = 1,
        cooldown = 0,
        gcd = "spell",
        school = "shadowflame",

        talent = "summon_soulkeeper",
        startsCombat = true,
        buff = "tormented_souls",

        handler = function ()
            applyBuff( "summon_soulkeeper", buff.tormented_souls.stack )
            removeBuff( "tormented_souls" )
        end,
    },


} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = true,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageDots = false,
    damageExpiration = 6,

    potion = "spectral_intellect",

    package = "Destruction",
} )


spec:RegisterSetting( "default_pet", "summon_sayaad", {
    name = "Preferred Demon",
    desc = "Specify which demon should be summoned if you have no active pet.",
    type = "select",
    values = function()
        return {
            summon_sayaad = class.abilityList.summon_sayaad,
            summon_imp = class.abilityList.summon_imp,
            summon_felhunter = class.abilityList.summon_felhunter,
            summon_voidwalker = class.abilityList.summon_voidwalker,

        }
    end
} )


spec:RegisterSetting( "fixed_aoe_3_plus", false, {
    name = "Require 3+ Targets for AOE",
    desc = function()
        return "If checked, the default action list will only use its AOE action list (including |T" .. ( GetSpellTexture( 5740 ) ) .. ":0|t Rain of Fire) when there are 3+ targets.\n\n" ..
        "In multi-target Patchwerk simulations, this setting creates a significant DPS loss.  However, this option may be useful in real-world scenarios, especially if you are fighting two moving targets that will not stand in your Rain of Fire for the whole duration."
    end,
    type = "toggle",
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


spec:RegisterPack( "Destruction", 20221120, [[Hekili:TZ1sZTnos4Fl(IS04efrzl7jPK0HD2ltQTYfpNffejKfxtrQWhoXt5s)23gGKGaGObPEyNS7MkPsSfb7Ur)8RXdTWzXFT4EFsgDXxgpA8yhNXJg6C7OBhDZI7ZEEhDX97iEpsEa(HiYw4F)N00SKCVSG4i2ZEomM4ZOrACEIh88nzz7s)0h(WdbzBYxn0lE7hsd2MhsyVHxczDg739(WI7xLheM9Nrlw1uaMm5whqai5zBItwC)9bB)dGYb((0IHtt9wC)I7ddsZszmpiJUL9dFHpDOrKvHu)f)Jf37LapkjGaIknByq0AAsejCibK)NO7x(Yl7xEX(LzKqAu2W08TBJJCfJQKofdllyl1nl21paEVP7xo2bKVs1qEk1TqeYG)aI3AsEyMqEQgw6oAyOByS3JYYygmX5ZHiqstY3L5gSMPCwVE4tXm1wi1nno8jMeMVtz2vr41H00nCDR8mgSiHRcI8BsMksaS(AufwHoYLgr3gqt3VC((Lo7x2B)s9hmDgOn2V8Q9l7lRnluJX1AXEIhTL4hrttDJx7MTH6s(7)n5RbjMgjjDdnYnHULeeLwpGbWSlljWlJPHfQbpcOEl(fxMRrHdIBHFRxiL8eLnLVP7tzyMD9HZksmNptq5tFX8ljMKee9G7QqYFtvua(uUlGxC06qYdjqaYWs1a39Zz4eqnu4A6THK8atEbXDl57UL)UK0wteMGDlQGXCzCtHx3NZKBgEhxw6lXJ5CJTPicV44q)4Vfn0hEqukWzsOBsW6SH(5j8WFUHRsO0hftYUtoCXJKr8cFoDRw0YVJk(vkvYdmDQpfIMxhKi0RsKEdjkIgwpegD)y3ulGs(gPyA2JQOGZiBMC4V(XqCbKKjSWCUobIBzdw2LNNhGPuGuNRYtzSrYXVq1RrNA3IR5dPNwOOqtQMstyWQFUGwZXyIbYl0biKV(5DG81Q2QhY1ShrID2dG4Q0DBOBFw5jY2Z5Q2tWZio1DvCi3F0zSgB7u8FvPGV4ONDTtVE8dE8uZo3Ou8qT4KwmHdEYMQGI8GiiYi6rPm5xWnKLdWpGat7apx62v0KuJzJFcCusyPT9RrbOmWAYTkpjILDGLbpvRuAPxjxvhe5rGjugvXjFqlXQo45W4PnxbGw8zfehY8a5IMUrhYGIMH05o7KpbCwzQb(uqXR2Ja2rwMruxk80xAsoRypcnWtvvQBPje)apsd7tzvf5hlN(qi9vUhf8Fyn7Hqn31HbpSjdt4gJNeKZ7QI)ERSmdhJhV)FVoTJhlhq3O(NgMqCKzkEYqoFfhzv1iowh5C3G3VFEqMIs5IoJwtfeDT)RPQUYYMLuwAilMuypL)05koRa2ZSeaExO1qVX4jnKH30xbf1(LVNNUCGzqpqUAqb999l)nbgj0SkJvG3K6bDmXWPKbDkr1T()UIRc1lyleTYakYMlAJ9JYJny7oAKpBOSQ6GdF8Ugu)6rkccZfijwNSxR07c4Xher5ZeLHbV1UekdQcPUHhuJkx)oQY)IvGMecvLRzZAwmt82GiEUjrVrAfbHxuxy1yBrL0SyWybUTW7Wue5PmpDroajdvBd0qxdfCa6OIs2K6Ms9sOG3i1BtuWxZPYAxKryTdHYGPhsc2gdzpyYwkbE86apdWznombs)At4xZdsdYItsDFaA3qtfQ4Ck3rPYO0REvQg2qG6SuF34Kv88eXjqYnPseydOc2TIVipFPg(gfpwSodC6QllRdnRoRBipf7XrO9urTWIpqUsViY3ulXqoRdVVrope(8gLldGDRjEfQKQ6n4vq6sPrC6IxurUY0mUoaJg4U(nRUXtbdzLhn0HNNvxBpqRGLmVARk0TDXVchnO5MyMRJKsQHF9EtlGKFfYkcu80bfy2BbEboWs02fN8w0RyP5sEifTrFRCvRYE9U37zVqOclRsAwkl2jZwN5D1OxeAzK4nAAVtXQ194HNeHd3TmthK6J5ypmf0EpYdoa(QxxJnIhP0D0eoLpQMpfDpETHcNyDpQ0PPsOQ2aXdBluTkRwy3u)4GY(H522v)Y2At0CVCQlzuRRMfBKUKiF3vqv(0S4i11j0cJKkaMzTPrJTm3Dy9AOCvkv3wxo4rpyRvMbJtMEVvwk9x4kAhPkYu2K(gF5fA8PARCOUAdpYQUuY0gar05bFbRn6P1T(j5R67e5(NrQyvSO)gW(WwG4wQuHdGW6cKIMpOvDs1uQVyfq4VIQNUc5Zc8EeM2hqYalPgBXa23iaYB4WEelkS2MPCvNBp)a2xgSDBrFPn0XpzCwBywXxR1FsNw6auXtTFmjfXZYBX5ajtoBt(k2mldzXWXiCmn30T2tIHAoPuPU9EcGWwKQ(jsiRzyrz4IWU6yxooiLfyBl55n0T1kuGwL8Fhqe36a7u7j1(bVhBDRhPFe7X2KU0XdEynwvHMraMY8Jhv1OszvtDvotdBy)nxNdpuRVCJyw3MTMfBKQe9wUhCN)TD7Wr5AT7RAUPD4jY31XJxr36saFtfEv3)VUNE1yVHVXDWznG9)T2)pC0wDgGEjMWULIrFdcBz)hpLni8aAQ8qMaDDxilToy7GOnUjxu91ClgBRv2UTfJ4PumxlcbGIXIq)A)lFT3)Yw9d7RwO8vDpoT0G0)VVnNwwkgEHUxPdTzTaSlM))g6B58Yhw8lnHTOb2Bm5SWRW4yF315jpBVxJZbVyr)C(XnAGz7jyIYEs551fGPC)3GSjWeh8j(Rnahc2UlojB)Y1Xj7xEjho0LmKNFnhOLpRumZBMKNfVf8l85UurGl1W9F(FbolGJ4N2V8pIJaoXF8LMLvGMzXOpTAMaJQVZ3ha0E)NniDLhw3dt(gRjFSmmgpQTvIi6aAkLfC4AZAGYv5qBMRT2hDKwMZ5PrA7jg7iNuwagngyCXz0P7eZ0vPZEn6ASRFD6(7i0vR5wDsJ07Ro1DgHzeB06zddkAZPDLjI(j1iDJ(q7kbf4B0d70BdTbbrSEAyF0ilcYOUsCJOM0D9SHSQRmsbYLgdmchRRewdPMUz0moUge)JMjUe6CncBa3VorhJKE(SyqXi(z3GIXOt2GIr4ZIbD8nwIolX4Akavd(Bxj7RqncmwjavRRZ1bBFP9c6KyMQ9akMJv06C7WHvetAJhUuVqtZZ0GovrcWprQIL34imsCt064WW4VX3qnsEcbA34B0e4ZZtzupicOgByfyo3VKTAySTAnRACrXC7BEKYO99zd2hSbRiP0pboe89ws5exG4LuSdkhMJIoQpH7pBbbAetiVkb6Q3BFvXDGGQ5Sc7aHhhnQde6D0Goq8FpXoikdoqYGDwQ)Hr8ZE6imgDY1)Wi8zP(NdIJYPbObbY7rez)lSr)cB0pVyJ47W2LhurpmpHdxISIc6OwydeA9kyyEdK6tErsqavCuYicTEf0SVbs9jRzV7SfdymQKTo4NLGYZc6geuUNfAJ0Q1zH2yj)pnAV)Z)j3wXi5DQnOWmhlyFPo4X2ZL7yxeQ41b1hq10HIBg1m17107cwpJTdlZh17cXLGA)NB8Axn7d134jZpV6REI3Xo7aZA5Em1fsGDFLm)UgV5r8PxH(16fyYmj1VMsMhv9fuQttkZx)ievEvVfMFSOvgmXVA)UyopLJyw9x9hIptzsWuzO7rW7K)Qbzg23mi1mt)0LuOdk649DfxkPzomowSJqvNpZ5o9u)GPZgFv)lut92ZAs(EMYQoqEkBw2iXwfSzxRqI6TBKn2(L8uzb)7HF0(M6mCYGxEPCxmNjVhOsmrF3TRmqf7W80BgExV(LV28XV8I0(LoT9ZONMgr3FI9H67)UumL(Yai)EcFxn5D2nYJQ68EXvF9XoPB9ew(gRkaO)mD83ME9GEchgX8c01OhYT5MiJereZhjI04CTzMiAQZYniNnLnSROV8IPtl2lVuRcNRQcn7hZ3QZ2hgRGVIvtTkuNDeQosxqK7fvHbATskIin1(xVQxsP3nWBU0cQ221GbwIcnCQR6jR8yN2kudc(rMAE9PFW(BRCQOqhA5etAjb6HFCLMk4DVlkiOXdPulcMYzrQvl7BUzuphf(SrYAETnJPCKBzN19UWAvJxE5cDKZwiVuM2j9K(TAxLRKoKmwCzRsF3xQeW7DgOMmhIu)ndLhuV8(kku17QVAAxdxn)gzVtIvFjt4jgcfmrkZZBXxPyQ8X9VNYr9Fom70R5prHjGaiVDbizpB7vS58227w72nRHOzZb999hn053uNCdeoIYCPbvBcWtWUMrSMQ9u7kkcnnElQUYe0f(tgm3rN7II2kNp6ctSXIXtmulUc69rutUuvk)WPZUvxklC)miIDtZ3Er1YH24gZks4A6c3oZzu34LsLzvw1O6Sbh2oRnuUTS)0zRBObKrvIxUTs4fzSKI9zVT5BXAVwjy7qnSvbPKiOf60v5nvX139d0zQCU5IgTSMEU1SY6udyw1PDTGo6h513XVPvZmFrRMc()c4af7FHbg0L(QegTtQ)QAE(g1ML0KSzY96NDmnDv)649E17c8JQCt6yl4VFF8MY6H52E(6w7yBqRzIfXSfVGHLRwuD8oAYzzR65S3pzxPouTQLrhBowVtZQFc7lenzshAp8WcsoHgiTse56qNIezOttCQDgBc16KZCVODkdwRfp(X3nlEvLw1oi92InClwY(NL2FngrDwAdgnc9O7gwQWLr4q8e8Z04M(ewheyZee9mVAMfKx33vOdMQGSsMgx3Keg9HvqJmPNT25MnwRz65JBYKdaAF9kXAS8n6uJjN9B89Cb4Mz6B4Ibg1dsEAy6Y(QZ1P38Eb0e(ofCLvNE0nwqDRdmiD6lqGMCa1QFJeenxAlDGiS9kDgHOyLJD4GjMj(6LhfadcAi1G3XoYKMH8ywXDJ6qjRkrG5v9vF60jL4MnDYKI5GWj3Hsj(1CAX)5p]] )
