-- WarlockAffliction.lua
-- November 2022

if UnitClassBase( "player" ) ~= "WARLOCK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local spec = Hekili:NewSpecialization( 265 )

spec:RegisterResource( Enum.PowerType.SoulShards, {},
    setmetatable( {
        actual = nil,
        max = 5,
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
            if k == "count" or k == "current" then return t.actual

            elseif k == "actual" then
                t.actual = UnitPower( "player", Enum.PowerType.SoulShards )
                return t.actual

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
    abyss_walker                   = { 71954, 389609, 1 }, -- Using Demonic Circle: Teleport or your Demonic Gateway reduces all damage you take by 4% for 10 sec.
    accrued_vitality               = { 71953, 386613, 2 }, -- Drain Life heals for 15% of the amount drained over 7.6 sec.
    amplify_curse                  = { 71934, 328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within 15 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional 20%. Curse of Tongues Increases casting time by an additional 40%. Curse of Weakness Enemy is unable to critically strike.
    banish                         = { 71944, 710   , 1 }, -- Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect.
    burning_rush                   = { 71949, 111400, 1 }, -- Increases your movement speed by 50%, but also damages you for 4% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until canceled.
    curses_of_enfeeblement         = { 71951, 386105, 1 }, -- Grants access to the following abilities: Curse of Tongues: Forces the target to speak in Demonic, increasing the casting time of all spells by 30% for 1 min. Curses: A warlock can only have one Curse active per target. Curse of Exhaustion: Reduces the target's movement speed by 50% for 12 sec. Curses: A warlock can only have one Curse active per target.
    dark_accord                    = { 71956, 386659, 1 }, -- Reduces the cooldown of Unending Resolve by 45 sec.
    dark_pact                      = { 71936, 108416, 1 }, -- Sacrifices 20% of your current health to shield you for 200% of the sacrificed health plus an additional 6,815 for 20 sec. Usable while suffering from control impairing effects.
    darkfury                       = { 71941, 264874, 1 }, -- Reduces the cooldown of Shadowfury by 15 sec and increases its radius by 2 yards.
    demon_skin                     = { 71952, 219272, 2 }, -- Your Soul Leech absorption now passively recharges at a rate of 0.2% of maximum health every 1 sec, and may now absorb up to 15% of maximum health.
    demonic_circle                 = { 71933, 268358, 1 }, -- Summons a Demonic Circle for 15 min. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects. You also learn:  Demonic Circle: Teleport Teleports you to your Demonic Circle and removes all movement slowing effects.
    demonic_embrace                = { 71930, 288843, 1 }, -- Stamina increased by 10%.
    demonic_fortitude              = { 71922, 386617, 1 }, -- Increases you and your pets' maximum health by 5%.
    demonic_gateway                = { 71955, 111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per 1.5 min.
    demonic_inspiration            = { 71928, 386858, 1 }, -- Filling a Soul Shard increases the attack speed of your primary pet by 5% for 8 sec. Increases Grimoire of Sacrifice damage by 15%.
    demonic_resilience             = { 71917, 389590, 2 }, -- Reduces the chance you will be critically struck by 2%. All damage your primary demon takes is reduced by 8%.
    desperate_pact                 = { 71929, 386619, 2 }, -- Drain Life heals for 15% more while below 50% health.
    fel_armor                      = { 71950, 386124, 2 }, -- When Soul Leech absorbs damage, 5% of damage taken is absorbed and spread out over 5 sec. Reduces damage taken by 1.5%.
    fel_domination                 = { 71931, 333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by 5.5 sec.
    fel_pact                       = { 71932, 386113, 2 }, -- Reduces the cooldown of Fel Domination by 30 sec.
    fel_synergy                    = { 71918, 389367, 1 }, -- Soul Leech also heals you for 25% and your pet for 50% of the absorption it grants.
    fiendish_stride                = { 71948, 386110, 2 }, -- Reduces the damage dealt by Burning Rush by 25%. Burning Rush increases your movement speed by an additional 5%.
    frequent_donor                 = { 71937, 386686, 1 }, -- Reduces the cooldown of Dark Pact by 15 sec.
    gorefiends_resolve             = { 71916, 389623, 2 }, -- Targets resurrected with Soulstone resurrect with 20% additional health and 15% additional mana.
    greater_banish                 = { 71943, 386651, 1 }, -- Increases the duration of Banish by 30 sec. Banish now affects Undead.
    grim_feast                     = { 71926, 386689, 1 }, -- Drain Life now channels 30% faster and restores health 30% faster.
    grimoire_of_synergy            = { 71924, 171975, 2 }, -- Damage done by you or your demon has a chance to grant the other one 5% increased damage for 15 sec.
    howl_of_terror                 = { 71947, 5484  , 1 }, -- Let loose a terrifying howl, causing 5 enemies within 10 yds to flee in fear, disorienting them for 20 sec. Damage may cancel the effect.
    ichor_of_devils                = { 71937, 386664, 1 }, -- Dark Pact sacrifices only 5% of your current health for the same shield value.
    inquisitors_gaze               = { 71939, 386344, 1 }, -- Summon an Inquisitor's Eye that periodically blasts enemies for 376 Shadowflame damage and occasionally dealing 430 Shadowflame damage instead. Lasts 1 |4hour:hrs;.
    lifeblood                      = { 71940, 386646, 2 }, -- When you use a Healthstone, gain 7% Leech for 20 sec.
    mortal_coil                    = { 71947, 6789  , 1 }, -- Horrifies an enemy target into fleeing, incapacitating for 3 sec and healing you for 20% of maximum health.
    nightmare                      = { 71945, 386648, 2 }, -- When Fear ends, the target is slowed by 15% for 4 sec.
    profane_bargain                = { 71919, 389576, 2 }, -- When your health drops below 35%, the percentage of damage shared via your Soul Link is increased by an additional 5%. While Grimoire of Sacrifice is active, your Stamina is increased by 3%.
    resolute_barrier               = { 71915, 389359, 2 }, -- Attacks received that deal at least 5% of your health decrease Unending Resolve's cooldown by 10 sec. Cannot occur more than once every 30 sec.
    shadowflame                    = { 71941, 384069, 1 }, -- Slows enemies in a 12 yard cone in front of you by 70% for 6 sec.
    shadowfury                     = { 71942, 30283 , 1 }, -- Stuns all enemies within 8 yds for 3 sec.
    soul_conduit                   = { 71923, 215941, 2 }, -- Every Soul Shard you spend has a 5% chance to be refunded.
    soul_link                      = { 71925, 108415, 1 }, -- 10% of all damage you take is taken by your demon pet instead. While Grimoire of Sacrifice is active, your Stamina is increased by 5%.
    soulburn                       = { 71957, 385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells. Demonic Circle: Teleport: Increases your movement speed by 50% and makes you immune to snares and roots for 8 sec. Demonic Gateway: Can be cast instantly. Drain Life: Gain an absorb shield equal to the amount of healing done for 30 sec. This shield cannot exceed 30% of your maximum health. Health Funnel: Restores 140% more health and reduces the damage taken by your pet by 30% for 10 sec. Healthstone: Increases the healing of your Healthstone by 30% and increases your maximum health by 20% for 12 sec.
    strength_of_will               = { 71956, 317138, 1 }, -- Unending Resolve reduces damage taken by an additional 15%.
    summon_soulkeeper              = { 71939, 386256, 1 }, -- Summons a Soulkeeper that consumes all Tormented Souls you've collected, blasting nearby enemies for 829 Chaos damage every 1 sec for each Tormented Soul consumed. You collect Tormented Souls from each target you kill and occasionally escaped souls you previously collected.
    sweet_souls                    = { 71927, 386620, 1 }, -- Your Healthstone heals you for an additional 10% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount.
    teachings_of_the_black_harvest = { 71938, 385881, 1 }, -- Your primary pets gain a bonus effect. Imp: Successful Singe Magic casts grant the target 4% damage reduction for 5 sec. Voidwalker: Reduces the cooldown of Shadow Bulwark by 30 sec. Felhunter: Reduces the cooldown of Devour Magic by 5 sec. Sayaad: Reduces the cooldown of Seduction by 10 sec and causes the target to walk faster towards the demon.
    teachings_of_the_satyr         = { 71935, 387972, 1 }, -- Reduces the cooldown of Amplify Curse by 10 sec.
    wrathful_minion                = { 71946, 386864, 1 }, -- Filling a Soul Shard increases the damage done by your primary pet by 5% for 8 sec. Increases Grimoire of Sacrifice damage by 15%.

    -- Affliction
    absolute_corruption            = { 72053, 196103, 1 }, -- Corruption is now permanent and deals 15% increased damage. Duration reduced to 24 sec against players.
    agonizing_corruption           = { 72038, 386922, 2 }, -- Seed of Corruption's explosion increases the stack count of Agony by 1 on all targets hit.
    creeping_death                 = { 72058, 264000, 1 }, -- Your Agony, Corruption, Siphon Life, and Unstable Affliction deal damage 15% faster.
    dark_harvest                   = { 72057, 387016, 1 }, -- Each target affected by Soul Rot increases your haste and critical strike chance by 2.5% for 8 sec.
    doom_blossom                   = { 71986, 389764, 1 }, -- If Corruption damages a target affected by your Unstable Affliction, it has a 10% chance per stack of Malefic Affliction to deal 1,972 Shadow damage to nearby enemies.
    drain_soul                     = { 72045, 198590, 1 }, -- Drains the target's soul, causing 5,810 Shadow damage over 3.8 sec. Damage is increased by 100% against enemies below 20% health. Generates 1 Soul Shard if the target dies during this effect.
    dread_touch                    = { 71986, 389775, 1 }, -- If Malefic Affliction exceeds 3 stacks, the target instead takes 20% additional damage from your damage over time effects for 6 sec.
    grand_warlocks_design          = { 71988, 387084, 1 }, -- Every Soul Shard you spend reduces the cooldown of Summon Darkglare by 2.0 sec.
    grim_reach                     = { 71988, 389992, 1 }, -- When Darkglare deals damage, it deals 50% of that damage to all enemies affected by your damage over time effects.
    grimoire_of_sacrifice          = { 72054, 108503, 1 }, -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal 1,447 additional Shadow damage. Lasts 1 |4hour:hrs; or until you summon a demon pet.
    harvester_of_souls             = { 72043, 201424, 2 }, -- Each time Corruption deals damage, it has a 7% chance to deal 464 Shadow damage to the target and heal you for 100% of the damage dealt.
    haunt                          = { 72032, 48181 , 1 }, -- A ghostly soul haunts the target, dealing 2,273 Shadow damage and increasing your damage dealt to the target by 10% for 18 sec. If the target dies, Haunt's cooldown is reset.
    haunted_soul                   = { 71989, 387301, 1 }, -- Your Haunt spell also increases the damage of your damage over time effects to all targets by 20% while active.
    inevitable_demise              = { 72046, 334319, 2 }, -- Damaging an enemy with Agony increases the damage of your next Drain Life by 7%. This effect stacks up to 50 times.
    malefic_affliction             = { 71921, 389761, 2 }, -- Malefic Rapture causes your active Unstable Affliction to deal 5% additional damage, up to 15%, for the rest of its duration.
    malefic_rapture                = { 72049, 324536, 1 }, -- Your damaging periodic effects erupt on all targets, causing 1,416 Shadow damage per effect.
    malevolent_visionary           = { 71987, 387273, 2 }, -- Darkglare increases its damage by an additional 3% for each damage over time effect active. Darkglare lasts an additional 5 sec.
    nightfall                      = { 72047, 108558, 1 }, -- Corruption damage has a chance to cause your next Shadow Bolt or Drain Soul to deal 25% increased damage. Shadow Bolt is instant cast and Drain Soul channels 50% faster when affected.
    pandemic_invocation            = { 72052, 386759, 2 }, -- Refreshing Corruption, Agony, Unstable Affliction, or Siphon Life with less than 5 seconds remaining will deal 132 Shadow damage and has a 3.33% chance to grant you a Soul Shard.
    phantom_singularity            = { 72036, 205179, 1 }, -- Places a phantom singularity above the target, which consumes the life of all enemies within 15 yards, dealing 10,570 damage over 12.2 sec, healing you for 25% of the damage done.
    sacrolashs_dark_strike         = { 72035, 386986, 2 }, -- Corruption damage is increased by 7%, and each time it deals damage any of your Curses active on the target are extended by 0.5 sec.
    seed_of_corruption             = { 72050, 27243 , 1 }, -- Embeds a demon seed in the enemy target that will explode after 9.1 sec, dealing 2,936 Shadow damage to all enemies within 10 yards and applying Corruption to them. The seed will detonate early if the target is hit by other detonations, or takes 1,363 damage from your spells.
    seized_vitality                = { 71990, 387250, 2 }, -- Haunt deals 10% additional damage. When the Haunt spell ends or is dispelled, the soul returns to you, healing for 50% of the damage it did to the target.
    shadow_embrace                 = { 72044, 32388 , 2 }, -- Shadow Bolt and Drain Soul apply Shadow Embrace, increasing your damage dealt to the target by 1.5% for 16 sec. Stacks up to 3 times.
    siphon_life                    = { 72053, 63106 , 1 }, -- Siphons the target's life essence, dealing 5,782 Shadow damage over 15 sec and healing you for 30% of the damage done.
    soul_flame                     = { 72041, 199471, 2 }, -- When you kill a target, its soul bursts into flames, dealing 1,322 Shadowflame damage to nearby enemies. Deals reduced damage beyond 8 targets.
    soul_rot                       = { 72056, 386997, 1 }, -- Wither away all life force of your current target and up to 3 additional targets nearby, causing your primary target to suffer 10,339 Nature damage and secondary targets to suffer 5,169 Nature damage over 8 sec. For the next 8 sec, casting Drain Life will cause you to also Drain Life from any enemy affected by your Soul Rot, and Drain Life will not consume any mana.
    soul_swap                      = { 72037, 386951, 1 }, -- Applies Corruption, Agony, and Unstable Affliction to your target.
    soul_tap                       = { 72042, 387073, 1 }, -- Sacrifice 8% of your Soul Leech to gain a Soul Shard.
    souleaters_gluttony            = { 71920, 389630, 2 }, -- Whenever Unstable Affliction deals damage, the cooldown of Soul Rot is reduced by 0.5 sec.
    sow_the_seeds                  = { 72039, 196226, 1 }, -- Seed of Corruption now embeds demon seeds into 2 additional nearby enemies.
    summon_darkglare               = { 72034, 205180, 1 }, -- Summons a Darkglare from the Twisting Nether that extends the duration of your damage over time effects on all enemies by 8 sec. The Darkglare will serve you for 20 sec, blasting its target for 928 Shadow damage, increased by 10% for every damage over time effect you have active on any target.
    tormented_crescendo            = { 72031, 387075, 1 }, -- While Agony, Corruption, and Unstable Affliction are active, your Shadow Bolt has a 30% chance and your Drain Soul has a 20% chance to make your next Malefic Rapture cost no Soul Shards and cast instantly.
    unstable_affliction            = { 72048, 316099, 1 }, -- Afflicts one target with 18,624 Shadow damage over 21 sec. If dispelled, deals 32,416 damage to the dispeller and silences them for 4 sec. Generates 1 Soul Shard if the target dies while afflicted.
    vile_taint                     = { 72036, 278350, 1 }, -- Unleashes a vile explosion at the target location, dealing 8,331 Shadow damage over 10 sec to 8 enemies within 10 yds and applies Agony and Curse of Exhaustion to them.
    withering_bolt                 = { 72055, 386976, 2 }, -- Shadow Bolt and Drain Soul deal 7% increased damage, up to 21%, per damage over time effect you have active on the target.
    wrath_of_consumption           = { 72033, 387065, 1 }, -- Corruption and Agony each grant an application of Wrath of Consumption when a target dies, increasing all periodic damage dealt by 3% for 30 sec, stacking up to 5 times.
    writhe_in_agony                = { 72040, 196102, 2 }, -- Agony's damage starts at 2 stacks and may now ramp up to 14 stacks.
    xavian_teachings               = { 72051, 317031, 1 }, -- Corruption is instant cast and instantly deals 711 damage.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    bane_of_fragility   = 11  , -- (199954) Reduces the target's maximum health by up to 15% for 10 sec.
    bane_of_shadows     = 17  , -- (234877) Magical damage over time effects will strike the target an additional time for 20% of their damage as Shadow. Lasts 10 sec.
    bonds_of_fel        = 5546, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the 8 yd radius they explode, dealing 11,314 Fire damage split amongst all nearby enemies.
    call_observer       = 5543, -- (201996) Summons a demonic Observer to keep a watchful eye over the area for 20 sec. Anytime an enemy within 20 yards casts a harmful magical spell, the Observer will deal up to 5% of the target's maximum health in Shadow damage.
    casting_circle      = 20  , -- (221703) Summons a Casting Circle for 12 sec. While within the casting circle, you are immune to silence and interrupt effects.
    deathbolt           = 12  , -- (264106) Launches a bolt of death at the target, accumulating 50% of the remaining damage from your spells on the target and dealing it over 3 sec.
    essence_drain       = 19  , -- (221711) Whenever you heal yourself with Drain Life, the enemy target deals 9% reduced damage to you for 10 sec. Stacks up to 4 times.
    gateway_mastery     = 15  , -- (248855) Increases the range of your Demonic Gateway by 20 yards, and reduces the cast time by 30%. Reduces the time between how often players can take your Demonic Gateway by 30 sec.
    nether_ward         = 18  , -- (212295) Surrounds the caster with a shield that lasts 3 sec, reflecting all harmful spells cast on you.
    precognition        = 5506, -- (377360) If an interrupt is used on you while you are not casting, gain 15% haste and become immune to control and interrupt effects for 4 sec.
    rampant_afflictions = 5379, -- (335052) Unstable Affliction can now be applied to up to 3 targets.
    rapid_contagion     = 5386, -- (344566) For the next 20 sec, all of your damage over time effects occur 33% more often.
    rot_and_decay       = 16  , -- (212371) Each time your Drain Life deals damage, it increases the duration of your Unstable Affliction, Corruption and Agony on the target by 0.80 sec.
    shadow_rift         = 5392, -- (353294) Conjure a Shadow Rift at the target location lasting 2 sec. Enemy players within the rift when it expires are teleported to your Demonic Circle. Must be within 40 yds of your Demonic Circle to cast.
} )


-- Auras
spec:RegisterAuras( {
    -- Talent: Damage taken is reduced by $s1%.
    -- https://wowhead.com/beta/spell=389614
    abyss_walker = {
        id = 389614,
        duration = 10,
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec. Damage increases over time.
    -- https://wowhead.com/beta/spell=980
    agony = {
        id = 980,
        duration = function () return ( 18 + conduit.rolling_agony.mod * 0.001 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
        tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
        type = "Magic",
        max_stack = function () return 10 + 4 * talent.writhe_in_agony.rank end,
        meta = {
            stack = function( t )
                if t.down then return 0 end
                if t.count >= 10 then return t.count end

                local app = t.applied
                local tick = t.tick_time

                local last_real_tick = now + ( floor( ( now - app ) / tick ) * tick )
                local ticks_since = floor( ( query_time - last_real_tick ) / tick )

                return min( talent.writhe_in_agony.enabled and 18 or 10, t.count + ticks_since )
            end,
        }
    },
    -- Talent: Next Curse of Tongues, Curse of Exhaustion or Curse of Weakness is amplified.
    -- https://wowhead.com/beta/spell=328774
    amplify_curse = {
        id = 328774,
        duration = 15,
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
    -- Talent: Movement speed increased by $s1%.
    -- https://wowhead.com/beta/spell=111400
    burning_rush = {
        id = 111400,
        duration = 3600,
        max_stack = 1
    },
    -- Suffering $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=146739
    corruption = {
        id = 146739,
        duration = function () return ( talent.absolute_corruption.enabled and ( target.is_player and 24 or 3600 ) or 14 ) * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
        tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
        type = "Magic",
        max_stack = 1
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
    dark_harvest = {
        id = 387018,
        duration = 8,
        max_stack = 4,
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=108416
    dark_pact = {
        id = 108416,
        duration = 20,
        max_stack = 1
    },
    decaying_soul_satchel = {
        id = 356369,
        duration = 8,
        max_stack = 4,
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
        max_stack = 1
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
    -- Talent: Suffering $w1 Shadow damage every $t1 seconds.
    -- https://wowhead.com/beta/spell=198590
    drain_soul = {
        id = 198590,
        duration = function () return 5 * ( buff.nightfall.up and 0.5 or 1 ) * haste end,
        tick_time = function ()
            if not settings.manage_ds_ticks then return nil end
            return ( buff.nightfall.up and 0.5 or 1 ) * haste
        end,
        type = "Magic",
        max_stack = 1
    },
    dread_touch = {
        id = 389868,
        duration = 6,
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
    -- Talent: Imp, Voidwalker, Succubus, Felhunter, or Felguard casting time reduced by $/1000;S1 sec.
    -- https://wowhead.com/beta/spell=333889
    fel_domination = {
        id = 333889,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Sacrificed your demon pet to gain its command demon ability.    Your spells sometimes deal additional Shadow damage.
    -- https://wowhead.com/beta/spell=196099
    grimoire_of_sacrifice = {
        id = 196099,
        duration = 3600,
        max_stack = 1
    },
    -- Talent: Taking $s2% increased damage from the Warlock. Haunt's cooldown will be reset on death.
    -- https://wowhead.com/beta/spell=48181
    haunt = {
        id = 48181,
        duration = 18,
        type = "Magic",
        max_stack = 1
    },
    -- Spells cast by the Warlock also hit this target for $s1% of normal initial damage.
    -- https://wowhead.com/beta/spell=80240
    havoc = {
        id = 80240,
        duration = 12,
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
        duration = 18,
        tick_time = 3,
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
    inevitable_demise = {
        id = 334320,
        duration = 20,
        max_stack = 50,
        copy = { 334463, "inevitable_demise_az" }
    },
    -- Taking $w1% increased Fire damage from Infernal.
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
    -- Talent: $@auracaster's Unstable Affliction deals $s1% additional damage.
    -- https://wowhead.com/beta/spell=389845
    malefic_affliction = {
        id = 389845,
        duration = 3600,
        max_stack = 3
    },
    --
    -- https://wowhead.com/beta/spell=77215
    mastery_potent_afflictions = {
        id = 77215,
        duration = 3600,
        max_stack = 1
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
    nightfall = {
        id = 264571,
        duration = 12,
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
    -- Talent: Dealing damage to all nearby targets every $t1 sec and healing the casting Warlock.
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
    --
    -- https://wowhead.com/beta/spell=698
    ritual_of_summoning = {
        id = 698,
        duration = 120,
        type = "Magic",
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
    -- Talent: Embeded with a demon seed that will soon explode, dealing Shadow damage to the caster's enemies within $27285A1 yards, and applying Corruption to them.    The seed will detonate early if the target is hit by other detonations, or takes $w3 damage from your spells.
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
    shadow_embrace = {
        id = 32390,
        duration = 16,
        type = "Magic",
        max_stack = 3,
    },
    -- If the target dies and yields experience or honor, Shadowburn restores ${$245731s1/10} Soul Shard and refunds a charge.
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
    -- Talent: Suffering $w1 Shadow damage every $t1 sec and siphoning life to the casting Warlock.
    -- https://wowhead.com/beta/spell=63106
    siphon_life = {
        id = 63106,
        duration = function () return 15 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
        tick_time = function () return 3 * ( talent.creeping_death.enabled and 0.85 or 1 ) end,
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
    -- Talent: Suffering $s2 Nature damage every $t2 sec.
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
    -- Talent: Summons a Darkglare from the Twisting Nether that blasts its target for Shadow damage, dealing increased damage for every damage over time effect you have active on any target.
    -- https://wowhead.com/beta/spell=205180
    summon_darkglare = {
        id = 205180,
        duration = function() return 20 + 5 * talent.malevolent_visionary.rank end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=386256
    summon_soulkeeper = {
        id = 386256,
        duration = 12,
        max_stack = 1
    },
    --
    -- https://wowhead.com/beta/spell=101508
    the_codex_of_xerrath = {
        id = 101508,
        duration = 3600,
        max_stack = 1
    },
    tormented_crescendo = {
        id = 387079,
        duration = 10,
        max_stack = 1,
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
    -- Damage taken reduced by $w3%  Immune to interrupt and silence effects.
    -- https://wowhead.com/beta/spell=104773
    unending_resolve = {
        id = 104773,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=316099
    unstable_affliction = {
        id = function () return pvptalent.rampant_afflictions.enabled and 342938 or 316099 end,
        duration = function () return 16 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
        tick_time = function () return 2 * ( talent.creeping_death.enabled and 0.85 or 1 ) * haste end,
        type = "Magic",
        max_stack = 1,
        copy = { 342938, 316099 }
    },
    -- Talent: Suffering $w1 Shadow damage every $t1 sec.
    -- https://wowhead.com/beta/spell=386931
    vile_taint = {
        id = 386931,
        duration = 10,
        tick_time = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Periodic damage increased by $s1%.
    -- https://wowhead.com/beta/spell=387066
    wrath_of_consumption = {
        id = 387066,
        duration = 30,
        max_stack = 5,
        copy = 337130
    },
    -- Talent: Damage done increased by $w1%.
    -- https://wowhead.com/beta/spell=386865
    wrathful_minion = {
        id = 386865,
        duration = 8,
        max_stack = 1
    },


    -- PvP Talents
    casting_circle = {
        id = 221705,
        duration = 3600,
        max_stack = 1,
    },
    curse_of_fragility = {
        id = 199954,
        duration = 10,
        max_stack = 1,
    },
    curse_of_shadows = {
        id = 234877,
        duration = 10,
        type = "Curse",
        max_stack = 1,
    },
    demon_armor = {
        id = 285933,
        duration = 3600,
        max_stack = 1,
    },
    essence_drain = {
        id = 221715,
        duration = 10,
        type = "Magic",
        max_stack = 5,
    },
    soulshatter = {
        id = 236471,
        duration = 8,
        max_stack = 5,
    },


    -- Conduit
    diabolic_bloodstone = {
        id = 340563,
        duration = 8,
        max_stack = 1
    },


    -- Legendaries
    malefic_wrath = {
        id = 337125,
        duration = 8,
        max_stack = 1
    },

    relic_of_demonic_synergy = {
        id = 337060,
        duration = 15,
        max_stack = 1
    },

    -- Azerite
    cascading_calamity = {
        id = 275378,
        duration = 15,
        max_stack = 1
    },
} )


spec:RegisterHook( "TimeToReady", function( wait, action )
    local ability = action and class.abilities[ action ]

    if ability and ability.spend and ability.spendType == "soul_shards" and ability.spend > soul_shard then
        wait = 3600
    end

    return wait
end )

spec:RegisterStateExpr( "soul_shard", function () return soul_shards.current end )


state.sqrt = math.sqrt

spec:RegisterStateExpr( "time_to_shard", function ()
    local num_agony = active_dot.agony
    if num_agony == 0 then return 3600 end

    return 1 / ( 0.16 / sqrt( num_agony ) * ( num_agony == 1 and 1.15 or 1 ) * num_agony / debuff.agony.tick_time )
end )


spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
    if sourceGUID == GUID and spellName == class.abilities.seed_of_corruption.name then
        if subtype == "SPELL_CAST_SUCCESS" then
            action.seed_of_corruption.flying = GetTime()
        elseif subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" then
            action.seed_of_corruption.flying = 0
        end
    end
end, false )


spec:RegisterGear( "tier28", 188884, 188887, 188888, 188889, 188890 )

-- Tier 28
spec:RegisterSetBonuses( "tier28_2pc", 364437, "tier28_4pc", 363953 )
-- 2-Set - Deliberate Malice - Malefic Rapture's damage is increased by 15% and each cast extends the duration of Corruption, Agony, and Unstable Affliction by 2 sec.
-- 4-Set - Calamitous Crescendo - While Agony, Corruption, and Unstable Affliction are active, your Drain Soul has a 10% chance / Shadow Bolt has a 20% chance to make your next Malefic Rapture cost no Soul Shards and cast instantly.
spec:RegisterAura( "calamitous_crescendo", {
    id = 364322,
    duration = 10,
    max_stack = 1,
} )

spec:RegisterGear( "tier21", 152174, 152177, 152172, 152176, 152173, 152175 )
spec:RegisterGear( "tier20", 147183, 147186, 147181, 147185, 147182, 147184 )
spec:RegisterGear( "tier19", 138314, 138323, 138373, 138320, 138311, 138317 )
spec:RegisterGear( "class", 139765, 139768, 139767, 139770, 139764, 139769, 139766, 139763 )

spec:RegisterGear( "amanthuls_vision", 154172 )
spec:RegisterGear( "hood_of_eternal_disdain", 132394 )
spec:RegisterGear( "norgannons_foresight", 132455 )
spec:RegisterGear( "pillars_of_the_dark_portal", 132357 )
spec:RegisterGear( "power_cord_of_lethtendris", 132457 )
spec:RegisterGear( "reap_and_sow", 144364 )
spec:RegisterGear( "sacrolashs_dark_strike", 132378 )
spec:RegisterGear( "soul_of_the_netherlord", 151649 )
spec:RegisterGear( "stretens_sleepless_shackles", 132381 )
spec:RegisterGear( "the_master_harvester", 151821 )


--[[ spec:RegisterStateFunction( "applyUnstableAffliction", function( duration )
    for i = 1, 5 do
        local aura = "unstable_affliction_" .. i

        if debuff[ aura ].down then
            applyDebuff( "target", aura, duration or 8 )
            break
        end
    end
end ) ]]


spec:RegisterHook( "reset_preauras", function ()
    if class.abilities.summon_darkglare.realCast and state.now - class.abilities.summon_darkglare.realCast < 20 then
        target.updated = true
    end
end )


local SUMMON_DEMON_TEXT

spec:RegisterHook( "reset_precast", function ()
    soul_shards.actual = nil

    local icd = 25

    if debuff.drain_soul.up then
        local ticks = debuff.drain_soul.ticks_remain
        if pvptalent.rot_and_decay.enabled then
            if debuff.agony.up then debuff.agony.expires = debuff.agony.expires + 1 end
            if debuff.corruption.up then debuff.corruption.expires = debuff.corruption.expires + 1 end
            if debuff.unstable_affliction.up then debuff.unstable_affliction.expires = debuff.unstable_affliction.expires + 1 end
        end
        if pvptalent.essence_drain.enabled and health.pct < 100 then
            addStack( "essence_drain", debuff.drain_soul.remains, debuff.essence_drain.stack + ticks )
        end
    end

    -- Can't trust Agony stacks/duration to refresh.
    local name, _, count, _, duration, expires, caster = FindUnitDebuffByID( "target", 980 )
    if name then
        debuff.agony.expires = expires
        debuff.agony.duration = duration
        debuff.agony.applied = max( 0, expires - duration )
        debuff.agony.count = expires > 0 and max( 1, count ) or 0
        debuff.agony.caster = caster
    else
        debuff.agony.expires = 0
        debuff.agony.duration = 0
        debuff.agony.applied = 0
        debuff.agony.count = 0
        debuff.agony.caster = "nobody"
    end

    if buff.casting.up and buff.casting.v1 == 234153 then
        removeBuff( "inevitable_demise" )
        removeBuff( "inevitable_demise_az" )
    end

    if buff.casting_circle.up then
        applyBuff( "casting_circle", action.casting_circle.lastCast + 8 - query_time )
    end

    class.abilities.summon_pet = class.abilities.summon_felhunter

    if not SUMMON_DEMON_TEXT then
        SUMMON_DEMON_TEXT = GetSpellInfo( 180284 )
        class.abilityList.summon_pet = "|T136082:0|t |cff00ccff[" .. ( SUMMON_DEMON_TEXT or "Summon Demon" ) .. "]|r"
    end
end )


spec:RegisterHook( "spend", function( amt, resource )
    if resource == "soul_shards" and amt > 0 and talent.summon_darkglare.enabled then
        if talent.grand_warlocks_design.enabled then reduceCooldown( "summon_darkglare", amt * 2 ) end
        if legendary.wilfreds_sigil_of_superior_summoning.enabled then reduceCooldown( "summon_darkglare", amt * 2 ) end
    end
end )


spec:RegisterStateExpr( "target_uas", function ()
    return active_dot.unstable_affliction
end )

spec:RegisterStateExpr( "contagion", function ()
    return active_dot.unstable_affliction > 0
end )

spec:RegisterStateExpr( "can_seed", function ()
    local seed_targets = min( active_enemies, Hekili:GetNumTTDsAfter( action.seed_of_corruption.cast + ( 6 * haste ) ) )
    if active_dot.seed_of_corruption < seed_targets - ( state:IsInFlight( "seed_of_corruption" ) and 1 or 0 ) then return true end
    return false
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
    -- Inflicts increasing agony on the target, causing up to 9,300 Shadow damage over 18 sec. Damage starts low and increases over the duration. Refreshing Agony maintains its current damage level. Agony damage sometimes generates 1 Soul Shard.
    agony = {
        id = 980,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "agony", nil, max( 2 * talent.writhe_in_agony.rank + ( azerite.sudden_onset.enabled and 4 or 0 ), debuff.agony.stack ) )
        end,
    },

    -- Talent: Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within 15 sec is amplified. Curse of Exhaustion Reduces the target's movement speed by an additional 20%. Curse of Tongues Increases casting time by an additional 40%. Curse of Weakness Enemy is unable to critically strike.
    amplify_curse = {
        id = 328774,
        cast = 0,
        cooldown = function() return talent.teachings_of_the_satyr.enabled and 20 or 30 end,
        gcd = "off",
        school = "shadow",

        talent = "amplify_curse",
        startsCombat = false,

        handler = function ()
            applyBuff( "amplify_curse" )
        end,
    },

    -- Talent: Banishes an enemy Demon, Aberration, or Elemental, preventing any action for 30 sec. Limit 1. Casting Banish again on the target will cancel the effect.
    banish = {
        id = 710,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.015,
        spendType = "mana",

        talent = "banish",
        startsCombat = true,

        handler = function ()
            if debuff.banish.up then removeDebuff( "target", "banish" )
            else applyDebuff( "target", "banish" ) end
        end,
    },

    -- Talent: Increases your movement speed by 50%, but also damages you for 4% of your maximum health every 1 sec. Movement impairing effects may not reduce you below 100% of normal movement speed. Lasts until canceled.
    burning_rush = {
        id = 111400,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        talent = "burning_rush",
        startsCombat = false,

        handler = function ()
            if buff.burning_rush.up then removeBuff( "burning_rush" )
            else applyBuff( "burning_rush" ) end
        end,
    },

    -- Corrupts the target, causing 6,386 Shadow damage over 14 sec.
    corruption = {
        id = 172,
        cast = function() return talent.xavian_teachings.enabled and 0 or 2 * haste end,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "corruption" )
        end,
    },

    -- Reduces the target's movement speed by 50% for 12 sec. Curses: A warlock can only have one Curse active per target.
    curse_of_exhaustion = {
        id = 334275,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        talent = "curses_of_enfeeblement",
        startsCombat = true,

        handler = function ()
            removeBuff( "amplify_curse" )
            applyDebuff( "target", "curse_of_exhaustion" )
            removeDebuff( "target", "curse_of_tongues" )
            removeDebuff( "target", "curse_of_weakness" )
        end,
    },


    curse_of_fragility = {
        id = 199954,
        cast = 0,
        cooldown = 45,
        gcd = "spell",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "curse_of_fragility",

        startsCombat = true,
        texture = 132097,

        usable = function () return target.is_player end,
        handler = function ()
            applyDebuff( "target", "curse_of_fragility" )
            setCooldown( "curse_of_tongues", max( 6, cooldown.curse_of_tongues.remains ) )
            setCooldown( "curse_of_weakness", max( 6, cooldown.curse_of_weakness.remains ) )
        end,
    },

    -- Forces the target to speak in Demonic, increasing the casting time of all spells by 30% for 1 min. Curses: A warlock can only have one Curse active per target.
    curse_of_tongues = {
        id = 1714,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "curses_of_enfeeblement",
        startsCombat = true,

        handler = function ()
            removeBuff( "amplify_curse" )
            removeDebuff( "target", "curse_of_exhaustion" )
            applyDebuff( "target", "curse_of_tongues" )
            removeDebuff( "target", "curse_of_weakness" )
            setCooldown( "curse_of_fragility", max( 6, cooldown.curse_of_fragility.remains ) )
            setCooldown( "curse_of_weakness", max( 6, cooldown.curse_of_weakness.remains ) )
        end,
    },

    -- Increases the time between an enemy's attacks by 20% for 2 min. Curses: A warlock can only have one Curse active per target.
    curse_of_weakness = {
        id = 702,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            removeBuff( "amplify_curse" )
            removeDebuff( "target", "curse_of_exhaustion" )
            removeDebuff( "target", "curse_of_tongues" )
            applyDebuff( "target", "curse_of_weakness" )
            setCooldown( "curse_of_fragility", max( 6, cooldown.curse_of_fragility.remains ) )
            setCooldown( "curse_of_tongues", max( 6, cooldown.curse_of_tongues.remains ) )
        end,
    },


    -- Talent: Sacrifices 20% of your current health to shield you for 250% of the sacrificed health plus an additional 12,365 for 20 sec. Usable while suffering from control impairing effects.
    dark_pact = {
        id = 108416,
        cast = 0,
        cooldown = function() return talent.frequent_donor.enabled and 45 or 60 end,
        gcd = "off",
        school = "physical",

        talent = "dark_pact",
        startsCombat = false,

        toggle = "defensives",

        usable = function () return health.pct > ( talent.ichor_of_devils.enabled and 10 or 25 ), "insufficient health" end,
        handler = function ()
            applyBuff( "dark_pact" )
            spend( ( talent.ichor_of_devils.enabled and 0.05 or 0.2 ) * health.max, "health" )
        end,
    },


    deathbolt = {
        id = 264106,
        cast = 1,
        cooldown = 30,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        pvptalent = "deathbolt",

        handler = function ()
        end,
    },

    -- Talent: Summons a Demonic Circle for 15 min. Cast Demonic Circle: Teleport to teleport to its location and remove all movement slowing effects. You also learn:  Demonic Circle: Teleport Teleports you to your Demonic Circle and removes all movement slowing effects.
    demonic_circle = {
        id = 268358,
        cast = 0,
        cooldown = 0,
        gcd = "off",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "demonic_circle",
        startsCombat = false,
        nobuff = "demonic_circle",

        handler = function ()
            applyBuff( "demonic_circle" )
        end,
    },


    demonic_circle_teleport = {
        id = 48020,
        cast = 0,
        cooldown = 30,
        gcd = "spell",

        spend = 0.03,
        spendType = "mana",

        startsCombat = false,

        talent = "demonic_circle",
        buff = "demonic_circle",

        handler = function ()
            if talent.abyss_walker.enabled then applyBuff( "abyss_walker" ) end
            if conduit.demonic_momentum.enabled then applyBuff( "demonic_momentum" ) end
        end,
    },

    -- Talent: Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per 1.5 min.
    demonic_gateway = {
        id = 111771,
        cast = function ()
            if legendary.pillars_of_the_dark_portal.enabled or buff.soulburn.up then return 0 end
            return 2 * haste
        end,
        cooldown = 10,
        gcd = "spell",
        school = "shadow",

        spend = 0.2,
        spendType = "mana",

        talent = "demonic_gateway",
        startsCombat = false,

        handler = function ()
            removeBuff( "soulburn" )
        end,
    },


    devour_magic = {
        id = 19505,
        cast = 0,
        cooldown = function() return talent.teachings_of_the_black_harvest.enabled and 10 or 15 end,
        gcd = "off",

        spend = 0,
        spendType = "mana",

        startsCombat = true,
        toggle = "interrupts",

        usable = function ()
            if buff.dispellable_magic.down then return false, "no dispellable magic aura" end
            return true
        end,

        handler = function()
            removeBuff( "dispellable_magic" )
        end,
    },

    -- Drains life from the target, causing 2,174 Shadow damage over 4.0 sec, and healing you for 500% of the damage done. Drain Life heals for 15% more while below 50% health.
    drain_life = {
        id = 234153,
        cast = function () return 5
            * haste
            * ( talent.grim_feast.enabled and 0.7 or 1 )
            * ( legendary.claw_of_endereth.enabled and 0.5 or 1 ) end,
        channeled = true,
        breakable = true,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = function () return active_dot.soul_rot > 0 and 0 or 0.03 end,
        spendType = "mana",

        startsCombat = true,

        start = function ()
            applyDebuff( "target", "drain_life" )
            removeBuff( "inevitable_demise" )
        end,

        finish = function ()
            if talent.accrued_vitality.enabled or conduit.accrued_vitality.enabled then applyBuff( "accrued_vitality" ) end
        end,
    },

    -- Talent: Drains the target's soul, causing 5,810 Shadow damage over 3.8 sec. Damage is increased by 100% against enemies below 20% health. Generates 1 Soul Shard if the target dies during this effect.
    drain_soul = {
        id = 198590,
        cast = function() return 5 * ( buff.nightfall.up and 0.5 or 1 ) * haste end,
        channeled = true,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        prechannel = true,
        breakable = true,
        breakchannel = function () removeDebuff( "target", "drain_soul" ) end,

        talent = "drain_soul",
        startsCombat = true,

        break_any = function ()
            if not settings.manage_ds_ticks then return true end
            return nil
        end,

        tick_time = function ()
            if not talent.shadow_embrace.enabled or not settings.manage_ds_ticks or debuff.shadow_embrace.stack > 2 then return nil end
            return class.auras.drain_soul.tick_time
        end,

        start = function ()
            applyDebuff( "target", "drain_soul" )
            applyBuff( "casting", 5 * haste )

            channelSpell( "drain_soul" )

            removeStack( "decimating_bolt" )
            removeBuff( "malefic_wrath" )
            removeBuff( "nightfall" )

            if talent.shadow_embrace.enabled then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
        end,

        tick = function ()
            if not settings.manage_ds_ticks or not talent.shadow_embrace.enabled or debuff.shadow_embrace.stack > 2 then return end
            applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 )
        end,

        bind = "shadow_bolt"
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

    -- Strikes fear in the enemy, disorienting for 20 sec. Damage may cancel the effect. Limit 1.
    fear = {
        id = 5782,
        cast = 1.7,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.05,
        spendType = "mana",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "fear" )
        end,
    },

    -- Talent: Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by 5.5 sec.
    fel_domination = {
        id = 333889,
        cast = 0,
        cooldown = function () return 180 - 30 * talent.fel_pact.rank + conduit.fel_celerity.mod * 0.001 end,
        gcd = "off",
        school = "shadowstrike",

        talent = "fel_domination",
        startsCombat = false,
        essential = true,
        nomounted = true,
        nobuff = "grimoire_of_sacrifice",

        handler = function ()
            applyBuff( "fel_domination" )
        end,
    },

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

    -- Talent: A ghostly soul haunts the target, dealing 2,273 Shadow damage and increasing your damage dealt to the target by 10% for 18 sec. If the target dies, Haunt's cooldown is reset.
    haunt = {
        id = 48181,
        cast = 1.5,
        cooldown = 15,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "haunt",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "haunt" )
            if level > 51 then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
        end,
    },

        -- Sacrifices 25% of your maximum health to heal your summoned Demon for twice as much over 4.0 sec.
    health_funnel = {
        id = 755,
        cast = 5,
        channeled = true,
        breakable = true,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        startsCombat = false,

        usable = function () return pet.active and pet.alive and pet.health_pct < 100, "requires pet" end,
        start = function ()
            applyBuff( "health_funnel" )
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

    -- Talent: Summon an Inquisitor's Eye that periodically blasts enemies for 254 Shadowflame damage and occasionally dealing 290 Shadowflame damage instead. Lasts 1 |4hour:hrs;.
    inquisitors_gaze = {
        id = 386344,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "shadow",

        talent = "inquisitors_gaze",
        startsCombat = false,
        nobuff = "inquisitors_gaze",

        handler = function ()
            applyBuff( "inquisitors_gaze" )
        end,
    },

    -- Talent: Your damaging periodic effects erupt on all targets, causing 1,416 Shadow damage per effect.
    malefic_rapture = {
        id = 324536,
        cast = function () return ( buff.tormented_crescendo.up or buff.calamitous_crescendo.up ) and 0 or 1.5 end,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = function () return ( buff.tormented_crescendo.up or buff.calamitous_crescendo.up ) and 0 or 1 end,
        spendType = "soul_shards",

        startsCombat = true,
        texture = 236296,

        handler = function ()
            if buff.calamitous_crescendo.up then removeBuff( "calamitous_crescendo" ) end
            if buff.tormented_crescendo.up then removeBuff( "tormented_crescendo" ) end

            if talent.malefic_affliction.enabled and active_dot.unstable_affliction > 0 then
                if buff.malefic_affliction.stack == 3 then
                    if debuff.unstable_affliction.up then applyDebuff( "target", "dread_touch" )
                    else active_dot.dread_touch = 1 end
                else addStack( "malefic_affliction", 1 ) end
            end
            if legendary.malefic_wrath.enabled then addStack( "malefic_wrath", nil, 1 ) end
        end,
    },

    -- Talent: Horrifies an enemy target into fleeing, incapacitating for 3 sec and healing you for 20% of maximum health.
    mortal_coil = {
        id = 6789,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "mortal_coil",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "mortal_coil" )
            active_dot.mortal_coil = max( active_dot.mortal_coil, active_dot.bane_of_havoc )
            gain( 0.2 * health.max, "health" )
        end,
    },

    -- Surrounds the caster with a shield that lasts 3 sec, reflecting all harmful spells cast on you.
    nether_ward = {
        id = 212295,
        cast = 0,
        cooldown = 45,
        gcd = "off",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        pvptalent = "nether_ward",
        startsCombat = false,
        toggle = "defensives",

        handler = function ()
            applyBuff( "nether_ward" )
        end,
    },

    -- Talent: Places a phantom singularity above the target, which consumes the life of all enemies within 15 yards, dealing 10,570 damage over 12.2 sec, healing you for 25% of the damage done.
    phantom_singularity = {
        id = 205179,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "phantom_singularity",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "phantom_singularity" )
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
            applyBuff( "ritual_of_summoning" )
        end,
    }, ]]

    -- Talent: Embeds a demon seed in the enemy target that will explode after 9.1 sec, dealing 2,936 Shadow damage to all enemies within 10 yards and applying Corruption to them. The seed will detonate early if the target is hit by other detonations, or takes 1,363 damage from your spells.
    seed_of_corruption = {
        id = 27243,
        cast = 2.5,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "seed_of_corruption",
        startsCombat = true,
        nodebuff = "seed_of_corruption",

        velocity = 30,

        impact = function ()
            applyDebuff( "target", "seed_of_corruption" )
            if active_enemies > 1 and talent.sow_the_seeds.enabled then
                active_dot.seed_of_corruption = min( active_enemies, active_dot.seed_of_corruption + 2 )
            end
        end,
    },

    -- Sends a shadowy bolt at the enemy, causing 2,321 Shadow damage.
    shadow_bolt = {
        id = 686,
        cast = function()
            if buff.nightfall.up then return 0 end
            return 2 * haste
        end,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.015,
        spendType = "mana",

        notalent = "drain_soul",
        startsCombat = true,
        velocity = 20,

        cycle = function () return talent.shadow_embrace.enabled and "shadow_embrace" or nil end,

        handler = function ()
            removeBuff( "nightfall" )
            removeBuff( "malefic_wrath" )
        end,

        impact = function ()
            if talent.shadow_embrace.enabled and debuff.shadow_embrace.stack < 3 then applyDebuff( "target", "shadow_embrace", nil, debuff.shadow_embrace.stack + 1 ) end
        end,
    },

    -- Talent: Slows enemies in a 12 yard cone in front of you by 70% for 6 sec.
    shadowflame = {
        id = 384069,
        cast = 0,
        cooldown = 15,
        gcd = "spell",
        school = "shadowflame",

        talent = "shadowflame",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "shadowflame" )
        end,
    },

    -- Talent: Stuns all enemies within 8 yds for 3 sec.
    shadowfury = {
        id = 30283,
        cast = 1.5,
        cooldown = function () return talent.darkfury.enabled and 45 or 60 end,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "shadowfury",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "shadowfury" )
        end,
    },

    -- Talent: Siphons the target's life essence, dealing 5,782 Shadow damage over 15 sec and healing you for 30% of the damage done.
    siphon_life = {
        id = 63106,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "siphon_life",
        startsCombat = false,

        handler = function ()
            applyBuff( "siphon_life" )
        end,
    },

    -- Talent: Wither away all life force of your current target and up to 3 additional targets nearby, causing your primary target to suffer 10,339 Nature damage and secondary targets to suffer 5,169 Nature damage over 8 sec. For the next 8 sec, casting Drain Life will cause you to also Drain Life from any enemy affected by your Soul Rot, and Drain Life will not consume any mana.
    soul_rot = {
        id = function() return talent.soul_rot.enabled and 386997 or 325640 end,
        cast = 1.5,
        cooldown = 60,
        gcd = "spell",
        school = "nature",

        spend = 0.005,
        spendType = "mana",

        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "soul_rot" )
            active_dot.soul_rot = min( 4, active_enemies )
            if legendary.decaying_soul_satchel.enabled then applyBuff( "decaying_soul_satchel", nil, active_dot.soul_rot ) end
            if talent.dark_harvest.enabled then applyBuff( "dark_harvest", nil, active_dot.soul_rot ) end
        end,

        copy = { 386997, 325640 }
    },

    -- Talent: Applies Corruption, Agony, and Unstable Affliction to your target.
    soul_swap = {
        id = 386951,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "soul_swap",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "corruption" )
            applyDebuff( "target", "agony" )
            applyDebuff( "target", "unstable_affliction" )
        end,
    },

    -- Talent: Sacrifice 8% of your Soul Leech to gain a Soul Shard.
    soul_tap = {
        id = 387073,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "soul_tap",
        startsCombat = false,

        usable = function() return buff.soul_leech.v1 > health.max * 0.08, "requires soul_leech" end,

        handler = function ()
            removeBuff( "soul_leech" )
        end,
    },

    -- Talent: Consumes a Soul Shard, unlocking the hidden power of your spells. Demonic Circle: Teleport: Increases your movement speed by 50% and makes you immune to snares and roots for 8 sec. Demonic Gateway: Can be cast instantly. Drain Life: Gain an absorb shield equal to the amount of healing done for 30 sec. This shield cannot exceed 30% of your maximum health. Health Funnel: Restores 140% more health and reduces the damage taken by your pet by 30% for 10 sec. Healthstone: Increases the healing of your Healthstone by 30% and increases your maximum health by 20% for 12 sec.
    soulburn = {
        id = 385899,
        cast = 0,
        cooldown = 6,
        gcd = "off",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "soulburn",
        startsCombat = false,

        handler = function ()
            applyBuff( "soulburn" )
        end,
    },

    -- Stores the soul of the target party or raid member, allowing resurrection upon death. Also castable to resurrect a dead target. Targets resurrect with 60% health and at least 20% mana.
    soulstone = {
        id = 20707,
        cast = 3,
        cooldown = 600,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "soulstone" )
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

        bind = { 119910, 132409, 119898 }
    },

    -- Subjugates the target demon up to level 61, forcing it to do your bidding for 5 min.
    subjugate_demon = {
        id = 1098,
        cast = 3,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        startsCombat = true,

        usable = function () return target.is_demon and target.level < level + 2, "requires demon target" end,
        handler = function ()
            summonPet( "controlled_demon" )
        end,
    },

    -- Talent: Summons a Darkglare from the Twisting Nether that extends the duration of your damage over time effects on all enemies by 8 sec. The Darkglare will serve you for 20 sec, blasting its target for 928 Shadow damage, increased by 10% for every damage over time effect you have active on any target.
    summon_darkglare = {
        id = 205180,
        cast = 0,
        cooldown = 120,
        gcd = "spell",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        talent = "summon_darkglare",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            summonPet( "darkglare", 20 )
            if debuff.agony.up then debuff.agony.expires = debuff.agony.expires + 8 end
            if debuff.corruption.up then debuff.corruption.expires = debuff.corruption.expires + 8 end
            -- if debuff.impending_catastrophe.up then debuff.impending_catastrophe.expires = debuff.impending_catastrophe.expires + 8 end
            if debuff.scouring_tithe.up then debuff.scouring_tithe.expires = debuff.scouring_tithe.expires + 8 end
            if debuff.siphon_life.up then debuff.siphon_life.expires = debuff.siphon_life.expires + 8 end
            if debuff.soul_rot.up then debuff.soul_rot.expires = debuff.soul_rot.expires + 8 end
            if debuff.unstable_affliction.up then debuff.unstable_affliction.expires = debuff.unstable_affliction.expires + 8 end
        end,
    },


    summon_felhunter = {
        id = 691,
        cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.fel_domination.up and 0 or 1 end,
        spendType = "soul_shards",

        essential = true,

        usable = function ()
            if pet.alive then return false, "pet is alive"
            elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
            return true
        end,
        handler = function ()
            removeBuff( "fel_domination" )
            removeBuff( "grimoire_of_sacrifice" )
            summonPet( "felhunter" )
        end,

        copy = 112869,

        bind = function ()
            if settings.default_pet == "summon_felhunter" then return "summon_pet" end
        end,
    },


    summon_imp = {
        id = 688,
        cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.fel_domination.up and 0 or 1 end,
        spendType = "soul_shards",

        essential = true,
        nomounted = true,

        usable = function ()
            if pet.alive then return false, "pet is alive"
            elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
            return true
        end,
        handler = function ()
            removeBuff( "fel_domination" )
            removeBuff( "grimoire_of_sacrifice" )
            summonPet( "imp" )
        end,

        bind = function ()
            if settings.default_pet == "summon_imp" then return "summon_pet" end
        end,
    },


    summon_pet = {
        name = "|T136082:0|t |cff00ccff[Summon Demon]|r",
        bind = function () return settings.default_pet end
    },


    summon_sayaad = {
        id = 366222,
        cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.fel_domination.up and 0 or 1 end,
        spendType = "soul_shards",

        usable = function () return not pet.alive end,
        handler = function ()
            removeBuff( "fel_domination" )
            removeBuff( "grimoire_of_sacrifice" )
            summonPet( "sayaad" )
        end,

        copy = { 365349, "summon_incubus", "summon_succubus" },

        bind = function()
            if settings.default_pet == "summon_sayaad" then return { "summon_incubus", "summon_succubus", "summon_pet" } end
            return { "summon_incubus", "summon_succubus" }
        end,
    },

    -- Talent: Summons a Soulkeeper that consumes all Tormented Souls you've collected, blasting nearby enemies for 829 Chaos damage every 1 sec for each Tormented Soul consumed. You collect Tormented Souls from each target you kill and occasionally escaped souls you previously collected.
    summon_soulkeeper = {
        id = 386256,
        cast = 1,
        cooldown = 0,
        gcd = "spell",
        school = "shadowflame",

        talent = "summon_soulkeeper",
        startsCombat = false,

        handler = function ()
            applyBuff( "summon_soulkeeper" )
        end,
    },


    summon_voidwalker = {
        id = 697,
        cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.fel_domination.up and 0 or 1 end,
        spendType = "soul_shards",

        startsCombat = true,
        essential = true,

        usable = function ()
            if pet.alive then return false, "pet is alive"
            elseif buff.grimoire_of_sacrifice.up then return false, "grimoire_of_sacrifice is up" end
            return true
        end,
        handler = function ()
            removeBuff( "fel_domination" )
            removeBuff( "grimoire_of_sacrifice" )
            summonPet( "voidwalker" )
        end,

        bind = function ()
            if settings.default_pet == "summon_voidwalker" then return "summon_pet" end
        end,
    },

    unending_breath = {
        id = 5697,
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,

        handler = function ()
            applyBuff( "unending_breath" )
        end,
    },

    -- Hardens your skin, reducing all damage you take by 25% and granting immunity to interrupt, silence, and pushback effects for 8 sec.
    unending_resolve = {
        id = 104773,
        cast = 0,
        cooldown = function() return 180 - 45 * talent.dark_accord.rank end,
        gcd = "off",
        school = "shadow",

        spend = 0.02,
        spendType = "mana",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "unending_resolve" )
        end,
    },

    -- Talent: Afflicts one target with 18,624 Shadow damage over 21 sec. If dispelled, deals 32,416 damage to the dispeller and silences them for 4 sec. Generates 1 Soul Shard if the target dies while afflicted.
    unstable_affliction = {
        id = function () return pvptalent.rampant_afflictions.enabled and 342938 or 316099 end,
        cast = 1.5,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "unstable_affliction",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "unstable_affliction" )
            removeBuff( "malefic_affliction" )

            if azerite.cascading_calamity.enabled and debuff.unstable_affliction.up then
                applyBuff( "cascading_calamity" )
            end

            if azerite.dreadful_calling.enabled then
                gainChargeTime( "summon_darkglare", 1 )
            end
        end,

        copy = { 342938, 316099 },
    },

    -- Talent: Unleashes a vile explosion at the target location, dealing 8,331 Shadow damage over 10 sec to 8 enemies within 10 yds and applies Agony and Curse of Exhaustion to them.
    vile_taint = {
        id = 278350,
        cast = 1.5,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "vile_taint",
        startsCombat = true,

        -- Azerite
        cascading_calamity = {
            id = 275378,
            duration = 15,
            max_stack = 1
        }
    }
} )

spec:RegisterSetting( "manage_ds_ticks", false, {
    name = "Model |T136163:0|t Drain Soul Ticks",
    desc = "If checked, the addon will expend |cFFFF0000more CPU|r determining when to break |T136163:0|t Drain Soul channels in favor of " ..
        "other spells.  This is generally not worth it, but is technically more accurate.",
    type = "toggle",
    width = "full"
} )

spec:RegisterSetting( "agony_macro", nil, {
    name = "|T136139:0|t Agony Macro",
    desc = "Using a macro makes it easier to apply your DOT effects to other targets without switching targets.",
    type = "input",
    width = "full",
    multiline = true,
    get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.agony.name end,
    set = function () end,
} )

spec:RegisterSetting( "corruption_macro", nil, {
    name = "|T136118:0|t Corruption Macro",
    desc = "Using a macro makes it easier to apply your DOT effects to other targets without switching targets.",
    type = "input",
    width = "full",
    multiline = true,
    get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.corruption.name end,
    set = function () end,
} )

spec:RegisterSetting( "sl_macro", nil, {
    name = "|T136188:0|t Siphon Life Macro",
    desc = "Using a macro makes it easier to apply your DOT effects to other targets without switching targets.",
    type = "input",
    width = "full",
    multiline = true,
    get = function () return "#showtooltip\n/use [@mouseover,harm,nodead][] " .. class.abilities.siphon_life.name end,
    set = function () end,
} )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,

    nameplates = false,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 6,

    potion = "spectral_intellect",

    package = "Affliction",
} )


spec:RegisterPack( "Affliction", 20221113.1, [[Hekili:D3ZIYTXns(TOARIwkwMw8HCC2ZsvfhNuX5YJTS8MCvD1jYHdbfN1dNHzEizTLp(TFD3aZm45myOO869QkLJnhGgnA0OFdGRhD97V(QLbfSR)1XNnE8OrJMmC03C(lp78RVQ4(TSRVABq4hcUb(ljbBG)8BxTkokSiknb)09XPblrqKNwMfcFEDrX28)6ZF(nrfRlxmmmDZZZJ2ughG9imlyvb(VdF(1xTOmkU4TjxVW(4pbG5wwi8ZVaqL1rlxY4TLLhE9vWyNLUkkggXaczYhUnJbJ2IGIlwXINTmDtucnONgT6IIOnSlpBWrBzfddIJULn4OfLRwn8MSOnPrzSzPRMLheMfTkkKnSC7UFYaQp9INNxUztAYmai2)EzoBwubBZPiL6II0neCHUKxKLwMplK(BL8E6diYtJzbRZNLZcZyfZkyHRtI(ZsM9(ADYqZ(GywsHJjlljyrmBPDqUkMLVMw1S)9BdYIWUZr3LPf5ZYyblV)0BdIlzxGD5wgSwuamczzLBriaRds)EWnPj3R(tLavcb6SGAwnObhFKyAKhTDnSkehTQg5)0NK6U03V8StgCm(BBxhKaRhZYJsUb4fZIkUFyru4hG)5N(ufGT1iXaCIdgcgBjsnBMCNghLWMfU8IrNHuEGdooEwrq2nSI8HMnFwqk7YlMyh6RdktCq3HDBXZYVlWbJQfkiInhjMY7(PD)0F5VSB(3)rwyzbS2pNDll7(DZXTjWFUg(daSPz7MhLd)1BdIIrWnSE0etS40Wpu)BW4UKDligy2MGBIcL)9WaOX8)jSUKxWzxG5(PW(ba)UyeIEI1qwcBtel)YjYqydSebSRZYc2wuMrC10gyaYbBIkODxzGKbwYYuA)lm9(oyu3npNTnidKVqtjaA7MJyWU5RWP3VcBSsJtZasWV8hWSf(6vVFi01YSmGLigOjPj0FclxBI(NiTI6iSpD387azC7M)3UAOmMMvMyovtWXz2M7uMVHP3cSxaJxsfwma6mdG)nSHvt47aCF9avsZfJg4MLLM6FR0unxGYWiN8bq018fS1b3gLMbZZRkcWVhKbZM8GBRNElqSa(TRa(SDZFxAXZF7MTaTfzEa6ArakrB7A2Z)BCeaAzdgCkqUaEOS7IqIeIgHPPXltVlzy3mfcSCw(24OIzHRzQCy270swCW9WElrNZ7UhW(JI6MRSQqYlO9xzWFPwib(Rrv0GzHnKasMJsZAryZjd47CxhKT8Yj8MFlOfdereLibMkrDP3ndOKZqbhEmPwga78yntlfESOBwxmBvadeKwj1EOcX(tFQEzQE6NX2aiw(LJp7tF6yJULMWg4SpVs0QHJgw3gXNoXgWkUl1dGn2eyNGiUywc)VI13N5ZC06IzFMWTcGh0S3piBNuCSPufj6ZhUhg3ePFibMsN4d5YgtDpiwT09hePYh4ANq5HwFFOlcBcxgK9HBGE3loix99brr6eO2ihKsJxxMbYQZjr(KekqZq0kqJak6qykq8Muu5jW(K1L65088buxNvHbmU9gZqZm(QgbHdCy03WAZvaK7TRq1iCU2DZHEyv1dhlbTOjWVDQqn9BQifGoWuWwNpwa7UeM5eYv0JMju4JawbKMbwBTL0wyi6XlffESCn2TLR1SyTYfRjnOw(Vn9BF2WN9s8uhkvD(9AuNZF)o2kWeX1e3dWLWcYql7qo8BsjdBavWa)rGG7h(F1M8aqpN5b)rAHfoJgs)rDq7116nvzjSId7OEYI1U6KP79YI7LAok22sMxcWNYx3U6(KqWmBRB35MG)7CkZZ)vUKQFiGPjSq1K0st7sj5lF)MT3dUVcI)(TSLqFdHMHEzWLQeLeIXuafRSg6gaMKIiOTrfpbL5GU9UB(XJEjklb80hLEc(nZ4olCImZJL5SdB1O4wCElCiJgCCLCDMa7NLkqEd58VA0lWTOS)SmA7w2sZE0lSSIDuhhBND7GJW)ffV448d)cxD0U5)b69eSohqUbTTIfkxrJb5NusT)CVHfgTjOG23)604I(qt62toDQ1Y6rB2cyWQN5tEeOt)gUfOzNbqrogyQJl5Y4Gn1pdDcMOMNWjAO3TQBv8GACC7coSAJ6GJCqWo5KdnHOt83ILlJErTriUn7qiB70krcIOPKwjWHt93e8pqpSjDqDQqPIqP4HAxYwTO5X0fjfcbfeUtdVpK8eLcwvZqrFSrMSC)erOcLrNENWIQRiFvjEMjWpXHgxnBezfzYtkQT7kwS)dm5JKCJugSNeK49fKn)h0(YRO46TB(phTIvrIdIZtXOvuqYzRj1ioimsfO3jLaTfgOGTBJVNy1be77QJbxUsujSespZqtnEGnh0fQ3naq9cZrrjZeZ09FeBIUzpgVbQHG1(QztGiODXsrQyuDawRXNt62KXlhnwg8ockPaWo8b4cWlkzZ8S5MG1jJeDYfJTCGKTcJESN8itrA8aXH8CYCBYmK4)A0ZgxVl50MnatQ0g9TlYtJlXWxkbdzCSHRXY0uDv7vtF2X2yCBI3udf5exSmJ5ZlULn0(0uqFpl7uH9YYgqF3AgmxcGn2NZNw1kMFh3rr(E2GBtJe7xdHnP4w029TuI1CkxJ64reA9h0aMKIo0bwnsB2TlWghxtZgHjXve3SIxJOSlkwYChhOFdfMejL2KhKpJT410bWFsWWuhUc2142l3efdZE5krxWvep)IW1pJwiWuKHY6dUHjIyDqY9fRf2XuqSIHrRIOCBeNZagXmp8FJalLAKAFfVADWsu323Vzrwa5qGi04nohwfReRm4DoM5YPOlNgTzm(G1ehQLmkBhAFgefg(HxD84NXbA1Nj7iRf9dRj27DTLMCQ7FhvCAU)KVfw2Ofo)F5wH0kCZrbrEbjw4AZcK4eDtcMErY)lUDqcVLijgjSpwyFJPWtSsOTr)tI6QAlFTZxnczWDYzvlxe4jF2AxcYXUI8UxB34ntF3bghvhwX(PprRak)My5BYN(KSM2wxmWPkUOH4SyUUPQr3XD1H7VQGyxXzMq2dvKYxCUbfxhuuNShPLKfLzOr)3fLqm9hp(mjVzrBC3q8(fWkh8byOIcJOWNHWUcUK2l(qFshldU8sYPdVxo(SbwiLsQV)liHRIeP7iiQkIeGG8K5YZFjFiXF7)KKtjffH9BE4JWWt6Ec5GDaf4yx7g5W7Pi3Xh4IOQzFWS8PV7Hyenjw4o7YCQ)rDraArrs3jG3NGbD54ZHnrONz4s3SI0zlJyVYNEEO2w6Z8xlHDWs3BYigrHtl5v5tgwaEd6A9n0x5M692e2TrK1Tyqi2qHQkHfq(W8rXQuUqaPCm5xKwk2bsMFTmvOdeGqUSEkIpNdf5zZsed5gkxLv9OAmz2scr4eLlNEMGIz2GYTdS43CpmN2l)rfY5jA0H01chWTdNiC0R2njxQtdEaMNlpGnvPtLXXlab4dVnfR6ky8bpiqlnpfKkYiuBw1cTEtKl9PAwdeGw6REKRW9HsvPJvlzCzlcN96IjdA1uLlNOmTLm3bROfXhggKYUWADri1GNAuDn8F0xt4FeY6dyM7dodlY2vV)575WGj(O67WNPh9fu7bxXA0BaJvP)MFG4OhyeGmDV2uwIabCknus(g1MxnLJa8i2vN909eAxEXuz5Id6eYpksHBb2wMdvv42GT3UvSaLfSzlWWi1X8A)QAh1E1eDSqnczY2h4NGe)dDKpqZNilCCNPLb2T7PxpD6M(dwQbyQ2Ej2OZqrEGYETfPRhBZvLAAQPlIFwqv)4F4r7WNw6S(66G)uPC08RtUlmVoDJOfsI(yBXcE7beWZoAOF1Q6bpawv)AWep6KC4qn0E1UjSssaLA5RalXKf9FK23DrD6HuVUf61d)sU48Zeoh627evhto3PJmvMIEUvdN0rYhhtVvOaFrA(Df3LDtWRwCVWQofz(CRbmOBzKJoZNsW7CVA1ymB8jllJAShdW3ygtkhP1Ziyo7Co1rW0Br2L1XrBbMVPPRjZ51XkM8VP(3N2iEK(G9Pwf3(byf6CFi9polqYZId8AsEyAzgo6fry0uKy51u2DH(b5bqjmM4fs1nPEFEQ(X)zjAjXk8e7CllpNf7FpVj((TRrFqcYZJ2eXp9v(39YKW1aPh04dRelJcksZYrfmHFae35pyylGwHZ8BJcz(3nqTtksVbH15SSBtJ6bjlilCn8VclYNbltSeGP5E0rSEm84XKAglmoABEp6vrkB2hsySCWy8uk2DE31nzzWygKd2tEBApMRHP5BadbKwI4uo8G7OWzk7MWf2SSqTjWaTnvNHrRbix5I400LT0g67ZwvMDFBnILblYQB4mAupSROvVPmaSUmhf6MMrVx4Mnr13RgNdCx3EVWALD2PZA26S)(j5EUzU1vVWP6)uC8zpK5OwVFuMK5LjCEu4Fa4wEr)NKFPVoIiCmRG0yMvU4((pdF5dzg(YpdZqYeumIBzlqnEG0VnSK9yP0EXw75eD6EprLMQIQh)cEi6ISv(DVS7aiCPrVmhcnhdJCxqu(oGw6R1H1rqcDecUEJgTadROJAqDnIjB)gCZUkV8ISS16qu(s1Pd9clhN6QIkLFGQTpkxoEGXAU43AHEaTW2zQwe4kZLZlfhJI3xfpN5bXGjTnhdwr601QyMt3n)nVw8PFK8jXCI)u9tsE1jBI29lM7(KRxEtNHL8tt7DuI1NMU9ICwr0QtrVlIqmYEz44kCfTCKPOuTkYrBtvXuxWqPPj2Pc2YSSu6UFihGQVJkNBEwVuRzMQkAAfyLvk45OvmJ6y1EefFlF14NkJx0G9JWuF38NTB(2SOuEjjGLwE9qI0OMetNIfF)nXPlWJEXDW0AjwbdL8JQHOQxOCzlk3WTPzfLjrvLXxnu)L)Oxu1l)62Q8IBcxcF5JMZTFicjwc9s7MxhEtQqMbwKOWOTC)TMNUY84eyhf9W6lJJ9hHcGHsEaqRw64aGVWh4zXSchG7L(ao36WDa1P11JpXtSfxmexxbIswHK1CkUlexUmogdy)Wcppf45VR(OF8ARiRJZjGC8uguJNYsTTcnlX1rbs(iN7YZ6C(F13xp5r5VUN8uRRLH3pmwvqzpicTts1aBxsYV0XwG9Zud78)Tyt2uRDWt7RS3zVmlzQ6PAefWgyuw2CzTQo(2Uq2avz1hmbQJ)kNIu53uh6izuRN2gPtqsBmAEL60EKMjE94rLNkJQ646d2dM5kf1b(CyH6boV3zgJFaDSxJF4Y(erL8wRhLxZV3WLVVBojG84OLm(Pwa0JWlQqEDxJCrXHWqsfuAs5Mf0zbybwtAthEoD0irgaQlrvkXHbQmUGRHSGLxije69J)6t6jx3XTvgFTvDLdpNBt73UKBaiAaYV8oHTj5vuc2hlYcAmWJQ)56lfhKjaRY8ioxqNR4cITSfI4x52c5T9lDxuL7rzs2JIHuJMjQYr(1fd)GdYjDOE3Uy3LtZLFmZ)mYrQyD5sSGh1yGLYGPD6ATmDRfEs3As6QBQsX7Q1Akmm9mtT(yqlrBUDU0kn8FxKCrCjHNDrRdPVzVmeTbn2zQlNTUCtqsA0YQBEjy95znRncFoeyFVDVycxKBsDkqJODDVb4Scb(Kewmxw7DmCOULj2BHg9qyRh8CwtOQC(yD2t7gS0XbUO10W(QjF5LSxht)VGrthjMoNDHwDFM)LEI2ZBjp7kMeOLFcSQtaZ)ZlaPO3ef7OtMUIfgKLJ(GTcpkhzG09zOPgRy(caa)dZk5Il)ZsqoE5gWNn1ma2jeOBjrmJwlJUfVq9wWI9EgKEllBf3VMzbjWs3Sq8yI5zVrld3KIH4Jf(HzBll43QC(J9BccdwagwMVMbERUb8gl03UUkoGFLrUiOOi27r8UGpGw6NdlzPjl9Tx0kuboAlz5BdKtYA7DukFJlcw6pLnfweJY)a5FpWBsN5tp7660SeSF3geN6nEIRI4DihOikFJVDcSidSWAnlyzfEMeCt8QGwgvBP5uVnwsxQbyKsek)SSIrzkLoT85LumV2nF3)lyUjyo1)1V9oE8M(5Ya8G3ck)F7tqvFHPja7pzkEX6iHFDObuR3WalOKugwfpfPlApT4ptNHsy)F1TPGioShF8OVQLlyHNk)z3cduBNE8K0(QE0Ro5Klg16m5PUcOCAcRAAi(PHJa7nOS2hoq9NQSA(K9BOkUlvFOgBouJFidLAfcunAh1JPgM2QJ6b(bTVEzPJImXNjGsBQWFRxAAnHwszo78(qRL2p6RSncelx9h059bgo79egRo751xb7jZbIsZDC81xDxqg6tC(1x9E0C1On8D4Kt1pXcT7jOf0amZW925P4rQnOeCsI73nAj8nm8QS4NPRYMX)v8cdOwwWtm5iEcx2q9xku(0XJ(4jEcSkEdhau6ZkaDIdGo2ngo2jg2oWCIHgFwbOtpK0W2b2EsdDb09Ig2oW6nnC3pzHVwRKM6hp938xr3af6cXguP6Ex9v77)nIDAfI1)Z)bgDLc8(nEzuozEEnihDMxWuTcTSdqRZxfL89B2oASxOMfRQADcFUxq1Pzq9yUxLY0EoT15cDwaN1CIoBrL3y6C66JHJQlTAaC8zxq3qA5JWmWqENucK0GkpykoGJXE(hbCvFmoSu7ZFuNb2fIXwfug3t(AD80XjsVcjD85)1qf4JXlTpgkNWfnOR8nxW9BCQzSoS1I4Iyr7OLM8ic8obR5DRRf9L7loVFaVtWUFKcpX59d4Dc29Ju4joVFaVtWUFKcpX59d4Dc29Ju4joVFaVtWUFKcpX59d4Dc29Ju4joVFaVXAPplMK9zzq(CyA2ix(I29Tx6tQnbs87MDXC1XLBBpsd3JRDmgG)rE28Ih3zJo4FCNnJDSh6bBH2yh7BKYnToynFJMma6x)yHTUa8dcBneU(ii64ZYGmrFX8WYZprx83bg86I7oWG)ZHJugdYbEoyi15aTXAQlXapAa(HSJDQoJOZYBPc2oBGNXfiifrZEetahrX5WYS9zymCefPhmFHJnJpy4(5XoW))ZG4qGYHDqEScV0ihkvBoh0Aqv6sGXLEADg(hDrlvv2u)KV4YEWhIyvxIQvkKjDWATgPmwOoZoO7DqTD5lz)b0J4K1HC5daOFCS)vF75HKLxOPYf76dHKS7NE7MQmDnAYoL3auCJY1xr)n6fmwoxDWp8R0tJSaIx)6Q3)yT6QR69h28dfx)RJTcbNLyxdSC3eaQtSc1iNLAtdyBPnaCN6cU2QgpfGATbaep3keTxGEna0X3b49cRWZzj71as3nbG6xBfQwQJVg4z7JaKEPviPvwFnqr)dae(gRqqTc)AaG2Vd9F0z2zAX)TCX(jX2A8jem2591l9VgOy8feikS)lQx(nZyn1A7S1kL(xZ4P(Zy3TZ9QueGsRFk)m29ZTIRoZdo1hIDScKnLbOmAGn7RLBwDLaQ3QxQaS6IbuTzfW6fxcLCPbztyv6wqkcRObKvfOe(3IlH)3XGqsqO4U5F1U5URNVDZpz38NARPUfM4Up615xlTuVM)OMc)3fqt5Vc8zrB5tnBvkjnHNje4Qvsw2en7f9skg)vvrZU5dm(9QG2b4RmAuTYLMyvmE)WGXoWGX(Gbf3LAtGVxyWr0Qv)Pe0)9Ppr9wdgEpxQHr71GO8uwTIJSPuYRzTTkgKqwh1zO8S1wnd6BF57kSp6ABDCwbI1BB6cQeE1BOAJbJeoXLxPvYxUnSs(ostYsi5F1Pjv63uAsA(1)ItdOCWk1OHZ2NDA2uRxHAnqT9M50ekLBwTgOP(ZonyY8cwRbew(MttKCEzR1ao3nXP5sYxSwsKF5Fv3qPA91gf)NPnr1TvTO(AXQNwUN1AWV2AeFFG2fzKTncwNSxbk6aM)OasqK5vAejkPopr6xRr7M)QDZFHSif9R4i1(361CulaJIqb)9tb)K21EK2pMWLFzDf3YE8A2BDJtoe0g8jU5WrCCaThc1XCwBrewT4sDZMoeKOVWzFmNZwKklRpr2c0db95Lhs6JDG9GOp6tzlQvQjp2VjwoeuPPhsQKDG9GOsoM5cJyKVViQfDxBXyDiJ18QBSCR4xQMATyIpoho1lhnp3hpinmjOzH9iBusmUy4nnboJBu2PDbvWJI2Sk1LCyuB3qJSj17ondxBR7PfvJkOz3PxG4NowML0Xf3gXnn6SkEJoB9L7MFEVA94Zf82TwwZeJyfHYk7VnfJnefpPiDC5k4bkOR4Pbf8JCCE1kJTRPAQft5u3MLzLy0RqO0oA22K7)OY3CEFyeE0zBQK6At((JhNI8OQeqm17kBJn7vxcJTVz38USuOJCGVesdii5Cc(ZTVVY1vB5(GfwGJe1Q5JTVnRRB5Y9bZAbEYUQA0O23W54kXCFqqtWi75v13QC0IoEggkPZ3YaTwXPHFOnL0lz3cSTZ2eCdgVFtv1wNPyNBEh3iSEs)vCgKAnnmnddjWearWMOI0Y8zH8SySmDy52MXq72cYM0aLONYV8TYzBd4pENC4WtrMi)ZspoM4vdgDv)8(H7M)Dn3bx8N1WuaMBI(NOmeQJ01lw1Dl3WgCmRmrLmirRK1OyAxhW20r9qrTrFfHh(Rb(OcqznPkX72SCsHk(TsuT8Qhw0Q45TGTo42O0SH09Wv9BOl(wCwrPQUeo5xHsVlT45VDt9fK531Od(52UGPovCjKDh9MrkFv)n0tEpBzvWsCF8cwgr6WsOEuCNGeoMQ9qRq6kXV057svttBrHf5VWa(D1k)ESIVnTPZwE8FOV1wXM0)n5QzzwpqwV2o7VIxw84NBe8wALt3cdd)WUKhIcHJtoJQD7EYjfKF96w2R4E7j0npucYPaWQhK9G20HpM9Lq1TlRhmQwpgQ2jHpuxN7lj322Z9MG3kWoKKBVhO2j29Y9dFPOT7crFiNT6NZbJw63O4Iq6Piw9mozKcGx72yjvL6UUEVLF9LJ3KI2jbBnYuSvlfVlvhiA7m55PY1FkMJnzDsdCBrELRx2YuHcAJxlWv7vjWz1Obo(dgtHxdjNkSv7n1VekuzwX(yb9Mst3OEIBCv0wXI2wkShQqzX0EQw3BoNX1bvWHrakBl61(rhslv0iB3(LV4W(dI4(onZQL2OnPprBxRsiwl0RFiDM8679yy0aqYcYqhqWDN3KsicyixQ8lDFZ9npGBYPw0xoy1f9J8ADF)ce(r71wKUTly6bNDWhMWMjuxmoERZDQb3tv0KkSujzvl0wGQgt1v3Ne66o8L7g7VZxME(VYvb8di3GISwvFXknCiJFRT)9IK6TB(VvxOvO79CHYrjHPB4sLxNIxu3Ljfr41CAXtqr247llS(n6LOOymcH51383W4DIh(qWv9uho225xhvjFQUzopmI82)IgHuTwyz0IL7WDyDRHlmVBM)hVPrRmyf6fxyVyiLI8cN)t)c8gVSLZjrACw2Cff8uajsQJbJ(BrXbkylUwtCCD9tu3jpARgfvvM5ErW)Tc6A8UIAad(XWUX4sUMdq03ZWiGrllNStCvxR)4s4sbslstBXDmU4ZoxhorYHShfAQESG8YwxyLOZDh6XgYWwwFUt15Ig5CIOEFUGx(I5MG)bgIn0qH206BngK(O2YHrc2JsXjotw6i9qbvHQ88u0zwrMcnr(fEgNjy4Tpto(2uY00daUR6qcJ1fMlCPqSRPVeVi2jNdUIEGRPTbtqZcimGBpwe5QevEUspAdOSjW1gslkU6G9KGeVVGEY)GKzDfLyKDZ)z8oiwSmheJ34PlyfKoV6LBeh4EIHR5jL83RGGTBJVNwQMGNVKQzs(WoIG)yzdCSg9pf7anivkSihHt4z85lrYDNYPorfZtRZEIi1gR7ilntBLtaNfUtjYXgHAvu(P2NEN4R)siGg3GxsvEbIpUnMqmSo8TMsqGiCj6EY0vY2M2zkYg7SABKs6NNjD01M8pRL1XyN5fqsqHbA2cpo3K(NrIsBFhhTc1YgHt6IPESEIBqXdYcgKLDG)RrpBCTaTtBKvnPYOQVDrEACjM5SVtDZHUEn)I503A8e(CQW3vzNz5VWf4doZ5C0P2UW3XHkxSyaDlBtIedb5GryI7Bwf02Gov1yUXCglDLsQN8ccnsWhFJCW1jABJDT1i2y67em1UI2QRe5juPb)fbkToxzOu8i2Y(71UMF1E6W6E4(TfzwKFADg(O(Hv9oqtAiXbXT)UhVoITZe9aYQLs6IW1pJybIORM0YC8k8x8IdLCFXAH14f0wJWOvrifcF2hHngzTgBhj0cHnHmUR)KwpMPvg)1YB9ajY5ysf3ZQsT(qPxZHHskJfRrT(0qu57KVXcNxq1tCvr1Tlk6VJgvzkyHl7rYOAXw0YTcXJIxatQT1p(L54H4aaefNeUqgrunirDjSpwyx2HiIjL0BUfTUR6dCDqsAKoIcBQFmGiWJK0RnZ6SRC(652)QMAUNuo3yD66gcgxV9svl4yBmnOI8mBIR4DTxRUiTdz14pKqeXBtvJUJhZbEGQeREv5fjHm(UiLVAFdQ4IFReSQ(5UIVgVOmJEFOIswspSyyAQQdJf6u3gQqikwJsGYHHkkmIv9OLwbxIMWhAL4D1jTEqRr7sK1Sbwxpunddj8UkY82j8)sn1vpyoO(CsQhU)ixM0jfhi83(pfcORnkRNKG(Oe4e)PhUSZDVyerJcSBlbfZRtr(s(MT8Ag3C69FsvqqU9x(ouiL4PYmQWIi)U0f3s(AuKp4xmTfv8jjjOkAksVGBen2pi9zvYJBVoAVQzCXyGW0LVf8hPjUVsk8pIhForacYRQfnGl4nyK5UH(k3w93MWUnICrddg6gke9jSakEbFuWQKlu4iNK3fPLcbqKD4ltfgFWFXmBYSeTxLdLR1lCVO6XE2sAORiZOP3NjTwy2WYT89GUJZgF)Nlpo82XUjEhckP3Io7EKov3cVhQV4kJyhECp1zeTS7XD3ZgxwqP4XRn4r4(JO)UoWxx2e08K)P7jyRxwl418rr9dJMGJ2OXLKT9tj1IwA))sEj10fGGtvT4Fov5KZizDUA7G)j4(sy6MfbDCevQ9H(Skh82YkggehDBThFesJh8Xu8SjNUAwEa0FqwitPyExXIH9jBIsQpUXkvRSW9RTm9q6A)iodknOXc6dAplwcXPIBVfaCsbhVRgw46ypdCcSG15axCygwaqSW1jr)zP0owNTOWJtTGDcMHAfRndhaLdOG8wbfINUgOUVHaKKOfkfiPAoaPVtssT)jRcdRB4XYrkWQSaPWRQfcXkWCsVmDXZatOCftG(doJccasjDPqYwIfKKgrvQVqGMLaAplifNrxqvzpMFZzHWI)OZWr8BKxHTLSJrkPdHByZDbB1Bv7N)m9dbJD1qihtk7A9dIG1KqQm6J7As02PWYsCV80DwFcSt7SppOkvsnAtp8kS6Zb(2hhPCgnTo3m2sB0cTTxw8zgoo35nPZ8FfgKq)ARBUBv2(rDzd0GdxYTSycPD01vfeyyiSPO9xvfkDbsZZuBTmdBMR5YNhpgnum4uDdKRN8Em2UpAgDPA6HBNUl3nS1CRIGPrC7TBfmqzbB2c7rK6MkBuxZOxrQuSrLmQGyvJNLDowYobLSt2UoLdDo6mQEsLGFAvnHCLJ4QEQiHQ9iePEMVGhrX0128CqKv7rkQ)mwsVouxES9GCQS25kM1Frmb9KF3snd7YVxVseKrXi6vVTDE3CwYF9(Kl4oeBDA2G3e9(lPX4yS1s5HH4PzIwAgilbb0OMWuHMvtb7WmI2hp3NcVgWAEXq3kmh7TgJPTdNEglljDCkEa(QlQQ6sDdfQmUsYNYwTyOLIx6qRfRLkmQJGQErZnUqDCtBp8QMrv98wJkR0in5CNUP0mPLcGDHLAvQQzFgIqhVGK(3Oi0nw9MLOLi0rIY194U6non3O55MUNBTcj)3m61eFjx1NV996kK1W9kfD(kUGy)BTwBDxkzMHhr(sxeMgCmJsv1g0cN3gSrR6s2MsIOEVqFiMe3OBsAU5dezY9kAHap8h0s6P7M)Mxl(0ps3Xn2UknjRlCUgmdR5LRVQRsUVEfZNCiETLam5s)KFNxskTyI8P1urivjnlpnnrPyC1t85b4at6syRyZUw1hH1Na9LDQLss1L0Wkq9vkSfv3UeTlZiUDYpvDcCTLyH4h19hbciL0OTzrPzuMWXZIqn2Hu6Murs(SCtC6c8qgDhqWwIXQPKFOK4ZlE2lfvAiETjxMuxRE1q9x(dJ1gAl1x3Or1DzbCt4YHuMvTqeA9604hIq6SWY6Dvhn4CEzJdCUrHrBPuIaO(kZd2Yq3xEIsZfJZRmnE81TZAwvSEbm6kInTEbm2Ya(IwVndDgh9u33MHTmyVSTRgqxXKjV7RgWwgYPDFp75(uA39X25Tvsz2ICmz802lkVds26POaiKNs)W6q9lbfdd7PVR(KszliOAxezdKVbN1uO0sSECcmFKnZtKJKfaM3aAgb(XvB9NcE13xt(qnwUjFuRR06zzsB3IOoiLUDbOBO2LIrD6PRZOu73YvDDebKoeuoceQr8cuhaRh2NkqwFnM1rScA5ifyZLYUDQV7JnIAm1n8Q3p9EVRrvu95CvQ845k(udfu7A8cuuCU)A3gtgJ0MooJ4ky5M3shZJA9eVjDcQmCW8WCK26icBgH1qTw(OQ0LrvPD95VddwKIoCFotFpQtlJWx5milTZAEL9Alez1Mikg6AdP4Ln9nCTT7MtkBooAjJFstav(8izXRXDKZnoeMcuj0MuUzbDoqwGLH20HNNJWfzePUevzfhmqLXfCtIky5fsIJF)4V(Kw40p2V6aSRQaD45Ikd0ier(rp)2LlJW)gAZ6V8oH5S5v0o2hlYcA8SGFUqUnikghfKLdivSiopxN8xILhzxtWVYnFwXKxFlxIhy9A6d93rDyAeLmBbiWjHwu)K8BEo(jAMtVrtLu2r6)MT2cWLiPMk4ZpJ7guCTzjwFLABEKcCPYkKCkhlSCE7S3YU0j3YzQZky0oBKU1D2Xb50EwQv1m78WLjh9qpci4S1LBcssJwsvDwdk6r4gv9xREy3PDcc(Dbaqgmoei83Lxg2CihyoEwdJHWXCbvYdFWNqb0WLVfo3I83tQPFrK8L3aBhWNyXewmxh2DmeBWA6JKIGMgte5R1JsTUXN8OWACSJSHs9XyxVo5quOY64aln5lOGDwuD8L(IbJSUo1SmwuDICuDC2A8xXGRwwSgFirUkAZ3r)Y1)F]] )