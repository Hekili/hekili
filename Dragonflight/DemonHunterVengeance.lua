-- DemonHunterVengeance.lua
-- October 2023

if UnitClassBase( "player" ) ~= "DEMONHUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

local floor = math.floor
local strformat = string.format

local spec = Hekili:NewSpecialization( 581 )

spec:RegisterResource( Enum.PowerType.Fury, {
    -- Immolation Aura now grants 20 up front, 60 over 12 seconds (5 fps).
    immolation_aura = {
        aura    = "immolation_aura",

        last = function ()
            local app = state.buff.immolation_aura.applied
            local t = state.query_time

            return app + floor( t - app )
        end,

        interval = 1,
        value = 2
    },
} )

-- Talents
spec:RegisterTalents( {
    -- Demon Hunter
    aldrachi_design           = { 90999, 391409, 1 }, -- Increases your chance to parry by 3%.
    aura_of_pain              = { 90933, 207347, 1 }, -- Increases the critical strike chance of Immolation Aura by $s1%.
    blazing_path              = { 91008, 320416, 1 }, -- Infernal Strike gains an additional charge.
    bouncing_glaives          = { 90931, 320386, 1 }, -- Throw Glaive ricochets to 1 additional target.
    champion_of_the_glaive    = { 90994, 429211, 1 }, -- Throw Glaive has ${$s2+1} charges and $s1 yard increased range.
    chaos_fragments           = { 95154, 320412, 1 }, -- Each enemy stunned by Chaos Nova has a $179057s3% chance to generate a Lesser Soul Fragment.
    chaos_nova                = { 90993, 179057, 1 }, -- Unleash an eruption of fel energy, dealing 1,946 Chaos damage and stunning all nearby enemies for 2 sec. Each enemy stunned by Chaos Nova has a 30% chance to generate a Lesser Soul Fragment.
    charred_warblades         = { 90948, 213010, 1 }, -- You heal for 4% of all Fire damage you deal.
    collective_anguish        = { 95152, 390152, 1 }, -- $?a212613[Fel Devastation][Eye Beam] summons an allied $?a212613[Havoc][Vengeance] Demon Hunter who casts $?a212613[Eye Beam][Fel Devastation], dealing $?a212613[${$391058s1*10*2} Chaos][${$393834s1*(2/$393831t1)} Fire] damage over $?a212613[$391057d][$393831d]. $?a212613[Deals reduced damage beyond $198013s5 targets.][Dealing damage heals you for up to ${$212106s1*(2/$t1)} health.]
    consume_magic             = { 91006, 278326, 1 }, -- Consume 1 beneficial Magic effect removing it from the target.
    darkness                  = { 91002, 196718, 1 }, -- Summons darkness around you in a$?a357419[ 12 yd][n 8 yd] radius, granting friendly targets a $209426s2% chance to avoid all damage from an attack. Lasts $d.; Chance to avoid damage increased by $s3% when not in a raid.
    demon_muzzle              = { 90928, 388111, 1 }, -- Enemies deal 8% reduced magic damage to you for 8 sec after being afflicted by one of your Sigils.
    demonic                   = { 91003, 213410, 1 }, -- Fel Devastation causes you to enter demon form for 6 sec after it finishes dealing damage.
    disrupting_fury           = { 90937, 183782, 1 }, -- Disrupt generates 30 Fury on a successful interrupt.
    elysian_decree            = { 90997, 390163, 1 }, -- [395039] $?a388114[Chaos][Arcane]
    erratic_felheart          = { 90996, 391397, 2 }, -- The cooldown of Infernal Strike is reduced by 10%.
    felblade                  = { 95150, 232893, 1 }, -- [395020] $?a388114[Chaos][Fire]
    felfire_haste             = { 90939, 389846, 1 }, -- Infernal Strike increases your movement speed by 10% for 8 sec.
    first_of_the_illidari     = { 91003, 235893, 1 }, -- Metamorphosis grants 10% versatility and its cooldown is reduced by 60 sec.
    flames_of_fury            = { 90949, 389694, 2 }, -- Sigil of Flame deals $s2% increased damage and generates $s1 additional Fury per target hit.
    illidari_knowledge        = { 90935, 389696, 1 }, -- Reduces magic damage taken by $s1%.
    imprison                  = { 91007, 217832, 1 }, -- Imprisons a demon, beast, or humanoid, incapacitating them for 1 min. Damage will cancel the effect. Limit 1.
    improved_disrupt          = { 90938, 320361, 1 }, -- Increases the range of Disrupt to 10 yds.
    improved_sigil_of_misery  = { 90945, 320418, 1 }, -- Reduces the cooldown of Sigil of Misery by 30 sec.
    infernal_armor            = { 91004, 320331, 2 }, -- Immolation Aura increases your armor by 10% and causes melee attackers to suffer $320334s1/$s3${$320334s1/$s3} Fire damage.
    internal_struggle         = { 90934, 393822, 1 }, -- Increases your mastery by 3.0%.
    live_by_the_glaive        = { 95151, 428607, 1 }, -- When you parry an attack or have one of your attacks parried, restore $428608s2% of max health and $428608s1 Fury. ; This effect may only occur once every $s1 sec.
    long_night                = { 91001, 389781, 1 }, -- Increases the duration of Darkness by 3 sec.
    lost_in_darkness          = { 90947, 389849, 1 }, -- Spectral Sight lasts an additional 6 sec if disrupted by attacking or taking damage.
    master_of_the_glaive      = { 90994, 389763, 1 }, -- Throw Glaive has ${$s2+1} charges and snares all enemies hit by $213405s1% for $213405d.
    misery_in_defeat          = { 90945, 388110, 1 }, -- You deal 20% increased damage to enemies for 5 sec after Sigil of Misery's effect on them ends.
    pitch_black               = { 91001, 389783, 1 }, -- Reduces the cooldown of Darkness by 120 sec.
    precise_sigils            = { 95155, 389799, 1 }, -- All Sigils are now placed at your target's location.
    pursuit                   = { 90940, 320654, 1 }, -- Mastery increases your movement speed.
    quickened_sigils          = { 95149, 209281, 1 }, -- All Sigils activate ${$s1/-1000} second faster.
    rush_of_chaos             = { 95148, 320421, 2 }, -- Reduces the cooldown of Metamorphosis by ${$m1/-1000} sec.
    shattered_restoration     = { 90950, 389824, 1 }, -- The healing of Shattered Souls is increased by $s1%.
    sigil_of_misery           = { 90946, 207684, 1 }, -- Place a Sigil of Misery at the target location that activates after 1 sec. Causes all enemies affected by the sigil to cower in fear, disorienting them for 22 sec.
    soul_rending              = { 90936, 204909, 2 }, -- Leech increased by 5%. Gain an additional 5% leech while Metamorphosis is active.
    soul_sigils               = { 90929, 395446, 1 }, -- Afflicting an enemy with a Sigil generates 1 Lesser Soul Fragment.
    swallowed_anger           = { 91005, 320313, 1 }, -- Consume Magic generates 20 Fury when a beneficial Magic effect is successfully removed from the target.
    the_hunt                  = { 90927, 370965, 1 }, -- Charge to your target, striking them for 29,491 Nature damage, rooting them in place for 1.5 sec and inflicting 24,445 Nature damage over 6 sec to up to 5 enemies in your path. The pursuit invigorates your soul, healing you for 25% of the damage you deal to your Hunt target for 20 sec.
    unrestrained_fury         = { 90941, 320770, 1 }, -- Increases maximum Fury by $s1.
    vengeful_bonds            = { 90930, 320635, 1 }, -- Vengeful Retreat reduces the movement speed of all nearby enemies by 70% for 3 sec.
    will_of_the_illidari      = { 91000, 389695, 1 }, -- Increases maximum health by $s1%.

    -- Vengeance
    agonizing_flames          = { 90971, 207548, 1 }, -- Immolation Aura increases your movement speed by $s1% and its duration is increased by $s2%.
    ascending_flame           = { 90960, 428603, 1 }, -- Sigil of Flame's initial damage is increased by $s2%.; Multiple applications of Sigil of Flame may overlap.
    bulk_extraction           = { 90956, 320341, 1 }, -- Demolish the spirit of all those around you, dealing 2,472 Fire damage to nearby enemies and extracting up to 5 Lesser Soul Fragments, drawing them to you for immediate consumption.
    burning_alive             = { 90959, 207739, 1 }, -- Every 2 sec, Fiery Brand spreads to one nearby enemy.
    burning_blood             = { 90987, 390213, 1 }, -- Fire damage increased by $s1%.
    calcified_spikes          = { 90967, 389720, 1 }, -- You take 12% reduced damage after Demon Spikes ends, fading by 1% per second.
    chains_of_anger           = { 90964, 389715, 1 }, -- Increases the duration of your Sigils by ${$s2/1000} sec and radius by $s1 yds.
    charred_flesh             = { 90962, 336639, 2 }, -- Immolation Aura damage increases the duration of your Fiery Brand and Sigil of Flame by ${$s1/1000}.2 sec.
    cycle_of_binding          = { 90963, 389718, 1 }, -- Afflicting an enemy with a Sigil reduces the cooldown of your Sigils by 3 sec.
    darkglare_boon            = { 90985, 389708, 1 }, -- When Fel Devastation finishes fully channeling, it refreshes $s1-$s2% of its cooldown and refunds $s3-$s4 Fury.
    deflecting_spikes         = { 90989, 321028, 1 }, -- Demon Spikes also increases your Parry chance by 15% for 8 sec.
    down_in_flames            = { 90961, 389732, 1 }, -- Fiery Brand has 15 sec reduced cooldown and 1 additional charge.
    extended_spikes           = { 90966, 389721, 1 }, -- Increases the duration of Demon Spikes by ${$s1/1000} sec.
    fallout                   = { 90972, 227174, 1 }, -- Immolation Aura's initial burst has a chance to shatter Lesser Soul Fragments from enemies.
    feast_of_souls            = { 90969, 207697, 1 }, -- Soul Cleave heals you for an additional 6,714 over 6 sec.
    feed_the_demon            = { 90983, 218612, 2 }, -- Consuming a Soul Fragment reduces the remaining cooldown of Demon Spikes by 0.25 sec.
    fel_devastation           = { 90991, 212084, 1 }, -- Unleash the fel within you, damaging enemies directly in front of you for 17,528 Fire damage over 2 sec. Causing damage also heals you for up to 47,442 health.
    fel_flame_fortification   = { 90955, 389705, 1 }, -- You take 10% reduced magic damage while Immolation Aura is active.
    fiery_brand               = { 90951, 204021, 1 }, -- Brand an enemy with a demonic symbol, instantly dealing 16,004 Fire damage and 24,726 Fire damage over 10 sec. The enemy's damage done to you is reduced by 40% for 10 sec.
    fiery_demise              = { 90958, 389220, 2 }, -- Fiery Brand also increases Fire damage you deal to the target by 20%.
    focused_cleave            = { 90975, 343207, 1 }, -- Soul Cleave deals 40% increased damage to your primary target.
    fracture                  = { 90970, 263642, 1 }, -- Rapidly slash your target for 9,574 Physical damage, and shatter 2 Lesser Soul Fragments from them. Generates 25 Fury.
    frailty                   = { 90990, 389958, 1 }, -- Enemies struck by Sigil of Flame are afflicted with Frailty for 6 sec. You heal for 10% of all damage you deal to targets with Frailty.
    illuminated_sigils        = { 90961, 428557, 1 }, -- Sigil skills have $s2 additional $lcharge:charges;.; You have $s6% increased chance to parry attacks from enemies afflicted by your Sigil of Flame.
    last_resort               = { 90979, 209258, 1 }, -- Sustaining fatal damage instead transforms you to Metamorphosis form. This may occur once every 8 min.
    meteoric_strikes          = { 90953, 389724, 1 }, -- Reduce the cooldown of Infernal Strike by 8 sec.
    painbringer               = { 90976, 207387, 2 }, -- Consuming a Soul Fragment reduces all damage you take by 1% for 6 sec. Multiple applications may overlap.
    perfectly_balanced_glaive = { 90968, 320387, 1 }, -- Reduces the cooldown of Throw Glaive by 6 sec.
    retaliation               = { 90952, 389729, 1 }, -- While Demon Spikes is active, melee attacks against you cause the attacker to take 800 Physical damage. Generates high threat.
    revel_in_pain             = { 90957, 343014, 1 }, -- When Fiery Brand expires on your primary target, you gain a shield that absorbs up 64,939 damage for 15 sec, based on your damage dealt to them while Fiery Brand was active.
    roaring_fire              = { 90988, 391178, 1 }, -- Fel Devastation heals you for up to 50% more, based on your missing health.
    ruinous_bulwark           = { 90965, 326853, 1 }, -- Fel Devastation heals for an additional 10%, and 100% of its healing is converted into an absorb shield for 10 sec.
    shear_fury                = { 90970, 389997, 1 }, -- Shear generates 10 additional Fury.
    sigil_of_chains           = { 90954, 202138, 1 }, -- Place a Sigil of Chains at the target location that activates after 1 sec. All enemies affected by the sigil are pulled to its center and are snared, reducing movement speed by 70% for 8 sec.
    sigil_of_flame            = { 90943, 204596, 1 }, -- Place a Sigil of Flame at the target location that activates after 1 sec. Deals 1,294 Fire damage, and an additional 4,858 Fire damage over 8 sec, to all enemies affected by the sigil. Generates 30 Fury.
    sigil_of_silence          = { 90988, 202137, 1 }, -- Place a Sigil of Silence at the target location that activates after 1 sec. Silences all enemies affected by the sigil for 8 sec.
    soul_barrier              = { 90956, 263648, 1 }, -- Shield yourself for $d, absorbing $<baseAbsorb> damage.; Consumes all available Soul Fragments to add $<fragmentAbsorb> to the shield per fragment.
    soul_carver               = { 90982, 207407, 1 }, -- Carve into the soul of your target, dealing 23,767 Fire damage and an additional 10,314 Fire damage over 3 sec. Immediately shatters 2 Lesser Soul Fragments from the target and 1 additional Lesser Soul Fragment every 1 sec.
    soul_furnace              = { 90974, 391165, 1 }, -- Every 10 Soul Fragments you consume increases the damage of your next Soul Cleave or Spirit Bomb by 40%.
    soulcrush                 = { 90980, 389985, 1 }, -- Multiple applications of Frailty may overlap. Soul Cleave applies Frailty to your primary target for 8 sec.
    soulmonger                = { 90973, 389711, 1 }, -- When consuming a Soul Fragment would heal you above full health it shields you instead, up to a maximum of 52,285.
    spirit_bomb               = { 90978, 247454, 1 }, -- Consume up to 5 available Soul Fragments then explode, damaging nearby enemies for 2,596 Fire damage per fragment consumed, and afflicting them with Frailty for 6 sec, causing you to heal for 10% of damage you deal to them. Deals reduced damage beyond 8 targets.
    stoke_the_flames          = { 90984, 393827, 1 }, -- Fel Devastation damage increased by 40%.
    vengeful_retreat          = { 90942, 198793, 1 }, -- Remove all snares and vault away. Nearby enemies take 1,135 Physical damage.
    void_reaver               = { 90977, 268175, 1 }, -- Frailty now also reduces all damage you take from afflicted targets by 4%. Enemies struck by Soul Cleave are afflicted with Frailty for 6 sec.
    volatile_flameblood       = { 90986, 390808, 1 }, -- Immolation Aura generates 5-10 Fury when it deals critical damage. This effect may only occur once per 1 sec.
    vulnerability             = { 90981, 389976, 2 }, -- Frailty now also increases all damage you deal to afflicted targets by 2%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    blood_moon        = 5434, -- (355995) Consume Magic now affects all enemies within 8 yards of the target and generates a Lesser Soul Fragment. Each effect consumed has a 5% chance to upgrade to a Greater Soul.
    chaotic_imprint   = 5439, -- (356510) Throw Glaive now deals damage from a random school of magic, and increases the target's damage taken from the school by 10% for 20 sec.
    cleansed_by_flame = 814 , -- (205625) Immolation Aura dispels all magical effects on you when cast.
    cover_of_darkness = 5520, -- (357419) The radius of Darkness is increased by 4 yds, and its duration by 2 sec.
    demonic_trample   = 3423, -- (205629) Transform to demon form, moving at 175% increased speed for 3 sec, knocking down all enemies in your path and dealing 805.1 Physical damage. During Demonic Trample you are unaffected by snares but cannot cast spells or use your normal attacks. Shares charges with Infernal Strike.
    detainment        = 3430, -- (205596) Imprison's PvP duration is increased by 1 sec, and targets become immune to damage and healing while imprisoned.
    everlasting_hunt  = 815 , -- (205626) Dealing damage increases your movement speed by 15% for 3 sec.
    glimpse           = 5522, -- (354489) Vengeful Retreat provides immunity to loss of control effects, and reduces damage taken by 35% until you land.
    illidans_grasp    = 819 , -- (205630) You strangle the target with demonic magic, dangling them in place for 5 sec. Use Illidan's Grasp again to toss the target to a location within 40 yards, stunning them and all nearby enemies for 3 sec and dealing 805.1 Shadow damage.
    jagged_spikes     = 816 , -- (205627) While Demon Spikes is active, melee attacks against you cause Physical damage equal to 30% of the damage taken back to the attacker.
    rain_from_above   = 5521, -- (206803) You fly into the air out of harm's way. While floating, you gain access to Fel Lance allowing you to deal damage to enemies below.
    reverse_magic     = 3429, -- (205604) Removes all harmful magical effects from yourself and all nearby allies within 10 yards, and sends them back to their original caster if possible.
    sigil_mastery     = 1948, -- (211489) Reduces the cooldown of your Sigils by an additional 25%.
    tormentor         = 1220, -- (207029) You focus the assault on this target, increasing their damage taken by 3% for 6 sec. Each unique player that attacks the target increases the damage taken by an additional 3%, stacking up to 5 times. Your melee attacks refresh the duration of Focused Assault.
    unending_hatred   = 3727, -- (213480) Taking damage causes you to gain Fury based on the damage dealt.
} )


