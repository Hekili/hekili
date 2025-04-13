-- DemonHunterHavoc.lua
-- January 2025

if UnitClassBase( "player" ) ~= "DEMONHUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local strformat, wipe = string.format, table.wipe
local GetSpellInfo = ns.GetUnpackedSpellInfo
local GetSpellCastCount = C_Spell.GetSpellCastCount
local IsSpellOverlayed = IsSpellOverlayed
local spec = Hekili:NewSpecialization( 577 )

spec:RegisterResource( Enum.PowerType.Fury, {
    mainhand_fury = {
        talent = "demon_blades",
        swing = "mainhand",

        last = function ()
            local swing = state.swings.mainhand
            local t = state.query_time

            return swing + floor( ( t - swing ) / state.swings.mainhand_speed ) * state.swings.mainhand_speed
        end,

        interval = "mainhand_speed",

        stop = function () return state.time == 0 or state.swings.mainhand == 0 end,
        value = function () return state.talent.demonsurge.enabled and state.buff.metamorphosis.up and 10 or 7 end,
    },

    offhand_fury = {
        talent = "demon_blades",
        swing = "offhand",

        last = function ()
            local swing = state.swings.offhand
            local t = state.query_time

            return swing + floor( ( t - swing ) / state.swings.offhand_speed ) * state.swings.offhand_speed
        end,

        interval = "offhand_speed",

        stop = function () return state.time == 0 or state.swings.offhand == 0 end,
        value = function () return state.talent.demonsurge.enabled and state.buff.metamorphosis.up and 10 or 7 end,
    },

    -- Immolation Aura now grants 20 up front, then 4 per second with burning hatred talent.
    immolation_aura = {
        talent  = "burning_hatred",
        aura    = "immolation_aura",

        last = function ()
            local app = state.buff.immolation_aura.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 4
    },

    student_of_suffering = {
        talent  = "student_of_suffering",
        aura    = "student_of_suffering",

        last = function ()
            local app = state.buff.student_of_suffering.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = function () return spec.auras.student_of_suffering.tick_time end,
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

        interval = function() return state.haste end,
        value = function() return 20 * state.talent.blind_fury.rank end
    },
} )

