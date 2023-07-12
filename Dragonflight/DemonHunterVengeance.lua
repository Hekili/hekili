-- DemonHunterVengeance.lua
-- October 2022

if UnitClassBase( "player" ) ~= "DEMONHUNTER" then return end

local addon, ns = ...
local Hekili = _G[ addon ]
local class, state = Hekili.Class, Hekili.State

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
    aura_of_pain              = { 90932, 207347, 1 }, -- Increases the critical strike chance of Immolation Aura by 6%.
    blazing_path              = { 91008, 320416, 1 }, -- Infernal Strike gains an additional charge.
    bouncing_glaives          = { 90931, 320386, 1 }, -- Throw Glaive ricochets to 1 additional target.
    chaos_fragments           = { 90992, 320412, 1 }, -- Each enemy stunned by Chaos Nova has a 30% chance to generate a Lesser Soul Fragment.
    chaos_nova                = { 90993, 179057, 1 }, -- Unleash an eruption of fel energy, dealing 1,946 Chaos damage and stunning all nearby enemies for 2 sec. Each enemy stunned by Chaos Nova has a 30% chance to generate a Lesser Soul Fragment.
    charred_warblades         = { 90948, 213010, 1 }, -- You heal for 4% of all Fire damage you deal.
    collective_anguish        = { 90995, 390152, 1 }, -- Fel Devastation summons an allied Havoc Demon Hunter who casts Eye Beam, dealing 18,004 Chaos damage over 1.6 sec. Deals reduced damage beyond 5 targets.
    concentrated_sigils       = { 90944, 207666, 1 }, -- All Sigils are now placed at your location, and the duration of their effects is increased by 2 sec.
    consume_magic             = { 91006, 278326, 1 }, -- Consume 1 beneficial Magic effect removing it from the target.
    darkness                  = { 91002, 196718, 1 }, -- Summons darkness around you in an 8 yd radius, granting friendly targets a 20% chance to avoid all damage from an attack. Lasts 8 sec.
    demon_muzzle              = { 90928, 388111, 1 }, -- Enemies deal 8% reduced magic damage to you for 8 sec after being afflicted by one of your Sigils.
    demonic                   = { 91003, 213410, 1 }, -- Fel Devastation causes you to enter demon form for 6 sec after it finishes dealing damage.
    disrupting_fury           = { 90937, 183782, 1 }, -- Disrupt generates 30 Fury on a successful interrupt.
    erratic_felheart          = { 90996, 391397, 2 }, -- The cooldown of Infernal Strike is reduced by 10%.
    extended_sigils           = { 90998, 389697, 2 }, -- Increases the duration of Sigil effects by 1.0 sec.
    felblade                  = { 90932, 232893, 1 }, -- Charge to your target and deal 5,118 Fire damage. Shear has a chance to reset the cooldown of Felblade. Generates 40 Fury.
    felfire_haste             = { 90939, 389846, 1 }, -- Infernal Strike increases your movement speed by 10% for 8 sec.
    first_of_the_illidari     = { 91003, 235893, 1 }, -- Metamorphosis grants 10% versatility and its cooldown is reduced by 60 sec.
    flames_of_fury            = { 90949, 389694, 1 }, -- Sigil of Flame generates 2 additional Fury per target hit.
    illidari_knowledge        = { 90935, 389696, 2 }, -- Reduces magic damage taken by 2%.
    imprison                  = { 91007, 217832, 1 }, -- Imprisons a demon, beast, or humanoid, incapacitating them for 1 min. Damage will cancel the effect. Limit 1.
    improved_disrupt          = { 90938, 320361, 1 }, -- Increases the range of Disrupt to 10 yds.
    improved_sigil_of_misery  = { 90945, 320418, 1 }, -- Reduces the cooldown of Sigil of Misery by 30 sec.
    infernal_armor            = { 91004, 320331, 2 }, -- Immolation Aura increases your armor by 10% and causes melee attackers to suffer $320334s1/$s3${$320334s1/$s3} Fire damage.
    internal_struggle         = { 90934, 393822, 1 }, -- Increases your mastery by 3.0%.
    long_night                = { 91001, 389781, 1 }, -- Increases the duration of Darkness by 3 sec.
    lost_in_darkness          = { 90947, 389849, 1 }, -- Spectral Sight lasts an additional 6 sec if disrupted by attacking or taking damage.
    master_of_the_glaive      = { 90994, 389763, 1 }, -- Throw Glaive has 2 charges, and snares all enemies hit by 50% for 6 sec.
    misery_in_defeat          = { 90945, 388110, 1 }, -- You deal 20% increased damage to enemies for 5 sec after Sigil of Misery's effect on them ends.
    pitch_black               = { 91001, 389783, 1 }, -- Reduces the cooldown of Darkness by 120 sec.
    precise_sigils            = { 90944, 389799, 1 }, -- All Sigils are now placed at your target's location, and the duration of their effects is increased by 2 sec.
    pursuit                   = { 90940, 320654, 1 }, -- Mastery increases your movement speed.
    quickened_sigils          = { 90997, 209281, 1 }, -- All Sigils activate 1 second faster, and their cooldowns are reduced by 20%.
    relentless_pursuit        = { 90926, 389819, 1 }, -- The cooldown of The Hunt is reduced by 12 sec whenever an enemy is killed while afflicted by its damage over time effect.
    rush_of_chaos             = { 90933, 320421, 1 }, -- Reduces the cooldown of Metamorphosis by 60 sec.
    shattered_restoration     = { 90950, 389824, 2 }, -- The healing of Shattered Souls is increased by 5%.
    sigil_of_misery           = { 90946, 207684, 1 }, -- Place a Sigil of Misery at the target location that activates after 1 sec. Causes all enemies affected by the sigil to cower in fear, disorienting them for 22 sec.
    soul_rending              = { 90936, 204909, 2 }, -- Leech increased by 5%. Gain an additional 5% leech while Metamorphosis is active.
    soul_sigils               = { 90929, 395446, 1 }, -- Afflicting an enemy with a Sigil generates 1 Lesser Soul Fragment.
    swallowed_anger           = { 91005, 320313, 1 }, -- Consume Magic generates 20 Fury when a beneficial Magic effect is successfully removed from the target.
    the_hunt                  = { 90927, 370965, 1 }, -- Charge to your target, striking them for 29,491 Nature damage, rooting them in place for 1.5 sec and inflicting 24,445 Nature damage over 6 sec to up to 5 enemies in your path. The pursuit invigorates your soul, healing you for 25% of the damage you deal to your Hunt target for 20 sec.
    unleashed_power           = { 90992, 206477, 1 }, -- Reduces the Fury cost of Chaos Nova by 50% and its cooldown by 20%.
    unnatural_malice          = { 90926, 389811, 1 }, -- Increase the damage over time effect of The Hunt by 30%.
    unrestrained_fury         = { 90941, 320770, 2 }, -- Increases maximum Fury by 10.
    vengeful_bonds            = { 90930, 320635, 1 }, -- Vengeful Retreat reduces the movement speed of all nearby enemies by 70% for 3 sec.
    will_of_the_illidari      = { 91000, 389695, 2 }, -- Increases maximum health by 2%.

    -- Vengeance
    agonizing_flames          = { 90971, 207548, 2 }, -- Immolation Aura increases your movement speed by 10% and its duration is increased by 25%.
    bulk_extraction           = { 90956, 320341, 1 }, -- Demolish the spirit of all those around you, dealing 2,472 Fire damage to nearby enemies and extracting up to 5 Lesser Soul Fragments, drawing them to you for immediate consumption.
    burning_alive             = { 90959, 207739, 1 }, -- Every 2 sec, Fiery Brand spreads to one nearby enemy.
    burning_blood             = { 90987, 390213, 2 }, -- Fire damage increased by 5%.
    calcified_spikes          = { 90967, 389720, 1 }, -- You take 12% reduced damage after Demon Spikes ends, fading by 1% per second.
    chains_of_anger           = { 90964, 389715, 1 }, -- Increases the radius of your Sigils by 2 yds.
    charred_flesh             = { 90962, 336639, 2 }, -- Immolation Aura damage increases the duration of your Fiery Brand by 0.25 sec.
    cycle_of_binding          = { 90963, 389718, 1 }, -- Afflicting an enemy with a Sigil reduces the cooldown of your Sigils by 3 sec.
    darkglare_boon            = { 90985, 389708, 2 }, -- When Fel Devastation finishes fully channeling, it refreshes 10-20% of its cooldown and refunds 10-20 Fury.
    deflecting_spikes         = { 90989, 321028, 1 }, -- Demon Spikes also increases your Parry chance by 15% for 8 sec.
    down_in_flames            = { 90961, 389732, 1 }, -- Fiery Brand has 15 sec reduced cooldown and 1 additional charge.
    elysian_decree            = { 90960, 390163, 1 }, -- Place a Kyrian Sigil at the target location that activates after 1 sec. Detonates to deal 27,207 Arcane damage and shatter up to 3 Lesser Soul Fragments from enemies affected by the sigil. Deals reduced damage beyond 5 targets.
    extended_spikes           = { 90966, 389721, 2 }, -- Increases the duration of Demon Spikes by 1 sec.
    fallout                   = { 90972, 227174, 1 }, -- Immolation Aura's initial burst has a chance to shatter Lesser Soul Fragments from enemies.
    feast_of_souls            = { 90969, 207697, 1 }, -- Soul Cleave heals you for an additional 6,714 over 6 sec.
    feed_the_demon            = { 90983, 218612, 2 }, -- Consuming a Soul Fragment reduces the remaining cooldown of Demon Spikes by 0.25 sec.
    fel_devastation           = { 90991, 212084, 1 }, -- Unleash the fel within you, damaging enemies directly in front of you for 17,528 Fire damage over 2 sec. Causing damage also heals you for up to 47,442 health.
    fel_flame_fortification   = { 90955, 389705, 1 }, -- You take 10% reduced magic damage while Immolation Aura is active.
    fiery_brand               = { 90951, 204021, 1 }, -- Brand an enemy with a demonic symbol, instantly dealing 16,004 Fire damage and 24,726 Fire damage over 10 sec. The enemy's damage done to you is reduced by 40% for 10 sec.
    fiery_demise              = { 90958, 389220, 2 }, -- Fiery Brand also increases Fire damage you deal to the target by 20%.
    focused_cleave            = { 90975, 343207, 1 }, -- Soul Cleave deals 40% increased damage to your primary target.
    fodder_to_the_flame       = { 90960, 391429, 1 }, -- Your damaging abilities have a chance to call forth a condemned demon for 25 sec. Throw Glaive deals lethal damage to the demon, which explodes on death, dealing 14,811 Shadow damage to nearby enemies and healing you for 20% of your maximum health. The explosion deals reduced damage beyond 5 targets.
    fracture                  = { 90970, 263642, 1 }, -- Rapidly slash your target for 9,574 Physical damage, and shatter 2 Lesser Soul Fragments from them. Generates 25 Fury.
    frailty                   = { 90990, 389958, 1 }, -- Enemies struck by Sigil of Flame are afflicted with Frailty for 6 sec. You heal for 10% of all damage you deal to targets with Frailty.
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
    soul_barrier              = { 90956, 263648, 1 }, -- Shield yourself for 12 sec, absorbing 46,631 damage. Consumes all Soul Fragments within 25 yds to add 9,326 to the shield per fragment.
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
        duration = 10,
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
        duration = function () return ( talent.concentrated_sigils.enabled and 8 or 6 ) + talent.erratic_felheart.rank + ( 2 * talent.precise_sigils.rank ) end,
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
        duration = function () return ( talent.concentrated_sigils.enabled and 8 or 6 ) + talent.erratic_felheart.rank + ( 2 * talent.precise_sigils.rank ) end,
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Disoriented.
    -- https://wowhead.com/beta/spell=207685
    sigil_of_misery_debuff = {
        id = 207685,
        duration = function () return ( talent.concentrated_sigils.enabled and 22 or 20 ) + talent.erratic_felheart.rank + ( 2 * talent.precise_sigils.rank ) end,
        mechanic = "flee",
        type = "Magic",
        max_stack = 1
    },
    -- Talent: Silenced.
    -- https://wowhead.com/beta/spell=204490
    sigil_of_silence = {
        id = 204490,
        duration = function () return ( talent.concentrated_sigils.enabled and 8 or 6 ) + talent.erratic_felheart.rank + ( 2 * talent.precise_sigils.rank ) end,
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
        if activation > now then sigils[ sigil ] = activation
        else sigils[ sigil ] = 0 end
    end

    if action.elysian_decree.known then
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

    fiery_brand_dot_primary_expires = nil
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
        cooldown = function() return talent.unleashed_power.enabled and 48 or 60 end,
        gcd = "spell",
        school = "chromatic",

        spend = function() return talent.unleashed_power.enabled and 15 or 30 end,
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


    demonic_trample = {
        id = 205629,
        cast = 0,
        charges = 2,
        cooldown = 12,
        recharge = 12,
        gcd = "spell",

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
            return ( 240 - ( talent.first_of_the_illidari.enabled and 60 or 0 ) - ( talent.rush_of_chaos.enabled and 60 or 0 ) ) * ( essence.vision_of_perfection.enabled and 0.87 or 1 )
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
        id = function () return talent.precise_sigils.enabled and 389810 or talent.concentrated_sigils.enabled and 204513 or 204596 end,
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

        copy = { 204596, 204513, 389810 }
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
        cooldown = 60,
        gcd = "spell",
        school = "fire",

        talent = "soul_carver",
        startsCombat = true,

        handler = function ()
            addStack( "soul_fragments", nil, 2 )
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
        charges = function() return talent.master_of_the_glaive.enabled and 2 or nil end,
        cooldown = function() return talent.perfectly_balanced_glaive.enabled and 3 or 9 end,
        recharge = function() return talent.master_of_the_glaive.enabled and ( talent.perfectly_balanced_glaive.enabled and 3 or 9 ) or nil end,
        gcd = "spell",
        school = "physical",

        spend = function() return talent.furious_throws.enabled and 25 or nil end,
        spendType = function() return talent.furious_throws.enabled and "fury" or nil end,

        startsCombat = true,

        handler = function ()
            if conduit.serrated_glaive.enabled then applyDebuff( "target", "exposed_wound" ) end
            if talent.master_of_the_glaive.enabled then applyDebuff( "target", "master_of_the_glaive" ) end
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
        nodebuff = "rooted",

        readyTime = function ()
            if settings.recommend_movement then return 0 end
            return 3600
        end,

        handler = function ()
            if talent.vengeful_bonds.enabled and target.within8 then
                applyDebuff( "target", "vengeful_retreat" )
            end
            if talent.momentum.enabled then applyBuff( "momentum" ) end

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
    name = strformat( "Reserve %s Charges", Hekili:GetSpellLinkWithTexture( 189110 ) ),
    desc = strformat( "If set above zero, %s will not be recommended if it would leave you with fewer charges.", Hekili:GetSpellLinkWithTexture( 189110 ) ),
    type = "range",
    min = 0,
    max = 2,
    step = 0.1,
    width = "full"
} )


