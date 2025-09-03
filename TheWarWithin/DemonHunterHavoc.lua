-- DemonHunterHavoc.lua
-- August 2025
-- Patch 11.2

-- TODO: Queue fragments with sigils in combatlog like Vengeance

if UnitClassBase( "player" ) ~= "DEMONHUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State
local PTR = ns.PTR
local spec = Hekili:NewSpecialization( 577 )

---- Local function declarations for increased performance
-- Strings
local strformat = string.format
-- Tables
local insert, remove, sort, wipe = table.insert, table.remove, table.sort, table.wipe
-- Math
local abs, ceil, floor, max, sqrt = math.abs, math.ceil, math.floor, math.max, math.sqrt

-- Common WoW APIs, comment out unneeded per-spec
local GetSpellCastCount = C_Spell.GetSpellCastCount
-- local GetSpellInfo = C_Spell.GetSpellInfo
-- local GetSpellInfo = ns.GetUnpackedSpellInfo
-- local GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
-- local FindUnitBuffByID, FindUnitDebuffByID = ns.FindUnitBuffByID, ns.FindUnitDebuffByID
local IsSpellOverlayed = C_SpellActivationOverlay.IsSpellOverlayed
local IsSpellKnownOrOverridesKnown = C_SpellBook.IsSpellInSpellBook
-- local IsActiveSpell = ns.IsActiveSpell

-- Specialization-specific local functions (if any)

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

    -- Demon Hunter
    aldrachi_design                = {  90999,  391409, 1 }, -- Increases your chance to parry by $s1%
    aura_of_pain                   = {  90933,  207347, 1 }, -- Increases the critical strike chance of Immolation Aura by $s1%
    blazing_path                   = {  91008,  320416, 1 }, -- Fel Rush gains an additional charge
    bouncing_glaives               = {  90931,  320386, 1 }, -- Throw Glaive ricochets to $s1 additional target
    champion_of_the_glaive         = {  90994,  429211, 1 }, -- Throw Glaive has $s1 charges and $s2 yard increased range
    chaos_fragments                = {  95154,  320412, 1 }, -- Each enemy stunned by Chaos Nova has a $s1% chance to generate a Lesser Soul Fragment
    chaos_nova                     = {  90993,  179057, 1 }, -- Unleash an eruption of fel energy, dealing $s$s2 Chaos damage and stunning all nearby enemies for $s3 sec. Each enemy stunned by Chaos Nova has a $s4% chance to generate a Lesser Soul Fragment
    charred_warblades              = {  90948,  213010, 1 }, -- You heal for $s1% of all Fire damage you deal
    collective_anguish             = {  95152,  390152, 1 }, -- Eye Beam summons an allied Vengeance Demon Hunter who casts Fel Devastation, dealing $s$s3 Fire damage over $s4 sec$s$s5 Dealing damage heals you for up to $s6 health
    consume_magic                  = {  91006,  278326, 1 }, -- Consume $s1 beneficial Magic effect removing it from the target
    darkness                       = {  91002,  196718, 1 }, -- Summons darkness around you in an $s1 yd radius, granting friendly targets a $s2% chance to avoid all damage from an attack. Lasts $s3 sec. Chance to avoid damage increased by $s4% when not in a raid
    demon_muzzle                   = {  90928,  388111, 1 }, -- Enemies deal $s1% reduced magic damage to you for $s2 sec after being afflicted by one of your Sigils
    demonic                        = {  91003,  213410, 1 }, -- Eye Beam causes you to enter demon form for $s1 sec after it finishes dealing damage
    disrupting_fury                = {  90937,  183782, 1 }, -- Disrupt generates $s1 Fury on a successful interrupt
    erratic_felheart               = {  90996,  391397, 2 }, -- The cooldown of Fel Rush is reduced by $s1%
    felblade                       = {  95150,  232893, 1 }, -- Charge to your target and deal $s$s2 Fire damage. Demon Blades has a chance to reset the cooldown of Felblade. Generates $s3 Fury
    felfire_haste                  = {  90939,  389846, 1 }, -- Fel Rush increases your movement speed by $s1% for $s2 sec
    flames_of_fury                 = {  90949,  389694, 2 }, -- Sigil of Flame deals $s1% increased damage and generates $s2 additional Fury per target hit
    illidari_knowledge             = {  90935,  389696, 1 }, -- Reduces magic damage taken by $s1%
    imprison                       = {  91007,  217832, 1 }, -- Imprisons a demon, beast, or humanoid, incapacitating them for $s1 min. Damage may cancel the effect. Limit $s2
    improved_disrupt               = {  90938,  320361, 1 }, -- Increases the range of Disrupt to $s1 yds
    improved_sigil_of_misery       = {  90945,  320418, 1 }, -- Reduces the cooldown of Sigil of Misery by $s1 sec
    infernal_armor                 = {  91004,  320331, 2 }, -- Immolation Aura increases your armor by $s2% and causes melee attackers to suffer $s$s3 Fire damage
    internal_struggle              = {  90934,  393822, 1 }, -- Increases your mastery by $s1%
    live_by_the_glaive             = {  95151,  428607, 1 }, -- When you parry an attack or have one of your attacks parried, restore $s1% of max health and $s2 Fury. This effect may only occur once every $s3 sec
    long_night                     = {  91001,  389781, 1 }, -- Increases the duration of Darkness by $s1 sec
    lost_in_darkness               = {  90947,  389849, 1 }, -- Spectral Sight has $s1 sec reduced cooldown and no longer reduces movement speed
    master_of_the_glaive           = {  90994,  389763, 1 }, -- Throw Glaive has $s1 charges and snares all enemies hit by $s2% for $s3 sec
    pitch_black                    = {  91001,  389783, 1 }, -- Reduces the cooldown of Darkness by $s1 sec
    precise_sigils                 = {  95155,  389799, 1 }, -- All Sigils are now placed at your target's location
    pursuit                        = {  90940,  320654, 1 }, -- Mastery increases your movement speed
    quickened_sigils               = {  95149,  209281, 1 }, -- All Sigils activate $s1 second faster
    rush_of_chaos                  = {  95148,  320421, 2 }, -- Reduces the cooldown of Metamorphosis by $s1 sec
    shattered_restoration          = {  90950,  389824, 1 }, -- The healing of Shattered Souls is increased by $s1%
    sigil_of_misery                = {  90946,  207684, 1 }, -- Place a Sigil of Misery at the target location that activates after $s1 sec. Causes all enemies affected by the sigil to cower in fear, disorienting them for $s2 sec
    sigil_of_spite                 = {  90997,  390163, 1 }, -- Place a demonic sigil at the target location that activates after $s2 sec. Detonates to deal $s$s3 Chaos damage and shatter up to $s4 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond $s5 targets
    soul_rending                   = {  90936,  204909, 2 }, -- Leech increased by $s1%. Gain an additional $s2% leech while Metamorphosis is active
    soul_sigils                    = {  90929,  395446, 1 }, -- Afflicting an enemy with a Sigil generates $s1 Lesser Soul Fragment
    swallowed_anger                = {  91005,  320313, 1 }, -- Consume Magic generates $s1 Fury when a beneficial Magic effect is successfully removed from the target
    the_hunt                       = {  90927,  370965, 1 }, -- Charge to your target, striking them for $s$s3 Chaos damage, rooting them in place for $s4 sec and inflicting $s$s5 Chaos damage over $s6 sec to up to $s7 enemies in your path. The pursuit invigorates your soul, healing you for $s8% of the damage you deal to your Hunt target for $s9 sec
    unrestrained_fury              = {  90941,  320770, 1 }, -- Increases maximum Fury by $s1
    vengeful_bonds                 = {  90930,  320635, 1 }, -- Vengeful Retreat reduces the movement speed of all nearby enemies by $s1% for $s2 sec
    vengeful_retreat               = {  90942,  198793, 1 }, -- Remove all snares and vault away. Nearby enemies take $s$s2 Physical damage
    will_of_the_illidari           = {  91000,  389695, 1 }, -- Increases maximum health by $s1%

    -- Havoc
    a_fire_inside                  = {  95143,  427775, 1 }, -- Immolation Aura has $s1 additional charge, $s2% chance to refund a charge when used, and deals Chaos damage instead of Fire. You can have multiple Immolation Auras active at a time
    accelerated_blade              = {  91011,  391275, 1 }, -- Throw Glaive deals $s1% increased damage, reduced by $s2% for each previous enemy hit
    blind_fury                     = {  91026,  203550, 2 }, -- Eye Beam generates $s1 Fury every second, and its damage and duration are increased by $s2%
    burning_hatred                 = {  90923,  320374, 1 }, -- Immolation Aura generates an additional $s1 Fury over $s2 sec
    burning_wound                  = {  90917,  391189, 1 }, -- Demon Blades and Throw Glaive leave open wounds on your enemies, dealing $s$s2 Chaos damage over $s3 sec and increasing damage taken from your Immolation Aura by $s4%. May be applied to up to $s5 targets
    chaos_theory                   = {  91035,  389687, 1 }, -- Blade Dance causes your next Chaos Strike within $s1 sec to have a $s2-$s3% increased critical strike chance and will always refund Fury
    chaotic_disposition            = {  95147,  428492, 2 }, -- Your Chaos damage has a $s1% chance to be increased by $s2%, occurring up to $s3 total times
    chaotic_transformation         = {  90922,  388112, 1 }, -- When you activate Metamorphosis, the cooldowns of Blade Dance and Eye Beam are immediately reset
    critical_chaos                 = {  91028,  320413, 1 }, -- The chance that Chaos Strike will refund $s1 Fury is increased by $s2% of your critical strike chance
    cycle_of_hatred                = {  91032,  258887, 1 }, -- Activating Eye Beam reduces the cooldown of your next Eye Beam by $s1 sec, stacking up to $s2 sec
    dancing_with_fate              = {  91015,  389978, 2 }, -- The final slash of Blade Dance deals an additional $s1% damage
    dash_of_chaos                  = {  93014,  427794, 1 }, -- For $s1 sec after using Fel Rush, activating it again will dash back towards your initial location
    deflecting_dance               = {  93015,  427776, 1 }, -- You deflect incoming attacks while Blade Dancing, absorbing damage up to $s1% of your maximum health
    demon_blades                   = {  91019,  203555, 1 }, -- Your auto attacks deal an additional $s$s2 Shadow damage and generate $s3-$s4 Fury
    demon_hide                     = {  91017,  428241, 1 }, -- Magical damage increased by $s1%, and Physical damage taken reduced by $s2%
    desperate_instincts            = {  93016,  205411, 1 }, -- Blur now reduces damage taken by an additional $s1%. Additionally, you automatically trigger Blur with $s2% reduced cooldown and duration when you fall below $s3% health. This effect can only occur when Blur is not on cooldown
    essence_break                  = {  91033,  258860, 1 }, -- Slash all enemies in front of you for $s$s2 Chaos damage, and increase the damage your Chaos Strike and Blade Dance deal to them by $s3% for $s4 sec. Deals reduced damage beyond $s5 targets
    exergy                         = {  91021,  206476, 1 }, -- The Hunt and Vengeful Retreat increase your damage by $s1% for $s2 sec
    eye_beam                       = {  91018,  198013, 1 }, -- Blasts all enemies in front of you, dealing guaranteed critical strikes for up to $s$s2 Chaos damage over $s3 sec. Deals reduced damage beyond $s4 targets. When Eye Beam finishes fully channeling, your Haste is increased by an additional $s5% for $s6 sec
    fel_barrage                    = {  95144,  258925, 1 }, -- Unleash a torrent of Fel energy, rapidly consuming Fury to inflict $s$s2 Chaos damage to all enemies within $s3 yds, lasting $s4 sec or until Fury is depleted. Deals reduced damage beyond $s5 targets
    first_blood                    = {  90925,  206416, 1 }, -- Blade Dance deals $s$s2 Chaos damage to the first target struck
    furious_gaze                   = {  91025,  343311, 1 }, -- When Eye Beam finishes fully channeling, your Haste is increased by an additional $s1% for $s2 sec
    furious_throws                 = {  93013,  393029, 1 }, -- Throw Glaive now costs $s1 Fury and throws a second glaive at the target
    glaive_tempest                 = {  91035,  342817, 1 }, -- Launch two demonic glaives in a whirlwind of energy, causing $s$s2 Chaos damage over $s3 sec to all nearby enemies. Deals reduced damage beyond $s4 targets
    growing_inferno                = {  90916,  390158, 1 }, -- Immolation Aura's damage increases by $s1% each time it deals damage
    improved_chaos_strike          = {  91030,  343206, 1 }, -- Chaos Strike damage increased by $s1%
    improved_fel_rush              = {  93014,  343017, 1 }, -- Fel Rush damage increased by $s1%
    inertia                        = {  91021,  427640, 1 }, -- The Hunt and Vengeful Retreat cause your next Fel Rush or Felblade to empower you, increasing damage by $s1% for $s2 sec
    initiative                     = {  91027,  388108, 1 }, -- Damaging an enemy before they damage you increases your critical strike chance by $s1% for $s2 sec. Vengeful Retreat refreshes your potential to trigger this effect on any enemies you are in combat with
    inner_demon                    = {  91024,  389693, 1 }, -- Entering demon form causes your next Chaos Strike to unleash your inner demon, causing it to crash into your target and deal $s$s2 Chaos damage to all nearby enemies. Deals reduced damage beyond $s3 targets
    insatiable_hunger              = {  91019,  258876, 1 }, -- Demon's Bite deals $s1% more damage and generates $s2 to $s3 additional Fury
    isolated_prey                  = {  91036,  388113, 1 }, -- Chaos Nova, Eye Beam, and Immolation Aura gain bonuses when striking $s1 target.  Chaos Nova: Stun duration increased by $s4 sec.  Eye Beam: Deals $s7% increased damage.  Immolation Aura: Always critically strikes
    know_your_enemy                = {  91034,  388118, 2 }, -- Gain critical strike damage equal to $s1% of your critical strike chance
    looks_can_kill                 = {  90921,  320415, 1 }, -- Eye Beam deals guaranteed critical strikes
    mortal_dance                   = {  93015,  328725, 1 }, -- Blade Dance now reduces targets' healing received by $s1% for $s2 sec
    netherwalk                     = {  93016,  196555, 1 }, -- Slip into the nether, increasing movement speed by $s1% and becoming immune to damage, but unable to attack. Lasts $s2 sec
    ragefire                       = {  90918,  388107, 1 }, -- Each time Immolation Aura deals damage, $s1% of the damage dealt by up to $s2 critical strikes is gathered as Ragefire. When Immolation Aura expires you explode, dealing all stored Ragefire damage to nearby enemies
    relentless_onslaught           = {  91012,  389977, 1 }, -- Chaos Strike has a $s1% chance to trigger a second Chaos Strike
    restless_hunter                = {  91024,  390142, 1 }, -- Leaving demon form grants a charge of Fel Rush and increases the damage of your next Blade Dance by $s1%
    scars_of_suffering             = {  90914,  428232, 1 }, -- Increases Versatility by $s1% and reduces threat generated by $s2%
    screaming_brutality            = {  90919, 1220506, 1 }, -- Blade Dance automatically triggers Throw Glaive on your primary target for $s1% damage and each slash has a $s2% chance to Throw Glaive an enemy for $s3% damage
    serrated_glaive                = {  91013,  390154, 1 }, -- Enemies hit by Chaos Strike or Throw Glaive take $s1% increased damage from Chaos Strike and Throw Glaive for $s2 sec
    shattered_destiny              = {  91031,  388116, 1 }, -- The duration of your active demon form is extended by $s1 sec per $s2 Fury spent
    soulscar                       = {  91012,  388106, 1 }, -- Throw Glaive causes targets to take an additional $s1% of damage dealt as Chaos over $s2 sec
    tactical_retreat               = {  91022,  389688, 1 }, -- Vengeful Retreat has a $s1 sec reduced cooldown and generates $s2 Fury over $s3 sec
    trail_of_ruin                  = {  90915,  258881, 1 }, -- The final slash of Blade Dance inflicts an additional $s$s2 Chaos damage over $s3 sec
    unbound_chaos                  = {  91020,  347461, 1 }, -- The Hunt and Vengeful Retreat increase the damage of your next Fel Rush or Felblade by $s1%. Lasts $s2 sec

    -- Aldrachi Reaver
    aldrachi_tactics               = {  94914,  442683, 1 }, -- The second enhanced ability in a pattern shatters an additional Soul Fragment
    army_unto_oneself              = {  94896,  442714, 1 }, -- Felblade surrounds you with a Blade Ward, reducing damage taken by $s1% for $s2 sec
    art_of_the_glaive              = {  94915,  442290, 1 }, -- Consuming $s2 Soul Fragments or casting The Hunt converts your next Throw Glaive into Reaver's Glaive.  Reaver's Glaive: Throw a glaive enhanced with the essence of consumed souls at your target, dealing $s$s5 Physical damage and ricocheting to $s6 additional enemies. Begins a well-practiced pattern of glaivework, enhancing your next Chaos Strike and Blade Dance. The enhanced ability you cast first deals $s7% increased damage, and the second deals $s8% increased damage
    evasive_action                 = {  94911,  444926, 1 }, -- Vengeful Retreat can be cast a second time within $s1 sec
    fury_of_the_aldrachi           = {  94898,  442718, 1 }, -- When enhanced by Reaver's Glaive, Blade Dance casts $s1 additional glaive slashes to nearby targets. If cast after Chaos Strike, cast $s2 slashes instead
    incisive_blade                 = {  94895,  442492, 1 }, -- Chaos Strike deals $s1% increased damage
    incorruptible_spirit           = {  94896,  442736, 1 }, -- Each Soul Fragment you consume shields you for an additional $s1% of the amount healed
    keen_engagement                = {  94910,  442497, 1 }, -- Reaver's Glaive generates $s1 Fury
    preemptive_strike              = {  94910,  444997, 1 }, -- Throw Glaive deals $s$s2 Physical damage to enemies near its initial target
    reavers_mark                   = {  94903,  442679, 1 }, -- When enhanced by Reaver's Glaive, Chaos Strike applies Reaver's Mark, which causes the target to take $s1% increased damage for $s2 sec. Max $s3 stacks. Applies $s4 additional stack of Reaver's Mark If cast after Blade Dance
    thrill_of_the_fight            = {  94919,  442686, 1 }, -- After consuming both enhancements, gain Thrill of the Fight, increasing your attack speed by $s1% for $s2 sec and your damage and healing by $s3% for $s4 sec
    unhindered_assault             = {  94911,  444931, 1 }, -- Vengeful Retreat resets the cooldown of Felblade
    warblades_hunger               = {  94906,  442502, 1 }, -- Consuming a Soul Fragment causes your next Chaos Strike to deal $s1 additional Physical damage. Felblade consumes up to $s2 nearby Soul Fragments
    wounded_quarry                 = {  94897,  442806, 1 }, -- Expose weaknesses in the target of your Reaver's Mark, causing your Physical damage to any enemy to also deal $s1% of the damage dealt to your marked target as Chaos, and sometimes shatter a Lesser Soul Fragment

    -- Felscarred
    burning_blades                 = {  94905,  452408, 1 }, -- Your blades burn with Fel energy, causing your Chaos Strike, Throw Glaive, and auto-attacks to deal an additional $s1% damage as Fire over $s2 sec
    demonic_intensity              = {  94901,  452415, 1 }, -- Activating Metamorphosis greatly empowers Eye Beam, Immolation Aura, and Sigil of Flame$s$s2 Demonsurge damage is increased by $s3% for each time it previously triggered while your demon form is active
    demonsurge                     = {  94917,  452402, 1 }, -- Metamorphosis now also causes Demon Blades to generate $s2 additional Fury. While demon form is active, the first cast of each empowered ability induces a Demonsurge, causing you to explode with Fel energy, dealing $s$s3 Fire damage to nearby enemies. Deals reduced damage beyond $s4 targets
    enduring_torment               = {  94916,  452410, 1 }, -- The effects of your demon form persist outside of it in a weakened state, increasing Chaos Strike and Blade Dance damage by $s1%, and Haste by $s2%
    flamebound                     = {  94902,  452413, 1 }, -- Immolation Aura has $s1 yd increased radius and $s2% increased critical strike damage bonus
    focused_hatred                 = {  94918,  452405, 1 }, -- Demonsurge deals $s1% increased damage when it strikes a single target. Each additional target reduces this bonus by $s2%
    improved_soul_rending          = {  94899,  452407, 1 }, -- Leech granted by Soul Rending increased by $s1% and an additional $s2% while Metamorphosis is active
    monster_rising                 = {  94909,  452414, 1 }, -- Agility increased by $s1% while not in demon form
    pursuit_of_angriness           = {  94913,  452404, 1 }, -- Movement speed increased by $s1% per $s2 Fury
    set_fire_to_the_pain           = {  94899,  452406, 1 }, -- $s2% of all non-Fire damage taken is instead taken as Fire damage over $s3 sec$s$s4 Fire damage taken reduced by $s5%
    student_of_suffering           = {  94902,  452412, 1 }, -- Sigil of Flame applies Student of Suffering to you, increasing Mastery by $s1% and granting $s2 Fury every $s3 sec, for $s4 sec
    untethered_fury                = {  94904,  452411, 1 }, -- Maximum Fury increased by $s1
    violent_transformation         = {  94912,  452409, 1 }, -- When you activate Metamorphosis, the cooldowns of your Sigil of Flame and Immolation Aura are immediately reset
    wave_of_debilitation           = {  94913,  452403, 1 }, -- Chaos Nova slows enemies by $s1% and reduces attack and cast speed by $s2% for $s3 sec after its stun fades
} )

