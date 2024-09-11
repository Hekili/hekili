-- DemonHunterHavoc.lua
-- July 2024

if UnitClassBase( "player" ) ~= "DEMONHUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat, wipe = string.format, table.wipe
local GetSpellInfo = ns.GetUnpackedSpellInfo

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
    chaos_nova               = { 90993, 179057, 1 }, -- Unleash an eruption of fel energy, dealing 2,956 Chaos damage and stunning all nearby enemies for 2 sec. Each enemy stunned by Chaos Nova has a 30% chance to generate a Lesser Soul Fragment.
    charred_warblades        = { 90948, 213010, 1 }, -- You heal for 3% of all Fire damage you deal.
    collective_anguish       = { 95152, 390152, 1 }, -- Eye Beam summons an allied Vengeance Demon Hunter who casts Fel Devastation, dealing 18,271 Fire damage over 2 sec. Dealing damage heals you for up to 1,641 health.
    consume_magic            = { 91006, 278326, 1 }, -- Consume 1 beneficial Magic effect removing it from the target.
    darkness                 = { 91002, 196718, 1 }, -- Summons darkness around you in an 8 yd radius, granting friendly targets a 15% chance to avoid all damage from an attack. Lasts 8 sec. Chance to avoid damage increased by 100% when not in a raid.
    demon_muzzle             = { 90928, 388111, 1 }, -- Enemies deal 8% reduced magic damage to you for 8 sec after being afflicted by one of your Sigils.
    demonic                  = { 91003, 213410, 1 }, -- Eye Beam causes you to enter demon form for 5 sec after it finishes dealing damage.
    disrupting_fury          = { 90937, 183782, 1 }, -- Disrupt generates 30 Fury on a successful interrupt.
    erratic_felheart         = { 90996, 391397, 2 }, -- The cooldown of Fel Rush is reduced by 10%.
    felblade                 = { 95150, 232893, 1 }, -- Charge to your target and deal 11,329 Chaos damage. Demon Blades has a chance to reset the cooldown of Felblade. Generates 40 Fury.
    felfire_haste            = { 90939, 389846, 1 }, -- Fel Rush increases your movement speed by 10% for 8 sec.
    flames_of_fury           = { 90949, 389694, 2 }, -- Sigil of Flame deals 35% increased damage and generates 1 additional Fury per target hit.
    illidari_knowledge       = { 90935, 389696, 1 }, -- Reduces magic damage taken by 5%.
    imprison                 = { 91007, 217832, 1 }, -- Imprisons a demon, beast, or humanoid, incapacitating them for 1 min. Damage will cancel the effect. Limit 1.
    improved_disrupt         = { 90938, 320361, 1 }, -- Increases the range of Disrupt to 10 yds.
    improved_sigil_of_misery = { 90945, 320418, 1 }, -- Reduces the cooldown of Sigil of Misery by 30 sec.
    infernal_armor           = { 91004, 320331, 2 }, -- Immolation Aura increases your armor by 20% and causes melee attackers to suffer 478 Chaos damage.
    internal_struggle        = { 90934, 393822, 1 }, -- Increases your mastery by 3.6%.
    live_by_the_glaive       = { 95151, 428607, 1 }, -- When you parry an attack or have one of your attacks parried, restore 2% of max health and 10 Fury. This effect may only occur once every 5 sec.
    long_night               = { 91001, 389781, 1 }, -- Increases the duration of Darkness by 3 sec.
    lost_in_darkness         = { 90947, 389849, 1 }, -- Spectral Sight lasts an additional 6 sec if disrupted by attacking or taking damage.
    master_of_the_glaive     = { 90994, 389763, 1 }, -- Throw Glaive has 2 charges and snares all enemies hit by 50% for 6 sec.
    pitch_black              = { 91001, 389783, 1 }, -- Reduces the cooldown of Darkness by 120 sec.
    precise_sigils           = { 95155, 389799, 1 }, -- All Sigils are now placed at your target's location.
    pursuit                  = { 90940, 320654, 1 }, -- Mastery increases your movement speed.
    quickened_sigils         = { 95149, 209281, 1 }, -- All Sigils activate 1 second faster.
    rush_of_chaos            = { 95148, 320421, 2 }, -- Reduces the cooldown of Metamorphosis by 30 sec.
    shattered_restoration    = { 90950, 389824, 1 }, -- The healing of Shattered Souls is increased by 10%.
    sigil_of_misery          = { 90946, 207684, 1 }, -- Place a Sigil of Misery at the target location that activates after 2 sec. Causes all enemies affected by the sigil to cower in fear, disorienting them for 15 sec.
    sigil_of_spite           = { 90997, 390163, 1 }, -- Place a demonic sigil at the target location that activates after 2 sec. Detonates to deal 44,825 Chaos damage and shatter up to 3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond 5 targets.
    soul_rending             = { 90936, 204909, 2 }, -- Leech increased by 6%. Gain an additional 6% leech while Metamorphosis is active.
    soul_sigils              = { 90929, 395446, 1 }, -- Afflicting an enemy with a Sigil generates 1 Lesser Soul Fragment.
    swallowed_anger          = { 91005, 320313, 1 }, -- Consume Magic generates 20 Fury when a beneficial Magic effect is successfully removed from the target.
    the_hunt                 = { 90927, 370965, 1 }, -- Charge to your target, striking them for 51,808 Chaos damage, rooting them in place for 1.5 sec and inflicting 45,412 Chaos damage over 6 sec to up to 5 enemies in your path. The pursuit invigorates your soul, healing you for 10% of the damage you deal to your Hunt target for 20 sec.
    unrestrained_fury        = { 90941, 320770, 1 }, -- Increases maximum Fury by 20.
    vengeful_bonds           = { 90930, 320635, 1 }, -- Vengeful Retreat reduces the movement speed of all nearby enemies by 70% for 3 sec.
    vengeful_retreat         = { 90942, 198793, 1 }, -- Remove all snares and vault away. Nearby enemies take 1,229 Physical damage.
    will_of_the_illidari     = { 91000, 389695, 1 }, -- Increases maximum health by 5%.

    -- Havoc
    a_fire_inside            = { 95143, 427775, 1 }, -- Immolation Aura has 1 additional charge and 25% chance to refund a charge when used. You can have multiple Immolation Auras active at a time.
    accelerated_blade        = { 91011, 391275, 1 }, -- Throw Glaive deals 60% increased damage, reduced by 30% for each previous enemy hit.
    any_means_necessary      = { 90919, 388114, 1 }, -- Mastery: Demonic Presence now also causes your Arcane, Fire, Frost, Nature, and Shadow damage to be dealt as Chaos instead, and increases that damage by 28.9%.
    blind_fury               = { 91026, 203550, 2 }, -- Eye Beam generates 40 Fury every second, and its damage and duration are increased by 10%.
    burning_hatred           = { 90923, 320374, 1 }, -- Immolation Aura generates an additional 40 Fury over 10 sec.
    burning_wound            = { 90917, 391189, 1 }, -- Demon Blades and Throw Glaive leave open wounds on your enemies, dealing 8,140 Chaos damage over 15 sec and increasing damage taken from your Immolation Aura by 40%. May be applied to up to 3 targets.
    chaos_theory             = { 91035, 389687, 1 }, -- Blade Dance causes your next Chaos Strike within 8 sec to have a 14-30% increased critical strike chance and will always refund Fury.
    chaotic_disposition      = { 95147, 428492, 2 }, -- Your Chaos damage has a 7.77% chance to be increased by 17%, occurring up to 3 total times.
    chaotic_transformation   = { 90922, 388112, 1 }, -- When you activate Metamorphosis, the cooldowns of Blade Dance and Eye Beam are immediately reset.
    critical_chaos           = { 91028, 320413, 1 }, -- The chance that Chaos Strike will refund 20 Fury is increased by 30% of your critical strike chance.
    cycle_of_hatred          = { 91032, 258887, 2 }, -- Blade Dance, Chaos Strike, and Glaive Tempest reduce the cooldown of Eye Beam by 0.5 sec.
    dancing_with_fate        = { 91015, 389978, 2 }, -- The final slash of Blade Dance deals an additional 25% damage.
    dash_of_chaos            = { 93014, 427794, 1 }, -- For 2 sec after using Fel Rush, activating it again will dash back towards your initial location.
    deflecting_dance         = { 93015, 427776, 1 }, -- You deflect incoming attacks while Blade Dancing, absorbing damage up to 15% of your maximum health.
    demon_blades             = { 91019, 203555, 1 }, -- Your auto attacks deal an additional 1,719 Chaos damage and generate 7-12 Fury.
    demon_hide               = { 91017, 428241, 1 }, -- Magical damage increased by 3%, and Physical damage taken reduced by 5%.
    desperate_instincts      = { 93016, 205411, 1 }, -- Blur now reduces damage taken by an additional 10%. Additionally, you automatically trigger Blur with 50% reduced cooldown and duration when you fall below 35% health. This effect can only occur when Blur is not on cooldown.
    essence_break            = { 91033, 258860, 1 }, -- Slash all enemies in front of you for 30,395 Chaos damage, and increase the damage your Chaos Strike and Blade Dance deal to them by 80% for 4 sec. Deals reduced damage beyond 8 targets.
    eye_beam                 = { 91018, 198013, 1 }, -- Blasts all enemies in front of you, dealing guaranteed critical strikes for up to 70,852 Chaos damage over 1.9 sec. Deals reduced damage beyond 5 targets. When Eye Beam finishes fully channeling, your Haste is increased by an additional 10% for 10 sec.
    fel_barrage              = { 95144, 258925, 1 }, -- Unleash a torrent of Fel energy, rapidly consuming Fury to inflict 3,755 Chaos damage to all enemies within 12 yds, lasting 8 sec or until Fury is depleted. Deals reduced damage beyond 5 targets.
    first_blood              = { 90925, 206416, 1 }, -- Blade Dance deals 24,200 Chaos damage to the first target struck.
    furious_gaze             = { 91025, 343311, 1 }, -- When Eye Beam finishes fully channeling, your Haste is increased by an additional 10% for 10 sec.
    furious_throws           = { 93013, 393029, 1 }, -- Throw Glaive now costs 25 Fury and throws a second glaive at the target.
    glaive_tempest           = { 91035, 342817, 1 }, -- Launch two demonic glaives in a whirlwind of energy, causing 32,341 Chaos damage over 3 sec to all nearby enemies. Deals reduced damage beyond 8 targets.
    growing_inferno          = { 90916, 390158, 1 }, -- Immolation Aura's damage increases by 10% each time it deals damage.
    improved_chaos_strike    = { 91030, 343206, 1 }, -- Chaos Strike damage increased by 10%.
    improved_fel_rush        = { 93014, 343017, 1 }, -- Fel Rush damage increased by 20%.
    inertia                  = { 91021, 427640, 1 }, -- When empowered by Unbound Chaos, Fel Rush increases your damage done by 18% for 5 sec.
    initiative               = { 91027, 388108, 1 }, -- Damaging an enemy before they damage you increases your critical strike chance by 10% for 5 sec. Vengeful Retreat refreshes your potential to trigger this effect on any enemies you are in combat with.
    inner_demon              = { 91024, 389693, 1 }, -- Entering demon form causes your next Chaos Strike to unleash your inner demon, causing it to crash into your target and deal 22,918 Chaos damage to all nearby enemies. Deals reduced damage beyond 5 targets.
    insatiable_hunger        = { 91019, 258876, 1 }, -- Demon's Bite deals 50% more damage and generates 5 to 10 additional Fury.
    isolated_prey            = { 91036, 388113, 1 }, -- Chaos Nova, Eye Beam, and Immolation Aura gain bonuses when striking 1 target.  Chaos Nova: Stun duration increased by 2 sec.  Eye Beam: Deals 30% increased damage.  Immolation Aura: Always critically strikes.
    know_your_enemy          = { 91034, 388118, 2 }, -- Gain critical strike damage equal to 40% of your critical strike chance.
    looks_can_kill           = { 90921, 320415, 1 }, -- Eye Beam deals guaranteed critical strikes.
    momentum                 = { 91021, 206476, 1 }, -- Fel Rush, The Hunt, and Vengeful Retreat increase your damage done by 6% for 6 sec, up to a maximum of 30 sec.
    mortal_dance             = { 93015, 328725, 1 }, -- Blade Dance now reduces targets' healing received by 50% for 6 sec.
    netherwalk               = { 93016, 196555, 1 }, -- Slip into the nether, increasing movement speed by 100% and becoming immune to damage, but unable to attack. Lasts 6 sec.
    ragefire                 = { 90918, 388107, 1 }, -- Each time Immolation Aura deals damage, 30% of the damage dealt by up to 3 critical strikes is gathered as Ragefire. When Immolation Aura expires you explode, dealing all stored Ragefire damage to nearby enemies.
    relentless_onslaught     = { 91012, 389977, 1 }, -- Chaos Strike has a 10% chance to trigger a second Chaos Strike.
    restless_hunter          = { 91024, 390142, 1 }, -- Leaving demon form grants a charge of Fel Rush and increases the damage of your next Blade Dance by 50%.
    scars_of_suffering       = { 90914, 428232, 1 }, -- Increases Versatility by 4% and reduces threat generated by 8%.
    serrated_glaive          = { 91013, 390154, 1 }, -- Enemies hit by Chaos Strike or Throw Glaive take 15% increased damage from Chaos Strike and Throw Glaive for 15 sec.
    shattered_destiny        = { 91031, 388116, 1 }, -- The duration of your active demon form is extended by 0.1 sec per 12 Fury spent.
    soulscar                 = { 91012, 388106, 1 }, -- Throw Glaive causes targets to take an additional 100% of damage dealt as Chaos over 6 sec.
    tactical_retreat         = { 91022, 389688, 1 }, -- Vengeful Retreat has a 5 sec reduced cooldown and generates 80 Fury over 10 sec.
    trail_of_ruin            = { 90915, 258881, 1 }, -- The final slash of Blade Dance inflicts an additional 7,742 Chaos damage over 4 sec.
    unbound_chaos            = { 91020, 347461, 1 }, -- Activating Immolation Aura increases the damage of your next Fel Rush by 250%. Lasts 12 sec.

    -- Aldrachi Reaver
    aldrachi_tactics         = { 94914, 442683, 1 }, -- The second enhanced ability in a pattern shatters an additional Soul Fragment.
    army_unto_oneself        = { 94896, 442714, 1 }, -- Felblade surrounds you with a Blade Ward, reducing damage taken by 10% for 5 sec.
    art_of_the_glaive        = { 94915, 442290, 1, "aldrachi_reaver" }, -- Consuming 6 Soul Fragments or casting The Hunt converts your next Throw Glaive into Reaver's Glaive.  Reaver's Glaive:
    evasive_action           = { 94911, 444926, 1 }, -- Vengeful Retreat can be cast a second time within 3 sec.
    fury_of_the_aldrachi     = { 94898, 442718, 1 }, -- When enhanced by Reaver's Glaive, Blade Dance casts 3 additional glaive slashes to nearby targets. If cast after Chaos Strike, cast 6 slashes instead.
    incisive_blade           = { 94895, 442492, 1 }, -- Chaos Strike deals 15% increased damage.
    incorruptible_spirit     = { 94896, 442736, 1 }, -- Consuming a Soul Fragment also heals you for an additional 15% over time.
    keen_engagement          = { 94910, 442497, 1 }, -- Reaver's Glaive generates 20 Fury.
    preemptive_strike        = { 94910, 444997, 1 }, -- Throw Glaive deals 3,124 damage to enemies near its initial target.
    reavers_mark             = { 94903, 442679, 1 }, -- When enhanced by Reaver's Glaive, Chaos Strike applies Reaver's Mark, which causes the target to take 12% increased damage for 20 sec. If cast after Blade Dance, Reaver's Mark is increased to 24%.
    thrill_of_the_fight      = { 94919, 442686, 1 }, -- After consuming both enhancements, gain Thrill of the Fight, increasing your attack speed by 15% for 20 sec and your damage and healing by 20% for 10 sec.
    unhindered_assault       = { 94911, 444931, 1 }, -- Vengeful Retreat resets the cooldown of Felblade.
    warblades_hunger         = { 94906, 442502, 1 }, -- Consuming a Soul Fragment causes your next Chaos Strike to deal 1,734 additional damage. Felblade consumes up to 5 nearby Soul Fragments.
    wounded_quarry           = { 94897, 442806, 1 }, -- While Reaver's Mark is on your target, melee attacks strike with an additional glaive slash for 867 Physical damage and have a chance to shatter a soul.

    -- Fel-Scarred
    burning_blades           = { 94905, 452408, 1 }, -- Your blades burn with Fel energy, causing your Chaos Strike, Throw Glaive, and auto-attacks to deal an additional 10% damage as Fire over 6 sec.
    demonic_intensity        = { 94901, 452415, 1 }, -- Activating Metamorphosis greatly empowers Eye Beam, Immolation Aura, and Sigil of Flame. Demonsurge damage is increased by 10% for each time it previously triggered while your demon form is active.
    demonsurge               = { 94917, 452402, 1, "felscarred" }, -- Metamorphosis now also causes Demon Blades to generate 5 additional Fury. While demon form is active, the first cast of each empowered ability induces a Demonsurge, causing you to explode with Fel energy, dealing 12,158 Fire damage to nearby enemies.
    enduring_torment         = { 94916, 452410, 1 }, -- The effects of your demon form persist outside of it in a weakened state, increasing Chaos Strike and Blade Dance damage by 5%, and Haste by 3%.
    flamebound               = { 94902, 452413, 1 }, -- Immolation Aura has 2 yd increased radius and 30% increased critical strike damage bonus.
    focused_hatred           = { 94918, 452405, 1 }, -- Demonsurge deals 35% increased damage when it strikes a single target.
    improved_soul_rending    = { 94899, 452407, 1 }, -- Leech granted by Soul Rending increased by 2% and an additional 2% while Metamorphosis is active.
    monster_rising           = { 94909, 452414, 1 }, -- Agility increased by 5% while not in demon form.
    pursuit_of_angriness     = { 94913, 452404, 1 }, -- Movement speed increased by 1% per 10 Fury.
    set_fire_to_the_pain     = { 94899, 452406, 1 }, -- 5% of all non-Fire damage taken is instead taken as Fire damage over 6 sec. Fire damage taken reduced by 10%.
    student_of_suffering     = { 94902, 452412, 1 }, -- Sigil of Flame applies Student of Suffering to you, increasing Mastery by 14.4% and granting 5 Fury every 2 sec, for 8 sec.
    untethered_fury          = { 94904, 452411, 1 }, -- Maximum Fury increased by 50.
    violent_transformation   = { 94912, 452409, 1 }, -- When you activate Metamorphosis, the cooldowns of your Sigil of Flame and Immolation Aura are immediately reset.
    wave_of_debilitation     = { 94913, 452403, 1 }, -- Chaos Nova slows enemies by 60% and reduces attack and cast speed 15% for 5 sec after its stun fades.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    blood_moon        = 5433, -- (355995)
    chaotic_imprint   = 809 , -- (356510)
    cleansed_by_flame = 805 , -- (205625)
    cover_of_darkness = 1206, -- (357419)
    detainment        = 812 , -- (205596)
    glimpse           = 813 , -- (354489)
    rain_from_above   = 811 , -- (206803) You fly into the air out of harm's way. While floating, you gain access to Fel Lance allowing you to deal damage to enemies below.
    reverse_magic     = 806 , -- (205604) Removes all harmful magical effects from yourself and all nearby allies within 10 yards, and sends them back to their original caster if possible.
    sigil_mastery     = 5523, -- (211489)
    unending_hatred   = 1218, -- (213480)
} )


