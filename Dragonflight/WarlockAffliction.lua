-- WarlockAffliction.lua
-- November 2022

if UnitClassBase( "player" ) ~= "WARLOCK" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local FindUnitDebuffByID = ns.FindUnitDebuffByID
local UnitTokenFromGUID = _G.UnitTokenFromGUID

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

spec:RegisterTalents( {
    -- Warlock Talents
    abyss_walker                   = { 71954, 389609, 1 }, -- Using Demonic Circle: Teleport or your Demonic Gateway reduces all damage you take by $389614s1% for $389614d.
    accrued_vitality               = { 71953, 386613, 2 }, -- Drain Life heals for $s1% of the amount drained over $386614d.
    amplify_curse                  = { 71934, 328774, 1 }, -- Your next Curse of Exhaustion, Curse of Tongues or Curse of Weakness cast within $d is amplified.; $@spellname334275; Reduces the target's movement speed by an additional $s3%.; $@spellname1714; Increases casting time by an additional $<cast>%.; $@spellname702; Enemy is unable to critically strike.
    banish                         = { 71944, 710   , 1 }, -- Banishes an enemy Demon, Aberration$?s386651[, Undead][], or Elemental, preventing any action for $d. Limit 1. Casting Banish again on the target will cancel the effect.
    burning_rush                   = { 71949, 111400, 1 }, -- Increases your movement speed by $s1%, but also damages you for $s2% of your maximum health every $t2 sec. Movement impairing effects may not reduce you below $s3% of normal movement speed. Lasts $d.
    curses_of_enfeeblement         = { 71951, 386105, 1 }, -- [1714] Forces the target to speak in Demonic, increasing the casting time of all spells by $s1% for $d.$?s103112[; Soulburn: Your Curse of Tongues will affect all enemies in a $104224A yard radius around your target.][]; Curses: A warlock can only have one Curse active per target.
    dark_accord                    = { 71956, 386659, 1 }, -- Reduces the cooldown of Unending Resolve by ${$s1/-1000} sec.
    dark_pact                      = { 71936, 108416, 1 }, -- Sacrifices $s2% of your current health to shield you for $s3% of the sacrificed health plus an additional $<points> for $d. Usable while suffering from control impairing effects.
    darkfury                       = { 71941, 264874, 1 }, -- Reduces the cooldown of Shadowfury by ${$s1/-1000} sec and increases its radius by $s2 yards.
    demon_skin                     = { 71952, 219272, 2 }, -- Your Soul Leech absorption now passively recharges at a rate of ${$s1/10}.1% of maximum health every $t1 sec, and may now absorb up to $s2% of maximum health.
    demonic_embrace                = { 71930, 288843, 1 }, -- Stamina increased by $s1%.
    demonic_fortitude              = { 71922, 386617, 1 }, -- Increases you and your pets' maximum health by $s1%.
    demonic_gateway                = { 71955, 111771, 1 }, -- Creates a demonic gateway between two locations. Activating the gateway transports the user to the other gateway. Each player can use a Demonic Gateway only once per $<GatewayCooldown> sec.
    demonic_inspiration            = { 71928, 386858, 1 }, -- Increases the attack speed of your primary pet by $s1%. $?a137044[][; Increases Grimoire of Sacrifice damage by $s2%.]
    demonic_resilience             = { 71917, 389590, 2 }, -- Reduces the chance you will be critically struck by $s1%. All damage your primary demon takes is reduced by $s3%.
    fel_armor                      = { 71950, 386124, 2 }, -- When Soul Leech absorbs damage, $s1% of damage taken is absorbed and spread out over $387847d.; Reduces damage taken by ${$s4/10}.1%.
    fel_domination                 = { 71931, 333889, 1 }, -- Your next Imp, Voidwalker, Incubus, Succubus, Felhunter, or Felguard Summon spell is free and has its casting time reduced by $s1%.;
    fel_pact                       = { 71932, 386113, 2 }, -- Reduces the cooldown of Fel Domination by ${$s1/-1000} sec.
    fel_synergy                    = { 71918, 389367, 1 }, -- Soul Leech also heals you for $108446s2% and your pet for $108446s3% of the absorption it grants.
    fiendish_stride                = { 71948, 386110, 2 }, -- Reduces the damage dealt by Burning Rush by ${$abs($s1)}%. Burning Rush increases your movement speed by an additional $s2%.
    frequent_donor                 = { 71937, 386686, 1 }, -- Reduces the cooldown of Dark Pact by ${$s1/-1000} sec.
    grim_feast                     = { 71926, 386689, 1 }, -- Drain Life now channels ${$s1*-1}% faster and restores health ${$s1*-1}% faster.
    grimoire_of_synergy            = { 71924, 171975, 2 }, -- Damage done by you or your demon has a chance to grant the other one $s2% increased damage for $171982d.
    horrify                        = { 71916, 56244 , 1 }, -- Your Fear causes the target to tremble in place instead of fleeing in fear.
    howl_of_terror                 = { 71947, 5484  , 1 }, -- Let loose a terrifying howl, causing $i enemies within $A1 yds to flee in fear, disorienting them for $d. Damage may cancel the effect.
    ichor_of_devils                = { 71937, 386664, 1 }, -- Dark Pact sacrifices only $s3% of your current health for the same shield value.
    inquisitors_gaze               = { 71939, 386344, 1 }, -- Your spells and abilities have a chance to summon an Inquisitor's Eye that deals $388070s1 Shadowflame damage every $388067t1 sec for $388067d.
    lifeblood                      = { 71940, 386646, 2 }, -- When you use a Healthstone, gain $s2% Leech for $386647d.
    mortal_coil                    = { 71947, 6789  , 1 }, -- Horrifies an enemy target into fleeing, incapacitating for $6789d and healing you for $108396m1% of maximum health.
    nightmare                      = { 71916, 386648, 1 }, -- Increases the amount of damage required to break your fear effects by $s1%.
    profane_bargain                = { 71919, 389576, 2 }, -- When your health drops below $s1%, the percentage of damage shared via your Soul Link is increased by an additional $s2%. $?a137044[][; While Grimoire of Sacrifice is active, your Stamina is increased by $s3%.]
    resolute_barrier               = { 71915, 389359, 2 }, -- Attacks received that deal at least $s2% of your health decrease Unending Resolve's cooldown by $s3 sec. Cannot occur more than once every ${$proccooldown-$s1/-1000} sec.;
    sargerei_technique             = { 93179, 405955, 2 }, -- $?c1[Shadow Bolt and Drain Soul damage increased by $s1%.]?c2[Shadow Bolt damage increased by $s1%.][Incinerate damage increased by $s2%.]
    shadowflame                    = { 71941, 384069, 1 }, -- Slows enemies in a $A1 yard cone in front of you by $s1% for $d.
    shadowfury                     = { 71942, 30283 , 1 }, -- Stuns all enemies within $a1 yds for $d.
    socrethars_guile               = { 93178, 405936, 2 }, -- $?c1[Agony damage increased by $s1%.]?c2[Wild Imp damage increased by $s2%.][Immolate damage increased by $s3%.]
    soul_conduit                   = { 71923, 215941, 2 }, -- Every Soul Shard you spend has a $s1% chance to be refunded.
    soul_link                      = { 71925, 108415, 1 }, -- $108446s1% of all damage you take is taken by your demon pet instead. $?a137044[][; While Grimoire of Sacrifice is active, your Stamina is increased by $108446s4%.]
    soulburn                       = { 71957, 385899, 1 }, -- Consumes a Soul Shard, unlocking the hidden power of your spells.; Demonic Circle: Teleport: Increases your movement speed by $387633s1% and makes you immune to snares and roots for $387633d.; Demonic Gateway: Can be cast instantly.; Drain Life: Gain an absorb shield equal to the amount of healing done for $387630d. This shield cannot exceed $387630s1% of your maximum health.; Health Funnel: Restores $387626s1% more health and reduces the damage taken by your pet by ${$abs($387641s1)}% for $387641d.; Healthstone: Increases the healing of your Healthstone by $387626s2% and increases your maximum health by $387636s1% for $387636d.
    strength_of_will               = { 71956, 317138, 1 }, -- Unending Resolve reduces damage taken by an additional $s1%.
    summon_soulkeeper              = { 71939, 386244, 1 }, -- Summons a Soulkeeper that consumes all Tormented Souls you've collected, blasting nearby enemies for $386265s1 Chaos damage per soul consumed over ${$386256d-2} sec. Deals reduced damage beyond 8 targets and only one Soulkeeper can be active at a time.; You collect Tormented Souls from each target you kill and occasionally escaped souls you previously collected.
    sweet_souls                    = { 71927, 386620, 1 }, -- Your Healthstone heals you for an additional $s1% of your maximum health. Any party or raid member using a Healthstone also heals you for that amount.
    teachings_of_the_black_harvest = { 71938, 385881, 1 }, -- Your primary pets gain a bonus effect.; Imp: Successful Singe Magic casts grant the target $386869s1% damage reduction for $386869d.; Voidwalker: Reduces the cooldown of Shadow Bulwark by ${$abs($s2/1000)} sec.; Felhunter: Reduces the cooldown of Devour Magic by ${$abs($s3/1000)} sec.; Sayaad: Reduces the cooldown of Seduction by ${$abs($s4/1000)} sec and causes the target to walk faster towards the demon.$?s137044[; Felguard: Reduces the cooldown of Pursuit by ${$abs($s6/1000)} sec and increases its maximum range by $s7 yards.][]
    teachings_of_the_satyr         = { 71935, 387972, 1 }, -- Reduces the cooldown of Amplify Curse by ${$s1/-1000} sec.
    wrathful_minion                = { 71946, 386864, 1 }, -- Increases the damage done by your primary pet by $s1%. $?a137044[][; Increases Grimoire of Sacrifice damage by $s2%.]

    -- Affliction Talents
    absolute_corruption            = { 72053, 196103, 1 }, -- Corruption is now permanent and deals $s2% increased damage.; Duration reduced to $s1 sec against players.
    agonizing_corruption           = { 72038, 386922, 2 }, -- Seed of Corruption's explosion increases the stack count of Agony by $s1 on all targets hit.
    creeping_death                 = { 72058, 264000, 1 }, -- Your Agony, Corruption, Siphon Life, and Unstable Affliction deal damage $s1% faster.
    dark_harvest                   = { 72057, 387016, 1 }, -- Each target affected by Soul Rot increases your haste and critical strike chance by ${$s1/10}.1% for $387018d.
    dark_virtuosity                = { 72043, 405327, 2 }, -- Shadow Bolt and Drain Soul deal an additional $s1% damage.
    doom_blossom                   = { 71986, 416621, 1 }, -- When Seed of Corruption deals damage to a target suffering from your Unstable Affliction they explode, dealing $416699s1 Shadow damage to all enemies within $416699A1 yards.
    drain_soul                     = { 72045, 388667, 1 }, -- [198590] Drains the target's soul, causing $o1 Shadow damage over $d.; Damage is increased by $s2% against enemies below $s3% health.; Generates 1 Soul Shard if the target dies during this effect.
    dread_touch                    = { 71986, 389775, 1 }, -- Malefic Rapture causes targets suffering from your Unstable Affliction to take $389868s1% additional damage from your damage over time effects for $389868d.
    focused_malignancy             = { 72042, 399668, 2 }, -- Malefic Rapture deals $s1% increased damage to targets suffering from Unstable Affliction.
    grand_warlocks_design          = { 71988, 387084, 1 }, -- Every Soul Shard you spend reduces the cooldown of $?a137043[Summon Darkglare]?a137044[Summon Demonic Tyrant][Summon Infernal] by $?a137043[${$m1/1000}.1]?a137044[${$m2/1000}.1][${$m3/1000}.1] sec.
    grim_reach                     = { 71988, 389992, 1 }, -- When Darkglare deals damage, it deals $s1% of that damage to all enemies affected by your damage over time effects.
    grimoire_of_sacrifice          = { 72054, 108503, 1 }, -- Sacrifices your demon pet for power, gaining its command demon ability, and causing your spells to sometimes also deal $196100s1 additional Shadow damage.; Lasts $196099d or until you summon a demon pet.
    haunt                          = { 72032, 48181 , 1 }, -- A ghostly soul haunts the target, dealing $s1 Shadow damage and increasing your damage dealt to the target by $s2% for $d.; If the target dies, Haunt's cooldown is reset.
    haunted_soul                   = { 71989, 387301, 1 }, -- Your Haunt spell also increases the damage of your damage over time effects to all targets by $s1% while active.
    inevitable_demise              = { 72046, 334319, 2 }, -- Damaging an enemy with Agony increases the damage dealt by your next Drain Life by $s1%. This effect stacks up to $334320u times.
    kindled_malice                 = { 72040, 405330, 2 }, -- Malefic Rapture and Seed of Corruption deal an additional $s1% damage.
    malefic_rapture                = { 72049, 324536, 1 }, -- Your damaging periodic effects from your spells erupt on all targets, causing $<damage> Shadow damage per effect.
    malevolent_visionary           = { 71987, 387273, 2 }, -- Darkglare increases its damage by an additional $s1% for each damage over time effect active. Darkglare lasts an additional ${$s2/1000} sec.
    nightfall                      = { 72047, 108558, 1 }, -- Corruption damage has a chance to cause your next Shadow Bolt or Drain Soul to deal $264571s2% increased damage. ; Shadow Bolt is instant cast and Drain Soul channels $264571s3% faster when affected.
    pandemic_invocation            = { 72052, 386759, 1 }, -- Refreshing Corruption, Agony, Unstable Affliction, or Siphon Life with less than ${$s1/1000} seconds remaining will deal ${$386760s1*(1+$s3/100)} Shadow damage and has a ${$s2/100}.2% chance to grant you a Soul Shard.
    phantom_singularity            = { 72036, 205179, 1 }, -- Places a phantom singularity above the target, which consumes the life of all enemies within $205246A2 yards, dealing ${8*$205246s2} damage over $d, healing you for ${$205246e2*100}% of the damage done.
    sacrolashs_dark_strike         = { 72035, 386986, 2 }, -- Corruption damage is increased by $s1%, and each time it deals damage any of your Curses active on the target are extended by ${$s2/1000}.1 sec.
    seed_of_corruption             = { 72050, 27243 , 1 }, -- Embeds a demon seed in the enemy target that will explode after $d, dealing $27285s1 Shadow damage to all enemies within $27285A1 yards and applying Corruption to them.; The seed will detonate early if the target is hit by other detonations, or takes ${$SPS*$s1/100} damage from your spells.
    seized_vitality                = { 71990, 387250, 2 }, -- Haunt deals $s1% additional damage. When the Haunt spell ends or is dispelled, the soul returns to you, healing for $s2% of the damage it did to the target.
    shadow_embrace                 = { 72044, 32388 , 2 }, -- Shadow Bolt and Drain Soul apply Shadow Embrace, increasing your damage dealt to the target by ${$S2/10}.1% for $32390d. Stacks up to $32390u times.
    siphon_life                    = { 72053, 63106 , 1 }, -- Siphons the target's life essence, dealing $o1 Shadow damage over $d and healing you for ${$e1*100}% of the damage done.
    soul_flame                     = { 72041, 199471, 2 }, -- When you kill a target, its soul bursts into flames, dealing ${$199581s1*(1+$s2/100)} Shadowflame damage to nearby enemies. Deals reduced damage beyond $s4 targets.
    soul_rot                       = { 72056, 386997, 1 }, -- Wither away all life force of your current target and up to $s3 additional targets nearby, causing your primary target to suffer ${$o2*(1+$m4/10)} Nature damage and secondary targets to suffer $o2 Nature damage over $d.; For the next $d, casting Drain Life will cause you to also Drain Life from any enemy affected by your Soul Rot, and Drain Life will not consume any mana.
    soul_swap                      = { 72037, 386951, 1 }, -- Copies your damage over time effects from the target, preserving their duration.; Your next use of Soul Swap within $86211d will exhale a copy damage of the effects onto a new target.
    souleaters_gluttony            = { 71920, 389630, 2 }, -- Whenever Unstable Affliction deals damage, the cooldown of Soul Rot is reduced by ${$s1/$s2}.1 sec.
    sow_the_seeds                  = { 72039, 196226, 1 }, -- Seed of Corruption now $@switch<$s2>[][consumes a Soul Shard, if available, to ]embeds demon seeds into $s1 additional nearby enemies.
    summon_darkglare               = { 72034, 205180, 1 }, -- Summons a Darkglare from the Twisting Nether that extends the duration of your damage over time effects on all enemies by $s2 sec.; The Darkglare will serve you for $d, blasting its target for $205231s1 Shadow damage, increased by $s3% for every damage over time effect you have active on their current target.
    tormented_crescendo            = { 72031, 387075, 1 }, -- While Agony, Corruption, and Unstable Affliction are active, your Shadow Bolt has a $s1% chance and your Drain Soul has a $s2% chance to make your next Malefic Rapture cost no Soul Shards and cast instantly.
    unstable_affliction            = { 72048, 316099, 1 }, -- Afflicts one target with $o2 Shadow damage over $d. ; If dispelled, deals ${$m2*$s1/100} damage to the dispeller and silences them for $196364d.$?s231791[; Generates $231791m1 Soul $LShard:Shards; if the target dies while afflicted.][]
    vile_taint                     = { 72036, 278350, 1 }, -- Unleashes a vile explosion at the target location, dealing $386931o1 Shadow damage over $386931d to $s2 enemies within $a1 yds and applies Agony and Curse of Exhaustion to them.
    withering_bolt                 = { 72055, 386976, 2 }, -- Shadow Bolt and Drain Soul deal $s1% increased damage, up to ${$s1*$s2}%, per damage over time effect you have active on the target.
    wrath_of_consumption           = { 72033, 387065, 1 }, -- Corruption and Agony each grant an application of Wrath of Consumption when a target dies, increasing all periodic damage dealt by $s2% for $387066d, stacking up to $387066u times.
    writhe_in_agony                = { 72051, 196102, 1 }, -- Agony's damage starts at $s3 stacks and may now ramp up to $s2 stacks.
    xavius_gambit                  = { 71921, 416615, 2 }, -- Unstable Affliction deals $s1% increased damage.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    bonds_of_fel        = 5546, -- (353753) Encircle enemy players with Bonds of Fel. If any affected player leaves the $a2 yd radius they explode, dealing $353813s1 Fire damage split amongst all nearby enemies.
    call_observer       = 5543, -- (201996) Summons a demonic Observer to keep a watchful eye over the area for $d.; Anytime an enemy within $m2 yards casts a harmful magical spell, the Observer will deal up to $212529s2% of the target's maximum health in Shadow damage.
    essence_drain       = 19, -- (221711) Whenever you heal yourself with Drain Life, the enemy target deals $221715m1% reduced damage to you for $221715d. Stacks up to $221715u times.
    gateway_mastery     = 15, -- (248855) Increases the range of your Demonic Gateway by $s1 yards, and reduces the cast time by $s2%.  Reduces the time between how often players can take your Demonic Gateway by $s3 sec.
    impish_instincts    = 5579, -- (409835) Taking direct Physical damage reduces the cooldown of Demonic Circle by ${$s1/-1000} sec.; Cannot occur more than once every $proccooldown sec.
    nether_ward         = 18, -- (212295) Surrounds the caster with a shield that lasts $d, reflecting all harmful spells cast on you.
    oblivion            = 12, -- (417537) Unleash wicked magic upon your target's soul, dealing $o Shadow damage over $d.; Deals $s2% increased damage, up to ${$s2*$s3}%, per damage over time effect you have active on the target.
    rampant_afflictions = 5379, -- (335052) Unstable Affliction can now be applied to up to $s3 targets, but its damage is reduced by $s2%.
    rapid_contagion     = 5386, -- (344566) For the next $d, all of your damage over time effects occur ${100*(1/(1+$m1/100)-1)}% more often.
    rot_and_decay       = 16, -- (212371) Shadow Bolt damage increases the duration of your Unstable Affliction, Corruption, Agony, and Siphon Life on the target by ${$s2/1000}.1 sec.; Drain Life, Drain Soul, and Oblivion damage increases the duration of your Unstable Affliction, Corruption, Agony, and Siphon Life on the target by ${$s1/1000}.1 sec.;
    shadow_rift         = 5392, -- (353294) Conjure a Shadow Rift at the target location lasting $d. Enemy players within the rift when it expires are teleported to your Demonic Circle.; Must be within $s2 yds of your Demonic Circle to cast.
    soul_rip            = 5608, -- (410598) Fracture the soul of up to $i target players within $r yds into the shadows, reducing their damage done by $s1% and healing received by $s3% for $d. Souls are fractured up to $410615a yds from the player's location.; Players can retrieve their souls to remove this effect.
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
    -- Damage taken from $auracaster's damage over time effects increased by 30%.
    dread_touch = {
        id = 389868,
        duration = 8,
        type = "Magic",
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
    soul_swap = {
        id = 399680,
        duration = 10,
        max_stack = 1,

        source = "nobody",
        agony = false,
        corruption = false,
        unstable_affliction = false
    },
    -- Talent: Consumes a Soul Shard, unlocking the hidden power of your spells.    |cFFFFFFFFDemonic Circle: Teleport|r: Increases your movement speed by $387633s1% and makes you immune to snares and roots for $387633d.    |cFFFFFFFFDemonic Gateway|r: Can be cast instantly.    |cFFFFFFFFDrain Life|r: Gain an absorb shield equal to the amount of healing done for $387630d. This shield cannot exceed $387630s1% of your maximum health.    |cFFFFFFFFHealth Funnel|r: Restores $387626s1% more health and reduces the damage taken by your pet by ${$abs($387641s1)}% for $387641d.    |cFFFFFFFFHealthstone|r: Increases the healing of your Healthstone by $387626s2% and increases your maximum health by $387636s1% for $387636d.
    -- https://wowhead.com/beta/spell=387626
    soulburn = {
        id = 387626,
        duration = 3600,
        max_stack = 1,
        onRemove = function()
            setCooldown( "soulburn", action.soulburn.cooldown )
        end,
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
        duration = 8,
        max_stack = 10
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
        max_stack = 1,
        copy = "vile_taint_dot"
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


local SoulSwapSource = "nobody"
local SoulSwapCorruption = false
local SoulSwapAgony = false
local SoulSwapUnstableAffliction = false

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName, _, amount, interrupt, a, b, c, d, offhand, multistrike, ... )
    if sourceGUID == GUID then
        if spellName == class.abilities.seed_of_corruption.name then
            if subtype == "SPELL_CAST_SUCCESS" then
                action.seed_of_corruption.flying = GetTime()
            elseif subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_REFRESH" then
                action.seed_of_corruption.flying = 0
            end
        elseif spellID == class.abilities.soul_swap_exhale.id then
            local unit = UnitTokenFromGUID( destGUID )

            SoulSwapCorruption = false
            SoulSwapAgony = false
            SoulSwapUnstableAffliction = false
            SoulSwapSource = destGUID

            if unit then
                if FindUnitDebuffByID( unit, class.auras.corruption.id ) then
                    SoulSwapCorruption = true
                end
                if FindUnitDebuffByID( unit, class.auras.agony.id ) then
                    SoulSwapAgony = true
                end
                if FindUnitDebuffByID( unit, class.auras.unstable_affliction.id ) then
                    SoulSwapUnstableAffliction = true
                end
            end
        end
    end
end, false )


spec:RegisterGear( "tier30", 202534, 202533, 202532, 202536, 202531 )
spec:RegisterAura( "infirmity", {
    id = 409765,
    duration = 16, -- spelldata says 2 sec, but applies for 16 seconds from PS and 10 seconds from VT.
    max_stack = 1
} )

-- Tier 29
spec:RegisterGear( "tier29", 200336, 200338, 200333, 200335, 200337 )
spec:RegisterAuras( {
    cruel_inspiration = {
        id = 394215,
        duration = 6,
        max_stack = 1
    },
    cruel_epiphany = {
        id = 394253,
        duration = 40,
        max_stack = 5
    }
} )

-- Tier 28
spec:RegisterGear( "tier28", 188884, 188887, 188888, 188889, 188890 )
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

    if buff.soul_swap.up then
        buff.soul_swap.source = SoulSwapSource
        if SoulSwapAgony then buff.soul_swap.agony = true end
        if SoulSwapCorruption then buff.soul_swap.corruption = true end
        if SoulSwapUnstableAffliction then buff.soul_swap.unstable_affliction = true end
        if Hekili.ActiveDebug then Hekili:Debug( "Soul Swap available; Agony: " .. tostring( buff.soul_swap.agony ) .. ", Corruption: " .. tostring( buff.soul_swap.corruption ) .. ", Unstable Affliction: " .. tostring( buff.soul_swap.unstable_affliction ) .. "." ) end
    end

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
        cast = 0,
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
        flash = { 686, 198590 },
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

    --[[ Passive in 10.0.5 -- Talent: Summon an Inquisitor's Eye that periodically blasts enemies for 254 Shadowflame damage and occasionally dealing 290 Shadowflame damage instead. Lasts 1 |4hour:hrs;.
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
    }, ]]

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
            removeStack( "cruel_epiphany" )

            if buff.calamitous_crescendo.up then removeBuff( "calamitous_crescendo" ) end
            if buff.tormented_crescendo.up then removeBuff( "tormented_crescendo" ) end

            if talent.dread_touch.enabled then
                if debuff.unstable_affliction.up then applyDebuff( "target", "dread_touch" ) end
                active_dot.dread_touch = active_dot.unsable_affliction
            end

            --[[ if talent.malefic_affliction.enabled and active_dot.unstable_affliction > 0 then
                if buff.malefic_affliction.stack == 3 then
                    if debuff.unstable_affliction.up then applyDebuff( "target", "dread_touch" )
                    else active_dot.dread_touch = 1 end
                else addStack( "malefic_affliction" ) end
            end ]]
            if legendary.malefic_wrath.enabled then addStack( "malefic_wrath" ) end
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
        cooldown = 33,
        gcd = "spell",
        school = "shadow",

        spend = 0.01,
        spendType = "mana",

        talent = "phantom_singularity",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "phantom_singularity" )
            if set_bonus.tier30_4pc > 0 then applyDebuff( "target", "infirmity" ) end
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
        cast = 2,
        cooldown = 0,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "seed_of_corruption",
        startsCombat = true,
        nodebuff = "seed_of_corruption",

        velocity = 30,

        handler = function()
            removeStack( "cruel_epiphany" )
        end,

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
            applyDebuff( "target", "siphon_life" )
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
        icd = 30,
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "soul_swap",
        startsCombat = true,
        nobuff = "soul_swap",

        handler = function ()
            applyBuff( "soul_swap" )
            buff.soul_swap.corruption = debuff.corruption.up
            buff.soul_swap.agony = debuff.agony.up
            buff.soul_swap.unstable_affliction = debuff.unstable_affliction.up
            if debuff.unstable_affliction.up then removeDebuff( "unstable_affliction" ) end
        end,

        bind = "soul_swap_exhale"
    },


    -- Talent: Applies Corruption, Agony, and Unstable Affliction to your target.
    soul_swap_exhale = {
        id = 399685,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        talent = "soul_swap",
        startsCombat = true,
        buff = "soul_swap",

        usable = function() return buff.soul_swap.source ~= target.unit, "cannot apply to source of dots" end,

        handler = function ()
            if buff.soul_swap.agony then applyDebuff( "target", "agony" ) end
            if buff.soul_swap.corruption then applyDebuff( "target", "corruption" ) end
            if buff.soul_swap.unstable_affliction then applyDebuff( "target", "unstable_affliction" ) end
            removeBuff( "soul_swap" )
        end,

        bind = "soul_swap"
    },

    --[[ Removed in 10.0.5 -- Talent: Sacrifice 8% of your Soul Leech to gain a Soul Shard.
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
    }, ]]

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
        nobuff = "soulburn",

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
        startsCombat = true,

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

        startsCombat = false,
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

        startsCombat = false,
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

        startsCombat = false,
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
            summonPet( "sayaad" )
        end,

        copy = { 365349, "summon_incubus", "summon_succubus" },

        bind = function()
            if settings.default_pet == "summon_sayaad" then return { "summon_incubus", "summon_succubus", "summon_pet" } end
            return { "summon_incubus", "summon_succubus" }
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
        nobuff = "summon_soulkeeper",

        handler = function ()
            applyBuff( "summon_soulkeeper", nil, buff.tormented_souls.stack )
            removeBuff( "tormented_souls" )
        end,
    },


    summon_voidwalker = {
        id = 697,
        cast = function () return ( buff.fel_domination.up and 0.5 or 6 ) * haste end,
        cooldown = 0,
        gcd = "spell",

        spend = function () return buff.fel_domination.up and 0 or 1 end,
        spendType = "soul_shards",

        startsCombat = false,
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
            -- removeBuff( "malefic_affliction" )

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
        cooldown = 25,
        gcd = "spell",
        school = "shadow",

        spend = 1,
        spendType = "soul_shards",

        talent = "vile_taint",
        startsCombat = true,

        handler = function()
            applyDebuff( "target", "agony" )
            active_dot.agony = min( active_enemies, active_dot.agony + 7 )
            applyDebuff( "target", "curse_of_exhaustion" )
            active_dot.curse_of_exhaustion = min( active_enemies, active_dot.curse_of_exhaustion + 7 )
            if set_bonus.tier30_4pc > 0 then applyDebuff( "target", "infirmity", 10 ) end
        end,

        -- Azerite
        auras = {
            cascading_calamity = {
                id = 275378,
                duration = 15,
                max_stack = 1
            }
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
    damageDots = true,
    damageExpiration = 6,

    potion = "spectral_intellect",

    package = "Affliction",
} )


