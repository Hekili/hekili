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

spec:RegisterSetting("throw_glaive_charges_text", nil, {
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

spec:RegisterPack( "Havoc", 20250413, [[Hekili:S3ZAZnUXr(BzRuHlP0kUeGIRx7BPs5hNVyF(2KlYj3hUkceIeucNajyaaxzLsf)TF9m418O7zgqsPDTZwPQ4ved6PNE63tpnUY7QF(QlxeweD179h5pz05EJh6nA85EV5QllEyt0vxUjC(DH3a)J1HRG)))y4hsNZ(1hssdxWE780TzZHNCz8QTjHfXPR)2SWLfxD51BJtk(H1xDnYm49f(JHxDt08RE)KV4lU6YBJxSiQCSr5WeWg7zJo)mVXF1Uzxg(HODZ(lrW)j7L57M9FKegZ(LOpeTE3S4L7MDF0ltsG)tyEb87FDwXUzPWpxCBu7OZlGLs(UFC3pwd8rVba(3Ne9l7M9N2eTokt4PJpZ7C2u)W65aCJlUf(3XR(wXbmYZ4a8pZNb)(RIxNMnqFKavmlDzCcq7(D)UDZUTOyt(x96xFdmGTxpCE6QxN3qsNZiPS)E(RVoj96xdlS7dZyWkE9R)65SH8NZItZIlE4NIZlYF9IOvPRVD76IOSGBz7zdzV8UFKnt)1naLjD3m2UIicbi7)vy2C4V(YDZyRHDZod(3El98NeYwxH8jkF4MSia9UoS40PV(dHzXHxNe9kg)X0IS413fv4fa7dzPXlYF1hct2287d9ggNpmEfSW)qCE0IG8OWLawVDvaWNfTk8UOSomn(utJVltdqj(MeGLibiy7MbphOkLVFEj9520Kfn)2UzZtH)o9(15vd(hwhxed7omERW1WiFF08O88WShaYj8w3b)Es86OZ2c070Tf5Xlk5cxVimteWaIMeTkADbFRUdRFVG5WoogjEv4IG)X2OO15bRyZxr0JpknG)VTRVBvyuErwkmKOBcHXDZ6OcLHDtuy2nWpSaKncY3eMffCx0d5kJkdemxNUnp4201rpeC92)5)mktfszXRcMNUae2CFb6JTa9TTa9DBb670c03HfOF3xGz3eaCTlIwgUnPy6OxLUzAwuoWnG(U5X3eNeKUmyzc8Y4JjE1Q0sLfbHBZeLxHhUiopB7MIs5))3)y0DXjX)9DZMLfvaR)Oc4vksdclyQiNbCKap(6urwZOfdzVm82GwROqG99B2MToE9n7M9)KUD9IAHcysIbmCwmOyguEvexcFGVFE0AGcKMxIdTOggk8kMCtW8ft9Ev1dJxof0J(vlIUE7YLdVUCUdUNn1dZaj6415VcgtrycGSYpVx1pYvjgCDsiyHPhB()quWIuLb)U(GrPKKGYPn)I)W4bhec)IY)eyqcUon)4GJtrXrWs2wMQNBygYa5bylAdOMBwoWIaANeygK5excVva8smwqGbSwythFoPV3VVV)W3Cs5sgmRaAFhCs)(IJnFlGt94BsRa60Q0Sn3MMdIhB3m4KXN65pyWP8NQWUoKBD(K3u(WcgYopmjaO1a3wb82N4nIVi)5y2IA8yq)zC5YJPA(2O53jRdVu372n5Lw4YLvphc6vwgppIMSWG(4XbNVjgETkIs)smVrVpGwp(4lQw(T)8GELdCD9egKxpFLVbGZa3W6T5dfTJZSsLdKdFysNxUJ(DPBbecSEastBZJewCmBtCPVsPUC()oKBErWuLWlWTqfUwawlcbnIcWKKuSGJfbaQbVxfP4fr)JTXB2aQfaDtGAvMYjyXeSH5fYd9AF8TGAZi2tNdg9a9Q9LSkO(uPhIb5b9Ahs9QSwbWf(JeGVVj47Bh((yWNVR8x57emhOIa3paP8OANqzetMtQ5mPViyxLXH24iAk3htgJj4H2WwT4HzAKC(qxurRxgMaZiBMVmcSqX9AR8D5qQIhikK55gmJPmSisI1oBliLX)Ra2RuohHzVcSogpVauAbQLyVza7fhgMSidawmi9XwmvgnU8bGf(VZDj87dtsUoSrIBtu6ggxAc4pEscJt02uVmxAQFHH5M9)GP)RR(96WaePEt1mTgVEUS6mU8yw0AMmtqo35SHST2snv3WJqamUUnl7bqeTxZopxZxWIW1Cr3E3mVXAZuGxREEhwoL9alJFiGngpqzyyXTb53hfTrZO7Myq752nblZcVHzB1Kb3gdpLCjQV6RkzVxYM1sAjtD(7M(LJmYETmkj46WmairOQ9fEEV(nedHFTMk8o2QDv4VCYx0RFL5kGXDvCu(ftbtgXzGZ3vMPonlmEralKTIHHlwKdIxq4jp(O6phVUfOyp9IVC0abKs2ktfA94JkiJ)GhFKVvlUgats9EHcAp1R3luNZOFHjMnqHIo)2qWZYsEjgHhJfdyzWzW6lY6SiFQpcg3J5j1fEQ7KHRxhFBCPPZNK5vLF9Va21zX4uXjoSuYmpOe4dta3ayggwmRXoCXTmJqmPboJCJ9j9i4HOAzAefupQQxuE2AwWYRSwrzsz8IBZItsQv2Vm(MBlckTaQXlF(PAKPbN2YXXEFwK1AV3yMhoTJl6HOGRJcxPpUAV9Yb6eS(bzeqwPiE9daa02Iu0ZSGXIsOFsBK(4JScHQ9tXaPH7UcUAn4bk6)g0tMx6DJ7v5Vo4guemXbxd7M3vUPuo1Hzn2FRyN4(bEX4kXvuP7laUwAQShqWkxdT)IQS7Zit15pXezgXGfzrp11SQ6kWMnMpabn(kQi2)(uEaeGf(vmMgW8omlLb2LhVkNjShU(MsFqZsxbs3BHhvMlQDZ(jEsvyoj9THSmZj(7)Bvkk4V73(D8STCZnj8CrXg7TrjB2n7oMPZzZbqVLlS466Puncpqlq)578M0Re6nUZL3drgLThqytH9Okbwj(4wzlz2BWSIcU2e(E(M4co7Mb5I64jQ5rxfMDxJwAwSGIp4cGzVcwI)CJKYu)ZQah4p(87yovgWXgnZzeUigi6QaG4nCJIUiOAWC7gfGReShdqQCX16ezaCj43qlHqyMe2JqCg5ISiGNeC2iGTZpWQYh5Tz2dmQ1zIkjBFwv6KkTFQreEc1JUyc9At3B9)s09Pz3jLitqDgFDukHw(4Y8aZ91HlyYicfH8Wpb9EBNxSnls1PYO1WYABty66EJQfBmMSx9QcwWcoy)UrdbRaY)GG9mn9(tfgApZUhcovb2(A1SwOM16EApRnvZcgz1FV6Ghl8gEBiZ7WqyNB9dbl2O9SAuSxFHhOgYzRpdTXUImSlgpAGoE5JGx(7dEPhkChWRk)y9h1krdrmNb8dL2q3U(AwsTc4(tlkfwnkiUW4BUbCmS1SRUG7ruBwBgDKsghwKriruqOHIfQbbQRG5WBXNrECXk0lTqvqiG1U(lLLkdQc7owHU5aZHcYAqsD0Wj2IGRgAjPP3b8KHRda3ss0IwXZ1nE2K0G8Q23p8fR4WkPRMC8M5uiTAWj0KUlq2WBc51IQrqATfWQAU1g6PEAXb((uwINyX29QARfBYsNNd)1dPBbZkSSlYZ1pl3qNvKEwzoI(HgZKGBGGDYCEwQQp0mg8yrecgLGnJcGOwdCEqHGRMFv7zJE)93pKzt860I86tif(3G)8BsZkE9c)5Jxh)F(Hfx(3E47U()ErE43LN9nVU9KpTz(U2JrnbTQT7WaMrCWnC2z51dnr(UjpHn3opfW(gBJtWxNg1X(96JKXe9xqtqsjznD3vhfaCethec67a6Peo0eJcKQUP9C6evT0kdP7BuRbs6Wy2v(SJmoJxhMJmUfOTWohBlLwx(028brLLH9kLJubFYp7yej3XnHqIfnbPLrwIMbxKwgppU4IPNp60wNPQorXty25FbHfufixL6LIOvBIaZ26y5bO)qpxik0r0LVgkwCBw69cPms1vKgxe3MfZQva(4ZB96nFoa3vSTQRZ2c)wCXdGrBUsnEIyruRBsDGT8rtZ41ySGnNzpCXBvPpIBZAMcFbQHkx5Gq0u7KgFBgS0YkMvPao(MULN)XSqWDOs)2CiZmUNqc)jQ4T7NVq5XPhCDCHQfdvgrIWO6rWlPYpyAjtZe92gEx2HrXrVWKl8goYRkshDsRQaJoxxq228B)KCjzb3dZaVFbSknduhxSxSx8dUZB0iXcTti9SWKi5vj3DH(gwntzNgEfh78hMNWpgCWzBqOXqagt9gpOLtxcnjmt0eAROaqjPgrY(C2r0tLwR32g7TaW0Z49G2XX4nkINdgwcxNZZvnJYHAPgmHxhNgynkGlFPLZ18Iey5fuw5Kg9z8cbphWtE)Gb9uJGhLWkCKpLN7pSVXp6p5moAMvWO7T97tD8cn)UpXVpw(3rJFglOhf)RgqZZ1v2TgUA9Jp7xpmI9j4eP8eSDIu4rPz(GjrM7d)ymgShSFBsz)kxnhYYdm6HLGD2ohPgKMZ6wPwjIx)H07ak(ValvqBCa71DTEjeXym4uMCOnP3d7bXRxUnpw4e11XDKL6u)ruKi5cUGvP7XW0wfIHCrx0uRuyf1AZdz5PzoRqzyUwYyYwfxW3)BReR7cZw8a8Y3awVeFvScDs4X0LkBZqilt2wCNL8MSGK053TgIkl5oHNru(STqhP0zLPMSdwaCeAvj1uNovAnuVu8AsLSuj7Xz2Mma9yGQvbmbvxhdDg0tUg20XMEcfHwJAVfG7USLg)aQrEE9eZE8lAFolswoIar5oqPa2mnZEwMzKyCLMzp5zEGmN)fEmVlqdhw5hOjXgoGo1tWFIB8feIi8uP7MqMzkkoj3afvAvyFZZaxHeKgOqFG4mCJajRHGl0yMWOonQvqPe82dkHNbOyJkGYlBtkt45ONiJCu)0us5clv2dmPIkaDoWtLeTXeLDre15nzVg5C2KppTQPh1pUQtQ7GWokRjmmSnXEIvxDVMFwQsJvvc4kcqyR65B(BSMThtP1mmspVOwz5CMe4qFj2Is)pBzILukx7QUbn2OoXpq1yjks(CzV0YKBtnYNaMmrmmQ4W8cEHuJzgmOim34L7HY3zlG0CYg9My6KjNSVQAYtslAUgCLE)rpl1h)PAsCO0oJgWObUKZylsYyjhqYIGV4NWsBGKphQUwRFQoL3eqL3tXUQ8dj2rfpnjLGwmkf6pImyr09m)N19me1kUVN53X9mFh3Z8v2ZW8Os(HhYEg61LHCpRUgNjpDKsRfkBohWz0WlQF8sFeR(gBs6yMCXOxIw7ByDDn(XY)7XOUMi3i(KS0rTCw6Ljpsjp2c5rtl7ivxzX0SGTBKtnsZevFKuQ6hemUiFepQd0DKz(IGfahQYfISjBV(gGe6DZqmjFkHxi)2Ivca)n1tKPQ2qK6jfv86CfrDLjwKxIE2ThUKmyfYgjjqn86ihvO663N4w9y4yrKobPthBISOFM040f1nfdGuP4a6kjzPC5lYp9wVrJqT99LJmD3QOT9DUEwUnJrwRvoKTidqu)KALQ0GZh1r4PHHYVzpfO7o)m7fpRXWBJAJZgp5Iri1gAT(OXc13IOIVMdJx451vsXfEVTBmQK42ONBCtHJ)thIM(r2Ey8zIUmXrkachrhKERrn4QgEOiZNpIxi2pN0z16sXcQjAXxf96z6H84ORuiIAwGEzFI2A6mYHo2FWfg3kKQBdPXXmDsyw04zNsESzQb))9SBJ9YT8ImSSGAxevgTZR2n7R)Z)0UzzrFiMDmx5TxsZ0fBz3URRJk4xfZSO8TjfLpFDZn3KxlUH1xUQ6efuEv2lVtyF9F6FxOjFONpbKfFtpZyst2lfRttrE6goGN1RUvnsVx3ZfQdvvazfignz4XAHXtDA5MZChRO7FJTbXUxmgOL96cPuCEjk7ctrr0wi6JgoPztu5SVDQOcowbLvXli6ob2mG4)JnkeX95vLsCIVLR1u7ihJH5AE5Z1woD8OE2Q(fngH(gw5dLBkk8FZCeJn4ngwJgs1(OUSMXW0dFhRIvnHQnClIH0rRnHMeAJ1IIxsHWBtxbD(1MYLRSXAkpi09UjdNONLeXTKAnB6fv)3MU6AE3tXhmBfLagF2MFBzJ7jNGajxHG2jq9TPovlyNhF0Cv43w12DfYO6tqIYTPMG1IS0TYS1OOJcRR9mWkUqrLiSOuQbmOlFnLs1hIjhzTF)6BQcVZnueAxyxfQOSkIz52RqLIQoNwtCfTso3AKXIqIJNydcRyQfAO(r(IuuUktSqLQRwyDgocNlo3L7fbI7FOuoHmGz5klQ6nbg40Jl2L6c2uTEwxY8VHLU6JxWDkDOIA836v3WVBkeulC86T70Tj5ZdZiUadUReciIhY1zq5KmzOvtJok35dUKq5NzDyvBQp(O8KoSifOjxmYuFb4DtKclTml14kg2tC6Om3exacC9LtikHFBETOMbfxU8p0iOfnaoHDiMxXFzLRwGb7I)bAc3rvPGLR9igtLnNM(OD9jiO5QQwWnzqLpLYKrCAD5iJ)mX0YXXcStmK)Go09FWNQ9jnb8KcG67cZ5mJw1LJvDpIXwPBB4HVQ6s)gZG)A0KTLg64bv)PKdpyrY31UEGmJ37M6tIAnYoFCqTliWm1DLgKRz)xNHWuKQ4ZIMNSYLmgAK(4SYof))Z3jyBNtKWYLA8L2sDI7ze4qiC2xooMQkKscefTm1CL2dzRNrSRVUdtnECPk65aBIJyUL9wuNjC03EulD43)MEK9zvYosyRaU2JOH2Jp2(iGyXITaEpIcSHWehwb3yF7GFjkRp6om7KDLOMP1PaX04Spq2TlZVJMdWQRaTM)PBG6GAnjiSD0uaPXrerIfnGTbMt4)d1v7K8AZzReOPk0z8LOE5BDCmXzUixSOyHax1k)i99rdDkck6V5yCXiLUE4C0EP4sA269cmDu9O12HYCAiXyw2eWxku5hd1VpkqG23aectrQC3kpDYMpXgBJQA42FFuYzxwsuS2aRDm5mlZN6w)RUTTImwilIlzTtC82(5YCH2yQBJ)tG2eALTU2VBcLn)23n(0AMWITlG)lx)bmYOmqr7PykJhOSQr8qXL4uudXrZtUMd(ddZOpm2ZA0s)oSo7qJ2ashkqwFQ(oE4RVlg)KU8uxdengFx7uDCySpzC45PbCA5y34xCgxutFY4bc(nITVyTcGTAsx8e2DIbaFESDAQxm1tOVcGndwl(dozJwkP((7PWLONzvNwL4BW8W0TqpB37CAb5eFGVQ8JO7kox5(ntLQKJWM0idQ4hy5m8WBrBwpGm(csXhEAX0g21ZnuzyYwb7AdVI)wDmsG4C2ObpMapRFO5SKySCCTH6nvr7RqdM1uoQbKUpw)rdN87RaK4(g9wF5K1MyG6xHvdsQj(rD1OLjmdcQ20umWwMbmq5au90A(d3mNrCVjQ3duL7u5LSVlY4t7xwSrFXOZgpYmE13veJwXpiYnOScolr2IBJs5HaFI)OZ0yuuxG7BlkZb(5t67zY3UJ1A)aAwAAYzCYO(j3qNGLpzOcwTcsS0OdX1KT79T9W5(3Fg1fK6P5)RNd3tZhEeVM5G4J2sYcU)e1U3ecJfl9yw62BDTpA9ROULv3YTNBzm8i022myGxjY(aXAkJHAU11TSXqyAHIEnyLocqYsM2n(h6(Wgv())vd)gv3zRRjtUd9Gnd8s9TXmrLBsKFwjSQ6LQaWLU2fCw19Hx1AhIJaLD8MUCa9foz88zOVWjpHYzF9Z9foT(XcfH7ZTaUp3c4SZx85waNfc0NBbCDPfWzKsEeAdBw9rt)iJWAxsOz(D)ArB6klDdMg66AyG05Uw1(yu)JAdRIGi9VsnSkJnEkeLEpFDMkh2C(TENPYyhMY0MZtElOsEZPBTGk3lCgXoPD7d(nw7KYEUjqWy8qzgtQBRl9MQMDE0mvyi8sPjNH0tpE9pbP42LaH2SkUCxKMUY2POYNpHOQLEzB5g085J0hnzueUmuZOoE0z6jn38PHFQcBO9tqJ)Qy84dApskA9Qnh4eZViImUrB2w(CBnaC58OFqT4HBulwcfkgn2EJyPsWPxkFIoklfOP1n4k8NYRnIMjb)OcTNFhnEvTCvs1)favvyj6tp7NO5u6OOMJiLLwKgyfIHlsbv)HIKWjEdNyRMukj7yptUoeWpHlWAWaJDXmJ(OkI6yJtQqkBfbu0RIwEKOsLM4F0QAF57Co6UJ04Bwh4LDR1RF(0j0NvPwezAlLWRFiph8L5MW)zuzeBymTMphu66nO2tsjSG9oyBpDVryy(UJq)(hyd0GwBHr1cmXc67NqfjATWLzAW(ClBCHY2hL13cYtCtGmjf)u2HfAxD7XLAYb34im2qypGKeyREQyDxKE7JdpvTUK9Z8aoDQErAgHpx6BBS5Ttuaa49a8g0Vir5uQZEtPq5oGwNYZkxG6z3rEfIAaI613YbgI3GsACPnPyAlZjj8duiwAjvx(BYTue8au7q9vkBO2fdLk2Of(IMsDVqFs6)iKmC6zOXc1YWNEB2SWxceUIJg2J5dXGkUsJmB7vPUW)wasZLoT90Gn7vRQnq5OAj8RKQfmiCVhmEHOvNuwJnCl)7OkRiuTjD26LLbYt9qKkQupKIkfv2ScCMtaIMwf2VIQosWLZ9aKMcN8DNB30NFtIcoXiRqdCWJGXuH0BdjWl9uIWuSTEA0VzQKdpXEMIq9K4O0ZAOTez2nIdQN14IHqhN(Uon)wTLSG7YDF81wj9RdfW(ahAMo4BLyp)3EFcHXD19xJ4prdVzz9DwCQqTvP5YHOJx1)mcmuysBwJ1h6YqHBlN8L9O6g2JdtXZSr2)p8t(yFWvxsaJ2LDFQh(j9tNOadjxa3URQBkA58KCP152Gbzmq6U8ATFS8XADRfrdoEAVikoUO1(CoahVE4eD6vjCZtqEQ0QI8rs4zUX7E0e2qtygTovZ5ZbpPcYm2S7ISfpqXxCAbBHxQVv7sskWn2xzWNnTmlQnzi3cC1mlsFgpK(LACxFaoU6s6)vXuLm9tuE0UrBCAcvt6k15)GqNjw2D8so2X2DcLCvDFQXAWDMoybvMb8PvAu0kA3tTO7H(fX4LjiGFS7ZiT8vsmbLMxHPuHPzyLBGthrWKDGX0BvG1UegfieC1e1CO5EfYvxYQwg4TU69(J8Nm68rF5vxEFixej)Ql)z2xnciW30mia4LSpofVCzBfK8s2hBI)XwwOy7GaNxX(ctSTiDf7oeVBgqsbLUSpKe)umRfHp5Ry9l81W8XF8lTutzaWlsfgwb94679ldSoni1PL2uGpMNuW3faxjmycUTdPRyDhaUdGvSS2qaPYJDexDaOmN9ydXDG6gZh94CAAqQGte(79M5BFbFxamf)b6q6kw3bG7aynYNO9yhXvhakfZ3BEE08rpn7dD(jf4wb7rwUKEASI92vUECbEdy)ctKg5AagNSOngjSMc873g6tkWDaS2jj4JXjSE)2iFsbUvWUVMeCeR3xWBfW7RFuoI37l4BaSN3rMIOG4hD47cKDW2gLbZddQuwmna1JIKUz47GDhhnjBEEiUkg4tg9GDBg3p9mpTqVfU(2HBNKxvX7Jn8DbYoeUcPu1bbvsPkAOAxQYbxkmdFhKQC0BoZZJRsvwgSBZ4(5qZtl0b4YZBZY0KK075F9pz54kF3S7JyFxrb2JfLFYpl)OGYZAu9xc0R3wupoEvpSKLMuXrVybBWW2s41H5rF1UFK)HGdygzh1jA(IEzNstKkXiDt1xa18sS4LD8y3D4wV0P(g3WO1SztVB4PvXC1J8t8(ixZcQbw26NC1mHUTt86pVt80TtmKqQBtw080vxhw0rHptURaZqw6hIZzFeoIcH5jE7QGnGDGvH3r51I13rsrOr96wbfI6DRVJ00p(5XPqJtd1n7hFYmmA3NsIl(p(mspy3Nq0Ugd(0rnu3NmazxfmpDr0VqSGeFUeyp)5XBgJtJZSd2gT7tPRSdwgS7tOBSdghQ7tMb2b9NxbwunSGDVWTjDu)QnFBQmoWpvVaUbW8AJcN037333F4BojSGvjWbGJ(frdoP5Yelum21MrqpN4bNm(up)bdoT8GkvohuEvgFYBkFybZW68WwR0B3CI3Og6MrC91FAGRwzk46aUnTSiHcMdH3qO4tBmoXZvMlcK(md(KqmshNQ9jyHNuGBfS(oq9XhJtyTVZuFtJ0XPYkbYE6voUaNsZvy2Npb)Ji47cG7WUx3X6oaChaRd5zQRhIQta9ZNGFxaFxaChuC3DSUda3bW6Wrh0vMpNa6NpbFxbUvWEKLlpUhY(tkWBa7NpbFNjjhPZ1ZHJ9TdBKpPa3ky3xtcoI17l4Tc491pkhX79f8na27zn3uKZ2(UoEQHFNGCh433d8Udq3f46GZNKNh7bbvYZJLgQoZj6EAXmW3BNtXbfnhD43ji3bJr7bE3bO7cCDWt0oZj6euj5eDiVpDAV7Pg(UazhOhKu5dcQ7bvM5dSAF2h3Qd2W6WSC4(yzg(Uw9fDQMMoU5f7Pf6TW1Hu20jlZQ49Xg(UazhS2rktDqqLuMYCEHSktroSomlhEOCMHVRYuDQIMoU505Pf6d)eRIM4n6Hx2PCN79wzkI2r)903MrQP0h4m9AhMPHKh9qhPAu6MX5bDHr6JgGpuZjpvySpLhL)keWhin(jaJ39J)axcGboppzDtm(8RUK)VU6NV6sHBwl8NV3J9Bvhp(vFZvxoplg0JhhE1L9bTTGSs9SPwWz7MDXuyTmA3SE8b(catrU901h9(Uzp(iO(J4Z21SbCWWFO6h(T6jqVplbOWUzNpQe0iJOft3n7TLJQflfNMgCSenKR0p(R7ZFMmeW)yXjVGzDkFomLAWF7M9UDZgpsAzRDzU1ORkTlH2jQNW2e21RNTaQuNUB2jWmxIB4Fm64ivjE1o1XYv4OYtj2WlXFYAHSIaXw7eTkIsYWGAiP09)lFFwtvHVa9Mad9Qll58V6sPI84QIREVVjgDZKVYPNJPA9sbjIVUmYXq2GVmRQNt1oEPmiW6ng)lUSv)dx8YUSsZurjUiSfsWbmWr5L(UiY0JKBTrKdT8I50UgnfYeqJ9ijjIWHjNoMuo10(9eYLw9QMq8QftkBxAmu4CfuifgvEur7qRxHS)vcR9wy4lJw5SB7ZWOYOKJJt9HifqKYqOkrtLHruxLkJslUvLNJMxyorkG1oqaAN8x6hgjEIcjUHDqJ(P7sIOzPM2ALSMHsjEXVKyYmHtu5UjehkhkbNLI5jbx0qpRzTXHKDeoZSxLwxdotwkjnQvRjEAmAuSQKic74gs2qXXnD)rjXnpDCBaM8m719hzvhV3iIhyAdTCcPBpx8jvhKtU6Yswze(tGB(neCZec7IS0VquqZMYdN24O3GTTPPSUDMXXgJQcChGsLzoc0qMPiCaT(liO1YQmv0A4cvgdFWicQ6MpqclsUW3hIkLqPZAw0g4aA)iQ3MuO5WUZBP2DqSzjUhvQz(D4buI6oLysHQdHu0bjlEQJ6LTbTn(nuKgJi(JAOdyRoGA8LeudkZZsE7OzdRE2iFByg9grmLeM6DBgPEz2eQMaHwDFCEmVoLsbr3pXdwWZOJEdSeqJzjKZk9oLbFlH7mWU1nB8tteJY2MYaTXqOjwBCKUB2iJr99y0nFq4IfGaqsAHWwoJVqnEBf(c)pn5lqviEq8fQEKTx8fugE0gJd8fMo)MUZxqyXdJVWNZxqhFNbVYkXQQTD1VHN8jSYYg(3YZ2DL6q9fESsi4sVVW33ZAK4yfUWXmkgXFXQXZ61OEBCx3WQuhf19KuyA1BK)Fkl1nc6kQ6t4Cgh1OYDLXXLC71Puwi)9m9kg2D5YCSKPVikhWYnLV23hLC2LL5KRfwZdtsck)Jawk6ltuFvCZIPQ3ygmB8EYRKbOi9MBsAVv7nltDnS18unpbl5j))S31sZTrUr4Fl6YuKwL8knsY7UvjPujvUKl7H4KRMIlfTnlltQAOyC8f(Bp4XmaDd0pagjBZnRUzRbCaqJg9JV(XSxhOxndRWii5lQopYn7V94W7xQC1HJd1TvbxGlNU67CPY4n1pz47jkxJ6TZu(6xQ6llBF7WzurKIgrTLNGH7V1pdeRwK3dc3Pbe2HwMafoz)aiD344G(bs5WKgxl6NcFReRSZDOA4L0TBTeFR9hsH4qgPNsPcNqaeYlEjiG(dV7A6PVUpOr5pOvJOAjHOFwY6Gxz6G)QYIWVkl6wtj1ZkZyGMhMwfF8TYiVlBpd4KAkCH0uW6aTyzwc2WZEwwOzKN789N(HJKCdS1jTav7P9ML39wWxqbRMucOEYyYlNqYZvo4trjhQumAvtVQIzUL2Ydh7afElPOEnstmdRrUwOtp7v6wsWZl1T9pt7HfaAhrWGJuPHZAkeyI0hjXGjxEVa5BbFeKa7msSyuSyf(QCAzMT1y(9NwscZs2DbgBIIsDwT12xdwE3Sh6w(vQb4yQCk5ev5ETZzB5lxakyCpL0zfirjiUTGPjM7(Jny0hdmvp8T2ZEenXQjYO66NOIFzHCZ(1zEtHYnTU3Etv2MCDavcfOmv8MstS0u8PbJei9dm3w8ymR)ymRItPfsIlJjLcWdug7g8cRzXBzs8p)Np1zENnZaQBFnP2TMKLe7c5mWj9sF930nE6UXWVBF8R8ONCcjR(ubre8MJZG6v(NPUsytsypoRCh4(2rmTJIW1GKVGFCEq0klJsXw(SuC1nncOO8hrsmZTvE3qeinYW1uQPQPw3tMZrOTgCeqdZgcZ3ebDDhLByYY)RnLktjp5MODgVzSj39UsKXqLYP6BxVZa5Fmc92N(6tpdbck9Phf27qe7IFWiDBEEduzbHSXM82hOeg5DpebGZ4n9C03n8AZCM7cS3DE3I5RnKQnDDlDyLACMk0zgPGLupFMWbrsU)gcZ0NHianZMXqBwDhzMxwX03oQPVfn9PwuuX0ZgQnhMOOrjNXv4XkM2v4HsMBvKVZqhLlb25)29Zx8jFnQ4QoI(F229Uel)JMRfH)w8AY2(b)pIFWnVDUTEw(TLlm8MZTSHV1z5HnhZxV8eREcdhT13J93U9rlDQd(IdFwJNhO5PSm27huOkwX5fBiWq0R2koVKA)GudTKZR20Zlcg4bIrQThwIr3swYXW7P7dZmm)VTV7b(U3EAaZqg9uG5ya4fotIqd1Uo6Mb0Soo5nqD0OVuPyarkcJURaUEgPiFWI3)CJmYzg3ShLqje0pTO39I7Mz8BB1A54j0Bs4AWhBqGqCqo1kJTU71WLi3u6N8AujGvHcUfqMFpLgsffZHjxzkGEJu3jdVn5CeFtGCHwgbrAAvlawm4KqJKfPTejMUCShNqrpmuSrIKIkBiI3aSzpU8ZpyeXjdeMcfTCqT6912zDYaTIH96xpLN7l9cVukxCbRlDzrMzq(KmyAKUT1hzkcUcg3IQevlT3nHpfkszs5D7TDmzMzw98IE8NWqKjcI(8GRCP7nho9ZwlqH09buk(QasO9pkWq9lNMm2iGi34dYXuwracUVRUDo9ay7KFvwWRB1D0HWbuQefEH0J62sM7qsoHg2bxCkRk0Rjas64C5slmoY(OOs1FbRufLDl8YN1otVWZL2(J9qn1(Lwn9evSHKrWPrBaGAfaPHIvtVgz8vK0Ktu(jN7RZn)1pbCCBpdA9n4tVlLL3U8bqSmEjm9I12A1WsLiBviJK0Ycb9mUczSpSg3sc8rbrFTjbRqHQWulylx5cuYBkBW3SFit6rJMm10hBkwLVYAcOptuYJH3cDyyH4cpe1l3jZqItYuJKjXGsVqyFwtlrGxBfKwbQz8f7AJXWWsozoRwQFiPr0yUt)vNtBwNMvD3CT3GNg9dB(fvu6zHKsIKZn7NmTosNGBLvLvw1jLufnA4RBiyYY7jaxpeZajwU0NY7YDQ(AfpUz48foL1yBB08L(QRbYFk5kw(GzzvU81xIOVbTuPh6rDn03Q4TDDKKTjLQqJXPx)2AIkrilvMk7iJDwzYdsElV7d2IlgBTCV7Z4VpHrPGavffepiUuPWpksYyVbRrujsQm(BPcOVKwbDUn5JFSB19oOdSoB4tBQ7M)50iGMK7enKa2f)b1OMkvIePHCP5IxIgcbj6cq5em2NWrIcVtWkmbHhiRzlnQz(tMQqUWVsUiBsSPsP7GiWB7HsRY0Sl7SOf74s0vbKJlJVeGiTQ9DKGup6QfrLl5MmMFKtZV5uaNX3oOeo7unqI4T1HwgEzYzjGIunv03UzNRz0qMZH76w5QbnBEdSvmD60vheoaXQw8Np5P60vAh1iSAsYRbEf)6QeqmlbXa86hsmwmeJmj750s8cXkyJueKkJGmewu44DeRFv0wBjaQubsoQA30QGOcD6BKZHPytXFr(W)7GKeQBgYHRQfjNhX4Hf03YlO)GnbFeoCPeirB1B7fLcH3qe6hGWl8BwTTB3dpMsqtON6bTUxml1Nppq2f(tU)rRf8iZFd(50ZrwE1GBjW3g6dRhNnJ9M08QH687SENfC)h)vFQp3EUFXBIdI4ZUNBiwZrW1yPtYApM22L1d2SVy7YfBwFhmI9dO2sbhKorDsUFJuWyKd9j2KX1d5sZSTZnBbJ0r07XSgM97BwVBRXk(LFzE3xw94hxT2McuBneR2zx8Wc3nveb4FTYUHp)ClwQ(TUnRE(4slnfM(p(02z3dg2y77DloZEgwoOutX8(o)CZSUA5csaL0PBhP2eRAWTQf83JVGRT4mFIAq4rqpx(ddWidIqGsogAertstGhXPL9d9x20Y2xfsoy)7B2ziL7V12pcmtm4G0McxUMvS78D3wFJl2LfwGm6c8dCjY181G3L3LWWqGh735M3zgooZiPWqdTkF7YhM35Y4kptW9(uK1TYSnCaFToyNOLlJmkz18OnyilSMuavzWwLeOAKCENmAwhjuUfOjMDXHkiZqGygOZYbJzsgap8TvvaS7l(6I7D8Agh8mA8lTe3CLOfSk1kkciV0JwJwE)NKE0QEW4(M2zvNWVpr0GwHNDE(ZyShH2sfsawQoQwJ5Af4EUaao)P(Y3eL7FUh2TCTvpyFK0broSGBN6x1clej48K5cM(8CD7j1GuNWETOar)XLiagWxABQpNTn10zImlXFPFQ(s)u9Xx6NQV0pvdNbeuzRo5x6NQ))A)ufJ(aNn3zT5lEi6ueoe71PjZmrG2bGQ)DQNVYBPpO3ZuXEKRFUY2DvlPHUgS6dHKMBTeEecTfoHNX1PyNGLRXSwqNG9BWsvQfYY1QqHw)8KxCkr1UFvgNrQavhWeIUJ3JUekSmNKWjthhJ6sVmk3D49dHXilgtspuSZQSLxXcR)JNPwkgtrZwsLnerdQCBWxAsZmAe4BsZeE35hw8EFpT1vlV0VKs60ZpBDQ3Q7GZC(u2pOx6GZ1W0q)faLJPPLMPP42a9Zgtt1T3z(iVOgc)mEINTCC4xHijcHdKQnqBFpCTrAGn8DV0IOvQfdu9TXNVuQ8fLCG1Z7uBRbpES4tvStctLX72fFYIo7mxUbTTUYrasWnYrZZZiqRJEE3q3ionjq6HwvohqsYljo2s3d7ttW3F)UoBczHEgb850hLfu(mKf9vGGWMHXX0WUc)ajBr59dO66FQjjR)VYwvbGGbxs5fP05gsOZWisjKT24JJ0K9JpxpLVK3)OX0MMPK80OLNwPs4Dn(63btHQqQ(jgb)d4T0nP7OqsHP2nBH8RzR4AQbiEgfX2fl8wfzcnrwxw83JLVQr0)Dp0e0hPJz56UAXLuBD)OfHsPZB8tlnI31EkrFpvQIuuSUGHiXIocZEqnee1j4rVt7EiSHMqLp4iWRPemTNRmTe6yjJCtxadhFvMvqHi8(YAAS0wJ3Vse67UXBKkfvZrLmq55Y(AK(Y9wKNafyUKSxcm2TRv2WxHBkh0gLnIJuEtAOeVxZ0GTqwXPvbt2K18N1DEvQuuSP5fnfP9rfEL79mhQTi8FFx3A7g9lznbCIlryQkvJZvrj5iuhDdvLhMzFeNZJJl5FAkcxESSaoK3J0R8SOJxr63wtJ2rVnPY1nnr3u9b3bpDvROgkOqaRzgfHIh(YmtaXM8zhPGrxm9hVwEDPk2AHni(ioTcnLR1H5EMDN)uoPfmm2xZpdpMViqXLiJureDj(fYuln)wBQqC90p7XUDOsCWNoEdOY8Ur1jlF)873UmjR4)3U81FJLv2Cu9zJoY93U697V9l2)CN7QO98A5kJMxJ9aBmpY8Vm)dhSq2s1y7JBFn5kDeLeeLkn81jsDrK8U9pdHzY1bPnbmM7(GrPZc3qPf0MqW(R9MiT)2)zFI5)FGT2uZ7Icik9TE)DgYmBTjZOAYojfu9Zpp8RY0t)8GCD(0vkg3AcQfCqayYyAFXkevdITCrDkDujyH7jJJh1msU1jyUV72clgy2DEZE6CCn1yoL(iZ3JflpgpkgZwjgWXhwsVK4QSEjXXcBVPdpoWUo46b7B0xnlH6jS8yog6yh66nNcgn9ANq(2DBP(Y4KkRK5x1wGPVH72AhgaK7KQQIJiKp7NJmWsgigQqs4E88UqMt1heI(A68MqvTqywck6IQwOasNd6SRyQK)Ev5k2Z)nKl(HDsgPTf2JpYPDCjKO4hCty9XjcE6b9hY0PLVBJFErR9JagNVRpZo99eXdp37obytdmNav(UTyEpjhW5ju2LjDCEz8lPVdeveyFfwyrsTems8jnxeXRrAS4nzTdIcb2v0ByfrNyK8OaLHhR0rrPO6R8e)zKaMlLhsijfkampQDO6NL2d8VnQAgVFdmFYNWK0zdFbuCdImdJIJazvc9B4rCg0zRT8xpF9xND3dKpFylmSefZNOCZ0CsQvsbP(QdKAT3YS2BFARDQeO7jT2t84OO0GFWwJrKAoncIwQSfQkappT0(E7u63v0TJKgzjUaHJPoMYkmo61kZoF0kCgB(jW63mXPk0XXAZlb19lkAlp7TXsfrEdna1cGQiop3VzZNmxpNVE2NmwmtAgus(KY00oRR3yvHvj2Fyjr(OE6j8NfpKvXt(IYuSDP8z2)R9UcwUPbIH(T0lESBhGPXuMEOox4tG7TtBzcWm02zAApah4BNy74DxPvpjToPab4wNuhN1YsALEpTsdxJG(jbojhBYnHSD4s5UAaFLt0EzQWBYUt7fOTXLZbvDr9xlGgBgKHg9HlCi3EU5vVKqxcEW90yXeFGest1tluUcg8Q(crTGcmT60NK1v)pOTd8G2kaafcXG4et0C92jHIjcmQ4VmR6awukM1y0VZyAt1VtlbecTC5eAcJUhnmDgZh8PaooceHmSJtIdv4LZZzQcuENDDbo4cq)7a)QSfV5PCevrhQkDUvsgmRVDZQ4UEvRBE85nF2xEI3wIF57wRT4Dk1d6HTr)4AlmECuKR(XJkL4mZawCyfLQ92Q0ao9VPT3OvQSkyjHDABn49Botj39e4DtDRaTxykmDI9Q16SIgAnyY7qB2jR8cvYzJI5Sr6QhAcg9N(060T1iZ15yUSY9qLE16FnZBQX)zcLx0ILlX0PSPrL5aLFy1e7UTxfSD)4dpCNx5zDCRpRFV60RUyoP4bN(kM016RXZXwb(H6YtApbmscYvJK(NUXQbj(D0gY324VRDuUL2wPDrEKlBj0i7JVxpzWo1svetbbKDH5H22YC(fMqrL3vr3stFmmmJRQnbeBFa5vNBILw9km0ltUQ0PgY4f1qekAhBMALsPm8uQVIAOjUBHt3mWMx42duQ9yz3VbY5(U0mcOuCe03XTFTW5hw3p3wR1HhEXRmdbF0K9E505zwuTdHSPtJ7WhiF9ScaWdjj4qBH11RP)mndJy1Krqlo(Xw6clzFtIiXuXSHj6qXa0rgXeYMdCRfcviP2Q38T1RV(Rx9PR)Ey3fdFLk)QvU2LBjdnBY6S)7cdqz3h)CvwjbFHiZpKxKIrVyg3lDlPZkX7RQd2jJF9ZI1wz89KJaBJwWr8QwgZPJ)6NSwPI8nFiRSfxE8PjwtJ66eUSkZlZsSeAVZwOEa1wRDh7XRiqZf6Wdc7zXn)mDuB5RLmWcn9T6zN8E)sIY)ubL9d5BfOM1wTcE7gEgtGnxZr3KiogcIsv6ESW5zna8LrAYhOAOsORX9EkE8rd38vzhvy3QQVJlSdGsys299WoxaI0Us9bU3DXPu2MAZvq9k2YHftgKZnKDrNr0szbZjqOe1huM(pc(ouik1opGAg69lNgkHomFKzRWJAXshL)q6AyqmOMuCYRdoYh9)lXg43KEiXeCqr0b1fiRitCQ0e(D)i0Zu1mfzqJK923m1qEGtum3yPDLb0IsH)YUXfu2ujRMB7)Jb2RgkEax(V4jiyiLtV0SbL3Pasnvjv5p6bSP4VbXjhW4ASCM8gj0cgGOhxGkz4(JaIOAo3mpOWMUJusQTdcCC2Jw)ecdS3tC(eCCji2BeglmVyLIP0oe0IhMMkB6BKyZ)WZ8rLsMSwk0GyGjIZ(tyDAuVnJH3KH4Ev5fVXyzyk(2MY0Qsneo8dEOrOOI2AzmTQuIH)99WNMtZIfU4OFKuuw7BulvOIgyKXfqCi74O5seoeTBJwXtHLK0mFKTLCWOflRbuyW(FQtBerooupoX6DRuHRl0rke)8tpyfmvc()veisCyp8qoZ4Fs(fcoCGzkq0XjaNKvZbGulyxBusnIlXA1KJft(Uz)T6ZYi0rFK83E)x1eEu7SasEkIbtKto(Pz8aiePyz82z2hTk1YcsAG(EIMcrlOne8YDrxw3gqojhzNoyO(QHVtdkmK9KJwjoQPX80(vBwwzlKPTDun7IRimIEoZ0XuHuh7rCueUPFsGx4JSiGcNFgoOd3lij(WQDiitC3Wy)traAgSYoCKGe8Bsvwl7ijZ7IIUapXI8AmzNR81JfXBoSd7PzAvexM0c(thIaWlef8k4It5DHSHEWVlG8GBeWkfOuof51MLhFy5Nw680MEcbQU5279ffpkiuDonNjuRFRW0YntclplvhDcmCRFR)R98tF(HhV8dBSLF)WNC5p)]] )

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

spec:RegisterPack( "Havoc", 20250821, [[Hekili:S3ZAZnYTr(BzRuHhhPvCjhkUEDorELp74lXLphxzDs(WvzhnICi1erodZ8qALlv63(1aZl8OBaqkQhBI(Y(GdE0Or)gaD)PrF6x(0hxewe9PFYFO)KHFWF0GrVF0KHt(0hlUDB0N(42W5xfUc(hjHBG)8peED6C2VE760WfSENNwMnh(YhJ3uUoSion5BZcxw8PpErz86I)yYNUaBgoDe0ZTrZ)0pn5R(Qp9XlJxSiQQPr5W4ZA6jd)Wj(J(D3F(3h)57p)VgLSkAz567p)phvKffwC)5ltZU)8V5pF)pC)p00(rJH2)DrN8ZzLjrsFWh(WFzldqwu3ZF5V93U)8pogwmzPlJxdlHFZV5(ZVSOyB(V7DVBvCXLLxmyE6M3L3UYMZwzS))83DX60lExXLr3eMDd004K39nZzn5NZItZIlU9hJZlYF3IOLHLRlG)EtAYLLjfrzbxYqHdydY9)aBgvqC3F(3MUztm83F82K5aup80WHJ)WIQg)DWca(T2L1i2Ie(9)AywC4fRJYRxCPj3FEzE09NxKfNCvub87HjSvoSNeb)0kOjLS5ikeAFC5M7)Hqo8NpyBweSQViS44PV766H9TSD)P1J1OGCymsJxK)2Rdxx2(7dgn4YW8G5PPRxKEtsp5FoViSyqyYTbl2M37nDFloFq8gyl4648Ofb5nWtaq4fTj8QOSDaY8PGmFCiZ3aK57cKby()71ahYAy3UgZ3HWlsbYjygB)T7pVbcA2M(JjXfXWE)1r17p)u08O88WSBHTgOxxb)(64KOtk3Y3WYJxa)caWjlcZehyaqxhTjkPGtiD)5a59F67(tS97pxbi3KMDfmelxE)5RIsasG5mOjzrmh1cdqcG6cxWAcmbaNz8YB5KjXqBUoErz4AX1gh6xwwuMfbyiOpUVjnkyoWGOr6ay7nHlc(NLrrj5bByRWIO7UtQb)JYKR2egLxKLcnjAvi0UvjrfknBvuy2k4hweLb7UBdZIcUk62CLwLfEDusAzEWLPjr3gCr5V(RrzQJuw8gGSzr0N16CXYWKvbfPFoor5BxSomVytiJuC8WHdv(68Ymo5ubmRbXlsxR89TrzlJxeZamaZ(pIMxKUBSaiyxFByxF3WU(oHD9Da76tHD9nGD9nID9TGD9Fiy3L5bfXWmEAG)2yGhTgbNhveCrAsz(arvbmzf5PjbJHgp3LrpBvaiYQwzX0HVnD70SiySX7BE8Q41bPldwUg6mEBI3SjTsPsqyzwitlrDZGpUiopRCBbx813xYK1WfjuPBeWqGaGiMSbX(OGoGEfaDIbPaC2qUfUgKanGRSla2NaD5h1F0VTV)G3FuyrbiNeu(bBCEh1VVyBZlZwf17IYLlhSjQiCtA22ltZHDRYTEhn(4r(EEhZ)QYQAqoBmp69vFSGbSZdxhKvzGa07JgnKVi)itEgta28lJMFvT0RovFN)ZTs0pNnuWFgXL9XgrMOzE7)F5mdvQLVK9zsStnfxNIcgT2CmjEM1ViObLRJIXzdRkfsAhhdFLX4nr)ZY4TBJw4IsUFjMHBgpgubexrFuiJmBveX0wvUf0qWyfYLvOfct(Y45rgWCmESXbNkYJ1VARVvtzf0xt)09Z3DhVDjnZxqEZ0vrMmB6KEKTidwRGgWZgoyYXn6OhCDTjNTeu1TYRxFYbIdBMLk4dlV53Dx70eDBuWfrHBAg(J9NPUIBMy69I8wk8qMvFIBnBQPBxugvzkqdXnG1fmsXT9KAvc72wZHaH51RbQgGZE1RVtMk0RVGfEIgfkYv1U3uJ4N5p0Z7U767K6sHzyeXmmcFg4BVFxAjFJr1c(QTj(ohFBTmVAxKBoOGPLcDGBrzyIWyTieGrHXKCtFbhkcaSp0V6D7ojgGgiyHYubb7xa2hC552EDF(sq9Ae7RZbJuZfWB8Dg1Vk9rSr2RNr8M6(c147BF8r3557k)L8AELfrGHhBaHCGLXGIIB4itWwhMzh3FEeq4Y4jzgrd)l4FSLPzLjweChCan(M3Uf1i6LHRHPJR4kcSVc0lxPkknHpm1earHZVeika)DyGqKKuvW93GQ)xaRlvZry2BbI145fth924Ltz9mG1XbHRxKbdwmiOJTsQ808)7J3cSO)97p)eWiHW1RViSvIY2O0Tms01rxhTETIQq0PEzU0u)gdZnFD)n1)kZB)QFUXiNWmmRNItMlBkcxEtwucJHjGn1xfnG76h)dRwhcILa7NkZYUfeb1RDBNB1sWIWeUOPERMVOHsykqO1kcQAk7bwCDDaRnJadzclUmi)MOOTv4pjaEBmy7t52GLzHRyEP9wwWvMcy13wrRUKnkv4gMPvNn9RhACjVmADWfHzWOfHAcMW371VDXj8RTA8yq)MWpF0x1RFL1obaH4M4O8ztbZ3IZaJcka79bN(oolmEraSLdJF4IfGT2PLjGZbQ)CCs3GI91zF9qpbGs2IVAW6U7uagFVA97IRbW8WEVrbSNoQ3BuNZOpZyB8uWOZVmmnVM2GH4XizasaCcM(IKclYN6JaX9kI3enBK6ozyss8LXvMX(OmV18V)HORIxh)3zSqBszwXwtsoOItlpOAWhW8NIjLFX5T2nuCjtJcJ6gWHm5A1kBQyg)pajq)p8(cu5llyI3eK1nqz5kpBTly5vwhRjjpBXLzXRx3i5Ez8QllcQuNPrlF6XAOjVJ7O4y9NfloT(nM5TrFsdZ6AxVA2SCapbRFGhb4vkItUfgaTTif5glyKOeYB0APpElvme1aQHBEfUyk4dkYZ86jtlD24ElI4Zay2wemXbxa7MxvTPun1HzTktRjNQm2ECn7kk39mFdM)E2iaHDrAEEVQfs3pRYa)eszD6JmMEMV8QD20rdPX9e4hv5BG6fmJaAThvvoXpLY9(huXVHrLb63HzHfaqWeZ4n5mPdHjRQSanlfCB(pxcFQkS33F(pYdbkZePVfMy5F))SwYcVVF73XJn6QvmtiUjM12lJwV9(ZVIP7885WqxY5UCD9uj3P2aJaGmGj39Srt6vnjT20L)wdFRhcFpBlLqpf3l8kHas7pD8RYBBGQkUHn)i39ywq)xfVUYoXpUnUiQYFzgYwjGWNEc3Vl47GoJiUq5LrzzCmjdzZnRVnYWSXtcqvWHTHokNnPm8bndUjjpn0MnSGBcZUQL7EQ)j1OgWHG5xXmSnGpX5g8d0ENDZprdswM9HgbMY7L1SuKIRoMsA)SP2wohtUA8qzI9vzIjmKpq0aWocFfHkC7jBL8iAtOQPE(9uTzcisLHeLyV9w9PZVrTiBkwcMoY8ewZEuHnie7rNLfbsza7ndymQEw1)SB7KZMOQdzFwv6OkTFQvO8eQpnBc9AdXbcgQkRm)YwTCLjxaMFViGBflde0a7(DbIjkdeQ4qiNKh02OoDENCRUJHnR5yyReC97VnInI8aq16I6VWaQ5HITMDQWluflPgPnUGA1Oi1SpOgN3kZS9hIlbVxtKMZaE21aUoO6yyjLS3S)a2B4PHd7HGMei6QBf4zB8QvGPWD2yOtNQsjQHd08muhJ8gkucTrSZassbVApB4aWun5FqWOtnJZMk00E2XGacunSDDNECpTV1D(TcwcR3pH4j1C2TTkYd0mwxmctKnF24HE6ZPpYC6VBZPHMZMtVoQ3hvsnMafD6NNgYK(OcSQCCfChv9qDK0am79IbuUwow9)FtklukLBSgnHzmxkmzot7gNFR4cQjdv9cyDNOWI8IYfWFZTZcAm)(wiaaYNFxRy2MWf8OZZ0cigzvuBflc1UYH4YmGgR1w0TUN1w3LV7oYOk2YLThwxrycvhzP4XD2dl(BCcg54wryeelGwe8Wkqo0l(mYJMQIGdzlbMoctsstaMKo7gdwBT7qfQukyouawdYqgoyIT98MrBDA6v5bZdtcaFzxRftSrAHoGyJNnjsrQgLz)HVQfBMDVTyHFGws9eACObR6mfbMP1SRDdm1rH220J1qXiwwxJecdyMrhaDh8zTbZCrzwcl6m3Wa1EWuXMlbfbIIOrIPSEh0icucNTdWR5b4agWCeW3bWtj(ptm7XUIxmi(yi0lQ4s3jlqlY0A(FyG(6uNd8wdLiLxuJen7x3sIAs93GrK5PS8BatrrQYX2PvbpJtcm4gyWdtY5XlJno2CP4Sjhp(ik9B26CL10MPipYhL4A8WMGqm)25R5hnkm7q)aIHKRoYFWKJ4BhQFLhjxjFG6URfwLmmBIPgHqVyq1VcRG4gvFJYnro)jMkwROr3I27UWGW(DpQDhAS)rt(IYfkZRexTECNaiZ(xzgGaispg6cEkPW93jqtY(inFioEIbUCQVqf4yj2)9IyF)yFzUmPAy5B08fYbURJh)qumAr2171drdH)XgC4SsRB(0H9CYJuolP(cxh8BqLF4XNh2fhUEMCPdNlZKHhgS1DAltMM5Dt9PoY8DxOl9E5usyZG9oTaTNh5rrUxxobQt3HhybelyH9kdbDM0Pg2vsbCZDz884IztpD4XDoexFpGpI5R2BOC(PLf9I1XGFiSoz6yA0csF9wAr0MTGWsK11dqaJ(XMQG5rryAOEWuH0BeojAnRHBcmqzg)YNZBFRr55PLRZNhMjecP5W8SHTzFrwj8BXfmuwTGkG4hXbjtkhSD3xO3mAVtfS5m72zt)QHNOV9x3Qt02NRetpAIdHVq2Tq(1G6u1nheVGCYBkBodQznQvolorrAjpiFWACvTPFgoVQD)SW8NOc3UF7MQUy9bxWoBzZKQiXiGdWeuxAY9mSKPjR(ql1m7oXXbVW1Zgny4OArK6OwLTOrTMJiZtPtPz6GZEExPQljfypmBEycavPzGK)I9IQJZgnA4qHhaYaHRacmjsEBYv)23KcyHy0QO80qyOMoASGHAsGjHgP2iHkYxuHQry4pLDjGjn)QZqwHbtd5RirORtuo7JC898d0PwliOgmGZeQW(RCoKgdAZmbJSOUArT)UpXVpw83b4JYQEfVDAfYxD1KHDD(XtiRC2mHKPLwV(9pmRiIdKblI1k2J5rtX(yt7Hp8MPi92xsYE9jijPSfTBI0o0C89m(PFP6gggzL3EqxTnL9RCPFilpqfj2nbH5pgPGL27LRCiqfN04KRtVc2k(mSQb51bSrQ6uc2MEdGgJtwwMhlCbE1NEzaDQ8HpjoxYxT76xYtqTtvYxV72Nyb2J5S9Jmp5NZommMsrgjYM4c(Ux3d44QWSf3cDEfOssSRyVpcHpR98kPwtSlVay6XMQ1Ko0wPObl0e10QspPOw)UPzQzXBe5RmWXt5PbPdnOo6UamWKT04xivdU4wfPK2VZEXpCajm5wpLxFIPzEKLzgX9DPzEK8m7PCHsh5tDTAv(bAuSHBJf6qpXnIdnAQkAJ9DRwYl0bYpin(VbTXW6avBOkfKgiBHaYFVPGC45lP0KYKBJJ4puSaOPGuaOv5BuPenScqje93BkrhEGxknHyfGFJj3f63hcvkHmvUdSUjv2mZpU0bdOCPvHD5mgi)Kgj1O1boH6gcswLcNh2mIrDAuj1LgV9atmYWOydlGsSBtHGW3rVghYbnIgtk)agnhr0gBzPUws6MSkyAkw4WMqCXKDLkaH9MF0)mpRrULBYrRNdXVH2AdWwV9dtiSOBhax8yWigCesCIzOWr8tiW4QWQirZpjvh0ky(nZsim11DzSSObBxU7OeeFZ4DVCBPxvmU4ChHaPmeYHzQDCMjs)jhgyyePtckarBMt5WnV0odjp3Gpud(hdgoiVkyObmI)8Nt75rbONmt6Tm720FSBgtHBw)(BrKjl63lUd00(dN4GGiTVK8F2yA7G2nbZ4wVRsWGcKpvemwM8Nc6LNrZOvYEthoPxUm5uzSdAOOjLEGdmnbsIcHqlrDb)EkJ5qrqry(vMpsUrtmD5nNq8WYiSq0D5(4ULvj43QvzA35QrTbiu(U72Ouyn4JqsbR5zRUT(rfpAe81(o4RiM1tnCtZM(1dTDz7oB6eT09ILzcHV11zsJj1NypCIRlF9RBIWL6ypZ)nofMblx0fzHu6ZmPTQoMRQiJH8ZeLStBwFzrRsfUDhxSMuYwbdeKN65FjBZa5QKGm0t01tl0zEiUfYVmjgU6qFq7Iq9kdTveTvg681PfTzwuxzH15GjOPTWqqBKKnEPQdsNOnSNtgk9Lbs7tWIgHiPhz4z1PjLZoVBIz73bRtNFvcOhE9v6xyXQu6Qs)uc9M8hjS(rPve0KkZdw0peiBvoqnlSfsbNrxaYxpShgECvm7gA5TBKR()7c5kISE3jxvppedKR(osU6RqUIfVz5pALC1KiuL5zFjxTN87msU6VdKRnzijY7)iRDhY3)0Pt6ovUmXCkIP7v9uwGwL6sDkiQc623ylTRbXQ6VpeVFBY9JDjTTGIg7yJjZhjwE9yvxsdLRrMWnyr7EmuNsHtZck3kFjgANOMBbQQapRVv6Mg6oWmFrWcGosjHf3E9Q8nmsO5RnXltJY56i3BPhReVRQx7N6lw7Pt6PD7z1EmfZgHK9rW5OS82xmbYIevTRyTBRer4eihwH7le5GAO7ix9xvKJ)D45iqd3NrPR(5XJnHw0Vf644f1Dmddj2lUChqjlLFM6CYOrdhIQlM54J(p3XXrjK9uTRgTjCKlpfAKTiTGqPVonN8B4lD)H4Jn54QFRULEPdNURJN2QxUN9ugD35vyDS7w33km7KXtMnej)c0iLCSWJ7ruCCTeNpmu47nxL)zJ(WUXeqcBdFQHnfUPxoin97XTt0zpmEcdWJO5Dv6EgEinM7ddnImuuNsTnD6qEwX5PCFs9vXyb0eTJrf86z6J8tBPwynQkl6L9rARPtiB6yFVzg3kKEJisTJPwNqLnURLT6riU0TMU3fex2yma669ijzzlfIy7D9oD4G3lEGleppxQdFSn6Wklpt3(8dJVeYz3ZVVRI9WR8pSxzvLxIV9(Z)MF(hz5OTRJz3P58UeaC6IswUN8IiM3USwKxUUO67jTzf4cwY)nSjpC2iZQkNNxL(q)M)0V)(ZZNhLaeVPS0GUIOneYnwDKiGTPoHVRwN1oBrzIsrW2jBWOh8u4jkGRktJ4PEu7xMAMEMC(OsWAkc3RbcrRpWiFqmfZgLprIkU97TpSvlPcUUwoMcfkQp7Lm0Rd5AUlv9ojhpSNTx8JEa8mSYhGEvMDAfIb1OE1UpY2By(m9rwDvXiO2kit0R6hdgdkAjfeV7QmWYAv20wO2i09UjdMOh3jXTK6)ThXsw26Wh8sw1lqd8X7nY2uM5BSfa8qJfEiWIXxtCdWHepJ233T(BD1PNTVrEBfEl7h7G4YeLL1IuZ2HbLcvtQzZneMdS2ZmuDpmDdV0Vz2LXlkmrW(dnzOQYIDAn1ewcZjULwefHibEiSiSau91CICFQ5)G0BgwzIfY6agYkvAHo7uQhKHfpjqXCcrj1ssiu9zmInC6rPWLNUTPhGRFTBLVhjlC9aCvwPOg0a)wtKh(7Mab1N8FZ2DtANO()l)q61ZOBMqIhMutbLemZcIQ3zU7o2cQTg7KpOifwyZWV5BnKRtK8uV64im84rDB3YGePjuP3aPqcbwpIKKvQjgpwEJPjztXN9CoC0K4nSznK8CUZj2f3qgw4NF(WeiAGjGizQzdQo)VO35pOYnSKViXyJCrUaLsMNTeKbX(HM5r2tfiy2e(sFzHRiLkMDvHF54Mhmp(3Ac9l(x3NWRXpzyuJWeZ8tOMNihWkIeNHjr)kPO8r4RkLOyAojkyWoro8PMEXWNYDPgFzWwxn95TtWsd5)56)ReFmweel3XCaTm55zt9jbTwoSNhqBgbKreMobsoDAqrIyPjM0jFECcXMEn3dKF7lOX3bNTYCKdAmRh)(0yNEIqBVQRY2IUL7bT5HSk1IdbkD4xyljB7qogGuK3wfkyzQm7Shm9pHqxFDJ3B9kqvMabx5EGxTS3IA(N7v7NhesDFanZwk0jOsByjR3cK1hXojC6jaxYrtSWoaOeMhRq)iUPEe2BGDZ9StpWCF4SMJNhZOfhDdVDWZ0kzHycP3Nrw9SRRhvvloCtrj29sYAcFhFOEqLbaeYoAmGu7i8c3Ii4UW9qymkvwCJmXyz70Ljo1yBP6lcAxY7jQInag8BXIScdcJjm6riYEeBNgskTuBdMJheggLwjURwR5smC79gmrv9Of6HsJAiQR7LOCQGVIAym1qGMorfCDu6(2wLB3AQj1zLr1117VpA9jFScP0nml1lh6c3tLdw9TwrE1uFB3meNlc1klf8cv6YU3hLRTVc5(sVWMwJtQOqkZwvxcGpBCBDZePCyDmMsavejrPKNO4xQFXOzOLUyhkqYO3uLz2EXG5lSID5EVQ0rvh8IDPemIyoUlrlqnqdYRRZM2vy3WOg7rkV9Kwlcodl6OTskOl9y6RpvB6F4RVzJFuxEUYxYid3LQNvLG)9iMJgc76HSUfAw9G7vvWXhGIdO1BPyNPRorjGpp2U5kZMosiL2IndEwSqHvXM0kgFolTNqG(tFX4t0LDn5wMzwFCliF0qfQtS6XatSz2Ja)zNsZnTNvMUt81xewE(hpMlH(vWcvvJHD8YeTq(Tf5tFatMULfMWtoOFVJBjpGNzBonWVoXlzOg7nUjUjkROkBrOfFoMmw58Hd9TOD2PE7MfNTs8Mq0ptpP6XEhzEy9umk7HHJPHKJnlM07mPRgc1u7EOuEAROIoAU5ZvfvKc8uZfHMp8rftLvgE9lcHj9YMUrPRAU)T6X70UDbcS04VpHdNzo(Ei6ffJ)dka8AvvCxklBhWQQ4d1Kuf6DPh6m2It38gxwWthzkXtieVFRffFV9S(5TVuh07(VwvhTbqh8Q6iPvX0kVnyujYXyQyPuByXu7rRuD5NaqZPTj9D1AuJ0PVQzA8Z2kPv)KHvtDB0zN8L9(s6mCNzAE1K)OgVEDzqMSZxz0uobm6o2639PAlTXDcF1RMBQL(nTGiRCEEgmYKCBJ4oSQov7XAvzeEQkqFegwPI37zsXMf8m59(vZYMD0apdw4DQTyMWZwB2FXg0xhfppBbgq62i2fmc9J8((ZvgQ9S0h(4vQdp3Mz(M8AkoN1AGsDBwultkFhM7cUESCSZUyq7JsEaa5Mo3h0d8B7KE6GbtvtwNW0MUCm7QCROkqD1ODd0mezBBXk0wKanH5aq94gHnUfzBIefKGIN3qkcvmtbOkDLooiTtnrzN3MeD7eoSIUz)Qxt6xn8KXdnJk67kUG20EMGIAJR4alOhpLFzpoYhPQFI5U3ESihlSipUzfYUvfSmOwuvIq6OjdpXFyJBEkLxuVJWo09tg)HxC4RhmUY3KAaEZCJTX(AFI5vDVo6sY9LNSDGMjroUckI60TYe2MoDOhs1S13LO(rlor7uqrdhLdkooQ)itNH(Hc)zlUEgUPxoylbxwjP1eVCWcwTYKyPrFenMScDFUTaS0cEFn7pOQhWysNf3PmzdfxbS5dnb32g0RjeQvIV0F7nwFsrUC0u8r(zBLQUKuG9hPQlSW9C64V8QUWQ4mBxet0Na94HpXvbyNRQVTPXtx3TmbxFrwcFpyBWVKkQUw2w7QGUklJdwXZvE(oafpxeK(u5BmI4ekF5r)sTc6kVMETc6(Af0LKJ(1kORZuq3zVwj6uLW41kORdL(ltuPVwbDTGGETc6UlvqxtyYx6vqxJubVwbD)xKkORPD5NMkORji4XTc6AAMFYQGUgbIh5kORP5(1kORKQ2xavq3hOzrpoM1)AT01gPZ)6xlDnrFCXJDT010K)CwlDLHRxQ1sxtyVNSkqkhox)Vv1s39QWC(A52TDM3RQZ5lcIDN2S(YIC(1YT7dPC7(kx9Jcx9R1C3DTiMQgqxccZxl8UKIsCUW76an7RfExxOzvpgfB0SVw9DnqZAU67ktZw8Su9D33ajTRrSQ6VpiL4kQKGakT60XgJq3tos)Rh6rxYJFdD(KPNup(sVIhRpi9n8GdOwc4zis6NddkbIzbXKCRK5CpeYN2Pa95KhRvILxM)cQelBdyCVelRnsouWAm0BPxEmVRQ36RN7sSSoiR(yfrbBhocu5HD3kXYAD)PUelRbap8sSS2qILkt3buYs5Kp0YYN6sSmgeznL(GSfzznEakVYAJR(vOx55UHnEoNvc0OZgp0eAJ4(83L1cbU3SfZdZlAwWwRpVUVfPSevh9Qbs)f7X07nVWD(D24(SuXJDGrMe2ESlt02Ki8YbPTNLj69NV2qFlEclr0wnhGAl6XVerRbAQVzplGMODyQGxptF8zQerJiHbTCZSm)WxIOjsKbv2Vr)A7ACDTkZ)XRayf3CZ4M(bwIgCrAszolPuCty2nXfxgNWI7zo0C2zto3t6g4lb89m9OHvvGiw(aHLdzp7P0Xwme764t3lsVzuEPJ6VNVPJvNsvyDhQtpDWb1tq)o9BK2o(6CS90YNnvX66AIXDtjVb7mm9ySm1T(4pfvlRMXdpr3Tm0M2(wgpw1RzR7k8UI5xVx3tgMoIOTVJE25cH)2Im9UUKsItggCp0Tv1LKtPiw2y2mb8SaRcgJgAf6zTSfup8M24le(x5j9vZXuquYvf5PuznVZfqcgxwd6sEIOvBCtJnsWxqmtOsokP4aAEBle9J(GTMiLnEvi4pA0Gj2CvOc7I9nzrm4bazw1LjGMmX4nhre0XAhW2z9I0QMr1NnQNoDU6oOcz)(Xozr1fQAbnqdBQxsxSD2X5S522OMISglfG3UPLQq6SZtRUzWJVJofw5raouybQj1gNYidfJhtrDC)Qc(hM1KLKBmHwBuwJPdTyHZosv8saKrYyf1BfhOfZlEAkTOKwLZrgp0AHAt)eAnGtgG(e3CAfkEAfl7o4bRQEDTGbq4LfUvMwiNuR2G2UBWszFVoDz4xlyBNJ9ztNqR7qZHbDe4f3MNhUoyv4VgvP70fACoJPvdJBt0iYefng3yWbqnNM097YLuWNXY2VrFPntKs3FchVAml10hpJN3kj4)mBplJnJwIsnYpr4mF8OervAOYl6cM1gCsiFXK5GDzXuJBkw5tAhguseTilJiwxHZWHtJe35eYLQL8O70jmtZ3d)GRZjQ7N7e4OdT1ckaFkdGDCxdDay5Qvp0JNweP0MfJutfZh5tTzVRfW0h1nBvZqCy789OLHtMD7gSzUNz847pHep2A3HvZUFSXN9rleCg8yS5z3JBcPnY)ksq9qskAfkTOl2gffg7jJc8llmwteRWYNXyRdVD2A(hbsvd5XRJgV7Ba2sWNpDuupXlmN30XKQ7WLSO7joiNIABDIrmh1Ai5L6zSKYHegdtfjKDojPQYRSZdadmD3qzLI2UjAdNmJBNSut5EfwdNTbwCrAk)2jzy3qvoKuFTTGAPx2TdL4)N9U(AUTTrI)zPpC2r2Z5kj7M2RZ1EpCV15M7LCphlgl5e1ejQHs6s6mE0N9dGsuKey)ZVfK0nxRFlrC9VDbWIDxaSyHyavjCOexDl6bjDSStMWbjCBNoib6nuO1b1sowB4nqr8ednobO8KZi7)8YbZQMdwWER6SR2cwdl8NmzSuDQsYTM6RPZ30ZJtYD3ufPXGo6g79VWB(sK(ZDeP7N2eDPNXSrvbHWCgq05rlv(2EUk01gOWIjtWDdo0qd05Eg(TWJukTkrz7lQGuetYNAJMHquNQc1N3awCJPn29b))OSC17DnRzzUEZLe65QiPv6(mHOAWtAtRr2VQ0kykwH0A9)03dM9eAcLKQyAcmZ7iNMFkVk65h8urDWZ4qF0GszoGMqq8CE1Io5BIrNguc3ezTERZ(0Kk)YxDU5WMlhITtRP7ZtwEtv6CQbrSLUMeaQHH4CJeXElLTLgXMxgiZRjEmZ6qs6f8ceY7SjC1qsp2Z0rkhwDOd6hzEcrc9KJ9itZTkc5aSp1b)0tLQrpwK9(vojYP6K7KTFMUIqKIpBUqqIJiQubrYxkxNDZnx4v04ES9Ed(ltYOlcRAKIli6CBwXbqKG1to)J7iBVQxHfi(p4hM61zFkpGLpJdMTY5c55ruFpCUDj0FnvN0z0iISU8nKwH025(V2Bw0rk4JwJkRFZ34ZJ6RBwtPpPQOSchAuEK6bjOk3Z9bi(nKBeMxT9VF3yAmBM66mBgrNL1GTOKz2YfaryqDyhIbg3E8l4jbSL0AnFqgcPnYGO0793i6MIPNC56a(IxTr0MSfTwUNQF4XyeMWOg4LeG9TM0lIC2JqESebgM7IkB7XRQ3Q(OrCMMaFwfvV9ublPtS1g5YVl638NKzuy(tyk)S)(3UJ2ctA5uTkXY8(f8KYZHWOrajTSkiYPvJ0uyE)NkZT9)rmtP1Zh2ipehVS23XOKaUj4LI0fulowC3pA4(6yNTpSTQOthFZe5uxlArbKglcZQyARcr3t0y3RGljRlwSiZapEJVK93kwKJ85EHYoeX3lt4mJU2fu5h6y7Mjl2VGm8iTTVIFmPtISAFEBPKyUtLaEUXRRPYPveO8C6)YMWOrgT5n0Jy)tR8DW79qkBtz7nSEK6)XU3WQbK2jgBTZ5iXIjpciNmqTlULqFs32FUtnU1HvUZI8(D6QF4RfGwN3QfIuK5BYPP))rVtJa3PACLUAn3b2CLKusClNpH5ZA1gZfF8KSNCjpACjvezP7bzrVNkLp0oHTDCICbsw(ZbpR0IjKIumHYNvb3zmGTeU4gW538E(vHXF5(ypYdrZAmYk11RM5OB3xVBjr5LDsHBleYmzg4iSKvU7iirpp(MaqAU60p(U9fR9X()5YhTBgRn6HGEAJM0pNY4i759zsZ2wuXVWoYjB6lMmX1eexCROSdXSs1WZaoEaG5qdB2Xg0qvstB5PDHH10W(zlLOJBhqE8l7DLpMXmkPd0XEZp(eTBaIrovLNbKEQVG3TePMO0ljdH1ZMxGNsdlAR5YYIOXmsXVvD0hfDBVano)ywJunmhRlsCq0yR3j3TItTIJvDTYFE(PAT2UI9lE7B81fq3F1B)3thp97g)dtU7TV5ZzLwd3(238F(WIdZwUAtEXUdZEmV4WSlFSUC2D5Hzf(QeSFo9ST5RC0MTFx(kFYMEyMt735fF7nh(L)LBu4WSV7hpm7FMV2XVYpF5UMfh243Rkh47YBq2oE6E1KVmsLnevCZiwqtZGcVfGpPRlHBnjwLAdGdaBZAblbKbFguwba1VxCEsWbft5JNoi2quIIj0Vtw5lv4TamN(bjjwLAdGdaROEs0NbLvaq5u(ETKLVOxRmAdFuKbXKunmnWWBbydMMSl1gahawatuCQEDcuRQESv3AAlFmuIZk6QTnnZyPfND6tQyjdIjPAWDGH3cWgm5AxQnaoaSaMEToPccuRtQyFMdOnP3Ljvcp7c0mdBs13)8eJopBsrdAqbxf2EocsE2Ok96Ud7xWpd7pi6KP1t1aJ7LqAAj1CWN2a6GcoaS6Dj00aj1PnqoOGRcBQo7aL6uHxf4uJ8fuUtf(Zapz8ZNBkwELMoZWIocUO9qWrhlmAO2g0TI1ZOxJR4M2r(EQsReXrA7wbW2uzAUWqJVjKnOHMGCBaDeCbwYjxi3DdvUyUfqfwtuKumULQ3KHgFtiBWsqcYTb0rWfyDAM1eHqLvtum2U(FnzS8lvRwdn(iiJ3tzylHegz0BjiZA7B8rqgVN6p76unFFtz8U04ZOYlE))F21uf7)J(mQ8I3)3p6)dJwKQ3rGOa7x0rWfVVVF09hgni1EhG4E6x0RX9VPJRP5PHYDFJpcYaXwXgXwNqLnInEuxs8g0sByHImdCP775Nm((RIeXJElnJ4j2ahbTmyXQSCpiY(XGVJvC8knRPdl664M68zu5ov8rqUEM9XN6yrBgNjbvUbrNZ2XuG9E0uKSdn(iidSpmCwO7gQj0ldzHMLmdCP7huLm(OwOvi2ahbTqBi2nLEqel0W7yolVslMRHfDDCtD(mQCNk(iiRAdLKeu5ge9yBhLzN8J5F6t5F2x)IM5td7ThM95ffUF3rUJnlx7aZt2XCJ(WSp5msCy272VRIU15LP28(1TOE(CpXZZ2L9USTl(Xd)YHz)v3pV(38f4eYSI(stjdTWckCMU25nHEES6EE9qjArxaZZl)MAGFY0(7k)MgWV8nlooFA7rTOlnwdLaEr((5F601m5XWh(3RDifCNDVzXAp3MhDv8JQQRvukCVB1UpDQxoJ6)8OIzPt0RFqbRUsju3E9Qg0zSyEi6Bw5q7VARRNJ1SMP2vpQsJcBW)BFzW)pud(3W4BytXIhYx9USDgDriUKMkXHWiT42KjcAL5V7NVHY6pbjGG7uhC9jf5)3LL5B7ImxpZY9RUFJlk6vzFKBFku)BABtwmcd2om590vguXomssabhPXtexT6Ftl2FR04fqkncMTNIS5x3V(JRYwSDxrUVEY9(mhk(1gqZmbQXz57xKv8E3pmFrHB4ztwXI7)4IFJsHxKyCgILDc45jJCRRy5kN288fFHPb1874W6IU5rN9P73L)LLugDiibhCNhTT7wL5x((TJhpMg(yIWzG(9bGLmCM4cb8XLZlR1JUzH)6Ih2LZmkZqzlwDN4oIOp5emFJfzd8KtnQXzj6KtfIXzi2Kt8uhsU1Xp5m(74Wkp5KKeCW1MCYqeod0NCYsgotGMCkr5jwrgHNlu)S9FYy8Dtvwb5P4HpEBYlJ5FBvCWx9Qj)Lxn9MxFv2oFbT5(p474hD15xULgv8MQiNldSn8s5p6QBVEY0rJUMmS3YILZvV(4h35xlXdz1lmz)MRMuRmikRF7xhYkMvC1qO6CCQ8SVmwXhkw6Lycof8ziqXclCWcLCQCBk6ZTavm5JH9nPrnel70Ai6303Dqbhawl99Aud1s60cE73ewDqb)mSIx6VpKFSEJE)dzfZzw0senTK6VkU(IP0bnOGRc7uGEFAAGK6b4e063B)(GcoxKvzfVuTz6r4TaSHrp7sTbWbGfiZd4YNHob6lvBglWBbydgUTl1gahawGet0QYheOjvDc0xRn2gHby93KHPbgElaBW0KDP2a4aWcyIIt1RtGAv17zn2MLdrIp9s1MjHjvPzY1UuBaCaybm9ADsfeOwNu9SUCn8jvY02IDVuTzyvpFPAZW21iEDL6Es82V30NbfCay17sOPbsQtBGCqbxf2uD2bk1PcVkWPg5lOCJa))J9Uw6TXroc)BXxySSH9krzLXlGTpKdbi5WCX7zrtljBlmAKeiLMnlWa)Bp9dY(zvvxup84GiGaKDmPQU6QRhFv1v3Key9PBBMuAKNUTzs5g70TndtBnguUdAO7aF3bQZHUms5edY9(r1t32m7e97eL7GNGDGV7a15qxg5P1znrwu90TnZosFouMVKQdLeIZDcqNSQo20NdL5lP()DDQ9OFqoPPEa0u3JEc5tK()Xrlkz0rgOapSuNdD5l7pm6(hhnOKshg4EoSu3s3d9T7qiFFOPphkZaBfkIT9IQNUTzsFxgK4L7WiY0Zqx8kF62MjLV6dT9mx(ExPphkBTSpDBZS)0NdLzuhgmp07hv3bPmlp0OVwhgL9FJQoDBZWWdn7kMFGVpyoUupnD3v7zU89UsFouoPp0t32mYZrXMY)wN6i68GZhx0bot)zn17tWTCX7N)K31zH5UmPx2zkknp4BVQ98)SNJ0VXyKUgTHY7MuBa2Pk8yDX58zz8osxCoF0JxEItBhRXRdYZpnJ3hT88GpEV)V)xklx5Omi33NQ0(C8JQ)RX)X4hD(Mel(NFDG8V1Cysh)pg)O84fot4iz8JNlOU6)zImfEP08(tpCVm(X7p9ZFkyB9zuDYFnzH6e98wPaQ002dQ67pLLKsdg((t9uVOyupZqr)Rshd9KJj4x77TRBjJ6HVmBrXZLvvLnEovpX)2(rm8Irxts74kCVTAZ8jAuEcpIFxfbWNbEEvDTIGVm)132uyMo39(td77XgrF5XJMNvZQ3SqmvkEB7sXAaSKd6BmVK7BCZ)(txigznVTUA2pkK)9bx7(1ZwYuA(Yo0Z9VIJcEkYcG4D2mxgsqk8gn(rTs34h9onYJ3m(R5u6y0ZSSwLqSjJ3enN4zdJFMADj8StBxXaVIMulTgHDVuQ1FEucppHEO6HvZwQs0Ow4(5BTCQpdHQLMwLZWiyADoUrq0561b1UHOQDaYPr6r)CuTcgUBSSvFlBTEL6)xWp3eWpRwp(X6zBSVAlco5)1c53BEj0R1RNnfO7u1mK5fqYkn4T8tso8Haz(f8krDLVINlKFU8ftL1ZMmVCrrtKl5mEuWmw)IXtgNfrGNfgsY1T1CH(J0ikWGqROBEy76NzbAuOvbITU(vr8vOToSk1wejZH6N4O3diNpLU4G2aQaVOlN1(EN59QUjKP4UasXJ3aQyimVfNXnkVniM36b52s(ZBbvq4AtoeGpGAbvpGG2XwNDed6iPA9FhuTgW4OvRg4rHk1hkTWZmA)AFRTQ(eX6n)2eILKacqmfIM98TeYpGMcX2b4E88Fp4kWHyCLE2IABfnB3dJRa6WB2sSJqTMRhjJsoMDFb0SdjYN14d9fSMGN5eJlzOwwEpX9YMAXnyYZ27DktKa62iZJD9MRK13ckR9XpyfXH)DpNBCeUqSbOfBaaM9uEcS3U7ISeZMLDu9OxShwwiBxlxD(DWvh)7sd7Qt4Fho9R4CxCt0bj4Jf7RGuvLZNwm7hYaeLtN6h)6wnjcFfzTuvW454eqRzkWwdQAc4DZrbf8PwbHgy4D6IzKfHYeinLOGSMuQXrlR)L7TqhqUAii3SzzVWnye9k3Gr(Gpym75ewIHria2awKdXprEFMH4AuddlCMwne6cXZjxqWNAvdnLWxDrlpS4g1fTSIpmpA6QTpllW2szW(Km7anZgwbgnZw5EphA5YG)8XK90CxyI6AUd5cR0YNOVWXKJfUFKSCyU8nSS5kP0HlD(BFamgCk3GhTc3vCWh7fOGGJppWDOBzLSU6GUq0vV1biTdKmpaNxrV6VS8W5XESbuShzl8lkvCwEhGZ2o4su1Qlh9GpaJo4mtWUl)S8k(BKIPBErsExg0ZwrYKZfT0gg4pCoH2jc2ZdRYbtGpAla8YJ34pyXQvFRwGQDzX3MVybqDiICiGLBlcCdR9MC7P(9(KGTSZK7BlWyiGhYQjGGrzF5blBGVDhDuuL05PlNg7vS9heWESLsjDoIn8dah(mFCR03LRT)iuSZT4I7JGBoa8EANG5J2rfAnECR7d9VlVq6zC18P1TZC0vhoX(AqnhhBRZm2aCglCDJtupF488xDvobdZVE3DJH7dJ0AmP5nDOvoEiC36EI0hzORtBmEfEoKW2cPQQjlBLZcnuIAb12xlwpuUAdteGsff9oO7eh0ltyLep4yz2gypfSpC8TJd9dd7Bv7Anlbys3YVQfRJFSEXQno)BzJbewlNtgASm0ad6UxgAqBwsNn0G71BmdTCydnS68g9oCn0sfokEWpigAeXLIb8WZqdiPYydT8adTCLHgEBErK9Dgmm87LPSxl7j0InLvVoBJ4pEzSs3KvBxUbwFSrF(MJX2W7w329T7aC)lXupULPuuE7YNL9SCHSZDQD3vzNsKy6(wxMhDUrAmEVSjFC0ceQSYoZrTQJ34v0R6g1rSEYcSbCmFN5QxlgMXswq2THoT(eudhMUlymCJ575hyqap)RWFZ7C)bUTUYRcLBHD3QQc9(Rek3sZJETFxUhTNmTyQWayjDlj1ODy7nlbNygUYLlN)2C93WdOojYlSPIsX9BMu8i7mCJLxMrv(5fZf6RQ(jpohA4aRzXg1TMryg79vHOuCxypIQ(IKOKDJ8CP1g1hQxIceDGnyh8gOzjVR2puJDKymSuYPz3G2PAV1habAUJhc3bXBxAiWc9GSn9f(BeoJl0MMxQ6cuhrzWhbgO94LJefsBWPw3lkLpDZSVVEw9gODQKTe1XZd4U(50mFTk1d63pbaQ2Ica94qxjuyOUbtwK7jZD98bTLrrw)HNmdRsSVwH3qOKuG7Yta99dm1qDJ0RzNptnAfvBRFdCxB8xrApzkgBFyAhhxL6BAAGtEqdbvhVceusfiaCVBcet2pYsc3tvtNuwVXvyXCIrYbDWxwIrwpiXFPBlKGJ3GONG7MtRnCLdixt4l1Fw2MSIbVVhOnx21nqBtBOBjLtu2G4r32p4DBpdtAd7B9wsdC2gv99omD6)jy6e70mQi8Dyg9zybk03nEqGDYGQSAs5sHaBvv1SgGU4rha98b7rJijjlWP(h)0IU13dgte9P0mUPVRB(FvQgHizZPJI0PjKBEcXtQSuVGZ(y6HOafzwkX4fGYKRs8tgMRW8PnIDKCkD3MdMHsYPcJz9jkdAv8SmXlhXztoy7wExnbKDzu3KDtkXVZ)uj9fyqt3RqnLXQACYLceuxuiODthZftMqQvl03wRN))ZzlU6XjIhjKpa5aAwhkxSOq)pkKhQo9rRRL6ohUoY09mnC2GMmXw96RlSHVRXb93A)rukrvXmsD0TSuo60SyKKoFVjBsrt7A4sMO1SVxzXlcpJfIvX5tDuJ6rjxL66t2um)L0IRWfHvRL(ROtv2ABAvjqsS1YLvBxIYKq)oF2kiHaCyGWk5zgXPKcsbAObPfgnOvRNEdOnBCMK68ptwLq6Ixf)WGA7rNPkoG1Dsqbv5cG)SxKHr0VYdT1ievqrobXHW2mp8rW4ozWtTJUwLHsU7CDeZY6oJmvSR89(NRhbaU1Z7USE(IeGNn76YfIq9tEBUmtMFO3AwWSzWXk)Hj6Eq5u8xOKRhmG2efFjUWyANzsSc4o889OjPHT(m6(m)f5javreQLfOQZJfZZ1mRXsukHCnq7FDdK14hKNsGlfVE)mEOrEW2wv0fm)UOJNDpWnSOdL(aR(2avleUVlBNZoAzzmzKmg8HFDAGzb1r(VPb25ke65p80RmzoBurUZEKi8FlIkS18nVgS4COgaPqq4pDG(mF7kQjqxdcMfneUTwXiHItagHO6H25zDHQleVPi3R7FfYsPW0d3qSsVbjq4hKCxCeuMPoUzplfcxZGHSxd3PQIBV9dSSN10iM06CEZZEkXwQbUhcKnA8ue1Un5AnnVFzAJZEMuTtWK4q3PtQWAC982QLYT8)pLbn9EbgASgWqiLPbIeijOgvxOeZ8oLyqeXZoY1NcAINycruXzGJSIVjh6EqdJWNMrsc0ozOVe2U3hSns0TJa)W1GEtt6fmM(hySm5P2SfC45NNs4yJxe3RggMmmwEa8IW5ezXsqGKA5YnYj6Ks7GriOXKEFb22YBRE5yLFHzBJrmthYEd3DcQMURCPAOyVYadtbzks2wKc9QTctJN3VTJZEi2ohNTjUrUsY2K)2oY2nCo4PsXys62cfeBedDyFICHBmqb356ZrW75vJXWFRNR0(xpkWaUD3qaEpTEmyDnGlDaX2g9jvEa3StWYKx9VKQGDRKhNrrqlw9qk(cP4de7MgTB)SuvaWPLZI6GhIniJIObjdFdHeBOxiJ6jIr(7smMpxTv83MV5VGaIwVA7I6jLvGv(oy7sj2sSKGZjvVWV9QsTlt7T8eFY2bOUhmaSU(hJ3998ovT5HbqeOWpsbukhhzkY6gXIgD)deTH7xcUrLxO0OuEw)niVjmHGPzY4ournSkQt7qnuMF)7XxsEG3qdeLs2ZLhEM1zPXnNWzvBOPl9Th2L6eJ2rRGU6DbQf7SWdWdOVe660yyQW3ajOGnIlocKU4orpdo3St9IN)L(Mo6PBc4Z7Qm2t5j4xypihgqCkBtre6vcdp5JVq3YcxbAZr4jEioyf6f7SoLiFAf6af5b83o4JN0MBDxa8N8Gh8qGAgmmrBBgD1CJJdm2a6)veXWMZdt0XPWIg69sMxOuh)CufspeBl4gE3EvtbG37(2MD)SyJOz)h5vQCO4joY(qfEU2NJ2OoFDiouR4cvsOaLuctxbRhSxQqQXSU4LknZxUqJE66(dE3DRgGxLbSZgeSal87PUlC28w1Q)SogLK6VxOrOPKqj6BwOtEtwu1X)8i9GerWjtnmXjtyxm00XovLlWbpCuZvk7qSQtxz4QbG4OT04ajXjV0h2kOlluvJOGz(e7WCrr3Zn41NLlSCVN1H74BZ8HUDosQ2ON3giwQMlRrI6Cq48cd8FzVRLMBJCJW)w0LPKwvRJmLLtoiXuj1EjvLKnv0MCmu0IKsSmnLQzixfFH)2dEmda6g9dmu0sADMl7A7bCg8Or)cF9haHl488vAtJ8Kvv3UQd98tiNtKvhnXtsfyqXCiRs9nYUk(Urj73o5BZwUQKm38Da3S)S3PiuJKcZLrF4yKOlq3)a)TpWF7BKzV3029QXBCf03(oM04QuzmqnsoBG)2vuGd3kOZO5d83o9O9zS5c9EkB0oWF7fyQTiTN8Az1wCL4g8b(BFG)2TRod83EUO5a)TBFHLgjEXlCd83oJy4a)TFa6Ed83(HUJnWF7j6wkJG0F1IdVSUxXou8mIw4vku8I0omWF7eD6b(BF9a)TxuFi2n4pQMEovPQ8CG)27j)TlXqU9FX5i1YrqArPetEd02(aBslVh8zXM0ujZuAlYr49hftI0dS1USM0b2A)1F)1ldBTx6(RbsAVmRq5E1u2(RVRjP92(HVokSNbqDKXW4fJVkKH4QD3aEbESDMJ1LdZbPEWqzWlgpWNI91Iy9rvbdQvmOYoNUO2bJXFRB)SfZotC4yUbhtwylWZMy4Nwpqm8dedV7tEwPL8CCCpqm8jlecUDnod97dedpLm4)3sm87fbmtqZhk6VWYUv7Oy0CMEpVsnnkc(nbByJPRCE9vQdNZEdmCiOR8FJZN8ynkY8jFV3TKtx5Q87(4xDIgxHZ27fVC)QSOMr04A2j6Xak1VZ8bvLwdsoWTFtq04oRtrTz8enUX1wRpvuoZJShuqzLyNnyXRpWLEYSffdqJPOiyvq7mwEGzYuMXl2)nEYf8S39r0OMPXJHhyS2bV7I3vP4rqH(rwGpVeHeJ5zc54M06lmovPn)EzOKGLJfMMFv1eiW)QZPDjsZJiRjIZplnsUIkvpU0Uw4uz5yvV4PoHqYuc775OHjvWwUbxgPWe5XuIuEAK8sIC4NYhUk2wNs0Qms(cRYAITy9yK0IyoxEjQVd3ywrLlE3fG53GYy8IE4VZWMb8(99TBAJkuryCIDLaUsq5pJExj8845h(bKavW4lDEh9lmI7T(E(TNWegqrdOk3xqeBsl)4TYNTy1iOnFM)Af8Wvilcy4r7gKBUVE5QvDNGI)4JMn9ly2XiTd8H4Vw44Zk2ShwdxIJymMeZT4iyHqjThCo1x42bwLtGCZX62tLOzsStrjVu3)mGVhi7KviFYAUFQ9G3mXmAIDCZY1Ff(XKZHyKPSLXsNWAbIeuIECdcIqkzpYh1r2(wOsaanyY76G6XPilLmot4hea7hptk95hSW6ruRDVsydL67sv0sKwqD6woJyeJgTOPhgwRmYDZWci02IF9HKlWLxQb5nbstncP3r3KaqyX(pyNHSKiZDFXmN08UnpSPLjzsZyaV9dKZPHtkRZxDvYfmZmtVUvrs3ACbJ(RWYdk9ATbXWYoHHTANMlq8drPiRWyJtS0(6nFYpljYQKNiy3tK8e7cm4i2aoPDdDVHbWB9z29ISWY3xQ4j2FuElXlG(3(Zp(Jawhb74GMhfOJvjpnEZYawcl8SU8FKIbcEfZcKn73lZq0HA5P02O3x8PW1OJy62vBcPWn8Bw2uV9XnyXr08PoCiAx5OVvCcSD4VZ9hgzZ5P5FZ4460B)8K7T1eIBAX3UyIPsUMctDsGqnqRB0Ep4p1wCm7AHY3PDAPrmAAebcFm2OS7ba779h8Uahb4rNkv89mPZcF75Cy7QpAXdxZ8BFy9mQuAwWKka5PAyLUcG)nhD0B3heH)eaND95TnI4Tvo08tN6AFLXhAR3YBrtKx7H2NDB0C7AK5fU7MR7EX7U5Fe7L2vnZ)D(Y131TVPT9)T26W56VU(27npMk9Q6RahNN9jQKHkGdT1ZV1OmzQrIPzQziASuhUZnhFfW3jQwMLqY07HhCEZjmgY(ItgfMzGjF6H1BBS8n)ttRFA5gZeMDLSXSzz0Kp84TQXsEQZP7Xc5Q7eGyqAjtHw9)LL2f2Zp3I5m)gOnqjHaIpxz88A7JM3TThB(F)9UXPzvVBGsLr5VHl7h(jE)BedFx0gOUVkuHbxvS116CKh3TcNPWiS0NASdwthhJ1W0Np)ZPKsyfScfTNU8vtqLZuBf6LkU11PNT18Gnpe12ywo8)d3B6CuPNxxo7ivA(QcQPfsze5t8U1DQgbBb936eSne2PDY1BXpRa2UpbBSH5ZMUodQOs0c8p5E2UBS442vVLbfg2fk3ANBHDBJFD0S6BSUfvVL8dMUEM9)K8U8jsn0eQJxqFzFX0vnZthoE(0dno(xnTYxZMBCM9lgLD7UzPXA3tUpVd2VwvoZxAruVPlAEK5pz(dU7izR6XMnnVJ6igGwBN)40AhHV47VR8SFSBkYIXFpH7B)KZNhhtm3xYUZup69nlv9dUZcNwlFSbhjW5)7XDBQ3H4hnrg8Wx(00OlX9AjKvZvvMwTUlgOjZESjeOtp8SJW)PyX5Hwm)3T9ZUfq8EGMwz6flxzNCTY)Myqs8UAp9(NZmsvMjgXzJc8mLy2iwdLhc3S5OcPsTTM3wg(WGQPmmpaX7mWEf0VMeMcHQbOIXNQjm8edSr0eNcH8QD3msw9pVY4fSDNj0VUMOr1enXDIuDc2)LGZxTs0Po)TXcXjV)H)O1FlJiU9MK0PO3SIwN(InsBRMBtbBBL)S7MF5N)PF2Ud5)67ip9q9NTAxx0gB3YBT9M1ZwABVP7ymqTz(0zEfWo)iw8v3glZc(YFD5STw3kIJnxVFX2nBRNBMXEyX(fxcChJQiRI)y5TTmrwjYYG4DYjYostKDKUilhf)L3Ocfz9fi3(f(GSJ9Npz0J3cYNa6Q9GZxY65SF2Uxv9Dt82e8z756ZcoOWK)wyEF(dPTeNptCkLmFuVRgzjvQLADjYPumdETqsf2gNU7dae9cvRe7bBhp9)ECATyiSfF5Ke8S8HcvHaVIlc)eNyOqfhFwIJJcnYRUs7y7DdO2dxCXQT1U73M0SmcqvPcCTqKBD6NqaNc2ohtEZj2BqnlqbmM2hbZLEwIfHpoTdJYgqLw2IX5Xv4glK)8uFBpK2hynfgoXTmz9yAG6Oc8vywQYqDNaiBePyIuDaKjcIemK8ADuGKccym01MBCOKJjdvuq1xiL1hWM2pWoEOMPO3wjbDQYW(k7v95AeLQXFOe9EtLGEcbOp9gAaDmfWeaOHGspcg)MbvjcfH2EoOlqGJhjKfGyMclZTJL6jcxZHXDKkO)QiyIj)TSVM4JndmlQEQb56w)KqkWbl5Q1NWZXnfuYDxcRKlA342JLuEpqOuw3NptnGafCFmf4lt7HLSHACPajGSj33a7nybFcCX3XBGTv4y6e7T9)eZUmtO6uwF(02612b6twFz0oqy4Skf0mumsUhMJYrjyLu4bhxqXm53kiCdVG02YG8EOUabNNkpmcX7ejvKovJjAe84GcBgA6MvmnredChVvOIHPCHl)8vba3IBTxhYGYlxvL6QBkezfUdQvC1c6t6rCgfQk3OdZ2mOp89xoqWXypkROcKfLQIlsBNeSTkd)n5xc065qAt9wQJiQnZl)N96qlOSxafwjv0tkz0(mqkmUkaE1W5vxFNrJU)8PP1IHYELPXO0e)NA9iz3n)t)j(SzVoHIwKLrDhIvL5XkzT9MQB)339RYmcEyqBy(NJRLJ9KCrUPagLKcEFN4pgUsLpPBNnXq(QDfCxQcY3jKLmuOycHmirkTEmu6BwtkKWzh5v7OVLWWEkPGtZxIolFsmuYfhSha34lQvOKkk6YSkk6uHH3jDpoiU25xp7B8Cic)K9wGSUT0TkDssRP77e63MLUhGvxjZVAe)VIbnxclgjPMs6kL8ic9Z(VrwMi6MmuJ3394P1bWD0saCDiDluzveg9bO8q1()L7kHZSrLktEuvkLs736TkF4vBjnurnygL)Qa7vS)3cBPAoZNZXobf0Xo1m49)LC8AKEhflNw5oaE)(wQo7H7UZmBKCWXvmAnY86K2P0dK745JwpcwMSCH(Gap10EaCIjWwEVR6HuDOiAWkzCrUpVYwj)IWrPIALXDuYAs3KlOpjDyNwIzg7quFI40INhorDJ5OZyJ(f6T9F1HP2D3CTTrEmnCTTzEq2Ab1ac3fF4hBVSgEY4jYCNwQfZR9qlYcFch6JcaWW((YsxGW5veuQL4ZiTATGT0CwkmrNenQ1CB9iuu(E82TffZVBSQD7Y3J5vyZ3fE)rm4zYqvasXKbQmoRQGkmJ97TiFwkAPkmF(8RSxZuuurjX)mW20fYnzChy8libsuJWcoKcASk4FAwPNaAtxOjeL1oWmM)zLKtrT4ehVR7cVJmp)mN3YEqeqvcIEkKeK)Ovoa4f5OYwgKJ5yCqglhxhTE)M)aK))0mSc4Nv1N1UWc3VIkGG8R3bClsVzkabVq)gSIDrOb2HYZGNltecnZ5Cvr)2XHlxDQE0i(E0ONrpc8B)FT312UTXrm0VL8YIvXiOXzJAZd2(L(FKahBJ2a00uejJG2h83EL2lZWBhsURKCTtZtjWA1Qz4WHxo8mCWJOvODQp922iXja6EmYr8yayJtp7d)xJVhnIZhjOtqNDvePaIGi)2lLbrqOVmwfPy)mxA2aNwtRuSQrE66Vron8PMuOnw)Dq3juaGUo)bu3CkQwLYK3M9jeyQBh6x1YfkAPFTSjHrXlW3)Z6OLVRmvvlFCe2lcMjvEu8jrK9voZBD1PGShEfIbTceD5ABN1P)hO8QkaqqxcywPrOE5nNYcraM4btiNg0KXnHAITanW0b8hi4GYdRa7fWYUCpT07zwHOAxzb8lgQrlmkx5UsUpsLCDKFsSlFxf5y2z)tSWlZoShh5b9WlkFaCjNMNJKlnBjwyyzmuzRjSEO6Rw68SHQZmjiEh10Cfl2tJDOvjTGduoTPeR3ff4kvVBEwD6RrvUeaBy0DFs310p8(MeXQZKhDJlQKyKCxJdYah84PZbkDZNUPT9MzICVNArhogQiy2CAkBtaAB1s3yRwBUz3i8Z7vH)4xVF3F7tBLlBN(M0whoykFLgr1RhgBtnD5F518gjVDx16vw6T7BFwdnrM1olC4iMQIxC8Ve2UAR33HdeAgr9LnC3MiYHAeQwxaZkSBvsHOAFmWt)nRTN6jj(c22AhJNzy6J1fuT6F0DWUZP7G1fGpYZnPNLiITRVCWj6cGkzj7PkMAoNE5URUlu22FSw7Xr50FRrqYSs2MVgg3J4uwnFloXTYk)oGKzFh6C73(wh)TeD6ENABp7FCcNnytsvQt6rujjWAxq7d0gP84e35n0OEbmz7OvT2O3baJVaSUwHtiOZAOzn38bpViGGaKNaFk5lHNCFkoZdvl5bQAZm)XEa2kQBa9TwcERdraUZYXT3C9MTIvMnBV)2D)BFb)39nUBFP5zbpeA4k7lQL(0ZMMmg58Y29h91Kin6acBBkvd2lKONWGYFGiJ0yh9T0ZEP1m2ZORf7f5Yk34M3qyvuGkhP6S26uB0LvpIR0vhT1hXGAQhbpv3dSQFdmdA9lt2usPORa)oGTVHhAftO4DWBt8lEIRG)8mxgTpEF4mVl3JQQnUZ2(9jGvRB1lsAvBCVz)K38jv25r3dTxrWOtRtHGXi5wzM7m9ZpAOI9HMoZLHluPV75CN9bSOWs7YyJ)7DltDEYDKigiymcWPK)GddLNJiybJtuZehNrygxW5I9sfxKuPfUbM9nzkNHMi81tzA(RJwEndUZYK5h)7nBU(p(WVD9)ChDZsKTYdjWZRe1sLno12vdsuiimzCu4WGxXrKgKoDIK5AIW37Ir5HZzyYCGhMpo3a060ozJ8Sp5gW)q7pUg)NSwBYkU8Wm7wOvBsg4IZceo1)mZLMyPsgNy6sFfU0NAZV(KbHfehDkCKKp94We9XrQnscvUB0Aoo5BXUw2cTpNjUSc)2LcxtPaCs(wdEgfRZaFD9ZXAkxUgRMeXPOZ)lnAEjv6kD0BgppI6F6M3sA9PFg45XqwvB0lyCcBrqdtmGJRpsDBYN2ShEWDRI)1xVtuCkF0bxLq2BniVSu(1CCqkyKu8IiW5uLsqb1If8Ygd)WTEnom630nx4o(f4m5O7RWHe)E3SC(0WoH1jlMOfh03cwzzOBU0iNvb2ljds3Yck1UsIENPJeXzFwjp6id(rlNOAxzUm2iHz4WVM(agykwbJg)xLGFO0uo6NPUWJr0sM59Ka)jK)iYKb18zIukDMT4(nXbvs2bYC5NRXLlJpaVfZlFO0a99m1jGOvPnfcALCMuGL62V8LpltWZ4c(dJVHVDjTqCs2MGX7KX7n7)p9ujPNSNP8GitPoyDG(OcQmny42Ijt((ed7lyEZEuJcYZUvp3ukBNYvzsYwhctaJofbo7Ao05gWgZffE4efX50UQxXDdLEZs59JaVTzjVSm1PkvkxREK1eCHoiA6zqm0Zsk9Ez269VaP2s5faj9cx2Tr0qu0KJpsoCUfyg8u1J8bpCHi)5CCyY7umzRZBiJPNyxWUoNrf7eD9So65)15iHedfYr)QMfNW086BE6qr1rtx0zYfTJRqeNnxUGy()8nxACxR1q6mP9XcLYLu4TJ4Y9tkoj0utcjBrXMzF7dR2(CJsGoAR25l2CieQ05ib89IeYgFY38Uu81DG7JI7gdSY2mtEUoagVMnCjjwr(v6VAJbT)IeWMgtR8zxf8LczavBS2aOXgPCWphysP)Zsf)vJP98ujdj11CA17lIHb)xo3aEWKT0nDnfavdaBJoHRBN0vnQ)PbAde7kLMwORhtSrr)H7bxoh5KXQyUAZOlR2Xlu1tQxCjRVjyQRbM4Q5Jv5Yhhkgqo4kR4bLt3lg28YNRaXViBMj4nC25Fgi1QLZBjTy92W6gqLRY906Hp3Xsyxn3mBDiXkN9lVmbNjX)L2W8JQkW82WyFLhe69HSKI7DoG8VBK8yErC5dhKRcERoOK6cSM4ILnIE5IxfVM9GNJ(f5cSFS77GjuQLWdKzun8VSnYQ2wBDQcB0(cF7a9FeljG(cHKqkLAtBe0O5GT0TSmXzLlR7UL1evecAUCP3KMA0hSN4b3IVhC8495RADOfWJV41rOsMYWPeF0ayfccsRnHaMyjKVo7jyXHMgMc44dCCV7vCQWG8E7jvTLIyHlM1KmZobmfeZy(Lf0u4UL6WK9thaenybzq1jL402bzmUZ5nnOJ)0Oi3aLYPGJ3n8Kf1HMV2RH13YbB9i3llq8bgdy3)(zlIQNL2upPetb2hgWj3YMMa103MfE1KNRDfmSjUhpWxlk7)A3V933FB(UZOZV2)xE))c]] )