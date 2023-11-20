-- DemonHunterHavoc.lua
-- October 2023

if UnitClassBase( "player" ) ~= "DEMONHUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat = string.format

local spec = Hekili:NewSpecialization( 577 )

spec:RegisterResource( Enum.PowerType.Fury, {
    -- Immolation Aura now grants 20 up front, 60 over 12 seconds (5 fps).
    immolation_aura = {
        talent  = "burning_hatred",
        aura    = "immolation_aura",

        last = function ()
            local app = state.buff.immolation_aura.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 5
    },

    tactical_retreat = {
        talent  = "tactical_retreat",
        aura    = "tactical_retreat",

        last = function ()
            local app = state.buff.tactical_retreat.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = function() return class.auras.tactical_retreat.tick_time end,
        value = 8
    },

    eye_beam = {
        talent = "blind_fury",
        aura   = "eye_beam",

        last = function ()
            local app = state.buff.eye_beam.applied
            local t = state.query_time

            return app + floor( ( t - app ) / state.haste ) * state.haste
        end,

        interval = function () return state.haste end,
        value = 20,
    },
} )

-- Talents
spec:RegisterTalents( {
    -- Demon Hunter
    aldrachi_design          = { 90999, 391409, 1 }, -- Increases your chance to parry by 3%.
    aura_of_pain             = { 90933, 207347, 1 }, -- Increases the critical strike chance of Immolation Aura by 6%.
    blazing_path             = { 91008, 320416, 1 }, -- Fel Rush gains an additional charge.
    bouncing_glaives         = { 90931, 320386, 1 }, -- Throw Glaive ricochets to 1 additional target.
    champion_of_the_glaive   = { 90994, 429211, 1 }, -- Throw Glaive has 2 charges and 10 yard increased range.
    chaos_fragments          = { 95154, 320412, 1 }, -- Each enemy stunned by Chaos Nova has a 30% chance to generate a Lesser Soul Fragment.
    chaos_nova               = { 90993, 179057, 1 }, -- Unleash an eruption of fel energy, dealing 2,602 Chaos damage and stunning all nearby enemies for 2 sec.
    charred_warblades        = { 90948, 213010, 1 }, -- You heal for 3% of all Fire damage you deal.
    collective_anguish       = { 95152, 390152, 1 }, -- Eye Beam summons an allied Vengeance Demon Hunter who casts Fel Devastation, dealing 17,854 Fire damage over 2 sec. Dealing damage heals you for up to 1,395 health.
    consume_magic            = { 91006, 278326, 1 }, -- Consume 1 beneficial Magic effect removing it from the target.
    darkness                 = { 91002, 196718, 1 }, -- Summons darkness around you in an 8 yd radius, granting friendly targets a 15% chance to avoid all damage from an attack. Lasts 8 sec. Chance to avoid damage increased by 100% when not in a raid.
    demon_muzzle             = { 90928, 388111, 1 }, -- Enemies deal 8% reduced magic damage to you for 8 sec after being afflicted by one of your Sigils.
    demonic                  = { 91003, 213410, 1 }, -- Eye Beam causes you to enter demon form for 5 sec after it finishes dealing damage.
    disrupting_fury          = { 90937, 183782, 1 }, -- Disrupt generates 30 Fury on a successful interrupt.
    elysian_decree           = { 90997, 390163, 1 }, -- Place a Kyrian Sigil at the target location that activates after 1 sec. Detonates to deal 39,422 Chaos damage and shatter up to 3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond 5 targets.
    erratic_felheart         = { 90996, 391397, 2 }, -- The cooldown of Fel Rush is reduced by 10%.
    felblade                 = { 95150, 232893, 1 }, -- Charge to your target and deal 9,964 Chaos damage. Demon Blades has a chance to reset the cooldown of Felblade. Generates 40 Fury.
    felfire_haste            = { 90939, 389846, 1 }, -- Fel Rush increases your movement speed by 10% for 8 sec.
    flames_of_fury           = { 90949, 389694, 2 }, -- Sigil of Flame deals 35% increased damage and generates 1 additional Fury per target hit.
    illidari_knowledge       = { 90935, 389696, 1 }, -- Reduces magic damage taken by 5%.
    imprison                 = { 91007, 217832, 1 }, -- Imprisons a demon, beast, or humanoid, incapacitating them for 1 min. Damage will cancel the effect. Limit 1.
    improved_disrupt         = { 90938, 320361, 1 }, -- Increases the range of Disrupt to 10 yds.
    improved_sigil_of_misery = { 90945, 320418, 1 }, -- Reduces the cooldown of Sigil of Misery by 30 sec.
    infernal_armor           = { 91004, 320331, 2 }, -- Immolation Aura increases your armor by 20% and causes melee attackers to suffer 806 Chaos damage.
    internal_struggle        = { 90934, 393822, 1 }, -- Increases your mastery by 3.6%.
    live_by_the_glaive       = { 95151, 428607, 1 }, -- When you parry an attack or have one of your attacks parried, restore 4% of max health and 10 Fury. This effect may only occur once every 5 sec.
    long_night               = { 91001, 389781, 1 }, -- Increases the duration of Darkness by 3 sec.
    lost_in_darkness         = { 90947, 389849, 1 }, -- Spectral Sight lasts an additional 6 sec if disrupted by attacking or taking damage.
    master_of_the_glaive     = { 90994, 389763, 1 }, -- Throw Glaive has 2 charges and snares all enemies hit by 50% for 6 sec.
    pitch_black              = { 91001, 389783, 1 }, -- Reduces the cooldown of Darkness by 120 sec.
    precise_sigils           = { 95155, 389799, 1 }, -- All Sigils are now placed at your target's location.
    pursuit                  = { 90940, 320654, 1 }, -- Mastery increases your movement speed.
    quickened_sigils         = { 95149, 209281, 1 }, -- All Sigils activate 1 second faster.
    rush_of_chaos            = { 95148, 320421, 2 }, -- Reduces the cooldown of Metamorphosis by 30 sec.
    shattered_restoration    = { 90950, 389824, 1 }, -- The healing of Shattered Souls is increased by 10%.
    soul_rending             = { 90936, 204909, 2 }, -- Leech increased by 10%. Gain an additional 10% leech while Metamorphosis is active.
    soul_sigils              = { 90929, 395446, 1 }, -- Afflicting an enemy with a Sigil generates 1 Lesser Soul Fragment.
    swallowed_anger          = { 91005, 320313, 1 }, -- Consume Magic generates 20 Fury when a beneficial Magic effect is successfully removed from the target.
    the_hunt                 = { 90927, 370965, 1 }, -- Charge to your target, striking them for 45,564 Chaos damage, rooting them in place for 1.5 sec and inflicting 40,211 Chaos damage over 6 sec to up to 5 enemies in your path. The pursuit invigorates your soul, healing you for 10% of the damage you deal to your Hunt target for 20 sec.
    unrestrained_fury        = { 90941, 320770, 1 }, -- Increases maximum Fury by 20.
    vengeful_bonds           = { 90930, 320635, 1 }, -- Vengeful Retreat reduces the movement speed of all nearby enemies by 70% for 3 sec.
    will_of_the_illidari     = { 91000, 389695, 1 }, -- Increases maximum health by 5%.

    -- Havoc
    a_fire_inside            = { 95143, 427775, 1 }, -- Immolation Aura has 1 additional charge and 30% chance to refund a charge when used. You can have multiple Immolation Auras active at a time.
    accelerated_blade        = { 91011, 391275, 1 }, -- Throw Glaive deals 60% increased damage, reduced by 30% for each previous enemy hit.
    any_means_necessary      = { 90919, 388114, 1 }, -- Mastery: Demonic Presence now also causes your Arcane, Fire, Frost, Nature, and Shadow damage to be dealt as Chaos instead, and increases that damage by 29.5%.
    blind_fury               = { 91026, 203550, 2 }, -- Eye Beam generates 40 Fury every second, and its damage and duration are increased by 10%.
    burning_hatred           = { 90923, 320374, 1 }, -- Immolation Aura generates an additional 40 Fury over 10 sec.
    burning_wound            = { 90917, 391189, 1 }, -- Demon Blades and Throw Glaive leave open wounds on your enemies, dealing 7,164 Chaos damage over 15 sec and increasing damage taken from your Immolation Aura by 40%. May be applied to up to 3 targets.
    chaos_theory             = { 91035, 389687, 1 }, -- Blade Dance causes your next Chaos Strike within 8 sec to have a 14-30% increased critical strike chance and will always refund Fury.
    chaotic_disposition      = { 95147, 428492, 2 }, -- Your Chaos damage has a 7.77% chance to be increased by 17%, occurring up to 3 total times.
    chaotic_transformation   = { 90922, 388112, 1 }, -- When you activate Metamorphosis, the cooldowns of Blade Dance and Eye Beam are immediately reset.
    critical_chaos           = { 91028, 320413, 1 }, -- The chance that Chaos Strike will refund 20 Fury is increased by 30% of your critical strike chance.
    cycle_of_hatred          = { 91032, 258887, 2 }, -- Blade Dance, Chaos Strike, and Glaive Tempest reduce the cooldown of Eye Beam by 0.5 sec.
    dancing_with_fate        = { 91015, 389978, 2 }, -- The final slash of Blade Dance deals an additional 25% damage.
    dash_of_chaos            = { 93014, 427794, 1 }, -- For 2 sec after using Fel Rush, activating it again will dash back towards your initial location.
    deflecting_dance         = { 93015, 427776, 1 }, -- You deflect incoming attacks while Blade Dancing, absorbing damage up to 15% of your maximum health.
    demon_blades             = { 91019, 203555, 1 }, -- Your auto attacks deal an additional 1,512 Chaos damage and generate 7-12 Fury.
    demon_hide               = { 91017, 428241, 1 }, -- Magical damage increased by 3%, and Physical damage taken reduced by 5%.
    desperate_instincts      = { 93016, 205411, 1 }, -- Blur now reduces damage taken by an additional 10%. Additionally, you automatically trigger Blur with 50% reduced cooldown and duration when you fall below 35% health. This effect can only occur when Blur is not on cooldown.
    essence_break            = { 91033, 258860, 1 }, -- Slash all enemies in front of you for 26,753 Chaos damage, and increase the damage your Chaos Strike and Blade Dance deal to them by 80% for 4 sec. Deals reduced damage beyond 8 targets.
    eye_beam                 = { 91018, 198013, 1 }, -- Blasts all enemies in front of you, for up to 34,645 Chaos damage over 1.6 sec. Deals reduced damage beyond 5 targets. When Eye Beam finishes fully channeling, your Haste is increased by an additional 10% for 10 sec.
    fel_barrage              = { 95144, 258925, 1 }, -- Unleash a torrent of Fel energy, rapidly consuming Fury to inflict 3,756 Chaos damage to all enemies within 12 yds, lasting 8 sec or until Fury is depleted. Deals reduced damage beyond 5 targets.
    first_blood              = { 90925, 206416, 1 }, -- Blade Dance deals 21,300 Chaos damage to the first target struck.
    furious_gaze             = { 91025, 343311, 1 }, -- When Eye Beam finishes fully channeling, your Haste is increased by an additional 10% for 10 sec.
    furious_throws           = { 93013, 393029, 1 }, -- Throw Glaive now costs 25 Fury and throws a second glaive at the target.
    glaive_tempest           = { 91035, 342817, 1 }, -- Launch two demonic glaives in a whirlwind of energy, causing 28,465 Chaos damage over 3 sec to all nearby enemies. Deals reduced damage beyond 8 targets.
    growing_inferno          = { 90916, 390158, 1 }, -- Immolation Aura's damage increases by 10% each time it deals damage.
    improved_chaos_strike    = { 91030, 343206, 1 }, -- Chaos Strike damage increased by 10%.
    improved_fel_rush        = { 93014, 343017, 1 }, -- Fel Rush damage increased by 20%.
    inertia                  = { 91021, 427640, 1 }, -- When empowered by Unbound Chaos, Fel Rush increases your damage done by 18% for 5 sec.
    initiative               = { 91027, 388108, 1 }, -- Damaging an enemy before they damage you increases your critical strike chance by 10% for 5 sec. Vengeful Retreat refreshes your potential to trigger this effect on any enemies you are in combat with.
    inner_demon              = { 91024, 389693, 1 }, -- Entering demon form causes your next Chaos Strike to unleash your inner demon, causing it to crash into your target and deal 20,172 Chaos damage to all nearby enemies. Deals reduced damage beyond 5 targets.
    insatiable_hunger        = { 91019, 258876, 1 }, -- Demon's Bite deals 50% more damage and generates 5 to 10 additional Fury.
    isolated_prey            = { 91036, 388113, 1 }, -- Chaos Nova, Eye Beam, and Immolation Aura gain bonuses when striking 1 target.  Chaos Nova: Stun duration increased by 2 sec.  Eye Beam: Deals 30% increased damage.  Immolation Aura: Always critically strikes.
    know_your_enemy          = { 91034, 388118, 2 }, -- Gain critical strike damage equal to 40% of your critical strike chance.
    looks_can_kill           = { 90921, 320415, 1 }, -- Eye Beam deals guaranteed critical strikes.
    momentum                 = { 91021, 206476, 1 }, -- Fel Rush, The Hunt, and Vengeful Retreat increase your damage done by 6% for 6 sec, up to a maximum of 30 sec.
    mortal_dance             = { 93015, 328725, 1 }, -- Blade Dance now reduces targets' healing received by 50% for 6 sec.
    netherwalk               = { 93016, 196555, 1 }, -- Slip into the nether, increasing movement speed by 100% and becoming immune to damage, but unable to attack. Lasts 6 sec.
    ragefire                 = { 90918, 388107, 1 }, -- Each time Immolation Aura deals damage, 35% of the damage dealt by up to 3 critical strikes is gathered as Ragefire. When Immolation Aura expires you explode, dealing all stored Ragefire damage to nearby enemies.
    relentless_onslaught     = { 91012, 389977, 1 }, -- Chaos Strike has a 10% chance to trigger a second Chaos Strike.
    restless_hunter          = { 91024, 390142, 1 }, -- Leaving demon form grants a charge of Fel Rush and increases the damage of your next Blade Dance by 50%.
    scars_of_suffering       = { 90914, 428232, 1 }, -- Increases Versatility by 4% and reduces threat generated by 8%.
    serrated_glaive          = { 91013, 390154, 1 }, -- Enemies hit by Chaos Strike or Throw Glaive take 15% increased damage from Chaos Strike and Throw Glaive for 15 sec.
    shattered_destiny        = { 91031, 388116, 1 }, -- The duration of your active demon form is extended by 0.1 sec per 12 Fury spent.
    sigil_of_misery          = { 90946, 207684, 1 }, -- Place a Sigil of Misery at the target location that activates after 1 sec. Causes all enemies affected by the sigil to cower in fear, disorienting them for 20 sec.
    soulscar                 = { 91012, 388106, 1 }, -- Throw Glaive causes targets to take an additional 100% of damage dealt as Chaos over 6 sec.
    tactical_retreat         = { 91022, 389688, 1 }, -- Vengeful Retreat has a 5 sec reduced cooldown and generates 80 Fury over 10 sec.
    trail_of_ruin            = { 90915, 258881, 1 }, -- The final slash of Blade Dance inflicts an additional 6,814 Chaos damage over 4 sec.
    unbound_chaos            = { 91020, 347461, 1 }, -- Activating Immolation Aura increases the damage of your next Fel Rush by 250%. Lasts 12 sec.
    vengeful_retreat         = { 90942, 198793, 1 }, -- Remove all snares and vault away. Nearby enemies take 1,076 Physical damage.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    blood_moon        = 5433, -- (355995) Consume Magic now affects all enemies within 8 yards of the target and generates a Lesser Soul Fragment. Each effect consumed has a 5% chance to upgrade to a Greater Soul.
    chaotic_imprint   = 809 , -- (356510) Throw Glaive now deals damage from a random school of magic, and increases the target's damage taken from the school by 10% for 20 sec.
    cleansed_by_flame = 805 , -- (205625) Immolation Aura dispels all magical effects on you when cast.
    cover_of_darkness = 1206, -- (357419) The radius of Darkness is increased by 4 yds, and its duration by 2 sec.
    detainment        = 812 , -- (205596) Imprison's PvP duration is increased by 1 sec, and targets become immune to damage and healing while imprisoned.
    glimpse           = 813 , -- (354489) Vengeful Retreat provides immunity to loss of control effects, and reduces damage taken by 35% until you land.
    rain_from_above   = 811 , -- (206803) You fly into the air out of harm's way. While floating, you gain access to Fel Lance allowing you to deal damage to enemies below.
    reverse_magic     = 806 , -- (205604) Removes all harmful magical effects from yourself and all nearby allies within 10 yards, and sends them back to their original caster if possible.
    sigil_mastery     = 5523, -- (211489) Reduces the cooldown of your Sigils by an additional 25%.
    unending_hatred   = 1218, -- (213480) Taking damage causes you to gain Fury based on the damage dealt.
} )