-- Talents
spec:RegisterTalents( {
    -- DemonHunter
    aldrachi_design          = {  90999, 391409, 1 }, -- Increases your chance to parry by 3%.
    aura_of_pain             = {  90933, 207347, 1 }, -- Increases the critical strike chance of Immolation Aura by 6%.
    blazing_path             = {  91008, 320416, 1 }, -- Fel Rush gains an additional charge.
    bouncing_glaives         = {  90931, 320386, 1 }, -- Throw Glaive ricochets to 1 additional target.
    champion_of_the_glaive   = {  90994, 429211, 1 }, -- Throw Glaive has 2 charges and 10 yard increased range.
    chaos_fragments          = {  95154, 320412, 1 }, -- Each enemy stunned by Chaos Nova has a 30% chance to generate a Lesser Soul Fragment.
    chaos_nova               = {  90993, 179057, 1 }, -- Unleash an eruption of fel energy, dealing 7,335 Chaos damage and stunning all nearby enemies for 2 sec.
    charred_warblades        = {  90948, 213010, 1 }, -- You heal for 3% of all Fire damage you deal.
    collective_anguish       = {  95152, 390152, 1 }, -- Eye Beam summons an allied Vengeance Demon Hunter who casts Fel Devastation, dealing 43,890 Fire damage over 2.2 sec. Dealing damage heals you for up to 3,188 health.
    consume_magic            = {  91006, 278326, 1 }, -- Consume 1 beneficial Magic effect removing it from the target.
    darkness                 = {  91002, 196718, 1 }, -- Summons darkness around you in an 8 yd radius, granting friendly targets a 15% chance to avoid all damage from an attack. Lasts 8 sec. Chance to avoid damage increased by 100% when not in a raid.
    demon_muzzle             = {  90928, 388111, 1 }, -- Enemies deal 8% reduced magic damage to you for 8 sec after being afflicted by one of your Sigils.
    demonic                  = {  91003, 213410, 1 }, -- Eye Beam causes you to enter demon form for 5 sec after it finishes dealing damage.
    disrupting_fury          = {  90937, 183782, 1 }, -- Disrupt generates 30 Fury on a successful interrupt.
    erratic_felheart         = {  90996, 391397, 2 }, -- The cooldown of Fel Rush is reduced by 10%.
    felblade                 = {  95150, 232893, 1 }, -- Charge to your target and deal 22,671 Fire damage. Demon Blades has a chance to reset the cooldown of Felblade. Generates 40 Fury.
    felfire_haste            = {  90939, 389846, 1 }, -- Fel Rush increases your movement speed by 10% for 8 sec.
    flames_of_fury           = {  90949, 389694, 2 }, -- Sigil of Flame deals 35% increased damage and generates 1 additional Fury per target hit.
    illidari_knowledge       = {  90935, 389696, 1 }, -- Reduces magic damage taken by 5%.
    imprison                 = {  91007, 217832, 1 }, -- Imprisons a demon, beast, or humanoid, incapacitating them for 1 min. Damage may cancel the effect. Limit 1.
    improved_disrupt         = {  90938, 320361, 1 }, -- Increases the range of Disrupt to 10 yds.
    improved_sigil_of_misery = {  90945, 320418, 1 }, -- Reduces the cooldown of Sigil of Misery by 30 sec.
    infernal_armor           = {  91004, 320331, 2 }, -- Immolation Aura increases your armor by 20% and causes melee attackers to suffer 2,212 Fire damage.
    internal_struggle        = {  90934, 393822, 1 }, -- Increases your mastery by 4.5%.
    live_by_the_glaive       = {  95151, 428607, 1 }, -- When you parry an attack or have one of your attacks parried, restore 2% of max health and 10 Fury. This effect may only occur once every 5 sec.
    long_night               = {  91001, 389781, 1 }, -- Increases the duration of Darkness by 3 sec.
    lost_in_darkness         = {  90947, 389849, 1 }, -- Spectral Sight has 5 sec reduced cooldown and no longer reduces movement speed.
    master_of_the_glaive     = {  90994, 389763, 1 }, -- Throw Glaive has 2 charges and snares all enemies hit by 50% for 6 sec.
    pitch_black              = {  91001, 389783, 1 }, -- Reduces the cooldown of Darkness by 120 sec.
    precise_sigils           = {  95155, 389799, 1 }, -- All Sigils are now placed at your target's location.
    pursuit                  = {  90940, 320654, 1 }, -- Mastery increases your movement speed.
    quickened_sigils         = {  95149, 209281, 1 }, -- All Sigils activate 1 second faster.
    rush_of_chaos            = {  95148, 320421, 2 }, -- Reduces the cooldown of Metamorphosis by 30 sec.
    shattered_restoration    = {  90950, 389824, 1 }, -- The healing of Shattered Souls is increased by 10%.
    sigil_of_misery          = {  90946, 207684, 1 }, -- Place a Sigil of Misery at the target location that activates after 1 sec. Causes all enemies affected by the sigil to cower in fear, disorienting them for 15 sec.
    sigil_of_spite           = {  90997, 390163, 1 }, -- Place a demonic sigil at the target location that activates after 1 sec. Detonates to deal 120,957 Chaos damage and shatter up to 3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond 5 targets.
    soul_rending             = {  90936, 204909, 2 }, -- Leech increased by 6%. Gain an additional 6% leech while Metamorphosis is active.
    soul_sigils              = {  90929, 395446, 1 }, -- Afflicting an enemy with a Sigil generates 1 Lesser Soul Fragment.
    swallowed_anger          = {  91005, 320313, 1 }, -- Consume Magic generates 20 Fury when a beneficial Magic effect is successfully removed from the target.
    the_hunt                 = {  90927, 370965, 1 }, -- Charge to your target, striking them for 153,784 Chaos damage, rooting them in place for 1.5 sec and inflicting 119,447 Chaos damage over 6 sec to up to 5 enemies in your path. The pursuit invigorates your soul, healing you for 10% of the damage you deal to your Hunt target for 20 sec.
    unrestrained_fury        = {  90941, 320770, 1 }, -- Increases maximum Fury by 20.
    vengeful_bonds           = {  90930, 320635, 1 }, -- Vengeful Retreat reduces the movement speed of all nearby enemies by 70% for 3 sec.
    vengeful_retreat         = {  90942, 198793, 1 }, -- Remove all snares and vault away. Nearby enemies take 2,865 Physical damage.
    will_of_the_illidari     = {  91000, 389695, 1 }, -- Increases maximum health by 5%.

    -- Havoc
    a_fire_inside            = {  95143, 427775, 1 }, -- Immolation Aura has 1 additional charge, 30% chance to refund a charge when used, and deals Chaos damage instead of Fire. You can have multiple Immolation Auras active at a time.
    accelerated_blade        = {  91011, 391275, 1 }, -- Throw Glaive deals 60% increased damage, reduced by 30% for each previous enemy hit.
    blind_fury               = {  91026, 203550, 2 }, -- Eye Beam generates 40 Fury every second, and its damage and duration are increased by 10%.
    burning_hatred           = {  90923, 320374, 1 }, -- Immolation Aura generates an additional 40 Fury over 10 sec.
    burning_wound            = {  90917, 391189, 1 }, -- Demon Blades and Throw Glaive leave open wounds on your enemies, dealing 20,193 Chaos damage over 15 sec and increasing damage taken from your Immolation Aura by 40%. May be applied to up to 3 targets.
    chaos_theory             = {  91035, 389687, 1 }, -- Blade Dance causes your next Chaos Strike within 8 sec to have a 14-30% increased critical strike chance and will always refund Fury.
    chaotic_disposition      = {  95147, 428492, 2 }, -- Your Chaos damage has a 7.77% chance to be increased by 17%, occurring up to 3 total times.
    chaotic_transformation   = {  90922, 388112, 1 }, -- When you activate Metamorphosis, the cooldowns of Blade Dance and Eye Beam are immediately reset.
    critical_chaos           = {  91028, 320413, 1 }, -- The chance that Chaos Strike will refund 20 Fury is increased by 30% of your critical strike chance.
    cycle_of_hatred          = {  91032, 258887, 1 }, -- Activating Eye Beam reduces the cooldown of your next Eye Beam by 5.0 sec, stacking up to 20 sec.
    dancing_with_fate        = {  91015, 389978, 2 }, -- The final slash of Blade Dance deals an additional 25% damage.
    dash_of_chaos            = {  93014, 427794, 1 }, -- For 2 sec after using Fel Rush, activating it again will dash back towards your initial location.
    deflecting_dance         = {  93015, 427776, 1 }, -- You deflect incoming attacks while Blade Dancing, absorbing damage up to 15% of your maximum health.
    demon_blades             = {  91019, 203555, 1 }, -- Your auto attacks deal an additional 3,423 Shadow damage and generate 7-12 Fury.
    demon_hide               = {  91017, 428241, 1 }, -- Magical damage increased by 3%, and Physical damage taken reduced by 5%.
    desperate_instincts      = {  93016, 205411, 1 }, -- Blur now reduces damage taken by an additional 10%. Additionally, you automatically trigger Blur with 50% reduced cooldown and duration when you fall below 35% health. This effect can only occur when Blur is not on cooldown.
    essence_break            = {  91033, 258860, 1 }, -- Slash all enemies in front of you for 75,406 Chaos damage, and increase the damage your Chaos Strike and Blade Dance deal to them by 80% for 4 sec. Deals reduced damage beyond 8 targets.
    exergy                   = {  91021, 206476, 1 }, -- The Hunt and Vengeful Retreat increase your damage by 5% for 20 sec.
    eye_beam                 = {  91018, 198013, 1 }, -- Blasts all enemies in front of you, for up to 322,392 Chaos damage over 1.8 sec. Deals reduced damage beyond 5 targets. When Eye Beam finishes fully channeling, your Haste is increased by an additional 10% for 10 sec.
    fel_barrage              = {  95144, 258925, 1 }, -- Unleash a torrent of Fel energy, rapidly consuming Fury to inflict 9,316 Chaos damage to all enemies within 12 yds, lasting 8 sec or until Fury is depleted. Deals reduced damage beyond 5 targets.
    first_blood              = {  90925, 206416, 1 }, -- Blade Dance deals 60,036 Chaos damage to the first target struck.
    furious_gaze             = {  91025, 343311, 1 }, -- When Eye Beam finishes fully channeling, your Haste is increased by an additional 10% for 10 sec.
    furious_throws           = {  93013, 393029, 1 }, -- Throw Glaive now costs 25 Fury and throws a second glaive at the target.
    glaive_tempest           = {  91035, 342817, 1 }, -- Launch two demonic glaives in a whirlwind of energy, causing 80,232 Chaos damage over 3 sec to all nearby enemies. Deals reduced damage beyond 8 targets.
    growing_inferno          = {  90916, 390158, 1 }, -- Immolation Aura's damage increases by 10% each time it deals damage.
    improved_chaos_strike    = {  91030, 343206, 1 }, -- Chaos Strike damage increased by 10%.
    improved_fel_rush        = {  93014, 343017, 1 }, -- Fel Rush damage increased by 20%.
    inertia                  = {  91021, 427640, 1 }, -- The Hunt and Vengeful Retreat cause your next Fel Rush or Felblade to empower you, increasing damage by 18% for 5 sec.
    initiative               = {  91027, 388108, 1 }, -- Damaging an enemy before they damage you increases your critical strike chance by 10% for 5 sec. Vengeful Retreat refreshes your potential to trigger this effect on any enemies you are in combat with.
    inner_demon              = {  91024, 389693, 1 }, -- Entering demon form causes your next Chaos Strike to unleash your inner demon, causing it to crash into your target and deal 56,855 Chaos damage to all nearby enemies. Deals reduced damage beyond 5 targets.
    insatiable_hunger        = {  91019, 258876, 1 }, -- Demon's Bite deals 50% more damage and generates 5 to 10 additional Fury.
    isolated_prey            = {  91036, 388113, 1 }, -- Chaos Nova, Eye Beam, and Immolation Aura gain bonuses when striking 1 target.  Chaos Nova: Stun duration increased by 2 sec.  Eye Beam: Deals 30% increased damage.  Immolation Aura: Always critically strikes.
    know_your_enemy          = {  91034, 388118, 2 }, -- Gain critical strike damage equal to 40% of your critical strike chance.
    looks_can_kill           = {  90921, 320415, 1 }, -- Eye Beam deals guaranteed critical strikes.
    mortal_dance             = {  93015, 328725, 1 }, -- Blade Dance now reduces targets' healing received by 50% for 6 sec.
    netherwalk               = {  93016, 196555, 1 }, -- Slip into the nether, increasing movement speed by 100% and becoming immune to damage, but unable to attack. Lasts 6 sec.
    ragefire                 = {  90918, 388107, 1 }, -- Each time Immolation Aura deals damage, 30% of the damage dealt by up to 3 critical strikes is gathered as Ragefire. When Immolation Aura expires you explode, dealing all stored Ragefire damage to nearby enemies.
    relentless_onslaught     = {  91012, 389977, 1 }, -- Chaos Strike has a 10% chance to trigger a second Chaos Strike.
    restless_hunter          = {  91024, 390142, 1 }, -- Leaving demon form grants a charge of Fel Rush and increases the damage of your next Blade Dance by 50%.
    scars_of_suffering       = {  90914, 428232, 1 }, -- Increases Versatility by 4% and reduces threat generated by 8%.
    screaming_brutality      = {  90919, 1220506, 1 }, -- Blade Dance automatically triggers Throw Glaive on your primary target for 100% damage and each slash has a 50% chance to Throw Glaive an enemy for 35% damage.
    serrated_glaive          = {  91013, 390154, 1 }, -- Enemies hit by Chaos Strike or Throw Glaive take 15% increased damage from Chaos Strike and Throw Glaive for 15 sec.
    shattered_destiny        = {  91031, 388116, 1 }, -- The duration of your active demon form is extended by 0.1 sec per 12 Fury spent.
    soulscar                 = {  91012, 388106, 1 }, -- Throw Glaive causes targets to take an additional 80% of damage dealt as Chaos over 6 sec.
    tactical_retreat         = {  91022, 389688, 1 }, -- Vengeful Retreat has a 5 sec reduced cooldown and generates 80 Fury over 10 sec.
    trail_of_ruin            = {  90915, 258881, 1 }, -- The final slash of Blade Dance inflicts an additional 19,218 Chaos damage over 4 sec.
    unbound_chaos            = {  91020, 347461, 1 }, -- The Hunt and Vengeful Retreat increase the damage of your next Fel Rush or Felblade by 300%. Lasts 12 sec.

    -- Aldrachi Reaver
    aldrachi_tactics         = {  94914, 442683, 1 }, -- The second enhanced ability in a pattern shatters an additional Soul Fragment.
    army_unto_oneself        = {  94896, 442714, 1 }, -- Felblade surrounds you with a Blade Ward, reducing damage taken by 10% for 5 sec.
    art_of_the_glaive        = {  94915, 442290, 1, "aldrachi_reaver" }, -- Consuming 6 Soul Fragments or casting The Hunt converts your next Throw Glaive into Reaver's Glaive.  Reaver's Glaive: Throw a glaive enhanced with the essence of consumed souls at your target, dealing 46,361 Physical damage and ricocheting to 3 additional enemies. Begins a well-practiced pattern of glaivework, enhancing your next Chaos Strike and Blade Dance. The enhanced ability you cast first deals 10% increased damage, and the second deals 20% increased damage.
    evasive_action           = {  94911, 444926, 1 }, -- Vengeful Retreat can be cast a second time within 3 sec.
    fury_of_the_aldrachi     = {  94898, 442718, 1 }, -- When enhanced by Reaver's Glaive, Blade Dance casts 3 additional glaive slashes to nearby targets. If cast after Chaos Strike, cast 6 slashes instead.
    incisive_blade           = {  94895, 442492, 1 }, -- Chaos Strike deals 10% increased damage.
    incorruptible_spirit     = {  94896, 442736, 1 }, -- Each Soul Fragment you consume shields you for an additional 15% of the amount healed.
    keen_engagement          = {  94910, 442497, 1 }, -- Reaver's Glaive generates 20 Fury.
    preemptive_strike        = {  94910, 444997, 1 }, -- Throw Glaive deals 3,443 Physical damage to enemies near its initial target.
    reavers_mark             = {  94903, 442679, 1 }, -- When enhanced by Reaver's Glaive, Chaos Strike applies Reaver's Mark, which causes the target to take 7% increased damage for 20 sec. If cast after Blade Dance, Reaver's Mark is increased to 14%.
    thrill_of_the_fight      = {  94919, 442686, 1 }, -- After consuming both enhancements, gain Thrill of the Fight, increasing your attack speed by 15% for 20 sec and your damage and healing by 20% for 10 sec.
    unhindered_assault       = {  94911, 444931, 1 }, -- Vengeful Retreat resets the cooldown of Felblade.
    warblades_hunger         = {  94906, 442502, 1 }, -- Consuming a Soul Fragment causes your next Chaos Strike to deal 6,886 additional Physical damage. Felblade consumes up to 5 nearby Soul Fragments.
    wounded_quarry           = {  94897, 442806, 1 }, -- Expose weaknesses in the target of your Reaver's Mark, causing your Physical damage to any enemy to also deal 20% of the damage dealt to your marked target as Chaos.

    -- Fel-Scarred
    burning_blades           = {  94905, 452408, 1 }, -- Your blades burn with Fel energy, causing your Chaos Strike, Throw Glaive, and auto-attacks to deal an additional 50% damage as Fire over 6 sec.
    demonic_intensity        = {  94901, 452415, 1 }, -- Activating Metamorphosis greatly empowers Eye Beam, Immolation Aura, and Sigil of Flame. Demonsurge damage is increased by 10% for each time it previously triggered while your demon form is active.
    demonsurge               = {  94917, 452402, 1, "felscarred" }, -- Metamorphosis now also causes Demon Blades to generate 5 additional Fury. While demon form is active, the first cast of each empowered ability induces a Demonsurge, causing you to explode with Fel energy, dealing 28,790 Fire damage to nearby enemies.
    enduring_torment         = {  94916, 452410, 1 }, -- The effects of your demon form persist outside of it in a weakened state, increasing Chaos Strike and Blade Dance damage by 15%, and Haste by 5%.
    flamebound               = {  94902, 452413, 1 }, -- Immolation Aura has 2 yd increased radius and 30% increased critical strike damage bonus.
    focused_hatred           = {  94918, 452405, 1 }, -- Demonsurge deals 50% increased damage when it strikes a single target. Each additional target reduces this bonus by 10%.
    improved_soul_rending    = {  94899, 452407, 1 }, -- Leech granted by Soul Rending increased by 2% and an additional 2% while Metamorphosis is active.
    monster_rising           = {  94909, 452414, 1 }, -- Agility increased by 8% while not in demon form.
    pursuit_of_angriness     = {  94913, 452404, 1 }, -- Movement speed increased by 1% per 10 Fury.
    set_fire_to_the_pain     = {  94899, 452406, 1 }, -- 5% of all non-Fire damage taken is instead taken as Fire damage over 6 sec. Fire damage taken reduced by 10%.
    student_of_suffering     = {  94902, 452412, 1 }, -- Sigil of Flame applies Student of Suffering to you, increasing Mastery by 18.0% and granting 5 Fury every 2 sec, for 6 sec.
    untethered_fury          = {  94904, 452411, 1 }, -- Maximum Fury increased by 50.
    violent_transformation   = {  94912, 452409, 1 }, -- When you activate Metamorphosis, the cooldowns of your Sigil of Flame and Immolation Aura are immediately reset.
    wave_of_debilitation     = {  94913, 452403, 1 }, -- Chaos Nova slows enemies by 60% and reduces attack and cast speed 15% for 5 sec after its stun fades.
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    blood_moon        = 5433, -- (355995)
    cleansed_by_flame =  805, -- (205625)
    cover_of_darkness = 1206, -- (357419)
    detainment        =  812, -- (205596)
    glimpse           =  813, -- (354489)
    illidans_grasp    = 5691, -- (205630) You strangle the target with demonic magic, stunning them in place and dealing 120,508 Shadow damage over 5 sec while the target is grasped. Can move while channeling. Use Illidan's Grasp again to toss the target to a location within 20 yards.
    rain_from_above   =  811, -- (206803) You fly into the air out of harm's way. While floating, you gain access to Fel Lance allowing you to deal damage to enemies below.
    reverse_magic     =  806, -- (205604) Removes all harmful magical effects from yourself and all nearby allies within 10 yards, and sends them back to their original caster if possible.
    sigil_mastery     = 5523, -- (211489)
    unending_hatred   = 1218, -- (213480)
} )