-- Auras
spec:RegisterAuras( {
    -- $w1 Soul Fragments consumed. At $?a212612[$442290s1~][$442290s2~], Reaver's Glaive is available to cast.
    art_of_the_glaive = {
        id = 444661,
        duration = 30.0,
        max_stack = 6,
    },
    -- Dodge chance increased by $s2%.
    -- https://wowhead.com/beta/spell=188499
    blade_dance = {
        id = 188499,
        duration = 1,
        max_stack = 1
    },
    -- Damage taken reduced by $s1%.
    blade_ward = {
        id = 442715,
        duration = 5.0,
        max_stack = 1,
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
    demonsurge = {
        id = 452416,
        duration = 12,
        max_stack = 10
    },
    demonsurge_demonic = {
        id = 452435,
        duration = 3600,
        max_stack = 1
    },
    demonsurge_hardcast = {
        id = 452489,
        duration = 3600,
        max_stack = 1
    },
    demonsurge_soul_sunder = {

    },
    demonsurge_spirit_burst = {

    },
    demonsurge_sigil_of_doom = {

    },
    demonsurge_consuming_fire = {

    },
    demonsurge_fel_desolation = {

    },
    demonsurge_abyssal_gaze = {

    },
    demonsurge_annihilation = {

    },
    demonsurge_death_sweep = {

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
    -- Vengeful Retreat may be cast again.
    evasive_action = {
        id = 444929,
        duration = 3.0,
        max_stack = 1,
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
    initiative_tracker = {
        duration = 3600,
        max_stack = 1
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
    -- Agility increased by $w1%.
    monster_rising = {
        id = 452550,
        duration = 3600,
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
    -- $w3
    pursuit_of_angriness = {
        id = 452404,
        duration = 0.0,
        tick_time = 1.0,
        max_stack = 1,
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
    reavers_glaive = {
        id = 444686,
        duration = 15,
        max_stack = 2
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
        max_stack = 1,
    },
    -- Taking $w1 Fire damage every $t1 sec.
    set_fire_to_the_pain = {
        id = 453286,
        duration = 6.0,
        tick_time = 1.0,
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
        duration = function() return 15 + talent.extended_sigils.rank + ( talent.precise_sigils.enabled and 2 or 0 ) end,
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
    -- Mastery increased by ${$w1*$mas}.1%. ; Generating $453236s1 Fury every $t2 sec.
    student_of_suffering = {
        id = 453239,
        duration = 8.0,
        max_stack = 1,
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
    -- Attack Speed increased by $w1%
    thrill_of_the_fight = {
        id = 442695,
        duration = 20.0,
        max_stack = 1,
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
        max_stack = 1,
        copy = "inertia_trigger" -- Hmm.
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
    -- Your next $?a212612[Chaos Strike]?s263642[Fracture][Shear] will deal $442507s1 additional Physical damage.
    warblades_hunger = {
        id = 442503,
        duration = 30.0,
        max_stack = 1,
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
    sigils[ sigil ] = query_time + activation_time

    local effect = sigil == "elysian_dcreee" and "elysian_decree" or ( "sigil_of_" .. sigil )
    applyDebuff( "target", effect )
    debuff[ effect ].applied = debuff[ effect ].applied + 1
    debuff[ effect ].expires = debuff[ effect ].expires + 1
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
local initiative_actual, initiative_virtual = {}, {}

local death_events = {
    UNIT_DIED               = true,
    UNIT_DESTROYED          = true,
    UNIT_DISSIPATES         = true,
    PARTY_KILL              = true,
    SPELL_INSTAKILL         = true,
}

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if subtype == "SPELL_CAST_SUCCESS" then
            -- Fracture:  Generate 2 frags.
            if spellID == 263642 then
                queue_fragments( 2 )
            end

            -- Shear:  Generate 1 frag.
            if spellID == 203782 then
                queue_fragments( 1 )
            end

            if spellID == 198793 and talent.initiative.enabled then
                wipe( initiative_actual )
            end

        elseif spellID == 203981 and fragments.real > 0 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
            fragments.real = fragments.real - 1

        elseif state.set_bonus.tier30_2pc > 0 and subtype == "SPELL_AURA_APPLIED" and spellID == 408737 then
            furySpent = max( 0, furySpent - 175 )

        elseif state.talent.initiative.enabled and subtype == "SPELL_DAMAGE" then
            initiative_actual[ destGUID ] = true
        end
    elseif destGUID == GUID and ( subtype == "SPELL_DAMAGE" or subtype == "SPELL_PERIODIC_DAMAGE" ) then
        initiative_actual[ sourceGUID ] = true

    elseif death_events[ subtype ] then
        initiative_actual[ destGUID ] = nil
    end
end, false )

spec:RegisterEvent( "PLAYER_REGEN_ENABLED", function()
    wipe( initiative_actual )
end )

spec:RegisterHook( "UNIT_ELIMINATED", function( id )
    initiative_actual[ id ] = nil
end )

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

spec:RegisterGear( "tier31", 207261, 207262, 207263, 207264, 207266, 217228, 217230, 217226, 217227, 217229 )
-- (2) Blade Dance automatically triggers Throw Glaive on your primary target for $s3% damage and each slash has a $s2% chance to Throw Glaive an enemy for $s1% damage.
-- (4) Throw Glaive reduces the remaining cooldown of The Hunt by ${$s1/1000}.1 sec, and The Hunt's damage over time effect lasts ${$s2/1000} sec longer.


spec:RegisterGear( "tww1", 212068, 212066, 212065, 212064, 212063 )
spec:RegisterAura( "blade_rhapsody", {
    id = 454628,
    duration = 12,
    max_stack = 1
} )



local sigil_types = {
    chains         = "sigil_of_chains" ,
    flame          = "sigil_of_flame"  ,
    misery         = "sigil_of_misery" ,
    silence        = "sigil_of_silence",
    spite          = "sigil_of_spite",
    elysian_decree = "elysian_decree"
}

spec:RegisterHook( "reset_precast", function ()
    last_metamorphosis = nil
    last_infernal_strike = nil

    wipe( initiative_virtual )
    active_dot.initiative_tracker = 0

    for k, v in pairs( initiative_actual ) do
        initiative_virtual[ k ] = v

        if k == target.unit then
            applyDebuff( "target", "initiative_tracker" )
        else
            active_dot.initiative_tracker = active_dot.initiative_tracker + 1
        end
    end

    -- Unbound Chaos effect remains even after the buff falls off, so we'll reapply the buff whenever Immo Aura has been used more recently than Fel Rush.
    if talent.unbound_chaos.enabled and buff.unbound_chaos.remains < gcd.max and action.immolation_aura.lastCast > action.fel_rush.lastCast then
        applyBuff( "unbound_chaos", nil, gcd.max )
    end

    for s, a in ipairs( sigil_types ) do
        local activation = ( action[ a ].lastCast or 0 ) + ( talent.quickened_sigils.enabled and 2 or 1 )
        if activation > now then sigils[ s ] = activation
        else sigils[ s ] = 0 end
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

    if IsActiveSpell( 442294 ) then applyBuff( "reavers_glaive" ) end

    fury_spent = nil
end )


spec:RegisterHook( "runHandler", function( action )
    local ability = class.abilities[ action ]

    if ability.startsCombat and not debuff.initiative_tracker.up then
        applyBuff( "initiative" )
        applyDebuff( "target", "initiative_tracker" )
    end
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
            if buff.rending_strike.up then applyDebuff( "target", "rending_strike" ) end
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

        spend = function() return 35 * ( buff.blade_rhapsody.up and 0.5 or 1 ) end,
        spendType = "fury",

        startsCombat = true,

        bind = "death_sweep",
        nobuff = "metamorphosis",

        handler = function ()
            applyBuff( "blade_dance" )
            removeBuff( "blade_rhapsody")
            removeBuff( "restless_hunter" )
            removeBuff( "glaive_flurry" )
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
            if buff.rending_strike.up then
                applyDebuff( "target", "reavers_mark" )
                removeBuff( "rending_strike" )
            end
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

        spend = function() return 35 * ( buff.blade_rhapsody.up and 0.5 or 1 ) end,
        spendType = "fury",

        startsCombat = true,
        texture = 1309099,

        bind = "blade_dance",
        buff = "metamorphosis",

        handler = function ()
            applyBuff( "death_sweep" )
            removeBuff( "restless_hunter" )
            removeBuff( "blade_rhapsody" )
            setCooldown( "blade_dance", action.death_sweep.cooldown )
            if buff.rending_strike.up then
                applyDebuff( "target", "reavers_mark" )
                removeBuff( "rending_strike" )
            end

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

    -- Blasts all enemies in front of you,$?s320415[ dealing guaranteed critical strikes][] for up to $<dmg> Chaos damage over $d. Deals reduced damage beyond $s5 targets.$?s343311[; When Eye Beam finishes fully channeling, your Haste is increased by an additional $343312s1% for $343312d.][]
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

        copy = { "abyssal_gaze", 452497 }
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
        cooldown = function() return 30 * haste end,
        charges = function()
            if talent.a_fire_inside.enabled then return 2 end
        end,
        recharge = function()
            if talent.a_fire_inside.enabled then return 30 * haste end
        end,
        gcd = "spell",
        school = "fire",

        spend = -20,
        spendType = "fury",

        startsCombat = false,

        handler = function ()
            applyBuff( "immolation_aura" )
            if talent.unbound_chaos.enabled then applyBuff( "unbound_chaos" ) end
            if talent.ragefire.enabled then applyBuff( "ragefire" ) end
        end,

        copy = { 427917, "consuming_fire", 452487, 456640 },
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

        copy = { 204596, 204513, 389810, "sigil_of_doom", 452490 }
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

    -- Place a demonic sigil at the target location that activates after $d.; Detonates to deal $389860s1 Chaos damage and shatter up to $s3 Lesser Soul Fragments from
    sigil_of_spite = {
        id = 390163,
        cast = 0.0,
        cooldown = function() return 60 * ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) end,
        gcd = "spell",

        talent = "sigil_of_spite",
        startsCombat = false,

        sigil_placed = function() return sigil_placed end,

        handler = function ()
            create_sigil( "spite" )
        end,
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
        known = 185123,
        cast = 0,
        charges = function () return talent.champion_of_the_glaive.enabled and 2 or nil end,
        cooldown = 9,
        recharge = function () return talent.champion_of_the_glaive.enabled and 9 or nil end,
        gcd = "spell",
        school = "physical",

        spend = function() return talent.furious_throws.enabled and 25 or 0 end,
        spendType = "fury",

        startsCombat = true,
        nobuff = "reavers_glaive",

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

        bind = "reavers_glaive"
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
                return max( 0, cooldown.felblade.remains - 0.4 )
            end
            if settings.retreat_and_return == "either" then
                return max( 0, min( cooldown.felblade.remains, cooldown.fel_rush.remains ) - 1 )
            end
        end,

        handler = function ()
            applyBuff( "vengeful_retreat_movement" )
            if cooldown.fel_rush.remains < 1 then setCooldown( "fel_rush", 1 ) end
            applyDebuff( "target", "vengeful_retreat" )
            applyDebuff( "target", "vengeful_retreat_snare" )
            -- Assume that we retreated away.
            setDistance( 15 )

            if talent.evasive_action.enabled then
                if buff.evasive_action.down then applyBuff( "evasive_action" )
                else
                    removeBuff( "evasive_action" )
                    setCooldown( "vengeful_retreat", 0 )
                end
            end
            if talent.tactical_retreat.enabled then applyBuff( "tactical_retreat" ) end
            if talent.momentum.enabled then applyBuff( "momentum" ) end
            if pvptalent.glimpse.enabled then applyBuff( "glimpse" ) end
        end,
    }
} )


spec:RegisterRanges( "disrupt", "felblade", "fel_eruption", "torment", "throw_glaive", "the_hunt" )

spec:RegisterOptions( {
    enabled = true,

    aoe = 3,
    cycle = false,

    nameplates = true,
    nameplateRange = 10,
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
        Hekili:GetSpellLinkWithTexture( 185123 ), Hekili:GetSpellLinkWithTexture( 391429 ), GetSpellInfo( 396363 ) or "Thundering", Hekili:GetSpellLinkWithTexture( 389763 ),
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

spec:RegisterPack( "Havoc", 20240910, [[Hekili:S3txZnUns(BX1wNgr7z0ksz5XZEwk1D5LltDvEXzR9HTorrlrBZYsIkKuZeFLk9B)aa)cF0naifPD2l5LKXIGnA0O)UBaUWDXVS4(1bzHl(zVXExp(lUJh5EJR70jlUp719HlUFFWQxcEI8p2fSL8F)Vc(w8k6V(6M4G103on(qYkYtUpA7HnbzrX7(XKGhZwC)dhI2K9t7w8aWmm(wVBjV6(Wvl(5PF(ZlU)5O1RdZhBykzcOJ9tJ)YNg7(XtlP))jf))BZ))UJ)BNwsMYF80Yd7PG)0xp918x62p5Dd5H)98FEz8(WDHjNwUj(POvcJ66kqSpjkojk7viG56rg2p(C4QxiWC3dXh2TM(3bXPNwMfSjCx2PLpgtMGFA724tl)poKeu)6F(tEtiV(V8mbr(hbKb9pIYEoAhHaMe)y0gczlyfLKLoAFs4Q4TpeKD1S)63csIcEyt4hP08zzjr7EjmZ1pnlmjoAD6h)wWMdv)(i3rphKsEyq2OGDV6VEF6PVAnu9WGQxRGAYt(eiTo8XGdBYMn(JX7NLeMgMb)UPrpfTXp(r)h3qEz4XerOQ5Sv(bes7hJEC2dhE8Xrs)(O1XFFhLU)x(lNwwahYBNeMfK8uygzmzX(bzzeU5pUjAxO)Q1ZC)yXdjWCB0U1Hma)WHKDr7EY)70D6rjHBdI2LsN28nBXNpO4hxhULGipSjGW9oGo9Fl0FDS0GVBiHHFZg)8znD(pmX5CW3lY)RrrP(peN2nO4miuSg9u2SJ2TIUht2HlyFyKWKWDRPGmLWm9siBRza7bpTjGoTpU5qsYRJoSFWQ44n0hpIHx(Rd2TkK(7pTQI0pB8XJLZ7O8PCaHb5B(0X4swwbzp7N(9WW9YeZ9rREX)WE)htcEAlHe8XdPHeUThPV5mx811JHB8FiiH8wHIlUckj3ZhmSAfW9RLO(DuuCBWVD5NhmSGIt0fTnkmD(mYUqus46sk9vjbrR9d)gf(bRxNoAfz7i74r5FoAxnqHE68Vm2HdP2s4N2gNS)540O0s064rjKXZ54r2(d)A4WENbxiH2ZChCH8Cg(BrPzPcSjRJstoSpJ)NOqo5q6ZvYVhYvL6VIQjLULd8RYKrVCYy8ofPFY4jKX05JZxBaJGOsHng)SOTH3n1zGEA0C3X8OpdFk4NRwcsS5LRbfM8H8SVRtN5bSbWpzb72f9CuoY37twsyW3cts9Zbu10jc3Ajyur7SNtI2WuMN9m59IE65mI48wiPHRVsbjDUQMNL((pty(vEVjoxoHBCHVg6)qyWw1XvQYl9zIg0qQugrAllA3ReaOqGKuVSMYKJOwszKEWJSaHicIMinuyEbS2mYdKu75mqCN8UjdUOGBxCxC0MG0mFI2U13nDqHzTW00qcU5)azOVW23oEmhvkjFIC8VH8fx3Z0P5E6xQRciZA(F6VHOml3kq5oR5rM7HjLebWCsXCevncpsC)HQ8LPOYD6GHaA5VMOLNrZyw1tpquSnkL6SWDt5X3khSs3hLX2er5gk5tk333gK8sLYWzEFQqK6xpqmQswUR9zWovGL5WovIdVXuY8xTvXBevEbEyppyb8auE)TuGNcThjMvHmMWwKdVq1go3MaGn85cgoCWfNgGQyseexnTGDxKzixIe4bLazk1zrE3BaOl4OG31dqMu8vuBNS7UvRArnKq2VNMDGekygJTL83HKasEAKSKia(8mjog)SKqgVv6kY2y4Adw5jkcW32OpCicJuLBgL(1u6bc1CIgtu)GE8XH6ysbhAGpLtMOplnAD45kpOkHP8tvR6PypAUgJjnZxpf8TsUKeQtswuaVIrjA4vEZXDvumALWDKL)bcYesylcK8)NlEPODrK5KIsdW37MtimCHLC34rtoEu8h80WmnJBOGSvuRb24768Biw8KPwf)92yACoh2AmeaI7TCKyaHuEFUnmzGATigWCCQ3wHKP5qaXebu7)eB9sfdRnXRKnKbkpRoNgCoSP(EdRtGsfIO4kjz1IoQ5EJDuNbpGzWZQzqDuKzOICR6mRtxy8TMzsibbqH6Y2MfdreX2j19feZngXz6R8rQBKRYYfsb5UAM(gro4CuR4pKSDdjkCTgt7t7QqsVY7o0zrJ2qn6c)KyGE8ujjjynQTQudC6R6mabzZQsXHa2vXplK3jhup2i6VPkW5dENt1eGRXQVGseWs5EXPzwxLEBCFnLEV2NYhG1KjCgIJhahX34N2V4FTPbbFjqdiQcTywv(dR1aN2SVlOPRIUljvIWH4mqk4fCTu6D63Gg2ELzZzqHYyAQGzuVGnZDhnESbIjnT6dKYCWu9ltmNLk9e3bm8CMBpCBFqUlzwjnGx087)KyJIE6PWeM15HgKZQYvxT)bcdSd9WCYFkrxXruU1s5faP717Xuz0SOvKD1GDPpgNSLX7IMSPkfOxn5smpkn9YK9uhfjvjb1l9afkNmUmdsRED1gAyy(KzN8EejJDVCP7ehEU3YWX4qi5G5Q9at3GOEOI6)85gEc2gh8(MLcCExnvZ(d2tgOh65BCALgbQMetpr72uOc)skJgCHsCJGtOi71vtohtbg46UXXEvMOEXxL4Nb24M)8P05uDHRI(LKYB)dU6r95UNJvwFcqRdAOin3k1RO517tk8kgUGeXkZ3RhpqRzcXpGvrzZVUIHP8vRw)K1k5r8qVOSlzHB3te4bck5mesejOQ(KinttgOxRjBXhFG9ZePSNkkguzeIjzLf4jFnPJQdMTXdk15VzUrnut6zV2uvHzS8MlbjgyOzfdJPzimHJW(lY140a2MSNtI)oxj8K2kDRsZZHKO4dP(SXNQBlXcbSCmE(T1PUss5RbVULTB0nb5RKZzdEIJWgJx7cDsfTPUtEehBSV9le7)cwrb9Fikluh3awsbeZ2c6oUgAHMSOFlzzdgmMBroGuP5YCTni3FVVRhDiEqYQGDeukoHywjRvCCuXmI5WX02ERaWv6ciZGGQhMgM25mNJUL)mVXOPYbr9DX(mppForgSo3eHaupJQ9XKdyQv)3PECybnj6IXKYQRhTJOdYNjojL9KeIz4nKvgRtvct0MuG5Co7a3ddoodW8wwkkI6ICgSznHF75i)8k2xy4TUFa85GFrQCYlNY0EMBrhPGy9fRloQ(DpKFFI4VdwwaOQoizB2bprknLtgpESJhHQg9)AW5peH1hZV565qsOaNB3bnpzYjzsd)(qtm86ANIAUbfWW3(D5co6LC2ht)jK8fozkcNkktLG3T8Zt0UVf)czZ93iKwIngF6BNxYS9XFNSxfT7XdPrCTmO6ucGGef4GRkXwIL2P(rK5SiwnX2In8xpeTFFiLEU2)xpegUJ2(q7Ons)XJvpKQLyfD7K6NjLjCBugJjPAePVeKS(vYl)ezJoeeROvWN4vZ2IsfQmF4kUkyQl)HCP3YaYX5tMdV)LRpLleAYVPInGraVM4MlDDDhnhjAI9npfkvpN2n(mejy3Ro8VOHz21WmdexVWm7koZoISpZDPvOwoaDjwmCQRM2PsgQWYEI8diSySGkSJjvpLeMuRHskSemVPPHBqasY5eHeRGfuhrXlMKIEQI8CiTaeHxlidUAGIjsaidSjrlUNd2FcAu(UMzfcI7IeGz6l6dn2DQMk4F3uzwDenYv7MPBIZQovq5A8WHEzgjKJfbRRDaDgrdT(t0fhEUlr1KOSONs9bwdNXfMKdfhaYUfFUuLmQzktK2VP49MUPaWGB)MIN9Bkqc9xysLM4aoNnf4eqdUPuEccqZHiDCDzjNzh6gOgOM136O(W6mq4nkAE)CKRTUK0qFFaPFnPTXbx2LykEFJRNSOneYkFXRXDUGGuCD9jAZ5hKfN4FyVOFRvZsvMuLKpnwcWYbAhMqZxJpbDapuz8DF3LdD)3g6n6MlZpaG(er0SqNlD9UC4qWUCgwRXLJhnzYvUooxLZaivxk25f4YBYFygDbSkGVYPxYvya9u4vK4EjsfslSQSE4HbgWd6eFGNCLyr6v5R3k71udQww5kqtqdkmFnVwfje(HxttjePNc(FdFBNzbjp8PgXPgyyYfVmkeXExSJLRf9bNhYHnSb9aU0jQyckztTUzW0n5Dmm4jvUXgrY4(l67YksI74XG22)YyDh9tCB7xRPmhaOJ(UMLHHEJvtAfolLADuKR5jaWSUpmuydMGlWuHjRJJ3AjIOHujwBxj8VL11vV4ifOFQYTOkDSFAY05Jb6f7slst4kjpVPpUQYv3g4fgKM7EBdKGqrSXVPiMKO4VtixQL158470lII9I8oaZwhK5TdD39wnwiLmPJTTC9yQML3U9f56yBaV4Dnug3gO7HSSFvOzh0oh(A(sLf0Nqh6epN54Bcc1)TEqu)cqm7Rnh5hpc71jxLfOToqyCYRdGRAfwVIY09dYzR0(y0gbIRCccWb5SWoJNcvS4bD50WQhm4NsMbDp8UXJMAed04rpwrjOKnSsUCbWUsbJi)pXAffnf2L7W0RlymtDmkxt(Qqiu0UP20DYhChDSrqKrn(o0T4J2(BURrUcKO607KZdx8xktVNcSGolVfnXONINWwCKpr5SlOI8XZ9oZZPegvPpUDw3S75O5qdZZwbQKdOfyKMaoNL10(2kEkFTdkxO8oUj678P4vqxx3AQJ9tB(EeL5W1ytpPOGkt1EgYq2SAaF)FGzQSy7wjqmTB22t1XYabNxaL9dc3pPQQr2s7k6)ylThhONxhbNSXNzlUvi00yqxr8taLpeI9x4eDPYDF1enD5Mg5NP83WeaUlAYvs02KPgBapDcvPk0JV5AvSXJVMqAafa9)CPn0W1qHCdWOAUtkzGneEQU4Xbpi2o1iXTPHf11pALTQ7nahRNZi8qxa)Un2w5Enq0xUrwl1DfFGPYhURM7spB07Esbn94rkcvD7ZXoj44cF3nviUY8ehbWfG0PYywQvv9dUaFSpBeDCu3GiJz8gZiGAB0kA(x3v0co9StLs0DMUTWRFT8OgLyWm28U1Q0i7AYYSMdA7)pSOqYFt(9m2vLDCOGX6QNj3xUQx6niDGBPvQQQexkq4bB)sTSYLVa1BMcAz9tP17F1l5rrJCO7ao95ejo4EYf)k(J4cb4lG6Hl9nqFiCFylKmkH(vM)QjLxIeF6b2FnVhcOJI3bjqTxyNruTEwHsxGt0xfGeBHGABJAQ6FRieWo6COS)WZ)XKNd2NgV(vrFrHc4Q0tuW2dt1D18rP9El0gQU8gzBLSnS)l5Wzrss1enFDShq3pwkE5dlQ0QT1wTsGUNE4Zz3zTiG2rucTfuOalR1aegz)mBvQHHJfQ(wKESftmyQIuTdqMnu9A6NWMNpZBSdkAUXBQPns3trfRlUyQH1VIKanqAf2D8y5vrcnpBCCgLmSkhJNCE75ZMw5NXm0Cw5OPFQ7cQ3fGKpyAfEC8AYOe8XaXWLBGWPeHFFb0Tfi9rnMqWTXjOdqJRDTFYALUWjaZmFvHHyp5v)P72YOXTwyfgiLViRRQimlg8kFmw2GgaeyBLJckEPdH(DI6zqdmgvwkfDUQEL8WZVJgw(qq5uE9uknCzGLrYxHsjkxp0q9bktHxtuj10RwoSRzjT3YCakLXZUo454RryUgPBn2ASjyuWSpjZ)jFQ4eZGmRICGkkrSRPL9Mj4alxYFaEQiAqTtNYnAFtICsUnpkyjLV68BcidLRUdU7Y4PUMHhkbJahynSBg2eqca2l8cOPC7aYxIJIjWg4cZfBxAOrOdWfSe9myJECtr8PAMNJPBLjyzaDh7xRJbsTh7HNk4tva31aM4DRHgNRm4iHwKSmah4nQ2v9lizn5U6gYoxtRZIb9LnXJtI2si3cSUqq6WeeSxrFlwvIWvyP)I)QSeWWcB4jgduG)my)q7pbZwCSHiG4tiSARMOpQLiiyzvb90e8LRsq8I7P6fipU87R24BxC)3dyE9KU4E2xESOT7Jtk)mL9HCO8HtltON(tYk40YusW2Nws)MtTniJ(de7OehHthD6R)3epfoTK9nqlEhzQyp(dyCfeOMfR55Jc3r7WX1KXn093CmbFHDrjylkEHa3RHHBDalsaLlsMMbXZgtNcdxj(vjil9umyFtpV79zy4xMchjWwLzheODl2EgZJvLnSC)yBgSecMqcIcpddUFPdXrey1x44zZPY(0l2vlEx3Uey9TAkSj4m0N4obgK85)qcOc9XBdbBNOpXTVuc6IOf8SLfCrur1BaUD8ViaRmRgY7wf)CtbNqorKGP4x)sma3LQODr0t1zcTEi6R6UjOpL1WaEVJ9NTWShIwcPiwLvUjDr9IbCeFAoFSgH3U7O3i87Nj3cZr)hJ3Sj(7e5xQZ8jbPNw(DckDAj9tbijmGDeyshwE8eNws)ORCA5dhYkh3Uywuch2jm61RPdEDqwWdbPH)TtF90YprEnHSzr7tfGynk(sa)HUiyJhRpJtsehUN0qxu7SDvm)yKV3dKGV8JBS58wAzabCNfjgZRGZ3glwSrTCXJO6ODwVqT)3EpcFlCPOLXM9VI4g0Hkxwmh6toO1td6fut1SumImWH0NqVVG77nwREdnPaxWHyhw3oO3xW9DdR7AtKiEwXsMzXnFJeS5Futb7zzldlMHwPNZdX3GwQNdZH92HB9M3)ka(Suj0VqVVG77nw3ovc2I1Td69fCFRWA0sk0gPpeGj0LisGuSdsWamIlZTdl7w)VXcDVJ9tdBAAhjO3s3GcGplvc9l07l4(EJ1TtLGTyD7GEFb33kSgXBYZxGbbWRaVF7LMb4b10PQZ8igBcoJKh8UHZDT2BeV6pF(NEp)UVxtW5W10Lf0bdyTnCN(f3oltl9l07l4(EJ1TZ0ITyD7GEFb33iSEcwvc7wTYytJYx1pP5q55OtaIF2IxLdsqx8HOGgZXHUOCKt6sLutWQiEhVzImnTmXzG1)BFs4Q4Tpe0WkaQKWSkns0BR(0SGm6TvV)69qAKagIOmiQiOrGdoeDRFrAzdOai1a9mZvQeuJ3hM)9cinVCV6a1VBUtYTyztW1)6VpW1kkFx2WGyfATZ0paYkxA8Pz8XOT3xR9vfbINDGbiWTLAd1cZEiwvKz6mBQed7HTH3TN296(gZSVAj9(Uhv7JUNbbM9aFmYm1j8XO8iTGpUV4oqZBFR5JvGyLVurqFXE(GQdvyJZQPHlQLYVorktb8y6vW3ea3GaYAow3aGBby5)yobasPhBjUAbqPxGl0HypqTJ5dFCwnnUwWDapMEf8nbWniZlnhRBaWTaSA5tuESL4QfavhZ3FFx6H9u3yPGT8J1wDhW(ppTuL76)5F)0sIU1KxpTCDuktPAfmXlnLDm0wQnTBRawVcCJGTJL172cw1RaVcS4TSvK8NupyYIYyeW6UT776vGBbyntsGhJvyD72i7vGBeST1mJLyDBbVra3wFZSeVBl4RaSf19Oreej8URbVfa2cJLywGplGIzbghODIqUwWBHfhlngRDAOz7d4tAk8CHpyRMW2PFPxbEfyvsW5zkLkH1Dn4TaWwe2dMW0zbumHjCGAwyYcNi0cEleMS09nTtJTctggSvty78FPxbEfyXpI9Tonq92bu7n)GhgSd70gsRGZh6IYtCUh(EyOE2jhSlteFFEML7NR0GUSXR7Y2JgPLfAz7o1LfkSVpz9)o(MabbyD3sVl5grpGRDHWi61FqXxlfzkqXp3uW1bDOdwt23yjPtF9N2wMZVBeT6qv9V4E2)AXVS4(87clY)6NDP)z(ixCF(hyHf3xa5f)NlYw8ZE0ru)l3VkjIq2JcwCpy7dCA5aI9Mst8G35zIdr0eGmaKVo1yp1exl)GaTWWgWqUPb(E7)0YJhpT8ItlrVczpT0zX9CxJ7uc69eSHqK2NtlvUeZmFlW)NFPkuFJ3XVuf1YhYBDuXJjuXdzoaqXfE(nXVAd58zmsSYLLA(ZaFXkU07MDAz5DH6shgZnGSz1WNZp8ljkGQFdTFthAICRSAb9eXRr1XyHMeP7HW8gu60sYI8AeDjfiBfpUCqekQhuxRfkg0RKPh0nONEGC3G33FRl0V5ofDZfQP0G2sLVmX539qChGASJD1IV4E3XMi7N3h0I6vppAsx53iTYbhhh9qWsdejr8Jqb73VWS5qrAbbV(m6ocIpgCQuK((uqu(qC2OEPvEn)tNMBnnns(hwplkFW352WbV7ukLylOs5GLYdJPmSM6btXPY3O7fdbbz10v8bRGOOL4JBoOa(KxWP0xv5fvf90cv)LqBMGMAvBXmv)5A)rVkEH3O(s3UrDHf7v4Bjd1yfrYyOQZH0hB0Xpe9BvaXPepWznaD4IPWhI(sK66ucm23Hd2dPiq93IJCMqe0YTBrRZYw9eeCep8dyPqvJZActOAN(cTEdWTJZ9f)OGBlIMRT5mXvUT)Yp6iS1WKMBbSaBGsqKb5hCs8yjPtetNcQ4K(SHWrlu)kvYV(584MrcK9WZKPWZY1adoMPyp0f3ffDQ6PKc6xFeMnWRhdYoHObu08IAqLvsY4FDseKxydGTuK95OEPG9LkXwlgjcF7tytMrhj0ASgtjdNsC5lvbHhcEPDQjaOQf7qn2qXn8ZXDlDMiy0IUYBhl8Ab)tlJSbuWWfb87Wx(ZLsnguI2052rG8PA)tRxtALCRCGbxdgriBQ(TaC)yyGu(tSIKUcn(pxoPCKtwQXWTRxiQj9fyP5Zi)x2f2uIBZwFoZ04tvjjhi3ddq3QhOX5zyMxO8puVqfyMzRuCl)iFmxexNaS(1ZMyaC0zd3gnUCOEXS5OzzbKAoupbDOvwULI1G)RTav4steh5rx4OObbXhzCjDof0A88Y28NGVHHNZiC8c(RkJk9f54VAm8dC5S6GlQxtIjDMTOWDebNXrV1a7Khe)gLZqfChj06qKESrl7VzRwTn0oMTloDnfBCS1jUpmTNWAyTQyju8JBdcII7GHrA3DCQImO42cRt68oPdeqmQneY)fiNj0zCXykp0fCeUfH2PEVdwqtgZxip(OVeRM3eHc(jg9L4a9ebi3xEh(XLrFg7YUErz1e5OQXKPpnKluLVfqOXKNs)xBoec7NKOCcOxBOfszqoNEf3uEyVucC5upk5js8iRydf2ujdn93rveEF(GxauhuZRTcojGdAOIgp(Xak1sCG4ZLVLsgEMrv7Ms79h)mAYcZi)4vNwMeeT2p8BS4WwVoLe)iHvoNyi)iAZhPoDyJK4zZxgd5SaIinfoaPLYt0NeEAqDWgxaUKNXYSA(JLXWWFJwMBM4s9(ihWxuw1UkM7O0Kd7ZKeaW9VGHTGzad4jy7ME87MerC5JzpFsKhxtcbgzsy(y9Ztf1D5PIYkDT0CdogoXBg8ebo0gCb2HIcGRRYNTgEd8OGm4BYBlYjx1hChkaWarDDAveQP2SymzxZ0dGU8CkFCfFszAlrH4e2BL)pKExvR9QV7aB8UWHB0W4oGk918AfqnpG8wEw4rNyUpmuO8IWBWcfR4XkMKQZ7hph3DLeJlQ0biMlUrBcsZ8ZB60CX)bADeNL4sgkZVvXRjqnxF4EF(MWvF97g1FELMGMsYK9XSsBwab3Z)dFAlzL3ywfgQkzcxav3iCiahmGqhpi4AUjp3vdFkx4T0eJ70YneeheQZhUKNTIPZJBLx0uA6lmL(yYGIVxiTtESwPUqfewtERlcDL6rvT9Fyh2osfJgNtim0vM0rd9JJGi5ZIMYibZZoqtA0HDwrkAfDoWkWUa6(6CAlPl4AIHItlQew1CIkaVQuzNPY0a8qEWo1y29BA2MSW5lM(dtR56bzQOffwgk9HBeFFduyV0G16FWmo7i6FPUQ8GtpH7gNIWiH)MYJI2Z9Ug9RBVggTZBsV7w9FsJn8PAg82OQsNpUJ3Tskxvhd4plWWnv)qMB0fd9Ysg8EhmYk01(qXI3dukrnS8xXGYC9bUH1uhm)8TQZp10AbdmjvoVA)qiVgKTPXJMKVavFGNr1kZKEnufmLUgyxWNZzDEEHdwwuFx1gnZ6KkmpxZOWoSXKFYh4DRqpeJjfEi5CcQha0D7ZjTaeZdVCWhv04Atc8(XwCg7CjoAtSjfToFBfyeECJqiIiyiqPv4hFpOW8yKqDVcv8DCv6F0HFsZV6zX148d9kfZp3wT(4rn0IRkf)V1Efkk6aDlpYRXxtQfzmPYPud1PTAp8rmMQ1Xud1DxwuH4xnzZzvgtHjkLIB(OayHf1BxxBJI29fkDlQrTjyTvUQbYEi9E5MSUt78BWQNb7DFsobx8w900)bO6mn6HRG6zK5fVBaaCnqjB4dmgUJcu6MKQpN2IyBOkleJesRhsAAgbtCZilq90)PVpebz7KiL1vtIjKwesMF)tdJT2WOJrwu8aInXIQOWvGja878eNFxi99(aKCdOxrPrT9ghaFQjFBLEkQWtUDe)htY3Sc2K7G4OXJ1V)PP(oXP5RCG8Do1csYaB9UwnEvd8C4boALN2g1dY3JeMJRKNz2Niu90tSdpjuim4ATKQwJO7FyTfLc874qKM8N6rBY8BTEuGUScVyHgzdKzsxP9ghwInapNKtz6OMWwPMJnYgGwWg6GQNeqn5LvvDbrL4KX8PYxUH9iKGxyaXDcyi5yNYJQLICuEYo3RFWLXAzM(1tPlOMNZYwiZgwTgQoZR0gS1msMh1aZyHm3MrnFin6IGM8UIZPuDSgtld4FkCcO0IQYsx5cZDNViwk4Ddc1RjgsPp0u8ZvNRj7cFEox1lgc2(qLtSU0FF7FAGSjZVbdK5JwF11fuJHNVjn(3nhTD8b6pH6jw6iFmPPh5d8MyAcEQuqRL5G8tCgTUvrRIYyRQRf4)B0PfBsdYQsNPaHFBTOTrYc3UNOQNHsnQk3tK0xA22jH0()1Exnl322aHFw8fos2JtOOKZ4EOUh69Ej3Tgvv3uptAShvLR(zVeKGKlw8T)qi5gNj9MnjfjWIDxS)8TlG1Uy147q8u7sZqU1Y(dluTkkmg2LJiyc0jdH4nwwo7HSdxG1IvuIiU1hn9z6UobRmRLneEwY0duHE10PH4xOQouwiKTxsFd8fZYt(HT5SSjUYbyebUnV2i88yHbDuA4vIJV)F5qjPjA0nWchxGb2WrSnm8Zla39FBJHsBH4VMJrx9Os5VcpHcf3gjQIbhA1l009G5aqI4YcWBm6tyFVry0N90utSXO0blr(ASSYxrJJ3Ud739Lws1thAnZiSBzRE7XJAW7lQ(li2iYpJ)OWNpZS0o7Wk)RLFIcc(AnjFnovo81o8G43JuahT)(XIu5JDf8)gQWotzqQ8Uvb5X82i12XCLXhJjZeSwPA9h0s7O6WI7HeE85xokJj1nPcWru2PCY4FPERuIAkPMAHCBNyw9UqrAmuu1uPe91v)osLRZRxaz1hAlUmkcSpymfgE1cg(cdwLrZMtU9eKxmv8M7EyLvCzsSjWX6umQ1YuzJY5bf(HkvB88iwixUFkulHmVBPjQ8jGZuc8QmRmtPZmBfzoGsGINgzTAlr3Ckd6JQLWBCz8ljD4TVxeVK9Xy0BSM6S5YzoVv0gyGOrN8io6CJkOTYWbsfpE(oZEc0G1nPrAuw0dZP6zD(UbaGOj96kgD8IswPVNPVUQR4sBV77gbhP4oNixWZzKQ0butzY)kf2Y)lMC6IjLWIkBIOjlQdEG8anOufpCJCP1Tk5Y66952fUp8h)DiK0DqTGg3X5vNlolBhZwHZvDMdBkGzj)NHIiKyDFUVmdQGHcfJUoLSHzI9POugAH8yM3LMJo8PB5P(u9cBxceCNcx1oHHWv)875T7pZUqNaBuMnqPIt0SaP085k4BaLDC1xwuA8B(dwLPudi62FqftfNX01KWsKNXgf4FdmkPPCvNkW)Eype2P4avtcoJeDpXPyLppoOEAqBIMKNS2gUqycfIs5NcU60pYQj7nRIINQ0OQ3N2hkxm3gEfmwBPHuyJFZvu1yFGFFtuQZyMUuGZQdLjZBoB4ipoCX52RA4t4VOZI8FGIJcW9(SJga2d)Eu1bzZtJURcGO0Sn5nBsluyGq64u0IzKZWFyimu2kEp2sULynmS1JZ)cMhqNa0Y8eMOU(FaTWb1J)VyKVz1kgnHT0LoL(cr0owdewL6SjmZXIPQBQ1snp8XM79466KzRsVDZYU6QzAVxefvkTZZ(XLxSeQMNhLMr9O1gQTl4(XYufQsCAkzli90YC2fjmDIV)lQ1QyWNJqS7To)EGTFPE07iQRSPauf6jlkhUPVqWi0wS)buvakA90jC3nHT9O0XrP9XxAE3KK9jRRcSflDk8VWJ8VdFsy81GxlULGphvlkrxtUSMwFJQeRI4Z0ijE25bY0OnSichCRp)8dbQd)CeU)Rp(abDCGd)x2tLEIhtrdX)88d7FC3N3gryrwEf)9sughff0pAmswYv9KuyLGUntGTFc4kpIoaMZEoWXHDm8WXrRbALPq3pfgldNC1JkAi333ydCU3JhBci5gn2wLp2wI4)d)8HEHak45cYm2oxo7gqxRCDSE)ZOyOufpGviOebX1gPhyIr)cISJPiORLt5LDRLsgzXn7Kf7l79UeUie2U8guoYJApy6vgdYb76jQq8qCrdd0Cp9dDY0ZvwVtF0sjju3QzYEWLsMj(1NnHrGUtGSmWHJ8PYEHlnSPtNoC9lDLqC49BxEnwk0WkrAUH6xK1kD2ZiiDL9CIBepAs(yj1W2Z13UnnPrDFa)LTYAF(PJK)xf6fVD4gGm7Ne3aFR35WniPlj7zCWn0Cw5g0QuRmUHgg3qJbMlmJ22RxSGtAx4OU0jbDbMNlwj)6yj6K591zWeZZKLV0OSsou4kThNkqaNMHEBZP(j4Mbrb6BwwZt9yANJQi8QNNrlOYSWmB8rLQs6PFa1fPp1sQA1q90HTFfIHy7XyKUJBExx2Tc2Qw99D)rZ7(q312DmGO5TT60o23Bpc1UEZWJVWciWqvZx21Ja7Bu3RgCa4QbUwgY1JiQUVYDhEOJH54(DPf2(L9qQzIIfYf32wYgY)BBQvsipBswj2)hBB5hF0h(DP4MuohNgjFtkcw4DgR8x9W0UImghbgDfZVHJmJgApCKHTDD61ZXHLrI44FdAAysqEsz5TcthBik5)tyZYBHA03tucbtGfeUsgDIyJcqgUAONJlaKomkof5Ldw5sRaVUrSoSQU2WmYFQwM1LR1xZsYnseJ8(DNV(UnGNkgIFoCobmr4KmQGapPk)gYGY5oTRmADw11P6haaBuw16mg4QFHzOIKSmCUkwEfaN1VAFnXm)X9U6UCiaZ3n0OkwaM4uBsI59B6vrmij6NdVaNN6LOXTI7fSU9fLAJsb3AMtN63atNzbenZz0BHfiMUtf4UvKavw1JQHvnOMnSglfyJnsh2u)67J5T1IoBPGZmloJn1u14FRynYGQN(UeZAcrDPkFsvz9aKKeKSJUOPtwKXlH0KRn(jR7ZZ7D8kcDpRNo0d)UjDIIG4jSlWxp(xpD4(p2Ah2V2DL7)3]] )