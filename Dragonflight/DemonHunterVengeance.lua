-- DemonHunterVengeance.lua
-- October 2022

if UnitClassBase( "player" ) ~= "DEMONHUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

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
    agonizing_flames          = { 90971, 207548, 2 }, -- Immolation Aura increases your movement speed by 10% and its duration is increased by 25%.
    aldrachi_design           = { 90999, 391409, 1 }, -- Increases your chance to parry by 3%.
    aura_of_pain              = { 90932, 207347, 1 }, -- Increases the critical strike chance of Immolation Aura by 6%.
    blazing_path              = { 91008, 320416, 1 }, -- Infernal Strike gains an additional charge.
    bouncing_glaives          = { 90931, 320386, 1 }, -- Throw Glaive ricochets to 1 additional target.
    bulk_extraction           = { 90956, 320341, 1 }, -- Demolish the spirit of all those around you, dealing 160 Fire damage to nearby enemies and extracting up to 5 Lesser Soul Fragments, drawing them to you for immediate consumption.
    burning_alive             = { 90959, 207739, 1 }, -- Every 2 sec, Fiery Brand spreads to one nearby enemy.
    burning_blood             = { 90987, 390213, 2 }, -- Fire damage increased by 5%.
    calcified_spikes          = { 90967, 389720, 1 }, -- You take 10% reduced damage after Demon Spikes ends, fading by 1% per second.
    chains_of_anger           = { 90964, 389715, 1 }, -- Increases the radius of your Sigils by 2 yards.
    chaos_fragments           = { 90992, 320412, 1 }, -- Each enemy stunned by Chaos Nova has a 30% chance to generate a Lesser Soul Fragment.
    chaos_nova                = { 90993, 179057, 1 }, -- Unleash an eruption of fel energy, dealing 126 Chaos damage and stunning all nearby enemies for 2 sec.
    charred_flesh             = { 90962, 336639, 2 }, -- Immolation Aura damage increases the duration of your Fiery Brand by 0.25 sec.
    charred_warblades         = { 90948, 213010, 1 }, -- You heal for 5% of all Fire damage you deal.
    collective_anguish        = { 90995, 390152, 1 }, -- Fel Devastation summons an allied Havoc Demon Hunter who casts Eye Beam, dealing 1,165 Chaos damage over 2.0 sec. Deals reduced damage beyond 5 targets.
    concentrated_sigils       = { 90944, 207666, 1 }, -- All Sigils are now placed at your location, and the duration of their effects is increased by 2 sec.
    consume_magic             = { 91006, 278326, 1 }, -- Consume 1 beneficial Magic effect removing it from the target.
    cycle_of_binding          = { 90963, 389718, 1 }, -- Afflicting an enemy with a Sigil reduces the cooldown of your Sigils by 3 sec.
    darkglare_boon            = { 90985, 389708, 2 }, -- When Fel Devastation finishes fully channeling, it refreshes 10-20% of its cooldown and refunds 10-20 Fury.
    darkness                  = { 91002, 196718, 1 }, -- Summons darkness around you in an 8 yd radius, granting friendly targets a 10% chance to avoid all damage from an attack. Lasts 8 sec.
    deflecting_spikes         = { 90989, 321028, 1 }, -- Demon Spikes also increases your Parry chance by 15% for 6 sec.
    demon_muzzle              = { 90928, 388111, 1 }, -- Enemies deal 8% reduced magic damage to you for 8 sec after being afflicted by one of your Sigils.
    demonic                   = { 91003, 213410, 1 }, -- Fel Devastation causes you to enter demon form for 6 sec after it finishes dealing damage.
    disrupting_fury           = { 90937, 183782, 1 }, -- Disrupt generates 30 Fury on a successful interrupt.
    down_in_flames            = { 90961, 389732, 1 }, -- Fiery Brand has 15 sec reduced cooldown and 1 additional charge.
    elysian_decree            = { 90960, 390163, 1 }, -- Place a Kyrian Sigil at the target location that activates after 2 sec. Detonates to deal 1,761 Arcane damage and shatter up to 3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond 5 targets.
    erratic_felheart          = { 90996, 391397, 2 }, -- The cooldown of Infernal Strike is reduced by 10%.
    extended_sigils           = { 90998, 389697, 2 }, -- Increases the duration of Sigil effects by 1 sec.
    extended_spikes           = { 90966, 389721, 2 }, -- Increases the duration of Demon Spikes by 1 sec.
    fallout                   = { 90972, 227174, 1 }, -- Immolation Aura's initial burst has a chance to shatter Lesser Soul Fragments from enemies.
    feast_of_souls            = { 90969, 207697, 1 }, -- Soul Cleave heals you for an additional 372 over 6 sec.
    feed_the_demon            = { 90983, 218612, 2 }, -- Consuming a Soul Fragment reduces the remaining cooldown of Demon Spikes by 0.25 sec.
    fel_devastation           = { 90991, 212084, 1 }, -- Unleash the fel within you, damaging enemies directly in front of you for 839 Fire damage over 2 sec. Causing damage also heals you for up to 2,142 health.
    fel_flame_fortification   = { 90955, 389705, 1 }, -- You take 10% reduced magic damage while Immolation Aura is active.
    felblade                  = { 90932, 232893, 1 }, -- Charge to your target and deal 242 Fire damage. Shear has a chance to reset the cooldown of Felblade. Generates 40 Fury.
    felfire_haste             = { 90939, 389846, 1 }, -- Infernal Strike increases your movement speed by 10% for 8 sec.
    fiery_brand               = { 90951, 204021, 1 }, -- Brand an enemy with a demonic symbol, instantly dealing 690 Fire damage and 267 Fire damage over 10 sec. The enemy's damage done to you is reduced by 40% for 10 sec.
    fiery_demise              = { 90958, 389220, 2 }, -- Fiery Brand also increases Fire damage you deal to the target by 20%.
    first_of_the_illidari     = { 91003, 235893, 1 }, -- Metamorphosis grants 10% Versatility and its cooldown is reduced by 60 sec.
    flames_of_fury            = { 90949, 389694, 1 }, -- Sigil of Flame generates 2 additional Fury per target hit.
    focused_cleave            = { 90975, 343207, 1 }, -- Soul Cleave deals 30% increased damage to your primary target.
    fodder_to_the_flame       = { 90960, 391429, 1 }, -- Your damaging abilities have a chance to call forth a condemned demon for 25 sec. Throw Glaive deals lethal damage to the demon, which explodes on death, dealing 997 Shadow damage to nearby enemies and healing you for 25% of your maximum health. The explosion deals reduced damage beyond 5 targets.
    fracture                  = { 90970, 263642, 1 }, -- Rapidly slash your target for 606 Physical damage, and shatter 2 Lesser Soul Fragments from them. Generates 25 Fury.
    frailty                   = { 90990, 389958, 1 }, -- Enemies struck by Sigil of Flame are afflicted with Frailty for 5 sec. You heal for 8% of all damage you deal to targets with Frailty.
    illidari_knowledge        = { 90935, 389696, 2 }, -- Reduces magic damage taken by 2%.
    imprison                  = { 91007, 217832, 1 }, -- Imprisons a demon, beast, or humanoid, incapacitating them for 1 min. Damage will cancel the effect. Limit 1.
    improved_disrupt          = { 90938, 320361, 1 }, -- Increases the range of Disrupt to 10 yards.
    improved_sigil_of_misery  = { 90945, 320418, 1 }, -- Reduces the cooldown of Sigil of Misery by 30 sec.
    infernal_armor            = { 91004, 320331, 2 }, -- Immolation Aura increases your armor by 10% and causes melee attackers to suffer 27 Fire damage.
    internal_struggle         = { 90934, 393822, 1 }, -- Increases your Mastery by 3.0%.
    last_resort               = { 90979, 209258, 1 }, -- Sustaining fatal damage instead transforms you to Metamorphosis form. This may occur once every 8 min.
    long_night                = { 91001, 389781, 1 }, -- Increases the duration of Darkness by 3 sec.
    lost_in_darkness          = { 90947, 389849, 1 }, -- Spectral Sight lasts an additional 6 sec if disrupted by attacking or taking damage.
    master_of_the_glaive      = { 90994, 389763, 1 }, -- Throw Glaive has 2 charges, and snares all enemies hit by 50% for 6 sec.
    meteoric_strikes          = { 90953, 389724, 1 }, -- Reduce the cooldown of Infernal Strike by 8 sec.
    misery_in_defeat          = { 90945, 388110, 1 }, -- You deal 20% increased damage to enemies for 5 sec after Sigil of Misery's effect on them ends.
    painbringer               = { 90976, 207387, 2 }, -- Consuming a Soul Fragment reduces all damage you take by 1% for 4 sec. Multiple applications may overlap.
    perfectly_balanced_glaive = { 90968, 320387, 1 }, -- Reduces the cooldown of Throw Glaive by 6 sec.
    pitch_black               = { 91001, 389783, 1 }, -- Reduces the cooldown of Darkness by 120 sec.
    precise_sigils            = { 90944, 389799, 1 }, -- All Sigils are now placed at your target's location, and the duration of their effects is increased by 2 sec.
    pursuit                   = { 90940, 320654, 1 }, -- Mastery increases your movement speed.
    quickened_sigils          = { 90997, 209281, 1 }, -- All Sigils activate 1 second faster, and their cooldowns are reduced by 20%.
    relentless_pursuit        = { 90926, 389819, 1 }, -- The cooldown of The Hunt is reduced by 12 sec whenever an enemy is killed while afflicted by its damage over time effect.
    retaliation               = { 90952, 389729, 1 }, -- While Demon Spikes is active, melee attacks against you cause the attacker to take 51 Physical damage. Generates high threat.
    revel_in_pain             = { 90957, 343014, 1 }, -- When Fiery Brand expires on your primary target, you gain a shield that absorbs up 3,496 damage for 15 sec, based on your damage dealt to them while Fiery Brand was active.
    roaring_fire              = { 90988, 391178, 1 }, -- Fel Devastation heals you for up to 50% more, based on your missing health.
    ruinous_bulwark           = { 90965, 326853, 1 }, -- Fel Devastation heals for an additional 10%, and 100% of its healing is converted into an absorb shield for 10 sec.
    rush_of_chaos             = { 90933, 320421, 1 }, -- Reduces the cooldown of Metamorphosis by 60 sec.
    shattered_restoration     = { 90950, 389824, 2 }, -- The healing of Shattered Souls is increased by 5%.
    shear_fury                = { 90970, 389997, 1 }, -- Shear generates 10 additional Fury.
    sigil_of_chains           = { 90954, 202138, 1 }, -- Place a Sigil of Chains at the target location that activates after 2 sec. All enemies affected by the sigil are pulled to its center and are snared, reducing movement speed by 70% for 6 sec.
    sigil_of_flame            = { 90943, 204596, 1 }, -- Place a Sigil of Flame at the target location that activates after 2 sec. Deals 76 Fire damage, and an additional 214 Fire damage over 6 sec, to all enemies affected by the sigil. Generates 30 Fury.
    sigil_of_misery           = { 90946, 207684, 1 }, -- Place a Sigil of Misery at the target location that activates after 2 sec. Causes all enemies affected by the sigil to cower in fear, disorienting them for 20 sec.
    sigil_of_silence          = { 90988, 202137, 1 }, -- Place a Sigil of Silence at the target location that activates after 2 sec. Silences all enemies affected by the sigil for 6 sec.
    soul_barrier              = { 90956, 263648, 1 }, -- Shield yourself for 12 sec, absorbing 2,590 damage. Consumes all Soul Fragments within 25 yds to add 518 to the shield per fragment.
    soul_carver               = { 90982, 207407, 1 }, -- Carve into the soul of your target, dealing 1,308 Fire damage and an additional 506 Fire damage over 3 sec. Immediately shatters 2 Lesser Soul Fragments from the target and 1 additional Lesser Soul Fragment every 1 sec.
    soul_furnace              = { 90974, 391165, 1 }, -- Every 10 Soul Fragments you consume increases the damage of your next Soul Cleave or Spirit Bomb by 40%.
    soul_rending              = { 90936, 204909, 2 }, -- Leech increased by 5%. Gain an additional 5% Leech while Metamorphosis is active.
    soul_sigils               = { 90929, 395446, 1 }, -- Afflicting an enemy with a Sigil generates 1 Lesser Soul Fragment.
    soulcrush                 = { 90980, 389985, 1 }, -- Multiple applications of Frailty may overlap. Soul Cleave applies Frailty to your primary target for 5 sec.
    soulmonger                = { 90973, 389711, 1 }, -- When consuming a Soul Fragment would heal you above full health it shields you instead, up to a maximum of 1,508.
    spirit_bomb               = { 90978, 247454, 1 }, -- Consume up to 5 available Soul Fragments then explode, damaging nearby enemies for 160 Fire damage per fragment consumed, and afflicting them with Frailty for 5 sec, causing you to heal for 8% of damage you deal to them. Deals reduced damage beyond 8 targets.
    stoke_the_flames          = { 90984, 393827, 1 }, -- Fel Devastation damage increased by 40%.
    swallowed_anger           = { 91005, 320313, 1 }, -- Consume Magic generates 20 Fury when a beneficial Magic effect is successfully removed from the target.
    the_hunt                  = { 90927, 370965, 1 }, -- Charge to your target, striking them for 2,121 Nature damage, rooting them in place for 1.5 sec and inflicting 1,423 Nature damage over 6 sec to up to 5 enemies in your path. The pursuit invigorates your soul, healing you for 50% of the damage you deal to your Hunt target for 30 sec.
    unleashed_power           = { 90992, 206477, 1 }, -- Reduces the Fury cost of Chaos Nova by 50% and its cooldown by 20%.
    unnatural_malice          = { 90926, 389811, 1 }, -- Increase the damage over time effect of The Hunt by 30%.
    unrestrained_fury         = { 90941, 320770, 2 }, -- Increases maximum Fury by 10.
    vengeful_bonds            = { 90930, 320635, 1 }, -- Vengeful Retreat reduces the movement speed of all nearby enemies by 70% for 3 sec.
    vengeful_retreat          = { 90942, 198793, 1 }, -- Remove all snares and vault away. Nearby enemies take 73 Physical damage.
    void_reaver               = { 90977, 268175, 1 }, -- Frailty now also reduces all damage you take from afflicted targets by 4%. Enemies struck by Soul Cleave are afflicted with Frailty for 5 sec.
    volatile_flameblood       = { 90986, 390808, 1 }, -- Immolation Aura generates 5-10 Fury when it deals critical damage. This effect may only occur once per 1.0 sec.
    vulnerability             = { 90981, 389976, 2 }, -- Frailty now also increases all damage you deal to afflicted targets by 4%.
    will_of_the_illidari      = { 91000, 389695, 2 }, -- Increases maximum health by 2%.
} )