-- Auras
spec:RegisterAuras( {
    -- $w1 Soul Fragments consumed. At $?a212612[$442290s1~][$442290s2~], Reaver's Glaive is available to cast.
    art_of_the_glaive = {
        id = 444661,
        duration = 30.0,
        max_stack = 6
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
        max_stack = 1
    },
    blazing_slaughter = {
        id = 355892,
        duration = 12,
        max_stack = 20
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
    -- https://www.wowhead.com/spell=453177
    burning_blades = {
        id = 453177,
        duration = 6,
        max_stack = 1
    },
    -- Talent: Taking $w1 Chaos damage every $t1 seconds.  Damage taken from $@auracaster's Immolation Aura increased by $s2%.
    -- https://wowhead.com/beta/spell=391191
    burning_wound_391191 = {
        id = 391191,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    burning_wound_346278 = {
        id = 346278,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    burning_wound = {
        alias = { "burning_wound_391191", "burning_wound_346278" },
        aliasMode = "first",
        aliasType = "buff"
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
        max_stack = 1
    },
    chaotic_blades = {
        id = 337567,
        duration = 8,
        max_stack = 1
    },
    cycle_of_hatred = {
        id = 1214887,
        duration = 3600,
        max_stack = 4
    },
    darkness = {
        id = 196718,
        duration = function () return pvptalent.cover_of_darkness.enabled and 10 or 8 end,
        max_stack = 1
    },
    death_sweep = {
        id = 210152,
        duration = 1,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=427901
    -- Deflecting Dance Absorbing 1180318 damage.
    deflecting_dance = {
        id = 427901,
        duration = 1,
        max_stack = 1
    },
    demon_soul = {
        id = 347765,
        duration = 15,
        max_stack = 1
    },
    -- https://www.wowhead.com/spell=452416
    -- Demonsurge Damage of your next Demonsurge is increased by 40%.
    demonsurge = {
        id = 452416,
        duration = 12,
        max_stack = 10
    },
    -- Fake buffs for demonsurge damage procs
    demonsurge_abyssal_gaze = {},
    demonsurge_annihilation = {},
    demonsurge_consuming_fire = {},
    demonsurge_death_sweep = {},
    demonsurge_hardcast = {},
    demonsurge_sigil_of_doom = {},
    -- TODO: This aura determines sigil pop time.
    elysian_decree = {
        id = 390163,
        duration = function () return talent.quickened_sigils.enabled and 1 or 2 end,
        max_stack = 1,
        copy = "sigil_of_spite"
    },
    -- https://www.wowhead.com/spell=453314
    -- Enduring Torment Chaos Strike and Blade Dance damage increased by 10%. Haste increased by 5%.
    enduring_torment = {
        id = 453314,
        duration = 3600,
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
        duration = 10,
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
        max_stack = 5
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
    -- https://www.wowhead.com/spell=1215159
    -- Inertia Your next Fel Rush or Felblade increases your damage by 18% for 5 sec.
    inertia_trigger = {
        id = 1215159,
        duration = 12,
        max_stack = 1,
    },
    initiative = {
        id = 391215,
        duration = 5,
        max_stack = 1
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
        duration = 20,
        max_stack = 1,
        -- This copy is for SIMC compatibility while avoiding managing a virtual buff.
        copy = "demonsurge_demonic"
    },
    exergy = {
        id = 208628,
        duration = 30, -- extends up to 30
        max_stack = 1,
        copy = "momentum"
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
        -- no id, fake buff
        duration = 3600,
        max_Stack = 1
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
    sigil_of_flame = {
        id = 204598,
        duration = function() return ( talent.felfire_heart.enabled and 8 or 6 ) + talent.extended_sigils.rank + ( talent.precise_sigils.enabled and 2 or 0 ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Sigil of Flame is active.
    -- https://wowhead.com/beta/spell=389810
    sigil_of_flame_active = {
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
        duration = 6,
        tick_time = 2.0,
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
        duration = 20,
        max_stack = 1,
        copy = "thrill_of_the_fight_attack_speed",
    },
    thrill_of_the_fight_damage = {
        id = 442688,
        duration = 10,
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
        -- copy = "inertia_trigger"
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

spec:RegisterStateExpr( "soul_fragments", function ()
    return GetSpellCastCount(232893) -- only works with Reaver hero tree
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

spec:RegisterStateExpr( "activation_time", function()
    return talent.quickened_sigils.enabled and 1 or 2
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

spec:RegisterGear( "tww2", 229316, 229314, 229319, 229317, 229315 )

spec:RegisterAuras( {
    -- 2-set
    -- Winning Streak! Increase the DPS of Blade Dance and Chaos Strike by 3% stacking pu to 10 times. Blade Dance and Chaos Strike have 15% chance of removing Winning Streak! .
    winning_streak = {
        id = 1217011,
        duration = 3600,
        max_stack = 10
        },
    --4-set
    -- Winning Streak persists for 7s after being cancelled. Entering Demon Form sacrifices all Winning Streak! stacks to gain 0% (?) Crit Strike Chance per stack consumed. Lasts 15s
    necessary_sacrifice = {
    id = 1217055,
    duration = 15,
    max_stack = 10
    },
    -- https://www.wowhead.com/spell=1220706
    -- Winning Streak! Ending a Winning Streak! Blade Dance and Chaos Strike damage increased by 6%.
    winning_streak_temporary = {
        id = 1220706,
        duration = 7,
        max_stack = 10
    },

} )

spec:RegisterGear( "tww1", 212068, 212066, 212065, 212064, 212063 )
spec:RegisterAura( "blade_rhapsody", {
    id = 454628,
    duration = 12,
    max_stack = 1
} )

-- Abilities that may trigger Demonsurge.
local demonsurge = {
    demonic = { "annihilation", "death_sweep" },
    hardcast = { "abyssal_gaze", "consuming_fire", "sigil_of_doom" },
}

local demonsurgeLastSeen = setmetatable( {}, {
    __index = function( t, k ) return rawget( t, k ) or 0 end,
})

spec:RegisterHook( "reset_precast", function ()
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

    --[[ 20250301: Legacy items from Legion that reduce the cooldown of Metamorphosis.
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
    --]]

    if IsSpellKnownOrOverridesKnown( 442294 ) then
        applyBuff( "reavers_glaive" )
        if Hekili.ActiveDebug then Hekili:Debug( "Applied Reaver's Glaive." ) end
    end

    if talent.demonsurge.enabled and buff.metamorphosis.up then
        local metaRemains = buff.metamorphosis.remains

        for _, name in ipairs( demonsurge.demonic ) do
            if IsSpellOverlayed( class.abilities[ name ].id ) then
                applyBuff( "demonsurge_" .. name, metaRemains )
                demonsurgeLastSeen[ name ] = query_time
            end
        end
        if talent.demonic_intensity.enabled then
            local metaApplied = buff.metamorphosis.applied - 0.2
            if action.metamorphosis.lastCast >= metaApplied or action.abyssal_gaze.lastCast >= metaApplied then
                applyBuff( "demonsurge_hardcast", metaRemains )
            end
            for _, name in ipairs( demonsurge.hardcast ) do
                if IsSpellOverlayed( class.abilities[ name ].id ) then
                    applyBuff( "demonsurge_" .. name, metaRemains )
                    demonsurgeLastSeen[ name ] = query_time
                end
            end

            -- The Demonsurge buff does not actually get applied in-game until ~500ms after
            -- the empowered ability is cast. Pretend that it's applied instantly for any
            -- APL conditions that check `buff.demonsurge.stack`.

            local pending = 0

            for _, list in pairs( demonsurge ) do
                for _, name in ipairs( list ) do
                    local hasPending = buff[ "demonsurge_" .. name ].down and abs( action[ name ].lastCast - demonsurgeLastSeen[ name ] ) < 0.7 and action[ name ].lastCast > buff.demonsurge.applied
                    if hasPending then pending = pending + 1 end
                    --[[
                    if Hekili.ActiveDebug then
                        Hekili:Debug( " - " .. ( hasPending and "PASS: " or "FAIL: " ) ..
                            "buff.demonsurge_" .. name .. ".down[" .. ( buff[ "demonsurge_" .. name ].down and "true" or "false" ) .. "] & " ..
                            "@( action." .. name .. ".lastCast[" .. action[ name ].lastCast .. "] - lastSeen." .. name .. "[" .. demonsurgeLastSeen[ name ] .. "] ) < 0.7 & " ..
                            "action." .. name .. ".lastCast[" .. action[ name ].lastCast .. "] > buff.demonsurge.applied[" .. buff.demonsurge.applied .. "]" )
                    end
                    --]]
                end
            end
            if pending > 0 then
                addStack( "demonsurge", nil, pending )
            end
            if Hekili.ActiveDebug then
                Hekili:Debug( " - buff.demonsurge.stack[" .. buff.demonsurge.stack - pending .. " + " .. pending .. "]" )
            end
        end

        if Hekili.ActiveDebug then
            Hekili:Debug( "Demonsurge status:\n" ..
                " - Hardcast " .. ( buff.demonsurge_hardcast.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Demonic " .. ( buff.demonsurge_demonic.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Abyssal Gaze " .. ( buff.demonsurge_abyssal_gaze.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Annihilation " .. ( buff.demonsurge_annihilation.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Consuming Fire " .. ( buff.demonsurge_consuming_fire.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Death Sweep " .. ( buff.demonsurge_death_sweep.up and "ACTIVE" or "INACTIVE" ) .. "\n" ..
                " - Sigil of Doom " .. ( buff.demonsurge_sigil_of_doom.up and "ACTIVE" or "INACTIVE" ) )
        end
    end

    fury_spent = nil
end )


spec:RegisterHook( "runHandler", function( action )
    local ability = class.abilities[ action ]

    if ability.startsCombat and not debuff.initiative_tracker.up then
        applyBuff( "initiative" )
        applyDebuff( "target", "initiative_tracker" )
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
            Hekili:Notify( "|cFFFF0000WARNING!|r  Fury from Demon Blades is forecasted very conservatively.\nSee /hekili > Havoc for more information." )
            wasWarned = true
        end
    end )
end


local TriggerDemonic = setfenv( function( )
    local demonicExtension = 7

    if buff.metamorphosis.up then
        buff.metamorphosis.expires = buff.metamorphosis.expires + demonicExtension
        -- Fel-Scarred
        if talent.demonsurge.enabled then
            local metaExpires = buff.metamorphosis.expires

            for _, name in ipairs( demonsurge.demonic ) do
                local aura = buff[ "demonsurge_" .. name ]
                if aura.up then aura.expires = metaExpires end
            end

            if talent.demonic_intensity.enabled and buff.demonsurge_hardcast.up then
                buff.demonsurge_hardcast.expires = metaExpires

                for _, name in ipairs( demonsurge.hardcast ) do
                    local aura = buff[ "demonsurge_" .. name ]
                    if aura.up then aura.expires = metaExpires end
                end
            end
        end
    else
        applyBuff( "metamorphosis", demonicExtension )
        if talent.inner_demon.enabled then applyBuff( "inner_demon" ) end
        stat.haste = stat.haste + 20
        -- Fel-Scarred
        if talent.demonsurge.enabled then
            local metaRemains = buff.metamorphosis.remains

            for _, name in ipairs( demonsurge.demonic ) do
                applyBuff( "demonsurge_" .. name, metaRemains )
            end
        end
    end

end, state )

-- Abilities
spec:RegisterAbilities( {
    annihilation = {
        id = 201427,
        known = 162794,
        flash = { 201427, 162794 },
        cast = 0,
        cooldown = 0,
        gcd = "spell",

        spend = 40,
        spendType = "fury",

        startsCombat = true,
        texture = 1303275,

        bind = "chaos_strike",
        buff = "metamorphosis",

        handler = function ()
            spec.abilities.chaos_strike.handler()
            -- Fel-Scarred
            if buff.demonsurge_annihilation.up then
                removeBuff( "demonsurge_annihilation" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
        end,
    },

    -- Strike $?a206416[your primary target for $<firstbloodDmg> Chaos damage and ][]all nearby enemies for $<baseDmg> Physical damage$?s320398[, and increase your chance to dodge by $193311s1% for $193311d.][. Deals reduced damage beyond $199552s1 targets.]
    blade_dance = {
        id = 188499,
        flash = { 188499, 210152 },
        cast = 0,
        cooldown = 10,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        spend = function() return 35 * ( buff.blade_rhapsody.up and 0.5 or 1 ) end,
        spendType = "fury",

        startsCombat = true,

        bind = "death_sweep",
        nobuff = "metamorphosis",

        handler = function ()
            -- Standard and Talents
            applyBuff( "blade_dance" )
            removeBuff( "restless_hunter" )
            setCooldown( "death_sweep", action.blade_dance.cooldown )
            if talent.chaos_theory.enabled then applyBuff( "chaos_theory" ) end
            if talent.deflecting_dance.enabled then applyBuff( "deflecting_dance" ) end
            if talent.screaming_brutality.enabled then spec.abilities.throw_glaive.handler() end
            if talent.mortal_dance.enabled then applyDebuff( "target", "mortal_dance" ) end

            -- TWW
            if set_bonus.tww1 >= 2 then removeBuff( "blade_rhapsody") end

            -- Hero Talents
            if buff.glaive_flurry.up then
                removeBuff( "glaive_flurry" )
                -- bugs: Thrill of the Fight doesn't apply without Fury of the Aldrachi and (maybe) Reaver's Mark.
                if talent.thrill_of_the_fight.enabled and talent.reavers_mark.enabled and buff.rending_strike.down then
                    applyBuff( "thrill_of_the_fight" )
                    applyBuff( "thrill_of_the_fight_damage" )
                end
            end
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

        spend = 40,
        spendType = "fury",

        startsCombat = true,

        bind = "annihilation",
        nobuff = "metamorphosis",

        cycle = function () return ( talent.burning_wound.enabled or legendary.burning_wound.enabled ) and "burning_wound" or nil end,

        handler = function ()
            removeBuff( "inner_demon" )
            if buff.chaos_theory.up then
                gain( 20, "fury" )
                removeBuff( "chaos_theory" )
            end

            -- Reaver
            if buff.rending_strike.up then
                removeBuff( "rending_strike" )
                -- Fun fact: Reaver's Mark's Blade Dance -> Chaos Strike -> 2 stacks doesn't work without Fury of the Aldrachi talented (note that Blade Dance doesn't light up as empowered in-game).
                local danced = talent.fury_of_the_aldrachi.enabled and buff.glaive_flurry.down
                applyDebuff( "target", "reavers_mark", nil, danced and 2 or 1 )

                if talent.thrill_of_the_fight.enabled and danced then
                    applyBuff( "thrill_of_the_fight" )
                    applyBuff( "thrill_of_the_fight_damage" )
                end
            end
            removeBuff( "warblades_hunger" )

            -- Legacy
            removeBuff( "chaotic_blades" )
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
            applyBuff( "darkness" )
        end,
    },


    death_sweep = {
        id = 210152,
        known = 188499,
        flash = { 210152, 188499 },
        cast = 0,
        cooldown = 9,
        hasteCD = true,
        gcd = "spell",

        spend = function() return 35 * ( buff.blade_rhapsody.up and 0.5 or 1 ) end,
        spendType = "fury",

        startsCombat = true,
        texture = 1309099,

        bind = "blade_dance",
        buff = "metamorphosis",

        handler = function ()
            setCooldown( "blade_dance", action.death_sweep.cooldown )
            spec.abilities.blade_dance.handler()
            applyBuff( "death_sweep" )

            -- Fel-Scarred
            if buff.demonsurge_death_sweep.up then
                removeBuff( "demonsurge_death_sweep" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
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
        nobuff = function () return talent.demonic_intensity.enabled and "metamorphosis" or nil end,

        start = function()
            applyBuff( "eye_beam" )
            if talent.demonic.enabled then TriggerDemonic() end
            if talent.cycle_of_hatred.enabled then
                reduceCooldown( "eye_beam", 5 * talent.cycle_of_hatred.rank * buff.cycle_of_hatred.stack )
                addStack( "cycle_of_hatred" )
            end
            removeBuff( "seething_potential" )
            setCooldown( "abyssal_gaze", action.eye_beam.cooldown )
        end,

        finish = function()
            if talent.furious_gaze.enabled then applyBuff( "furious_gaze" ) end
        end,

        bind = "abyssal_gaze"
    },

    abyssal_gaze = {
        id = 452497,
        known = 198013,
        cast = function () return ( talent.blind_fury.enabled and 3 or 2 ) * haste end,
        channeled = true,
        cooldown = 40,
        gcd = "spell",
        school = "chromatic",

        spend = 30,
        spendType = "fury",

        talent = "demonic_intensity",
        buff = "demonsurge_hardcast",
        startsCombat = true,

        start = function()
            applyBuff( "eye_beam" )
            if talent.demonic.enabled then TriggerDemonic() end
            if talent.cycle_of_hatred.enabled then
                reduceCooldown( "abyssal_gaze", 5 * talent.cycle_of_hatred.rank * buff.cycle_of_hatred.stack )
                addStack( "cycle_of_hatred" )
            end
            if buff.demonsurge_abyssal_gaze.up then
                removeBuff( "demonsurge_abyssal_gaze" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
            removeBuff( "seething_potential" )
            setCooldown( "eye_beam", action.abyssal_gaze.cooldown )
        end,

        finish = function() spec.abilities.eye_beam.finish() end,

        bind = "eye_beam"
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

            if buff.unbound_chaos.up then removeBuff( "unbound_chaos" ) end
            if buff.inertia_trigger.up then
                removeBuff( "inertia_trigger" )
                applyBuff( "inertia" )
            end
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
            if buff.unbound_chaos.up then removeBuff( "unbound_chaos" ) end
            if buff.inertia_trigger.up then
                removeBuff( "inertia_trigger" )
                applyBuff( "inertia" )
            end
            if talent.warblades_hunger.enabled then
                if buff.art_of_the_glaive.stack + soul_fragments >= 6 then
                    applyBuff( "reavers_glaive" )
                else
                    addStack( "art_of_the_glaive", soul_fragments )
                end
                addStack( "warblades_hunger", soul_fragments )
            end
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
        end,
    },

    -- Engulf yourself in flames, $?a320364 [instantly causing $258921s1 $@spelldesc395020 damage to enemies within $258921A1 yards and ][]radiating ${$258922s1*$d} $@spelldesc395020 damage over $d.$?s320374[    |cFFFFFFFFGenerates $<havocTalentFury> Fury over $d.|r][]$?(s212612 & !s320374)[    |cFFFFFFFFGenerates $<havocFury> Fury.|r][]$?s212613[    |cFFFFFFFFGenerates $<vengeFury> Fury over $d.|r][]
    immolation_aura = {
        id = function() return buff.demonsurge_hardcast.up and 452487 or 258920 end,
        known = 258920,
        cast = 0,
        cooldown = 30,
        hasteCD = true,
        charges = function()
            if talent.a_fire_inside.enabled then return 2 end
        end,
        recharge = function()
            if talent.a_fire_inside.enabled then return 30 * haste end
        end,
        gcd = "spell",
        school = function() return talent.a_fire_inside.enabled and "chaos" or "fire" end,
        texture = function() return buff.demonsurge_hardcast.up and 135794 or 1344649 end,

        spend = -20,
        spendType = "fury",
        startsCombat = false,

        handler = function ()
            applyBuff( "immolation_aura" )
            if talent.ragefire.enabled then applyBuff( "ragefire" ) end

            if buff.demonsurge_consuming_fire.up then
                removeBuff( "demonsurge_consuming_fire" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
        end,

        copy = { 258920, 427917, "consuming_fire", 452487 }
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
        cooldown = function () return ( 180 - ( 30 * talent.rush_of_chaos.rank ) )  end,
        gcd = "spell",
        school = "physical",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "metamorphosis", buff.metamorphosis.remains + 20 )
            setDistance( 5 )
            stat.haste = stat.haste + 20

            if talent.chaotic_transformation.enabled then
                setCooldown( "eye_beam", 0 )
                setCooldown( "abyssal_gaze", 0 )
                setCooldown( "blade_dance", 0 )
                setCooldown( "death_sweep", 0 )
            end

            if talent.demonsurge.enabled then
                local metaRemains = buff.metamorphosis.remains

                for _, name in ipairs( demonsurge.demonic ) do
                    applyBuff( "demonsurge_ " .. name, metaRemains )
                end

                if talent.violent_transformation.enabled then
                    setCooldown( "sigil_of_flame", 0 )
                    gainCharges( "immolation_aura", 1 )
                    if talent.demonic_intensity.enabled then
                        gainCharges( "consuming_fire", 1 )
                        setCooldown( "sigil_of_doom", 0 )
                    end
                end

                if talent.demonic_intensity.enabled then
                    removeBuff( "demonsurge" )
                    applyBuff( "demonsurge_hardcast", metaRemains )

                    for _, name in ipairs( demonsurge.hardcast ) do
                        applyBuff( "demonsurge_ " .. name, metaRemains )
                    end
                end
            end

            -- Legacy
            if covenant.venthyr then
                applyDebuff( "target", "sinful_brand" )
                active_dot.sinful_brand = active_enemies
            end
        end,

        -- We need to alias to spell ID 200166 to catch SPELL_CAST_SUCCESS for Metamorphosis.
        copy = 200166
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
        id = function() return talent.precise_sigils.enabled and 389810 or 204596 end,
        known = 204596,
        cast = 0,
        cooldown = function() return ( pvptalent.sigil_of_mastery.enabled and 0.75 or 1 ) * 30 end,
        gcd = "spell",
        school = "fire",

        spend = -30,
        spendType = "fury",

        startsCombat = false,
        texture = 1344652,
        nobuff = "demonsurge_hardcast",

        flightTime = function() return activation_time end,
        delay = function() return activation_time end,
        placed = function() return query_time < action.sigil_of_flame.lastCast + activation_time end,

        impact = function()
            applyDebuff( "target", "sigil_of_flame" )
            active_dot.sigil_of_flame = active_enemies
            if talent.soul_sigils.enabled then addStack( "soul_fragments", nil, 1 ) end
            if talent.student_of_suffering.enabled then applyBuff( "student_of_suffering" ) end
            if talent.flames_of_fury.enabled then gain( talent.flames_of_fury.rank * active_enemies, "fury" ) end
        end,

        copy = { 204596, 389810 },
        bind = "sigil_of_doom"
    },

    sigil_of_doom = {
        id = function () return talent.precise_sigils.enabled and 469991 or 452490 end,
        known = 204596,
        cast = 0,
        cooldown = function() return ( pvptalent.sigil_of_mastery.enabled and 0.75 or 1 ) * 30 end,
        gcd = "spell",
        school = "chaos",

        spend = -30,
        spendType = "fury",

        talent = "demonic_intensity",
        buff = "demonsurge_hardcast",

        startsCombat = false,
        texture = 1121022,

        flightTime = function() return activation_time end,
        delay = function() return activation_time end,
        placed = function() return query_time < action.sigil_of_doom.lastCast + activation_time end,

        handler = function ()
            if buff.demonsurge_sigil_of_doom.up then
                removeBuff( "demonsurge_sigil_of_doom" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
            -- Sigil of Doom and Sigil of Flame share a cooldown.
            setCooldown( "sigil_of_flame", action.sigil_of_doom.cooldown )
        end,

        impact = function()
            applyDebuff( "target", "sigil_of_doom" )
            active_dot.sigil_of_doom = active_enemies
            if talent.soul_sigils.enabled then addStack( "soul_fragments", nil, 1 ) end
            if talent.student_of_suffering.enabled then applyBuff( "student_of_suffering" ) end
            if talent.flames_of_fury.enabled then gain( talent.flames_of_fury.rank * active_enemies, "fury" ) end
        end,

        copy = { 452490, 469991 },
        bind = "sigil_of_flame"
    },

    -- Talent: Place a Sigil of Misery at your location that activates after $d.    Causes all enemies affected by the sigil to cower in fear. Targets are disoriented for $207685d.
    sigil_of_misery = {
        id = function () return talent.precise_sigils.enabled and 389813 or 207684 end,
        known = 207684,
        cast = 0,
        cooldown = function () return 120 * ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) end,
        gcd = "spell",
        school = "physical",

        talent = "sigil_of_misery",
        startsCombat = false,

        toggle = "interrupts",

        flightTime = function() return activation_time end,
        delay = function() return activation_time end,
        placed = function() return query_time < action.sigil_of_misery.lastCast + activation_time end,

        impact = function()
            applyDebuff( "target", "sigil_of_misery_debuff" )
        end,

        copy = { 207684, 389813 }
    },

    -- Place a demonic sigil at the target location that activates after $d.; Detonates to deal $389860s1 Chaos damage and shatter up to $s3 Lesser Soul Fragments from
    sigil_of_spite = {
        id = function () return talent.precise_sigils.enabled and 389815 or 390163 end,
        known = 390163,
        cast = 0.0,
        cooldown = function() return 60 * ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) end,
        gcd = "spell",

        talent = "sigil_of_spite",
        startsCombat = false,

        flightTime = function() return activation_time end,
        delay = function() return activation_time end,
        placed = function() return query_time < action.sigil_of_spite.lastCast + activation_time end,

        impact = function ()
            addStack( "soul_fragments", nil, talent.soul_sigils.enabled and 4 or 3 )
        end,

        copy = { 389815, 390163 }
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

            if talent.exergy.enabled then
                applyBuff( "exergy", min( 30, buff.exergy.remains + 20 ) )
            elseif talent.inertia.enabled then -- talent choice node, only 1 or the other
                applyBuff( "inertia_trigger" )
            end
            if talent.unbound_chaos.enabled then applyBuff( "unbound_chaos" ) end

            -- Hero Talents
            if talent.art_of_the_glaive.enabled then applyBuff( "reavers_glaive" ) end

            -- Legacy
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

    reavers_glaive = {
        id = 442294,
        cast = 0,
        charges = function () return talent.champion_of_the_glaive.enabled and 2 or nil end,
        cooldown = 9,
        recharge = function () return talent.champion_of_the_glaive.enabled and 9 or nil end,
        gcd = "spell",
        school = "physical",
        known = 442290,

        spend = function() return talent.keen_engagement.enabled and -20 or nil end,
        spendType = function() return talent.keen_engagement.enabled and "fury" or nil end,

        startsCombat = true,
        buff = "reavers_glaive",

        handler = function ()
            removeBuff( "reavers_glaive" )
            if talent.master_of_the_glaive.enabled then applyDebuff( "target", "master_of_the_glaive" ) end
            applyBuff( "rending_strike" )
            applyBuff( "glaive_flurry" )
        end,

        bind = "throw_glaive"
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
        gcd = "off",

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

            -- Standard effects/Talents
            applyBuff( "vengeful_retreat_movement" )
            if cooldown.fel_rush.remains < 1 then setCooldown( "fel_rush", 1 ) end
            if talent.vengeful_bonds.enabled then
                applyDebuff( "target", "vengeful_retreat" )
                applyDebuff( "target", "vengeful_retreat_snare" )
            end

            if talent.tactical_retreat.enabled then applyBuff( "tactical_retreat" ) end
            if talent.exergy.enabled then
                applyBuff( "exergy", min( 30, buff.exergy.remains + 20 ) )
            elseif talent.inertia.enabled then -- talent choice node, only 1 or the other
                applyBuff( "inertia_trigger" )
            end
            if talent.unbound_chaos.enabled then applyBuff( "unbound_chaos" ) end

            -- Hero Talents
            if talent.unhindered_assault.enabled then setCooldown( "felblade", 0 ) end
            if talent.evasive_action.enabled then
                if buff.evasive_action.down then applyBuff( "evasive_action" )
                else
                    removeBuff( "evasive_action" )
                    setCooldown( "vengeful_retreat", 0 )
                end
            end

            -- PvP
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

    potion = "tempered_potion",

    package = "Havoc",
} )


spec:RegisterSetting( "demon_blades_text", nil, {
    name = function()
        return strformat( "|cFFFF0000WARNING!|r  If using the %s talent, Fury gains from your auto-attacks will be forecasted conservatively and updated when you "
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

spec:RegisterPack( "Havoc", 20250409, [[Hekili:S3ZAZTXXr(BrvQadqkcHDbHKSpbMYpoFX(8PKl0j3hUkCXsGfK7raSi7drZuSWV9RNzFnp6EMzbaPKDuLQIfXoBp90t)E6P3R8U6NV6YfH5rx9E)r(tgD(OVCO3R9gp5QlZFyB0vxUnC(DH3a)JnHRH)))y4hsMZ(1hwLeUG9YzjfPZHNCz86IvH5XjB(20WL5xD51fXRY)HnxDn2e4pXhE1TrZV69tEZBU6YBJxSiQCSrzWeWg7zJo)SrV(R2n77xf9l7M9N2gTjknB3pU7hlF64Z8ohE6LpSz(Uz3hNFl8VJx)TIdyKNXb4FMpd(9xhVjjDG(iHfAAYY4vWY73972n7288TzF1RE1nWakUE48K1VkRzvpNTQz)98xD9QKRFv(Tr3hMYGv8Mx91Zzd5pNgNKgN)WpfNLN9QfrRt2CBXM8O0GBzK1HSxE3pYMP)62DZYt2nJr4eriaz)VctNd)1xUBgBnSB2zW)2BjqqdzRRq(eLnCBAeGExhMF60x9HW04WRxf9s2w40804n3fL7fKbtCs8ISx(HWvfn)(qVHXzdJxdl8peNfTiilkCjG1fRdawHO1H3fL2HPXNAA8DzAakX3ScyaxbeSDZGNduLY3pRK(CBYQfn)2UzZtG)o5(nzvd(h2eNhd7oFaiIHBGr((O5rzzHPpaKt4TUd(9vXBIoRaO3jf5zXlGFjlhgByQiGbeDv06On58T6oS(9cMd74yK41Hlc(hfrrBYcwZMV8OhFuAa)FfBUBDyuwEAcmKOBcHXDZMOCLHDtuy6nWpSaKncY2gMgfCx0dzkJkn8drBskYcUnzt0dbxx8p)NrPQqknEDW8KfGWM7lqFSfOVTfOVBlqFNwG(oSa97(cm9MaGRDr0YWIv5th9YKTttJYaUb03nl(M4vbjldwUcEz8XeVEDsPYIGWIur5v4HlIZsl2Mxk)))(hJUlEv8FF3SzPr5W6pkhEL8KGW8CqEygWrc84BseznJwmK9YWBdATIcb23VPiDt8MB2n7)jPyZIAHcysIbmCw8MDZaLx5XLWh47NhTbOajzL4qlQHHcVKj3emFXuVxw9W4Ltb9OF1IORlwUC41LZDW9SPEykirhVj7LWyYdxbiR8Z7v9JCvIbxVkemc0Jn)FikyrIYGFxFWUXQvbLtB2f)HXdoie(fL)jWGeCDs2XbhNIIJGLScMQNBygYa5bylAlOMBwgWIaANeygK5excVva8smwqGbSwythFoPV3VVV)WxFs5sgmRaAFhCs)(IJnRaWPE8nP1aDADs62BtYaXJITdoz8PE(dgCk)PkSRdZyW8Kxx(WCgYopCvaqRbUTC4TpXBeFr(ZXSf14XG(Z4YLht18TrZVtwhEPU3ITzLw4YKvphc6vwgppIMSWG(4XbNVngETkIs)smVrVpGwp(4lQw(T)8GELdCt9egKvpFLVbGZa3WMISHI2XzwPYaYHpmPZl3r)UKcaHaRhG0urwKWIJzBIl9vk1LX)3HCZlcMQeEbUfQWncWAriOruaMKKIfCSiaqn49QifVi6FueVDlOwa0nbQvzkNGftWwMxip0R9X3cQnJypDoy0d0R2xYQG6tLEigKh0RDi1RYAfax4psa((MGVVD47JbF(UYFLVtWCGkcC)aKYz67wc8zCIjyQinJj9fb7Qmo0e4rW)c(hCFmzmMGhAdB1IhMQrY5dDrfTEz4kygzZ8LrGfkUxBLVlhsv8arHmp3GzmHHfrsS2PfGug)VcyVs5CeM(sW6y88CqPfOwI9MbSxCy4QfPaWIbPp2IPYOXLpaSW)DUlHFF4Qvxh2iXTnkzlJlDv0ha1smorBt9YmPP(fgMB2)dM(VU633n7Vu9GwQ3untRXBMlRoJlpMgTHjZeKXDoBiBRTut1nRczkAxUQin9bqeTxZopxZxWIWnCr3E3mVXAZuGxREEhwoL9alJFiGngpqzyy(Tbz3hfTvZO72yq7zX2GLPH3WSTAYGBJHNsUe1x9LLS3lzZAjTKPo)Dt)YrgzVwgTk46WuairOQ9fEEV(nedHFTMk8o2QDD4VCYB61VYCfW4Uook7IPGjJ4uW57kZuNMggViayra4hUyrgiEbHN84JQ)C8MwGI90l(YrdeqkzRmvO1JpQGm(dE8r(wT4Aamj17fkO9uVEVqDoJ(fMy2afk68Bdbpll5LyeEmwmGLbNbRViRZISP(iyCpMNux4PUtgUzt8TXLMoFsMxv(1)cyxNfJtfN4WsjZSGsGpCf4gaZWWIzn2HZVLzeIjnWzKBSpvk6(faV()b)DbM7L5mnIcQhv1lkpBnly5vwROmPmE(TPXRwvRSFz8n3MhuAbuJx(8t1itdoTLJJ9(SiR1EVXmpCAhx0drbxhfUwFC1E7Lb0jy9dYiGSsE8MhaaOTfPONzbJfLq)K2i9Xhzfcv7NIbsd3DfC1AWdu0)nONmV07g3RYFDWnOiyIdUg2nVRCtPCQdtBS)wXoX9d8IXvIROs3xaCT0uzpGGvUgA)fvz3NrMQZFIjYmIHnsPk5qvtgyohZ9GGg3iv0i8(eESfGX)1m(jWYpeAtzmFzXRZy6bc3CtP7PPjRbb)c4rLPPA3SFINVfM)tFlmXY)()wLoe(7(TFhprm3CZkEAQyJ92OvB3n7oMv1zZbqxWLJCD9uQHHhdgOA9DEt6vc9gp9Y6Hi(Y2Eim3WEuLSSelERyNmNpyXrbxBISpBBCoNt0GitDOg1SVRdtVRrbolmrXhCbihublXFUriAQ)zvGdCvF(Dm)nd4yJMLocVhde9Iaq8ggvrVhuTLwSvb4kXbYaKkdET6sgaxcUu0sieMjH9ie)uUinc4jb)qcy78dSQxsEBM9aJkKMOsY2NvLoPs7NAeHNq9OlMqV20DK)VeDFs6Ds54e00XxhLsOLpUmfXC3G4cMmIqEipYuqLyX88I0iv)nJ2alRIMi41DuvlSzmzV6vfSGf89(DJgcA1K)bbtDAMeMkm0EM9Ce83cml2Q0nxnH290EwBwOfS)Q)E1XvM7n82qMJJHWo3MhcwSv7z1OyV(cpqnA0w3jAdRfzyxmE0aD8YhbV83h8spk5oGxvU46pQvIgcMof4hknVwS5Aw(Uc4UAlkfwnkiKX4BUb8zS1ISUG7ruBwBYEKYthwqtibBqOHIffcbQRG5WBXNrEiZk0lTOyqiG1rfiLaldQc7owHU5aZHcYAqsD0Wj2cURgARssUd4jd3eaULSslqgpx34ztsdYRAF)WxSIdRKUAYNCM)I0QbNqt6UazdVjAylQgbP1waRQ5wBON6PfI47ty5KIf23lRTwSnnzEg8xpKuaMvyjEKFmaS0gDwEYzLPp6hAmtcUbc2jZ4jWQ(80yWJfSiyuc2mYbIAnW5XlcUA(vThB693F)qMnXRtYZQp8u4FdU6Vnjn)vl8NpEt8)5hwC5F7HV76)7fzHFxw638Q2df1M57Apg1e0Q2UddygXbp0zhZxp0C87M8e2C78ua7BSnobFDAuh73RpsYu0FbnbjL840DxDuaWrmtriOVdONs4qtmkqQ6M2ZPtu1sRmKUVrTgizkJzx5ZoY4mEDyoYa(LaHa3ZsG2c7CSTuAD5tBtvevci2RSrsf8j)yLrKCh3ecjw0eKwgz5GgCrAz8848lME(OtBDMQ6WgpHzN)fewqvGCvwzYJwVncmBRJLhG(d9CHOqhrx(AOy(TPj3lKnjvxrACrSinMvgb8XN161B2CaURzBvxNwa)wC(dGrBUsnEoAruRBsDGTuvtZ41ySGnNPpCXBvPpIBZAMcFbQHkx5Gq0u7KgFBgS0syMvPao(MuWZNwAi4ouPFBoKzg3tiH)ev829JEO8K2dUoox1IHkJiryu9i4Lu5hmTKPzIEBdVl7CQ4Ox4Ql8goYRkshDsRQaJoxxqAr2TFsUKSG7HPG3VawLKcQJZ3l2l(z65nAKyn4jKEwysK8QK7UqFdRMPSdkVIJD(dZxXpHCWzBqOXqagt9gpOLtxcnjmt0eAROaqjPgrY(C2P3tLwR32g7TaW0tg(G2XX4nYJNdgwc3KXZvnJYHAPgmHxhNgynkGlFPLZ1S8vWYlOSOkn6Z4fcEoGNx)bd6PgbpkHv40GkljayFJFQGYzC0mRGr3B73N6KhA(DFIFFS8VJg)mwqpk(xnGMNRRSBnC16NS2VEye7tWjs5jy7ePWJsZ8btIm3h(Xymypy)2MW(vUAoKLhy0dlb7SDosninhdUszueV5dj3bu8FbwQG24a2R7APuiIXyWPm5qBtUh2dI3SSilw4W21XDKL6u)ruKi5AXGvN6XW0wfIHC9y0ugvy17AZdz5PzoRgAyUwYyYwhNZ3)BlsR7ctx8a8Y3awVeFvSAGs4X0vrBZqiRG2wCNL8M0GvjZVBdev2Q7eEgrL12cDKQQvMAYoybWrO1LutD6uP1q9Q0RjvYsvZhNzBYa0JbQwfWeuDDm0zqp5YBthB6juFAnQ9waU7YwA8ZUg551tm7XVO95Siz5iceL7aLABZ0m7zzMrIXvAM9KN5bYC(x4X8UanCyLFGMeB4a6upn7jUXxqiIWtLUBczMPO4KCduuPvH9npdCfsqAGc9bIZWncKSgcUqJzcJ60OwCLsWBpOeEgGInQakVSnPmHNJEImYr9ttjLR5uzpWKkQa05apvs0gtu2fruN3K9AKZzt(80QMEu)4QoPUdc7OSMWWW2e7jw419A(zPIqwvjGRiaHTQNV5VXA2EmLwZWi98IALLZzsGd9Lylk9)SLjwsPCTR6g0yJ6e)avJLOi5ZL9sltUn1iFcyYeXWOIdZl41ynMzWG8WmJ37hkFNTasZjB0BIPtMCY(QQjBvsEZnKR07p6zP(4pvtIdL2z0agnWLCgBrsgl5aswe8f)ewAdK85q11A9t1P8scQ8Ek2vLFiXoQ4PjPe0IrPq)rKblIUN5)SUNHOwX99m)oUN574EMVYEgMhvYp8q2ZqVjnK7z1L)m5PJuATqzZ5aoJgE9(Jx6Jy13ytshtLRt9s0AFdRRRXpw(Fpg11e5gXNKLoQLZsVm5rk5XwipAAzhP62mMKguSvo1intu9rsPQFqW4I8r8Ooq3rM5lcwaCOk3vYMS96BasOxBdXK8PeEH8Blwja83uprMQAdrQNuuXRZve1vMyrEj6z3E4sYGviBKKa1WRJCuHQRFFIl8JHJfr6eKoDSjYI(zsJtxu3umasLIdORKKLYLVi)0B9gnc123xoY01UI22356z52mgzTw5q2Imar9tQvQsdoFuhHNggk)M9uGU78ZSx8SgdVnQnoB8KlgHuBO16JgluFlIk(AomEHNxxjfx492UXOsIBJEUXnfo(pDiA6hz7HXNj6YehPaiCeDq6Tg1GRA4HImF(iEHy)CsNvRlflOMOfFv0RNPhYJJUsHiQzb6L9jARPZih6y)bxyCRqQUnKghZ0jHzrJNDk5XMPg8)3ZUO2ll4fzyzb1UiQmANxUB2x)N)PDZsJ(qm7yUYAV)Mjlky3URRJY53sZ0OSIv5LpFtZL6KxlUH1xUQ6efuEl3lVtyF9F6FxO)FONpbKfFt70yst2lfRttrE6goGN1RUvnsVx3ZfQdvvazfignz4XAHXtDA5MZChRO7FTTbXUxmgOL96cPuCEjk7ctrr0wi6JgoPztu5SVDQOcowbLvXli6ob2mG4)JnkeXv9vLsCIVLR1u7ihJH5AE5Z1woD8OE2Q(fngH(gw5dL7xk8FZCeJn4ngwJgs1(OUSMXW0dFhRIvnHQnClIH0rRnHMeAJ1IIxsHWBtxbD(1MYLRSXAkpi09UjdNONLeXTKAnB6fv)3MS(AEJvXhmBfTcm(uKDBzp9jJGajxHG2jq9TPovlyNhF0Cv43w12DfYO6tqIYTPMG1IS0TYS1OOJcRR9mWkUqrLiSOuQbmOlFnLs1hIjhzTF17BQcVZnueAxyxfQOSkIz52RqLIQoNwtCfTso3AKXIqIJNydcRyQfAO(r(IuuUktSqLQRwyDgocNloFWH1Bcq8meLOkKCml3MrvhnWaNEiZUuYWMkd06QP)1SmzF8I7tPVwuJ)wVvh(DtxHAnLxZjKuSkBEykXDBWD9tar8qUPdkhYjdTAApszoFMMe6fnRERAt9XhLN0H5jan5IrMAzaVBIueRLjWgxNXEIthL5M4UrGRkDcr19BZHg1KR4Y9cIgbTObWjSdXYl(lRCRdmyY8pqt4oQkfSCJiXyQS5p1hTBwbbnxv1cUjdQuTuMNItRRuz8NjMXoowGDyI8h0HEge(uTpzqGNVau3Ay(Tz0GVCyS7r43knIdp8vvx6szgCLJMST0qZqO6pL8fcli)U2qeKz8E3uFsuRr25JdQDbbMPUR0GCn7)6meMcIfFw0CYvUAYqtcaoRStPg457WTTZjsy5sn0tBzvX9KfCieo7lhhZIfs1cIIwM67s7HS1Zi21x3HPgpUuf9CGnXrm3YElQZeo6BpQLo8RMtpYUZkzFmSvax7r0q7XhBFeqSyXwaVhrT3qyIdRwCSVDWVFL1NQhMDYUsut16VGyAC2hi72983rZbyLCGwld1nqDqDTee2oAkG04iIiXIgW2aZj8)H6wFsEJ6SvD0u1an(suVYUooM4mx)lwuSqGRAvMK((OHMibf93CmUyKsxp3oAVuCjdC9EbMoQE0A7qzonKZmlBc4lfQ8JH63hfiqBPacHPivjCLhCzZhMJIOQ2093hT6SlljkwB71oMCMLztDRRx32XrglKfXLSMqoEhbDzMqho1TX)jqheTYwx7xBHYCP(UXNwZeMxSa(VC9hWiJsbfTNIPmEGYQgXdfxItrnehnp5AotqmmJ(CApRrl97WA6dnAdiDOaz9P674HV(Uy8t6YtDnq0o9DTj2XHX(KXHNNEZPLtKJFNACrn9jJhi43i2(I1Id2QjDXdF3jga85X2bTEXupHwoa2myTUq4KnAPK6R2NcxIEMvDAvIVbZdt3c9SDVZPfKt8b(QYpIUR4Cr93mvQsocBsJmOIFGLJ3dV7Tz9g)Xxqk(WtlM2WUEUHIgt2kyx7fw83QJrceNXgn4Xe4z9dnNLeJLJRnuVFlAFfAWSMYrnG0yY6pA4KFFfGe33O36lNS2edu)kSYtsnXpQRgTmHzqq1MMIb2YmGbkhGQNwZF4M5mIRur9EGQCNkVK9DrgFA)Y6q6nJoB8iZ4vFxrmAf)Gi3GYI7SezZVnkHhc8j(JotJrrDbUVDVmh4NpPVNjF7owR9dOpQPjNXjJ6NCdDcw(KHky1kiXsJoext2U33ohN7F1AuxqQNM)VEoCpnF4r8AMdIpAljl4(tuNGtimwS0JzPrW11wS1VIAKwDl3EULXWJqhDZGbELi7del3mgQ5wd5YgdHPfk6nKv6iajRMA34FOBrBu5))xn8BunUTUMm5o0E2mWl13gZevUjr(zLWQQxQcax6gzWzv3hEvRnpocu2XlbZb0Y4KXZNHwgN8ekN91p3Y40AvlueUp3D4(C3HZoFXN7oCwiqFU7W1LUdNrk5rOdTz1hn9JmcRtkHM539R7TPRS0nyAOHSHbsNBOv7Jr9pQ9YkcI0)k1lRm2tQqu69810QCyZ536nTkJnFktBop5DNk5nNU1DQCVWzeBY2Tp43yDAk75MabJXdLzmPUTU02QA25rZuHHWlLMCgsp941AfKIBxceAZQ4YDrsYABNIkF(eIQw6LTLBqZNpsF0Krr4YqnJ64rNPN0CZNg(PkSH2pbn(RIXJpO9iPO1R2CGtm)IiY4gTzB5ZT1aWLZJ(b19hUrTyjuOy0y7nILkbNEP817OSuGMw37RWFkV2iAMe8Jk0E(D04v1YvjvRzauvHLOp9SFIMtPJIAoIuwArAGvigUifu9hkscN4nCITAsPKSJ9m56qa)eUaRbdm2GZm6JQiQJnoPcPSveqrVkA5rIkvAI)rRQ9LVo6O7osJVzDGx2TwVz6tNqFwLArKPTucV(HSmWxMBc)NrLrSHX0A(CqPR3GApjLWc27GT909EKH57oc97FG9wdATfgvlWelOVFcvKOncxMPb7ZTSXfkBFuwFlipXnbYKu8tzZxOD1ThxQjhCJJWydH9assGT6PI14r6Tpo8u1vt2pZd40P6fPze(CPp7XM3orbaG3dW7D)IeLtPo7nLcL7a6QkpRCbQNDh5viQbiQxFlhyiEnkPXLoOIPTmNKWpqHyPLuD5Vj3TrWdqTd1xPSHAxmuQyJw4JDk19c9jP1KqYWPNHgluldFvUzZcFjq4koAypMpedQ4knYSTxL6c)Zeinx602td2SxTQ2aLJQLWVsQwWGW9EW4fIwDsz98Wc(NyvwrOAt6S1lldKN6HivuPEifvkQSzf4mNaenTkSFfvDKGlN7binfo57o3UPp)MefCIrwHg4GhbJPcP3gsGx6PeHPyB90OFZujhEI9mfH6jXrPN1qBjYSBehupRXfdHoo9DDA(TAlzb3L7(4RTs6xhkG9bo0mDW3kXE(V9(6cJ7Q7VgXFIgEZY67S4uHARsZLdrhVQ)zeyOWK2SgRp0LHc3wo5l7r1nShhMINzJS)F4N8X(GRUKagTl7(up8t6NorbgsUaUDxv3u0Y5j5sRZTbdYyG0D51A)y5J16wlIgC80EruCCrR95CaoE9Wj60Rs4MNG8uPvf5JKWZCp59OjSHMWmADQMZNdEsfKzSz3fzlEGIV40c2cVuFR2LKuGBSVYGpBAzwuBYqUf4QzwK(mEi9l14U(aCC1L0)RIPkz6NO8ODJ240eQM0vQZ)bHotSS74LCSJT7ek5Q6(uJ1G7mDWcQmd4tR0OOv0UNAr3d9lIXltqa)y3NrA5RKycknVctPctZWk3aNoIGj7aJP3QaRDjmkqi4QjQ5qZ9kKRUKvTmWBD179h5pz05JEZvxEFixej7Ql)z2huciW3Kuia4LSVBfFXY2ki5lyFhk(hfSqX2bboVM9XNOipzn7oeVBgqsbLUSVXe)umR7Hp5RyTs8nW8XF8xyPMYaGNNimSC6X137xgyDAqQtlTPaFmpPGVlaUsyWeCBhsxX6oaChaRyzTHasLh7iU6aqzo7XgI7a1nMp6X500GubNi837nZ3(c(Uayk(d0H0vSUda3bWAKpr7XoIRoaukMVx)8O5JEA2h68tkWTc2JSCj90yf7TRC94c8gW(gtKg5AagNSOngjSMc873g6tkWDaS2jj4JXjSE)2iFsbUvWUVMeCeR3xWBfW7RFuoI37l4BaSN3rMIOG4hD47cKDW2gLbZddQuwmna1JIKUz47GDhhnjBEEiUkg4tg9GDBg3p9mpTqVfU(2HBNKxvX7Jn8DbYoeUcPu1bbvsPkAOAxQYbxkmdFhKQC0BoZZJRsvwgSBZ4(5qZtl0b4YZBZYKvRsUN)HbLLJRSDZUpI9jhfypwu(1aT87fkpRr1FKqVUiVEC8QEyjlnPIJEXc2GHTLWRdZI(QD)i)BehWmYoQt08f9fDknrQeJKTvFCuZkXIVOJh7Ud36Lo134ggTHnB6DdpTkMREKFI3h5AwqnWYw)KRMj0TDIx95DINUDIHesDBtJMNS(6W8ok8zYDfygst(qCg7JWruimpXfRd2c2bwhEhLxlwFhjfHg1RBfuiQ3T(ost)4NhNcnonu3SF8jZWODFkjU4)4Zi9GDFcr7Am4th1qDFYaKDDW8Kfr)cXcs85sG98NhVzmonoZoyB0UpLUYoyzWUpHUXoyCOUpzgyh0FEfyr1Wc29clw1r9R28TPY4a)u9c4gaZQnkCsFVFFF)HV(KWCwLahao6Nhn4KMltSqXyxBgb9CIhCY4t98hm40YdQu5Cq5vz8jVU8H5mdRZdBTsxS9eVrn0nJ46R(0axTYuW1bCBszrcfmhcVHqXN2yCINRmxei9zg8jHyKoov7tWcpPa3ky9DG6JpgNWAFNP(MgPJtLvcK90RCCboLMRW0pFc(hrW3fa3HDVUJ1Da4oawhYZuxpevNa6Npb)Ua(Ua4oO4U7yDhaUdG1HJoORmFob0pFc(UcCRG9ilxECpK9NuG3a2pFc(otsosNRNdh7Bh2iFsbUvWUVMeCeR3xWBfW7RFuoI37l4BaS3ZAUPiNT9DD8ud)ob5oWVVh4DhGUlW1bNpjpp2dcQKNhlnuDMt090IzGV3oNIdkAo6WVtqUdgJ2d8Udq3f46GNODMt0jOsYj6qEF60E3tn8DbYoqpiPYheu3dQmZhy1(SpUvhSH1Hz5W9XYm8DT6l6unnDCZl2tl0BHRdPSPtwMvX7Jn8DbYoyTJuM6GGkPmL58czvMICyDywo8q5mdFxLP6ufnDCZPZtl0h(jwfnXB0dFrNYDU3BLPiAh93tFBgPMsFGZ0RCyMgsE0dDKQrPBgNh0fgPpAa(qnN8uHX(uEu(RqaFG04NamE3p(dCjag488K1nX4ZV6s()6QF(QlfUzTWF(Ep2VvD84x9nxD580yqpEC4vx2h02cYk1ZMAbNTB2ftH1YODZ6Xh4lamf52txF077M94JG6pIpBxZgWbd)HQF43QNa9(SeGc7MD(OsqJmIwmD3S3woQwSuCAAWXs0qUs)4VUp)zYqa)JfN8cM1P85WuQb)TB272nB8iPLT2L5wJUQ0UeANOEcBtyxVE2cOsD6UzNaZCjUH)XOJJuL4v7uhlxHJkpLydVe)jRfYkceBTt0QikjddQHKs3)V89znvf(c0Bcm0RUSKZ)QlLkYJRYV69(My0nt(kNEoMQ1lfKi(6Yihdzd(YSQEov74LYGaR3y8V4Yw9pCXl7YkntfL4IWwibhWahLx67IitpsU1gro0YlMt7A0uitan2JKKichMC6ys5ut73tixA1RAcXRwmPSDPXqHZvqHeyuzr5TdTEfY(xRyT3cdFz0kNDBFggvgLCCCQpePaIugcvjAQmmI6QuzuAXTQ8C08cZjsbS2bcq7K)s)WiXtuiXnSdA0pDxsenl10wRK1mukXl(LetMjCIk3nH4q5qj4Sumpj4Ig6znRnoKSJWzM9Q06AWzYsjPrTAnXtJrJIvLeryh3qYgkoUP7pkjU5PJBdWKNzVU)iR649gr8atBOLtiD75IpP6GCYvxwYkJWFcCZVMGBMqyxKL(fIcA2uE40gh9gSTnnL1TZmo2yuvG7auQmZrGgYmfHdO1VHGwlRYurRHluzm8bJiOQB(ajSi5cFFiQucLoRzrBGdO9JOEBsHMd7oVLA3bXML4EuPM53HhqjQ7uIjfQoesrhKS4PoQx2g0243qrAmI4pQHoGT6aQXxsqnOmpl5TJMnS6zJ8THz0BeXusyQ3TzK6LztOAceA19X5X86ukfeD)epybpJo6nWsanMLqoR07ug8TeUZa7w3SXpnrmkBBkd0gdHMyTXr6UzJmg13Jr38bHlwacaRsYf2Yz8fQXBRWx4)PjFbQcXdIVq1JS9IVGYWJ2yCGVW0530D(cclEy8f(C(c647m4vwjwvTTR(n8KpHvw2W)wE2URuhQVWJvcbx69f((EwJehRWfoMrXi(lwnEwVg1BJ76gwL6OOUNKctREJ8)tzPUrqxrvFcNZ4OgvURmoUKBVoLYc5VNPxXWUlxMHLm9frzawUT81((OvNDzzo5AH18WvRck)Jawk6ltuFvCZIPQ3ygmB8EYRKbip5MBw1ER2BwM6AyR5PAEcEYtSMOx(7))ZExln324iH)TKlSKIl7rM25XuLJ3A3AVSxMdBM9AKPLysuzBjvusB25I)TVaGKaDd0paPTJ9uJpnEcPibA0V7VUPGJv4mi12uDTzU5(RoY)8LAxD49HM2Qab48PRTtUu58n19YWYjkIrD(zkl(fB(YY2x2FgLfPOq0A5X409x2(giwTOOheKPbe2(rMavEYEgiDx64GEgPCysJBe9tLFRiVStdOQ)H0CyTeFR9hsLXHespLrfoLaOmV0QbbmF4DIPZoPROrPxOuJOAjHOFw06G3yAF8QYQWViP6wtjTZkZyGEpmJk(WtLrFxYEgWjvK5cPiJ1bAXYSeSLN90KsZi)Ut3F6hos6nWENucmThpBw(YNbFbfSwsjs1tctE(esEUY(ykY5qLIrBW0RbXmxs75HJDGkFlXz9AKUy6xJCJqNo2R4TKqKxQB7pqhHfi1oIjdoqL6pRPYatG(iPgms49CuSf8vqcSZiZfJIhRWhLZkZ8Dg3VVPMmnljYcm(ef06SANDUguVC(2M6)G6gCmvoJCIMC)KlyBzHlafmSNIMScKzjiSTGWeZj)ylg9rax19FR9ShrtSwImMU(fQ6xMj3C76mDOq5ETUNEXG8n5t(SsOKktLOP0ulnfFAWObs)aZTfpcZ6pg3Q4mAH04Y4sPq6bYJDdkWAw8wMK2R)Hzo37Sidyy7RjdDRj5jXbpMboUt7BRKUjs3ng(D7LFBB2toMKvFQGkcE3XzY6v6NPUCytIypon)a4E6iM27Ii0GOVGFCrqukRJsXx(eiU6Enczr5pJKygPv(WqeinYPRjxxvJ9UNeZrOTg8oGoM1xMVjc26EtQJj1)plKkJjpPUODkVBSrYExiYyOs5uJTRlyG0pgHT(NEYStrjbL(0Jk37Wm2f(Gr6288oOYMeYcl4TFHsyK39WmaCkVRNJw2O1AMZDxG)UvnlQwBivBAAQD5k1IuPMbHYxfkuhqFbzcm(7gCMbD5cA4mYOZhdYibmR)1dzJDwygnSgl0Ij7YNrudpOeY)4J13j87tenOu4ANLEnYC)fomZgtMYkdFWIva5Cbah)xAHVjkYFUlAuhV0(raS1hDqj2Yq6uxuZVqKcTuMly6JJ42dcYUtyflYq1FyjcSh(kqEFmbYB8BYp5sFfHVQGX8ve(2r8EfHVzQvjRdUmqI7iaI6Ri89ve((aq4lE25Y5ZDcWtyS9pvv5qa9TrVzbC3(ZdfY8E6dQg6a2JCimMfVV5aXyVxF7xv3C2zZpF7Q6oEt)LwU5W12i9xBvRZP8mSofXMmhuHZaBYpblvjqnZbEvO3pp4fNs5m7wLH3iv5r6xym9GfsiuyzojItMo1z0LFs3ARA0OtzDYIXL0xk(zL3YlBL1)5ZvlfNPOzlPkwvWHk3g812gGXIaFBdqeDx7TfK77OTZTKw6hso9EWJg2XhCpfWftz3n9ApfmeMg6zsfhttjntt2nMWJgtZGB4a(AuQw1OeEIprut5JspbxS5W690hUDmh)kmtIW0bs1yc2NdxJna8HV51MwGSPfGvNe0pb8LLvLViNdSoENH2SkHJLwqHFS)vzIUDXn2SZo3vJ5DXPXvTUgG85suVAqZmu1mhKQDQ6hQNiv)QXdNksfVwYG)wzrRaamzHCo(nlc(R2VPzUjCvII(OVgrv3Qe9SxSC(sJO7AL0BFiQeaqi8bNsgujJo6XWvdfA7sf0aLuqJZ5ZqIcqqsQaWfYvgtwd8pEOSdvc0uEhHNeOYhujhczWNUkqE9dWxcn2ujrhqeyeoQf5VFrcZqkOEGKIsDqdI80PuF((672AIUMkjhztrZhMQDONZH3afVD(1z8CFXc8so8CohTaJeAO(jQulKiJgp8admXyUIVqd0PbItvTNnbkHu0YeZ7w0IgKO3mZQNx1t7jmeRHEvFTWL8D9gSaosqcKQl8iei8OaAO7cvSNH6JZIU3aehTSBFeDyhPcqaqEQBNzVa2oPIYc(OQUJEjCafRrHxj9OKwsa4KeSY87GZN907g)hNX7FjV(zTZ0ZB5slFEpuJ9FPuZoXa2qqVdt3ufA3aiHviluSw61iJVLKMCSYp5SwiM0k(jGm7sN1PG2mBBWo)AR72aYzVN3Uo8teYEsbZfBQvTrtI0Tk0JX8X91sD1XqcYzF4uRdMrXige(Uzysgjwg9gfAvVzN8(8U5l9vodD30v6rdNBAVm)kRWhGlbAJKJ7dH07((yXDYOaaPOGk1rA2tum750OGQ9Wn7AJXXWCozoDOuFFBGQXCh)RoJ2TonV6SM5oBgKvmlSGsYlpr)ygwfu7XRaNrojS4cQwiljSYb1N1dtljKrx(gUi0EyY7jaxpmNbsSCXxLpK7y71krCZW5lCkRX2wOfl9fFcO)jhrS0BMLv5DN8oe91BLk(qpyRHwQI331rs2MKRbnMGEB3wtujcjO1oVJm23kZKnG3Z7U2NW11mLCp7t5LNWzPGiRkkz8GqOk)kaLsYyLG1iQPpwbVQfY(smAuCBY9FVz1T32deK2A9SS6U4EA6B4UHSqPeadXmvSgjsh5I7U(ilecA0fsLJ3zFIajYuMGvzckFGSUTumkab1V)rT8d5ISiYNkL59TaVDBQ0GOrQQXJFOUke1nfEU0tzu6R(KJQsCCnHijqX1m(z(fPtVFHmh2JE8qPYeDzISbkM63dRK3txMgoDMwoK4DfIwfFEQHjYuP6SNz3MdUPppYmyFpCCOzLRgW2gfeptGgU1c)bi2Yt75tAVnFH2rnkvornYiVFb6wmqmlEbsEZhr(s6lHMK7EADAPy1Fj1qPYiiNHlQ089g2WUODgtiNtzO5yq7MsLeUq3VMPCykUC83Kp8)jOjHsYqUAwLi98igpSI(sEf9Vy7OxHdxkfs0ofxEEUz4ZiuuD429(m85)nR21Cy7(ycAe9uVM2DQzDlH5o5iGsw)4e4xC)rPn3sM)nJpgghbM)9QDwKYpT)(cX8dMCFjH9tcmQ32py)oTlwc3)tROpM)Q3jeZV49HBAVD)TOkmOwSp3326ocEOk60S2LYB7YARftr7QxSz9syb97tQlv2I0jQtsdRKklhPzgf7r566fg(5kZkzxLzly0oIEoM1W8R3S(WoJt(1)OQ5hR2)9vRNVRUANHyvo)8TlCsQicWVVYUHp7mBQwB367TS91wAQ7RHMhfv3Au6EyRHn2(Cn)NFRF1C)vFUF5ajziuctLVjD62BuB2TcCNBGHYVpYxm(dPUPiums(U6GDugajl(1wQ(AlZ(1Yc6XOd2)PdW43FLfSGoiJ7pi)U5N7(6e6oFpSR9lvO5OFF1(GErWpOY(LiSAn4z1gXO)wGh7iGQtLIn0Q8Z1BRACnytltWTTZed3kZc4V2HBK9fvxhyusgYH2ALSW6sb0Kb7yrcnueRAKt21BeMVsOxm7IdnbgB1IV1yoBZDxxTNQsn6YfyU1v3TTzZ)D1olYUQRmKUvhUB(2QfgUJBWFiv6bd7ClOn3SAjzZUpGxF5OE9LOx)W1MI39CnRf(UK7dw89k2mS4BvOJxJEMGg)aja8pU1y(Q9takuDR5Tz)U9zfvbcI9YM9si)lVjJoHuOozx5dBvBFS1kHXhf7ODZjNBOtnWhS5m8267mwHQ808ywgReX40IJzxupVkhW5vz(Nxs9BbXZKSnL9mW9eJyDBwIrtnl5O)508T52wCR3xUppZRcIj(cSxDFaENX(Bh7WO5L2nSIJDzSRp3L9ymkkgomc7Uyxsf(6ThASHVHUgXSmagSCa3dzuloYki7RumB6kd50Da5GJCcMtMxjCm3CGOfvcbxHFaMoYPwLkWanIodbQMqQFXhhXPgGpZqYvVT7sJzkot5USAuDXXB5Ml20jgq0E)l4T0LX7iFiKQd7wi)AYkEifuKNrrCAYcLQYViV8YX610JnT4nViqDFGoMKzC1kvn0IioKc4pSci)yDkrlNkvER8WtqmrkMteBMIRnTgMuQGIh9bX7lHn0eQShJsjnLIj2A(ka)5rUPZGHJVK1zu2IVM3mLDI0kryS8gKivQqxwLYt(DzFmsFyFNOLekN3X6Ulj3Yw0o7PIS8lWi8L2PSrCKY7sdL69H8AWEi7EzkiPH2Lnzl)jdVxfyNGDnpRxrmOS5nU3XCOobXV(qZA7g9hjZiCcHimvLAU6QyKCeMJslvBHKZ(r(umUjXwK2wg0mH1futdjuXrAiVH0NwxJoqVnPQzJMQBQXKBFBhQw)TuUl0AEiiiiz3Ww4w5ZRcrNUyA2UsEBP5dMLc3roTvHI8T6WiN5QC2d4KwWX42ke2FzEiJGlOMujhFh(bYu5TFRmwjEo596akRpT4AVpRmFzuz(9Rv3URokfI)hx293yzLnhv3zSrE)vR(69x9dxc6DII2ZR6vglVg)b2yUK5Vm)HlTq2meUB)UtixPJi5WuM0WItK2Iybvvruot(KxBJVHbA(MXOZc3TsROnIG937Cr6(R(3DPXhLAoZZIkru6B9EiQqnMrlsCQMSTuGMF(q)VkXo9JtT8tFDC35LrdCanf1cbiaCzmUjBM2R7HylN1GuhEo(vCdEo(SMrYTobZ9TChe6qS78I7Ph4OXoZPak9Fglw(C8O4m7aZbC4I5am1lsaM6rcBVP9x2ZU2h6b7t8mm6duWIdf8F1TBofC30RDc9Bl3r9HZjwxjZVQmdxFXinq4WaK5oPrC9Bi0p3(osswspXqnLeUlNbmujClbvQCvpuUimZSOh1vtLI3BqHI94lHC(Z2jzG2M7jLmGHtjTCdpsXpxNWVLbI5w9f9Nb1P5VBdFCsh6NqmUqBFKJj8bMU80G)eYQQN3f4rGBlMo)taCEcy4iA62iNEtArKGDc7JWM1KyhfdeFsVjr8AK(sEzc2sZmVVIblROzfNOpQC2WNk1rrPOMHne)ZifmVt(w8aAoJC9rTdv)O2(c)lRQMV9xEpy2)obBEyFm(IC3eXDucUdKtl0pbawASdUolq1oPA9FmF5wYR3Vf6xIGl73DcEX50ul9tU0)LCGATxYS2lFyRDkC)9Gw7rbKK1ilU3vKr0s2fcQwgy7AlK9EAT9DUX0TROX2CHSgxGYX44wzvghcQLzNpAdoJf(cSHvtCQcJRCOWwqD)IkgZJElZQOYRVzRZitgH3ZTB2CJr8SA98Bmout6guuNhX0GWdRrBgGxj2Fyofgz40t4plCiRMU5ZZZWMVBL()T3vWUTnsm0VLCrqkb7weR2ICiYx6NqVNGKu42c0KauNCO9W(TVwYwAi5WhjhzN262ElWrwEefjhY3JKJX1OOFYqBkWMCJaFpDPsxnGVYzwVmnOvz)zfd0dA5uuvxuZ6a0yZqu0PPEWHCh5Mx9sISj4bpsxkP(aPKMAKX1qfm4v7fIz9g4A1zFoyx93G2oYdABioRYpjZxGtmXY1BNgiNiSQs)YIIhyrPqAJbhpJiot)oTmqikRrLxeEm015C6IpgWXjGiKHTVkouHxopNufO82eFbo4c3zfM8vzlEZt9iQsounAdCwgmRVBZQ4(EvRB)6ZB(Sp)KCei8Y363T4DkTd6XASbCHb)rTXXJIYRMBalbSIOAVTgDZB8nTJgTsLx9mPStBRdTGZ5m29abE34jlL1lmdIqXE1AdwWdToe9DSDYlB8cvZzJH5St6QhBcg7NEAz826K56Cmxwf(iPE16FmZ2YT)tcJy8APJy6u2KV094OFy1KAv(RNSD)WJpEFu5zDARpVFVA6vxmNuYGt)hH017RjZX2a(H6YtANagjd5QT1eaDJvho(P30u831bQgtFR0UenZLTeA09X3RNmyN6PkIPGaYUW8qBBzo)cJOOkpb43XnChNdz8v1saXogqE15My0IBrGEj5QOtOSTxudtOy1vn1gvA50tP9kQHN4UhoDZaBELBpqPoILD)gixe7sZiGYWrq)474FvoRxS9ZTZAD4Hx9kZqWhDkISC8SNrvTdHSzqJ7Ppq)6ffaqessWH2cl7xx)zwggPInJHwC6J90fwk(MmrIRIzJq0HIbOJnVQ0nhKwlmQqO2Q3(T1RV5lx)XB((0Ulo(kn(vRcTl3sbA2S1z)3fgGY(pQBR8sc(svMFyVivJEXnUx(wsbNa1bC5pA8B3Qw7KXpW6q2gRGJKf1mMtN4LxzTrb77(qw5lUI4ttTKhT1jczvMxfMyj0bNTq7aQ9w7b2J3qGMl0H9j7BsB(56O2ZxlB4i76BnYo59(LuL)ubL)d5RvOM1xTcE7gEgjWMB5OBueNcbXOiEpvPDxNa(Yjn5Junun01KEpv7U0PB(QSojoSQ6BLc7jqjCj7(b4GnarAxP(ap4U4ICKAPmdJTRyRawmzqo3W2fDgrlLfmNcHsCFqz6)i47qHOuhS)1C07xooaKdy(OZwre1ILbk)b6AyqmyMum51He5J()L6HT8OEiZeCqrma1fiRixCQSe(D)30G0ZYuuans2BF3udLboXXCtK2vgqlgf(R4gxqztrwn31)hdSxnu8aH8FjtqWrktV0SPU75asnnjv5x6P1T6VbZjhW4AB5mfnsOfcarpTavYP7pciIQ5CZIGclDhjsQTdcCC2JE)ekhoaNf8j40sqS3jmwyEXgftPFiOfpzUn203jXM)GhG0gLmzTwObPatuhK4W60OExgdVkdX9QYlEJTLHP6BBotRg1q4Wp4XgHIgARLX0Qrjg(73dpnNMflcXr)wsrft3rRuHkA6tNwa7guKMKCoj)M6X2DrRePWsiZ6hDBPamAjYAafgC8NA6Ckkqt9eeR3DsfPUqhRq8Z7EWkyQeY)RkqK4WEKHCMX)K(leC4aZuGyJtaojRMJaP2KDTtj1OUeRntown57Md3QplJWaJzYF6JNvx4r9ZcG8uKcMiNC8ZZ4bqjsXY4TZDmBvQLfK0a79eDfIEqBO4L7YUSHrGEso6oDWq9vdFNoPWW2tozLeOMgZt73CwALTqg32X0SlTIWi6fmthxfsBShXrreM(jfEHpXJakC(z4GocVG04dRoGGK4UrW(NHa0nyL9OLGu8BYvwlRLKLdzXqGN4rEnMSZvXgbJ4nh2J90CTksltEb)zdra4fIbEfsXP(Uq(qpe3fqEWnkyLcukhJ8AZYtEY7qlDE(mrHbvhoIHziEmqO6cEotWdtWYsl3njS8SudmOWWtgU(V2Zp9Ph)6vVFJT87g(KR()d]] )
