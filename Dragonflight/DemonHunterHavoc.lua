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
    aura_of_pain             = { 90933, 207347, 1 }, -- Increases the critical strike chance of Immolation Aura by $s1%.
    blazing_path             = { 91008, 320416, 1 }, -- Fel Rush gains an additional charge.
    bouncing_glaives         = { 90931, 320386, 1 }, -- Throw Glaive ricochets to 1 additional target.
    champion_of_the_glaive   = { 90994, 429211, 1 }, -- Throw Glaive has ${$s2+1} charges and $s1 yard increased range.
    chaos_fragments          = { 95154, 320412, 1 }, -- Each enemy stunned by Chaos Nova has a $179057s3% chance to generate a Lesser Soul Fragment.
    chaos_nova               = { 90993, 179057, 1 }, -- Unleash an eruption of fel energy, dealing 2,211 Chaos damage and stunning all nearby enemies for 2 sec.
    charred_warblades        = { 90948, 213010, 1 }, -- You heal for 3% of all Fire damage you deal.
    collective_anguish       = { 95152, 390152, 1 }, -- $?a212613[Fel Devastation][Eye Beam] summons an allied $?a212613[Havoc][Vengeance] Demon Hunter who casts $?a212613[Eye Beam][Fel Devastation], dealing $?a212613[${$391058s1*10*2} Chaos][${$393834s1*(2/$393831t1)} Fire] damage over $?a212613[$391057d][$393831d]. $?a212613[Deals reduced damage beyond $198013s5 targets.][Dealing damage heals you for up to ${$212106s1*(2/$t1)} health.]    consume_magic            = { 91006, 278326, 1 }, -- Consume 1 beneficial Magic effect removing it from the target.
    darkness                 = { 91002, 196718, 1 }, -- Summons darkness around you in a$?a357419[ 12 yd][n 8 yd] radius, granting friendly targets a $209426s2% chance to avoid all damage from an attack. Lasts $d.; Chance to avoid damage increased by $s3% when not in a raid.
    demon_muzzle             = { 90928, 388111, 1 }, -- Enemies deal 8% reduced magic damage to you for 8 sec after being afflicted by one of your Sigils.
    demonic                  = { 91003, 213410, 1 }, -- Eye Beam causes you to enter demon form for 6 sec after it finishes dealing damage.
    disrupting_fury          = { 90937, 183782, 1 }, -- Disrupt generates 30 Fury on a successful interrupt.
    elysian_decree           = { 90997, 390163, 1 }, -- [395039] $?a388114[Chaos][Arcane]
    erratic_felheart         = { 90996, 391397, 2 }, -- The cooldown of Fel Rush is reduced by 10%.
    felblade                 = { 95150, 232893, 1 }, -- [395020] $?a388114[Chaos][Fire]
    felfire_haste            = { 90939, 389846, 1 }, -- Fel Rush increases your movement speed by 10% for 8 sec.
    first_of_the_illidari    = { 91003, 235893, 1 }, -- Metamorphosis grants 10% versatility and its cooldown is reduced by 60 sec.
    flames_of_fury           = { 90949, 389694, 2 }, -- Sigil of Flame deals $s2% increased damage and generates $s1 additional Fury per target hit.
    illidari_knowledge       = { 90935, 389696, 1 }, -- Reduces magic damage taken by $s1%.
    imprison                 = { 91007, 217832, 1 }, -- Imprisons a demon, beast, or humanoid, incapacitating them for 1 min. Damage will cancel the effect. Limit 1.
    improved_disrupt         = { 90938, 320361, 1 }, -- Increases the range of Disrupt to 10 yds.
    improved_sigil_of_misery = { 90945, 320418, 1 }, -- Reduces the cooldown of Sigil of Misery by 30 sec.
    infernal_armor           = { 91004, 320331, 2 }, -- Immolation Aura increases your armor by 10% and causes melee attackers to suffer $320334s1/$s3${$320334s1/$s3} Fire damage.
    internal_struggle        = { 90934, 393822, 1 }, -- Increases your mastery by 3.6%.
    live_by_the_glaive       = { 95151, 428607, 1 }, -- When you parry an attack or have one of your attacks parried, restore $428608s2% of max health and $428608s1 Fury. ; This effect may only occur once every $s1 sec.
    long_night               = { 91001, 389781, 1 }, -- Increases the duration of Darkness by 3 sec.
    lost_in_darkness         = { 90947, 389849, 1 }, -- Spectral Sight lasts an additional 6 sec if disrupted by attacking or taking damage.
    master_of_the_glaive     = { 90994, 389763, 1 }, -- Throw Glaive has ${$s2+1} charges and snares all enemies hit by $213405s1% for $213405d.
    misery_in_defeat         = { 90945, 388110, 1 }, -- You deal 20% increased damage to enemies for 5 sec after Sigil of Misery's effect on them ends.
    pitch_black              = { 91001, 389783, 1 }, -- Reduces the cooldown of Darkness by 120 sec.
    precise_sigils           = { 95155, 389799, 1 }, -- All Sigils are now placed at your target's location.
    pursuit                  = { 90940, 320654, 1 }, -- Mastery increases your movement speed.
    quickened_sigils         = { 95149, 209281, 1 }, -- All Sigils activate ${$s1/-1000} second faster.
    rush_of_chaos            = { 95148, 320421, 2 }, -- Reduces the cooldown of Metamorphosis by ${$m1/-1000} sec.
    shattered_restoration    = { 90950, 389824, 1 }, -- The healing of Shattered Souls is increased by $s1%.
    sigil_of_misery          = { 90946, 207684, 1 }, -- Place a Sigil of Misery at the target location that activates after 2 sec. Causes all enemies affected by the sigil to cower in fear, disorienting them for 22 sec.
    soul_rending             = { 90936, 204909, 2 }, -- Leech increased by 5%. Gain an additional 5% leech while Metamorphosis is active.
    soul_sigils              = { 90929, 395446, 1 }, -- Afflicting an enemy with a Sigil generates 1 Lesser Soul Fragment.
    swallowed_anger          = { 91005, 320313, 1 }, -- Consume Magic generates 20 Fury when a beneficial Magic effect is successfully removed from the target.
    the_hunt                 = { 90927, 370965, 1 }, -- Charge to your target, striking them for 24,488 Nature damage, rooting them in place for 1.5 sec and inflicting 26,387 Nature damage over 6 sec to up to 5 enemies in your path. The pursuit invigorates your soul, healing you for 10% of the damage you deal to your Hunt target for 20 sec.
    unrestrained_fury        = { 90941, 320770, 1 }, -- Increases maximum Fury by $s1.
    vengeful_bonds           = { 90930, 320635, 1 }, -- Vengeful Retreat reduces the movement speed of all nearby enemies by 70% for 3 sec.
    vengeful_retreat         = { 90942, 198793, 1 }, -- Remove all snares and vault away. Nearby enemies take 942 Physical damage.
    will_of_the_illidari     = { 91000, 389695, 1 }, -- Increases maximum health by $s1%.

    -- Havoc
    a_fire_inside            = { 95143, 427775, 1 }, -- Immolation Aura has $m1 additional $Lcharge:charges; and $s3% chance to refund a charge when used.; You can have multiple Immolation Auras active at a time.
    accelerated_blade        = { 91011, 391275, 1 }, -- Throw Glaive deals 60% increased damage, reduced by 30% for each previous enemy hit.
    any_means_necessary      = { 90919, 388114, 1 }, -- Mastery: Demonic Presence now also causes your Arcane, Fire, Frost, Nature, and Shadow damage to be dealt as Chaos instead, and increases that damage by 29.5%.
    blind_fury               = { 91026, 203550, 2 }, -- Eye Beam generates 20 Fury every second, and its damage and duration are increased by 10%.
    burning_hatred           = { 90923, 320374, 1 }, -- Immolation Aura generates an additional 60 Fury over 12 sec.
    burning_wound            = { 90917, 391189, 1 }, -- Demon Blades and Throw Glaive leave open wounds on your enemies, dealing 5,909 Chaos damage over 15 sec and increasing damage taken from your Immolation Aura by 40%. May be applied to up to 3 targets.
    chaos_theory             = { 91035, 389687, 1 }, -- Blade Dance causes your next Chaos Strike within 8 sec to have a 14-30% increased critical strike chance and will always refund Fury.
    chaotic_disposition      = { 95147, 428492, 2 }, -- Each time you deal Chaos damage, there is a ${$s2/100}.2% chance to duplicate $s3% of the damage, up to $m1 total $Ltime:times;.
    chaotic_transformation   = { 90922, 388112, 1 }, -- When you activate Metamorphosis, the cooldowns of Blade Dance and Eye Beam are immediately reset.
    critical_chaos           = { 91028, 320413, 1 }, -- The chance that Chaos Strike will refund $193840s1 Fury is increased by $s2% of your critical strike chance.
    cycle_of_hatred          = { 91032, 258887, 2 }, -- Blade Dance, Chaos Strike, $?a393029[Throw Glaive, ][]and Glaive Tempest reduce the cooldown of Eye Beam by ${$s1/1000}.1 sec.
    dancing_with_fate        = { 91015, 389978, 2 }, -- The final slash of Blade Dance deals an additional 20% damage.
    dash_of_chaos            = { 93014, 427794, 1 }, -- For ${$427793D-($428160s1/10)} sec after using Fel Rush, activating it again will dash back towards your initial location.
    deflecting_dance         = { 93015, 427776, 1 }, -- You deflect incoming attacks while Blade Dancing, absorbing damage up to $s1% of your maximum health.
    demon_blades             = { 91019, 203555, 1 }, -- Your auto attacks deal an additional 992 Shadow damage and generate 7-12 Fury.
    demon_hide               = { 91017, 428241, 1 }, -- Magical damage increased by $s1%, and Physical damage taken reduced by $s2%.
    desperate_instincts      = { 93016, 205411, 1 }, -- Blur now reduces damage taken by an additional 10%. Additionally, you automatically trigger Blur with 50% reduced cooldown and duration when you fall below 35% health. This effect can only occur when Blur is not on cooldown.
    essence_break            = { 91033, 258860, 1 }, -- Slash all enemies in front of you for 22,729 Chaos damage, and increase the damage your Chaos Strike and Blade Dance deal to them by 80% for 4 sec. Deals reduced damage beyond 8 targets.
    eye_beam                 = { 91018, 198013, 1 }, -- Blasts all enemies in front of you, dealing guaranteed critical strikes for up to 46,070 Chaos damage over 1.9 sec. Deals reduced damage beyond 5 targets. When Eye Beam finishes fully channeling, your Haste is increased by an additional 10% for 10 sec.
    fel_barrage              = { 95144, 258925, 1 }, -- Unleash a torrent of Fel energy, rapidly consuming Fury to inflict $258926s1 Chaos damage to all enemies within $258926A1 yds, lasting $d or until Fury is depleted. Deals reduced damage beyond $258926s2 targets.
    first_blood              = { 90925, 206416, 1 }, -- Blade Dance deals 17,893 Chaos damage to the first target struck.
    furious_gaze             = { 91025, 343311, 1 }, -- When Eye Beam finishes fully channeling, your Haste is increased by an additional 10% for 10 sec.
    furious_throws           = { 93013, 393029, 1 }, -- Throw Glaive now costs 25 Fury and throws a second glaive at the target.
    glaive_tempest           = { 91035, 342817, 1 }, -- Launch two demonic glaives in a whirlwind of energy, causing ${14*$342857s1} Chaos damage over $d to all nearby enemies. Deals reduced damage beyond $s2 targets.
    growing_inferno          = { 90916, 390158, 1 }, -- Immolation Aura's damage increases by $s1% each time it deals damage.
    improved_chaos_strike    = { 91030, 343206, 1 }, -- Chaos Strike damage increased by 10%.
    improved_fel_rush        = { 93014, 343017, 1 }, -- Fel Rush damage increased by 20%.
    inertia                  = { 91021, 427640, 1 }, -- When empowered by Unbound Chaos, Fel Rush increases your damage done by $427641s1% for $427641d.
    initiative               = { 91027, 388108, 1 }, -- Damaging an enemy before they damage you increases your critical strike chance by $391215s1% for $391215d.; Vengeful Retreat refreshes your potential to trigger this effect on any enemies you are in combat with.
    inner_demon              = { 91024, 389693, 1 }, -- Entering demon form causes your next Chaos Strike to unleash your inner demon, causing it to crash into your target and deal $390137s1 Chaos damage to all nearby enemies. Deals reduced damage beyond $s2 targets.
    insatiable_hunger        = { 91019, 258876, 1 }, -- Demon's Bite deals 50% more damage and generates 5 to 10 additional Fury.
    isolated_prey            = { 91036, 388113, 1 }, -- Chaos Nova, Eye Beam, and Immolation Aura gain bonuses when striking 1 target.; $@spellicon179057 $@spellname179057:; Stun duration increased by ${$s1/1000} sec.; $@spellicon198013 $@spellname198013:; Deals $s2% increased damage.; $@spellicon258920 $@spellname258920:; Always critically strikes.
    know_your_enemy          = { 91034, 388118, 2 }, -- Gain critical strike damage equal to 40% of your critical strike chance.
    looks_can_kill           = { 90921, 320415, 1 }, -- Eye Beam deals guaranteed critical strikes.
    momentum                 = { 91021, 206476, 1 }, -- Fel Rush, The Hunt, and Vengeful Retreat increase your damage done by $208628s1% for $208628d, up to a maximum of ${$s2/1000} sec.
    mortal_dance             = { 93015, 328725, 1 }, -- Blade Dance now reduces targets' healing received by $356608s1% for $356608d.
    netherwalk               = { 93016, 196555, 1 }, -- Slip into the nether, increasing movement speed by 100% and becoming immune to damage, but unable to attack. Lasts 6 sec.
    ragefire                 = { 90918, 388107, 1 }, -- Each time Immolation Aura deals damage, 35% of the damage dealt by up to 3 critical strikes is gathered as Ragefire. When Immolation Aura expires you explode, dealing all stored Ragefire damage to nearby enemies.
    relentless_onslaught     = { 91012, 389977, 1 }, -- Chaos Strike has a 10% chance to trigger a second Chaos Strike.
    restless_hunter          = { 91024, 390142, 1 }, -- Leaving demon form grants a charge of Fel Rush and increases the damage of your next Blade Dance by 50%.
    scars_of_suffering       = { 90914, 428232, 1 }, -- Increases Versatility by $s1% and reduces threat generated by ${$s2*-1}%.
    serrated_glaive          = { 91013, 390154, 1 }, -- Enemies hit by Chaos Strike or Throw Glaive take $s1% increased damage from Chaos Strike and Throw Glaive for $390155d.
    shattered_destiny        = { 91031, 388116, 1 }, -- The duration of your active demon form is extended by 0.1 sec per 8 Fury spent.
    sigil_of_flame           = { 90943, 204596, 1 }, -- Place a Sigil of Flame at the target location that activates after 2 sec. Deals 1,074 Fire damage, and an additional 5,043 Fire damage over 10 sec, to all enemies affected by the sigil. Generates 30 Fury.
    soulscar                 = { 91012, 388106, 1 }, -- Throw Glaive causes targets to take an additional $s1% of damage dealt as Chaos over $390181d.
    tactical_retreat         = { 91022, 389688, 1 }, -- Vengeful Retreat has a 5 sec reduced cooldown and generates 80 Fury over 10 sec.
    trail_of_ruin            = { 90915, 258881, 1 }, -- The final slash of Blade Dance inflicts an additional 5,789 Chaos damage over 4 sec.
    unbound_chaos            = { 91020, 347461, 1 }, -- Activating Immolation Aura increases the damage of your next Fel Rush by $s2%. Lasts $347462d.
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
        duration = 3,
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
    immolation_aura = {
        id = 258920,
        duration = function() return talent.felfire_heart.enabled and 8 or 6 end,
        tick_time = 1,
        max_stack = 1
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
            if set_bonus.tier31_2pc > 0 then action.throw_glaive.handler() end
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

        talent = "consume_magic",
        startsCombat = false,

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
            if set_bonus.tier31_2pc > 0 then action.throw_glaive.handler() end
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

        start = function ()
            applyBuff( "fel_barrage", 3 )
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
            removeBuff( "unbound_chaos" )
            setDistance( 5 )
            setCooldown( "global_cooldown", 0.25 )
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

        -- usable = function () return target.within15 end,
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
        charges = function() return talent.a_fire_inside.enabled and 2 or 0 end,
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
        cooldown = function () return ( 180 - ( talent.rush_of_chaos.enabled and 30 or 0 ) ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 ) - ( pvptalent.demonic_origins.up and 120 or 0 ) end,
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
            if target.within8 then
                applyDebuff( "target", "vengeful_retreat" )
                applyDebuff( "target", "vengeful_retreat_snare" )
                -- Assume that we retreated away.
                setDistance( 15 )
            else
                -- Assume that we retreated back.
                setDistance( 5 )
            end
            if talent.tactical_retreat.enabled then applyBuff( "tactical_retreat" ) end
            if talent.momentum.enabled then applyBuff( "momentum" ) end
            if pvptalent.glimpse.enabled then applyBuff( "glimpse" ) end
        end,
    }
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 7,

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

