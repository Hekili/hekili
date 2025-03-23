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
        duration = 20.0,
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
-- APL uses this syntax because ...
spec:RegisterGear( "thewarwithin_season_2", 229316, 229314, 229319, 229317, 229315 )

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
                if talent.thrill_of_the_fight.enabled and buff.rending_strike.down then
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
                applyDebuff( "target", "reavers_mark" )
                removeBuff( "rending_strike" )
                if talent.thrill_of_the_fight.enabled and buff.glaive_flurry.down then
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

spec:RegisterPack( "Havoc", 20250314, [[Hekili:S3ZAZnoYn(BzQurJK9ynsuwZo7wJCQKCvUKTYT1vX5Q7dxftrlrzXZsKk8XmR3YL(TFO5Z(bq3nPO8Sto)LKzv3eanA04rd0W3n9U)(D3U2l1)UFYzIZ8jZMoF8uN5F)KRV720No4F3Th8w9O3dW)i0Bp8)(N9(C0k2V(0UiV1SVojklEfmYTb7Z25Lgef(hJ92KE3T3NfSl9VeE39yy4Jx7aF6b)v39tZ)UV7UB3gSETFXC9taeWM7vtMD10R)HJlV9PWvhx(LG0TW)oy)F84pE8hRMWKPANGZvoFaMWW9bHrXJuNjSuIJ2eSdwa)MFZXLBttpK8dV)9pati7(XRI2)(K611k26I9FV693Vl6(3NU1)lEXmyfe((F)k2u(pJdIIdsF6VgKKM8(1(7Jc3MfM6h7ULX4gZ(4J)idt)xhoUmn64sgRHNGaI9)WlEf8F99hxYwdhxEf8VNUbyAES1LxoIsgFi2hiV79sVCX7)SxCG3978FhBtArACq4J(PtDtaehfSo5DF2Bxw9VpE64GKXb7Hf(Nds8x7M47TbO6S9UWMT)EVh9JBbACOqJJnOb4e)HDGi2oGHDCjmoWvk((Kc(Z2ODRR)TJlxfb)3rFjmPCY)LWG0ay35Zat0leM5p5VYpjXl(jGDcF1JWVVli0)QmGFhLLMeSg(LKuyUEX8agi0D(79dtZ3QBX6FQ7kyhhJfV3BT7)mZ3pmXDpdFP(p)SWe(FZcFCVNFsACemf)h8G59qOFQ00EW3l(b4hw7hN4MCWl239r)NsKMvS3N9dJYsC3gf6)K79z)YV4hldP4G9URIw7)ZTyb6GTaDmTaDSBb6y1c0XIfOt7xGXp4csTR934LTlDXK3fDyrSFcinG(TjbpeSZnAJ7MDWhJpNG97Jkuw46LfZFEfgCDqsC2H0IZ))p)z)hd2f8poUCzSFkS(9tHpjnY1lnfopSeKibz8WiErt)1JzFm81GwlFpq89pKfhge(WXL)3rzHRRouaijaOWLbHhxckVsdkGpi3VYpe4arjf0qdPHrcVJDUXD16ftFx5GbBwa6r)H1(3NTzZ47lWT7xyOECmCIoim5DWCs92beR44dk)XCvIU3VZduZpGH)p77UosAYFAiyzy3o3c0MCZVB2OtIGFtX)jiG4EFus)qJlqPXJl)tzmvpp4h6hdNhGTOdGAULjGicODItyqusCd8vUWhXebbbWQdBQ0ZfdN(Bh6m(dxuSKbZkG23rxmCi)CtYaAAq(M0EGpTpk(W2Oe44r2Hrxm7YPoJgDz(OsIRJtyW8IpumykJyx5TZf41G0wk81xmDs(I8VhWwuZMb6pdkwEmvZB9x9OOo8cDVzhskSWLiQE2d0RSjyLpnBHb9zZCV(qa8zLmLHfuETEFGSE(53uU8B(5rdkMyyfcDtQWxXxa0mineMLmM3ooZkvcWoCaKUQyh9FlkdiiW6bCAklXNBXXSnLF6R4uxs()2l38cNPkUpi3cLxihSw7bAe5GjjRyDov4cKg8DLSI34)pZcoCaula6Ma1QmLtWIX9aZlKNg0m8wqTPpB0vGrpqV6qbRcYJkmigKhnOzkvRYkfa34mHd(o6GVJz47Gb)8DLB9b7e5(ovWXyoquP)Z3J5)0wWRegJ1xqalodK1Z)VCzFsbZ1lMPtG9bUS5p2B36yagbGOpy0jUuJ9TpbYp)JC)X(tE72DVxT4(b)OdmrKD(Fg0jWedmHXnjIyCJ)UeG9e7V(5NZHYN(UPmRh5R1FFj5CC5FRKEQS94fVqXKwq4kr1i5NdI9dzYQGZAmNIgZyPfAiEyNhtb3MDzXXpbhnguZXZ144U2lm)iZGhwvRLFbShxH3XfOCayr6ZUS5mfuc5LU1n5l((hum2Dia0ALDWDtS3dmBA6m0vRWhwNaJu(tFxHy1ggwbD(a)KPg9tl((j8mivDT(7CVhy1W5ou1TCJpyynZG7xR4cFITA379Zx8DdgwAMau7VpWp5MfGQ6ayZSY8WLXEbRDH9va(ERxNaI1qybp)S8phe2auSrV57NmIJOe1Uxswp)SeX4m65NZ3Q5xdGPGbVrISxmDWBKXP)pZoynsIJUARh4rxHSeJXJjIbIm4cyd5fDwNSWbHIhW8G5MPY7KEHHbBdkmzDwWRS86FdSNYITOusCCHcHe3cGpEhy(LPqE9YA7FPBzk)zNgYfKRTluC09TGS()E(3cc3Bszgpb9EGbHdmpgglTCfXw9cwCL1CuM8mE624GD7QuYUj4HTPUfwEuKLV(sf20OlBK4yFplIwLVBgZZIM55)KV79(E7vNxLxwjaFcw)Wze4SsAq4taau2IK0ZSMjIsOFszMo4ZSKGQ8pqdRj3nbC1AWas6)gnquw6tZgu6Nm4(HpGy37HDZhl2ugI4BwT9TNFMMlofyif0yZViF28fuO56ZmtKXmKxUYAIalXyg0DRD)sI7GB)3T4aiJBHieZweekDfgsCRMPILPg7ttNpyiIU8Rv26QdXm5qqA(whTmu5iv7279IFSwgAHZvLNYapax9iSYw7Md7el5g82ibQOEBI32O8kk7GeWLIUGbi5T3kLbmaUbmyoy4BuTcZXGrScFde(9wMvwxgVEulp1XgO06i(XX5Y7rDzvPYQu(PAb85udDZC61MQhQ)n)Vef)OWnNbNZZxhfxSwXWfx8yUr(CRumMqQxE8oGcHSvPzX(YEt5hclRS64cvDdtjySb0ggUbwWCEw(PjJN98ZI)aNICffIl4M6a9(fbEtak9Bu5KkFnPdugR5Un5SUO(DvrRKoDmepUll8VXEHp5U(GYyvK4GHCdihJtJXYMGLqM2nZMmsLUCqOlNUqxQXE1c6Q0boNjnNOda9RG8qHXLSW7z3IIBUJK8NclNfevuWdpaEe1yps9GRILVURnR5keeU9hSqcqCLMqdfZaabPlr5WxLJrg5jZVu8rhHbw5ZRW1IOrvy7Pk0nhahseRMtQtgp3uOlvqBxu0JGmPxOl4g(of30NA7gpdj1eVSD7tFXYpTc(QopozElrRgConR7gKn86y9mOAeoT2ayzn3kt9sfolI1UsMGNlZ0g41glLkdqVpvavmCXzEUwdIdQhrQFGYEVuG1wqV6bqpg6oc5Bb5j5F7CTYqYEw8sA3Vsat0hzmbDKRUGPk8vBVwtxNMTxJbnXTPX2nP18SOjSDQGf70ndrf3tEQ1qo0clAn((sQhNDFGGb9nbRcsVzX1tUSX0FzcxUGzv6ne67LGCze0P(7p4dgzuPYtq1HACTs8r0LVcjcbIh9fUi)LnCw7qtwCalvQ5ZpPXhTKvaC3Z2QUpod(TG0Natm56ZYVVmen660ey6AdPf8QTtWWz8t38rz(d)2SIhsVb1gLTsqikPTszVjBvkxUHXtb50BuwE6rI9aJ3cH(JfIB7dF2zUmDB)1axKTr37dsLnwilis40)aczjz5bDlzAHOpwl7YYzqo55T7MPJNmT0VCvwR8bgvPo34SKT)QCjzG29IbhQbQkkguhN2jXR88RmDYe(6qI7Q2aKi4KDUNcd1SAwWswyPe7QNwTlplHB9aNtxRXD4ftNnQrsxGmjmtuhig)bGcwn69Y98Zk)o3gaYzm1lUCuZ8yYgPbRadlEHjBII3NRBr2iny4UkGcWqKB(rlPd1XGzNDWkZTOMY06P4nC(lGF9Rqm6YHAIYtltfZC73Y16b7WHu3gC9V7q87Ze)D0O6WcTvYfQr0YwTvSQw6vnBgFtiWnKqIJYzVgCijlslKbirukRMNjWmhzsm7qe7xZvBfLKmqATagXWUEx2oePgH6umkLI6GWph9iWz)zyDbAxDzFUTPPMNIXGtXvtCi6ladpiCtwsaxImvPDXv5cNjuChXuCZkS2aaJLbkiMM76QcbR89QhKDbbRy1NaZlrMC0(G0895MAo5rV41pbF8dGHi(pfRKo4gMUOaRNczbb2q7bSiTC3fT6Xqi2QDpYngrHc2aDKIeuKBYUrBWNM9fCtv(uHHn1IoQ(omfkoPC5S5J0M1V5OQZyKZObIvRJk1mGRCBQ1STg8CLT0YtziY4viMn8BAgNfpAoHaXQosQuD0H5PgWmsKQcyEQiMhjE((MPoij(ushan3vtsHKHkP6hrrcIth5xFRDNV0ZmX52AyMcRcZ7BAeieGK8vjarlyhdsu5q(5f9mgz0ixMycWRdCIPAGIjUaQySPdyCJJMfaXy3P5KIvpNO)vcjOgfhSs)r1CjTDePDren55xbmlYgKC7iMdNs0J6Lwz2HojQJYqIqoEekH0b1)Sq5uEsubHTQxyIO2KwhWRUllKgLOwzZfpjq)qbzJc)mBKKf0mx5nUg12O(Pps2yjkr(szV0aYnPl5RRjtedJsUjVoV0vXmd6M6LO9fmq5XSbqQ)kdNoxx2WMlVGS4OvYUO06N5tHpF0iOkBBY3cdLIz0ib1iBCfB9rgK4isbdL19CwC)cEAi7lTAYykEKtsFNK1uXbj2h5tcKuukAp25iwRug3UCEr3Uq0Jy)2LJ9BxowUD5iTDH5cL4GNY2f6JaGC7QQcsjtQrHLbP9Lti1k5Lmnw1YLxAIKf9)ObcFrzb)wqCDnqU2gXyX)FFucnKBhTPKdr5IvlC6AoupxUw2bnD3v3jKa5ZDpykx9r5lVkk2n7G49EuJOQuhjRlGZ8HyQyKNO9eZQ1UWYnq6DDvF1SoAGeAPUZFtDsbqi(18jRp)lvVisznFivPi65jPYwvgX8In0y3CarIGL7kfjbQMphjLEYRFhIhjHM0xiKPNlNPJTOM7yC(I8MIgqkLe)2Ys2iwuC5zzD6KjO25((j6EQk025Uw9wQ1trgRalKTinqunJQcveW1tAj8uOqXVCGe0TxEM9HxvBPTwTXvZMFZeKkoSsF0mUsqHxXxDsZ5gVQIhUz6hBNGkjTn5LM2KK4)1dttn1QNMCgVps5efaHE0JOpQvdUSHhk281tYlV3xs(SC9JyG04T4ltEd0nyEKYLkernlqVSVqznDf5uN5m6gTBfc1xHW8yMojmlQn3NKPddd6NwL(JxHVgUYhwzc)bYxutDO(tOUainVtNbwGzImWRZh1MINDY45152uk9OwLY5(Y7(YDpEJvyyaX6QjoeXJVtMtCHJHNIrZmNHr5k(qMFwCXSjdmviek75d1SYhl25aY)n9XJut3yunQd7D5WyLGHUb)eRUf1rQ1sl8bmqTbZpIwNYreTOKLKy82Rwa7HdysJG8Kq37MpEUA428BjL)7rQvv9FmA)9Wk54sNJlHf)XLSIaRO7wKqWGeRtmZmOHM0CQ4k9ZpRVmSBQD32czu9jiXqvxzOkXTyxXwQ9OJKOR57YJFHIEIWGsPAWGU8vukvLeSCI18JLTUGSUwtjkDJzvO8Nv5m)ROIswvNvRPCfTcUoPvWI4exEyZewXKR5m1ugIuAMsiMRELLl7knPa4MRnuy8iovHY04UAfdVWkzhjWaNAax2uyO6Q4VQAM(dSl(S)IAq6LMxr)gRDFN2PlqUYHR2PJYY7qkevWU96FaM4Pup7sjbJrw1nKKeRZ5fHEp9QVk3uF(zrKoonc4j3mr3Zy(tZfI3P46pX1j0rAQxWnrfWJRQCornCBYHf5qZT51FqtGg0ayf1Hyzf)JLQTCnMe)D0mUEvPGHN8gMqLj)L(Qv)8e8Czvl4MmOcuVOVsCzv9RIpw199GpAxcdppXjOEAWCLsRnyXil7qeXsVN)P4RQ20kF04DLYzQAeSrZBQU8)uW9K(4DvlkR8PfoKKwT4(xhs7gcktExPM4Q3)vfi4LOeqSUoJco6vCiDOK3HibSJlJBvy8Onrfjn)OYteMmKJPZ01vyFu4NYQ08YXYRhcPcUqjlDnHLoCc5fK6gQ6PsTRoYhGieH7aF1WElQvClDQwXetZHkfesMKEYw2vZPrLHOH2ZpJ12djQoccdvyvlH5TJ8NVwvYyWS21wMASsR2ctHsxGSDpJAlvQJLPyLUJNDG6K6heiID0CaH5rekGbnGnret4fd1lRJ81mzk9fuPLaFjQw7n4neuCRuACZ1GUdkJVY1mI6wLMNHpflwF8JyClA7J261Gn3E1G3GXShqRqdv(tZ9nzytaFPqD3tOoOrbcHyry9KA)DxDBX6Zy)y1Y7WytYc7AhRnTFHzCx22gwJXfV19TjbP19TrtJ09806(kn100pTlAo2FA2LvciPzRH))8JVWm9Jb9CxIPlSPjaIwmvslse3hSjua5OiuCZQotyy0nD2jVQwf6NWEW71NJPlWp11NSJDN(67MzN1LN8AGsqKjErAPscgDjO(xMUONH8qLN8DBuWEXSrCo1HTVySGlnAVLpLZwjaGJhtPx8Mft5Eg2yyWyxzoNTPPmylFqussjQ33OvRs8n48mNyGFYLAhCpzSADAL4HJ8XkE)pSUuPRrL8bkU9UjAmbmYqUUW7Lv6sKu(ArYLB6dU1cWxBrP5uy2STDgO8VQLoUhKWMn49d4i8t15CHjeMRFuTPeAEfQXqN0vYJ0MMgoz88FBjG43YO31lqwtC8vFcRmDKVNg5vJYTmP5ORjDhJmfiVgohqQxwjFyNboIcxVApq(iNSSK5DrMC6WI6X57MC1Sj6PRH2sy0McGtBJkkHUcInDRFuEeRx4m5kfbf5fyx7LtwipFXWP68fSVw7NqxLs5CwoBundh03hYVA4cgTlsS0OdxvN18U2hTS)VNcYli5SE)TtsWu8QhXp6Cq8vBjzG2pt9flU4yXUnldTfR22iI(2ODd1UBHZU72707Vvd1yBx6saC5R4kgPH02ImTXRBvH(0cfQBtYQh2o5e6gwf11Y)TGCfvBSQTxVR9nRkDYmdnj0qDvIi)SuqtvlvoGZFHGfIKgLjBALwQDrlcsJmiJER3zjsIN3ENLiUET3zzO3zrX4ETnz9ABYsRiXRTjldmOxBtwTPnzPLt2dTQkJoFP4mLClLb9EC7whSsvfPDWut)OcdKw3uF6Iv8Vw9Zhc(Z)pPF(OTV8GOL7LRX9yX(Y)c34E02aE0TVC27qpI7lV2HES3z1ESd9y(EiqOyLWCMrQgSnD6NAXfS7OaPP8uM87f937rxigDbqOGv(126OO9MstAo(4IGw4JnDvF6t3Xq0lyIWbIkbYztUs9oW1NU7lLe3mNqS8pftwEutgMOv6wN)iMxse3IgTLCXmWQb4Ixl(j1gcEqUAiK4y0u7d81cro)s6pnbfvc0IQgge(O5f)qnsWZ8N57Yrrwv5(hP64aGkj8Ij0iohnQNuN1U3eqTBFF00uekxfPtcxmD8CtfDsbBhBmXkkapHvGw)rA7kuADBLN0XMNqno2CeqsVkALlIEQuN8JsnZlwtPO7ocZVEDGxQigFW1lMtN6rL4ZuwkE3)usc4TZdE)IFr8BycT6tRjD5du5MPavW(gSTN236h0)YnO)(tSLrqRTqRAb2Xc6xhqjlkK7bbnQlVXfB4Sdrf9nq8eVdhDNIpN9uGMvxhEsrw4ZgHXgc7bKSatvgfRFAmOlo8u2So6M5bC(u1IupbFTWFbs1VDIcaGUhH3sZ5zkxsLInPsE7eAwiVOsbYPOJ8b8ude5hpLfceFaL1ytJbr3wMvNWpXdXclPQQztSjAGhiAlQusrd12yOuYgn3FjhPEcLNLoUbPaN613yGBP5pqUmSKVeiCfhnSh9P0GkUsTcBDQYvY)BGgTu6IMm)Q3RwzBGIr1s4xjvNhG7zpO9rflJ0vS)r(F)iz1uQPtNnEzPH9unfHAeDksnIIE2SeC6VTdfTkSFfvDeNlNDaK6cN8txB20Nt9ffCHwrHA4GhbJUkL3erGxjPeHPyA9uRFtxfeEH5Bkc1tIEPvTqBjsVBeNuRAXgdHwI(2IM)vTtKG7Y9q81wb)Rf1J(il6Hm4BLyJ)VE)Ptf3v3VfPFI(8YMQhH4cU)kfQ4YbVJxv)mcmKesRxJvPLzm3ZHt8TBu((2XHjFwDe9)dpdhDHwT5cyuEQ5lMIN3F6lkqZLlGB3v2nfL78KCP16MqbzmqQU8AS1L81ADRerdoDAUKk6xYQl5bO)6ds0xVkHBECNNkSQiMsIP6B1S92Hn0lmJwNQ(7Zb)sfefSzp2ydEGIV4uc2cVSEl3LeuGRTRUGJnLBwubzipcC5BwKohpK(LQDxFeoTAZ1)ltPs30prPqBhVXkekFPRu5)bHptSSB5BwSLnBeQZvvDjgJb3PlXcYcd4Ovyw0kA7Ow0oOFHpEzcg4x7wasJCLGqqH5vaLscnJlDdCXecHStmMEJhynFcJce1UAE3TScCbMXD)KZeN5tMnz6D3(fVCP9K7U9VV1ppg2Oyiw2nrXhx(2nnv(XBpUmMvsPSM)bed8EyUEzPr7zVU3JlbUdO)mbc79VgW6V1t)bwZUoeWx(WVfBZbGyAeXyJ9dzbkTgMZWP)8itWL7PGibv(xCs7Gj(Zgrc84tQLyssxQekKgTLWUu9IemR8TQDW6K39CEzHRYDmlbBLXBj8pjPocyEgK6iWuVi1ra7oj1DUKoMtrJv(vRqM1oCBle1xzS1WVCAP0ZZk0GuTPkOaFoNvW3gaxA1whCBMsBP6waClalFX5IasPHTKwTaOSOsztXEGANWh98ScniLGoI8DNf(6k4BdGPKpqNsBP6waClaRw5eLHTKwTaOucFF4LrZhnA6cF(ScCJGTNpxsJgJuVzLR9lWRb73PJ1i(CgWzlkZrGQPaF32qpRa3cWAMLGphRO6UTrEwbUrW2vtcws1Df8gbCx9JYs6URGVgWFKYVy)277(uLqgprU75g(2azlStsz890GkL1xnqTx0AOh(wydZsZ76XdXludhz0t2om2nDwNxO3axLqIpXZ(Y0DFdFBGSfH(qEQ6KGk5PkAOA(uLfUNOh(wCQYspd1JhBpvzyY2HXU5C05f6nWDgLHVoFHq0GSv2sZVb(nr72f9LGWhyxWESxYXLFXpg(Dq8fGCqial20kURF2F7itspU8(S0Q5LxkABy5UIF2RxZMmi24DVxI)pC8hZ)7rjCyHv)jO38)BB1f(tDfSivINe3a9bu1URiuidosGxymk4sS9juTusWvSsQAhCBPyHwy1ZC4RptCcc42jobbS6zoHsSWNSwcci(Yq3FtIfLyFEjXYjN4bYaS6SeKQJM9Kcqkal0)MLjx(XAlGB6b0sqTzasq2NjD6fby9S8QmAIo4x4)DsHf)32Y6o2IN9FR6d2v0T5(HD1m)vEFXUEbvdlt9h7QDx72jE)R7eNVDcJoP33NoFzCpzkrAT7B08YyONcnDSelicPPSQOEBRISHSWA6Sv8x4Oy6KPS(pg5(mcaYs6OdWI0p)oalcpjpbUgje7pQ785NBhOrcyDY040jNlaFwlQVZvnrrzl8K1brbyHIQwcWcJ1wleNoRGaWNaRa18deL0QO937L(2tZ8tmxQsameh95GeiiSeFpapbz7Dp4TcCc6rQmMy8B0BRkM7oLnckr0B33O3mu8zjHuArdv3vfhzAMT9OKO5RIJr6jBpcr7x34OJAQ2JmGy37UkAT)ptSG4hxVpeXNLmPOfnwloyA22JsBfhmmz7rODIdANQ9itJ4G6460W6fN)(ABN(vY7)PZUSDUSz)TsDC3NHHqe0qVSM7Zas6ty9IeqshGf5De3NaR3EZgKxCruw(tpugUL)CBb3MS4G8SKZ62cYzgtCql9tCT)gVSDT0lrIZV5p(l38RjuM24hQLAfAESGyWSOD)yhevU5Ane3fdN(Bh6m(dxacaERE0DRxsQ)OlQ7vUQih)5Ap6Izxo1z0OllEhEspZV8MOZfFOyWu21MUYR5oyZoCX0jwWibA99)6GwnRvUZ25OmQN7d32OIxvVlCMAnHJRkZXEWJ9NPbCKqmtlrvxk0KZkWncwhl4(4ZXkQ2XAUVUzAjQmYGmxAE9lW145z1CBNEBQ3EQyR9s6OPCJ)IYK1zYp0xFdUTe2DZbPZ0U3lC0j9M)CV(gCBjS7Ku35s6413GB7EgKDf8TbWTWUx7P6waClaRfv3DBFgKwb0xFdUTb8TbWTWL32t1Ta4wawlEWoTv4ZkG(6BW1wGBeS985Y(9zYEwbEnyF9n4AnlPNEnDw8WnBXg5zf4gbBxnjyjv3vWBeWD1pklP7Uc(Aa)9u(f73EF3Pk9It25DvaZFqXUCfAFQJjXwxz2NB43ki3IdLDGUBb0TbUw4Hm5t18KGk5t1KgQwljAFwR1i3BwsXcTH9o8BfKBHfZoq3Ta62axlCxU1sIwbvsjrlUw)wT3DUHVnq2c(bjx(KGAh4Ymh1dss9JD3fT6XWeWG2J4wDWMwlWYP7iOE4B7dZUvT7G(nThNxO3axlUxPwzzwMU7B4BdKTWAh5zQtcQKNP0F5vgptroTwGLtpEt9W32ZuTQzh0Vx805f6nWT)FgZ0G0VdbTquHs)ZSGvp6hYQsy2d8krcQYdRc(Ff1lf8I70dpQ)RyJ(SY84Kx))yVJKLBBDKFl(IkPKY(rsjNLQK9H5Wu1mhEx8Cw0k2kjQIILkT8M5WR03(GfsqGgDJgKes2PIoLyrqGgn69fWt1C17lDGusOsmx9ggjRqVxQVFW9GtZtA5C27abKYg9jLr(GyUss2vPACOobOPTektzIFjBo2uL)(xTfOhYlt016t1KrW90J(mk8e3)wU6KYxrm59wivXjRYzoDL4cv)kNS2ziXTR9R6Q0)dYeYvFQGX0lmlLYYiMRKiy4maNNUtN0bJjMxIObv6nM4mpVDcdt4ErsOwjClijZDkBENtLlbN55nb6A1ZFkDLjTUiqmzjBNt25vPvGZ56AW5mTmNPBBhILP3StqFe8A8Qt)3W4AWUNR0FeXkrzr98wgbUtrnNtriLk2Bc3Q6D8udl8qUJLUQcM26FUTtxVWWuXfPRWy6nfNmL04jkqp5rfT)Z)e33C(D(G4(OuMqltp7VwQPTFK)PmY8Pnxpet2Q1R)XUYNM)s5pwUAfyoDFyS636hCsidT)rQJyI7DK6OI5vhf55hPReXu(kmX9u(0PdIjOf61fkq4PE3tcte)PKy6lBpi(TL79SYWFeulY4t1vr8ycb3DuO4X)9)szdOCQYZDZ1R0sVzpO(FZ(pZEW6RDR4p)ZC5VvnFZ(hZE4PTlfwGTC(ShgkMDH1I1NTWRZ0JpE)DItHSJpoqnWReGRgsrTv)4J)9FF8r0VxWh2C8XrQPr9q7nQCLRxGTZx(C5I)sHIF(5D3iTO)(Jpojtp1iJObsfUcRhvduIGpRbd37rw1RxOEM7meU5i1J(Rl)233xAaKPIt(mNDR3Nizp0jrCuud0C6G9rRwc3v(rC8X3jwzniTz7I)Qu(753y)LxwcuA4QzPbQqapL4Cwd)KxWUAGqT3j(aSRrdAyz)sP3l3lv4p7bnv9ShCUajMTF2FweIiomosdTkWX7ZqUdg2N(pf09YhwlwIY5h9OW(SY)7jFZW(Z6WZhywkkwbRtoId(rrYlmmg2HbKePg2j07JAfUZifWfbg67HVfsioEWXK8GiNL3sc217icoMgayZA1)kw5jGvETyu7wSVzO1Xyr()wDq8pYGJSzZINr6co9QBgarzZbgLBv8bFiYTdcyiu3FEGHrCP3bgLxvlcEoAxbOqsLVm)NcSZUnlEA58vLvw4jrX3cqXgQap8NVfe2QtGXmWImW6HgbJ1eE3cPCji11dLGYYwTIKVUX(v02H0BCi1gRIyoVsqAalT1Cpzncc3IweRgzLGYqLh2qQfECyZ3yDsyl3h20ipa)S81lYOeBNNH9otdFoQxhura6tr81siEstbJqwkiI)abrmbpUnL8v28xCYmI68I(CL7ScSVJMEHJ(emVJqXYsv6g0mfItGR)ibU2vsjqyrmyzm4bdjafj3telsdq0fKkfVy0cu8g4iAtdQpMa4CXPZNOoDquvzFgPfipf3TpulKStErTJE228WyZnQ9Y(m(fzE2QuKz2(yBkbs4ZeibkLX2icFnw1Rg5BlwX8mILKqXECRi1llxqO39nI8uKw5TYFFBdjXT2ppOzDJy8ijmJX1s7p1ZpJ)kJ41LrqgDRTlWCS(EJHqUR34iTP0WrzskiWuS4m0qXniO7xTEV1jTKCa6NmGCO4Tj5aQ4VEroan7QnKduAx8gteKdH6mN2toqOwdJCOqroq7YwatV0qL3P9Ds712jt5C5EH8Of7f)479pBEATWtC8JTQJ9pB7NFfCO9wwIh32Og4QGowBPxS(T)2Q5sjN2BJu5mrk9XX(xy1XwVhD7cJgJKT1)AkEaaWhtO6i29ymo3jJvJLSfHsxz4xuuCqx1JLIJngEOXOW8vZA3MLkxa2ld)nwuVfKUcqzJ(1(NlwD9d6aS1mxpnF1Qs9FukJLUoI6vEmBht9OdhPrIAnPG5j4reHXQiqeD03BU6OTO4eRJYyGc1XECOzXWLeDQwe8GaHySb)T9WlHqF6whlCCKQGm0goIItOYIYWCqqHzss4IAUJOWBdcQP8A34WxOxbeO1XpHqc3AWR1FG8Wce2RaQ7Ef52RiMZf1uU9WUVJfalGH1(UofjDR8fXITGhQhtVWaotSU3WHjXc22MKDtv2C8FqbhsvIcDEnaCqRpS2Z0WIJN6L2PrOQkdty4So4F)dTMvcHJE7zlkPbrcidIaociFUb)DNScoAmgnM12F)XF4WAuKJpYMyKd(sCo7b9fN9xLPirQWejOoEe5XJiPPkR9NiMdv08BYMqUUGuBffFHJyixAgSWVadcwhnL0aJuFvvRObHBPaUMXUT)iUT8wr6blKWniNA6aSaY0GwcjIeWyprVQSPpYAdHgAggltTNkLgOYDcRR)Xc0OU4XNqyCvJej0V602dW)dinQ647uoHhMXZcd2SNaFfgqJEGvg(SkQ5kl)u2s6vCZQJOHsTuc1A)bwIjJKiwdN(FEGvlRA2h0k7wUZeTcMaAY4SeNiRrUNgecE4pWuBX37s63ftUOuO5inMWCZaXpioYnBgwbWljs0p)Jzkt)KP8VD7RHTDRfYkJdMIb46kHUAoDHhTRf07Yh)oD4vUgLuFuare0MQt4lLGtqYkiMiz661QW5jtaKh5X7j4PdzkhfIBdErpc37IIWYOySZ3RHmultGGK8RikMGBL2fLaOMWHLjwZyHw(JwdroBn7ryBpwDY(qcbPrx3v(2JS4)jl)ri6X3YSCAtCb8EtdsyWI5y97RYrb9AUR8RB1a98vAZsVjl3jgN4NEyXK3oYCBx)FRIkQAZtBxkzmghiB1O3OiMW7E7OdKtB6zN5n0AZuM7AzV78Tpn)fbQA92TluXevwMsBBvf5YGHQkkxjoQIBJ4lPtmc3YhJ65ExQ0rlI1FBQuXkflDUmfhW5b29Vwv4BC1eyCbcpqD5oKEZ4Srlc8SX(pdnMFnNyrxiLHf01BwglE4afh8VJmwdz4TupuiH9zzxEOn72kPyrW5XZgzaKqElgtGOIJvI2xRVSENMEJUoBhssYhHi7g4Zsp2LQVnLvFlCLmFlOVuwUSLs5LYYTc5DPSCVuwUxkl3oHuP4fJwGYPTSCD)i2gD9KqOYVIckGzdn1olyLdu1SNVshM24DReB2I9iv9btwTUXuGWMWbVF5ITJhxozZYfv0MMh986dFr6y(lsP5TaGdwIXuv8BeLy8PeMdvKYuvLQTzq9gkXtdzfW1SqyP1OgEiACkhUXaq3qajnEiVWtBeVAxwpnhrAKfHjPVvSZkoWlAP2)YyQfJXu4uJy5wQXGk1(6sr)7kJIUO)r8LtpSgU8kuAPeJIpjX05ajReWBDhbq5bz1GU0rarqRG)TcHIwPaNwj62kiz0kTUDbOtGiBkD8ifU0UaPk2lNT2fWoXHwL0pDgtzPkWoUAWN6IW(AZMH627l(Jx2moeDxemFBPvqWXYAhFyqnqJPiMqfKk3CMHswJawLWvted)MSM6NVF92sHxNiPJHhgDsUuHZC)0ZLcK8Yxyco9bqu6TlCo7lDcSqjdMgQSBGRNzaEvjgquYKmhQC7stKPSsqHmcN)ntVnBbwCWywJMzYk5eyX4XrboE(zmS(2lcEHGIMtEqja8EDrFpluL6WuRbOyuSdAl3fvYRl3V4NBe(gJfRIOXOXxCOv1SMkl)mwV85mAQpidFidyMqHlCl7yB5tybgWJhDb4cMTHi2LQygE5f1YQdLBUrQnhgPmqA3b6AWaSYeqpTOh9jSDf(ze9PlsXBvZCMJncOLV0utc6BMklj0vgDwtq9PmWyBkSqj52NCoSbIacugCSBNS3aBhFw5agFYUJElCabLOqlKUtClELvuOI5YSdMKD6Tp)tz0MoslFM7mDsMXxLxXdvO9lfC6jAXgY26q)n1aUbyf3jhnuKA65qJVdfNCnZRmwx8hA2Va1dDHs7uJ0mzxSw(fP52wOZAlVv9CxWcLlKFAqvTST3bq2kTEUaU0botPl7)iIf8uv5))bGNbunDMBKn5IqSZuIMJfUf0aDdmEtIuIoH9eZPINR7NdL3VmvTdWnp(QY6e5GCmnthBFotcBeMQfZjtEBX(MwLKJ2f(wJXn0IZolPINXAbxCh20avJ8SirL2bjI6vIjectXALkph9AvVi3o5w2e6HhW0M2Kk8EYIQ32l(qKCWNs7emudkJpWeu(boL5iBHICrBlvJ8NyyX8hmjPYT3CRd(1O3aEOB(BIE7G2AYoI2ggR(kc3q1BRHSibVYxoUJmYvLO7)PTfUQncuDpsb1CNtZp5g3aK4CWedceMQ4ZXIpkJKdMdP6pTbSZnq8qGL5HAtU)7BxUAvDfwOtRYZZ)jS3E(MBxboGjE7TrnfuIK99RlUkmFnebKOhi4kgZVrmTpsEcsHjorOJ0SLbDQsBQ3)oT(ckqoaytfZ9yD4ijo5iDQVD6BCVJGcxpiASz3XdIUFPxHAm7m0Of35R5iwIJ79O5D8E9d2jd705tFEgx0AOnXbx0DCIxrIji79UYU1hu3w6UDVsvFmG(HMOJAbmhGUAu0Np(9U7uUJANGMaAupA998AcCiwmC)0Qfa2iAswviZ446KWGPqfvYdlHq4yjHfqTRiDNc1iR)F7DT0CBKBe(3IVm1q5A3nAO8AFqIPYMCjx2dRYztpMIYMLPizXhzlNd63EaWmyaAG(fgr7vkzVK4veZman6Ur3F9dWHUJcnhfTAAeG2aVEeZ5WemL4VYV5)DqtcMKbFCJAa65bmEqf9n0k6F2wXQmBUykKWn2T5kTyPzekApT(4awAdpZQd7pT7ykbnHEkh94E1SyxsyrLl)p5(hnwmJm)nJTdTl(Y8p3EWMA5t8Jl4lFulUlZDE0uk6cFhW7YEFeC)hDI(q(lFpZZ8e)CyqhTRVfTHgrI99ErN5iW(gOtZAp4Y2P1oBQhCy5ITBUlo05E4tXqbsMOwN7Uig6f5yqcTuCZYfg(5wZm5qRzjy0ocEpM5W8pUDZPdgJ3x(7T7)9vh)8QnZpSS9GHy1m)QDlCsQacW)ALDbpDQnrk6w6hTS9lT0u3Dt5qIiT2O090odBS99A()(v)S5XpCRF6etYaztlgosY0TxjwuyvWsDaM77dE0cZCpSbLK)FOFR(C3rrUyL(zBe)SnQ)SKPlyYg7)WLp1p(bBA25YO6HnYpBE8vB(u)(7PdU)DRzR)y7XGEXOhODZD2)NO3vNNGddjEBhKh3yqNbML3UCx7ExfP0XeSURNp4Mz2CMRldHSFOLldmkzn4VW5eKjueOla2UNh5k8lUh7o2AZbIRDN)82lzMqGooyNM7DMJW2(WhBpIfhezzbih6Qh2TF7)E1bBMvTS1qUwD6H57Axy4i(c8MbXN6OZT5642v3HwK3f85Bg1NVb85lxdkC1tvrtWrXxJOWXYwOOWHYunOjVZOAHaW0)lRnhzz5qGQynFn7LhNv8ms4Zlp6Lk(Ndht0lygRh2fCUov1)G9KbJDj22vMt22qN2h)In7HRx(G5KN2bAEklJvGyCAUHSlI7xnfSF1OF)IRweqENOLW7adSNyKQpZsm2VKKC4Fp7)0CBDG5TF72)YGgicFkGwY924rMAJDQrIMpAFZ5n1mX(AahXkXGJR9r7hogfH(cneQdPNjj6GbiulaYl0(InkCpqxHPYIuaI9U4SePDxtObfYdYK(AqCMAXG0k0NZup2PbSHpyP9)0yASWywXk6SvQBqUw1mU)60Ni)8EjnlDfn4zNy)xnMFnBgJhQbXScGjUxohSO5PyBZPXcG6d)kTiVC02IbSgVqbclLm4LfdJtPryRKOBxw0vpxekCPkUy)Oly7PePuMbiUzuvjuzYumQjK7wRphwq1yqWcW1ftnczarzYw3rUOvWWrhpxfy)FVUgpAn3mHParcsKcHVsvCU4)w2xd3T5ATesooZnLnUHV4HqSs7OIeH(AycPIBc1i2sPnabtxDjFM9G65Y9XesZeCdS4pNoRdVkKtg9bn7(1N233lzf)eP5qm95R9mhITzA0RDFkXzivfR5RkCi5iookpENvCMMdKCgBV9Qsvwyc1fqy7uKqgyX7CuI(GuAeJOkWX05mwumK0dJ1yu9L8MyePYzvat4sIPE2QHmuM8e)kT2Tgh6(g6dg1N2gvjLJy8UyL(JqieAGgKx(onJvUDXmZ)Z0jrbmetCbH7nWxixED)(rbLjMcBi)fQMwY8PPkX)9BCPUULMpK(77)KrL6c3qXvJKar3FR3aGh)WV1JEmajhZ769Jdg1(SyaRBmwLzYiAnceRC9T(Nk7uOZt4EZ)CuJCwszDlP5IX83idIsR4HjEHrKLSQEjniMEWQTtOu1yqWbLBTgY9D3H4SlHCLx9iEVBm1uLXd30zBYogGPqMbqbFwTcAYjXRZYjXxZS8M4)5b2vVH1KVXPWaulKUgyz(P8bjtIgn(Chr)2DhWU7qs1vs8unkmSdgmAMnJiOH46eWVcr)C33idkapXq0HBKZFbrjv8O4RdfFdEBbAcNxkcoP8TMZ)Q)W2Hc0w(CanNKr1EdzV8gJB)6sOwMVzNzrMKbB5wIgPP(6h9x4B1ABtbCHloe7gwim5LeopDPdoNlyWumuZHHdyDZQ8E7GAsY9QRmECoZGAx7RW6IDQDxbl8rnodWqGAA2SSS5tjiHSoJjOqdIkuz3auJIsH1Foq(Za5F8lC0KLbhLIFfo2qtYF09Sh)EDpokzQ8ShJApP1qTYhtZUd3Gqgrt0ia2aG)gIYKbBt2YMAq)y7MVo)UDO)UFj4NIr)8WQJXOihWaCpYSHgjp2CVHyU380M7yzA1tAUNyFVQUQQ3cGruCRvmQwkSWxzGygxBpeQn8SjTIxJBKYXu3ajvghoBMyLp6dCgBW2j9sfzxn2nTsJiT469(cUxPkp0OcQ88LTQcGbcFN1B3(fJ4z7M5FXyhl8OyKZUUmnYzHLRaU(PM)PMjX(GcW6ps6z8Jf2KfHZ8kDhS9gP9SzO8NaWBuCiNhy1HHMQQH4rEn7MjTnXp9qOqu1p5XZG2uFSxbbhBgaDcLrbTj3AE5vFlbkKyHlSGykbZCVi1u47vKgVYprEcx6rxlDH6w9NgT9c3OnzynaHJ6SCfRonCmacYqHVCsaMBkfyyAiMBkQGq7jQkCHdP054Buyrfc4ncxtXE7mkUobPTq4BNcZygO86XTH2McX2Fu2wj9zM4gsf0JYuVTahxoSWmlEWYA9X9Nm)TvhtRH8V91y7u6di5T1HR(SFhtuyMQhgQ4OtjANIcPOyU3P0hFvWz1AnsPskNxqoGDQqW1gZL15zcZo)DEd3ggt4eP1QnvxnD(Rtfcx2lTRWvMnumLnmIZcEP(sJWWV6Jt1ZPcoSogXL7vF32E)HVpTRVUFmk(tW8Tks0PSM5N49ATB2eQj55dYU3TD7dAPN1HJ(K(E1XJU4mFk1M0FiH6k9yPUwZG6qD5(QhHbjaWQUiRhFWQqKYJFPbZURvKXEYsP3ecQBztHj464T8jo5ujwr6ipqguHXbY2S8Wk4bpn9QKUVG5dMHjmQPryxRd)U6CrS4uejb0YOrf3IN6g0earHRYlQzsGVHvj)mAc0FDj45gbK8iVEcMAns22dqENUHMf3jgfb2(KWpICZuWRNRxA1T4rhzgW9uxmcZ83ugOSDuaAQu4E4pGp(K0mvtSrO94MmBsf1NXjyeszlaiXyPumjBd4jbKergZjjKokBaUb0yGWfhsLwarajww9JF9WH21Z)u7)z40fbDLmF1kvNYnlbeBW80(SKgO807vOvsobFnFIbqA0LODVWJKu2cFvOY3l8Zxop904nGAECcNXrPPgmDOC032sRzYdCXfzLm5sJon0ehKNNqLuzEUmstHo7DOuEdQLM7koJNHGMt0jRLY3eo8turTKUwq3Lvu3QMtYT6LqP)Xek5f5virKvMTI815wJbZ2zv05jXbtqysf2lqkjYbGVo7HD9zbhkg6APAprRaXHx(9zvBQAw1FoLypakHy5uVHSvttfRUs1bE2vXP5wccPjWYNOwkKyYGCEc4u0ryTuMXCibucQdkJ)Nc(oktuQvwwuc89Z8DqwfIp4rRqdBXmfz9q8CWrgyDkoA7if5d7pHEnW65dbIGogrAK2eLIeXPIJ4FtOJLXjkMans2UVORHPgobXClXTRmGwyYI1KxCbzlv0SzH9F4IELlNbuP)k1bbbQC8qZAVPxseut2GQ8SUTiJ(nak5ieU6YIjTwc1Kai6ffWso8(PaIOAmVmnOWgFIuKRTocoT3JsFcKUR(RvUcUOee7fmJL0VyMSou2e0IBbYmh6pQOR8)fDQxMezSgZ0GGHjODSzY80OU3JHFkdX9QYtEJUmceD3ggPvMeOZ9bFPfqrgU1YI0ktI49)El(yFAAAufJ(UGIM0s94CfQO28Byc03D(ydY5a9BOsv7TwrtILe1pyWLLuerReVgOmdw)QoUx2qBUrPy92tvs5fUbK)95f(xfPReP)kkqK0M9KAYzw8NW3qOnhyKeeECcODYAYlaQ2GCTqMJGofRzDog157jNVzFMhHkACG)H3WnfHhv2lGOvrWyI8GJFzwCaqSuSS42j2kMkvYImOb8NjkseLG2arl313Kvs)4o5GR0HgQVAY90bggWzYbPef50yUB)0gSHnr8h7Wk2fMr0i6P0thrgsEShPTIqD4NqIl8RKcafT)z0gDOEcHfpSAfeYi1njr)JHakASYtOsGq0BczwX8EsFJ4tf4jsbVMoyN3RRn9rF4Wt4mnrPIW0eMWF8qeqSHWGxrk5e)uizOh0Rci34geSsjyk9wEzMEPxXjXPopSrsaGQJ2IHrqEyqO6DqFMiV12kZTCfoHzBSwNo(5T7F)TgXV)U7V8()7p]] )