-- Auras
spec:RegisterAuras( {
    -- Dodge chance increased by $s2%.
    -- https://wowhead.com/beta/spell=188499
    blade_dance = {
        id = 188499,
        duration = 1,
        max_stack = 1
    },
    blazing_slaughter = {
        id = 355892,
        duration = 12,
        max_stack = 20,
    },
    -- Versatility increased by $w1%.
    -- https://wowhead.com/beta/spell=355894
    blind_faith = {
        id = 355894,
        duration = 20,
        max_stack = 1
    },
    -- Dodge increased by $s2%. Damage taken reduced by $s3%.
    -- https://wowhead.com/beta/spell=212800
    blur = {
        id = 212800,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Taking $w1 Chaos damage every $t1 seconds.  Damage taken from $@auracaster's Immolation Aura increased by $s2%.
    -- https://wowhead.com/beta/spell=391191
    burning_wound_391191 = {
        id = 391191,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
    },
    burning_wound_346278 = {
        id = 346278,
        duration = 15,
        tick_time = 3,
        max_stack = 1,
    },
    burning_wound = {
        alias = { "burning_wound_391191", "burning_wound_346278" },
        aliasMode = "first",
        aliasType = "buff",
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=179057
    chaos_nova = {
        id = 179057,
        duration = function () return talent.isolated_prey.enabled and active_enemies == 1 and 4 or 2 end,
        type = "Magic",
        max_stack = 1
    },
    chaos_theory = {
        id = 390195,
        duration = 8,
        max_stack = 1,
    },
    chaotic_blades = {
        id = 337567,
        duration = 8,
        max_stack = 1
    },
    darkness = {
        id = 196718,
        duration = function () return pvptalent.cover_of_darkness.enabled and 10 or 8 end,
        max_stack = 1,
    },
    death_sweep = {
        id = 210152,
        duration = 1,
        max_stack = 1,
    },
    demon_soul = {
        id = 347765,
        duration = 15,
        max_stack = 1,
    },
    elysian_decree = { -- TODO: This aura determines sigil pop time.
        id = 390163,
        duration = function () return talent.quickened_sigils.enabled and 1 or 2 end,
        max_stack = 1
    },
    essence_break = {
        id = 320338,
        duration = 4,
        max_stack = 1,
        copy = "dark_slash" -- Just in case.
    },
    -- https://wowhead.com/beta/spell=198013
    eye_beam = {
        id = 198013,
        duration = function () return 2 * ( 1 + 0.1 * talent.blind_fury.rank ) * haste end,
        generate = function( t )
            if buff.casting.up and buff.casting.v1 == 198013 then
                t.applied  = buff.casting.applied
                t.duration = buff.casting.duration
                t.expires  = buff.casting.expires
                t.stack    = 1
                t.caster   = "player"
                forecastResources( "fury" )
                return
            end

            t.applied  = 0
            t.duration = class.auras.eye_beam.duration
            t.expires  = 0
            t.stack    = 0
            t.caster   = "nobody"
        end,
        tick_time = 0.2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Unleashing Fel.
    -- https://wowhead.com/beta/spell=258925
    fel_barrage = {
        id = 258925,
        duration = 8,
        tick_time = 0.25,
        max_stack = 1
    },
    -- Legendary.
    fel_bombardment = {
        id = 337849,
        duration = 40,
        max_stack = 5,
    },
    -- Legendary
    fel_devastation = {
        id = 333105,
        duration = 2,
        max_stack = 1,
    },
    furious_gaze = {
        id = 343312,
        duration = 12,
        max_stack = 1,
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=211881
    fel_eruption = {
        id = 211881,
        duration = 4,
        max_stack = 1
    },
    -- Talent: Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=389847
    felfire_haste = {
        id = 389847,
        duration = 8,
        max_stack = 1,
        copy = 338804
    },
    -- Branded, dealing $204021s1% less damage to $@auracaster$?s389220[ and taking $w2% more Fire damage from them][].
    -- https://wowhead.com/beta/spell=207744
    fiery_brand = {
        id = 207744,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Battling a demon from the Theater of Pain...
    -- https://wowhead.com/beta/spell=391430
    fodder_to_the_flame = {
        id = 391430,
        duration = 25,
        max_stack = 1,
        copy = { 329554, 330910 }
    },
    -- The demon is linked to you.
    fodder_to_the_flame_chase = {
        id = 328605,
        duration = 3600,
        max_stack = 1,
    },
    -- This is essentially the countdown before the demon despawns (you can Imprison it for a long time).
    fodder_to_the_flame_cooldown = {
        id = 342357,
        duration = 120,
        max_stack = 1,
    },
    -- Falling speed reduced.
    -- https://wowhead.com/beta/spell=131347
    glide = {
        id = 131347,
        duration = 3600,
        max_stack = 1
    },
    -- Burning nearby enemies for $258922s1 $@spelldesc395020 damage every $t1 sec.$?a207548[    Movement speed increased by $w4%.][]$?a320331[    Armor increased by $w5%. Attackers suffer $@spelldesc395020 damage.][]
    -- https://wowhead.com/beta/spell=258920
    immolation_aura_1 = {
        id = 258920,
        duration = function() return talent.felfire_heart.enabled and 8 or 6 end,
        tick_time = 1,
        max_stack = 1
    },
    immolation_aura_2 = {
        id = 427912,
        duration = function() return talent.felfire_heart.enabled and 8 or 6 end,
        tick_time = 1,
        max_stack = 1
    },
    immolation_aura_3 = {
        id = 427913,
        duration = function() return talent.felfire_heart.enabled and 8 or 6 end,
        tick_time = 1,
        max_stack = 1
    },
    immolation_aura_4 = {
        id = 427914,
        duration = function() return talent.felfire_heart.enabled and 8 or 6 end,
        tick_time = 1,
        max_stack = 1
    },
    immolation_aura_5 = {
        id = 427915,
        duration = function() return talent.felfire_heart.enabled and 8 or 6 end,
        tick_time = 1,
        max_stack = 1
    },
    immolation_aura = {
        alias = { "immolation_aura_1", "immolation_aura_2", "immolation_aura_3", "immolation_aura_4", "immolation_aura_5" },
        aliasMode = "longest",
        aliasType = "buff",
        max_stack = 5,
    },
    -- Talent: Incapacitated.
    -- https://wowhead.com/beta/spell=217832
    imprison = {
        id = 217832,
        duration = 60,
        mechanic = "sap",
        type = "Magic",
        max_stack = 1
    },
    -- Damage done increased by $w1%.
    inertia = {
        id = 427641,
        duration = 5,
        max_stack = 1,
    },
    initiative = {
        id = 391215,
        duration = 5,
        max_stack = 1,
    },
    inner_demon = {
        id = 337313,
        duration = 10,
        max_stack = 1,
        copy = 390145
    },
    -- Talent: Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=213405
    master_of_the_glaive = {
        id = 213405,
        duration = 6,
        mechanic = "snare",
        max_stack = 1
    },
    -- Chaos Strike and Blade Dance upgraded to $@spellname201427 and $@spellname210152.  Haste increased by $w4%.$?s235893[  Versatility increased by $w5%.][]$?s204909[  Leech increased by $w3%.][]
    -- https://wowhead.com/beta/spell=162264
    metamorphosis = {
        id = 162264,
        duration = function () return 24 + ( pvptalent.demonic_origins.enabled and -15 or 0 ) end,
        max_stack = 1,
        meta = {
            extended_by_demonic = function ()
                return false -- disabled in 8.0:  talent.demonic.enabled and ( buff.metamorphosis.up and buff.metamorphosis.duration % 15 > 0 and buff.metamorphosis.duration > ( action.eye_beam.cast + 8 ) )
            end,
        },
    },
    momentum = {
        id = 208628,
        duration = 6,
        max_stack = 1,
    },
    -- Stunned.
    -- https://wowhead.com/beta/spell=200166
    metamorphosis_stun = {
        id = 200166,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    -- Dazed.
    -- https://wowhead.com/beta/spell=247121
    metamorphosis_daze = {
        id = 247121,
        duration = 3,
        type = "Magic",
        max_stack = 1
    },
    misery_in_defeat = {
        id = 391369,
        duration = 5,
        max_stack = 1,
    },
    -- Talent: Healing effects received reduced by $w1%.
    -- https://wowhead.com/beta/spell=356608
    mortal_dance = {
        id = 356608,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Immune to damage and unable to attack.  Movement speed increased by $s3%.
    -- https://wowhead.com/beta/spell=196555
    netherwalk = {
        id = 196555,
        duration = 6,
        max_stack = 1
    },
    ragefire = {
        id = 390192,
        duration = 30,
        max_stack = 1,
    },
    rain_from_above_immune = {
        id = 206803,
        duration = 1,
        tick_time = 1,
        max_stack = 1,
        copy = "rain_from_above_launch"
    },
    rain_from_above = { -- Gliding/floating.
        id = 206804,
        duration = 10,
        max_stack = 1
    },
    restless_hunter = {
        id = 390212,
        duration = 12,
        max_stack = 1
    },
    -- Damage taken from Chaos Strike and Throw Glaive increased by $w1%.
    serrated_glaive = {
        id = 390155,
        duration = 15,
        max_stack = 1
    },
    -- Movement slowed by $s1%.
    -- https://wowhead.com/beta/spell=204843
    sigil_of_chains = {
        id = 204843,
        duration = function() return 6 + talent.extended_sigils.rank + ( talent.precise_sigils.enabled and 2 or 0 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $w2 $@spelldesc395020 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=204598
    sigil_of_flame_dot = {
        id = 204598,
        duration = function() return ( talent.felfire_heart.enabled and 8 or 6 ) + talent.extended_sigils.rank + ( talent.precise_sigils.enabled and 2 or 0 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Sigil of Flame is active.
    -- https://wowhead.com/beta/spell=389810
    sigil_of_flame = {
        id = 389810,
        duration = function () return talent.quickened_sigils.enabled and 1 or 2 end,
        max_stack = 1,
        copy = 204596
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=207685
    sigil_of_misery_debuff = {
        id = 207685,
        duration = function() return 20 + talent.extended_sigils.rank + ( talent.precise_sigils.enabled and 2 or 0 ) end,
        mechanic = "flee",
        type = "Magic",
        max_stack = 1
    },
    sigil_of_misery = { -- TODO: Model placement pop.
        id = 207684,
        duration = function () return talent.quickened_sigils.enabled and 1 or 2 end,
        max_stack = 1
    },
    -- Silenced.
    -- https://wowhead.com/beta/spell=204490
    sigil_of_silence_debuff = {
        id = 204490,
        duration = function() return 6 + talent.extended_sigils.rank + ( talent.precise_sigils.enabled and 2 or 0 ) end,
        type = "Magic",
        max_stack = 1
    },
    sigil_of_silence = { -- TODO: Model placement pop.
        id = 202137,
        duration = function () return talent.quickened_sigils.enabled and 1 or 2 end,
        max_stack = 1
    },
    -- Consume to heal for $210042s1% of your maximum health.
    -- https://wowhead.com/beta/spell=203795
    soul_fragment = {
        id = 203795,
        duration = 20,
        max_stack = 1
    },
    -- Talent: Suffering $w1 Chaos damage every $t1 sec.
    -- https://wowhead.com/beta/spell=390181
    soulscar = {
        id = 390181,
        duration = 6,
        tick_time = 2,
        max_stack = 1
    },
    -- Can see invisible and stealthed enemies.  Can see enemies and treasures through physical barriers.
    -- https://wowhead.com/beta/spell=188501
    spectral_sight = {
        id = 188501,
        duration = 10,
        max_stack = 1
    },
    tactical_retreat = {
        id = 389890,
        duration = 8,
        tick_time = 1,
        max_stack = 1
    },
    -- Talent: Suffering $w1 $@spelldesc395042 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=345335
    the_hunt_dot = {
        id = 370969,
        duration = function() return set_bonus.tier31_4pc > 0 and 12 or 6 end,
        tick_time = 2,
        type = "Magic",
        max_stack = 1,
        copy = 345335
    },
    -- Talent: Marked by the Demon Hunter, converting $?c1[$345422s1%][$345422s2%] of the damage done to healing.
    -- https://wowhead.com/beta/spell=370966
    the_hunt = {
        id = 370966,
        duration = 30,
        max_stack = 1,
        copy = 323802
    },
    the_hunt_root = {
        id = 370970,
        duration = 1.5,
        max_stack = 1,
        copy = 323996
    },
    -- Taunted.
    -- https://wowhead.com/beta/spell=185245
    torment = {
        id = 185245,
        duration = 3,
        max_stack = 1
    },
    -- Talent: Suffering $w1 Chaos damage every $t1 sec.
    -- https://wowhead.com/beta/spell=258883
    trail_of_ruin = {
        id = 258883,
        duration = 4,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
    },
    unbound_chaos = {
        id = 347462,
        duration = 20,
        max_stack = 1
    },
    vengeful_retreat_movement = {
        duration = 1,
        max_stack = 1,
        generate = function( t )
            if action.vengeful_retreat.lastCast > query_time - 1 then
                t.applied  = action.vengeful_retreat.lastCast
                t.duration = 1
                t.expires  = action.vengeful_retreat.lastCast + 1
                t.stack    = 1
                t.caster   = "player"
                return
            end

            t.applied  = 0
            t.duration = 1
            t.expires  = 0
            t.stack    = 0
            t.caster   = "nobody"
        end,
    },
    -- Talent: Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=198813
    vengeful_retreat = {
        id = 198813,
        duration = 3,
        max_stack = 1,
        copy = "vengeful_retreat_snare"
    },

    -- Conduit
    exposed_wound = {
        id = 339229,
        duration = 10,
        max_stack = 1,
    },

    -- PvP Talents
    chaotic_imprint_shadow = {
        id = 356656,
        duration = 20,
        max_stack = 1,
    },
    chaotic_imprint_nature = {
        id = 356660,
        duration = 20,
        max_stack = 1,
    },
    chaotic_imprint_arcane = {
        id = 356658,
        duration = 20,
        max_stack = 1,
    },
    chaotic_imprint_fire = {
        id = 356661,
        duration = 20,
        max_stack = 1,
    },
    chaotic_imprint_frost = {
        id = 356659,
        duration = 20,
        max_stack = 1,
    },
    -- Conduit
    demonic_parole = {
        id = 339051,
        duration = 12,
        max_stack = 1
    },
    glimpse = {
        id = 354610,
        duration = 8,
        max_stack = 1,
    },
} )


local sigils = setmetatable( {}, {
    __index = function( t, k )
        t[ k ] = 0
        return t[ k ]
    end
} )

spec:RegisterStateFunction( "create_sigil", function( sigil )
    sigils[ sigil ] = query_time + ( talent.quickened_sigils.enabled and 1 or 2 )
end )

spec:RegisterStateExpr( "soul_fragments", function ()
    return buff.soul_fragments.stack
end )

spec:RegisterStateTable( "fragments", {
    real = 0,
    realTime = 0,
} )

spec:RegisterStateFunction( "queue_fragments", function( num, extraTime )
    fragments.real = fragments.real + num
    fragments.realTime = GetTime() + 1.25 + ( extraTime or 0 )
end )

spec:RegisterStateFunction( "purge_fragments", function()
    fragments.real = 0
    fragments.realTime = 0
end )

local last_darkness = 0
local last_metamorphosis = 0
local last_eye_beam = 0

spec:RegisterStateExpr( "darkness_applied", function ()
    return max( class.abilities.darkness.lastCast, last_darkness )
end )

spec:RegisterStateExpr( "metamorphosis_applied", function ()
    return max( class.abilities.darkness.lastCast, last_metamorphosis )
end )

spec:RegisterStateExpr( "eye_beam_applied", function ()
    return max( class.abilities.eye_beam.lastCast, last_eye_beam )
end )

spec:RegisterStateExpr( "extended_by_demonic", function ()
    return buff.metamorphosis.up and buff.metamorphosis.extended_by_demonic
end )

local activation_time = function ()
    return talent.quickened_sigils.enabled and 1 or 2
end

spec:RegisterStateExpr( "activation_time", activation_time )

local sigil_placed = function ()
    return sigils.flame > query_time
end

spec:RegisterStateExpr( "sigil_placed", sigil_placed )

spec:RegisterStateExpr( "meta_cd_multiplier", function ()
    return 1
end )


local furySpent = 0

local FURY = Enum.PowerType.Fury
local lastFury = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "FURY" and state.set_bonus.tier30_2pc > 0 then
        local current = UnitPower( "player", FURY )

        if current < lastFury - 3 then
            furySpent = ( furySpent + lastFury - current )
        end

        lastFury = current
    end
end )

spec:RegisterStateExpr( "fury_spent", function ()
    if set_bonus.tier30_2pc == 0 then return 0 end
    return furySpent
end )

local queued_frag_modifier = 0

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            -- Fracture:  Generate 2 frags.
            if spellID == 263642 then
                queue_fragments( 2 ) end

            -- Shear:  Generate 1 frag.
            if spellID == 203782 then
                queue_fragments( 1 ) end

            --[[ Spirit Bomb:  Up to 5 frags.
            if spellID == 247454 then
                local name, _, count = FindUnitBuffByID( "player", 203981 )
                if name then queue_fragments( -1 * count ) end
            end

            -- Soul Cleave:  Up to 2 frags.
            if spellID == 228477 then
                local name, _, count = FindUnitBuffByID( "player", 203981 )
                if name then queue_fragments( -1 * min( 2, count ) ) end
            end ]]

        -- We consumed or generated a fragment for real, so let's purge the real queue.
        elseif spellID == 203981 and fragments.real > 0 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
            fragments.real = fragments.real - 1

        elseif state.set_bonus.tier30_2pc > 0 and subtype == "SPELL_AURA_APPLIED" and spellID == 408737 then
            furySpent = max( 0, furySpent - 175 )

        end
    end
end, false )


-- Gear Sets
spec:RegisterGear( "tier29", 200345, 200347, 200342, 200344, 200346 )
spec:RegisterAura( "seething_chaos", {
    id = 394934,
    duration = 6,
    max_stack = 1
} )

-- Tier 30
spec:RegisterGear( "tier30", 202527, 202525, 202524, 202523, 202522 )
-- 2 pieces (Havoc) : Every 175 Fury you spend, gain Seething Fury, increasing your Agility by 8% for 6 sec.
-- TODO: Track Fury spent toward Seething Fury.  New expressions: seething_fury_threshold, seething_fury_spent, seething_fury_deficit.
spec:RegisterAura( "seething_fury", {
    id = 408737,
    duration = 6,
    max_stack = 1
} )
-- 4 pieces (Havoc) : Each time you gain Seething Fury, gain 15 Fury and the damage of your next Eye Beam is increased by 15%, stacking 5 times.
spec:RegisterAura( "seething_potential", {
    id = 408754,
    duration = 60,
    max_stack = 5
} )

spec:RegisterGear( "tier31", 207261, 207262, 207263, 207264, 207266 )
-- (2) Blade Dance automatically triggers Throw Glaive on your primary target for $s3% damage and each slash has a $s2% chance to Throw Glaive an enemy for $s1% damage.
-- (4) Throw Glaive reduces the remaining cooldown of The Hunt by ${$s1/1000}.1 sec, and The Hunt's damage over time effect lasts ${$s2/1000} sec longer.


local sigil_types = { "chains", "flame", "misery", "silence" }

spec:RegisterHook( "reset_precast", function ()
    last_metamorphosis = nil
    last_infernal_strike = nil

    for i, sigil in ipairs( sigil_types ) do
        local activation = ( action[ "sigil_of_" .. sigil ].lastCast or 0 ) + ( talent.quickened_sigils.enabled and 2 or 1 )
        if activation > now then sigils[ sigil ] = activation
        else sigils[ sigil ] = 0 end
    end

    last_darkness = 0
    last_metamorphosis = 0
    last_eye_beam = 0

    local rps = 0

    if equipped.convergence_of_fates then
        rps = rps + ( 3 / ( 60 / 4.35 ) )
    end

    if equipped.delusions_of_grandeur then
        -- From SimC model, 1/13/2018.
        local fps = 10.2 + ( talent.demonic.enabled and 1.2 or 0 )

        -- SimC uses base haste, we'll use current since we recalc each time.
        fps = fps / haste

        -- Chaos Strike accounts for most Fury expenditure.
        fps = fps + ( ( fps * 0.9 ) * 0.5 * ( 40 / 100 ) )

        rps = rps + ( fps / 30 ) * ( 1 )
    end

    meta_cd_multiplier = 1 / ( 1 + rps )

    fury_spent = nil
end )


spec:RegisterHook( "advance_end", function( time )
    if query_time - time < sigils.flame and query_time >= sigils.flame then
        -- SoF should've applied.
        applyDebuff( "target", "sigil_of_flame", debuff.sigil_of_flame.duration - ( query_time - sigils.flame ) )
        active_dot.sigil_of_flame = active_enemies
        sigils.flame = 0
    end
end )


spec:RegisterHook( "spend", function( amt, resource )
    if set_bonus.tier30_2pc == 0 or amt < 0 or resource ~= "fury" then return end

    fury_spent = fury_spent + amt
    if fury_spent > 175 then
        fury_spent = fury_spent - 175
        applyBuff( "seething_fury" )
        if set_bonus.tier30_4pc > 0 then
            gain( 15, "fury" )
            applyBuff( "seething_potential" )
        end
    end
end )




spec:RegisterGear( "tier19", 138375, 138376, 138377, 138378, 138379, 138380 )
spec:RegisterGear( "tier20", 147130, 147132, 147128, 147127, 147129, 147131 )
spec:RegisterGear( "tier21", 152121, 152123, 152119, 152118, 152120, 152122 )
    spec:RegisterAura( "havoc_t21_4pc", {
        id = 252165,
        duration = 8
    } )

spec:RegisterGear( "class", 139715, 139716, 139717, 139718, 139719, 139720, 139721, 139722 )

spec:RegisterGear( "convergence_of_fates", 140806 )

spec:RegisterGear( "achor_the_eternal_hunger", 137014 )
spec:RegisterGear( "anger_of_the_halfgiants", 137038 )
spec:RegisterGear( "cinidaria_the_symbiote", 133976 )
spec:RegisterGear( "delusions_of_grandeur", 144279 )
spec:RegisterGear( "kiljaedens_burning_wish", 144259 )
spec:RegisterGear( "loramus_thalipedes_sacrifice", 137022 )
spec:RegisterGear( "moarg_bionic_stabilizers", 137090 )
spec:RegisterGear( "prydaz_xavarics_magnum_opus", 132444 )
spec:RegisterGear( "raddons_cascading_eyes", 137061 )
spec:RegisterGear( "sephuzs_secret", 132452 )
spec:RegisterGear( "the_sentinels_eternal_refuge", 146669 )

spec:RegisterGear( "soul_of_the_slayer", 151639 )
spec:RegisterGear( "chaos_theory", 151798 )
spec:RegisterGear( "oblivions_embrace", 151799 )


do
    local wasWarned = false

    spec:RegisterEvent( "PLAYER_REGEN_DISABLED", function ()
        if state.talent.demon_blades.enabled and not state.settings.demon_blades_acknowledged and not wasWarned then
            Hekili:Notify( "|cFFFF0000WARNING!|r  Demon Blades cannot be forecasted.\nSee /hekili > Havoc for more information." )
            wasWarned = true
        end
    end )
end

-- SimC documentation reflects that there are still the following expressions, which appear unused:
-- greater_soul_fragments, lesser_soul_fragments, blade_dance_worth_using, death_sweep_worth_using
-- They are not implemented becuase that documentation is from mid-2016.


-- Abilities
spec:RegisterAbilities( {
    annihilation = {
        id = 201427,
        known = 162794,
        flash = { 201427, 162794 },
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = function () return 40 - buff.thirsting_blades.stack end,
        spendType = "fury",

        startsCombat = true,
        texture = 1303275,

        bind = "chaos_strike",
        buff = "metamorphosis",

        handler = function ()
            removeBuff( "thirsting_blades" )
            removeBuff( "inner_demon" )
            if azerite.thirsting_blades.enabled then applyBuff( "thirsting_blades", nil, 0 ) end

            if buff.chaotic_blades.up then gain( 20, "fury" ) end -- legendary
        end,
    },

    -- Strike $?a206416[your primary target for $<firstbloodDmg> Chaos damage and ][]all nearby enemies for $<baseDmg> Physical damage$?s320398[, and increase your chance to dodge by $193311s1% for $193311d.][. Deals reduced damage beyond $199552s1 targets.]
    blade_dance = {
        id = 188499,
        flash = { 188499, 210152 },
        cast = 0,
        cooldown = function() return ( level > 21 and 10 or 15 ) * haste end,
        gcd = "spell",
        school = "physical",

        spend = 35,
        spendType = "fury",

        startsCombat = true,

        bind = "death_sweep",
        nobuff = "metamorphosis",

        handler = function ()
            removeBuff( "restless_hunter" )
            applyBuff( "blade_dance" )
            setCooldown( "death_sweep", action.blade_dance.cooldown )
            if talent.chaos_theory.enabled then applyBuff( "chaos_theory" ) end
            if talent.cycle_of_hatred.enabled and cooldown.eye_beam.remains > 0 then reduceCooldown( "eye_beam", 0.5 * talent.cycle_of_hatred.rank ) end
            if set_bonus.tier31_2pc > 0 then spec.abilities.throw_glaive.handler() end
            if pvptalent.mortal_dance.enabled or talent.mortal_dance.enabled then applyDebuff( "target", "mortal_dance" ) end
        end,

        copy = "blade_dance1"
    },

    -- Increases your chance to dodge by $212800s2% and reduces all damage taken by $212800s3% for $212800d.
    blur = {
        id = 198589,
        cast = 0,
        cooldown = function () return 60 + ( conduit.fel_defender.mod * 0.001 ) end,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            applyBuff( "blur" )
        end,
    },

    -- Talent: Unleash an eruption of fel energy, dealing $s2 Chaos damage and stunning all nearby enemies for $d.$?s320412[    Each enemy stunned by Chaos Nova has a $s3% chance to generate a Lesser Soul Fragment.][]
    chaos_nova = {
        id = 179057,
        cast = 0,
        cooldown = 45,
        gcd = "spell",
        school = "chromatic",

        spend = 25,
        spendType = "fury",

        talent = "chaos_nova",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
            applyDebuff( "target", "chaos_nova" )
        end,
    },

    -- Slice your target for ${$222031s1+$199547s1} Chaos damage. Chaos Strike has a ${$min($197125h,100)}% chance to refund $193840s1 Fury.
    chaos_strike = {
        id = 162794,
        flash = { 162794, 201427 },
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "chaos",

        spend = function () return 40 - buff.thirsting_blades.stack end,
        spendType = "fury",

        startsCombat = true,

        bind = "annihilation",
        nobuff = "metamorphosis",

        cycle = function () return ( talent.burning_wound.enabled or legendary.burning_wound.enabled ) and "burning_wound" or nil end,

        handler = function ()
            removeBuff( "thirsting_blades" )
            removeBuff( "inner_demon" )
            if azerite.thirsting_blades.enabled then applyBuff( "thirsting_blades", nil, 0 ) end
            if talent.burning_wound.enabled then applyDebuff( "target", "burning_wound" ) end
            if buff.chaos_theory.up then
                gain( 20, "fury" )
                removeBuff( "chaos_theory" )
            end
            removeBuff( "chaotic_blades" )
            if talent.cycle_of_hatred.enabled and cooldown.eye_beam.remains > 0 then reduceCooldown( "eye_beam", 0.5 * talent.cycle_of_hatred.rank ) end
        end,
    },

    -- Talent: Consume $m1 beneficial Magic effect removing it from the target$?s320313[ and granting you $s2 Fury][].
    consume_magic = {
        id = 278326,
        cast = 0,
        cooldown = 10,
        gcd = "spell",
        school = "chromatic",

        startsCombat = false,
        talent = "consume_magic",

        toggle = "interrupts",

        usable = function () return buff.dispellable_magic.up end,
        handler = function ()
            removeBuff( "dispellable_magic" )
            if talent.swallowed_anger.enabled then gain( 20, "fury" ) end
        end,
    },

    -- Summons darkness around you in a$?a357419[ 12 yd][n 8 yd] radius, granting friendly targets a $209426s2% chance to avoid all damage from an attack. Lasts $d.; Chance to avoid damage increased by $s3% when not in a raid.
    darkness = {
        id = 196718,
        cast = 0,
        cooldown = 300,
        gcd = "spell",
        school = "physical",

        talent = "darkness",
        startsCombat = false,

        toggle = "defensives",

        handler = function ()
            last_darkness = query_time
            applyBuff( "darkness" )
        end,
    },


    death_sweep = {
        id = 210152,
        known = 188499,
        flash = { 210152, 188499 },
        cast = 0,
        cooldown = function() return 9 * haste end,
        gcd = "spell",

        spend = 35,
        spendType = "fury",

        startsCombat = true,
        texture = 1309099,

        bind = "blade_dance",
        buff = "metamorphosis",

        handler = function ()
            removeBuff( "restless_hunter" )
            applyBuff( "death_sweep" )
            setCooldown( "blade_dance", action.death_sweep.cooldown )

            if talent.cycle_of_hatred.enabled and cooldown.eye_beam.remains > 0 then reduceCooldown( "eye_beam", 0.5 * talent.cycle_of_hatred.rank ) end
            if set_bonus.tier31_2pc > 0 then spec.abilities.throw_glaive.handler() end
            if pvptalent.mortal_dance.enabled or talent.mortal_dance.enabled then
                applyDebuff( "target", "mortal_dance" )
            end
        end,
    },

    -- Quickly attack for $s2 Physical damage.    |cFFFFFFFFGenerates $?a258876[${$m3+$258876s3} to ${$M3+$258876s4}][$m3 to $M3] Fury.|r
    demons_bite = {
        id = 162243,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function () return talent.insatiable_hunger.enabled and -25 or -20 end,
        spendType = "fury",

        startsCombat = true,

        notalent = "demon_blades",
        cycle = function () return ( talent.burning_wound.enabled or legendary.burning_wound.enabled ) and "burning_wound" or nil end,

        handler = function ()
            if talent.burning_wound.enabled then applyDebuff( "target", "burning_wound" ) end
        end,
    },

    -- Interrupts the enemy's spellcasting and locks them from that school of magic for $d.|cFFFFFFFF$?s183782[    Generates $218903s1 Fury on a successful interrupt.][]|r
    disrupt = {
        id = 183752,
        cast = 0,
        cooldown = 15,
        gcd = "off",
        school = "chromatic",

        startsCombat = true,

        toggle = "interrupts",

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            interrupt()
            if talent.disrupting_fury.enabled then gain( 30, "fury" ) end
        end,
    },

    -- Covenant (Kyrian): Place a Kyrian Sigil at the target location that activates after $d.    Detonates to deal $307046s1 $@spelldesc395039 damage and shatter up to $s3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond $s1 targets.
    elysian_decree = {
        id = function() return talent.elysian_decree.enabled and 390163 or 306830 end,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "arcane",

        startsCombat = false,

        handler = function ()
            create_sigil( "elysian_decree" )
            if legendary.blind_faith.enabled then applyBuff( "blind_faith" ) end
        end,

        copy = { 390163, 306830 }
    },

    -- Talent: Slash all enemies in front of you for $s1 Chaos damage, and increase the damage your Chaos Strike and Blade Dance deal to them by $320338s1% for $320338d. Deals reduced damage beyond $s2 targets.
    essence_break = {
        id = 258860,
        cast = 0,
        cooldown = 40,
        gcd = "spell",
        school = "chromatic",

        talent = "essence_break",
        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "essence_break" )
            active_dot.essence_break = max( 1, active_enemies )
        end,

        copy = "dark_slash"
    },

    -- Talent: Blasts all enemies in front of you, $?s320415[dealing guaranteed critical strikes][] for up to $<dmg> Chaos damage over $d. Deals reduced damage beyond $s5 targets.$?s343311[    When Eye Beam finishes fully channeling, your Haste is increased by an additional $343312s1% for $343312d.][]
    eye_beam = {
        id = 198013,
        cast = function () return ( talent.blind_fury.enabled and 3 or 2 ) * haste end,
        channeled = true,
        cooldown = 40,
        gcd = "spell",
        school = "chromatic",

        spend = 30,
        spendType = "fury",

        talent = "eye_beam",
        startsCombat = true,

        start = function ()
            last_eye_beam = query_time

            applyBuff( "eye_beam" )
            removeBuff( "seething_potential" )

            if talent.demonic.enabled then
                if buff.metamorphosis.up then
                    buff.metamorphosis.duration = buff.metamorphosis.remains + 8
                    buff.metamorphosis.expires = buff.metamorphosis.expires + 8
                else
                    applyBuff( "metamorphosis", action.eye_beam.cast + 8 )
                    buff.metamorphosis.duration = action.eye_beam.cast + 8
                    stat.haste = stat.haste + 25

                    if talent.inner_demon.enabled then
                        applyBuff( "inner_demon" )
                    end
                end
            end

            if pvptalent.isolated_prey.enabled and active_enemies == 1 then
                applyDebuff( "target", "isolated_prey" )
            end

            -- This is likely repeated per tick but it's not worth the CPU overhead to model each tick.
            if legendary.agony_gaze.enabled and debuff.sinful_brand.up then
                debuff.sinful_brand.expires = debuff.sinful_brand.expires + 0.75
            end
        end,

        finish = function ()
            if talent.furious_gaze.enabled then applyBuff( "furious_gaze" ) end
        end,
    },

    -- Talent: Unleash a torrent of Fel energy over $d, inflicting ${(($d/$t1)+1)*$258926s1} Chaos damage to all enemies within $258926A1 yds. Deals reduced damage beyond $258926s2 targets.
    fel_barrage = {
        id = 258925,
        cast = 3,
        channeled = true,
        cooldown = 90,
        gcd = "spell",
        school = "chromatic",

        spend = 10,
        spendType = "fury",

        talent = "fel_barrage",
        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "fel_barrage" )
        end,
    },

    -- Impales the target for $s1 Chaos damage and stuns them for $d.
    fel_eruption = {
        id = 211881,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "chromatic",

        spend = 10,
        spendType = "fury",

        startsCombat = true,

        handler = function ()
            applyDebuff( "target", "fel_eruption" )
        end,
    },


    fel_lance = {
        id = 206966,
        cast = 1,
        cooldown = 0,
        gcd = "spell",

        pvptalent = "rain_from_above",
        buff = "rain_from_above",

        startsCombat = true,
    },

    -- Rush forward, incinerating anything in your path for $192611s1 Chaos damage.
    fel_rush = {
        id = 195072,
        cast = 0,
        charges = function() return talent.blazing_path.enabled and 2 or nil end,
        cooldown = function () return ( legendary.erratic_fel_core.enabled and 7 or 10 ) * ( 1 - 0.1 * talent.erratic_felheart.rank ) end,
        recharge = function () return talent.blazing_path.enabled and ( ( legendary.erratic_fel_core.enabled and 7 or 10 ) * ( 1 - 0.1 * talent.erratic_felheart.rank ) ) or nil end,
        gcd = "off",
        icd = 0.5,
        school = "physical",

        startsCombat = true,
        nodebuff = "rooted",

        readyTime = function ()
            if prev[1].fel_rush then return 3600 end
            if ( settings.fel_rush_charges or 1 ) == 0 then return end
            return ( ( 1 + ( settings.fel_rush_charges or 1 ) ) - cooldown.fel_rush.charges_fractional ) * cooldown.fel_rush.recharge
        end,

        handler = function ()
            setDistance( 5 )
            setCooldown( "global_cooldown", 0.25 )
            if buff.unbound_chaos.up then
                removeBuff( "unbound_chaos" )
                if talent.inertia.enabled then applyBuff( "inertia" ) end
            end
            if cooldown.vengeful_retreat.remains < 1 then setCooldown( "vengeful_retreat", 1 ) end
            if talent.momentum.enabled then applyBuff( "momentum" ) end
            if active_enemies == 1 and talent.isolated_prey.enabled then gain( 25, "fury" ) end
            if conduit.felfire_haste.enabled then applyBuff( "felfire_haste" ) end
        end,
    },

    -- Talent: Charge to your target and deal $213243sw2 $@spelldesc395020 damage.    $?s203513[Shear has a chance to reset the cooldown of Felblade.    |cFFFFFFFFGenerates $213243s3 Fury.|r]?a203555[Demon Blades has a chance to reset the cooldown of Felblade.    |cFFFFFFFFGenerates $213243s3 Fury.|r][Demon's Bite has a chance to reset the cooldown of Felblade.    |cFFFFFFFFGenerates $213243s3 Fury.|r]
    felblade = {
        id = 232893,
        cast = 0,
        cooldown = 15,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        spend = -40,
        spendType = "fury",

        talent = "felblade",
        startsCombat = true,
        nodebuff = "rooted",

        handler = function ()
            setDistance( 5 )
        end,
    },

    -- Talent: Launch two demonic glaives in a whirlwind of energy, causing ${14*$342857s1} Chaos damage over $d to all nearby enemies. Deals reduced damage beyond $s2 targets.
    glaive_tempest = {
        id = 342817,
        cast = 0,
        cooldown = 25,
        gcd = "spell",
        school = "magic",

        spend = 30,
        spendType = "fury",

        talent = "glaive_tempest",
        startsCombat = true,

        handler = function ()
            if talent.cycle_of_hatred.enabled and cooldown.eye_beam.remains > 0 then reduceCooldown( "eye_beam", 0.5 * talent.cycle_of_hatred.rank ) end
        end,
    },

    -- Engulf yourself in flames, $?a320364 [instantly causing $258921s1 $@spelldesc395020 damage to enemies within $258921A1 yards and ][]radiating ${$258922s1*$d} $@spelldesc395020 damage over $d.$?s320374[    |cFFFFFFFFGenerates $<havocTalentFury> Fury over $d.|r][]$?(s212612 & !s320374)[    |cFFFFFFFFGenerates $<havocFury> Fury.|r][]$?s212613[    |cFFFFFFFFGenerates $<vengeFury> Fury over $d.|r][]
    immolation_aura = {
        id = 258920,
        cast = 0,
        cooldown = 30,
        charges = function()
            if talent.a_fire_inside.enabled then return 2 end
        end,
        recharge = function()
            if talent.a_fire_inside.enabled then return 30 end
        end,
        gcd = "spell",
        school = "fire",

        spend = -20,
        spendType = "fury",

        startsCombat = true,

        handler = function ()
            applyBuff( "immolation_aura" )
            if talent.unbound_chaos.enabled then applyBuff( "unbound_chaos" ) end
            if talent.ragefire.enabled then applyBuff( "ragefire" ) end
        end,
    },

    -- Talent: Imprisons a demon, beast, or humanoid, incapacitating them for $d. Damage will cancel the effect. Limit 1.
    imprison = {
        id = 217832,
        cast = 0,
        gcd = "spell",
        school = "shadow",

        talent = "imprison",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "imprison" )
        end,
    },

    -- Leap into the air and land with explosive force, dealing $200166s2 Chaos damage to enemies within 8 yds, and stunning them for $200166d. Players are Dazed for $247121d instead.    Upon landing, you are transformed into a hellish demon for $162264d, $?s320645[immediately resetting the cooldown of your Eye Beam and Blade Dance abilities, ][]greatly empowering your Chaos Strike and Blade Dance abilities and gaining $162264s4% Haste$?(s235893&s204909)[, $162264s5% Versatility, and $162264s3% Leech]?(s235893&!s204909[ and $162264s5% Versatility]?(s204909&!s235893)[ and $162264s3% Leech][].
    metamorphosis = {
        id = 191427,
        cast = 0,
        cooldown = function () return ( 180 - ( talent.rush_of_chaos.enabled and 30 or 0 ) ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) - ( pvptalent.demonic_origins.enabled and 120 or 0 ) end,
        gcd = "spell",
        school = "physical",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "metamorphosis" )
            last_metamorphosis = query_time

            setDistance( 5 )

            if IsSpellKnownOrOverridesKnown( 317009 ) then
                applyDebuff( "target", "sinful_brand" )
                active_dot.sinful_brand = active_enemies
            end

            if level > 19 then stat.haste = stat.haste + 25 end

            if azerite.chaotic_transformation.enabled or talent.chaotic_transformation.enabled then
                setCooldown( "eye_beam", 0 )
                setCooldown( "blade_dance", 0 )
                setCooldown( "death_sweep", 0 )
            end
        end,

        meta = {
            adjusted_remains = function ()
                --[[ if level < 116 and ( equipped.delusions_of_grandeur or equipped.convergeance_of_fates ) then
                    return cooldown.metamorphosis.remains * meta_cd_multiplier
                end ]]

                return cooldown.metamorphosis.remains
            end
        }
    },

    -- Talent: Slip into the nether, increasing movement speed by $s3% and becoming immune to damage, but unable to attack. Lasts $d.
    netherwalk = {
        id = 196555,
        cast = 0,
        cooldown = 180,
        gcd = "spell",
        school = "physical",

        talent = "netherwalk",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            applyBuff( "netherwalk" )
            setCooldown( "global_cooldown", buff.netherwalk.remains )
        end,
    },


    rain_from_above = {
        id = 206803,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        pvptalent = "rain_from_above",

        startsCombat = false,
        texture = 1380371,

        handler = function ()
            applyBuff( "rain_from_above" )
        end,
    },


    reverse_magic = {
        id = 205604,
        cast = 0,
        cooldown = 60,
        gcd = "spell",

        -- toggle = "cooldowns",
        pvptalent = "reverse_magic",

        startsCombat = false,
        texture = 1380372,

        debuff = "reversible_magic",

        handler = function ()
            if debuff.reversible_magic.up then removeDebuff( "player", "reversible_magic" ) end
        end,
    },


    -- Talent: Place a Sigil of Flame at your location that activates after $d.    Deals $204598s1 Fire damage, and an additional $204598o3 Fire damage over $204598d, to all enemies affected by the sigil.    |CFFffffffGenerates $389787s1 Fury.|R
    sigil_of_flame = {
        id = function ()
            if talent.precise_sigils.enabled then return 389810 end
            if talent.concentrated_sigils.enabled then return 204513 end -- TODO: Remove?
            return 204596
        end,
        known = 204596,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        spend = -30,
        spendType = "fury",

        startsCombat = false,

        sigil_placed = function() return sigil_placed end,

        handler = function ()
            create_sigil( "flame" )
        end,

        copy = { 204596, 204513 }
    },

    -- Talent: Place a Sigil of Misery at your location that activates after $d.    Causes all enemies affected by the sigil to cower in fear. Targets are disoriented for $207685d.
    sigil_of_misery = {
        id = function ()
            if talent.precise_sigils.enabled then return 389813 end
            if talent.concentrated_sigils.enabled then return 202140 end
            return 207684
        end,
        known = 207684,
        cast = 0,
        cooldown = function () return 120 * ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) end,
        gcd = "spell",
        school = "physical",

        talent = "sigil_of_misery",
        startsCombat = false,

        toggle = function()
            if talent.misery_in_defeat.enabled then return "cooldowns" end
            return "interrupts"
        end,

        handler = function ()
            create_sigil( "misery" )
        end,

        copy = { 389813, 207684, 202140 }
    },

    -- Allows you to see enemies and treasures through physical barriers, as well as enemies that are stealthed and invisible. Lasts $d.    Attacking or taking damage disrupts the sight.
    spectral_sight = {
        id = 188501,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        startsCombat = false,

        handler = function ()
            applyBuff( "spectral_sight" )
        end,
    },

    -- Talent / Covenant (Night Fae): Charge to your target, striking them for $370966s1 $@spelldesc395042 damage, rooting them in place for $370970d and inflicting $370969o1 $@spelldesc395042 damage over $370969d to up to $370967s2 enemies in your path.     The pursuit invigorates your soul, healing you for $?c1[$370968s1%][$370968s2%] of the damage you deal to your Hunt target for $370966d.
    the_hunt = {
        id = function() return talent.the_hunt.enabled and 370965 or 323639 end,
        cast = 1,
        cooldown = function() return talent.the_hunt.enabled and 90 or 180 end,
        gcd = "spell",
        school = "nature",

        startsCombat = true,
        toggle = "cooldowns",
        nodebuff = "rooted",

        handler = function ()
            applyDebuff( "target", "the_hunt" )
            applyDebuff( "target", "the_hunt_dot" )
            setDistance( 5 )

            if talent.momentum.enabled then applyBuff( "momentum" ) end

            if legendary.blazing_slaughter.enabled then
                applyBuff( "immolation_aura" )
                applyBuff( "blazing_slaughter" )
            end
        end,

        copy = { 370965, 323639 }
    },

    -- Throw a demonic glaive at the target, dealing $337819s1 Physical damage. The glaive can ricochet to $?$s320386[${$337819x1-1} additional enemies][an additional enemy] within 10 yards.
    throw_glaive = {
        id = 185123,
        cast = 0,
        charges = function () return talent.champion_of_the_glaive.enabled and 2 or nil end,
        cooldown = 9,
        recharge = function () return talent.champion_of_the_glaive.enabled and 9 or nil end,
        gcd = "spell",
        school = "physical",

        spend = function() return talent.furious_throws.enabled and 25 or 0 end,
        spendType = "fury",

        startsCombat = true,

        readyTime = function ()
            if ( settings.throw_glaive_charges or 1 ) == 0 then return end
            return ( ( 1 + ( settings.throw_glaive_charges or 1 ) ) - cooldown.throw_glaive.charges_fractional ) * cooldown.throw_glaive.recharge
        end,

        handler = function ()
            if talent.burning_wound.enabled then applyDebuff( "target", "burning_wound" ) end
            if talent.champion_of_the_glaive.enabled then applyDebuff( "target", "master_of_the_glaive" ) end
            if talent.serrated_glaive.enabled then applyDebuff( "target", "serrated_glaive" ) end
            if talent.soulscar.enabled then applyDebuff( "target", "soulscar" ) end
            if set_bonus.tier31_4pc > 0 then reduceCooldown( "the_hunt", 2 ) end
        end,
    },

    -- Taunts the target to attack you.
    torment = {
        id = 185245,
        cast = 0,
        cooldown = 8,
        gcd = "off",
        school = "shadow",

        startsCombat = false,

        handler = function ()
            applyBuff( "torment" )
        end,
    },

    -- Talent: Remove all snares and vault away. Nearby enemies take $198813s2 Physical damage$?s320635[ and have their movement speed reduced by $198813s1% for $198813d][].$?a203551[    |cFFFFFFFFGenerates ${($203650s1/5)*$203650d} Fury over $203650d if you damage an enemy.|r][]
    vengeful_retreat = {
        id = 198793,
        cast = 0,
        cooldown = function () return talent.tactical_retreat.enabled and 20 or 25 end,
        gcd = "spell",

        startsCombat = true,
        nodebuff = "rooted",

        readyTime = function ()
            if settings.retreat_and_return == "fel_rush" or settings.retreat_and_return == "either" and not talent.felblade.enabled then
                return max( 0, cooldown.fel_rush.remains - 1 )
            end
            if settings.retreat_and_return == "felblade" and talent.felblade.enabled then
                return max( 0, cooldown.felblade.remains - 1 )
            end
            if settings.retreat_and_return == "either" then
                return max( 0, min( cooldown.felblade.remains, cooldown.fel_rush.remains ) - 1 )
            end
        end,

        handler = function ()
            applyBuff( "vengeful_retreat_movement" )
            if cooldown.fel_rush.remains < 1 then setCooldown( "fel_rush", 1 ) end
            -- 20231117: if target.within8 then
                applyDebuff( "target", "vengeful_retreat" )
                applyDebuff( "target", "vengeful_retreat_snare" )
                -- Assume that we retreated away.
                setDistance( 15 )
            --[[ else
                -- Assume that we retreated back.
                setDistance( 5 )
            end ]]
            if talent.tactical_retreat.enabled then applyBuff( "tactical_retreat" ) end
            if talent.momentum.enabled then applyBuff( "momentum" ) end
            if pvptalent.glimpse.enabled then applyBuff( "glimpse" ) end
        end,
    }
} )


spec:RegisterRanges( "chaos_strike", "felblade", "fel_eruption", "torment", "throw_glaive", "the_hunt" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    rangeChecker = "chaos_strike",
    rangeFilter = false,

    damage = true,
    damageExpiration = 8,

    potion = "phantom_fire",

    package = "Havoc",
} )


spec:RegisterSetting( "demon_blades_text", nil, {
    name = function()
        return strformat( "|cFFFF0000WARNING!|r  If using the %s talent, Fury gains from your auto-attacks will be forecast conservatively and updated when you "
            .. "actually gain resources.  This prediction can result in Fury spenders appearing abruptly since it was not guaranteed that you'd have enough Fury on "
            .. "your next melee swing.", Hekili:GetSpellLinkWithTexture( 203555 ) )
    end,
    type = "description",
    width = "full"
} )

spec:RegisterSetting( "demon_blades_acknowledged", false, {
    name = function()
        return strformat( "I understand that Fury generation from %s is unpredictable.", Hekili:GetSpellLinkWithTexture( 203555 ) )
    end,
    desc = function()
        return strformat( "If checked, %s will not trigger a warning when entering combat.", Hekili:GetSpellLinkWithTexture( 203555 ) )
    end,
    type = "toggle",
    width = "full",
    arg = function() return false end,
} )


-- Fel Rush
spec:RegisterSetting( "fel_rush_head", nil, {
    name = Hekili:GetSpellLinkWithTexture( 195072, 20 ),
    type = "header"
} )

spec:RegisterSetting( "fel_rush_warning", nil, {
    name = strformat( "The %s, %s, and/or %s talents require the use of %s.  If you do not want |W%s|w to be recommended to trigger these talents, you may want to "
        .. "consider a different talent build.\n\n"
        .. "You can reserve |W%s|w charges to ensure recommendations will always leave you with charge(s) available to use, but failing to use |W%s|w may ultimately "
        .. "cost you DPS.", Hekili:GetSpellLinkWithTexture( 388113 ), Hekili:GetSpellLinkWithTexture( 206476 ), Hekili:GetSpellLinkWithTexture( 347461 ),
        Hekili:GetSpellLinkWithTexture( 195072 ), spec.abilities.fel_rush.name, spec.abilities.fel_rush.name, spec.abilities.fel_rush.name ),
    type = "description",
    width = "full",
} )

spec:RegisterSetting( "fel_rush_charges", 0, {
    name = strformat( "Reserve %s Charges", Hekili:GetSpellLinkWithTexture( 195072 ) ),
    desc = strformat( "If set above zero, %s will not be recommended if it would leave you with fewer (fractional) charges.", Hekili:GetSpellLinkWithTexture( 195072 ) ),
    type = "range",
    min = 0,
    max = 2,
    step = 0.1,
    width = "full"
} )

spec:RegisterSetting( "fel_rush_filler", true, {
    name = strformat( "%s: Filler and Movement", Hekili:GetSpellLinkWithTexture( 195072 ) ),
    desc = strformat( "When enabled, %s may be recommended as a filler ability or for movement.\n\n"
        .. "These recommendations may occur with %s talented, when your other abilities are on cooldown, and/or because you are out of range of your target.",
        Hekili:GetSpellLinkWithTexture( 195072 ), Hekili:GetSpellLinkWithTexture( 203555 ) ),
    type = "toggle",
    width = "full"
} )

-- Throw Glaive
spec:RegisterSetting( "throw_glaive_head", nil, {
    name = Hekili:GetSpellLinkWithTexture( 185123, 20 ),
    type = "header"
} )

spec:RegisterSetting( "throw_glaive_charges_text", nil, {
    name = strformat( "You can reserve charges of %s to ensure that it is always available for %s or |W|T1385910:0::::64:64:4:60:4:60|t |cff71d5ff%s (affix)|r|w procs. "
        .. "If set to your maximum charges (2 with %s, 1 otherwise), |W%s|w will never be recommended.  Failing to use |W%s|w when appropriate may impact your DPS.",
        Hekili:GetSpellLinkWithTexture( 185123 ), Hekili:GetSpellLinkWithTexture( 391429 ), GetSpellInfo( 396363 ), Hekili:GetSpellLinkWithTexture( 389763 ),
        spec.abilities.throw_glaive.name, spec.abilities.throw_glaive.name ),
    type = "description",
    width = "full",
} )

spec:RegisterSetting( "throw_glaive_charges", 0, {
    name = strformat( "Reserve %s Charges", Hekili:GetSpellLinkWithTexture( 185123 ) ),
    desc = strformat( "If set above zero, %s will not be recommended if it would leave you with fewer (fractional) charges.", Hekili:GetSpellLinkWithTexture( 185123 ) ),
    type = "range",
    min = 0,
    max = 2,
    step = 0.1,
    width = "full"
} )

--[[ Retired 20240712:
spec:RegisterSetting( "footloose", true, {
    name = strformat( "%s before %s", Hekili:GetSpellLinkWithTexture( 185123 ) , Hekili:GetSpellLinkWithTexture( 188499 ) ),
    desc = strformat( "When enabled, %s may be recommended without having %s on cooldown.\n\n"
        .. "This setting deviates from the default SimulationCraft profile, but performs equally on average with higher top-end damage.",
        Hekili:GetSpellLinkWithTexture( 185123 ) , Hekili:GetSpellLinkWithTexture( 188499 ) ),
    type = "toggle",
    width = "full"
} ) ]]

-- Vengeful Retreat
spec:RegisterSetting( "retreat_head", nil, {
    name = Hekili:GetSpellLinkWithTexture( 198793, 20 ),
    type = "header"
} )

spec:RegisterSetting( "retreat_warning", nil, {
    name = strformat( "The %s, %s, and/or %s talents require the use of %s.  If you do not want |W%s|w to be recommended to trigger the benefit of these talents, you "
        .. "may want to consider a different talent build.", Hekili:GetSpellLinkWithTexture( 388108 ),Hekili:GetSpellLinkWithTexture( 206476 ),
        Hekili:GetSpellLinkWithTexture( 389688 ), Hekili:GetSpellLinkWithTexture( 198793 ), spec.abilities.vengeful_retreat.name ),
    type = "description",
    width = "full",
} )

spec:RegisterSetting( "retreat_and_return", "off", {
    name = strformat( "%s: %s and %s", Hekili:GetSpellLinkWithTexture( 198793 ), Hekili:GetSpellLinkWithTexture( 195072 ), Hekili:GetSpellLinkWithTexture( 232893 ) ),
    desc = function()
        return strformat( "When enabled, %s will |cFFFF0000NOT|r be recommended unless either %s or %s are available to quickly return to your current target.  This "
            .. "requirement applies to all |W%s|w and |W%s|w recommendations, regardless of talents.\n\n"
            .. "If |W%s|w is not talented, its cooldown will be ignored.\n\n"
            .. "This option does not guarantee that |W%s|w or |W%s|w will be the first recommendation after |W%s|w but will ensure that either/both are available immediately.",
            Hekili:GetSpellLinkWithTexture( 198793 ), Hekili:GetSpellLinkWithTexture( 195072 ), Hekili:GetSpellLinkWithTexture( 232893 ),
            spec.abilities.fel_rush.name, spec.abilities.vengeful_retreat.name, spec.abilities.felblade.name,
            spec.abilities.fel_rush.name, spec.abilities.felblade.name, spec.abilities.vengeful_retreat.name )
    end,
    type = "select",
    values = {
        off = "Disabled (default)",
        fel_rush = "Require " .. Hekili:GetSpellLinkWithTexture( 195072 ),
        felblade = "Require " .. Hekili:GetSpellLinkWithTexture( 232893 ),
        either = "Either " .. Hekili:GetSpellLinkWithTexture( 195072 ) .. " or " .. Hekili:GetSpellLinkWithTexture( 232893 )
    },
    width = "full"
} )

spec:RegisterSetting( "retreat_filler", false, {
    name = strformat( "%s: Filler and Movement", Hekili:GetSpellLinkWithTexture( 198793 ) ),
    desc = function()
        return strformat( "When enabled, %s may be recommended as a filler ability or for movement.\n\n"
            .. "These recommendations may occur with %s talented, when your other abilities being on cooldown, and/or because you are out of range of your target.",
            Hekili:GetSpellLinkWithTexture( 198793 ), Hekili:GetSpellLinkWithTexture( 203555 ) )
    end,
    type = "toggle",
    width = "full"
} )

spec:RegisterPack( "Havoc", 20231119, [[Hekili:D3Z2Ynksw(T4yIMsYUSAajzx1g2QJzQz3z7o2PNjw3Z8OqyjSnrjbAbKR2D4qF77jZKeYBNmri5QV8svwqYjp3VLjKZdM)tZVBvCvY8Fm0pCCqqWhhfgg(XWjZVR6LTjZVBB8Yph)i8hzXBG)9)o(58LKR(Y684vKNUmFxXs4o3LUz364Q08Spve)q187UFx66QVpB(9MNHXWJUnz58FC61xp)UNsxTkHn2KsyciJ9YGGldM8FSFXFpViz)IIK1jphNvTFrz6M9l2TLa1Yr7)H9)qZOhdJ(oS76FnC3)RDfvpLuSFrG)OqKXnfg3)mUA5tSr1Et)RVm4dWn3V4)nzt(ZjRiy1QDzROOvvrA2NtG)ijd(trGsEUP1p3ZXB2UFXdf5BOOQipt(bcOpqlEemAkhFLgO)e6a)ZRaSjFlbyaQKVFXp9ur(x2V4VToo9zG99L0QNY3by3FzD8k43)14SLW)rg9N(Rca8QldzO6FE9AYZ)yswsr6YgYRKb9hjeArYY8nBsYwr4e5p8WL)nfq5pMcQ)EobdAbqkmPRsEiE3AaiBlsZlsREr4bNEzqi9b)jolTwojW4(KW4NC5yF64)x0HTsCyWFNxuZaBFIWldVM(eF)dGorYAqYSRe4ZXzWd)VtYEm5HDKlMuvKedZFmrdCvAz89RjGFaOLUnTkHqAa9xTBt9J(tXlRsxgl(O3NKM9iq9XRHbMSA47H)(PKw6MiAwdpqmJF)FwwMqLm)f4X)mJzFFIeVwIoQvi)hujFjzCpgxSIoLDGU(scZ0650scCx8pYw)sn(9aGvjfFlrpNqIcyqC9uTmoJHBv7kYQvbarvjDYPEkEhmkIvEA860FjMPBwMuvbJampicyYmvBVayzzzomwQeKOVcINY81SF)plsE59T8B4p)xz3NVJqxF6P48s4cFFwAf80G6(7XP4nXVq41Fj(LsnglOz(aH6Zlt4cSYAzFj49zjGiJaNFf5aVbC5rK1aJy0wkiUpU6IB)2NJlsjkjVN4V82QNkssI2KMfvR8)(NJxVdUo7xGk5Y881RY)s2Ov7kOmOBd(G)RVYhqO5bS)h6WCZaru5lzlJkxNZN7G3N(Gac8uCzuzvC1O4SxIwTT0BWzTtU6nBrmdy(SBTG1dpguoueL1XkbuwNESYlNzHCqW44cqTpjQkVOaupii2d7kEze4olDzA1SGPMFSDLjrGdJnmcnEn4)8P4IOT7(LFzDs095)mbsn4WMKQ4n5fBbnX0YrfjBItZkVbb0PB2KZIIefd4U5bvM(y66O8hIEynGaKj7SK)VDPB3cQ0gWgIhMAWCl42Ry32QMlaqBj8F72aA2XpcHgeUHS88EsOMOvKinCfFQr1OhslkRIUFDE(kq(WUwvrmddl2LM1C1LeB7iWHuEXlE3V7HhKUYic361xbxmRxhvfxa0r5iHznywao2Tf42GJOii(qKoMYhRi48iI6BgC90lRXUvqAazShU88q)HEnsqHNQr(94YvJ2e)ZDdJsEbeejXBKzC0jmDP3z1)(Ey8RIiOv7uZFYM5Dq9eF(4HEskRJ9XXLVeNwXXLnCNUs4c)QENrLl8FoA32gPxkK7a4sUEe1)cga(0(eqeKPLybupDduO96FMWcugDpjo5qVg5LMpxVhsF8PQOAUXm7gzxm2)I6jO8P4Qki(4Qiq6c8Ixo)kFphMOHUgXmgH3kKs(5KL7QahkPBsUGlOg0W)awweLWVieCi9N(tq4OgoxA2Z5Fojk5NbSmlEDeHjZvKGa7rPzpabJZZiw7mrKegjlgu8Iq94YqIci)FWGnXJm4NH5llzdeUE2TJjoEzJzhlwCe1481xPZM01OwQd9gyZa51xxLqFsjrl7j7gQghrquGWltxL4POeEWilK4WAqTbUe4yHkG4MWNh6HIQIy6djaaGeWAKaYtZUTcmefQAeBAlV1Yu96RGl(NJiivqJgLNITM8V5kQJL4OG30ON2XcNrPZaF2JTnNQTsq0ZKzN18nvvkCKTJIWgPfU)SgHacoi4gwgnubqpuGLyMKl1nfHoqVhkMmWG6PD6(1xpZSVtusWBGbgmtZZWn4U4UYECqcMdHrVE6RV2LWLNho8anPmCzdQoS0fgr4Bq2CrRst6WmQi001gmJsO6YxmEgo26YBjI0gmaomgMtIYKwajkVD1Tzb(sicuw86i2pJwNwwXcvXHH7rsMFi4Zk0WzE46KCrRsmSBgloTXzzPpLYmtBMeHqWsssZtZTW8CUeqFUUeuWsLwb67jvcafkt8AZQfd3rN)OXD1vwOhrrE2uAcEqOzFpYDAbuGIu(WqXMNLxGTXKWyOqGORBZ6ftDP60iUA8kwN8hIhFr4PWeHz7Ibb(NZRN4LLRjexeKChKA3WHGJuQRZXqv3cSSldUbsNxiOhNYRXG2lOIZGNfcByYWFFWIbnNboOiVZAsUwm9ClvCCRaN0Bauy3QOKNPjOTAvjmtZgmX)sZsKZdMoKvMYmIi5RH8hjeBJKMNj1rlrng(TrKo4mv5aHWeYWBfmnpfv(LKeu)qTEZj0rv6sOiO4SsOiUnSMA4PHvUI11uxxsgT7N1Ez5xvxDYHAbrHcpHdBr86wq5g8uTOtKyZUdUPQrvxcNAc7sPIHZfapdNa6x6rjmHbkvNb1SMsQDTURiV(QbRWj(dns(CmTjpzR2xI(jRiybe(MBvuBdPEzwpcyfAWrbvdQiENN1uX8hnT2jRRoUC74rbN34x((8Ys5MbCZvI8ub7lch1yhGgy0g2LZ2zTzwY0cjQV3hxqkTwRwbXIXSKzEn7tyQnlejdXAV(gA0d9hHhtrLAmJRZZwMk6SGGCof4lpnFxz0JX)cp6P4LO6cLjvaQKTReYhpPyCq0KTlhc4TY19JcHRx7X0x1FqndLW36HXaKYKyZXiTYXGPHQW6r6YRfvLSzBszvFneTZk1eebDql6GsM1ONA3ZrxIw0HObMdOmTlS)MUK2pzU90q8oZOirQRnMT5gBbSUmyftmRxoBAaqWOPdn7Gxi9gRE(BZ)Qa0Uxdth1ZusbjRzJey7tiMYCdcR6KVzcNkepqtvTgD1DFlSAlGYGyt8r9FJhidqbBUjD1yxZfR3SAsgsL1KBxoq80V3nHeXPrJsdoqbhLI8g91)PgBilt2MeihXOSKLGaoU4flPNOyJD7e5axf5FjI5ruygkZ3TUCzCHxF8mQ3KRl(4qpPf8z2TdcVujwdfvkTzbBP5UJn5WvnuKgh2ql(u5wHhEx(yTkZVBDzu1NFBDBiR1LR6ir7yy30c9v5rWtqNDcYjTsu3oX3RpkKnR00b9u2nmoae73RA)9rzM5vwPMNsiZ(pFJXBbwsr0B3Q0Zxjjn7RUWlibKPtu(Uk6YehNvR3D4wvdobTn3sfEsqF4HOK0atXboYwN(n1GDtsxZMSEMDrWPiPMYsx39YQI0pN0nNl2HT70l1nnnQwiVM2KwFAwnPRoIWYW9mLuC9eJNxVja8oZKwr8QxapT81ZtoWFtvU0Yame2NuCaEtQon6YdLldgONYO7tRsEpl7UAZsP2AD)UImIi9leeI7Qv6In5JoHN2WQCLN7MbY(Y(UXODJsJ7FMj2Vm4cEZ46FLutfefDSUlKIPUnevTUHvSkfCxdQe0Mhpqh5iXnuMn7DevqQj0eutZNnxKdmiNRDTRGEwc4He4ajoyd60SRWa8skRFrAJVVug0egYCVxT1enYEhQhXeVY3yzrqHcDJeuPa7eaEep7Kgaxt1IH1BBHRhkEDOekvYeFR6CTpo2ATNHiLFAKFY2DenjhzUUWWPyBvc0ckH4fM7wPpVVNK1ZJvUSrelz9lLPXza(VSijPVDLASVLovBCEL3LJBIbLQOhlstEOkVy5t6lrcf24n(LLCh2YtnZYoJXXYMY7VrDNeNO2ytEZi8S24uf9XV5Bcc9VH02iXDLJ5WS4mntBnu8LmgFvOPvYovhf)GpjGN(vVjmeXxshq60I0vjqHhpa5XrKC9gJzcKWtaAh2b0UeulHk6aphqm2CWs(ar7whM8aICtDL4VZaTcvlWaZv5mXVlAjG7SLq0qqHLSAb3N8sE2Q(zEHBcHQgdKDJzHQK34oeVnuGXDJTqqWoq6RGzkpJUp)UpFZ9GflK0xwzsHo9pq0QESFh6d5nInb0etw42QKoPNO40EGDAx82MERaC8ob4lGxjRPI30DBI2MVKSF6JZEoDTWikHOcXBizHdbax(5iglfkaDDIWO2ex8zs(sRGqef7wdHFnrFnBLE7yizP6SWESXBgk4fgH2ybd7KRkeiOR8iQ(ZZxwCt1yDUkFp51xOK)slW0gB3IYQVNd3gGUm0Q7ag9fwbPD0Y765VZIO7Bcho0OtuOQbIu3cEh6DMrbhKbdPJ34pzh3BnIB6IoWNdDXNd)QXNnydCe85aVZmA8Cs5ZTCA(wT7cTff3EtBeFqJlaP6to)UNHGVWiAE9qNmky(DFjM2KGY53rFbXs3SnVOQ(n57DCY)DK3DlWXqb5f3QeI4UFr8UQ8nS3xmOegWfp5LW8)jndUf51P8t5zW0rV97KL2VJ9I29oZ6aWDhe8ZdDblZvnPaAZdcBMcpHyncS(6H1AvPPmjA3hd(tLHF(2eMbw9Rw676sEp)rQScoF8pw0TBYUrH4khkeDS6Jtt9sCPrVNuJZP9PSHtC9PHtCcRd7azhiZ8bZtcB5jFWS7iErAkEHu3blQoF(Ok0qtQTbW1JOY4qEdbUtWQNSTgynoKoHZ9d4Tbz9pP8c1q4NwO7gU9JB0vSUFq3nCnuTGn2HWy6gE3x47gYgY)2gl5GX8(cF3qUV8KUI59f(UHCF5jDfZ7l8Dd5(z13v8UFq3nC7NvFxX6(b9w4QvfWrQ)PI3NA47gYQT4Wo)GnGUHZhoKTat1Y9FNCcocP(JvFBOJSi)TrRSmjfpIESi0lln2DpAYcN6m2SfUi53UmYV93jmYwL2XUTToOOgQgfNA47gYQT6ZEudt(BoDq2cmpE)nJpc)nF9APRjP4r4VrONUAS7tUzsh838RlJ8i838vLroI0NCdDLU(7z37oOMsJykj85rsXws4oygtiWu6ZRKcuLU3bc3LcFoMuaR4TWG6eZqvCZEPavXB1XgeFuTnhbwTF5Luax7nWG4vMHyp7hfc0szV3RA(IteFhzvH11Nq(gcSKAHRceLBU8Hb3t2IlGaFHneMgpTDRIHatKoqY3p8kaKF5deAsBtvfqkVfw7ANnzpR0hvjf4kDVdeU9sdfbwhnThGSME9cjXlj7ecSJNKrtKRpyjcWEZWYJ2psaIJ9(r(NsVWHADK5yagQIDVtxhdKhTibdW9k(dgWuEHvvaQYDpuGFmC1tFFCWa5XlOW2lbNeE7jDtp8MIPN(sHXa5XlYSK)(PE7F8gWwq8VQ(HfrbWAF3rWa)BvYQHi5Qj(bWqbUsFBmqa7ymH5PqR(xfGF0CAmaR8Hlqb0k39qb(Bkl5imxgBRS6d1f6yKeLm8(qRaydJaDsqmW5VzSkqMF5dfCYVH0iwESBIcAeFfhDMUJr8vC8Mgyf2DsfGFnMKjizgFANeKC76PQig4obQItqsUPN9vadChTMngGpAn7jiUo7ROcX0UNDMddChzZnXa7XZnrCaj9kBRay534BmaJ4BOV8veWDK81PiAP9elNIOB2xWHes)iYsyQT2K3h(OXfgP5uO4Dh0sJO51uFLlpOD3HcTFQbVta33vjUJ4DFbFdGX3nnQNOkg4hggIewJVTxCcCJdPtaVVIY3yW7eW9vu2r8UVGVntV3sHj(gwWjWDRgEQ3bhVXG3jG7RkyhX7(cEAKGVNgeGaVj8ZSK9liFm3jU4NFh9ViNFG83ym4V)r6XryDuL5)L53TSifkkpnMCycA8LhJbxYHgyZlP28Q5)yyFHJ47SgaOkcKPlRFd21mJSdfjXPHpX8HiDijPmWXkyy(253vMu1(W89Sa5VwVd(pEHb6BaG9lE9191hxzMxkFPryAv53VWB)ckVr6UeMd7zXpHL2VygevIIWrSZisH7si1jhmPA6JfcfdjlQ((f3aQV7xC909lUSHOmLxY(fNtwlL9lgsF4g9utFzLjaT(fqrKuq(YwriRPhmzjIQTDBHIBN1qi67EazKx9BzcNDuJ8uAEmNKf)IdrLtJ9XOooCjK2v9L0uZHLtBYFte2TvsFmvE9RKEM0MpE3I4TPJMkcEF9bJ3dKvGuKk2QDIZIB3BrQh7umjG4wzIkcSVLP2V4cIuI(F8IwX24cuz9v(Y6hiq9gMLqhg5mU3AZhrvumtuzBGGGuBFqqhDiWRefFINHaeX2hq9wxdy1(wqPd5VMgaEFlvX3JIrT2tg7pbt)JQHP)T9Ilzh4YLbbg4FECi0mxVt5tJiHO)OlI24oRquT0KDZjI01)Edk6GK5xLoquY3kTh4Bp(S6NOFnXbYrL1(f36eXy0VHJnR2qGToD0VMOb1yjzm)tebLaXtKPHzg43c9MtzlDHOMuUr8PUnnDr3c4k)lmpfxXtwYUIM9qsk6kwWALOZjMEbJ1a5j1sxscZUr)1TvZSRRSZtbHma101f7La8Z6weplQymuWGCU1YZWnfd9Cv3YwJtR1PdsYfKa8UMIhxR0Ul6a1mx7OBkd30HLH(rrMdSvYzJAMODsJZSopoDzXA)cQ54m7eExdOIOOsDuGq)QPR2fX0bZzmRxZtL1L51mM)EmkqnX1Mkivoh0yLnxNgfFoPqaphk8yf2mff1(80t2Ie9RJOzt99e0epRNAUEMWXtHSEhgIERsGb0I5)Xq80oShlZF04(eJILjcZfmOamL(tMplAYQSeae)IsXMSalAOc1YO8z(y(DcFbRinRGqXwYdbBrceNCK4aIuvGE6a4MaQUP7aFun4OwDAwYSqEU0KS1y0f0zGyEEEBpsmVZnObNgkeTTj(krysMojP5Lu2drMk8iIP2PZ7BOg9VplY8fAydUqyIKRLoPz0HS((nUMrJf2GoYY8Om)Mc2fld1vioUxgLWz6F)gPuZaYgvqS7uOQtNZi9HInSPUrnQ5K9BlfF0erfuGBRI6qvo7qo0gvoDMbRr9ZbI9Bs4D9sRurHUmBl2KCkg236KCwQf66qzE4zTwpjg7shtts5ZwkIbxhmu4gC2lwWw6GMtvkSxj7Q3oXwA2Aw89X0QU7zwpDaDXgR9P)2WcXZxEGH2QrqaPpv0mEaIRVj(QojWR1tPEE3C2aZXrX2KVcoJmC(dkgc9gfytFgNNhHAwh(JMQeyURl(ajDqsEFNReHN86WYcmi3hzyIVQv6kPAqfXQfu0kIrxBLbDW9zxcrptVU1wJTUVcE4f04S)dsYujugxxmOnERTprDc6iigaFSgqgSJg3QCiwLVKMNtIRvgzAFIlOYRCelYUJPJzr6Sxt7gp)M4HOAcC6BUtIH4v3DKEvQlvsE5SAxsdd(zKvUeu7Ol(kEHGhVhWUkorusc6O9I85ojLQCS652kU2DGChOJAT2JDwFHXSqoueYyclt7UsbpM4y8mops1H(ulalJfKJYeUQvhCQn(GM4U4PeR(RtsKdfGhmAQHAo6zFLLIQ2ITiV(hIv47G5jdpSs6BiDSV787R7qesojAgWceoEkcbtfYrqy99hJxIGT0dSNCwnYBp6PNBvSz4nkMVbJeJyzR6y8O01nRKplueZ0qjXye1cn6fej0ke6SL9RS5rg7SmglVVcumXEIcAoTaNNtAXg5tSkkcHxuqncPU355AfhP)rtRx1fqAuCoU0gpIridOoEUulri53vIU7jTdR29y3XR1ZEsrfq8CTIYYXts3K4ZGV2(VqHTRCMVDTjRlq2y8K0fB0gYMOs3TYrV0KD380xw2OL(cEQSk7PQBzX39AqWJWWL68)iHIu(nuUnHEMGNX7rqp2COmX5sp8huhkhSFGjo2TQgpYvPgVgV9g(XUQU)c99rfItTdHF3MZkfD0podpHUTib0FB2AdEUsVrzETVZbM4Sb2gv(BWahh(RYKn2gKW4rBOfVKEYlpIXnhkUsmEkLDnuGRjhh3fwjA6UxMDg1srl88SSOo7PTZzBxUwZk5w9eINALjFVioWXtwOv32yj1IjiRTbPzSDtA(XREPjaT8URtpZAHdt1MwG45QbjUxkP3ABEKDJXe1SA4dIYczhgRgSOn(IqkgR24zJlLAMqhwTFyTZix6qgOh46747arPZO36vbAcEcmo0xoZTkJkMiUwV)APRywwofpVNVA2)tLFVrevIArmY46xlZW6dgra4JWvWdpPD482WuQfL60FBEpOOjM0XAqdlTubMomeTDM0wSuYmIhpyGd9(M0t0i(oLwOLKJo0mgRM3U3VS(stzP9imZjP0YCTq1YTWZuosTVRnhzoLx57S3w02Y0YIKAMeDXiCzmHWs6o)WZk7OBCRM50CF3iabB)hiDVq57v3EmZCTU(MLu3AaleHNRSqT08slIoCVtoAYB4ubZuJ7jd0Mpst3XHkhxRSD1D5BvV2g22swS90pnw8B4QnnUXKRdDeq(uHM6pejvh1tUzTnAYD1BUtTXPiSSFyKj4hQwjrFhCnRdVshEUZiCM8Qh1UyMtAfQQRkBRW(gEkoN5Qd3gS7(g4Hjg7SLMQjAb2XAgXVwL(lHxtRQ0NvmPJXH2kGC1jE1Tw7uuQ7d(I5YHmaI7NqNgzHtjep2gIw9i3fJY1hxpjBrvLWVk0FiH(Xkbr9aRgJ(1hx3PF14G6PZ16JvlTZzc64M9UfyVBs0nqeHfOwadNfy6qzgJnyEShUlk7UESAl3Wnrp2OR9Zy4fQxnBbPXPF070MdgH)P9s21ubc25Nngx0YdiN(SIlu(EyTdl(5n6RFOjzNYq05KTlBRd2zqhzNAJZW37aAXUwGNPX56aTwzuwoWUvgPYH2DtUGi8KwCBwhPHzYBNDRmANC4HAbvr5hI5zXcsO9ww2MNJryGPFJoCPkPmCAGtrkHTfofPul8OPiogFiqXOb)SPGQU00yfKCARfT2R0ZLh)zSLbv5vv)7CPX8T8D33qhr1UTP0WA01brhY1kmR7qZvVDhaydyd1dN1136I69To94fxq6vz4v8urehEyI4WFBiInAS)MjId0eXQhCl)AjIdzDyP5RwMPwS4(dlHZ4f0ucD7TLnsXVEcAFNjm1Td3iOKFibSv9tOKi3Tft1hL7GKKMOANyL(krOjQn1Aa30zOr60efOtNM4gUfzZCXiCtM4Dmq7l6IyhpJlwgNrsbROiHTLCXQV)yRmesxZwrM8YxBkBtzjsLB8T1L2Yw12w66o1goEx1t5qwQW8)j6vM)))d]] )