spec:RegisterPack( "Havoc", 20231105.1, [[Hekili:D3Z2YnUnw(T4AQWwYUTcjLKDNPSvQz6zNztQDZm16m7JMIwIYMvlrQLKYDCkx6BFpaGGe3oauuYD6KxsClcEW5(naqCFW9)893TmUk5(Fk0pCCqG)0rbtdUo8Q7VR6LTj3F324fFk(r4pYI3a)3)Z4NZxq(1xwNhVK82L57kwap5U0n7whxLMN9XI4vv3F3d7sxx9dz3)G5zyk8QBtwC)pn96RV)UNsxUmHn2KsyciJ9YGGl9N(N3p)FfxT4P9Zd8hfoA)pU)hPp0)6ld(a8W9Z)Fs2K)CYY9ZlswUlBzCw1(5vfPzFkb(JKm4ptkLFVP1V3ZXB2UF(QI8n7NRG)YVqa9fAXJGrt3pF3wcDjnq)j0b(xwcyt(wcWaujF)8F(PI8pVF()yDC6Zj7N)50QNY3by3FDD8s4F)3IZwa)pYO)4FtaGxDzidv)lRxtE)htYsksx0qELmO)iHqlswKVzts2scNiF1Ql)hkGYFmfu)35emOfaPWKUmzv8U1aq2wKMxKw9IWlo9YGq6l(ZCwkJUlfyCFuy8tUCSpD8)B6Wwkom4VZlQzGTVr4LHxtFJFy1(5)9K1GKzxjWNJZGx()nj7XKv7i)ysvrsmm)XfabSmTm(H1eWpa0y2MwLqinG(R2TP(v)54fvPlIfF1hssZEeO(41Watwo89WF)uslDtenRHxiMXV)pkltOsM)k86FIXSFirIxlrh1kK)tQKVKmUhJlwsNYoqxFoPGc7NtljWD()mB9l143kaRsk(wIEoHefWG46PArCgd3Q2vKvRcaIQs6KtTAFhmkIfxA860FnMPBwMuvbJampicyYmvBVayzzzomwQeKOVcINY81S)9)Qi5L33YVH)8FN9q(ocD9XNIZlHF4hYsRG3gu3FpofVj(fcV(ZXVuQXybnZveQpVmHlWkRL9LjRtwaiYiWruroWBa3peznWigTLcIhIRU42V954IuIsY7j(UUT6PIKKOnPzr1k)V)5417GFN9VavYf55RxM)5Srl3vqzq3g8b)xFLpGqZdy)p2H5MbIOYxYwevUoNp3bVpDLac8uCzuzvC1O4SxIwUT0BWzTtU6dBrmdy(SBTG1dpguoueL1XkbuwNESYlNzHCqW44cqTpjQkVOaupii2QDfVmcCNLUiTAwWuZV2UYKiWHXggHgVg8F(uCr02D)6VUoj6H8FHaPgCytsv8M8ITGMyA5OIKnXPzL3Ga6Y0htxhLVkA1Aa2e4CwY)3U0TBbTvdtKzGKUztoluuumWaiEyQh2TGBVIDBRA(by0lG)3UnGMD8JqOHF8pPgvHz8(3tlkPbCYZx(EIZ8401eNeeNsPzWVqCmtSjdVGyUv8ij4GWSiRC8azgIwsMaUve1cD0kY0e9azwaHn73QiZfHNuaZuZVUG4Oic8ULx8I3d7wTs6xgry9V(k4VA96OA0zKWSgmlah72cIoWRweeSjsht5JveCEe9MBgC90lRXULqofzSxU88q)HEnQdcVvJYWJlwoAt8V0nmk5fq0NeVrMXrNW0fENv)VFag)YicA1o183SzEhupXNpEONKM)yFCC5ZXPvCCzd3dUeUW)vVZOYf()C0UTnsVuireW)E9iQ)xWaWN2NaIGmTeZP6PBGcTx)ptyrDJEGe0DOxJ8sZbU3Q0hFQkQMBmZUf7fJ9VOEckFkUQcc2UmcKUaV4LZVY3ZH9EORrmJr4TcPKFjzXUkW7u6MKl4cQbn8pGLfrj8lcbVB)jWSTLZLM9C(NsIs(falZIxhryYCfjilHO0SvqKDiaUa3wXPb1lnBUkG83b7YepYGFgaBwYgie)SBh7nWMA9RVUmHkELeiultnmUIKGB0J08BfM6YKIcskd1pXBatHYi)JZIUYBq98Q821(eqEixq1ATiH1CTGPE2ha3w(8WHU4oDgqGvdOdCJ)OPd9qzPEmVCJidfIOfTmnPHL8HEWQX9A0GyEoyLdcVWG8Ia0ZVYj3b5n7nhOtQ6XrefDW(OmDzINIVk60UJLOAenydBAHCsxdorGFbMEQ5QolshBfrOvjaaGC7jyIHzz3wVANdky(i2CwEBhNhi2y0t7yz6qXZaFgvTnNcEz)V4Sjohzqhusmkj3TDyxTJgJY3LcDq)LoXeCtwyt4adsA7uXRVEM5Gs4kXMCXXCCzX33v2tWGG5q(jxpvWPJL8qopC4HPDoWWpBqrq3(SdZOjzJKq3mkHQzEX4z4yRlNsisBqD(WyyojktAbK0NSRUnlWxcrwed6RS)z060YkwoaCy4EKK5hc3VSHquripCDsUOvjRHBgRg6FB6IpfTBB0kipdsIIVN04WBPP2qMxwM0L57w3mIYz(2C9CLvtfigkZ0BdnxiAsC8zObeJbqKxwkNG4nbx7e33KVm52SK4ciXqgHSMiPk0QT82jtHsDnreXlF51xP2RJLLMXzzPpLYCD1ireseusT3Sm5wqOC(yPKSR7QcqK0MQ8EsXT5RwfbJK1EbCgT)OXD1lEOhXQF2uAzgqMJ(EKN0cOaftIddfBExEpJmwkadfcevDmBen1LDwJU9GZKlbbjyNi8uyIWSDXGa)Z5v1(YI1eIlckXa0nhoeYtIgNzS)RVkWYUm4gOOYMPVLYRXG2FqfNzjtoBYWFFWIbnNboOiVZAkXtSirlzWERaN0BqrC6YOKNP5)TCzjmtZgmX)sZsKZdMoKvS8mIi5lH8hjDKgjnV25JwIAmxLgr6GZuLdecBBrYZeyoka4bXvpfv(5Keu)qTH(i0rv6cOu84SYv5fBy9PZtdRCLyqt3fsYOn0VoKe)x1vNCOwquOWZoZw6bDldMg8uT1hijY4otavnkKAfKYBfNlaEgob0VyLgwY1TUiebQXCqBYqS2i0HgnJ)o41uAAXyM)pE(NbeVOwqqUjbyWNMVRm6X4FL7Iv8NOsKYKkavY2vcz4MumoiAY2fqT7NP87(rHWVxBwj1NnjeGW5gOG8ltktjzSu3qZxF1anpXFyNAtYyRoLedUurWcibrURKA6x9NzT3Jjq5OGQxOi(kqPzx6pAADKjxnl92XJcoVjyMH00UsKNk4uIWrn282bgD85kc1mHo9WuiaB(hIliTlZyf(1pJGg9qUcPmjMajPHIgKYQZlRJmrvq2UKms7PoLDRenBSGoWqoOKzn6P29C0LOfDiAG5akt7c7VPx99tMBpneVZmksiXmC4oDSfW6YxSyIz9YUPbabJMo0SVkH0BS6eRn)ls9wKkTObDskiznBKaBFdXuMBqyv)vnt4ubxBAQQ1ORHcgNkQmiUusOUIW9jdOGTiGUwEbZD2OzbsnKkRPiQCG4P)SBcjItJgLgIncXaf5n6R7zn2qw53njqoIrzjlabCCXlwsprXg72jY5KyUX3qH)LlIl86JNr9ocEX3n0tAzhND7GWlvsJGIkL2SGT0u5XMC4QMLHgh2qBpv5wHSLX8A)U1ivvx4TLHHSaQUkleTBPDtPYxLKH3Go7gA(IVxF0VAw(Yd6TSRNlJyJTHy)EvzUp6MmNSkLWuc5C(PBm(iWWiI(42Os81TuZCPl8IaEFcZ3vr37bXz16DE1fcRwPwR2R0tivMC8RyGL61KG(WdrhPbMIdCKTf5W0Alys4A2I1ZShcofj1pA6E5OSQi9tjDZ3IDy7ozrDltJAfEA2RM1s6SFOo96nPXEMsESEIbTR3VjEyTvg8)YxVq5O7nvLrZ13qSDsfa4DI60OIpuUSnGEkJEiTk59Su4QnwL6D1d7kYis6ptqiUdyPFSjPZj8CdwMR8E3mq2d33pgTLtAC)ZmX(LbxWBgx)lK2RGOOJfxHuX0TH(yaOHvSmfCIdQe0oepqh5irtuMn7T9uqQj0PttZNnpNdmiNRlqrb9SegejCcs0Xg0Pz3mc4LuQ9I0gFlqnOj6N5gSARPpKTPwpIuELVXAFGQb6gjOsb2ja8aH2jnaUMk4Y(cIZRZCicfIVHWU2hhrT2ElKYlnYkz7AJMSLmx3x4uKfLaVGr6kqAQXA(8w0rwVow5WgrSK1VuMgNb4)IIKK(21PX(w6eTX5vEJ5Ujg0NIESinzvvEXIN0xcekSX7rjlBpSLFAMLnDJJLfLRxv3e4jQ9KM3SbpR98(1xLepFZ3ee6FdPTqcRjdsewCMMPDZm(scJVkZ0kvNQJIFWNeRt)xVjmeXiRdiDAr6YeOsKMLHVVymtGeEcq7WoG2LGAjuIh45acVMdwYhiA36RKhlKBQRe6LSPhuTadmx2Ze)UOLaUZwabcbfwYc98qYl5zl7N5fUjeQAmq2nMfQsEJhQH2OagpabcX)6aPVeMP8m62e8H8npawSq(EzKT4Hg9pq0QESFh6Z4nIn5Zetw4XQKoPNN40EGDAx8XMoiloogl(c4vYAQ4nD3MOT5lihbK4SNtxlmIsiQq8gsc4qaWfFkIXsHssxNimQnXfFIKQ0sierXU1qmyt0xZP)WogswvjlShB8MHcEHrOnwWWo5Qcbc6kpIQ)8uLf30mwNRY3toXnL8ZzdtBSDJWRE0CUnaDzMv3Hl6lCcs7ML3B9FVfr33eo0CcwqbdePUf8o07mJcoidgshTXFZoU3ze3ufDGph6Iph(fJpBWg4i4ZbENz045KYNB5089D4fsRFRXNl2e67V7ziuk5pAoRW3F3NJP16xE)D0ZNy6MT5fv1hK03XjL3ro6GGrEb5Cdwcrp3ppExv(g2XveQebCxtodW)xPzWJiNM3pMNbtg9XVtwY9o2588DMLNWthe8ldDblZf)OaAZdcBMcpHyncS(YH1AvCPmjAphd(tLHF(2eMXs9jB(DDjhM)ivIaNp(hl62nz3OqCLdfIowjXPP2hU0O3tQX50(u2WjU(0WjoH1uDGSdKz(G5jHT8Kpy2DeVGlfVqQ72evNpFNk0qtqTbW1JOY4qEdbUtWQN4SgynoKoHZ9d4Tbz9pP8c1q4NwO7gU9JB0vSUFq3nCnK5Vn2HWy6gE3x47gYgYL2gl5GX8(cF3qUV8KUI59f(UHCF5jDfZ7l8Dd5(z13v8UFq3nC7NvFxX6(b9w4QvfWrQ)PI3NA47gYQTRWo)GnGUHZhoKTat1s3FNCcocP(JvFBOJSi)6OTuMKIhr)se6lLg7UhnmHtDgBCcxK81lJ8B)DcJSvPDSBBRdkQHQrXPg(UHSAB7Sh1WK)MthKTaZJ3FZ4JWFZxU2ZAskEe(Be6pRg7(KBM0b)n)2Yipc)nFrzKGslTN0RYjFUaPFP9i7L1s(NYVDLenyIwl9J4hR737NtoF(7N)WUMp5Fz50gAt)(51o6LljdEzCv8dXLj)59)4(5xUFoAl9i9F3qhYR)0o(UdQb5iM1cFCVuSRfEcMHncmL(4GPavPNDGWDHWhtmfWk(imOoXmuf3)ykqv8rDSz1hvl8rGv73nmfW1(amiELzi2ZEJHaTu25LvlUqI4zRvfwxFc5BiWsQDYkquUr3hgCpzl0bc8f2OzA802TGgcmr6gkFJ3Raq(p35UHYEnPVjtkGu6zhiC7LMeEfs9byOP)Ccb2rRygG4POFy5P0SouRDdhdWqwj2JixumqE0Iema3lhAyat5KtQauLNEOa)y4QN(MuGbYJxqHTq5NeE7jDf9FtX0tFDEyG84fzwsi8uV3gEdyli(xf)yvOauPVJfyGfj7b1VbekGw7tebg4rsK4OfMJXeMNcT6Fta(Bglr5e0RaALNEOa)nLLCeMlJTvN2H6cDmsIsgojVka2WiqNeedC(H6ubY8F(qbN8z7fXJb7HOG(nZOgRqHtkF(lXKmbjb2t7KGKcwp1yWa3jqJzcsoi9SEsmWjDukvGP8XS8ab8rRzpbXdxFfvirT7zhzWa3r2ulmWE8CtehqsN(xfalF4HXamIVH(Yxra3rYxNIOL2tSCkIUzFbhsK3Jiy(uBThTp8XV6BoFZL(X7oO2ZR5bxFL8oOD7GIC4udENaUVRAAhX7(c(gaJV7suVGBmWpmmejSgFBG4e4ghsNaEFfLVXG3jG7ROSJ4DFbFBwNVLct8fW3jWDRgEQ3rdVXG3jG7RkyhX7(c(rKib)aniabEtKd8qCXF)D0)IC1kYpMuWF)t0BQr2yj3rInhQQ7VRoS39)17RU)NcfhM8zRsCCveyqxyyDyZUHPSbxPBCkLboMmW2F5UCadltQAFz(kWt(R17G)hVed9LqE)8xFDF9D)M5fdwAeMwx39Z9irZxz42LI9U43Wu7NpdIPWUqkls3YW(t1vRfLpeXUtnfMuchCYbZbn9HXGs4Kv7D)8BaD69ZVEknffljoTF(5K1Kz)8H0xUr510NkycqRpLgIKcYh3jczn9GjlruTTRnuC7SgcrFzTLrE1pEhC2rnYtP5XCsw8RRdv8p2hJ64WLqAx1xstnjBoTj)ray3wj18u51bt6DsB(AulI3MUXVi491hmEpqwbsrQyR4oolUDd4OEBEXKaI73hQiW((kA)8lisj6)Jxvn2kQtL1x5lRFGa1BywcDyKZ4UWnFZFrXmrLTbccsTfONo6qGxjk(e)O4teBFqrSbENa6nnUrTsTXku6q(ZhbG33sv89OyKDBDIYh(hYfcYYvyu(Q(rW2VZf2ACpaiQpzsHNIm6FtTQTIv)a4j6UI5LJoquAYkbf4JsrgWkIXRxJkcY9)0(53Ea4e)RjafzcWzVCcpWVLL1Crr1co(N6Dk4cDjTmjmg4YFRcRNOpzC7fQf6jX0rmvdKJDQsi5CS5x7aV2K8xnfNoXJSHDdq1zDXiiCYZ6MJxlgWmuWGePnnjdpu0d4vDlPboTwNvcjLecW7AMgC9h7oCcutGQl2NdmkHCOdRFFy5aBLSCvtiQ7QrAkY40Lf7YlOgoZSt4Dn8aIIk1KgH(vZAQlIPdMZywVMNrLlZRzmNNyuGA(tn1hPCzCXkPRoAoFoPqapuocw7z3uuu7ZqmF4XJ7iA2u7jbnXJHxZ1f)S)3PSMU5wfx4ivTsk9epER9Oo(Jg3NOjS4WmxWGcW06Cki(SO5mXIMk(L8Hnzbw0qfsPwPfX3FNWxoisP4ek2sqDSMPlo5iXbePQa9a34MaQUP7aFKb8ZWlxWsoaYZLMKTgJUGodeZZZB7aG5nIan40qEiQbC2WnmHjz6KKMxszpezQWRCMGOvN33qn6FlnK5l0WgCHWejxlDsZOd5N9vUMrJf2GoYY8Om)M6gfRgYvioUxgLWz6F38OuZaYc6l2Keu1PZzK(qX(gu3Va1CY(6sXhnlubfyEheoCLZoKySrLtNzWAu)CGyBpeoxomIX89AMTytYPyyFNaYzPwORdL5HN1QTMfX0Ku(CrIyW1bdfUbN9IfSLoO5uLc7vYU6D1QLMTMfFFmTqQqxPMm7SXAF6VnSq88LDwANuRaKyf4L0f06kZ2xQjbNliUv)UAaP1akA9h8aIIfqfig41jX169W0oHvW1MYf(wD))nCPVrN9AA34Duc36VXNKV52PeQwHqRmBGrgIYNvzgwGWxN4R6yhxyQ0Te3wdbMZ9bBdblWLnCTYjM2JQ4L(o4FNYW8O5pAQsYuDDDliPWtYv)CLSYih3uwWC5wqdt8vTsxj1qQigVeo0LLzqhc51L0QMP3RHwhKQ3vgMx9qcfGxD3rQHwxQK8QQ02zDd6SYiQajqxAr8cbpERPU6ZbXtwqh59Y3NFuQcVypNfx7oqUd0rTw7XoRVWywihkczmHLPDxPGhtCmEgNhP6qFQfGLXcYThbx1QdrEhFqtCxcNJv)1jXlKcWdgn1qnh9SVYsEOBXwKtZGyf(oyEYWdRK(gsh7799(6oeHeFtZawGWXd3emviEJWYmpgVebBHAShOVg5TNINNBvSz4nkMV5xetRYw1X4Psw3Ss(SqrmtdLeJrul0OxqK8)G87Az)k7HHXolJXY(6NIj2ZMvZPf48Csl2iFjbrri8IcQri19yoxR4i9pAA9QUaY1NZXL2wnmcza1XZLAzRlFMc6UN0oSmVJDhVwpfFfvaXRsiklhpNEtIVWMuGOy31(2vdSUYwJXZ1uSdziBchD)bh9Ak2D7kFzMQwEh45GQSNCULfy2RbbpcloQx7JeksjMq52e6zcEQQ60Z4Usp28emX5Ag8hupbhSb8e8CCzXRnDPvsnEn(4n8lUs9KQ03hoiEJoe(DBYMu0r)QFRfnqAuMSbUXtmLyxDEB2ucEUsmrzETVM)tC26zJA)nyGJlqtzYgBRny8EGZIBsp5f2W4UlexlgpzWUglW1KJJ7cRHSW98jfTWZqYI(SN2wVS1TOzTCRUcXtkcnyIRzrY5oEgaTQ9gRtwmRxTnFltIyYOiE5lnbVL3Wy6PllCPu20xdpxD9W96d9w7oazlwmrnJN2EyTHFPwAWy34PaumoUX7yuk1mHoSAF0A31O0HmqpO23Z2eXaQiExNwV0otWtUXH(YzUvzuXeXfW93kDfZYYP45e9fZ1WuLJrHGsulIrgx)6dgwZTicaFeUcEKlTl50gMsTOuN(BZjcfnXKowJNyPpjW0HHOTZK2kGsMr8qfdCO3305inIVtPmAjXPdnBYQ7B3qx8tsJdMOPDo)aLmhDT6ZY9LZu6tTNJJJmFZR8D2WkAVwAzrsDiIUcdUmMqyjDNF4zLD0nUvZCAUzAsaXykGI9RCyNyAD9qlu31al0GNlKZsdjTi5WDo5OXTHtr7VRRDiinBhhmpUsz7Q)X3(DTnHTLSyB6DAO43WvqACJfxhAwG8nSl1DisMoQ3cUABEK7Q3WMAJtryz)YGsWnuTsI(UYAMZdPGIAQ7LT0tqggmPvOQUDaKBWo3vT9UwtEhfvNVbEzIToB5MAcwGDTsrCRvPF(UA6IL(SIjDmo0wbKRURRUDzNIsDFWxmvoKbqC)e60ilCkH4X2KZQxFPyuU(46jzlQQe(fH(dj0pwfiQx(Vy0V(46o9RggupBUwFSAzDotqh3S3Ta7nAIUbtiSa16x4SatxWTySbZJ9WDrz31JvB5gUj6vWBTFgdhGB1KfKgN(vFsBkye(N2jgRPaeS7IymUOLxqo7zfxO89LAhwqZB0xtqtYoLHOZjBxkwhSZGoYo1gNHZxpTwxlWZ04CD5aRmklx(XkJu5cqUjPqeEslUnRJ0Wm5TOUvgTto8qTGQO8dX8Sybj0ogIT55yegy63OdxQqkd3SYuKsyREtrk16oAQHJXhcumAWVBaOQln9vbjN2ArR9c9C5XFgBPnvof0FVlnMVLV7VCv3XTnvgwJUoi6qUwHzDhAU6TRQVnGnupCwxpjf17fD6v1SG0RYWzXurehEyI4WVoeXgn2FZeXbAIy1loJFReXHSgS08vYYuhwC)nlWz8cAkHU92YgP4bZx7tyGPMD4gbL8djGTQFYEe5UTyQ(OChKK0dv7eR0hGanrTPwd4ModnsNMOaD60e3WTiBMlgHBYeVJbAFSqeB4zCXI4mskyffjS9cow99hBLHq6A2kY0q5RsXsTvcTToPFTyJ0vxrwPMPtTHJ3v9uoKLkm0ps)L7))p]] )