-- PvP Talents
spec:RegisterPvpTalents( {
    blood_moon                     = 5433, -- (355995) Consume Magic now affects all enemies within $s1 yards of the target and generates a Lesser Soul Fragment. Each effect consumed has a $s2% chance to upgrade to a Greater Soul
    cleansed_by_flame              =  805, -- (205625) Immolation Aura dispels a magical effect on you when cast
    cover_of_darkness              = 1206, -- (357419) The radius of Darkness is increased by $s1 yds, and its duration by $s2 sec
    detainment                     =  812, -- (205596) Imprison's PvP duration is increased by $s1 sec, and targets become immune to damage and healing while imprisoned
    glimpse                        =  813, -- (354489) Vengeful Retreat provides immunity to loss of control effects, and reduces damage taken by $s1% until you land
    illidans_grasp                 = 5691, -- (205630) You strangle the target with demonic magic, stunning them in place and dealing $s$s2 Shadow damage over $s3 sec while the target is grasped. Can move while channeling. Use Illidan's Grasp again to toss the target to a location within $s4 yards
    rain_from_above                =  811, -- (206803) You fly into the air out of harm's way. While floating, you gain access to Fel Lance allowing you to deal damage to enemies below
    reverse_magic                  =  806, -- (205604) Removes all harmful magical effects from yourself and all nearby allies within $s1 yards, and sends them back to their original caster if possible
    sigil_mastery                  = 5523, -- (211489) Reduces the cooldown of your Sigils by an additional $s1%
    unending_hatred                = 1218, -- (213480) Taking damage causes you to gain Fury based on the damage dealt
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

-- Soul fragments metatable - Havoc DH (simpler than Vengeance due to limited real data)
spec:RegisterStateTable( "soul_fragments", setmetatable( {

    reset = setfenv( function()
        -- For Havoc - use spell cast count from Reaver hero tree talent
        soul_fragments.active = GetSpellCastCount( 232893 ) or 0
        soul_fragments.inactive = 0  -- Havoc doesn't track inactive fragments reliably
    end, state ),

    queueFragments = setfenv( function( count, extraTime )
        -- Simple virtual tracking for simulation purposes only
        count = count or 1
        soul_fragments.inactive = soul_fragments.inactive + count
    end, state ),

    consumeFragments = setfenv( function()
        -- Consume all active fragments
        gain( 20 * soul_fragments.active, "fury" )
        soul_fragments.active = 0
    end, state ),

}, {
    __index = function( t, k )
        if k == "total" then
            return ( rawget( t, "active" ) or 0 ) + ( rawget( t, "inactive" ) or 0 )
        elseif k == "active" then
            return rawget( t, "active" ) or 0
        elseif k == "inactive" then
            return rawget( t, "inactive" ) or 0
        end

        return 0
    end
} ) )

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

local DemonsurgeHardcast = false

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _, subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID == GUID then
        if spellID == 228532 then
            -- Consumed
            soul_fragments.reset()
        end
        if subtype == "SPELL_CAST_SUCCESS" then
            if spellID == 198793 and talent.initiative.enabled then
                wipe( initiative_actual )
            elseif spellID == 228537 then
                -- Generated
                soul_fragments.reset()
            elseif ( spellID == 191427 or spellID == 200166 ) and state.talent.demonic_intensity.enabled then
                DemonsurgeHardcast = true
            end
        elseif state.set_bonus.tier30_2pc > 0 and subtype == "SPELL_AURA_APPLIED" and spellID == 408737 then
            furySpent = max( 0, furySpent - 175 )
        elseif state.talent.initiative.enabled and subtype == "SPELL_DAMAGE" then
            initiative_actual[ destGUID ] = true
        elseif subtype == "SPELL_AURA_REMOVED" and spellID == 162264 then
            DemonsurgeHardcast = false
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
spec:RegisterGear({
    -- The War Within
    tww3 = {
        items = { 237691, 237689, 237694, 237692, 237690 },
        auras = {
            -- Fel-Scarred
            -- Havoc
            demon_soul_tww3 = {
                id = 1238676,
                duration = 10,
                max_stack = 1
            },
        }
    },
    tww2 = {
        items = { 229316, 229314, 229319, 229317, 229315 },
        auras = {
            winning_streak = {
                id = 1217011,
                duration = 3600,
                max_stack = 10
            },
            necessary_sacrifice = {
                id = 1217055,
                duration = 15,
                max_stack = 10
            },
            winning_streak_temporary = {
                id = 1220706,
                duration = 7,
                max_stack = 10
            }
        }
    },
    tww1 = {
        items = { 212068, 212066, 212065, 212064, 212063 },
        auras = {
            blade_rhapsody = {
                id = 454628,
                duration = 12,
                max_stack = 1
            }
        }
    },
    -- Dragonflight
    tier31 = {
        items = { 207261, 207262, 207263, 207264, 207266, 217228, 217230, 217226, 217227, 217229 }
    },
    tier30 = {
        items = { 202527, 202525, 202524, 202523, 202522 },
        auras = {
            seething_fury = {
                id = 408737,
                duration = 6,
                max_stack = 1
            },
            seething_potential = {
                id = 408754,
                duration = 60,
                max_stack = 5
            }
        }
    },
    tier29 = {
        items = { 200345, 200347, 200342, 200344, 200346 },
        auras = {
            seething_chaos = {
                id = 394934,
                duration = 6,
                max_stack = 1
            }
        }
    },
    -- Legacy Tier Sets
    tier21 = {
        items = { 152121, 152123, 152119, 152118, 152120, 152122 },
        auras = {
            havoc_t21_4pc = {
                id = 252165,
                duration = 8
            }
        }
    },
    tier20 = { items = { 147130, 147132, 147128, 147127, 147129, 147131 } },
    tier19 = { items = { 138375, 138376, 138377, 138378, 138379, 138380 } },
    -- Class Hall Set
    class = { items = { 139715, 139716, 139717, 139718, 139719, 139720, 139721, 139722 } },
    -- Legion/Trinkets/Legendaries
    convergence_of_fates = { items = { 140806 } },
    achor_the_eternal_hunger = { items = { 137014 } },
    anger_of_the_halfgiants = { items = { 137038 } },
    cinidaria_the_symbiote = { items = { 133976 } },
    delusions_of_grandeur = { items = { 144279 } },
    kiljaedens_burning_wish = { items = { 144259 } },
    loramus_thalipedes_sacrifice = { items = { 137022 } },
    moarg_bionic_stabilizers = { items = { 137090 } },
    prydaz_xavarics_magnum_opus = { items = { 132444 } },
    raddons_cascading_eyes = { items = { 137061 } },
    sephuzs_secret = { items = { 132452 } },
    the_sentinels_eternal_refuge = { items = { 146669 } },
    soul_of_the_slayer = { items = { 151639 } },
    chaos_theory = { items = { 151798 } },
    oblivions_embrace = { items = { 151799 } }
} )

-- Abilities that may trigger Demonsurge.
local demonsurge = {
    demonic = { "annihilation", "death_sweep" },
    hardcast = { "abyssal_gaze", "consuming_fire", "sigil_of_doom" },
}

-- Map old demonsurge names to current ability names due to SimC APL
local demonsurge_spell_map = {
    abyssal_gaze = "eye_beam",
    sigil_of_doom = "sigil_of_flame",
    consuming_fire = "immolation_aura"
}

local demonsurgeLastSeen = setmetatable( {}, {
    __index = function( t, k ) return rawget( t, k ) or 0 end,
})

spec:RegisterHook( "reset_precast", function ()
    -- Call soul fragments reset first
    soul_fragments.reset()

    -- Debug snapshot for soul_fragments (Havoc)
    if Hekili.ActiveDebug then
        Hekili:Debug( "Soul Fragments (Havoc) - Active: %d, Inactive: %d, Total: %d",
            soul_fragments.active or 0,
            soul_fragments.inactive or 0,
            soul_fragments.total or 0
        )
    end

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
        if DemonsurgeHardcast then
            applyBuff( "demonsurge_hardcast", metaRemains )
            for _, name in ipairs( demonsurge.hardcast ) do
                local ability_name = demonsurge_spell_map[name] or name
                if class.abilities[ ability_name ] and IsSpellOverlayed( class.abilities[ ability_name ].id ) then
                    applyBuff( "demonsurge_" .. name, metaRemains )
                end
            end

            -- The Demonsurge buff does not actually get applied in-game until ~500ms after
            -- the empowered ability is cast. Pretend that it's applied instantly for any
            -- APL conditions that check `buff.demonsurge.stack`.

            local pending = 0

            for _, list in pairs( demonsurge ) do
                for _, name in ipairs( list ) do
                    local ability_name = demonsurge_spell_map[name] or name
                    local hasPending = buff[ "demonsurge_" .. name ].down and abs( action[ ability_name ].lastCast - demonsurgeLastSeen[ name ] ) < 0.7 and action[ ability_name ].lastCast > buff.demonsurge.applied
                    if hasPending then pending = pending + 1 end
                    --[[
                    if Hekili.ActiveDebug then
                        Hekili:Debug( " - " .. ( hasPending and "PASS: " or "FAIL: " ) ..
                            "buff.demonsurge_" .. name .. ".down[" .. ( buff[ "demonsurge_" .. name ].down and "true" or "false" ) .. "] & " ..
                            "@( action." .. ability_name .. ".lastCast[" .. action[ ability_name ].lastCast .. "] - lastSeen." .. name .. "[" .. demonsurgeLastSeen[ name ] .. "] ) < 0.7 & " ..
                            "action." .. ability_name .. ".lastCast[" .. action[ ability_name ].lastCast .. "] > buff.demonsurge.applied[" .. buff.demonsurge.applied .. "]" )
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
        id = function() return buff.demonsurge_hardcast.up and 452497 or 198013 end,
        cast = function () return ( talent.blind_fury.enabled and 3 or 2 ) * haste end,
        channeled = true,
        cooldown = 40,
        gcd = "spell",
        school = "chromatic",

        spend = 30,
        spendType = "fury",

        talent = "eye_beam",
        startsCombat = true,
        -- nobuff = function () return talent.demonic_intensity.enabled and "metamorphosis" or nil end,
        texture = function() return buff.demonsurge_hardcast.up and 136149 or 1305156 end,

        start = function()
            if buff.demonsurge_abyssal_gaze.up then
                removeBuff( "demonsurge_abyssal_gaze" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
            applyBuff( "eye_beam" )
            if talent.demonic.enabled then TriggerDemonic() end
            if talent.cycle_of_hatred.enabled then
                reduceCooldown( "eye_beam", 5 * talent.cycle_of_hatred.rank * buff.cycle_of_hatred.stack )
                addStack( "cycle_of_hatred" )
            end
            removeBuff( "seething_potential" )
        end,

        finish = function()
            if talent.furious_gaze.enabled then applyBuff( "furious_gaze" ) end
        end,

        bind = "abyssal_gaze",
        copy = { 452497, 198013, "abyssal_gaze" }
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
                if buff.art_of_the_glaive.stack + soul_fragments.active >= 6 then
                    applyBuff( "reavers_glaive" )
                else
                    addStack( "art_of_the_glaive", soul_fragments.active )
                end
                addStack( "warblades_hunger", soul_fragments.active )
            end
            soul_fragments.consumeFragments()
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
        -- startsCombat = function() if prev[1].sigil_of_flame then return true else return false end end,

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
                setCooldown( "blade_dance", 0 )
                setCooldown( "death_sweep", 0 )
            end

            if talent.demonsurge.enabled then
                local metaRemains = buff.metamorphosis.remains

                for _, name in ipairs( demonsurge.demonic ) do
                    applyBuff( "demonsurge_" .. name, metaRemains )
                end

                if talent.violent_transformation.enabled then
                    setCooldown( "sigil_of_flame", 0 )
                    gainCharges( "immolation_aura", 1 )
                    if talent.demonic_intensity.enabled then
                        gainCharges( "consuming_fire", 1 )
                    end
                end

                if talent.demonic_intensity.enabled then
                    removeBuff( "demonsurge" )
                    applyBuff( "demonsurge_hardcast", metaRemains )

                    for _, name in ipairs( demonsurge.hardcast ) do
                        applyBuff( "demonsurge_" .. name, metaRemains )
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
        id = function()
            if buff.demonsurge_hardcast.up then
                return talent.precise_sigils.enabled and 469991 or 452490
            else
                return talent.precise_sigils.enabled and 389810 or 204596
            end
        end,
        known = 204596,
        cast = 0,
        cooldown = function() return ( pvptalent.sigil_of_mastery.enabled and 0.75 or 1 ) * 30 end,
        gcd = "spell",
        school = function() return buff.demonsurge_hardcast.up and "chaos" or "fire" end,

        spend = -30,
        spendType = "fury",

        startsCombat = false,
        texture = function() return buff.demonsurge_hardcast.up and 1121022 or 1344652 end,

        flightTime = function() return activation_time end,
        delay = function() return activation_time end,
        placed = function() return query_time < action.sigil_of_flame.lastCast + activation_time end,

        handler = function ()
            if buff.demonsurge_sigil_of_doom.up then
                removeBuff( "demonsurge_sigil_of_doom" )
                if talent.demonic_intensity.enabled then addStack( "demonsurge" ) end
            end
        end,

        impact = function()
            if buff.demonsurge_hardcast.up then
                applyDebuff( "target", "sigil_of_doom" )
                active_dot.sigil_of_doom = active_enemies
            else
                applyDebuff( "target", "sigil_of_flame" )
                active_dot.sigil_of_flame = active_enemies
            end
            if talent.soul_sigils.enabled then soul_fragments.queueFragments( 1 ) end
            if talent.student_of_suffering.enabled then applyBuff( "student_of_suffering" ) end
            if talent.flames_of_fury.enabled then gain( talent.flames_of_fury.rank * active_enemies, "fury" ) end
            if talent.initiative.enabled and debuff.initiative_tracker.down then applyBuff( "initiative" ) end
        end,

        copy = { 204596, 389810, 452490, 469991, "sigil_of_doom" },
        bind = "sigil_of_doom"
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
            soul_fragments.queueFragments( talent.soul_sigils.enabled and 4 or 3 )
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
    name = strformat(
        "You can reserve charges of %s to ensure that it is always available when needed. " ..
        "If set to your maximum charges (2 if you have either %s or %s talented, 1 otherwise), |W%s|w will never be recommended. " ..
        "Failing to use |W%s|w when appropriate may impact your DPS.",
        Hekili:GetSpellLinkWithTexture(185123),
        Hekili:GetSpellLinkWithTexture(389763),
        Hekili:GetSpellLinkWithTexture(429211),
        spec.abilities.throw_glaive.name,
        spec.abilities.throw_glaive.name
    ),
    type = "description",
    width = "full",
})

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

spec:RegisterPack( "Havoc", 20250831, [[Hekili:S3ZAZnYTr(BzRuHhP0kUCgkUETprELp74lXLpBxzDU8HRUD0iYHute5mmZdPvPuPF7xdmVWJUbaPOESj6lwE5GhnA0Vbq3FY7t)2N(4IWIOp9Z(J8Nm6dJ9g67pA0eVp9XIB3g9PpUnC(vHRG)NKWnW)9pgED6C2VE760WfSENNwMnh(YhJ3uUoSion57Ycxw8PpErz86I)uYNUqFg8M8EFFORBJM)PFEYx9vF6JxgVyruvBJYHj4KtU)8F7YO7p)VgMb)N4IlJtU)8pgfMNc)D89)iBWoz0hozS33C)5)qCsC(L3F(3hDYVMvMe19z)Qp)57p))jkzv0YY13F(FoQilkS4(ZxMcJ93(N7AT34VbBq88HF(VSLTkwu3RF7V(xbWzmGjYsxgVgw))UFhRn5SHEd08llk2M)nV7DRaqV8IHZt38U8wm0CggI9VN)UlwNEX7kUm6MWSB4RY39TZzn5xZItZIlU9NIZlYF3IOLHLRlG)Ujn5YYKIOSGlzBfdzdY9)iBYv2aU)8VlDZMy4VF82K5aen60WrJ)WIQg)9WAb(T2vO39)i8balfMfhEX6O861jdBxMd7dfzXjxfva)Eycdja7TrWpTcAszbFNbAFC5M7)Xqo8NpCBweSQViS44PV766H9TmQOP1JLxqomgPXlYF71HRlB)9HEdVmmpyEA66fP3K0t(NZlclggMCBWIT59Et33IZhgVb2nUoopArqEd8eaeWrBcVkkBhGmFkiZhhY8naz(UazaM))CnWPTg2TRX8Di8IuGCcMX2F7(ZBGGMTP)usCrmS3FDu9(Zphnpkppm7wyRb61vWVVooj6KYT8nS84fWVaaCYIWmXbga01rBIsk4es3FoqP)lF)VW2V)CfGCtA2vWqSC59NVkkbibMZGMKfXCulmajaQlCbRjWeam4XlVLtMedT564fLHRfxBCOFzzrzweGHG(4(MKxWCGbrJ0bW2Bcxe83lJIsYd2WwHfr3DNud(BLjxTjmcywtHMeTkeA3QKOcLMTkkmBf8dlIYGD3THzrbxfDBUsRYcVokjTmp4Y0KOBdUO8F8pIYuhPS4nazZIOpR15ILHjRcks)CCIY3UyDyEXMqgP44rJgP815LzCYPcywdIxKUw57BJYwgViMbyaM9VfnViD3ybqWU(2WU(UHD9Dc767a21Nc76Ba76Be76Bb76)qWUlZdkIHz80a)TXapAncopQi4I0KY8HIQcyYka9DbJHgp3LrpBvaiYQwzX0rVnD70SiySX7BE8Q41bPldwUg6mEBI3SjTsPsqyzwitlrDZGpUiopRCBbx81puYK1WfjuPMeWqGaGiMSbX(OGoGEfaDIbPaC2qUfUgKanKRSla2NatcoQV3VVV)W3FuyrbiNeu(bBCdoQFFX2MxMTkQ3fLlxoCtur4M0STxMMd7wLBhC04J98hm4y(xvwvdZzJ5rVV6JfmGDE46GSk7eGEFK3i(I8Jm5zmbyZVmA(v1sV6u9D(V2kr)C2qb)3iUSp2iYenZB))nNzOsT8LSptIDQP46uuWO1MJjXZS(fbnOCDumoByvPqs74y4RmgVj6VxgVDB0cxuY9BXmCZ4XGkG4k6JczKzRIiM2QYTGgcgRqUScTqyYxgppYaMJXJno4urES(vB9TAkRG(A6NUF(U74TlPz(cYBMUkYKztN0JSfzWAf0aE2OHtoUrh9WRRT8SLGQUvd61NCG4WMzPc(WYB(D31onr3gfCby8zZWFS)m1vCZetVxK3sHhYS6tCRztnD7IYOktbAiUbSUGrkUTNuRsy32AoeiSb9AGQH4Sx967KPc96lyHNOrHICvT7n1i(z(Jgm4U767K6sHzWJyg8WNb(273NwY3yuTGVABIVZX3wlZR2f5MdkyAPqh4wugMimwlcbyuymj30xWHIaa7d9RE3UtIbObcwOmvqW(fG9bxEUTx3NVeuVgX(6CWi1Cb8gFNr9RsFeBKh0ZiEtDFHA89Tp(O788DL)sEnVYIiWWJnGqoWYyqrXnCKjyRdZSJ7ppciCz8KmJOlyUbNULPzLjweChCin(M3Uf1i6LHRHPJR4kcSVc0lxPkknHpm1earHZbxNHPlLbcrssvb)GdQ(xbSUunhHzVfiwJNxm17TXlNY6zaRJddxVidgSyqqhBLu5P5)7hVfyr))U)CWJ(FiC96lcBLOSnkDlJeDD01rRxROkeDQxMln1VXWCZx3FB9VYC6V6NBmYjmdZ6P4K5YMIWL3KfLWyycyt9vrd5U(X)WQ1HGyjW(PYSSBbrq9A325wTeSimHlAQ3Q5lAOeMceATIGQMYEGfxxhWAJhyityXLb53efTTc)jbWBJbBFk3gSmlCfZlT3YcsZuaR(2kA1LSrPc3WmT6SPF9iJl5LrRdUimdgTiutWe(EV(TloHFTvJhd63e(5J(QE9RS2jaie3ehLpBky(wCgyuqbyVp403XzHXlcGTCy8dxSaS1oTmbCoq9NJt6guSVo7RhnqaOKT4RgSU7ofGXFqT(DX1ayEyV3Oa2t969g15m6Zm2Mbky05xgMMxtBWq8yKmajaobtFrsHf5t9rG4EfXBIM5PUtgMKeFzCLzSpkZBn)7Fm6Q41X)FmwOnPmRyRjjhwXPLhun4dz(tXKYV48w7gkUKPrHrDd4qMCTALnvmJ)BGeO)lEFbQ8LfmXBcY6gQSCLNT2fS8kRJ1KKNT4YS41RBKCVmE1LfbvQZ0OLp9yn00GJ7O4y9NfloT(nM5TrFsdZ6AxVA2SCapbRFGhb4vkItUfgaTTif5glyKOeYB0APpElvme1aQHBEfUyk4dkYZg0tMw6SX9weXNbWSTiyIdUa2nVQAtPAQdZAvMwtovzS94A2vuU7z(gm)9mpaHDrAEEVQfs3pRYa)eszD6JmMEMV8QD2uVr04Ec8JQ8nq9cMraT2JQkN4Nt5E)dQ43WOYa97WSWcaiyIz8MCM0HWKvvwGMLcUn)NlHpvf277p)N4HaLzI03btS8V)VxlzH33V775XgD1kMje3eZA7LrR3E)5xX0DE(CyOl5CxUUEQK7uBGraqgWK7EM3KEvtsRnD5V1W36HW3Z2sj0tX9cVsiG0(th)Q82gOQIByZpXDpMf0)vXRRSt8JBJlIQ8xMHSvci8PNW97c(oOZiIluEzuwghtYq2CZ6BJmmB8KaufCyBOJYztkdFqZGBsYtdTzdl4MWSRA5UN6FsnQbCiy(vmdBd4tCUb)aT3z38t0GKLzFOrGP8EznlfP4QJPK2pBQTLZXKRMbOmX(QmXegYhiAayhHVIqfU9KTsEeTju1up)EQ2mbePYqIsS3ER(053OwKnflbthzEcRzpQWgeI9OZYIaPmG9Mbmg1bw1)SB7KZMOQdzFwv6OkTFQvO8eQpnBc9AdXbcgQkRm)YwTCLjxaMFViGBflde0a7(DbIjkdeQ4qiNKh02OoDENCRUtJnR50yReC9hUnInI8aq16I6VXaQ5HITMD6YluflPgPnUGA1Oi1SpOgN3kZS9hHlbVxtKMZaE21aUoO6yyjLS3S)a2Bmqdh2dbnjq0v3kWZ24vRatH7SXqNovLsudhO5zOog5nuOeAJyNbKKcE1E2OHGPAY)GGrNAgNnvOP9SJbbeOAy76o94EAFR78BfSewVFcXtQ5SBBvKhOzSUyeMiB(SXJgOpN(iZP)UnNgAoBoh0r9(OsQXeOOt)80qM0hvGvLJRG7OQhQJKgGzVxmGY1YXQ)3BszHsPCJ1OjmJ5sHjZzA348BfxqnzOQxaR7efwKxuUa(l3olOX87BHaaiF(DTIzBcxWJoptlGyKvrTvSiu7khIlZaASwBr36EwBDx(U7iJQylx2EyDfHjuDKLIh3zpS4VXjyKJBfHrqSaArWdRa5qV4ZipAQkcoKTeyQhMKKMamjD2ngS2A3HkuPuWCOaSgKHmA4eB75nJ2600RYdMhMea(YUwlMyEAHoGyJNnjsrQgLz)HVQfBMDVTyHFGws9eACObR6mfbMP1SRDdm1rH220J1qXiwwxJecdyMrhaDh8zTbZCrzwcl6m3Wa1EWuXMlbfbIIOrIPSEh0icucNTdWR5b4agWCeW3bWtj(ptm7XUIxmi(yi0lQ4s3jlqlY0A(FyG(6uNd8wdLiLxuEIM9RBjrnP(BWiYgOS8BatrrQYX2PvbpJtcm4gyWdtY5XlJno2CP4Sjhp(ik9B26CL10MPipYhL4A8OMGqm)25R5hnkm7q)aIHKRoYF4KJ4BhQFLhjxjFG6URfwLmmBIPgHqVyq1VcRG4gvFJYnro)jMkwROr3I27UWGW(9bu7o0y)JM8fLluMxjUA94obqM9VYmabqKEm0f8usH7VtGMK9rA(qC8edC5uFHkWXsS)7fX((X(YCzs1WY3O5lKdCxhp(HOy0ISR3RhIgc)Jn4WzLw38PJ65KhPCws9fUo43Gk)WJppSloC9m5shoxMjdpmyR70wMmnZ7M6tDK57Uqx69YPKWMb7DAb6bdipkY96YjqD6o8alGyblSxziOZKo1WUskGBUlJNhxmB6PJoUZH467b8rmF1EdLZpTSOxSog8dH1jthtJwq6R3slI2SfewISUEacy0p2ufmpkctd1dMkKEJWjrRznCtGbkZ4x(CE7BnkppTCD(8WmHqinhMNnSn7lYkHFlUGHYQfube)ioizs5GT7(c9Mr7DQGnNz3oB6xn6e9T)6wDI2(CLyAVjoe(cz3c5xdQtv3Cq8cYjVPS5mOM1Ow5S4efPL8G8bRXv1M(z48Q29ZcZFIkC7(TBQ6I1hCb7SLntQIeJaoatqDPj3ZWsMMS6dTuZS7ehh8cxpZB4iVArK6OwLTiVwZrK5P0P0mDWzpVRu1LKcShMnpmbGQ0mqYFXEr1XzJ8gns4bGmu4kGatIK3MC1V9nPawigTkkpnegQPEJfmutcmj0i1gjur(Ikuncd)PSlbmP5xDgYkmyAiFfjcDDIYzFKJVNFGo1Abb1GbCMqf2FLZH0yqBMjyKf1vlQ939j(9XI)oaFuw1R4TtRq(QRMmSRZpEczLZMjKmT061V)HzfrCGmyrSwXESb0uSp20E4dVzkYb7ljzV(eKKu2I2nrAhAo(Eg)0VuDddJSAWEqxTnL9RCPFilpqfj2nbH5pgPGL27LRCiqfN04KRtVc2k(mSQb51bSrQ6uc2MEdGgJtwwMhlCbE1NEzaDQ8HpjoxYxT76xYtqTtvYxV72Nyb2J5S9Jmp5NZommMsrgjYM4c(Ux3d44QWSf3cDEfOssSRyVpcHpR98kPwtSlVay6XMQ1Ko0wPObl0e10QspPOw)UPzQzXBe5RmWzGYtdshAqD0DbyGjBPXVqQgCXTksjTFN9IF4asyYTduE9jMMzplZmI77sZSN8mpq5cL65tDTAv(bAuSHBJf6qpXnIdnAQkAJ9DRwYl0HYpin(VbTXW6avBOkfKgiBHaYFVPGC45lP0KYKBJJ4puSaOPGuaOv5BuPenScqje93BkrhEGxknHyfGFJj3f63hcvkHmvUdSUjv2mZpU0bdOCPvHD5mgi)Kgj1O1boH6gcswLcNh2mIrDAuj1LgV9at4zyuSHfqj2TPqq47OxJd5GgrJjLFaJMJiAJTSuxljDtwfmnflCytiUyYUsfGWEZp6FMN1i3Yn5O1ZH43qBTbyR3(Hjew0TdGlEmyed6HeNygk0JFcbgxfwfjA(jP6GwbZVzwcHPUUlJLfny7YDhLG4BgV7LBl9QIXfN7ieiLHqomtTJZmr6p5WadEKojOaeTzoLd38s7mK8Cd(qn8VnC0W8QGHgWi(ZFoTNhfGEYmP3YSBt)XUzmfUz97VfrMSOFV4oqt7pCIdcI0(sY)zJPTdA3emJB9Ukbdkq(urWyzYFkOxEgnJwj7nD4KE5YKtLXoOHIMu6boW0eijkecTe1f87PmMdfbfH5xz(i58My6YBoH4HLryHO7Y9XDlRsWVvRY0UZvETbiu(U72Ouyn4JqsbR5zRUT(rf75bFTVd(kIz9ud30SPF9iBx2UZMorlDVyzMq4BDDM0ys9j2dN46Yx)6MiCPo2Z8FJtHzWYfDrwiL(mtARQJ5QkYyi)mrj70M1xw0QuHB3XfRjLSvWab5PE(xY2mqUkjidhi66Pf6SbiUfYVmjgU6qFq7Iq9kdTveTvg681PfTzwuxzH15GjOPTWqqBKKnEPQdsNOnSNtgk9Lbs7tWIgHiPhz4z1PjLZoVBIz73bRtNFvcOhE9v6xyXQu6Qs)uc9M8hjS(rPve0KkZdw0peiBvoqnlSfsbNrxaYxpQhgECvm7gAny3ix9)xfYvez9UtUQEEigix9DKC1xHCflEZYF0k5QjrOkZZ(sUAp53zKC1FhixBYqsK3)rw7oKV)PtN0DQCzI5uet3R6PSaTk1L6uquf0TVXwAxdIv1FpeVFBY9JDjTTGIg7yJjZhjwE9yvxsdLRrMWnyr7EmuNsHtZck3kFjgANOMBbQQapRVv6Mg6oWmFrWcGosjHf3E9Q8nmsO5RnXltJY56i3BPhReVRQx7N6lw7Pt6PD7z1EmfZ8qY(i4CuwE7lMazrIQ2vS2TvIiCcKdRW9fICqn0DKR(RkYX)o8CeOH7ZO0v)84XMql63cDC8I6oMHHe7fxUdOKLYptDozK3OrO6Izo(O)ZDCCuczpv7QrBch5YtHgzlsliu6RtZj)g(s3Fe(ytoU63QBPx6WP764PT6L7zpLr3DEfwh7U19TcZoz8KzJqYVansjhl84EefhxlX5dJe(EZv5FM3h2nMasyB0tnSPWn9YbPPFpUDIo7HXtyaEenVRs3ZOdPXCFyKrKHI6uQTPthXZkopL7tQVkglGMODmQGxptFKFAl1cRrvzrVSpsBnDczth7pyMXTcP3iIu7yQ1juzJ7AzREeIlDRP7DbXLngdGUEpssw2sHi2ExVthn89Ih4cXZZL6WhBJoSYYZ0Tp)W4lHC298h6Qyp8k)d7vwv5L4BV)8V9x)jwoA76y2DAoVlbaNUOKL7jViI5TlRf5LRlQ(EsBwbUGL8FdBYdNnYSQY55vPp0V9x(d3FE(8OeG4nLLg0veTHqUXQJebSn1j8D16S2zlktukc2ozdg9GNcprbCvzAep1JA)YuZ0ZKZhvcwtr4EnqiA9bg5dIPy2O8jsuXTFV9HTAjvW11YXuOqr9zVKHEDixZDPQ3j54r9S9IF0dGNHv(q0RYStRqmOg1R29r2EdZNPpYQRkgb1wbzIEv)yWyqrlPG4DxLbwwRYM2c1gHU3nz4e94ojULu))pGyjlBD4dEjR6fOb(49gzBkZ8n2caEOXcpeyX4RjUb4qINr777w)TU60Z23iVTcVL9JDqCzIYYArQz7WGsHQj1S5gcZbw7zgQUhMUHx63m7Y4ffMiy)HMmuvzXoTMAclH5e3slIIqKapewewaQ(AorUp18Fq6ndRmXczDadzLkTqNDk1dYWINeOyoHOKAjjeQ(mgXgo9Ou4Yt320dW1V2TY3JKfUEaUkRuudAGFRjYd)DtGG6t(Vz7UjTtu)VLFi96z0ntiXdtQPGscMzbr17m3DhBb1wJDYhwKclSz438TgY1jsEQxDCegE8OUTBzqI0eQ0BGuiHaRhrsYk1eJhlVX0KSP4ZEohoAs8g2SgsEo35e7IBidl8ZpFycenWeqKm1SbvN)h078hu5gwYxKySrUixGsjZZwcYGy)qZ8i7PcemBcFPVSWvKsfZUQWVCCZdMh)BnH(f)R7t414NmmQryIz(juZtKdyfrIZWKOFLuuUh(QsjkMMtIcgStKdFQPxm8PCxQXxgS1vtFE7eS0q(FU(FkXhJfbXYDmhqltEE2uFsqRLd75b0MrazeHPtGKtNguKiwAIjDYNhNqSPxZ9a53(cA8DWzRmh5GgZ6XVpn2PNi02R6QSTOB5EqBEiRsT4qGsh(f2sY2oKJbif5TvHcwMkZo7bt)ti01x349wVcuLjqWvUh4vl7TOM)5E1(5bHu3hqZSLcDcQ0gwY6Taz9rStcNEcWLC0elSdakH5Xk0pIBQhH9gy3Cp70dm3hoR545XmAXr3WBh8mTswiMq69zKvp766rv1Id3uuIDVKSMW3XhQhuzaaHSJgdi1ocVWTicUlCpegJsLf3itmw2oDzItn2wQ(IG2L8EIQydGb)wSiRWGWycJEeIShX2PHKsl12G54bHHrPvI7Q1AUed3EVbtuvpAHEO0OgI66EjkNk4ROggtneOPtubxhLUVTv52TMAsDwzuDD9(hIwFYhRqkDdZs9YHUW9u5GvFRvKxn132ndX5IqTYsbVqLUS79r5A7RqUV0lSP14KkkKYSv1La4Zg3w3mrkhwhJPeqfrsuk5jk(L6xmAgAPl2HcKm6nvzMTxmy(cRyxU3RkDu1bVyxkbJiMJ7s0cud0G866SPDf2nmQXEKYBpP1IGZWIoARKc6spM(6t1M(h(6B24h1LNR8LmYWDP6zvj4FpI5OHWUEiRBHMvp4EvfC8bO4aA9wk2z6Qtuc4ZJTBUYSPEcP0wSzyGfluyvSjTIXNZs7jeO)0xm(eDzxtULzM1h3cYhnuH6eREmWeBM9iWF2P0Ct7zLP7eF9fHLN)XJ5sOFfSqv1yyhVmrlKFBr(0hWKPBzHj8Kd6374wYd4z2Mtd8Rt8sgQXEJBIBIYkQYweAXNJjJvoF4qFlAND6GDZIZwjEti6NPNu94bhzEyhOyu2ddhtdjhBwm5GZKUAiutT7Hs5PTIk6O5MpxvurkWtnxeA(Whvmvwz41VieM0lB6gLUQ5(3QhVt72fiWsJ)(eoCM54parVOy8FqbGxRQI7szz7awvfFOMKQqVl9qNXwC6M34YcEQNPepHq8(Twu8hSN1pV9L6GE3)1Q6Ona6GxvhjTkMw5TbJkrogtflLAdlMApALQl)eaAoTnPVRwJAKo9vntJF2wjT6NmSAQBJo7KVS3xsNH7mtZRM8h141RldYKD(kJMYjGr3Xw)UpvBPnUt4RE1CtT0VPfezLZZZGrMKBBe3Hv1PApwRkJWtvb6JWWkv8Eptk2SGNjV3VAw2SJg4zWcVtTfZeE2AZ(l2G(6OmyGTadiDBe7cgH(rEF)5kd1Ew6dF8k1HNBZmFtEnfNZAnqPUnlQLjLVdZDbxpwo2zxmO9rjpaGCtN7d6b(9DspDWGPQjRtyAtxoMDvUvufOUA0UbAgISTTyfAlsGMWCaOECJWg3ISnrIcsqXZBifHkMPauLUshhK2PMOSZBtIUDchwr3SF1Rj9RgDY4rMrf9DfxqBAptqrTXvCGf0JNYVShh5Ju1pXC3BpwKJfwKh3Scz3QcwgulQkriD0KrN4pQXnpLYl6GJWo09tg)HxC4RhmUY3KAaEZCJTX(AFI5vDVo6sY9LNSDGMjroUckI60TYe2MoD0aKQzRVlr9JwCI2PGIgokhuCCuFptNH(Hc)zlUEgUPxoylbxwjP1eVCWcwTYKyPrFenMScDFUTaS0cEFn7pOQhWysNf3PmzdfxbS5dnb32g0RjeQvIV0F7nwFsrUC0u8r(zBLQUKuG9hPQlSW9C64V8QUWQ4mBxet0Na94rpXvbyNRQVTPXtx3Tmbx)RDj81SotOtizBXPECp53tsQxsLXxlesD1SxLLXbRC9kpFhGY1lcsFQ8DurCcLVUQFPwZELxtVwZEFTM9sYr)An71zkO7SxDgDQ2B8An71HInMjQ0xRzVwqqVwZE3LA2Rjm5l9A2RrQGxRzV)tsn710U8ttn71ee84wZEnnZpz1SxJaXJCn710C)An7vsv7lGA27d0SOhhZ6FT69AJ05F(REVMOpU4XU69AAYFoREVYW1l1Q3RjS3twnpLdNR)xQQ37EvkqFTa)2oZ7v9a9fbXUtBwFzro)Ab(9HuGFFLR(rHR(1Q87Uw2uvdOlbH5RL6xsrjoxQFDGM91s9Rl0SQhJInA2xR3VgOznxVFLPzlEwQ3V7BGK21iwv93dsr1IkTlGsRoDSXi09KJ0)6rdOlYYVHod20tQhFPxJL1hK(gEIdulb8Csj9dWbLaXSGysUvYS8hc5t7uG(a2J1kQZlZFbvuNTbmUxuN1gjhkrog6T0BDM3v17z2ZDrDwhKvFEKOGTdhbQ8WUBf1zTU)uxuN1aGhErDwBiXsEQ7akzPC6oAz5tDrDgdISMeHq2ISSgpaf0zTXv)s7R8a7WgpNZdcA0zJhzcTr8cc6YtIa3B2I5H5fnlyRvey33IuwIQJE1aP)gbz69Mx4o)oBCFwQXYoWitcBp2fMABseE5G02Zct9(ZxBOVfpHfLARMdqTf94xuQ1an1xjOfqt0omvWRNPp(mvuQrKWGwGBwMF4lk1ePoHk73OFFFnUUwLRb51CSIBUzCt)alrdUinPmNLgmUjm7M4IlJtyX9mhAo7SjNpq6g4lb89m9mLvvGiwWcHLdzp7P0Xwme764t3lsVzuEBL6VGWPJvNsvyDhQmqDWX1ep6970VrA747bY2JzF2ufRRRjg3nL8gSZW0Z)Yu36J)4xTSAgp6eD3YqBA7RN8yvVMTURW7kMF9d6EKY0reT9L7Zoxi8xZKPxsMuAJYWGpaDBvDj5usPLnMntapVZQGXOHwHEwlBb1dVPn(cH)vEAM1CmfeLCvrEkvi17CbKGXL1GU01iA9n30yJe8feZeQKJskoGM32crV3hS1eP8)Rcb)rEdNyZvHkSl23KfXGhaKzvxMaAYeJ3CerqhRDaBN1lsRAoCFMxpD6C1DqfY(9JDYIQlu1cAGg2uVKU8(SJZzZTTrnPCnwkaVDtlvP7zNNwDZGhFhDsZAab4qHfOMuBCkEgk)pMI64(v39pmRjlPtzcT2OSgthzXcNDKQ4LaiJKJmQ3koqlMx80uArjTklNmEK1sdN(j0AaNme9jU50ku80kw2DWdwv96AjkGWllCRmTqoPwFdTD3GLY3FD6YWVwW2oh7ZMoHw3HMdd6iWlUnppCDWQW)ruLUtxOX5mMwnmUn1Mitu0yCJbha1CAs3Vlxs6FuLzBEpn6lTzIu6(t44vJzPM(4z8mLjb)Nz7zzSz0suQr(jcN5ZakruLgQ1JUGzTbNeYxmzoyxEt14MIv(K2HbLerlYYiI1v4mC40iXDoHCPAjZ9oDcZ089Wp46SW6(5obo6qBTGcWNYayh31qhaw2HDa6XtlIuAZBsQj)5J8P2S31sM6J6MTQzioSD(E0c)jZUDd2m3ZmE89NqIhBT7WQz3p24Z(OLEodEm28S7XnH0g5FfjOEijfTcLw0fBJIcJ9Krb(LfgRjIvyzqzS1XGD2A(hbsvdzoSJgV7Ba2sPOpDuupXlmN30XKQ7WLSO7joiNuCBDIrmR4AiDPoWyrSdjmgMklj7CAzvLxzNhagy6UHYkLjEt0gozgNZwQ9)ZExnl3g5gHFw2drYuQIwskBVB2k7Md52wPYfNZwCSiLnxBQr1qYyVvPIp7byiN)a6F(AmZi7SRUzZP1x3aOr3naA046OA7x0XrSmpVm7KegncTd15VvRbvRV819qjU4A0ds6yHUmHds46EDqc0BOqNdQLCS2WRUI4jgACcq5jNr2)5LdMvnhSG9ov2xTfSgwQrzYyPMuLKBn1xsNVP1JtYD3uLfYGo6w79VWRmtK(Zljs3pTj6spCAtQccH5mGOZJwQ8TTUk01fOWIjtWDdo0qd05Eg(TWJukTAFz3lQGuetYNAJMHquNQcve4awCLPn29w))OSa57DnRzzUzZLe65QiPt6(mJO(ZtAtRv2VQ0kykwH0A9)8paM9eAcLKQyAcmZlxNMFkVkA9tSQOoyno0hnOuMdOjeepGyDOt(My0RbLWnrwR3Q2NMubF(I6MdBUCi2oTMUppA5vCP3PgeXw6AsaOggIZnse7Tu2wAfBEzGmVM45tRhjPxWBEiVZMWvdj98sthPCy9OoOFK5rlj0to2ZAn3QiKdW(uh8JpwQgDxr2734KiNQtUt2(f6kcrk(S5cbjoIOsfejFPCD2T3CHxqJ7X27v4VfktolSQrkUGO62SIdGibBGC(h3r2DvVclq8FWpmnOZ(uEYmFchm7KZfYZJO(E4C7sO)wQYSZOrezD57iTcPTZ9FR3SOJuWhTgvw)M)GppQVSDnL(KQIYkCOr5oQNaHQCp3hG43rUryE12)(lNsJz7uxNzZi6TSgSfLmZwodicdQd7qmW4UJFbpcHDKwR5dYyiTrgeLEHbNq3um9ip3eWx8QnI2KTO1Y9yZtDgJWeg1aVKaSV1KErKZEeYJLiWWCFuz7oEv964hnIZ0e4ZQOMTNkyjDIT2ix(9r)M)KmJcZFgt5N9RF7oAlmPLt1QelZ7xWJkphctMaK0YQGiNwnstH59FQm32)hXmLwpFyJ8qC8YA)sgLeWnbVuKoJAXXI7(rl3xh7S9HTvfD60RMjN6ArlkG0yrywftBvi6EIg7EfCjz9XIfzg4XB8LS)wXICKp3Zu2Hi(EzcNz01UGk)qhB3mzX(zKHhPT9v8Jj9sKv7Z7kLeZDQeW6gVUMkNwrGYZP)lBcJgz0M3qpI9pTY3bV3dPSnLT3W6rQ)h7EdRgq6MySnoNJelM8iGCYa1U4wc9jDB)5o16whw5olY73PR(HVwaADERwisrMVjNM()h9oTcCNQXv6Q1Chy7vssjXDC(eMpRvBmx8XtYEYL8OXLurKLUhKf9EQu(q7e22XjYfiz5ph8qwlMqksXekFwfCNXa2s4IBa1VY(8RcJ)Y9XEKhIM1yKvQRxnZr3UVz3sIYl7Kc3wiKzYmWryjRC3rqIEE8nbG0C1PF8D7lU3h7)NlFMWzS2Ohc6PnAs)CkJJSN3NjnB7qf)c7iNSPVyYextqCXTIYoeZkvdpd44baMdnSDhBqdvjnTLN2fgwtl7NDuIoUDa5XVL4v(yMYOKosh7n)4t0Ubig5uvEgq6P(mE3sKAIsVKmewpBFbEknSOTMlllIgZif)w1rFu0D9c068Jzns1YCSUiXbrRTENC3ko1kow11k)5LNQ1A7k2V6TVXxxaD)vV9FpF68xn9hNp7TV5ZzLwd3(238F(WQdlwV5H8IDhwCxEXHfNFxt5S78dlk8vjy)C6fBZ34OnB)U8n(Kn9WcN2VZl(2Ro8R)l3OWHfV6NoS4FMFVJFLF(8DTloSXVxvoW3L3ISD809IzFzIkBiQ4MrSGMMrfElaFsxxc3gsSk1gaha221cwcid(mOScaQFV48KGdkMYhpDqSHOeftOFNSYxQWBbyo9dssSk1gahawr9KOpdkRaGYP89AjlFrVwz0g(OidIjPAyAKH3cWgmnzxQnaoaSaMO4u96fOwv9yRU10w(yOeNv0vBBAMXslo70NuXsgets1G7idVfGnyY1UuBaCaybm9ADsfeOwNuX(mhqBsVptQeE2fOzg2KQF4PjgDE2KIg0OcUkSdCeK8Srv61DhoSGxd7pk6KPZt1aJ7LqA6i1CWN2a6OcoaS6Dj00aj1PnqoQGRcBQo7aL6uHxf4uJ8fuUtf(AGNn9PZnflVstNzCrhbx0Ei4OJfgnuBd6wXgy0BWvCt7iFpvPvI4iTBRayBQmnxySX3eYg0qtqUnGocUal5KlK7(Hkxm3cOcRjkskg3s1BYyJVjKnyjib52a6i4cSonZAIqOYQjkgB3WVMmw(LQvRXgFeKX7PmSLqcJm6TeKzTdn(iiJ3t9NDDQ2VVPmExA9zu5fV))p7AQI9)rFgvEX7)hg9)Xrls17iquGdl6i4I33pm6(JJgKAVdqCpdl6n4(30X1080q5EOXhbzGyRyJyRxOYgXgpQRjEdAPnSqrMbU0)98tgF)vrI4rVLMr8eBGJGwgSyvwUhez)yW3XkoELM10XfDDCtD(mQCNk(ii3mZ(4tDSOnJAsqLBq05SDmhyVhnfj7yJpcYa7ddNf6(HAc9YqwOzjZax6)bvjJpQfAfInWrql0gIDtPheXcn8oMZYR0I5ACrxh3uNpJk3PIpcYQ2qjjbvUbrp22rz2jFx(N(u(N91VOf(0WE7HfFEvH73DK7yZ67DG5j7yUrFyXNCgjoS4D73vr395LP28(77q9YLEIxMTl7DzBx9th(1dl(RUF((F3xGtiZk6ZnLm0clOWz6AN3eA9y1n86Hs0IUaMNw(n3a)KP9Rk)MhWV8hwDC(02JArNBSgkb8I89l)8PRzYDHp8Vx6qk4o7E1Q79CBz0vXpQQUwrPW9Uv7(0PE5mA(ZJkMLorV5bfS6kLqD71RAq1yX8q03UYHoC1wxphByntTREsLgf2G)3)8G)FOg8VIX3WdfRUnFZ7Y2z0fH4sAQehcJ0IBtMiOvM)Uz5duw)jibeCN6GRpPi))UUmFBxL56zwVFZnp4IIEt2h52Nc1)MU2KfJWGTdtEpDLbvSdJKeqWrA8eXvR(30H9xlnEbKsJGz7PiB(T93)XnzR2URi3xp5EFMdf)AdOzMa14S89RYkEV7hwUQWn88qwXQB(4QFNsHxKyCgILDc45jJCRRy9gN28YvFHPb1(74W6IU5oN9PB2L)L1ugDiibhCNhTT72K5x((1tNoLg(yIWzG(9bGLmCM4cb8U1llR1JUzH)2QB3LZmkZqzhw9sXDerFYjy(glYg4jNAuJZs0jNkeJZqSjN4PoKCRJFYz83XHvEYjjj4GRn5KHiCgOp5KLmCMan5uIYtSImcpxO(z7)KX47MRScYtXdF82KxgZ)2Q4GV4fZ(lVy(vV(ISD(cAZnFW3Xp5I6xULwv8MQiNldSn8s5p5IRVC28jtUKmS3YILZfV(4h35xlXTznlmz)dxmRrzquw)(VnKvmR4QHq174u5zFzSI3wS2lXeCk4ZqGIfw4Ofk5C52u0N7aQyYhd7BsJAiw2R1qmSPV7OcoaSw671OgQL0Rf8oSjS6OcEnSIx6VpKFSEJEZTzflzw0senDK6VjU(IP0bnQGRc7CGEFAAGK6r4e0g2B)(OcoxKvzfpxTzgq4TaSHrp7sTbWbGfiZd4YNHEb6ZvBglWBbydgUTl1gahawGet0QYheOjvDc0xRn2gHby93KHPrgElaBW0KDP2a4aWcyIIt1RxGAv17jn2M1JrIp9C1MjHjvPzY1UuBaCaybm9ADsfeOwNu9KUCn8jvY02HDpxTzyvpFUAZW21iEDL6Fs8oS30NrfCay17sOPbsQtBGCubxf2uD2bk16W))yVRLEBJKJW)w0LjIwqAjhkg7fqshYHaKCWxuqoYruKuweMMKGZqVzbm0V90pM(DvvxdFyRGqGfy3vZWQRU66XxvD19KjwkdXrNq(YKV3xYBj85BBMCAKNVTzY5g78TndtBnguUdAO7bF3bQZHUms5edY9Hr1Z32m7f97eL7GNG9GV7a15qxg5P1znrwu98TnZEsFouMVKQdLeIZDcqNSQo10NdL5lP()DDQdOFqoRPEe0upGEc5DK()PrlkB0rgOapUuNdD5l7po6(NgnOSshg4EoUu3r3J9T7qmFFSPphkZaBfkITdIQNVTzYFxgK5L7WiY0Zqx8kF(2MjNV6JT9mx(EFPphk7SSpFBZC40NdLzuhgmp0hgv3dPmlp0OVwhgLdFJQoFBZWWdn7kMFKVpyoTuppD3x7zU89(sFouoRp0Z32mYZrrZK)sN6i6YOZhxYbot)znn4tWTCX7h)G31zH9UmPxXfkkTi6BVQ78)CGJ0VXyKUbTHY7MuBa2Pk8uDX58Ez8orxCo)ShVYmN2owJxhKNVBgVF2YZJ(492)8FOSCLJYGYqFQs7ZXpQ(Vg)Vg)O33KyX)7Nhi)BThM0X)TXpkpEHZfosg)4LcQR(hBKP4lLM3E6H7LXpE7PF8dbBRpJQt)ZPlvNONxNiGknZCqvF7PISuAWW3EQN6ffJ6fwkgEv6yPNCmb)AFVBJHmQh(Y8Lvppz72jTEovpj82(rm8Irxts34kCVTUzXunkpHhXVPIaeYapVUUwrWxw8LxBQStN7E7PH9dyJKV84jZZTZRBwkMkvVUBLynawYb9nMxY9TU5F7PpigznVTz78Vxj)7dUX)RNTKP08LBOxeEfhf9uKfaX70Sqgsqk8gn(rTs34hdonYJBg)5skDm6zwHrjeBYemrljE2W0NPwxIp70UvmWROj1sRvy3lNAnPsOyATDYIzvZ)U67K)Sz13ibxieN32Atb8g(l6FkwL1FySRt9W04NnVwgzVQr(P3VP2smiM6oP9zPwL(ezMCzglf1d3oFLkvOAHdYVAKLHmeQDuEJclJGzx45OdXQOxhmmgIAyaiNgzvjq0Bz4q0Xw9DS1M1Q)TGFUnIFwVz8J1ZBCVQbJP8)AP8lIVeC4MnZNb0)SAgY(ci5nh9wHPXh)qGCtJELKZnGINRKFq)ftLnZNUyYYQ2yRYz8OOzSDPkz6KgA0395cHwI0(ksTxRoBFOzvYUmmkw3hXNJ(vr8zPTbCQUoKrlG6R5K3di3tLg3atGDGx0NZmV3fbVQFIHwVgEpNhVbu5syElnZFuEBqkV1dY50dTE8Y4atoeGpGAbvpGGwRoxAedQWRIwNgqrvOw)xruRbmpI1QpwQHxyv)1Uqn6(eGoS)2mYLSitqSfsM98nfkpI2cPgc4o2cFp4sbIyDLF2IACLmBpaRRi6WB2sS1ug71tKvjx7UuljHz3hrm7qI95B8DHxqSSXsz54e3bBUL1OPnBh35moIOBR0o1RBPvkJj4eY6pHiRdrqe5FJJugIFanAJGQCGcwG9zEFeQyMTSJSN8IE5WgJ50SmfjZfRo)oYQt499bwQGP5r5N0fs8hhkxEznHK61GrC8d4urJMrI5UaBnIQjGJpFrGgw4D6sQuKGXeivKKiS2e7XreR)LhS4gqIAji3CQzVKnye9A2GrHipym75etIH5haWawKdXdrBg2DrbeuRsQggxApB(EaxAF(QH2nsqDDppS6w119SIpSpA26DpllZ3kzK(Sm7alZco2sMnUgrgMDR)DX4PLlTmz4yk5U4e1nChYLQ5PLpL5URzuSHxYYX5YBzz71M5pnU0nIsgdlLBWJ)ruecc28YiVH(voY5Pd6wzx9whHuoqY6aCEL8Q)YscNh7XgjXbKPWVO8W57vas)uQrJLTD0f96pl7T4HvYIyzMGDFdMNxBFrswwgWZvXXStbROgLRKtfmG)WPlMwGdMWE0ga47tuR7GLRx)1Ab2VvvFDXYLaLGiXFawATiGnCMBYTi737tc1YntU3uCXy4oKfsabHYHYdo2aFlx6OOkRVtFon1PO5heXESLsz9nIn8dah(IquR03NSMFekYzdQ4(iOMJGUN3hy5O9uHwJg35ar)7kRK(MwVywTzMJU6Wj0N3Us1L1pagBaoJfVUXjOxiyE(RUg3GiE0KobXYV2mroe3E4(8iTEZ6oGosmhpk(TBarYMmSnOnEVgpJtyBNCfaLLT1fXgwjTnR51s1BLR2WebOKsjVd6EZb9YewvPdowEWr2Fr7mhF7(y)2W(I1UIlYG9uKk9Y1nE2qYwxaRwogxzNn0yAObgK(Gm0G2xLoBOb3F6ygALWgAy1do5D4AOLl8v6GFum0iIJLcqINHgqoOXgALkdn8grJi18cyq63d0BlxLQInD9UvnWAFM(W5uSb9(109q7Ba))sk1tBQlfL3T6zzxvxj7CNA)9B2R(j2(d2N5rNBKME3lBYhppNcfuzN5Ow1XBnm6vDRYhwxJb2ao2VeE1BwO2O8gv)q611uqTez(UGXYn2V4GGU8d8Mc)v5Z)h436kFrOClSYwVTA3gOwQlppg0GGLb0E6SQzcdGv0TKuR2HR3SK7)Jz4MSA1IxxO)kJa1jrbbjvukTJ4KIhzVRBT8kSQYpVCHqFv1X7PzydhgTi1O2ygr00Dx3YDXDXQ6BMIs2ns5aZmVnX4H6LOirhylaISTAwY7R9d1yhzgdhL8A2nODQoy9bqGw65HWFqc2bhcKppipibc)ncNXvAtZRu9PQNOm6Zud0E8YrIcPn4v97LtKpTz(32mVUbANkzlr988aURFEnZNrPEq)(zGlzkzaylyg5kHcX0TyYIYazUVNpOTmkX6p(SJ4uId1kcgcLKcCxEIOFyGPwQBLET7kAUrRA7U6xb31MWveZzNXA7dt704QuF1vJCYdAiO64vGGsQabG7DtKyY9zGs4EA7SPtQB8fwmNyKCqh8LLzK1ds63I3kju4ge9eC3CATHR9G0AdFP(ZY2Kvm49daT5ZU(bABBuEhP8IYgfp6t9JExZPSsBy)PGL0iNTjvFVdtN(VdMoPontkcFhMrVhwGI9DJheyVmOMSD6Kvcb26TBN3c0fp6aONpypAejj5ao1)0Nw0Nc9GXerFonJB777M)xLQrms2s6OiDAc5NNq6KQi3l4TjNbikqrMLtm(bqzY1z(jdlvy(0gXEsoLUB7bZqj5uHXC(eLbTQEwM4LN4SnhS9lVlQt9chj(DHNBQpcdA6EfQPcw1EtUuGG6IcbTu8uluS2ONO)95lV(XPIxqii8sulcTgwlZmDYYLv6)Nk5X(tF4)m0W74)rMUNTz0g0Mj26V8LLUW314G(n2FefouvmJChUmhLtonlwjP3xeZ2u00UgUIjAn37nP6fHNXkXQ4Iz(hEkk5QuxFAt1IxYlUIxewVr6VIovzNTPBHhjXwhxUD3kuMe63fYwrQy4WaHvYlSItjfKc0ydshmAqR2a9gqB20mj15FMTkH0fVk9Hr12JotvCaR7LGcQYfa)5GidJOFLhm1ievqrobXHW2opcrW4pzWtTJUwLXsU78DeZY6UGmvSRd9(xQhbaUnW7US69IeGNp)MjlfH6N(6czMmFVDJBHYMbhR8pnr3dkNI)cLC9Gb0MP4lPfgt7mtIva3HxOhnjnYuFgIQXJfJZ3SQ1Ytkr8ni7Ftle10huMtalfNb)mEOpEW1Mv0fi)UKdmEpWnOOdL6aRE2avheUjmnZzpTQcMmsbd(iSUmWSG6sii5qvtp29chE6vMcVnMO0Bpre(Rfrb2z)kCp(r9Hk4f5rvwQTtxCoyGcHZcOV34(sycq0GywrJu7kjmsex2MUrGriQEOtauxP6sXBRkdAnyHSvkCdWnKAeyrce)jt3hhbLzRNB2lYHW1oyi71WDQQ427WalhyDnIjTUK38SNsSLBG7HazJgpfrTBZUwtZ7xL3yTNnv7mmjo0D6KkCwDpVB7k5g8)hYGMbVadnwlyiKY0arcKeutQluMzENsmiH4fN46tbnXZmHiQ4mWXzj0KdDpOHr4tZizbANnuygB37J2gj62rGF4BqVPz9cMs)Jm2MYCB2co88lZjCCXls7vdltghBpcUr8CISyjiquDCzJCIoDIBWie0ysVpcBBfSvVCSY)GDBJrmthYEd39cQMVNDPA34GYadtbzksUgIc9Y3ctJN3VTJZEi2UeNTjUZWYY2K)2oY2TCo8HvXys63cfeBedDyFICHBnqb356lrW7fuJX4FBGR0(3mkYa2SBiaVNwpgSUgWLoGyBJENkpGB2jyzYxcVgTGDRuMMQrulw9qo(cP4de7MgTB)ICveWRLZs6GhIniJIOrjhFlHeByqiJ6PIr(BsmMpVDN4VTO5pHaIwVE3Y6Pt2cw57OTlLylXYcoNu9c)2Rk3UmDWYt8jBhG6E0aW67FmD33l7u1MhgbrGc)ifqPsCKPiRBelA09pqYgUFf4gv(bLgLYZ6Vb5nHjemntM2HkQHvrDAhQXY87Fl9UKe82BGOuYbU8WZSUipU5moRmHMUk0EyFQtmAhTc6Q3hOwQZIaapG(sORtJLPIFdKGcUiU4iq6I7e9m4s7o1lE(h7B7ONUjGVSRY4aLNOFH7yBybXPSnfrOxlm8Kp(d6ww4AqBocpXdXbRqVyx0Pe5ZRqhPipG)2bF6K2CR7cG)KhcGhcuZGHzABZKlpCCCGPgq)VIig2CEyMoofw0qVxY8cL65NJQc7XyBb3WBZfqfaEV7nn7(fPgrZ)pYl95yXtAK9Hk8CMNJ2OoFEiouR0cvsOaLvctxbRhCx4qQXSU6LTAMFYsn6PB6p4n)9GaEvgWoBq0cSWVN6UQP51TR)J6uusQ)ELgHMscLPVzHo5nfjvh)9J0dsebNm1WmNmH9Xqth7uvUap8WjnxzZ4h3iKGR)2ZtAgVF9r22GJfQdayXBXhzutXrQMTP2QSS1)mVsF8UJ60R)DlRiOL6BUG8u0PU6mAPP4Vpr(9V4LflBuUxeVI8lKXJgk73Fyj1ZsbOz)LgXhg)I3IpxFKsJsosJeUV0J7)VS3vwVTrYr4Fl6fcYySowuwEtaKuqc2xcqs2G4nVkkUIKweIMuyMHwXVWF7PpMPpQUUMru2At0l7A7P5m9rDxFv1L4tRhZEYoGiikDMrr1VrWglrpxcBOeTwhK3zOdjH)AsAhvyda0WxWgcrFqlFq4ngSm61)YM53EV)MAXrVgjtT3Ab3zOuc)BrPqDe3)1qSuAPQ)hgZ)QRNB5Y)OZms7nwW2L)GvNUHm3M0Sd3yOXmhCvPVydr1MLF2W93w3PhU5x(5F6NTCj)h)e5XDv3BEf2co1Hl413ANnBxS2o(A7D4IzZA(c7qmFaBnXU6RoMlZ566VSEXERSW4AZn7xTVzF1sZgZUvOmDwbEws2(3eTZ5yejzN2ds2P6jz56guiVtks2PsKStLjzP6FTLdcNKfrOs3PdubT8PJ5PZ(1DB3xBJI5JZRECDZDR3ALMvBSb)mJxm3MbsxG7n2pku3O9JwTK8Z29QQ(0mBpYCXYvZ3VXmwxRC6htTvdylxU5A)H0rcDBiBO25r1RLb7RLbBx820LGNRrZHtpkDSCFrFTmyj8V)1YGD7)VugSdQCZqa1GG8liT7i063Ky2tlutQGOEru7FWIZKwEL4Y5DVawoifN5VXREwOef(QNT3ClLfNPy1SE139YQuOcv7vvi(D5qTOSkL0t0JfeF8thjnGFRvwLNETMO16TP3v9dSxZFiMErA1oz(5ZmPhTVLfJPkX1ZfPaAALL8q0ySQCJowopRE478bWQKQecoK1RJLW(OZJw29LI88Igr4Xsveez4Ndu5en(PeFPuuKcm1t6WqKK0(9fHeGegjoUgrRUejce4V6mCtIKSiYQI4S3L6jNQ76rQgaOYTYaNjdLXK(T1X4sMGBFpfjmIP(i911byd(1ucvFQN8CKCWNs7UkuxNG3Qeu(mNYsKTq5AOGaVe5ISY)GdMKu583EE2(Bq4m8qp83jYDlTDFpFBByUkM7NyxcVeCk)jm70GQ9Zo(ligGV4tuOlzZtPERNsZEMhWaSIEqO7OGWKkqFZUBrkrqA)ePSjP56zIIa8I(XTiBURA9gNB8wd)9yMEX8pdXcqjkq5KVcXQbRApOeUedXiujwQXHrdHqypOmQxj7aPWPSyZrAg0ir06vOALcGbOtYraB0QVBUTZVA8z047yZ6TFLasiOXqmwxGcxie0NfaiFeT4oZjcUG9WN7(c(2CHazG(N20b9aDaLk5QcI)mhy)W74cF(rZTEqHe2Ra2Gj(wRGwKWckxCzfWapQ0chmmKAz4NMHdWCDl(Zh0kFK)OolUj5GYHj8oYQeYiwS)d2DilKz(Kn)Z1VTzxtlUzsJyaT(dGXPHmLjabEg1m9QhkKYACoH8RWXdi8AToXqIf7aR2Bkji(DrQilXyTJS0(6nFY75izfItu(0JfQ4DogCcPdN4MHo4ot9l9D2bbnYs(sblX(t8SeFdK)2)QbEAM2XmoUC1JmfFcNLgVyX7hZbpPj)dhTKmLwZ)RSdH7QLVaEIwFrhc3oSF0fc3WVzDD1(hAGKJG9tz4q0EYH3Cqcy7(37(dtTXa18VzmCD(T3p7ol6DCBl(Xfdmvstzl1ibeXaTMr7TG3WCFQpg4tC)fVuAq9BerGWhIdQOQNBlJbRjW5nwpN282CAyNwpyr3u9sl2WYaXtR0xSqAQytTspEq9gyf)boevA5dcwe00d8uM)2MI82or9freyR7J(BocltYs7jGdtCbyOE4M)zCoyptm)3Loe155kAh)FVfJAF8RBV9oZJrGQvCcyr01TyHxv(eyCz0NWcgktf9VTdAIZQNB2emAQdDyqRMPeBNWgzrajt76i0vJwUBQyV4KvbpU0Mo79pCROVKVXz09vmXQd2Ak)L12t4ZmSRnR98on5KebqAArY5ElSGTtS6CWE2TEYo)tVDbXIO8Z4X(XFJ3)gdMZHtC39vBuIg5rHGiezXh89LwBeegdLW0Np)t5wrtdHvDqOZClO4tPZ6Mul2Brl)UO8gZ29HaAKjjWsUrjXqNjpDwQquYBEN0bLFjHxUX7o3Xgu(iW)wtG6qi32rpVz)SmxUqtGkBi(SGZ5FYDfHwwPd(Zl3rO78DFT)40ba8eWKN8dCyiF(2K3LpEPHHKE6ND1KILEb5J9vZ3uVeSC(31TuBlwAmD9ZgzEhUzTr73JUzHTyERTcywU2Ebo5XBU5pz(dU()QvkzDt9BtNOUNSalfd56Jx(W8kh4W9Z3n(A9YT3zVKP8LxSDsSCzCnr0DyTwxMy9nzHjN1H2MxXN2GtyQW5b0jhVUdtdDucxZIRHXDgLYz5)Lr(IwTdqeVMAaRWB60ZsuKiM8FMG9K5Rbk6ohZIE3w2CoGrw0KdxHvCIKfbwHJ55VmR7UgdY9xXzgkYp7mGhyLfDKRplOGAerGKl3LvLqDnbjUnvcpuT8lwCn82tttdc4ztzE2z5plSE4HPHizJFDhSRWlSOLcoELxLfGJmxUWCtmJPHFZAuhx1XE)Hi0PPqRvrs50avMxiCv0tdn8BtEEy5smcMILZ9WQLBD3lHEuPLGKifmKCCxtsyugtZOKiVMgAvhdofgyuZSxgRwBckAfY(tU30JZVh25()dYL4GTOu1xwyaKxsLzJcEDxM)qulgZgsr5DLAde4AQeZBWWzwXYP0kaL(8R6gxe)ufKxfcPzE(Ki5DMX9yNlJG2RhZnF4s38IiIdLmgpfzI5EqMDbDcEv6MBO38UyZnc)tWMBy3sVymD2FENDCSzeN4bChO(pit8Lf(ON3DBEJqOI48zhznc7bKQ(yrgcsiMEydowCFr0CgcEbKA)ulRW0JiVqjJaTGT8XrD39IYDjVAjzUkwTpbUlW7r3QL9kbpgLPNbUsT8DLCsio)hsrfUUpGBT61LQsWjTawPJvWYwTGBjMdW7TD3UuQ70WUm1ghsym62RZTGaiFtZUm28bLPT8M5(PSXsDT63Znvk2w1A2lgyIJfLGtU1WQ89CK430D6KhwqkNe5HEjH(Nme5PWFkkCvDUg5arsuWkQbb3PbstebFCa4C8qrp4jCwe7)Lp5TBKD0WluR32QpYOUo)7oZof0oNvS61Otsb7hIHbQEDcPXOheGOuvniifo4VhA3TisggtVuAQnCZJWJYI7T4K90WKf9B3GGI3q0Bt75hpVZYWKm)B2Gu4ZDZoIEGYZ78067ExJRa)Z3GaX2Wuo0Iv(MnlJFXgeC5gpPrAsmanemtZXaPHPrxkkPRFvau)C5GWRdIMFZiLEECeD8a1nbDtp1ws8e8u47KF46LkGrF2Ga06okAq7i6Bf)g8Z2Gar7UPivA5LNRP5VNAkBv4fJ4O4siSvtoRAqWDD3sb3DXYaCO0ShpdasuZB7cZTId2SB391gB)2o7(1B2GecIc5buU1sySrKDZMnWUwycHPwXvYLPxYdJHm9AMdOS8dBoeNg0jJPNBvIYotNPCyBzYG2LeLns95HyBzcMn7sWXBsU(gYkeHWQzGP74(HFH3V3brh7nchctPPf3PkKhkA041AQCPgTEpXkVSxipU0ORl3gE9hQDs)ieK1GuvgXam5xipfPD0I6yzAfLcWRawJGKuavW4JPcwcEE2FG2rtCwgP4EYXsDcKF6ZRTuHZ2S7273wB0UCF3WkjxThY4VeKaivmgYmXHnygMPYpoLxVa2oqE40ZUdLsJl51l4DKGLMghN3SRjH1PbPSGa8xtFL)sj)fQk5Ne)fwwu0YFnTx8xtX5VOc6BXy0YFjPSQ8JFu4V6fso1XFH4OjK)AQJ)AOf9gML4hTk569PM50op84j0MzGQyViIMO9YqCJhD4MSxGVUKkX6YXjdRhn8hK(Vu(2FwA8pPnImMQguKWa7elx0MtYt7IXyn2T3BXSZmxTlwd9ylqWtbuTeu(KfzFFDqw)WAxg49yk1dh3RHLzvlGBqQYQI9M8XOOpiH20QcZzYw7quFtpY4a8Sn(YrH5L4wBw7B5cBnUKaJxn9jk66MmUQKG02iv5XOTC7xTzFL7(Tjopb9zmHgyeaYBPFcMo3HDYf)I6Bmq880TpkNRwGPpDcde0msQ(jHs0zUXcP7WaVSxsxbxrkA0pHLtKfQygJ36AedsDMbEiyeKMMIgp(JpmqC(qlfIxqbSvXGRXoUuww0Lse7lq9Tjljbo1rSB76K4802PWzR4AMqc6(j2KGudbodI1WKbWuXiNGPza9cAbL6v3QIMAVL5btoYbQBCuM2Y8ax0ki4iSFLBTtCKj3n7rNjmxZHrosH(H0jAgi)3Y(AIp2SWS95MQSmaiBNUcdU4THh3QAXMq9f592yCZ6gWrkTfiycR7ZNj3Tk0uBPYclEf1WMJltV(X9nGwdQ4taBh10kyBjoMpZEB)pZWLTEXsmTp)6(QT2f6JwBzkz1lDLmozWAwjckjhG6ORWAACfMZKkL8ezvRwwbM6(aiTLi))5YcymEsVBeSvkLyyqkc)aCDGvcssYMfunX4nRyx9blof29lfTYiQZEEAPePM0L0MotDtBACm3b1cMALBt6jukfgPxPdbBwUn89NoGXWyFFhcZrwqOkopDCCnYiDDKMYlbA5cpQPA)s06B2f5LRh0nneM(ICIvub9OugTpllKgxgANBHq1w9jJeDFhBaxkgO(S)ZT2FC4M)vBfp)L0l2jZ7kelPET0BPirRSWrfwSI2T7tLT)JD)QcLGhNO2w(5yIV7F8DyQcyYxcH13j2Jb7D)HuoGSKV8GI7s10ZXv53Bmcx6kmrqcLADCo13I60MKi5kF0b8AheAPKqNl7BXKLoigcXIlFgKZ4Zkvqtp29IIES7BywEt6ECGCTZUEY3OVnbe65v6tnzOtglRvAsYOXN7iY3wKYdqkRK4xnL(xbSRzS8HrsOP4k08tqKp7)gfrIOBZq0FF3JNxfsExBAH669tHgeaIs)SK0jQ))cviTd08yl9QsO5Y)CZQ8(VBhPx1rZbbH6LbeMo8Q2mvYz5EofgnVDUzX7)lLDWK0oxcFyL7kUKt9P4Rz3N(Kz3O7hxxOGmqBvy1jUrPhjZXlxT(E6YS1RKxeWTM2eWHeaBcFDYT26V5A2yhU5J2b5BZoF0omF3hZEVUcU6zF)p0IJ3hn6Dw6OjxTSQY1ZHSTZhhQyd3bT23xUZHQZ7PyU0owzfnHnKTL01JxzldPQgEMG0UaArgrLz9e(sgrRVrJ2p7suEJ4nQ3hMikVy67eYxrqOwInJ4I1c6sHMGMMQeI(4KJ1drq5Pq2TvQVXdjf72fVhZRWgVliHy05zuxvYixqDu5QI(KRYi2pyARIq0IDvvqhFLbTtvEiJ(pNPB6C(HeWgIIaiHTcvKKcCSl4FArZynBmDUMGCrpKPgZ)mnXuuYpXRo0vCSOX5)4HyMrmKECxJw8PwHFp)eDB78(yCvGMQexhTw7w(aG9(43Xqz)Sr95SYnP)VT3vZYTXnm4NLCzhP4jT2ETtVyPEOpc9E8O44K6zIJ7ijpzAp4N9U)WLKGa4dyPKtIZ0tjJT0Asqq8Zh(wajo)XPaoI96KKvKFc9Qzjg3n0XC305mzAPEnivSHGPC9DxhBXssROZ1xrNFaRi43DDrFwt4M5pwxteyreOSzY(Bdb0e2vYD96gSJRmFmLylP6tlb8KYoh4yh73UwgePc9LWPAo2pZLMnM7xs1iF(M4xGrGwJl0gt)D0EpYua66SN0MVzw1QSm5Tz3ZmNM)N4QwwPOn)R5nBNC8cW(JU064BTOQA8xBH9sbZKIF0sRokFLtqNRGcYE4viwz44Wlx7IznpmuuE59DqyOJGYL65H38CwicLnUXgcmYYe6DcoUc0OMoaEHOhuUzfyVsTSlpMx6DpNq5AxEb8ZgQrjmkxcpj7JCzAEkx2XEttiIl)jossV7(FWc307YoSYXaZs4daKCAihjRehsC6WYiOYMsy9q1xL05jlvWoXiEh22CjjOuHBOjjDbhOadUhPNvoWvSPz(SM9DbvohaBimVR0JU8OpjXYS6m5r)Z31fLYWFiz0l0cdslid9GhF(CGMF5JpgdpxpgtLMDRUArREmuwWSbgtHtihlnKdjNw7UPBfEFVk873(y3p7U9LhBp)JTWw9GPWknfvVECTnngY)TrlrYk2XV5BK0B7hOCJJvPlbhC6rmLeV6X)MX2vz9(w9aHMruFEd3TXICOcHQ1AWSc5HhMjQ2hd80NApIQz)Jj(IUT1wcpZ0PpwRr1Q))5L3TG5LxRb(iV0KEsIiYT(4lorRbuj1CNkAQ5StZS1Sz7nB(sNO6HTDbX07wBF)Shzehf48graYgXyVuJFjf1Wyqffd(UX1DaaZK57oTN(E90fxFEOE20sSocX5WmRD)x)Al9PGRRBBCqw1)XZ4SbztYsDIVIIjbMMlGxNpAXdBCWtOH9aiY2GvTfwpdfm(mW6APEcbTslnP9ggm9OasfWCh4tv(qOj37IZ8QQL0avLzMFyQ4Tm3na59R1Gy6zcWolhF4Mn72xCYSB)JFO7FhOas3342EYAqcEW0WL3h0I8p9SPjJqoVKB)wFTsKgbGWUWLQb5bMPNqGYFKiJ5XoIT0tEOPm29ORz7fzvIBCZBjS0kqflOzvQZ6cqTrRR(dR5vhDbgHGuQggFQ2Niv7wXSN0F5SlH5uYTaVofBDJFOLeHc6fT1XFXN5k2ppZJw3B7dFPS)kBCfp(daxZ7t46xeA2hyRyH7IdBEXpjZUo9YcdgcfDknylCE1L4(I)5dgMi)srN3LHhKOR7zuN7gSOqs7s4I)7MvzQ1ti0rmpQXeOULM3IthkpGiPI1T241xpJqpUG9f7flUOsLy1l0KVjrz10KbwVLCt4sRJBXG7KmH(()z3UnF(6pT5FVn)YJLTZdjWZ1f1sLSo52znsuWimz9OWvdEvpIuJ0PDKmxJf(ExfKhG3HjXfUz(4udsx62PRLN(j3c4xA)Wz8xiT2KLu5Hy2TQwXZYaV4Dbsp1Fp7LgBPIhNA8sFzE076Yp)ndsxqC0PWHtIRRh2ighPfwsObtFPqBmn2BzVosPhx2N9eNwKi5LcxrPG6M8cbEgzRZO(4g2JPuUGgRMeXU4n)RfAEjj6kD0BgpFd1)4nVf36tVvXZJGSk1OxGZLyzOHZmGRxFK01K721dpy3P4FV92IItHrhCPdzV0ICvS8R(4GKXkj6fPaNtwkcrulQ4Hfc)awVgaJ(fDZzEJVcNjhDFfas8hQfOif8X0Y2H1jjMOzh0xfNSe0nRnYzwG9LKbPTUGsLRKi6D6WrC2NGA4OKBnwhNA1Us8ySPe2bCJAcdmWfzhA6wbTw)RDWp08uog2Pq4YY0syTVPxbrpG(juNE8bx1ItsJP7WeBXdxInQKmaY8YFphNop(aqhMREI3jQTHOLPnzcIv5ojct1hE4H7ltWJd4l4veaBxIleNKToy8E269M()Zavsgi7PlpiLPuBCoK)rlOY0OHBjMmH9jA2xWq7E4Odx7o9QilvDxzYSRozmb06TiaCR5q3Bk2yUkYdhRioNUv9gQBi3xwIpFnWCBQ5H5PovUs5A53ynbi0bwBpbIHEItP3R9wV)kKA1YlGS0lGSBltdHrto6k5W5wGyWtjpYh8Yvf5pWRdJFNIoBDEJzmfI5(TNIIaA1XJOMKDVaxnRGFL1X6whSyufkeIyR)hmOS9XTB(09D74ovRh2hOv0PoImMeSvzctZRV5XdfLhnDuNXx0oqHOE2C(cIrEHXtH3iV1FhlH)gOyxXRWJDxRvq6mP9rcLcsk8fbC5(vgNeAsjH4TOyZSV9PR2(sJsGaTv58fBoecvcELa(zrcjJp54BpqY5OcFDh5(yXSXqxzBMjpNwaHXSbKKyr5xS)QfcA)voGn1Mw5ZUk41czqU2yQbq7O)p4S0TbPIR4VAeTN7kzOsDnqREVkgg89CVP4bRSLUXRPGs1a0Tr7W1niDvH6FkG2qMDLytle6Xu3OiE5EWLZPCZivmxUz06QDCLQEL6fRi9nbrDnLnoB)ivU8WsraYbOSIguE(DrZMx(Cfi4ISjMG347o)laPwQCE10I1xyw3GC5A5DA(YN6yXSRMlMTUkrlN9dpUbNjX)lTHHJQYW824AFjccDhZnLV7dIlm8pqf6f8GqshOCIlgV4HY9ojo9WFWJ)GCrTFSJDWykfD4bsmQg6xwgzvzRTGQWADVaBhy4xrscyOqioKsUU0AbnQpylHLLXoR8Y6UlznHfHaNlx8lTUw9g3rEcw8DJxpEmFvtlndE8zFoQQKXmCwIpQbScgbPTWHaoZYi9Cgjy1dn1mfWWh44o7vavyOCU94Q2swSWvN1KeZogmfuNb91f0K5TL0YK8N2aiALdKrvhxItzhM24o730ap(tHICROuofCC3YRSOo55RDQA9TayRB5EPcXNYAq39poBrT6zXn1NvIjd7dJ4KlztRa10l8cVQZ3RDgmSoMJh6JfL(V2J7)Rh2(U)SZOZFm8tE3)9d]] )