spec:RegisterSetting( "frailty_stacks", 1, {
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



spec:RegisterPack( "Vengeance", 20230711, [[Hekili:TVvBVTnos4FlflqAmUwhl54M2Enb4U9tBXHIfW7EFzXjjAjkBIij6JKkP5GH(TFdPKSfPiLTJD2dfxqasS5mCMN5foKuAsGxWVfmpbjWbFZFI)0j345n2FQ)uVBcMlEAnoy(Au89OLWhkq5WV)N4ILyurSIYtzuuIucCAjto0kHyn)ZxD1sIyv5IXX08R4K8YmKGqlIzOuH87XxfmFrjjt8lfblSR(zGmxJJd(2Sp6bILKKGR5fZJdMl599tU59EEFUk6xrI4vvrEtg7nEwvu5AP8gx91QVwZ2S37pby7VbIiPksWif3Jf8Xa(z0usgGAuSeE8XRzyaXlqI)YTx9aIrqlYWVtA232mRqVWfLPP839akRC7OGExH4HLCSI6MnxQtqo4yUGbEoXQnBSqmhXfy2twP9aMXb3xgryN(k5CTsjMreJQ(6HBD(wToFxwN)qwN)awN)ESoFNwN)jyDEH4VhNvMG7f9i8XSYfpf(4kC26qo87SUouG8JRiq6imYYqsrmIvaPyHKyAXXaaFhaWFya4)maaNSKKfstdtZaeyNhsEoTEHziQKHEhj9wjBpGdXf4CcMFR3MnVrGYWfIXPOSmAPqUQQrwGesiCw5Ar3HaeXlZXH5OLK4UeifPya1zHqQc5E87K5t000WLXj36j1D8keBjO0C03dB(8fc5FeJb9iKLCUZBIM6X5a25RbXX7lV3OYs6YZ4Y1GelUhCIDftowGYPS1ROCcVlHuCwyc(bidu5LucT1DqGeAGyoHJhJlKX6eTPQOVGHks230U4ncsSjMwuMDpKTiy1d1L0AA9i)0pvf119(a9ESCk1EzPXxN9TM(iMbjnPLCdjfdX0W6VgMbUyTSv((5eahbLPXOyfoCvzHwkbo7jobvaMDmdJ7sb21ilesMHIasV0L2CtY6n9h9IeA7akN84gF4OrxOeAkdTmhMe)l3oDGq6aHmgohrk4Frk4qbjhlxl0pqzSisZ6SVgusznbkEfUawjQSBDiF3TxFrDYRwMjK9ocCgM8o9c7S23pNHrpGpmaoGvLktjlz6cAfgX0tdy0hdxMHi6AeC)lYqjyzzei99354QO6SiixEHCxaOSdSh9kKOkAPCYr17ibSHRpJb8rkRkkbbvyK7Y3i8XnjJGsqSyubouqzWEscPdoTK9eujiLete35nRr7)kJqHWa5)GBfh8xmktgHJGCJOsj82UCiIcPPD)EpuUdmTmnWEr)4EoI9AC)iFmI9ACVWNIyV6)f(qeD0Vmure4CJTw5zurRwR3OTfOJnYUFUs13Uu9FMsvwhpCvtz9lDb2UHQyknlH(yX4MnbgDr)P5Bon)(t7OHAx3QlGEXLwl4VzZw1RtQbm35pXUz0KonKHi36tBLtldB24YV8STDFR2U)lHT71327h77y7E7Z2BIqJcMlRhbgFZTAN5pjy(JW6nyLhpy(VTc2XGKVMYG9psL7M92wF0BLB09Vljm5vv5uyx5iuPGMdluHbGJfdx(Md769pifaj5TF)zAbOmf53Qd02sTGmf0ouf9iFP33hDGcvRmTdjBYZzw8NaWB2cziCVJLZRWpbu3zZTHqUoBNFLCcwGA73HWEldNtbFc4vEOGHGBd9ZOyDbwFhs1F4L49iFecD41G255ml(ta4UwfALLZRWpbup0QpNSD(vYjyb2xjAHHZPGpb8ADTyF6NrX6cStDw4WYj6Tu(WoxhUkCERa76Ai21u61o9whID5IRdxfhUDTx21u6noDMMND0Id0clVGcFVIT)z9T4CEUy(5jCnX(7f8Y1YdklfC7ThAFUNvr)bmyX9fW0)x)1QiCHG9uvucHREWQBf0hpR4ZW4pVc)aeRSus78CuPPdznS(PZAY1lQWpaXoOJOh5gSQU7vknlJ(O658jF8M8QOhXmSkbdubbsSes2AZYKpXB5J4t0YxbvDXTYcnUtsKmNGeOfio(ZvFTk69WD2GneKpWrlx6lbNIkZKBxCm35RxnV(pD8TEd3V1bZO3zxSwT4TV(PJ0Mhmh41752tYVEp3tqjNGfy)SQVEp39d2xVN7rk5xVN7jOKtWcSVs8175UFW(69C)X6EUFWXjcR7eO3ACyW6r7FoW)NDG7FjV9EJxRlz55kdMdh3CfLfmFoj)NdMRgx2iJnTra8XVPAnYg7j4V32LGWF16VG6wsKrwxt80BPHG5slacqOG5DBCHQO7GnFNfiGFM3esTIt66G5CSyhGBFpvYpLvI3oBZ9KRI2SbIBvrds)pBIJm8WN922q5GcR7U1g2AFtEGR(B(pF3R)ECV2O)NnXr2mF)DM)0NV5BTKDVO9qLKShAAERTs0D9ZhDwl82ZzDSOZVl6M5OcsdZEawZOIUFxgxAEV4Yf2Dkf8MQixVVzPQ(WWQY3qv(hRQ6KrCtxvTyibDPBm3lnW8jabzMvrxOwV4StqmdwwKrRDVTjqKwWhpJXf3gyn4vNwYSHfQr(WnTGQEV)KH9dnjBhGNqYWB6vhOLVA6UD0JKUTpDgZXCRQxE3MNd3MTKqt3M3H428662uNqq9G(2UzDRJRP)P76uB3WPLfT(P2GrZsZ78Un9pDv0TvrD6NALhXONQRpwXKDA0OrT7feTu1vR0HkYz021nkw161Dm)omztnZ66i0c2gocZIFA4zGNw5oPB0xW9kZDecvzRswQBw4o6yxdgVTiulnJ(92W((uxwR7)BdoGaO91MMDUD9rD130svv3Z1XDhucThxwkaT822gb3eNt7YKENHBYQ7SSlRDWdfdApQ1EItoAJCv1J6ci69BDv0xGLut3zcDAHDfO1YznZQmmq3PTBl)8L68ivdOVRy0EYS8UPlim6LBtqOLgQ3r4MSAw)xlGy6NU7w1fVQxl4OA(OTXjBZEQA2UMAhqVRB6vLpNOzr7A9DZYSEhSL77F4ouFTm82UL3KPR10TS95n5yM(QPD9tVjJFWiJt1G96mjK)VU18Mxc()IBm(6n6E9gDVy3O7GQz4U4UC67(NStDgnVD12T(40Cx8rS9NG)7p]] )