-- Auras
spec:RegisterAuras( {
    -- Versatility increased by $w1%.
    -- https://wowhead.com/beta/spell=355894
    blind_faith = {
        id = 355894,
        duration = 20,
        max_stack = 1
    },
    -- Taking $w1 Chaos damage every $t1 seconds.  Damage taken from $@auracaster's Immolation Aura increased by $s2%.
    -- https://wowhead.com/beta/spell=391191
    burning_wound = {
        id = 391191,
        duration = 15,
        tick_time = 3,
        max_stack = 1
    },
    -- Talent: Stunned.
    -- https://wowhead.com/beta/spell=179057
    chaos_nova = {
        id = 179057,
        duration = 2,
        type = "Magic",
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=196718
    darkness = {
        id = 196718,
        duration = function() return talent.long_night.enabled and 11 or 8 end,
        max_stack = 1
    },
    demon_soul = {
        id = 347765,
        duration = 15,
        max_stack = 1,
    },
    -- Armor increased by ${$W2*$AGI/100}.$?s321028[  Parry chance increased by $w1%.][]
    -- https://wowhead.com/beta/spell=203819
    demon_spikes = {
        id = 203819,
        duration = function() return 6 + talent.extended_spikes.rank end,
        max_stack = 1
    },
    calcified_spikes = {
        id = 391171,
        duration = 12,
        max_stack = 1
    },
    feast_of_souls = {
        id = 207693,
        duration = 6,
        max_stack = 1
    },
    -- Talent:
    -- https://wowhead.com/beta/spell=212084
    fel_devastation = {
        id = 212084,
        duration = 2,
        tick_time = 0.2,
        max_stack = 1
    },
    fel_flame_fortification = {
        id = 337546,
        duration = function () return class.auras.immolation_aura.duration end,
        max_stack = 1
    },
    -- Talent: Movement speed increased by $w1%.
    -- https://wowhead.com/beta/spell=389847
    felfire_haste = {
        id = 389847,
        duration = 8,
        max_stack = 1
    },
    -- Talent: Branded, taking $w3 Fire damage every $t3 sec, and dealing $204021s1% less damage to $@auracaster$?s389220[ and taking $w2% more Fire damage from them][].
    -- https://wowhead.com/beta/spell=207744
    fiery_brand = {
        id = 207771,
        duration = 12,
        type = "Magic",
        max_stack = 1,
        copy = "fiery_brand_dot"
    },
    -- Talent: Battling a demon from the Theater of Pain...
    -- https://wowhead.com/beta/spell=391430
    fodder_to_the_flame = {
        id = 391430,
        duration = 25,
        max_stack = 1,
        copy = 329554
    },
    -- Talent: $@auracaster is healed for $w1% of all damage they deal to you.$?$w3!=0[  Dealing $w3% reduced damage to $@auracaster.][]$?$w4!=0[  Suffering $w4% increased damage from $@auracaster.][]
    -- https://wowhead.com/beta/spell=247456
    frailty = {
        id = 247456,
        duration = 5,
        tick_time = 1,
        type = "Magic",
        max_stack = 1
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
        duration = function () return talent.agonizing_flames.enabled and 9 or 6 end,
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
    -- Talent: Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=213405
    master_of_the_glaive = {
        id = 213405,
        duration = 6,
        mechanic = "snare",
        max_stack = 1
    },
    -- Maximum health increased by $w2%.  Armor increased by $w8%.  $?s235893[Versatility increased by $w5%. ][]$?s263642[Fracture][Shear] generates $w4 additional Fury and one additional Lesser Soul Fragment.
    -- https://wowhead.com/beta/spell=187827
    metamorphosis = {
        id = 187827,
        duration = 15,
        max_stack = 1
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
    painbringer = {
        id = 212988,
        duration = 6,
        max_stack = 1
    },
    ruinous_bulwark = {
        id = 326863,
        duration = 10,
        max_stack = 1
    },
    -- Talent: Movement slowed by $s1%.
    -- https://wowhead.com/beta/spell=204843
    sigil_of_chains = {
        id = 204843,
        duration = function () return 6 + ( 2 * talent.chains_of_anger.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Sigil of Flame is active.
    -- https://wowhead.com/beta/spell=204596
    sigil_of_flame_active = {
        id = 204596,
        duration = 2,
        max_stack = 1,
        copy = 389810
    },
    -- Talent: Suffering $w2 $@spelldesc395020 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=204598
    sigil_of_flame = {
        id = 204598,
        duration = function () return 6 + ( 2 * talent.chains_of_anger.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=207685
    sigil_of_misery_debuff = {
        id = 207685,
        duration = function () return 20 + ( 2 * talent.chains_of_anger.rank ) end,
        mechanic = "flee",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=204490
    sigil_of_silence = {
        id = 204490,
        duration = function () return 6 + ( 2 * talent.chains_of_anger.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=263648
    soul_barrier = {
        id = 263648,
        duration = 15,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Suffering $s1 Fire damage every $t1 sec.
    -- TODO: Trigger more Lesser Soul Fragments...
    -- https://wowhead.com/beta/spell=207407
    soul_carver = {
        id = 207407,
        duration = 3,
        tick_time = 1,
        max_stack = 1
    },
    -- Consume to heal for $210042s1% of your maximum health.
    -- https://wowhead.com/beta/spell=203795
    soul_fragment = {
        id = 203795,
        duration = 20,
        max_stack = 5
    },
    soul_fragments = {
        id = 203981,
        duration = 3600,
        max_stack = 5,
    },
    -- Talent: $w1 Soul Fragments consumed. At $u, the damage of your next Soul Cleave is increased by $391172s1%.
    -- https://wowhead.com/beta/spell=391166
    soul_furnace_stack = {
        id = 391166,
        duration = 30,
        max_stack = 10,
        copy = 339424
    },
    soul_furnace = {
        id = 391172,
        duration = 30,
        max_stack = 1
    },
    -- Suffering $w1 Chaos damage every $t1 sec.
    -- https://wowhead.com/beta/spell=390181
    soulrend = {
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
    -- Talent:
    -- https://wowhead.com/beta/spell=247454
    spirit_bomb = {
        id = 247454,
        duration = 1.5,
        max_stack = 1
    },
    spirit_of_the_darkness_flame = {
        id = 337542,
        duration = 3600,
        max_stack = 15
    },
    -- Talent: Suffering $w1 $@spelldesc395042 damage every $t1 sec.
    -- https://wowhead.com/beta/spell=345335
    the_hunt_dot = {
        id = 370969,
        duration = 6,
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
    -- Talent: Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=198813
    vengeful_retreat = {
        id = 198813,
        duration = 3,
        max_stack = 1
    },
    void_reaver = {
        id = 268178,
        duration = 12,
        max_stack = 1,
    },

    -- PvP Talents
    demonic_trample = {
        id = 205629,
        duration = 3,
        max_stack = 1,
    },
    everlasting_hunt = {
        id = 208769,
        duration = 3,
        max_stack = 1,
    },
    focused_assault = { -- Tormentor.
        id = 206891,
        duration = 6,
        max_stack = 5,
    },
    illidans_grasp = {
        id = 205630,
        duration = 6,
        type = "Magic",
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

    if sigil == "elysian_decree" then
        applyDebuff( "target", "elysian_decree" )
        debuff.elysian_decree.applied = debuff.elysian_decree.applied + activation_time
        debuff.elysian_decree.expires = debuff.elysian_decree.expires + activation_time
    else
        local effect = sigil == "elysian_dcreee" and "elysian_decree" or ( "sigil_of_" .. sigil )
        applyDebuff( "target", effect )
        debuff[ effect ].applied = debuff[ effect ].applied + 1
        debuff[ effect ].expires = debuff[ effect ].expires + 1
    end
end )

spec:RegisterStateExpr( "soul_fragments", function ()
    return buff.soul_fragments.stack
end )

spec:RegisterStateExpr( "last_metamorphosis", function ()
    return action.metamorphosis.lastCast
end )

spec:RegisterStateExpr( "last_infernal_strike", function ()
    return action.infernal_strike.lastCast
end )


local activation_time = function ()
    return talent.quickened_sigils.enabled and 1 or 2
end

spec:RegisterStateExpr( "activation_time", activation_time )

local sigil_placed = function ()
    return sigils.flame > query_time
end

spec:RegisterStateExpr( "sigil_placed", sigil_placed )
-- Also add to infernal_strike, sigil_of_flame.

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


-- Variable to track the total bonus timed earned on fiery brand from immolation aura.
local bonus_time_from_immo_aura = 0
-- Variable to track the GUID of the initial target
local initial_fiery_brand_guid = ""

spec:RegisterHook( "COMBAT_LOG_EVENT_UNFILTERED", function( _ , subtype, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags, _, spellID, spellName )
    if sourceGUID ~= GUID then return end

    if talent.charred_flesh.enabled and subtype == "SPELL_DAMAGE" and spellID == 258922 and destGUID == initial_fiery_brand_guid then
        bonus_time_from_immo_aura = bonus_time_from_immo_aura + ( 0.25 * talent.charred_flesh.rank )

    elseif subtype == "SPELL_CAST_SUCCESS" then
        if talent.charred_flesh.enabled and spellID == 204021 then
            bonus_time_from_immo_aura = 0
            initial_fiery_brand_guid = destGUID
        end

        -- Fracture:  Generate 2 frags.
        if spellID == 263642 then
            queue_fragments( 2 )
        end

        -- Shear:  Generate 1 frag.
        if spellID == 203782 then
            queue_fragments( 1 )
        end

        -- We consumed or generated a fragment for real, so let's purge the real queue.
    elseif spellID == 203981 and fragments.real > 0 and ( subtype == "SPELL_AURA_APPLIED" or subtype == "SPELL_AURA_APPLIED_DOSE" ) then
        fragments.real = fragments.real - 1

    end
end, false )


local sigil_types = { "chains", "flame", "misery", "silence" }

spec:RegisterHook( "reset_precast", function ()
    last_metamorphosis = nil
    last_infernal_strike = nil

    for i, sigil in ipairs( sigil_types ) do
        local activation = ( action[ "sigil_of_" .. sigil ].lastCast or 0 ) + ( talent.quickened_sigils.enabled and 2 or 1 )
        local time_to_proc = activation - query_time
        if time_to_proc > 0 then
            local effect = "sigil_of_" .. sigil

            sigils[ sigil ] = activation
            applyDebuff( "target", effect )
            debuff[ effect ].applied = activation
            debuff[ effect ].expires = debuff[ effect ].expires + time_to_proc
        else sigils[ sigil ] = 0 end
    end

    if action.elysian_decree.known then
        local activation = ( action.elysian_decree.lastCast or 0 ) + ( talent.quickened_sigils.enabled and 2 or 1 )
        local time_to_proc = activation - query_time
        if time_to_proc > 0 then
            sigils.elysian_decree = activation
            applyDebuff( "target", "elysian_decree" )
            debuff.elysian_decree.applied = activation
            debuff.elysian_decree.expires = debuff.elysian_decree.expires + time_to_proc
        else sigils.elysian_decree = 0 end
    else
        sigils.elysian_decree = 0
    end

    if talent.abyssal_strike.enabled then
        -- Infernal Strike is also a trigger for Sigil of Flame.
        local activation = ( action.infernal_strike.lastCast or 0 ) + ( talent.quickened_sigils.enabled and 2 or 1 )
        if activation > now and activation > sigils[ sigil ] then sigils.flame = activation end
    end

    if fragments.realTime > 0 and fragments.realTime < now then
        fragments.real = 0
        fragments.realTime = 0
    end

    if buff.demonic_trample.up then
        setCooldown( "global_cooldown", max( cooldown.global_cooldown.remains, buff.demonic_trample.remains ) )
    end

    if buff.illidans_grasp.up then
        setCooldown( "illidans_grasp", 0 )
    end

    if buff.soul_fragments.down then
        -- Apply the buff with zero stacks.
        applyBuff( "soul_fragments", nil, 0 + fragments.real )
    elseif fragments.real > 0 then
        addStack( "soul_fragments", nil, fragments.real )
    end

    fiery_brand_dot_primary_expires = nil
    fury_spent = nil
end )


spec:RegisterHook( "spend", function( amt, resource )
    if set_bonus.tier31_4pc == 0 or amt < 0 or resource ~= "fury" then return end

    fury_spent = fury_spent + amt
    if fury_spent > 40 then
        reduceCooldown( "sigil_of_flame", floor( fury_spent / 40 ) )
        fury_spent = fury_spent % 40
    end
end )


spec:RegisterHook( "advance_end", function( time )
    if query_time - time < sigils.flame and query_time >= sigils.flame then
        -- SoF should've applied.
        applyDebuff( "target", "sigil_of_flame", debuff.sigil_of_flame.duration - ( query_time - sigils.flame ) )
        active_dot.sigil_of_flame = active_enemies
        if talent.frailty.enabled then
            applyDebuff( "target", "frailty", 6 - ( query_time - sigils.flame ), debuff.frailty.stack + 1 )
            active_dot.frailty = active_enemies
        end
        sigils.flame = 0
    end
end )


-- approach that actually calculated time remaining of fiery_brand via combat log. last modified 1/27/2023.
spec:RegisterStateExpr( "fiery_brand_dot_primary_expires", function()
    return action.fiery_brand.lastCast + bonus_time_from_immo_aura + class.auras.fiery_brand.duration
end )

spec:RegisterStateExpr( "fiery_brand_dot_primary_remains", function()
    return max( 0, fiery_brand_dot_primary_expires - query_time )
end )

spec:RegisterStateExpr( "fiery_brand_dot_primary_ticking", function()
    return fiery_brand_dot_primary_remains > 0
end )


-- Incoming Souls calculation added to APL in August 2023.
spec:RegisterVariable( "incoming_souls", function()
    -- actions+=/variable,name=incoming_souls,op=reset
    local souls = 0
    
    -- actions+=/variable,name=incoming_souls,op=add,value=2,if=prev_gcd.1.fracture&!buff.metamorphosis.up
    if action.fracture.time_since < ( 0.25 + gcd.max ) and not buff.metamorphosis.up then souls = souls + 2 end

    -- actions+=/variable,name=incoming_souls,op=add,value=3,if=prev_gcd.1.fracture&buff.metamorphosis.up
    if action.fracture.time_since < ( 0.25 + gcd.max ) and buff.metamorphosis.up then souls = souls + 3 end

    -- actions+=/variable,name=incoming_souls,op=add,value=2,if=talent.soul_sigils&(prev_gcd.2.sigil_of_flame|prev_gcd.2.sigil_of_silence|prev_gcd.2.sigil_of_chains|prev_gcd.2.elysian_decree)
    if talent.soul_sigils.enabled and ( ( action.sigil_of_flame.time_since < ( 0.25 + 2 * gcd.max ) and action.sigil_of_flame.time_since > gcd.max ) or
        ( action.sigil_of_silence.time_since < ( 0.25 + 2 * gcd.max ) and action.sigil_of_silence.time_since > gcd.max ) or
        ( action.sigil_of_chains.time_since  < ( 0.25 + 2 * gcd.max ) and action.sigil_of_chains.time_since  > gcd.max ) or
        ( action.elysian_decree.time_since   < ( 0.25 + 2 * gcd.max ) and action.elysian_decree.time_since   > gcd.max ) ) then
        souls = souls + 2
    end

    -- actions+=/variable,name=incoming_souls,op=add,value=active_enemies>?3,if=talent.elysian_decree&prev_gcd.2.elysian_decree
    if talent.elysian_decree.enabled and ( action.elysian_decree.time_since < ( 0.25 + 2 * gcd.max ) and action.elysian_decree.time_since > gcd.max ) then
        souls = souls + min( 3, active_enemies )
    end

    -- actions+=/variable,name=incoming_souls,op=add,value=0.6*active_enemies>?5,if=talent.fallout&prev_gcd.1.immolation_aura
    if talent.fallout.enabled and action.immolation_aura.time_since < ( 0.25 + gcd.max ) then souls = souls + ( 0.6 * min( 5, active_enemies ) ) end

    -- actions+=/variable,name=incoming_souls,op=add,value=active_enemies>?5,if=talent.bulk_extraction&prev_gcd.1.bulk_extraction
    if talent.bulk_extraction.enabled and action.bulk_extraction.time_since < ( 0.25 + gcd.max ) then souls = souls + min( 5, active_enemies ) end

    -- actions+=/variable,name=incoming_souls,op=add,value=3-(cooldown.soul_carver.duration-ceil(cooldown.soul_carver.remains)),if=talent.soul_carver&cooldown.soul_carver.remains>57
    if talent.soul_carver.enabled and cooldown.soul_carver.true_remains > 57 then souls = souls + ( 3 - ( cooldown.soul_carver.duration - ceil( cooldown.soul_carver.remains ) ) ) end

    return souls
end )






-- Gear Sets
spec:RegisterGear( "tier29", 200345, 200347, 200342, 200344, 200346 )
spec:RegisterAura( "decrepit_souls", {
    id = 394958,
    duration = 8,
    max_stack = 1
} )

-- Tier 30
spec:RegisterGear( "tier30", 202527, 202525, 202524, 202523, 202522 )
-- 2 pieces (Vengeance) : Soul Fragments heal for 10% more and generating a Soul Fragment increases your Fire damage by 2% for 6 sec. Multiple applications may overlap.
-- TODO: Track each application to keep count for Recrimination.
spec:RegisterAura( "fires_of_fel", {
    id = 409645,
    duration = 6,
    max_stack = 1
} )
-- 4 pieces (Vengeance) : Shear and Fracture deal Fire damage, and after consuming 20 Soul Fragments, your next cast of Shear or Fracture will apply Fiery Brand for 6 sec to its target.
spec:RegisterAura( "recrimination", {
    id = 409877,
    duration = 30,
    max_stack = 1
} )

spec:RegisterGear( "tier31", 207261, 207262, 207263, 207264, 207266, 217228, 217230, 217226, 217227, 217229 )
-- (2) When you attack a target afflicted by Sigil of Flame, your damage and healing are increased by 2% and your Stamina is increased by 2% for 8 sec, stacking up to 5.
-- (4) Sigil of Flame's periodic damage has a chance to flare up, shattering an additional Soul Fragment from a target and dealing $425672s1 additional damage. Each $s1 Fury you spend reduces its cooldown by ${$s2/1000}.1 sec.
spec:RegisterAura( "fiery_resolve", {
    id = 425653,
    duration = 8,
    max_stack = 5
} )


local furySpent = 0

local FURY = Enum.PowerType.Fury
local lastFury = -1

spec:RegisterUnitEvent( "UNIT_POWER_FREQUENT", "player", nil, function( event, unit, powerType )
    if powerType == "FURY" and state.set_bonus.tier31_4pc > 0 then
        local current = UnitPower( "player", FURY )

        if current < lastFury - 3 then
            furySpent = ( furySpent + lastFury - current )
        end

        lastFury = current
    end
end )

spec:RegisterStateExpr( "fury_spent", function ()
    if set_bonus.tier31_4pc == 0 then return 0 end
    return furySpent
end )


spec:RegisterGear( "tier19", 138375, 138376, 138377, 138378, 138379, 138380 )
spec:RegisterGear( "tier20", 147130, 147132, 147128, 147127, 147129, 147131 )
spec:RegisterGear( "tier21", 152121, 152123, 152119, 152118, 152120, 152122 )
spec:RegisterGear( "class", 139715, 139716, 139717, 139718, 139719, 139720, 139721, 139722 )

spec:RegisterGear( "convergence_of_fates", 140806 )


-- Abilities
spec:RegisterAbilities( {
    -- Talent: Demolish the spirit of all those around you, dealing $s1 Fire damage to nearby enemies and extracting up to $s2 Lesser Soul Fragments, drawing them to you for immediate consumption.
    bulk_extraction = {
        id = 320341,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "fire",

        talent = "bulk_extraction",
        startsCombat = true,

        toggle = "cooldowns",

        handler = function ()
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

        handler = function ()
            applyDebuff( "target", "chaos_nova" )
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
        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
            if talent.swallowed_anger.enabled then gain( 20, "fury" ) end
        end,
    },

    -- Summons darkness around you in a$?a357419[ 12 yd][n 8 yd] radius, granting friendly targets a $209426s2% chance to avoid all damage from an attack. Lasts $d.; Chance to avoid damage increased by $s3% when not in a raid.
    darkness = {
        id = 196718,
        cast = 0,
        cooldown = function() return talent.pitch_black.enabled and 180 or 300 end,
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

    -- Surge with fel power, increasing your Armor by ${$203819s2*$AGI/100}$?s321028[, and your Parry chance by $203819s1%, for $203819d][].
    demon_spikes = {
        id = 203720,
        cast = 0,
        charges = 2,
        cooldown = 20,
        recharge = 20,
        icd = 1.5,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        toggle = "defensives",
        defensive = true,

        handler = function ()
            applyBuff( "demon_spikes", buff.demon_spikes.remains + buff.demon_spikes.duration )
        end,
    },


    demonic_trample = {
        id = 205629,
        cast = 0,
        charges = 2,
        cooldown = 12,
        recharge = 12,
        gcd = "spell",
        icd = 0.8,

        pvptalent = "demonic_trample",
        nobuff = "demonic_trample",

        startsCombat = false,
        texture = 134294,
        nodebuff = "rooted",

        handler = function ()
            spendCharges( "infernal_strike", 1 )
            setCooldown( "global_cooldown", 3 )
            applyBuff( "demonic_trample" )
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
        interrupt = true,

        debuff = "casting",
        readyTime = state.timeToInterrupt,

        handler = function ()
            if talent.disrupting_fury.enabled then gain( 30, "fury" ) end
            interrupt()
        end,
    },

    -- Talent: Unleash the fel within you, damaging enemies directly in front of you for ${$212105s1*(2/$t1)} Fire damage over $d.$?s320639[ Causing damage also heals you for up to ${$212106s1*(2/$t1)} health.][]
    fel_devastation = {
        id = 212084,
        cast = 0,
        channeled = true,
        cooldown = 40,
        fixedCast = true,
        gcd = "spell",
        school = "fire",

        spend = 50,
        spendType = "fury",

        talent = "fel_devastation",
        startsCombat = true,

        start = function ()
            applyBuff( "fel_devastation" )

            -- This is likely repeated per tick but it's not worth the CPU overhead to model each tick.
            if legendary.agony_gaze.enabled and debuff.sinful_brand.up then
                debuff.sinful_brand.expires = debuff.sinful_brand.expires + 0.75
            end
        end,

        finish = function ()
            if talent.demonic.enabled then applyBuff( "metamorphosis", 6 ) end
            if talent.ruinous_bulwark.enabled then applyBuff( "ruinous_bulwark" ) end
            if talent.darkglare_boon.enabled then
                gain( 10, "fury" )
                reduceCooldown( "fel_devastation", 6 )
            end
        end
    },

    -- Talent: Charge to your target and deal $213243sw2 $@spelldesc395020 damage.    $?s203513[Shear has a chance to reset the cooldown of Felblade.    |cFFFFFFFFGenerates $213243s3 Fury.|r]?a203555[Demon Blades has a chance to reset the cooldown of Felblade.    |cFFFFFFFFGenerates $213243s3 Fury.|r][Demon's Bite has a chance to reset the cooldown of Felblade.    |cFFFFFFFFGenerates $213243s3 Fury.|r]
    felblade = {
        id = 232893,
        cast = 0,
        cooldown = 15,
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

    -- Talent: Brand an enemy with a demonic symbol, instantly dealing $sw2 Fire damage$?s320962[ and ${$207771s3*$207744d} Fire damage over $207744d][]. The enemy's damage done to you is reduced by $s1% for $207744d.
    fiery_brand = {
        id = 204021,
        cast = 0,
        charges = function() return talent.down_in_flames.enabled and 2 or nil end,
        cooldown = function () return ( talent.down_in_flames.enabled and 45 or 60 ) + ( conduit.fel_defender.mod * 0.001 ) end,
        recharge = function() return talent.down_in_flames.enabled and 45 + ( conduit.fel_defender.mod * 0.001 ) or nil end,
        gcd = "spell",
        school = "fire",

        talent = "fiery_brand",
        startsCombat = true,

        readyTime = function ()
            if ( settings.brand_charges or 1 ) == 0 then return end
            return ( ( 1 + ( settings.brand_charges or 1 ) ) - cooldown.fiery_brand.charges_fractional ) * cooldown.fiery_brand.recharge
        end,

        handler = function ()
            applyDebuff( "target", "fiery_brand_dot" )
            fiery_brand_dot_primary_expires = query_time + class.auras.fiery_brand.duration
            removeBuff( "spirit_of_the_darkness_flame" )

            if talent.charred_flesh.enabled then applyBuff( "charred_flesh" ) end
        end,
    },

    -- Talent: Rapidly slash your target for ${$225919sw1+$225921sw1} Physical damage, and shatter $s1 Lesser Soul Fragments from them.    |cFFFFFFFFGenerates $s4 Fury.|r
    fracture = {
        id = 263642,
        cast = 0,
        charges = 2,
        cooldown = 4.5,
        recharge = 4.5,
        hasteCD = true,
        gcd = "spell",
        school = "physical",

        spend = function() return ( buff.metamorphosis.up and -45 or -25 ) * ( set_bonus.tier29_2pc > 0 and 1.2 or 1 ) end,
        spendType = "fury",

        talent = "fracture",
        bind = "shear",
        startsCombat = true,

        handler = function ()
            if buff.recrimination.up then
                applyDebuff( "target", "fiery_brand", 6 )
                removeBuff( "recrimination" )
            end
            addStack( "soul_fragments", nil, buff.metamorphosis.up and 3 or 2 )
        end,
    },


    illidans_grasp = {
        id = function () return debuff.illidans_grasp.up and 208173 or 205630 end,
        known = 205630,
        cast = 0,
        channeled = true,
        cooldown = function () return buff.illidans_grasp.up and ( 54 + buff.illidans_grasp.remains ) or 0 end,
        gcd = "off",

        pvptalent = "illidans_grasp",
        aura = "illidans_grasp",
        breakable = true,

        startsCombat = true,
        texture = function () return buff.illidans_grasp.up and 252175 or 1380367 end,

        start = function ()
            if buff.illidans_grasp.up then removeBuff( "illidans_grasp" )
            else applyBuff( "illidans_grasp" ) end
        end,

        copy = { 205630, 208173 }
    },

    -- Engulf yourself in flames, $?a320364 [instantly causing $258921s1 $@spelldesc395020 damage to enemies within $258921A1 yards and ][]radiating ${$258922s1*$d} $@spelldesc395020 damage over $d.$?s320374[    |cFFFFFFFFGenerates $<havocTalentFury> Fury over $d.|r][]$?(s212612 & !s320374)[    |cFFFFFFFFGenerates $<havocFury> Fury.|r][]$?s212613[    |cFFFFFFFFGenerates $<vengeFury> Fury over $d.|r][]
    immolation_aura = {
        id = 258920,
        cast = 0,
        cooldown = function () return level > 26 and 15 or 30 end,
        gcd = "spell",
        school = "fire",

        spend = -8,
        spendType = "fury",
        startsCombat = true,

        handler = function ()
            applyBuff( "immolation_aura" )
            if legendary.fel_flame_fortification.enabled then applyBuff( "fel_flame_fortification" ) end
            if pvptalent.cleansed_by_flame.enabled then
                removeDebuff( "player", "reversible_magic" )
            end
        end,
    },

    -- Talent: Imprisons a demon, beast, or humanoid, incapacitating them for $d. Damage will cancel the effect. Limit 1.
    imprison = {
        id = 217832,
        cast = 0,
        cooldown = function () return pvptalent.detainment.enabled and 60 or 45 end,
        gcd = "spell",
        school = "shadow",

        talent = "imprison",
        startsCombat = false,

        handler = function ()
            applyDebuff( "target", "imprison" )
        end,
    },

    -- Leap through the air toward a targeted location, dealing $189112s1 Fire damage to all enemies within $189112a1 yards.
    infernal_strike = {
        id = 189110,
        cast = 0,
        charges = function() return talent.blazing_path.enabled and 2 or nil end,
        cooldown = function() return ( talent.meteoric_strikes.enabled and 12 or 20 ) * ( 1 - 0.1 * talent.erratic_felheart.rank ) end,
        recharge = function() return talent.blazing_path.enabled and ( ( talent.meteoric_strikes.enabled and 12 or 20 ) * ( 1 - 0.1 * talent.erratic_felheart.rank ) ) or nil end,
        gcd = "off",
        school = "physical",
        icd = 0.8,

        startsCombat = false,
        nodebuff = "rooted",

        sigil_placed = function() return sigil_placed end,

        readyTime = function ()
            if ( settings.infernal_charges or 1 ) == 0 then return end
            return ( ( 1 + ( settings.infernal_charges or 1 ) ) - cooldown.infernal_strike.charges_fractional ) * cooldown.infernal_strike.recharge
        end,

        handler = function ()
            setDistance( 5 )
            spendCharges( "demonic_trample", 1 )

            if talent.abyssal_strike.enabled then
                create_sigil( "flame" )
            end

            if talent.felfire_haste.enabled or conduit.felfire_haste.enabled then applyBuff( "felfire_haste" ) end
        end,
    },

    -- Transform to demon form for $d, increasing current and maximum health by $s2% and Armor by $s8%$?s235893[. Versatility increased by $s5%][]$?s321067[. While transformed, Shear and Fracture generate one additional Lesser Soul Fragment][]$?s321068[ and $s4 additional Fury][].
    metamorphosis = {
        id = 187827,
        cast = 0,
        cooldown = function()
            return ( 180 - ( talent.first_of_the_illidari.enabled and 60 or 0 ) - ( talent.rush_of_chaos.enabled and 30 or 0 ) ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 )
        end,
        gcd = "off",
        school = "chaos",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "metamorphosis" )

            if action.sinful_brand.known then
                applyDebuff( "target", "sinful_brand" )
                active_dot.sinful_brand = active_enemies
            end

            last_metamorphosis = query_time
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

        buff = "reversible_magic",

        handler = function ()
            if debuff.reversible_magic.up then removeDebuff( "player", "reversible_magic" ) end
        end,
    },

    -- Shears an enemy for $s1 Physical damage, and shatters $?a187827[two Lesser Soul Fragments][a Lesser Soul Fragment] from your target.    |cFFFFFFFFGenerates $m2 Fury.|r
    shear = {
        id = 203782,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = function () return ( ( level > 47 and buff.metamorphosis.up and -30 or -10 ) - ( talent.shear_fury.enabled and 20 or 0 ) ) * ( set_bonus.tier29_2pc > 0 and 1.2 or 1 ) end,

        notalent = "fracture",
        bind = "fracture",
        startsCombat = true,

        handler = function ()
            if buff.recrimination.up then
                applyDebuff( "target", "fiery_brand", 6 )
                removeBuff( "recrimination" )
            end
            addStack( "soul_fragments", nil, buff.metamorphosis.up and 2 or 1 )
        end,
    },

    -- Talent: Place a Sigil of Chains at the target location that activates after $d.    All enemies affected by the sigil are pulled to its center and are snared, reducing movement speed by $204843s1% for $204843d.
    sigil_of_chains = {
        id = function() return talent.precise_sigils.enabled and 389807 or 202138 end,
        known = 202138,
        cast = 0,
        cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 90 end,
        charges = function () return talent.illuminated_sigils.enabled and 2 or 1 end,
        recharge = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 90 end,
        gcd = "spell",
        school = "physical",

        talent = "sigil_of_chains",
        startsCombat = false,

        handler = function ()
            create_sigil( "chains" )
        end,

        copy = { 202138, 389807 }
    },

    -- Talent: Place a Sigil of Flame at your location that activates after $d.    Deals $204598s1 Fire damage, and an additional $204598o3 Fire damage over $204598d, to all enemies affected by the sigil.    |CFFffffffGenerates $389787s1 Fury.|R
    sigil_of_flame = {
        id = function () return talent.precise_sigils.enabled and 389810 or 204596 end,
        known = 204596,
        cast = 0,
        cooldown = 30,
        charges = function () return talent.illuminated_sigils.enabled and 2 or 1 end,
        recharge = 30,
        gcd = "spell",
        icd = function() return 0.25 + ( talent.quickened_sigils.enabled and 1 or 2 ) end,
        school = "physical",

        spend = -30,
        spendType = "fury",

        startsCombat = false,

        readyTime = function ()
            return sigils.flame - query_time
        end,

        sigil_placed = function() return sigil_placed end,

        handler = function ()
            create_sigil( "flame" )
        end,

        copy = { 204596, 389810 }
    },

    -- Talent: Place a Sigil of Misery at your location that activates after $d.    Causes all enemies affected by the sigil to cower in fear. Targets are disoriented for $207685d.
    sigil_of_misery = {
        id = function () return talent.precise_sigils.enabled and 389813 or 207684 end,
        known = 207684,
        cast = 0,
        cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 120 - ( talent.improved_sigil_of_misery.enabled and 30 or 0 ) end,
        charges = function () if talent.illuminated_sigils.enabled then return 2 end end,
        recharge = function () if talent.illuminated_sigils.enabled then return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 120 - ( talent.improved_sigil_of_misery.enabled and 30 or 0 ) end end,
        gcd = "spell",
        school = "physical",

        talent = "sigil_of_misery",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            create_sigil( "misery" )
        end,

        copy = { 207684, 389813 }
    },



    sigil_of_silence = {
        id = function () return talent.precise_sigils.enabled and 389809 or 202137 end,
        known = 202137,
        cast = 0,
        cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 60 end,
        charges = function () if talent.illuminated_sigils.enabled then return 2 end end,
        recharge = function () if talent.illuminated_sigils.enabled then return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 60 end end,
        gcd = "spell",

        startsCombat = true,
        texture = 1418288,

        toggle = "interrupts",

        usable = function () return debuff.casting.remains > ( talent.quickened_sigils.enabled and 1 or 2 ) end,
        handler = function ()
            interrupt() -- early, but oh well.
            create_sigil( "silence" )
        end,

        copy = { 202137, 389809 },

        auras = {
            -- Conduit, applies after SoS expires.
            demon_muzzle = {
                id = 339589,
                duration = 6,
                max_stack = 1
            }
        }
    },

    -- Talent: Shield yourself for $d, absorbing $<baseAbsorb> damage.    Consumes all Soul Fragments within 25 yds to add $<fragmentAbsorb> to the shield per fragment.
    soul_barrier = {
        id = 263648,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "shadow",

        talent = "soul_barrier",
        startsCombat = false,


        toggle = "defensives",

        handler = function ()
            if talent.feed_the_demon.enabled then
                gainChargeTime( "demon_spikes", 0.5 * buff.soul_fragments.stack )
            end

            -- TODO: Soul Fragment consumption mechanics.
            buff.soul_fragments.count = 0
            applyBuff( "soul_barrier" )
        end,
    },

    -- Talent: Carve into the soul of your target, dealing ${$s2+$214743s1} Fire damage and an additional $o1 Fire damage over $d.  Immediately shatters $s3 Lesser Soul Fragments from the target and $s4 additional Lesser Soul Fragment every $t1 sec.
    soul_carver = {
        id = 207407,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "fire",

        talent = "soul_carver",
        startsCombat = true,

        handler = function ()
            addStack( "soul_fragments", nil, 3 )
            applyBuff( "soul_carver" )
        end,
    },

    -- Viciously strike up to $228478s2 enemies in front of you for $228478s1 Physical damage and heal yourself for $s4.    Consumes up to $s3 available Soul Fragments$?s321021[ and heals you for an additional $s5 for each Soul Fragment consumed][].
    soul_cleave = {
        id = 228477,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "physical",

        spend = 30,
        spendType = "fury",

        startsCombat = true,

        handler = function ()
            if talent.feed_the_demon.enabled then
                gainChargeTime( "demon_spikes", 0.5 * buff.soul_fragments.stack )
            end

            if talent.feast_of_souls.enabled then applyBuff( "feast_of_souls" ) end
            if talent.soulcrush.enabled then applyDebuff( "target", "frailty" ) end
            if talent.void_reaver.enabled then active_dot.frailty = true_active_enemies end
            if legendary.fiery_soul.enabled then reduceCooldown( "fiery_brand", 2 * min( 2, buff.soul_fragments.stack ) ) end

            removeBuff( "soul_furnace" )
            if talent.soul_furnace.enabled then
                addStack( "soul_furnace_stack", nil, min( 2, buff.soul_fragments.stack ) )
                if buff.soul_furnace_stack.up and buff.soul_furnace_stack.stack == 10 then
                    removeBuff( "soul_furnace_stack" )
                    applyBuff( "soul_furnace" )
                end
            end
            buff.soul_fragments.count = max( 0, buff.soul_fragments.stack - 2 )
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

    -- Talent: Consume up to $s2 available Soul Fragments then explode, damaging nearby enemies for $247455s1 Fire damage per fragment consumed, and afflicting them with Frailty for $247456d, causing you to heal for $247456s1% of damage you deal to them. Deals reduced damage beyond $s3 targets.
    spirit_bomb = {
        id = 247454,
        cast = 0,
        cooldown = 0,
        gcd = "spell",
        school = "fire",

        spend = 40,
        spendType = "fury",

        talent = "spirit_bomb",
        startsCombat = false,
        buff = "soul_fragments",

        handler = function ()
            if talent.feed_the_demon.enabled then
                gainChargeTime( "demon_spikes", 0.5 * buff.soul_fragments.stack )
            end

            applyDebuff( "target", "frailty" )
            active_dot.frailty = active_enemies

            removeBuff( "soul_furnace" )
            if talent.soul_furnace.enabled then
                addStack( "soul_furnace_stack", nil, min( 5, buff.soul_fragments.stack ) )
                if buff.soul_furnace_stack.up and buff.soul_furnace_stack.stack == 10 then
                    removeBuff( "soul_furnace_stack" )
                    applyBuff( "soul_furnace" )
                end
            end
            buff.soul_fragments.count = max( 0, buff.soul_fragments.stack - 5 )
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
        id = 204157,
        cast = 0,
        charges = function()
            local c = talent.champion_of_the_glaive.rank + talent.master_of_the_glaive.rank
            if c > 0 then return 1 + c end
        end,
        cooldown = function() return talent.perfectly_balanced_glaive.enabled and 3 or 9 end,
        recharge = function()
            local c = talent.champion_of_the_glaive.rank + talent.master_of_the_glaive.rank
            if c > 0 then return ( talent.perfectly_balanced_glaive.enabled and 3 or 9 ) end
        end,
        gcd = "spell",
        school = "physical",

        spend = function() return talent.furious_throws.enabled and 25 or nil end,
        spendType = function() return talent.furious_throws.enabled and "fury" or nil end,

        startsCombat = true,

        handler = function ()
            if talent.serrated_glaive.enabled or conduit.serrated_glaive.enabled then applyDebuff( "target", "exposed_wound" ) end
            if talent.master_of_the_glaive.enabled then applyDebuff( "target", "master_of_the_glaive" ) end
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
        nopvptalent = "tormentor",

        handler = function ()
            applyDebuff( "target", "torment" )
        end,
    },


    tormentor = {
        id = 207029,
        cast = 0,
        cooldown = 20,
        gcd = "spell",

        startsCombat = true,
        texture = 1344654,

        pvptalent = "tormentor",

        handler = function ()
            applyDebuff( "target", "focused_assault" )
        end,
    },

    -- Talent: Remove all snares and vault away. Nearby enemies take $198813s2 Physical damage$?s320635[ and have their movement speed reduced by $198813s1% for $198813d][].$?a203551[    |cFFFFFFFFGenerates ${($203650s1/5)*$203650d} Fury over $203650d if you damage an enemy.|r][]
    vengeful_retreat = {
        id = 198793,
        cast = 0,
        cooldown = function () return talent.momentum.enabled and 20 or 25 end,
        gcd = "spell",

        startsCombat = true,
        nodebuff = "rooted",

        readyTime = function ()
            if settings.recommend_movement then return 0 end
            return 3600
        end,

        handler = function ()
            if talent.vengeful_bonds.enabled and action.chaos_strike.in_range then -- 20231116: and target.within8 then
                applyDebuff( "target", "vengeful_retreat" )
            end
            if talent.momentum.enabled then applyBuff( "momentum" ) end

            if pvptalent.glimpse.enabled then applyBuff( "glimpse" ) end
        end,
    }
} )


spec:RegisterRanges( "disrupt", "fiery_brand", "torment", "throw_glaive", "the_hunt" )

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

    package = "Vengeance",
} )


spec:RegisterSetting( "infernal_charges", 1, {
    name = strformat( "Reserve %s Charges", Hekili:GetSpellLinkWithTexture( 189110 ) ),
    desc = strformat( "If set above zero, %s will not be recommended if it would leave you with fewer charges.", Hekili:GetSpellLinkWithTexture( 189110 ) ),
    type = "range",
    min = 0,
    max = 2,
    step = 0.1,
    width = "full"
} )


spec:RegisterSetting( "brand_charges", 0, {
    name = strformat( "Reserve %s Charges", Hekili:GetSpellLinkWithTexture( spec.abilities.fiery_brand.id ) ),
    desc = strformat( "If set above zero, %s will not be recommended if it would leave you with fewer charges.", Hekili:GetSpellLinkWithTexture( spec.abilities.fiery_brand.id ) ),
    type = "range",
    min = 0,
    max = 2,
    step = 0.1,
    width = "full"
} )


spec:RegisterSetting( "frailty_stacks", 2, {
    name = strformat( "Require %s Stacks", Hekili:GetSpellLinkWithTexture( 389958 ) ),
    desc = function()
        return strformat( "If set above zero, the default priority will not recommend certain abilities unless you have at least this many stacks of %s on your target.\n\n"
            .. "If %s is not talented, then |cFFFFD100frailty_threshold_met|r will always be |cFF00FF00true|r.\n\n"
            .. "If %s is not talented, then |cFFFFD100frailty_threshold_met|r will be |cFF00FF00true|r even with only one stack of %s.\n\n"
            .. "This is an experimental setting.  Requiring too many stacks may result in a loss of DPS due to delaying use of your major cooldowns.",
            Hekili:GetSpellLinkWithTexture( 389958 ), Hekili:GetSpellLinkWithTexture( 389976 ), Hekili:GetSpellLinkWithTexture( 389985 ), spec.auras.frailty.name )
    end,
    type = "range",
    min = 0,
    max = 6,
    step = 1,
    width = "full"
} )

spec:RegisterStateExpr( "frailty_threshold_met", function()
    if settings.frailty_stacks == 0 or not talent.vulnerability.enabled then return true end
    if not talent.soulcrush.enabled then return debuff.frailty.up end
    return debuff.frailty.stack >= settings.frailty_stacks
end )



spec:RegisterPack( "Vengeance", 20240508, [[Hekili:TZvFVTnos)plblqQn2exlL400fXb42Uxb2IDlUdU398FwIwI2Mx0l(0ljnhm0N9BiPKfjfPEX2Tl2NNh0I2endNz4Wz(XHViT0A5xwUWhLHx(z7P23oD207NyzBDN99lxK96o8Yf7qEpH2a)qeke(3)joAdgf5XO8AqmYNkH048e6J2MLTl9NE7B3qY2MVAIxC4BtjH5bOmsCKxcADg939E7YfRYjbz)A0Yv6v)7azUd7T8ZZU3celX3hZ5fN6TCbL3RNo76P3)tfUliHFOWnFhvmtk(uXN4uTU22cO(LxWONslCZIbo3Irjxv4(74me8F4mVk(V5AlG)Ba()7X)wHljCxs8Z4qCug00VAlXM1TaB)ECcUWf6lvAovMNB4gMavxr6tFhq)J5jzBXjfUwtNyRxotNb893qzEB5CvtC69xBFhq8FWAfV)bMZUaYAc2VWDxcjoHK9AHBajntQDmL)ZyKxC0B)Lp(ZGMtHb4cxK))kpnd7lW87U(gRdU4k6Chi87r(vYPugsT0Ek0Y)IpWtijnLeTHAGrBcWxNHs2GZOwweoTuon69GeSEpiHFnCxCs2bgkCxNehEWKOnDneELHJe7ZJ8JJEd0OvjWOFHBCo8ZKiQpc5rdf5EfAyXweqQK7YHDiYy9AIhbh596yzd6oUbfWcnkCpKmaQ4zCYwuEGO9j3wlPHsRjZudAVHgsx51OU5Ses0t4S0jqUws8AsaKHXT)0j7sWq21ku2pohsP2qcCIx7aEIq8vu3QJN)8zfFsh3KWWyEcPdkpbrv(pu4(HTypWtrwxR2c3TiQ3yv(61mFc2dEyLmbj9mkHGwfGVIcnmVSzowo0gKE1ZOG8dpf6VBrPo5Pyg197hjtG(WjPzjGdnB7(9AigIGyVKx1sd89Pqpkag71sFlTTAP4bXlJ7UpzRTpzBQpz3wFYUL(KDh9jBJ9j7b3NSCWF1li3h3yKIKojjF1RoVSfhSZjf(3arNhq(LTeaEgEYghsKhkjccJDiuGGovRTb1A3UAT7qTqi8VWZIboyOc5jaqailizFngYl9XpdeJPj)uGGq0xjHK)dwKA(Umsi2CFaWjYC8cWqArP1pYlooWp(LOjGuCaHaJkSCRjj4qejk9H5J4sBcmhzqzJNG)k2lhSDQ6(XnE(vCpE8Lu7(H7NQMucO60(JpgatbBMKYHYO5NmqWuifh5B20x77qz41kVokaqWMWKQZQeqexk9iUEUKRch)yjwP)(Jt)FP(8)hM1tT2CQJEXocKobZZbWNqxdQRbM4o2dOb93pWKSzBNpFNdF(UsRhCvbbLpkDskt8oRaPp3QfbfIGgHIXDjKhNBFPrIpimLqdvSISPFk4oZYWdf5KUB1vX7MNIZiRVcsn9juENxX4eLaXrhii5SUKnYTobTHve2JZNngWxR5TYF0GVBL4RSt1GRBgZvVdoivYgoz5sNoT294tstGaCXhbUK08qStiAdXtKajAngq0cCGPmipjfvbzJXupl840ROZ3eVETdecp36kY65xWq9f5zs(oiDo6jArxcIjekBlmoz324uIr5iXevqJUOezGPbI3(9DL)9OLT08p7Iz1C9PF4hQQ)I5iyUA2V6qRgJhcH)AgZlivOb1ujz4qPhQV9IWxxr9KEz8E3zbXRlTt7(qPOSscfyojpQjVYGdIMQ(uIUf4bqc9cRICNcQckqRykjYkBSE8CYHXnwK8ZXpb5wLpIvvsPj(A4QywPQBJ3HpgjSl(fCcm7)68uwmfdZ(JYto(cjccpRR(vCawxbWg4tPS66yiuQhmDhTkegLlRsqibb5HeArj(oSgNUF)fCPSla5H9fJUKL(8PgndijBvaYNzahYffqKbCPUsiHjenp7x50FZA1ceLQzhgB2wucu6k1yLbhF4gJTdwfSZ28OmJmGdEnLaZT4J9sWmhb1Kbq5PxEbu3ZZummOWuz2mBM1(oPi7YzVeqWHwgeGteJf82s9AcbdEVc1xqPSIWIjMaP)G0oGUO0YkYTPdQDM86XOdEl7JosHvtcOuhJskBAlAjBBs8loBcq06t5PO)UaYO7L0Y(EcJ3v3wbKtAexn0RbS7rJmJupF6L1PeY5z9jJqycoHi6b2YJktKUeYY5AbzaOCCJofYqbOByn8BPZeWAz7cYKF9pkinzRWiaSmBRYdEIofqcNmd)B0SRLHvg)GCTQJvQj7H52gDgDHdyi2uepwpGCPpbhbqo405wCiwOak62kLrXTOd1NgSDfQTXX61u)wEc3oplQYOJKTVQNr1uVWs62Q5H2vU0Y(nqk6RFy(ntLxq0JwnRT3OGRx(ytbF70sOTfSQ0kC)ICzAYvVPDAovoeGBmZKIRvebpgWF5HEOOn5K0T1akPz0cQOMqjKs5ZxLNert7xfeh7p2SwBofCFM5TdBVlpXbp)fhsof2oGwutzOVzomT4b6eyLdR2xpRWTmOrqqvvrRFavG6qgNQMl184L6SXsJBvehR3sAP8PrQOLw733CPV9QkRw676zQ3Ll2Srhcm0z)AGKHEqhrqIgFZOhbQ9iY5UFutGt56MgyGX(9gIh0j4MXJ10((edyStQJLEp(l0ezK(waYvvtnusZOJUcoe6vncnmRN(kZEeq9XYFPQXhXYsmSCK2KzNldXWYpAtMDVSdtl3qJuRQetNcPLKO55nwzc4DH)(xl3Ob(HDLEmBmX5ERnwUGEcq0FGF04w2wlx8cIH6NUCXx2Izhyj7SrxhNu4(gEN8nfUj4)DojHUb1PXH0diiploeXo5wyupAd7yw)nseqIE(YFiocufJ8BmmO8g(oIBIC18paBJS(64UKUsmOIWnSGzvzF33ul3G0vI0nz5Yldxv2V7BQLBq6QPtMmDLf3xl9IpPjKRefByXCwg6)nM8t1dySSjvFGbnOohQQpWqjx91dxpHIQGRP0t)kSiduEq2j6x1E07hSTsQzni3UR08X2BqYQ8CMf)jy4Lh)EB2DnlNxHFcwTWfdOnlxMTZVsoHEa7Ql0MTxXW5uWNG9sVqfTzUL0pJI1KXABqQ2TNI3G8aeA75G655ml(tWWnLfQLLZRWpbRUTSpJSD(vYj0d0NjQHHZPGpb7vBUyt6NrXAYyVXiWHM7hLg4d9C1Fvy8owPxxTXUKsV1O3Qp9ltC1Fv0)(vNS3NvkiCKuVrUAqbkdC1hINJPwHYjzSQydIT8EDOiXYNAuyV)Bq)UDHEeDCwP1RH1ne)cHEbKPh3uAHlSoBm7(D5tVwWGaPSXxSo)Mbt3hGSk(IIz1LNhjXTVpLzFugAfkf)tqH8Uxd1KtVSy6RPxPtmGc7Ba0W76kNzNIJrHQjxUbz38C)ueFtgmPHgOnN)LljT7(dZ3AW6oJlg1u))8Syudsx64bueT2JoOlpC1oGpmVRPTr5mo2lCIDdZ2mSjbNgaMbewPtZxfOvI4aZt)tcgW5ooG)sHqf19kVsha5LlGr9TXjlxqFjmwUG9C2BPKimb8GpZE7Nkf)YFM)2fLq2LX2(v5J1T6nVy5IQtzzz2YpBtfqfbHZZquQaB3OOh6SeqTfiqyDHMu4UFp0XbVt74cSlvtBj4fUJRnvLtNHAJ3A0gVG(M1y4OFQfPYZbjot05OQrzh0DTPCDhKIQxN)qqsVtsPLhxJI2UxrBvSREsm8qhh(l(gF31xsh2xuUTN6cHm2FLITeoHWJiAOJqHgbMhIy7Buj)E8)4COK6PSaRru8uXZARW9bGQf3EujXAieVXA6Xg9CB)JEMzSJ0WOHjm1NW2AqO2oOGCQbRoecAky2m(wL3AqH733JW93F2sUSMEQzocZw3A2t9uTkzo6VhHAsI0mBDvO8OQ3DgDxEWcxyW9quFhxJqEAaWN4TAQWfYUfUztSmbAEsBxRWJusgUNv9xAJpiZ65y0xrcZL08IiomvDaBQTzdnu2svcsNvFW7pxqFFtRVOISwlmSlpGYh1fc8LOEaTSISYnyujHZ8uP8GVzSLkQcQmM7jLUSAvGO6aFTRnhLBkz7yIQ3ZrJ4yMXd5DJoqZOJbL(7YlcjZjBv1NeVnD1t2uhmo6mhMFz17NgmjWSPQLdXUibTJE)T1G0aJRPuLV)wd7MuOBAeDrnYy16UdNQLzuhbqT1B4aVk5apYIA0KgWNhw3etTPKBNAAcUm6lAD5BkDBtpPGoSO8nUE5IznQ9QvKISQz647kKovk5q1(EUywx)5gR1uuFpGDo35gTLSkaD8hujRO2lZ3mGwJY8p2A1nJs13jBYOr6S78GUKGyOaVuX1Gxjw6pfKd)NHZpTUYM2O)9M4yL06((TxG1VllQUKXQV2c6Y1hGxZUdVMo6FVjowx33UU7RcAmGUV2tnRXGyBNkK(HMYV0b6QjCawN2Z(QHZAOwNTO1Pch1T1neiwUqm(Y43NksUFQ(Alo5p8aIUgXLaRP(3UDkDS0tjYYhzL6mMnwu6JSPmnbBSwUWadFDie7RvVg(6MHO7o6)hy0xDoTUDkg)MjWx3Jsxy4FNjenw5TYwt15NK5sljWUzL4YmrhENjztvNrK2kYpzd6orDvTdSunzOAbYA96QsehQirt1khYowu)zIGf1)CZ3MEJlmrCXSpR(6ZBQv3uorxvA2Z6)wayQ5Z0Q0VPglDiqAjpLF0lukd1sAduK(kyOYPuD0kFwmu51CH0xWREs9dJrjsm7JJHGnlW0YfcFAmOfJs1tRNqb)2GP8HZOAleRxVIYvQOVBLhD5V2s7xHKQ0AUshdc)7VHQNtARJp8f2qLlZBE838j74F(jO9O6WM23NzHLstRh(O2TAXDOMkev0fnOfYGX6SBLpZgskSbuUT5fT3mJE4QteL228kTvbbgSIQHOZe1Ax7XH4RDPM12QzDoncj768Zg15rOjgbFuNM6))zR13ZwR9UFhB2Zb3WZd5yS(UCgXL)SMW9MXRgE1EeJcn8wrj0hLzOFjkdrXYVutAumNH2J(pgfR8kjPrZLC0i0w8T9RJ4AtUr1nGLnOEIDiLHWwtpog5pGrkZBo4XO4bnsDVcieFBuLhLEVip8tIqP(KP9B8U6pl)Vd]] )