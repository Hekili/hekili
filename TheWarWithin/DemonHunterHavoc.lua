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

spec:RegisterPack( "Havoc", 20250413, [[Hekili:S3ZAZnUXr(BzRuHlP0kUeGIRx7BPs5hNVyF(2KlYj3hUkceIeucNajyaaxzLsf)TF9m418O7zgqsPDTZwPQ4ved6PNE63tpnUY7QF(QlxeweD179h5pz05EJh6nA85EV5QllEyt0vxUjC(DH3a)J1HRG)))y4hsNZ(1hssdxWE780TzZHNCz8QTjHfXPR)2SWLfxD51BJtk(H1xDnYm49f(JHxDt08RE)KV4lU6YBJxSiQCSr5WeWg7zJo)mVXF1Uzxg(HODZ(lrW)j7L57M9FKegZ(LOpeTE3S4L7MDF0ltsG)tyEb87FDwXUzPWpxCBu7OZlGLs(UFC3pwd8rVba(3Ne9l7M9N2eTokt4PJpZ7C2u)W65aCJlUf(3XR(wXbmYZ4a8pZNb)(RIxNMnqFKavmlDzCcq7(D)UDZUTOyt(x96xFdmGTxpCE6QxN3qsNZiPS)E(RVoj96xdlS7dZyWkE9R)65SH8NZItZIlE4NIZlYF9IOvPRVD76IOSGBz7zdzV8UFKnt)1naLjD3m2UIicbi7)vy2C4V(YDZyRHDZod(3El98NeYwxH8jkF4MSia9UoS40PV(dHzXHxNe9kg)X0IS413fv4fa7dzPXlYF1hct2287d9ggNpmEfSW)qCE0IG8OWLawVDvaWNfTk8UOSomn(utJVltdqj(MeGLibiy7MbphOkLVFEj9520Kfn)2UzZtH)o9(15vd(hwhxed7omERW1WiFF08O88WShaYj8w3b)Es86OZ2c070Tf5Xlk5cxVimteWaIMeTkADbFRUdRFVG5WoogjEv4IG)X2OO15bRyZxr0JpknG)VTRVBvyuErwkmKOBcHXDZ6OcLHDtuy2nWpSaKncY3eMffCx0d5kJkdemxNUnp4201rpeC92)5)mktfszXRcMNUae2CFb6JTa9TTa9DBb670c03HfOF3xGz3eaCTlIwgUnPy6OxLUzAwuoWnG(U5X3eNeKUmyzc8Y4JjE1Q0sLfbHBZeLxHhUiopB7MIs5))3)y0DXjX)9DZMLfvaR)Oc4vksdclyQiNbCKap(6urwZOfdzVm82GwROqG99B2MToE9n7M9)KUD9IAHcysIbmCwmOyguEvexcFGVFE0AGcKMxIdTOggk8kMCtW8ft9Ev1dJxof0J(vlIUE7YLdVUCUdUNn1dZaj6415VcgtrycGSYpVx1pYvjgCDsiyHPhB()quWIuLb)U(GrPKKGYPn)I)W4bhec)IY)eyqcUon)4GJtrXrWs2wMQNBygYa5bylAdOMBwoWIaANeygK5excVva8smwqGbSwythFoPV3VVV)W3Cs5sgmRaAFhCs)(IJnFlGt94BsRa60Q0Sn3MMdIhB3m4KXN65pyWP8NQWUoKBD(K3u(WcgYopmjaO1a3wb82N4nIVi)5y2IA8yq)zC5YJPA(2O53jRdVu372n5Lw4YLvphc6vwgppIMSWG(4XbNVjgETkIs)smVrVpGwp(4lQw(T)8GELdCD9egKxpFLVbGZa3W6T5dfTJZSsLdKdFysNxUJ(DPBbecSEastBZJewCmBtCPVsPUC()oKBErWuLWlWTqfUwawlcbnIcWKKuSGJfbaQbVxfP4fr)JTXB2aQfaDtGAvMYjyXeSH5fYd9AF8TGAZi2tNdg9a9Q9LSkO(uPhIb5b9Ahs9QSwbWf(JeGVVj47Bh((yWNVR8x57emhOIa3paP8OANqzetMtQ5mPViyxLXH24iAk3htgJj4H2WwT4HzAKC(qxurRxgMaZiBMVmcSqX9AR8D5qQIhikK55gmJPmSisI1oBliLX)Ra2RuohHzVcSogpVauAbQLyVza7fhgMSidawmi9XwmvgnU8bGf(VZDj87dtsUoSrIBtu6ggxAc4pEscJt02uVmxAQFHH5M9)GP)RR(96WaePEt1mTgVEUS6mU8yw0AMmtqo35SHST2snv3WJqamUUnl7bqeTxZopxZxWIW1Cr3E3mVXAZuGxREEhwoL9alJFiGngpqzyyXTb53hfTrZO7Myq752nblZcVHzB1Kb3gdpLCjQV6RkzVxYM1sAjtD(7M(LJmYETmkj46WmairOQ9fEEV(nedHFTMk8o2QDv4VCYx0RFL5kGXDvCu(ftbtgXzGZ3vMPonlmEralKTIHHlwKdIxq4jp(O6phVUfOyp9IVC0abKs2ktfA94JkiJ)GhFKVvlUgats9EHcAp1R3luNZOFHjMnqHIo)2qWZYsEjgHhJfdyzWzW6lY6SiFQpcg3J5j1fEQ7KHRxhFBCPPZNK5vLF9Va21zX4uXjoSuYmpOe4dta3ayggwmRXoCXTmJqmPboJCJ9j9i4HOAzAefupQQxuE2AwWYRSwrzsz8IBZItsQv2Vm(MBlckTaQXlF(PAKPbN2YXXEFwK1AV3yMhoTJl6HOGRJcxPpUAV9Yb6eS(bzeqwPiE9daa02Iu0ZSGXIsOFsBK(4JScHQ9tXaPH7UcUAn4bk6)g0tMx6DJ7v5Vo4guemXbxd7M3vUPuo1Hzn2FRyN4(bEX4kXvuP7laUwAQShqWkxdT)IQS7Zit15pXezgXGfzrp11SQ6kWMnMpabn(kQi2)(uEaeGf(vmMgW8omlLb2LhVkNjShU(MsFqZsxbs3BHhvMlQDZ(jEsvyoj9THSmZj(7)Bvkk4V73(D8STCZnj8CrXg7TrjB2n7oMPZzZbqVLlS466Puncpqlq)578M0Re6nUZL3drgLThqytH9Okbwj(4wzlz2BWSIcU2e(E(M4co7Mb5I64jQ5rxfMDxJwAwSGIp4cGzVcwI)CJKYu)ZQah4p(87yovgWXgnZzeUigi6QaG4nCJIUiOAWC7gfGReShdqQCX16ezaCj43qlHqyMe2JqCg5ISiGNeC2iGTZpWQYh5Tz2dmQ1zIkjBFwv6KkTFQreEc1JUyc9At3B9)s09Pz3jLitqDgFDukHw(4Y8aZ91HlyYicfH8Wpb9EBNxSnls1PYO1WYABty66EJQfBmMSx9QcwWcoy)UrdbRaY)GG9mn9(tfgApZUhcovb2(A1SwOM16EApRnvZcgz1FV6Ghl8gEBiZ7WqyNB9dbl2O9SAuSxFHhOgYzRpdTXUImSlgpAGoE5JGx(7dEPhkChWRk)y9h1krdrmNb8dL2q3U(AwsTc4(tlkfwnkiUW4BUbCmS1SRUG7ruBwBgDKsghwKriruqOHIfQbbQRG5WBXNrECXk0lTqvqiG1U(lLLkdQc7owHU5aZHcYAqsD0Wj2IGRgAjPP3b8KHRda3ss0IwXZ1nE2K0G8Q23p8fR4WkPRMC8M5uiTAWj0KUlq2WBc51IQrqATfWQAU1g6PEAXb((uwINyX29QARfBYsNNd)1dPBbZkSSlYZ1pl3qNvKEwzoI(HgZKGBGGDYCEwQQp0mg8yrecgLGnJcGOwdCEqHGRMFv7zJE)93pKzt860I86tif(3G)8BsZkE9c)5Jxh)F(Hfx(3E47U()ErE43LN9nVU9KpTz(U2JrnbTQT7WaMrCWnC2z51dnr(UjpHn3opfW(gBJtWxNg1X(96JKXe9xqtqsjznD3vhfaCethec67a6Peo0eJcKQUP9C6evT0kdP7BuRbs6Wy2v(SJmoJxhMJmUfOTWohBlLwx(028brLLH9kLJubFYp7yej3XnHqIfnbPLrwIMbxKwgppU4IPNp60wNPQorXty25FbHfufixL6LIOvBIaZ26y5bO)qpxik0r0LVgkwCBw69cPms1vKgxe3MfZQva(4ZB96nFoa3vSTQRZ2c)wCXdGrBUsnEIyruRBsDGT8rtZ41ySGnNzpCXBvPpIBZAMcFbQHkx5Gq0u7KgFBgS0YkMvPao(MULN)XSqWDOs)2CiZmUNqc)jQ4T7NVq5XPhCDCHQfdvgrIWO6rWlPYpyAjtZe92gEx2HrXrVWKl8goYRkshDsRQaJoxxq228B)KCjzb3dZaVFbSknduhxSxSx8dUZB0iXcTti9SWKi5vj3DH(gwntzNgEfh78hMNWpgCWzBqOXqagt9gpOLtxcnjmt0eAROaqjPgrY(C2r0tLwR32g7TaW0Z49G2XX4nkINdgwcxNZZvnJYHAPgmHxhNgynkGlFPLZ18Iey5fuw5Kg9z8cbphWtE)Gb9uJGhLWkCKpLN7pSVXp6p5moAMvWO7T97tD8cn)UpXVpw(3rJFglOhf)RgqZZ1v2TgUA9Jp7xpmI9j4eP8eSDIu4rPz(GjrM7d)ymgShSFBsz)kxnhYYdm6HLGD2ohPgKMZ6wPwjIx)H07ak(ValvqBCa71DTEjeXym4uMCOnP3d7bXRxUnpw4e11XDKL6u)ruKi5cUGvP7XW0wfIHCrx0uRuyf1AZdz5PzoRqzyUwYyYwfxW3)BReR7cZw8a8Y3awVeFvScDs4X0LkBZqilt2wCNL8MSGK053TgIkl5oHNru(STqhP0zLPMSdwaCeAvj1uNovAnuVu8AsLSuj7Xz2Mma9yGQvbmbvxhdDg0tUg20XMEcfHwJAVfG7USLg)aQrEE9eZE8lAFolswoIar5oqPa2mnZEwMzKyCLMzp5zEGmN)fEmVlqdhw5hOjXgoGo1tWFIB8feIi8uP7MqMzkkoj3afvAvyFZZaxHeKgOqFG4mCJajRHGl0yMWOonQvqPe82dkHNbOyJkGYlBtkt45ONiJCu)0us5clv2dmPIkaDoWtLeTXeLDre15nzVg5C2KppTQPh1pUQtQ7GWokRjmmSnXEIvxDVMFwQsJvvc4kcqyR65B(BSMThtP1mmspVOwz5CMe4qFj2Is)pBzILukx7QUbn2OoXpq1yjks(CzV0YKBtnYNaMmrmmQ4W8cEHuJzgmOim34L7HY3zlG0CYg9My6KjNSVQAYtslAUgCLE)rpl1h)PAsCO0oJgWObUKZylsYyjhqYIGV4NWsBGKphQUwRFQoL3eqL3tXUQ8dj2rfpnjLGwmkf6pImyr09m)N19me1kUVN53X9mFh3Z8v2ZW8Os(HhYEg61LHCpRUgNjpDKsRfkBohWz0WlQF8sFeR(gBs6yMCXOxIw7ByDDn(XY)7XOUMi3i(KS0rTCw6Ljpsjp2c5rtl7ivxzX0SGTBKtnsZevFKuQ6hemUiFepQd0DKz(IGfahQYfISjBV(gGe6DZqmjFkHxi)2Ivca)n1tKPQ2qK6jfv86CfrDLjwKxIE2ThUKmyfYgjjqn86ihvO663N4w9y4yrKobPthBISOFM040f1nfdGuP4a6kjzPC5lYp9wVrJqT99LJmD3QOT9DUEwUnJrwRvoKTidqu)KALQ0GZh1r4PHHYVzpfO7o)m7fpRXWBJAJZgp5Iri1gAT(OXc13IOIVMdJx451vsXfEVTBmQK42ONBCtHJ)thIM(r2Ey8zIUmXrkachrhKERrn4QgEOiZNpIxi2pN0z16sXcQjAXxf96z6H84ORuiIAwGEzFI2A6mYHo2FWfg3kKQBdPXXmDsyw04zNsESzQb))9SBJ9YT8ImSSGAxevgTZR2n7R)Z)0UzzrFiMDmx5TxsZ0fBz3URRJk4xfZSO8TjfLpFDZn3KxlUH1xUQ6efuEv2lVtyF9F6FxOjFONpbKfFtpZyst2lfRttrE6goGN1RUvnsVx3ZfQdvvazfignz4XAHXtDA5MZChRO7FJTbXUxmgOL96cPuCEjk7ctrr0wi6JgoPztu5SVDQOcowbLvXli6ob2mG4)JnkeX95vLsCIVLR1u7ihJH5AE5Z1woD8OE2Q(fngH(gw5dLBkk8FZCeJn4ngwJgs1(OUSMXW0dFhRIvnHQnClIH0rRnHMeAJ1IIxsHWBtxbD(1MYLRSXAkpi09UjdNONLeXTKAnB6fv)3MU6AE3tXhmBfLagF2MFBzJ7jNGajxHG2jq9TPovlyNhF0Cv43w12DfYO6tqIYTPMG1IS0TYS1OOJcRR9mWkUqrLiSOuQbmOlFnLs1hIjhzTF)6BQcVZnueAxyxfQOSkIz52RqLIQoNwtCfTso3AKXIqIJNydcRyQfAO(r(IuuUktSqLQRwyDgocNlo3L7fbI7FOuoHmGz5klQ6nbg40Jl2L6c2uTEwxY8VHLU6JxWDkDOIA836v3WVBkeulC86T70Tj5ZdZiUadUReciIhY1zq5KmzOvtJok35dUKq5NzDyvBQp(O8KoSifOjxmYuFb4DtKclTml14kg2tC6Om3exacC9LtikHFBETOMbfxU8p0iOfnaoHDiMxXFzLRwGb7I)bAc3rvPGLR9igtLnNM(OD9jiO5QQwWnzqLpLYKrCAD5iJ)mX0YXXcStmK)Go09FWNQ9jnb8KcG67cZ5mJw1LJvDpIXwPBB4HVQ6s)gZG)A0KTLg64bv)PKdpyrY31UEGmJ37M6tIAnYoFCqTliWm1DLgKRz)xNHWuKQ4ZIMNSYLmgAK(4SYof))Z3jyBNtKWYLA8L2sDI7ze4qiC2xooMQkKscefTm1CL2dzRNrSRVUdtnECPk65aBIJyUL9wuNjC03EulD43)MEK9zvYosyRaU2JOH2Jp2(iGyXITaEpIcSHWehwb3yF7GFjkRp6om7KDLOMP1PaX04Spq2TlZVJMdWQRaTM)PBG6GAnjiSD0uaPXrerIfnGTbMt4)d1v7K8AZzReOPk0z8LOE5BDCmXzUixSOyHax1k)i99rdDkck6V5yCXiLUE4C0EP4sA269cmDu9O12HYCAiXyw2eWxku5hd1VpkqG23aectrQC3kpDYMpXgBJQA42FFuYzxwsuS2aRDm5mlZN6w)RUTTImwilIlzTtC82(5YCH2yQBJ)tG2eALTU2VBcLn)23n(0AMWITlG)lx)bmYOmqr7PykJhOSQr8qXL4uudXrZtUMd(ddZOpm2ZA0s)oSo7qJ2ashkqwFQ(oE4RVlg)KU8uxdengFx7uDCySpzC45PbCA5y34xCgxutFY4bc(nITVyTcGTAsx8e2DIbaFESDAQxm1tOVcGndwl(dozJwkP((7PWLONzvNwL4BW8W0TqpB37CAb5eFGVQ8JO7kox5(ntLQKJWM0idQ4hy5m8WBrBwpGm(csXhEAX0g21ZnuzyYwb7AdVI)wDmsG4C2ObpMapRFO5SKySCCTH6nvr7RqdM1uoQbKUpw)rdN87RaK4(g9wF5K1MyG6xHvdsQj(rD1OLjmdcQ20umWwMbmq5au90A(d3mNrCVjQ3duL7u5LSVlY4t7xwSrFXOZgpYmE13veJwXpiYnOScolr2IBJs5HaFI)OZ0yuuxG7BlkZb(5t67zY3UJ1A)aAwAAYzCYO(j3qNGLpzOcwTcsS0OdX1KT79T9W5(3Fg1fK6P5)RNd3tZhEeVM5G4J2sYcU)e1U3ecJfl9yw62BDTpA9ROULv3YTNBzm8i022myGxjY(aXAkJHAU11TSXqyAHIEnyLocqYsM2n(h6(Wgv())vd)gv3zRRjtUd9Gnd8s9TXmrLBsKFwjSQ6LQaWLU2fCw19Hx1AhIJaLD8MUCa9foz88zOVWjpHYzF9Z9foT(XcfH7ZTaUp3c4SZx85waNfc0NBbCDPfWzKsEeAdBw9rt)iJWAxsOz(D)ArB6klDdMg66AyG05Uw1(yu)JAdRIGi9VsnSkJnEkeLEpFDMkh2C(TENPYyhMY0MZtElOsEZPBTGk3lCgXoPD7d(nw7KYEUjqWy8qzgtQBRl9MQMDE0mvyi8sPjNH0tpE9pbP42LaH2SkUCxKMUY2POYNpHOQLEzB5g085J0hnzueUmuZOoE0z6jn38PHFQcBO9tqJ)Qy84dApskA9Qnh4eZViImUrB2w(CBnaC58OFqT4HBulwcfkgn2EJyPsWPxkFIoklfOP1n4k8NYRnIMjb)OcTNFhnEvTCvs1)favvyj6tp7NO5u6OOMJiLLwKgyfIHlsbv)HIKWjEdNyRMukj7yptUoeWpHlWAWaJDXmJ(OkI6yJtQqkBfbu0RIwEKOsLM4F0QAF57Co6UJ04Bwh4LDR1RF(0j0NvPwezAlLWRFiph8L5MW)zuzeBymTMphu66nO2tsjSG9oyBpDVryy(UJq)(hyd0GwBHr1cmXc67NqfjATWLzAW(ClBCHY2hL13cYtCtGmjf)u2HfAxD7XLAYb34im2qypGKeyREQyDxKE7JdpvTUK9Z8aoDQErAgHpx6BBS5Ttuaa49a8g0Vir5uQZEtPq5oGwNYZkxG6z3rEfIAaI613YbgI3GsACPnPyAlZjj8duiwAjvx(BYTue8au7q9vkBO2fdLk2Of(IMsDVqFs6)iKmC6zOXc1YWNEB2SWxceUIJg2J5dXGkUsJmB7vPUW)wasZLoT90Gn7vRQnq5OAj8RKQfmiCVhmEHOvNuwJnCl)7OkRiuTjD26LLbYt9qKkQupKIkfv2ScCMtaIMwf2VIQosWLZ9aKMcN8DNB30NFtIcoXiRqdCWJGXuH0BdjWl9uIWuSTEA0VzQKdpXEMIq9K4O0ZAOTez2nIdQN14IHqhN(Uon)wTLSG7YDF81wj9RdfW(ahAMo4BLyp)3EFcHXD19xJ4prdVzz9DwCQqTvP5YHOJx1)mcmuysBwJ1h6YqHBlN8L9O6g2JdtXZSr2)p8t(yFWvxsaJ2LDFQh(j9tNOadjxa3URQBkA58KCP152Gbzmq6U8ATFS8XADRfrdoEAVikoUO1(CoahVE4eD6vjCZtqEQ0QI8rs4zUX7E0e2qtygTovZ5ZbpPcYm2S7ISfpqXxCAbBHxQVv7sskWn2xzWNnTmlQnzi3cC1mlsFgpK(LACxFaoU6s6)vXuLm9tuE0UrBCAcvt6k15)GqNjw2D8so2X2DcLCvDFQXAWDMoybvMb8PvAu0kA3tTO7H(fX4LjiGFS7ZiT8vsmbLMxHPuHPzyLBGthrWKDGX0BvG1UegfieC1e1CO5EfYvxYQwg4TU69(J8Nm68rF5vxEFixej)Ql)z2xnciW30mia4LSpofVCzBfK8s2hBI)XwwOy7GaNxX(ctSTiDf7oeVBgqsbLUSpKe)umRfHp5Ry9l81W8XF8lTutzaWlsfgwb94679ldSoni1PL2uGpMNuW3faxjmycUTdPRyDhaUdGvSS2qaPYJDexDaOmN9ydXDG6gZh94CAAqQGte(79M5BFbFxamf)b6q6kw3bG7aynYNO9yhXvhakfZ3BEE08rpn7dD(jf4wb7rwUKEASI92vUECbEdy)ctKg5AagNSOngjSMc873g6tkWDaS2jj4JXjSE)2iFsbUvWUVMeCeR3xWBfW7RFuoI37l4BaSN3rMIOG4hD47cKDW2gLbZddQuwmna1JIKUz47GDhhnjBEEiUkg4tg9GDBg3p9mpTqVfU(2HBNKxvX7Jn8DbYoeUcPu1bbvsPkAOAxQYbxkmdFhKQC0BoZZJRsvwgSBZ4(5qZtl0b4YZBZY0KK075F9pz54kF3S7JyFxrb2JfLFYpl)OGYZAu9xc0R3wupoEvpSKLMuXrVybBWW2s41H5rF1UFK)HGdygzh1jA(IEzNstKkXiDt1xa18sS4LD8y3D4wV0P(g3WO1SztVB4PvXC1J8t8(ixZcQbw26NC1mHUTt86pVt80TtmKqQBtw080vxhw0rHptURaZqw6hIZzFeoIcH5jE7QGnGDGvH3r51I13rsrOr96wbfI6DRVJ00p(5XPqJtd1n7hFYmmA3NsIl(p(mspy3Nq0Ugd(0rnu3NmazxfmpDr0VqSGeFUeyp)5XBgJtJZSd2gT7tPRSdwgS7tOBSdghQ7tMb2b9NxbwunSGDVWTjDu)QnFBQmoWpvVaUbW8AJcN037333F4BojSGvjWbGJ(frdoP5Yelum21MrqpN4bNm(up)bdoT8GkvohuEvgFYBkFybZW68WwR0B3CI3Og6MrC91FAGRwzk46aUnTSiHcMdH3qO4tBmoXZvMlcK(md(KqmshNQ9jyHNuGBfS(oq9XhJtyTVZuFtJ0XPYkbYE6voUaNsZvy2Npb)Ji47cG7WUx3X6oaChaRd5zQRhIQta9ZNGFxaFxaChuC3DSUda3bW6Wrh0vMpNa6NpbFxbUvWEKLlpUhY(tkWBa7NpbFNjjhPZ1ZHJ9TdBKpPa3ky3xtcoI17l4Tc491pkhX79f8na27zn3uKZ2(UoEQHFNGCh433d8Udq3f46GZNKNh7bbvYZJLgQoZj6EAXmW3BNtXbfnhD43ji3bJr7bE3bO7cCDWt0oZj6euj5eDiVpDAV7Pg(UazhOhKu5dcQ7bvM5dSAF2h3Qd2W6WSC4(yzg(Uw9fDQMMoU5f7Pf6TW1Hu20jlZQ49Xg(UazhS2rktDqqLuMYCEHSktroSomlhEOCMHVRYuDQIMoU505Pf6d)eRIM4n6Hx2PCN79wzkI2r)903MrQP0h4m9AhMPHKh9qhPAu6MX5bDHr6JgGpuZjpvySpLhL)keWhin(jaJ39J)axcGboppzDtm(8RUK)VU6NV6sHBwl8NV3J9Bvhp(vFZvxoplg0JhhE1L9bTTGSs9SPwWz7MDXuyTmA3SE8b(catrU901h9(Uzp(iO(J4Z21SbCWWFO6h(T6jqVplbOWUzNpQe0iJOft3n7TLJQflfNMgCSenKR0p(R7ZFMmeW)yXjVGzDkFomLAWF7M9UDZgpsAzRDzU1ORkTlH2jQNW2e21RNTaQuNUB2jWmxIB4Fm64ivjE1o1XYv4OYtj2WlXFYAHSIaXw7eTkIsYWGAiP09)lFFwtvHVa9Mad9Qll58V6sPI84QIREVVjgDZKVYPNJPA9sbjIVUmYXq2GVmRQNt1oEPmiW6ng)lUSv)dx8YUSsZurjUiSfsWbmWr5L(UiY0JKBTrKdT8I50UgnfYeqJ9ijjIWHjNoMuo10(9eYLw9QMq8QftkBxAmu4CfuifgvEur7qRxHS)vcR9wy4lJw5SB7ZWOYOKJJt9HifqKYqOkrtLHruxLkJslUvLNJMxyorkG1oqaAN8x6hgjEIcjUHDqJ(P7sIOzPM2ALSMHsjEXVKyYmHtu5UjehkhkbNLI5jbx0qpRzTXHKDeoZSxLwxdotwkjnQvRjEAmAuSQKic74gs2qXXnD)rjXnpDCBaM8m719hzvhV3iIhyAdTCcPBpx8jvhKtU6Yswze(tGB(neCZec7IS0VquqZMYdN24O3GTTPPSUDMXXgJQcChGsLzoc0qMPiCaT(liO1YQmv0A4cvgdFWicQ6MpqclsUW3hIkLqPZAw0g4aA)iQ3MuO5WUZBP2DqSzjUhvQz(D4buI6oLysHQdHu0bjlEQJ6LTbTn(nuKgJi(JAOdyRoGA8LeudkZZsE7OzdRE2iFByg9grmLeM6DBgPEz2eQMaHwDFCEmVoLsbr3pXdwWZOJEdSeqJzjKZk9oLbFlH7mWU1nB8tteJY2MYaTXqOjwBCKUB2iJr99y0nFq4IfGaqsAHWwoJVqnEBf(c)pn5lqviEq8fQEKTx8fugE0gJd8fMo)MUZxqyXdJVWNZxqhFNbVYkXQQTD1VHN8jSYYg(3YZ2DL6q9fESsi4sVVW33ZAK4yfUWXmkgXFXQXZ61OEBCx3WQuhf19KuyA1BK)Fkl1nc6kQ6t4Cgh1OYDLXXLC71Puwi)9m9kg2D5YCSKPVikhWYnLV23hLC2LL5KRfwZdtsck)Jawk6ltuFvCZIPQ3ygmB8EYRKbOi9MBsAVv7nltDnS18unpbl5j))S31sZTrUr4Fl6YuKwL8knsY7UvjPujvUKl7H4KRMIlfTnlltQAOyC8f(Bp4XmaDd0pagjBZnRUzRbCaqJg9JV(XSxhOxndRWii5lQopYn7V94W7xQC1HJd1TvbxGlNU67CPY4n1pz47jkxJ6TZu(6xQ6llBF7WzurKIgrTLNGH7V1pdeRwK3dc3Pbe2HwMafoz)aiD344G(bs5WKgxl6NcFReRSZDOA4L0TBTeFR9hsH4qgPNsPcNqaeYlEjiG(dV7A6PVUpOr5pOvJOAjHOFwY6Gxz6G)QYIWVkl6wtj1ZkZyGMhMwfF8TYiVlBpd4KAkCH0uW6aTyzwc2WZEwwOzKN789N(HJKCdS1jTav7P9ML39wWxqbRMucOEYyYlNqYZvo4trjhQumAvtVQIzUL2Ydh7afElPOEnstmdRrUwOtp7v6wsWZl1T9pt7HfaAhrWGJuPHZAkeyI0hjXGjxEVa5BbFeKa7msSyuSyf(QCAzMT1y(9NwscZs2DbgBIIsDwT12xdwE3Sh6w(vQb4yQCk5ev5ETZzB5lxakyCpL0zfirjiUTGPjM7(Jny0hdmvp8T2ZEenXQjYO66NOIFzHCZ(1zEtHYnTU3Etv2MCDavcfOmv8MstS0u8PbJei9dm3w8ymR)ymRItPfsIlJjLcWdug7g8cRzXBzs8p)Np1zENnZaQBFnP2TMKLe7c5mWj9sF930nE6UXWVBF8R8ONCcjR(ubre8MJZG6v(NPUsytsypoRCh4(2rmTJIW1GKVGFCEq0klJsXw(SuC1nncOO8hrsmZTvE3qeinYW1uQPQPw3tMZrOTgCeqdZgcZ3ebDDhLByYY)RnLktjp5MODgVzSj39UsKXqLYP6BxVZa5Fmc92N(6tpdbck9Phf27qe7IFWiDBEEduzbHSXM82hOeg5DpebGZ4n9C03n8AZCM7cS3DE3I5RnKQnDDlDyLACMk0zgPGLupFMWbrsU)gcZ0NHianZMXqBwDhzMxwX03oQPVfn9PwuuX0ZgQnhMOOrjNXv4XkM2v4HsMBvKVZqhLlb25)29Zx8jFnQ4QoI(F229Uel)JMRfH)w8AY2(b)pIFWnVDUTEw(TLlm8MZTSHV1z5HnhZxV8eREcdhT13J93U9rlDQd(IdFwJNhO5PSm27huOkwX5fBiWq0R2koVKA)GudTKZR20Zlcg4bIrQThwIr3swYXW7P7dZmm)VTV7b(U3EAaZqg9uG5ya4fotIqd1Uo6Mb0Soo5nqD0OVuPyarkcJURaUEgPiFWI3)CJmYzg3ShLqje0pTO39I7Mz8BB1A54j0Bs4AWhBqGqCqo1kJTU71WLi3u6N8AujGvHcUfqMFpLgsffZHjxzkGEJu3jdVn5CeFtGCHwgbrAAvlawm4KqJKfPTejMUCShNqrpmuSrIKIkBiI3aSzpU8ZpyeXjdeMcfTCqT6912zDYaTIH96xpLN7l9cVukxCbRlDzrMzq(KmyAKUT1hzkcUcg3IQevlT3nHpfkszs5D7TDmzMzw98IE8NWqKjcI(8GRCP7nho9ZwlqH09buk(QasO9pkWq9lNMm2iGi34dYXuwracUVRUDo9ay7KFvwWRB1D0HWbuQefEH0J62sM7qsoHg2bxCkRk0Rjas64C5slmoY(OOs1FbRufLDl8YN1otVWZL2(J9qn1(Lwn9evSHKrWPrBaGAfaPHIvtVgz8vK0Ktu(jN7RZn)1pbCCBpdA9n4tVlLL3U8bqSmEjm9I12A1WsLiBviJK0Ycb9mUczSpSg3sc8rbrFTjbRqHQWulylx5cuYBkBW3SFit6rJMm10hBkwLVYAcOptuYJH3cDyyH4cpe1l3jZqItYuJKjXGsVqyFwtlrGxBfKwbQz8f7AJXWWsozoRwQFiPr0yUt)vNtBwNMvD3CT3GNg9dB(fvu6zHKsIKZn7NmTosNGBLvLvw1jLufnA4RBiyYY7jaxpeZajwU0NY7YDQ(AfpUz48foL1yBB08L(QRbYFk5kw(GzzvU81xIOVbTuPh6rDn03Q4TDDKKTjLQqJXPx)2AIkrilvMk7iJDwzYdsElV7d2IlgBTCV7Z4VpHrPGavffepiUuPWpksYyVbRrujsQm(BPcOVKwbDUn5JFSB19oOdSoB4tBQ7M)50iGMK7enKa2f)b1OMkvIePHCP5IxIgcbj6cq5em2NWrIcVtWkmbHhiRzlnQz(tMQqUWVsUiBsSPsP7GiWB7HsRY0Sl7SOf74s0vbKJlJVeGiTQ9DKGup6QfrLl5MmMFKtZV5uaNX3oOeo7unqI4T1HwgEzYzjGIunv03UzNRz0qMZH76w5QbnBEdSvmD60vheoaXQw8Np5P60vAh1iSAsYRbEf)6QeqmlbXa86hsmwmeJmj750s8cXkyJueKkJGmewu44DeRFv0wBjaQubsoQA30QGOcD6BKZHPytXFr(W)7GKeQBgYHRQfjNhX4Hf03YlO)GnbFeoCPeirB1B7fLcH3qe6hGWl8BwTTB3dpMsqtON6bTUxml1Nppq2f(tU)rRf8iZFd(50ZrwE1GBjW3g6dRhNnJ9M08QH687SENfC)h)vFQp3EUFXBIdI4ZUNBiwZrW1yPtYApM22L1d2SVy7YfBwFhmI9dO2sbhKorDsUFJuWyKd9j2KX1d5sZSTZnBbJ0r07XSgM97BwVBRXk(LFzE3xw94hxT2McuBneR2zx8Wc3nveb4FTYUHp)ClwQ(TUnRE(4slnfM(p(02z3dg2y77DloZEgwoOutX8(o)CZSUA5csaL0PBhP2eRAWTQf83JVGRT4mFIAq4rqpx(ddWidIqGsogAertstGhXPL9d9x20Y2xfsoy)7B2ziL7V12pcmtm4G0McxUMvS78D3wFJl2LfwGm6c8dCjY181G3L3LWWqGh735M3zgooZiPWqdTkF7YhM35Y4kptW9(uK1TYSnCaFToyNOLlJmkz18OnyilSMuavzWwLeOAKCENmAwhjuUfOjMDXHkiZqGygOZYbJzsgap8TvvaS7l(6I7D8Agh8mA8lTe3CLOfSk1kkciV0JwJwE)NKE0QEW4(M2zvNWVpr0GwHNDE(ZyShH2sfsawQoQwJ5Af4EUaao)P(Y3eL7FUh2TCTvpyFK0broSGBN6x1clej48K5cM(8CD7j1GuNWETOar)XLiagWxABQpNTn10zImlXFPFQ(s)u9Xx6NQV0pvdNbeuzRo5x6NQ))A)ufJ(aNn3zT5lEi6ueoe71PjZmrG2bGQ)DQNVYBPpO3ZuXEKRFUY2DvlPHUgS6dHKMBTeEecTfoHNX1PyNGLRXSwqNG9BWsvQfYY1QqHw)8KxCkr1UFvgNrQavhWeIUJ3JUekSmNKWjthhJ6sVmk3D49dHXilgtspuSZQSLxXcR)JNPwkgtrZwsLnerdQCBWxAsZmAe4BsZeE35hw8EFpT1vlV0VKs60ZpBDQ3Q7GZC(u2pOx6GZ1W0q)faLJPPLMPP42a9Zgtt1T3z(iVOgc)mEINTCC4xHijcHdKQnqBFpCTrAGn8DV0IOvQfdu9TXNVuQ8fLCG1Z7uBRbpES4tvStctLX72fFYIo7mxUbTTUYrasWnYrZZZiqRJEE3q3ionjq6HwvohqsYljo2s3d7ttW3F)UoBczHEgb850hLfu(mKf9vGGWMHXX0WUc)ajBr59dO66FQjjR)VYwvbGGbxs5fP05gsOZWisjKT24JJ0K9JpxpLVK3)OX0MMPK80OLNwPs4Dn(63btHQqQ(jgb)d4T0nP7OqsHP2nBH8RzR4AQbiEgfX2fl8wfzcnrwxw83JLVQr0)Dp0e0hPJz56UAXLuBD)OfHsPZB8tlnI31EkrFpvQIuuSUGHiXIocZEqnee1j4rVt7EiSHMqLp4iWRPemTNRmTe6yjJCtxadhFvMvqHi8(YAAS0wJ3Vse67UXBKkfvZrLmq55Y(AK(Y9wKNafyUKSxcm2TRv2WxHBkh0gLnIJuEtAOeVxZ0GTqwXPvbt2K18N1DEvQuuSP5fnfP9rfEL79mhQTi8FFx3A7g9lznbCIlryQkvJZvrj5iuhDdvLhMzFeNZJJl5FAkcxESSaoK3J0R8SOJxr63wtJ2rVnPY1nnr3u9b3bpDvROgkOqaRzgfHIh(YmtaXM8zhPGrxm9hVwEDPk2AHni(ioTcnLR1H5EMDN)uoPfmm2xZpdpMViqXLiJureDj(fYuln)wBQqC90p7XUDOsCWNoEdOY8Ur1jlF)873UmjR4)3U81FJLv2Cu9zJoY93U697V9l2)CN7QO98A5kJMxJ9aBmpY8Vm)dhSq2s1y7JBFn5kDeLeeLkn81jsDrK8U9pdHzY1bPnbmM7(GrPZc3qPf0MqW(R9MiT)2)zFI5)FGT2uZ7Icik9TE)DgYmBTjZOAYojfu9Zpp8RY0t)8GCD(0vkg3AcQfCqayYyAFXkevdITCrDkDujyH7jJJh1msU1jyUV72clgy2DEZE6CCn1yoL(iZ3JflpgpkgZwjgWXhwsVK4QSEjXXcBVPdpoWUo46b7B0xnlH6jS8yog6yh66nNcgn9ANq(2DBP(Y4KkRK5x1wGPVH72AhgaK7KQQIJiKp7NJmWsgigQqs4E88UqMt1heI(A68MqvTqywck6IQwOasNd6SRyQK)Ev5k2Z)nKl(HDsgPTf2JpYPDCjKO4hCty9XjcE6b9hY0PLVBJFErR9JagNVRpZo99eXdp37obytdmNav(UTyEpjhW5ju2LjDCEz8lPVdeveyFfwyrsTems8jnxeXRrAS4nzTdIcb2v0ByfrNyK8OaLHhR0rrPO6R8e)zKaMlLhsijfkampQDO6NL2d8VnQAgVFdmFYNWK0zdFbuCdImdJIJazvc9B4rCg0zRT8xpF9xND3dKpFylmSefZNOCZ0CsQvsbP(QdKAT3YS2BFARDQeO7jT2t84OO0GFWwJrKAoncIwQSfQkappT0(E7u63v0TJKgzjUaHJPoMYkmo61kZoF0kCgB(jW63mXPk0XXAZlb19lkAlp7TXsfrEdna1cGQiop3VzZNmxpNVE2NmwmtAgus(KY00oRR3yvHvj2Fyjr(OE6j8NfpKvXt(IYuSDP8z2)R9UcwUPbIH(T0lESBhGPXuMEOox4tG7TtBzcWm02zAApah4BNy74DxPvpjToPab4wNuhN1YsALEpTsdxJG(jbojhBYnHSD4s5UAaFLt0EzQWBYUt7fOTXLZbvDr9xlGgBgKHg9HlCi3EU5vVKqxcEW90yXeFGest1tluUcg8Q(crTGcmT60NK1v)pOTd8G2kaafcXG4et0C92jHIjcmQ4VmR6awukM1y0VZyAt1VtlbecTC5eAcJUhnmDgZh8PaooceHmSJtIdv4LZZzQcuENDDbo4cq)7a)QSfV5PCevrhQkDUvsgmRVDZQ4UEvRBE85nF2xEI3wIF57wRT4Dk1d6HTr)4AlmECuKR(XJkL4mZawCyfLQ92Q0ao9VPT3OvQSkyjHDABn49Botj39e4DtDRaTxykmDI9Q16SIgAnyY7qB2jR8cvYzJI5Sr6QhAcg9N(060T1iZ15yUSY9qLE16FnZBQX)zcLx0ILlX0PSPrL5aLFy1e7UTxfSD)4dpCNx5zDCRpRFV60RUyoP4bN(kM016RXZXwb(H6YtApbmscYvJK(NUXQbj(D0gY324VRDuUL2wPDrEKlBj0i7JVxpzWo1svetbbKDH5H22YC(fMqrL3vr3stFmmmJRQnbeBFa5vNBILw9km0ltUQ0PgY4f1qekAhBMALsPm8uQVIAOjUBHt3mWMx42duQ9yz3VbY5(U0mcOuCe03XTFTW5hw3p3wR1HhEXRmdbF0K9E505zwuTdHSPtJ7WhiF9ScaWdjj4qBH11RP)mndJy1Krqlo(Xw6clzFtIiXuXSHj6qXa0rgXeYMdCRfcviP2Q38T1RV(Rx9PR)Ey3fdFLk)QvU2LBjdnBY6S)7cdqz3h)CvwjbFHiZpKxKIrVyg3lDlPZkX7RQd2jJF9ZI1wz89KJaBJwWr8QwgZPJ)6NSwPI8nFiRSfxE8PjwtJ66eUSkZlZsSeAVZwOEa1wRDh7XRiqZf6Wdc7zXn)mDuB5RLmWcn9T6zN8E)sIY)ubL9d5BfOM1wTcE7gEgtGnxZr3KiogcIsv6ESW5zna8LrAYhOAOsORX9EkE8rd38vzhvy3QQVJlSdGsys299WoxaI0Us9bU3DXPu2MAZvq9k2YHftgKZnKDrNr0szbZjqOe1huM(pc(ouik1opGAg69lNgkHomFKzRWJAXshL)q6AyqmOMuCYRdoYh9)lXg43KEiXeCqr0b1fiRitCQ0e(D)i0Zu1mfzqJK923m1qEGtum3yPDLb0IsH)YUXfu2ujRMB7)Jb2RgkEax(V4jiyiLtV0SbL3Pasnvjv5p6bSP4VbXjhW4ASCM8gj0cgGOhxGkz4(JaIOAo3mpOWMUJusQTdcCC2Jw)ecdS3tC(eCCji2BeglmVyLIP0oe0IhMMkB6BKyZ)WZ8rLsMSwk0GyGjIZ(tyDAuVnJH3KH4Ev5fVXyzyk(2MY0Qsneo8dEOrOOI2AzmTQuIH)99WNMtZIfU4OFKuuw7BulvOIgyKXfqCi74O5seoeTBJwXtHLK0mFKTLCWOflRbuyW(FQtBerooupoX6DRuHRl0rke)8tpyfmvc()veisCyp8qoZ4Fs(fcoCGzkq0XjaNKvZbGulyxBusnIlXA1KJft(Uz)T6ZYi0rFK83E)x1eEu7SasEkIbtKto(Pz8aiePyz82z2hTk1YcsAG(EIMcrlOne8YDrxw3gqojhzNoyO(QHVtdkmK9KJwjoQPX80(vBwwzlKPTDun7IRimIEoZ0XuHuh7rCueUPFsGx4JSiGcNFgoOd3lij(WQDiitC3Wy)traAgSYoCKGe8Bsvwl7ijZ7IIUapXI8AmzNR81JfXBoSd7PzAvexM0c(thIaWlef8k4It5DHSHEWVlG8GBeWkfOuof51MLhFy5Nw680MEcbQU5279ffpkiuDonNjuRFRW0YntclplvhDcmCRFR)R98tF(HhV8dBSLF)WNC5p)]] )