-- PvP Talents
spec:RegisterPvpTalents( {
    blood_moon        = 5434, -- (355995) Consume Magic now affects all enemies within 8 yards of the target, and grants 5% Leech for 5 sec.
    chaotic_imprint   = 5439, -- (356510) Throw Glaive now deals damage from a random school of magic, and increases the target's damage taken from the school by 10% for 20 sec.
    cleansed_by_flame = 814 , -- (205625) Immolation Aura dispels all magical effects on you when cast.
    cover_of_darkness = 5520, -- (357419) The radius of Darkness is increased by 4 yds, and its duration by 2 sec.
    demonic_trample   = 3423, -- (205629) Transform to demon form, moving at 175% increased speed for 3 sec, knocking down all enemies in your path and dealing 52.1 Physical damage. During Demonic Trample you are unaffected by snares but cannot cast spells or use your normal attacks. Shares charges with Infernal Strike.
    detainment        = 3430, -- (205596) Imprison's PvP duration is increased by 1 sec, and targets become immune to damage and healing while imprisoned.
    everlasting_hunt  = 815 , -- (205626) Dealing damage increases your movement speed by 15% for 3 sec.
    glimpse           = 5522, -- (354489) Vengeful Retreat provides immunity to loss of control effects, and reduces damage taken by 75% until you land.
    illidans_grasp    = 819 , -- (205630) You strangle the target with demonic magic, dangling them in place for 6 sec. Use Illidan's Grasp again to toss the target to a location within 40 yards, stunning them and all nearby enemies for 3 sec and dealing 52.1 Shadow damage.
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
        id = 163073,
        duration = 15,
        max_stack = 1,
    },
    -- Armor increased by ${$W2*$AGI/100}.$?s321028[  Parry chance increased by $w1%.][]
    -- https://wowhead.com/beta/spell=203819
    demon_spikes = {
        id = 203819,
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
        duration = function () return azerite.revel_in_pain.enabled and 10 or 8 end,
        type = "Magic",
        max_stack = 1
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
    -- Talent: Movement slowed by $s1%.
    -- https://wowhead.com/beta/spell=204843
    sigil_of_chains = {
        id = 204843,
        duration = function () return talent.concentrated_sigils.enabled and 8 or 6 end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Sigil of Flame is active.
    -- https://wowhead.com/beta/spell=204596
    sigil_of_flame_active = {
        id = 204596,
        duration = 2,
        max_stack = 1
    },
    -- Talent: Suffering $w2 $@spelldesc395020 damage every $t2 sec.
    -- https://wowhead.com/beta/spell=204598
    sigil_of_flame = {
        id = 204598,
        duration = function () return talent.concentrated_sigils.enabled and 8 or 6 end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Sigil of Flame is active.
    -- https://wowhead.com/beta/spell=389810
    sigil_of_flame_active = {
        id = 389810,
        duration = 2,
        max_stack = 1
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=207685
    sigil_of_misery_debuff = {
        id = 207685,
        duration = function () return talent.concentrated_sigils.enabled and 22 or 20 end,
        mechanic = "flee",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=204490
    sigil_of_silence = {
        id = 204490,
        duration = function () return talent.concentrated_sigils.enabled and 8 or 6 end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Absorbs $w1 damage.
    -- https://wowhead.com/beta/spell=263648
    soul_barrier = {
        id = 263648,
        duration = 12,
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
    -- Conduit
    soul_furnace = {
        id = 339424,
        duration = 30,
        max_stack = 10,
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
    soul_furnace = {
        id = 391166,
        duration = 30,
        max_stack = 10
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
    -- Talent:
    -- https://wowhead.com/beta/spell=198793
    vengeful_retreat = {
        id = 198793,
        duration = 1,
        max_stack = 1
    },
    -- Talent: Movement speed reduced by $s1%.
    -- https://wowhead.com/beta/spell=198813
    vengeful_retreat_snare = {
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
    sigils[ sigil ] = query_time + ( talent.quickened_sigils.enabled and 1 or 2 )
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

        end
    end
end, false )


local sigil_types = { "chains", "flame", "misery", "silence" }

spec:RegisterHook( "reset_precast", function ()
    last_metamorphosis = nil
    last_infernal_strike = nil

    for i, sigil in ipairs( sigil_types ) do
        local activation = ( action[ "sigil_of_" .. sigil ].lastCast or 0 ) + ( talent.quickened_sigils.enabled and 2 or 1 )
        if activation > now then sigils[ sigil ] = activation
        else sigils[ sigil ] = 0 end
    end

    if IsSpellKnownOrOverridesKnown( class.abilities.elysian_decree.id ) then
        local activation = ( action.elysian_decree.lastCast or 0 ) + ( talent.quickened_sigils.enabled and 2 or 1 )
        if activation > now then sigils.elysian_decree = activation
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
end )

spec:RegisterHook( "advance_end", function( time )
    if query_time - time < sigils.flame and query_time >= sigils.flame then
        -- SoF should've applied.
        applyDebuff( "target", "sigil_of_flame", debuff.sigil_of_flame.duration - ( query_time - sigils.flame ) )
        active_dot.sigil_of_flame = active_enemies
        sigils.flame = 0
    end
end )


-- Gear Sets

-- Tier 28:
spec:RegisterSetBonuses( "tier28_2pc", 364454, "tier28_4pc", 363737 )
-- 2-Set - Burning Hunger - Damage dealt by Immolation Aura has a 10% chance to generate a Lesser Soul Fragment.
-- 4-Set - Rapacious Hunger - Consuming a Lesser Soul Fragment reduces the remaining cooldown of your Immolation Aura or Fel Devastation by 1 sec.
-- Nothing to model (2/13/22).

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
        cooldown = 90,
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
        cooldown = 60,
        gcd = "spell",
        school = "chromatic",

        spend = 30,
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

        spend = -20,
        spendType = "fury",

        talent = "consume_magic",
        startsCombat = false,

        toggle = "interrupts",
        buff = "dispellable_magic",

        handler = function ()
            removeBuff( "dispellable_magic" )
        end,
    },

    -- Talent: Summons darkness around you in a$?a357419[ 12 yd][n 8 yd] radius, granting friendly targets a $209426s2% chance to avoid all damage from an attack. Lasts $d.
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

    -- Covenant (Kyrian): Place a Kyrian Sigil at the target location that activates after $d.    Detonates to deal $307046s1 $@spelldesc395039 damage and shatter up to $s3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond $s1 targets.
    elysian_decree = {
        id = function() return covenant.kyrian and 306830 or 390163 end,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "arcane",

        talent = function()
            if covenant.kyrian then return end
            return "elysian_decree"
        end,
        startsCombat = false,

        handler = function ()
            create_sigil( "elysian_decree" )

            if legendary.blind_faith.enabled then applyBuff( "blind_faith" ) end
        end,

        copy = { 390163, 306830 }
    },

    -- Talent: Unleash the fel within you, damaging enemies directly in front of you for ${$212105s1*(2/$t1)} Fire damage over $d.$?s320639[ Causing damage also heals you for up to ${$212106s1*(2/$t1)} health.][]
    fel_devastation = {
        id = 212084,
        cast = 0,
        channeled = true,
        cooldown = 60,
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
                debuff.sinful.brand.expires = debuff.sinful_brand.expires + 0.75
            end
        end,

        finish = function ()
            if talent.demonic.enabled then applyBuff( "metamorphosis", 6 ) end
            if talent.ruinous_bulwark.enabled then applyBuff( "ruinous_bulwark" ) end
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

        handler = function ()
            applyDebuff( "target", "fiery_brand" )
            if talent.charred_flesh.enabled then applyBuff( "charred_flesh" ) end
            removeBuff( "spirit_of_the_darkness_flame" )
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

        spend = function () return level > 47 and buff.metamorphosis.up and -45 or -25 end,
        spendType = "fury",

        talent = "fracture",
        startsCombat = true,

        handler = function ()
            addStack( "soul_fragments", nil, 2 )
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
        cooldown = function() return ( talent.meteoric_strikes.enabled and 12 or 20 ) * ( 1 - 0.1 * talent.erratic_felheart.rank ) end,
        gcd = "off",
        school = "physical",

        startsCombat = false,

        sigil_placed = function() return sigil_placed end,

        readyTime = function ()
            if settings.infernal_charges == 0 then return end
            return ( ( 1 + settings.infernal_charges ) - cooldown.infernal_strike.charges_fractional ) * cooldown.infernal_strike.recharge
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
            return ( 240 - ( talent.first_of_the_illidari.enabled and 60 or 0 ) - ( talent.rush_of_chaos.enabled and 60 or 0 ) ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 )
        end,
        gcd = "off",
        school = "chaos",

        startsCombat = false,

        toggle = "cooldowns",

        handler = function ()
            applyBuff( "metamorphosis" )
            gain( 8, "fury" )

            if IsSpellKnownOrOverridesKnown( 317009 ) then
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

        spend = function () return level > 47 and buff.metamorphosis.up and -30 or -10 end,

        startsCombat = true,

        notalent = "fracture",

        handler = function ()
            addStack( "soul_fragments", nil, level > 19 and 2 or 1 )
        end,
    },

    -- Talent: Place a Sigil of Chains at the target location that activates after $d.    All enemies affected by the sigil are pulled to its center and are snared, reducing movement speed by $204843s1% for $204843d.
    sigil_of_chains = {
        id = 202138,
        cast = 0,
        cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 90 end,
        gcd = "spell",
        school = "physical",

        talent = "sigil_of_chains",
        startsCombat = false,

        handler = function ()
            create_sigil( "chains" )
        end,
    },

    -- Talent: Place a Sigil of Flame at your location that activates after $d.    Deals $204598s1 Fire damage, and an additional $204598o3 Fire damage over $204598d, to all enemies affected by the sigil.    |CFFffffffGenerates $389787s1 Fury.|R
    sigil_of_flame = {
        id = function () return talent.concentrated_sigils.enabled and 204513 or 204596 end,
        known = 204596,
        cast = 0,
        cooldown = 30,
        gcd = "spell",
        school = "physical",

        spend = -30,
        spendType = "fury",

        talent = "sigil_of_flame",
        startsCombat = false,

        readyTime = function ()
            return sigils.flame - query_time
        end,

        sigil_placed = function() return sigil_placed end,

        handler = function ()
            create_sigil( "flame" )
        end,

        copy = { 204596, 204513 }
    },

    -- Talent: Place a Sigil of Misery at your location that activates after $d.    Causes all enemies affected by the sigil to cower in fear. Targets are disoriented for $207685d.
    sigil_of_misery = {
        id = function () return talent.concentrated_sigils.enabled and 207684 or 202140 end,
        cast = 0,
        cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 120 - ( talent.improved_sigil_of_misery.enabled and 30 or 0 ) end,
        gcd = "spell",
        school = "physical",

        talent = "sigil_of_misery",
        startsCombat = false,

        toggle = "interrupts",

        handler = function ()
            create_sigil( "misery" )
        end,

        copy = { 207684, 202140 }
    },



    sigil_of_silence = {
        id = function () return talent.concentrated_sigils.enabled and 207682 or 202137 end,
        known = 202137,
        cast = 0,
        cooldown = function () return ( pvptalent.sigil_mastery.enabled and 0.75 or 1 ) * 60 end,
        gcd = "spell",

        startsCombat = true,
        texture = 1418288,

        toggle = "interrupts",

        usable = function () return debuff.casting.remains > ( talent.quickened_sigils.enabled and 1 or 2 ) end,
        handler = function ()
            interrupt() -- early, but oh well.
            create_sigil( "silence" )
        end,

        copy = { 207682, 202137 },

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

        handler = function ()
            applyBuff( "soul_barrier" )
        end,

        toggle = "defensives",

        handler = function ()
            if talent.feed_the_demon.enabled then
                gainChargeTime( "demon_spikes", 0.5 * buff.soul_fragments.stack )
            end

            buff.soul_fragments.count = 0
            applyBuff( "soul_barrier" )
        end,
    },

    -- Talent: Carve into the soul of your target, dealing ${$s2+$214743s1} Fire damage and an additional $o1 Fire damage over $d.  Immediately shatters $s3 Lesser Soul Fragments from the target and $s4 additional Lesser Soul Fragment every $t1 sec.
    soul_carver = {
        id = 207407,
        cast = 0,
        cooldown = 60,
        gcd = "spell",
        school = "fire",

        talent = "soul_carver",
        startsCombat = true,

        handler = function ()
            addStack( "soul_fragments", 2 )
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

            if talent.void_reaver.enabled then applyDebuff( "target", "void_reaver" ) end
            if legendary.fiery_soul.enabled then reduceCooldown( "fiery_brand", 2 * min( 2, buff.soul_fragments.stack ) ) end

            -- Razelikh's is random; can't predict it.

            buff.soul_fragments.count = max( 0, buff.soul_fragments.stack - 2 )

            if buff.soul_furnace.up and buff.soul_furnace.stack == 10 then removeBuff( "soul_furnace" ) end
        end,
    },

    -- Allows you to see enemies and treasures through physical barriers, as well as enemies that are stealthed and invisible. Lasts $d.    Attacking or taking damage disrupts the sight.
    spectral_sight = {
        id = 188501,
        cast = 0,
        cooldown = 60,
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

            buff.soul_fragments.count = 0
        end,
    },


    -- Talent / Covenant (Night Fae): Charge to your target, striking them for $370966s1 $@spelldesc395042 damage, rooting them in place for $370970d and inflicting $370969o1 $@spelldesc395042 damage over $370969d to up to $370967s2 enemies in your path.     The pursuit invigorates your soul, healing you for $?c1[$370968s1%][$370968s2%] of the damage you deal to your Hunt target for $370966d.
    the_hunt = {
        id = function() return talent.the_hunt.enabled and 370965 or 323639 end,
        cast = 1,
        cooldown = function() return talent.the_hunt.enabled and 90 or 180 end,
        gcd = "spell",
        school = "nature",

        talent = "the_hunt",
        startsCombat = false,

        toggle = function() return talent.the_hunt.enabled and "cooldowns" or "essences" end,

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
    },

    -- Throw a demonic glaive at the target, dealing $337819s1 Physical damage. The glaive can ricochet to $?$s320386[${$337819x1-1} additional enemies][an additional enemy] within 10 yards.
    throw_glaive = {
        id = 204157,
        cast = 0,
        charges = 1,
        cooldown = 9,
        recharge = 9,
        gcd = "spell",
        school = "physical",

        spend = function() return talent.furious_throws.enabled and 25 or nil end,
        spend = function() return talent.furious_throws.enabled and "fury" or nil end,

        startsCombat = true,

        handler = function ()
            if conduit.serrated_glaive.enabled then applyDebuff( "target", "exposed_wound" ) end
            interrupt()
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

        readyTime = function ()
            if settings.recommend_movement then return 0 end
            return 3600
        end,

        handler = function ()
            if target.within8 then
                applyDebuff( "target", "vengeful_retreat" )
                if talent.momentum.enabled then applyBuff( "momentum" ) end
            end

            if pvptalent.glimpse.enabled then applyBuff( "glimpse" ) end
        end,
    }
} )


spec:RegisterOptions( {
    enabled = true,

    aoe = 2,

    nameplates = true,
    nameplateRange = 8,

    damage = true,
    damageExpiration = 8,

    potion = "phantom_fire",

    package = "Vengeance",
} )


spec:RegisterSetting( "infernal_charges", 1, {
    name = "Reserve |T1344650:0|t Infernal Strike Charges",
    desc = "If set above zero, the addon will not recommend |T1344650:0|t Infernal Strike if it would leave you with fewer charges.",
    icon = 1344650,
    iconCoords = { 0.1, 0.9, 0.1, 0.9 },
    type = "range",
    min = 0,
    max = 2,
    step = 0.1,
    width = 1.5
} )


spec:RegisterPack( "Vengeance", 20220306, [[dOuaNaqivipIqWMKiFsfkJIkCkIQvrLQQxrf1SKa7ss)IO0WisDmIILrLYZKqnnvO6AQG2gHO(gvQ04OIGZrLkwhHqnpjK7bj7tc6GeI0cjKEOkanrvG6IecPnsfrFKkvfJufqDsvaSsjQzQci3Kkc1oHO(jHq0svbYtvPPcPSvQiKVsieglHi2lu)vjdg4WuwSQ8ysnzQ6YO2Ss9zv0OjuNwQxtKmBe3wvTBr)g0WjIJtLQslhPNtY0fUobBNk57qQgpvKopez9uPkZhc7xXyzWOHVElymYUjTBUjDXslYvzCx3e5JJVbssy8vIPLYoz8nTpJVorCEYwQz8vIHebAEmA4Rckq1m(kocjkrSSYE2HyHxvd)YQ6VaXIgMAQTdzv9xll((eAsCas8dF9wWyKDtA3Ct6ILwKRY4UUjYf7o4RscRXiFOtqg8vC79CIF4RNvA89G5pmhWbwidMoaNiopzl18u2j2OAXdqKlyaUjTBUnLNYIucbI(aCsQPdbkpalgabI(aCsbksdWHek7IZqnaNuGI0aALsGvda9oepGRKM2Xaef(FYR4RekC3egFfbryahm)H5aoWczW0b4eX5jBPMNYIGimaNyJQfparUGb4M0U52uEklcIWaePece9b4KuthcuEawmace9b4KcuKgGdju2fNHAaoPafPb0kLaRga6DiEaxjnTJbik8)KxNYtzthnmvvjuwd)plq9Grqy)AtmKyp6DEUcOt7CkB6OHPQkHYA4)zHZOKDtyLyn12rb9gLckqED6RseuHaHxmvqs0WebcfuG860xDbjw0eEPGexCgt5PSimaruNYAHG9dGDXuKgq0FEaHyEaMoG0b0QbyUSMypcxNYMoAyQCgLSUmABpcxqAFg1JAPF9eAIVaxgrGrfgHZOANWSDVopxBI9zvLt7ryFPWiCg1Nan78CzK2fx50Ee2xkmcNrvl2Ou2V2ewjUYP9iSFkB6OHPYzuY6BfvqsmLnD0Wu5mkz1Wuj8513oB9u20rdtLZOKLYUyQIxF7S1tzthnmvoJs2qmfI(6KyTlUGEJ6jS31ntwp4)zu)NZOQctlfQdl54jS31()HelAyUmbQvfKGaXrpH9U(5W(qQeXqvRQcsKpLnD0Wu5mkz1gHSmD0WCrAvuqAFg1JAPVavqBDGsMc6nkxgTThHRpQL(1tOj(PSPJgMkNrjR2iKLPJgMlsRIcs7ZO88Mtv7IvtzthnmvoJswTrilthnmxKwffK2NrPHqIhIEQMYMoAyQCgLSAJqwMoAyUiTkkiTpJkH0VrMYtzryaozZuKgGOul9d4GGHfnmNYMoAyQQpQLEu7MPiTEul9tzthnmv1h1sVZOKT)FiXIgMltGAf0BuEyu3ntrA9Ow6RrRLQZZP8u20rdtvvdHepe9uHscmAyoLnD0Wuv1qiXdrpvoJswnm1Cguly)AtSpxqVr54ipmQAyQ5mOwW(1MyFE9eOznATuDEw6ithnmRAyQ5mOwW(1MyFU25At6tXbceBbczrzTyJEYRO)CrNAF9Bov(u20rdtvvdHepe9u5mkzrhsjExCNlkRGPLAUGEJ6jS3vsV5hbc9vvyAPkQ4PSPJgMQQgcjEi6PYzuY(5pKI0cUxebD7xEkBF1uwegWbgs8d4GytsNNdWjj2NvdydPdGDkRfcEaulp5baPdqQMqgWtyVvfmGEpajqLQFeUoarkbDdj1acksdiGd4KJbeI5bqGOZQyaAiK4HONd4zk2payoaZL1e7r4bWj)BwvNYMoAyQQAiK4HONkNrjlLnjDEU2e7ZQc6nQWONCuJ(ZRaU8nxKm1drGWHJWONCufZgjexLOJcDcsJary0toQIzJeIRs0rrOCtA5LCy6ODXlo5FZkuYGaXUpfhlk)Tovf6M7ixoceocJEYrn6pVc4sIowUjDHflDjhMoAx8It(3ScLmiqS7tXXIYFRtvHh)4YLpLfHbCW82eiXa2gH8mTudydPdqqzpcpawP4uZQ6u20rdtvvdHepe9u5mkzfZgnwSsXPMNYMoAyQQAiK4HONkNrjRGIxDW)c49M1XkTpJsJKMadkmB96rmvuqVr9e276N)qksl4Ere0TF5PS9vvpe9CkB6OHPQQHqIhIEQCgLSckE1b)liTpJYuIDzjRwuZ9G0Lgsnsb9gLNFc7DLAUhKU0qQrwE(jS3vpe9ebcp)e27QgMEbD0U4vNsT88tyVRcskfg9KJQy2iH4QeDuuXYGary0toQr)5vax(MlYnPNYIWaoyEBcKyaBJqEMwQbSH0biOShHhqh8xvNYMoAyQQAiK4HONkNrjRGIxDWF1u20rdtvvdHepe9u5mkzvDUfiRh1sFb9g1rEyuvDUfiRh1sFnATuDEoLnD0Wuv1qiXdrpvoJs2qmVelKXu20rdtvvdHepe9u5mkzzcsQ2YLN1uMNYtzryahmV5u1Uy1u20rdtv1ZBovTlwHYZFyUusAPyvb9gvyPuDEwYHJTaHSOSwSrp5v0FUizk1Pg(78C5TVDYRIvYrGWHPJ2fV4K)nRkS4sDQH)opxE7BN8QyvPNWEx98hMlLKwkwv9q0t5iq4Otn8355YBF7KxhQku6QBh6(fZgjex)MtLlFkB6OHPQ65nNQ2fRCgLSkOaz9mkTzAb9gLdthTlEXj)BwvyXL6ud)DEU823o5vXQspH9U65pmxkjTuSQ6HONYrGWrNA4VZZL3(2jVouvO01J7(fZgjex)MtLpLnD0Wuv98Mtv7IvoJs2NarQf70GA6OHzb9gLy2iH4QeMQ5mk6qPNYMoAyQQEEZPQDXkNrj7Nd7dPsedvTQGEJ6ihHr4mQE(dZwx50Ee2lVKJJ0qxCAzuDXzigjkceh5Hrv15wGSEul91O1s15PCeiC8GkvPDFkowu(BDQksMdLpLnD0Wuv98Mtv7IvoJs2DZuKwpQL(P8uwegaYq63id4GGHfnmNYMoAyQQjK(nIZOKTZnttJSubTLIlO3O2ceYIYAXg9Kxr)5IKPKJJcJWzu3e7Zln1uIRCApc7rGWHhgvvF2KfCV2e7Zvk)TovfvCPJmD0WS25MPPrwQG2sXvvF2KLeIPzVC5tzthnmv1es)gXzuY(eisTyNguthnmNYMoAyQQjK(nIZOKvjPPDSEW)RGEJYHJNWEx)CyFivIyOQvvbjLcJWzu3uthcuUYP9iSVKckqwBQD(5mufIQy5iqOGcK1MANFodvHOoU8PSPJgMQAcPFJ4mkz3mz5zxMkSOHzb9gvyPuDEwYHPJ2fV4K)nRkugeicJWzu98hMTUYP9iSx(u20rdtvnH0VrCgLSkOazPjS5IlO3OC4imcNrvjPPDSEW)RYP9iSVKckqwBQD(5muOKwocehfgHZOQK00owp4)v50Ee2lVKdhHr4mQBQPdbkx50Ee2xAlqrQquhEOCeiCCuyeoJ6MA6qGYvoThH9L2cuKkeL7kTCei0qiXdrpRBMS8Sltfw0WSs5V1PQWWONCuJ(ZRaU8nJaHJNWEx)CyFivIyOQvvbjLC4imcNrDtnDiq5kN2JW(sBbksfIQ4dLJaHJJcJWzu3uthcuUYP9iSV0wGIuHOouA5YLlFkB6OHPQMq63ioJs2()HelAyUmbQvqVr5WHlJ22JW1h1s)6j0eFjnes8q0Z6UzksRh1sFLYFRtvHYiTCeioYLrB7r46JAPF9eAIxEPTafPIq5ospLnD0Wuvti9BeNrj7MjpI55c6nQTafPIqjYspLnD0Wuvti9BeNrj7MA6qGYf0BuBbksfvS0iq4WryeoJQsst7y9G)xLt7ryFjfuGS2u78ZzOkcvXYrGWXrHr4mQkjnTJ1d(FvoThH9LC44jS31ph2hsLigQAvvqsPTafPIqD4HYrGWXtyVRFoSpKkrmu1QQhIEwAlqrQiuUR0YLlx(u20rdtvnH0VrCgLSQ(Sjl4ETj2NlO3OoYHg6ItlJQuirBllrfsEdPNCLAUhtAPeRwEE3e(ZziFkB6OHPQMq63ioJswLy2Otzthnmv1es)gXzuYgIPq0xNeRDX4RlMQAyIr2nPDtgzKXTIXx0nA25PcFfrispiKpai7(iIhWaqtmpG(lbsJbSH0bCmjuwd)plo2aOS7Rqtz)auWppatiGFly)a0IT8Kv1P8bQtEaUjIhWbeMUyAW(bCmfuG860xfjhBabCahtbfiVo9vrsLt7ry)XgGdzCQ86u(a1jpa3eXd4actxmny)aoMckqED6RIKJnGaoGJPGcKxN(QiPYP9iS)ydWIbiIkI8anahY4u51P8uweHi9Gq(aGS7JiEadanX8a6VeingWgshWXsi9BKJnak7(k0u2paf8ZdWec43c2paTylpzvDkFG6KhG7iIhWbeMUyAW(bCmQqYBi9KRIKJnGaoGJrfsEdPNCvKu50Ee2FSb4qgNkVoLNYhGVeiny)ae5by6OH5aiTku1Pm(sAvOWOHVpQLEmAyKLbJg(YP9iShlk(6zLM2sIgM4Rt2mfPbik1s)aoiyyrdt810rdt8D3mfP1JAPhhyKDdJg(YP9iShlk(QPDW02WxpmQ7MPiTEul91O1s15j(A6OHj(2)pKyrdZLjqnCGd81ZBtGey0Wildgn8Lt7rypwu8fkbFvCGVMoAyIVUmABpcJVUmIaJVHr4mQ2jmB3RZZ1MyFwv50Ee2pGsdimcNr9jqZopxgPDXvoThH9dO0acJWzu1InkL9RnHvIRCApc7XxpR00ws0WeFfrDkRfc2pa2ftrAar)5beI5by6ashqRgG5YAI9iCfFDz0vAFgFFul9RNqt84aJSBy0WxthnmXxFROcsc8Lt7rypwuCGrUymA4RPJgM4RgMkHpV(2zRXxoThH9yrXbg5JJrdFnD0WeFPSlMQ413oBn(YP9iShlkoWiFign8Lt7rypwu8vt7GPTHVpH9UUzY6b)pJ6)CgvvyAPgaQbC4aknahd4jS31()HelAyUmbQvfKmaeigWrd4jS31ph2hsLigQAvvqYaKJVMoAyIVHyke91jXAxmoWilYy0WxoThH9yrXxnTdM2g(6YOT9iC9rT0VEcnXJVQG26aJSm4RPJgM4R2iKLPJgMlsRc8L0QyL2NX3h1spoWi7Uy0WxoThH9yrXxthnmXxTrilthnmxKwf4lPvXkTpJVEEZPQDXkCGr2jGrdF50Ee2JffFnD0WeF1gHSmD0WCrAvGVKwfR0(m(QHqIhIEQWbgz3bJg(YP9iShlk(A6OHj(Qnczz6OH5I0QaFjTkwP9z8nH0VrWboWxjuwd)plWOHrwgmA4RPJgM47dgbH9RnXqI9O355kGoTt8Lt7rypwuCGr2nmA4lN2JWESO4RM2btBdFvqbYRtFvIGkei8IPcsIgMvoThH9dabIbOGcKxN(QliXIMWlfK4IZOYP9iShFnD0WeF3ewjwtTDGdCGVAiK4HONkmAyKLbJg(A6OHj(kbgnmXxoThH9yrXbgz3WOHVCApc7XIIVAAhmTn81XaoAaEyu1WuZzqTG9RnX(86jqZA0AP68CaLgWrdW0rdZQgMAodQfSFTj2NRDU2K(uCmaeigWwGqwuwl2ON8k6ppGIgWP2x)MthGC810rdt8vdtnNb1c2V2e7Z4aJCXy0WxoThH9yrXxnTdM2g((e27kP38JaH(QkmTudOObum(A6OHj(IoKs8U4oxuwbtl1moWiFCmA4RPJgM47N)qksl4Ere0TF5PS9v4lN2JWESO4aJ8Hy0WxoThH9yrXxthnmXxkBs68CTj2Nv4RNvAAljAyIVhyiXpGdInjDEoaNKyFwnGnKoa2PSwi4bqT8KhaKoaPAczapH9wvWa69aKavQ(r46aePe0nKudiOinGaoGtogqiMhabIoRIbOHqIhIEoGNPy)aG5amxwtShHhaN8VzvfF10oyAB4By0toQr)5vax(MhqrdqM6HdabIb4yaogqy0toQIzJeIRs0XakCaobPhacedim6jhvXSrcXvj6yafHAaUj9aKpGsdWXamD0U4fN8Vz1aqnazgacedy3NIJfL)wNQbu4aCZDgG8biFaiqmahdim6jh1O)8kGlj6y5M0dOWbuS0dO0aCmathTlEXj)BwnaudqMbGaXa29P4yr5V1PAafoGJF8biFaYXbgzrgJg(YP9iShlk(6zLM2sIgM47bZBtGedyBeYZ0snGnKoabL9i8ayLItnRQ4RPJgM4Ry2OXIvko1moWi7Uy0WxoThH9yrXxthnmXxnsAcmOWS1RhXub(QPDW02W3NWEx)8hsrAb3lIGU9lpLTVQ6HON4lV3SowP9z8vJKMadkmB96rmvGdmYobmA4lN2JWESO4RPJgM4RPe7YswTOM7bPlnKAe8vt7GPTHVE(jS3vQ5Eq6sdPgz55NWEx9q0ZbGaXa88tyVRAy6f0r7IxDk1YZpH9UkizaLgqy0toQIzJeIRs0XakAaflZaqGyaHrp5Og9NxbC5BEafna3KgFt7Z4RPe7YswTOM7bPlnKAeCGr2DWOHVCApc7XIIVEwPPTKOHj(EW82eiXa2gH8mTudydPdqqzpcpGo4VQIVMoAyIVckE1b)v4aJSmsJrdF50Ee2JffF10oyAB47rdWdJQQZTaz9Ow6RrRLQZt810rdt8v15wGSEul94aJSmYGrdFnD0WeFdX8sSqg4lN2JWESO4aJSmUHrdFnD0WeFzcsQ2YLN1uMXxoThH9yrXboWxpV5u1UyfgnmYYGrdF50Ee2JffFnD0WeF98hMlLKwkwHVEwPPTKOHj(EW8Mtv7Iv4RM2btBdFdlLQZZbuAaogGJbSfiKfL1In6jVI(ZdOObiZaknGo1WFNNlV9TtEvSAaYhacedWXamD0U4fN8Vz1akCafpGsdOtn8355YBF7KxfRgqPb8e27QN)WCPK0sXQQhIEoa5dabIb4yaDQH)opxE7BN86q1akCasxD7Wb4(hGy2iH463C6aKpa54aJSBy0WxoThH9yrXxnTdM2g(6yaMoAx8It(3SAafoGIhqPb0Pg(78C5TVDYRIvdO0aEc7D1ZFyUusAPyv1drphG8bGaXaCmGo1WFNNlV9TtEDOAafoaPRhFaU)biMnsiU(nNoa54RPJgM4RckqwpJsBMIdmYfJrdF50Ee2JffF10oyAB4Ry2iH4QeMQ5mgqrd4qPXxthnmX3NarQf70GA6OHjoWiFCmA4lN2JWESO4RM2btBdFpAaogqyeoJQN)WS1voThH9dq(aknahd4ObOHU40YO6IZqms0bGaXaoAaEyuvDUfiRh1sFnATuDEoa5dabIb4yapOsnGsdy3NIJfL)wNQbu0aK5WbihFnD0WeF)CyFivIyOQv4aJ8Hy0WxthnmX3DZuKwpQLE8Lt7rypwuCGd8nH0VrWOHrwgmA4lN2JWESO4RPJgM4BNBMMgzPcAlfJVEwPPTKOHj(ImK(nYaoiyyrdt8vt7GPTHVBbczrzTyJEYRO)8akAaYmGsdWXaoAaHr4mQBI95LMAkXvoThH9dabIb4yaEyuv9ztwW9AtSpxP836unGIgqXdO0aoAaMoAyw7CZ00ilvqBP4QQpBYscX0SFaYhGCCGr2nmA4RPJgM47tGi1IDAqnD0WeF50Ee2JffhyKlgJg(YP9iShlk(QPDW02WxhdWXaEc7D9ZH9HujIHQwvfKmGsdimcNrDtnDiq5kN2JW(buAakOazTP25NZqnGcrnGIhG8bGaXauqbYAtTZpNHAafIAahFaYXxthnmXxLKM2X6b)pCGr(4y0WxoThH9yrXxnTdM2g(gwkvNNdO0aCmathTlEXj)BwnGchGmdabIbegHZO65pmBDLt7ry)aKJVMoAyIVBMS8Sltfw0WehyKpeJg(YP9iShlk(QPDW02WxhdWXacJWzuvsAAhRh8)QCApc7hqPbOGcK1MANFod1aqnaPhG8bGaXaoAaHr4mQkjnTJ1d(FvoThH9dq(aknahdWXacJWzu3uthcuUYP9iSFaLgWwGI0ake1ao8WbiFaiqmahd4ObegHZOUPMoeOCLt7ry)aknGTafPbuiQb4Uspa5dabIbOHqIhIEw3mz5zxMkSOHzLYFRt1akCaHrp5Og9NxbC5BEaiqmahd4jS31ph2hsLigQAvvqYaknahdWXacJWzu3uthcuUYP9iSFaLgWwGI0ake1ak(WbiFaiqmahd4ObegHZOUPMoeOCLt7ry)aknGTafPbuiQbCO0dq(aKpa5dqo(A6OHj(QGcKLMWMlghyKfzmA4lN2JWESO4RM2btBdFDmahdWLrB7r46JAPF9eAIFaLgGgcjEi6zD3mfP1JAPVs5V1PAafoazKEaYhaced4Ob4YOT9iC9rT0VEcnXpa5dO0a2cuKgqrOgG7in(A6OHj(2)pKyrdZLjqnCGr2DXOHVCApc7XIIVAAhmTn8DlqrAafHAaIS04RPJgM47MjpI5zCGr2jGrdF50Ee2JffF10oyAB47wGI0akAafl9aqGyaogGJbegHZOQK00owp4)v50Ee2pGsdqbfiRn1o)CgQbueQbu8aKpaeigGJbC0acJWzuvsAAhRh8)QCApc7hqPb4yaogWtyVRFoSpKkrmu1QQGKbuAaBbksdOiud4WdhG8bGaXaCmGNWEx)CyFivIyOQvvpe9CaLgWwGI0akc1aCxPhG8biFaYhGC810rdt8DtnDiqzCGr2DWOHVCApc7XIIVAAhmTn89Ob4yaAOloTmQsHeTTCaLgavi5nKEYvQ5EmPLsSA55Dt4pNrLt7ry)aKJVMoAyIVQ(Sjl4ETj2NXbgzzKgJg(A6OHj(QeZgfF50Ee2JffhyKLrgmA4RPJgM4BiMcrFDsS2fJVCApc7XIIdCGd81ecXqk(E7)beh4aJb]] )