spec:RegisterPack( "Affliction", 20230711, [[Hekili:LZvBpUnUr4FlbhGJdUCow2EZU5A8c07AlWf0ET4CUVAzAj61QRSORe1Uzbm0V9oKuVqrXHskBsoGw0E351C4mdhoZZmCi3DR32pUDtiHt3(RlMVy58R98M5D1v3S6DB3WF6mD7MZKG7j3bFiHCc(3)5dhIJc4rSeXqpfZiHcwKXYtdGHpY5NZ(X38M7I4hZ3plGD6nzrNYJjIzeKsoWf)CWB2UzFEum)xs2U3M8VE5kGNNPbWx)2Ra2gfgsv0sZc2Urq7pm)6FWZ7hl29B0tShOHf7(hKy6HOGIDnkzXUdS0IDEZN5n7Q)uXosapNexSl)SqOf7sy8IDprH)f5bsumzFmDwXhk(GsaV9hwSceaW5OebB4psj3d)NJeycXrCAkjo(PIDbhjj3rZKS7yuYDASa()xjzXVXY5rj0grR4cjmeM3VNKXfYUTQts0xu)g5mppfiz6JGXfz1(9f7(lm2PID)umllJD6vGCyaj)Z)QCTlPjokJ3sd9ENud)9sfRYInF21AKTszSbYYaA(xWkMlKZgy5cBVPrCWoeDa(cwESy1cRThJIHpUhixi2F(VuYAcmYXiWqdEqPSdWN2UrPBzZoNsbFM9e(6d0y)q2POePRZRJoSMhDIE78jV4mLpJeh9aDYl2NF4WS7sJoXIsP(Sd(zKG0iWQqNLFU4dD463V(nz5NoXs8bMyF8hG1IyR41c)91bXuYduFY54xhspqYJ5RN)A251P0mmgyvDK6pSHLWruxAIqOHi6mLgkipGLMMFUYEaXhXX(Cs6DuE2SU04ty0BxANJhj5ji6FEPVOpP2VsinbPGLiKXNzHI1W(cpk4EWBa(GAHcycX(zpsW2iosczp6VNfZfEzLKadeabv(QF0x4RQ2jQ2xY6Nu2DbH9tfe(EAamt5b86mEkSsx7PzkOj0tr0SB9M0(lE)QlxQ02znoq9lky)YLCwQZHtQOF)ufQGM)vykLe6Zz5bhNesLriAF1Su6jsus27xOZT6TkF6NocSrWo5mRhaINMy(nDDdMmTF3eKHMv6(C5sFumbB8QL2vVsFT9C9NVCPsU18xN9K7yjpjyO1rBhXALKSOZhLUbhOO00oCf(IWuGiFXEH2oFzef90(usaDY0YD)2F9myTgC)7xE5I9HRK)YwgrTG1Vnc8SkbJFwt(fHGBHTKY4xUeWyXa7sQ)QAgUM(jAqoN6lsC4GWBxVOLX(biJeaRgLWFMsuBMuiZAAM)DX5Co4VmlLKC)7xmXHo51nafgxOr1ylpW9HOY6F8CMVwsVMuDHK07VdmH0wtws9emELLc)iekAS47bbsHnCKKgElGboTCYCw6j4)cPNcG0Mb0KqMckXYakNL1Et0yvBhdCGVrjharmGdGr2aiHr(kir1kBrpCUjXrOaBktUnySlPzB8(8v0YHsIU7i)aKpQpBLC4AQ7AMuqsvWysQH6DFisbTgc5WYkXcUD1nxU4KGfZNCqij)QiRv4GF9Pxgqx9rUgE(bWcCuwwUdeDRePRHGXuoJ1EiALw1pZGsa6a3x(LnWsMJybR0KKobWLF)xZKJvI2AXRcw38nZqNTA7i4Pa5IxwQRQ4O6zmrtzLuBrfmachMkwJ99Op)i1xquM5mnc5mhUDmX0McOeq92ayF1eNXfEZrwAI5FpLEMMw7J3ejlgScyDEzKNTrVD5K9WPgnc9SitTkwg6oJ2CE)s7MP2HlqUs2EsSwutL0Th5Ok0UV8sRVYYmmc3Q)()3RQ4VRy3VY4u4C8)nXjXZyNGdNdqGzGhpwxicfhLpGjmr7IYkBzcj(rYtzIEkeKNc12mt0zGpEumU4FehXNLEpjfMw4mlM2VQ4o1sXrT5Me5Yp2MRrFfTBNuhszPTPAfxQcZGSpJflQ2Sz4j9dRwZCnM6miEkU40WV6OPVYIiDMOQMkBj6Aht2krwZqOO8UWgg3PM17SGt2(cl8fTal9EvnwMovIUAE8HasgV8uiIXTy4XiTX6lddTqLO)B1g5zQqwB72JOmnTnXruTMPO(Iv7PLSGRgMu1sUp8m5dbkQBzMdps21ChyQxB7p6zFLnttGRNr9LF24Smz(k)e8zOAbwindQHbsO4hL8a7EXzMdyH0p138cyj)BiibcQogfhl0FQU6j6iOa)HvHH6u1kPEpiDAQijZGNrmJf6Fip9j0z8DFxvJ4RNLALc1yaM)esSVWVrTQoZEKMcwId5zJqVpeLsLAc6eAMsDxv)EZoFl7pGOv3zu(RFGeNtxJHK0uJsj(KtCECrkpDBxrAGi1rA2YxGlezNn6kK6a3oSVBghCM3CO92symDDziY5ibIlcZAleCJFDROAmvT6oLQVwvFbAAuxR7kNR2Q0lQxALA8LltTL(qVH5A99qIG2oiqLc4vB38aeDc)C59g(2fR2U5rsAcSOZ2U5JhHIyJoDMLYlV0PxwE9nVuuV7)jhcrcRQ)LKdMlaYjS(I8Gkw)7Y7Q7TqLY)mlbKLC4x2n)7lvxWMLrQUshGIPEF6v180BPDM2UTOg81ONPySE1xpwFfcRlDFmzAv4eg7qSSFUS7MVSS7D2zNLA3m4STQ7qeYI5FleI33cHG4r)nri1fhAW6MIg7WWIpybFO(QjhhcX1oC8e9dWMNNSpbdtRim640hep3wnXQJoPngAibIJ0OJWSUmRZSmUflIozjdOH6zRkgm)o7YOjtQbRBgaJJy4)J1sQ4gcU8xuBaImEg2GVSztW4MrLmMC1y4b6RQok04CurIkT0sfdD0cfOrOi5t(MiKU9)X0y3HGXwPXZRORVkvYHa()zY0Ip8lshnbRUU9Z1s4jTDJ8tIxBN8mWWh(v5Z3RKrB)PTBcsfpkTicuEC3Z9v9kR2UP(u6B5q9Zg8q9o)WoiEdtqPa45sR80YH0ByNTb5W)BtzH72wU1Z1450Omv(kPwNBX2IDqCqCUABRQbn5A78k09k12t178Py3TGRvXUjkxa9bEFXUvf7UCPyxZ2B97lA7g1BhsyMgMQPMRq3UAm62YXljOmgHyElQyWJpKgc8oYknklAudJUMkK61OsTZL5ifw)xOJKSP17pixxrXU1f7MlP9fYRrX113O2whcDtWPr3MCvXUx1ywmVklHD5M(20h06QL(RRKTugnSNUmuOmVdvzq4JSxPIz6nFStTjhKC(4GOiZx7gDKmqcQunO8Ye15NGctKJoo(2peELFMJ3vLu3wQS(oFFvveQ5u007xPsIdq9hPsQ1WzPwIdvjCgTxVOsYOp2kqQGhT(B3Q3jClmHfAUewkMwQT4iEFX1wnUz71MPakLBw9SU80GtBQKxUCWHsB3stPyA30tdSiqQsoIdc1E6T5OfHO6DAfkkIPvtjmk(xQm4Gqk8tXliqMcSml80Ab5Orgn5uqFvysevvkFdb1owWsYTf4OFpxvtDzBvPVqEOCUvoCO1NRY1y3CN8FHzfFwlrUQLZgfx14MzST45wM9c333YUKSo9WAOBy2U2u3Qmo4VRRXufmCJYS1lHlufn06Ivvf1AMtQk16cC0E3lX2P2wGdd7MngjFwGJ)PDlRwQrzbomN1j2UcLfsCP6RND7gpRl021CSCUEvj6lKw0XRpgGZJtQ7)VUvXq2CM6REi84J))UICZGWkATvZS83eU0iLtYM)aEvxFLpWGZtL23zcmJ3BtaoJA98jeXdop(4WoEGzOVnYqy6s7AeEzknv(4ONE1oSDFOyDwkD6AN1tCzb2cZmvfOoe10Owo0oikJRSzOuhTRs7SvJUX50AHCPv7RTJZ1kqwuoRbrRArKz5MgeJ7Q)86mYDbHZor(Kt46bDifm574nT5wO4Hv9l0Pk)xlhFbW0QEOALh3e5nR0ZuS)k4SrTTNZqFfT74upJPSghNxzCL1GFgIERPBSf)jEADJUkq86smF0Dn(KU0faadtuyni2sMdT62Sb(05ua9Hs2h)WQoqVeqZ3WNOwX66OhsXGIo1wvjORs4ggs5YXH)UAa4Q92Q6VKfH4Scml1z0OmpN8RMqJdR6fP6RzdKu7QWMBgrckCKM6oTy5re03c1R1zumbknsrIdcmv)ecv4aUBeeGq)CHk8W7SGrsrHW1B0ZCnit7uP68JB4sDnRZVfqnLPyXpAavE2XBsBoUknTttKhbiL3GbPAUsplhALDw4UPLTRIAXNIZPQythVJvtFhhpucjZlVJlvxo5DVJXHPq2FLRM6s3xwHUki7xvnU7OvH6GeeH3TBQnIw2(1Am8rj6pNg9Ql6M23zl)q)YV)T5wnyV7wqN(V3TB(vdI8Kt0xoLVuwBPx6FT8cndvjJQBvT9kvBFBYgDcf9b4kRWvFlO(rgidqRFmD2cq1YDiRI(wT8Y1)TDP6lKAa2FHxAmeT)RftNcuA(J(ITcumSWPuuBCARBoxDR7vVpHnZT5(3jrPZ)8V0ivRK5U(NH83dMQlW3DE532x1F4hE7ZQiSjDqz0FIK9wf2ndnVH8HC85)Szu)6JydIFGmO53OeB(EdLj1)sM42FZjtQ)DerAyeE758JS0TB2eD6NLFZ2)7p]] )